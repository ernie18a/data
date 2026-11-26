# Footprint Liquidity Imbalance Framework [PakunFX]

- url: https://www.tradingview.com/script/YLQ31Umc-Footprint-Liquidity-Imbalance-Framework-PakunFX/
- type: indicator
- pine_id: PUB;bc01d879ef794d19b779eaab566ade72
- version: 1.0

## Description

[b]Footprint Liquidity Imbalance Framework [PakunFX][/b]

[image]https://www.tradingview.com/x/19GaDVdU/[/image]

Footprint Liquidity Imbalance Framework is a structural market analysis tool designed to visualize liquidity imbalance behavior using footprint delta, candle rejection structure, and contextual price positioning.

The framework focuses on identifying situations where aggressive participation is absorbed or rejected, helping traders observe potential liquidity interaction and liquidity interaction zones.

This script is intended for educational and analytical purposes only.

━━━━━━━━━━━━━━━━━━

[b]■ Core Framework[/b]

The framework combines multiple analytical layers including:

[list]
[*]Footprint delta imbalance
[*]Candle rejection structure
[*]POC positioning
[*]Value Area context
[*]Volatility-adjusted imbalance conditions
[/list]

Rather than functioning as a standalone prediction system, the script is designed to help traders visually interpret changing market participation conditions.

━━━━━━━━━━━━━━━━━━

[b]■ Delta Imbalance Analysis[/b]

[image]https://www.tradingview.com/x/GHAfA0kO/[/image]

The script evaluates abnormal delta expansion relative to historical delta behavior.

Positive and negative delta conditions are analyzed together with candle structure in order to identify potential absorption behavior rather than simple directional momentum.

This framework focuses on situations where aggressive market participation may show reduced directional continuation.

━━━━━━━━━━━━━━━━━━

[b]■ Candle Rejection Structure[/b]

[image]https://www.tradingview.com/x/Z8Z8yXqh/[/image]

The framework evaluates:

[list]
[*]Upper wick rejection
[*]Lower wick rejection
[*]Body-to-range ratio
[*]Relative candle acceptance behavior
[/list]

These conditions are used as structural context filters to reduce weak imbalance conditions.

━━━━━━━━━━━━━━━━━━

[b]■ POC and Value Area Context[/b]

[image]https://www.tradingview.com/x/6xk5X59c/[/image]

The script dynamically visualizes:

[list]
[*]Point of Control (POC)
[*]Value Area High (VAH)
[*]Value Area Low (VAL)
[/list]

These areas are used as contextual liquidity reference zones rather than predictive levels.

The framework is designed to help traders understand how price interacts with active liquidity concentration areas.

━━━━━━━━━━━━━━━━━━

[b]■ Contextual Market Layer[/b]

[image]https://www.tradingview.com/x/q0NF7KeE/[/image]

The displayed markers represent contextual imbalance conditions derived from:

[list]
[*]Delta behavior
[*]Price rejection structure
[*]POC positioning
[*]Relative candle acceptance
[/list]

These markers are intended as analytical references and should not be interpreted as predictive outcomes.

━━━━━━━━━━━━━━━━━━

[b]■ Intended Usage[/b]

https://www.tradingview.com/x/R7ejxZCm/

This framework is designed for traders interested in:

[list]
[*]Liquidity analysis
[*]Footprint behavior
[*]Market structure context
[*]Volume imbalance observation
[*]Discretionary analysis workflows
[/list]

Recommended usage includes high-liquidity markets and structure-based analytical environments.

━━━━━━━━━━━━━━━━━━

[b]■ Notes[/b]

[list]
[*]This script is intended for educational and structural analysis purposes.
[*]Results may vary depending on market conditions and timeframe selection.
[*]The framework does not guarantee profitability or predictive accuracy.
[*]This tool should be used as part of a broader analytical process.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PakunFX

//@version=6
indicator("Footprint Liquidity Imbalance Framework [PakunFX]", shorttitle="FP Trap", overlay=true, max_labels_count=500, max_boxes_count=200, max_lines_count=500)

//====================================================
// Inputs
//====================================================
string groupFp = "Footprint"
int ticksPerRow  = input.int(100, "Ticks per footprint row", minval=1, group=groupFp)
int valueAreaPct = input.int(70, "Value Area %", minval=1, maxval=100, group=groupFp)

