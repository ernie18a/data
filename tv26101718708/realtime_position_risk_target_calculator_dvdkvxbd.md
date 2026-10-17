# Real-Time Position, Risk & Target Calculator

- url: https://www.tradingview.com/script/dVDKVxbd-Real-Time-Position-Risk-Target-Calculator/
- type: indicator
- pine_id: PUB;c02fd9a520264ef9936e782901638199
- version: 2.0

## Description

Real-Time Position, Risk & Target Calculator
Summary
Real-Time Position, Risk & Target Calculator is an all-in-one risk management, position sizing, and profit target tool built directly for active crypto and futures traders.

Instead of opening external calculators or scrambling with mental math during fast market moves, this indicator displays a live, customizable dashboard on your chart. Every single section, metric, and visual element is 100% adjustable, and table sections can be individually hidden or toggled to keep your chart layout as minimal or detailed as you prefer.

Key Features
Modular & Customizable Layout (Toggle/Hide Any Section)

Show or hide entire table sections (e.g., Profit Targets or ATR Trail Stats) with simple checkboxes to declutter your screen.

Full control over table position (8 chart placement locations), text size, grid line borders, and custom background colors for each header section.

Toggle on/off on-chart target lines and Supertrend buy/sell flip markers.

Instant Position Sizing & Risk Engine

Sizes your position (QTY) and total USDT market value based on your account size and preferred risk model (Fixed % or Fixed USDT).

Uses a custom Supertrend line as an automated Stop Loss anchor with fully adjustable length, multiplier, and source parameters.

Multi-Leverage Margin Breakdown

Compares 4 customizable leverage tiers (e.g., 2x, 5x, 10x, 15x) side-by-side.

Shows required USDT margin and percentage of account balance used for each setting.

Automatically highlights over-leveraged setups in red when required margin exceeds your total account size.

Displays the exact Min Lev Needed to open the position within your current balance.

Dynamic Profit Targets (+1%, +2%, Custom %)

Automatically calculates exact price levels and dollar returns for +1% account gain, +2% account gain, and a Custom % target (adjustable step-by-step in settings).

Displays target price levels inside the table matrix and optionally projects TP target lines directly onto your price chart. 


ATR Trailing Stop Analytics

Tracks live trend momentum using a dual Fast/Slow ATR Trailing Stop engine with fully adjustable ATR periods and factors.

Displays current trail signal (BUY/SELL), candles elapsed since the signal flip, entry signal price, floating trade profit/loss %, and distance % to support/resistance.

How to Use
Input Account Data: Enter your account balance (e.g., 10000 USDT) and set your risk mode (% or USDT).

Customize Your View: Toggle off any table sections or chart lines you don't need (like Profit Targets or ATR Stats) to keep your workspace clean.

Set Leverage Tiers: Customize your 4 leverage options to quickly compare margin requirements across different settings.

Check Position Metrics: Use Position QTY, Position Value, and Min Lev Needed to execute precise orders directly on your exchange.

Scale Out at Targets: Reference the calculated TP price levels or on-chart target lines to set limit orders for take-profit targets.

Credits & Acknowledgments
ATR Trailing Stop Engine: The dual-ATR tracking mechanics used in the stats section are adapted from the popular ATR Trailing Stop indicator by ceyhun.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © itsjustAL

//@version=6
indicator("Real-Time Position, Risk & Target Calculator", shorttitle="Real-Time Position", overlay=true)

// --- Inputs ---
accountSize = input.float(10000, title="Account Size (USDT)", group="Account & Risk")
riskMode    = input.string("%", title="Risk Mode", options=["%", "USDT"], group="Account & Risk")
riskValue   = input.float(1.0, title="Risk Amount", step=0.1, group="Account & Risk")

stSource    = input.source(close, title="Supertrend Source", group="Supertrend SL")
stLength    = input.int(10, title="Supertrend Length", group="Supertrend SL")
stFactor    = input.float(3.0, title="Supertrend Multiplier", step=0.1, group="Supertrend SL")
showSignals = input.bool(true, title="Show Buy/Sell Markers on Flip", group="Supertrend SL")

