<!-- tradingview-pine-id: PUB;fb23cbf3c12f4aa499ce161cc3a0268c -->
<!-- tradingviewscripts-format: 1 -->
# Pre-Market / Opening Spike Probability Model

Source: https://www.tradingview.com/script/hb0zpbTQ-Pre-Market-Opening-Spike-Probability-Model/

## Description

i use it for AXTI for AMD trading. pretty good to do a case study for bull.bear trends

---

## Source Code

````pine
//@version=6
indicator(
     "Pre-Market / Opening Spike Probability Model",
     shorttitle = "PM Spike Stats",
     overlay = true,
     max_boxes_count = 500,
     max_labels_count = 300
)

//══════════════════════════════════════════════════════════════════════
// Settings
//══════════════════════════════════════════════════════════════════════

string TZ          = "America/New_York"
string PM_SESSION  = "0400-0930:23456"
string OR_SESSION  = "0930-0940:23456"
string RTH_SESSION = "0930-1600:23456"

float minimumPMMove = input.float(
     0.25,
     "Minimum pre-market move (%)",
     minval = 0.0,
     step = 0.05
)

float minimumSpike = input.float(
     0.10,
     "Minimum opening spike (%)",
     minval = 0.0,
     step = 0.05
)

int fastLength = input.int(
     20,
     "Daily fast EMA",
     minval = 1
)

int slowLength = input.int(
     50,
     "Daily slow EMA",
     minval = 2
)

bool requireEMAStack = input.bool(
     true,
     "Require price above/below both EMAs"
)

bool showPremarketBox = input.bool(
     true,
     "Show pre-market boxes"
)

bool showOpeningBox = input.bool(
     true,
     "Show opening-range boxes"
)

bool showDayBox = input.bool(
     true,
     "Show post-9:40 outcome boxes"
)

bool showLabels = input.bool(
     true,
     "Show setup labels"
)

bool showTable = input.bool(
     true,
     "Show statistics table"
)

bool showEMAs = input.bool(
     true,
     "Show daily trend EMAs"
)

int minimumSampleSize = input.int(
     20,
     "Minimum sample for confidence",
     minval = 1
)

string tablePositionInput = input.string(
     "Top right",
     "Table position",
     options = [
         "Top right",
         "Top left",
         "Bottom right",
         "Bottom left"
     ]
)

tablePosition =
     tablePositionInput == "Top left"
         ? position.top_left
         : tablePositionInput == "Bottom right"
         ? position.bottom_right
         : tablePositionInput == "Bottom left"
         ? position.bottom_left
         : position.top_right

// An exact 9:30–9:40 measurement requires 1-, 2-, or 5-minute bars.


//══════════════════════════════════════════════════════════════════════
// Helper functions
//══════════════════════════════════════════════════════════════════════

f_probability(int successes, int samples) =>
    samples > 0
         ? str.tostring(
             100.0 * successes / samples,
             "#.0"
         ) + "%"
         : "N/A"

f_directionText(int direction) =>
    direction == 1
         ? "UP"
         : direction == -1
         ? "DOWN"
         : "FLAT"

f_trendText(int trend) =>
    trend == 1
         ? "UPTREND"
         : trend == -1
         ? "DOWNTREND"
         : "NEUTRAL"

f_spikeText(int spike) =>
    spike == 1
         ? "SPIKE UP"
         : spike == -1
         ? "SPIKE DOWN"
         : "NO SPIKE"

f_confidenceText(int samples, int requiredSamples) =>
    samples >= requiredSamples
         ? "VALID SAMPLE"
         : samples > 0
         ? "LOW SAMPLE"
         : "NO DATA"

f_probabilityColor(float probability, int samples, int requiredSamples) =>
    samples < requiredSamples
         ? color.orange
         : na(probability)
         ? color.gray
         : probability >= 65
         ? color.lime
         : probability >= 55
         ? color.yellow
         : color.red

// Statistical buckets:
//
// 0 = opening spike up   / daily uptrend
// 1 = opening spike up   / daily downtrend
// 2 = opening spike up   / neutral trend
// 3 = opening spike down / daily uptrend
// 4 = opening spike down / daily downtrend
// 5 = opening spike down / neutral trend

