# ULTIMATE SYSTEM by MaLL

- url: https://www.tradingview.com/script/KUPh3MDZ-ULTIMATE-SYSTEM-by-MaLL/
- type: indicator
- pine_id: PUB;6dab2dcad9de4c289be56c4b96ec783b
- version: 1.0

## Description

ULTIMATE SYSTEM — EMA Structure + Multi-TF Sentiment + Bias Filter
by MaLL[s][/s]
One chart. One system. No noise.
MALL ULTIMATE combines three independent edge layers into a single clean overlay — giving you HTF structure, real-time sentiment, and directional bias simultaneously, without cluttering your chart with unnecessary indicators. LAYER 1 — HTF EMA STRUCTURE
Daily and 4H EMAs (21 / 55 / 200) rendered directly on any timeframe chart. See the big picture compression and expansion at a glance. Know exactly where price sits relative to the major moving averages that institutions actually watch — without switching timeframes. LAYER 2 — MULTI-TIMEFRAME SENTIMENT ENGINE
Eight technical confluence factors scored simultaneously across 15min, 1H, 4H, and 1D — each vote contributing to a weighted total score (0–100). The scoreboard shows who controls each timeframe in real time.
Factors measured per TF: candle direction, close position in range, EMA stack alignment, RSI zone, MACD histogram, volume confirmation, Stochastic positioning, Higher High / Lower Low structure.
Signals appear only when 15min + 1H + 4H align simultaneously above threshold. Double signal when all 4 TF confirm. Built-in cooldown eliminates spam — every 🚀 or ⚠️ means something. LAYER 3 — HTF BIAS FILTER 2026
Eight-point macro scoring system built specifically for the BTC 2026 market structure — volatile, recovery-driven, with sharp bear traps and relief rallies that destroy undisciplined shorts.
Measures: Weekly candle direction, Weekly EMA position, Daily candle, Daily EMA 21/55/200 positioning, EMA stack alignment, and Recovery Mode detection.
SHORT BAN activates automatically when the market is in recovery phase — the feature built directly from months of painful experience shorting relief rallies.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MALL444
//@version=5
indicator("MALL ULTIMATE by MaLL", overlay=true)

