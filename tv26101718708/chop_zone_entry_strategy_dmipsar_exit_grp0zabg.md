# CHOP Zone Entry Strategy + DMI/PSAR Exit

- url: https://www.tradingview.com/script/GrP0zABg-CHOP-Zone-Entry-Strategy-DMI-PSAR-Exit/
- type: strategy
- pine_id: PUB;7iW42g0Byb9oPTYH10lHdtasNo2trr16
- version: 3.0

## Description

This is a Strategy with associated visual indicators and Long/Short and Reverse/Close Position Alerts for the [b]Choppiness Index (CHOP)[/b].  It is used to determine if the market is choppy (trading sideways) or not choppy (trading within a trend in either direction).  CHOP is not directional, so a DMI script was ported into this strategy to allow for trend confirmation and direction determination; it consists of an [b][i]Average Directional Index (ADX)[/i][/b], [b][i]Plus Directional Indicator (+DI)[/i][/b] and [b][i]Minus Directional Indicator (-DI)[/i][/b].  In addition, a [b][i]Parabolic SAR[/i][/b] is also included to act as a trailing stop during any strong trends.

[b]Development Notes[/b]
---------------------------
This indicator, and most of the descriptions below, were derived largely from the TradingView reference manual.  Feedback and suggestions for improvement are more than welcome, as well are recommended Input settings and best practices for use.

https://www.tradingview.com/support/solutions/43000501980-choppiness-index-chop/
https://www.tradingview.com/support/solutions/43000502250-directional-movement-dmi/
https://www.tradingview.com/support/solutions/43000502597-parabolic-sar-sar/

Recommend using the below DMI and PSAR indicators in conjunction with this script to fully visualize and understand how entry and exit conditions are chosen.  Variable inputs should correlate between the scripts for uniformity and visual compatibility.

https://www.tradingview.com/script/9OoEHrv5-Directional-Movement-Index-DMI-Alerts/
https://www.tradingview.com/script/MddD4giy-Parabolic-SAR/

[b]THANKS [/b]to LazyBear and his Momentum Squeeze script for helping me quickly develop a momentum state model for coloring the Chop line by trend.

[b]Strategy Description[/b]
---------------------------
CHOP produces values that [b][i]determine whether the market is choppy or trending[/i][/b].  The closer the value is to [b][i]100[/i][/b], the[b][i] higher the choppiness levels[/i][/b], while the [b][i]closer it is to 0[/i][/b], the stronger the [b][i]market is trending[/i][/b].  Territories for both levels, and their associated upper and lower thresholds, are popularly defined using the Fibonacci Retracements, 61.8 and 38.2.

[b]Basic Use[/b]
---------------------------
CHOP is often [b][i]used to confirm the market condition[/i][/b] to help you stay out of sideways markets and only enter when there is movement or imminent explosions.  When readings are above the upper threshold, continued sideways movement may be expected, while readings below the lower threshold are typically indicative of a continuing trend.  It is also used to anticipate upcoming trendiness changes, with the general belief that extended periods of consolidation (sideways movement) are followed by extended periods of strong, trending, directional movement, and vice versa.

One limitation in this index is that you must be cautious in deciding whether the range or trend will likely continue, or if it will reverse.

Confidence in price action and trend is higher when two or more indicators are in agreement -- while this strategy combines CHOP with both DMI and PSAR, we would still recommend pairing with other indicators to determine entry or exit trade opportunities.

Recommend also choosing 'Once Per Bar Close' when creating alerts.

[b]Inputs[/b]
---------------------------
[b]Strategy Direction[/b] - an option to only trade Short, Long, Both, or only in the direction of the Trend (Follow Trend is the Default).

[b]Sensitivity[/b] - an incremental variable to test whether the past n candles are in the same trend state before triggering a delayed long or short alert (1 is the Default).  Can help filter out noise and reduces active alerts.

[b]Show Chop Index[/b] - two visual styles are provided for user preference, a visible Chop line with a background overlay, or a compact column and label only view.

[b]Chop Lookback Period[/b] - the time period to be used in calculating CHOP (14 is the Default).

[b]Chop Offset[/b] - changing this number will move the CHOP either forwards or backwards relative to the current market (0 is the Default).

