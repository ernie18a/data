# Supertrend Engulf Breakout

- url: https://www.tradingview.com/script/UGMuUUyE-Supertrend-Engulf-Breakout/
- type: indicator
- pine_id: PUB;9895b4f5ef69442e94c0dcbe51c8df74
- version: 1.0

## Description

Supertrend Engulf Breakout is in beta testing...we trade a break out system inside the supertrend.

## Source Code

````pine
// @version=5
// Supertrend + Engulfing Box Breakout Strategy
// -----------------------------------------------
// BUY:  Supertrend is green → green candle engulfs red candle →
//       draw box from green candle low to high → next candle closes above box → BUY
// SELL: Supertrend is red  → red candle engulfs green candle →
//       draw box from red candle low to high → next candle closes below box → SELL

indicator("Supertrend Engulf Breakout", overlay=true, max_boxes_count=500, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
atrPeriod   = input.int(10,    "ATR Period",          minval=1)
atrMult     = input.float(3.0, "ATR Multiplier",      step=0.1)
changeATR   = input.bool(true, "Use ATR (vs SMA-TR)?")
showSignals = input.bool(true, "Show Buy/Sell Signals")
highlighting= input.bool(true, "Highlighter On/Off")
boxColor    = input.color(color.new(color.yellow, 75), "Buy Box Fill Color")
boxBorder   = input.color(color.new(color.yellow, 20), "Buy Box Border Color")

// ─── SUPERTREND CALCULATION ───────────────────────────────────────────────────
src  = hl2
atr2 = ta.sma(ta.tr, atrPeriod)
atrVal  = changeATR ? ta.atr(atrPeriod) : atr2

up   = src - atrMult * atrVal
up  := nz(close[1] > nz(up[1], up) ? math.max(up, nz(up[1], up)) : up)

dn   = src + atrMult * atrVal
dn  := nz(close[1] < nz(dn[1], dn) ? math.min(dn, nz(dn[1], dn)) : dn)

var int trend = 1
trend := nz(trend[1], 1)
trend := trend == -1 and close > nz(dn[1], dn) ?  1 :
         trend ==  1 and close < nz(up[1], up) ? -1 : trend

supertrendGreen = trend ==  1
supertrendRed   = trend == -1

// ─── SUPERTREND PLOTS ─────────────────────────────────────────────────────────
upPlot = plot(supertrendGreen ? up : na, "Up Trend",   style=plot.style_linebr, linewidth=2, color=color.green)
dnPlot = plot(supertrendRed   ? dn : na, "Down Trend", style=plot.style_linebr, linewidth=2, color=color.red)
mPlot  = plot(ohlc4, "", style=plot.style_circles, linewidth=0)

longFillColor  = highlighting ? (supertrendGreen ? color.new(color.green, 90) : color.new(color.white, 100)) : color.new(color.white, 100)
shortFillColor = highlighting ? (supertrendRed   ? color.new(color.red,   90) : color.new(color.white, 100)) : color.new(color.white, 100)
fill(mPlot, upPlot, title="UpTrend Highlighter",  color=longFillColor)
fill(mPlot, dnPlot, title="DownTrend Highlighter", color=shortFillColor)

// Supertrend flip markers
buyFlip  = supertrendGreen and trend[1] == -1
sellFlip = supertrendRed   and trend[1] ==  1
plotshape(buyFlip  ? up : na, "UpTrend Begins",   location=location.absolute, style=shape.circle, size=size.tiny, color=color.green)
plotshape(sellFlip ? dn : na, "DownTrend Begins", location=location.absolute, style=shape.circle, size=size.tiny, color=color.red)

// ─── CANDLE HELPERS ───────────────────────────────────────────────────────────
prevOpen  = open[1]
prevClose = close[1]
prevHigh  = high[1]
prevLow   = low[1]

prevBullish = close[1] > open[1]
prevBearish = close[1] < open[1]
currBullish = close > open
currBearish = close < open

prevBody = math.abs(close[1] - open[1])
currBody = math.abs(close - open)

// ─── BOX STATE VARIABLES ──────────────────────────────────────────────────────
var float buyBoxLow   = na
var float buyBoxHigh  = na
var box   buyBoxObj   = na

var float sellBoxLow  = na
var float sellBoxHigh = na
var box   sellBoxObj  = na

// ─── ENGULF CONDITIONS (declared at global scope) ────────────────────────────
buyEngulf = supertrendGreen and currBullish and prevBearish and currBody > prevBody and close > prevOpen and open  < prevClose

sellEngulf = supertrendRed and
             currBearish and
             prevBullish and
             currBody > prevBody and
             open  > prevClose and
             close < prevOpen

// ─── BREAKOUT CONDITIONS (declared at global scope) ──────────────────────────
buySignal  = not na(buyBoxHigh)  and close > buyBoxHigh  and not buyEngulf
sellSignal = not na(sellBoxLow)  and close < sellBoxLow  and not sellEngulf

// ─── BUY BOX LOGIC ───────────────────────────────────────────────────────────
if buyEngulf
    if not na(buyBoxObj)
        box.delete(buyBoxObj)
    buyBoxLow  := low
    buyBoxHigh := high
    buyBoxObj  := box.new(bar_index, high, bar_index + 50, low,
                          border_color=boxBorder, bgcolor=boxColor,
                          border_width=1, extend=extend.none)

// ─── BUY SIGNAL ──────────────────────────────────────────────────────────────
if buySignal and showSignals
    label.new(bar_index, low * 0.9995,
              "BUY", style=label.style_label_up,
              color=color.green, textcolor=color.white, size=size.normal)
    if not na(buyBoxObj)
        box.set_right(buyBoxObj, bar_index)
    buyBoxLow  := na
    buyBoxHigh := na
    buyBoxObj  := na

// ─── SELL BOX LOGIC ──────────────────────────────────────────────────────────
if sellEngulf
    if not na(sellBoxObj)
        box.delete(sellBoxObj)
    sellBoxLow  := low
    sellBoxHigh := high
    sellBoxObj  := box.new(bar_index, high, bar_index + 50, low,
                           border_color=color.new(color.orange, 20),
                           bgcolor=color.new(color.orange, 80),
                           border_width=1, extend=extend.none)

// ─── SELL SIGNAL ─────────────────────────────────────────────────────────────
if sellSignal and showSignals
    label.new(bar_index, high * 1.0005,
              "SELL", style=label.style_label_down,
              color=color.red, textcolor=color.white, size=size.normal)
    if not na(sellBoxObj)
        box.set_right(sellBoxObj, bar_index)
    sellBoxLow  := na
    sellBoxHigh := na
    sellBoxObj  := na

// ─── INVALIDATION: Clear pending boxes on trend flip ─────────────────────────
if supertrendRed and not na(buyBoxHigh)
    if not na(buyBoxObj)
        box.delete(buyBoxObj)
    buyBoxLow  := na
    buyBoxHigh := na
    buyBoxObj  := na

if supertrendGreen and not na(sellBoxLow)
    if not na(sellBoxObj)
        box.delete(sellBoxObj)
    sellBoxLow  := na
    sellBoxHigh := na
    sellBoxObj  := na

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(buySignal,  "Engulf Breakout BUY",  "Supertrend Engulf Breakout — BUY Signal!")
alertcondition(sellSignal, "Engulf Breakout SELL", "Supertrend Engulf Breakout — SELL Signal!")
alertcondition(buyFlip,    "SuperTrend Buy Flip",  "SuperTrend turned Bullish!")
alertcondition(sellFlip,   "SuperTrend Sell Flip", "SuperTrend turned Bearish!")
````
