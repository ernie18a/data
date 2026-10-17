# BREAKOUT DEFENSE

- url: https://www.tradingview.com/script/wQDCbLDn-BREAKOUT-DEFENSE/
- type: indicator
- pine_id: PUB;14a6efc6905942799ed1e32ab8d0018f
- version: 1.0

## Description

BREAKOUT DEFENSE is designed to identify breakout levels that continue to hold after price moves beyond a previous candle’s high or low.

For a bullish setup, Candle 2 must close above Candle 1’s high. After the breakout, price must continue closing above that level while the indicator waits for two consecutive retest candles. 

Both retest candles must touch or trade through Candle 1’s high and still close back above it. When that happens, a horizontal line is drawn at Candle 1’s high.
For a bearish setup, Candle 2 must close below Candle 1’s low. Price must continue closing below that level until two consecutive retest candles appear. Both retest candles must touch or trade through Candle 1’s low and still close back below it. A horizontal line is then drawn at Candle 1’s low.

The two retest candles do not have to appear immediately after the breakout. They can occur several candles later, as long as they are consecutive and the breakout level has not been invalidated by a close back through it.

The Maximum Bars After Breakout setting controls how long the indicator will wait for the two-candle retest sequence.
This indicator can be useful for spotting breakout continuation, defended support and resistance, successful retests, and areas where price confirms acceptance beyond a previous level.

## Source Code

````pine
//@version=6
indicator(
     title="BREAKOUT DEFENSE",
     shorttitle="BREAKOUT DEFENSE",
     overlay=true,
     max_lines_count=500,
     max_bars_back=500
)

//====================================================================
// BREAKOUT DEFENSE
//====================================================================
//
// Candle 1 and Candle 2 MUST be consecutive.
//
// Candle 1 creates the breakout level.
//
// Candle 2 breaks that level with a CLOSE.
//
// After Candle 2, the indicator waits for
// TWO CONSECUTIVE retest candles.
//
// Those retest candles can happen later.
//
// Example:
//
// C1
// C2 = breakout
// C3 = anything
// C4 = anything
// C5 = anything
// C6 = retest #1
// C7 = retest #2
//
// VALID.
//
// IMPORTANT:
//
// While waiting for the retest pair:
//
// BULLISH:
// No candle may CLOSE back below Candle 1 HIGH.
//
// BEARISH:
// No candle may CLOSE back above Candle 1 LOW.
//
//====================================================================


//====================================================================
// SETTINGS
//====================================================================

maximumBarsAfterBreakout = input.int(
     20,
     title="Maximum Bars After Breakout",
     minval=2,
     maxval=200
)

showBullish = input.bool(
     true,
     title="Show Bullish Signals",
     display=display.none
)

showBearish = input.bool(
     true,
     title="Show Bearish Signals",
     display=display.none
)


//====================================================================
// LINE SETTINGS
//====================================================================

bullishColor = input.color(
     color.lime,
     title="Bullish Line Color",
     display=display.none
)

bearishColor = input.color(
     color.red,
     title="Bearish Line Color",
     display=display.none
)

lineWidth = input.int(
     2,
     title="Line Width",
     minval=1,
     maxval=5,
     display=display.none
)

lineStyleSetting = input.string(
     "Solid",
     title="Line Style",
     options=[
         "Solid",
         "Dashed",
         "Dotted"
     ],
     display=display.none
)

selectedLineStyle =
     lineStyleSetting == "Dashed" ?
     line.style_dashed :
     lineStyleSetting == "Dotted" ?
     line.style_dotted :
     line.style_solid


//====================================================================
// RETEST PAIR
//====================================================================
//
// Current candle = Retest #2
//
// Previous candle = Retest #1
//
// These two MUST be consecutive.
//====================================================================

retest1High =
     high[1]

retest1Low =
     low[1]

retest1Close =
     close[1]

retest2High =
     high

retest2Low =
     low

retest2Close =
     close


//====================================================================
// SIGNAL STORAGE
//====================================================================

bool bullishSignal = false
bool bearishSignal = false

float bullishLevel = na
float bearishLevel = na

