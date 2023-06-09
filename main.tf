terraform {
    required_version = ">= 0.14.0"
    required_providers {
        openstack = {
            source = "terraform-provider-openstack/openstack"
            version = "1.49.0"
        }
    }
}

provider "openstack" {
    profile = "default"
    region = "eu-west-2"

    user_name       =   "OS_USERNAME"
    tenant_name     =   "OS_TENANT"
    password        =   "OS_PASSWORD"
    auth_url        =   "OS_AUTH_URL"
    region          =   "OS_REGION"
}
