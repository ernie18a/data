# Adaptive Reaction Zones

- url: https://www.tradingview.com/script/H9OVD9rc-Adaptive-Reaction-Zones/
- type: indicator
- pine_id: PUB;5646aabfd33d4215875094487b011b7b
- version: 1.0

## Description

Adaptive Reaction Zones is an adaptive price-reaction level indicator designed to automatically identify areas where the market has repeatedly reversed, slowed down, or changed direction.
Rather than plotting every local high and low, the indicator:
detects confirmed price reactions;
evaluates the quality of each reaction;
groups nearby reactions into price clusters;
ranks the resulting areas;
displays only the most relevant support and resistance levels.
The chart shows the calculated center of each identified reaction area:
🔴 Red lines represent levels above the current price.
🟢 Green lines represent levels below the current price.
Each label displays the exact level price and its percentage distance from the current market price.
🎯 Purpose of the Indicator
Adaptive Reaction Zones provides a structured map of nearby price areas that have previously generated meaningful market reactions.
The indicator can be used to:
identify nearby support and resistance areas;
measure the distance to potentially significant price levels;
plan possible profit-taking areas;
locate zones where future price behavior may require closer observation;
analyze level breakouts and potential role reversals;
create alerts for crossings of relevant price areas.
The indicator is not a standalone trading strategy and does not generate mandatory buy or sell signals.
Its purpose is to provide an objective map of historical price reactions that traders can combine with trend analysis, market structure, volume, volatility, and other forms of analysis.
⚙️ How the Algorithm Works
1. Detecting Confirmed Price Reactions
The calculation begins with confirmed local highs and lows.
Users can select one of two reaction sources:
High / Low
The algorithm analyzes the full high and low values of each candle, including its wicks.
Candle body
The algorithm uses the boundaries of the candle body and excludes the extreme wick values.
The Pivot confirmation setting determines how many bars are required on each side of a local high or low before the reaction is confirmed.
As a result, a reaction is not included in the calculations at the exact moment the extreme occurs. It is added only after subsequent bars confirm that the point was a local high or low.
A lower setting:
increases the sensitivity of the algorithm;
produces more confirmed reactions;
allows the indicator to respond to smaller local movements.
A higher setting:
selects more pronounced market extremes;
reduces the number of secondary reactions;
increases the confirmation delay.
2. Evaluating Reaction Quality
The algorithm does not treat every confirmed local high or low as equally important.
Each reaction receives an individual quality score based on two components.
Reaction Candle Structure
For a reaction from a local high, the algorithm evaluates the upper wick relative to the candle’s total range.
For a reaction from a local low, it evaluates the lower wick.
A pronounced wick may indicate that price was rejected from that area by market participants.
Subsequent Price Movement
The algorithm also measures how far price moved away from the detected extreme during the period required to confirm the reaction.
This movement is normalized using ATR, allowing reactions formed under different volatility conditions to be compared on a consistent basis.
In the final calculation, the subsequent price movement receives slightly more weight than the candle structure.
This means that an isolated or insignificant extreme receives a lower score than a reaction followed by a meaningful price move in the opposite direction.
3. Adaptive Reaction Clustering
The market rarely reacts several times at exactly the same price.
More commonly, reactions occur within the same broader price area but at slightly different values. For this reason, Adaptive Reaction Zones groups nearby reactions into adaptive price clusters.
The cluster width is not fixed. It is calculated using:
the current ATR value;
the market range over the selected lookback period;
the instrument’s minimum tick size.
The algorithm compares the width calculated from ATR with a percentage of the broader market range and uses the larger value.
This allows the clustering distance to adapt automatically to:
current volatility;
the scale of movement in the selected instrument;
the characteristics of the market and timeframe.
ATR is not used as a separate trading signal in this indicator. It is used to normalize volatility, determine the adaptive cluster width, and calculate the minimum spacing between displayed levels.
4. Calculating the Center of a Price Area
When a new reaction is confirmed, the algorithm searches for the nearest suitable cluster.
If the distance to an existing cluster is within the calculated tolerance, the reaction is added to that cluster.
If no suitable cluster exists, a new price area is created.
The center of each cluster is calculated as a weighted average of all reactions included in it.
More recent reactions receive greater weight. The influence of older reactions gradually decreases according to the Historical reaction weight setting.
For each cluster, the algorithm stores:
the number of reactions;
the combined reaction-quality value;
the upper and lower boundaries of the area;
the bar of the most recent reaction;
the number of reactions from local highs;
the number of reactions from local lows.
🧠 How Level Significance Is Evaluated
After the clusters have been created, each cluster receives a composite score.
The score is based on five main characteristics.
Number of Reactions
The more confirmed reactions that have occurred within the same price area, the higher its base significance.
Reaction Quality
Clusters containing pronounced candle rejections and stronger subsequent price movements receive a higher score.
Recency
Recent reactions receive more weight than areas that have not interacted with price for a long time.
Cluster Tightness
Reactions concentrated within a relatively narrow price range receive a higher score than reactions spread across a wider area.
Role Reversal
A cluster receives additional weight when the same price area has generated reactions from both local highs and local lows.
This allows the algorithm to recognize areas that have acted as resistance during one period and as support during another.
The significance of a level is therefore not determined by a single condition. It is based on a combination of:
repetition;
reaction quality;
recency;
cluster tightness;
historical role reversal.
📊 How Displayed Levels Are Selected
Support and resistance levels are selected independently.
Resistance levels are selected from clusters located above the current price.
Support levels are selected from clusters located below the current price.
The selection process considers:
the minimum required number of reactions;
the maximum permitted distance from the current price;
the composite cluster-quality score;
proximity to the current price;
the minimum spacing between neighboring levels.
The Proximity priority setting increases the preference given to clusters located closer to the current price.
Proximity does not replace the underlying quality score. It is added to the cluster’s base score as an additional selection factor.
The Minimum spacing setting prevents several nearly identical levels from being displayed close together.
Users can separately define the maximum number of resistance and support levels.
When fewer qualifying clusters are available, the indicator displays only the levels that meet the selected requirements rather than forcing a fixed number of lines onto the chart.
🖥 Chart Display
For every active level, the indicator displays:
the calculated center of the reaction area;
the percentage distance from the current price;
a color based on the level’s current position relative to price.
A positive percentage means that the level is above the current price.
A negative percentage means that the level is below the current price.
The percentage distance is updated dynamically as the current price changes.
Level Origin Options
From last reaction
The line begins at the most recent confirmed reaction included in the cluster.
Across chart
The line extends across the entire chart.
Users can also customize:
support and resistance colors;
line style;
line thickness;
transparency;
label position;
horizontal spacing between labels.
🔄 Why Levels May Change
Adaptive Reaction Zones is a dynamic indicator.
Whenever a new reaction is confirmed, the price clusters are recalculated.
A new reaction may:
strengthen an existing cluster;
change the calculated center of a cluster;
create a new price area;
change the ranking of previously identified areas;
cause one displayed level to be replaced by another.
The number of stored reactions is limited by the Reaction memory setting.
When older reactions move outside the selected memory limit, they are removed from the calculation.
Displayed lines should therefore not be interpreted as permanent levels that must remain unchanged on the chart.
They represent the current result of the algorithm’s analysis of the available history of confirmed price reactions.
🛠 Main Settings
Reaction Detection
Pivot confirmation
Defines the number of bars required on each side of a local reaction before it is confirmed.
Lower values increase sensitivity. Higher values select more pronounced market extremes.
Reaction memory
Defines the maximum number of recent confirmed reactions included in the calculation.
Minimum reactions
Defines the minimum number of reactions required for a price cluster to qualify as a level.
Reaction source
Selects the source used to identify reactions:
High / Low;
Candle body.
Show confirmed reactions
Displays markers for confirmed local reactions directly on the chart.
Adaptive Clustering
ATR period
Defines the ATR period used to adapt the algorithm to changing volatility.
ATR cluster width
Defines the ATR multiplier used to determine how close reactions must be to belong to the same cluster.
Market range lookback
Defines the number of bars used to calculate the broader market range.
Range cluster width
Defines the percentage of the market range used as an additional measure of cluster width.
Historical reaction weight
Controls how quickly the influence of older reactions decreases.
Lower values cause historical reactions to lose influence more rapidly.
Level Selection
Resistance levels
Defines the maximum number of displayed resistance levels.
Support levels
Defines the maximum number of displayed support levels.
Maximum distance from price
Excludes clusters located too far from the current price.
Minimum spacing
Prevents several closely positioned levels from being displayed together.
Proximity priority
Controls how strongly proximity to the current price influences the final level selection.
Premium Appearance
This section allows users to customize:
support and resistance colors;
line style;
line thickness;
line transparency;
label transparency;
label position;
spacing between labels;
the starting point of each level line.
📌 Practical Use
A conservative approach is to treat each line as the calculated center of a broader area of interest rather than as an exact price for an automatic trade entry.
When price approaches a level, traders may additionally evaluate:
candle behavior;
trend direction;
market structure;
volume;
current volatility;
the nature of the initial interaction;
a breakout and subsequent retest of the area.
To Display Fewer but More Selective Levels
Consider increasing:
Pivot confirmation;
Minimum reactions;
Minimum spacing.
To Create a More Sensitive Market Map
Consider decreasing:
Pivot confirmation;
Minimum reactions.
Higher sensitivity may also increase the number of less significant reaction areas.
For highly volatile instruments, the ATR cluster width setting may require adjustment.
For markets with broad long-term price ranges, the Range cluster width setting may have a greater influence on the calculations.
🔔 Alerts
The indicator includes two alert conditions:
price crossing above an active reaction level;
price crossing below an active reaction level.
A crossing is determined by comparing the previous bar’s closing price with the current bar’s closing price.
To receive alerts only after a candle has been confirmed, select Once Per Bar Close when creating the TradingView alert.
✨ Originality of the Method
Adaptive Reaction Zones is not a simple combination of several standard indicators.
Confirmed pivots and ATR are used only as individual components within a unified calculation process.
Pivots provide confirmed price-reaction points, while ATR allows the calculations to adapt to changing market volatility.
The core methodology follows a structured sequence:
detecting confirmed price reactions;
evaluating the quality of each reaction;
adaptively grouping nearby reactions into clusters;
weighting reactions according to their recency;
evaluating cluster tightness and historical role reversal;
calculating a composite cluster score;
selecting support and resistance levels independently;
filtering out overlapping and excessively distant levels.
The purpose of this approach is not to display every possible market extreme.
Instead, the algorithm identifies a limited number of price areas that have the highest relevance according to the combined history, quality, density, and recency of previous market reactions.
⚠️ Limitations
The indicator uses price data only and does not account for:
fundamental events;
market news;
corporate reports;
macroeconomic factors.
Confirmed pivots always appear with a delay equal to the selected Pivot confirmation value.
This delay is a necessary part of confirming a local extreme and is not a calculation error.
New reactions may change:
the composition of a cluster;
the calculated center of an area;
the ranking of a level;
the set of lines displayed on the chart.
Results may be less stable on instruments with low liquidity, large price gaps, or insufficient historical data.
A historical reaction does not mean that price will necessarily reverse from the same area in the future.
The indicator highlights algorithmically identified areas of previous price interaction, but it does not guarantee the outcome of the next interaction with a level.

