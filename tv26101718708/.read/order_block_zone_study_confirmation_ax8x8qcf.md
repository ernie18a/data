# Order Block Zone Study + Confirmation

- url: https://www.tradingview.com/script/Ax8x8QCF-Order-Block-Zone-Study-Confirmation/
- type: indicator
- pine_id: PUB;f60842ba5205497b834d218e5b37f4f1
- version: 4.0

## Description

[b]Order Block Zone Study + Confirmation[/b] marks support and resistance order-block zones, then helps users judge whether price is only reaching a zone or reacting with confirmation.

It is designed to answer three simple questions:

[list]
[*]Where is the order-block zone?
[*]How strong is the zone based on the model?
[*]Is price only touching it, or is confirmation also active?
[/list]

[quote]The goal is not to give automatic trade calls. The goal is to make order-block zones easier to read, compare, and monitor.[/quote]

[b]==================================================
WARNING
==================================================[/b]

This indicator is a chart-reading tool. It does not predict the future and does not guarantee that any order block will hold.

The labels, scores, observed stats, and confirmation markers are based on the script's internal model and the available chart data. They should be used as context, not as financial advice or as standalone buy/sell instructions.

[quote]A zone can look strong and still fail. Always check the broader trend, market structure, liquidity, news risk, and your own risk management.[/quote]

[b]==================================================
(1) OVERVIEW
==================================================[/b]

This indicator has two main parts.

[b]1) Order-block zone detection[/b]

The script detects bullish and bearish order-block-style zones.

[list]
[*][b]Support OB[/b] - a bullish order-block zone that may act as support.
[*][b]Resistance OB[/b] - a bearish order-block zone that may act as resistance.
[/list]

The zone logic uses several chart conditions together, including:

[list]
[*]swing highs and swing lows
[*]the last opposite candle before a displacement move
[*]ATR-based displacement strength
[*]EMA trend alignment
[*]premium / discount location
[*]pivot support or resistance confluence
[*]body expansion and relative volume
[*]current market bias
[/list]

[b]2) Confirmation add-on[/b]

The confirmation layer checks whether price is simply reaching the zone or whether the reaction is supported by additional conditions.

It can use:

[list]
[*]fast EMA position
[*]fast EMA direction
[*]RSI behavior
[*]MACD behavior
[*]candle direction
[*]relative volume
[/list]

[quote]The box shows where the zone is. The label explains the zone quality. The triangle shows that confirmation conditions are active.[/quote]

[b]==================================================
(2) WHAT YOU SEE ON THE CHART
==================================================[/b]

[list]
[*][b]Boxes[/b] - active support or resistance OB zones.
[*][b]Labels[/b] - zone type, grade, status, observed behavior, edge class, and model rating.
[*][b]Triangles[/b] - confirmation conditions after price reaches or approaches a zone.
[*][b]Faded zones[/b] - historical or invalidated zones kept for visual context.
[*][b]Midline[/b] - the center of the zone, useful for reading depth of reaction.
[/list]

The indicator is designed to keep the latest active zones visible and reduce chart clutter by limiting how many zones and labels remain on the chart.

[b]==================================================
(3) HOW TO USE IT PROPERLY
==================================================[/b]

The correct way to use this indicator is to read the zone step by step, not only look at the box.

[b]Simple workflow[/b]

[list=1]
[*][b]Find the zone.[/b]
Check whether price is reacting around a support OB or resistance OB.

[*][b]Read the label.[/b]
The label explains the model grade, zone status, observed behavior, edge class, and final model rating.

[*][b]Check the status.[/b]
Fresh zones are usually cleaner than tested zones. Broken zones should not be treated as active zones.

[*][b]Wait for reaction quality.[/b]
A zone touch alone is only the first step. Confirmation adds evidence that price is reacting.

[*][b]Use the triangle as confirmation context.[/b]
A triangle means the confirmation engine found enough supporting conditions. It is not a guaranteed entry.

[*][b]Check broader market structure.[/b]
Use the indicator together with trend, support/resistance, liquidity, and risk management.
[/list]

[quote]The best reading comes when the zone type, label quality, status, confirmation, and broader market structure all support the same idea.[/quote]

[b]==================================================
(4) LABEL EXPLANATION
==================================================[/b]

A label may look like this:

[pine]
Support OB | Grade A | Status Fresh | Observed 61.2% | Edge Strong | Model 8.1/10
[/pine]

[b]Support OB / Resistance OB[/b]

This tells you the zone type.

[list]
[*][b]Support OB[/b] - bullish order-block zone, treated as possible support.
[*][b]Resistance OB[/b] - bearish order-block zone, treated as possible resistance.
[/list]

[b]Grade[/b]

The grade summarizes the internal zone score.

[list]
[*][b]A++[/b] - 86 or higher
[*][b]A[/b] - 72 to 85.99
[*][b]B+[/b] - 60 to 71.99
[*][b]B[/b] - 48 to 59.99
[*][b]C[/b] - below 48
[/list]

A++ and A are stronger model grades. B+ is acceptable. B and C are weaker.

[b]Status[/b]

The status explains the current condition of the zone.

[list]
[*][b]Fresh[/b] - price has not touched the zone yet.
[*][b]Tested[/b] - price already touched the zone.
[*][b]Broken[/b] - price invalidated the zone.
[/list]

Fresh is usually cleaner than tested. Broken means the zone is no longer active.

[b]Observed[/b]

Observed shows the script's chart-based observation for that side of the model. It combines how often zones were touched and how often resolved zones reached the model target before invalidation.

This is not a guaranteed win rate. It depends on available chart history and the number of resolved examples.

[b]Edge[/b]

Edge classifies the model's observed reward/risk behavior into simple language:

[list]
[*]Weak
[*]Slightly Weak
[*]Neutral
[*]Strong
[*]Very Strong
[/list]

This is based on observed target/invalidation behavior, ATR-based target and invalidation distances, and confidence from sample size.

[b]Model[/b]

Model is the final combined rating from 1 to 10.

It combines:

[list]
[*]zone grade
[*]zone status
[*]observed behavior
[*]edge class
[*]confidence from available outcomes
[/list]

A practical reading:

[list]
[*][b]8 to 10[/b] - stronger model reading
[*][b]6 to 7.9[/b] - decent model reading
[*][b]4 to 5.9[/b] - average or weaker reading
[*][b]below 4[/b] - low-quality reading
[/list]

[b]==================================================
(5) PRACTICAL LABEL EXAMPLES
==================================================[/b]

[b]Example 1[/b]

[pine]
Support OB | Grade A | Status Fresh | Observed 63% | Edge Strong | Model 8.2/10
[/pine]

This is a stronger support-zone reading. If price returns and confirmation appears, the reaction has better model support.

[b]Example 2[/b]

[pine]
Resistance OB | Grade B+ | Status Fresh | Observed 55% | Edge Neutral | Model 6.6/10
[/pine]

