<!-- tradingview-pine-id: PUB;1cbd779ea65a446e82c367853b18fd66 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Distribution Days & Follow Thru Day Counter

Source: https://www.tradingview.com/script/AA5kdzHu-Distribution-Days-Follow-Thru-Day-Counter/

## Description

Distribution & Follow-Through Days Counter

Distribution & Follow-Through Days Counter is an independent Pine Script v6 indicator designed to visualize several publicly described William O'Neil / IBD-style market-timing concepts on daily charts. Rather than displaying isolated signals, the indicator combines Market Correction, Rally Attempt, Follow-Through Day and Distribution analysis into a state-based market-direction model.

OVERVIEW

The model follows three primary market states: CORRECTION, RALLY ATTEMPT and CONFIRMED UPTREND.

1. MARKET CORRECTION

The model begins in a Correction state and tracks the developing market low. The first confirmed positive session that holds the current correction low can begin Rally Attempt Day 1. The objective at this stage is to identify a possible change in market character without prematurely treating the market as being in a confirmed uptrend.

2. RALLY ATTEMPT

Once a Rally Attempt begins, the indicator counts successive trading sessions from Day 1. The attempt fails if the market undercuts the Rally Low according to the selected failure method. By default, the model uses an intraday undercut of the Rally Low as the stricter failure condition, while a close-based alternative is also available. Unlike earlier versions, the script does not impose an arbitrary maximum Rally Day, so a Follow-Through Day may occur on Day 4 or later when the required price and volume conditions are satisfied.

3. CONFIRMED UPTREND

A qualifying Follow-Through Day changes the model state to CONFIRMED UPTREND. When a new FTD occurs, the previous Distribution/Stalling count is reset and a new selling-pressure cycle begins. During a Confirmed Uptrend, the indicator tracks Distribution Days, Stalling-Day approximations, Distribution expiration, 5% recovery/negation, Follow-Through Day age, early post-FTD selling, Follow-Through Day low undercuts and accumulated selling pressure.

DISTRIBUTION DAYS

A Distribution Day is identified when the market declines by at least the configured threshold while volume is greater than the previous session. The default decline threshold is 0.20%. Each Distribution Day is stored independently rather than being managed as part of a simple FIFO counter. A counted Distribution or Stalling event is removed when its configured trading-bar lifetime expires or when the market closes at least the configured recovery percentage above that event's close. The default settings are 25 trading bars for expiration and 5% for recovery/negation. This allows every selling-pressure event to maintain its own independent lifecycle.

STALLING-DAY APPROXIMATION

The Stalling detector is deliberately described as an approximation. It uses publicly described characteristics including a small positive price gain, higher volume than the previous session, a close in the lower portion of the daily range, and recent upward progress during at least one of the previous two sessions. The default settings are a maximum Stalling gain of 0.40%, a maximum close position of 50% of the daily range, and a prior progress requirement of 0.20%.

Complete proprietary Stalling-Day rules are not reconstructed by this script. The indicator therefore does not claim that every orange "S" marker represents an official IBD Stalling Day. Instead, the signal should be interpreted as a public-rule approximation of potential institutional stalling behavior.

FOLLOW-THROUGH DAY

The default Follow-Through Day requirements are:
Rally Day 4 or later
Daily gain of at least 1.25%
Volume greater than the previous session
The price threshold is configurable, and there is no Day 12 cutoff. A qualifying FTD changes the model to Confirmed Uptrend, records the FTD session and Rally Day, records the FTD session low, and resets the Distribution/Stalling count to zero.

FTD LOW UNDERCUT

After a Follow-Through Day, the script can monitor whether a later session trades below the FTD day's low. When this occurs, the indicator generates an FTD LOW warning. By default, an FTD-low undercut is treated as a warning rather than an automatic market-regime change. Users may optionally enable a model rule that resets the state to Correction following an FTD-low undercut. This optional reset is explicitly treated as a model heuristic rather than an official market-status rule.

EARLY POST-FTD WARNING

Selling pressure appearing shortly after a Follow-Through Day can be particularly important. The indicator therefore monitors Distribution and Stalling events occurring inside a configurable early post-FTD window. The default warning window is 5 trading sessions. A selling-pressure event inside this period receives an additional visual warning, helping distinguish ordinary later-stage Distribution from selling that appears almost immediately after a new rally has been confirmed.

MODEL STATES

CORRECTION means no active Rally Attempt has been confirmed and the model continues tracking the developing market low. RALLY ATTEMPT means a potential recovery has begun, but no qualifying Follow-Through Day has yet appeared; the dashboard displays the current Rally Day and Rally Low. CONFIRMED UPTREND means a qualifying Follow-Through Day has occurred and Distribution and Stalling events are now tracked as part of the current selling-pressure cycle.

MODEL PRESSURE

