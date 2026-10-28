# The Essential Pivots

- url: https://www.tradingview.com/script/IKTUuASE-The-Essential-Pivots/
- type: indicator
- pine_id: PUB;811798f6e1074fb691de4d971bc272b0
- version: 1.0

## Description

[url=https://www.tradingview.com/x/gCYy3sJ5/]https://www.tradingview.com/x/gCYy3sJ5/[/url]

[b]The Essential Pivots[/b]

Not every pivot deserves space on your chart.

The Essential Pivots was designed around a simple idea: emphasize the higher-importance pivot levels that tend to attract greater participation, receive more meaningful reactions, and produce larger directional moves—while removing many of the secondary levels that often add more clutter than clarity.

Traditional pivot indicators can fill the chart with numerous support and resistance lines. Although every calculated level may have a purpose, displaying all of them at once can make it difficult to recognize which areas truly matter. The Essential Pivots takes a more selective approach, giving traders a cleaner view of the market’s most significant reference points.

[b]Why These Pivots Matter[/b]

Major pivots can act as areas where:

[list]
[*]Price pauses, rejects, or reverses
[*]Breakouts gain momentum
[*]Previous resistance becomes support, or support becomes resistance
[*]Buyers and sellers compete for directional control
[*]Trend indicators react, flatten, or change direction
[*]Larger intraday and multi-session moves begin
[/list]

Because these levels represent broader reference points, they may be watched by more market participants than many lower-priority pivot levels. This does not mean price will always reverse at a pivot. Instead, the levels identify areas where trader attention and the probability of a meaningful reaction may increase.

[b]A Cleaner Approach to Market Structure[/b]

The primary purpose of The Essential Pivots is not to predict every market turn. It is to simplify the chart so traders can quickly answer a more useful question:

[b]Where are the most important decision areas right now?[/b]

By concentrating on essential pivot levels, the indicator helps reduce visual noise and prevents the chart from becoming a maze of competing horizontal lines. This makes it easier to combine the pivots with price action, market structure, volume, or a preferred trend indicator without overwhelming the screen.

[b]Ways to Use the Indicator[/b]

The Essential Pivots can help traders evaluate:

[list]
[*]Rejection entries when price tests a pivot and fails to continue
[*]Breakout opportunities when price closes decisively through a level
[*]Retests after a broken pivot changes its role
[*]Profit targets near the next major pivot
[*]Stop placement beyond a confirmed structural level
[*]Consolidation when price repeatedly crosses the same pivot
[*]Confluence with trendlines, moving averages, opening ranges, or volume-based tools
[/list]

A pivot should generally be treated as an area of interest rather than an automatic entry signal. The quality of the reaction still matters. A decisive rejection, strong close, successful retest, or expansion in momentum provides more information than price merely touching the line.

[b]Reading Price Around a Pivot[/b]

[list]
[*]Rejection: Price tests the pivot but closes back away from it, suggesting the level is being defended.
[*]Breakout: Price closes clearly beyond the pivot with directional conviction.
[*]Retest: Price returns to the broken level and holds it from the opposite side.
[*]Acceptance: Price repeatedly trades on both sides of the pivot, suggesting uncertainty or balance rather than a clean directional edge.
[*]Role reversal: A former resistance level begins acting as support, or former support begins acting as resistance.
[/list]

When price repeatedly moves above and below a pivot, conditions may be too indecisive for the level to provide a reliable directional bias. In these situations, patience may be more valuable than prediction.

[b]Visual Design[/b]

The indicator uses a consistent visual hierarchy so the pivots remain easy to identify without competing with candles or other tools. Essential levels are displayed with greater prominence, while the overall presentation remains intentionally minimal.

The quarterly pivot is enabled by default because it can provide valuable higher-timeframe context and may remain relevant across many trading sessions.

[b]Best Practices[/b]

The Essential Pivots is most effective when used as a framework for context—not as a standalone buy-or-sell system. Traders may improve selectivity by considering:

[list]
[*]The strength and direction of the prevailing trend
[*]The quality of the candle reaction at the pivot
[*]Whether price is rejecting, breaking, or accepting the level
[*]The distance to the next significant pivot
[*]Current volatility and market conditions
[*]Alignment with higher-timeframe structure
[/list]

The strongest opportunities often occur when price reaches an important pivot with clear directional intent and then confirms whether the level is being defended or surrendered.

[b]Final Perspective[/b]

The Essential Pivots is built for traders who want fewer lines and more meaningful information.

Rather than displaying every possible pivot calculation, it focuses attention on the levels most likely to influence price behavior, support larger moves, and provide useful structural context. The result is a cleaner chart, a clearer decision-making process, and more room to observe what matters most: how price actually responds when it reaches an important level.

[b]Important:[/b]  Pivot levels are reference points, not guarantees. This indicator does not provide financial advice and should be used alongside appropriate confirmation, risk management, and independent analysis.

## Source Code

````pine
//@version=6
indicator(
     "The Essential Pivots",
     shorttitle = "Essential Pivots",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 100
     )

//=====================================================================
// ESSENTIAL PIVOT LEVELS
//=====================================================================

string GRP_LEVELS = "Essential Pivot Levels"

bool showDaily = input.bool(
     true,
     "Daily P",
     group = GRP_LEVELS
     )

bool showWeekly = input.bool(
     true,
     "Weekly P",
     group = GRP_LEVELS
     )

bool showMonthly = input.bool(
     true,
     "Monthly P",
     group = GRP_LEVELS
     )

bool showQuarterly = input.bool(
     true,
     "Quarterly P",
     group = GRP_LEVELS
     )

int historyToShow = input.int(
     10,
     "Historical Pivot Periods",
     minval = 1,
     maxval = 50,
     group = GRP_LEVELS
     )

//=====================================================================
// COLORS
//=====================================================================

string GRP_COLORS = "Colors"

color pivotColor = input.color(
     color.rgb(156, 39, 176),
     "Essential Pivot Color",
     group = GRP_COLORS
     )

//=====================================================================
// APPEARANCE
//=====================================================================

string GRP_APPEARANCE = "Appearance"

int dailyWidth = input.int(
     2,
     "Daily Line Width",
     minval = 1,
     maxval = 5,
     group = GRP_APPEARANCE
     )

int weeklyWidth = input.int(
     2,
     "Weekly Line Width",
     minval = 1,
     maxval = 5,
     group = GRP_APPEARANCE
     )

int monthlyWidth = input.int(
     2,
     "Monthly Line Width",
     minval = 1,
     maxval = 5,
     group = GRP_APPEARANCE
     )

int quarterlyWidth = input.int(
     2,
     "Quarterly Line Width",
     minval = 1,
     maxval = 5,
     group = GRP_APPEARANCE
     )

bool showTags = input.bool(
     true,
     "Show Tags",
     group = GRP_APPEARANCE
     )

bool showPriceInTags = input.bool(
     true,
     "Show Price In Tags",
     group = GRP_APPEARANCE
     )

int tagOffset = input.int(
     8,
     "Tag Offset",
     minval = 0,
     maxval = 100,
     group = GRP_APPEARANCE
     )

color tagBackground = input.color(
     color.rgb(8, 12, 18),
     "Tag Background",
     group = GRP_APPEARANCE
     )

//=====================================================================
// PIVOT CALCULATION
// Traditional Pivot:
// P = (Previous High + Previous Low + Previous Close) / 3
//=====================================================================

getPivot(string tf) =>
    request.security(
         syminfo.tickerid,
         tf,
         (high[1] + low[1] + close[1]) / 3.0,
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_on
         )

//=====================================================================
// PIVOT VALUES
//=====================================================================

float dailyP = getPivot("1D")
float weeklyP = getPivot("1W")
float monthlyP = getPivot("1M")
float quarterlyP = getPivot("3M")

bool newDay = timeframe.change("1D")
bool newWeek = timeframe.change("1W")
bool newMonth = timeframe.change("1M")
bool newQuarter = timeframe.change("3M")

//=====================================================================
// STORAGE
//=====================================================================

var array<line> dailyLines = array.new_line()
var array<line> weeklyLines = array.new_line()
var array<line> monthlyLines = array.new_line()
var array<line> quarterlyLines = array.new_line()

var label dailyTag = na
var label weeklyTag = na
var label monthlyTag = na
var label quarterlyTag = na


//=====================================================================
// HELPERS
//=====================================================================

trimLines(array<line> arr) =>
    while array.size(arr) > historyToShow
        line.delete(array.shift(arr))

closePreviousLine(array<line> lineArr) =>
    if array.size(lineArr) > 0
        line previousLine = array.get(lineArr, array.size(lineArr) - 1)
        line.set_extend(previousLine, extend.none)
        line.set_x2(previousLine, bar_index)

createPivotLine(array<line> lineArr, float level, color lineColor, int lineWidth) =>
    if not na(level)
        line newLine = line.new(
             x1 = bar_index,
             y1 = level,
             x2 = bar_index + 1,
             y2 = level,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = lineColor,
             width = lineWidth
             )
        array.push(lineArr, newLine)
        trimLines(lineArr)

makeTag(float level, string tagText, color tagColor) =>
    string finalText = showPriceInTags ? tagText + "  " + str.tostring(level, format.mintick) + "  " : tagText
    label.new(
         x = bar_index + tagOffset,
         y = level,
         text = finalText,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_left,
         color = tagBackground,
         textcolor = tagColor,
         size = size.tiny
         )

//=====================================================================
// DRAW PIVOT LINES
//=====================================================================

if showDaily and (barstate.isfirst or newDay)

    closePreviousLine(
         dailyLines
         )

    createPivotLine(
         dailyLines,
         dailyP,
         pivotColor,
         dailyWidth
         )

if showWeekly and (barstate.isfirst or newWeek)

    closePreviousLine(
         weeklyLines
         )

    createPivotLine(
         weeklyLines,
         weeklyP,
         pivotColor,
         weeklyWidth
         )

if showMonthly and (barstate.isfirst or newMonth)

    closePreviousLine(
         monthlyLines
         )

    createPivotLine(
         monthlyLines,
         monthlyP,
         pivotColor,
         monthlyWidth
         )

if showQuarterly and (barstate.isfirst or newQuarter)

    closePreviousLine(
         quarterlyLines
         )

    createPivotLine(
         quarterlyLines,
         quarterlyP,
         pivotColor,
         quarterlyWidth
         )

//=====================================================================
// CURRENT TAGS
//=====================================================================

if barstate.islast

    if not na(dailyTag)
        label.delete(dailyTag)

    if not na(weeklyTag)
        label.delete(weeklyTag)

    if not na(monthlyTag)
        label.delete(monthlyTag)

    if not na(quarterlyTag)
        label.delete(quarterlyTag)

    if showTags and showDaily and not na(dailyP)

        dailyTag := makeTag(
             dailyP,
             "  DAILY P  ",
             pivotColor
             )

    if showTags and showWeekly and not na(weeklyP)

        weeklyTag := makeTag(
             weeklyP,
             "  WEEKLY P  ",
             pivotColor
             )

    if showTags and showMonthly and not na(monthlyP)

        monthlyTag := makeTag(
             monthlyP,
             "  MONTHLY P  ",
             pivotColor
             )

    if showTags and showQuarterly and not na(quarterlyP)

        quarterlyTag := makeTag(
             quarterlyP,
             "  QUARTERLY P  ",
             pivotColor
             )
````
