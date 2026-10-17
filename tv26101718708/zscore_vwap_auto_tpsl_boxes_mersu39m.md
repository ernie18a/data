# Z-Score + VWAP + Auto TP/SL Boxes

- url: https://www.tradingview.com/script/mersu39m-Z-Score-VWAP-Auto-TP-SL-Boxes/
- type: indicator
- pine_id: PUB;d62917ff195548b1873120a53fed9740
- version: 1.0

## Description

algo for tradig and thomas is goated guy it works really well and yeaj 
flw
,
w
w

w
w
w

## Source Code

````pine
//@version=5
indicator("Z-Score + VWAP + Auto TP/SL Boxes", overlay=true)

// =====================
// INPUTS
// =====================
length      = input.int(20, title="Z-Score Length")
entryLevel  = input.float(2.0, title="Z-Score Entry")
exitLevel   = input.float(0.5, title="Z-Score Exit")
sdMult      = input.float(2.0, title="SD Band Multiplier")

riskReward  = input.float(1.5, title="Risk Reward Ratio")

// =====================
// VWAP
// =====================
vwapValue = ta.vwap(close)

// =====================
// Z-SCORE
// =====================
mean    = ta.sma(close, length)
std     = ta.stdev(close, length)
zscore  = (close - mean) / std

// =====================
// SD BANDS
// =====================
upperBand = mean + std * sdMult
lowerBand = mean - std * sdMult

// =====================
// SIGNALS
// =====================
longSignal =
     ta.crossunder(zscore, -entryLevel) and
     close > vwapValue

shortSignal =
     ta.crossover(zscore, entryLevel) and
     close < vwapValue

// =====================
// PLOTS
// =====================
plotshape(
     longSignal,
     title="BUY",
     location=location.belowbar,
     color=color.green,
     style=shape.labelup,
     text="BUY",
     size=size.small)

plotshape(
     shortSignal,
     title="SELL",
     location=location.abovebar,
     color=color.red,
     style=shape.labeldown,
     text="SELL",
     size=size.small)

// =====================
// BANDS
// =====================
plot(upperBand, title="Upper SD Band", color=color.gray)
plot(lowerBand, title="Lower SD Band", color=color.gray)
plot(mean, title="Mean", color=color.yellow)
plot(vwapValue, title="VWAP", color=color.purple)

// =====================
// AUTO TP/SL BOXES
// =====================

// LONG SETUP
if longSignal

    entryPrice = close

    // Stop onder VWAP
    stopPrice = vwapValue

    // Risk distance
    risk = entryPrice - stopPrice

    // TP gebaseerd op RR
    targetPrice = entryPrice + (risk * riskReward)

    // TP BOX
    box.new(
         left=bar_index,
         right=bar_index + 10,
         top=targetPrice,
         bottom=entryPrice,
         bgcolor=color.new(color.blue, 80),
         border_color=color.blue)

    // SL BOX
    box.new(
         left=bar_index,
         right=bar_index + 10,
         top=entryPrice,
         bottom=stopPrice,
         bgcolor=color.new(color.gray, 85),
         border_color=color.gray)

    // ENTRY LINE
    line.new(
         x1=bar_index,
         y1=entryPrice,
         x2=bar_index + 10,
         y2=entryPrice,
         color=color.white,
         width=2)


// SHORT SETUP
if shortSignal

    entryPrice = close

    // Stop boven VWAP
    stopPrice = vwapValue

    // Risk distance
    risk = stopPrice - entryPrice

    // TP gebaseerd op RR
    targetPrice = entryPrice - (risk * riskReward)

    // TP BOX
    box.new(
         left=bar_index,
         right=bar_index + 10,
         top=entryPrice,
         bottom=targetPrice,
         bgcolor=color.new(color.blue, 80),
         border_color=color.blue)

    // SL BOX
    box.new(
         left=bar_index,
         right=bar_index + 10,
         top=stopPrice,
         bottom=entryPrice,
         bgcolor=color.new(color.gray, 85),
         border_color=color.gray)

    // ENTRY LINE
    line.new(
         x1=bar_index,
         y1=entryPrice,
         x2=bar_index + 10,
         y2=entryPrice,
         color=color.white,
         width=2)

// =====================
// ALERTS
// =====================
alertcondition(
     longSignal,
     title="BUY Alert",
     message="BUY Signal")

alertcondition(
     shortSignal,
     title="SELL Alert",
     message="SELL Signal")
````
