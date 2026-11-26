# ICT S1 by Joseph McGinnis Real Deal

- url: https://www.tradingview.com/script/MnDcHUfu-ICT-S1-by-Joseph-McGinnis-Real-Deal/
- type: indicator
- pine_id: PUB;15f88675e9ff4c4d88f81a7f6402b4f1
- version: 1.0

## Description

This must work because I love you guys. This must work because I love you guys. This must work because I love you guys. This must work because I love you guys. This must work because I love you guys. This must work because I love you guys. This must work because I love you guys. This must work because I love you guys.

## Source Code

````pine
//@version=5
indicator("ICT S1 by Joseph McGinnis", overlay=true, max_bars_back=500, max_lines_count=20)

show_sessions = input.bool(true, "Show Session Backgrounds")
show_panel    = input.bool(true, "Show Info Panel")
show_levels   = input.bool(true, "Show Stop/Target on Signal")

// ── BIAS ──
pdh = request.security(syminfo.tickerid, "D", high[1])
pdl = request.security(syminfo.tickerid, "D", low[1])
pde = (pdh + pdl) / 2
bull = close > pde

// ── DOL ──
sh = ta.pivothigh(high, 10, 10)
sl = ta.pivotlow(low, 10, 10)
var float dh = na
var float dl = na
if not na(sh)
    dh := sh
if not na(sl)
    dl := sl

// ── SESSIONS ──
h = hour(time, "America/New_York")
m = minute(time, "America/New_York")
is_london = h >= 3 and h < 8
is_nyam   = (h == 9 and m >= 30) or h == 10
is_nypm   = h >= 13 and h < 16
in_session = is_nyam or is_nypm
bgcolor(show_sessions and is_london ? color.new(#3366ff, 95) : na, title="London")
bgcolor(show_sessions and is_nyam   ? color.new(#00ffaa, 95) : na, title="NY AM")
bgcolor(show_sessions and is_nypm   ? color.new(#0088ff, 95) : na, title="NY PM")

// ── FVG (used for scoring only, not drawn) ──
bull_fvg = low[0] > high[2]
bear_fvg = high[0] < low[2]

// ── HTF BIAS ──
h4_mid = request.security(syminfo.tickerid, "240", (high[1] + low[1]) / 2)
h1_mid = request.security(syminfo.tickerid, "60", (high[1] + low[1]) / 2)
htf_bull = close > h4_mid and close > h1_mid
htf_bear = close < h4_mid and close < h1_mid
htf_aligned = (bull and htf_bull) or (not bull and htf_bear)

// ── BOS ──
bos_up = close > dh and close[1] <= dh
bos_dn = close < dl and close[1] >= dl

// ── RETEST REACTIONS ──
retest_bull = bull and low[1] <= pde and close > pde
retest_bear = not bull and high[1] >= pde and close < pde
retest_dol_bull = bull and low[1] <= dl and close > dl
retest_dol_bear = not bull and high[1] >= dh and close < dh

// ── CONFIDENCE SCORE (0-100) ──
score_long = 0.0
score_long += in_session ? 25 : 0
score_long += htf_bull ? 30 : 0
score_long += (retest_bull or retest_dol_bull) ? 25 : 0
score_long += bos_up ? 15 : 0
score_long += bull_fvg ? 5 : 0

score_short = 0.0
score_short += in_session ? 25 : 0
score_short += htf_bear ? 30 : 0
score_short += (retest_bear or retest_dol_bear) ? 25 : 0
score_short += bos_dn ? 15 : 0
score_short += bear_fvg ? 5 : 0

// ── ONLY FIRE AT 80%+ CONFIDENCE ──
var int last_long = 0
var int last_short = 0
long_sig  = bull and score_long >= 80 and (bar_index - last_long > 15)
short_sig = not bull and score_short >= 80 and (bar_index - last_short > 15)
if long_sig
    last_long := bar_index
if short_sig
    last_short := bar_index

plotshape(long_sig,  "BUY",  shape.labelup,   location.belowbar, #00ffaa, text="BUY 🚀", textcolor=color.black, size=size.large)
plotshape(short_sig, "SELL", shape.labeldown, location.abovebar, #ff3366, text="SELL 🔻", textcolor=color.white, size=size.large)

// ── STOP / TARGET ──
var line stop_line = na
var line target_line = na
if show_levels and long_sig
    risk = close - dl
    line.delete(stop_line)
    line.delete(target_line)
    stop_line   := line.new(bar_index, dl, bar_index + 20, dl, color=color.red, width=2, style=line.style_dashed)
    target_line := line.new(bar_index, close + risk * 2, bar_index + 20, close + risk * 2, color=color.green, width=2, style=line.style_dashed)
if show_levels and short_sig
    risk = dh - close
    line.delete(stop_line)
    line.delete(target_line)
    stop_line   := line.new(bar_index, dh, bar_index + 20, dh, color=color.red, width=2, style=line.style_dashed)
    target_line := line.new(bar_index, close - risk * 2, bar_index + 20, close - risk * 2, color=color.green, width=2, style=line.style_dashed)

// ── INFO PANEL ──
if show_panel and barstate.islast
    score = bull ? score_long : score_short
    var table t = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 75), border_width=1, border_color=color.new(color.white, 80))
    table.cell(t, 0, 0, "BIAS", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 0, bull ? "BULLISH" : "BEARISH", text_color=bull ? #00ffaa : #ff3366, text_size=size.small)
    table.cell(t, 0, 1, "HTF", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 1, htf_aligned ? "ALIGNED" : "WAIT", text_color=htf_aligned ? #00ffaa : #ffff00, text_size=size.small)
    table.cell(t, 0, 2, "CONFIDENCE", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(score, "#") + "%", text_color=score >= 80 ? #00ffaa : color.gray, text_size=size.small)

alertcondition(long_sig,  "ICT Long",  "BUY 🚀 - 80%+ Confidence")
alertcondition(short_sig, "ICT Short", "SELL 🔻 - 80%+ Confidence")
````