// ═══ SETTINGS ═══
show_ema     = input.bool(true,  "Show EMA Lines")
show_sent    = input.bool(true,  "Show Sentiment Panel")
show_emoji   = input.bool(true,  "Show Signals on Chart")
tf0          = input.timeframe("15",  "TF 15min")
tf1          = input.timeframe("60",  "TF 1H")
tf2          = input.timeframe("240", "TF 4H")
tf3          = input.timeframe("D",   "TF Daily")
tf_w         = input.timeframe("W",   "TF Weekly")
cooldown     = input.int(50, "Signal Cooldown", minval=20, maxval=300)
table_pos    = input.string("top_right", "Panel Position", options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"])

get_pos(p) =>
    p == "top_left" ? position.top_left : p == "top_center" ? position.top_center : p == "top_right" ? position.top_right : p == "middle_left" ? position.middle_left : p == "middle_center" ? position.middle_center : p == "middle_right" ? position.middle_right : p == "bottom_left" ? position.bottom_left : p == "bottom_center" ? position.bottom_center : position.bottom_right

// ═══ EMA — Daily + H4 compressed ═══
d_ema21  = request.security(syminfo.tickerid, tf3, ta.ema(close, 21))
d_ema55  = request.security(syminfo.tickerid, tf3, ta.ema(close, 55))
d_ema200 = request.security(syminfo.tickerid, tf3, ta.ema(close, 200))
h4_ema21 = request.security(syminfo.tickerid, tf2, ta.ema(close, 21))
h4_ema55 = request.security(syminfo.tickerid, tf2, ta.ema(close, 55))

plot(show_ema ? d_ema21  : na, "D EMA 21",  color=color.new(#00ff88, 20), linewidth=2)
plot(show_ema ? d_ema55  : na, "D EMA 55",  color=color.new(#FFD700, 20), linewidth=2)
plot(show_ema ? d_ema200 : na, "D EMA 200", color=color.new(#ff4444, 10), linewidth=3)
plot(show_ema ? h4_ema21 : na, "H4 EMA 21", color=color.new(#00ff88, 60), linewidth=1, style=plot.style_circles)
plot(show_ema ? h4_ema55 : na, "H4 EMA 55", color=color.new(#FFD700, 60), linewidth=1, style=plot.style_circles)

// ═══ BIAS DATA ═══
d_close  = request.security(syminfo.tickerid, tf3, close)
d_open   = request.security(syminfo.tickerid, tf3, open)
w_close  = request.security(syminfo.tickerid, tf_w, close)
w_open   = request.security(syminfo.tickerid, tf_w, open)
w_ema21  = request.security(syminfo.tickerid, tf_w, ta.ema(close, 21))

d_low20     = ta.lowest(request.security(syminfo.tickerid, tf3, low), 20)
d_high20    = ta.highest(request.security(syminfo.tickerid, tf3, high), 20)
range_pos   = (d_close - d_low20) / math.max(d_high20 - d_low20, 1)
in_recovery = range_pos > 0.5 and d_close > d_ema21
weekly_above = w_close > w_ema21
ema_stack    = d_ema21 > d_ema55

bias_pts = (w_close > w_open ? 1 : 0) + (weekly_above ? 1 : 0) + (d_close > d_open ? 1 : 0) + (d_close > d_ema21 ? 1 : 0) + (d_close > d_ema55 ? 1 : 0) + (d_close > d_ema200 ? 1 : 0) + (ema_stack ? 1 : 0) + (in_recovery ? 1 : 0)
short_banned = in_recovery and weekly_above and bias_pts >= 5

// ═══ SENTIMENT ═══
get_data() =>
    _e8  = ta.ema(close, 8)
    _e21 = ta.ema(close, 21)
    _e55 = ta.ema(close, 55)
    [_, __, mh] = ta.macd(close, 12, 26, 9)
    _k  = ta.stoch(close, high, low, 14)
    _r  = ta.rsi(close, 14)
    _va = ta.sma(volume, 20)
    [close, open, high, low, volume, _va, _r, _e8, _e21, _e55, mh, _k, close[1], close[2]]

[c0,o0,h0,l0,v0,va0,r0,e80,e210,e550,mh0,k0,cp0,cp20] = request.security(syminfo.tickerid, tf0, get_data())
[c1,o1,h1,l1,v1,va1,r1,e81,e211,e551,mh1,k1,cp1,cp21] = request.security(syminfo.tickerid, tf1, get_data())
[c2,o2,h2,l2,v2,va2,r2,e82,e212,e552,mh2,k2,cp2,cp22] = request.security(syminfo.tickerid, tf2, get_data())
[c3,o3,h3,l3,v3,va3,r3,e83,e213,e553,mh3,k3,cp3,cp23] = request.security(syminfo.tickerid, tf3, get_data())

score(c,o,h,l,v,va,r,e8,e21,e55,mh,k,cp,cp2) =>
    s1 = c > o ? 1 : c < o ? -1 : 0
    rng = h - l
    pos = rng > 0 ? (c-l)/rng : 0.5
    s2 = pos >= 0.65 ? 1 : pos <= 0.35 ? -1 : 0
    s3 = e8 > e21 and e21 > e55 ? 1 : e8 < e21 and e21 < e55 ? -1 : 0
    s4 = r > 58 ? 1 : r < 42 ? -1 : 0
    s5 = mh > 0 ? 1 : mh < 0 ? -1 : 0
    s6 = c > o and v > va*1.5 ? 1 : c < o and v > va*1.5 ? -1 : 0
    s7 = k > 65 ? 1 : k < 35 ? -1 : 0
    s8 = c > cp and cp > cp2 ? 1 : c < cp and cp < cp2 ? -1 : 0
    s1+s2+s3+s4+s5+s6+s7+s8

norm(s) => math.round((s+8)/16*100)

n0 = norm(score(c0,o0,h0,l0,v0,va0,r0,e80,e210,e550,mh0,k0,cp0,cp20))
n1 = norm(score(c1,o1,h1,l1,v1,va1,r1,e81,e211,e551,mh1,k1,cp1,cp21))
n2 = norm(score(c2,o2,h2,l2,v2,va2,r2,e82,e212,e552,mh2,k2,cp2,cp22))
n3 = norm(score(c3,o3,h3,l3,v3,va3,r3,e83,e213,e553,mh3,k3,cp3,cp23))
total = math.round(n0*0.10 + n1*0.20 + n2*0.30 + n3*0.40)

// ═══ SIGNALS ═══
core_bull = n0 >= 75 and n1 >= 75 and n2 >= 75
core_bear = n0 <= 25 and n1 <= 25 and n2 <= 25
mega_bull = core_bull and n3 >= 75
mega_bear = core_bear and n3 <= 25

var int last_bull = -999
var int last_bear = -999

new_mega_bull = mega_bull and not (n0[1]>=75 and n1[1]>=75 and n2[1]>=75 and n3[1]>=75) and (bar_index-last_bull)>=cooldown
new_bull      = core_bull and not (n0[1]>=75 and n1[1]>=75 and n2[1]>=75) and not mega_bull and (bar_index-last_bull)>=cooldown
new_mega_bear = mega_bear and not (n0[1]<=25 and n1[1]<=25 and n2[1]<=25 and n3[1]<=25) and (bar_index-last_bear)>=cooldown
new_bear      = core_bear and not (n0[1]<=25 and n1[1]<=25 and n2[1]<=25) and not mega_bear and (bar_index-last_bear)>=cooldown

if new_bull or new_mega_bull
    last_bull := bar_index
if new_bear or new_mega_bear
    last_bear := bar_index

if show_emoji
    if new_mega_bull
        label.new(bar_index, low*0.998, "🚀🚀", color=color.new(color.black,100), textcolor=color.white, style=label.style_label_up, size=size.large)
    else if new_bull
        label.new(bar_index, low*0.999, "🚀", color=color.new(color.black,100), textcolor=color.white, style=label.style_label_up, size=size.normal)
    if new_mega_bear
        label.new(bar_index, high*1.002, "⚠️⚠️", color=color.new(color.black,100), textcolor=color.white, style=label.style_label_down, size=size.large)
    else if new_bear
        label.new(bar_index, high*1.001, "⚠️", color=color.new(color.black,100), textcolor=color.white, style=label.style_label_down, size=size.normal)

// ═══ PANEL ═══
get_bar(v) => v>=80?"████████":v>=65?"██████░░":v>=55?"████░░░░":v>=45?"████░░░░":v>=35?"██░░░░░░":v>=20?"█░░░░░░░":"░░░░░░░░"
get_win(v) => v>=75?"🚀🚀🚀":v>=60?"🚀🚀":v>=55?"🚀":v<=25?"⚠️⚠️⚠️":v<=40?"⚠️⚠️":v<=45?"⚠️":"😐"
get_col(v) => v>=55?color.new(#00ff88,0):v<=45?color.new(#cc2200,0):color.new(#FFD700,0)
bg_row(b)  => b and core_bull?color.new(#00ff88,80):b and core_bear?color.new(#8b0000,80):color.new(color.black,60)
get_lbl(v) => v>=80?"STRONG BULL":v>=65?"BULL":v>=55?"WEAK BULL":v<=20?"STRONG BEAR":v<=35?"BEAR":v<=45?"WEAK BEAR":"NEUTRAL"

bias_col = bias_pts>=5?color.new(#00ff88,0):bias_pts<=3?color.new(#cc2200,0):color.new(#FFD700,0)
bias_txt = short_banned?"NO SHORT":bias_pts>=6?"LONG":bias_pts<=2?"SHORT":bias_pts>=5?"PREFER L":"WAIT"

var table t = table.new(get_pos(table_pos), 4, 9, bgcolor=color.new(#0a0a0a,40), border_color=color.new(#333333,30), border_width=1, frame_color=color.new(#FFD700,40), frame_width=1)

if show_sent and barstate.islast
    table.cell(t,0,0,"SENTIMENT",text_color=#FFD700,text_size=size.small,bgcolor=color.new(#111111,20))
    table.cell(t,1,0,"SCORE",text_color=#FFD700,text_size=size.small,bgcolor=color.new(#111111,20))
    table.cell(t,2,0,"POWER",text_color=#FFD700,text_size=size.small,bgcolor=color.new(#111111,20))
    table.cell(t,3,0,"WIN",text_color=#FFD700,text_size=size.small,bgcolor=color.new(#111111,20))
    table.cell(t,0,1,"15m",text_color=color.white,text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,1,1,str.tostring(n0)+"/100",text_color=get_col(n0),text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,2,1,get_bar(n0),text_color=get_col(n0),text_size=size.tiny,bgcolor=bg_row(true))
    table.cell(t,3,1,get_win(n0),text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,0,2,"1H",text_color=color.white,text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,1,2,str.tostring(n1)+"/100",text_color=get_col(n1),text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,2,2,get_bar(n1),text_color=get_col(n1),text_size=size.tiny,bgcolor=bg_row(true))
    table.cell(t,3,2,get_win(n1),text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,0,3,"4H",text_color=color.white,text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,1,3,str.tostring(n2)+"/100",text_color=get_col(n2),text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,2,3,get_bar(n2),text_color=get_col(n2),text_size=size.tiny,bgcolor=bg_row(true))
    table.cell(t,3,3,get_win(n2),text_size=size.small,bgcolor=bg_row(true))
    table.cell(t,0,4,"1D",text_color=color.white,text_size=size.small,bgcolor=color.new(color.black,60))
    table.cell(t,1,4,str.tostring(n3)+"/100",text_color=get_col(n3),text_size=size.small,bgcolor=color.new(color.black,60))
    table.cell(t,2,4,get_bar(n3),text_color=get_col(n3),text_size=size.tiny,bgcolor=color.new(color.black,60))
    table.cell(t,3,4,get_win(n3),text_size=size.small,bgcolor=color.new(color.black,60))
    table.cell(t,0,5,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,1,5,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,2,5,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,3,5,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,0,6,"TOTAL",text_color=#FFD700,text_size=size.small)
    table.cell(t,1,6,str.tostring(total)+"/100",text_color=get_col(total),text_size=size.normal)
    table.cell(t,2,6,get_bar(total),text_color=get_col(total),text_size=size.tiny)
    table.cell(t,3,6,get_lbl(total),text_color=get_col(total),text_size=size.small)
    table.cell(t,0,7,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,1,7,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,2,7,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,3,7,"------",text_color=color.new(color.gray,60),text_size=size.tiny)
    table.cell(t,0,8,"BIAS "+str.tostring(bias_pts)+"/8",text_color=bias_col,text_size=size.small)
    table.cell(t,1,8,bias_txt,text_color=bias_col,text_size=size.small)
    table.cell(t,2,8,short_banned?"NO SHORT":"",text_color=color.new(#cc2200,0),text_size=size.tiny)
    table.cell(t,3,8,in_recovery?"RECOVERY":"",text_color=color.new(#FFD700,0),text_size=size.tiny)

alertcondition(new_bull,      "🚀 BULL",       "15m+1H+4H bullish")
alertcondition(new_bear,      "⚠️ BEAR",       "15m+1H+4H bearish")
alertcondition(new_mega_bull, "🚀🚀 MEGA BULL", "All 4 TF bullish")
alertcondition(new_mega_bear, "⚠️⚠️ MEGA BEAR","All 4 TF bearish")
alertcondition(short_banned,  "🚫 NO SHORT",   "Recovery mode")
````
