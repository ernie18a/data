# Smart Support & Resistance + Session POC

- url: https://www.tradingview.com/script/V1jJHFPU-Smart-Support-Resistance-Session-POC/
- type: indicator
- pine_id: PUB;fc65f4bbcd9d49af95025aeb4b5611bf
- version: 1.0

## Description

Smart Support & Resistance + Session POC
Overview  

Smart Support & Resistance + Session POC is a confirmation-based support and resistance indicator designed to identify meaningful price areas instead of plotting a level after every pivot or wick.

The indicator searches for repeated, separate price rejections on a user-selected detection timeframe. A level remains hidden after its first rejection and only becomes a visible zone after it receives the required number of valid rejections.

Each rejection can be filtered by:

Pivot structure
Approach direction
Minimum wick rejection
Minimum displacement away from the level
Time between separate visits
Distance from existing zones 

The indicator can also compare confirmed zones with the Point of Control from previous completed volume-profile sessions. Zones with POC confluence are displayed more prominently, allowing traders to quickly identify areas where repeated price rejection and concentrated traded volume overlap.

This indicator is intended for intraday support and resistance analysis on futures, stocks, forex, and other symbols that provide the required volume and footprint data.

Main Features
Multi-Timeframe Zone Detection

Zones can be calculated from a timeframe independent of the chart timeframe.

For example, you can:

Calculate zones from the 1-hour timeframe.
View those same zones on a 15-minute chart.
Drop to the 5-minute or 1-minute chart for execution.

This keeps the important higher-timeframe structure visible while using a lower timeframe for trade entries.

The selected detection timeframe must be equal to or higher than the chart timeframe.

Confirmation-Based Zone Detection

The indicator does not display every pivot high or pivot low.

A level begins as a hidden candidate after its first valid rejection. It only becomes a visible support or resistance zone after receiving the selected minimum number of separate rejections.

The default requirement is:

Regular zone: 2 valid rejections
Strong zone: 3 or more valid rejections

The thresholds are fully adjustable.

Because pivot confirmation requires bars to form on the right side of the pivot, zones appear after confirmation rather than attempting to predict a turning point in advance.

What Counts as a Valid Rejection?

A rejection must pass the enabled quality filters before it can be counted.

Resistance Rejection

A potential resistance rejection is created when:

A confirmed pivot high forms.
Price approached the area from underneath, when the approach filter is enabled.
The pivot candle closes sufficiently below its high.
Price produces the required downward displacement after the rejection.
The rejection is sufficiently separated from the previous visit.
Support Rejection

A potential support rejection is created when:

A confirmed pivot low forms.
Price approached the area from above, when the approach filter is enabled.
The pivot candle closes sufficiently above its low.
Price produces the required upward displacement after the rejection.
The rejection is sufficiently separated from the previous visit.

These filters help prevent ordinary consolidation, repeated candles inside the same range, and weak pivots from being counted as meaningful support or resistance.

Separate-Visit Logic

Several candles reacting around the same level do not automatically count as several independent rejections.

A new rejection must be separated from the previous rejection by the selected number of detection-timeframe bars.

For example, with:

Detection timeframe: 60 minutes
Minimum bars between rejections: 3

The next rejection must occur at least three 1-hour bars after the previous rejection before it can increase the zone’s rejection count.

This prevents a cluster of candles from incorrectly creating an immediate strong zone.

Adjustable Tick-Based Zones

Zone thickness is defined in ticks using the symbol’s minimum tick size.

This allows the same indicator to adjust correctly across different instruments.

For MNQ:

1 tick = 0.25 points
4 ticks = 1 point
20 ticks = 5 points
40 ticks = 10 points

Support zones are constructed upward from the confirmed rejection low.

Resistance zones are constructed downward from the confirmed rejection high.

When a new valid rejection is merged into an existing zone, the zone may adjust to include the newer rejection extreme while maintaining the selected zone thickness.

Zone Merging

Nearby rejections of the same type can be grouped into one zone instead of creating several overlapping boxes.

The Zone merge tolerance setting controls how close two areas can be before they are treated as the same support or resistance zone.

A larger merge tolerance produces fewer, broader structural areas.

A smaller merge tolerance keeps nearby levels separate and creates more zones.

Zone Strength and Appearance

The indicator uses opacity to display zone quality without adding labels, centerlines, or unnecessary chart clutter.

Default appearance:

Regular zone: 50% opacity
Strong zone: 75% opacity
POC-confluence zone: 100% opacity

Support zones are green by default.

Resistance zones are red by default.

All colors, opacity levels, and border widths are customizable.

Visual Priority

POC confluence has the highest appearance priority.

Therefore:

A two-rejection zone without POC confluence appears as a regular zone.
A zone reaching the strong-rejection threshold appears as a strong zone.
Any confirmed zone overlapping a selected POC appears at the POC opacity level.

