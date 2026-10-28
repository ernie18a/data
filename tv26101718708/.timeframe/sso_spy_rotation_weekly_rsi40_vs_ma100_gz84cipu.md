# SSO / SPY Rotation - Weekly RSI(40) vs MA(100)

- url: https://www.tradingview.com/script/Gz84cIpu-SSO-SPY-Rotation-Weekly-RSI-40-vs-MA-100/
- type: indicator
- pine_id: PUB;0d0f8fe29c6c41338a8ffbfa87a87fb0
- version: 1.0

## Description

This is a strategy that uses moving averages to provide guidance on when to sell and buy certain positions.

## Source Code

````pine
//@version=5
indicator("SSO / SPY Rotation - Weekly RSI(40) vs MA(100)", overlay=true)

// === INPUTS ===
rsiLength = 40
maLength = 120

// === WEEKLY DATA (REAL-TIME) ===
weeklyClose = request.security(syminfo.tickerid, "W", close, lookahead=barmerge.lookahead_on)

// === RSI CALCULATION ===
weeklyRSI = ta.rsi(weeklyClose, rsiLength)
rsiMA = ta.sma(weeklyRSI, maLength)

// === SIGNALS ===
longSSO = weeklyRSI > rsiMA
longSPY = weeklyRSI <= rsiMA

// === PLOTS ===
plot(weeklyRSI, color=color.blue, title="Weekly RSI(40)")
plot(rsiMA, color=color.orange, title="RSI MA(100)")

// === BACKGROUND ===
bgcolor(longSSO ? color.new(color.green, 85) : color.new(color.red, 85))

// === SIGNAL LABEL ===
var label signalLabel = na
if barstate.islast
    label.delete(signalLabel)
    signalText = longSSO ? "SSO (Risk ON)" : "SPY (Risk OFF)"
    signalLabel := label.new(bar_index, high, signalText, style=label.style_label_down)

// === ALERTS ===
if ta.crossover(weeklyRSI, rsiMA)
    alert('{"ticker": "' + syminfo.ticker + '", "signal": "RISK_ON"}', alert.freq_once_per_bar_close)

if ta.crossunder(weeklyRSI, rsiMA)
    alert('{"ticker": "' + syminfo.ticker + '", "signal": "RISK_OFF"}', alert.freq_once_per_bar_close)
    alert('{"ticker": "' + syminfo.ticker + '", "signal": "RISK_ON"}', alert.freq_once_per_bar_close)
````