The indicator summarizes accumulated selling pressure during a Confirmed Uptrend. The dashboard displays the active Distribution count, active Stalling approximation count, total selling-pressure count and Model Pressure status. The script also includes an optional transition from Confirmed Uptrend back to Correction after substantial accumulated selling pressure. The default heuristic reset level is 7 active Distribution/Stalling events. This feature is explicitly labeled a heuristic model rule and is not presented as a reconstruction of the official IBD Market Pulse algorithm. The automatic pressure reset can be disabled.

DASHBOARD

The on-chart dashboard summarizes the current model state and important market-direction information, including Timeframe Status, Model State, Rally Attempt Day, Rally Low, Follow-Through Day, FTD Age, Distribution count, Stalling approximation count, Total Pressure, Model Pressure and Last Event.

The dashboard supports nine positions:
Top Left / Top Center / Top Right
Middle Left / Middle Center / Middle Right
Bottom Left / Bottom Center / Bottom Right
Five dashboard text sizes are supported: Tiny, Small, Normal, Large and Huge. The dashboard also includes the attribution CANSLIM Research | canslim.blog.

CONFIRMED-BAR PROCESSING

Market-direction signals are calculated only from confirmed bars. On a Daily chart, this means a Distribution Day, Stalling approximation, Rally Day, Follow-Through Day or FTD-low warning is not finalized until the Daily candle has closed. This helps prevent temporary intraday price or volume conditions from being permanently counted before the trading session is complete.

RECOMMENDED TIMEFRAME

The recommended timeframe is 1 Day. The indicator is specifically designed around daily market-timing concepts. When Require 1D Chart is enabled, signal generation is disabled on other timeframes. The dashboard displays 1D OK when the correct timeframe is being used and USE 1D on an unsupported timeframe.

VOLUME AND DATA LIMITATIONS

This model depends heavily on volume. Different TradingView symbols, exchanges and data vendors can report different volume figures, and index volume in particular may not always represent exactly the same data used by other market-analysis services. For this reason, highly liquid ETF proxies such as SPY or QQQ may sometimes provide more consistent volume behavior than cash index symbols. Users should understand the underlying data source and compare instruments before relying on individual signals.

ALERTS

The indicator includes alert conditions for:
Distribution Day
Stalling approximation
Rally Attempt Day 1
Rally Attempt failure
Follow-Through Day
Early post-FTD selling
FTD Low undercut
Model Correction
Because model events require confirmed bars, alerts are primarily intended for end-of-session market analysis rather than intraday prediction.

IMPORTANT METHODOLOGY LIMITATION

This indicator intentionally separates publicly described methodology from model-specific heuristics. Where a rule can reasonably be represented using publicly described daily OHLCV concepts, the script attempts to implement it directly. Where the full methodology involves proprietary rules, discretionary interpretation, leadership analysis, market context or information unavailable from standard TradingView OHLCV data, the script does not attempt to invent an exact replacement.

This distinction is particularly important for Stalling Days, market-regime transitions, accumulated Distribution interpretation, and broader market leadership and confirmation. The objective is to provide a transparent analytical framework rather than claim an exact reconstruction of a proprietary market-timing system.

VERSION 8.2 RELEASE NOTES

Version 8.2 introduces a major architecture and usability rewrite. The model now uses three explicit market states: Correction, Rally Attempt and Confirmed Uptrend. Follow-Through Day resets the Distribution/Stalling count, the arbitrary Rally Day 12 cutoff has been removed, FTD can qualify on Rally Day 4 or later, and explicit FTD Rally-Day, FTD age and FTD-low tracking have been added.

Rally Attempt state handling has been reworked, including a configurable Rally Low failure method and proper cycle reset following a failed Rally Attempt. Distribution events now maintain independent expiration and 5% recovery/negation levels, while selling pressure is counted only during a Confirmed Uptrend. A new Follow-Through Day begins a fresh Distribution cycle.

The Stalling approximation now includes a prior two-session progress requirement and is explicitly identified as a public-rule approximation rather than an official proprietary detector. Early post-FTD selling warnings and FTD-low undercut warnings have also been added, while the optional FTD-low model reset remains disabled by default.

The model now clearly separates publicly described methodology from configurable heuristics, including the optional Correction reset based on accumulated selling pressure. Signals require confirmed bars to reduce temporary realtime Daily-bar conditions, and Daily-timeframe validation can prevent signal generation outside the intended 1D timeframe.

The dashboard has also been redesigned with nine selectable positions, five text-size levels and CANSLIM Research attribution. Alert conditions have been reorganized to cover the major market-direction events used by the model.

DISCLAIMER

This script is provided for educational, research and analytical purposes only. It is an independent implementation inspired by publicly described William O'Neil / IBD-style market-analysis concepts and is not an official implementation of Investor's Business Daily, MarketSurge, William O'Neil + Co., Dow Jones, or any affiliated methodology or product.

