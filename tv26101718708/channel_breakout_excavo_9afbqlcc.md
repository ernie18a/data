# Channel Breakout [EXCAVO]

- url: https://www.tradingview.com/script/9aFbqLcc-Channel-Breakout-EXCAVO/
- type: indicator
- pine_id: PUB;81b24db355cd414d83a8c732da9b96fa
- version: 1.0

## Description

Automatic Convergent Channel Detection with Multi-Filter Breakout Confirmation

The [i]Channel Breakout[/i] automatically detects convergent channel patterns — wedges, flags, and triangles — by fitting trendlines through confirmed swing pivots on both boundaries simultaneously. When price breaks out with volume and momentum confirmation, the indicator signals the direction with colored channel lines and an entry label on the breakout candle.

This is not a basic highest/lowest channel. The boundaries are built from verified pivot points, and a convergence filter ensures only genuinely contracting channels qualify — expanding ranges and sideways boxes are excluded.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. It begins scanning for convergent channel
              patterns using swing pivots on the current timeframe.
[b]Step 2[/b]  →  Wait for a channel to form. The indicator draws the upper and
              lower boundary lines in blue while price remains inside.
[b]Step 3[/b]  →  Watch for the breakout signal. When price closes beyond either
              boundary with confirmation, channel lines turn blue (bull) or
              red (bear), and an arrow label appears on the breakout candle.
[b]Step 4[/b]  →  Check the dashboard. It shows the current pattern state,
              breakout strength (Strong / Medium / Weak), and the directional
              bias score that built up while price was inside the channel.
[b]Step 5[/b]  →  Read the strength rating. Strong breakouts combine high volume,
              deep body penetration, and RSI alignment. Weak breakouts show
              fewer confirming factors and may warrant additional analysis.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  Pivot Detection[/b]
Swing highs and lows are identified with ta.pivothigh / ta.pivotlow using a
configurable lookback (Pivot Detection Length, default 5 bars each side). Only
confirmed, closed pivots are used — no repainting. All recent pivots within the
Max Channel Width lookback are stored and passed to the trendline fitting engine.

[b]◆  Best-Fit Trendline Algorithm[/b]
For the upper boundary, the engine tests every pair of stored pivot highs (a, b).
For each candidate line through (a, b), it counts how many other pivot highs lie
within ATR × Touch Tolerance of the line while no pivot exceeds it by more than
ATR × Max Deviation. The line with the most qualifying touches becomes the upper
boundary. The same process runs independently for pivot lows to find the lower
boundary. Both boundaries must exist with at least Min Touches (default 2) to
form a valid channel.

[b]◆  Convergence Filter[/b]
Once both boundaries are found, the engine measures channel width at the earliest
shared bar (widthStart) and at the current bar (widthNow):
convRate = 1 − (widthNow / widthStart)
A channel is only accepted when convRate >= Min Convergence Rate (default 0.02).
This rejects expanding wedges and flat ranges, keeping only contracting patterns.

[b]◆  Breakout Detection and Strength Score[/b]
On each confirmed bar close, the engine projects both boundary lines to the current
bar. A bull breakout fires when close > upper boundary; a bear breakout when
close < lower boundary. The breakout strength score blends five components:
penetration depth relative to ATR (25%), candle body ratio (15%), body commitment
relative to the broken boundary (15%), volume vs SMA-20 spike (25%), and RSI
alignment above/below 50 (20%). Score >= 65 = Strong, >= 35 = Medium, < 35 = Weak.

[b]◆  Confirmation Filters[/b]
Three optional filters gate the breakout signal. Volume Spike Multiplier requires
the breakout bar's volume to exceed 20-bar SMA by a configurable factor. Volume
Contraction Filter requires that average volume inside the channel was lower than
before the channel formed — confirming energy compression. Momentum Confirmation
requires RSI > 50 for bull breakouts and RSI < 50 for bear breakouts. Any filter
can be disabled for forex or low-volume instruments.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Pivot-Confirmed Boundaries[/b]
Most auto-channel scripts use ta.highest / ta.lowest, which anchors lines to the
highest wick in a window regardless of pattern shape. This indicator builds
boundaries only through confirmed swing pivot points, the same anchor logic a
trader would use when drawing manually.

[b]◆  Convergence-Only Filter[/b]
The convRate filter rejects any channel that is not actively narrowing. Sideways
ranges, expanding wedges, and parallel channels are all excluded. Only patterns
where price is compressing toward a decision point qualify.

[b]◆  Best-Fit Touch Counting[/b]
The engine evaluates every pair of pivots and selects the line with the highest
touch count, not just the first two pivots it finds. A channel supported by four
touches is stronger than one supported by two, and the algorithm reflects that
by preferring denser confirmation.

[b]◆  Multi-Component Strength Score[/b]
The breakout strength is not a simple volume check. It combines five independent
signals — penetration depth, body ratio, body commitment relative to the broken
level, volume spike, and momentum direction — into a single 0-100 score that
classifies the breakout as Strong, Medium, or Weak.

