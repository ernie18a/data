# [Strategy Alert Webhook Demo] Buy One Sell One

- url: https://www.tradingview.com/script/TCsd7tB4-Strategy-Alert-Webhook-Demo-Buy-One-Sell-One/
- type: strategy
- pine_id: PUB;081e5320eb14484c9e7bccd396bae1c2
- version: 2.0

## Description

[b][Strategy Alert Webhook Demo] Buy One Sell One[/b]

Two Options to send Alert Order via Webhook

[b]1. Order fill events with `alert_message` on strategy.close(), strategy.entry(), strategy.exit() and strategy.order() 
[/b]
[i]NOTE: Need to fill the Alert Creation box with `{{strategy.order.alert_message}}`
[/i]
[b]2. Send Alert through `alert()`[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Crypto-Arsenal

//@version=5
strategy("Buy One Sell One", overlay = false, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

CONNECTOR_NAME = 'YOUR_CONNECTOR_NAME'
CONNECTOR_TOKEN = 'YOUR_CONNECTOR_TOKEN'

percent = str.tostring(10)
cls = str.tostring(close)
tp = str.tostring(strategy.position_avg_price * (1 + 0.1))
sl = str.tostring(strategy.position_avg_price * (1 - 0.1))
    
if(bar_index % 2 == 0)
    // DEMO FOR SENDING MESSAGE WITH alert_message()
    // NEED TO ADD {{{strategy.order.alert_message}} to Message field at Create Alert box 
    
    // Add "limit" to open a LIMIT order instead of default MARKET
    alert_message = '{"action":"openLong","percent":"' + percent + '","profit":"' + tp + '","loss":"' + sl + '","connectorName":"' + CONNECTOR_NAME + '","connectorToken":"' + CONNECTOR_TOKEN + '","log":"Open Long at price:' + cls + '"}'
    strategy.entry('Enter Long',  strategy.long, alert_message = alert_message)
else
    // DEMO FOR SENDING MESSAGE WITH alert() 

    strategy.entry('Enter Short', strategy.short)
    // Add "limit" to open a LIMIT order instead of default MARKET
    alert_message = '{"action":"closeLong","percent":"' + percent + '","profit":"' + sl + '","loss":"' + tp + '","connectorName":"' + CONNECTOR_NAME + '","connectorToken":"' + CONNECTOR_TOKEN + '","log":"Close long at price:' + cls + '"}'
    alert(alert_message, alert.freq_once_per_bar)
````
