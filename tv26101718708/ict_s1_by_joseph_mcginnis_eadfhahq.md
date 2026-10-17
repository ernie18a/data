# ICT S1 by Joseph McGinnis

- url: https://www.tradingview.com/script/EADfHAHq-ICT-S1-by-Joseph-McGinnis/
- type: indicator
- pine_id: PUB;961a4f81de7548da9a1e9fd811a6b2ff
- version: 1.0

## Description

I believe we can do all things under Christ. I believe we can do all things under Christ. I believe we can do all things under Christ. I believe we can do all things under Christ. I believe we can do all things under Christ. I believe we can do all things under Christ. I believe we can do all things under Christ.

## Source Code

````pine
//@version=5
indicator("ICT S1 by Joseph McGinnis", overlay=true, max_bars_back=500, max_boxes_count=50, max_lines_count=20)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
show_fvg = input.bool(true, "Show FVG Boxes")
show_sessions = input.bool(true, "Show Session Backgrounds")
show_panel = input.bool(true, "Show Info Panel")
show_levels = input.bool(true, "Show Stop/Target on Signal")

// ─── BIAS ────────────────────────────────────────────────────────────────────
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])
pde = (pdh + pdl) / 2
bull = close > pde
plot(pde, "Mid", color=bull ? #00ffaa : #ff3366, linewidth=2)

// ─── DOL ─────────────────────────────────────────────────────────────────────
sh = ta.pivothigh(high, 10, 10)
sl = ta.pivotlow(low, 10, 10)
var float dh = na
var float dl = na
if not na(sh)
    dh := sh
if not na(sl)
    dl := sl
plot(dh, "DOL High", color=color.new(#ff9900, 50), linewidth=1, style=plot.style_stepline)
plot(dl, "DOL Low", color=color.new(#ff9900, 50), linewidth=1, style=plot.style_stepline)

// ─── SESSIONS ────────────────────────────────────────────────────────────────
h = hour(time, "America/New_York")
m = minute(time, "America/New_York")
is_london = h >= 3 and h < 8
is_nyam = (h == 9 and m >= 30) or h == 10
is_nypm = h >= 13 and h < 16
in_session = is_nyam or is_nypm
bgcolor(show_sessions and is_london ? color.new(#3366ff, 95) : na, title="London")
bgcolor(show_sessions and is_nyam ? color.new(#00ffaa, 95) : na, title="NY AM")
bgcolor(show_sessions and is_nypm ? color.new(#0088ff, 95) : na, title="NY PM")

// ─── FVG BOXES ───────────────────────────────────────────────────────────────
bull_fvg = low[0] > high[2]
bear_fvg = high[0] < low[2]
if show_fvg and bull_fvg
    box.new(bar_index - 2, low[0], bar_index + 20, high[2], border_color=color.new(#00ffaa, 40), bgcolor=color.new(#00ffaa, 88), border_width=1)
if show_fvg and bear_fvg
    box.new(bar_index - 2, low[2], bar_index + 20, high[0], border_color=color.new(#ff3366, 40), bgcolor=color.new(#ff3366, 88), border_width=1)

// ─── HTF BIAS ────────────────────────────────────────────────────────────────
h4_mid = request.security(syminfo.tickerid, "240", (high[1] + low[1]) / 2)
h1_mid = request.security(syminfo.tickerid, "60", (high[1] + low[1]) / 2)
htf_bull = close > h4_mid or close > h1_mid
htf_bear = close < h4_mid or close < h1_mid
htf_aligned = (bull and htf_bull) or (not bull and htf_bear)

// ─── WARNINGS ────────────────────────────────────────────────────────────────
near_mid = math.abs(close - pde) / pde < 0.003
near_dol_low = not na(dl) and math.abs(close - dl) / dl < 0.003
near_dol_high = not na(dh) and math.abs(close - dh) / dh < 0.003
approaching_bull = in_session and htf_bull and bull and (near_mid or near_dol_low)
approaching_bear = in_session and htf_bear and not bull and (near_mid or near_dol_high)
var int last_warn_bull = 0
var int last_warn_bear = 0
warn_bull = approaching_bull and not approaching_bull[1] and (bar_index - last_warn_bull > 10)
warn_bear = approaching_bear and not approaching_bear[1] and (bar_index - last_warn_bear > 10)
if warn_bull
    last_warn_bull := bar_index
if warn_bear
    last_warn_bear := bar_index

// ─── SIGNALS ─────────────────────────────────────────────────────────────────
retest_bull = bull and low[1] <= pde and close > pde
retest_bear = not bull and high[1] >= pde and close < pde
retest_dol_bull = bull and low[1] <= dl and close > dl
retest_dol_bear = not bull and high[1] >= dh and close < dh
retest_fvg_bull = bull and bull_fvg and close > open
retest_fvg_bear = not bull and bear_fvg and close < open
long_sig = in_session and htf_bull and (retest_bull or retest_dol_bull or retest_fvg_bull)
short_sig = in_session and htf_bear and (retest_bear or retest_dol_bear or retest_fvg_bear)

plotshape(warn_bull, "READY LONG", shape.diamond, location.belowbar, color.new(#ffff00, 0), size=size.tiny, text="⚡")
plotshape(warn_bear, "READY SHORT", shape.diamond, location.abovebar, color.new(#ffff00, 0), size=size.tiny, text="⚡")
plotshape(long_sig, "BUY", shape.labelup, location.belowbar, #00ffaa, text="BUY 🚀", textcolor=color.black, size=size.normal)
plotshape(short_sig, "SELL", shape.labeldown, location.abovebar, #ff3366, text="SELL 🔻", textcolor=color.white, size=size.normal)

// ─── STOP AND TARGET ────────────────────────────────────────────────────────
var line stop_line = na
var line target_line = na
if show_levels and long_sig
    risk = close - dl
    line.delete(stop_line)
    line.delete(target_line)
    stop_line := line.new(bar_index, dl, bar_index + 20, dl, color=color.red, width=2, style=line.style_dashed)
    target_line := line.new(bar_index, close + risk * 2, bar_index + 20, close + risk * 2, color=color.green, width=2, style=line.style_dashed)
if show_levels and short_sig
    risk = dh - close
    line.delete(stop_line)
    line.delete(target_line)
    stop_line := line.new(bar_index, dh, bar_index + 20, dh, color=color.red, width=2, style=line.style_dashed)
    target_line := line.new(bar_index, close - risk * 2, bar_index + 20, close - risk * 2, color=color.green, width=2, style=line.style_dashed)

// ─── INFO PANEL ──────────────────────────────────────────────────────────────
if show_panel and barstate.islast
    var table t = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 75), border_width=1, border_color=color.new(color.white, 80))
    table.cell(t, 0, 0, "BIAS", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 0, bull ? "BULLISH" : "BEARISH", text_color=bull ? #00ffaa : #ff3366, text_size=size.small)
    table.cell(t, 0, 1, "HTF", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, htf_aligned ? "ALIGNED" : "CONFLICT", text_color=htf_aligned ? #00ffaa : #ffff00, text_size=size.small)
    sess_text = is_nyam ? "NY AM" : is_nypm ? "NY PM" : is_london ? "LONDON" : "CLOSED"
    table.cell(t, 0, 2, "SESSION", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, sess_text, text_color=in_session ? #00ffaa : color.gray, text_size=size.small)
    table.cell(t, 0, 3, "PDH", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(pdh, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 4, "PDL", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(pdl, "#.##"), text_color=color.white, text_size=size.small)

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(warn_bull, "GET READY LONG", "⚡ Approaching BUY level - Get Ready!")
alertcondition(warn_bear, "GET READY SHORT", "⚡ Approaching SELL level - Get Ready!")
alertcondition(long_sig, "ICT Long", "BUY 🚀 - Enter Long Now")
alertcondition(short_sig, "ICT Short", "SELL 🔻 - Enter Short Now")
````
