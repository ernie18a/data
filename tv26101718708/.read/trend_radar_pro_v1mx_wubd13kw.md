# Trend Radar Pro V1MX

- url: https://www.tradingview.com/script/wUbD13KW/
- type: indicator
- pine_id: PUB;a24a8714b7ed437981f042eafb03d736
- version: 1.0

## Description

Trend Radar Pro

Trend Radar Pro is a trend-following indicator designed to identify the direction and strength of a market trend by combining multiple technical signals into one simple visual panel.

Instead of relying on a single indicator, Trend Radar Pro analyzes several trend, momentum, strength, and higher-timeframe confirmation factors to help determine whether the market is more likely to continue bullish, bearish, or remain in a neutral/choppy condition.

The indicator calculates both a bullish and bearish score using 6 main components:

Fast EMA and Slow EMA to identify trend structure.
Supertrend to confirm dynamic trend direction.
ADX + DI to measure trend strength.
RSI to evaluate momentum.
Linear Regression Slope to detect price direction.
Higher Timeframe Confirmation — HTF to align signals with the broader market context.

The result is displayed in a simple dashboard:

Bull score: 0/6 to 6/6
Bear score: 0/6 to 6/6
ADX
RSI
HTF
Overall bias

When the Bull score is high, the indicator detects stronger bullish alignment.
When the Bear score is high, it detects stronger bearish alignment.
When both scores are mixed, the indicator labels the market as Neutral / Chop, suggesting a possible range, indecision, or low-quality trend environment.

What is it used for?

Trend Radar Pro can help traders:

Identify bullish or bearish trends more clearly.
Avoid low-confirmation or choppy market conditions.
Confirm whether the higher timeframe supports the current direction.
Filter weak signals using ADX, RSI, and Supertrend.
Quickly visualize whether the market is trending or ranging.
Suggested use cases

Trend Radar Pro can be used across different trading styles:

Scalping: 1m, 3m, or 5m charts with 15m or 30m HTF confirmation.
Intraday trading: 15m or 30m charts with 1H or 4H HTF confirmation.
Swing trading: 4H or daily charts with daily or weekly HTF confirmation.

Quick interpretation

Strong Bullish: multiple bullish conditions are aligned.
Strong Bearish: multiple bearish conditions are aligned.
Neutral / Chop: the market is mixed, lacks clear confirmation, or may be ranging.

The early signals early ↑ and early ↓ suggest that a directional bias may be starting to form, but full confirmation is not present yet.

Important note

This indicator does not predict the future and does not guarantee trading results. It is designed to support trend analysis and decision-making, but it should be used together with risk management, market structure, support/resistance levels, and a defined trading strategy.

Trend Radar Pro is not financial advice. It is a technical analysis tool meant to complement your own trading process.

## Source Code

````pine
//@version=6
indicator("Trend Radar Pro - Roberto Edition", overlay=true, max_labels_count=500)

// =====================
// Inputs
// =====================
emaFastLen   = input.int(50, "EMA rápida", minval=1)
emaSlowLen   = input.int(200, "EMA lenta", minval=1)

adxLen       = input.int(14, "ADX length", minval=1)
adxSmooth    = input.int(14, "ADX smoothing", minval=1)
adxMin       = input.float(20.0, "ADX mínimo para tendencia", step=0.5)

rsiLen       = input.int(14, "RSI length", minval=1)
rsiBull      = input.float(55.0, "RSI mínimo alcista", step=0.5)
rsiBear      = input.float(45.0, "RSI máximo bajista", step=0.5)

stAtrLen     = input.int(10, "Supertrend ATR length", minval=1)
stFactor     = input.float(3.0, "Supertrend factor", step=0.1)

linLen       = input.int(50, "Regresión lineal length", minval=5)
htfTf        = input.timeframe("240", "Temporalidad mayor")

scoreMin     = input.int(4, "Score mínimo para señal fuerte", minval=1, maxval=6)
showBg       = input.bool(true, "Colorear fondo")
showLabels   = input.bool(true, "Mostrar etiquetas")

// =====================
// Base calculations
// =====================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

[plusDI, minusDI, adx] = ta.dmi(adxLen, adxSmooth)
rsi = ta.rsi(close, rsiLen)

[superTrend, stDir] = ta.supertrend(stFactor, stAtrLen)
// En TradingView, stDir suele ser -1 para alcista y 1 para bajista.
stBull = stDir < 0
stBear = stDir > 0

linNow  = ta.linreg(close, linLen, 0)
linPrev = ta.linreg(close, linLen, 1)
linSlope = linNow - linPrev

