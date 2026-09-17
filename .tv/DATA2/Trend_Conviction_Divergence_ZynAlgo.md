<!-- tradingview-pine-id: PUB;bd55afe6c256463bb3e6918abc6c3c12 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Conviction Divergence [ZynAlgo]

Source: https://www.tradingview.com/script/TKB5vLDl-Trend-Conviction-Divergence-ZynAlgo/

## Description

1. Overview
Trend Conviction Divergence measures how much conviction is behind the current trend, not just its direction. It blends four proxies - Price Efficiency, Participation, Follow Through and Breakout Acceptance - into a single 0-100 Conviction Score shown in its own pane, and keeps trend direction separate so a fading trend stays visible.
[image]https://www.tradingview.com/x/DcoYyEfq/[/image]

2. What Builds the Conviction Score

[*]Price Efficiency - a Kaufman-style efficiency ratio: net directional move divided by total bar-to-bar movement. Near 1 is a clean push, near 0 is chop.
[*]Participation - recent volume average versus an older baseline; volume draining during a move flags weak participation (volume is a proxy and can be unreliable on some symbols).
[*]Follow Through - size of the latest swing leg versus the average of prior legs; shrinking legs mean weakening follow-through.
[*]Breakout Acceptance - the share of recent range breakouts that held instead of being rejected.

3. How to Read the Conviction Score

[*]The score plots as columns: red below the Weak level (default 40), yellow between, green above the Strong level (default 70). Two dashed lines mark the 40 and 70 levels.
[*]Divergence read: when direction stays BULLISH or BEARISH but the score slides toward or under the weak line, conviction is leaving the trend before price turns.
[*]Confirming read: when price is trending and the score holds in the green zone above the Strong level, conviction is backing the move rather than fading.
[*]Use it as a confirmation and filter layer over your own setups - lean in when conviction is high and rising, be cautious when it is weak or diverging. It is analytical context, not an entry trigger.

[image]https://www.tradingview.com/x/63P6vsOo/[/image]

[*]The dashboard shows PRICE (BULLISH or BEARISH), CONVICTION (the score as a percentage) and STATUS (WEAK TREND / MODERATE / STRONG TREND).

[image]https://www.tradingview.com/x/Ltfqf7PL/[/image]

4. Inputs / Settings

[*]Trend Reference Length - moving-average length that sets the BULLISH or BEARISH direction.
[*]Efficiency Lookback - window used for the Price Efficiency ratio.
[*]Participation - recent and baseline volume lengths plus the baseline offset.
[*]Follow Through - swing pivot length and how many legs are remembered for the average.
[*]Breakout Acceptance - breakout lookback, bars-later acceptance check, and how many recent breakouts are averaged.
[*]Conviction Score Weights - the weight of each of the four components in the blend.
[*]Display - Weak and Strong thresholds that drive the coloring and status.

5. Notes

[*]Like any oscillator, the current bar value updates until the bar closes; closed bars do not change.
[*]This is an analytical tool, not a signal generator, and does not guarantee any trading result. Always use your own analysis and risk management.

---

## Source Code

````pine
//@version=6
// Trend Conviction Divergence [ZynAlgo]
// A composite 0-100 "conviction" score for how much strength is behind the current
// trend, built from four components: Price Efficiency (Kaufman-style efficiency
// ratio), Participation (recent volume vs an older baseline - note volume is a proxy
// and can be unreliable on some symbols), Follow Through (latest swing leg vs the
// average of prior legs) and Breakout Acceptance (share of recent range breakouts
// that held rather than got rejected). Trend direction is kept separate from
// conviction, so conviction can fade while price still moves the same way.
// Analytical context and filter tool - not a trading-signal generator.
indicator("Trend Conviction Divergence [ZynAlgo]", shorttitle="Trend Conviction Divergence [ZynAlgo]", overlay=false, max_labels_count=50)

// ==========================================
// 1. INPUTS
// ==========================================
grp_trend = "Trend Direction"
trendLen = input.int(20, "Trend Reference Length", minval=1, group=grp_trend)

