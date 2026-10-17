# Draggable TradeSize RR System | julzALGO

- url: https://www.tradingview.com/script/Incx02Tk-Draggable-TradeSize-RR-System-julzALGO/
- type: indicator
- pine_id: PUB;a7c9df6b391948d1a36ed249d3ea5bbf
- version: 3.0

## Description

⚪ Summary

The Draggable TradeSize RR System is a professional trade planning, position sizing, and risk management indicator that helps traders calculate every aspect of a trade before entering the market.

Simply place your Entry and Stop Loss directly on the chart using TradingView's interactive drag points. The indicator instantly calculates your optimal position size, monetary risk, expected reward, live profit/loss, and Risk-to-Reward ratio.

Designed for Stocks, Forex, Crypto, Futures, CFDs, Metals, Options, and Custom Instruments, this tool adapts to multiple markets while maintaining consistent risk management.

🟠 Key Features

 ✔ Interactive Drag & Drop RR Tool
https://www.tradingview.com/x/kQClKqpv/
* Draggable Entry and Stop Loss
* Professional Risk/Reward visualization
* Automatic trade recalculation
* Adjustable RR width

✔ Long & Short Trade Planning
https://www.tradingview.com/x/UbxtH4di/
Quickly switch between Long and Short positions with automatic RR adjustment.

✔ Multiple Stop Loss Modes
https://www.tradingview.com/x/nVzIBzS8/
Choose the stop method that matches your trading style:
* Manual
* ATR
* Pivot Swing

✔ Automatic Position Sizing
https://www.tradingview.com/x/IoBarlwc/
Automatically calculates position size using:
* Risk %
* Fixed Amount
* Account Size
* Stop Loss Distance
* Point Value
* Quantity Step

✔ Multi-Asset Support
https://www.tradingview.com/x/2H9yMPdb/

Supports:
* Stocks
* Crypto / Spot
* Forex
* Futures
* Metals / CFD
* Options
* Custom Instruments

Automatically displays the correct position type:
* Shares
* Coin Quantity
* Contracts
* Lots / Units
* Position Quantity

✔ Automatic Price Gap Detection

Automatically detects significant Bullish and Bearish Price Gaps as they develop, helping identify potential market imbalances for improved trade planning.
https://www.tradingview.com/x/kuOOFFew/

Features include:

* Bullish Price Gap detection
* Bearish Price Gap detection
* Largest Gap filter
* Automatic removal of filled gaps
* Lightweight chart markers

Price Gap markers help identify potential imbalance zones for improved trade planning.

✔ Professional RR Dashboard

Monitor every important trade statistic in one place.
https://www.tradingview.com/x/cnsGIZXz/

The dashboard provides a complete overview of your trade, including:

* Account Size
* Risk %
* Amount To Risk
* Entry Price
* Stop Loss
* Take Profit
* Position Size
* Maximum Loss
* Expected Profit
* Live Profit/Loss
* Risk : Reward Ratio

✔ Dashboard Target Selection
https://www.tradingview.com/x/P8seYyvE/
Select which take-profit target is displayed:
* 1R
* 2R
* 3R

✔ Visibility Rescue Mode

Automatically repositions the RR planner when switching to symbols with different price scales, ensuring the tool remains visible without manual adjustment.

✔ Multi-Currency Support

Supports multiple dashboard currencies, including:

USD, PHP, EUR, GBP, JPY, AUD, CAD, CHF, NZD, SGD, HKD, CNY, INR, IDR, MYR, THB, KRW, BTC, and Custom Currency.

✔ Professional Customization

Customize:

* Entry Color
* Stop Color
* Target Color
* Dashboard Header
* Dashboard Position
* Long Marker
* Short Marker

⚪ How to Use

Initial Setup
https://www.tradingview.com/x/G6FQ5I16/
1. Add the indicator to your chart.
2. After adding the indicator, TradingView will prompt you to place the Entry and Stop anchors directly on the chart.
3. Click on the chart to position the Entry.
4. Click again to place the Stop Loss.
5. The complete Risk/Reward plan is created automatically.

Moving the Entry
https://www.tradingview.com/x/Gjmntqv8/
* Locate the blue (Long) or red (Short) circular marker at the Entry Price.
* Click and drag the marker, then drag it to a new location.

The indicator automatically recalculates:

* Position Size
* Stop Loss Distance
* Expected Profit
* Maximum Loss
* Risk/Reward Ratio
* Live Profit/Loss

Moving the Stop Loss
https://www.tradingview.com/x/0fhesB8p/
* When Stop Mode = Manual, drag the second marker to adjust your Stop Loss.
* In ATR and Pivot modes, the Stop Loss is calculated automatically and cannot be dragged.


