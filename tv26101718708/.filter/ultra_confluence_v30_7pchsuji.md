# Ultra Confluence v3.0

- url: https://www.tradingview.com/script/7PchSUJI-Ultra-Confluence-v3-0/
- type: indicator
- pine_id: PUB;94d9c9b5a61648748ba6e5b74ae47db3
- version: 1.0

## Description

**What it is**

A multi-confluence trading indicator that runs 9 different technical analysis tools simultaneously and only fires a BUY or SELL signal when enough of them agree. Instead of relying on one indicator (which gives lots of false signals), it requires a minimum score of 6 out of 9 before anything appears on your chart.

---

**The 9 indicators and what each one checks**

1. **EMA Stack (9/21/50)** — checks whether the fast, mid, and slow moving averages are lined up in the correct bullish or bearish order. When 9 is above 21 which is above 50, the short-term trend is cleanly up.

2. **EMA 200** — the macro trend filter. If price is above the 200 EMA, you're in a bull market environment. Below it, bear. This alone filters out a huge number of bad trades.

3. **RSI (14)** — measures momentum. For a buy, it needs to be above 45 but below 70 (not overbought). For a sell, below 55 but above 30. This catches the middle of moves, not exhausted tops and bottoms.

4. **MACD (12/26/9) with freshness check** — not only does MACD need to be in a bullish/bearish position, the crossover must have happened within the last 5 bars. This is the key improvement from v1 — it prevents the script from crediting a MACD signal that's 50 candles old.

5. **VWAP** — Volume Weighted Average Price. Institutional traders and algorithms use VWAP as a reference. Being above it is bullish, below is bearish. It resets every session, so it's always relevant.

6. **Bollinger Bands (20, 2.0)** — checks that price is in the bullish zone (above the midline but below the upper band). Being above the upper band means the move is over-extended and the indicator won't give credit for it — this filters out chasing.

7. **Supertrend (10, 3.0)** — an ATR-based trend line that flips direction. When it's below price, trend is up. When above, trend is down. Very clean and hard to fake.

8. **Stochastic (14)** — cycle timing tool. For a buy, the K line needs to be above the D line but not yet overbought (below 80). Catches momentum building before it peaks.

9. **Volume** — checks whether the current bar's volume is more than 1.5× the 20-bar average. This confirms that real money is behind the move, not just a quiet drift.

---

**How signals are generated**

Each of the 9 conditions scores 1 point. The script adds up the BUY score and the SELL score separately. A signal only fires when:
- the score hits your minimum threshold (default 6)
- that direction's score is higher than the opposite direction's score
- the score just crossed the threshold this bar (not already above it last bar — prevents repeating)

So a 7/9 BUY means 7 of the 9 indicators are simultaneously pointing up. That's a high-conviction moment.

---

**What appears on the chart**

- Green **BUY** / Red **SELL** label directly on the candle
- A score badge below/above it (e.g. `✦ 7/9`)
- Green dashed **TP line** projected 25 bars forward, calculated as 3× ATR from entry
- Red dashed **SL line** at 1.5× ATR from entry — giving you a 1:2 risk/reward built in
- The candle's background briefly flashes green or red on signal bars
- The **EMA lines** (9, 21, 50, 200) plotted on the chart in yellow/orange/red/white
- **Supertrend line** in green when bullish, red when bearish
- **VWAP** as a purple line

---

**The dashboard (top-right corner)**

A live table that updates every bar showing:
- Current BUY score and SELL score out of 9
- The state of all 9 indicators individually (▲ BULL or ▼ BEAR)
- Whether volume is high or normal
- The current signal status (BUY / SELL / NONE)

This lets you see at a glance *why* a signal fired or why it hasn't yet — e.g. "everything is bullish but MACD cross is stale and volume is low, so score is only 5/9."

---

**Alerts**

Three alert conditions are built in — a dedicated BUY alert, a dedicated SELL alert, and a combined "any signal" alert. You set these in TradingView's Alert menu and they'll notify you by phone, email, or webhook without needing to watch the chart.

---

**Best use**

Works on any asset (crypto, forex, stocks, indices) and any timeframe. The 1H and 4H timeframes give the cleanest signals because there's enough volume and candle data for all 9 indicators to have meaning. On the 1-minute chart the signals will be noisy. Raising the minimum score to 7 gives fewer signals but each one is markedly stronger.

## Source Code

````pine
// ============================================================
// ULTRA CONFLUENCE INDICATOR v3.0
// Fixed: Pine v6, removed colspan (not supported), all errors resolved
// ============================================================

//@version=6
indicator("Ultra Confluence v3.0", overlay=true,
     max_labels_count=500, max_lines_count=500)