The chart remains clean because no labels or centerlines are required to identify zone quality.

Completed Session POC Confluence

The indicator can analyze Point of Control levels from previously completed volume profiles.

The Point of Control represents the highest-volume price row within the selected completed profile.

A confirmed zone receives POC confluence when its price range overlaps a POC row within the selected profile lookback.

POC confluence can be calculated from:

Exchange-defined regular sessions
Extended or full sessions

The profile timeframe is also adjustable.

For intraday trading, a common configuration is:

Profile timeframe: 1D
Profile session: Exchange regular
POC lookback: 5 completed profiles

This compares active support and resistance zones with POCs from the previous five completed daily profiles.

Completed Profiles Only

The indicator uses completed profiles rather than a developing current-session POC.

A developing POC can move throughout the session as additional volume trades. Using completed profiles provides a stable reference that does not continue shifting during the current session.

POC Lookback

The POC lookback controls how many completed profiles remain available for confluence.

For example:

A lookback of 1 checks only the most recently completed profile.
A lookback of 5 checks the previous five completed profiles.
A lookback of 10 checks the previous ten completed profiles.

When an old profile leaves the selected lookback, the indicator recalculates confluence. A zone may therefore lose its POC appearance when the POC supporting it is no longer inside the active lookback.

POC functionality requires footprint data to be available for the TradingView account and selected symbol.

Zone Invalidation

A zone is considered invalid when price closes completely beyond its outside boundary plus the selected break buffer.

Support Invalidation

A support zone is deleted when the selected confirmation candle closes below:

Support zone bottom − break buffer

Resistance Invalidation

A resistance zone is deleted when the selected confirmation candle closes above:

Resistance zone top + break buffer

A wick through the zone does not automatically invalidate it. Price must close beyond the zone and its buffer.

Once broken:

The zone is permanently removed from the chart.
It is not faded.
It is not retained as a historical zone.
It does not automatically convert into a support/resistance flip.
A new zone can form near the same price only after new valid rejections occur.
Break Confirmation Timeframe

There are two break-confirmation choices.

Detection Timeframe

This is the recommended setting.

A zone calculated from the 1-hour timeframe is invalidated only by a confirmed 1-hour close beyond the zone and buffer.

This prevents a small lower-timeframe close from deleting a higher-timeframe zone prematurely.

Chart Timeframe

The zone is invalidated by a confirmed close on the current chart timeframe.

This is more responsive but also more sensitive.

For example, a 1-minute close could invalidate a zone calculated from the 1-hour timeframe.

Zone Freshness

The Zone freshness lookback determines how long a level can remain active without receiving another valid rejection.

Freshness is measured from the zone’s most recent valid rejection.

For example, with a 10-day freshness setting:

A zone whose most recent valid rejection occurred within the last 10 days remains active.
A zone that has not received a valid rejection for more than 10 days is deleted.
A new valid rejection refreshes the zone’s age.

The freshness setting is measured in calendar-day periods.

Zone Length

Two zone-extension modes are available.

Until Broken

The zone continuously extends to the right until:

Price invalidates it.
It becomes stale.
It is removed because of the maximum tracked-level limit.

This is the recommended setting for active support and resistance trading.

Fixed Detection Bars

The zone extends for a selected number of detection-timeframe bars after confirmation.

For example:

Detection timeframe: 60 minutes
Fixed length: 100 bars

The zone remains active for approximately 100 confirmed 1-hour bars unless it is invalidated or becomes stale first.

How to Use the Indicator
Step 1: Choose the Detection Timeframe

Select the timeframe from which support and resistance should be calculated.

Common examples:

Scalping on a 1-minute chart: use 15-minute, 30-minute, or 1-hour zones.
Trading on a 5-minute chart: use 30-minute or 1-hour zones.
Trading on a 15-minute chart: use 1-hour or 4-hour zones.

The detection timeframe cannot be lower than the chart timeframe.

A good starting point for MNQ intraday trading is:

Chart timeframe: 1–5 minutes
Detection timeframe: 60 minutes
Step 2: Set the Minimum Rejections

Start with:

Minimum rejections: 2
Strong-zone rejections: 3

With these settings:

The first rejection creates a hidden candidate.
The second valid rejection confirms and displays the zone.
The third valid rejection upgrades it to a strong zone.

Increasing the required rejections creates fewer but more selective zones.

Step 3: Set the Zone Thickness

Choose a zone thickness that matches the instrument’s normal movement.

Suggested MNQ starting value:

Zone thickness: 20 ticks, or 5 points

A smaller zone is more precise but may be invalidated or missed more easily.

A larger zone captures a broader area but may create less precise entries.

Zone thickness should generally be adjusted according to the instrument’s volatility and the selected detection timeframe.

Step 4: Configure the Rejection Filters

