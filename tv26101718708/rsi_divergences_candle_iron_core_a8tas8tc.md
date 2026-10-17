# RSI Divergences - Candle Iron Core

- url: https://www.tradingview.com/script/a8taS8TC-RSI-Divergences-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;21499da08faf4c2aa5ce110d866ba123
- version: 2.0

## Description

[b]RSI Divergences - Candle Iron Core[/b] expands the traditional Relative Strength Index by providing an objective and configurable framework for identifying three different categories of RSI divergence:

[list]
[*]Regular Divergence
[*]Hidden Divergence
[*]Exaggerated Divergence
[/list]

Each divergence type can be enabled or disabled independently, allowing traders to display only the structures relevant to their analysis or all divergence types simultaneously.

The indicator preserves the traditional RSI calculation while expanding the divergence-detection logic beyond Regular Divergence.


[b]RSI Calculation[/b]

The Relative Strength Index is a momentum oscillator that compares the magnitude of recent bullish and bearish price movements.

For each bar, the indicator compares the current Close with the previous Close.

Positive changes contribute to the bullish movement series.

Negative changes contribute to the bearish movement series using their absolute magnitude.

These movements are smoothed using Wilder's Moving Average (RMA) over the selected RSI Length.

The default RSI Length is 14 periods.

The Relative Strength is then calculated as:

[b]RS = Average Bullish Movement / Average Bearish Movement[/b]

The RSI converts this relationship into a bounded scale between 0 and 100.

A higher RSI therefore indicates that bullish movements have had greater relative magnitude, while a lower RSI indicates greater relative bearish magnitude.

The traditional 70, 50 and 30 levels are visual reference levels and do not determine divergence detection.


[b]Pivot Detection[/b]

Divergences are identified by comparing confirmed pivots in the RSI with the corresponding price highs or lows.

A [b]Pivot Low[/b] represents a confirmed local minimum in the RSI.

A [b]Pivot High[/b] represents a confirmed local maximum in the RSI.

By default, the indicator uses:

[list]
[*][b]Pivot Lookback Left: 5[/b]
[*][b]Pivot Lookback Right: 5[/b]
[/list]

This means that a pivot is evaluated relative to five bars on each side.

Because bars to the right are required for confirmation, a pivot cannot be confirmed on the exact bar where it initially forms.

For example, with Pivot Lookback Right set to 5, the indicator requires five subsequent bars before confirming the pivot.

The divergence label is plotted back on the original pivot bar once confirmation becomes available.

[quote]
The plotted pivot represents where the structure occurred. It does not represent the bar where the divergence first became available in real time.
[/quote]


[b]Regular Bullish Divergence[/b]

A Regular Bullish Divergence is detected when:

[b]Price forms a Lower Low while the RSI forms a Higher Low.[/b]

Price therefore reaches a new lower extreme, while the RSI does not confirm that move with a corresponding Lower Low.

This represents a loss of confirmation between price and bearish momentum.


[b]Regular Bearish Divergence[/b]

A Regular Bearish Divergence is detected when:

[b]Price forms a Higher High while the RSI forms a Lower High.[/b]

Price reaches a new higher extreme, while the RSI does not confirm that move with a corresponding Higher High.

This represents a loss of confirmation between price and bullish momentum.


[b]Hidden Bullish Divergence[/b]

A Hidden Bullish Divergence is detected when:

[b]Price forms a Higher Low while the RSI forms a Lower Low.[/b]

Price maintains a structurally higher low even though the RSI temporarily records a lower momentum low.

Hidden Bullish Divergence can be studied in the context of bullish trend continuation rather than exclusively as a reversal structure.


[b]Hidden Bearish Divergence[/b]

A Hidden Bearish Divergence is detected when:

[b]Price forms a Lower High while the RSI forms a Higher High.[/b]

Price maintains a structurally lower high even though the RSI temporarily produces a higher momentum high.

Hidden Bearish Divergence can be studied in the context of bearish trend continuation.


[b]Exaggerated Bullish Divergence[/b]

An Exaggerated Bullish Divergence is detected when:

[b]Price forms two approximately equal lows while the RSI forms a Higher Low.[/b]

Because two market lows are rarely mathematically identical, the indicator uses a configurable percentage tolerance to determine when two price lows can be considered approximately equal.

The default tolerance is:

