# Daily Cloud Roadmap by TenAMTrader

- url: https://www.tradingview.com/script/VaHKKvJw-Daily-Cloud-Roadmap-by-TenAMTrader/
- type: indicator
- pine_id: PUB;a423f55559404c2d88d48cc9ab64f1f1
- version: 1.0

## Description

Daily Cloud Roadmap by TenAMTrader

The Daily Cloud Roadmap is a multi-layer EMA cloud indicator designed to help intraday traders navigate price action using daily exponential moving average structure. Rather than plotting single EMA lines, each cloud is formed by a pair of EMAs, giving you a zone of confluence instead of a hard line — making it easier to read where price is relative to key daily levels, regardless of what timeframe you're trading on.
Five cloud layers are included by default:

Cloud 1: 8/9 EMA (short-term momentum)
Cloud 2: 13/14 EMA (near-term trend)
Cloud 3: 20/21 EMA (intermediate trend)
Cloud 4: 34/35 EMA (medium-term structure)
Cloud 5: 48/55 EMA (longer-term structure)

Each cloud changes color dynamically based on whether the shorter EMA is above or below the longer EMA, giving an at-a-glance read on the trend state of each layer. All periods, colors, and timeframes are fully customizable.
Additional features include:

Configurable EMA source and timeframe (defaults to Daily)
Optional EMA lines on top of each cloud
Optional ATR-based TP/SL bands anchored to any EMA
Optional smoothing for cleaner visuals on lower timeframes

How to use it:
Load it on any intraday chart — 1m, 5m, 15m, etc. — and the clouds will reflect the daily EMA levels, giving you a roadmap of where the significant daily structure sits as you trade intraday. Look for reactions at cloud edges, confluences between cloud layers, and color shifts as potential areas of interest.

⚠️ Disclaimer:
This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any security or financial instrument. Past performance of any trading strategy or methodology is not indicative of future results. Trading involves substantial risk of loss and is not suitable for all investors. You are solely responsible for your own trading decisions. TenAMTrader and the developer of this script accept no liability for any losses incurred as a result of using this indicator. Always conduct your own due diligence and consult a licensed financial advisor before making any trading decisions.

## Source Code

````pine
//@version=6
indicator('Daily Cloud Roadmap by TenAMTrader', overlay = true)

// ─────────────────────────────────────────────
// GLOBAL SETTINGS
// ─────────────────────────────────────────────
ema_tf = input.timeframe('D', title = 'EMA Timeframe', group = 'Global Settings')
ema_src = input.string('close', title = 'EMA Source', group = 'Global Settings', options = ['hl2', 'close', 'open', 'high', 'low', 'hlc3', 'ohlc4'])
smooth_on = input.bool(false, title = 'Smooth EMA Lines', group = 'Global Settings')
smooth_length = input.int(3, title = 'Smoothing Length', group = 'Global Settings', minval = 2, maxval = 10)

// ─────────────────────────────────────────────
// SOURCE RESOLVER
// ─────────────────────────────────────────────
src = ema_src == 'hl2' ? hl2 : ema_src == 'close' ? close : ema_src == 'open' ? open : ema_src == 'high' ? high : ema_src == 'low' ? low : ema_src == 'hlc3' ? hlc3 : ohlc4

// ─────────────────────────────────────────────
// EMA 1 SETTINGS
// ─────────────────────────────────────────────
ema1_show = input.bool(true, title = 'Show EMA 1', group = 'EMA 1')
ema1_show_lines = input.bool(false, title = 'Show EMA 1 Lines', group = 'EMA 1')
ema1_show_cloud = input.bool(true, title = 'Show EMA 1 Cloud', group = 'EMA 1')
ema1_short = input.int(8, title = 'EMA 1 Short Period', group = 'EMA 1', minval = 1)
ema1_long = input.int(9, title = 'EMA 1 Long Period', group = 'EMA 1', minval = 1)
ema1_bull_color = input.color(color.new(color.green, 80), title = 'EMA 1 Bullish Cloud Color', group = 'EMA 1')
ema1_bear_color = input.color(color.new(color.red, 80), title = 'EMA 1 Bearish Cloud Color', group = 'EMA 1')
ema1_bull_line = input.color(color.new(color.green, 0), title = 'EMA 1 Bullish Line Color', group = 'EMA 1')
ema1_bear_line = input.color(color.new(color.red, 0), title = 'EMA 1 Bearish Line Color', group = 'EMA 1')

