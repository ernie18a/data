# Arth - EMA Cloud + IV + Closing Range %

- url: https://www.tradingview.com/script/YtiidhvI-Arth-EMA-Cloud-IV-Closing-Range/
- type: indicator
- pine_id: PUB;2a72b42291584de0b3c33cbc9fa8f584
- version: 5.0

## Description

10, 20, 50 EMA

Institutional volume (Volume > 4 times the previous 50 volumes)

Closing range of IV candles (%)

Works on all time frames

## Source Code

````pine
//@version=5
indicator("EMA+IV+DCR+IB+Table", overlay=true)

// =====================
// EMA
// =====================
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

// =====================
// EMA PLOTS
// =====================
p1 = plot(ema10, color=color.new(color.blue, 60), linewidth=1)
p2 = plot(ema20, color=color.new(color.fuchsia, 65), linewidth=1)
p3 = plot(ema50, color=color.new(color.green, 60), linewidth=1)
plot(ema200, color=color.new(color.gray, 40), linewidth=1)

// =====================
// CLOUDS
// =====================
pClose = plot(close, display=display.none)

fill(pClose, p1, color=color.new(color.blue, 85))
fill(p2, p3, color=color.new(color.fuchsia, 90))

// =====================
// INSTITUTIONAL VOLUME
// =====================
volAvg50 = ta.sma(volume, 50)
highVol = volume > 4 * volAvg50 and close > ema20

// =====================
// INSIDE BAR
// =====================
insideBar = high < high[1] and low > low[1]

// =====================
// BAR COLORS
// =====================
barcolor(highVol ? color.orange : insideBar ? color.yellow : na)

// =====================
// INSIDE BAR LABEL
// =====================
if insideBar
    label.new(bar_index, high, "IB", style=label.style_label_down, color=color.white, textcolor=color.black, size=size.tiny)

// =====================
// CLOSING RANGE %
// =====================
rangePerc = (high != low) ? (close - low) / (high - low) * 100 : na

y = high + ta.atr(14) * 0.35
txt = str.tostring(rangePerc, "#.0") + "%"

if highVol and not na(rangePerc)
    label.new(bar_index, y, txt, style=label.style_label_down, color=color.new(color.white, 100), textcolor=color.black, size=size.small)

// =====================
// EMA TABLE
// =====================
var table t = table.new(position.bottom_left, 1, 5, border_width=1)

// % Distance from CMP
dist10 = ((close - ema10) / ema10) * 100
dist20 = ((close - ema20) / ema20) * 100
dist50 = ((close - ema50) / ema50) * 100
dist200 = ((close - ema200) / ema200) * 100

// =====================
// TABLE TEXT
// =====================
cmpTxt = "CMP : " + str.tostring(close, "#")

txt10 = "10 EMA : " + str.tostring(ema10, "#") + " (" + str.tostring(dist10, "#.##") + "%)"
txt20 = "20 EMA : " + str.tostring(ema20, "#") + " (" + str.tostring(dist20, "#.##") + "%)"
txt50 = "50 EMA : " + str.tostring(ema50, "#") + " (" + str.tostring(dist50, "#.##") + "%)"
txt200 = "200 EMA : " + str.tostring(ema200, "#") + " (" + str.tostring(dist200, "#.##") + "%)"

// =====================
// TABLE COLORS
// =====================
bgCol = color.new(color.yellow, 80)
txtCol = color.black

// =====================
// POPULATE TABLE
// =====================
if barstate.islast
    table.cell(t, 0, 0, cmpTxt, text_color=txtCol, bgcolor=bgCol, text_size=size.normal)
    table.cell(t, 0, 1, txt10, text_color=txtCol, bgcolor=bgCol, text_size=size.normal)
    table.cell(t, 0, 2, txt20, text_color=txtCol, bgcolor=bgCol, text_size=size.normal)
    table.cell(t, 0, 3, txt50, text_color=txtCol, bgcolor=bgCol, text_size=size.normal)
    table.cell(t, 0, 4, txt200, text_color=txtCol, bgcolor=bgCol, text_size=size.normal)
````
