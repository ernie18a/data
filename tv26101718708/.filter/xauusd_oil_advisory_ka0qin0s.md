# XAUUSD OIL Advisory

- url: https://www.tradingview.com/script/Ka0qIn0s-XAUUSD-OIL-Advisory/
- type: indicator
- pine_id: PUB;85aee7d0c41e4a3d80f66f2e3da39bc0
- version: 1.0

## Description

Tested trend and signal advisory for XAUUSD related to OIL price trending and spiking... It works fine, EMA s give a good direction bias...

## Source Code

````pine
// ============================================================
//  XAUUSD × OIL Advisory Engine  —  Giorgio / Ferribucket
//  Pine Script v6  |  Optimised H1 / H4
//
//  LOGIC:
//  Oil trend UP  = oil EMA21 > EMA55 > EMA200
//  Oil spike UP  = oil % change > threshold in N bars
//  BOTH true     = ADVISORY: XAU likely to drop → prepare SELL
//  XAU trend     = shown separately so you decide entry timing
// ============================================================
//@version=6
indicator(title      = "XAUUSD × OIL Advisory",
          shorttitle = "XAU×OIL",
          overlay    = true,
          max_bars_back = 500)

// ─────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────
grp_oil  = "── Oil Settings ──"
oil_sym  = input.symbol("USOIL", "Oil Symbol", group = grp_oil)
oil_lb   = input.int(3,   "Spike lookback (bars)",   group = grp_oil, minval = 1, maxval = 10)
oil_thr  = input.float(0.8, "Spike threshold (%)",   group = grp_oil, minval = 0.1, step = 0.1)
oil_e1   = input.int(21,  "Oil EMA Fast",            group = grp_oil, minval = 1)
oil_e2   = input.int(55,  "Oil EMA Mid",             group = grp_oil, minval = 1)
oil_e3   = input.int(200, "Oil EMA Slow",            group = grp_oil, minval = 1)

grp_xau  = "── XAU Settings ──"
xau_e1   = input.int(21,  "XAU EMA Fast",            group = grp_xau, minval = 1)
xau_e2   = input.int(55,  "XAU EMA Mid",             group = grp_xau, minval = 1)
xau_e3   = input.int(200, "XAU EMA Slow",            group = grp_xau, minval = 1)
rsi_len  = input.int(14,  "RSI Length",              group = grp_xau, minval = 2)

grp_vol  = "── ATR Levels ──"
atr_len  = input.int(14,   "ATR Length",             group = grp_vol, minval = 1)
atr_sl   = input.float(1.5,"SL multiplier",          group = grp_vol, step = 0.1)
atr_tp   = input.float(2.0,"TP R:R",                 group = grp_vol, step = 0.1)

grp_disp = "── Display ──"
show_ema = input.bool(true, "Show XAU EMAs",         group = grp_disp)
show_oil = input.bool(true, "Show Oil EMAs (pane)",  group = grp_disp)
show_db  = input.bool(true, "Show Dashboard",        group = grp_disp)
show_lvl = input.bool(true, "Show TP/SL on advisory",group = grp_disp)

// ─────────────────────────────────────────────────────────────
//  OIL DATA
// ─────────────────────────────────────────────────────────────
oil_close = request.security(oil_sym, timeframe.period, close, lookahead = barmerge.lookahead_off)
oil_high  = request.security(oil_sym, timeframe.period, high,  lookahead = barmerge.lookahead_off)

o_e1 = ta.ema(oil_close, oil_e1)
o_e2 = ta.ema(oil_close, oil_e2)
o_e3 = ta.ema(oil_close, oil_e3)

oil_trend_up = o_e1 > o_e2 and o_e2 > o_e3 and oil_close > o_e1

oil_pct    = (oil_close - oil_close[oil_lb]) / oil_close[oil_lb] * 100
oil_spk_up = oil_pct >= oil_thr

oil_alert         = oil_trend_up and oil_spk_up
oil_alert_trigger = oil_alert and not oil_alert[1]

// ─────────────────────────────────────────────────────────────
//  XAU EMAs + RSI + ATR
// ─────────────────────────────────────────────────────────────
x_e1  = ta.ema(close, xau_e1)
x_e2  = ta.ema(close, xau_e2)
x_e3  = ta.ema(close, xau_e3)
rsi   = ta.rsi(close, rsi_len)
atr   = ta.atr(atr_len)

xau_bull = x_e1 > x_e2 and x_e2 > x_e3 and close > x_e1
xau_bear = x_e1 < x_e2 and x_e2 < x_e3 and close < x_e1
xau_flat = not xau_bull and not xau_bear

// ─────────────────────────────────────────────────────────────
//  ADVISORY LEVELS
// ─────────────────────────────────────────────────────────────
var float adv_sl = na
var float adv_tp = na

if oil_alert_trigger
    adv_sl := high + atr * atr_sl
    adv_tp := close - (adv_sl - close) * atr_tp