// ─────────────────────────────────────────────
// EMA 2 SETTINGS
// ─────────────────────────────────────────────
ema2_show = input.bool(true, title = 'Show EMA 2', group = 'EMA 2')
ema2_show_lines = input.bool(false, title = 'Show EMA 2 Lines', group = 'EMA 2')
ema2_show_cloud = input.bool(true, title = 'Show EMA 2 Cloud', group = 'EMA 2')
ema2_short = input.int(13, title = 'EMA 2 Short Period', group = 'EMA 2', minval = 1)
ema2_long = input.int(14, title = 'EMA 2 Long Period', group = 'EMA 2', minval = 1)
ema2_bull_color = input.color(color.new(color.orange, 80), title = 'EMA 2 Bullish Cloud Color', group = 'EMA 2')
ema2_bear_color = input.color(color.new(color.yellow, 80), title = 'EMA 2 Bearish Cloud Color', group = 'EMA 2')
ema2_bull_line = input.color(color.new(color.orange, 0), title = 'EMA 2 Bullish Line Color', group = 'EMA 2')
ema2_bear_line = input.color(color.new(color.yellow, 0), title = 'EMA 2 Bearish Line Color', group = 'EMA 2')

// ─────────────────────────────────────────────
// EMA 3 SETTINGS
// ─────────────────────────────────────────────
ema3_show = input.bool(true, title = 'Show EMA 3', group = 'EMA 3')
ema3_show_lines = input.bool(false, title = 'Show EMA 3 Lines', group = 'EMA 3')
ema3_show_cloud = input.bool(true, title = 'Show EMA 3 Cloud', group = 'EMA 3')
ema3_short = input.int(20, title = 'EMA 3 Short Period', group = 'EMA 3', minval = 1)
ema3_long = input.int(21, title = 'EMA 3 Long Period', group = 'EMA 3', minval = 1)
ema3_bull_color = input.color(color.new(color.red, 80), title = 'EMA 3 Bullish Cloud Color', group = 'EMA 3')
ema3_bear_color = input.color(color.new(color.green, 80), title = 'EMA 3 Bearish Cloud Color', group = 'EMA 3')
ema3_bull_line = input.color(color.new(color.red, 0), title = 'EMA 3 Bullish Line Color', group = 'EMA 3')
ema3_bear_line = input.color(color.new(color.green, 0), title = 'EMA 3 Bearish Line Color', group = 'EMA 3')

// ─────────────────────────────────────────────
// EMA 4 SETTINGS (34/35)
// ─────────────────────────────────────────────
ema4_show = input.bool(true, title = 'Show EMA 4', group = 'EMA 4')
ema4_show_lines = input.bool(false, title = 'Show EMA 4 Lines', group = 'EMA 4')
ema4_show_cloud = input.bool(true, title = 'Show EMA 4 Cloud', group = 'EMA 4')
ema4_short = input.int(34, title = 'EMA 4 Short Period', group = 'EMA 4', minval = 1)
ema4_long = input.int(35, title = 'EMA 4 Long Period', group = 'EMA 4', minval = 1)
ema4_bull_color = input.color(color.new(color.fuchsia, 80), title = 'EMA 4 Bullish Cloud Color', group = 'EMA 4')
ema4_bear_color = input.color(color.new(color.purple, 80), title = 'EMA 4 Bearish Cloud Color', group = 'EMA 4')
ema4_bull_line = input.color(color.new(color.fuchsia, 0), title = 'EMA 4 Bullish Line Color', group = 'EMA 4')
ema4_bear_line = input.color(color.new(color.purple, 0), title = 'EMA 4 Bearish Line Color', group = 'EMA 4')

