<!-- tradingview-pine-id: PUB;21499da08faf4c2aa5ce110d866ba123 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Divergences - Candle Iron Core

Source: https://www.tradingview.com/script/a8taS8TC-RSI-Divergences-Candle-Iron-Core/

## Description

RSI Divergences - Candle Iron Core expands the traditional Relative Strength Index by providing an objective and configurable framework for identifying three different categories of RSI divergence:

[*]Regular Divergence
[*]Hidden Divergence
[*]Exaggerated Divergence

Each divergence type can be enabled or disabled independently, allowing traders to display only the structures relevant to their analysis or all divergence types simultaneously.

The indicator preserves the traditional RSI calculation while expanding the divergence-detection logic beyond Regular Divergence.

RSI Calculation

The Relative Strength Index is a momentum oscillator that compares the magnitude of recent bullish and bearish price movements.

For each bar, the indicator compares the current Close with the previous Close.

Positive changes contribute to the bullish movement series.

Negative changes contribute to the bearish movement series using their absolute magnitude.

These movements are smoothed using Wilder's Moving Average (RMA) over the selected RSI Length.

The default RSI Length is 14 periods.

The Relative Strength is then calculated as:

RS = Average Bullish Movement / Average Bearish Movement

The RSI converts this relationship into a bounded scale between 0 and 100.

A higher RSI therefore indicates that bullish movements have had greater relative magnitude, while a lower RSI indicates greater relative bearish magnitude.

The traditional 70, 50 and 30 levels are visual reference levels and do not determine divergence detection.

Pivot Detection

Divergences are identified by comparing confirmed pivots in the RSI with the corresponding price highs or lows.

A Pivot Low represents a confirmed local minimum in the RSI.

A Pivot High represents a confirmed local maximum in the RSI.

By default, the indicator uses:

[*]Pivot Lookback Left: 5
[*]Pivot Lookback Right: 5

This means that a pivot is evaluated relative to five bars on each side.

Because bars to the right are required for confirmation, a pivot cannot be confirmed on the exact bar where it initially forms.

For example, with Pivot Lookback Right set to 5, the indicator requires five subsequent bars before confirming the pivot.

The divergence label is plotted back on the original pivot bar once confirmation becomes available.

The plotted pivot represents where the structure occurred. It does not represent the bar where the divergence first became available in real time.

Regular Bullish Divergence

A Regular Bullish Divergence is detected when:

Price forms a Lower Low while the RSI forms a Higher Low.

Price therefore reaches a new lower extreme, while the RSI does not confirm that move with a corresponding Lower Low.

This represents a loss of confirmation between price and bearish momentum.

Regular Bearish Divergence

A Regular Bearish Divergence is detected when:

Price forms a Higher High while the RSI forms a Lower High.

Price reaches a new higher extreme, while the RSI does not confirm that move with a corresponding Higher High.

This represents a loss of confirmation between price and bullish momentum.

Hidden Bullish Divergence

A Hidden Bullish Divergence is detected when:

Price forms a Higher Low while the RSI forms a Lower Low.

Price maintains a structurally higher low even though the RSI temporarily records a lower momentum low.

Hidden Bullish Divergence can be studied in the context of bullish trend continuation rather than exclusively as a reversal structure.

Hidden Bearish Divergence

A Hidden Bearish Divergence is detected when:

Price forms a Lower High while the RSI forms a Higher High.

Price maintains a structurally lower high even though the RSI temporarily produces a higher momentum high.

Hidden Bearish Divergence can be studied in the context of bearish trend continuation.

Exaggerated Bullish Divergence

An Exaggerated Bullish Divergence is detected when:

Price forms two approximately equal lows while the RSI forms a Higher Low.

Because two market lows are rarely mathematically identical, the indicator uses a configurable percentage tolerance to determine when two price lows can be considered approximately equal.

The default tolerance is:

Exaggerated Price Tolerance: 0.10%

For example, if two price lows differ by less than the configured tolerance, the indicator can classify them as approximately equal.

If the RSI simultaneously forms a Higher Low, the structure is classified as an Exaggerated Bullish Divergence.

Exaggerated Bearish Divergence

An Exaggerated Bearish Divergence is detected when:

