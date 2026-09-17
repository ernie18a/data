<!-- tradingview-pine-id: PUB;66bc2db6cc57419e8ef228f6d98e9c53 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Global Cash Market Open Close Handoff Sequence

Source: https://www.tradingview.com/script/dizubEmQ-Global-Cash-Market-Open-Close-Handoff-Sequence/

## Description

Global Cash Market Open Close Handoff Sequence is a schedule-state transition study for configurable cash-market reference hours.

The vertical line is only the presentation layer. At each unique boundary timestamp, the script generates and consolidates scheduled OPEN, BREAK, RESUME, and CLOSE events, evaluates the configured active-market state immediately before and after that timestamp, and classifies how the tracked market schedule changes.

Instead of displaying every market event as an unrelated line, the script treats the enabled markets as one chronological system. It shows how that system activates, gains overlap, changes market identity, releases overlap, and deactivates through the trading day.

The classification engine uses schedule state only. It does not use price direction, session highs or lows, volume, volatility, external symbols, higher-timeframe data, or future price assumptions.

Core transition model

Every consolidated boundary is assigned one of the following descriptive roles:

- ACTIVATE: No configured market is active before the boundary, and one or more markets are active after it.

- OVERLAP +: The number of configured active markets increases across the boundary.

- HANDOFF: The active-market count remains unchanged, but the composition of the active-market set changes.

- OVERLAP -: The number of configured active markets decreases, while at least one tracked market remains active.

- DEACTIVATE: One or more configured markets are active before the boundary, and none are active after it.

- INTERNAL: A scheduled boundary occurs, but the configured active-market set does not materially change.

HANDOFF is intentionally separate from a normal open, close, or overlap count.

For example, if one market closes while another market opens or resumes at the same timestamp, the number of active markets can remain unchanged even though the identity of the active markets changes. The script detects that composition change and classifies it as a HANDOFF rather than treating the two events as unrelated markers.

Simultaneous-event consolidation

Events that share the same absolute timestamp are merged before they are drawn.

If two or more configured markets open, close, break, or resume at the same time, the script creates one structural boundary instead of stacking multiple vertical lines and overlapping labels at the same chart position.

The merged label lists the events that occurred at that timestamp. The transition role is then calculated from the complete configured state before and after the consolidated boundary.

This makes simultaneous events readable while preserving their individual market identities.

Split-session handling

Each market can contain one or two independently editable trading segments.

When two enabled segments are separated, the script models the market day as:

OPEN
BREAK
RESUME
CLOSE

When the two segments touch or overlap, they are automatically treated as one continuous interval:

OPEN
CLOSE

This allows split cash-market schedules, such as morning and afternoon continuous-trading periods, to be represented without creating a false break when the configured intervals are actually continuous.

Default reference schedules

The default configuration contains six editable cash-market reference schedules:

- Sydney Cash
  10:00-16:00
  Australia/Sydney

- Tokyo Cash
  09:00-11:30 and 12:30-15:30
  Asia/Tokyo

- Hong Kong Cash
  09:30-12:00 and 13:00-16:00
  Asia/Hong_Kong

- Xetra Main Cash
  09:00-17:30
  Europe/Berlin

- London Cash
  08:00-16:30
  Europe/London

- New York Cash
  09:30-16:00
  America/New_York

The default weekday setting is Monday through Friday.

Every market can be enabled or disabled independently. The displayed name, short code, IANA time zone, weekdays, first segment, optional second segment, and color are all editable.

The defaults are reference schedules rather than locked assumptions. Users can adjust them for another market, venue, research convention, or historical schedule.

Time-zone and DST handling

Each market uses its own IANA time-zone identifier.

This allows regional daylight-saving changes to be applied independently. Sydney, London, Xetra, and New York do not rely on one fixed UTC offset, and Asian markets can remain on their configured local schedules.

The chart time zone does not define the market calculations. Market boundaries are generated from each market's configured IANA time zone and placed on the chart using absolute timestamps.

The Boundary Strip has a separate readout time-zone input. Changing that input changes the displayed date and time in the panel without changing the underlying boundary timestamps.

Historical research modes

Visible range is the default research mode.

In this mode, the script rebuilds its boundary sequence around the section of the chart currently being studied. Panning or zooming the chart can therefore change the processed time window and the subset of boundaries retained for display.

The right visible bar acts as the effective anchor. This makes it possible to move to a historical period and inspect the market schedule, active-market state, previous boundary, next boundary, and handoff sequence for that period rather than only for the latest bar.

A configurable visible-span cap prevents an extremely wide chart range from creating an unnecessarily large calculation window. If the displayed range exceeds the cap, the script processes the most recent permitted portion ending at the right visible bar.

Recent days is available as an alternative mode.

Its anchor can follow:

- The right visible bar
- The latest chart bar
- The real clock

This allows the same engine to support historical inspection, dataset-relative inspection, or a clock-relative schedule view.

Future schedule projection

The script can project recurring configured boundaries beyond the effective anchor.

These projected objects represent repetitions of the selected reference schedule. They are not price forecasts, volatility forecasts, liquidity predictions, or claims that an exchange will operate normally on the projected date.

Future projection can be disabled or limited through the settings. The immediate next boundary can be emphasized with a separate color and width so that it remains identifiable without turning every future boundary into a dominant chart object.

Adaptive spread

A complete multi-market schedule can generate many boundaries across a long visible range. Drawing all of them at once would reduce the readability of both the indicator and the underlying price chart.

Adaptive spread is therefore the default line-retention mode.

When the generated boundary count exceeds the selected visual budget, Adaptive spread distributes a capped subset of already generated and classified boundaries across the displayed research span. It attempts to preserve structural variety across the global market sequence and retains the immediate next boundary when one is available.

Adaptive spread changes presentation only.

It does not change:

- The configured market schedules
- The generated event timestamps
- Simultaneous-event consolidation
- The active-market state
- The transition classification
- The Last and Next calculations

The default visible line budget is seven, providing a sparse publication-ready view while leaving price visible.

Users who need a denser local study can increase the line and label budgets or select Nearest anchor. Nearest anchor favors boundaries closest to the effective anchor rather than distributing them across the complete displayed span.

Boundary lines and labels

Lines are drawn behind the chart so that candles and price remain visually dominant.

Users can control:

- Historical and projected boundaries
- Visible line budget
- Line width
- Historical and future transparency
- Directional or uniform line styles
- Market-identity or transition-role colors
- Next-boundary emphasis
- Label visibility
- Label content
- Label placement
- Label lanes
- Minimum spacing
- Maximum label count
- Text size
- Text emphasis
- Label transparency
- Native local time in tooltips

Directional line style distinguishes single-event boundary types:

- OPEN and RESUME use a solid line
- BREAK uses a dotted line
- CLOSE uses a dashed line
- Consolidated multi-event timestamps use a solid structural line

Transition-role color mode emphasizes the change in the configured active-market state.

Market-identity color mode instead preserves the market color associated with the event. Consolidated timestamps can use a dedicated simultaneous-event color.

Labels can show:

- Transition role and event list
- Event list only
- Transition role only

Lane allocation and minimum time spacing reduce label collisions without moving the actual boundary timestamp.

Boundary Strip

The fixed Boundary Strip summarizes the effective research state.

It displays:

- ANCHOR: The timestamp at which the current state is evaluated

- ACTIVE: The configured markets active at the anchor and their count

- LAST: The most recent generated boundary at or before the anchor

- NEXT: The first generated boundary after the anchor

- COUNTDOWN: The time remaining from the anchor to the next boundary

- VIEW: The active schedule scope, retention mode, and any display-cap status

The Active row refers to the effective anchor shown in the panel. Under the default configuration, this is the right visible bar and is not necessarily the current real-world time.

The panel defaults to the lower-left area and includes adjustable bottom clearance to avoid permanent chart furniture. It can also be moved to another left or right chart position, and its text size and emphasis can be changed.

Suggested use

1. Add the indicator to an intraday chart.

2. Begin with the default settings so that the published chart and the user's first view remain consistent.

3. Read the transition role first to understand whether the configured market system is activating, gaining overlap, handing off, releasing overlap, or deactivating.

4. Read the event line below the role to identify the market-specific OPEN, BREAK, RESUME, or CLOSE events that produced that transition.

5. Use the Boundary Strip to confirm the effective anchor, active markets, previous boundary, next boundary, and remaining time.

6. Pan to an earlier period when studying historical market transitions. Visible range mode will rebuild around the displayed chart section.

7. Increase the visual budgets or switch to Nearest anchor only when a more detailed local sequence is required.

8. Edit market schedules, time zones, weekdays, and segments when researching another venue or schedule convention.

This indicator can be placed on any intraday symbol. However, its boundaries remain the configured cash-market references and do not automatically become the native trading session of the charted instrument.

Why this is a separate study

This script is not a continuous session highlighter.

A conventional session highlighter answers:

"Which session interval contains this bar?"

This script instead answers:

"What scheduled events occurred at this timestamp, and how did the configured active-market state change across that boundary?"

It intentionally does not draw session backgrounds, session boxes, opening ranges, session highs or lows, price levels, volume statistics, volatility measures, directional bias, entry signals, exit signals, targets, or strategy results.

It is also different from a generic recurring time marker.

A generic time marker places independent objects at selected times. This script constructs linked market schedules, models separated trading segments, consolidates simultaneous events, evaluates the configured state immediately before and after every unique timestamp, classifies the resulting transition, and presents the result as a chronological handoff sequence.

