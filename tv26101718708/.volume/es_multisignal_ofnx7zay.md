# ES Multi-Signal

- url: https://www.tradingview.com/script/ofnx7ZAy-ES-Multi-Signal/
- type: indicator
- pine_id: PUB;24a6268a54e04152b4955b90371bcbd4
- version: 1.0

## Description

Cole Multi-Signal B/S combines five battle-tested indicators into a single, vote-based buy/sell system designed for intraday traders on the 15–30 minute chart.
The script aggregates signals from Keltner Channels (volatility breakouts), Williams Alligator (trend confirmation via three smoothed moving averages), VWAP (institutional price bias), RSI (momentum positioning), and MACD (trend + momentum crossover). Each indicator casts an independent bull or bear vote on every bar, and a BUY or SELL label prints only when at least 3 of 5 agree — filtering out the noise that plagues single-indicator systems.
Features:

Majority-vote mode (3/5) for balanced signal frequency, or strict mode (5/5) for high-conviction setups only
Built-in signal deduplication — no repeat labels until direction actually flips
On-chart score breakdown showing exactly which indicators confirmed each signal
Fully configurable lengths, multipliers, and thresholds for every component
Alert conditions ready for TradingView webhooks (Discord, brokers, custom apps)

Best used on: SPY, QQQ, and liquid large-caps on 15m–1H charts during regular market hours. VWAP anchoring resets each session, making this especially effective for intraday setups.
Not financial advice. Always backtest and paper-trade before committing capital.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Cole_MultiSignal_v1

//@version=5
indicator(title="Cole Multi-Signal B/S [KC + Alligator + VWAP + RSI + MACD]",
     shorttitle="Cole B/S",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500)

// ─────────────────────────────────────────────
//  INPUT GROUPS
// ─────────────────────────────────────────────

// Keltner Channel
kc_len     = input.int(20,   "KC Length",          group="Keltner Channel")
kc_mult    = input.float(2.0,"KC Multiplier",      group="Keltner Channel")
kc_atr_len = input.int(10,   "KC ATR Length",      group="Keltner Channel")

// Williams Alligator
jaw_len    = input.int(13, "Jaw Length",   group="Williams Alligator")
jaw_off    = input.int(8,  "Jaw Offset",   group="Williams Alligator")
teeth_len  = input.int(8,  "Teeth Length", group="Williams Alligator")
teeth_off  = input.int(5,  "Teeth Offset", group="Williams Alligator")
lips_len   = input.int(5,  "Lips Length",  group="Williams Alligator")
lips_off   = input.int(3,  "Lips Offset",  group="Williams Alligator")

// RSI
rsi_len    = input.int(14,  "RSI Length",       group="RSI")
rsi_ob     = input.int(70,  "Overbought Level", group="RSI")
rsi_os     = input.int(30,  "Oversold Level",   group="RSI")

// MACD
macd_fast  = input.int(12, "MACD Fast",   group="MACD")
macd_slow  = input.int(26, "MACD Slow",   group="MACD")
macd_sig   = input.int(9,  "MACD Signal", group="MACD")

// Signal Filter
require_all = input.bool(false, "Require ALL conditions (strict mode)", group="Signal Filter",
     tooltip="OFF = majority vote (3 of 5). ON = all 5 must agree.")

// Visuals
show_kc    = input.bool(true,  "Show Keltner Bands",  group="Display")
show_vwap  = input.bool(true,  "Show VWAP Line",      group="Display")
show_allig = input.bool(true,  "Show Alligator Lines", group="Display")
show_label = input.bool(true,  "Show B/S Labels",     group="Display")

// ─────────────────────────────────────────────
//  1. KELTNER CHANNEL
// ─────────────────────────────────────────────
kc_basis = ta.ema(close, kc_len)
kc_atr   = ta.atr(kc_atr_len)
kc_upper = kc_basis + kc_mult * kc_atr
kc_lower = kc_basis - kc_mult * kc_atr

kc_bull = close > kc_upper  // price breaking above upper band
kc_bear = close < kc_lower  // price breaking below lower band

// Plot KC
p_kc_u = plot(show_kc ? kc_upper : na, "KC Upper", color=color.new(color.orange, 70), linewidth=1)
p_kc_l = plot(show_kc ? kc_lower : na, "KC Lower", color=color.new(color.orange, 70), linewidth=1)
p_kc_m = plot(show_kc ? kc_basis : na, "KC Mid",   color=color.new(color.orange, 85), linewidth=1, style=plot.style_circles)
fill(p_kc_u, p_kc_l, color=color.new(color.orange, 93))

// ─────────────────────────────────────────────
//  2. WILLIAMS ALLIGATOR
// ─────────────────────────────────────────────
// Uses SMMA (Wilder's smoothed MA) on hl2
smma(src, length, offset) =>
    smma_val = ta.sma(src, length)
    smma_val := na(smma_val[1]) ? smma_val : (smma_val[1] * (length - 1) + src) / length
    smma_val[offset]

