<!-- tradingview-pine-id: PUB;71f1adbcc4ba4cf09589374c473bf87c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TCloud

Source: https://www.tradingview.com/script/rgyPeK5p/

## Description

TCloud — Tilson T3 Cloud with ATR Trend Line

TCloud implements the Tradencia Traders trading methodology, combining two Tilson T3 moving averages with an ATR-based Supertrend line. It overlays the price chart to help identify trend direction and show how price is positioned relative to the cloud.

This trading methodology belongs to Tradencia Traders. Indicator credits: EduWarlock — Tradencia Traders.

HOW IT WORKS

The cloud is formed by a short Tilson T3 and a long Tilson T3:

• Blue cloud: the short Tilson is above the long Tilson.
• Red cloud: the short Tilson is below or equal to the long Tilson.

Cloud colors can be customized in the settings.

CANDLE COLORS

Each candle is colored according to its closing price relative to both moving averages:

• Blue: the close is above both Tilson averages.
• Red: the close is below both Tilson averages.
• White: the close is inside the cloud or exactly on either boundary.

Candle colors are calculated independently of the cloud and ATR line colors.

ATR LINE — SUPERTREND

The line uses ATR and a multiplier to track trend direction while adapting to volatility:

• Blue line below price: an upward Supertrend state.
• Red line above price: a downward Supertrend state.

This is a price level derived from ATR, rather than the raw ATR value.

HOW TO USE IT

For a bullish reading, look for alignment between a blue cloud, blue candles, and a blue ATR line below price.

For a bearish reading, look for alignment between a red cloud, red candles, and a red ATR line above price.

White candles indicate that the closing price is within the cloud or on its boundaries. Disagreement between the cloud, candles, and ATR line may indicate a transition or a lack of directional alignment.

The ATR line can also serve as a visual reference for tracking a move and planning exits. Using it as a stop requires your own risk management rules.

SETTINGS

• Tilson Long Period: long moving average period. Default: 15.
• Tilson Short Period: short moving average period. Default: 4.
• Tilson Long Factor: long Tilson smoothing factor. Default: 0.55.
• Tilson Short Factor: short Tilson smoothing factor. Default: 0.38.
• ATR Length: ATR period used by the Supertrend. Default: 10.
• Factor: ATR multiplier. Default: 3.0.
• Mostrar Nuvem Tilson: shows or hides the cloud.
• Mostrar Linha ATR: shows or hides the Supertrend line.

Shorter moving average periods generally increase sensitivity to price changes. A larger ATR multiplier generally places the line farther from price and reduces the frequency of trend reversals.

NOTES

Values and colors can change while the current candle is forming. Wait for the candle to close when evaluating confirmed conditions.

TCloud is a visual indicator. It does not execute trades, provide backtest results, or include programmed alerts. Its components can lag behind price and change direction frequently in sideways markets. Color alignment does not guarantee trend continuation or profitable results.

Trading methodology: Tradencia Traders.
Indicator author: EduWarlock — Tradencia Traders.
Code released under the Mozilla Public License 2.0.

---

## Source Code

````pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EduWarlock from Tradencia Traders

//@version=6
indicator("TCloud", overlay=true)

// === Inputs ===
tilsonLongLen = input.int(15, title="Tilson Long Period", minval=1)
tilsonShortLen = input.int(4, title="Tilson Short Period", minval=1)
tilsonLongFactor = input.float(0.55, title="Tilson Long Factor", step=0.01)
tilsonShortFactor = input.float(0.38, title="Tilson Short Factor", step=0.01)

colorUp = input.color(color.blue, title="Cloud Color (Short > Long)")
colorDown = input.color(color.red, title="Cloud Color (Long > Short)")
showCloud = input.bool(true, title="Mostrar Nuvem Tilson")

atrPeriod = input.int(10, title="ATR Length", minval=1)
factor = input.float(3.0, title="Factor", minval=0.01, step=0.01)
showATR = input.bool(true, title="Mostrar Linha ATR")

// === Tilson Function ===
tilsonMA(src, length, vfactor) =>
    e1 = ta.ema(src, length)
    e2 = ta.ema(e1, length)
    e3 = ta.ema(e2, length)
    e4 = ta.ema(e3, length)
    e5 = ta.ema(e4, length)
    e6 = ta.ema(e5, length)
    c1 = -vfactor * vfactor * vfactor
    c2 = 3 * vfactor * vfactor + 3 * vfactor * vfactor * vfactor
    c3 = -6 * vfactor * vfactor - 3 * vfactor - 3 * vfactor * vfactor * vfactor
    c4 = 1 + 3 * vfactor + vfactor * vfactor * vfactor + 3 * vfactor * vfactor
    T3 = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3
    T3

// === Cálculo Tilson ===
tilsonShort = tilsonMA(close, tilsonShortLen, tilsonShortFactor)
tilsonLong = tilsonMA(close, tilsonLongLen, tilsonLongFactor)

// === Plot Tilsons ===
plotShort = plot(tilsonShort, title="Tilson Short", color=color.new(colorUp, 0))
plotLong = plot(tilsonLong, title="Tilson Long", color=color.new(colorDown, 0))

// === Nuvem ===
fill(plotShort, plotLong, color=showCloud ? (tilsonShort > tilsonLong ? color.new(colorUp, 80) : color.new(colorDown, 80)) : na, title="Tilson Cloud")

// === Cores dos candles ===
minTilson = math.min(tilsonShort, tilsonLong)
maxTilson = math.max(tilsonShort, tilsonLong)

candleColor = close > maxTilson ? color.blue : close < minTilson ? color.red : color.white

barcolor(candleColor, title="Candle Color")

// === Linha baseada no ATR (Supertrend) ===
[atrLine, atrDirection] = ta.supertrend(factor, atrPeriod)

// Azul: preço acima da linha
plot(showATR and atrDirection < 0 ? atrLine : na, title="ATR Azul", color=color.blue, linewidth=2, style=plot.style_linebr)

// Vermelho: preço abaixo da linha
plot(showATR and atrDirection > 0 ? atrLine : na, title="ATR Vermelho", color=color.red, linewidth=2, style=plot.style_linebr)
````