Some elements of the original methodology involve discretionary judgment, market context, leadership behavior, proprietary definitions and data that cannot be reconstructed solely from TradingView OHLCV information. The indicator should therefore not be interpreted as an exact reproduction of any proprietary market-timing system. Past signals do not guarantee future market performance. Nothing produced by this indicator constitutes investment advice, a recommendation to buy or sell securities, or a guarantee of investment results. Users remain solely responsible for their own investment decisions and risk management.

---

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// Author: hkpress
// Version: 8.2
//
// Market Direction: Distribution, Rally & Follow-Through
//
// CANSLIM Research | canslim.blog
//
// IMPORTANT:
// - Designed primarily for DAILY charts.
// - Best used on major U.S. market indexes with usable volume data,
//   or highly liquid ETF proxies such as SPY / QQQ.
// - Independent educational implementation inspired by publicly described
//   William O'Neil / IBD market-direction concepts.
// - This is NOT an official IBD, MarketSurge, William O'Neil + Co.,
//   or Dow Jones implementation.
// - TradingView OHLCV / volume can differ from other data vendors.
// - Full proprietary stalling-day logic is not publicly available.
//   The stalling detector below is therefore explicitly an approximation.

indicator(
    "Distribution Days & Follow Thru Day Counter",
    shorttitle = "DD Days & FTD Counter",
    overlay = true,
    max_labels_count = 500
)


// ============================================================================
// MODEL STATES
// ============================================================================

const int STATE_CORRECTION = 0
const int STATE_RALLY = 1
const int STATE_CONFIRMED = 2


// ============================================================================
// INPUT GROUPS
// ============================================================================

const string G_CORE = "1. Core / Timeframe"
const string G_DIST = "2. Distribution Days"
const string G_STALL = "3. Stalling Approximation"
const string G_RALLY = "4. Rally Attempt"
const string G_FTD = "5. Follow-Through Day"
const string G_MODEL = "6. Model Regime Rules"
const string G_VIS = "7. Visuals / Dashboard"
const string G_ALERT = "8. Alerts"


// ============================================================================
// CORE
// ============================================================================

bool enforceDaily = input.bool(
    true,
    "Require 1D Chart",
    group = G_CORE,
    tooltip = "When enabled, signals are generated only on a 1-day chart."
)

int warmupBars = input.int(
    100,
    "Initialization Warm-up Bars",
    minval = 0,
    maxval = 500,
    group = G_CORE,
    tooltip = "Suppresses model signals during initial historical bootstrap."
)


// ============================================================================
// DISTRIBUTION DAY SETTINGS
// ============================================================================

float distThreshold = input.float(
    0.20,
    "Distribution Down Threshold (%)",
    minval = 0.05,
    maxval = 3.00,
    step = 0.05,
    group = G_DIST,
    tooltip = "A down day of at least this amount on higher volume can qualify as a Distribution Day."
) / 100.0

int distExpiration = input.int(
    25,
    "Distribution Expiration (Trading Bars)",
    minval = 10,
    maxval = 60,
    group = G_DIST,
    tooltip = "A counted Distribution or Stalling event expires after this many trading bars."
)

float distNegation = input.float(
    5.0,
    "Distribution Negation / Recovery (%)",
    minval = 1.0,
    maxval = 10.0,
    step = 0.25,
    group = G_DIST,
    tooltip = "A counted event is removed when the market closes this percentage above that event's close."
) / 100.0


// ============================================================================
// STALLING APPROXIMATION
// ============================================================================

bool enableStalling = input.bool(
    true,
    "Count Stalling Approximation",
    group = G_STALL,
    tooltip = "Uses publicly described characteristics only. This is not a reconstruction of proprietary IBD stalling logic."
)

float stallMaxGain = input.float(
    0.40,
    "Maximum Stalling Gain (%)",
    minval = 0.05,
    maxval = 1.50,
    step = 0.05,
    group = G_STALL
) / 100.0

float stallClosePosition = input.float(
    50.0,
    "Maximum Close Position in Range (%)",
    minval = 25.0,
    maxval = 75.0,
    step = 5.0,
    group = G_STALL,
    tooltip = "50% means the close must finish in the lower half of the day's range."
) / 100.0

float stallPriorGain = input.float(
    0.20,
    "Prior Progress Requirement (%)",
    minval = 0.0,
    maxval = 2.0,
    step = 0.05,
    group = G_STALL,
    tooltip = "At least one of the prior two sessions must have risen by this amount."
) / 100.0

bool stallRequirePriorProgress = input.bool(
    true,
    "Require Prior 2-Day Progress",
    group = G_STALL
)


// ============================================================================
// RALLY ATTEMPT
// ============================================================================

