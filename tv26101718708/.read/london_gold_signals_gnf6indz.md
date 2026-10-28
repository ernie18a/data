# London Gold Signals

- url: https://www.tradingview.com/script/GNf6iNDz-London-Gold-Signals/
- type: indicator
- pine_id: PUB;6333735de35a4ac486f69a31de1102ab
- version: 1.0

## Description

London Gold Session Bias tracks institutional gold trading setups during the London session and London/NY overlap — the two highest-volume windows for GC/MGC futures.

The indicator monitors four key confluence factors in real time:

• Asia Session Range — identifies the overnight high/low that London is expected to break, flags breakouts and breakdowns as directional triggers

• VWAP — tracks whether price is trading above or below the session anchor, used by institutional algorithms as a key reference

• LBMA Fix Window — highlights the 10:20–10:45 ET gold fix period, a known structural reversal zone

• 8:30 ET News Level — marks the news candle high/low and signals when price retests those levels during the overlap session

All four signals vote on a real-time LONG / SHORT / NEUTRAL overall bias displayed in a clean status table. When bias is confirmed, the indicator automatically draws an entry zone, three take profit levels (TP1 quick scalp, TP2 main target, TP3 runner), and a stop loss — all as labeled horizontal lines directly on the chart.

Levels auto-adjust each bar and dim outside active session hours so you always have context heading into the London open.

Best used on GC or MGC futures on the 5m or 15m timeframe. All session times are based on US Eastern Time (ET).

## Source Code

````pine
//@version=6
indicator("London Gold Signals", overlay=true, max_labels_count=20, max_lines_count=20)

tz = "America/New_York"

in_asia    = not na(time(timeframe.period, "1800-0200", tz))
in_london  = not na(time(timeframe.period, "0300-0800", tz))
in_overlap = not na(time(timeframe.period, "0800-1200", tz))
in_active  = in_london or in_overlap
in_lbma    = not na(time(timeframe.period, "1020-1045", tz))
in_830     = not na(time(timeframe.period, "0830-0831", tz))

// ── ASIA RANGE ──────────────────────────────────────────────
var float asia_hi = na
var float asia_lo = na
var float prev_hi = na
var float prev_lo = na

if in_asia and not in_asia[1]
    prev_hi := asia_hi
    prev_lo := asia_lo
    asia_hi := high
    asia_lo := low
else if in_asia
    asia_hi := math.max(asia_hi, high)
    asia_lo := math.min(asia_lo, low)

// ── 8:30 NEWS LEVELS ────────────────────────────────────────
var float news_hi = na
var float news_lo = na
if in_830
    news_hi := high
    news_lo := low

vwap_v = ta.vwap(hlc3)
atr14  = ta.atr(14)
p(v)   => str.tostring(v, "#.00")

// ── SESSION BACKGROUNDS ─────────────────────────────────────
bgcolor(in_asia    ? color.new(color.yellow, 92) : na, title="Asia")
bgcolor(in_london  ? color.new(color.green,  88) : na, title="London")
bgcolor(in_overlap ? color.new(color.teal,   85) : na, title="Overlap")

// ── KEY LEVEL PLOTS ─────────────────────────────────────────
plot(in_active ? prev_hi : na, "Asia High",  color.new(color.orange, 0),  2, plot.style_linebr)
plot(in_active ? prev_lo : na, "Asia Low",   color.new(color.orange, 0),  2, plot.style_linebr)
plot(vwap_v,                   "VWAP",       color.new(color.blue,   20), 1)
plot(in_overlap ? news_hi : na, "8:30 High", color.new(color.silver, 20), 1, plot.style_linebr)
plot(in_overlap ? news_lo : na, "8:30 Low",  color.new(color.silver, 20), 1, plot.style_linebr)