⚪ Trade Planning

1. Select Long or Short.
2. Choose Stop Mode.
3. Set your Account Size.
4. Select Risk % or Fixed Amount.
5. Choose Asset Type.
6. Review Position Size and Risk before entering the trade.

 ⚪ Inputs

 Draggable RR System

* Show RR Tool
* Direction
* Stop Mode
* Visibility Rescue Mode
* Auto Fit Distance × ATR
* Drag Entry
* Drag Stop
* ATR Length
* ATR Multiplier
* Pivot Lookback
* Target 1R
* Target 2R
* Target 3R
* Dashboard Take Profit
* RR Width Bars
* Show Risk / Reward Zones
* Show RR Dashboard

Position Sizing

* Account Size
* Risk %
* Risk Source
* Amount To Risk
* Asset Type
* Custom Point Value
* Quantity Step
* Dashboard Currency
* Custom Currency Symbol

Price Gap Detection

* Show Gap Markers
* Largest Gaps To Show

Style

* Entry Color
* Stop Color
* Target Color
* Dashboard Header
* Dashboard Position
* Long Marker
* Short Marker

📌 Important Notes

This indicator is designed for one active trade plan per chart.
When switching to another symbol, the existing Entry and Stop anchors remain linked to the original chart. 
To create a new trade plan, simply remove the indicator and add it again. TradingView will prompt you to place new Entry and Stop anchors.
If the RR planner is not visible after changing symbols, enable Visibility Rescue Mode or reload the indicator. This behavior is expected because TradingView stores interactive price and time anchors for each indicator instance.

🔴 Disclaimer

This indicator is designed as a trade planning, position sizing, and risk management tool. It does not generate buy or sell signals and should be used together with your own market analysis and trading strategy.

Always practice disciplined risk management and never risk more than you can afford to lose.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// (c) julzALGO

//@version=6
indicator("Draggable TradeSize RR System | julzALGO", shorttitle="Drag RR", overlay=true, max_lines_count=150, max_labels_count=100, max_boxes_count=50)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupRR = "Draggable RR System"

showRRTool = input.bool(true, "Show RR Tool", group=groupRR)
rrDirection = input.string("Long", "Direction", options=["Long", "Short"], group=groupRR)
rrStopMode = input.string("ATR", "Stop Mode", options=["Manual", "ATR", "Pivot"], group=groupRR)
rrAutoFitNewSymbol = input.bool(false, "Visibility Rescue Mode", group=groupRR)
rrAutoFitDistance = input.float(25.0, "Auto Fit Distance x ATR", minval=1, step=1, group=groupRR)

rrEntryTime = input.time(timestamp("2026-01-01T00:00:00"), "Drag Entry", confirm=true, group=groupRR, inline="ENTRY")
rrEntryPrice = input.price(100.0, "Entry", confirm=true, group=groupRR, inline="ENTRY")

rrStopTime = input.time(timestamp("2026-01-01T00:00:00"), "Drag Stop", confirm=true, group=groupRR, inline="STOP")
rrManualStop = input.price(95.0, "Stop", confirm=true, group=groupRR, inline="STOP")

rrAtrLen = input.int(14, "ATR Length", minval=1, group=groupRR)
rrAtrMult = input.float(1.5, "ATR Multiplier", minval=0.1, step=0.1, group=groupRR)
rrPivotLen = input.int(10, "Pivot Lookback", minval=1, group=groupRR)

rrTarget1 = input.float(1.0, "Target 1R", minval=0.1, step=0.1, group=groupRR)
rrTarget2 = input.float(2.0, "Target 2R", minval=0.1, step=0.1, group=groupRR)
rrTarget3 = input.float(3.0, "Target 3R", minval=0.1, step=0.1, group=groupRR)
rrDashboardTarget = input.string("2R", "Dashboard Take Profit", options=["1R", "2R", "3R"], group=groupRR)

rrWidthBars = input.int(20, "RR Width Bars", minval=5, maxval=500, group=groupRR)
showRRZones = input.bool(true, "Show Risk / Reward Zones", group=groupRR)
showRRDashboard = input.bool(true, "Show RR Dashboard", group=groupRR)

groupRisk = "Position Sizing"

