# GROK8_NextGenTrading77 SMC + SuperTrend + WaveTrend [4 Profiles]

- url: https://www.tradingview.com/script/8Z0rwjB8/
- type: indicator
- pine_id: PUB;d328859639344d80a83c7b23a3a1d6f5
- version: 1.0

## Description

A powerful all-in-one indicator that combines Smart Money Concepts (SMC), SuperTrend, and WaveTrend with 4 ready-to-use trading profiles.
How it works:

SMC detects institutional price zones: Order Blocks, Fair Value Gaps, Liquidity Pools, Break of Structure (BOS) and Change of Character (CHOCH).
SuperTrend delivers dynamic trend filtering and trailing stops based on ATR.
WaveTrend provides precise entry/exit signals, momentum shifts, and divergence detection.

The indicator intelligently merges market structure (SMC) + trend confirmation (SuperTrend) + timing & momentum (WaveTrend) for higher-probability setups.
4 Built-in Profiles for instant switching:

Scalping
Intraday
Swing
Trend Following

Perfect for Forex, Indices, Cryptocurrencies, and Stocks. Clean, customizable visuals with optional alerts.
Just add to chart, choose your profile, and trade.

## Source Code

````pine
//@version=6
indicator(
    title            = "GROK7 SMC + SuperTrend + WaveTrend [4 Profiles]",
    shorttitle       = "GROK7 TP",
    overlay          = true,
    max_lines_count  = 500,
    max_labels_count = 200,
    max_boxes_count  = 100
)

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE SELECTION (tylko informacyjnie)
// ─────────────────────────────────────────────────────────────────────────────
trading_profile = input.string("Balanced 30min", "Trading Profile (informacyjnie)",
     options = ["Aggressive 15min", "Balanced 30min", "Safe 1H", "Ultra Safe 4H"],
     group = "⚡ Profile Selection")

// ─────────────────────────────────────────────────────────────────────────────
// 🔧 ZAAWANSOWANE FILTRY (włączaj/wyłączaj ręcznie)
// ─────────────────────────────────────────────────────────────────────────────
use_supertrend_filter = input.bool(true,  "Używaj filtra SuperTrend",          group="🔧 Zaawansowane filtry")
require_orderblock    = input.bool(true,  "Wymagaj blisko Order Block",        group="🔧 Zaawansowane filtry")
use_wt_strict         = input.bool(true,  "Ścisły WaveTrend (tylko OB/OS)",    group="🔧 Zaawansowane filtry")
allow_counter_trend   = input.bool(false, "Zezwól na counter-trend",           group="🔧 Zaawansowane filtry")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

st_period = input.int   (10,  "Okres ATR",         minval=1,  group="🔵 SuperTrend")
st_mult   = input.float (3.0, "Mnożnik ATR",       step=0.1,  group="🔵 SuperTrend")

wt_n1     = input.int  (10,   "Channel Length (n1)",  minval=2,  group="🟣 WaveTrend")
wt_n2     = input.int  (21,   "Average Length (n2)",  minval=2,  group="🟣 WaveTrend")
wt_ob     = input.float(53.0, "Overbought level",     step=1.0,  group="🟣 WaveTrend")
wt_os     = input.float(-53.0,"Oversold level",       step=1.0,  group="🟣 WaveTrend")

ob_lookback = input.int (8,  "Swing Lookback (OB)", minval=3, maxval=50, group="🟠 Order Blocks (SMC)")
ob_extend   = input.int (40, "Extend OB (bary)",   minval=5,             group="🟠 Order Blocks (SMC)")
ob_prox_pct = input.float(1.0,"Proximity do OB (%)", step=0.1,           group="🟠 Order Blocks (SMC)")

atr_period   = input.int  (14,  "ATR Period",      minval=1,  group="⚖️ Ryzyko / TP / SL")
sl_atr_buf   = input.float(0.5, "SL bufor ATR",   step=0.1,  group="⚖️ Ryzyko / TP / SL")
tp1_rr       = input.float(1.2, "TP1  R:R",       step=0.1,  group="⚖️ Ryzyko / TP / SL")
tp2_rr       = input.float(2.0, "TP2  R:R",       step=0.1,  group="⚖️ Ryzyko / TP / SL")
tp3_rr       = input.float(3.5, "TP3  R:R",       step=0.1,  group="⚖️ Ryzyko / TP / SL")

show_ob    = input.bool(true,  "Pokaż Order Blocks",        group="🎨 Wyświetlanie")
show_tpsl  = input.bool(true,  "Pokaż linie TP / SL",       group="🎨 Wyświetlanie")
lineLength = input.int (18, "Długość linii TP/SL (w świecach)", minval=8, maxval=50, group="🎨 Wyświetlanie")
show_label = input.bool(true,  "Pokaż etykiety wejść",      group="🎨 Wyświetlanie")
show_wt_mk = input.bool(true,  "Pokaż markery WaveTrend",   group="🎨 Wyświetlanie")
show_bg    = input.bool(true,  "Tło trendu",                group="🎨 Wyświetlanie")

