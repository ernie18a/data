# MYND Volume Profile Value Zones v1.0

- url: https://www.tradingview.com/script/bVuSwWGY-MYND-Volume-Profile-Value-Zones-v1-0/
- type: indicator
- pine_id: PUB;c5d3ec8c87e44edcbd3581dedfd4be8f
- version: 1.0

## Description

MYND Volume Profile Value Zones [v1.0]

A from-scratch rolling Volume Profile - see where volume actually traded, find the Point of Control, and watch price react to a self-updating Value Area.

WHAT IT DOES

This indicator bins the last N bars' volume by price into a live histogram, finds the Point of Control (POC - the single price level with the most traded volume), and expands a Value Area (default 70% of profile volume) outward from the POC using the same standard "expand toward the side with more incremental volume" method real volume profile tools use. Unlike session/weekly/monthly anchored profiles, this one is fully rolling: it recomputes fresh every bar from a fixed recent lookback window, so it always reflects the same amount of current trading activity rather than growing across a session.

HOW IT WORKS

Each historical bar's entire volume is assigned to one price bin, based on that bar's typical price (HLC3 by default, configurable) - a real, commonly-used technique for building efficient rolling profiles that trades a small amount of intrabar precision for a much cheaper, more robust calculation than distributing volume proportionally across every bin a bar's range touches. The POC is simply the highest-volume bin; the Value Area expands outward from it, one bin at a time toward whichever side carries more volume, until it contains your configured percentage of the total.

Signals fire on Value Area High/Low breakouts (requiring volume confirmation) and rejections (reversion back into value) - a Bounce/Break-style taxonomy shared with MYND Anchored Value Zones for a consistent feel across the suite's value-zone tools.

KEY FEATURES

A live, updating volume profile histogram drawn directly on the chart, colored by whether up-volume or down-volume dominated each price level. Plotted POC and Value Area High/Low lines that update every bar. A dashboard showing the current POC, Value Area range, whether price is currently above, below, or inside value, and the last signal fired. 4 individual alerts plus 3 combo bundles. Light/Dark theme presets plus a colorblind-safe signal color option. Full customization throughout - colors, table size/position, line widths - with tooltips on every setting that benefits from one.

HOW TO USE IT

Works out of the box with sensible defaults - no source configuration required. Scan the histogram for the widest bars (high-interest price levels that tend to act as support/resistance) and thin or gapped areas (levels price tends to move through quickly). Use the POC and Value Area lines as dynamic reference levels the way you would any support/resistance zone, and let the Bounce/Break signals flag when price is actually leaving or failing to leave the current value range.

SETTINGS WORTH TUNING FIRST

Profile Lookback (bars) - shorten to track only very recent trading activity, lengthen for a broader, more stable structural read. Number of Price Bins - more bins for finer resolution, fewer for a cleaner look. Value Area % - 70% is the standard convention, but adjustable.

WHAT THIS TOOL DELIBERATELY DOES NOT DO

POC and Value Area describe where volume already traded, not where price will go next - they're structural context, not a directional forecast. Because of that, this tool does not carry a self-tracking accuracy dashboard the way some other MYND tools do; bolting a prediction-accuracy tracker onto a structural read would be a forced fit. This is also not a session/weekly/monthly anchored profile - it's intentionally the always-current rolling-window variant.

ALERTS

All 7 alerts (4 individual breakout/rejection alerts plus 3 combo bundles) use TradingView's standard alertcondition() system - no special setup required. Add Alert -> Condition -> this script -> pick the named alert from the dropdown.

This tool is provided for informational and educational purposes and does not constitute financial advice. Trading involves risk; past performance and historical patterns do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("MYND Volume Profile Value Zones v1.0", shorttitle="MYND VPVZ v1.0", overlay=true, max_boxes_count=50)

