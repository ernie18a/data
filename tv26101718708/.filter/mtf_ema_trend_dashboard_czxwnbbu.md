# MTF EMA Trend Dashboard

- url: https://www.tradingview.com/script/CZxWNBbu/
- type: indicator
- pine_id: PUB;d753dbb8e6e6437f8214ffb163c51dd2
- version: 1.0

## Description

Multi-timeframe trend dashboard built in Pine Script v6. Shows EMA-based trend direction across 5 user-configurable timeframes in a clean on-chart table. Useful as a confluence filter for entries on lower timeframes. Alerts trigger when all timeframes align bullish or bearish. Open source — free to use and modify. Feedback welcome.

## Source Code

````pine
//@version=6
// ============================================================================
// Multi-Timeframe EMA Trend Dashboard
// Author: Roberto [Cognome]
// Open source — free to use, modify, and learn from.
// ============================================================================

indicator("MTF EMA Trend Dashboard", overlay = true)

// ---------- Inputs ----------
grpEma = "EMA Settings"
emaFastLen = input.int(20, "Fast EMA Length", minval = 1, group = grpEma)
emaSlowLen = input.int(50, "Slow EMA Length", minval = 1, group = grpEma)

grpTf = "Timeframes"
tf1 = input.timeframe("15",  "TF 1", group = grpTf)
tf2 = input.timeframe("60",  "TF 2", group = grpTf)
tf3 = input.timeframe("240", "TF 3", group = grpTf)
tf4 = input.timeframe("D",   "TF 4", group = grpTf)
tf5 = input.timeframe("W",   "TF 5", group = grpTf)

grpDisp = "Display"
tablePos = input.string("top_right", "Dashboard Position",
     options = ["top_right", "top_left", "bottom_right", "bottom_left"],
     group = grpDisp)
showLocalEmas = input.bool(true, "Show EMAs on Current Chart", group = grpDisp)

// ---------- Logic ----------
f_trend(tf) =>
    fast = request.security(syminfo.tickerid, tf, ta.ema(close, emaFastLen), lookahead = barmerge.lookahead_off)
    slow = request.security(syminfo.tickerid, tf, ta.ema(close, emaSlowLen), lookahead = barmerge.lookahead_off)
    fast > slow ? 1 : fast < slow ? -1 : 0

t1 = f_trend(tf1)
t2 = f_trend(tf2)
t3 = f_trend(tf3)
t4 = f_trend(tf4)
t5 = f_trend(tf5)

// Local EMAs (current chart)
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
plot(showLocalEmas ? emaFast : na, "EMA Fast", color = color.new(color.aqua,   0), linewidth = 2)
plot(showLocalEmas ? emaSlow : na, "EMA Slow", color = color.new(color.orange, 0), linewidth = 2)

// ---------- Dashboard ----------
var table dash = table.new(
     position = tablePos == "top_right"    ? position.top_right    :
                tablePos == "top_left"     ? position.top_left     :
                tablePos == "bottom_right" ? position.bottom_right :
                                             position.bottom_left,
     columns = 2, rows = 6, border_width = 1)

f_color(t) => t == 1 ? color.new(color.green, 20) : t == -1 ? color.new(color.red, 20) : color.new(color.gray, 30)
f_label(t) => t == 1 ? "▲ UP" : t == -1 ? "▼ DOWN" : "— FLAT"

if barstate.islast
    table.cell(dash, 0, 0, "Timeframe", bgcolor = color.new(color.black, 30), text_color = color.white)
    table.cell(dash, 1, 0, "Trend",     bgcolor = color.new(color.black, 30), text_color = color.white)
    table.cell(dash, 0, 1, tf1, text_color = color.white)
    table.cell(dash, 1, 1, f_label(t1), bgcolor = f_color(t1), text_color = color.white)
    table.cell(dash, 0, 2, tf2, text_color = color.white)
    table.cell(dash, 1, 2, f_label(t2), bgcolor = f_color(t2), text_color = color.white)
    table.cell(dash, 0, 3, tf3, text_color = color.white)
    table.cell(dash, 1, 3, f_label(t3), bgcolor = f_color(t3), text_color = color.white)
    table.cell(dash, 0, 4, tf4, text_color = color.white)
    table.cell(dash, 1, 4, f_label(t4), bgcolor = f_color(t4), text_color = color.white)
    table.cell(dash, 0, 5, tf5, text_color = color.white)
    table.cell(dash, 1, 5, f_label(t5), bgcolor = f_color(t5), text_color = color.white)

// ---------- Alerts ----------
allUp   = t1 == 1  and t2 == 1  and t3 == 1  and t4 == 1  and t5 == 1
allDown = t1 == -1 and t2 == -1 and t3 == -1 and t4 == -1 and t5 == -1
alertcondition(allUp,   "All Timeframes Bullish", "All 5 timeframes: fast EMA above slow EMA")
alertcondition(allDown, "All Timeframes Bearish", "All 5 timeframes: fast EMA below slow EMA")
````