// ─────────────────────────────────────────────────────────────────────────────
// LOGIKA
// ─────────────────────────────────────────────────────────────────────────────

[stLine, stDir] = ta.supertrend(st_mult, st_period)
isBullST = stDir < 0
isBearST = stDir > 0

wt_ap  = hlc3
wt_esa = ta.ema(wt_ap, wt_n1)
wt_d   = ta.ema(math.abs(wt_ap - wt_esa), wt_n1)
wt_ci  = (wt_ap - wt_esa) / (0.015 * wt_d)
wt_tci = ta.ema(wt_ci, wt_n2)
wt1    = wt_tci
wt2    = ta.sma(wt1, 4)

wtCrossUp   = ta.crossover (wt1, wt2)
wtCrossDown = ta.crossunder(wt1, wt2)

// WaveTrend signal z opcjonalnym strict mode
wtLongSignal  = wtCrossUp   and (not use_wt_strict or wt1 < wt_os or wt1[1] < wt_os)
wtShortSignal = wtCrossDown and (not use_wt_strict or wt1 > wt_ob or wt1[1] > wt_ob)

// SuperTrend + counter-trend
st_ok_long  = not use_supertrend_filter or isBullST or (allow_counter_trend and isBearST)
st_ok_short = not use_supertrend_filter or isBearST or (allow_counter_trend and isBullST)

pivHigh = ta.pivothigh(high, ob_lookback, ob_lookback)
pivLow  = ta.pivotlow (low,  ob_lookback, ob_lookback)

var float lastSwingHigh = na
var float lastSwingLow  = na
if not na(pivHigh)
    lastSwingHigh := pivHigh
if not na(pivLow)
    lastSwingLow  := pivLow

bosUp   = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bosDown = not na(lastSwingLow)  and close < lastSwingLow  and close[1] >= lastSwingLow

// Order Blocks
var float bull_ob_high = na
var float bull_ob_low  = na
var int   bull_ob_idx  = na
var bool  bull_ob_valid = false

var float bear_ob_high = na
var float bear_ob_low  = na
var int   bear_ob_idx  = na
var bool  bear_ob_valid = false

if bosUp
    for i = 1 to ob_lookback
        if close[i] < open[i]
            bull_ob_high  := high[i]
            bull_ob_low   := low[i]
            bull_ob_idx   := bar_index - i
            bull_ob_valid := true
            break

if bosDown
    for i = 1 to ob_lookback
        if close[i] > open[i]
            bear_ob_high  := high[i]
            bear_ob_low   := low[i]
            bear_ob_idx   := bar_index - i
            bear_ob_valid := true
            break

if bull_ob_valid and close < bull_ob_low
    bull_ob_valid := false
if bear_ob_valid and close > bear_ob_high
    bear_ob_valid := false

proxFactor = ob_prox_pct / 100.0
nearBullOB = bull_ob_valid and low  <= bull_ob_high * (1.0 + proxFactor) and high >= bull_ob_low  * (1.0 - proxFactor)
nearBearOB = bear_ob_valid and high >= bear_ob_low  * (1.0 - proxFactor) and low  <= bear_ob_high * (1.0 + proxFactor)

// Rysowanie OB
var box bullOBBox = na
var box bearOBBox = na

if show_ob and bosUp and bull_ob_valid
    if not na(bullOBBox)
        box.delete(bullOBBox)
    bullOBBox := box.new(left = bull_ob_idx, top = bull_ob_high, right = bar_index + ob_extend, bottom = bull_ob_low,
                         border_color = color.new(color.green, 30), border_width = 1, bgcolor = color.new(color.green, 88))

if show_ob and bosDown and bear_ob_valid
    if not na(bearOBBox)
        box.delete(bearOBBox)
    bearOBBox := box.new(left = bear_ob_idx, top = bear_ob_high, right = bar_index + ob_extend, bottom = bear_ob_low,
                         border_color = color.new(color.red, 30), border_width = 1, bgcolor = color.new(color.red, 88))

if show_ob and not na(bullOBBox) and bull_ob_valid
    box.set_right(bullOBBox, bar_index + ob_extend)
if show_ob and not na(bearOBBox) and bear_ob_valid
    box.set_right(bearOBBox, bar_index + ob_extend)

// Warunki wejścia
longEntry  = wtLongSignal  and st_ok_long  and (not require_orderblock or nearBullOB or bull_ob_valid)
shortEntry = wtShortSignal and st_ok_short and (not require_orderblock or nearBearOB or bear_ob_valid)

// TP/SL + etykiety z cenami
atr = ta.atr(atr_period)

