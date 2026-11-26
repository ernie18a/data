# High Low with Five Sessions - by Zephyros

- url: https://www.tradingview.com/script/y2vjTGHi-high-low-with-five-sessions-by-zephyros/
- type: indicator
- pine_id: PUB;d573554029cf468596af7f2ce1b9d8ea
- version: 1.0

## Description

# High Low with Five Sessions - by Zephyros

High Low with Five Sessions is a configurable market-structure overlay that plots High and Low levels from five completed intraday sessions together with levels from completed Daily, Weekly, and Monthly periods.

The indicator is designed to keep important completed-range boundaries visible until price touches them for the first time. It does not generate buy or sell recommendations. The levels are reference points that can be used as additional context for liquidity analysis, market structure, reactions around previous extremes, or a trader's own entry and exit framework.

## What the indicator displays

The script tracks eight categories of completed High/Low levels:

- Asia session
- London session
- NYM session
- NYAM session
- NYPM session
- Previous completed Daily period
- Previous completed Weekly period
- Previous completed Monthly period

The five intraday sessions are fully configurable. Each session has separate inputs for start time, end time, lookback, line colors, line widths, labels, and line visibility.

## Default session settings

The default session time zone is `America/New_York`.

Default session intervals:

- Asia: 20:00-23:59
- London: 02:00-05:00
- NYM: 07:00-09:00
- NYAM: 09:30-12:00
- NYPM: 13:30-16:00

The Asia session ends at `23:59` instead of `00:00` so that the default interval remains inside one calendar day in the script's hour-and-minute session model. Session end times are exclusive, which means a bar whose opening time is exactly equal to the configured end time is not included in that session.

Custom session intervals should therefore begin and end within the same calendar day. Overnight intervals that cross midnight are not supported by this version.

## Time-zone selection

The `Session Time Zone` setting uses a drop-down list of common time zones. The selected value applies to:

- calculation of all five custom sessions;
- the daily reset of crossing counters;
- the daily reset of accumulated crossing flags.

The default IANA time zone, `America/New_York`, automatically follows daylight-saving-time changes. Other IANA locations in the list behave in the same way. `UTC` uses a fixed UTC clock.

The selected custom-session time zone does not redefine the Daily, Weekly, or Monthly candles. Those levels continue to use the standard periods supplied by the exchange or data source for the current symbol.

## How session levels are calculated

While a custom session is active, the script records the highest High and lowest Low of the chart bars that open inside the configured interval.

The level pair is created only after the session has fully ended:

- Session High = highest High recorded during the completed session.
- Session Low = lowest Low recorded during the completed session.

The indicator does not display developing session High/Low levels before the session closes.

Session calculations use the bars of the current chart timeframe. They do not request a separate lower-timeframe data set.

## Daily, Weekly, and Monthly levels

Daily, Weekly, and Monthly levels are taken only from fully completed standard periods of the current symbol:

- Daily High/Low = High and Low of the previous completed Daily period.
- Weekly High/Low = High and Low of the previous completed Weekly period.
- Monthly High/Low = High and Low of the previous completed Monthly period.

The script requests the preceding closed period, so these reference values do not use the developing High or Low of the current Daily, Weekly, or Monthly candle.

## Historical anchoring and level availability

Every level becomes active only after its source session or standard period has fully closed.

For visual context, the script anchors each completed-session line to the start bar of that session. Daily, Weekly, and Monthly lines are anchored to the start time of their completed source period. As a result, part of each line is drawn retrospectively across the range from which the High or Low was calculated.

That historical segment does not mean the final level was known in real time at the beginning of the session or period. First-touch tracking starts only after the level is created, and the script does not count price interactions that occurred while the source session or period was still forming.

## Timeframe hierarchy

The indicator avoids reconstructing lower-period levels inside larger chart candles.

The period hierarchy is:

- Seconds and intraday charts: Session + Daily + Weekly + Monthly calculations. Session lines are displayed only below 60 minutes.
- Daily chart: Daily + Weekly + Monthly.
- Weekly chart: Weekly + Monthly.
- Monthly chart: Monthly only.

On multi-period chart timeframes larger than a source period, the smaller source period is excluded. For example, Daily levels are not processed on a 2-day chart, Weekly levels are not processed on a 2-week chart, and Monthly levels are not processed on chart timeframes above one month.

## Session-line visibility by timeframe

Session lines and session labels are automatically hidden on chart timeframes of 60 minutes or higher. Session calculations and hidden crossing outputs continue to run from the current chart bars.

On 30-minute and 45-minute charts, a chart candle can overlap a configured session boundary. In that situation, the session High or Low can include the full High or Low of that chart candle. For the most precise session boundaries, use a timeframe whose bars align with the configured start and end times.

## First-touch crossing logic

Each completed level is active until its first touch.

A High level is considered crossed when:

`Current bar High >= level price`

A Low level is considered crossed when:

`Current bar Low <= level price`

Only the first touch of each individual level is counted. Repeated touches of the same level are ignored.

If one candle touches several previously active levels, each level is counted separately. For example, if one candle first touches three High levels, `High Crosses Today` increases by three.

## Crossed-line behavior

The `Delete Crossed Lines` setting controls what happens after the first touch:

- Disabled by default: the line stops at the first-touch bar and remains visible as a completed historical fragment.
- Enabled: the crossed line is removed from the chart.

The `Show High/Low Lines` setting inside each group controls visual display only. Disabling a line group does not disable its level calculations, first-touch tracking, daily flags, counters, or hidden outputs when that category is permitted on the current chart timeframe.

## Lookback Bars

Each level group includes a `Lookback Bars` setting.

It defines the maximum age, measured in bars of the current chart timeframe, for an uncrossed level to remain active and eligible for first-touch processing. The default and maximum value is 5000 bars.

Once a level is crossed, it is removed from active tracking. If `Delete Crossed Lines` is disabled, its truncated line can remain visible until TradingView removes older drawing objects under the platform's drawing limits.

## Labels and debug information

Normal level labels are disabled by default and can be enabled separately for each session or period group.

`Show Debug Information` is also disabled by default. When enabled, it displays:

- a label at each detected first touch;
- a table containing daily counters and flags;
- the number of currently active tracked High/Low levels;
- the current priority values used by the hidden classification outputs.

Debug information is intended for inspection and integration testing, not as a trading recommendation.

## Hidden outputs

The script includes hidden plots for use in the Data Window, data export, or integration with other Pine Script tools.

### Daily accumulated flags

Each flag resets at the beginning of a new calendar day in the selected `Session Time Zone`. After the first qualifying touch during that day, the corresponding flag becomes `1` and remains `1` until the next daily reset.

