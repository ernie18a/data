# Entropic Regime Field [JOAT]

- url: https://www.tradingview.com/script/NK5dYlr4-Entropic-Regime-Field-JOAT/
- type: indicator
- pine_id: PUB;d97d14cd762445c28b992f9f749214f0
- version: 1.0

## Description

Entropic Regime Field is an open-source market state classifier that uses three quantitative measures — Fractal Efficiency Ratio, a synthetic Hurst Exponent approximation, and a Garman-Klass volatility estimator — to classify each bar into one of three entropy states: LOW (predictable, directional structure present), TRANSITION (regime shift underway), and HIGH (chaotic, low-predictability environment). Directional signals from an Adaptive Momentum Oscillator are filtered to fire only during LOW entropy states, where momentum signals have historically more reliable edge than during random or chaotic market behavior.

The foundational premise is that markets alternate between periods of organized directional behavior and periods of disorganized random movement. Trading momentum signals indiscriminately across both environments degrades overall performance because the same signal that has edge in a trending market produces random outcomes in a chaotic one. By measuring the structural organization of price movement directly — rather than relying on ADX alone, which is a lagging momentum derivative — Entropic Regime Field attempts to identify when the market's behavior is organized enough for directional signals to have context.


[b]Core Concepts[/b]

[b]1. Fractal Efficiency Ratio (FER)[/b]

The FER measures how efficiently price has moved over a lookback period — the ratio of the net directional distance to the total path length of individual bar-to-bar changes. A value near 1.0 indicates straight-line directional movement; a value near 0.0 indicates constant reversals:

[pine]
float ferNet  = math.abs(close - close[ferLen])
float ferPath = math.sum(math.abs(ta.change(close)), ferLen)
float ferVal  = ferPath > 0.0 ? ferNet / ferPath : 0.0
[/pine]

[b]2. Synthetic Hurst Exponent[/b]

The Hurst Exponent characterizes the memory of a time series. Values above 0.5 indicate persistence (trending), values near 0.5 indicate randomness, and values below 0.5 indicate anti-persistence (mean-reversion). A simplified Hurst estimate is computed using the variance ratio method:

[pine]
float var1    = ta.variance(ta.change(close, 1), hurstWindow)
float var5    = ta.variance(ta.change(close, 5) / 5, hurstWindow)
float hurstEst= 0.5 * math.log(var1 / var5) / math.log(5) + 0.5
[/pine]

[b]3. Garman-Klass Volatility Estimator[/b]

Standard ATR uses only the prior close and current high/low. The Garman-Klass estimator uses all four OHLC prices, producing a more statistically efficient estimate of true volatility:

[pine]
gkBar = 0.5 * math.pow(math.log(high / math.max(low, syminfo.mintick)), 2.0)
      - (2.0 * math.log(2.0) - 1.0) * math.pow(math.log(close / math.max(open, syminfo.mintick)), 2.0)
[/pine]

The GK estimate is averaged over a configurable period and normalized to a 0-100 percentile rank over the trailing 100 bars.

[b]4. Three-Factor Entropy Classification[/b]

LOW entropy requires FER above a threshold AND ADX above a minimum AND Hurst estimate above 0.52. HIGH entropy is triggered when FER falls below a lower threshold OR ADX falls below a minimum. TRANSITION is the state between the two.

[b]5. Adaptive Momentum Oscillator (AMO)[/b]

The AMO blends three momentum inputs with fixed weights: RSI(14) centered at 50 (40%), Stochastic(14) centered at 50 (35%), and Williams Percent Range(14) centered at -50 (25%). Directional signals fire only in LOW entropy when AMO crosses zero and KAMA confirms via crossover/under.


[b]Features[/b]