This is a watchlist-quality resistance zone. It may be useful, but it is not as strong unless confirmation appears.

[b]Example 3[/b]

[pine]
Support OB | Grade A++ | Status Tested | Observed 60% | Edge Strong | Model 7.4/10
[/pine]

The grade is strong, but the zone has already been tested. It can still matter, but it is less clean than a fresh zone.

[b]Example 4[/b]

[pine]
Resistance OB | Grade C | Status Fresh | Observed 47% | Edge Weak | Model 3.8/10
[/pine]

This is a weak model reading. Even if price reaches it, it should not be trusted alone.

[b]Example 5[/b]

[pine]
Support OB | Grade B+ | Status Fresh | Observed 58% | Edge Neutral | Model 6.9/10
[/pine]

This is a decent zone, but if there is no confirmation, it is usually better to keep watching instead of treating the touch as enough.

[b]==================================================
(6) CONFIRMATION
==================================================[/b]

Confirmation is optional, but useful.

The order block marks the important area. The confirmation add-on checks whether price is reacting with enough supporting evidence.

[b]Simple logic[/b]

[list]
[*][b]OB zone[/b] = where price may react.
[*][b]Label[/b] = how good the zone looks according to the model.
[*][b]Triangle[/b] = confirmation conditions are active.
[/list]

For support confirmation, the script checks whether price is inside or near the support OB and whether enough bullish confirmation conditions are active.

For resistance confirmation, it checks the opposite side.

The confirmation engine can include:

[list]
[*]EMA position
[*]EMA direction
[*]RSI behavior
[*]MACD behavior
[*]candle behavior
[*]relative volume
[/list]

[quote]A zone touch starts the observation. Confirmation adds extra evidence that the reaction may be developing.[/quote]

[b]==================================================
(7) ALERTS
==================================================[/b]

The alert conditions can be grouped into three simple types.

[b]1) Zone reached alerts[/b]

These alerts tell you price has reached a support or resistance OB zone.

This means the area is active, but confirmation may not be present yet.

[b]2) Zone reached + confirmation alerts[/b]

These alerts tell you price reached the zone and confirmation conditions are active.

This is the stronger alert type, but it is still only a chart condition.

[b]3) Confirmation only / any event alerts[/b]

These alerts are broader monitoring alerts. They are useful when you want to know that a support or resistance event is happening, even if you do not want a very specific alert.

[pine]
Reached only = start watching
Reached + confirmation = stronger chart condition
[/pine]

[quote]Alerts are monitoring tools. They are not trade instructions and do not guarantee a result.[/quote]

[b]==================================================
(8) HOW THE MODEL IS CALCULATED
==================================================[/b]

[b]1. Zone Score[/b]

[pine]
Score = Base + Displacement + Break + Trend + Body + Volume + PD Filter + S/R Filter + Bias + Edge
[/pine]

The score combines several pieces of zone quality, including displacement strength, structure break, trend alignment, candle body expansion, volume expansion, premium/discount location, pivot confluence, market bias, and observed edge.

[b]2. Quality Grade[/b]

[pine]
Quality Grade = function of Score
[/pine]

The raw score is converted into A++, A, B+, B, or C.

[b]3. Zone Status[/b]

[pine]
Zone Status = Fresh, Tested, or Broken
[/pine]

The status depends on whether price has touched or invalidated the zone.

[b]4. Observed Rate[/b]

[pine]
Observed Rate = Target Rate x Touch Rate
[/pine]

This combines how often zones are revisited and how often resolved zones reach the model target before invalidation.

[b]5. Target Rate[/b]

[pine]
Target Rate = Targets Reached / Resolved Zones x 100
[/pine]

This measures resolved zones only.

[b]6. Touch Rate[/b]

[pine]
Touch Rate = Touches / Total Zones x 100
[/pine]

This measures how often detected zones were revisited by price.

[b]7. Reward/Risk Ratio[/b]

[pine]
RR = Target ATR Multiplier / Invalidation ATR Multiplier
[/pine]

This is based on the ATR target and invalidation settings.

[b]8. Edge[/b]

[pine]
Edge = Target Rate x RR - (1 - Target Rate)
[/pine]

This estimates whether the observed target/invalidation behavior is positive, neutral, or weak.

[b]9. Confidence[/b]

[pine]
Confidence = min(Resolved Outcomes / Minimum Observed Outcomes, 1.0)
[/pine]

Confidence adjusts how much trust is placed on the observed stats. Low sample size means lower confidence.

[b]10. Final Model Rating[/b]

[pine]
Model Rating = Grade Score + Status Score + Observed Score + Edge Score
[/pine]

This creates the final label rating from 1 to 10.

[b]==================================================
(9) IMPORTANT LIMITATIONS
==================================================[/b]

This script does not know the future. It only evaluates chart conditions using its internal rules.

Observed stats can be unreliable when there are not enough resolved examples. A label can show useful context, but it should not be treated as proof that the next zone will work.

Order blocks can fail during strong trends, news events, low-liquidity conditions, or when broader market structure changes.

[quote]Use the model rating as context, not certainty.[/quote]

[b]==================================================
DISCLAIMER
==================================================[/b]

This script is a public open-source indicator for educational and informational use.

It is not financial advice, investment advice, or a recommendation to buy or sell any asset.

The script identifies order-block-style chart zones and confirmation conditions only. It does not guarantee profitable trades, signal accuracy, or future performance.

Users should always apply their own analysis, position sizing, and risk management before making any trading decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ReconHK

//@version=6
indicator("IND003 - Order Block Zone + Confirmation v1.1", shorttitle="IND003 - OB Zone Study v1.1", overlay=true, max_bars_back=5000, max_boxes_count=200, max_labels_count=200, max_lines_count=200)
//------------------------------------------------------------------------------
// Order Block Zone Study + Confirmation
// Minor refresh: label class display + alert text cleanup. Core OB logic unchanged.
//
// This indicator marks order-block-style support and resistance zones, then adds
// a lightweight confirmation layer around touches and retests.
//
// New label model:
// Origin   = how strongly the OB was created.
// Location = how meaningful the OB position is.
// Reaction = how price behaved after returning to the OB.
// Score    = weighted total from Origin, Location, and Reaction, shown from 0/30.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Input groups
//------------------------------------------------------------------------------
grp_main    = "Main Settings"
grp_rating  = "OB Rating"
grp_confirm = "Confirmation Add-On"

