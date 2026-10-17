# Futures Tick & Point Specs

- url: https://www.tradingview.com/script/wJciecfD-Futures-Tick-Point-Specs/
- type: indicator
- pine_id: PUB;c4f9deb7b1e3404cb82acfb1c538a10d
- version: 2.0

## Description

Futures Tick & Point Specs is a professional futures trading utility that provides instant access to critical contract specifications directly on your TradingView chart.

The indicator displays verified contract information for a wide range of futures markets, including equity indexes, commodities, currencies, treasuries, agricultural products, and livestock contracts.

Instead of searching exchange specification sheets or calculating contract values manually, traders can instantly view:

* Tick Size
* Tick Value
* Point Value
* Risk Per Contract (optional)
* Contract Category
* Verified Contract Specifications

The indicator automatically updates as you switch between futures markets and provides a clean, customizable table that can be positioned anywhere on the chart.

*Key Features*

✓ Verified contract specifications for major futures products

✓ Instant display of tick size, tick value, and point value

✓ Built-in risk calculator based on user-defined stop size

✓ Adjustable table position

✓ Customizable colors and text sizes

✓ Compact, Standard, and Detailed display modes

✓ Supports equity index, energy, metals, currency, treasury, grain, and livestock futures

Designed For:

* Futures traders
* Prop firm traders
* Day traders
* Swing traders
* Multi-market traders
* Traders learning futures contract specifications

Whether you're trading ES, NQ, CL, GC, 6E, ZC, ZW, NG, or dozens of other futures products, Futures Tick & Point Specs provides the information you need directly on the chart so you can make faster and more informed trading decisions.

## Source Code

````pine
//@version=6
indicator("Futures Contract Info Grid", overlay=true)

// Inputs
tablePositionInput = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])
textSizeInput = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
displayMode = input.string("Standard", "Display Mode", options=["Compact", "Standard", "Detailed"])
showRiskCalc = input.bool(true, "Show Risk Calculator")
stopTicks = input.int(10, "Stop Size in Ticks", minval=1)

bgColor = input.color(color.new(color.black, 10), "Table Background")
headerColor = input.color(color.new(color.blue, 0), "Header Color")
labelColor = input.color(color.new(color.gray, 20), "Label Cell Color")
valueColor = input.color(color.new(color.teal, 0), "Value Cell Color")
statusVerifiedColor = input.color(color.new(color.green, 0), "Verified Status Color")
statusFallbackColor = input.color(color.new(color.orange, 0), "Fallback Status Color")
textColor = input.color(color.white, "Text Color")
borderColor = input.color(color.new(color.white, 35), "Border Color")

tablePosition = tablePositionInput == "Top Left" ? position.top_left : tablePositionInput == "Top Center" ? position.top_center : tablePositionInput == "Top Right" ? position.top_right : tablePositionInput == "Middle Left" ? position.middle_left : tablePositionInput == "Middle Center" ? position.middle_center : tablePositionInput == "Middle Right" ? position.middle_right : tablePositionInput == "Bottom Left" ? position.bottom_left : tablePositionInput == "Bottom Center" ? position.bottom_center : position.bottom_right
textSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Large" ? size.large : textSizeInput == "Huge" ? size.huge : size.normal

root = syminfo.root

isVerified(string r) =>
    switch r
        "ES" => true
        "MES" => true
        "NQ" => true
        "MNQ" => true
        "YM" => true
        "MYM" => true
        "RTY" => true
        "M2K" => true
        "CL" => true
        "MCL" => true
        "NG" => true
        "MNG" => true
        "RB" => true
        "HO" => true
        "GC" => true
        "MGC" => true
        "SI" => true
        "SIL" => true
        "HG" => true
        "PL" => true
        "PA" => true
        "6E" => true
        "M6B" => true
        "M6E" => true
        "6B" => true
        "6J" => true
        "6A" => true
        "6C" => true
        "6S" => true
        "6M" => true
        "ZB" => true
        "ZN" => true
        "ZF" => true
        "ZT" => true
        "UB" => true
        "ZC" => true
        "ZW" => true
        "ZS" => true
        "ZM" => true
        "ZL" => true
        "ZO" => true
        "KE" => true
        "XC" => true
        "XK" => true
        "XW" => true
        "LE" => true
        "HE" => true
        "GF" => true
        => false