[list]
[*][b]Fractal Efficiency Ratio:[/b] Net directional move divided by total path length, configurable lookback
[*][b]Synthetic Hurst Exponent:[/b] Variance ratio approximation identifying persistent vs. anti-persistent price behavior
[*][b]Garman-Klass volatility:[/b] OHLC-based volatility estimator normalized to percentile rank over 100 bars
[*][b]Three entropy states:[/b] LOW, TRANSITION, HIGH — each with distinct visual treatment
[*][b]10-line entropy ribbon:[/b] EMA lines colored by entropy state for visual history of regime transitions
[*][b]Adaptive Momentum Oscillator:[/b] RSI + Stochastic + WPR composite with fixed optimal weights
[*][b]Entropy-gated signals:[/b] AMO + KAMA confirmation signals fire only in LOW entropy state
[*][b]Regime background tint:[/b] Background tinted by entropy state, cleared after 10 bars
[*][b]Trade block on signal:[/b] ATR-based TP and stop rendered as boxes on signal bars
[*][b]12-row institutional dashboard:[/b] FER, Hurst estimate, GK volatility percentile, ADX, AMO, entropy state, signal, win rate, bars in current state
[*][b]Non-repainting:[/b] All signals gated by barstate.isconfirmed; no future data referenced
[*][b]Four color themes:[/b] Phantom, Neon, Classic, Solar
[/list]

[b]Input Parameters[/b]

[b]Fractal Efficiency:[/b]
[list]
[*]FER Lookback (default: 14)
[*]LOW Entropy FER Minimum (default: 0.60)
[*]HIGH Entropy FER Maximum (default: 0.35)
[/list]

[b]Hurst Exponent:[/b]
[list]
[*]Hurst Window (default: 20)
[*]LOW Entropy Hurst Minimum (default: 0.52)
[/list]

[b]Garman-Klass Volatility:[/b]
[list]
[*]GK Averaging Length (default: 14)
[/list]

[b]ADX Gate:[/b]
[list]
[*]Min ADX for LOW Entropy (default: 22)
[/list]

[b]Signal:[/b]
[list]
[*]AMO Cross Threshold, KAMA Period, Cooldown Bars
[*]TP ATR Multiple, SL ATR Multiple
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Entropy State[/b]
Check the dashboard. LOW entropy means the market is behaving in an organized, directional way — this is when momentum signals carry more weight. HIGH entropy means the market is chaotic — avoid directional signals.

[b]Step 2: Watch FER and Hurst Together[/b]
FER and Hurst are independent measures of market organization. When both agree (high FER AND Hurst > 0.52 simultaneously), the LOW entropy classification is more reliable.

[b]Step 3: Enter on AMO + KAMA Confirmation[/b]
Signals fire only when the AMO crosses zero in the signal direction AND price crosses the KAMA level simultaneously. Both conditions must occur on the same confirmed bar in a LOW entropy environment.

[b]Indicator Limitations[/b]

[list]
[*]The Hurst approximation via variance ratio is a simplified estimate. It should be treated as a directional indicator of persistence, not a precise statistical measure
[*]The FER computation on every bar may affect chart loading performance for very long lookback periods on large datasets
[*]LOW entropy classifications can persist during slow grinding trends that produce high FER but low volatility. These environments may produce signals with narrower ATR-based targets
[*]The GK estimator can return unreliable values when open equals close (as occurs on some synthetic instruments or during gaps)
[*]This indicator classifies entropy state. It does not predict how long the state will persist or when it will change
[/list]

[b]Originality Statement[/b]