// Target Levels Inputs (Risk Multiples R:R)
target1R        = input.float(1.0, title="Target 1 Risk Multiple (1R)", step=0.5, group="Target / TP Levels")
target2R        = input.float(2.0, title="Target 2 Risk Multiple (2R)", step=0.5, group="Target / TP Levels")
target3R        = input.float(3.0, title="Target 3 Risk Multiple (Custom R)", step=0.5, group="Target / TP Levels")
showTargetTable = input.bool(true, title="Show Profit Targets in Table", group="Target / TP Levels")
plotTargets     = input.bool(true, title="Plot Target Lines on Chart", group="Target / TP Levels")

// ATR Trailing Stop Stats Inputs
showStatsTable = input.bool(true, title="Show ATR Trail Stats in Table", group="ATR Trail Stats")
ap1            = input.int(5, title="Fast ATR Period", group="ATR Trail Stats")
af1            = input.float(0.5, title="Fast ATR Multiplier", step=0.1, group="ATR Trail Stats")
ap2            = input.int(10, title="Slow ATR Period", group="ATR Trail Stats")
af2            = input.float(3.0, title="Slow ATR Multiplier", step=0.1, group="ATR Trail Stats")

// Comparison Leverage Inputs
lev1 = input.int(2, title="Leverage Option 1", minval=1, group="Leverage Comparison")
lev2 = input.int(5, title="Leverage Option 2", minval=1, group="Leverage Comparison")
lev3 = input.int(10, title="Leverage Option 3", minval=1, group="Leverage Comparison")
lev4 = input.int(15, title="Leverage Option 4", minval=1, group="Leverage Comparison")

// Display Settings
tblPosInput   = input.string("Top Right", title="Table Position", options=["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left", "Bottom Center", "Middle Right", "Middle Left"], group="Display Settings")
tblSizeInput  = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group="Display Settings")

// Section Header Colors
accountRowBg  = input.color(color.new(color.blue, 75), title="Account Size Header BG", group="Section Header Colors")
leverageRowBg = input.color(color.new(color.teal, 75), title="Leverage Header BG", group="Section Header Colors")
targetsRowBg  = input.color(color.new(color.green, 75), title="Profit Targets Header BG", group="Section Header Colors")
statsRowBg    = input.color(color.new(color.purple, 75), title="ATR Trail Stats Header BG", group="Section Header Colors")

// Table Border Styling
frameColor    = input.color(color.gray, title="Outer Border Color", group="Display Settings")
frameWidth    = input.int(2, title="Outer Border Thickness", minval=0, maxval=10, group="Display Settings")
gridColor     = input.color(color.new(color.gray, 60), title="Inner Grid Color", group="Display Settings")
gridWidth     = input.int(1, title="Inner Grid Thickness", minval=0, maxval=10, group="Display Settings")

// Map Display Position
getPos(p) =>
    switch p
        "Top Right"      => position.top_right
        "Top Left"       => position.top_left
        "Top Center"     => position.top_center
        "Bottom Right"   => position.bottom_right
        "Bottom Left"    => position.bottom_left
        "Bottom Center"  => position.bottom_center
        "Middle Right"   => position.middle_right
        "Middle Left"    => position.middle_left
        => position.top_right

// Map Text Size
getSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Auto"   => size.auto
        => size.small

tblPos  = getPos(tblPosInput)
tblSize = getSize(tblSizeInput)

// Global Helper Function for Table Cells with Background Color support
f_cell(table t, int col, int row, string txt, color txtColor, string halign, string txtSize, color bgColor = na) =>
    table.cell(t, col, row, txt, text_color=txtColor, text_halign=halign, text_size=txtSize, bgcolor=bgColor)

// --- Custom Supertrend Math ---
atr = ta.atr(stLength)
up = stSource - (stFactor * atr)
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up

dn = stSource + (stFactor * atr)
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn

var int trend = 1
trend := nz(trend[1], 1)
trend := trend == -1 and close > dn1 ? 1 : (trend == 1 and close < up1 ? -1 : trend)

st = trend == 1 ? up : dn
dir = trend == 1 ? -1 : 1

// Signal Flips
bullFlip = trend == 1 and trend[1] == -1
bearFlip = trend == -1 and trend[1] == 1

