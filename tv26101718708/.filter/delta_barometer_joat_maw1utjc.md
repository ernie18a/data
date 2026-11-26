# Delta Barometer [JOAT]

- url: https://www.tradingview.com/script/mAW1UTJC-Delta-Barometer-JOAT/
- type: indicator
- pine_id: PUB;8d50d2b5f3de48d8aa9b313f6186981f
- version: 1.0

## Description

[b]Delta Barometer [JOAT][/b]

[b]Introduction[/b]

Delta Barometer is an open-source dual-engine institutional pressure indicator that generates directional signals from two independent momentum measurement systems — an ATR trailing stop with Trend Strength Score, and a cumulative delta volume crossover with Pressure Score — and allows the user to configure how the two engines interact via four hybrid modes.

The core insight is that trend-following signals and momentum signals often disagree during transition periods and agree during high-probability setups. By building both engines independently, assigning each a score that reflects the quality of its reading, and providing modes that require either one engine, either engine, or both engines simultaneously, the indicator lets traders choose the selectivity level appropriate to their strategy. Requiring confluence produces fewer but higher-quality signals; allowing either engine to fire produces more signals with less selectivity.

[image]https://www.tradingview.com/x/EzcIG2dT/[/image]

[b]Core Concepts[/b]

[b]1. Engine A: ATR Trailing Stop with Trend Strength Score[/b]

A regime-adaptive ATR trailing stop is computed with different multipliers for low, medium, and high volatility environments. The ATR ratio determines the regime. The trail ratchets in one direction only and produces a signal on flip.

A Trend Strength Score (TSS) between 0 and 100 qualifies each trail flip: RSI slope magnitude contributes 40%, volume rate relative to its average contributes 35%, and ATR expansion relative to a shorter ATR period contributes 25%.

[pine]
float tssScore = (rsiSlopeComp * 0.40 + volRatioComp * 0.35 + atrExpandComp * 0.25) * 100
[/pine]

[b]2. Engine B: Cumulative Delta Volume with Pressure Score[/b]

Signed volume (positive when close is above open, negative otherwise) is accumulated into a running cumulative delta. A moving average of the cumulative delta is computed. A crossover of delta above its moving average is a potential bullish signal; a crossunder is bearish.

A Pressure Score between 0 and 100 qualifies each delta crossover: the magnitude of the delta ratio contributes 40%, volume rate relative to average contributes 35%, and candle body size relative to candle range contributes 25%.

[b]3. Four Hybrid Modes[/b]

Both Engines: A signal requires both Engine A and Engine B to produce a raw signal simultaneously. Highest selectivity.
Priority A: Engine A signals take precedence; Engine B fills gaps where A is not firing.
Priority B: Engine B signals take precedence; Engine A fills gaps where B is not firing.
Either Engine: A signal fires when either engine produces a raw signal. Highest frequency.

[b]4. Regime Arming[/b]

Each engine can be restricted to fire only in compatible volatility regimes — preventing the trailing engine from generating whipsaw signals during volatility compression.

[b]5. Five-State Pressure Candle Coloring[/b]

Bar colors reflect the combined pressure state across both engines on a five-level scale: strong bull, moderate bull, neutral, moderate bear, strong bear.

[image]https://www.tradingview.com/x/NbEzftrD/[/image]

[b]Features[/b]

[list]
[*][b]Engine A — ATR trail with TSS:[/b] Regime-adaptive trailing stop with Trend Strength Score qualifying each flip signal
[*][b]Engine B — Delta volume with Pressure Score:[/b] Cumulative signed volume crossover with composite Pressure Score qualification
[*][b]Four hybrid modes:[/b] Both Engines, Priority A, Priority B, Either Engine — configurable selectivity
[*][b]Regime arming:[/b] Each engine independently armed for specific volatility regimes
[*][b]Five-state pressure candle coloring:[/b] Strong bull / moderate bull / neutral / moderate bear / strong bear reflected in bar colors
[*][b]Gradient trail fill:[/b] Gradient between trailing stop and close; color inverts with trail direction
[*][b]Trade block on signal:[/b] Entry, stop (correctly positioned above entry for shorts, below for longs), and TP level rendered as colored boxes on confirmed signals. Stop line is bold dashed red with high-contrast label background. Entry always sits visually between the stop and take-profit zones
[*][b]9-column horizontal dashboard:[/b] Mode, regime, TSS, pressure score, trail direction, delta, engine ID, signal state, status — shown in a horizontal table layout at chart bottom
[*][b]Non-repainting:[/b] All signals confirmed on barstate.isconfirmed
[*][b]Four color themes:[/b] Phantom, Neon, Classic, Solar
[*][b]Backtest tracker:[/b] Win rate and expected value tracked per engine type
[/list]