[list]
[*]The combination of Fractal Efficiency Ratio, synthetic Hurst Exponent via variance ratio, and Garman-Klass volatility estimator as a three-factor entropy classification system gating AMO momentum signals is not replicated in any existing open-source Pine Script v6 publication as of this writing
[*]The Garman-Klass estimator as a volatility input provides a more statistically efficient OHLC-based volatility measure that captures intraday range information not available in ATR
[*]Gating a composite three-input momentum oscillator by an entropy state derived from completely different mathematical principles (efficiency, persistence, and OHLC volatility) rather than using a single lagging derivative like ADX as the sole filter is an original analytical architecture
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves substantial risk of loss. Entropy classifications are approximations based on historical price data and do not guarantee future market behavior will repeat. The Hurst approximation used is a simplified estimate, not a statistically rigorous computation. Past win rates do not predict future performance. The author accepts no responsibility for trading losses resulting from use of this indicator.

Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Entropic Regime Field [JOAT]", overlay=true, max_boxes_count=10, max_lines_count=10, max_labels_count=20)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  COLOR THEMES
// ══════════════════════════════════════════════════════════════════════════════
string themeInput = input.string("Neon", "Color Theme",
     options=["Phantom","Neon","Classic","Solar"], group="◈ Visual")

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

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — FRACTAL EFFICIENCY RATIO
// ══════════════════════════════════════════════════════════════════════════════
var string G_FER = "◈ Fractal Efficiency"
int   ferLen  = input.int(14,    "FER Lookback",           minval=2,  maxval=50,  group=G_FER)
float ferLow  = input.float(0.60,"LOW Entropy FER Min",    minval=0.1,maxval=1.0, step=0.05, group=G_FER)
float ferHigh = input.float(0.35,"HIGH Entropy FER Max",   minval=0.0,maxval=0.8, step=0.05, group=G_FER)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — HURST EXPONENT
// ══════════════════════════════════════════════════════════════════════════════
var string G_HURST = "◈ Hurst Exponent"
int   hurstWindow = input.int(20,   "Hurst Window",            minval=5,  maxval=50,  group=G_HURST)
float hurstLow    = input.float(0.52,"LOW Entropy Hurst Min",  minval=0.4,maxval=0.9, step=0.01, group=G_HURST)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — GARMAN-KLASS VOLATILITY
// ══════════════════════════════════════════════════════════════════════════════
var string G_GK = "◈ Garman-Klass Volatility"
int gkLen = input.int(14, "GK Averaging Length", minval=2, maxval=50, group=G_GK)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — ADX GATE
// ══════════════════════════════════════════════════════════════════════════════
var string G_ADX = "◈ ADX Gate"
int adxMinLow = input.int(22, "Min ADX for LOW Entropy", minval=0, maxval=60, group=G_ADX)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — SIGNAL
// ══════════════════════════════════════════════════════════════════════════════
var string G_SIG = "◈ Signal"
float amoThresh = input.float(20.0, "AMO Cross Threshold", minval=0.0,  maxval=50.0, group=G_SIG)
int   kamaPer   = input.int(21,     "KAMA Period",         minval=5,    maxval=50,   group=G_SIG)
int   cooldown  = input.int(5,      "Cooldown Bars",       minval=0,    maxval=20,   group=G_SIG)
float tpMultATR = input.float(2.0,  "TP ATR Multiple",     step=0.5,                group=G_SIG)
float slMultATR = input.float(1.5,  "SL ATR Multiple",     step=0.5,                group=G_SIG)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — VISUAL
// ══════════════════════════════════════════════════════════════════════════════
var string G_VIS = "◈ Visual"
bool showRibbon = input.bool(true,  "Show Entropy Ribbon",  group=G_VIS)
bool showBG     = input.bool(true,  "Show Entropy Tint",    group=G_VIS)
bool showBlock  = input.bool(true,  "Show Trade Block",     group=G_VIS)
int  extR       = input.int(15,     "Block Extend Bars",    minval=1, maxval=80, group=G_VIS)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  INPUTS — DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
var string G_DASH = "◈ Dashboard"
bool   showDash = input.bool(true,        "Show Dashboard", group=G_DASH)
string dashPos  = input.string("Top Right","Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=G_DASH)
string dashSize = input.string("Small",    "Size",
     options=["Tiny","Small","Normal"], group=G_DASH)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  HELPER — KAMA FUNCTION  (defined before first call site)
// ══════════════════════════════════════════════════════════════════════════════
kamaF(simple int kLen) =>
    float diff = math.abs(ta.change(close, kLen))
    float vola = math.sum(math.abs(ta.change(close)), kLen)
    float er   = vola != 0.0 ? diff / vola : 0.0
    float sc   = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2.0)
    var float k = na
    k := nz(k[1], close) + sc * (close - nz(k[1], close))
    k

