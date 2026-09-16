<!-- tradingview-pine-id: PUB;57d20e08b48740a590ef5485582aa051 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Highest Volume Candle @MaxMaserati

Source: https://www.tradingview.com/script/XEFQonB1-Highest-Volume-Candle-MaxMaserati/

## Description

Highest Volume Candle

Colors candlesticks whenever relative volume spikes against a rolling
average, then draws a footprint-derived Point of Control box on those
bars to show exactly where within the range volume concentrated. An
optional filter requires price to close beyond the footprint's POC and
Value Area before a candle is flagged, and a sequential signal mode
marks only the first valid volume spike after a trend flip.

─── WHY THESE COMPONENTS TOGETHER ───
Relative volume alone tells you a bar was busy, not where inside that
bar's range trading actually clustered. Footprint POC/VAH/VAL data
alone shows where volume concentrated on every bar, but doesn't tell
you which bars are volume-significant enough to matter. Combining the
two means the POC box only appears on candles that already cleared a
volume threshold — the output is a shortlist of statistically
significant bars with their internal volume structure visible, rather
than either a wall of footprint boxes or an undifferentiated string of
colored candles.

 [image]https://www.tradingview.com/x/p7Hs79mq/[/image]

─── VOLUME INTENSITY COLORING ───
rVol = volume / SMA(volume, length). A bullish candle (close >= open)
is colored Ultra when rVol >= ultraThresh, or High when rVol >=
highThresh and below the Ultra threshold. The same logic applies to
bearish candles with separate colors. Both thresholds and the lookback
length are user-adjustable.

─── POC BOX ───
On any valid High/Ultra candle, the script pulls the bar's footprint
POC upper/lower bounds, finds the midpoint, and plots a box double the
height of the raw POC range, centered on that midpoint. This gives a
readable visual anchor for where the heaviest trading sat inside a
volume-significant bar.

─── POC AND VALUE AREA FILTER ───
Optional. When enabled, a bullish Ultra/High candle must close above
both the POC midpoint and the VAH; a bearish candle must close below
both the POC midpoint and the VAL. This narrows signals to volume
spikes that also broke through the bar's own value structure.

─── SEQUENTIAL SIGNAL MARKERS ───
When Sequential Stars is on, a triangle only plots on the first valid
bullish signal following a bearish one (or vice versa), suppressing
repeated signals within the same directional run.

─── HOW TO USE ───
1. Watch for a candle to print in one of the four intensity colors —
   this marks a statistically significant relative-volume bar.
2. Check the POC box on that candle to see where volume clustered
   within the range, not just that volume was high.
3. If the POC/VA filter is enabled, treat a colored candle as
   confirmation only when it also closed beyond the POC and VAH/VAL —
   this is the stronger signal.
4. Use the triangle markers under Sequential Stars mode to catch the
   first spike after a directional flip, rather than reacting to every
   qualifying bar in a run.
5. Footprint data requires a Premium or Ultimate TradingView plan;
   works on any instrument and timeframe with footprint support, though
   it is most legible on intraday charts.

─── SETTINGS ───
Display Toggles — turn Ultra/High colors, the POC box, and the
POC/VA close filter on or off.
Signal Settings — enable markers, restrict to sequential (flip-only)
signals, set marker size.
Volume Thresholds — SMA lookback length and the High/Ultra relative
volume multipliers.
Footprint Settings — ticks per footprint row, Value Area percentage,
and how many bars back to compute footprint data for.
Candle Colors — colors for Ultra/High bullish and bearish candles.
POC Box Colors — fill and border colors for bullish and bearish POC
boxes.

─── NOTES ───
All footprint calculations run only on confirmed bars (barstate.isconfirmed)
and are gated by the Max Bars for Footprint setting; no repainting of
historical bars occurs once a bar closes. Footprint data requires a
Premium or Ultimate TradingView subscription. Built primarily for
intraday use on liquid futures and equity index symbols.

---

## Source Code

````pine
//@version=6
indicator("Highest Volume Candle @MaxMaserati", shorttitle="HVC @MaxMaserati", overlay=true, max_bars_back=300, max_boxes_count=500)