Recommended starting settings:

Require correct approach direction: On
Minimum rejection wick: 4 ticks
Require displacement: On
Displacement mode: Ticks
Minimum displacement: 20 ticks
Displacement window: 3 bars

These settings require price to produce a meaningful reaction after contacting the area.

For instruments or timeframes with changing volatility, ATR displacement can be used instead of a fixed tick amount.

Step 5: Configure the Volume Profile

Recommended intraday starting configuration:

Use completed-profile POC confluence: On
Profile timeframe: 1D
Profile session: Exchange regular
POC lookback: 5
Footprint row size: 4 ticks
POC overlap tolerance: 0–4 ticks

The profile timeframe must be higher than the chart timeframe.

Use Exchange regular when regular-session institutional volume is the main focus.

Use Extended/full when overnight and extended-session volume should be included.

Step 6: Read the Zones
Regular Zone

A regular zone has reached the minimum rejection requirement but has not reached the strong threshold and does not overlap a selected POC.

It is a valid area, but it has the lowest visual priority.

Strong Zone

A strong zone has received at least the selected number of valid rejections.

Repeated rejection suggests that the area has continued to influence price.

POC Zone

A POC zone is a confirmed support or resistance zone that overlaps a POC from the selected completed-profile lookback.

This combines:

Repeated price rejection
Structural support or resistance
High historical traded volume

POC confluence increases visual importance, but it does not guarantee that the zone will hold.

Suggested Trading Workflow

The indicator identifies reaction areas. It does not automatically provide buy or sell entries.

Long Setup
Establish a bullish directional bias.
Wait for price to return to a support zone.
Give greater attention to strong or POC-confluence support.
Look for lower-timeframe confirmation, such as:
A liquidity sweep and close back above the zone
A bullish rejection candle
A higher low
A bullish market-structure shift
Positive volume or delta confirmation
Consider invalidation below the zone and an appropriate buffer.
Use the next resistance zone or another planned level as a potential target.
Short Setup
Establish a bearish directional bias.
Wait for price to return to a resistance zone.
Give greater attention to strong or POC-confluence resistance.
Look for lower-timeframe confirmation, such as:
A liquidity sweep and close back below the zone
A bearish rejection candle
A lower high
A bearish market-structure shift
Negative volume or delta confirmation
Consider invalidation above the zone and an appropriate buffer.
Use the next support zone or another planned level as a potential target.

Zones should be treated as areas where a reaction may occur, not as automatic entry signals.

Settings Guide
1. Zone Detection
Zone Detection Timeframe

Controls the timeframe used to detect pivots and rejections.

It must be equal to or higher than the current chart timeframe.

Pivot Bars Left

Controls how many bars must appear to the left of a pivot.

Higher values produce fewer and more significant pivots.

Pivot Bars Right

Controls how many bars must form after a pivot before it is confirmed.

Higher values provide more selective confirmation but cause zones to appear later.

Minimum Rejections

The number of separate valid rejections required before a zone becomes visible.

Strong-Zone Rejections

The number of valid rejections required to upgrade a confirmed zone to strong status.

The script will never allow the effective strong threshold to be lower than the minimum confirmation threshold.

Minimum Bars Between Rejections

Controls how many detection-timeframe bars must separate two counted rejections.

Minimum Rejection Wick

Defines how far the pivot candle must close away from its high or low.

For resistance, the pivot candle must close below its high by this amount.

For support, the pivot candle must close above its low by this amount.

Set it to zero to disable this filter.

Require Correct Approach Direction

When enabled:

Resistance should be approached from below.
Support should be approached from above.

This helps prevent sideways price action from repeatedly creating levels inside congestion.

Require Displacement After Rejection

Requires price to move a minimum distance away from the rejection before it is accepted.

Displacement Mode

Choose between:

Fixed ticks
ATR-based displacement
Minimum Displacement

The fixed tick distance required when using Ticks mode.

Displacement Window

The number of bars immediately following the pivot that are examined for displacement.

The effective window cannot exceed the number of pivot-right bars because the rejection must remain fully confirmed.

ATR Length and Multiplier

Control the volatility-adjusted displacement requirement when ATR mode is selected.

2. Zone Construction and Life
Zone Thickness

Controls the vertical size of every support and resistance zone in ticks.

Zone Merge Tolerance

Controls how close two same-direction rejection areas can be before they are grouped together.

Zone Freshness Lookback

Deletes levels whose most recent valid rejection is older than the selected number of days.

Zone Length

Choose between continuous extension until invalidation or a fixed number of detection bars.

Fixed Length

Controls how many detection-timeframe bars a fixed-length zone remains active.

Break Confirmation Candle

Selects whether invalidation is confirmed by the detection timeframe or current chart timeframe.

Break Buffer

Adds extra space beyond the outside boundary before a zone is deleted.