string rallyFailureMethod = input.string(
    "Intraday Low",
    "Rally Failure Method",
    options = ["Intraday Low", "Close"],
    group = G_RALLY,
    tooltip = "Intraday Low is the stricter default. Close is provided as a relaxed model alternative."
)

int minRallyDays = input.int(
    4,
    "Minimum Rally Day for FTD",
    minval = 3,
    maxval = 10,
    group = G_RALLY,
    tooltip = "Default is Day 4. No arbitrary maximum FTD day is imposed."
)


// ============================================================================
// FOLLOW-THROUGH DAY
// ============================================================================

float ftdThreshold = input.float(
    1.25,
    "FTD Minimum Gain (%)",
    minval = 0.50,
    maxval = 5.00,
    step = 0.05,
    group = G_FTD
) / 100.0

bool requireHigherVolume = input.bool(
    true,
    "Require Higher Volume",
    group = G_FTD
)

bool trackFtdLowUndercut = input.bool(
    true,
    "Track FTD Low Undercut",
    group = G_FTD,
    tooltip = "Flags the first confirmed session that trades below the Follow-Through Day's low."
)

bool resetOnFtdLowUndercut = input.bool(
    false,
    "Reset Model on FTD Low Undercut",
    group = G_FTD,
    tooltip = "Optional model heuristic. Disabled by default."
)

int postFtdWarningBars = input.int(
    5,
    "Early Post-FTD Warning Window",
    minval = 1,
    maxval = 15,
    group = G_FTD,
    tooltip = "Highlights Distribution or Stalling events occurring shortly after an FTD."
)


// ============================================================================
// MODEL REGIME RULES
// ============================================================================

bool enablePressureReset = input.bool(
    true,
    "Enable Heuristic Correction Reset",
    group = G_MODEL,
    tooltip = "Allows heavy accumulated selling pressure to reset the model to Correction. This is a model heuristic, not an official IBD Market Pulse rule."
)

int modelCorrectionCount = input.int(
    7,
    "Heuristic Correction Reset Count",
    minval = 4,
    maxval = 12,
    group = G_MODEL,
    tooltip = "Default is 7 active Distribution/Stalling events. This is explicitly a model heuristic."
)


// ============================================================================
// VISUAL SETTINGS
// ============================================================================

bool showDLabels = input.bool(true, "Show Distribution Labels", group = G_VIS)

bool showStallLabels = input.bool(true, "Show Stalling Labels", group = G_VIS)

bool showRallyLabels = input.bool(true, "Show Rally Day 1 Labels", group = G_VIS)

bool showFtdLabels = input.bool(true, "Show FTD Labels", group = G_VIS)

bool showWarningLabels = input.bool(true, "Show Warning Labels", group = G_VIS)

bool showResetLabels = input.bool(true, "Show Model Correction Labels", group = G_VIS)

bool showRallyLow = input.bool(true, "Show Rally Low", group = G_VIS)

bool showFtdLow = input.bool(true, "Show FTD Low", group = G_VIS)

bool colorBars = input.bool(false, "Color Signal Bars", group = G_VIS)

bool showDashboard = input.bool(true, "Show Dashboard", group = G_VIS)


// ============================================================================
// DASHBOARD POSITION
// ============================================================================

string dashboardVerticalInput = input.string(
    "Top",
    "Dashboard Vertical",
    options = ["Top", "Middle", "Bottom"],
    inline = "DashPos",
    group = G_VIS
)

string dashboardHorizontalInput = input.string(
    "Right",
    "Horizontal",
    options = ["Left", "Center", "Right"],
    inline = "DashPos",
    group = G_VIS
)


// ============================================================================
// DASHBOARD TEXT SIZE
// ============================================================================

string dashboardTextSizeInput = input.string(
    size.normal,
    "Dashboard Text Size",
    options = [size.tiny, size.small, size.normal, size.large, size.huge],
    group = G_VIS
)


// ============================================================================
// ALERT SETTINGS
// ============================================================================

bool enableAlerts = input.bool(
    true,
    "Enable Alert Conditions",
    group = G_ALERT
)


// ============================================================================
// DISTRIBUTION DAY DATA TYPE
// ============================================================================

type DDay
    int bar
    float closePrice
    bool isStall

var array<DDay> dDays = array.new<DDay>()


// ============================================================================
// BASIC CALCULATIONS
// ============================================================================

bool isOneDay = timeframe.isdaily and timeframe.multiplier == 1

bool timeframeOk = not enforceDaily or isOneDay

bool hasPreviousBar = not na(close[1])

bool hasVolume = not na(volume) and not na(volume[1])

float priceChange = (
    hasPreviousBar and close[1] != 0
    ? (close - close[1]) / close[1]
    : na
)

bool volumeHigher = hasVolume and volume > volume[1]

float dayRange = high - low

float closePosition = (
    dayRange > 0
    ? (close - low) / dayRange
    : 0.5
)