// Supertrend Line Plot
plot(st, color=dir == 1 ? color.red : color.green, style=plot.style_line, title="Supertrend SL", linewidth=2)

// Buy / Sell Markers on Flip
plotshape(showSignals and bullFlip, title="Buy Signal", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY", textcolor=color.white, size=size.small)
plotshape(showSignals and bearFlip, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.white, size=size.small)

// --- ATR Trailing Stop Calculations (Stats Section Logic) ---
sl1 = af1 * ta.atr(ap1)
var float trail1 = 0.0
iff_1 = stSource > nz(trail1[1], 0) ? stSource - sl1 : stSource + sl1
iff_2 = stSource < nz(trail1[1], 0) and stSource[1] < nz(trail1[1], 0) ? math.min(nz(trail1[1], 0), stSource + sl1) : iff_1
trail1 := stSource > nz(trail1[1], 0) and stSource[1] > nz(trail1[1], 0) ? math.max(nz(trail1[1], 0), stSource - sl1) : iff_2

sl2 = af2 * ta.atr(ap2)
var float trail2 = 0.0
iff_3 = stSource > nz(trail2[1], 0) ? stSource - sl2 : stSource + sl2
iff_4 = stSource < nz(trail2[1], 0) and stSource[1] < nz(trail2[1], 0) ? math.min(nz(trail2[1], 0), stSource + sl2) : iff_3
trail2 := stSource > nz(trail2[1], 0) and stSource[1] > nz(trail2[1], 0) ? math.max(nz(trail2[1], 0), stSource - sl2) : iff_4

atrBuy  = ta.crossover(trail1, trail2)
atrSell = ta.crossunder(trail1, trail2)

sr = trail1 > trail2 ? 1 : (trail2 > trail1 ? -1 : 0)
isAtrLong = sr == 1

barsSinceAtrSignal = isAtrLong ? ta.barssince(atrBuy) : ta.barssince(atrSell)
atrSignalPrice     = isAtrLong ? ta.valuewhen(atrBuy, stSource, 0) : ta.valuewhen(atrSell, stSource, 0)

atrProfitPct = isAtrLong ? ((stSource - atrSignalPrice) / atrSignalPrice) * 100 : ((atrSignalPrice - stSource) / atrSignalPrice) * 100
atrDistPct   = ((close - trail2) / trail2) * 100

// --- Risk & Position Math ---
price = close
slDistance = math.abs(price - st)

// Dollar risk calculation
riskAmountUSDT = riskMode == "%" ? (accountSize * (riskValue / 100)) : riskValue
effectiveRiskPct = (riskAmountUSDT / accountSize) * 100

// Position sizing based on distance to Supertrend SL
posQty = slDistance > 0 ? (riskAmountUSDT / slDistance) : 0
posValueUSDT = posQty * price

isLong = trend == 1

// Profit Target Calculations (Based on Risk Multiples R:R)
tp1Price = isLong ? price + (slDistance * target1R) : price - (slDistance * target1R)
tp2Price = isLong ? price + (slDistance * target2R) : price - (slDistance * target2R)
tp3Price = isLong ? price + (slDistance * target3R) : price - (slDistance * target3R)

tp1Dollar = riskAmountUSDT * target1R
tp2Dollar = riskAmountUSDT * target2R
tp3Dollar = riskAmountUSDT * target3R

tp1Pct = effectiveRiskPct * target1R
tp2Pct = effectiveRiskPct * target2R
tp3Pct = effectiveRiskPct * target3R

// Plot Target Lines on Chart
plot(plotTargets ? tp1Price : na, color=color.new(color.teal, 30), style=plot.style_linebr, title="Target 1 Line", linewidth=1)
plot(plotTargets ? tp2Price : na, color=color.new(color.green, 20), style=plot.style_linebr, title="Target 2 Line", linewidth=1)
plot(plotTargets ? tp3Price : na, color=color.new(color.lime, 0), style=plot.style_linebr, title="Target 3 Line", linewidth=2)

// Leverage Calculations
margin1 = posValueUSDT / lev1
margin2 = posValueUSDT / lev2
margin3 = posValueUSDT / lev3
margin4 = posValueUSDT / lev4

marginPct1 = (margin1 / accountSize) * 100
marginPct2 = (margin2 / accountSize) * 100
marginPct3 = (margin3 / accountSize) * 100
marginPct4 = (margin4 / accountSize) * 100

// Minimum leverage required to open position within 100% account balance
minLev = posValueUSDT / accountSize

// --- Dynamic Table Setup ---
var table tbl = na

if barstate.islast
    table.delete(tbl)
    
    // Calculate total rows dynamically based on section toggles
    int totalRows = 11 + (showTargetTable ? 4 : 0) + (showStatsTable ? 6 : 0)
    
    tbl := table.new(tblPos, 3, totalRows, bgcolor=color.new(color.black, 85), frame_color=frameColor, frame_width=frameWidth, border_color=gridColor, border_width=gridWidth)

    int r = 0

    // 1. Trade Overview Section (Account Size Row Highlighted)
    f_cell(tbl, 0, r, "Account Size", color.white, text.align_left, tblSize, accountRowBg)
    f_cell(tbl, 1, r, str.tostring(accountSize, "#.##") + " USDT", color.white, text.align_right, tblSize, accountRowBg)
    f_cell(tbl, 2, r, "", color.white, text.align_left, tblSize, accountRowBg)
    r += 1
    
    f_cell(tbl, 0, r, "Risk (" + str.tostring(riskValue) + riskMode + ")", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(riskAmountUSDT, "#.##") + " USDT", color.red, text.align_right, tblSize)
    f_cell(tbl, 2, r, "", color.white, text.align_left, tblSize)
    r += 1

    f_cell(tbl, 0, r, "Stop Loss (ST)", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(st, "#.####"), dir == 1 ? color.red : color.green, text.align_right, tblSize)
    f_cell(tbl, 2, r, "", color.white, text.align_left, tblSize)
    r += 1

    f_cell(tbl, 0, r, "Position QTY", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(posQty, "#.####"), color.yellow, text.align_right, tblSize)
    f_cell(tbl, 2, r, "", color.white, text.align_left, tblSize)
    r += 1

    f_cell(tbl, 0, r, "Position Value", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(posValueUSDT, "#.##") + " USDT", color.yellow, text.align_right, tblSize)
    f_cell(tbl, 2, r, "", color.white, text.align_left, tblSize)
    r += 1

    f_cell(tbl, 0, r, "Min Lev Needed", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(minLev, "#.##") + "x", color.orange, text.align_right, tblSize)
    f_cell(tbl, 2, r, "", color.white, text.align_left, tblSize)
    r += 1

    // 2. Leverage Breakdown Section (Leverage Header Row Highlighted)
    f_cell(tbl, 0, r, "Leverage", color.aqua, text.align_left, tblSize, leverageRowBg)
    f_cell(tbl, 1, r, "Margin Needed", color.aqua, text.align_right, tblSize, leverageRowBg)
    f_cell(tbl, 2, r, "% Account", color.aqua, text.align_right, tblSize, leverageRowBg)
    r += 1

    // Option 1
    f_cell(tbl, 0, r, str.tostring(lev1) + "x", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(margin1, "#.##") + " USDT", margin1 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    f_cell(tbl, 2, r, str.tostring(marginPct1, "#.#") + "%", margin1 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    r += 1

    // Option 2
    f_cell(tbl, 0, r, str.tostring(lev2) + "x", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(margin2, "#.##") + " USDT", margin2 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    f_cell(tbl, 2, r, str.tostring(marginPct2, "#.#") + "%", margin2 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    r += 1

    // Option 3
    f_cell(tbl, 0, r, str.tostring(lev3) + "x", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(margin3, "#.##") + " USDT", margin3 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    f_cell(tbl, 2, r, str.tostring(marginPct3, "#.#") + "%", margin3 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    r += 1

    // Option 4
    f_cell(tbl, 0, r, str.tostring(lev4) + "x", color.white, text.align_left, tblSize)
    f_cell(tbl, 1, r, str.tostring(margin4, "#.##") + " USDT", margin4 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    f_cell(tbl, 2, r, str.tostring(marginPct4, "#.#") + "%", margin4 > accountSize ? color.red : color.lime, text.align_right, tblSize)
    r += 1

    // 3. Profit Targets Section (Dynamic R-Multiples)
    if showTargetTable
        f_cell(tbl, 0, r, "Profit Targets", color.lime, text.align_left, tblSize, targetsRowBg)
        f_cell(tbl, 1, r, "Price Level", color.lime, text.align_right, tblSize, targetsRowBg)
        f_cell(tbl, 2, r, "Return ($)", color.lime, text.align_right, tblSize, targetsRowBg)
        r += 1

        // Target 1
        f_cell(tbl, 0, r, "TP1 (" + str.tostring(target1R, "#.#") + "R / +" + str.tostring(tp1Pct, "#.##") + "%)", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, str.tostring(tp1Price, "#.####"), color.teal, text.align_right, tblSize)
        f_cell(tbl, 2, r, "+" + str.tostring(tp1Dollar, "#.##") + " USDT", color.teal, text.align_right, tblSize)
        r += 1

        // Target 2
        f_cell(tbl, 0, r, "TP2 (" + str.tostring(target2R, "#.#") + "R / +" + str.tostring(tp2Pct, "#.##") + "%)", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, str.tostring(tp2Price, "#.####"), color.green, text.align_right, tblSize)
        f_cell(tbl, 2, r, "+" + str.tostring(tp2Dollar, "#.##") + " USDT", color.green, text.align_right, tblSize)
        r += 1

        // Target 3
        f_cell(tbl, 0, r, "TP3 (" + str.tostring(target3R, "#.#") + "R / +" + str.tostring(tp3Pct, "#.##") + "%)", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, str.tostring(tp3Price, "#.####"), color.lime, text.align_right, tblSize)
        f_cell(tbl, 2, r, "+" + str.tostring(tp3Dollar, "#.##") + " USDT", color.lime, text.align_right, tblSize)
        r += 1

    // 4. ATR Trail Stats Section (Toggleable)
    if showStatsTable
        f_cell(tbl, 0, r, "ATR Trail Stats", color.fuchsia, text.align_left, tblSize, statsRowBg)
        f_cell(tbl, 1, r, "Value", color.fuchsia, text.align_right, tblSize, statsRowBg)
        f_cell(tbl, 2, r, "Detail", color.fuchsia, text.align_right, tblSize, statsRowBg)
        r += 1

        // Trend State
        f_cell(tbl, 0, r, "Trail Signal", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, isAtrLong ? "BUY" : "SELL", isAtrLong ? color.green : color.red, text.align_right, tblSize)
        f_cell(tbl, 2, r, isAtrLong ? "BULLISH" : "BEARISH", isAtrLong ? color.green : color.red, text.align_right, tblSize)
        r += 1

        // Candles Since Signal
        f_cell(tbl, 0, r, "Candles Since", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, str.tostring(barsSinceAtrSignal), color.white, text.align_right, tblSize)
        f_cell(tbl, 2, r, "bars", color.gray, text.align_right, tblSize)
        r += 1

        // Signal Price
        f_cell(tbl, 0, r, "Signal Price", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, str.tostring(atrSignalPrice, "#.####"), color.white, text.align_right, tblSize)
        f_cell(tbl, 2, r, "USDT", color.gray, text.align_right, tblSize)
        r += 1

        // Trade Profit %
        color pnlColor = atrProfitPct >= 0 ? color.green : color.red
        f_cell(tbl, 0, r, "Trade Profit", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, (atrProfitPct >= 0 ? "+" : "") + str.tostring(atrProfitPct, "#.##") + "%", pnlColor, text.align_right, tblSize)
        f_cell(tbl, 2, r, "", color.white, text.align_right, tblSize)
        r += 1

        // Trail Distance %
        f_cell(tbl, 0, r, isAtrLong ? "Support Dist" : "Resist Dist", color.white, text.align_left, tblSize)
        f_cell(tbl, 1, r, str.tostring(atrDistPct, "#.##") + "%", color.yellow, text.align_right, tblSize)
        f_cell(tbl, 2, r, str.tostring(trail2, "#.####"), color.gray, text.align_right, tblSize)
        r += 1
````
