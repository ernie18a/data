# Fractal Trendlines

- url: https://www.tradingview.com/script/lz4VViV0-Fractal-Trendlines/
- type: indicator
- pine_id: PUB;1fb57820af884fc792f464aeeb54db00
- version: 16.0

## Description

Fractal Trendlines is a non-repainting market structure indicator that builds dynamic support and resistance trendlines directly from confirmed fractal pivots. The script identifies major swing highs and lows using customizable left/right fractal strength settings, then connects those pivots into active trendlines while filtering out structurally weak lines using an optional Verified Trendlines mode. Verified red trendlines require lower highs and verified green trendlines require higher lows, helping remove a large amount of noisy or directionless structure.

The indicator is designed to separate short-term fractal structure from larger directional trend structure. Fractal markers and short pivot lines help visualize local reaction zones and recent liquidity pivots, while the trendline engine focuses on broader structural continuation and breakout behavior. Fractal Historical Lookback controls only the visible fractal markers and pivot lines without affecting the internal pivot memory used by the trendline engine. This allows traders to maintain a clean chart visually while still preserving deeper structural trendline calculations internally.

Break signals trigger only on currently active displayed trendlines. Once a trendline has produced a valid break signal, it becomes inactive and cannot generate repeated break labels. Break labels are directly tied to their parent trendline, so when older trendlines are removed by the Max Trendlines setting, their associated break labels are automatically removed as well. This prevents stale signals from remaining on the chart and keeps the display focused on current actionable structure.

The indicator can be used across multiple timeframes and trading styles. Lower fractal settings produce faster and more reactive structure, while higher settings produce cleaner swing-based trendlines more suitable for swing trading and macro structure analysis. RSI confirmation is optional and can be enabled to filter fractals using momentum conditions. Default settings are optimized for clean chart structure with minimal visual clutter while still retaining enough context for breakout and trend continuation analysis.

## Source Code

````pine
//@version=6
indicator("Fractal Trendlines", shorttitle="Fractal Trendlines", overlay=true, max_lines_count=500, max_labels_count=500)

//--------------------------------------------------
// GROUPS
//--------------------------------------------------

groupFractals = "Fractals"
groupRSI      = "RSI Confirmation"
groupTrends   = "Trendlines"
groupAddon    = "Addon Trendlines"
groupBreaks   = "Break Signals"
groupInfoBox  = "Info Box"

//--------------------------------------------------
// FRACTAL INPUTS
//--------------------------------------------------

nonRepaintSignals = input.bool(title="Non-Repaint Signals", defval=true, tooltip="When enabled, fractal signals only fire once the bar has fully closed, so they never appear and then vanish (repaint). Disable to get signals one bar earlier, at the cost of possible repainting on the live bar.")

leftBars = input.int(title="Bars Before", defval=50, minval=1, maxval=200, group=groupFractals, tooltip="Number of bars to the LEFT of a candidate pivot that must all be lower (for highs) or higher (for lows). Larger values detect only major swing points; smaller values detect more frequent, minor pivots.")
rightBars = input.int(title="Bars After", defval=5, minval=1, maxval=100, group=groupFractals, tooltip="Number of bars to the RIGHT required to confirm a pivot. Larger values produce more reliable pivots but confirm later, since a signal can only appear this many bars after the actual swing point.")

maxTrendlines = input.int(title="Main Lines Per Trend", defval=2, minval=1, maxval=50, group=groupFractals, tooltip="Maximum number of main trendlines kept on the chart per direction (highs and lows counted separately). When exceeded, the oldest line and its break label are deleted.")
extendMode = input.string(title="Extend Trendlines", defval="Chart", options=["Chart", "Fractal", "Break"], group=groupFractals, tooltip="Chart: extends right indefinitely. Fractal: stops at the second pivot. Break: extends right until the trendline is broken, then caps at the break bar.")
useVerifiedTrendlines = input.bool(title="Use Verified Trendlines Only", defval=true, group=groupFractals, tooltip="When enabled, trendlines are only drawn between pivots that form valid descending highs or ascending lows.")
minimumPivotRoc = input.float(title="Minimum Pivot ROC %", defval=0.05, minval=0, maxval=50, step=0.01, group=groupFractals, tooltip="Minimum percentage price difference between the two pivots for a trendline to be drawn. Filters out nearly flat lines between pivots at almost the same price. Only applies when 'Use Verified Trendlines Only' is enabled.")

hiLoMode = input.bool(title="Hi/Lo Mode", defval=true, group=groupFractals, tooltip="When enabled, fractals are detected using candle highs and lows. When disabled, fractals are detected using candle closes instead.")

showFractals = input.bool(title="Show Fractal Markers", defval=false, group=groupFractals, tooltip="Plots small triangle markers at the pivot candles used by the currently displayed main trendlines.")
showPivotLines = input.bool(title="Show Fractal Pivot Lines", defval=true, group=groupFractals, tooltip="Draws short horizontal lines at the price of each pivot used by the currently displayed main trendlines.")

pivotLineLength = input.int(title="Pivot Line Length", defval=8, minval=1, maxval=100, group=groupFractals, tooltip="How many bars each horizontal pivot line extends to the right of its pivot.")
pivotHighColor = input.color(title="High Pivot Line Color", defval=color.red, group=groupFractals, tooltip="Color of the horizontal lines drawn at high pivots.")
pivotLowColor = input.color(title="Low Pivot Line Color", defval=color.green, group=groupFractals, tooltip="Color of the horizontal lines drawn at low pivots.")
pivotLineWidth = input.int(title="Pivot Line Width", defval=2, minval=1, maxval=5, group=groupFractals, tooltip="Thickness of the pivot lines, in pixels.")
pivotLineStyleInput = input.string(title="Pivot Line Style", defval="Solid", options=["Solid", "Dashed", "Dotted"], group=groupFractals, tooltip="Visual style of the pivot lines: solid, dashed, or dotted.")