// =====================================================================================
// MYND VOLUME PROFILE VALUE ZONES v1.0
// A faithful, from-scratch rolling Volume Profile: bins the last N bars' volume by price
// into a live histogram, finds the Point of Control (POC - the single price level with the
// most traded volume) and expands a Value Area (default 70% of volume) outward from the
// POC using the same "always extend toward the side with more incremental volume" algorithm
// real volume profile tools use - not an approximation of the concept, the actual standard
// method. Recomputed fresh every bar from a rolling lookback window (not a calendar anchor),
// which keeps it simple, robust, and cheap to run.
//
// Simplification, stated plainly: each historical bar's ENTIRE volume is assigned to ONE
// price bin (based on that bar's typical price), rather than being distributed proportionally
// across every bin its high-low range touches. This is a real, commonly-used technique (not
// a shortcut unique to this tool) that trades a small amount of intrabar precision for a much
// cheaper, simpler, more robust calculation - see Directions & Notes for detail.
//
// Signals: Value Area High/Low breakouts (volume-confirmed) and rejections (reversion back
// into value), mirroring the Bounce/Break taxonomy already used in MYND Anchored Value Zones
// for a consistent feel across the suite's "value zone" tools.
//
// Note on scope: unlike MYND KNN and MYND PWEV, this tool does NOT ship a self-tracking
// accuracy dashboard. POC/Value Area are descriptive structural levels (where volume actually
// traded), not a directional forecast - bolting a prediction-accuracy tracker onto a
// structural tool would be forced rather than a natural fit. Noted here for consistency of
// documentation practice, not as an oversight.
// =====================================================================================

// ---------------------------- INPUTS: PROFILE SETTINGS ----------------------------
lookbackBars = input.int(100, "Profile Lookback (bars)", minval=20, group="Profile Settings", tooltip="How many recent bars the rolling profile is built from. Larger captures a broader structure but reacts slower as it rolls forward; smaller tracks recent trading more tightly.")
numBins = input.int(24, "Number of Price Bins (Rows)", minval=10, maxval=50, group="Profile Settings", tooltip="How many horizontal price rows the lookback range is divided into. More bins gives finer price resolution but a noisier-looking profile; fewer is coarser but cleaner.")
valueAreaPct = input.float(70, "Value Area %", minval=50, maxval=99, group="Profile Settings", tooltip="The standard convention is 70% - the % of total profile volume the Value Area (VAH to VAL) is expanded to contain, starting from the POC outward.")
priceSourceIn = input.string("Typical (HLC3)", "Bin Assignment Price", options=["Typical (HLC3)", "Close", "OHLC4"], group="Profile Settings", tooltip="Which single price point each historical bar's full volume is assigned to for binning. Typical (HLC3) is the standard, most representative choice for most symbols.")

// ---------------------------- INPUTS: SIGNAL SETTINGS ----------------------------
volConfirmLen = input.int(20, "Volume Confirmation Average Length", minval=2, group="Signal Settings", tooltip="Average volume length used to confirm Value Area breakouts - a breakout on below-average volume is a common source of false signals.")
volConfirmMult = input.float(1.2, "Volume Confirmation Multiplier", minval=0.5, step=0.1, group="Signal Settings", tooltip="Breakout volume must be at least this multiple of the average to count as confirmed. Rejection signals do not require this - failing to hold outside value is meaningful regardless of volume.")

// ---------------------------- INPUTS: DISPLAY - PROFILE ----------------------------
showProfile = input.bool(true, "Show Volume Profile Histogram", group="Display - Profile")
profileWidthBars = input.int(20, "Profile Max Width (bars)", minval=5, maxval=100, group="Display - Profile", tooltip="Horizontal width, in bars, of the single largest-volume bin. Every other bin scales proportionally to it.")
profileOffsetBars = input.int(2, "Profile Offset From Current Bar", minval=0, maxval=20, group="Display - Profile", tooltip="How many bars of empty space to leave between the current bar and where the profile histogram starts.")
showPOCLine = input.bool(true, "Show POC Line", group="Display - Profile")
showValueLines = input.bool(true, "Show Value Area High/Low Lines", group="Display - Profile")
pocLineWidth = input.int(2, "POC Line Width", minval=1, maxval=5, group="Display - Profile", tooltip="Line thickness for the POC level - thicker helps it stand out from the thinner Value Area High/Low lines.")

