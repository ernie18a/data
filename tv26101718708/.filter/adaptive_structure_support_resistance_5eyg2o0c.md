# Adaptive Structure Support & Resistance

- url: https://www.tradingview.com/script/5eYg2o0C/
- type: indicator
- pine_id: PUB;ac8cddbcfca44526b2a7599d024e95d3
- version: 2.0

## Description

[b]Chinese description is provided below. Chinese readers, please scroll down to read.[/b]

[i]A structure-based support and resistance framework using confirmed pivots, price clustering, adaptive search ranges, historical reaction analysis and post-break role reversal.[/i]


[b]1. What is this indicator?[/b]

Adaptive Structure Support & Resistance is a market-structure tool designed to identify the support and resistance areas that are currently most relevant to price.

The purpose of this script is not to display every historical swing high and swing low.

Instead, it attempts to answer a more practical question:

[quote]
Among all historical turning points, which price areas still have enough structural significance to matter to the current market?
[/quote]

The script therefore treats support and resistance as a multi-stage structural problem.

The complete process is:

[list=1]
[*]Identify confirmed swing highs and swing lows.
[*]Merge nearby turning points into structural price clusters.
[*]Evaluate the historical importance of each cluster.
[*]Determine how far above and below the current price the model needs to search.
[*]Select the most relevant support and resistance structures.
[*]Evaluate the historical strength of the selected structures.
[*]Convert exact levels into practical support/resistance zones.
[*]Track what happens after a confirmed break.
[*]Require a retest or rebound before confirming a support/resistance role reversal.
[/list]

This means that the script is not simply:

[pine]
ta.pivothigh(...)
ta.pivotlow(...)
[/pine]

followed by two horizontal lines.

Confirmed pivots are only the raw structural observations. Several additional stages are used before a level becomes the displayed support or resistance.


[b]2. Why was this model designed?[/b]

Traditional automatic support/resistance tools often face several practical problems.

[list]
[*][b]Too many levels[/b]

If every historical pivot is plotted independently, the chart can quickly become filled with horizontal lines. Many of those lines represent nearly identical prices or structures that are no longer relevant.

[*][b]A single pivot may not represent a meaningful structure[/b]

A temporary local high or low can occur for many reasons. A more meaningful market structure often forms when price reacts around the same area multiple times.

[*][b]Fixed search distances do not work equally well for every instrument[/b]

A low-volatility instrument may have meaningful support only 10–20% below the current price.

A highly volatile or strongly trending instrument may require a much wider historical price range before a significant support or resistance structure appears.

[*][b]The nearest level is not always the most important level[/b]

A minor pivot located very close to current price may be less meaningful than a slightly more distant area that has produced several strong historical reactions.

[*][b]A breakout does not automatically mean role reversal[/b]

Resistance does not necessarily become support simply because price trades above it once.

Likewise, support does not necessarily become resistance immediately after one breakdown.

[/list]

The model is designed around these problems.

Its goal is therefore not to maximize the number of detected structures, but to reduce historical information into a smaller set of currently relevant structural areas.


[b]3. Where can this indicator be used?[/b]

The script is intended for standard price charts where historical swing structure is meaningful.

Typical applications include:

[list]
[*]Stocks
[*]Indices
[*]ETFs
[*]Futures
[*]Foreign exchange
[*]Cryptocurrency
[*]Other liquid instruments with usable price history
[/list]

It can be used on different timeframes, but the meaning of the detected structure changes with the timeframe.

For example:

[list]
[*]A support structure on a 15-minute chart describes short-term intraday structure.
[*]A support structure on a daily chart describes a larger swing structure.
[*]A support structure on a weekly chart may represent a long-term structural price area.
[/list]

The indicator does not automatically convert a lower-timeframe level into a higher-timeframe level.

The displayed support and resistance always belong to the chart timeframe being analyzed.


[b]4. Core principle: confirmed structural pivots[/b]

The first stage identifies confirmed pivot highs and pivot lows.

A pivot requires price bars on both sides of the potential turning point.

Representative logic:

[pine]
float pivotHigh = ta.pivothigh(
    high,
    pivotLeftBarsInput,
    pivotRightBarsInput)

float pivotLow = ta.pivotlow(
    low,
    pivotLeftBarsInput,
    pivotRightBarsInput)
[/pine]

The important word here is [b]confirmed[/b].

A newly formed high is not immediately considered a structural resistance observation.

A newly formed low is not immediately considered a structural support observation.

The model waits for the configured number of right-side bars before confirming the pivot.

[quote]
The intention is to sacrifice some immediacy in exchange for more stable structural observations.
[/quote]

This also means that pivot detection naturally contains confirmation delay.

That delay is part of the methodology rather than an attempt to predict a turning point before it exists.


[b]5. Core principle: price clustering[/b]

Multiple pivots occurring around similar prices should not necessarily be treated as unrelated horizontal levels.

For this reason, the script groups nearby pivot observations into price clusters.

Conceptually:

[pine]
float distancePercent =
    math.abs(price - clusterPrice) /
    clusterPrice *
    100.0

if distancePercent <= mergePercent
    matchingIndex := clusterIndex
[/pine]

If several historical lows occur around approximately the same area, they can contribute to one support structure.

The same process applies to historical highs when building resistance structures.

This changes the interpretation from:

[quote]
"Price touched 12.01, 12.05 and 12.09."
[/quote]

to:

[quote]
"Price has repeatedly reacted around the same structural area."
[/quote]

The cluster center is updated using the accumulated structural contribution of its observations rather than simply keeping the first pivot price.


[b]6. Core principle: structural ranking[/b]

Not every cluster deserves the same importance.

Each pivot contributes a base structural score that incorporates relative volume participation and recency.

A simplified representation of the calculation is:

[pine]
float pivotBaseScore =
    1.0 +
    volumeWeightInput * volumeRatio +
    recencyWeightInput * recencyFactor
[/pine]

When several pivots belong to the same cluster, their contributions accumulate.

After the candidate clusters have been created, the model evaluates structures within the active search range.

The final ranking also gives a limited preference to structures nearer the current price:

[pine]
float candidateRank =
    accumulatedBaseScore +
    proximityBonusInput *
    proximityFactor
[/pine]

Proximity is therefore useful, but it is not the entire model.

A level is not selected only because it is the nearest pivot.


[b]7. Relative volume participation[/b]

Historical price reactions can contain different levels of market participation.

For each pivot observation, volume is compared with its recent average.

Representative logic:

[pine]
float volumeRatio =
    pivotAverageVolume > 0.0
        ? math.min(
            pivotVolume / pivotAverageVolume,
            3.0)
        : 1.0
[/pine]

Higher relative volume can contribute additional structural weight.

However, volume is only one component.

The model does not assume that high volume by itself automatically creates support or resistance.


[b]8. Historical reaction analysis[/b]

A structural level is more informative when historical interactions with that area produced meaningful price responses.

For a support pivot, the model measures the maximum upside response after the confirmed low during a configurable observation window.

Conceptually:

[pine]
float reactionPercent =
    (highestPostPivotPrice / pivotPrice - 1.0) *
    100.0
[/pine]

For resistance, the opposite calculation is used:

[pine]
float reactionPercent =
    (pivotPrice - lowestPostPivotPrice) /
    pivotPrice *
    100.0
[/pine]

This allows the model to distinguish between two different situations.

[list]
[*]A level that price touched repeatedly but barely reacted to.
[*]A level where historical interaction repeatedly produced meaningful rejection or recovery.
[/list]

These situations are not treated as structurally equivalent.


[b]9. Why the search range is adaptive[/b]

One of the main design features of this script is that support and resistance do not have to use the same fixed search distance.

A fixed 25% range can work well for one instrument but fail on another.

A fixed 100% range may capture important historical structures, but can also introduce unnecessarily distant structures when meaningful nearby levels already exist.

The Auto mode therefore uses progressive search tiers.

[list=1]
[*]25%
[*]50%
[*]75%
[*]100%
[/list]

The algorithm first asks whether the nearest tier contains a structure that satisfies minimum structural requirements.

If it does, the search can stop.

If it does not, the model expands to the next tier.

Representative logic:

[pine]
if distancePercent <= 25.0
    result := 25.0
else if distancePercent <= 50.0 and maximumRangePercent >= 50.0
    result := 50.0
else if distancePercent <= 75.0 and maximumRangePercent >= 75.0
    result := 75.0
else if distancePercent <= 100.0 and maximumRangePercent >= 100.0
    result := 100.0
[/pine]

The important feature is that [b]support and resistance are evaluated independently[/b].

For example:

[quote]
Support search range: 25%

Resistance search range: 75%
[/quote]

This can occur when a meaningful support structure exists close below price, while the next meaningful resistance structure is much farther above the market.


[b]10. The model does not stop at the first nearby pivot[/b]

Adaptive search would not be useful if any small nearby pivot could immediately stop expansion.

The model therefore requires a nearby structure to satisfy minimum quality conditions.

Conceptually:

[pine]
bool qualifiedStructure =
    touchCount >= minimumStructureTouchesInput and
    structureQuality >= adaptiveQualityThreshold
[/pine]

Only a qualified structure can stop the search from expanding to the next distance tier.

This prevents a minor local pivot from automatically hiding a larger and more meaningful historical structure.


[b]11. Volatility-aware search adjustment[/b]

Volatility also affects how much evidence is required from nearby structures.

ATR is converted into a percentage of price:

[pine]
float currentAtrPercent =
    close > 0.0
        ? averageTrueRange / close * 100.0
        : 0.0
[/pine]

When volatility is high, the minimum structural-quality requirement is increased moderately.

Representative logic:

[pine]
if currentAtrPercent >= 6.0
    adaptiveQualityThreshold :=
        minimumStructureQualityInput + 8.0
else if currentAtrPercent >= 4.0
    adaptiveQualityThreshold :=
        minimumStructureQualityInput + 5.0
[/pine]

The purpose is not simply:

[quote]
Higher volatility = wider search range.
[/quote]

Instead:

[quote]
Higher volatility = minor nearby structures need stronger evidence before they are allowed to stop the search.
[/quote]

This distinction is important.

Volatility assists the structural search; it does not independently determine support or resistance.


[b]12. Structural quality used by adaptive search[/b]

To decide whether search expansion can stop, a separate quality model evaluates candidate clusters.

The quality assessment combines several components:

[list]
[*]Number of structural interactions
[*]Average historical reaction
[*]Relative volume participation
[*]Recency
[*]Accumulated structural contribution
[/list]

A simplified representation is:

[pine]
float structureQuality =
    touchComponent +
    reactionComponent +
    volumeComponent +
    recencyComponent +
    baseScoreComponent
[/pine]

The result is bounded to a 0–100 scale.

[pine]
clampValue(
    structureQuality,
    0.0,
    100.0)
[/pine]

This quality score primarily answers:

[quote]
"Is this structure meaningful enough for the adaptive search to stop here?"
[/quote]

It is separate from the final displayed strength score.


[b]13. Selecting the final support and resistance[/b]

After the adaptive search distance has been determined, the model evaluates all valid clusters inside that range.

For support:

[list]
[*]The cluster must be below or near the current price.
[*]It must remain inside the active support search range.
[*]Its structural score is combined with a proximity adjustment.
[/list]

For resistance, the same process is applied above current price.

The highest-ranked candidate becomes the primary structural level.

This means that the displayed level represents the outcome of:

[quote]
confirmed pivots → clustering → structural scoring → adaptive distance selection → final ranking
[/quote]

rather than simply selecting the latest high or low.


[b]14. Strength score: what does 0–100 mean?[/b]

After the primary support and resistance levels are selected, the model performs a second evaluation.

This stage describes the [b]historical quality of the selected structure[/b].

The strength score considers:

[list]
[*]Touch count
[*]Average reaction after historical interactions
[*]Relative volume participation
[*]Recency
[*]Repeated crossings of the level
[*]Fast failed breaks
[/list]

The positive components are conceptually:

[pine]
float rawStrengthScore =
    touchComponent +
    reactionComponent +
    volumeComponent +
    recencyComponent +
    stabilityComponent -
    totalPenalty
[/pine]

Repeated crossings reduce the score:

[pine]
float totalPenalty =
    crossingCount *
    crossingPenaltyInput +
    failedBreakCount *
    failedBreakPenaltyInput
[/pine]

The final value is limited to 0–100.

The interface converts it into:

[list]
[*]Weak
[*]Medium
[*]Strong
[/list]

The score should [b]not[/b] be interpreted as:

[quote]
82 points = 82% probability that support will hold.
[/quote]

It does not represent probability, expected return or strategy win rate.

It is a normalized description of historical structural behavior.


[b]15. Why repeated crossings reduce strength[/b]

A price level may appear frequently in historical data simply because the market traded through it many times.

That does not necessarily make the level stronger.

A structurally useful support or resistance area usually produces some degree of rejection, recovery or directional response.

For this reason, the script counts repeated close-to-close crossings.

Representative logic:

[pine]
bool crossedAbove =
    olderClose <= level and
    newerClose > level

bool crossedBelow =
    olderClose >= level and
    newerClose < level

if crossedAbove or crossedBelow
    crossingCount += 1
[/pine]

Frequent crossings therefore reduce structural strength instead of increasing it automatically.


[b]16. Why support and resistance are displayed as zones[/b]

Real market structure rarely operates at one mathematically exact tick.

Several pivots may occur at slightly different prices while still representing the same area.

The script therefore displays:

[list]
[*]A center structural level
[*]A surrounding structural zone
[/list]

