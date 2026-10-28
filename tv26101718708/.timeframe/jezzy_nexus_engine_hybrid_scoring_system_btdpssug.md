# Jezzy Nexus Engine | Hybrid Scoring System

- url: https://www.tradingview.com/script/bTDpsSUG-Jezzy-Nexus-Engine-Hybrid-Scoring-System/
- type: indicator
- pine_id: PUB;fa62f566240f45c48736079b2d4da007
- version: 1.0

## Description

NEXUS ENGINE by Jezzy

OVERVIEW

Nexus Engine is a confluence scoring tool. It checks seven independent conditions on every bar, adds them up into a bull score and a bear score from 0 to 7, and prints a signal only when the score is high enough and a set of hard filters agrees. The score is shown on every signal label and in a live table, so you always see why a signal appeared and which conditions were missing.


WHY THESE COMPONENTS TOGETHER

Each component answers a different question, and no single one is enough on its own:
- Trend direction: EMA structure, 4H trend, Linear Regression Channel
- Momentum: MACD, triple Parabolic SAR
- Price imbalance: Fair Value Gaps and Inverse Fair Value Gaps
- Timing: wick rejection candle
- Market conditions: session, ADX, RSI, volume

Trend and momentum tools tell you which side to be on but not when. Imbalance zones and rejection candles give timing but fail against the trend. The score combines them so that a signal needs agreement across categories, not a single trigger.


THE SCORE (0 TO 7)

One point each, calculated separately for bulls and bears:

1. MACD: histogram and MACD line on the same side of the signal line.
2. SAR: at least two of three Parabolic SARs (slow, moderate, fast) on the trend side of price.
3. EMA: the last N closes are all beyond the fast EMA, and the fast EMA is on the correct side of the slow EMA.
4. 4H trend: fast EMA vs slow EMA on the 4-hour chart. Applied on chart timeframes of 1 hour and below; counted automatically on higher timeframes.
5. CISD + FVG: a Fair Value Gap of at least a minimum ATR size, with the close beyond the prior swing extreme.
6. IFVG: price has touched an Inverse Fair Value Gap (a gap that was closed through and flipped) within the last five bars.
7. LRC: price on the correct side of the Linear Regression line, and the line sloping in the signal direction.


HARD FILTERS

These are not part of the score. If any one fails, there is no signal at all:
- Session: London or New York hours (UTC, adjustable). Ignored on the daily chart.
- ADX at or above the minimum (default 20), so ranging markets are skipped.
- RSI not overbought for buys, not oversold for sells.
- Volume at or above its moving average times the multiplier.
- No opposing engulfing candle in the recent lookback.


SIGNALS

- Strong (▲ BUY / ▼ SELL): wick rejection candle and a score of 6 or 7.
- Normal (▲ buy / ▼ sell): wick rejection or CISD + FVG, and a score of 4 or more.
- EMA Touch

## Source Code

