# EMA Pulse Momentum System [StrixEDGE]

- url: https://www.tradingview.com/script/mjxAQYhd-EMA-Pulse-Momentum-System-StrixEDGE/
- type: indicator
- pine_id: PUB;d44fdaded15c44b19d8b3f9369003fff
- version: 2.0

## Description

Overview

The EMA Pulse Momentum System is a trend-following indicator that combines a triple exponential moving average (EMA) ribbon with an RSI-based momentum gate to produce high-confidence directional signals on trending instruments. Unlike single-crossover systems that generate excessive noise, this indicator requires simultaneous alignment across three conditions before printing an entry — which significantly reduces false positives in ranging or choppy market environments.

How the signal logic works

The system operates on a three-layer confirmation model:

1. EMA Ribbon Alignment. Three EMAs are computed: a fast EMA (default 8), a mid EMA (default 21), and a slow EMA (default 55). For a valid long setup, all three must be fully stacked in ascending order (EMA 8 above EMA 21, EMA 21 above EMA 55). The reverse applies for short setups. This stacking condition eliminates entries during period of EMA compression or crossover noise, and acts as a structural trend filter. The ribbon also fills with a color-coded cloud between EMA 8 and EMA 21, providing instant visual feedback on trend health.

https://www.tradingview.com/x/SfvphW8J/

2. RSI Momentum Gate. Even with a clean ribbon, markets can trend without momentum confirmation — particularly after extended runs. A 14-period RSI is applied as a secondary gate: RSI must be above 52 to confirm bullish momentum, or below 48 to confirm bearish. These thresholds are intentionally set close to the 50 midline rather than the classic 70/30 extremes, because the goal is to confirm that momentum is directionally engaged, not to identify overbought or oversold conditions. The RSI thresholds are fully adjustable in settings.

https://www.tradingview.com/x/IcLiMew8/

3. Crossover Trigger. The entry fires only when EMA 8 crosses above EMA 21 (long) or below (short) while both the ribbon stack and RSI gate are simultaneously satisfied. The crossover itself does not generate a signal if either condition fails.

Risk management — ATR-based TP and SL

All risk levels are calculated dynamically using the Average True Range (ATR) over 14 periods, which adapts automatically to current market volatility. This means tighter levels during low-volatility regimes and wider levels during expansion — no manual adjustment required.

— Take Profit: Entry price ± (ATR × 2.0)
— Stop Loss: Entry price ± (ATR × 1.2)
— Default Risk-to-Reward ratio: 1.67 : 1 minimum

TP, SL, and entry lines are drawn forward 30 bars from each signal and labeled with exact price levels. All multipliers are adjustable via the settings panel.

Information table

A real-time dashboard table (position configurable: Bottom Right, Bottom Left, Top Right, Top Left) displays:
— Current trend direction (Bullish / Bearish / Neutral)
— Live RSI value with color coding
— Current ATR value for sizing context
— Last signal direction (Long / Short)
— Calculated Risk-to-Reward ratio
— EMA stack status (aligned or mixed)

Recommended usage

Best timeframes: 4H and Daily. The indicator functions on all timeframes but performs most reliably where EMA 8/21/55 have enough separation to define structure. On 1H or below, the signal frequency increases but false positives also rise — compensate by tightening RSI thresholds in settings.

Compatible with all liquid markets: Forex majors, Crypto (BTC, ETH, majors), Stocks, Indices, and Futures.

Avoid using this indicator as a standalone system during known high-impact news events (FOMC, NFP, CPI) where price gaps can invalidate ATR-based stops instantly.

Alerts

Two built-in alert conditions are included:
— "EMA Pulse — Long Entry": fires when all long conditions are satisfied
https://www.tradingview.com/x/MtLoaVC5/
https://www.tradingview.com/x/bEgW1ItU/

— "EMA Pulse — Short Entry": fires when all short conditions are satisfied
https://www.tradingview.com/x/dDZJ2mYG/
https://www.tradingview.com/x/dnwEYQWm/

Configure via the Alerts panel in TradingView using "Once per bar close" for cleanest signals.

Settings reference

EMA Fast (default 8) — reduce for more sensitivity, increase to reduce noise
EMA Mid (default 21) — core crossover reference line
EMA Slow (default 55) — structural trend filter
RSI Length (default 14) — period for momentum gate
RSI Bull Threshold (default 52) — minimum RSI for long confirmation
RSI Bear Threshold (default 48) — maximum RSI for short confirmation
ATR Length (default 14) — volatility lookback for TP/SL
TP Multiplier (default 2.0) — take profit distance in ATR units
SL Multiplier (default 1.2) — stop loss distance in ATR units

Limitations

This indicator is a technical analysis tool and does not constitute financial advice. Past signal performance does not guarantee future results. Always use proper position sizing and risk management independent of any indicator output.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("EMA Pulse Momentum System [StrixEDGE]", overlay=true, max_lines_count=10, max_labels_count=50, max_boxes_count=10)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
grp1 = "EMA Settings"
ema_fast   = input.int(8,  "Fast EMA",   minval=3,  maxval=50,  group=grp1)
ema_mid    = input.int(21, "Mid EMA",    minval=10, maxval=100, group=grp1)
ema_slow   = input.int(55, "Slow EMA",   minval=20, maxval=200, group=grp1)

