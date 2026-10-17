# Adaptive 2 EMA Cloud (Trend-Aware)

- url: https://www.tradingview.com/script/tV8vBEco-Adaptive-2-EMA-Cloud-Trend-Aware/
- type: indicator
- pine_id: PUB;27f69e7d77794ed78b701810105faa6f
- version: 1.0

## Description

Liquidity Zone Indicator V2 is a chart overlay designed to highlight potential high-activity price areas using volume spikes and recent price extremes. The script detects possible liquidity zones and visualizes them directly on the chart using dynamic boxes or marker signals.

Features
Configurable liquidity lookback period
Volume-threshold based liquidity detection
Optional liquidity zone visualization
Extendable zones until invalidation
Dual-color or monochrome display modes
Bullish and bearish liquidity zone highlighting
Lightweight overlay design
Built-in alert condition support
Detection Logic

The indicator identifies potential liquidity areas when:

Volume exceeds the selected moving average threshold
Price reaches recent highs or lows within the configured lookback range

Zones are automatically managed and removed after invalidation conditions are met.

Visual Options
Liquidity zones as boxes or marker signals
Adjustable colors for bullish and bearish zones
Monochrome mode support
Zone transparency customization
Alerts

Includes alert conditions for detected liquidity events:

“Liquidity Zone Alert”
Inputs
Liquidity lookback
Volume threshold multiplier
Zone extension toggle
Zone display mode
Dual-color mode
Bullish/Bearish colors
Monochrome color selection
Notes
This indicator is intended for chart visualization and market structure analysis.
Volume-based signals may behave differently across markets and timeframes.
Use additional confirmation methods when analyzing price action.
Open-source script

This script is open-source and available for educational and analytical purposes in accordance with platform rules and guidelines.

## Source Code

````pine
//@version=6
indicator("Adaptive 2 EMA Cloud (Trend-Aware)", overlay=true, max_labels_count=500)

//====================================================
// GROUPS
//====================================================
var string GR_EMA     = "EMA Settings"
var string GR_DISPLAY = "Display Settings"
var string GR_SIGNAL  = "Signal Settings"
var string GR_TREND   = "Trend Filter (Trend vs Chop)"

//====================================================
// INPUTS (Core)
//====================================================
// EMA
ema1_period = input.int(14,  "EMA 1 Period", group=GR_EMA, minval=1)
ema2_period = input.int(50, "EMA 2 Period", group=GR_EMA, minval=1)

// Display
showEMAs          = input.bool(true, "Show EMAs", group=GR_DISPLAY)
cloudTransparency = input.int(80, "Cloud Transparency (0-100)%", minval=0, maxval=100, group=GR_DISPLAY)
colorMode         = input.string(
     "Classic",
     "Color Mode",
     options=["Classic","Monochrome","Heatmap","Pastel","Dark","Neon1","Neon2","BlueScale","RedScale","GreenScale","PriceBased"],
     group=GR_DISPLAY
)

// Signals
sigSizeChoice = input.string("Normal", "Crossover Signal Size", options=["Tiny","Small","Normal","Large","Huge"], group=GR_SIGNAL)

// Trend filter settings
useTrendFilter = input.bool(true, "Use Trend Filter (Trend vs Chop)", group=GR_TREND)
showChopBg     = input.bool(true, "Highlight Chop Zones", group=GR_TREND)

minDistATR  = input.float(
     0.20,
     "minDistATR (EMA separation threshold)",
     step=0.01, minval=0.0, group=GR_TREND,
     tooltip="Higher = stricter = fewer signals.\nFilters EMA compression/ranges.\nStill getting chop → increase.\nAlmost no signals → decrease.\nToo low: signals fire in congestion.\nToo high: only late-stage trends qualify."
)

minSlopeATR = input.float(
     0.05,
     "minSlopeATR (EMA slope/commitment threshold)",
     step=0.01, minval=0.0, group=GR_TREND,
     tooltip="Higher = stricter = fewer signals.\nFilters weak drift and slow grind.\nSignals stall → increase.\nMiss smooth trends → decrease.\nToo low: allows flat EMA states.\nToo high: requires strong acceleration."
)

slopeLen = input.int(
     5,
     "slopeLen (lookback for slope)",
     minval=1, group=GR_TREND,
     tooltip="Higher = smoother/slower = fewer, more stable signals.\nLower = faster = more signals, more noise.\nWhipsawed → increase.\nReacts too late → decrease.\nGuidelines: 3–5 responsive, 8–14 stable."
)

atrLen = input.int(
     14,
     "atrLen (normalization stability)",
     minval=1, group=GR_TREND,
     tooltip="Normalizes distance/slope across symbols.\nLeave at 14 in most cases.\nUse 20–30 for extreme volatility shifts."
)

//====================================================
// CORE CALCULATIONS
//====================================================
ema1 = ta.ema(close, ema1_period)
ema2 = ta.ema(close, ema2_period)

atr     = ta.atr(atrLen)
atrSafe = math.max(atr, syminfo.mintick)