rrAccountSize = input.float(10000.0, "Account Size", minval=0, step=100, group=groupRisk)
rrRiskPct = input.float(2.0, "Risk %", minval=0, step=0.1, group=groupRisk)
rrRiskMode = input.string("Risk %", "Risk Source", options=["Risk %", "Fixed Amount"], group=groupRisk)
rrFixedRisk = input.float(0.0, "Amount To Risk", minval=0, step=10, group=groupRisk)
rrAssetType = input.string("Custom", "Asset Type", options=["Stock", "Crypto / Spot", "CFD / Other", "Options", "Futures", "Forex", "Custom"], group=groupRisk)
rrForexUnitsPerLot = input.float(100000.0, "Forex Units Per Lot", minval=0.000001, step=1000, group=groupRisk)
rrCfdUnitsPerLot = input.float(100.0, "CFD Units Per Lot", minval=0.000001, step=1, group=groupRisk)
rrCustomPointValue = input.float(1.0, "Custom Point Value", minval=0.000001, step=0.1, group=groupRisk)
rrQtyStepInput = input.float(0.0, "Quantity Step (0 = Raw)", minval=0.0, step=0.0001, group=groupRisk)
rrCurrency = input.string("USD $", "Dashboard Currency", options=["USD $", "PHP ₱", "EUR €", "GBP £", "JPY ¥", "AUD A$", "CAD C$", "CHF Fr", "NZD NZ$", "SGD S$", "HKD HK$", "CNY ¥", "INR ₹", "IDR Rp", "MYR RM", "THB ฿", "KRW ₩", "BTC ₿", "Custom"], group=groupRisk)
rrCustomCurrencySign = input.string("$", "Custom Currency Sign", group=groupRisk)

groupGaps = "Gap Markers"

showGapMarks = input.bool(true, "Show Gap Markers", group=groupGaps)
gapTopCount = input.int(10, "Largest Gaps To Show", minval=1, maxval=10, group=groupGaps)

groupStyle = "Style"

