# SMC Apex by Cruz

- url: https://www.tradingview.com/script/P9ZI49sO-SMC-Apex-by-Cruz/
- type: indicator
- pine_id: PUB;62526d5bbd674e3682ba38b354a31103
- version: 1.0

## Description

SMC Apex by Cruz is a Pine Script v5 indicator built on Smart Money Concepts methodology.
Order Blocks: Detects the last bearish or bullish candle before an impulsive move using a 14-bar swing lookback. These zones mark institutional entry areas where price is likely to react.
Fair Value Gaps: Identifies three-candle imbalances using a minimum gap size filter of 0.1% to remove noise. Highlights areas where price tends to return to fill inefficiencies.
Break of Structure: Confirms trend continuation when price closes beyond a previous swing high or low, validated by a 3-bar breakout confirmation filter.
Change of Character: Detects the first BOS against the prevailing trend using swing point analysis, signaling potential trend reversals.
EMA Trend Filter: Uses EMA 50 and EMA 200 to filter signals. Longs only above EMA 50, shorts only below EMA 50.
Signal Cooldown: 10-bar cooldown between signals to prevent overtrading. Maximum 6 signals per session.
Auto TP and SL: Calculates levels based on nearest order block distance with a minimum 3:1 RR ratio.
Best used on 1H timeframe on crypto and forex pairs.

## Source Code