The focus is deliberately narrow: scheduled cash-market boundary structure and active-market identity changes.

Limitations and interpretation

This is a configurable reference-schedule study, not a live exchange-status service or an official exchange calendar.

The script does not automatically model:

- Exchange holidays
- Early closes
- Delayed openings
- Unscheduled closures
- Security-specific halts
- Historical changes to exchange schedules
- Opening or closing auction phases
- Instrument-specific pre-market or post-market sessions

The Sydney 10:00 and 16:00 defaults are rounded regular-market reference boundaries. Security-level opening sequencing and the later closing auction are outside the model.

The Hong Kong defaults represent the morning and afternoon continuous-trading intervals ending at 16:00. The subsequent closing auction is outside the model.

The remaining schedules likewise represent editable main cash-session references rather than every auction, extended-hours period, or product-specific rule.

Users should verify and edit the reference hours when exact exchange-calendar treatment is required.

Market codes should remain unique. The HANDOFF comparison uses the configured active-market codes to identify changes in composition. Assigning the same code to different enabled markets can make an identity change ambiguous.

The script requires an intraday chart. On a daily or higher timeframe, the Boundary Strip reports that an intraday timeframe is required.

Projected boundaries are recurring schedule references only. They do not predict price direction or confirm that a market will open on a holiday or exceptional date.

ACTIVATE, OVERLAP +, HANDOFF, OVERLAP -, DEACTIVATE, and INTERNAL are descriptive schedule classifications. They are not buy signals, sell signals, entry instructions, exit instructions, or assessments of future market behavior.

The script does not contain strategy orders, backtesting logic, performance statistics, or alert conditions.

The source code is published openly so users can inspect, verify, study, and modify the schedule and visualization logic.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG_Group
//@version=6
indicator(
     "Global Cash Market Open Close Handoff Sequence",
     shorttitle = "MktHandoff",
     overlay = true,
     scale = scale.none,
     max_lines_count = 500,
     max_labels_count = 300,
     behind_chart = true)

// =============================================================================
// PURPOSE
// =============================================================================
// Boundary-only market-clock study. It draws exact open, break, resume, and
// close timestamps for configurable cash-market references. Simultaneous
// events are merged, and each timestamp can be classified by how the tracked
// active-market set changes across it.
//
// This script intentionally does not draw session backgrounds, price ranges,
// highs/lows, volume studies, trading signals, or performance claims.
// The default visual profile is deliberately sparse: a small adaptive set of
// real boundary timestamps is distributed across the displayed research span,
// lines render behind price, and bold captions stay on a compact top rail. Users can
// raise the line budget or switch to nearest-anchor retention when they need a
// denser forensic view. The fixed readout uses visual row marks and a
// transparent bottom clearance so it remains readable without colliding with
// permanent chart furniture.
// Default schedules are editable reference hours. Exchange holidays, early
// closes, auctions, unscheduled closures, and historical schedule changes are
// not modeled. Contiguous or overlapping segments are rendered as one active
// interval; separated segments create BREAK and RESUME boundaries.

// =============================================================================
// CONSTANTS AND DATA TYPES
// =============================================================================
const int MINUTE_MS = 60 * 1000
const int HOUR_MS   = 60 * MINUTE_MS
const int DAY_MS    = 24 * HOUR_MS

const int EVENT_OPEN   = 1
const int EVENT_BREAK  = 2
const int EVENT_RESUME = 3
const int EVENT_CLOSE  = 4

const string GROUP_WINDOW = "1. Research Window"
const string GROUP_LABELS = "2. Boundary Labels"
const string GROUP_LINES  = "3. Boundary Lines"
const string GROUP_ROLES  = "4. Handoff Classification"
const string GROUP_STRIP  = "5. Boundary Strip"
const string GROUP_SYDNEY = "6. Sydney Cash Reference"
const string GROUP_TOKYO  = "7. Tokyo Cash Reference"
const string GROUP_HK     = "8. Hong Kong Cash Reference"
const string GROUP_FRA    = "9. Frankfurt / Xetra Main Cash Reference"
const string GROUP_LON    = "10. London Cash Reference"
const string GROUP_NY     = "11. New York Cash Reference"

type Market
    bool enabled
    string name
    string code
    string tz
    string weekdays
    string segmentOne
    bool segmentTwoEnabled
    string segmentTwo
    color tint

// =============================================================================
// INPUTS
// Every input uses display.none so the chart status line shows only the
// indicator's short title rather than a trail of parameter values.
// =============================================================================
string scheduleScope = input.string(
     "Visible range",
     "Schedule scope",
     options = ["Visible range", "Recent days"],
     tooltip = "Visible range rebuilds around the part of the chart you are studying. Recent days follows the selected anchor instead.",
     group = GROUP_WINDOW,
     display = display.none)

int visibleSpanCapDays = input.int(
     90,
     "Maximum visible span to process (days)",
     minval = 3,
     maxval = 365,
     tooltip = "When the visible chart covers more than this span, the script retains the most recent portion ending at the right visible bar.",
     group = GROUP_WINDOW,
     display = display.none,
     active = scheduleScope == "Visible range")

int recentPastDays = input.int(
     10,
     "Past days",
     minval = 1,
     maxval = 45,
     group = GROUP_WINDOW,
     display = display.none,
     active = scheduleScope == "Recent days")

string anchorMode = input.string(
     "Right visible bar",
     "Recent-days anchor",
     options = ["Right visible bar", "Latest chart bar", "Real clock"],
     tooltip = "Right visible bar is suitable for historical study. Latest chart bar follows the dataset. Real clock follows timenow and can extend beyond the latest bar.",
     group = GROUP_WINDOW,
     display = display.none,
     active = scheduleScope == "Recent days")

int futureProjectionDays = input.int(
     2,
     "Future projection days",
     minval = 0,
     maxval = 7,
     tooltip = "Projects recurring reference boundaries forward from the effective anchor. This is a time schedule, not a price forecast.",
     group = GROUP_WINDOW,
     display = display.none)

string readoutTimezone = input.string(
     "Etc/UTC",
     "Boundary Strip time zone",
     tooltip = "Use a valid IANA identifier such as Etc/UTC, Asia/Tokyo, Europe/London, or America/New_York.",
     group = GROUP_WINDOW,
     display = display.none)

bool showHistoricalLines = input.bool(
     true,
     "Show boundaries at or before anchor",
     group = GROUP_WINDOW,
     display = display.none)

bool showFutureLines = input.bool(
     true,
     "Show projected boundaries after anchor",
     group = GROUP_WINDOW,
     display = display.none,
     active = futureProjectionDays > 0)

// Boundary labels.
bool showBoundaryLabels = input.bool(
     true,
     "Show boundary labels",
     group = GROUP_LABELS,
     display = display.none)