// ─────────────────────────────────────────────
// EMA 5 SETTINGS (48/55)
// ─────────────────────────────────────────────
ema5_show = input.bool(true, title = 'Show EMA 5', group = 'EMA 5')
ema5_show_lines = input.bool(false, title = 'Show EMA 5 Lines', group = 'EMA 5')
ema5_show_cloud = input.bool(true, title = 'Show EMA 5 Cloud', group = 'EMA 5')
ema5_short = input.int(48, title = 'EMA 5 Short Period', group = 'EMA 5', minval = 1)
ema5_long = input.int(55, title = 'EMA 5 Long Period', group = 'EMA 5', minval = 1)
ema5_bull_color = input.color(color.new(color.aqua, 80), title = 'EMA 5 Bullish Cloud Color', group = 'EMA 5')
ema5_bear_color = input.color(color.new(color.blue, 80), title = 'EMA 5 Bearish Cloud Color', group = 'EMA 5')
ema5_bull_line = input.color(color.new(color.aqua, 0), title = 'EMA 5 Bullish Line Color', group = 'EMA 5')
ema5_bear_line = input.color(color.new(color.blue, 0), title = 'EMA 5 Bearish Line Color', group = 'EMA 5')

// ─────────────────────────────────────────────
// TP / SL BAND SETTINGS
// ─────────────────────────────────────────────
tp_source_ema = input.string('EMA 1 Short', title = 'Base EMA for Bands', group = 'TP/SL Bands', options = ['EMA 1 Short', 'EMA 1 Long', 'EMA 2 Short', 'EMA 2 Long', 'EMA 3 Short', 'EMA 3 Long', 'EMA 4 Short', 'EMA 4 Long', 'EMA 5 Short', 'EMA 5 Long'])
tp_atr_length = input.int(50, title = 'ATR Lookback Length', group = 'TP/SL Bands', minval = 1)
tp_mult = input.float(1.5, title = 'TP Band Multiplier', group = 'TP/SL Bands', minval = 0.1, step = 0.1)
sl_mult = input.float(1.0, title = 'SL Band Multiplier', group = 'TP/SL Bands', minval = 0.1, step = 0.1)
tp_show_upper = input.bool(false, title = 'Show TP Upper Band', group = 'TP/SL Bands')
tp_show_lower = input.bool(false, title = 'Show SL Lower Band', group = 'TP/SL Bands')
tp_show_fill = input.bool(false, title = 'Show Band Fill', group = 'TP/SL Bands')
tp_upper_color = input.color(color.new(color.teal, 0), title = 'TP Line Color', group = 'TP/SL Bands')
tp_lower_color = input.color(color.new(color.orange, 0), title = 'SL Line Color', group = 'TP/SL Bands')
tp_fill_color = input.color(color.new(color.teal, 85), title = 'Band Fill Color', group = 'TP/SL Bands')

// ─────────────────────────────────────────────
// SMOOTHING FUNCTION
// ─────────────────────────────────────────────
smooth(src_val) =>
    smooth_on ? ta.ema(ta.ema(src_val, smooth_length), smooth_length) : src_val

// ─────────────────────────────────────────────
// CALCULATE EMAs
// ─────────────────────────────────────────────
f_ema(p) =>
    ta.ema(src, p)

ema1_ema_s = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema1_short), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))
ema1_ema_l = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema1_long), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))

ema2_ema_s = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema2_short), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))
ema2_ema_l = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema2_long), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))

ema3_ema_s = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema3_short), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))
ema3_ema_l = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema3_long), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))

ema4_ema_s = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema4_short), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))
ema4_ema_l = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema4_long), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))

ema5_ema_s = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema5_short), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))
ema5_ema_l = smooth(request.security(syminfo.tickerid, ema_tf, f_ema(ema5_long), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))

// ─────────────────────────────────────────────
// SELECT BASE EMA FOR BANDS
// ─────────────────────────────────────────────
tp_base_ema = tp_source_ema == 'EMA 1 Short' ? ema1_ema_s : tp_source_ema == 'EMA 1 Long' ? ema1_ema_l : tp_source_ema == 'EMA 2 Short' ? ema2_ema_s : tp_source_ema == 'EMA 2 Long' ? ema2_ema_l : tp_source_ema == 'EMA 3 Short' ? ema3_ema_s : tp_source_ema == 'EMA 3 Long' ? ema3_ema_l : tp_source_ema == 'EMA 4 Short' ? ema4_ema_s : tp_source_ema == 'EMA 4 Long' ? ema4_ema_l : tp_source_ema == 'EMA 5 Short' ? ema5_ema_s : ema5_ema_l

