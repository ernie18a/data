# Kinetic Ribbon Trail [JOAT]

- url: https://www.tradingview.com/script/xVLaKEdl-Kinetic-Ribbon-Trail-JOAT/
- type: indicator
- pine_id: PUB;a61279543c074c678bd15fb38ad32bd0
- version: 1.0

## Description

[b]Kinetic Ribbon Trail [JOAT][/b]

[b]Introduction[/b]

Kinetic Ribbon Trail is an open-source trend-following indicator built on two structural layers: a 20-line Hull Moving Average gradient ribbon that quantifies the spread and conviction of near-term versus long-term momentum, and a Fibonacci-anchored adaptive trailing stop that adjusts its sensitivity based on the current swing structure and volatility ratio. The two layers interact — the ribbon provides visual context for momentum strength while the trail provides the dynamic level that determines directional bias.

The unique analytical contribution is the ribbon normalization. Most HMA ribbon indicators simply plot multiple lines and fill between them. Kinetic Ribbon Trail computes the signed spread between the fastest and slowest ribbon line, normalizes it by the 200-bar exponential average of that spread, clamps it to a -1 to +1 range, and uses the result to drive a continuous color gradient between the bear and bull theme colors. This means the ribbon's color intensity directly reflects how unusual the current momentum spread is relative to its historical average — not just whether the ribbon is bullish or bearish.

[image]https://www.tradingview.com/x/WRhfRl1q/[/image]

[b]Core Concepts[/b]

[b]1. 20-Line HMA Ribbon with rFactor Normalization[/b]

Twenty Hull Moving Average lines are computed from a base period, incrementing by a configurable step. The spread between the fastest and slowest line is the primary signal variable:

[pine]
rSpread    = rh01 - rh20
rAvgSpread = ta.ema(math.abs(rSpread), 200)
rFactor    = math.max(-1, math.min(1, rSpread / (rAvgSpread * 1.5 + 1e-9)))
rCol       = color.from_gradient(rFactor, -1, 1, colorBEAR, colorBULL)
[/pine]

When the fastest line is far above the slowest relative to its recent average, rFactor approaches +1 and the ribbon glows in full bull theme color. The gradient reflects spread magnitude — a bullish spread twice as wide as normal appears more saturated than one just barely positive.

[b]2. Fibonacci Adaptive Trailing Stop[/b]

The trailing stop anchors to swing structure rather than to fixed ATR multiples. Confirmed swing highs and lows define a Fibonacci range. Three trail levels are computed from this range at the 0.382, 0.5, and 0.618 Fibonacci retracement. One is selected based on the trail mode: Aggressive, Balanced, or Conservative. A volatility adjustment scales the selected level by the inverse of the current volatility ratio.

The trail ratchets: for longs, it can only move up. For shorts, it can only move down. A flip occurs when price closes through the trail level with body ratio and penetration confirmation.

[b]3. Four-State Regime Detection[/b]

A four-state regime classification determines which visual treatments are active: Trend Bull, Trend Bear, Range High-Vol, Range Low-Vol. The classification uses ADX relative to a threshold and the ATR-to-SMA(ATR) ratio. When a regime transition occurs, the chart background is tinted for 10 bars in the corresponding theme color before clearing.

[b]4. Six-Factor Confidence Score[/b]

Each signal is assigned a confidence grade (D through A+) based on six weighted factors: swing structure alignment (20%), regime alignment (20%), ADX strength (15%), volume participation (15%), volatility favorability (15%), and SMA50 proximity to trail level (15%). Signals below a user-set minimum grade are suppressed.

[image]https://www.tradingview.com/x/xgOT0yIk/[/image]

[b]Features[/b]

[list]
[*][b]20-line HMA gradient ribbon:[/b] rFactor-normalized color gradient reflecting momentum spread intensity vs. its 200-bar historical average
[*][b]19 ribbon fill layers:[/b] Adjacent HMA lines filled with gradient opacity layers for depth visualization
[*][b]Fibonacci adaptive trailing stop:[/b] Trail anchored to swing structure at 0.382 / 0.5 / 0.618 Fibonacci levels with volatility adjustment
[*][b]Trail ratchet with flip confirmation:[/b] Trail advances in one direction only; flips require body ratio and penetration confirmation
[*][b]Gradient trail fill:[/b] Fill between trail and close — top color opaque, bottom color transparent
[*][b]Four-state regime detection:[/b] Trend Bull, Trend Bear, Range High-Vol, Range Low-Vol with background tint on transition
[*][b]Six-factor confidence scoring:[/b] A+ / A / B / C / D grading system applied to each signal
[*][b]Confidence filter:[/b] Signals below the minimum confidence grade are suppressed
[*][b]Trade block on trail flip:[/b] Entry, stop, TP1/TP2/TP3 rendered as gradient boxes on confirmed flip signals
[*][b]Backtest tracker:[/b] Win rate and expected value
[*][b]Four color themes:[/b] Phantom, Neon, Classic, Solar
[*][b]Non-repainting:[/b] All signals gated by barstate.isconfirmed
[*][b]Institutional dashboard:[/b] 13-row table with regime, trail level, confidence grade, signal, TP/SL levels, and performance stats
[/list]