int bullishCandle1Bar = na
int bearishCandle1Bar = na


//====================================================================
// PREVENT SAME ORIGINAL SETUP FROM PRINTING AGAIN
//====================================================================

var int lastBullishCandle1Bar = na
var int lastBearishCandle1Bar = na


//====================================================================
// SEARCH FOR CANDLE 1 + CANDLE 2
//====================================================================
//
// Candle 2 can be several bars behind
// the current retest pair.
//
// Candle 1 is ALWAYS exactly one candle
// before Candle 2.
//
//====================================================================

if barstate.isconfirmed

    for candle2Offset = 2 to maximumBarsAfterBreakout + 1

        candle1Offset =
             candle2Offset + 1

        if not na(close[candle1Offset])

            //========================================================
            // ORIGINAL CANDLE 1
            //========================================================

            candidateHigh =
                 high[candle1Offset]

            candidateLow =
                 low[candle1Offset]

            candidateCandle1Bar =
                 bar_index -
                 candle1Offset


            //========================================================
            // ORIGINAL CANDLE 2
            //========================================================

            candidateCandle2Close =
                 close[candle2Offset]


            //========================================================
            // BULLISH BREAKOUT
            //
            // Candle 2 CLOSES ABOVE Candle 1 HIGH.
            //========================================================

            bullishBreakout =
                 candidateCandle2Close >
                 candidateHigh


            //========================================================
            // BULLISH LEVEL MUST STAY DEFENDED
            //
            // Every candle AFTER Candle 2 and BEFORE
            // the retest pair must CLOSE ABOVE
            // Candle 1 HIGH.
            //
            // If one closes back below or at the level,
            // the breakout is invalid.
            //========================================================

            bool bullishLevelHeld = true

            if candle2Offset > 2

                for j = 2 to candle2Offset - 1

                    if close[j] <= candidateHigh

                        bullishLevelHeld := false


            //========================================================
            // BULLISH RETEST #1
            //
            // Candle LOW reaches Candle 1 HIGH.
            //
            // Candle CLOSE remains ABOVE Candle 1 HIGH.
            //========================================================

            bullishRetest1Touches =
                 retest1Low <= candidateHigh and
                 retest1High >= candidateHigh

            bullishRetest1ClosesAbove =
                 retest1Close >
                 candidateHigh


            //========================================================
            // BULLISH RETEST #2
            //
            // Immediately follows Retest #1.
            //
            // Candle LOW reaches Candle 1 HIGH.
            //
            // Candle CLOSE remains ABOVE Candle 1 HIGH.
            //========================================================

            bullishRetest2Touches =
                 retest2Low <= candidateHigh and
                 retest2High >= candidateHigh

            bullishRetest2ClosesAbove =
                 retest2Close >
                 candidateHigh


            //========================================================
            // PREVENT DUPLICATE BULLISH SETUP
            //========================================================

            bullishNotAlreadyUsed =
                 na(lastBullishCandle1Bar) or
                 candidateCandle1Bar != lastBullishCandle1Bar


            //========================================================
            // FINAL BULLISH BREAKOUT DEFENSE
            //========================================================

            validBullishSetup =
                 showBullish and
                 bullishBreakout and
                 bullishLevelHeld and
                 bullishRetest1Touches and
                 bullishRetest1ClosesAbove and
                 bullishRetest2Touches and
                 bullishRetest2ClosesAbove and
                 bullishNotAlreadyUsed


            //========================================================
            // BEARISH BREAKOUT
            //
            // Candle 2 CLOSES BELOW Candle 1 LOW.
            //========================================================

            bearishBreakout =
                 candidateCandle2Close <
                 candidateLow


            //========================================================
            // BEARISH LEVEL MUST STAY DEFENDED
            //
            // Every candle AFTER Candle 2 and BEFORE
            // the retest pair must CLOSE BELOW
            // Candle 1 LOW.
            //
            // If one closes back above or at the level,
            // the breakout is invalid.
            //========================================================

            bool bearishLevelHeld = true

            if candle2Offset > 2

                for j = 2 to candle2Offset - 1

                    if close[j] >= candidateLow

                        bearishLevelHeld := false


            //========================================================
            // BEARISH RETEST #1
            //
            // Candle HIGH reaches Candle 1 LOW.
            //
            // Candle CLOSE remains BELOW Candle 1 LOW.
            //========================================================

            bearishRetest1Touches =
                 retest1High >= candidateLow and
                 retest1Low <= candidateLow

            bearishRetest1ClosesBelow =
                 retest1Close <
                 candidateLow


            //========================================================
            // BEARISH RETEST #2
            //
            // Immediately follows Retest #1.
            //
            // Candle HIGH reaches Candle 1 LOW.
            //
            // Candle CLOSE remains BELOW Candle 1 LOW.
            //========================================================

            bearishRetest2Touches =
                 retest2High >= candidateLow and
                 retest2Low <= candidateLow

            bearishRetest2ClosesBelow =
                 retest2Close <
                 candidateLow


            //========================================================
            // PREVENT DUPLICATE BEARISH SETUP
            //========================================================

            bearishNotAlreadyUsed =
                 na(lastBearishCandle1Bar) or
                 candidateCandle1Bar != lastBearishCandle1Bar


            //========================================================
            // FINAL BEARISH BREAKOUT DEFENSE
            //========================================================

            validBearishSetup =
                 showBearish and
                 bearishBreakout and
                 bearishLevelHeld and
                 bearishRetest1Touches and
                 bearishRetest1ClosesBelow and
                 bearishRetest2Touches and
                 bearishRetest2ClosesBelow and
                 bearishNotAlreadyUsed


            //========================================================
            // SAVE NEAREST BULLISH SETUP
            //========================================================

            if validBullishSetup and
               not bullishSignal

                bullishSignal := true

                bullishLevel :=
                     candidateHigh

                bullishCandle1Bar :=
                     candidateCandle1Bar


            //========================================================
            // SAVE NEAREST BEARISH SETUP
            //========================================================

            if validBearishSetup and
               not bearishSignal

                bearishSignal := true

                bearishLevel :=
                     candidateLow

                bearishCandle1Bar :=
                     candidateCandle1Bar


            //========================================================
            // STOP SEARCHING IF BOTH SIDES FOUND
            //========================================================

            if bullishSignal and
               bearishSignal

                break


