# Storage account to use
export STORAGE_ACCOUNT="StorageAccountName"

# Storage container to upload to
export STORAGE_CONTAINER="StorageContainerName"

# Resource group name
export GROUP="ResourceGroupName"

# Location
export LOCATION="centralus"

# Get storage account connection string based on info above
export CONNECTION=$(az storage account show-connection-string \
                    -n $STORAGE_ACCOUNT \
                    -g $GROUP \
                    -o tsv)
