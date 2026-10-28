# MNQ Micro Nasdaq Futures 1M [BUY/SELL]

- url: https://www.tradingview.com/script/n0UCnk11-MNQ-Micro-Nasdaq-Futures-1M-BUY-SELL/
- type: indicator
- pine_id: PUB;e9dda3d624e14b95824ce6225f7e7aa0
- version: 1.0

## Description

Thins is the indicator combines EMA trend analysis, RSI, MACD, and stochastic signals to identify potential buy and sell opportunities on micro nasdaq charts

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © anoopvarghese876

//@version=6

indicator("MNQ Micro Nasdaq Futures 1M [BUY/SELL]", overlay=true, max_labels_count=500, max_lines_count=500)

// ── INPUTS ──────────────────────────────────────────────────────
g1 = "EMA Settings"
ema1_len = input.int(8,  "Fast EMA",  group=g1)
ema2_len = input.int(21, "Mid EMA",   group=g1)
ema3_len = input.int(34, "Slow EMA",  group=g1)

g2 = "RSI"
rsi_len  = input.int(14, "RSI Length", group=g2)
rsi_ob   = input.int(70, "Overbought", group=g2)
rsi_os   = input.int(30, "Oversold",   group=g2)

g3 = "MACD"
mfast    = input.int(12, "Fast",   group=g3)
mslow    = input.int(26, "Slow",   group=g3)
msig     = input.int(9,  "Signal", group=g3)

g4 = "Stochastic"
sk_len   = input.int(14, "K Length", group=g4)
sd_len   = input.int(3,  "D Smooth", group=g4)

g5 = "ATR Risk Management"
atr_len  = input.int(14,    "ATR Period", group=g5)
sl_mult  = input.float(1.5, "SL x ATR",  group=g5, step=0.1)
tp_mult  = input.float(3.0, "TP x ATR",  group=g5, step=0.1)

g6 = "Signal Filter"
min_sc   = input.int(5, "Min Confluence Score (1–9)", minval=1, maxval=9, group=g6)
use_sess = input.bool(true, "Filter: Regular Session Only (09:30–16:00 ET)", group=g6)

g7 = "Display"
show_ema   = input.bool(true,  "Show EMAs",        group=g7)
show_vwap  = input.bool(true,  "Show VWAP",        group=g7)
show_bb    = input.bool(true,  "Show Bollinger",   group=g7)
show_lbl   = input.bool(true,  "Show Labels",      group=g7)
show_lines = input.bool(true,  "Show SL/TP Lines", group=g7)

// ── SESSION FILTER ───────────────────────────────────────────────
in_session = not use_sess or (time(timeframe.period, "0930-1600", "America/New_York") != 0)

// ── INDICATORS ───────────────────────────────────────────────────
e1 = ta.ema(close, ema1_len)
e2 = ta.ema(close, ema2_len)
e3 = ta.ema(close, ema3_len)

_rsi = ta.rsi(close, rsi_len)

[_ml, _sl, _hl] = ta.macd(close, mfast, mslow, msig)

_sk = ta.stoch(close, high, low, sk_len)
_sd = ta.sma(_sk, sd_len)

[_bbu, _bbm, _bbl] = ta.bb(close, 20, 2.0)

_atr  = ta.atr(atr_len)
_vwap = ta.vwap(hlc3)

vol_avg   = ta.sma(volume, 20)
vol_spike = volume > vol_avg * 1.5

// ── SCORING ──────────────────────────────────────────────────────
var int buy_sc  = 0
var int sell_sc = 0

buy_sc  := 0
sell_sc := 0

buy_sc  += e1 > e2 and e2 > e3 ? 1 : 0
sell_sc += e1 < e2 and e2 < e3 ? 1 : 0

buy_sc  += ta.crossover(e1, e2)  ? 1 : 0
sell_sc += ta.crossunder(e1, e2) ? 1 : 0

