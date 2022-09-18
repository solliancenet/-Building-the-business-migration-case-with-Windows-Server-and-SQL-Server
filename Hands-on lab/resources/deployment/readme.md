# Before Hands-on Lab Deployment

The Before HOL setup scripts for the Hands-on lab is contained within this folder. When authoring these scripts the infrastructure deployment is authored in Azure Bicep in the `deploy.bicep` file, and then it uses the `./bicep build` command to compile the Bicep code into an ARM Template with some help from the `build.sh` script.

[![Deploy To Azure](https://raw.githubusercontent.com/solliancenet/Building-the-business-migration-case-with-Windows-Server-and-SQL-Server/lab/Hands-on%20lab/images/deploytoazure.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSolliancenet%2FBuilding-the-business-migration-case-with-Windows-Server-and-SQL-Server%2Flab%2FHands-on %20lab%2Fresources%2Fdeployment%2Fdeploy.json)