````pine
//@version=6
indicator("Jezzy Nexus Engine | Hybrid Scoring System", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════
// SETTINGS
// ═══════════════════════════════════════════════════════════════

// MACD
macd_fast   = input.int(12, "Fast",   minval=1, group="MACD")
macd_slow   = input.int(26, "Slow",   minval=1, group="MACD")
macd_signal = input.int(9,  "Signal", minval=1, group="MACD")

// EMA
ema_fast_len   = input.int(20,  "EMA Fast",             minval=1,           group="EMA")
ema_slow_len   = input.int(50,  "EMA Slow",             minval=1,           group="EMA")
ema_confirm    = input.int(3,   "Confirm Candle Count", minval=1, maxval=20, group="EMA")
show_ema       = input.bool(true, "Show EMA Lines",                         group="EMA")
show_ema_touch = input.bool(true, "Show EMA Touch Signal",                  group="EMA")
ema200_len     = input.int(200, "EMA 200", minval=1,                        group="EMA")

// SAR
show_sar     = input.bool(true,  "Show SAR Lines",   group="SAR")
show_sar_avg = input.bool(true,  "Show SAR Average", group="SAR")
sar_slow_s   = input.float(0.01, "Slow Start",       group="SAR")
sar_slow_i   = input.float(0.01, "Slow Inc",         group="SAR")
sar_mod_s    = input.float(0.02, "Moderate Start",   group="SAR")
sar_mod_i    = input.float(0.02, "Moderate Inc",     group="SAR")
sar_fast_s   = input.float(0.03, "Fast Start",       group="SAR")
sar_fast_i   = input.float(0.03, "Fast Inc",         group="SAR")
sar_max_val  = input.float(0.2,  "SAR Max",          group="SAR")

// LRC
show_lrc     = input.bool(true, "Show LRC Lines",      group="LRC")
show_lrc_lbl = input.bool(true, "Show LRC Cross Label",group="LRC")
lrc_len_high = input.int(300,   "Length - High", minval=10, group="LRC")
lrc_len_low  = input.int(300,   "Length - Low",  minval=10, group="LRC")

// RSI
use_rsi     = input.bool(true, "RSI Filter Active",     group="RSI")
rsi_len     = input.int(14,    "RSI Length", minval=2,   group="RSI")
rsi_ob      = input.int(70,    "Overbought", minval=50, maxval=90, group="RSI")
rsi_os      = input.int(30,    "Oversold",   minval=10, maxval=50, group="RSI")

// ADX
use_adx     = input.bool(true, "ADX Filter Active",          group="ADX")
adx_len     = input.int(14,    "ADX Length", minval=2,        group="ADX")
adx_min     = input.int(20,    "Min ADX (trend threshold)",   group="ADX")

// CANDLE
wick_mult    = input.float(3.0, "Wick/Body Ratio",            minval=1.0, maxval=10.0, step=0.5,  group="Candle")
min_body     = input.float(0.1, "Min Body (ATR x)",           minval=0.0, maxval=1.0,  step=0.05, group="Candle")
eng_lookback = input.int(5,     "Engulfing Lookback",         minval=1,   maxval=20,              group="Candle")
eng_atr_mult = input.float(1.0, "Min Engulfing Body (ATR x)", minval=0.1, maxval=5.0,  step=0.1,  group="Candle")

// CISD + FVG
swLen    = input.int(6,     "CISD Swing Length",     minval=2,   maxval=20,              group="CISD+FVG")
atrMulti = input.float(0.2, "Min FVG (ATR x)",       minval=0.0, maxval=3.0, step=0.05, group="CISD+FVG")
volMult  = input.float(1.0, "Min Volume Multiplier",  minval=0.1, maxval=5.0, step=0.1,  group="CISD+FVG")
volLen   = input.int(20,    "Volume MA Period",        minval=5,   maxval=100,            group="CISD+FVG")
show_fvg = input.bool(true, "Show FVG Boxes",                                            group="CISD+FVG")

// SIGNALS
show_labels    = input.bool(true, "Show Signal Labels",    group="Signals")
show_table     = input.bool(true, "Show Info Table",       group="Signals")
show_detail    = input.bool(true, "Show Filter Detail in Table", group="Signals")
sig_cooldown   = input.int(3,     "Signal Cooldown (bars)", minval=0, maxval=20, group="Signals")

// SESSION
ldn_show    = input.bool(true, "London Active",  group="Session")
ldn_open_h  = input.int(7,  "LDN Open (UTC)",    minval=0, maxval=23, group="Session")
ldn_close_h = input.int(16, "LDN Close (UTC)",   minval=0, maxval=23, group="Session")
ny_show     = input.bool(true, "NY Active",      group="Session")
ny_open_h   = input.int(13, "NY Open (UTC)",     minval=0, maxval=23, group="Session")
ny_close_h  = input.int(22, "NY Close (UTC)",    minval=0, maxval=23, group="Session")

// ═══════════════════════════════════════════════════════════════
// BASE CALCULATIONS
// ═══════════════════════════════════════════════════════════════
atr14  = ta.atr(14)
ema20  = ta.ema(close, ema_fast_len)
ema50  = ta.ema(close, ema_slow_len)
ema200 = ta.ema(close, ema200_len)
volAvg = ta.sma(volume, volLen)

[macd_line, sig_line, hist] = ta.macd(close, macd_fast, macd_slow, macd_signal)

tfMinutes = timeframe.in_seconds() / 60
is_1d     = timeframe.period == "1D"

// 4H trend filter
h4_ema20 = request.security(syminfo.tickerid, "240", ta.ema(close, ema_fast_len))
h4_ema50 = request.security(syminfo.tickerid, "240", ta.ema(close, ema_slow_len))
h4_bull  = tfMinutes <= 60 ? h4_ema20 > h4_ema50 : true
h4_bear  = tfMinutes <= 60 ? h4_ema20 < h4_ema50 : true

// ═══════════════════════════════════════════════════════════════
// RSI
// ═══════════════════════════════════════════════════════════════
rsi_val  = ta.rsi(close, rsi_len)
rsi_bull = not use_rsi or rsi_val < rsi_ob   // not overbought for buy
rsi_bear = not use_rsi or rsi_val > rsi_os   // not oversold for sell

// ═══════════════════════════════════════════════════════════════
// ADX
// ═══════════════════════════════════════════════════════════════
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_len)
adx_ok = not use_adx or adx_val >= adx_min   // trending market