//====================================================================
// BULLISH LINE
//
// START:
// Original Candle 1
//
// PRICE:
// Candle 1 HIGH
//
// END:
// Second consecutive retest candle
//====================================================================

if bullishSignal and
   not na(bullishLevel) and
   not na(bullishCandle1Bar)

    line.new(
         x1=bullishCandle1Bar,
         y1=bullishLevel,

         x2=bar_index,
         y2=bullishLevel,

         xloc=xloc.bar_index,
         extend=extend.none,

         color=bullishColor,
         style=selectedLineStyle,
         width=lineWidth
     )

    lastBullishCandle1Bar :=
         bullishCandle1Bar


//====================================================================
// BEARISH LINE
//
// START:
// Original Candle 1
//
// PRICE:
// Candle 1 LOW
//
// END:
// Second consecutive retest candle
//====================================================================

if bearishSignal and
   not na(bearishLevel) and
   not na(bearishCandle1Bar)

    line.new(
         x1=bearishCandle1Bar,
         y1=bearishLevel,

         x2=bar_index,
         y2=bearishLevel,

         xloc=xloc.bar_index,
         extend=extend.none,

         color=bearishColor,
         style=selectedLineStyle,
         width=lineWidth
     )

    lastBearishCandle1Bar :=
         bearishCandle1Bar


//====================================================================
// ALERTS
//====================================================================

alertcondition(
     bullishSignal,
     title="Bullish Breakout Defense",
     message="Bullish Breakout Defense: price broke above Candle 1 high, held above the level, and two consecutive candles retested and defended it."
)

alertcondition(
     bearishSignal,
     title="Bearish Breakout Defense",
     message="Bearish Breakout Defense: price broke below Candle 1 low, held below the level, and two consecutive candles retested and defended it."
)
````