## Source Code

````pine
//@version=6
indicator(
     "Adaptive Reaction Zones",
     shorttitle = "AR Zones",
     overlay = true,
     max_lines_count = 100,
     max_labels_count = 100,
     max_bars_back = 3000
)

//==================================================
// 1. Reaction detection
//==================================================

groupDetection = "Reaction Detection"

pivotLength = input.int(
     9,
     "Pivot confirmation",
     minval = 3,
     maxval = 30,
     group = groupDetection,
     tooltip = "Bars required on each side to confirm a local reaction."
)

pivotMemory = input.int(
     60,
     "Reaction memory",
     minval = 10,
     maxval = 150,
     group = groupDetection,
     tooltip = "Maximum number of recent confirmed reactions used in calculations."
)

minimumTouches = input.int(
     2,
     "Minimum reactions",
     minval = 2,
     maxval = 10,
     group = groupDetection,
     tooltip = "Minimum number of price reactions required to confirm a level."
)

sourceMode = input.string(
     "High / Low",
     "Reaction source",
     options = ["High / Low", "Candle body"],
     group = groupDetection
)

showPivotMarks = input.bool(
     false,
     "Show confirmed reactions",
     group = groupDetection
)

//==================================================
// 2. Adaptive clustering
//==================================================

groupClustering = "Adaptive Clustering"

