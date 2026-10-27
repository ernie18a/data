# Anchored RWAP

- url: https://www.tradingview.com/script/Ml6ve5jH-Anchored-RWAP/
- type: indicator
- pine_id: PUB;c0b2c00ca8374c2799f64d90f59bab2d
- version: 1.0

## Description

An anchored average promises to remember where an auction began. A recency-weighted average quietly breaks that promise, because it forgets its oldest bars geometrically, and the forgetting runs at a different speed on every chart clock. An anchor that still governs a daily line can be long forgotten on the hourly chart of the same symbol, while both lines continue to wear the word "anchored." Anchored RWAP keeps the anchor, keeps the forgetting, and prints exactly how much of the anchor each clock still remembers.

The indicator is a supplementary instrument. It does not issue entries or exits; it describes where recent prices have settled since a chosen event, whether that equilibrium is migrating, and whether the event still shapes the line. A trader can use those readings to test an existing setup, to manage an open position, or to match an option's horizon to the market's own memory. The sections below explain the calculation, read the chart above, and show how to fold the readings into analysis already in hand.

[b]The Calculation Forgets on Purpose
[/b]
Anchored RWAP takes a finite geometric average of a chosen price source, beginning at a defined anchor. The current bar receives a weight of one, and each earlier bar receives the prior weight multiplied by a decay factor called gamma. No bar before the anchor contributes, so the line belongs to one auction rather than to the whole chart.

The anchor can be set four ways. Manual mode begins on the first bar at or after a chosen timestamp, which suits swings, breakouts, failed auctions and scheduled releases. Session, Week and Month modes reset at their calendar boundaries for traders who study recurring auctions. An optional cap limits the calculation to a maximum number of bars, and an optional sigma row measures price's distance from the line in the line's own recency-weighted dispersion.

The difference from familiar averages lies in origin and decay together. VWAP weights by volume and never forgets a heavy print while its anchor stands. An EMA forgets smoothly but has no origin, and an SMA has a window but drops each bar from full weight to zero in one step. Anchored RWAP joins a visible origin to a smooth fade, so a reader can see both where the auction started and how far its memory has drifted from that start.

[b]One Memory Across Three Clocks
[/b]
The indicator was built for the 15-minute, hourly and daily charts, and its default memory mode makes those three clocks agree. Clock span mode sets memory in trading days rather than in bars. The default of 34 trading days places roughly 95 percent of the weight on the latest 34 sessions, whatever the chart's timeframe. Gamma is then derived for each clock, so one anchor means the same thing on all three.

An intraday chart measures its own trading day as the median bar count of its 21 most recent completed days. The median behaves like a jury that ignores its loudest member, so half-days, merged holiday sessions and sparse extended-hours days cannot distort it. Regular-hours equities measure seven hourly bars, extended hours measure whatever actually prints, and 24-hour markets measure twenty-four. The chart's session setting therefore changes the bar count without changing the memory in days, and the line lands in nearly the same place either way.

A row called Anchor reach divides the bars since the anchor by the full memory. A ratio at or below 1.0 reads Active, up to 2.0 reads Fading, and beyond that reads Forgotten, meaning the line has become a rolling average that no longer depends on its anchor. Under Clock span, one anchor prints the same reach on every clock, which makes the row a calibration check as well as a reading. Fixed gamma mode remains available for traders who want a fast intraday line and accept that the anchor will matter less on faster clocks.

[b]Reading the Chart
[/b]
The chart above shows Affirm (AFRM) on the hourly clock with regular hours, captured after the close of 9 October. The manual anchor sits at the 28 August session that printed the 90.40 high. The line's path tells that story in three hues. It falls in red as price unwinds the spike toward the 66.03 low of 10 September, flattens through late September while price rotates on both sides of a line near 72, and turns green in early October as price pulls away from the line.

The table carries the numbers. Gamma reads 0.9875, the anchor stands 210 bars back, and the reach reads Active at 0.9×, which matches the daily chart's reach for the same anchor. The RWAP stands at 72.76 with price at 80.68, so price sits 8.70 ATR and 10.87 percent above the line. The posture reads Acceptance · rising, the normalized slope reads +0.5755 with 58 percent force, and the daily ladder row reads Bullish at +0.4429.

Hue carries direction, and brightness carries force. The slope is the change in the line across five bars divided by a 13-bar ATR, and a threshold with hysteresis keeps minor wobbles from flipping the hue. Brightness rises with the slope's magnitude, so a dimming bullish line still rises, only more slowly. Hue is the weathervane and brightness the anemometer, and neither one claims to know where the storm will land.

The posture row joins location to state. Price above a rising line reads as acceptance, price beneath a rising line reads as a pullback, and the mirror readings apply to a falling line. Price within a narrow band around the line reads as equilibrium. Every value also appears in the Data Window, including the measured bars per trading day, so a reader can quote numbers that a screenshot might clip.

[b]Where Anchored RWAP Fits in a Trading Process
[/b]
The primary use is analysis that a trader already performs. A setup drawn from structure, volume or momentum can be checked against the line: a long entry in Acceptance · rising has equilibrium behind it, while the same entry in Relief · falling is a trade against a line that has not changed its mind. A pullback into a rising line with the ladder in agreement describes a with-trend context, and a breakout that leaves a neutral line far behind describes price outrunning acceptance. The line supplies context for a decision, and the decision belongs to the trader's own method.

The second use is trade management. An open position can be monitored by watching posture and force rather than price alone, since a dimming line warns of deceleration before a reversal becomes visible in the candles. A re-anchor at a new structural event isolates the auction in which a trade actually lives. The ladder rows on the 15-minute and hourly charts report the slower clocks from their last closed bars, so those values never repaint while a position is open.