- `Asia High Cross Flag`
- `Asia Low Cross Flag`
- `London High Cross Flag`
- `London Low Cross Flag`
- `NYM High Cross Flag`
- `NYM Low Cross Flag`
- `NYAM High Cross Flag`
- `NYAM Low Cross Flag`
- `NYPM High Cross Flag`
- `NYPM Low Cross Flag`
- `Daily High Cross Flag`
- `Daily Low Cross Flag`
- `Weekly High Cross Flag`
- `Weekly Low Cross Flag`
- `Monthly High Cross Flag`
- `Monthly Low Cross Flag`

### Daily crossing counters

- `High Crosses Today` = number of individual active High levels first touched during the current selected-time-zone day.
- `Low Crosses Today` = number of individual active Low levels first touched during the current selected-time-zone day.

### Per-bar priority outputs

The following values describe only first-touch events detected on the current bar:

- `ZEP_HL_HIGH_STRENGTH`
- `ZEP_HL_LOW_STRENGTH`
- `ZEP_HL_SIGNAL`

The word `STRENGTH` is retained for compatibility with the output names, but the value is a predefined category priority, not a statistically measured signal strength:

- `1` = custom intraday session level;
- `2` = Daily level;
- `3` = Weekly or Monthly level.

`ZEP_HL_HIGH_STRENGTH` returns the highest High-side priority touched on the current bar.

`ZEP_HL_LOW_STRENGTH` returns the highest Low-side priority touched on the current bar.

`ZEP_HL_SIGNAL` is classified as follows:

- positive value = the strongest current-bar event is a Low-level touch;
- negative value = the strongest current-bar event is a High-level touch;
- `0` = no event, or equal highest priorities occurred on both sides of the same bar.

These values are technical classifications. They are not independent long or short signals.

## Basic usage

1. Add the indicator to a time-based chart.
2. Select the time zone used for the five custom sessions.
3. Adjust the five session intervals when required.
4. Choose which line groups and labels should be visible.
5. Use the extended High/Low levels as contextual references.
6. Observe the first interaction between price and each active level.
7. Combine the information with an independent method such as market structure, price reaction, volume, volatility, or risk-management rules.

## Originality

This is an original implementation by Zephyros.

Its purpose is not simply to display a single previous High or Low. The script combines:

- five independently configurable completed sessions;
- a selectable session time zone with daily state resets;
- completed Daily, Weekly, and Monthly reference levels;
- timeframe-aware period hierarchy;
- first-touch-only lifecycle management for each individual level;
- separate visual and calculation states;
- accumulated daily flags and counters;
- per-bar priority outputs for external integration.

The script is published with open source code so users can inspect, verify, modify, and study its calculations.

## Limitations

- The plotted levels are historical reference points, not predictions.
- A touch of a High or Low does not guarantee a reversal, continuation, liquidity sweep, or profitable trade.
- The indicator does not open positions, place orders, calculate position size, set stop-losses, set profit targets, or provide strategy-test results.
- Custom sessions are calculated from the current chart bars. Boundary precision therefore depends on the selected timeframe and its bar alignment.
- Custom session intervals that cross midnight are not supported.
- Missing market data or exchange closures can reduce the number of bars available inside a session.
- Daily, Weekly, and Monthly boundaries depend on the standard periods supplied for the selected symbol by its exchange or data provider.
- The current open bar can trigger a first touch as its High or Low develops.
- The script is intended for time-based charts. Non-time-based chart types can produce unavailable timeframe classifications or behavior that does not match the intended session model.
- TradingView limits the number of line and label drawings maintained by one script. The indicator requests the platform maximum of 500 lines and 500 labels, but older visual objects can still be removed automatically when those limits are reached.
- Hidden priority values are deterministic category codes, not statistical confidence scores.
- The indicator should not be used as the sole basis for a trading decision.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Zephyros

indicator(
    title = "High Low with Five Sessions - by Zephyros",
    overlay = true,
    max_bars_back = 5000,
    max_lines_count = 500,
    max_labels_count = 500
)

// ============================================================================
// INPUT GROUPS
// ============================================================================

const string GROUP_GENERAL = "General Settings"
const string GROUP_ASIA = "Asia Session Settings"
const string GROUP_LONDON = "London Session Settings"
const string GROUP_NYM = "NYM Session Settings"
const string GROUP_NYAM = "NYAM Session Settings"
const string GROUP_NYPM = "NYPM Session Settings"
const string GROUP_DAILY = "Daily Level Settings"
const string GROUP_WEEKLY = "Weekly Level Settings"
const string GROUP_MONTHLY = "Monthly Level Settings"

// ============================================================================
// GENERAL SETTINGS
// ============================================================================

string sessionTimeZone = input.string(
    "America/New_York",
    "Session Time Zone",
    options = [
        "UTC",
        "America/New_York",
        "America/Chicago",
        "America/Los_Angeles",
        "Europe/London",
        "Europe/Berlin",
        "Europe/Moscow",
        "Asia/Dubai",
        "Asia/Kolkata",
        "Asia/Singapore",
        "Asia/Hong_Kong",
        "Asia/Tokyo",
        "Australia/Sydney"
    ],
    tooltip = "Applies to the five custom sessions and to the daily reset of counters and flags. Daily, weekly, and monthly levels continue to use the symbol's standard exchange periods.",
    group = GROUP_GENERAL
)

bool deleteCrossedLines = input.bool(
    false,
    "Delete Crossed Lines",
    tooltip = "When disabled, a level is truncated at its first touch and remains on the chart. When enabled, the crossed line is deleted.",
    group = GROUP_GENERAL
)

bool showDebugInformation = input.bool(
    false,
    "Show Debug Information",
    tooltip = "Displays crossing labels, the diagnostic table, and the number of active tracked levels.",
    group = GROUP_GENERAL
)

// ============================================================================
// ASIA SESSION SETTINGS
// ============================================================================

int asiaStartHour = input.int(20, "Start Hour", minval = 0, maxval = 23, inline = "asiaStart", group = GROUP_ASIA)
int asiaStartMinute = input.int(0, "Start Minute", minval = 0, maxval = 59, inline = "asiaStart", group = GROUP_ASIA)
int asiaEndHour = input.int(23, "End Hour", minval = 0, maxval = 23, inline = "asiaEnd", group = GROUP_ASIA)
int asiaEndMinute = input.int(59, "End Minute", minval = 0, maxval = 59, inline = "asiaEnd", group = GROUP_ASIA)
int asiaLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed Asia level to remain active.", group = GROUP_ASIA)
color asiaHighColor = input.color(color.red, "High Line Color", inline = "asiaHigh", group = GROUP_ASIA)
int asiaHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "asiaHigh", group = GROUP_ASIA)
color asiaLowColor = input.color(color.red, "Low Line Color", inline = "asiaLow", group = GROUP_ASIA)
int asiaLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "asiaLow", group = GROUP_ASIA)
bool showAsiaLabels = input.bool(false, "Show Labels", group = GROUP_ASIA)
bool showAsiaLines = input.bool(true, "Show High/Low Lines", group = GROUP_ASIA)

// ============================================================================
// LONDON SESSION SETTINGS
// ============================================================================