// ─────────────────────────────────────────────────────────────
//  MARKERS
// ─────────────────────────────────────────────────────────────
plotshape(oil_alert_trigger,
     title     = "OIL UP — XAU Advisory",
     location  = location.abovebar,
     style     = shape.diamond,
     size      = size.normal,
     color     = color.new(#FF6D00, 0),
     text      = "OIL↑\nWATCH",
     textcolor = color.new(#FF6D00, 0))

plotshape(oil_trend_up and oil_spk_up and not oil_alert_trigger,
     title    = "Oil trend + spike active",
     location = location.abovebar,
     style    = shape.circle,
     size     = size.tiny,
     color    = color.new(#FF6D00, 50))

// ─────────────────────────────────────────────────────────────
//  XAU EMAs
// ─────────────────────────────────────────────────────────────
plot(show_ema ? x_e1 : na, "XAU EMA 21",  color = color.new(#FFEB3B, 40), linewidth = 1)
plot(show_ema ? x_e2 : na, "XAU EMA 55",  color = color.new(#FF9800, 40), linewidth = 1)
plot(show_ema ? x_e3 : na, "XAU EMA 200", color = color.new(#CE93D8, 40), linewidth = 2)

// ─────────────────────────────────────────────────────────────
//  ADVISORY TP / SL
// ─────────────────────────────────────────────────────────────
plot(show_lvl and not na(adv_sl) ? adv_sl : na,
     "Advisory SL", style = plot.style_linebr,
     color = color.new(#FF1744, 30), linewidth = 1)

plot(show_lvl and not na(adv_tp) ? adv_tp : na,
     "Advisory TP", style = plot.style_linebr,
     color = color.new(#00E676, 30), linewidth = 1)

// ─────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────
if show_db and barstate.islast
    var table db = table.new(position.top_right, 2, 11,
         bgcolor      = color.new(#0D0D1A, 5),
         border_width = 1,
         border_color = color.new(color.gray, 65),
         frame_width  = 1,
         frame_color  = color.new(color.gray, 45))

    table.cell(db, 0, 0, "XAU × OIL Advisory", text_color = #E0E0E0, text_size = size.small, bgcolor = #3D1F00, text_halign = text.align_left)
    table.cell(db, 1, 0, timeframe.period,       text_color = #B0BEC5, text_size = size.small, bgcolor = #3D1F00, text_halign = text.align_right)

    table.cell(db, 0, 1, "Oil price",   text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 1, str.tostring(oil_close, "#.##"), text_color = #B0BEC5, text_size = size.small, text_halign = text.align_right)

    oil_pct_col = oil_pct >= oil_thr ? #FF6D00 : oil_pct > 0 ? #FFA726 : #42A5F5
    table.cell(db, 0, 2, "Oil Δ " + str.tostring(oil_lb) + "b", text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 2, str.tostring(oil_pct, "#.##") + "%", text_color = oil_pct_col, text_size = size.small, text_halign = text.align_right)

    oil_tr_txt = oil_trend_up ? "▲ UP  (all EMAs)" : "─ Not trending up"
    oil_tr_col = oil_trend_up ? #FF6D00 : #546E7A
    table.cell(db, 0, 3, "Oil trend",  text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 3, oil_tr_txt,   text_color = oil_tr_col, text_size = size.small, text_halign = text.align_right)

    spk_txt = oil_spk_up ? "⚡ YES (" + str.tostring(oil_pct, "#.#") + "%)" : "─ No"
    spk_col = oil_spk_up ? #FF6D00 : #546E7A
    table.cell(db, 0, 4, "Oil spike ≥" + str.tostring(oil_thr, "#.#") + "%", text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 4, spk_txt, text_color = spk_col, text_size = size.small, text_halign = text.align_right)

    adv_txt = oil_alert ? "◉ ACTIVE — prep SELL" : "○ Watching"
    adv_col = oil_alert ? #FF6D00 : #546E7A
    adv_bg  = oil_alert ? color.new(#3D1000, 20) : color.new(#0D0D1A, 5)
    table.cell(db, 0, 5, "Advisory", text_color = #E0E0E0, text_size = size.small, bgcolor = adv_bg, text_halign = text.align_left)
    table.cell(db, 1, 5, adv_txt,    text_color = adv_col, text_size = size.small, bgcolor = adv_bg, text_halign = text.align_right)

    table.cell(db, 0, 6, "─────────────", text_color = #37474F, text_size = size.tiny, text_halign = text.align_left)
    table.cell(db, 1, 6, "─────────────", text_color = #37474F, text_size = size.tiny, text_halign = text.align_right)

    xau_txt = xau_bull ? "▲ Bullish" : xau_bear ? "▼ Bearish" : "◆ Ranging"
    xau_col = xau_bull ? #66BB6A : xau_bear ? #EF5350 : #FFA726
    table.cell(db, 0, 7, "XAU trend",  text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 7, xau_txt,      text_color = xau_col, text_size = size.small, text_halign = text.align_right)

    rsi_col = rsi > 65 ? #EF5350 : rsi < 35 ? #66BB6A : #B0BEC5
    table.cell(db, 0, 8, "XAU RSI(" + str.tostring(rsi_len) + ")", text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 8, str.tostring(rsi, "#.#"), text_color = rsi_col, text_size = size.small, text_halign = text.align_right)

    sl_txt = na(adv_sl) ? "─" : str.tostring(adv_sl, "#.##")
    tp_txt = na(adv_tp) ? "─" : str.tostring(adv_tp, "#.##")
    table.cell(db, 0,  9, "Adv. SL (sell)", text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1,  9, sl_txt, text_color = #EF5350, text_size = size.small, text_halign = text.align_right)
    table.cell(db, 0, 10, "Adv. TP (sell)", text_color = #78909C, text_size = size.small, text_halign = text.align_left)
    table.cell(db, 1, 10, tp_txt, text_color = #66BB6A, text_size = size.small, text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────
alertcondition(oil_alert_trigger,
     title   = "OIL UP — XAU Advisory",
     message = "⚠️ XAUUSD Advisory: Oil trending UP + spike detected. Prepare SELL position on XAU. Confirm your entry manually.")

alertcondition(oil_trend_up and not oil_trend_up[1],
     title   = "Oil trend turned UP",
     message = "Oil EMA stack turned bullish — XAU bearish bias building.")
````
