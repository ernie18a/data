# IFVG + OB Backtesting Assistance

- url: https://www.tradingview.com/script/YmhCPN4r-IFVG-OB-Backtesting-Assistance/
- type: indicator
- pine_id: PUB;28d2e187b9034ff9aa8a29a3f69cc667
- version: 1.0

## Description

[b] IFVG + OB Backtesting Assistant[/b]

## Overview

IFVG + OB Backtesting Assistant is a historical market-analysis indicator designed to identify, visualize, and evaluate trading opportunities originating from Inverse Fair Value Gaps (IFVGs) and Order Blocks (OBs).

The indicator combines two independent price-action models into a unified research environment, allowing traders to examine historical entry locations, originating price zones, and subsequent price behavior relative to configurable take-profit and stop-loss levels.

Its primary purpose is to facilitate retrospective opportunity analysis, visual backtesting, and systematic research into price-action setups.

## Methodology

**1. First-Active Inverse Fair Value Gap (IFVG)**

The IFVG model monitors the formation of fair value gaps and identifies qualifying inversions when price closes beyond the relevant gap boundary.

Once an eligible inverted zone is established, the model monitors the first qualifying interaction with the selected entry level.

Users can configure entry evaluation at either the zone boundary or Consequent Encroachment (the midpoint of the gap).

The model includes controls for minimum gap size, zone age, consecutive gap qualification, and invalidation.

**2. First-Active Order Block (OB)**

The Order Block model identifies qualifying groups of consecutive directional candles and evaluates subsequent displacement and price interaction.

The model applies configurable conditions involving candle-group structure, directional closes, displacement efficiency, and body size.

Qualifying Order Blocks are monitored for their first eligible entry interaction, subject to the selected validity conditions.

These models operate independently, allowing historical IFVG and OB opportunities to be examined separately or together.

## Historical Opportunity Visualization

The indicator preserves the originating price-zone coordinates associated with each identified opportunity.

Once a candidate reaches its configured take-profit or stop-loss level, the corresponding outcome can be displayed retrospectively at the original entry location.

Available visualization features include:

- Historical IFVG and Order Block source zones.
- Independent winning and losing opportunity displays.
- Optional take-profit and stop-loss visualization.
- Configurable zone boundaries and reference lines.
- Adjustable source-zone extensions.
- Optional price labels and zone identification tags.

Winning opportunities are enabled by default. Losing opportunities can be enabled independently for each model.

Text labels and identification tags are disabled by default to minimize chart congestion.

## Session Configuration

Both models use shared, customizable time windows.

- **State-Tracking Session:** Default **07:00–16:00**, New York time.
- **Entry/Validation Session:** Default **09:30–16:00**, New York time.

The state-tracking session determines when qualifying structures are monitored, while the entry session determines when candidate entries may be registered.

This arrangement supports the analysis of structures formed before the selected execution window.

The indicator is designed for use on the **1-minute chart**.

## Daily Opportunity Analytics

An integrated daily performance table summarizes historical opportunity outcomes separately for bullish and bearish IFVG and OB models.

The table includes:

- Winning opportunities and modeled winning P&L.
- Losing opportunities and modeled losing P&L.
- Combined displayed net P&L.
- Individual model and directional breakdowns.

Users can configure the target distance, stop-loss distance, contract quantity, and monetary value per point.

The calculations represent hypothetical outcomes based on the selected parameters, not verified brokerage transactions.

The table counts retained, displayed outcomes. Disabling opportunity categories or reaching historical drawing limits can affect the reported totals.

## Important Limitations

**This is a retrospective opportunity-analysis indicator, not an automated trading strategy.**

Historical opportunity zones and markers are displayed after their associated outcomes become known. They may be drawn backward onto the original entry candles and must not be interpreted as signals that were necessarily visible or confirmed at those earlier moments.

During Bar Replay, historical opportunities may remain absent until sufficient subsequent price data is available to determine their outcomes.

When take-profit and stop-loss prices are both touched within the same evaluation candle, the selected ambiguity-handling rule determines whether the observation is excluded or classified.

Unresolved or expired candidates are not automatically classified as successful or unsuccessful trades.

The indicator does not execute orders or simulate brokerage fills. Its modeled P&L excludes trading costs, commissions, slippage, execution latency, and other real-world execution constraints.

Historical observations do not establish future predictive accuracy or profitability.

## Intended Use

IFVG + OB Backtesting Assistant is intended for traders conducting historical price-action research, reviewing market behavior around qualifying IFVG and Order Block structures, and investigating how different entry and risk parameters affect observed opportunities.

Its distinguishing functionality is the combination of independent first-active zone detection, preserved historical source-zone geometry, configurable outcome classification, and session-based opportunity analytics within a single charting tool.

All results should be independently evaluated before being incorporated into a trading methodology.

## Source Code

