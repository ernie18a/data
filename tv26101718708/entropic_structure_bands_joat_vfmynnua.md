# Entropic Structure Bands [JOAT]

- url: https://www.tradingview.com/script/VfMYNNua-Entropic-Structure-Bands-JOAT/
- type: indicator
- pine_id: PUB;fa1139344c164b3497bc7f6aae7174e8
- version: 1.0

## Description

[b]Entropic Structure Bands [JOAT][/b]

[b]Introduction[/b]

Entropic Structure Bands is an open-source overlay indicator that dynamically selects the best-fitting Ordinary Least Squares regression window from recent structural pivots and surrounds that regression channel with entropy-adjusted deviation bands. The key innovation over standard regression channel indicators is twofold: the window length is selected optimally each bar by searching through available pivot anchors for the highest R² × log(N) quality score, and the band width is modulated by the current Shannon entropy of log returns — widening during chaotic periods and tightening during orderly ones.

[b]Core Concepts[/b]

[b]1. Optimal Regression Window Search[/b]

Rather than using a fixed lookback, the indicator records the bar index of every confirmed pivot high and low. Each bar, it tests several candidate windows anchored at recent pivots and selects the one that maximizes a performance score: R² multiplied by the natural log of the window length. This rewards both fit quality and window depth simultaneously:

[pine]
float score = r2 * math.log(float(N))
// highest score wins; window updates every bar
if trial.perfScore > bestScore
    bestScore := trial.perfScore
    bestMdl   := trial
[/pine]

The regression channel therefore adapts to where significant price structure has occurred, not to an arbitrary fixed period.

[b]2. Shannon Entropy Modulation[/b]

Shannon entropy of the log return distribution is computed using a histogram-binning approach. Low entropy means returns are concentrated — price is moving in an organized, directional way. High entropy means returns are evenly distributed — chaotic, noisy conditions. Band width scales with entropy:

[pine]
float entAdjDev = bestMdl.stdErr * (1.0 + entNorm * 0.8)
[/pine]

When entropy is low (below the configurable threshold), the market is classified as orderly and signals are enabled. This prevents signals from firing into chaotic conditions where regression bands have less predictive value.

[image]https://www.tradingview.com/x/Xwzudu0C/[/image]

[b]3. Trend-Confluence Signal Logic[/b]

Signals require simultaneous alignment of six conditions: regression slope direction, price position relative to midline, recent pullback to the inner band, momentum confirmation, optional HTF slope alignment, optional ADX trending gate, and optional RSI gate. Each condition is individually toggleable. This multi-factor gate replaces simple band-crossover logic with a structured confluence requirement.

[b]4. Forward Projection[/b]

The regression channel extends forward by a configurable number of bars beyond the right edge of the chart. A projection target label marks the estimated price at the end of the projection window based on the current slope and intercept. This gives visual context for where the regression model expects price to be if the current trend continues.

[b]5. Z-Score Candle Coloring[/b]

Each candle's position within the channel is expressed as a Z-score (standard deviations from the regression midline). Candles far above the midline (overbought extension) are tinted bear-color; candles far below (oversold extension) are tinted bull-color. This provides immediate visual context for where price stands within its current regression structure.

[b]Features[/b]

[list]
[*][b]Dynamic regression window:[/b] Optimal window selected each bar from pivot anchor scan
[*][b]R² quality gate:[/b] Configurable minimum R² prevents low-fit windows from being used
[*][b]Entropy-adjusted bands:[/b] Band width scales with Shannon entropy of log returns
[*][b]Multi-factor signal gate:[/b] Six independently configurable confluence conditions
[*][b]Forward projection:[/b] Channel extended beyond right edge with target label
[*][b]Z-score candle coloring:[/b] Candles painted by standard deviation position in channel
[*][b]Inner and outer bands (±1σ, ±2σ):[/b] Gradient-filled channel layers
[*][b]Glow-effect midline:[/b] Double-drawn center line with transparency for depth
[*][b]10-row dashboard:[/b] R², entropy, Z-score, duration, HTF alignment, ADX, RSI, signal state
[*][b]JSON webhook alerts:[/b] Alert messages formatted as JSON with EP, TP, SL, and R²
[/list]

