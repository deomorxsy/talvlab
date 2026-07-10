#!/bin/sh
#
# depends-on: ./scripts/storage/set-openebs.sh

## Environment variables
SC_NFS="./artifacts/nfs-SC.yaml"
PVC_NFS_CSI_DYNAMIC_URI="https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/pvc-nfs-csi-dynamic.yaml"
HELM_CHART_NFS_CSI="csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"

# export envs
export SC_NFS PVC_NFS_CSI_DYNAMIC_URI


core_routine() {
    # add the CSI driver for NFS
    if ! helm repo add "${HELM_CHART_NFS_CSI}"; then
        echo "|> [ERROR]: could not add the helm chart for [csi-driver-nfs]. Exiting now.."
        return 1
    fi
    echo "|> [PASS]: successfully added the helm chart for [csi-driver-nfs]. Proceeding..."

    # fetch updates for the repo
    if ! helm repo update; then
        echo "|> [ERROR]: could not fetch updates for the repo. Exiting now..."
        return 1
    fi
        echo "|> [PASS]: successfully fetched updates for the repo. Proceeding..."

    # Install csi-driver-nfs
    if ! (helm upgrade --install csi-driver-nfs \
        csi-driver-nfs/csi-driver-nfs \
        --namespace kube-system \
        --version 4.11.0 \
        --set controller.replicas=2 \
        --set controller.runOnControlPlane=true \
        --set externalSnapshotter.enabled=false \
        --atomic); then
    echo "|> [ERROR]: could not install the [csi-driver-nfs] helm chart with helm. Exiting now..."
    echo
    return 1
    fi
    echo "|> [PASS]: successfully installed the [csi-driver-nfs] helm chart with helm. Exiting now..."
    echo


    # Create StorageClass
    if ! (

        (
    cat <<EOF
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
    name: nfs-csi
    provisioner: nfs.csi.k8s.io
    parameters:
    server: nfs-server.default.svc.cluster.local
    share: /
    # csi.storage.k8s.io/provisioner-secret is only needed for providing mountOptions in DeleteVolume
    # csi.storage.k8s.io/provisioner-secret-name: "mount-options"
    # csi.storage.k8s.io/provisioner-secret-namespace: "nfs-talv"
    reclaimPolicy: Delete
    volumeBindingMode: Immediate
    allowVolumeExpansion: true
    mountOptions:
    - nfsvers=4.1

EOF
) | kubectl apply -f -
    #tee "${SC_NFS}" && \
    #kubectl apply -f "${SC_NFS}"
); then
echo "|> [ERROR]: could not create a StorageClass for csi-driver-nfs. Exiting now..."
echo
return 1
    fi
echo "|> [PASS]: successfully created a StorageClass for csi-driver-nfs. Proceeding..."

# Create PVC
(
cat <<EOF
kubectl create -f "${}"
EOF
)

# Check CSI deployment
if ! kubectl --namespace=kube-system get pods --selector="app.kubernetes.io/instance=csi-driver-nfs" --watch; then
    echo "|> Error: could not deploy the csi-driver-nfs deployment. Exiting now..."
    return 1
fi


# Create namespace for the openebs nfs-server
kubectl create namespace nfs-example

# Create PVC for the NFS example
(
cat <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-server-claim
  namespace: nfs-example
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 200MiB
  storageClassName: openebs-single-replica
EOF
) | kubectl apply -f "${PVC_NFS_CSI_DYNAMIC_URI}"


# Deploy the rest of the resources
(
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-server
  namespace: nfs-example
spec:
  replicas: 1
  selector:
    matchLabels:
      role: nfs-server
  template:
    metadata:
      labels:
        role: nfs-server
    spec:
      volumes:
      - name: nfs-vol
        persistentVolumeClaim:
          claimName: nfs-server-claim
      restartPolicy: Always
      containers:
      - name: nfs-server
        image: itsthenetwork/nfs-server-alpine
        env:
        - name: SHARED_DIRECTORY
          value: /nfsshare
        ports:
          - name: nfs
            containerPort: 2049
        securityContext:
          privileged: true
          capabilities:
            add:
              - SYS_ADMIN
        livenessProbe:
          tcpSocket:
            port: 2049
          initialDelaySeconds: 10
          periodSeconds: 20
        readinessProbe:
          tcpSocket:
            port: 2049
          initialDelaySeconds: 5
          periodSeconds: 10
        volumeMounts:
          - mountPath: /nfsshare
            name: nfs-vol
EOF
) | kubectl apply -f -




    # Create service for the NFS Server
    (
    cat <<-EOF
    apiVersion: v1
    kind: Service
    metadata:
    name: nfs-service
    namespace: nfs-example
    spec:
    type: ClusterIP
    # clusterIP: "None"
    selector:
        role: nfs-server
    ports:
        - name: nfs
        port: 2049
        targetPort: 2049
        protocol: TCP

EOF
    ) | kubectl apply -f -



}

print_usage() {
    cat <<-END >&2
USAGE: DEPLOY_NFS.sh [-options]
                - clean
                - nfs_setup
                - version
                - help
eg,
MODE="clean"        . ./scripts/DEPLOY_NFS.sh   # clean intermediate compiler files
MODE="nfs_setup"    . ./scripts/DEPLOY_NFS.sh   # setup the nfs mount with PVC and StorageClass under a k3s cluster
MODE="version"      . ./scripts/DEPLOY_NFS.sh   # shows script version
MODE="help"         . ./scripts/DEPLOY_NFS.sh   # shows this help message

See the man page and example file for more info.

END

}

printa_version() {
    echo
    echo "|> Version: deploy-nfs v1.0.0"
    echo
}

printa_error() {

    echo "|> script: deploy-nfs.sh"
    echo "|> Invalid option. Please specify one of: nfsdep, clean, help, version"
    echo
}


# Check the argument passed from the command line
if ! [ -z "${DEPLOY_NFS_VERBOSE}" ] && [ "${DEPLOY_NFS_VERBOSE}" = "1" ]; then
    DEPLOY_NFS_VERBOSE="1" && export DEPLOY_NFS_VERBOSE;

    if ! env | grep "DEPLOY_NFS_VERBOSE"; then
        echo "|> [WARNING]: the [DEPLOY_NFS_VERBOSE] pretty-printer variable was not set. Exiting now..."
        return 1
    fi
    echo "|> [PASS]: the [DEPLOY_NFS_VERBOSE] pretty-printer variable was set with success. Proceeding..."
fi

if ! [ -z "${MODE}" ] &&
    [ "${MODE}" = "nfsdep" ] ||
    [ "${MODE}" = "clean" ] ||
    [ "${MODE}" = "help" ] ||
    [ "${MODE}" = "version" ]; then
    case "${MODE}" in
    "clean") clean ;;
    "nfsdep") nfsdep ;;
    *)
        printa_error
        print_usage
        ;;
    esac

elif [ "${MODE}" = "help" ] || [ "${MODE}" = "-h" ] || [ "${MODE}" = "--help" ]; then
    print_usage
elif [ "${MODE}" = "version" ] || [ "${MODE}" = "-v" ] || [ "${MODE}" = "--version" ]; then
    printf "\n|> Version: deploy-nfs 1.0.0"
else
    printa_error
    print_usage
fi