// ══════════════════════════════════════════════════════════════════════════════
// ◈  CORE CALCULATION 1 — FRACTAL EFFICIENCY RATIO (FER)
// ══════════════════════════════════════════════════════════════════════════════
// Net directional displacement divided by total path length.
// FER near 1 → strongly trending; FER near 0 → chaotic/random.
// Uses math.sum to avoid any loop — pure vectorized computation.
float ferNet  = math.abs(close - close[ferLen])
float ferPath = math.sum(math.abs(ta.change(close)), ferLen)
float ferVal  = ferPath > 0.0 ? ferNet / ferPath : 0.0

// ══════════════════════════════════════════════════════════════════════════════
// ◈  CORE CALCULATION 2 — GARMAN-KLASS VOLATILITY
// ══════════════════════════════════════════════════════════════════════════════
// Uses OHLC data to estimate realized variance, significantly more efficient
// than close-to-close returns.  Averaged over gkLen bars then normalized to
// 0-100 percentile rank across the last 100 bars.
float _gkH   = math.max(high,  open  + syminfo.mintick)
float _gkL   = math.max(low,   syminfo.mintick)
float _gkC   = math.max(close, syminfo.mintick)
float _gkO   = math.max(open,  syminfo.mintick)
float gkBar  = 0.5 * math.pow(math.log(_gkH / _gkL), 2.0) -
               (2.0 * math.log(2.0) - 1.0) * math.pow(math.log(_gkC / _gkO), 2.0)
float gkAvg  = ta.sma(math.max(0.0, gkBar), gkLen)

float gkLow100  = ta.lowest(gkAvg,  100)
float gkHigh100 = ta.highest(gkAvg, 100)
float gkNorm    = (gkHigh100 - gkLow100) > 0.0 ?
     (gkAvg - gkLow100) / (gkHigh100 - gkLow100) * 100.0 : 50.0

// ══════════════════════════════════════════════════════════════════════════════
// ◈  CORE CALCULATION 3 — SYNTHETIC HURST EXPONENT  (variance-ratio method)
// ══════════════════════════════════════════════════════════════════════════════
// H > 0.5  →  trending (persistent)   →  low entropy
// H ≈ 0.5  →  random walk             →  transition
// H < 0.5  →  mean-reverting          →  higher entropy for directional trades
float chg1    = ta.change(close, 1)
float chg5    = ta.change(close, 5) / 5.0
float var1    = ta.variance(chg1, hurstWindow)
float var5    = ta.variance(chg5, hurstWindow)
float logRatio = (var5 > 0.0 and var1 > 0.0) ? math.log(var1 / var5) : 0.0
float hurstEst = math.max(0.1, math.min(0.9,
     0.5 * logRatio / math.log(5.0) + 0.5))

// ══════════════════════════════════════════════════════════════════════════════
// ◈  CORE CALCULATION 4 — ADX
// ══════════════════════════════════════════════════════════════════════════════
[diP, diM, adxVal] = ta.dmi(14, 14)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  ENTROPY STATE CLASSIFICATION
// ══════════════════════════════════════════════════════════════════════════════
// LOW  (1) — trending, predictable; signals are active
// TRANS(2) — mixed environment; signals are suppressed
// HIGH (3) — chaotic; signals are suppressed
bool entropLow  = ferVal  >= ferLow  and adxVal >= float(adxMinLow) and hurstEst >= hurstLow
bool entropHigh = ferVal  <= ferHigh or  adxVal < 14.0
bool entropTrans = not entropLow and not entropHigh

// Numeric state for change detection
int entropyState = entropLow ? 1 : entropHigh ? 3 : 2

// ══════════════════════════════════════════════════════════════════════════════
// ◈  REGIME BACKGROUND TINT  (brief flash on state change)
// ══════════════════════════════════════════════════════════════════════════════
var int stateChangeBar = -1
if entropyState != entropyState[1]
    stateChangeBar := bar_index

color entropTint = na
if showBG and stateChangeBar >= 0 and bar_index - stateChangeBar < 10
    entropTint := entropLow  ? color.new(colorBULL, 94) :
                  entropHigh ? color.new(colorBEAR, 94) :
                               color.new(colorNEUTR, 96)