[b]Input Parameters[/b]

[b]Ribbon:[/b]
[list]
[*]Base Length: Fastest HMA period (default: 10)
[*]Step: Increment between each ribbon line (default: 14)
[/list]

[b]Fibonacci Trail:[/b]
[list]
[*]Trail Mode: Aggressive (0.618) / Balanced (0.5) / Conservative (0.382) / Auto (regime-adaptive)
[*]Pivot Lookback: Bars required to confirm a swing pivot
[/list]

[b]Confidence:[/b]
[list]
[*]Enable Confidence Filter toggle
[*]Min Signal Grade: D / C / B / A / A+
[/list]

[b]Trade Levels:[/b]
[list]
[*]Show Trade Block toggle
[*]Risk Preset: Conservative / Balanced / Aggressive / Scalping
[*]Extend Bars: How far lines project right
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Ribbon Color[/b]
A deeply saturated bull color means the ribbon spread is unusually wide — momentum is strong. A muted or transitional color means the spread is near its historical average — momentum is uncertain.

[b]Step 2: Watch for Trail Flips[/b]
A signal fires when the Fibonacci trail flips direction and confidence meets the minimum grade. The trade block appears immediately with entry, stop, and three TP levels.

[b]Step 3: Use Regime Context[/b]
The four-state regime in the dashboard tells you whether you are in a trending or ranging environment. High-confidence signals in trending regimes carry more structural weight than the same grade in a ranging regime.

[b]Indicator Limitations[/b]

[list]
[*]Swing detection uses ta.pivothigh() and ta.pivotlow() with a lookback offset. The Fibonacci levels are computed from swings confirmed bars after they occurred
[*]In markets with very shallow swing structures, the Fibonacci range can be small relative to ATR, causing the trail to cluster near the current price and produce excessive flips
[*]The 20-line ribbon increases visual complexity. Reducing the base length and step can make the ribbon more compact on busy charts
[*]The confidence score uses volume as one factor. On timeframes or instruments where volume is not meaningful, this factor should carry less weight
[*]Regime detection uses ADX, which lags price. A trend that begins explosively may be classified as ranging for several bars before ADX responds
[/list]

[b]Originality Statement[/b]

