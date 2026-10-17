# Trend-Reset Cumulative Delta [ChartPrime]

- url: https://www.tradingview.com/script/KoXIqM5l-Trend-Reset-Cumulative-Delta-ChartPrime/
- type: indicator
- pine_id: PUB;93b08b314d6a44889f8267a1b8dd40f7
- version: 1.0

## Description

[b]Trend-Reset Cumulative Delta [ChartPrime][/b]

[b]🔶 OVERVIEW[/b]

Standard Cumulative Delta indicators track the net difference between buying and selling volume from a fixed starting point (like the start of the day). While useful, they often become skewed by historical data that is no longer relevant to the current market trend.

The [b]Trend-Reset Cumulative Delta[/b] solves this by using a [b]Volatility-Based Reset Mechanism[/b]. It utilizes an ATR (Average True Range) envelope to define the current trend; the moment price breaks out of this envelope, the Cumulative Delta "resets." This ensures you are only seeing the volume pressure relevant to the [i]active[/i] trend.



[b]🔶 THE RESET LOGIC: ATR BANDS[/b]

The indicator tracks a central EMA surrounded by volatility bands. This creates a "dynamic corridor" for price:

[list]
[*] [b]Bullish Trend:[/b] When price closes above the [b]Upper ATR Band[/b], the trend turns bullish and the Delta counter resets to 0.
[*] [b]Bearish Trend:[/b] When price closes below the [b]Lower ATR Band[/b], the trend turns bearish and the Delta counter resets to 0.
[/list]

By resetting at every major trend shift, the indicator highlights the "fresh" volume entering the move, making it easier to spot exhaustion or trend strength without the baggage of old data.

[b]🔶 KEY FEATURES[/b]

[list]
[*] [b]Z-Score Pivot Filter:[/b] Not all pivots are equal. This indicator uses a Z-Score calculation to identify "outlier" volume events. It highlights pivots where the Cumulative Delta is significantly higher (statistically) than the recent average.
[*] [b]Trend Summary Labels:[/b] At the end of every trend cycle, a label appears summarizing the [b]Total Volume[/b] and [b]Net Delta[/b] of that specific move. This allows you to compare the "effort vs. result" of previous trends side-by-side.
[*] [b]Dual-Chart Projection:[/b] Filtered volume pivots can be projected directly onto the price chart, showing you exactly which candle saw a statistical volume extreme.
[*] [b]Dynamic Column Coloring:[/b] 
    * [b]Bright Colors:[/b] Volume is increasing in the direction of the trend.
    * [b]Faded Colors:[/b] Volume pressure is slowing down (potential divergence/exhaustion).
[/list]

[b]🔶 TRADING APPLICATIONS[/b]

[list]
[*] [b]Effort vs. Result (Divergence):[/b] If price is making new trend highs but the [b]Trend-Reset Delta[/b] columns are becoming smaller or fading in color, it indicates that the "effort" (volume) is not supporting the move.
[*] [b]Institutional Absorption:[/b] Look for the [b]Z-Score Pivot[/b] markers (▼/▲). When these appear at structural support or resistance, it signifies that a massive amount of volume was transacted, often indicating institutional absorption.
[*] [b]Trend Strength Comparison:[/b] Use the Trend Summary Labels to look back at previous cycles. If the previous Bullish trend had a Net Delta of +1M and the current Bullish trend only has +200k, the current move is significantly more fragile.
[/list]

[b]🔶 CONCLUSION[/b]

The [b]Trend-Reset Cumulative Delta [ChartPrime][/b] provides a cleaner, more actionable view of volume flow. By stripping away irrelevant historical volume and focusing on the current volatility-defined trend, it helps traders identify when a trend is being fueled by fresh capital—or when it's simply running on fumes.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime

//@version=6
indicator('Trend-Reset Cumulative Delta [ChartPrime]', shorttitle = 'TR-Cumulative Delta  [ChartPrime]', overlay = false, max_labels_count = 500)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

grp_trend = 'Trend Settings'
emaLen = input.int(50, 'Base EMA Length', minval = 1, group = grp_trend, tooltip = 'Central EMA lookback.')
atrLen = input.int(14, 'ATR Length', minval = 1, group = grp_trend, tooltip = 'ATR period for volatility.')
atrMult = input.float(2.0, 'ATR Multiplier', step = 0.1, group = grp_trend, tooltip = 'ATR multiplier for bands.')
src = input.source(close, 'Source', group = grp_trend)

grp_piv = 'Pivot Settings'
pivotLeft = 15
pivotRight = 1
zThreshold = input.float(2.0, 'Z-Score Threshold', step = 0.1, group = grp_piv, tooltip = 'Only show pivots where Delta is X standard deviations away from the mean.')
zLen = input.int(20, 'Z-Score Lookback', minval = 1, group = grp_piv, tooltip = 'Lookback period for calculating the moving average and standard deviation.')
showPricePiv = input.bool(true, 'Project Pivots to Price Chart', group = grp_piv)

grp_vol = 'Volume & Labels'
showLabels = input.bool(true, 'Show Trend Summary Labels', group = grp_vol)