grp2 = "RSI Filter"
rsi_len    = input.int(14, "RSI Length", minval=5, maxval=30, group=grp2)
rsi_bull   = input.int(52, "RSI Bull Threshold", minval=45, maxval=65, group=grp2, tooltip="RSI must be above this level for long entries")
rsi_bear   = input.int(48, "RSI Bear Threshold", minval=35, maxval=55, group=grp2, tooltip="RSI must be below this level for short entries")

grp3 = "Risk Management"
atr_len    = input.int(14,  "ATR Length",    minval=5,  maxval=30, group=grp3)
tp_mult    = input.float(2.0, "TP Multiplier (ATR)", minval=0.5, maxval=5.0, step=0.5, group=grp3)
sl_mult    = input.float(1.2, "SL Multiplier (ATR)", minval=0.3, maxval=3.0, step=0.1, group=grp3)

grp4 = "Display"
show_emas  = input.bool(true,  "Show EMA Lines",     group=grp4)
show_cloud = input.bool(true,  "Show EMA Cloud",     group=grp4)
show_table = input.bool(true,  "Show Info Table",    group=grp4)
tbl_pos    = input.string("Bottom Right", "Table Position", options=["Bottom Right","Bottom Left","Top Right","Top Left"], group=grp4)
tbl_size   = input.string("Small", "Table Size", options=["Tiny","Small","Normal","Large","Huge"], group=grp4)

// ─────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────
ema8  = ta.ema(close, ema_fast)
ema21 = ta.ema(close, ema_mid)
ema55 = ta.ema(close, ema_slow)
rsi   = ta.rsi(close, rsi_len)
atr   = ta.atr(atr_len)

// Ribbon alignment
bull_align = ema8 > ema21 and ema21 > ema55
bear_align = ema8 < ema21 and ema21 < ema55

// Momentum pulse: RSI crossing threshold from neutral
rsi_bull_confirm = rsi > rsi_bull
rsi_bear_confirm = rsi < rsi_bear

// Entry conditions
long_signal  = bull_align and rsi_bull_confirm and ta.crossover(ema8, ema21)
short_signal = bear_align and rsi_bear_confirm and ta.crossunder(ema8, ema21)

// ─────────────────────────────────────────────
// TP / SL LEVELS
// ─────────────────────────────────────────────
var float entry_price = na
var float tp_price    = na
var float sl_price    = na
var int   sig_dir     = 0  // 1=long, -1=short

if long_signal
    entry_price := close
    tp_price    := close + atr * tp_mult
    sl_price    := close - atr * sl_mult
    sig_dir     := 1

if short_signal
    entry_price := close
    tp_price    := close - atr * tp_mult
    sl_price    := close + atr * sl_mult
    sig_dir     := -1

// Risk:Reward ratio
rr_ratio = math.abs(tp_price - entry_price) / math.abs(sl_price - entry_price)