//--------------------------------------------------
// RSI INPUTS
//--------------------------------------------------

useRsiConfirm = input.bool(title="Use RSI Confirmation", defval=false, group=groupRSI, tooltip="When enabled, a high fractal is only accepted if RSI is above the Overbought level at the pivot bar, and a low fractal only if RSI is below the Oversold level. Filters out pivots that form without a momentum extreme.")
rsiLength = input.int(title="RSI Length", defval=14, minval=1, group=groupRSI, tooltip="Lookback period for the RSI used in confirmation.")
rsiSource = input.source(title="RSI Source", defval=close, group=groupRSI, tooltip="Price series the RSI is calculated on (close by default).")
rsiOverbought = input.float(title="RSI Overbought", defval=65.0, minval=0.0, maxval=100.0, step=1.0, group=groupRSI, tooltip="RSI must be ABOVE this level at the pivot bar for a high fractal to be accepted. Lower values make high fractals easier to confirm.")
rsiOversold = input.float(title="RSI Oversold", defval=35.0, minval=0.0, maxval=100.0, step=1.0, group=groupRSI, tooltip="RSI must be BELOW this level at the pivot bar for a low fractal to be accepted. Higher values make low fractals easier to confirm.")

//--------------------------------------------------
// TRENDLINE INPUTS
//--------------------------------------------------

drawHighTrendlines = input.bool(title="Draw High Trendlines", defval=true, group=groupTrends, tooltip="Draws resistance trendlines connecting consecutive high pivots.")
drawLowTrendlines = input.bool(title="Draw Low Trendlines", defval=true, group=groupTrends, tooltip="Draws support trendlines connecting consecutive low pivots.")

highTrendColor = input.color(title="High Trendline Color", defval=color.red, group=groupTrends, tooltip="Color of the main descending-highs (resistance) trendlines.")
lowTrendColor = input.color(title="Low Trendline Color", defval=color.green, group=groupTrends, tooltip="Color of the main ascending-lows (support) trendlines.")
trendWidth = input.int(title="Trendline Width", defval=2, minval=1, maxval=5, group=groupTrends, tooltip="Thickness of main and addon trendlines, in pixels.")
trendStyleInput = input.string(title="Trendline Style", defval="Solid", options=["Solid", "Dashed", "Dotted"], group=groupTrends, tooltip="Visual style applied to all trendlines (main and addon): solid, dashed, or dotted.")

//--------------------------------------------------
// ADDON TRENDLINE INPUTS
//--------------------------------------------------

showAddonTrendlines = input.bool(title="Show Addon Trendlines", defval=true, group=groupAddon, tooltip="Draws extra fan-style trendlines from the anchor pivot of the most recent main trendline to each newer valid pivot. Addon lines reset every time a new main trendline forms.")

addonHighTrendColor = input.color(title="Addon High Trendline Color", defval=color.new(color.red, 60), group=groupAddon, tooltip="Color of addon resistance trendlines. Some transparency is recommended to distinguish them from the main lines.")
addonLowTrendColor = input.color(title="Addon Low Trendline Color", defval=color.new(color.green, 60), group=groupAddon, tooltip="Color of addon support trendlines. Some transparency is recommended to distinguish them from the main lines.")

showAddonFractals = input.bool(title="Show Addon Fractal Markers", defval=false, group=groupAddon, tooltip="Plots small triangle markers at the pivot candles used by the currently active addon trendlines.")
showAddonPivotLines = input.bool(title="Show Addon Fractal Pivot Lines", defval=true, group=groupAddon, tooltip="Draws short horizontal lines at the price of each pivot used by the currently active addon trendlines.")

addonPivotLineLength = input.int(title="Addon Pivot Line Length", defval=8, minval=1, maxval=100, group=groupAddon, tooltip="How many bars each addon pivot line extends to the right of its pivot.")
addonPivotHighColor = input.color(title="Addon High Pivot Line Color", defval=color.new(color.red, 40), group=groupAddon, tooltip="Color of the horizontal lines and markers drawn at addon high pivots.")
addonPivotLowColor = input.color(title="Addon Low Pivot Line Color", defval=color.new(color.green, 40), group=groupAddon, tooltip="Color of the horizontal lines and markers drawn at addon low pivots.")
addonPivotLineWidth = input.int(title="Addon Pivot Line Width", defval=2, minval=1, maxval=5, group=groupAddon, tooltip="Thickness of the addon pivot lines, in pixels.")
addonPivotLineStyleInput = input.string(title="Addon Pivot Line Style", defval="Solid", options=["Solid", "Dashed", "Dotted"], group=groupAddon, tooltip="Visual style of the addon pivot lines: solid, dashed, or dotted.")

showAddonBreakSignals = input.bool(title="Show Addon Break Signals", defval=true, group=groupAddon, tooltip="Shows a label when price closes through an addon trendline. Addon breaks use the same ATR cutoff and close-only settings as main breaks, but only fire if no main-line break occurred on the same bar.")
addonBullBreakLabelColor = input.color(title="Addon Bull Break Label Color", defval=color.new(color.green, 50), group=groupAddon, tooltip="Background color of bullish addon break labels.")
addonBullBreakTextColor = input.color(title="Addon Bull Break Text Color", defval=color.black, group=groupAddon, tooltip="Text color of bullish addon break labels.")
addonBearBreakLabelColor = input.color(title="Addon Bear Break Label Color", defval=color.new(color.red, 50), group=groupAddon, tooltip="Background color of bearish addon break labels.")
addonBearBreakTextColor = input.color(title="Addon Bear Break Text Color", defval=color.white, group=groupAddon, tooltip="Text color of bearish addon break labels.")