Zone width contains two elements.

First, the actual spread of the clustered pivot prices.

Second, a small volatility-sensitive padding:

[pine]
float zonePadding =
    math.max(
        selectedLevel *
            minimumZoneWidthPercentInput /
            100.0,
        averageTrueRange *
            atrZoneMultiplierInput)
[/pine]

The center line is useful for reference.

The surrounding area is intended to represent the broader price region where structural interaction may occur.


[b]17. Breakout detection uses the previous structure[/b]

There is an important implementation detail in breakout detection.

When price breaks resistance, the current resistance calculation may immediately change because current price itself has changed.

If breakout detection used only the newly recalculated structure, the model could lose the level that price actually broke.

The script therefore references the previously confirmed zone:

[pine]
float previousResistanceZoneUpperBound =
    resistanceZoneUpperBound[1]

float resistanceBreakTrigger =
    previousResistanceZoneUpperBound *
    (1.0 +
        breakoutBufferPercentInput /
        100.0)
[/pine]

The same principle applies to support breakdowns.

This allows the structural state machine to remember the actual area involved in the break.


[b]18. Resistance does not immediately become support[/b]

A confirmed break starts a new structural state.

The model uses named states internally:

[pine]
const int STATE_NORMAL = 0
const int STATE_BREAKOUT_WAITING_RETEST = 1
const int STATE_RESISTANCE_TO_SUPPORT = 2
const int STATE_BREAKDOWN_WAITING_REBOUND = -1
const int STATE_SUPPORT_TO_RESISTANCE = -2
[/pine]

After resistance is broken:

[list=1]
[*]The previous resistance area is stored.
[*]The model enters a "waiting for retest" state.
[*]Price is monitored for a return toward the old resistance.
[*]If the retest holds, the former resistance may become support.
[*]If price falls back through the old zone, the breakout is treated as failed.
[/list]

Representative confirmation logic:

[pine]
bool testedFormerResistance =
    low <=
    roleReversalUpperBound *
    (1.0 +
        retestTolerancePercentInput /
        100.0)

bool retestHeld =
    testedFormerResistance and
    close > roleReversalUpperBound
[/pine]

Only after this process can the old resistance be promoted to support.


[b]19. Support-to-resistance uses the opposite process[/b]

After support is broken:

[list=1]
[*]The previous support area is stored.
[*]The model waits for a rebound.
[*]Price must test the former support area.
[*]If price is rejected and cannot recover the area, the former support can become resistance.
[/list]

Representative logic:

[pine]
bool testedFormerSupport =
    high >=
    roleReversalLowerBound *
    (1.0 -
        retestTolerancePercentInput /
        100.0)

bool reboundRejected =
    testedFormerSupport and
    close < roleReversalLowerBound
[/pine]

This creates a distinction between:

[quote]
price crossed a level
[/quote]

and:

[quote]
the market actually completed a structural role reversal.
[/quote]


[b]20. Failed breakout and failed breakdown[/b]

The script also monitors invalidation after a break.

If resistance is broken but price quickly returns below the former resistance structure, the event can be treated as a failed breakout.

If support is broken but price quickly recovers the former support structure, the event can be treated as a failed breakdown.

These events reset the pending role-reversal process rather than automatically promoting the old structure to a new role.


[b]21. How to use the indicator[/b]

A simple workflow is:

[list=1]
[*][b]Locate the current support[/b]

Identify the support area below the current market.

This is the structural area currently considered most relevant by the model.

[*][b]Locate the current resistance[/b]

Identify the active structural resistance above price.

[*][b]Read the strength[/b]

A stronger score indicates that the selected structure has historically shown better structural characteristics under this model.

It does not mean the level cannot break.

[*][b]Read "Why this level?"[/b]

The dashboard shows the number of historical structural interactions and the average subsequent reaction.

This gives a plain-language explanation for why the level has been selected.

[*][b]Check how far the algorithm searched[/b]

For example:

"Below 25% | Above 75%"

means that qualified support was available relatively close below current price, while the model had to inspect a much wider area to find qualified resistance.

[*][b]Observe the current structural state[/b]

The dashboard may report states such as:

"Price is between support and resistance"

"Resistance broken; waiting for a retest"

"Former resistance is currently acting as support"

"Support broken; waiting for a rebound"

"Former support is currently acting as resistance"

[/list]


[b]22. Practical interpretation[/b]

The indicator is designed primarily as a [b]context tool[/b].

For example:

[quote]
Price approaching strong support does not automatically mean "buy".

It means price is entering an area that has meaningful structural evidence and may deserve closer observation.
[/quote]

Likewise:

[quote]
Price approaching resistance does not automatically mean "sell".

It identifies an area where historical supply or rejection has been structurally significant.
[/quote]

A trader can then combine that context with his or her own analysis of:

[list]
[*]Price action
[*]Volume
[*]Trend
[*]Market regime
[*]Higher-timeframe structure
[*]Risk/reward
[*]Position sizing
[*]Independent fundamental or macro analysis
[/list]

The script itself does not generate automatic buy or sell orders.


[b]23. Dashboard explanation[/b]

The dashboard intentionally avoids exposing every internal statistical variable.

Instead, it translates the model into simpler trading language.

[b]Support[/b]

Current selected support level and its strength evaluation.

[b]Why this level?[/b]

Shows how many historical structural interactions contributed to the area and the average subsequent upside response.

[b]Resistance[/b]

Current selected resistance level and strength evaluation.

[b]Why this level?[/b]

Shows historical interactions and the average subsequent downside response.

[b]How far it searched[/b]

Shows the active adaptive search range below and above the current market.

[b]Current state[/b]

Explains whether price remains between the structures, has broken one of them, is waiting for confirmation, or has completed a role reversal.


[b]24. Main settings[/b]

[b]Lookback Bars[/b]

Controls how much historical price data is considered when constructing structural clusters.

A longer lookback includes more historical structure but may also retain older information.

[b]Pivot Left Bars / Pivot Right Bars[/b]

Control how strict pivot confirmation is.

Larger values generally identify larger structural turns but require more confirmation.

[b]Price Cluster Width %[/b]

Controls how close two pivot observations must be before they can belong to the same structural area.

[b]Search Mode[/b]

Auto allows support and resistance to determine their own search distances.

Manual uses a fixed maximum distance.

[b]Maximum Auto Range[/b]

Defines the maximum distance the adaptive search is allowed to inspect.

[b]Minimum Structure Quality[/b]

Controls how meaningful a structure must be before it can stop automatic search expansion.

[b]Minimum Valid Tests[/b]

Defines the minimum number of structural observations required for a candidate to qualify during adaptive search.

[b]Reaction Observation Bars[/b]

Defines how many bars after a historical pivot are examined when measuring its subsequent price reaction.

[b]Break Confirmation Buffer[/b]

Adds a small margin beyond the old structural zone before a break is considered confirmed.

[b]Retest Tolerance[/b]

Controls how close price must return to the former structural area during retest/rebound evaluation.


[b]25. Alerts[/b]

Alert conditions are provided for:

[list]
[*]Resistance break
[*]Support break
[*]Resistance confirmed as support
[*]Support confirmed as resistance
[*]Failed breakout
[*]Failed breakdown
[/list]

When close confirmation is enabled, structural break events are evaluated on confirmed bars.


[b]26. About repainting and structural updates[/b]

This script should not be interpreted as a system that predicts pivots before they are confirmed.

Pivot highs and lows require right-side confirmation bars.

Therefore:

[quote]
A newly forming pivot is not shown as confirmed structure until sufficient bars exist to confirm it.
[/quote]

Once new market data arrives, the active support and resistance can still change for legitimate structural reasons.

Examples include:

[list]
[*]A new confirmed pivot enters the calculation.
[*]Several new observations create a stronger price cluster.
[*]Current price moves enough to change the relevant search region.
[*]An older observation exits the configured lookback window.
[*]A breakout creates a role-reversal state.
[/list]

This is dynamic structural recalculation, not a promise that current support and resistance will remain fixed forever.


[b]27. Why these components belong together[/b]

This script combines several concepts, but they are not independent indicators placed together for convenience.

Each component solves a different stage of the same problem.

[list=1]
[*][b]Confirmed pivots[/b] identify potential structural observations.
[*][b]Price clustering[/b] converts nearby observations into common price areas.
[*][b]Structural ranking[/b] determines which areas contain more meaningful historical evidence.
[*][b]Adaptive search[/b] determines how far the model needs to inspect for an adequate structure.
[*][b]Reaction analysis[/b] measures how price historically responded to that structure.
[*][b]Strength evaluation[/b] summarizes the historical quality of the selected area.
[*][b]ATR-based zone construction[/b] converts an exact center price into a practical market area.
[*][b]The role-reversal state machine[/b] manages what happens after the structure is broken.
[/list]

[quote]
The components are therefore sequential stages of one structural support/resistance framework rather than a mashup of unrelated indicators.
[/quote]


[b]28. What is distinctive about this implementation?[/b]

The primary design characteristics of this implementation are:

[list]
[*]Nearby pivots are aggregated into structural price clusters rather than displayed independently.
[*]Support and resistance use independent adaptive search ranges.
[*]Search expansion depends on structural quality rather than distance alone.
[*]Volatility modifies the evidence required from nearby structures.
[*]Level selection and level-strength evaluation are deliberately separated.
[*]Repeated crossings and failed breaks can reduce structural strength.
[*]Support and resistance are represented as price areas instead of exact single-price barriers.
[*]Break detection references the previous structural zone.
[*]Role reversal requires confirmation through a state machine instead of occurring immediately after a single crossing.
[*]The chart intentionally focuses on the current relevant structure rather than filling the chart with historical event markers.
[/list]


[b]29. Limitations[/b]

No support/resistance algorithm can know with certainty whether a level will hold or fail.

Important limitations include:

[list]
[*]Pivot confirmation introduces intentional delay.
[*]Support and resistance may change as new information becomes available.
[*]Historical reaction does not guarantee future reaction.
[*]A high strength score is not a probability of success.
[*]Very new instruments with limited history may not contain enough structural observations.
[*]Strong trend transitions can invalidate historical structures quickly.
[*]Volume-based components depend on the quality and meaning of the instrument's volume data.
[*]Different timeframes can produce materially different support and resistance structures.
[*]Synthetic or non-standard chart types may use transformed OHLC values and can therefore produce different structural results.
[/list]


[b]30. Final note[/b]

[quote]
Support and resistance should be understood as areas of market interaction, not guaranteed turning points.

The purpose of this indicator is to organize historical structure and reduce it into a small number of currently relevant price areas.

It is an analytical framework, not an automatic trading system.
[/quote]

[i]This script is intended for market-structure analysis and educational use. It does not constitute investment advice, a recommendation, or a guarantee of future market performance.[/i]


────────────────────────────────────


[b]中文说明[/b]

[b]1. 这个指标是什么？[/b]

Adaptive Structure Support & Resistance 是一个基于市场历史结构，自动寻找当前价格上下方关键支撑与压力区域的分析工具。

它解决的并不是：

[quote]
“历史上哪里出现过高点和低点？”
[/quote]

而是试图解决一个更实际的问题：

[quote]
“历史上这么多高低点里，哪些价格区域到现在仍然具有足够的结构意义，值得当前继续关注？”
[/quote]

所以，这个指标不是简单地把每一个 Pivot High 和 Pivot Low 都画成水平线。

完整计算过程包括：

[list=1]
[*]识别已经确认的历史高低结构。
[*]把价格相近的多个结构合并成一个价格簇。
[*]评价不同价格簇的历史结构意义。
[*]分别判断寻找支撑和压力到底需要看多远。
[*]从有效搜索范围中选择当前更重要的支撑与压力。
[*]评价被选中位置过去的实际价格反应。
[*]将精确价格转化为更加符合实际交易的撑压区域。
[*]价格突破或跌破以后保存原结构。
[*]通过回踩或反抽确认撑压角色是否真正发生转换。
[/list]

因此，Pivot 只是整个模型的第一步，而不是最终结果。


[b]2. 为什么要做这套模型？[/b]

传统的自动支撑压力工具经常存在几个问题。

[list]
[*][b]画出来的线太多[/b]

如果把每个前高前低全部保留下来，时间稍长以后主图会出现大量水平线。

不仅影响阅读，而且其中很多价格其实属于同一个结构。

[*][b]单个高低点不一定有意义[/b]

市场临时出现一个局部最高点或最低点，并不能说明这个价格一定存在真正的供需结构。

如果不同时间价格多次来到相近区域并产生反应，它所代表的结构意义通常更加完整。

[*][b]不同标的不能使用完全相同的搜索距离[/b]

有些股票距离现价下方 20% 就存在非常明确的历史结构。

有些高波动、长期趋势较强的股票，却可能需要向下或者向上看 50%、75% 甚至更远，才能找到真正有意义的位置。

[*][b]距离最近的不一定最重要[/b]

现价附近可能存在一个很小的 Pivot，但稍微远一点的位置可能历史上被多次验证，并且每次都出现较大价格反应。

[*][b]突破并不等于立刻完成撑压转换[/b]

突破压力一次，不应该马上认为压力已经变成支撑。

跌破支撑一次，也不应该马上认为原支撑已经成为新压力。

[/list]

所以这套模型的设计目标不是“尽量多找线”。

而是：

[quote]
尽量把复杂的历史价格结构压缩成少量、当前更值得关注的支撑和压力区域。
[/quote]


[b]3. 可以用在哪里？[/b]

只要历史价格结构具有一定参考意义，理论上都可以使用，例如：

