# Deviation Lens [JOAT]

- url: https://www.tradingview.com/script/QK8f1R5o-Deviation-Lens-JOAT/
- type: indicator
- pine_id: PUB;a5a520a5a79c48ecab4dbcea9855b28e
- version: 1.0

## Description

[b]Deviation Lens [JOAT][/b]

[b]Introduction[/b]

Deviation Lens is an open-source multi-dimensional statistical displacement tool that applies Z-Score analysis simultaneously to three market dimensions: price level, close-to-close price change, and volume. Rather than using arbitrary overbought/oversold thresholds derived from historical maxima and minima, Deviation Lens computes exactly how many standard deviations each dimension is from its recent rolling mean. This provides a precise, adaptive, distribution-aware measure of how statistically extreme current market conditions are.

The core insight is that markets are mean-reverting systems over short time horizons. Statistical extremes — conditions where price, momentum, or volume are far from their recent averages — represent transient states. The further from the mean, the greater the statistical probability that conditions will normalize. Deviation Lens quantifies this probability directly, from 0% (at the mean) to 99.7% (at three standard deviations), and displays it as a live reversal probability for every bar.

[image]https://www.tradingview.com/x/rdRGR8jy/[/image]

[b]Core Concepts[/b]

[b]1. Three-Dimensional Z-Score Calculation[/b]

Three independent Z-Scores are computed on every bar:

The Price Z-Score measures how far the current close is from the rolling mean close in standard deviation units. This captures whether the current price level is statistically cheap or expensive relative to recent history.

The Change Z-Score measures how far the current bar's close-to-close price change is from the rolling mean change — quantifying momentum extremity rather than price level extremity.

The Volume Z-Score measures how far the current volume is from the rolling mean volume. High-volume Z-Score values identify bars where unusual institutional participation is statistically evident:

[pine]
priceZ  = priceStd  > 0 ? (close   - priceMean)  / priceStd  : 0.0
changeZ = changeStd > 0 ? (chg     - changeMean)  / changeStd : 0.0
volumeZ = volStd    > 0 ? (volume  - volMean)     / volStd    : 0.0
[/pine]

[b]2. Reversal Probability Mapping[/b]

The absolute Z-Score is mapped to a reversal probability percentage based on the properties of the normal distribution. A Z-Score of 1.0 corresponds to 68.3% of values lying within one standard deviation — meaning only 31.7% of readings exceed this level, implying a 68.3% probability of mean reversion. A Z-Score of 2.0 corresponds to 95.4%, and 3.0 to 99.7%:

[pine]
calcRevProb(float z) =>
    float absZ = math.abs(z)
    absZ >= 3.0 ? 99.7 : absZ >= 2.5 ? 98.8 : absZ >= 2.0 ? 95.4 : absZ >= 1.5 ? 86.6 : absZ >= 1.0 ? 68.3 : absZ >= 0.5 ? 38.3 : 0.0
[/pine]

This probability is displayed in the dashboard alongside the live Z-Score value, giving the trader both the raw statistical reading and its corresponding reversal likelihood.

[b]3. Composite Z-Score and Zone Classification[/b]

The three individual Z-Scores are combined into a composite score using configurable weights for each dimension. The composite is then classified into a zone: EXTREME (above the configurable extreme threshold), ELEVATED, NEUTRAL, or the opposing directional equivalents. Zone classification determines the dashboard color coding and alert triggers:

[pine]
composite = (priceZ * wPrice + changeZ * wChange + volumeZ * wVolume) / totalWeight
[/pine]

[b]4. Divergence and Hidden Divergence Detection[/b]

Deviation Lens monitors for two divergence conditions. Standard divergence occurs when the Z-Score direction disagrees with the price direction — price makes a higher high but the Z-Score makes a lower high (bearish divergence), or price makes a lower low but the Z-Score makes a higher low (bullish divergence). Hidden divergence occurs when the Z-Score makes an extreme move while price action is relatively contained — a potential continuation pattern. Divergence events are labeled directly on the chart with bold, clearly sized labels:

[pine]
bullDiv  = close > close[divLook] and priceZ < priceZ[divLook]  // Price up, Z down = bull div
bearDiv  = close < close[divLook] and priceZ > priceZ[divLook]  // Price down, Z up = bear div
[/pine]

