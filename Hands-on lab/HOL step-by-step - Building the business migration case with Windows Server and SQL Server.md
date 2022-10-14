![](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/main/Media/ms-cloud-workshop.png "Microsoft Cloud Workshops")

<div class="MCWHeader1">
Building the business migration case with Windows Server and SQL Server
</div>

<div class="MCWHeader2">
Hands-on lab step-by-step
</div>

<div class="MCWHeader3">
October 2022
</div>


Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.

© 2022 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at <https://www.microsoft.com/en-us/legal/intellectualproperty/Trademarks/Usage/General.aspx> are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents** 

<!-- TOC -->

- [Building the business migration case with Windows Server and SQL Server hands-on lab step-by-step](#building-the-business-migration-case-with-windows-server-and-sql-server-hands-on-lab-step-by-step)
  - [Abstract and learning objectives](#abstract-and-learning-objectives)
  - [Overview](#overview)
  - [Solution architecture](#solution-architecture)
  - [Requirements](#requirements)
  - [Before the hands-on lab](#before-the-hands-on-lab)
  - [Exercise 1: SQL database migration](#exercise-1-sql-database-migration)
    - [Task 1: Create subnet and storage account for Azure SQL MI](#task-1-create-subnet-and-storage-account-for-azure-sql-mi)
    - [Task 2: Create Azure SQL MI](#task-2-create-azure-sql-mi)
    - [Task 3: Install Data Migration Assistant](#task-3-install-data-migration-assistant)
    - [Task 4: Assess on-premises database compatibility](#task-4-assess-on-premises-database-compatibility)
    - [Task 5: Backup on-premises SQL database](#task-5-backup-on-premises-sql-database)
    - [Task 6: Migrate database to Azure SQL MI](#task-6-migrate-database-to-azure-sql-mi)
  - [Exercise 2: Create VM to migrate web application](#exercise-2-create-vm-to-migrate-web-application)
    - [Task 1: Create Windows Server 2022 Azure Edition VM for application hosting](#task-1-create-windows-server-2022-azure-edition-vm-for-application-hosting)
    - [Task 2: Check remote desktop access](#task-2-check-remote-desktop-access)
  - [Exercise 3: Azure Arc-enable on-premises VM](#exercise-3-azure-arc-enable-on-premises-vm)
    - [Task 1: Generate Azure Arc script to add server](#task-1-generate-azure-arc-script-to-add-server)
    - [Task 2: Run script to add server to Azure Arc](#task-2-run-script-to-add-server-to-azure-arc)
    - [Task 3: Verify Azure Arc-enabled VM](#task-3-verify-azure-arc-enabled-vm)
  - [After the hands-on lab](#after-the-hands-on-lab)
    - [Task 1: Delete resource group to remove the lab environment](#task-1-delete-resource-group-to-remove-the-lab-environment)

<!-- /TOC -->

# Building the business migration case with Windows Server and SQL Server hands-on lab step-by-step

## Abstract and learning objectives

In this hands-on lab, you will perform steps to migrate Windows Server and SQL Server workloads to Azure. You will go through provisioning a Windows Server VM, migrating a SQL Server database to Azure SQL Managed Instance (SQL MI), and Azure Arc-enable an on-premises Windows Server VM.

## Overview

In this lab, attendees will perform steps toward migrating Tailspin Toy's on-premises Windows Server and SQL Server workloads to Azure. Tailspin needs a new Windows Server VM created in Azure for hosting their Web application, an on-premises SQL Server database migrated to Azure SQL Managed Instance, and an on-premises Windows Server VM to be Azure Arc-enabled.

Tailspin already has a Hub and Spoke network setup in Azure with Azure Bastion for enabling remote management of Azure VM using Azure Bastion. The Azure resources provisioned throughout this lab will be deployed into this environment.

At the end of this hands-on lab, you will be better able to set up a Windows Server for application migration to Azure, migrate an on-premises SQL Database to Azure SQL Managed Instance, and Azure Arc-enable an on-premises virtual machine so it can be managed from Azure.

## Solution architecture

![Diagram showing on-premises network connected to Azure using Azure ExpressRoute with a Hub and Spoke network in Azure. The Spoke VNet contains the migrated Front-end, Back-end, and SQL Database workloads running within Subnets inside the Spoke VNet in Azure.](images/PreferredSolutionDiagram.png "Preferred Solution Diagram")

The diagram shows an on-premise network connected to Azure using Azure ExpressRoute with a Hub and Spoke network in Azure. The Spoke VNet contains the migrated Front-end, Back-end, and SQL Database workloads running within Subnets inside the Spoke VNet in Azure.

## Requirements

- You must have a working Azure subscription to carry out this hands-on lab step-by-step without a spending cap to deploy the Barracuda firewall from the Azure Marketplace.

## Before the hands-on lab

Refer to the Before the hands-on lab setup guide manual before continuing to the lab exercises.

## Exercise 1: SQL database migration

Duration: 90 minutes

Tailspin Toys needs to migrate their on-premises SQL Server database to Azure SQL Managed Instance. This is part of the migration strategy defined to migrate Tailspin Toys workloads to Azure.

In this exercise, you will go through the steps necessary to migrate Tailspin Toys' on-premises SQL Server database to Azure SQL Managed Instance.

### Task 1: Create subnet and storage account for Azure SQL MI

1. Sign in to the [Azure Portal](https://portal.azure.com). Ensure that you're using a subscription associated with the same resources you created during the Before the hands-on lab setup.

2. Within the Azure Portal, navigate to the Resource Group created for this lab, and go to the `tailspin-spoke-vnet` virtual network.

3. Under **Settings**, select the **Subnets** link.

    ![The tailspin-spoke-vnet Virtual network pane is shown with the Subnets link under Settings highlighted.](images/azure-sql-mi-spoke-vnet-subnets-link.png "Virtual network pane with subnets links highlighted")

4. Select **+Subnet** to create a new Subnet.

5. On the **Add subnet** pane, enter the following values to create a Subnet that will be used by the Azure SQL Managed Instance that will be created later:

    Add subnet pane   - **Name**: `AzureSQLMI` 
        - **Subnet address range**: `10.2.1.0/24`
        - **Delegate subnet to a service**: `Microsoft.Sql/managedInstances`

    ![Add subnet pane is shown with fields entered with desired values for the subnet to add.](images/azure-sql-mi-new-subnet.png "Add subnet pane with values entered")

6. Select **Save**. The list of Subnets will now look like the following:

    ![The Subnets page of the tailspin-spoke-vnet Virtual network pane now shows the list of subnets that have been created.](images/azure-sql-mi-subnets-list.png "List of subnets in the Virtual network")

7. Go to the **Home** screen in the **Azure Portal**, then select **+ Create a resource**.

8. Under **Categories**, select **Storage**, then select **Create** for **Storage account** in the list of popular resources.

    ![The Azure Marketplace is shown with the Create link highlighted for the Storage account resource.](images/2022-10-07-20-33-19.png "Create a Storage account resource")

9. On the **Create a storage account**, enter the following values, then select **Review**:

    - **Resource group**: Select the resource group that you created for this lab, such as `tailspin-rg`.
    - **Storage account name**: Enter a unique name for the storage account, similar to `tailspinsqlmistorage`. You can add your initials or date to meet uniqueness requirements.
    - **Region**: Select the Azure Region that was used to create the resource group.

    ![The Create a storage account pane is shown with the fields highlighted and all values entered.](images/azure-portal-create-storage-account-sqlmi.png "Create a storage account pane with all values entered")

10. Select **Create** to create the Storage Account.

11. Once the Storage Account is created, navigate to it, then select **Containers**.
On the Add subnet pane, enter the following values to create a Subnet
    ![The Storage account pane is shown for the newly creates Storage account with the Containers link highlighted under Data storage.](images/azure-portal-storage-account-containers-link.png "Storage Account with Containers link highlighted")

12. Select **+ Container**

13. On the **New container** pane, enter `sql-backup` in the **Name** field, then select **Create**.

    ![The New container dialog is shown with the Name entered with the Name field and Create button highlighted.](images/storage-container-sql-backup-new.png "New container")

### Task 2: Create Azure SQL MI

1. On the **Home** page within the Azure Portal, towards the top, select **Create a resource**.

    ![The Home page of the Azure Portal is shown with the 'Create a resource' link highlighted.](images/azure-portal-home-create-resource-link.png "Create a resource on Azure Portal Home page")

2. Within the **Search services and marketplace** field, type **Azure SQL Managed Instance**, press Enter, and select it in the search results.

    ![The Azure Marketplace search results for Azure SQL Managed Instance are shown with Azure SQL Managed Instance highlighted.](images/2022-10-07-20-35-13.png "Azure SQL MI in Azure Marketplace")

3. Select **Create**.

4. On the **Create Azure SQL Managed Instance** pane, set the following values:

    - **Resource group**: Select the resource group that you created for this lab. Such as `tailspin-rg`.
    - **Managed Instance name**: Enter a unique name, such as `tailspin-sqlmi`.
    - **Region**: Select the Azure Region that was used to create the resource group.

    ![The Create Azure SQL Managed Instance pane is shown with fields highlighted and all values entered.](images/2022-10-07-20-38-02.png "Create Azure SQL Managed Instance pane")

5. For **Compute + storage**, select **Configure Managed Instance**.

    ![The Compute + storage section of the Create Azure SQL Managed Instance pane is shown with the Configure Managed Instance link highlighted.](images/create-azure-sql-mi-compute-storage-configure-link.png "Compute + storage section with Configure Managed Instance link highlighted")

6. For the **Compute + storage** configured select the following values:

    - **Service tier**: General Purpose
    - **Hardware generation**: Standard-series
    - **vCores**: 8 vCores
    - **Storage in GB**: 64 GB

    ![The Compute + storage pane is shown with necessary values selected and highlighted.](images/create-azure-sql-mi-compute-storage-values-entered.png "Compute + storage pane with values entered")

7. Select **Apply**.

8. Under **Authentication**, set the **Authentication Method** value to **Use both SQL and Azure AD authentication**.

9. Under **Azure AD admin**, select **Set admin** and choose an Azure AD user for the Azure AD admin. You should choose your own User account.

    > **Note**: To choose the Azure AD admin, an organization account must be selected. A personal Microsoft Account cannot be used for this.

10. Enter a username to use for the **Managed Instance admin login** and a **Password** for this new Administrator user that will be created on the database server.

    > **Note**: Using the `demouser` username that was used previously in the lab will make it easier to remember. However, this does require a password length of 16 characters, so here's an example password that is similar to the previous one used in the lab: `demo!pass1234567`.

    ![The Authentication section is shown with the Managed Instance admin login and Password fields entered and highlighted.](images/create-azure-sql-mi-authentication-values-entered.png "Authentication values are entered")

11. Select **Next: Networking**.

12. On the **Networking** pane, enter the following values:

    - **Virtual network / subnet**: `tailspin-spoke-vnet/AzureSQLMI`.

    ![The Networking tab of the Create Azure SQL Managed Instance pane is shown with the tailspin-spoke-vnet/AzureSQLMI subnet selected with the field highlighted.](images/create-azure-sql-mi-networking-values-entered.png "Networking values entered")

13. Select **Review + create**.

14. Select **Create**.

    > **Note**: Deploying the new instance of Azure SQL Managed Instance may take about 1 hour to complete. You can continue to Exercise 2, then come back here later to finish Exercise 1.

### Task 3: Install Data Migration Assistant

1. In the Azure Portal, navigate to the Resource Group for the lab, then navigate to the `tailspin-onprem-sql-vm` virtual machine. This is the simulated on-premises SQL Server VM that contains the database to migrate to Azure SQL MI.

    ![The Virtual machine pane for the Simulated on-premises SQL Server VM is shown in the Azure Portal.](images/azure-portal-onprem-sql-vm.png "Simulated on-premises SQL Server VM")

2. On the left, select **Bastion** under **Operations**.

    ![The Bastion link under Operations is shown.](images/azure-portal-vm-operations-bastion-link.png "Bastion link is highlighted")

3. Enter the **Username** and **Password**, then select **Connect**.

    ![The Bastion pane of the tailspin-onprem-sql-vm Virtual machine is shown with the Username and Password fields entered and highlighted.](images/azure-portal-sql-vm-bastion-username-password-entered.png "Bastion credentials shown entered")

    > **Note**: When the VM was created the credentials were set up as:
    > - **Username**: `demouser`
    > - **Password**: `demo!pass123`

4. In the **tailspin-onprem-sql-vm** virtual machine, go to **Server Manager**, and select **Local Server**.

    ![The Server Manager window is shown with Local Server selected.](images/server-manager-local-server-highlighted.png "Server Manager with Local Server highlighted")

5. Within **Local Server**, select the `On` text link for the **IE Enhanced Security Configuration** property.

    ![The Local Server pane is shown within Server Manager and the value of On is highlighted for IE Enhanced Security Configuration.](images/server-manager-local-server-ie-enhanced-security-config.png "Server Manager with IE Enhanced Security Configuration highlighted")

6. On the **Internet Explorer Enhanced Security Configuration** dialog, select **Off** for **Administrators**, then select **OK**.

    ![The Internet Explorer Enhanced Security Configuration window is shown with the Administrators section having the Off value selected and highlighted.](images/server-manager-ie-enhanced-security-config-administrators-off-property.png "IE Enhanced Security Configuration dialog with Administrators Off property highlighted")

7. In the **tailspin-onprem-sql-vm** virtual machine, open **Internet Explorer** then go to the following link and download the **.NET Framework 4.8 Runtime** installer. This will be needed to install the Microsoft Data Migration Assistant.

    <https://dotnet.microsoft.com/en-us/download/dotnet-framework/thank-you/net48-web-installer>

8. Select **Run** to run the **.NET Framework 4.8 Runtime** installer once it's finished downloading, and follow the prompts to install the .NET Framework.

    ![The .NET Framework 4.8 Setup wizard is shown.](images/2022-10-07-21-14-05.png ".NET Framework 4.8 Setup")

9. Using **Internet Explorer**, go to the following link and download the **Microsoft Data Migration Assistant**.

    - <https://www.microsoft.com/en-us/download/details.aspx?id=53595>

10. Select **Run** to run the **Microsoft Data Migration Assistant** installer once it's finished downloading and follow the prompts to install the assistant.

    ![The Microsoft Data Migration Assistant Setup wizard is shown.](images/microsoft-data-migration-assistant-setup-wizard.png "Microsoft Data Migration Assistant Setup wizard")

### Task 4: Assess on-premises database compatibility

1. Run the **Microsoft Data Migration Assistant** that was previously installed.

    ![The Data Migration Assistant application is shown.](images/ms-data-migration-assistant-windows.png "Data Migration Assistant")

2. On the left, select the Plus sign (`+`) button to create a new project, and enter the following values, then select **Create**.

    - **Project type**: Assessment
    - **Project name**: Tailspin
    - **Assessment type**: Database Engine
    - **Source server type**: SQL Server
    - **Target server type**: Azure SQL Database Managed Instance

    ![The New project dialog is shown with the required values entered in the fields.](images/ms-data-migration-assistant-new-project.png "Data Migration Assistant New project dialog with values entered")

3. On the **Options** tab, ensure the **Check database compatibility** and **Check feature parity** report types are selected, then select **Next**.

    ![The Options step is shown with Check database compatibility and Check feature parity options selected.](images/2022-10-07-21-17-11.png "Data Migration Assistant Options pane")

4. On the **Connect to a server** prompt, enter `localhost` for the     **Server name**, and check the **Trust server certificate** option, then select **Connect**.

    ![The Connect to a server dialog box is shown with the values entered to connect to localhost and to trust the server certificate.](images/ms-data-migration-assistant-assessment-connect-to-server-localhost.png "Connect to a server configured for localhost")

5. On the **Add sources** prompt, select the **WideWorldImporters** database, then select **Add**.

    ![The Add sources dialog box is shown with the WideWorldImporters database selected.](images/2022-10-07-21-18-32.png "Add sources with WideWorldImporters database selected")

6. Select **Start Assessment** in the lower right.

    ![The Select sources step is shown with the WideWorldImporters database shown as previously selected and the Start Assessment button is highlighted.](images/ms-data-migration-assistant-assessment-start-assessment-button.png "Data Migration Assistant with the Start Assessment button highlighted")

7. On the **Review results** pane, you should see a message that states "**There are no feature parity issues with your server instance.**"

    ![The Review results step is shown with the 'There are no feature parity issues with your server instance' message shown.](images/ms-data-migration-assistant-assessment-no-feature-parity-issues.png "Data Migration Assistant showing there are no feature parity issues")

8. On the top left of the **Review results** pane, select **Compatibility issues**.

    ![The Compatibility issues option is selected on the Review results pane.](images/ms-data-migration-assistant-assessment-no-compatibility-issues-selected.png "Compatibility issues selected")

9. On the **Review results** pane, you should see a message that "**There are no compatibility issues with your database**".

    ![The Review results pane is shown with Compatibility issues selected and showing the 'There are no compatibility issues with your database' message shown.](images/ms-data-migration-assistant-assessment-no-compatibility-issues.png "Data Migration Assistant showing there are no compatibility issues")

10. The Data Migration Assessment is complete. If there were feature parity or compatibility issues found, then you would need to address those before migrating the SQL Server database to Azure SQL MI.

### Task 5: Backup on-premises SQL database

1. In the **tailspin-onprem-sql-vm** virtual machine, open the **Start menu**, then type **Azure Data Studio** to search the application, then select it to run **Azure Data Studio**.

    ![The Search results in the Start menu show a search for Azure Data Studio.](images/win-start-menu-search-azure-data-studio.png "Azure Data Studio in Start menu search")

2. On the left, select the **Extensions** tab, then select the **Azure SQL Migration** extension and install it.

    ![Azure Data Studio is shown displaying the Extensions pane with the Azure SQL Migration extension selected and the Install button is highlighted.](images/azure-data-studio-extensions-azure-sql-migration.png "Azure SQL Migration extension highlighted")

3. Next, you need to enable Preview Features within Azure Data Studio. Select the **Manage** icon (shown as the Gear in the lower left corner of Azure Data Studio) and select **Settings**.

    ![The Manage menu is shown with the Settings option highlighted.](images/azure-data-studio-manage-menu-settings.png "The manage menu open with Settings highlighted")

4. On the **Settings** pane, type **Enable Preview Features** in the search box at the top, then check the **Enable unreleased preview features** box for the **Workbench: Enable Preview Features** option that shows in the search results. This will autosave.

    ![The Settings pane is shown with search results for Enable Preview Features showing the Enable unreleased preview features option selected.](images/azure-data-studio-preview-features-enabled.png "Azure Data Studio settings pane with Preview Features enabled")

5. Next, let's connect to the on-premises SQL Server. Select the **Connections** tab on the left side of Azure Data Studio, then select **New Connection**.

    ![The Connections pane is shown with the New Connection button highlighted.](images/azure-data-studio-connections-tab-new-connection-button.png "Azure Data Studio connections tab with New Connection button shown")

6. On the **Connection** pane, enter the following values to connect to the on-premises SQL database, then select **Connect**:

    - **Connection type**: Microsoft SQL Server
    - **Server**: `localhost`
    - **Authentication type**: Windows Authentication
    - **Database**: `WideWorldImporters`

    ![The Connection Details pane is shown with values entered and fields highlighted.](images/azure-data-studio-connection-pane-values-entered.png "Azure Data Studio with Connection pane shown having all values entered")

7. In the list of servers, right-click the **localhost, WideWorldImporters** server, then select **Manage**.

    ![The right-click menu for the 'localhost, WideWorldImporters' server is shown with the Manage option highlighted.](images/azure-data-studio-servers-right-click-manage-shown.png "WideWorldImporters server with right-click menu shown and Manage option highlighted")

8. Select **Backup**.

    ![The Manage page for the database is shown with the Backup button highlighted.](images/azure-data-studio-database-manage-backup-button.png "Manage database with Backup button highlighted")

9. On the **Backup database** pane, make sure the **Backup type** is set to **Full**, select the **Reliability** option to **Perform checksum before writing to media**, then make a note of the location of the **Backup files**, and select **Backup**.

    ![The Backup database dialog box is shown with the Backup type set to Full and the Reliability set as desired.](images/azure-data-studio-backup-full.png "Backup database pane")

10. Open **Internet Explorer**, navigate to the following URL, download **Microsoft Azure Storage Explorer**, and install it.

    <https://azure.microsoft.com/en-us/products/storage/storage-explorer/#overview>

    ![The Microsoft Azure Storage Explorer Setup wizard is shown.](images/2022-10-07-21-22-14.png "Microsoft Azure Storage Explorer Setup")

11. Launch **Microsoft Azure Storage Explorer**.

12. Select **Sign in with Azure**.

    ![The Azure Storage Explorer window is shown with the Sign in with Azure button highlighted.](images/azure-storage-explorer-with-sign-in-azure-highlighted.png "Azure Storage Explorer Sign in with Azure")

13. Sign in with your **Microsoft Account**.

14. In the **Explorer** pane, expand the Azure Subscription, locate the Storage Account that was previously created (named similar to `tailspinsqlmistorage`), then expand **Blob Container** and select the **sql-backup** container.

    ![Storage Explorer is displaying the Storage Accounts list with the previously created storage account and the nested Blob Containers tree expanded with the sql-backup container selected.](images/azure-storage-explorer-tailspinsqlmistorage-container-expanded.png "Storage Explorer showing the SQL MI backup storage account expanded")

15. In the **sql-backup** container pane, select **Upload**, then select **Upload Files...**.

    ![The Upload button menu is shown with the Upload files option highlighted.](images/azure-storage-explorer-tailspinsqlmistorage-upload-button.png "Storage Explorer with Upload button highlighted and menu for Upload files showing")

16. In the **Upload Files** dialog, in the **Selected files** field, select the **Database Backup File** (`.bak`) for the **WideWorldImporters** database that was previously created, then select **Upload**.

    ![The Upload Files dialog box is shown with the sql database backup file selected within the Selected filed field.](images/azure-storage-explorer-upload-files.png "Storage Explorer Upload File dialog with database backup file selected")

### Task 6: Migrate database to Azure SQL MI

1. Within **Azure Data Studio**, under the list of servers, right-click the **localhost, WideWorldImporters** server, then select **Manage**.

    ![localhost server is highlighted with right-click menu shown with the Manage option highlighted.](images/azure-data-studio-servers-right-click-manage-shown.png "WideWorldImporters server with right-click menu shown and Manage option is highlighted")

2. Select the **Azure SQL Migration** option.

    ![The Manage server pane is shown with the Azure SQL Migration option highlighted.](images/azure-data-studio-manage-server-pane.png "Manage server pane with Azure SQL Migration option highlighted")

3. Select the **Migrate to Azure SQL** button.

    ![The Azure SQL Migration pane is shown with the Migrate to Azure SQL button highlighted.](images/azure-data-studio-azure-sql-migration-migrate-button.png "Azure SQL Migration with Migrate to Azure SQL button highlighted")

4. In **Step 1: Database for assessment**, select the **WideWorldImporters** database, then select **Next**.

    ![Step 1 Database for assessment step is shown with the WideWorldImporters database selected for assessment.](images/azure-data-studio-migrate-step-1.png "Step 1: Databases for assessment")

5. In **Step 2: Assessment results and recommendations**, select the **Azure SQL Managed Instance** option.

    ![Step 2 Assessment results and recommendations are shown with the Azure SQL target option of Azure SQL Managed Instance selected.](images/azure-data-studio-migrate-step-2-azuresqlmi-selected.png "Step 2: Assessment results and recommendations")

6. Scroll down and select the **View/Select** button to select a database.

    ![The View/Select button to choose the Azure SQL Managed Instance to migrate to is highlighted.](images/2022-10-13-14-36-48.png "View/Select Azure SQL Managed Instance button")

7. Select the **WideWorldImporters** database, and you should see a message stating "`No issues for migrating to Azure SQL Managed Instance.`", then select the **Select** button.

    ![WideWorldImporters database selected and 'no issues' message shown.](images/2022-09-23-15-01-58.png "No issues found message is shown")

8. Verify the **Azure SQL Managed Instance** target is selected, notice that it now shows **1 of 1 databases selected**, then select **Next**.

    ![Step 2 Assessment results and recommendations are shown with Azure SQL Managed Instance option selected.](images/azure-data-studio-migrate-step-2.png "Step 2: Assessment results and recommendations")

9. In **Step 3: Azure SQL target**, enter connection information to your Azure Subscription and for the **Azure SQL Manage Instance** resource that was previously created, then select **Next**.

    ![Step 3 Azure SQL target is shown with the Azure account entered and the Location, Resource group, and Azure SQL Managed Instance resource selected as the target for the migration.](images/azure-data-studio-migrate-step-3.png "Step 3: Azure SQL target")

10. On **Step 4: Migration mode**, keep **Online migration** selected, then select **Next**.

    ![Step 4 Migration mode is shown with the Online migration option selected.](images/azure-data-studio-migrate-step-4.png "Step 4: Migration mode")

11. In **Step 5: Database backup**, select **My database backups are in an Azure Storage Blob Container**, select the Azure Storage Account and container created previously, then select **Next**.

    ![Step 5 Database backup is shown with the 'My database backups are in an Azure Storage Blob Container' option selected, with the Storage account and sql-backup container selected for the location of the source database.](images/azure-data-studio-migrate-step-5.png "Step 5: Database backup")

12. In **Step 6: Azure Database Migration Service**, select **Create new** under **Azure Database Migration Service**.

    ![Step 6 Azure Database Migration Service is shown with the Create new link under Azure Database Migration Service highlighted.](images/2022-10-07-21-25-58.png "Step 6 Azure Database Migration Service")

13. In the **Create Azure Database Migration Service** pane, enter the following values, then select **Create**.

    - **Resource group**: Select the Resource Group for this lab, for example: `tailspin-rg`.
    - **Name**: `tailspin-sql-migration`

    ![The Create Database Migration Service dialog is shown with Resource Group and Name for the Azure Database Migration Service to create entered.](images/azure-data-studio-migrate-create-migration-service.png "Create Database Migration Service dialog")

14. Once the Database Migration Service has been created, select **Done**.

15. In **Step 6: Azure Database Migration Service**, select the **Azure Database Migration Service** that was created, then select **Next**.

    ![Step 6 Azure Database Migration Service is shown with the Azure Database Migration Service field now entered.](images/azure-data-studio-migrate-step-6.png "Step 6: Azure Database Migration Service")

16. In **Step 7: Summary**, review all the configurations chosen, then select **Start migration**.

    ![Step 7 Summary is shown with all the selected values displayed for review.](images/azure-data-studio-migrate-step-7.png "Step 7: Summary")

17. Azure Data Studio will now show **Database migrations in progress - 1**.

    ![The Azure SQL Migration pane in Azure Data Studio shows there is 1 data migration in progress.](images/azure-data-studio-database-migrations-in-progress.png "Azure Data Studio showing there is 1 data migration in progress")

18. In the Azure Portal, navigate to the **Azure Database Migration Service** that was created (named similar to `tailspin-sql-migration`), then select **Migrations** and the **WideWorldImporters** migration.

    ![The Azure Database Migration Service is shown within the Azure Portal displaying the new database migration in the list of Migrations.](images/azure-database-migration-service-inprogress.png "Azure Database Migration Service list of migrations.")

19. The **WideWorldImporters** migration shows the current status of the migration as `InProgress`. Notice the **Currently restoring files** should say **All backups restored** once the database backup has been restored. Then select **Complete cutover** at the top.

    ![The WideWorldImporters migration is shown within the Azure Portal having a migration status of InProgress](images/wideworldimporters-migration-inprogress.png "WideWorldImporters migration showing status as InProgress")

20. In the **Complete cutover** prompt, select the box for **I confirm there are no additional log backups...**, then select **Complete cutover**.

    ![The Complete cutover prompt is shown with the confirmation box checked and the Complete cutover button highlighted.](images/wideworldimporters-migration-complete-cutover.png "Complete cutover")

21. The **WideWorldImporters** Migration will now show the status of **Completing**. This will take a few minutes to complete.

    ![The WideWorldImporters migration is shown in the Azure Portal having a migration status of Completing.](images/wideworldimporters-migration-completing.png "WideWorldImporters migration showing status of Completing")

22. Once the cutover has been completed, the **WideWorldImporters** migration will show a status of **Succeeded**.

    ![The WideWorldImporters migration is shown in the Azure Portal with a migration status of succeeded.](images/wideworldimporters-migration-succeeded.png "WideWorldImporters migration showing status of succeeded")

23. Within the Azure Portal, navigate to the **Azure SQL Managed Instance** that was created previously.

24. When the SQL Server database migration to Azure SQL MI has completed, you will see the **WideWorldImporters** database shown with an **Online** status.

    ![The Azure SQL Managed Instance resource is shown in the Azure Portal with the WideWorldImporters migration showing a Status of Online.](images/azure-portal-sql-mi-database-status-online.png "Azure SQL MI in Azure Portal showing the WideWorldImporters database in Online status")

## Exercise 2: Create VM to migrate web application

Duration: 30 minutes

In this exercise, you will create a new Windows Server 2022: Azure Edition virtual machine (VM) that will be the destination for migrating the on-premises Web Application to Azure, and then you will use Azure Bastion to connect to the VM over Remote Desktop (RDP). Azure Bastion will allow secure remote connections to the VM for Administrators. Windows Server Azure Edition is a specific image of Windows Server with unique capabilities such as rebootless patching with Hotpatch, available only on Azure.

### Task 1: Create Windows Server 2022 Azure Edition VM for application hosting

In this task, you will create a new Windows Server 2022: Azure Edition virtual machine (VM) that will be the destination for migrating the on-premises Web Application to Azure.

1. Sign in to the [Azure Portal](https://portal.azure.com). Ensure that you're using a subscription associated with the same resources you created during the Before the hands-on lab set up.

2. On the **Home** page within the Azure Portal, towards the top, select **Create a resource**.

    ![The Home page of the Azure Portal is shown with the 'Create a resource' link highlighted.](images/azure-portal-home-create-resource-link.png "Create a resource on Azure Portal Home page")

3. Within the **Search services and marketplace** field, type **Windows Server** and press Enter to search the marketplace, then select **Windows Server**.

    ![Windows Server is highlighted within the Azure Marketplace search results.](images/azure-marketplace-windows-server.png "Windows Server is highlighted")

4. Choose **Windows Server 2022 Datacenter: Azure Edition**, then select **Create**.

5. On the **Create a virtual machine** pane, set the following values to configure the new virtual machine:

    - **Resource group**: Select the resource group that you created for this lab. Such as `tailspin-rg`.
    - **Virtual machine name**: Give the VM a unique name, such as `tailspin-webapp-vm`.
    - **Region**: Select the Azure Region that was used to create the resource group.
    - **Image**: Verify the image is set to **Windows Server 2022 Datacenter: Azure Edition - Gen 2**.

    ![The Create a virtual machine pane is shown with values entered and filed highlighted.](images/create-virtual-machine-windows-server-image-set.png "Create a virtual machine with field set")

6. Set the **Size** field by selecting the **Standard_D4s_v5** virtual machine size.

    ![The Virtual Machine Size field is shown with the desired size selected.](images/create-virtual-machine-size-set.png "VM size is set")

7. Set a **Username** and **Password** for the **Administrator account** for the VM.

    > **Note**: Be sure to save the Username and Password for the VM, so it can be used later. A recommendation for easy to remember Username is `demouser` and Password is `demo!pass123`.

8. Select **Next** until you are navigated to the **Networking** tab of the **Create a virtual machine** page.

    ![The Networking tab of the Create a virtual machine pane is selected.](images/create-virtual-machine-networking-tab-selected.png "Networking tab is selected")

9. Provision the VM in the Spoke VNet in Azure by selecting the following values under the **Network interface** section:

    - **Virtual network**: Select the Spoke VNet that was created for this lab. Its name will be similar to `tailspin-spoke-vnet`.
    - **Subnet**: `default`
    - **Public IP**: `None`

    ![The Networking tab has the Network interface values selected for the Virtual network, Subnet, and Public IP to connect to the VM.](images/create-virtual-machine-networking-values-set.png "Virtual Network, Subnet, and Public IP values are set")

10. Set the following values to ensure that HTTPS traffic will be allowed to connect to the VM:

    - **Public inbound ports**: `Allow selected ports`
    - **Select inbound ports**: `HTTPS (443)`

    ![The Public inbound ports field is set to Allow selected ports and the Select inbound ports has HTTPS 443 selected.](images/create-virtual-network-https-traffic-allowed.png "Networking inbound ports set to allow HTTPS traffic")

11. Select **Review + create** to review the virtual machine settings.

    ![The Review + create button for the Create a virtual machine pane is shown and highlighted.](images/create-virtual-network-review-create-button.png "Review + create button")

12. Select **Create** to begin provisioning the virtual machine once the **Validation passed** message is shown.

    ![The Validation passed message is shown and the Create button is highlighted.](images/create-virtual-machine-create-button.png "Validation passed and Create button")

### Task 2: Check remote desktop access

In this task, you will test Remote Desktop (RDP) connectivity to the newly created virtual machine using Azure Bastion.

1. In the Azure Portal, navigate to the newly created **Virtual Machine**.

    ![The Virtual machine pane is shown in the Azure Portal for the newly created VM.](images/web-app-win2022server-virtual-machine-pane.png "Virtual machine pane is open")

2. On the left, under the **Operations** section, select **Bastion**.

    ![The Bastion link under Operations is shown and highlighted.](images/portal-virtual-machine-operations-bastion-link.png "Bastion link")

3. On the **Bastion** pane, enter the **Username** and **Password** that was set for the Administrator User of the VM when it was created, then select **Connect**.

    ![The Bastion pane for the VM is shown with the username and password fields entered.](images/portal-virtual-machine-operations-bastion-pane.png "Bastion pane with username and password entered")

    > **Note**: The Azure Bastion instance named `tailspin-hub-bastion` was previously created with the Before the Hands-on lab setup. This is a required resource for using Azure Bastion to securely connect to Azure VMs using RDP from within the Azure Portal.

4. A new browser tab will open with Azure Bastion connected to the virtual machine over RDP. To close this session, you can close this browser tab.

    ![A browser window is shown open with Bastion connected to a remote desktop session to the VM.](images/browser-azure-bastion-connected-web-app-win2022server.png "Browser window open with Azure Bastion connected to the VM")

> **Note**: Now that the Windows Server 2022 VM has been created in Azure, Tailspin Toys will now be able to modify their Continuous Integration and Continuous Deployment (CD/CD) pipelines within Azure DevOps to begin deploying the Web Application code to this virtual machine as they get ready for migrating the application to Azure.

## Exercise 3: Azure Arc-enable on-premises VM

Duration: 45 minutes

In this exercise, you will Azure Arc-enable a Windows Server VM that Tailspin has on-premises. This VM is being Arc-enabled since there are no plans to migrate it to Azure, but Tailspin would like to simplify the management of all their VMs in a single place. Azure Arc provides the functionality to manage Azure and on-premises VMs in a single place giving Tailspin Toys exactly what they are looking for to simplify VM management and administration.

### Task 1: Generate Azure Arc script to add server

1. Sign in to the [Azure Portal](https://portal.azure.com). Ensure that you're using a subscription associated with the same resources you created during the Before the hands-on lab set up.

2. In the **Search resources, services, and docs** box at the top of the portal, search for **Azure Arc**, then select the **Azure Arc** service.

    ![An Azure Portal search is shown showing the results for a search for Azure Arc with the Azure Arc service in the results highlighted.](images/azure-portal-search-azure-arc-service.png "Azure Portal search for Azure Arc with 'Azure Arc' option highlighted")

3. On the **Azure Arc** pane, select the **Infrastructure** tab, then select the **Add** button under **Servers**.

    ![The Azure Arc pane in the Azure Portal is shown navigated to the Infrastructure pane and the Servers Add button is highlighted.](images/azure-arc-pane-infrastructure-servers-add-button.png "Azure Arc pane showing Infrastructure tab")

4. Under **Add a single server** select **Generate script**.

    ![The Add servers with Azure Arc pane is shown with the Generate Script button highlighted for the Add a single server option.](images/2022-10-07-21-36-05.png "Add servers with Azure Arc with Generate script")

5. On the **Add a server with Azure Arc** pane, read the requirements of Azure Arc that are listed, then select **Next**.

    ![The prerequisites tab is shown for the Add a server with Azure Arc pane with the requirements listed.](images/2022-10-07-21-37-35.png "Add a server with Azure Arc requirements")

6. On the **Resource details** tab, enter the following values, then select **Next**.

    - **Resource group**: Select the Resource Group created for this lab. For example: `tailspin-rg`.
    - **Region**: Select the closest region to the geographic location of the server being added to Azure Arc. In this case, use the same Region used for the Resource Group created for the lab.
    - **Operating system**: `Windows`
    - **Connectivity method**: `Public endpoint`

    ![The Resource details tab of the Add a server with Azure Arc pane is displayed with values entered.](images/2022-09-22-21-13-42.png "Resource details tab with values entered")

7. On the **Tags** tab, enter the following tag values to identify this server, then select **Next**:

    - **Datacenter**: `headquarters`
    - **City**: `Milwaukee`
    - **StateOrDistrict**: `WI`
    - **CountryOrRegion**: `USA`

    ![The Tags tab of the Add a server with Azure Arc pane is shown with the tag values entered.](images/azure-arc-add-server-tags-tab.png "Tags tab with all tag values entered")

8. On the **Download and run script** tab, select **Download** to download the generated script. By default, the script named `OnboardingScript.ps1` will be saved to the `Downloads` folder.

    ![The Download button is highlighted on the Download and run script tab.](images/azure-arc-download-script.png "Download and run script")

### Task 2: Run script to add server to Azure Arc

1. In the Azure Portal, navigate to the Resource Group for the lab, then select the **`tailspin-onprem-hyperv-vm`** virtual machine resource. This is the simulated on-premises Hyper-V host VM.

    ![The resource group for the lab is shown with the simulated on-premises Hyper-V Host VM highlighted in the resource list.](images/azure-portal-lab-rg-hyperv-vm.png "Resource group with simulated on-premises Hyper-V Host VM highlighted")

2. On the left, select **Bastion** under **Operations**.

    ![The virtual machine pane for the simulated on-premises hyper-v host VM is shown with the Bastion link under Operations highlighted.](images/azure-portal-hyper-v-host-vm-bastion-link.png "Bastion link under Operations")

3. Enter the **Username** and **Password**, then select **Connect**.

    ![The Bastion pane is shown for the VM with the Username and Password values entered and fields highlighted.](images/azure-portal-vm-bastion-username-password-entered.png "Bastion credentials shown entered")

    > **Note**: When the VM was created the credentials were set up as:
    - **Username**: `demouser`
    - **Password**: `demo!pass123`

4. Once connected to the Hyper-V Host VM, open the **Start menu**, then search for and run the **Hyper-V Manager**.

5. Within the **Hyper-V Manager**, double-click the **OnPremVM** VM to connect to it.

    ![The Hyper-V Manager is shown with the list of virtual machines displayed with the OnPremVM highlighted.](images/hyper-v-manager-vm-list.png "Hyper-V Manager list of VMs with OnPremVM shown")

6. Once connected to the **OnPremVM** VM within Hyper-V, sign in using the **Administrator** account and the password of `demo!pass123`.

    > **Note**: If you encounter that the **OnPremVM** has **No Internet Connection**, go back into the `tailspin-onprem-hyperv-vm` Hyper-V Host VM and perform the following steps:
    > - Open the **Network Connections**
    > - Locate the **Ethernet** connection and right-click it.
    > - Select **Properties**
    > - Select the **Sharing** tab
    > - Disable and re-enable **Internet Connection Sharing** on this connection.
    >
    > You may see a warning message when disabling it and re-enabling it, but it will still work to restore Internet Connection Sharing with the **OnPremVM** that is connected through the Host VM's network connection.
    >
    > ![The Ethernet connection properties on the Hyper-V Host VM showing Internet Connection Sharing option highlighted.](images/windows-hyperv-network-connections-internet-connection-sharing.png "Ethernet Properties for Internet Connection Sharing")

7. Within the **OnPremVM**, open **Internet Explorer**, go to the following link to download the Windows Update for installing **PowerShell 5.1**, and run it. This will install PowerShell 5.1 on the Windows Server 2012 R2 VM, since this is the version of PowerShell required by the Azure Arc script.

    <https://go.microsoft.com/fwlink/?linkid=839516>

8. Within the **OnPremVM**, open **Internet Explorer**, go to the following link to download the .NET Framework 4.8, and install it. The Azure Arc script will install the **Azure Connected Machine Agent** which requires **.NET Framework 4.6 or later**.

    <https://go.microsoft.com/fwlink/?LinkId=2085155>

    > **Note**: The .NET Framework installer will display a **Blocking Issues** box with a note that another update needs to be installed.
    > The following 2 updates will need to be installed in the following order:
    > - Install KB2919442 from <https://www.microsoft.com/en-us/download/details.aspx?id=42153>
    > - Install KB2919355 from <https://www.microsoft.com/en-us/download/details.aspx?id=42334>
    >
    > Be sure to restart the VM after installing the updates, before you continue with the .NET Framework install.
    >
    > ![The blocking issue warning of the .NET Framework installer is shown with the message for the blocking issue highlighted.](images/dot-net-framwork-blocking-issue.png "Blocking issue warning with message highlighted")

9. Within the **OnPremVM**, open the **Windows PowerShell ISE**, and create a new script file.

10. Paste in the contents of the Azure Arc `OnboardingScript.ps1` script that was previously downloaded.

    > **Note**: Within the Hyper-V Virtual Machine Connection window, you may need to use the **Clipboard** -> **Type clipboard text** menu option to paste into the **OnPremVM**.

11. Run the full script. This will install the Azure Arc agent and Arc-enable the VM. When the script opens up a browser window, enter your credentials to authenticate with Azure.

    > **Note**: When the Azure Arc script opens a new browser window to authenticate you with Azure, be sure to use an Organization Account with permissions to create `Microsoft.HybridCompute/machines` resources. Using a Personal Account is not supported and will result in a `AZCM0042: Failed to Create Resource` error message.

12. When the script finishes executing successfully, a message stating "**Connected machine to Azure**" will be shown, along with the Azure Portal resource URL for the Azure Arc-enabled Server.

    ![The command line output of the Azure Arc script is shown that includes the Connected machine to Azure message showing the script executed successfully.](images/azure-arc-enabled-script-successful.png "Azure Arc script successful with Connected machine to Azure message")

### Task 3: Verify Azure Arc-enabled VM

1. In the Azure Portal, navigate to the Resource Group for the lab.

    ![The tailspin-rg Resource group for the lab is shown in the Azure Portal.](images/azure-portal-resource-group-tailspin-rg.png "tailspin-rg resource group")

2. Scroll down and locate the Azure resource of type **Server - Azure Arc**. and select it.

    ![The resources in the resource group are shown with the resource of type Server - Azure Arc highlighted.](images/resource-group-showing-server-azure-arc-resource.png "Azure Resource Group showing resource list with Server - Azure Arc resource")

    > **Note**: The on-premises VM has been Azure Arc-enabled and can be managed alongside other Azure resources. This is enabled by the **Azure Connected Machine Agent** running on the VM that facilitates the interaction between Azure and the Azure Arc-enabled VM.

3. This is the **Server - Azure Arc** pane for the on-premises virtual machine that was just Azure Arc-enabled. The **Status** shows **Connected** to signify that the Azure Arc-enabled virtual machine is connected to Azure. Also, notice that the **Computer Name** and **Operating System** of the virtual machine are displayed.

    ![The Server - Azure Arc pane in the Azure Portal is shown for the on-premises VM with status, computer name, and operating system values highlighted within the Essentials section.](images/azure-portal-server-azure-arc-enabled-vm.png "Azure Portal Server - Azure Arc pane for Azure Arc-enabled virtual machine")

4. From here, there are several **Azure Arc** capabilities available to use for managing the Azure Arc-enabled virtual machine.

    ![The Capabilities section of the Server- Azure Arc pane is shown with the list of capabilities to choose from.](images/azure-portal-server-azure-arc-capabilities.png "Azure Arc capabilities listed on the Server - Azure Arc pane")

5. Select **Extensions** under **Settings**. This is where you can install Extensions on the Azure Arc-enabled virtual machine. For example, the **Custom Script Extension for Windows - Azure Arc** extension can be used to download PowerShell scripts and files from Azure storage, and launch a PowerShell script on the machine.

    ![The Extensions pane for the Server - Azure Arc resource is shown with the Extensions link under Settings highlighted.](images/azure-poral-server-azure-arc-extensions.png "Azure Portal Server - Azure Arc pane showing Extensions")

## After the hands-on lab

Duration: 15 minutes

### Task 1: Delete resource group to remove the lab environment

1. Go to the **Azure Portal**.

2. Go to your **Resource groups**.

3. Select the **Resource group** you created.

    ![The Azure Portal is showing the list of resource groups in the Azure Subscription with the resource group for this lab highlighted.](images/azure-portal-resource-groups.png "Resource group list in Azure Portal")

4. Select **Delete Resource group**.

    ![The Resource group pane in the Azure Portal for the resource group for this lab is shown with the Delete resource group button highlighted.](images/azure-portal-resource-group-delete-button.png "Resource group pane with Delete button highlighted")

5. Enter the name of the **Resource group** and select **Delete**.

    ![The confirmation box for deleting the resource group is shown with the resource group name entered into the 'Type the resource group name' field to confirm the delete operation and the Delete button is highlighted.](images/azure-portal-resource-group-delete-confirm.png "Delete Resource group confirmation prompt")

You should follow all steps provided *after* attending the Hands-on lab.