````pine
//@version=6
indicator("IFVG + OB Backtesting Assistance", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// Original IFVG + OB opportunity detection, validation and TP/SL drawing are retained.
// No wick module. Retains the supplied IFVG + OB state machines, entry rules and source-zone coordinates.
// Each entry candidate snapshots the exact originating source-zone coordinates.
// Confirmed TP winners display their source zone retrospectively, from
// the original IFVG/FVG or OB candle through N bars after the ENTRY candle.
// Optional stop-loss zones use the same frozen origin geometry. No new entry path.
// Zone appearance adapted from the supplied IFVG V4.1 and OB V3.4 indicators.

string GRP_SESSION = "01 — SHARED IFVG + OB SESSIONS"
string GRP_TOP = "02 — CONTROL PANEL"
string GRP_H1 = "03 — HOURS 00–07"
string GRP_H2 = "04 — HOURS 08–15"
string GRP_H3 = "05 — HOURS 16–23"
string GRP_IFVG = "06 — FIRST-ACTIVE IFVG"
string GRP_OB = "07 — FIRST-ACTIVE ORDER BLOCK"
string GRP_OUT = "08 — HISTORICAL VALIDATION"
string GRP_IFVGVIS = "09 — IFVG ZONE VISUALS"
string GRP_OBVIS = "10 — ORDER BLOCK ZONE VISUALS"
string GRP_TABLE = "11 — DAILY PERFORMANCE TABLE"

// Shared session control: ONE tracking interval and ONE entry interval for BOTH models.
// Pre-entry state is retained, but neither engine may create entries outside
// the shared entry interval. Hours are interpreted in New York time.
string statsTimezone = input.string("America/New_York", "Session / Statistics Timezone", group = GRP_SESSION)
string ifvgStateSession = input.session("0700-1600", "IFVG + OB State-Tracking Session", group = GRP_SESSION,
     tooltip = "Both IFVG conversions and OB candle groups are monitored only within this session. Both inventories reset at the next state-session opening.")
string ifvgEntrySession = input.session("0930-1600", "IFVG + OB Entry / Validation Session", group = GRP_SESSION,
     tooltip = "Shared start and end time for IFVG first-touch entries and OB body-touch entries. Tracking can begin earlier.")

int targetSelection = input.int(
     55,
     "Target Points",
     options = [55, 71, 81, 91, 106, 155, 205],
     group = GRP_TOP)

float targetPts = float(targetSelection)

float stopPts = input.float(
     20.0,
     "Outcome Stop Distance",
     minval = 0.25,
     step = 0.25,
     group = GRP_TOP)


string pnlInstrumentMode = input.string(
     "Auto",
     "Potential Profit Instrument",
     options = ["Auto", "MNQ", "NQ", "Custom"],
     tooltip = "Auto uses TradingView's contract point value. MNQ = $2/point. NQ = $20/point.",
     group = GRP_TOP)

int contractQuantity = input.int(
     1,
     "Contract Quantity",
     minval = 1,
     maxval = 100,
     tooltip = "Number of MNQ or NQ contracts used for potential winner value (not realized P&L).",
     group = GRP_TOP)

float customDollarsPerPoint = input.float(
     2.0,
     "Custom $ Per Point / Contract",
     minval = 0.01,
     step = 0.25,
     tooltip = "Used only when P&L Instrument is Custom.",
     group = GRP_TOP)

float autoPointValue = nz(syminfo.pointvalue, customDollarsPerPoint)

float dollarsPerPoint = autoPointValue

if pnlInstrumentMode == "MNQ"
    dollarsPerPoint := 2.0
else if pnlInstrumentMode == "NQ"
    dollarsPerPoint := 20.0
else if pnlInstrumentMode == "Custom"
    dollarsPerPoint := customDollarsPerPoint

string detectedInstrument = syminfo.root

if syminfo.root == "MNQ"
    detectedInstrument := "MNQ"
else if syminfo.root == "NQ"
    detectedInstrument := "NQ"

string pnlInstrumentText = pnlInstrumentMode

if pnlInstrumentMode == "Auto"
    pnlInstrumentText := "AUTO " + detectedInstrument


// --------------------------------------------------------------------------
// DISPLAY MODE
// --------------------------------------------------------------------------

bool showIFVGMode = input.bool(
     true,
     "IFVG",
     inline = "MODE",
     group = GRP_TOP)

bool showOBMode = input.bool(
     true,
     "Order Block",
     inline = "MODE",
     group = GRP_TOP)

bool showBullish = input.bool(
     true,
     "Bullish",
     inline = "DIR",
     group = GRP_TOP)

bool showBearish = input.bool(
     true,
     "Bearish",
     inline = "DIR",
     group = GRP_TOP)

// All three dimensions are DISPLAY filters, never entry-model filters.
bool showWinningIFVG = input.bool(true, "Winning IFVG", inline = "WIN", group = GRP_TOP)
bool showWinningOB = input.bool(true, "Winning OB", inline = "WIN", group = GRP_TOP)


// --------------------------------------------------------------------------
// HOURLY DISPLAY CAPS
// --------------------------------------------------------------------------

int maxBullVisiblePerHour = input.int(
     0,
     "Max Bullish Winners / Hour — 0 = Unlimited",
     minval = 0,
     maxval = 100,
     group = GRP_TOP)

int maxBearVisiblePerHour = input.int(
     0,
     "Max Bearish Winners / Hour — 0 = Unlimited",
     minval = 0,
     maxval = 100,
     group = GRP_TOP)


// --------------------------------------------------------------------------
// VISUALS
// --------------------------------------------------------------------------

bool showTPSLBoxes = input.bool(
     false,
     "Show TP / SL Boxes",
     group = GRP_TOP)

color tpBoxColor = input.color(
     color.new(color.green, 82),
     "TP Box Color",
     group = GRP_TOP)

color slBoxColor = input.color(
     color.new(color.red, 88),
     "SL Box Color",
     group = GRP_TOP)

bool showWinnerVerticalLines = input.bool(
     true,
     "Show Winner Vertical Lines",
     group = GRP_TOP)

color bullishWinnerLineColor = input.color(
     color.green,
     "Bullish Winner Line",
     group = GRP_TOP)

color bearishWinnerLineColor = input.color(
     color.red,
     "Bearish Winner Line",
     group = GRP_TOP)

int winnerLineWidth = input.int(
     1,
     "Winner Line Width",
     minval = 1,
     maxval = 4,
     group = GRP_TOP)

bool showLosingIFVG = input.bool(false, "Losing IFVG", inline = "LOSE", group = GRP_TOP)
bool showLosingOB = input.bool(false, "Losing OB", inline = "LOSE", group = GRP_TOP)
color losingMarkerColor = input.color(color.rgb(186, 56, 64), "Losing Opportunity Color", group = GRP_TOP)


// ============================================================================
// 02–04 — DISPLAY HOUR CHECKBOXES
// ============================================================================

bool showH00 = input.bool(true, "00", inline = "H0003", group = GRP_H1)
bool showH01 = input.bool(true, "01", inline = "H0003", group = GRP_H1)
bool showH02 = input.bool(true, "02", inline = "H0003", group = GRP_H1)
bool showH03 = input.bool(true, "03", inline = "H0003", group = GRP_H1)

bool showH04 = input.bool(true, "04", inline = "H0407", group = GRP_H1)
bool showH05 = input.bool(true, "05", inline = "H0407", group = GRP_H1)
bool showH06 = input.bool(true, "06", inline = "H0407", group = GRP_H1)
bool showH07 = input.bool(true, "07", inline = "H0407", group = GRP_H1)

bool showH08 = input.bool(true, "08", inline = "H0811", group = GRP_H2)
bool showH09 = input.bool(true, "09", inline = "H0811", group = GRP_H2)
bool showH10 = input.bool(true, "10", inline = "H0811", group = GRP_H2)
bool showH11 = input.bool(true, "11", inline = "H0811", group = GRP_H2)

bool showH12 = input.bool(true, "12", inline = "H1215", group = GRP_H2)
bool showH13 = input.bool(true, "13", inline = "H1215", group = GRP_H2)
bool showH14 = input.bool(true, "14", inline = "H1215", group = GRP_H2)
bool showH15 = input.bool(true, "15", inline = "H1215", group = GRP_H2)

bool showH16 = input.bool(true, "16", inline = "H1619", group = GRP_H3)
bool showH17 = input.bool(true, "17", inline = "H1619", group = GRP_H3)
bool showH18 = input.bool(true, "18", inline = "H1619", group = GRP_H3)
bool showH19 = input.bool(true, "19", inline = "H1619", group = GRP_H3)

bool showH20 = input.bool(true, "20", inline = "H2023", group = GRP_H3)
bool showH21 = input.bool(true, "21", inline = "H2023", group = GRP_H3)
bool showH22 = input.bool(true, "22", inline = "H2023", group = GRP_H3)
bool showH23 = input.bool(true, "23", inline = "H2023", group = GRP_H3)


// ============================================================================
// 05 — FIRST-ACTIVE IFVG
// ============================================================================

float ifvgMinGap = input.float(
     0.75,
     "Minimum 1M Source FVG Size",
     minval = 0.25,
     step = 0.25,
     group = GRP_IFVG)

string ifvgTouchMode = input.string(
     "Boundary",
     "IFVG Entry Level",
     options = ["Boundary", "Consequent Encroachment"],
     group = GRP_IFVG)

int ifvgMaxAgeMinutes = input.int(
     0,
     "Maximum IFVG Age For First Entry — 0 = Disabled",
     options = [0, 15, 30, 60],
     tooltip = "0 preserves the supplied First-Active V4.1 lifecycle: the active IFVG remains eligible until invalidated, replaced by a genuinely new source-FVG run, or the state session ends.",
     group = GRP_IFVG)


// ============================================================================
// 06 — FIRST-PER-CYCLE ORDER BLOCK
// ============================================================================

int obGroupsToTrack = input.int(
     5,
     "Candidate Groups To Track",
     options = [1, 2, 3, 4, 5, 6, 7],
     group = GRP_OB)

int obMinGroupSize = input.int(
     2,
     "Minimum Consecutive Candles",
     minval = 2,
     maxval = 4,
     group = GRP_OB)

float obMinBodySize = input.float(
     1.0,
     "Minimum First-Candle Body Size",
     minval = 1.0,
     step = 0.25,
     group = GRP_OB)

bool obRequireProgressiveCloses = input.bool(
     true,
     "Require Progressive Group Closes",
     group = GRP_OB)

int obMinDirectionalCloses = input.int(
     2,
     "Minimum Directional Closing Steps",
     minval = 1,
     maxval = 20,
     group = GRP_OB)

float obMinDirectionalCloseRatio = input.float(
     0.60,
     "Minimum Directional-Close Ratio",
     minval = 0.0,
     maxval = 1.0,
     step = 0.05,
     group = GRP_OB)

float obMinEfficiency = input.float(
     0.55,
     "Minimum Displacement Efficiency",
     minval = 0.0,
     maxval = 1.0,
     step = 0.05,
     group = GRP_OB)

string obInvalidationReference = input.string(
     "Body Entry",
     "OB Validity Stop Reference",
     options = ["Body Entry", "Order Block Threshold"],
     group = GRP_OB)

int obMaxAgeMinutes = input.int(
     30,
     "Maximum OB Age For First Entry",
     options = [15, 30, 60],
     group = GRP_OB)


// ============================================================================
// 07 — VALIDATION
// ============================================================================

string sameBarPolicy = input.string(
     "Reject ambiguous",
     "If TP And SL Occur On Same 1M Bar",
     options = ["Reject ambiguous", "TP wins", "SL wins"],
     group = GRP_OUT)

int maxPending = input.int(
     300,
     "Maximum Unresolved Candidates",
     minval = 25,
     maxval = 1000,
     group = GRP_OUT)

int maxAgeBars = input.int(
     1440,
     "Maximum Candidate Lifetime In Bars",
     minval = 1,
     maxval = 10000,
     group = GRP_OUT)

int maxDisplayedWins = input.int(
     220,
     "Maximum Retained Winner Drawings",
     minval = 10,
     maxval = 240,
     group = GRP_OUT)



int maxDisplayedLosses = input.int(150, "Maximum Retained Loss Markers", minval = 10, maxval = 200, group = GRP_OUT)
int obMaxGroupSize = 4

// ============================================================================
// INPUTS — PASSIVE ZONE VISUALS ONLY
// ============================================================================

bool showIFVGZones = input.bool(true, "Show WINNING IFVG Source Zones", group = GRP_IFVGVIS)
color bullIFVGColor = input.color(color.rgb(0, 139, 170), "Bullish IFVG", group = GRP_IFVGVIS)
color bearIFVGColor = input.color(color.rgb(132, 78, 170), "Bearish IFVG", group = GRP_IFVGVIS)
int ifvgFillAlpha = input.int(87, "Fill Transparency", minval = 0, maxval = 100, group = GRP_IFVGVIS)
int ifvgBorderAlpha = input.int(18, "Border Transparency", minval = 0, maxval = 100, group = GRP_IFVGVIS)
int ifvgBorderWidth = input.int(1, "Border Width", minval = 0, maxval = 4, group = GRP_IFVGVIS)
string ifvgBoxAnchor = input.string("First FVG candle", "Zone Start", options = ["First FVG candle", "FVG end candle"], group = GRP_IFVGVIS)
bool showIFVGCE = input.bool(true, "Show IFVG CE Line", group = GRP_IFVGVIS)
color ifvgCEColor = input.color(color.yellow, "IFVG CE Line", group = GRP_IFVGVIS)
int ifvgCEWidth = input.int(2, "IFVG CE Width", minval = 1, maxval = 4, group = GRP_IFVGVIS)
string ifvgCEStyle = input.string("Solid", "IFVG CE Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_IFVGVIS)
bool showIFVGPrices = input.bool(false, "Boundary / CE Price Labels", group = GRP_IFVGVIS)
bool showIFVGText = input.bool(false, "Show IFVG Zone Text", group = GRP_IFVGVIS)
string ifvgPriceLabelPosition = input.string("Middle", "Price Label Position", options = ["Middle", "Right edge"], group = GRP_IFVGVIS)
int ifvgLabelGap = input.int(5, "CE Label Line Gap (Bars)", minval = 0, maxval = 30, group = GRP_IFVGVIS)

bool showOBZones = input.bool(true, "Show WINNING Order Block Source Zones", group = GRP_OBVIS)
color bullOBColor = input.color(color.green, "Bullish OB Body Entry", group = GRP_OBVIS)
color bearOBColor = input.color(color.red, "Bearish OB Body Entry", group = GRP_OBVIS)
color obThresholdColor = input.color(color.orange, "Order Block Threshold", group = GRP_OBVIS)
int obFillAlpha = input.int(91, "OB Fill Transparency", minval = 0, maxval = 100, group = GRP_OBVIS)
int obBorderAlpha = input.int(55, "OB Border Transparency", minval = 0, maxval = 100, group = GRP_OBVIS)
bool showOBBodyEntry = input.bool(true, "Show Body Entry Line", group = GRP_OBVIS)
bool showOBThreshold = input.bool(true, "Show Order Block Threshold", group = GRP_OBVIS)
bool showOBTag = input.bool(false, "Show Order Block Tag", group = GRP_OBVIS)
string obTagPosition = input.string("Middle", "Order Block Tag Position", options = ["Middle", "Right edge"], group = GRP_OBVIS)
int obTagGap = input.int(6, "Body Entry Line Gap Around Tag", minval = 2, maxval = 30, group = GRP_OBVIS)

// Global extension applies ONLY to the source-zone drawing, NOT to TP/SL.
int zoneBarsAfterEntry = input.int(7, "Extend Winning Source Zone N Bars After Entry", minval = 0, maxval = 500, group = GRP_OUT)
int maxWinningSourceZones = input.int(100, "Maximum Retained Source Zones (Wins + Losses)", minval = 1, maxval = 160,
     tooltip = "Safety-capped to respect TradingView's 500-box / 500-line / 500-label limits alongside TP/SL and loss drawings.", group = GRP_OUT)

bool showStatsTable = input.bool(
     true,
     "Show Daily Win / Loss P&L Table",
     group = GRP_TABLE)

string tablePositionInput = input.string(
     "Top Right",
     "Table Position",
     options = [
         "Top Right",
         "Top Left",
         "Middle Right",
         "Middle Left",
         "Bottom Right",
         "Bottom Left"
     ],
     group = GRP_TABLE)

string tableBodySizeInput = input.string(
     "Small",
     "Body Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GRP_TABLE)

string tableHeaderSizeInput = input.string(
     "Normal",
     "Header Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GRP_TABLE)

color tableAccent = input.color(
     color.rgb(74, 144, 226),
     "Table Accent",
     group = GRP_TABLE)

int tableTransparency = input.int(
     8,
     "Panel Transparency",
     minval = 0,
     maxval = 90,
     group = GRP_TABLE)


int MOD_IFVG = 1
int MOD_OB = 2
int MINUTE_MS = 60000
bool isOneMinuteChart = timeframe.isminutes and timeframe.multiplier == 1
bool inIfvgStateSession = isOneMinuteChart and not na(time(timeframe.period, ifvgStateSession, statsTimezone))
bool inIfvgEntrySession = isOneMinuteChart and not na(time(timeframe.period, ifvgEntrySession, statsTimezone))
bool ifvgStateSessionStart = inIfvgStateSession and not inIfvgStateSession[1]
bool ifvgStateSessionEnd = not inIfvgStateSession and inIfvgStateSession[1]

// ============================================================================
// HELPERS
// ============================================================================

f_pad2(int value) =>
    string result = str.tostring(value)
    if value < 10
        result := "0" + str.tostring(value)
    result


f_dayKey(int timestampValue) =>
    int yy = year(timestampValue, statsTimezone)
    int mm = month(timestampValue, statsTimezone)
    int dd = dayofmonth(timestampValue, statsTimezone)
    yy * 10000 + mm * 100 + dd


f_weekKey(int timestampValue) =>
    int yy = year(timestampValue, statsTimezone)
    int ww = weekofyear(timestampValue, statsTimezone)
    yy * 100 + ww


f_dateText(int timestampValue) =>
    string yy = str.tostring(year(timestampValue, statsTimezone))
    string mm = f_pad2(month(timestampValue, statsTimezone))
    string dd = f_pad2(dayofmonth(timestampValue, statsTimezone))
    yy + "-" + mm + "-" + dd


f_hourEnabled(int hourValue) =>
    bool enabled = false

    if hourValue == 0
        enabled := showH00
    else if hourValue == 1
        enabled := showH01
    else if hourValue == 2
        enabled := showH02
    else if hourValue == 3
        enabled := showH03
    else if hourValue == 4
        enabled := showH04
    else if hourValue == 5
        enabled := showH05
    else if hourValue == 6
        enabled := showH06
    else if hourValue == 7
        enabled := showH07
    else if hourValue == 8
        enabled := showH08
    else if hourValue == 9
        enabled := showH09
    else if hourValue == 10
        enabled := showH10
    else if hourValue == 11
        enabled := showH11
    else if hourValue == 12
        enabled := showH12
    else if hourValue == 13
        enabled := showH13
    else if hourValue == 14
        enabled := showH14
    else if hourValue == 15
        enabled := showH15
    else if hourValue == 16
        enabled := showH16
    else if hourValue == 17
        enabled := showH17
    else if hourValue == 18
        enabled := showH18
    else if hourValue == 19
        enabled := showH19
    else if hourValue == 20
        enabled := showH20
    else if hourValue == 21
        enabled := showH21
    else if hourValue == 22
        enabled := showH22
    else if hourValue == 23
        enabled := showH23

    enabled


f_moduleVisible(int moduleId) =>
    moduleId == MOD_IFVG ? showIFVGMode : moduleId == MOD_OB ? showOBMode : false

f_directionVisible(int direction) =>
    direction == 1 ? showBullish : showBearish

f_lossVisible(int setupTime, int moduleId, int direction) =>
    bool toggled = moduleId == MOD_IFVG ? showLosingIFVG : moduleId == MOD_OB ? showLosingOB : false
    toggled and f_moduleVisible(moduleId) and f_directionVisible(direction) and f_hourEnabled(hour(setupTime, statsTimezone))

// Internal closed-trade accounting is unchanged by optional drawings.
var array<int> dayBullWins = array.new_int(2, 0)
var array<int> dayBullLosses = array.new_int(2, 0)
var array<int> dayBearWins = array.new_int(2, 0)
var array<int> dayBearLosses = array.new_int(2, 0)
var int dayExcluded = 0
var int activeDayKey = na
int currentDayKey = f_dayKey(time)
if na(activeDayKey) or currentDayKey != activeDayKey
    activeDayKey := currentDayKey
    dayExcluded := 0
    for i = 0 to 1
        array.set(dayBullWins, i, 0)
        array.set(dayBullLosses, i, 0)
        array.set(dayBearWins, i, 0)
        array.set(dayBearLosses, i, 0)

f_recordOutcome(int moduleId, int direction, bool won) =>
    int idx = moduleId - 1
    if direction == 1
        if won
            array.set(dayBullWins, idx, array.get(dayBullWins, idx) + 1)
        else
            array.set(dayBullLosses, idx, array.get(dayBullLosses, idx) + 1)
    else
        if won
            array.set(dayBearWins, idx, array.get(dayBearWins, idx) + 1)
        else
            array.set(dayBearLosses, idx, array.get(dayBearLosses, idx) + 1)

f_cash(float value) =>
    (value < 0 ? "-$" : "$") + str.tostring(math.abs(value), "#,##0.00")


f_tablePosition(string positionInput) =>
    string result = position.top_right

    if positionInput == "Top Left"
        result := position.top_left
    else if positionInput == "Middle Right"
        result := position.middle_right
    else if positionInput == "Middle Left"
        result := position.middle_left
    else if positionInput == "Bottom Right"
        result := position.bottom_right
    else if positionInput == "Bottom Left"
        result := position.bottom_left

    result


f_textSize(string sizeInput) =>
    string result = size.small

    if sizeInput == "Tiny"
        result := size.tiny
    else if sizeInput == "Normal"
        result := size.normal
    else if sizeInput == "Large"
        result := size.large

    result


// ============================================================================
// DISPLAY QUOTA ENGINE
// ============================================================================

var array<int> displayBucketKeys = array.new_int()
var array<int> displayBucketCounts = array.new_int()


f_displayBucketKey(int setupTime, int direction) =>
    int dayValue = f_dayKey(setupTime)
    int hourValue = hour(setupTime, statsTimezone)
    int directionCode = 2

    if direction == 1
        directionCode := 1

    dayValue * 1000 + hourValue * 10 + directionCode


f_displayLimit(int direction) =>
    int result = maxBearVisiblePerHour

    if direction == 1
        result := maxBullVisiblePerHour

    result


f_displaySlotAvailable(int setupTime, int moduleId, int direction) =>
    int setupHour = hour(setupTime, statsTimezone)

    bool hourPass = f_hourEnabled(setupHour)
    bool modulePass = f_moduleVisible(moduleId) and (moduleId == MOD_IFVG ? showWinningIFVG : showWinningOB)
    bool directionPass = f_directionVisible(direction)
    bool drawable = showWinnerVerticalLines or showTPSLBoxes or (moduleId == MOD_IFVG ? showIFVGZones : showOBZones)

    int limitValue = f_displayLimit(direction)

    bool countPass = true

    if hourPass and modulePass and directionPass and limitValue > 0
        int key = f_displayBucketKey(setupTime, direction)
        int indexValue = array.indexof(displayBucketKeys, key)

        int used = 0

        if indexValue >= 0
            used := array.get(displayBucketCounts, indexValue)

        countPass := used < limitValue

    hourPass and modulePass and directionPass and countPass and drawable


f_reserveDisplaySlot(int setupTime, int direction) =>
    int limitValue = f_displayLimit(direction)

    if limitValue > 0
        int key = f_displayBucketKey(setupTime, direction)
        int indexValue = array.indexof(displayBucketKeys, key)

        if indexValue == -1
            array.push(displayBucketKeys, key)
            array.push(displayBucketCounts, 1)
        else
            array.set(displayBucketCounts, indexValue, array.get(displayBucketCounts, indexValue) + 1)


// ============================================================================
// CANDIDATE ENGINE
// ============================================================================

var array<int> candDir = array.new_int()

var array<float> candEntry = array.new_float()
var array<float> candTP = array.new_float()
var array<float> candSL = array.new_float()

var array<int> candSetupBar = array.new_int()
var array<int> candSetupTime = array.new_int()
var array<int> candStartBar = array.new_int()

var array<int> candModule = array.new_int()
var array<int> candZoneId = array.new_int()

// Source-zone snapshot at the precise entry, not a lookup of the currently active zone.
var array<int> candOriginBar = array.new_int()
var array<float> candZoneTop = array.new_float()
var array<float> candZoneBottom = array.new_float()
var array<float> candZoneEntryLine = array.new_float()
var array<float> candZoneCenterLine = array.new_float()


f_candidateExists(int moduleId, int setupBar, int direction, int zoneId) =>
    bool exists = false
    int count = array.size(candDir)

    if count > 0
        for i = 0 to count - 1
            bool sameCore =
                 array.get(candModule, i) == moduleId and
                 array.get(candSetupBar, i) == setupBar and
                 array.get(candDir, i) == direction

            bool sameZone = zoneId < 0 or array.get(candZoneId, i) == zoneId

            if sameCore and sameZone
                exists := true

    exists


f_addCandidate(int direction, float entry, int setupBar, int setupTime, int moduleId, int zoneId,
     int sourceStartBar, float zoneTop, float zoneBottom, float entryLine, float centerLine) =>
    bool added = false

    bool duplicate =
         f_candidateExists(
             moduleId,
             setupBar,
             direction,
             zoneId)

    if not duplicate and array.size(candDir) < maxPending
        float targetPrice = entry + targetPts
        float stopPrice = entry - stopPts

        if direction == -1
            targetPrice := entry - targetPts
            stopPrice := entry + stopPts

        array.push(candDir, direction)

        array.push(candEntry, entry)
        array.push(candTP, targetPrice)
        array.push(candSL, stopPrice)

        array.push(candSetupBar, setupBar)
        array.push(candSetupTime, setupTime)
        array.push(candStartBar, setupBar + 1)

        array.push(candModule, moduleId)
        array.push(candZoneId, zoneId)
        array.push(candOriginBar, sourceStartBar)
        array.push(candZoneTop, zoneTop)
        array.push(candZoneBottom, zoneBottom)
        array.push(candZoneEntryLine, entryLine)
        array.push(candZoneCenterLine, centerLine)

        added := true

    added


// ============================================================================
// DRAWINGS
// ============================================================================

var array<box> winnerTPBoxes = array.new_box()
var array<box> winnerSLBoxes = array.new_box()
var array<line> winnerLines = array.new_line()
var array<int> shownWinnerSetupTimes = array.new_int()
var array<int> shownWinnerDirections = array.new_int()
var array<int> shownWinnerModules = array.new_int()


f_trimDrawings() =>
    while array.size(winnerTPBoxes) > maxDisplayedWins
        box oldBox = array.shift(winnerTPBoxes)
        box.delete(oldBox)

    while array.size(winnerSLBoxes) > maxDisplayedWins
        box oldBox = array.shift(winnerSLBoxes)
        box.delete(oldBox)

    while array.size(winnerLines) > maxDisplayedWins
        line oldLine = array.shift(winnerLines)
        line.delete(oldLine)
    while array.size(shownWinnerSetupTimes) > maxDisplayedWins
        array.shift(shownWinnerSetupTimes)
        array.shift(shownWinnerDirections)
        array.shift(shownWinnerModules)


f_drawWinner(int direction, float entry, float targetPrice, float stopPrice, int setupBar, int setupTime, int targetHitBar, int moduleId) =>
    bool visible = f_displaySlotAvailable(setupTime, moduleId, direction)

    if visible
        f_reserveDisplaySlot(setupTime, direction)

        if showTPSLBoxes
            box tpBox = box.new(
                 left = setupBar,
                 top = math.max(entry, targetPrice),
                 right = targetHitBar,
                 bottom = math.min(entry, targetPrice),
                 xloc = xloc.bar_index,
                 bgcolor = tpBoxColor,
                 border_color = color.new(tpBoxColor, 0))

            box slBox = box.new(
                 left = setupBar,
                 top = math.max(entry, stopPrice),
                 right = targetHitBar,
                 bottom = math.min(entry, stopPrice),
                 xloc = xloc.bar_index,
                 bgcolor = slBoxColor,
                 border_color = color.new(slBoxColor, 0))

            array.push(winnerTPBoxes, tpBox)
            array.push(winnerSLBoxes, slBox)

        if showWinnerVerticalLines
            color winnerColor = bearishWinnerLineColor

            if direction == 1
                winnerColor := bullishWinnerLineColor

            line winnerLine = line.new(
                 x1 = setupBar,
                 y1 = stopPrice,
                 x2 = setupBar,
                 y2 = targetPrice,
                 xloc = xloc.bar_index,
                 extend = extend.both,
                 color = winnerColor,
                 width = winnerLineWidth)

            array.push(winnerLines, winnerLine)

        array.push(shownWinnerSetupTimes, setupTime)
        array.push(shownWinnerDirections, direction)
        array.push(shownWinnerModules, moduleId)
        f_trimDrawings()


// Loss labels are resolved outcomes, displayed retroactively at setup bar.
var array<label> losingLabels = array.new_label()
var array<line> losingLines = array.new_line()
var array<int> shownLossSetupTimes = array.new_int()
var array<int> shownLossDirections = array.new_int()
var array<int> shownLossModules = array.new_int()

f_drawLoss(int direction, float entry, float stopPrice, int setupBar, int setupTime, int moduleId) =>
    if f_lossVisible(setupTime, moduleId, direction)
        string moduleText = moduleId == MOD_IFVG ? "IFVG" : "OB"
        string sideText = direction == 1 ? "BUY" : "SELL"
        label lossLabel = label.new(x = setupBar, y = entry, text = moduleText + "\nSL", xloc = xloc.bar_index, yloc = yloc.price,
             color = losingMarkerColor, style = direction == 1 ? label.style_label_up : label.style_label_down,
             textcolor = color.white, size = size.tiny,
             tooltip = sideText + " " + moduleText + " losing opportunity\nEntry: " + str.tostring(entry, format.mintick) + "\nStop: " + str.tostring(stopPrice, format.mintick))
        array.push(losingLabels, lossLabel)
        line lossLine = line.new(x1 = setupBar, y1 = entry, x2 = setupBar, y2 = stopPrice, xloc = xloc.bar_index, extend = extend.none,
             color = losingMarkerColor, style = line.style_dashed, width = 2)
        array.push(losingLines, lossLine)
        array.push(shownLossSetupTimes, setupTime)
        array.push(shownLossDirections, direction)
        array.push(shownLossModules, moduleId)
        while array.size(losingLabels) > maxDisplayedLosses
            label.delete(array.shift(losingLabels))
            line.delete(array.shift(losingLines))
            array.shift(shownLossSetupTimes)
            array.shift(shownLossDirections)
            array.shift(shownLossModules)

// ============================================================================
// MODULE 1 — FIRST-ACTIVE IFVG
// ============================================================================

type SourceGap
    int id
    int originalDir
    float lo
    float hi
    int firstCandleTime
    int endCandleTime
    int formedBar
    int runId
    int runSize
    bool converted
    int conversionBar
    int conversionTime
    bool handled


type IFVGActive
    bool active
    int direction
    float lo
    float hi
    int formedBar
    int formedTime
    int sourceRunId
    bool retracementStarted
    bool entryConsumed


var array<SourceGap> bullSourceFvgs = array.new<SourceGap>()
var array<SourceGap> bearSourceFvgs = array.new<SourceGap>()

var IFVGActive bullIfvg =
     IFVGActive.new(
         false,
         1,
         na,
         na,
         na,
         na,
         na,
         false,
         false)

var IFVGActive bearIfvg =
     IFVGActive.new(
         false,
         -1,
         na,
         na,
         na,
         na,
         na,
         false,
         false)

var int nextSourceId = 0
var int nextRunId = 0

var int lastBullSourceFormationBar = na
var int lastBearSourceFormationBar = na

var int currentBullSourceRunId = na
var int currentBearSourceRunId = na

var int currentBullSourceRunSize = 0
var int currentBearSourceRunSize = 0

var int bullIfvgCutoffBar = na
var int bearIfvgCutoffBar = na

var int bullIfvgPendingRunId = na
var int bearIfvgPendingRunId = na

var int bullIfvgPendingLastSourceBar = na
var int bearIfvgPendingLastSourceBar = na

var array<int> bullConvertedRunIds = array.new_int()
var array<int> bearConvertedRunIds = array.new_int()

var int nextIfvgZoneId = 0
var int bullIfvgZoneId = na
var int bearIfvgZoneId = na
var int bullIFVGFirstBar = na
var int bullIFVGEndBar = na
var int bearIFVGFirstBar = na
var int bearIFVGEndBar = na


f_resetIfvg(IFVGActive z) =>
    z.active := false
    z.lo := na
    z.hi := na
    z.formedBar := na
    z.formedTime := na
    z.sourceRunId := na
    z.retracementStarted := false
    z.entryConsumed := false


f_updateRunSize(array<SourceGap> gaps, int runId, int newSize) =>
    if array.size(gaps) > 0
        int i = 0

        while i < array.size(gaps)
            SourceGap g = array.get(gaps, i)

            if g.runId == runId
                g.runSize := newSize
                array.set(gaps, i, g)

            i += 1


f_markRunHandled(array<SourceGap> gaps, int runId) =>
    if array.size(gaps) > 0
        int i = 0

        while i < array.size(gaps)
            SourceGap g = array.get(gaps, i)

            if g.runId == runId
                g.handled := true
                array.set(gaps, i, g)

            i += 1


f_runInfo(array<SourceGap> gaps, int runId) =>
    int memberCount = 0
    int convertedCount = 0
    int declaredRunSize = 0

    int firstSourceBar = na
    int lastSourceBar = na

    int selectedIndex = -1
    int latestConversionBar = na
    int selectedSourceBar = na

    bool anyUnhandled = false

    if array.size(gaps) > 0
        int i = 0

        while i < array.size(gaps)
            SourceGap g = array.get(gaps, i)

            if g.runId == runId
                memberCount += 1
                declaredRunSize := math.max(declaredRunSize, g.runSize)

                if na(firstSourceBar)
                    firstSourceBar := g.formedBar
                else
                    firstSourceBar := math.min(firstSourceBar, g.formedBar)

                if na(lastSourceBar)
                    lastSourceBar := g.formedBar
                else
                    lastSourceBar := math.max(lastSourceBar, g.formedBar)

                anyUnhandled := anyUnhandled or not g.handled

                if g.converted
                    convertedCount += 1

                    bool laterConversion = na(latestConversionBar) or g.conversionBar > latestConversionBar

                    bool sameConversionEarlierSource =
                         not na(latestConversionBar) and
                         g.conversionBar == latestConversionBar and
                         (na(selectedSourceBar) or g.formedBar < selectedSourceBar)

                    if laterConversion or sameConversionEarlierSource
                        latestConversionBar := g.conversionBar
                        selectedSourceBar := g.formedBar
                        selectedIndex := i

            i += 1

    [memberCount, convertedCount, declaredRunSize, firstSourceBar, lastSourceBar, selectedIndex, anyUnhandled]


f_addUniqueRun(array<int> ids, int runId) =>
    if not array.includes(ids, runId)
        array.push(ids, runId)


f_choosePending(array<SourceGap> gaps, array<int> convertedRunIds, int cutoffBar, int currentPendingId, int currentPendingLastBar) =>
    int chosenId = currentPendingId
    int chosenLastBar = currentPendingLastBar

    if array.size(convertedRunIds) > 0
        int i = 0

        while i < array.size(convertedRunIds)
            int rid = array.get(convertedRunIds, i)

            [cnt, convCnt, rSize, firstBar, lastBar, selectedIndex, anyUnhandled] = f_runInfo(gaps, rid)

            bool afterCutoff =
                 anyUnhandled and
                 not na(firstBar) and
                 (na(cutoffBar) or firstBar > cutoffBar)

            bool moreRecent =
                 na(chosenId) or
                 na(chosenLastBar) or
                 (not na(lastBar) and lastBar > chosenLastBar)

            if afterCutoff and moreRecent
                chosenId := rid
                chosenLastBar := lastBar

            i += 1

    [chosenId, chosenLastBar]


// ============================================================================
// IFVG FIRST-ACTIVE SESSION RESET
// ============================================================================
//
// Exact lifecycle alignment with the supplied V4.1 model:
// - Start state tracking at 07:00 ET.
// - Clear all prior source inventory and active IFVG state at the new state session.
// - End state at 16:00 ET so stale prior-session source FVGs cannot leak forward.
// - Bullish and bearish directional state remain independent.
//
if ifvgStateSessionStart
    array.clear(bullSourceFvgs)
    array.clear(bearSourceFvgs)

    array.clear(bullConvertedRunIds)
    array.clear(bearConvertedRunIds)

    f_resetIfvg(bullIfvg)
    f_resetIfvg(bearIfvg)

    nextSourceId := 0
    nextRunId := 0

    lastBullSourceFormationBar := na
    lastBearSourceFormationBar := na

    currentBullSourceRunId := na
    currentBearSourceRunId := na

    currentBullSourceRunSize := 0
    currentBearSourceRunSize := 0

    bullIfvgCutoffBar := bar_index - 1
    bearIfvgCutoffBar := bar_index - 1

    bullIfvgPendingRunId := na
    bearIfvgPendingRunId := na

    bullIfvgPendingLastSourceBar := na
    bearIfvgPendingLastSourceBar := na

    bullIfvgZoneId := na
    bearIfvgZoneId := na

if ifvgStateSessionEnd
    f_resetIfvg(bullIfvg)
    f_resetIfvg(bearIfvg)

    array.clear(bullSourceFvgs)
    array.clear(bearSourceFvgs)

    array.clear(bullConvertedRunIds)
    array.clear(bearConvertedRunIds)

    bullIfvgPendingRunId := na
    bearIfvgPendingRunId := na

    bullIfvgPendingLastSourceBar := na
    bearIfvgPendingLastSourceBar := na

    bullIfvgZoneId := na
    bearIfvgZoneId := na


// ============================================================================
// IFVG PROCESSING
// ============================================================================

if inIfvgStateSession and barstate.isconfirmed and bar_index >= 2

    array.clear(bullConvertedRunIds)
    array.clear(bearConvertedRunIds)


    // ------------------------------------------------------------------------
    // INVALIDATION
    // ------------------------------------------------------------------------

    if bullIfvg.active and close < bullIfvg.lo
        f_resetIfvg(bullIfvg)
        bullIfvgZoneId := na

    if bearIfvg.active and close > bearIfvg.hi
        f_resetIfvg(bearIfvg)
        bearIfvgZoneId := na


    // ------------------------------------------------------------------------
    // CONVERT BULLISH SOURCE FVGs
    // ------------------------------------------------------------------------

    int bullSourceIndex = 0

    while bullSourceIndex < array.size(bullSourceFvgs)
        SourceGap g = array.get(bullSourceFvgs, bullSourceIndex)

        if not g.converted and close < g.lo
            g.converted := true
            g.conversionBar := bar_index
            g.conversionTime := time_close

            array.set(bullSourceFvgs, bullSourceIndex, g)

            f_addUniqueRun(
                 bearConvertedRunIds,
                 g.runId)

        bullSourceIndex += 1


    // ------------------------------------------------------------------------
    // CONVERT BEARISH SOURCE FVGs
    // ------------------------------------------------------------------------

    int bearSourceIndex = 0

    while bearSourceIndex < array.size(bearSourceFvgs)
        SourceGap g = array.get(bearSourceFvgs, bearSourceIndex)

        if not g.converted and close > g.hi
            g.converted := true
            g.conversionBar := bar_index
            g.conversionTime := time_close

            array.set(bearSourceFvgs, bearSourceIndex, g)

            f_addUniqueRun(
                 bullConvertedRunIds,
                 g.runId)

        bearSourceIndex += 1


    // ========================================================================
    // BULLISH FIRST-ACTIVE IFVG
    // ========================================================================

    int oldBullPending = bullIfvgPendingRunId

    [nextBullPending, nextBullPendingLast] = f_choosePending(bearSourceFvgs, bullConvertedRunIds, bullIfvgCutoffBar, bullIfvgPendingRunId, bullIfvgPendingLastSourceBar)

    if not na(oldBullPending) and nextBullPending != oldBullPending
        f_markRunHandled(
             bearSourceFvgs,
             oldBullPending)

    bullIfvgPendingRunId := nextBullPending
    bullIfvgPendingLastSourceBar := nextBullPendingLast


    if not na(bullIfvgPendingRunId)

        [cntBull, convBull, runSizeBull, firstBarBull, lastBarBull, selectedBullIndex, unhandledBull] = f_runInfo(bearSourceFvgs, bullIfvgPendingRunId)

        if runSizeBull >= 3
            f_markRunHandled(
                 bearSourceFvgs,
                 bullIfvgPendingRunId)

            bullIfvgCutoffBar := lastBarBull

            bullIfvgPendingRunId := na
            bullIfvgPendingLastSourceBar := na

        else if runSizeBull >= 1 and runSizeBull <= 2 and convBull == cntBull and cntBull == runSizeBull and selectedBullIndex >= 0

            SourceGap selectedBull =
                 array.get(
                     bearSourceFvgs,
                     selectedBullIndex)

            f_resetIfvg(
                 bullIfvg)

            bullIfvg.active := true
            bullIfvg.direction := 1

            bullIfvg.lo := selectedBull.lo
            bullIfvg.hi := selectedBull.hi

            bullIfvg.formedBar := bar_index
            bullIfvg.formedTime := time_close

            bullIfvg.sourceRunId := bullIfvgPendingRunId

            bullIfvg.retracementStarted := false
            bullIfvg.entryConsumed := false

            nextIfvgZoneId += 1
            bullIfvgZoneId := nextIfvgZoneId
            bullIFVGFirstBar := selectedBull.formedBar - 2
            bullIFVGEndBar := selectedBull.formedBar

            f_markRunHandled(
                 bearSourceFvgs,
                 bullIfvgPendingRunId)

            bullIfvgCutoffBar := bar_index

            bullIfvgPendingRunId := na
            bullIfvgPendingLastSourceBar := na


    // ========================================================================
    // BEARISH FIRST-ACTIVE IFVG
    // ========================================================================

    int oldBearPending = bearIfvgPendingRunId

    [nextBearPending, nextBearPendingLast] = f_choosePending(bullSourceFvgs, bearConvertedRunIds, bearIfvgCutoffBar, bearIfvgPendingRunId, bearIfvgPendingLastSourceBar)

    if not na(oldBearPending) and nextBearPending != oldBearPending
        f_markRunHandled(
             bullSourceFvgs,
             oldBearPending)

    bearIfvgPendingRunId := nextBearPending
    bearIfvgPendingLastSourceBar := nextBearPendingLast


    if not na(bearIfvgPendingRunId)

        [cntBear, convBear, runSizeBear, firstBarBear, lastBarBear, selectedBearIndex, unhandledBear] = f_runInfo(bullSourceFvgs, bearIfvgPendingRunId)

        if runSizeBear >= 3
            f_markRunHandled(
                 bullSourceFvgs,
                 bearIfvgPendingRunId)

            bearIfvgCutoffBar := lastBarBear

            bearIfvgPendingRunId := na
            bearIfvgPendingLastSourceBar := na

        else if runSizeBear >= 1 and runSizeBear <= 2 and convBear == cntBear and cntBear == runSizeBear and selectedBearIndex >= 0

            SourceGap selectedBear =
                 array.get(
                     bullSourceFvgs,
                     selectedBearIndex)

            f_resetIfvg(
                 bearIfvg)

            bearIfvg.active := true
            bearIfvg.direction := -1

            bearIfvg.lo := selectedBear.lo
            bearIfvg.hi := selectedBear.hi

            bearIfvg.formedBar := bar_index
            bearIfvg.formedTime := time_close

            bearIfvg.sourceRunId := bearIfvgPendingRunId

            bearIfvg.retracementStarted := false
            bearIfvg.entryConsumed := false

            nextIfvgZoneId += 1
            bearIfvgZoneId := nextIfvgZoneId
            bearIFVGFirstBar := selectedBear.formedBar - 2
            bearIFVGEndBar := selectedBear.formedBar

            f_markRunHandled(
                 bullSourceFvgs,
                 bearIfvgPendingRunId)

            bearIfvgCutoffBar := bar_index

            bearIfvgPendingRunId := na
            bearIfvgPendingLastSourceBar := na


    // ========================================================================
    // CREATE NEW SOURCE FVGs
    // ========================================================================

    bool bullishGap = low > high[2]
    bool bearishGap = high < low[2]

    float bullishGapSize = 0.0
    float bearishGapSize = 0.0

    if bullishGap
        bullishGapSize := low - high[2]

    if bearishGap
        bearishGapSize := low[2] - high


    if bullishGap and bullishGapSize >= ifvgMinGap

        bool consecutiveBullSource =
             not na(lastBullSourceFormationBar) and
             lastBullSourceFormationBar == bar_index - 1

        if consecutiveBullSource
            currentBullSourceRunSize += 1

            f_updateRunSize(
                 bullSourceFvgs,
                 currentBullSourceRunId,
                 currentBullSourceRunSize)

        else
            nextRunId += 1

            currentBullSourceRunId := nextRunId
            currentBullSourceRunSize := 1

        nextSourceId += 1

        SourceGap srcBull =
             SourceGap.new(
                 nextSourceId,
                 1,
                 high[2],
                 low,
                 time[2],
                 time,
                 bar_index,
                 currentBullSourceRunId,
                 currentBullSourceRunSize,
                 false,
                 na,
                 na,
                 false)

        array.push(
             bullSourceFvgs,
             srcBull)

        lastBullSourceFormationBar := bar_index


    if bearishGap and bearishGapSize >= ifvgMinGap

        bool consecutiveBearSource =
             not na(lastBearSourceFormationBar) and
             lastBearSourceFormationBar == bar_index - 1

        if consecutiveBearSource
            currentBearSourceRunSize += 1

            f_updateRunSize(
                 bearSourceFvgs,
                 currentBearSourceRunId,
                 currentBearSourceRunSize)

        else
            nextRunId += 1

            currentBearSourceRunId := nextRunId
            currentBearSourceRunSize := 1

        nextSourceId += 1

        SourceGap srcBear =
             SourceGap.new(
                 nextSourceId,
                 -1,
                 high,
                 low[2],
                 time[2],
                 time,
                 bar_index,
                 currentBearSourceRunId,
                 currentBearSourceRunSize,
                 false,
                 na,
                 na,
                 false)

        array.push(
             bearSourceFvgs,
             srcBear)

        lastBearSourceFormationBar := bar_index


    // ========================================================================
    // FIRST-ACTIVE IFVG ENTRY INTERACTION
    // ========================================================================
    //
    // The mapper now follows the standalone V4.1 first-touch lifecycle exactly:
    // - Boundary mode waits for the FIRST Boundary interaction.
    // - CE mode waits for the FIRST CE interaction.
    // - A shallow Boundary touch does NOT consume a CE setup.
    // - No selected level is eligible on the IFVG formation/conversion bar.
    // - The active zone remains eligible until selected-level touch, direct
    //   invalidation, valid same-direction replacement, state-session end,
    //   or an explicitly enabled optional age cap.
    //

    if inIfvgEntrySession
        if bullIfvg.active and not bullIfvg.entryConsumed and bar_index > bullIfvg.formedBar
            int bullAgeMs = time - bullIfvg.formedTime
            int bullMaxAgeMs = ifvgMaxAgeMinutes * MINUTE_MS

            bool bullAgeAllowed =
                 ifvgMaxAgeMinutes == 0 or
                 bullAgeMs <= bullMaxAgeMs

            if not bullAgeAllowed
                bullIfvg.entryConsumed := true
            else
                float bullBoundary = bullIfvg.hi
                float bullCe = (bullIfvg.lo + bullIfvg.hi) / 2.0

                bool bullSelectedLevelTouched = false
                float bullEntry = bullBoundary

                if ifvgTouchMode == "Boundary"
                    bullSelectedLevelTouched := low <= bullBoundary and high >= bullBoundary
                    bullEntry := bullBoundary
                else
                    bullSelectedLevelTouched := low <= bullCe and high >= bullCe
                    bullEntry := bullCe

                if bullSelectedLevelTouched
                    bool bullAdded =
                         f_addCandidate(
                             1,
                             bullEntry,
                             bar_index,
                             time,
                             MOD_IFVG,
                             nz(bullIfvgZoneId, -1),
                             ifvgBoxAnchor == "First FVG candle" ? bullIFVGFirstBar : bullIFVGEndBar,
                             bullIfvg.hi, bullIfvg.lo, bullIfvg.hi, (bullIfvg.lo + bullIfvg.hi) / 2.0)

                    if bullAdded
                        bullIfvg.entryConsumed := true

        if bearIfvg.active and not bearIfvg.entryConsumed and bar_index > bearIfvg.formedBar
            int bearAgeMs = time - bearIfvg.formedTime
            int bearMaxAgeMs = ifvgMaxAgeMinutes * MINUTE_MS

            bool bearAgeAllowed =
                 ifvgMaxAgeMinutes == 0 or
                 bearAgeMs <= bearMaxAgeMs

            if not bearAgeAllowed
                bearIfvg.entryConsumed := true
            else
                float bearBoundary = bearIfvg.lo
                float bearCe = (bearIfvg.lo + bearIfvg.hi) / 2.0

                bool bearSelectedLevelTouched = false
                float bearEntry = bearBoundary

                if ifvgTouchMode == "Boundary"
                    bearSelectedLevelTouched := high >= bearBoundary and low <= bearBoundary
                    bearEntry := bearBoundary
                else
                    bearSelectedLevelTouched := high >= bearCe and low <= bearCe
                    bearEntry := bearCe

                if bearSelectedLevelTouched
                    bool bearAdded =
                         f_addCandidate(
                             -1,
                             bearEntry,
                             bar_index,
                             time,
                             MOD_IFVG,
                             nz(bearIfvgZoneId, -1),
                             ifvgBoxAnchor == "First FVG candle" ? bearIFVGFirstBar : bearIFVGEndBar,
                             bearIfvg.hi, bearIfvg.lo, bearIfvg.lo, (bearIfvg.lo + bearIfvg.hi) / 2.0)

                    if bearAdded
                        bearIfvg.entryConsumed := true


// ============================================================================
// MODULE 2 — ORDER BLOCK
// ============================================================================

type OBCandidate
    int groupStartIndex
    int groupEndIndex
    int watchStartIndex
    float obOpen
    float obHigh
    float obLow
    float obClose
    float displacementAnchor
    float displacementPath
    int displacementBars
    int directionalSteps


type OBActive
    bool active
    int direction
    float bodyTop
    float bodyBottom
    float thresholdPrice
    float bodyEntryPrice
    float validityStopPrice
    int confirmationIndex
    int confirmationTime
    int zoneId
    bool bodyTouched


var array<OBCandidate> bearishOBCandidates = array.new<OBCandidate>()
var array<OBCandidate> bullishOBCandidates = array.new<OBCandidate>()

var OBActive bullishOB =
     OBActive.new(
         false,
         1,
         na,
         na,
         na,
         na,
         na,
         na,
         na,
         na,
         false)

var OBActive bearishOB =
     OBActive.new(
         false,
         -1,
         na,
         na,
         na,
         na,
         na,
         na,
         na,
         na,
         false)

var bool bullishOBReplacementReady = false
var bool bearishOBReplacementReady = false

var int bullishOBCandidateCutoffBar = na
var int bearishOBCandidateCutoffBar = na

var int bullRunLength = 0
var int bullRunStartIndex = na

var float bullRunStartOpen = na
var float bullRunStartHigh = na
var float bullRunStartLow = na
var float bullRunStartClose = na

var int bearRunLength = 0
var int bearRunStartIndex = na

var float bearRunStartOpen = na
var float bearRunStartHigh = na
var float bearRunStartLow = na
var float bearRunStartClose = na

var int nextOBZoneId = 0
var int obEtDay = na
var int bullOBOriginBar = na
var int bearOBOriginBar = na


f_resetOBActive(OBActive z) =>
    z.active := false

    z.bodyTop := na
    z.bodyBottom := na

    z.thresholdPrice := na
    z.bodyEntryPrice := na
    z.validityStopPrice := na

    z.confirmationIndex := na
    z.confirmationTime := na

    z.zoneId := na
    z.bodyTouched := false


f_resetOBWatch(array<OBCandidate> candidates, int newWatchStart, float newAnchor) =>
    int count = array.size(candidates)

    if count > 0
        for i = 0 to count - 1
            OBCandidate candidate = array.get(candidates, i)

            candidate.watchStartIndex := newWatchStart
            candidate.displacementAnchor := newAnchor

            candidate.displacementPath := 0.0
            candidate.displacementBars := 0
            candidate.directionalSteps := 0

            array.set(candidates, i, candidate)


f_trimOBCandidates(array<OBCandidate> candidates) =>
    while array.size(candidates) > obGroupsToTrack
        array.shift(candidates)


f_makeOBActive(int direction, OBCandidate candidate, int zoneId) =>
    float bodyTop =
         math.max(
             candidate.obOpen,
             candidate.obClose)

    float bodyBottom =
         math.min(
             candidate.obOpen,
             candidate.obClose)

    float thresholdPrice =
         (
             bodyTop +
             bodyBottom
         ) /
         2.0

    float bodyEntryPrice = bodyBottom

    if direction == 1
        bodyEntryPrice := bodyTop

    float invalidationReference = bodyEntryPrice

    if obInvalidationReference == "Order Block Threshold"
        invalidationReference := thresholdPrice

    float validityStop =
         invalidationReference -
         direction *
         stopPts

    OBActive.new(
         true,
         direction,
         bodyTop,
         bodyBottom,
         thresholdPrice,
         bodyEntryPrice,
         validityStop,
         bar_index,
         time,
         zoneId,
         false)


// ============================================================================
// OB DAILY RESET
// ============================================================================

int currentOBDay =
     f_dayKey(
         time)


if ifvgStateSessionStart and barstate.isconfirmed

    if na(obEtDay) or currentOBDay != obEtDay or ifvgStateSessionStart

        array.clear(
             bearishOBCandidates)

        array.clear(
             bullishOBCandidates)

        f_resetOBActive(
             bullishOB)

        f_resetOBActive(
             bearishOB)

        bullishOBReplacementReady := false
        bearishOBReplacementReady := false

        bullishOBCandidateCutoffBar := bar_index - 1
        bearishOBCandidateCutoffBar := bar_index - 1

        bullRunLength := 0
        bullRunStartIndex := na

        bullRunStartOpen := na
        bullRunStartHigh := na
        bullRunStartLow := na
        bullRunStartClose := na

        bearRunLength := 0
        bearRunStartIndex := na

        bearRunStartOpen := na
        bearRunStartHigh := na
        bearRunStartLow := na
        bearRunStartClose := na

        bullOBOriginBar := na
        bearOBOriginBar := na
        obEtDay := currentOBDay


// ============================================================================
// OB PROCESSING — SHARED STATE-TRACKING WINDOW
// ============================================================================

if inIfvgStateSession and barstate.isconfirmed

    bool bullishOBAcceptedThisBar = false
    bool bearishOBAcceptedThisBar = false


    // ------------------------------------------------------------------------
    // ACTIVE INVALIDATION
    // ------------------------------------------------------------------------

    if bullishOB.active and low <= bullishOB.validityStopPrice
        f_resetOBActive(bullishOB)

        bullishOBReplacementReady := false
        bullishOBCandidateCutoffBar := bar_index


    if bearishOB.active and high >= bearishOB.validityStopPrice
        f_resetOBActive(bearishOB)

        bearishOBReplacementReady := false
        bearishOBCandidateCutoffBar := bar_index


    // ------------------------------------------------------------------------
    // BULLISH CANDLE RUN
    // ------------------------------------------------------------------------

    bool bullishCandle =
         close >
         open

    if bullishCandle

        bool continueBullRun =
             bullRunLength > 0 and
             (
                 not obRequireProgressiveCloses or
                 close > close[1]
             )

        if continueBullRun
            bullRunLength += 1

        else
            bullRunLength := 1

            bullRunStartIndex := bar_index

            bullRunStartOpen := open
            bullRunStartHigh := high
            bullRunStartLow := low
            bullRunStartClose := close

    else

        bullRunLength := 0
        bullRunStartIndex := na

        bullRunStartOpen := na
        bullRunStartHigh := na
        bullRunStartLow := na
        bullRunStartClose := na


    // ------------------------------------------------------------------------
    // BEARISH CANDLE RUN
    // ------------------------------------------------------------------------

    bool bearishCandle =
         close <
         open

    if bearishCandle

        bool continueBearRun =
             bearRunLength > 0 and
             (
                 not obRequireProgressiveCloses or
                 close < close[1]
             )

        if continueBearRun
            bearRunLength += 1

        else
            bearRunLength := 1

            bearRunStartIndex := bar_index

            bearRunStartOpen := open
            bearRunStartHigh := high
            bearRunStartLow := low
            bearRunStartClose := close

    else

        bearRunLength := 0
        bearRunStartIndex := na

        bearRunStartOpen := na
        bearRunStartHigh := na
        bearRunStartLow := na
        bearRunStartClose := na


    // ------------------------------------------------------------------------
    // BULLISH RUN -> BEARISH OB CANDIDATE
    // ------------------------------------------------------------------------

    float bearishOBBodySize = 0.0

    if not na(bullRunStartOpen) and not na(bullRunStartClose)
        bearishOBBodySize :=
             math.abs(
                 bullRunStartClose -
                 bullRunStartOpen)

    bool bearishOBBodyLargeEnough =
         bearishOBBodySize >=
         obMinBodySize


    if bullRunLength == obMinGroupSize and bearishOBBodyLargeEnough

        OBCandidate newBearishCandidate =
             OBCandidate.new(
                 bullRunStartIndex,
                 bar_index,
                 bar_index,
                 bullRunStartOpen,
                 bullRunStartHigh,
                 bullRunStartLow,
                 bullRunStartClose,
                 close,
                 0.0,
                 0,
                 0)

        array.push(
             bearishOBCandidates,
             newBearishCandidate)

        f_trimOBCandidates(
             bearishOBCandidates)

        f_resetOBWatch(
             bearishOBCandidates,
             bar_index,
             close)


    if bullRunLength > obMinGroupSize and bullRunLength <= obMaxGroupSize and bearishOBBodyLargeEnough and array.size(bearishOBCandidates) > 0

        int newestIndex =
             array.size(
                 bearishOBCandidates) - 1

        OBCandidate newestCandidate =
             array.get(
                 bearishOBCandidates,
                 newestIndex)

        if newestCandidate.groupStartIndex == bullRunStartIndex

            newestCandidate.groupEndIndex := bar_index

            array.set(
                 bearishOBCandidates,
                 newestIndex,
                 newestCandidate)

            f_resetOBWatch(
                 bearishOBCandidates,
                 bar_index,
                 close)


    // ------------------------------------------------------------------------
    // BEARISH RUN -> BULLISH OB CANDIDATE
    // ------------------------------------------------------------------------

    float bullishOBBodySize = 0.0

    if not na(bearRunStartOpen) and not na(bearRunStartClose)
        bullishOBBodySize :=
             math.abs(
                 bearRunStartClose -
                 bearRunStartOpen)

    bool bullishOBBodyLargeEnough =
         bullishOBBodySize >=
         obMinBodySize


    if bearRunLength == obMinGroupSize and bullishOBBodyLargeEnough

        OBCandidate newBullishCandidate =
             OBCandidate.new(
                 bearRunStartIndex,
                 bar_index,
                 bar_index,
                 bearRunStartOpen,
                 bearRunStartHigh,
                 bearRunStartLow,
                 bearRunStartClose,
                 close,
                 0.0,
                 0,
                 0)

        array.push(
             bullishOBCandidates,
             newBullishCandidate)

        f_trimOBCandidates(
             bullishOBCandidates)

        f_resetOBWatch(
             bullishOBCandidates,
             bar_index,
             close)


    if bearRunLength > obMinGroupSize and bearRunLength <= obMaxGroupSize and bullishOBBodyLargeEnough and array.size(bullishOBCandidates) > 0

        int newestIndex =
             array.size(
                 bullishOBCandidates) - 1

        OBCandidate newestCandidate =
             array.get(
                 bullishOBCandidates,
                 newestIndex)

        if newestCandidate.groupStartIndex == bearRunStartIndex

            newestCandidate.groupEndIndex := bar_index

            array.set(
                 bullishOBCandidates,
                 newestIndex,
                 newestCandidate)

            f_resetOBWatch(
                 bullishOBCandidates,
                 bar_index,
                 close)


    // Reject groups that exceed the maximum candle count.
    if bullRunLength > obMaxGroupSize and array.size(bearishOBCandidates) > 0
        int newestBearIndex = array.size(bearishOBCandidates) - 1
        OBCandidate newestBearGroup = array.get(bearishOBCandidates, newestBearIndex)
        if newestBearGroup.groupStartIndex == bullRunStartIndex
            array.remove(bearishOBCandidates, newestBearIndex)

    if bearRunLength > obMaxGroupSize and array.size(bullishOBCandidates) > 0
        int newestBullIndex = array.size(bullishOBCandidates) - 1
        OBCandidate newestBullGroup = array.get(bullishOBCandidates, newestBullIndex)
        if newestBullGroup.groupStartIndex == bearRunStartIndex
            array.remove(bullishOBCandidates, newestBullIndex)

    // ------------------------------------------------------------------------
    // PROCESS BEARISH OB CANDIDATES
    // ------------------------------------------------------------------------

    int bearishCandidateCount =
         array.size(
             bearishOBCandidates)

    if bearishCandidateCount > 0

        int bearishIndex =
             bearishCandidateCount - 1

        while bearishIndex >= 0

            OBCandidate candidate =
                 array.get(
                     bearishOBCandidates,
                     bearishIndex)

            bool eligible =
                 bar_index >
                 candidate.watchStartIndex

            if eligible

                candidate.displacementBars += 1

                candidate.displacementPath +=
                     math.abs(
                         close -
                         close[1])

                if close < close[1]
                    candidate.directionalSteps += 1

                float netDisplacement =
                     candidate.displacementAnchor -
                     close

                float efficiency = 0.0

                if candidate.displacementPath > 0.0
                    efficiency :=
                         netDisplacement /
                         candidate.displacementPath

                float directionalRatio = 0.0

                if candidate.displacementBars > 0
                    directionalRatio :=
                         float(candidate.directionalSteps) /
                         float(candidate.displacementBars)

                bool structuralBreak =
                     close <
                     candidate.obLow

                bool validDisplacement =
                     candidate.directionalSteps >= obMinDirectionalCloses and
                     directionalRatio >= obMinDirectionalCloseRatio and
                     efficiency >= obMinEfficiency

                if structuralBreak

                    bool candidateIsNewCycle =
                         na(bearishOBCandidateCutoffBar) or
                         candidate.groupEndIndex >= bearishOBCandidateCutoffBar

                    bool canAcceptBearish =
                         validDisplacement and
                         not bearishOBAcceptedThisBar and
                         candidateIsNewCycle and
                         (
                             not bearishOB.active or
                             bearishOBReplacementReady
                         )

                    if canAcceptBearish

                        nextOBZoneId += 1

                        bearishOB :=
                             f_makeOBActive(
                                 -1,
                                 candidate,
                                 nextOBZoneId)
                        bearOBOriginBar := candidate.groupStartIndex

                        bearishOBAcceptedThisBar := true

                        bearishOBReplacementReady := false

                        bullishOBReplacementReady := true
                        bullishOBCandidateCutoffBar := bar_index

                    array.remove(
                         bearishOBCandidates,
                         bearishIndex)

                else

                    array.set(
                         bearishOBCandidates,
                         bearishIndex,
                         candidate)

            bearishIndex -= 1


    // ------------------------------------------------------------------------
    // PROCESS BULLISH OB CANDIDATES
    // ------------------------------------------------------------------------

    int bullishCandidateCount =
         array.size(
             bullishOBCandidates)

    if bullishCandidateCount > 0

        int bullishIndex =
             bullishCandidateCount - 1

        while bullishIndex >= 0

            OBCandidate candidate =
                 array.get(
                     bullishOBCandidates,
                     bullishIndex)

            bool eligible =
                 bar_index >
                 candidate.watchStartIndex

            if eligible

                candidate.displacementBars += 1

                candidate.displacementPath +=
                     math.abs(
                         close -
                         close[1])

                if close > close[1]
                    candidate.directionalSteps += 1

                float netDisplacement =
                     close -
                     candidate.displacementAnchor

                float efficiency = 0.0

                if candidate.displacementPath > 0.0
                    efficiency :=
                         netDisplacement /
                         candidate.displacementPath

                float directionalRatio = 0.0

                if candidate.displacementBars > 0
                    directionalRatio :=
                         float(candidate.directionalSteps) /
                         float(candidate.displacementBars)

                bool structuralBreak =
                     close >
                     candidate.obHigh

                bool validDisplacement =
                     candidate.directionalSteps >= obMinDirectionalCloses and
                     directionalRatio >= obMinDirectionalCloseRatio and
                     efficiency >= obMinEfficiency

                if structuralBreak

                    bool candidateIsNewCycle =
                         na(bullishOBCandidateCutoffBar) or
                         candidate.groupEndIndex >= bullishOBCandidateCutoffBar

                    bool canAcceptBullish =
                         validDisplacement and
                         not bullishOBAcceptedThisBar and
                         candidateIsNewCycle and
                         (
                             not bullishOB.active or
                             bullishOBReplacementReady
                         )

                    if canAcceptBullish

                        nextOBZoneId += 1

                        bullishOB :=
                             f_makeOBActive(
                                 1,
                                 candidate,
                                 nextOBZoneId)
                        bullOBOriginBar := candidate.groupStartIndex

                        bullishOBAcceptedThisBar := true

                        bullishOBReplacementReady := false

                        bearishOBReplacementReady := true
                        bearishOBCandidateCutoffBar := bar_index

                    array.remove(
                         bullishOBCandidates,
                         bullishIndex)

                else

                    array.set(
                         bullishOBCandidates,
                         bullishIndex,
                         candidate)

            bullishIndex -= 1


    // ------------------------------------------------------------------------
    // FIRST EXACT BULLISH OB BODY ENTRY
    // ------------------------------------------------------------------------

    if inIfvgEntrySession and bullishOB.active and not bullishOB.bodyTouched and bar_index > bullishOB.confirmationIndex

        int ageMs =
             time -
             bullishOB.confirmationTime

        int maxAgeMs =
             obMaxAgeMinutes *
             MINUTE_MS

        if ageMs > maxAgeMs

            bullishOB.bodyTouched := true

        else

            bool bodyEntryTouched =
                 low <= bullishOB.bodyEntryPrice and
                 high >= bullishOB.bodyEntryPrice

            if bodyEntryTouched

                bool addedBullOB = f_addCandidate(
                     1,
                     bullishOB.bodyEntryPrice,
                     bar_index,
                     time,
                     MOD_OB,
                     bullishOB.zoneId,
                     bullOBOriginBar,
                     bullishOB.bodyTop, bullishOB.bodyBottom, bullishOB.bodyEntryPrice, bullishOB.thresholdPrice)

                if addedBullOB
                    bullishOB.bodyTouched := true


    // ------------------------------------------------------------------------
    // FIRST EXACT BEARISH OB BODY ENTRY
    // ------------------------------------------------------------------------

    if inIfvgEntrySession and bearishOB.active and not bearishOB.bodyTouched and bar_index > bearishOB.confirmationIndex

        int ageMs =
             time -
             bearishOB.confirmationTime

        int maxAgeMs =
             obMaxAgeMinutes *
             MINUTE_MS

        if ageMs > maxAgeMs

            bearishOB.bodyTouched := true

        else

            bool bodyEntryTouched =
                 low <= bearishOB.bodyEntryPrice and
                 high >= bearishOB.bodyEntryPrice

            if bodyEntryTouched

                bool addedBearOB = f_addCandidate(
                     -1,
                     bearishOB.bodyEntryPrice,
                     bar_index,
                     time,
                     MOD_OB,
                     bearishOB.zoneId,
                     bearOBOriginBar,
                     bearishOB.bodyTop, bearishOB.bodyBottom, bearishOB.bodyEntryPrice, bearishOB.thresholdPrice)

                if addedBearOB
                    bearishOB.bodyTouched := true


// ============================================================================
// RESOLVED OPPORTUNITY SOURCE VISUALS — NO ACTIVE-ZONE OVERLAY
// ============================================================================
// A visual uses the original zone snapshot retained with its candidate.
// Zones are drawn only after TP or SL has been confirmed; their right edges are
// deliberately ENTRY bar + selected bars, NOT the bar where TP was reached.
// xloc.bar_index counts real chart bars, including over nontrading intervals.

type SourceZoneDrawing
    box body
    line primaryLeft
    line primaryRight
    line secondary
    label primaryLabel
    label secondaryLabel

var array<SourceZoneDrawing> historicalWinningZones = array.new<SourceZoneDrawing>()

f_deleteSourceDrawing(SourceZoneDrawing z) =>
    if not na(z.body)
        box.delete(z.body)
    if not na(z.primaryLeft)
        line.delete(z.primaryLeft)
    if not na(z.primaryRight)
        line.delete(z.primaryRight)
    if not na(z.secondary)
        line.delete(z.secondary)
    if not na(z.primaryLabel)
        label.delete(z.primaryLabel)
    if not na(z.secondaryLabel)
        label.delete(z.secondaryLabel)
    true

f_sourceLineStyle(string styleText) =>
    styleText == "Dashed" ? line.style_dashed : styleText == "Dotted" ? line.style_dotted : line.style_solid

f_sourceDrawingCap() =>
    // Worst-case budgets, accounting for separately retained TP/SL and loss
    // drawings. Three lines and two labels are reserved per source zone.
    int boxSpace = 500 - (showTPSLBoxes ? 2 * maxDisplayedWins : 0)
    int lineSpace = 500 - (showWinnerVerticalLines ? maxDisplayedWins : 0) - ((showLosingIFVG or showLosingOB) ? maxDisplayedLosses : 0)
    int labelSpace = 500 - ((showLosingIFVG or showLosingOB) ? maxDisplayedLosses : 0)
    int allowed = math.min(maxWinningSourceZones, math.min(boxSpace, math.min(int(math.floor(lineSpace / 3.0)), int(math.floor(labelSpace / 2.0)))))
    math.max(1, allowed)

f_drawOutcomeSource(int direction, int moduleId, int originBar, int entryBar, float upper, float lower, float entryLine, float centerLine, bool isWinner) =>
    // Losing-zone displays are independent of the winning-zone controls.
    // The calling loss switch already gates losing zones OFF by default.
    bool enabled = not isWinner or (moduleId == MOD_IFVG ? showIFVGZones : showOBZones)
    // The historical-coordinate guard prevents invalid bar_index objects on
    // exceptionally late TP resolution beyond the exchange history limit.
    bool permitted = enabled and not na(originBar) and originBar <= entryBar and originBar >= bar_index - 9999 and not na(upper) and not na(lower)
    if permitted
        int cap = f_sourceDrawingCap()
        while array.size(historicalWinningZones) >= cap
            SourceZoneDrawing oldest = array.shift(historicalWinningZones)
            f_deleteSourceDrawing(oldest)

        int rightBar = entryBar + zoneBarsAfterEntry
        int span = math.max(0, rightBar - originBar)
        int midpoint = originBar + int(math.round(span / 2.0))
        bool bullish = direction == 1
        SourceZoneDrawing z = SourceZoneDrawing.new()
        if moduleId == MOD_IFVG
            color zoneColor = isWinner ? (bullish ? bullIFVGColor : bearIFVGColor) : losingMarkerColor
            string zoneName = bullish ? "1M Bullish IFVG" : "1M Bearish IFVG"
            int labelX = ifvgPriceLabelPosition == "Middle" ? midpoint : rightBar
            float boundary = entryLine == upper ? upper : lower
            z.body := box.new(left = originBar, right = rightBar, top = upper, bottom = lower, xloc = xloc.bar_index,
                 bgcolor = color.new(zoneColor, ifvgFillAlpha), border_color = color.new(zoneColor, ifvgBorderAlpha),
                 border_width = ifvgBorderWidth, border_style = line.style_dashed,
                 text = showIFVGText ? zoneName : "", text_color = color.new(color.white, 15),
                 text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
            if showIFVGCE
                int gap = showIFVGPrices ? ifvgLabelGap : 0
                int leftEnd = gap > 0 ? math.max(originBar, labelX - gap) : rightBar
                if leftEnd > originBar
                    z.primaryLeft := line.new(originBar, centerLine, leftEnd, centerLine,
                         xloc = xloc.bar_index, color = ifvgCEColor, width = ifvgCEWidth, style = f_sourceLineStyle(ifvgCEStyle))
                if gap > 0 and ifvgPriceLabelPosition == "Middle"
                    int rightStart = math.min(rightBar, labelX + gap)
                    if rightStart < rightBar
                        z.primaryRight := line.new(rightStart, centerLine, rightBar, centerLine,
                             xloc = xloc.bar_index, color = ifvgCEColor, width = ifvgCEWidth, style = f_sourceLineStyle(ifvgCEStyle))
            if showIFVGPrices
                z.primaryLabel := label.new(labelX, boundary, "Boundary " + str.tostring(boundary, format.mintick),
                     xloc = xloc.bar_index, style = label.style_label_center, textcolor = color.white,
                     color = color.new(zoneColor, 82), size = size.small)
                z.secondaryLabel := label.new(labelX, centerLine, "CE " + str.tostring(centerLine, format.mintick),
                     xloc = xloc.bar_index, style = label.style_label_center, textcolor = ifvgCEColor,
                     color = color.new(zoneColor, 35), size = size.small)
        else
            color zoneColor = isWinner ? (bullish ? bullOBColor : bearOBColor) : losingMarkerColor
            int labelX = obTagPosition == "Middle" ? midpoint : rightBar
            z.body := box.new(left = originBar, right = rightBar, top = upper, bottom = lower, xloc = xloc.bar_index,
                 bgcolor = color.new(zoneColor, obFillAlpha), border_color = color.new(zoneColor, obBorderAlpha), border_width = 1)
            if showOBBodyEntry
                int leftEnd = showOBTag ? math.max(originBar, labelX - obTagGap) : rightBar
                if leftEnd > originBar
                    z.primaryLeft := line.new(originBar, entryLine, leftEnd, entryLine,
                         xloc = xloc.bar_index, color = zoneColor, width = 2)
                if showOBTag and obTagPosition == "Middle"
                    int rightStart = math.min(rightBar, labelX + obTagGap)
                    if rightStart < rightBar
                        z.primaryRight := line.new(rightStart, entryLine, rightBar, entryLine,
                             xloc = xloc.bar_index, color = zoneColor, width = 2)
            if showOBThreshold
                z.secondary := line.new(originBar, centerLine, rightBar, centerLine,
                     xloc = xloc.bar_index, color = obThresholdColor, width = 2)
            if showOBTag
                z.primaryLabel := label.new(labelX, entryLine, "Order Block",
                     xloc = xloc.bar_index, style = label.style_label_center, textcolor = color.white,
                     color = color.new(zoneColor, 82), size = size.small)
        array.push(historicalWinningZones, z)
    true

// ============================================================================
// OUTCOME RESOLUTION (SAME AS PREVIOUS VERSION; NO TABLE)
// ============================================================================
if isOneMinuteChart and barstate.isconfirmed and array.size(candDir) > 0
    int candidateIndex = array.size(candDir) - 1
    while candidateIndex >= 0
        int direction = array.get(candDir, candidateIndex)
        float entry = array.get(candEntry, candidateIndex)
        float targetPrice = array.get(candTP, candidateIndex)
        float stopPrice = array.get(candSL, candidateIndex)
        int setupBar = array.get(candSetupBar, candidateIndex)
        int setupTime = array.get(candSetupTime, candidateIndex)
        int startBar = array.get(candStartBar, candidateIndex)
        int moduleId = array.get(candModule, candidateIndex)
        int originBar = array.get(candOriginBar, candidateIndex)
        float sourceTop = array.get(candZoneTop, candidateIndex)
        float sourceBottom = array.get(candZoneBottom, candidateIndex)
        float sourceEntryLine = array.get(candZoneEntryLine, candidateIndex)
        float sourceCenterLine = array.get(candZoneCenterLine, candidateIndex)
        bool expired = bar_index - setupBar > maxAgeBars
        bool targetTouched = false
        bool stopTouched = false
        if bar_index >= startBar
            if direction == 1
                targetTouched := high >= targetPrice
                stopTouched := low <= stopPrice
            else
                targetTouched := low <= targetPrice
                stopTouched := high >= stopPrice

        bool outcomeKnown = false
        bool winner = false
        bool removeCandidate = false
        bool excludeOutcome = false
        if targetTouched and stopTouched
            removeCandidate := true
            if sameBarPolicy == "Reject ambiguous"
                excludeOutcome := true
            else
                outcomeKnown := true
                winner := sameBarPolicy == "TP wins"
        else if targetTouched
            outcomeKnown := true
            winner := true
            removeCandidate := true
        else if stopTouched
            outcomeKnown := true
            winner := false
            removeCandidate := true
        else if expired
            removeCandidate := true
            excludeOutcome := true

        if removeCandidate
            if outcomeKnown
                f_recordOutcome(moduleId, direction, winner)
                if winner
                    // Check BEFORE reserving the original per-hour display slot.
                    bool sourceEligible = f_displaySlotAvailable(setupTime, moduleId, direction)
                    f_drawWinner(direction, entry, targetPrice, stopPrice, setupBar, setupTime, bar_index, moduleId)
                    if sourceEligible
                        f_drawOutcomeSource(direction, moduleId, originBar, setupBar, sourceTop, sourceBottom, sourceEntryLine, sourceCenterLine, true)
                else
                    bool lossEligible = f_lossVisible(setupTime, moduleId, direction)
                    f_drawLoss(direction, entry, stopPrice, setupBar, setupTime, moduleId)
                    if lossEligible
                        f_drawOutcomeSource(direction, moduleId, originBar, setupBar, sourceTop, sourceBottom, sourceEntryLine, sourceCenterLine, false)
            else if excludeOutcome
                dayExcluded += 1
            array.remove(candDir, candidateIndex)
            array.remove(candEntry, candidateIndex)
            array.remove(candTP, candidateIndex)
            array.remove(candSL, candidateIndex)
            array.remove(candSetupBar, candidateIndex)
            array.remove(candSetupTime, candidateIndex)
            array.remove(candStartBar, candidateIndex)
            array.remove(candModule, candidateIndex)
            array.remove(candZoneId, candidateIndex)
            array.remove(candOriginBar, candidateIndex)
            array.remove(candZoneTop, candidateIndex)
            array.remove(candZoneBottom, candidateIndex)
            array.remove(candZoneEntryLine, candidateIndex)
            array.remove(candZoneCenterLine, candidateIndex)
        candidateIndex -= 1




// ============================================================================
// DAILY SESSION TABLE — DRAWN WINS AND DRAWN LOSSES COUNTED SEPARATELY
// ============================================================================

string BODY_SIZE = f_textSize(tableBodySizeInput)
string HEADER_SIZE = f_textSize(tableHeaderSizeInput)

color T_DARK = color.rgb(38, 43, 56)
color T_DARK2 = color.rgb(48, 54, 68)
color T_BG = color.new(color.rgb(235, 239, 245), tableTransparency)
color T_BG_ALT = color.new(color.rgb(224, 230, 239), tableTransparency)
color T_GRID = color.rgb(150, 161, 177)
color T_TEXT = color.rgb(39, 44, 55)
color T_BUY = color.rgb(110, 185, 171)
color T_SELL = color.rgb(186, 143, 203)
color T_POSITIVE = color.rgb(30, 113, 73)
color T_NEGATIVE = color.rgb(174, 47, 58)

// Header, columns, 3 BUY rows, 3 SELL rows, total row, footer.
var table statsTable = table.new(f_tablePosition(tablePositionInput), 7, 10,
     frame_color = T_GRID, frame_width = 1,
     border_color = T_GRID, border_width = 1)

if barstate.isfirst
    table.merge_cells(statsTable, 0, 0, 6, 0)
    table.merge_cells(statsTable, 0, 2, 0, 4)
    table.merge_cells(statsTable, 0, 5, 0, 7)
    table.merge_cells(statsTable, 0, 9, 6, 9)

f_statCell(int col, int row, string txt, color bg, color fg, string sz, string alignMode) =>
    table.cell(statsTable, col, row, txt,
         text_color = fg, bgcolor = bg, text_size = sz,
         text_halign = alignMode, text_valign = text.align_center)

f_pnlRow(int row, string name, int wins, int losses, bool summary) =>
    float positive = float(wins) * targetPts * float(contractQuantity) * dollarsPerPoint
    float negative = -float(losses) * stopPts * float(contractQuantity) * dollarsPerPoint
    float net = positive + negative
    color bg = summary ? T_DARK : (row % 2 == 0 ? T_BG : T_BG_ALT)
    color fg = summary ? color.white : T_TEXT
    f_statCell(1, row, name, bg, fg, BODY_SIZE, text.align_center)
    f_statCell(2, row, str.tostring(wins), bg, fg, BODY_SIZE, text.align_center)
    f_statCell(3, row, f_cash(positive), bg, summary ? color.white : (wins > 0 ? T_POSITIVE : T_TEXT), BODY_SIZE, text.align_right)
    f_statCell(4, row, str.tostring(losses), bg, fg, BODY_SIZE, text.align_center)
    f_statCell(5, row, f_cash(negative), bg, summary ? color.white : (losses > 0 ? T_NEGATIVE : T_TEXT), BODY_SIZE, text.align_right)
    f_statCell(6, row, f_cash(net), bg, summary ? color.white : (net > 0 ? T_POSITIVE : net < 0 ? T_NEGATIVE : T_TEXT), BODY_SIZE, text.align_right)

if barstate.islast and showStatsTable
    int currentSessionDate = f_dayKey(time)
    int bullIFVGWins = 0
    int bullOBWins = 0
    int bearIFVGWins = 0
    int bearOBWins = 0
    int bullIFVGLosses = 0
    int bullOBLosses = 0
    int bearIFVGLosses = 0
    int bearOBLosses = 0

    // Drawn, retained WIN markers only. Session filters are enforced at entry.
    int visibleWinners = array.size(shownWinnerSetupTimes)
    if visibleWinners > 0
        for i = 0 to visibleWinners - 1
            int entryTime = array.get(shownWinnerSetupTimes, i)
            if f_dayKey(entryTime) == currentSessionDate
                int direction = array.get(shownWinnerDirections, i)
                int moduleId = array.get(shownWinnerModules, i)
                if direction == 1
                    if moduleId == MOD_IFVG
                        bullIFVGWins += 1
                    else if moduleId == MOD_OB
                        bullOBWins += 1
                else if direction == -1
                    if moduleId == MOD_IFVG
                        bearIFVGWins += 1
                    else if moduleId == MOD_OB
                        bearOBWins += 1

    // Drawn, retained LOSS markers only. Both loss switches default to OFF.
    int visibleLosses = array.size(shownLossSetupTimes)
    if visibleLosses > 0
        for i = 0 to visibleLosses - 1
            int entryTime = array.get(shownLossSetupTimes, i)
            if f_dayKey(entryTime) == currentSessionDate
                int direction = array.get(shownLossDirections, i)
                int moduleId = array.get(shownLossModules, i)
                if direction == 1
                    if moduleId == MOD_IFVG
                        bullIFVGLosses += 1
                    else if moduleId == MOD_OB
                        bullOBLosses += 1
                else if direction == -1
                    if moduleId == MOD_IFVG
                        bearIFVGLosses += 1
                    else if moduleId == MOD_OB
                        bearOBLosses += 1

    int allWins = bullIFVGWins + bullOBWins + bearIFVGWins + bearOBWins
    int allLosses = bullIFVGLosses + bullOBLosses + bearIFVGLosses + bearOBLosses
    string hdr = "OPPORTUNITY MAPPER  •  " + detectedInstrument + "  |  " + f_dateText(time) + " ET"
    f_statCell(0, 0, hdr, T_DARK, color.white, HEADER_SIZE, text.align_center)
    f_statCell(0, 1, "SIDE", T_DARK2, color.white, BODY_SIZE, text.align_center)
    f_statCell(1, 1, "MODEL", T_DARK2, color.white, BODY_SIZE, text.align_center)
    f_statCell(2, 1, "WINS", T_DARK2, color.white, BODY_SIZE, text.align_center)
    f_statCell(3, 1, "WIN P&L", T_DARK2, color.white, BODY_SIZE, text.align_center)
    f_statCell(4, 1, "LOSSES", T_DARK2, color.white, BODY_SIZE, text.align_center)
    f_statCell(5, 1, "LOSS P&L", T_DARK2, color.white, BODY_SIZE, text.align_center)
    f_statCell(6, 1, "SHOWN NET P&L", T_DARK2, color.white, BODY_SIZE, text.align_center)

    f_statCell(0, 2, "BUY", T_BUY, color.white, HEADER_SIZE, text.align_center)
    f_pnlRow(2, "IFVG", bullIFVGWins, bullIFVGLosses, false)
    f_pnlRow(3, "OB", bullOBWins, bullOBLosses, false)
    f_pnlRow(4, "TOTAL", bullIFVGWins + bullOBWins, bullIFVGLosses + bullOBLosses, true)

    f_statCell(0, 5, "SELL", T_SELL, color.white, HEADER_SIZE, text.align_center)
    f_pnlRow(5, "IFVG", bearIFVGWins, bearIFVGLosses, false)
    f_pnlRow(6, "OB", bearOBWins, bearOBLosses, false)
    f_pnlRow(7, "TOTAL", bearIFVGWins + bearOBWins, bearIFVGLosses + bearOBLosses, true)

    f_statCell(0, 8, "ALL", T_DARK, color.white, HEADER_SIZE, text.align_center)
    f_pnlRow(8, "TOTAL", allWins, allLosses, true)

    string footer = "ENTRY " + ifvgEntrySession + " ET  •  " + str.tostring(targetSelection) + " PT TP / " + str.tostring(stopPts, "#.##") + " PT SL  •  DISPLAYED, RETAINED OUTCOMES ONLY  •  NOT REALIZED P&L"
    if not isOneMinuteChart
        footer := "USE 1-MINUTE CHART — VALIDATION REQUIRES 1M BARS"
    else if not showWinningIFVG and not showWinningOB and not showLosingIFVG and not showLosingOB
        footer := "ENABLE WINNING OR LOSING IFVG / OB TO VIEW AND COUNT OPPORTUNITIES"
    f_statCell(0, 9, footer, T_DARK, color.white, size.tiny, text.align_center)
````