//------------------------------------------------------------------------------
// Tooltips
//------------------------------------------------------------------------------
TT_SWING_LEN = "Range: 3-30. Controls how many left-side bars are used to detect swing highs/lows. Lower values create more zones but more noise. Higher values create fewer but stronger zones."
TT_PIVOT_CONFIRM = "Range: 0-10. Number of right-side bars needed before a pivot is confirmed. 0 is fastest but less stable. 1-3 is usually balanced."
TT_LOOKBACK = "Range: 5-50. How far back from the confirmed pivot the script searches for the source candle of the OB."
TT_DISP = "Range: 0.5-10 ATR. Minimum displacement needed after the source candle. Higher values require a stronger impulse move."
TT_EMA = "Range: 5-100. EMA used for trend filtering in the OB rating and confirmation logic."
TT_PD = "When enabled, support OBs score better below the recent range midpoint, and resistance OBs score better above the recent range midpoint."
TT_SR = "When enabled, OBs score better when close to recent pivot support/resistance."
TT_MIN_SCORE = "Range: 0-30. Minimum final OB score required for zone events and confirmation logic. Higher values make signals stricter. Suggested balanced value: 17.5."
TT_TP = "Range: 0.5-20 ATR. Observation target distance used to judge whether price reacted well after touching the OB. This is not a trade order."
TT_SL = "Range: 0.5-20 ATR. Observation failure distance used to judge whether the OB reaction failed. This is not a trade order."
TT_HIST = "Shows broken zones in a faded historical style instead of deleting them immediately."
TT_LABELS = "Shows labels beside the newest active zones. The label shows Origin, Location, Reaction, final Score, and optional score class."
TT_SCORE_CLASS = "Adds Weak / Moderate / Good / Strong classification to active OB labels."
TT_LATEST_LABELS = "Range: 0-3. Number of newest support labels and newest resistance labels to show. Use 0 for no labels."
TT_LABEL_LEAD = "Range: 0-10 bars. Moves labels to the right of the current candle."

TT_ORIGIN_WEIGHT = "Range: 0-100. Weight of Origin in the final OB score. Origin measures how strongly the OB was created: displacement, structure break, candle body, and volume. Suggested default: 40."
TT_LOCATION_WEIGHT = "Range: 0-100. Weight of Location in the final OB score. Location measures where the OB sits: premium/discount, pivot S/R confluence, trend alignment, and market bias. Suggested default: 40."
TT_REACTION_WEIGHT = "Range: 0-100. Weight of Reaction in the final OB score. Reaction measures what price did after returning to the OB. Suggested default: 20 because reaction may be unknown when the OB is still fresh."

TT_CONF_ENABLE = "Turns the confirmation layer on/off. Confirmation checks momentum, EMA, RSI, MACD, candle direction, and relative volume near an OB."
TT_CONF_WINDOW = "Range: 1-10 bars. How long after the first OB touch confirmation can still be valid."
TT_BULL_HITS = "Range: 1-6. Minimum number of support confirmation checks that must pass."
TT_BEAR_HITS = "Range: 1-6. Minimum number of resistance confirmation checks that must pass."
TT_RSI_LEN = "Range: 5-50. RSI length used in confirmation."
TT_FAST_EMA = "Range: 3-50. Fast EMA used in confirmation."
TT_SLOW_EMA = "Range: 5-100. Slow EMA used in confirmation. Usually should be higher than the fast EMA."
TT_RVOL_LEN = "Range: 5-100. Lookback used to calculate relative volume."
TT_NEAR_ATR = "Range: 0.05-1.00 ATR. How close price must be to the OB to count as near-zone confirmation."
TT_SCORE_TOL = "Range: 0-10 points. Allows confirmation on OBs slightly below the main minimum score."
TT_SHAPES = "Shows small confirmation triangles when confirmation conditions trigger."
TT_CLOSE_ONLY = "When enabled, confirmation alerts and triangles are only valid after the bar closes."
TT_STATE_CHANGE = "When enabled, alerts trigger only on the first bar of a new signal state."

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
swingLen            = input.int(7, "Swing detection length", minval=3, maxval=30, group=grp_main, tooltip=TT_SWING_LEN)
pivotConfirmBars    = input.int(1, "Pivot confirmation bars", minval=0, maxval=10, group=grp_main, tooltip=TT_PIVOT_CONFIRM)
lookbackBars        = input.int(18, "Source candle lookback", minval=5, maxval=50, group=grp_main, tooltip=TT_LOOKBACK)
dispMult            = input.float(1.3, "Displacement multiplier (ATR)", minval=0.5, maxval=10.0, step=0.1, group=grp_main, tooltip=TT_DISP)
emaLen              = input.int(20, "EMA filter length", minval=5, maxval=100, group=grp_main, tooltip=TT_EMA)
usePdFilter         = input.bool(true, "Use premium / discount filter", group=grp_main, tooltip=TT_PD)
useSrFilter         = input.bool(true, "Use pivot S/R confluence", group=grp_main, tooltip=TT_SR)
minSignalScore      = input.float(17.5, "Minimum OB score", minval=0.0, maxval=30.0, step=0.5, group=grp_main, tooltip=TT_MIN_SCORE)
tpAtrMult           = input.float(3.0, "Reaction target distance (ATR)", minval=0.5, maxval=20.0, step=0.1, group=grp_main, tooltip=TT_TP)
slAtrMult           = input.float(4.0, "Reaction failure distance (ATR)", minval=0.5, maxval=20.0, step=0.1, group=grp_main, tooltip=TT_SL)
showHistorical      = input.bool(true, "Show historical zones", group=grp_main, tooltip=TT_HIST)
showLabels          = input.bool(true, "Show labels", group=grp_main, tooltip=TT_LABELS)
showScoreClass      = input.bool(true, "Show score class in labels", group=grp_main, tooltip=TT_SCORE_CLASS)
latestLabelsPerSide = input.int(2, "Latest labels per side", minval=0, maxval=3, group=grp_main, tooltip=TT_LATEST_LABELS)
labelLeadBars       = input.int(0, "Label lead bars", minval=0, maxval=10, group=grp_main, tooltip=TT_LABEL_LEAD)

originWeight   = input.float(34.0, "Origin weight (%)", minval=0.0, maxval=100.0, step=5.0, group=grp_rating, tooltip=TT_ORIGIN_WEIGHT)
locationWeight = input.float(33.0, "Location weight (%)", minval=0.0, maxval=100.0, step=5.0, group=grp_rating, tooltip=TT_LOCATION_WEIGHT)
reactionWeight = input.float(33.0, "Reaction weight (%)", minval=0.0, maxval=100.0, step=5.0, group=grp_rating, tooltip=TT_REACTION_WEIGHT)

