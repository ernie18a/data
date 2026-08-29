<!-- tradingview-pine-id: PUB;2bc90ca3669f4848a904a09295a6a794 -->
<!-- tradingviewscripts-format: 1 -->
# Market Acceleration Model

Source: https://www.tradingview.com/script/rGgiHILM-Market-Acceleration-Model/

## Description

• MARKET ACCELERATION MODEL

The Market Acceleration Model (MAM) is designed to identify changes in the rate at which price is moving through the market.

Rather than measuring momentum candle-by-candle, MAM samples price across a defined number of candles, calculates a structural average, and compares the displacement between consecutive structural samples.

The objective is simple:

Is price movement accelerating upward, accelerating downward, or losing acceleration?

• WHAT DOES "ACCELERATION" MEAN?

MAM measures the change in structural displacement.

When consecutive structural samples begin separating by increasingly larger distances, the market is displaying expanding movement.

• Green = Upward Acceleration
Price is moving upward and the magnitude of that structural movement is increasing.

• Red = Downward Acceleration
Price is moving downward and the magnitude of that structural movement is increasing.

• Neutral = No Significant Acceleration
The change in structural displacement is not large enough to exceed the selected acceleration threshold.

This makes MAM different from a traditional momentum oscillator. It is not primarily asking whether price is moving up or down. It is asking whether the rate of structural price expansion is increasing or decreasing.

• HOW THE MODEL WORKS

MAM divides the chart into structural sampling intervals using the Loopback setting.

For example, with Loopback = 20:

• The first 20 candles are sampled.
• A structural average is calculated.
• The next 20 candles are sampled.
• A new structural average is calculated.
• The displacement between those structural averages is measured.
• That displacement is compared with the previous structural displacement.

The process then repeats across the chart.

This creates a structural sequence rather than reacting to every individual candle.

• CALIBRATING LOOPBACK

The most important setting is Loopback.

Loopback determines how many candles are grouped together before MAM creates a structural observation.

Lower Loopback = More Responsive

Lower values allow the model to react to shorter-term changes in price movement.

This is generally more appropriate for:

• Lower timeframes
• Intraday trading
• Short-term market structure
• Faster acceleration/deceleration changes

The tradeoff is increased sensitivity to market noise.

Higher Loopback = More Structural

Higher values require price movement to persist across a larger number of candles before the model recognizes a structural change.

This is generally more appropriate for:

• Higher timeframes
• Larger market swings
• Broader trend analysis
• Filtering short-term fluctuations

The tradeoff is that acceleration transitions will be recognized later.

• LTF vs MTF vs HTF CALIBRATION

There is no universal "correct" Loopback value.

The appropriate setting depends on the relationship between your chart timeframe and the structural movement you are attempting to measure.

For LTF analysis, use a relatively smaller Loopback if you want MAM to respond to internal market movement.

For MTF analysis, increase the Loopback so the model represents a larger intermediate structure rather than individual candle fluctuations.

For HTF analysis, larger aggregation intervals are generally preferable when the goal is to identify major expansion and contraction in the market.

A useful way to think about calibration is:

LTF → Internal Movement

MTF → Intermediate Structure

HTF → External / Major Structure

The exact values should be calibrated to the instrument and trading style rather than treated as universal defaults.

• TIMEFRAME-SPECIFIC CALIBRATION

When moving between timeframes, remember that Loopback is measured in candles, not minutes or hours.

For example, Loopback = 20 means:

• 20 candles on a 1-minute chart = approximately 20 minutes
• 20 candles on a 5-minute chart = approximately 100 minutes
• 20 candles on a 1-hour chart = approximately 20 hours
• 20 candles on a 4-hour chart = approximately 80 hours

Therefore, the same Loopback setting can represent dramatically different structural horizons depending on the chart timeframe.

If you change timeframe, reassess Loopback rather than assuming the same value will produce the same market structure.

• AVERAGE METHOD

The Average Method determines which price representation is used when calculating each structural sample.

Available methods:

• Close
• HL2
• HLC3
• OHLC4

