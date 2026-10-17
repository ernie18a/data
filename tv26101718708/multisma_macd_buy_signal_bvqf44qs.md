# Multi-SMA + MACD Buy Signal

- url: https://www.tradingview.com/script/BvqF44QS-Multi-SMA-MACD-Buy-Signal/
- type: indicator
- pine_id: PUB;b1e8e03d425c4a61b29a3a11f63764c2
- version: 1.0

## Description

Simple moving average based indicator for leap strategies on mag 7 type stocks, value buying stocks or leap plays, works really well with high conviction on day trading

## Source Code

````pine
  //@version=6
indicator("Multi-SMA + MACD Buy Signal", overlay=true)

  // Moving Averages
ma50 = ta.sma(close, 100)
ma200 = ta.sma(close, 200)
ma300 = ta.sma(close, 300)
ma600 = ta.sma(close, 600)

  // MACD (12, 26, 9)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
macdCrossover = ta.crossover(macdLine, signalLine)

  // Buy signals - only when SMA exists
buyMA50 = not na(ma50) and close < ma50 and (na(ma200) or close >= ma200) and macdCrossover
buyMA200 = not na(ma200) and close < ma200 and (na(ma300) or close >= ma300) and macdCrossover
buyMA300 = not na(ma300) and close < ma300 and (na(ma600) or close >= ma600) and macdCrossover
buyMA600 = not na(ma600) and close < ma600 and macdCrossover

  // Plot SMAs - use na to hide when not ready (prevents 0 plotting)
plot(na(ma50) ? na : ma50, color=color.black, linewidth=2, title="SMA 100")
plot(na(ma200) ? na : ma200, color=color.orange, linewidth=2, title="SMA 200")
plot(na(ma300) ? na : ma300, color=color.red, linewidth=2, title="SMA 300")
plot(na(ma600) ? na : ma600, color=color.purple, linewidth=2, title="SMA 600")

  // Buy signals
plotshape(buyMA50, style=shape.triangleup, location=location.belowbar, color=color.black, size=size.tiny, title="Buy < 100")
plotshape(buyMA200, style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.small, title="Buy < 200")
plotshape(buyMA300, style=shape.triangleup, location=location.belowbar, color=color.red, size=size.normal, title="Buy < 300")
plotshape(buyMA600, style=shape.triangleup, location=location.belowbar, color=color.purple, size=size.huge, title="Buy < 600")


//plotshape(buyMA50, style=shape.triangleup, location=location.belowbar, color=color.black, size=size.tiny, title="Buy < 50", text="BUY 1-2", textcolor=color.black)
//plotshape(buyMA200, style=shape.triangleup, location=location.belowbar, color=color.orange, size=size.small, title="Buy < 200", text="BUY SOME", textcolor=color.orange)
//plotshape(buyMA300, style=shape.triangleup, location=location.belowbar, color=color.red, size=size.normal, title="Buy < 300", text="BUY DECENT", textcolor=color.red)
//plotshape(buyMA600, style=shape.triangleup, location=location.belowbar, color=color.purple, size=size.huge, title="Buy < 600", text="GO DEEP", textcolor=color.purple)

  // ═══════════════════════════════════════════════════════════════════════════════
  // LEGEND TABLE - Top Right Corner
  // ═══════════════════════════════════════════════════════════════════════════════
var table legend = table.new(position.top_right, 2, 5, bgcolor=color.new(color.white, 80), border_width=1)

if barstate.islast
    table.cell(legend, 0, 0, "SIGNAL", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 0, "ACTION", bgcolor=color.gray, text_color=color.white, text_size=size.small)
    table.cell(legend, 0, 1, "▲ < SMA 100", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 1, "BUY 1-2", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(legend, 0, 2, "▲ < SMA 200", bgcolor=color.orange, text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 2, "BUY SOME", bgcolor=color.orange, text_color=color.white, text_size=size.small)
    table.cell(legend, 0, 3, "▲ < SMA 300", bgcolor=color.red, text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 3, "BUY DECENT", bgcolor=color.red, text_color=color.white, text_size=size.small)
    table.cell(legend, 0, 4, "▲ < SMA 600", bgcolor=color.purple, text_color=color.white, text_size=size.small)
    table.cell(legend, 1, 4, "GO DEEP", bgcolor=color.purple, text_color=color.white, text_size=size.small)
````