[b]Smooth Chop Line and Length[/b] - if enabled, the entered time period will be used in calculating a smooth average of the index (Enabled and 4 are the Defaults).

[b]Color Line to Trend Direction[/b] - toggles whether the index line is colored to visually depict the current trend direction (Enabled is the Default).

[b]Color Background[/b] - toggles the visibility of a background color based on the index state (Enabled is the Default).

[b]Enable DMI Option[/b] - if enabled, then entry will be confirmed by and dependent on the ADX Key Level, with any close or reversal confirmed by both ADX and +/-DI to determine whether there is a strong trend present or not (Enabled is the Default).  

[b]ADX Smoothing[/b] - the time period to be used in calculating the ADX which has a smoothing component (14 is the Default).

[b]DI Length[/b] - the time period to be used in calculating the DI (14 is the Default).

[b]ADX Key Level[/b] - any trade with the ADX above the key level is a strong indicator that it is trending (23 to 25 is the suggested setting).

[b]Enable PSAR Option[/b] - enables trailing stop loss orders (Enabled is the Default).

[b]PSAR Start[/b] - the starting value for the Acceleration Force (0.015 is our chosen Default, 0.02 is more common).

[b]PSAR Increment[/b] - the increment in which the Acceleration Force will move (0.001 is our chosen Default, 0.02 is more common).

[b]PSAR Max Value[/b] - the maximum value of the Acceleration Factor (0.2 is the Default).

[b]Color Candles Option[/b] - an option to transpose the CHOP condition levels to the main candle bars.  Note that the outer red and green border will still be distinguished by whether each individual candle is bearish or bullish during the specified timeframe.

Note too that if both DMI and PSAR are deselected, then close determinations will default to a CHOP reversal strategy (e.g., close long when below 38.2 and close short when above 61.8).  Though if either DMI or PSAR are enabled, then the CHOP reversal for close determination will automatically be disabled.

[b]Indicator Visuals[/b]
---------------------------
For the candle colors, black indicates tight chop (45 to 55), yellow is loose chop (38.2 to 45 and 55 to 61.8), dark purple is trending down (< 38.2), and dark blue is trending up (> 61.8).

The background color has additional shades to differentiate a wider range of more levels…
	• < 30 is dark purple
	• 30 to 38.2 is purple
	• 38.2 to 45 is light purple
	• 45 to 55 is black
	• 55 to 61.8 is light blue
	• 61.8 to 70 is blue
	• > 70 is dark blue

Long, Short, Close, and Reverse labels are plotted on the Chop line, which itself can be colored based on the trend.  The chop line can also be hidden for a clean and compact, columnar view, which is my preferred option (see example image below).

[image]https://www.tradingview.com/x/zCaiExsU/[/image]

Visual cues are intended to improve analysis and decrease interpretation time during trading, as well as to aid in understanding the purpose of this strategy and how its inclusion can benefit a comprehensive trading plan.

[b]DMI and Trend Strength[/b]
---------------------------
To analyze trend strength, the focus should be on the ADX line and not the +DI or -DI lines.   An [i]ADX reading above 25 indicates a strong trend[/i], while a [i]reading below 20 indicates a weak or non-existent trend[/i].  A reading between those two values would be considered indeterminable.  Though what is truly a strong trend or a weak trend depends on the financial instrument being examined; historical analysis can assist in determining appropriate values.

DMI exits trade when ADX is below the user selected key level (e.g., default is 25) and when the +/- DI lines cross (e.g., -DI > +DI exits long position and +DI > -DI exits short position).

[b]PSAR and Trailing Stop[/b]
---------------------------
PSAR is a time and price based indicator that excels at measuring direction and duration, though not the actual strength of a trend, which is why we use this in conjunction with DMI.  It is also included in this script as a trailing stop option to maximize gains during strong trends and to mitigate any false ADX strengthening signals.

This creates a parabola that is located below the candle during a Bullish trend and above during a Bearish trend.  A buy or reversal is signaled when the price crosses above or below the Parabolic SAR.

