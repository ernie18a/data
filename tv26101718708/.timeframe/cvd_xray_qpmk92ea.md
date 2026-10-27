# CVD X-Ray

- url: https://www.tradingview.com/script/QPmK92ea-CVD-X-Ray/
- type: indicator
- pine_id: PUB;dc04707cf4594a66a0a8285b6b033de9
- version: 5.0

## Description

[url=https://www.tradingview.com/x/nkYF6zid/]https://www.tradingview.com/x/nkYF6zid/[/url]


[b]CVD X-Ray[/b]
See the Participation Behind the Move

Most indicators tell you what price is doing.

CVD X-Ray is designed to reveal who is participating behind the move.

Price can rally on weak participation.
Price can decline despite aggressive buying.
Price can appear strong while participation quietly deteriorates beneath the surface.

CVD X-Ray was built to expose these hidden shifts in market participation by combining cumulative volume delta pressure, momentum acceleration, participation normalization, and multi-timeframe alignment into a single visual framework.

Rather than focusing solely on market structure, CVD X-Ray focuses on participation pressure—the intensity and direction of buying and selling activity driving the current move.


[b]What Makes CVD X-Ray Different?[/b]

Traditional volume indicators often struggle with context.

A large reading may appear important on one chart while being completely normal on another.

CVD X-Ray solves this by normalizing participation pressure and classifying it into intuitive strength categories:

[list]
[*]Weak
[*]Building
[*]Moderate
[*]Strong
[*]Extreme
[/list]

This allows traders to quickly distinguish between routine activity and meaningful participation events.


[b]Pressure vs Trend[/b]

One of the most common mistakes traders make is confusing participation with trend.

A market can be trending lower while buyers suddenly begin participating aggressively.

Likewise, a market can be trending higher while participation quietly weakens beneath the surface.

CVD X-Ray intentionally measures participation pressure rather than market structure trend.

This distinction can help identify potential continuation opportunities, weakening moves, failed breakouts, and early signs of accumulation or distribution.


[b]Strength and Rarity[/b]

Each reading is evaluated based on both participation strength and historical context.

The optional percentile ranking (PCT) provides additional insight into how unusual the current participation reading is relative to recent market behavior.

For example:

[list]
[*]P80 = Stronger than 80% of recent readings
[*]P95 = Stronger than 95% of recent readings
[/list]

This helps traders quickly recognize when participation is becoming statistically significant.


[b]Designed for Clarity[/b]

CVD X-Ray was built around a simple goal:

Reduce information overload while increasing informational value.

The interface uses a consistent strength scale, visual participation hierarchy, and clean multi-timeframe dashboard to deliver actionable context without cluttering the chart.

Whether you're analyzing breakouts, pullbacks, reversals, or trend continuation setups, CVD X-Ray provides a structured view of the participation driving price.

Because understanding what price is doing is useful.

Understanding who is participating behind the move is often more valuable.


[b]Disclaimer[/b]

CVD X-Ray is an analytical tool designed to assist in evaluating market participation and participation pressure. It does not predict future price movements and should not be used as a standalone basis for trading decisions.

All trading involves risk, including the potential loss of capital. Past performance, historical participation readings, and indicator signals are not guarantees of future results.

This script is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice. Users are solely responsible for their own risk management and trading decisions.

## Source Code

````pine
//@version=6

indicator("CVD X-Ray", overlay=false, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// CVD X-RAY

//

// Pressure = Direction of participation

// Strength = Magnitude of participation

// PCT      = Historical rarity ranking

//

// This indicator measures participation

// pressure, not market structure trend.

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// UNIVERSAL UX PALETTE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

colorTheme = input.string(
     "Graphite",
     "Color Theme",
     options = ["Graphite", "Classic Navy"],
     group = "Appearance",
     tooltip = "Controls the histogram, guide lines, readout, and MTF table colors. Graphite uses the refined neutral-dark palette, while Classic Navy restores the original published appearance.")

isGraphite = colorTheme == "Graphite"

BULL_COLOR    = isGraphite ? #26C6B8 : #00c89b
BEAR_COLOR    = isGraphite ? #A83A68 : #f23645
NEUTRAL_COLOR = isGraphite ? #667582 : #636b79
CAUTION_COLOR = #ffbf00

HEADER_COLOR = isGraphite ? #B9B9BD : #38bdf8
PANEL_BG     = isGraphite ? #222225 : #131722
ROW_BG       = isGraphite ? #2D2D30 : #1e222d
HEADER_BG    = isGraphite ? #17181C : #2a2e39

BORDER_COLOR = isGraphite
     ? color.new(#38383C, 52)
     : color.new(#363a45, 50)

MUTED_TEXT = isGraphite ? #929296 : #b2b5be

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LOCKED ENGINE SETTINGS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cvdSmoothLen = 10

cvdNormLen   = 40

tsiShort = 13

tsiLong  = 25

tsiAccelSmooth = 3

accelBoost     = 6.0

baseWeight  = 0.75

boostWeight = 0.45

histSmoothLen = 4

histPower     = 1.35

histClamp     = 1.25

buildingLevel = 0.20

moderateLevel = 0.40

strongLevel   = 0.70

extremeLevel  = 1.00

useChopGate       = true

chopThreshold     = 0.07

chopCompression   = 0.60

useIgnitionAssist = true

ignitionThreshold = 0.10

ignitionBoost     = 0.18

useAdaptiveDecay  = true

decaySensitivity  = 0.16

decayFloor        = 0.78

useTrendSustain   = true

sustainThreshold  = 0.28

sustainBoost      = 1.08

useTailCleanup    = true

tailThreshold     = 0.10

tailDecay         = 0.72

useResetAssist    = true

resetThreshold    = 0.035

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// USER INPUTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullThreshold = input.float(0.20, "Bull Participation Threshold", step=0.05, tooltip="Histogram value required before buying pressure is classified as bullish. Higher values produce fewer but stronger bullish readings.")

bearThreshold = input.float(-0.20, "Bear Participation Threshold", step=0.05, tooltip="Histogram value required before selling pressure is classified as bearish. Lower values produce fewer but stronger bearish readings.")

deltaMethod = input.string(

     "Candle Anatomy",

     "Delta Estimation Method",

     options = ["Directional", "Candle Anatomy", "Hybrid"],

     tooltip = "Directional preserves the original CVD X-Ray volume estimate. Candle Anatomy weights estimated delta by candle-body strength. Hybrid blends 35% Directional with 65% Candle Anatomy. These are OHLCV estimates, not true bid/ask delta."

)

percentileLen = input.int(500, "PCT Lookback", minval=50, tooltip="Number of historical bars used for percentile ranking. Higher values create more stable rarity readings. Lower values react faster to recent market conditions.")

showZeroLine   = input.bool(true, "Show Zero Line", tooltip="Displays the zero line separating bullish and bearish pressure.")

showGuideLines = input.bool(true, "Show Threshold Guide Lines", tooltip="Displays bullish, bearish, and strong participation reference lines.")

showReadout    = input.bool(true, "Show Left Readout", tooltip="Displays the current chart timeframe, CVD value, pressure, strength, and optional PCT reading.")

showPctReadout = input.bool(true, "Show PCT in Readout", tooltip="Displays percentile rank in the left readout. Example: P80 means the current reading is stronger than 80% of recent readings.")

showMTF        = input.bool(true, "Show MTF Table", tooltip="Displays multi-timeframe CVD X-Ray participation alignment.")

showBuyerPct   = input.bool(true, "Show MTF Buyer/Seller %", tooltip="Displays the average buyer or seller percentage across the three selected MTF timeframes using the same close-position method as the CVD MTF Dashboard.")

tf1 = input.timeframe("240", "MTF 1", tooltip="Highest timeframe used in the participation table. Common choices: 4H or 1D.")

tf2 = input.timeframe("60", "MTF 2", tooltip="Intermediate timeframe used in the participation table. Common choices: 1H or 4H.")

tf3 = input.timeframe("15", "MTF 3", tooltip="Fastest timeframe used in the participation table. Common choices: 15M or 1H.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// CVD ENGINE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

_rate(tw, bw, body, cond) =>

    candleRange = tw + bw + body

    ret = candleRange > 0 ? 0.5 * (tw + bw + (cond ? 2.0 * body : 0.0)) / candleRange : 0.5

    nz(ret) == 0 ? 0.5 : ret

cvdXRay() =>

    // Original CVD X-Ray directional estimate

    buyVolDirectional = close > open ? volume : close > close[1] ? volume : volume * 0.5

    sellVolDirectional = close < open ? volume : close < close[1] ? volume : volume * 0.5

    deltaDirectional = buyVolDirectional - sellVolDirectional

    // Candle-anatomy estimate adapted from the LonesomeTheBlue-style method

    tw = high - math.max(open, close)

    bw = math.min(open, close) - low

    body = math.abs(close - open)

    deltaUpAnatomy = volume * _rate(tw, bw, body, close > open)

    deltaDownAnatomy = volume * _rate(tw, bw, body, close < open)

    // Exact dojis are neutral to avoid a systematic bullish bias

    deltaAnatomy = close > open ? deltaUpAnatomy : close < open ? -deltaDownAnatomy : 0.0

    // Hybrid preserves some original responsiveness while emphasizing candle structure

    deltaHybrid = deltaDirectional * 0.35 + deltaAnatomy * 0.65

    delta = deltaMethod == "Candle Anatomy" ? deltaAnatomy : deltaMethod == "Hybrid" ? deltaHybrid : deltaDirectional

    cvdRaw = ta.cum(delta)

    cvdPressureRaw = cvdRaw - cvdRaw[1]

    cvdPressure = ta.ema(cvdPressureRaw, cvdSmoothLen)

    cvdPressureBase = ta.ema(math.abs(cvdPressure), cvdNormLen)

    cvdNorm = cvdPressureBase != 0 ? cvdPressure / cvdPressureBase : 0.0

    cvdNormClamped = math.max(math.min(cvdNorm, histClamp), -histClamp)

    momentum = close - close[1]

    doubleSmoothedMomentum = ta.ema(ta.ema(momentum, tsiShort), tsiLong)

    doubleSmoothedAbsMomentum = ta.ema(ta.ema(math.abs(momentum), tsiShort), tsiLong)

    tsi = doubleSmoothedAbsMomentum != 0 ? 100.0 * doubleSmoothedMomentum / doubleSmoothedAbsMomentum : 0.0

    tsiNorm = tsi / 100.0

    tsiAccelRaw = tsiNorm - tsiNorm[1]

    tsiAccel = ta.ema(tsiAccelRaw, tsiAccelSmooth)

    tsiAccelBoosted = tsiAccel * accelBoost

    baseThrust = cvdNormClamped * baseWeight

    accelAgreement = cvdNormClamped > 0 and tsiAccelBoosted > 0 ? 1.0 : cvdNormClamped < 0 and tsiAccelBoosted < 0 ? 1.0 : 0.0

    accelOpposition = cvdNormClamped > 0 and tsiAccelBoosted < 0 ? 1.0 : cvdNormClamped < 0 and tsiAccelBoosted > 0 ? 1.0 : 0.0

    boostLayer = accelAgreement == 1.0 ? math.abs(cvdNormClamped) * math.abs(tsiAccelBoosted) * boostWeight * math.sign(cvdNormClamped) : 0.0

    oppositionPenalty = accelOpposition == 1.0 ? math.abs(tsiAccelBoosted) * 0.20 : 0.0

    penaltyMultiplier = math.max(0.60, 1.0 - oppositionPenalty)

    rawHist = ((baseThrust * penaltyMultiplier) + boostLayer) * histPower

    softChop = math.abs(cvdNormClamped) < chopThreshold and math.abs(tsiAccelBoosted) < chopThreshold

    rawHistGated = useChopGate and softChop ? rawHist * chopCompression : rawHist

    compressionRelease = math.abs(rawHistGated[1]) < ignitionThreshold and math.abs(rawHistGated) > math.abs(rawHistGated[1]) and accelAgreement == 1.0

    rawHistIgnited = useIgnitionAssist and compressionRelease ? rawHistGated * (1.0 + ignitionBoost) : rawHistGated

    hist = ta.ema(rawHistIgnited, histSmoothLen)

    sameDirection = (hist > 0 and hist[1] > 0) or (hist < 0 and hist[1] < 0)

    histWeakening = math.abs(hist) < math.abs(hist[1])

    accelWeakening = math.abs(tsiAccelBoosted) < math.abs(tsiAccelBoosted[1])

    cvdWeakening = math.abs(cvdNormClamped) < math.abs(cvdNormClamped[1])

    trendHealthy = sameDirection and accelAgreement == 1.0 and math.abs(hist) > sustainThreshold and math.abs(cvdNormClamped) > chopThreshold

    sustainMultiplier = useTrendSustain and trendHealthy and not histWeakening ? sustainBoost : 1.0

    exhaustionPressure = sameDirection and histWeakening and accelWeakening and cvdWeakening

    decayMultiplier = useAdaptiveDecay and exhaustionPressure ? math.max(decayFloor, 1.0 - decaySensitivity) : 1.0

    histAdjusted = hist * sustainMultiplier * decayMultiplier

    tailZone = math.abs(histAdjusted) < tailThreshold and accelOpposition == 1.0 and math.abs(cvdNormClamped) < math.abs(cvdNormClamped[1])

    histTailCleaned = useTailCleanup and tailZone ? histAdjusted * tailDecay : histAdjusted

    resetZone = math.abs(histTailCleaned) < resetThreshold and math.abs(cvdNormClamped) < chopThreshold

    histReset = useResetAssist and resetZone ? histTailCleaned * 0.50 : histTailCleaned

    math.max(math.min(histReset, histClamp), -histClamp)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// CURRENT TF

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

histFinal = cvdXRay()

absHist = math.abs(histFinal)

pctRankRaw = ta.percentrank(absHist, percentileLen)

pctRank = math.min(pctRankRaw, 99.0)

bullPressure = histFinal >= bullThreshold

bearPressure = histFinal <= bearThreshold

pressureText = bullPressure ? "Bullish" : bearPressure ? "Bearish" : "Neutral"

pressureColor = bullPressure ? BULL_COLOR : bearPressure ? BEAR_COLOR : NEUTRAL_COLOR

strengthText = absHist < buildingLevel ? "Weak" :

     absHist < moderateLevel ? "Building" :

     absHist < strongLevel ? "Moderate" :

     absHist < extremeLevel ? "Strong" :

     "Extreme"

strengthColor = strengthText == "Weak" ? NEUTRAL_COLOR :

     strengthText == "Building" ? CAUTION_COLOR :

     BULL_COLOR

bullRising = histFinal > 0 and histFinal > histFinal[1]

bullFading = histFinal > 0 and histFinal <= histFinal[1]

bearRising = histFinal < 0 and histFinal < histFinal[1]

bearFading = histFinal < 0 and histFinal >= histFinal[1]

histColor = bullRising ? BULL_COLOR :

     bullFading ? color.new(BULL_COLOR, 35) :

     bearRising ? BEAR_COLOR :

     bearFading ? color.new(BEAR_COLOR, 35) :

     NEUTRAL_COLOR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// PLOTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(histFinal, title="CVD X-Ray Histogram", style=plot.style_histogram, color=histColor, linewidth=4)

hline(0, "Zero Line", color=showZeroLine ? color.new(color.gray, 45) : color.new(color.gray, 100))

hline(bullThreshold, "Bull Participation Threshold", color=showGuideLines ? color.new(BULL_COLOR, 55) : color.new(BULL_COLOR, 100), linestyle=hline.style_dashed)

hline(bearThreshold, "Bear Participation Threshold", color=showGuideLines ? color.new(BEAR_COLOR, 55) : color.new(BEAR_COLOR, 100), linestyle=hline.style_dashed)

hline(strongLevel, "Strong Bull Participation", color=showGuideLines ? color.new(BULL_COLOR, 82) : color.new(BULL_COLOR, 100), linestyle=hline.style_dotted)

hline(-strongLevel, "Strong Bear Participation", color=showGuideLines ? color.new(BEAR_COLOR, 82) : color.new(BEAR_COLOR, 100), linestyle=hline.style_dotted)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MTF BUYER / SELLER BALANCE

// Same close-position calculation used by CVD MTF Dashboard

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buyerPct() =>

    priceRange = math.max(high - low, syminfo.mintick)

    closePos = (close - low) / priceRange

    math.max(0.0, math.min(100.0, math.round(closePos * 100.0)))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// MTF

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

hist1 = request.security(syminfo.tickerid, tf1, cvdXRay())

hist2 = request.security(syminfo.tickerid, tf2, cvdXRay())

hist3 = request.security(syminfo.tickerid, tf3, cvdXRay())

buyPct1 = request.security(syminfo.tickerid, tf1, buyerPct())

buyPct2 = request.security(syminfo.tickerid, tf2, buyerPct())

buyPct3 = request.security(syminfo.tickerid, tf3, buyerPct())

avgBuyPct = math.round((buyPct1 + buyPct2 + buyPct3) / 3.0)

avgSellPct = 100.0 - avgBuyPct

buyerDominantPct = avgBuyPct >= 50.0

balanceLabel = buyerDominantPct ? "BUYERS" : "SELLERS"

balancePct = buyerDominantPct ? avgBuyPct : avgSellPct

balanceColor = buyerDominantPct ? BULL_COLOR : BEAR_COLOR

buyersLabelColor = avgBuyPct > 50.0 ? BULL_COLOR : avgBuyPct < 50.0 ? BEAR_COLOR : NEUTRAL_COLOR

bull1 = hist1 >= bullThreshold

bull2 = hist2 >= bullThreshold

bull3 = hist3 >= bullThreshold

bear1 = hist1 <= bearThreshold

bear2 = hist2 <= bearThreshold

bear3 = hist3 <= bearThreshold

bullCount = (bull1 ? 1 : 0) + (bull2 ? 1 : 0) + (bull3 ? 1 : 0)

bearCount = (bear1 ? 1 : 0) + (bear2 ? 1 : 0) + (bear3 ? 1 : 0)

strong1 = math.abs(hist1) >= strongLevel

strong2 = math.abs(hist2) >= strongLevel

strong3 = math.abs(hist3) >= strongLevel

strongCount = (strong1 ? 1 : 0) + (strong2 ? 1 : 0) + (strong3 ? 1 : 0)

fullBull = bullCount == 3 and strongCount >= 2

fullBear = bearCount == 3 and strongCount >= 2

bullDominant = bullCount >= 2 and bearCount == 0 and not fullBull

bearDominant = bearCount >= 2 and bullCount == 0 and not fullBear

bullTransition = bullCount >= 2 and bearCount >= 1

bearTransition = bearCount >= 2 and bullCount >= 1

stackText = fullBull ? "FULL BULL" :

     fullBear ? "FULL BEAR" :

     bullDominant ? "BULL DOMINANT" :

     bearDominant ? "BEAR DOMINANT" :

     bullTransition ? "BULL TRANSITION" :

     bearTransition ? "BEAR TRANSITION" :

     "MIXED"

stackColor = fullBull or bullDominant or bullTransition ? BULL_COLOR :

     fullBear or bearDominant or bearTransition ? BEAR_COLOR :

     MUTED_TEXT

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// HELPERS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tfLabel(_tf) =>

    n = str.tonumber(_tf)

    not na(n) ? (int(n) >= 60 and int(n) % 60 == 0 ? str.tostring(int(n / 60)) + "H" : str.tostring(int(n)) + "M") : _tf == "D" ? "1D" : _tf == "W" ? "1W" : _tf == "M" ? "1MO" : str.upper(_tf)

tfDir(_hist) =>

    _hist >= bullThreshold ? "▲" : _hist <= bearThreshold ? "▼" : "—"

tfDirColor(_hist) =>

    _hist >= bullThreshold ? BULL_COLOR : _hist <= bearThreshold ? BEAR_COLOR : CAUTION_COLOR

tfStrength(_hist) =>

    a = math.abs(_hist)

    a < buildingLevel ? "Weak" : a < moderateLevel ? "Bld" : a < strongLevel ? "Mod" : a < extremeLevel ? "Str" : "Ext"

tfStrengthColor(_hist) =>

    a = math.abs(_hist)

    a < buildingLevel ? NEUTRAL_COLOR :

     a < moderateLevel ? CAUTION_COLOR :

     BULL_COLOR

tfPwr(_hist) =>

    a = math.abs(_hist)

    a >= strongLevel ? "●" : a >= moderateLevel ? "◑" : "○"

tfPwrColor(_hist) =>

    a = math.abs(_hist)

    a >= strongLevel ? BULL_COLOR : a >= moderateLevel ? CAUTION_COLOR : NEUTRAL_COLOR

chartTfLabel = tfLabel(timeframe.period)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// LEFT READOUT

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table readout = table.new(position.top_left, 14, 1)

if barstate.islast and showReadout

    table.cell(readout, 0, 0, "TF:", text_color=MUTED_TEXT)

    table.cell(readout, 1, 0, chartTfLabel, text_color=color.white)

    table.cell(readout, 2, 0, " · ", text_color=color.new(color.white, 70))

    table.cell(readout, 3, 0, "CVD:", text_color=MUTED_TEXT)

    table.cell(readout, 4, 0, str.tostring(histFinal, "#.00"), text_color=color.white)

    table.cell(readout, 5, 0, " · ", text_color=color.new(color.white, 70))

    table.cell(readout, 6, 0, "Pressure:", text_color=MUTED_TEXT)

    table.cell(readout, 7, 0, pressureText, text_color=pressureColor)

    table.cell(readout, 8, 0, " · ", text_color=color.new(color.white, 70))

    table.cell(readout, 9, 0, "Strength:", text_color=MUTED_TEXT)

    table.cell(readout, 10, 0, strengthText, text_color=strengthColor)

    table.cell(readout, 11, 0, showPctReadout ? " · " : "", text_color=color.new(color.white, 70))

    table.cell(readout, 12, 0, showPctReadout ? "PCT:" : "", text_color=MUTED_TEXT)

    table.cell(readout, 13, 0, showPctReadout ? "P" + str.tostring(pctRank, "#") : "", text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// SINGLE STABLE MTF TABLE

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mtfRows = showBuyerPct ? 7 : 6

var table mtfPanel = table.new(position.top_right, 5, mtfRows, border_width=1, frame_color=BORDER_COLOR, border_color=BORDER_COLOR)

renderRow(row, tf, val) =>

    bg = row % 2 == 0 ? ROW_BG : PANEL_BG

    table.cell(mtfPanel, 0, row, " " + tfLabel(tf) + " ", text_color=HEADER_COLOR, bgcolor=bg)

    table.cell(mtfPanel, 1, row, " " + str.tostring(val, "#.00") + " ", text_color=color.white, bgcolor=bg)

    table.cell(mtfPanel, 2, row, " " + tfStrength(val) + " ", text_color=tfStrengthColor(val), bgcolor=bg)

    table.cell(mtfPanel, 3, row, " " + tfDir(val) + " ", text_color=tfDirColor(val), bgcolor=bg, text_size=size.large)

    table.cell(mtfPanel, 4, row, " " + tfPwr(val) + " ", text_color=tfPwrColor(val), bgcolor=bg)

if barstate.islast and showMTF

    table.cell(mtfPanel, 0, 0, "CVD X-RAY", text_color=color.white, bgcolor=HEADER_BG)

    table.merge_cells(mtfPanel, 0, 0, 4, 0)

    table.cell(mtfPanel, 0, 1, "TF", text_color=MUTED_TEXT, bgcolor=PANEL_BG, text_size=size.small)

    table.cell(mtfPanel, 1, 1, "CVD", text_color=MUTED_TEXT, bgcolor=PANEL_BG, text_size=size.small)

    table.cell(mtfPanel, 2, 1, "STG", text_color=MUTED_TEXT, bgcolor=PANEL_BG, text_size=size.small)

    table.cell(mtfPanel, 3, 1, "DIR", text_color=MUTED_TEXT, bgcolor=PANEL_BG, text_size=size.small)

    table.cell(mtfPanel, 4, 1, "PWR", text_color=MUTED_TEXT, bgcolor=PANEL_BG, text_size=size.small)

    renderRow(2, tf1, hist1)

    renderRow(3, tf2, hist2)

    renderRow(4, tf3, hist3)

    table.cell(mtfPanel, 0, 5, " MTF ALIGN ", text_color=MUTED_TEXT, bgcolor=HEADER_BG, text_size=size.small)

    table.cell(mtfPanel, 1, 5, " " + stackText + " ", text_color=stackColor, bgcolor=HEADER_BG, text_halign=text.align_left)

    table.merge_cells(mtfPanel, 1, 5, 4, 5)

    if showBuyerPct

        table.cell(mtfPanel, 0, 6, " FLOW ", text_color=MUTED_TEXT, bgcolor=HEADER_BG, text_size=size.small)

        table.cell(mtfPanel, 1, 6, " BUYERS ", text_color=buyersLabelColor, bgcolor=HEADER_BG, text_halign=text.align_left)

        table.cell(mtfPanel, 2, 6, " " + str.tostring(avgBuyPct, "#") + "% ", text_color=color.white, bgcolor=HEADER_BG, text_halign=text.align_left)

        table.merge_cells(mtfPanel, 2, 6, 4, 6)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ALERTS

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullIgnition = histFinal >= bullThreshold and histFinal > histFinal[1]

bearIgnition = histFinal <= bearThreshold and histFinal < histFinal[1]

alertcondition(bullIgnition, title="Bull CVD Threshold", message="CVD X-Ray: Bullish pressure threshold expanding")

alertcondition(bearIgnition, title="Bear CVD Threshold", message="CVD X-Ray: Bearish pressure threshold expanding")

alertcondition(fullBull, title="CVD X-Ray Full Bull", message="CVD X-Ray: Full Bull MTF pressure")

alertcondition(fullBear, title="CVD X-Ray Full Bear", message="CVD X-Ray: Full Bear MTF pressure")

alertcondition(bullDominant, title="CVD X-Ray Bull Dominant", message="CVD X-Ray: Bull Dominant MTF pressure")

alertcondition(bearDominant, title="CVD X-Ray Bear Dominant", message="CVD X-Ray: Bear Dominant MTF pressure")
````