int londonStartHour = input.int(2, "Start Hour", minval = 0, maxval = 23, inline = "londonStart", group = GROUP_LONDON)
int londonStartMinute = input.int(0, "Start Minute", minval = 0, maxval = 59, inline = "londonStart", group = GROUP_LONDON)
int londonEndHour = input.int(5, "End Hour", minval = 0, maxval = 23, inline = "londonEnd", group = GROUP_LONDON)
int londonEndMinute = input.int(0, "End Minute", minval = 0, maxval = 59, inline = "londonEnd", group = GROUP_LONDON)
int londonLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed London level to remain active.", group = GROUP_LONDON)
color londonHighColor = input.color(color.blue, "High Line Color", inline = "londonHigh", group = GROUP_LONDON)
int londonHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "londonHigh", group = GROUP_LONDON)
color londonLowColor = input.color(color.blue, "Low Line Color", inline = "londonLow", group = GROUP_LONDON)
int londonLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "londonLow", group = GROUP_LONDON)
bool showLondonLabels = input.bool(false, "Show Labels", group = GROUP_LONDON)
bool showLondonLines = input.bool(true, "Show High/Low Lines", group = GROUP_LONDON)

// ============================================================================
// NYM SESSION SETTINGS
// ============================================================================

int nymStartHour = input.int(7, "Start Hour", minval = 0, maxval = 23, inline = "nymStart", group = GROUP_NYM)
int nymStartMinute = input.int(0, "Start Minute", minval = 0, maxval = 59, inline = "nymStart", group = GROUP_NYM)
int nymEndHour = input.int(9, "End Hour", minval = 0, maxval = 23, inline = "nymEnd", group = GROUP_NYM)
int nymEndMinute = input.int(0, "End Minute", minval = 0, maxval = 59, inline = "nymEnd", group = GROUP_NYM)
int nymLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed NYM level to remain active.", group = GROUP_NYM)
color nymHighColor = input.color(color.rgb(37, 181, 238), "High Line Color", inline = "nymHigh", group = GROUP_NYM)
int nymHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "nymHigh", group = GROUP_NYM)
color nymLowColor = input.color(color.rgb(37, 181, 238), "Low Line Color", inline = "nymLow", group = GROUP_NYM)
int nymLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "nymLow", group = GROUP_NYM)
bool showNYMLabels = input.bool(false, "Show Labels", group = GROUP_NYM)
bool showNYMLines = input.bool(true, "Show High/Low Lines", group = GROUP_NYM)

// ============================================================================
// NYAM SESSION SETTINGS
// ============================================================================

int nyamStartHour = input.int(9, "Start Hour", minval = 0, maxval = 23, inline = "nyamStart", group = GROUP_NYAM)
int nyamStartMinute = input.int(30, "Start Minute", minval = 0, maxval = 59, inline = "nyamStart", group = GROUP_NYAM)
int nyamEndHour = input.int(12, "End Hour", minval = 0, maxval = 23, inline = "nyamEnd", group = GROUP_NYAM)
int nyamEndMinute = input.int(0, "End Minute", minval = 0, maxval = 59, inline = "nyamEnd", group = GROUP_NYAM)
int nyamLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed NYAM level to remain active.", group = GROUP_NYAM)
color nyamHighColor = input.color(color.purple, "High Line Color", inline = "nyamHigh", group = GROUP_NYAM)
int nyamHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "nyamHigh", group = GROUP_NYAM)
color nyamLowColor = input.color(color.purple, "Low Line Color", inline = "nyamLow", group = GROUP_NYAM)
int nyamLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "nyamLow", group = GROUP_NYAM)
bool showNYAMLabels = input.bool(false, "Show Labels", group = GROUP_NYAM)
bool showNYAMLines = input.bool(true, "Show High/Low Lines", group = GROUP_NYAM)

// ============================================================================
// NYPM SESSION SETTINGS
// ============================================================================

int nypmStartHour = input.int(13, "Start Hour", minval = 0, maxval = 23, inline = "nypmStart", group = GROUP_NYPM)
int nypmStartMinute = input.int(30, "Start Minute", minval = 0, maxval = 59, inline = "nypmStart", group = GROUP_NYPM)
int nypmEndHour = input.int(16, "End Hour", minval = 0, maxval = 23, inline = "nypmEnd", group = GROUP_NYPM)
int nypmEndMinute = input.int(0, "End Minute", minval = 0, maxval = 59, inline = "nypmEnd", group = GROUP_NYPM)
int nypmLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed NYPM level to remain active.", group = GROUP_NYPM)
color nypmHighColor = input.color(color.green, "High Line Color", inline = "nypmHigh", group = GROUP_NYPM)
int nypmHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "nypmHigh", group = GROUP_NYPM)
color nypmLowColor = input.color(color.green, "Low Line Color", inline = "nypmLow", group = GROUP_NYPM)
int nypmLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "nypmLow", group = GROUP_NYPM)
bool showNYPMLabels = input.bool(false, "Show Labels", group = GROUP_NYPM)
bool showNYPMLines = input.bool(true, "Show High/Low Lines", group = GROUP_NYPM)

// ============================================================================
// DAILY, WEEKLY, AND MONTHLY SETTINGS
// ============================================================================

int dailyLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed Daily level to remain active.", group = GROUP_DAILY)
color dailyHighColor = input.color(color.orange, "High Line Color", inline = "dailyHigh", group = GROUP_DAILY)
int dailyHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "dailyHigh", group = GROUP_DAILY)
color dailyLowColor = input.color(color.orange, "Low Line Color", inline = "dailyLow", group = GROUP_DAILY)
int dailyLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "dailyLow", group = GROUP_DAILY)
bool showDailyLabels = input.bool(false, "Show Labels", group = GROUP_DAILY)
bool showDailyLines = input.bool(true, "Show High/Low Lines", group = GROUP_DAILY)

int weeklyLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed Weekly level to remain active.", group = GROUP_WEEKLY)
color weeklyHighColor = input.color(color.yellow, "High Line Color", inline = "weeklyHigh", group = GROUP_WEEKLY)
int weeklyHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "weeklyHigh", group = GROUP_WEEKLY)
color weeklyLowColor = input.color(color.yellow, "Low Line Color", inline = "weeklyLow", group = GROUP_WEEKLY)
int weeklyLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "weeklyLow", group = GROUP_WEEKLY)
bool showWeeklyLabels = input.bool(false, "Show Labels", group = GROUP_WEEKLY)
bool showWeeklyLines = input.bool(true, "Show High/Low Lines", group = GROUP_WEEKLY)

