# All In One [Minimal]

- url: https://www.tradingview.com/script/aL264czA-All-In-One-Minimal/
- type: indicator
- pine_id: PUB;c8ccc0a2830e4457b9dbd3e187f7761d
- version: 1.0

## Description

All In One [Minimal] — Free Multi-Timeframe Dashboard
This indicator consolidates 8 of the most widely used technical tools into a single clean overlay table, giving you a full market read at a glance without cluttering your chart with separate panes.
What's included:
RSI (3 timeframes) — Pulls RSI readings from your three chosen timeframes (default: 15m, 1H, 4H) simultaneously. Color-coded red for overbought (≥70), green for oversold (≤30), and neutral otherwise. Great for multi-timeframe confluence.
EMA Stack (4 periods) — Tracks price position relative to the 9, 21, 50, and 200 EMAs. Each shows a simple Bullish/Bearish read. When all four align, trend conviction is high.
Stochastic — Displays %K vs %D crossover status with overbought/oversold zones clearly labeled (Overbought, Oversold, Bullish Cross, Bearish Cross).
MACD — Shows whether the MACD line is above/below signal, and flags fresh crossovers in real time.
ADX (with DI±) — Identifies trend strength and direction. Readings above 25 are labeled Strong Bull or Strong Bear; below 25 are Weak Bull/Bear.
MFI (Money Flow Index) — Volume-weighted momentum. Flags overbought (≥80), oversold (≤20), and bullish/bearish ranges.
VWAP — Simple above/below read for intraday context.
OBV — Compares OBV to its EMA to detect accumulation vs distribution phases.
ATR-Based Risk Manager — Calculates a stop loss distance using ATR × multiplier (default 1.5×) and outputs it in pips/ticks, along with three take-profit targets at 1.5R, 2R, and 3R automatically.
Summary Score — All indicators vote bullish (+1) or bearish (−1). The total score out of 14 gives you an overall market bias label: Strong Bull, Bullish, Slightly Bullish, Neutral, and so on in the bearish direction.
Settings are fully customizable — every period, timeframe, and multiplier is adjustable from the inputs panel. Works on any instrument (forex, crypto, indices) and any timeframe.
No repainting. Overlay only — no extra panes needed.

## Source Code