For MNQ:

4 ticks = 1 point
8 ticks = 2 points
Maximum Tracked Levels

Limits the total number of zone records stored by the indicator.

This includes both:

Hidden one-rejection candidates
Visible confirmed zones

When the limit is exceeded, the oldest level based on its most recent rejection is removed.

3. Session Volume Profile Confluence
Use Completed-Profile POC Confluence

Turns POC analysis on or off.

Profile Timeframe

Controls the duration of each completed volume profile.

Use 1D for completed daily profiles.

Profile Session

Choose between exchange regular hours or extended/full-session data.

POC Lookback

Controls how many completed POC rows are retained for confluence testing.

Footprint Row Size

Controls the price height of each footprint row in ticks.

Smaller values provide greater price resolution but may create noisier profile results.

Larger values group more prices into each row.

Value Area Percent

Controls the value-area percentage used when constructing the footprint profile.

The current indicator uses the profile’s POC for zone confluence and does not separately draw VAH or VAL.

POC Overlap Tolerance

Adds a tick allowance around each POC row when checking whether it overlaps a zone.

4. Appearance

The following can be customized independently:

Support color
Resistance color
Regular-zone opacity
Strong-zone opacity
POC-zone opacity
Border width

Zones are drawn behind the candles to keep price action readable.

Recommended MNQ Starting Settings
Setting	Starting Value
Detection timeframe	60 minutes
Pivot bars left	3
Pivot bars right	3
Minimum rejections	2
Strong-zone rejections	3
Minimum bars between rejections	3
Minimum rejection wick	4 ticks
Correct approach direction	On
Displacement filter	On
Displacement mode	Ticks
Minimum displacement	20 ticks
Displacement window	3 bars
Zone thickness	20 ticks
Merge tolerance	8 ticks
Freshness	10 days
Zone length	Until broken
Break confirmation	Detection timeframe
Break buffer	4 ticks
Profile timeframe	1D
Profile session	Exchange regular
POC lookback	5 profiles
Footprint row size	4 ticks
POC tolerance	0–4 ticks
Regular opacity	50%
Strong opacity	75%
POC opacity	100%

These are starting values, not universal settings. Different instruments and timeframes may require different zone sizes, displacement requirements, and profile-row sizes.

Available Alerts

The indicator includes alert conditions for:

New support zone
New resistance zone
Zone upgraded to strong
Zone gained POC confluence
Support zone broken
Resistance zone broken

To create an alert:

Add the indicator to the chart.
Select Create Alert.
Choose this indicator under the alert condition.
Select the desired event.
Use Once Per Bar Close when close confirmation is required.
Important Notes
This is an indicator, not an automated strategy.
It does not place trades or calculate position size.
A zone is not displayed until the required rejections are fully confirmed.
Higher pivot-right values create slower but more selective confirmation.
Existing zone boundaries can adjust when a new valid rejection is merged into the same area.
POC appearance can change as completed profiles enter or leave the selected lookback.
Footprint and POC results depend on the data available for the symbol.
Support and resistance zones represent areas of interest, not guaranteed reversal points.
Always combine zones with risk management, market context, and entry confirmation.

Smart Support & Resistance + Session POC is designed to reduce chart clutter while highlighting repeatedly defended price areas and the zones that also contain meaningful historical volume concentration.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © elsrodriguez1

//@version=6
indicator(
     "Smart Support & Resistance + Session POC",
     "Smart S/R + POC",
     overlay = true,
     behind_chart = true,
     max_boxes_count = 200,
     max_bars_back = 5000)

//=============================================================================
// INPUTS
//=============================================================================

string GROUP_DETECTION = "1. Zone Detection"
string detectionTf = input.timeframe("60", "Zone detection timeframe", group = GROUP_DETECTION,
     tooltip = "Zones are calculated from confirmed bars on this timeframe. Keep this timeframe equal to or above the chart timeframe.")
int pivotLeft = input.int(3, "Pivot bars left", minval = 1, maxval = 20, group = GROUP_DETECTION)
int pivotRight = input.int(3, "Pivot bars right", minval = 1, maxval = 20, group = GROUP_DETECTION,
     tooltip = "More right-side bars produce slower but more selective confirmation.")
int minimumRejections = input.int(2, "Minimum rejections", minval = 2, maxval = 10, group = GROUP_DETECTION)
int strongRejectionsInput = input.int(3, "Strong-zone rejections", minval = 2, maxval = 15, group = GROUP_DETECTION)
int minimumBarsBetween = input.int(3, "Minimum bars between rejections", minval = 1, maxval = 100, group = GROUP_DETECTION)
int rejectionWickTicks = input.int(4, "Minimum rejection wick (ticks)", minval = 0, maxval = 500, group = GROUP_DETECTION,
     tooltip = "Resistance requires the pivot candle to close this far below its high. Support requires it to close this far above its low. Set to 0 to disable.")