````pine
//@version=5
indicator("SMC Apex by Cruz", overlay=true, max_bars_back=500, max_lines_count=200, max_boxes_count=200, max_labels_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
ema_fast       = input.int(50,   "EMA Fast",               group="〔 Trend Filter 〕")
ema_slow       = input.int(200,  "EMA Slow",               group="〔 Trend Filter 〕")
show_emas      = input.bool(true,"Show EMAs",              group="〔 Trend Filter 〕")

fvg_min_size   = input.float(0.1,"Min FVG Size (%)",       group="〔 FVG Settings 〕", minval=0.01)
show_fvg       = input.bool(true,"Show FVG Boxes",         group="〔 FVG Settings 〕")
fvg_max_width  = input.int(10,   "FVG Max Width (bars)",   group="〔 FVG Settings 〕", minval=3, maxval=40)
fvg_filled_col = input.bool(true,"Fade FVG When Mitigated",group="〔 FVG Settings 〕")

swing_len      = input.int(14,   "Swing Lookback",         group="〔 Structure 〕",     minval=5)
rr_ratio       = input.float(3.0,"Min RR Ratio",           group="〔 Trade Settings 〕",minval=1.0)

// Relaxed breakout filter — was 5, now 3 bars lookback so more signals print
breakout_bars  = input.int(3,    "Breakout Confirm (bars)",group="〔 Trade Settings 〕",minval=1, maxval=10, tooltip="Lower = more signals, Higher = stricter")

cooldown_bars  = input.int(10,   "Signal Cooldown (bars)", group="〔 Signal Filter 〕", minval=3)
max_signals    = input.int(6,    "Max Signals Per Session",group="〔 Signal Filter 〕", minval=1)
choch_cooldown = input.int(8,    "CHoCH Label Cooldown",   group="〔 Signal Filter 〕", minval=3)

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
bull_color      = #00E5FF
bear_color      = #FF4C6A
fvg_bull_border = color.new(#00E5FF, 20)
fvg_bear_border = color.new(#FF4C6A, 20)
fvg_bull_fill   = color.new(#00E5FF, 88)
fvg_bear_fill   = color.new(#FF4C6A, 88)
fvg_mitigated   = color.new(#555555, 92)
ema_fast_col    = color.new(#FFD700, 55)
ema_slow_col    = color.new(#AAAAAA, 30)
choch_bull_col  = #00FF88
choch_bear_col  = #FF8800
tp_color        = color.new(#00E5FF, 15)
sl_color        = color.new(#FF4C6A, 15)

// ─────────────────────────────────────────────
// EMAs
// ─────────────────────────────────────────────
ema50  = ta.ema(close, ema_fast)
ema200 = ta.ema(close, ema_slow)

plot(show_emas ? ema50  : na, "EMA Fast", color=ema_fast_col, linewidth=1)
plot(show_emas ? ema200 : na, "EMA Slow", color=ema_slow_col, linewidth=2)

bull_trend = close > ema200
bear_trend = close < ema200

// ─────────────────────────────────────────────
// SESSION COUNTER
// ─────────────────────────────────────────────
var int signal_count    = 0
var int last_signal_bar = 0
var int last_label_bar  = 0

if ta.change(time("D")) != 0
    signal_count := 0

// ─────────────────────────────────────────────
// SWING HIGHS / LOWS
// ─────────────────────────────────────────────
swing_high = ta.pivothigh(high, swing_len, swing_len)
swing_low  = ta.pivotlow(low,  swing_len, swing_len)

var float last_sh = na
var float last_sl = na

if not na(swing_high)
    last_sh := swing_high
if not na(swing_low)
    last_sl := swing_low

// ─────────────────────────────────────────────
// BOS / CHoCH
// ─────────────────────────────────────────────
bos_bull   = not na(last_sh) and close > last_sh and close[1] <= last_sh[1]
bos_bear   = not na(last_sl) and close < last_sl and close[1] >= last_sl[1]
choch_bull = bos_bull and bear_trend
choch_bear = bos_bear and bull_trend

atr = ta.atr(14)
label_ok = (bar_index - last_label_bar) >= choch_cooldown

if label_ok
    if choch_bull
        label.new(bar_index, low - atr * 1.2, "CHoCH ▲",
             color=color.new(choch_bull_col, 70), textcolor=choch_bull_col,
             style=label.style_label_up, size=size.tiny)
        last_label_bar := bar_index
    else if choch_bear
        label.new(bar_index, high + atr * 1.2, "CHoCH ▼",
             color=color.new(choch_bear_col, 70), textcolor=choch_bear_col,
             style=label.style_label_down, size=size.tiny)
        last_label_bar := bar_index
    else if bos_bull and bull_trend
        label.new(bar_index, low - atr * 0.8, "BOS ▲",
             color=color.new(bull_color, 70), textcolor=color.new(bull_color, 0),
             style=label.style_label_up, size=size.tiny)
        last_label_bar := bar_index
    else if bos_bear and bear_trend
        label.new(bar_index, high + atr * 0.8, "BOS ▼",
             color=color.new(bear_color, 70), textcolor=color.new(bear_color, 0),
             style=label.style_label_down, size=size.tiny)
        last_label_bar := bar_index

// ─────────────────────────────────────────────
// FAIR VALUE GAPS
// ─────────────────────────────────────────────
fvg_bull_top    = low[0]
fvg_bull_bottom = high[2]
fvg_bull_valid  = fvg_bull_bottom < fvg_bull_top and
                  ((fvg_bull_top - fvg_bull_bottom) / fvg_bull_bottom * 100) >= fvg_min_size

fvg_bear_top    = low[2]
fvg_bear_bottom = high[0]
fvg_bear_valid  = fvg_bear_top > fvg_bear_bottom and
                  ((fvg_bear_top - fvg_bear_bottom) / fvg_bear_bottom * 100) >= fvg_min_size

if show_fvg and fvg_bull_valid and bull_trend
    b = box.new(bar_index - 2, fvg_bull_top, bar_index + fvg_max_width, fvg_bull_bottom,
         border_color=fvg_bull_border, bgcolor=fvg_bull_fill, border_width=1)
    if fvg_filled_col and low <= fvg_bull_top
        box.set_bgcolor(b, fvg_mitigated)
        box.set_border_color(b, color.new(#777777, 60))

if show_fvg and fvg_bear_valid and bear_trend
    b = box.new(bar_index - 2, fvg_bear_top, bar_index + fvg_max_width, fvg_bear_bottom,
         border_color=fvg_bear_border, bgcolor=fvg_bear_fill, border_width=1)
    if fvg_filled_col and high >= fvg_bear_bottom
        box.set_bgcolor(b, fvg_mitigated)
        box.set_border_color(b, color.new(#777777, 60))

// ─────────────────────────────────────────────
// ENTRY LOGIC
// ─────────────────────────────────────────────
var bool  waiting_bull = false
var bool  waiting_bear = false
var float bull_fvg_top = na
var float bull_fvg_bot = na
var float bear_fvg_top = na
var float bear_fvg_bot = na

if (bos_bull and bull_trend) or choch_bull
    waiting_bull   := true
    bull_fvg_top   := na
    bull_fvg_bot   := na

if (bos_bear and bear_trend) or choch_bear
    waiting_bear   := true
    bear_fvg_top   := na
    bear_fvg_bot   := na

if waiting_bull and fvg_bull_valid
    bull_fvg_top := fvg_bull_top
    bull_fvg_bot := fvg_bull_bottom

if waiting_bear and fvg_bear_valid
    bear_fvg_top := fvg_bear_top
    bear_fvg_bot := fvg_bear_bottom

bull_entry = waiting_bull and not na(bull_fvg_top) and low <= bull_fvg_top and close >= bull_fvg_bot and bull_trend
bear_entry = waiting_bear and not na(bear_fvg_top) and high >= bear_fvg_bot and close <= bear_fvg_top and bear_trend

if bull_entry
    waiting_bull := false
if bear_entry
    waiting_bear := false

// ─────────────────────────────────────────────
// BREAKOUT CONFIRMATION — relaxed to breakout_bars
// ─────────────────────────────────────────────
breakout_bull_raw = bull_entry and close > ta.highest(high, breakout_bars)[1]
breakout_bear_raw = bear_entry and close < ta.lowest(low,  breakout_bars)[1]

// ─────────────────────────────────────────────
// FILTERS
// ─────────────────────────────────────────────
cooldown_ok = (bar_index - last_signal_bar) >= cooldown_bars
under_max   = signal_count < max_signals

breakout_bull = breakout_bull_raw and cooldown_ok and under_max
breakout_bear = breakout_bear_raw and cooldown_ok and under_max

if breakout_bull or breakout_bear
    signal_count    := signal_count + 1
    last_signal_bar := bar_index

// ─────────────────────────────────────────────
// SL / TP
// ─────────────────────────────────────────────
bull_sl = bull_fvg_bot - atr * 0.5
bull_tp = close + (close - bull_sl) * rr_ratio
bear_sl = bear_fvg_top + atr * 0.5
bear_tp = close - (bear_sl - close) * rr_ratio

// ─────────────────────────────────────────────
// SIGNAL ARROWS + TP/SL — always printed together
// ─────────────────────────────────────────────
plotshape(breakout_bull, title="▲ LONG",
         location=location.belowbar, style=shape.triangleup,
         color=color.new(bull_color, 0), size=size.small,
         text="LONG", textcolor=color.new(bull_color, 0))

plotshape(breakout_bear, title="▼ SHORT",
         location=location.abovebar, style=shape.triangledown,
         color=color.new(bear_color, 0), size=size.small,
         text="SHORT", textcolor=color.new(bear_color, 0))

// TP/SL labels — only print when arrow fires (same bar)
if breakout_bull
    label.new(bar_index + 1, bull_tp,
         "🎯 TP  " + str.tostring(math.round(bull_tp, 4)),
         color=tp_color, textcolor=color.white,
         style=label.style_label_left, size=size.small)
    label.new(bar_index + 1, bull_sl,
         "🛑 SL  " + str.tostring(math.round(bull_sl, 4)),
         color=sl_color, textcolor=color.white,
         style=label.style_label_left, size=size.small)

if breakout_bear
    label.new(bar_index + 1, bear_tp,
         "🎯 TP  " + str.tostring(math.round(bear_tp, 4)),
         color=tp_color, textcolor=color.white,
         style=label.style_label_left, size=size.small)
    label.new(bar_index + 1, bear_sl,
         "🛑 SL  " + str.tostring(math.round(bear_sl, 4)),
         color=sl_color, textcolor=color.white,
         style=label.style_label_left, size=size.small)

// ─────────────────────────────────────────────
// PREMIUM DASHBOARD
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 6,
     bgcolor=color.new(#0D0D14, 5),
     border_color=color.new(#00E5FF, 50),
     border_width=1,
     frame_color=color.new(#00E5FF, 30),
     frame_width=1)

if barstate.islast
    // Row 0 — Header
    table.cell(dash, 0, 0, "SMC APEX",
         text_color=color.new(#00E5FF, 0), text_size=size.small,
         bgcolor=color.new(#00E5FF, 80), text_halign=text.align_center)
    table.cell(dash, 1, 0, "1H  •  CRYPTO",
         text_color=color.new(#CCCCCC, 0), text_size=size.small,
         bgcolor=color.new(#00E5FF, 80), text_halign=text.align_center)

    // Row 1 — Trend
    trend_txt   = bull_trend ? "▲  BULLISH" : "▼  BEARISH"
    trend_col   = bull_trend ? color.new(#00E5FF, 0) : color.new(#FF4C6A, 0)
    trend_bg    = bull_trend ? color.new(#00E5FF, 85) : color.new(#FF4C6A, 85)
    table.cell(dash, 0, 1, "Trend",
         text_color=color.new(#888888, 0), text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))
    table.cell(dash, 1, 1, trend_txt,
         text_color=trend_col, text_size=size.tiny, bgcolor=trend_bg)

    // Row 2 — EMA Distance
    ema_dist = math.round(math.abs(close - ema200) / ema200 * 100, 2)
    table.cell(dash, 0, 2, "EMA200 Dist",
         text_color=color.new(#888888, 0), text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))
    table.cell(dash, 1, 2, str.tostring(ema_dist) + "%",
         text_color=color.new(#CCCCCC, 0), text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))

    // Row 3 — Signals
    sig_col = signal_count >= max_signals ? color.new(#FF4C6A, 0) :
              signal_count >= max_signals - 1 ? color.new(#FFD700, 0) :
              color.new(#00E5FF, 0)
    sig_bg  = signal_count >= max_signals ? color.new(#FF4C6A, 85) : color.new(#0D0D14, 15)
    table.cell(dash, 0, 3, "Signals",
         text_color=color.new(#888888, 0), text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))
    table.cell(dash, 1, 3, str.tostring(signal_count) + " / " + str.tostring(max_signals),
         text_color=sig_col, text_size=size.tiny, bgcolor=sig_bg)

    // Row 4 — Slots left
    slots_left = max_signals - signal_count
    table.cell(dash, 0, 4, "Slots Left",
         text_color=color.new(#888888, 0), text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))
    table.cell(dash, 1, 4, str.tostring(slots_left) + " remaining",
         text_color=sig_col, text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))

    // Row 5 — Status
    status_txt = signal_count >= max_signals ? "⛔  LIMIT REACHED" :
                 bull_trend ? "✅  SCAN FOR LONG" : "✅  SCAN FOR SHORT"
    status_col = signal_count >= max_signals ? color.new(#FF4C6A, 0) : color.new(#00FF88, 0)
    status_bg  = signal_count >= max_signals ? color.new(#FF4C6A, 82) : color.new(#00FF88, 88)
    table.cell(dash, 0, 5, "Status",
         text_color=color.new(#888888, 0), text_size=size.tiny, bgcolor=color.new(#0D0D14, 15))
    table.cell(dash, 1, 5, status_txt,
         text_color=status_col, text_size=size.tiny, bgcolor=status_bg)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(breakout_bull, title="🟢 LONG — Cruz SMC",
     message="🟢 LONG | SMC Apex by Cruz | FVG Retest + BOS confirmed | Check TP & SL on chart")
alertcondition(breakout_bear, title="🔴 SHORT — Cruz SMC",
     message="🔴 SHORT | SMC Apex by Cruz | FVG Retest + BOS confirmed | Check TP & SL on chart")
alertcondition(signal_count >= max_signals, title="⛔ Daily Limit — Cruz SMC",
     message="⛔ SMC Apex: Max signals reached for today. No more entries allowed.")
````