getCategory(string r) =>
    switch r
        "ES" => "Equity Index"
        "MES" => "Equity Index"
        "NQ" => "Equity Index"
        "MNQ" => "Equity Index"
        "YM" => "Equity Index"
        "MYM" => "Equity Index"
        "RTY" => "Equity Index"
        "M2K" => "Equity Index"
        "CL" => "Energy"
        "MCL" => "Energy"
        "NG" => "Energy"
        "MNG" => "Energy"
        "RB" => "Energy"
        "HO" => "Energy"
        "GC" => "Metals"
        "MGC" => "Metals"
        "SI" => "Metals"
        "SIL" => "Metals"
        "HG" => "Metals"
        "PL" => "Metals"
        "PA" => "Metals"
        "6E" => "Currency"
        "M6B" => "Currency"
        "M6E" => "Currency"
        "6B" => "Currency"
        "6J" => "Currency"
        "6A" => "Currency"
        "6C" => "Currency"
        "6S" => "Currency"
        "6M" => "Currency"
        "ZB" => "Treasury"
        "ZN" => "Treasury"
        "ZF" => "Treasury"
        "ZT" => "Treasury"
        "UB" => "Treasury"
        "ZC" => "Grains"
        "ZW" => "Grains"
        "ZS" => "Grains"
        "ZM" => "Grains"
        "ZL" => "Grains"
        "ZO" => "Grains"
        "KE" => "Grains"
        "XC" => "Mini Grains"
        "XK" => "Mini Grains"
        "XW" => "Mini Grains"
        "LE" => "Livestock"
        "HE" => "Livestock"
        "GF" => "Livestock"
        => "TradingView Data"

getTickSize(string r) =>
    switch r
        "ES" => 0.25
        "MES" => 0.25
        "NQ" => 0.25
        "MNQ" => 0.25
        "YM" => 1.0
        "MYM" => 1.0
        "RTY" => 0.1
        "M2K" => 0.1
        "CL" => 0.01
        "MCL" => 0.01
        "NG" => 0.001
        "MNG" => 0.001
        "RB" => 0.0001
        "HO" => 0.0001
        "GC" => 0.1
        "MGC" => 0.1
        "SI" => 0.005
        "SIL" => 0.005
        "HG" => 0.0005
        "PL" => 0.1
        "PA" => 0.5
        "6E" => 0.00005
        "M6E" => 0.0001
        "M6B" => 0.0001
        "6B" => 0.0001
        "6J" => 0.0000005
        "6A" => 0.00005
        "6C" => 0.00005
        "6S" => 0.00005
        "6M" => 0.00001
        "ZB" => 0.03125
        "ZN" => 0.015625
        "ZF" => 0.0078125
        "ZT" => 0.00390625
        "UB" => 0.03125
        "ZC" => 0.25
        "ZW" => 0.25
        "ZS" => 0.25
        "ZM" => 0.1
        "ZL" => 0.01
        "ZO" => 0.25
        "KE" => 0.25
        "XC" => 0.00125
        "XK" => 0.00125
        "XW" => 0.00125
        "LE" => 0.025
        "HE" => 0.025
        "GF" => 0.025
        => syminfo.mintick

getTickValue(string r) =>
    switch r
        "ES" => 12.50
        "MES" => 1.25
        "NQ" => 5.00
        "MNQ" => 0.50
        "YM" => 5.00
        "MYM" => 0.50
        "RTY" => 5.00
        "M2K" => 0.50
        "CL" => 10.00
        "MCL" => 1.00
        "NG" => 10.00
        "MNG" => 1.00
        "RB" => 4.20
        "HO" => 4.20
        "GC" => 10.00
        "MGC" => 1.00
        "SI" => 25.00
        "SIL" => 5.00
        "HG" => 12.50
        "PL" => 5.00
        "PA" => 50.00
        "6E" => 6.25
        "M6E" => 1.25
        "6B" => 6.25
        "M6B" => 0.625
        "6J" => 6.25
        "6A" => 5.00
        "6C" => 5.00
        "6S" => 6.25
        "6M" => 5.00
        "ZB" => 31.25
        "ZN" => 15.625
        "ZF" => 7.8125
        "ZT" => 7.8125
        "UB" => 31.25
        "ZC" => 12.50
        "ZW" => 12.50
        "ZS" => 12.50
        "ZM" => 10.00
        "ZL" => 6.00
        "ZO" => 12.50
        "KE" => 12.50
        "XC" => 1.25
        "XK" => 1.25
        "XW" => 1.25
        "LE" => 10.00
        "HE" => 10.00
        "GF" => 12.50
        => syminfo.mintick * syminfo.pointvalue