bool useApproachFilter = input.bool(true, "Require correct approach direction", group = GROUP_DETECTION,
     tooltip = "Resistance should be approached from below. Support should be approached from above.")
bool useDepartureFilter = input.bool(true, "Require displacement after rejection", group = GROUP_DETECTION)
string departureMode = input.string("Ticks", "Displacement mode", options = ["Ticks", "ATR"], group = GROUP_DETECTION)
int departureTicks = input.int(20, "Minimum displacement (ticks)", minval = 1, maxval = 2000, group = GROUP_DETECTION)
int departureBarsInput = input.int(3, "Displacement window (bars)", minval = 1, maxval = 20, group = GROUP_DETECTION,
     tooltip = "The usable window cannot exceed Pivot bars right because the rejection must remain confirmed and non-repainting.")
int atrLength = input.int(14, "ATR length", minval = 1, maxval = 200, group = GROUP_DETECTION)
float atrMultiplier = input.float(0.50, "ATR displacement multiplier", minval = 0.05, maxval = 10.0, step = 0.05, group = GROUP_DETECTION)

string GROUP_ZONE = "2. Zone Construction & Life"
int zoneTicks = input.int(20, "Zone thickness (ticks)", minval = 1, maxval = 2000, group = GROUP_ZONE)
int mergeToleranceTicks = input.int(8, "Zone merge tolerance (ticks)", minval = 0, maxval = 1000, group = GROUP_ZONE)
int freshnessDays = input.int(10, "Zone freshness lookback (days)", minval = 1, maxval = 365, group = GROUP_ZONE,
     tooltip = "A level is removed when its most recent valid rejection is older than this many days.")
string extensionMode = input.string("Until broken", "Zone length", options = ["Until broken", "Fixed detection bars"], group = GROUP_ZONE)
int fixedLengthBars = input.int(100, "Fixed length (detection bars)", minval = 1, maxval = 5000, group = GROUP_ZONE)
string breakTimeframeMode = input.string("Detection timeframe", "Break confirmation candle", options = ["Detection timeframe", "Chart timeframe"], group = GROUP_ZONE,
     tooltip = "Detection timeframe is recommended so a 1-minute close does not invalidate a 1-hour zone.")
int breakBufferTicks = input.int(4, "Break buffer (ticks)", minval = 0, maxval = 1000, group = GROUP_ZONE)
int maxTrackedLevels = input.int(60, "Maximum tracked levels", minval = 10, maxval = 200, group = GROUP_ZONE,
     tooltip = "Includes hidden one-rejection candidates and visible confirmed zones.")

string GROUP_PROFILE = "3. Session Volume Profile Confluence"
bool useProfilePoc = input.bool(true, "Use completed-profile POC confluence", group = GROUP_PROFILE)
string profileTf = input.timeframe("1D", "Profile timeframe", group = GROUP_PROFILE,
     tooltip = "Use 1D for one completed daily/session profile. This timeframe must be above the chart timeframe.")
string profileSessionMode = input.string("Exchange regular", "Profile session", options = ["Exchange regular", "Extended/full"], group = GROUP_PROFILE,
     tooltip = "Exchange regular uses TradingView's exchange-defined regular session. Extended/full includes the extended session when the symbol supports it.")
int profileLookback = input.int(5, "POC lookback (completed profiles)", minval = 1, maxval = 30, group = GROUP_PROFILE)
int profileRowTicks = input.int(4, "Footprint row size (ticks)", minval = 1, maxval = 1000, group = GROUP_PROFILE)
float profileVaPercent = input.float(70.0, "Value area percent", minval = 1.0, maxval = 100.0, step = 1.0, group = GROUP_PROFILE)
int pocToleranceTicks = input.int(0, "POC overlap tolerance (ticks)", minval = 0, maxval = 1000, group = GROUP_PROFILE)

string GROUP_STYLE = "4. Appearance"
color supportColor = input.color(color.rgb(0, 170, 110), "Support color", group = GROUP_STYLE)
color resistanceColor = input.color(color.rgb(210, 55, 70), "Resistance color", group = GROUP_STYLE)
int regularOpacity = input.int(50, "Regular zone opacity (%)", minval = 0, maxval = 100, group = GROUP_STYLE)
int strongOpacity = input.int(75, "Strong zone opacity (%)", minval = 0, maxval = 100, group = GROUP_STYLE)
int pocOpacity = input.int(100, "POC zone opacity (%)", minval = 0, maxval = 100, group = GROUP_STYLE)
int borderWidth = input.int(1, "Border width", minval = 0, maxval = 4, group = GROUP_STYLE)

//=============================================================================
// TYPES AND STATE
//=============================================================================