int monthlyLookbackBars = input.int(5000, "Lookback Bars", minval = 1, maxval = 5000, tooltip = "Maximum age, measured in current-chart bars, for an uncrossed Monthly level to remain active.", group = GROUP_MONTHLY)
color monthlyHighColor = input.color(color.white, "High Line Color", inline = "monthlyHigh", group = GROUP_MONTHLY)
int monthlyHighWidth = input.int(1, "High Width", minval = 1, maxval = 10, inline = "monthlyHigh", group = GROUP_MONTHLY)
color monthlyLowColor = input.color(color.white, "Low Line Color", inline = "monthlyLow", group = GROUP_MONTHLY)
int monthlyLowWidth = input.int(1, "Low Width", minval = 1, maxval = 10, inline = "monthlyLow", group = GROUP_MONTHLY)
bool showMonthlyLabels = input.bool(false, "Show Labels", group = GROUP_MONTHLY)
bool showMonthlyLines = input.bool(true, "Show High/Low Lines", group = GROUP_MONTHLY)

// ============================================================================
// DATA STRUCTURES
// ============================================================================

// Stores only active, not-yet-crossed levels. A crossed line can remain visible
// as a truncated historical fragment, but it is removed from active tracking.
type ActiveLevel
    float price
    line drawing
    int birthBar

var array<ActiveLevel> asiaHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> asiaLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> londonHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> londonLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> nymHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> nymLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> nyamHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> nyamLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> nypmHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> nypmLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> dailyHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> dailyLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> weeklyHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> weeklyLowLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> monthlyHighLevels = array.new<ActiveLevel>(0)
var array<ActiveLevel> monthlyLowLevels = array.new<ActiveLevel>(0)

// Mutable one-element arrays are used so helper functions can update shared state.
var array<int> highCrossesTodayArr = array.new<int>(1, 0)
var array<int> lowCrossesTodayArr = array.new<int>(1, 0)
var array<int> zepHlHighStrengthArr = array.new<int>(1, 0)
var array<int> zepHlLowStrengthArr = array.new<int>(1, 0)

var array<int> asiaHighFlagArr = array.new<int>(1, 0)
var array<int> asiaLowFlagArr = array.new<int>(1, 0)
var array<int> londonHighFlagArr = array.new<int>(1, 0)
var array<int> londonLowFlagArr = array.new<int>(1, 0)
var array<int> nymHighFlagArr = array.new<int>(1, 0)
var array<int> nymLowFlagArr = array.new<int>(1, 0)
var array<int> nyamHighFlagArr = array.new<int>(1, 0)
var array<int> nyamLowFlagArr = array.new<int>(1, 0)
var array<int> nypmHighFlagArr = array.new<int>(1, 0)
var array<int> nypmLowFlagArr = array.new<int>(1, 0)
var array<int> dailyHighFlagArr = array.new<int>(1, 0)
var array<int> dailyLowFlagArr = array.new<int>(1, 0)
var array<int> weeklyHighFlagArr = array.new<int>(1, 0)
var array<int> weeklyLowFlagArr = array.new<int>(1, 0)
var array<int> monthlyHighFlagArr = array.new<int>(1, 0)
var array<int> monthlyLowFlagArr = array.new<int>(1, 0)

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

f_isInSession(int minuteOfDay, int startHour, int startMinute, int endHour, int endMinute) =>
    int startTotal = startHour * 60 + startMinute
    int endTotal = endHour * 60 + endMinute
    minuteOfDay >= startTotal and minuteOfDay < endTotal

f_addLevel(array<ActiveLevel> levels, float price, line drawing) =>
    array.push(levels, ActiveLevel.new(price, drawing, bar_index))

f_pruneLevels(array<ActiveLevel> levels, int lookbackBars) =>
    while array.size(levels) > 0
        ActiveLevel oldest = array.get(levels, 0)
        if bar_index - oldest.birthBar <= lookbackBars
            break
        line.delete(oldest.drawing)
        array.shift(levels)

f_resetBarStrength() =>
    array.set(zepHlHighStrengthArr, 0, 0)
    array.set(zepHlLowStrengthArr, 0, 0)

f_registerHigh(int eventStrength) =>
    array.set(zepHlHighStrengthArr, 0, math.max(array.get(zepHlHighStrengthArr, 0), eventStrength))

f_registerLow(int eventStrength) =>
    array.set(zepHlLowStrengthArr, 0, math.max(array.get(zepHlLowStrengthArr, 0), eventStrength))

f_resetDailyState() =>
    array.set(highCrossesTodayArr, 0, 0)
    array.set(lowCrossesTodayArr, 0, 0)
    array.set(asiaHighFlagArr, 0, 0)
    array.set(asiaLowFlagArr, 0, 0)
    array.set(londonHighFlagArr, 0, 0)
    array.set(londonLowFlagArr, 0, 0)
    array.set(nymHighFlagArr, 0, 0)
    array.set(nymLowFlagArr, 0, 0)
    array.set(nyamHighFlagArr, 0, 0)
    array.set(nyamLowFlagArr, 0, 0)
    array.set(nypmHighFlagArr, 0, 0)
    array.set(nypmLowFlagArr, 0, 0)
    array.set(dailyHighFlagArr, 0, 0)
    array.set(dailyLowFlagArr, 0, 0)
    array.set(weeklyHighFlagArr, 0, 0)
    array.set(weeklyLowFlagArr, 0, 0)
    array.set(monthlyHighFlagArr, 0, 0)
    array.set(monthlyLowFlagArr, 0, 0)

f_createSessionLevels(
    array<ActiveLevel> highLevels,
    array<ActiveLevel> lowLevels,
    int sessionStartBar,
    int sessionEndBar,
    float sessionHigh,
    float sessionLow,
    bool drawLines,
    color highColor,
    color lowColor,
    int highWidth,
    int lowWidth,
    bool drawLabels,
    string sessionName
) =>
    line highLine = na
    line lowLine = na

    if drawLines
        highLine := line.new(
            sessionStartBar,
            sessionHigh,
            sessionEndBar,
            sessionHigh,
            xloc = xloc.bar_index,
            extend = extend.right,
            color = highColor,
            width = highWidth
        )
        lowLine := line.new(
            sessionStartBar,
            sessionLow,
            sessionEndBar,
            sessionLow,
            xloc = xloc.bar_index,
            extend = extend.right,
            color = lowColor,
            width = lowWidth
        )

    f_addLevel(highLevels, sessionHigh, highLine)
    f_addLevel(lowLevels, sessionLow, lowLine)

    if drawLabels
        label.new(
            sessionEndBar,
            sessionHigh,
            sessionName + " High: " + str.tostring(sessionHigh, format.price),
            xloc = xloc.bar_index,
            yloc = yloc.price,
            style = label.style_label_left,
            color = color.white,
            textcolor = color.black
        )
        label.new(
            sessionEndBar,
            sessionLow,
            sessionName + " Low: " + str.tostring(sessionLow, format.price),
            xloc = xloc.bar_index,
            yloc = yloc.price,
            style = label.style_label_left,
            color = color.white,
            textcolor = color.black
        )