[b]Input Parameters[/b]

[b]Regression Engine:[/b]
[list]
[*]Pivot Scan Horizon: Number of pivots to evaluate as regression anchors (default: 20)
[*]Pivot Sensitivity: Left/right bars for pivot confirmation (default: 5)
[*]Min R² Quality Gate: Minimum fit quality to use a window (default: 0.50)
[*]Band Multiplier 1/2: Inner and outer band standard deviation multiples (default: 1.0, 2.0)
[/list]

[b]Entropy System:[/b]
[list]
[*]Entropy Lookback: Bars for entropy calculation (default: 20)
[*]Entropy Bins: Histogram bins for return distribution (default: 10)
[*]Low Entropy Threshold: Threshold below which market is classified as orderly (default: 2.5)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Slope Bias[/b]
Check the dashboard's Slope Bias row. BULLISH or BEARISH indicates the current regression direction. This is the primary directional input.

[b]Step 2: Check Entropy State[/b]
LOW (orderly) entropy is the condition under which signals are most reliable. HIGH entropy warns that the regression model is operating in a chaotic environment.

[b]Step 3: Wait for Signal Labels[/b]
LONG and SHORT labels appear only when the full confluence gate is satisfied. Each label shows entry price, TP1, TP2, stop loss, and R² quality.

[b]Indicator Limitations[/b]

[list]
[*]Regression channels repaint historically when the optimal window shifts to a new anchor; use the confirmed-bar signals for non-repainting entry logic
[*]In markets with very few pivots, the scan horizon may find suboptimal windows with low R²
[*]Shannon entropy requires sufficient lookback to produce stable estimates
[/list]

[b]Originality Statement[/b]

The dynamic pivot-anchored regression window search using R² × log(N) scoring, combined with Shannon entropy-modulated band width and a six-condition confluence signal gate, is the original analytical architecture of this publication. No existing published Pine Script regression channel indicator implements adaptive window selection from pivot anchors with entropy modulation in this manner.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Regression channels are mathematical models of past price behavior and do not predict future price. Trading involves substantial risk of loss.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Entropic Structure Bands [JOAT]", shorttitle="ESB [JOAT]", overlay=true,
     max_lines_count=500, max_labels_count=500, max_bars_back=2000)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — COLOR SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════
color NEON_CYAN  = color.rgb(0,   243, 255)
color CORAL      = color.rgb(255, 100,  80)
color MINT_GRN   = color.rgb(0,   200,  83)
color AMBER_ENT  = color.rgb(255, 150,  30)
color VOID_BG    = color.rgb(10,   14,  26)
color SLATE_BRD  = color.rgb(40,   55,  90)
color LAVEN_HDR  = color.rgb(140, 160, 210)
color GOLD_VAL   = color.rgb(255, 215,  60)
color MAGENTA    = color.rgb(255,   0, 255)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string G_CORE = "━━ Regression Engine ━━"
string G_ENT  = "━━ Entropy System ━━"
string G_FILT = "━━ Trend Confluence Filters ━━"
string G_SIG  = "━━ Signal Settings ━━"
string G_VIZ  = "━━ Visual Settings ━━"
string G_DASH = "━━ Dashboard ━━"

int    i_scanHorizon = input.int(20,   "Pivot Scan Horizon",         minval=5, maxval=50, group=G_CORE,
     tooltip="Number of historical structure pivots to scan for optimal regression window.")
float  i_devMult1   = input.float(1.0, "Band Multiplier 1 (inner)",  minval=0.1, step=0.1, group=G_CORE)
float  i_devMult2   = input.float(2.0, "Band Multiplier 2 (outer)",  minval=0.2, step=0.1, group=G_CORE)
int    i_structLen  = input.int(5,     "Pivot Sensitivity",          minval=2, maxval=20,  group=G_CORE)
float  i_minR2      = input.float(0.50,"Min R² Quality Gate",        minval=0.0, maxval=1.0, step=0.05, group=G_CORE,
     tooltip="Regression window must achieve at least this R² to be used. 0 = accept any.")