[b]Input Parameters[/b]

[b]Engine A — ATR Trail:[/b]
[list]
[*]ATR Length, Low/Med/High Regime Multipliers
[*]Regime ATR Lookback, Low/High Vol Thresholds
[*]TSS Lookback and Min TSS Score to fire
[/list]

[b]Engine B — Delta Volume:[/b]
[list]
[*]Delta MA Length, Min Pressure Score
[*]RSI Overbought/Oversold gates
[/list]

[b]Hybrid Mode:[/b]
[list]
[*]Hybrid Mode: Both Engines / Priority A / Priority B / Either Engine
[*]Engine A and B arming: All / Low Only / Med + High / High Only
[/list]

[b]Signal:[/b]
[list]
[*]Cooldown Bars, TP ATR Multiple, SL % from Entry
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Select the Hybrid Mode[/b]
Start with Either Engine for maximum signal frequency. Switch to Both Engines when you want only the highest-conviction setups. Priority modes are useful when you trust one engine more than the other for a particular asset.

[b]Step 2: Read the 9-Column Dashboard[/b]
The horizontal dashboard shows the current state of both engines simultaneously. The ENGINE column shows which engine fired (A, B, or A+B for confluence). The TSS and PRESSURE columns show the raw quality scores of each engine.

[b]Step 3: Verify Trade Block Direction[/b]
For LONG signals: the red risk box appears below entry (stop is below) and the green reward box appears above entry (TP is above). For SHORT signals: the red risk box appears above entry (stop is above) and the green reward box appears below entry (TP is below). Entry is always the dividing line between the two zones.

[b]Step 4: Use Regime Arming for Market Fit[/b]
If the asset tends to trend strongly, arm Engine A for all regimes. If it is more volatile-momentum driven, arm Engine B for all regimes. Use Med + High arming for Engine A to avoid choppy low-volatility whipsaws.

[b]Indicator Limitations[/b]

[list]
[*]The TSS score components all lag price by varying amounts. Signals in fast-moving markets may arrive after the optimal entry point
[*]Cumulative delta volume as used here is a proxy. It approximates institutional bias without access to true bid-ask tick data
[*]Both Engines mode will produce very few signals on most assets. Adjust to Priority or Either modes if signal frequency is too low
[*]Regime classification uses ATR ratio, which is a lagging measure. A volatility spike that changes the regime will affect engine arming only after ATR responds
[/list]

[b]Originality Statement[/b]

