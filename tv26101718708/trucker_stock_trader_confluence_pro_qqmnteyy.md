# Trucker Stock Trader Confluence Pro

- url: https://www.tradingview.com/script/qqMnTeyY-Trucker-Stock-Trader-Confluence-Pro/
- type: indicator
- pine_id: PUB;4f8a66cdc9954ce78d61614ee2794196
- version: 2.0

## Description

Trucker Stock Trader Confluence Pro
Built for beginners and experienced day traders alike
This indicator combines several popular trading tools into one easy-to-read dashboard so you don’t have to jump between 5 different indicators.
How It Works (Simple Version):
Think of it like a traffic light system for buying or selling stocks:
The Colored Shapes on the Chart:
Green Circle = MACD just turned bullish (momentum shifting up)
Green Triangle = RSI crossing above 50 (getting stronger)
Green Square = EMA 9 crossing above other EMAs (short-term trend turning up)
Green Diamond = Price breaking above the Keltner Channel (strong upward move)
White Circle = Price crossed above or below the VWAP line
The more green shapes that appear together on the same candle = the stronger the buy signal.
Red shapes mean the opposite (bearish/sell signals).
Live Status Box (Top Left Corner):
This box tells you at a glance what each tool is saying:
MACD, RSI, EMA, VWAP, Keltner — each marked Bullish or Bearish with matching symbols
ATR Stop — Shows a suggested stop-loss distance (how much room to give the trade)
Strength Bar — Fills up with green blocks the more signals are agreeing. More green = higher probability setup.
Plotted Lines You See:
Yellow line = Fast EMA (9)
Green line = Medium EMA (20)
Red line = Long-term EMA (200)
White line = VWAP (average price for the day)
Thin green/red lines = Keltner Channels (like dynamic support/resistance)
Best Way for Beginners to Use It:
Look for candles where multiple green shapes stack together.
Check the Strength Bar — the fuller it is, the better.
Use the ATR number in the box to help set your stop-loss.
Always combine this with your own chart reading and risk management.
This indicator helps you see confluence — when several tools agree at the same time — which usually gives higher-probability trades than using just one tool alone.
Perfect for SPY, QQQ, IWM, NVDA, PLTR, and other popular stocks.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jthproflow

//@version=6
indicator("Trucker Stock Trader Confluence Pro", overlay=true, max_labels_count=500, max_lines_count=500)

// ── Inputs ─────────────────────────────────────
showEMAs = input.bool(true, "Show EMAs")
showKC = input.bool(true, "Show Keltner Channels")
showVWAP = input.bool(true, "Show VWAP")

lenFast = input.int(9, "EMA Fast Length", minval=1)
lenMedium = input.int(20, "EMA Medium Length", minval=1)
lenLong = input.int(200, "EMA Long Length", minval=1)

