# Stochastic Resonance Signal [JOAT]

- url: https://www.tradingview.com/script/7IhTAKuE-Stochastic-Resonance-Signal-JOAT/
- type: indicator
- pine_id: PUB;186765109c974e65b465f34bf4224ce3
- version: 1.0

## Description

[b]Stochastic Resonance Signal [JOAT][/b]

[b]Introduction[/b]

Stochastic Resonance Signal is an open-source indicator built on the physical principle of stochastic resonance — the counterintuitive phenomenon where a moderate level of random noise actually enhances the detection of weak periodic signals rather than degrading it. In trading terms: markets with low volatility noise may suppress trend signals, while a calibrated level of volatility noise can help reveal underlying directional structure.

This indicator computes a signal-to-noise score that normalizes a smoothed price derivative against ATR-based noise. The score peaks when a meaningful directional signal is present within a noise environment that is neither too quiet (which produces false flatness) nor too loud (which obscures the signal entirely).

[b]Core Concepts[/b]

[b]1. Signal Component[/b]

The raw signal is the smoothed rate of change of price — the first derivative of a filtered price series. An EMA is applied to close to produce a noise-reduced price, then the bar-to-bar difference of that EMA serves as the signal. Positive signal indicates upward momentum; negative indicates downward:

[pine]
float emaPrice  = ta.ema(close, i_signalLen)
float rawSignal = emaPrice - emaPrice[1]
float normSig   = rawSignal / (ta.stdev(rawSignal, i_normLen) + 0.0001)
[/pine]

The signal is normalized by its own rolling standard deviation, making it dimensionless and comparable across instruments.

[b]2. Noise Component[/b]

Noise is defined as ATR normalized by its rolling standard deviation. This separates the volatility component from the directional component. When noise is very low, it contributes little penalty. When noise is very high, it heavily discounts the signal. The optimal noise range produces the highest SR score:

[pine]
float noisePenalty = ta.stdev(atrVal, i_normLen) / (ta.sma(atrVal, i_normLen) + 0.0001)
float srScore      = math.abs(normSig) / (1.0 + noisePenalty)
[/pine]

[image]https://www.tradingview.com/x/QGZFvkJe/[/image]

[b]3. SR Score and Threshold[/b]

The final SR score combines signal strength divided by noise penalty. The score is plotted as a histogram and compared against a configurable threshold. When the score exceeds the threshold in the positive signal direction, a bullish event fires. When in the negative direction, a bearish event fires. Both require barstate.isconfirmed.

[b]4. Regime Context[/b]

The indicator categorizes the current noise state as Low, Optimal, or High. The Optimal zone — where stochastic resonance theory predicts signal enhancement — is highlighted in the background. Signals fired during the Optimal noise zone are the primary intended use case.

[b]Features[/b]

[list]
[*][b]Normalized signal derivative:[/b] EMA-smoothed price rate of change, dimensionless
[*][b]ATR noise penalty:[/b] Volatility normalized by its own distribution, not a fixed threshold
[*][b]SR Score histogram:[/b] Visual representation of the signal-to-noise ratio each bar
[*][b]Threshold crossover signals:[/b] Bull and bear signals when SR score exceeds the gate
[*][b]Noise regime classification:[/b] Low, Optimal, and High noise zones labeled
[*][b]Optimal zone background:[/b] Chart shading during the resonance-optimal noise window
[*][b]Candle coloring:[/b] Candles tinted by current SR score direction and magnitude
[*][b]Dashboard:[/b] Current SR score, signal value, noise level, and regime state
[*][b]Alerts:[/b] Configurable bull and bear SR threshold crossing alerts
[/list]

[b]Input Parameters[/b]

[b]Signal Engine:[/b]
[list]
[*]Signal EMA Length: Smoothing for price derivative calculation (default: 10)
[*]Normalization Length: Rolling window for z-score normalization (default: 50)
[/list]

[b]Noise Engine:[/b]
[list]
[*]ATR Period: ATR length for noise estimation (default: 14)
[*]Optimal Noise Low: Lower bound of optimal noise zone (default: 0.3)
[*]Optimal Noise High: Upper bound of optimal noise zone (default: 0.8)
[/list]

[b]Signal Gate:[/b]
[list]
[*]SR Score Threshold: Minimum SR score to fire a signal (default: 1.5)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Noise Regime[/b]
Check whether the background shading is active (Optimal zone). Signals fired during optimal noise conditions have the theoretical backing of stochastic resonance theory behind them.