[b]◆  Directional Bias Score[/b]
While price is inside the channel, the dashboard tracks a real-time directional
bias built from channel slope (35%), RSI deviation from 50 (35%), and price
position within the channel range (30%). This gives a probabilistic lean on
which side of the channel is more likely to break before the signal fires.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel (top right) with key state metrics:
[list]
[*][b]Status[/b] - Active (channel forming) / Bull Breakout / Bear Breakout / Scanning
[*][b]Direction[/b] - directional bias with arrow and % while channel is active (e.g. ▲ 64%); BULLISH or BEARISH after breakout
[*][b]Strength[/b] - Strong / Medium / Weak (breakout strength score); — while channel is forming
[*][b]Convergence[/b] - narrowing rate of the active channel in %; — when no channel
[/list]

Legend table (bottom left) explains every visual element. Toggle in Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Main Settings[/b]
[list]
[*][b]Pivot Detection Length[/b] - 5 (bars left/right for swing pivot confirmation; lower = more sensitive)
[*][b]Min Touches per Boundary[/b] - 2 (minimum pivot touches required per trendline)
[*][b]Max Channel Width (bars)[/b] - 120 (maximum lookback for channel search)
[*][b]Min Convergence Rate[/b] - 0.02 (minimum narrowing ratio; higher = stricter contraction)
[/list]

[b]Filters[/b]
[list]
[*][b]Volume Spike Mult[/b] - 1.2 (breakout bar volume vs SMA-20; set 0.5 to disable on forex)
[*][b]Volume Contraction Filter[/b] - ON (require declining volume inside the channel)
[*][b]Momentum Confirmation[/b] - ON (RSI > 50 for bull, < 50 for bear)
[/list]

[b]Visual[/b]
[list]
[*][b]Show Channel Patterns[/b] - ON (draw boundary lines)
[*][b]Show Pattern Background[/b] - OFF (subtle bgcolor while inside active channel)
[/list]

[b]Channel Lines[/b]
[list]
[*][b]Line Width[/b] - 2 (boundary line thickness; 1-4)
[/list]

[b]Risk Management[/b]
[list]
[*][b]Show Entry Labels[/b] - ON (arrow label on the breakout candle)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Position[/b] - Top Right (Top Left / Top Right / Bottom Left / Bottom Right)
[*][b]Font Size[/b] - Small (Small / Normal)
[/list]

[b]Advanced[/b]
[list]
[*][b]Touch Tolerance (ATR)[/b] - 0.15 (pivot distance to count as a touch; 0.10-0.25)
[*][b]Max Deviation (ATR)[/b] - 0.30 (maximum pivot overshoot from the line)
[*][b]Min Channel Width (ATR)[/b] - 0.5 (minimum channel width filter)
[/list]

[b]Alerts[/b]
[list]
[*][b]JSON Alerts[/b] - OFF (structured JSON payload for 3Commas, Wunderbit, and similar bots)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Bull Breakout[/b] - price closes above the upper channel boundary with confirmation
[*][b]Bear Breakout[/b] - price closes below the lower channel boundary with confirmation
[*][b]Any Breakout[/b] - either direction; use for a single alert covering both signals
[*][b]New Pattern[/b] - a new convergent channel has been detected and is now active
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// Channel Breakout [EXCAVO]
// -----------------------------------------------------------------------------
// Automatically detects convergent channel patterns and signals breakouts
// with volume and momentum confirmation.
//
//@version=6
indicator(
    title              = "Channel Breakout [EXCAVO]",
    shorttitle         = "EXCAVO Channel Breakout",
    overlay            = true,
    max_lines_count    = 500,
    max_labels_count   = 500,
    max_bars_back      = 5000)

// ══════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════
GRP_MAIN   = "Main Settings"
GRP_FILTER = "Filters"
GRP_VISUAL = "Visual"
GRP_RISK   = "Risk Management"
GRP_LINES  = "Channel Lines"
GRP_DASH   = "Dashboard"
GRP_ALERT  = "Alerts"
GRP_ADV    = "Advanced"

int MAX_PIVOTS         = 60
int RESCAN_INTERVAL    = 10
int MAX_PIVOT_SCAN     = 15
int WARMUP_MINIMUM     = 50
float LINE_EPSILON     = 1e-10
float MAX_WIDTH_MULT   = 10.0
float VOL_CONTR_THRESH = 0.85
float BG_TRANSPARENCY  = 90.0

