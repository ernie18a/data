# Squeeze Momentum Setup Assistant

- url: https://www.tradingview.com/script/HeCf2CBM-Squeeze-Momentum-Setup-Assistant/
- type: indicator
- pine_id: PUB;8779ffae83d44df28663d5a7b661e5f2
- version: 1.0

## Description

[image]https://www.tradingview.com/x/eKtzl6JI/[/image]

BB/KC squeeze detection with MA trend signals, RSI filtering, and ATR-based stop/target levels.

Squeeze Momentum Setup Assistant is a hybrid volatility and trend-confirmation tool designed to help traders identify potential breakout setups, trend shifts, and ATR-based risk levels directly on the chart.

The indicator combines Bollinger Bands and Keltner Channels to detect squeeze conditions. A squeeze occurs when the Bollinger Bands contract inside the Keltner Channels, suggesting a period of reduced volatility and possible energy buildup.

When the squeeze releases, the script uses a simple momentum calculation to classify the potential breakout direction:

- SqueezeUp appears when volatility releases with positive momentum.
- SqueezeDown appears when volatility releases with negative momentum.

In addition to squeeze detection, the indicator includes a moving average crossover system with RSI filtering:

- A Call signal appears when the short moving average crosses above the long moving average while RSI remains below the overbought zone.
- A Put signal appears when the short moving average crosses below the long moving average while RSI remains above the oversold zone.

For each Call or Put setup, the indicator automatically calculates ATR-based stop and target levels. This helps traders visualize potential risk and reward zones without manually measuring volatility.

Key features:

- Bollinger Band and Keltner Channel squeeze detection
- Squeeze release direction labels
- Moving average crossover signals
- RSI-based signal filtering
- ATR-based stop loss and target projections
- Visual trend and volatility structure on the chart

This tool is designed for traders who want to combine volatility compression, momentum release, trend confirmation, and risk planning in one visual framework.

Best used with market structure, VWAP, support and resistance, volume confirmation, and higher timeframe trend context.

Important:
This indicator does not predict future price movement and should not be used as a standalone trading system. Squeeze releases can fail, moving average crossovers can lag, and ATR levels are only volatility-based reference zones. Always use proper risk management and additional confirmation.

A hybrid squeeze and trend setup assistant that combines BB/KC volatility compression, momentum release direction, MA crossover signals, RSI filtering, and ATR-based stop/target levels.
How it works:

The indicator first compares Bollinger Bands against Keltner Channels to detect volatility compression. When the Bollinger Bands move inside the Keltner Channels, the market is considered to be in a squeeze.

When the squeeze releases, momentum is used to estimate the possible breakout direction.

Separately, the script evaluates short and long moving average crossovers with RSI filtering to identify possible Call and Put setups.

When a Call or Put condition appears, the indicator calculates projected stop and target levels using ATR, allowing traders to quickly visualize volatility-adjusted risk zones.

Inputs:

BB Length:
Controls the Bollinger Band lookback period.

BB Multiplier:
Controls the width of the Bollinger Bands.

KC ATR Length:
Controls the ATR length used for the Keltner Channel calculation.

KC Multiplier:
Controls the width of the Keltner Channels.

Momentum Length:
Controls the lookback period used to estimate squeeze release direction.

Short MA Length:
Controls the fast moving average used for crossover signals.

Long MA Length:
Controls the slow moving average used for crossover signals.

RSI Length:
Controls the RSI filter used to avoid extreme overbought or oversold entries.

ATR Length for SL/Target:
Controls the ATR calculation used for stop and target projections.

Target Multiplier:
Defines how far the projected target is placed from the signal price using ATR.

Stop Loss Multiplier:
Defines how far the projected stop is placed from the signal price using ATR.

## Source Code

````pine
//@version=5
indicator("Squeeze Momentum Setup Assistant", overlay=true)

// Configuración de Bandas de Bollinger
lengthBB = input(20, title="BB Length")
multBB = input(2.0, title="BB Multiplier")
basisBB = ta.sma(close, lengthBB)
devBB = multBB * ta.stdev(close, lengthBB)
upperBB = basisBB + devBB
lowerBB = basisBB - devBB