// ── BIAS LOGIC ───────────────────────────────────────────────
sess_name = in_overlap ? "Overlap (8–12)" : in_london ? "London (3–8)" : in_asia ? "Asia" : "Closed"
sess_col  = in_active  ? color.new(color.teal, 20) : color.new(color.gray, 50)

range_bias = not na(prev_hi) and close > prev_hi ? 1 : not na(prev_lo) and close < prev_lo ? -1 : 0
range_txt  = range_bias ==  1 ? "Above Asia High" : range_bias == -1 ? "Below Asia Low" : "Inside Range"
range_dir  = range_bias ==  1 ? "LONG" : range_bias == -1 ? "SHORT" : "NEUTRAL"
range_col  = range_bias ==  1 ? color.new(color.green, 20) : range_bias == -1 ? color.new(color.red, 20) : color.new(color.gray, 50)

vwap_bias = close > vwap_v ? 1 : -1
vwap_txt  = vwap_bias == 1 ? "Price above VWAP" : "Price below VWAP"
vwap_dir  = vwap_bias == 1 ? "LONG" : "SHORT"
vwap_col  = vwap_bias == 1 ? color.new(color.green, 20) : color.new(color.red, 20)

lbma_txt = in_lbma ? "Window active" : "Not active"
lbma_dir = in_lbma ? "WATCH" : "–"
lbma_col = in_lbma ? color.new(color.purple, 20) : color.new(color.gray, 50)

near_hi  = not na(news_hi) and math.abs(close - news_hi) <= atr14 * 0.35
near_lo  = not na(news_lo) and math.abs(close - news_lo) <= atr14 * 0.35
news_bias = near_hi ? -1 : near_lo ? 1 : 0
news_txt  = near_hi ? "At news high" : near_lo ? "At news low" : "Away from level"
news_dir  = news_bias ==  1 ? "LONG" : news_bias == -1 ? "SHORT" : "–"
news_col  = news_bias ==  1 ? color.new(color.green, 20) : news_bias == -1 ? color.new(color.red, 20) : color.new(color.gray, 50)

bull = (range_bias == 1 ? 1 : 0) + (vwap_bias == 1 ? 1 : 0) + (news_bias == 1 ? 1 : 0)
bear = (range_bias ==-1 ? 1 : 0) + (vwap_bias ==-1 ? 1 : 0) + (news_bias ==-1 ? 1 : 0)

overall     = bull > bear ? 1 : bear > bull ? -1 : 0
overall_txt = overall == 1 ? "LONG" : overall == -1 ? "SHORT" : "NEUTRAL"
overall_col = overall == 1 ? color.new(color.green, 0) : overall == -1 ? color.new(color.red, 0) : color.new(color.gray, 30)
score_txt   = str.tostring(bull) + "L / " + str.tostring(bear) + "S"

// ── ENTRY ZONE + TP + SL LINES ──────────────────────────────
var line     ln_sl    = na
var line     ln_ez_hi = na
var line     ln_ez_lo = na
var line     ln_tp1   = na
var line     ln_tp2   = na
var line     ln_tp3   = na
var linefill lf_ez    = na
var label    lb_sl    = na
var label    lb_ez    = na
var label    lb_tp1   = na
var label    lb_tp2   = na
var label    lb_tp3   = na

line.delete(ln_sl)
line.delete(ln_ez_hi)
line.delete(ln_ez_lo)
line.delete(ln_tp1)
line.delete(ln_tp2)
line.delete(ln_tp3)
linefill.delete(lf_ez)
label.delete(lb_sl)
label.delete(lb_ez)
label.delete(lb_tp1)
label.delete(lb_tp2)
label.delete(lb_tp3)