// ═══════════════════════════════════════════════════════════════
// SAR
// ═══════════════════════════════════════════════════════════════
sarSlow = ta.sar(sar_slow_s, sar_slow_i, sar_max_val)
sarMod  = ta.sar(sar_mod_s,  sar_mod_i,  sar_max_val)
sarFast = ta.sar(sar_fast_s, sar_fast_i, sar_max_val)
sarAvg  = math.avg(sarSlow, sarMod, sarFast)

sar_bull = (sarSlow < close ? 1 : 0) + (sarMod < close ? 1 : 0) + (sarFast < close ? 1 : 0) >= 2
sar_bear = (sarSlow > close ? 1 : 0) + (sarMod > close ? 1 : 0) + (sarFast > close ? 1 : 0) >= 2

// ═══════════════════════════════════════════════════════════════
// LRC
// ═══════════════════════════════════════════════════════════════
lrcHigh = ta.linreg(high, lrc_len_high, 0)
lrcLow  = ta.linreg(low,  lrc_len_low,  0)

lrc_bull = close > lrcLow  and lrcLow  > lrcLow[1]
lrc_bear = close < lrcHigh and lrcHigh < lrcHigh[1]

lrc_cross_up   = ta.crossover(lrcHigh, lrcLow)
lrc_cross_down = ta.crossunder(lrcHigh, lrcLow)

// ═══════════════════════════════════════════════════════════════
// SESSION
// ═══════════════════════════════════════════════════════════════
bar_mins   = hour(time, "UTC") * 60 + minute(time, "UTC")
in_ldn     = bar_mins >= ldn_open_h * 60 and bar_mins < ldn_close_h * 60
in_ny      = bar_mins >= ny_open_h  * 60 and bar_mins < ny_close_h  * 60
in_session = is_1d ? true : (ldn_show and in_ldn) or (ny_show and in_ny)

session_tag() =>
    in_ldn and in_ny ? " LDN+NY" : in_ldn ? " LDN" : in_ny ? " NY" : ""

// ═══════════════════════════════════════════════════════════════
// EMA CONDITIONS
// ═══════════════════════════════════════════════════════════════
ema_bull_break = true
ema_bear_break = true
for i = 0 to ema_confirm - 1
    if close[i] <= ema20[i]
        ema_bull_break := false
    if close[i] >= ema20[i]
        ema_bear_break := false

ema_buy_cond  = ema_bull_break and ema20 > ema50
ema_sell_cond = ema_bear_break and ema20 < ema50

