![Microsoft Cloud Workshops](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/main/Media/ms-cloud-workshop.png "Microsoft Cloud Workshops")

<div class="MCWHeader1">
Building the business migration case with Windows Server and SQL Server
</div>

<div class="MCWHeader2">
Whiteboard design session student guide
</div>

<div class="MCWHeader3">
September 2022

</div>

Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.

© 2022 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at https://www.microsoft.com/en-us/legal/intellectualproperty/Trademarks/Usage/General.aspx are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents**

<!-- TOC -->

- [Building the business migration case with Windows Server and SQL Server](#building-the-business-migration-case-with-windows-server-and-sql-server)
    - [Abstract and learning objectives](#abstract-and-learning-objectives)
    - [Step 1: Review the customer case study](#step-1-review-the-customer-case-study)
        - [Customer situation](#customer-situation)
        - [Customer needs](#customer-needs)
        - [Customer objections](#customer-objections)
        - [Infographic for common scenarios](#infographic-for-common-scenarios)
    - [Step 2: Design a proof of concept solution](#step-2-design-a-proof-of-concept-solution)
    - [Step 3: Present the solution](#step-3-present-the-solution)
    - [Wrap-up](#wrap-up)
    - [Additional references](#additional-references)

<!-- /TOC -->

# Building the business migration case with Windows Server and SQL Server

## Abstract and learning objectives

In this whiteboard design session, you will look at how to design a strategy for migrating existing on-premises Windows Server and SQL Server workloads to Azure. Throughout the whiteboard design session, you will look at the Virtual Machine pricing, integrated management of cloud and on-premises workloads using Azure Arc, and migrating SQL Server workloads to Azure.

At the end of the workshop, you will be better able to design a migration strategy for Windows Server workloads to Azure VMs, SQL Server workloads to Azure SQL MI, and simplifying workload management using Azure Arc.

## Step 1: Review the customer case study

**Outcome**

Analyze your customer's needs.

Timeframe: 15 minutes

Directions: With all participants in the session, the facilitator/SME presents an overview of the customer case study along with technical tips.

1. Meet your team members and trainer.

2. Read all directions for steps 1-3 in the student guide.

3. As a team, review the following customer case study.

### Customer situation

Tailspin Toys is a global manufacturer of children’s toys that was founded in 1957 with its global headquarters located in Milwaukee, WI. Their mission-critical workloads are currently hosted in an on-premises data center and are beginning a journey to modernize and migrate into the cloud using Microsoft Azure.

The CTO, Kaylee Frye, has already had the Technical Architects at Tailspin Toys assess their current environment and what it will take to migrate to the cloud. They are looking to optimize their technology investments by reducing technical debt, streamlining operations, and simplifying their DevOps workflow. According to Kaylee Frye, "Our development teams have already begun adopting DevOps strategies and implemented CI/CD pipelines with Azure DevOps. We really look forward to better streamlining IT operations as we adopt Microsoft Azure for the infrastructure too."

Tailspin has already completed the first round of analysis to identify the apps and workloads to migrate first. These workloads are hosted using SQL Server and Windows Server VMs. They have compiled an initial list of servers they believe can be migrated now, in addition to some they’ll need to retain on-premises for now.

Their on-premises environment consists of over 250 servers and VMs, although, they don't plan to migrate all of them to Azure. The fear of breaking an existing system during their migration is the reason they've identified just a few servers / VMs to begin the migration.

The first workload they want to migrate to Azure consists of:

- Web Application Front-end
  - ASP.NET MVC using .NET Framework 4.7
  - 2x Windows Server 2012 VMs
    - each with 2 CPU cores and 16 GB Memory
- REST API Back-end
  - ASP.NET MVC using .NET Framework 4.7
  - 2x Windows Server 2012 VMs
    - each with 4 CPU cores and 32 GB Memory
- Application Databases
  - SQL Server 2012
  - Data replication across 2x Windows Server 2012 VMs
    - each with 8 CPU cores and 64 GB Memory
  - 3x databases with the following storage sizes
    - Database 1: 1.2 TB
    - Database 2: 435 GB
    - Database 3: 50 GB

They have identified the following workloads that may not be migrated to Azure, but would like some advice on how to handle these:

- Windows Domain Controllers
- 3x Network File Shares hosted on Windows Server 2012
- 8x Windows Server VMs hosting .NET Core and .NET Framework applications hosted using IIS
- 4x Ubuntu 18.04 Linux VMs running nginx hosting multiple small .NET Core web applications

The Virtual Machines hosted in their on-premises data center are hosted using Windows Hyper-V. Also, some of the smaller .NET Core web applications are included in a plan to be phased out, so there may be limited benefit from migrating all their on-premises workloads to Azure.

In preparations for their cloud adoption journey, Tailspin has already had an Azure ExpressRoute circuit provisioned to connect to their on-premises data center along with a Hub and Spoke Virtual Network topology in Azure. The ExpressRoute circuit is configured with 2 Gbps bandwidth to connect to the Azure Networking that has been set up in the North Central US region. This will provide them with the necessary Azure networking infrastructure to migrate their workloads. Since they are new to Azure, they will need some additional help in the migrations and modernization of their Windows Server and SQL Server workloads.

### Customer needs

1. Migrate existing workloads to Azure as efficiently as possible.

2. Lower the management burden with a consolidated view to manage all VMs and Servers across Azure and on-premises.

3. Network security is extremely important as we integrate on-premises networking with Microsoft Azure.

### Customer objections

1. It appears there are multiple options for hosting SQL databases in Azure. What's the best option to choose, and how do you know it'll be compatible?

2. What kind of downtime will be incurred when migrating the Windows Server and SQL Server workloads to Azure?

3. Will we be able to roll back to the on-premises VMs if the migration fails?

4. Tailspin has negotiated an Enterprise Agreement (EA) with Microsoft for their Azure consumption. Any cost estimates need to reflect their EA discount.

5. Would there be further savings from the use of PaaS services?

### Infographic for common scenarios

**Hub-spoke network topology in Azure**
![Hub-spoke network topology in Azure](images/diagram-azure-vnet-hub-spoke.png "Hub-spoke network topology in Azure")

**Azure Arc control plan**
![Azure Arc control plan](images/diagram-azure-arc-control-plane.png "Azure Arc control plan")

## Step 2: Design a proof of concept solution

**Outcome**

Design a solution and prepare to present the solution to the target customer audience in a 15-minute chalk-talk format.

Timeframe: 60 minutes

**Business needs**

Directions:  With your team, answer the following questions and be prepared to present your solution to others:

1. Who will you present this solution to? Who is your target customer audience? Who are the decision-makers?

2. What customer business needs do you need to address with your solution?

**Design**

Directions: With your team, respond to the following questions:

1. How will you migrate the on-premises workloads to Azure?

2. How will you migrate the SQL Server workloads to Azure?

3. Which workloads should remain on-premises and which should be considered to be migrated at a later time?

4. How will they reduce the burden of managing both on-premises and Azure workloads?

**Pricing**

Provide an estimated cost for the workloads being migrated in your solution.

- Be sure to cover all aspects of the design, including the primary site, DR solution, backup solution, and monitoring costs

- What's the best option for hosting the SQL Server workloads?

- Have you included all appropriate cost-saving measures?

**Prepare**

Directions: As a team:

1. Identify any customer needs that are not addressed with the proposed solution.

2. Identify the benefits of your solution.

3. Determine how you will respond to the customer's objections.

Prepare a 15-minute chalk-talk style presentation to the customer.

## Step 3: Present the solution

**Outcome**

Present a solution to the target customer audience in a 15-minute chalk-talk format.

Timeframe: 30 minutes

**Presentation**

Directions:

1. Pair with another team.

2. One group is the Microsoft team, the other is the customer.

3. The Microsoft team presents their proposed solution to the customer.

4. The customer makes one of the objections from the list of objections.

5. The Microsoft team responds to the objection.

6. The customer team gives feedback to the Microsoft team.

7. Switch roles and repeat Steps 2-6.

## Wrap-up

Timeframe: 15 minutes

Directions: Reconvene with the larger group to hear the facilitator/SME share the preferred solution for the case study.

## Additional references

|    |            |
|----------|:-------------:|
| **Description** | **Links** |
| Microsoft Azure Reference Architectures| <https://docs.microsoft.com/azure/guidance/guidance-architecture> |
| Hub-spoke network topology in Azure | <https://docs.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/hub-spoke> |
| Extend an on-premises network using ExpressRoute | <https://docs.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/expressroute> |
| Azure Arc overview | <https://docs.microsoft.com/azure/azure-arc/overview> |
| What is Azure SQL Managed Instance? | <https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/sql-managed-instance-paas-overview> |
| Azure Database Migration Service | <https://azure.microsoft.com/products/database-migration/#overview> |
| Overview of Data Migration Assistant | <https://docs.microsoft.com/sql/dma/dma-overview> |