// Draw whenever bias is confirmed — not just during active session
if overall != 0
    dir     = overall
    tc      = dir == 1 ? color.green : color.red
    dtxt    = dir == 1 ? "LONG" : "SHORT"
    // Slightly dim lines when session is closed
    a       = in_active ? 0 : 35

    ez_hi   = close + 0.2  * atr14
    ez_lo   = close - 0.2  * atr14
    tp1_px  = close + dir  * atr14 * 0.75
    tp2_px  = close + dir  * atr14 * 1.5
    tp3_px  = close + dir  * atr14 * 2.5
    sl_px   = close - dir  * atr14 * 0.75

    trigger = range_bias != 0 ? (dir == 1 ? "Asia High Breakout" : "Asia Low Breakdown") :
              news_bias  != 0 ? "8:30 Level Retest" :
              in_lbma         ? "LBMA Fix Fade" : "VWAP Signal"

    // Lines span 40 bars back so they're fully visible on chart body
    x1 = bar_index - 40
    x2 = bar_index

    ln_sl    := line.new(x1, sl_px,  x2, sl_px,  color=color.new(color.red,    a + 10), width=2, style=line.style_dashed, extend=extend.right)
    ln_ez_hi := line.new(x1, ez_hi,  x2, ez_hi,  color=color.new(color.orange, a + 20), width=1, style=line.style_solid,  extend=extend.right)
    ln_ez_lo := line.new(x1, ez_lo,  x2, ez_lo,  color=color.new(color.orange, a + 20), width=1, style=line.style_solid,  extend=extend.right)
    lf_ez    := linefill.new(ln_ez_hi, ln_ez_lo, color=color.new(color.orange, a + 72))
    ln_tp1   := line.new(x1, tp1_px, x2, tp1_px, color=color.new(tc,           a + 55), width=1, style=line.style_dashed, extend=extend.right)
    ln_tp2   := line.new(x1, tp2_px, x2, tp2_px, color=color.new(tc,           a + 25), width=2, style=line.style_dashed, extend=extend.right)
    ln_tp3   := line.new(x1, tp3_px, x2, tp3_px, color=color.new(tc,           a),      width=2, style=line.style_solid,  extend=extend.right)

    // Labels placed 38 bars back — visible on chart body, not off the right edge
    lx = bar_index - 38

    lb_sl    := label.new(lx, sl_px,  "●  " + dtxt + " STOP LOSS  (" + p(sl_px) + ")",                                           color=color.new(color.red,    a + 10), textcolor=color.white, style=label.style_label_right, size=size.small)
    lb_ez    := label.new(lx, close,  "◆  " + dtxt + " ENTRY ZONE  (" + p(ez_lo) + " – " + p(ez_hi) + ")  [" + trigger + "]",   color=color.new(color.orange, a + 15), textcolor=color.white, style=label.style_label_right, size=size.small)
    lb_tp1   := label.new(lx, tp1_px, "▶  " + dtxt + " TP1 — Quick Scalp  (" + p(tp1_px) + ")",                                 color=color.new(tc,           a + 55), textcolor=color.white, style=label.style_label_right, size=size.small)
    lb_tp2   := label.new(lx, tp2_px, "▶  " + dtxt + " TP2 — Main Target  (" + p(tp2_px) + ")",                                 color=color.new(tc,           a + 25), textcolor=color.white, style=label.style_label_right, size=size.small)
    lb_tp3   := label.new(lx, tp3_px, "▶  " + dtxt + " TP3 — Runner  (" + p(tp3_px) + ")",                                      color=color.new(tc,           a),      textcolor=color.white, style=label.style_label_right, size=size.small)

// ── KEY LEVEL LABELS ─────────────────────────────────────────
var label ll_ahi = na
var label ll_alo = na
var label ll_vwp = na
var label ll_nhi = na
var label ll_nlo = na

label.delete(ll_ahi)
label.delete(ll_alo)
label.delete(ll_vwp)
label.delete(ll_nhi)
label.delete(ll_nlo)