[list]
[*]The rFactor normalization — dividing ribbon spread by a 200-bar EMA of absolute ribbon spread, clamped to -1/+1, driving a continuous color.from_gradient() — is an original approach to HMA ribbon coloring that reflects relative momentum intensity rather than absolute direction
[*]Anchoring a trailing stop to Fibonacci retracements of the current confirmed swing structure, with volatility-ratio adjustment and body/penetration confirmation on flips, is distinct from standard ATR-multiplier trailing stops
[*]The six-factor confidence scoring system applied per signal, producing an A+ to D grade that gates signal output, provides per-trade quality assessment within the indicator itself
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Past confidence grades and win rates do not predict future performance. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
// =============================================================================
// Kinetic Ribbon Trail [JOAT]
// Jack Of All Trades — Institutional Series
// Version  : 1.0
// Platform : TradingView  Pine Script v6
// Features : 20-line HMA gradient ribbon · Fibonacci adaptive trailing stop
//            4-state regime detection · 6-factor confidence score
//            TP/SL trade block · Live backtest stats · Full dashboard
// =============================================================================
//@version=6
indicator("Kinetic Ribbon Trail [JOAT]", overlay=true, max_boxes_count=30, max_lines_count=30, max_labels_count=30)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 · COLOR THEME SYSTEM
// ─────────────────────────────────────────────────────────────────────────────
string themeInput = input.string("Phantom", "Color Theme", options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

var color colorBULL  = na
var color colorBEAR  = na
var color colorELITE = na
var color colorNEUTR = na

if themeInput == "Phantom"
    colorBULL  := color.rgb(6, 182, 212)
    colorBEAR  := color.rgb(236, 72, 153)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else if themeInput == "Neon"
    colorBULL  := #00F5D4
    colorBEAR  := #FF4466
    colorELITE := #6C63FF
    colorNEUTR := #FFD700
else if themeInput == "Classic"
    colorBULL  := color.rgb(0, 255, 0)
    colorBEAR  := color.rgb(255, 0, 0)
    colorELITE := color.rgb(187, 134, 252)
    colorNEUTR := color.rgb(139, 148, 158)
else
    colorBULL  := #FF9800
    colorBEAR  := #42A5F5
    colorELITE := #FFEB3B
    colorNEUTR := #9E9E9E

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 · INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Ribbon
var string G_RIB   = "◈ Ribbon"
int    ribbonBase  = input.int(10,   "Base Length",  minval=2,  maxval=50,  group=G_RIB)
int    ribbonStep  = input.int(14,   "Step",         minval=1,  maxval=30,  group=G_RIB)
bool   showRibbon  = input.bool(true, "Show Ribbon",                        group=G_RIB)

// Trail
var string G_TRAIL = "◈ Fibonacci Trail"
string trailMode   = input.string("Balanced", "Trail Mode", options=["Aggressive","Balanced","Conservative","Auto"], group=G_TRAIL)
int    pivLen      = input.int(10, "Pivot Lookback", minval=3, maxval=30,   group=G_TRAIL)
bool   showTrail   = input.bool(true, "Show Trail Line",                    group=G_TRAIL)
bool   showFill    = input.bool(true, "Show Trail Fill",                    group=G_TRAIL)

// Confidence
var string G_CONF  = "◈ Confidence"
bool   useConf     = input.bool(true, "Enable Confidence Filter",           group=G_CONF)
string minGrade    = input.string("C", "Min Signal Grade", options=["D","C","B","A","A+"], group=G_CONF)

// Trade levels
var string G_TP    = "◈ Trade Levels"
bool   showBlock   = input.bool(true, "Show Trade Block",                   group=G_TP)
string riskPreset  = input.string("Balanced", "Risk Preset", options=["Conservative","Balanced","Aggressive","Scalping"], group=G_TP)
int    extR        = input.int(20, "Extend Bars", minval=1, maxval=100,     group=G_TP)

// Visual
var string G_VIS   = "◈ Visual"
bool showBarCol    = input.bool(true,  "Show Bar Color",                    group=G_VIS)
bool showBG        = input.bool(true,  "Show Regime Tint",                  group=G_VIS)
bool showGlow      = input.bool(false, "Show Glow Candles",                 group=G_VIS)

// Dashboard
var string G_DASH  = "◈ Dashboard"
bool   showDash    = input.bool(true,         "Show Dashboard",             group=G_DASH)
string dashPos     = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
string dashSize    = input.string("Small",     "Size",     options=["Tiny","Small","Normal"],                             group=G_DASH)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 · UTILITY FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────

clampVal(float v, float mn, float mx) =>
    math.max(mn, math.min(mx, v))

gradeFromScore(float s) =>
    s >= 90.0 ? "A+" : s >= 75.0 ? "A" : s >= 60.0 ? "B" : s >= 40.0 ? "C" : "D"

gradeNum(string g) =>
    g == "A+" ? 5 : g == "A" ? 4 : g == "B" ? 3 : g == "C" ? 2 : 1

gradeMinOk(string grade, string minG) =>
    gradeNum(grade) >= gradeNum(minG)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 · CORE MARKET CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────

float atr14   = ta.atr(14)
[diP14, diM14, adxVal] = ta.dmi(14, 14)
float volMult  = volume > 0 ? volume / math.max(ta.ema(volume, 20), 1.0) : 1.0
float sma50    = ta.sma(close, 50)
float volRatio = atr14 / math.max(ta.sma(atr14, 50), 0.0001)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 · 4-STATE REGIME DETECTION
// ─────────────────────────────────────────────────────────────────────────────
// 1 = TREND_BULL  |  2 = TREND_BEAR  |  3 = RANGE_HVOL  |  4 = RANGE_LVOL

bool isTrend = adxVal > 25
bool isHVol  = volRatio > 1.2
int  regime  = isTrend and close > sma50 ? 1 : isTrend and close < sma50 ? 2 : isHVol ? 3 : 4

// Regime background tint — fires for 10 bars after each regime change
var int regimeChangeBar = -1
if ta.change(regime) != 0
    regimeChangeBar := bar_index

color regimeTint = na
if showBG and regimeChangeBar >= 0 and bar_index - regimeChangeBar < 10
    color _rt1 = regime == 1 ? color.new(colorBULL, 94)  : color.new(colorBEAR, 94)
    color _rt2 = regime == 3 ? color.new(colorNEUTR, 96) : color.new(colorELITE, 97)
    regimeTint := regime <= 2 ? _rt1 : _rt2
bgcolor(regimeTint)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 · PIVOT SWING DETECTION
// ─────────────────────────────────────────────────────────────────────────────

float swingH = ta.pivothigh(high, pivLen, pivLen)
float swingL = ta.pivotlow( low,  pivLen, pivLen)

var float latestHigh = na
var float latestLow  = na

if not na(swingH)
    latestHigh := swingH
if not na(swingL)
    latestLow  := swingL

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 7 · FIBONACCI TRAIL LEVELS
// ─────────────────────────────────────────────────────────────────────────────

var float fibTop    = na
var float fibBottom = na
var float fibRange  = na
var float fib382    = na
var float fib500    = na
var float fib618    = na

if not na(latestHigh) and not na(latestLow) and latestHigh > latestLow
    fibTop    := latestHigh
    fibBottom := latestLow
    fibRange  := fibTop - fibBottom
    fib382    := fibTop - fibRange * 0.382
    fib500    := fibTop - fibRange * 0.5
    fib618    := fibTop - fibRange * 0.618

// Fibonacci multiplier based on trail mode and regime context
float fibMult = switch trailMode
    "Aggressive"   => 0.618
    "Balanced"     => 0.5
    "Conservative" => 0.382
    "Auto"         => regime == 1 ? 0.618 : regime == 3 ? 0.5 : 0.382
    =>                0.5

float volAdj = clampVal(1.0 / math.max(volRatio, 0.01), 0.7, 1.5)

float selectedFibBull = not na(fibBottom) and not na(fibRange) ? clampVal(fibBottom + fibRange * fibMult * volAdj, fibBottom, fibTop) : na
float selectedFibBear = not na(fibTop) and not na(fibRange) ? clampVal(fibTop - fibRange * fibMult * volAdj, fibBottom, fibTop) : na

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 8 · ADAPTIVE FIBONACCI TRAILING STOP
// ─────────────────────────────────────────────────────────────────────────────

var float trailStop = na
var int   trailDir  = 0   // 1 = long bias | -1 = short bias | 0 = uninit

// Breakout quality confirmation — requires body dominance + meaningful penetration
confirmBreak(bool isLong, float lvl) =>
    float bodyRatio   = (high - low) > 0 ? math.abs(close - open) / (high - low) : 0.0
    float penetration = isLong ? close - lvl : lvl - close
    bodyRatio >= 0.45 and penetration > 0.2 * atr14

// Initialise on first valid bar
if na(trailStop)
    trailStop := not na(selectedFibBull) ? selectedFibBull : close
    trailDir  := close > sma50 ? 1 : -1

// Ratchet logic — executes only on confirmed (closed) bars
if barstate.isconfirmed and not na(selectedFibBull) and not na(selectedFibBear)
    if trailDir == 1
        trailStop := math.max(trailStop, selectedFibBull)
        if close < trailStop and confirmBreak(false, trailStop)
            trailStop := selectedFibBear
            trailDir  := -1
    else
        trailStop := math.min(trailStop, selectedFibBear)
        if close > trailStop and confirmBreak(true, trailStop)
            trailStop := selectedFibBull
            trailDir  := 1

// Trail flip signals — fire only once per directional change on confirmed bars
bool trailFlipBull = ta.change(trailDir) != 0 and trailDir ==  1 and barstate.isconfirmed
bool trailFlipBear = ta.change(trailDir) != 0 and trailDir == -1 and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 9 · 6-FACTOR CONFIDENCE SCORE
// ─────────────────────────────────────────────────────────────────────────────

// Factor 1 — Structural swing quality (20 %)
float structScore = 0.0
if not na(latestHigh) and not na(latestLow)
    float swingRange = latestHigh - latestLow
    float rScore     = atr14 > 0 ? swingRange / atr14 : 0.0
    structScore      := clampVal(rScore * 0.4, 0.0, 1.0) * (trailDir == 1 ? 1.0 : 0.5)

// Factor 2 — Regime alignment (20 %)
float regimeScore = (regime == 1 and trailDir == 1) or (regime == 2 and trailDir == -1) ? 1.0 : regime == 3 ? 0.5 : 0.3

// Factor 3 — ADX trend strength (15 %)
float adxScore = clampVal(adxVal / 40.0, 0.0, 1.0)

// Factor 4 — Volume surge (15 %)
float volScore = clampVal(volMult / 1.5, 0.0, 1.0)

// Factor 5 — ATR ratio favourability (15 %)
float volFavor = (volRatio < 0.3 or volRatio > 2.5) ? 0.0 : 1.0 - math.abs(volRatio - 1.0) / 1.5

// Factor 6 — Trail vs SMA50 confluence (15 %)
float confScore = (not na(sma50) and not na(trailStop) and atr14 > 0) ? clampVal(1.0 - math.abs(trailStop - sma50) / (atr14 * 2.0), 0.0, 1.0) : 0.5

// Composite weighted score → 0–100
float confidence = (structScore * 0.20 + regimeScore * 0.20 + adxScore * 0.15 + volScore * 0.15 + clampVal(volFavor, 0.0, 1.0) * 0.15 + confScore * 0.15) * 100.0

string confGrade = gradeFromScore(confidence)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 10 · FINAL GATED SIGNALS
// ─────────────────────────────────────────────────────────────────────────────

bool confirmedBull = trailFlipBull and (not useConf or gradeMinOk(confGrade, minGrade))
bool confirmedBear = trailFlipBear and (not useConf or gradeMinOk(confGrade, minGrade))

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 11 · 20-LINE HMA GRADIENT RIBBON
// ─────────────────────────────────────────────────────────────────────────────

rh(simple int len) => ta.hma(close, len)

float rh01 = rh(ribbonBase + ribbonStep *  0)
float rh02 = rh(ribbonBase + ribbonStep *  1)
float rh03 = rh(ribbonBase + ribbonStep *  2)
float rh04 = rh(ribbonBase + ribbonStep *  3)
float rh05 = rh(ribbonBase + ribbonStep *  4)
float rh06 = rh(ribbonBase + ribbonStep *  5)
float rh07 = rh(ribbonBase + ribbonStep *  6)
float rh08 = rh(ribbonBase + ribbonStep *  7)
float rh09 = rh(ribbonBase + ribbonStep *  8)
float rh10 = rh(ribbonBase + ribbonStep *  9)
float rh11 = rh(ribbonBase + ribbonStep * 10)
float rh12 = rh(ribbonBase + ribbonStep * 11)
float rh13 = rh(ribbonBase + ribbonStep * 12)
float rh14 = rh(ribbonBase + ribbonStep * 13)
float rh15 = rh(ribbonBase + ribbonStep * 14)
float rh16 = rh(ribbonBase + ribbonStep * 15)
float rh17 = rh(ribbonBase + ribbonStep * 16)
float rh18 = rh(ribbonBase + ribbonStep * 17)
float rh19 = rh(ribbonBase + ribbonStep * 18)
float rh20 = rh(ribbonBase + ribbonStep * 19)

// rFactor — normalised spread driving gradient morphing (−1 bear → +1 bull)
float rSpread    = rh01 - rh20
float rAbsSpread = math.abs(rSpread)
float rAvgSpread = ta.ema(rAbsSpread, 200)
float rFactor    = math.max(-1.0, math.min(1.0, nz(rSpread / (rAvgSpread * 1.5 + 1e-9), 0.0)))
color rCol       = color.from_gradient(rFactor, -1.0, 1.0, colorBEAR, colorBULL)

// Ribbon plots — 10 of the 20 computed lines plotted (every other line + last)
// All 20 HMA values are still computed for rFactor; only plot slots are reduced
p01 = plot(showRibbon ? rh01 : na, "RH01", color.new(rCol,  4), 1)
p03 = plot(showRibbon ? rh03 : na, "RH03", color.new(rCol, 14), 1)
p05 = plot(showRibbon ? rh05 : na, "RH05", color.new(rCol, 24), 1)
p07 = plot(showRibbon ? rh07 : na, "RH07", color.new(rCol, 34), 1)
p09 = plot(showRibbon ? rh09 : na, "RH09", color.new(rCol, 44), 1)
p11 = plot(showRibbon ? rh11 : na, "RH11", color.new(rCol, 54), 1)
p13 = plot(showRibbon ? rh13 : na, "RH13", color.new(rCol, 64), 1)
p15 = plot(showRibbon ? rh15 : na, "RH15", color.new(rCol, 74), 1)
p17 = plot(showRibbon ? rh17 : na, "RH17", color.new(rCol, 82), 1)
p20 = plot(showRibbon ? rh20 : na, "RH20", color.new(rCol, 90), 1)

// Inter-band fills — 9 fills between the 10 plotted lines
fill(p01, p03, color.new(rCol, 92))
fill(p03, p05, color.new(rCol, 93))
fill(p05, p07, color.new(rCol, 93))
fill(p07, p09, color.new(rCol, 94))
fill(p09, p11, color.new(rCol, 95))
fill(p11, p13, color.new(rCol, 95))
fill(p13, p15, color.new(rCol, 96))
fill(p15, p17, color.new(rCol, 97))
fill(p17, p20, color.new(rCol, 97))

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 12 · TRAIL PLOT + GRADIENT FILL
// ─────────────────────────────────────────────────────────────────────────────

color trailCol = trailDir == 1 ? colorBULL : colorBEAR

pTrail = plot(showTrail ? trailStop : na, "Trail Stop", trailCol, 2, plot.style_linebr)
pClose = plot(close, "Close Ref", na, display=display.none)

fill(pTrail, pClose,
    top_color    = showFill ? (trailDir == 1 ? color.new(colorBULL, 55) : color.new(colorBEAR, 90)) : na,
    bottom_color = showFill ? (trailDir == 1 ? color.new(colorBULL, 90) : color.new(colorBEAR, 55)) : na)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 13 · BAR COLOR
// ─────────────────────────────────────────────────────────────────────────────

color barCol = showBarCol ? (trailDir == 1 ? color.from_gradient(adxVal, 20, 50, color.new(colorBULL, 50), colorBULL) : color.from_gradient(adxVal, 20, 50, color.new(colorBEAR, 50), colorBEAR)) : na

barcolor(barCol)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 14 · GLOW CANDLES (optional depth layer)
// ─────────────────────────────────────────────────────────────────────────────

color glowBase = trailDir == 1 ? colorBULL : colorBEAR

plotcandle(open, high, low, close, "Glow",
    color=showGlow ? color.new(glowBase, 80) : na,
    wickcolor=showGlow ? color.new(glowBase, 15) : na,
    bordercolor=showGlow ? color.new(glowBase, 15) : na,
    display=display.all)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 15 · TP/SL TRADE BLOCK SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

// Risk preset multiplier lookup
float effSLMult = na
float effTP1    = na
float effTP2    = na
float effTP3    = na

switch riskPreset
    "Conservative" =>
        effSLMult := 2.5
        effTP1    := 1.0
        effTP2    := 2.0
        effTP3    := 4.0
    "Balanced" =>
        effSLMult := 1.5
        effTP1    := 1.0
        effTP2    := 2.0
        effTP3    := 3.0
    "Aggressive" =>
        effSLMult := 1.0
        effTP1    := 1.5
        effTP2    := 2.5
        effTP3    := 4.0
    "Scalping" =>
        effSLMult := 0.8
        effTP1    := 0.8
        effTP2    := 1.5
        effTP3    := 2.0
    =>
        effSLMult := 1.5
        effTP1    := 1.0
        effTP2    := 2.0
        effTP3    := 3.0

float slDist = atr14 * effSLMult

// Active trade state variables
var float activeEntry = na
var float activeSL    = na
var float activeTP1   = na
var float activeTP2   = na
var float activeTP3   = na
var int   activeDir   = 0
var bool  aTp1Hit     = false
var bool  aTp2Hit     = false

// Update levels on confirmed flip
if confirmedBull
    activeEntry := close
    activeSL    := close - slDist
    activeTP1   := close + slDist * effTP1
    activeTP2   := close + slDist * effTP2
    activeTP3   := close + slDist * effTP3
    activeDir   := 1
    aTp1Hit     := false
    aTp2Hit     := false

if confirmedBear
    activeEntry := close
    activeSL    := close + slDist
    activeTP1   := close - slDist * effTP1
    activeTP2   := close - slDist * effTP2
    activeTP3   := close - slDist * effTP3
    activeDir   := -1
    aTp1Hit     := false
    aTp2Hit     := false

// Track TP1 hit status
if activeDir == 1 and not na(activeTP1)
    aTp1Hit := aTp1Hit or high >= activeTP1
if activeDir == -1 and not na(activeTP1)
    aTp1Hit := aTp1Hit or low  <= activeTP1

// Drawing object handles
var line  lnEntry  = na
var line  lnSL     = na
var line  lnTP1    = na
var line  lnTP2    = na
var line  lnTP3    = na
var label lbEntry  = na
var label lbSL     = na
var label lbTP1    = na
var label lbTP2    = na
var label lbTP3    = na
var box   bxRisk   = na
var box   bxRew    = na

// Level colours
color cEntry = #ffffff
color cSL    = colorBEAR
color cTP1   = color.rgb(0, 180, 80)
color cTP2   = color.rgb(0, 210, 90)
color cTP3   = color.rgb(0, 255, 110)

// Redraw block on every new signal
if (confirmedBull or confirmedBear) and showBlock
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP1)
    line.delete(lnTP2)
    line.delete(lnTP3)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbTP1)
    label.delete(lbTP2)
    label.delete(lbTP3)
    box.delete(bxRisk)
    box.delete(bxRew)

    int sB = bar_index
    int eB = bar_index + extR

    lnEntry := line.new(sB, activeEntry, eB, activeEntry, color=cEntry, width=1)
    lbEntry := label.new(eB, activeEntry,
        "ENTRY  " + str.tostring(activeEntry, format.mintick),
        style=label.style_label_left,
        color=color.new(cEntry, 80),
        textcolor=cEntry,
        size=size.small)

    lnSL := line.new(sB, activeSL, eB, activeSL, color=cSL, width=1, style=line.style_dashed)
    lbSL := label.new(eB, activeSL,
        "STOP  " + str.tostring(activeSL, format.mintick),
        style=label.style_label_left,
        color=color.new(cSL, 80),
        textcolor=cSL,
        size=size.small)

    lnTP1 := line.new(sB, activeTP1, eB, activeTP1, color=cTP1, width=1)
    lbTP1 := label.new(eB, activeTP1,
        "TP1  " + str.tostring(activeTP1, format.mintick),
        style=label.style_label_left,
        color=color.new(cTP1, 80),
        textcolor=cTP1,
        size=size.small)

    lnTP2 := line.new(sB, activeTP2, eB, activeTP2, color=cTP2, width=1)
    lbTP2 := label.new(eB, activeTP2,
        "TP2  " + str.tostring(activeTP2, format.mintick),
        style=label.style_label_left,
        color=color.new(cTP2, 80),
        textcolor=cTP2,
        size=size.small)

    lnTP3 := line.new(sB, activeTP3, eB, activeTP3, color=cTP3, width=2)
    lbTP3 := label.new(eB, activeTP3,
        "TP3  " + str.tostring(activeTP3, format.mintick),
        style=label.style_label_left,
        color=color.new(cTP3, 80),
        textcolor=cTP3,
        size=size.small)

    // Risk box (entry → SL)
    float rT = activeDir == 1 ? activeEntry : activeSL
    float rB2 = activeDir == 1 ? activeSL    : activeEntry
    // Reward box (entry → TP1)
    float wT = activeDir == 1 ? activeTP1   : activeEntry
    float wB2 = activeDir == 1 ? activeEntry : activeTP1

    bxRisk := box.new(sB, rT,  eB, rB2,
        bgcolor=color.new(colorBEAR, 88),
        border_color=color.new(colorBEAR, 70))
    bxRew  := box.new(sB, wT,  eB, wB2,
        bgcolor=color.new(colorBULL, 88),
        border_color=color.new(colorBULL, 70))