grp_efficiency = "Price Efficiency"
erLen = input.int(14, "Efficiency Lookback (bars)", minval=2, group=grp_efficiency, tooltip="Net directional move over this window, divided by the sum of every bar-to-bar move in the same window (Kaufman-style Efficiency Ratio). Near 1 = clean directional move, near 0 = choppy/noisy.")

grp_participation = "Participation (Volume)"
volShortLen = input.int(5, "Recent Volume Average Length", minval=1, group=grp_participation)
volLongLen  = input.int(20, "Baseline Volume Average Length", minval=1, group=grp_participation, tooltip="Participation compares the recent short-term volume average to this longer baseline average from several bars back - declining volume during a continuing move signals weakening participation.")
volBaselineOffset = input.int(10, "Baseline Offset (bars back)", minval=1, group=grp_participation)

grp_followthrough = "Follow Through"
pivotLen        = input.int(5, "Swing Pivot Length", minval=2, group=grp_followthrough)
maxLegsStored   = input.int(10, "Legs Remembered for Average", minval=2, group=grp_followthrough, tooltip="The size of the most recently completed swing leg is compared to the average size of the prior legs in memory - shrinking legs signal weakening follow-through.")

grp_acceptance = "Breakout Acceptance"
acceptLen       = input.int(20, "Breakout Lookback (N-bar high/low)", minval=5, group=grp_acceptance)
acceptCheckBars = input.int(5, "Bars Later to Check Acceptance", minval=1, group=grp_acceptance)
acceptWindow    = input.int(10, "Recent Breakouts Averaged", minval=1, maxval=30, group=grp_acceptance)

grp_weights = "Conviction Score Weights"
wEfficiency    = input.float(25, "Price Efficiency Weight", minval=0, group=grp_weights)
wParticipation = input.float(25, "Participation Weight", minval=0, group=grp_weights)
wFollowThrough = input.float(25, "Follow Through Weight", minval=0, group=grp_weights)
wAcceptance    = input.float(25, "Breakout Acceptance Weight", minval=0, group=grp_weights)

grp_display = "Display"
weakThreshold   = input.float(40, "Weak Trend Warning Threshold (%)", minval=0, maxval=100, group=grp_display)
strongThreshold = input.float(70, "Strong Trend Threshold (%)", minval=0, maxval=100, group=grp_display)

// ==========================================
// 2. TREND DIRECTION (separate from conviction)
// ==========================================
trendMA = ta.sma(close, trendLen)
isBullish = close > trendMA

// ==========================================
// 3. PRICE EFFICIENCY
// ==========================================
netMove = math.abs(close - close[erLen])
sumMove = ta.sma(math.abs(close - close[1]), erLen) * erLen
priceEfficiency = sumMove > 0 ? netMove / sumMove : 0.0

// ==========================================
// 4. PARTICIPATION (VOLUME)
// ==========================================
volShort = ta.sma(volume, volShortLen)
volBaseline = ta.sma(volume, volLongLen)[volBaselineOffset]
participationRaw = volBaseline > 0 ? volShort / volBaseline : 1.0
participationScore = math.min(1.0, participationRaw)

// ==========================================
// 5. FOLLOW THROUGH (SWING LEG SIZE TREND)
// ==========================================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float[] legSizes       = array.new_float(0)
var float   lastPivotPrice = na
var int     lastPivotType  = 0

if barstate.isconfirmed
    if not na(ph)
        if lastPivotType == -1 and not na(lastPivotPrice)
            legSize = ph - lastPivotPrice
            array.push(legSizes, legSize)
            if array.size(legSizes) > maxLegsStored
                array.shift(legSizes)
        lastPivotPrice := ph
        lastPivotType := 1

    if not na(pl)
        if lastPivotType == 1 and not na(lastPivotPrice)
            legSize = lastPivotPrice - pl
            array.push(legSizes, legSize)
            if array.size(legSizes) > maxLegsStored
                array.shift(legSizes)
        lastPivotPrice := pl
        lastPivotType := -1