enableConfirmationAddOn   = input.bool(true, "Enable confirmation add-on", group=grp_confirm, tooltip=TT_CONF_ENABLE)
confirmWindowBars         = input.int(4, "Confirmation window after zone touch", minval=1, maxval=10, group=grp_confirm, tooltip=TT_CONF_WINDOW)
bullConfirmMinHits        = input.int(2, "Support confirmation min hits", minval=1, maxval=6, group=grp_confirm, tooltip=TT_BULL_HITS)
bearConfirmMinHits        = input.int(2, "Resistance confirmation min hits", minval=1, maxval=6, group=grp_confirm, tooltip=TT_BEAR_HITS)
confirmRsiLen             = input.int(14, "Confirmation RSI length", minval=5, maxval=50, group=grp_confirm, tooltip=TT_RSI_LEN)
confirmFastEmaLen         = input.int(9, "Confirmation fast EMA", minval=3, maxval=50, group=grp_confirm, tooltip=TT_FAST_EMA)
confirmSlowEmaLen         = input.int(21, "Confirmation slow EMA", minval=5, maxval=100, group=grp_confirm, tooltip=TT_SLOW_EMA)
confirmRvolLen            = input.int(20, "Confirmation RVOL length", minval=5, maxval=100, group=grp_confirm, tooltip=TT_RVOL_LEN)
confirmNearAtrMult        = input.float(0.25, "Near zone distance (ATR)", minval=0.05, maxval=1.0, step=0.05, group=grp_confirm, tooltip=TT_NEAR_ATR)
confirmScoreTolerance     = input.float(2.5, "Allowed score tolerance", minval=0.0, maxval=10.0, step=0.5, group=grp_confirm, tooltip=TT_SCORE_TOL)
showConfirmShapes         = input.bool(true, "Show confirmation triangles", group=grp_confirm, tooltip=TT_SHAPES)
confirmOnlyOnClose        = input.bool(true, "Confirmation only on bar close", group=grp_confirm, tooltip=TT_CLOSE_ONLY)
confirmAlertOnStateChange = input.bool(true, "Alert only on first signal bar", group=grp_confirm, tooltip=TT_STATE_CHANGE)

//------------------------------------------------------------------------------
// Internal defaults
//------------------------------------------------------------------------------
maxActivePerSide = 6
zoneExtend       = 180

normalizeZones = true
normAtrMult    = 0.75

pdLookback    = 80
srAtrDistance = 0.8
bodyPeriod    = 20
volPeriod     = 20
bodyMult      = 1.3
volMult       = 1.05

confirmBars      = 3
requireMidClose  = false
requirePrevBreak = false

showBull    = true
showBear    = true
showMidLine = true

bullBg      = color.new(color.teal, 82)
bullBorder  = color.new(color.lime, 10)
bearBg      = color.new(color.red, 84)
bearBorder  = color.new(color.red, 10)
touchBg     = color.new(color.gray, 88)
touchBorder = color.new(color.gray, 40)
histBullBg  = color.new(color.teal, 95)
histBearBg  = color.new(color.red, 95)
histBullBor = color.new(color.teal, 88)
histBearBor = color.new(color.red, 88)

//------------------------------------------------------------------------------
// Core series
//------------------------------------------------------------------------------
atr = ta.atr(14)
ema = ta.ema(close, emaLen)
avgBody = ta.sma(math.abs(close - open), bodyPeriod)
avgVol  = ta.sma(volume, volPeriod)

bodySpike = avgBody > 0 and math.abs(close - open) >= avgBody * bodyMult
volSpike  = avgVol > 0 and volume >= avgVol * volMult

rangeHigh = ta.highest(high, pdLookback)
rangeLow  = ta.lowest(low, pdLookback)
rangeMid  = (rangeHigh + rangeLow) * 0.5

barMsRaw = bar_index > 0 ? time - time[1] : 0
barMs = barMsRaw > 0 ? barMsRaw : 1

//------------------------------------------------------------------------------
// Pivots and market bias
//------------------------------------------------------------------------------
ph = ta.pivothigh(high, swingLen, pivotConfirmBars)
pl = ta.pivotlow(low, swingLen, pivotConfirmBars)

var float lastPivotHigh = na
var float lastPivotLow  = na
var int marketBias = 0

if not na(ph)
    lastPivotHigh := ph

if not na(pl)
    lastPivotLow := pl

bullBreakBias = not na(lastPivotHigh) and close > lastPivotHigh
bearBreakBias = not na(lastPivotLow) and close < lastPivotLow

if bullBreakBias
    marketBias := 1
else if bearBreakBias
    marketBias := -1

//------------------------------------------------------------------------------
// Order block type
//------------------------------------------------------------------------------
type OrderBlock
    box zone
    label lbl
    line midLn
    float top
    float bot
    float rawTop
    float rawBot
    float originScore
    float locationScore
    float reactionScore
    float score
    float maxCoverage
    float tp
    float sl
    int srcBar
    int srcTime
    int detectBar
    int touchBar
    bool isBull
    bool touched
    bool resolved
    bool won
    bool inHist

var bullActive = array.new<OrderBlock>()
var bearActive = array.new<OrderBlock>()
var bullHist   = array.new<OrderBlock>()
var bearHist   = array.new<OrderBlock>()

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(_x, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _x))

f_round_1(_x) =>
    math.round(_x * 10.0) / 10.0

f_normalize_zone(_top, _bot, _atrNow) =>
    if normalizeZones and _atrNow > 0
        mid = (_top + _bot) * 0.5
        halfH = _atrNow * normAtrMult * 0.5
        [mid + halfH, mid - halfH]
    else
        [_top, _bot]

f_find_last_bear_candle(_start, _end) =>
    int found = na
    for i = _start to _end
        if bar_index - i >= 0 and close[i] < open[i]
            found := i
            break
    found

f_find_last_bull_candle(_start, _end) =>
    int found = na
    for i = _start to _end
        if bar_index - i >= 0 and close[i] > open[i]
            found := i
            break
    found

//------------------------------------------------------------------------------
// Rating helpers
//------------------------------------------------------------------------------
// Origin = how strongly the OB was created.
// It uses displacement, structure break, candle body, and volume.
f_origin_score(_disp, _srcAtr, _breakOk, _bodyOk, _volOk) =>
    ratio = _srcAtr > 0 and dispMult > 0 ? _disp / (_srcAtr * dispMult) : 0.0

    dispScore =
         ratio >= 1.75 ? 4.0 :
         ratio >= 1.50 ? 3.5 :
         ratio >= 1.25 ? 3.0 :
         ratio >= 1.00 ? 2.5 : 1.0

    breakScore = _breakOk ? 2.0 : 0.0
    bodyScore  = _bodyOk ? 2.0 : 0.0
    volScore   = _volOk ? 2.0 : 0.0

    f_clamp(dispScore + breakScore + bodyScore + volScore, 0.0, 10.0)

