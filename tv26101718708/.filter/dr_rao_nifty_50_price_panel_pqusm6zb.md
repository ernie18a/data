# Dr RAO NIFTY 50 Price Panel

- url: https://www.tradingview.com/script/PQUsm6zb-Dr-RAO-NIFTY-50-Price-Panel/
- type: indicator
- pine_id: PUB;cfc7b3d3547f465aa0e1c5bf7a4e9b4b
- version: 1.0

## Description

It displays and updates the NIFTY 50 index on real time basis

## Source Code

````pine
//@version=5
indicator("NIFTY 50 Price Panel", overlay=true)

// Fetch NIFTY 50 data
nifty = request.security("NSE:NIFTY", timeframe.period, close)
prevClose = request.security("NSE:NIFTY", "D", close[1])
dayHigh = request.security("NSE:NIFTY", "D", high)
dayLow  = request.security("NSE:NIFTY", "D", low)

// Calculate change
change = nifty - prevClose
changePct = (change / prevClose) * 100

// Create table (top-right)
var table t = table.new(position.top_right, 1, 4, border_width=1)

// Format values
priceText   = "Price: " + str.tostring(nifty, format.mintick)
changeText  = "Change: " + str.tostring(change, format.mintick) + 
              " (" + str.tostring(changePct, "#.##") + "%)"
highText    = "Day High: " + str.tostring(dayHigh, format.mintick)
lowText     = "Day Low: " + str.tostring(dayLow, format.mintick)

// Color for change
chgColor = change >= 0 ? color.green : color.red

// Update table
if barstate.islast
    table.cell(t, 0, 0, priceText, text_color=color.white, bgcolor=color.blue, text_size=size.large)
    table.cell(t, 0, 1, changeText, text_color=color.white, bgcolor=chgColor, text_size=size.large)
    table.cell(t, 0, 2, highText, text_color=color.white, bgcolor=color.green, text_size=size.large)
    table.cell(t, 0, 3, lowText, text_color=color.white, bgcolor=color.red, text_size=size.large)
````