// ─── Inputs ───
// --- DISPLAY TOGGLES ---
showUltra       = input.bool(true,  title="Show Ultra-High Volume Colors", group="Display Toggles")
showHigh        = input.bool(true,  title="Show High Volume Colors",       group="Display Toggles")
showPocBox      = input.bool(true,  title="Show POC Box on Valid Candles", group="Display Toggles")
filterPocVa     = input.bool(false, title="Filter: Must Close Above/Below POC & VA", group="Display Toggles",
                     tooltip="If ON: Bullish Ultra/High must close > POC & VAH. Bearish Ultra/High must close < POC & VAL.")

// --- SIGNAL & STAR SETTINGS ---
showSignals     = input.bool(true,  title="Show Signal Markers",           group="Signal Settings")
sequentialStars = input.bool(true,  title="Sequential Stars Only",         group="Signal Settings",
                     tooltip="When enabled, only displays a signal after a trend direction change.")
signalSizeInput = input.string("Tiny", title="Marker Size", options=["Tiny", "Small", "Normal", "Large"], group="Signal Settings")

// --- VOLUME THRESHOLDS ---
int   length      = input.int(20,    title="Volume SMA Lookback", minval=1,               group="Volume Thresholds")
float highThresh  = input.float(1.5, title="High Volume Multiplier (Wide)", step=0.1,         group="Volume Thresholds")
float ultraThresh = input.float(2.0, title="Ultra-High Volume Multiplier (Widest)", step=0.1, group="Volume Thresholds")

// --- FOOTPRINT SETTINGS ---
int ticksPerRowInput = input.int(4,   "Ticks Per Footprint Row", minval=1,         group="Footprint Settings")
int vaPercentInput   = input.int(70,  "Value Area %",            minval=1, maxval=100, group="Footprint Settings")
int maxBarsBackInput = input.int(300, "Max Bars for Footprint",  minval=50, maxval=1000, group="Footprint Settings")