// ═══════════════════════════════════════════════════════════════
// MACD
// ═══════════════════════════════════════════════════════════════
macd_bull = hist > 0 and macd_line > sig_line
macd_bear = hist < 0 and macd_line < sig_line

// ═══════════════════════════════════════════════════════════════
// CANDLE: WICK REJECTION + ENGULFING
// ═══════════════════════════════════════════════════════════════
body       = math.abs(close - open)
upper_wick = high - math.max(close, open)
lower_wick = math.min(close, open) - low
min_bv     = atr14 * min_body

upper_rej = upper_wick >= body * wick_mult and body >= min_bv and upper_wick >= atr14 * 0.2
lower_rej = lower_wick >= body * wick_mult and body >= min_bv and lower_wick >= atr14 * 0.2

isBullEng(i) =>
    body_c = close[i] - open[i]
    close[i] > open[i] and close[i+1] < open[i+1] and close[i] > open[i+1] and open[i] < close[i+1] and body_c >= atr14 * eng_atr_mult

isBearEng(i) =>
    body_c = open[i] - close[i]
    close[i] < open[i] and close[i+1] > open[i+1] and close[i] < open[i+1] and open[i] > close[i+1] and body_c >= atr14 * eng_atr_mult

bull_eng = false
bear_eng = false
if not is_1d
    for i = 0 to eng_lookback - 1
        if isBullEng(i)
            bull_eng := true
        if isBearEng(i)
            bear_eng := true

no_bull_eng = is_1d ? true : not bull_eng
no_bear_eng = is_1d ? true : not bear_eng

// ═══════════════════════════════════════════════════════════════
// CISD + FVG + IFVG
// ═══════════════════════════════════════════════════════════════
prevSwHigh = ta.highest(high, swLen)[1]
prevSwLow  = ta.lowest(low,   swLen)[1]

bearCISD = close < prevSwHigh
bullCISD = close > prevSwLow

bearFVGtop  = low[2]
bearFVGbot  = high
bearFVGsize = bearFVGtop - bearFVGbot
bearFVGok   = bearFVGsize >= atr14 * atrMulti

bullFVGtop  = low
bullFVGbot  = high[2]
bullFVGsize = bullFVGtop - bullFVGbot
bullFVGok   = bullFVGsize >= atr14 * atrMulti

type FVG
    float top
    float bot
    float mid

var array<FVG> bullFvgAry  = array.new<FVG>()
var array<FVG> bearFvgAry  = array.new<FVG>()
var array<FVG> bullIfvgAry = array.new<FVG>()
var array<FVG> bearIfvgAry = array.new<FVG>()

if bullFVGok and bullCISD
    array.push(bullFvgAry, FVG.new(bullFVGtop, bullFVGbot, math.avg(bullFVGtop, bullFVGbot)))
    if array.size(bullFvgAry) > 20
        array.shift(bullFvgAry)

if bearFVGok and bearCISD
    array.push(bearFvgAry, FVG.new(bearFVGtop, bearFVGbot, math.avg(bearFVGtop, bearFVGbot)))
    if array.size(bearFvgAry) > 20
        array.shift(bearFvgAry)

if array.size(bullFvgAry) > 0
    for i = array.size(bullFvgAry) - 1 to 0
        f = array.get(bullFvgAry, i)
        if close < f.mid
            array.push(bearIfvgAry, array.remove(bullFvgAry, i))
            if array.size(bearIfvgAry) > 10
                array.shift(bearIfvgAry)

if array.size(bearFvgAry) > 0
    for i = array.size(bearFvgAry) - 1 to 0
        f = array.get(bearFvgAry, i)
        if close > f.mid
            array.push(bullIfvgAry, array.remove(bearFvgAry, i))
            if array.size(bullIfvgAry) > 10
                array.shift(bullIfvgAry)

hasIfvgBear = false
hasIfvgBull = false

