<!-- tradingview-pine-id: PUB;eda06b8e24fa4f6ea1acb30d34abb79f -->
<!-- tradingviewscripts-format: 1 -->
# Box Theory BB System V7

Source: https://www.tradingview.com/script/8W5MLVih-Box-Theory-BB-System-V7/

## Description

The Box Theory BB System V7 is a multi-timeframe trend and momentum indicator designed for intraday futures trading. It combines a 4-hour market structure box, higher timeframe trend alignment, 200 EMA trend filtering and a Bollinger Band/EMA entry system to help identify higher-probability trade locations. The purpose of the indicator is not to predict every market movement, but to help traders identify when price is aligned with the larger market direction and entering from a favorable location. The system is designed primarily for use on a 5 minute chart with higher timeframe confirmation from the 15-minute, 1-hour and 4-hour charts.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tmwilkerson8647124

//@version=6
indicator("Box Theory BB System V7", overlay=true, max_boxes_count=10)


//====================================================
// INPUTS
//====================================================

// 200 EMA
emaLength = input.int(200, "200 EMA Length")

// Bollinger Inputs
bbUseEMA = input.bool(false, "Use EMA for Bollinger Basis")
bbLength = input.int(20, "Bollinger Length", minval=1)
bbSource = input.source(close, "Bollinger Source")
bbMult = input.float(2.0, "Bollinger Multiplier", minval=0.5)

// Fast EMA
fastEMALength = input.int(3, "Fast EMA Length", minval=1)


//====================================================
// 200 EMA TREND FILTER
//====================================================

ema200 = ta.ema(close, emaLength)

bullTrend = close > ema200
bearTrend = close < ema200

emaColor = bullTrend ? color.green : color.red

plot(
     ema200,
     title="200 EMA",
     color=emaColor,
     linewidth=3
)


//====================================================
// BOLLINGER BANDS
//====================================================

bbBasis = bbUseEMA ?
     ta.ema(bbSource, bbLength) :
     ta.sma(bbSource, bbLength)


bbDeviation = bbMult * ta.stdev(bbSource, bbLength)

bbUpper = bbBasis + bbDeviation
bbLower = bbBasis - bbDeviation


plot(
     bbBasis,
     title="BB Basis",
     color=color.red,
     linewidth=2
)

upperPlot = plot(
     bbUpper,
     title="BB Upper",
     color=color.blue
)

lowerPlot = plot(
     bbLower,
     title="BB Lower",
     color=color.blue
)

fill(
     upperPlot,
     lowerPlot,
     color=color.new(color.gray, 90)
)


//====================================================
// FAST EMA
//====================================================

fastEMA = ta.ema(close, fastEMALength)

plot(
     fastEMA,
     title="Fast EMA",
     color=color.black,
     linewidth=2
)
//====================================================
// PREVIOUS 4H CANDLE BOX
//====================================================

show4HBox = input.bool(true, "Show Previous 4H Box")


// Previous completed 4H candle high and low
prev4HHigh = request.security(
     syminfo.tickerid,
     "240",
     high[1],
     lookahead=barmerge.lookahead_off
)

prev4HLow = request.security(
     syminfo.tickerid,
     "240",
     low[1],
     lookahead=barmerge.lookahead_off
)


// Detect new 4H candle
new4HCandle = ta.change(time("240")) != 0


var box h4Box = na


if new4HCandle and show4HBox

    if not na(h4Box)
        box.delete(h4Box)

    h4Box := box.new(
         left=bar_index,
         top=prev4HHigh,
         right=bar_index + 200,
         bottom=prev4HLow,
         border_color=color.orange,
         bgcolor=color.new(color.orange, 85)
    )

//====================================================
// HIGHER TIMEFRAME ALIGNMENT TABLE
//====================================================

showTable = input.bool(true, "Show HTF Table")


getTrend(tf)=>

    tfClose = request.security(
         syminfo.tickerid,
         tf,
         close
    )

    tfEMA = request.security(
         syminfo.tickerid,
         tf,
         ta.ema(close, emaLength)
    )

    tfClose > tfEMA ? "BULLISH" : "BEARISH"


trend5 = getTrend("5")
trend15 = getTrend("15")
trend60 = getTrend("60")
trend240 = getTrend("240")


var table trendTable = table.new(
     position.top_right,
     2,
     5,
     border_width=2
)


// Function for trend colors

trendColor(trend)=>
    trend == "BULLISH" ? color.green : color.red