// ══════════════════════════════════════
// INPUTS
// ══════════════════════════════════════
pivotLenInput = input.int(5, "Pivot Detection Length", minval = 2, maxval = 30, group = GRP_MAIN, tooltip = "Bars left/right for swing pivot detection.\n• Recommended: 3–10")
minTouchesInput = input.int(2, "Min Touches per Boundary", minval = 2, maxval = 6, group = GRP_MAIN, tooltip = "Minimum pivot touches per trendline.\n• Recommended: 2–3")
maxChannelBarsInput = input.int(120, "Max Channel Width (bars)", minval = 20, maxval = 500, step = 10, group = GRP_MAIN, tooltip = "Maximum lookback.\n• Recommended: 60–150")
convergenceMinInput = input.float(0.02, "Min Convergence Rate", minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_MAIN, tooltip = "Min narrowing rate (0–1).\n• Recommended: 0.02–0.15")
touchToleranceInput = input.float(0.15, "Touch Tolerance (ATR)", minval = 0.01, maxval = 0.5, step = 0.01, group = GRP_ADV, tooltip = "Pivot distance to count as touch.\n• Recommended: 0.10–0.25")
deviationMaxInput = input.float(0.3, "Max Deviation (ATR)", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_ADV, tooltip = "Max pivot overshoot.\n• Recommended: 0.2–0.5")
minChannelWidthAtrInput = input.float(0.5, "Min Channel Width (ATR)", minval = 0.1, maxval = 3.0, step = 0.1, group = GRP_ADV, tooltip = "Min width filter.\n• Recommended: 0.3–1.0")

volConfirmInput = input.float(1.2, "Volume Spike Mult", minval = 0.5, maxval = 3.0, step = 0.1, group = GRP_FILTER, tooltip = "Volume vs SMA(20).\n• Set 0.5 to disable on forex")
volContractionInput = input.bool(true, "Volume Contraction Filter", group = GRP_FILTER, tooltip = "Require volume decline inside channel")
momentumFilterInput = input.bool(true, "Momentum Confirmation", group = GRP_FILTER, tooltip = "RSI > 50 for bull, < 50 for bear")

showPatternsInput = input.bool(true, "Show Channel Patterns", group = GRP_VISUAL)
showBgInput       = input.bool(false, "Show Pattern Background", group = GRP_VISUAL, tooltip = "Subtle bgcolor while price is inside channel")
lineWidthInput    = input.int(2, "Line Width", minval = 1, maxval = 4, group = GRP_LINES, tooltip = "Thickness of channel boundary lines.\n• 1 = thin\n• 2 = default\n• 3–4 = bold")
showLevelsInput   = input.bool(true, "Show Entry Labels", group = GRP_RISK, tooltip = "Show blue/red entry labels on breakout candles")