if array.size(bearIfvgAry) > 0
    for i = array.size(bearIfvgAry) - 1 to 0
        f = array.get(bearIfvgAry, i)
        if close > f.top
            array.remove(bearIfvgAry, i)
        else
            for k = 0 to 4
                if high[k] >= f.bot and low[k] <= f.top
                    hasIfvgBear := true

if array.size(bullIfvgAry) > 0
    for i = array.size(bullIfvgAry) - 1 to 0
        f = array.get(bullIfvgAry, i)
        if close < f.bot
            array.remove(bullIfvgAry, i)
        else
            for k = 0 to 4
                if low[k] <= f.top and high[k] >= f.bot
                    hasIfvgBull := true

volOk = volume >= volAvg * volMult

// ═══════════════════════════════════════════════════════════════
// SCORE SYSTEM (0-7)
// ═══════════════════════════════════════════════════════════════
calcBullScore() =>
    s = 0
    s += macd_bull                ? 1 : 0
    s += sar_bull                 ? 1 : 0
    s += ema_buy_cond             ? 1 : 0
    s += h4_bull                  ? 1 : 0
    s += (bullCISD and bullFVGok) ? 1 : 0
    s += hasIfvgBull              ? 1 : 0
    s += lrc_bull                 ? 1 : 0
    s

calcBearScore() =>
    s = 0
    s += macd_bear                ? 1 : 0
    s += sar_bear                 ? 1 : 0
    s += ema_sell_cond            ? 1 : 0
    s += h4_bear                  ? 1 : 0
    s += (bearCISD and bearFVGok) ? 1 : 0
    s += hasIfvgBear              ? 1 : 0
    s += lrc_bear                 ? 1 : 0
    s

bullScore = calcBullScore()
bearScore = calcBearScore()

// ═══════════════════════════════════════════════════════════════
// FINAL SIGNALS
// ═══════════════════════════════════════════════════════════════
// ADX + RSI are hard gates (not in score, block signal entirely)
bullStrong = in_session and adx_ok and rsi_bull and lower_rej and bullScore >= 6 and no_bear_eng and volOk
bearStrong = in_session and adx_ok and rsi_bear and upper_rej and bearScore >= 6 and no_bull_eng and volOk

bullNormal = in_session and adx_ok and rsi_bull and (lower_rej or (bullCISD and bullFVGok)) and bullScore >= 4 and no_bear_eng and volOk and not bullStrong
bearNormal = in_session and adx_ok and rsi_bear and (upper_rej or (bearCISD and bearFVGok)) and bearScore >= 4 and no_bull_eng and volOk and not bearStrong

ema_touch_buy  = ema20 > ema50 and low[1] <= ema20[1] and close[1] > ema20[1] and close > open and in_session
ema_touch_sell = ema20 < ema50 and high[1] >= ema20[1] and close[1] < ema20[1] and close < open and in_session

// Cooldown — suppress repeat signals within N bars
var int last_bull_bar = na
var int last_bear_bar = na
bull_cd_ok = na(last_bull_bar) or (bar_index - last_bull_bar) >= sig_cooldown
bear_cd_ok = na(last_bear_bar) or (bar_index - last_bear_bar) >= sig_cooldown

bullFire = (bullStrong or bullNormal) and bull_cd_ok
bearFire = (bearStrong or bearNormal) and bear_cd_ok

if bullFire
    last_bull_bar := bar_index
if bearFire
    last_bear_bar := bar_index

// ═══════════════════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════════════════