Close places the greatest emphasis on where the market finished each candle.

HL2 uses the midpoint of the candle's high and low and provides a more range-oriented representation.

HLC3 incorporates the high, low, and close.

OHLC4 incorporates the complete OHLC structure.

For a cleaner structural representation, HL2 or HLC3 can be useful. For a close-oriented interpretation, Close may be preferable.

• ACCELERATION THRESHOLD

The Acceleration Threshold % controls how much the structural displacement must change before MAM recognizes meaningful acceleration.

Lower threshold:

• More signals
• More sensitivity
• Earlier recognition
• Greater exposure to noise

Higher threshold:

• Fewer signals
• Stronger confirmation
• Less sensitivity to minor changes
• Greater emphasis on meaningful expansion

If MAM appears too reactive, increase the threshold.

If MAM appears too slow or is ignoring useful acceleration phases, decrease the threshold.

• HOW TO THINK ABOUT THE COLORS

The colors should be interpreted as direction + acceleration, not simply bullish/bearish trend signals.

Green means upward price displacement is expanding.

Red means downward price displacement is expanding.

A market can therefore be moving upward while not displaying green acceleration if its upward displacement is contracting.

Likewise, a market can remain below a prior structural level while no longer displaying red acceleration if downward displacement is losing momentum.

This distinction is important.

MAM is designed to identify changes in the intensity of movement, not simply market direction.

• PRACTICAL CALIBRATION APPROACH

Rather than searching for a "perfect" setting, calibrate MAM according to the market behavior you want to observe.

Start with:

1. Choose the structural horizon.

Decide whether you want to measure internal LTF movement, intermediate MTF movement, or larger HTF movement.

2. Adjust Loopback.

Increase Loopback until the structural path represents the type of movement you actually care about.

3. Adjust the Acceleration Threshold.

Increase the threshold if there are too many insignificant color changes.

Decrease it if meaningful acceleration is being filtered out.

4. Test different Average Methods.

Compare Close, HL2, HLC3, and OHLC4 to determine which price representation best reflects the structure you are attempting to measure.

5. Calibrate per instrument.

Different markets have different volatility characteristics. A setting that works well on one instrument may be too sensitive or too slow on another.

• THE BIGGER IDEA

Think of MAM as a way of observing how the market is changing its rate of movement.

Consolidation can produce relatively small structural displacement.

Expansion produces larger structural displacement.

When expansion itself begins increasing, the market is accelerating.

When expansion begins weakening, the market is decelerating.

This makes the model useful as a contextual tool for studying:

• Expansion vs. contraction
• Trend development
• Momentum transitions
• Structural movement
• Breakout behavior
• Increasing or decreasing directional pressure

MAM IS NOT INTENDED TO BE A STANDALONE BUY/SELL SYSTEM.

It is best used as a market-condition and movement-intensity model, providing structural context that can be combined with price action, market structure, liquidity, supply/demand, or other forms of analysis.

• DISCLAIMER

MAM is an analytical tool and should not be interpreted as a guarantee of future price movement. No setting is universally optimal. Always calibrate the model to the instrument, timeframe, volatility environment, and type of market structure you are attempting to analyze.

---

## Source Code

````pine
// This Pine Script® code is subject to the terShift of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_Forex_Steward

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++ =======   JESUS IS KING   ======= +++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++|\/\/\/\/\/|++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++|          |++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++|__________|++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++|‾‾‾‾‾‾‾          ‾‾‾‾‾‾‾|+++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++|                        |+++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++|_______          _______|+++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|        |+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++|________|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//@version=6
indicator("Market Acceleration Model", shorttitle="MAM", overlay=true, max_lines_count=500)

//====================================================================
// INPUTS
//====================================================================

groupStructure = "Structural Sampling"

groupGuide = "Calibration Guide"

loopback = input.int(
     10,
     minval = 1,
     title = "Loopback (LTF: 5–10 | MTF: 15–25 | HTF: 30–50)",
     tooltip = "Number of candles in each structural sampling interval.",
     group = groupStructure)

