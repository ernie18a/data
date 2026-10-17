# Current Timeframe Display

- url: https://www.tradingview.com/script/p8ijsHXf-Current-Timeframe-Display/
- type: indicator
- pine_id: PUB;20cb600fe1b64b7cb3662a26d99db961
- version: 1.0

## Description

This script displays the currently selected chart timeframe directly on the chart for quick reference. It helps traders stay aware of their active timeframe without needing to check the toolbar.

Useful when switching between multiple timeframes or during fast-paced analysis.

## Source Code

````pine
//@version=5
indicator("Current Timeframe Display", overlay=true)

var table tf_table = table.new(position.top_center, 1, 3)

table.cell(tf_table, 0, 0, "", text_size=size.small, bgcolor=color.new(color.black, 100))
table.cell(tf_table, 0, 1, "", text_size=size.small, bgcolor=color.new(color.black, 100))
table.cell(tf_table, 0, 2, timeframe.period, 
     text_size=size.huge, 
     text_color=color.white, 
     bgcolor=color.new(color.black, 30))
````