buy_sc  += close > _vwap ? 1 : 0
sell_sc += close < _vwap ? 1 : 0

buy_sc  += (_rsi > 50 and _rsi < rsi_ob) or _rsi < rsi_os ? 1 : 0
sell_sc += (_rsi < 50 and _rsi > rsi_os) or _rsi > rsi_ob ? 1 : 0

buy_sc  += ta.crossover(_hl, 0)  ? 1 : 0
sell_sc += ta.crossunder(_hl, 0) ? 1 : 0

buy_sc  += _hl > 0 and _hl > _hl[1] ? 1 : 0
sell_sc += _hl < 0 and _hl < _hl[1] ? 1 : 0

buy_sc  += ta.crossover(_sk, _sd)  and _sk < 75 ? 1 : 0
sell_sc += ta.crossunder(_sk, _sd) and _sk > 25 ? 1 : 0

buy_sc  += close <= _bbl ? 1 : 0
sell_sc += close >= _bbu ? 1 : 0

buy_sc  += vol_spike and close > open ? 1 : 0
sell_sc += vol_spike and close < open ? 1 : 0

// ── SIGNALS ──────────────────────────────────────────────────────
raw_buy  = buy_sc  >= min_sc and buy_sc  > sell_sc and in_session
raw_sell = sell_sc >= min_sc and sell_sc > buy_sc  and in_session

buy_sig  = raw_buy  and not raw_buy[1]
sell_sig = raw_sell and not raw_sell[1]

b_sl = close - _atr * sl_mult
b_tp = close + _atr * tp_mult
s_sl = close + _atr * sl_mult
s_tp = close - _atr * tp_mult