atrLength = input.int(
     14,
     "ATR period",
     minval = 5,
     maxval = 100,
     group = groupClustering
)

atrWidthMultiplier = input.float(
     0.75,
     "ATR cluster width",
     minval = 0.10,
     maxval = 3.00,
     step = 0.05,
     group = groupClustering,
     tooltip = "Controls how close reactions must be to form one price cluster."
)

rangeLookback = input.int(
     300,
     "Market range lookback",
     minval = 50,
     maxval = 1000,
     group = groupClustering
)

rangeWidthPercent = input.float(
     1.25,
     "Range cluster width (%)",
     minval = 0.10,
     maxval = 5.00,
     step = 0.05,
     group = groupClustering
)

recencyDecay = input.float(
     0.93,
     "Historical reaction weight",
     minval = 0.70,
     maxval = 1.00,
     step = 0.01,
     group = groupClustering,
     tooltip = "Lower values reduce the influence of older reactions."
)

//==================================================
// 3. Level selection
//==================================================

groupSelection = "Level Selection"

resistanceLimit = input.int(
     3,
     "Resistance levels",
     minval = 0,
     maxval = 5,
     group = groupSelection
)

supportLimit = input.int(
     3,
     "Support levels",
     minval = 0,
     maxval = 5,
     group = groupSelection
)