Price forms two approximately equal highs while the RSI forms a Lower High.

If the difference between the two price highs remains within the configured percentage tolerance while the RSI forms a Lower High, the structure is classified as an Exaggerated Bearish Divergence.

Divergence Classification

The indicator separates Exaggerated Divergence from Regular and Hidden Divergence using the configured price tolerance.

When two price extremes fall within the Exaggerated Price Tolerance, they are treated as approximately equal.

This prevents the same comparison from being simultaneously classified as both an Exaggerated Divergence and another divergence category merely because one price extreme is mathematically a fraction higher or lower than the other.

Pivot Distance

The indicator also controls how far apart two RSI pivots may be before they can form a valid divergence.

Default values:

[*]Minimum Pivot Distance: 5 bars
[*]Maximum Pivot Distance: 60 bars

This limits divergence comparisons to pivots that fall within the configured distance range.

Both values are configurable.

Divergence Selection

Each divergence family can be independently enabled or disabled:

[*]Show Regular Divergences
[*]Show Hidden Divergences
[*]Show Exaggerated Divergences

All three categories can also remain enabled simultaneously.

The labels identify the specific structure detected:

[*]Regular Bull Div
[*]Regular Bear Div
[*]Hidden Bull Div
[*]Hidden Bear Div
[*]Exaggerated Bull Div
[*]Exaggerated Bear Div

Exaggerated Price Tolerance

The Exaggerated Price Tolerance determines the maximum percentage difference allowed between two price extremes for them to be treated as approximately equal.

A smaller tolerance requires the two price levels to be more similar.

A larger tolerance permits a wider difference between the two levels.

This parameter makes the definition of an approximately equal High or Low objective and configurable instead of relying exclusively on visual interpretation.

RSI Reference Levels

The traditional RSI levels are displayed as visual references:

[*]70 — Upper Band
[*]50 — Middle Band
[*]30 — Lower Band

These levels do not determine whether a divergence exists.

The divergence algorithm searches for confirmed RSI pivots independently of the 70, 50 and 30 levels.

Therefore, a valid divergence can occur above 70, below 30 or anywhere between those levels.

Important Interpretation Notes

A divergence represents a disagreement between price structure and RSI momentum.

It does not guarantee that price will reverse or continue in any particular direction.

Regular, Hidden and Exaggerated Divergences describe different relationships between price and momentum and should be evaluated within the broader market context and within objectively defined trading rules.

Confirmation and Historical Display

This indicator uses confirmed RSI pivots.

Because pivot confirmation requires bars to the right of the pivot, divergence signals become known only after the required confirmation bars have formed.

For example:

If Pivot Lookback Right = 5, the algorithm must receive five additional bars before it can confirm the earlier RSI pivot.

Once confirmed, the indicator displays the divergence on the historical bar where the pivot actually occurred.

The divergence label shows where the pivot occurred, not when the signal became available in real time.

Increasing Pivot Lookback Right requires more bars for confirmation and generally produces more selective pivot structures.

Reducing Pivot Lookback Right confirms pivots sooner and makes pivot detection more sensitive.

Original Functionality

The standard Relative Strength Index calculation is a classic technical-analysis calculation.

RSI Divergences - Candle Iron Core extends this foundation with a configurable divergence-classification framework.

The additional functionality includes:

[*]Regular Bullish and Bearish Divergence detection
[*]Hidden Bullish and Bearish Divergence detection
[*]Exaggerated Bullish and Bearish Divergence detection
[*]Independent visibility controls for each divergence family
[*]Configurable RSI pivot confirmation
[*]Configurable minimum and maximum pivot distance
[*]Objective percentage-based tolerance for approximately equal price extremes
[*]Mutually separated Exaggerated Divergence classification
[*]Descriptive labels identifying the detected divergence type

The purpose of the indicator is to provide a consistent and objective framework for studying multiple forms of RSI divergence from a single tool.

Divergence represents a relationship between price structure and momentum. It should not be interpreted as a guaranteed prediction of future price movement.

---

## Source Code

````pine
//@version=6
indicator(
     title = "RSI Divergences - Candle Iron Core",
     shorttitle = "CIC - RSI Divergences",
     format = format.price,
     precision = 2,
     timeframe = "",
     timeframe_gaps = true
)

