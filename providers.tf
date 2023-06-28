provider "openstack" {
    profile = "default"
    region = "eu-west-2"

    user_name       =   "OS_USERNAME"
    tenant_name     =   "OS_TENANT"
    password        =   "OS_PASSWORD"
    auth_url        =   "OS_AUTH_URL"
    region          =   "OS_REGION"
}

provider "azure" {
    profile = "default"
    region = "eu-west-2"

    user_name       =   "OS_USERNAME"
    tenant_name     =   "OS_TENANT"
    password        =   "OS_PASSWORD"
    auth_url        =   "OS_AUTH_URL"
    region          =   "OS_REGION"
}