//--------------------------------------------------
// BREAK SIGNAL INPUTS
//--------------------------------------------------

showBreakSignals = input.bool(title="Show Main Line Break Labels", defval=true, group=groupBreaks, tooltip="Shows a label on the chart when price breaks through a main trendline.")
breakOnCloseOnly = input.bool(title="Breaks On Bar Close Only", defval=true, group=groupBreaks, tooltip="When enabled, breaks are only registered on confirmed bar closes. Disable to allow intrabar break signals, which can trigger and then become invalid if price retreats before the bar closes.")
breakAtrLength = input.int(title="Break ATR Length", defval=14, minval=1, group=groupBreaks, tooltip="ATR lookback period used to size the break cutoff distance.")
breakAtrCutoff = input.float(title="Break ATR Cutoff", defval=0.25, minval=0.0, step=0.1, group=groupBreaks, tooltip="Minimum distance beyond the broken trendline, measured in ATR multiples. Set to 0 to disable the ATR cutoff.")

bullBreakText = input.string(title="Bull Break Text", defval="B ↑", group=groupBreaks, tooltip="Text shown inside bullish break labels (used for both main and addon breaks).")
bearBreakText = input.string(title="Bear Break Text", defval="B ↓", group=groupBreaks, tooltip="Text shown inside bearish break labels (used for both main and addon breaks).")

bullBreakColor = input.color(title="Bull Break Label Color", defval=color.lime, group=groupBreaks, tooltip="Background color of bullish break labels on main trendlines.")
bearBreakColor = input.color(title="Bear Break Label Color", defval=color.red, group=groupBreaks, tooltip="Background color of bearish break labels on main trendlines.")

bullBreakTextColor = input.color(title="Bull Break Text Color", defval=color.black, group=groupBreaks, tooltip="Text color of bullish break labels on main trendlines.")
bearBreakTextColor = input.color(title="Bear Break Text Color", defval=color.white, group=groupBreaks, tooltip="Text color of bearish break labels on main trendlines.")

breakLabelSizeInput = input.string(title="Break Label Size", defval="Small", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupBreaks, tooltip="Size of all break labels, main and addon.")

//--------------------------------------------------
// INFO BOX INPUTS
//--------------------------------------------------

showInfoBox = input.bool(title="Show Info Box", defval=true, group=groupInfoBox, tooltip="Displays an on-chart panel summarizing the indicator's current settings and live status.")
infoBoxDetailInput = input.string(title="Info Box Detail", defval="Medium", options=["Small", "Medium", "Large"], group=groupInfoBox, tooltip="Controls how many rows of information are shown. Small shows core detection settings; Medium adds trendline and break-display settings; Large adds RSI, ATR-cutoff, and live line counts.")
infoBoxPositionInput = input.string(title="Position", defval="Bottom Right", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupInfoBox, tooltip="Screen corner where the info box panel is anchored.")
infoBoxTextSizeInput = input.string(title="Text Size", defval="Tiny", options=["Tiny", "Small", "Normal"], group=groupInfoBox, tooltip="Font size used for the text inside the info box.")
infoBoxBgColor = input.color(title="Background", defval=color.new(color.black, 10), group=groupInfoBox, tooltip="Background color of the info box panel.")
infoBoxHeaderBgColor = input.color(title="Header Background", defval=color.new(color.blue, 55), group=groupInfoBox, tooltip="Background color of the info box's title/header row.")
infoBoxTextColor = input.color(title="Text Color", defval=color.white, group=groupInfoBox, tooltip="Color used for the primary values displayed in the info box.")
infoBoxMutedTextColor = input.color(title="Label Text Color", defval=color.silver, group=groupInfoBox, tooltip="Color used for the row labels (left column) in the info box.")
infoBoxBorderColor = input.color(title="Border Color", defval=color.gray, group=groupInfoBox, tooltip="Color of the info box panel's outline.")

//--------------------------------------------------
// STYLE CONVERSIONS
//--------------------------------------------------

trendLineStyle = line.style_solid
if trendStyleInput == "Dashed"
    trendLineStyle := line.style_dashed
else if trendStyleInput == "Dotted"
    trendLineStyle := line.style_dotted

pivotLineStyle = line.style_solid
if pivotLineStyleInput == "Dashed"
    pivotLineStyle := line.style_dashed
else if pivotLineStyleInput == "Dotted"
    pivotLineStyle := line.style_dotted

addonPivotLineStyle = line.style_solid
if addonPivotLineStyleInput == "Dashed"
    addonPivotLineStyle := line.style_dashed
else if addonPivotLineStyleInput == "Dotted"
    addonPivotLineStyle := line.style_dotted

// CHANGED: lineExtend now driven by extendMode
// "Break" starts as extend.right and gets capped in break detection
lineExtend = (extendMode == "Chart" or extendMode == "Break") ? extend.right : extend.none

breakLabelSize = size.small
if breakLabelSizeInput == "Tiny"
    breakLabelSize := size.tiny
else if breakLabelSizeInput == "Normal"
    breakLabelSize := size.normal
else if breakLabelSizeInput == "Large"
    breakLabelSize := size.large
else if breakLabelSizeInput == "Huge"
    breakLabelSize := size.huge

//--------------------------------------------------
// FRACTAL LOGIC
//--------------------------------------------------

enoughBars = bar_index >= leftBars + rightBars

rsiValue = ta.rsi(rsiSource, rsiLength)

highSource = hiLoMode ? high : close
lowSource = hiLoMode ? low : close