maximumDistancePercent = input.float(
     15.0,
     "Maximum distance from price (%)",
     minval = 1.0,
     maxval = 100.0,
     step = 0.5,
     group = groupSelection,
     tooltip = "Levels farther from the current price are excluded."
)

minimumSeparationATR = input.float(
     0.90,
     "Minimum spacing (ATR)",
     minval = 0.10,
     maxval = 5.00,
     step = 0.05,
     group = groupSelection,
     tooltip = "Prevents several nearby levels from appearing as a stack."
)

proximityWeight = input.float(
     2.25,
     "Proximity priority",
     minval = 0.0,
     maxval = 5.0,
     step = 0.25,
     group = groupSelection,
     tooltip = "Higher values give more priority to levels near the current price."
)

//==================================================
// 4. Premium appearance
//==================================================

groupStyle = "Premium Appearance"

resistanceColor = input.color(
     color.rgb(242, 103, 110),
     "Resistance",
     group = groupStyle
)

supportColor = input.color(
     color.rgb(46, 214, 150),
     "Support",
     group = groupStyle
)

lineStyleInput = input.string(
     "Dashed",
     "Level style",
     options = ["Solid", "Dashed", "Dotted"],
     group = groupStyle
)

lineWidth = input.int(
     1,
     "Level thickness",
     minval = 1,
     maxval = 2,
     group = groupStyle
)

lineTransparency = input.int(
     18,
     "Level transparency",
     minval = 0,
     maxval = 90,
     group = groupStyle,
     tooltip = "Lower values make the lines brighter."
)

labelTransparency = input.int(
     18,
     "Label transparency",
     minval = 0,
     maxval = 80,
     group = groupStyle
)

baseLabelOffset = input.int(
     8,
     "Label position",
     minval = 1,
     maxval = 50,
     group = groupStyle,
     tooltip = "Base distance between the current candle and the labels."
)

labelStagger = input.int(
     4,
     "Label spacing",
     minval = 0,
     maxval = 10,
     group = groupStyle,
     tooltip = "Horizontally separates labels that are close in price."
)

lineReachInput = input.string(
     "From last reaction",
     "Level origin",
     options = ["From last reaction", "Across chart"],
     group = groupStyle
)

lineStyle =
     lineStyleInput == "Solid"  ? line.style_solid :
     lineStyleInput == "Dotted" ? line.style_dotted :
                                  line.style_dashed

//==================================================
// 5. Core market measurements
//==================================================

float atrValue = ta.atr(atrLength)

float marketHigh = ta.highest(high, rangeLookback)
float marketLow = ta.lowest(low, rangeLookback)

float marketRange =
     nz(marketHigh - marketLow, 0.0)

float atrTolerance =
     nz(atrValue, syminfo.mintick) *
     atrWidthMultiplier

float rangeTolerance =
     marketRange *
     rangeWidthPercent /
     100.0

float clusterTolerance =
     math.max(
          math.max(
               atrTolerance,
               rangeTolerance
          ),
          syminfo.mintick * 2
     )

float minimumLevelSpacing =
     math.max(
          nz(atrValue, syminfo.mintick) *
          minimumSeparationATR,
          clusterTolerance * 0.75
     )

//==================================================
// 6. Confirmed reactions
//==================================================

float upperSource =
     sourceMode == "High / Low"
     ? high
     : math.max(open, close)

float lowerSource =
     sourceMode == "High / Low"
     ? low
     : math.min(open, close)

float pivotHigh =
     ta.pivothigh(
          upperSource,
          pivotLength,
          pivotLength
     )

float pivotLow =
     ta.pivotlow(
          lowerSource,
          pivotLength,
          pivotLength
     )

plotshape(
     showPivotMarks and not na(pivotHigh),
     title = "Confirmed High Reaction",
     style = shape.circle,
     location = location.abovebar,
     offset = -pivotLength,
     size = size.tiny,
     color = color.new(resistanceColor, 5)
)

plotshape(
     showPivotMarks and not na(pivotLow),
     title = "Confirmed Low Reaction",
     style = shape.circle,
     location = location.belowbar,
     offset = -pivotLength,
     size = size.tiny,
     color = color.new(supportColor, 5)
)

//==================================================
// 7. Reaction storage
//==================================================

var float[] reactionPrices = array.new_float()
var int[] reactionBars = array.new_int()
var float[] reactionQualities = array.new_float()
var int[] reactionTypes = array.new_int()

// Reaction type:
//  1 = reaction from a high
// -1 = reaction from a low

bool newReaction =
     not na(pivotHigh) or
     not na(pivotLow)

