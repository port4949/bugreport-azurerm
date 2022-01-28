# Notes
When i activate a system assigned identity in an preexisting app service and
add a key vault policy that uses this identity terraform can't resolve the
dependency and the apply fails with the following error message:
	
        ╷
	│ Error: Missing required argument
	│ 
	│   with azurerm_key_vault_access_policy.policy-bugreport-app,
	│   on main.tf line 93, in resource "azurerm_key_vault_access_policy" "policy-bugreport-app":
	│   93:   tenant_id    = azurerm_app_service.app-bugreport.identity[0].tenant_id
	│ 
	│ The argument "tenant_id" is required, but no definition was found.
	╵
	╷
	│ Error: Missing required argument
	│ 
	│   with azurerm_key_vault_access_policy.policy-bugreport-app,
	│   on main.tf line 94, in resource "azurerm_key_vault_access_policy" "policy-bugreport-app":
	│   94:   object_id    = azurerm_app_service.app-bugreport.identity[0].principal_id
	│ 
	│ The argument "object_id" is required, but no definition was found.


## Reproduce the issue
To reproduce the issue you have to apply the prepared main.tf (this creates the
key vault, app service, etc.).

Then uncomment the identity block in the app service (around line 78) und the
key vault access policy block at the end of the file.

Now you can apply the configuration again und you will see the error message.
