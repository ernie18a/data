<!-- tradingview-pine-id: PUB;aaa734fea7b94d1ab2f06d8bf95be744 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cross Asset Relative Strength Matrix [Pineify]

Source: https://www.tradingview.com/script/UL0fNWQ3-Cross-Asset-Relative-Strength-Matrix-Pineify/

## Description

Cross Asset Relative Strength Matrix [Pineify]

Overview
This indicator compares up to eight markets through a bounded relative-strength heatmap, consistency-weighted ranks, and one focus history. Every row states whether its snapshot is LIVE or STALE.

Problem Definition
Raw performance tables rank endpoint percentage change but ignore its path. A smooth advance and a violent round trip can end equally, while high-volatility assets can dominate. Mixed quote currencies and asynchronous sessions further break comparability. The useful question is which asset has the strongest normalized move, how coherently it formed, and whether its source has updated recently.

Design Rationale
Log returns add across a shared window. Window return divided by root-sum-square one-bar returns measures displacement against path energy, then a bounded transform limits extremes. A price z-score was rejected because it measures local-mean distance rather than shared-window performance. Cells show standardized differences while rank discounts reversal-heavy paths. Currency normalization aligns price basis. Source timestamps commit snapshots only when markets advance; the stale threshold labels rather than erases an old snapshot.

Key Features

[*]Eight symbols and optional currency normalization.
[*]Pairwise heatmap with consistency-aware intensity.
[*]Cached last-valid snapshots with LIVE or STALE status.
[*]Consistency rank, focus line, halo, rail, and gated alerts.

How It Works

[*]Each symbol uses the chart timeframe and lookahead off. A source timestamp change commits its cached score.
[*]Optional daily rates convert the declared quote currency; a missing rate prevents a valid snapshot.
[*]Window log return divided by one-bar return energy is bounded from -100 to +100.
[*]Path efficiency and directional agreement form a 55/45 consistency score.
[*]Each cell is row score minus column score. Teal leads, magenta lags, and reliability controls intensity.
[*]Rank applies consistency; the focus line subtracts basket mean quality. STALE values remain visible with dimmed heat and explicit text.

Warm-up needs the full window and a valid source update. Too few cached assets suppress output. Alerts require the configured minimum number of current assets plus a current focus asset.

How Multiple Indicators Work Together
The components form one chain. Currency defines price basis; energy scaling creates comparable returns; path statistics describe formation; subtraction identifies leadership; timestamp caching preserves the last cross-section while exposing age. Without energy, volatility dominates; without consistency, smooth and reversal-heavy paths look alike; without LIVE/STALE labels, asynchronous times are hidden. Heatmap, rank, and focus line are views of this chain.

Trading Ideas and Insights
Use an economically related basket such as regions, sectors, macro proxies, commodities, or major crypto assets. Positive cells across a row describe relative leadership; high rank with low consistency describes a noisy advantage. A focus move above zero or into the top two can prompt chart review, not an automatic entry. Treat STALE rows as historical context, and keep structure, liquidity, and risk decisions separate.

Unique Aspects
The contribution is separating comparison value, path confidence, and timestamp state. Common heatmaps sort one raw return, then silently fill or erase unavailable rows. Here, cells retain bounded return-energy differences, rank applies consistency, and source-driven snapshots freeze between actual updates. The table distinguishes magnitude, path quality, and whether data is current.

How to Use
Choose two to eight related symbols; the intended range is 4H to 1W. Set one lookback and focus slot. For mixed currencies, enable conversion and declare each quote correctly. Read across rows for leadership, use RANK / DATA to distinguish LIVE from STALE, and use the focus line for history. Amber means the focus reading is stale or below the consistency floor; the table identifies the data state.

Customization
Short windows react faster but are endpoint-sensitive; long windows adapt later. Minimum active assets controls coverage. Maximum stale bars controls when a cached row changes from LIVE to STALE; it does not delete the snapshot. The consistency floor changes the amber state. Focus slot changes the history and alerts, not the matrix. Matrix, halo, background, and rail remain independent visual switches.

Assumptions and Limitations
Daily FX rates and asset prices may update on different schedules; wrong declarations mislead. A confirmed snapshot remains visible after its market closes and becomes STALE after the threshold. It still affects the descriptive matrix and rank, so asynchronous baskets can compare different observation times; dimmed cells and text disclose this limitation. Alerts require a completed bar, current focus, and enough current assets. Scaling is not beta adjustment, correlation control, forecasting, or optimization. The basket is equal-observation, not capitalization weighted. Permissions, invalid symbols, illiquidity, corporate actions, rolls, and holidays can distort coverage. Current-bar values may change intrabar. No future data or lookahead is used.