candidateRsi = enoughBars ? rsiValue[rightBars] : na
candidateHigh = enoughBars ? highSource[rightBars] : na
candidateLow = enoughBars ? lowSource[rightBars] : na

bool highLeftOk = false
bool highRightOk = false

if enoughBars
    highLeftOk := true
    highRightOk := true

    for i = 1 to leftBars
        highLeftOk := highLeftOk and highSource[rightBars + i] < candidateHigh

    for i = 1 to rightBars
        highRightOk := highRightOk and highSource[rightBars - i] < candidateHigh

highFractalRaw = enoughBars and highLeftOk and highRightOk

bool lowLeftOk = false
bool lowRightOk = false

if enoughBars
    lowLeftOk := true
    lowRightOk := true

    for i = 1 to leftBars
        lowLeftOk := lowLeftOk and lowSource[rightBars + i] > candidateLow

    for i = 1 to rightBars
        lowRightOk := lowRightOk and lowSource[rightBars - i] > candidateLow

lowFractalRaw = enoughBars and lowLeftOk and lowRightOk

highRsiOk = not useRsiConfirm or not na(candidateRsi) and candidateRsi > rsiOverbought
lowRsiOk = not useRsiConfirm or not na(candidateRsi) and candidateRsi < rsiOversold

highFractalBase = highFractalRaw and highRsiOk
lowFractalBase = lowFractalRaw and lowRsiOk

highFractal = nonRepaintSignals ? highFractalBase and barstate.isconfirmed : highFractalBase
lowFractal = nonRepaintSignals ? lowFractalBase and barstate.isconfirmed : lowFractalBase

//--------------------------------------------------
// STORAGE
//--------------------------------------------------

var label[] highFractalLabels = array.new_label()
var label[] lowFractalLabels = array.new_label()
var line[] highPivotLines = array.new_line()
var line[] lowPivotLines = array.new_line()
var int[] highVisualPivotBars = array.new_int()
var int[] lowVisualPivotBars = array.new_int()

var label[] addonHighFractalLabels = array.new_label()
var label[] addonLowFractalLabels = array.new_label()
var line[] addonHighPivotLines = array.new_line()
var line[] addonLowPivotLines = array.new_line()
var int[] addonHighVisualPivotBars = array.new_int()
var int[] addonLowVisualPivotBars = array.new_int()

var line[] highTrendlines = array.new_line()
var line[] lowTrendlines = array.new_line()

var int[] highTrendStartBars = array.new_int()
var float[] highTrendStartPrices = array.new_float()
var int[] highTrendEndBars = array.new_int()
var float[] highTrendEndPrices = array.new_float()

var int[] lowTrendStartBars = array.new_int()
var float[] lowTrendStartPrices = array.new_float()
var int[] lowTrendEndBars = array.new_int()
var float[] lowTrendEndPrices = array.new_float()

var bool[] highTrendlineBroken = array.new_bool()
var bool[] lowTrendlineBroken = array.new_bool()

var label[] highBreakLabels = array.new_label()
var label[] lowBreakLabels = array.new_label()

var int lastHighBar = na
var float lastHighPrice = na

var int lastLowBar = na
var float lastLowPrice = na

var int addonHighAnchorBar = na
var float addonHighAnchorPrice = na
var int addonLowAnchorBar = na
var float addonLowAnchorPrice = na

var line[] activeAddonHighLines = array.new_line()
var line[] activeAddonLowLines = array.new_line()

var int[] addonHighStartBars = array.new_int()
var float[] addonHighStartPrices = array.new_float()
var int[] addonHighEndBars = array.new_int()
var float[] addonHighEndPrices = array.new_float()

var int[] addonLowStartBars = array.new_int()
var float[] addonLowStartPrices = array.new_float()
var int[] addonLowEndBars = array.new_int()
var float[] addonLowEndPrices = array.new_float()

var bool[] addonHighBroken = array.new_bool()
var bool[] addonLowBroken = array.new_bool()
var label[] addonHighBreakLabels = array.new_label()
var label[] addonLowBreakLabels = array.new_label()

var bool addonHighJustReset = false
var bool addonLowJustReset = false

bool newHighTrendline = false
bool newLowTrendline = false

//--------------------------------------------------
// VISUAL FUNCTIONS
//--------------------------------------------------

f_deletePivotVisuals() =>
    for lbl in highFractalLabels
        label.delete(lbl)
    for lbl in lowFractalLabels
        label.delete(lbl)
    for ln in highPivotLines
        line.delete(ln)
    for ln in lowPivotLines
        line.delete(ln)

    for lbl in addonHighFractalLabels
        label.delete(lbl)
    for lbl in addonLowFractalLabels
        label.delete(lbl)
    for ln in addonHighPivotLines
        line.delete(ln)
    for ln in addonLowPivotLines
        line.delete(ln)

    array.clear(highFractalLabels)
    array.clear(lowFractalLabels)
    array.clear(highPivotLines)
    array.clear(lowPivotLines)
    array.clear(highVisualPivotBars)
    array.clear(lowVisualPivotBars)

    array.clear(addonHighFractalLabels)
    array.clear(addonLowFractalLabels)
    array.clear(addonHighPivotLines)
    array.clear(addonLowPivotLines)
    array.clear(addonHighVisualPivotBars)
    array.clear(addonLowVisualPivotBars)

f_drawMainHighPivotVisual(int pivotBar, float pivotPrice) =>
    if not array.includes(highVisualPivotBars, pivotBar)
        if showFractals
            lbl = label.new(x=pivotBar, y=pivotPrice, text="", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_triangledown, color=color.red, textcolor=color.red, size=size.tiny)
            array.push(highFractalLabels, lbl)

        if showPivotLines
            pivotLine = line.new(x1=pivotBar, y1=pivotPrice, x2=pivotBar + pivotLineLength, y2=pivotPrice, xloc=xloc.bar_index, extend=extend.none, color=pivotHighColor, style=pivotLineStyle, width=pivotLineWidth)
            array.push(highPivotLines, pivotLine)

        array.push(highVisualPivotBars, pivotBar)

