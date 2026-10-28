# Multi-Tool: Overlays, MAs, Grid & Sessions

- url: https://www.tradingview.com/script/vlX8u7xX/
- type: indicator
- pine_id: PUB;54a848e140494331b95a322cd9ab84cf
- version: 1.0

## Description

🛠 Multi-Tool (H1/D1 Overlays, Flexible MAs & Session Grid)
📖 Introduction
The Scalp-Vision Multi-Tool is a professional analysis instrument designed specifically for scalpers and day traders. It combines the structure of higher timeframes (H1/D1) with session time markers and psychological price levels directly within the current chart. The goal is to make market context instantly readable — without having to switch timeframes.
✨ Key Features

📦 Multi-Timeframe Template Overlays (H1 & D1)


H1 Projection: The indicator takes the high and low of the last completed hourly candle and projects this range as a subtle "shadow" (box) over the current hour.
D1 Projection: Yesterday's range is overlaid as a large background frame across the current trading day.
Median Lines: Automatically calculated midlines for both time ranges serve as reference points for mean reversion trades.
Advantage: You can instantly see whether price is trading within the value area of the previous period or whether a breakout is occurring.


📈 Flexible Moving Averages (MA+)


Four MA Slots: Users can activate up to four moving averages simultaneously.
Individual Types: Each MA can be set separately as SMA (Simple), EMA (Exponential), or WMA (Weighted).
Fully Customizable: Length, color, and line width are freely adjustable for each MA, allowing strategies like the 20/200 crossover to be mapped perfectly.


🕒 Manual Session Markers (Vertical Lines)


Session Opens (Green): Vertical solid lines mark the start of the Asia, London, and New York sessions.
Session Closes (Red): Indicate the end of each respective trading session.
Flag Icons: Small icons (🇯🇵, 🇬🇧, 🇺🇸) at the bottom of the chart help with quick time orientation.
Manual Control: To avoid errors caused by timezone shifts, the hours and minutes of each session can be entered directly in the settings.


🏁 Round Numbers Grid (Psychological Levels)


100-Step Lines: Solid horizontal lines at round price levels (e.g. 1.1000, 1.1100).
50-Step Lines: Dashed lines for finer subdivision.
Global Design: The grid extends across the entire chart and helps place take-profit and stop-loss levels at institutionally relevant marks.

⚙️ User Guide & Settings
🛠 Setting Up Sessions
Since TradingView servers run globally, the safest method is manual input:

Look at your local time shown at the bottom of the time axis in the chart.
Enter the desired start and end time (hour and minute) in the fields under "Sessions (Manual Times)".
The lines will adjust to your chart immediately.

🎨 Visual Customization

Overlays: If the H1 boxes overlap the candles too heavily, reduce the opacity in the color settings of the boxes.
Line Styles: All session lines and medians can be switched from Solid to Dashed or Dotted.

💡 Trading Tips

Inside vs. Outside: Is price using the D1 median as support? A bounce is often a sign of strength.
Session Volatility: Watch the green London line (9:00 AM) — this is often where the first real trends of the day emerge.
Grid Magnetism: Round numbers frequently attract price. Use the grid to identify congested order areas.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Multi-Tool: Overlays, MAs, Grid & Sessions", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// --- Helper Functions ---
get_line_style(style) =>
    style == "Solid" ? line.style_solid : style == "Dashed" ? line.style_dashed : line.style_dotted

// --- GLOBAL VARIABLES (FIXING THE ERROR) ---
// We call all ta.* and time functions here at the top level, outside of any 'if' or function.
t_Main = time
t_60   = time("60")
t_D    = time("D")
change_60 = ta.change(t_60)
change_D  = ta.change(t_D)
change_T  = ta.change(t_Main)

