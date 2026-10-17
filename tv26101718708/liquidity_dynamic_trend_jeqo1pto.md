# Liquidity Dynamic Trend

- url: https://www.tradingview.com/script/jeqo1PTO-Liquidity-Dynamic-Trend/
- type: indicator
- pine_id: PUB;715a5f1a6b5f41ef97aad577e8d502f8
- version: 1.0

## Description

Liquidity Dynamic Trend is designed to help traders read trend behavior through the interaction between price, a dynamic trend boundary, and liquidity sweep reactions.

Many trend-following tools mainly focus on identifying when the trend has already changed. This can be useful for direction filtering, but the signal may appear only after price has already moved away from the reaction area. Liquidity Dynamic Trend takes a different approach. Instead of treating the dynamic trend line only as a trend-change boundary, it also treats the active line as a moving support or resistance area where liquidity may be tested.

When the market is in an uptrend, the lower dynamic line can act as a moving support zone. When the market is in a downtrend, the upper dynamic line can act as a moving resistance zone. These areas are not used as simple touch levels. The indicator waits for price to sweep the active line with the wick, then checks whether a short candle-pair confirmation appears after that sweep.

This workflow is intended to highlight moments where price tests liquidity around the active trend boundary and then reacts back, instead of generating a signal only after the trend line has already changed direction.

The workflow of the indicator is:

1. Calculate a dynamic trend line based on price and volatility.
2. Identify the current trend state.
3. In an uptrend, display the active lower line as dynamic support.
4. In a downtrend, display the active upper line as dynamic resistance.
5. Wait for price to sweep the active line with the wick.
6. Check for a confirming candle pair after the sweep.
7. Display a triangle only when the liquidity sweep and candle-pair confirmation occur together.
8. Ignore simple trend-line direction changes as standalone signals.

The creative purpose of this indicator is to connect trend direction with liquidity behavior. The dynamic line is not only a visual trend filter. It also works as an adaptive area where price may hunt liquidity, trigger stops, or test the strength of the active trend before continuing or reacting.

Bullish signal logic:

A bullish triangle may appear when the market is in an uptrend, price sweeps the lower dynamic support line with the lower wick of the current or previous candle, and then a bearish-to-bullish candle pair confirms the reaction.

This may suggest that price has tested liquidity below the dynamic support area and then shown a buying response.

Bearish signal logic:

A bearish triangle may appear when the market is in a downtrend, price sweeps the upper dynamic resistance line with the upper wick of the current or previous candle, and then a bullish-to-bearish candle pair confirms the reaction.

This may suggest that price has tested liquidity above the dynamic resistance area and then shown a selling response.

Key features:

• Dynamic trend boundary that adapts to market volatility.
• Trend line interpreted as moving support or resistance.
• Liquidity sweep detection through wick interaction with the active line.
• Candle-pair confirmation after the sweep.
• Triangle-only signals for cleaner chart reading.
• No signal generated from a simple trend-line color or direction change.
• Designed to identify sweep-and-reaction areas around the active trend boundary.
• Optional trend highlighting and alert conditions.

How to use:

A bullish triangle appears below price when price sweeps the dynamic support line and confirms with a bearish-to-bullish candle pair.

A bearish triangle appears above price when price sweeps the dynamic resistance line and confirms with a bullish-to-bearish candle pair.

The signal should be treated as a liquidity-reaction warning, not as a standalone buy or sell system. Traders may combine it with market structure, support and resistance, higher timeframe trend context, liquidity zones, and candle behavior.

The signal may be more meaningful when it appears near an important market structure area or after a clear pullback into the dynamic trend boundary. In sideways or low-volatility conditions, price may sweep the dynamic line more frequently, so additional confirmation is recommended.

Important note:

Liquidity Dynamic Trend is intended for technical analysis and educational use. It does not predict future price movement and does not guarantee trading results. Market conditions, volatility, timeframe, and symbol behavior can affect signal quality. Users should always apply proper risk management and use additional confirmation before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrategyLAB_

//@version=6
indicator("Liquidity Dynamic Trend", overlay = true, format = format.price, precision = 2, max_labels_count = 500)

//====================
// INPUTS
//====================
railLen       = input.int(10, "Rail Volatility Length", minval = 1)
priceBase     = input.source(hl2, "Price Base")
railFactor    = input.float(3.0, "Rail Distance Factor", step = 0.1)
useWilderVol  = input.bool(true, "Use Wilder Volatility")
showSweepMark = input.bool(true, "Show Sweep Triangles")
showZone       = input.bool(true, "Show Trend Zone")