f_drawMainLowPivotVisual(int pivotBar, float pivotPrice) =>
    if not array.includes(lowVisualPivotBars, pivotBar)
        if showFractals
            lbl = label.new(x=pivotBar, y=pivotPrice, text="", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_triangleup, color=color.green, textcolor=color.green, size=size.tiny)
            array.push(lowFractalLabels, lbl)

        if showPivotLines
            pivotLine = line.new(x1=pivotBar, y1=pivotPrice, x2=pivotBar + pivotLineLength, y2=pivotPrice, xloc=xloc.bar_index, extend=extend.none, color=pivotLowColor, style=pivotLineStyle, width=pivotLineWidth)
            array.push(lowPivotLines, pivotLine)

        array.push(lowVisualPivotBars, pivotBar)

f_drawAddonHighPivotVisual(int pivotBar, float pivotPrice) =>
    if not array.includes(addonHighVisualPivotBars, pivotBar)
        if showAddonFractals
            lbl = label.new(x=pivotBar, y=pivotPrice, text="", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_triangledown, color=addonPivotHighColor, textcolor=addonPivotHighColor, size=size.tiny)
            array.push(addonHighFractalLabels, lbl)

        if showAddonPivotLines
            pivotLine = line.new(x1=pivotBar, y1=pivotPrice, x2=pivotBar + addonPivotLineLength, y2=pivotPrice, xloc=xloc.bar_index, extend=extend.none, color=addonPivotHighColor, style=addonPivotLineStyle, width=addonPivotLineWidth)
            array.push(addonHighPivotLines, pivotLine)

        array.push(addonHighVisualPivotBars, pivotBar)

f_drawAddonLowPivotVisual(int pivotBar, float pivotPrice) =>
    if not array.includes(addonLowVisualPivotBars, pivotBar)
        if showAddonFractals
            lbl = label.new(x=pivotBar, y=pivotPrice, text="", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_triangleup, color=addonPivotLowColor, textcolor=addonPivotLowColor, size=size.tiny)
            array.push(addonLowFractalLabels, lbl)

        if showAddonPivotLines
            pivotLine = line.new(x1=pivotBar, y1=pivotPrice, x2=pivotBar + addonPivotLineLength, y2=pivotPrice, xloc=xloc.bar_index, extend=extend.none, color=addonPivotLowColor, style=addonPivotLineStyle, width=addonPivotLineWidth)
            array.push(addonLowPivotLines, pivotLine)

        array.push(addonLowVisualPivotBars, pivotBar)

//--------------------------------------------------
// HIGH FRACTAL OBJECTS
//--------------------------------------------------

if highFractal
    pivotBar = bar_index - rightBars
    pivotPrice = candidateHigh
    addonHighJustReset := false

    highPivotRoc = not na(lastHighPrice) and lastHighPrice != 0.0 ? math.abs((pivotPrice - lastHighPrice) / lastHighPrice) * 100.0 : na
    validHighTrendline = not useVerifiedTrendlines or (pivotPrice < lastHighPrice and not na(highPivotRoc) and highPivotRoc >= minimumPivotRoc)

    if drawHighTrendlines and not na(lastHighBar) and validHighTrendline
        trendLine = line.new(x1=lastHighBar, y1=lastHighPrice, x2=pivotBar, y2=pivotPrice, xloc=xloc.bar_index, extend=lineExtend, color=highTrendColor, style=trendLineStyle, width=trendWidth)

        array.push(highTrendlines, trendLine)
        array.push(highTrendlineBroken, false)
        array.push(highBreakLabels, na)

        array.push(highTrendStartBars, lastHighBar)
        array.push(highTrendStartPrices, lastHighPrice)
        array.push(highTrendEndBars, pivotBar)
        array.push(highTrendEndPrices, pivotPrice)

        addonHighAnchorBar := lastHighBar
        addonHighAnchorPrice := lastHighPrice

        for addonLine in activeAddonHighLines
            line.delete(addonLine)
        for addonLbl in addonHighBreakLabels
            label.delete(addonLbl)

        array.clear(activeAddonHighLines)
        array.clear(addonHighStartBars)
        array.clear(addonHighStartPrices)
        array.clear(addonHighEndBars)
        array.clear(addonHighEndPrices)
        array.clear(addonHighBroken)
        array.clear(addonHighBreakLabels)

        addonHighJustReset := true
        newHighTrendline := true

    if showAddonTrendlines and not na(addonHighAnchorBar) and not addonHighJustReset
        addonRoc = addonHighAnchorPrice != 0.0 ? math.abs((pivotPrice - addonHighAnchorPrice) / addonHighAnchorPrice) * 100.0 : na
        validAddon = not useVerifiedTrendlines or (pivotPrice < addonHighAnchorPrice and not na(addonRoc) and addonRoc >= minimumPivotRoc)

        if validAddon
            newAddonLine = line.new(x1=addonHighAnchorBar, y1=addonHighAnchorPrice, x2=pivotBar, y2=pivotPrice, xloc=xloc.bar_index, extend=lineExtend, color=addonHighTrendColor, style=trendLineStyle, width=trendWidth)

            array.push(activeAddonHighLines, newAddonLine)
            array.push(addonHighBroken, false)
            array.push(addonHighBreakLabels, na)

            array.push(addonHighStartBars, addonHighAnchorBar)
            array.push(addonHighStartPrices, addonHighAnchorPrice)
            array.push(addonHighEndBars, pivotBar)
            array.push(addonHighEndPrices, pivotPrice)

    lastHighBar := pivotBar
    lastHighPrice := pivotPrice