rrEntryCol = input.color(color.rgb(144, 158, 163), "Entry Color", group=groupStyle)
rrStopCol = input.color(color.new(#ff5252, 0), "Stop Color", group=groupStyle)
rrTargetCol = input.color(color.new(#4caf4f, 0), "Target Color", group=groupStyle)
rrPanelBg = input.color(color.rgb(0, 0, 0), "Dashboard Header", group=groupStyle)
rrDashboardPosInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupStyle)
rrLongMarker = input.string("🔵", "Long Drag Marker", options=["🔵", "🟢", "⚪", "⬤"], group=groupStyle)
rrShortMarker = input.string("🔴", "Short Drag Marker", options=["🔴", "🟠", "🟣", "⬤"], group=groupStyle)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
rrCurrencySign(string currency, string customSign) =>
    currency == "USD $" ? "$" :
     currency == "PHP ₱" ? "₱" :
     currency == "EUR €" ? "€" :
     currency == "GBP £" ? "£" :
     currency == "JPY ¥" ? "¥" :
     currency == "AUD A$" ? "A$" :
     currency == "CAD C$" ? "C$" :
     currency == "CHF Fr" ? "Fr" :
     currency == "NZD NZ$" ? "NZ$" :
     currency == "SGD S$" ? "S$" :
     currency == "HKD HK$" ? "HK$" :
     currency == "CNY ¥" ? "¥" :
     currency == "INR ₹" ? "₹" :
     currency == "IDR Rp" ? "Rp" :
     currency == "MYR RM" ? "RM" :
     currency == "THB ฿" ? "฿" :
     currency == "KRW ₩" ? "₩" :
     currency == "BTC ₿" ? "₿" :
     customSign

fmtCash(float value, string cashSign) =>
    cashSign + str.tostring(value, "#.##")

fmtSignedCash(float value, string cashSign) =>
    (value >= 0 ? "+" : "-") + cashSign + str.tostring(math.abs(value), "#.##")

fmtQty(float value) =>
    str.tostring(value, "#.######")

var line[] rrLines = array.new<line>()
var label[] rrLabels = array.new<label>()
var box[] rrBoxes = array.new<box>()
var label[] gapLabels = array.new<label>()
var float[] gapTops = array.new_float()
var float[] gapBottoms = array.new_float()
var bool[] gapIsBull = array.new_bool()
var float[] gapRanges = array.new_float()
var string rrPlanKey = ""
var string rrSizeKey = ""
var float rrPlanEntry = na
var float rrPlanStop = na
var float rrPlanTp1 = na
var float rrPlanTp2 = na
var float rrPlanTp3 = na
var float rrPlanTakeProfit = na
var float rrPlanPointValue = na
var int rrPlanDirectionSign = na
var string rrPlanDashboardTarget = ""
var float rrPlanAccountSize = na
var float rrPlanRiskPct = na
var float rrPlanAmountRisk = na
var string rrPlanQtyLabel = ""
var string rrPlanUnitLabel = ""
var string rrPlanLotLabel = ""
var float rrPlanQty = na
var float rrPlanUnitQty = na
var float rrPlanLotQty = na
var float rrPlanLossMoney = na
var float rrPlanProfitMoney = na
var float rrPlanRatio = na

rrDashboardPos =
     rrDashboardPosInput == "Top Left" ? position.top_left :
     rrDashboardPosInput == "Bottom Right" ? position.bottom_right :
     rrDashboardPosInput == "Bottom Left" ? position.bottom_left :
     position.top_right

var table rrDashboard = table.new(rrDashboardPos, 2, 13, frame_color=color.new(color.gray, 35), frame_width=1, border_color=color.new(color.gray, 45), border_width=1)

clearRRDrawings() =>
    while array.size(rrLines) > 0
        line.delete(array.pop(rrLines))
    while array.size(rrLabels) > 0
        label.delete(array.pop(rrLabels))
    while array.size(rrBoxes) > 0
        box.delete(array.pop(rrBoxes))

removeGapAt(int idx) =>
    label.delete(array.get(gapLabels, idx))
    array.remove(gapLabels, idx)
    array.remove(gapTops, idx)
    array.remove(gapBottoms, idx)
    array.remove(gapIsBull, idx)
    array.remove(gapRanges, idx)
    true

limitGapSet(int maxKeep) =>
    bool canTrim = true
    while array.size(gapRanges) > maxKeep and canTrim
        float smallestRange = array.min(gapRanges)
        int removeIx = array.indexof(gapRanges, smallestRange)
        if removeIx >= 0
            removeGapAt(removeIx)
        canTrim := removeIx >= 0

drawGapMark(int x, float y, bool isBullGap) =>
    string markText = isBullGap ? "🔵" : "🔴"
    label lb = label.new(x, y, markText, xloc=xloc.bar_index, style=label.style_label_center, color=color.new(color.black, 100), textcolor=color.white, size=size.normal)
    array.push(gapLabels, lb)

drawRRLine(int x1, int x2, float y, color lineColor, string lineText) =>
    line ln = line.new(x1, y, x2, y, xloc=xloc.bar_time, color=lineColor, style=line.style_solid, width=1)
    label lb = label.new(x2, y, lineText, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 72), textcolor=lineColor, size=size.small)
    array.push(rrLines, ln)
    array.push(rrLabels, lb)

drawRRTargetGuide(int x1, int x2, float y, string guideText) =>
    color guideCol = color.new(color.gray, 45)
    color guideTextCol = color.rgb(0, 176, 230)
    int labelGap = int(math.max(1, math.round((x2 - x1) * 0.05)))
    int lineRight = math.max(x1 + 1, x2 - labelGap)
    line ln = line.new(x1, y, lineRight, y, xloc=xloc.bar_time, color=guideCol, style=line.style_dashed, width=1)
    label lb = label.new(x2, y, guideText, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=guideTextCol, size=size.small)
    array.push(rrLines, ln)
    array.push(rrLabels, lb)

drawRRBox(int x1, int x2, float topY, float botY, color boxColor) =>
    box bx = box.new(x1, topY, x2, botY, xloc=xloc.bar_time, bgcolor=color.new(boxColor, 88), border_color=na, border_width=0)
    array.push(rrBoxes, bx)

rrDashCell(int row, string name, string value, color valueColor) =>
    table.cell(rrDashboard, 0, row, name, text_color=color.new(chart.fg_color, 15), bgcolor=color.rgb(12, 12, 12), text_size=size.normal)
    table.cell(rrDashboard, 1, row, value, text_color=valueColor, bgcolor=color.rgb(24, 24, 24), text_size=size.normal, text_halign=text.align_right)

rrDashQtyCell(int row, string name, string value) =>
    color qtyBg = color.rgb(255, 214, 64)
    table.cell(rrDashboard, 0, row, name, text_color=color.black, bgcolor=color.new(qtyBg, 15), text_size=size.normal)
    table.cell(rrDashboard, 1, row, value, text_color=color.white, bgcolor=color.rgb(24, 24, 24), text_size=size.normal, text_halign=text.align_right)

//------------------------------------------------------------------------------
// Gap Markers
//------------------------------------------------------------------------------
bool gapReady = bar_index >= 2
bool newBullGap = showGapMarks and gapReady and low > high[2]
bool newBearGap = showGapMarks and gapReady and high < low[2]

if newBullGap
    float gapTop = low
    float gapBottom = high[2]
    drawGapMark(bar_index, (gapTop + gapBottom) * 0.5, true)
    array.push(gapTops, gapTop)
    array.push(gapBottoms, gapBottom)
    array.push(gapIsBull, true)
    array.push(gapRanges, gapTop - gapBottom)

if newBearGap
    float gapTop = low[2]
    float gapBottom = high
    drawGapMark(bar_index, (gapTop + gapBottom) * 0.5, false)
    array.push(gapTops, gapTop)
    array.push(gapBottoms, gapBottom)
    array.push(gapIsBull, false)
    array.push(gapRanges, gapTop - gapBottom)

if array.size(gapTops) > 0
    int gapIx = array.size(gapTops) - 1
    while gapIx >= 0
        bool isBullGap = array.get(gapIsBull, gapIx)
        float savedTop = array.get(gapTops, gapIx)
        float savedBottom = array.get(gapBottoms, gapIx)
        bool gapFilled = isBullGap ? low <= savedBottom : high >= savedTop
        if gapFilled
            removeGapAt(gapIx)
        gapIx -= 1

limitGapSet(gapTopCount)

//------------------------------------------------------------------------------
// RR Engine
//------------------------------------------------------------------------------
float rrAtrValue = ta.atr(rrAtrLen)
float rrPivotLowValue = ta.lowest(low, rrPivotLen)
float rrPivotHighValue = ta.highest(high, rrPivotLen)

if barstate.islast
    clearRRDrawings()
    table.clear(rrDashboard, 0, 0, 1, 12)

    if showRRTool
        bool rrLong = rrDirection == "Long"
        float rrAutoFitAtrRange = nz(rrAtrValue, syminfo.mintick * 100.0) * rrAutoFitDistance
        float rrAutoFitRange = math.max(math.max(rrAutoFitAtrRange, math.abs(close) * 0.25), syminfo.mintick * 100.0)
        bool rrUseAutoFit = rrAutoFitNewSymbol and math.abs(rrEntryPrice - close) > rrAutoFitRange
        int rrAnchorTime = rrUseAutoFit ? time : rrEntryTime
        int rrStopAnchorTime = rrUseAutoFit ? time : rrStopTime
        float rrEntry = rrUseAutoFit ? close : rrEntryPrice
        float rrAtrStop = rrLong ? rrEntry - rrAtrValue * rrAtrMult : rrEntry + rrAtrValue * rrAtrMult
        float rrPivotStop = rrLong ? rrPivotLowValue : rrPivotHighValue
        float rrManualStopForCalc = rrUseAutoFit ? rrAtrStop : rrManualStop
        float rrRawStop =
             rrStopMode == "Manual" ? rrManualStopForCalc :
             rrStopMode == "Pivot" ? rrPivotStop :
             rrAtrStop

        bool rrStopInvalid = rrLong ? rrRawStop >= rrEntry : rrRawStop <= rrEntry
        float rrStopPrice = rrStopMode != "Manual" and rrStopInvalid ? rrAtrStop : rrRawStop
        float rrRisk = rrLong ? rrEntry - rrStopPrice : rrStopPrice - rrEntry
        bool rrValid = rrRisk > syminfo.mintick

        int rrBarMs = int(math.max(1, nz(time - time[1], 1)))
        int rrLeft = rrAnchorTime
        int rrBaseRight = rrLeft + rrBarMs * rrWidthBars
        int rrRight = time >= rrBaseRight ? time + rrBarMs * rrWidthBars : rrBaseRight

        if rrValid
            string rrCashSign = rrCurrencySign(rrCurrency, rrCustomCurrencySign)
            float rrTp1 = rrLong ? rrEntry + rrRisk * rrTarget1 : rrEntry - rrRisk * rrTarget1
            float rrTp2 = rrLong ? rrEntry + rrRisk * rrTarget2 : rrEntry - rrRisk * rrTarget2
            float rrTp3 = rrLong ? rrEntry + rrRisk * rrTarget3 : rrEntry - rrRisk * rrTarget3
            float rrTakeProfit =
                 rrDashboardTarget == "1R" ? rrTp1 :
                 rrDashboardTarget == "2R" ? rrTp2 :
                 rrTp3

            float rrMoneyRisk = rrRiskMode == "Fixed Amount" ? rrFixedRisk : rrAccountSize * rrRiskPct / 100.0
            float rrDisplayRiskPct = rrRiskMode == "Risk %" ? rrRiskPct : 0.0
            float rrDisplayAmountRisk = rrRiskMode == "Fixed Amount" ? rrFixedRisk : 0.0
            float rrPointValue =
                 rrAssetType == "Stock" ? 1.0 :
                 rrAssetType == "Crypto / Spot" ? 1.0 :
                 rrAssetType == "Options" ? 100.0 :
                 rrCustomPointValue
            float rrQtyStep = rrQtyStepInput
            string rrQtyLabel =
                 rrAssetType == "Stock" ? "Shares" :
                 rrAssetType == "Crypto / Spot" ? "Coin Qty" :
                 rrAssetType == "CFD / Other" ? "Position Qty" :
                 rrAssetType == "Options" ? "Contracts" :
                 rrAssetType == "Futures" ? "Contracts" :
                 rrAssetType == "Forex" ? "Position Qty" :
                 "Position Qty"
            bool rrUseUnitLotRows = rrAssetType == "Forex" or rrAssetType == "CFD / Other"
            float rrUnitsPerLot = rrAssetType == "Forex" ? rrForexUnitsPerLot : rrCfdUnitsPerLot
            string rrUnitLabel = "Unit Qty"
            string rrLotLabel = "Lot Qty"
            float rrRiskPerUnit = rrRisk * rrPointValue
            float rrRawQty = rrRiskPerUnit > 0 ? rrMoneyRisk / rrRiskPerUnit : 0.0
            float rrCalcQty = rrQtyStep > 0 ? math.floor(rrRawQty / rrQtyStep) * rrQtyStep : rrRawQty
            float rrCalcLossMoney = rrCalcQty * rrRiskPerUnit
            float rrCalcProfitMoney = rrCalcQty * math.abs(rrTakeProfit - rrEntry) * rrPointValue
            float rrCalcRatio = rrCalcLossMoney > 0 ? rrCalcProfitMoney / rrCalcLossMoney : na
            int rrDirectionSign = rrLong ? 1 : -1
            string rrPlanInputKey =
                 syminfo.tickerid + "|" +
                 timeframe.period + "|" +
                 rrDirection + "|" +
                 rrStopMode + "|" +
                 rrDashboardTarget + "|" +
                 str.tostring(rrEntryTime) + "|" +
                 str.tostring(rrEntryPrice) + "|" +
                 str.tostring(rrStopTime) + "|" +
                 str.tostring(rrManualStop) + "|" +
                 str.tostring(rrAtrLen) + "|" +
                 str.tostring(rrAtrMult) + "|" +
                 str.tostring(rrPivotLen) + "|" +
                 str.tostring(rrTarget1) + "|" +
                 str.tostring(rrTarget2) + "|" +
                 str.tostring(rrTarget3)

            string rrSizeInputKey =
                 rrPlanInputKey + "|" +
                 rrRiskMode + "|" +
                 str.tostring(rrAccountSize) + "|" +
                 str.tostring(rrRiskPct) + "|" +
                 str.tostring(rrFixedRisk) + "|" +
                 rrAssetType + "|" +
                 str.tostring(rrCustomPointValue) + "|" +
                 str.tostring(rrQtyStepInput) + "|" +
                 str.tostring(rrForexUnitsPerLot) + "|" +
                 str.tostring(rrCfdUnitsPerLot)

            if rrPlanKey != rrPlanInputKey
                rrPlanKey := rrPlanInputKey
                rrPlanEntry := na
                rrPlanStop := na
                rrPlanTp1 := na
                rrPlanTp2 := na
                rrPlanTp3 := na
                rrPlanTakeProfit := na
                rrPlanPointValue := na
                rrPlanDirectionSign := na
                rrPlanDashboardTarget := ""
                rrSizeKey := ""
                rrPlanAccountSize := na
                rrPlanRiskPct := na
                rrPlanAmountRisk := na
                rrPlanQtyLabel := ""
                rrPlanUnitLabel := ""
                rrPlanLotLabel := ""
                rrPlanQty := na
                rrPlanUnitQty := na
                rrPlanLotQty := na
                rrPlanLossMoney := na
                rrPlanProfitMoney := na
                rrPlanRatio := na

            if na(rrPlanEntry)
                rrPlanEntry := rrEntry
                rrPlanStop := rrStopPrice
                rrPlanTp1 := rrTp1
                rrPlanTp2 := rrTp2
                rrPlanTp3 := rrTp3
                rrPlanTakeProfit := rrTakeProfit
                rrPlanDirectionSign := rrDirectionSign
                rrPlanDashboardTarget := rrDashboardTarget

            float rrDashEntry = nz(rrPlanEntry, rrEntry)
            float rrDashStop = nz(rrPlanStop, rrStopPrice)
            float rrDashTp1 = nz(rrPlanTp1, rrTp1)
            float rrDashTp2 = nz(rrPlanTp2, rrTp2)
            float rrDashTp3 = nz(rrPlanTp3, rrTp3)
            float rrDashTakeProfit = nz(rrPlanTakeProfit, rrTakeProfit)
            int rrDashDirectionSign = na(rrPlanDirectionSign) ? rrDirectionSign : rrPlanDirectionSign
            string rrDashDirection = rrDashDirectionSign == 1 ? "Long" : "Short"
            string rrDashTargetName = rrPlanDashboardTarget == "" ? rrDashboardTarget : rrPlanDashboardTarget
            float rrDashRisk = math.abs(rrDashEntry - rrDashStop)
            float rrDashRiskPerUnit = rrDashRisk * rrPointValue
            float rrDashRawQty = rrDashRiskPerUnit > 0 ? rrMoneyRisk / rrDashRiskPerUnit : 0.0
            float rrDashCalcQty = rrQtyStep > 0 ? math.floor(rrDashRawQty / rrQtyStep) * rrQtyStep : rrDashRawQty
            float rrDashCalcLossMoney = rrDashCalcQty * rrDashRiskPerUnit
            float rrDashCalcProfitMoney = rrDashCalcQty * math.abs(rrDashTakeProfit - rrDashEntry) * rrPointValue
            float rrDashCalcRatio = rrDashCalcLossMoney > 0 ? rrDashCalcProfitMoney / rrDashCalcLossMoney : na

            if rrSizeKey != rrSizeInputKey
                rrSizeKey := rrSizeInputKey
                rrPlanPointValue := na
                rrPlanAccountSize := na
                rrPlanRiskPct := na
                rrPlanAmountRisk := na
                rrPlanQtyLabel := ""
                rrPlanUnitLabel := ""
                rrPlanLotLabel := ""
                rrPlanQty := na
                rrPlanUnitQty := na
                rrPlanLotQty := na
                rrPlanLossMoney := na
                rrPlanProfitMoney := na
                rrPlanRatio := na

            if na(rrPlanQty)
                rrPlanPointValue := rrPointValue
                rrPlanAccountSize := rrAccountSize
                rrPlanRiskPct := rrDisplayRiskPct
                rrPlanAmountRisk := rrDisplayAmountRisk
                rrPlanQtyLabel := rrQtyLabel
                rrPlanUnitLabel := rrUseUnitLotRows ? rrUnitLabel : ""
                rrPlanLotLabel := rrUseUnitLotRows ? rrLotLabel : ""
                rrPlanQty := rrDashCalcQty
                rrPlanUnitQty := rrUseUnitLotRows ? rrDashCalcQty : na
                rrPlanLotQty := rrUseUnitLotRows and rrUnitsPerLot > 0 ? rrDashCalcQty / rrUnitsPerLot : na
                rrPlanLossMoney := rrDashCalcLossMoney
                rrPlanProfitMoney := rrDashCalcProfitMoney
                rrPlanRatio := rrDashCalcRatio

            float rrDashPointValue = nz(rrPlanPointValue, rrPointValue)
            float rrDashAccountSize = nz(rrPlanAccountSize, rrAccountSize)
            float rrDashRiskPct = nz(rrPlanRiskPct, rrDisplayRiskPct)
            float rrDashMoneyRisk = nz(rrPlanAmountRisk, rrDisplayAmountRisk)
            string rrDashQtyLabel = rrPlanQtyLabel == "" ? rrQtyLabel : rrPlanQtyLabel
            string rrDashUnitLabel = rrPlanUnitLabel == "" ? rrUnitLabel : rrPlanUnitLabel
            string rrDashLotLabel = rrPlanLotLabel == "" ? rrLotLabel : rrPlanLotLabel
            float rrQty = nz(rrPlanQty, rrDashCalcQty)
            bool rrDashUseUnitLotRows = rrPlanUnitLabel != "" and rrPlanLotLabel != ""
            float rrUnitQty = nz(rrPlanUnitQty, rrQty)
            float rrLotQty = nz(rrPlanLotQty, rrUnitsPerLot > 0 ? rrQty / rrUnitsPerLot : na)
            float rrLossMoney = nz(rrPlanLossMoney, rrDashCalcLossMoney)
            float rrProfitMoney = nz(rrPlanProfitMoney, rrDashCalcProfitMoney)
            float rrRatio = nz(rrPlanRatio, rrDashCalcRatio)
            float rrLiveMove = rrDashDirectionSign == 1 ? close - rrDashEntry : rrDashEntry - close
            float rrLivePL = rrQty * rrLiveMove * rrDashPointValue
            color rrLiveCol = rrLivePL >= 0 ? rrTargetCol : rrStopCol
            string rrLiveText = fmtSignedCash(rrLivePL, rrCashSign)

            if showRRZones
                drawRRBox(rrLeft, rrRight, math.max(rrDashEntry, rrDashStop), math.min(rrDashEntry, rrDashStop), rrStopCol)
                drawRRBox(rrLeft, rrRight, math.max(rrDashEntry, rrDashTp3), math.min(rrDashEntry, rrDashTp3), rrTargetCol)

            drawRRLine(rrLeft, rrRight, rrDashEntry, rrEntryCol, "ENTRY | " + str.tostring(rrDashEntry, format.mintick))
            drawRRLine(rrLeft, rrRight, rrDashStop, rrStopCol, "SL " + rrStopMode + " | " + str.tostring(rrDashStop, format.mintick))
            drawRRTargetGuide(rrLeft, rrRight, rrDashTp1, str.tostring(rrTarget1, "#.#") + "R | " + str.tostring(rrDashTp1, format.mintick))
            drawRRTargetGuide(rrLeft, rrRight, rrDashTp2, str.tostring(rrTarget2, "#.#") + "R | " + str.tostring(rrDashTp2, format.mintick))
            drawRRTargetGuide(rrLeft, rrRight, rrDashTp3, str.tostring(rrTarget3, "#.#") + "R | " + str.tostring(rrDashTp3, format.mintick))

            string rrDragMarker = rrLong ? rrLongMarker : rrShortMarker
            label entryAnchor = label.new(rrAnchorTime, rrDashEntry, rrDragMarker, xloc=xloc.bar_time, style=label.style_label_center, color=color.new(color.black, 100), textcolor=color.white, size=size.large)
            array.push(rrLabels, entryAnchor)

            if rrStopMode == "Manual"
                float rrStopLabelPrice = rrDashStop
                label stopAnchor = label.new(rrStopAnchorTime, rrStopLabelPrice, rrDragMarker, xloc=xloc.bar_time, style=label.style_label_center, color=color.new(color.black, 100), textcolor=color.white, size=size.large)
                array.push(rrLabels, stopAnchor)

            if showRRDashboard
                table.cell(rrDashboard, 0, 0, "RR DASHBOARD", text_color=color.white, bgcolor=rrPanelBg, text_size=size.normal)
                table.cell(rrDashboard, 1, 0, rrDashDirection + " " + rrDashTargetName, text_color=rrDashDirectionSign == 1 ? rrTargetCol : rrStopCol, bgcolor=rrPanelBg, text_size=size.normal, text_halign=text.align_right)
                rrDashCell(1, "Account Size", fmtCash(rrDashAccountSize, rrCashSign), color.white)
                rrDashCell(2, "Risk %", str.tostring(rrDashRiskPct, "#.##") + "%", color.white)
                rrDashCell(3, "Amount To Risk", fmtCash(rrDashMoneyRisk, rrCashSign), color.white)
                rrDashCell(4, "Entry Price", str.tostring(rrDashEntry, format.mintick), rrEntryCol)
                rrDashCell(5, "Stop Loss", str.tostring(rrDashStop, format.mintick), rrStopCol)
                rrDashCell(6, "Take Profit", str.tostring(rrDashTakeProfit, format.mintick), rrTargetCol)
                int rrLossRow = rrDashUseUnitLotRows ? 9 : 8
                int rrProfitRow = rrDashUseUnitLotRows ? 10 : 9
                int rrLiveRow = rrDashUseUnitLotRows ? 11 : 10
                int rrRatioRow = rrDashUseUnitLotRows ? 12 : 11
                if rrDashUseUnitLotRows
                    rrDashQtyCell(7, rrDashUnitLabel, fmtQty(rrUnitQty))
                    rrDashQtyCell(8, rrDashLotLabel, fmtQty(rrLotQty))
                else
                    rrDashQtyCell(7, rrDashQtyLabel, fmtQty(rrQty))
                rrDashCell(rrLossRow, "Loss", fmtCash(rrLossMoney, rrCashSign), rrStopCol)
                rrDashCell(rrProfitRow, "Profit", fmtCash(rrProfitMoney, rrCashSign), rrTargetCol)
                rrDashCell(rrLiveRow, "Live P/L", rrLiveText, rrLiveCol)
                rrDashCell(rrRatioRow, "Ratio", "1:" + str.tostring(rrRatio, "#.##"), rrTargetCol)
        else
            label invalidLabel = label.new(rrAnchorTime, rrEntry, "RR STOP INVALID", xloc=xloc.bar_time, style=label.style_label_center, color=rrStopCol, textcolor=color.white, size=size.normal)
            array.push(rrLabels, invalidLabel)
````