Conclusion
The matrix reports standardized differences, consistency ranks, snapshot age, and focus history—not prediction. Use a coherent basket and correct currencies; STALE means last confirmed, not live.

---

## Source Code

````pine
//@version=6
indicator("Cross Asset Relative Strength Matrix [Pineify]", shorttitle="CARSM [Pineify]", overlay=false, dynamic_requests=true)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string GROUP_BASKET = "Asset basket"
string GROUP_CURRENCY = "Currency normalization"
string GROUP_MODEL = "Relative strength model"
string GROUP_VISUALS = "Visual system"

enable1 = input.bool(true, "Enable 1", inline="a1", group=GROUP_BASKET)
symbol1 = input.symbol("AMEX:SPY", "Asset 1", inline="a1", group=GROUP_BASKET)
currency1 = input.string("USD", "Currency 1", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c1", group=GROUP_CURRENCY)
enable2 = input.bool(true, "Enable 2", inline="a2", group=GROUP_BASKET)
symbol2 = input.symbol("NASDAQ:QQQ", "Asset 2", inline="a2", group=GROUP_BASKET)
currency2 = input.string("USD", "Currency 2", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c2", group=GROUP_CURRENCY)
enable3 = input.bool(true, "Enable 3", inline="a3", group=GROUP_BASKET)
symbol3 = input.symbol("AMEX:IWM", "Asset 3", inline="a3", group=GROUP_BASKET)
currency3 = input.string("USD", "Currency 3", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c3", group=GROUP_CURRENCY)
enable4 = input.bool(true, "Enable 4", inline="a4", group=GROUP_BASKET)
symbol4 = input.symbol("NASDAQ:TLT", "Asset 4", inline="a4", group=GROUP_BASKET)
currency4 = input.string("USD", "Currency 4", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c4", group=GROUP_CURRENCY)
enable5 = input.bool(true, "Enable 5", inline="a5", group=GROUP_BASKET)
symbol5 = input.symbol("AMEX:GLD", "Asset 5", inline="a5", group=GROUP_BASKET)
currency5 = input.string("USD", "Currency 5", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c5", group=GROUP_CURRENCY)
enable6 = input.bool(true, "Enable 6", inline="a6", group=GROUP_BASKET)
symbol6 = input.symbol("AMEX:USO", "Asset 6", inline="a6", group=GROUP_BASKET)
currency6 = input.string("USD", "Currency 6", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c6", group=GROUP_CURRENCY)
enable7 = input.bool(true, "Enable 7", inline="a7", group=GROUP_BASKET)
symbol7 = input.symbol("AMEX:UUP", "Asset 7", inline="a7", group=GROUP_BASKET)
currency7 = input.string("USD", "Currency 7", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c7", group=GROUP_CURRENCY)
enable8 = input.bool(true, "Enable 8", inline="a8", group=GROUP_BASKET)
symbol8 = input.symbol("AMEX:VEA", "Asset 8", inline="a8", group=GROUP_BASKET)
currency8 = input.string("USD", "Currency 8", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], inline="c8", group=GROUP_CURRENCY)

convertCurrency = input.bool(false, "Convert assets to a common currency", group=GROUP_CURRENCY)
baseCurrency = input.string("USD", "Base currency", options=["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "HKD"], group=GROUP_CURRENCY)

lookback = input.int(63, "Unified comparison window", minval=10, maxval=252, group=GROUP_MODEL)
minimumActive = input.int(3, "Minimum active assets", minval=2, maxval=8, group=GROUP_MODEL)
maximumStaleBars = input.int(2, "Maximum stale chart bars", minval=0, maxval=10, group=GROUP_MODEL)
consistencyFloor = input.float(0.45, "Reliable consistency floor", minval=0.10, maxval=0.90, step=0.05, group=GROUP_MODEL)
focusSlot = input.int(1, "Focus asset slot", minval=1, maxval=8, group=GROUP_MODEL)

showMatrix = input.bool(true, "Show relative strength matrix", group=GROUP_VISUALS)
showHalo = input.bool(true, "Show focus consistency halo", group=GROUP_VISUALS)
showStateWash = input.bool(true, "Show focus state background", group=GROUP_VISUALS)
showRankRail = input.bool(true, "Show focus rank rail", group=GROUP_VISUALS)
bullColor = input.color(color.rgb(20, 184, 166), "Relative leader", group=GROUP_VISUALS)
bearColor = input.color(color.rgb(225, 76, 122), "Relative laggard", group=GROUP_VISUALS)
uncertainColor = input.color(color.rgb(245, 158, 11), "Low consistency", group=GROUP_VISUALS)
neutralColor = input.color(color.rgb(148, 163, 184), "Neutral / unavailable", group=GROUP_VISUALS)

//------------------------------------------------------------------------------
// Fixed, bounded data requests
//------------------------------------------------------------------------------
[raw1, stamp1] = request.security(symbol1, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw2, stamp2] = request.security(symbol2, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw3, stamp3] = request.security(symbol3, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw4, stamp4] = request.security(symbol4, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw5, stamp5] = request.security(symbol5, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw6, stamp6] = request.security(symbol6, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw7, stamp7] = request.security(symbol7, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[raw8, stamp8] = request.security(symbol8, timeframe.period, [close, time], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

fx1 = convertCurrency and currency1 != baseCurrency ? request.currency_rate(currency1, baseCurrency, ignore_invalid_currency=true) : 1.0
fx2 = convertCurrency and currency2 != baseCurrency ? request.currency_rate(currency2, baseCurrency, ignore_invalid_currency=true) : 1.0
fx3 = convertCurrency and currency3 != baseCurrency ? request.currency_rate(currency3, baseCurrency, ignore_invalid_currency=true) : 1.0
fx4 = convertCurrency and currency4 != baseCurrency ? request.currency_rate(currency4, baseCurrency, ignore_invalid_currency=true) : 1.0
fx5 = convertCurrency and currency5 != baseCurrency ? request.currency_rate(currency5, baseCurrency, ignore_invalid_currency=true) : 1.0
fx6 = convertCurrency and currency6 != baseCurrency ? request.currency_rate(currency6, baseCurrency, ignore_invalid_currency=true) : 1.0
fx7 = convertCurrency and currency7 != baseCurrency ? request.currency_rate(currency7, baseCurrency, ignore_invalid_currency=true) : 1.0
fx8 = convertCurrency and currency8 != baseCurrency ? request.currency_rate(currency8, baseCurrency, ignore_invalid_currency=true) : 1.0

price1 = raw1 * fx1
price2 = raw2 * fx2
price3 = raw3 * fx3
price4 = raw4 * fx4
price5 = raw5 * fx5
price6 = raw6 * fx6
price7 = raw7 * fx7
price8 = raw8 * fx8

f_clamp(float value, float lower, float upper) =>
    math.min(math.max(value, lower), upper)

f_fresh(int stamp) =>
    barsSinceUpdate = ta.barssince(not na(stamp) and stamp != stamp[1])
    not na(stamp) and nz(barsSinceUpdate, maximumStaleBars + 1) <= maximumStaleBars

f_updated(int stamp) =>
    not na(stamp) and (na(stamp[1]) or stamp != stamp[1])

f_metrics(float price, bool enabled) =>
    stepReturn = price > 0.0 and price[1] > 0.0 ? math.log(price / price[1]) : na
    windowReturn = price > 0.0 and price[lookback] > 0.0 ? math.log(price / price[lookback]) : na
    pathLength = math.sum(math.abs(stepReturn), lookback)
    returnEnergy = math.sqrt(math.sum(stepReturn * stepReturn, lookback))
    directionBias = math.sum(math.sign(stepReturn), lookback) / float(lookback)
    agreement = windowReturn >= 0.0 ? 0.5 * (1.0 + directionBias) : 0.5 * (1.0 - directionBias)
    pathEfficiency = pathLength > 0.0 ? math.abs(windowReturn) / pathLength : 0.0
    consistency = f_clamp(0.55 * pathEfficiency + 0.45 * agreement, 0.0, 1.0)
    energyRatio = returnEnergy > 0.0 ? windowReturn / returnEnergy : 0.0
    normalizedReturn = 100.0 * energyRatio / (1.0 + math.abs(energyRatio))
    qualityScore = normalizedReturn * (0.35 + 0.65 * consistency)
    valid = enabled and not na(windowReturn) and not na(returnEnergy) and not na(consistency)
    [valid ? normalizedReturn : na, valid ? consistency : na, valid ? qualityScore : na, valid]

eligible1 = enable1 and (not convertCurrency or not na(fx1))
eligible2 = enable2 and (not convertCurrency or not na(fx2))
eligible3 = enable3 and (not convertCurrency or not na(fx3))
eligible4 = enable4 and (not convertCurrency or not na(fx4))
eligible5 = enable5 and (not convertCurrency or not na(fx5))
eligible6 = enable6 and (not convertCurrency or not na(fx6))
eligible7 = enable7 and (not convertCurrency or not na(fx7))
eligible8 = enable8 and (not convertCurrency or not na(fx8))

[candidateS1, candidateK1, candidateQ1, candidateV1] = f_metrics(price1, eligible1)
[candidateS2, candidateK2, candidateQ2, candidateV2] = f_metrics(price2, eligible2)
[candidateS3, candidateK3, candidateQ3, candidateV3] = f_metrics(price3, eligible3)
[candidateS4, candidateK4, candidateQ4, candidateV4] = f_metrics(price4, eligible4)
[candidateS5, candidateK5, candidateQ5, candidateV5] = f_metrics(price5, eligible5)
[candidateS6, candidateK6, candidateQ6, candidateV6] = f_metrics(price6, eligible6)
[candidateS7, candidateK7, candidateQ7, candidateV7] = f_metrics(price7, eligible7)
[candidateS8, candidateK8, candidateQ8, candidateV8] = f_metrics(price8, eligible8)

updated1 = f_updated(stamp1)
updated2 = f_updated(stamp2)
updated3 = f_updated(stamp3)
updated4 = f_updated(stamp4)
updated5 = f_updated(stamp5)
updated6 = f_updated(stamp6)
updated7 = f_updated(stamp7)
updated8 = f_updated(stamp8)
fresh1 = f_fresh(stamp1)
fresh2 = f_fresh(stamp2)
fresh3 = f_fresh(stamp3)
fresh4 = f_fresh(stamp4)
fresh5 = f_fresh(stamp5)
fresh6 = f_fresh(stamp6)
fresh7 = f_fresh(stamp7)
fresh8 = f_fresh(stamp8)

var float s1 = na
var float s2 = na
var float s3 = na
var float s4 = na
var float s5 = na
var float s6 = na
var float s7 = na
var float s8 = na
var float k1 = na
var float k2 = na
var float k3 = na
var float k4 = na
var float k5 = na
var float k6 = na
var float k7 = na
var float k8 = na
var float q1 = na
var float q2 = na
var float q3 = na
var float q4 = na
var float q5 = na
var float q6 = na
var float q7 = na
var float q8 = na

if updated1 and candidateV1
    s1 := candidateS1
    k1 := candidateK1
    q1 := candidateQ1
if updated2 and candidateV2
    s2 := candidateS2
    k2 := candidateK2
    q2 := candidateQ2
if updated3 and candidateV3
    s3 := candidateS3
    k3 := candidateK3
    q3 := candidateQ3
if updated4 and candidateV4
    s4 := candidateS4
    k4 := candidateK4
    q4 := candidateQ4
if updated5 and candidateV5
    s5 := candidateS5
    k5 := candidateK5
    q5 := candidateQ5
if updated6 and candidateV6
    s6 := candidateS6
    k6 := candidateK6
    q6 := candidateQ6
if updated7 and candidateV7
    s7 := candidateS7
    k7 := candidateK7
    q7 := candidateQ7
if updated8 and candidateV8
    s8 := candidateS8
    k8 := candidateK8
    q8 := candidateQ8

v1 = eligible1 and not na(s1) and not na(k1) and not na(q1)
v2 = eligible2 and not na(s2) and not na(k2) and not na(q2)
v3 = eligible3 and not na(s3) and not na(k3) and not na(q3)
v4 = eligible4 and not na(s4) and not na(k4) and not na(q4)
v5 = eligible5 and not na(s5) and not na(k5) and not na(q5)
v6 = eligible6 and not na(s6) and not na(k6) and not na(q6)
v7 = eligible7 and not na(s7) and not na(k7) and not na(q7)
v8 = eligible8 and not na(s8) and not na(k8) and not na(q8)
current1 = v1 and fresh1
current2 = v2 and fresh2
current3 = v3 and fresh3
current4 = v4 and fresh4
current5 = v5 and fresh5
current6 = v6 and fresh6
current7 = v7 and fresh7
current8 = v8 and fresh8
stale1 = v1 and not current1
stale2 = v2 and not current2
stale3 = v3 and not current3
stale4 = v4 and not current4
stale5 = v5 and not current5
stale6 = v6 and not current6
stale7 = v7 and not current7
stale8 = v8 and not current8

//------------------------------------------------------------------------------
// Cross-sectional matrix, reliability and focus history
//------------------------------------------------------------------------------
array<string> symbols = array.from(symbol1, symbol2, symbol3, symbol4, symbol5, symbol6, symbol7, symbol8)
array<float> standardized = array.from(s1, s2, s3, s4, s5, s6, s7, s8)
array<float> consistency = array.from(k1, k2, k3, k4, k5, k6, k7, k8)
array<float> quality = array.from(q1, q2, q3, q4, q5, q6, q7, q8)
array<bool> valid = array.from(v1, v2, v3, v4, v5, v6, v7, v8)
array<bool> current = array.from(current1, current2, current3, current4, current5, current6, current7, current8)
array<bool> stale = array.from(stale1, stale2, stale3, stale4, stale5, stale6, stale7, stale8)
array<int> ranks = array.new_int(8, 0)

int activeCount = 0
int currentCount = 0
int staleCount = 0
float sumQuality = 0.0
float sumConsistency = 0.0
for i = 0 to 7
    if array.get(valid, i)
        activeCount += 1
        sumQuality += array.get(quality, i)
        sumConsistency += array.get(consistency, i)
        if array.get(current, i)
            currentCount += 1
        else
            staleCount += 1

basketReady = activeCount >= minimumActive
basketCurrent = currentCount >= minimumActive
basketMean = basketReady ? sumQuality / float(activeCount) : na
basketConsistency = basketReady ? sumConsistency / float(activeCount) : na

for i = 0 to 7
    if array.get(valid, i)
        int rankValue = 1
        float scoreI = array.get(quality, i)
        for j = 0 to 7
            if array.get(valid, j) and array.get(quality, j) > scoreI
                rankValue += 1
        array.set(ranks, i, rankValue)

focusIndex = focusSlot - 1
focusValid = basketReady and array.get(valid, focusIndex)
focusStandardized = focusValid ? array.get(standardized, focusIndex) : na
focusConsistency = focusValid ? array.get(consistency, focusIndex) : na
focusQuality = focusValid ? array.get(quality, focusIndex) : na
focusRank = focusValid ? array.get(ranks, focusIndex) : 0
focusRelative = focusValid ? f_clamp(focusQuality - basketMean, -100.0, 100.0) : na
focusCurrent = focusValid and array.get(current, focusIndex)
focusStale = focusValid and array.get(stale, focusIndex)
focusReliable = focusCurrent and focusConsistency >= consistencyFloor
focusColor = not focusReliable ? uncertainColor : focusRelative > 0.0 ? bullColor : focusRelative < 0.0 ? bearColor : neutralColor

uncertaintyWidth = focusValid ? 4.0 + 22.0 * (1.0 - focusConsistency) : na
haloUpper = focusValid ? math.min(100.0, focusRelative + uncertaintyWidth) : na
haloLower = focusValid ? math.max(-100.0, focusRelative - uncertaintyWidth) : na
rankRail = showRankRail and focusValid ? -100.0 + 25.0 * (float(activeCount - focusRank) / math.max(float(activeCount - 1), 1.0)) : na

//------------------------------------------------------------------------------
// Visual system
//------------------------------------------------------------------------------
hline(0.0, "Basket center", color=color.new(neutralColor, 52), linestyle=hline.style_dotted)
hline(50.0, "Upper context", color=color.new(neutralColor, 92))
hline(-50.0, "Lower context", color=color.new(neutralColor, 92))
hline(100.0, "Upper bound", color=color.new(neutralColor, 96))
hline(-100.0, "Lower bound", color=color.new(neutralColor, 96))

upperPlot = plot(showHalo ? haloUpper : na, "Consistency Halo Upper", color=color.new(focusColor, 100))
lowerPlot = plot(showHalo ? haloLower : na, "Consistency Halo Lower", color=color.new(focusColor, 100))
fill(upperPlot, lowerPlot, color=showHalo and focusValid ? color.new(focusColor, 84) : na, title="Consistency Halo")
plot(focusRelative, "Focus Relative Strength Halo", color=focusValid ? color.new(focusColor, 78) : na, linewidth=8)
plot(focusRelative, "Focus Relative Strength", color=focusValid ? focusColor : na, linewidth=3)
plot(rankRail, "Focus Rank Rail", color=color.new(focusColor, 18), style=plot.style_columns, histbase=-100.0)
bgcolor(showStateWash and focusValid and math.abs(focusRelative) >= 18.0 ? color.new(focusColor, 93) : na, title="Relative State Wash")

//------------------------------------------------------------------------------
// Matrix dashboard
//------------------------------------------------------------------------------
f_short_symbol(string value) =>
    length = str.length(value)
    length <= 9 ? value : str.substring(value, length - 9, length)

f_heat_color(float delta, float reliability) =>
    intensity = f_clamp(math.abs(delta) / 80.0, 0.0, 1.0) * f_clamp(reliability, 0.0, 1.0)
    transparency = int(math.round(92.0 - 62.0 * intensity))
    delta > 0.0 ? color.new(bullColor, transparency) : delta < 0.0 ? color.new(bearColor, transparency) : color.new(neutralColor, 90)

var table matrix = table.new(position.top_right, 10, 9, border_width=1)
if barstate.islast
    if showMatrix
        headerBg = color.rgb(37, 43, 55)
        bodyBg = color.new(color.black, 22)
        coverageText = staleCount > 0 ? "REL | " + str.tostring(staleCount) + " STALE" : "REL | LIVE"
        table.cell(matrix, 0, 0, coverageText, text_color=color.white, bgcolor=headerBg)
        for column = 0 to 7
            table.cell(matrix, column + 1, 0, f_short_symbol(array.get(symbols, column)), text_color=color.white, bgcolor=headerBg)
        table.cell(matrix, 9, 0, "RANK / DATA", text_color=color.white, bgcolor=headerBg)
        for row = 0 to 7
            rowValid = array.get(valid, row)
            rowStale = array.get(stale, row)
            rowSymbol = array.get(symbols, row)
            rowScore = array.get(standardized, row)
            rowConsistency = array.get(consistency, row)
            rowTextColor = rowValid and not rowStale ? color.white : neutralColor
            table.cell(matrix, 0, row + 1, f_short_symbol(rowSymbol), text_color=rowTextColor, bgcolor=headerBg)
            for column = 0 to 7
                columnValid = array.get(valid, column)
                pairStale = rowStale or array.get(stale, column)
                pairValid = rowValid and columnValid
                delta = pairValid ? rowScore - array.get(standardized, column) : na
                cellText = row == column and rowValid ? "--" : pairValid ? str.tostring(delta, "#.0") : "n/a"
                pairReliability = pairValid ? math.min(rowConsistency, array.get(consistency, column)) * (pairStale ? 0.45 : 1.0) : 0.0
                cellBg = row == column ? color.new(neutralColor, 86) : pairValid ? f_heat_color(delta, pairReliability) : bodyBg
                table.cell(matrix, column + 1, row + 1, cellText, text_color=pairValid ? color.white : neutralColor, bgcolor=cellBg)
            dataState = rowStale ? "STALE" : "LIVE"
            rankText = rowValid ? "#" + str.tostring(array.get(ranks, row)) + " | " + str.tostring(100.0 * rowConsistency, "#") + "% | " + dataState : "n/a"
            rankBg = row == focusIndex and rowValid ? color.new(focusColor, 34) : bodyBg
            table.cell(matrix, 9, row + 1, rankText, text_color=rowTextColor, bgcolor=rankBg)
    else
        table.clear(matrix, 0, 0, 9, 8)

//------------------------------------------------------------------------------
// Confirmed alerts
//------------------------------------------------------------------------------
alertReady = barstate.isconfirmed and basketCurrent and focusCurrent
enteredTopTwo = alertReady and focusRank <= 2 and nz(focusRank[1], 9) > 2
enteredBottomTwo = alertReady and focusRank >= activeCount - 1 and nz(focusRank[1], 0) < nz(activeCount[1], activeCount) - 1
crossedAboveBasket = ta.crossover(focusRelative, 0.0) and alertReady
crossedBelowBasket = ta.crossunder(focusRelative, 0.0) and alertReady
lostConsistency = alertReady and focusConsistency < consistencyFloor and nz(focusConsistency[1], 1.0) >= consistencyFloor

alertcondition(enteredTopTwo, "Focus asset entered top two", "The completed bar moved the focus asset into the top two consistency-weighted ranks.")
alertcondition(enteredBottomTwo, "Focus asset entered bottom two", "The completed bar moved the focus asset into the bottom two consistency-weighted ranks.")
alertcondition(crossedAboveBasket, "Focus asset crossed above basket", "The completed bar moved the focus asset relative strength above the active basket center.")
alertcondition(crossedBelowBasket, "Focus asset crossed below basket", "The completed bar moved the focus asset relative strength below the active basket center.")
alertcondition(lostConsistency, "Focus asset consistency weakened", "The completed bar moved the focus asset path consistency below the configured reliability floor.")
````
