<!-- tradingview-pine-id: PUB;abf9039c1b7f4780b582c6fe3591cc1c -->
<!-- tradingviewscripts-format: 1 -->
# Legend BUY SELL + Supertrend Filter

Source: https://www.tradingview.com/script/8acpMXli-ABUKI-Legend-BUY-SELL-WITH-Supertrend-Filter/

## Description

ABUKI Legend BUY SELL WITH Supertrend Filter
best option for day traders and swing traders , it reduce stress of analyzing the markets

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © Sascha Sambale; merged with TradingView Supertrend logic.

//@version=6
strategy(
     title="Legend BUY SELL + Supertrend Filter",
     shorttitle="Legend + ST Filter",
     overlay=true,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     pyramiding=1,
     margin_long=0,
     margin_short=0,
     process_orders_on_close=true
)

//────────────────────────────────────────────────────────────────────
// Supertrend direction filter
//────────────────────────────────────────────────────────────────────
stAtrPeriod = input.int(10, "ATR Length", minval=1, group="Supertrend Filter")
stFactor = input.float(3.0, "Factor", minval=0.01, step=0.01, group="Supertrend Filter")
showTrendFill = input.bool(true, "Show Trend Background", group="Supertrend Filter")

[supertrendRaw, stDirection] = ta.supertrend(stFactor, stAtrPeriod)
supertrend = barstate.isfirst ? na : supertrendRaw

stBullish = stDirection < 0 and close > supertrend
stBearish = stDirection > 0 and close < supertrend
stTurnedBullish = stDirection[1] > stDirection
stTurnedBearish = stDirection[1] < stDirection

upTrend = plot(
     stDirection < 0 ? supertrend : na,
     "Supertrend Up Trend",
     color=color.green,
     style=plot.style_linebr,
     linewidth=2
)

downTrend = plot(
     stDirection > 0 ? supertrend : na,
     "Supertrend Down Trend",
     color=color.red,
     style=plot.style_linebr,
     linewidth=2
)

bodyMiddle = plot(
     barstate.isfirst ? na : (open + close) / 2,
     "Body Middle",
     display=display.none
)

fill(
     bodyMiddle,
     upTrend,
     title="Uptrend Background",
     color=showTrendFill ? color.new(color.green, 90) : na,
     fillgaps=false
)

fill(
     bodyMiddle,
     downTrend,
     title="Downtrend Background",
     color=showTrendFill ? color.new(color.red, 90) : na,
     fillgaps=false
)

//────────────────────────────────────────────────────────────────────
// Legend MACD + ADX signal engine
//────────────────────────────────────────────────────────────────────
fastLength = input.int(5, "Fast Length", minval=1, group="Legend Signal")
slowLength = input.int(13, "Slow Length", minval=1, group="Legend Signal")
source = input.source(close, "Source", group="Legend Signal")
signalLength = input.int(9, "Signal Smoothing", minval=1, maxval=50, group="Legend Signal")

adxLength = input.int(14, "ADX Smoothing", minval=1, group="ADX Filter")
diLength = input.int(10, "DI Length", minval=1, group="ADX Filter")
adxThreshold = input.float(25.0, "ADX Threshold", minval=0.0, group="ADX Filter")

// Risk is measured from the signal candle close to the current Supertrend line.
riskPercent = input.float(1.0, "Account Risk per Trade (%)", minval=0.01, step=0.1, group="Risk and Exits")
riskReward = input.float(3.0, "Target Risk/Reward", minval=0.1, step=0.1, group="Risk and Exits")
exitMode = input.string(
     "TP or Opposite Signal",
     "Exit Mode",
     options=["Fixed RR Target", "Opposite Signal", "TP or Opposite Signal"],
     group="Risk and Exits"
)
quantityStep = input.float(0.01, "Quantity Step", minval=0.000001, group="Risk and Exits")
minimumQuantity = input.float(0.01, "Minimum Quantity", minval=0.000001, group="Risk and Exits")

directionalMovement(simple int length) =>
    float up = ta.change(high)
    float down = -ta.change(low)
    float plusDM = na(up) ? na : up > down and up > 0 ? up : 0
    float minusDM = na(down) ? na : down > up and down > 0 ? down : 0
    float trueRange = ta.rma(ta.tr(true), length)
    float plus = fixnan(100 * ta.rma(plusDM, length) / trueRange)
    float minus = fixnan(100 * ta.rma(minusDM, length) / trueRange)
    [plus, minus]

calculateADX(simple int diPeriod, simple int smoothingPeriod) =>
    [plus, minus] = directionalMovement(diPeriod)
    float sumValue = plus + minus
    float adxValue = 100 * ta.rma(
         math.abs(plus - minus) / (sumValue == 0 ? 1 : sumValue),
         smoothingPeriod
    )
    adxValue

adxValue = calculateADX(diLength, adxLength)
fastEMA = ta.ema(source, fastLength)
slowEMA = ta.ema(source, slowLength)
macdValue = fastEMA - slowEMA
signalValue = ta.ema(macdValue, signalLength)
macdCrossUp = ta.crossover(macdValue, signalValue)
macdCrossDown = ta.crossunder(macdValue, signalValue)

legendBullish =
     adxValue > adxThreshold and
     macdValue < 0 and
     macdCrossUp

legendBearish =
     adxValue > adxThreshold and
     macdValue > 0 and
     macdCrossDown

//────────────────────────────────────────────────────────────────────
// Combined entries
// Legend produces the signal; Supertrend validates its direction.
//────────────────────────────────────────────────────────────────────
validBuy = legendBullish and stBullish
validSell = legendBearish and stBearish