jaw    = smma(hl2, jaw_len,   jaw_off)
teeth  = smma(hl2, teeth_len, teeth_off)
lips   = smma(hl2, lips_len,  lips_off)

// Alligator open = lines fanned (lips > teeth > jaw for bull)
allig_bull = lips > teeth and teeth > jaw
allig_bear = lips < teeth and teeth < jaw

plot(show_allig ? jaw   : na, "Jaw",   color=color.new(color.blue,   0), linewidth=2)
plot(show_allig ? teeth : na, "Teeth", color=color.new(color.red,    0), linewidth=2)
plot(show_allig ? lips  : na, "Lips",  color=color.new(color.green,  0), linewidth=2)

// ─────────────────────────────────────────────
//  3. VWAP
// ─────────────────────────────────────────────
vwap_val = ta.vwap(hlc3)
vwap_bull = close > vwap_val
vwap_bear = close < vwap_val

plot(show_vwap ? vwap_val : na, "VWAP", color=color.new(color.purple, 0), linewidth=2, style=plot.style_stepline)

// ─────────────────────────────────────────────
//  4. RSI
// ─────────────────────────────────────────────
rsi_val  = ta.rsi(close, rsi_len)
rsi_bull = rsi_val > 50 and rsi_val < rsi_ob   // bullish momentum, not yet overbought
rsi_bear = rsi_val < 50 and rsi_val > rsi_os   // bearish momentum, not yet oversold

// ─────────────────────────────────────────────
//  5. MACD
// ─────────────────────────────────────────────
[macd_line, signal_line, hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)
macd_bull = macd_line > signal_line and macd_line > 0
macd_bear = macd_line < signal_line and macd_line < 0

// ─────────────────────────────────────────────
//  SIGNAL AGGREGATION
// ─────────────────────────────────────────────
bull_score = (kc_bull ? 1 : 0) + (allig_bull ? 1 : 0) + (vwap_bull ? 1 : 0) + (rsi_bull ? 1 : 0) + (macd_bull ? 1 : 0)
bear_score = (kc_bear ? 1 : 0) + (allig_bear ? 1 : 0) + (vwap_bear ? 1 : 0) + (rsi_bear ? 1 : 0) + (macd_bear ? 1 : 0)

threshold = require_all ? 5 : 3

buy_signal  = bull_score >= threshold and bull_score > bear_score
sell_signal = bear_score >= threshold and bear_score > bull_score

// ─────────────────────────────────────────────
//  SIGNAL DEDUPLICATION (no consecutive repeats)
// ─────────────────────────────────────────────
var int last_signal = 0  // 1 = last was buy, -1 = last was sell

clean_buy  = buy_signal  and last_signal != 1
clean_sell = sell_signal and last_signal != -1

if clean_buy
    last_signal := 1
if clean_sell
    last_signal := -1

// ─────────────────────────────────────────────
//  SHAPES ON CHART
// ─────────────────────────────────────────────
plotshape(clean_buy,  title="BUY",  style=shape.labelup,   location=location.belowbar,
     color=color.new(color.lime, 0),  textcolor=color.white, text="BUY",  size=size.normal)
plotshape(clean_sell, title="SELL", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red,  0),  textcolor=color.white, text="SELL", size=size.normal)

// ─────────────────────────────────────────────
//  SCORE LABEL (optional)
// ─────────────────────────────────────────────
if show_label and (clean_buy or clean_sell)
    lbl_txt = clean_buy
         ? "▲ BULL " + str.tostring(bull_score) + "/5\nKC:" + (kc_bull?"✓":"✗") + " ALG:" + (allig_bull?"✓":"✗") + " VWAP:" + (vwap_bull?"✓":"✗") + " RSI:" + (rsi_bull?"✓":"✗") + " MACD:" + (macd_bull?"✓":"✗")
         : "▼ BEAR " + str.tostring(bear_score) + "/5\nKC:" + (kc_bear?"✓":"✗") + " ALG:" + (allig_bear?"✓":"✗") + " VWAP:" + (vwap_bear?"✓":"✗") + " RSI:" + (rsi_bear?"✓":"✗") + " MACD:" + (macd_bear?"✓":"✗")
    lbl_col = clean_buy ? color.new(color.lime, 15) : color.new(color.red, 15)
    lbl_y   = clean_buy ? low * 0.9985 : high * 1.0015
    label.new(bar_index, lbl_y, lbl_txt,
         color=lbl_col, textcolor=color.white,
         style=clean_buy ? label.style_label_up : label.style_label_down,
         size=size.small)

// ─────────────────────────────────────────────
//  BACKGROUND HIGHLIGHT
// ─────────────────────────────────────────────
bgcolor(clean_buy  ? color.new(color.lime, 88) : na, title="Buy Zone BG")
bgcolor(clean_sell ? color.new(color.red,  88) : na, title="Sell Zone BG")

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(clean_buy,  title="BUY Signal",  message="Cole Multi-Signal: BUY triggered — bull score {{plot_0}}/5")
alertcondition(clean_sell, title="SELL Signal", message="Cole Multi-Signal: SELL triggered — bear score {{plot_0}}/5")
````
