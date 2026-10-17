# Historical Impulse Zones [SMRT Algo]

- url: https://www.tradingview.com/script/76TXutIU-Historical-Impulse-Zones-SMRT-Algo/
- type: indicator
- pine_id: PUB;db1f917c2ce54689bbe5badee3cf8095
- version: 1.0

## Description

Historical Impulse Zones measures how strongly buyers and sellers have been pushing price, using the levels left behind by recent impulse moves. It turns that pressure into a single sentiment reading, colours the candles by the current state and shades the active bullish and bearish reference zones. This helps you see at a glance whether the market is in Positive Flow, Negative Flow or a Stability Phase.

[image]https://www.tradingview.com/x/T47aAevk/[/image]

[b]How It Works[/b]

[list=1]
[*][b]Impulse Detection[/b]: a bullish impulse is recorded when a candle's low gaps above the high from two bars earlier, the middle candle closes above that high, and the gap is larger than ATR × Impulse ATR Multiplier. A bearish impulse is the mirror image. Small gaps below the ATR filter are ignored.
[*][b]Reference Levels[/b]: the levels from the most recent impulses (up to the Reference Lookback) are averaged into one bullish reference level and one bearish reference level. If no impulse has formed yet, the lowest low or highest high of the lookback is used instead.
[*][b]Bull Power and Bear Power[/b]: each side is scored from 0 to 100. 55% of the score comes from how far price has extended away from the reference level within the lookback range. 45% comes from how far the source is from the reference level, measured in ATR.
[*][b]Sentiment[/b]: Bull Power minus Bear Power, smoothed with an EMA. It ranges from -100 to +100.
[*][b]Status[/b]: Sentiment above the Gray Zone Threshold is Positive Flow. Below the negative threshold is Negative Flow. Anything in between is a Stability Phase.
[/list]

[b]What You See on the Chart[/b]

[list]
[*][b]Candle Colours[/b]: teal for Positive Flow, pink for Negative Flow, gray for Stability Phase
[*][b]Bullish Zone[/b]: teal shading between price and the bullish reference level while price trades above it
[*][b]Bearish Zone[/b]: pink shading between price and the bearish reference level while price trades below it
[*][b]Dashboard[/b]: current Sentiment, Status, Bull Power and Bear Power
[/list]

[b]Use Cases[/b]

[list]
[*][b]Pullbacks Within a Trend[/b]: if price pulls back but the status stays Positive Flow (or Negative Flow in a downtrend), the underlying pressure has not shifted. This can help you judge whether a pullback is a potential continuation setup or the start of a change.
[*][b]Pressure Shifts[/b]: a move from Positive Flow through a Stability Phase into Negative Flow (or the reverse) shows the balance of pressure changing over time, rather than on a single candle.
[*][b]Counter Moves[/b]: a brief bullish push inside a bearish phase that never changes the status helps you see that the move did not change the wider pressure.
[*][b]Stability Phases[/b]: gray candles show that neither side has clear control. Many traders use these periods to stand aside or wait for the next directional phase.
[*][b]Directional Moves[/b]: during sustained moves the status stays coloured and the zone shading widens. This helps you follow how far price has moved away from its reference level.
[/list]

[image]https://www.tradingview.com/x/8KdlUrs8/[/image]

[b]How to Use the Settings[/b]

[list]
[*][b]Gray Zone Threshold[/b] sets how strong the sentiment reading must be before it counts as Positive Flow or Negative Flow. Higher values mark more of the chart as Stability Phase, so only stronger directional pressure is coloured.
[/list]

[image]https://www.tradingview.com/x/YW61sSei/[/image]