Labels: BULL DIV, BEAR DIV (size.small), H.BULL, H.BEAR (size.tiny for hidden divergence).

[b]5. Multi-Dimensional Dashboard[/b]

The institutional dashboard presents all three Z-Scores, the composite Z-Score, current zone classification, reversal probability, and divergence status simultaneously. The layout is designed so the most actionable information — Zone and Rev. Probability — is displayed at the largest text size, with supporting metrics at smaller sizes.

[image]https://www.tradingview.com/x/im4UHfEi/[/image]

[b]Features[/b]

[list]
[*][b]Three independent Z-Scores:[/b] Price level, price change (momentum), and volume — each computed on its own rolling mean and standard deviation
[*][b]Configurable Z-Score weights:[/b] The composite score uses adjustable per-dimension weights allowing emphasis on price, momentum, or volume depending on trading context
[*][b]Live reversal probability:[/b] Probability percentage mapped directly from the Z-Score using normal distribution properties (68.3% at 1σ through 99.7% at 3σ)
[*][b]Zone classification:[/b] Composite Z-Score classified as Extreme, Elevated, or Neutral in both directions with color-coded dashboard display
[*][b]Divergence labels (BULL DIV / BEAR DIV):[/b] Z-Score vs price direction disagreement labeled on-chart at size.small
[*][b]Hidden divergence labels (H.BULL / H.BEAR):[/b] Z-Score extreme with contained price action labeled at size.tiny
[*][b]Configurable extreme and elevated thresholds:[/b] Both Z-Score thresholds independently adjustable
[*][b]Institutional dashboard (top right):[/b] 14-row table with Price Z, Change Z, Volume Z, Composite Z, Zone, Reversal Probability, and divergence status
[*][b]Adaptive thresholds:[/b] All calculations normalize to the rolling lookback period, adapting to current instrument and timeframe volatility
[*][b]Alerts:[/b] Separate alertconditions for extreme bull and extreme bear composite Z-Score readings
[/list]

[b]Input Parameters[/b]

[b]Z-Score Settings:[/b]
[list]
[*]Z-Score Length: Rolling window for all three Z-Score calculations (default: 20)
[*]Extreme Threshold: Z-Score magnitude classified as Extreme zone (default: 2.0)
[*]Elevated Threshold: Z-Score magnitude classified as Elevated zone (default: 1.0)
[/list]

[b]Dimension Weights:[/b]
[list]
[*]Price Weight: Relative weight of the price Z-Score in composite (default: 1.0)
[*]Change Weight: Relative weight of the momentum Z-Score in composite (default: 1.0)
[*]Volume Weight: Relative weight of the volume Z-Score in composite (default: 0.5)
[/list]

[b]Divergence:[/b]
[list]
[*]Divergence Lookback: Bars back for divergence comparison (default: 5)
[*]Show Divergence Labels toggle
[/list]

[b]Display:[/b]
[list]
[*]Show Dashboard toggle
[*]Bull and Bear color inputs
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Composite Zone[/b]
The Zone row in the dashboard shows the current composite Z-Score classification. EXTREME readings at the top of the scale indicate the highest statistical probability of mean reversion. NEUTRAL readings indicate current conditions are close to the mean and have low statistical directional edge from this tool alone.

[b]Step 2: Check Reversal Probability[/b]
The Rev. Probability row translates the Z-Score magnitude directly into a percentage. A reading above 95% means the current composite Z-Score is in the outer 5% of its historical distribution — a statistical extreme that has preceded mean reversion 95% of the time in the measured period.

[b]Step 3: Assess Each Dimension Independently[/b]
The three individual Z-Score rows reveal which dimension is driving the composite. A high composite driven entirely by volume Z-Score is a different setup than one driven by price Z-Score. Understanding which dimension is extreme helps filter entries: a price Z-Score extreme without supporting momentum or volume Z-Score extremes may be a lower-conviction reading.

[b]Step 4: React to Divergence Labels[/b]
BULL DIV and BEAR DIV labels appear when Z-Score momentum diverges from price direction. These signal that the statistical driver of a move is weakening even as price continues. H.BULL and H.BEAR hidden divergence labels flag potential continuation setups where Z-Score is extreme but price is not.