int    i_entLen     = input.int(20,    "Entropy Lookback (bars)",    minval=5, maxval=100,  group=G_ENT)
int    i_entBins    = input.int(10,    "Entropy Histogram Bins",     minval=5, maxval=30,   group=G_ENT)
float  i_entThr     = input.float(2.5, "Low Entropy Threshold",      minval=0.5, maxval=4.5, step=0.1, group=G_ENT,
     tooltip="Signals only fire when entropy drops below this value (low = orderly market).")
int    i_entSmooth  = input.int(3,     "Entropy EMA Smoothing",      minval=1, maxval=10,   group=G_ENT)

bool   i_useHTF     = input.bool(true,  "HTF Slope Alignment",       group=G_FILT,
     tooltip="Long only when HTF regression slope is also positive. Short only when negative.")
string i_htfTf      = input.timeframe("D", "HTF Timeframe",          group=G_FILT)
bool   i_useADX     = input.bool(true,  "ADX Trending Filter",       group=G_FILT)
int    i_adxLen     = input.int(14,    "ADX Length",                  minval=1, group=G_FILT)
int    i_adxMin     = input.int(20,    "ADX Min Threshold",           minval=5, group=G_FILT)
bool   i_useRSI     = input.bool(true,  "RSI Gate",                  group=G_FILT)
int    i_rsiLen     = input.int(14,    "RSI Length",                  minval=2, group=G_FILT)
float  i_rsiObOS    = input.float(70.0,"RSI OB/OS Level",            minval=55.0, step=5.0, group=G_FILT,
     tooltip="Avoid longs when RSI is above this (overbought), avoid shorts when below complement.")

bool   i_reqLowEnt  = input.bool(true, "Require Low Entropy for Signals", group=G_SIG)
bool   i_reqPullback= input.bool(true, "Require Band Pullback",       group=G_SIG,
     tooltip="Signal only fires after price pulled back into or near the inner band, then resumed trend direction.")
bool   i_showSig    = input.bool(true, "Show Entry Labels",           group=G_SIG)
int    i_fwdBars    = input.int(30,   "Forward Projection (bars)",    minval=5, maxval=100, group=G_VIZ)
bool   i_showBand2  = input.bool(true, "Show Outer Bands (±2σ)",      group=G_VIZ)
bool   i_showPlots  = input.bool(true, "Show Band Plots (per-bar)",   group=G_VIZ,
     tooltip="Draws continuous band plots bar-by-bar. Disable if only want the channel lines.")
bool   i_candleColor= input.bool(true, "Z-Score Candle Coloring",     group=G_VIZ,
     tooltip="Paints candles by their Z-score position within the channel.")
color  i_bullCol    = input.color(NEON_CYAN,"Bullish Band Color",     group=G_VIZ)
color  i_bearCol    = input.color(CORAL,    "Bearish Band Color",     group=G_VIZ)
bool   i_showDash   = input.bool(true, "Show Dashboard",              group=G_DASH)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — USER-DEFINED TYPES
// ═══════════════════════════════════════════════════════════════════════════════
type RegrModel
    float slope
    float intercept
    float r2
    float stdErr
    float zScore
    int   originBar
    int   duration
    float perfScore
    bool  valid

type ChannelSet
    line  midLine
    line  u1Line
    line  l1Line
    line  u2Line
    line  l2Line
    linefill fill1u
    linefill fill1l
    linefill fill2u
    linefill fill2l

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════
computeOLS(int startBar, int endBar) =>
    int N = endBar - startBar
    RegrModel mdl = RegrModel.new(0.0, 0.0, 0.0, 0.0, 0.0, startBar, N, 0.0, false)
    if N >= 5
        float sX  = 0.0
        float sY  = 0.0
        float sXY = 0.0
        float sXX = 0.0
        float sYY = 0.0
        for i = 0 to N - 1
            float p = close[i]
            float x = float(N - 1 - i)
            sX  += x
            sY  += p
            sXY += x * p
            sXX += x * x
            sYY += p * p
        float detX = N * sXX - sX * sX
        float detY = N * sYY - sY * sY
        if detX > 0.0 and detY > 0.0
            float beta  = (N * sXY - sX * sY) / detX
            float alpha = (sY - beta * sX) / float(N)
            float num   = N * sXY - sX * sY
            float den   = math.sqrt(detX * detY)
            float r     = den != 0.0 ? num / den : 0.0
            float r2    = r * r
            float sse   = 0.0
            for i = 0 to N - 1
                float p    = close[i]
                float x    = float(N - 1 - i)
                float pred = beta * x + alpha
                float err  = p - pred
                sse += err * err
            float stdE  = math.sqrt(sse / math.max(1, N - 2))
            float curEst = beta * float(N - 1) + alpha
            float z      = stdE != 0.0 ? (close - curEst) / stdE : 0.0
            float score  = r2 * math.log(float(N))
            mdl := RegrModel.new(beta, alpha, r2, stdE, z, startBar, N, score, true)
    mdl