//====================
// VOLATILITY ENGINE
//====================
f_volatility(_len, _useWilder) =>
    trueMove = ta.tr(true)
    _useWilder ? ta.rma(trueMove, _len) : ta.sma(trueMove, _len)

//====================
// RAIL ENGINE
//====================
f_rail(_base, _vol, _factor) =>
    lowerBase = _base - _vol * _factor
    upperBase = _base + _vol * _factor

    var float lowerRail = na
    var float upperRail = na
    var int railState = 1

    oldLower = nz(lowerRail[1], lowerBase)
    oldUpper = nz(upperRail[1], upperBase)
    oldState = nz(railState[1], 1)

    lowerRail := close[1] > oldLower ? math.max(lowerBase, oldLower) : lowerBase
    upperRail := close[1] < oldUpper ? math.min(upperBase, oldUpper) : upperBase

    railState := oldState
    railState := oldState == -1 and close > oldUpper ? 1 : oldState == 1 and close < oldLower ? -1 : oldState

    activeRail = railState == 1 ? lowerRail : upperRail

    [activeRail, lowerRail, upperRail, railState]

//====================
// CALCULATE RAIL
//====================
railVol = f_volatility(railLen, useWilderVol)
[activeRail, supportRail, resistRail, trendSide] = f_rail(priceBase, railVol, railFactor)

//====================
// PLOT LINE
//====================
supportPlot = plot(trendSide == 1 ? supportRail : na, title = "Support Rail", color = color.green, linewidth = 1, style = plot.style_linebr)
resistPlot  = plot(trendSide == -1 ? resistRail : na, title = "Resistance Rail", color = color.red, linewidth = 1, style = plot.style_linebr)

midPlot = plot(ohlc4, title = "Mid Price", display = display.none)

greenFill = showZone and trendSide == 1 ? color.new(color.green, 88) : na
redFill   = showZone and trendSide == -1 ? color.new(color.red, 88) : na

fill(midPlot, supportPlot, title = "Support Zone", color = greenFill)
fill(midPlot, resistPlot, title = "Resistance Zone", color = redFill)

//====================
// CANDLE PAIR
//====================
bullNow = close > open
bearNow = close < open

bullPrev = close[1] > open[1]
bearPrev = close[1] < open[1]

buyPair = bearPrev and bullNow
sellPair = bullPrev and bearNow

//====================
// WICK AREA CHECK
//====================
lowerWickTopNow = math.min(open, close)
lowerWickTopPrev = math.min(open[1], close[1])

upperWickBottomNow = math.max(open, close)
upperWickBottomPrev = math.max(open[1], close[1])

supportSweepNow = trendSide == 1 and supportRail >= low and supportRail <= lowerWickTopNow
supportSweepPrev = trendSide[1] == 1 and supportRail[1] >= low[1] and supportRail[1] <= lowerWickTopPrev

resistSweepNow = trendSide == -1 and resistRail <= high and resistRail >= upperWickBottomNow
resistSweepPrev = trendSide[1] == -1 and resistRail[1] <= high[1] and resistRail[1] >= upperWickBottomPrev

//====================
// FINAL SIGNALS
//====================
buySweep = barstate.isconfirmed and buyPair and (supportSweepNow or supportSweepPrev)
sellSweep = barstate.isconfirmed and sellPair and (resistSweepNow or resistSweepPrev)

//====================
// TRIANGLES ONLY
//====================
plotshape(showSweepMark and buySweep, title = "Buy Sweep", location = location.belowbar, style = shape.triangleup, size = size.small, color = color.green)

plotshape(showSweepMark and sellSweep, title = "Sell Sweep", location = location.abovebar, style = shape.triangledown, size = size.small, color = color.red)

//====================
// ALERTS
//====================
alertcondition(buySweep, title = "Buy Sweep", message = "Buy Sweep: price swept dynamic support rail and confirmed with red-green candle pair.")

alertcondition(sellSweep, title = "Sell Sweep", message = "Sell Sweep: price swept dynamic resistance rail and confirmed with green-red candle pair.")

alertcondition(buySweep or sellSweep, title = "Any Wick Sweep", message = "Dynamic Rail Wick Sweep signal detected.")
````
