# HIDDEN DIVERGANCE AND MARKET SENTIMENT SYSTEM 2026

- url: https://www.tradingview.com/script/4Cn0ezZo-HIDDEN-DIVERGANCE-AND-MARKET-SENTIMENT-SYSTEM-2026/
- type: indicator
- pine_id: PUB;1fd31d26107a49038245bf133ca59ca0
- version: 1.0

## Description

HIDDEN DIVERGENCE & MARKET SENTIMENT
​BY MALL
​This analytical system is a multi-layered engine designed to identify institutional trend continuation and overall market health across any asset class.
​Core Components:
​Sentiment Engine (MTF Scoring):
​Aggregates price action and momentum data from four timeframes: 15m, 1H, 4H, and 1D.
​Generates a weighted Total Score (0-100) to quantify the dominant market force.
​Score values above 70 indicate strong bullish sentiment, while values below 30 indicate strong bearish sentiment.
​Hidden Divergence Logic:
​Specifically tracks Hidden Bullish and Hidden Bearish divergences to confirm trend continuation.
​Hidden Bull: Identifies points where price makes a higher low while the momentum oscillator makes a lower low, signaling a high-probability continuation of the uptrend.
​These signals are integrated into the dashboard's "DIV" section for real-time monitoring.
​Institutional Bias & Risk Management:
​Calculates a High Timeframe (HTF) Bias (e.g., 6/8 or 8/8) to define the "line of least resistance".
​Includes an automated Execution Ban: When the HTF Bias is extreme (e.g., "Long Only"), the system flags a "BAN" on all counter-trend setups to prevent retail-side liquidity traps.
​Structural Alignment:
​Acts as a quantitative filter for complex geometric price structures.
​Allows for the verification of internal strength (Sentiment Score) against visual patterns like the "Three Peaks and a Domed House", providing data-driven confirmation of potential reversals or breakouts.
​Summary:
​The system replaces subjective "guessing" with a standardized mathematical approach to sentiment and momentum, applicable to Crypto, Forex, and Legacy Markets.
​ENGINEERED BY MALL

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MALL444
//@version=5
indicator("MALL SYSTEM 2026", overlay=false)