averageMethod = input.string(
     "Close",
     title = "Average Method",
     options = ["Close", "HL2", "HLC3", "OHLC4"],
     tooltip = "Price source averaged across each structural interval.",
     group = groupStructure)

frequencyThreshold = input.float(
     20.0,
     minval = 0.0,
     step = 1.0,
     title = "Acceleration Threshold % (LTF: 10–15% | MTF: 15–25% | HTF: 20–35%,)",
     tooltip = "Minimum percentage increase in structural displacement required to classify acceleration.",
     group = groupStructure)

groupPath = "Structural Path"

showPath = input.bool(
     true,
     title = "Show Structural Path",
     group = groupPath)

pathWidth = input.int(
     3,
     minval = 1,
     maxval = 5,
     title = "Path Width",
     group = groupPath)

pathStyleInput = input.string(
     "Solid",
     title = "Path Style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupPath)

pathColor = input.color(
     color.white,
     title = "Neutral Path Color",
     group = groupPath)

bullColor = input.color(
     color.lime,
     title = "Upward Acceleration Color",
     group = groupPath)

bearColor = input.color(
     color.red,
     title = "Downward Acceleration Color",
     group = groupPath)

groupDisplay = "Display"

showSamples = input.bool(
     false,
     title = "Show Structural Points",
     group = groupDisplay)

showFrequencyLabels = input.bool(
     false,
     title = "Show Acceleration Labels",
     group = groupDisplay)

//====================================================================
// PATH STYLE
//====================================================================

pathStyle =
     pathStyleInput == "Dashed" ? line.style_dashed :
     pathStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid

//====================================================================
// SOURCE
//====================================================================

float source = switch averageMethod
    "Close" => close
    "HL2" => hl2
    "HLC3" => hlc3
    "OHLC4" => ohlc4

//====================================================================
// STRUCTURAL SAMPLING
//====================================================================
//
// Every X candles:
//
//     candle 1 ───────── candle X
//                 ↓
//              Average
//
// This creates a structural sequence:
//
//     Average 1 → Average 2 → Average 3 → ...
//
//====================================================================

bool sampleComplete =
     bar_index >= loopback - 1 and
     (bar_index + 1) % loopback == 0

float structuralAverage = na

if sampleComplete
    structuralAverage := ta.sma(source, loopback)

//====================================================================
// STRUCTURAL STATE
//====================================================================

var float previousAverage = na
var float previousDisplacement = na

var int previousSampleBar = na

var float currentDisplacement = na
var float frequencyChange = na
var float frequency = na

var int frequencyState = 0

//====================================================================
// PATH STATE
//====================================================================

var float previousPathPrice = na
var int previousPathBar = na

var array<line> pathLines = array.new_line()

//====================================================================
// PROCESS COMPLETED STRUCTURAL SAMPLE
//====================================================================

if sampleComplete and not na(structuralAverage)

    //----------------------------------------------------------------
    // First structural sample
    //----------------------------------------------------------------
    if na(previousAverage)

        previousAverage := structuralAverage

        previousSampleBar := bar_index

        previousPathPrice := structuralAverage
        previousPathBar := bar_index

    //----------------------------------------------------------------
    // Subsequent structural samples
    //----------------------------------------------------------------
    else

        //------------------------------------------------------------
        // Percentage displacement between structural averages.
        //
        // Positive = upward structural displacement
        // Negative = downward structural displacement
        //------------------------------------------------------------

        if previousAverage != 0

            currentDisplacement :=
                 ((structuralAverage - previousAverage) /
                  math.abs(previousAverage)) * 100.0

        //------------------------------------------------------------
        // ACCELERATION
        //
        // Acceleration measures whether the magnitude of structural
        // displacement is increasing or decreasing.
        //------------------------------------------------------------

        if not na(previousDisplacement) and
           previousDisplacement != 0 and
           not na(currentDisplacement)

            frequencyChange :=
                 ((math.abs(currentDisplacement) -
                   math.abs(previousDisplacement)) /
                  math.abs(previousDisplacement)) * 100.0

            //--------------------------------------------------------
            // Acceleration state
            //
            // +1 = displacement magnitude expanding
            //  0 = stable / below threshold
            // -1 = displacement magnitude contracting
            //--------------------------------------------------------

            if frequencyChange >= frequencyThreshold

                frequencyState := 1

            else if frequencyChange <= -frequencyThreshold

                frequencyState := -1

            else

                frequencyState := 0

        //------------------------------------------------------------
        // First displacement has no acceleration comparison yet.
        //------------------------------------------------------------
        else

            frequencyChange := na
            frequencyState := 0

        //------------------------------------------------------------
        // Frequency / acceleration magnitude.
        //------------------------------------------------------------

        frequency :=
             frequencyChange

        //============================================================
        // ACCELERATION DIRECTION
        //============================================================
        //
        // The important distinction:
        //
        // frequencyState tells us whether displacement magnitude
        // is expanding or contracting.
        //
        // currentDisplacement tells us the direction of that
        // displacement.
        //
        // Therefore:
        //
        // Positive displacement + expanding magnitude
        //     = UPWARD ACCELERATION
        //
        // Negative displacement + expanding magnitude
        //     = DOWNWARD ACCELERATION
        //
        //============================================================

        bool upwardAcceleration =
             frequencyState == 1 and
             currentDisplacement > 0

        bool downwardAcceleration =
             frequencyState == 1 and
             currentDisplacement < 0

        //------------------------------------------------------------
        // DRAW STRUCTURAL PATH
        //------------------------------------------------------------

        if showPath and not na(previousPathPrice)

            lineColor =
                 upwardAcceleration ? bullColor :
                 downwardAcceleration ? bearColor :
                 pathColor

            newLine = line.new(
                 x1 = previousPathBar,
                 y1 = previousPathPrice,
                 x2 = bar_index,
                 y2 = structuralAverage,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = lineColor,
                 style = pathStyle,
                 width = pathWidth)

            array.push(
                 pathLines,
                 newLine)

        //------------------------------------------------------------
        // STRUCTURAL POINT
        //------------------------------------------------------------

        if showSamples

            pointColor =
                 upwardAcceleration ? bullColor :
                 downwardAcceleration ? bearColor :
                 pathColor

            line.new(
                 x1 = bar_index - 2,
                 y1 = structuralAverage,
                 x2 = bar_index + 2,
                 y2 = structuralAverage,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = pointColor,
                 width = 2)

        //------------------------------------------------------------
        // OPTIONAL ACCELERATION LABEL
        //------------------------------------------------------------

        if showFrequencyLabels and not na(frequency)

            labelText =
                 upwardAcceleration ?
                     "↑ ACC " + str.tostring(math.abs(frequency), "#.##") + "%" :
                 downwardAcceleration ?
                     "↓ ACC " + str.tostring(math.abs(frequency), "#.##") + "%" :
                     "—"

            label.new(
                 x = bar_index,
                 y = structuralAverage,
                 text = labelText,
                 style = label.style_label_down,
                 color = color.new(color.black, 100),
                 textcolor =
                     upwardAcceleration ?
                         bullColor :
                     downwardAcceleration ?
                         bearColor :
                         pathColor,
                 size = size.tiny)

        //------------------------------------------------------------
        // UPDATE STRUCTURAL STATE
        //------------------------------------------------------------

        previousAverage :=
             structuralAverage

        previousDisplacement :=
             currentDisplacement

        previousSampleBar :=
             bar_index

        previousPathPrice :=
             structuralAverage

        previousPathBar :=
             bar_index

//====================================================================
// CURRENT STRUCTURAL VALUES
//====================================================================
//
// structuralAverage
// currentDisplacement
// frequency
// frequencyState
//
// frequencyState:
//
//     +1 = displacement expanding
//      0 = displacement stable
//     -1 = displacement contracting
//
//====================================================================

//====================================================================
// CURRENT ACCELERATION VALUE
//====================================================================

plot(
     na,
     title = "Acceleration Engine",
     display = display.none)
````