string groupSignal = "Signal Logic"
int   deltaLookback      = input.int(20, "Delta average lookback", minval=5, group=groupSignal)
float deltaMult          = input.float(1.5, "Strong delta multiplier", minval=0.1, step=0.1, group=groupSignal)
float wickRatioMin       = input.float(0.35, "Min wick ratio", minval=0.0, maxval=1.0, step=0.05, group=groupSignal)
float bodyRatioMax       = input.float(0.45, "Max body ratio", minval=0.05, maxval=1.0, step=0.05, group=groupSignal)
bool  showOnlyConfirmed  = input.bool(true, "Show signals only on confirmed bars", group=groupSignal)
bool  showPreviewSignals = input.bool(true, "Show preview signals on forming bars", group=groupSignal)

string groupLevels = "Levels / Zones"
bool showPOCZone    = input.bool(true, "Show POC zone", group=groupLevels)
bool showVAZone     = input.bool(true, "Show Value Area zone", group=groupLevels)
int  zoneExtendBars = input.int(20, "Zone extend bars", minval=1, maxval=300, group=groupLevels)

string groupPanel = "Right Panel"
bool   showPanel      = input.bool(true, "Show right panel", group=groupPanel)
string panelTextSize  = input.string("Small", "Panel text size", options=["Tiny", "Small", "Normal"], group=groupPanel)
bool   showSignalRow  = input.bool(true, "Show signal row", group=groupPanel)
bool   showReasonRow  = input.bool(true, "Show reason row", group=groupPanel)
bool   showRatioRow   = input.bool(true, "Show candle ratio row", group=groupPanel)
bool   showPOCRow     = input.bool(true, "Show POC row", group=groupPanel)
bool   showVARow      = input.bool(true, "Show VA row", group=groupPanel)

string groupVisual = "Visual"
bool  showBg           = input.bool(true, "Background highlight on signal bars", group=groupVisual)
color bullColor        = input.color(color.lime, "Bullish color", group=groupVisual)
color bearColor        = input.color(color.red, "Bearish color", group=groupVisual)
color pocColor         = input.color(color.orange, "POC zone color", group=groupVisual)
color vaColor          = input.color(color.aqua, "VA zone color", group=groupVisual)
color panelHeaderColor = input.color(color.rgb(24, 119, 242), "Panel header color", group=groupVisual)
color panelBgColor     = input.color(color.rgb(17, 24, 39), "Panel background color", group=groupVisual)

//====================================================
// Helpers
//====================================================
f_getTextSize(_size) =>
    _size == "Tiny" ? size.tiny : _size == "Normal" ? size.normal : size.small

f_fmtPrice(_v) =>
    na(_v) ? "na" : str.tostring(_v, format.mintick)

f_fmtVol(_v) =>
    na(_v) ? "na" : str.tostring(_v, format.volume)

f_fmtPct(_v) =>
    na(_v) ? "na" : str.tostring(_v, "#.##") + "%"

//====================================================
// Candle stats
//====================================================
float barRange       = math.max(high - low, syminfo.mintick)
float bodySize       = math.abs(close - open)
float upperWick      = high - math.max(open, close)
float lowerWick      = math.min(open, close) - low

float bodyRatio      = bodySize / barRange
float upperWickRatio = upperWick / barRange
float lowerWickRatio = lowerWick / barRange

//====================================================
// Footprint request
//====================================================
footprint fp = request.footprint(ticksPerRow, valueAreaPct)

float buyVol   = na
float sellVol  = na
float deltaVol = na
float totalVol = na

float pocUp = na
float pocDn = na
float vahUp = na
float vahDn = na
float valUp = na
float valDn = na

bool fpReady = not na(fp)

if fpReady
    buyVol   := fp.buy_volume()
    sellVol  := fp.sell_volume()
    deltaVol := fp.delta()
    totalVol := fp.total_volume()

    volume_row pocRow = fp.poc()
    volume_row vahRow = fp.vah()
    volume_row valRow = fp.val()

    pocUp := pocRow.up_price()
    pocDn := pocRow.down_price()

    vahUp := vahRow.up_price()
    vahDn := vahRow.down_price()

    valUp := valRow.up_price()
    valDn := valRow.down_price()

//====================================================
// Delta logic
//====================================================
float absDelta    = math.abs(deltaVol)
float avgAbsDelta = ta.sma(absDelta, deltaLookback)

bool strongPositiveDelta = fpReady and not na(avgAbsDelta) and deltaVol > avgAbsDelta * deltaMult
bool strongNegativeDelta = fpReady and not na(avgAbsDelta) and deltaVol < -avgAbsDelta * deltaMult

float deltaPct = fpReady and totalVol > 0 ? (deltaVol / totalVol) * 100.0 : na

//====================================================
// Trap logic
//====================================================
bool bearishTrapCore =
     strongPositiveDelta and
     upperWickRatio >= wickRatioMin and
     bodyRatio <= bodyRatioMax and
     close <= open

