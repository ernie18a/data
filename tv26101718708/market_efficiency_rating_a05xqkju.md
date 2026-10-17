# Market Efficiency Rating

- url: https://www.tradingview.com/script/A05XQkju-Market-Efficiency-Rating/
- type: indicator
- pine_id: PUB;d7865e0bd2d8419c9fb42821c3a5037c
- version: 3.0

## Description

[b]Market Efficiency Regime Indicator (Visible / Loopback Body Efficiency)[/b]

This indicator is designed to measure [b]market tradability by quantifying how efficiently price movement translates into structural expansion[/b]. In simple terms, it distinguishes between markets that are actively progressing in a directional way versus markets that are mostly rotating, overlapping, or consolidating.

The core output is an [b]Efficiency Rating[/b], which represents the proportion of candle-body activity that contributes to net structural expansion. Higher values indicate that more of the market’s movement is being converted into directional progress, while lower values indicate inefficient, choppy, or compressive conditions.

[b]Primary Purpose[/b]

The main function of this tool is to help traders determine:

• Whether a market is currently [b]tradable or non-tradable for trend-based strategies[/b]
• When market conditions are shifting between [b]consolidation and expansion regimes[/b]
• When to [b]engage or avoid participation[/b] based on structural efficiency

Rather than predicting direction, it focuses on identifying whether the environment is conducive to extracting profit efficiently.

[b]How to Interpret the Efficiency Rating[/b]

The efficiency score reflects how much of total movement is producing meaningful directional expansion:

• Low values → high overlap, consolidation, rotational price behavior
• Mid values → transitional or early expansion phases
• High values → strong directional efficiency and clean expansion

This allows traders to quickly assess whether price action is “working” in a way that supports their strategy.

[b]Calibration Using R-Multiple Expectations[/b]

A key feature of this indicator is that it can be calibrated based on the trader’s [b]preferred R-multiple outcomes[/b].

Instead of treating efficiency as an abstract number, it can be mapped to expected trade quality:

• If your strategy targets ~1R moves → calibrate “tradable threshold” around lower efficiency environments
• If your strategy targets ~2R moves → define “acceptable trading conditions” in moderate efficiency regimes
• If your strategy targets ~3–4R+ moves → focus only on high efficiency regimes where directional expansion dominates

This allows traders to align regime detection with their actual performance expectations rather than arbitrary thresholds.

Over time, traders can refine calibration by reviewing historical trades and identifying the efficiency levels that consistently produced their desired R-multiples. This turns the indicator into a [b]strategy-specific market filter rather than a generic metric[/b].

[b]Market Selection Use Case[/b]

Beyond simple regime filtering, this tool is designed for [b]relative market selection[/b].

Traders can compare:

• Different symbols (e.g., indices, forex pairs, crypto assets)
• Different timeframes on the same market
• Different sessions or time windows

The goal is to identify where capital is most efficiently being expressed at any given moment.

Higher efficiency readings across markets typically indicate:
• Stronger directional expansion
• Better follow-through potential
• Higher quality trade environments

This allows traders to focus only on the most favorable instruments at a specific time, rather than trading every market equally.

[b]Summary[/b]

This indicator is not designed to predict direction. It is designed to answer one critical question:

[b]“Is this market currently offering efficient conditions for extracting my desired R-multiple?”[/b]

By aligning efficiency readings with personal trade expectations and using it across multiple markets and timeframes, traders can build a structured framework for identifying high-quality opportunities and avoiding low-probability environments.

## Source Code

````pine
//@version=6
indicator("Market Efficiency Rating", overlay=true)

//====================================================
// INPUTS
//====================================================

note = input.int(1, "***Use Visible Range to calibrate efficiency thresholds using consolidated and trending markets. Use Loopback during live trading for continuous accuracy.***")

efficientValue = input.float(0.15, "Efficient Rating")
veryEfficientValue = input.float(0.25, "Very Efficient Rating")

useVisibleRange  = input.bool(false, "Use Visible Range Instead of Loopback")
loopbackBars = input.int(100, "Loopback Bars", minval=1, maxval=10000)

// TABLE POSITION
stablePositionInput = input.string(
     "Top Right",
     "Table Position",
     options = [
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ])

tablePosition =
     stablePositionInput == "Top Left" ? position.top_left :
     stablePositionInput == "Bottom Right" ? position.bottom_right :
     stablePositionInput == "Bottom Left" ? position.bottom_left :
     position.top_right

//====================================================
// TRANSITION DOT SETTINGS
//====================================================

showTransitionDots = input.bool(true, "Show Regime Transition Dots")

//====================================================
// VISIBLE RANGE
//====================================================

leftVisibleBarTime  = chart.left_visible_bar_time
rightVisibleBarTime = chart.right_visible_bar_time

maxBarsBack = math.min(bar_index, 10000)

//====================================================
// RANGE FUNCTION
//====================================================

f_inRange(_b) =>
    useVisibleRange ? (time[_b] >= leftVisibleBarTime and time[_b] <= rightVisibleBarTime) : (_b <= loopbackBars)

//====================================================
// CALCULATIONS
//====================================================

int candleCount = 0
float highestHigh = na
float lowestLow = na
float totalBodyMovement = 0.0

candleCount := 0
highestHigh := na
lowestLow := na
totalBodyMovement := 0.0

for b = 0 to maxBarsBack

    if f_inRange(b)

        candleCount += 1

        highestHigh := na(highestHigh) ? high[b] : math.max(highestHigh, high[b])
        lowestLow   := na(lowestLow)  ? low[b]  : math.min(lowestLow, low[b])

        // BODY-BASED MOVEMENT
        float candleBody = math.abs(close[b] - open[b])

        totalBodyMovement += candleBody

float rangeDiff = (not na(highestHigh) and not na(lowestLow)) ? (highestHigh - lowestLow) : na

//====================================================
// BODY EFFICIENCY METRIC
//====================================================

float efficiencyRating =
     (not na(rangeDiff) and totalBodyMovement != 0) ?
     (rangeDiff/totalBodyMovement) :
     na

//====================================================
// REGIME CLASSIFICATION
//====================================================

string regime = na
color regimeColor = color.gray
int regimeState = na

if not na(efficiencyRating)

    if efficiencyRating < efficientValue
        regime := "Inefficient"
        regimeColor := color.orange
        regimeState := 0

    else if efficiencyRating < veryEfficientValue
        regime := "Efficient"
        regimeColor := color.blue
        regimeState := 1

    else
        regime := "Highly Efficient"
        regimeColor := color.yellow
        regimeState := 2

//====================================================
// TRANSITION DETECTION
//====================================================

bool regimeTransition = ta.change(regimeState) != 0

plotshape(
     showTransitionDots and regimeTransition,
     title="Regime Transition",
     style=shape.circle,
     location=location.bottom,
     color=regimeColor,
     size=size.tiny)

//====================================================
// FIXED 0.00000 FORMATTER
//====================================================

f_5dec(x) =>
    na(x) ? "na" : str.tostring(x, "0.00000")

//====================================================
// TABLE
//====================================================

var table t = table.new(tablePosition, 2, 2, border_width=1)

if barstate.islast

    table.cell(t, 0, 0, "Regime", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, regime, text_color=color.white, bgcolor=regimeColor)

    table.cell(t, 0, 1, "Efficiency Rating", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 1, f_5dec(efficiencyRating), text_color=color.white, bgcolor=color.black)
````
