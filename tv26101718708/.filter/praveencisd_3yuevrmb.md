# Praveen_CISD

- url: https://www.tradingview.com/script/3YueVrmb-Praveen-CISD/
- type: indicator
- pine_id: PUB;c023aeafa7144d268a1dbd2a5ecfb1a0
- version: 1.0

## Description

This is a Smart Money Concepts (SMC) based TradingView indicator designed to generate high-probability trade setups by combining liquidity analysis, institutional order flow, and higher-timeframe confluence.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © praveen_n007
//@version=5
indicator("SMC PRO CLEAN (CISD + HTF Zones + SLTP)", overlay=true)

// ===== INPUTS =====
htfInput = input.timeframe("15", "HTF")
useAutoMap = input.bool(true, "Auto TF Mapping")

showFVG = input.bool(true, "Show FVG")
showOB  = input.bool(true, "Show Order Blocks")
showEQ  = input.bool(true, "Show Equilibrium")
showSLTP = input.bool(true, "Show SL TP")

emaLen = input.int(50, "EMA Length")
zoneTol = input.float(0.1, "Zone Tolerance %")
rr = input.float(2.0, "Risk Reward")
len = input.int(5, "Structure Length")

// ===== AUTO TF =====
htf = useAutoMap ? (timeframe.period == "1" ? "15" : timeframe.period == "5" ? "60" : htfInput) : htfInput

// ===== HTF DATA =====
[H, L, C, O] = request.security(syminfo.tickerid, htf, [high, low, close, open], lookahead=barmerge.lookahead_off)

// ===== TREND =====
emaHTF = request.security(syminfo.tickerid, htf, ta.ema(close, emaLen))
bullTrend = C > emaHTF
bearTrend = C < emaHTF

// ===== FVG (3 candle) =====
bullFVG = L[1] > H[2]
bearFVG = H[1] < L[2]

var box fvgBox = na

if showFVG
    if bullFVG
        box.delete(fvgBox)
        fvgBox := box.new(bar_index, L[1], bar_index + 20, H[2], bgcolor=color.new(color.green, 85))
    if bearFVG
        box.delete(fvgBox)
        fvgBox := box.new(bar_index, L[2], bar_index + 20, H[1], bgcolor=color.new(color.red, 85))

// ===== ORDER BLOCK =====
bullOB = O[1] > C[1] and C > H[1]
bearOB = O[1] < C[1] and C < L[1]

var box obBox = na

if showOB
    if bullOB
        box.delete(obBox)
        obBox := box.new(bar_index, O[1], bar_index + 20, L[1], bgcolor=color.new(color.green, 80))
    if bearOB
        box.delete(obBox)
        obBox := box.new(bar_index, H[1], bar_index + 20, O[1], bgcolor=color.new(color.red, 80))

// ===== EQUILIBRIUM =====
rangeHigh = ta.highest(high, 50)
rangeLow = ta.lowest(low, 50)
eq = (rangeHigh + rangeLow) / 2

plot(showEQ ? eq : na, color=color.yellow)

// ===== ZONE CHECK =====
tol = close * zoneTol / 100

inFVG = showFVG and not na(fvgBox) and close <= box.get_top(fvgBox) + tol and close >= box.get_bottom(fvgBox) - tol
inOB = showOB and not na(obBox) and close <= box.get_top(obBox) + tol and close >= box.get_bottom(obBox) - tol

inZone = inFVG or inOB

// ===== LIQUIDITY SWEEP =====
liqHigh = ta.highest(high, len)
liqLow = ta.lowest(low, len)

sweepHigh = high > liqHigh[1] and close < liqHigh
sweepLow = low < liqLow[1] and close > liqLow

// ===== CISD =====
prevHigh = ta.highest(high, len)
prevLow = ta.lowest(low, len)

bullCISD = high > prevHigh[1] and close > open
bearCISD = low < prevLow[1] and close < open

// ===== SIGNAL =====
buy = sweepLow and bullCISD and inZone and bullTrend
sell = sweepHigh and bearCISD and inZone and bearTrend

// ===== SL / TP =====
var line slLine = na
var line tpLine = na

if showSLTP
    if buy
        sl = ta.lowest(low, len)
        entry = close
        tp = entry + (entry - sl) * rr
        line.delete(slLine)
        line.delete(tpLine)
        slLine := line.new(bar_index, sl, bar_index + 20, sl, color=color.red)
        tpLine := line.new(bar_index, tp, bar_index + 20, tp, color=color.green)

    if sell
        sl = ta.highest(high, len)
        entry = close
        tp = entry - (sl - entry) * rr
        line.delete(slLine)
        line.delete(tpLine)
        slLine := line.new(bar_index, sl, bar_index + 20, sl, color=color.red)
        tpLine := line.new(bar_index, tp, bar_index + 20, tp, color=color.green)

// ===== SIGNAL PLOTS =====
plotshape(buy, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY")
plotshape(sell, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL")

bgcolor(bullTrend ? color.new(color.green, 92) : bearTrend ? color.new(color.red, 92) : na)

// ===== ALERTS =====
alertcondition(buy, "BUY", "BUY signal")
alertcondition(sell, "SELL", "SELL signal")
````