//====================================================
// TREND LOGIC (Trend vs Chop)
//====================================================
emaDistance  = math.abs(ema1 - ema2)
distATR      = emaDistance / atrSafe

ema1Slope    = ema1 - ema1[slopeLen]
ema2Slope    = ema2 - ema2[slopeLen]
ema1SlopeATR = math.abs(ema1Slope) / atrSafe
ema2SlopeATR = math.abs(ema2Slope) / atrSafe

trendDistanceOK = distATR >= minDistATR
trendSlopeOK    = ema1SlopeATR >= minSlopeATR and ema2SlopeATR >= minSlopeATR

isTrending = trendDistanceOK and trendSlopeOK
isChop     = not isTrending

isBullish = isTrending and ema1 > ema2
isBearish = isTrending and ema1 < ema2

bgcolor(showChopBg and isChop ? color.new(color.gray, 92) : na, title="Chop Background")

//====================================================
// COLOR HELPERS
//====================================================
getCloudColor(dirUp) =>
    color c = color.black
    if colorMode == "PriceBased"
        c := close >= ema2 ? color.green : color.red
    else if colorMode == "Monochrome"
        c := color.rgb(110, 110, 110)
    else if colorMode == "Heatmap"
        c := dirUp ? color.orange : color.red
    else if colorMode == "Pastel"
        c := dirUp ? color.rgb(255, 182, 193) : color.rgb(255, 218, 185)
    else if colorMode == "Dark"
        c := dirUp ? color.rgb(50, 50, 50) : color.rgb(25, 25, 25)
    else if colorMode == "Neon1"
        c := dirUp ? color.rgb(0, 255, 255) : color.rgb(255, 20, 147)
    else if colorMode == "Neon2"
        c := dirUp ? color.rgb(125, 249, 255) : color.rgb(255, 97, 0)
    else if colorMode == "BlueScale"
        c := dirUp ? color.rgb(0, 0, 220) : color.rgb(0, 0, 80)
    else if colorMode == "RedScale"
        c := dirUp ? color.rgb(220, 0, 0) : color.rgb(80, 0, 0)
    else if colorMode == "GreenScale"
        c := dirUp ? color.rgb(0, 220, 0) : color.rgb(0, 80, 0)
    else
        c := dirUp ? color.aqua : color.blue
    color.new(c, cloudTransparency)

getEMAColor(defaultColor) =>
    bool useWhite = (
         colorMode == "PriceBased" or
         colorMode == "Monochrome" or
         colorMode == "Dark" or
         colorMode == "Neon1" or
         colorMode == "Neon2" or
         colorMode == "BlueScale" or
         colorMode == "RedScale" or
         colorMode == "GreenScale"
    )
    useWhite ? color.white : (colorMode == "Pastel" ? color.gray : defaultColor)

getSignalColor(isBull) =>
    if colorMode == "PriceBased"
        isBull ? color.green : color.red
    else
        switch colorMode
            "Monochrome" => color.black
            "Heatmap"    => isBull ? color.green : color.red
            "Pastel"     => isBull ? color.new(color.green, 20) : color.new(color.red, 20)
            "Dark"       => isBull ? color.lime : color.red
            "Neon1"      => isBull ? color.rgb(57, 255, 20) : color.rgb(255, 20, 147)
            "Neon2"      => isBull ? color.rgb(125, 249, 255) : color.rgb(255, 97, 0)
            "BlueScale"  => isBull ? color.rgb(0, 0, 220) : color.rgb(0, 0, 80)
            "RedScale"   => isBull ? color.rgb(220, 0, 0) : color.rgb(80, 0, 0)
            "GreenScale" => isBull ? color.rgb(0, 220, 0) : color.rgb(0, 80, 0)
            => isBull ? color.lime : color.red

//====================================================
// SIZE HANDLING (plotshape size must be const)
//====================================================
showTiny   = sigSizeChoice == "Tiny"
showSmall  = sigSizeChoice == "Small"
showNormal = sigSizeChoice == "Normal"
showLarge  = sigSizeChoice == "Large"
showHuge   = sigSizeChoice == "Huge"

//====================================================
// PLOTTING
//====================================================
p1 = plot(showEMAs ? ema1 : na, color=getEMAColor(color.blue), title="EMA 1")
p2 = plot(showEMAs ? ema2 : na, color=getEMAColor(color.aqua), title="EMA 2")

dirUp = ema1 >= ema2
fill(p1, p2, color=getCloudColor(dirUp), title="EMA Cloud")

//====================================================
// SIGNALS (Raw + Trend-Filtered)
//====================================================
rawBull = ta.crossover(ema1, ema2)
rawBear = ta.crossunder(ema1, ema2)

bull = useTrendFilter ? (rawBull and isTrending) : rawBull
bear = useTrendFilter ? (rawBear and isTrending) : rawBear