if not na(pivotHigh)
    float reactionRange =
         math.max(
              high[pivotLength] -
              low[pivotLength],
              syminfo.mintick
         )

    float upperWick =
         high[pivotLength] -
         math.max(
              open[pivotLength],
              close[pivotLength]
         )

    float wickQuality =
         math.min(
              upperWick / reactionRange,
              1.0
         )

    float atrAtReaction =
         math.max(
              nz(
                   atrValue[pivotLength],
                   syminfo.mintick
              ),
              syminfo.mintick
         )

    float bearishDeparture =
         math.max(
              pivotHigh - close,
              0.0
         )

    float departureQuality =
         math.min(
              bearishDeparture /
              atrAtReaction /
              3.0,
              1.0
         )

    float combinedQuality =
         wickQuality * 0.45 +
         departureQuality * 0.55

    array.unshift(
         reactionPrices,
         pivotHigh
    )

    array.unshift(
         reactionBars,
         bar_index - pivotLength
    )

    array.unshift(
         reactionQualities,
         combinedQuality
    )

    array.unshift(
         reactionTypes,
         1
    )

if not na(pivotLow)
    float reactionRange =
         math.max(
              high[pivotLength] -
              low[pivotLength],
              syminfo.mintick
         )

    float lowerWick =
         math.min(
              open[pivotLength],
              close[pivotLength]
         ) -
         low[pivotLength]

    float wickQuality =
         math.min(
              lowerWick / reactionRange,
              1.0
         )

    float atrAtReaction =
         math.max(
              nz(
                   atrValue[pivotLength],
                   syminfo.mintick
              ),
              syminfo.mintick
         )

    float bullishDeparture =
         math.max(
              close - pivotLow,
              0.0
         )

    float departureQuality =
         math.min(
              bullishDeparture /
              atrAtReaction /
              3.0,
              1.0
         )

    float combinedQuality =
         wickQuality * 0.45 +
         departureQuality * 0.55

    array.unshift(
         reactionPrices,
         pivotLow
    )

    array.unshift(
         reactionBars,
         bar_index - pivotLength
    )

    array.unshift(
         reactionQualities,
         combinedQuality
    )

    array.unshift(
         reactionTypes,
         -1
    )

while array.size(reactionPrices) > pivotMemory
    array.pop(reactionPrices)
    array.pop(reactionBars)
    array.pop(reactionQualities)
    array.pop(reactionTypes)

//==================================================
// 8. Cluster storage
//==================================================

var float[] clusterCenters = array.new_float()
var float[] clusterWeights = array.new_float()
var float[] clusterQualitySums = array.new_float()
var float[] clusterHighs = array.new_float()
var float[] clusterLows = array.new_float()

var int[] clusterTouches = array.new_int()
var int[] clusterLastBars = array.new_int()
var int[] clusterHighReactions = array.new_int()
var int[] clusterLowReactions = array.new_int()

//==================================================
// 9. Rebuild adaptive clusters
//==================================================

