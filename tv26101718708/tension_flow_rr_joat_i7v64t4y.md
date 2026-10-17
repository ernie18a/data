# Tension Flow RR [JOAT]

- url: https://www.tradingview.com/script/I7V64t4y-Tension-Flow-RR-JOAT/
- type: indicator
- pine_id: PUB;c47da36d26a048de953d8264037cfeec
- version: 1.0

## Description

[b]TENSION FLOW RR [JOAT][/b]

A trend-signal engine wrapped in a full risk-reward execution layer — Hull Moving Average baseline, Z-score normalised tension reading, ATR-sized stops and targets, optional R-multiple-triggered trailing stop, and a rolling-window backtest that tracks every closed trade and reports win rate / cumulative R / equity sparkline directly on the chart. Built for traders who care about [i]what happens after the signal fires[/i], not just the signal itself.

[b]Trend signal — HMA + Z-score tension[/b]

Two cleanly chosen primitives:

[list]
[*] [b]Hull Moving Average[/b] (HMA) — a chained-WMA construct that delivers a fast, low-lag trend baseline. The square-root final smoothing step is what makes it noticeably less laggy than EMA at the same length.
[*] [b]Z-score of (close − HMA)[/b] — the residual is normalised by its own rolling stdev so the tension reading is dimensionless and comparable across instruments. |Z| above the overextended threshold (default 2.0) tags the move as overextended in the Energy Dashboard.
[/list]

A new trend signal fires when the configured signal cooldown has elapsed and the directional logic flips. The signal is non-repainting (confirmed on bar close).

[image]https://www.tradingview.com/x/7AUQ1ZBe/[/image]

[b]ATR-sized stops and targets[/b]

Each signal automatically renders:

[list]
[*] [b]SL box[/b] — a translucent box sized at SL-ATR × multiplier (default 2.0 × ATR-200) from entry, drawn in the bear colour.
[*] [b]TP box[/b] — sized at SL distance × Risk:Reward ratio (default 1.0R), drawn in the bull colour.
[*] [b]Trailing-stop line[/b] (optional, JOAT enhancement) — when enabled and price moves more than the activation threshold (in R-multiples) in your favour, the stop ratchets behind price by Trail-ATR × multiplier. Configurable bar-by-bar trail step, optional break-even lock at activation.
[/list]

This is full execution geometry — you can see entry, stop, target, and the trail's path on the chart at all times.

[b]Rolling-window backtest (the headline)[/b]

The script tracks the last [b]N[/b] closed trades (configurable, default 100) and produces live performance statistics that update tick-by-tick:

[list]
[*] Total trades, wins, losses, breakevens.
[*] Win rate, with [b]colour-coded cell[/b] — green above the configured "green" threshold, amber between, red below.
[*] Average R per trade, best R, worst R.
[*] Cumulative R since the start of the window.
[*] Profit factor.
[*] Expectancy in R-multiples.
[*] [b]Unicode equity sparkline[/b] — a compact in-cell chart of the last N cumulative-R points, drawn directly in the dashboard cells with block-character glyphs.
[/list]

Trades are evicted FIFO when the history window is exceeded, so the win rate is always a [i]rolling[/i] read of recent performance, not lifetime stats — which is the right read for a working trader.

[b]Two dashboards[/b]

[list]
[*] [b]Energy Dashboard[/b] (Bottom-Right by default) — compact 22-row read of current Z-score, trend direction, HMA value, overextension flag, ribbon width, ATR, and signal state.
[*] [b]RR Performance Dashboard[/b] (Top-Right by default) — 29-row institutional read of the rolling backtest stats above, plus the equity sparkline.
[/list]

Both are independently positionable, sizeable, and toggle-able. The split lets you run "engine state" on one corner and "PnL state" on the other without overlap.

[b]Trend ribbon[/b]

The HMA is rendered with an ATR-band ribbon (configurable width) whose transparency is dynamically modulated by current Z-score — the ribbon visually [i]breathes[/i] with tension. Toggle off if you prefer a clean line.

[b]Alerts[/b]

Alert conditions are exposed for new signals, SL hits, TP hits, trailing-stop hits, overextension events, and two win-rate threshold alerts: [b]Win-Rate High[/b] (crossover above the configured high level) and [b]Win-Rate Low[/b] (crossunder below the configured low level). Win-rate alerts are suppressed until a minimum sample size has been recorded, so you do not get a 100% win-rate alert from a single lucky trade.

[b]How to read it[/b]

The script is designed to be used as a closed loop:

[list=1]
[*] Take the trend-start signal as the entry. The HMA + Z-score logic is the signal; the SL/TP boxes are the geometry.
[*] If trailing is enabled, the line will appear once unrealised PnL exceeds the activation threshold and will ratchet from there.
[*] When the trade closes, the rolling backtest updates — watch the win-rate colour and the cumulative-R sparkline.
[*] If win-rate trips the low alert, that is the script telling you the current regime does not suit the current settings.
[/list]

The cumulative-R sparkline is the most honest single line on the dashboard — if it is climbing, the engine is doing its job; if it is grinding flat or down, it isn't, and you should re-evaluate parameters or stand aside.

[b]Suggested settings[/b]