type ZoneRecord
    bool isSupport
    float top
    float bottom
    int touches
    int firstTouchTime
    int lastTouchTime
    int confirmationTime
    int expiryTime
    bool confirmed
    bool pocConfluence
    box zoneBox

var array<ZoneRecord> zones = array.new<ZoneRecord>()
var array<float> pocTops = array.new_float()
var array<float> pocBottoms = array.new_float()

float tickSize = syminfo.mintick
float zoneHeight = zoneTicks * tickSize
float mergeTolerance = mergeToleranceTicks * tickSize
float breakBuffer = breakBufferTicks * tickSize
float pocTolerance = pocToleranceTicks * tickSize
int strongRejections = math.max(strongRejectionsInput, minimumRejections)
int detectionMs = int(timeframe.in_seconds(detectionTf) * 1000.0)
int minimumTouchSpacingMs = detectionMs * minimumBarsBetween
int freshnessMs = freshnessDays * 24 * 60 * 60 * 1000

//=============================================================================
// UTILITY FUNCTIONS
//=============================================================================

f_visibleOpacity(ZoneRecord z) =>
    z.pocConfluence ? pocOpacity : z.touches >= strongRejections ? strongOpacity : regularOpacity

f_baseColor(ZoneRecord z) =>
    z.isSupport ? supportColor : resistanceColor

f_fillColor(ZoneRecord z) =>
    color.new(f_baseColor(z), 100 - f_visibleOpacity(z))

f_borderColor(ZoneRecord z) =>
    color.new(f_baseColor(z), 100 - f_visibleOpacity(z))

f_hasPocConfluence(float top, float bottom) =>
    bool hasConfluence = false
    int pocCount = array.size(pocTops)
    if useProfilePoc and pocCount > 0
        for i = 0 to pocCount - 1
            float pocTop = array.get(pocTops, i)
            float pocBottom = array.get(pocBottoms, i)
            bool overlaps = pocTop + pocTolerance >= bottom and pocBottom - pocTolerance <= top
            if overlaps
                hasConfluence := true
                break
    hasConfluence

f_zoneExpiry(int confirmationTime) =>
    extensionMode == "Fixed detection bars" ? confirmationTime + detectionMs * fixedLengthBars : confirmationTime

f_createBox(ZoneRecord z) =>
    int rightTime = extensionMode == "Fixed detection bars" ? z.expiryTime : z.confirmationTime
    box.new(
         left = z.firstTouchTime,
         top = z.top,
         right = rightTime,
         bottom = z.bottom,
         xloc = xloc.bar_time,
         extend = extensionMode == "Until broken" ? extend.right : extend.none,
         border_color = f_borderColor(z),
         border_width = borderWidth,
         bgcolor = f_fillColor(z))

f_updateBox(ZoneRecord z) =>
    if z.confirmed and not na(z.zoneBox)
        box.set_left(z.zoneBox, z.firstTouchTime)
        box.set_top(z.zoneBox, z.top)
        box.set_bottom(z.zoneBox, z.bottom)
        box.set_border_color(z.zoneBox, f_borderColor(z))
        box.set_border_width(z.zoneBox, borderWidth)
        box.set_bgcolor(z.zoneBox, f_fillColor(z))
        if extensionMode == "Fixed detection bars"
            box.set_right(z.zoneBox, z.expiryTime)
            box.set_extend(z.zoneBox, extend.none)
        else
            box.set_right(z.zoneBox, z.confirmationTime)
            box.set_extend(z.zoneBox, extend.right)

f_removeZone(int index) =>
    ZoneRecord z = array.get(zones, index)
    if not na(z.zoneBox)
        box.delete(z.zoneBox)
    array.remove(zones, index)

f_enforceRecordLimit() =>
    while array.size(zones) > maxTrackedLevels
        int oldestIndex = 0
        ZoneRecord firstRecord = array.get(zones, 0)
        int oldestTime = firstRecord.lastTouchTime
        if array.size(zones) > 1
            for i = 1 to array.size(zones) - 1
                int candidateTime = array.get(zones, i).lastTouchTime
                if candidateTime < oldestTime
                    oldestTime := candidateTime
                    oldestIndex := i
        f_removeZone(oldestIndex)