bool bullishTrapCore =
     strongNegativeDelta and
     lowerWickRatio >= wickRatioMin and
     bodyRatio <= bodyRatioMax and
     close >= open

bool priceRejectedAbovePOC =
     fpReady and not na(pocUp) and close < pocUp

bool priceHeldBelowPOC =
     fpReady and not na(pocDn) and close > pocDn

bool bearishTrap = bearishTrapCore and priceRejectedAbovePOC
bool bullishTrap = bullishTrapCore and priceHeldBelowPOC

//====================================================
// Confirmed / Preview signals
//====================================================
bool confirmedBullishTrap = barstate.isconfirmed and bullishTrap
bool confirmedBearishTrap = barstate.isconfirmed and bearishTrap

bool previewBullishTrap =
     showPreviewSignals and
     not barstate.isconfirmed and
     bullishTrap

bool previewBearishTrap =
     showPreviewSignals and
     not barstate.isconfirmed and
     bearishTrap

bool finalBullishTrap = showOnlyConfirmed ? confirmedBullishTrap : bullishTrap
bool finalBearishTrap = showOnlyConfirmed ? confirmedBearishTrap : bearishTrap

string signalText =
     finalBullishTrap ? "BUY" :
     finalBearishTrap ? "SELL" :
     previewBullishTrap ? "PRE-BUY" :
     previewBearishTrap ? "PRE-SELL" :
     "-"

color signalColor =
     finalBullishTrap ? bullColor :
     finalBearishTrap ? bearColor :
     previewBullishTrap ? color.new(bullColor, 0) :
     previewBearishTrap ? color.new(bearColor, 0) :
     color.silver

//====================================================
// Reason text
//====================================================
bool hasUpperWickCondition = upperWickRatio >= wickRatioMin
bool hasLowerWickCondition = lowerWickRatio >= wickRatioMin
bool hasBodyCondition      = bodyRatio <= bodyRatioMax

string reasonText = ""

if not fpReady
    reasonText := "No FP"
else if previewBullishTrap or finalBullishTrap
    reasonText := (strongNegativeDelta ? "-Δ " : "")
    reasonText += (hasLowerWickCondition ? "Wick " : "Need Wick ")
    reasonText += (priceHeldBelowPOC ? "POC" : "Need POC")
else if previewBearishTrap or finalBearishTrap
    reasonText := (strongPositiveDelta ? "+Δ " : "")
    reasonText += (hasUpperWickCondition ? "Wick " : "Need Wick ")
    reasonText += (priceRejectedAbovePOC ? "POC" : "Need POC")
else
    if strongPositiveDelta
        reasonText := "+Δ "
        reasonText += hasUpperWickCondition ? "" : "Need Wick "
        reasonText += hasBodyCondition ? "" : "Need Body "
        reasonText += priceRejectedAbovePOC ? "POC" : "Need POC"
    else if strongNegativeDelta
        reasonText := "-Δ "
        reasonText += hasLowerWickCondition ? "" : "Need Wick "
        reasonText += hasBodyCondition ? "" : "Need Body "
        reasonText += priceHeldBelowPOC ? "POC" : "Need POC"
    else
        reasonText := "Need Δ"

//====================================================
// Refined POC / VA styling
//====================================================
groupStyle = "POC / VA Style"
showRefinedLevels = input.bool(true, "Use refined POC / VA style", group=groupStyle)
showPOCGlow       = input.bool(true, "Show POC glow", group=groupStyle)
showVAFill        = input.bool(true, "Show VA fill", group=groupStyle)
levelExtendBars   = input.int(35, "Level extend bars", minval=5, maxval=300, group=groupStyle)
pocLineWidth      = input.int(2, "POC line width", minval=1, maxval=5, group=groupStyle)
vahValLineWidth   = input.int(1, "VAH/VAL line width", minval=1, maxval=3, group=groupStyle)

pocLineColor      = input.color(color.rgb(255, 70, 70), "POC line color", group=groupStyle)
pocGlowColor      = input.color(color.rgb(255, 70, 70), "POC glow color", group=groupStyle)
vaBorderColor     = input.color(color.rgb(180, 180, 180), "VA border color", group=groupStyle)
vaFillColor       = input.color(color.rgb(160, 160, 160), "VA fill color", group=groupStyle)

// POC center price
float pocMid = fpReady and not na(pocUp) and not na(pocDn) ? (pocUp + pocDn) * 0.5 : na
float vahMid = fpReady and not na(vahUp) and not na(vahDn) ? (vahUp + vahDn) * 0.5 : na
float valMid = fpReady and not na(valUp) and not na(valDn) ? (valUp + valDn) * 0.5 : na

