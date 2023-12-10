#################################################
############# Resource group
#################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.00"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraformtfstate"
    storage_account_name = "terraformtfstatecicd"
    container_name       = "tfstate"
    key                  = "rg/rg-1/"
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
  tags = {
    Environment        = var.environment_tag[0]
    Owner              = var.owner_tag
    ProjectName        = var.projectname_tag
    ServiceDescription = var.servicedescription_tag
    Status             = var.status_tag[0]
    Provider           = var.provider_tag[2]
    Temporal           = var.temporal_tag[0]
    Compliance         = var.compliance_tag[5]
    Confidentiality    = var.confidentiality_tag[3]
    Integrity          = var.integrity_tag[3]
    Availability       = var.availability_tag[3]
    Criticality        = var.criticality_tag[3]
    EnvironmentTech    = var.environmenttech_tag[1]
    SSRorNSSRID        = var.ssrornssrid_tag
    Location           = var.location_tag
    Budget             = var.budget_tag
    ExpirationDate     = var.expirationdate_tag
    MaintenanceWindow  = var.maintenancewindow_tag
    BA                 = var.ba_tag
    CreationDate       = var.creationdate_tag
    TPO                = var.tpo_tag
    EJE                = var.eje_tag
    Speed              = var.speed_tag[3]
    Seat               = var.seat_tag[2]
    Coverage           = var.coverage_tag[3]
    Facturable         = var.facturable_tag[1]
    BU                 = var.bu_tag
    CostCenter         = var.na_tag
    Servicebusiness    = var.servicebusiness_tag
    Hus                = var.hus_tag[0]
  }
}