bool confirmedContextBar = barstate.isconfirmed and timeframeOk

bool signalBar = confirmedContextBar and bar_index >= warmupBars


// ============================================================================
// RAW DISTRIBUTION SIGNAL
// ============================================================================

bool rawDownDistribution = (
    signalBar and
    hasPreviousBar and
    volumeHigher and
    not na(priceChange) and
    priceChange <= -distThreshold
)


// ============================================================================
// PUBLIC-RULE STALLING APPROXIMATION
// ============================================================================

bool priorProgressOk = (
    not stallRequirePriorProgress or
    (
        (not na(priceChange[1]) and priceChange[1] >= stallPriorGain) or
        (not na(priceChange[2]) and priceChange[2] >= stallPriorGain)
    )
)

bool rawStalling = (
    signalBar and
    enableStalling and
    hasPreviousBar and
    volumeHigher and
    not na(priceChange) and
    priceChange > 0 and
    priceChange <= stallMaxGain and
    closePosition < stallClosePosition and
    priorProgressOk
)


// ============================================================================
// MARKET STATE
// ============================================================================

var int marketState = STATE_CORRECTION

var float rallyLow = na
var int rallyLowBar = na

var int rallyDay = 0
var int rallyStartBar = na

var int ftdBar = na
var int ftdRallyDay = na

var float ftdClose = na
var float ftdLow = na

var bool ftdLowBreached = false

var string lastEvent = "Initializing"


// ============================================================================
// ONE-BAR EVENT FLAGS
// ============================================================================

bool eventRallyStart = false
bool eventRallyFail = false

bool eventFtd = false
bool eventFtdLowUndercut = false

bool eventPostFtdDistribution = false
bool eventModelCorrection = false


// ============================================================================
// CORRECTION LOW TRACKING
// ============================================================================

if marketState == STATE_CORRECTION and confirmedContextBar
    if na(rallyLow) or low < rallyLow
        rallyLow := low
        rallyLowBar := bar_index


// ============================================================================
// START RALLY ATTEMPT
// ============================================================================

bool startRally = (
    signalBar and
    marketState == STATE_CORRECTION and
    hasPreviousBar and
    close > close[1] and
    not na(rallyLow) and
    low >= rallyLow
)

if startRally
    marketState := STATE_RALLY
    rallyDay := 1
    rallyStartBar := bar_index

    array.clear(dDays)

    ftdBar := na
    ftdRallyDay := na
    ftdClose := na
    ftdLow := na
    ftdLowBreached := false

    eventRallyStart := true
    lastEvent := "Rally Attempt Day 1"


// ============================================================================
// EXISTING RALLY ATTEMPT
// ============================================================================

if signalBar and marketState == STATE_RALLY and not eventRallyStart

    bool rallyFailed = (
        rallyFailureMethod == "Intraday Low"
        ? low < rallyLow
        : close < rallyLow
    )

    if rallyFailed

        eventRallyFail := true

        marketState := STATE_CORRECTION

        rallyDay := 0
        rallyStartBar := na

        rallyLow := low
        rallyLowBar := bar_index

        array.clear(dDays)

        ftdBar := na
        ftdRallyDay := na
        ftdClose := na
        ftdLow := na
        ftdLowBreached := false

        lastEvent := "Rally Attempt Failed"

    else

        rallyDay += 1

        bool ftdVolumeOk = not requireHigherVolume or volumeHigher

        bool ftdCandidate = (
            rallyDay >= minRallyDays and
            not na(priceChange) and
            priceChange >= ftdThreshold and
            ftdVolumeOk
        )

        if ftdCandidate

            eventFtd := true

            marketState := STATE_CONFIRMED

            ftdBar := bar_index
            ftdRallyDay := rallyDay

            ftdClose := close
            ftdLow := low

            ftdLowBreached := false

            // New FTD starts a fresh Distribution Day count.
            array.clear(dDays)

            lastEvent := "FTD - Rally Day " + str.tostring(ftdRallyDay)


// ============================================================================
// DISTRIBUTION ENGINE
// ============================================================================

bool countedDownDistribution = marketState == STATE_CONFIRMED and rawDownDistribution

bool countedStalling = marketState == STATE_CONFIRMED and rawStalling

bool countedDistributionEvent = countedDownDistribution or countedStalling


// ============================================================================
// REMOVE EXPIRED / NEGATED EVENTS
// ============================================================================

if signalBar and marketState == STATE_CONFIRMED and array.size(dDays) > 0

    int i = array.size(dDays) - 1

    while i >= 0

        DDay d = array.get(dDays, i)

        bool ageExpired = bar_index - d.bar >= distExpiration

        bool recoveryNegated = close >= d.closePrice * (1.0 + distNegation)

        if ageExpired or recoveryNegated
            array.remove(dDays, i)

        i -= 1