f_createPeriodLevels(
    array<ActiveLevel> highLevels,
    array<ActiveLevel> lowLevels,
    int periodStartTime,
    int creationTime,
    float periodHigh,
    float periodLow,
    bool drawLines,
    color highColor,
    color lowColor,
    int highWidth,
    int lowWidth,
    bool drawLabels,
    string periodName
) =>
    line highLine = na
    line lowLine = na

    if drawLines
        highLine := line.new(
            periodStartTime,
            periodHigh,
            creationTime,
            periodHigh,
            xloc = xloc.bar_time,
            extend = extend.right,
            color = highColor,
            width = highWidth,
            style = line.style_dotted
        )
        lowLine := line.new(
            periodStartTime,
            periodLow,
            creationTime,
            periodLow,
            xloc = xloc.bar_time,
            extend = extend.right,
            color = lowColor,
            width = lowWidth,
            style = line.style_dotted
        )

    f_addLevel(highLevels, periodHigh, highLine)
    f_addLevel(lowLevels, periodLow, lowLine)

    if drawLabels
        label.new(
            creationTime,
            periodHigh,
            periodName + " High: " + str.tostring(periodHigh, format.price),
            xloc = xloc.bar_time,
            yloc = yloc.price,
            style = label.style_label_left,
            color = color.white,
            textcolor = color.black
        )
        label.new(
            creationTime,
            periodLow,
            periodName + " Low: " + str.tostring(periodLow, format.price),
            xloc = xloc.bar_time,
            yloc = yloc.price,
            style = label.style_label_left,
            color = color.white,
            textcolor = color.black
        )

f_handleCrossings(
    array<ActiveLevel> highLevels,
    array<ActiveLevel> lowLevels,
    array<int> highFlagArr,
    array<int> lowFlagArr,
    string levelName,
    int eventStrength,
    bool useTimeCoordinates,
    bool enabled
) =>
    if enabled
        int highCount = array.size(highLevels)
        if highCount > 0
            for i = highCount - 1 to 0
                ActiveLevel activeLevel = array.get(highLevels, i)
                if high >= activeLevel.price
                    array.set(highCrossesTodayArr, 0, array.get(highCrossesTodayArr, 0) + 1)
                    array.set(highFlagArr, 0, 1)
                    f_registerHigh(eventStrength)

                    bool drawingExists = not na(activeLevel.drawing) and array.includes(line.all, activeLevel.drawing)
                    if drawingExists
                        if deleteCrossedLines
                            line.delete(activeLevel.drawing)
                        else
                            line.set_extend(activeLevel.drawing, extend.none)
                            line.set_x2(activeLevel.drawing, useTimeCoordinates ? time : bar_index)
                            line.set_y2(activeLevel.drawing, activeLevel.price)

                    if showDebugInformation
                        string debugText = "Crossed " + levelName + " High: " + str.tostring(activeLevel.price, format.price) + " (flag = 1)"
                        if useTimeCoordinates
                            label.new(
                                time,
                                activeLevel.price,
                                debugText,
                                xloc = xloc.bar_time,
                                yloc = yloc.price,
                                style = label.style_label_down,
                                color = color.yellow,
                                textcolor = color.black
                            )
                        else
                            label.new(
                                bar_index,
                                activeLevel.price,
                                debugText,
                                xloc = xloc.bar_index,
                                yloc = yloc.price,
                                style = label.style_label_down,
                                color = color.yellow,
                                textcolor = color.black
                            )

                    array.remove(highLevels, i)

        int lowCount = array.size(lowLevels)
        if lowCount > 0
            for i = lowCount - 1 to 0
                ActiveLevel activeLevel = array.get(lowLevels, i)
                if low <= activeLevel.price
                    array.set(lowCrossesTodayArr, 0, array.get(lowCrossesTodayArr, 0) + 1)
                    array.set(lowFlagArr, 0, 1)
                    f_registerLow(eventStrength)

                    bool drawingExists = not na(activeLevel.drawing) and array.includes(line.all, activeLevel.drawing)
                    if drawingExists
                        if deleteCrossedLines
                            line.delete(activeLevel.drawing)
                        else
                            line.set_extend(activeLevel.drawing, extend.none)
                            line.set_x2(activeLevel.drawing, useTimeCoordinates ? time : bar_index)
                            line.set_y2(activeLevel.drawing, activeLevel.price)

                    if showDebugInformation
                        string debugText = "Crossed " + levelName + " Low: " + str.tostring(activeLevel.price, format.price) + " (flag = 1)"
                        if useTimeCoordinates
                            label.new(
                                time,
                                activeLevel.price,
                                debugText,
                                xloc = xloc.bar_time,
                                yloc = yloc.price,
                                style = label.style_label_up,
                                color = color.yellow,
                                textcolor = color.black
                            )
                        else
                            label.new(
                                bar_index,
                                activeLevel.price,
                                debugText,
                                xloc = xloc.bar_index,
                                yloc = yloc.price,
                                style = label.style_label_up,
                                color = color.yellow,
                                textcolor = color.black
                            )

                    array.remove(lowLevels, i)

// ============================================================================
// TIMEFRAME RULES
// ============================================================================

float chartTimeframeSeconds = timeframe.in_seconds()
float dailyTimeframeSeconds = timeframe.in_seconds("1D")
float weeklyTimeframeSeconds = timeframe.in_seconds("1W")
float monthlyTimeframeSeconds = timeframe.in_seconds("1M")

bool timeBasedChart = not na(chartTimeframeSeconds)
bool showSessionVisualsOnThisTimeframe = timeBasedChart and chartTimeframeSeconds < 60.0 * 60.0
bool processDailyLevels = timeBasedChart and chartTimeframeSeconds <= dailyTimeframeSeconds
bool processWeeklyLevels = timeBasedChart and chartTimeframeSeconds <= weeklyTimeframeSeconds
bool processMonthlyLevels = timeBasedChart and chartTimeframeSeconds <= monthlyTimeframeSeconds

// ============================================================================
// SELECTED-TIME-ZONE DAY RESET
// ============================================================================

int localYear = year(time, sessionTimeZone)
int localMonth = month(time, sessionTimeZone)
int localDay = dayofmonth(time, sessionTimeZone)
int localDayKey = localYear * 10000 + localMonth * 100 + localDay
bool newLocalDay = bar_index > 0 and localDayKey != localDayKey[1]

if newLocalDay
    f_resetDailyState()

// ============================================================================
// FIVE CUSTOM SESSIONS
// ============================================================================

int localHour = hour(time, sessionTimeZone)
int localMinute = minute(time, sessionTimeZone)
int localMinuteOfDay = localHour * 60 + localMinute