````pine
//@version=5
indicator("All In One [Minimal]", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
rsi_len   = input.int(14, "RSI Length", group="RSI")
rsi_tf1   = input.timeframe("15",  "RSI TF 1", group="RSI")
rsi_tf2   = input.timeframe("60",  "RSI TF 2", group="RSI")
rsi_tf3   = input.timeframe("240", "RSI TF 3", group="RSI")

ema1_len  = input.int(9,   "EMA 1", group="EMA")
ema2_len  = input.int(21,  "EMA 2", group="EMA")
ema3_len  = input.int(50,  "EMA 3", group="EMA")
ema4_len  = input.int(200, "EMA 4", group="EMA")

stoch_k   = input.int(14, "Stoch %K", group="Stoch")
stoch_d   = input.int(3,  "Stoch %D", group="Stoch")
stoch_s   = input.int(3,  "Stoch Smooth", group="Stoch")

macd_fast = input.int(12, "MACD Fast", group="MACD")
macd_slow = input.int(26, "MACD Slow", group="MACD")
macd_sig  = input.int(9,  "MACD Signal", group="MACD")

adx_len   = input.int(14,  "ADX Length",      group="ADX")
mfi_len   = input.int(14,  "MFI Length",      group="MFI")
obv_ma    = input.int(20,  "OBV MA Length",   group="OBV")
atr_len   = input.int(14,  "ATR Length",      group="ATR Stop Loss")
atr_mult  = input.float(1.5,"ATR Multiplier", group="ATR Stop Loss", step=0.1)

// ─── COLORS ───────────────────────────────────────────────────────────────────
c_bull   = color.new(#4caf7d, 0)
c_bear   = color.new(#c0504d, 0)
c_neu    = color.new(#888888, 0)
c_header = color.new(#2d3348, 0)
c_title  = color.new(#8b6f3e, 0)
c_bg     = color.new(#1a1d2e, 0)
c_text   = color.new(#e0e0e0, 0)
c_border = color.new(#444444, 0)

// ─── RSI ──────────────────────────────────────────────────────────────────────
rsi_15  = request.security(syminfo.tickerid, rsi_tf1, ta.rsi(close, rsi_len))
rsi_60  = request.security(syminfo.tickerid, rsi_tf2, ta.rsi(close, rsi_len))
rsi_240 = request.security(syminfo.tickerid, rsi_tf3, ta.rsi(close, rsi_len))

rsi_col(v) => v >= 70 ? c_bear : v <= 30 ? c_bull : c_neu

// ─── EMA ──────────────────────────────────────────────────────────────────────
ema1 = ta.ema(close, ema1_len)
ema2 = ta.ema(close, ema2_len)
ema3 = ta.ema(close, ema3_len)
ema4 = ta.ema(close, ema4_len)

ema_status(e) => close > e ? "Bullish" : "Bearish"
ema_col(e)    => close > e ? c_bull : c_bear

// ─── STOCH ────────────────────────────────────────────────────────────────────
sk = ta.sma(ta.stoch(close, high, low, stoch_k), stoch_s)
sd = ta.sma(sk, stoch_d)
stoch_stat = sk > sd ? (sk > 80 ? "Overbought" : "Bullish Cross") : (sk < 20 ? "Oversold" : "Bearish Cross")
stoch_col  = sk > sd ? (sk > 80 ? c_bear : c_bull) : (sk < 20 ? c_bull : c_bear)

// ─── MACD ─────────────────────────────────────────────────────────────────────
[ml, ms, mh] = ta.macd(close, macd_fast, macd_slow, macd_sig)
macd_cross_up   = ta.crossover(ml, ms)
macd_cross_down = ta.crossunder(ml, ms)
macd_stat = ml > ms ? (macd_cross_up ? "Bullish Cross" : "Bullish") : (macd_cross_down ? "Bearish Cross" : "Bearish")
macd_col  = ml > ms ? c_bull : c_bear

// ─── ADX ──────────────────────────────────────────────────────────────────────
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_len)
adx_stat = adx_val > 25 ? (diplus > diminus ? "Strong Bull" : "Strong Bear") : (diplus > diminus ? "Weak Bull" : "Weak Bear")
adx_col  = diplus > diminus ? c_bull : c_bear

// ─── MFI ──────────────────────────────────────────────────────────────────────
mfi_val  = ta.mfi(hlc3, mfi_len)
mfi_stat = mfi_val >= 80 ? "Overbought" : mfi_val <= 20 ? "Oversold" : mfi_val > 50 ? "Bullish Range" : "Bearish Range"
mfi_col  = mfi_val >= 80 ? c_bear : mfi_val <= 20 ? c_bull : mfi_val > 50 ? c_bull : c_bear

// ─── VWAP ─────────────────────────────────────────────────────────────────────
vwap_val  = ta.vwap(hlc3)
vwap_stat = close > vwap_val ? "Above VWAP" : "Below VWAP"
vwap_col  = close > vwap_val ? c_bull : c_bear

// ─── OBV ──────────────────────────────────────────────────────────────────────
obv_val  = ta.obv
obv_sig  = ta.ema(obv_val, obv_ma)
obv_stat = obv_val > obv_sig ? (obv_val > obv_val[1] ? "Accumulation" : "Bullish") : (obv_val < obv_val[1] ? "Distribution" : "Bearish")
obv_col  = obv_val > obv_sig ? c_bull : c_bear

// ─── ATR STOP LOSS ────────────────────────────────────────────────────────────
atr_val   = ta.atr(atr_len)
atr_sl    = atr_val * atr_mult
sl_long   = close - atr_sl
sl_short  = close + atr_sl

// Pips: for forex use 0.0001 as pip, for indices/crypto use syminfo.mintick
pip_size  = syminfo.type == "forex" ? 0.0001 : syminfo.mintick
sl_pips   = math.round(atr_sl / pip_size)
tp1_pips  = math.round(sl_pips * 1.5)
tp2_pips  = math.round(sl_pips * 2.0)
tp3_pips  = math.round(sl_pips * 3.0)

atr_str   = "SL  " + str.tostring(sl_pips) + " pips"
tp_str    = "TP1 " + str.tostring(tp1_pips) + "  TP2 " + str.tostring(tp2_pips) + "  TP3 " + str.tostring(tp3_pips)

// ─── SUMMARY SCORE ────────────────────────────────────────────────────────────
rsi_vote(v) => v >= 70 ? -1 : v <= 30 ? 1 : v > 50 ? 1 : -1
score_rsi   = rsi_vote(rsi_15) + rsi_vote(rsi_60) + rsi_vote(rsi_240)

ema_vote(e) => close > e ? 1 : -1
score_ema   = ema_vote(ema1) + ema_vote(ema2) + ema_vote(ema3) + ema_vote(ema4)

score_stoch = sk > sd ? 1 : -1
score_macd  = ml > ms ? 1 : -1
score_adx   = diplus > diminus ? 1 : -1
score_mfi   = mfi_val > 50 ? 1 : -1
score_vwap  = close > vwap_val ? 1 : -1
score_obv   = obv_val > obv_sig ? 1 : -1

total_score = score_rsi + score_ema + score_stoch + score_macd + score_adx + score_mfi + score_vwap + score_obv

summary_text =
     total_score >= 10 ? "Strong Bull" :
     total_score >= 5  ? "Bullish" :
     total_score >= 2  ? "Slightly Bullish" :
     total_score <= -10? "Strong Bear" :
     total_score <= -5 ? "Bearish" :
     total_score <= -2 ? "Slightly Bearish" :
     "Neutral"

summary_col =
     total_score >= 5  ? c_bull :
     total_score <= -5 ? c_bear :
     total_score >= 2  ? color.new(#4caf7d, 40) :
     total_score <= -2 ? color.new(#c0504d, 40) :
     c_neu

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 25,
     bgcolor=c_bg,
     border_color=c_border, border_width=1,
     frame_color=c_title, frame_width=2)

if barstate.islast
    table.merge_cells(t, 0, 0, 1, 0)
    table.cell(t, 0, 0, "All In One", bgcolor=c_title, text_color=color.white, text_size=size.normal)

    table.cell(t, 0, 1, "Indicator", bgcolor=color.new(#5a4a2e, 0), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, "Status",    bgcolor=color.new(#5a4a2e, 0), text_color=color.white, text_size=size.small)

    // RSI
    table.merge_cells(t, 0, 2, 1, 2)
    table.cell(t, 0, 2, "RSI", bgcolor=c_header, text_color=c_text, text_size=size.small)
    table.cell(t, 0, 3, "RSI " + rsi_tf1, bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(math.round(rsi_15, 2)),  bgcolor=rsi_col(rsi_15),  text_color=color.white, text_size=size.small)
    table.cell(t, 0, 4, "RSI " + rsi_tf2, bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(math.round(rsi_60, 2)),  bgcolor=rsi_col(rsi_60),  text_color=color.white, text_size=size.small)
    table.cell(t, 0, 5, "RSI " + rsi_tf3, bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(math.round(rsi_240, 2)), bgcolor=rsi_col(rsi_240), text_color=color.white, text_size=size.small)

    // EMA
    table.merge_cells(t, 0, 6, 1, 6)
    table.cell(t, 0, 6, "EMA", bgcolor=c_header, text_color=c_text, text_size=size.small)
    table.cell(t, 0, 7,  "EMA " + str.tostring(ema1_len), bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 7,  ema_status(ema1), bgcolor=ema_col(ema1), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 8,  "EMA " + str.tostring(ema2_len), bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 8,  ema_status(ema2), bgcolor=ema_col(ema2), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 9,  "EMA " + str.tostring(ema3_len), bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 9,  ema_status(ema3), bgcolor=ema_col(ema3), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 10, "EMA " + str.tostring(ema4_len), bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 10, ema_status(ema4), bgcolor=ema_col(ema4), text_color=color.white, text_size=size.small)

    // Others
    table.merge_cells(t, 0, 11, 1, 11)
    table.cell(t, 0, 11, "Others", bgcolor=c_header, text_color=c_text, text_size=size.small)
    table.cell(t, 0, 12, "Stoch", bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 12, stoch_stat, bgcolor=stoch_col, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 13, "MACD",  bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 13, macd_stat, bgcolor=macd_col, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 14, "ADX",   bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 14, adx_stat, bgcolor=adx_col, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 15, "MFI",   bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 15, mfi_stat, bgcolor=mfi_col, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 16, "VWAP",  bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 16, vwap_stat, bgcolor=vwap_col, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 17, "OBV",   bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 17, obv_stat, bgcolor=obv_col, text_color=color.white, text_size=size.small)

    // ATR Stop Loss
    table.merge_cells(t, 0, 18, 1, 18)
    table.cell(t, 0, 18, "ATR Risk  (" + str.tostring(atr_mult) + "x ATR)", bgcolor=c_header, text_color=c_text, text_size=size.small)
    table.merge_cells(t, 0, 19, 1, 19)
    table.cell(t, 0, 19, atr_str, bgcolor=color.new(#d4a843, 60), text_color=color.white, text_size=size.small)
    table.merge_cells(t, 0, 20, 1, 20)
    table.cell(t, 0, 20, tp_str, bgcolor=color.new(#4a7a9b, 60), text_color=color.white, text_size=size.small)
    
    // Summary
    table.merge_cells(t, 0, 20, 1, 20)
    table.cell(t, 0, 20, "Summary", bgcolor=c_header, text_color=c_text, text_size=size.small)
    table.cell(t, 0, 21, "Market", bgcolor=c_bg, text_color=c_text, text_size=size.small)
    table.cell(t, 1, 21, summary_text, bgcolor=summary_col, text_color=color.white, text_size=size.small)
    table.merge_cells(t, 0, 22, 1, 22)
    table.cell(t, 0, 22, "Score  " + str.tostring(total_score) + " / 14", bgcolor=summary_col, text_color=color.white, text_size=size.small)

plot(na)
````