f_bucket(int spike, int trend) =>
    int trendPart =
         trend == 1
             ? 0
             : trend == -1
             ? 1
             : 2

    int spikePart = spike == 1 ? 0 : 3

    spikePart + trendPart

//══════════════════════════════════════════════════════════════════════
// Confirmed daily trend
//══════════════════════════════════════════════════════════════════════

// All three values use the previous completed daily candle.
// This prevents today's future price action from changing today's setup.

float priorDailyClose = request.security(
     syminfo.tickerid,
     "D",
     close[1],
     lookahead = barmerge.lookahead_on
)

float priorFastEMA = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, fastLength)[1],
     lookahead = barmerge.lookahead_on
)

float priorSlowEMA = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, slowLength)[1],
     lookahead = barmerge.lookahead_on
)

int calculatedTrend =
     priorFastEMA > priorSlowEMA and
     (
         not requireEMAStack or
         priorDailyClose > priorFastEMA
     )
         ? 1
         : priorFastEMA < priorSlowEMA and
           (
               not requireEMAStack or
               priorDailyClose < priorFastEMA
           )
         ? -1
         : 0

plot(
     showEMAs ? priorFastEMA : na,
     "Prior daily fast EMA",
     color = color.new(color.aqua, 15),
     linewidth = 1
)

plot(
     showEMAs ? priorSlowEMA : na,
     "Prior daily slow EMA",
     color = color.new(color.fuchsia, 15),
     linewidth = 1
)

//══════════════════════════════════════════════════════════════════════
// Session detection
//══════════════════════════════════════════════════════════════════════

bool inPM = not na(
     time(timeframe.period, PM_SESSION, TZ)
)

bool inOR = not na(
     time(timeframe.period, OR_SESSION, TZ)
)

bool inRTH = not na(
     time(timeframe.period, RTH_SESSION, TZ)
)

bool pmStarted =
     inPM and not inPM[1]

bool orStarted =
     inOR and not inOR[1]

bool orEnded =
     not inOR and inOR[1]

bool rthEnded =
     not inRTH and inRTH[1]

//══════════════════════════════════════════════════════════════════════
// Current-day values
//══════════════════════════════════════════════════════════════════════

var float pmOpen  = na
var float pmHigh  = na
var float pmLow   = na
var float pmClose = na

var float orOpen  = na
var float orHigh  = na
var float orLow   = na
var float orClose = na

var float dayHigh  = na
var float dayLow   = na
var float dayClose = na

var float currentPMMove    = na
var float currentSpikeMove = na

var int currentPMDirection = 0
var int currentSpike       = 0
var int currentTrend       = 0

var bool currentTrendFade = false
var bool currentFullSetup = false

var box pmBox  = na
var box orBox  = na
var box dayBox = na

//══════════════════════════════════════════════════════════════════════
// Historical statistics
//══════════════════════════════════════════════════════════════════════

var int totalSpikeDays    = 0
var int followThroughDays = 0
var int reversalDays      = 0
var int unresolvedDays    = 0

var int trendFadeSetups = 0
var int trendFadeWins   = 0

var int fullSetups = 0
var int fullWins   = 0

var array<int> bucketSamples = array.new_int(6, 0)
var array<int> bucketFollow  = array.new_int(6, 0)
var array<int> bucketReverse = array.new_int(6, 0)

//══════════════════════════════════════════════════════════════════════
// Pre-market measurement
//══════════════════════════════════════════════════════════════════════

if pmStarted
    pmOpen  := open
    pmHigh  := high
    pmLow   := low
    pmClose := close

    orOpen  := na
    orHigh  := na
    orLow   := na
    orClose := na

    dayHigh  := na
    dayLow   := na
    dayClose := na

    currentPMMove      := na
    currentSpikeMove   := na
    currentPMDirection := 0
    currentSpike       := 0
    currentTrend       := calculatedTrend
    currentTrendFade   := false
    currentFullSetup   := false

    if showPremarketBox
        pmBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             border_color = color.new(color.blue, 15),
             border_width = 1,
             bgcolor = color.new(color.blue, 88),
             text = "PRE-MARKET",
             text_color = color.new(color.white, 20),
             text_size = size.tiny
        )

