# Confluence Trend Signals

- url: https://www.tradingview.com/script/1ROUM2Yo-Confluence-Trend-Signals/
- type: indicator
- pine_id: PUB;927a592692ec4f499405e4fc844eeac7
- version: 1.0

## Description

[b]Confluence Trend Signals[/b]

The Confluence Trend Signals indicator is a comprehensive, multi-factor tool designed to identify high-probability trading setups by integrating five separate, proven technical analysis components. It generates clear "High Quality BUY" and "High Quality SELL" signals based on the alignment of these different trend and structure elements.-----Key Confluence Components

The indicator combines the following five components to calculate a final confluence score and trigger signals:
🪸 Coral Trend: Acts as the primary trend filter, using both a "Fast Coral" for entries and a "Slow Coral" for bias confirmation.
📏 Price % of Pivots: Measures price's current position relative to recent swing pivots (highs/lows) and includes an optional Higher Timeframe (HTF) Pivot filter for macro trend alignment.
📈 MACD: Utilizes a custom MACD to confirm directional momentum.
🧱 Smart Money Concepts (SMC) - Order Blocks: Detects both Swing and Internal Order Blocks, and checks if price is within "proximity" (defined by ATR) of a relevant unmitigated block.
📊 VWAP Bias: Filters trades based on price position relative to the Volume Weighted Average Price (VWAP), with a momentum bonus for rising/falling VWAP.

[b]-----High Quality Signal Logic[/b]

A signal is generated only when a minimum confluence score is reached and specific gating conditions are met.
High Quality BUY Signal: Requires a Coral Bull Flip, high Pivot % > low Pivot %, MACD bullish alignment, proximity to a bullish Order Block, and price above VWAP (bullish bias).
High Quality SELL Signal: Requires a Coral Bear Flip, high Pivot % < low Pivot %, MACD bearish alignment, proximity to a bearish Order Block, and price below VWAP (bearish bias).

[b]-----Advanced Trade Management[/b]

The indicator includes a robust risk management engine with multiple options:
Stop Loss (SL): Calculates a Stop Loss based on ATR (Average True Range) and includes an option for a Structure-Based SL placed beyond the nearest relevant Order Block or swing point.
Take Profits (TPs): Provides up to three Take Profit levels (TP1, TP2, TP3) based on multiples of the initial risk.
Exit Modes: Supports Trailing Stops (trailing to BE, TP1, TP2) or Fixed Exits with options for a single TP target or Partial Exits (scaling out at multiple TPs).
Confluence Decay Exit: A unique feature that closes the trade if the underlying directional confluence score drops below a dynamic or absolute threshold for a specified number of bars, aiming to "let winners run" until the core thesis is invalidated.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// CONFLUENCE SNIPER [Coral + Pivots + MACD + SMC + VWAP]
// ══════════════════════════════════════════════════════════
// Template/layout structure inspired by Precision Sniper [WillyAlgoTrader]
// Confluence signals by ky_yule1010:
//   1. Coral Trend Indicator (LazyBear, v4 port by Unknown_TracerBunny)
//   2. Price % of Pivots by ky_yule1010
//   3. MACD (custom, ChrisMoody style)
//   4. Smart Money Concepts - Internal & Swing Order Blocks (LuxAlgo)
//   5. VWAP Bias (colored VWAP, direction + momentum)
//
// Version: 1.3.0
// High Quality BUY:  Coral bull flip + highPivot% > lowPivot% + MACD bullish
//                    + price just above a bullish OB (internal or swing)
//                    + price above VWAP (bullish bias)
// High Quality SELL: Coral bear flip + highPivot% < lowPivot% + MACD bearish
//                    + price just below a bearish OB (internal or swing)
//                    + price below VWAP (bearish bias)
indicator(
     title             = "Confluence Trend Signals [Coral+Pivot+MACD+SMC+VWAP]",
     shorttitle        = "ConflTrend",
     overlay           = true,
     max_labels_count  = 500,
     max_lines_count   = 500,
     max_boxes_count   = 500,
     max_bars_back     = 5000)

// ══════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════
GRP_MAIN    = "⚙️ Main Settings"
GRP_CORAL   = "🪸 Coral Trend"
GRP_PIVOT   = "📏 Price % of Pivots"
GRP_MACD    = "📈 MACD"
GRP_VWAP    = "📊 VWAP"
GRP_SMC     = "🧱 Smart Money / Order Blocks"
GRP_ENTRY   = "🎯 Entry Engine"
GRP_RISK    = "🛡 Risk Management"
GRP_VISUAL  = "🎨 Visual Settings"
GRP_DASH    = "📊 Dashboard"
GRP_ALERT   = "🔔 Alerts"
GRP_COLORS  = "🎨 Colors"

INDICATOR_VERSION = "v1.3.0"

BULLISH =  1
BEARISH = -1

// ══════════════════════════════════════
// INPUTS — Main Settings
// ══════════════════════════════════════
sourceInput = input.source(close, "Source", group = GRP_MAIN, tooltip = "Price source for all calculations.\nDefault: close")

// ══════════════════════════════════════
// INPUTS — Coral Trend (primary + slow)
// ══════════════════════════════════════
ctSmooth      = input.int(9,   "Smoothing Period",    minval = 1, group = GRP_CORAL)
ctCD          = input.float(0.4, "Constant D (Fast)",  minval = 0.01, maxval = 1.0, step = 0.05, group = GRP_CORAL, tooltip = "Primary Coral used for entries. Lower D = smoother/laggier.")
ctCDSlow      = input.float(0.6, "Constant D (Slow/Bias)", minval = 0.01, maxval = 1.0, step = 0.05, group = GRP_CORAL, tooltip = "Second Coral using the SAME smoothing period but a different Constant D — acts as a 'slow Coral' bias filter. Higher D produces a much smoother, slower-turning line ideal as a bias confirmation.")
useSlowCoral  = input.bool(false, "Require Slow Coral Alignment", group = GRP_CORAL, tooltip = "If true, entries require the slow Coral to agree with the fast Coral direction. Slow Coral alignment always adds to the confluence score regardless.")
showCoral     = input.bool(true, "Plot Fast Coral Line", group = GRP_CORAL)
showSlowCoral = input.bool(true, "Plot Slow Coral Line", group = GRP_CORAL)

// ══════════════════════════════════════
// INPUTS — Price % of Pivots
// ══════════════════════════════════════
pivotLeft       = input.int(5,   "Left Bars for Pivot",  minval = 1, maxval = 25, group = GRP_PIVOT)
pivotRight      = input.int(5,   "Right Bars for Pivot", minval = 1, maxval = 25, group = GRP_PIVOT)
pivotSmoothLen  = input.int(5,   "Smoothing Length",     minval = 1, maxval = 20, group = GRP_PIVOT, tooltip = "EMA smoothing on the % lines. 1 = no smoothing.")
pivotLongThresh = input.float(99.0, "Strong Bull Threshold %", minval = 50.0, maxval = 110.0, step = 0.5, group = GRP_PIVOT, tooltip = "High-pivot % above this = strong bull confluence bonus")
pivotShortThresh= input.float(99.0, "Strong Bear Threshold %", minval = 50.0, maxval = 110.0, step = 0.5, group = GRP_PIVOT, tooltip = "Low-pivot %  above this = strong bear confluence bonus")

// ── HTF Pivot % ──
useHtfPivot     = input.bool(true, "Enable HTF Pivot %", group = GRP_PIVOT, tooltip = "Enable a higher-timeframe Price % of Pivots filter. When enabled it either REQUIRES alignment (if 'Require HTF Pivot Alignment' is on) or simply adds to the confluence score.")
htfPivotTF      = input.timeframe("30", "HTF Pivot Timeframe", group = GRP_PIVOT, tooltip = "Higher timeframe used for Price % of Pivots bias.\nRecommended: 1H for 5-15M, 4H for 1H, D for 4H")
requireHtfPivot = input.bool(true, "Require HTF Pivot Alignment", group = GRP_PIVOT, tooltip = "If true AND HTF Pivot is enabled, entries require HTF pivot direction to agree with chart-TF pivot direction. If false, alignment just adds to the score.")
showHtfPivotDash = input.bool(true, "Show HTF Pivot on Dashboard", group = GRP_PIVOT)

// ══════════════════════════════════════
// INPUTS — MACD
// ══════════════════════════════════════
macdFast   = input.int(12, "MACD Fast Length",   minval = 1, group = GRP_MACD)
macdSlow   = input.int(26, "MACD Slow Length",   minval = 1, group = GRP_MACD)
macdSignal = input.int(9,  "MACD Signal Length", minval = 1, group = GRP_MACD)

// ══════════════════════════════════════
// INPUTS — VWAP
// ══════════════════════════════════════
useVWAP         = input.bool(true, "Enable VWAP Filter", group = GRP_VWAP, tooltip = "Enable VWAP as a confluence component.\nBullish bias: price above VWAP.\nBearish bias: price below VWAP.\nAlways adds to the confluence score when enabled; optionally acts as a hard gate.")
requireVWAP     = input.bool(false, "Require VWAP Alignment", group = GRP_VWAP, tooltip = "If true, entries ONLY fire when price is on the correct side of VWAP (above for longs, below for shorts). If false, VWAP alignment just adds to the confluence score.")
vwapRisingLen   = input.int(2, "VWAP Rising/Falling Lookback", minval = 1, maxval = 10, group = GRP_VWAP, tooltip = "Number of bars to determine if VWAP is rising or falling.\nRising VWAP + price above = stronger bull bias (bonus score).\nFalling VWAP + price below = stronger bear bias (bonus score).")
showVWAP        = input.bool(true, "Plot VWAP Line", group = GRP_VWAP)
vwapLineWidth   = input.int(2, "VWAP Line Width", minval = 1, maxval = 5, group = GRP_VWAP)