string labelContent = input.string(
     "Role + events",
     "Label content",
     options = ["Role + events", "Events only", "Role only"],
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

string labelPlacement = input.string(
     "Top",
     "Label placement",
     options = ["Alternate", "Top", "Bottom"],
     tooltip = "Alternate distributes labels between upper and lower lanes. Lane spacing reduces collisions without moving timestamps.",
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

int labelLaneCount = input.int(
     2,
     "Lanes per side",
     minval = 1,
     maxval = 4,
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

int labelSpacingMinutes = input.int(
     360,
     "Minimum time spacing per lane (minutes)",
     minval = 15,
     maxval = 1440,
     step = 15,
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

int maximumBoundaryLabels = input.int(
     7,
     "Maximum labels",
     minval = 1,
     maxval = 80,
     tooltip = "Keep this near the visible line budget. Labels are applied only to retained structural lines.",
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

string labelTextSize = input.string(
     "Small",
     "Text size",
     options = ["Tiny", "Small", "Normal"],
     tooltip = "Small is the readability-first default. Use Normal when the chart is displayed on a high-resolution screen or in a large publication image.",
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

bool boldBoundaryLabelText = input.bool(
     true,
     "Bold label text",
     tooltip = "Uses Pine v6 text formatting to keep compact boundary captions legible against the chart.",
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

int labelTransparency = input.int(
     8,
     "Label background transparency",
     minval = 0,
     maxval = 70,
     tooltip = "Lower values create a more opaque caption background and stronger text contrast.",
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

bool showNativeTimeInTooltip = input.bool(
     true,
     "Include native local time in tooltip",
     group = GROUP_LABELS,
     display = display.none,
     active = showBoundaryLabels)

// Boundary lines.
int boundaryLineWidth = input.int(
     1,
     "Standard line width",
     minval = 1,
     maxval = 4,
     group = GROUP_LINES,
     display = display.none)

int maximumBoundaryLines = input.int(
     7,
     "Visible line budget",
     minval = 3,
     maxval = 120,
     tooltip = "Adaptive spread uses this as the target number of real boundary timestamps. Increase it only when a denser research view is required.",
     group = GROUP_LINES,
     display = display.none)

string lineRetentionMode = input.string(
     "Adaptive spread",
     "Line retention",
     options = ["Adaptive spread", "Nearest anchor"],
     tooltip = "Adaptive spread distributes retained boundaries across the displayed time span. Nearest anchor preserves the former dense research behavior around the effective anchor.",
     group = GROUP_LINES,
     display = display.none)

string lineColorMode = input.string(
     "Transition role",
     "Line color mode",
     options = ["Market identity", "Transition role"],
     tooltip = "Market identity preserves each market color. Transition role recolors lines by the active-market change across the timestamp.",
     group = GROUP_LINES,
     display = display.none)

string lineStyleMode = input.string(
     "Directional",
     "Line style mode",
     options = ["Directional", "Uniform"],
     tooltip = "Directional uses solid for open/resume, dotted for breaks, dashed for closes, and solid for merged timestamps.",
     group = GROUP_LINES,
     display = display.none)

string uniformLineStyle = input.string(
     "Solid",
     "Uniform style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_LINES,
     display = display.none,
     active = lineStyleMode == "Uniform")

int historicalTransparency = input.int(
     58,
     "Historical line transparency",
     minval = 0,
     maxval = 85,
     group = GROUP_LINES,
     display = display.none)

int futureTransparency = input.int(
     44,
     "Future line transparency",
     minval = 0,
     maxval = 85,
     group = GROUP_LINES,
     display = display.none)

color simultaneousEventColor = input.color(
     color.rgb(255, 193, 7),
     "Simultaneous-event color",
     tooltip = "Used when multiple tracked market events occur at the same absolute timestamp.",
     group = GROUP_LINES,
     display = display.none)

bool emphasizeNextBoundary = input.bool(
     true,
     "Emphasize next boundary",
     group = GROUP_LINES,
     display = display.none)

color nextBoundaryColor = input.color(
     color.rgb(255, 215, 0),
     "Next-boundary color",
     group = GROUP_LINES,
     display = display.none,
     active = emphasizeNextBoundary)

// Handoff classification.
bool classifyBoundaryRoles = input.bool(
     true,
     "Classify active-market transitions",
     tooltip = "Compares the configured active-market set immediately before and after each boundary. This is descriptive schedule logic, not a trading signal.",
     group = GROUP_ROLES,
     display = display.none)

color activationColor = input.color(
     color.rgb(0, 188, 255),
     "Activation (none to active)",
     group = GROUP_ROLES,
     display = display.none,
     active = classifyBoundaryRoles)

color overlapBuildColor = input.color(
     color.rgb(76, 217, 100),
     "Overlap build (active count rises)",
     group = GROUP_ROLES,
     display = display.none,
     active = classifyBoundaryRoles)

color handoffColor = input.color(
     color.rgb(255, 179, 0),
     "Handoff (same count, different markets)",
     group = GROUP_ROLES,
     display = display.none,
     active = classifyBoundaryRoles)

color overlapReleaseColor = input.color(
     color.rgb(175, 82, 222),
     "Overlap release (active count falls)",
     group = GROUP_ROLES,
     display = display.none,
     active = classifyBoundaryRoles)

color deactivationColor = input.color(
     color.rgb(255, 69, 58),
     "Deactivation (active to none)",
     group = GROUP_ROLES,
     display = display.none,
     active = classifyBoundaryRoles)

color internalBoundaryColor = input.color(
     color.rgb(100, 116, 139),
     "Internal boundary",
     group = GROUP_ROLES,
     display = display.none,
     active = classifyBoundaryRoles)

// Compact fixed-position readout. Default is bottom-left to avoid the right
// price scale and High/Low labels.
bool showBoundaryStrip = input.bool(
     true,
     "Show Boundary Strip",
     group = GROUP_STRIP,
     display = display.none)

string boundaryStripPosition = input.string(
     "Bottom left",
     "Position",
     options = ["Bottom left", "Middle left", "Top left", "Bottom right", "Middle right", "Top right"],
     tooltip = "Bottom-left remains the default. A transparent clearance row lifts the visible panel above TradingView's permanent lower-left branding area.",
     group = GROUP_STRIP,
     display = display.none,
     active = showBoundaryStrip)

string boundaryStripTextSize = input.string(
     "Small",
     "Text size",
     options = ["Tiny", "Small", "Normal"],
     tooltip = "Small is the readability-first default for the fixed readout.",
     group = GROUP_STRIP,
     display = display.none,
     active = showBoundaryStrip)

bool boldBoundaryStripText = input.bool(
     true,
     "Bold panel text",
     tooltip = "Applies bold formatting to the panel header, keys, values, and visual marks.",
     group = GROUP_STRIP,
     display = display.none,
     active = showBoundaryStrip)

float boundaryStripBottomClearance = input.float(
     4.0,
     "Bottom clearance (% of pane)",
     minval = 0.0,
     maxval = 15.0,
     step = 0.5,
     tooltip = "Raises a bottom-anchored panel above the lower-left or lower-right chart furniture without moving it away from the corner. Set to zero to disable.",
     group = GROUP_STRIP,
     display = display.none,
     active = showBoundaryStrip and (boundaryStripPosition == "Bottom left" or boundaryStripPosition == "Bottom right"))

bool showSecondsInCountdown = input.bool(
     false,
     "Show seconds when under one hour",
     group = GROUP_STRIP,
     display = display.none,
     active = showBoundaryStrip)

// Market presets. All fields remain editable for research.
bool sydneyEnabled = input.bool(true, "Enable", inline = "syd0", group = GROUP_SYDNEY, display = display.none)
string sydneyCode = input.string("SYD", "Code", inline = "syd0", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)
string sydneyName = input.string("Sydney Cash", "Name", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)
string sydneyTimezone = input.string("Australia/Sydney", "IANA time zone", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)
string sydneyWeekdays = input.string("23456", "Active weekdays (1 Sun ... 7 Sat)", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)
string sydneySegmentOne = input.session("1000-1600", "Primary segment", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)
bool sydneySegmentTwoEnabled = input.bool(false, "Use second segment", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)
string sydneySegmentTwo = input.session("0000-0000", "Second segment", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled and sydneySegmentTwoEnabled)
color sydneyColor = input.color(color.rgb(0, 174, 239), "Color", group = GROUP_SYDNEY, display = display.none, active = sydneyEnabled)

bool tokyoEnabled = input.bool(true, "Enable", inline = "tyo0", group = GROUP_TOKYO, display = display.none)
string tokyoCode = input.string("TYO", "Code", inline = "tyo0", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)
string tokyoName = input.string("Tokyo Cash", "Name", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)
string tokyoTimezone = input.string("Asia/Tokyo", "IANA time zone", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)
string tokyoWeekdays = input.string("23456", "Active weekdays (1 Sun ... 7 Sat)", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)
string tokyoSegmentOne = input.session("0900-1130", "Morning segment", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)
bool tokyoSegmentTwoEnabled = input.bool(true, "Use afternoon segment", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)
string tokyoSegmentTwo = input.session("1230-1530", "Afternoon segment", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled and tokyoSegmentTwoEnabled)
color tokyoColor = input.color(color.rgb(238, 61, 190), "Color", group = GROUP_TOKYO, display = display.none, active = tokyoEnabled)

bool hongKongEnabled = input.bool(true, "Enable", inline = "hkg0", group = GROUP_HK, display = display.none)
string hongKongCode = input.string("HKG", "Code", inline = "hkg0", group = GROUP_HK, display = display.none, active = hongKongEnabled)
string hongKongName = input.string("Hong Kong Cash", "Name", group = GROUP_HK, display = display.none, active = hongKongEnabled)
string hongKongTimezone = input.string("Asia/Hong_Kong", "IANA time zone", group = GROUP_HK, display = display.none, active = hongKongEnabled)
string hongKongWeekdays = input.string("23456", "Active weekdays (1 Sun ... 7 Sat)", group = GROUP_HK, display = display.none, active = hongKongEnabled)
string hongKongSegmentOne = input.session("0930-1200", "Morning segment", group = GROUP_HK, display = display.none, active = hongKongEnabled)
bool hongKongSegmentTwoEnabled = input.bool(true, "Use afternoon segment", group = GROUP_HK, display = display.none, active = hongKongEnabled)
string hongKongSegmentTwo = input.session("1300-1600", "Afternoon segment", group = GROUP_HK, display = display.none, active = hongKongEnabled and hongKongSegmentTwoEnabled)
color hongKongColor = input.color(color.rgb(245, 158, 11), "Color", group = GROUP_HK, display = display.none, active = hongKongEnabled)

bool frankfurtEnabled = input.bool(true, "Enable", inline = "fra0", group = GROUP_FRA, display = display.none)
string frankfurtCode = input.string("XET", "Code", inline = "fra0", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)
string frankfurtName = input.string("Xetra Main Cash", "Name", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)
string frankfurtTimezone = input.string("Europe/Berlin", "IANA time zone", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)
string frankfurtWeekdays = input.string("23456", "Active weekdays (1 Sun ... 7 Sat)", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)
string frankfurtSegmentOne = input.session("0900-1730", "Primary segment", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)
bool frankfurtSegmentTwoEnabled = input.bool(false, "Use second segment", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)
string frankfurtSegmentTwo = input.session("0000-0000", "Second segment", group = GROUP_FRA, display = display.none, active = frankfurtEnabled and frankfurtSegmentTwoEnabled)
color frankfurtColor = input.color(color.rgb(42, 200, 96), "Color", group = GROUP_FRA, display = display.none, active = frankfurtEnabled)

bool londonEnabled = input.bool(true, "Enable", inline = "lon0", group = GROUP_LON, display = display.none)
string londonCode = input.string("LON", "Code", inline = "lon0", group = GROUP_LON, display = display.none, active = londonEnabled)
string londonName = input.string("London Cash", "Name", group = GROUP_LON, display = display.none, active = londonEnabled)
string londonTimezone = input.string("Europe/London", "IANA time zone", group = GROUP_LON, display = display.none, active = londonEnabled)
string londonWeekdays = input.string("23456", "Active weekdays (1 Sun ... 7 Sat)", group = GROUP_LON, display = display.none, active = londonEnabled)
string londonSegmentOne = input.session("0800-1630", "Primary segment", group = GROUP_LON, display = display.none, active = londonEnabled)
bool londonSegmentTwoEnabled = input.bool(false, "Use second segment", group = GROUP_LON, display = display.none, active = londonEnabled)
string londonSegmentTwo = input.session("0000-0000", "Second segment", group = GROUP_LON, display = display.none, active = londonEnabled and londonSegmentTwoEnabled)
color londonColor = input.color(color.rgb(111, 91, 255), "Color", group = GROUP_LON, display = display.none, active = londonEnabled)

bool newYorkEnabled = input.bool(true, "Enable", inline = "nyc0", group = GROUP_NY, display = display.none)
string newYorkCode = input.string("NYC", "Code", inline = "nyc0", group = GROUP_NY, display = display.none, active = newYorkEnabled)
string newYorkName = input.string("New York Cash", "Name", group = GROUP_NY, display = display.none, active = newYorkEnabled)
string newYorkTimezone = input.string("America/New_York", "IANA time zone", group = GROUP_NY, display = display.none, active = newYorkEnabled)
string newYorkWeekdays = input.string("23456", "Active weekdays (1 Sun ... 7 Sat)", group = GROUP_NY, display = display.none, active = newYorkEnabled)
string newYorkSegmentOne = input.session("0930-1600", "Primary segment", group = GROUP_NY, display = display.none, active = newYorkEnabled)
bool newYorkSegmentTwoEnabled = input.bool(false, "Use second segment", group = GROUP_NY, display = display.none, active = newYorkEnabled)
string newYorkSegmentTwo = input.session("0000-0000", "Second segment", group = GROUP_NY, display = display.none, active = newYorkEnabled and newYorkSegmentTwoEnabled)
color newYorkColor = input.color(color.rgb(255, 59, 92), "Color", group = GROUP_NY, display = display.none, active = newYorkEnabled)

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================
f_sessionStartMinutes(string sessionText) =>
    int hourValue = int(str.tonumber(str.substring(sessionText, 0, 2)))
    int minuteValue = int(str.tonumber(str.substring(sessionText, 2, 4)))
    hourValue * 60 + minuteValue

f_sessionEndMinutes(string sessionText) =>
    int hourValue = int(str.tonumber(str.substring(sessionText, 5, 7)))
    int minuteValue = int(str.tonumber(str.substring(sessionText, 7, 9)))
    hourValue * 60 + minuteValue

f_sessionHasDuration(string sessionText) =>
    f_sessionStartMinutes(sessionText) != f_sessionEndMinutes(sessionText)

f_shiftLocalDate(int yearValue, int monthValue, int dayValue, string timezoneValue, int dayOffset) =>
    int localNoon = timestamp(timezoneValue, yearValue, monthValue, dayValue, 12, 0, 0)
    int shifted = localNoon + dayOffset * DAY_MS
    [year(shifted, timezoneValue), month(shifted, timezoneValue), dayofmonth(shifted, timezoneValue)]

f_sessionBounds(int yearValue, int monthValue, int dayValue, string timezoneValue, string sessionText) =>
    int startMinutes = f_sessionStartMinutes(sessionText)
    int endMinutes = f_sessionEndMinutes(sessionText)
    int startTimestamp = timestamp(
         timezoneValue,
         yearValue,
         monthValue,
         dayValue,
         int(startMinutes / 60),
         startMinutes % 60,
         0)
    int endYear = yearValue
    int endMonth = monthValue
    int endDay = dayValue
    if endMinutes <= startMinutes
        [nextYear, nextMonth, nextDay] = f_shiftLocalDate(yearValue, monthValue, dayValue, timezoneValue, 1)
        endYear := nextYear
        endMonth := nextMonth
        endDay := nextDay
    int endTimestamp = timestamp(
         timezoneValue,
         endYear,
         endMonth,
         endDay,
         int(endMinutes / 60),
         endMinutes % 60,
         0)
    [startTimestamp, endTimestamp]

f_dayAllowed(int localTimestamp, string timezoneValue, string weekdayMask) =>
    int weekdayNumber = dayofweek(localTimestamp, timezoneValue)
    str.contains(weekdayMask, str.tostring(weekdayNumber))

f_intervalActiveForDate(
     int queryTimestamp,
     int yearValue,
     int monthValue,
     int dayValue,
     string timezoneValue,
     string weekdayMask,
     string sessionText) =>
    int localNoon = timestamp(timezoneValue, yearValue, monthValue, dayValue, 12, 0, 0)
    bool allowed = f_dayAllowed(localNoon, timezoneValue, weekdayMask)
    [startTimestamp, endTimestamp] = f_sessionBounds(yearValue, monthValue, dayValue, timezoneValue, sessionText)
    allowed and f_sessionHasDuration(sessionText) and queryTimestamp >= startTimestamp and queryTimestamp < endTimestamp

f_segmentActive(Market marketValue, string sessionText, int queryTimestamp) =>
    int currentYear = year(queryTimestamp, marketValue.tz)
    int currentMonth = month(queryTimestamp, marketValue.tz)
    int currentDay = dayofmonth(queryTimestamp, marketValue.tz)
    bool activeCurrentDate = f_intervalActiveForDate(
         queryTimestamp,
         currentYear,
         currentMonth,
         currentDay,
         marketValue.tz,
         marketValue.weekdays,
         sessionText)
    [previousYear, previousMonth, previousDay] = f_shiftLocalDate(
         currentYear,
         currentMonth,
         currentDay,
         marketValue.tz,
         -1)
    bool activePreviousDate = f_intervalActiveForDate(
         queryTimestamp,
         previousYear,
         previousMonth,
         previousDay,
         marketValue.tz,
         marketValue.weekdays,
         sessionText)
    activeCurrentDate or activePreviousDate

f_marketActive(Market marketValue, int queryTimestamp) =>
    bool firstSegmentActive = marketValue.enabled and f_sessionHasDuration(marketValue.segmentOne) and f_segmentActive(marketValue, marketValue.segmentOne, queryTimestamp)
    bool secondSegmentActive = marketValue.enabled and marketValue.segmentTwoEnabled and f_sessionHasDuration(marketValue.segmentTwo) and f_segmentActive(marketValue, marketValue.segmentTwo, queryTimestamp)
    firstSegmentActive or secondSegmentActive

f_activeState(array<Market> markets, int queryTimestamp) =>
    int activeCount = 0
    string activeCodes = ""
    int marketCount = array.size(markets)
    if marketCount > 0
        for marketIndex = 0 to marketCount - 1
            Market marketValue = array.get(markets, marketIndex)
            if f_marketActive(marketValue, queryTimestamp)
                activeCount += 1
                activeCodes += (activeCodes == "" ? "" : " + ") + marketValue.code
    [activeCount, activeCodes == "" ? "None" : activeCodes]

f_eventWord(int eventKind) =>
    switch eventKind
        EVENT_OPEN => "OPEN"
        EVENT_BREAK => "BREAK"
        EVENT_RESUME => "RESUME"
        => "CLOSE"

f_transitionRole(int beforeCount, string beforeCodes, int afterCount, string afterCodes) =>
    string role = "INTERNAL BOUNDARY"
    if beforeCount == 0 and afterCount > 0
        role := "ACTIVATION"
    else if beforeCount > 0 and afterCount == 0
        role := "DEACTIVATION"
    else if afterCount > beforeCount
        role := "OVERLAP BUILD"
    else if afterCount < beforeCount
        role := "OVERLAP RELEASE"
    else if beforeCodes != afterCodes
        role := "HANDOFF"
    role

f_roleColor(string role) =>
    switch role
        "ACTIVATION" => activationColor
        "OVERLAP BUILD" => overlapBuildColor
        "HANDOFF" => handoffColor
        "OVERLAP RELEASE" => overlapReleaseColor
        "DEACTIVATION" => deactivationColor
        => internalBoundaryColor

f_roleTag(string role) =>
    switch role
        "ACTIVATION" => "ACTIVATE"
        "OVERLAP BUILD" => "OVERLAP +"
        "HANDOFF" => "HANDOFF"
        "OVERLAP RELEASE" => "OVERLAP -"
        "DEACTIVATION" => "DEACTIVATE"
        "BOUNDARY" => "BOUNDARY"
        => "INTERNAL"

f_uniformLineStyle(string styleName) =>
    switch styleName
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_boundaryLineStyle(int eventKind, int eventCount) =>
    if lineStyleMode == "Uniform"
        f_uniformLineStyle(uniformLineStyle)
    else if eventCount > 1
        line.style_solid
    else
        switch eventKind
            EVENT_BREAK => line.style_dotted
            EVENT_CLOSE => line.style_dashed
            => line.style_solid

f_textSize(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Normal" => size.normal
        => size.small

f_headerTextSize(string sizeName) =>
    switch sizeName
        "Tiny" => size.small
        "Normal" => size.large
        => size.normal

f_tablePosition(string positionName) =>
    switch positionName
        "Middle left" => position.middle_left
        "Top left" => position.top_left
        "Bottom right" => position.bottom_right
        "Middle right" => position.middle_right
        "Top right" => position.top_right
        => position.bottom_left

f_contrastTextColor(color backgroundColor) =>
    float luminance = 0.2126 * color.r(backgroundColor) + 0.7152 * color.g(backgroundColor) + 0.0722 * color.b(backgroundColor)
    luminance > 145.0 ? color.rgb(8, 15, 28) : color.rgb(248, 250, 252)

f_durationText(int millisecondsValue, bool includeSeconds) =>
    int remaining = math.max(millisecondsValue, 0)
    int totalSeconds = int(remaining / 1000)
    int totalMinutes = int(totalSeconds / 60)
    int daysValue = int(totalMinutes / (24 * 60))
    int hoursValue = int((totalMinutes % (24 * 60)) / 60)
    int minutesValue = totalMinutes % 60
    int secondsValue = totalSeconds % 60
    string result = ""
    if daysValue > 0
        result := str.tostring(daysValue) + "d " + str.tostring(hoursValue) + "h"
    else if hoursValue > 0
        result := str.tostring(hoursValue) + "h " + str.tostring(minutesValue) + "m"
    else if totalMinutes > 0
        result := str.tostring(totalMinutes) + "m"
        if includeSeconds
            result += " " + str.tostring(secondsValue) + "s"
    else
        result := includeSeconds ? str.tostring(secondsValue) + "s" : "<1m"
    result

f_clearLines(array<line> lineObjects) =>
    int objectCount = array.size(lineObjects)
    if objectCount > 0
        for objectIndex = 0 to objectCount - 1
            line.delete(array.get(lineObjects, objectIndex))
    array.clear(lineObjects)
    0

f_clearLabels(array<label> labelObjects) =>
    int objectCount = array.size(labelObjects)
    if objectCount > 0
        for objectIndex = 0 to objectCount - 1
            label.delete(array.get(labelObjects, objectIndex))
    array.clear(labelObjects)
    0

f_pushRawEvent(
     array<int> rawTimes,
     array<int> rawMarketIndexes,
     array<int> rawKinds,
     array<color> rawColors,
     int eventTimestamp,
     int marketIndex,
     int eventKind,
     color eventColor,
     int lowerTimestamp,
     int upperTimestamp) =>
    if eventTimestamp >= lowerTimestamp and eventTimestamp <= upperTimestamp
        array.push(rawTimes, eventTimestamp)
        array.push(rawMarketIndexes, marketIndex)
        array.push(rawKinds, eventKind)
        array.push(rawColors, eventColor)
    0

f_addMarketDateEvents(
     array<int> rawTimes,
     array<int> rawMarketIndexes,
     array<int> rawKinds,
     array<color> rawColors,
     Market marketValue,
     int marketIndex,
     int yearValue,
     int monthValue,
     int dayValue,
     int lowerTimestamp,
     int upperTimestamp) =>
    int localNoon = timestamp(marketValue.tz, yearValue, monthValue, dayValue, 12, 0, 0)
    bool allowed = marketValue.enabled and f_dayAllowed(localNoon, marketValue.tz, marketValue.weekdays)
    if allowed and f_sessionHasDuration(marketValue.segmentOne)
        [firstStart, firstEnd] = f_sessionBounds(yearValue, monthValue, dayValue, marketValue.tz, marketValue.segmentOne)
        bool validSecond = marketValue.segmentTwoEnabled and f_sessionHasDuration(marketValue.segmentTwo)
        if validSecond
            [secondStart, secondEnd] = f_sessionBounds(yearValue, monthValue, dayValue, marketValue.tz, marketValue.segmentTwo)
            bool firstStartsEarlier = firstStart <= secondStart
            int earlyStart = firstStartsEarlier ? firstStart : secondStart
            int earlyEnd = firstStartsEarlier ? firstEnd : secondEnd
            int lateStart = firstStartsEarlier ? secondStart : firstStart
            int lateEnd = firstStartsEarlier ? secondEnd : firstEnd
            bool intervalsTouchOrOverlap = lateStart <= earlyEnd

            f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, earlyStart, marketIndex, EVENT_OPEN, marketValue.tint, lowerTimestamp, upperTimestamp)
            if intervalsTouchOrOverlap
                int mergedEnd = math.max(earlyEnd, lateEnd)
                f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, mergedEnd, marketIndex, EVENT_CLOSE, marketValue.tint, lowerTimestamp, upperTimestamp)
            else
                f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, earlyEnd, marketIndex, EVENT_BREAK, marketValue.tint, lowerTimestamp, upperTimestamp)
                f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, lateStart, marketIndex, EVENT_RESUME, marketValue.tint, lowerTimestamp, upperTimestamp)
                f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, lateEnd, marketIndex, EVENT_CLOSE, marketValue.tint, lowerTimestamp, upperTimestamp)
        else
            f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, firstStart, marketIndex, EVENT_OPEN, marketValue.tint, lowerTimestamp, upperTimestamp)
            f_pushRawEvent(rawTimes, rawMarketIndexes, rawKinds, rawColors, firstEnd, marketIndex, EVENT_CLOSE, marketValue.tint, lowerTimestamp, upperTimestamp)
    0

f_findLane(array<int> laneTimes, int eventTimestamp, int minimumSpacingMilliseconds) =>
    int laneCount = array.size(laneTimes)
    int selectedLane = 0
    bool freeLaneFound = false
    int oldestTimestamp = na
    if laneCount > 0
        for laneIndex = 0 to laneCount - 1
            int priorTimestamp = array.get(laneTimes, laneIndex)
            bool laneIsFree = na(priorTimestamp) or eventTimestamp - priorTimestamp >= minimumSpacingMilliseconds
            if laneIsFree and not freeLaneFound
                selectedLane := laneIndex
                freeLaneFound := true
            if na(oldestTimestamp) or na(priorTimestamp) or priorTimestamp < oldestTimestamp
                oldestTimestamp := priorTimestamp
                if not freeLaneFound
                    selectedLane := laneIndex
    [selectedLane, freeLaneFound]


f_eventImportance(string role, int eventCount) =>
    int score = 100
    if role == "HANDOFF"
        score := 650
    else if role == "ACTIVATION" or role == "DEACTIVATION"
        score := 600
    else if eventCount > 1
        score := 540
    else if role == "OVERLAP BUILD" or role == "OVERLAP RELEASE"
        score := 320
    score


f_groupContains(string groupedKeyText, int marketIndex, int eventKind) =>
    str.contains(groupedKeyText, "|" + str.tostring(marketIndex) + ":" + str.tostring(eventKind) + "|")

f_eventPhase(string groupedKeyText, string role) =>
    int phase = 6
    if role == "ACTIVATION" or f_groupContains(groupedKeyText, 0, EVENT_OPEN)
        phase := 0
    else if f_groupContains(groupedKeyText, 1, EVENT_OPEN) or f_groupContains(groupedKeyText, 2, EVENT_OPEN)
        phase := 1
    else if role == "HANDOFF" or f_groupContains(groupedKeyText, 2, EVENT_RESUME) or f_groupContains(groupedKeyText, 0, EVENT_CLOSE)
        phase := 2
    else if f_groupContains(groupedKeyText, 3, EVENT_OPEN) or f_groupContains(groupedKeyText, 4, EVENT_OPEN)
        phase := 3
    else if f_groupContains(groupedKeyText, 5, EVENT_OPEN)
        phase := 4
    else if role == "DEACTIVATION" or f_groupContains(groupedKeyText, 5, EVENT_CLOSE)
        phase := 5
    phase

// =============================================================================
// PERSISTENT STATE
// =============================================================================
var array<Market> markets = array.new<Market>()
if barstate.isfirst
    array.push(markets, Market.new(sydneyEnabled, sydneyName, sydneyCode, sydneyTimezone, sydneyWeekdays, sydneySegmentOne, sydneySegmentTwoEnabled, sydneySegmentTwo, sydneyColor))
    array.push(markets, Market.new(tokyoEnabled, tokyoName, tokyoCode, tokyoTimezone, tokyoWeekdays, tokyoSegmentOne, tokyoSegmentTwoEnabled, tokyoSegmentTwo, tokyoColor))
    array.push(markets, Market.new(hongKongEnabled, hongKongName, hongKongCode, hongKongTimezone, hongKongWeekdays, hongKongSegmentOne, hongKongSegmentTwoEnabled, hongKongSegmentTwo, hongKongColor))
    array.push(markets, Market.new(frankfurtEnabled, frankfurtName, frankfurtCode, frankfurtTimezone, frankfurtWeekdays, frankfurtSegmentOne, frankfurtSegmentTwoEnabled, frankfurtSegmentTwo, frankfurtColor))
    array.push(markets, Market.new(londonEnabled, londonName, londonCode, londonTimezone, londonWeekdays, londonSegmentOne, londonSegmentTwoEnabled, londonSegmentTwo, londonColor))
    array.push(markets, Market.new(newYorkEnabled, newYorkName, newYorkCode, newYorkTimezone, newYorkWeekdays, newYorkSegmentOne, newYorkSegmentTwoEnabled, newYorkSegmentTwo, newYorkColor))

var array<line> drawnLines = array.new<line>()
var array<label> drawnLabels = array.new<label>()

var array<int> rawTimes = array.new_int()
var array<int> rawMarketIndexes = array.new_int()
var array<int> rawKinds = array.new_int()
var array<color> rawColors = array.new_color()

var array<int> groupedTimes = array.new_int()
var array<string> groupedTokens = array.new_string()
var array<string> groupedDescriptions = array.new_string()
var array<string> groupedKeys = array.new_string()
var array<color> groupedColors = array.new_color()
var array<int> groupedCounts = array.new_int()
var array<int> groupedPrimaryKinds = array.new_int()
var array<string> groupedRoles = array.new_string()
var array<string> groupedBeforeCodes = array.new_string()
var array<string> groupedAfterCodes = array.new_string()

var int cachedVisibleLeft = na
var int cachedVisibleRight = na
var int cachedAnchorMinute = na
var bool statusVisibleSpanCapped = false
var bool statusLinesTruncated = false
var bool statusLabelsTruncated = false
var int effectiveAnchorTimestamp = na
var int lastBoundaryIndex = na
var int nextBoundaryIndex = na

var table boundaryStrip = table.new(
     f_tablePosition(boundaryStripPosition),
     3,
     8,
     bgcolor = color.new(color.rgb(15, 23, 42), 100),
     frame_color = color.new(color.rgb(71, 85, 105), 100),
     frame_width = 0,
     border_color = color.new(color.rgb(51, 65, 85), 100),
     border_width = 0)

if barstate.isfirst
    table.merge_cells(boundaryStrip, 0, 0, 2, 0)

// Visible-price range used only for placing labels inside the chart pane.
var float visiblePriceHigh = na
var float visiblePriceLow = na
bool barIsVisible = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
if barIsVisible
    visiblePriceHigh := na(visiblePriceHigh) ? high : math.max(visiblePriceHigh, high)
    visiblePriceLow := na(visiblePriceLow) ? low : math.min(visiblePriceLow, low)

// =============================================================================
// SCHEDULE BUILD AND DRAWING
// =============================================================================
int visibleLeftTimestamp = chart.left_visible_bar_time
int visibleRightTimestamp = chart.right_visible_bar_time

int selectedAnchorTimestamp = visibleRightTimestamp
if scheduleScope == "Recent days"
    selectedAnchorTimestamp := switch anchorMode
        "Latest chart bar" => last_bar_time
        "Real clock" => timenow
        => visibleRightTimestamp

int anchorMinuteKey = int(selectedAnchorTimestamp / MINUTE_MS)
bool rebuildRequired = barstate.islast and (
     na(cachedVisibleLeft) or
     na(cachedVisibleRight) or
     na(cachedAnchorMinute) or
     cachedVisibleLeft != visibleLeftTimestamp or
     cachedVisibleRight != visibleRightTimestamp or
     cachedAnchorMinute != anchorMinuteKey)

if rebuildRequired
    cachedVisibleLeft := visibleLeftTimestamp
    cachedVisibleRight := visibleRightTimestamp
    cachedAnchorMinute := anchorMinuteKey
    effectiveAnchorTimestamp := selectedAnchorTimestamp

    f_clearLines(drawnLines)
    f_clearLabels(drawnLabels)
    array.clear(rawTimes)
    array.clear(rawMarketIndexes)
    array.clear(rawKinds)
    array.clear(rawColors)
    array.clear(groupedTimes)
    array.clear(groupedTokens)
    array.clear(groupedDescriptions)
    array.clear(groupedKeys)
    array.clear(groupedColors)
    array.clear(groupedCounts)
    array.clear(groupedPrimaryKinds)
    array.clear(groupedRoles)
    array.clear(groupedBeforeCodes)
    array.clear(groupedAfterCodes)

    statusVisibleSpanCapped := false
    statusLinesTruncated := false
    statusLabelsTruncated := false
    lastBoundaryIndex := na
    nextBoundaryIndex := na

    if timeframe.isintraday
        int drawingStartTimestamp = scheduleScope == "Visible range" ? visibleLeftTimestamp : effectiveAnchorTimestamp - recentPastDays * DAY_MS
        int drawingEndTimestamp = effectiveAnchorTimestamp + futureProjectionDays * DAY_MS

        if scheduleScope == "Visible range"
            int maximumVisibleSpan = visibleSpanCapDays * DAY_MS
            if visibleRightTimestamp - visibleLeftTimestamp > maximumVisibleSpan
                drawingStartTimestamp := visibleRightTimestamp - maximumVisibleSpan
                statusVisibleSpanCapped := true

        // Extra days support overnight intervals, local-date offsets, and the
        // Boundary Strip's next-event lookup beyond the drawn window.
        int calculationStartTimestamp = drawingStartTimestamp - 2 * DAY_MS
        int calculationEndTimestamp = drawingEndTimestamp + 9 * DAY_MS
        int calculationDays = int(math.ceil(float(calculationEndTimestamp - calculationStartTimestamp) / DAY_MS)) + 2

        int marketCount = array.size(markets)
        if marketCount > 0
            for dayOffset = 0 to calculationDays
                int dayProbe = calculationStartTimestamp + dayOffset * DAY_MS
                for marketIndex = 0 to marketCount - 1
                    Market marketValue = array.get(markets, marketIndex)
                    int localYear = year(dayProbe, marketValue.tz)
                    int localMonth = month(dayProbe, marketValue.tz)
                    int localDay = dayofmonth(dayProbe, marketValue.tz)
                    f_addMarketDateEvents(
                         rawTimes,
                         rawMarketIndexes,
                         rawKinds,
                         rawColors,
                         marketValue,
                         marketIndex,
                         localYear,
                         localMonth,
                         localDay,
                         calculationStartTimestamp,
                         calculationEndTimestamp)

        // Chronologically sort raw events, then collapse every identical UNIX
        // timestamp into one boundary object. This prevents overlapping lines.
        int rawEventCount = array.size(rawTimes)
        if rawEventCount > 0
            array<int> sortedRawIndexes = array.sort_indices(rawTimes, order.ascending)
            int currentTimestamp = na
            string currentTokens = ""
            string currentDescriptions = ""
            string currentKeys = ""
            color currentColor = na
            int currentCount = 0
            int currentPrimaryKind = EVENT_OPEN

            for sortedPosition = 0 to rawEventCount - 1
                int rawIndex = array.get(sortedRawIndexes, sortedPosition)
                int eventTimestamp = array.get(rawTimes, rawIndex)
                int marketIndex = array.get(rawMarketIndexes, rawIndex)
                int eventKind = array.get(rawKinds, rawIndex)
                color eventColor = array.get(rawColors, rawIndex)
                Market marketValue = array.get(markets, marketIndex)
                string eventKey = "|" + str.tostring(marketIndex) + ":" + str.tostring(eventKind) + "|"

                if na(currentTimestamp) or eventTimestamp != currentTimestamp
                    if not na(currentTimestamp)
                        array.push(groupedTimes, currentTimestamp)
                        array.push(groupedTokens, currentTokens)
                        array.push(groupedDescriptions, currentDescriptions)
                        array.push(groupedKeys, currentKeys)
                        array.push(groupedColors, currentCount > 1 ? simultaneousEventColor : currentColor)
                        array.push(groupedCounts, currentCount)
                        array.push(groupedPrimaryKinds, currentPrimaryKind)
                    currentTimestamp := eventTimestamp
                    currentTokens := ""
                    currentDescriptions := ""
                    currentKeys := ""
                    currentColor := eventColor
                    currentCount := 0
                    currentPrimaryKind := eventKind

                if not str.contains(currentKeys, eventKey)
                    string eventToken = marketValue.code + " " + f_eventWord(eventKind)
                    string nativeTimeText = showNativeTimeInTooltip ? " at " + str.format_time(eventTimestamp, "yyyy-MM-dd HH:mm", marketValue.tz) + " (" + marketValue.tz + ")" : ""
                    string eventDescription = marketValue.name + ": " + f_eventWord(eventKind) + nativeTimeText
                    currentTokens += (currentTokens == "" ? "" : " · ") + eventToken
                    currentDescriptions += (currentDescriptions == "" ? "" : "\n") + eventDescription
                    currentKeys += eventKey
                    currentCount += 1

            if not na(currentTimestamp)
                array.push(groupedTimes, currentTimestamp)
                array.push(groupedTokens, currentTokens)
                array.push(groupedDescriptions, currentDescriptions)
                array.push(groupedKeys, currentKeys)
                array.push(groupedColors, currentCount > 1 ? simultaneousEventColor : currentColor)
                array.push(groupedCounts, currentCount)
                array.push(groupedPrimaryKinds, currentPrimaryKind)

        // Classify each grouped timestamp once. Rendering then reuses the
        // cached before/after sets instead of recalculating them per object.
        int groupedEventCount = array.size(groupedTimes)
        if groupedEventCount > 0
            for groupIndex = 0 to groupedEventCount - 1
                int groupTimestamp = array.get(groupedTimes, groupIndex)
                [beforeCount, beforeCodes] = f_activeState(markets, groupTimestamp - 1)
                [afterCount, afterCodes] = f_activeState(markets, groupTimestamp + 1)
                array.push(groupedRoles, f_transitionRole(beforeCount, beforeCodes, afterCount, afterCodes))
                array.push(groupedBeforeCodes, beforeCodes)
                array.push(groupedAfterCodes, afterCodes)

        // Locate the last and next boundary relative to the effective anchor.
        if groupedEventCount > 0
            for groupIndex = 0 to groupedEventCount - 1
                int groupTimestamp = array.get(groupedTimes, groupIndex)
                if groupTimestamp <= effectiveAnchorTimestamp
                    lastBoundaryIndex := groupIndex
                else if na(nextBoundaryIndex)
                    nextBoundaryIndex := groupIndex

        // Build line candidates, retain those nearest the anchor if the object
        // budget is exceeded, then restore chronological drawing order.
        array<int> lineCandidateIndexes = array.new_int()
        array<int> lineCandidateDistances = array.new_int()
        if groupedEventCount > 0
            for groupIndex = 0 to groupedEventCount - 1
                int groupTimestamp = array.get(groupedTimes, groupIndex)
                bool inDrawingWindow = groupTimestamp >= drawingStartTimestamp and groupTimestamp <= drawingEndTimestamp
                bool sideEnabled = groupTimestamp <= effectiveAnchorTimestamp ? showHistoricalLines : showFutureLines
                if inDrawingWindow and sideEnabled
                    array.push(lineCandidateIndexes, groupIndex)
                    array.push(lineCandidateDistances, math.abs(groupTimestamp - effectiveAnchorTimestamp))

        int lineCandidateCount = array.size(lineCandidateIndexes)
        int lineSelectionCount = math.min(lineCandidateCount, maximumBoundaryLines)
        statusLinesTruncated := lineCandidateCount > maximumBoundaryLines
        array<int> selectedLineIndexes = array.new_int()
        if lineSelectionCount > 0
            if lineRetentionMode == "Adaptive spread" and lineCandidateCount > maximumBoundaryLines
                int selectionSpan = math.max(drawingEndTimestamp - drawingStartTimestamp, 1)
                for slotIndex = 0 to lineSelectionCount - 1
                    int slotStart = drawingStartTimestamp + int(float(selectionSpan) * float(slotIndex) / float(lineSelectionCount))
                    int slotEnd = slotIndex == lineSelectionCount - 1 ? drawingEndTimestamp + 1 : drawingStartTimestamp + int(float(selectionSpan) * float(slotIndex + 1) / float(lineSelectionCount))
                    int slotCenter = slotStart + int((slotEnd - slotStart) / 2)
                    int bestGroupIndex = na
                    int bestScore = -1
                    int bestCenterDistance = na
                    for candidatePosition = 0 to lineCandidateCount - 1
                        int groupIndex = array.get(lineCandidateIndexes, candidatePosition)
                        int groupTimestamp = array.get(groupedTimes, groupIndex)
                        if groupTimestamp >= slotStart and groupTimestamp < slotEnd
                            string actualRole = array.get(groupedRoles, groupIndex)
                            string groupedKeyText = array.get(groupedKeys, groupIndex)
                            int eventCount = array.get(groupedCounts, groupIndex)
                            int preferredPhase = slotIndex % 6
                            int phaseBonus = f_eventPhase(groupedKeyText, actualRole) == preferredPhase ? 1000 : 0
                            int eventScore = phaseBonus + f_eventImportance(actualRole, eventCount)
                            int centerDistance = math.abs(groupTimestamp - slotCenter)
                            if eventScore > bestScore or (eventScore == bestScore and (na(bestCenterDistance) or centerDistance < bestCenterDistance))
                                bestGroupIndex := groupIndex
                                bestScore := eventScore
                                bestCenterDistance := centerDistance
                    if not na(bestGroupIndex)
                        array.push(selectedLineIndexes, bestGroupIndex)

                // Keep one actionable future marker in the sparse view. The
                // last sampled slot is replaced, rather than increasing the
                // user's line budget, when the immediate next boundary was
                // not selected by phase balancing.
                if showFutureLines and not na(nextBoundaryIndex)
                    int nextTimestampForRetention = array.get(groupedTimes, nextBoundaryIndex)
                    bool nextInsideDrawingWindow = nextTimestampForRetention >= drawingStartTimestamp and nextTimestampForRetention <= drawingEndTimestamp
                    if nextInsideDrawingWindow and array.indexof(selectedLineIndexes, nextBoundaryIndex) == -1
                        int retainedCount = array.size(selectedLineIndexes)
                        if retainedCount > 0
                            array.set(selectedLineIndexes, retainedCount - 1, nextBoundaryIndex)
                        else
                            array.push(selectedLineIndexes, nextBoundaryIndex)
                array.sort(selectedLineIndexes, order.ascending)
            else
                array<int> distanceOrder = array.sort_indices(lineCandidateDistances, order.ascending)
                for selectionPosition = 0 to lineSelectionCount - 1
                    int candidatePosition = array.get(distanceOrder, selectionPosition)
                    array.push(selectedLineIndexes, array.get(lineCandidateIndexes, candidatePosition))
                array.sort(selectedLineIndexes, order.ascending)

        float rangeHigh = na(visiblePriceHigh) ? high : visiblePriceHigh
        float rangeLow = na(visiblePriceLow) ? low : visiblePriceLow
        float rangeSize = math.max(rangeHigh - rangeLow, math.max(math.abs(close) * 0.01, syminfo.mintick * 100.0))

        int selectedLineCount = array.size(selectedLineIndexes)
        if selectedLineCount > 0
            for selectedPosition = 0 to selectedLineCount - 1
                int groupIndex = array.get(selectedLineIndexes, selectedPosition)
                int eventTimestamp = array.get(groupedTimes, groupIndex)
                int eventCount = array.get(groupedCounts, groupIndex)
                int primaryKind = array.get(groupedPrimaryKinds, groupIndex)
                color marketColor = array.get(groupedColors, groupIndex)
                string actualRole = array.get(groupedRoles, groupIndex)
                string role = classifyBoundaryRoles ? actualRole : "BOUNDARY"
                color roleColor = classifyBoundaryRoles ? f_roleColor(role) : marketColor
                color baseLineColor = lineColorMode == "Transition role" ? roleColor : marketColor
                bool isNextBoundary = emphasizeNextBoundary and groupIndex == nextBoundaryIndex
                color finalLineColor = isNextBoundary ? nextBoundaryColor : color.new(baseLineColor, eventTimestamp <= effectiveAnchorTimestamp ? historicalTransparency : futureTransparency)
                int finalLineWidth = isNextBoundary ? math.min(boundaryLineWidth + 1, 4) : boundaryLineWidth
                line boundaryLine = line.new(
                     x1 = eventTimestamp,
                     y1 = rangeLow,
                     x2 = eventTimestamp,
                     y2 = rangeHigh,
                     xloc = xloc.bar_time,
                     extend = extend.both,
                     color = finalLineColor,
                     style = isNextBoundary ? line.style_solid : f_boundaryLineStyle(primaryKind, eventCount),
                     width = finalLineWidth)
                array.push(drawnLines, boundaryLine)

        // Label candidates are selected independently, so reducing label count
        // never removes structural boundary lines.
        if showBoundaryLabels and selectedLineCount > 0
            array<int> labelCandidateIndexes = array.copy(selectedLineIndexes)
            array<int> labelCandidateDistances = array.new_int()
            int labelCandidateCount = array.size(labelCandidateIndexes)
            if labelCandidateCount > 0
                for candidatePosition = 0 to labelCandidateCount - 1
                    int groupIndex = array.get(labelCandidateIndexes, candidatePosition)
                    array.push(labelCandidateDistances, math.abs(array.get(groupedTimes, groupIndex) - effectiveAnchorTimestamp))

            int labelSelectionCount = math.min(labelCandidateCount, maximumBoundaryLabels)
            statusLabelsTruncated := labelCandidateCount > maximumBoundaryLabels
            array<int> selectedLabelIndexes = array.new_int()
            if labelSelectionCount > 0
                array<int> labelDistanceOrder = array.sort_indices(labelCandidateDistances, order.ascending)
                for selectionPosition = 0 to labelSelectionCount - 1
                    int candidatePosition = array.get(labelDistanceOrder, selectionPosition)
                    array.push(selectedLabelIndexes, array.get(labelCandidateIndexes, candidatePosition))
                array.sort(selectedLabelIndexes, order.ascending)

            array<int> topLaneTimes = array.new_int(labelLaneCount, na)
            array<int> bottomLaneTimes = array.new_int(labelLaneCount, na)
            int minimumSpacingMilliseconds = labelSpacingMinutes * MINUTE_MS
            int selectedLabelCount = array.size(selectedLabelIndexes)
            if selectedLabelCount > 0
                for labelPosition = 0 to selectedLabelCount - 1
                    int groupIndex = array.get(selectedLabelIndexes, labelPosition)
                    int eventTimestamp = array.get(groupedTimes, groupIndex)
                    string eventTokens = array.get(groupedTokens, groupIndex)
                    string eventDescriptions = array.get(groupedDescriptions, groupIndex)
                    color marketColor = array.get(groupedColors, groupIndex)
                    string beforeCodes = array.get(groupedBeforeCodes, groupIndex)
                    string afterCodes = array.get(groupedAfterCodes, groupIndex)
                    string actualRole = array.get(groupedRoles, groupIndex)
                    string role = classifyBoundaryRoles ? actualRole : "BOUNDARY"
                    color roleColor = classifyBoundaryRoles ? f_roleColor(role) : marketColor
                    bool isNextBoundary = emphasizeNextBoundary and groupIndex == nextBoundaryIndex
                    color labelBaseColor = isNextBoundary ? nextBoundaryColor : roleColor
                    string roleTag = f_roleTag(role)
                    string labelText = switch labelContent
                        "Events only" => eventTokens
                        "Role only" => roleTag
                        => roleTag + "\n" + eventTokens
                    bool preferTop = labelPlacement == "Top" or (labelPlacement == "Alternate" and labelPosition % 2 == 0)
                    if labelPlacement == "Bottom"
                        preferTop := false

                    [preferredTopLane, preferredTopFree] = f_findLane(topLaneTimes, eventTimestamp, minimumSpacingMilliseconds)
                    [preferredBottomLane, preferredBottomFree] = f_findLane(bottomLaneTimes, eventTimestamp, minimumSpacingMilliseconds)
                    bool useTop = preferTop
                    int selectedLane = preferTop ? preferredTopLane : preferredBottomLane
                    bool preferredFree = preferTop ? preferredTopFree : preferredBottomFree
                    bool alternateFree = preferTop ? preferredBottomFree : preferredTopFree
                    bool allowOppositeSide = labelPlacement == "Alternate"
                    if allowOppositeSide and not preferredFree and alternateFree
                        useTop := not preferTop
                        selectedLane := preferTop ? preferredBottomLane : preferredTopLane

                    if useTop
                        array.set(topLaneTimes, selectedLane, eventTimestamp)
                    else
                        array.set(bottomLaneTimes, selectedLane, eventTimestamp)

                    float laneOffset = rangeSize * (0.03 + selectedLane * 0.058)
                    float labelPrice = useTop ? rangeHigh - laneOffset : rangeLow + laneOffset
                    string transitionText = "Transition: " + beforeCodes + " -> " + afterCodes
                    string readoutTimeText = "Readout: " + str.format_time(eventTimestamp, "yyyy-MM-dd HH:mm", readoutTimezone) + " (" + readoutTimezone + ")"
                    string tooltipText = eventDescriptions + "\n" + transitionText + "\nRole: " + role + "\n" + readoutTimeText
                    label boundaryLabel = label.new(
                         x = eventTimestamp,
                         y = labelPrice,
                         text = labelText,
                         xloc = xloc.bar_time,
                         yloc = yloc.price,
                         style = useTop ? label.style_label_down : label.style_label_up,
                         color = color.new(labelBaseColor, labelTransparency),
                         textcolor = f_contrastTextColor(labelBaseColor),
                         size = f_textSize(labelTextSize),
                         textalign = text.align_center,
                         tooltip = tooltipText,
                         text_font_family = font.family_default)
                    if boldBoundaryLabelText
                        label.set_text_formatting(boundaryLabel, text.format_bold)
                    else
                        label.set_text_formatting(boundaryLabel, text.format_none)
                    array.push(drawnLabels, boundaryLabel)

// =============================================================================
// BOUNDARY STRIP
// =============================================================================
if barstate.islast
    table.set_position(boundaryStrip, f_tablePosition(boundaryStripPosition))
    if not showBoundaryStrip
        table.clear(boundaryStrip, 0, 0, 2, 7)
    else
        color panelBackground = color.new(color.rgb(15, 23, 42), 3)
        color keyBackground = color.new(color.rgb(30, 41, 59), 1)
        color neutralText = color.rgb(241, 245, 249)
        color keyText = color.rgb(203, 213, 225)
        color subduedText = color.rgb(148, 163, 184)
        color headerBackground = color.rgb(3, 105, 161)

        table.cell(
             boundaryStrip,
             0,
             0,
             "◆  MktHandoff",
             bgcolor = headerBackground,
             text_color = color.white,
             text_size = f_headerTextSize(boundaryStripTextSize),
             text_halign = text.align_center,
             text_valign = text.align_center,
             text_formatting = text.format_bold)

        if not timeframe.isintraday
            table.cell(boundaryStrip, 0, 1, "!", bgcolor = keyBackground, text_color = color.rgb(253, 224, 71), text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 1, "STATUS", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 1, "Intraday timeframe required", bgcolor = panelBackground, text_color = color.rgb(253, 224, 71), text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)
            for emptyRow = 2 to 6
                table.cell(boundaryStrip, 0, emptyRow, "", bgcolor = keyBackground)
                table.cell(boundaryStrip, 1, emptyRow, "", bgcolor = keyBackground)
                table.cell(boundaryStrip, 2, emptyRow, "", bgcolor = panelBackground)
        else
            int liveAnchorTimestamp = visibleRightTimestamp
            if scheduleScope == "Recent days"
                liveAnchorTimestamp := switch anchorMode
                    "Latest chart bar" => last_bar_time
                    "Real clock" => timenow
                    => visibleRightTimestamp
            [activeCountNow, activeCodesNow] = f_activeState(markets, liveAnchorTimestamp)

            string anchorText = str.format_time(liveAnchorTimestamp, "yyyy-MM-dd HH:mm", readoutTimezone) + "  " + readoutTimezone
            string lastText = "None in calculation window"
            color lastColor = internalBoundaryColor
            if not na(lastBoundaryIndex)
                int lastTimestamp = array.get(groupedTimes, lastBoundaryIndex)
                string lastTokens = array.get(groupedTokens, lastBoundaryIndex)
                lastText := lastTokens + "  ·  " + str.format_time(lastTimestamp, "MM-dd HH:mm", readoutTimezone)
                lastColor := array.get(groupedColors, lastBoundaryIndex)

            string nextText = "None in calculation window"
            string distanceText = "—"
            color nextColor = internalBoundaryColor
            if not na(nextBoundaryIndex)
                int nextTimestamp = array.get(groupedTimes, nextBoundaryIndex)
                string nextTokens = array.get(groupedTokens, nextBoundaryIndex)
                string nextActualRole = array.get(groupedRoles, nextBoundaryIndex)
                string nextRole = classifyBoundaryRoles ? nextActualRole : "BOUNDARY"
                nextColor := classifyBoundaryRoles ? f_roleColor(nextRole) : array.get(groupedColors, nextBoundaryIndex)
                nextText := nextTokens + "  ·  " + str.format_time(nextTimestamp, "MM-dd HH:mm", readoutTimezone)
                distanceText := f_durationText(nextTimestamp - liveAnchorTimestamp, showSecondsInCountdown)

            string activeText = activeCountNow == 0 ? "None" : activeCodesNow + "  (" + str.tostring(activeCountNow) + ")"
            string noteText = scheduleScope + " · " + lineRetentionMode
            if statusVisibleSpanCapped
                noteText += " · span capped"
            if statusLinesTruncated or statusLabelsTruncated
                noteText += " · " + str.tostring(array.size(drawnLines)) + " lines"

            color activeColor = activeCountNow > 0 ? color.rgb(56, 189, 248) : subduedText
            color lastValueBackground = color.new(lastColor, 86)
            color nextValueBackground = color.new(nextColor, 82)

            // Icon column. The marks give each row a stable visual identity even
            // when values change or the panel is viewed as a small thumbnail.
            table.cell(boundaryStrip, 0, 1, "◉", bgcolor = keyBackground, text_color = color.rgb(125, 211, 252), text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 1, "ANCHOR", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 1, anchorText, bgcolor = panelBackground, text_color = neutralText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)

            table.cell(boundaryStrip, 0, 2, "●", bgcolor = keyBackground, text_color = activeColor, text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 2, "ACTIVE", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 2, activeText, bgcolor = panelBackground, text_color = activeColor, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)

            table.cell(boundaryStrip, 0, 3, "◀", bgcolor = keyBackground, text_color = lastColor, text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 3, "LAST", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 3, lastText, bgcolor = lastValueBackground, text_color = neutralText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)

            table.cell(boundaryStrip, 0, 4, "▶", bgcolor = keyBackground, text_color = nextColor, text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 4, "NEXT", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 4, nextText, bgcolor = nextValueBackground, text_color = neutralText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)

            table.cell(boundaryStrip, 0, 5, "⌛", bgcolor = keyBackground, text_color = color.rgb(253, 224, 71), text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 5, "COUNTDOWN", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 5, distanceText, bgcolor = panelBackground, text_color = color.rgb(253, 224, 71), text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)

            table.cell(boundaryStrip, 0, 6, "▦", bgcolor = keyBackground, text_color = subduedText, text_size = f_headerTextSize(boundaryStripTextSize), text_halign = text.align_center, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 1, 6, "VIEW", bgcolor = keyBackground, text_color = keyText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left, text_formatting = text.format_bold)
            table.cell(boundaryStrip, 2, 6, noteText, bgcolor = panelBackground, text_color = subduedText, text_size = f_textSize(boundaryStripTextSize), text_halign = text.align_left)

        // Apply the optional emphasis with dedicated setters and literal
        // text.format_* constants. This avoids assigning text_format values to
        // an int variable and follows Pine's type-safe formatting pattern.
        if boldBoundaryStripText
            for formattedRow = 1 to 6
                table.cell_set_text_formatting(boundaryStrip, 2, formattedRow, text.format_bold)
        else
            for formattedRow = 1 to 6
                table.cell_set_text_formatting(boundaryStrip, 2, formattedRow, text.format_none)

        // A blank final row creates a controllable offset above permanent chart
        // furniture. Minimal one-line constructors remove the parser-sensitive
        // nested color.new() expression from the script tail.
        bool useBottomClearance = boundaryStripPosition == "Bottom left" or boundaryStripPosition == "Bottom right"
        float appliedBottomClearance = useBottomClearance ? boundaryStripBottomClearance : 0.0

        table.cell(boundaryStrip, 0, 7, "")
        table.cell(boundaryStrip, 1, 7, "")
        table.cell(boundaryStrip, 2, 7, "")
        table.cell_set_height(boundaryStrip, 0, 7, appliedBottomClearance)
        table.cell_set_height(boundaryStrip, 1, 7, appliedBottomClearance)
        table.cell_set_height(boundaryStrip, 2, 7, appliedBottomClearance)
````