// --- CANDLE COLOR INPUTS ---
color bullUltraCol   = input.color(#006400, title="Ultra Bull (#006400)", group="Candle Colors")
color bullHighCol    = input.color(#01d401, title="High Bull (#01d401)",  group="Candle Colors")
color bearUltraCol   = input.color(#880e4f, title="Ultra Bear (#880e4f)", group="Candle Colors")
color bearHighCol    = input.color(#ff00ff, title="High Bear (#ff00ff)", group="Candle Colors")

// --- POC BOX COLOR INPUTS ---
color bullPocFillCol = input.color(color.new(#00FF00, 70), title="Bullish POC Box Fill (#00FF00)", group="POC Box Colors")
color bullPocBordCol = input.color(color.new(#00FF00, 20), title="Bullish POC Box Border",          group="POC Box Colors")
color bearPocFillCol = input.color(color.new(#FF0000, 70), title="Bearish POC Box Fill (#FF0000)",  group="POC Box Colors")
color bearPocBordCol = input.color(color.new(#FF0000, 20), title="Bearish POC Box Border",          group="POC Box Colors")

// ─── Volume and Footprint Calculations ───
float avgVolume = ta.sma(volume, length)
float rVol      = volume / avgVolume

bool isBull     = close >= open
bool isUltra    = rVol >= ultraThresh
bool isHigh     = rVol >= highThresh and not isUltra

float pocUpper    = na
float pocLower    = na
float pocMidPrice = na
float vahUpper    = na
float valLower    = na
float deltaValue  = na

footprint fp = request.footprint(ticksPerRowInput, vaPercentInput)

if barstate.isconfirmed and (bar_index >= last_bar_index - maxBarsBackInput) and not na(fp)
    deltaValue  := fp.delta()
    volume_row pocRow = fp.poc()
    volume_row vahRow = fp.vah()
    volume_row valRow = fp.val()

    pocUpper    := math.min(pocRow.up_price(), high)
    pocLower    := math.max(pocRow.down_price(), low)
    pocMidPrice := (pocUpper + pocLower) / 2.0
    vahUpper    := math.min(vahRow.up_price(), high)
    valLower    := math.max(valRow.down_price(), low)

// ─── POC and VA Filtering and Validation ───
bool bullPassesFilter = not filterPocVa or (not na(pocMidPrice) and not na(vahUpper) and close > pocMidPrice and close > vahUpper)
bool bearPassesFilter = not filterPocVa or (not na(pocMidPrice) and not na(valLower) and close < pocMidPrice and close < valLower)

bool validBullUltra = showUltra and isBull     and isUltra and bullPassesFilter
bool validBullHigh  = showHigh  and isBull     and isHigh  and bullPassesFilter
bool validBearUltra = showUltra and not isBull and isUltra and bearPassesFilter
bool validBearHigh  = showHigh  and not isBull and isHigh  and bearPassesFilter

bool anyValidBull   = validBullUltra or validBullHigh
bool anyValidBear   = validBearUltra or validBearHigh

// ─── Candle Coloring and POC Box Creation ───
color candleColor = na
if validBullUltra
    candleColor := bullUltraCol
else if validBullHigh
    candleColor := bullHighCol
else if validBearUltra
    candleColor := bearUltraCol
else if validBearHigh
    candleColor := bearHighCol

barcolor(candleColor, title="Volume Intensity Color")

if showPocBox and (anyValidBull or anyValidBear) and not na(pocUpper) and not na(pocLower)
    float pocHeight = pocUpper - pocLower
    float doubleTop = pocMidPrice + pocHeight
    float doubleBot = pocMidPrice - pocHeight

    color boxFill   = anyValidBull ? bullPocFillCol : bearPocFillCol
    color boxBorder = anyValidBull ? bullPocBordCol : bearPocBordCol
    box.new(left=bar_index, top=doubleTop, right=bar_index + 1, bottom=doubleBot,
            border_color=boxBorder, border_width=1, bgcolor=boxFill)

// ─── Sequential Stars and Markers ───
var bool was_bearish = false
var bool was_bullish = false

bool bullish_signal  = false
bool bearish_signal  = false

if barstate.isconfirmed
    if sequentialStars
        if anyValidBear
            was_bearish := true
            was_bullish := false
        if anyValidBull
            was_bullish := true
            was_bearish := false

        if anyValidBull and was_bearish
            bullish_signal := true
            was_bearish    := false
        if anyValidBear and was_bullish
            bearish_signal := true
            was_bullish    := false
    else
        bullish_signal := anyValidBull
        bearish_signal := anyValidBear

bool isTiny   = signalSizeInput == "Tiny"
bool isSmall  = signalSizeInput == "Small"
bool isNormal = signalSizeInput == "Normal"
bool isLarge  = signalSizeInput == "Large"

// Bullish Signals
plotshape(showSignals and bullish_signal and isTiny,   style=shape.triangleup, location=location.belowbar, color=bullUltraCol, size=size.tiny,   title="Bullish Volume Signal (Tiny)")
plotshape(showSignals and bullish_signal and isSmall,  style=shape.triangleup, location=location.belowbar, color=bullUltraCol, size=size.small,  title="Bullish Volume Signal (Small)")
plotshape(showSignals and bullish_signal and isNormal, style=shape.triangleup, location=location.belowbar, color=bullUltraCol, size=size.normal, title="Bullish Volume Signal (Normal)")
plotshape(showSignals and bullish_signal and isLarge,  style=shape.triangleup, location=location.belowbar, color=bullUltraCol, size=size.large,  title="Bullish Volume Signal (Large)")

// Bearish Signals
plotshape(showSignals and bearish_signal and isTiny,   style=shape.triangledown, location=location.abovebar, color=bearUltraCol, size=size.tiny,   title="Bearish Volume Signal (Tiny)")
plotshape(showSignals and bearish_signal and isSmall,  style=shape.triangledown, location=location.abovebar, color=bearUltraCol, size=size.small,  title="Bearish Volume Signal (Small)")
plotshape(showSignals and bearish_signal and isNormal, style=shape.triangledown, location=location.abovebar, color=bearUltraCol, size=size.normal, title="Bearish Volume Signal (Normal)")
plotshape(showSignals and bearish_signal and isLarge,  style=shape.triangledown, location=location.abovebar, color=bearUltraCol, size=size.large,  title="Bearish Volume Signal (Large)")

// ─── Alerts ───
alertcondition(bullish_signal, "Bullish Volume Breakout", "Valid Bullish High/Ultra Volume Candle Detected")
alertcondition(bearish_signal, "Bearish Volume Breakout", "Valid Bearish High/Ultra Volume Candle Detected")
````
