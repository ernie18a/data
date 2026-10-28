# Liquidity Trap PRO System

- url: https://www.tradingview.com/script/eW3M9Cy0-Liquidity-Trap-PRO-System/
- type: indicator
- pine_id: PUB;a8e37514365b4854948f8f159788f01a
- version: 1.0

## Description

Gold exhibits multiple liquidity layers across higher timeframes, particularly the 4-hour and 1-hour structures. The objective is to precisely identify where significant liquidity is resting within these zones.

Once these liquidity areas are mapped, price typically gravitates toward the designated “green zone.” On the 5-minute timeframe, a rejection from this region often provides the optimal entry point.

This should not be taken mechanically—incorporate discretionary judgment through overall market structure, trend context, and price behaviour to refine timing and confirmation before execution.

## Source Code

````pine
//@version=5
indicator("Liquidity Trap PRO System", overlay=true, max_lines_count=500)

// ================= INPUTS =================
tf_main = input.timeframe("240", "4H Liquidity")
tf_1h = input.timeframe("60", "1H Liquidity")
use1H = input.bool(true, "Use 1H Levels")

col_active = input.color(color.green, "Active Liquidity")
col_taken = input.color(color.red, "Taken Liquidity")

width = input.int(3, "Line Width")

// ===== FILTERS =====
useDisplacement = input.bool(true, "Displacement Filter")
atrMult = input.float(1.0, "ATR Multiplier")

useSweepDepth = input.bool(true, "Sweep Depth Filter")
minSweep = input.float(0.5, "Min Sweep (points)")

useTrendFilter = input.bool(false, "Trend Filter (EMA 50)")

useRangeFilter = input.bool(false, "Avoid Low Volatility")

sl_points = input.float(1.0, "Stop Loss Points")

// ================= STORAGE =================
var line[] highs = array.new_line()
var line[] lows = array.new_line()
var float[] high_vals = array.new_float()
var float[] low_vals = array.new_float()
var bool[] high_taken = array.new_bool()
var bool[] low_taken = array.new_bool()

// ================= HTF LEVEL CREATION =================
f_new_level(tf) =>
    h = request.security(syminfo.tickerid, tf, high)
    l = request.security(syminfo.tickerid, tf, low)
    isNew = ta.change(time(tf))

    if isNew
        lh = line.new(bar_index, h, bar_index+1, h,
             extend=extend.right, color=col_active, width=width)
        array.push(highs, lh)
        array.push(high_vals, h)
        array.push(high_taken, false)

        ll = line.new(bar_index, l, bar_index+1, l,
             extend=extend.right, color=col_active, width=width)
        array.push(lows, ll)
        array.push(low_vals, l)
        array.push(low_taken, false)

// ================= LIQUIDITY TRACKING =================
f_check_liquidity() =>
    hiSize = array.size(highs)
    loSize = array.size(lows)

    // ===== HIGH LEVELS =====
    if hiSize > 0
        for i = 0 to hiSize - 1
            if i >= 0
                if not array.get(high_taken, i)
                    lvl = array.get(high_vals, i)
                    ln  = array.get(highs, i)

                    if high >= lvl
                        line.set_color(ln, col_taken)
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        array.set(high_taken, i, true)

    // ===== LOW LEVELS =====
    if loSize > 0
        for i = 0 to loSize - 1
            if i >= 0
                if not array.get(low_taken, i)
                    lvl = array.get(low_vals, i)
                    ln  = array.get(lows, i)

                    if low <= lvl
                        line.set_color(ln, col_taken)
                        line.set_extend(ln, extend.none)
                        line.set_x2(ln, bar_index)
                        array.set(low_taken, i, true)

// ================= 5M LOGIC =================
isBull(c) => close[c] > open[c]
isBear(c) => close[c] < open[c]

// 3 candle retail run
bull_run = isBull(1) and isBull(2) and isBull(3)
bear_run = isBear(1) and isBear(2) and isBear(3)

// ================= SWEEP =================
high4h = request.security(syminfo.tickerid, tf_main, high)
low4h  = request.security(syminfo.tickerid, tf_main, low)

high1h = request.security(syminfo.tickerid, tf_1h, high)
low1h  = request.security(syminfo.tickerid, tf_1h, low)

sweepHigh = high > high4h or (use1H and high > high1h)
sweepLow  = low < low4h  or (use1H and low < low1h)

// ================= CANDLE STRUCTURE =================
body = math.abs(close - open)
upper_wick = high - math.max(close, open)
lower_wick = math.min(close, open) - low

bull_trigger = (lower_wick > body) or (body > upper_wick * 1.5)
bear_trigger = (upper_wick > body) or (body > lower_wick * 1.5)

// ================= FILTERS =================
atr = ta.atr(14)

strongBull = (close - open) > atr * atrMult
strongBear = (open - close) > atr * atrMult

validSweepHigh = (high - high4h) > minSweep
validSweepLow  = (low4h - low) > minSweep

ema = ta.ema(close, 50)
bullTrend = close > ema
bearTrend = close < ema

rangeOK = (high - low) > atr * 0.5

longFilter = (not useDisplacement or strongBull) and (not useSweepDepth or validSweepLow) and (not useTrendFilter or bullTrend) and (not useRangeFilter or rangeOK)

shortFilter = (not useDisplacement or strongBear) and (not useSweepDepth or validSweepHigh) and (not useTrendFilter or bearTrend) and (not useRangeFilter or rangeOK)

// ================= FINAL ENTRY =================
longEntry = sweepLow and bear_run and isBull(0) and bull_trigger and longFilter

shortEntry = sweepHigh and bull_run and isBear(0) and bear_trigger and shortFilter

// ================= PLOT ARROWS =================
plotshape(longEntry,
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small,
     title="BUY")

plotshape(shortEntry,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small,
     title="SELL")

// ================= STOP LOSS =================
if longEntry
    line.new(bar_index, low - sl_points, bar_index+5, low - sl_points,
         color=color.red, width=2)

if shortEntry
    line.new(bar_index, high + sl_points, bar_index+5, high + sl_points,
         color=color.red, width=2)

// ================= EXECUTION =================
if timeframe.isintraday
    f_new_level(tf_main)
    if use1H
        f_new_level(tf_1h)

    f_check_liquidity()
````