// EMA
plot(show_ema ? ema20  : na, "EMA 20",  color=color.new(#00BCD4, 0),  linewidth=1)
plot(show_ema ? ema50  : na, "EMA 50",  color=color.new(#FF9800, 0),  linewidth=1)
plot(show_ema ? ema200 : na, "EMA 200", color=color.new(#FF5722, 40), linewidth=2)

// SAR
plot(show_sar     ? sarSlow : na, "SAR Slow",     color=color.new(color.maroon, 40), style=plot.style_cross, linewidth=1)
plot(show_sar     ? sarMod  : na, "SAR Moderate", color=color.new(color.green,  40), style=plot.style_cross, linewidth=1)
plot(show_sar     ? sarFast : na, "SAR Fast",     color=color.new(color.red,    40), style=plot.style_cross, linewidth=1)
plot(show_sar_avg ? sarAvg  : na, "SAR Average",  color=color.new(color.orange,  0), style=plot.style_cross, linewidth=1)

// LRC
plot(show_lrc ? lrcHigh : na, "LRC High", color=color.new(#2196F3, 0), linewidth=1)
plot(show_lrc ? lrcLow  : na, "LRC Low",  color=color.new(#ef5350, 0), linewidth=1)

if show_lrc and show_lrc_lbl and lrc_cross_up
    label.new(bar_index, low * 0.999, "✕ LRC", color=color.new(color.orange, 60), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if show_lrc and show_lrc_lbl and lrc_cross_down
    label.new(bar_index, low * 0.999, "✕ LRC", color=color.new(color.green,  60), textcolor=color.white, style=label.style_label_up, size=size.tiny)

// FVG boxes
if show_fvg and bearFire and bearFVGok
    box.new(bar_index - 2, bearFVGtop, bar_index + 15, bearFVGbot, bgcolor=color.new(#ef5350, bearStrong ? 80 : 90), border_color=color.new(#ef5350, 40), border_width=1, border_style=line.style_dashed)
if show_fvg and bullFire and bullFVGok
    box.new(bar_index - 2, bullFVGtop, bar_index + 15, bullFVGbot, bgcolor=color.new(#26a69a, bullStrong ? 80 : 90), border_color=color.new(#26a69a, 40), border_width=1, border_style=line.style_dashed)

// Signal labels
bullTag = bullStrong ? "▲ BUY" : "▲ buy"
bearTag = bearStrong ? "▼ SELL" : "▼ sell"

bullLblTxt = bullTag + " [" + str.tostring(bullScore) + "/7]" + session_tag()
bearLblTxt = bearTag + " [" + str.tostring(bearScore) + "/7]" + session_tag()

var label last_buy_lbl  = na
var label last_sell_lbl = na
var int   last_buy_bar2 = na
var int   last_sell_bar2 = na

if show_labels and bullFire
    last_buy_bar2 := bar_index
    last_buy_lbl  := label.new(bar_index, low - atr14 * 0.5, bullLblTxt,
         color=color.new(#00E676, bullStrong ? 70 : 85), textcolor=color.new(#00E676, 0),
         style=label.style_label_up, size=size.tiny)

if show_labels and bearFire
    last_sell_bar2 := bar_index
    last_sell_lbl  := label.new(bar_index, high + atr14 * 0.5, bearLblTxt,
         color=color.new(#FF1744, bearStrong ? 70 : 85), textcolor=color.new(#FF1744, 0),
         style=label.style_label_down, size=size.tiny)

// Next candle wick check
if not na(last_buy_bar2) and bar_index == last_buy_bar2 + 1
    if low < low[1]
        label.delete(last_buy_lbl)
if not na(last_sell_bar2) and bar_index == last_sell_bar2 + 1
    if high > high[1]
        label.delete(last_sell_lbl)

// EMA Touch labels
if show_ema_touch and ema_touch_buy
    label.new(bar_index, low - atr14 * 0.8, "▲ BUY? EMA Touch", color=color.new(#00BCD4, 85), textcolor=color.new(#00BCD4, 0), style=label.style_label_up, size=size.tiny)
if show_ema_touch and ema_touch_sell
    label.new(bar_index, high + atr14 * 0.8, "▼ SELL? EMA Touch", color=color.new(#FF9800, 85), textcolor=color.new(#FF9800, 0), style=label.style_label_down, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// INFO TABLE
// ═══════════════════════════════════════════════════════════════
chk(v) => v ? "✓" : "✗"
chkCol(v) => v ? color.lime : color.new(color.red, 20)

var table tbl = table.new(position.top_right, 2, 12, bgcolor=color.new(color.black, 80), border_width=1)
if show_table and barstate.islast
    // Header
    table.cell(tbl, 0, 0, "TF",      text_color=color.gray,  text_size=size.small)
    table.cell(tbl, 1, 0, timeframe.period, text_color=color.white, text_size=size.small)
    // Scores
    table.cell(tbl, 0, 1, "Bull",    text_color=color.gray,  text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(bullScore) + "/7", text_color=bullScore >= 6 ? color.lime : bullScore >= 4 ? color.yellow : color.gray, text_size=size.small)
    table.cell(tbl, 0, 2, "Bear",    text_color=color.gray,  text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(bearScore) + "/7", text_color=bearScore >= 6 ? color.red  : bearScore >= 4 ? color.orange : color.gray, text_size=size.small)
    // ADX / RSI
    table.cell(tbl, 0, 3, "ADX",     text_color=color.gray,  text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(adx_val, 1)), text_color=adx_ok ? color.lime : color.red, text_size=size.small)
    table.cell(tbl, 0, 4, "RSI",     text_color=color.gray,  text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(math.round(rsi_val, 1)), text_color=rsi_val > rsi_ob ? color.red : rsi_val < rsi_os ? color.lime : color.yellow, text_size=size.small)
    // Filter detail (only when show_detail is on)
    if show_detail
        table.cell(tbl, 0,  5, "MACD",      text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1,  5, chk(macd_bull) + " / " + chk(macd_bear), text_color=color.silver, text_size=size.tiny)
        table.cell(tbl, 0,  6, "SAR",       text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1,  6, chk(sar_bull) + " / " + chk(sar_bear),   text_color=color.silver, text_size=size.tiny)
        table.cell(tbl, 0,  7, "EMA",       text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1,  7, chk(ema_buy_cond) + " / " + chk(ema_sell_cond), text_color=color.silver, text_size=size.tiny)
        table.cell(tbl, 0,  8, "H4",        text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1,  8, chk(h4_bull) + " / " + chk(h4_bear),     text_color=color.silver, text_size=size.tiny)
        table.cell(tbl, 0,  9, "CISD+FVG",  text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1,  9, chk(bullCISD and bullFVGok) + " / " + chk(bearCISD and bearFVGok), text_color=color.silver, text_size=size.tiny)
        table.cell(tbl, 0, 10, "IFVG",      text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1, 10, chk(hasIfvgBull) + " / " + chk(hasIfvgBear), text_color=color.silver, text_size=size.tiny)
        table.cell(tbl, 0, 11, "LRC",       text_color=color.gray, text_size=size.tiny)
        table.cell(tbl, 1, 11, chk(lrc_bull) + " / " + chk(lrc_bear),   text_color=color.silver, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(bullStrong and bull_cd_ok, title="BUY Strong",  message="STRONG BUY [{{interval}}] {{ticker}} | Entry: {{close}}")
alertcondition(bearStrong and bear_cd_ok, title="SELL Strong", message="STRONG SELL [{{interval}}] {{ticker}} | Entry: {{close}}")
alertcondition(bullNormal and bull_cd_ok, title="BUY Normal",  message="BUY [{{interval}}] {{ticker}} | Entry: {{close}}")
alertcondition(bearNormal and bear_cd_ok, title="SELL Normal", message="SELL [{{interval}}] {{ticker}} | Entry: {{close}}")
alertcondition(ema_touch_buy,             title="BUY EMA Touch",   message="BUY? EMA Touch - {{ticker}} {{interval}}")
alertcondition(ema_touch_sell,            title="SELL EMA Touch",  message="SELL? EMA Touch - {{ticker}} {{interval}}")
alertcondition(bullFire,                  title="All BUY",   message="BUY [{{interval}}] {{ticker}} | Entry: {{close}}")
alertcondition(bearFire,                  title="All SELL",  message="SELL [{{interval}}] {{ticker}} | Entry: {{close}}")
````