grp_color = 'Visuals'
upColor = input.color(#12bb9f, 'Bullish Color', group = grp_color)
downColor = input.color(#8b12bb, 'Bearish Color', group = grp_color)
labelTxtCol = input.color(color.white, 'Label Text Color', group = grp_color)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{

//  ATR Trend Logic 
baseEma = ta.ema(src, emaLen)
atrValue = ta.atr(atrLen)
upperBand = baseEma + atrValue * atrMult
lowerBand = baseEma - atrValue * atrMult

var int trendState = 0
if src > upperBand
    trendState := 1
    trendState
else if src < lowerBand
    trendState := -1
    trendState

trendChanged = ta.change(trendState) != 0

//  Cumulative Delta Logic 
barDelta = close > open ? volume : -volume
var float cumDelta = 0.0
var float totalVol = 0.0

if trendChanged
    cumDelta := barDelta
    totalVol := volume
    totalVol
else
    cumDelta := cumDelta + barDelta
    totalVol := totalVol + volume
    totalVol

//  Z-Score Calculation 
// We calculate Z-Score on the Cumulative Delta to find outliers
meanDelta = ta.sma(cumDelta, zLen)
stdDelta = ta.stdev(cumDelta, zLen)
zScore = (cumDelta - meanDelta) / stdDelta

//  Pivot Detection with Z-Score Filter 
phRaw = ta.pivothigh(cumDelta, pivotLeft, pivotRight)
plRaw = ta.pivotlow(cumDelta, pivotLeft, pivotRight)

// Filter: Pivot must exist AND Z-Score must exceed threshold at the time of the pivot bar
// Note: phRaw occurs 'pivotRight' bars ago
ph = not na(phRaw) and math.abs(zScore[pivotRight]) >= zThreshold ? phRaw : na
pl = not na(plRaw) and math.abs(zScore[pivotRight]) >= zThreshold ? plRaw : na


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{

//  1. Historical Trend Labels 
if trendChanged and showLabels
    lblColor = trendState[1] == 1 ? upColor : downColor
    txt = 'Total: ' + str.tostring(totalVol[1], format.volume) + '\nDelta: ' + str.tostring(cumDelta[1], format.volume)
    label.new(bar_index[1], cumDelta[1], text = txt, color = lblColor, textcolor = labelTxtCol, style = cumDelta[1] > 0 ? label.style_label_down : label.style_label_up, size = size.small)

//  2. Filtered Pivot Labels 
if not na(ph) and cumDelta > 0
    label.new(bar_index - pivotRight, ph, str.tostring(cumDelta, '#.#') + '\n▼', color = color.new(upColor, 100), textcolor = labelTxtCol, style = label.style_label_down, size = size.tiny)
    if showPricePiv
        label.new(bar_index - pivotRight, high[pivotRight], '▼', color = color.new(upColor, 100), textcolor = color.new(upColor, 20), style = label.style_label_down, size = size.small, force_overlay = true)

if not na(pl) and cumDelta < 0
    label.new(bar_index - pivotRight, pl, '▲\n' + str.tostring(cumDelta, '#.#'), color = color.new(downColor, 100), textcolor = labelTxtCol, style = label.style_label_up, size = size.tiny)
    if showPricePiv
        label.new(bar_index - pivotRight, low[pivotRight], '▲', color = color.new(downColor, 100), textcolor = color.new(downColor, 20), style = label.style_label_up, size = size.small, force_overlay = true)

// 3. Oscillator Plots 
hline(0, 'Zero Line', color = color.new(color.gray, 50))
plotColor = trendState == 1 ? upColor : downColor
plot(trendChanged ? na : cumDelta, 'Trend Delta', color = cumDelta < 0 ? cumDelta < cumDelta[1] ? downColor : color.new(downColor, 30) : cumDelta > cumDelta[1] ? upColor : color.new(upColor, 30), style = plot.style_columns)

// 4. Trend Boundary & Fill 
trend_band = trendChanged ? na : trendState == 1 ? lowerBand : upperBand
band = plot(trend_band, 'Trend Boundary', color = plotColor, linewidth = 2, force_overlay = true, style = plot.style_linebr)
price = plot(hl2, 'Price Ref', display = display.none, editable = false, force_overlay = true)
fill(band, price, trend_band, hl2, color.new(plotColor, 85), color.new(plotColor, 100))

//  5. Realtime Label 
var label liveLabel = label.new(na, na, '', style = label.style_label_left, textcolor = labelTxtCol, size = size.normal)
if barstate.islast
    label.set_xy(liveLabel, bar_index + 2, cumDelta)
    label.set_text(liveLabel, 'LIVE TREND\nDelta: ' + str.tostring(cumDelta, format.volume) + '\nTotal: ' + str.tostring(totalVol, format.volume))
    label.set_color(liveLabel, trendState == 1 ? upColor : downColor)

bgcolor(trendChanged ? color.new(color.yellow, 85) : na)
plot(ta.sma(cumDelta, 10), color = color.new(chart.fg_color, 70), title = 'Avg Delta')
// --------------------------------------------------------------------------------------------------------------------}
````
