# Absorption Bubbles with Footprint 

- url: https://www.tradingview.com/script/3USGq0em-Absorption-Bubbles-with-Footprint/
- type: indicator
- pine_id: PUB;5aad1decafab403aaa15e8ae31469027
- version: 1.0

## Description

Absorption Bubbles with Footprint

Absorption Bubbles Footprint - Visible is a footprint-based TradingView indicator designed to highlight possible buying and selling absorption directly on the price chart.

The script analyzes footprint volume rows inside candle wicks and detects areas where one side of the market shows strong dominance. Buying absorption is detected in the lower wick when buyer volume dominates seller volume. Selling absorption is detected in the upper wick when seller volume dominates buyer volume. The goal is to help traders visually identify potential exhaustion, liquidity absorption, and reaction zones.

Key Features
Detects buying absorption in lower candle wicks.
Detects selling absorption in upper candle wicks.
Uses TradingView footprint data through request.footprint().
Shows absorption bubbles at the exact footprint row price.
Bubble size increases with absorption strength.
Optional halo bubbles for stronger visual confirmation.
Optional triangle markers on candle highs/lows.
Optional bar highlighting for signal candles.
Adjustable dominance ratio, absorption threshold, row size, lookback period, and minimum row volume.
Includes alert conditions for buying absorption, selling absorption, or any absorption event.
Displays useful values in the Data Window, including row volume, strength, and absorption price.
How It Works

The indicator scans the footprint volume rows inside each candle. For bullish absorption, it checks the lower wick and looks for rows where buy volume is significantly stronger than sell volume. For bearish absorption, it checks the upper wick and looks for rows where sell volume is significantly stronger than buy volume.

The detected volume is compared against its historical average using the selected lookback period. When the volume strength passes the selected threshold, the indicator prints a bubble on the chart at the exact price level where the absorption occurred.

Green bubbles represent buying absorption.
Red bubbles represent selling absorption.
White bubbles represent extremely strong absorption events.

Suggested Use

This indicator can be useful for traders who use order flow, footprint analysis, liquidity concepts, reversals, pullbacks, or support and resistance zones. Absorption signals may be especially useful when they appear near key levels such as previous highs/lows, value area levels, VWAP, liquidity zones, or major support/resistance.

A buying absorption signal may suggest that aggressive selling pressure is being absorbed by stronger buyers.
A selling absorption signal may suggest that aggressive buying pressure is being absorbed by stronger sellers.

Important Notes

This indicator does not predict price movement by itself. Absorption should be used together with market structure, trend context, liquidity levels, volume profile, VWAP, or other confirmation tools.

Because it uses footprint data, availability may depend on the symbol, exchange, and TradingView data support.

Disclaimer

This script is for educational and analytical purposes only. It is not financial advice and should not be used as the only reason to enter or exit a trade. Always test your strategy and manage risk properly.

## Source Code

````pine
//@version=6
indicator("Absorption Bubbles Footprint - Visible", overlay = true, scale = scale.none)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
groupName = "Absorption Bubbles"

showDots         = input.bool(true, "Show Bubbles?", group = groupName)
showHalo         = input.bool(true, "Show Halo Bubble", group = groupName)
showTriangles    = input.bool(true, "Show High/Low Triangle Marker", group = groupName)
highlightBars    = input.bool(true, "Highlight Signal Bars", group = groupName)

ticksPerRow      = input.int(25, "Ticks per row", minval = 1, group = groupName)
valueAreaPct     = input.int(70, "Value area %", minval = 1, maxval = 100, group = groupName)
limitFactor      = input.float(1.0, "Absorption Threshold", step = 0.1, minval = 0.1, group = groupName)
lookbackPeriod   = input.int(100, "Lookback Period", minval = 5, group = groupName)
dominanceRatio   = input.float(1.25, "Dominance Ratio", minval = 1.0, step = 0.05, group = groupName)
minRowVolume     = input.float(0.0, "Minimum Row Volume", minval = 0.0, step = 1.0, group = groupName)
useConfirmedBars = input.bool(true, "Only print after candle close", group = groupName)

// Bright colors
buyCoreColor  = color.rgb(0, 255, 80)
buyHaloColor  = color.new(color.rgb(0, 255, 80), 70)
sellCoreColor = color.rgb(255, 40, 40)
sellHaloColor = color.new(color.rgb(255, 40, 40), 70)

//--------------------------------------------------
// Candle structure
//--------------------------------------------------
float topBody = math.max(open, close)
float botBody = math.min(open, close)
float topWick = high
float botWick = low
float midBody = (topBody + botBody) / 2.0

bool bullBar = close > open
bool bearBar = close < open

//--------------------------------------------------
// Footprint
//--------------------------------------------------
footprint fp = request.footprint(ticksPerRow, valueAreaPct)
bool hasFp = not na(fp)

