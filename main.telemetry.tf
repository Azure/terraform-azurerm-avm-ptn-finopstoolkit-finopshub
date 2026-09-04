resource "random_id" "telem" {
  count = var.enable_telemetry ? 1 : 0

  byte_length = 4
}

# This is the module telemetry deployment that is only created if telemetry is enabled.
# It is deployed to the resource's resource group.
resource "azurerm_resource_group_template_deployment" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  deployment_mode     = "Incremental"
  name                = local.telem_arm_deployment_name
  resource_group_name = var.resource_group_name
  tags                = null
  template_content    = local.telem_arm_template_content
}

resource "random_uuid" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

data "modtm_module_source" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  module_path = path.module
}

resource "modtm_telemetry" "telemetry" {
  count = var.enable_telemetry ? 1 : 0

  tags = merge({
    subscription_id = one(data.azapi_client_config.telemetry).subscription_id
    tenant_id       = one(data.azapi_client_config.telemetry).tenant_id
    module_source   = one(data.modtm_module_source.telemetry).module_source
    module_version  = one(data.modtm_module_source.telemetry).module_version
    random_id       = one(random_uuid.telemetry).result
  }, { location = local.main_location })
}

data "azapi_client_config" "telemetry" {
  count = var.enable_telemetry ? 1 : 0
}

locals {
  main_location = var.location
}