// ─── INPUTS ─────────────────────────────────────────────────
grp1 = "━━━ EMA Settings ━━━"
ema_fast   = input.int(9,   "Fast EMA",  minval=1, group=grp1)
ema_mid    = input.int(21,  "Mid EMA",   minval=1, group=grp1)
ema_slow   = input.int(50,  "Slow EMA",  minval=1, group=grp1)
ema_trend  = input.int(200, "Trend EMA", minval=1, group=grp1)

grp2 = "━━━ RSI Settings ━━━"
rsi_len    = input.int(14, "RSI Length", minval=2, group=grp2)
rsi_ob     = input.int(70, "Overbought", group=grp2)
rsi_os     = input.int(30, "Oversold",   group=grp2)

grp3 = "━━━ MACD Settings ━━━"
macd_fast  = input.int(12, "MACD Fast",   group=grp3)
macd_slow  = input.int(26, "MACD Slow",   group=grp3)
macd_sig   = input.int(9,  "MACD Signal", group=grp3)

grp4 = "━━━ Bollinger Bands ━━━"
bb_len     = input.int(20,   "BB Length", group=grp4)
bb_mult    = input.float(2.0,"BB StdDev", group=grp4)

grp5 = "━━━ Supertrend ━━━"
st_atr_len = input.int(10,   "ATR Length", group=grp5)
st_factor  = input.float(3.0,"Factor",     group=grp5)

grp6 = "━━━ Stochastic ━━━"
stoch_k    = input.int(14, "K Length",  group=grp6)
stoch_d    = input.int(3,  "D Smooth",  group=grp6)
stoch_ob   = input.int(80, "Overbought",group=grp6)
stoch_os   = input.int(20, "Oversold",  group=grp6)

grp7 = "━━━ Signal Strength ━━━"
min_score   = input.int(6, "Min Confluence Score (1-9)", minval=1, maxval=9, group=grp7,
              tooltip="6=balanced | 7=high quality | 8+=very selective")
show_score  = input.bool(true,  "Show Score Labels",   group=grp7)
show_tp_sl  = input.bool(true,  "Show TP/SL Levels",   group=grp7)
atr_mult_sl = input.float(1.5,  "SL Multiplier (ATR)", group=grp7)
atr_mult_tp = input.float(3.0,  "TP Multiplier (ATR)", group=grp7)

grp8 = "━━━ Display ━━━"
show_emas   = input.bool(true,  "Show EMAs",            group=grp8)
show_bb     = input.bool(false, "Show Bollinger Bands", group=grp8)
show_vwap   = input.bool(true,  "Show VWAP",            group=grp8)

// ─── CALCULATIONS ────────────────────────────────────────────

// EMAs
e_fast  = ta.ema(close, ema_fast)
e_mid   = ta.ema(close, ema_mid)
e_slow  = ta.ema(close, ema_slow)
e_trend = ta.ema(close, ema_trend)

// RSI
rsi = ta.rsi(close, rsi_len)

// MACD
[macd_line, macd_signal_line, macd_hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)

// VWAP (Pine v6 syntax — no argument)
vwap_val = ta.vwap

// ATR
atr_val = ta.atr(14)

// Bollinger Bands
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev

// Stochastic
stoch_k_val = ta.stoch(close, high, low, stoch_k)
stoch_d_val = ta.sma(stoch_k_val, stoch_d)

// Supertrend
[st_val, st_dir] = ta.supertrend(st_factor, st_atr_len)
st_bull = st_dir < 0
st_bear = st_dir > 0

// Volume
vol_avg  = ta.sma(volume, 20)
high_vol = volume > vol_avg * 1.5

// MACD freshness — crossover within last 5 bars
macd_bull_cross  = ta.crossover(macd_line, macd_signal_line)
macd_bear_cross  = ta.crossunder(macd_line, macd_signal_line)
macd_bull_recent = macd_bull_cross or macd_bull_cross[1] or macd_bull_cross[2] or macd_bull_cross[3] or macd_bull_cross[4]
macd_bear_recent = macd_bear_cross or macd_bear_cross[1] or macd_bear_cross[2] or macd_bear_cross[3] or macd_bear_cross[4]

// ─── CONFLUENCE SCORING ──────────────────────────────────────

// BUY conditions
b1 = e_fast > e_mid and e_mid > e_slow
b2 = close > e_trend
b3 = rsi > 45 and rsi < rsi_ob
b4 = macd_line > macd_signal_line and macd_bull_recent
b5 = close > vwap_val
b6 = close > bb_basis and close < bb_upper
b7 = st_bull
b8 = stoch_k_val > stoch_d_val and stoch_k_val < stoch_ob
b9 = high_vol

