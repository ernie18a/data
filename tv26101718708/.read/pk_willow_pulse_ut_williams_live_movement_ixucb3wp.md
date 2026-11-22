# PK Willow Pulse - UT + Williams + Live Movement

- url: https://www.tradingview.com/script/IxuCb3wp-PK-Willow-Pulse-UT-Williams-Live-Movement/
- type: indicator
- pine_id: PUB;74a97760f909479ebe3faa4c1a94d654
- version: 1.0

## Description

Market indicators are mathematical or statistical tools used by investors and traders to analyze market trends, evaluate investor sentiment, and predict future price movements. They apply formulas to price, volume, or broader financial data to generate actionable buy or exit signals

## Source Code

````pine
//@version=6
indicator("PK Willow Pulse - UT + Williams + Live Movement", overlay=true, max_labels_count=500)

// ===== INPUTS =====
signalMode = input.string("Both", "Signal Mode", options=["UT Bot", "Williams", "Both"])
strikeStep = input.int(50, "Strike Step")
showUT = input.bool(true, "Show UT Bot")
showFractals = input.bool(true, "Show Williams Fractals")

// UT Bot inputs
utKey = input.float(1.0, "UT Key Value")
utAtrPeriod = input.int(10, "UT ATR Period")
useHA = input.bool(false, "Use Heikin Ashi")

// Williams inputs
n = input.int(2, "Williams Periods", minval=2)

// ===== UT BOT =====
src = useHA ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off) : close

xATR = ta.atr(utAtrPeriod)
nLoss = utKey * xATR

var float trail = na
trail := src > nz(trail[1], 0) and src[1] > nz(trail[1], 0) ? math.max(nz(trail[1]), src - nLoss) :
     src < nz(trail[1], 0) and src[1] < nz(trail[1], 0) ? math.min(nz(trail[1]), src + nLoss) :
     src > nz(trail[1], 0) ? src - nLoss : src + nLoss

ema1 = ta.ema(src, 1)
utBuy = src > trail and ta.crossover(ema1, trail)
utSell = src < trail and ta.crossover(trail, ema1)

// ===== WILLIAMS FRACTALS =====
upFractal = ta.pivothigh(high, n, n)
downFractal = ta.pivotlow(low, n, n)

willBuy = not na(downFractal)
willSell = not na(upFractal)

// ===== FINAL SIGNALS =====
buyRaw = signalMode == "UT Bot" ? utBuy : signalMode == "Williams" ? willBuy : utBuy or willBuy
sellRaw = signalMode == "UT Bot" ? utSell : signalMode == "Williams" ? willSell : utSell or willSell

buyOffset = utBuy ? 0 : n
sellOffset = utSell ? 0 : n

// avoid same-bar confusion
buySignal = buyRaw and not sellRaw
sellSignal = sellRaw and not buyRaw

// ===== LABEL MEMORY =====
var label activeLabel = na
var float activePrice = na
var int activeDir = 0
var string activeBaseText = ""

getTimeText(t) =>
    str.format("{0,date,dd MMM} at {0,time,HH:mm}", t)

// ===== FUNCTION: FREEZE OLD LABEL =====
freezeOldLabel(sigPrice) =>
    if not na(activeLabel) and not na(activePrice)
        finalMove = activeDir == 1 ? sigPrice - activePrice : activePrice - sigPrice
        finalPct = finalMove / activePrice * 100
        label.set_text(activeLabel,
             activeBaseText + "\n" +
             "Final: " + str.tostring(finalMove, "#.##") + " pts (" +
             str.tostring(finalPct, "#.##") + "%)")

// ===== BUY SIGNAL =====
if buySignal
    sigPrice = close[buyOffset]
    sigTime = time[buyOffset]
    atmStrike = math.round(sigPrice / strikeStep) * strikeStep

    freezeOldLabel(sigPrice)

    activeBaseText :=
         "Bullish Structure\n" +
         str.tostring(sigPrice, "#.##") + "\n" +
         "(" + getTimeText(sigTime) + ")\n" +
         "ATM: " + str.tostring(atmStrike) + " CE"

    activeLabel := label.new(bar_index - buyOffset, low[buyOffset],
         activeBaseText + "\nLive: 0 pts",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

    activePrice := sigPrice
    activeDir := 1

// ===== SELL SIGNAL =====
if sellSignal
    sigPrice = close[sellOffset]
    sigTime = time[sellOffset]
    atmStrike = math.round(sigPrice / strikeStep) * strikeStep

    freezeOldLabel(sigPrice)

    activeBaseText :=
         "Bearish Structure\n" +
         str.tostring(sigPrice, "#.##") + "\n" +
         "(" + getTimeText(sigTime) + ")\n" +
         "ATM: " + str.tostring(atmStrike) + " PE"

    activeLabel := label.new(bar_index - sellOffset, high[sellOffset],
         activeBaseText + "\nLive: 0 pts",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

    activePrice := sigPrice
    activeDir := -1

// ===== LIVE UPDATE =====
if not na(activeLabel) and not na(activePrice)
    liveMove = activeDir == 1 ? close - activePrice : activePrice - close
    livePct = liveMove / activePrice * 100

    label.set_text(activeLabel,
         activeBaseText + "\n" +
         "Live: " + str.tostring(liveMove, "#.##") + " pts (" +
         str.tostring(livePct, "#.##") + "%)")

// ===== PLOTS =====
plot(showUT ? trail : na, "UT Trail", color=color.orange, linewidth=2)

plotshape(showUT and utBuy, title="UT Buy", text="UT Buy",
     style=shape.labelup, location=location.belowbar,
     color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showUT and utSell, title="UT Sell", text="UT Sell",
     style=shape.labeldown, location=location.abovebar,
     color=color.red, textcolor=color.white, size=size.tiny)

plotshape(showFractals and willBuy, title="Williams Buy",
     style=shape.triangleup, location=location.belowbar,
     color=color.green, size=size.tiny, offset=-n)

plotshape(showFractals and willSell, title="Williams Sell",
     style=shape.triangledown, location=location.abovebar,
     color=color.red, size=size.tiny, offset=-n)

alertcondition(buySignal, title="PK Willow BUY", message="PK Willow BUY")
alertcondition(sellSignal, title="PK Willow SELL", message="PK Willow SELL")
````
