#  XAUUSD risk mangment Dashboard

- url: https://www.tradingview.com/script/dncrDthz-XAUUSD-risk-mangment-Dashboard/
- type: indicator
- pine_id: PUB;3b8536040b804bf6979d14e51c1606b6
- version: 2.0

## Description

Dual Account Position Sizing Dashboard (XAUUSD / Forex)
Description
Managing risk across multiple accounts can be time-consuming, especially in fast-moving markets like Gold (XAUUSD). This indicator provides a clean, customizable on-chart HUD that calculates precise lot sizes for two separate accounts simultaneously, completely eliminating the need for external calculators.

Key Features:

Dual Account Tracking: Manage two distinct capital pools side-by-side. Set different account balances and risk parameters for each.

Custom Stop Loss Inputs: No more rigid grids. Simply type in the exact Stop Loss point distances your setup requires (e.g., "5, 7, 10, 15"), and the dashboard instantly builds the rows.

Flexible Risk Models: Choose between a Fixed USD amount or a % of Account Balance for your risk per trade.

Fully Customizable UI: Use the built-in color pickers to adjust the transparency, text color, and background of the dashboard to fit seamlessly over your dark or light charts. Choose exactly which corner it snaps to.

Why Position Sizing Matters
Having a solid strategy gives you an edge, but position sizing ensures your survival.

Trade the Structure: Proper sizing allows you to place your Stop Loss exactly where the chart structure invalidates your setup—not just where your wallet dictates. You simply adjust the lot size down to fit the wider stop.

Capital Preservation: Drawdowns are mathematically asymmetric; a 20% loss requires a 25% gain to recover. By strictly capping risk per trade, you protect your equity curve from catastrophic hits.

Emotional Neutrality: Knowing your exact monetary exposure before execution removes anxiety, preventing you from closing winners early or moving stops out of fear.

How to Use
Add the indicator to your chart.

Open the Settings (gear icon) to input your two account balances and desired risk.

Enter your target Stop Loss points as a comma-separated list (e.g., 5, 6, 8, 12).

Read the exact lot size required for your platform directly off the screen.

## Source Code

````pine
//@version=6
indicator("Multi-Account XAUUSD & Futures Dashboard", overlay=true)

// --- Account 1 Settings (e.g., 10k CFD) ---
grp1 = "Account 1 Settings"
show1 = input.bool(true, title="Show Account 1", group=grp1)
name1 = input.string("10k CFD", title="Account Name", group=grp1)
size1 = input.float(10000, title="Account Size ($)", group=grp1)
asset1 = input.string("Standard CFD (100 oz)", title="Asset Type", options=["Standard CFD (100 oz)", "Micro Futures (10 oz)"], group=grp1)
riskType1 = input.string("Fixed USD", title="Risk Type", options=["Fixed USD", "% of Account"], group=grp1)
riskVal1 = input.float(200, title="Risk Value", group=grp1)

// --- Account 2 Settings (e.g., 25k CFD) ---
grp2 = "Account 2 Settings"
show2 = input.bool(true, title="Show Account 2", group=grp2)
name2 = input.string("25k CFD", title="Account Name", group=grp2)
size2 = input.float(25000, title="Account Size ($)", group=grp2)
asset2 = input.string("Standard CFD (100 oz)", title="Asset Type", options=["Standard CFD (100 oz)", "Micro Futures (10 oz)"], group=grp2)
riskType2 = input.string("Fixed USD", title="Risk Type", options=["Fixed USD", "% of Account"], group=grp2)
riskVal2 = input.float(500, title="Risk Value", group=grp2)

// --- Account 3 Settings (e.g., 50k Future) ---
grp3 = "Account 3 Settings"
show3 = input.bool(true, title="Show Account 3", group=grp3)
name3 = input.string("50k Future", title="Account Name", group=grp3)
size3 = input.float(50000, title="Account Size ($)", group=grp3)
asset3 = input.string("Micro Futures (10 oz)", title="Asset Type", options=["Standard CFD (100 oz)", "Micro Futures (10 oz)"], group=grp3)
riskType3 = input.string("Fixed USD", title="Risk Type", options=["Fixed USD", "% of Account"], group=grp3)
riskVal3 = input.float(200, title="Risk Value", group=grp3)