[b]Step 2: Read the SR Score[/b]
A rising histogram above the threshold line in positive territory indicates a developing bullish signal. Crossing below the negative threshold indicates a bearish signal.

[b]Step 3: Apply as a Momentum Filter[/b]
Use SR score direction to confirm or reject signals from other tools. An SR score rising strongly above its threshold while a support level holds adds conviction to a long setup.

[b]Indicator Limitations[/b]

[list]
[*]Stochastic resonance as a trading construct is a theoretical analogy, not a proven quantitative edge on its own
[*]The optimal noise zone boundaries are heuristic; the true optimal noise level varies by instrument and timeframe
[*]Normalization requires a minimum lookback before scores stabilize — expect less meaningful output in the first normLen bars
[/list]

[b]Originality Statement[/b]

The application of stochastic resonance theory to price signal detection — computing a signal-to-noise ratio using a normalized price derivative divided by an ATR noise penalty, with an explicit optimal noise zone classification — is an original analytical framing not found in existing published Pine Script indicators. This is not a standard oscillator; it is a physics-inspired signal processing approach adapted to price data.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. The stochastic resonance framework is a conceptual model and does not guarantee profitable signals. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Stochastic Resonance Signal [JOAT]", shorttitle="SRS [JOAT]", overlay=false,
     max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// Physics-inspired palette: signal=cyan, noise=amber, resonance=magenta
// ═══════════════════════════════════════════════════════════════════════════════
color SIGNAL_CYAN  = color.rgb(  0, 220, 220)
color NOISE_AMBER  = color.rgb(255, 170,  30)
color RESON_MAGENTA= color.rgb(220,   0, 200)
color BULL_MINT    = color.rgb(  0, 230, 120)
color BEAR_PINK    = color.rgb(240,  50, 100)
color VOID_BG      = color.rgb( 10,  14,  26)
color SLATE_BRD    = color.rgb( 40,  55,  90)
color LAVEN_HDR    = color.rgb(140, 160, 210)
color GOLD_VAL     = color.rgb(255, 215,  60)

lerpCol(color cA, color cB, float t) =>
    float ct = math.max(0.0, math.min(1.0, t))
    int r = int(color.r(cA) + (color.r(cB) - color.r(cA)) * ct)
    int g = int(color.g(cA) + (color.g(cB) - color.g(cA)) * ct)
    int b = int(color.b(cA) + (color.b(cB) - color.b(cA)) * ct)
    color.rgb(r, g, b)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_SIGNAL = "━━ Signal Parameters ━━"
string G_NOISE  = "━━ Noise (Entropy) ━━"
string G_SRS    = "━━ Stochastic Resonance ━━"
string G_SIG    = "━━ Signal Detection ━━"
string G_VIZ    = "━━ Visual ━━"

int    i_fastRSI  = input.int(7,    "Fast RSI Length",     minval=2, group=G_SIGNAL,
     tooltip="Fast momentum proxy — forms the 'sub-threshold signal'.")
int    i_slowRSI  = input.int(21,   "Slow RSI Length",     minval=5, group=G_SIGNAL,
     tooltip="Slow RSI for cross-reference. Signal = Fast - Slow (centered at 0).")
int    i_rsiSmooth= input.int(3,    "Signal Smoothing",    minval=1, group=G_SIGNAL)

int    i_entLen   = input.int(20,   "Entropy Lookback",    minval=5, maxval=100, group=G_NOISE)
int    i_entBins  = input.int(10,   "Entropy Bins",        minval=5, maxval=30,  group=G_NOISE)
int    i_entSmooth= input.int(3,    "Entropy Smoothing",   minval=1, group=G_NOISE)

float  i_optNoiseLo= input.float(1.5,"Optimal Noise Low",  minval=0.5, maxval=3.0, step=0.1, group=G_SRS,
     tooltip="Optimal noise band: entropy between these values maximizes stochastic resonance.")
float  i_optNoiseHi= input.float(2.5,"Optimal Noise High", minval=0.5, maxval=4.0, step=0.1, group=G_SRS)

float  i_srThr    = input.float(0.3, "SR Score Signal Threshold", minval=0.05, maxval=1.0, step=0.05, group=G_SIG,
     tooltip="Minimum SR score required to generate a signal.")
int    i_cooldown = input.int(5,    "Signal Cooldown (bars)",    minval=1, group=G_SIG)

bool   i_showDash = input.bool(true, "Show Dashboard",           group=G_VIZ)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — NOISE MEASUREMENT (Shannon Entropy)
// High entropy = high noise = chaotic. Low entropy = low noise = ordered.
// ═══════════════════════════════════════════════════════════════════════════════
float logRets = math.log(close / nz(close[1], close))