bool asiaInSession = f_isInSession(localMinuteOfDay, asiaStartHour, asiaStartMinute, asiaEndHour, asiaEndMinute)
bool londonInSession = f_isInSession(localMinuteOfDay, londonStartHour, londonStartMinute, londonEndHour, londonEndMinute)
bool nymInSession = f_isInSession(localMinuteOfDay, nymStartHour, nymStartMinute, nymEndHour, nymEndMinute)
bool nyamInSession = f_isInSession(localMinuteOfDay, nyamStartHour, nyamStartMinute, nyamEndHour, nyamEndMinute)
bool nypmInSession = f_isInSession(localMinuteOfDay, nypmStartHour, nypmStartMinute, nypmEndHour, nypmEndMinute)

bool asiaStartSession = asiaInSession and not asiaInSession[1]
bool londonStartSession = londonInSession and not londonInSession[1]
bool nymStartSession = nymInSession and not nymInSession[1]
bool nyamStartSession = nyamInSession and not nyamInSession[1]
bool nypmStartSession = nypmInSession and not nypmInSession[1]

bool asiaEndSession = not asiaInSession and asiaInSession[1]
bool londonEndSession = not londonInSession and londonInSession[1]
bool nymEndSession = not nymInSession and nymInSession[1]
bool nyamEndSession = not nyamInSession and nyamInSession[1]
bool nypmEndSession = not nypmInSession and nypmInSession[1]

var int asiaSessionStartBar = na
var float asiaSessionHigh = na
var float asiaSessionLow = na
var int londonSessionStartBar = na
var float londonSessionHigh = na
var float londonSessionLow = na
var int nymSessionStartBar = na
var float nymSessionHigh = na
var float nymSessionLow = na
var int nyamSessionStartBar = na
var float nyamSessionHigh = na
var float nyamSessionLow = na
var int nypmSessionStartBar = na
var float nypmSessionHigh = na
var float nypmSessionLow = na

if asiaStartSession
    asiaSessionStartBar := bar_index
    asiaSessionHigh := high
    asiaSessionLow := low
else if asiaInSession
    asiaSessionHigh := na(asiaSessionHigh) ? high : math.max(asiaSessionHigh, high)
    asiaSessionLow := na(asiaSessionLow) ? low : math.min(asiaSessionLow, low)

if londonStartSession
    londonSessionStartBar := bar_index
    londonSessionHigh := high
    londonSessionLow := low
else if londonInSession
    londonSessionHigh := na(londonSessionHigh) ? high : math.max(londonSessionHigh, high)
    londonSessionLow := na(londonSessionLow) ? low : math.min(londonSessionLow, low)

if nymStartSession
    nymSessionStartBar := bar_index
    nymSessionHigh := high
    nymSessionLow := low
else if nymInSession
    nymSessionHigh := na(nymSessionHigh) ? high : math.max(nymSessionHigh, high)
    nymSessionLow := na(nymSessionLow) ? low : math.min(nymSessionLow, low)

if nyamStartSession
    nyamSessionStartBar := bar_index
    nyamSessionHigh := high
    nyamSessionLow := low
else if nyamInSession
    nyamSessionHigh := na(nyamSessionHigh) ? high : math.max(nyamSessionHigh, high)
    nyamSessionLow := na(nyamSessionLow) ? low : math.min(nyamSessionLow, low)

if nypmStartSession
    nypmSessionStartBar := bar_index
    nypmSessionHigh := high
    nypmSessionLow := low
else if nypmInSession
    nypmSessionHigh := na(nypmSessionHigh) ? high : math.max(nypmSessionHigh, high)
    nypmSessionLow := na(nypmSessionLow) ? low : math.min(nypmSessionLow, low)

if asiaEndSession and not na(asiaSessionStartBar) and not na(asiaSessionHigh) and not na(asiaSessionLow)
    f_createSessionLevels(
        asiaHighLevels,
        asiaLowLevels,
        asiaSessionStartBar,
        bar_index - 1,
        asiaSessionHigh,
        asiaSessionLow,
        showSessionVisualsOnThisTimeframe and showAsiaLines,
        asiaHighColor,
        asiaLowColor,
        asiaHighWidth,
        asiaLowWidth,
        showSessionVisualsOnThisTimeframe and showAsiaLabels,
        "Asia"
    )
    asiaSessionStartBar := na
    asiaSessionHigh := na
    asiaSessionLow := na

if londonEndSession and not na(londonSessionStartBar) and not na(londonSessionHigh) and not na(londonSessionLow)
    f_createSessionLevels(
        londonHighLevels,
        londonLowLevels,
        londonSessionStartBar,
        bar_index - 1,
        londonSessionHigh,
        londonSessionLow,
        showSessionVisualsOnThisTimeframe and showLondonLines,
        londonHighColor,
        londonLowColor,
        londonHighWidth,
        londonLowWidth,
        showSessionVisualsOnThisTimeframe and showLondonLabels,
        "London"
    )
    londonSessionStartBar := na
    londonSessionHigh := na
    londonSessionLow := na

if nymEndSession and not na(nymSessionStartBar) and not na(nymSessionHigh) and not na(nymSessionLow)
    f_createSessionLevels(
        nymHighLevels,
        nymLowLevels,
        nymSessionStartBar,
        bar_index - 1,
        nymSessionHigh,
        nymSessionLow,
        showSessionVisualsOnThisTimeframe and showNYMLines,
        nymHighColor,
        nymLowColor,
        nymHighWidth,
        nymLowWidth,
        showSessionVisualsOnThisTimeframe and showNYMLabels,
        "NYM"
    )
    nymSessionStartBar := na
    nymSessionHigh := na
    nymSessionLow := na

if nyamEndSession and not na(nyamSessionStartBar) and not na(nyamSessionHigh) and not na(nyamSessionLow)
    f_createSessionLevels(
        nyamHighLevels,
        nyamLowLevels,
        nyamSessionStartBar,
        bar_index - 1,
        nyamSessionHigh,
        nyamSessionLow,
        showSessionVisualsOnThisTimeframe and showNYAMLines,
        nyamHighColor,
        nyamLowColor,
        nyamHighWidth,
        nyamLowWidth,
        showSessionVisualsOnThisTimeframe and showNYAMLabels,
        "NYAM"
    )
    nyamSessionStartBar := na
    nyamSessionHigh := na
    nyamSessionLow := na

if nypmEndSession and not na(nypmSessionStartBar) and not na(nypmSessionHigh) and not na(nypmSessionLow)
    f_createSessionLevels(
        nypmHighLevels,
        nypmLowLevels,
        nypmSessionStartBar,
        bar_index - 1,
        nypmSessionHigh,
        nypmSessionLow,
        showSessionVisualsOnThisTimeframe and showNYPMLines,
        nypmHighColor,
        nypmLowColor,
        nypmHighWidth,
        nypmLowWidth,
        showSessionVisualsOnThisTimeframe and showNYPMLabels,
        "NYPM"
    )
    nypmSessionStartBar := na
    nypmSessionHigh := na
    nypmSessionLow := na

// ============================================================================
// CLOSED DAILY, WEEKLY, AND MONTHLY LEVELS
// ============================================================================