// ── PLOTS ────────────────────────────────────────────────────────
plot(show_ema  ? e1    : na, "EMA 8",  color=#00d4aa, linewidth=1)
plot(show_ema  ? e2    : na, "EMA 21", color=#f59e0b, linewidth=1)
plot(show_ema  ? e3    : na, "EMA 34", color=color.red, linewidth=2)
plot(show_vwap ? _vwap : na, "VWAP",  color=#a78bfa, linewidth=2)

p_bbu = plot(show_bb ? _bbu : na, "BB Upper", color=color.new(color.gray, 60), linewidth=1)
p_bbl = plot(show_bb ? _bbl : na, "BB Lower", color=color.new(color.gray, 60), linewidth=1)
fill(p_bbu, p_bbl, color=show_bb ? color.new(color.gray, 92) : na)

plotshape(buy_sig,  "BUY",  shape.triangleup,   location.belowbar, color=#00ff88, size=size.normal)
plotshape(sell_sig, "SELL", shape.triangledown, location.abovebar, color=#ff3355, size=size.normal)

bgcolor(buy_sig  ? color.new(#00ff88, 85) : na)
bgcolor(sell_sig ? color.new(#ff3355, 85) : na)

// ── LABELS ───────────────────────────────────────────────────────
if show_lbl and buy_sig
    label.new(bar_index, low - _atr * 0.8,
        "▲ BUY  MNQ\nEntry : " + str.tostring(close, "#.00") +
        "\nSL    : " + str.tostring(b_sl, "#.00") +
        "\nTP    : " + str.tostring(b_tp, "#.00") +
        "\nScore : " + str.tostring(buy_sc) + "/9",
        style=label.style_label_up,
        color=color.new(#003320, 5),
        textcolor=#00ff88,
        size=size.small)

if show_lbl and sell_sig
    label.new(bar_index, high + _atr * 0.8,
        "▼ SELL  MNQ\nEntry : " + str.tostring(close, "#.00") +
        "\nSL    : " + str.tostring(s_sl, "#.00") +
        "\nTP    : " + str.tostring(s_tp, "#.00") +
        "\nScore : " + str.tostring(sell_sc) + "/9",
        style=label.style_label_down,
        color=color.new(#330010, 5),
        textcolor=#ff3355,
        size=size.small)

// ── SL/TP LINES ──────────────────────────────────────────────────
if show_lines and buy_sig
    line.new(bar_index, b_sl, bar_index + 12, b_sl, color=color.red,    width=2, style=line.style_dashed)
    line.new(bar_index, b_tp, bar_index + 12, b_tp, color=#00ff88,      width=2, style=line.style_dashed)
    line.new(bar_index, close, bar_index + 12, close, color=color.white, width=1, style=line.style_dotted)

if show_lines and sell_sig
    line.new(bar_index, s_sl, bar_index + 12, s_sl, color=color.red,    width=2, style=line.style_dashed)
    line.new(bar_index, s_tp, bar_index + 12, s_tp, color=#00ff88,      width=2, style=line.style_dashed)
    line.new(bar_index, close, bar_index + 12, close, color=color.white, width=1, style=line.style_dotted)

// ── TABLE ────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 11, border_width=1)

if barstate.islast
    cur_sig  = buy_sig ? "▲ BUY" : sell_sig ? "▼ SELL" : "── WAIT"
    sig_col  = buy_sig ? #00ff88 : sell_sig  ? #ff3355  : color.gray
    sc_now   = buy_sc > sell_sc ? buy_sc : sell_sc

    table.cell(tbl, 0, 0,  "MNQ 1M SCALPER",   text_color=#00d4ff, bgcolor=#0d1b2e, text_size=size.small)
    table.cell(tbl, 1, 0,  "MICRO NASDAQ",      text_color=#64748b, bgcolor=#0d1b2e, text_size=size.small)
    table.cell(tbl, 0, 1,  "Signal",            text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 1,  cur_sig,             text_color=sig_col,     bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 2,  "Score",             text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 2,  str.tostring(sc_now) + " / 9", text_color=sc_now >= min_sc ? #00ff88 : color.gray, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 3,  "EMA Stack",         text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 3,  e1 > e2 and e2 > e3 ? "Bullish" : e1 < e2 and e2 < e3 ? "Bearish" : "Mixed", text_color=e1 > e2 and e2 > e3 ? #00ff88 : e1 < e2 and e2 < e3 ? #ff3355 : color.yellow, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 4,  "VWAP",              text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 4,  close > _vwap ? "Above" : "Below", text_color=close > _vwap ? #00ff88 : #ff3355, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 5,  "RSI",               text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 5,  str.tostring(math.round(_rsi, 1)), text_color=_rsi > rsi_ob ? #ff3355 : _rsi < rsi_os ? #00ff88 : color.yellow, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 6,  "MACD Hist",         text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 6,  str.tostring(math.round(_hl, 2)), text_color=_hl > 0 ? #00ff88 : #ff3355, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 7,  "Stoch %K",          text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 7,  str.tostring(math.round(_sk, 1)), text_color=_sk > 75 ? #ff3355 : _sk < 25 ? #00ff88 : color.yellow, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 8,  "ATR",               text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 8,  str.tostring(math.round(_atr, 2)) + " pts", text_color=color.gray, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 9,  "Volume",            text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 9,  vol_spike ? "SPIKE" : "Normal", text_color=vol_spike ? #00ff88 : color.gray, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 0, 10, "Session",           text_color=color.white, bgcolor=#0a0f1e, text_size=size.small)
    table.cell(tbl, 1, 10, in_session ? "ACTIVE" : "CLOSED", text_color=in_session ? #00ff88 : color.gray, bgcolor=#0a0f1e, text_size=size.small)

// ── ALERTS ───────────────────────────────────────────────────────
alertcondition(buy_sig,             title="MNQ BUY",    message="MNQ BUY @ {{close}} | {{time}}")
alertcondition(sell_sig,            title="MNQ SELL",   message="MNQ SELL @ {{close}} | {{time}}")
alertcondition(buy_sig or sell_sig, title="MNQ Signal", message="MNQ Signal on {{ticker}} @ {{close}} | {{time}}")
````