tf0 = input.timeframe("15",  "15min")
tf1 = input.timeframe("60",  "1H")
tf2 = input.timeframe("240", "4H")
tf3 = input.timeframe("D",   "1D")
tf_w = input.timeframe("W",  "Weekly")
cooldown = input.int(50, "Cooldown", minval=20, maxval=300)
table_pos = input.string("top_right", "Panel",
     options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"])

get_pos(p) =>
    p == "top_left" ? position.top_left : p == "top_center" ? position.top_center : p == "top_right" ? position.top_right : p == "middle_left" ? position.middle_left : p == "middle_center" ? position.middle_center : p == "middle_right" ? position.middle_right : p == "bottom_left" ? position.bottom_left : p == "bottom_center" ? position.bottom_center : position.bottom_right

get_data() =>
    _e8 = ta.ema(close, 8)
    _e21 = ta.ema(close, 21)
    _e55 = ta.ema(close, 55)
    [_, __, mh] = ta.macd(close, 12, 26, 9)
    _k = ta.stoch(close, high, low, 14)
    _r = ta.rsi(close, 14)
    _va = ta.sma(volume, 20)
    [close, open, high, low, volume, _va, _r, _e8, _e21, _e55, mh, _k, close[1], close[2]]

[c0,o0,h0,l0,v0,va0,r0,e80,e210,e550,mh0,k0,cp0,cp20] = request.security(syminfo.tickerid, tf0, get_data())
[c1,o1,h1,l1,v1,va1,r1,e81,e211,e551,mh1,k1,cp1,cp21] = request.security(syminfo.tickerid, tf1, get_data())
[c2,o2,h2,l2,v2,va2,r2,e82,e212,e552,mh2,k2,cp2,cp22] = request.security(syminfo.tickerid, tf2, get_data())
[c3,o3,h3,l3,v3,va3,r3,e83,e213,e553,mh3,k3,cp3,cp23] = request.security(syminfo.tickerid, tf3, get_data())

score(c, o, h, l, v, va, r, e8, e21, e55, mh, k, cp, cp2) =>
    s1 = c > o ? 1 : c < o ? -1 : 0
    rng = h - l
    pos = rng > 0 ? (c - l) / rng : 0.5
    s2 = pos >= 0.65 ? 1 : pos <= 0.35 ? -1 : 0
    s3 = e8 > e21 and e21 > e55 ? 1 : e8 < e21 and e21 < e55 ? -1 : 0
    s4 = r > 58 ? 1 : r < 42 ? -1 : 0
    s5 = mh > 0 ? 1 : mh < 0 ? -1 : 0
    s6 = c > o and v > va * 1.5 ? 1 : c < o and v > va * 1.5 ? -1 : 0
    s7 = k > 65 ? 1 : k < 35 ? -1 : 0
    s8 = c > cp and cp > cp2 ? 1 : c < cp and cp < cp2 ? -1 : 0
    s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8

norm(s) => math.round((s + 8) / 16 * 100)

n0 = norm(score(c0,o0,h0,l0,v0,va0,r0,e80,e210,e550,mh0,k0,cp0,cp20))
n1 = norm(score(c1,o1,h1,l1,v1,va1,r1,e81,e211,e551,mh1,k1,cp1,cp21))
n2 = norm(score(c2,o2,h2,l2,v2,va2,r2,e82,e212,e552,mh2,k2,cp2,cp22))
n3 = norm(score(c3,o3,h3,l3,v3,va3,r3,e83,e213,e553,mh3,k3,cp3,cp23))
sent_total = math.round(n0 * 0.10 + n1 * 0.20 + n2 * 0.30 + n3 * 0.40)

w_close = request.security(syminfo.tickerid, tf_w, close)
w_open  = request.security(syminfo.tickerid, tf_w, open)
w_ema21 = request.security(syminfo.tickerid, tf_w, ta.ema(close, 21))
d_close  = request.security(syminfo.tickerid, tf3, close)
d_open   = request.security(syminfo.tickerid, tf3, open)
d_ema21  = request.security(syminfo.tickerid, tf3, ta.ema(close, 21))
d_ema55  = request.security(syminfo.tickerid, tf3, ta.ema(close, 55))
d_ema200 = request.security(syminfo.tickerid, tf3, ta.ema(close, 200))

d_low20  = ta.lowest(request.security(syminfo.tickerid, tf3, low), 20)
d_high20 = ta.highest(request.security(syminfo.tickerid, tf3, high), 20)
range_pos = (d_close - d_low20) / math.max(d_high20 - d_low20, 1)
in_recovery = range_pos > 0.5 and d_close > d_ema21

weekly_above = w_close > w_ema21
daily_bull   = d_close > d_open
ema_stack    = d_ema21 > d_ema55

bias_pts = (w_close > w_open ? 1 : 0) + (weekly_above ? 1 : 0) + (daily_bull ? 1 : 0) + (d_close > d_ema21 ? 1 : 0) + (d_close > d_ema55 ? 1 : 0) + (d_close > d_ema200 ? 1 : 0) + (ema_stack ? 1 : 0) + (in_recovery ? 1 : 0)
short_banned = in_recovery and weekly_above and bias_pts >= 5

rsi = ta.rsi(close, 14)
[_, __, hist] = ta.macd(close, 12, 26, 9)
vol_osc = (ta.ema(volume, 5) - ta.ema(volume, 20)) / ta.ema(volume, 20) * 100
macd_norm = math.min(math.max((hist / close * 10000) + 50, 0), 100)
vol_norm  = math.min(math.max(vol_osc + 50, 0), 100)
composite = math.round(rsi * 0.40 + macd_norm * 0.35 + vol_norm * 0.25)
comp_sma  = ta.sma(composite, 10)

pivot_lb = 5
price_ph = ta.pivothigh(high, pivot_lb, pivot_lb)
price_pl = ta.pivotlow(low,  pivot_lb, pivot_lb)

var float p_high1 = na, var float p_high2 = na
var float p_low1  = na, var float p_low2  = na
var float c_high1 = na, var float c_high2 = na
var float c_low1  = na, var float c_low2  = na

if not na(price_ph)
    p_high2 := p_high1
    p_high1 := price_ph
    c_high2 := c_high1
    c_high1 := composite[pivot_lb]

if not na(price_pl)
    p_low2 := p_low1
    p_low1 := price_pl
    c_low2 := c_low1
    c_low1 := composite[pivot_lb]

bear_div = not na(p_high1) and not na(p_high2) and not na(c_high1) and not na(c_high2) and p_high1 > p_high2 and c_high1 < c_high2
bull_div = not na(p_low1) and not na(p_low2) and not na(c_low1) and not na(c_low2) and p_low1 < p_low2 and c_low1 > c_low2
hidden_bull = not na(p_low1) and not na(p_low2) and not na(c_low1) and not na(c_low2) and p_low1 > p_low2 and c_low1 < c_low2
hidden_bear = not na(p_high1) and not na(p_high2) and not na(c_high1) and not na(c_high2) and p_high1 < p_high2 and c_high1 > c_high2

rsi_bull_conf  = rsi < 50 and rsi > rsi[pivot_lb * 2]
macd_bull_conf = hist < 0 and hist > hist[pivot_lb * 2]
vol_bull_conf  = vol_osc < 0 and vol_osc > vol_osc[pivot_lb * 2]
rsi_bear_conf  = rsi > 50 and rsi < rsi[pivot_lb * 2]
macd_bear_conf = hist > 0 and hist < hist[pivot_lb * 2]
vol_bear_conf  = vol_osc > 0 and vol_osc < vol_osc[pivot_lb * 2]

bull_strength = (rsi_bull_conf ? 1 : 0) + (macd_bull_conf ? 1 : 0) + (vol_bull_conf ? 1 : 0)
bear_strength = (rsi_bear_conf ? 1 : 0) + (macd_bear_conf ? 1 : 0) + (vol_bear_conf ? 1 : 0)

col_comp = composite >= 70 ? color.new(#00ff88, 0) : composite >= 55 ? color.new(#00ff88, 50) : composite <= 30 ? color.new(#8b0000, 0) : composite <= 45 ? color.new(#ff4444, 50) : color.new(#FFD700, 30)

plot(composite,  "Composite", color=col_comp, linewidth=2, style=plot.style_area)
plot(comp_sma,   "Signal",    color=color.new(color.white, 50), linewidth=1)
plot(sent_total, "Sentiment", color=color.new(#1E90FF, 30), linewidth=1)

hline(75, "Bull", color=color.new(#00ff88, 50), linestyle=hline.style_dashed)
hline(50, "Mid",  color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(25, "Bear", color=color.new(#ff4444, 50), linestyle=hline.style_dashed)

bgcolor(composite >= 70 ? color.new(#ff4444, 95) : composite <= 30 ? color.new(#00ff88, 95) : na)

plotshape(bull_div and bull_strength >= 2, location=location.bottom, style=shape.labelup,   color=color.new(#00ff88,0), textcolor=color.black, text="DIV", size=size.small)
plotshape(bear_div and bear_strength >= 2, location=location.top,    style=shape.labeldown, color=color.new(#ff4444,0), textcolor=color.white, text="DIV", size=size.small)
plotshape(hidden_bull, location=location.bottom, style=shape.triangleup,   color=color.new(#00ff88,40), size=size.tiny)
plotshape(hidden_bear, location=location.top,    style=shape.triangledown, color=color.new(#ff4444,40), size=size.tiny)

core_bull = n0 >= 75 and n1 >= 75 and n2 >= 75
core_bear = n0 <= 25 and n1 <= 25 and n2 <= 25
mega_bull = core_bull and n3 >= 75
mega_bear = core_bear and n3 <= 25

var int last_bull_bar = -999
var int last_bear_bar = -999

new_mega_bull = mega_bull and not (n0[1] >= 75 and n1[1] >= 75 and n2[1] >= 75 and n3[1] >= 75) and (bar_index - last_bull_bar) >= cooldown
new_bull      = core_bull and not (n0[1] >= 75 and n1[1] >= 75 and n2[1] >= 75) and not mega_bull and (bar_index - last_bull_bar) >= cooldown
new_mega_bear = mega_bear and not (n0[1] <= 25 and n1[1] <= 25 and n2[1] <= 25 and n3[1] <= 25) and (bar_index - last_bear_bar) >= cooldown
new_bear      = core_bear and not (n0[1] <= 25 and n1[1] <= 25 and n2[1] <= 25) and not mega_bear and (bar_index - last_bear_bar) >= cooldown

if new_bull or new_mega_bull
    last_bull_bar := bar_index
if new_bear or new_mega_bear
    last_bear_bar := bar_index

plotshape(new_mega_bull, location=location.bottom, style=shape.labelup,   color=color.new(#00ff88,0), textcolor=color.black, text="🚀🚀", size=size.normal)
plotshape(new_bull,      location=location.bottom, style=shape.labelup,   color=color.new(#00ff88,0), textcolor=color.black, text="🚀",   size=size.small)
plotshape(new_mega_bear, location=location.top,    style=shape.labeldown, color=color.new(#ff4444,0), textcolor=color.white, text="⚠️⚠️", size=size.normal)
plotshape(new_bear,      location=location.top,    style=shape.labeldown, color=color.new(#ff4444,0), textcolor=color.white, text="⚠️",   size=size.small)

get_bar(v) => v >= 80 ? "████████" : v >= 65 ? "██████░░" : v >= 55 ? "████░░░░" : v >= 45 ? "████░░░░" : v >= 35 ? "██░░░░░░" : v >= 20 ? "█░░░░░░░" : "░░░░░░░░"
get_col(v) => v >= 55 ? color.new(#00ff88,0) : v <= 45 ? color.new(#cc2200,0) : color.new(#FFD700,0)
get_win(v) => v >= 75 ? "🚀🚀🚀" : v >= 60 ? "🚀🚀" : v >= 55 ? "🚀" : v <= 25 ? "⚠️⚠️⚠️" : v <= 40 ? "⚠️⚠️" : v <= 45 ? "⚠️" : "😐"
bg_core(b) => b and core_bull ? color.new(#00ff88,80) : b and core_bear ? color.new(#8b0000,80) : color.new(color.black,60)

div_txt = bull_div ? "BULL DIV " + str.tostring(bull_strength) + "/3" : bear_div ? "BEAR DIV " + str.tostring(bear_strength) + "/3" : hidden_bull ? "HIDDEN BULL" : hidden_bear ? "HIDDEN BEAR" : "NONE"
div_col = bull_div or hidden_bull ? color.new(#00ff88,0) : bear_div or hidden_bear ? color.new(#ff4444,0) : color.new(color.gray,0)
bias_col = bias_pts >= 5 ? color.new(#00ff88,0) : bias_pts <= 3 ? color.new(#cc2200,0) : color.new(#FFD700,0)
bias_label = bias_pts >= 6 ? "LONG ONLY" : bias_pts <= 2 ? "SHORT ONLY" : bias_pts >= 5 ? "PREFER LONG" : bias_pts <= 3 ? "PREFER SHORT" : "WAIT"

final_action = short_banned ? "NO SHORT" : bias_pts >= 6 and sent_total >= 60 and (bull_div or hidden_bull) ? "A+ LONG" : bias_pts >= 5 and sent_total >= 55 ? "LONG OK" : bias_pts <= 3 and sent_total <= 40 and (bear_div or hidden_bear) ? "A+ SHORT" : bias_pts <= 3 and sent_total <= 45 ? "SHORT OK" : "WAIT"
final_col = final_action == "A+ LONG" or final_action == "LONG OK" ? color.new(#00ff88,0) : final_action == "A+ SHORT" or final_action == "SHORT OK" ? color.new(#cc2200,0) : final_action == "NO SHORT" ? color.new(#ff4444,0) : color.new(#FFD700,0)

var table t = table.new(get_pos(table_pos), 4, 11, bgcolor=color.new(#0a0a0a,40), border_color=color.new(#333333,30), border_width=1, frame_color=color.new(#FFD700,40), frame_width=1)

if barstate.islast
    table.cell(t, 0, 0, "MALL 2026", text_color=#FFD700, text_size=size.normal, bgcolor=color.new(#111111,20))
    table.cell(t, 1, 0, "SCORE",     text_color=#FFD700, text_size=size.small,  bgcolor=color.new(#111111,20))
    table.cell(t, 2, 0, "POWER",     text_color=#FFD700, text_size=size.small,  bgcolor=color.new(#111111,20))
    table.cell(t, 3, 0, "WIN",       text_color=#FFD700, text_size=size.small,  bgcolor=color.new(#111111,20))
    table.cell(t, 0, 1, "15m", text_color=color.white, text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 1, 1, str.tostring(n0)+"/100", text_color=get_col(n0), text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 2, 1, get_bar(n0), text_color=get_col(n0), text_size=size.tiny, bgcolor=bg_core(true))
    table.cell(t, 3, 1, get_win(n0), text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 0, 2, "1H", text_color=color.white, text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 1, 2, str.tostring(n1)+"/100", text_color=get_col(n1), text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 2, 2, get_bar(n1), text_color=get_col(n1), text_size=size.tiny, bgcolor=bg_core(true))
    table.cell(t, 3, 2, get_win(n1), text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 0, 3, "4H", text_color=color.white, text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 1, 3, str.tostring(n2)+"/100", text_color=get_col(n2), text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 2, 3, get_bar(n2), text_color=get_col(n2), text_size=size.tiny, bgcolor=bg_core(true))
    table.cell(t, 3, 3, get_win(n2), text_size=size.small, bgcolor=bg_core(true))
    table.cell(t, 0, 4, "1D", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black,60))
    table.cell(t, 1, 4, str.tostring(n3)+"/100", text_color=get_col(n3), text_size=size.small, bgcolor=color.new(color.black,60))
    table.cell(t, 2, 4, get_bar(n3), text_color=get_col(n3), text_size=size.tiny, bgcolor=color.new(color.black,60))
    table.cell(t, 3, 4, get_win(n3), text_size=size.small, bgcolor=color.new(color.black,60))
    table.cell(t, 0, 5, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 1, 5, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 2, 5, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 3, 5, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 0, 6, "SENTIMENT", text_color=#FFD700, text_size=size.small)
    table.cell(t, 1, 6, str.tostring(sent_total)+"/100", text_color=get_col(sent_total), text_size=size.normal)
    table.cell(t, 2, 6, get_bar(sent_total), text_color=get_col(sent_total), text_size=size.tiny)
    table.cell(t, 3, 6, get_win(sent_total), text_size=size.small)
    table.cell(t, 0, 7, "HTF BIAS", text_color=#FFD700, text_size=size.small)
    table.cell(t, 1, 7, str.tostring(bias_pts)+"/8", text_color=bias_col, text_size=size.small)
    table.cell(t, 2, 7, bias_label, text_color=bias_col, text_size=size.small)
    table.cell(t, 3, 7, short_banned ? "BAN" : "OK", text_color=short_banned ? color.new(#ff4444,0) : color.new(color.gray,0), text_size=size.small)
    table.cell(t, 0, 8, "DIV", text_color=#FFD700, text_size=size.small)
    table.cell(t, 1, 8, div_txt, text_color=div_col, text_size=size.small)
    table.cell(t, 2, 8, composite >= 70 ? "OVERBOUGHT" : composite <= 30 ? "OVERSOLD" : "NEUTRAL", text_color=get_col(composite), text_size=size.tiny)
    table.cell(t, 3, 8, str.tostring(composite)+"/100", text_color=get_col(composite), text_size=size.small)
    table.cell(t, 0, 9, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 1, 9, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 2, 9, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 3, 9, "------", text_color=color.new(color.gray,60), text_size=size.tiny)
    table.cell(t, 0, 10, "ACTION", text_color=#FFD700, text_size=size.small)
    table.cell(t, 1, 10, final_action, text_color=final_col, text_size=size.large)
    table.cell(t, 2, 10, final_action == "A+ LONG" or final_action == "A+ SHORT" ? "ALL ALIGNED" : "", text_color=final_col, text_size=size.tiny)
    table.cell(t, 3, 10, short_banned ? "NO SHORT" : "", text_color=color.new(#ff4444,0), text_size=size.tiny)

alertcondition(new_bull,      "🚀 BULL",        "15m+1H+4H bullish")
alertcondition(new_bear,      "⚠️ BEAR",        "15m+1H+4H bearish")
alertcondition(new_mega_bull, "🚀🚀 MEGA BULL",  "All 4 TF bullish")
alertcondition(new_mega_bear, "⚠️⚠️ MEGA BEAR", "All 4 TF bearish")
alertcondition(bull_div and bull_strength >= 2, "DIV BULL", "Bullish divergence confirmed")
alertcondition(bear_div and bear_strength >= 2, "DIV BEAR", "Bearish divergence confirmed")
alertcondition(short_banned, "🚫 SHORT BAN", "Recovery — no shorts")
````