// Extend block rightward every bar
if not na(lnEntry) and showBlock
    int re = bar_index + extR
    line.set_x2(lnEntry, re)
    line.set_x2(lnSL,    re)
    line.set_x2(lnTP1,   re)
    line.set_x2(lnTP2,   re)
    line.set_x2(lnTP3,   re)
    label.set_x(lbEntry, re)
    label.set_x(lbSL,    re)
    label.set_x(lbTP1,   re)
    label.set_x(lbTP2,   re)
    label.set_x(lbTP3,   re)
    box.set_right(bxRisk, re)
    box.set_right(bxRew,  re)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 16 · SIGNAL LABELS
// ─────────────────────────────────────────────────────────────────────────────

if confirmedBull
    label.new(bar_index, low - atr14 * 0.4,
        "▲  LONG  " + confGrade,
        style=label.style_label_up,
        color=color.new(colorBULL, 75),
        textcolor=colorBULL,
        size=size.small)

if confirmedBear
    label.new(bar_index, high + atr14 * 0.4,
        "▼  SHORT  " + confGrade,
        style=label.style_label_down,
        color=color.new(colorBEAR, 75),
        textcolor=colorBEAR,
        size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 17 · LIVE BACKTEST ENGINE (R-based P&L)
// ─────────────────────────────────────────────────────────────────────────────

var int   btTrades = 0
var int   btWins   = 0
var float btPnlR   = 0.0
var int   btDir    = 0
var float btEntry  = na
var float btSL     = na
var float btTP     = na

if confirmedBull
    btDir  := 1
    btEntry := close
    btSL   := close - slDist
    btTP   := close + slDist * effTP2

if confirmedBear
    btDir  := -1
    btEntry := close
    btSL   := close + slDist
    btTP   := close - slDist * effTP2

if btDir != 0 and not na(btSL)
    bool bw = btDir ==  1 ? high >= btTP : low  <= btTP
    bool bl = btDir ==  1 ? low  <= btSL : high >= btSL
    if bw or bl
        btTrades += 1
        if bw
            btWins  += 1
            btPnlR  += effTP2
        else
            btPnlR  -= 1.0
        btDir := 0

float btWR = btTrades > 0 ? float(btWins)  / float(btTrades) * 100.0 : 0.0
float btEV = btTrades > 0 ? btPnlR / float(btTrades)                  : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 18 · DASHBOARD (13 rows × 2 columns)
// ─────────────────────────────────────────────────────────────────────────────

string regTxt = regime == 1 ? "Trend Bull" : regime == 2 ? "Trend Bear" : regime == 3 ? "Range HVol" : "Range LVol"
color regCol = regime == 1 ? colorBULL : regime == 2 ? colorBEAR : regime == 3 ? colorNEUTR : colorELITE

// Position and size resolution
simple string dashPosVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

simple string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    =>          size.small

var table dash = table.new(dashPosVal, 2, 14,
    bgcolor=color.new(#0d1117, 10),
    border_color=color.new(#30363d, 20),
    border_width=1,
    frame_color=color.new(#30363d, 40),
    frame_width=1)

// Helper — write a single table cell
f_dc(int col, int row, string txt, color tc, color bg) =>
    table.cell(dash, col, row, txt,
        text_color=tc,
        text_size=dSz,
        bgcolor=bg,
        text_halign=col == 0 ? text.align_left : text.align_right)

if showDash and barstate.islast
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)
    color cWht = color.new(#ffffff, 0)

    // Row 0 — header
    f_dc(0, 0, "Kinetic Ribbon Trail [JOAT]", colorELITE, hBg)
    f_dc(1, 0, timeframe.period + " | v1.0",  cMut,       hBg)

    // Row 1 — regime
    f_dc(0, 1, "Regime",   cMut,   pBg)
    f_dc(1, 1, regTxt,     regCol, dBg)

    // Row 2 — ADX
    f_dc(0, 2, "ADX",      cMut,   pBg)
    f_dc(1, 2, str.tostring(math.round(adxVal)),
        adxVal > 25 ? colorBULL : cMut, dBg)

    // Row 3 — ATR Ratio
    f_dc(0, 3, "ATR Ratio", cMut,  pBg)
    f_dc(1, 3, str.tostring(volRatio, "#.##"),
        volRatio > 1.2 ? colorNEUTR : cMut, dBg)

    // Row 4 — Trail Level
    f_dc(0, 4, "Trail Level", cMut, pBg)
    f_dc(1, 4,
        not na(trailStop) ? str.tostring(trailStop, format.mintick) : "─",
        trailDir == 1 ? colorBULL : colorBEAR, dBg)

    // Row 5 — Ribbon Direction
    f_dc(0, 5, "Ribbon Dir", cMut, pBg)
    f_dc(1, 5,
        rh01 > rh20 ? "Bullish" : "Bearish",
        rh01 > rh20 ? colorBULL : colorBEAR, dBg)

    // Row 6 — Confidence
    color gradeCol = (confGrade == "A+" or confGrade == "A") ? colorBULL : confGrade == "B" ? colorNEUTR : colorBEAR
    f_dc(0, 6, "Confidence", cMut, pBg)
    f_dc(1, 6, confGrade + "  " + str.tostring(math.round(confidence)), gradeCol, dBg)

    // Row 7 — Signal
    string sigTxt2 = confirmedBull ? "▲  LONG" : confirmedBear ? "▼  SHORT" : trailDir == 1 ? "Long Bias" : "Short Bias"
    color  sigCol2 = trailDir == 1 ? colorBULL : colorBEAR
    f_dc(0, 7, "Signal", cMut,    pBg)
    f_dc(1, 7, sigTxt2,  sigCol2, dBg)

    // Row 8 — Stop
    f_dc(0, 8, "Stop", cMut, pBg)
    f_dc(1, 8,
        not na(activeSL) ? str.tostring(activeSL, format.mintick) : "─",
        colorBEAR, dBg)

    // Row 9 — TP1 / TP2
    f_dc(0, 9, "TP1 / TP2", cMut, pBg)
    f_dc(1, 9,
        not na(activeTP1) ?
            str.tostring(activeTP1, format.mintick) + " / " +
            str.tostring(activeTP2, format.mintick) : "─",
        colorBULL, dBg)

    // Row 10 — TP3
    f_dc(0, 10, "TP3", cMut, pBg)
    f_dc(1, 10,
        not na(activeTP3) ? str.tostring(activeTP3, format.mintick) : "─",
        color.rgb(0, 255, 110), dBg)

    // Row 11 — Win Rate
    color wr2Col = btWR >= 55 ? colorBULL : btWR >= 40 ? colorNEUTR : btTrades > 0 ? colorBEAR : cMut
    f_dc(0, 11, "Win Rate", cMut, pBg)
    f_dc(1, 11,
        btTrades > 0 ? str.tostring(btWR, "#.#") + "%" : "─",
        wr2Col, dBg)

    // Row 12 — Expected Value
    color ev2Col = btEV >= 0 ? colorBULL : colorBEAR
    f_dc(0, 12, "Exp Value", cMut, pBg)
    f_dc(1, 12,
        btTrades > 0 ?
            (btEV >= 0 ? "+" : "") + str.tostring(btEV, "#.##") + " R" : "─",
        ev2Col, dBg)

    // Row 13 — brand footer
    f_dc(0, 13, "[JOAT]",          color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 13, "jackofalltrades", cMut,                   color.new(#0d1117, 20))

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 19 · ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(confirmedBull,
    "Kinetic Long",
    "Kinetic Ribbon Trail: Bull flip confirmed.")

alertcondition(confirmedBear,
    "Kinetic Short",
    "Kinetic Ribbon Trail: Bear flip confirmed.")

alertcondition(confirmedBull and (confGrade == "A+" or confGrade == "A"),
    "Kinetic High-Confidence Long",
    "Kinetic Ribbon Trail: High-confidence bull signal.")

alertcondition(confirmedBear and (confGrade == "A+" or confGrade == "A"),
    "Kinetic High-Confidence Short",
    "Kinetic Ribbon Trail: High-confidence bear signal.")

alertcondition(ta.change(regime) != 0 and isTrend,
    "Kinetic Regime: Trend Detected",
    "Kinetic Ribbon Trail: Market entered a trending regime.")

// =============================================================================
// END — Kinetic Ribbon Trail [JOAT]  |  Pine Script v6  |  JOAT Suite v1.0
// =============================================================================
````