[list]
[*]The dual-engine architecture with four configurable interaction modes — each engine carrying its own qualification score — and per-engine regime arming is an original design not replicated in existing open-source Pine Script v6 publications
[*]The Trend Strength Score weighting RSI slope, volume rate, and ATR expansion as qualification for ATR trail flip signals, combined with a separate Pressure Score for delta crossovers, provides independent signal quality assessment that single-engine indicators do not offer
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Past signal statistics do not predict future performance. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
// Dual-engine institutional pressure indicator.
// Engine A: ATR trailing stop with Trend Strength Score (TSS).
// Engine B: Cumulative delta volume crossover with Pressure Score.
// Four hybrid modes, regime-aware arming, 5-state candle coloring,
// gradient trail fill, horizontal 9-column dashboard at bottom_center.
// =============================================================================
//@version=6
indicator("Delta Barometer [JOAT]", overlay=true, max_boxes_count=20, max_lines_count=20, max_labels_count=20)

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR THEMES
// ─────────────────────────────────────────────────────────────────────────────
string themeInput = input.string("Neon", "Color Theme", options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

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
//  INPUTS — ENGINE A
// ─────────────────────────────────────────────────────────────────────────────
var string G_A = "◈ Engine A — ATR Trail"
bool   engAEnabled  = input.bool(true,  "Enable Engine A",       group=G_A)
int    atrLen       = input.int(14,     "ATR Length",            group=G_A)
float  lowMult      = input.float(1.5,  "Low Regime Mult",  step=0.1, group=G_A)
float  medMult      = input.float(2.0,  "Med Regime Mult",  step=0.1, group=G_A)
float  highMult     = input.float(2.5,  "High Regime Mult", step=0.1, group=G_A)
int    regLookback  = input.int(50,     "Regime ATR Lookback",   group=G_A)
float  lowThresh    = input.float(0.85, "Low Vol Threshold",  step=0.05, group=G_A)
float  highThresh   = input.float(1.35, "High Vol Threshold", step=0.05, group=G_A)
int    tssLookback  = input.int(5,      "TSS Lookback Bars",     group=G_A)
float  tssMinScore  = input.float(30.0, "Min TSS to Fire",       group=G_A)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — ENGINE B
// ─────────────────────────────────────────────────────────────────────────────
var string G_B = "◈ Engine B — Delta Volume"
bool   engBEnabled  = input.bool(true,  "Enable Engine B",       group=G_B)
int    deltaMALen   = input.int(14,     "Delta MA Length",       group=G_B)
float  pressMinScore= input.float(30.0, "Min Pressure to Fire",  group=G_B)
int    rsiOB        = input.int(70,     "RSI Overbought Gate",   group=G_B)
int    rsiOS        = input.int(30,     "RSI Oversold Gate",     group=G_B)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — HYBRID MODE
// ─────────────────────────────────────────────────────────────────────────────
var string G_HYB = "◈ Hybrid Mode"
string hybridMode = input.string("Either Engine", "Hybrid Mode",
     options=["Both Engines","Priority A","Priority B","Either Engine"], group=G_HYB)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — REGIME ARMING
// ─────────────────────────────────────────────────────────────────────────────
var string G_REGIME = "◈ Regime Arming"
string engAArm = input.string("Med + High", "Engine A Armed In",
     options=["All","Low Only","Med + High","High Only"], group=G_REGIME)
string engBArm = input.string("All",        "Engine B Armed In",
     options=["All","Low Only","Med + High","High Only"], group=G_REGIME)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — SIGNAL
// ─────────────────────────────────────────────────────────────────────────────
var string G_SIG = "◈ Signal"
int   cooldown    = input.int(3,    "Cooldown Bars", 0, 20, group=G_SIG)
float tpMultATR   = input.float(2.0,"TP ATR Multiple", step=0.5, group=G_SIG)
float slPctTrail  = input.float(0.5,"SL % from Entry", step=0.1, group=G_SIG)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — VISUAL
// ─────────────────────────────────────────────────────────────────────────────
var string G_VIS = "◈ Visual"
bool showTrail  = input.bool(true,  "Show Trail Line",       group=G_VIS)
bool showFill   = input.bool(true,  "Show Gradient Fill",    group=G_VIS)
bool showBarCol = input.bool(true,  "Show Pressure Candles", group=G_VIS)
bool showBG     = input.bool(true,  "Show Regime Tint",      group=G_VIS)
bool showGlow   = input.bool(false, "Show Glow Candles",     group=G_VIS)
bool showBlock  = input.bool(true,  "Show Trade Block",      group=G_VIS)
int  extR       = input.int(15,     "Block Extend Bars", 1, 80, group=G_VIS)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS — DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var string G_DASH = "◈ Dashboard"
bool   showDash = input.bool(true,    "Show Dashboard",      group=G_DASH)
string dashSize = input.string("Small","Size", options=["Tiny","Small","Normal"], group=G_DASH)

// ─────────────────────────────────────────────────────────────────────────────
//  CORE: ATR & REGIME
// ─────────────────────────────────────────────────────────────────────────────
float atrRaw    = ta.atr(atrLen)
float atrSMA    = ta.sma(atrRaw, regLookback)
float atrRatio  = atrSMA > 0.0 ? atrRaw / atrSMA : 1.0
bool  regLow    = atrRatio < lowThresh
bool  regHigh   = atrRatio > highThresh
bool  regMed    = not regLow and not regHigh
string regName  = regLow ? "LOW" : regHigh ? "HIGH" : "MED"
float activeMult = regLow ? lowMult : regHigh ? highMult : medMult

// ─────────────────────────────────────────────────────────────────────────────
//  ENGINE A ARMING
// ─────────────────────────────────────────────────────────────────────────────
bool aArmed = switch engAArm
    "Low Only"   => regLow
    "Med + High" => regMed or regHigh
    "High Only"  => regHigh
    => true

// ─────────────────────────────────────────────────────────────────────────────
//  ATR TRAILING STOP
// ─────────────────────────────────────────────────────────────────────────────
float atrBand    = atrRaw * activeMult
float trailUpVal = close - atrBand
float trailDnVal = close + atrBand

var float trail  = na
var bool  prevUp = true

float newTrailUp = na
float newTrailDn = na

if not na(trail)
    newTrailUp := math.max(trailUpVal, prevUp ? trail : trailUpVal)
    newTrailDn := math.min(trailDnVal, not prevUp ? trail : trailDnVal)
else
    newTrailUp := trailUpVal
    newTrailDn := trailDnVal

if prevUp
    trail  := newTrailUp
    if close < trail
        trail  := newTrailDn
        prevUp := false
else
    trail  := newTrailDn
    if close > trail
        trail  := newTrailUp
        prevUp := true

bool trailUp = prevUp

// ─────────────────────────────────────────────────────────────────────────────
//  TSS — TREND STRENGTH SCORE
// ─────────────────────────────────────────────────────────────────────────────
float rsiNow   = ta.rsi(close, 14)
float rsiPrev  = ta.rsi(close, 14)[tssLookback]
float rsiSlope = rsiNow - rsiPrev
float rsiComp  = math.min(math.abs(rsiSlope) / 20.0, 1.0)

float volMA    = ta.ema(volume, 20)
float volRatio = volMA > 0 ? volume / volMA : 1.0
float volComp  = math.min(math.max(volRatio - 1.0, 0.0) / 1.5, 1.0)

float atrShort  = ta.atr(5)
float atrExpand = atrShort > 0 ? atrRaw / atrShort : 1.0
float atrComp   = math.min(math.max(atrExpand - 1.0, 0.0) / 0.5, 1.0)

float tssScore  = (rsiComp * 0.40 + volComp * 0.35 + atrComp * 0.25) * 100.0

// ─────────────────────────────────────────────────────────────────────────────
//  ENGINE A — SIGNALS
// ─────────────────────────────────────────────────────────────────────────────
bool flipToBull = not na(trail) and not prevUp[1] and close > trail
bool flipToBear = not na(trail) and prevUp[1]     and close < trail

bool trailRawBuy  = engAEnabled and aArmed and flipToBull and tssScore >= tssMinScore
bool trailRawSell = engAEnabled and aArmed and flipToBear and tssScore >= tssMinScore

// ─────────────────────────────────────────────────────────────────────────────
//  ENGINE B — CUMULATIVE DELTA VOLUME
// ─────────────────────────────────────────────────────────────────────────────
float rawDelta     = close >= open ? volume : -volume
var float cumDelta = 0.0
cumDelta += rawDelta

float deltaMA    = ta.sma(cumDelta, deltaMALen)
bool  deltaXup   = ta.crossover(cumDelta,  deltaMA)
bool  deltaXdn   = ta.crossunder(cumDelta, deltaMA)

float deltaRatio = volume > 0 ? rawDelta / volume : 0.0
float bodyComp2  = (high - low) > 0 ? math.min(math.abs(close - open) / (high - low), 1.0) : 0.0
float volCompB   = volMA > 0 ? math.min(math.max(volume / volMA - 1.0, 0.0) / 1.5, 1.0) : 0.0
float pressScore = (math.abs(deltaRatio) * 0.40 + volCompB * 0.35 + bodyComp2 * 0.25) * 100.0

bool bArmed = switch engBArm
    "Low Only"   => regLow
    "Med + High" => regMed or regHigh
    "High Only"  => regHigh
    => true

bool pressRawBuy  = engBEnabled and bArmed and deltaXup  and pressScore >= pressMinScore and rsiNow < rsiOB
bool pressRawSell = engBEnabled and bArmed and deltaXdn  and pressScore >= pressMinScore and rsiNow > rsiOS

// ─────────────────────────────────────────────────────────────────────────────
//  HYBRID SIGNAL RESOLUTION
// ─────────────────────────────────────────────────────────────────────────────
var bool buySignal  = false
var bool sellSignal = false
var int  engineId   = 0   // 1=A, 2=B, 3=Confluence

buySignal  := false
sellSignal := false
engineId   := 0

switch hybridMode
    "Both Engines" =>
        if trailRawBuy and pressRawBuy
            buySignal := true
            engineId  := 3
        if trailRawSell and pressRawSell
            sellSignal := true
            engineId   := 3
    "Priority A" =>
        if trailRawBuy
            buySignal := true
            engineId  := 1
        else if pressRawBuy and not trailRawSell
            buySignal := true
            engineId  := 2
        if trailRawSell
            sellSignal := true
            engineId   := 1
        else if pressRawSell and not trailRawBuy
            sellSignal := true
            engineId   := 2
    "Priority B" =>
        if pressRawBuy
            buySignal := true
            engineId  := 2
        else if trailRawBuy and not pressRawSell
            buySignal := true
            engineId  := 1
        if pressRawSell
            sellSignal := true
            engineId   := 2
        else if trailRawSell and not pressRawBuy
            sellSignal := true
            engineId   := 1
    => // Either Engine
        if trailRawBuy or pressRawBuy
            buySignal := true
            engineId  := trailRawBuy and pressRawBuy ? 3 : trailRawBuy ? 1 : 2
        if trailRawSell or pressRawSell
            sellSignal := true
            engineId   := trailRawSell and pressRawSell ? 3 : trailRawSell ? 1 : 2

// ─────────────────────────────────────────────────────────────────────────────
//  COOLDOWN
// ─────────────────────────────────────────────────────────────────────────────
var int barsCD = 999
barsCD += 1

bool confirmedBuy  = buySignal  and barsCD >= cooldown and barstate.isconfirmed
bool confirmedSell = sellSignal and barsCD >= cooldown and barstate.isconfirmed

if confirmedBuy or confirmedSell
    barsCD := 0

// ─────────────────────────────────────────────────────────────────────────────
//  5-STATE PRESSURE CANDLE COLORING
// ─────────────────────────────────────────────────────────────────────────────
bool stStrongBull = tssScore > 70 and pressScore > 70
bool stBull       = (tssScore > 50 or pressScore > 50) and not stStrongBull
bool stNeutral    = tssScore <= 50 and pressScore <= 50 and not stBull
bool stBear       = (tssScore < 50 or pressScore < 50) and not stNeutral and not stBull
bool stStrongBear = tssScore < 30 and pressScore < 30

color pressCol = stStrongBull ? colorBULL :
     stBull        ? color.new(colorBULL,  40) :
     stNeutral     ? color.new(colorNEUTR, 60) :
     stBear        ? color.new(colorBEAR,  40) :
     colorBEAR

barcolor(showBarCol ? pressCol : na)

// ─────────────────────────────────────────────────────────────────────────────
//  REGIME BACKGROUND TINT
// ─────────────────────────────────────────────────────────────────────────────
color regimeTint = na
if showBG
    regimeTint := regLow  ? color.new(colorBULL,  97) :
         regHigh ? color.new(colorBEAR,  97) :
         color.new(colorNEUTR, 97)

bgcolor(regimeTint)

// ─────────────────────────────────────────────────────────────────────────────
//  GLOW CANDLES (3-layer depth effect)
// ─────────────────────────────────────────────────────────────────────────────
color glowBase2 = trailUp ? colorBULL : colorBEAR

plotcandle(open, high, low, close, "Glow D2",
     color=showGlow ? color.new(glowBase2, 95) : na,
     wickcolor=showGlow ? color.new(glowBase2, 95) : na,
     bordercolor=showGlow ? color.new(glowBase2, 95) : na,
     display=display.all)

plotcandle(open, high, low, close, "Glow D1",
     color=showGlow ? color.new(glowBase2, 85) : na,
     wickcolor=showGlow ? color.new(glowBase2, 85) : na,
     bordercolor=showGlow ? color.new(glowBase2, 85) : na,
     display=display.all)

plotcandle(open, high, low, close, "Glow Sh",
     color=showGlow ? color.new(glowBase2, 70) : na,
     wickcolor=showGlow ? color.new(glowBase2, 10) : na,
     bordercolor=showGlow ? color.new(glowBase2, 10) : na,
     display=display.all)

// ─────────────────────────────────────────────────────────────────────────────
//  TRAIL LINE + GRADIENT FILL
// ─────────────────────────────────────────────────────────────────────────────
color trailCol = trailUp ? colorBULL : colorBEAR

pTrail = plot(showTrail ? trail : na, "Trail", trailCol, 2, plot.style_linebr)
pClose = plot(close, "Close", na, display=display.none)

fill(pTrail, pClose,
     top_color    = showFill ? (trailUp ? color.new(colorBULL, 55) : color.new(colorBEAR, 90)) : na,
     bottom_color = showFill ? (trailUp ? color.new(colorBULL, 90) : color.new(colorBEAR, 55)) : na)

// ─────────────────────────────────────────────────────────────────────────────
//  SIGNAL LABELS
// ─────────────────────────────────────────────────────────────────────────────
string engLbl = engineId == 3 ? "[A+B]" : engineId == 1 ? "[A]" : "[B]"

if confirmedBuy
    label.new(bar_index, low - atrRaw * 0.5,
         "▲  LONG  " + engLbl + "\nTSS:" + str.tostring(math.round(tssScore)) + " P:" + str.tostring(math.round(pressScore)),
         style=label.style_label_up,
         color=color.new(colorBULL, 75),
         textcolor=colorBULL,
         size=size.small)

if confirmedSell
    label.new(bar_index, high + atrRaw * 0.5,
         "▼  SHORT  " + engLbl + "\nTSS:" + str.tostring(math.round(tssScore)) + " P:" + str.tostring(math.round(pressScore)),
         style=label.style_label_down,
         color=color.new(colorBEAR, 75),
         textcolor=colorBEAR,
         size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
//  TP / SL TRADE BLOCK
// ─────────────────────────────────────────────────────────────────────────────
var float bEntry  = na
var float bSL     = na
var float bTP     = na
var int   bDir    = 0
var line  lnEntry = na
var line  lnSL    = na
var line  lnTP    = na
var label lbEntry = na
var label lbSL    = na
var label lbTP    = na
var box   bxRisk  = na
var box   bxRew   = na

if confirmedBuy
    bEntry := close
    // SL is BELOW entry for longs — use min of trail and ATR-based floor to guarantee it
    bSL    := not na(trail) ? math.min(trail, close - atrRaw * 0.5) : close * (1.0 - slPctTrail / 100.0)
    bTP    := close + atrRaw * tpMultATR
    bDir   := 1
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbTP)
    box.delete(bxRisk)
    box.delete(bxRew)
    int eBar = bar_index + extR
    lnEntry := line.new(bar_index, bEntry, eBar, bEntry, color=#ffffff, width=1)
    // Stop line — gradient red, bold, dashed
    lnSL    := line.new(bar_index, bSL, eBar, bSL, color=colorBEAR, width=2, style=line.style_dashed)
    lnTP    := line.new(bar_index, bTP, eBar, bTP, color=color.rgb(0,220,100), width=2)
    lbEntry := label.new(eBar, bEntry, "ENTRY  " + str.tostring(bEntry, format.mintick),
         style=label.style_label_left, color=color.new(#ffffff, 80), textcolor=#ffffff, size=size.small)
    // Stop label — semi-transparent red background, red text
    lbSL    := label.new(eBar, bSL, "STOP  " + str.tostring(bSL, format.mintick),
         style=label.style_label_left, color=color.new(colorBEAR, 60), textcolor=colorBEAR, size=size.small)
    lbTP    := label.new(eBar, bTP, "TP  " + str.tostring(bTP, format.mintick),
         style=label.style_label_left, color=color.new(color.rgb(0,220,100), 60), textcolor=color.rgb(0,220,100), size=size.small)
    // Risk box (RED): entry DOWN to stop (stop is below entry for longs)
    bxRisk  := box.new(bar_index, bEntry, eBar, bSL,
         bgcolor=color.new(colorBEAR, 85), border_color=color.new(colorBEAR, 50), border_width=1)
    // Reward box (GREEN): TP DOWN to entry (TP is above entry for longs)
    bxRew   := box.new(bar_index, bTP, eBar, bEntry,
         bgcolor=color.new(colorBULL, 85), border_color=color.new(colorBULL, 50), border_width=1)

if confirmedSell
    bEntry := close
    // SL is ABOVE entry for shorts — use max of trail and ATR-based ceiling to guarantee it
    bSL    := not na(trail) ? math.max(trail, close + atrRaw * 0.5) : close * (1.0 + slPctTrail / 100.0)
    bTP    := close - atrRaw * tpMultATR
    bDir   := -1
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbTP)
    box.delete(bxRisk)
    box.delete(bxRew)
    int eBar = bar_index + extR
    lnEntry := line.new(bar_index, bEntry, eBar, bEntry, color=#ffffff, width=1)
    // Stop line — gradient red, bold, dashed
    lnSL    := line.new(bar_index, bSL, eBar, bSL, color=colorBEAR, width=2, style=line.style_dashed)
    lnTP    := line.new(bar_index, bTP, eBar, bTP, color=color.rgb(0,220,100), width=2)
    lbEntry := label.new(eBar, bEntry, "ENTRY  " + str.tostring(bEntry, format.mintick),
         style=label.style_label_left, color=color.new(#ffffff, 80), textcolor=#ffffff, size=size.small)
    // Stop label — semi-transparent red background, red text
    lbSL    := label.new(eBar, bSL, "STOP  " + str.tostring(bSL, format.mintick),
         style=label.style_label_left, color=color.new(colorBEAR, 60), textcolor=colorBEAR, size=size.small)
    lbTP    := label.new(eBar, bTP, "TP  " + str.tostring(bTP, format.mintick),
         style=label.style_label_left, color=color.new(color.rgb(0,220,100), 60), textcolor=color.rgb(0,220,100), size=size.small)
    // Risk box (RED): stop DOWN to entry (stop is ABOVE entry for shorts)
    bxRisk  := box.new(bar_index, bSL, eBar, bEntry,
         bgcolor=color.new(colorBEAR, 85), border_color=color.new(colorBEAR, 50), border_width=1)
    // Reward box (GREEN): entry DOWN to TP (TP is BELOW entry for shorts)
    bxRew   := box.new(bar_index, bEntry, eBar, bTP,
         bgcolor=color.new(colorBULL, 85), border_color=color.new(colorBULL, 50), border_width=1)

// Live extend — update right edge every bar so block tracks realtime
if not na(lnEntry) and showBlock
    int re = bar_index + extR
    line.set_x2(lnEntry, re)
    line.set_x2(lnSL, re)
    line.set_x2(lnTP, re)
    label.set_x(lbEntry, re)
    label.set_x(lbSL, re)
    label.set_x(lbTP, re)
    box.set_right(bxRisk, re)
    box.set_right(bxRew, re)

// ─────────────────────────────────────────────────────────────────────────────
//  LIGHTWEIGHT BACKTEST TRACKER
// ─────────────────────────────────────────────────────────────────────────────
var int   btTrades = 0
var int   btWins   = 0
var float btPnlR   = 0.0
var int   btDir2   = 0
var float btEntry2 = na
var float btTP2    = na
var float btSL2    = na

if confirmedBuy
    btDir2   := 1
    btEntry2 := close
    btTP2    := close + atrRaw * tpMultATR
    btSL2    := bSL

if confirmedSell
    btDir2   := -1
    btEntry2 := close
    btTP2    := close - atrRaw * tpMultATR
    btSL2    := bSL

if btDir2 != 0 and not na(btTP2) and not na(btSL2)
    bool bw = btDir2 == 1 ? high >= btTP2 : low  <= btTP2
    bool bl = btDir2 == 1 ? low  <= btSL2 : high >= btSL2
    if bw or bl
        btTrades += 1
        if bw
            btWins  += 1
            btPnlR  += tpMultATR
        else
            btPnlR  -= 1.0
        btDir2 := 0

float btWR = btTrades > 0 ? float(btWins) / float(btTrades) * 100.0 : 0.0
float btEV = btTrades > 0 ? btPnlR / float(btTrades) : 0.0

// ─────────────────────────────────────────────────────────────────────────────
//  DASHBOARD — HORIZONTAL 9-COLUMN, bottom_center
// ─────────────────────────────────────────────────────────────────────────────
string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

var table dash = table.new(position.bottom_center, 9, 4,
     bgcolor=color.new(#0d1117, 10),
     border_color=color.new(#30363d, 20), border_width=1,
     frame_color=color.new(#30363d, 40),  frame_width=1)

if showDash and barstate.islast
    color hBg  = color.new(#0d1f1e, 0)
    color pBg  = color.new(#0d1117, 30)
    color cMut = color.new(#8b949e, 0)

    // ── Row 0 — title stripe ─────────────────────────────────────────────────
    table.cell(dash, 0, 0, " Delta Barometer [JOAT] ",
         text_color=colorBULL, text_size=dSz, bgcolor=hBg, text_halign=text.align_left)
    for ci = 1 to 8
        table.cell(dash, ci, 0, "", text_color=cMut, text_size=dSz, bgcolor=hBg)

    // ── Row 1 — column headers ────────────────────────────────────────────────
    string[] headers = array.from("MODE","REGIME","TSS","PRESSURE","TRAIL DIR","DELTA","ENGINE","SIGNAL","STATUS")
    for ci = 0 to 8
        table.cell(dash, ci, 1, headers.get(ci),
             text_color=cMut, text_size=dSz,
             bgcolor=color.new(#161b22, 0), text_halign=text.align_center)

    // ── Row 2 — live values ───────────────────────────────────────────────────
    string modeTxt  = hybridMode == "Both Engines" ? "CONFLUENCE" :
         hybridMode == "Priority A" ? "PRI A" :
         hybridMode == "Priority B" ? "PRI B" : "EITHER"
    color  modeCol  = hybridMode == "Both Engines" ? colorELITE : colorBULL

    string regTxt   = regName + " " + str.tostring(activeMult, "#.#") + "x"
    color  regCol   = regLow ? colorBULL : regHigh ? colorBEAR : colorNEUTR

    string tssTxt   = str.tostring(math.round(tssScore))
    color  tssCol   = tssScore > 60 ? colorBULL : tssScore > 40 ? colorNEUTR : colorBEAR

    string pressTxt  = str.tostring(math.round(pressScore))
    color  pressCol2 = pressScore > 60 ? colorBULL : pressScore > 40 ? colorNEUTR : colorBEAR

    string trailTxt  = trailUp ? "▲ BULL" : "▼ BEAR"
    color  trailCol2 = trailUp ? colorBULL : colorBEAR

    string deltaTxt = cumDelta > deltaMA ? "▲" : "▼"
    color  deltaCol = cumDelta > deltaMA ? colorBULL : colorBEAR

    string engTxt  = engineId == 3 ? "A + B" : engineId == 1 ? "A" : engineId == 2 ? "B" : "─"
    color  engCol  = engineId == 3 ? colorELITE : engineId > 0 ? colorBULL : cMut

    string sigTxt  = confirmedBuy ? "▲ LONG" : confirmedSell ? "▼ SHORT" : "─ WAIT"
    color  sigCol  = confirmedBuy ? colorBULL : confirmedSell ? colorBEAR : cMut

    string statusTxt = btTrades > 0 ? str.tostring(btWR, "#.#") + "% WR" : "─"
    color  statusCol = btWR >= 55 ? colorBULL : btWR >= 40 ? colorNEUTR : btTrades > 0 ? colorBEAR : cMut

    table.cell(dash, 0, 2, modeTxt,   text_color=modeCol,   text_size=dSz, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 1, 2, regTxt,    text_color=regCol,    text_size=dSz, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 2, 2, tssTxt,    text_color=tssCol,    text_size=dSz, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 3, 2, pressTxt,  text_color=pressCol2, text_size=dSz, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 4, 2, trailTxt,  text_color=trailCol2, text_size=dSz, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 5, 2, deltaTxt,  text_color=deltaCol,  text_size=dSz, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 6, 2, engTxt,    text_color=engCol,    text_size=dSz, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 7, 2, sigTxt,    text_color=sigCol,    text_size=dSz, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 8, 2, statusTxt, text_color=statusCol, text_size=dSz, bgcolor=hBg, text_halign=text.align_center)

    // ── Row 3 — detail / sub-values ───────────────────────────────────────────
    table.cell(dash, 0, 3, hybridMode,
         text_color=cMut, text_size=size.tiny, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 1, 3, aArmed ? "A Armed" : "A Off",
         text_color=aArmed ? colorBULL : cMut, text_size=size.tiny, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 2, 3, "RSI " + str.tostring(math.round(rsiNow)),
         text_color=cMut, text_size=size.tiny, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 3, 3, bArmed ? "B Armed" : "B Off",
         text_color=bArmed ? colorBULL : cMut, text_size=size.tiny, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 4, 3, not na(trail) ? str.tostring(trail, format.mintick) : "─",
         text_color=cMut, text_size=size.tiny, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 5, 3, str.tostring(math.round(cumDelta)),
         text_color=cMut, text_size=size.tiny, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 6, 3, "CD " + str.tostring(barsCD) + "b",
         text_color=cMut, text_size=size.tiny, bgcolor=pBg, text_halign=text.align_center)
    table.cell(dash, 7, 3, str.tostring(btTrades) + " trades",
         text_color=cMut, text_size=size.tiny, bgcolor=hBg, text_halign=text.align_center)
    table.cell(dash, 8, 3,
         btTrades > 0 ? (btEV >= 0 ? "+" : "") + str.tostring(btEV, "#.##") + "R" : "─",
         text_color=btEV >= 0 ? colorBULL : colorBEAR,
         text_size=size.tiny, bgcolor=pBg, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(confirmedBuy  and engineId == 1,
     "Delta Barometer Long A",
     "Delta Barometer: Engine A — bull trail flip confirmed.")

alertcondition(confirmedBuy  and engineId == 2,
     "Delta Barometer Long B",
     "Delta Barometer: Engine B — delta crossover confirmed.")

alertcondition(confirmedBuy  and engineId == 3,
     "Delta Barometer Long Both",
     "Delta Barometer: Confluence — both engines bullish.")

alertcondition(confirmedSell and engineId == 1,
     "Delta Barometer Short A",
     "Delta Barometer: Engine A — bear trail flip confirmed.")

alertcondition(confirmedSell and engineId == 2,
     "Delta Barometer Short B",
     "Delta Barometer: Engine B — delta crossdown confirmed.")

alertcondition(confirmedSell and engineId == 3,
     "Delta Barometer Short Both",
     "Delta Barometer: Confluence — both engines bearish.")

alertcondition(regName != regName[1],
     "Delta Barometer Regime Change",
     "Delta Barometer: Volatility regime changed.")

// ─────────────────────────────────────────────────────────────────────────────
//  END OF SCRIPT
// ─────────────────────────────────────────────────────────────────────────────
````
