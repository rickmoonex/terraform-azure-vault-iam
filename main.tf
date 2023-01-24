data "azurerm_subscription" "current" {}

locals {
  resource_group_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group.name}"
}

resource "azurerm_user_assigned_identity" "vault" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_key_vault_access_policy" "vault_msi" {
  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.vault.principal_id
  tenant_id    = var.tenant_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_role_definition" "vault" {
  name  = "${var.resource_name_prefix}-vault-server"
  scope = local.resource_group_id

  assignable_scopes = [
    local.resource_group_id,
  ]

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachineScaleSets/*/read",
    ]
  }
}

resource "azurerm_role_assignment" "vault" {
  principal_id       = azurerm_user_assigned_identity.vault.principal_id
  role_definition_id = azurerm_role_definition.vault.role_definition_resource_id
  scope              = local.resource_group_id
}

resource "azurerm_user_assigned_identity" "load_balancer" {
  location            = var.resource_group.location
  name                = "${var.resource_name_prefix}-vault-lb"
  resource_group_name = var.resource_group.name
  tags                = var.common_tags
}

resource "azurerm_key_vault_access_policy" "load_balancer_msi" {
  key_vault_id = var.key_vault_id
  object_id    = azurerm_user_assigned_identity.load_balancer.principal_id
  tenant_id    = var.tenant_id

  secret_permissions = [
    "Get",
  ]
}