//--------------------------------------------------
// LOW FRACTAL OBJECTS
//--------------------------------------------------

if lowFractal
    pivotBar = bar_index - rightBars
    pivotPrice = candidateLow
    addonLowJustReset := false

    lowPivotRoc = not na(lastLowPrice) and lastLowPrice != 0.0 ? math.abs((pivotPrice - lastLowPrice) / lastLowPrice) * 100.0 : na
    validLowTrendline = not useVerifiedTrendlines or (pivotPrice > lastLowPrice and not na(lowPivotRoc) and lowPivotRoc >= minimumPivotRoc)

    if drawLowTrendlines and not na(lastLowBar) and validLowTrendline
        trendLine = line.new(x1=lastLowBar, y1=lastLowPrice, x2=pivotBar, y2=pivotPrice, xloc=xloc.bar_index, extend=lineExtend, color=lowTrendColor, style=trendLineStyle, width=trendWidth)

        array.push(lowTrendlines, trendLine)
        array.push(lowTrendlineBroken, false)
        array.push(lowBreakLabels, na)

        array.push(lowTrendStartBars, lastLowBar)
        array.push(lowTrendStartPrices, lastLowPrice)
        array.push(lowTrendEndBars, pivotBar)
        array.push(lowTrendEndPrices, pivotPrice)

        addonLowAnchorBar := lastLowBar
        addonLowAnchorPrice := lastLowPrice

        for addonLine in activeAddonLowLines
            line.delete(addonLine)
        for addonLbl in addonLowBreakLabels
            label.delete(addonLbl)

        array.clear(activeAddonLowLines)
        array.clear(addonLowStartBars)
        array.clear(addonLowStartPrices)
        array.clear(addonLowEndBars)
        array.clear(addonLowEndPrices)
        array.clear(addonLowBroken)
        array.clear(addonLowBreakLabels)

        addonLowJustReset := true
        newLowTrendline := true

    if showAddonTrendlines and not na(addonLowAnchorBar) and not addonLowJustReset
        addonRoc = addonLowAnchorPrice != 0.0 ? math.abs((pivotPrice - addonLowAnchorPrice) / addonLowAnchorPrice) * 100.0 : na
        validAddon = not useVerifiedTrendlines or (pivotPrice > addonLowAnchorPrice and not na(addonRoc) and addonRoc >= minimumPivotRoc)

        if validAddon
            newAddonLine = line.new(x1=addonLowAnchorBar, y1=addonLowAnchorPrice, x2=pivotBar, y2=pivotPrice, xloc=xloc.bar_index, extend=lineExtend, color=addonLowTrendColor, style=trendLineStyle, width=trendWidth)

            array.push(activeAddonLowLines, newAddonLine)
            array.push(addonLowBroken, false)
            array.push(addonLowBreakLabels, na)

            array.push(addonLowStartBars, addonLowAnchorBar)
            array.push(addonLowStartPrices, addonLowAnchorPrice)
            array.push(addonLowEndBars, pivotBar)
            array.push(addonLowEndPrices, pivotPrice)

    lastLowBar := pivotBar
    lastLowPrice := pivotPrice

//--------------------------------------------------
// MAIN TRENDLINE CLEANUP
//--------------------------------------------------

while array.size(highTrendlines) > maxTrendlines
    oldLine = array.shift(highTrendlines)
    array.shift(highTrendlineBroken)
    oldBreakLabel = array.shift(highBreakLabels)

    array.shift(highTrendStartBars)
    array.shift(highTrendStartPrices)
    array.shift(highTrendEndBars)
    array.shift(highTrendEndPrices)

    if not na(oldLine)
        line.delete(oldLine)

    if not na(oldBreakLabel)
        label.delete(oldBreakLabel)

while array.size(lowTrendlines) > maxTrendlines
    oldLine = array.shift(lowTrendlines)
    array.shift(lowTrendlineBroken)
    oldBreakLabel = array.shift(lowBreakLabels)

    array.shift(lowTrendStartBars)
    array.shift(lowTrendStartPrices)
    array.shift(lowTrendEndBars)
    array.shift(lowTrendEndPrices)

    if not na(oldLine)
        line.delete(oldLine)

    if not na(oldBreakLabel)
        label.delete(oldBreakLabel)

//--------------------------------------------------
// SYNC FRACTAL MARKERS / PIVOT LINES TO DISPLAYED LINE ENDPOINTS
//--------------------------------------------------

f_deletePivotVisuals()

if showFractals or showPivotLines
    if array.size(highTrendlines) > 0
        for i = 0 to array.size(highTrendlines) - 1
            f_drawMainHighPivotVisual(array.get(highTrendStartBars, i), array.get(highTrendStartPrices, i))
            f_drawMainHighPivotVisual(array.get(highTrendEndBars, i), array.get(highTrendEndPrices, i))

    if array.size(lowTrendlines) > 0
        for i = 0 to array.size(lowTrendlines) - 1
            f_drawMainLowPivotVisual(array.get(lowTrendStartBars, i), array.get(lowTrendStartPrices, i))
            f_drawMainLowPivotVisual(array.get(lowTrendEndBars, i), array.get(lowTrendEndPrices, i))