Defaults (HMA 50, Z 50, 2.0 R-stop, 1.0 R-target) are calibrated for 1H–4H on liquid markets. For lower timeframes drop both lengths proportionally and consider a Risk:Reward above 1.0 to offset the higher signal frequency. For daily and above, raise lengths and lower the signal cooldown.

[b]Originality / what's reused[/b]

HMA, Z-score, and ATR-sized stops are public-domain primitives, used here as building blocks. The implementation — the Z-normalised tension reading, the R-multiple activation trailing stop with break-even lock, the colour-coded rolling-N backtest, the Unicode equity sparkline rendered inside table cells, the dual-dashboard split, and the sample-gated win-rate alerts — is JOAT-original and tuned together. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. The execution geometry, the rolling-trade tracker, the Z-modulated ribbon, and the sparkline renderer are each isolated so you can adapt any one without reading the whole file. Forks welcome with credit.

[b]Limitations[/b]

The rolling backtest is a [i]descriptive[/i] read of recent signal performance under the current settings — it is not a predictive metric and changing the parameters resets the read. SL / TP geometry assumes a single position per signal direction; the script is not a position manager. Trailing stop fires on confirmed bars; intra-bar movement past the trail level is registered but the close determines the outcome.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title             = "Tension Flow RR [JOAT]",
         shorttitle          = "TFR [JOAT]",
         overlay             = true,
         max_boxes_count     = 500,
         max_lines_count     = 500,
         max_labels_count    = 500,
         max_bars_back       = 5000)

// =================================================================================================
//  SECTION 1  INPUTS
// =================================================================================================

grpSettings  = "Settings  Trend Engine"
grpVisible   = "Visibility"
grpRisk      = "Risk Management  Stops & Targets"
grpTrail     = "Risk Management  Trailing Stop  (JOAT)"
grpBacktest  = "Backtest  Rolling Window"
grpAppear    = "Appearance  Boxes & Ribbon"
grpDash      = "Appearance  Dashboards"
grpAlerts    = "Alerts  Threshold Triggers"

// ---- Settings (HMA + Z-Score core) ----
hmaLen       = input.int(50, "HMA Length", minval = 2, maxval = 1000, group = grpSettings,
     tooltip = "Length of the Hull Moving Average used as the trend baseline. Lower = faster, Higher = smoother.")
zLen         = input.int(50, "Z-Score Length", minval = 2, maxval = 1000, group = grpSettings,
     tooltip = "Lookback period for the standard deviation that normalises (close - HMA) into a Z-Score.")
offsetMult   = input.float(0.5, "Ribbon Width  (ATR mult)", step = 0.05, minval = 0.05, maxval = 5.0,
     group = grpSettings,
     tooltip = "ATR(14) multiplier that controls how wide the trend ribbon is drawn around the HMA.")
signalGap    = input.int(30, "Signal Cooldown  (bars)", minval = 1, maxval = 1000, group = grpSettings,
     tooltip = "Minimum number of bars that must pass before a new BUY/SELL signal can fire. Prevents clustering.")
overextZ     = input.float(2.0, "Overextended |Z|", step = 0.1, minval = 0.5, maxval = 10.0,
     group = grpSettings,
     tooltip = "Absolute Z-Score threshold above which the Energy Dashboard tags the move as Overextended.")

// ---- Visibility ----
showLabels   = input.bool(true, "Show Trend-Start Labels", group = grpVisible,
     tooltip = "Display START labels on the chart when a new trend signal fires.")
showRibbon   = input.bool(true, "Show Trend Ribbon",       group = grpVisible,
     tooltip = "Toggle the HMA  ATR ribbon fill.")
showBaseline = input.bool(true, "Show HMA Baseline",       group = grpVisible,
     tooltip = "Toggle the central Hull Moving Average line.")
showSLBox    = input.bool(true, "Show SL Boxes",           group = grpVisible,
     tooltip = "Toggle the red translucent stop-loss boxes.")
showTPBox    = input.bool(true, "Show TP Boxes",           group = grpVisible,
     tooltip = "Toggle the green translucent take-profit boxes.")
showTrailLn  = input.bool(true, "Show Trailing-Stop Line  (JOAT)", group = grpVisible,
     tooltip = "Render the stepped trailing-stop line for active trades when trailing is enabled.")
showTable    = input.bool(true, "Show Energy Dashboard",   group = grpVisible,
     tooltip = "Show the compact 22 Z-Score / status dashboard (bottom-right).")
showRRTable  = input.bool(true, "Show RR Performance Dashboard", group = grpVisible,
     tooltip = "Show the expanded 29 risk-reward statistics dashboard (top-right).")

// ---- Risk Management ----
atrSLPeriod  = input.int(200, "SL  ATR Period", minval = 1, maxval = 1000, group = grpRisk,
     tooltip = "Length of the ATR used to size the stop-loss distance from entry.")
atrMultSL    = input.float(2.0, "SL  ATR Multiplier", step = 0.1, minval = 0.1, maxval = 20.0,
     group = grpRisk,
     tooltip = "Stop-loss distance from entry expressed in multiples of the SL-ATR.")
rrRatio      = input.float(1.0, "Risk : Reward Ratio", step = 0.1, minval = 0.1, maxval = 20.0,
     group = grpRisk,
     tooltip = "Take-profit is placed at this multiple of the stop-loss distance.")