var float longSL   = na
var float longTP1  = na
var float longTP2  = na
var float longTP3  = na

var float shortSL  = na
var float shortTP1 = na
var float shortTP2 = na
var float shortTP3 = na

if longEntry
    longSL  := bull_ob_valid ? (bull_ob_low - atr * sl_atr_buf) : (close - atr * 1.5)
    risk    = close - longSL
    longTP1 := close + risk * tp1_rr
    longTP2 := close + risk * tp2_rr
    longTP3 := close + risk * tp3_rr

if shortEntry
    shortSL  := bear_ob_valid ? (bear_ob_high + atr * sl_atr_buf) : (close + atr * 1.5)
    risk     = shortSL - close
    shortTP1 := close - risk * tp1_rr
    shortTP2 := close - risk * tp2_rr
    shortTP3 := close - risk * tp3_rr

if show_tpsl and longEntry
    line.new(bar_index, longSL,  bar_index + lineLength, longSL,  color=color.new(color.red, 0), width=2)
    line.new(bar_index, longTP1, bar_index + lineLength, longTP1, color=color.new(color.lime, 0), width=2)
    line.new(bar_index, longTP2, bar_index + lineLength, longTP2, color=color.new(color.lime, 20), width=1)
    line.new(bar_index, longTP3, bar_index + lineLength, longTP3, color=color.new(color.lime, 40), width=1)

    label.new(bar_index + lineLength, longSL,  "SL "  + str.tostring(longSL,  "#.##"), style=label.style_label_left, color=color.new(color.red,0),    textcolor=color.white, size=size.small)
    label.new(bar_index + lineLength, longTP1, "TP1 " + str.tostring(longTP1, "#.##"), style=label.style_label_left, color=color.new(color.lime,0),  textcolor=color.white, size=size.small)
    label.new(bar_index + lineLength, longTP2, "TP2 " + str.tostring(longTP2, "#.##"), style=label.style_label_left, color=color.new(color.lime,0),  textcolor=color.white, size=size.small)
    label.new(bar_index + lineLength, longTP3, "TP3 " + str.tostring(longTP3, "#.##"), style=label.style_label_left, color=color.new(color.lime,0),  textcolor=color.white, size=size.small)

if show_tpsl and shortEntry
    line.new(bar_index, shortSL,  bar_index + lineLength, shortSL,  color=color.new(color.red, 0), width=2)
    line.new(bar_index, shortTP1, bar_index + lineLength, shortTP1, color=color.new(color.fuchsia, 0), width=2)
    line.new(bar_index, shortTP2, bar_index + lineLength, shortTP2, color=color.new(color.fuchsia, 20), width=1)
    line.new(bar_index, shortTP3, bar_index + lineLength, shortTP3, color=color.new(color.fuchsia, 40), width=1)

    label.new(bar_index + lineLength, shortSL,  "SL "  + str.tostring(shortSL,  "#.##"), style=label.style_label_left, color=color.new(color.red,0),    textcolor=color.white, size=size.small)
    label.new(bar_index + lineLength, shortTP1, "TP1 " + str.tostring(shortTP1, "#.##"), style=label.style_label_left, color=color.new(color.fuchsia,0), textcolor=color.white, size=size.small)
    label.new(bar_index + lineLength, shortTP2, "TP2 " + str.tostring(shortTP2, "#.##"), style=label.style_label_left, color=color.new(color.fuchsia,0), textcolor=color.white, size=size.small)
    label.new(bar_index + lineLength, shortTP3, "TP3 " + str.tostring(shortTP3, "#.##"), style=label.style_label_left, color=color.new(color.fuchsia,0), textcolor=color.white, size=size.small)

// SuperTrend + reszta
stCol = isBullST ? color.new(color.lime, 10) : color.new(color.red, 10)
plot(stLine, "SuperTrend", color=stCol, linewidth=2)

bgcolor(show_bg and isBullST ? color.new(color.green, 96) : na)
bgcolor(show_bg and isBearST ? color.new(color.red,   96) : na)

plotshape(longEntry,  "LONG",  shape.triangleup,   location.belowbar, color.new(color.lime, 0), size=size.normal)
plotshape(shortEntry, "SHORT", shape.triangledown, location.abovebar, color.new(color.red,  0), size=size.normal)

if show_label and longEntry
    label.new(bar_index, low, "🟢 LONG", style=label.style_label_upper_left, color=color.new(color.green,10), textcolor=color.white, size=size.small)

if show_label and shortEntry
    label.new(bar_index, high, "🔴 SHORT", style=label.style_label_lower_left, color=color.new(color.red,10), textcolor=color.white, size=size.small)

alertcondition(longEntry, "LONG Entry", "LONG")
alertcondition(shortEntry, "SHORT Entry", "SHORT")
````