// The [1] offset combined with lookahead_on requests only the previous fully
// closed higher-timeframe period and keeps the values stable in realtime.
[previousDailyHigh, previousDailyLow, previousDailyStartTime] = request.security(
    syminfo.tickerid,
    "1D",
    [high[1], low[1], time[1]],
    gaps = barmerge.gaps_off,
    lookahead = barmerge.lookahead_on
)

[previousWeeklyHigh, previousWeeklyLow, previousWeeklyStartTime] = request.security(
    syminfo.tickerid,
    "1W",
    [high[1], low[1], time[1]],
    gaps = barmerge.gaps_off,
    lookahead = barmerge.lookahead_on
)

[previousMonthlyHigh, previousMonthlyLow, previousMonthlyStartTime] = request.security(
    syminfo.tickerid,
    "1M",
    [high[1], low[1], time[1]],
    gaps = barmerge.gaps_off,
    lookahead = barmerge.lookahead_on
)

bool newDailyPeriod = timeframe.change("1D")
bool newWeeklyPeriod = timeframe.change("1W")
bool newMonthlyPeriod = timeframe.change("1M")

if processDailyLevels and newDailyPeriod and not na(previousDailyHigh) and not na(previousDailyLow) and not na(previousDailyStartTime)
    f_createPeriodLevels(
        dailyHighLevels,
        dailyLowLevels,
        previousDailyStartTime,
        time,
        previousDailyHigh,
        previousDailyLow,
        showDailyLines,
        dailyHighColor,
        dailyLowColor,
        dailyHighWidth,
        dailyLowWidth,
        showDailyLabels,
        "Daily"
    )

if processWeeklyLevels and newWeeklyPeriod and not na(previousWeeklyHigh) and not na(previousWeeklyLow) and not na(previousWeeklyStartTime)
    f_createPeriodLevels(
        weeklyHighLevels,
        weeklyLowLevels,
        previousWeeklyStartTime,
        time,
        previousWeeklyHigh,
        previousWeeklyLow,
        showWeeklyLines,
        weeklyHighColor,
        weeklyLowColor,
        weeklyHighWidth,
        weeklyLowWidth,
        showWeeklyLabels,
        "Weekly"
    )

if processMonthlyLevels and newMonthlyPeriod and not na(previousMonthlyHigh) and not na(previousMonthlyLow) and not na(previousMonthlyStartTime)
    f_createPeriodLevels(
        monthlyHighLevels,
        monthlyLowLevels,
        previousMonthlyStartTime,
        time,
        previousMonthlyHigh,
        previousMonthlyLow,
        showMonthlyLines,
        monthlyHighColor,
        monthlyLowColor,
        monthlyHighWidth,
        monthlyLowWidth,
        showMonthlyLabels,
        "Monthly"
    )

// ============================================================================
// LOOKBACK PRUNING FOR ACTIVE LEVELS
// ============================================================================

f_pruneLevels(asiaHighLevels, asiaLookbackBars)
f_pruneLevels(asiaLowLevels, asiaLookbackBars)
f_pruneLevels(londonHighLevels, londonLookbackBars)
f_pruneLevels(londonLowLevels, londonLookbackBars)
f_pruneLevels(nymHighLevels, nymLookbackBars)
f_pruneLevels(nymLowLevels, nymLookbackBars)
f_pruneLevels(nyamHighLevels, nyamLookbackBars)
f_pruneLevels(nyamLowLevels, nyamLookbackBars)
f_pruneLevels(nypmHighLevels, nypmLookbackBars)
f_pruneLevels(nypmLowLevels, nypmLookbackBars)
f_pruneLevels(dailyHighLevels, dailyLookbackBars)
f_pruneLevels(dailyLowLevels, dailyLookbackBars)
f_pruneLevels(weeklyHighLevels, weeklyLookbackBars)
f_pruneLevels(weeklyLowLevels, weeklyLookbackBars)
f_pruneLevels(monthlyHighLevels, monthlyLookbackBars)
f_pruneLevels(monthlyLowLevels, monthlyLookbackBars)

// ============================================================================
// FIRST-TOUCH CROSSING PROCESSING
// ============================================================================

f_resetBarStrength()

f_handleCrossings(asiaHighLevels, asiaLowLevels, asiaHighFlagArr, asiaLowFlagArr, "Asia", 1, false, true)
f_handleCrossings(londonHighLevels, londonLowLevels, londonHighFlagArr, londonLowFlagArr, "London", 1, false, true)
f_handleCrossings(nymHighLevels, nymLowLevels, nymHighFlagArr, nymLowFlagArr, "NYM", 1, false, true)
f_handleCrossings(nyamHighLevels, nyamLowLevels, nyamHighFlagArr, nyamLowFlagArr, "NYAM", 1, false, true)
f_handleCrossings(nypmHighLevels, nypmLowLevels, nypmHighFlagArr, nypmLowFlagArr, "NYPM", 1, false, true)
f_handleCrossings(dailyHighLevels, dailyLowLevels, dailyHighFlagArr, dailyLowFlagArr, "Daily", 2, true, processDailyLevels)
f_handleCrossings(weeklyHighLevels, weeklyLowLevels, weeklyHighFlagArr, weeklyLowFlagArr, "Weekly", 3, true, processWeeklyLevels)
f_handleCrossings(monthlyHighLevels, monthlyLowLevels, monthlyHighFlagArr, monthlyLowFlagArr, "Monthly", 3, true, processMonthlyLevels)

// ============================================================================
// HIDDEN OUTPUTS
// ============================================================================

float highCrossesToday = array.get(highCrossesTodayArr, 0)
float lowCrossesToday = array.get(lowCrossesTodayArr, 0)
int zepHlHighStrength = array.get(zepHlHighStrengthArr, 0)
int zepHlLowStrength = array.get(zepHlLowStrengthArr, 0)
int zepHlSignal = zepHlLowStrength > zepHlHighStrength ? zepHlLowStrength : zepHlHighStrength > zepHlLowStrength ? -zepHlHighStrength : 0

float asiaHighFlag = array.get(asiaHighFlagArr, 0)
float asiaLowFlag = array.get(asiaLowFlagArr, 0)
float londonHighFlag = array.get(londonHighFlagArr, 0)
float londonLowFlag = array.get(londonLowFlagArr, 0)
float nymHighFlag = array.get(nymHighFlagArr, 0)
float nymLowFlag = array.get(nymLowFlagArr, 0)
float nyamHighFlag = array.get(nyamHighFlagArr, 0)
float nyamLowFlag = array.get(nyamLowFlagArr, 0)
float nypmHighFlag = array.get(nypmHighFlagArr, 0)
float nypmLowFlag = array.get(nypmLowFlagArr, 0)
float dailyHighFlag = array.get(dailyHighFlagArr, 0)
float dailyLowFlag = array.get(dailyLowFlagArr, 0)
float weeklyHighFlag = array.get(weeklyHighFlagArr, 0)
float weeklyLowFlag = array.get(weeklyLowFlagArr, 0)
float monthlyHighFlag = array.get(monthlyHighFlagArr, 0)
float monthlyLowFlag = array.get(monthlyLowFlagArr, 0)