calcShannonEntropy(float src, int length, int bins) =>
    float minV = ta.lowest(src,  length)
    float maxV = ta.highest(src, length)
    float rng  = maxV - minV
    float bw   = rng > 0.0 ? rng / bins : 1.0
    float[] cnt = array.new_float(bins, 0.0)
    for i = 0 to length - 1
        int b = rng > 0.0 ? math.floor((src[i] - minV) / bw) : 0
        b := math.max(0, math.min(bins - 1, b))
        array.set(cnt, b, array.get(cnt, b) + 1.0)
    float H = 0.0
    for i = 0 to bins - 1
        float p = array.get(cnt, i)
        if p > 0.0
            p := p / float(length)
            H -= p * (math.log(p) / math.log(2.0))
    H

lerpCol(color cA, color cB, float t) =>
    float ct = math.max(0.0, math.min(1.0, t))
    int r = int(color.r(cA) + (color.r(cB) - color.r(cA)) * ct)
    int g = int(color.g(cA) + (color.g(cB) - color.g(cA)) * ct)
    int b = int(color.b(cA) + (color.b(cB) - color.b(cA)) * ct)
    color.rgb(r, g, b)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — ENTROPY CALCULATION
// ═══════════════════════════════════════════════════════════════════════════════
float logRets    = math.log(close / nz(close[1], close))
float rawEntropy = calcShannonEntropy(logRets, i_entLen, i_entBins)
float smoothEnt  = ta.ema(rawEntropy, i_entSmooth)
bool  isLowEnt   = smoothEnt < i_entThr
float entNorm    = math.max(0.0, math.min(1.0, (smoothEnt - 1.0) / 3.0))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — STRUCTURE PIVOT REGISTRY
// ═══════════════════════════════════════════════════════════════════════════════
var int[] pivotBars = array.new_int()

float ph = ta.pivothigh(i_structLen, i_structLen)
float pl = ta.pivotlow (i_structLen, i_structLen)
if not na(ph)
    array.push(pivotBars, bar_index[i_structLen])
if not na(pl)
    array.push(pivotBars, bar_index[i_structLen])
if pivotBars.size() > 2000
    array.shift(pivotBars)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — OPTIMAL REGRESSION SEARCH
// ═══════════════════════════════════════════════════════════════════════════════
RegrModel bestMdl = RegrModel.new(0.0, 0.0, 0.0, 0.0, 0.0, bar_index, 1, 0.0, false)
float     bestScore = -1.0

int nPivots = pivotBars.size()
int scanD   = math.min(nPivots, i_scanHorizon)

if scanD > 0
    for k = 1 to scanD
        int pIdx    = nPivots - k
        if pIdx >= 0
            int anchor = array.get(pivotBars, pIdx)
            RegrModel trial = computeOLS(anchor, bar_index)
            if trial.valid and trial.r2 >= i_minR2
                if trial.perfScore > bestScore
                    bestScore := trial.perfScore
                    bestMdl   := trial

// Extract slope to persistent var — UDT fields cannot use [1] directly
var float currentSlope = 0.0
if bestMdl.valid
    currentSlope := bestMdl.slope

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7B — CONFLUENCE FILTERS
// ═══════════════════════════════════════════════════════════════════════════════
// HTF slope: is the regression on the higher timeframe also bullish/bearish?
float htfSlope = request.security(syminfo.tickerid, i_htfTf, currentSlope[1], lookahead=barmerge.lookahead_on)
bool  htfBull  = not i_useHTF or (not na(htfSlope) and htfSlope > 0.0)
bool  htfBear  = not i_useHTF or (not na(htfSlope) and htfSlope < 0.0)