// Location = how meaningful the OB position is.
// It uses premium/discount, pivot S/R confluence, trend, and market bias.
f_location_score(_isBull, _mid, _srcAtr) =>
    pdOk = _isBull ? _mid < rangeMid : _mid > rangeMid

    srOk = _isBull ?
         not na(lastPivotLow) and math.abs(_mid - lastPivotLow) <= _srcAtr * srAtrDistance :
         not na(lastPivotHigh) and math.abs(_mid - lastPivotHigh) <= _srcAtr * srAtrDistance

    trendOk = _isBull ? close > ema : close < ema
    biasOk  = _isBull ? marketBias == 1 : marketBias == -1

    pdScore =
         usePdFilter ? pdOk ? 3.0 : 0.0 : 1.5

    srScore =
         useSrFilter ?
             (_isBull ? na(lastPivotLow) : na(lastPivotHigh)) ? 1.5 :
             srOk ? 3.0 : 0.0 :
         1.5

    trendScore = trendOk ? 2.0 : 0.5
    biasScore  = biasOk ? 2.0 : marketBias == 0 ? 1.0 : 0.0

    f_clamp(pdScore + srScore + trendScore + biasScore, 0.0, 10.0)

// Coverage = how much price has entered the OB zone.
// This is used internally for Reaction, but not shown directly in the label.
f_zone_coverage_pct(_isBull, _top, _bot) =>
    zoneH = math.max(_top - _bot, syminfo.mintick)
    rawDepth = _isBull ? _top - low : high - _bot
    f_clamp(rawDepth / zoneH * 100.0, 0.0, 100.0)

// Reaction = what price did after returning to the OB.
// Fresh zones start neutral at 5/10.
f_reaction_score(_isBull, _touched, _resolved, _won, _coverage, _top, _bot) =>
    invalidated = _isBull ? close < _bot : close > _top

    invalidated ? 0.0 :
     _resolved and _won ? 10.0 :
     _resolved and not _won ? 0.0 :
     not _touched ? 5.0 :
     _coverage < 25.0 ? 6.0 :
     _coverage < 75.0 ? 7.0 :
     _coverage < 100.0 ? 4.0 : 3.0

// Final score = weighted sum out of 30.
// Example with 40/40/20 weights:
// Origin 8/10 contributes 9.6 points.
// Location 7/10 contributes 8.4 points.
// Reaction 5/10 contributes 3.0 points.
// Total = 21.0/30.
f_weighted_score_30(_origin, _location, _reaction) =>
    weightSum = originWeight + locationWeight + reactionWeight

    originShare   = weightSum > 0 ? originWeight / weightSum : 1.0 / 3.0
    locationShare = weightSum > 0 ? locationWeight / weightSum : 1.0 / 3.0
    reactionShare = weightSum > 0 ? reactionWeight / weightSum : 1.0 / 3.0

    weighted10 = _origin * originShare + _location * locationShare + _reaction * reactionShare
    f_clamp(weighted10 * 3.0, 0.0, 30.0)

f_calc_dynamic_scores(_ob) =>
    reaction = f_reaction_score(_ob.isBull, _ob.touched, _ob.resolved, _ob.won, _ob.maxCoverage, _ob.top, _ob.bot)
    total = f_weighted_score_30(_ob.originScore, _ob.locationScore, reaction)
    [reaction, total]

f_olr_class(_score) =>
    _score >= 23 ? "Strong" :
     _score >= 16 ? "Good" :
     _score >= 9 ? "Moderate" : "Weak"
     
f_label_text(_isBull, _origin, _location, _reaction, _score) =>

    zoneType = _isBull ? "Support OB" : "Resistance OB"

    originTxt   = str.tostring(math.round(_origin)) + "/10"
    locationTxt = str.tostring(math.round(_location)) + "/10"
    reactionTxt = str.tostring(math.round(_reaction)) + "/10"
    scoreTxt    = str.tostring(math.round(_score)) + "/30"
    classTxt    = showScoreClass ? " | " + f_olr_class(_score) : ""

    zoneType + " | O " + originTxt + " | L " + locationTxt + " | R " + reactionTxt + " | Score " + scoreTxt + classTxt
//------------------------------------------------------------------------------
// Drawing helpers
//------------------------------------------------------------------------------
f_delete_ob(_ob) =>
    if not na(_ob.zone)
        box.delete(_ob.zone)
    if not na(_ob.lbl)
        label.delete(_ob.lbl)
    if not na(_ob.midLn)
        line.delete(_ob.midLn)

f_set_hist_style(_ob) =>
    obWork = _ob

    if not na(obWork.zone)
        obWork.zone.set_extend(extend.none)
        obWork.zone.set_right(time)
        obWork.zone.set_bgcolor(obWork.isBull ? histBullBg : histBearBg)
        obWork.zone.set_border_color(obWork.isBull ? histBullBor : histBearBor)

    if not na(obWork.lbl)
        label.delete(obWork.lbl)
        obWork.lbl := na

    if not na(obWork.midLn)
        obWork.midLn.set_extend(extend.none)
        obWork.midLn.set_x2(time)
        obWork.midLn.set_color(color.new(obWork.isBull ? bullBorder : bearBorder, 80))

    obWork

f_draw_ob(_ob, _showLabel) =>
    obWork = _ob

    [drawReaction, drawScore] = f_calc_dynamic_scores(obWork)
    obWork.reactionScore := drawReaction
    obWork.score := drawScore

    fill = obWork.touched ? touchBg : obWork.isBull ? bullBg : bearBg
    bor  = obWork.touched ? touchBorder : obWork.isBull ? bullBorder : bearBorder
    rightTime = time + int(barMs * zoneExtend)
    mid = (obWork.top + obWork.bot) * 0.5

    if na(obWork.zone)
        obWork.zone := box.new(obWork.srcTime, obWork.top, rightTime, obWork.bot, xloc=xloc.bar_time, border_color=bor, bgcolor=fill, extend=extend.none)
    else
        obWork.zone.set_left(obWork.srcTime)
        obWork.zone.set_right(rightTime)
        obWork.zone.set_top(obWork.top)
        obWork.zone.set_bottom(obWork.bot)
        obWork.zone.set_extend(extend.none)
        obWork.zone.set_bgcolor(fill)
        obWork.zone.set_border_color(bor)

    if showMidLine
        if na(obWork.midLn)
            obWork.midLn := line.new(obWork.srcTime, mid, rightTime, mid, xloc=xloc.bar_time, extend=extend.none, color=bor, width=1)
        else
            obWork.midLn.set_x1(obWork.srcTime)
            obWork.midLn.set_y1(mid)
            obWork.midLn.set_x2(rightTime)
            obWork.midLn.set_y2(mid)
            obWork.midLn.set_extend(extend.none)
            obWork.midLn.set_color(bor)

    if showLabels and _showLabel
        txt = f_label_text(obWork.isBull, obWork.originScore, obWork.locationScore, obWork.reactionScore, obWork.score)
        labelTime = time + int(barMs * labelLeadBars)
        labelY = (obWork.top + obWork.bot) * 0.5
        labelStyle = label.style_label_left
        baseCol = obWork.isBull ? bullBorder : bearBorder
        labelColor = color.new(baseCol, 55)
        textColor = color.white

        if na(obWork.lbl)
            obWork.lbl := label.new(labelTime, labelY, txt, xloc=xloc.bar_time, style=labelStyle, textcolor=textColor, color=labelColor, size=size.small, textalign=text.align_left)
        else
            obWork.lbl.set_xy(labelTime, labelY)
            obWork.lbl.set_text(txt)
            obWork.lbl.set_style(labelStyle)
            obWork.lbl.set_color(labelColor)
            obWork.lbl.set_textcolor(textColor)
    else
        if not na(obWork.lbl)
            label.delete(obWork.lbl)
            obWork.lbl := na

    obWork