f_addRejection(bool isSupport, float rejectionPrice, int rejectionTime) =>
    bool confirmedNow = false
    bool strongNow = false
    bool pocNow = false

    float proposedTop = isSupport ? rejectionPrice + zoneHeight : rejectionPrice
    float proposedBottom = isSupport ? rejectionPrice : rejectionPrice - zoneHeight

    int matchIndex = -1
    float bestDistance = 1e20
    int zoneCount = array.size(zones)

    if zoneCount > 0
        for i = 0 to zoneCount - 1
            ZoneRecord z = array.get(zones, i)
            if z.isSupport == isSupport
                bool overlaps = proposedTop + mergeTolerance >= z.bottom and proposedBottom - mergeTolerance <= z.top
                if overlaps
                    float zAnchor = isSupport ? z.bottom : z.top
                    float distance = math.abs(rejectionPrice - zAnchor)
                    if distance < bestDistance
                        bestDistance := distance
                        matchIndex := i

    if matchIndex == -1
        ZoneRecord newZone = ZoneRecord.new(
             isSupport,
             proposedTop,
             proposedBottom,
             1,
             rejectionTime,
             rejectionTime,
             na,
             na,
             false,
             false,
             na)
        array.push(zones, newZone)
    else
        ZoneRecord z = array.get(zones, matchIndex)
        bool separateVisit = rejectionTime > z.lastTouchTime and rejectionTime - z.lastTouchTime >= minimumTouchSpacingMs

        if separateVisit
            int oldTouches = z.touches
            bool oldPoc = z.pocConfluence

            z.touches += 1
            z.lastTouchTime := rejectionTime

            if isSupport
                z.bottom := math.min(z.bottom, rejectionPrice)
                z.top := z.bottom + zoneHeight
            else
                z.top := math.max(z.top, rejectionPrice)
                z.bottom := z.top - zoneHeight

            if not z.confirmed and z.touches >= minimumRejections
                z.confirmed := true
                z.confirmationTime := rejectionTime
                z.expiryTime := f_zoneExpiry(rejectionTime)
                z.pocConfluence := f_hasPocConfluence(z.top, z.bottom)
                z.zoneBox := f_createBox(z)
                confirmedNow := true
                pocNow := z.pocConfluence
            else if z.confirmed
                z.pocConfluence := f_hasPocConfluence(z.top, z.bottom)
                strongNow := oldTouches < strongRejections and z.touches >= strongRejections
                pocNow := not oldPoc and z.pocConfluence
                f_updateBox(z)

            array.set(zones, matchIndex, z)

    f_enforceRecordLimit()
    [confirmedNow, strongNow, pocNow]

f_recalculatePocConfluence() =>
    bool upgraded = false
    int zoneCount = array.size(zones)
    if zoneCount > 0
        for i = 0 to zoneCount - 1
            ZoneRecord z = array.get(zones, i)
            if z.confirmed
                bool oldPoc = z.pocConfluence
                z.pocConfluence := f_hasPocConfluence(z.top, z.bottom)
                upgraded := upgraded or (not oldPoc and z.pocConfluence)
                f_updateBox(z)
                array.set(zones, i, z)
    upgraded

// This function runs inside the selected detection timeframe.
f_detectionData() =>
    int departureBars = math.max(1, math.min(departureBarsInput, pivotRight))
    float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
    float pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

    float atrAtPivot = ta.atr(atrLength)[pivotRight]
    float requiredDeparture = departureMode == "ATR" ? atrAtPivot * atrMultiplier : departureTicks * syminfo.mintick

    // Measure the first N bars immediately after the pivot, not simply the most recent N bars.
    float postPivotLow = na
    float postPivotHigh = na
    for step = 1 to departureBars
        int offset = pivotRight - step
        postPivotLow := na(postPivotLow) ? low[offset] : math.min(postPivotLow, low[offset])
        postPivotHigh := na(postPivotHigh) ? high[offset] : math.max(postPivotHigh, high[offset])

    bool resistanceApproach = not useApproachFilter or close[pivotRight + 1] < pivotHigh - zoneHeight
    bool supportApproach = not useApproachFilter or close[pivotRight + 1] > pivotLow + zoneHeight
    bool resistanceWick = close[pivotRight] <= pivotHigh - rejectionWickTicks * syminfo.mintick
    bool supportWick = close[pivotRight] >= pivotLow + rejectionWickTicks * syminfo.mintick
    bool resistanceDeparture = not useDepartureFilter or postPivotLow <= pivotHigh - requiredDeparture
    bool supportDeparture = not useDepartureFilter or postPivotHigh >= pivotLow + requiredDeparture

    int resistanceValid = not na(pivotHigh) and resistanceApproach and resistanceWick and resistanceDeparture ? 1 : 0
    int supportValid = not na(pivotLow) and supportApproach and supportWick and supportDeparture ? 1 : 0
    int resistanceTime = not na(pivotHigh) ? time[pivotRight] : na
    int supportTime = not na(pivotLow) ? time[pivotRight] : na

    [pivotHigh, pivotLow, resistanceTime, supportTime, resistanceValid, supportValid, close, time]

//=============================================================================
// TIMEFRAME VALIDATION
//=============================================================================

if barstate.isfirst
    if timeframe.in_seconds(detectionTf) < timeframe.in_seconds()
        runtime.error("Zone detection timeframe must be equal to or higher than the chart timeframe.")
    if useProfilePoc and timeframe.in_seconds(profileTf) <= timeframe.in_seconds()
        runtime.error("Profile timeframe must be higher than the chart timeframe when POC confluence is enabled.")