getPointValue(string r) =>
    switch r
        "ES" => 50.0
        "MES" => 5.0
        "NQ" => 20.0
        "MNQ" => 2.0
        "YM" => 5.0
        "MYM" => 0.5
        "RTY" => 50.0
        "M2K" => 5.0
        "CL" => 1000.0
        "MCL" => 100.0
        "NG" => 10000.0
        "MNG" => 1000.0
        "RB" => 42000.0
        "HO" => 42000.0
        "GC" => 100.0
        "MGC" => 10.0
        "SI" => 5000.0
        "SIL" => 1000.0
        "HG" => 25000.0
        "PL" => 50.0
        "PA" => 100.0
        "6E" => 125000.0
        "M6E" => 12500.0
        "6B" => 62500.0
        "M6B" => 6250.0
        "6J" => 12500000.0
        "6A" => 100000.0
        "6C" => 100000.0
        "6S" => 125000.0
        "6M" => 500000.0
        "ZB" => 1000.0
        "ZN" => 1000.0
        "ZF" => 1000.0
        "ZT" => 2000.0
        "UB" => 1000.0
        "ZC" => 50.0
        "ZW" => 50.0
        "ZS" => 50.0
        "ZM" => 100.0
        "ZL" => 600.0
        "ZO" => 50.0
        "KE" => 50.0
        "XC" => 1000.0
        "XK" => 1000.0
        "XW" => 1000.0
        "LE" => 400.0
        "HE" => 400.0
        "GF" => 500.0
        => syminfo.pointvalue

tickSize = getTickSize(root)
tickValue = getTickValue(root)
pointValue = getPointValue(root)
riskPerContract = stopTicks * tickValue
verified = isVerified(root)
category = getCategory(root)
statusText = verified ? "Verified" : "TV Fallback"
statusColor = verified ? statusVerifiedColor : statusFallbackColor

tickSizeText = str.tostring(tickSize, "0.########")
tickValueText = tickValue < 1 ? "$" + str.format("{0,number,#,###.000}", tickValue) : "$" + str.format("{0,number,#,###.00}", tickValue)
pointValueText = "$" + str.format("{0,number,#,###.00}", pointValue)
riskText = "$" + str.format("{0,number,#,###.00}", riskPerContract)
stopTicksText = str.tostring(stopTicks) + " ticks"

rows = displayMode == "Detailed" and showRiskCalc ? 7 : displayMode == "Detailed" and not showRiskCalc ? 6 : displayMode == "Standard" and showRiskCalc ? 5 : 4

var table infoTable = table.new(tablePosition, 2, rows, bgcolor=bgColor, frame_color=borderColor, frame_width=1, border_color=borderColor, border_width=1)

if barstate.islast
    table.clear(infoTable, 0, 0, 1, rows - 1)

    table.cell(infoTable, 0, 0, "FUTURES SPECS", bgcolor=headerColor, text_color=textColor, text_size=textSize, text_halign=text.align_center)
    table.cell(infoTable, 1, 0, syminfo.ticker, bgcolor=headerColor, text_color=textColor, text_size=textSize, text_halign=text.align_center)

    table.cell(infoTable, 0, 1, "Tick Size", bgcolor=labelColor, text_color=textColor, text_size=textSize)
    table.cell(infoTable, 1, 1, tickSizeText, bgcolor=valueColor, text_color=textColor, text_size=textSize)

    table.cell(infoTable, 0, 2, "Tick Value", bgcolor=labelColor, text_color=textColor, text_size=textSize)
    table.cell(infoTable, 1, 2, tickValueText, bgcolor=valueColor, text_color=textColor, text_size=textSize)

    table.cell(infoTable, 0, 3, "Point Value", bgcolor=labelColor, text_color=textColor, text_size=textSize)
    table.cell(infoTable, 1, 3, pointValueText, bgcolor=valueColor, text_color=textColor, text_size=textSize)

    nextRow = 4

    if displayMode == "Detailed"
        table.cell(infoTable, 0, nextRow, "Category", bgcolor=labelColor, text_color=textColor, text_size=textSize)
        table.cell(infoTable, 1, nextRow, category, bgcolor=valueColor, text_color=textColor, text_size=textSize)
        nextRow += 1

        table.cell(infoTable, 0, nextRow, "Status", bgcolor=labelColor, text_color=textColor, text_size=textSize)
        table.cell(infoTable, 1, nextRow, statusText, bgcolor=statusColor, text_color=textColor, text_size=textSize)
        nextRow += 1

    if showRiskCalc and displayMode != "Compact"
        table.cell(infoTable, 0, nextRow, "Risk / Contract", bgcolor=labelColor, text_color=textColor, text_size=textSize)
        table.cell(infoTable, 1, nextRow, riskText + " @ " + stopTicksText, bgcolor=valueColor, text_color=textColor, text_size=textSize)
````