[list]
[*][b]Impulse ATR Multiplier[/b] sets how large a gap must be, relative to ATR, to count as an impulse. Higher values keep only larger gaps, which changes the reference levels and how sentiment reads. Lower values pick up more, smaller impulses.
[*][b]Reference Lookback[/b] sets how many recent impulses are averaged into each reference level, and the range used for the power calculations. Higher values give steadier levels; lower values react faster.
[*][b]Sentiment Smoothing[/b] sets the EMA length applied to sentiment. Higher values reduce switching between states; lower values respond sooner.
[*][b]ATR Length[/b] is the period used to measure volatility for impulse detection and the power readings.
[*][b]Source[/b] is the price used in the ATR distance component (Close by default).
[*][b]Colours[/b] set the Positive Flow, Negative Flow and Stability Phase colours.
[/list]

[image]https://www.tradingview.com/x/cYEQnvT7/[/image]

[b]Dashboard Settings[/b]

[list]
[*][b]Dashboard[/b]: show or hide the statistics table
[*][b]Location[/b]: Top Right, Bottom Right or Bottom Left
[*][b]Size[/b]: Tiny, Small or Normal
[/list]

[b]Notes and Limitations[/b]

[list]
[*]The script uses only the chart's own data, with no higher-timeframe requests and no future data.
[*]Values on historical bars do not change. On the live bar, Sentiment, Status and candle colour update in real time and are only confirmed when the bar closes.
[*]Readings describe past and current buying and selling pressure. They do not predict future price movement.
[*]Default settings are a starting point. Different markets and timeframes may need different thresholds.
[*]Use this tool alongside your own analysis and risk management. It is not financial advice.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SMRTAlgo

//@version=6
indicator('Historical Impulse Zones [SMRT Algo]', overlay=true, max_bars_back=500, max_boxes_count=500, max_lines_count=500, max_labels_count=100)

