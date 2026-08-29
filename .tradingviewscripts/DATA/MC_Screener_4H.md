<!-- tradingview-pine-id: PUB;7cf9a3fcd8844639a9e9d6e8b8aad66e -->
<!-- tradingviewscripts-format: 1 -->
# MC Screener 4H

Source: https://www.tradingview.com/script/4jGeQSkl-MC-Screener-4H/

## Description

This indicator is designed to work in combination with the indicator "MC Scanner PRO".

This indicator "MC Screener 4H shall only be marked as a favorite (by a star), but NOT added to the chart itself. 

The MC Screener 4H indicator is then used inside the Pine Screener to identify all assets/pairs in your watchlist (of choice) that have a current/fresh Manipulation Candle for a potential trade setup.

The other indicator "MC Scanner PRO" shows the Manipulation Candle on your chart (4h) for any asset you choose. Please see that indicator for further instructions.

---

## Source Code

````pine
//@version=6
indicator(
     title = "MC Screener 4H",
     shorttitle = "MC Screener 4H",
     timeframe = "240",
     timeframe_gaps = false
)

//=====================================================================
// INPUTS
//=====================================================================

int validForBars = input.int(
     defval = 3,
     title = "Fresh for number of 4H candles",
     minval = 1,
     maxval = 10,
     tooltip = "3 means the MC remains fresh for the latest closed 4H candle and the next two 4H candles."
)

//=====================================================================
// ORIGINAL STRICT MC DEFINITION
//
// The [1] offset means the signal is evaluated only on the latest
// fully closed 4H candle, not on the currently forming candle.
//=====================================================================

bool bullishMcClosed =
     close[1] > open[1] and
     low[1] < low[2] and
     high[1] > high[2] and
     close[1] > math.max(open[2], close[2])

bool bearishMcClosed =
     close[1] < open[1] and
     high[1] > high[2] and
     low[1] < low[2] and
     close[1] < math.min(open[2], close[2])

//=====================================================================
// SIGNAL AGE
//
// Age 0 = MC occurred on the latest fully closed 4H candle.
// Age 1 = one 4H candle has passed since confirmation.
//=====================================================================

int bullishAge = ta.barssince(bullishMcClosed)
int bearishAge = ta.barssince(bearishMcClosed)

bool bullishFresh =
     not na(bullishAge) and
     bullishAge < validForBars

bool bearishFresh =
     not na(bearishAge) and
     bearishAge < validForBars

//=====================================================================
// USE ONLY THE LATEST FRESH MC
//
// Direction:
//  1 = bullish
// -1 = bearish
//  0 = no fresh MC
//=====================================================================

int mcDirection =
     bullishFresh and bearishFresh ?
         bullishAge <= bearishAge ? 1 : -1 :
     bullishFresh ? 1 :
     bearishFresh ? -1 :
     0

bool freshMc = mcDirection != 0

int mcAge =
     mcDirection == 1 ? bullishAge :
     mcDirection == -1 ? bearishAge :
     na

//=====================================================================
// PINE SCREENER COLUMNS
//=====================================================================

// 1 = fresh MC
// 0 = no fresh MC

plot(
     freshMc ? 1 : 0,
     title = "Fresh MC"
)

// 1 = bullish MC
// -1 = bearish MC
// 0 = no fresh MC

plot(
     mcDirection,
     title = "Direction"
)

// 0 = latest closed 4H candle
// 1 = one 4H candle later
// 2 = two 4H candles later

plot(
     freshMc ? mcAge : na,
     title = "Age"
)
````
