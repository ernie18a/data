# 10% Upside / Downside Trade Signal

- url: https://www.tradingview.com/script/0fpgS9a2-10-Upside-Downside-Trade-Signal/
- type: indicator
- pine_id: PUB;bd0c30ee4b5043c99a52b5cdae31f9ad
- version: 1.0

## Description

For QQQ / IWM options, I would use this on:

5-minute chart

Good for quick entries
More signals
More false signals

15-minute chart

Better quality signals
Better for 0DTE and weekly options
My preferred timeframe for your style

1-hour chart

Best for 7-day to 30-day options
Fewer signals
Better for catching bigger moves
How I would use this

For a call trade, only enter when:

Green BUY 10% signal appears
Price is above both EMAs
Market direction agrees, especially SPY/QQQ
Volume is above average
Option spread is not too wide

For a put trade, only enter when:

Red SELL 10% signal appears
Price is below both EMAs
Breakdown happens with volume
RSI confirms weakness

## Source Code

````pine
//@version=5
indicator("10% Upside / Downside Trade Signal", overlay=true, max_labels_count=500)

// === INPUTS ===
targetPercent = input.float(10.0, "Target %", step=0.5)
stopPercent = input.float(4.0, "Stop Loss %", step=0.5)

emaFastLen = input.int(50, "Fast EMA")
emaSlowLen = input.int(200, "Slow EMA")

rsiLen = input.int(14, "RSI Length")
rsiBullMin = input.int(55, "Bullish RSI Minimum")
rsiBearMax = input.int(45, "Bearish RSI Maximum")

volumeLen = input.int(20, "Volume Average Length")
breakoutLen = input.int(20, "Breakout / Breakdown Lookback")

useMacd = input.bool(true, "Use MACD Confirmation")
useVolume = input.bool(true, "Use Volume Confirmation")

// === CALCULATIONS ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

rsi = ta.rsi(close, rsiLen)

avgVolume = ta.sma(volume, volumeLen)
volumeStrong = volume > avgVolume

[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

macdBull = macdLine > signalLine and histLine > 0
macdBear = macdLine < signalLine and histLine < 0

recentHigh = ta.highest(high, breakoutLen)[1]
recentLow = ta.lowest(low, breakoutLen)[1]

breakout = close > recentHigh
breakdown = close < recentLow

// === TREND CONDITIONS ===
bullTrend = close > emaFast and close > emaSlow and emaFast > emaSlow
bearTrend = close < emaFast and close < emaSlow and emaFast < emaSlow

// === MOMENTUM CONDITIONS ===
bullMomentum = rsi >= rsiBullMin and rsi < 75
bearMomentum = rsi <= rsiBearMax and rsi > 25

// === CONFIRMATION CONDITIONS ===
bullConfirmBase = bullTrend and bullMomentum and breakout
bearConfirmBase = bearTrend and bearMomentum and breakdown

bullConfirmMacd = useMacd ? macdBull : true
bearConfirmMacd = useMacd ? macdBear : true

bullConfirmVolume = useVolume ? volumeStrong : true
bearConfirmVolume = useVolume ? volumeStrong : true

bullConfirm = bullConfirmBase and bullConfirmMacd and bullConfirmVolume
bearConfirm = bearConfirmBase and bearConfirmMacd and bearConfirmVolume

// === SIGNAL CONTROL ===
bullSignal = bullConfirm and not bullConfirm[1]
bearSignal = bearConfirm and not bearConfirm[1]

// === TARGETS AND STOPS ===
bullTarget = close * (1 + targetPercent / 100)
bullStop = close * (1 - stopPercent / 100)

bearTarget = close * (1 - targetPercent / 100)
bearStop = close * (1 + stopPercent / 100)

// === PLOTS ===
plot(emaFast, title="50 EMA", linewidth=2)
plot(emaSlow, title="200 EMA", linewidth=2)

plotshape(bullSignal, title="Bullish 10% Setup", style=shape.labelup, location=location.belowbar, text="BUY 10%", size=size.small, color=color.green, textcolor=color.white)
plotshape(bearSignal, title="Bearish 10% Setup", style=shape.labeldown, location=location.abovebar, text="SELL 10%", size=size.small, color=color.red, textcolor=color.white)

plot(bullSignal ? bullTarget : na, title="Bullish 10% Target", style=plot.style_linebr, linewidth=2, color=color.green)
plot(bullSignal ? bullStop : na, title="Bullish Stop", style=plot.style_linebr, linewidth=2, color=color.red)

plot(bearSignal ? bearTarget : na, title="Bearish 10% Target", style=plot.style_linebr, linewidth=2, color=color.green)
plot(bearSignal ? bearStop : na, title="Bearish Stop", style=plot.style_linebr, linewidth=2, color=color.red)

// === LABELS ===
if bullSignal
    label.new(bar_index, low, "BULLISH SETUP\nEntry: " + str.tostring(close, format.mintick) + "\nTarget: " + str.tostring(bullTarget, format.mintick) + "\nStop: " + str.tostring(bullStop, format.mintick), style=label.style_label_up, color=color.green, textcolor=color.white)

if bearSignal
    label.new(bar_index, high, "BEARISH SETUP\nEntry: " + str.tostring(close, format.mintick) + "\nTarget: " + str.tostring(bearTarget, format.mintick) + "\nStop: " + str.tostring(bearStop, format.mintick), style=label.style_label_down, color=color.red, textcolor=color.white)

// === ALERTS ===
alertcondition(bullSignal, title="Bullish 10% Trade Setup", message="Bullish 10% upside trade setup detected.")
alertcondition(bearSignal, title="Bearish 10% Trade Setup", message="Bearish 10% downside trade setup detected.")
````