calcEntropy(float src, int len, int bins) =>
    float minV = ta.lowest(src,  len)
    float maxV = ta.highest(src, len)
    float rng  = maxV - minV
    float bw   = rng > 0.0 ? rng / bins : 1.0
    float[] cnt = array.new_float(bins, 0.0)
    for i = 0 to len - 1
        int b = rng > 0.0 ? math.floor((src[i] - minV) / bw) : 0
        b := math.max(0, math.min(bins - 1, b))
        array.set(cnt, b, array.get(cnt, b) + 1.0)
    float H = 0.0
    for i = 0 to bins - 1
        float p = array.get(cnt, i)
        if p > 0.0
            p := p / float(len)
            H -= p * (math.log(p) / math.log(2.0))
    H

float rawEntropy   = calcEntropy(logRets, i_entLen, i_entBins)
float smoothEntropy= ta.ema(rawEntropy, i_entSmooth)

// Noise in "optimal band" for stochastic resonance
bool  optimalNoise = smoothEntropy >= i_optNoiseLo and smoothEntropy <= i_optNoiseHi

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — SUB-THRESHOLD SIGNAL (momentum differential)
// ═══════════════════════════════════════════════════════════════════════════════
float fastRSI = ta.rsi(close, i_fastRSI)
float slowRSI = ta.rsi(close, i_slowRSI)

// Signal: difference between fast and slow RSI, centered at 0
// Raw range approximately -50 to +50, normalize to -1 to +1
float rawSignal = (fastRSI - slowRSI) / 50.0
rawSignal := math.max(-1.0, math.min(1.0, rawSignal))
float smoothSignal = ta.ema(rawSignal, i_rsiSmooth)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — STOCHASTIC RESONANCE SCORE
// SR Score = |signal| / (1 + noise_penalty)
// When noise is in optimal band, penalty is minimized → signal is amplified
// When noise is too low (boring market) or too high (chaotic), score drops
// ═══════════════════════════════════════════════════════════════════════════════
// Noise penalty: distance from optimal band center
float optCenter  = (i_optNoiseLo + i_optNoiseHi) / 2.0
float optHalfW   = (i_optNoiseHi - i_optNoiseLo) / 2.0 + 0.0001
float noiseDist  = math.abs(smoothEntropy - optCenter)
float noisePenalty = noiseDist / optHalfW   // 0 at center, >1 outside band

// SR Score: signal strength amplified by optimal noise
float srScore = math.abs(smoothSignal) / (1.0 + noisePenalty)
srScore := math.max(0.0, math.min(1.0, srScore))

// Directional SR score
float srScoreDir = smoothSignal >= 0.0 ? srScore : -srScore

// Smoothed SR for display
float srSmooth = ta.ema(srScore, 3)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — SIGNAL DETECTION (non-repainting)
// ═══════════════════════════════════════════════════════════════════════════════
var int lastSigBar = -999

bool cooldownOK = (bar_index - lastSigBar) >= i_cooldown

bool srBullSignal = barstate.isconfirmed and
     srScore >= i_srThr and smoothSignal > 0.0 and
     optimalNoise and cooldownOK and
     srScore > srScore[1]    // SR score must be rising (peak detection)

bool srBearSignal = barstate.isconfirmed and
     srScore >= i_srThr and smoothSignal < 0.0 and
     optimalNoise and cooldownOK and
     srScore > srScore[1]

if srBullSignal or srBearSignal
    lastSigBar := bar_index

// SR Divergence: SR score diverges from price momentum
bool srBullDiv = barstate.isconfirmed and
     ta.crossover(srSmooth, i_srThr) and smoothSignal > 0.0 and
     close < ta.highest(close, 10)[1]

bool srBearDiv = barstate.isconfirmed and
     ta.crossover(srSmooth, i_srThr) and smoothSignal < 0.0 and
     close > ta.lowest(close, 10)[1]

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — VISUAL RENDERING
// ═══════════════════════════════════════════════════════════════════════════════
// Reference lines
hline(i_srThr, "Signal Threshold", color=color.new(RESON_MAGENTA, 60), linestyle=hline.style_dashed, linewidth=1)
hline(0.0,     "Zero",             color=color.new(LAVEN_HDR, 70),     linestyle=hline.style_solid,  linewidth=1)

// Shannon entropy (normalized for display alongside SR)
float entNorm = math.max(0.0, math.min(1.0, (smoothEntropy - 1.0) / 3.0))
plot(entNorm, "Noise (Entropy)", color=color.new(NOISE_AMBER, 40), linewidth=1, style=plot.style_line)