// ══════════════════════════════════════
// INPUTS — Smart Money Concepts (Order Blocks)
// ══════════════════════════════════════
swingLen         = input.int(50, "Swing Pivot Length",    minval = 10, group = GRP_SMC, tooltip = "Bars for swing-structure pivot detection")
internalLen      = input.int(5,  "Internal Pivot Length", minval = 3,  group = GRP_SMC, tooltip = "Bars for internal-structure pivot detection")
obProximityATR   = input.float(1.0, "OB Proximity (ATR)", minval = 0.1, maxval = 5.0, step = 0.1, group = GRP_SMC, tooltip = "Max distance from order block (in ATR units) to consider price 'just above/below' the OB.")
showOBs          = input.bool(true, "Show Order Blocks",  group = GRP_SMC)
obFilterATR      = input.int(200, "OB Volatility ATR Length", minval = 10, group = GRP_SMC, tooltip = "Used to filter overly volatile bars out of OB detection")

// ══════════════════════════════════════
// INPUTS — Entry Engine
// ══════════════════════════════════════
minScoreInput = input.int(6, "Min Confluence Score", minval = 1, maxval = 10, group = GRP_ENTRY, tooltip = "Minimum confluence points to trigger a signal.\nMax possible: ~9.25 (with all bonuses including HTF Pivot + VWAP)")
requireOB     = input.bool(false, "Require OB Proximity for Entry", group = GRP_ENTRY, tooltip = "If true, entries ONLY fire when price is within proximity of a matching order block. If false, OB just adds score.")
requireCoralFlip = input.bool(false, "Require Coral Flip Bar", group = GRP_ENTRY, tooltip = "If true, entry must occur on the bar Coral flips direction. If false, any bar with Coral in the right direction is eligible.")

// ══════════════════════════════════════
// INPUTS — Risk Management
// ══════════════════════════════════════
atrLenInput    = input.int(14, "ATR Length", minval = 5, maxval = 50, group = GRP_RISK)
slMultInput    = input.float(3, "SL ATR Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_RISK, tooltip = "Stop Loss distance = ATR × this value.")
tp1MultInput   = input.float(1.0, "TP1 Risk:Reward",   minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_RISK)
tp2MultInput   = input.float(2.0, "TP2 Risk:Reward",   minval = 1.0, maxval = 8.0, step = 0.1, group = GRP_RISK)
tp3MultInput   = input.float(3.0, "TP3 Risk:Reward",   minval = 1.5, maxval = 12.0, step = 0.5, group = GRP_RISK)
useTrailInput  = input.bool(true, "Enable Trailing Stop", group = GRP_RISK, tooltip = "After TP1 → trail to BE. After TP2 → trail to TP1. After TP3 → trail to TP2.\nWhen enabled, this overrides the Exit Mode below: trailing logic handles all exits.")
useStructureSL = input.bool(true, "Structure-Based SL", group = GRP_RISK, tooltip = "Place SL beyond nearest OB edge or swing, whichever is tighter but at least min-distance.")
swingLookback  = input.int(10, "Swing Lookback for SL", minval = 3, maxval = 30, group = GRP_RISK)

// --- Exit Mode (used when trailing stop is OFF) ---
exitModeInput = input.string("Partial Exits", "Exit Mode (no-trail)", options = ["Single TP", "Partial Exits"], group = GRP_RISK, tooltip = "How the backtest models exits when trailing stop is DISABLED:\n\n• Single TP: full position exits at one chosen TP level (TP1/TP2/TP3). Binary win/loss against the fixed SL.\n\n• Partial Exits: position is scaled out at TP1/TP2/TP3 using the percentages below. Remaining position after partial exits runs until it either hits the next TP or the original SL.\n\nIgnored when trailing stop is ON.")
singleTPInput = input.string("TP2", "Single TP Target", options = ["TP1", "TP2", "TP3"], group = GRP_RISK, tooltip = "Which TP level to use when Exit Mode = 'Single TP'.")
partialTP1Input = input.float(40.0, "Partial % at TP1", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_RISK, tooltip = "Percentage of position to exit at TP1. The three partial percentages should sum to 100 (script will normalize if they don't).")
partialTP2Input = input.float(40.0, "Partial % at TP2", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_RISK)
partialTP3Input = input.float(20.0, "Partial % at TP3", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_RISK, tooltip = "Percentage of position to exit at TP3. Any residual (if percentages < 100) runs to SL or opposing signal.")

// --- Confluence Decay Exit ---
useDecayExit      = input.bool(true, "Enable Confluence Decay Exit", group = GRP_RISK, tooltip = "Close the trade when the MAINTENANCE SCORE (directional confluence components, excluding one-shot flip/cross bonuses) drops below a threshold.\n\nIntended as a 'let winners run' mechanism: trade stays open as long as the reasons for entry remain true, and exits when the underlying thesis decays — rather than trailing on price.\n\nCan be combined with trailing stop and partial exits: decay exit is checked IN ADDITION TO those mechanisms, whichever fires first closes the remaining position.")
decayThreshMode   = input.string("% of Entry Score", "Decay Threshold Mode", options = ["Absolute", "% of Entry Score"], group = GRP_RISK, tooltip = "How the decay exit threshold is interpreted:\n\n• Absolute: exit when maintenance score drops below this fixed value (e.g. 3.0)\n\n• % of Entry Score: exit when maintenance score drops below this % of the score captured at entry (e.g. 50% of a 5.0 entry = exit below 2.5). Adapts to signal quality: strong setups must decay more before exit.")
decayAbsThresh    = input.float(3.0, "Decay Absolute Threshold", minval = 0.0, maxval = 7.0, step = 0.25, group = GRP_RISK, tooltip = "Used when Threshold Mode = 'Absolute'. Exit when maintenance score < this.")
decayPctThresh    = input.float(80.0, "Decay % of Entry Score", minval = 10.0, maxval = 95.0, step = 5.0, group = GRP_RISK, tooltip = "Used when Threshold Mode = '% of Entry Score'. Exit when maintenance score falls below this % of the score at entry.")
decayConfirmBars  = input.int(2, "Decay Confirmation Bars", minval = 1, maxval = 10, group = GRP_RISK, tooltip = "Number of CONSECUTIVE bars the maintenance score must stay below threshold before exit fires. Higher = fewer whipsaws but later exits. 1 = exit on first bar below.")
decayMinTPHit     = input.string("None", "Decay Exit Only After", options = ["None", "TP1", "TP2"], group = GRP_RISK, tooltip = "Restrict decay exit so it can only fire AFTER a certain TP has been hit. Useful if you want decay to be strictly a 'protect profits on the runner' mechanism rather than an early exit on unfavorable trades.\n\n• None: decay can fire any time after entry\n• TP1: decay only fires after TP1 has been hit\n• TP2: decay only fires after TP2 has been hit")

// ══════════════════════════════════════
// INPUTS — Visual Settings
// ══════════════════════════════════════
themeInput        = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL)
showSignalsInput  = input.bool(true, "Show Buy/Sell Signals", group = GRP_VISUAL)
signalSizeInput   = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GRP_VISUAL)
showTPSLInput     = input.bool(true, "Show TP/SL Lines", group = GRP_VISUAL)
showTrailInput    = input.bool(true, "Show Trailing Stop", group = GRP_VISUAL)
showBgInput       = input.bool(false, "Show Background Color", group = GRP_VISUAL)
showWatermarkInput= input.bool(true, "Show Watermark", group = GRP_VISUAL)
showGradeInput    = input.bool(true, "Show Signal Grade", group = GRP_VISUAL)
labelOffsetInput  = input.int(20, "Label Offset (bars)", minval = 5, maxval = 50, group = GRP_VISUAL)

// ══════════════════════════════════════
// INPUTS — Dashboard
// ══════════════════════════════════════
showDashInput   = input.bool(true, "Show Dashboard", group = GRP_DASH)
showBtDashInput = input.bool(true, "Show Backtest Stats", group = GRP_DASH)
dashPosStr      = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = GRP_DASH)

// ══════════════════════════════════════
// INPUTS — Alerts
// ══════════════════════════════════════
webhookInput = input.bool(false, "Webhook JSON Format", group = GRP_ALERT)