if showAddonFractals or showAddonPivotLines
    if array.size(activeAddonHighLines) > 0
        for i = 0 to array.size(activeAddonHighLines) - 1
            f_drawAddonHighPivotVisual(array.get(addonHighStartBars, i), array.get(addonHighStartPrices, i))
            f_drawAddonHighPivotVisual(array.get(addonHighEndBars, i), array.get(addonHighEndPrices, i))

    if array.size(activeAddonLowLines) > 0
        for i = 0 to array.size(activeAddonLowLines) - 1
            f_drawAddonLowPivotVisual(array.get(addonLowStartBars, i), array.get(addonLowStartPrices, i))
            f_drawAddonLowPivotVisual(array.get(addonLowEndBars, i), array.get(addonLowEndPrices, i))

//--------------------------------------------------
// BREAK DETECTION — PRIMARY TRENDLINES
//--------------------------------------------------

bool bullBreak = false
bool bearBreak = false

breakAtrValue = ta.atr(breakAtrLength)
breakAtrDistance = breakAtrValue * breakAtrCutoff
breakAtrDistancePrev = breakAtrValue[1] * breakAtrCutoff

highIndex = array.size(highTrendlines) - 1
while highIndex >= 0
    if not bullBreak and not array.get(highTrendlineBroken, highIndex)
        testLine = array.get(highTrendlines, highIndex)

        lineNow = line.get_price(testLine, bar_index)
        linePrev = line.get_price(testLine, bar_index - 1)

        crossedUp = not na(lineNow) and not na(linePrev) and close > lineNow + breakAtrDistance and close[1] <= linePrev + breakAtrDistancePrev
        validBreak = breakOnCloseOnly ? crossedUp and barstate.isconfirmed : crossedUp

        if validBreak
            bullBreak := true
            array.set(highTrendlineBroken, highIndex, true)

            // CHANGED: cap the line at the break bar when in "Break" mode
            if extendMode == "Break"
                line.set_x2(testLine, bar_index)
                line.set_y2(testLine, lineNow)
                line.set_extend(testLine, extend.none)

            if showBreakSignals
                lbl = label.new(x=bar_index, y=low, text=bullBreakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=bullBreakColor, textcolor=bullBreakTextColor, size=breakLabelSize)
                array.set(highBreakLabels, highIndex, lbl)

    highIndex -= 1

lowIndex = array.size(lowTrendlines) - 1
while lowIndex >= 0
    if not bearBreak and not array.get(lowTrendlineBroken, lowIndex)
        testLine = array.get(lowTrendlines, lowIndex)

        lineNow = line.get_price(testLine, bar_index)
        linePrev = line.get_price(testLine, bar_index - 1)

        crossedDown = not na(lineNow) and not na(linePrev) and close < lineNow - breakAtrDistance and close[1] >= linePrev - breakAtrDistancePrev
        validBreak = breakOnCloseOnly ? crossedDown and barstate.isconfirmed : crossedDown

        if validBreak
            bearBreak := true
            array.set(lowTrendlineBroken, lowIndex, true)

            // CHANGED: cap the line at the break bar when in "Break" mode
            if extendMode == "Break"
                line.set_x2(testLine, bar_index)
                line.set_y2(testLine, lineNow)
                line.set_extend(testLine, extend.none)

            if showBreakSignals
                lbl = label.new(x=bar_index, y=high, text=bearBreakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=bearBreakColor, textcolor=bearBreakTextColor, size=breakLabelSize)
                array.set(lowBreakLabels, lowIndex, lbl)

    lowIndex -= 1

//--------------------------------------------------
// BREAK DETECTION — ADDON TRENDLINES
//--------------------------------------------------

addonHighIdx = array.size(activeAddonHighLines) - 1
while addonHighIdx >= 0 and not bullBreak
    if not array.get(addonHighBroken, addonHighIdx)
        testLine = array.get(activeAddonHighLines, addonHighIdx)

        lineNow = line.get_price(testLine, bar_index)
        linePrev = line.get_price(testLine, bar_index - 1)

        crossedUp = not na(lineNow) and not na(linePrev) and close > lineNow + breakAtrDistance and close[1] <= linePrev + breakAtrDistancePrev
        validBreak = breakOnCloseOnly ? crossedUp and barstate.isconfirmed : crossedUp

        if validBreak
            array.set(addonHighBroken, addonHighIdx, true)

            // CHANGED: cap addon line at the break bar when in "Break" mode
            if extendMode == "Break"
                line.set_x2(testLine, bar_index)
                line.set_y2(testLine, lineNow)
                line.set_extend(testLine, extend.none)

            if showAddonBreakSignals
                lbl = label.new(x=bar_index, y=low, text=bullBreakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=addonBullBreakLabelColor, textcolor=addonBullBreakTextColor, size=breakLabelSize)
                array.set(addonHighBreakLabels, addonHighIdx, lbl)

    addonHighIdx -= 1

addonLowIdx = array.size(activeAddonLowLines) - 1
while addonLowIdx >= 0 and not bearBreak
    if not array.get(addonLowBroken, addonLowIdx)
        testLine = array.get(activeAddonLowLines, addonLowIdx)

        lineNow = line.get_price(testLine, bar_index)
        linePrev = line.get_price(testLine, bar_index - 1)

        crossedDown = not na(lineNow) and not na(linePrev) and close < lineNow - breakAtrDistance and close[1] >= linePrev - breakAtrDistancePrev
        validBreak = breakOnCloseOnly ? crossedDown and barstate.isconfirmed : crossedDown

        if validBreak
            array.set(addonLowBroken, addonLowIdx, true)

            // CHANGED: cap addon line at the break bar when in "Break" mode
            if extendMode == "Break"
                line.set_x2(testLine, bar_index)
                line.set_y2(testLine, lineNow)
                line.set_extend(testLine, extend.none)

            if showAddonBreakSignals
                lbl = label.new(x=bar_index, y=high, text=bearBreakText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=addonBearBreakLabelColor, textcolor=addonBearBreakTextColor, size=breakLabelSize)
                array.set(addonLowBreakLabels, addonLowIdx, lbl)

    addonLowIdx -= 1