// Configuración de Canales de Keltner
atrLengthKC = input(20, title="KC ATR Length")
atrMultKC = input(1.5, title="KC Multiplier")
kcBasis = ta.sma(close, lengthBB)
atrKC = ta.atr(atrLengthKC)
upperKC = kcBasis + atrMultKC * atrKC
lowerKC = kcBasis - atrMultKC * atrKC

// Cálculo del Squeeze (cuando BB está dentro de KC)
isSqueeze = upperBB < upperKC and lowerBB > lowerKC
bgcolor(isSqueeze ? color.red : na, transp=90)

// Plotear Bandas de Bollinger y Canales de Keltner
plot(upperBB, "Upper BB", color=color.blue)
plot(lowerBB, "Lower BB", color=color.blue)
plot(upperKC, "Upper KC", color=color.orange)
plot(lowerKC, "Lower KC", color=color.orange)

// Cálculo del Momentum (oscilador) para predecir la dirección
momentumLength = input(14, title="Momentum Length")
momentum = ta.sma(close - ta.sma(close, momentumLength), momentumLength)

// Identificación de la salida del squeeze
squeezeReleased = not isSqueeze and isSqueeze[1]
squeezeDirectionUp = squeezeReleased and momentum > 0
squeezeDirectionDown = squeezeReleased and momentum < 0

// Señales en el gráfico con flechas de dirección
plotshape(series=squeezeDirectionUp, title="Squeeze Breakout Up", location=location.belowbar, color=color.green, style=shape.labelup, size=size.small, text="SqueezeUp", textcolor=color.white)
plotshape(series=squeezeDirectionDown, title="Squeeze Breakout Down", location=location.abovebar, color=color.red, style=shape.labeldown, size=size.small, text="SqueezeDown", textcolor=color.white)

// Parámetros de MA, RSI y ATR
shortMaLength = input.int(9, title="Short MA Length", minval=1)
longMaLength = input.int(21, title="Long MA Length", minval=1)
rsiLength = input.int(14, title="RSI Length", minval=1)
atrLengthSL = input.int(14, title="ATR Length for SL/Target", minval=1)
targetMultiplier = input.float(2.0, title="Target Multiplier", minval=0.1)
stopLossMultiplier = input.float(1.5, title="Stop Loss Multiplier", minval=0.1)

// Calcular medias móviles
shortMa = ta.sma(close, shortMaLength)
longMa = ta.sma(close, longMaLength)

// Calcular RSI y ATR
rsiValue = ta.rsi(close, rsiLength)
atrValue = ta.atr(atrLengthSL)

// Condiciones de compra y venta basadas en el cruce de MA y RSI
buyCondition = ta.crossover(shortMa, longMa) and rsiValue < 70
sellCondition = ta.crossunder(shortMa, longMa) and rsiValue > 30

// Calcular precios de stop-loss y objetivos para operaciones largas y cortas
longStopLoss = close - stopLossMultiplier * atrValue
longTarget = close + targetMultiplier * atrValue
shortStopLoss = close + stopLossMultiplier * atrValue
shortTarget = close - targetMultiplier * atrValue

// Mostrar señales de compra/venta en el gráfico
var label longInfoLabel = na
var label shortInfoLabel = na

if (buyCondition)
    longInfoLabel := label.new(bar_index, low - atrValue * 1.0, "Bull\nStop: " + str.tostring(longStopLoss, "#.##") + "\nTarget: " + str.tostring(longTarget, "#.##"), style=label.style_label_up, color=color.green, textcolor=color.white, size=size.normal)

if (sellCondition)
    shortInfoLabel := label.new(bar_index, high + atrValue * 1.0, "Bear\nStop: " + str.tostring(shortStopLoss, "#.##") + "\nTarget: " + str.tostring(shortTarget, "#.##"), style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal)

// Plotear las medias móviles en el gráfico
plot(shortMa, color=color.blue, title="Short MA")
plot(longMa, color=color.orange, title="Long MA")

// Plotear señales de compra y venta en el gráfico
plotshape(series=buyCondition, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.labelup, text="Buy")
plotshape(series=sellCondition, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.labeldown, text="Sell")
````