showDashInput = input.bool(true, "Show Dashboard", group = GRP_DASH)
dashPosStr    = input.string("Top Right", "Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = GRP_DASH)
dashSizeInput = input.string("Small", "Font Size", options = ["Small", "Normal"], group = GRP_DASH, tooltip = "Dashboard text size.\n• Small: default\n• Normal: larger, easier to read")

i_json = input.bool(false, "JSON Alerts (for bots)", group = GRP_ALERT,
     tooltip = "JSON format for 3Commas, Wunderbit, etc.")

// ══════════════════════════════════════
// EXCAVO CONSTANTS
// ══════════════════════════════════════
color C_DASH_BG     = color.rgb(50, 53, 60)
color C_DASH_BORDER = color.rgb(80, 85, 95)
color C_DASH_BULL   = color.rgb(80, 140, 255)
color C_DASH_BEAR   = color.rgb(240, 70, 70)
color C_DASH_SIGNAL = color.rgb(255, 170, 50)

color TEXT_BRIGHT   = color.white
color TEXT_MUTED    = color.rgb(160, 163, 175)
color DASH_GREEN    = C_DASH_BULL
color DASH_RED      = C_DASH_BEAR
color DASH_CYAN     = color.rgb(80, 200, 190)

color C_BULL           = color.rgb(0, 60, 180)
color C_BEAR           = color.rgb(200, 40, 40)

color CHANNEL_LINE_COLOR = C_DASH_BULL              // bright blue before breakout
color CHANNEL_FILL_COLOR = color.new(color.white, 100) // no fill

color ENTRY_COLOR  = color.rgb(255, 140, 0)

// ══════════════════════════════════════
// RESOLVERS
// ══════════════════════════════════════
dashSize = switch dashSizeInput
    "Normal" => size.normal
    => size.small

dashPos = switch dashPosStr
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

// ══════════════════════════════════════
// PURE FUNCTIONS (no global dependencies)
// ══════════════════════════════════════
safeDiv(float num, float den, float fallback = 0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

lineAt(float x1, float y1, float x2, float y2, float x) =>
    float dx = x2 - x1
    math.abs(dx) > LINE_EPSILON ? y1 + (y2 - y1) * (x - x1) / dx : y1

// ══════════════════════════════════════
// CORE CALCULATIONS
// ══════════════════════════════════════
float atr20    = nz(ta.atr(20), syminfo.mintick * 10)
float rsiVal   = nz(ta.rsi(close, 14), 50.0)
float volSma   = nz(ta.sma(volume, 20), 0.0)
bool  hasVolume = nz(volume, 0) > 0
float cumVol   = ta.cum(nz(volume, 0))

int WARMUP_BARS = math.max(pivotLenInput * 2 + maxChannelBarsInput, WARMUP_MINIMUM)
bool isWarmedUp = bar_index >= WARMUP_BARS

// ══════════════════════════════════════
// PIVOT DETECTION
// ══════════════════════════════════════
float pivHigh = ta.pivothigh(high, pivotLenInput, pivotLenInput)
float pivLow  = ta.pivotlow(low, pivotLenInput, pivotLenInput)

var array<float> hiPrices = array.new_float()
var array<int>   hiBars   = array.new_int()
var array<float> loPrices = array.new_float()
var array<int>   loBars   = array.new_int()

if not na(pivHigh)
    hiPrices.unshift(pivHigh)
    hiBars.unshift(bar_index - pivotLenInput)
if not na(pivLow)
    loPrices.unshift(pivLow)
    loBars.unshift(bar_index - pivotLenInput)

while hiPrices.size() > MAX_PIVOTS
    hiPrices.pop()
    hiBars.pop()
while loPrices.size() > MAX_PIVOTS
    loPrices.pop()
    loBars.pop()

// ══════════════════════════════════════
// CHANNEL STATE
// ══════════════════════════════════════
var bool     channelActive  = false
var float    hiX1 = 0.0
var float    hiY1 = 0.0
var float    hiX2 = 0.0
var float    hiY2 = 0.0
var float    loX1 = 0.0
var float    loY1 = 0.0
var float    loX2 = 0.0
var float    loY2 = 0.0
var int      chHiTouches   = 0
var int      chLoTouches   = 0
var float    chConvergence = 0.0
var float    chMaxWidth    = 0.0
var int      chDetectBar   = 0
var line     chHiLine      = na
var line     chLoLine      = na
var linefill chFill        = na

var int    breakoutDir     = 0
var int    breakoutBar     = 0
var string breakStrength   = "—"
var bool   breakInvalid    = false
var float  volContraction  = 0.0
var float  entryPrice      = 0.0
var float  dirScore        = 50.0
var int    totalPatterns   = 0
var int    bullBreaks      = 0
var int    bearBreaks      = 0
var int    lastSignalBar   = 0

// Current signal drawings
var line     sigHiLine = na
var line     sigLoLine = na
var linefill sigFill   = na
var label    sigLabel  = na

// ══════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════
formatBreakoutMsg(string action, string strLbl) =>
    string tickerStr = syminfo.tickerid
    string tfStr     = timeframe.period
    string priceStr  = str.tostring(close, format.mintick)
    string jsonMsg   = '{"action":"' + action + '","ticker":"' + tickerStr + '","price":' + priceStr + ',"strength":"' + strLbl + '","timeframe":"' + tfStr + '","indicator":"EXCAVO_Channel_Breakout"}'
    string textMsg   = (action == "bullish" ? "▲" : "▼") + " " + str.upper(action) + " [" + strLbl + "] | " + tickerStr + " | " + tfStr + " | " + priceStr
    i_json ? jsonMsg : textMsg

// ══════════════════════════════════════
// BOUNDARY-FIT CHANNEL DETECTION
// ══════════════════════════════════════
bool newPivot = not na(pivHigh) or not na(pivLow)
bool rescanDue = bar_index % RESCAN_INTERVAL == 0
bool shouldScan = (newPivot or rescanDue) and not channelActive and isWarmedUp and hiPrices.size() >= minTouchesInput and loPrices.size() >= minTouchesInput

bool channelJustDetected = false

if shouldScan
    var array<float> hX = array.new_float()
    var array<float> hY = array.new_float()
    var array<float> lX = array.new_float()
    var array<float> lY = array.new_float()
    hX.clear()
    hY.clear()
    lX.clear()
    lY.clear()

    for i = 0 to math.min(hiPrices.size() - 1, MAX_PIVOT_SCAN)
        if bar_index - hiBars.get(i) <= maxChannelBarsInput
            hX.push(float(hiBars.get(i)))
            hY.push(hiPrices.get(i))
    for i = 0 to math.min(loPrices.size() - 1, MAX_PIVOT_SCAN)
        if bar_index - loBars.get(i) <= maxChannelBarsInput
            lX.push(float(loBars.get(i)))
            lY.push(loPrices.get(i))

    int hCnt = hX.size()
    int lCnt = lX.size()
    float devTol   = atr20 * deviationMaxInput
    float touchTol = atr20 * touchToleranceInput

    float bestHiX1 = 0.0
    float bestHiY1 = 0.0
    float bestHiX2 = 0.0
    float bestHiY2 = 0.0
    int   bestHiTouches = 0
    bool  foundHi = false

    if hCnt >= minTouchesInput
        for a = 0 to hCnt - 2
            for b = a + 1 to hCnt - 1
                float ax = hX.get(a)
                float ay = hY.get(a)
                float bx = hX.get(b)
                float bPy = hY.get(b)
                if math.abs(bx - ax) >= 1.0
                    bool allBelow = true
                    int  touches = 0
                    for k = 0 to hCnt - 1
                        float projY = lineAt(ax, ay, bx, bPy, hX.get(k))
                        float diff = hY.get(k) - projY
                        if diff > devTol
                            allBelow := false
                            break
                        if math.abs(diff) <= touchTol
                            touches += 1
                    if allBelow and touches >= minTouchesInput and touches > bestHiTouches
                        bestHiTouches := touches
                        bestHiX1 := ax
                        bestHiY1 := ay
                        bestHiX2 := bx
                        bestHiY2 := bPy
                        foundHi  := true

    float bestLoX1 = 0.0
    float bestLoY1 = 0.0
    float bestLoX2 = 0.0
    float bestLoY2 = 0.0
    int   bestLoTouches = 0
    bool  foundLo = false

    if lCnt >= minTouchesInput
        for a = 0 to lCnt - 2
            for b = a + 1 to lCnt - 1
                float ax = lX.get(a)
                float ay = lY.get(a)
                float bx = lX.get(b)
                float bPy = lY.get(b)
                if math.abs(bx - ax) >= 1.0
                    bool allAbove = true
                    int  touches = 0
                    for k = 0 to lCnt - 1
                        float projY = lineAt(ax, ay, bx, bPy, lX.get(k))
                        float diff = lY.get(k) - projY
                        if diff < -devTol
                            allAbove := false
                            break
                        if math.abs(diff) <= touchTol
                            touches += 1
                    if allAbove and touches >= minTouchesInput and touches > bestLoTouches
                        bestLoTouches := touches
                        bestLoX1 := ax
                        bestLoY1 := ay
                        bestLoX2 := bx
                        bestLoY2 := bPy
                        foundLo  := true

    if foundHi and foundLo
        float hiMinX = math.min(bestHiX1, bestHiX2)
        float hiMaxX = math.max(bestHiX1, bestHiX2)
        float loMinX = math.min(bestLoX1, bestLoX2)
        float loMaxX = math.max(bestLoX1, bestLoX2)
        float overlapStart = math.max(hiMinX, loMinX)
        float overlapEnd   = math.min(hiMaxX, loMaxX)
        float maxH = 0.0
        if overlapEnd > overlapStart
            int samples = math.max(int((overlapEnd - overlapStart) / 5.0), 2)
            for s = 0 to samples
                float sx = overlapStart + (overlapEnd - overlapStart) * float(s) / float(samples)
                float hu = lineAt(bestHiX1, bestHiY1, bestHiX2, bestHiY2, sx)
                float lo = lineAt(bestLoX1, bestLoY1, bestLoX2, bestLoY2, sx)
                if hu - lo > maxH
                    maxH := hu - lo
        else
            float midX = (hiMinX + hiMaxX + loMinX + loMaxX) / 4.0
            maxH := math.abs(lineAt(bestHiX1, bestHiY1, bestHiX2, bestHiY2, midX) - lineAt(bestLoX1, bestLoY1, bestLoX2, bestLoY2, midX))

        float startX     = math.min(math.min(bestHiX1, bestHiX2), math.min(bestLoX1, bestLoX2))
        float endX       = float(bar_index)
        float upperNow   = lineAt(bestHiX1, bestHiY1, bestHiX2, bestHiY2, endX)
        float lowerNow   = lineAt(bestLoX1, bestLoY1, bestLoX2, bestLoY2, endX)
        float widthNow   = upperNow - lowerNow
        float upperStart = lineAt(bestHiX1, bestHiY1, bestHiX2, bestHiY2, startX)
        float lowerStart = lineAt(bestLoX1, bestLoY1, bestLoX2, bestLoY2, startX)
        float widthStart = upperStart - lowerStart
        float convRate   = widthStart > 0 ? 1.0 - safeDiv(widthNow, widthStart, 1.0) : 0.0
        bool  notInv     = widthNow > 0
        bool  isConv     = convRate >= convergenceMinInput
        bool  widthOk    = widthNow >= atr20 * minChannelWidthAtrInput and widthNow < atr20 * MAX_WIDTH_MULT
        bool  isInside   = notInv and close[1] <= upperNow and close[1] >= lowerNow

        int patStartIdx = int(startX)
        int patBars     = math.max(bar_index - patStartIdx, 1)

        // [FIX 1.5] Guard against patBars > bar_index
        int safPatBars  = math.min(patBars, bar_index)
        int preBars     = math.min(safPatBars, patStartIdx)
        float volInPat  = hasVolume and safPatBars > 0 ? safeDiv(cumVol - nz(cumVol[safPatBars], 0.0), float(safPatBars), volSma) : volSma
        float volPrePat = hasVolume and preBars > 0 ? safeDiv(nz(cumVol[safPatBars], 0.0) - nz(cumVol[safPatBars + preBars], 0.0), float(preBars), volSma) : volSma
        float volContRatio = safeDiv(volInPat, volPrePat, 1.0)
        bool  volContOk = volContractionInput ? (not hasVolume or volContRatio < VOL_CONTR_THRESH) : true

        if notInv and isConv and widthOk and isInside and volContOk
            channelActive  := true
            hiX1 := bestHiX1
            hiY1 := bestHiY1
            hiX2 := bestHiX2
            hiY2 := bestHiY2
            loX1 := bestLoX1
            loY1 := bestLoY1
            loX2 := bestLoX2
            loY2 := bestLoY2
            chHiTouches   := bestHiTouches
            chLoTouches   := bestLoTouches
            chConvergence := convRate
            chMaxWidth    := maxH
            chDetectBar   := bar_index
            breakoutDir   := 0
            breakInvalid  := false
            breakStrength := "—"
            volContraction := volContRatio
            channelJustDetected := true
            totalPatterns += 1

// ── Draw / extend active channel ──
if channelActive and showPatternsInput
    float hiProjNow = lineAt(hiX1, hiY1, hiX2, hiY2, float(bar_index))
    float loProjNow = lineAt(loX1, loY1, loX2, loY2, float(bar_index))

    if channelJustDetected
        int drawStart  = int(math.min(math.min(hiX1, hiX2), math.min(loX1, loX2)))
        float hiStartY = lineAt(hiX1, hiY1, hiX2, hiY2, float(drawStart))
        float loStartY = lineAt(loX1, loY1, loX2, loY2, float(drawStart))
        if not na(chHiLine)
            line.delete(chHiLine)
        if not na(chLoLine)
            line.delete(chLoLine)
        if not na(chFill)
            linefill.delete(chFill)
        chHiLine := line.new(drawStart, hiStartY, bar_index, hiProjNow, color = CHANNEL_LINE_COLOR, width = lineWidthInput)
        chLoLine := line.new(drawStart, loStartY, bar_index, loProjNow, color = CHANNEL_LINE_COLOR, width = lineWidthInput)
        chFill   := linefill.new(chHiLine, chLoLine, CHANNEL_FILL_COLOR)
    else if breakoutDir == 0
        // Only extend while no breakout — freeze channel lines at the breakout bar
        if not na(chHiLine)
            line.set_x2(chHiLine, bar_index)
            line.set_y2(chHiLine, hiProjNow)
        if not na(chLoLine)
            line.set_x2(chLoLine, bar_index)
            line.set_y2(chLoLine, loProjNow)

// ══════════════════════════════════════
// BREAKOUT DETECTION + STRENGTH
// ══════════════════════════════════════
bool rawBullBreak = false
bool rawBearBreak = false
float strengthScore = 0.0
float breakBoundary = 0.0
float oppBoundary   = 0.0

bool channelMature = channelActive and breakoutDir == 0

if channelMature and barstate.isconfirmed and isWarmedUp
    float upper     = lineAt(hiX1, hiY1, hiX2, hiY2, float(bar_index))
    float lower     = lineAt(loX1, loY1, loX2, loY2, float(bar_index))
    float bodyLen   = math.abs(close - open)
    float candleLen = high - low
    float bodyRatio = candleLen > 0 ? bodyLen / candleLen : 0.0
    float bodyMid   = (open + close) / 2.0
    bool  volOk     = hasVolume ? volume > volSma * volConfirmInput : true
    bool  momOk     = momentumFilterInput ? (close > upper ? rsiVal > 50 : rsiVal < 50) : true

    if close > upper
        rawBullBreak := true
        breakBoundary := upper
        oppBoundary   := lower
        float penetration = atr20 > 0 ? math.min((close - upper) / atr20, 2.0) / 2.0 : 0.5
        float bodyCommit  = bodyMid > upper ? 1.0 : 0.3
        float volBonus    = volOk ? 1.0 : 0.4
        float momBonus    = momOk ? 1.0 : 0.4
        strengthScore := (penetration * 0.25 + bodyRatio * 0.15 + bodyCommit * 0.15 + volBonus * 0.25 + momBonus * 0.20) * 100

    if close < lower
        rawBearBreak := true
        breakBoundary := lower
        oppBoundary   := upper
        float penetration = atr20 > 0 ? math.min((lower - close) / atr20, 2.0) / 2.0 : 0.5
        float bodyCommit  = bodyMid < lower ? 1.0 : 0.3
        float volBonus    = volOk ? 1.0 : 0.4
        float momBonus    = momOk ? 1.0 : 0.4
        strengthScore := (penetration * 0.25 + bodyRatio * 0.15 + bodyCommit * 0.15 + volBonus * 0.25 + momBonus * 0.20) * 100

// ══════════════════════════════════════
// DIRECTIONAL SCORING
// ══════════════════════════════════════
if channelActive and breakoutDir == 0
    float upperNow  = lineAt(hiX1, hiY1, hiX2, hiY2, float(bar_index))
    float lowerNow  = lineAt(loX1, loY1, loX2, loY2, float(bar_index))
    float upperPrev = lineAt(hiX1, hiY1, hiX2, hiY2, float(bar_index - 1))
    float lowerPrev = lineAt(loX1, loY1, loX2, loY2, float(bar_index - 1))
    float midSlope  = ((upperNow + lowerNow) - (upperPrev + lowerPrev)) / 2.0
    float slopeBias = midSlope > 0 ? math.min(midSlope / (atr20 * 0.01), 1.0) : math.max(midSlope / (atr20 * 0.01), -1.0)
    float rsiBias   = (rsiVal - 50.0) / 50.0
    float chRange   = upperNow - lowerNow
    float posInCh   = chRange > 0 ? (close - lowerNow) / chRange : 0.5
    float posBias   = (posInCh - 0.5) * 2.0
    float combined  = slopeBias * 0.35 + rsiBias * 0.35 + posBias * 0.30
    dirScore := math.max(0.0, math.min(100.0, 50.0 + combined * 50.0))

if not channelActive
    dirScore := 50.0

// ══════════════════════════════════════
// SIGNAL PROCESSING + TARGET
// ══════════════════════════════════════
bool confirmedBullBreak = rawBullBreak
bool confirmedBearBreak = rawBearBreak

if confirmedBullBreak
    breakoutDir   := 1
    breakoutBar   := bar_index
    entryPrice    := close
    breakStrength := strengthScore >= 65 ? "Strong" : strengthScore >= 35 ? "Medium" : "Weak"
    bullBreaks    += 1
    lastSignalBar  := bar_index
    channelActive := false  // re-enable scanning for next channel
    if not na(chHiLine)
        line.set_color(chHiLine, C_BULL)
        line.set_width(chHiLine, lineWidthInput)
    if not na(chLoLine)
        line.set_color(chLoLine, C_BULL)
        line.set_width(chLoLine, lineWidthInput)

if confirmedBearBreak
    breakoutDir   := -1
    breakoutBar   := bar_index
    entryPrice    := close
    breakStrength := strengthScore >= 65 ? "Strong" : strengthScore >= 35 ? "Medium" : "Weak"
    bearBreaks    += 1
    lastSignalBar  := bar_index
    channelActive := false  // re-enable scanning for next channel
    if not na(chHiLine)
        line.set_color(chHiLine, C_BEAR)
        line.set_width(chHiLine, lineWidthInput)
    if not na(chLoLine)
        line.set_color(chLoLine, C_BEAR)
        line.set_width(chLoLine, lineWidthInput)

// ══════════════════════════════════════
// CHANNEL TIMEOUT
// ══════════════════════════════════════
if channelActive and breakoutDir == 0 and bar_index - chDetectBar > maxChannelBarsInput
    channelActive := false

// ══════════════════════════════════════
// ENTRY LABELS (3-SLOT ROLLING)
// ══════════════════════════════════════
if (confirmedBullBreak or confirmedBearBreak) and showLevelsInput
    // Delete previous signal
    line.delete(sigHiLine)
    line.delete(sigLoLine)
    linefill.delete(sigFill)
    // Purge any accumulated labels (audit F1)
    for lb in label.all
        label.delete(lb)
    // Adopt frozen channel lines as current signal
    sigHiLine := chHiLine
    sigLoLine := chLoLine
    sigFill   := chFill
    // Arrow label on candle
    sigLabel  := label.new(
         bar_index,
         confirmedBullBreak ? low : high,
         confirmedBullBreak ? "▲" : "▼",
         color     = confirmedBullBreak ? C_BULL : C_BEAR,
         textcolor = color.white,
         style     = confirmedBullBreak ? label.style_label_up : label.style_label_down,
         size      = size.normal)
    // Orphan so next channel detection skips deleting these lines
    chHiLine := na
    chLoLine := na
    chFill   := na

bgcolor(showBgInput and channelActive and breakoutDir == 0 ? color.new(C_DASH_BULL, BG_TRANSPARENCY) : na, title = "Active Pattern BG")

// ══════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════
if showDashInput and barstate.islast
    var table dash = table.new(dashPos, 2, 5,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 2,
         frame_color  = C_DASH_BORDER,
         frame_width  = 2)

    table.cell(dash, 0, 0, "EXCAVO",           text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left,  bgcolor = C_DASH_BG)
    table.cell(dash, 1, 0, "Channel Breakout", text_color = color.white,  text_size = size.normal, text_halign = text.align_right, bgcolor = C_DASH_BG)

    // Row 1 — Status
    string statusStr = channelActive ? "Active" : breakoutDir == 1 ? "Bull Breakout" : breakoutDir == -1 ? "Bear Breakout" : "Scanning"
    color  statusCol = channelActive ? color.white : breakoutDir == 1 ? C_DASH_BULL : breakoutDir == -1 ? C_DASH_BEAR : TEXT_MUTED

    // Row 2 — Direction bias (during channel) or breakout direction
    string dirStr = "—"
    color  dirCol = TEXT_MUTED
    if channelActive and breakoutDir == 0
        string dirArrow = dirScore > 50 ? "▲ " : "▼ "
        dirStr := dirArrow + str.tostring(dirScore, "#.0") + "%"
        dirCol := dirScore > 60 ? C_DASH_BULL : dirScore < 40 ? C_DASH_BEAR : color.white
    else if breakoutDir == 1
        dirStr := "BULLISH"
        dirCol := C_DASH_BULL
    else if breakoutDir == -1
        dirStr := "BEARISH"
        dirCol := C_DASH_BEAR

    // Row 3 — Breakout strength
    string strStr = breakStrength == "Strong" ? "Strong" : breakStrength == "Medium" ? "Medium" : breakStrength == "Weak" ? "Weak" : "—"
    color  strClr = breakStrength == "Strong" ? C_DASH_BULL : breakStrength == "Medium" ? C_DASH_SIGNAL : breakStrength == "Weak" ? C_DASH_BEAR : TEXT_MUTED

    // Row 4 — Convergence rate (only meaningful while channel is active)
    string convStr = channelActive ? str.tostring(chConvergence * 100, "#.1") + "%" : "—"
    color  convCol = channelActive ? C_DASH_SIGNAL : TEXT_MUTED

    table.cell(dash, 0, 1, "Status",      text_color = TEXT_MUTED, text_size = dashSize, text_halign = text.align_left,  bgcolor = C_DASH_BG)
    table.cell(dash, 1, 1, statusStr,     text_color = statusCol,  text_size = dashSize, text_halign = text.align_right, bgcolor = C_DASH_BG)
    table.cell(dash, 0, 2, "Direction",   text_color = TEXT_MUTED, text_size = dashSize, text_halign = text.align_left,  bgcolor = C_DASH_BG)
    table.cell(dash, 1, 2, dirStr,        text_color = dirCol,     text_size = dashSize, text_halign = text.align_right, bgcolor = C_DASH_BG)
    table.cell(dash, 0, 3, "Strength",    text_color = TEXT_MUTED, text_size = dashSize, text_halign = text.align_left,  bgcolor = C_DASH_BG)
    table.cell(dash, 1, 3, strStr,        text_color = strClr,     text_size = dashSize, text_halign = text.align_right, bgcolor = C_DASH_BG)
    table.cell(dash, 0, 4, "Convergence", text_color = TEXT_MUTED, text_size = dashSize, text_halign = text.align_left,  bgcolor = C_DASH_BG)
    table.cell(dash, 1, 4, convStr,       text_color = convCol,    text_size = dashSize, text_halign = text.align_right, bgcolor = C_DASH_BG)


// ══════════════════════════════════════
// ALERTS
// ══════════════════════════════════════
if confirmedBullBreak
    alert(formatBreakoutMsg("bullish", breakStrength), alert.freq_once_per_bar_close)

if confirmedBearBreak
    alert(formatBreakoutMsg("bearish", breakStrength), alert.freq_once_per_bar_close)

if channelJustDetected
    string tickerStr = syminfo.tickerid
    string tfStr     = timeframe.period
    string priceStr  = str.tostring(close, format.mintick)
    string jsonMsg   = '{"action":"pattern","ticker":"' + tickerStr + '","price":' + priceStr + ',"timeframe":"' + tfStr + '","indicator":"EXCAVO_Channel_Breakout"}'
    string textMsg   = "● PATTERN | " + tickerStr + " | " + tfStr + " | " + priceStr
    alert(i_json ? jsonMsg : textMsg, alert.freq_once_per_bar_close)
//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if showDashInput and barstate.islast
    var table leg = table.new(position.bottom_left, 2, 6,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 1,
         frame_color  = C_DASH_BORDER,
         frame_width  = 1)

    table.cell(leg, 0, 0, "LEGEND", text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "",       text_size = size.small,   bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "━", text_color = C_DASH_BULL,  text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Bull breakout channel",        text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 0, 2, "━", text_color = C_DASH_BEAR,  text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Bear breakout channel",        text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 0, 3, "▲", text_color = C_DASH_BULL,  text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Bull breakout label",          text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 0, 4, "▼", text_color = C_DASH_BEAR,  text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Bear breakout label",          text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 0, 5, "",   text_size = size.small,   bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "",   text_size = size.small,   bgcolor = C_DASH_BG)



//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(confirmedBullBreak,                       title = "Bull Breakout",  message = "Channel Breakout [EXCAVO]: Bullish breakout on {{ticker}} ({{interval}})")
alertcondition(confirmedBearBreak,                       title = "Bear Breakout",  message = "Channel Breakout [EXCAVO]: Bearish breakout on {{ticker}} ({{interval}})")
alertcondition(confirmedBullBreak or confirmedBearBreak, title = "Any Breakout",   message = "Channel Breakout [EXCAVO]: Breakout on {{ticker}} ({{interval}})")
alertcondition(channelJustDetected,                      title = "New Pattern",    message = "Channel Breakout [EXCAVO]: New channel pattern on {{ticker}} ({{interval}})")
````