if inPM
    pmHigh  := math.max(nz(pmHigh, high), high)
    pmLow   := math.min(nz(pmLow, low), low)
    pmClose := close

    if showPremarketBox and not na(pmBox)
        box.set_right(pmBox, bar_index)
        box.set_top(pmBox, pmHigh)
        box.set_bottom(pmBox, pmLow)

//══════════════════════════════════════════════════════════════════════
// Opening-range measurement
//══════════════════════════════════════════════════════════════════════

if orStarted
    orOpen  := open
    orHigh  := high
    orLow   := low
    orClose := close

    if showOpeningBox
        orBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             border_color = color.orange,
             border_width = 2,
             bgcolor = color.new(color.orange, 82),
             text = "OPENING 10M",
             text_color = color.white,
             text_size = size.tiny
        )

if inOR
    orHigh  := math.max(nz(orHigh, high), high)
    orLow   := math.min(nz(orLow, low), low)
    orClose := close

    if showOpeningBox and not na(orBox)
        box.set_right(orBox, bar_index)
        box.set_top(orBox, orHigh)
        box.set_bottom(orBox, orLow)

//══════════════════════════════════════════════════════════════════════
// Classify today's setup at 9:40 a.m.
//══════════════════════════════════════════════════════════════════════

if orEnded
    currentPMMove :=
         not na(pmOpen) and pmOpen != 0
             ? 100.0 * (pmClose - pmOpen) / pmOpen
             : na

    currentSpikeMove :=
         not na(orOpen) and orOpen != 0
             ? 100.0 * (orClose - orOpen) / orOpen
             : na

    currentPMDirection :=
         currentPMMove >= minimumPMMove
             ? 1
             : currentPMMove <= -minimumPMMove
             ? -1
             : 0

    currentSpike :=
         currentSpikeMove >= minimumSpike
             ? 1
             : currentSpikeMove <= -minimumSpike
             ? -1
             : 0

    // Trend-fade setup:
    // Uptrend + opening spike down = buy reversal.
    // Downtrend + opening spike up = short reversal.

    currentTrendFade :=
         (
             currentTrend == 1 and
             currentSpike == -1
         ) or
         (
             currentTrend == -1 and
             currentSpike == 1
         )

    // Full alignment:
    // Pre-market agrees with the larger daily trend,
    // while the opening spike moves against both.

    currentFullSetup :=
         currentTrendFade and
         currentPMDirection == currentTrend

    dayHigh  := high
    dayLow   := low
    dayClose := close

    if showOpeningBox and not na(orBox)
        color spikeColor =
             currentSpike == 1
                 ? color.green
                 : currentSpike == -1
                 ? color.red
                 : color.orange

        box.set_border_color(orBox, spikeColor)
        box.set_bgcolor(
             orBox,
             color.new(spikeColor, 82)
        )

    if showDayBox
        dayBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             border_color = color.new(color.gray, 45),
             border_width = 1,
             bgcolor = color.new(color.gray, 92),
             text = "PENDING",
             text_color = color.gray,
             text_size = size.tiny
        )

    if showLabels
        string setupText =
             currentFullSetup
                 ? "FULL ALIGNMENT\nFade opening spike"
                 : currentTrendFade
                 ? "TREND FADE\nOpening spike opposes trend"
                 : currentSpike == currentTrend and currentTrend != 0
                 ? "TREND CONTINUATION"
                 : "NO CLEAR SETUP"

        color setupColor =
             currentFullSetup
                 ? color.purple
                 : currentTrendFade
                 ? color.teal
                 : currentSpike == currentTrend and currentTrend != 0
                 ? color.green
                 : color.gray

        label.new(
             bar_index,
             currentSpike == 1 ? orHigh : orLow,
             setupText +
             "\nTrend: " + f_trendText(currentTrend) +
             "\nPM: " + f_directionText(currentPMDirection) +
             "\nOpen: " + f_spikeText(currentSpike),
             style = currentSpike == 1
                 ? label.style_label_down
                 : label.style_label_up,
             color = setupColor,
             textcolor = color.white
        )