[b]Long/Short Entry[/b]
---------------------------
	1. CHOP must be over 61.8 (long) or under 38.2 (short).
	2. If DMI is enabled, then the ADX signal line must be above the user selected Key Level (default is 25).
	3. If Sensitivity is selected, then that past candle must meet the criteria in step 1, as well as all the intermediate candles in between.
	4. If "Follow Trend" is selected and PSAR is enabled, then a long position can only open when the momentum and PSAR are in an uptrend, or short when both are in a downtrend, to include all intermediate candles if the Sensitivity option is set on a past candle.

[b] Close/Reverse[/b]
---------------------------
	1. If DMI is enabled, then a close flag will be raised when the ADX signal drops below the Key Level (of 25), and -DI crosses over +DI (if long), or +DI crosses over -DI (if short).
	2. If PSAR is enabled, then a close flag will be raised when the current trend state is opposite the last state.
	3. If both DMI and PSAR are disabled, then a close flag will be raised if the Chop line drops under 38.2 (if long) or goes over 61.8 (if short).
	4. If a Long or Short Entry is triggered on the same candle as any of the above close flags, then the position will be reversed, else the position will be closed.

[b]Strategy Alerts[/b]
---------------------------
	1. Long Entry
	2. Short Entry
	3. Reverse
	4. Close

The provided backtest result is based on a position sizing of 10% equity with 100k initial capital.  When testing SPX, disabling the DMI performed the best, but EURUSD performed poorly without it enabled, and TSLA had a small reduction in net profit.  Timeframe likewise differed between commodities with TSLA performing best at 30M, SPX at 15M, and EURUSD at 4H.  I do not plan on using this as a standalone strategy, but I also was expecting better results with the inclusion of EMI and PSAR to compliment the CHOP.  Key elements of this script will likely be included in future, more holistic strategies.

[b]Disclaimer[/b]
---------------------------
Past performance may not be indicative of future results. Due to various factors, including changing market conditions, the strategy may no longer perform as well as in historical backtesting. This post and the script are not intended to provide any financial advice.  Trade at your own risk.

No known repainting, though there may be if an offset is introduced in the Inputs.  I did my best not to code any other variables that repaint, but cannot fully attest to this fact.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Title:    "CHOP Zone Entry Strategy + DMI/PSAR Exit"
// Revision: 1.2
// Author:   © IronCasper

//@version=4
strategy("CHOP Zone Entry Strategy + DMI/PSAR Exit", shorttitle="CHOP Zone Strategy", default_qty_value=1, overlay=false)


//-----------------------//
// Inputs                //
//-----------------------//

showChopAs = input(title="Show Chop Index as", defval="Colored Line (PSAR)", options=["Line", "Colored Line (MOM)", "Colored Line (PSAR)", "Columns"])
lookbackPeriod = input(14, title="Lookback Period", minval=1)
smoothLength = input(4, title="Smooth Length", minval=1)
offset = input(0, "Offset", type = input.integer, minval = -500, maxval = 500)

tradeType = input(title="Strategy Direction", defval="Follow Trend", options=["Short Only", "Long Only", "Both", "Follow Trend"])

sensitivity = input(title="Alert Sensitivity", type=input.integer, defval=1, minval=1, maxval=10)

colorBg = input(true, title="Color Background to CHOP State", type=input.bool)
colorBars = input(true, title="Color Candles to CHOP State", type=input.bool)

enableDMI = input(true, title="════ Enable Directional Movement Index ════", type=input.bool)
adxLen = input(14, title="ADX Smoothing")
diLen = input(14, title="DI Length")
adxKeyLevel = input(25, title="Key Level for ADX", type=input.integer, minval=1, maxval=100)

enablePSAR = input(true, title="════ Enable Parabolic Stop and Reverse ════", type=input.bool)
psarStart = input(defval=0.015, title="Start", type=input.float, step=0.015, minval=0)
psarIncr = input(defval=0.001, title="Increment", type=input.float, step=0.001, minval=0)
psarMax = input(defval=0.2, title="Max Value", type=input.float, step=0.2, minval=0)


//---------------------------------------------------------------------------------------//
// Calculate Chop                                                                        //
//  ... derived from TradingView Reference Manual                                        //
//      https://www.tradingview.com/support/solutions/43000501980-choppiness-index-chop  //
//---------------------------------------------------------------------------------------//

sumAtrOverLookback = sum(atr(1), lookbackPeriod) // sum of the Avg True Range over past n bars
maxHi = highest(high >= close[1] ? high : close[1], lookbackPeriod) // highest high over past n bars
minLo = lowest(low <= close[1] ? low : close[1], lookbackPeriod) // lowest low over past n bars