if newReaction
    array.clear(clusterCenters)
    array.clear(clusterWeights)
    array.clear(clusterQualitySums)
    array.clear(clusterHighs)
    array.clear(clusterLows)

    array.clear(clusterTouches)
    array.clear(clusterLastBars)
    array.clear(clusterHighReactions)
    array.clear(clusterLowReactions)

    int storedReactionCount =
         array.size(reactionPrices)

    if storedReactionCount > 0
        for reactionIndex = 0 to storedReactionCount - 1
            float reactionPrice =
                 array.get(
                      reactionPrices,
                      reactionIndex
                 )

            int reactionBar =
                 array.get(
                      reactionBars,
                      reactionIndex
                 )

            float reactionQuality =
                 array.get(
                      reactionQualities,
                      reactionIndex
                 )

            int reactionType =
                 array.get(
                      reactionTypes,
                      reactionIndex
                 )

            float reactionWeight =
                 math.pow(
                      recencyDecay,
                      reactionIndex
                 )

            int nearestCluster = -1
            float nearestDistance = 1e10

            int existingClusterCount =
                 array.size(clusterCenters)

            if existingClusterCount > 0
                for clusterIndex = 0 to existingClusterCount - 1
                    float currentCenter =
                         array.get(
                              clusterCenters,
                              clusterIndex
                         )

                    float distanceToCenter =
                         math.abs(
                              reactionPrice -
                              currentCenter
                         )

                    if distanceToCenter <= clusterTolerance and
                       distanceToCenter < nearestDistance
                        nearestCluster := clusterIndex
                        nearestDistance := distanceToCenter

            if nearestCluster == -1
                array.push(
                     clusterCenters,
                     reactionPrice
                )

                array.push(
                     clusterWeights,
                     reactionWeight
                )

                array.push(
                     clusterQualitySums,
                     reactionQuality *
                     reactionWeight
                )

                array.push(
                     clusterHighs,
                     reactionPrice
                )

                array.push(
                     clusterLows,
                     reactionPrice
                )

                array.push(
                     clusterTouches,
                     1
                )

                array.push(
                     clusterLastBars,
                     reactionBar
                )

                array.push(
                     clusterHighReactions,
                     reactionType == 1 ? 1 : 0
                )

                array.push(
                     clusterLowReactions,
                     reactionType == -1 ? 1 : 0
                )

            else
                float previousCenter =
                     array.get(
                          clusterCenters,
                          nearestCluster
                     )

                float previousWeight =
                     array.get(
                          clusterWeights,
                          nearestCluster
                     )

                float updatedWeight =
                     previousWeight +
                     reactionWeight

                float updatedCenter =
                     (
                          previousCenter *
                          previousWeight +
                          reactionPrice *
                          reactionWeight
                     ) /
                     updatedWeight

                array.set(
                     clusterCenters,
                     nearestCluster,
                     updatedCenter
                )

                array.set(
                     clusterWeights,
                     nearestCluster,
                     updatedWeight
                )

                array.set(
                     clusterQualitySums,
                     nearestCluster,
                     array.get(
                          clusterQualitySums,
                          nearestCluster
                     ) +
                     reactionQuality *
                     reactionWeight
                )

                array.set(
                     clusterHighs,
                     nearestCluster,
                     math.max(
                          array.get(
                               clusterHighs,
                               nearestCluster
                          ),
                          reactionPrice
                     )
                )

                array.set(
                     clusterLows,
                     nearestCluster,
                     math.min(
                          array.get(
                               clusterLows,
                               nearestCluster
                          ),
                          reactionPrice
                     )
                )

                array.set(
                     clusterTouches,
                     nearestCluster,
                     array.get(
                          clusterTouches,
                          nearestCluster
                     ) + 1
                )

                array.set(
                     clusterLastBars,
                     nearestCluster,
                     math.max(
                          array.get(
                               clusterLastBars,
                               nearestCluster
                          ),
                          reactionBar
                     )
                )

                if reactionType == 1
                    array.set(
                         clusterHighReactions,
                         nearestCluster,
                         array.get(
                              clusterHighReactions,
                              nearestCluster
                         ) + 1
                    )
                else
                    array.set(
                         clusterLowReactions,
                         nearestCluster,
                         array.get(
                              clusterLowReactions,
                              nearestCluster
                         ) + 1
                    )

//==================================================
// 10. Cluster quality score
//==================================================

clusterBaseScore(int clusterIndex) =>
    float totalWeight =
         array.get(
              clusterWeights,
              clusterIndex
         )

    float averageQuality =
         totalWeight > 0
         ? array.get(
              clusterQualitySums,
              clusterIndex
         ) / totalWeight
         : 0.0

    float clusterSpread =
         array.get(
              clusterHighs,
              clusterIndex
         ) -
         array.get(
              clusterLows,
              clusterIndex
         )

    float tightness =
         1.0 -
         math.min(
              clusterSpread /
              math.max(
                   clusterTolerance,
                   syminfo.mintick
              ),
              1.0
         )

    int ageInBars =
         bar_index -
         array.get(
              clusterLastBars,
              clusterIndex
         )

    float expectedHistory =
         math.max(
              pivotMemory *
              pivotLength,
              1
         )

    float recencyScore =
         math.max(
              0.0,
              1.0 -
              ageInBars /
              expectedHistory
         )

    int highReactionCount =
         array.get(
              clusterHighReactions,
              clusterIndex
         )

    int lowReactionCount =
         array.get(
              clusterLowReactions,
              clusterIndex
         )

    float roleReversalBonus =
         highReactionCount > 0 and
         lowReactionCount > 0
         ? 1.0
         : 0.0

    int touchCount =
         array.get(
              clusterTouches,
              clusterIndex
         )

    touchCount * 1.20 +
     averageQuality * 1.50 +
     recencyScore * 1.15 +
     tightness * 0.90 +
     roleReversalBonus * 1.25

//==================================================
// 11. Selected levels
//==================================================

var float[] activeLevels = array.new_float()
var float[] activeScores = array.new_float()
var int[] activeOrigins = array.new_int()
var int[] activeLabelOffsets = array.new_int()

bool refreshSelection =
     newReaction or
     barstate.islast