//══════════════════════════════════════════════════════════════════════
// Update the post-opening box
//══════════════════════════════════════════════════════════════════════

if inRTH and not inOR and not na(dayHigh)
    dayHigh  := math.max(dayHigh, high)
    dayLow   := math.min(dayLow, low)
    dayClose := close

    if showDayBox and not na(dayBox)
        box.set_right(dayBox, bar_index)
        box.set_top(dayBox, dayHigh)
        box.set_bottom(dayBox, dayLow)

//══════════════════════════════════════════════════════════════════════
// Score completed regular sessions
//══════════════════════════════════════════════════════════════════════

if rthEnded and currentSpike != 0 and not na(dayClose)
    // Follow-through:
    // The closing price finishes beyond the opening range
    // in the original opening-spike direction.

    bool followedThrough =
         currentSpike == 1
             ? dayClose > orHigh
             : dayClose < orLow

    // Reversal:
    // The closing price crosses back beyond the 9:30 open
    // against the opening-spike direction.

    bool reversed =
         currentSpike == 1
             ? dayClose < orOpen
             : dayClose > orOpen

    totalSpikeDays += 1

    if followedThrough
        followThroughDays += 1
    else if reversed
        reversalDays += 1
    else
        unresolvedDays += 1

    int completedBucket =
         f_bucket(currentSpike, currentTrend)

    array.set(
         bucketSamples,
         completedBucket,
         array.get(
             bucketSamples,
             completedBucket
         ) + 1
    )

    if followedThrough
        array.set(
             bucketFollow,
             completedBucket,
             array.get(
                 bucketFollow,
                 completedBucket
             ) + 1
        )

    if reversed
        array.set(
             bucketReverse,
             completedBucket,
             array.get(
                 bucketReverse,
                 completedBucket
             ) + 1
        )

    if currentTrendFade
        trendFadeSetups += 1

        if reversed
            trendFadeWins += 1

    if currentFullSetup
        fullSetups += 1

        if reversed
            fullWins += 1

    if showDayBox and not na(dayBox)
        color outcomeColor =
             followedThrough
                 ? color.green
                 : reversed
                 ? color.purple
                 : color.gray

        string outcomeText =
             followedThrough
                 ? "FOLLOW-THROUGH"
                 : reversed
                 ? "REVERSAL"
                 : "UNRESOLVED"

        box.set_border_color(
             dayBox,
             outcomeColor
        )

        box.set_bgcolor(
             dayBox,
             color.new(outcomeColor, 87)
        )

        box.set_text(
             dayBox,
             outcomeText
        )

        box.set_text_color(
             dayBox,
             color.white
        )

//══════════════════════════════════════════════════════════════════════
// Current conditional statistics
//══════════════════════════════════════════════════════════════════════

bool validCurrentBucket =
     currentSpike != 0

int currentBucket =
     validCurrentBucket
         ? f_bucket(currentSpike, currentTrend)
         : 0

int currentBucketSamples =
     validCurrentBucket
         ? array.get(
             bucketSamples,
             currentBucket
         )
         : 0

int currentBucketFollow =
     validCurrentBucket
         ? array.get(
             bucketFollow,
             currentBucket
         )
         : 0

int currentBucketReverse =
     validCurrentBucket
         ? array.get(
             bucketReverse,
             currentBucket
         )
         : 0

//══════════════════════════════════════════════════════════════════════
// Current trade-success probability
//══════════════════════════════════════════════════════════════════════

int successWins    = 0
int successSamples = 0

string suggestedTrade = "NO SETUP"
string successType    = "N/A"

if currentFullSetup
    // Strongest version of the original pattern:
    // daily trend and pre-market agree, opening move opposes both.

    successWins    := fullWins
    successSamples := fullSetups

    suggestedTrade :=
         currentTrend == 1
             ? "BUY REVERSAL"
             : "SHORT REVERSAL"

    successType := "Full alignment"