The third use belongs to options traders, who face a calendar question every time they choose an expiration. A daily line with a 34-day memory weights roughly the same stretch of trading that a 45-day option must endure. A same-day option belongs to a single session, and a session-anchored 15-minute line describes that session's own equilibrium. The memory span becomes a setting that can be matched to the exposure.

The indicator reads price alone. It does not measure volume, order flow, open interest, implied volatility or dealer positioning, and its gamma is a decay coefficient with no connection to options gamma. Charts below 15 minutes turn acceptance into noise, so a design-clock guard hides the line on other timeframes and says why in the table. A chart whose history begins on the anchor's own day uses a provisional gamma until it has measured one full trading day, and the table marks that state openly. Nothing in this description or in the script is financial advice, and past behavior of the line does not predict future prices.

[b]Memory Is the Trade's Horizon[/b]

Every average on a chart carries a memory, and that memory is usually an accident of the timeframe the trader happened to open. A hundred bars means a season on one clock and an afternoon on another, and the line never says which. Anchored RWAP converts that accident into a declared number of trading days and prints it beside every reading.

The consequence reaches past the indicator. An option is a lease on the future, and the memory span is the tenant history checked before signing. A one-session lease judged on a 34-day history mistakes the tenant for the neighborhood, and a 45-day lease judged on a 36-minute history mistakes a single visit for a reputation. The effective-memory row states, in bars and trading days, which history the line is reading. A trade and the evidence behind it each run on a calendar. The table has always printed one of them, and the trader has always chosen the other.

## Source Code

````pine
//@version=6
indicator(
     "Anchored RWAP",
     shorttitle = "AnchRWAP",
     overlay = true,
     max_bars_back = 5000
)

// The state constants keep the state machine legible.
const int STATE_BEARISH = -1
const int STATE_NEUTRAL = 0
const int STATE_BULLISH = 1

// The number of recent completed trading days whose median bar count
// measures an intraday chart's trading-day length.
const int DAY_SAMPLE = 21

// The group names organize the Settings panel.
const string GROUP_ANCHOR = "Anchor"
const string GROUP_WEIGHTING = "Recency Weighting"
const string GROUP_STATE = "Slope State"
const string GROUP_LOCATION = "Location and Sigma"
const string GROUP_LADDER = "Clock Ladder"
const string GROUP_VISUALS = "Visuals"
const string GROUP_INFORMATION = "Information Table"
const string GROUP_ALERTS = "Alerts"

// This function converts the internal state integer into readable text.
stateName(int state) =>
    state == STATE_BULLISH ? "Bullish" :
     state == STATE_BEARISH ? "Bearish" :
     "Neutral"

// This function estimates the number of latest bars containing roughly
// 95 percent of the geometric weight. The estimate is descriptive rather
// than a statistical effective-sample-size calculation.
effectiveMemoryBars(float gammaValue, int availableBars) =>
    int result = 0

    if availableBars > 0
        if gammaValue >= 0.999999
            result := availableBars
        else
            float rawSpan = math.log(0.05) / math.log(gammaValue)
            int estimatedSpan = int(math.ceil(rawSpan))
            result := math.min(estimatedSpan, availableBars)

    result

// This function prints a signed number with an explicit plus sign.
signedText(float value, string fmt) =>
    na(value) ? "n/a" : (value > 0 ? "+" : "") + str.tostring(value, fmt)

// ─────────────────────────────────────────────────────────────────────────────
// Anchor inputs
// ─────────────────────────────────────────────────────────────────────────────

string anchorModeInput = input.string(
     "Manual",
     "Anchor mode",
     options = ["Manual", "Session", "Week", "Month"],
     group = GROUP_ANCHOR,
     tooltip = "Manual begins on the first bar whose opening time reaches the selected timestamp. Session resets at the selected session boundary. Week and Month reset at their respective exchange-calendar boundaries."
)

int manualAnchorTimeInput = input.time(
     0,
     "Manual anchor timestamp",
     confirm = true,
     group = GROUP_ANCHOR,
     tooltip = "TradingView will request an anchor bar when the indicator is first added. This input affects the Manual anchor mode only."
)

string sessionHoursInput = input.session(
     "1700-1600",
     "Session hours",
     group = GROUP_ANCHOR,
     tooltip = "The default reflects a common CME-style session in the symbol exchange timezone. Adjust this value for the contract and auction being studied. Session mode is not meaningful on daily charts, where it would reset on every bar."
)

string sessionDaysInput = input.string(
     "1234567",
     "Session days",
     group = GROUP_ANCHOR,
     tooltip = "Use 1 for Sunday through 7 for Saturday. The default permits every day for which chart data exists."
)

// ─────────────────────────────────────────────────────────────────────────────
// Weighting inputs
// ─────────────────────────────────────────────────────────────────────────────

float sourceInput = input.source(
     hlc3,
     "Price source",
     group = GROUP_WEIGHTING
)

string memoryModeInput = input.string(
     "Clock span",
     "Memory mode",
     options = ["Clock span", "Fixed gamma"],
     group = GROUP_WEIGHTING,
     tooltip = "Clock span sets memory in trading days and derives gamma for each chart clock, so one anchor means the same thing on the 15m, 1h and 1D charts. Fixed gamma applies one gamma to every clock, so memory is counted in bars and shortens in calendar time on faster charts."
)