//=====================================================================
// RSI SETTINGS
//=====================================================================

groupRSI = "RSI Settings"

rsiLengthInput = input.int(
     14,
     minval = 1,
     title = "RSI Length",
     group = groupRSI
)

rsiSourceInput = input.source(
     close,
     title = "Source",
     group = groupRSI
)

change = ta.change(rsiSourceInput)

up = ta.rma(
     math.max(change, 0),
     rsiLengthInput
)

down = ta.rma(
     -math.min(change, 0),
     rsiLengthInput
)

float rsi = na

if down == 0
    rsi := 100
else if up == 0
    rsi := 0
else
    rsi := 100 - (100 / (1 + up / down))

//=====================================================================
// RSI DISPLAY
//=====================================================================

rsiPlot = plot(
     rsi,
     title = "RSI",
     color = #7E57C2
)

rsiUpperBand = hline(
     70,
     title = "RSI Upper Band",
     color = #787B86
)

rsiMiddleBand = hline(
     50,
     title = "RSI Middle Band",
     color = color.new(#787B86, 50)
)

rsiLowerBand = hline(
     30,
     title = "RSI Lower Band",
     color = #787B86
)

fill(
     rsiUpperBand,
     rsiLowerBand,
     color = color.rgb(126, 87, 194, 90),
     title = "RSI Background Fill"
)

//=====================================================================
// DIVERGENCE SETTINGS
//=====================================================================

groupDiv = "Divergence Settings"

showRegular = input.bool(
     true,
     title = "Show Regular Divergences",
     group = groupDiv
)

showHidden = input.bool(
     true,
     title = "Show Hidden Divergences",
     group = groupDiv
)

showExaggerated = input.bool(
     true,
     title = "Show Exaggerated Divergences",
     group = groupDiv
)

lookbackLeft = input.int(
     5,
     minval = 1,
     title = "Pivot Lookback Left",
     group = groupDiv
)

lookbackRight = input.int(
     5,
     minval = 1,
     title = "Pivot Lookback Right",
     group = groupDiv
)

rangeLower = input.int(
     5,
     minval = 1,
     title = "Minimum Pivot Distance",
     group = groupDiv
)

rangeUpper = input.int(
     60,
     minval = 2,
     title = "Maximum Pivot Distance",
     group = groupDiv
)

priceTolerancePercent = input.float(
     0.10,
     minval = 0.0,
     step = 0.01,
     title = "Exaggerated Price Tolerance (%)",
     tooltip = "Maximum percentage difference allowed between two price highs or lows for them to be considered approximately equal.",
     group = groupDiv
)

//=====================================================================
// COLORS
//=====================================================================

groupColors = "Divergence Colors"

regularBullColor = input.color(
     color.green,
     "Regular Bullish",
     group = groupColors
)

regularBearColor = input.color(
     color.red,
     "Regular Bearish",
     group = groupColors
)

hiddenBullColor = input.color(
     color.aqua,
     "Hidden Bullish",
     group = groupColors
)

hiddenBearColor = input.color(
     color.orange,
     "Hidden Bearish",
     group = groupColors
)

exaggeratedBullColor = input.color(
     color.lime,
     "Exaggerated Bullish",
     group = groupColors
)

exaggeratedBearColor = input.color(
     color.fuchsia,
     "Exaggerated Bearish",
     group = groupColors
)

textColor = color.white
noneColor = color.new(color.white, 100)

//=====================================================================
// HELPER FUNCTIONS
//=====================================================================

_inRange(bool condition) =>
    bars = ta.barssince(condition)
    rangeLower <= bars and bars <= rangeUpper

_isApproximatelyEqual(float currentValue, float previousValue) =>
    bool equal = false

    if not na(currentValue) and not na(previousValue) and previousValue != 0
        differencePercent =
             math.abs(currentValue - previousValue) /
             math.abs(previousValue) *
             100

        equal := differencePercent <= priceTolerancePercent

    equal

//=====================================================================
// RSI PIVOTS
//=====================================================================

pivotLowFound =
     not na(
         ta.pivotlow(
             rsi,
             lookbackLeft,
             lookbackRight
         )
     )

pivotHighFound =
     not na(
         ta.pivothigh(
             rsi,
             lookbackLeft,
             lookbackRight
         )
     )

rsiPivotValue = rsi[lookbackRight]

priceLowAtPivot = low[lookbackRight]
priceHighAtPivot = high[lookbackRight]

//=====================================================================
// PREVIOUS RSI PIVOT LOW INFORMATION
//=====================================================================

previousRSILow =
     ta.valuewhen(
         pivotLowFound,
         rsiPivotValue,
         1
     )

previousPriceLow =
     ta.valuewhen(
         pivotLowFound,
         priceLowAtPivot,
         1
     )

lowPivotInRange =
     _inRange(
         pivotLowFound[1]
     )

//=====================================================================
// PREVIOUS RSI PIVOT HIGH INFORMATION
//=====================================================================

previousRSIHigh =
     ta.valuewhen(
         pivotHighFound,
         rsiPivotValue,
         1
     )

previousPriceHigh =
     ta.valuewhen(
         pivotHighFound,
         priceHighAtPivot,
         1
     )

highPivotInRange =
     _inRange(
         pivotHighFound[1]
     )

//=====================================================================
// PRICE FLAT CONDITIONS
// Used only for Exaggerated Divergence
//=====================================================================

flatLow =
     pivotLowFound and
     _isApproximatelyEqual(
         priceLowAtPivot,
         previousPriceLow
     )

flatHigh =
     pivotHighFound and
     _isApproximatelyEqual(
         priceHighAtPivot,
         previousPriceHigh
     )

//=====================================================================
// RSI STRUCTURE
//=====================================================================

// Current RSI Pivot Low > Previous RSI Pivot Low
rsiHigherLow =
     rsiPivotValue > previousRSILow

// Current RSI Pivot Low < Previous RSI Pivot Low
rsiLowerLow =
     rsiPivotValue < previousRSILow

// Current RSI Pivot High < Previous RSI Pivot High
rsiLowerHigh =
     rsiPivotValue < previousRSIHigh

// Current RSI Pivot High > Previous RSI Pivot High
rsiHigherHigh =
     rsiPivotValue > previousRSIHigh

//=====================================================================
// PRICE STRUCTURE AT RSI PIVOTS
//=====================================================================

priceLowerLow =
     priceLowAtPivot < previousPriceLow

priceHigherLow =
     priceLowAtPivot > previousPriceLow

priceHigherHigh =
     priceHighAtPivot > previousPriceHigh

priceLowerHigh =
     priceHighAtPivot < previousPriceHigh

//=====================================================================
// REGULAR BULLISH DIVERGENCE
//
// Price: Lower Low
// RSI:   Higher Low
//=====================================================================

regularBull =
     showRegular and
     pivotLowFound and
     lowPivotInRange and
     priceLowerLow and
     not flatLow and
     rsiHigherLow

//=====================================================================
// REGULAR BEARISH DIVERGENCE
//
// Price: Higher High
// RSI:   Lower High
//=====================================================================

regularBear =
     showRegular and
     pivotHighFound and
     highPivotInRange and
     priceHigherHigh and
     not flatHigh and
     rsiLowerHigh

//=====================================================================
// HIDDEN BULLISH DIVERGENCE
//
// Price: Higher Low
// RSI:   Lower Low
//=====================================================================

hiddenBull =
     showHidden and
     pivotLowFound and
     lowPivotInRange and
     priceHigherLow and
     not flatLow and
     rsiLowerLow

//=====================================================================
// HIDDEN BEARISH DIVERGENCE
//
// Price: Lower High
// RSI:   Higher High
//=====================================================================

hiddenBear =
     showHidden and
     pivotHighFound and
     highPivotInRange and
     priceLowerHigh and
     not flatHigh and
     rsiHigherHigh

//=====================================================================
// EXAGGERATED BULLISH DIVERGENCE
//
// Price: Approximately Equal Low
// RSI:   Higher Low
//=====================================================================

exaggeratedBull =
     showExaggerated and
     pivotLowFound and
     lowPivotInRange and
     flatLow and
     rsiHigherLow

//=====================================================================
// EXAGGERATED BEARISH DIVERGENCE
//
// Price: Approximately Equal High
// RSI:   Lower High
//=====================================================================

exaggeratedBear =
     showExaggerated and
     pivotHighFound and
     highPivotInRange and
     flatHigh and
     rsiLowerHigh

//=====================================================================
// REGULAR BULLISH PLOT
//=====================================================================

plot(
     pivotLowFound ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Regular Bullish Divergence Line",
     linewidth = 2,
     color = regularBull ? regularBullColor : noneColor
)

plotshape(
     regularBull ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Regular Bullish Divergence",
     text = "Regular\nBull Div",
     style = shape.labelup,
     location = location.absolute,
     color = regularBullColor,
     textcolor = textColor
)

//=====================================================================
// REGULAR BEARISH PLOT
//=====================================================================

plot(
     pivotHighFound ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Regular Bearish Divergence Line",
     linewidth = 2,
     color = regularBear ? regularBearColor : noneColor
)

plotshape(
     regularBear ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Regular Bearish Divergence",
     text = "Regular\nBear Div",
     style = shape.labeldown,
     location = location.absolute,
     color = regularBearColor,
     textcolor = textColor
)

//=====================================================================
// HIDDEN BULLISH PLOT
//=====================================================================

plot(
     pivotLowFound ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Hidden Bullish Divergence Line",
     linewidth = 2,
     color = hiddenBull ? hiddenBullColor : noneColor
)

plotshape(
     hiddenBull ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Hidden Bullish Divergence",
     text = "Hidden\nBull Div",
     style = shape.labelup,
     location = location.absolute,
     color = hiddenBullColor,
     textcolor = textColor
)

//=====================================================================
// HIDDEN BEARISH PLOT
//=====================================================================

plot(
     pivotHighFound ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Hidden Bearish Divergence Line",
     linewidth = 2,
     color = hiddenBear ? hiddenBearColor : noneColor
)

plotshape(
     hiddenBear ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Hidden Bearish Divergence",
     text = "Hidden\nBear Div",
     style = shape.labeldown,
     location = location.absolute,
     color = hiddenBearColor,
     textcolor = textColor
)

//=====================================================================
// EXAGGERATED BULLISH PLOT
//=====================================================================

plot(
     pivotLowFound ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Exaggerated Bullish Divergence Line",
     linewidth = 2,
     color = exaggeratedBull ? exaggeratedBullColor : noneColor
)

plotshape(
     exaggeratedBull ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Exaggerated Bullish Divergence",
     text = "Exaggerated\nBull Div",
     style = shape.labelup,
     location = location.absolute,
     color = exaggeratedBullColor,
     textcolor = textColor
)

//=====================================================================
// EXAGGERATED BEARISH PLOT
//=====================================================================

plot(
     pivotHighFound ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Exaggerated Bearish Divergence Line",
     linewidth = 2,
     color = exaggeratedBear ? exaggeratedBearColor : noneColor
)

plotshape(
     exaggeratedBear ? rsiPivotValue : na,
     offset = -lookbackRight,
     title = "Exaggerated Bearish Divergence",
     text = "Exaggerated\nBear Div",
     style = shape.labeldown,
     location = location.absolute,
     color = exaggeratedBearColor,
     textcolor = textColor
)

//=====================================================================
// ALERTS
//=====================================================================

alertcondition(
     regularBull,
     title = "Regular Bullish Divergence",
     message = "Regular Bullish Divergence detected."
)

alertcondition(
     regularBear,
     title = "Regular Bearish Divergence",
     message = "Regular Bearish Divergence detected."
)

alertcondition(
     hiddenBull,
     title = "Hidden Bullish Divergence",
     message = "Hidden Bullish Divergence detected."
)

alertcondition(
     hiddenBear,
     title = "Hidden Bearish Divergence",
     message = "Hidden Bearish Divergence detected."
)

alertcondition(
     exaggeratedBull,
     title = "Exaggerated Bullish Divergence",
     message = "Exaggerated Bullish Divergence detected."
)

alertcondition(
     exaggeratedBear,
     title = "Exaggerated Bearish Divergence",
     message = "Exaggerated Bearish Divergence detected."
)
````