// --- General Settings ---
grpGen = "General Settings"
slInput = input.string("5, 6, 7, 8, 10, 12, 15", title="Custom SL Points (comma separated)", group=grpGen)
tablePosition = input.string("Bottom Right", title="Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpGen)

// --- UI & Color Settings ---
grpUI = "UI & Color Settings"
headerBgColor = input.color(color.new(color.blue, 70), title="Header Background", group=grpUI)
riskBgColor   = input.color(color.new(color.gray, 80), title="Risk Row Background", group=grpUI)
rowBgColor    = input.color(color.new(color.black, 80), title="Data Row Background", group=grpUI)
textColor     = input.color(color.white, title="Text Color", group=grpUI)
borderColor   = input.color(color.new(color.gray, 50), title="Border Color", group=grpUI)

// --- Calculations ---
getMult(type) => type == "Micro Futures (10 oz)" ? 10.0 : 100.0
getRisk(rType, rVal, aSize) => rType == "Fixed USD" ? rVal : (aSize * rVal / 100)

// Calculate lots and format based on asset type (whole numbers + raw decimal in brackets for futures)
formatLots(riskAmount, slPts, multiplier, assetTypeStr) =>
    rawLots = riskAmount / (slPts * multiplier)
    if assetTypeStr == "Micro Futures (10 oz)"
        str.tostring(math.floor(rawLots), "0") + " (" + str.tostring(rawLots, "#.##") + ")"
    else
        str.tostring(rawLots, "#.##")

mult1 = getMult(asset1)
mult2 = getMult(asset2)
mult3 = getMult(asset3)

riskUSD1 = getRisk(riskType1, riskVal1, size1)
riskUSD2 = getRisk(riskType2, riskVal2, size2)
riskUSD3 = getRisk(riskType3, riskVal3, size3)

// --- Dashboard Rendering ---
var string pos = tablePosition == "Top Right" ? position.top_right : 
                 tablePosition == "Top Left" ? position.top_left : 
                 tablePosition == "Bottom Right" ? position.bottom_right : position.bottom_left
                 
// Table initialized with 4 columns maximum
var table dash = table.new(pos, 4, 20, border_width = 1, border_color=borderColor)

if barstate.islast
    slArray = str.split(slInput, ",")
    int numSLs = array.size(slArray)
    
    if numSLs > 18
        numSLs := 18

    // Track dynamic column indices so empty accounts collapse seamlessly
    int c1 = -1
    int c2 = -1
    int c3 = -1
    int curCol = 1
    
    // SL Header (Column 0)
    table.cell(dash, 0, 0, "SL (Pts)", bgcolor=headerBgColor, text_color=textColor, text_halign=text.align_center)
    
    // Account Headers
    if show1
        c1 := curCol
        table.cell(dash, c1, 0, name1, bgcolor=headerBgColor, text_color=textColor, text_halign=text.align_center)
        curCol += 1
    if show2
        c2 := curCol
        table.cell(dash, c2, 0, name2, bgcolor=headerBgColor, text_color=textColor, text_halign=text.align_center)
        curCol += 1
    if show3
        c3 := curCol
        table.cell(dash, c3, 0, name3, bgcolor=headerBgColor, text_color=textColor, text_halign=text.align_center)
        curCol += 1
        
    // Risk Row
    table.cell(dash, 0, 1, "Risk:", bgcolor=riskBgColor, text_color=textColor, text_halign=text.align_center)
    if show1
        table.cell(dash, c1, 1, "$" + str.tostring(riskUSD1, "#.##"), bgcolor=riskBgColor, text_color=textColor, text_halign=text.align_center)
    if show2
        table.cell(dash, c2, 1, "$" + str.tostring(riskUSD2, "#.##"), bgcolor=riskBgColor, text_color=textColor, text_halign=text.align_center)
    if show3
        table.cell(dash, c3, 1, "$" + str.tostring(riskUSD3, "#.##"), bgcolor=riskBgColor, text_color=textColor, text_halign=text.align_center)

    // Populate SL & Lot Data Rows
    if numSLs > 0
        for i = 0 to numSLs - 1
            cleanStr = str.replace_all(array.get(slArray, i), " ", "")
            slValue = str.tonumber(cleanStr)
            
            if not na(slValue) and slValue > 0
                rowIdx = i + 2
                table.cell(dash, 0, rowIdx, str.tostring(slValue), bgcolor=rowBgColor, text_color=textColor, text_halign=text.align_center)
                
                if show1
                    lotsStr1 = formatLots(riskUSD1, slValue, mult1, asset1)
                    table.cell(dash, c1, rowIdx, lotsStr1, bgcolor=rowBgColor, text_color=textColor, text_halign=text.align_center)
                if show2
                    lotsStr2 = formatLots(riskUSD2, slValue, mult2, asset2)
                    table.cell(dash, c2, rowIdx, lotsStr2, bgcolor=rowBgColor, text_color=textColor, text_halign=text.align_center)
                if show3
                    lotsStr3 = formatLots(riskUSD3, slValue, mult3, asset3)
                    table.cell(dash, c3, rowIdx, lotsStr3, bgcolor=rowBgColor, text_color=textColor, text_halign=text.align_center)
````
