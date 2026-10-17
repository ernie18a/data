# GRID Overlay

- url: https://www.tradingview.com/script/Nb6jUmxE-GRID-Overlay/
- type: indicator
- pine_id: PUB;518ae2a2800b4fb08e0575e05faceea1
- version: 1.0

## Description

Combined HMA + EMA overlay for the GRID trading dashboard. Plots a fast Hull Moving Average (default 7) and a slow Exponential Moving Average (default 20) on the price chart. Lengths, colors, and line widths are configurable via the indicator inputs. Designed to count as a single indicator slot when embedded in TradingView widgets, freeing the second slot for RSI or other oscillators.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Buzrocks aka Alan Fischbach
//@version=6
indicator("GRID Overlay", shorttitle="GRID", overlay=true)

// === HMA 7 ===
hmaLen = input.int(7, title="HMA Length", minval=1)
hmaCol = input.color(color.red, title="HMA Color")
hmaWid = input.int(2, title="HMA Width", minval=1, maxval=5)
hmaVal = ta.hma(close, hmaLen)
plot(hmaVal, title="HMA", color=hmaCol, linewidth=hmaWid)

// === EMA 20 ===
emaLen = input.int(20, title="EMA Length", minval=1)
emaCol = input.color(color.white, title="EMA Color")
emaWid = input.int(2, title="EMA Width", minval=1, maxval=5)
emaVal = ta.ema(close, emaLen)
plot(emaVal, title="EMA", color=emaCol, linewidth=emaWid)
````