plot(asiaHighFlag, title = "Asia High Cross Flag", display = display.none)
plot(asiaLowFlag, title = "Asia Low Cross Flag", display = display.none)
plot(londonHighFlag, title = "London High Cross Flag", display = display.none)
plot(londonLowFlag, title = "London Low Cross Flag", display = display.none)
plot(nymHighFlag, title = "NYM High Cross Flag", display = display.none)
plot(nymLowFlag, title = "NYM Low Cross Flag", display = display.none)
plot(nyamHighFlag, title = "NYAM High Cross Flag", display = display.none)
plot(nyamLowFlag, title = "NYAM Low Cross Flag", display = display.none)
plot(nypmHighFlag, title = "NYPM High Cross Flag", display = display.none)
plot(nypmLowFlag, title = "NYPM Low Cross Flag", display = display.none)
plot(dailyHighFlag, title = "Daily High Cross Flag", display = display.none)
plot(dailyLowFlag, title = "Daily Low Cross Flag", display = display.none)
plot(weeklyHighFlag, title = "Weekly High Cross Flag", display = display.none)
plot(weeklyLowFlag, title = "Weekly Low Cross Flag", display = display.none)
plot(monthlyHighFlag, title = "Monthly High Cross Flag", display = display.none)
plot(monthlyLowFlag, title = "Monthly Low Cross Flag", display = display.none)
plot(highCrossesToday, title = "High Crosses Today", display = display.none)
plot(lowCrossesToday, title = "Low Crosses Today", display = display.none)
plot(zepHlSignal, title = "ZEP_HL_SIGNAL", display = display.none)
plot(zepHlHighStrength, title = "ZEP_HL_HIGH_STRENGTH", display = display.none)
plot(zepHlLowStrength, title = "ZEP_HL_LOW_STRENGTH", display = display.none)

// ============================================================================
// OPTIONAL DEBUG INFORMATION
// ============================================================================

var table debugTable = na
var label activeLevelsLabel = na

if barstate.islast and showDebugInformation
    if na(debugTable)
        debugTable := table.new(position.top_right, 3, 15, bgcolor = color.new(color.gray, 10), border_width = 1)

    int totalActiveLevels = (
        array.size(asiaHighLevels) + array.size(asiaLowLevels) +
        array.size(londonHighLevels) + array.size(londonLowLevels) +
        array.size(nymHighLevels) + array.size(nymLowLevels) +
        array.size(nyamHighLevels) + array.size(nyamLowLevels) +
        array.size(nypmHighLevels) + array.size(nypmLowLevels) +
        array.size(dailyHighLevels) + array.size(dailyLowLevels) +
        array.size(weeklyHighLevels) + array.size(weeklyLowLevels) +
        array.size(monthlyHighLevels) + array.size(monthlyLowLevels)
    )

    if na(activeLevelsLabel)
        activeLevelsLabel := label.new(
            bar_index,
            high,
            "",
            xloc = xloc.bar_index,
            yloc = yloc.abovebar,
            color = color.blue,
            style = label.style_label_down,
            textcolor = color.white
        )

    label.set_xy(activeLevelsLabel, bar_index, high)
    label.set_text(activeLevelsLabel, "Active tracked High/Low levels: " + str.tostring(totalActiveLevels))

    table.cell(debugTable, 0, 0, "Crossed", text_color = color.white)
    table.cell(debugTable, 1, 0, "Count", text_color = color.white)
    table.cell(debugTable, 2, 0, "", text_color = color.white)
    table.cell(debugTable, 0, 1, "Low", text_color = color.white)
    table.cell(debugTable, 1, 1, str.tostring(lowCrossesToday), text_color = color.white)
    table.cell(debugTable, 0, 2, "High", text_color = color.white)
    table.cell(debugTable, 1, 2, str.tostring(highCrossesToday), text_color = color.white)
    table.cell(debugTable, 0, 3, "Level Type", text_color = color.white)
    table.cell(debugTable, 1, 3, "High Flag", text_color = color.white)
    table.cell(debugTable, 2, 3, "Low Flag", text_color = color.white)
    table.cell(debugTable, 0, 4, "Asia", text_color = color.white)
    table.cell(debugTable, 1, 4, str.tostring(asiaHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 4, str.tostring(asiaLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 5, "London", text_color = color.white)
    table.cell(debugTable, 1, 5, str.tostring(londonHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 5, str.tostring(londonLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 6, "NYM", text_color = color.white)
    table.cell(debugTable, 1, 6, str.tostring(nymHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 6, str.tostring(nymLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 7, "NYAM", text_color = color.white)
    table.cell(debugTable, 1, 7, str.tostring(nyamHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 7, str.tostring(nyamLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 8, "NYPM", text_color = color.white)
    table.cell(debugTable, 1, 8, str.tostring(nypmHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 8, str.tostring(nypmLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 9, "Daily", text_color = color.white)
    table.cell(debugTable, 1, 9, str.tostring(dailyHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 9, str.tostring(dailyLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 10, "Weekly", text_color = color.white)
    table.cell(debugTable, 1, 10, str.tostring(weeklyHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 10, str.tostring(weeklyLowFlag), text_color = color.white)
    table.cell(debugTable, 0, 11, "Monthly", text_color = color.white)
    table.cell(debugTable, 1, 11, str.tostring(monthlyHighFlag), text_color = color.white)
    table.cell(debugTable, 2, 11, str.tostring(monthlyLowFlag), text_color = color.white)

    color signalBackground = zepHlSignal > 0 ? color.new(color.green, 70) : zepHlSignal < 0 ? color.new(color.red, 70) : color.new(color.gray, 80)
    table.cell(debugTable, 0, 12, "ZEP_HL_SIGNAL", text_color = color.white, bgcolor = signalBackground)
    table.cell(debugTable, 1, 12, str.tostring(zepHlSignal), text_color = color.white, bgcolor = signalBackground)
    table.cell(debugTable, 2, 12, zepHlSignal > 0 ? "Low" : zepHlSignal < 0 ? "High" : "Conflict / None", text_color = color.white, bgcolor = signalBackground)
    table.cell(debugTable, 0, 13, "ZEP Low Priority", text_color = color.white)
    table.cell(debugTable, 1, 13, str.tostring(zepHlLowStrength), text_color = color.white)
    table.cell(debugTable, 2, 13, "Positive", text_color = color.white)
    table.cell(debugTable, 0, 14, "ZEP High Priority", text_color = color.white)
    table.cell(debugTable, 1, 14, str.tostring(zepHlHighStrength), text_color = color.white)
    table.cell(debugTable, 2, 14, "Negative", text_color = color.white)
````