// ══════════════════════════════════════
// INPUTS — Colors
// ══════════════════════════════════════
bullColorInput    = input.color(#00E676, "Bull",    inline = "sig_colors", group = GRP_COLORS)
bearColorInput    = input.color(#FF5252, "Bear",    inline = "sig_colors", group = GRP_COLORS)
neutralColorInput = input.color(#FFEB3B, "Neutral", inline = "sig_colors", group = GRP_COLORS)
bullOBColorInput  = input.color(color.new(#1848cc, 75), "Bullish OB", group = GRP_COLORS)
bearOBColorInput  = input.color(color.new(#b22833, 75), "Bearish OB", group = GRP_COLORS)

// ══════════════════════════════════════
// THEME DETECTION & COLORS
// ══════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TEXT_COLOR    = isDark ? #E0E0E0 : #1A1A1A
TEXT_MUTED    = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TEXT_BRIGHT   = isDark ? #FFFFFF : #000000
TABLE_BG      = isDark ? color.new(#131722, 5) : color.new(#FFFFFF, 5)
TABLE_BORDER  = isDark ? color.new(#2A2E39, 0) : color.new(#D0D0D0, 0)
TABLE_ROW_ALT = isDark ? color.new(#1C2030, 0) : color.new(#F0F4F8, 0)
HEADER_BG     = color.new(#2962FF, 0)
HEADER_TEXT   = #FFFFFF
LABEL_TEXT    = #FFFFFF
LINE_SUBTLE   = isDark ? color.new(#555555, 0) : color.new(#AAAAAA, 0)
WM_COLOR      = isDark ? color.new(#FFFFFF, 80) : color.new(#000000, 80)
BULL_BG       = color.new(bullColorInput, 88)
BEAR_BG       = color.new(bearColorInput, 88)
SL_COLOR      = color.new(#FF1744, 0)
TP_COLOR      = color.new(#00E676, 0)
TRAIL_COLOR   = color.new(#FF9800, 0)
ENTRY_COLOR   = color.new(#2979FF, 0)
BT_HEADER_BG  = color.new(#6200EA, 0)
DASH_BULL     = isDark ? bullColorInput    : #00873E
DASH_BEAR     = isDark ? bearColorInput    : #D32F2F
DASH_NEUTRAL  = isDark ? neutralColorInput : #B8860B

// ══════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════
safeDiv(float num, float den, float fallback = 0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

safeStr(float val, string fmt = "#.##") =>
    na(val) ? "—" : str.tostring(val, fmt)

getSwingLow(int lookback) =>
    float swLow = low
    for i = 1 to lookback
        if nz(low[i], low) < swLow
            swLow := nz(low[i], low)
    swLow

getSwingHigh(int lookback) =>
    float swHigh = high
    for i = 1 to lookback
        if nz(high[i], high) > swHigh
            swHigh := nz(high[i], high)
    swHigh

getDashPos(string pos) =>
    switch pos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>                position.top_right

getSignalSize(string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

getGrade(float score) =>
    score >= 7.0 ? "A+" : score >= 5.5 ? "A" : score >= 4.0 ? "B" : "C"

// ══════════════════════════════════════
// CORAL TREND FUNCTION (LazyBear)
// ══════════════════════════════════════
coralTrend(float src, int sm, float cd) =>
    float di  = (sm - 1.0) / 2.0 + 1.0
    float c1  = 2.0 / (di + 1.0)
    float c2  = 1.0 - c1
    float c3  = 3.0 * (cd * cd + cd * cd * cd)
    float c4  = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
    float c5  = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd
    var float i1 = na
    var float i2 = na
    var float i3 = na
    var float i4 = na
    var float i5 = na
    var float i6 = na
    i1 := c1 * src + c2 * nz(i1[1])
    i2 := c1 * i1  + c2 * nz(i2[1])
    i3 := c1 * i2  + c2 * nz(i3[1])
    i4 := c1 * i3  + c2 * nz(i4[1])
    i5 := c1 * i4  + c2 * nz(i5[1])
    i6 := c1 * i5  + c2 * nz(i6[1])
    float cto = -cd * cd * cd * i6 + c3 * i5 + c4 * i4 + c5 * i3
    int dir = cto > nz(cto[1]) ? 1 : cto < nz(cto[1]) ? -1 : 0
    [cto, dir]

// ══════════════════════════════════════
// CORE CALCULATIONS
// ══════════════════════════════════════
int WARMUP_BARS = math.max(swingLen, obFilterATR, 50)
bool isWarmedUp = bar_index >= WARMUP_BARS

string sigSize = getSignalSize(signalSizeInput)

// ── Coral Trend — Fast (primary, for entries) ──
[ctVal, ctDir] = coralTrend(sourceInput, ctSmooth, ctCD)
bool ctBull     = ctDir ==  1
bool ctBear     = ctDir == -1
bool ctFlipBull = ctBull and ctDir[1] != 1
bool ctFlipBear = ctBear and ctDir[1] != -1

// ── Coral Trend — Slow (bias filter, same smoothing / different Constant D) ──
[ctSlowVal, ctSlowDir] = coralTrend(sourceInput, ctSmooth, ctCDSlow)
bool ctSlowBull = ctSlowDir ==  1
bool ctSlowBear = ctSlowDir == -1

// ── ATR ──
float atrVal = nz(ta.atr(atrLenInput), high - low)

// ── MACD ──
float fastMA = ta.ema(sourceInput, macdFast)
float slowMA = ta.ema(sourceInput, macdSlow)
float macdLine = fastMA - slowMA
float macdSig  = ta.sma(macdLine, macdSignal)
float macdHist = macdLine - macdSig
bool macdBull  = macdLine > macdSig and macdHist > 0
bool macdBear  = macdLine < macdSig and macdHist < 0
bool macdBullCross = ta.crossover(macdLine, macdSig)
bool macdBearCross = ta.crossunder(macdLine, macdSig)

// ── VWAP ──
// ta.vwap() returns the session VWAP. On non-intraday charts it falls back
// to a cumulative VWAP which is still directionally useful.
float vwapVal     = ta.vwap(close)
bool  vwapIsValid = useVWAP and not na(vwapVal)

// Bias: price position relative to VWAP
bool vwapBull = vwapIsValid and close > vwapVal
bool vwapBear = vwapIsValid and close < vwapVal

// Momentum: VWAP itself rising or falling over N bars (like the v3 snippet)
bool vwapRising  = vwapIsValid and ta.rising(vwapVal, vwapRisingLen)
bool vwapFalling = vwapIsValid and ta.falling(vwapVal, vwapRisingLen)

// Combined momentum confirmation: price above a rising VWAP, or below a falling one
bool vwapMomentumBull = vwapBull and vwapRising
bool vwapMomentumBear = vwapBear and vwapFalling

// ── Price % of Pivots (helper for both chart-TF and HTF) ──
// Returns [smoothedHighPct, smoothedLowPct] given the current context's price & pivots.
calcPivotPct(int lb, int rb, int smLen) =>
    float ph = ta.pivothigh(high, lb, rb)
    float pl = ta.pivotlow(low,  lb, rb)
    var float lastPH = na
    var float lastPL = na
    if not na(ph)
        lastPH := ph
    if not na(pl)
        lastPL := pl
    float hp = na(lastPH) ? na : (close / lastPH) * 100.0
    float lp = na(lastPL) ? na : (lastPL / close) * 100.0
    [ta.ema(hp, smLen), ta.ema(lp, smLen)]

// Chart-TF pivot %
[smoothedHighPct, smoothedLowPct] = calcPivotPct(pivotLeft, pivotRight, pivotSmoothLen)
bool pivotBull       = not na(smoothedHighPct) and not na(smoothedLowPct) and smoothedHighPct > smoothedLowPct
bool pivotBear       = not na(smoothedHighPct) and not na(smoothedLowPct) and smoothedLowPct  > smoothedHighPct
bool pivotStrongBull = not na(smoothedHighPct) and smoothedHighPct > pivotLongThresh
bool pivotStrongBear = not na(smoothedLowPct)  and smoothedLowPct  > pivotShortThresh

// HTF pivot %
[htfHighPctRaw, htfLowPctRaw] = request.security(syminfo.tickerid, htfPivotTF, calcPivotPct(pivotLeft, pivotRight, pivotSmoothLen), lookahead = barmerge.lookahead_off)
float htfHighPct = useHtfPivot ? htfHighPctRaw : na
float htfLowPct  = useHtfPivot ? htfLowPctRaw  : na
bool htfPivotBull = useHtfPivot and not na(htfHighPct) and not na(htfLowPct) and htfHighPct > htfLowPct
bool htfPivotBear = useHtfPivot and not na(htfHighPct) and not na(htfLowPct) and htfLowPct  > htfHighPct

// ══════════════════════════════════════
// ORDER BLOCK DETECTION (SMC-style, simplified)
// ══════════════════════════════════════
// UDT for order block
type orderBlock
    float barHigh
    float barLow
    int   barTime
    int   bias     // BULLISH or BEARISH
    bool  internal // true = internal OB, false = swing OB
    bool  mitigated
    box   b_ox

// storage
var array<orderBlock> bullOBs = array.new<orderBlock>()
var array<orderBlock> bearOBs = array.new<orderBlock>()

// Parsed highs/lows filtering out high-volatility bars (LuxAlgo style)
float obAtr = ta.atr(obFilterATR)
bool  highVolBar = (high - low) >= (2 * obAtr)
float parsedHigh = highVolBar ? low  : high
float parsedLow  = highVolBar ? high : low

// Track pivot states for swing vs internal structures
var float swingHighLevel = na
var int   swingHighBar   = na
var bool  swingHighCrossed = false
var float swingLowLevel  = na
var int   swingLowBar    = na
var bool  swingLowCrossed = false

var float intHighLevel = na
var int   intHighBar   = na
var bool  intHighCrossed = false
var float intLowLevel  = na
var int   intLowBar    = na
var bool  intLowCrossed = false

// Detect new pivots — swing
float phSwing = ta.pivothigh(high, swingLen, swingLen)
float plSwing = ta.pivotlow(low,   swingLen, swingLen)
if not na(phSwing)
    swingHighLevel := phSwing
    swingHighBar   := bar_index - swingLen
    swingHighCrossed := false
if not na(plSwing)
    swingLowLevel  := plSwing
    swingLowBar    := bar_index - swingLen
    swingLowCrossed := false

// Detect new pivots — internal
float phInt = ta.pivothigh(high, internalLen, internalLen)
float plInt = ta.pivotlow(low,   internalLen, internalLen)
if not na(phInt)
    intHighLevel := phInt
    intHighBar   := bar_index - internalLen
    intHighCrossed := false
if not na(plInt)
    intLowLevel  := plInt
    intLowBar    := bar_index - internalLen
    intLowCrossed := false

// Helper: when price breaks above a pivot-high, the order block is the
// highest-high / lowest-low candle between the pivot and the break
storeOB(float pivotLvl, int pivotBar, int bias, bool internal) =>
    if not na(pivotBar) and bar_index > pivotBar
        float obHigh = parsedHigh
        float obLow  = parsedLow
        int   obBar  = bar_index
        int lookback = bar_index - pivotBar
        if lookback > 0 and lookback < 500
            float bestH = parsedHigh
            float bestL = parsedLow
            int   bestBar = bar_index
            for i = 0 to lookback
                float ph = nz(parsedHigh[i], high[i])
                float pl = nz(parsedLow[i],  low[i])
                if bias == BEARISH and ph > bestH
                    bestH := ph
                    bestL := nz(low[i], low)
                    bestBar := bar_index - i
                if bias == BULLISH and pl < bestL
                    bestL := pl
                    bestH := nz(high[i], high)
                    bestBar := bar_index - i
            obHigh := bestH
            obLow  := bestL
            obBar  := bestBar
        orderBlock ob = orderBlock.new(obHigh, obLow, time[bar_index - obBar], bias, internal, false, na)
        if bias == BULLISH
            bullOBs.unshift(ob)
            if bullOBs.size() > 20
                orderBlock old = bullOBs.pop()
                if not na(old.b_ox)
                    box.delete(old.b_ox)
        else
            bearOBs.unshift(ob)
            if bearOBs.size() > 20
                orderBlock old = bearOBs.pop()
                if not na(old.b_ox)
                    box.delete(old.b_ox)

// Detect structure breaks to spawn order blocks
if not na(swingHighLevel) and not swingHighCrossed and ta.crossover(close, swingHighLevel)
    storeOB(swingHighLevel, swingHighBar, BULLISH, false)
    swingHighCrossed := true
if not na(swingLowLevel) and not swingLowCrossed and ta.crossunder(close, swingLowLevel)
    storeOB(swingLowLevel, swingLowBar, BEARISH, false)
    swingLowCrossed := true
if not na(intHighLevel) and not intHighCrossed and ta.crossover(close, intHighLevel)
    storeOB(intHighLevel, intHighBar, BULLISH, true)
    intHighCrossed := true
if not na(intLowLevel) and not intLowCrossed and ta.crossunder(close, intLowLevel)
    storeOB(intLowLevel, intLowBar, BEARISH, true)
    intLowCrossed := true

// Mitigation: remove OBs once fully violated
mitigateOBs(array<orderBlock> obArr, int bias) =>
    int sz = obArr.size()
    if sz > 0
        for i = sz - 1 to 0
            orderBlock ob = obArr.get(i)
            bool mitigated = bias == BULLISH ? close < ob.barLow : close > ob.barHigh
            if mitigated
                if not na(ob.b_ox)
                    box.delete(ob.b_ox)
                obArr.remove(i)
mitigateOBs(bullOBs, BULLISH)
mitigateOBs(bearOBs, BEARISH)

// ── Proximity check ──
float proxDist = atrVal * obProximityATR
bool nearBullOB = false
if bullOBs.size() > 0
    for i = 0 to bullOBs.size() - 1
        orderBlock ob = bullOBs.get(i)
        if close >= ob.barLow and close <= ob.barHigh + proxDist
            nearBullOB := true
            break
bool nearBearOB = false
if bearOBs.size() > 0
    for i = 0 to bearOBs.size() - 1
        orderBlock ob = bearOBs.get(i)
        if close <= ob.barHigh and close >= ob.barLow - proxDist
            nearBearOB := true
            break

// ══════════════════════════════════════
// CONFLUENCE SCORING
// ══════════════════════════════════════
// Max reachable: Fast Coral dir (1) + Fast Coral flip (0.5) + Slow Coral (0.5) +
// Pivot dir (1) + Pivot strong (1) + HTF Pivot (0.75) + MACD dir (1) +
// MACD cross (0.5) + OB proximity (1.5) + VWAP bias (1.0) + VWAP momentum (0.5) = 9.25
float bullScore = 0.0
bullScore += ctBull           ? 1.0  : 0.0
bullScore += ctFlipBull       ? 0.5  : 0.0
bullScore += ctSlowBull       ? 0.5  : 0.0
bullScore += pivotBull        ? 1.0  : 0.0
bullScore += pivotStrongBull  ? 1.0  : 0.0
bullScore += htfPivotBull     ? 0.75 : 0.0
bullScore += macdBull         ? 1.0  : 0.0
bullScore += macdBullCross    ? 0.5  : 0.0
bullScore += nearBullOB       ? 1.5  : 0.0
bullScore += vwapBull         ? 1.0  : 0.0   // VWAP bias
bullScore += vwapMomentumBull ? 0.5  : 0.0   // VWAP rising momentum bonus

float bearScore = 0.0
bearScore += ctBear           ? 1.0  : 0.0
bearScore += ctFlipBear       ? 0.5  : 0.0
bearScore += ctSlowBear       ? 0.5  : 0.0
bearScore += pivotBear        ? 1.0  : 0.0
bearScore += pivotStrongBear  ? 1.0  : 0.0
bearScore += htfPivotBear     ? 0.75 : 0.0
bearScore += macdBear         ? 1.0  : 0.0
bearScore += macdBearCross    ? 0.5  : 0.0
bearScore += nearBearOB       ? 1.5  : 0.0
bearScore += vwapBear         ? 1.0  : 0.0   // VWAP bias
bearScore += vwapMomentumBear ? 0.5  : 0.0   // VWAP falling momentum bonus

// --- Maintenance scores ---
// Excludes one-shot bonuses (flip/cross). VWAP bias + momentum are persistent
// so they belong in maintenance.
// Max reachable: 8.25 (vs 9.25 for full entry score).
float bullMaintenanceScore = 0.0
bullMaintenanceScore += ctBull           ? 1.0  : 0.0
bullMaintenanceScore += ctSlowBull       ? 0.5  : 0.0
bullMaintenanceScore += pivotBull        ? 1.0  : 0.0
bullMaintenanceScore += pivotStrongBull  ? 1.0  : 0.0
bullMaintenanceScore += htfPivotBull     ? 0.75 : 0.0
bullMaintenanceScore += macdBull         ? 1.0  : 0.0
bullMaintenanceScore += nearBullOB       ? 1.5  : 0.0
bullMaintenanceScore += vwapBull         ? 1.0  : 0.0
bullMaintenanceScore += vwapMomentumBull ? 0.5  : 0.0

float bearMaintenanceScore = 0.0
bearMaintenanceScore += ctBear           ? 1.0  : 0.0
bearMaintenanceScore += ctSlowBear       ? 0.5  : 0.0
bearMaintenanceScore += pivotBear        ? 1.0  : 0.0
bearMaintenanceScore += pivotStrongBear  ? 1.0  : 0.0
bearMaintenanceScore += htfPivotBear     ? 0.75 : 0.0
bearMaintenanceScore += macdBear         ? 1.0  : 0.0
bearMaintenanceScore += nearBearOB       ? 1.5  : 0.0
bearMaintenanceScore += vwapBear         ? 1.0  : 0.0
bearMaintenanceScore += vwapMomentumBear ? 0.5  : 0.0

// ══════════════════════════════════════
// SIGNAL LOGIC
// ══════════════════════════════════════
bool coralBullOk = requireCoralFlip ? ctFlipBull : ctBull
bool coralBearOk = requireCoralFlip ? ctFlipBear : ctBear

bool slowCoralBullOk = not useSlowCoral or ctSlowBull
bool slowCoralBearOk = not useSlowCoral or ctSlowBear

bool htfPivotBullOk = not (useHtfPivot and requireHtfPivot) or htfPivotBull
bool htfPivotBearOk = not (useHtfPivot and requireHtfPivot) or htfPivotBear

bool obBullOk = not requireOB or nearBullOB
bool obBearOk = not requireOB or nearBearOB

// VWAP gate: when requireVWAP is on AND VWAP is enabled, price must be on
// the correct side of VWAP. When off (or VWAP disabled), it's a free pass.
bool vwapBullOk = not (useVWAP and requireVWAP) or vwapBull
bool vwapBearOk = not (useVWAP and requireVWAP) or vwapBear

bool rawBuy  = coralBullOk and pivotBull and macdBull and obBullOk and slowCoralBullOk and htfPivotBullOk and vwapBullOk and bullScore >= minScoreInput
bool rawSell = coralBearOk and pivotBear and macdBear and obBearOk and slowCoralBearOk and htfPivotBearOk and vwapBearOk and bearScore >= minScoreInput

var int lastDirection = 0
bool buyCondition  = rawBuy  and lastDirection != 1
bool sellCondition = rawSell and lastDirection != -1
bool confirmedBuy  = buyCondition  and barstate.isconfirmed and isWarmedUp
bool confirmedSell = sellCondition and barstate.isconfirmed and isWarmedUp
if confirmedBuy and confirmedSell
    confirmedSell := false
if confirmedBuy
    lastDirection := 1
else if confirmedSell
    lastDirection := -1

// ══════════════════════════════════════
// TRADE MANAGEMENT (SL / TP / TRAIL)
// ══════════════════════════════════════
var float entryPrice = na
var float slPrice    = na
var float tp1Price   = na
var float tp2Price   = na
var float tp3Price   = na
var float trailPrice = na
var bool  tp1Hit     = false
var bool  tp2Hit     = false
var bool  tp3Hit     = false
var bool  slHit      = false
var int   tradeDir   = 0
var float tradeRisk  = na
var int   entryBar   = 0
// Decay exit state
var float entryMaintScore = na
var int   barsBelowDecay  = 0
var bool  decayExitHit    = false

calcSL(bool isLong, float entry, float atrSL) =>
    float atrStop = isLong ? entry - atrSL : entry + atrSL
    if useStructureSL
        float structStop = isLong ? getSwingLow(swingLookback)  - atrVal * 0.2 : getSwingHigh(swingLookback) + atrVal * 0.2
        float obEdge = na
        if isLong and bullOBs.size() > 0
            obEdge := bullOBs.get(0).barLow - atrVal * 0.2
        if not isLong and bearOBs.size() > 0
            obEdge := bearOBs.get(0).barHigh + atrVal * 0.2
        float finalStop = isLong ? math.max(atrStop, structStop) : math.min(atrStop, structStop)
        if not na(obEdge)
            finalStop := isLong ? math.max(finalStop, obEdge) : math.min(finalStop, obEdge)
        float minDist = atrVal * 0.5
        float dist    = math.abs(entry - finalStop)
        finalStop := dist < minDist ? (isLong ? entry - minDist : entry + minDist) : finalStop
        finalStop
    else
        atrStop

if confirmedBuy
    entryPrice := close
    tradeDir   := 1
    float risk = atrVal * slMultInput
    slPrice    := calcSL(true, close, risk)
    tradeRisk  := math.abs(close - slPrice)
    tp1Price   := close + tradeRisk * tp1MultInput
    tp2Price   := close + tradeRisk * tp2MultInput
    tp3Price   := close + tradeRisk * tp3MultInput
    trailPrice := slPrice
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false
    entryBar := bar_index
    entryMaintScore := bullMaintenanceScore
    barsBelowDecay  := 0
    decayExitHit    := false

if confirmedSell
    entryPrice := close
    tradeDir   := -1
    float risk = atrVal * slMultInput
    slPrice    := calcSL(false, close, risk)
    tradeRisk  := math.abs(close - slPrice)
    tp1Price   := close - tradeRisk * tp1MultInput
    tp2Price   := close - tradeRisk * tp2MultInput
    tp3Price   := close - tradeRisk * tp3MultInput
    trailPrice := slPrice
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false
    entryBar := bar_index
    entryMaintScore := bearMaintenanceScore
    barsBelowDecay  := 0
    decayExitHit    := false

// TP/SL detection
bool canCheckTPSL = bar_index > entryBar and tradeDir != 0 and not slHit
if canCheckTPSL and tradeDir == 1
    float preTrail = trailPrice
    if high >= tp1Price and not tp1Hit
        tp1Hit := true
        if useTrailInput
            trailPrice := entryPrice
    if high >= tp2Price and not tp2Hit
        tp2Hit := true
        if useTrailInput
            trailPrice := tp1Price
    if high >= tp3Price and not tp3Hit
        tp3Hit := true
        if useTrailInput
            trailPrice := tp2Price
    if low <= nz(preTrail, slPrice)
        slHit := true
if canCheckTPSL and tradeDir == -1
    float preTrail = trailPrice
    if low <= tp1Price and not tp1Hit
        tp1Hit := true
        if useTrailInput
            trailPrice := entryPrice
    if low <= tp2Price and not tp2Hit
        tp2Hit := true
        if useTrailInput
            trailPrice := tp1Price
    if low <= tp3Price and not tp3Hit
        tp3Hit := true
        if useTrailInput
            trailPrice := tp2Price
    if high >= nz(preTrail, slPrice)
        slHit := true

// --- Confluence Decay Exit detection ---
if useDecayExit and tradeDir != 0 and not slHit and not decayExitHit and bar_index > entryBar
    float currentMaint = tradeDir == 1 ? bullMaintenanceScore : bearMaintenanceScore
    float decayThresh = decayThreshMode == "Absolute" ? decayAbsThresh : nz(entryMaintScore, 0.0) * (decayPctThresh / 100.0)
    bool tpGateOk = decayMinTPHit == "None" or (decayMinTPHit == "TP1" and tp1Hit) or (decayMinTPHit == "TP2" and tp2Hit)
    if tpGateOk and currentMaint < decayThresh
        barsBelowDecay := barsBelowDecay + 1
    else
        barsBelowDecay := 0
    if barsBelowDecay >= decayConfirmBars
        decayExitHit := true

bool tradeActive = tradeDir != 0 and not slHit and not decayExitHit
string tradeStatus = "No Trade"
string statusTag = useTrailInput ? "Trail" : exitModeInput == "Single TP" ? "Fixed" : "Partial"
if tradeActive and tp3Hit
    tradeStatus := "TP3 ✓ — " + statusTag
else if tradeActive and tp2Hit
    tradeStatus := "TP2 ✓ — " + statusTag
else if tradeActive and tp1Hit
    tradeStatus := "TP1 ✓ — " + statusTag
else if tradeActive
    tradeStatus := "Active"

// Reset lastDirection when trade closes by SL
var bool slHitPrev = false
if slHit and not slHitPrev
    lastDirection := 0
slHitPrev := slHit

// ══════════════════════════════════════
// BACKTEST TRACKER
// ══════════════════════════════════════
float partialSum = partialTP1Input + partialTP2Input + partialTP3Input
float p1Frac = partialSum > 100.0 ? partialTP1Input / partialSum : partialTP1Input / 100.0
float p2Frac = partialSum > 100.0 ? partialTP2Input / partialSum : partialTP2Input / 100.0
float p3Frac = partialSum > 100.0 ? partialTP3Input / partialSum : partialTP3Input / 100.0
float residualFrac = math.max(0.0, 1.0 - (p1Frac + p2Frac + p3Frac))

float singleTPR = switch singleTPInput
    "TP1" => tp1MultInput
    "TP2" => tp2MultInput
    "TP3" => tp3MultInput
    =>       tp2MultInput
bool singleTPHit = switch singleTPInput
    "TP1" => tp1Hit
    "TP2" => tp2Hit
    "TP3" => tp3Hit
    =>       tp2Hit

var int   btTotalTrades  = 0
var int   btWins         = 0
var int   btLosses       = 0
var float btTotalR       = 0.0
var float btGrossWin     = 0.0
var float btGrossLoss    = 0.0
var int   btDecayExits   = 0

var bool prevTradeOpen = false
var int  prevDir       = 0
var bool prevTP1       = false
var bool prevTP2       = false
var bool prevTP3       = false
var bool prevSL        = false
var bool prevSingleTP  = false
var bool prevDecayHit  = false

bool singleTPJustHit  = (not useTrailInput) and exitModeInput == "Single TP" and singleTPHit and not prevSingleTP and prevTradeOpen
bool partialAllOutTP3 = (not useTrailInput) and exitModeInput == "Partial Exits" and residualFrac <= 0.0001 and tp3Hit and not prevTP3 and prevTradeOpen

bool  tradeJustClosed = false
float closedR         = 0.0

// Case A: profit-close terminal event (trailing OFF only)
if singleTPJustHit
    tradeJustClosed := true
    closedR := singleTPR
else if partialAllOutTP3
    tradeJustClosed := true
    closedR := p1Frac * tp1MultInput + p2Frac * tp2MultInput + p3Frac * tp3MultInput
// Case B: SL hit
else if slHit and not prevSL and prevTradeOpen
    tradeJustClosed := true
    if useTrailInput
        if prevTP3 or tp3Hit
            closedR := tp2MultInput
        else if prevTP2 or tp2Hit
            closedR := tp1MultInput
        else if prevTP1 or tp1Hit
            closedR := 0.0
        else
            closedR := -1.0
    else if exitModeInput == "Single TP"
        closedR := -1.0
    else
        float realizedR = 0.0
        float closedFrac = 0.0
        if prevTP1 or tp1Hit
            realizedR += p1Frac * tp1MultInput
            closedFrac += p1Frac
        if prevTP2 or tp2Hit
            realizedR += p2Frac * tp2MultInput
            closedFrac += p2Frac
        if prevTP3 or tp3Hit
            realizedR += p3Frac * tp3MultInput
            closedFrac += p3Frac
        float remainingFrac = math.max(0.0, 1.0 - closedFrac)
        closedR := realizedR + remainingFrac * (-1.0)
// Case C: Decay exit
else if decayExitHit and not prevDecayHit and prevTradeOpen
    tradeJustClosed := true
    float realizedR = 0.0
    float closedFrac = 0.0
    if not useTrailInput and exitModeInput == "Partial Exits"
        if prevTP1 or tp1Hit
            realizedR += p1Frac * tp1MultInput
            closedFrac += p1Frac
        if prevTP2 or tp2Hit
            realizedR += p2Frac * tp2MultInput
            closedFrac += p2Frac
        if prevTP3 or tp3Hit
            realizedR += p3Frac * tp3MultInput
            closedFrac += p3Frac
    float remainingFrac = math.max(0.0, 1.0 - closedFrac)
    float pnl  = tradeDir == 1 ? close - entryPrice : entryPrice - close
    float mtmR = tradeRisk != 0 ? pnl / tradeRisk : 0.0
    closedR := realizedR + remainingFrac * mtmR
    btDecayExits += 1
// Case D: opposing signal
else if (confirmedBuy and prevDir == -1 and prevTradeOpen) or (confirmedSell and prevDir == 1 and prevTradeOpen)
    tradeJustClosed := true
    if useTrailInput
        if prevTP3
            closedR := tp2MultInput
        else if prevTP2
            closedR := tp1MultInput
        else if prevTP1
            closedR := 0.0
        else
            float prevEntry = nz(entryPrice[1], close)
            float prevRisk  = nz(tradeRisk[1],  atrVal)
            float pnl       = prevDir == 1 ? close - prevEntry : prevEntry - close
            closedR := prevRisk != 0 ? pnl / prevRisk : 0.0
    else if exitModeInput == "Single TP"
        float prevEntry = nz(entryPrice[1], close)
        float prevRisk  = nz(tradeRisk[1],  atrVal)
        float pnl       = prevDir == 1 ? close - prevEntry : prevEntry - close
        closedR := prevRisk != 0 ? pnl / prevRisk : 0.0
    else
        float realizedR = 0.0
        float closedFrac = 0.0
        if prevTP1
            realizedR += p1Frac * tp1MultInput
            closedFrac += p1Frac
        if prevTP2
            realizedR += p2Frac * tp2MultInput
            closedFrac += p2Frac
        if prevTP3
            realizedR += p3Frac * tp3MultInput
            closedFrac += p3Frac
        float remainingFrac = math.max(0.0, 1.0 - closedFrac)
        float prevEntry = nz(entryPrice[1], close)
        float prevRisk  = nz(tradeRisk[1],  atrVal)
        float pnl       = prevDir == 1 ? close - prevEntry : prevEntry - close
        float mtmR      = prevRisk != 0 ? pnl / prevRisk : 0.0
        closedR := realizedR + remainingFrac * mtmR

if tradeJustClosed
    btTotalTrades += 1
    btTotalR      += closedR
    if closedR > 0
        btWins     += 1
        btGrossWin += closedR
    else if closedR < 0
        btLosses   += 1
        btGrossLoss += math.abs(closedR)

if singleTPJustHit or partialAllOutTP3 or (decayExitHit and not prevDecayHit)
    slHit        := true
    tradeActive  := false
    lastDirection := 0

prevTradeOpen := tradeActive
prevDir       := tradeDir
prevTP1       := tp1Hit
prevTP2       := tp2Hit
prevTP3       := tp3Hit
prevSL        := slHit
prevSingleTP  := singleTPHit
prevDecayHit  := decayExitHit

float btWinRate      = btTotalTrades > 0 ? btWins * 1.0 / btTotalTrades * 100.0 : 0.0
float btAvgR         = btTotalTrades > 0 ? btTotalR / (btTotalTrades * 1.0)     : 0.0
float btProfitFactor = btGrossLoss > 0 ? btGrossWin / btGrossLoss : (btGrossWin > 0 ? 999.0 : 0.0)
float btExpectancy   = btTotalTrades > 0 ? btTotalR : 0.0

// ══════════════════════════════════════
// PLOTS — Coral + VWAP + Order Blocks
// ══════════════════════════════════════
color ctPlotColor = ctDir == 1 ? color.new(bullColorInput, 20) : ctDir == -1 ? color.new(bearColorInput, 20) : color.new(neutralColorInput, 20)
plot(showCoral ? ctVal : na, "Coral Trend (Fast)", color = ctPlotColor, linewidth = 2, style = plot.style_stepline)
color ctSlowPlotColor = ctSlowDir == 1 ? color.new(bullColorInput, 55) : ctSlowDir == -1 ? color.new(bearColorInput, 55) : color.new(neutralColorInput, 55)
plot(showSlowCoral ? ctSlowVal : na, "Coral Trend (Slow)", color = ctSlowPlotColor, linewidth = 3, style = plot.style_stepline)

// VWAP plot — colored green when bullish (price above + rising), red when bearish
color vwapPlotColor = not vwapIsValid ? na : vwapBull ? (vwapRising ? color.new(bullColorInput, 10) : color.new(bullColorInput, 40)) : vwapBear ? (vwapFalling ? color.new(bearColorInput, 10) : color.new(bearColorInput, 40)) : color.new(neutralColorInput, 30)
plot(showVWAP and useVWAP ? vwapVal : na, "VWAP", color = vwapPlotColor, linewidth = vwapLineWidth, style = plot.style_linebr)

bgcolor(showBgInput ? (ctBull ? color.new(bullColorInput, 94) : ctBear ? color.new(bearColorInput, 94) : na) : na, title = "Trend Background")

// Draw/update OB boxes
drawOBs(array<orderBlock> obArr, bool internal) =>
    if showOBs and obArr.size() > 0
        int drawCount = math.min(obArr.size(), 5)
        for i = 0 to drawCount - 1
            orderBlock ob = obArr.get(i)
            color obCol = ob.bias == BULLISH ? bullOBColorInput : bearOBColorInput
            if internal
                obCol := color.new(obCol, 82)
            if not na(ob.b_ox)
                box.delete(ob.b_ox)
            ob.b_ox := box.new(
                 left         = ob.barTime,
                 top          = ob.barHigh,
                 right        = last_bar_time,
                 bottom       = ob.barLow,
                 xloc         = xloc.bar_time,
                 extend       = extend.right,
                 bgcolor      = obCol,
                 border_color = color.new(obCol, 50))

if barstate.islast
    drawOBs(bullOBs, false)
    drawOBs(bearOBs, false)

// ══════════════════════════════════════
// SIGNAL LABELS
// ══════════════════════════════════════
if showSignalsInput and confirmedBuy
    string gradeStr = showGradeInput ? " " + getGrade(bullScore) : ""
    label.new(bar_index, low, "Long" + gradeStr, color = bullColorInput, textcolor = LABEL_TEXT, style = label.style_label_up,   size = sigSize, yloc = yloc.belowbar)
if showSignalsInput and confirmedSell
    string gradeStr = showGradeInput ? " " + getGrade(bearScore) : ""
    label.new(bar_index, high, "Short" + gradeStr, color = bearColorInput, textcolor = LABEL_TEXT, style = label.style_label_down, size = sigSize, yloc = yloc.abovebar)

// ══════════════════════════════════════
// TP/SL LINES & LABELS
// ══════════════════════════════════════
var line  lineEntry = na, var line  lineSL    = na
var line  lineTP1   = na, var line  lineTP2   = na, var line  lineTP3 = na
var line  lineTrail = na
var label lbEntry   = na, var label lbSL      = na
var label lbTP1     = na, var label lbTP2     = na, var label lbTP3  = na
var label lbTrail   = na
var bool  hasDrawings = false

if (confirmedBuy or confirmedSell) and showTPSLInput
    line.delete(lineEntry), line.delete(lineSL)
    line.delete(lineTP1), line.delete(lineTP2), line.delete(lineTP3)
    line.delete(lineTrail)
    label.delete(lbEntry), label.delete(lbSL)
    label.delete(lbTP1), label.delete(lbTP2), label.delete(lbTP3)
    label.delete(lbTrail)

    int lineEnd  = bar_index + labelOffsetInput
    int labelPos = bar_index + labelOffsetInput + 2

    lineEntry := line.new(bar_index, entryPrice, lineEnd, entryPrice, color = ENTRY_COLOR, width = 2, style = line.style_solid)
    lineSL    := line.new(bar_index, slPrice,    lineEnd, slPrice,    color = SL_COLOR,    width = 2, style = line.style_solid)
    lineTP1   := line.new(bar_index, tp1Price,   lineEnd, tp1Price,   color = TP_COLOR,    width = 1, style = line.style_dashed)
    lineTP2   := line.new(bar_index, tp2Price,   lineEnd, tp2Price,   color = TP_COLOR,    width = 1, style = line.style_dashed)
    lineTP3   := line.new(bar_index, tp3Price,   lineEnd, tp3Price,   color = TP_COLOR,    width = 2, style = line.style_dashed)

    if showTrailInput and useTrailInput
        lineTrail := line.new(bar_index, trailPrice, lineEnd, trailPrice, color = TRAIL_COLOR, width = 1, style = line.style_dotted)
        lbTrail   := label.new(labelPos + 10, trailPrice, "TRAIL " + str.tostring(trailPrice, format.mintick), color = color.new(TRAIL_COLOR, 60), textcolor = TEXT_BRIGHT, style = label.style_label_left, size = size.small)

    lbEntry := label.new(labelPos, entryPrice, "ENTRY " + str.tostring(entryPrice, format.mintick), color = color.new(ENTRY_COLOR, 60), textcolor = TEXT_BRIGHT, style = label.style_label_left, size = size.small)
    lbSL    := label.new(labelPos, slPrice,    "SL "    + str.tostring(slPrice,    format.mintick), color = color.new(SL_COLOR,    60), textcolor = TEXT_BRIGHT, style = label.style_label_left, size = size.small)
    lbTP1   := label.new(labelPos, tp1Price,   "TP1 "   + str.tostring(tp1Price,   format.mintick), color = color.new(TP_COLOR,    60), textcolor = TEXT_BRIGHT, style = label.style_label_left, size = size.small)
    lbTP2   := label.new(labelPos, tp2Price,   "TP2 "   + str.tostring(tp2Price,   format.mintick), color = color.new(TP_COLOR,    60), textcolor = TEXT_BRIGHT, style = label.style_label_left, size = size.small)
    lbTP3   := label.new(labelPos, tp3Price,   "TP3 "   + str.tostring(tp3Price,   format.mintick), color = color.new(TP_COLOR,    60), textcolor = TEXT_BRIGHT, style = label.style_label_left, size = size.small)
    hasDrawings := true

if showTPSLInput and hasDrawings and not (confirmedBuy or confirmedSell)
    int newLineEnd  = bar_index + labelOffsetInput
    int newLabelPos = bar_index + labelOffsetInput + 2
    if not na(lineEntry)
        line.set_x2(lineEntry, newLineEnd)
    if not na(lineSL)
        line.set_x2(lineSL, newLineEnd)
    if not na(lineTP1)
        line.set_x2(lineTP1, newLineEnd)
    if not na(lineTP2)
        line.set_x2(lineTP2, newLineEnd)
    if not na(lineTP3)
        line.set_x2(lineTP3, newLineEnd)
    if not na(lbEntry)
        label.set_x(lbEntry, newLabelPos)
    if not na(lbSL)
        label.set_x(lbSL, newLabelPos)
    if not na(lbTP1)
        label.set_x(lbTP1, newLabelPos)
    if not na(lbTP2)
        label.set_x(lbTP2, newLabelPos)
    if not na(lbTP3)
        label.set_x(lbTP3, newLabelPos)
    if showTrailInput and useTrailInput
        if not na(lineTrail)
            line.set_x2(lineTrail, newLineEnd)
            line.set_y1(lineTrail, trailPrice)
            line.set_y2(lineTrail, trailPrice)
        if not na(lbTrail)
            label.set_xy(lbTrail, newLabelPos + 10, trailPrice)
            label.set_text(lbTrail, "TRAIL " + str.tostring(trailPrice, format.mintick))

if showTPSLInput and not na(lineTP1) and tp1Hit
    line.set_color(lineTP1, color.new(#40E0D0, 0))
    line.set_style(lineTP1, line.style_solid)
    if not na(lbTP1)
        label.set_text(lbTP1, "TP1 ✓ " + str.tostring(tp1Price, format.mintick))
        label.set_color(lbTP1, color.new(#40E0D0, 40))
if showTPSLInput and not na(lineTP2) and tp2Hit
    line.set_color(lineTP2, color.new(#40E0D0, 0))
    line.set_style(lineTP2, line.style_solid)
    if not na(lbTP2)
        label.set_text(lbTP2, "TP2 ✓ " + str.tostring(tp2Price, format.mintick))
        label.set_color(lbTP2, color.new(#40E0D0, 40))
if showTPSLInput and not na(lineTP3) and tp3Hit
    line.set_color(lineTP3, color.new(#40E0D0, 0))
    line.set_style(lineTP3, line.style_solid)
    if not na(lbTP3)
        label.set_text(lbTP3, "TP3 ✓ " + str.tostring(tp3Price, format.mintick))
        label.set_color(lbTP3, color.new(#40E0D0, 40))

// ══════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════
int dashRows = 16 + (showBtDashInput ? 8 : 0)
var table dashTable = table.new(getDashPos(dashPosStr), 2, dashRows, TABLE_BG, TABLE_BORDER, 1, TABLE_BORDER, 1)

if showDashInput and barstate.islast
    int row = 0

    // Header
    table.cell(dashTable, 0, row, "Confluence Trend Alers", text_color = HEADER_TEXT, bgcolor = HEADER_BG, text_size = size.small, text_halign = text.align_center)
    table.merge_cells(dashTable, 0, row, 1, row)
    row += 1

    // Fast Coral
    string coralStr = ctBull ? "▲ Bull" : ctBear ? "▼ Bear" : "— Flat"
    color  coralCol = ctBull ? DASH_BULL : ctBear ? DASH_BEAR : DASH_NEUTRAL
    table.cell(dashTable, 0, row, "Coral (Fast)", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
    table.cell(dashTable, 1, row, coralStr,       text_color = coralCol,   text_size = size.small, bgcolor = TABLE_BG)
    row += 1

    // Slow Coral (bias)
    string slowStr = ctSlowBull ? "▲ Bull" : ctSlowBear ? "▼ Bear" : "— Flat"
    color  slowCol = ctSlowBull ? DASH_BULL : ctSlowBear ? DASH_BEAR : DASH_NEUTRAL
    string slowLabel = "Coral (Slow)" + (useSlowCoral ? " *" : "")
    table.cell(dashTable, 0, row, slowLabel, text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
    table.cell(dashTable, 1, row, slowStr,   text_color = slowCol,    text_size = size.small, bgcolor = TABLE_ROW_ALT)
    row += 1

    // Pivot %
    string pivStr = pivotBull ? safeStr(smoothedHighPct, "#.#") + "% ▲" : pivotBear ? safeStr(smoothedLowPct, "#.#") + "% ▼" : "— Flat"
    color  pivCol = pivotBull ? DASH_BULL : pivotBear ? DASH_BEAR : DASH_NEUTRAL
    table.cell(dashTable, 0, row, "Pivot %", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
    table.cell(dashTable, 1, row, pivStr,    text_color = pivCol,     text_size = size.small, bgcolor = TABLE_BG)
    row += 1

    // HTF Pivot %
    if useHtfPivot and showHtfPivotDash
        string htfPivStr = htfPivotBull ? safeStr(htfHighPct, "#.#") + "% ▲" : htfPivotBear ? safeStr(htfLowPct, "#.#") + "% ▼" : "— Flat"
        color  htfPivCol = htfPivotBull ? DASH_BULL : htfPivotBear ? DASH_BEAR : DASH_NEUTRAL
        string htfPivLabel = "HTF Pivot (" + htfPivotTF + ")" + (requireHtfPivot ? " *" : "")
        table.cell(dashTable, 0, row, htfPivLabel, text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, row, htfPivStr,   text_color = htfPivCol,  text_size = size.small, bgcolor = TABLE_ROW_ALT)
        row += 1

    // MACD
    string macdStr = macdBull ? "▲ Bull" : macdBear ? "▼ Bear" : "— Flat"
    color  macdCol = macdBull ? DASH_BULL : macdBear ? DASH_BEAR : DASH_NEUTRAL
    table.cell(dashTable, 0, row, "MACD", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
    table.cell(dashTable, 1, row, macdStr, text_color = macdCol,    text_size = size.small, bgcolor = TABLE_BG)
    row += 1

    // VWAP
    if useVWAP
        string vwapStr = vwapBull ? (vwapRising ? "▲ Bull (rising)" : "▲ Bull") : vwapBear ? (vwapFalling ? "▼ Bear (falling)" : "▼ Bear") : "— Flat"
        color  vwapCol = vwapBull ? DASH_BULL : vwapBear ? DASH_BEAR : DASH_NEUTRAL
        string vwapLabel = "VWAP" + (requireVWAP ? " *" : "")
        table.cell(dashTable, 0, row, vwapLabel, text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, row, vwapStr,   text_color = vwapCol,    text_size = size.small, bgcolor = TABLE_ROW_ALT)
        row += 1

    // Order Block proximity
    string obStr = nearBullOB ? "Near Bull OB" : nearBearOB ? "Near Bear OB" : "—"
    color  obCol = nearBullOB ? DASH_BULL     : nearBearOB ? DASH_BEAR      : TEXT_MUTED
    table.cell(dashTable, 0, row, "OB Proximity", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
    table.cell(dashTable, 1, row, obStr,          text_color = obCol,      text_size = size.small, bgcolor = TABLE_ROW_ALT)
    row += 1

    // OB counts
    string obCountStr = "Bull: " + str.tostring(bullOBs.size()) + " | Bear: " + str.tostring(bearOBs.size())
    table.cell(dashTable, 0, row, "Active OBs", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
    table.cell(dashTable, 1, row, obCountStr,   text_color = TEXT_COLOR, text_size = size.small, bgcolor = TABLE_ROW_ALT)
    row += 1

    // Score
    float  activeScore = tradeDir == 1 ? bullScore : tradeDir == -1 ? bearScore : math.max(bullScore, bearScore)
    string scoreStr    = safeStr(activeScore, "#.#") + " / 9.25"
    color  scoreCol    = activeScore >= 6 ? DASH_BULL : activeScore >= 4.5 ? DASH_NEUTRAL : DASH_BEAR
    table.cell(dashTable, 0, row, "Score", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
    table.cell(dashTable, 1, row, scoreStr, text_color = scoreCol,  text_size = size.small, bgcolor = TABLE_BG)
    row += 1

    // Maintenance / Decay
    if useDecayExit
        float activeMaint = tradeDir == 1 ? bullMaintenanceScore : tradeDir == -1 ? bearMaintenanceScore : math.max(bullMaintenanceScore, bearMaintenanceScore)
        float activeThresh = decayThreshMode == "Absolute" ? decayAbsThresh : (tradeDir != 0 and not na(entryMaintScore) ? entryMaintScore * (decayPctThresh / 100.0) : decayAbsThresh)
        string maintStr = safeStr(activeMaint, "#.##") + " / thr " + safeStr(activeThresh, "#.##") + (barsBelowDecay > 0 ? " (" + str.tostring(barsBelowDecay) + "/" + str.tostring(decayConfirmBars) + ")" : "")
        color  maintCol = activeMaint < activeThresh ? DASH_BEAR : activeMaint < activeThresh + 1.0 ? DASH_NEUTRAL : DASH_BULL
        table.cell(dashTable, 0, row, "Maint/Decay", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, row, maintStr,      text_color = maintCol,   text_size = size.small, bgcolor = TABLE_ROW_ALT)
        row += 1

    // Status
    color statusCol = tradeStatus == "No Trade" ? TEXT_MUTED : str.contains(tradeStatus, "TP") ? DASH_BULL : DASH_NEUTRAL
    table.cell(dashTable, 0, row, "Status",   text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
    table.cell(dashTable, 1, row, tradeStatus, text_color = statusCol, text_size = size.small, bgcolor = TABLE_BG)
    row += 1

    // Timeframe
    table.cell(dashTable, 0, row, "Timeframe",       text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
    table.cell(dashTable, 1, row, timeframe.period,  text_color = TEXT_COLOR, text_size = size.small, bgcolor = TABLE_BG)
    row += 1

    // Version
    table.cell(dashTable, 0, row, "Version",           text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
    table.cell(dashTable, 1, row, INDICATOR_VERSION,   text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
    row += 1

    // Backtest section
    if showBtDashInput
        table.cell(dashTable, 0, row, "📈 Backtest", text_color = HEADER_TEXT, bgcolor = BT_HEADER_BG, text_size = size.small, text_halign = text.align_center)
        table.merge_cells(dashTable, 0, row, 1, row)
        row += 1

        table.cell(dashTable, 0, row, "Trades", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
        table.cell(dashTable, 1, row, str.tostring(btTotalTrades) + " (" + str.tostring(btWins) + "W / " + str.tostring(btLosses) + "L)", text_color = TEXT_COLOR, text_size = size.small, bgcolor = TABLE_BG)
        row += 1

        color wrCol = btWinRate >= 55 ? DASH_BULL : btWinRate >= 45 ? DASH_NEUTRAL : DASH_BEAR
        table.cell(dashTable, 0, row, "Win Rate", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, row, safeStr(btWinRate, "#.0") + "%", text_color = btTotalTrades > 0 ? wrCol : TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        row += 1

        color avgRCol = btAvgR > 0.5 ? DASH_BULL : btAvgR > 0 ? DASH_NEUTRAL : DASH_BEAR
        table.cell(dashTable, 0, row, "Avg R", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
        table.cell(dashTable, 1, row, safeStr(btAvgR, "#.##") + "R", text_color = btTotalTrades > 0 ? avgRCol : TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
        row += 1

        string pfStr = btProfitFactor >= 999 ? "∞" : safeStr(btProfitFactor, "#.##")
        color  pfCol = btProfitFactor >= 1.5 ? DASH_BULL : btProfitFactor >= 1.0 ? DASH_NEUTRAL : DASH_BEAR
        table.cell(dashTable, 0, row, "Profit Factor", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        table.cell(dashTable, 1, row, pfStr, text_color = btTotalTrades > 0 ? pfCol : TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
        row += 1

        color totRCol = btExpectancy > 0 ? DASH_BULL : btExpectancy < 0 ? DASH_BEAR : TEXT_MUTED
        table.cell(dashTable, 0, row, "Total R", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
        table.cell(dashTable, 1, row, safeStr(btExpectancy, "#.##") + "R", text_color = btTotalTrades > 0 ? totRCol : TEXT_MUTED, text_size = size.small, bgcolor = TABLE_BG)
        row += 1

        if useDecayExit
            string decayStr = str.tostring(btDecayExits) + " / " + str.tostring(btTotalTrades)
            table.cell(dashTable, 0, row, "Decay Exits", text_color = TEXT_MUTED, text_size = size.small, bgcolor = TABLE_ROW_ALT)
            table.cell(dashTable, 1, row, decayStr,      text_color = TEXT_COLOR, text_size = size.small, bgcolor = TABLE_ROW_ALT)

// ══════════════════════════════════════
// WATERMARK
// ══════════════════════════════════════
var table wmTable = table.new(position.bottom_center, 1, 1, color.new(color.black, 100), color.new(color.black, 100), 0, color.new(color.black, 100), 0)
if barstate.islast and showWatermarkInput
    table.cell(wmTable, 0, 0, "Confluence Sniper — higatetrading", text_color = WM_COLOR, text_size = size.normal, text_halign = text.align_center, bgcolor = color.new(color.black, 100))

// ══════════════════════════════════════
// ALERTS
// ══════════════════════════════════════
string tickerStr = syminfo.tickerid
string tfStr     = timeframe.period

if confirmedBuy
    string priceStr   = str.tostring(close,            format.mintick)
    string slAlStr    = str.tostring(nz(slPrice,  0.0), format.mintick)
    string tp1AlStr   = str.tostring(nz(tp1Price, 0.0), format.mintick)
    string tp2AlStr   = str.tostring(nz(tp2Price, 0.0), format.mintick)
    string tp3AlStr   = str.tostring(nz(tp3Price, 0.0), format.mintick)
    string bScoreStr  = str.tostring(nz(bullScore, 0.0), "#.#")
    string gradeAlStr = getGrade(bullScore)
    string jsonMsg    = '{"action":"buy","ticker":"' + tickerStr + '","price":' + priceStr + ',"sl":' + slAlStr + ',"tp1":' + tp1AlStr + ',"tp2":' + tp2AlStr + ',"tp3":' + tp3AlStr + ',"score":' + bScoreStr + ',"grade":"' + gradeAlStr + '","tf":"' + tfStr + '"}'
    string textMsg    = "🟢 BUY " + gradeAlStr + " | " + tickerStr + " | TF: " + tfStr + " | Price: " + priceStr + " | SL: " + slAlStr + " | TP1: " + tp1AlStr + " | TP2: " + tp2AlStr + " | TP3: " + tp3AlStr + " | Score: " + bScoreStr
    alert(webhookInput ? jsonMsg : textMsg, alert.freq_once_per_bar_close)

if confirmedSell
    string priceStr   = str.tostring(close,            format.mintick)
    string slAlStr    = str.tostring(nz(slPrice,  0.0), format.mintick)
    string tp1AlStr   = str.tostring(nz(tp1Price, 0.0), format.mintick)
    string tp2AlStr   = str.tostring(nz(tp2Price, 0.0), format.mintick)
    string tp3AlStr   = str.tostring(nz(tp3Price, 0.0), format.mintick)
    string sScoreStr  = str.tostring(nz(bearScore, 0.0), "#.#")
    string gradeAlStr = getGrade(bearScore)
    string jsonMsg    = '{"action":"sell","ticker":"' + tickerStr + '","price":' + priceStr + ',"sl":' + slAlStr + ',"tp1":' + tp1AlStr + ',"tp2":' + tp2AlStr + ',"tp3":' + tp3AlStr + ',"score":' + sScoreStr + ',"grade":"' + gradeAlStr + '","tf":"' + tfStr + '"}'
    string textMsg    = "🔴 SELL " + gradeAlStr + " | " + tickerStr + " | TF: " + tfStr + " | Price: " + priceStr + " | SL: " + slAlStr + " | TP1: " + tp1AlStr + " | TP2: " + tp2AlStr + " | TP3: " + tp3AlStr + " | Score: " + sScoreStr
    alert(webhookInput ? jsonMsg : textMsg, alert.freq_once_per_bar_close)

if tp1Hit and not tp1Hit[1] and tradeDir != 0
    string p = str.tostring(close, format.mintick)
    string msg = webhookInput ? '{"event":"tp1_hit","ticker":"' + tickerStr + '","price":' + p + '}' : "🎯 TP1 HIT | " + tickerStr + " | Price: " + p
    alert(msg, alert.freq_once_per_bar_close)
if tp2Hit and not tp2Hit[1] and tradeDir != 0
    string p = str.tostring(close, format.mintick)
    string msg = webhookInput ? '{"event":"tp2_hit","ticker":"' + tickerStr + '","price":' + p + '}' : "🎯 TP2 HIT | " + tickerStr + " | Price: " + p
    alert(msg, alert.freq_once_per_bar_close)
if tp3Hit and not tp3Hit[1] and tradeDir != 0
    string p = str.tostring(close, format.mintick)
    string msg = webhookInput ? '{"event":"tp3_hit","ticker":"' + tickerStr + '","price":' + p + '}' : "🏆 TP3 HIT | " + tickerStr + " | Price: " + p
    alert(msg, alert.freq_once_per_bar_close)
if slHit and not slHit[1] and tradeDir != 0
    string p = str.tostring(close, format.mintick)
    string msg = webhookInput ? '{"event":"sl_hit","ticker":"' + tickerStr + '","price":' + p + '}' : "🛑 SL HIT | " + tickerStr + " | Price: " + p
    alert(msg, alert.freq_once_per_bar_close)
if decayExitHit and not decayExitHit[1] and tradeDir != 0
    string p = str.tostring(close, format.mintick)
    float  curMaint = tradeDir == 1 ? bullMaintenanceScore : bearMaintenanceScore
    string maintStr = str.tostring(curMaint, "#.##")
    string msg = webhookInput ? '{"event":"decay_exit","ticker":"' + tickerStr + '","price":' + p + ',"maint":' + maintStr + '}' : "🍂 DECAY EXIT | " + tickerStr + " | Price: " + p + " | Maint: " + maintStr
    alert(msg, alert.freq_once_per_bar_close)

// ══════════════════════════════════════
// END
// ══════════════════════════════════════
````