plotshape(bull and showTiny,   title="Bull Tiny",   location=location.belowbar, style=shape.triangleup,   color=getSignalColor(true),  size=size.tiny)
plotshape(bull and showSmall,  title="Bull Small",  location=location.belowbar, style=shape.triangleup,   color=getSignalColor(true),  size=size.small)
plotshape(bull and showNormal, title="Bull Normal", location=location.belowbar, style=shape.triangleup,   color=getSignalColor(true),  size=size.normal)
plotshape(bull and showLarge,  title="Bull Large",  location=location.belowbar, style=shape.triangleup,   color=getSignalColor(true),  size=size.large)
plotshape(bull and showHuge,   title="Bull Huge",   location=location.belowbar, style=shape.triangleup,   color=getSignalColor(true),  size=size.huge)

plotshape(bear and showTiny,   title="Bear Tiny",   location=location.abovebar, style=shape.triangledown, color=getSignalColor(false), size=size.tiny)
plotshape(bear and showSmall,  title="Bear Small",  location=location.abovebar, style=shape.triangledown, color=getSignalColor(false), size=size.small)
plotshape(bear and showNormal, title="Bear Normal", location=location.abovebar, style=shape.triangledown, color=getSignalColor(false), size=size.normal)
plotshape(bear and showLarge,  title="Bear Large",  location=location.abovebar, style=shape.triangledown, color=getSignalColor(false), size=size.large)
plotshape(bear and showHuge,   title="Bear Huge",   location=location.abovebar, style=shape.triangledown, color=getSignalColor(false), size=size.huge)

//====================================================
// TREND LABEL SETTINGS (Moved here as requested)
//====================================================
showTrendLabel = input.bool(true, "Show Trend Status Label (Bull/Bear/Chop)", group=GR_TREND)

trendLabelPos = input.string(
     "Top Right",
     "Trend Label Position",
     options=["Top Left","Top Middle","Top Right","Bottom Left","Bottom Middle","Bottom Right"],
     group=GR_TREND
)

bottomLeftOffsetRows = input.int(
     4,
     "Bottom Left Offset (rows)",
     minval=0, maxval=20, group=GR_TREND,
     tooltip="Only applies when Trend Label Position = Bottom Left.\nHigher = moves label up more.\nUses blank table rows to avoid the TradingView logo."
)

topLeftOffsetRows = input.int(
     3,
     "Top Left Offset (rows)",
     minval=0, maxval=20, group=GR_TREND,
     tooltip="Only applies when Trend Label Position = Top Left.\nHigher = moves label down more.\nUses blank table rows to avoid the Buy/Sell buttons."
)

//====================================================
// TREND STATUS LABEL (TABLE, REPOSITIONABLE + OFFSETS)
//====================================================
getTblPos(pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Middle"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Middle" => position.bottom_center
        "Bottom Right"  => position.bottom_right

int tblRows =
     trendLabelPos == "Bottom Left" ? (1 + bottomLeftOffsetRows) :
     trendLabelPos == "Top Left"    ? (1 + topLeftOffsetRows) :
                                      1

// Where to write the label text:
// - Top Left: write on bottom row to push it DOWN away from Buy/Sell buttons.
// - Bottom Left: write on top row to push it UP away from TV logo.
// - Others: row 0.
int labelRow = trendLabelPos == "Top Left" ? (tblRows - 1) : 0

var table trendTable = na
var string lastPos = na
var int lastRows = na

if barstate.isfirst or (lastPos != trendLabelPos) or (lastRows != tblRows)
    if not na(trendTable)
        table.delete(trendTable)
    trendTable := table.new(getTblPos(trendLabelPos), 1, tblRows)
    lastPos := trendLabelPos
    lastRows := tblRows

if barstate.islast
    for r = 0 to (tblRows - 1)
        table.cell(trendTable, 0, r, "", bgcolor=na, text_color=na)

    if showTrendLabel
        string trendText = isBullish ? "BULLISH" : isBearish ? "BEARISH" : "CHOP"
        color baseColor  = isBullish ? color.green : isBearish ? color.red : color.gray
        table.cell(
            trendTable, 0, labelRow,
            "Trend: " + trendText,
            bgcolor=color.new(baseColor, 85),
            text_color=color.white,
            text_size=size.normal
        )

//====================================================
// ALERTS
//====================================================
alertcondition(rawBull, "Bullish EMA Crossover (Raw)", "EMA1 crossed ABOVE EMA2 (raw).")
alertcondition(rawBear, "Bearish EMA Crossover (Raw)", "EMA1 crossed BELOW EMA2 (raw).")
alertcondition(bull, "Bullish EMA Crossover (Trend-Filtered)", "EMA1 crossed ABOVE EMA2 and trend filter is ON.")
alertcondition(bear, "Bearish EMA Crossover (Trend-Filtered)", "EMA1 crossed BELOW EMA2 and trend filter is ON.")

alertcondition(ta.change(isTrending) and isTrending, "Trend Flip: Chop → Trend", "Trend flipped from CHOP to TREND.")
alertcondition(ta.change(isTrending) and not isTrending, "Trend Flip: Trend → Chop", "Trend flipped from TREND to CHOP.")
alertcondition(ta.change(isBullish) and isBullish, "Trend Flip: → Bullish", "Trend flipped to BULLISH.")
alertcondition(ta.change(isBearish) and isBearish, "Trend Flip: → Bearish", "Trend flipped to BEARISH.")
````