// ---------------------------- INPUTS: THEME & ACCESSIBILITY ----------------------------
themeMode = input.string("Light", "Theme Preset", options=["Light", "Dark", "Custom"], group="Theme & Accessibility", tooltip="Light and Dark apply a curated color palette suited to that chart background. Custom uses the individual color pickers in Display instead - Theme Preset overrides them unless set to Custom.")
colorblindMode = input.bool(false, "Colorblind-Safe Signal Colors", group="Theme & Accessibility", tooltip="When on, overrides the up/down volume bin colors and Bullish/Bearish signal colors to a colorblind-safe blue/orange palette (Okabe-Ito), regardless of Theme Preset or Custom colors.")

// ---------------------------- INPUTS: DISPLAY - COLORS & TABLE ----------------------------
showTable = input.bool(true, "Show Dashboard Table", group="Display - Colors & Table")
tablePosIn = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group="Display - Colors & Table")
tableSizeIn = input.string("Normal", "Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display - Colors & Table")
headerBgColorCustom = input.color(color.new(color.navy, 0), "Custom Table Header Background", group="Display - Colors & Table", tooltip="Only applied when Theme Preset is set to Custom.")
headerTextColorCustom = input.color(color.new(color.white, 0), "Custom Table Header Text", group="Display - Colors & Table", tooltip="Only applied when Theme Preset is set to Custom.")
bullishColorCustom = input.color(color.new(color.lime, 0), "Custom Up-Volume / Bullish Color", group="Display - Colors & Table", tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe Signal Colors is off.")
bearishColorCustom = input.color(color.new(color.red, 0), "Custom Down-Volume / Bearish Color", group="Display - Colors & Table", tooltip="Only applied when Theme Preset is Custom AND Colorblind-Safe Signal Colors is off.")
neutralColorCustom = input.color(color.new(color.gray, 0), "Custom Value Area Line Color", group="Display - Colors & Table", tooltip="Only applied when Theme Preset is set to Custom.")
pocColorCustom = input.color(color.new(color.orange, 0), "Custom POC Line Color", group="Display - Colors & Table", tooltip="Only applied when Theme Preset is set to Custom. POC is not affected by Colorblind-Safe Signal Colors since it doesn't carry bullish/bearish meaning.")

// =====================================================================================
// THEME RESOLUTION (Light/Dark/Custom base palette, then Colorblind-Safe override on top)
// =====================================================================================
lightHeaderBg = color.new(color.navy, 0)
lightHeaderText = color.new(color.white, 0)
lightBullish = color.new(color.green, 0)
lightBearish = color.new(color.red, 0)
lightNeutral = color.new(color.gray, 0)
lightPOC = color.new(color.orange, 0)

darkHeaderBg = color.new(#1A1F2E, 0)
darkHeaderText = color.new(#E0E0E0, 0)
darkBullish = color.new(#26A69A, 0)
darkBearish = color.new(#EF5350, 0)
darkNeutral = color.new(#787B86, 0)
darkPOC = color.new(#FFB74D, 0)

cbBullish = color.new(#0072B2, 0)
cbBearish = color.new(#E69F00, 0)

headerBgColor = themeMode == "Custom" ? headerBgColorCustom : themeMode == "Dark" ? darkHeaderBg : lightHeaderBg
headerTextColor = themeMode == "Custom" ? headerTextColorCustom : themeMode == "Dark" ? darkHeaderText : lightHeaderText
baseBullishColor = themeMode == "Custom" ? bullishColorCustom : themeMode == "Dark" ? darkBullish : lightBullish
baseBearishColor = themeMode == "Custom" ? bearishColorCustom : themeMode == "Dark" ? darkBearish : lightBearish
neutralColor = themeMode == "Custom" ? neutralColorCustom : themeMode == "Dark" ? darkNeutral : lightNeutral
pocColor = themeMode == "Custom" ? pocColorCustom : themeMode == "Dark" ? darkPOC : lightPOC
bullishColor = colorblindMode ? cbBullish : baseBullishColor
bearishColor = colorblindMode ? cbBearish : baseBearishColor

// =====================================================================================
// PROFILE CALCULATION - recomputed fresh every bar from the rolling lookback window
// =====================================================================================
rangeHigh = ta.highest(high, lookbackBars)
rangeLow = ta.lowest(low, lookbackBars)
binSize = (rangeHigh - rangeLow) / numBins

var array<float> binVolUp = array.new_float(0)
var array<float> binVolDown = array.new_float(0)

array.clear(binVolUp)
array.clear(binVolDown)
for i = 0 to numBins - 1
    array.push(binVolUp, 0.0)
    array.push(binVolDown, 0.0)

for i = 0 to lookbackBars - 1
    if not na(close[i]) and not na(open[i]) and not na(high[i]) and not na(low[i]) and not na(volume[i])
        typicalPrice = priceSourceIn == "Close" ? close[i] : priceSourceIn == "OHLC4" ? (open[i] + high[i] + low[i] + close[i]) / 4 : (high[i] + low[i] + close[i]) / 3
        binIdx = binSize > 0 ? int(math.min(numBins - 1, math.max(0.0, math.floor((typicalPrice - rangeLow) / binSize)))) : 0
        isUpBar = close[i] >= open[i]
        if isUpBar
            array.set(binVolUp, binIdx, array.get(binVolUp, binIdx) + volume[i])
        else
            array.set(binVolDown, binIdx, array.get(binVolDown, binIdx) + volume[i])

maxBinVol = 0.0
pocIdx = 0
totalVol = 0.0
for i = 0 to numBins - 1
    binTotal = array.get(binVolUp, i) + array.get(binVolDown, i)
    totalVol := totalVol + binTotal
    if binTotal > maxBinVol
        maxBinVol := binTotal
        pocIdx := i

pocPrice = rangeLow + (pocIdx + 0.5) * binSize

// =====================================================================================
// VALUE AREA - expand outward from POC toward whichever side has more incremental volume,
// until reaching valueAreaPct% of total profile volume (the standard method)
// =====================================================================================
vaVolume = array.get(binVolUp, pocIdx) + array.get(binVolDown, pocIdx)
vaLowIdx = pocIdx
vaHighIdx = pocIdx
targetVol = totalVol * (valueAreaPct / 100)

for i = 0 to numBins - 1
    if vaVolume >= targetVol
        break
    belowIdx = vaLowIdx - 1
    aboveIdx = vaHighIdx + 1
    belowVol = belowIdx >= 0 ? array.get(binVolUp, belowIdx) + array.get(binVolDown, belowIdx) : -1.0
    aboveVol = aboveIdx < numBins ? array.get(binVolUp, aboveIdx) + array.get(binVolDown, aboveIdx) : -1.0
    if belowVol < 0 and aboveVol < 0
        break
    else if belowVol >= aboveVol
        vaLowIdx := belowIdx
        vaVolume := vaVolume + belowVol
    else
        vaHighIdx := aboveIdx
        vaVolume := vaVolume + aboveVol

vahPrice = rangeLow + (vaHighIdx + 1) * binSize
valPrice = rangeLow + vaLowIdx * binSize

// =====================================================================================
// SIGNAL LOGIC
// =====================================================================================
volSma = ta.sma(volume, volConfirmLen)
volConfirmed = volume >= volSma * volConfirmMult

crossAboveVAH = ta.crossover(close, vahPrice)
crossBelowVAH = ta.crossunder(close, vahPrice)
crossAboveVAL = ta.crossover(close, valPrice)
crossBelowVAL = ta.crossunder(close, valPrice)

vahBreakout = crossAboveVAH and volConfirmed
vahRejection = crossBelowVAH
valBreakdown = crossBelowVAL and volConfirmed
valRejection = crossAboveVAL

var string lastEventType = "None"
var int lastEventBar = na
if vahBreakout
    lastEventType := "VAH Breakout"
    lastEventBar := bar_index
if vahRejection
    lastEventType := "VAH Rejection"
    lastEventBar := bar_index
if valBreakdown
    lastEventType := "VAL Breakdown"
    lastEventBar := bar_index
if valRejection
    lastEventType := "VAL Rejection"
    lastEventBar := bar_index
barsSinceEvent = na(lastEventBar) ? na : bar_index - lastEventBar

// =====================================================================================
// PLOTS - POC / Value Area lines, signal markers
// =====================================================================================
plot(showPOCLine ? pocPrice : na, title="POC", color=pocColor, linewidth=pocLineWidth, style=plot.style_stepline)
plot(showValueLines ? vahPrice : na, title="Value Area High", color=neutralColor, linewidth=1, style=plot.style_stepline)
plot(showValueLines ? valPrice : na, title="Value Area Low", color=neutralColor, linewidth=1, style=plot.style_stepline)

plotshape(vahBreakout, title="VAH Breakout", style=shape.triangleup, location=location.abovebar, color=bullishColor, size=size.small)
plotshape(vahRejection, title="VAH Rejection", style=shape.xcross, location=location.abovebar, color=bearishColor, size=size.tiny)
plotshape(valBreakdown, title="VAL Breakdown", style=shape.triangledown, location=location.belowbar, color=bearishColor, size=size.small)
plotshape(valRejection, title="VAL Rejection", style=shape.xcross, location=location.belowbar, color=bullishColor, size=size.tiny)

// =====================================================================================
// VOLUME PROFILE HISTOGRAM (drawn/updated only on the last bar - box objects created once,
// then repositioned in place every update rather than recreated, to stay within
// max_boxes_count and avoid unnecessary drawing overhead)
// =====================================================================================
var array<box> profileBoxes = array.new_box(0)
var bool boxesInit = false

if not boxesInit
    for i = 0 to numBins - 1
        array.push(profileBoxes, box.new(bar_index, close, bar_index, close, border_color=color.new(color.gray, 100), bgcolor=color.new(color.gray, 100)))
    boxesInit := true

if showProfile and barstate.islast
    maxBinVolForDraw = maxBinVol > 0 ? maxBinVol : 1.0
    leftX = bar_index + profileOffsetBars
    for i = 0 to numBins - 1
        binUpVol = array.get(binVolUp, i)
        binDownVol = array.get(binVolDown, i)
        binTotalVol = binUpVol + binDownVol
        binLow = rangeLow + i * binSize
        binHigh = rangeLow + (i + 1) * binSize
        barLen = profileWidthBars * (binTotalVol / maxBinVolForDraw)
        rightX = leftX + math.round(barLen)
        binColor = binUpVol >= binDownVol ? color.new(bullishColor, 40) : color.new(bearishColor, 40)
        b = array.get(profileBoxes, i)
        box.set_left(b, leftX)
        box.set_right(b, rightX)
        box.set_top(b, binHigh)
        box.set_bottom(b, binLow)
        box.set_bgcolor(b, binColor)
        box.set_border_color(b, binColor)
else if not showProfile and barstate.islast
    for i = 0 to numBins - 1
        b = array.get(profileBoxes, i)
        box.set_bgcolor(b, color.new(color.gray, 100))
        box.set_border_color(b, color.new(color.gray, 100))

// =====================================================================================
// DASHBOARD TABLE
// =====================================================================================
tablePosConst = tablePosIn == "Top Left" ? position.top_left : tablePosIn == "Top Right" ? position.top_right : tablePosIn == "Bottom Left" ? position.bottom_left : position.bottom_right
tableSizeConst = tableSizeIn == "Tiny" ? size.tiny : tableSizeIn == "Small" ? size.small : tableSizeIn == "Large" ? size.large : tableSizeIn == "Huge" ? size.huge : size.normal

var table dash = table.new(tablePosConst, 2, 7, border_width=1)

f_cell(_col, _row, _txt, _bg, _txtcol) =>
    table.cell(dash, _col, _row, _txt, bgcolor=_bg, text_color=_txtcol, text_size=tableSizeConst)

if showTable and barstate.islast
    f_cell(0, 0, "MYND VPVZ v1.0", headerBgColor, headerTextColor)
    f_cell(1, 0, "Status", headerBgColor, headerTextColor)

    f_cell(0, 1, "POC (Point of Control)", color.new(color.gray, 85), color.black)
    f_cell(1, 1, str.tostring(pocPrice, format.mintick), color.new(pocColor, 75), color.black)

    f_cell(0, 2, "Value Area (VAH - VAL)", color.new(color.gray, 85), color.black)
    f_cell(1, 2, str.tostring(vahPrice, format.mintick) + " - " + str.tostring(valPrice, format.mintick), color.new(color.gray, 88), color.black)

    posTxt = close > vahPrice ? "Above Value (bullish)" : close < valPrice ? "Below Value (bearish)" : "Inside Value"
    posColor = close > vahPrice ? color.new(bullishColor, 70) : close < valPrice ? color.new(bearishColor, 70) : color.new(neutralColor, 85)
    f_cell(0, 3, "Current Position", color.new(color.gray, 85), color.black)
    f_cell(1, 3, posTxt, posColor, color.black)

    f_cell(0, 4, "Value Area %", color.new(color.gray, 85), color.black)
    f_cell(1, 4, str.tostring(valueAreaPct, "#.#") + "% of profile volume", color.new(color.gray, 88), color.black)

    f_cell(0, 5, "Profile Lookback", color.new(color.gray, 85), color.black)
    f_cell(1, 5, str.tostring(lookbackBars) + " bars, " + str.tostring(numBins) + " bins", color.new(color.gray, 88), color.black)

    lastColor = lastEventType == "VAH Breakout" or lastEventType == "VAL Rejection" ? color.new(bullishColor, 70) : lastEventType == "VAL Breakdown" or lastEventType == "VAH Rejection" ? color.new(bearishColor, 70) : color.new(color.gray, 85)
    lastTxt = na(barsSinceEvent) ? "None yet" : lastEventType + " (" + str.tostring(barsSinceEvent) + " bars ago)"
    f_cell(0, 6, "Last Signal", color.new(color.gray, 85), color.black)
    f_cell(1, 6, lastTxt, lastColor, color.black)

// =====================================================================================
// ALERTS - INDIVIDUAL
// =====================================================================================
alertcondition(vahBreakout, title="VAH Breakout", message="MYND VPVZ: Volume-confirmed breakout above Value Area High on {{ticker}} ({{interval}})")
alertcondition(vahRejection, title="VAH Rejection", message="MYND VPVZ: Price rejected back below Value Area High on {{ticker}} ({{interval}})")
alertcondition(valBreakdown, title="VAL Breakdown", message="MYND VPVZ: Volume-confirmed breakdown below Value Area Low on {{ticker}} ({{interval}})")
alertcondition(valRejection, title="VAL Rejection", message="MYND VPVZ: Price reclaimed back above Value Area Low on {{ticker}} ({{interval}})")

// =====================================================================================
// ALERTS - COMBO BUNDLES (see MYND_Project_Notes.md for the standing convention)
// =====================================================================================
allSignals = vahBreakout or vahRejection or valBreakdown or valRejection
allBreakouts = vahBreakout or valBreakdown
allRejections = vahRejection or valRejection

alertcondition(allSignals, title="ALL Signals", message="MYND VPVZ: Signal on {{ticker}} ({{interval}}) - check chart")
alertcondition(allBreakouts, title="ALL Breakouts (out of Value)", message="MYND VPVZ: Volume-confirmed breakout out of the Value Area on {{ticker}} ({{interval}})")
alertcondition(allRejections, title="ALL Rejections (back into Value)", message="MYND VPVZ: Price rejected back into the Value Area on {{ticker}} ({{interval}})")
````