[b]Exaggerated Price Tolerance: 0.10%[/b]

For example, if two price lows differ by less than the configured tolerance, the indicator can classify them as approximately equal.

If the RSI simultaneously forms a Higher Low, the structure is classified as an Exaggerated Bullish Divergence.


[b]Exaggerated Bearish Divergence[/b]

An Exaggerated Bearish Divergence is detected when:

[b]Price forms two approximately equal highs while the RSI forms a Lower High.[/b]

If the difference between the two price highs remains within the configured percentage tolerance while the RSI forms a Lower High, the structure is classified as an Exaggerated Bearish Divergence.


[b]Divergence Classification[/b]

The indicator separates Exaggerated Divergence from Regular and Hidden Divergence using the configured price tolerance.

When two price extremes fall within the Exaggerated Price Tolerance, they are treated as approximately equal.

This prevents the same comparison from being simultaneously classified as both an Exaggerated Divergence and another divergence category merely because one price extreme is mathematically a fraction higher or lower than the other.


[b]Pivot Distance[/b]

The indicator also controls how far apart two RSI pivots may be before they can form a valid divergence.

Default values:

[list]
[*][b]Minimum Pivot Distance: 5 bars[/b]
[*][b]Maximum Pivot Distance: 60 bars[/b]
[/list]

This limits divergence comparisons to pivots that fall within the configured distance range.

Both values are configurable.


[b]Divergence Selection[/b]

Each divergence family can be independently enabled or disabled:

[list]
[*]Show Regular Divergences
[*]Show Hidden Divergences
[*]Show Exaggerated Divergences
[/list]

All three categories can also remain enabled simultaneously.

The labels identify the specific structure detected:

[list]
[*]Regular Bull Div
[*]Regular Bear Div
[*]Hidden Bull Div
[*]Hidden Bear Div
[*]Exaggerated Bull Div
[*]Exaggerated Bear Div
[/list]


[b]Exaggerated Price Tolerance[/b]

The Exaggerated Price Tolerance determines the maximum percentage difference allowed between two price extremes for them to be treated as approximately equal.

A smaller tolerance requires the two price levels to be more similar.

A larger tolerance permits a wider difference between the two levels.

This parameter makes the definition of an approximately equal High or Low objective and configurable instead of relying exclusively on visual interpretation.


[b]RSI Reference Levels[/b]

The traditional RSI levels are displayed as visual references:

[list]
[*][b]70 — Upper Band[/b]
[*][b]50 — Middle Band[/b]
[*][b]30 — Lower Band[/b]
[/list]

These levels do not determine whether a divergence exists.

The divergence algorithm searches for confirmed RSI pivots independently of the 70, 50 and 30 levels.

Therefore, a valid divergence can occur above 70, below 30 or anywhere between those levels.


[b]Important Interpretation Notes[/b]

A divergence represents a disagreement between price structure and RSI momentum.

It does not guarantee that price will reverse or continue in any particular direction.

Regular, Hidden and Exaggerated Divergences describe different relationships between price and momentum and should be evaluated within the broader market context and within objectively defined trading rules.


[b]Confirmation and Historical Display[/b]

This indicator uses confirmed RSI pivots.

Because pivot confirmation requires bars to the right of the pivot, divergence signals become known only after the required confirmation bars have formed.

For example:

If [b]Pivot Lookback Right = 5[/b], the algorithm must receive five additional bars before it can confirm the earlier RSI pivot.

Once confirmed, the indicator displays the divergence on the historical bar where the pivot actually occurred.

[quote]
The divergence label shows where the pivot occurred, not when the signal became available in real time.
[/quote]

Increasing Pivot Lookback Right requires more bars for confirmation and generally produces more selective pivot structures.

Reducing Pivot Lookback Right confirms pivots sooner and makes pivot detection more sensitive.


[b]Original Functionality[/b]

The standard Relative Strength Index calculation is a classic technical-analysis calculation.

RSI Divergences - Candle Iron Core extends this foundation with a configurable divergence-classification framework.

The additional functionality includes:

[list]
[*]Regular Bullish and Bearish Divergence detection
[*]Hidden Bullish and Bearish Divergence detection
[*]Exaggerated Bullish and Bearish Divergence detection
[*]Independent visibility controls for each divergence family
[*]Configurable RSI pivot confirmation
[*]Configurable minimum and maximum pivot distance
[*]Objective percentage-based tolerance for approximately equal price extremes
[*]Mutually separated Exaggerated Divergence classification
[*]Descriptive labels identifying the detected divergence type
[/list]

