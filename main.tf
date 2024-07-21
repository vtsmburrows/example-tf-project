
resource "azurerm_resource_group" "hub-east" {
  name     = var.hub.east.name
  tags     = var.hub.east.tags
  location = var.hub.east.location
}

resource "azurerm_express_route_gateway" "hub-east" {
  location            = var.hub.east.location
  name                = var.hub.east.name
  resource_group_name = azurerm_resource_group.hub-east.name
  scale_units         = 1
  virtual_hub_id      = azurerm_virtual_hub.hub-east.id
  tags                = var.hub.east.tags
}

resource "azurerm_virtual_wan" "wan" {
  location                          = var.hub.east.location
  name                              = var.hub.east.name
  resource_group_name               = azurerm_resource_group.hub-east.name
  tags                              = var.hub.east.tags
  office365_local_breakout_category = "None"
}

resource "azurerm_virtual_hub" "hub-east" {
  virtual_wan_id      = azurerm_virtual_wan.wan.id
  resource_group_name = azurerm_resource_group.hub-east.name
  name                = var.hub.east.name
  location            = var.hub.east.location
  tags                = var.hub.east.tags
  address_prefix      = var.hub.east.ipspace
}

resource "azurerm_express_route_circuit_peering" "hub-east-azure-dc1" {
  resource_group_name        = "${azurerm_resource_group.hub-east.name}-azure-dc1"
  express_route_circuit_name = var.hub.east.name
  peering_type               = "AzurePrivatePeering"
  vlan_id                    = 300
}

resource "azurerm_express_route_connection" "hub-east" {
  name                             = var.hub.east.name
  express_route_gateway_id         = azurerm_express_route_gateway.hub-east.id
  express_route_circuit_peering_id = azurerm_express_route_circuit_peering.hub-east-azure-dc1.id
}

resource "azurerm_firewall" "hub-east" {
  location            = var.hub.east.location
  name                = var.hub.east.name
  resource_group_name = azurerm_resource_group.hub-east.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Basic"
  tags                = var.hub.east.tags

  virtual_hub {
    public_ip_count = 0
    virtual_hub_id  = azurerm_virtual_hub.hub-east.id
  }
  firewall_policy_id = azurerm_firewall_policy.hub-east.id
}


resource "azurerm_firewall_policy" "hub-east" {
  location            = var.hub.east.location
  name                = var.hub.east.name
  resource_group_name = azurerm_resource_group.hub-east.name
  tags                = var.hub.east.tags
}

resource "azurerm_virtual_network" "spoke" {
  address_space       = ["10.0.16.0/23"]
  location            = var.hub.east.location
  name                = "spoke"
  resource_group_name = azurerm_resource_group.hub-east.name
}


// Added to cause a scan result
resource "azurerm_network_security_rule" "name" {
  destination_address_prefixes = ["0.0.0.0/0"]
  protocol                     = "Tcp"
  source_address_prefix        = "0.0.0.0/0"
  destination_port_range       = "*"
  source_port_range            = "*"
  access                       = "Allow"
  direction                    = "Inbound"
  priority                     = 100
  resource_group_name          = azurerm_resource_group.hub-east.name
  network_security_group_name  = "tst"
  name                         = "test"
}