[b]Step 5: Combine with Structural Context[/b]
Deviation Lens produces the highest value when its extreme readings coincide with a structural confluence point — an order block, session low, or structure level. A 99.7% reversal probability at a tested support zone is a higher-conviction setup than the same reading in open air.

[b]Indicator Limitations[/b]

[list]
[*]All Z-Scores are computed relative to the rolling lookback window. The lookback defines what "normal" means. A very short lookback will produce extreme readings frequently; a very long lookback will rarely reach the extreme threshold. Calibration to the instrument and timeframe is required
[*]The reversal probability percentages are derived from the normal distribution assumption. Price change and volume distributions are not perfectly normal — they exhibit fat tails and skew. The probabilities are approximations, not precise statistical guarantees
[*]The composite Z-Score uses equal weights by default. Changing dimension weights significantly alters which market conditions produce extreme readings. Weight adjustments should be based on the specific instrument's characteristics
[*]Divergence detection uses a simple lookback comparison, not a peak-detection algorithm. In choppy markets, divergence labels may appear frequently without providing actionable signals
[/list]

[b]Originality Statement[/b]

Deviation Lens is original in its simultaneous, weighted multi-dimensional Z-Score framework that maps composite statistical extremity directly to a reversal probability percentage. This indicator is published because:

[list]
[*]Applying Z-Score analysis to three independent market dimensions simultaneously — price level, momentum (close-to-close change), and volume — rather than a single oscillator provides a richer statistical picture of current market extremity than any single-dimension Z-Score tool
[*]The direct mapping of Z-Score magnitude to reversal probability percentages using normal distribution properties gives traders an immediately interpretable statistic rather than a raw number requiring subjective interpretation
[*]The composite weighted Z-Score system, where each dimension's contribution to the overall reading is configurable, allows the indicator to be tuned toward price-mean-reversion strategies, momentum exhaustion strategies, or volume anomaly detection depending on the trader's methodology
[*]The combined detection of standard divergence and hidden divergence between the Z-Score and price direction provides trend continuation and reversal signals from the same framework
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Z-Score readings and reversal probability percentages are statistical tools based on historical distributions and do not guarantee any future price behavior. The normal distribution assumption applied to price and volume data is an approximation. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Deviation Lens [JOAT]", shorttitle="Dev Lens [JOAT]", overlay=false,
     precision=4, max_labels_count=300, max_lines_count=300)
// ─── Z-SCORE FUNCTION ──────────────────────────────────────────────────────────
// Welford-style sliding window: O(1) per bar using running sum and sum-of-squares.
standardize(series float src, simple int len) =>
    if len <= 1
        float(na)
    var S1 = 0.0
    var S2 = 0.0
    var N  = 0
    var float[] winVals = array.new_float(0)
    var bool[]  winIsNA = array.new_bool(0)
    float xNew     = src[0]
    bool  xNewIsNA = na(xNew)
    if array.size(winVals) == len
        float xOld     = array.get(winVals, 0)
        bool  xOldIsNA = array.get(winIsNA, 0)
        array.shift(winVals)
        array.shift(winIsNA)
        if not xOldIsNA
            S1 -= xOld
            S2 -= xOld * xOld
            N  -= 1
    array.push(winVals, xNewIsNA ? 0.0 : xNew)
    array.push(winIsNA, xNewIsNA)
    if not xNewIsNA
        S1 += xNew
        S2 += xNew * xNew
        N  += 1
    float z = na
    if N >= 2
        float meanVal   = S1 / N
        float varPop    = (S2 / N) - (meanVal * meanVal)
        varPop         := varPop < 1e-10 ? 0.0 : varPop
        float varSample = varPop * N / (N - 1)
        float stdevVal  = math.sqrt(varSample)
        if xNewIsNA
            z := na
        else if stdevVal > 1e-10
            z := (xNew - meanVal) / stdevVal
        else
            z := (math.abs(xNew - meanVal) < 1e-10) ? 0.0 : na
    z

// ─── INPUTS ────────────────────────────────────────────────────────────────────
grpCore = "Core Settings"
iSrc    = input.source(close, "Source",          group=grpCore)
iLen    = input.int(20,       "Lookback Period", minval=2, maxval=500, group=grpCore)