groupMain = 'Main Settings'
src = input.source(close, 'Source', display=display.none, group=groupMain)
flatLimit = input.float(1.5, 'Gray Zone Threshold', minval=0, step=0.01, group=groupMain)
atrLength = input.int(14, 'ATR Length', minval=1, group=groupMain)
impulseATR = input.float(0.30, 'Impulse ATR Multiplier', minval=0.05, step=0.05, group=groupMain)
refLookback = input.int(20, 'Reference Lookback', minval=3, group=groupMain)
smoothLength = input.int(3, 'Sentiment Smoothing', minval=1, group=groupMain)
clrBull = input.color(#0df1c6, 'Colors                                      ', inline='1', group=groupMain)
clrBear = input.color(#e91e63, '', inline='1', group=groupMain)
clrGray = input.color(color.gray, '', inline='1', group=groupMain)

groupDashboard = 'DASHBOARD SETTINGS'
showDash = input(true, 'Dashboard', group=groupDashboard)
dashPos = input.string('Top Right', 'Location', options=['Top Right', 'Bottom Right', 'Bottom Left'], group=groupDashboard, display=display.none)
textSize = input.string('Small', 'Size', options=['Tiny', 'Small', 'Normal'], group=groupDashboard, display=display.none)

// variables ----------------------------------------------

var listUp = array.new_float()
var listDown = array.new_float()

// calculations --------------------------------------------

atr = ta.atr(atrLength)
atrSafe = math.max(nz(atr), syminfo.mintick)
fallbackVol = ta.sma(high - low, atrLength)
volBase = math.max(nz(atr, fallbackVol), syminfo.mintick)

upImpulse = low > high[2] and close[1] > high[2] and low - high[2] > volBase * impulseATR
downImpulse = high < low[2] and close[1] < low[2] and low[2] - high > volBase * impulseATR

if upImpulse
    array.unshift(listUp, low)
    if array.size(listUp) > refLookback
        array.pop(listUp)

if downImpulse
    array.unshift(listDown, high)
    if array.size(listDown) > refLookback
        array.pop(listDown)

peakZone = ta.highest(high, refLookback)
floorZone = ta.lowest(low, refLookback)

upRef = array.size(listUp) > 0 ? array.avg(listUp) : na
downRef = array.size(listDown) > 0 ? array.avg(listDown) : na

activeUpRef = na(upRef) ? floorZone : upRef
activeDownRef = na(downRef) ? peakZone : downRef

bullRaw = activeUpRef != 0 ? (peakZone - activeUpRef) / activeUpRef * 100 : 0
bearRaw = activeDownRef != 0 ? (activeDownRef - floorZone) / activeDownRef * 100 : 0

bullForceRaw = math.min(math.max(bullRaw, 0), 100)
bearForceRaw = math.min(math.max(bearRaw, 0), 100)

bullATR = math.max((src - activeUpRef) / atrSafe, 0)
bearATR = math.max((activeDownRef - src) / atrSafe, 0)

bullATRForce = math.min(bullATR * 10, 100)
bearATRForce = math.min(bearATR * 10, 100)

bullForce = bullForceRaw * 0.55 + bullATRForce * 0.45
bearForce = bearForceRaw * 0.55 + bearATRForce * 0.45

rawSentiment = bullForce - bearForce
sentiment = ta.ema(rawSentiment, smoothLength)

flatState = math.abs(sentiment) < flatLimit
bullState = sentiment >= flatLimit
bearState = sentiment <= -flatLimit

trendColor = flatState ? clrGray : bullState ? clrBull : clrBear
trendStatus = flatState ? 'Stability Phase' : bullState ? 'Positive Flow' : 'Negative Flow'

// visuals --------------------------------------------

barcolor(trendColor, editable=false)

plotUpRef = plot(activeUpRef, color=color(na), editable=false)
plotDownRef = plot(activeDownRef, color=color(na), editable=false)
plotsrc = plot(src, color=color(na), editable=false)

middle = math.avg(open, close)

fill(plotsrc, plotUpRef, math.max(middle, upRef), math.min(ta.sma(upRef, 10), upRef), color.new(clrBull, 70), math.max(middle, upRef) <= upRef ? color(na) : color.new(chart.bg_color, 100), display = display.all)
fill(plotsrc, plotDownRef, math.max(ta.sma(downRef, 10), downRef), math.min(middle, downRef), math.min(middle, downRef) >= downRef ? color(na) : color.new(chart.bg_color, 100), color.new(clrBear, 70), display = display.all)

// table ----------------------------------------------------------------------

var table_position = dashPos == 'Bottom Left' ? position.bottom_left : dashPos == 'Top Right' ? position.top_right : position.bottom_right
var table_size = textSize == 'Tiny' ? size.tiny : textSize == 'Small' ? size.small : size.normal

var tabel = table.new(table_position, 5, 5, bgcolor=#1e222d, border_color=#373a46, border_width=1, frame_color=#373a46, frame_width=1)

tbSize = table_size

if showDash
    if barstate.islast
        tabel.cell(0, 0, 'Statistics', text_color=color.white, text_size=tbSize)
        tabel.merge_cells(0, 0, 1, 0)
        tabel.cell(0, 1, 'Sentiment', text_size=tbSize, text_color=#9399a2)
        tabel.cell(1, 1, str.tostring(sentiment, '#.##'), text_size=tbSize, text_color=trendColor)
        tabel.cell(0, 2, 'Status', text_size=tbSize, text_color=#9399a2)
        tabel.cell(1, 2, trendStatus, text_size=tbSize, bgcolor=color.from_gradient(math.abs(sentiment), 0, 100, chart.bg_color, color.new(trendColor, 70)), text_color=trendColor)
        tabel.cell(0, 3, 'Bull Power', text_size=tbSize, text_color=#9399a2)
        tabel.cell(1, 3, str.tostring(bullForce, '#.##'), text_size=tbSize, text_color=clrBull)
        tabel.cell(0, 4, 'Bear Power', text_size=tbSize, text_color=#9399a2)
        tabel.cell(1, 4, str.tostring(bearForce, '#.##'), text_size=tbSize, text_color=clrBear)
````