// ─────────────────────────────────────────────
// ATR BANDS
// ─────────────────────────────────────────────
band_atr = request.security(syminfo.tickerid, ema_tf, ta.atr(tp_atr_length), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
tp_upper_band = tp_base_ema + band_atr * tp_mult
tp_lower_band = tp_base_ema - band_atr * sl_mult

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
ema1_color = ema1_ema_s > ema1_ema_l ? ema1_bull_color : ema1_bear_color
ema1_line_color = ema1_ema_s > ema1_ema_l ? ema1_bull_line : ema1_bear_line
ema2_color = ema2_ema_s > ema2_ema_l ? ema2_bull_color : ema2_bear_color
ema2_line_color = ema2_ema_s > ema2_ema_l ? ema2_bull_line : ema2_bear_line
ema3_color = ema3_ema_s > ema3_ema_l ? ema3_bull_color : ema3_bear_color
ema3_line_color = ema3_ema_s > ema3_ema_l ? ema3_bull_line : ema3_bear_line
ema4_color = ema4_ema_s > ema4_ema_l ? ema4_bull_color : ema4_bear_color
ema4_line_color = ema4_ema_s > ema4_ema_l ? ema4_bull_line : ema4_bear_line
ema5_color = ema5_ema_s > ema5_ema_l ? ema5_bull_color : ema5_bear_color
ema5_line_color = ema5_ema_s > ema5_ema_l ? ema5_bull_line : ema5_bear_line

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
p1s = plot(ema1_show ? ema1_ema_s : na, color = ema1_show_lines ? ema1_line_color : na, linewidth = 1, title = 'EMA 1 Short')
p1l = plot(ema1_show ? ema1_ema_l : na, color = ema1_show_lines ? ema1_line_color : na, linewidth = 1, title = 'EMA 1 Long')
p2s = plot(ema2_show ? ema2_ema_s : na, color = ema2_show_lines ? ema2_line_color : na, linewidth = 1, title = 'EMA 2 Short')
p2l = plot(ema2_show ? ema2_ema_l : na, color = ema2_show_lines ? ema2_line_color : na, linewidth = 1, title = 'EMA 2 Long')
p3s = plot(ema3_show ? ema3_ema_s : na, color = ema3_show_lines ? ema3_line_color : na, linewidth = 1, title = 'EMA 3 Short')
p3l = plot(ema3_show ? ema3_ema_l : na, color = ema3_show_lines ? ema3_line_color : na, linewidth = 1, title = 'EMA 3 Long')
p4s = plot(ema4_show ? ema4_ema_s : na, color = ema4_show_lines ? ema4_line_color : na, linewidth = 1, title = 'EMA 4 Short')
p4l = plot(ema4_show ? ema4_ema_l : na, color = ema4_show_lines ? ema4_line_color : na, linewidth = 1, title = 'EMA 4 Long')
p5s = plot(ema5_show ? ema5_ema_s : na, color = ema5_show_lines ? ema5_line_color : na, linewidth = 1, title = 'EMA 5 Short')
p5l = plot(ema5_show ? ema5_ema_l : na, color = ema5_show_lines ? ema5_line_color : na, linewidth = 1, title = 'EMA 5 Long')

p_upper = plot(tp_show_upper ? tp_upper_band : na, color = tp_upper_color, linewidth = 1, title = 'TP Upper Band')
p_lower = plot(tp_show_lower ? tp_lower_band : na, color = tp_lower_color, linewidth = 1, title = 'SL Lower Band')
fill(p_upper, p_lower, color = tp_show_fill and tp_show_upper and tp_show_lower ? tp_fill_color : na)

fill(p1s, p1l, color = ema1_show_cloud ? ema1_color : na, title = 'EMA 1 Cloud')
fill(p2s, p2l, color = ema2_show_cloud ? ema2_color : na, title = 'EMA 2 Cloud')
fill(p3s, p3l, color = ema3_show_cloud ? ema3_color : na, title = 'EMA 3 Cloud')
fill(p4s, p4l, color = ema4_show_cloud ? ema4_color : na, title = 'EMA 4 Cloud')
fill(p5s, p5l, color = ema5_show_cloud ? ema5_color : na, title = 'EMA 5 Cloud')
````
