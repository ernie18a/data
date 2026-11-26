# Gold Intel Pro

- url: https://www.tradingview.com/script/P5kJO6ij-Gold-Intel-Pro/
- type: indicator
- pine_id: PUB;4dbeea7e22734d619513b64f93ce3f28
- version: 2.0

## Description

Click "Alerts" button (top toolbar)
Click "Create Alert"
Condition: Select "Gold Intel Pro" → "Any alert() function call"
Webhook URL: https://goldintel.live/api/webhook/tradingview
Message: Leave blank (indicator sends JSON automatically)
Name it "Gold Intel Webhook" → Create

## Source Code

````pine
//@version=6
indicator("Gold Intel Pro", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
level1 = input.price(2665.0, "Long #1 Level")
level2 = input.price(2635.0, "Stop Long #1 Level")
level3 = input.price(2785.0, "Short #1 Level")
level4 = input.price(2815.0, "Stop Short #1 Level")
level5 = input.price(2895.0, "High Level")
level6 = input.price(2858.22, "ATH Level")

atrLen = input.int(14, "ATR Length")
atrMult = input.float(2.0, "ATR Multiplier")
volLen = input.int(20, "Volume MA Length")
volThresh = input.float(1.5, "Volume Threshold")

// --- Calculations ---
atr = ta.atr(atrLen)
volMA = ta.ema(volume, volLen)
highVol = volume > volMA * volThresh
highVolStart = highVol and not highVol[1]

// --- Trailing Stop Visuals (ATR) ---
var float trailStop = na
if close > nz(trailStop[1], 0) and close[1] > nz(trailStop[1], 0)
    trailStop := math.max(nz(trailStop[1]), close - atr * atrMult)
else if close < nz(trailStop[1], 1e10) and close[1] < nz(trailStop[1], 1e10)
    trailStop := math.min(nz(trailStop[1]), close + atr * atrMult)
else
    trailStop := close > nz(trailStop[1]) ? close - atr * atrMult : close + atr * atrMult

plot(trailStop, "ATR Trailing Stop", color.new(close > trailStop ? color.green : color.red, 30), linewidth=2, style=plot.style_linebr)

// --- Dynamic Levels ---
// Note: plot() used instead of hline() to allow dynamic input.price() values
plot(level1, "Long #1", color.new(color.green, 50), style=plot.style_linebr)
plot(level2, "Stop Long #1", color.new(color.red, 50), style=plot.style_linebr)
plot(level3, "Short #1", color.new(color.red, 50), style=plot.style_linebr)
plot(level4, "Stop Short #1", color.new(color.orange, 50), style=plot.style_linebr)
plot(level5, "High Level", color.new(color.yellow, 30), linewidth=2, style=plot.style_linebr)
plot(level6, "ATH Level", color.new(color.gray, 30), linewidth=2, style=plot.style_linebr)

// --- Labels ---
// Initialize labels once and update coordinates to keep them at the right edge
var label lbl1 = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.green, 90), textcolor=color.green, style=label.style_label_left)
var label lbl2 = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.red, 90), textcolor=color.red, style=label.style_label_left)
var label lbl3 = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.red, 90), textcolor=color.red, style=label.style_label_left)
var label lbl4 = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.orange, 90), textcolor=color.orange, style=label.style_label_left)
var label lbl5 = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.yellow, 90), textcolor=color.yellow, style=label.style_label_left)
var label lbl6 = label.new(na, na, "", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.gray, 90), textcolor=color.gray, style=label.style_label_left)

if barstate.islast
    label.set_xy(lbl1, bar_index, level1), label.set_text(lbl1, "Long #1: " + str.tostring(level1))
    label.set_xy(lbl2, bar_index, level2), label.set_text(lbl2, "Stop Long #1: " + str.tostring(level2))
    label.set_xy(lbl3, bar_index, level3), label.set_text(lbl3, "Short #1: " + str.tostring(level3))
    label.set_xy(lbl4, bar_index, level4), label.set_text(lbl4, "Stop Short #1: " + str.tostring(level4))
    label.set_xy(lbl5, bar_index, level5), label.set_text(lbl5, "High: " + str.tostring(level5))
    label.set_xy(lbl6, bar_index, level6), label.set_text(lbl6, "ATH: " + str.tostring(level6))

// --- Visuals ---
plotshape(highVol ? low : na, "High Volume", shape.circle, location.absolute, color.new(color.blue, 50), size=size.tiny)

// --- Alerts ---
if highVolStart
    alert("High Volume Spike Detected", alert.freq_once_per_bar)
````