f_trim_side(_arr, _histArr, _max) =>
    while array.size(_arr) > _max
        old = array.shift(_arr)
        f_delete_ob(old)

    while array.size(_histArr) > _max * 3
        oldh = array.shift(_histArr)
        f_delete_ob(oldh)

//------------------------------------------------------------------------------
// Label selection
//------------------------------------------------------------------------------
f_pick_latest_three(_arr) =>
    sz = array.size(_arr)
    i1 = sz >= 1 ? sz - 1 : -1
    i2 = sz >= 2 ? sz - 2 : -1
    i3 = sz >= 3 ? sz - 3 : -1
    [i1, i2, i3]

//------------------------------------------------------------------------------
// Detect new resistance OB
//------------------------------------------------------------------------------
if not na(ph) and showBear
    pOfs = pivotConfirmBars
    idx = f_find_last_bull_candle(pOfs + 1, pOfs + lookbackBars)

    if not na(idx)
        rawTop = high[idx]
        rawBot = low[idx]
        disp = rawTop - low[pOfs]
        srcAtr = nz(atr[idx], atr)

        if srcAtr > 0 and disp >= srcAtr * dispMult
            [topN, botN] = f_normalize_zone(rawTop, rawBot, srcAtr)
            mid = (topN + botN) * 0.5

            bodyOk = not na(avgBody[pOfs]) and avgBody[pOfs] > 0 and math.abs(close[pOfs] - open[pOfs]) >= avgBody[pOfs] * bodyMult
            volOk = not na(avgVol[pOfs]) and avgVol[pOfs] > 0 and volume[pOfs] >= avgVol[pOfs] * volMult
            breakOk = close < low[idx]

            originScore = f_origin_score(disp, srcAtr, breakOk, bodyOk, volOk)
            locationScore = f_location_score(false, mid, srcAtr)
            reactionScore = 5.0
            totalScore = f_weighted_score_30(originScore, locationScore, reactionScore)

            target = mid - srcAtr * tpAtrMult
            invalidation = topN + srcAtr * slAtrMult

            ob = OrderBlock.new(
                 na, na, na,
                 topN, botN, rawTop, rawBot,
                 originScore, locationScore, reactionScore, totalScore, 0.0,
                 target, invalidation,
                 bar_index - idx, time[idx], bar_index, na,
                 false, false, false, false, false)

            array.push(bearActive, ob)
            f_trim_side(bearActive, bearHist, maxActivePerSide)

//------------------------------------------------------------------------------
// Detect new support OB
//------------------------------------------------------------------------------
if not na(pl) and showBull
    pOfs = pivotConfirmBars
    idx = f_find_last_bear_candle(pOfs + 1, pOfs + lookbackBars)

    if not na(idx)
        rawTop = high[idx]
        rawBot = low[idx]
        disp = high[pOfs] - rawBot
        srcAtr = nz(atr[idx], atr)

        if srcAtr > 0 and disp >= srcAtr * dispMult
            [topN, botN] = f_normalize_zone(rawTop, rawBot, srcAtr)
            mid = (topN + botN) * 0.5

            bodyOk = not na(avgBody[pOfs]) and avgBody[pOfs] > 0 and math.abs(close[pOfs] - open[pOfs]) >= avgBody[pOfs] * bodyMult
            volOk = not na(avgVol[pOfs]) and avgVol[pOfs] > 0 and volume[pOfs] >= avgVol[pOfs] * volMult
            breakOk = close > high[idx]

            originScore = f_origin_score(disp, srcAtr, breakOk, bodyOk, volOk)
            locationScore = f_location_score(true, mid, srcAtr)
            reactionScore = 5.0
            totalScore = f_weighted_score_30(originScore, locationScore, reactionScore)

            target = mid + srcAtr * tpAtrMult
            invalidation = botN - srcAtr * slAtrMult

            ob = OrderBlock.new(
                 na, na, na,
                 topN, botN, rawTop, rawBot,
                 originScore, locationScore, reactionScore, totalScore, 0.0,
                 target, invalidation,
                 bar_index - idx, time[idx], bar_index, na,
                 true, false, false, false, false)

            array.push(bullActive, ob)
            f_trim_side(bullActive, bullHist, maxActivePerSide)

//------------------------------------------------------------------------------
// Process active zones
//------------------------------------------------------------------------------
bullConfirmRaw = false
bearConfirmRaw = false
bullTouchRaw   = false
bearTouchRaw   = false

if array.size(bullActive) > 0
    for i = array.size(bullActive) - 1 to 0
        ob = array.get(bullActive, i)
        mid = (ob.top + ob.bot) * 0.5

        coverageNow = f_zone_coverage_pct(ob.isBull, ob.top, ob.bot)
        ob.maxCoverage := math.max(ob.maxCoverage, coverageNow)

        touchedNow = coverageNow > 0
        bullTouchRaw := bullTouchRaw or touchedNow

        if touchedNow and not ob.touched
            ob.touched := true
            ob.touchBar := bar_index

        [bullReactionNow, bullScoreNow] = f_calc_dynamic_scores(ob)
        ob.reactionScore := bullReactionNow
        ob.score := bullScoreNow

        pdOk = usePdFilter ? mid < rangeMid : true
        srOk = useSrFilter ? not na(lastPivotLow) and math.abs(mid - lastPivotLow) <= atr * srAtrDistance : true
        touchWindow = not na(ob.touchBar) and bar_index - ob.touchBar >= 0 and bar_index - ob.touchBar <= confirmBars
        reclaim = requireMidClose ? close > mid : close > ob.bot and close >= open
        prevBreak = requirePrevBreak ? close > high[1] : true

        bullZoneOk = marketBias == 1 and not ob.resolved and pdOk and srOk and touchWindow and reclaim and prevBreak and ob.score >= minSignalScore
        bullConfirmRaw := bullConfirmRaw or bullZoneOk

        if ob.touched and not ob.resolved
            if high >= ob.tp
                ob.resolved := true
                ob.won := true
            else if low <= ob.sl
                ob.resolved := true
                ob.won := false

        [bullReactionAfter, bullScoreAfter] = f_calc_dynamic_scores(ob)
        ob.reactionScore := bullReactionAfter
        ob.score := bullScoreAfter

        if close < ob.bot
            if showHistorical
                ob.inHist := true
                ob := f_set_hist_style(ob)
                array.push(bullHist, ob)
            else
                f_delete_ob(ob)

            array.remove(bullActive, i)
        else
            array.set(bullActive, i, ob)

