# Red & Blue No Gap Candles

- url: https://www.tradingview.com/script/oCq6fJHS-Red-Blue-No-Gap-Candles/
- type: indicator
- pine_id: PUB;bb848845b2a8496b8d31a7f865f619ba
- version: 1.0

## Description

Hey Y'all,

I made The Red & Blue No Gap Candles indicator, to help other traders that prefer Red & Blue No Gap Candles, to get their chart set up much faster.

I was inspired by the Original No Gap Candles, by Echepata, but I just wanted to make it a little easier for my Brother & Niece to get their chart set-up much faster with a few less steps.

I currently use the Red & Blue No Gap Candles everyday, to primarily trade Forex & Futures Currency markets, but the Red & Blue No Gap Candles works perfect on most charts like Bitcoin, Gold, NQ & many more.

I prefer using the Red & Blue No Gap Candles, because it's perfectly aligned with the previous candles's Open & Close, which is perfect & based on how most are taught in examples.

How To Use The Red & Blue No Gap Candles Indicator?

#1 - Right click any empty blank space on the Candlestick chart, then click Chart Settings.

#2 - Under Symbol Section, Un-check all the boxes, like "Color Bars Based On Previous Close, Body, Borders & Wick." - Then click "ok" to save.

#3 - Click Indicators button, then search for Red & Blue No Gap Candles, then click the star to save it under favorites, to make it easier for you to find it, then add it to your chart.

#4 - Enjoy using the Red & Blue No Gap Candles, to hopefully, make your trading experience a little bit easier.

Thanks!

## Source Code

````pine
//@version=6
indicator("Red & Blue No Gap Candles", overlay=true, behind_chart=false, max_lines_count=10)

//────────────────────────────────────────────────────────────────────
// SETTINGS
//────────────────────────────────────────────────────────────────────

bool applyToDayOpenOnly = input.bool(false, "Apply To Day Open Only")
float dayChangeHourThreshold = input.float(6.0, "Day Open Gap Threshold (Hours)", minval=0.0)
bool showPriceLine = input.bool(false, "Show Current Price Line")

color bullishColor = input.color(color.rgb(41, 98, 255), "Bullish Candle")
color bearishColor = input.color(color.rgb(255, 82, 82), "Bearish Candle")

//────────────────────────────────────────────────────────────────────
// NO GAP CANDLE CALCULATION
//────────────────────────────────────────────────────────────────────

float hoursSinceLastCandle = na(time[1]) ? na : (time - time[1]) / 3600000.0

float myOpen  = open
float myHigh  = high
float myLow   = low
float myClose = close

bool removeGap = not applyToDayOpenOnly or (not na(hoursSinceLastCandle) and hoursSinceLastCandle > dayChangeHourThreshold)

if removeGap and not na(close[1])
    myOpen := close[1]

// Make sure wick range still contains our synthetic open.
myHigh := math.max(high, myOpen, myClose)
myLow  := math.min(low, myOpen, myClose)

//────────────────────────────────────────────────────────────────────
// CANDLE COLORS
//────────────────────────────────────────────────────────────────────

color candleColor = myClose >= myOpen ? bullishColor : bearishColor

//────────────────────────────────────────────────────────────────────
// DRAW NO GAP CANDLES
//────────────────────────────────────────────────────────────────────

plotcandle(
     myOpen,
     myHigh,
     myLow,
     myClose,
     title="PUW No Gap Candles",
     color=candleColor,
     bordercolor=candleColor,
     wickcolor=candleColor,
     editable=false
)

//────────────────────────────────────────────────────────────────────
// CURRENT PRICE LINE
//────────────────────────────────────────────────────────────────────

var line currentPriceLine = na

if barstate.islast
    if showPriceLine
        if na(currentPriceLine)
            currentPriceLine := line.new(
                 bar_index - 500,
                 close,
                 bar_index + 100,
                 close,
                 extend=extend.both,
                 style=line.style_dotted,
                 width=1,
                 color=candleColor
             )
        else
            line.set_xy1(currentPriceLine, bar_index - 500, close)
            line.set_xy2(currentPriceLine, bar_index + 100, close)
            line.set_color(currentPriceLine, candleColor)
    else if not na(currentPriceLine)
        line.delete(currentPriceLine)
        currentPriceLine := na
````