if in_active
    if not na(prev_hi)
        ll_ahi := label.new(bar_index, prev_hi, "Asia H  " + p(prev_hi), color=color.new(color.orange, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(prev_lo)
        ll_alo := label.new(bar_index, prev_lo, "Asia L  " + p(prev_lo), color=color.new(color.orange, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    ll_vwp := label.new(bar_index, vwap_v, "VWAP  " + p(vwap_v), color=color.new(color.blue, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(news_hi)
        ll_nhi := label.new(bar_index, news_hi, "8:30 H  " + p(news_hi), color=color.new(color.gray, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(news_lo)
        ll_nlo := label.new(bar_index, news_lo, "8:30 L  " + p(news_lo), color=color.new(color.gray, 30), textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ── TABLE ────────────────────────────────────────────────────
var table t = table.new(position.top_right, 3, 8, border_width=1, border_color=color.new(color.gray, 60), frame_color=color.new(color.gray, 40), frame_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Signal",     text_color=color.white, bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(t, 1, 0, "Status",     text_color=color.white, bgcolor=color.new(color.navy, 30), text_size=size.small)
    table.cell(t, 2, 0, "Bias",       text_color=color.white, bgcolor=color.new(color.navy, 30), text_size=size.small)

    table.cell(t, 0, 1, "Session",    text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(t, 1, 1, sess_name,    text_color=color.white, bgcolor=sess_col, text_size=size.small)
    table.cell(t, 2, 1, in_active ? "Active" : "–", text_color=color.white, bgcolor=sess_col, text_size=size.small)

    table.cell(t, 0, 2, "Asia Range", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(t, 1, 2, range_txt,    text_color=color.white, bgcolor=range_col, text_size=size.small)
    table.cell(t, 2, 2, range_dir,    text_color=color.white, bgcolor=range_col, text_size=size.small)

    table.cell(t, 0, 3, "VWAP",       text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(t, 1, 3, vwap_txt,     text_color=color.white, bgcolor=vwap_col, text_size=size.small)
    table.cell(t, 2, 3, vwap_dir,     text_color=color.white, bgcolor=vwap_col, text_size=size.small)

    table.cell(t, 0, 4, "LBMA Fix",   text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(t, 1, 4, lbma_txt,     text_color=color.white, bgcolor=lbma_col, text_size=size.small)
    table.cell(t, 2, 4, lbma_dir,     text_color=color.white, bgcolor=lbma_col, text_size=size.small)

    table.cell(t, 0, 5, "8:30 Level", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(t, 1, 5, news_txt,     text_color=color.white, bgcolor=news_col, text_size=size.small)
    table.cell(t, 2, 5, news_dir,     text_color=color.white, bgcolor=news_col, text_size=size.small)

    table.cell(t, 0, 6, "OVERALL",    text_color=color.white, bgcolor=color.new(color.gray, 40), text_size=size.normal)
    table.cell(t, 1, 6, score_txt,    text_color=color.white, bgcolor=overall_col, text_size=size.normal)
    table.cell(t, 2, 6, overall_txt,  text_color=color.white, bgcolor=overall_col, text_size=size.normal)

    tgt_col  = overall == 1 ? color.new(color.green, 40) : overall == -1 ? color.new(color.red, 40) : color.new(color.gray, 50)
    tp1_show = overall != 0 ? p(close + overall * atr14 * 0.75) : "–"
    tp2_show = overall != 0 ? p(close + overall * atr14 * 1.5)  : "–"
    tp3_show = overall != 0 ? p(close + overall * atr14 * 2.5)  : "–"
    sl_show  = overall != 0 ? p(close - overall * atr14 * 0.75) : "–"

    table.cell(t, 0, 7, "TP1 / TP2 / TP3",                              text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.tiny)
    table.cell(t, 1, 7, tp1_show + " / " + tp2_show + " / " + tp3_show, text_color=color.white, bgcolor=tgt_col, text_size=size.tiny)
    table.cell(t, 2, 7, "SL  " + sl_show,                               text_color=color.white, bgcolor=color.new(color.red, 40), text_size=size.tiny)
````