// Sub-threshold signal
plot(math.abs(smoothSignal) * 0.5, "Signal Strength", color=color.new(SIGNAL_CYAN, 50), linewidth=1, style=plot.style_line)

// SR Score histogram
color srHistColor = smoothSignal >= 0.0 ?
     lerpCol(LAVEN_HDR, BULL_MINT, math.min(1.0, srScore / i_srThr)) :
     lerpCol(LAVEN_HDR, BEAR_PINK, math.min(1.0, srScore / i_srThr))

plot(srScore, "SR Score", color=srHistColor, style=plot.style_histogram, linewidth=3)
plot(srSmooth,"SR Smooth", color=RESON_MAGENTA, linewidth=2, style=plot.style_line)

// Optimal noise band background
bgcolor(optimalNoise ? color.new(RESON_MAGENTA, 96) : na, title="Optimal Noise Band")

// Signal markers
plotshape(srBullSignal, "SR Bull Signal", shape.triangleup, location.bottom,
     color=BULL_MINT, size=size.normal, text="SR", textcolor=BULL_MINT)
plotshape(srBearSignal, "SR Bear Signal", shape.triangledown, location.top,
     color=BEAR_PINK, size=size.normal, text="SR", textcolor=BEAR_PINK)

plotshape(srBullDiv, "SR Bull Div", shape.labelup, location.bottom,
     color=color.new(BULL_MINT, 30), textcolor=color.white, text="SR DIV", size=size.small)
plotshape(srBearDiv, "SR Bear Div", shape.labeldown, location.top,
     color=color.new(BEAR_PINK, 30), textcolor=color.white, text="SR DIV", size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if i_showDash
    string noiseState = smoothEntropy < i_optNoiseLo ? "TOO LOW (boring)" : smoothEntropy > i_optNoiseHi ? "TOO HIGH (chaotic)" : "OPTIMAL (resonant)"
    color  noiseCol   = optimalNoise ? RESON_MAGENTA : NOISE_AMBER
    string srDirStr   = srScoreDir > 0.0 ? "BULLISH" : srScoreDir < 0.0 ? "BEARISH" : "NEUTRAL"
    color  srDirCol   = srScoreDir > 0.0 ? BULL_MINT : srScoreDir < 0.0 ? BEAR_PINK : LAVEN_HDR
    string sigState   = srBullSignal ? "BUY" : srBearSignal ? "SELL" : srScore > i_srThr ? "WATCH" : "WAIT"
    color  sigCol     = srBullSignal ? BULL_MINT : srBearSignal ? BEAR_PINK : srScore > i_srThr ? GOLD_VAL : LAVEN_HDR

    table.cell(dash, 0, 0, "Stochastic Resonance", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "SR Score",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, str.tostring(srScore, "#.###"), text_color=RESON_MAGENTA, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 2, "Direction",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 2, srDirStr,      text_color=srDirCol,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 3, "Signal Str",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, str.tostring(math.abs(smoothSignal), "#.###"), text_color=SIGNAL_CYAN, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 4, "Entropy",     text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, str.tostring(smoothEntropy, "#.###") + "  " + noiseState,
         text_color=noiseCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 5, "Optimal Band",text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, str.tostring(i_optNoiseLo, "#.#") + " — " + str.tostring(i_optNoiseHi, "#.#"),
         text_color=RESON_MAGENTA, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 6, "Fast RSI",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, str.tostring(fastRSI, "#.#"), text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

    table.cell(dash, 0, 7, "Signal",      text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 7, sigState,      text_color=sigCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(srBullSignal, "SRS Bull Signal",
     "Stochastic Resonance Signal [JOAT]: BULLISH resonance peak on {{ticker}} {{interval}}")
alertcondition(srBearSignal, "SRS Bear Signal",
     "Stochastic Resonance Signal [JOAT]: BEARISH resonance peak on {{ticker}} {{interval}}")
alertcondition(optimalNoise and not optimalNoise[1], "SRS Optimal Noise Entry",
     "Stochastic Resonance Signal [JOAT]: Entering OPTIMAL noise band — watch for signals on {{ticker}}")
alertcondition(srBullDiv, "SRS Bull Divergence",
     "Stochastic Resonance Signal [JOAT]: Bullish SR divergence on {{ticker}}")
alertcondition(srBearDiv, "SRS Bear Divergence",
     "Stochastic Resonance Signal [JOAT]: Bearish SR divergence on {{ticker}}")
````