chopIndex = 100 * log10( sumAtrOverLookback / ( maxHi - minLo ) ) / log10(lookbackPeriod)

// Smooth (average) Chop Index if user selected option
chopIndex := sma(chopIndex, smoothLength) // a value of 1 has the same effect as disabiling the smooth feature


//----------------------------//
// Determine Chop conditions  //
//----------------------------//

condChopIndex38minus = chopIndex <= 38.2 and close[1] > close ? true : false // 38.2-
condChopIndex38to45  = chopIndex >= 38.2 and chopIndex < 45   ? true : false // 38.2 to 45
condChopIndex45to55  = chopIndex >= 45   and chopIndex < 55   ? true : false // 45 to 55
condChopIndex55to61  = chopIndex >= 55   and chopIndex < 61.8 ? true : false // 55 to 61.8
condChopIndex61plus  = chopIndex >= 61.8   and close[1] < close ? true : false // 61.8+

// Extra conditions for chop zone background color
condChopIndex30minus = chopIndex <= 30   and close[1] > close ? true : false // 30-
condChopIndex30to38  = chopIndex >  30   and chopIndex < 38.2 ? true : false // 30 to 38.2
condChopIndex61to70  = chopIndex >= 61.8 and chopIndex < 70   ? true : false // 61.8 to 70
condChopIndex70plus  = chopIndex >= 70   and close[1] < close ? true : false // 70+


//-----------------------------------------------------------//
// Compute Momentum State for Trend Line and Entry Determination     //
//-----------------------------------------------------------//

// Borrowed from script by LazyBear
val = linreg(close - avg(avg(highest(high, lookbackPeriod), lowest(low, lookbackPeriod)), ema(close, lookbackPeriod)), lookbackPeriod, 0)

// Determine Momenteum State
curr_momUpTrend = val > nz(val[1])
curr_momDnTrend = val < nz(val[1])

// Determine Momentum Line Color
momentumLineColor = curr_momUpTrend ? color.green : (curr_momDnTrend ? color.maroon : na)


//-----------------------------------------------------------------------//
// Calculate Parabolic SAR for Trend Line and Entry/Exit Determination   //
//-----------------------------------------------------------------------//

// Use built-in parabolic sar function
psar = sar(psarStart, psarIncr, psarMax)

// Determine psar trending state
psarTrendState = psar < close ? "up" : "dn"

// Determine PSAR Line Color
psarLineColor = psarTrendState == "up" ? color.green : (psarTrendState == "dn" ? color.maroon : na)


//------------------------------------------------------//
// Color Candles & Chop Index Line based on Chop State  //
//------------------------------------------------------//

// Create user defined chop limit
hli1 = hline(showChopAs != "Columns" ? 38.2 : na, linestyle=hline.style_dotted, editable=false) // Loose Chop Lower Limit
hli2 = hline(showChopAs != "Columns" ? 61.8 : na, linestyle=hline.style_dotted, editable=false) // Loose Chop Upper Limit

fill(hli1, hli2, color=color.yellow, transp=95, editable=false)

// Plot Chop Index Line
lineColor = showChopAs == "Colored Line (PSAR)" ? psarLineColor : (showChopAs == "Colored Line (MOM)" ? momentumLineColor : color.gray)
plot(showChopAs != "Columns" ? chopIndex : na, style=plot.style_linebr, linewidth=2, color=lineColor, offset=offset, editable=false)

// Plot bars to match chop state
var color candleColor = na
candleColor := condChopIndex38minus ? #800080      : candleColor // Short
candleColor := condChopIndex38to45  ? color.yellow : candleColor // Loose Chop
candleColor := condChopIndex45to55  ? #000000      : candleColor // Tight Chop
candleColor := condChopIndex55to61  ? color.yellow : candleColor // Loose Chop
candleColor := condChopIndex61plus  ? #0000FF      : candleColor // Long

barcolor(colorBars ? candleColor : na, editable=false)


//-----------------------//
// Plot Chop Zone        //
//-----------------------//

