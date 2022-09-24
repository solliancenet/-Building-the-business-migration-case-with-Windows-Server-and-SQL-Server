![](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/main/Media/ms-cloud-workshop.png "Microsoft Cloud Workshops")

<div class="MCWHeader1">
Building the business migration case with Windows Server and SQL Server
</div>

<div class="MCWHeader2">
Hands-on lab step-by-step
</div>

<div class="MCWHeader3">
September 2022
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
    - [Before the hands-on lab](#exercise-1-before-the-hands-on-lab)
    - [Exercise 1: SQL Database Migration](#exercise-1-sql-database-migration)
        - [Task 1: Create Subnet and Storage Account for Azure SQL MI](#task-1-create-subnet-and-storage-account-for-azure-sql-mi)
        - [Task 2: Create Azure SQL MI](#task-1-create-azure-sql-mi)
        - [Task 3: Install Data Migration Assistant](#task-3-install-data-migration-assistant)
        - [Task 4: Assess On-premises database compatibility](#task-2-assess-on-premises-database-compatibility)
        - [Task 5: Backup on-premises SQL Database](task-5-backup-on-premises-sql-database)
        - [Task 6: Migrate Database to Azure SQL MI](#task-6-migrate-database-to-azure-sql-mi)
    - [Exercise 2: Create VM to Migrate Web Application](#exercise-2-create-vm-to-migrate-web-application)
        - [Task 1: Create Windows Server 2022 VM for Application Hosting](#task-1-create-windows-server-2022-vm-for-application-hosting)
        - [Task 2: Check Remote Desktop Access](#task-2-check-remote-desktop-access)
    - [Exercise 3: Azure Arc-enable On-premises VM](#exercise-3-azure-arc-enable-on-premises-vm)
        - [Task 1: Generate Azure Arc script to add server](#task-1-generate-azure-arc-script-to-add-server)
        - [Task 2: Run script to add server to Azure Arc]($task-2-run-script-to-add-server-to-azure-arc)
        - [Task 3: Verify Azure Arc-enabled VM](#task-3-verify-azure-arc-enabled-vm)
    - [After the hands-on lab](#after-the-hands-on-lab)
        - [Task 1: Delete Resource group to remove the lab environment](#task-1-delete-resource-group-to-remove-the-lab-environment)

<!-- /TOC -->

# Building the business migration case with Windows Server and SQL Server hands-on lab step-by-step

## Abstract and learning objectives

In this hands-on lab, you will perform steps to migrate Windows Server and SQL Server workloads to Azure. You will go through provisioning a Windows Server VM, migrating SQL Server database to Azure SQL Managed Instance (SQL MI), and Azure Arc-enable an on-premises Windows Server VM.

## Overview

In this lab, attendees will perform steps towards migrating Tailspin Toys on-premises Windows Server and SQL Server workloads to Azure. Tailspin needs a new Windows Server VM created in Azure for hosting their Web application, a on-premises SQL Server database migrated to Azure SQL Managed Instance, and an on-premises Windows Server VM to be Azure Arc-enabled.

Tailspin already has a Hub and Spoke network setup in Azure with Azure Bastion for enabling remote management of Azure VM using Azure Bastion. The Azure resources provisioned throughout this lab will be deployed into this environment.

## Solution architecture

![Preferred Solution Diagram](images/PreferredSolutionDiagram.png "Diagram showing on-premises network connected to Azure using Azure ExpressRoute with a Hub and Spoke network in Azure. The Spoke VNet contains the migrated Front-end, Back-end, and SQL Database workloads running within Subnets inside the Spoke VNet in Azure.")

The diagram shows on-premises network connected to Azure using Azure ExpressRoute with a Hub and Spoke network in Azure. The Spoke VNet contains the migrated Front-end, Back-end, and SQL Database workloads running within Subnets inside the Spoke VNet in Azure.

## Requirements

- You must have a working Azure subscription to carry out this hands-on lab step-by-step without a spending cap to deploy the Barracuda firewall from the Azure Marketplace.

## Before the hands-on lab

Refer to the Before the hands-on lab setup guide manual before continuing to the lab exercises.

## Exercise 1: SQL Database Migration

Duration: 90 minutes

Tailspin Toys needs to migrate their on-premises SQL Server database to Azure SQL Managed Instance. This is part of the migration strategy defines to migrate Tailspin Toys workloads to Azure.

In this exercise, you will go through the steps necessary to migrate Tailspin Toys on-premises SQL Server database to Azure SQL Managed Instance.

### Task 1: Create Subnet and Storage Account for Azure SQL MI

1. Sign in to the [Azure Portal](https://portal.azure.com). Ensure that you're using a subscription associated with the same resources you created during the Before the hands-on lab setup.

2. Within the Azure Portal, navigate to Resource Group created for this lab, and go to the `tailspin-spoke-vnet` virtual network.

3. Under **Settings**, select the **Subnets** link.

    ![Subnets link highlighted on the tailspin-spoke-vnet pane](images/azure-sql-mi-spoke-vnet-subnets-link.png "Subnets link highlighted on the tailspin-spoke-vnet pane")

4. Select **+Subnet** to create a new Subnet.

5. On the **Add subnet** pane, enter the following values to create a Subnet that will used by the Azure SQL Managed Instance that will be created later:

    - **Name**: `AzureSQLMI`
    - **Subnet address range**: `10.2.1.0/24`
    - **Delegate subnet to a service**: `Microsoft.Sql/managedInstances`

    ![Add subnet pane with values entered](images/azure-sql-mi-new-subnet.png "Add subnet pane with values entered")

6. Select **Save**. The list of Subnets will now look like the following:

    ![List of Subnets for the Spoke VNet in the Azure Portal](images/azure-sql-mi-subnets-list.png "List of Subnets for the Spoke VNet in the Azure Portal")

7. Go to the **Home** screen in the **Azure Portal**, then select **+ Create a resource**.

8. Under **Categories**, select **Storage**, then select **Create** for **Storage account** in the list of popular resources.

9. On the **Create a storage account**, enter the following values, then select **Review**:

    - **Resource group**: Select the resource group that you created for this lab. Such as `tailspin-rg`
    - **Storage account name**: Enter a unique name for the storage account, similar to `tailspinsqlmistorage`. You can add your initials or date to meet uniqueness requirements.
    - **Region**: Select the Azure Region that was used to create the resource group.

    ![Create a storage account pane with all values entered](images/azure-portal-create-storage-account-sqlmi.png "Create a storage account pane with all values entered")

10. Select **Create** to create the Storage Account.

11. Once the Storage Account is created, navigate to it, then select **Containers**.

    ![Storage Account with Containers link highlighted](images/azure-portal-storage-account-containers-link.png "Storage Account with Containers link highlighted")

12. Select **+ Container**.

13. On the **New container** pane, enter `sql-backup` in the **Name** field, then select **Create**.

### Task 2: Create Azure SQL MI

1. On the **Home** page within the Azure Portal, towards the top, select **Create a resource**.

2. Within the **Search services and marketplace** field, type **Azure SQL Managed Instance**, press Enter, and select it in the search results.

3. Select **Create**.

4. On the **Create Azure SQL Managed Instance** pane, set the following values:

    - **Resource group**: Select the resource group that you created for this lab. Such as `tailspin-rg`
    - **Managed Instance name**: Enter a unique name, such as `tailspin-sqlmi`
    - **Region**: Select the Azure Region that was used to create the resource group.

5. For **Compute + storage**, select **Configure Managed Instance**.

    ![Compute + storage section with Configure Managed Instance link highlighted](images/create-azure-sql-mi-compute-storage-configure-link.png "Compute + storage section with Configure Managed Instance link highlighted")

6. For the **Compute + storage** configured select the following values:

    - **Service tier**: General Purpose
    - **Hardware generation**: Standard-series
    - **vCores**: 8 vCores
    - **Storage in GB**: 64 GB

    ![Compute + storage pane with values entered](images/create-azure-sql-mi-compute-storage-values-entered.png "Compute + storage pane with values entered")

7. Select **Apply**

8. Under **Authentication**, set the **Authentication Method** value to **Use both SQL and Azure AD authentication**.

9. Under **Azure AD admin**, select **Set admin** and choose an Azure AD user for the Azure AD admin. You should choose your own User account.

    > **Note**: To choose the Azure AD admin, an organization account must be selected. A personal Microsoft Account cannot be used for this.

10. Enter a username to use for the **Managed Instance admin login** and a **Password** for this new Administrator user that will be created on the database server.

    > **Note**: Using the `demouser` username that was used previously in the lab, will make it easier to remember. However, this does require a password length of 16 characters, so here's an example password that is similar to the previous one used in the lab: `demo!pass1234567`

    ![Authentication values are set](images/create-azure-sql-mi-authentication-values-entered.png "Authentication values are set")

11. Select **Next: Networking >**.

12. On the **Networking** pane, enter the following values:

    - **Virtual network / subnet**: `tailspin-spoke-vnet/AzureSQLMI`

    ![Networking values entered](images/create-azure-sql-mi-networking-values-entered.png "Networking values entered")

13. Select **Review + create**.

14. Select **Create**.

    Deploying the new instance of Azure SQL Managed Instance may take about 1 hour to complete. You can continue to Exercise 2, then come back here later to finish Exercise 1.

### Task 3: Install Data Migration Assistant

1. In the Azure Portal, navigate to the Resource Group for the lab, then navigate to the `tailspin-onprem-sql-vm` virtual machine. This is the simulated on-premises SQL Server VM that contains the database to migrate to Azure SQL MI.

    ![Simulatd on-premises SQL Server VM](images/azure-portal-onprem-sql-vm.png "Simulatd on-premises SQL Server VM")

2. On the left, select **Bastion** under **Operations**.

    ![Bastion link is highlighted](images/azure-portal-vm-operations-bastion-link.png "Bastion link is highlighted")

3. Enter the **Username** and **Password**, then select **Connect**.

    ![Bastion credentials shown entered](images/azure-portal-sql-vm-bastion-username-password-entered.png "Bastion credentials shown entered")

    > **Note**: When the VM was created the credentials were setup as:
    > - **Username**: `demouser`
    > - **Password**: `demo!pass123`

4. In the **tailspin-onprem-sql-vm** virtual machine, go to **Server Manager**, and select **Local Server**

    ![Server Manager with Local Server highlighted](images/server-manager-local-server-highlighted.png "Server Manager with Local Server highlighted")

5. Within **Local Server**, select the `On` text link for the **IE Enhanced Security Configuration** property.

    ![Server Manager with IE Enhanced Security Configuration highlighted](images/server-manager-local-server-ie-enhanced-security-config.png "Server Manager with IE Enhanced Security Configuration highlighted")

6. On the **Internet Explorer Enhanced Security Configuration** dialog, select **Off** for **Administrators**, then select **OK**.

    ![IE Enhanced Security Configuration dialog with Administrators Off property highlighted](images/server-manager-ie-enhanced-security-config-administrators-off-property.png "IE Enhanced Security Configuration dialog with Administrators Off property highlighted")

7. In the **tailspin-onprem-sql-vm** virtual machine, open **Internet Explorer** then go to the following link and download the **.NET Framework 4.8 Runtime** installer. This will be needed to install the Microsoft Data Migration Assistant.

    <https://dotnet.microsoft.com/en-us/download/dotnet-framework/thank-you/net48-web-installer>

8. Select **Run** to run the **.NET Framework 4.8 Runtime** installer once it's finished downloading, and follow the prompts to install the .NET Framework.

9. Using **Internet Explorer**, go to the following link and download the **Microsoft Data Migration Assistant**.

    - <https://www.microsoft.com/en-us/download/details.aspx?id=53595>

10. Select **Run** to run the **Microsoft Data Migration Assistant** installer once it's finished downloading, and follow the prompts to install the assistant.

    ![Microsoft Data Migration Assistant Setup wizard](images/microsoft-data-migration-assistant-setup-wizard.png "Microsoft Data Migration Assistant Setup wizard")

### Task 4: Assess On-premises database compatibility

1. Run the **Microsoft Data Migration Assistant** that was previously installed.

    ![Data Migartion Assistant window](images/ms-data-migration-assistant-windows.png "Data Migartion Assistant window")

2. On the left, select the Plus sign (`+`) button to create a new project, and enter the following values, then select **Create**.

    - **Project type**: Assessment
    - **Project name**: Tailspin
    - **Assessment type**: Database Engine
    - **Source server type**: SQL Server
    - **Target server type**: Azure SQL Database Managed Instance

    ![Data Migration Assistant New project dialog with values entered](images/ms-data-migration-assistant-new-project.png "Data Migration Assistant New project dialog with values entered")

3. On the **Options** tab, ensure the **Check database compatibility** and **Check feature parity** report types are selected, then select **Next**.

4. On the **Connect to a server** prompt, enter `localhost` for the     **Server name**, and check the **Trust server certificate** option, then select **Connect**.

    ![Connect to a server configured for localhost](images/ms-data-migration-assistant-assessment-connect-to-server-localhost.png "Connect to a server configured for localhost")

5. On the **Add sources** prompt, select the **WideWorldImporters** database, then select **Add**.

6. Select **Start Assessment** in the lower right.

    ![Data Migration Assistant with the Start Assessment button highlighted](images/ms-data-migration-assistant-assessment-start-assessment-button.png "Data Migration Assistant with the Start Assessment button highlighted")

7. On the **Review results** pane, you should see a message that "**There are no feature parity issues with your server instance**".

    ![Data Migration Assistant showing there are no feature parity issues](images/ms-data-migration-assistant-assessment-no-feature-parity-issues.png "Data Migration Assistant showing there are no feature parity issues")

8. On the top left of the **Review results** pane, select **Compatibility issues**.

9. On the **Review results** pane, you should see a message that "**There are no compatibility issues with your database**".

    ![Data Migration Assistant showing there are no compatibility issues](images/ms-data-migration-assistant-assessment-no-compatibility-issues.png "Data Migration Assistant showing there are no compatibility issues")

10. The Data Migration Assessment is complete. If there were feature parity or compatibility issues found, then you would need to address those before migrating the SQL Server database to Azure SQL MI.

### Task 5: Backup on-premises SQL Database

1. In the **tailspin-onprem-sql-vm** virtual machine, run the **Azure Data Studio**.

2. On the left, select the **Extensions** tab, then select the **Azure SQL Migration** extension and install it.

    ![Azure SQL Migration extension highlighted](images/azure-data-studio-extensions-azure-sql-migration.png "Azure SQL Migration extension highlighted")

3. Next, you need to enable Preview Features within Azure Data Studio. Select the Manage icon (shown as the Gear in the lower left corner of Azure Data Studio)

    ![The manage menu open with Settings highlighted](images/azure-data-studio-manage-menu-settings.png "The manage menu open with Settings highlighted")

4. On the **Settings** pane, type **Enable Preview Features** in the search box at the top, then check the **Enable unreleased preview features** box for the **Workbench: Enable Preview Features** option that shows in the search results. This will autosave.

    ![Azure Data Studio settings pane with Preview Features enabled](images/azure-data-studio-preview-features-enabled.png "Azure Data Studio settings pane with Preview Features enabled")

5. Next, let's connect to the on-premises SQL Server. Select the **Connections** tab on the left side of Azure Data Studio.

6. Select **New Connection**

    ![Azure Data Studio connections tab with New Connection button shown](images/azure-data-studio-connections-tab-new-connection-button.png "Azure Data Studio connections tab with New Connection button shown")

7. On the **Connection** pane, enter the following values to connect to the on-premises SQL database, then select **Connect**:

    - **Connection type**: Microsoft SQL Server
    - **Server**: `localhost`
    - **Authentication type**: Windows Authentication
    - **Database**: `WideWorldImporters`

    ![Azure Data Studio with Connection pane shown having all values entered](images/azure-data-studio-connection-pane-values-entered.png "Azure Data Studio with Connection pane shown having all values entered")

8. In the list of servers, right-click the **localhost, WideWorldImporters** server, then select **Manage**.

    ![WideWorlImporters server with right-click menu shown and Manage option is highlighted](images/azure-data-studio-servers-right-click-manage-shown.png "WideWorlImporters server with right-click menu shown and Manage option is highlighted")

9. Select **Backup**.

    ![Manage database with Backup button highlighted](images/azure-data-studio-database-manage-backup-button.png "Manage database with Backup button highlighted")

10. On the **Backup database** pane, make sure **Backup type** is set to **Full**, select the **Reliability** option to **Perform checksum before writing to media**, then make a note of the **Backup files** location, and select **Backup**.

    ![Backup database pane](images/azure-data-studio-backup-full.png "Backup database pane")

11. Open **Internet Explorer**, navigate to the following URL, download **Microsoft Azure Storage Explorer** and install it.

    <https://azure.microsoft.com/en-us/products/storage/storage-explorer/#overview>

12. Launch **Microsoft Azure Storage Explorer**

13. Select **Sign in with Azure**

    ![Azure Storage Explorer window with Sign in with Azure button highlighted](images/azure-storage-explorer-with-sign-in-azure-highlighted.png "Azure Storage Explorer window with Sign in with Azure button highlighted")

14. Sign in with your **Microsoft Account**.

15. In the **Explorer** pane, expand the Azure Subscription, locate the Storage Account that was previously created (named similar to `tailspinsqlmistorage`), then expand **Blob Container** and select the **sql-backup** container.

    ![Storage Explorer showing the SQL MI backup storage account expanded](images/azure-storage-explorer-tailspinsqlmistorage-container-expanded.png "Storage Explorer showing the SQL MI backup storage account expanded")

16. In the **sql-backup** container pane, select **Upload**, then select **Upload Files...**.

    ![Storage Explroer with Upload button highlighted and menu for Upload files showing](images/azure-storage-explorer-tailspinsqlmistorage-upload-button.png "Storage Explroer with Upload button highlighted and menu for Upload files showing")

17. In the **Upload Files** dialog, in the **Selected files** field, select the **Database Backup File** (`.bak`) for the **WideWorldImporters** database that was previously created, then select **Upload**.

    ![Storage Explorer Upload File dialog with database backup file selected](images/azure-storage-explorer-upload-files.png "Storage Explorer Upload File dialog with database backup file selected")

### Task 6: Migrate Database to Azure SQL MI

6. In the list of servers, right-click the **localhost, WideWorldImporters** server, then select **Manage**.

    ![WideWorlImporters server with right-click menu shown and Manage option is highlighted](images/azure-data-studio-servers-right-click-manage-shown.png "WideWorlImporters server with right-click menu shown and Manage option is highlighted")

7. Select the **Azure SQL Migration** option.

    ![Manage server pane with Azure SQL Migration option highlighted](images/azure-data-studio-manage-server-pane.png "Manage server pane with Azure SQL Migration option highlighted")

8. Select the **Migrate to Azure SQL** button.

    ![Azure SQL Migration with Migrate to Azure SQL button highlighted](images/azure-data-studio-azure-sql-migration-migrate-button.png "Azure SQL Migration with Migrate to Azure SQL button highlighted")

9. On **Step 1: Database for assessment**, select the **WideWorldImporters** database, then select **Next**.

    ![](images/azure-data-studio-migrate-step-1.png)

10. On **Step 2: Assessment results and recommendations**, select the **Azure SQL Managed Instance** option.

11. Scroll down and select the **View/Select** button to select a database.

12. Select the **WideWorldImporters** database, and you should see a message stating "`No issues for migrating to Azure SQL Managed Instance.`", then select the **Select** button.

     ![WideWorldImporters database selected and 'no issues' message shown](images/2022-09-23-15-01-58.png "WideWorldImporters database selected and 'no issues' message shown")

13. Select **Next**.

    ![](images/azure-data-studio-migrate-step-2.png "")

14. On **Step 3: Azure SQL target**, enter connection information to your Azure Subscription and for the **Azure SQL Manage Instance** resource that was previously created.

    ![Step 3 shown with Azure SQL MI resource selected](images/azure-data-studio-migrate-step-3.png "Step 3 shown with Azure SQL MI resource selected")

15. On **Step 4: Migration mode**, select **Next**.

    ![Step 4 Migration mode with Online migration selected](images/azure-data-studio-migrate-step-4.png "Step 4 Migration mode with Online migration selected")

16. On **Step 5: Database backup**, select **My database backups are in an Azure Storage Blob Container**, select the Azure Storage Account and container created previously, then select **Next**.

    ![Step 5: Database backup with Azure Storage Account and Container selected](images/azure-data-studio-migrate-step-5.png "Step 5: Database backup with Azure Storage Account and Container selected")

17. On **Step 6: Azure Database Migration Service**, select **Create new** under **Azure Database Migration Service**.

18. On the **Create Azure Database Migration Service** pane, enter the following values, then select **Create**.

    - **Resource group**: Select the Resource Group for this lab. For example: `tailspin-rg`
    - **Name**: `tailspin-sql-migration`

    ![Create Database Migration Service dialog with values entered](images/azure-data-studio-migrate-create-migration-service.png "Create Database Migration Service dialog with values entered")

19. Once the Database Migration Service has been created, select **Done**.

20. On **Step 6: Azure Database Migration Service**, select the **Azure Database Migration Service** that was created, then selecft **Next**.

    ![Step 6 with Azure Database Migration Service selected](images/azure-data-studio-migrate-step-6.png "Step 6 with Azure Database Migration Service selected")

21. On **Step 7: Summary**, review all the configurations chosen, then select **Start migration**.

    ![Step 7 showing summary of configurations chosen](images/azure-data-studio-migrate-step-7.png "Step 7 showing summary of configurations chosen")

22. Azure Data Studio will now show that there is 1 **Database migrations in progress**.

    ![Azure Data Studio showing there is 1 data migration in progress](images/azure-data-studio-database-migrations-in-progress.png "Azure Data Studio showing there is 1 data migration in progress")

23. In the Azure Portal, navigate to the **Azure Database Migration Service** that was created (named similar to `tailspin-sql-migration`), then select **Migrations** and the **WideWorldImporters** migration.

    ![Azure Database Migration Service with In-progress migration highlighted](images/azure-database-migration-service-inprogress.png "Azure Database Migration Service with In-progress migration highlighted")

24. The **WideWorldImporters** migration shows the current status of the migration as `InProgress`. Notice the **Currently restoring files** should say **All backups restored** once the database backup has been restored. Then select **Complete cutover** at the top.

    ![](images/wideworldimporters-migration-inprogress.png "WideWorldImporters migration showing status as InProgress")

25. On the **Complete cutover** prompt, select the box for **I confirm there are no additional log backups...**, then select **Complete cutover**.

    ![Complete cutover prompt](images/wideworldimporters-migration-complete-cutover.png "Complete cutover prompt")

26. The **WideWorldImporters** Migration will now show the status of **Completing**. This will take a few minutes to complete.

    ![WideWorldImporters migration showing status of Completing](images/wideworldimporters-migration-completing.png "WideWorldImporters migration showing status of Completing")

27. Once the cutover has completed, the **WideWorldImporters** migration will show a status of **Succeeded**.

    ![WideWorldImporters migration showing status of succeeded](images/wideworldimporters-migration-succeeded.png "WideWorldImporters migration showing status of succeeded")

28. Within the Azure Portal, navigate to the **Azure SQL Managed Instance** that was created previously.

29. When the SQL Server database migration to Azure SQL MI has completed, you will see the **WideWorldImporters** database shown with an **Online** status.

    ![Azure SQL MI in Azure Portal showing the WideWorldImporters database in Online status](images/azure-portal-sql-mi-database-status-online.png "Azure SQL MI in Azure Portal showing the WideWorldImporters database in Online status")

## Exercise 2: Create VM to Migrate Web Application

Duration: 30 minutes

In this exercise, you will create a new Windows Server 2022 virtual machine (VM) that will be the destination for migrating the on-premises Web Application to Azure, and then you will use Azure Bastion to connect to the VM over Remote Desktop (RDP). Azure Bastion will allow secure remote connections to the VM for Administrators.

### Task 1: Create Windows Server 2022 VM for Application Hosting

In this task, you will create a new Windows Server 2022 virtual machine (VM) that will be the destination for migrating the on-premises Web Application to Azure.

1. Sign in to the [Azure Portal](https://portal.azure.com). Ensure that you're using a subscription associated with the same resources you created during the Before the hands-on lab setup.

2. On the **Home** page within the Azure Portal, towards the top, select **Create a resource**.

3. Within the **Search services and marketplace** field, type **Windows Server** and press Enter to search the marketplace.

4. Select **Windows Server**.

    ![Windows Server is highlighted within the Azure Marketplace](images/azure-marketplace-windows-server.png "Windows Server is highlighted")

5. Choose **Windows Server 2022 Datacenter**, then select **Create**.

6. On the **Create a virtual machine** pane, set the following values to configure the new virtual machine:

    - **Resource group**: Select the resource group that you created for this lab. Such as `tailspin-rg`.
    - **Virtual machine name**: Give the VM a unique name, such as `tailspin-webapp-vm`
    - **Region**: Select the Azure Region that was used to create the resource group
    - **Image**: Verify the image is set to **Windows Server 2022 Datacenter**

    ![Create a virtual machine with field set](images/create-virtual-machine-windows-server-image-set.png "Create a virtual machine with field set")

7. Set the **Size** field select the **Standard_D4s_v5** virtual machine size.

    ![VM size is set](images/create-virtual-machine-size-set.png "VM size is set")

8. Set a **Username** and **Password** for the **Administrator account** for the VM.

    > **Note**: Be sure to save the Username and Password for the VM, so it can be used later. Recommendation for easy to remember Username is `demouser` and Password is `demo!pass123`.

9. Select **Next** until you are navigated to the **Networking** tab of the ** Create a virtual machine page.

    ![Networking tab is selected](images/create-virtual-machine-networking-tab-selected.png "Networking tab is selected")

10. Provision the VM in the Spoke VNet in Azure by selecting the following values under the **Network interface** section:

    - **Virtual network**: Select the Spoke VNet that was created for this lab. It's name will be silimar to `tailspin-spoke-vnet`
    - **Subnet**: `default`
    - **Public IP**: `None`

    ![Virtual Network, Subnet, and Public IP values are set](images/create-virtual-machine-networking-values-set.png "Virtual Network, Subnet, and Public IP values are set")

11. Set the following values to ensure that HTTPS traffic will be allowed to connect to the VM:

    - **Public inbound ports**: `Allow selected ports`
    - **Select inbound ports**: `HTTPS (443)`

    ![Networking inbound ports set to allow HTTPS traffic](images/create-virtual-network-https-traffic-allowed.png "Networking inbound ports set to allow HTTPS traffic")

12. Select **Review + create** to review the virtual machine settings.

13. Select **Create** to begin provisioning the virtual machine.

### Task 2: Check Remote Desktop Access

In this task, you will test Remote Desktop (RDP) connectivity to the newly created virtual machine using Azure Bastion.

1. In the Azure Portal, navigate to the newly created **Virtual Machine**.

    ![Virtual machine pane is open](images/web-app-win2022server-virtual-machine-pane.png "Virtual machine pane is open")

2. On the left, under the **Operations** section, select **Bastion**.

    ![Bastion is highlighted under Operations section](images/portal-virtual-machine-operations-bastion-link.png "Bastion is highlighted under Operations section")

3. On the **Bastion** pane, enter the **Username** and **Password** that was set for the Administrator User of the VM when it was created, then select **Connect**

    ![Bastion pane with username and password entered](images/portal-virtual-machine-operations-bastion-pane.png "Bastion pane with username and password entered")

    > **Note**: The Azure Bastion instance named `tailspin-hub-bastion` was previously created with the Before the Hands-on lab setup. This is a required resource for using Azure Bastion to securely connect to Azure VMs using RDP from within the Azure Portal.

4. A new browser tab will open with Azure Bastion connected to the virtual machine over RDP. To close this session, you can close this browser tab.

    ![Browser window open with Azure Bastion connected to the VM](images/browser-azure-bastion-connected-web-app-win2022server.png "Browser window open with Azure Bastion connected to the VM")

> **Note**: Now that the Windows Server 2022 VM has been created in Azure, Tailspin Toys will now be able to modify their Continuous Integration and Continuous Deployment (CD/CD) pipelines within Azure DevOps to begin deploying the Web Application code to this virtual machine as they get ready for migrating the application to Azure.

## Exercise 3: Azure Arc-enable On-premises VM

Duration: 30 minutes

In this exercise, you will Azure Arc-enable a Windows Server VM that Tailspin has on-premises. This VM is being Arc-enabled since there are no plans to migrate it to Azure, but Tailspin would like to simplify the management of all their VMs in a single place. Azure Arc provides the functionality to manage Azure and on-premises VMs in a single place giving Tailspin Toys exactly what they are looking to simplify VM management and administration.

### Task 1: Generate Azure Arc script to add server

1. Sign in to the [Azure Portal](https://portal.azure.com). Ensure that you're using a subscription associated with the same resources you created during the Before the hands-on lab setup.

2. In the **Search resources, services, and docs** box at the top of the portal, search for **Azure Arc**, then select the **Azure Arc** service.

    ![Azure Portal search for Azure Arc with 'Azure Arc' option highlighted](images/azure-portal-search-azure-arc-service.png "Azure Portal search for Azure Arc with 'Azure Arc' option highlighted")

3. On the **Azure Arc** pane, select the **Infrastructure** tab, then select the **Add** button under **Servers**.

    ![Azure Arc pane with Infrastructure tab and Servers Add button highlighted](images/azure-arc-pane-infrastructure-servers-add-button.png "Azure Arc pane with Infrastructure tab and Servers Add button highlighted")

4. Under **Add a single server** select **Generate script**.

5. On the **Add a server with Azure Arc** pane, read the requirements of Azure Arc that are listed, then select **Next**.

6. On the **Resource details** tab, enter the following values, then select **Next**.

    - **Resource group**: Select the Resource Group created for this lab. For example: `tailspin-rg`
    - **Region**: Select the closest region to the geographic location of the server being added to Azure Arc. In this case, use the same Region used for the Resource Group created for the lab.
    - **Operating system**: `Windows`
    - **Connectivity method**: `Public endpoint`

    ![Resource details tab with values entered](images/2022-09-22-21-13-42.png "Resource details tab with values entered")

7. On the **Tags** tab, enter the following tag values to identify this server, then select **Next**:

    - **Datacenter**: `headquarters`
    - **City**: `Milwaukee`
    - **StateOrDistrict**: `WI`
    - **CountryOrRegion**: `USA`

    ![Tags tab with all tag values entered](images/azure-arc-add-server-tags-tab.png "Tags tab with all tag values entered")

8. On the **Download and run script** tab, select **Download** to download the generated script. By default, the script named `OnboardingScript.ps1` will be saved to the `Downloads` folder.

### Task 2: Run script to add server to Azure Arc

1. In the Azure Portal, navigate to the Resource Group for the lab, then navigate to the `tailspin-onprem-hyperv-vm` virtual machine. This is the simulated on-premises Hyper-V host VM.

    ![Simulated on-premises hyper-v host vm](images/azurep-portal-onprem-hyperv-vm.png "Simulated on-premises hyper-v host vm")

2. On the left, select **Bastion** under **Operations**.

    ![Bastion link is highlighted](images/azure-portal-vm-operations-bastion-link.png "Bastion link is highlighted")

3. Enter the **Username** and **Password**, then select **Connect**.

    ![Bastion credentials shown entered](images/azure-portal-vm-bastion-username-password-entered.png "Bastion credentials shown entered")

    > **Note**: When the VM was created the credentials were setup as:
    > - **Username**: `demouser`
    > - **Password**: `demo!pass123`

4. Once connected to the Hyper-V Host VM, open the **Start menu**, then search for and run the **Hyper-V Manager**.

5. Within the **Hyper-V Manager**, double-click the **OnPremVM** VM to connect to it.

    ![Hyper-V Manager list of VMs with OnPremVM shown](images/hyper-v-manager-vm-list.png "Hyper-V Manager list of VMs with OnPremVM shown")

6. Once connected to the **OnPremVM** VM within Hyper-V, login using the **Administrator** account and the password of `demo!pass123`.

7. Within the **OnPremVM**, open the **Windows PowerShell ISE**, and create a new script file.

8. Paste in the contents of the Azure Arc `OnboardingScript.ps1` script that was previously downloaded.

    > **Note**: Within the Hyper-V Virtual Machine Connection window, you may need to use the **Clipboard** -> **Type clipboard text** menu option to paste into the **OnPremVM**.

9. Run the full script. This will install the Azure Arc agent and Arc-enable the VM.

### Task 3: Verify Azure Arc-enabled VM

1. ???







## After the hands-on lab

Duration: 15 minutes

### Task 1: Delete Resource group to remove the lab environment

1. To to the **Azure Portal**.

2. Go to your **Resource groups**.

3. Select the **Resource group** you created.

    ![Resource group list in Azure Portal](images/azure-portal-resource-groups.png "Resource group list in Azure Portal")

4. Select **Delete Resource group**.

    ![Resource group pane with Delete button highlighted](images/azure-portal-resource-group-delete-button.png "Resource group pane with Delete button highlighted")

5. Enter the name of the **Resource group** and select **Delete**.

    ![Delete Resource group confirmation prompt](images/azure-portal-resource-group-delete-confirm.png "Delete Resource group confirmation prompt")

You should follow all steps provided *after* attending the Hands-on lab.
