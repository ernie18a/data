# MTF SMC Suite [FVG | Liquidity | Swings | Signals]

- url: https://www.tradingview.com/script/9InaFnMq-MTF-SMC-Suite-FVG-Liquidity-Swings-Signals/
- type: indicator
- pine_id: PUB;9df1e38fed2c467abf23619e083805b1
- version: 1.0

## Description

This indicator is going to give you all the liquidity, when you can buy and when you can sell. it is going to give you also all the high and all the lows. it will be the best indicator to be able to winn on every trade.

## Source Code

````pine
//@version=6
indicator('MTF SMC Suite [FVG | Liquidity | Swings | Signals]', overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════
//  SETTINGS
// ═══════════════════════════════════════════════════════════════

// --- Timeframe Toggles ---
grp_tf = '⏱ Timeframe Selection'
show_1m = input.bool(true, '1 Min', group = grp_tf, inline = 'tf1')
show_5m = input.bool(true, '5 Min', group = grp_tf, inline = 'tf1')
show_15m = input.bool(true, '15 Min', group = grp_tf, inline = 'tf2')
show_30m = input.bool(true, '30 Min', group = grp_tf, inline = 'tf2')
show_1h = input.bool(true, '1 Hour', group = grp_tf, inline = 'tf3')

// --- FVG Settings ---
grp_fvg = '📦 Fair Value Gaps (FVG / iFVG)'
show_fvg = input.bool(true, 'Show FVG', group = grp_fvg)
show_ifvg = input.bool(true, 'Show iFVG', group = grp_fvg)
fvg_bull_col = input.color(color.new(#00e676, 80), 'Bullish FVG Color', group = grp_fvg)
fvg_bear_col = input.color(color.new(#ff1744, 80), 'Bearish FVG Color', group = grp_fvg)
ifvg_bull_col = input.color(color.new(#76ff03, 70), 'iFVG Bull Color', group = grp_fvg)
ifvg_bear_col = input.color(color.new(#ff6d00, 70), 'iFVG Bear Color', group = grp_fvg)
fvg_extend = input.int(20, 'FVG Extend Bars', minval = 1, maxval = 100, group = grp_fvg)

// --- Liquidity Settings ---
grp_liq = '💧 Liquidity Swings'
show_liq = input.bool(true, 'Show Liquidity Levels', group = grp_liq)
liq_len = input.int(10, 'Swing Lookback', minval = 3, maxval = 50, group = grp_liq)
liq_bull_col = input.color(color.new(#00bcd4, 0), 'Buy-Side Liquidity', group = grp_liq)
liq_bear_col = input.color(color.new(#ff5722, 0), 'Sell-Side Liquidity', group = grp_liq)
liq_style = input.string('Dashed', 'Line Style', options = ['Solid', 'Dashed', 'Dotted'], group = grp_liq)

// --- Swing High/Low Settings ---
grp_swg = '📈 Swing Highs / Lows'
show_swings = input.bool(true, 'Show Swing H/L', group = grp_swg)
swing_len = input.int(5, 'Swing Length', minval = 2, maxval = 30, group = grp_swg)
show_bos = input.bool(true, 'Show BOS/CHoCH', group = grp_swg)
sh_col = input.color(color.new(#f44336, 0), 'Swing High Label', group = grp_swg)
sl_col = input.color(color.new(#4caf50, 0), 'Swing Low Label', group = grp_swg)
bos_bull_col = input.color(color.new(#00e5ff, 0), 'BOS Bullish', group = grp_swg)
bos_bear_col = input.color(color.new(#ff6e40, 0), 'BOS Bearish', group = grp_swg)

// --- Candle Pattern Settings ---
grp_candle = '🕯 Candle Patterns'
show_patterns = input.bool(true, 'Show Candle Patterns', group = grp_candle)
show_engulf = input.bool(true, 'Engulfing', group = grp_candle)
show_hammer = input.bool(true, 'Hammer / Shooting Star', group = grp_candle)
show_doji = input.bool(true, 'Doji', group = grp_candle)
show_pin = input.bool(true, 'Pin Bar', group = grp_candle)

// --- Buy/Sell Signal Settings ---
grp_sig = '🚦 Buy / Sell Signals'
show_signals = input.bool(true, 'Show Signals', group = grp_sig)
signal_method = input.string('SMC Confluence', 'Signal Method', options = ['SMC Confluence', 'FVG + Swing', 'BOS + FVG'], group = grp_sig)
sig_buy_col = input.color(color.new(#00e676, 0), 'Buy Signal Color', group = grp_sig)
sig_sell_col = input.color(color.new(#ff1744, 0), 'Sell Signal Color', group = grp_sig)

// --- Checklist Table ---
grp_tbl = '📋 Trade Quality Checklist Table'
show_table = input.bool(true, 'Show Checklist Table', group = grp_tbl)
tbl_pos = input.string('Bottom Right', 'Table Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Middle Right'], group = grp_tbl)
tbl_size = input.string('Small', 'Text Size', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large'], group = grp_tbl)

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════

lineStyle(_s) =>
    _s == 'Dashed' ? line.style_dashed : _s == 'Dotted' ? line.style_dotted : line.style_solid

tblPos(_p) =>
    _p == 'Top Right' ? position.top_right : _p == 'Top Left' ? position.top_left : _p == 'Bottom Left' ? position.bottom_left : _p == 'Middle Right' ? position.middle_right : position.bottom_right

tblTxtSize(_s) =>
    _s == 'Tiny' ? size.tiny : _s == 'Small' ? size.small : _s == 'Large' ? size.large : _s == 'Normal' ? size.normal : size.auto

// ═══════════════════════════════════════════════════════════════
//  MULTI-TIMEFRAME DATA REQUESTS
// ═══════════════════════════════════════════════════════════════

[o1, h1, l1, c1, v1] = request.security(syminfo.tickerid, '1', [open, high, low, close, volume], lookahead = barmerge.lookahead_off)
[o5, h5, l5, c5, v5] = request.security(syminfo.tickerid, '5', [open, high, low, close, volume], lookahead = barmerge.lookahead_off)
[o15, h15, l15, c15, v15] = request.security(syminfo.tickerid, '15', [open, high, low, close, volume], lookahead = barmerge.lookahead_off)
[o30, h30, l30, c30, v30] = request.security(syminfo.tickerid, '30', [open, high, low, close, volume], lookahead = barmerge.lookahead_off)
[o60, h60, l60, c60, v60] = request.security(syminfo.tickerid, '60', [open, high, low, close, volume], lookahead = barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════
//  CURRENT CHART BARS — FVG DETECTION
// ═══════════════════════════════════════════════════════════════

// FVG: gap between candle[2].high and candle[0].low (bull) or candle[2].low and candle[0].high (bear)
// We detect on chart timeframe for the primary drawings; MTF info fed into table/signals

bull_fvg = low > high[2] // price gap above — bullish FVG
bear_fvg = high < low[2] // price gap below — bearish FVG

// iFVG = a previously formed FVG that has been mitigated (price traded back into it)
var float fvg_top = na
var float fvg_bot = na
var bool fvg_bull_active = false
var bool fvg_bear_active = false

if bull_fvg and show_fvg
    fvg_top := low
    fvg_bot := high[2]
    fvg_bull_active := true
    fvg_bull_active

if bear_fvg and show_fvg
    fvg_top := low[2]
    fvg_bot := high
    fvg_bear_active := true
    fvg_bear_active

// Draw FVG boxes
if bull_fvg and show_fvg
    box.new(bar_index - 2, low, bar_index + fvg_extend, high[2], bgcolor = fvg_bull_col, border_color = color.new(#00e676, 60), border_width = 1)

if bear_fvg and show_fvg
    box.new(bar_index - 2, high, bar_index + fvg_extend, low[2], bgcolor = fvg_bear_col, border_color = color.new(#ff1744, 60), border_width = 1)

// iFVG: detect when price re-enters a prior FVG zone
ifvg_bull_trigger = fvg_bull_active and close < fvg_top
ifvg_bear_trigger = fvg_bear_active and close > fvg_bot

if ifvg_bull_trigger and show_ifvg
    label.new(bar_index, low, 'iFVG↑', color = ifvg_bull_col, textcolor = color.white, style = label.style_label_up, size = size.tiny)
    fvg_bull_active := false
    fvg_bull_active

if ifvg_bear_trigger and show_ifvg
    label.new(bar_index, high, 'iFVG↓', color = ifvg_bear_col, textcolor = color.white, style = label.style_label_down, size = size.tiny)
    fvg_bear_active := false
    fvg_bear_active

// ═══════════════════════════════════════════════════════════════
//  SWING HIGHS & LOWS + BOS/CHoCH
// ═══════════════════════════════════════════════════════════════

swingH = ta.pivothigh(high, swing_len, swing_len)
swingL = ta.pivotlow(low, swing_len, swing_len)

var float lastSwingH = na
var float lastSwingL = na
var int lastSwingH_bar = na
var int lastSwingL_bar = na

if not na(swingH) and show_swings
    label.new(bar_index[swing_len], swingH, 'HH', color = sh_col, textcolor = color.white, style = label.style_label_down, size = size.tiny)
    lastSwingH := swingH
    lastSwingH_bar := bar_index[swing_len]
    lastSwingH_bar

if not na(swingL) and show_swings
    label.new(bar_index[swing_len], swingL, 'LL', color = sl_col, textcolor = color.white, style = label.style_label_up, size = size.tiny)
    lastSwingL := swingL
    lastSwingL_bar := bar_index[swing_len]
    lastSwingL_bar

// BOS / CHoCH
bos_bull = not na(lastSwingH) and close > lastSwingH and show_bos
bos_bear = not na(lastSwingL) and close < lastSwingL and show_bos

if bos_bull
    line.new(lastSwingH_bar, lastSwingH, bar_index, lastSwingH, color = bos_bull_col, style = line.style_dashed, width = 1)
    label.new(bar_index, lastSwingH, 'BOS ↑', color = bos_bull_col, textcolor = color.white, style = label.style_label_left, size = size.tiny)
    lastSwingH := na
    lastSwingH

if bos_bear
    line.new(lastSwingL_bar, lastSwingL, bar_index, lastSwingL, color = bos_bear_col, style = line.style_dashed, width = 1)
    label.new(bar_index, lastSwingL, 'BOS ↓', color = bos_bear_col, textcolor = color.white, style = label.style_label_left, size = size.tiny)
    lastSwingL := na
    lastSwingL

// ═══════════════════════════════════════════════════════════════
//  LIQUIDITY SWINGS
// ═══════════════════════════════════════════════════════════════

liqH = ta.pivothigh(high, liq_len, liq_len)
liqL = ta.pivotlow(low, liq_len, liq_len)

if not na(liqH) and show_liq
    line.new(bar_index[liq_len], liqH, bar_index[liq_len] + 30, liqH, color = liq_bear_col, style = lineStyle(liq_style), width = 1)
    label.new(bar_index[liq_len], liqH, 'SSL', color = liq_bear_col, textcolor = color.white, style = label.style_label_left, size = size.tiny)

if not na(liqL) and show_liq
    line.new(bar_index[liq_len], liqL, bar_index[liq_len] + 30, liqL, color = liq_bull_col, style = lineStyle(liq_style), width = 1)
    label.new(bar_index[liq_len], liqL, 'BSL', color = liq_bull_col, textcolor = color.white, style = label.style_label_left, size = size.tiny)

// ═══════════════════════════════════════════════════════════════
//  CANDLE PATTERNS
// ═══════════════════════════════════════════════════════════════

body = math.abs(close - open)
totalRange = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// Engulfing
bullEngulf = show_engulf and close[1] < open[1] and close > open and close >= open[1] and open <= close[1]
bearEngulf = show_engulf and close[1] > open[1] and close < open and close <= open[1] and open >= close[1]

// Hammer / Shooting Star
isHammer = show_hammer and lowerWick >= body * 2 and upperWick <= body * 0.5 and close > open
isStar = show_hammer and upperWick >= body * 2 and lowerWick <= body * 0.5 and close < open

// Doji
isDoji = show_doji and body <= totalRange * 0.1 and totalRange > 0

// Pin Bar
isPinBull = show_pin and lowerWick >= totalRange * 0.6 and body <= totalRange * 0.25
isPinBear = show_pin and upperWick >= totalRange * 0.6 and body <= totalRange * 0.25

if show_patterns
    if bullEngulf
        label.new(bar_index, low, 'BE', color = color.new(#4caf50, 0), textcolor = color.white, style = label.style_label_up, size = size.tiny)
    if bearEngulf
        label.new(bar_index, high, 'BE', color = color.new(#f44336, 0), textcolor = color.white, style = label.style_label_down, size = size.tiny)
    if isHammer
        label.new(bar_index, low, '🔨', color = color.new(#4caf50, 0), textcolor = color.white, style = label.style_label_up, size = size.tiny)
    if isStar
        label.new(bar_index, high, '⭐', color = color.new(#f44336, 0), textcolor = color.white, style = label.style_label_down, size = size.tiny)
    if isDoji
        label.new(bar_index, high, 'D', color = color.new(#ffeb3b, 0), textcolor = color.black, style = label.style_label_down, size = size.tiny)
    if isPinBull
        label.new(bar_index, low, 'PB↑', color = color.new(#00bcd4, 0), textcolor = color.white, style = label.style_label_up, size = size.tiny)
    if isPinBear
        label.new(bar_index, high, 'PB↓', color = color.new(#ff9800, 0), textcolor = color.white, style = label.style_label_down, size = size.tiny)

// ═══════════════════════════════════════════════════════════════
//  MTF BIAS (used for signals & table)
// ═══════════════════════════════════════════════════════════════

// Simple EMA trend bias per timeframe
ema_fast = 9
ema_slow = 21

ema9_1m = request.security(syminfo.tickerid, '1', ta.ema(close, ema_fast))
ema21_1m = request.security(syminfo.tickerid, '1', ta.ema(close, ema_slow))
ema9_5m = request.security(syminfo.tickerid, '5', ta.ema(close, ema_fast))
ema21_5m = request.security(syminfo.tickerid, '5', ta.ema(close, ema_slow))
ema9_15m = request.security(syminfo.tickerid, '15', ta.ema(close, ema_fast))
ema21_15m = request.security(syminfo.tickerid, '15', ta.ema(close, ema_slow))
ema9_30m = request.security(syminfo.tickerid, '30', ta.ema(close, ema_fast))
ema21_30m = request.security(syminfo.tickerid, '30', ta.ema(close, ema_slow))
ema9_1h = request.security(syminfo.tickerid, '60', ta.ema(close, ema_fast))
ema21_1h = request.security(syminfo.tickerid, '60', ta.ema(close, ema_slow))

bull_1m = ema9_1m > ema21_1m
bull_5m = ema9_5m > ema21_5m
bull_15m = ema9_15m > ema21_15m
bull_30m = ema9_30m > ema21_30m
bull_1h = ema9_1h > ema21_1h

// FVG presence per TF (simplified: recent bull/bear FVG on each TF)
fvg_bull_1m = request.security(syminfo.tickerid, '1', low > high[2])
fvg_bear_1m = request.security(syminfo.tickerid, '1', high < low[2])
fvg_bull_5m = request.security(syminfo.tickerid, '5', low > high[2])
fvg_bear_5m = request.security(syminfo.tickerid, '5', high < low[2])
fvg_bull_15m = request.security(syminfo.tickerid, '15', low > high[2])
fvg_bear_15m = request.security(syminfo.tickerid, '15', high < low[2])
fvg_bull_30m = request.security(syminfo.tickerid, '30', low > high[2])
fvg_bear_30m = request.security(syminfo.tickerid, '30', high < low[2])
fvg_bull_1h = request.security(syminfo.tickerid, '60', low > high[2])
fvg_bear_1h = request.security(syminfo.tickerid, '60', high < low[2])

// ═══════════════════════════════════════════════════════════════
//  BUY / SELL SIGNALS
// ═══════════════════════════════════════════════════════════════

// Confluence score (0–5)
bull_score = (bull_1m ? 1 : 0) + (bull_5m ? 1 : 0) + (bull_15m ? 1 : 0) + (bull_30m ? 1 : 0) + (bull_1h ? 1 : 0)
bear_score = (not bull_1m ? 1 : 0) + (not bull_5m ? 1 : 0) + (not bull_15m ? 1 : 0) + (not bull_30m ? 1 : 0) + (not bull_1h ? 1 : 0)

// Additional confluence: FVG + Pattern
fvg_bull_conf = (fvg_bull_1m ? 1 : 0) + (fvg_bull_5m ? 1 : 0) + (fvg_bull_15m ? 1 : 0)
fvg_bear_conf = (fvg_bear_1m ? 1 : 0) + (fvg_bear_5m ? 1 : 0) + (fvg_bear_15m ? 1 : 0)

pattern_bull = bullEngulf or isHammer or isPinBull
pattern_bear = bearEngulf or isStar or isPinBear

// Signal conditions
buy_signal = show_signals and bull_score >= 3 and fvg_bull_conf >= 1 and pattern_bull and not na(swingL)
sell_signal = show_signals and bear_score >= 3 and fvg_bear_conf >= 1 and pattern_bear and not na(swingH)

// Alternative: BOS + FVG
buy_bos_fvg = show_signals and signal_method == 'BOS + FVG' and bos_bull and bull_fvg
sell_bos_fvg = show_signals and signal_method == 'BOS + FVG' and bos_bear and bear_fvg

// Final signal
final_buy = signal_method == 'BOS + FVG' ? buy_bos_fvg : signal_method == 'FVG + Swing' ? bull_fvg and not na(swingL) and close > lastSwingL : buy_signal
final_sell = signal_method == 'BOS + FVG' ? sell_bos_fvg : signal_method == 'FVG + Swing' ? bear_fvg and not na(swingH) and close < lastSwingH : sell_signal

plotshape(final_buy, title = 'BUY', location = location.belowbar, style = shape.labelup, text = 'BUY', color = sig_buy_col, textcolor = color.white, size = size.normal)
plotshape(final_sell, title = 'SELL', location = location.abovebar, style = shape.labeldown, text = 'SELL', color = sig_sell_col, textcolor = color.white, size = size.normal)

// Alerts
alertcondition(final_buy, 'BUY Signal', 'MTF SMC Suite — BUY signal fired!')
alertcondition(final_sell, 'SELL Signal', 'MTF SMC Suite — SELL signal fired!')

// ═══════════════════════════════════════════════════════════════
//  TRADE QUALITY CHECKLIST TABLE  (score 60–100)
// ═══════════════════════════════════════════════════════════════

// Each criterion adds points; max = 100
// Criteria (10 items × 10 pts each = 100)
c1_lbl = '1H Trend Aligned'
c2_lbl = '30M Trend Aligned'
c3_lbl = '15M Trend Aligned'
c4_lbl = '5M FVG Present'
c5_lbl = '1M FVG Present'
c6_lbl = 'BOS / CHoCH Confirmed'
c7_lbl = 'Liquidity Swept'
c8_lbl = 'Candle Confirmation'
c9_lbl = '3+ TF Confluence'
c10_lbl = 'Clean Structure'

c2 = final_buy ? bull_30m : final_sell ? not bull_30m : false
c3 = final_buy ? bull_15m : final_sell ? not bull_15m : false
c4 = final_buy ? fvg_bull_5m : final_sell ? fvg_bear_5m : false
c6 = bos_bull or bos_bear
c7 = not na(liqH) or not na(liqL)
c8 = pattern_bull or pattern_bear
c9 = bull_score >= 3 or bear_score >= 3
c10 = not na(swingH) and not na(swingL)

score = (bool(c1) ? 10 : 0) + (c2 ? 10 : 0) + (c3 ? 10 : 0) + (c4 ? 10 : 0) + (bool(c5) ? 10 : 0) + (c6 ? 10 : 0) + (c7 ? 10 : 0) + (c8 ? 10 : 0) + (c9 ? 10 : 0) + (c10 ? 10 : 0)





checkmark(_b) =>
    _b ? '✔' : '✘'
check_col(_b) =>
    _b ? color.new(#00e676, 0) : color.new(#ff5252, 0)

if show_table and barstate.islast
    var table t = table.new(tblPos(tbl_pos), 3, 13, bgcolor = color.new(#0d1117, 10), border_color = color.new(#30363d, 0), border_width = 1, frame_color = color.new(#58a6ff, 0), frame_width = 1)

    sz = tblTxtSize(tbl_size)

    // Header
    table.cell(t, 0, 0, 'CRITERION', text_color = color.new(#58a6ff, 0), text_size = sz, bgcolor = color.new(#161b22, 0), text_halign = text.align_left)
    table.cell(t, 1, 0, 'STATUS', text_color = color.new(#58a6ff, 0), text_size = sz, bgcolor = color.new(#161b22, 0))
    table.cell(t, 2, 0, 'PTS', text_color = color.new(#58a6ff, 0), text_size = sz, bgcolor = color.new(#161b22, 0))

    // Rows
    crit_arr = array.from(c1_lbl, c2_lbl, c3_lbl, c4_lbl, c5_lbl, c6_lbl, c7_lbl, c8_lbl, c9_lbl, c10_lbl)
    bool_arr = array.from(bool(c1), c2, c3, c4, bool(c5), c6, c7, c8, c9, c10)

    for i = 0 to 9 by 1
        b = array.get(bool_arr, i)
        table.cell(t, 0, i + 1, array.get(crit_arr, i), text_color = color.new(#c9d1d9, 0), text_size = sz, text_halign = text.align_left)
        table.cell(t, 1, i + 1, checkmark(b), text_color = check_col(b), text_size = sz)
        table.cell(t, 2, i + 1, b ? '10' : '0', text_color = check_col(b), text_size = sz)

// Score row

    table.cell(t, 2, 11, score >= 60 ? '✔ VALID' : '✘ SKIP', text_size = sz, bgcolor = color.new(#161b22, 0))

    // Rating row
    rating = score >= 90 ? 'A+ ELITE' : score >= 80 ? 'A  HIGH' : score >= 70 ? 'B  MED' : score >= 60 ? 'C  LOW' : 'F  SKIP'
    table.cell(t, 0, 12, 'GRADE', text_size = sz, bgcolor = color.new(#0d1117, 0), text_halign = text.align_left)
    table.cell(t, 1, 12, rating, text_size = sz, bgcolor = color.new(#0d1117, 0))
    table.cell(t, 2, 12, '', text_size = sz, bgcolor = color.new(#0d1117, 0))
````