if refreshSelection
    array.clear(activeLevels)
    array.clear(activeScores)
    array.clear(activeOrigins)
    array.clear(activeLabelOffsets)

    int clusterCount =
         array.size(clusterCenters)

    array<bool> clusterUsed =
         array.new_bool(
              clusterCount,
              false
         )

    // ---------------------------------------------
    // Select resistance levels independently
    // ---------------------------------------------

    if clusterCount > 0 and resistanceLimit > 0
        for resistanceSlot = 0 to resistanceLimit - 1
            int bestCluster = -1
            float bestScore = -1e10

            for clusterIndex = 0 to clusterCount - 1
                bool alreadyUsed =
                     array.get(
                          clusterUsed,
                          clusterIndex
                     )

                int touchCount =
                     array.get(
                          clusterTouches,
                          clusterIndex
                     )

                float center =
                     array.get(
                          clusterCenters,
                          clusterIndex
                     )

                bool abovePrice =
                     center > close

                float distancePercent =
                     close != 0
                     ? 100.0 *
                       math.abs(center - close) /
                       math.abs(close)
                     : 100000.0

                bool withinDistance =
                     distancePercent <=
                     maximumDistancePercent

                bool sufficientlySeparated = true

                int selectedCount =
                     array.size(activeLevels)

                if selectedCount > 0
                    for selectedIndex = 0 to selectedCount - 1
                        float selectedPrice =
                             array.get(
                                  activeLevels,
                                  selectedIndex
                             )

                        if math.abs(
                             center -
                             selectedPrice
                        ) < minimumLevelSpacing
                            sufficientlySeparated := false
                            break

                if not alreadyUsed and
                   touchCount >= minimumTouches and
                   abovePrice and
                   withinDistance and
                   sufficientlySeparated

                    float proximityScore =
                         1.0 -
                         math.min(
                              distancePercent /
                              maximumDistancePercent,
                              1.0
                         )

                    float finalScore =
                         clusterBaseScore(clusterIndex) +
                         proximityScore *
                         proximityWeight

                    if finalScore > bestScore
                        bestScore := finalScore
                        bestCluster := clusterIndex

            if bestCluster == -1
                break

            array.set(
                 clusterUsed,
                 bestCluster,
                 true
            )

            float selectedLevel =
                 math.round_to_mintick(
                      array.get(
                           clusterCenters,
                           bestCluster
                      )
                 )

            array.push(
                 activeLevels,
                 selectedLevel
            )

            array.push(
                 activeScores,
                 bestScore
            )

            array.push(
                 activeOrigins,
                 array.get(
                      clusterLastBars,
                      bestCluster
                 )
            )

            array.push(
                 activeLabelOffsets,
                 baseLabelOffset +
                 resistanceSlot *
                 labelStagger
            )

    // ---------------------------------------------
    // Select support levels independently
    // ---------------------------------------------

    if clusterCount > 0 and supportLimit > 0
        for supportSlot = 0 to supportLimit - 1
            int bestCluster = -1
            float bestScore = -1e10

            for clusterIndex = 0 to clusterCount - 1
                bool alreadyUsed =
                     array.get(
                          clusterUsed,
                          clusterIndex
                     )

                int touchCount =
                     array.get(
                          clusterTouches,
                          clusterIndex
                     )

                float center =
                     array.get(
                          clusterCenters,
                          clusterIndex
                     )

                bool belowPrice =
                     center < close

                float distancePercent =
                     close != 0
                     ? 100.0 *
                       math.abs(center - close) /
                       math.abs(close)
                     : 100000.0

                bool withinDistance =
                     distancePercent <=
                     maximumDistancePercent

                bool sufficientlySeparated = true

                int selectedCount =
                     array.size(activeLevels)

                if selectedCount > 0
                    for selectedIndex = 0 to selectedCount - 1
                        float selectedPrice =
                             array.get(
                                  activeLevels,
                                  selectedIndex
                             )

                        if math.abs(
                             center -
                             selectedPrice
                        ) < minimumLevelSpacing
                            sufficientlySeparated := false
                            break

                if not alreadyUsed and
                   touchCount >= minimumTouches and
                   belowPrice and
                   withinDistance and
                   sufficientlySeparated

                    float proximityScore =
                         1.0 -
                         math.min(
                              distancePercent /
                              maximumDistancePercent,
                              1.0
                         )

                    float finalScore =
                         clusterBaseScore(clusterIndex) +
                         proximityScore *
                         proximityWeight

                    if finalScore > bestScore
                        bestScore := finalScore
                        bestCluster := clusterIndex

            if bestCluster == -1
                break

            array.set(
                 clusterUsed,
                 bestCluster,
                 true
            )

            float selectedLevel =
                 math.round_to_mintick(
                      array.get(
                           clusterCenters,
                           bestCluster
                      )
                 )

            array.push(
                 activeLevels,
                 selectedLevel
            )

            array.push(
                 activeScores,
                 bestScore
            )

            array.push(
                 activeOrigins,
                 array.get(
                      clusterLastBars,
                      bestCluster
                 )
            )

            array.push(
                 activeLabelOffsets,
                 baseLabelOffset +
                 supportSlot *
                 labelStagger
            )