//=============================================================================
// REQUEST CONFIRMED DETECTION-TIMEFRAME DATA
//=============================================================================

[detPivotHigh, detPivotLow, detResistanceTime, detSupportTime, detResistanceValid, detSupportValid, detClose, detBarTime] = request.security(
     syminfo.tickerid,
     detectionTf,
     f_detectionData(),
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off)

//=============================================================================
// REQUEST ONE CONFIRMED PROFILE FOOTPRINT
//=============================================================================

string profileTicker = profileSessionMode == "Exchange regular" ?
     ticker.new(syminfo.prefix, syminfo.ticker, session.regular) :
     ticker.new(syminfo.prefix, syminfo.ticker, session.extended)

footprint completedProfile = request.security(
     profileTicker,
     profileTf,
     request.footprint(profileRowTicks, profileVaPercent)[1],
     barmerge.gaps_on,
     barmerge.lookahead_on)

bool newPocProfile = false
if useProfilePoc and not na(completedProfile)
    volume_row pocRow = completedProfile.poc()
    array.push(pocTops, pocRow.up_price())
    array.push(pocBottoms, pocRow.down_price())
    while array.size(pocTops) > profileLookback
        array.shift(pocTops)
        array.shift(pocBottoms)
    newPocProfile := true

//=============================================================================
// EVENT FLAGS
//=============================================================================

bool newSupportZone = false
bool newResistanceZone = false
bool strongZoneUpgrade = false
bool pocZoneUpgrade = false
bool supportZoneBroken = false
bool resistanceZoneBroken = false

// Recalculate every confirmed zone when a completed profile enters or leaves the POC lookback.
if newPocProfile
    pocZoneUpgrade := f_recalculatePocConfluence()

//=============================================================================
// BREAK / INVALIDATION LOGIC
//=============================================================================

bool detectionCloseAvailable = not na(detBarTime) and not na(detClose)
bool evaluateBreak = breakTimeframeMode == "Detection timeframe" ? detectionCloseAvailable : barstate.isconfirmed
float breakClose = breakTimeframeMode == "Detection timeframe" ? detClose : close

if evaluateBreak and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        ZoneRecord z = array.get(zones, i)
        bool broken = z.isSupport ? breakClose < z.bottom - breakBuffer : breakClose > z.top + breakBuffer
        if broken
            supportZoneBroken := supportZoneBroken or z.isSupport
            resistanceZoneBroken := resistanceZoneBroken or not z.isSupport
            f_removeZone(i)

//=============================================================================
// ADD NEW, FULLY CONFIRMED REJECTIONS
//=============================================================================

if detResistanceValid == 1 and not na(detPivotHigh) and not na(detResistanceTime)
    [confirmedNow, strongNow, pocNow] = f_addRejection(false, detPivotHigh, detResistanceTime)
    newResistanceZone := newResistanceZone or confirmedNow
    strongZoneUpgrade := strongZoneUpgrade or strongNow
    pocZoneUpgrade := pocZoneUpgrade or pocNow

if detSupportValid == 1 and not na(detPivotLow) and not na(detSupportTime)
    [confirmedNow, strongNow, pocNow] = f_addRejection(true, detPivotLow, detSupportTime)
    newSupportZone := newSupportZone or confirmedNow
    strongZoneUpgrade := strongZoneUpgrade or strongNow
    pocZoneUpgrade := pocZoneUpgrade or pocNow

//=============================================================================
// FRESHNESS AND FIXED-LENGTH CLEANUP
//=============================================================================

int freshnessCutoff = time - freshnessMs
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        ZoneRecord z = array.get(zones, i)
        bool stale = z.lastTouchTime < freshnessCutoff
        bool fixedExpired = z.confirmed and extensionMode == "Fixed detection bars" and time > z.expiryTime
        if stale or fixedExpired
            f_removeZone(i)

//=============================================================================
// ALERTS
//=============================================================================

alertcondition(newSupportZone, "New support zone", "A new support zone has been confirmed by the required number of rejections.")
alertcondition(newResistanceZone, "New resistance zone", "A new resistance zone has been confirmed by the required number of rejections.")
alertcondition(strongZoneUpgrade, "Zone upgraded to strong", "A confirmed zone reached the strong-rejection threshold.")
alertcondition(pocZoneUpgrade, "Zone gained POC confluence", "A confirmed zone overlaps a POC inside the selected completed-profile lookback.")
alertcondition(supportZoneBroken, "Support zone broken", "A candle closed below a support zone plus its break buffer. The zone was deleted.")
alertcondition(resistanceZoneBroken, "Resistance zone broken", "A candle closed above a resistance zone plus its break buffer. The zone was deleted.")
````