followThroughScore = 0.5
if array.size(legSizes) >= 2
    lastLeg = array.get(legSizes, array.size(legSizes) - 1)
    sumPrior = 0.0
    for i = 0 to array.size(legSizes) - 2
        sumPrior += array.get(legSizes, i)
    countPrior = array.size(legSizes) - 1
    avgPrior = countPrior > 0 ? sumPrior / countPrior : lastLeg
    followThroughScore := avgPrior > 0 ? math.min(1.0, lastLeg / avgPrior) : 0.5

// ==========================================
// 6. BREAKOUT ACCEPTANCE
// ==========================================
donchianHigh = ta.highest(high, acceptLen)[1]
donchianLow  = ta.lowest(low, acceptLen)[1]

var float[] breakoutResults      = array.new_float(0)
var int     pendingBreakoutBar   = na
var float   pendingBreakoutLevel = na
var bool    pendingBreakoutIsHigh = true

if barstate.isconfirmed
    if na(pendingBreakoutBar)
        if close > donchianHigh
            pendingBreakoutBar    := bar_index
            pendingBreakoutLevel  := donchianHigh
            pendingBreakoutIsHigh := true
        else if close < donchianLow
            pendingBreakoutBar    := bar_index
            pendingBreakoutLevel  := donchianLow
            pendingBreakoutIsHigh := false

    if not na(pendingBreakoutBar) and (bar_index - pendingBreakoutBar) >= acceptCheckBars
        accepted = pendingBreakoutIsHigh ? close > pendingBreakoutLevel : close < pendingBreakoutLevel
        array.push(breakoutResults, accepted ? 1.0 : 0.0)
        if array.size(breakoutResults) > acceptWindow
            array.shift(breakoutResults)
        pendingBreakoutBar := na

acceptanceScore = array.size(breakoutResults) > 0 ? array.sum(breakoutResults) / array.size(breakoutResults) : 0.5

// ==========================================
// 7. COMPOSITE CONVICTION SCORE
// ==========================================
totalWeight = wEfficiency + wParticipation + wFollowThrough + wAcceptance
convictionRaw = totalWeight > 0 ? (priceEfficiency * wEfficiency + participationScore * wParticipation + followThroughScore * wFollowThrough + acceptanceScore * wAcceptance) / totalWeight : 0.5
convictionScore = convictionRaw * 100

// ==========================================
// 8. PLOTTING
// ==========================================
convictionColor = convictionScore < weakThreshold ? color.new(#F5474A, 0) : convictionScore > strongThreshold ? color.new(#10B981, 0) : color.new(#FFD600, 0)
plot(convictionScore, "Conviction Score", color=convictionColor, style=plot.style_columns, linewidth=2)

hline(strongThreshold, "Strong Trend", color=color.new(#10B981, 60), linestyle=hline.style_dashed)
hline(weakThreshold, "Weak Trend", color=color.new(#F5474A, 60), linestyle=hline.style_dashed)

// ==========================================
// 9. DASHBOARD
// ==========================================
var table dash = table.new(position.top_right, 2, 3, bgcolor=color.new(#131722, 10), border_color=color.new(#363a45, 0), border_width=1)

if barstate.islast
    priceDirText  = isBullish ? "BULLISH" : "BEARISH"
    priceDirColor = isBullish ? color.new(color.teal, 0) : color.new(color.red, 0)
    warningText   = convictionScore < weakThreshold ? "⚠ WEAK TREND" : convictionScore > strongThreshold ? "STRONG TREND" : "MODERATE"
    warningColor  = convictionScore < weakThreshold ? color.new(#F5474A, 0) : convictionScore > strongThreshold ? color.new(#10B981, 0) : color.new(#FFD600, 0)

    table.cell(dash, 0, 0, "PRICE", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, priceDirText, text_color=priceDirColor, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 1, "CONVICTION", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(convictionScore, "#") + "%", text_color=color.white, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 2, "STATUS", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, warningText, text_color=warningColor, text_size=size.small, text_halign=text.align_right)
````