// ─────────────────────────────────────────────
// VISUALS — EMA LINES
// ─────────────────────────────────────────────
col_fast = bull_align ? color.new(#00C087, 0) : color.new(#FF5C72, 0)
col_mid  = bull_align ? color.new(#00C087, 30) : color.new(#FF5C72, 30)
col_slow = color.new(#9B9EA6, 40)

p_fast = plot(show_emas ? ema8  : na, "EMA Fast",  col_fast, 2)
p_mid  = plot(show_emas ? ema21 : na, "EMA Mid",   col_mid,  1)
p_slow = plot(show_emas ? ema55 : na, "EMA Slow",  col_slow, 1, plot.style_line)

// EMA Cloud between fast and mid
fill(p_fast, p_mid, color = show_cloud ? (bull_align ? color.new(#00C087, 88) : color.new(#FF5C72, 88)) : na, title="EMA Cloud")

// ─────────────────────────────────────────────
// ENTRY SIGNALS
// ─────────────────────────────────────────────
plotshape(long_signal,  "Long Entry",  shape.triangleup,   location.belowbar, color.new(#00C087, 0), size=size.normal)
plotshape(short_signal, "Short Entry", shape.triangledown,  location.abovebar, color.new(#FF5C72, 0), size=size.normal)

// ─────────────────────────────────────────────
// TP / SL LINES (drawn on signal bars)
// ─────────────────────────────────────────────
var line tp_line = na
var line sl_line = na
var line ep_line = na

if long_signal or short_signal
    line.delete(tp_line)
    line.delete(sl_line)
    line.delete(ep_line)

    ep_line := line.new(bar_index, entry_price, bar_index + 30, entry_price,
         color=color.new(#9B9EA6, 20), width=1, style=line.style_dashed)
    tp_line := line.new(bar_index, tp_price, bar_index + 30, tp_price,
         color=color.new(#00C087, 0), width=2, style=line.style_solid)
    sl_line := line.new(bar_index, sl_price, bar_index + 30, sl_price,
         color=color.new(#FF5C72, 0), width=2, style=line.style_solid)

// ─────────────────────────────────────────────
// TP / SL LABELS
// ─────────────────────────────────────────────
if long_signal or short_signal
    label.new(bar_index + 31, tp_price, "TP  " + str.tostring(math.round(tp_price, 4)),
         color=color.new(#00C087, 10), textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index + 31, entry_price, "EP  " + str.tostring(math.round(entry_price, 4)),
         color=color.new(#9B9EA6, 20), textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index + 31, sl_price, "SL  " + str.tostring(math.round(sl_price, 4)),
         color=color.new(#FF5C72, 10), textcolor=color.white, style=label.style_label_left, size=size.small)

// ─────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────
if show_table and barstate.islast
    tbl_position = switch tbl_pos
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        => position.bottom_right

    tbl_sz = switch tbl_size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

    tbl = table.new(tbl_position, 2, 7,
         bgcolor=color.new(#0C0F16, 8),
         border_color=color.new(#1E2738, 0),
         border_width=1,
         frame_color=color.new(#1E2738, 0),
         frame_width=1)

    // Header
    table.cell(tbl, 0, 0, "EMA PULSE SYSTEM", text_color=color.new(#E1E7EF, 0), text_size=tbl_sz, bgcolor=color.new(#161D2B, 0), text_halign=text.align_center)
    table.cell(tbl, 1, 0, "StrixEDGE", text_color=color.new(#4A9EFF, 0),       text_size=tbl_sz, bgcolor=color.new(#161D2B, 0), text_halign=text.align_center)

    // Trend status
    trend_txt   = bull_align ? "▲ BULLISH" : bear_align ? "▼ BEARISH" : "◈ NEUTRAL"
    trend_color = bull_align ? color.new(#00C087, 0) : bear_align ? color.new(#FF5C72, 0) : color.new(#9B9EA6, 0)
    table.cell(tbl, 0, 1, "Trend",  text_color=color.new(#8892A4, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))
    table.cell(tbl, 1, 1, trend_txt, text_color=trend_color,          text_size=tbl_sz, bgcolor=color.new(#111621, 0))

    // RSI
    rsi_txt   = str.tostring(math.round(rsi, 1))
    rsi_color = rsi > rsi_bull ? color.new(#00C087, 0) : rsi < rsi_bear ? color.new(#FF5C72, 0) : color.new(#9B9EA6, 0)
    table.cell(tbl, 0, 2, "RSI (" + str.tostring(rsi_len) + ")", text_color=color.new(#8892A4, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))
    table.cell(tbl, 1, 2, rsi_txt, text_color=rsi_color, text_size=tbl_sz, bgcolor=color.new(#111621, 0))

    // ATR
    table.cell(tbl, 0, 3, "ATR (" + str.tostring(atr_len) + ")", text_color=color.new(#8892A4, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))
    table.cell(tbl, 1, 3, str.tostring(math.round(atr, 4)),        text_color=color.new(#FFB547, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))

    // Last signal
    sig_txt   = sig_dir == 1 ? "▲ LONG" : sig_dir == -1 ? "▼ SHORT" : "—"
    sig_color = sig_dir == 1 ? color.new(#00C087, 0) : sig_dir == -1 ? color.new(#FF5C72, 0) : color.new(#9B9EA6, 0)
    table.cell(tbl, 0, 4, "Signal", text_color=color.new(#8892A4, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))
    table.cell(tbl, 1, 4, sig_txt,  text_color=sig_color,             text_size=tbl_sz, bgcolor=color.new(#111621, 0))

    // R:R
    rr_txt   = na(rr_ratio) ? "—" : str.tostring(math.round(rr_ratio, 2)) + " : 1"
    rr_color = na(rr_ratio) ? color.new(#9B9EA6, 0) : rr_ratio >= 1.5 ? color.new(#00C087, 0) : color.new(#FFB547, 0)
    table.cell(tbl, 0, 5, "R : R",  text_color=color.new(#8892A4, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))
    table.cell(tbl, 1, 5, rr_txt,   text_color=rr_color,              text_size=tbl_sz, bgcolor=color.new(#111621, 0))

    // EMA stack
    stack_txt   = bull_align ? "8>21>55 ✓" : bear_align ? "8<21<55 ✓" : "Mixed ✗"
    stack_color = (bull_align or bear_align) ? color.new(#00C087, 0) : color.new(#FF5C72, 0)
    table.cell(tbl, 0, 6, "Stack", text_color=color.new(#8892A4, 0), text_size=tbl_sz, bgcolor=color.new(#111621, 0))
    table.cell(tbl, 1, 6, stack_txt, text_color=stack_color,          text_size=tbl_sz, bgcolor=color.new(#111621, 0))

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(long_signal,  "EMA Pulse — Long Entry",  "EMA Pulse: LONG signal detected. Check RSI and EMA stack alignment.")
alertcondition(short_signal, "EMA Pulse — Short Entry", "EMA Pulse: SHORT signal detected. Check RSI and EMA stack alignment.")
````