// ============================================================================
// ADD TODAY'S DISTRIBUTION EVENT
// ============================================================================

if countedDistributionEvent

    DDay newDDay = DDay.new(
        bar_index,
        close,
        countedStalling
    )

    array.push(dDays, newDDay)

    if countedStalling
        lastEvent := "Stalling Approximation"
    else
        lastEvent := "Distribution Day"


// ============================================================================
// COUNT ACTIVE DISTRIBUTION EVENTS
// ============================================================================

int activeDistCount = 0
int activeStallCount = 0

if marketState == STATE_CONFIRMED and array.size(dDays) > 0

    for i = 0 to array.size(dDays) - 1

        DDay d = array.get(dDays, i)

        if d.isStall
            activeStallCount += 1
        else
            activeDistCount += 1

int activeTotalCount = activeDistCount + activeStallCount


// ============================================================================
// FTD AGE
// ============================================================================

int ftdAge = (
    marketState == STATE_CONFIRMED and not na(ftdBar)
    ? bar_index - ftdBar
    : na
)


// ============================================================================
// FTD LOW UNDERCUT
// ============================================================================

if (
    signalBar and
    marketState == STATE_CONFIRMED and
    trackFtdLowUndercut and
    not ftdLowBreached and
    not na(ftdBar) and
    bar_index > ftdBar and
    not na(ftdLow) and
    low < ftdLow
)

    ftdLowBreached := true
    eventFtdLowUndercut := true
    lastEvent := "FTD Low Undercut"


// ============================================================================
// EARLY POST-FTD DISTRIBUTION WARNING
// ============================================================================

if (
    countedDistributionEvent and
    not na(ftdAge) and
    ftdAge >= 1 and
    ftdAge <= postFtdWarningBars
)

    eventPostFtdDistribution := true
    lastEvent := "Early Post-FTD Selling"


// ============================================================================
// HEURISTIC CONFIRMED UPTREND -> CORRECTION
// ============================================================================

bool resetForFtdUndercut = (
    marketState == STATE_CONFIRMED and
    resetOnFtdLowUndercut and
    eventFtdLowUndercut
)

bool resetForPressure = (
    marketState == STATE_CONFIRMED and
    enablePressureReset and
    activeTotalCount >= modelCorrectionCount
)

if signalBar and (resetForFtdUndercut or resetForPressure)

    eventModelCorrection := true

    marketState := STATE_CORRECTION

    rallyLow := low
    rallyLowBar := bar_index

    rallyDay := 0
    rallyStartBar := na

    ftdBar := na
    ftdRallyDay := na

    ftdClose := na
    ftdLow := na
    ftdLowBreached := false

    array.clear(dDays)

    activeDistCount := 0
    activeStallCount := 0
    activeTotalCount := 0

    lastEvent := (
        resetForFtdUndercut
        ? "Model Correction - FTD Low"
        : "Model Correction - Selling Pressure"
    )


// ============================================================================
// STATE / DASHBOARD TEXT
// ============================================================================

string marketStateText = (
    marketState == STATE_CORRECTION
    ? "CORRECTION"
    : marketState == STATE_RALLY
      ? "RALLY ATTEMPT"
      : "CONFIRMED UPTREND"
)

color marketStateColor = (
    marketState == STATE_CORRECTION
    ? color.red
    : marketState == STATE_RALLY
      ? color.orange
      : color.green
)

string rallyStatusText = (
    marketState == STATE_RALLY
    ? "Day " + str.tostring(rallyDay)
    : "—"
)

string ftdStatusText = (
    marketState == STATE_CONFIRMED and not na(ftdRallyDay)
    ? "Day " + str.tostring(ftdRallyDay)
    : "—"
)

string ftdAgeText = (
    marketState == STATE_CONFIRMED and not na(ftdAge)
    ? str.tostring(ftdAge) + " bars"
    : "—"
)

string pressureText = (
    marketState != STATE_CONFIRMED
    ? "—"
    : activeTotalCount >= modelCorrectionCount
      ? "RESET LEVEL"
      : activeTotalCount >= 5
        ? "HIGH"
        : activeTotalCount >= 3
          ? "BUILDING"
          : "LOW"
)

color pressureColor = (
    marketState != STATE_CONFIRMED
    ? color.gray
    : activeTotalCount >= modelCorrectionCount
      ? color.red
      : activeTotalCount >= 5
        ? color.orange
        : activeTotalCount >= 3
          ? color.yellow
          : color.green
)

string timeframeText = isOneDay ? "1D OK" : "USE 1D"

color timeframeColor = isOneDay ? color.green : color.red


// ============================================================================
// BACKGROUND HIGHLIGHTS
// ============================================================================

color signalBackground = (
    eventFtd
    ? color.new(color.lime, 80)
    : countedDownDistribution
      ? color.new(color.red, 84)
      : countedStalling
        ? color.new(color.orange, 86)
        : eventRallyStart
          ? color.new(color.aqua, 88)
          : na
)