float memorySpanDaysInput = input.float(
     34.0,
     "Memory span (trading days)",
     minval = 0.5,
     maxval = 500.0,
     step = 0.5,
     group = GROUP_WEIGHTING,
     tooltip = "Clock span mode only. The latest this-many trading days hold roughly 95 percent of the weight. Intraday charts measure their own trading-day length as the median bar count of their 21 most recent completed days, so extended hours and 24-hour markets are handled automatically. Keep the chart's session setting the same on every clock you compare; for equities, Regular hours match the daily bar."
)

float gammaFactorInput = input.float(
     0.92,
     "Gamma weight factor",
     minval = 0.01,
     maxval = 1.00,
     step = 0.01,
     group = GROUP_WEIGHTING,
     tooltip = "Fixed gamma mode only. Lower values emphasize the latest bars more strongly. Values nearer 1 retain more influence from older post-anchor bars. This gamma factor has no connection to options gamma."
)

bool useWindowCapInput = input.bool(
     false,
     "Limit calculation to maximum bars",
     group = GROUP_WEIGHTING,
     tooltip = "When enabled, the calculation retains only the latest maximum-bars quantity after the anchor. When disabled, every post-anchor bar remains in the finite geometric weighting."
)

int maxWindowBarsInput = input.int(
     2000,
     "Maximum bars",
     minval = 10,
     maxval = 4999,
     step = 10,
     group = GROUP_WEIGHTING,
     tooltip = "This setting applies only when the calculation cap is enabled. The ceiling sits one bar inside the script's 5000-bar history buffer."
)

// ─────────────────────────────────────────────────────────────────────────────
// State inputs
// ─────────────────────────────────────────────────────────────────────────────

int slopeLookbackInput = input.int(
     5,
     "Slope lookback",
     minval = 1,
     maxval = 100,
     group = GROUP_STATE,
     tooltip = "The normalized slope compares the current RWAP with its value this many bars earlier."
)

int atrLengthInput = input.int(
     13,
     "ATR normalization length",
     minval = 1,
     maxval = 500,
     group = GROUP_STATE
)

float directionalThresholdInput = input.float(
     0.05,
     "Directional threshold",
     minval = 0.001,
     maxval = 10.0,
     step = 0.005,
     group = GROUP_STATE,
     tooltip = "The RWAP enters a bullish or bearish state when its ATR-normalized slope reaches this magnitude."
)

float hysteresisWidthInput = input.float(
     0.03,
     "Hysteresis width",
     minval = 0.0,
     maxval = 10.0,
     step = 0.005,
     group = GROUP_STATE,
     tooltip = "Hysteresis allows the current directional state to persist through minor slope contraction. Larger values reduce color chatter."
)

float fullBrightnessSlopeInput = input.float(
     1.0,
     "Full brightness at normalized slope",
     minval = 0.001,
     maxval = 20.0,
     step = 0.01,
     group = GROUP_STATE,
     tooltip = "Normalized slope magnitudes at or beyond this value receive the user-defined brightness ceiling."
)

bool confirmStateAtCloseInput = input.bool(
     true,
     "Confirm hue changes at bar close",
     group = GROUP_STATE,
     tooltip = "When enabled, bullish, neutral, and bearish hue changes wait for bar confirmation. The RWAP value and brightness can still update intrabar."
)

// ─────────────────────────────────────────────────────────────────────────────
// Location and sigma inputs
// ─────────────────────────────────────────────────────────────────────────────

float atLineBandInput = input.float(
     0.05,
     "At-the-line band (ATR)",
     minval = 0.0,
     maxval = 2.0,
     step = 0.01,
     group = GROUP_LOCATION,
     tooltip = "Price within this many ATRs of the RWAP reads as sitting at equilibrium, in the neutral color, rather than above or below the line."
)

bool showSigmaInput = input.bool(
     false,
     "Show recency-weighted sigma",
     group = GROUP_LOCATION,
     tooltip = "Adds a Position row that measures price's distance from the RWAP in recency-weighted standard deviations. The sigma uses the same anchor and weights as the line. No bands are drawn."
)

// ─────────────────────────────────────────────────────────────────────────────
// Clock ladder inputs
// ─────────────────────────────────────────────────────────────────────────────

bool restrictToDesignClocksInput = input.bool(
     true,
     "Run on design clocks only (15m, 1h, 1D)",
     group = GROUP_LADDER,
     tooltip = "When enabled, the line is hidden on any other chart timeframe and the table says why. TradingView's Visibility tab cannot be set from code, so this switch protects templates pasted onto other clocks."
)

bool showLadderInput = input.bool(
     true,
     "Show slower clocks in the table",
     group = GROUP_LADDER,
     tooltip = "On the 1h chart the table adds the 1D state. On the 15m chart it adds the 1h and 1D states."
)

string ladderValueModeInput = input.string(
     "Confirmed",
     "Ladder values",
     options = ["Confirmed", "Live"],
     group = GROUP_LADDER,
     tooltip = "Confirmed reports the last closed bar of each slower clock and never repaints. Live reports the forming bar of each slower clock and can change until that bar closes."
)

// ─────────────────────────────────────────────────────────────────────────────
// Visual inputs
// ─────────────────────────────────────────────────────────────────────────────

color bullishColorInput = input.color(
     #4E8B3F,
     "Bullish color",
     group = GROUP_VISUALS
)

color neutralColorInput = input.color(
     #FFF59D,
     "Neutral color",
     group = GROUP_VISUALS
)

color bearishColorInput = input.color(
     #E06C6C,
     "Bearish color",
     group = GROUP_VISUALS
)