//--------------------------------------------------
// Scan wick rows for true absorption
//--------------------------------------------------
float buyRowVol    = na
float buyRowPrice  = na
float buyOpposing  = na

float sellRowVol   = na
float sellRowPrice = na
float sellOpposing = na

if hasFp
    array<volume_row> rows = fp.rows()

    float bestBuyVol    = na
    float bestBuyPrice  = na
    float bestBuyOpp    = na

    float bestSellVol   = na
    float bestSellPrice = na
    float bestSellOpp   = na

    for row in rows
        float rowTop    = row.up_price()
        float rowBot    = row.down_price()
        float rowMid    = (rowTop + rowBot) / 2.0

        float rowBuyVol  = row.buy_volume()
        float rowSellVol = row.sell_volume()
        float rowTotal   = rowBuyVol + rowSellVol

        bool inLowerWick = rowMid <= botBody and rowMid >= botWick
        bool inUpperWick = rowMid >= topBody and rowMid <= topWick

        bool buyDominant  = rowBuyVol  > rowSellVol * dominanceRatio
        bool sellDominant = rowSellVol > rowBuyVol  * dominanceRatio

        bool validBuyCandidate  = inLowerWick and rowTotal >= minRowVolume and buyDominant
        bool validSellCandidate = inUpperWick and rowTotal >= minRowVolume and sellDominant

        if validBuyCandidate and (na(bestBuyVol) or rowBuyVol > bestBuyVol)
            bestBuyVol   := rowBuyVol
            bestBuyPrice := rowMid
            bestBuyOpp   := rowSellVol

        if validSellCandidate and (na(bestSellVol) or rowSellVol > bestSellVol)
            bestSellVol   := rowSellVol
            bestSellPrice := rowMid
            bestSellOpp   := rowBuyVol

    buyRowVol    := bestBuyVol
    buyRowPrice  := bestBuyPrice
    buyOpposing  := bestBuyOpp

    sellRowVol   := bestSellVol
    sellRowPrice := bestSellPrice
    sellOpposing := bestSellOpp

//--------------------------------------------------
// Strength vs history
//--------------------------------------------------
float avgBuyRowVol  = ta.sma(buyRowVol, lookbackPeriod)
float avgSellRowVol = ta.sma(sellRowVol, lookbackPeriod)

float buyStrength  = not na(avgBuyRowVol) and avgBuyRowVol > 0 ? buyRowVol / avgBuyRowVol : na
float sellStrength = not na(avgSellRowVol) and avgSellRowVol > 0 ? sellRowVol / avgSellRowVol : na

//--------------------------------------------------
// Conditions
//--------------------------------------------------
bool allowPrint = useConfirmedBars ? barstate.isconfirmed : true

bool absorptionBuy = (
    showDots and
    hasFp and
    allowPrint and
    not na(buyRowVol) and
    not na(avgBuyRowVol) and
    buyStrength >= limitFactor and
    buyRowVol > buyOpposing * dominanceRatio
)

bool absorptionSell = (
    showDots and
    hasFp and
    allowPrint and
    not na(sellRowVol) and
    not na(avgSellRowVol) and
    sellStrength >= limitFactor and
    sellRowVol > sellOpposing * dominanceRatio
)

//--------------------------------------------------
// Size buckets
//--------------------------------------------------
bool condA_buy = absorptionBuy and buyStrength  >= limitFactor and buyStrength  < (limitFactor + 1)
bool condB_buy = absorptionBuy and buyStrength  >= (limitFactor + 1) and buyStrength  < (limitFactor + 2)
bool condC_buy = absorptionBuy and buyStrength  >= (limitFactor + 2) and buyStrength  < (limitFactor + 3)
bool condD_buy = absorptionBuy and buyStrength  >= (limitFactor + 3) and buyStrength  < (limitFactor + 6)
bool condE_buy = absorptionBuy and buyStrength  >= (limitFactor + 6)

bool condA_sell = absorptionSell and sellStrength >= limitFactor and sellStrength < (limitFactor + 1)
bool condB_sell = absorptionSell and sellStrength >= (limitFactor + 1) and sellStrength < (limitFactor + 2)
bool condC_sell = absorptionSell and sellStrength >= (limitFactor + 2) and sellStrength < (limitFactor + 3)
bool condD_sell = absorptionSell and sellStrength >= (limitFactor + 3) and sellStrength < (limitFactor + 6)
bool condE_sell = absorptionSell and sellStrength >= (limitFactor + 6)

//--------------------------------------------------
// Exact row price series
//--------------------------------------------------
float buyPriceA  = condA_buy  ? buyRowPrice  : na
float buyPriceB  = condB_buy  ? buyRowPrice  : na
float buyPriceC  = condC_buy  ? buyRowPrice  : na
float buyPriceD  = condD_buy  ? buyRowPrice  : na
float buyPriceE  = condE_buy  ? buyRowPrice  : na