else if currentTrendFade
    // Opening spike opposes the confirmed daily trend.

    successWins    := currentBucketReverse
    successSamples := currentBucketSamples

    suggestedTrade :=
         currentTrend == 1
             ? "BUY REVERSAL"
             : "SHORT REVERSAL"

    successType := "Trend fade"

else if currentSpike != 0 and currentTrend != 0
    // Opening spike agrees with the confirmed daily trend.

    successWins    := currentBucketFollow
    successSamples := currentBucketSamples

    suggestedTrade :=
         currentSpike == 1
             ? "LONG FOLLOW-THROUGH"
             : "SHORT FOLLOW-THROUGH"

    successType := "Trend continuation"

else if currentSpike != 0
    // There is an opening spike but no confirmed daily trend.

    successWins    := currentBucketFollow
    successSamples := currentBucketSamples
    suggestedTrade := "LOW-CONFIDENCE FOLLOW"
    successType    := "Neutral trend"

float successProbability =
     successSamples > 0
         ? 100.0 * successWins / successSamples
         : na

color successProbabilityColor =
     f_probabilityColor(
         successProbability,
         successSamples,
         minimumSampleSize
     )

string confidenceText =
     f_confidenceText(
         successSamples,
         minimumSampleSize
     )

//══════════════════════════════════════════════════════════════════════
// Statistics table
//══════════════════════════════════════════════════════════════════════

var table stats = table.new(
     tablePosition,
     3,
     14,
     bgcolor = color.new(color.black, 8),
     border_color = color.new(color.gray, 55),
     border_width = 1
)