if array.size(bearActive) > 0
    for i = array.size(bearActive) - 1 to 0
        ob = array.get(bearActive, i)
        mid = (ob.top + ob.bot) * 0.5

        coverageNow = f_zone_coverage_pct(ob.isBull, ob.top, ob.bot)
        ob.maxCoverage := math.max(ob.maxCoverage, coverageNow)

        touchedNow = coverageNow > 0
        bearTouchRaw := bearTouchRaw or touchedNow

        if touchedNow and not ob.touched
            ob.touched := true
            ob.touchBar := bar_index

        [bearReactionNow, bearScoreNow] = f_calc_dynamic_scores(ob)
        ob.reactionScore := bearReactionNow
        ob.score := bearScoreNow

        pdOk = usePdFilter ? mid > rangeMid : true
        srOk = useSrFilter ? not na(lastPivotHigh) and math.abs(mid - lastPivotHigh) <= atr * srAtrDistance : true
        touchWindow = not na(ob.touchBar) and bar_index - ob.touchBar >= 0 and bar_index - ob.touchBar <= confirmBars
        reject = requireMidClose ? close < mid : close < ob.top and close <= open
        prevBreak = requirePrevBreak ? close < low[1] : true

        bearZoneOk = marketBias == -1 and not ob.resolved and pdOk and srOk and touchWindow and reject and prevBreak and ob.score >= minSignalScore
        bearConfirmRaw := bearConfirmRaw or bearZoneOk

        if ob.touched and not ob.resolved
            if low <= ob.tp
                ob.resolved := true
                ob.won := true
            else if high >= ob.sl
                ob.resolved := true
                ob.won := false

        [bearReactionAfter, bearScoreAfter] = f_calc_dynamic_scores(ob)
        ob.reactionScore := bearReactionAfter
        ob.score := bearScoreAfter

        if close > ob.top
            if showHistorical
                ob.inHist := true
                ob := f_set_hist_style(ob)
                array.push(bearHist, ob)
            else
                f_delete_ob(ob)

            array.remove(bearActive, i)
        else
            array.set(bearActive, i, ob)

//------------------------------------------------------------------------------
// Trim stored history
//------------------------------------------------------------------------------
f_trim_side(bullActive, bullHist, maxActivePerSide)
f_trim_side(bearActive, bearHist, maxActivePerSide)

//------------------------------------------------------------------------------
// Draw active zones
//------------------------------------------------------------------------------
[bullLbl1, bullLbl2, bullLbl3] = f_pick_latest_three(bullActive)
[bearLbl1, bearLbl2, bearLbl3] = f_pick_latest_three(bearActive)

if array.size(bullActive) > 0
    for i = 0 to array.size(bullActive) - 1
        ob = array.get(bullActive, i)
        showThisLabel = showLabels and (
             latestLabelsPerSide >= 1 and i == bullLbl1 or
             latestLabelsPerSide >= 2 and i == bullLbl2 or
             latestLabelsPerSide >= 3 and i == bullLbl3)

        ob := f_draw_ob(ob, showThisLabel)
        array.set(bullActive, i, ob)

if array.size(bearActive) > 0
    for i = 0 to array.size(bearActive) - 1
        ob = array.get(bearActive, i)
        showThisLabel = showLabels and (
             latestLabelsPerSide >= 1 and i == bearLbl1 or
             latestLabelsPerSide >= 2 and i == bearLbl2 or
             latestLabelsPerSide >= 3 and i == bearLbl3)

        ob := f_draw_ob(ob, showThisLabel)
        array.set(bearActive, i, ob)

//------------------------------------------------------------------------------
// Base zone events
//------------------------------------------------------------------------------
bullConfirm = bullConfirmRaw and not bullConfirmRaw[1]
bearConfirm = bearConfirmRaw and not bearConfirmRaw[1]
bullTouchAlert = bullTouchRaw and not bullTouchRaw[1]
bearTouchAlert = bearTouchRaw and not bearTouchRaw[1]

alertcondition(bullTouchAlert, title="Support OB Zone Reached", message="IND003 - Price reached a support order-block zone on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")
alertcondition(bearTouchAlert, title="Resistance OB Zone Reached", message="IND003 - Price reached a resistance order-block zone on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")

//------------------------------------------------------------------------------
// Confirmation add-on
//------------------------------------------------------------------------------
edge(x) =>
    x and not x[1]

confirmRsi = ta.rsi(close, confirmRsiLen)
confirmFastEma = ta.ema(close, confirmFastEmaLen)
confirmSlowEma = ta.ema(close, confirmSlowEmaLen)
[confirmMacd, confirmMacdSignal, _confirmHist] = ta.macd(close, 12, 26, 9)
confirmAvgVol = ta.sma(volume, confirmRvolLen)
confirmRvol = confirmAvgVol > 0 ? volume / confirmAvgVol : 0.0

bullConfirmAddonRaw = false
bearConfirmAddonRaw = false
bullHitsNow = 0
bearHitsNow = 0

if enableConfirmationAddOn and array.size(bullActive) > 0
    for i = array.size(bullActive) - 1 to 0
        ob = array.get(bullActive, i)

        inZoneNow = low <= ob.top and high >= ob.bot
        nearZoneNow = low <= ob.top + atr * confirmNearAtrMult and close >= ob.bot - atr * confirmNearAtrMult
        recentTouch = ob.touched and not na(ob.touchBar) and bar_index - ob.touchBar >= 0 and bar_index - ob.touchBar <= confirmWindowBars

        bullHit1 = close >= confirmFastEma
        bullHit2 = confirmFastEma >= confirmSlowEma or confirmFastEma >= confirmFastEma[1]
        bullHit3 = confirmRsi > 42 and confirmRsi >= confirmRsi[1]
        bullHit4 = confirmMacd >= confirmMacdSignal or confirmMacd >= confirmMacd[1]
        bullHit5 = close >= open or close >= close[1]
        bullHit6 = confirmRvol >= 0.90

        bullHits = (bullHit1 ? 1 : 0) +
                   (bullHit2 ? 1 : 0) +
                   (bullHit3 ? 1 : 0) +
                   (bullHit4 ? 1 : 0) +
                   (bullHit5 ? 1 : 0) +
                   (bullHit6 ? 1 : 0)

        bullHitsNow := math.max(bullHitsNow, bullHits)

        bullOk = (recentTouch or nearZoneNow) and (inZoneNow or nearZoneNow) and ob.score >= minSignalScore - confirmScoreTolerance and bullHits >= bullConfirmMinHits
        bullConfirmAddonRaw := bullConfirmAddonRaw or bullOk