//==================================================
// 12. Drawing object management
//==================================================

var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()

int requiredObjectCount =
     array.size(activeLevels)

// Delete surplus lines.

while array.size(levelLines) > requiredObjectCount
    line lineToDelete =
         array.pop(levelLines)

    line.delete(lineToDelete)

// Delete surplus labels.

while array.size(levelLabels) > requiredObjectCount
    label labelToDelete =
         array.pop(levelLabels)

    label.delete(labelToDelete)

// Create missing lines.

while array.size(levelLines) < requiredObjectCount
    line newLevelLine = line.new(
         x1 = bar_index,
         y1 = close,
         x2 = bar_index + 1,
         y2 = close,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(
              resistanceColor,
              lineTransparency
         ),
         style = lineStyle,
         width = lineWidth
    )

    array.push(
         levelLines,
         newLevelLine
    )

// Create missing labels.

while array.size(levelLabels) < requiredObjectCount
    label newLevelLabel = label.new(
         x = bar_index,
         y = close,
         text = "",
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_down,
         color = color.new(
              resistanceColor,
              labelTransparency
         ),
         textcolor = color.white,
         size = size.small
    )

    array.push(
         levelLabels,
         newLevelLabel
    )

//==================================================
// 13. Dynamic visual updates
//==================================================

int visibleLevelCount =
     array.size(activeLevels)

if visibleLevelCount > 0
    for levelIndex = 0 to visibleLevelCount - 1
        float levelPrice =
             array.get(
                  activeLevels,
                  levelIndex
             )

        int levelOrigin =
             array.get(
                  activeOrigins,
                  levelIndex
             )

        int currentLabelOffset =
             array.get(
                  activeLabelOffsets,
                  levelIndex
             )

        int labelPosition =
             bar_index +
             currentLabelOffset

        bool isResistance =
             levelPrice >= close

        color levelColor =
             isResistance
             ? resistanceColor
             : supportColor

        float distancePercent =
             close != 0
             ? 100.0 *
               (levelPrice - close) /
               close
             : 0.0

        string levelText =
             str.tostring(
                  levelPrice,
                  format.mintick
             ) +
             " (" +
             str.tostring(
                  distancePercent,
                  "#.##"
             ) +
             "%)"

        int lineStart =
             lineReachInput == "Across chart"
             ? bar_index - 1
             : levelOrigin

        line currentLine =
             array.get(
                  levelLines,
                  levelIndex
             )

        label currentLabel =
             array.get(
                  levelLabels,
                  levelIndex
             )

        line.set_x1(
             currentLine,
             lineStart
        )

        line.set_y1(
             currentLine,
             levelPrice
        )

        line.set_x2(
             currentLine,
             labelPosition
        )

        line.set_y2(
             currentLine,
             levelPrice
        )

        line.set_extend(
             currentLine,
             lineReachInput == "Across chart"
             ? extend.both
             : extend.none
        )

        line.set_color(
             currentLine,
             color.new(
                  levelColor,
                  lineTransparency
             )
        )

        line.set_style(
             currentLine,
             lineStyle
        )

        line.set_width(
             currentLine,
             lineWidth
        )

        label.set_x(
             currentLabel,
             labelPosition
        )

        label.set_y(
             currentLabel,
             levelPrice
        )

        label.set_text(
             currentLabel,
             levelText
        )

        label.set_style(
             currentLabel,
             isResistance
             ? label.style_label_down
             : label.style_label_up
        )

        label.set_color(
             currentLabel,
             color.new(
                  levelColor,
                  labelTransparency
             )
        )

        label.set_textcolor(
             currentLabel,
             isResistance
             ? color.white
             : color.rgb(13, 58, 43)
        )

//==================================================
// 14. Alerts
//==================================================

bool crossedAboveReactionZone = false
bool crossedBelowReactionZone = false

if visibleLevelCount > 0
    for levelIndex = 0 to visibleLevelCount - 1
        float levelPrice =
             array.get(
                  activeLevels,
                  levelIndex
             )

        if close[1] <= levelPrice and
           close > levelPrice
            crossedAboveReactionZone := true

        if close[1] >= levelPrice and
           close < levelPrice
            crossedBelowReactionZone := true

alertcondition(
     crossedAboveReactionZone,
     title = "Adaptive Reaction Zones — Cross Above",
     message = "Price crossed above an adaptive reaction level."
)

alertcondition(
     crossedBelowReactionZone,
     title = "Adaptive Reaction Zones — Cross Below",
     message = "Price crossed below an adaptive reaction level."
)
````