bgcolor(
    signalBackground,
    title = "Market Direction Signals"
)


// ============================================================================
// OPTIONAL BAR COLOR
// ============================================================================

color barSignalColor = (
    eventFtd
    ? color.lime
    : countedDownDistribution
      ? color.red
      : countedStalling
        ? color.orange
        : eventRallyStart
          ? color.aqua
          : na
)

barcolor(colorBars ? barSignalColor : na)


// ============================================================================
// SIGNAL MARKERS
// ============================================================================

plotshape(
    showDLabels and countedDownDistribution,
    title = "Distribution Day",
    style = shape.labeldown,
    location = location.abovebar,
    color = color.red,
    text = "D",
    textcolor = color.white,
    size = size.tiny
)

plotshape(
    showStallLabels and countedStalling,
    title = "Stalling Approximation",
    style = shape.labeldown,
    location = location.abovebar,
    color = color.orange,
    text = "S",
    textcolor = color.white,
    size = size.tiny
)

plotshape(
    showRallyLabels and eventRallyStart,
    title = "Rally Attempt Day 1",
    style = shape.labelup,
    location = location.belowbar,
    color = color.aqua,
    text = "R1",
    textcolor = color.black,
    size = size.tiny
)

plotshape(
    showFtdLabels and eventFtd,
    title = "Follow-Through Day",
    style = shape.labelup,
    location = location.belowbar,
    color = color.lime,
    text = "FTD",
    textcolor = color.black,
    size = size.small
)

plotshape(
    showWarningLabels and eventFtdLowUndercut,
    title = "FTD Low Undercut",
    style = shape.labeldown,
    location = location.abovebar,
    color = color.fuchsia,
    text = "FTD LOW",
    textcolor = color.white,
    size = size.tiny
)

plotshape(
    showWarningLabels and eventPostFtdDistribution,
    title = "Early Post-FTD Distribution",
    style = shape.circle,
    location = location.top,
    color = color.yellow,
    size = size.tiny
)

plotshape(
    showResetLabels and eventModelCorrection,
    title = "Model Correction",
    style = shape.labeldown,
    location = location.abovebar,
    color = color.maroon,
    text = "MODEL\nCORR",
    textcolor = color.white,
    size = size.small
)


// ============================================================================
// RALLY LOW
// ============================================================================

plot(
    showRallyLow and marketState == STATE_RALLY ? rallyLow : na,
    title = "Rally Low",
    color = color.new(color.teal, 10),
    linewidth = 2,
    style = plot.style_linebr
)


// ============================================================================
// ACTIVE FTD LOW
// ============================================================================

plot(
    showFtdLow and marketState == STATE_CONFIRMED and not na(ftdLow) ? ftdLow : na,
    title = "FTD Low",
    color = color.new(color.fuchsia, 20),
    linewidth = 1,
    style = plot.style_linebr
)


// ============================================================================
// DASHBOARD POSITION
// ============================================================================

string dashboardPosition = (
    dashboardVerticalInput == "Top" and dashboardHorizontalInput == "Left" ? position.top_left :
    dashboardVerticalInput == "Top" and dashboardHorizontalInput == "Center" ? position.top_center :
    dashboardVerticalInput == "Top" and dashboardHorizontalInput == "Right" ? position.top_right :
    dashboardVerticalInput == "Middle" and dashboardHorizontalInput == "Left" ? position.middle_left :
    dashboardVerticalInput == "Middle" and dashboardHorizontalInput == "Center" ? position.middle_center :
    dashboardVerticalInput == "Middle" and dashboardHorizontalInput == "Right" ? position.middle_right :
    dashboardVerticalInput == "Bottom" and dashboardHorizontalInput == "Left" ? position.bottom_left :
    dashboardVerticalInput == "Bottom" and dashboardHorizontalInput == "Center" ? position.bottom_center :
    position.bottom_right
)


// ============================================================================
// DASHBOARD
// ============================================================================

var table dashboard = table.new(
    dashboardPosition,
    2,
    13,
    bgcolor = color.new(color.black, 15),
    frame_color = color.new(color.gray, 40),
    frame_width = 1,
    border_color = color.new(color.gray, 65),
    border_width = 1
)

if barstate.isfirst
    table.merge_cells(
        dashboard,
        0,
        12,
        1,
        12
    )


// ============================================================================
// DRAW DASHBOARD
// ============================================================================