[list]
[*]股票
[*]指数
[*]ETF
[*]期货
[*]外汇
[*]加密资产
[*]其他具有正常历史行情数据的流动性标的
[/list]

不同周期看到的是不同级别的结构。

例如：

[list]
[*]15分钟图得到的是偏短线结构。
[*]日线得到的是波段级结构。
[*]周线得到的是更长期的历史结构。
[/list]

指标不会把15分钟的支撑自动解释成日线支撑。

所有计算都基于当前图表所使用的周期。


[b]4. 第一步：确认历史结构高低点[/b]

模型首先通过已经确认的 Pivot High 与 Pivot Low 获取历史结构观察点。

核心逻辑：

[pine]
float pivotHigh = ta.pivothigh(
    high,
    pivotLeftBarsInput,
    pivotRightBarsInput)

float pivotLow = ta.pivotlow(
    low,
    pivotLeftBarsInput,
    pivotRightBarsInput)
[/pine]

这里最重要的是“确认”。

一个刚刚形成的高点不会马上成为正式压力结构。

一个刚刚形成的低点也不会马上成为正式支撑结构。

需要等待右侧一定数量的K线完成确认。

所以模型主动接受一定的确认延迟，用来减少把尚未成立的短期极值直接当成重要结构的情况。


[b]5. 第二步：把相近价格合并成一个结构[/b]

如果历史上存在：

[quote]
12.01

12.05

12.09
[/quote]

这三个低点，实际上它们很可能描述的是同一片支撑区域，而不是三条完全独立的支撑线。

所以系统会计算不同 Pivot 之间的价格距离：

[pine]
float distancePercent =
    math.abs(price - clusterPrice) /
    clusterPrice *
    100.0

if distancePercent <= mergePercent
    matchingIndex := clusterIndex
[/pine]

如果距离足够接近，就把它们合并到同一个价格结构中。

这样模型关注的就不再是：

[quote]
“12.01碰过一次”
[/quote]

而是：

[quote]
“12元附近这个区域历史上反复出现过结构反应。”
[/quote]


[b]6. 第三步：给历史结构进行初步排序[/b]

并不是所有 Pivot 对结构的重要性都一样。

模型会考虑：

[list]
[*]当时成交量相对大小
[*]这个结构距离现在有多久
[*]多个 Pivot 是否属于同一个价格区域
[/list]

基础贡献大致表现为：

[pine]
float pivotBaseScore =
    1.0 +
    volumeWeightInput * volumeRatio +
    recencyWeightInput * recencyFactor
[/pine]

多个相近 Pivot 被合并后，它们的结构贡献会累积。

最后选择当前结构时，还会给予距离现价较近的位置一定加分：

[pine]
float candidateRank =
    accumulatedBaseScore +
    proximityBonusInput *
    proximityFactor
[/pine]

但这里需要注意：

[quote]
“距离近”只是一个因素，并不是谁离现价最近就一定选择谁。
[/quote]


[b]7. 成交量在这里做什么？[/b]

模型会把 Pivot 当时的成交量与近期平均成交量进行比较。

例如：

[pine]
float volumeRatio =
    pivotAverageVolume > 0.0
        ? math.min(
            pivotVolume / pivotAverageVolume,
            3.0)
        : 1.0
[/pine]

如果某个结构形成时伴随更明显的市场参与，它可以得到额外权重。

但是成交量并不会单独决定支撑压力。

它只是结构评价中的一个辅助信息。


[b]8. 历史触碰以后到底有没有真正反应？[/b]

一个位置历史上碰过很多次，并不代表它一定很重要。

关键还要看：

[quote]
碰到以后，价格到底有没有发生真正的反向运动？
[/quote]

对于历史支撑 Pivot，系统观察之后一定K线范围内出现的最大向上反应。

核心思想：

[pine]
float reactionPercent =
    (highestPostPivotPrice / pivotPrice - 1.0) *
    100.0
[/pine]

对于历史压力，则计算后续最大回落：

[pine]
float reactionPercent =
    (pivotPrice - lowestPostPivotPrice) /
    pivotPrice *
    100.0
[/pine]

这样能够区别：

[list]
[*]一个历史上经常出现，但价格几乎没有明显反应的位置。
[*]一个每次靠近以后，价格都出现较明显反转或回撤的位置。
[/list]


[b]9. 为什么搜索距离必须智能调整？[/b]

这是这个模型比较重要的一部分。

固定使用25%的搜索范围并不适合所有标的。

固定使用100%，又可能在不必要的情况下把非常遥远的历史结构纳入计算。

所以自动模式采用：

[list=1]
[*]25%
[*]50%
[*]75%
[*]100%
[/list]

逐级寻找。

核心映射逻辑：

[pine]
if distancePercent <= 25.0
    result := 25.0
else if distancePercent <= 50.0 and maximumRangePercent >= 50.0
    result := 50.0
else if distancePercent <= 75.0 and maximumRangePercent >= 75.0
    result := 75.0
else if distancePercent <= 100.0 and maximumRangePercent >= 100.0
    result := 100.0
[/pine]

如果25%以内已经存在合格结构，就可以停止。

如果没有，就扩大到50%。

依次类推。


[b]10. 支撑和压力是分别搜索的[/b]

支撑和压力并不会强制使用同一个范围。

完全可能出现：

[quote]
下方支撑搜索：25%

上方压力搜索：75%
[/quote]

它表达的意思是：

下方距离现价比较近的地方已经存在足够明确的历史支撑结构。

但是上方近距离没有达到要求的压力，所以模型继续向更远的位置寻找。


[b]11. 为什么不是25%以内随便有个Pivot就停止？[/b]

如果只要附近出现一个 Pivot 就停止寻找，所谓智能搜索就没有意义。

因此，候选结构必须同时满足最低触碰次数和最低结构质量。

例如：

[pine]
bool qualifiedStructure =
    touchCount >= minimumStructureTouchesInput and
    structureQuality >= adaptiveQualityThreshold
[/pine]

这意味着：

[quote]
附近有结构 ≠ 附近有足够好的结构。
[/quote]

如果近端只是一个很弱的小级别价格点，系统仍然可以继续扩大搜索范围。


[b]12. 波动率为什么也参与？[/b]

系统使用 ATR 相对于当前价格的比例观察标的自身波动程度。

[pine]
float currentAtrPercent =
    close > 0.0
        ? averageTrueRange / close * 100.0
        : 0.0
[/pine]

高波动股票附近出现小 Pivot 非常正常。

因此，对于高波动标的，系统会适当提高“附近结构足够好”的要求。

例如：

[pine]
if currentAtrPercent >= 6.0
    adaptiveQualityThreshold :=
        minimumStructureQualityInput + 8.0
else if currentAtrPercent >= 4.0
    adaptiveQualityThreshold :=
        minimumStructureQualityInput + 5.0
[/pine]

这里不是：

[quote]
“ATR越高，搜索距离一定越远。”
[/quote]

而是：

[quote]
“波动越高，附近的小结构必须更有说服力，才能阻止系统继续向外寻找。”
[/quote]


[b]13. 智能搜索中的结构质量怎么计算？[/b]

用于决定“是否还要继续扩大搜索范围”的结构质量，主要包含：

[list]
[*]历史触碰次数
[*]触碰后的平均反应
[*]相对成交量
[*]结构新旧程度
[*]多个结构累积后的基础得分
[/list]

可以简化理解为：

[pine]
float structureQuality =
    touchComponent +
    reactionComponent +
    volumeComponent +
    recencyComponent +
    baseScoreComponent
[/pine]

最后压缩到0–100：

[pine]
clampValue(
    structureQuality,
    0.0,
    100.0)
[/pine]

这个分数主要解决的是：

[quote]
“这个位置够不够好，好到可以不用继续向外找了？”
[/quote]


[b]14. 最终支撑压力怎么选？[/b]

确定搜索范围以后，系统会重新检查范围内所有候选结构。

支撑必须位于现价下方或附近。

压力必须位于现价上方或附近。

最后比较：

[list]
[*]历史结构累积得分
[*]与当前价格的距离
[/list]

选择当前 Rank 更高的结构。

所以最终看到的线经历了：

[quote]
Pivot确认
→ 相近价格聚类
→ 结构评价
→ 智能搜索距离
→ 范围内重新排序
→ 最终支撑压力
[/quote]


[b]15. 0–100强度分数到底是什么意思？[/b]

当最终支撑压力确定以后，系统会再做一次独立评价。

这一部分不是用来重新选择线，而是告诉你：

[quote]
“现在已经选中的这条结构，历史质量到底怎么样？”
[/quote]

主要考虑：

[list]
[*]触碰次数
[*]历史平均反应
[*]相对成交量
[*]结构是否较新
[*]是否经常被来回穿越
[*]是否出现过快速失败突破
[/list]

大致计算结构：

[pine]
float rawStrengthScore =
    touchComponent +
    reactionComponent +
    volumeComponent +
    recencyComponent +
    stabilityComponent -
    totalPenalty
[/pine]

其中反复穿越和失败突破会扣分：

[pine]
float totalPenalty =
    crossingCount *
    crossingPenaltyInput +
    failedBreakCount *
    failedBreakPenaltyInput
[/pine]

最后得到0–100，并转化成：

[list]
[*]弱
[*]中
[*]强
[/list]

但是一定不要理解成：

[quote]
“82分 = 未来82%概率守住。”
[/quote]

它不是胜率，也不是未来预测概率。

它只是对历史结构质量进行标准化后的评分。


[b]16. 为什么反复穿越反而扣分？[/b]

有些价格历史上出现很多次，仅仅是因为市场一直在这个位置上下震荡。

如果价格能够非常轻松地不断穿过这个位置，它未必是真正强支撑或强压力。

所以系统统计价格穿越中心结构的情况：

[pine]
bool crossedAbove =
    olderClose <= level and
    newerClose > level

bool crossedBelow =
    olderClose >= level and
    newerClose < level
[/pine]

穿越越频繁，结构稳定性评价越低。


[b]17. 为什么画的是区域，不只是一条线？[/b]

真实交易中，很少存在一个价格精确到最小报价单位以后永远有效。

历史多个 Pivot 本身就可能分布在一个小区间里。

所以模型保留：

[list]
[*]中心结构价格
[*]结构区域
[/list]

区域宽度由：

[list]
[*]历史 Pivot 聚类本身的价格范围
[*]少量 ATR 波动缓冲
[/list]

共同决定。

核心思想：

[pine]
float zonePadding =
    math.max(
        selectedLevel *
            minimumZoneWidthPercentInput /
            100.0,
        averageTrueRange *
            atrZoneMultiplierInput)
[/pine]

中心线用于定位。

阴影区域用于表达真实市场中的价格博弈带。


[b]18. 为什么突破使用上一根K线的压力？[/b]

这是结构判断里很重要的一点。

当价格突破压力以后，如果马上重新计算当前压力，那么旧压力可能已经被系统替换。

这样反而不知道价格刚刚突破的到底是哪一个结构。

所以突破判断使用突破之前已经存在的压力区域：

[pine]
float previousResistanceZoneUpperBound =
    resistanceZoneUpperBound[1]
[/pine]

并基于它计算突破标准：

[pine]
float resistanceBreakTrigger =
    previousResistanceZoneUpperBound *
    (1.0 +
        breakoutBufferPercentInput /
        100.0)
[/pine]

支撑跌破同理。


[b]19. 突破压力以后为什么不能马上变成支撑？[/b]

系统内部使用一个状态机：

[pine]
const int STATE_NORMAL = 0
const int STATE_BREAKOUT_WAITING_RETEST = 1
const int STATE_RESISTANCE_TO_SUPPORT = 2
const int STATE_BREAKDOWN_WAITING_REBOUND = -1
const int STATE_SUPPORT_TO_RESISTANCE = -2
[/pine]

突破压力以后：

[list=1]
[*]保存原来的压力区域。
[*]进入“等待回踩”状态。
[*]观察价格是否重新回来测试原压力。
[*]如果回踩以后守住，才确认压力转支撑。
[*]如果重新跌回原结构下方，则视为突破失败。
[/list]

回踩逻辑类似：

[pine]
bool testedFormerResistance =
    low <=
    roleReversalUpperBound *
    (1.0 +
        retestTolerancePercentInput /
        100.0)

bool retestHeld =
    testedFormerResistance and
    close > roleReversalUpperBound
[/pine]


[b]20. 支撑转压力同样需要确认[/b]

支撑跌破以后：

[list=1]
[*]保存原来的支撑。
[*]等待价格反抽。
[*]观察反抽是否重新接触原支撑区域。
[*]如果无法重新站回，才确认原支撑变成压力。
[/list]

例如：

[pine]
bool testedFormerSupport =
    high >=
    roleReversalLowerBound *
    (1.0 -
        retestTolerancePercentInput /
        100.0)

bool reboundRejected =
    testedFormerSupport and
    close < roleReversalLowerBound
[/pine]

因此模型会区分：

[quote]
“价格只是穿过了一下”
[/quote]

与：

[quote]
“原来的市场结构真正完成了角色转换”
[/quote]


[b]21. 实际怎么使用？[/b]

最简单的使用顺序：

[list=1]
[*][b]先看支撑在哪里[/b]

这是当前算法认为下方更值得关注的历史结构区域。

[*][b]再看压力在哪里[/b]

这是当前上方更值得关注的历史结构区域。

[*][b]看强度[/b]

强度越高，代表这个结构在模型评价中具有更好的历史表现。

但再强也可能被突破。

[*][b]看“为什么是它？”[/b]