var color chopZoneColor = na
chopZoneColor := condChopIndex30minus ? #800080       : chopZoneColor // Dark Purple
chopZoneColor := condChopIndex30to38  ? color.purple  : chopZoneColor
chopZoneColor := condChopIndex38to45  ? color.yellow  : chopZoneColor
chopZoneColor := condChopIndex45to55  ? #000000       : chopZoneColor // Black
chopZoneColor := condChopIndex55to61  ? color.yellow  : chopZoneColor
chopZoneColor := condChopIndex61to70  ? color.blue    : chopZoneColor
chopZoneColor := condChopIndex70plus  ? #0000FF       : chopZoneColor // Dark Blue

// Plot columns vs bgcolor if Chop Index is not shown
plot(showChopAs == "Columns" ? 1 : na, color=chopZoneColor, style=plot.style_columns, transp=70, editable=false)

// Plot as bgcolor if selected in Line view
chopZoneColor := colorBg and showChopAs != "Columns" ? chopZoneColor : na
bgcolor(color=chopZoneColor, transp=80, editable=false)


//-----------------------------------------------------------------------------------------//
// Compute DMI                                                                             //
//  ... derived from TradingView Reference Manual                                          //
//      https://www.tradingview.com/chart/?solution=43000502250                            //
//                                                                                         //
// This is the same script as used in my DMI study                                         //
//    https://www.tradingview.com/script/9OoEHrv5-Directional-Movement-Index-DMI-Alerts    //
//-----------------------------------------------------------------------------------------//

// Part 1 - Calculate +DI and -DI
dirmov(diLen) =>

    // Determine Directional Movement
    upMove = change(high) // current high - previous high
    downMove = -change(low) // current low - previous low
    
    // Determine +DM and -DI by High, Low, and Close for each period
    plusDI = upMove > downMove and upMove > 0 ? upMove : 0
    minusDI = downMove > upMove and downMove > 0 ? downMove : 0
    
    // Update DM based on the number of user defined periods
    trueRange = ema(tr, diLen)
    plusDI := fixnan(100 * ema(plusDI, diLen) / trueRange)
    minusDI := fixnan(100 * ema(minusDI, diLen) / trueRange)
    
    [plusDI, minusDI] // Return

// Part 2 - Calculate ADX
adx(diLen, adxLen) =>

    [plusDI, minusDI] = dirmov(diLen)
    
    // Determine the ADX
    tmp = abs((plusDI - minusDI) / (plusDI + minusDI))
    adx = fixnan(100 * ema(tmp, adxLen))
	
	[adx, plusDI, minusDI] // Return

// Get ADX and DI from function
[adxSignal, plusDI, minusDI] = adx(diLen, adxLen)


//-------------------------------------------------------//
// Determine Trade State for Long/Short Entry            //
//-------------------------------------------------------//

// Establish long and short actions
goLong = condChopIndex61plus and not(condChopIndex61plus[sensitivity]) and (enableDMI ? adxSignal > adxKeyLevel : true)
goShort = condChopIndex38minus and not(condChopIndex38minus[sensitivity]) and (enableDMI ? adxSignal > adxKeyLevel : true)

// Increment to user selected sensitivity to only trigger actions on the n-th candle
if sensitivity != 1 and (goLong or goShort) // bypass if sensitivity equals one or no active go
    for i = 1 to sensitivity-1

        // Update long action based on past states
        if( condChopIndex61plus[i] != condChopIndex61plus )
            goLong := false
            //break // break loop if any candles aren't in a long state
            //bool(na) // required to trick compiler to return from loop
    
        // Update short action based on past states
        if( condChopIndex38minus[i] != condChopIndex38minus )
            goShort := false//, break, bool(na)

// Clear action if it doesn't follow the trend, if user selected
if tradeType == "Follow Trend"
    goLong := showChopAs == "Colored Line (Momentum)" ? (curr_momUpTrend ? goLong : na) : (psarTrendState == "up" ? goLong : na)
    goShort := showChopAs == "Colored Line (Momentum)" ? (curr_momDnTrend ? goShort : na) : (psarTrendState == "dn" ? goShort : na)


//-------------------------------------------------------//
// Determine Trade State for Exit and Reverse            //
//-------------------------------------------------------//

// Declare Active Position Identifiers
var bool activeLong = false
var bool activeShort = false