int brightnessFloorInput = input.int(
     34,
     "Brightness floor",
     minval = 0,
     maxval = 100,
     group = GROUP_VISUALS,
     tooltip = "This value defines the minimum opacity percentage. The script sorts the floor and ceiling internally if they are entered in reverse order."
)

int brightnessCeilingInput = input.int(
     89,
     "Brightness ceiling",
     minval = 0,
     maxval = 100,
     group = GROUP_VISUALS,
     tooltip = "This value defines the maximum opacity percentage. The defaults of 34 and 89 are intentional Fibonacci values."
)

int lineWidthInput = input.int(
     5,
     "Line width",
     minval = 1,
     maxval = 6,
     group = GROUP_VISUALS
)

// ─────────────────────────────────────────────────────────────────────────────
// Information table inputs
// ─────────────────────────────────────────────────────────────────────────────

bool showInformationTableInput = input.bool(
     true,
     "Show information table",
     group = GROUP_INFORMATION
)

string tablePositionInput = input.string(
     "Top Right",
     "Table position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = GROUP_INFORMATION
)

string tableTextSizeInput = input.string(
     "Normal",
     "Table text size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_INFORMATION
)

color tableBackgroundInput = input.color(
     color.new(#2A2A2A, 45),
     "Table background",
     group = GROUP_INFORMATION
)

color tableLabelColorInput = input.color(
     #FAF3B2,
     "Table label color",
     group = GROUP_INFORMATION,
     tooltip = "Labels and descriptive values use this color. State, slope, force, posture, location and sigma values take the line's state colors."
)

color tableBorderColorInput = input.color(
     color.new(#FAF3B2, 70),
     "Table border color",
     group = GROUP_INFORMATION
)

int tableBorderWidthInput = input.int(
     1,
     "Table border width",
     minval = 0,
     maxval = 5,
     group = GROUP_INFORMATION
)

bool showTableFootnoteInput = input.bool(
     true,
     "Show memory footnote",
     group = GROUP_INFORMATION
)

// ─────────────────────────────────────────────────────────────────────────────
// Alert inputs
// ─────────────────────────────────────────────────────────────────────────────

bool enableStateAlertsInput = input.bool(
     false,
     "Enable confirmed state alerts",
     group = GROUP_ALERTS,
     tooltip = "This switch exposes restrained bullish, neutral, and bearish state-change conditions. TradingView alerts must still be created manually."
)

// ─────────────────────────────────────────────────────────────────────────────
// Clock identity
// ─────────────────────────────────────────────────────────────────────────────

bool isFifteenMinute = timeframe.isminutes and timeframe.multiplier == 15
bool isHourly = timeframe.isminutes and timeframe.multiplier == 60
bool isDaily = timeframe.isdaily and timeframe.multiplier == 1
bool onDesignClock = isFifteenMinute or isHourly or isDaily

string clockLabel =
     isFifteenMinute ? "15m" :
     isHourly ? "1h" :
     isDaily ? "1D" :
     timeframe.period

// ─────────────────────────────────────────────────────────────────────────────
// Anchor detection
// ─────────────────────────────────────────────────────────────────────────────

string sessionSpecification = sessionHoursInput + ":" + sessionDaysInput

bool manualAnchorActive = time >= manualAnchorTimeInput
bool manualAnchorReset =
     manualAnchorActive and
     (barstate.isfirst or not manualAnchorActive[1])

bool insideSelectedSession =
     not na(time(timeframe.period, sessionSpecification))

bool newTradingDay =
     nz(ta.change(time_tradingday), 0) != 0

bool sessionAnchorReset =
     insideSelectedSession and
     (
         barstate.isfirst or
         not insideSelectedSession[1] or
         newTradingDay
     )

bool weekAnchorReset =
     barstate.isfirst or timeframe.change("1W")

bool monthAnchorReset =
     barstate.isfirst or timeframe.change("1M")

bool anchorActive = switch anchorModeInput
    "Manual" => manualAnchorActive
    "Session" => insideSelectedSession
    => true

bool anchorReset = switch anchorModeInput
    "Manual" => manualAnchorReset
    "Session" => sessionAnchorReset
    "Week" => weekAnchorReset
    "Month" => monthAnchorReset
    => false

// ─────────────────────────────────────────────────────────────────────────────
// Bars per trading day and clock-span gamma
// ─────────────────────────────────────────────────────────────────────────────

// Intraday charts measure their own trading-day length as the median bar
// count of the most recent completed days. The day holding the first loaded
// bar is skipped, because loaded history usually begins mid-session. A median
// ignores the merged days around holidays, half-days and sparse extended-hours
// sessions that would each distort a maximum. Daily and slower charts use
// calendar arithmetic.
var array<int> dayCounts = array.new<int>()
var int barsInTradingDay = 0
var bool firstBoundarySeen = false

if newTradingDay
    if firstBoundarySeen and barsInTradingDay > 0
        array.push(dayCounts, barsInTradingDay)
        if array.size(dayCounts) > DAY_SAMPLE
            array.shift(dayCounts)
    firstBoundarySeen := true
    barsInTradingDay := 1
else
    barsInTradingDay += 1

bool dayLengthMeasured = array.size(dayCounts) > 0

float barsPerDay =
     timeframe.isdaily ? 1.0 / timeframe.multiplier :
     timeframe.isweekly ? 1.0 / (5.0 * timeframe.multiplier) :
     timeframe.ismonthly ? 1.0 / (21.0 * timeframe.multiplier) :
     dayLengthMeasured ? float(array.median(dayCounts)) :
     86400.0 / timeframe.in_seconds()

int clockSpanBars =
     math.max(2, int(math.round(memorySpanDaysInput * barsPerDay)))

float clockGamma =
     math.pow(0.05, 1.0 / clockSpanBars)

float targetGamma =
     memoryModeInput == "Clock span" ? clockGamma : gammaFactorInput

// Gamma is fixed at each anchor reset so the weights inside one anchored
// span remain a true geometric sequence. A clock-span gamma set before any
// completed day had been measured rests on a 24-hour placeholder, so it is
// marked provisional and re-derived once, at the first completed day.
var float activeGamma = na
var bool gammaProvisional = false

if anchorReset or na(activeGamma)
    activeGamma := targetGamma
    gammaProvisional :=
         memoryModeInput == "Clock span" and
         timeframe.isintraday and
         not dayLengthMeasured

bool rederiveGamma =
     gammaProvisional and
     dayLengthMeasured and
     not anchorReset

if rederiveGamma
    activeGamma := targetGamma
    gammaProvisional := false

// ─────────────────────────────────────────────────────────────────────────────
// Anchored finite geometric weighting
// ─────────────────────────────────────────────────────────────────────────────

// The recurrence below calculates the exact anchored finite geometric sums
// without looping through every post-anchor bar on every script execution.
// The squared sum supports the optional recency-weighted sigma.
var float weightedPriceSum = na
var float weightedSquareSum = na
var float totalWeight = na
var int barsSinceAnchor = 0

float capWeight =
     math.pow(activeGamma, maxWindowBarsInput)

if not anchorActive
    weightedPriceSum := na
    weightedSquareSum := na
    totalWeight := na
    barsSinceAnchor := 0
else if anchorReset or na(weightedPriceSum[1]) or na(totalWeight[1])
    weightedPriceSum := sourceInput
    weightedSquareSum := sourceInput * sourceInput
    totalWeight := 1.0
    barsSinceAnchor := 1
else
    weightedPriceSum := sourceInput + activeGamma * weightedPriceSum[1]
    weightedSquareSum := sourceInput * sourceInput + activeGamma * weightedSquareSum[1]
    totalWeight := 1.0 + activeGamma * totalWeight[1]
    barsSinceAnchor := barsSinceAnchor[1] + 1

    if (
         useWindowCapInput and
         barsSinceAnchor > maxWindowBarsInput and
         not na(sourceInput[maxWindowBarsInput])
     )
        float expiredPrice = sourceInput[maxWindowBarsInput]
        weightedPriceSum -= capWeight * expiredPrice
        weightedSquareSum -= capWeight * expiredPrice * expiredPrice
        totalWeight -= capWeight

// When a provisional gamma is re-derived, the sums accumulated under the
// placeholder are rebuilt once with the measured gamma. The span is short by
// construction (at most the bars since the anchor through the first completed
// day), so the loop runs a single time and stays small.
if rederiveGamma and anchorActive and barsSinceAnchor > 0
    int rebuildSpan =
         useWindowCapInput ? math.min(barsSinceAnchor, maxWindowBarsInput) : barsSinceAnchor
    float rebuiltPrice = 0.0
    float rebuiltSquare = 0.0
    float rebuiltWeight = 0.0
    float stepWeight = 1.0
    for i = 0 to rebuildSpan - 1
        float pastPrice = sourceInput[i]
        rebuiltPrice += stepWeight * pastPrice
        rebuiltSquare += stepWeight * pastPrice * pastPrice
        rebuiltWeight += stepWeight
        stepWeight *= activeGamma
    weightedPriceSum := rebuiltPrice
    weightedSquareSum := rebuiltSquare
    totalWeight := rebuiltWeight

float rwap =
     anchorActive and
     not na(totalWeight) and
     totalWeight > 0.0
     ? weightedPriceSum / totalWeight
     : na

float weightedVariance =
     na(rwap) ? na : math.max(weightedSquareSum / totalWeight - rwap * rwap, 0.0)

float recencySigma =
     na(weightedVariance) ? na : math.sqrt(weightedVariance)

// ─────────────────────────────────────────────────────────────────────────────
// ATR-normalized slope
// ─────────────────────────────────────────────────────────────────────────────

float atrValue = ta.atr(atrLengthInput)

bool slopeReady =
     anchorActive and
     barsSinceAnchor > slopeLookbackInput and
     not na(rwap) and
     not na(rwap[slopeLookbackInput]) and
     not na(atrValue) and
     atrValue > 0.0

float normalizedSlope =
     slopeReady
     ? (rwap - rwap[slopeLookbackInput]) / atrValue
     : na

// The exit threshold remains inside the entry threshold.
// This arrangement creates a hysteresis band.
float exitThreshold =
     math.max(
         directionalThresholdInput - hysteresisWidthInput,
         0.0
     )

// ─────────────────────────────────────────────────────────────────────────────
// Tri-modal state machine
// ─────────────────────────────────────────────────────────────────────────────

var int rwapState = STATE_NEUTRAL

int priorState =
     nz(rwapState[1], STATE_NEUTRAL)

int candidateState = priorState

if slopeReady
    if priorState == STATE_BULLISH
        if normalizedSlope <= -directionalThresholdInput
            candidateState := STATE_BEARISH
        else if normalizedSlope < exitThreshold
            candidateState := STATE_NEUTRAL
        else
            candidateState := STATE_BULLISH

    else if priorState == STATE_BEARISH
        if normalizedSlope >= directionalThresholdInput
            candidateState := STATE_BULLISH
        else if normalizedSlope > -exitThreshold
            candidateState := STATE_NEUTRAL
        else
            candidateState := STATE_BEARISH

    else
        if normalizedSlope >= directionalThresholdInput
            candidateState := STATE_BULLISH
        else if normalizedSlope <= -directionalThresholdInput
            candidateState := STATE_BEARISH
        else
            candidateState := STATE_NEUTRAL
else
    candidateState := STATE_NEUTRAL

if not anchorActive or anchorReset or not slopeReady
    rwapState := STATE_NEUTRAL
else if confirmStateAtCloseInput and not barstate.isconfirmed
    rwapState := priorState
else
    rwapState := candidateState

// ─────────────────────────────────────────────────────────────────────────────
// Location, posture and sigma
// ─────────────────────────────────────────────────────────────────────────────

float priceDistance =
     na(rwap) ? na : close - rwap

float distanceAtr =
     na(priceDistance) or na(atrValue) or atrValue <= 0.0 ? na : priceDistance / atrValue

float distancePercent =
     na(priceDistance) or rwap == 0.0 ? na : 100.0 * priceDistance / rwap

// Side is +1 above the band, -1 beneath it, and 0 at the line.
int priceSide =
     na(distanceAtr) ? 0 :
     distanceAtr > atLineBandInput ? 1 :
     distanceAtr < -atLineBandInput ? -1 :
     0

// Posture joins side and state: +2 acceptance above a rising line,
// +1 pullback beneath a rising line, -1 relief above a falling line,
// -2 acceptance beneath a falling line, and 0 at the line or beside a flat one.
int postureCode =
     priceSide == 0 ? 0 :
     rwapState == STATE_BULLISH ? (priceSide > 0 ? 2 : 1) :
     rwapState == STATE_BEARISH ? (priceSide < 0 ? -2 : -1) :
     0

string postureText =
     na(rwap) ? "n/a" :
     priceSide == 0 ? "At equilibrium" :
     postureCode == 2 ? "Acceptance · rising" :
     postureCode == 1 ? "Pullback · rising" :
     postureCode == -1 ? "Relief · falling" :
     postureCode == -2 ? "Acceptance · falling" :
     priceSide > 0 ? "Above · flat" :
     "Below · flat"

float positionSigma =
     na(priceDistance) or na(recencySigma) or recencySigma <= 0.0 ? na : priceDistance / recencySigma

// ─────────────────────────────────────────────────────────────────────────────
// Memory and anchor reach
// ─────────────────────────────────────────────────────────────────────────────

int activeWindowBars =
     useWindowCapInput
     ? math.min(barsSinceAnchor, maxWindowBarsInput)
     : barsSinceAnchor

int memoryEstimate =
     effectiveMemoryBars(activeGamma, activeWindowBars)

// The full memory ignores the anchor, so comparing it with the active span
// shows how much of the anchor's auction the line still remembers.
float fullMemoryBars =
     activeGamma >= 0.999999 ? na : math.log(0.05) / math.log(activeGamma)

float reachRatio =
     na(fullMemoryBars) or fullMemoryBars <= 0.0 ? na : activeWindowBars / fullMemoryBars

string reachText =
     useWindowCapInput and barsSinceAnchor > maxWindowBarsInput ? "Capped" :
     na(reachRatio) ? "Active · equal weight" :
     reachRatio <= 1.0 ? "Active · " + str.tostring(reachRatio, "0.0") + "×" :
     reachRatio <= 2.0 ? "Fading · " + str.tostring(reachRatio, "0.0") + "×" :
     "Forgotten · " + str.tostring(reachRatio, "0.0") + "×"

// ─────────────────────────────────────────────────────────────────────────────
// Slower clocks
// ─────────────────────────────────────────────────────────────────────────────

// Each slower clock recomputes the whole indicator in its own context.
// Confirmed values read the last closed slower bar and never repaint.
// A request for a clock no slower than the chart falls back to the chart's own
// timeframe and is never displayed.
string dailyRequestTf = timeframe.in_seconds() < 86400 ? "1D" : timeframe.period
string hourlyRequestTf = timeframe.in_seconds() < 3600 ? "60" : timeframe.period

[dailyStateConfirmed, dailySlopeConfirmed] = request.security(syminfo.tickerid, dailyRequestTf, [rwapState[1], normalizedSlope[1]], lookahead = barmerge.lookahead_on)
[dailyStateLive, dailySlopeLive] = request.security(syminfo.tickerid, dailyRequestTf, [rwapState, normalizedSlope])
[hourlyStateConfirmed, hourlySlopeConfirmed] = request.security(syminfo.tickerid, hourlyRequestTf, [rwapState[1], normalizedSlope[1]], lookahead = barmerge.lookahead_on)
[hourlyStateLive, hourlySlopeLive] = request.security(syminfo.tickerid, hourlyRequestTf, [rwapState, normalizedSlope])

bool useLiveLadder = ladderValueModeInput == "Live"

int dailyState = nz(useLiveLadder ? dailyStateLive : dailyStateConfirmed, STATE_NEUTRAL)
float dailySlope = useLiveLadder ? dailySlopeLive : dailySlopeConfirmed
int hourlyState = nz(useLiveLadder ? hourlyStateLive : hourlyStateConfirmed, STATE_NEUTRAL)
float hourlySlope = useLiveLadder ? hourlySlopeLive : hourlySlopeConfirmed

bool showDailyRung = showLadderInput and (isHourly or isFifteenMinute)
bool showHourlyRung = showLadderInput and isFifteenMinute

// ─────────────────────────────────────────────────────────────────────────────
// Guards
// ─────────────────────────────────────────────────────────────────────────────

bool offDesignClock = restrictToDesignClocksInput and not onDesignClock
bool sessionOnSlowClock = anchorModeInput == "Session" and timeframe.isdwm
bool suppressLine = offDesignClock or sessionOnSlowClock

string guardNote =
     offDesignClock ? "Designed for 15m, 1h and 1D; line hidden" :
     sessionOnSlowClock ? "Session mode resets every bar here; line hidden" :
     ""

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic dimming
// ─────────────────────────────────────────────────────────────────────────────

// The user inputs express opacity-style brightness from 0 through 100.
// Pine colors use inverse transparency, so the script converts brightness
// into transparency immediately before plotting.
int brightnessFloor =
     math.min(brightnessFloorInput, brightnessCeilingInput)

int brightnessCeiling =
     math.max(brightnessFloorInput, brightnessCeilingInput)

float forceRatio =
     na(normalizedSlope)
     ? 0.0
     : math.min(
         math.abs(normalizedSlope) / fullBrightnessSlopeInput,
         1.0
     )

float dynamicBrightness =
     float(brightnessFloor) +
     float(brightnessCeiling - brightnessFloor) * forceRatio

int dynamicTransparency =
     100 - int(math.round(dynamicBrightness))

color stateBaseColor =
     rwapState == STATE_BULLISH
     ? bullishColorInput
     : rwapState == STATE_BEARISH
     ? bearishColorInput
     : neutralColorInput

color dynamicLineColor =
     color.new(stateBaseColor, dynamicTransparency)

// The line-break style prevents a session-mode plot from bridging inactive gaps.
plot(
     suppressLine ? na : rwap,
     title = "Anchored RWAP",
     color = dynamicLineColor,
     linewidth = lineWidthInput,
     style = plot.style_linebr
)

// ─────────────────────────────────────────────────────────────────────────────
// Shared value colors
// ─────────────────────────────────────────────────────────────────────────────

color valueBullColor = color.new(bullishColorInput, 0)
color valueBearColor = color.new(bearishColorInput, 0)
color valueNeutralColor = color.new(neutralColorInput, 0)

colorForState(int state) =>
    state == STATE_BULLISH ? valueBullColor :
     state == STATE_BEARISH ? valueBearColor :
     valueNeutralColor

color sideColor =
     na(priceDistance) ? tableLabelColorInput :
     priceSide > 0 ? valueBullColor :
     priceSide < 0 ? valueBearColor :
     valueNeutralColor

color slopeColor =
     na(normalizedSlope) ? tableLabelColorInput :
     normalizedSlope >= directionalThresholdInput ? valueBullColor :
     normalizedSlope <= -directionalThresholdInput ? valueBearColor :
     valueNeutralColor

color postureColor =
     postureCode == 2 ? valueBullColor :
     postureCode == -2 ? valueBearColor :
     postureCode == 1 or postureCode == -1 ? valueNeutralColor :
     tableLabelColorInput

// ─────────────────────────────────────────────────────────────────────────────
// Data Window outputs
// ─────────────────────────────────────────────────────────────────────────────

plot(normalizedSlope, "Normalized slope", color = slopeColor, display = display.data_window)
plot(na(normalizedSlope) ? na : forceRatio * 100.0, "Force (%)", color = colorForState(rwapState), display = display.data_window)
plot(rwapState, "State (-1 bear · 0 neutral · +1 bull)", color = colorForState(rwapState), display = display.data_window)
plot(distanceAtr, "Price vs RWAP (ATR)", color = sideColor, display = display.data_window)
plot(distancePercent, "Price vs RWAP (%)", color = sideColor, display = display.data_window)
plot(na(rwap) ? na : postureCode, "Posture (-2 to +2)", color = postureColor, display = display.data_window)
plot(showSigmaInput ? recencySigma : na, "Recency sigma", color = tableLabelColorInput, display = display.data_window)
plot(showSigmaInput ? positionSigma : na, "Position (sigma)", color = sideColor, display = display.data_window)
plot(activeGamma, "Active gamma", color = tableLabelColorInput, display = display.data_window)
plot(gammaProvisional ? 1 : 0, "Gamma provisional (1 yes · 0 no)", color = tableLabelColorInput, display = display.data_window)
plot(barsPerDay, "Bars per trading day", color = tableLabelColorInput, display = display.data_window)
plot(memoryEstimate, "Effective memory (bars)", color = tableLabelColorInput, display = display.data_window)
plot(reachRatio, "Anchor reach (span ÷ memory)", color = tableLabelColorInput, display = display.data_window)
plot(showHourlyRung ? hourlyState : na, "1h state", color = colorForState(hourlyState), display = display.data_window)
plot(showDailyRung ? dailyState : na, "1D state", color = colorForState(dailyState), display = display.data_window)

// ─────────────────────────────────────────────────────────────────────────────
// Optional information table
// ─────────────────────────────────────────────────────────────────────────────

tablePos = switch tablePositionInput
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right
    => position.top_right

tableSize = switch tableTextSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge" => size.huge
    => size.normal

// This helper writes one label and value pair.
writeRow(table tableId, int row, string label, string value, color valueColor, string textSize) =>
    table.cell(tableId, 0, row, label, text_color = tableLabelColorInput, text_size = textSize, text_halign = text.align_left)
    table.cell(tableId, 1, row, value, text_color = valueColor, text_size = textSize, text_halign = text.align_right)

string anchorText = switch anchorModeInput
    "Manual" => "Manual · " + str.format_time(manualAnchorTimeInput, "yyyy-MM-dd HH:mm", syminfo.timezone)
    "Session" => "Session · " + sessionHoursInput
    => anchorModeInput

string gammaText =
     str.tostring(activeGamma, "0.0000") +
     (memoryModeInput == "Clock span" ? (gammaProvisional ? " · provisional" : " · clock span") : " · fixed")

string barsText =
     str.tostring(barsSinceAnchor) +
     (useWindowCapInput and barsSinceAnchor > maxWindowBarsInput ? " (cap " + str.tostring(maxWindowBarsInput) + ")" : "")

string rwapText =
     na(rwap) ? "n/a" : str.tostring(rwap, format.mintick)

string distanceText =
     na(distanceAtr) ? "n/a" :
     signedText(distanceAtr, "0.00") + " ATR · " + signedText(distancePercent, "0.00") + "%"

string slopeText =
     signedText(normalizedSlope, "0.0000")

string forceText =
     na(normalizedSlope) ? "n/a" : str.tostring(math.round(forceRatio * 100.0)) + "%"

// A live bar under confirmation can show the state it is leaning toward.
bool statePending =
     confirmStateAtCloseInput and
     not barstate.isconfirmed and
     slopeReady and
     anchorActive and
     candidateState != rwapState

string stateText =
     stateName(rwapState) +
     (statePending ? "  → " + stateName(candidateState) + "?" : "")

string sigmaText =
     na(positionSigma) ? "n/a" :
     signedText(positionSigma, "0.00") + " σ · σ " + str.tostring(recencySigma, format.mintick)

string memoryText =
     "~" + str.tostring(memoryEstimate) + " bars · " + str.tostring(memoryEstimate / barsPerDay, "0.0") + " d"

string dailyRungText =
     stateName(dailyState) + " · " + signedText(dailySlope, "0.0000")

string hourlyRungText =
     stateName(hourlyState) + " · " + signedText(hourlySlope, "0.0000")

var table informationTable = na

if showInformationTableInput and barstate.islast
    if na(informationTable)
        informationTable := table.new(
             tablePos,
             2,
             20,
             bgcolor = tableBackgroundInput,
             border_width = tableBorderWidthInput,
             border_color = tableBorderColorInput
         )

    int row = 0
    writeRow(informationTable, row, "Anchored RWAP", syminfo.ticker + " · " + clockLabel, tableLabelColorInput, tableSize)
    row += 1

    if suppressLine
        writeRow(informationTable, row, "Note", guardNote, valueNeutralColor, tableSize)
        row += 1
    else
        writeRow(informationTable, row, "Anchor", anchorText, tableLabelColorInput, tableSize)
        row += 1
        writeRow(informationTable, row, "Gamma", gammaText, tableLabelColorInput, tableSize)
        row += 1
        writeRow(informationTable, row, "Bars since anchor", barsText, tableLabelColorInput, tableSize)
        row += 1
        writeRow(informationTable, row, "Anchor reach", reachText, tableLabelColorInput, tableSize)
        row += 1
        writeRow(informationTable, row, "RWAP", rwapText, colorForState(rwapState), tableSize)
        row += 1
        writeRow(informationTable, row, "Price vs RWAP", distanceText, sideColor, tableSize)
        row += 1
        writeRow(informationTable, row, "Posture", postureText, postureColor, tableSize)
        row += 1

        if showSigmaInput
            writeRow(informationTable, row, "Position", sigmaText, sideColor, tableSize)
            row += 1

        writeRow(informationTable, row, "Normalized slope", slopeText, slopeColor, tableSize)
        row += 1
        writeRow(informationTable, row, "Force", forceText, colorForState(rwapState), tableSize)
        row += 1
        writeRow(informationTable, row, "State", stateText, colorForState(rwapState), tableSize)
        row += 1

        if showHourlyRung
            writeRow(informationTable, row, "1h state", hourlyRungText, colorForState(hourlyState), tableSize)
            row += 1

        if showDailyRung
            writeRow(informationTable, row, "1D state", dailyRungText, colorForState(dailyState), tableSize)
            row += 1

        writeRow(informationTable, row, "Effective memory*", memoryText, tableLabelColorInput, tableSize)
        row += 1

        if showTableFootnoteInput
            color footnoteColor = color.new(tableLabelColorInput, 40)
            table.cell(informationTable, 0, row, "*Approximate 95% weight span", text_color = footnoteColor, text_size = size.tiny, text_halign = text.align_left)
            table.cell(informationTable, 1, row, "Times in " + syminfo.timezone, text_color = footnoteColor, text_size = size.tiny, text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// Optional restrained alerts
// ─────────────────────────────────────────────────────────────────────────────

bool confirmedBullishChange =
     enableStateAlertsInput and
     barstate.isconfirmed and
     rwapState == STATE_BULLISH and
     priorState != STATE_BULLISH

bool confirmedNeutralChange =
     enableStateAlertsInput and
     barstate.isconfirmed and
     rwapState == STATE_NEUTRAL and
     priorState != STATE_NEUTRAL

bool confirmedBearishChange =
     enableStateAlertsInput and
     barstate.isconfirmed and
     rwapState == STATE_BEARISH and
     priorState != STATE_BEARISH

alertcondition(
     confirmedBullishChange,
     title = "Anchored RWAP entered bullish state",
     message = "Anchored RWAP entered a confirmed bullish slope state."
)

alertcondition(
     confirmedNeutralChange,
     title = "Anchored RWAP entered neutral state",
     message = "Anchored RWAP entered a confirmed neutral slope state."
)

alertcondition(
     confirmedBearishChange,
     title = "Anchored RWAP entered bearish state",
     message = "Anchored RWAP entered a confirmed bearish slope state."
)
````
