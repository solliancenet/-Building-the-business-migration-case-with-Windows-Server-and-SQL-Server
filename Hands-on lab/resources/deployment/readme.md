# Before Hands-on Lab Deployment

The Before HOL setup scripts for the Hands-on lab is contained within this folder. When authoring these scripts the infrastructure deployment is authored in Azure Bicep in the `deploy.bicep` file, and then it uses the `./bicep build` command to compile the Bicep code into an ARM Template with some help from the `build.sh` script.