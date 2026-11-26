# Timbuktu V - Black hole

- url: https://www.tradingview.com/script/If33ecVD-Timbuktu-V-Black-hole/
- type: indicator
- pine_id: PUB;1fc190258c714f6b8ee2cf19f547b453
- version: 9.0

## Description

Timbuktu V - Black Hole is a momentum and trend-following technical indicator designed to identify high-volatility breakout phases and FOMO-driven moves. The algorithm pinpoints the exact moments when price breaks out of historical ranges with a drastic spike in volume and strong RSI backing, capturing high-velocity market expansions (the "Black Hole" effect).

The indicator highlights bars and plots visual signals directly on your chart when extreme market conditions are met. This is ideal for breakout traders, momentum scalpers, and those trading highly volatile assets (Crypto, Forex, or Equities).

How It Works (Quantitative Logic)
To filter out market noise and false breakouts, the script combines 4 key confirmation factors before triggering a signal:

Trend Context: It uses an EMA (21-period by default) to determine the macro direction. Long signals are only triggered above it, and Short signals below it.

Range Breakout: Price must break the highest high or lowest low of the last 100 periods (Lookback input). It does not trade ranges; it trades explosive expansions.

Volume Confirmation (Smart Money): It requires the breakout bar's volume to exceed its short-term volume moving average (2-period SMA) by at least 30% (x1.3).

Momentum Strength (RSI): The RSI must be in the overbought zone (>65) for Longs or oversold zone (<35) for Shorts, validating genuine aggressive buying/selling pressure.

Key Features
Dynamic FOMO Candles: Candles that trigger the signal change color (yellow by default) to visually alert you to the volatility explosion.

Net Percentage Calculation: The indicator automatically measures the percentage range of the breakout candle, subtracts a custom operational fee (Cost input), and projects the net percentage directly on the chart using dynamic labels.

Clean Visual Signals (plotshape): Sleek diamond icons plotted above/below the candles for quick execution and backtesting visualization.

Native Alerts Ready: Includes 3 built-in alert conditions (Black Hole Long, Black Hole Short, and a combined alert) so you can easily automate your strategy or receive instant mobile/webhook notifications.

Customizable Settings
EMA Trend (21): Adjusts the core trend-filtering line.

RSI (14): Changes the sensitivity of the strength oscillator.

Volume MA (2): The moving average period used to detect the volume spike (tweak it to look for sustained volume or pure immediate bursts).

Lookback HH/LL (100): The lookback window used to define what qualifies as a major historical high or low.

Cost (0.04): A percentage offset to simulate fees or slippage, providing a more realistic net movement display.

Trading Tips
Timeframes: Highly effective on 5m, 15m, and 1h charts to catch intra-day breakout continuations.

Risk Management: Because this strategy capitalizes on FOMO/Volatility, consider placing your Stop Loss just below the EMA 21 or at the low/high of the breakout candle itself.

## Source Code

````pine
//@version=6
indicator("Timbuktu V - Black hole", overlay=true)

// ───── Inputs
emaLen      = input.int(21, "EMA Trend")
rsiLen      = input.int(14, "RSI")
volLen      = input.int(2, "Volume MA")
lookbackHL  = input.int(15, "Lookback HH/LL")
cost      = input.float(0.04, "Cost")

// ───── Color Inputs
colorLong  = input.color(color.yellow, "Positive candle color Long")
colorShort = input.color(color.yellow, "Positive candle color Short")

colorLongNeg  = input.color(color.rgb(255, 121, 59), "Negative candle color Long")
colorShortNeg = input.color(color.rgb(255,  121, 59), "Negative candle color Short")


// ───── Base calculations
ema21 = ta.ema(close, emaLen)
rsi   = ta.rsi(close, rsiLen)
volMA = ta.sma(volume, volLen)

// ───── Trend context
trendBull = close > ema21
trendBear = close < ema21

// ───── High / Low reference
hh = ta.highest(high, lookbackHL)
ll = ta.lowest(low, lookbackHL)

// ───── FOMO LOGIC
fomoLong =  trendBull and  close > hh[1] and  volume > volMA * 1.3 and  rsi > 65
fomoShort =  trendBear and  close < ll[1] and  volume > volMA * 1.3 and  rsi < 35

// ───── % Movement Calculation
candlePct = (((high - low) / low) * 100)-cost
pctText = str.tostring(candlePct, "#.##") + "%"


colorLongl = colorLong
colorShortl = colorShort


if candlePct<0
    colorLongl := colorLongNeg
    colorShortl := colorShortNeg

// ───── Visuals
barcolor(fomoLong ? colorLongl : fomoShort ? colorShortl : na)
plot(ema21, color=color.orange, linewidth=2)

// Señales Seleccionables (Nativas con plotshape)
plotshape(fomoLong, title="FOMO Long Icon", style=shape.diamond, location=location.abovebar, color=colorLongl, size=size.tiny)
plotshape(fomoShort, title="FOMO Short Icon", style=shape.diamond, location=location.belowbar, color=colorShortl, size=size.tiny)

// ───── Etiqueta de % Dinámico (Estructura en línea que sí se dibuja)
if fomoLong or fomoShort
    label.new(x=bar_index, y=fomoLong ? high : low, text=pctText, yloc=fomoLong ? yloc.abovebar : yloc.belowbar, color=color.new(color.white, 100), textcolor=fomoLong ? colorLongl : colorShortl, style=label.style_none)

// ───── Alerts
alertcondition(fomoLong, title="Black Hole Long", message="⚠️ Black Hole LONG")
alertcondition(fomoShort, title="Black Hole Short", message="⚠️ Black Hole SHORT")
alertcondition(fomoShort or fomoLong, title="Black Hole", message="⚠️ Black Hole")
````