这里会直接告诉你历史上大致碰过多少次，以及碰到以后平均出现多大的反向运动。

[*][b]看“算法看了多远”[/b]

例如：

下方25%｜上方75%

意味着下方较近就找到了合格支撑，但是上方需要看更远，才找到合格压力。

[*][b]最后看“现在怎么看”[/b]

这里会告诉你目前属于：

价格仍在支撑压力之间；

突破压力等待回踩；

原压力已经转为支撑；

跌破支撑等待反抽；

原支撑已经转为压力；

等结构状态。
[/list]


[b]22. 应该如何理解支撑压力？[/b]

这个指标最适合作为“位置和结构背景工具”。

例如：

[quote]
价格到了强支撑，不等于自动买入。

它代表价格已经进入一个历史结构相对重要的位置，值得进一步观察。
[/quote]

同样：

[quote]
价格到了强压力，也不等于必须卖出。

它代表价格进入过去曾经出现明显供给或回落反应的区域。
[/quote]

后续仍然可以结合自己的：

[list]
[*]价格行为
[*]成交量
[*]趋势结构
[*]大周期方向
[*]市场环境
[*]赔率
[*]风险控制
[*]仓位管理
[/list]

共同判断。


[b]23. 右上角面板怎么看？[/b]

我刻意没有把所有内部统计数据全部堆在面板上。

面板只保留实际使用中更容易理解的信息。

[b]支撑位置[/b]

当前支撑在哪里，以及它的结构强弱。

[b]为什么是它？[/b]

告诉你历史触碰次数和触碰以后平均反弹幅度。

[b]压力位置[/b]

当前压力在哪里，以及强弱。

[b]为什么是它？[/b]

告诉你历史触碰次数和之后平均回落幅度。

[b]算法看了多远[/b]

显示支撑和压力分别使用了多大的搜索范围。

[b]现在怎么看[/b]

使用大白话告诉你当前市场与撑压之间处于什么结构状态。


[b]24. 常用参数怎么理解？[/b]

[b]Lookback Bars / 回看K线数[/b]

决定使用多少历史K线寻找结构。

周期越长，可以考虑更久以前的结构，但也可能保留更多较旧的信息。

[b]Pivot Left / Right Bars[/b]

决定 Pivot 判断严格程度。

数值越大，一般意味着只识别更明显的结构转折，同时确认速度也会更慢。

[b]Price Cluster Width %[/b]

决定两个历史 Pivot 相差多少以内可以被认为属于同一结构。

[b]Search Mode[/b]

Auto：自动决定支撑和压力分别要搜索多远。

Manual：手动固定搜索范围。

[b]Maximum Auto Range[/b]

智能搜索允许向外扩展到的最大距离。

[b]Minimum Structure Quality[/b]

决定附近结构必须达到多高质量，才能让系统停止继续扩大搜索。

[b]Minimum Valid Tests[/b]

智能搜索中，一个结构至少需要多少次历史观察才能成为有效候选。

[b]Reaction Observation Bars[/b]

计算历史 Pivot 出现以后，向后观察多少根K线的价格反应。

[b]Break Confirmation Buffer[/b]

突破原撑压区域以后，需要额外超过多少缓冲才认定为有效突破。

[b]Retest Tolerance[/b]

回踩或反抽过程中，允许价格距离原结构存在多大误差。


[b]25. 警报[/b]

指标支持以下 Alert：

[list]
[*]有效突破压力
[*]有效跌破支撑
[*]压力确认转支撑
[*]支撑确认转压力
[*]突破失败
[*]跌破失败
[/list]

如果启用了收盘确认，那么对应结构事件会等待K线确认以后判断。


[b]26. 关于重绘和结构变化[/b]

这个指标不是提前预测 Pivot 的工具。

Pivot 本身必须等待右侧K线确认。

因此：

[quote]
刚刚形成的最高点或最低点，不会在尚未确认时被当成已经成立的正式结构。
[/quote]

但是当前支撑压力未来仍然可能发生变化。

原因包括：

[list]
[*]新的 Pivot 被确认。
[*]新的历史触碰让另一个价格簇变得更重要。
[*]现价移动以后，当前最相关的结构发生变化。
[*]旧数据离开回看范围。
[*]价格突破以后发生撑压角色转换。
[/list]

这是动态结构模型正常的重新评价过程。


[b]27. 为什么这些模块必须放在一起？[/b]

虽然指标中包含多个计算部分，但它们并不是几个无关指标简单拼接。

每一个部分都负责解决同一个支撑压力问题中的不同阶段。

[list=1]
[*][b]Pivot[/b]：找出可能的历史结构观察点。
[*][b]价格聚类[/b]：把相近观察点合并成真正的价格区域。
[*][b]结构排序[/b]：判断哪些区域具有更多历史证据。
[*][b]智能搜索[/b]：判断为了找到有效结构到底需要看多远。
[*][b]历史反应[/b]：判断价格过去触碰以后是否真的产生明显反应。
[*][b]强度评分[/b]：评价最终选中结构过去的整体质量。
[*][b]ATR区域[/b]：把一个中心价格转化为更加符合实际市场的撑压带。
[*][b]状态机[/b]：处理结构突破以后，到底是真突破、失败突破还是完成撑压转换。
[/list]

因此：

[quote]
这是一条连续的结构计算链，而不是把多个独立指标组合到同一个脚本中。
[/quote]


[b]28. 这套实现有什么特点？[/b]

主要设计特点包括：

[list]
[*]不会把所有 Pivot 独立画线，而是先进行价格聚类。
[*]支撑和压力可以使用完全不同的智能搜索距离。
[*]是否扩大搜索范围由结构质量决定，而不是只有距离。
[*]高波动环境会提高附近小结构的有效要求。
[*]“选哪条线”和“这条线有多强”是两个独立计算阶段。
[*]反复穿越会降低结构评分，而不是因为出现次数多就自动变强。
[*]支撑压力使用区域表达，而不是绝对精确价格。
[*]突破使用之前已经存在的结构，而不是突破以后重新计算出的新位置。
[*]撑压转换必须经过回踩/反抽状态确认。
[*]主图只重点展示当前结构，不保留大量历史突破标签干扰图表。
[/list]


[b]29. 使用限制[/b]

任何支撑压力算法都无法提前确定某个位置未来一定守住或者一定突破。

需要注意：

[list]
[*]Pivot 确认天然存在延迟。
[*]随着市场产生新数据，当前支撑压力可能发生变化。
[*]历史上反应明显，不代表未来一定继续反应。
[*]强度分数不是未来成功概率。
[*]刚上市或者历史数据很少的标的可能缺少足够结构样本。
[*]趋势发生巨大变化以后，过去有效的结构可能迅速失效。
[*]成交量相关评价依赖该标的成交量数据本身的有效性。
[*]不同周期得到的撑压位置可以完全不同。
[*]非标准K线可能使用经过转换的 OHLC，因此计算结果可能与真实成交价格图存在差异。
[/list]


[b]30. 最后[/b]

[quote]
支撑和压力应该被理解为市场可能发生博弈的区域，而不是保证发生反转的价格。

这个指标的核心目标，是把复杂的历史市场结构整理成少量、当前更值得观察的位置。

它是市场结构分析框架，而不是自动交易系统。
[/quote]