if showDashboard and barstate.islast

    table.set_position(
        dashboard,
        dashboardPosition
    )

    // Header
    table.cell(
        dashboard,
        0,
        0,
        "MARKET DIRECTION",
        text_color = color.white,
        bgcolor = color.navy,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        0,
        "v8.2",
        text_color = color.white,
        bgcolor = color.navy,
        text_size = dashboardTextSizeInput
    )

    // Timeframe
    table.cell(
        dashboard,
        0,
        1,
        "Timeframe",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        1,
        timeframeText,
        text_color = color.white,
        bgcolor = timeframeColor,
        text_size = dashboardTextSizeInput
    )

    // Model State
    table.cell(
        dashboard,
        0,
        2,
        "Model State",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        2,
        marketStateText,
        text_color = color.white,
        bgcolor = marketStateColor,
        text_size = dashboardTextSizeInput
    )

    // Rally Attempt
    table.cell(
        dashboard,
        0,
        3,
        "Rally Attempt",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        3,
        rallyStatusText,
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    // Rally Low
    table.cell(
        dashboard,
        0,
        4,
        "Rally Low",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        4,
        marketState == STATE_RALLY and not na(rallyLow) ? str.tostring(rallyLow, format.mintick) : "—",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    // FTD
    table.cell(
        dashboard,
        0,
        5,
        "FTD",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        5,
        ftdStatusText,
        text_color = color.white,
        bgcolor = marketState == STATE_CONFIRMED ? color.green : color.gray,
        text_size = dashboardTextSizeInput
    )

    // FTD Age
    table.cell(
        dashboard,
        0,
        6,
        "FTD Age",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        6,
        ftdAgeText,
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    // Distribution
    table.cell(
        dashboard,
        0,
        7,
        "Distribution",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        7,
        str.tostring(activeDistCount),
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    // Stalling
    table.cell(
        dashboard,
        0,
        8,
        "Stalling Approx.",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        8,
        str.tostring(activeStallCount),
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    // Total Pressure
    table.cell(
        dashboard,
        0,
        9,
        "Total Pressure",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        9,
        str.tostring(activeTotalCount),
        text_color = color.white,
        bgcolor = pressureColor,
        text_size = dashboardTextSizeInput
    )

    // Model Pressure
    table.cell(
        dashboard,
        0,
        10,
        "Model Pressure",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        10,
        pressureText,
        text_color = color.white,
        bgcolor = pressureColor,
        text_size = dashboardTextSizeInput
    )

    // Last Event
    table.cell(
        dashboard,
        0,
        11,
        "Last Event",
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    table.cell(
        dashboard,
        1,
        11,
        lastEvent,
        text_color = color.white,
        text_size = dashboardTextSizeInput
    )

    // Footer
    table.cell(
        dashboard,
        0,
        12,
        "CANSLIM Research | canslim.blog",
        text_color = color.silver,
        bgcolor = color.new(color.black, 5),
        text_size = dashboardTextSizeInput,
        text_halign = text.align_center
    )


// ============================================================================
// CLEAR DASHBOARD WHEN DISABLED
// ============================================================================

if not showDashboard and barstate.islast

    table.clear(
        dashboard,
        0,
        0,
        1,
        12
    )


// ============================================================================
// ALERTS
// ============================================================================

alertcondition(
    enableAlerts and countedDownDistribution,
    title = "Distribution Day",
    message = "Confirmed Distribution Day detected."
)

alertcondition(
    enableAlerts and countedStalling,
    title = "Stalling Approximation",
    message = "Confirmed public-rule Stalling approximation detected."
)

alertcondition(
    enableAlerts and eventRallyStart,
    title = "Rally Attempt Day 1",
    message = "A new Rally Attempt Day 1 has been detected."
)

alertcondition(
    enableAlerts and eventRallyFail,
    title = "Rally Attempt Failed",
    message = "The current Rally Attempt has failed."
)

alertcondition(
    enableAlerts and eventFtd,
    title = "Follow-Through Day",
    message = "A Follow-Through Day has been detected."
)

alertcondition(
    enableAlerts and eventPostFtdDistribution,
    title = "Early Post-FTD Selling",
    message = "Distribution or Stalling appeared inside the early post-FTD warning window."
)

alertcondition(
    enableAlerts and eventFtdLowUndercut,
    title = "FTD Low Undercut",
    message = "The market traded below the Follow-Through Day low."
)

alertcondition(
    enableAlerts and eventModelCorrection,
    title = "Distribution & Follow Thru Day Counter",
    message = "The independent heuristic model has reset to Correction."
)


// ============================================================================
// DATA WINDOW / DEBUG OUTPUTS
// ============================================================================

plot(
    activeTotalCount,
    title = "Active Selling Pressure Count",
    display = display.data_window,
    color = color.new(color.red, 100)
)

plot(
    marketState == STATE_RALLY ? rallyDay : 0,
    title = "Rally Day",
    display = display.data_window,
    color = color.new(color.blue, 100)
)

plot(
    eventFtd ? 1 : 0,
    title = "FTD Signal",
    display = display.data_window,
    color = color.new(color.green, 100)
)
````