bgcolor(entropTint)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  CORE CALCULATION 5 — KAMA  (Kaufman Adaptive Moving Average)
// ══════════════════════════════════════════════════════════════════════════════
float kamaVal = kamaF(kamaPer)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  CORE CALCULATION 6 — AMO  (Adaptive Momentum Oscillator)
// ══════════════════════════════════════════════════════════════════════════════
// Composite of RSI, Stochastic and Williams %R, each centered on zero.
// Weights: RSI 40%, Stoch 35%, WPR 25%.  Output range: −100 … +100.
float rsiRaw  = ta.rsi(close, 14)
float rsiN    = (rsiRaw - 50.0) / 50.0

float stochRaw = ta.stoch(close, high, low, 14)
float stochN   = (stochRaw - 50.0) / 50.0

float wprRaw  = ta.wpr(14)
float wprN    = -(wprRaw + 50.0) / 50.0

float amo = (rsiN * 0.40 + stochN * 0.35 + wprN * 0.25) * 100.0

// ══════════════════════════════════════════════════════════════════════════════
// ◈  SIGNAL GENERATION — LOW-ENTROPY GATED
// ══════════════════════════════════════════════════════════════════════════════
// Both AMO threshold cross and price/KAMA cross must agree.
// Signals fire only in confirmed LOW-entropy bars with cooldown respected.
bool amoXup = ta.crossover(amo,   amoThresh)  and entropLow and
              ta.crossover(close, kamaVal)     and barstate.isconfirmed
bool amoXdn = ta.crossunder(amo, -amoThresh)  and entropLow and
              ta.crossunder(close, kamaVal)    and barstate.isconfirmed

var int barsCD = 999
barsCD += 1
bool longSig  = amoXup and barsCD >= cooldown
bool shortSig = amoXdn and barsCD >= cooldown
if longSig or shortSig
    barsCD := 0

// ══════════════════════════════════════════════════════════════════════════════
// ◈  ATR (shared reference)
// ══════════════════════════════════════════════════════════════════════════════
float atr14 = ta.atr(14)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  TP / SL TRADE BLOCK  (lines, labels, boxes)
// ══════════════════════════════════════════════════════════════════════════════
var float bEntry = na
var float bSL    = na
var float bTP    = na
var int   bDir   = 0
var line  lnE    = na
var line  lnS    = na
var line  lnT    = na
var label lbE    = na
var label lbS    = na
var label lbT    = na
var box   bxR    = na
var box   bxW    = na

