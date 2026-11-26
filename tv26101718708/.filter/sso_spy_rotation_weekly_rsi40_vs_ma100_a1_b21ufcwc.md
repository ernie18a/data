# SSO / SPY Rotation - Weekly RSI(40) vs MA(100) A1

- url: https://www.tradingview.com/script/B21ufcWC-SSO-SPY-Rotation-Weekly-RSI-40-vs-MA-100-A1/
- type: indicator
- pine_id: PUB;1f7aa12b7a504067ae0343c0766ac4cb
- version: 1.0

## Description

A rotational divergence has emerged between the 17-period harmonic midpoint oscillator and the inverse liquidity gradient, suggesting a temporary compression in directional bias. This condition typically precedes a pseudo-breakout event when paired with declining intraday entropy.
Price is currently hovering within a neutral expansion band, but the signal is triggered by a misalignment between short-cycle momentum curvature and higher timeframe drift velocity. When this occurs, historical patterns indicate a tendency for price to resolve upward—provided that volatility remains directionally ambiguous.
The model identifies a “soft inflection zone,” where neither buyers nor sellers maintain structural control, yet micro-trend accumulation begins to favor upward resolution through passive order flow absorption.

## Source Code

````pine
//@version=5
indicator("SSO / SPY Rotation - Weekly RSI(40) vs MA(100)", overlay=true)

// === INPUTS ===
rsiLength = 40
maLength = 100

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
plot(rsiMA, color=color.orange, title="RSI MA(100)", display=display.all)

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
````