// ---- Trailing Stop (JOAT) ----
useTrail     = input.bool(false, "Enable Trailing Stop", group = grpTrail,
     tooltip = "When enabled, the SL price moves in the direction of favorable price action by the configured ATR step. Initial SL is still placed at entry, then ratchets in once price moves > start-trigger.")
trailATRLen  = input.int(14, "Trail ATR Period", minval = 1, maxval = 500, group = grpTrail,
     tooltip = "ATR length that drives both the trailing step and the activation distance.")
trailATRMult = input.float(1.0, "Trail Step  (ATR mult)", step = 0.1, minval = 0.1, maxval = 10.0,
     group = grpTrail,
     tooltip = "Distance behind price (in ATR multiples) that the trailing stop sits at each update.")
trailStartR  = input.float(0.5, "Activation Threshold  (R-multiple)", step = 0.1, minval = 0.0, maxval = 10.0,
     group = grpTrail,
     tooltip = "Trailing only kicks in once unrealized PnL exceeds this many R-multiples (e.g. 0.5 = half the initial risk).")
trailLockBE  = input.bool(true, "Lock Break-Even at Activation", group = grpTrail,
     tooltip = "When trailing activates, immediately move SL to entry to remove tail risk before further trailing.")

// ---- Backtest ----
maxTrades    = input.int(100, "Trade History Window", minval = 5, maxval = 500, group = grpBacktest,
     tooltip = "Maximum number of CLOSED trades to keep in the rolling outcome history. Older trades are evicted FIFO.")
winRateGreen = input.float(55.0, "Win-Rate Green Threshold (%)", step = 1.0, minval = 0.0, maxval = 100.0,
     group = grpBacktest,
     tooltip = "Win-rate at or above this value is highlighted green in the dashboard.")
winRateAmber = input.float(40.0, "Win-Rate Amber Threshold (%)", step = 1.0, minval = 0.0, maxval = 100.0,
     group = grpBacktest,
     tooltip = "Win-rate between this and the green threshold is highlighted amber. Below = red.")

// ---- Appearance ----
slBoxAlpha   = input.int(85, "SL/TP Box Transparency", minval = 0, maxval = 100, group = grpAppear,
     tooltip = "0 = fully opaque, 100 = invisible. Default 85 keeps boxes visible without obscuring price.")
ribbonAlphaB = input.int(80, "Ribbon Base Transparency", minval = 0, maxval = 100, group = grpAppear,
     tooltip = "Baseline transparency for the ribbon fill before dynamic Z-modulation.")

// ---- Dashboards ----
dashEnergyPos = input.string("Bottom Right", "Energy Dashboard Position",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left",
                "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = grpDash)
dashRRPos     = input.string("Top Right", "RR Dashboard Position",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left",
                "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"],
     group = grpDash)