float sellPriceA = condA_sell ? sellRowPrice : na
float sellPriceB = condB_sell ? sellRowPrice : na
float sellPriceC = condC_sell ? sellRowPrice : na
float sellPriceD = condD_sell ? sellRowPrice : na
float sellPriceE = condE_sell ? sellRowPrice : na

//--------------------------------------------------
// Halo layer
//--------------------------------------------------
float buyHaloPrice  = showHalo and absorptionBuy  ? buyRowPrice  : na
float sellHaloPrice = showHalo and absorptionSell ? sellRowPrice : na

plotshape(buyHaloPrice,  title = "Buying Absorption Halo",  style = shape.circle, location = location.absolute, color = buyHaloColor,  size = size.huge, force_overlay = true)
plotshape(sellHaloPrice, title = "Selling Absorption Halo", style = shape.circle, location = location.absolute, color = sellHaloColor, size = size.huge, force_overlay = true)

//--------------------------------------------------
// Main exact-price bubbles
//--------------------------------------------------
plotshape(buyPriceA,  title = "Buying Absorption Tiny",   style = shape.circle, location = location.absolute, color = buyCoreColor,  size = size.small,  force_overlay = true)
plotshape(buyPriceB,  title = "Buying Absorption Small",  style = shape.circle, location = location.absolute, color = buyCoreColor,  size = size.normal, force_overlay = true)
plotshape(buyPriceC,  title = "Buying Absorption Normal", style = shape.circle, location = location.absolute, color = buyCoreColor,  size = size.large,  force_overlay = true)
plotshape(buyPriceD,  title = "Buying Absorption Large",  style = shape.circle, location = location.absolute, color = buyCoreColor,  size = size.huge,   force_overlay = true)
plotshape(buyPriceE,  title = "Buying Absorption Huge",   style = shape.circle, location = location.absolute, color = color.white,   size = size.huge,   force_overlay = true)

plotshape(sellPriceA, title = "Selling Absorption Tiny",   style = shape.circle, location = location.absolute, color = sellCoreColor, size = size.small,  force_overlay = true)
plotshape(sellPriceB, title = "Selling Absorption Small",  style = shape.circle, location = location.absolute, color = sellCoreColor, size = size.normal, force_overlay = true)
plotshape(sellPriceC, title = "Selling Absorption Normal", style = shape.circle, location = location.absolute, color = sellCoreColor, size = size.large,  force_overlay = true)
plotshape(sellPriceD, title = "Selling Absorption Large",  style = shape.circle, location = location.absolute, color = sellCoreColor, size = size.huge,   force_overlay = true)
plotshape(sellPriceE, title = "Selling Absorption Huge",   style = shape.circle, location = location.absolute, color = color.white,   size = size.huge,   force_overlay = true)

//--------------------------------------------------
// Extra candle markers for visibility
//--------------------------------------------------
float buyTrianglePrice  = showTriangles and absorptionBuy  ? low  : na
float sellTrianglePrice = showTriangles and absorptionSell ? high : na

plotshape(buyTrianglePrice,  title = "Buying Absorption Triangle",  style = shape.triangleup,   location = location.absolute, color = buyCoreColor,  size = size.large, force_overlay = true)
plotshape(sellTrianglePrice, title = "Selling Absorption Triangle", style = shape.triangledown, location = location.absolute, color = sellCoreColor, size = size.large, force_overlay = true)

//--------------------------------------------------
// Stronger bar highlight
//--------------------------------------------------
color signalBarColor =
     highlightBars and absorptionBuy  ? color.new(color.lime, 0) :
     highlightBars and absorptionSell ? color.new(color.red, 0)  :
     na

barcolor(signalBarColor)

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(absorptionBuy,
     title = "Buying Absorption",
     message = "Footprint absorption detected: Buyers absorbed selling pressure at the lower wick")

alertcondition(absorptionSell,
     title = "Selling Absorption",
     message = "Footprint absorption detected: Sellers absorbed buying pressure at the upper wick")

alertcondition(absorptionBuy or absorptionSell,
     title = "Absorption (Any)",
     message = "Footprint absorption detected: Buying or Selling absorption event")

//--------------------------------------------------
// Data window
//--------------------------------------------------
plot(buyRowVol,    "Buy Wick Row Volume",    display = display.data_window)
plot(sellRowVol,   "Sell Wick Row Volume",   display = display.data_window)
plot(buyStrength,  "Buy Wick Strength",      display = display.data_window)
plot(sellStrength, "Sell Wick Strength",     display = display.data_window)
plot(buyRowPrice,  "Buy Wick Row Price",     display = display.data_window)
plot(sellRowPrice, "Sell Wick Row Price",    display = display.data_window)
````
