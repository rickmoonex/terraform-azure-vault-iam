output "lb_identity_id" {
  value = azurerm_user_assigned_identity.load_balancer.id

  depends_on = [
    azurerm_key_vault_access_policy.load_balancer_msi,
  ]
}

output "vm_identity_id" {
  value = azurerm_user_assigned_identity.vault.id

  depends_on = [
    azurerm_key_vault_access_policy.vault_msi,
    azurerm_role_assignment.vault,
  ]
}
