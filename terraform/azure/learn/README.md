# Terraform on Azure

Going through the terraform learning guide on Azure.

Next steps:

[x] Remote state storage
[ ] Not committing secrets (.gitignore *.tfvars?)
[ ] VM access using ssh keys

## Azure cheatsheet

- Login: `az login` -> will bring up browser for oauth2 login
- Logout: `az logout`
- List available locations: `az account list-locations -o table`
- List VMs in a location: `az vm list-skus -l australiaeast  -o table`
- List available VM images: `az vm image list-skus -l australiaeast -f UbuntuServer -p Canonical`