buy_score = (b1?1:0)+(b2?1:0)+(b3?1:0)+(b4?1:0)+(b5?1:0)+(b6?1:0)+(b7?1:0)+(b8?1:0)+(b9?1:0)

// SELL conditions
s1 = e_fast < e_mid and e_mid < e_slow
s2 = close < e_trend
s3 = rsi < 55 and rsi > rsi_os
s4 = macd_line < macd_signal_line and macd_bear_recent
s5 = close < vwap_val
s6 = close < bb_basis and close > bb_lower
s7 = st_bear
s8 = stoch_k_val < stoch_d_val and stoch_k_val > stoch_os
s9 = high_vol

sell_score = (s1?1:0)+(s2?1:0)+(s3?1:0)+(s4?1:0)+(s5?1:0)+(s6?1:0)+(s7?1:0)+(s8?1:0)+(s9?1:0)

// ─── SIGNAL GENERATION ───────────────────────────────────────
buy_qualified  = buy_score  >= min_score and buy_score  > sell_score
sell_qualified = sell_score >= min_score and sell_score > buy_score

buy_confirmed  = buy_qualified  and not buy_qualified[1]
sell_confirmed = sell_qualified and not sell_qualified[1]

// ─── TP / SL ─────────────────────────────────────────────────
buy_sl  = close - atr_val * atr_mult_sl
buy_tp  = close + atr_val * atr_mult_tp
sell_sl = close + atr_val * atr_mult_sl
sell_tp = close - atr_val * atr_mult_tp

// ─── PLOTS ───────────────────────────────────────────────────
plot(show_emas ? e_fast  : na, "EMA 9",   color=color.new(color.yellow, 0), linewidth=1)
plot(show_emas ? e_mid   : na, "EMA 21",  color=color.new(color.orange, 0), linewidth=1)
plot(show_emas ? e_slow  : na, "EMA 50",  color=color.new(color.red,   30), linewidth=1)
plot(show_emas ? e_trend : na, "EMA 200", color=color.new(color.white, 50), linewidth=2)

p_upper = plot(show_bb ? bb_upper : na, "BB Upper", color=color.new(color.blue, 70))
p_lower = plot(show_bb ? bb_lower : na, "BB Lower", color=color.new(color.blue, 70))
fill(p_upper, p_lower, color=color.new(color.blue, 92))

plot(show_vwap ? vwap_val : na, "VWAP", color=color.new(color.purple, 20), linewidth=2)

plot(st_bull ? st_val : na, "ST Bull", color=color.new(color.green, 10), linewidth=2, style=plot.style_linebr)
plot(st_bear ? st_val : na, "ST Bear", color=color.new(color.red,   10), linewidth=2, style=plot.style_linebr)

// ─── SIGNAL SHAPES ───────────────────────────────────────────
plotshape(buy_confirmed,  title="BUY",  style=shape.labelup,   location=location.belowbar,
     color=color.new(color.green, 0), textcolor=color.white, text="BUY",  size=size.normal)
plotshape(sell_confirmed, title="SELL", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red,   0), textcolor=color.white, text="SELL", size=size.normal)

bgcolor(buy_confirmed  ? color.new(color.green, 85) : na)
bgcolor(sell_confirmed ? color.new(color.red,   85) : na)

// ─── SCORE LABELS ────────────────────────────────────────────
if show_score and buy_confirmed
    label.new(bar_index, low - atr_val * 0.8,
         "✦ " + str.tostring(buy_score) + "/9",
         style=label.style_label_up,
         color=color.new(color.green, 5),
         textcolor=color.white, size=size.small)

if show_score and sell_confirmed
    label.new(bar_index, high + atr_val * 0.8,
         "✦ " + str.tostring(sell_score) + "/9",
         style=label.style_label_down,
         color=color.new(color.red, 5),
         textcolor=color.white, size=size.small)