The purpose of the indicator is to provide a consistent and objective framework for studying multiple forms of RSI divergence from a single tool.


[i]Divergence represents a relationship between price structure and momentum. It should not be interpreted as a guaranteed prediction of future price movement.[/i]

## Source Code

````pine
//@version=6
indicator(
     title = "RSI Divergences - Candle Iron Core",
     shorttitle = "CIC - RSI Divergences",
     format = format.price,
     precision = 2,
     max_lines_count = 500
)

//=====================================================================
// RSI SETTINGS
//=====================================================================

groupRSI = "RSI Settings"

rsiLengthInput = input.int(14, minval = 1, title = "RSI Length", group = groupRSI)
rsiSourceInput = input.source(close, title = "Source", group = groupRSI)

change = ta.change(rsiSourceInput)
up     = ta.rma(math.max(change, 0), rsiLengthInput)
down   = ta.rma(-math.min(change, 0), rsiLengthInput)

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

plot(rsi, title = "RSI", color = #7E57C2)

rsiUpperBand  = hline(70, title = "RSI Upper Band",  color = #787B86)
rsiMiddleBand = hline(50, title = "RSI Middle Band", color = color.new(#787B86, 50))
rsiLowerBand  = hline(30, title = "RSI Lower Band",  color = #787B86)

fill(rsiUpperBand, rsiLowerBand, color = color.rgb(126, 87, 194, 90), title = "RSI Background Fill")

//=====================================================================
// DIVERGENCE SETTINGS
//=====================================================================

groupDiv = "Divergence Settings"

showRegular     = input.bool(true, title = "Show Regular Divergences",     group = groupDiv)
showHidden      = input.bool(true, title = "Show Hidden Divergences",      group = groupDiv)
showExaggerated = input.bool(true, title = "Show Exaggerated Divergences", group = groupDiv)

lookbackLeft = input.int(5, minval = 1, title = "Pivot Lookback Left", group = groupDiv)

lookbackRight = input.int(
     5,
     minval = 1,
     title = "Pivot Lookback Right",
     tooltip = "Number of bars to the right required to confirm a pivot. With Early Signals disabled, this also confirms the signal. With Early Signals enabled, it only defines the strict reference pivots that the signal is compared against.",
     group = groupDiv
)

useEarlySignals = input.bool(
     false,
     title = "Early Signals",
     tooltip = "Disabled (default): the signal is confirmed using the same number of bars as Pivot Lookback Right (less noise, later signals). Enabled: the signal is confirmed using Early Signal Confirmation Bars (earlier signals, more signals, more noise). Reference pivots always use Pivot Lookback Right.",
     group = groupDiv
)

earlyRightInput = input.int(
     3,
     minval = 1,
     title = "Early Signal Confirmation Bars",
     tooltip = "Only applies when Early Signals is enabled. Number of bars to the right required to confirm the signal pivot. 1 = the signal appears on the bar right after the RSI peak or trough. If the value is greater than Pivot Lookback Right, it is capped at that value.",
     group = groupDiv
)

// Number of confirmation bars actually used for the signal
signalRight = useEarlySignals ? math.min(earlyRightInput, lookbackRight) : lookbackRight

rangeLower = input.int(5,  minval = 1, title = "Minimum Pivot Distance", group = groupDiv)
rangeUpper = input.int(60, minval = 2, title = "Maximum Pivot Distance", group = groupDiv)

priceTolerancePercent = input.float(
     0.10,
     minval = 0.0,
     step = 0.01,
     title = "Exaggerated Price Tolerance (%)",
     tooltip = "Maximum percentage difference allowed between two price highs or lows for them to be considered approximately equal.",
     group = groupDiv
)

alertOnClose = input.bool(
     true,
     title = "Alerts only on bar close",
     tooltip = "Avoids false alerts caused by repainting: the alert fires only when the signal bar closes.",
     group = groupDiv
)

//=====================================================================
// COLORS
//=====================================================================

groupColors = "Divergence Colors"

regularBullColor     = input.color(color.green,   "Regular Bullish",     group = groupColors)
regularBearColor     = input.color(color.red,     "Regular Bearish",     group = groupColors)
hiddenBullColor      = input.color(color.aqua,    "Hidden Bullish",      group = groupColors)
hiddenBearColor      = input.color(color.orange,  "Hidden Bearish",      group = groupColors)
exaggeratedBullColor = input.color(color.lime,    "Exaggerated Bullish", group = groupColors)
exaggeratedBearColor = input.color(color.fuchsia, "Exaggerated Bearish", group = groupColors)

textColor = color.white

//=====================================================================
// HELPER FUNCTIONS
//=====================================================================

_isApproximatelyEqual(float currentValue, float previousValue) =>
    bool equal = false

    if not na(currentValue) and not na(previousValue) and previousValue != 0
        differencePercent = math.abs(currentValue - previousValue) / math.abs(previousValue) * 100
        equal := differencePercent <= priceTolerancePercent

    equal

//=====================================================================
// SIGNAL PIVOTS (Left / signalRight)
//=====================================================================

pivotLowFound  = not na(ta.pivotlow(rsi, lookbackLeft, signalRight))
pivotHighFound = not na(ta.pivothigh(rsi, lookbackLeft, signalRight))

rsiPivotValue    = rsi[signalRight]
priceLowAtPivot  = low[signalRight]
priceHighAtPivot = high[signalRight]
pivotBarIndex    = bar_index - signalRight

//=====================================================================
// REFERENCE PIVOTS (STRICT: Left / lookbackRight)
// Stored in persistent variables and updated AT THE END
// of the script, so the signal compares against the previous pivot.
//=====================================================================

refPivotLowValue  = ta.pivotlow(rsi, lookbackLeft, lookbackRight)
refPivotHighValue = ta.pivothigh(rsi, lookbackLeft, lookbackRight)

var int   refLowBar    = na
var float refRSILow    = na
var float refPriceLow  = na
var int   refHighBar   = na
var float refRSIHigh   = na
var float refPriceHigh = na

previousRSILow    = refRSILow
previousPriceLow  = refPriceLow
previousRSIHigh   = refRSIHigh
previousPriceHigh = refPriceHigh

lowDist  = pivotBarIndex - refLowBar
highDist = pivotBarIndex - refHighBar

lowPivotInRange  = not na(refLowBar)  and lowDist  >= rangeLower and lowDist  <= rangeUpper
highPivotInRange = not na(refHighBar) and highDist >= rangeLower and highDist <= rangeUpper

//=====================================================================
// PRICE FLAT CONDITIONS (only for Exaggerated Divergence)
//=====================================================================

flatLow  = pivotLowFound  and _isApproximatelyEqual(priceLowAtPivot,  previousPriceLow)
flatHigh = pivotHighFound and _isApproximatelyEqual(priceHighAtPivot, previousPriceHigh)

//=====================================================================
// RSI STRUCTURE
//=====================================================================

rsiHigherLow  = rsiPivotValue > previousRSILow
rsiLowerLow   = rsiPivotValue < previousRSILow
rsiLowerHigh  = rsiPivotValue < previousRSIHigh
rsiHigherHigh = rsiPivotValue > previousRSIHigh

//=====================================================================
// PRICE STRUCTURE AT RSI PIVOTS
//=====================================================================

priceLowerLow   = priceLowAtPivot  < previousPriceLow
priceHigherLow  = priceLowAtPivot  > previousPriceLow
priceHigherHigh = priceHighAtPivot > previousPriceHigh
priceLowerHigh  = priceHighAtPivot < previousPriceHigh

//=====================================================================
// DIVERGENCE CONDITIONS
//=====================================================================

// Regular Bullish: Price LL, RSI HL
regularBull = showRegular and pivotLowFound and lowPivotInRange and priceLowerLow and not flatLow and rsiHigherLow

// Regular Bearish: Price HH, RSI LH
regularBear = showRegular and pivotHighFound and highPivotInRange and priceHigherHigh and not flatHigh and rsiLowerHigh

// Hidden Bullish: Price HL, RSI LL
hiddenBull = showHidden and pivotLowFound and lowPivotInRange and priceHigherLow and not flatLow and rsiLowerLow

// Hidden Bearish: Price LH, RSI HH
hiddenBear = showHidden and pivotHighFound and highPivotInRange and priceLowerHigh and not flatHigh and rsiHigherHigh

// Exaggerated Bullish: Price ~equal low, RSI HL
exaggeratedBull = showExaggerated and pivotLowFound and lowPivotInRange and flatLow and rsiHigherLow

// Exaggerated Bearish: Price ~equal high, RSI LH
exaggeratedBear = showExaggerated and pivotHighFound and highPivotInRange and flatHigh and rsiLowerHigh

//=====================================================================
// DIVERGENCE LINES (from reference pivot to signal pivot)
//=====================================================================

_drawLine(bool cond, int x1, float y1, color c) =>
    if cond
        line.new(x1, y1, pivotBarIndex, rsiPivotValue, xloc = xloc.bar_index, color = c, width = 2)

_drawLine(regularBull,     refLowBar,  refRSILow,  regularBullColor)
_drawLine(hiddenBull,      refLowBar,  refRSILow,  hiddenBullColor)
_drawLine(exaggeratedBull, refLowBar,  refRSILow,  exaggeratedBullColor)
_drawLine(regularBear,     refHighBar, refRSIHigh, regularBearColor)
_drawLine(hiddenBear,      refHighBar, refRSIHigh, hiddenBearColor)
_drawLine(exaggeratedBear, refHighBar, refRSIHigh, exaggeratedBearColor)

//=====================================================================
// LABELS
//=====================================================================

plotshape(regularBull ? rsiPivotValue : na, offset = -signalRight, title = "Regular Bullish Divergence",
     text = "Regular\nBull Div", style = shape.labelup, location = location.absolute,
     color = regularBullColor, textcolor = textColor)

plotshape(regularBear ? rsiPivotValue : na, offset = -signalRight, title = "Regular Bearish Divergence",
     text = "Regular\nBear Div", style = shape.labeldown, location = location.absolute,
     color = regularBearColor, textcolor = textColor)

plotshape(hiddenBull ? rsiPivotValue : na, offset = -signalRight, title = "Hidden Bullish Divergence",
     text = "Hidden\nBull Div", style = shape.labelup, location = location.absolute,
     color = hiddenBullColor, textcolor = textColor)

plotshape(hiddenBear ? rsiPivotValue : na, offset = -signalRight, title = "Hidden Bearish Divergence",
     text = "Hidden\nBear Div", style = shape.labeldown, location = location.absolute,
     color = hiddenBearColor, textcolor = textColor)

plotshape(exaggeratedBull ? rsiPivotValue : na, offset = -signalRight, title = "Exaggerated Bullish Divergence",
     text = "Exaggerated\nBull Div", style = shape.labelup, location = location.absolute,
     color = exaggeratedBullColor, textcolor = textColor)

plotshape(exaggeratedBear ? rsiPivotValue : na, offset = -signalRight, title = "Exaggerated Bearish Divergence",
     text = "Exaggerated\nBear Div", style = shape.labeldown, location = location.absolute,
     color = exaggeratedBearColor, textcolor = textColor)

//=====================================================================
// ALERTS
//=====================================================================

alertOk = alertOnClose ? barstate.isconfirmed : true

alertcondition(regularBull     and alertOk, title = "Regular Bullish Divergence",     message = "Regular Bullish Divergence detected.")
alertcondition(regularBear     and alertOk, title = "Regular Bearish Divergence",     message = "Regular Bearish Divergence detected.")
alertcondition(hiddenBull      and alertOk, title = "Hidden Bullish Divergence",      message = "Hidden Bullish Divergence detected.")
alertcondition(hiddenBear      and alertOk, title = "Hidden Bearish Divergence",      message = "Hidden Bearish Divergence detected.")
alertcondition(exaggeratedBull and alertOk, title = "Exaggerated Bullish Divergence", message = "Exaggerated Bullish Divergence detected.")
alertcondition(exaggeratedBear and alertOk, title = "Exaggerated Bearish Divergence", message = "Exaggerated Bearish Divergence detected.")

//=====================================================================
// UPDATE REFERENCE PIVOTS (must stay at the END of the script)
//=====================================================================

if not na(refPivotLowValue)
    refLowBar   := bar_index - lookbackRight
    refRSILow   := refPivotLowValue
    refPriceLow := low[lookbackRight]

if not na(refPivotHighValue)
    refHighBar   := bar_index - lookbackRight
    refRSIHigh   := refPivotHighValue
    refPriceHigh := high[lookbackRight]
````