// ADX: trending market only
[_diP, _diM, adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool adxOK = not i_useADX or adxVal > i_adxMin

// RSI gate: not in extreme zone against direction
float rsiVal   = ta.rsi(close, i_rsiLen)
bool  rsiLong  = not i_useRSI or (rsiVal > 40.0 and rsiVal < i_rsiObOS)
bool  rsiShort = not i_useRSI or (rsiVal < 60.0 and rsiVal > (100.0 - i_rsiObOS))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — LIVE SIGNAL LOGIC (confirmed bars only, trend-confluence based)
// ═══════════════════════════════════════════════════════════════════════════════
float curEst    = na
float upperB1   = na
float lowerB1   = na
float upperB2   = na
float lowerB2   = na
float entAdjDev = na

if bestMdl.valid
    curEst    := bestMdl.slope * float(bestMdl.duration - 1) + bestMdl.intercept
    entAdjDev := bestMdl.stdErr * (1.0 + entNorm * 0.8)
    upperB1   := curEst + entAdjDev * i_devMult1
    lowerB1   := curEst - entAdjDev * i_devMult1
    upperB2   := curEst + entAdjDev * i_devMult2
    lowerB2   := curEst - entAdjDev * i_devMult2

float atrVal = ta.atr(14)

// Trend-bias signal logic:
// Long:  regression slope positive + price above midline + pullback to lower band + bounce + entropy low + HTF + ADX + RSI
// Short: regression slope negative + price below midline + pullback to upper band + rejection + entropy low + HTF + ADX + RSI
bool slopeBull = bestMdl.valid and bestMdl.slope > 0.0
bool slopeBear = bestMdl.valid and bestMdl.slope < 0.0
bool aboveMid  = bestMdl.valid and close > curEst
bool belowMid  = bestMdl.valid and close < curEst

// Pullback: price touched inner band in last 3 bars then closed back inside
bool pulledLow  = not na(lowerB1) and (low[1] <= lowerB1[1] or low[2] <= lowerB1[2] or low[3] <= lowerB1[3])
bool pulledHigh = not na(upperB1) and (high[1] >= upperB1[1] or high[2] >= upperB1[2] or high[3] >= upperB1[3])

// Momentum confirmation: close above prior bar's close (for longs) and vice versa
bool momBull = close > close[1] and close > close[2]
bool momBear = close < close[1] and close < close[2]

bool sigLong  = barstate.isconfirmed and slopeBull and aboveMid and momBull and htfBull and adxOK and rsiLong
bool sigShort = barstate.isconfirmed and slopeBear and belowMid and momBear and htfBear and adxOK and rsiShort

if i_reqLowEnt
    sigLong  := sigLong  and isLowEnt
    sigShort := sigShort and isLowEnt

if i_reqPullback
    sigLong  := sigLong  and pulledLow
    sigShort := sigShort and pulledHigh

// ── Signal labels with full trade plan ──────────────────────────────────────
if sigLong and i_showSig
    float sl_val  = lowerB1 - atrVal * 0.5
    float tp1_val = curEst
    float tp2_val = upperB1
    label.new(bar_index, low,
         "LONG\nEP: " + str.tostring(close, format.mintick) +
         "\nTP1: " + str.tostring(tp1_val, format.mintick) +
         "\nTP2: " + str.tostring(tp2_val, format.mintick) +
         "\nSL: "  + str.tostring(sl_val,  format.mintick) +
         "\nR²: "  + str.tostring(bestMdl.r2, "#.##"),
         style=label.style_label_up, color=i_bullCol, textcolor=color.white, size=size.small)
    alert('{"action":"long","symbol":"' + syminfo.tickerid + '","entry":"' +
         str.tostring(close, format.mintick) + '","tp1":"' + str.tostring(tp1_val, format.mintick) +
         '","tp2":"' + str.tostring(tp2_val, format.mintick) + '","sl":"' +
         str.tostring(sl_val, format.mintick) + '","r2":' + str.tostring(bestMdl.r2, "#.###") + '}',
         alert.freq_once_per_bar_close)

if sigShort and i_showSig
    float sl_val  = upperB1 + atrVal * 0.5
    float tp1_val = curEst
    float tp2_val = lowerB1
    label.new(bar_index, high,
         "SHORT\nEP: " + str.tostring(close, format.mintick) +
         "\nTP1: " + str.tostring(tp1_val, format.mintick) +
         "\nTP2: " + str.tostring(tp2_val, format.mintick) +
         "\nSL: "  + str.tostring(sl_val,  format.mintick) +
         "\nR²: "  + str.tostring(bestMdl.r2, "#.##"),
         style=label.style_label_down, color=i_bearCol, textcolor=color.white, size=size.small)
    alert('{"action":"short","symbol":"' + syminfo.tickerid + '","entry":"' +
         str.tostring(close, format.mintick) + '","tp1":"' + str.tostring(tp1_val, format.mintick) +
         '","tp2":"' + str.tostring(tp2_val, format.mintick) + '","sl":"' +
         str.tostring(sl_val, format.mintick) + '","r2":' + str.tostring(bestMdl.r2, "#.###") + '}',
         alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8B — PER-BAR BAND PLOTS + CANDLE COLORING
// ═══════════════════════════════════════════════════════════════════════════════
color themeColor = bestMdl.valid ? (bestMdl.slope >= 0.0 ? i_bullCol : i_bearCol) : LAVEN_HDR

// Per-bar plots of regression estimate and bands (continuous ribbon on chart)
pMid   = plot(i_showPlots ? curEst   : na, "Midline",       color=color.new(themeColor, 20), linewidth=2, style=plot.style_line)
pU1    = plot(i_showPlots ? upperB1  : na, "Upper Band 1",  color=color.new(themeColor, 50), linewidth=1, style=plot.style_line)
pL1    = plot(i_showPlots ? lowerB1  : na, "Lower Band 1",  color=color.new(themeColor, 50), linewidth=1, style=plot.style_line)
pU2    = plot(i_showPlots and i_showBand2 ? upperB2 : na, "Upper Band 2", color=color.new(themeColor, 75), linewidth=1, style=plot.style_line)
pL2    = plot(i_showPlots and i_showBand2 ? lowerB2 : na, "Lower Band 2", color=color.new(themeColor, 75), linewidth=1, style=plot.style_line)

// Gradient fills between band layers
fill(pU1, pMid, color=color.new(themeColor, 82), title="Inner Bull Fill")
fill(pMid, pL1, color=color.new(themeColor, 82), title="Inner Bear Fill")
fill(pU2, pU1,  color=color.new(themeColor, 91), title="Outer Bull Fill")
fill(pL1, pL2,  color=color.new(themeColor, 91), title="Outer Bear Fill")

// Buy/sell signal arrows
plotshape(sigLong,  "ESB Long",  shape.triangleup,   location.belowbar, color=i_bullCol, size=size.small)
plotshape(sigShort, "ESB Short", shape.triangledown,  location.abovebar, color=i_bearCol, size=size.small)

// Z-score candle coloring: paint candles based on their position within the channel
float zScore = bestMdl.valid and entAdjDev > 0.0 ? (close - curEst) / entAdjDev : 0.0
color candleCol = na
if i_candleColor and bestMdl.valid
    if zScore > 1.5
        candleCol := color.new(i_bearCol, 30)   // Price stretched above: bearish warning
    else if zScore < -1.5
        candleCol := color.new(i_bullCol, 30)   // Price stretched below: bullish opportunity
    else if zScore > 0.5
        candleCol := color.new(themeColor, 50)
    else if zScore < -0.5
        candleCol := color.new(themeColor, 50)
    else
        candleCol := color.new(themeColor, 30)
barcolor(i_candleColor ? candleCol : na, title="Z-Score Candle Color")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — CHANNEL RENDERING (barstate.islast) — lines + forward projection
// ═══════════════════════════════════════════════════════════════════════════════
var ChannelSet chanSet = ChannelSet.new(na, na, na, na, na, na, na, na, na)

deleteChannel(ChannelSet cs) =>
    if not na(cs.midLine)
        line.delete(cs.midLine)
    if not na(cs.u1Line)
        line.delete(cs.u1Line)
    if not na(cs.l1Line)
        line.delete(cs.l1Line)
    if not na(cs.u2Line)
        line.delete(cs.u2Line)
    if not na(cs.l2Line)
        line.delete(cs.l2Line)
    if not na(cs.fill1u)
        linefill.delete(cs.fill1u)
    if not na(cs.fill1l)
        linefill.delete(cs.fill1l)
    if not na(cs.fill2u)
        linefill.delete(cs.fill2u)
    if not na(cs.fill2l)
        linefill.delete(cs.fill2l)

if barstate.islast and bestMdl.valid
    deleteChannel(chanSet)

    int   t1    = bestMdl.originBar
    int   t2    = bar_index + i_fwdBars     // extend forward for projection
    int   dur   = bestMdl.duration
    float p1    = bestMdl.intercept
    float p2    = bestMdl.slope * float(dur + i_fwdBars) + bestMdl.intercept
    float dev   = entAdjDev

    color tCol   = bestMdl.slope >= 0.0 ? i_bullCol : i_bearCol
    color cSolid = color.new(tCol, 0)
    color cFill1 = color.new(tCol, 80)
    color cFill2 = color.new(tCol, 88)

    // Core midline (glow effect: draw twice — wide dim + narrow bright)
    line glowL = line.new(t1, p1, t2, p2, xloc.bar_index, color=color.new(tCol, 60), width=4)
    line midL  = line.new(t1, p1, t2, p2, xloc.bar_index, color=cSolid, width=2)
    line u1L   = line.new(t1, p1 + dev * i_devMult1, t2, p2 + dev * i_devMult1,
         xloc.bar_index, color=color.new(tCol, 30), width=1, style=line.style_dashed)
    line l1L   = line.new(t1, p1 - dev * i_devMult1, t2, p2 - dev * i_devMult1,
         xloc.bar_index, color=color.new(tCol, 30), width=1, style=line.style_dashed)

    linefill lf1u = linefill.new(u1L, midL, cFill1)
    linefill lf1l = linefill.new(midL, l1L, cFill1)

    line u2L  = na
    line l2L  = na
    linefill lf2u = na
    linefill lf2l = na

    if i_showBand2
        u2L  := line.new(t1, p1 + dev * i_devMult2, t2, p2 + dev * i_devMult2,
             xloc.bar_index, color=color.new(tCol, 55), width=1, style=line.style_dotted)
        l2L  := line.new(t1, p1 - dev * i_devMult2, t2, p2 - dev * i_devMult2,
             xloc.bar_index, color=color.new(tCol, 55), width=1, style=line.style_dotted)
        lf2u := linefill.new(u2L, u1L, cFill2)
        lf2l := linefill.new(l1L, l2L, cFill2)

    chanSet := ChannelSet.new(midL, u1L, l1L, u2L, l2L, lf1u, lf1l, lf2u, lf2l)

    // Forward projection target label
    float fwdTarget = p2
    label.new(t2, fwdTarget,
         "TARGET\n" + str.tostring(fwdTarget, format.mintick),
         xloc=xloc.bar_index, style=label.style_label_left,
         color=color.new(tCol, 70), textcolor=tCol, size=size.small)

    // Cleanup glow line tracking (not in ChannelSet, delete next render)
    line.delete(glowL)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — ENTROPY GRADIENT PLOT
// ═══════════════════════════════════════════════════════════════════════════════
// Entropy-colored background when in low-entropy zone
bgcolor(isLowEnt ? color.new(MINT_GRN, 94) : na, title="Low Entropy Zone")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 10,
     bgcolor=color.new(VOID_BG, 5), frame_color=SLATE_BRD, frame_width=1,
     border_color=SLATE_BRD, border_width=1)

if barstate.islast and i_showDash
    string trendStr  = bestMdl.valid ? (bestMdl.slope >= 0.0 ? "BULLISH" : "BEARISH") : "SCANNING"
    color  trendCol  = bestMdl.valid ? (bestMdl.slope >= 0.0 ? MINT_GRN : CORAL) : LAVEN_HDR
    string r2Str     = bestMdl.valid ? str.tostring(bestMdl.r2,     "#.###") : "—"
    string zStr      = bestMdl.valid ? str.tostring(bestMdl.zScore, "#.##")  : "—"
    string durStr    = bestMdl.valid ? str.tostring(bestMdl.duration)        : "—"
    string entState  = isLowEnt ? "LOW (orderly)" : "HIGH (chaotic)"
    color  entCol    = isLowEnt ? MINT_GRN : AMBER_ENT
    string htfStr    = not i_useHTF ? "OFF" : (bestMdl.slope >= 0.0 ? htfBull : htfBear) ? "ALIGNED" : "OPPOSED"
    color  htfCol    = not i_useHTF ? LAVEN_HDR : (bestMdl.slope >= 0.0 ? htfBull : htfBear) ? MINT_GRN : CORAL
    string adxStr    = not i_useADX ? "OFF" : adxOK ? str.tostring(adxVal, "#.#") + " PASS" : str.tostring(adxVal, "#.#") + " FAIL"
    color  adxCol    = not i_useADX ? LAVEN_HDR : adxOK ? MINT_GRN : CORAL
    bool   sigReady  = sigLong or sigShort
    string sigStr    = sigLong ? "LONG" : sigShort ? "SHORT" : "WAIT"
    color  sigCol    = sigLong ? MINT_GRN : sigShort ? CORAL : LAVEN_HDR

    table.cell(dash, 0, 0, "Entropic Structure Bands", text_color=LAVEN_HDR,
         text_size=size.small, bgcolor=color.new(VOID_BG, 5))
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 1, "Slope Bias",   text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 1, trendStr,       text_color=trendCol,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 2, "R² Quality",  text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 2, r2Str,          text_color=GOLD_VAL,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 3, "Entropy",      text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 3, str.tostring(smoothEnt, "#.###") + " " + entState, text_color=entCol, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 4, "Z-Score",      text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 4, zStr,           text_color=GOLD_VAL,  text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 5, "Duration",     text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 5, durStr + " bars", text_color=GOLD_VAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 6, "HTF Align",    text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 6, htfStr,         text_color=htfCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 7, "ADX",          text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 7, adxStr,         text_color=adxCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 8, "RSI",          text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    bool rsiGate = bestMdl.slope >= 0.0 ? rsiLong : rsiShort
    table.cell(dash, 1, 8, str.tostring(rsiVal, "#.#") + (rsiGate ? " PASS" : " FAIL"),
         text_color=rsiGate ? MINT_GRN : CORAL, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 0, 9, "Signal",       text_color=LAVEN_HDR, text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))
    table.cell(dash, 1, 9, sigStr,         text_color=sigCol,    text_size=size.tiny, bgcolor=color.new(VOID_BG, 10))

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
// Track slope direction via persistent var to avoid UDT history reference error
var float prevSlopeDir = 0.0
bool slopeTurnedBull = barstate.isconfirmed and bestMdl.valid and bestMdl.slope > 0.0 and prevSlopeDir <= 0.0
bool slopeTurnedBear = barstate.isconfirmed and bestMdl.valid and bestMdl.slope < 0.0 and prevSlopeDir >= 0.0
if bestMdl.valid
    prevSlopeDir := bestMdl.slope

alertcondition(sigLong,        "ESB Long Signal",      "Entropic Structure Bands [JOAT]: LONG confluence signal on {{ticker}} {{interval}}")
alertcondition(sigShort,       "ESB Short Signal",     "Entropic Structure Bands [JOAT]: SHORT confluence signal on {{ticker}} {{interval}}")
alertcondition(ta.crossunder(smoothEnt, i_entThr), "ESB Low Entropy Entry",
     "Entropic Structure Bands [JOAT]: Low entropy zone entered on {{ticker}}")
alertcondition(slopeTurnedBull,"ESB Turned Bullish",   "Entropic Structure Bands [JOAT]: Regression slope turned BULLISH on {{ticker}}")
alertcondition(slopeTurnedBear,"ESB Turned Bearish",   "Entropic Structure Bands [JOAT]: Regression slope turned BEARISH on {{ticker}}")
````