dashSize      = input.string("Normal", "Dashboard Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpDash)
sparkLen      = input.int(20, "Equity Sparkline Length", minval = 4, maxval = 60, group = grpDash,
     tooltip = "Number of last cumulative-R points rendered in the Unicode equity sparkline.")

// ---- Alerts ----
wrAlertHigh   = input.float(60.0, "Win-Rate High Alert (%)", step = 1.0, minval = 0.0, maxval = 100.0,
     group = grpAlerts,
     tooltip = "Trigger an alert when win-rate crosses ABOVE this level.")
wrAlertLow    = input.float(40.0, "Win-Rate Low Alert (%)",  step = 1.0, minval = 0.0, maxval = 100.0,
     group = grpAlerts,
     tooltip = "Trigger an alert when win-rate crosses BELOW this level.")
minSampleAlrt = input.int(20, "Min Sample for Win-Rate Alerts", minval = 1, maxval = 500,
     group = grpAlerts,
     tooltip = "Win-rate threshold alerts are suppressed until this many trades have been recorded.")

// =================================================================================================
//  SECTION 2  COLOR PALETTE  (Crimson Pulse - locked)
// =================================================================================================
// Curated palette - electric blue bull / lime-yellow bear on a deep crimson
// ground. Win-green / loss-red preserved for unambiguous RR readability.
const color C_BULL  = #00CFFE   // electric blue  (TP boxes, bull labels)
const color C_BEAR  = #E0F70E   // lime-yellow    (SL boxes, bear labels)
const color C_WIN   = #22C55E   // win-green
const color C_LOSS  = #EF4444   // loss-red
const color C_BG    = #12080C   // crimson-black background
const color C_FRAME = #2A0F18   // deep crimson frame

// Downstream aliases (preserve original symbol names)
color colorBull   = C_BULL
color colorBear   = C_BEAR
color colorBg     = C_BG
color colorFrame  = C_FRAME

// Header / muted text colors derived from frame for subtle premium feel
color colorHdr    = color.new(C_FRAME, 0)
color colorMuted  = color.new(color.gray, 20)
color colorTextLt = color.new(color.white, 0)
color colorWin    = color.new(C_WIN,  15)
color colorLoss   = color.new(C_LOSS, 15)
color colorAmber  = color.new(#f59e0b, 15)

// =================================================================================================
//  SECTION 3  HELPER FUNCTIONS
// =================================================================================================

// 3.1  Two-color RGB linear interpolation
f_colorGradient(float ratio, color colA, color colB) =>
    rA = color.r(colA), gA = color.g(colA), bA = color.b(colA)
    rB = color.r(colB), gB = color.g(colB), bB = color.b(colB)
    rr = rA + int((rB - rA) * ratio)
    rg = gA + int((gB - gA) * ratio)
    rb = bA + int((bB - bA) * ratio)
    color.rgb(rr, rg, rb, 0)

// 3.2  Clamp helper
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(x, hi))

// 3.3  Position string -> position constant
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// 3.4  Size string -> size constant
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// 3.5  Dashboard row gradient background
grad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? minT : (minT + (maxT - minT) * (row / float(rows - 1)))
    color.new(base, int(t))

// 3.6  Hull Moving Average  (used directly via ta.hma; helper retained for reference parity)
hma(float src, int len) =>
    int half = math.max(1, math.round(len / 2))
    int sqrL = math.max(1, math.round(math.sqrt(len)))
    wma1     = ta.wma(src, half)
    wma2     = ta.wma(src, len)
    diff     = 2 * wma1 - wma2
    ta.wma(diff, sqrL)

// 3.7  Equity sparkline glyph from a normalized 0..1 value
sparkGlyph(float v) =>
    string g = ""
    if      v >= 0.875
        g := "█"
    else if v >= 0.750
        g := "▇"
    else if v >= 0.625
        g := "▆"
    else if v >= 0.500
        g := "▅"
    else if v >= 0.375
        g := "▄"
    else if v >= 0.250
        g := "▃"
    else if v >= 0.125
        g := "▂"
    else
        g := "▁"
    g

// 3.8  Build sparkline string from float array
buildSparkline(array<float> arr, int wantLen) =>
    string out = ""
    int n      = array.size(arr)
    if n == 0
        out := "  no data"
    else
        int start = math.max(0, n - wantLen)
        // Find min/max in window for normalization
        float lo  =  1e15
        float hi  = -1e15
        for i = start to n - 1
            float v = array.get(arr, i)
            if v < lo
                lo := v
            if v > hi
                hi := v
        float rng = hi - lo
        for i = start to n - 1
            float v    = array.get(arr, i)
            float norm = rng > 0 ? (v - lo) / rng : 0.5
            out += sparkGlyph(norm)
    out

// 3.9  Format R-multiple distribution into 5 bucket glyphs
//      Buckets: [<-1R] [-1R..0] [0..+1R] [+1R..+2R] [>+2R]
distGlyphs(int b0, int b1, int b2, int b3, int b4, int total) =>
    array<int> counts = array.new_int()
    array.push(counts, b0)
    array.push(counts, b1)
    array.push(counts, b2)
    array.push(counts, b3)
    array.push(counts, b4)
    int maxC = 0
    for c in counts
        if c > maxC
            maxC := c
    string out = ""
    if total <= 0
        out := "        "
    else
        for c in counts
            float ratio = maxC > 0 ? c / float(maxC) : 0.0
            out += sparkGlyph(ratio)
    out

// 3.10  Color a win-rate value by configured thresholds
wrColor(float wr, float greenT, float amberT) =>
    color c = colorLoss
    if      wr >= greenT
        c := colorWin
    else if wr >= amberT
        c := colorAmber
    else
        c := colorLoss
    c

// 3.11  Format R-multiple value succinctly
fmtR(float r) =>
    string sign = r >= 0 ? "+" : ""
    sign + str.tostring(r, "0.00") + "R"

// 3.12  Safe ratio
safeRatio(float a, float b) => b == 0 ? 0.0 : a / b

// =================================================================================================
//  SECTION 4  CORE CALCULATIONS  (HMA + Z-Score + ATR ribbon)
// =================================================================================================

float hmaValue   = ta.hma(close, hmaLen)
bool  hmaSlopeUp = hmaValue > hmaValue[1]
float priceDist  = close - hmaValue
float stdDev     = ta.stdev(priceDist, zLen)
float zScore     = stdDev > 0 ? priceDist / stdDev : 0.0
float absZ       = math.abs(zScore)

// Dynamic transparency (lower = more opaque on stronger Z, capped to safe range)
float dynTransp  = math.min(90.0, math.max(10.0, absZ * 25.0))

// ATR ribbon (visual envelope around HMA)
float atrRibbon  = ta.atr(14)
float upperRib   = hmaValue + atrRibbon * offsetMult
float lowerRib   = hmaValue - atrRibbon * offsetMult

// Dedicated SL-ATR (longer period) and Trail-ATR (faster) per inputs
float atrSL      = ta.atr(atrSLPeriod)
float atrTrail   = ta.atr(trailATRLen)

// Trend-change flag (used to gate brand-new entries on the same bar an HMA flips)
bool trendChange = hmaSlopeUp != hmaSlopeUp[1]

// =================================================================================================
//  SECTION 5  STATE / TRACKING ARRAYS
// =================================================================================================

// 5.1  Cooldown gate
var int lastSignalBar = -100000
bool canTrigger       = (bar_index - lastSignalBar) >= signalGap

// 5.2  Active trade arrays (parallel, FIFO)
var array<box>   activeSLBoxes = array.new<box>()
var array<box>   activeTPBoxes = array.new<box>()
var array<line>  trailLines    = array.new<line>()       // JOAT trailing-stop visual
var array<float> entryPrices   = array.new<float>()
var array<float> slPrices      = array.new<float>()
var array<float> tpPrices      = array.new<float>()
var array<float> initRisks     = array.new<float>()      // |entry - initial SL|, for R calc
var array<float> initSLs       = array.new<float>()      // archived original SL (for break-even logic)
var array<int>   directions    = array.new<int>()
var array<int>   entryBars     = array.new<int>()
var array<bool>  trailActive   = array.new<bool>()       // whether trailing has kicked in for this trade

// 5.3  Closed-trade history buffers
var array<bool>  tradeHistory  = array.new<bool>()       // true = win
var array<float> rMultiples    = array.new<float>()      // realized R per closed trade
var array<float> equityCurve   = array.new<float>()      // cumulative R after each closed trade

// 5.4  Aggregated counters (recomputed each bar from the histories)
var float cumR        = 0.0
var float peakEquity  = 0.0
var float maxDD       = 0.0

// =================================================================================================
//  SECTION 6  SIGNAL ENGINE  (HMA + Z-Score + Cooldown)
// =================================================================================================

bool crossUp   = ta.crossover (close, hmaValue)
bool crossDn   = ta.crossunder(close, hmaValue)

// Confirmed-bar gating prevents intrabar repaint of BUY/SELL labels and SL/TP boxes.
bool bullSignal = barstate.isconfirmed and hmaSlopeUp     and crossUp and canTrigger
bool bearSignal = barstate.isconfirmed and (not hmaSlopeUp) and crossDn and canTrigger

if bullSignal or bearSignal
    lastSignalBar := bar_index

// Confluence-only entry (avoid signals on the same bar as a freshly-flipped HMA)
bool entryAllowed = (bullSignal or bearSignal) and (not trendChange) and (not trendChange[1])

// =================================================================================================
//  SECTION 6.5  ENTRY  Build SL + TP boxes, push to state arrays
// =================================================================================================

if entryAllowed
    float entry  = close
    int   dir    = bullSignal ? 1 : -1
    float slInit = dir == 1 ? entry - (atrSL * atrMultSL) : entry + (atrSL * atrMultSL)
    float risk   = math.abs(entry - slInit)
    float tp     = dir == 1 ? entry + (risk * rrRatio) : entry - (risk * rrRatio)

    // SL box  (bear-tinted)
    box newSL = box.new(
         left         = bar_index,
         top          = dir == 1 ? entry  : slInit,
         right        = bar_index,
         bottom       = dir == 1 ? slInit : entry,
         bgcolor      = showSLBox ? color.new(colorBear, slBoxAlpha) : na,
         border_color = showSLBox ? color.new(colorBear, math.max(0, slBoxAlpha - 45)) : na,
         border_width = 1)

    // TP box  (bull-tinted) with embedded RR text
    box newTP = box.new(
         left         = bar_index,
         top          = dir == 1 ? tp    : entry,
         right        = bar_index,
         bottom       = dir == 1 ? entry : tp,
         bgcolor      = showTPBox ? color.new(colorBull, slBoxAlpha) : na,
         border_color = showTPBox ? color.new(colorBull, math.max(0, slBoxAlpha - 45)) : na,
         border_width = 1,
         text         = "RR " + str.tostring(rrRatio, "0.0"),
         text_color   = colorTextLt,
         text_size    = size.small,
         text_halign  = text.align_right,
         text_valign  = text.align_top)

    // Trailing-stop line  (initially flat at slInit; updated each bar once active)
    line newTrail = line.new(
         x1    = bar_index,
         y1    = slInit,
         x2    = bar_index,
         y2    = slInit,
         color = useTrail and showTrailLn ? color.new(colorBear, 10) : na,
         style = line.style_dashed,
         width = 2)

    array.push(activeSLBoxes, newSL)
    array.push(activeTPBoxes, newTP)
    array.push(trailLines,    newTrail)
    array.push(entryPrices,   entry)
    array.push(slPrices,      slInit)
    array.push(tpPrices,      tp)
    array.push(initRisks,     risk)
    array.push(initSLs,       slInit)
    array.push(directions,    dir)
    array.push(entryBars,     bar_index)
    array.push(trailActive,   false)

// =================================================================================================
//  SECTION 6.6  PER-BAR TRADE MANAGEMENT
//      - update box right edges
//      - update trailing stop (if enabled)
//      - check SL / TP exits
//      - on exit: record R-multiple, update histories, evict
// =================================================================================================

bool tpHitThisBar = false
bool slHitThisBar = false

if array.size(activeSLBoxes) > 0
    for i = array.size(activeSLBoxes) - 1 to 0
        box   currSL  = array.get(activeSLBoxes, i)
        box   currTP  = array.get(activeTPBoxes, i)
        line  currLn  = array.get(trailLines,    i)
        float entry   = array.get(entryPrices,   i)
        float curSL   = array.get(slPrices,      i)
        float curTP   = array.get(tpPrices,      i)
        float risk    = array.get(initRisks,     i)
        int   d       = array.get(directions,    i)
        int   eBar    = array.get(entryBars,     i)
        bool  tActive = array.get(trailActive,   i)

        // -- Trailing stop logic (JOAT) ---------------------------------------
        float newSL = curSL
        if useTrail and risk > 0
            // Compute current unrealized R using favorable extreme
            float favorable = d == 1 ? high : low
            float unrealR   = d == 1 ? (favorable - entry) / risk : (entry - favorable) / risk

            // Activate trailing once unrealized PnL exceeds threshold
            if (not tActive) and unrealR >= trailStartR
                tActive := true
                array.set(trailActive, i, true)
                if trailLockBE
                    newSL := entry            // lock break-even
            // Once active, ratchet the stop in the favorable direction by ATR step
            if tActive
                float trailStep = atrTrail * trailATRMult
                float candidate = d == 1 ? favorable - trailStep : favorable + trailStep
                if d == 1
                    newSL := math.max(newSL, candidate)
                else
                    newSL := math.min(newSL, candidate)

        if newSL != curSL
            array.set(slPrices, i, newSL)
            curSL := newSL
            // Reshape SL box to reflect new stop
            if d == 1
                box.set_top(currSL, entry)
                box.set_bottom(currSL, curSL)
            else
                box.set_top(currSL, curSL)
                box.set_bottom(currSL, entry)

        // Extend boxes' right edges to current bar
        box.set_right(currSL, bar_index)
        box.set_right(currTP, bar_index)

        // Update trailing-stop visual line (stepped: extend right + lift y2 to current SL)
        if useTrail and showTrailLn and not na(currLn)
            line.set_xy1(currLn, eBar, curSL)
            line.set_xy2(currLn, bar_index, curSL)
        else if not na(currLn)
            // hide line if trailing toggled off
            line.set_color(currLn, na)

        // -- Exit checks -------------------------------------------------------
        bool hitSL = d == 1 ? low  <= curSL : high >= curSL
        bool hitTP = d == 1 ? high >= curTP : low  <= curTP

        if hitSL or hitTP
            // Determine outcome  (TP wins, SL handled below; if both, prefer SL  conservative)
            bool isWin = hitTP and not hitSL
            // Realized R-multiple (uses INITIAL risk as denominator  industry standard)
            float realizedR = 0.0
            if risk > 0
                if isWin
                    realizedR := rrRatio
                else
                    // Could be break-even or partial trail-out; compute from actual SL distance
                    float pnl = d == 1 ? (curSL - entry) : (entry - curSL)
                    realizedR := pnl / risk

            // Push into rolling histories (FIFO trim to maxTrades)
            array.push(tradeHistory, isWin)
            array.push(rMultiples,   realizedR)
            cumR += realizedR
            array.push(equityCurve,  cumR)

            if array.size(tradeHistory) > maxTrades
                array.shift(tradeHistory)
            if array.size(rMultiples) > maxTrades
                array.shift(rMultiples)
            if array.size(equityCurve) > maxTrades
                array.shift(equityCurve)

            // Update peak & drawdown trackers
            if cumR > peakEquity
                peakEquity := cumR
            float dd = peakEquity - cumR
            if dd > maxDD
                maxDD := dd

            // Visual: tag closed trade by retinting border slightly
            box.set_border_color(currSL, color.new(colorBear, 30))
            box.set_border_color(currTP, color.new(colorBull, 30))

            // Flag for alerts (latched within this bar across all closures)
            tpHitThisBar := tpHitThisBar or isWin
            slHitThisBar := slHitThisBar or (not isWin)

            // Evict from active arrays
            array.remove(activeSLBoxes, i)
            array.remove(activeTPBoxes, i)
            array.remove(trailLines,    i)
            array.remove(entryPrices,   i)
            array.remove(slPrices,      i)
            array.remove(tpPrices,      i)
            array.remove(initRisks,     i)
            array.remove(initSLs,       i)
            array.remove(directions,    i)
            array.remove(entryBars,     i)
            array.remove(trailActive,   i)

// =================================================================================================
//  SECTION 6.7  DERIVED STATISTICS  (from rolling histories)
// =================================================================================================

int   totalWins   = 0
int   totalLosses = 0
float sumWinR     = 0.0
float sumLossR    = 0.0

if array.size(tradeHistory) > 0
    for i = 0 to array.size(tradeHistory) - 1
        bool w = array.get(tradeHistory, i)
        if w
            totalWins   += 1
        else
            totalLosses += 1

if array.size(rMultiples) > 0
    for i = 0 to array.size(rMultiples) - 1
        float r = array.get(rMultiples, i)
        if r >= 0
            sumWinR  += r
        else
            sumLossR += r              // negative

int   totalClosed = totalWins + totalLosses
float winRate     = totalClosed > 0 ? (totalWins / float(totalClosed)) * 100.0 : 0.0
float profitFact  = math.abs(sumLossR) > 0 ? math.abs(sumWinR) / math.abs(sumLossR) : (sumWinR > 0 ? 999.0 : 0.0)
float avgR        = totalClosed > 0 ? cumR / float(totalClosed) : 0.0

// R-multiple distribution buckets
int b_lt_minus1 = 0      // r < -1
int b_minus1_0  = 0      // -1 <= r < 0
int b_0_1       = 0      //  0 <= r < 1
int b_1_2       = 0      //  1 <= r < 2
int b_gt_2      = 0      //  r >= 2

if array.size(rMultiples) > 0
    for i = 0 to array.size(rMultiples) - 1
        float r = array.get(rMultiples, i)
        if      r < -1
            b_lt_minus1 += 1
        else if r < 0
            b_minus1_0 += 1
        else if r < 1
            b_0_1 += 1
        else if r < 2
            b_1_2 += 1
        else
            b_gt_2 += 1

string distString = distGlyphs(b_lt_minus1, b_minus1_0, b_0_1, b_1_2, b_gt_2, totalClosed)
string sparkStr   = buildSparkline(equityCurve, sparkLen)

// =================================================================================================
//  SECTION 7  PLOTS / FILLS
// =================================================================================================

// Hidden anchors for the ribbon fill
plot_p1   = plot(showRibbon ? upperRib  : na, "Upper Ribbon",
     color = color.new(hmaSlopeUp ? colorBull : colorBear, 60), display = display.none)
plot_p2   = plot(showRibbon ? lowerRib  : na, "Lower Ribbon",
     color = color.new(hmaSlopeUp ? colorBull : colorBear, 60), display = display.none)
plot_pHma = plot(showRibbon ? hmaValue : na, "HMA (anchor)",
     color = color.new(color.gray, 100), display = display.none)

color fillCol  = hmaSlopeUp ? colorBull : colorBear
int   fillAlpT = math.max(50, math.min(98, int(ribbonAlphaB - dynTransp / 4.0)))
int   fillAlpB = 100

// Upper-half: fade from bright (near ribbon top) to transparent (near HMA)
fill(plot_p1, plot_pHma, upperRib, hmaValue,
     color.new(fillCol, fillAlpT), color.new(fillCol, fillAlpB))
// Lower-half: fade from transparent (near HMA) to bright (near ribbon bottom)
fill(plot_pHma, plot_p2, hmaValue, lowerRib,
     color.new(fillCol, fillAlpB), color.new(fillCol, fillAlpT))

// HMA baseline
plot(showBaseline ? hmaValue : na, "HMA Baseline",
     color = color.new(fillCol, 0), linewidth = 2)

// Trend-start labels via plotshape (on standard chart only  House Rule)
plotshape(showLabels and bullSignal,
     title    = "BUY START",
     style    = shape.labelup,
     location = location.belowbar,
     color    = color.new(colorBull, 30),
     text     = "START",
     textcolor= chart.fg_color,
     size     = size.tiny)

plotshape(showLabels and bearSignal,
     title    = "SELL START",
     style    = shape.labeldown,
     location = location.abovebar,
     color    = color.new(colorBear, 30),
     text     = "START",
     textcolor= chart.fg_color,
     size     = size.tiny)

// Subtle bar-tint when overextended (visual cue for energy spikes)
barcolor(absZ > overextZ ? color.new(color.orange, 75) : na,
     title = "Overextended Tint")

// =================================================================================================
//  SECTION 8  DRAWINGS  (boxes + trailing line are managed in 6.5 / 6.6 above)
//      No additional one-shot drawings needed  active boxes update in-place.
// =================================================================================================

// =================================================================================================
//  SECTION 9  DASHBOARDS
//      9A  Energy Dashboard (compact 22)
//      9B  RR Performance Dashboard (29 expanded JOAT version)
// =================================================================================================

// ---- 9A  Energy Dashboard ----
var table trendTable = table.new(strToPos(dashEnergyPos), 2, 4,
     bgcolor      = na,
     frame_color  = colorFrame,
     frame_width  = 1,
     border_color = color.new(colorFrame, 60),
     border_width = 1)

if showTable and barstate.islast
    statusText  = absZ > overextZ ? "Overextended" : absZ > overextZ * 0.5 ? "Strong" : "Building"
    statusColor = absZ > overextZ ? colorAmber : hmaSlopeUp ? color.new(colorBull, 0) : color.new(colorBear, 0)
    string trendDir    = hmaSlopeUp ? "UP" : "DOWN"
    color  trendDirCol = hmaSlopeUp ? color.new(colorBull, 0) : color.new(colorBear, 0)
    color  hdrBg       = color.new(colorFrame, 0)
    color  rowBg       = color.new(colorBg, 5)

    table.cell(trendTable, 0, 0, "TFRR Energy",
         bgcolor          = hdrBg, text_color = colorTextLt,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(trendTable, 1, 0, " v1.0",
         bgcolor          = hdrBg, text_color = statusColor,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    table.cell(trendTable, 0, 1, "Z-Score",
         bgcolor          = grad(rowBg, 1, 4, 80, 92), text_color = colorMuted,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(trendTable, 1, 1, str.tostring(zScore, "0.00"),
         bgcolor          = grad(rowBg, 1, 4, 80, 92), text_color = statusColor,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    table.cell(trendTable, 0, 2, "Status",
         bgcolor          = grad(rowBg, 2, 4, 80, 92), text_color = colorMuted,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(trendTable, 1, 2, statusText,
         bgcolor          = grad(rowBg, 2, 4, 80, 92), text_color = statusColor,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    table.cell(trendTable, 0, 3, "Trend",
         bgcolor          = grad(rowBg, 3, 4, 80, 92), text_color = colorMuted,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(trendTable, 1, 3, trendDir,
         bgcolor          = grad(rowBg, 3, 4, 80, 92), text_color = trendDirCol,
         text_size        = strToSize(dashSize),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

// ---- 9B  RR Performance Dashboard (JOAT 29 expanded) ----
var table rrTable = table.new(strToPos(dashRRPos), 2, 9,
     bgcolor      = na,
     frame_color  = colorFrame,
     frame_width  = 1,
     border_color = color.new(colorFrame, 65),
     border_width = 1)

if showRRTable and barstate.islast
    color  hdrBg     = color.new(colorFrame, 0)
    color  rowBg     = color.new(colorBg, 5)
    color  wrCol     = wrColor(winRate, winRateGreen, winRateAmber)
    pfCol     = profitFact >= 1.5 ? colorWin : profitFact >= 1.0 ? colorAmber : colorLoss
    ddCol     = maxDD <= 1.0 ? colorWin : maxDD <= 3.0 ? colorAmber : colorLoss
    color  avgCol    = avgR >= 0 ? colorWin : colorLoss
    string sizeStr   = dashSize

    // Row 0  Header
    table.cell(rrTable, 0, 0, "RR Performance",
         bgcolor          = hdrBg, text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 0, "RR " + str.tostring(rrRatio, "0.0") + ":1",
         bgcolor          = hdrBg, text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 1  Wins (green-bg)
    table.cell(rrTable, 0, 1, "Wins",
         bgcolor          = grad(rowBg, 1, 9, 82, 94), text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 1, str.tostring(totalWins),
         bgcolor          = color.new(#22c55e, 70),    text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 2  Losses (red-bg)
    table.cell(rrTable, 0, 2, "Losses",
         bgcolor          = grad(rowBg, 2, 9, 82, 94), text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 2, str.tostring(totalLosses),
         bgcolor          = color.new(#ef4444, 70),    text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 3  Win Rate (color graded)
    table.cell(rrTable, 0, 3, "Win Rate",
         bgcolor          = grad(rowBg, 3, 9, 82, 94), text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 3, str.tostring(winRate, "0.00") + "%",
         bgcolor          = wrCol, text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 4  Sample size  (last)
    table.cell(rrTable, 0, 4, "Sample (last)",
         bgcolor          = grad(rowBg, 4, 9, 82, 94), text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 4, str.tostring(totalClosed) + " / " + str.tostring(maxTrades),
         bgcolor          = grad(rowBg, 4, 9, 82, 94), text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 5  R-Multiple histogram  (5 buckets glyph)
    table.cell(rrTable, 0, 5, "R-Dist  <-1 <0 <1 <2 +",
         bgcolor          = grad(rowBg, 5, 9, 82, 94), text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 5, distString,
         bgcolor          = grad(rowBg, 5, 9, 82, 94), text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 6  Profit Factor
    table.cell(rrTable, 0, 6, "Profit Factor",
         bgcolor          = grad(rowBg, 6, 9, 82, 94), text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 6, profitFact >= 999 ? "" : str.tostring(profitFact, "0.00"),
         bgcolor          = pfCol, text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 7  Equity Sparkline
    table.cell(rrTable, 0, 7, "Equity (cumR)",
         bgcolor          = grad(rowBg, 7, 9, 82, 94), text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 7, sparkStr + " " + fmtR(cumR),
         bgcolor          = grad(rowBg, 7, 9, 82, 94), text_color = avgCol,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

    // Row 8  Max Drawdown (R)
    table.cell(rrTable, 0, 8, "Max DD (R)",
         bgcolor          = grad(rowBg, 8, 9, 82, 94), text_color = colorMuted,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_left)
    table.cell(rrTable, 1, 8, "-" + str.tostring(maxDD, "0.00") + "R",
         bgcolor          = ddCol, text_color = colorTextLt,
         text_size        = strToSize(sizeStr),
         text_font_family = font.family_monospace,
         text_halign      = text.align_right)

// =================================================================================================
//  SECTION 10  ALERTS
// =================================================================================================

// Latch previous win-rate to detect crossovers
var float prevWR = 0.0
bool wrCrossUp   = totalClosed >= minSampleAlrt and prevWR < wrAlertHigh and winRate >= wrAlertHigh
bool wrCrossDn   = totalClosed >= minSampleAlrt and prevWR > wrAlertLow  and winRate <= wrAlertLow
prevWR := winRate

alertcondition(bullSignal,
     title   = "TFRR  BUY Signal",
     message = "TFRR [JOAT]  BUY signal on {{ticker}} {{interval}} @ {{close}}")

alertcondition(bearSignal,
     title   = "TFRR  SELL Signal",
     message = "TFRR [JOAT]  SELL signal on {{ticker}} {{interval}} @ {{close}}")

alertcondition(tpHitThisBar,
     title   = "TFRR  TP Hit",
     message = "TFRR [JOAT]  Take-profit hit on {{ticker}} {{interval}}")

alertcondition(slHitThisBar,
     title   = "TFRR  SL Hit",
     message = "TFRR [JOAT]  Stop-loss hit on {{ticker}} {{interval}}")

alertcondition(wrCrossUp,
     title   = "TFRR  Win-Rate High Threshold",
     message = "TFRR [JOAT]  Win-rate crossed ABOVE high threshold")

alertcondition(wrCrossDn,
     title   = "TFRR  Win-Rate Low Threshold",
     message = "TFRR [JOAT]  Win-rate crossed BELOW low threshold")

// =================================================================================================
//  END OF FILE  TENSION FLOW RR [JOAT]
// =================================================================================================
````