if longSig
    bEntry := close
    bSL    := close - atr14 * slMultATR
    bTP    := close + atr14 * tpMultATR
    bDir   := 1
    line.delete(lnE)
    line.delete(lnS)
    line.delete(lnT)
    label.delete(lbE)
    label.delete(lbS)
    label.delete(lbT)
    box.delete(bxR)
    box.delete(bxW)
    int eBL = bar_index + extR
    lnE := line.new(bar_index, bEntry, eBL, bEntry,
         color=#ffffff, width=1)
    lnS := line.new(bar_index, bSL, eBL, bSL,
         color=colorBEAR, width=1, style=line.style_dashed)
    lnT := line.new(bar_index, bTP, eBL, bTP,
         color=color.rgb(0, 220, 100), width=2)
    lbE := label.new(eBL, bEntry,
         "ENTRY  " + str.tostring(bEntry, format.mintick),
         style=label.style_label_left,
         color=color.new(#ffffff, 80), textcolor=#ffffff, size=size.small)
    lbS := label.new(eBL, bSL,
         "STOP  " + str.tostring(bSL, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBEAR, 80), textcolor=colorBEAR, size=size.small)
    lbT := label.new(eBL, bTP,
         "TP  " + str.tostring(bTP, format.mintick),
         style=label.style_label_left,
         color=color.new(color.rgb(0, 220, 100), 80),
         textcolor=color.rgb(0, 220, 100), size=size.small)
    bxR := box.new(bar_index, bEntry, eBL, bSL,
         bgcolor=color.new(colorBEAR, 88),
         border_color=color.new(colorBEAR, 70))
    bxW := box.new(bar_index, bTP, eBL, bEntry,
         bgcolor=color.new(colorBULL, 88),
         border_color=color.new(colorBULL, 70))

if shortSig
    bEntry := close
    bSL    := close + atr14 * slMultATR
    bTP    := close - atr14 * tpMultATR
    bDir   := -1
    line.delete(lnE)
    line.delete(lnS)
    line.delete(lnT)
    label.delete(lbE)
    label.delete(lbS)
    label.delete(lbT)
    box.delete(bxR)
    box.delete(bxW)
    int eBs = bar_index + extR
    lnE := line.new(bar_index, bEntry, eBs, bEntry,
         color=#ffffff, width=1)
    lnS := line.new(bar_index, bSL, eBs, bSL,
         color=colorBEAR, width=1, style=line.style_dashed)
    lnT := line.new(bar_index, bTP, eBs, bTP,
         color=color.rgb(0, 220, 100), width=2)
    lbE := label.new(eBs, bEntry,
         "ENTRY  " + str.tostring(bEntry, format.mintick),
         style=label.style_label_left,
         color=color.new(#ffffff, 80), textcolor=#ffffff, size=size.small)
    lbS := label.new(eBs, bSL,
         "STOP  " + str.tostring(bSL, format.mintick),
         style=label.style_label_left,
         color=color.new(colorBEAR, 80), textcolor=colorBEAR, size=size.small)
    lbT := label.new(eBs, bTP,
         "TP  " + str.tostring(bTP, format.mintick),
         style=label.style_label_left,
         color=color.new(color.rgb(0, 220, 100), 80),
         textcolor=color.rgb(0, 220, 100), size=size.small)
    bxR := box.new(bar_index, bSL, eBs, bEntry,
         bgcolor=color.new(colorBEAR, 88),
         border_color=color.new(colorBEAR, 70))
    bxW := box.new(bar_index, bEntry, eBs, bTP,
         bgcolor=color.new(colorBULL, 88),
         border_color=color.new(colorBULL, 70))

// Extend block lines/labels/boxes to current bar
if not na(lnE) and showBlock
    int re = bar_index + extR
    line.set_x2(lnE, re)
    line.set_x2(lnS, re)
    line.set_x2(lnT, re)
    label.set_x(lbE, re)
    label.set_x(lbS, re)
    label.set_x(lbT, re)
    box.set_right(bxR, re)
    box.set_right(bxW, re)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  ENTROPY RIBBON  (10 EMA lines, color-coded by entropy state)
// ══════════════════════════════════════════════════════════════════════════════
color eRibCol = entropLow ? colorBULL : entropHigh ? colorBEAR : colorNEUTR

ep1  = plot(showRibbon ? ta.ema(close, 10)  : na, "ER01", color.new(eRibCol, 10), 1)
ep2  = plot(showRibbon ? ta.ema(close, 20)  : na, "ER02", color.new(eRibCol, 20), 1)
ep3  = plot(showRibbon ? ta.ema(close, 30)  : na, "ER03", color.new(eRibCol, 30), 1)
ep4  = plot(showRibbon ? ta.ema(close, 40)  : na, "ER04", color.new(eRibCol, 40), 1)
ep5  = plot(showRibbon ? ta.ema(close, 50)  : na, "ER05", color.new(eRibCol, 50), 1)
ep6  = plot(showRibbon ? ta.ema(close, 60)  : na, "ER06", color.new(eRibCol, 60), 1)
ep7  = plot(showRibbon ? ta.ema(close, 70)  : na, "ER07", color.new(eRibCol, 70), 1)
ep8  = plot(showRibbon ? ta.ema(close, 80)  : na, "ER08", color.new(eRibCol, 78), 1)
ep9  = plot(showRibbon ? ta.ema(close, 90)  : na, "ER09", color.new(eRibCol, 85), 1)
ep10 = plot(showRibbon ? ta.ema(close, 100) : na, "ER10", color.new(eRibCol, 90), 1)

fill(ep1,  ep2,  color=color.new(eRibCol, 93))
fill(ep2,  ep3,  color=color.new(eRibCol, 94))
fill(ep3,  ep4,  color=color.new(eRibCol, 94))
fill(ep4,  ep5,  color=color.new(eRibCol, 95))
fill(ep5,  ep6,  color=color.new(eRibCol, 95))
fill(ep6,  ep7,  color=color.new(eRibCol, 96))
fill(ep7,  ep8,  color=color.new(eRibCol, 96))
fill(ep8,  ep9,  color=color.new(eRibCol, 97))
fill(ep9,  ep10, color=color.new(eRibCol, 97))

// ══════════════════════════════════════════════════════════════════════════════
// ◈  KAMA PLOT
// ══════════════════════════════════════════════════════════════════════════════
plot(kamaVal, "KAMA", color.new(colorELITE, 40), 1)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  SIGNAL LABELS
// ══════════════════════════════════════════════════════════════════════════════
if longSig
    label.new(bar_index, low - atr14 * 0.5,
         "▲  LONG\nFER:" + str.tostring(ferVal, "#.##") +
         "  H:" + str.tostring(hurstEst, "#.##"),
         style=label.style_label_up,
         color=color.new(colorBULL, 75), textcolor=colorBULL, size=size.small)

if shortSig
    label.new(bar_index, high + atr14 * 0.5,
         "▼  SHORT\nFER:" + str.tostring(ferVal, "#.##") +
         "  H:" + str.tostring(hurstEst, "#.##"),
         style=label.style_label_down,
         color=color.new(colorBEAR, 75), textcolor=colorBEAR, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// ◈  LIGHTWEIGHT BACKTEST  (bar-by-bar, no strategy() API)
// ══════════════════════════════════════════════════════════════════════════════
// Tracks the most recent signal and checks whether TP or SL was hit on
// subsequent bars.  Results feed the dashboard win-rate / EV rows.
var int   btT  = 0       // total trades
var int   btW  = 0       // winners
var float btR  = 0.0     // cumulative R
var int   btD  = 0       // direction: 1=long, -1=short, 0=flat
var float btTP2 = na     // pending TP price
var float btSL2 = na     // pending SL price

if longSig
    btD   := 1
    btTP2 := close + atr14 * tpMultATR
    btSL2 := close - atr14 * slMultATR

if shortSig
    btD   := -1
    btTP2 := close - atr14 * tpMultATR
    btSL2 := close + atr14 * slMultATR

if btD != 0 and not na(btTP2) and not na(btSL2)
    bool bw = btD == 1 ? high >= btTP2 : low  <= btTP2
    bool bl = btD == 1 ? low  <= btSL2 : high >= btSL2
    if bw or bl
        btT += 1
        if bw
            btW += 1
            btR += tpMultATR
        else
            btR -= 1.0
        btD := 0

float btWR = btT > 0 ? float(btW) / float(btT) * 100.0 : 0.0
float btEV = btT > 0 ? btR / float(btT) : 0.0

// ══════════════════════════════════════════════════════════════════════════════
// ◈  DASHBOARD  (12-row table, right/left corner configurable)
// ══════════════════════════════════════════════════════════════════════════════
string dashPosVal = switch dashPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

string dSz = switch dashSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    =>          size.small

var table dash = table.new(dashPosVal, 2, 13,
     bgcolor=color.new(#0d1117, 10),
     border_color=color.new(#30363d, 20), border_width=1,
     frame_color=color.new(#30363d, 40), frame_width=1)

// Helper: write one dashboard cell
f_dc(int col, int row, string txt, color tc, color bg) =>
    table.cell(dash, col, row, txt,
         text_color=tc, text_size=dSz, bgcolor=bg,
         text_halign=col == 0 ? text.align_left : text.align_right)

if showDash and barstate.islast
    color hBg  = color.new(#1A237E, 0)
    color pBg  = color.new(#161b22, 0)
    color dBg  = color.new(#0d1117, 10)
    color cMut = color.new(#8b949e, 0)

    // Row 0 — header
    f_dc(0, 0, "Entropic Regime Field [JOAT]", colorELITE, hBg)
    f_dc(1, 0, timeframe.period + " | v1.0",   cMut,       hBg)

    // Row 1 — entropy state
    string entTxt = entropLow ? "LOW" : entropHigh ? "HIGH" : "TRANSITION"
    color  entCol = entropLow ? colorBULL : entropHigh ? colorBEAR : colorNEUTR
    f_dc(0, 1, "Entropy State", cMut, pBg)
    f_dc(1, 1, entTxt, entCol, dBg)

    // Row 2 — FER
    color ferCol = ferVal >= ferLow ? colorBULL : ferVal <= ferHigh ? colorBEAR : colorNEUTR
    f_dc(0, 2, "FER", cMut, pBg)
    f_dc(1, 2, str.tostring(ferVal, "#.###"), ferCol, dBg)

    // Row 3 — Hurst
    color hCol = hurstEst > 0.55 ? colorBULL : hurstEst < 0.45 ? colorBEAR : colorNEUTR
    f_dc(0, 3, "Hurst Est", cMut, pBg)
    f_dc(1, 3, str.tostring(hurstEst, "#.###"), hCol, dBg)

    // Row 4 — GK Volatility
    color gkCol = gkNorm > 70 ? colorBEAR : gkNorm < 30 ? colorBULL : colorNEUTR
    f_dc(0, 4, "GK Volatility", cMut, pBg)
    f_dc(1, 4, str.tostring(gkNorm, "#.#") + "%ile", gkCol, dBg)

    // Row 5 — ADX
    color aCol = adxVal > 25 ? colorBULL : cMut
    f_dc(0, 5, "ADX", cMut, pBg)
    f_dc(1, 5, str.tostring(math.round(adxVal)), aCol, dBg)

    // Row 6 — AMO
    color amoCol = amo > amoThresh ? colorBULL : amo < -amoThresh ? colorBEAR : colorNEUTR
    f_dc(0, 6, "AMO", cMut, pBg)
    f_dc(1, 6, str.tostring(amo, "#.#"), amoCol, dBg)

    // Row 7 — KAMA
    f_dc(0, 7, "KAMA", cMut, pBg)
    f_dc(1, 7, str.tostring(kamaVal, format.mintick),
         close > kamaVal ? colorBULL : colorBEAR, dBg)

    // Row 8 — Signal gate
    string sigG = entropLow ? "OPEN" : "BLOCKED"
    color  sigC = entropLow ? colorBULL : colorBEAR
    f_dc(0, 8, "Signal Gate", cMut, pBg)
    f_dc(1, 8, sigG, sigC, dBg)

    // Row 9 — Win rate
    color wrC = btWR >= 55 ? colorBULL : btWR >= 40 ? colorNEUTR : btT > 0 ? colorBEAR : cMut
    f_dc(0, 9, "Win Rate", cMut, pBg)
    f_dc(1, 9, btT > 0 ? str.tostring(btWR, "#.#") + "%" : "─", wrC, dBg)

    // Row 10 — Expected value
    color evC = btEV >= 0 ? colorBULL : colorBEAR
    f_dc(0, 10, "Exp Value", cMut, pBg)
    f_dc(1, 10, btT > 0 ? (btEV >= 0 ? "+" : "") + str.tostring(btEV, "#.##") + " R" : "─", evC, dBg)

    // Row 11 — Trade count
    f_dc(0, 11, "Trades", cMut, pBg)
    f_dc(1, 11, str.tostring(btT), cMut, dBg)

    // Row 12 — Branding
    f_dc(0, 12, "[JOAT]",           color.new(#6C63FF, 0), color.new(#0d1117, 20))
    f_dc(1, 12, "jackofalltrades",  cMut,                  color.new(#0d1117, 20))

// ══════════════════════════════════════════════════════════════════════════════
// ◈  ALERT CONDITIONS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(longSig,
     "Entropic Regime Long",
     "Entropic Regime Field: LOW entropy bull signal confirmed.")

alertcondition(shortSig,
     "Entropic Regime Short",
     "Entropic Regime Field: LOW entropy bear signal confirmed.")

alertcondition(entropTrans and not entropTrans[1],
     "Entropic Regime Transition",
     "Entropic Regime Field: Market entering TRANSITION state.")

alertcondition(entropHigh and not entropHigh[1],
     "Entropic Regime High",
     "Entropic Regime Field: HIGH entropy — avoid directional trading.")
````