// --- Inputs: Overlays ---
groupD1 = "Daily Overlay (Previous Day)"
showD1 = input.bool(true, "Show Daily Overlay", group = groupD1)
d1Color = input.color(color.new(#ffeb3b, 92), "Daily Box Color", group = groupD1)
d1MedColor = input.color(color.new(#ffeb3b, 20), "Daily Median Color", group = groupD1)
d1MedStyle = input.string("Solid", "Daily Median Style", options = ["Solid", "Dashed", "Dotted"], group = groupD1)

groupH1 = "Hourly Overlay (Previous Hour)"
showH1 = input.bool(true, "Show Hourly Overlay", group = groupH1)
h1Color = input.color(color.new(#9c27b0, 85), "Hourly Box Color", group = groupH1)
h1MedColor = input.color(color.new(#ffeb3b, 30), "Hourly Median Color (Yellow)", group = groupH1)

// --- Inputs: Moving Averages ---
groupMAs = "Moving Averages"
ma1_on = input.bool(true, "MA 1", inline = "ma1", group = groupMAs)
ma1_type = input.string("SMA", "", options = ["SMA", "EMA", "WMA"], inline = "ma1", group = groupMAs)
ma1_len = input.int(200, "", minval = 1, inline = "ma1", group = groupMAs)
ma1_col = input.color(color.white, "", inline = "ma1", group = groupMAs)

ma2_on = input.bool(true, "MA 2", inline = "ma2", group = groupMAs)
ma2_type = input.string("SMA", "", options = ["SMA", "EMA", "WMA"], inline = "ma2", group = groupMAs)
ma2_len = input.int(20, "", minval = 1, inline = "ma2", group = groupMAs)
ma2_col = input.color(#40E0D0, "", inline = "ma2", group = groupMAs)

ma3_on = input.bool(false, "MA 3", inline = "ma3", group = groupMAs)
ma3_type = input.string("EMA", "", options = ["SMA", "EMA", "WMA"], inline = "ma3", group = groupMAs)
ma3_len = input.int(50, "", minval = 1, inline = "ma3", group = groupMAs)
ma3_col = input.color(color.orange, "", inline = "ma3", group = groupMAs)

ma4_on = input.bool(false, "MA 4", inline = "ma4", group = groupMAs)
ma4_type = input.string("EMA", "", options = ["SMA", "EMA", "WMA"], inline = "ma4", group = groupMAs)
ma4_len = input.int(100, "", minval = 1, inline = "ma4", group = groupMAs)
ma4_col = input.color(color.red, "", inline = "ma4", group = groupMAs)

// --- Inputs: Sessions ---
groupSessions = "Sessions (Manual Times)"
sessionStartColor = input.color(#089981, "Start Line Color", group = groupSessions)
sessionEndColor   = input.color(#f23645, "End Line Color", group = groupSessions)
sessionStartStyle = input.string("Solid", "Start Line Style", options = ["Solid", "Dashed", "Dotted"], group = groupSessions)
sessionEndStyle   = input.string("Solid", "End Line Style", options = ["Solid", "Dashed", "Dotted"], group = groupSessions)
sessionLineWidth  = input.int(1, "Line Width", minval = 1, maxval = 5, group = groupSessions)

asiaH_S = input.int(2, "Asia Start Hour", minval=0, maxval=23, group=groupSessions, inline="as")
asiaM_S = input.int(0, "Min", minval=0, maxval=59, group=groupSessions, inline="as")
asiaH_E = input.int(10, "Asia End Hour", minval=0, maxval=23, group=groupSessions, inline="ae")
asiaM_E = input.int(0, "Min", minval=0, maxval=59, group=groupSessions, inline="ae")

lonH_S = input.int(9, "London Start Hour", minval=0, maxval=23, group=groupSessions, inline="ls")
lonM_S = input.int(0, "Min", minval=0, maxval=59, group=groupSessions, inline="ls")
lonH_E = input.int(17, "London End Hour", minval=0, maxval=23, group=groupSessions, inline="le")
lonM_E = input.int(30, "Min", minval=0, maxval=59, group=groupSessions, inline="le")

nyH_S = input.int(15, "NY Start Hour", minval=0, maxval=23, group=groupSessions, inline="ns")
nyM_S = input.int(30, "Min", minval=0, maxval=59, group=groupSessions, inline="ns")
nyH_E = input.int(22, "NY End Hour", minval=0, maxval=23, group=groupSessions, inline="ne")
nyM_E = input.int(0, "Min", minval=0, maxval=59, group=groupSessions, inline="ne")

// --- Inputs: Grid ---
groupGrid = "Round Numbers Grid"
grid100Color = input.color(color.new(color.gray, 60), "100 Step Color", group = groupGrid)
grid50Color = input.color(color.new(color.gray, 80), "50 Step Color", group = groupGrid)
gridRange = input.int(2000, "Grid Range (Price Points)", minval = 500, group = groupGrid)

// --- Logic: Moving Averages ---
ma1 = ma1_type == "SMA" ? ta.sma(close, ma1_len) : ma1_type == "EMA" ? ta.ema(close, ma1_len) : ta.wma(close, ma1_len)
ma2 = ma2_type == "SMA" ? ta.sma(close, ma2_len) : ma2_type == "EMA" ? ta.ema(close, ma2_len) : ta.wma(close, ma2_len)
ma3 = ma3_type == "SMA" ? ta.sma(close, ma3_len) : ma3_type == "EMA" ? ta.ema(close, ma3_len) : ta.wma(close, ma3_len)
ma4 = ma4_type == "SMA" ? ta.sma(close, ma4_len) : ma4_type == "EMA" ? ta.ema(close, ma4_len) : ta.wma(close, ma4_len)

plot(ma1_on ? ma1 : na, "MA 1", color = ma1_col, linewidth = 2)
plot(ma2_on ? ma2 : na, "MA 2", color = ma2_col, linewidth = 2)
plot(ma3_on ? ma3 : na, "MA 3", color = ma3_col, linewidth = 2)
plot(ma4_on ? ma4 : na, "MA 4", color = ma4_col, linewidth = 2)

// --- Logic: Overlays ---
[prevH1High, prevH1Low] = request.security(syminfo.tickerid, "60", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[prevD1High, prevD1Low] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)

if showD1 and not na(change_D) and change_D != 0 and timeframe.isintraday
    float med = (prevD1High + prevD1Low) / 2
    int endT = t_Main + (24 * 60 * 60 * 1000)
    box.new(t_Main, prevD1High, endT, prevD1Low, xloc = xloc.bar_time, border_color = na, bgcolor = d1Color)
    line.new(t_Main, med, endT, med, xloc = xloc.bar_time, color = d1MedColor, width = 2, style = get_line_style(d1MedStyle))

if showH1 and not na(change_60) and change_60 != 0 and timeframe.isintraday and timeframe.multiplier < 60
    float med = (prevH1High + prevH1Low) / 2
    int endT = t_Main + (60 * 60 * 1000)
    box.new(t_Main, prevH1High, endT, prevH1Low, xloc = xloc.bar_time, border_color = na, bgcolor = h1Color)
    line.new(t_Main, med, endT, med, xloc = xloc.bar_time, color = h1MedColor, width = 2)

// --- Logic: Sessions ---
h = hour
m = minute
is_new_bar = not na(change_T) and change_T != 0

drawS(isStart, flag) =>
    color col = isStart ? sessionStartColor : sessionEndColor
    st = isStart ? get_line_style(sessionStartStyle) : get_line_style(sessionEndStyle)
    line.new(bar_index, 0, bar_index, 0, extend = extend.both, color = col, style = st, width = sessionLineWidth)
    if isStart
        label.new(bar_index, 0, flag, yloc = yloc.belowbar, style = label.style_none, size = size.normal, textcolor = chart.fg_color)

if timeframe.isintraday and is_new_bar
    if h == asiaH_S and m == asiaM_S
        drawS(true, "🇯🇵")
    if h == asiaH_E and m == asiaM_E
        drawS(false, "")
    if h == lonH_S and m == lonM_S
        drawS(true, "🇬🇧")
    if h == lonH_E and m == lonM_E
        drawS(false, "")
    if h == nyH_S and m == nyM_S
        drawS(true, "🇺🇸")
    if h == nyH_E and m == nyM_E
        drawS(false, "")

// --- Logic: Grid ---
if barstate.islast
    float midPrice = close
    float startGrid = math.floor((midPrice - gridRange / 2) / 100) * 100
    for i = 0 to (gridRange / 50)
        float level = startGrid + (i * 50)
        bool is100Step = math.round(level / 50) % 2 == 0
        line.new(bar_index - 1, level, bar_index, level, extend = extend.both, color = is100Step ? grid100Color : grid50Color, style = is100Step ? line.style_solid : line.style_dashed, width = 1)
````