tablePos = input.string("Top Left", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right", "Middle Center"])

// ── Calculations ───────────────────────────────
emaFast = ta.ema(close, lenFast)
ema13 = ta.ema(close, 13)
emaMedium = ta.ema(close, lenMedium)
emaLong = ta.ema(close, lenLong)

[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
rsi = ta.rsi(close, 14)

// Keltner
kcLength = input.int(20, "KC Length")
kcMult = input.float(2.0, "KC Multiplier")
kcBasis = ta.ema(close, kcLength)
kcRange = ta.atr(kcLength) * kcMult
kcUpper = kcBasis + kcRange
kcLower = kcBasis - kcRange

// VWAP
vwapValue = ta.vwap(hlc3)

// ── Signals ────────────────────────────────────
macdBull = ta.crossover(macdLine, signalLine)
macdBear = ta.crossunder(macdLine, signalLine)

rsiBull = ta.crossover(rsi, 50)
rsiBear = ta.crossunder(rsi, 50)

emaBull = ta.crossover(emaFast, ema13) or ta.crossover(emaFast, emaMedium)
emaBear = ta.crossunder(emaFast, ema13) or ta.crossunder(emaFast, emaMedium)

kcBull = ta.crossover(close, kcUpper)
kcBear = ta.crossunder(close, kcLower)

vwapBullCross = ta.crossover(close, vwapValue)
vwapBearCross = ta.crossunder(close, vwapValue)

// ── Plots ──────────────────────────────────────
plot(showEMAs ? emaFast : na, color=color.yellow, linewidth=2, title="EMA Fast", force_overlay=true)
plot(showEMAs ? emaMedium : na, color=color.green, linewidth=2, title="EMA Medium", force_overlay=true)
plot(showEMAs ? emaLong : na, color=color.red, linewidth=2, title="EMA Long", force_overlay=true)

plot(showKC ? kcUpper : na, color=#00FF00, linewidth=1, title="KC Upper", force_overlay=true)
plot(showKC ? kcLower : na, color=#FF00FF, linewidth=1, title="KC Lower", force_overlay=true)
plot(showVWAP ? vwapValue : na, color=color.white, linewidth=2, title="VWAP", force_overlay=true)

// ── Shapes ─────────────────────────────────────
plotshape(macdBull, style=shape.circle, location=location.belowbar, color=color.new(color.green,0), size=size.tiny, force_overlay=true)
plotshape(rsiBull, style=shape.triangleup, location=location.belowbar, color=color.new(color.green,0), size=size.tiny, force_overlay=true)
plotshape(emaBull, style=shape.square, location=location.belowbar, color=color.new(color.green,0), size=size.tiny, force_overlay=true)
plotshape(kcBull, style=shape.diamond, location=location.belowbar, color=color.new(color.green,0), size=size.tiny, force_overlay=true)

plotshape(macdBear, style=shape.circle, location=location.abovebar, color=color.new(color.red,0), size=size.tiny, force_overlay=true)
plotshape(rsiBear, style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0), size=size.tiny, force_overlay=true)
plotshape(emaBear, style=shape.square, location=location.abovebar, color=color.new(color.red,0), size=size.tiny, force_overlay=true)
plotshape(kcBear, style=shape.diamond, location=location.abovebar, color=color.new(color.red,0), size=size.tiny, force_overlay=true)

plotshape(vwapBullCross, style=shape.circle, location=location.abovebar, color=color.new(color.white,0), size=size.small, force_overlay=true)
plotshape(vwapBearCross, style=shape.circle, location=location.belowbar, color=color.new(color.white,0), size=size.small, force_overlay=true)

// ── Table ──────────────────────────────────────
pos = switch tablePos
    "Top Left" => position.top_left
    "Top Right" => position.top_right
    "Bottom Left" => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    "Middle Center" => position.middle_center
    => position.top_left

var table infoTable = table.new(pos, 2, 7, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    bullScore = (macdLine > signalLine ? 1 : 0) + (rsi > 50 ? 1 : 0) + (emaFast > emaMedium ? 1 : 0) + (close > vwapValue ? 1 : 0) + (close > kcBasis ? 1 : 0)
    
    table.cell(infoTable, 0, 0, "MACD", text_color=color.white)
    table.cell(infoTable, 1, 0, macdLine > signalLine ? "BULLISH ●" : "BEARISH ●", text_color = macdLine > signalLine ? color.green : color.red)
    
    table.cell(infoTable, 0, 1, "RSI", text_color=color.white)
    table.cell(infoTable, 1, 1, rsi > 50 ? "BULLISH ▲" : "BEARISH ▼", text_color = rsi > 50 ? color.green : color.red)
    
    table.cell(infoTable, 0, 2, "EMA", text_color=color.white)
    table.cell(infoTable, 1, 2, emaFast > emaMedium ? "BULLISH ■" : "BEARISH ■", text_color = emaFast > emaMedium ? color.green : color.red)
    
    table.cell(infoTable, 0, 3, "VWAP", text_color=color.white)
    table.cell(infoTable, 1, 3, close > vwapValue ? "ABOVE ○" : "BELOW ○", text_color=color.white)
    
    table.cell(infoTable, 0, 4, "Keltner", text_color=color.white)
    table.cell(infoTable, 1, 4, close > kcBasis ? "BULLISH ◆" : "BEARISH ◆", text_color = close > kcBasis ? color.green : color.red)
    
    table.cell(infoTable, 0, 5, "ATR Stop", text_color=color.white)
    table.cell(infoTable, 1, 5, str.tostring(nz(ta.atr(14), 0), "#.##"), text_color=color.yellow)
    
    table.cell(infoTable, 0, 6, "Strength", text_color=color.white)
    table.cell(infoTable, 1, 6, bullScore >= 3 ? "██████" : bullScore >= 2 ? "████▒▒" : bullScore >= 1 ? "██▒▒▒▒" : "▒▒▒▒▒▒", text_color = bullScore >= 3 ? color.lime : color.orange)
````