// ─── TP / SL LINES ───────────────────────────────────────────
if show_tp_sl
    if buy_confirmed
        line.new(bar_index, buy_tp, bar_index + 25, buy_tp,
             color=color.new(color.green, 20), style=line.style_dashed, width=1)
        line.new(bar_index, buy_sl, bar_index + 25, buy_sl,
             color=color.new(color.red,   20), style=line.style_dashed, width=1)
        label.new(bar_index + 25, buy_tp, "TP +" + str.tostring(math.round(atr_val * atr_mult_tp, 2)),
             style=label.style_label_left, color=color.new(color.green, 20),
             textcolor=color.white, size=size.tiny)
        label.new(bar_index + 25, buy_sl, "SL -" + str.tostring(math.round(atr_val * atr_mult_sl, 2)),
             style=label.style_label_left, color=color.new(color.red,   20),
             textcolor=color.white, size=size.tiny)
    if sell_confirmed
        line.new(bar_index, sell_tp, bar_index + 25, sell_tp,
             color=color.new(color.green, 20), style=line.style_dashed, width=1)
        line.new(bar_index, sell_sl, bar_index + 25, sell_sl,
             color=color.new(color.red,   20), style=line.style_dashed, width=1)
        label.new(bar_index + 25, sell_tp, "TP +" + str.tostring(math.round(atr_val * atr_mult_tp, 2)),
             style=label.style_label_left, color=color.new(color.green, 20),
             textcolor=color.white, size=size.tiny)
        label.new(bar_index + 25, sell_sl, "SL -" + str.tostring(math.round(atr_val * atr_mult_sl, 2)),
             style=label.style_label_left, color=color.new(color.red,   20),
             textcolor=color.white, size=size.tiny)

// ─── ALERTS ──────────────────────────────────────────────────
alertcondition(buy_confirmed,  title="🟢 BUY Signal",  message="ULTRA CONFLUENCE BUY  | Price: {{close}} | TF: {{interval}}")
alertcondition(sell_confirmed, title="🔴 SELL Signal", message="ULTRA CONFLUENCE SELL | Price: {{close}} | TF: {{interval}}")
alertcondition(buy_confirmed or sell_confirmed, title="⚡ Any Signal", message="Signal fired | Price: {{close}} | TF: {{interval}}")

// ─── DASHBOARD TABLE ─────────────────────────────────────────
// colspan is NOT supported in Pine Script — each cell must be set individually
var table dash = table.new(position.top_right, 2, 14,
     bgcolor=color.new(color.black, 65),
     border_color=color.new(color.gray, 55),
     border_width=1,
     frame_color=color.new(color.gray, 40),
     frame_width=1)

if barstate.islast
    // Row 0: Header — two cells, same text, no colspan
    table.cell(dash, 0, 0, "⚡ ULTRA CONFLUENCE", text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.black, 40))
    table.cell(dash, 1, 0, "v3.0",               text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.black, 40))

    // Row 1: BUY score
    table.cell(dash, 0, 1, "BUY Score",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(buy_score) + " / 9",
         text_color=buy_score >= min_score ? color.lime : color.gray, text_size=size.small)

    // Row 2: SELL score
    table.cell(dash, 0, 2, "SELL Score", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(sell_score) + " / 9",
         text_color=sell_score >= min_score ? color.red : color.gray, text_size=size.small)

    // Row 3: Divider — two cells
    table.cell(dash, 0, 3, "── CONDITIONS", text_color=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(dash, 1, 3, "──",            text_color=color.new(color.gray, 40), text_size=size.tiny)

    // Rows 4-12: Individual indicators
    table.cell(dash, 0, 4,  "EMA Stack",   text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 4,  b1 ? "▲ BULL"  : "▼ BEAR",  text_color=b1 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 5,  "200 EMA",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 5,  b2 ? "▲ ABOVE" : "▼ BELOW", text_color=b2 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 6,  "RSI " + str.tostring(math.round(rsi)), text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 6,  b3 ? "▲ BULL"  : "▼ BEAR",  text_color=b3 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 7,  "MACD",        text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 7,  b4 ? "▲ FRESH" : "▼ STALE", text_color=b4 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 8,  "VWAP",        text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 8,  b5 ? "▲ ABOVE" : "▼ BELOW", text_color=b5 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 9,  "Supertrend",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 9,  b7 ? "▲ BULL"  : "▼ BEAR",  text_color=b7 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 10, "Stochastic",  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 10, b8 ? "▲ BULL"  : "▼ BEAR",  text_color=b8 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 11, "BB Zone",     text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 11, b6 ? "▲ BULL"  : "▼ BEAR",  text_color=b6 ? color.lime : color.red, text_size=size.tiny)

    table.cell(dash, 0, 12, "Volume",      text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 12, high_vol ? "● HIGH" : "○ NORM",
         text_color=high_vol ? color.yellow : color.new(color.gray, 30), text_size=size.tiny)

    // Row 13: Current signal status
    table.cell(dash, 0, 13, "Signal",      text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 13,
         buy_confirmed  ? "▲ BUY"  :
         sell_confirmed ? "▼ SELL" : "— NONE",
         text_color=buy_confirmed ? color.lime : sell_confirmed ? color.red : color.gray,
         text_size=size.tiny)
````