if enableConfirmationAddOn and array.size(bearActive) > 0
    for i = array.size(bearActive) - 1 to 0
        ob = array.get(bearActive, i)

        inZoneNow = high >= ob.bot and low <= ob.top
        nearZoneNow = high >= ob.bot - atr * confirmNearAtrMult and close <= ob.top + atr * confirmNearAtrMult
        recentTouch = ob.touched and not na(ob.touchBar) and bar_index - ob.touchBar >= 0 and bar_index - ob.touchBar <= confirmWindowBars

        bearHit1 = close <= confirmFastEma
        bearHit2 = confirmFastEma <= confirmSlowEma or confirmFastEma <= confirmFastEma[1]
        bearHit3 = confirmRsi < 58 and confirmRsi <= confirmRsi[1]
        bearHit4 = confirmMacd <= confirmMacdSignal or confirmMacd <= confirmMacd[1]
        bearHit5 = close <= open or close <= close[1]
        bearHit6 = confirmRvol >= 0.90

        bearHits = (bearHit1 ? 1 : 0) +
                   (bearHit2 ? 1 : 0) +
                   (bearHit3 ? 1 : 0) +
                   (bearHit4 ? 1 : 0) +
                   (bearHit5 ? 1 : 0) +
                   (bearHit6 ? 1 : 0)

        bearHitsNow := math.max(bearHitsNow, bearHits)

        bearOk = (recentTouch or nearZoneNow) and (inZoneNow or nearZoneNow) and ob.score >= minSignalScore - confirmScoreTolerance and bearHits >= bearConfirmMinHits
        bearConfirmAddonRaw := bearConfirmAddonRaw or bearOk

//------------------------------------------------------------------------------
// Confirmation markers
//------------------------------------------------------------------------------
bullConfirmAddon = enableConfirmationAddOn and bullConfirmAddonRaw and not bullConfirmAddonRaw[1]
bearConfirmAddon = enableConfirmationAddOn and bearConfirmAddonRaw and not bearConfirmAddonRaw[1]

finalOkAlert = not confirmOnlyOnClose or barstate.isconfirmed

plotBullConfirm = finalOkAlert and bullConfirmAddon
plotBearConfirm = finalOkAlert and bearConfirmAddon

plotshape(showConfirmShapes and plotBullConfirm ? low - atr * 0.22 : na,
     title="Support OB Confirmation",
     style=shape.triangleup,
     location=location.absolute,
     color=color.green,
     size=size.tiny)

plotshape(showConfirmShapes and plotBearConfirm ? high + atr * 0.22 : na,
     title="Resistance OB Confirmation",
     style=shape.triangledown,
     location=location.absolute,
     color=color.red,
     size=size.tiny)

//------------------------------------------------------------------------------
// Combined alert states
//------------------------------------------------------------------------------
bullReachedNoConfirm = bullTouchRaw and not bullConfirmAddonRaw
bearReachedNoConfirm = bearTouchRaw and not bearConfirmAddonRaw

bullReachedWithConfirm = bullTouchRaw and bullConfirmAddonRaw
bearReachedWithConfirm = bearTouchRaw and bearConfirmAddonRaw

bullConfirmOnlyRaw = bullConfirmAddonRaw
bearConfirmOnlyRaw = bearConfirmAddonRaw

anyBullEventRaw = bullTouchRaw or bullConfirmAddonRaw
anyBearEventRaw = bearTouchRaw or bearConfirmAddonRaw

bullReachedNoConfirmSig   = confirmAlertOnStateChange ? edge(bullReachedNoConfirm) : bullReachedNoConfirm
bearReachedNoConfirmSig   = confirmAlertOnStateChange ? edge(bearReachedNoConfirm) : bearReachedNoConfirm

bullReachedWithConfirmSig = confirmAlertOnStateChange ? edge(bullReachedWithConfirm) : bullReachedWithConfirm
bearReachedWithConfirmSig = confirmAlertOnStateChange ? edge(bearReachedWithConfirm) : bearReachedWithConfirm

bullConfirmOnlySig = confirmAlertOnStateChange ? edge(bullConfirmOnlyRaw) : bullConfirmOnlyRaw
bearConfirmOnlySig = confirmAlertOnStateChange ? edge(bearConfirmOnlyRaw) : bearConfirmOnlyRaw

anyBullEventSig = confirmAlertOnStateChange ? edge(anyBullEventRaw) : anyBullEventRaw
anyBearEventSig = confirmAlertOnStateChange ? edge(anyBearEventRaw) : anyBearEventRaw

aBullReachedNoConfirm   = finalOkAlert and bullReachedNoConfirmSig
aBearReachedNoConfirm   = finalOkAlert and bearReachedNoConfirmSig
aBullReachedWithConfirm = finalOkAlert and bullReachedWithConfirmSig
aBearReachedWithConfirm = finalOkAlert and bearReachedWithConfirmSig
aBullConfirmOnly        = finalOkAlert and bullConfirmOnlySig
aBearConfirmOnly        = finalOkAlert and bearConfirmOnlySig
aAnyBullEvent           = finalOkAlert and anyBullEventSig
aAnyBearEvent           = finalOkAlert and anyBearEventSig

//------------------------------------------------------------------------------
// Final alerts
//------------------------------------------------------------------------------
alertcondition(aBullReachedNoConfirm, title="IND003 - Support OB Reached | No Confirmation", message="IND003 - Price reached a support OB zone, but confirmation conditions are not active on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")
alertcondition(aBearReachedNoConfirm, title="IND003 - Resistance OB Reached | No Confirmation", message="IND003 - Price reached a resistance OB zone, but confirmation conditions are not active on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")

alertcondition(aBullReachedWithConfirm, title="IND003 - Support OB Reached | Confirmation Active", message="IND003 - Price reached a support OB zone and confirmation conditions are active on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")
alertcondition(aBearReachedWithConfirm, title="IND003 - Resistance OB Reached | Confirmation Active", message="IND003 - Price reached a resistance OB zone and confirmation conditions are active on {{ticker}} ({{interval}}). This is a chart condition, not a trade instruction.")

alertcondition(aBullConfirmOnly, title="IND003 - Support OB Confirmation Active", message="IND003 - Support OB confirmation conditions are active near a support OB zone on {{ticker}} ({{interval}}). Review chart context and risk.")
alertcondition(aBearConfirmOnly, title="IND003 - Resistance OB Confirmation Active", message="IND003 - Resistance OB confirmation conditions are active near a resistance OB zone on {{ticker}} ({{interval}}). Review chart context and risk.")

alertcondition(aAnyBullEvent, title="IND003 - Any Support OB Event", message="IND003 - Support OB event detected on {{ticker}} ({{interval}}): zone reached or confirmation active.")
alertcondition(aAnyBearEvent, title="IND003 - Any Resistance OB Event", message="IND003 - Resistance OB event detected on {{ticker}} ({{interval}}): zone reached or confirmation active.")
````