var line pocLine = na
var line pocGlowTop = na
var line pocGlowBot = na
var line vahLine = na
var line valLine = na
var linefill vaFill = na
var box pocGlowBox = na

if barstate.islast and showRefinedLevels
    // cleanup old objects
    if not na(pocLine)
        line.delete(pocLine)
    if not na(pocGlowTop)
        line.delete(pocGlowTop)
    if not na(pocGlowBot)
        line.delete(pocGlowBot)
    if not na(vahLine)
        line.delete(vahLine)
    if not na(valLine)
        line.delete(valLine)
    if not na(vaFill)
        linefill.delete(vaFill)
    if not na(pocGlowBox)
        box.delete(pocGlowBox)

    // VA band
    if fpReady and showVAZone and not na(vahUp) and not na(valDn)
        vahLine := line.new(
             x1 = bar_index,
             y1 = vahUp,
             x2 = bar_index + levelExtendBars,
             y2 = vahUp,
             color = color.new(vaBorderColor, 15),
             width = vahValLineWidth,
             style = line.style_solid)

        valLine := line.new(
             x1 = bar_index,
             y1 = valDn,
             x2 = bar_index + levelExtendBars,
             y2 = valDn,
             color = color.new(vaBorderColor, 15),
             width = vahValLineWidth,
             style = line.style_solid)

        if showVAFill
            vaFill := linefill.new(vahLine, valLine, color.new(vaFillColor, 82))

    // POC center line
    if fpReady and showPOCZone and not na(pocMid)
        pocLine := line.new(
             x1 = bar_index,
             y1 = pocMid,
             x2 = bar_index + levelExtendBars,
             y2 = pocMid,
             color = color.new(pocLineColor, 0),
             width = pocLineWidth,
             style = line.style_solid)

        // soft POC glow as a narrow box
        if showPOCGlow and not na(pocUp) and not na(pocDn)
            pocGlowBox := box.new(
                 left = bar_index,
                 top = pocUp,
                 right = bar_index + levelExtendBars,
                 bottom = pocDn,
                 bgcolor = color.new(pocGlowColor, 78),
                 border_color = color.new(pocGlowColor, 100))

//====================================================
// Signal plots
//====================================================
plotshape(
     finalBullishTrap,
     title = "Bullish Delta Trap",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullColor,
     text = "BUY",
     textcolor = color.white,
     size = size.small)

plotshape(
     finalBearishTrap,
     title = "Bearish Delta Trap",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearColor,
     text = "SELL",
     textcolor = color.white,
     size = size.small)

plotshape(
     previewBullishTrap,
     title = "Preview Bullish Delta Trap",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(bullColor, 65),
     text = "PRE",
     textcolor = color.white,
     size = size.tiny)

plotshape(
     previewBearishTrap,
     title = "Preview Bearish Delta Trap",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.new(bearColor, 65),
     text = "PRE",
     textcolor = color.white,
     size = size.tiny)

bgcolor(
     showBg ?
     finalBullishTrap ? color.new(bullColor, 88) :
     finalBearishTrap ? color.new(bearColor, 88) :
     previewBullishTrap ? color.new(bullColor, 93) :
     previewBearishTrap ? color.new(bearColor, 93) :
     na
     : na)

//====================================================
// Alerts
//====================================================
alertcondition(confirmedBullishTrap, title = "Bullish Delta Trap Confirmed", message = "PakunFX Footprint Delta Trap PRO: Confirmed bullish trap detected")
alertcondition(confirmedBearishTrap, title = "Bearish Delta Trap Confirmed", message = "PakunFX Footprint Delta Trap PRO: Confirmed bearish trap detected")

//====================================================
// Right panel table
//====================================================
var table fpPanel = table.new(position.top_right, 3, 10, border_width=1)