if barstate.islast and showTable

    // Header
    table.cell(
         trendTable,
         0,
         0,
         "TF",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         trendTable,
         1,
         0,
         "TREND",
         text_color=color.white,
         bgcolor=color.black
    )


    // 5 Minute
    table.cell(
         trendTable,
         0,
         1,
         "5M",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         trendTable,
         1,
         1,
         trend5,
         text_color=color.white,
         bgcolor=trendColor(trend5)
    )


    // 15 Minute
    table.cell(
         trendTable,
         0,
         2,
         "15M",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         trendTable,
         1,
         2,
         trend15,
         text_color=color.white,
         bgcolor=trendColor(trend15)
    )


    // 1 Hour
    table.cell(
         trendTable,
         0,
         3,
         "1H",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         trendTable,
         1,
         3,
         trend60,
         text_color=color.white,
         bgcolor=trendColor(trend60)
    )


    // 4 Hour
    table.cell(
         trendTable,
         0,
         4,
         "4H",
         text_color=color.white,
         bgcolor=color.black
    )

    table.cell(
         trendTable,
         1,
         4,
         trend240,
         text_color=color.white,
         bgcolor=trendColor(trend240)
    )

//====================================================
// PART 2 - SIGNAL ENGINE
//====================================================


//====================================================
// ADDITIONAL INPUTS
//====================================================

bbFilter = input.bool(false, "Filter Signals With Bollinger Bands")

sqzFilter = input.bool(false, "Filter Signals With BB Squeeze")

sqzLength = input.int(
     100,
     "BB Relative Squeeze Length",
     minval=5
)

sqzThreshold = input.int(
     50,
     "BB Squeeze Threshold %",
     maxval=99,
     step=5
)


//====================================================
// BB SQUEEZE CALCULATION
//====================================================

bbSpread = bbUpper - bbLower

avgSpread = ta.sma(
     bbSpread,
     sqzLength
)

bbSqueeze =
     (bbSpread / avgSpread) * 100


squeezeOK =
     bbSqueeze > sqzThreshold



//====================================================
// BREAKOUT CONDITIONS
//====================================================

breakUp =
     ta.crossover(fastEMA, bbBasis) and
     close > bbBasis


breakDown =
     ta.crossunder(fastEMA, bbBasis) and
     close < bbBasis



//====================================================
// APPLY FILTERS
//====================================================

buySignal =
     breakUp and
     bullTrend and
     (not bbFilter or close < bbUpper) and
     (not sqzFilter or squeezeOK)


sellSignal =
     breakDown and
     bearTrend and
     (not bbFilter or close > bbLower) and
     (not sqzFilter or squeezeOK)



//====================================================
// PREVENT REPEATED SIGNALS
//====================================================

newBuy =
     buySignal and not buySignal[1]


newSell =
     sellSignal and not sellSignal[1]




//====================================================
// BOX FILTER SETTINGS
//====================================================

use4HBoxFilter = input.bool(
     false,
     "Filter Signals Using 4H Box"
)


//====================================================
// CALCULATE BOX MIDPOINT
//====================================================

boxMiddle =
     (prev4HHigh + prev4HLow) / 2

//====================================================
// BOX LOCATION
//====================================================

priceInLowerBox =
     not na(boxMiddle) and close <= boxMiddle


priceInUpperBox =
     not na(boxMiddle) and close >= boxMiddle



//====================================================
// APPLY 4H BOX FILTER
//====================================================

boxBuyOK =
     not use4HBoxFilter or priceInLowerBox


boxSellOK =
     not use4HBoxFilter or priceInUpperBox



//====================================================
// FINAL SIGNALS (CLEAN BOOLEAN VERSION)
//====================================================

finalBuy =
     bool(newBuy) and bool(boxBuyOK)


finalSell =
     bool(newSell) and bool(boxSellOK)

//====================================================
// FINAL SIGNAL MARKERS
//====================================================

plotshape(
     finalBuy,
     title="FINAL BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
)


plotshape(
     finalSell,
     title="FINAL SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
)



//====================================================
// FINAL ALERTS
//====================================================

alertcondition(
     finalBuy,
     title="V7 FINAL BUY",
     message="Box Theory BB System V7 Confirmed BUY"
)


alertcondition(
     finalSell,
     title="V7 FINAL SELL",
     message="Box Theory BB System V7 Confirmed SELL"
)
````