// Determine DMI Close Trade Action, if applicable
dmiCloseLong = enableDMI ? adxSignal < adxKeyLevel and minusDI > plusDI : false
dmiCloseShort = enableDMI ? adxSignal < adxKeyLevel and plusDI > minusDI : false

// Determine PSAR Close Trade Action, if applicable
psarCloseLong = enablePSAR ? psarTrendState == "dn" and psarTrendState[1] == "up" : false
psarCloseShort = enablePSAR ? psarTrendState == "up" and psarTrendState[1] == "dn" : false

// Determine Default Close Trade Action (Chop Index Reversal), if PSAR or DMI not selected
chopCloseLong = enablePSAR or enableDMI ? false : chopIndex < 38.2
chopCloseShort = enablePSAR or enableDMI ? false : chopIndex > 61.8

// Consolidate close actions to a single variable
closeLongState = activeLong and (psarCloseLong or dmiCloseLong or chopCloseLong or goShort)
closeShortState = activeShort and (psarCloseShort or dmiCloseShort or chopCloseShort or goLong)

// Determine if in a Reverse Position State
goReverse = (closeLongState and goShort) or (closeShortState and goLong) ? true : false

// Determine new close action based on reverse state
goClose = not(goReverse) and (closeLongState or closeShortState) ? true : false


//--------------------------------//
// Plot Entry and Exits           //
//--------------------------------//

// Determine User Selected Trade Types
longSelected = tradeType == "Both" or tradeType == "Follow Trend" ? true : tradeType == "Long Only" ? true : false
shortSelected = tradeType == "Both" or tradeType == "Follow Trend" ? true : tradeType == "Short Only" ? true : false
reverseAllowed = tradeType == "Both" or tradeType == "Follow Trend"

// Identify series for when plotting shapes at the absolute location
plotSeries = showChopAs != "Columns" ? chopIndex : 0

// Plot Long and Short Indicators only on first entering state (i.e., position not already active)
plotshape(not(activeLong) and longSelected and goLong and not(goReverse) ? plotSeries : na
     , style=shape.circle, location=location.absolute, size=size.tiny, color=color.lime, text="Long", title="Long")
plotshape(not(activeShort) and shortSelected and goShort and not(goReverse) ? plotSeries : na
     , style=shape.circle, location=location.absolute, size=size.tiny, color=color.red, text="Short", title="Short")

// Consolidate active actions to one variable
active = activeLong or activeShort

// Plot Close Indicator
plotshape(active and goClose ? plotSeries : na
     , style=shape.xcross, location=location.absolute, size=size.tiny, color=color.olive, text="Close", title="Close")

// Plot Reverse Indicator
plotshape(active and reverseAllowed and goReverse ? plotSeries : na
     , style=shape.diamond, location=location.absolute, size=size.tiny, color=color.blue, text="Reverse", title="Reverse")


//-------------------------------------//
// Chop Alerts + Strategy              //
//-------------------------------------//

// Create Long/Short/Close/Reverse Strategies with Custom Alert Messages
//  ... and log active long and short positions to prevent pyramiding before a close or reverse
if not(activeLong) and longSelected and goLong and not(goReverse)
    strategy.entry("Long", strategy.long, alert_message="Buy {{ticker}} from Chop Zone Strategy") // Open Long
    activeLong := true

if not(activeShort) and shortSelected and goShort and not(goReverse)
    strategy.entry("Short", strategy.short, alert_message="Sell {{ticker}} from Chop Zone Strategy") // Open Short
    activeShort := true
        
if active and reverseAllowed
    if goLong and goReverse
        strategy.entry("Long", strategy.long, alert_message="Reverse {{ticker}} from Chop Zone Strategy") // Reverse Short to Long
        activeLong := true
        activeShort := false
    if goShort and goReverse
        strategy.entry("Short", strategy.short, alert_message="Reverse {{ticker}} from Chop Zone Strategy") // Reverse Long to Short
        activeShort := true
        activeLong := false
 
strategy.close("Long", when = active and goClose, alert_message="Close {{ticker}} from Chop Zone Strategy") // Close Long
strategy.close("Short", when = active and goClose, alert_message="Close {{ticker}} from Chop Zone Strategy") // Close Short

if goClose
    activeLong := false
    activeShort := false
````