if barstate.islast and showPanel
    table.clear(fpPanel, 0, 0, 2, 9)

    txtSize = f_getTextSize(panelTextSize)

    string fpStatusText = fpReady ? "● LIVE" : "● NO DATA"
    color fpStatusBg    = fpReady ? color.new(color.green, 25) : color.new(color.red, 25)

    color deltaTextColor = na(deltaVol) ? color.white : deltaVol >= 0 ? bullColor : bearColor
    color deltaPctColor  = na(deltaPct) ? color.white : deltaPct >= 0 ? bullColor : bearColor

    color signalBgColor =
         finalBullishTrap ? color.new(bullColor, 75) :
         finalBearishTrap ? color.new(bearColor, 75) :
         previewBullishTrap ? color.new(bullColor, 88) :
         previewBearishTrap ? color.new(bearColor, 88) :
         panelBgColor

    table.cell(fpPanel, 0, 0, "Item",   text_color=color.white, text_size=txtSize, bgcolor=panelHeaderColor)
    table.cell(fpPanel, 1, 0, "Value",  text_color=color.white, text_size=txtSize, bgcolor=panelHeaderColor)
    table.cell(fpPanel, 2, 0, "Reason", text_color=color.white, text_size=txtSize, bgcolor=panelHeaderColor)

    table.cell(fpPanel, 0, 1, "FP Status", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 1, 1, fpStatusText, text_color=color.white, text_size=txtSize, bgcolor=fpStatusBg)
    table.cell(fpPanel, 2, 1, fpReady ? "Footprint OK" : "No footprint", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)

    table.cell(fpPanel, 0, 2, "Buy Vol", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 1, 2, f_fmtVol(buyVol), text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 2, 2, "Aggressive buy", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)

    table.cell(fpPanel, 0, 3, "Sell Vol", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 1, 3, f_fmtVol(sellVol), text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 2, 3, "Aggressive sell", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)

    table.cell(fpPanel, 0, 4, "Delta", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 1, 4, f_fmtVol(deltaVol), text_color=deltaTextColor, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 2, 4, strongPositiveDelta ? "Strong +Δ" : strongNegativeDelta ? "Strong -Δ" : "Weak Δ", text_color=deltaTextColor, text_size=txtSize, bgcolor=panelBgColor)

    table.cell(fpPanel, 0, 5, "Delta %", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 1, 5, f_fmtPct(deltaPct), text_color=deltaPctColor, text_size=txtSize, bgcolor=panelBgColor)
    table.cell(fpPanel, 2, 5, "Pressure ratio", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)

    if showPOCRow
        table.cell(fpPanel, 0, 6, "POC", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 6, fpReady and not na(pocDn) and not na(pocUp) ? f_fmtPrice(pocDn) + " - " + f_fmtPrice(pocUp) : "na", text_color=pocColor, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 6, priceHeldBelowPOC ? "Bull support" : priceRejectedAbovePOC ? "Bear reject" : "Neutral", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    else
        table.cell(fpPanel, 0, 6, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 6, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 6, "", bgcolor=panelBgColor)

    if showVARow
        table.cell(fpPanel, 0, 7, "VA", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 7, fpReady and not na(valDn) and not na(vahUp) ? f_fmtPrice(valDn) + " - " + f_fmtPrice(vahUp) : "na", text_color=vaColor, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 7, "Value area", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    else
        table.cell(fpPanel, 0, 7, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 7, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 7, "", bgcolor=panelBgColor)

    if showRatioRow
        string wickInfo = upperWickRatio >= wickRatioMin ? "Upper wick OK" : lowerWickRatio >= wickRatioMin ? "Lower wick OK" : "Need wick"
        table.cell(fpPanel, 0, 8, "Body/Wick", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 8, "B:" + str.tostring(bodyRatio, "#.##") + " U:" + str.tostring(upperWickRatio, "#.##") + " L:" + str.tostring(lowerWickRatio, "#.##"), text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 8, wickInfo, text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    else
        table.cell(fpPanel, 0, 8, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 8, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 8, "", bgcolor=panelBgColor)

    if showSignalRow
        table.cell(fpPanel, 0, 9, "Signal", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 9, signalText, text_color=signalColor, text_size=txtSize, bgcolor=signalBgColor)
        table.cell(fpPanel, 2, 9, showReasonRow ? reasonText : "", text_color=color.white, text_size=txtSize, bgcolor=panelBgColor)
    else
        table.cell(fpPanel, 0, 9, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 1, 9, "", bgcolor=panelBgColor)
        table.cell(fpPanel, 2, 9, "", bgcolor=panelBgColor)

if barstate.islast and not showPanel
    table.clear(fpPanel, 0, 0, 2, 9)

//====================================================
// Data Window
//====================================================
plot(fpReady ? deltaVol : na, "Footprint Delta", display=display.data_window)
plot(fpReady ? buyVol : na, "Footprint Buy Volume", display=display.data_window)
plot(fpReady ? sellVol : na, "Footprint Sell Volume", display=display.data_window)
plot(fpReady ? totalVol : na, "Footprint Total Volume", display=display.data_window)
plot(fpReady ? pocUp : na, "POC Upper", display=display.data_window)
plot(fpReady ? pocDn : na, "POC Lower", display=display.data_window)
plot(fpReady ? vahUp : na, "VAH Upper", display=display.data_window)
plot(fpReady ? valDn : na, "VAL Lower", display=display.data_window)
````