if barstate.islast
    if showTable
        color headerColor = color.rgb(28, 33, 43)
        color labelColor  = color.rgb(39, 45, 56)
        color valueColor  = color.rgb(22, 26, 34)
        color tradeColor  = color.rgb(52, 43, 76)

        table.cell(
             stats, 0, 0,
             "PM / OPEN MODEL",
             bgcolor = headerColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 0,
             "VALUE",
             bgcolor = headerColor,
             text_color = color.white
        )

        table.cell(
             stats, 2, 0,
             "SAMPLE",
             bgcolor = headerColor,
             text_color = color.white
        )

        table.cell(
             stats, 0, 1,
             "Daily trend",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 1,
             f_trendText(currentTrend),
             bgcolor = valueColor,
             text_color =
                 currentTrend == 1
                     ? color.lime
                     : currentTrend == -1
                     ? color.red
                     : color.silver
        )

        table.cell(
             stats, 2, 1,
             "Prior day",
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 2,
             "Pre-market",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 2,
             f_directionText(currentPMDirection),
             bgcolor = valueColor,
             text_color = color.white
        )

        table.cell(
             stats, 2, 2,
             na(currentPMMove)
                 ? "N/A"
                 : str.tostring(
                     currentPMMove,
                     "#.##"
                 ) + "%",
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 3,
             "Opening move",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 3,
             f_spikeText(currentSpike),
             bgcolor = valueColor,
             text_color =
                 currentSpike == 1
                     ? color.lime
                     : currentSpike == -1
                     ? color.red
                     : color.silver
        )

        table.cell(
             stats, 2, 3,
             na(currentSpikeMove)
                 ? "N/A"
                 : str.tostring(
                     currentSpikeMove,
                     "#.##"
                 ) + "%",
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 4,
             "Current setup",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 4,
             currentFullSetup
                 ? "FULL ALIGNMENT"
                 : currentTrendFade
                 ? "TREND FADE"
                 : currentSpike == currentTrend and
                   currentTrend != 0
                 ? "CONTINUATION"
                 : "NO CLEAR SETUP",
             bgcolor =
                 currentFullSetup
                     ? color.new(color.purple, 15)
                     : currentTrendFade
                     ? color.new(color.teal, 15)
                     : valueColor,
             text_color = color.white
        )

        table.cell(
             stats, 2, 4,
             suggestedTrade,
             bgcolor = valueColor,
             text_color = color.white
        )

        table.cell(
             stats, 0, 5,
             "All spike follow-through",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 5,
             f_probability(
                 followThroughDays,
                 totalSpikeDays
             ),
             bgcolor = valueColor,
             text_color = color.lime
        )

        table.cell(
             stats, 2, 5,
             str.tostring(totalSpikeDays),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 6,
             "All spike reversal",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 6,
             f_probability(
                 reversalDays,
                 totalSpikeDays
             ),
             bgcolor = valueColor,
             text_color = color.aqua
        )

        table.cell(
             stats, 2, 6,
             str.tostring(totalSpikeDays),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 7,
             "Unresolved by close",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 7,
             f_probability(
                 unresolvedDays,
                 totalSpikeDays
             ),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 2, 7,
             str.tostring(totalSpikeDays),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 8,
             "Trend-fade success",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 8,
             f_probability(
                 trendFadeWins,
                 trendFadeSetups
             ),
             bgcolor = valueColor,
             text_color = color.aqua
        )

        table.cell(
             stats, 2, 8,
             str.tostring(trendFadeSetups),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 9,
             "Full-alignment success",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 9,
             f_probability(
                 fullWins,
                 fullSetups
             ),
             bgcolor = valueColor,
             text_color = color.fuchsia
        )

        table.cell(
             stats, 2, 9,
             str.tostring(fullSetups),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 10,
             "Current-bucket follow",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 10,
             validCurrentBucket
                 ? f_probability(
                     currentBucketFollow,
                     currentBucketSamples
                 )
                 : "N/A",
             bgcolor = valueColor,
             text_color = color.lime
        )

        table.cell(
             stats, 2, 10,
             str.tostring(currentBucketSamples),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 11,
             "Current-bucket reversal",
             bgcolor = labelColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 11,
             validCurrentBucket
                 ? f_probability(
                     currentBucketReverse,
                     currentBucketSamples
                 )
                 : "N/A",
             bgcolor = valueColor,
             text_color = color.aqua
        )

        table.cell(
             stats, 2, 11,
             str.tostring(currentBucketSamples),
             bgcolor = valueColor,
             text_color = color.silver
        )

        table.cell(
             stats, 0, 12,
             "TRADE SUCCESS PROB.",
             bgcolor = tradeColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 12,
             f_probability(
                 successWins,
                 successSamples
             ),
             bgcolor = color.rgb(30, 30, 38),
             text_color = successProbabilityColor,
             text_size = size.large
        )

        table.cell(
             stats, 2, 12,
             "N=" + str.tostring(successSamples),
             bgcolor = color.rgb(30, 30, 38),
             text_color = color.white
        )

        table.cell(
             stats, 0, 13,
             "Trade / confidence",
             bgcolor = tradeColor,
             text_color = color.white
        )

        table.cell(
             stats, 1, 13,
             suggestedTrade,
             bgcolor = color.rgb(30, 30, 38),
             text_color = color.white
        )

        table.cell(
             stats, 2, 13,
             confidenceText + "\n" + successType,
             bgcolor = color.rgb(30, 30, 38),
             text_color =
                 successSamples >= minimumSampleSize
                     ? color.lime
                     : color.orange
        )

else
    table.clear(stats, 0, 0, 2, 13)

//══════════════════════════════════════════════════════════════════════
// Alerts
//══════════════════════════════════════════════════════════════════════

bool newTrendFade =
     orEnded and currentTrendFade

bool newFullSetup =
     orEnded and currentFullSetup

bool newContinuation =
     orEnded and
     currentSpike != 0 and
     currentSpike == currentTrend

alertcondition(
     newTrendFade,
     "Opening spike opposes daily trend",
     "The 9:30–9:40 opening spike opposes the confirmed daily EMA trend."
)

alertcondition(
     newFullSetup,
     "Full pre-market alignment",
     "Pre-market agrees with the daily trend and the opening spike opposes both."
)

alertcondition(
     newContinuation,
     "Opening spike agrees with daily trend",
     "The 9:30–9:40 opening spike agrees with the confirmed daily EMA trend."
)
````