grpMom = "Momentum Prediction"
showDir   = input.bool(true, "Show Direction Line", group=grpMom)
projBars  = input.int(10,    "Projection Bars",     minval=1, maxval=50, group=grpMom)
momFactor = input.float(0.5, "Momentum Factor",     minval=0.1, maxval=2.0, step=0.1, group=grpMom)

grpVol = "Volume Contraction"
volMALen = input.int(20,    "Volume MA Length",       minval=2, maxval=100, group=grpVol)
volThres = input.float(0.7, "Contraction Threshold",  minval=0.1, maxval=1.0, step=0.05, group=grpVol)

grpDiv = "Divergence Detection"
showDiv     = input.bool(true, "Show Divergences",        group=grpDiv)
showHidDiv  = input.bool(true, "Show Hidden Divergences", group=grpDiv)
divPivLen   = input.int(5,     "Pivot Lookback",          minval=1, maxval=20, group=grpDiv)
divMaxRange = input.int(60,    "Max Range (bars)",        minval=10, maxval=200, group=grpDiv)
divMinRange = input.int(5,     "Min Range (bars)",        minval=1, maxval=50, group=grpDiv)

grpDisplay = "Display"
showDash = input.bool(true, "Show Dashboard", group=grpDisplay)

grpColors = "Colors"
colZline   = input.color(#B0BEC5,                "Z-Score Line",    group=grpColors)
colSD1     = input.color(color.new(#00897B, 50), "1 SD Band",       group=grpColors)
colSD2     = input.color(color.new(#E65100, 50), "2 SD Band",       group=grpColors)
colSD3     = input.color(color.new(#B71C1C, 50), "3 SD Band",       group=grpColors)
colFill1   = input.color(color.new(#00897B, 90), "1 SD Fill",       group=grpColors)
colFill2   = input.color(color.new(#E65100, 90), "2 SD Fill",       group=grpColors)
colFill3   = input.color(color.new(#B71C1C, 90), "3 SD Fill",       group=grpColors)
colBullDiv = input.color(color.new(#00897B, 0),  "Bullish Div",     group=grpColors)
colBearDiv = input.color(color.new(#E65100, 0),  "Bearish Div",     group=grpColors)
colHidBull = input.color(color.new(#00897B, 50), "Hidden Bull Div", group=grpColors)
colHidBear = input.color(color.new(#E65100, 50), "Hidden Bear Div", group=grpColors)

// ─── Z-SCORE CALCULATION ───────────────────────────────────────────────────────
zVal = standardize(iSrc, iLen)

// ─── SD BAND HLINES ────────────────────────────────────────────────────────────
hZero = hline(0,  "Mean",  color=color.new(#546E7A, 50), linestyle=hline.style_dotted)
hP1   = hline(1,  "+1 SD", color=colSD1, linestyle=hline.style_dotted)
hN1   = hline(-1, "-1 SD", color=colSD1, linestyle=hline.style_dotted)
hP2   = hline(2,  "+2 SD", color=colSD2, linestyle=hline.style_dotted)
hN2   = hline(-2, "-2 SD", color=colSD2, linestyle=hline.style_dotted)
hP3   = hline(3,  "+3 SD", color=colSD3, linestyle=hline.style_dotted)
hN3   = hline(-3, "-3 SD", color=colSD3, linestyle=hline.style_dotted)

fill(hP1, hN1, color=colFill1, title="1 SD Fill")
fill(hP2, hP1, color=colFill2, title="+1 to +2 SD")
fill(hN1, hN2, color=colFill2, title="-1 to -2 SD")
fill(hP3, hP2, color=colFill3, title="+2 to +3 SD")
fill(hN2, hN3, color=colFill3, title="-2 to -3 SD")

// ─── Z-SCORE PLOT ──────────────────────────────────────────────────────────────
zColor = zVal >= 3 ? #B71C1C : zVal >= 2 ? #E65100 : zVal >= 1 ? #00897B :
         zVal <= -3 ? #B71C1C : zVal <= -2 ? #E65100 : zVal <= -1 ? #00897B : #78909C
plot(zVal, "Z-Score", color=zColor, linewidth=2)

bgExtreme = math.abs(zVal) >= 3 ? color.new(#B71C1C, 88) : math.abs(zVal) >= 2 ? color.new(#E65100, 92) : na
bgcolor(bgExtreme, title="Extreme Background")

// ─── MOMENTUM & DIRECTION ──────────────────────────────────────────────────────
zMom  = zVal - nz(zVal[1])
zPred = math.max(-4, math.min(4, zVal + (zMom * momFactor * projBars)))

isBullish = zVal < 0 and zPred > zVal
isBearish = zVal > 0 and zPred < zVal

var line dirLine = na
if barstate.islast and showDir
    line.delete(dirLine)
    arrowCol = isBullish ? color.new(#00897B, 30) : isBearish ? color.new(#E65100, 30) : color.new(#546E7A, 30)
    dirLine := line.new(bar_index, zVal, bar_index + projBars, zPred,
         color=arrowCol, style=line.style_arrow_right, width=2)

// ─── VOLUME CONTRACTION ────────────────────────────────────────────────────────
volMA         = ta.sma(volume, volMALen)
volRatio      = volMA > 0 ? volume / volMA : 0.0
volContracted = volRatio < volThres

// ─── MEAN REVERSION PROBABILITY ────────────────────────────────────────────────
// Lookup table based on normal distribution area under curve.
calcRevProb(float z) =>
    float absZ = math.abs(z)
    absZ >= 3.0 ? 99.7 : absZ >= 2.5 ? 98.8 : absZ >= 2.0 ? 95.4 : absZ >= 1.5 ? 86.6 : absZ >= 1.0 ? 68.3 : absZ >= 0.5 ? 38.3 : 0.0

revProb = calcRevProb(zVal)

// ─── DIVERGENCE DETECTION ──────────────────────────────────────────────────────
zPivLo = ta.pivotlow(zVal,  divPivLen, divPivLen)
zPivHi = ta.pivothigh(zVal, divPivLen, divPivLen)

var float[] zLoVals = array.new_float(0)
var int[]   zLoBars = array.new_int(0)
var float[] pLoVals = array.new_float(0)
var float[] zHiVals = array.new_float(0)
var int[]   zHiBars = array.new_int(0)
var float[] pHiVals = array.new_float(0)

if not na(zPivLo)
    array.unshift(zLoVals, zVal[divPivLen])
    array.unshift(zLoBars, bar_index - divPivLen)
    array.unshift(pLoVals, iSrc[divPivLen])
    if array.size(zLoVals) > 10
        array.pop(zLoVals)
        array.pop(zLoBars)
        array.pop(pLoVals)

if not na(zPivHi)
    array.unshift(zHiVals, zVal[divPivLen])
    array.unshift(zHiBars, bar_index - divPivLen)
    array.unshift(pHiVals, iSrc[divPivLen])
    if array.size(zHiVals) > 10
        array.pop(zHiVals)
        array.pop(zHiBars)
        array.pop(pHiVals)

// ─── BULLISH DIVERGENCE CHECK ──────────────────────────────────────────────────
regBullDiv    = false
hiddenBullDiv = false
var int   bStartBar = na
var float bStartZ   = na
var int   bEndBar   = na
var float bEndZ     = na

if not na(zPivLo) and array.size(zLoVals) >= 2
    cZ  = array.get(zLoVals, 0)
    cBr = array.get(zLoBars, 0)
    cP  = array.get(pLoVals, 0)
    for i = 1 to math.min(array.size(zLoVals) - 1, 5)
        pZ  = array.get(zLoVals, i)
        pBr = array.get(zLoBars, i)
        pP  = array.get(pLoVals, i)
        bd  = cBr - pBr
        if bd >= divMinRange and bd <= divMaxRange
            if cP < pP and cZ > pZ
                regBullDiv := true
                bStartBar  := pBr
                bStartZ    := pZ
                bEndBar    := cBr
                bEndZ      := cZ
                break
            if cP > pP and cZ < pZ and showHidDiv
                hiddenBullDiv := true
                bStartBar     := pBr
                bStartZ       := pZ
                bEndBar       := cBr
                bEndZ         := cZ
                break

// ─── BEARISH DIVERGENCE CHECK ──────────────────────────────────────────────────
regBearDiv    = false
hiddenBearDiv = false
var int   sStartBar = na
var float sStartZ   = na
var int   sEndBar   = na
var float sEndZ     = na

if not na(zPivHi) and array.size(zHiVals) >= 2
    cZ  = array.get(zHiVals, 0)
    cBr = array.get(zHiBars, 0)
    cP  = array.get(pHiVals, 0)
    for i = 1 to math.min(array.size(zHiVals) - 1, 5)
        pZ  = array.get(zHiVals, i)
        pBr = array.get(zHiBars, i)
        pP  = array.get(pHiVals, i)
        bd  = cBr - pBr
        if bd >= divMinRange and bd <= divMaxRange
            if cP > pP and cZ < pZ
                regBearDiv := true
                sStartBar  := pBr
                sStartZ    := pZ
                sEndBar    := cBr
                sEndZ      := cZ
                break
            if cP < pP and cZ > pZ and showHidDiv
                hiddenBearDiv := true
                sStartBar     := pBr
                sStartZ       := pZ
                sEndBar       := cBr
                sEndZ         := cZ
                break

// ─── DIVERGENCE VISUALS ────────────────────────────────────────────────────────
// Regular divergences: solid line + labeled "BULL DIV" / "BEAR DIV"
// Hidden divergences:  dashed line + labeled "H.BULL"  / "H.BEAR"
if showDiv and regBullDiv
    line.new(bStartBar, bStartZ, bEndBar, bEndZ, color=colBullDiv, width=2)
    label.new(bEndBar, bEndZ, "BULL DIV",
         style=label.style_label_up, color=color.new(#00897B, 40),
         textcolor=color.white, size=size.small)

if showDiv and hiddenBullDiv
    line.new(bStartBar, bStartZ, bEndBar, bEndZ, color=colHidBull, width=1, style=line.style_dashed)
    label.new(bEndBar, bEndZ, "H.BULL",
         style=label.style_label_up, color=color.new(#00897B, 65),
         textcolor=color.white, size=size.tiny)

if showDiv and regBearDiv
    line.new(sStartBar, sStartZ, sEndBar, sEndZ, color=colBearDiv, width=2)
    label.new(sEndBar, sEndZ, "BEAR DIV",
         style=label.style_label_down, color=color.new(#E65100, 40),
         textcolor=color.white, size=size.small)

if showDiv and hiddenBearDiv
    line.new(sStartBar, sStartZ, sEndBar, sEndZ, color=colHidBear, width=1, style=line.style_dashed)
    label.new(sEndBar, sEndZ, "H.BEAR",
         style=label.style_label_down, color=color.new(#E65100, 65),
         textcolor=color.white, size=size.tiny)

// ─── DASHBOARD ─────────────────────────────────────────────────────────────────
var table stbl = table.new(position.top_right, 2, 14,
     bgcolor=color.new(#0D1117, 5),
     border_color=color.new(#1A2332, 0),
     border_width=1,
     frame_color=color.new(#546E7A, 50),
     frame_width=1)

getZoneColor(float z) =>
    math.abs(z) >= 3 ? color.new(#B71C1C, 0) : math.abs(z) >= 2 ? color.new(#E65100, 0) : math.abs(z) >= 1 ? color.new(#00897B, 0) : color.new(#546E7A, 0)

getProbColor(float p) =>
    p >= 95 ? color.new(#B71C1C, 0) : p >= 80 ? color.new(#E65100, 0) : p >= 60 ? color.new(#FFB300, 0) : color.new(#00897B, 0)

if barstate.islast and showDash
    color DARK_BG = color.new(#0D1117, 0)
    color SEP_BG  = color.new(#080D13, 0)
    color LBL_C   = color.new(#546E7A, 0)

    zStr    = str.tostring(zVal, "#.####")
    zDir    = zVal > 0 ? "+" : ""
    predStr = str.tostring(zPred, "#.####")
    predDir = zPred > zVal ? "+" : ""

    zoneStr = math.abs(zVal) >= 3 ? "EXTREME" : math.abs(zVal) >= 2 ? "ELEVATED" : math.abs(zVal) >= 1 ? "MODERATE" : "NORMAL"
    dirStr  = isBullish ? "MEAN REV UP" : isBearish ? "MEAN REV DN" : "FLAT"
    dirCol  = isBullish ? color.new(#00897B, 0) : isBearish ? color.new(#E65100, 0) : color.new(#546E7A, 0)

    divStr  = regBullDiv ? "BULL REG" : hiddenBullDiv ? "BULL HID" : regBearDiv ? "BEAR REG" : hiddenBearDiv ? "BEAR HID" : "None"
    divCol  = regBullDiv or hiddenBullDiv ? color.new(#00897B, 0) : regBearDiv or hiddenBearDiv ? color.new(#E65100, 0) : color.new(#546E7A, 0)

    volStr  = volContracted ? "CONTRACTED" : "NORMAL"
    volCol  = volContracted ? color.new(#FFB300, 0) : color.new(#546E7A, 0)

    isOptLong  = zVal <= -3.0 and volContracted
    isOptShort = zVal >=  3.0 and volContracted
    setupStr   = isOptLong ? "LONG SETUP" : isOptShort ? "SHORT SETUP" : "None"
    setupCol   = isOptLong ? color.new(#00897B, 0) : isOptShort ? color.new(#E65100, 0) : color.new(#546E7A, 0)

    // Row 0: Header
    table.cell(stbl, 0, 0, "DEVIATION LENS", text_color=color.new(#ECEFF1, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 0, "[JOAT]",         text_color=color.new(#546E7A, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 1: Separator
    table.cell(stbl, 0, 1, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(stbl, 1, 1, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 2: Z-Score (prominent)
    table.cell(stbl, 0, 2, "Z-Score",      text_color=LBL_C,              text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 2, zDir + zStr,    text_color=getZoneColor(zVal), text_size=size.normal,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 3: Zone
    table.cell(stbl, 0, 3, "Zone",         text_color=LBL_C,              text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 3, zoneStr,        text_color=getZoneColor(zVal), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 4: Separator
    table.cell(stbl, 0, 4, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(stbl, 1, 4, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 5: Predicted
    table.cell(stbl, 0, 5, "Predicted (" + str.tostring(projBars) + "b)",
         text_color=LBL_C, text_size=size.tiny, bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 5, predDir + predStr, text_color=getZoneColor(zPred), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 6: Direction
    table.cell(stbl, 0, 6, "Direction",    text_color=LBL_C,  text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 6, dirStr,         text_color=dirCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 7: Reversion Probability
    table.cell(stbl, 0, 7, "Rev Prob",     text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 7, str.tostring(revProb, "#.#") + "%",
         text_color=getProbColor(revProb), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 8: Separator
    table.cell(stbl, 0, 8, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(stbl, 1, 8, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 9: Divergence
    table.cell(stbl, 0, 9, "Divergence",   text_color=LBL_C,  text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 9, divStr,         text_color=divCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 10: Volume
    table.cell(stbl, 0, 10, "Volume",      text_color=LBL_C,  text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 10, volStr,        text_color=volCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 11: Separator
    table.cell(stbl, 0, 11, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(stbl, 1, 11, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 12: Setup Signal
    table.cell(stbl, 0, 12, "Setup",       text_color=LBL_C,    text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 12, setupStr,      text_color=setupCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 13: Lookback period
    table.cell(stbl, 0, 13, "Period",      text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(stbl, 1, 13, str.tostring(iLen) + " bars",
         text_color=color.new(#546E7A, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(zVal >= 3.0  and nz(zVal[1]) < 3.0,  "Z >= +3 SD",        "Deviation Lens: Z-Score crossed above +3 SD")
alertcondition(zVal <= -3.0 and nz(zVal[1]) > -3.0, "Z <= -3 SD",        "Deviation Lens: Z-Score crossed below -3 SD")
alertcondition(regBullDiv,    "Regular Bull Divergence",  "Deviation Lens: Regular bullish divergence detected")
alertcondition(regBearDiv,    "Regular Bear Divergence",  "Deviation Lens: Regular bearish divergence detected")
alertcondition(hiddenBullDiv, "Hidden Bull Divergence",   "Deviation Lens: Hidden bullish divergence detected")
alertcondition(hiddenBearDiv, "Hidden Bear Divergence",   "Deviation Lens: Hidden bearish divergence detected")
alertcondition(zVal <= -3.0 and volContracted, "Long Setup",  "Deviation Lens: Extreme low Z + volume contraction — long setup")
alertcondition(zVal >= 3.0  and volContracted, "Short Setup", "Deviation Lens: Extreme high Z + volume contraction — short setup")
````