[i]本指标仅用于市场结构研究与辅助分析，不构成投资建议、收益承诺或任何形式的买卖推荐。[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Adaptive Structure Support & Resistance", shorttitle="AdaptiveS/R", overlay=true, max_lines_count=20, max_labels_count=50, max_boxes_count=20, max_bars_back=2500)

// ============================================================================
// CONSTANTS 
// ============================================================================

const string LANGUAGE_ENGLISH = "English"
const string LANGUAGE_CHINESE = "简体中文"

const string SEARCH_MODE_AUTO = "Auto / 智能"
const string SEARCH_MODE_MANUAL = "Manual / 手动"

const int STATE_NORMAL = 0
const int STATE_BREAKOUT_WAITING_RETEST = 1
const int STATE_RESISTANCE_TO_SUPPORT = 2
const int STATE_BREAKDOWN_WAITING_REBOUND = -1
const int STATE_SUPPORT_TO_RESISTANCE = -2

const string GROUP_LANGUAGE = "Language / 语言"
const string GROUP_CORE = "Core Structure / 核心结构"
const string GROUP_SEARCH = "Adaptive Search / 智能搜索"
const string GROUP_RANKING = "Structure Ranking / 结构筛选"
const string GROUP_STRENGTH = "Strength Evaluation / 强度判断"
const string GROUP_ZONE = "S/R Zone / 撑压区域"
const string GROUP_REVERSAL = "Role Reversal / 撑压转换"
const string GROUP_DISPLAY = "Display / 显示"

// ============================================================================
// INPUTS
// ============================================================================

// Language
string languageInput = input.string(LANGUAGE_ENGLISH, "Language / 语言", options=[LANGUAGE_ENGLISH, LANGUAGE_CHINESE], group=GROUP_LANGUAGE)
bool useChinese = languageInput == LANGUAGE_CHINESE

// Core structure
int lookbackBarsInput = input.int(420, "Lookback Bars / 回看K线数", minval=100, maxval=2000, group=GROUP_CORE)
int pivotLeftBarsInput = input.int(3, "Pivot Left Bars / 左侧确认K线", minval=1, maxval=20, group=GROUP_CORE)
int pivotRightBarsInput = input.int(3, "Pivot Right Bars / 右侧确认K线", minval=1, maxval=20, group=GROUP_CORE)
float clusterMergePercentInput = input.float(1.20, "Price Cluster Width % / 相近价位合并%", minval=0.10, maxval=5.00, step=0.05, group=GROUP_CORE)

// Adaptive search
string searchModeInput = input.string(SEARCH_MODE_AUTO, "Search Mode / 搜索模式", options=[SEARCH_MODE_AUTO, SEARCH_MODE_MANUAL], group=GROUP_SEARCH)
float manualSearchRangePercentInput = input.float(25.0, "Manual Range % / 手动最大范围%", minval=5.0, maxval=100.0, step=5.0, group=GROUP_SEARCH)
float maximumAutoSearchRangePercentInput = input.float(100.0, "Maximum Auto Range % / 智能最大范围%", minval=25.0, maxval=100.0, step=25.0, group=GROUP_SEARCH)
float minimumStructureQualityInput = input.float(45.0, "Minimum Structure Quality / 最低有效结构质量", minval=10.0, maxval=90.0, step=1.0, group=GROUP_SEARCH)
int minimumStructureTouchesInput = input.int(2, "Minimum Valid Tests / 最少有效触碰次数", minval=1, maxval=10, group=GROUP_SEARCH)
bool volatilityAdaptiveSearchInput = input.bool(true, "Adapt Search To Volatility / 根据波动自动调整", group=GROUP_SEARCH)

// Ranking
float volumeWeightInput = input.float(0.35, "Volume Weight / 成交量权重", minval=0.0, maxval=2.0, step=0.05, group=GROUP_RANKING)
float recencyWeightInput = input.float(0.65, "Recency Weight / 近期结构权重", minval=0.0, maxval=2.0, step=0.05, group=GROUP_RANKING)
float proximityBonusInput = input.float(2.0, "Proximity Bonus / 临近结构加分", minval=0.0, maxval=10.0, step=0.1, group=GROUP_RANKING)

// Strength
int reactionObservationBarsInput = input.int(12, "Reaction Observation Bars / 触碰后观察K线数", minval=3, maxval=40, group=GROUP_STRENGTH)
float strongReactionReferencePercentInput = input.float(6.0, "Strong Reaction Reference % / 强反应参考幅度%", minval=1.0, maxval=30.0, step=0.5, group=GROUP_STRENGTH)
float strongVolumeReferenceInput = input.float(1.80, "Strong Volume Reference / 强成交量参考倍数", minval=1.0, maxval=5.0, step=0.10, group=GROUP_STRENGTH)
float crossingPenaltyInput = input.float(1.5, "Repeated Crossing Penalty / 反复穿越扣分", minval=0.0, maxval=10.0, step=0.5, group=GROUP_STRENGTH)
float failedBreakPenaltyInput = input.float(5.0, "Failed Break Penalty / 假突破跌破扣分", minval=0.0, maxval=20.0, step=0.5, group=GROUP_STRENGTH)

// Zones
float minimumZoneWidthPercentInput = input.float(0.10, "Minimum Zone Width % / 区域最小宽度%", minval=0.0, maxval=2.0, step=0.05, group=GROUP_ZONE)
float atrZoneMultiplierInput = input.float(0.08, "Volatility Zone Adjustment / 波动区域修正", minval=0.0, maxval=1.0, step=0.01, group=GROUP_ZONE)
int atrLengthInput = input.int(14, "Volatility Period / 波动周期", minval=5, maxval=100, group=GROUP_ZONE)

// Role reversal
float breakoutBufferPercentInput = input.float(0.15, "Break Confirmation Buffer % / 突破确认缓冲%", minval=0.0, maxval=3.0, step=0.05, group=GROUP_REVERSAL)
float retestTolerancePercentInput = input.float(0.30, "Retest Tolerance % / 回踩反抽容差%", minval=0.0, maxval=3.0, step=0.05, group=GROUP_REVERSAL)
float failedBreakBufferPercentInput = input.float(0.15, "Failed Break Buffer % / 假突破确认缓冲%", minval=0.0, maxval=3.0, step=0.05, group=GROUP_REVERSAL)
int retestWindowBarsInput = input.int(20, "Retest Window / 等待回踩最大K线数", minval=2, maxval=100, group=GROUP_REVERSAL)
int reversedLevelMaximumAgeInput = input.int(80, "Reversed Level Lifetime / 转换位最大有效期", minval=10, maxval=300, group=GROUP_REVERSAL)
bool confirmOnCloseInput = input.bool(true, "Confirm On Bar Close / 仅收盘确认", group=GROUP_REVERSAL)

// Display
color supportColorInput = input.color(color.rgb(30, 150, 100), "Support Color / 支撑颜色", group=GROUP_DISPLAY)
color resistanceColorInput = input.color(color.rgb(220, 80, 80), "Resistance Color / 压力颜色", group=GROUP_DISPLAY)
int zoneTransparencyInput = input.int(90, "Zone Transparency / 区域透明度", minval=0, maxval=100, group=GROUP_DISPLAY)
int lineWidthInput = input.int(2, "Line Width / 线宽", minval=1, maxval=4, group=GROUP_DISPLAY)
bool showStrengthInput = input.bool(true, "Show Strength / 显示强弱", group=GROUP_DISPLAY)
bool showDashboardInput = input.bool(true, "Show Simple Dashboard / 显示简明面板", group=GROUP_DISPLAY)

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Returns text in the language selected by the user.
localizedText(string englishText, string chineseText) =>
    useChinese ? chineseText : englishText

// Restricts a value to a specified numeric range.
clampValue(float value, float minimumValue, float maximumValue) =>
    math.max(minimumValue, math.min(value, maximumValue))

// Finds a previously created price cluster within the configured merge range.
findPriceCluster(array<float> clusterPrices, float price, float mergePercent) =>
    int matchingIndex = -1
    if array.size(clusterPrices) > 0
        for clusterIndex = 0 to array.size(clusterPrices) - 1
            float clusterPrice = array.get(clusterPrices, clusterIndex)
            float distancePercent = math.abs(price - clusterPrice) / clusterPrice * 100.0
            if distancePercent <= mergePercent
                matchingIndex := clusterIndex
                break
    matchingIndex

// Measures the largest upside response after a confirmed pivot low.
calculateSupportReaction(float pivotPrice, int pivotAge, int observationBars) =>
    float highestPostPivotPrice = pivotPrice
    for offset = 1 to observationBars
        int historyOffset = pivotAge - offset
        if historyOffset >= 0
            highestPostPivotPrice := math.max(highestPostPivotPrice, high[historyOffset])
    pivotPrice > 0.0 ? (highestPostPivotPrice / pivotPrice - 1.0) * 100.0 : 0.0

// Measures the largest downside response after a confirmed pivot high.
calculateResistanceReaction(float pivotPrice, int pivotAge, int observationBars) =>
    float lowestPostPivotPrice = pivotPrice
    for offset = 1 to observationBars
        int historyOffset = pivotAge - offset
        if historyOffset >= 0
            lowestPostPivotPrice := math.min(lowestPostPivotPrice, low[historyOffset])
    pivotPrice > 0.0 ? (pivotPrice - lowestPostPivotPrice) / pivotPrice * 100.0 : 0.0

// Counts repeated close-to-close crossings of a structural level.
countLevelCrossings(float level, int barsToInspect) =>
    int crossingCount = 0
    if not na(level) and barsToInspect >= 2
        for historyOffset = 2 to barsToInspect
            float olderClose = close[historyOffset]
            float newerClose = close[historyOffset - 1]
            bool crossedAbove = olderClose <= level and newerClose > level
            bool crossedBelow = olderClose >= level and newerClose < level
            if crossedAbove or crossedBelow
                crossingCount += 1
    crossingCount

// Counts quick breakout failures above a resistance zone.
countFailedBreakouts(float zoneLowerBound, float zoneUpperBound, int barsToInspect) =>
    int failureCount = 0
    if not na(zoneLowerBound) and not na(zoneUpperBound) and barsToInspect >= 3
        for historyOffset = 3 to barsToInspect
            float preBreakClose = close[historyOffset]
            float breakoutClose = close[historyOffset - 1]
            float followingClose = close[historyOffset - 2]
            bool failedBreakout = preBreakClose <= zoneUpperBound and breakoutClose > zoneUpperBound and followingClose < zoneLowerBound
            if failedBreakout
                failureCount += 1
    failureCount

// Counts quick breakdown failures below a support zone.
countFailedBreakdowns(float zoneLowerBound, float zoneUpperBound, int barsToInspect) =>
    int failureCount = 0
    if not na(zoneLowerBound) and not na(zoneUpperBound) and barsToInspect >= 3
        for historyOffset = 3 to barsToInspect
            float preBreakClose = close[historyOffset]
            float breakdownClose = close[historyOffset - 1]
            float followingClose = close[historyOffset - 2]
            bool failedBreakdown = preBreakClose >= zoneLowerBound and breakdownClose < zoneLowerBound and followingClose > zoneUpperBound
            if failedBreakdown
                failureCount += 1
    failureCount

// Converts the 0-100 strength score into a plain-language rating.
strengthLabel(float score) =>
    string result = localizedText("Weak", "弱")
    if score >= 70.0
        result := localizedText("Strong", "强")
    else if score >= 45.0
        result := localizedText("Medium", "中")
    result

// Assigns a structure to the nearest supported adaptive-search tier.
searchDistanceTier(float distancePercent, float maximumRangePercent) =>
    float result = na
    if distancePercent <= 25.0
        result := 25.0
    else if distancePercent <= 50.0 and maximumRangePercent >= 50.0
        result := 50.0
    else if distancePercent <= 75.0 and maximumRangePercent >= 75.0
        result := 75.0
    else if distancePercent <= 100.0 and maximumRangePercent >= 100.0
        result := 100.0
    result

// Evaluates whether a cluster is meaningful enough to stop search expansion.
// This score is used for adaptive search only; it does not replace final S/R ranking.
calculateStructureQuality(int touchCount, float averageReactionPercent, float averageVolumeRatio, int mostRecentPivotAge, float accumulatedBaseScore) =>
    float touchComponent = math.min(touchCount / 4.0, 1.0) * 30.0
    float reactionComponent = math.min(averageReactionPercent / strongReactionReferencePercentInput, 1.0) * 30.0
    float volumeNormalization = clampValue((averageVolumeRatio - 0.80) / math.max(strongVolumeReferenceInput - 0.80, 0.01), 0.0, 1.0)
    float volumeComponent = volumeNormalization * 15.0
    float recencyNormalization = 1.0 - math.min(mostRecentPivotAge / math.max(lookbackBarsInput * 1.0, 1.0), 1.0)
    float recencyComponent = recencyNormalization * 15.0
    float baseScoreComponent = math.min(accumulatedBaseScore / 8.0, 1.0) * 10.0
    clampValue(touchComponent + reactionComponent + volumeComponent + recencyComponent + baseScoreComponent, 0.0, 100.0)

// ============================================================================
// BASE CALCULATIONS
// ============================================================================

// Confirmed swing points provide the raw structural observations.
float pivotHigh = ta.pivothigh(high, pivotLeftBarsInput, pivotRightBarsInput)
float pivotLow = ta.pivotlow(low, pivotLeftBarsInput, pivotRightBarsInput)

float averageVolume = ta.sma(volume, 20)
float averageTrueRange = ta.atr(atrLengthInput)
float currentAtrPercent = close > 0.0 ? averageTrueRange / close * 100.0 : 0.0

// Volatility modifies the minimum quality required for a nearby structure to
// stop search expansion. High-volatility markets require stronger evidence.
float adaptiveQualityThreshold = minimumStructureQualityInput

if volatilityAdaptiveSearchInput
    if currentAtrPercent >= 6.0
        adaptiveQualityThreshold := minimumStructureQualityInput + 8.0
    else if currentAtrPercent >= 4.0
        adaptiveQualityThreshold := minimumStructureQualityInput + 5.0
    else if currentAtrPercent >= 2.5
        adaptiveQualityThreshold := minimumStructureQualityInput + 2.0
    else if currentAtrPercent <= 1.2
        adaptiveQualityThreshold := minimumStructureQualityInput - 3.0

adaptiveQualityThreshold := clampValue(adaptiveQualityThreshold, 20.0, 90.0)

int availableLookbackBars = math.min(lookbackBarsInput, math.max(bar_index - pivotRightBarsInput - 1, 0))

// ============================================================================
// CURRENT STRUCTURAL LEVEL VARIABLES
// ============================================================================

float selectedSupportLevel = na
float selectedResistanceLevel = na

float selectedSupportRank = -100000.0
float selectedResistanceRank = -100000.0

float selectedSupportBaseScore = na
float selectedResistanceBaseScore = na

int selectedSupportTouchCount = 0
int selectedResistanceTouchCount = 0

float selectedSupportClusterLowerBound = na
float selectedSupportClusterUpperBound = na
float selectedResistanceClusterLowerBound = na
float selectedResistanceClusterUpperBound = na

float selectedSupportReactionSum = 0.0
float selectedResistanceReactionSum = 0.0

float selectedSupportVolumeRatioSum = 0.0
float selectedResistanceVolumeRatioSum = 0.0

int selectedSupportMostRecentPivotAge = 999999
int selectedResistanceMostRecentPivotAge = 999999

float activeSupportSearchRangePercent = na
float activeResistanceSearchRangePercent = na

// ============================================================================
// BUILD STRUCTURAL PRICE CLUSTERS
// ============================================================================

if availableLookbackBars > pivotRightBarsInput + 10

    array<float> supportClusterPrices = array.new_float()
    array<float> supportClusterScores = array.new_float()
    array<int> supportClusterTouchCounts = array.new_int()
    array<float> supportClusterLowerBounds = array.new_float()
    array<float> supportClusterUpperBounds = array.new_float()
    array<float> supportClusterReactionSums = array.new_float()
    array<float> supportClusterVolumeRatioSums = array.new_float()
    array<int> supportClusterMostRecentAges = array.new_int()

    array<float> resistanceClusterPrices = array.new_float()
    array<float> resistanceClusterScores = array.new_float()
    array<int> resistanceClusterTouchCounts = array.new_int()
    array<float> resistanceClusterLowerBounds = array.new_float()
    array<float> resistanceClusterUpperBounds = array.new_float()
    array<float> resistanceClusterReactionSums = array.new_float()
    array<float> resistanceClusterVolumeRatioSums = array.new_float()
    array<int> resistanceClusterMostRecentAges = array.new_int()

    // ------------------------------------------------------------------------
    // Aggregate confirmed pivots into nearby support and resistance clusters.
    // ------------------------------------------------------------------------

    for historyOffset = 0 to availableLookbackBars

        // SUPPORT OBSERVATION
        float supportPivotPrice = pivotLow[historyOffset]

        if not na(supportPivotPrice)

            int pivotAge = historyOffset + pivotRightBarsInput
            float pivotVolume = nz(volume[pivotAge], volume[historyOffset])
            float pivotAverageVolume = nz(averageVolume[pivotAge], averageVolume[historyOffset])
            float volumeRatio = pivotAverageVolume > 0.0 ? math.min(pivotVolume / pivotAverageVolume, 3.0) : 1.0
            float recencyFactor = 1.0 + float(availableLookbackBars - historyOffset) / math.max(float(availableLookbackBars), 1.0)
            float pivotBaseScore = 1.0 + volumeWeightInput * volumeRatio + recencyWeightInput * recencyFactor
            float reactionPercent = calculateSupportReaction(supportPivotPrice, pivotAge, reactionObservationBarsInput)

            int matchingClusterIndex = findPriceCluster(supportClusterPrices, supportPivotPrice, clusterMergePercentInput)

            if matchingClusterIndex == -1

                array.push(supportClusterPrices, supportPivotPrice)
                array.push(supportClusterScores, pivotBaseScore)
                array.push(supportClusterTouchCounts, 1)
                array.push(supportClusterLowerBounds, supportPivotPrice)
                array.push(supportClusterUpperBounds, supportPivotPrice)
                array.push(supportClusterReactionSums, reactionPercent)
                array.push(supportClusterVolumeRatioSums, volumeRatio)
                array.push(supportClusterMostRecentAges, pivotAge)

            else

                float existingClusterPrice = array.get(supportClusterPrices, matchingClusterIndex)
                float existingClusterScore = array.get(supportClusterScores, matchingClusterIndex)
                float updatedClusterScore = existingClusterScore + pivotBaseScore
                float updatedClusterPrice = (existingClusterPrice * existingClusterScore + supportPivotPrice * pivotBaseScore) / updatedClusterScore

                array.set(supportClusterPrices, matchingClusterIndex, updatedClusterPrice)
                array.set(supportClusterScores, matchingClusterIndex, updatedClusterScore)
                array.set(supportClusterTouchCounts, matchingClusterIndex, array.get(supportClusterTouchCounts, matchingClusterIndex) + 1)
                array.set(supportClusterLowerBounds, matchingClusterIndex, math.min(array.get(supportClusterLowerBounds, matchingClusterIndex), supportPivotPrice))
                array.set(supportClusterUpperBounds, matchingClusterIndex, math.max(array.get(supportClusterUpperBounds, matchingClusterIndex), supportPivotPrice))
                array.set(supportClusterReactionSums, matchingClusterIndex, array.get(supportClusterReactionSums, matchingClusterIndex) + reactionPercent)
                array.set(supportClusterVolumeRatioSums, matchingClusterIndex, array.get(supportClusterVolumeRatioSums, matchingClusterIndex) + volumeRatio)
                array.set(supportClusterMostRecentAges, matchingClusterIndex, math.min(array.get(supportClusterMostRecentAges, matchingClusterIndex), pivotAge))

        // RESISTANCE OBSERVATION
        float resistancePivotPrice = pivotHigh[historyOffset]

        if not na(resistancePivotPrice)

            int pivotAge = historyOffset + pivotRightBarsInput
            float pivotVolume = nz(volume[pivotAge], volume[historyOffset])
            float pivotAverageVolume = nz(averageVolume[pivotAge], averageVolume[historyOffset])
            float volumeRatio = pivotAverageVolume > 0.0 ? math.min(pivotVolume / pivotAverageVolume, 3.0) : 1.0
            float recencyFactor = 1.0 + float(availableLookbackBars - historyOffset) / math.max(float(availableLookbackBars), 1.0)
            float pivotBaseScore = 1.0 + volumeWeightInput * volumeRatio + recencyWeightInput * recencyFactor
            float reactionPercent = calculateResistanceReaction(resistancePivotPrice, pivotAge, reactionObservationBarsInput)

            int matchingClusterIndex = findPriceCluster(resistanceClusterPrices, resistancePivotPrice, clusterMergePercentInput)

            if matchingClusterIndex == -1

                array.push(resistanceClusterPrices, resistancePivotPrice)
                array.push(resistanceClusterScores, pivotBaseScore)
                array.push(resistanceClusterTouchCounts, 1)
                array.push(resistanceClusterLowerBounds, resistancePivotPrice)
                array.push(resistanceClusterUpperBounds, resistancePivotPrice)
                array.push(resistanceClusterReactionSums, reactionPercent)
                array.push(resistanceClusterVolumeRatioSums, volumeRatio)
                array.push(resistanceClusterMostRecentAges, pivotAge)

            else

                float existingClusterPrice = array.get(resistanceClusterPrices, matchingClusterIndex)
                float existingClusterScore = array.get(resistanceClusterScores, matchingClusterIndex)
                float updatedClusterScore = existingClusterScore + pivotBaseScore
                float updatedClusterPrice = (existingClusterPrice * existingClusterScore + resistancePivotPrice * pivotBaseScore) / updatedClusterScore

                array.set(resistanceClusterPrices, matchingClusterIndex, updatedClusterPrice)
                array.set(resistanceClusterScores, matchingClusterIndex, updatedClusterScore)
                array.set(resistanceClusterTouchCounts, matchingClusterIndex, array.get(resistanceClusterTouchCounts, matchingClusterIndex) + 1)
                array.set(resistanceClusterLowerBounds, matchingClusterIndex, math.min(array.get(resistanceClusterLowerBounds, matchingClusterIndex), resistancePivotPrice))
                array.set(resistanceClusterUpperBounds, matchingClusterIndex, math.max(array.get(resistanceClusterUpperBounds, matchingClusterIndex), resistancePivotPrice))
                array.set(resistanceClusterReactionSums, matchingClusterIndex, array.get(resistanceClusterReactionSums, matchingClusterIndex) + reactionPercent)
                array.set(resistanceClusterVolumeRatioSums, matchingClusterIndex, array.get(resistanceClusterVolumeRatioSums, matchingClusterIndex) + volumeRatio)
                array.set(resistanceClusterMostRecentAges, matchingClusterIndex, math.min(array.get(resistanceClusterMostRecentAges, matchingClusterIndex), pivotAge))

    // ========================================================================
    // DETERMINE ADAPTIVE SUPPORT SEARCH RANGE
    // ========================================================================

    if searchModeInput == SEARCH_MODE_MANUAL

        activeSupportSearchRangePercent := manualSearchRangePercentInput

    else

        float nearestQualifiedSupportTier = na

        if array.size(supportClusterPrices) > 0

            for clusterIndex = 0 to array.size(supportClusterPrices) - 1

                float clusterPrice = array.get(supportClusterPrices, clusterIndex)
                float distancePercent = (close - clusterPrice) / close * 100.0

                if clusterPrice <= close and distancePercent >= 0.0 and distancePercent <= maximumAutoSearchRangePercentInput

                    int touchCount = array.get(supportClusterTouchCounts, clusterIndex)
                    float reactionSum = array.get(supportClusterReactionSums, clusterIndex)
                    float volumeRatioSum = array.get(supportClusterVolumeRatioSums, clusterIndex)
                    float averageReactionPercent = reactionSum / math.max(touchCount, 1)
                    float averageVolumeRatio = volumeRatioSum / math.max(touchCount, 1)
                    int mostRecentPivotAge = array.get(supportClusterMostRecentAges, clusterIndex)
                    float accumulatedBaseScore = array.get(supportClusterScores, clusterIndex)

                    float structureQuality = calculateStructureQuality(touchCount, averageReactionPercent, averageVolumeRatio, mostRecentPivotAge, accumulatedBaseScore)
                    float candidateTier = searchDistanceTier(distancePercent, maximumAutoSearchRangePercentInput)

                    bool qualifiedStructure = touchCount >= minimumStructureTouchesInput and structureQuality >= adaptiveQualityThreshold

                    if qualifiedStructure and not na(candidateTier)
                        if na(nearestQualifiedSupportTier) or candidateTier < nearestQualifiedSupportTier
                            nearestQualifiedSupportTier := candidateTier

        activeSupportSearchRangePercent := na(nearestQualifiedSupportTier) ? maximumAutoSearchRangePercentInput : nearestQualifiedSupportTier

    // ========================================================================
    // DETERMINE ADAPTIVE RESISTANCE SEARCH RANGE
    // ========================================================================

    if searchModeInput == SEARCH_MODE_MANUAL

        activeResistanceSearchRangePercent := manualSearchRangePercentInput

    else

        float nearestQualifiedResistanceTier = na

        if array.size(resistanceClusterPrices) > 0

            for clusterIndex = 0 to array.size(resistanceClusterPrices) - 1

                float clusterPrice = array.get(resistanceClusterPrices, clusterIndex)
                float distancePercent = (clusterPrice - close) / close * 100.0

                if clusterPrice >= close and distancePercent >= 0.0 and distancePercent <= maximumAutoSearchRangePercentInput

                    int touchCount = array.get(resistanceClusterTouchCounts, clusterIndex)
                    float reactionSum = array.get(resistanceClusterReactionSums, clusterIndex)
                    float volumeRatioSum = array.get(resistanceClusterVolumeRatioSums, clusterIndex)
                    float averageReactionPercent = reactionSum / math.max(touchCount, 1)
                    float averageVolumeRatio = volumeRatioSum / math.max(touchCount, 1)
                    int mostRecentPivotAge = array.get(resistanceClusterMostRecentAges, clusterIndex)
                    float accumulatedBaseScore = array.get(resistanceClusterScores, clusterIndex)

                    float structureQuality = calculateStructureQuality(touchCount, averageReactionPercent, averageVolumeRatio, mostRecentPivotAge, accumulatedBaseScore)
                    float candidateTier = searchDistanceTier(distancePercent, maximumAutoSearchRangePercentInput)

                    bool qualifiedStructure = touchCount >= minimumStructureTouchesInput and structureQuality >= adaptiveQualityThreshold

                    if qualifiedStructure and not na(candidateTier)
                        if na(nearestQualifiedResistanceTier) or candidateTier < nearestQualifiedResistanceTier
                            nearestQualifiedResistanceTier := candidateTier

        activeResistanceSearchRangePercent := na(nearestQualifiedResistanceTier) ? maximumAutoSearchRangePercentInput : nearestQualifiedResistanceTier

    // ========================================================================
    // SELECT THE PRIMARY SUPPORT
    // ========================================================================

    if array.size(supportClusterPrices) > 0

        for clusterIndex = 0 to array.size(supportClusterPrices) - 1

            float clusterPrice = array.get(supportClusterPrices, clusterIndex)
            float accumulatedBaseScore = array.get(supportClusterScores, clusterIndex)
            float distancePercent = (close - clusterPrice) / close * 100.0

            bool validCandidate = clusterPrice <= close and distancePercent >= 0.0 and distancePercent <= activeSupportSearchRangePercent

            if validCandidate

                float proximityFactor = math.max(1.0 - distancePercent / math.max(activeSupportSearchRangePercent, 1.0), 0.0)
                float candidateRank = accumulatedBaseScore + proximityBonusInput * proximityFactor

                if candidateRank > selectedSupportRank

                    selectedSupportRank := candidateRank
                    selectedSupportLevel := clusterPrice
                    selectedSupportBaseScore := accumulatedBaseScore
                    selectedSupportTouchCount := array.get(supportClusterTouchCounts, clusterIndex)
                    selectedSupportClusterLowerBound := array.get(supportClusterLowerBounds, clusterIndex)
                    selectedSupportClusterUpperBound := array.get(supportClusterUpperBounds, clusterIndex)
                    selectedSupportReactionSum := array.get(supportClusterReactionSums, clusterIndex)
                    selectedSupportVolumeRatioSum := array.get(supportClusterVolumeRatioSums, clusterIndex)
                    selectedSupportMostRecentPivotAge := array.get(supportClusterMostRecentAges, clusterIndex)

    // ========================================================================
    // SELECT THE PRIMARY RESISTANCE
    // ========================================================================

    if array.size(resistanceClusterPrices) > 0

        for clusterIndex = 0 to array.size(resistanceClusterPrices) - 1

            float clusterPrice = array.get(resistanceClusterPrices, clusterIndex)
            float accumulatedBaseScore = array.get(resistanceClusterScores, clusterIndex)
            float distancePercent = (clusterPrice - close) / close * 100.0

            bool validCandidate = clusterPrice >= close and distancePercent >= 0.0 and distancePercent <= activeResistanceSearchRangePercent

            if validCandidate

                float proximityFactor = math.max(1.0 - distancePercent / math.max(activeResistanceSearchRangePercent, 1.0), 0.0)
                float candidateRank = accumulatedBaseScore + proximityBonusInput * proximityFactor

                if candidateRank > selectedResistanceRank

                    selectedResistanceRank := candidateRank
                    selectedResistanceLevel := clusterPrice
                    selectedResistanceBaseScore := accumulatedBaseScore
                    selectedResistanceTouchCount := array.get(resistanceClusterTouchCounts, clusterIndex)
                    selectedResistanceClusterLowerBound := array.get(resistanceClusterLowerBounds, clusterIndex)
                    selectedResistanceClusterUpperBound := array.get(resistanceClusterUpperBounds, clusterIndex)
                    selectedResistanceReactionSum := array.get(resistanceClusterReactionSums, clusterIndex)
                    selectedResistanceVolumeRatioSum := array.get(resistanceClusterVolumeRatioSums, clusterIndex)
                    selectedResistanceMostRecentPivotAge := array.get(resistanceClusterMostRecentAges, clusterIndex)

// ============================================================================
// SUPPORT AND RESISTANCE ZONES
// ============================================================================

// The displayed zone combines the observed cluster spread with a small
// volatility-sensitive buffer. The center line remains the selected level.

float supportZoneLowerBound = na
float supportZoneUpperBound = na
float resistanceZoneLowerBound = na
float resistanceZoneUpperBound = na

if not na(selectedSupportLevel)

    float supportZonePadding = math.max(selectedSupportLevel * minimumZoneWidthPercentInput / 100.0, averageTrueRange * atrZoneMultiplierInput)

    supportZoneLowerBound := selectedSupportClusterLowerBound - supportZonePadding
    supportZoneUpperBound := selectedSupportClusterUpperBound + supportZonePadding

if not na(selectedResistanceLevel)

    float resistanceZonePadding = math.max(selectedResistanceLevel * minimumZoneWidthPercentInput / 100.0, averageTrueRange * atrZoneMultiplierInput)

    resistanceZoneLowerBound := selectedResistanceClusterLowerBound - resistanceZonePadding
    resistanceZoneUpperBound := selectedResistanceClusterUpperBound + resistanceZonePadding

// ============================================================================
// SUPPORT STRENGTH
// ============================================================================

// Strength is evaluated after the structural level is selected.
// It therefore describes the selected level without replacing the selection
// process itself.

float supportStrengthScore = na
float supportAverageReactionPercent = na
float supportAverageVolumeRatio = na

int supportCrossingCount = 0
int supportFailedBreakdownCount = 0

if not na(selectedSupportLevel) and selectedSupportTouchCount > 0

    supportAverageReactionPercent := selectedSupportReactionSum / selectedSupportTouchCount
    supportAverageVolumeRatio := selectedSupportVolumeRatioSum / selectedSupportTouchCount

    supportCrossingCount := countLevelCrossings(selectedSupportLevel, availableLookbackBars)
    supportFailedBreakdownCount := countFailedBreakdowns(supportZoneLowerBound, supportZoneUpperBound, availableLookbackBars)

    float touchComponent = math.min(selectedSupportTouchCount / 5.0, 1.0) * 25.0
    float reactionComponent = math.min(supportAverageReactionPercent / strongReactionReferencePercentInput, 1.0) * 35.0

    float volumeNormalization = clampValue((supportAverageVolumeRatio - 0.80) / math.max(strongVolumeReferenceInput - 0.80, 0.01), 0.0, 1.0)
    float volumeComponent = volumeNormalization * 15.0

    float recencyNormalization = 1.0 - math.min(selectedSupportMostRecentPivotAge / math.max(lookbackBarsInput * 1.0, 1.0), 1.0)
    float recencyComponent = recencyNormalization * 15.0

    float stabilityComponent = 10.0
    float totalPenalty = supportCrossingCount * crossingPenaltyInput + supportFailedBreakdownCount * failedBreakPenaltyInput

    float rawStrengthScore = touchComponent + reactionComponent + volumeComponent + recencyComponent + stabilityComponent - totalPenalty

    supportStrengthScore := math.round(clampValue(rawStrengthScore, 0.0, 100.0))

// ============================================================================
// RESISTANCE STRENGTH
// ============================================================================

float resistanceStrengthScore = na
float resistanceAverageReactionPercent = na
float resistanceAverageVolumeRatio = na

int resistanceCrossingCount = 0
int resistanceFailedBreakoutCount = 0

if not na(selectedResistanceLevel) and selectedResistanceTouchCount > 0

    resistanceAverageReactionPercent := selectedResistanceReactionSum / selectedResistanceTouchCount
    resistanceAverageVolumeRatio := selectedResistanceVolumeRatioSum / selectedResistanceTouchCount

    resistanceCrossingCount := countLevelCrossings(selectedResistanceLevel, availableLookbackBars)
    resistanceFailedBreakoutCount := countFailedBreakouts(resistanceZoneLowerBound, resistanceZoneUpperBound, availableLookbackBars)

    float touchComponent = math.min(selectedResistanceTouchCount / 5.0, 1.0) * 25.0
    float reactionComponent = math.min(resistanceAverageReactionPercent / strongReactionReferencePercentInput, 1.0) * 35.0

    float volumeNormalization = clampValue((resistanceAverageVolumeRatio - 0.80) / math.max(strongVolumeReferenceInput - 0.80, 0.01), 0.0, 1.0)
    float volumeComponent = volumeNormalization * 15.0

    float recencyNormalization = 1.0 - math.min(selectedResistanceMostRecentPivotAge / math.max(lookbackBarsInput * 1.0, 1.0), 1.0)
    float recencyComponent = recencyNormalization * 15.0

    float stabilityComponent = 10.0
    float totalPenalty = resistanceCrossingCount * crossingPenaltyInput + resistanceFailedBreakoutCount * failedBreakPenaltyInput

    float rawStrengthScore = touchComponent + reactionComponent + volumeComponent + recencyComponent + stabilityComponent - totalPenalty

    resistanceStrengthScore := math.round(clampValue(rawStrengthScore, 0.0, 100.0))

// ============================================================================
// BREAK CONFIRMATION
// ============================================================================

// Break events use the previously confirmed zone rather than the recalculated
// current zone. This preserves the structural level that price actually broke.

bool structureConfirmationAllowed = not confirmOnCloseInput or barstate.isconfirmed

float previousResistanceLevel = selectedResistanceLevel[1]
float previousResistanceZoneLowerBound = resistanceZoneLowerBound[1]
float previousResistanceZoneUpperBound = resistanceZoneUpperBound[1]

float previousSupportLevel = selectedSupportLevel[1]
float previousSupportZoneLowerBound = supportZoneLowerBound[1]
float previousSupportZoneUpperBound = supportZoneUpperBound[1]

float resistanceBreakTrigger = not na(previousResistanceZoneUpperBound) ? previousResistanceZoneUpperBound * (1.0 + breakoutBufferPercentInput / 100.0) : na
float supportBreakTrigger = not na(previousSupportZoneLowerBound) ? previousSupportZoneLowerBound * (1.0 - breakoutBufferPercentInput / 100.0) : na

bool confirmedResistanceBreak = structureConfirmationAllowed and not na(resistanceBreakTrigger) and close > resistanceBreakTrigger and close[1] <= resistanceBreakTrigger
bool confirmedSupportBreak = structureConfirmationAllowed and not na(supportBreakTrigger) and close < supportBreakTrigger and close[1] >= supportBreakTrigger

// ============================================================================
// ROLE-REVERSAL STATE MACHINE
// ============================================================================

// A break alone does not immediately reverse the role of a level.
// Resistance becomes support only after a successful retest.
// Support becomes resistance only after a rejected rebound.

var int structureState = STATE_NORMAL

var float roleReversalCenterLevel = na
var float roleReversalLowerBound = na
var float roleReversalUpperBound = na
var float roleReversalStrengthScore = na

var int roleReversalStartBarIndex = na
var int roleReversalConfirmationBarIndex = na

bool failedBreakoutEvent = false
bool failedBreakdownEvent = false
bool resistanceToSupportConfirmedEvent = false
bool supportToResistanceConfirmedEvent = false

// Register a new breakout or breakdown.
if confirmedResistanceBreak

    structureState := STATE_BREAKOUT_WAITING_RETEST

    roleReversalCenterLevel := previousResistanceLevel
    roleReversalLowerBound := previousResistanceZoneLowerBound
    roleReversalUpperBound := previousResistanceZoneUpperBound
    roleReversalStrengthScore := resistanceStrengthScore[1]

    roleReversalStartBarIndex := bar_index
    roleReversalConfirmationBarIndex := na

else if confirmedSupportBreak

    structureState := STATE_BREAKDOWN_WAITING_REBOUND

    roleReversalCenterLevel := previousSupportLevel
    roleReversalLowerBound := previousSupportZoneLowerBound
    roleReversalUpperBound := previousSupportZoneUpperBound
    roleReversalStrengthScore := supportStrengthScore[1]

    roleReversalStartBarIndex := bar_index
    roleReversalConfirmationBarIndex := na

// Evaluate the retest after a confirmed resistance breakout.
else if structureState == STATE_BREAKOUT_WAITING_RETEST and not na(roleReversalStartBarIndex) and bar_index > roleReversalStartBarIndex and structureConfirmationAllowed

    int barsSinceBreak = bar_index - roleReversalStartBarIndex

    bool breakoutFailed = close < roleReversalLowerBound * (1.0 - failedBreakBufferPercentInput / 100.0)

    if breakoutFailed

        failedBreakoutEvent := true
        structureState := STATE_NORMAL

        roleReversalCenterLevel := na
        roleReversalLowerBound := na
        roleReversalUpperBound := na
        roleReversalStrengthScore := na

        roleReversalStartBarIndex := na
        roleReversalConfirmationBarIndex := na

    else if barsSinceBreak <= retestWindowBarsInput

        bool testedFormerResistance = low <= roleReversalUpperBound * (1.0 + retestTolerancePercentInput / 100.0)
        bool retestHeld = testedFormerResistance and close > roleReversalUpperBound

        if retestHeld

            structureState := STATE_RESISTANCE_TO_SUPPORT
            roleReversalConfirmationBarIndex := bar_index
            resistanceToSupportConfirmedEvent := true

    else

        structureState := STATE_NORMAL

        roleReversalCenterLevel := na
        roleReversalLowerBound := na
        roleReversalUpperBound := na
        roleReversalStrengthScore := na

        roleReversalStartBarIndex := na
        roleReversalConfirmationBarIndex := na

// Evaluate the rebound after a confirmed support breakdown.
else if structureState == STATE_BREAKDOWN_WAITING_REBOUND and not na(roleReversalStartBarIndex) and bar_index > roleReversalStartBarIndex and structureConfirmationAllowed

    int barsSinceBreak = bar_index - roleReversalStartBarIndex

    bool breakdownFailed = close > roleReversalUpperBound * (1.0 + failedBreakBufferPercentInput / 100.0)

    if breakdownFailed

        failedBreakdownEvent := true
        structureState := STATE_NORMAL

        roleReversalCenterLevel := na
        roleReversalLowerBound := na
        roleReversalUpperBound := na
        roleReversalStrengthScore := na

        roleReversalStartBarIndex := na
        roleReversalConfirmationBarIndex := na

    else if barsSinceBreak <= retestWindowBarsInput

        bool testedFormerSupport = high >= roleReversalLowerBound * (1.0 - retestTolerancePercentInput / 100.0)
        bool reboundRejected = testedFormerSupport and close < roleReversalLowerBound

        if reboundRejected

            structureState := STATE_SUPPORT_TO_RESISTANCE
            roleReversalConfirmationBarIndex := bar_index
            supportToResistanceConfirmedEvent := true

    else

        structureState := STATE_NORMAL

        roleReversalCenterLevel := na
        roleReversalLowerBound := na
        roleReversalUpperBound := na
        roleReversalStrengthScore := na

        roleReversalStartBarIndex := na
        roleReversalConfirmationBarIndex := na

// Retire a confirmed resistance-to-support level after invalidation or expiry.
if structureState == STATE_RESISTANCE_TO_SUPPORT and not na(roleReversalConfirmationBarIndex) and structureConfirmationAllowed

    int reversedLevelAge = bar_index - roleReversalConfirmationBarIndex
    bool reversedSupportInvalidated = close < roleReversalLowerBound * (1.0 - failedBreakBufferPercentInput / 100.0)

    if reversedSupportInvalidated or reversedLevelAge > reversedLevelMaximumAgeInput

        structureState := STATE_NORMAL

        roleReversalCenterLevel := na
        roleReversalLowerBound := na
        roleReversalUpperBound := na
        roleReversalStrengthScore := na

        roleReversalStartBarIndex := na
        roleReversalConfirmationBarIndex := na

// Retire a confirmed support-to-resistance level after invalidation or expiry.
if structureState == STATE_SUPPORT_TO_RESISTANCE and not na(roleReversalConfirmationBarIndex) and structureConfirmationAllowed

    int reversedLevelAge = bar_index - roleReversalConfirmationBarIndex
    bool reversedResistanceInvalidated = close > roleReversalUpperBound * (1.0 + failedBreakBufferPercentInput / 100.0)

    if reversedResistanceInvalidated or reversedLevelAge > reversedLevelMaximumAgeInput

        structureState := STATE_NORMAL

        roleReversalCenterLevel := na
        roleReversalLowerBound := na
        roleReversalUpperBound := na
        roleReversalStrengthScore := na

        roleReversalStartBarIndex := na
        roleReversalConfirmationBarIndex := na

// ============================================================================
// FINAL DISPLAY LEVELS
// ============================================================================

// The primary clustering model remains the default source of S/R.
// A confirmed role-reversal level takes priority only when it is both valid
// and closer to current price than the primary structural candidate.

float displaySupportLevel = selectedSupportLevel
float displaySupportZoneLowerBound = supportZoneLowerBound
float displaySupportZoneUpperBound = supportZoneUpperBound
float displaySupportStrengthScore = supportStrengthScore

float displayResistanceLevel = selectedResistanceLevel
float displayResistanceZoneLowerBound = resistanceZoneLowerBound
float displayResistanceZoneUpperBound = resistanceZoneUpperBound
float displayResistanceStrengthScore = resistanceStrengthScore

bool displayingReversedSupport = false
bool displayingReversedResistance = false

if structureState == STATE_RESISTANCE_TO_SUPPORT and not na(roleReversalCenterLevel) and roleReversalCenterLevel <= close

    float roleDistancePercent = (close - roleReversalCenterLevel) / close * 100.0
    bool withinActiveRange = roleDistancePercent <= nz(activeSupportSearchRangePercent, maximumAutoSearchRangePercentInput)
    bool closerThanPrimaryLevel = na(selectedSupportLevel) or roleReversalCenterLevel > selectedSupportLevel

    if withinActiveRange and closerThanPrimaryLevel

        displaySupportLevel := roleReversalCenterLevel
        displaySupportZoneLowerBound := roleReversalLowerBound
        displaySupportZoneUpperBound := roleReversalUpperBound
        displaySupportStrengthScore := roleReversalStrengthScore

        displayingReversedSupport := true

if structureState == STATE_SUPPORT_TO_RESISTANCE and not na(roleReversalCenterLevel) and roleReversalCenterLevel >= close

    float roleDistancePercent = (roleReversalCenterLevel - close) / close * 100.0
    bool withinActiveRange = roleDistancePercent <= nz(activeResistanceSearchRangePercent, maximumAutoSearchRangePercentInput)
    bool closerThanPrimaryLevel = na(selectedResistanceLevel) or roleReversalCenterLevel < selectedResistanceLevel

    if withinActiveRange and closerThanPrimaryLevel

        displayResistanceLevel := roleReversalCenterLevel
        displayResistanceZoneLowerBound := roleReversalLowerBound
        displayResistanceZoneUpperBound := roleReversalUpperBound
        displayResistanceStrengthScore := roleReversalStrengthScore

        displayingReversedResistance := true

string displaySupportStrengthLabel = strengthLabel(nz(displaySupportStrengthScore))
string displayResistanceStrengthLabel = strengthLabel(nz(displayResistanceStrengthScore))

// ============================================================================
// PLAIN-LANGUAGE CURRENT STATE
// ============================================================================

string currentStateText = ""

if not na(displaySupportLevel) and not na(displayResistanceLevel)
    currentStateText := localizedText("Price is between support and resistance", "价格还在支撑和压力之间")
else if na(displaySupportLevel) and not na(displayResistanceLevel)
    currentStateText := localizedText("No nearby support is available", "附近暂时没有合适的支撑")
else if not na(displaySupportLevel) and na(displayResistanceLevel)
    currentStateText := localizedText("No nearby resistance is available", "附近暂时没有合适的压力")
else
    currentStateText := localizedText("No clear S/R structure is available", "目前暂时没有清晰的撑压结构")

if failedBreakoutEvent
    currentStateText := localizedText("Breakout failed; price moved back below the old resistance", "突破失败，价格又跌回原压力下方")
else if failedBreakdownEvent
    currentStateText := localizedText("Breakdown failed; price recovered above the old support", "跌破失败，价格又重新收回原支撑")
else if resistanceToSupportConfirmedEvent
    currentStateText := localizedText("Former resistance is now confirmed as support", "原来的压力已经确认变成支撑")
else if supportToResistanceConfirmedEvent
    currentStateText := localizedText("Former support is now confirmed as resistance", "原来的支撑已经确认变成压力")
else if confirmedResistanceBreak
    currentStateText := localizedText("Resistance broken; waiting for a retest", "已经突破压力，等待回踩确认")
else if confirmedSupportBreak
    currentStateText := localizedText("Support broken; waiting for a rebound test", "已经跌破支撑，等待反抽确认")
else if structureState == STATE_BREAKOUT_WAITING_RETEST
    currentStateText := localizedText("Price remains above old resistance; waiting for retest", "目前还在原压力上方，等待回踩")
else if structureState == STATE_BREAKDOWN_WAITING_REBOUND
    currentStateText := localizedText("Price remains below old support; waiting for rebound", "目前还在原支撑下方，等待反抽")
else if structureState == STATE_RESISTANCE_TO_SUPPORT
    currentStateText := localizedText("Former resistance is currently acting as support", "原来的压力目前正在作为支撑")
else if structureState == STATE_SUPPORT_TO_RESISTANCE
    currentStateText := localizedText("Former support is currently acting as resistance", "原来的支撑目前正在作为压力")

// ============================================================================
// CHART OBJECTS
// ============================================================================

var line supportLine = na
var line resistanceLine = na

var box supportZoneBox = na
var box resistanceZoneBox = na

var label supportLabel = na
var label resistanceLabel = na

int drawingStartBarIndex = math.max(bar_index - availableLookbackBars, 0)
int labelBarIndex = drawingStartBarIndex + math.min(12, availableLookbackBars)

// ============================================================================
// SUPPORT DISPLAY
// ============================================================================

if not na(displaySupportLevel)

    if na(supportZoneBox)

        supportZoneBox := box.new(
             left=drawingStartBarIndex,
             top=displaySupportZoneUpperBound,
             right=bar_index,
             bottom=displaySupportZoneLowerBound,
             border_color=color.new(supportColorInput, 45),
             bgcolor=color.new(supportColorInput, zoneTransparencyInput),
             extend=extend.right)

    else

        box.set_lefttop(supportZoneBox, drawingStartBarIndex, displaySupportZoneUpperBound)
        box.set_rightbottom(supportZoneBox, bar_index, displaySupportZoneLowerBound)
        box.set_extend(supportZoneBox, extend.right)
        box.set_border_color(supportZoneBox, color.new(supportColorInput, 45))
        box.set_bgcolor(supportZoneBox, color.new(supportColorInput, zoneTransparencyInput))

    if na(supportLine)

        supportLine := line.new(
             drawingStartBarIndex,
             displaySupportLevel,
             bar_index,
             displaySupportLevel,
             extend=extend.right,
             color=supportColorInput,
             width=lineWidthInput)

    else

        line.set_xy1(supportLine, drawingStartBarIndex, displaySupportLevel)
        line.set_xy2(supportLine, bar_index, displaySupportLevel)
        line.set_extend(supportLine, extend.right)
        line.set_color(supportLine, supportColorInput)
        line.set_width(supportLine, lineWidthInput)

    string supportLabelText = localizedText("Support ", "支撑 ") + str.tostring(displaySupportLevel, format.mintick)

    if displayingReversedSupport
        supportLabelText += localizedText(" | Former resistance", "｜原压力转支撑")
    else if showStrengthInput and not na(displaySupportStrengthScore)
        supportLabelText += " | " + displaySupportStrengthLabel + " " + str.tostring(displaySupportStrengthScore, "#")

    if na(supportLabel)

        supportLabel := label.new(
             labelBarIndex,
             displaySupportLevel,
             supportLabelText,
             style=label.style_none,
             textcolor=supportColorInput,
             size=size.normal)

    else

        label.set_x(supportLabel, labelBarIndex)
        label.set_y(supportLabel, displaySupportLevel)
        label.set_text(supportLabel, supportLabelText)
        label.set_textcolor(supportLabel, supportColorInput)

else

    if not na(supportLine)
        line.delete(supportLine)
        supportLine := na

    if not na(supportZoneBox)
        box.delete(supportZoneBox)
        supportZoneBox := na

    if not na(supportLabel)
        label.delete(supportLabel)
        supportLabel := na

// ============================================================================
// RESISTANCE DISPLAY
// ============================================================================

if not na(displayResistanceLevel)

    if na(resistanceZoneBox)

        resistanceZoneBox := box.new(
             left=drawingStartBarIndex,
             top=displayResistanceZoneUpperBound,
             right=bar_index,
             bottom=displayResistanceZoneLowerBound,
             border_color=color.new(resistanceColorInput, 45),
             bgcolor=color.new(resistanceColorInput, zoneTransparencyInput),
             extend=extend.right)

    else

        box.set_lefttop(resistanceZoneBox, drawingStartBarIndex, displayResistanceZoneUpperBound)
        box.set_rightbottom(resistanceZoneBox, bar_index, displayResistanceZoneLowerBound)
        box.set_extend(resistanceZoneBox, extend.right)
        box.set_border_color(resistanceZoneBox, color.new(resistanceColorInput, 45))
        box.set_bgcolor(resistanceZoneBox, color.new(resistanceColorInput, zoneTransparencyInput))

    if na(resistanceLine)

        resistanceLine := line.new(
             drawingStartBarIndex,
             displayResistanceLevel,
             bar_index,
             displayResistanceLevel,
             extend=extend.right,
             color=resistanceColorInput,
             width=lineWidthInput)

    else

        line.set_xy1(resistanceLine, drawingStartBarIndex, displayResistanceLevel)
        line.set_xy2(resistanceLine, bar_index, displayResistanceLevel)
        line.set_extend(resistanceLine, extend.right)
        line.set_color(resistanceLine, resistanceColorInput)
        line.set_width(resistanceLine, lineWidthInput)

    string resistanceLabelText = localizedText("Resistance ", "压力 ") + str.tostring(displayResistanceLevel, format.mintick)

    if displayingReversedResistance
        resistanceLabelText += localizedText(" | Former support", "｜原支撑转压力")
    else if showStrengthInput and not na(displayResistanceStrengthScore)
        resistanceLabelText += " | " + displayResistanceStrengthLabel + " " + str.tostring(displayResistanceStrengthScore, "#")

    if na(resistanceLabel)

        resistanceLabel := label.new(
             labelBarIndex,
             displayResistanceLevel,
             resistanceLabelText,
             style=label.style_none,
             textcolor=resistanceColorInput,
             size=size.normal)

    else

        label.set_x(resistanceLabel, labelBarIndex)
        label.set_y(resistanceLabel, displayResistanceLevel)
        label.set_text(resistanceLabel, resistanceLabelText)
        label.set_textcolor(resistanceLabel, resistanceColorInput)

else

    if not na(resistanceLine)
        line.delete(resistanceLine)
        resistanceLine := na

    if not na(resistanceZoneBox)
        box.delete(resistanceZoneBox)
        resistanceZoneBox := na

    if not na(resistanceLabel)
        label.delete(resistanceLabel)
        resistanceLabel := na

// ============================================================================
// SIMPLE DASHBOARD
// ============================================================================

// The dashboard intentionally translates internal calculations into simple
// trading-language explanations instead of exposing implementation details.

var table dashboard = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast

    if showDashboardInput

        color normalTextColor = chart.fg_color
        color headerBackground = color.new(chart.fg_color, 90)

        // Header
        table.cell(dashboard, 0, 0, localizedText("Adaptive S/R", "智能撑压"), text_color=normalTextColor, bgcolor=headerBackground)
        table.cell(dashboard, 1, 0, localizedText("Current", "当前"), text_color=normalTextColor, bgcolor=headerBackground)

        // Support
        table.cell(dashboard, 0, 1, localizedText("Support", "支撑位置"), text_color=supportColorInput)

        string supportDashboardText = "--"

        if not na(displaySupportLevel)
            supportDashboardText := str.tostring(displaySupportLevel, format.mintick)

            if showStrengthInput and not na(displaySupportStrengthScore)
                supportDashboardText += " | " + displaySupportStrengthLabel + " " + str.tostring(displaySupportStrengthScore, "#") + "/100"

        table.cell(dashboard, 1, 1, supportDashboardText, text_color=supportColorInput)

        // Why this support
        table.cell(dashboard, 0, 2, localizedText("Why this level?", "为什么是它？"), text_color=normalTextColor)

        string supportReasonText = "--"

        if displayingReversedSupport

            supportReasonText := localizedText("Old resistance held after a retest", "原压力突破后，回踩守住了")

        else if not na(displaySupportLevel)

            if useChinese
                supportReasonText := "历史碰过" + str.tostring(selectedSupportTouchCount) + "次，之后平均反弹" + str.tostring(nz(supportAverageReactionPercent), "#.##") + "%"
            else
                supportReasonText := str.tostring(selectedSupportTouchCount) + " tests; avg bounce " + str.tostring(nz(supportAverageReactionPercent), "#.##") + "%"

        table.cell(dashboard, 1, 2, supportReasonText, text_color=normalTextColor)

        // Resistance
        table.cell(dashboard, 0, 3, localizedText("Resistance", "压力位置"), text_color=resistanceColorInput)

        string resistanceDashboardText = "--"

        if not na(displayResistanceLevel)
            resistanceDashboardText := str.tostring(displayResistanceLevel, format.mintick)

            if showStrengthInput and not na(displayResistanceStrengthScore)
                resistanceDashboardText += " | " + displayResistanceStrengthLabel + " " + str.tostring(displayResistanceStrengthScore, "#") + "/100"

        table.cell(dashboard, 1, 3, resistanceDashboardText, text_color=resistanceColorInput)

        // Why this resistance
        table.cell(dashboard, 0, 4, localizedText("Why this level?", "为什么是它？"), text_color=normalTextColor)

        string resistanceReasonText = "--"

        if displayingReversedResistance

            resistanceReasonText := localizedText("Old support rejected price after a rebound", "原支撑跌破后，反抽没有站回去")

        else if not na(displayResistanceLevel)

            if useChinese
                resistanceReasonText := "历史碰过" + str.tostring(selectedResistanceTouchCount) + "次，之后平均回落" + str.tostring(nz(resistanceAverageReactionPercent), "#.##") + "%"
            else
                resistanceReasonText := str.tostring(selectedResistanceTouchCount) + " tests; avg pullback " + str.tostring(nz(resistanceAverageReactionPercent), "#.##") + "%"

        table.cell(dashboard, 1, 4, resistanceReasonText, text_color=normalTextColor)

        // Search distance
        table.cell(dashboard, 0, 5, localizedText("How far it searched", "算法看了多远"), text_color=normalTextColor)

        string searchRangeText = "--"

        if searchModeInput == SEARCH_MODE_MANUAL

            searchRangeText := localizedText("Manual ", "手动 ") + str.tostring(manualSearchRangePercentInput, "#") + "%"

        else

            if useChinese
                searchRangeText := "下方" + str.tostring(nz(activeSupportSearchRangePercent, maximumAutoSearchRangePercentInput), "#") + "%｜上方" + str.tostring(nz(activeResistanceSearchRangePercent, maximumAutoSearchRangePercentInput), "#") + "%"
            else
                searchRangeText := "Below " + str.tostring(nz(activeSupportSearchRangePercent, maximumAutoSearchRangePercentInput), "#") + "% | Above " + str.tostring(nz(activeResistanceSearchRangePercent, maximumAutoSearchRangePercentInput), "#") + "%"

        table.cell(dashboard, 1, 5, searchRangeText, text_color=normalTextColor)

        // Current state
        color stateBackground = structureState > STATE_NORMAL ? color.new(supportColorInput, 85) : structureState < STATE_NORMAL ? color.new(resistanceColorInput, 85) : headerBackground

        table.cell(dashboard, 0, 6, localizedText("Current state", "现在怎么看"), text_color=normalTextColor, bgcolor=stateBackground)
        table.cell(dashboard, 1, 6, currentStateText, text_color=normalTextColor, bgcolor=stateBackground)

    else

        for rowIndex = 0 to 6
            table.cell(dashboard, 0, rowIndex, "", bgcolor=color.new(color.black, 100))
            table.cell(dashboard, 1, rowIndex, "", bgcolor=color.new(color.black, 100))

// ============================================================================
// ALERT CONDITIONS
// ============================================================================

alertcondition(confirmedResistanceBreak, title="Adaptive S/R: Resistance Break", message="Price closed above the active resistance zone. / 价格收盘有效突破当前压力区域。")

alertcondition(confirmedSupportBreak, title="Adaptive S/R: Support Break", message="Price closed below the active support zone. / 价格收盘有效跌破当前支撑区域。")

alertcondition(resistanceToSupportConfirmedEvent, title="Adaptive S/R: Resistance Became Support", message="Former resistance held after a retest and is now treated as support. / 原压力区域回踩守住，确认转为支撑。")

alertcondition(supportToResistanceConfirmedEvent, title="Adaptive S/R: Support Became Resistance", message="Former support rejected price after a rebound and is now treated as resistance. / 原支撑区域反抽未收回，确认转为压力。")

alertcondition(failedBreakoutEvent, title="Adaptive S/R: Failed Breakout", message="Price broke resistance but returned below the former zone. / 价格突破压力后重新跌回原区域。")

alertcondition(failedBreakdownEvent, title="Adaptive S/R: Failed Breakdown", message="Price broke support but recovered above the former zone. / 价格跌破支撑后重新收回原区域。")
````