// =====================
// Higher timeframe confirmation
// =====================
htfClose   = request.security(syminfo.tickerid, htfTf, close)
htfEmaFast = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaFastLen))
htfEmaSlow = request.security(syminfo.tickerid, htfTf, ta.ema(close, emaSlowLen))

htfBull = htfClose > htfEmaFast and htfEmaFast > htfEmaSlow
htfBear = htfClose < htfEmaFast and htfEmaFast < htfEmaSlow

// =====================
// Trend conditions
// =====================
emaBull = close > emaFast and emaFast > emaSlow
emaBear = close < emaFast and emaFast < emaSlow

adxBull = adx >= adxMin and plusDI > minusDI
adxBear = adx >= adxMin and minusDI > plusDI

rsiMomentumBull = rsi >= rsiBull
rsiMomentumBear = rsi <= rsiBear

slopeBull = linSlope > 0
slopeBear = linSlope < 0

// =====================
// Score system
// =====================
bullScore = 0
bullScore += emaBull ? 1 : 0
bullScore += stBull ? 1 : 0
bullScore += adxBull ? 1 : 0
bullScore += rsiMomentumBull ? 1 : 0
bullScore += slopeBull ? 1 : 0
bullScore += htfBull ? 1 : 0

bearScore = 0
bearScore += emaBear ? 1 : 0
bearScore += stBear ? 1 : 0
bearScore += adxBear ? 1 : 0
bearScore += rsiMomentumBear ? 1 : 0
bearScore += slopeBear ? 1 : 0
bearScore += htfBear ? 1 : 0

trendScore = bullScore - bearScore

strongBull = bullScore >= scoreMin and bullScore > bearScore
strongBear = bearScore >= scoreMin and bearScore > bullScore

earlyBull = bullScore >= 3 and trendScore > trendScore[1] and not strongBull[1]
earlyBear = bearScore >= 3 and trendScore < trendScore[1] and not strongBear[1]

// =====================
// Plots
// =====================
plot(emaFast, "EMA rápida", color=color.new(color.teal, 0), linewidth=2)
plot(emaSlow, "EMA lenta", color=color.new(color.orange, 0), linewidth=2)
plot(superTrend, "Supertrend", color=stBull ? color.new(color.lime, 0) : color.new(color.red, 0), linewidth=2)

bgColor = strongBull ? color.new(color.green, 88) : strongBear ? color.new(color.red, 88) : color.new(color.gray, 95)
bgcolor(showBg ? bgColor : na)

barcolor(strongBull ? color.new(color.green, 0) : strongBear ? color.new(color.red, 0) : na)

plotshape(strongBull and not strongBull[1], title="Señal alcista fuerte", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="TREND ↑")
plotshape(strongBear and not strongBear[1], title="Señal bajista fuerte", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="TREND ↓")

plotshape(earlyBull and not strongBull, title="Alerta temprana alcista", style=shape.circle, location=location.belowbar, color=color.new(color.green, 35), size=size.tiny, text="early ↑")
plotshape(earlyBear and not strongBear, title="Alerta temprana bajista", style=shape.circle, location=location.abovebar, color=color.new(color.red, 35), size=size.tiny, text="early ↓")

// =====================
// Labels
// =====================
if showLabels and barstate.islast
    labelText = "Trend Radar Pro\n" +
      "Bull score: " + str.tostring(bullScore) + "/6\n" +
      "Bear score: " + str.tostring(bearScore) + "/6\n" +
      "ADX: " + str.tostring(adx, "#.##") + "\n" +
      "RSI: " + str.tostring(rsi, "#.##") + "\n" +
      "HTF: " + (htfBull ? "Bull" : htfBear ? "Bear" : "Neutral") + "\n" +
      "Sesgo: " + (strongBull ? "ALCISTA FUERTE" : strongBear ? "BAJISTA FUERTE" : "NEUTRAL / CHOP")

    labelColor = strongBull ? color.green : strongBear ? color.red : color.gray

    label.new(
      bar_index,
      high,
      labelText,
      style=label.style_label_down,
      color=color.new(labelColor, 10),
      textcolor=color.white
    )

// =====================
// Alerts
// =====================
alertcondition(strongBull and not strongBull[1], "Trend Radar Pro - Alcista fuerte", "Señal alcista fuerte detectada")
alertcondition(strongBear and not strongBear[1], "Trend Radar Pro - Bajista fuerte", "Señal bajista fuerte detectada")
alertcondition(earlyBull, "Trend Radar Pro - Alerta temprana alcista", "Posible inicio de sesgo alcista")
alertcondition(earlyBear, "Trend Radar Pro - Alerta temprana bajista", "Posible inicio de sesgo bajista")
````
