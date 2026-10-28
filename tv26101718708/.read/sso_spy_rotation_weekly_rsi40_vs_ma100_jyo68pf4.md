# SSO / SPY Rotation - Weekly RSI(40) vs MA(100)

- url: https://www.tradingview.com/script/JYo68pF4-SSO-SPY-Rotation-Weekly-RSI-40-vs-MA-100/
- type: indicator
- pine_id: PUB;be7f056e390c4cf888914e31fd339c4b
- version: 1.0

## Description

This signal uses moving averages to assist in tracking buy and sell signals using momentum in price action.

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
if (barstate.islast)
    label.delete(signalLabel)
    signalText = longSSO ? "SSO (Risk ON)" : "SPY (Risk OFF)"
    signalLabel := label.new(bar_index, high, signalText, style=label.style_label_down)
````