//--------------------------------------------------
// INFO BOX
//--------------------------------------------------

f_format_timeframe(string tf) =>
    float numericTf = str.tonumber(tf)
    if not na(numericTf)
        int minutes = int(numericTf)
        if minutes >= 1440 and minutes % 1440 == 0
            int days = minutes / 1440
            days == 1 ? "1 Day" : str.tostring(days) + " Days"
        else if minutes >= 60 and minutes % 60 == 0
            int hours = minutes / 60
            hours == 1 ? "1 Hr" : str.tostring(hours) + " Hr"
        else
            minutes == 1 ? "1 Min" : str.tostring(minutes) + " Min"
    else
        tf == "D" ? "1 Day" : tf == "W" ? "1 Week" : tf == "M" ? "1 Month" : tf

var table infoBoxTable = na

infoBoxPosition = infoBoxPositionInput == "Top Left" ? position.top_left : infoBoxPositionInput == "Bottom Right" ? position.bottom_right : infoBoxPositionInput == "Bottom Left" ? position.bottom_left : position.top_right
infoBoxTextSize = infoBoxTextSizeInput == "Tiny" ? size.tiny : infoBoxTextSizeInput == "Normal" ? size.normal : size.small
showMediumInfoBox = infoBoxDetailInput == "Medium" or infoBoxDetailInput == "Large"
showLargeInfoBox = infoBoxDetailInput == "Large"
infoBoxRowCount = showLargeInfoBox ? 16 : showMediumInfoBox ? 9 : 7

if showInfoBox and barstate.islast
    if na(infoBoxTable)
        infoBoxTable := table.new(position=infoBoxPosition, columns=2, rows=infoBoxRowCount, bgcolor=infoBoxBgColor, frame_color=infoBoxBorderColor, frame_width=1, border_color=infoBoxBorderColor, border_width=1)
        table.merge_cells(infoBoxTable, 0, 0, 1, 0)

    // ── Core (Small) ──
    modeText      = nonRepaintSignals ? "Non-Repaint ON" : "Repaint Allowed"
    chartText     = f_format_timeframe(timeframe.period)
    pivotText     = str.tostring(leftBars) + "L / " + str.tostring(rightBars) + "R"
    detectionText = hiLoMode ? "Hi/Lo" : "Close"
    extendText    = extendMode
    verifiedText  = useVerifiedTrendlines ? "ON" : "OFF"

    table.cell(infoBoxTable, 0, 0, "Fractal Trendlines", text_color=infoBoxTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxHeaderBgColor, text_halign=text.align_center)
    table.cell(infoBoxTable, 0, 1, "Mode",      text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 1, 1, modeText,    text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 0, 2, "Chart",     text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 1, 2, chartText,   text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 0, 3, "Pivots",    text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 1, 3, pivotText,   text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 0, 4, "Detection", text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 1, 4, detectionText, text_color=infoBoxTextColor,    text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 0, 5, "Extend",    text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 1, 5, extendText,  text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 0, 6, "Verified",  text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
    table.cell(infoBoxTable, 1, 6, verifiedText,text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)

    // ── Medium ──
    if showMediumInfoBox
        maxLinesText    = str.tostring(maxTrendlines)
        minRocText      = str.tostring(minimumPivotRoc) + "%"
        table.cell(infoBoxTable, 0, 7,  "Max Lines",   text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 7,  maxLinesText,  text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 8,  "Min ROC",     text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 8,  minRocText,    text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)

    // ── Large ──
    if showLargeInfoBox
        breakTriggerText = breakOnCloseOnly ? "Close Only" : "Intrabar"
        breakAtrText     = str.tostring(breakAtrLength)
        breakCutoffText  = str.tostring(breakAtrCutoff) + " ATR"
        rsiConfirmText   = useRsiConfirm ? "ON" : "OFF"
        rsiLengthText    = str.tostring(rsiLength)
        rsiLevelsText    = str.tostring(rsiOverbought) + " OB / " + str.tostring(rsiOversold) + " OS"
        activeLinesText  = str.tostring(array.size(highTrendlines)) + " H / " + str.tostring(array.size(lowTrendlines)) + " L"
        table.cell(infoBoxTable, 0, 9,  "Break Trigger",  text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 9,  breakTriggerText, text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 10, "Break ATR",      text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 10, breakAtrText,     text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 11, "Break Cutoff",   text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 11, breakCutoffText,  text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 12, "RSI Confirm",    text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 12, rsiConfirmText,   text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 13, "RSI Length",     text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 13, rsiLengthText,    text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 14, "RSI Levels",     text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 14, rsiLevelsText,    text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 0, 15, "Active Lines",   text_color=infoBoxMutedTextColor, text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
        table.cell(infoBoxTable, 1, 15, activeLinesText,  text_color=infoBoxTextColor,      text_size=infoBoxTextSize, bgcolor=infoBoxBgColor)
else if barstate.islast
    if not na(infoBoxTable)
        table.delete(infoBoxTable)
        infoBoxTable := na

//--------------------------------------------------
// ALERTS
//--------------------------------------------------

alertcondition(condition=bullBreak, title="Bullish Trendline Break", message="Bullish breakout above active displayed fractal trendline")
alertcondition(condition=bearBreak, title="Bearish Trendline Break", message="Bearish breakdown below active displayed fractal trendline")
alertcondition(condition=newLowTrendline, title="New Bullish Trendline", message="New bullish fractal trendline drawn (ascending lows)")
alertcondition(condition=newHighTrendline, title="New Bearish Trendline", message="New bearish fractal trendline drawn (descending highs)")
````