useFixedTarget = exitMode != "Opposite Signal"
allowOppositeReversal = exitMode != "Fixed RR Target"

var float longStop = na
var float longTarget = na
var float shortStop = na
var float shortTarget = na
var float lastRiskCash = na
var float lastOrderQuantity = na

// A Supertrend stop can only tighten after entry; it never moves away from price.
if strategy.position_size > 0 and stDirection < 0 and supertrend < close
    longStop := na(longStop) ? supertrend : math.max(longStop, supertrend)

if strategy.position_size < 0 and stDirection > 0 and supertrend > close
    shortStop := na(shortStop) ? supertrend : math.min(shortStop, supertrend)

canEnterBuy = validBuy and (
     strategy.position_size == 0 or
     strategy.position_size < 0 and allowOppositeReversal
)

canEnterSell = validSell and (
     strategy.position_size == 0 or
     strategy.position_size > 0 and allowOppositeReversal
)

if canEnterBuy
    initialStop = supertrend
    initialRiskDistance = close - initialStop
    riskCash = strategy.equity * riskPercent / 100.0
    cashRiskPerUnit = initialRiskDistance * syminfo.pointvalue
    rawQuantity = cashRiskPerUnit > 0 ? riskCash / cashRiskPerUnit : 0.0
    orderQuantity = math.floor(rawQuantity / quantityStep) * quantityStep
    orderQuantity := orderQuantity >= minimumQuantity ? orderQuantity : 0.0

    if initialRiskDistance > syminfo.mintick and orderQuantity > 0
        longStop := initialStop
        longTarget := close + initialRiskDistance * riskReward
        lastRiskCash := riskCash
        lastOrderQuantity := orderQuantity

        strategy.entry(
             id="Buy",
             direction=strategy.long,
             qty=orderQuantity,
             alert_message="Legend BUY aligned with bullish Supertrend"
        )
        alert("Legend BUY aligned with bullish Supertrend", alert.freq_once_per_bar_close)

if canEnterSell
    initialStop = supertrend
    initialRiskDistance = initialStop - close
    riskCash = strategy.equity * riskPercent / 100.0
    cashRiskPerUnit = initialRiskDistance * syminfo.pointvalue
    rawQuantity = cashRiskPerUnit > 0 ? riskCash / cashRiskPerUnit : 0.0
    orderQuantity = math.floor(rawQuantity / quantityStep) * quantityStep
    orderQuantity := orderQuantity >= minimumQuantity ? orderQuantity : 0.0

    if initialRiskDistance > syminfo.mintick and orderQuantity > 0
        shortStop := initialStop
        shortTarget := close - initialRiskDistance * riskReward
        lastRiskCash := riskCash
        lastOrderQuantity := orderQuantity

        strategy.entry(
             id="Sell",
             direction=strategy.short,
             qty=orderQuantity,
             alert_message="Legend SELL aligned with bearish Supertrend"
        )
        alert("Legend SELL aligned with bearish Supertrend", alert.freq_once_per_bar_close)

// The stop is always active. The target depends on the selected exit mode.
if not na(longStop)
    strategy.exit(
         id="Buy Exit",
         from_entry="Buy",
         stop=longStop,
         limit=useFixedTarget ? longTarget : na,
         alert_message="Legend BUY exit"
    )

if not na(shortStop)
    strategy.exit(
         id="Sell Exit",
         from_entry="Sell",
         stop=shortStop,
         limit=useFixedTarget ? shortTarget : na,
         alert_message="Legend SELL exit"
    )

plot(
     strategy.position_size > 0 ? longStop : strategy.position_size < 0 ? shortStop : na,
     "Active Supertrend Stop",
     color=color.orange,
     linewidth=2,
     style=plot.style_linebr
)

plot(
     useFixedTarget ? strategy.position_size > 0 ? longTarget : strategy.position_size < 0 ? shortTarget : na : na,
     "Active RR Target",
     color=color.aqua,
     linewidth=2,
     style=plot.style_linebr
)

// Keep these values available in the Data Window for risk verification.
plot(lastRiskCash, "Planned Cash Risk", display=display.data_window)
plot(lastOrderQuantity, "Calculated Order Quantity", display=display.data_window)

plotshape(
     canEnterBuy,
     title="Filtered Buy",
     text="BUY",
     color=color.green,
     style=shape.labelup,
     location=location.belowbar,
     size=size.small,
     textcolor=color.white
)

plotshape(
     canEnterSell,
     title="Filtered Sell",
     text="SELL",
     color=color.red,
     style=shape.labeldown,
     location=location.abovebar,
     size=size.small,
     textcolor=color.white
)

// Raw Legend signals that were rejected by the Supertrend filter.
plotshape(
     legendBullish and not stBullish,
     title="Blocked Legend Buy",
     style=shape.xcross,
     location=location.belowbar,
     color=color.new(color.green, 55),
     size=size.tiny
)

plotshape(
     legendBearish and not stBearish,
     title="Blocked Legend Sell",
     style=shape.xcross,
     location=location.abovebar,
     color=color.new(color.red, 55),
     size=size.tiny
)

alertcondition(canEnterBuy, "Filtered Buy Signal", "Legend BUY aligned with bullish Supertrend")
alertcondition(canEnterSell, "Filtered Sell Signal", "Legend SELL aligned with bearish Supertrend")
alertcondition(stTurnedBullish, "Supertrend Turned Bullish", "Supertrend switched from bearish to bullish")
alertcondition(stTurnedBearish, "Supertrend Turned Bearish", "Supertrend switched from bullish to bearish")
alertcondition(stDirection[1] != stDirection, "Supertrend Trend Change", "Supertrend direction changed")
````
