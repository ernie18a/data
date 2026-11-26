# FVG / IFVG - ICT - 1H + 4H + Daily

- url: https://www.tradingview.com/script/6BjmUGRY-FVG-IFVG-ICT-1H-4H-Daily/
- type: indicator
- pine_id: PUB;4538aa592e3d4fd5ad027f87a643fc2c
- version: 3.0

## Description

[b]Daily + 4H + 1H FVG / IFVG — Merged[/b]

This indicator provides a unified multi-timeframe inventory of Fair Value Gaps (FVGs) and Inverse Fair Value Gaps (IFVGs) from the Daily, 4-Hour, and 1-Hour source timeframes.

The purpose of the script is to make higher-timeframe imbalance structure directly visible on supported lower-timeframe charts while preserving the calculation and lifecycle logic of each source timeframe independently.

WHAT THE INDICATOR IDENTIFIES

The indicator uses strict three-candle FVG geometry.

Bullish FVG:
The low of the third source-timeframe candle must be above the high of the first source-timeframe candle.

The resulting zone extends from the first candle's high to the third candle's low.

Bearish FVG:
The high of the third source-timeframe candle must be below the low of the first source-timeframe candle.

The resulting zone extends from the third candle's high to the first candle's low.

Adjacent candle close/open gaps are not used in the calculation. The script evaluates the first-versus-third-candle price geometry directly.

SUPPORTED SOURCE TIMEFRAMES

The merged indicator contains three independent engines:

• Daily FVG / IFVG inventory
• 4H FVG / IFVG inventory
• 1H FVG / IFVG inventory

The Daily engine can be displayed on intraday and Daily charts.

The 4H engine operates on 4H and lower intraday charts.

The 1H engine operates on 1H and lower intraday charts.

Higher-timeframe calculations are based on confirmed source-timeframe information. On lower chart timeframes, previously completed higher-timeframe candles are used so that an unfinished higher-timeframe candle is not treated as a confirmed close.

CONFIRMED FVG → IFVG LIFECYCLE

The default lifecycle system does not convert an FVG immediately after a single opposing close.

For the Daily, 4H, and 1H engines, an original FVG becomes an opposite-direction IFVG only after two consecutive confirmed source-timeframe closes beyond the relevant FVG boundary.

Example:

A bullish FVG becomes a bearish IFVG after two consecutive confirmed source-timeframe closes below its lower boundary.

A bearish FVG becomes a bullish IFVG after two consecutive confirmed source-timeframe closes above its upper boundary.

This confirmation mechanism is intended to distinguish a temporary boundary violation from a confirmed structural inversion.

IFVG INVALIDATION

The indicator also manages the lifecycle of an IFVG after conversion.

For 4H zones, the number of consecutive reverse closes required for IFVG invalidation can be selected from 1 through 5.

For 1H zones, bullish and bearish IFVG invalidation thresholds can be configured independently, and confirmed IFVG invalidation can also be disabled.

The Daily confirmed-lifecycle model removes an IFVG after a confirmed Daily close through its opposite invalidation boundary.

PERSISTENT CURRENT-PRICE MODE

Each timeframe also provides an alternative persistent classification model.

When confirmed lifecycle mode is disabled, the original FVG remains in the inventory for the selected lookback period and is classified according to the current market-price relationship to the original zone.

In this mode:

• Price on the original/native side of the zone = original FVG classification
• Price beyond the opposite side = opposite-direction IFVG classification
• Price inside the zone = the most recently resolved classification remains active

This allows users to study the same original imbalance as its relationship with price evolves.

4H CONSECUTIVE-ZONE FILTERING

The 4H engine includes additional filtering for consecutive FVG and IFVG sequences.

When two or more same-direction FVGs occur on consecutive 4H source candles, the user can select which ordinal zone in the sequence is displayed:

1st, 2nd, 3rd, 4th, or 5th.

The same concept is available for consecutive 4H IFVG conversions.

Single isolated zones remain eligible for display.

This feature is designed for users who want to isolate a specific position within a sequence of higher-timeframe imbalances instead of displaying every zone in a cluster.

LOOKBACK AND INVENTORY CONTROL

Each timeframe has an independent calendar-day formation lookback.

Available selections are:

5, 10, 15, 30, 90, 180, or 365 calendar days.

Zones whose original formation falls outside the selected lookback are removed from that timeframe's active inventory.

MINIMUM FVG SIZE

Each source timeframe has an independent minimum FVG-size filter.

This allows the user to exclude gaps below a specified point size while retaining the same underlying three-candle detection logic.

MASTER VISIBILITY CONTROLS

The indicator includes a quick-control section for managing the entire chart without changing the underlying detection logic.

Users can globally enable or disable:

• All bullish zones
• All bearish zones

Each source timeframe also has independent controls for:

• Daily
• 4H
• 1H
• Bullish structures
• Bearish structures

Additional individual controls are available for bullish FVGs, bearish FVGs, bullish IFVGs, and bearish IFVGs.

These master switches control plotting and alert routing only. They do not modify the underlying source-timeframe calculations or zone lifecycle.

DYNAMIC ZONE PROJECTION

Visible zones extend dynamically to the opening timestamp of the current chart candle.

Users can also choose where the historical left edge of a zone begins:

• First FVG candle
• FVG end candle

The price boundaries themselves remain derived from the original FVG geometry.

ALERTS

The indicator includes alert conditions for both structure creation/classification and first interaction with visible zones.

Alerts are available for:

• Bullish FVG formation
• Bearish FVG formation
• Bullish IFVG classification
• Bearish IFVG classification
• Bullish FVG first retest
• Bearish FVG first retest
• Bullish IFVG first retest
• Bearish IFVG first retest

These alerts are implemented independently for the Daily, 4H, and 1H engines and respect the corresponding visibility and directional controls.

VISUAL CUSTOMIZATION

Each timeframe includes configurable visual parameters, including:

• Bullish zone color
• Bearish zone color
• FVG transparency
• IFVG transparency
• Border transparency
• Border width
• Zone text visibility
• Zone text color

FVG and IFVG states use distinct border styling to make their current classification easier to distinguish visually.

INTENDED USE

This indicator is intended as a market-structure and imbalance-mapping tool.

It can be used to:

• Monitor higher-timeframe FVGs while executing on lower timeframes
• Distinguish original FVGs from structurally inverted IFVGs
• Track confirmed higher-timeframe state changes
• Identify the first return of price to an active higher-timeframe zone
• Reduce chart clutter through directional, timeframe, size, lifecycle, and consecutive-zone filtering

The indicator does not generate an autonomous trading strategy, position sizing, entries, stop losses, profit targets, or performance projections.

FVG and IFVG zones should therefore be treated as structural market information rather than standalone trade recommendations.

IMPORTANT

Users should understand the distinction between Confirmed Lifecycle mode and Persistent Current-Price mode before using the indicator.

Confirmed Lifecycle mode requires completed source-timeframe closes to change structural state.

Persistent Current-Price mode intentionally allows classification to follow the current market-price relationship to the original gap and therefore represents a different analytical methodology.

The two modes should not be interpreted as producing identical historical or real-time behavior.

This script is intended for technical analysis and research purposes only and does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator("HTF FVG/IFVG ", overlay=true, max_boxes_count=500, max_lines_count=50, max_labels_count=50)

// ==============================================================================
// MERGED BUILD
// Calculation logic is preserved independently for the original 4H, 1H, and
// Daily engines. Identifier prefixes only prevent namespace collisions.
// ==============================================================================

// ==============================================================================
// 00. QUICK MASTER SWITCHES
// These are visibility / alert routing controls only. They do not alter FVG /
// IFVG detection, lifecycle, anchoring, source-timeframe calculations, or zones.
// ==============================================================================

quickGroup = "00. QUICK MASTER SWITCHES"

// Display filter only; existing detection, lifecycle, and alerts are preserved.
onlyUnmitigatedFvgs = input.bool(false, "Show only unmitigated FVGs", tooltip="Show only original fair value gaps that price has never touched or crossed after formation. Any subsequent wick reaching the near boundary removes the gap from this view. The formation candle does not count. All IFVGs are hidden while enabled. Existing timeframe, direction, lookback, and consecutive-zone filters still apply. OFF restores the original display; alerts are unchanged.", group=quickGroup)

// Global directional masters across ALL three source timeframes.
global_enableAllBullish = input.bool(true, "ALL TF Bullish", inline="quickGlobal", group=quickGroup)
global_enableAllBearish = input.bool(true, "ALL TF Bearish", inline="quickGlobal", group=quickGroup)

// Daily: timeframe master + direction filters.
d_enableDailyMaster = input.bool(true, "Daily", inline="quickDaily", group=quickGroup)
d_enableAllBullish = input.bool(true, "Bullish", inline="quickDaily", group=quickGroup)
d_enableAllBearish = input.bool(true, "Bearish", inline="quickDaily", group=quickGroup)

// 4H: timeframe master + direction filters.
h4_enable4HMaster = input.bool(true, "4H", inline="quick4H", group=quickGroup)
h4_enableAllBullish = input.bool(true, "Bullish", inline="quick4H", group=quickGroup)
h4_enableAllBearish = input.bool(true, "Bearish", inline="quick4H", group=quickGroup)

// 1H: timeframe master + direction filters.
h1_enableHourlyMaster = input.bool(true, "1H", inline="quick1H", group=quickGroup)
h1_enableAllBullish = input.bool(true, "Bullish", inline="quick1H", group=quickGroup)
h1_enableAllBearish = input.bool(true, "Bearish", inline="quick1H", group=quickGroup)

// 30M: timeframe master + direction filters.
m30_enable30MMaster = input.bool(true, "30M", inline="quick30M", group=quickGroup)
m30_enableAllBullish = input.bool(true, "Bullish", inline="quick30M", group=quickGroup)
m30_enableAllBearish = input.bool(true, "Bearish", inline="quick30M", group=quickGroup)

// 15M: timeframe master + direction filters.
m15_enable15MMaster = input.bool(true, "15M", inline="quick15M", group=quickGroup)
m15_enableAllBullish = input.bool(true, "Bullish", inline="quick15M", group=quickGroup)
m15_enableAllBearish = input.bool(true, "Bearish", inline="quick15M", group=quickGroup)


//==============================================================================

// 4H FVG / IFVG INVENTORY — V1.0

//------------------------------------------------------------------------------

// 1. Source timeframe is 4H (240 minutes) only.

// 2. Bullish FVG = third 4H candle LOW > first 4H candle HIGH.

//    Zone = first candle HIGH -> third candle LOW.

// 3. Bearish FVG = third 4H candle HIGH < first 4H candle LOW.

//    Zone = third candle HIGH -> first candle LOW.

// 4. Adjacent close/open gaps are ignored; only candle 1 vs candle 3 geometry matters.

// 5. Every visible zone extends dynamically to the OPEN of the current chart candle.

// 6. Formation lookback options: 5 / 10 / 15 / 30 / 90 / 180 / 365 calendar days.

// 7. Consecutive FVG runs:

//      - A single FVG is always eligible to display.

//      - For a run of 2+ same-direction FVGs on consecutive 4H source candles,

//        all zones in the run are displayed.

// 8. Consecutive IFVG runs:

//      - A single IFVG is always eligible to display.

//      - For a run of 2+ same-direction IFVG conversions on consecutive 4H closes,

//        all zones in the run are displayed.

// 9. Confirmed lifecycle mode (default):

//      - Two consecutive confirmed 4H closes beyond an FVG convert it to IFVG.

//      - IFVG invalidation requires a user-selected 1..5 consecutive confirmed 4H

//        closes back through the opposite boundary.

// 10. Persistent mode (confirmed lifecycle OFF): original gaps remain in inventory

//     inside lookback and are classified from current market price.

//==============================================================================

//------------------------------------------------------------------------------

// 01. Master controls

//------------------------------------------------------------------------------

h4_groupMaster = "4H • 01. Master Controls"

h4_enableIndicator = input.bool(true, "Enable indicator", group=h4_groupMaster)




h4_showZoneText = input.bool(true, "Show timeframe tag", group=h4_groupMaster)

h4_timeframeTag = input.string("4H", "Custom timeframe tag", tooltip="Text shown inside every visible 4H FVG / IFVG box. Example: 4H, H4, HTF. Only this tag is displayed on the box; direction and FVG / IFVG wording are intentionally omitted.", group=h4_groupMaster)

h4_lookbackDays = input.int(

     30,

     "4H formation lookback, calendar days",

     options=[5, 10, 15, 30, 90, 180, 365],

     group=h4_groupMaster)

h4_projectionAnchor = input.string(

     "First FVG candle",

     "Zone begins from",

     options=["First FVG candle", "FVG end candle"],

     group=h4_groupMaster)

//------------------------------------------------------------------------------

// 02. Consecutive-zone selectors

//------------------------------------------------------------------------------

// All consecutive FVG and IFVG zones are visible; ordinal selectors removed.

h4_groupLifecycle = "4H • 03. Classification / Lifecycle"

h4_useConfirmedLifecycle = input.bool(

     true,

     "Use confirmed 4H lifecycle / invalidation",

     tooltip="ON: two consecutive confirmed 4H closes beyond an FVG convert it to IFVG. The IFVG is removed only after the selected number of consecutive confirmed 4H reverse closes.\n\nOFF: original 4H gaps are never permanently invalidated inside lookback; current price determines whether each original gap is displayed as FVG or IFVG.",

     group=h4_groupLifecycle)

h4_ifvgInvalidationCloses = input.int(

     1,

     "IFVG invalidation — consecutive 4H closes required",

     options=[1, 2, 3, 4, 5],

     tooltip="Bearish IFVG: count confirmed 4H closes ABOVE the zone. Bullish IFVG: count confirmed 4H closes BELOW the zone. The IFVG is removed only when this consecutive-close threshold is reached.",

     group=h4_groupLifecycle)

//------------------------------------------------------------------------------

// 04. 4H inventory / minimum size

//------------------------------------------------------------------------------

h4_groupInventory = "4H • 04. 4H Inventory / Minimum Size"

h4_minGap4H = input.float(

     0.0,

     "4H: minimum FVG size, points",

     minval=0.0,

     step=0.25,

     group=h4_groupInventory)

//------------------------------------------------------------------------------

// 05. Individual 4H controls

//------------------------------------------------------------------------------

h4_group4H = "4H • 05. 4H Individual Controls"

h4_enable4HBullFvg = input.bool(true, "4H Bullish FVG — plot + alerts", group=h4_group4H)

h4_enable4HBearFvg = input.bool(true, "4H Bearish FVG — plot + alerts", group=h4_group4H)

h4_enable4HBullIfvg = input.bool(true, "4H Bullish IFVG — plot + alerts", group=h4_group4H)

h4_enable4HBearIfvg = input.bool(true, "4H Bearish IFVG — plot + alerts", group=h4_group4H)

//------------------------------------------------------------------------------

// 06. Visual customization — same palette as Daily/original indicator

//------------------------------------------------------------------------------

h4_groupVisual = "4H • 06. Visual Customization"

h4_bullishBaseColor = input.color(color.rgb(0, 139, 170), "Bullish cyan-blue", group=h4_groupVisual)

h4_bearishBaseColor = input.color(color.rgb(132, 78, 170), "Bearish purple", group=h4_groupVisual)

h4_fvgFillTransparency = input.int(84, "FVG fill transparency", minval=0, maxval=100, group=h4_groupVisual)

h4_ifvgFillTransparency = input.int(87, "IFVG fill transparency", minval=0, maxval=100, group=h4_groupVisual)

h4_borderTransparency = input.int(18, "Border transparency", minval=0, maxval=100, group=h4_groupVisual)

h4_boxBorderWidth = input.int(1, "Box border width", minval=0, maxval=4, group=h4_groupVisual)

h4_zoneTextColor = input.color(color.new(color.white, 15), "Zone text color", group=h4_groupVisual)

//------------------------------------------------------------------------------

// Routing and effective controls

//------------------------------------------------------------------------------

int h4_FOUR_HOURS_SECONDS = 4 * 60 * 60

bool h4_isFourHourChart = timeframe.isintraday and timeframe.in_seconds() == h4_FOUR_HOURS_SECONDS

bool h4_isLowerThanFourHourChart = timeframe.isintraday and timeframe.in_seconds() < h4_FOUR_HOURS_SECONDS

bool h4_supportedChart = h4_isFourHourChart or h4_isLowerThanFourHourChart

bool h4_canRun = h4_enableIndicator and h4_supportedChart

h4_bullFvgFill = color.new(h4_bullishBaseColor, h4_fvgFillTransparency)

h4_bearFvgFill = color.new(h4_bearishBaseColor, h4_fvgFillTransparency)

h4_bullIfvgFill = color.new(h4_bullishBaseColor, h4_ifvgFillTransparency)

h4_bearIfvgFill = color.new(h4_bearishBaseColor, h4_ifvgFillTransparency)

h4_bullBorder = color.new(h4_bullishBaseColor, h4_borderTransparency)

h4_bearBorder = color.new(h4_bearishBaseColor, h4_borderTransparency)

int h4_DAY_MS = 24 * 60 * 60 * 1000

int h4_lookbackMs = h4_lookbackDays * h4_DAY_MS

// Kind codes:

//   +1 = Bullish FVG

//   -1 = Bearish FVG

//   +2 = Bullish IFVG

//   -2 = Bearish IFVG

//------------------------------------------------------------------------------

// Zone object

//------------------------------------------------------------------------------

type h4_Zone

    float lo

    float hi

    int leftTime

    int originTime

    int originDirection

    int kind

    int oppositeCloseCount

    int reverseCloseCount

    int fvgRunId

    int fvgOrdinal

    int fvgRunSize

    int ifvgRunId

    int ifvgOrdinal

    int ifvgRunSize

    box bx

    bool touched

    int armedAfterBar

    // Permanent original-FVG history, independent of alert re-arming.
    int formationAfterBar

    bool originalFvgRetraced

h4_f_zone_text(int kind) =>

    h4_showZoneText ? h4_timeframeTag : ""

h4_f_kind_enabled(int kind) =>

    bool master = h4_canRun and h4_enable4HMaster

    kind == 1 ? master and (global_enableAllBullish and h4_enableAllBullish) and h4_enable4HBullFvg :

     kind == -1 ? master and (global_enableAllBearish and h4_enableAllBearish) and h4_enable4HBearFvg :

     kind == 2 ? master and (global_enableAllBullish and h4_enableAllBullish) and h4_enable4HBullIfvg :

     master and (global_enableAllBearish and h4_enableAllBearish) and h4_enable4HBearIfvg

h4_f_kind_fill(int kind) =>

    kind == 1 ? h4_bullFvgFill :

     kind == -1 ? h4_bearFvgFill :

     kind == 2 ? h4_bullIfvgFill : h4_bearIfvgFill

h4_f_kind_border(int kind) =>

    kind > 0 ? h4_bullBorder : h4_bearBorder

h4_f_kind_style(int kind) =>

    math.abs(kind) == 1 ? line.style_solid : line.style_dashed

h4_f_fixed_left(int firstCandleTime, int endCandleTime) =>

    h4_projectionAnchor == "First FVG candle" ? firstCandleTime : endCandleTime

h4_f_zone_visible(h4_Zone z) =>
    h4_f_kind_enabled(z.kind)

h4_f_make_box(

     int leftTime,

     int rightTime,

     float lo,

     float hi,

     int kind) =>

    box.new(

         left=leftTime,

         top=hi,

         right=rightTime,

         bottom=lo,

         xloc=xloc.bar_time,

         extend=extend.none,

         bgcolor=h4_f_kind_fill(kind),

         border_color=h4_f_kind_border(kind),

         border_width=h4_boxBorderWidth,

         border_style=h4_f_kind_style(kind),

         text=h4_f_zone_text(kind),

         text_color=h4_zoneTextColor,

         text_size=size.tiny,

         text_halign=text.align_right,

         text_valign=text.align_center)

h4_f_delete_box(box boxId) =>

    if not na(boxId)

        box.delete(boxId)

h4_f_add_zone(

     array<h4_Zone> zones,

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int fvgRunId,

     int fvgOrdinal,

     int fvgRunSize,

     int currentRightTime) =>

    int leftTime = h4_f_fixed_left(firstCandleTime, endCandleTime)

    h4_Zone z = h4_Zone.new(

         lo,

         hi,

         leftTime,

         originTime,

         originDirection,

         originDirection,

         0,

         0,

         fvgRunId,

         fvgOrdinal,

         fvgRunSize,

         na,

         0,

         0,

         na,

         false,

         armedAfterBar,

         armedAfterBar,

         false)

    if h4_f_zone_visible(z)

        z.bx := h4_f_make_box(leftTime, currentRightTime, lo, hi, z.kind)

    array.push(zones, z)

h4_f_update_fvg_run_size(array<h4_Zone> zones, int runId, int runSize) =>

    int i = 0

    while i < array.size(zones)

        h4_Zone z = array.get(zones, i)

        if z.fvgRunId == runId

            z.fvgRunSize := runSize

            array.set(zones, i, z)

        i += 1

h4_f_update_ifvg_run_size(array<h4_Zone> zones, int runId, int runSize) =>

    int i = 0

    while i < array.size(zones)

        h4_Zone z = array.get(zones, i)

        if z.ifvgRunId == runId

            z.ifvgRunSize := runSize

            array.set(zones, i, z)

        i += 1

h4_f_prune_lookback(array<h4_Zone> zones, int cutoffTime) =>

    int i = array.size(zones) - 1

    while i >= 0

        h4_Zone z = array.get(zones, i)

        if z.originTime < cutoffTime

            h4_f_delete_box(z.bx)

            array.remove(zones, i)

        i -= 1

// Dynamic right edge + ordinal filtering + current classification styling.

h4_f_sync_zones(array<h4_Zone> zones, int currentRightTime) =>

    int i = 0

    while i < array.size(zones)

        h4_Zone z = array.get(zones, i)

        // Ignore the formation candle; remember every later touch, even if hidden.
        if not z.originalFvgRetraced and bar_index > z.formationAfterBar
            bool reachedOriginalGap = z.originDirection == 1 ? low <= z.hi : high >= z.lo
            if reachedOriginalGap
                z.originalFvgRetraced := true

        bool visible = h4_f_zone_visible(z) and (not onlyUnmitigatedFvgs or (math.abs(z.kind) == 1 and not z.originalFvgRetraced))

        if visible

            if na(z.bx)

                z.bx := h4_f_make_box(z.leftTime, currentRightTime, z.lo, z.hi, z.kind)

            else

                box.set_right(z.bx, currentRightTime)

                box.set_bgcolor(z.bx, h4_f_kind_fill(z.kind))

                box.set_border_color(z.bx, h4_f_kind_border(z.kind))

                box.set_border_width(z.bx, h4_boxBorderWidth)

                box.set_border_style(z.bx, h4_f_kind_style(z.kind))

                box.set_text(z.bx, h4_f_zone_text(z.kind))

                box.set_text_color(z.bx, h4_zoneTextColor)

        else

            h4_f_delete_box(z.bx)

            z.bx := na

        array.set(zones, i, z)

        i += 1

//------------------------------------------------------------------------------

// Persistent current-price classification

//------------------------------------------------------------------------------

// In this optional mode, IFVG ordinal identity inherits the original FVG run identity.

// This keeps the 1st..5th filter deterministic even when live price flips a zone state.

h4_f_process_current_price_classification(

     array<h4_Zone> zones,

     float currentPrice,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = 0

    while i < array.size(zones)

        h4_Zone z = array.get(zones, i)

        int oldKind = z.kind

        int resolvedKind = oldKind

        if z.originDirection == -1

            // Original bearish FVG: below = Bearish FVG; above = Bullish IFVG.

            if currentPrice > z.hi

                resolvedKind := 2

            else if currentPrice < z.lo

                resolvedKind := -1

        else

            // Original bullish FVG: above = Bullish FVG; below = Bearish IFVG.

            if currentPrice < z.lo

                resolvedKind := -2

            else if currentPrice > z.hi

                resolvedKind := 1

        if resolvedKind != oldKind

            z.kind := resolvedKind

            z.oppositeCloseCount := 0

            z.reverseCloseCount := 0

            z.touched := false

            z.armedAfterBar := currentChartBar

            if math.abs(resolvedKind) == 2

                z.ifvgRunId := z.fvgRunId

                z.ifvgOrdinal := z.fvgOrdinal

                z.ifvgRunSize := z.fvgRunSize

                if resolvedKind == 2

                    newBullIfvg := true

                else

                    newBearIfvg := true

        array.set(zones, i, z)

        i += 1

    [newBullIfvg, newBearIfvg]

// direction: +1 bullish state; -1 bearish state.

h4_f_first_touch_kind(

     array<h4_Zone> zones,

     int targetKind,

     int direction,

     float chartHigh,

     float chartLow,

     int currentChartBar) =>

    bool pulse = false

    int i = 0

    while i < array.size(zones)

        h4_Zone z = array.get(zones, i)

        if z.kind == targetKind and h4_f_zone_visible(z)

            bool eligible = currentChartBar > z.armedAfterBar

            bool reachedBoundary = direction == 1 ? chartLow <= z.hi : chartHigh >= z.lo

            if eligible and not z.touched and reachedBoundary

                z.touched := true

                array.set(zones, i, z)

                pulse := true

        i += 1

    pulse

//------------------------------------------------------------------------------

// 4H source data

//------------------------------------------------------------------------------

bool h4_hasEnough4HChartBars = bar_index >= 2

// Lower-than-4H charts request the PREVIOUS fully closed 4H candle.

// The one-bar security offset ensures unfinished 4H candles never count as confirmed.

[h4_h4TimeClosed, h4_h4TimeCloseClosed, h4_h4FirstTimeClosed,

 h4_h4HighClosed, h4_h4LowClosed, h4_h4CloseClosed,

 h4_h4HighTwoBackClosed, h4_h4LowTwoBackClosed] = request.security(

     syminfo.tickerid,

     "240",

     [time[1], time_close[1], time[3], high[1], low[1], close[1], high[3], low[3]],

     gaps=barmerge.gaps_off,

     lookahead=barmerge.lookahead_on)

int h4_h4Time = h4_isFourHourChart ? time : h4_h4TimeClosed

int h4_h4TimeClose = h4_isFourHourChart ? time_close : h4_h4TimeCloseClosed

int h4_h4FirstTime = h4_isFourHourChart ? (h4_hasEnough4HChartBars ? time[2] : na) : h4_h4FirstTimeClosed

float h4_h4High = h4_isFourHourChart ? high : h4_h4HighClosed

float h4_h4Low = h4_isFourHourChart ? low : h4_h4LowClosed

float h4_h4Close = h4_isFourHourChart ? close : h4_h4CloseClosed

float h4_h4HighTwoBack = h4_isFourHourChart ? (h4_hasEnough4HChartBars ? high[2] : na) : h4_h4HighTwoBackClosed

float h4_h4LowTwoBack = h4_isFourHourChart ? (h4_hasEnough4HChartBars ? low[2] : na) : h4_h4LowTwoBackClosed

bool h4_sourceClosed4H = h4_canRun and (

     (h4_isFourHourChart and h4_hasEnough4HChartBars and barstate.isconfirmed) or

     (h4_isLowerThanFourHourChart and barstate.isnew and timeframe.change("240") and not na(h4_h4TimeClosed)))

int h4_armedAfterBar4H = h4_isFourHourChart ? bar_index : bar_index - 1

// Every visible zone ends at the opening timestamp of the current chart candle.

int h4_currentZoneRightTime = time

//------------------------------------------------------------------------------

// Inventory and run state

//------------------------------------------------------------------------------

var array<h4_Zone> h4_zones4H = array.new<h4_Zone>()

var int h4_nextFvgRunId = 0

var int h4_currentBullFvgRunId = na

var int h4_currentBearFvgRunId = na

var int h4_currentBullFvgRunCount = 0

var int h4_currentBearFvgRunCount = 0

var bool h4_previous4HBullGap = false

var bool h4_previous4HBearGap = false

var int h4_nextIfvgRunId = 0

var int h4_currentBullIfvgRunId = na

var int h4_currentBearIfvgRunId = na

var int h4_currentBullIfvgRunCount = 0

var int h4_currentBearIfvgRunCount = 0

var bool h4_previous4HBullIfvgConversion = false

var bool h4_previous4HBearIfvgConversion = false

//------------------------------------------------------------------------------

// Lookback pruning — based on ORIGINAL 4H FVG formation time

//------------------------------------------------------------------------------

int h4_currentCutoffTime = time - h4_lookbackMs

h4_f_prune_lookback(h4_zones4H, h4_currentCutoffTime)

//------------------------------------------------------------------------------

// Pulses

//------------------------------------------------------------------------------

bool h4_n4HBullFvgRaw = false

bool h4_n4HBearFvgRaw = false

bool h4_n4HBullIfvgRaw = false

bool h4_n4HBearIfvgRaw = false

//------------------------------------------------------------------------------

// Process each confirmed 4H source close

//------------------------------------------------------------------------------

if h4_sourceClosed4H

    int bullIfvgConversionsThisClose = 0

    int bearIfvgConversionsThisClose = 0

    // 1) Update lifecycle of zones that existed before this source close.

    if h4_useConfirmedLifecycle

        int i = 0

        while i < array.size(h4_zones4H)

            h4_Zone z = array.get(h4_zones4H, i)

            bool removeZone = false

            if z.kind == 1

                // Bullish FVG -> Bearish IFVG after TWO consecutive closes below lo.

                if h4_h4Close < z.lo

                    z.oppositeCloseCount += 1

                    if z.oppositeCloseCount >= 2

                        z.kind := -2

                        z.oppositeCloseCount := 0

                        z.reverseCloseCount := 0

                        z.touched := false

                        z.armedAfterBar := h4_armedAfterBar4H

                        // Assign this conversion to the current Bearish IFVG run.

                        if bearIfvgConversionsThisClose == 0

                            if not h4_previous4HBearIfvgConversion or na(h4_currentBearIfvgRunId)

                                h4_nextIfvgRunId += 1

                                h4_currentBearIfvgRunId := h4_nextIfvgRunId

                                h4_currentBearIfvgRunCount := 0

                        h4_currentBearIfvgRunCount += 1

                        bearIfvgConversionsThisClose += 1

                        z.ifvgRunId := h4_currentBearIfvgRunId

                        z.ifvgOrdinal := h4_currentBearIfvgRunCount

                        z.ifvgRunSize := h4_currentBearIfvgRunCount

                        h4_n4HBearIfvgRaw := true

                else

                    z.oppositeCloseCount := 0

            else if z.kind == -1

                // Bearish FVG -> Bullish IFVG after TWO consecutive closes above hi.

                if h4_h4Close > z.hi

                    z.oppositeCloseCount += 1

                    if z.oppositeCloseCount >= 2

                        z.kind := 2

                        z.oppositeCloseCount := 0

                        z.reverseCloseCount := 0

                        z.touched := false

                        z.armedAfterBar := h4_armedAfterBar4H

                        // Assign this conversion to the current Bullish IFVG run.

                        if bullIfvgConversionsThisClose == 0

                            if not h4_previous4HBullIfvgConversion or na(h4_currentBullIfvgRunId)

                                h4_nextIfvgRunId += 1

                                h4_currentBullIfvgRunId := h4_nextIfvgRunId

                                h4_currentBullIfvgRunCount := 0

                        h4_currentBullIfvgRunCount += 1

                        bullIfvgConversionsThisClose += 1

                        z.ifvgRunId := h4_currentBullIfvgRunId

                        z.ifvgOrdinal := h4_currentBullIfvgRunCount

                        z.ifvgRunSize := h4_currentBullIfvgRunCount

                        h4_n4HBullIfvgRaw := true

                else

                    z.oppositeCloseCount := 0

            else if z.kind == 2

                // Bullish IFVG invalidation: consecutive confirmed closes BELOW lo.

                if h4_h4Close < z.lo

                    z.reverseCloseCount += 1

                    if z.reverseCloseCount >= h4_ifvgInvalidationCloses

                        removeZone := true

                else

                    z.reverseCloseCount := 0

            else if z.kind == -2

                // Bearish IFVG invalidation: consecutive confirmed closes ABOVE hi.

                if h4_h4Close > z.hi

                    z.reverseCloseCount += 1

                    if z.reverseCloseCount >= h4_ifvgInvalidationCloses

                        removeZone := true

                else

                    z.reverseCloseCount := 0

            if removeZone

                h4_f_delete_box(z.bx)

                array.remove(h4_zones4H, i)

            else

                array.set(h4_zones4H, i, z)

                i += 1

        // Finalize IFVG run sizes after all conversions on this 4H close are known.

        if bullIfvgConversionsThisClose > 0

            h4_f_update_ifvg_run_size(h4_zones4H, h4_currentBullIfvgRunId, h4_currentBullIfvgRunCount)

            h4_previous4HBullIfvgConversion := true

        else

            h4_previous4HBullIfvgConversion := false

            h4_currentBullIfvgRunId := na

            h4_currentBullIfvgRunCount := 0

        if bearIfvgConversionsThisClose > 0

            h4_f_update_ifvg_run_size(h4_zones4H, h4_currentBearIfvgRunId, h4_currentBearIfvgRunCount)

            h4_previous4HBearIfvgConversion := true

        else

            h4_previous4HBearIfvgConversion := false

            h4_currentBearIfvgRunId := na

            h4_currentBearIfvgRunCount := 0

    // 2) Detect new strict three-candle 4H FVG geometry.

    bool bullishGap = not na(h4_h4HighTwoBack) and h4_h4Low > h4_h4HighTwoBack

    bool bearishGap = not na(h4_h4LowTwoBack) and h4_h4High < h4_h4LowTwoBack

    float bullishGapSize = bullishGap ? h4_h4Low - h4_h4HighTwoBack : 0.0

    float bearishGapSize = bearishGap ? h4_h4LowTwoBack - h4_h4High : 0.0

    if bullishGap and bullishGapSize >= h4_minGap4H

        if h4_previous4HBullGap and not na(h4_currentBullFvgRunId)

            h4_currentBullFvgRunCount += 1

        else

            h4_nextFvgRunId += 1

            h4_currentBullFvgRunId := h4_nextFvgRunId

            h4_currentBullFvgRunCount := 1

        h4_f_add_zone(

             h4_zones4H,

             h4_h4HighTwoBack,

             h4_h4Low,

             h4_h4FirstTime,

             h4_h4Time,

             h4_h4Time,

             1,

             h4_armedAfterBar4H,

             h4_currentBullFvgRunId,

             h4_currentBullFvgRunCount,

             h4_currentBullFvgRunCount,

             h4_currentZoneRightTime)

        h4_f_update_fvg_run_size(h4_zones4H, h4_currentBullFvgRunId, h4_currentBullFvgRunCount)

        h4_n4HBullFvgRaw := true

    else

        h4_currentBullFvgRunId := na

        h4_currentBullFvgRunCount := 0

    if bearishGap and bearishGapSize >= h4_minGap4H

        if h4_previous4HBearGap and not na(h4_currentBearFvgRunId)

            h4_currentBearFvgRunCount += 1

        else

            h4_nextFvgRunId += 1

            h4_currentBearFvgRunId := h4_nextFvgRunId

            h4_currentBearFvgRunCount := 1

        h4_f_add_zone(

             h4_zones4H,

             h4_h4High,

             h4_h4LowTwoBack,

             h4_h4FirstTime,

             h4_h4Time,

             h4_h4Time,

             -1,

             h4_armedAfterBar4H,

             h4_currentBearFvgRunId,

             h4_currentBearFvgRunCount,

             h4_currentBearFvgRunCount,

             h4_currentZoneRightTime)

        h4_f_update_fvg_run_size(h4_zones4H, h4_currentBearFvgRunId, h4_currentBearFvgRunCount)

        h4_n4HBearFvgRaw := true

    else

        h4_currentBearFvgRunId := na

        h4_currentBearFvgRunCount := 0

    h4_previous4HBullGap := bullishGap and bullishGapSize >= h4_minGap4H

    h4_previous4HBearGap := bearishGap and bearishGapSize >= h4_minGap4H

// Persistent mode follows CURRENT MARKET PRICE on every chart bar.

if h4_canRun and not h4_useConfirmedLifecycle

    [bullIfvgDynamicPulse, bearIfvgDynamicPulse] = h4_f_process_current_price_classification(

         h4_zones4H,

         close,

         bar_index)

    h4_n4HBullIfvgRaw := h4_n4HBullIfvgRaw or bullIfvgDynamicPulse

    h4_n4HBearIfvgRaw := h4_n4HBearIfvgRaw or bearIfvgDynamicPulse

// Re-prune after processing so formation lookback remains authoritative.

h4_f_prune_lookback(h4_zones4H, h4_currentCutoffTime)

//------------------------------------------------------------------------------

// Dynamic right-edge + text/style + ordinal synchronization

//------------------------------------------------------------------------------

h4_f_sync_zones(h4_zones4H, h4_currentZoneRightTime)

//------------------------------------------------------------------------------

// First-retest pulses by CURRENT classification and CURRENT visibility filter

//------------------------------------------------------------------------------

h4_t4HBullFvgRaw = h4_canRun ? h4_f_first_touch_kind(h4_zones4H, 1, 1, high, low, bar_index) : false

h4_t4HBearFvgRaw = h4_canRun ? h4_f_first_touch_kind(h4_zones4H, -1, -1, high, low, bar_index) : false

h4_t4HBullIfvgRaw = h4_canRun ? h4_f_first_touch_kind(h4_zones4H, 2, 1, high, low, bar_index) : false

h4_t4HBearIfvgRaw = h4_canRun ? h4_f_first_touch_kind(h4_zones4H, -2, -1, high, low, bar_index) : false

//------------------------------------------------------------------------------

// Effective alert pulses

//------------------------------------------------------------------------------

h4_n4HBullFvg = h4_canRun and h4_enable4HMaster and (global_enableAllBullish and h4_enableAllBullish) and h4_enable4HBullFvg and h4_n4HBullFvgRaw

h4_n4HBearFvg = h4_canRun and h4_enable4HMaster and (global_enableAllBearish and h4_enableAllBearish) and h4_enable4HBearFvg and h4_n4HBearFvgRaw

h4_n4HBullIfvg = h4_canRun and h4_enable4HMaster and (global_enableAllBullish and h4_enableAllBullish) and h4_enable4HBullIfvg and h4_n4HBullIfvgRaw

h4_n4HBearIfvg = h4_canRun and h4_enable4HMaster and (global_enableAllBearish and h4_enableAllBearish) and h4_enable4HBearIfvg and h4_n4HBearIfvgRaw

h4_t4HBullFvg = h4_canRun and h4_enable4HMaster and (global_enableAllBullish and h4_enableAllBullish) and h4_enable4HBullFvg and h4_t4HBullFvgRaw

h4_t4HBearFvg = h4_canRun and h4_enable4HMaster and (global_enableAllBearish and h4_enableAllBearish) and h4_enable4HBearFvg and h4_t4HBearFvgRaw

h4_t4HBullIfvg = h4_canRun and h4_enable4HMaster and (global_enableAllBullish and h4_enableAllBullish) and h4_enable4HBullIfvg and h4_t4HBullIfvgRaw

h4_t4HBearIfvg = h4_canRun and h4_enable4HMaster and (global_enableAllBearish and h4_enableAllBearish) and h4_enable4HBearIfvg and h4_t4HBearIfvgRaw

//==============================================================================

// 4H FORMATION / CLASSIFICATION ALERTS

//==============================================================================

alertcondition(h4_n4HBullFvg, title="4H Bullish FVG Formed", message="{{ticker}}: 4H bullish FVG formed.")

alertcondition(h4_n4HBearFvg, title="4H Bearish FVG Formed", message="{{ticker}}: 4H bearish FVG formed.")

alertcondition(h4_n4HBullIfvg, title="4H Bullish IFVG Formed", message="{{ticker}}: 4H zone classified as bullish IFVG.")

alertcondition(h4_n4HBearIfvg, title="4H Bearish IFVG Formed", message="{{ticker}}: 4H zone classified as bearish IFVG.")

//==============================================================================

// 4H FIRST-RETEST ALERTS

//==============================================================================

alertcondition(h4_t4HBullFvg, title="4H Bullish FVG First Retest", message="{{ticker}}: price reached a visible 4H bullish FVG.")

alertcondition(h4_t4HBearFvg, title="4H Bearish FVG First Retest", message="{{ticker}}: price reached a visible 4H bearish FVG.")

alertcondition(h4_t4HBullIfvg, title="4H Bullish IFVG First Retest", message="{{ticker}}: price reached a visible 4H bullish IFVG.")

alertcondition(h4_t4HBearIfvg, title="4H Bearish IFVG First Retest", message="{{ticker}}: price reached a visible 4H bearish IFVG.")



//==============================================================================

// 1H FVG / IFVG INVENTORY — V2.0

//------------------------------------------------------------------------------

// 1. 1H source timeframe only. Works on intraday charts up to and including 1H.

// 2. Bullish FVG = third 1H candle LOW > first 1H candle HIGH.

//    Zone = first candle HIGH -> third candle LOW.

// 3. Bearish FVG = third 1H candle HIGH < first 1H candle LOW.

//    Zone = third candle HIGH -> first candle LOW.

// 4. Adjacent close/open gaps are ignored. Only candle 1 vs candle 3 geometry matters.

// 5. Every visible zone dynamically extends to the OPEN of the current chart candle.

//    Box text is right-aligned and vertically centered, keeping the 1H tag at the

//    current right edge on supported intraday charts up to and including 1H.

// 6. DEFAULT lifecycle mode:

//      - One 1H close beyond an FVG does NOT convert it.

//      - Two CONSECUTIVE confirmed 1H closes beyond the far boundary convert it

//        into the opposite-direction IFVG.

//      - After conversion, the configured number of consecutive confirmed 1H closes back through the opposite

//        boundary invalidates/removes that IFVG.

// 7. PERSISTENT CURRENT-PRICE mode (default lifecycle switch OFF):

//      - Original 1H gaps are never permanently invalidated inside lookback.

//      - Current price on native side => original FVG.

//      - Current price beyond opposite side => opposite-direction IFVG.

//      - If current price is inside the zone, the most recently resolved state remains.

// 8. Calendar-day lookback: 5 / 10 / 15 / 30 / 90 / 180 / 365.

//==============================================================================

//------------------------------------------------------------------------------

// 01. Master controls

//------------------------------------------------------------------------------

h1_groupMaster = "1H • 01. Master Controls"

h1_enableIndicator = input.bool(true, "Enable indicator", group=h1_groupMaster)




h1_showZoneText = input.bool(true, "Show timeframe tag", group=h1_groupMaster)

h1_timeframeTag = input.string("1H", "Custom timeframe tag", tooltip="Text shown inside every visible 1H FVG / IFVG box. Example: 1H, H1, 60. Only this tag is displayed on the box; direction and FVG / IFVG wording are intentionally omitted.", group=h1_groupMaster)

h1_lookbackDays = input.int(

     30,

     "1H FVG / IFVG lookback, calendar days",

     options=[5, 10, 15, 30, 90, 180, 365],

     group=h1_groupMaster)

h1_projectionAnchor = input.string(

     "First FVG candle",

     "Zone begins from",

     options=["First FVG candle", "FVG end candle"],

     group=h1_groupMaster)

//------------------------------------------------------------------------------

// 02. Classification / lifecycle

//------------------------------------------------------------------------------

h1_groupLifecycle = "1H • 02. Classification / Lifecycle"

h1_useConfirmedLifecycle = input.bool(

     true,

     "Require 2 confirmed 1H closes for FVG -> IFVG",

     tooltip="ON (default): one opposite 1H close is ignored; two consecutive confirmed 1H closes beyond the FVG convert it to an IFVG. IFVG invalidation is controlled separately below.\n\nOFF: never permanently invalidate an original gap inside the selected lookback. Classify each zone from current market price: native side = FVG, opposite side = IFVG.",

     group=h1_groupLifecycle)

h1_invalidateIfvgs = input.bool(

     true,

     "Enable confirmed 1H IFVG invalidation",

     tooltip="ON: confirmed 1H closes can invalidate IFVGs using the bullish/bearish close-count settings below. OFF: once a zone becomes an IFVG in confirmed lifecycle mode, it remains on the chart until it falls outside the lookback or you hide it with visibility controls.",

     group=h1_groupLifecycle)

h1_bullIfvgInvalidationCloses = input.int(

     1,

     "Bullish IFVG: 1H closes below zone to invalidate",

     options=[1, 2, 3, 4, 5],

     tooltip="Number of CONSECUTIVE confirmed 1H closes below the bullish IFVG lower boundary required to remove the bullish IFVG.",

     group=h1_groupLifecycle)

h1_bearIfvgInvalidationCloses = input.int(

     1,

     "Bearish IFVG: 1H closes above zone to invalidate",

     options=[1, 2, 3, 4, 5],

     tooltip="Number of CONSECUTIVE confirmed 1H closes above the bearish IFVG upper boundary required to remove the bearish IFVG.",

     group=h1_groupLifecycle)

//------------------------------------------------------------------------------

// 03. 1H inventory / minimum size

//------------------------------------------------------------------------------

h1_groupInventory = "1H • 03. 1H Inventory / Minimum Size"

h1_minGapH = input.float(

     0.0,

     "1H: minimum FVG size, points",

     minval=0.0,

     step=0.25,

     group=h1_groupInventory)

//------------------------------------------------------------------------------

// 04. Individual 1H controls

//------------------------------------------------------------------------------

h1_groupHourly = "1H • 04. 1H Individual Controls"

h1_enableHBullFvg = input.bool(true, "1H Bullish FVG — plot + alerts", group=h1_groupHourly)

h1_enableHBearFvg = input.bool(true, "1H Bearish FVG — plot + alerts", group=h1_groupHourly)

h1_enableHBullIfvg = input.bool(true, "1H Bullish IFVG — plot + alerts", group=h1_groupHourly)

h1_enableHBearIfvg = input.bool(true, "1H Bearish IFVG — plot + alerts", group=h1_groupHourly)

//------------------------------------------------------------------------------

// 05. Visual customization — same colors as original indicator

//------------------------------------------------------------------------------

h1_groupVisual = "1H • 05. Visual Customization"

h1_bullishBaseColor = input.color(color.rgb(0, 139, 170), "Bullish cyan-blue", group=h1_groupVisual)

h1_bearishBaseColor = input.color(color.rgb(132, 78, 170), "Bearish purple", group=h1_groupVisual)

h1_fvgFillTransparency = input.int(84, "FVG fill transparency", minval=0, maxval=100, group=h1_groupVisual)

h1_ifvgFillTransparency = input.int(87, "IFVG fill transparency", minval=0, maxval=100, group=h1_groupVisual)

h1_borderTransparency = input.int(18, "Border transparency", minval=0, maxval=100, group=h1_groupVisual)

h1_boxBorderWidth = input.int(1, "Box border width", minval=0, maxval=4, group=h1_groupVisual)

h1_zoneTextColor = input.color(color.new(color.white, 15), "Zone text color", group=h1_groupVisual)

//------------------------------------------------------------------------------

// Routing and effective controls

//------------------------------------------------------------------------------

int h1_chartTimeframeSeconds = timeframe.in_seconds()

h1_isOneHourChart = timeframe.isintraday and h1_chartTimeframeSeconds == 60 * 60

h1_isLowerIntradayChart = timeframe.isintraday and h1_chartTimeframeSeconds < 60 * 60

h1_supportedChart = h1_isOneHourChart or h1_isLowerIntradayChart

h1_canRun = h1_enableIndicator and h1_supportedChart

h1_bullFvgFill = color.new(h1_bullishBaseColor, h1_fvgFillTransparency)

h1_bearFvgFill = color.new(h1_bearishBaseColor, h1_fvgFillTransparency)

h1_bullIfvgFill = color.new(h1_bullishBaseColor, h1_ifvgFillTransparency)

h1_bearIfvgFill = color.new(h1_bearishBaseColor, h1_ifvgFillTransparency)

h1_bullBorder = color.new(h1_bullishBaseColor, h1_borderTransparency)

h1_bearBorder = color.new(h1_bearishBaseColor, h1_borderTransparency)

int h1_DAY_MS = 24 * 60 * 60 * 1000

int h1_lookbackMs = h1_lookbackDays * h1_DAY_MS

// Kind codes:

//   +1 = Bullish FVG

//   -1 = Bearish FVG

//   +2 = Bullish IFVG

//   -2 = Bearish IFVG

//------------------------------------------------------------------------------

// Zone object

//------------------------------------------------------------------------------

type h1_Zone

    float lo

    float hi

    int leftTime

    int originTime

    int originDirection

    int kind

    int oppositeCloseCount

    box bx

    bool touched

    int armedAfterBar

    // Permanent original-FVG history, independent of alert re-arming.
    int formationAfterBar

    bool originalFvgRetraced

h1_f_zone_text(int kind) =>

    h1_showZoneText ? h1_timeframeTag : ""

h1_f_kind_visible(int kind) =>

    bool master = h1_canRun and h1_enableHourlyMaster

    kind == 1 ? master and (global_enableAllBullish and h1_enableAllBullish) and h1_enableHBullFvg :

     kind == -1 ? master and (global_enableAllBearish and h1_enableAllBearish) and h1_enableHBearFvg :

     kind == 2 ? master and (global_enableAllBullish and h1_enableAllBullish) and h1_enableHBullIfvg :

     master and (global_enableAllBearish and h1_enableAllBearish) and h1_enableHBearIfvg

h1_f_kind_fill(int kind) =>

    kind == 1 ? h1_bullFvgFill :

     kind == -1 ? h1_bearFvgFill :

     kind == 2 ? h1_bullIfvgFill : h1_bearIfvgFill

h1_f_kind_border(int kind) =>

    kind > 0 ? h1_bullBorder : h1_bearBorder

h1_f_kind_style(int kind) =>

    math.abs(kind) == 1 ? line.style_solid : line.style_dashed

h1_f_fixed_left(int firstCandleTime, int endCandleTime) =>

    h1_projectionAnchor == "First FVG candle" ? firstCandleTime : endCandleTime

h1_f_make_box(

     int leftTime,

     int rightTime,

     float lo,

     float hi,

     int kind) =>

    box.new(

         left=leftTime,

         top=hi,

         right=rightTime,

         bottom=lo,

         xloc=xloc.bar_time,

         extend=extend.none,

         bgcolor=h1_f_kind_fill(kind),

         border_color=h1_f_kind_border(kind),

         border_width=h1_boxBorderWidth,

         border_style=h1_f_kind_style(kind),

         text=h1_f_zone_text(kind),

         text_color=h1_zoneTextColor,

         text_size=size.tiny,

         text_halign=text.align_right,

         text_valign=text.align_center)

h1_f_delete_box(box boxId) =>

    if not na(boxId)

        box.delete(boxId)

h1_f_new_zone(

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int currentRightTime) =>

    int leftTime = h1_f_fixed_left(firstCandleTime, endCandleTime)

    int initialKind = originDirection

    box boxId = na

    if h1_f_kind_visible(initialKind)

        boxId := h1_f_make_box(leftTime, currentRightTime, lo, hi, initialKind)

    h1_Zone.new(

         lo,

         hi,

         leftTime,

         originTime,

         originDirection,

         initialKind,

         0,

         boxId,

         false,

         armedAfterBar,

         armedAfterBar,

         false)

h1_f_add_zone(

     array<h1_Zone> zones,

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int currentRightTime) =>

    h1_Zone z = h1_f_new_zone(

         lo,

         hi,

         firstCandleTime,

         endCandleTime,

         originTime,

         originDirection,

         armedAfterBar,

         currentRightTime)

    array.push(zones, z)

h1_f_prune_lookback(array<h1_Zone> zones, int cutoffTime) =>

    int i = array.size(zones) - 1

    while i >= 0

        h1_Zone z = array.get(zones, i)

        if z.originTime < cutoffTime

            h1_f_delete_box(z.bx)

            array.remove(zones, i)

        i -= 1

// Apply visibility, style, text, and — critically — the dynamic right edge.

h1_f_sync_zones(array<h1_Zone> zones, int currentRightTime) =>

    int i = 0

    while i < array.size(zones)

        h1_Zone z = array.get(zones, i)

        // Ignore the formation candle; remember every later touch, even if hidden.
        if not z.originalFvgRetraced and bar_index > z.formationAfterBar
            bool reachedOriginalGap = z.originDirection == 1 ? low <= z.hi : high >= z.lo
            if reachedOriginalGap
                z.originalFvgRetraced := true

        bool visible = h1_f_kind_visible(z.kind) and (not onlyUnmitigatedFvgs or (math.abs(z.kind) == 1 and not z.originalFvgRetraced))

        if visible

            if na(z.bx)

                z.bx := h1_f_make_box(z.leftTime, currentRightTime, z.lo, z.hi, z.kind)

            else

                box.set_right(z.bx, currentRightTime)

                box.set_bgcolor(z.bx, h1_f_kind_fill(z.kind))

                box.set_border_color(z.bx, h1_f_kind_border(z.kind))

                box.set_border_width(z.bx, h1_boxBorderWidth)

                box.set_border_style(z.bx, h1_f_kind_style(z.kind))

                box.set_text(z.bx, h1_f_zone_text(z.kind))

                box.set_text_color(z.bx, h1_zoneTextColor)

        else

            h1_f_delete_box(z.bx)

            z.bx := na

        array.set(zones, i, z)

        i += 1

//------------------------------------------------------------------------------

// DEFAULT confirmed lifecycle

//------------------------------------------------------------------------------

// One opposite 1H close does not change an FVG.

// Two consecutive opposite 1H closes convert FVG -> IFVG.

// IFVG invalidation is independently configurable from 1 to 5 consecutive 1H closes.

// When IFVG invalidation is OFF, converted IFVGs remain until lookback pruning or visibility hiding.

h1_f_process_confirmed_lifecycle(

     array<h1_Zone> zones,

     float sourceClose,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = array.size(zones) - 1

    while i >= 0

        h1_Zone z = array.get(zones, i)

        bool removeZone = false

        if z.kind == 1

            // Bullish FVG -> Bearish IFVG after TWO consecutive confirmed 1H closes below lo.

            if sourceClose < z.lo

                z.oppositeCloseCount += 1

                if z.oppositeCloseCount >= 2

                    z.kind := -2

                    z.oppositeCloseCount := 0

                    z.touched := false

                    z.armedAfterBar := currentChartBar

                    newBearIfvg := true

            else

                z.oppositeCloseCount := 0

        else if z.kind == -1

            // Bearish FVG -> Bullish IFVG after TWO consecutive confirmed 1H closes above hi.

            if sourceClose > z.hi

                z.oppositeCloseCount += 1

                if z.oppositeCloseCount >= 2

                    z.kind := 2

                    z.oppositeCloseCount := 0

                    z.touched := false

                    z.armedAfterBar := currentChartBar

                    newBullIfvg := true

            else

                z.oppositeCloseCount := 0

        else if z.kind == 2

            // Bullish IFVG: optional invalidation after configured consecutive 1H closes below lo.

            if h1_invalidateIfvgs

                if sourceClose < z.lo

                    z.oppositeCloseCount += 1

                    if z.oppositeCloseCount >= h1_bullIfvgInvalidationCloses

                        removeZone := true

                else

                    z.oppositeCloseCount := 0

            else

                z.oppositeCloseCount := 0

        else if z.kind == -2

            // Bearish IFVG: optional invalidation after configured consecutive 1H closes above hi.

            if h1_invalidateIfvgs

                if sourceClose > z.hi

                    z.oppositeCloseCount += 1

                    if z.oppositeCloseCount >= h1_bearIfvgInvalidationCloses

                        removeZone := true

                else

                    z.oppositeCloseCount := 0

            else

                z.oppositeCloseCount := 0

        if removeZone

            h1_f_delete_box(z.bx)

            array.remove(zones, i)

        else

            array.set(zones, i, z)

        i -= 1

    [newBullIfvg, newBearIfvg]

//------------------------------------------------------------------------------

// PERSISTENT current-price classification

//------------------------------------------------------------------------------

// This mode never permanently invalidates an original FVG inside lookback.

// Classification is based on current market price relative to original geometry.

h1_f_process_current_price_classification(

     array<h1_Zone> zones,

     float currentPrice,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = 0

    while i < array.size(zones)

        h1_Zone z = array.get(zones, i)

        int oldKind = z.kind

        int resolvedKind = oldKind

        if z.originDirection == -1

            // Original bearish FVG:

            // below zone = Bearish FVG; above zone = Bullish IFVG.

            if currentPrice > z.hi

                resolvedKind := 2

            else if currentPrice < z.lo

                resolvedKind := -1

        else

            // Original bullish FVG:

            // above zone = Bullish FVG; below zone = Bearish IFVG.

            if currentPrice < z.lo

                resolvedKind := -2

            else if currentPrice > z.hi

                resolvedKind := 1

        if resolvedKind != oldKind

            z.kind := resolvedKind

            z.oppositeCloseCount := 0

            z.touched := false

            z.armedAfterBar := currentChartBar

            if resolvedKind == 2

                newBullIfvg := true

            else if resolvedKind == -2

                newBearIfvg := true

        array.set(zones, i, z)

        i += 1

    [newBullIfvg, newBearIfvg]

// direction: +1 bullish state; -1 bearish state.

h1_f_first_touch_kind(

     array<h1_Zone> zones,

     int targetKind,

     int direction,

     float chartHigh,

     float chartLow,

     int currentChartBar) =>

    bool pulse = false

    int i = 0

    while i < array.size(zones)

        h1_Zone z = array.get(zones, i)

        if z.kind == targetKind

            bool eligible = currentChartBar > z.armedAfterBar

            bool reachedBoundary = direction == 1 ? chartLow <= z.hi : chartHigh >= z.lo

            if eligible and not z.touched and reachedBoundary

                z.touched := true

                array.set(zones, i, z)

                pulse := true

        i += 1

    pulse

//------------------------------------------------------------------------------

// 1H source data

//------------------------------------------------------------------------------

// On a 1H chart, process the current 1H candle only once it closes.

bool h1_hasEnoughOneHourChartBars = bar_index >= 2

// On lower intraday charts, request the PREVIOUS fully closed 1H candle with a one-bar offset.

// This prevents an unfinished 1H candle from being treated as a confirmed close.

[h1_hTimeClosed, h1_hTimeCloseClosed, h1_hFirstTimeClosed,

 h1_hHighClosed, h1_hLowClosed, h1_hCloseClosed,

 h1_hHighTwoBackClosed, h1_hLowTwoBackClosed] = request.security(

     syminfo.tickerid,

     "60",

     [time[1], time_close[1], time[3], high[1], low[1], close[1], high[3], low[3]],

     gaps=barmerge.gaps_off,

     lookahead=barmerge.lookahead_on)

int h1_hTime = h1_isOneHourChart ? time : h1_hTimeClosed

int h1_hTimeClose = h1_isOneHourChart ? time_close : h1_hTimeCloseClosed

int h1_hFirstTime = h1_isOneHourChart ? (h1_hasEnoughOneHourChartBars ? time[2] : na) : h1_hFirstTimeClosed

float h1_hHigh = h1_isOneHourChart ? high : h1_hHighClosed

float h1_hLow = h1_isOneHourChart ? low : h1_hLowClosed

float h1_hClose = h1_isOneHourChart ? close : h1_hCloseClosed

float h1_hHighTwoBack = h1_isOneHourChart ? (h1_hasEnoughOneHourChartBars ? high[2] : na) : h1_hHighTwoBackClosed

float h1_hLowTwoBack = h1_isOneHourChart ? (h1_hasEnoughOneHourChartBars ? low[2] : na) : h1_hLowTwoBackClosed

bool h1_sourceClosedH = h1_canRun and (

     (h1_isOneHourChart and h1_hasEnoughOneHourChartBars and barstate.isconfirmed) or

     (h1_isLowerIntradayChart and barstate.isnew and timeframe.change("60") and not na(h1_hTimeClosed)))

// On lower intraday charts, the previous 1H candle was already confirmed before the

// first chart bar of the new hour. That first bar can therefore interact with it.

int h1_armedAfterBarH = h1_isOneHourChart ? bar_index : bar_index - 1

// Right edge is ALWAYS the opening time of the current chart candle.

int h1_currentZoneRightTime = time

//------------------------------------------------------------------------------

// Inventory

//------------------------------------------------------------------------------

var array<h1_Zone> h1_hourlyZones = array.new<h1_Zone>()

//------------------------------------------------------------------------------

// Lookback pruning

//------------------------------------------------------------------------------

int h1_currentCutoffTime = time - h1_lookbackMs

h1_f_prune_lookback(h1_hourlyZones, h1_currentCutoffTime)

//------------------------------------------------------------------------------

// Process confirmed 1H closes and detect new 1H FVGs

//------------------------------------------------------------------------------

bool h1_nHBullFvgRaw = false

bool h1_nHBearFvgRaw = false

bool h1_nHBullIfvgRaw = false

bool h1_nHBearIfvgRaw = false

if h1_sourceClosedH

    // First update the lifecycle of zones that already existed before this 1H close.

    if h1_useConfirmedLifecycle

        [bullIfvgPulse, bearIfvgPulse] = h1_f_process_confirmed_lifecycle(

             h1_hourlyZones,

             h1_hClose,

             h1_armedAfterBarH)

        h1_nHBullIfvgRaw := bullIfvgPulse

        h1_nHBearIfvgRaw := bearIfvgPulse

    // Strict three-candle FVG geometry. Adjacent close/open gaps are irrelevant.

    bool bullishGap = not na(h1_hHighTwoBack) and h1_hLow > h1_hHighTwoBack

    bool bearishGap = not na(h1_hLowTwoBack) and h1_hHigh < h1_hLowTwoBack

    float bullishGapSize = bullishGap ? h1_hLow - h1_hHighTwoBack : 0.0

    float bearishGapSize = bearishGap ? h1_hLowTwoBack - h1_hHigh : 0.0

    if bullishGap and bullishGapSize >= h1_minGapH

        h1_f_add_zone(

             h1_hourlyZones,

             h1_hHighTwoBack,

             h1_hLow,

             h1_hFirstTime,

             h1_hTime,

             h1_hTime,

             1,

             h1_armedAfterBarH,

             h1_currentZoneRightTime)

        h1_nHBullFvgRaw := true

    if bearishGap and bearishGapSize >= h1_minGapH

        h1_f_add_zone(

             h1_hourlyZones,

             h1_hHigh,

             h1_hLowTwoBack,

             h1_hFirstTime,

             h1_hTime,

             h1_hTime,

             -1,

             h1_armedAfterBarH,

             h1_currentZoneRightTime)

        h1_nHBearFvgRaw := true

// In persistent mode, classification follows CURRENT MARKET PRICE on every chart bar,

// including the live/open candle. This is deliberately independent of 1H closes.

if h1_canRun and not h1_useConfirmedLifecycle

    [bullIfvgDynamicPulse, bearIfvgDynamicPulse] = h1_f_process_current_price_classification(

         h1_hourlyZones,

         close,

         bar_index)

    h1_nHBullIfvgRaw := h1_nHBullIfvgRaw or bullIfvgDynamicPulse

    h1_nHBearIfvgRaw := h1_nHBearIfvgRaw or bearIfvgDynamicPulse

// Re-prune after formation so selected lookback remains authoritative.

h1_f_prune_lookback(h1_hourlyZones, h1_currentCutoffTime)

//------------------------------------------------------------------------------

// Dynamic right-edge + text/style synchronization

//------------------------------------------------------------------------------

// Every box ends at the OPEN of whatever chart candle is currently active.

// Because text_halign = text.align_right, the 1H FVG/IFVG tag remains visible

// at the right edge while vertically centered inside the zone.

h1_f_sync_zones(h1_hourlyZones, h1_currentZoneRightTime)

//------------------------------------------------------------------------------

// First-retest pulses by CURRENT classification

//------------------------------------------------------------------------------

h1_tHBullFvgRaw = h1_canRun ? h1_f_first_touch_kind(h1_hourlyZones, 1, 1, high, low, bar_index) : false

h1_tHBearFvgRaw = h1_canRun ? h1_f_first_touch_kind(h1_hourlyZones, -1, -1, high, low, bar_index) : false

h1_tHBullIfvgRaw = h1_canRun ? h1_f_first_touch_kind(h1_hourlyZones, 2, 1, high, low, bar_index) : false

h1_tHBearIfvgRaw = h1_canRun ? h1_f_first_touch_kind(h1_hourlyZones, -2, -1, high, low, bar_index) : false

//------------------------------------------------------------------------------

// Effective alert pulses

//------------------------------------------------------------------------------

h1_nHBullFvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBullish and h1_enableAllBullish) and h1_enableHBullFvg and h1_nHBullFvgRaw

h1_nHBearFvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBearish and h1_enableAllBearish) and h1_enableHBearFvg and h1_nHBearFvgRaw

h1_nHBullIfvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBullish and h1_enableAllBullish) and h1_enableHBullIfvg and h1_nHBullIfvgRaw

h1_nHBearIfvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBearish and h1_enableAllBearish) and h1_enableHBearIfvg and h1_nHBearIfvgRaw

h1_tHBullFvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBullish and h1_enableAllBullish) and h1_enableHBullFvg and h1_tHBullFvgRaw

h1_tHBearFvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBearish and h1_enableAllBearish) and h1_enableHBearFvg and h1_tHBearFvgRaw

h1_tHBullIfvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBullish and h1_enableAllBullish) and h1_enableHBullIfvg and h1_tHBullIfvgRaw

h1_tHBearIfvg = h1_canRun and h1_enableHourlyMaster and (global_enableAllBearish and h1_enableAllBearish) and h1_enableHBearIfvg and h1_tHBearIfvgRaw

//==============================================================================

// 1H FORMATION / CLASSIFICATION ALERTS

//==============================================================================

alertcondition(h1_nHBullFvg, title="1H Bullish FVG Formed", message="{{ticker}}: 1H bullish FVG formed.")

alertcondition(h1_nHBearFvg, title="1H Bearish FVG Formed", message="{{ticker}}: 1H bearish FVG formed.")

alertcondition(h1_nHBullIfvg, title="1H Bullish IFVG Formed", message="{{ticker}}: 1H zone classified as bullish IFVG.")

alertcondition(h1_nHBearIfvg, title="1H Bearish IFVG Formed", message="{{ticker}}: 1H zone classified as bearish IFVG.")

//==============================================================================

// 1H FIRST-RETEST ALERTS

//==============================================================================

alertcondition(h1_tHBullFvg, title="1H Bullish FVG First Retest", message="{{ticker}}: price reached a 1H bullish FVG.")

alertcondition(h1_tHBearFvg, title="1H Bearish FVG First Retest", message="{{ticker}}: price reached a 1H bearish FVG.")

alertcondition(h1_tHBullIfvg, title="1H Bullish IFVG First Retest", message="{{ticker}}: price reached a 1H bullish IFVG.")

alertcondition(h1_tHBearIfvg, title="1H Bearish IFVG First Retest", message="{{ticker}}: price reached a 1H bearish IFVG.")



//==============================================================================
// 30M FVG / IFVG ENGINE — ADDITIVE CLONE OF EXISTING 1H LIFECYCLE LOGIC
// Existing Daily / 4H / 1H calculations are not modified by this engine.
//==============================================================================

// 30M FVG / IFVG INVENTORY — V2.0

//------------------------------------------------------------------------------

// 1. 30M source timeframe only. Works on intraday charts up to and including 30M.

// 2. Bullish FVG = third 30M candle LOW > first 30M candle HIGH.

//    Zone = first candle HIGH -> third candle LOW.

// 3. Bearish FVG = third 30M candle HIGH < first 30M candle LOW.

//    Zone = third candle HIGH -> first candle LOW.

// 4. Adjacent close/open gaps are ignored. Only candle 1 vs candle 3 geometry matters.

// 5. Every visible zone dynamically extends to the OPEN of the current chart candle.

//    Box text is right-aligned and vertically centered, keeping the 30M tag at the

//    current right edge on supported intraday charts up to and including 30M.

// 6. DEFAULT lifecycle mode:

//      - One 30M close beyond an FVG does NOT convert it.

//      - Two CONSECUTIVE confirmed 30M closes beyond the far boundary convert it

//        into the opposite-direction IFVG.

//      - After conversion, the configured number of consecutive confirmed 30M closes back through the opposite

//        boundary invalidates/removes that IFVG.

// 7. PERSISTENT CURRENT-PRICE mode (default lifecycle switch OFF):

//      - Original 30M gaps are never permanently invalidated inside lookback.

//      - Current price on native side => original FVG.

//      - Current price beyond opposite side => opposite-direction IFVG.

//      - If current price is inside the zone, the most recently resolved state remains.

// 8. Session lookback: Today only through Today + 4 prior exchange sessions (maximum 5 sessions total).

//==============================================================================

//------------------------------------------------------------------------------

// 01. Master controls

//------------------------------------------------------------------------------

m30_groupMaster = "30M • 01. Master Controls"

m30_enableIndicator = input.bool(true, "Enable indicator", group=m30_groupMaster)




m30_showZoneText = input.bool(true, "Show timeframe tag", group=m30_groupMaster)

m30_timeframeTag = input.string("30", "Custom timeframe tag", tooltip="Text shown inside every visible 30-minute FVG / IFVG box. Example: 30, 30M, M30. Only this tag is displayed on the box; direction and FVG / IFVG wording are intentionally omitted.", group=m30_groupMaster)

m30_sessionLookback = input.string(

     "Today only",

     "30M FVG / IFVG session lookback",

     options=["Today only", "Today + 1 prior session", "Today + 2 prior sessions", "Today + 3 prior sessions", "Today + 4 prior sessions"],

     tooltip="Controls only the 30M inventory. 'Today only' keeps zones formed in the current exchange trading session. The remaining choices include the current session plus 1-4 prior exchange sessions, for a maximum of 5 sessions total. Weekends/non-trading days are skipped by using the symbol's Daily session boundaries.",

     group=m30_groupMaster)

int m30_priorSessionOffset = switch m30_sessionLookback
    "Today only" => 0
    "Today + 1 prior session" => 1
    "Today + 2 prior sessions" => 2
    "Today + 3 prior sessions" => 3
    => 4

m30_projectionAnchor = input.string(

     "First FVG candle",

     "Zone begins from",

     options=["First FVG candle", "FVG end candle"],

     group=m30_groupMaster)

//------------------------------------------------------------------------------

// 02. Classification / lifecycle

//------------------------------------------------------------------------------

m30_groupLifecycle = "30M • 02. Classification / Lifecycle"

m30_useConfirmedLifecycle = input.bool(

     true,

     "Require 2 confirmed 30M closes for FVG -> IFVG",

     tooltip="ON (default): one opposite 30M close is ignored; two consecutive confirmed 30M closes beyond the FVG convert it to an IFVG. IFVG invalidation is controlled separately below.\n\nOFF: never permanently invalidate an original gap inside the selected lookback. Classify each zone from current market price: native side = FVG, opposite side = IFVG.",

     group=m30_groupLifecycle)

m30_invalidateIfvgs = input.bool(

     true,

     "Enable confirmed 30M IFVG invalidation",

     tooltip="ON: confirmed 30M closes can invalidate IFVGs using the bullish/bearish close-count settings below. OFF: once a zone becomes an IFVG in confirmed lifecycle mode, it remains on the chart until it falls outside the lookback or you hide it with visibility controls.",

     group=m30_groupLifecycle)

m30_bullIfvgInvalidationCloses = input.int(

     1,

     "Bullish IFVG: 30M closes below zone to invalidate",

     options=[1, 2, 3, 4, 5],

     tooltip="Number of CONSECUTIVE confirmed 30M closes below the bullish IFVG lower boundary required to remove the bullish IFVG.",

     group=m30_groupLifecycle)

m30_bearIfvgInvalidationCloses = input.int(

     1,

     "Bearish IFVG: 30M closes above zone to invalidate",

     options=[1, 2, 3, 4, 5],

     tooltip="Number of CONSECUTIVE confirmed 30M closes above the bearish IFVG upper boundary required to remove the bearish IFVG.",

     group=m30_groupLifecycle)

//------------------------------------------------------------------------------

// 03. 30M inventory / minimum size

//------------------------------------------------------------------------------

m30_groupInventory = "30M • 03. 30M Inventory / Minimum Size"

m30_minGap30M = input.float(

     0.0,

     "30M: minimum FVG size, points",

     minval=0.0,

     step=0.25,

     group=m30_groupInventory)

//------------------------------------------------------------------------------

// 04. Individual 30M controls

//------------------------------------------------------------------------------

m30_group30M = "30M • 04. 30M Individual Controls"

m30_enable30MBullFvg = input.bool(true, "30M Bullish FVG — plot + alerts", group=m30_group30M)

m30_enable30MBearFvg = input.bool(true, "30M Bearish FVG — plot + alerts", group=m30_group30M)

m30_enable30MBullIfvg = input.bool(true, "30M Bullish IFVG — plot + alerts", group=m30_group30M)

m30_enable30MBearIfvg = input.bool(true, "30M Bearish IFVG — plot + alerts", group=m30_group30M)

//------------------------------------------------------------------------------

// 05. Visual customization — same colors as original indicator

//------------------------------------------------------------------------------

m30_groupVisual = "30M • 05. Visual Customization"

m30_bullishBaseColor = input.color(color.rgb(0, 139, 170), "Bullish cyan-blue", group=m30_groupVisual)

m30_bearishBaseColor = input.color(color.rgb(132, 78, 170), "Bearish purple", group=m30_groupVisual)

m30_fvgFillTransparency = input.int(84, "FVG fill transparency", minval=0, maxval=100, group=m30_groupVisual)

m30_ifvgFillTransparency = input.int(87, "IFVG fill transparency", minval=0, maxval=100, group=m30_groupVisual)

m30_borderTransparency = input.int(18, "Border transparency", minval=0, maxval=100, group=m30_groupVisual)

m30_boxBorderWidth = input.int(1, "Box border width", minval=0, maxval=4, group=m30_groupVisual)

m30_zoneTextColor = input.color(color.new(color.white, 15), "Zone text color", group=m30_groupVisual)

//------------------------------------------------------------------------------

// Routing and effective controls

//------------------------------------------------------------------------------

int m30_chartTimeframeSeconds = timeframe.in_seconds()

m30_isThirtyMinuteChart = timeframe.isintraday and m30_chartTimeframeSeconds == 30 * 60

m30_isLowerIntradayChart = timeframe.isintraday and m30_chartTimeframeSeconds < 30 * 60

m30_supportedChart = m30_isThirtyMinuteChart or m30_isLowerIntradayChart

m30_canRun = m30_enableIndicator and m30_supportedChart

m30_bullFvgFill = color.new(m30_bullishBaseColor, m30_fvgFillTransparency)

m30_bearFvgFill = color.new(m30_bearishBaseColor, m30_fvgFillTransparency)

m30_bullIfvgFill = color.new(m30_bullishBaseColor, m30_ifvgFillTransparency)

m30_bearIfvgFill = color.new(m30_bearishBaseColor, m30_ifvgFillTransparency)

m30_bullBorder = color.new(m30_bullishBaseColor, m30_borderTransparency)

m30_bearBorder = color.new(m30_bearishBaseColor, m30_borderTransparency)


// Kind codes:

//   +1 = Bullish FVG

//   -1 = Bearish FVG

//   +2 = Bullish IFVG

//   -2 = Bearish IFVG

//------------------------------------------------------------------------------

// Zone object

//------------------------------------------------------------------------------

type m30_Zone

    float lo

    float hi

    int leftTime

    int originTime

    int originDirection

    int kind

    int oppositeCloseCount

    box bx

    bool touched

    int armedAfterBar

    // Permanent original-FVG history, independent of alert re-arming.
    int formationAfterBar

    bool originalFvgRetraced

m30_f_zone_text(int kind) =>

    m30_showZoneText ? m30_timeframeTag : ""

m30_f_kind_visible(int kind) =>

    bool master = m30_canRun and m30_enable30MMaster

    kind == 1 ? master and (global_enableAllBullish and m30_enableAllBullish) and m30_enable30MBullFvg :

     kind == -1 ? master and (global_enableAllBearish and m30_enableAllBearish) and m30_enable30MBearFvg :

     kind == 2 ? master and (global_enableAllBullish and m30_enableAllBullish) and m30_enable30MBullIfvg :

     master and (global_enableAllBearish and m30_enableAllBearish) and m30_enable30MBearIfvg

m30_f_kind_fill(int kind) =>

    kind == 1 ? m30_bullFvgFill :

     kind == -1 ? m30_bearFvgFill :

     kind == 2 ? m30_bullIfvgFill : m30_bearIfvgFill

m30_f_kind_border(int kind) =>

    kind > 0 ? m30_bullBorder : m30_bearBorder

m30_f_kind_style(int kind) =>

    math.abs(kind) == 1 ? line.style_solid : line.style_dashed

m30_f_fixed_left(int firstCandleTime, int endCandleTime) =>

    m30_projectionAnchor == "First FVG candle" ? firstCandleTime : endCandleTime

m30_f_make_box(

     int leftTime,

     int rightTime,

     float lo,

     float hi,

     int kind) =>

    box.new(

         left=leftTime,

         top=hi,

         right=rightTime,

         bottom=lo,

         xloc=xloc.bar_time,

         extend=extend.none,

         bgcolor=m30_f_kind_fill(kind),

         border_color=m30_f_kind_border(kind),

         border_width=m30_boxBorderWidth,

         border_style=m30_f_kind_style(kind),

         text=m30_f_zone_text(kind),

         text_color=m30_zoneTextColor,

         text_size=size.tiny,

         text_halign=text.align_right,

         text_valign=text.align_center)

m30_f_delete_box(box boxId) =>

    if not na(boxId)

        box.delete(boxId)

m30_f_new_zone(

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int currentRightTime) =>

    int leftTime = m30_f_fixed_left(firstCandleTime, endCandleTime)

    int initialKind = originDirection

    box boxId = na

    if m30_f_kind_visible(initialKind)

        boxId := m30_f_make_box(leftTime, currentRightTime, lo, hi, initialKind)

    m30_Zone.new(

         lo,

         hi,

         leftTime,

         originTime,

         originDirection,

         initialKind,

         0,

         boxId,

         false,

         armedAfterBar,

         armedAfterBar,

         false)

m30_f_add_zone(

     array<m30_Zone> zones,

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int currentRightTime) =>

    m30_Zone z = m30_f_new_zone(

         lo,

         hi,

         firstCandleTime,

         endCandleTime,

         originTime,

         originDirection,

         armedAfterBar,

         currentRightTime)

    array.push(zones, z)

m30_f_prune_lookback(array<m30_Zone> zones, int cutoffTime) =>

    int i = array.size(zones) - 1

    while i >= 0

        m30_Zone z = array.get(zones, i)

        if z.originTime < cutoffTime

            m30_f_delete_box(z.bx)

            array.remove(zones, i)

        i -= 1

// Apply visibility, style, text, and — critically — the dynamic right edge.

m30_f_sync_zones(array<m30_Zone> zones, int currentRightTime) =>

    int i = 0

    while i < array.size(zones)

        m30_Zone z = array.get(zones, i)

        // Ignore the formation candle; remember every later touch, even if hidden.
        if not z.originalFvgRetraced and bar_index > z.formationAfterBar
            bool reachedOriginalGap = z.originDirection == 1 ? low <= z.hi : high >= z.lo
            if reachedOriginalGap
                z.originalFvgRetraced := true

        bool visible = m30_f_kind_visible(z.kind) and (not onlyUnmitigatedFvgs or (math.abs(z.kind) == 1 and not z.originalFvgRetraced))

        if visible

            if na(z.bx)

                z.bx := m30_f_make_box(z.leftTime, currentRightTime, z.lo, z.hi, z.kind)

            else

                box.set_right(z.bx, currentRightTime)

                box.set_bgcolor(z.bx, m30_f_kind_fill(z.kind))

                box.set_border_color(z.bx, m30_f_kind_border(z.kind))

                box.set_border_width(z.bx, m30_boxBorderWidth)

                box.set_border_style(z.bx, m30_f_kind_style(z.kind))

                box.set_text(z.bx, m30_f_zone_text(z.kind))

                box.set_text_color(z.bx, m30_zoneTextColor)

        else

            m30_f_delete_box(z.bx)

            z.bx := na

        array.set(zones, i, z)

        i += 1

//------------------------------------------------------------------------------

// DEFAULT confirmed lifecycle

//------------------------------------------------------------------------------

// One opposite 30M close does not change an FVG.

// Two consecutive opposite 30M closes convert FVG -> IFVG.

// IFVG invalidation is independently configurable from 1 to 5 consecutive 30M closes.

// When IFVG invalidation is OFF, converted IFVGs remain until lookback pruning or visibility hiding.

m30_f_process_confirmed_lifecycle(

     array<m30_Zone> zones,

     float sourceClose,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = array.size(zones) - 1

    while i >= 0

        m30_Zone z = array.get(zones, i)

        bool removeZone = false

        if z.kind == 1

            // Bullish FVG -> Bearish IFVG after TWO consecutive confirmed 30M closes below lo.

            if sourceClose < z.lo

                z.oppositeCloseCount += 1

                if z.oppositeCloseCount >= 2

                    z.kind := -2

                    z.oppositeCloseCount := 0

                    z.touched := false

                    z.armedAfterBar := currentChartBar

                    newBearIfvg := true

            else

                z.oppositeCloseCount := 0

        else if z.kind == -1

            // Bearish FVG -> Bullish IFVG after TWO consecutive confirmed 30M closes above hi.

            if sourceClose > z.hi

                z.oppositeCloseCount += 1

                if z.oppositeCloseCount >= 2

                    z.kind := 2

                    z.oppositeCloseCount := 0

                    z.touched := false

                    z.armedAfterBar := currentChartBar

                    newBullIfvg := true

            else

                z.oppositeCloseCount := 0

        else if z.kind == 2

            // Bullish IFVG: optional invalidation after configured consecutive 30M closes below lo.

            if m30_invalidateIfvgs

                if sourceClose < z.lo

                    z.oppositeCloseCount += 1

                    if z.oppositeCloseCount >= m30_bullIfvgInvalidationCloses

                        removeZone := true

                else

                    z.oppositeCloseCount := 0

            else

                z.oppositeCloseCount := 0

        else if z.kind == -2

            // Bearish IFVG: optional invalidation after configured consecutive 30M closes above hi.

            if m30_invalidateIfvgs

                if sourceClose > z.hi

                    z.oppositeCloseCount += 1

                    if z.oppositeCloseCount >= m30_bearIfvgInvalidationCloses

                        removeZone := true

                else

                    z.oppositeCloseCount := 0

            else

                z.oppositeCloseCount := 0

        if removeZone

            m30_f_delete_box(z.bx)

            array.remove(zones, i)

        else

            array.set(zones, i, z)

        i -= 1

    [newBullIfvg, newBearIfvg]

//------------------------------------------------------------------------------

// PERSISTENT current-price classification

//------------------------------------------------------------------------------

// This mode never permanently invalidates an original FVG inside lookback.

// Classification is based on current market price relative to original geometry.

m30_f_process_current_price_classification(

     array<m30_Zone> zones,

     float currentPrice,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = 0

    while i < array.size(zones)

        m30_Zone z = array.get(zones, i)

        int oldKind = z.kind

        int resolvedKind = oldKind

        if z.originDirection == -1

            // Original bearish FVG:

            // below zone = Bearish FVG; above zone = Bullish IFVG.

            if currentPrice > z.hi

                resolvedKind := 2

            else if currentPrice < z.lo

                resolvedKind := -1

        else

            // Original bullish FVG:

            // above zone = Bullish FVG; below zone = Bearish IFVG.

            if currentPrice < z.lo

                resolvedKind := -2

            else if currentPrice > z.hi

                resolvedKind := 1

        if resolvedKind != oldKind

            z.kind := resolvedKind

            z.oppositeCloseCount := 0

            z.touched := false

            z.armedAfterBar := currentChartBar

            if resolvedKind == 2

                newBullIfvg := true

            else if resolvedKind == -2

                newBearIfvg := true

        array.set(zones, i, z)

        i += 1

    [newBullIfvg, newBearIfvg]

// direction: +1 bullish state; -1 bearish state.

m30_f_first_touch_kind(

     array<m30_Zone> zones,

     int targetKind,

     int direction,

     float chartHigh,

     float chartLow,

     int currentChartBar) =>

    bool pulse = false

    int i = 0

    while i < array.size(zones)

        m30_Zone z = array.get(zones, i)

        if z.kind == targetKind

            bool eligible = currentChartBar > z.armedAfterBar

            bool reachedBoundary = direction == 1 ? chartLow <= z.hi : chartHigh >= z.lo

            if eligible and not z.touched and reachedBoundary

                z.touched := true

                array.set(zones, i, z)

                pulse := true

        i += 1

    pulse

//------------------------------------------------------------------------------

// 30M source data

//------------------------------------------------------------------------------

// On a 30M chart, process the current 30M candle only once it closes.

bool m30_hasEnoughThirtyMinuteChartBars = bar_index >= 2

// On lower intraday charts, request the PREVIOUS fully closed 30M candle with a one-bar offset.

// This prevents an unfinished 30M candle from being treated as a confirmed close.

[m30_t30TimeClosed, m30_t30TimeCloseClosed, m30_t30FirstTimeClosed,

 m30_t30HighClosed, m30_t30LowClosed, m30_t30CloseClosed,

 m30_t30HighTwoBackClosed, m30_t30LowTwoBackClosed] = request.security(

     syminfo.tickerid,

     "30",

     [time[1], time_close[1], time[3], high[1], low[1], close[1], high[3], low[3]],

     gaps=barmerge.gaps_off,

     lookahead=barmerge.lookahead_on)

int m30_t30Time = m30_isThirtyMinuteChart ? time : m30_t30TimeClosed

int m30_t30TimeClose = m30_isThirtyMinuteChart ? time_close : m30_t30TimeCloseClosed

int m30_t30FirstTime = m30_isThirtyMinuteChart ? (m30_hasEnoughThirtyMinuteChartBars ? time[2] : na) : m30_t30FirstTimeClosed

float m30_t30High = m30_isThirtyMinuteChart ? high : m30_t30HighClosed

float m30_t30Low = m30_isThirtyMinuteChart ? low : m30_t30LowClosed

float m30_t30Close = m30_isThirtyMinuteChart ? close : m30_t30CloseClosed

float m30_t30HighTwoBack = m30_isThirtyMinuteChart ? (m30_hasEnoughThirtyMinuteChartBars ? high[2] : na) : m30_t30HighTwoBackClosed

float m30_t30LowTwoBack = m30_isThirtyMinuteChart ? (m30_hasEnoughThirtyMinuteChartBars ? low[2] : na) : m30_t30LowTwoBackClosed

bool m30_sourceClosed30M = m30_canRun and (

     (m30_isThirtyMinuteChart and m30_hasEnoughThirtyMinuteChartBars and barstate.isconfirmed) or

     (m30_isLowerIntradayChart and barstate.isnew and timeframe.change("30") and not na(m30_t30TimeClosed)))

// On lower intraday charts, the previous 30M candle was already confirmed before the

// first chart bar of the new 30-minute cycle. That first bar can therefore interact with it.

int m30_armedAfterBar30M = m30_isThirtyMinuteChart ? bar_index : bar_index - 1

// Right edge is ALWAYS the opening time of the current chart candle.

int m30_currentZoneRightTime = time

//------------------------------------------------------------------------------

// Inventory

//------------------------------------------------------------------------------

var array<m30_Zone> m30_zones30M = array.new<m30_Zone>()

//------------------------------------------------------------------------------

// Lookback pruning

//------------------------------------------------------------------------------

int m30_currentCutoffTime = request.security(
     syminfo.tickerid,
     "D",
     time[m30_priorSessionOffset],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

m30_f_prune_lookback(m30_zones30M, m30_currentCutoffTime)

//------------------------------------------------------------------------------

// Process confirmed 30M closes and detect new 30M FVGs

//------------------------------------------------------------------------------

bool m30_n30MBullFvgRaw = false

bool m30_n30MBearFvgRaw = false

bool m30_n30MBullIfvgRaw = false

bool m30_n30MBearIfvgRaw = false

if m30_sourceClosed30M

    // First update the lifecycle of zones that already existed before this 30M close.

    if m30_useConfirmedLifecycle

        [bullIfvgPulse, bearIfvgPulse] = m30_f_process_confirmed_lifecycle(

             m30_zones30M,

             m30_t30Close,

             m30_armedAfterBar30M)

        m30_n30MBullIfvgRaw := bullIfvgPulse

        m30_n30MBearIfvgRaw := bearIfvgPulse

    // Strict three-candle FVG geometry. Adjacent close/open gaps are irrelevant.

    bool bullishGap = not na(m30_t30HighTwoBack) and m30_t30Low > m30_t30HighTwoBack

    bool bearishGap = not na(m30_t30LowTwoBack) and m30_t30High < m30_t30LowTwoBack

    float bullishGapSize = bullishGap ? m30_t30Low - m30_t30HighTwoBack : 0.0

    float bearishGapSize = bearishGap ? m30_t30LowTwoBack - m30_t30High : 0.0

    if bullishGap and bullishGapSize >= m30_minGap30M

        m30_f_add_zone(

             m30_zones30M,

             m30_t30HighTwoBack,

             m30_t30Low,

             m30_t30FirstTime,

             m30_t30Time,

             m30_t30Time,

             1,

             m30_armedAfterBar30M,

             m30_currentZoneRightTime)

        m30_n30MBullFvgRaw := true

    if bearishGap and bearishGapSize >= m30_minGap30M

        m30_f_add_zone(

             m30_zones30M,

             m30_t30High,

             m30_t30LowTwoBack,

             m30_t30FirstTime,

             m30_t30Time,

             m30_t30Time,

             -1,

             m30_armedAfterBar30M,

             m30_currentZoneRightTime)

        m30_n30MBearFvgRaw := true

// In persistent mode, classification follows CURRENT MARKET PRICE on every chart bar,

// including the live/open candle. This is deliberately independent of 30M closes.

if m30_canRun and not m30_useConfirmedLifecycle

    [bullIfvgDynamicPulse, bearIfvgDynamicPulse] = m30_f_process_current_price_classification(

         m30_zones30M,

         close,

         bar_index)

    m30_n30MBullIfvgRaw := m30_n30MBullIfvgRaw or bullIfvgDynamicPulse

    m30_n30MBearIfvgRaw := m30_n30MBearIfvgRaw or bearIfvgDynamicPulse

// Re-prune after formation so the selected 30M session lookback remains authoritative.

m30_f_prune_lookback(m30_zones30M, m30_currentCutoffTime)

//------------------------------------------------------------------------------

// Dynamic right-edge + text/style synchronization

//------------------------------------------------------------------------------

// Every box ends at the OPEN of whatever chart candle is currently active.

// Because text_halign = text.align_right, the 30M FVG/IFVG tag remains visible

// at the right edge while vertically centered inside the zone.

m30_f_sync_zones(m30_zones30M, m30_currentZoneRightTime)

//------------------------------------------------------------------------------

// First-retest pulses by CURRENT classification

//------------------------------------------------------------------------------

m30_t30MBullFvgRaw = m30_canRun ? m30_f_first_touch_kind(m30_zones30M, 1, 1, high, low, bar_index) : false

m30_t30MBearFvgRaw = m30_canRun ? m30_f_first_touch_kind(m30_zones30M, -1, -1, high, low, bar_index) : false

m30_t30MBullIfvgRaw = m30_canRun ? m30_f_first_touch_kind(m30_zones30M, 2, 1, high, low, bar_index) : false

m30_t30MBearIfvgRaw = m30_canRun ? m30_f_first_touch_kind(m30_zones30M, -2, -1, high, low, bar_index) : false

//------------------------------------------------------------------------------

// Effective alert pulses

//------------------------------------------------------------------------------

m30_n30MBullFvg = m30_canRun and m30_enable30MMaster and (global_enableAllBullish and m30_enableAllBullish) and m30_enable30MBullFvg and m30_n30MBullFvgRaw

m30_n30MBearFvg = m30_canRun and m30_enable30MMaster and (global_enableAllBearish and m30_enableAllBearish) and m30_enable30MBearFvg and m30_n30MBearFvgRaw

m30_n30MBullIfvg = m30_canRun and m30_enable30MMaster and (global_enableAllBullish and m30_enableAllBullish) and m30_enable30MBullIfvg and m30_n30MBullIfvgRaw

m30_n30MBearIfvg = m30_canRun and m30_enable30MMaster and (global_enableAllBearish and m30_enableAllBearish) and m30_enable30MBearIfvg and m30_n30MBearIfvgRaw

m30_t30MBullFvg = m30_canRun and m30_enable30MMaster and (global_enableAllBullish and m30_enableAllBullish) and m30_enable30MBullFvg and m30_t30MBullFvgRaw

m30_t30MBearFvg = m30_canRun and m30_enable30MMaster and (global_enableAllBearish and m30_enableAllBearish) and m30_enable30MBearFvg and m30_t30MBearFvgRaw

m30_t30MBullIfvg = m30_canRun and m30_enable30MMaster and (global_enableAllBullish and m30_enableAllBullish) and m30_enable30MBullIfvg and m30_t30MBullIfvgRaw

m30_t30MBearIfvg = m30_canRun and m30_enable30MMaster and (global_enableAllBearish and m30_enableAllBearish) and m30_enable30MBearIfvg and m30_t30MBearIfvgRaw

//==============================================================================

// 30M FORMATION / CLASSIFICATION ALERTS

//==============================================================================

alertcondition(m30_n30MBullFvg, title="30M Bullish FVG Formed", message="{{ticker}}: 30M bullish FVG formed.")

alertcondition(m30_n30MBearFvg, title="30M Bearish FVG Formed", message="{{ticker}}: 30M bearish FVG formed.")

alertcondition(m30_n30MBullIfvg, title="30M Bullish IFVG Formed", message="{{ticker}}: 30M zone classified as bullish IFVG.")

alertcondition(m30_n30MBearIfvg, title="30M Bearish IFVG Formed", message="{{ticker}}: 30M zone classified as bearish IFVG.")

//==============================================================================

// 30M FIRST-RETEST ALERTS

//==============================================================================

alertcondition(m30_t30MBullFvg, title="30M Bullish FVG First Retest", message="{{ticker}}: price reached a 30M bullish FVG.")

alertcondition(m30_t30MBearFvg, title="30M Bearish FVG First Retest", message="{{ticker}}: price reached a 30M bearish FVG.")

alertcondition(m30_t30MBullIfvg, title="30M Bullish IFVG First Retest", message="{{ticker}}: price reached a 30M bullish IFVG.")

alertcondition(m30_t30MBearIfvg, title="30M Bearish IFVG First Retest", message="{{ticker}}: price reached a 30M bearish IFVG.")

//==============================================================================

// DAILY FVG / IFVG INVENTORY — V2.0

//------------------------------------------------------------------------------

// 1. Daily source timeframe only. Works on intraday and Daily charts.

// 2. Bullish FVG = third Daily candle LOW > first Daily candle HIGH.

//    Zone = first candle HIGH -> third candle LOW.

// 3. Bearish FVG = third Daily candle HIGH < first Daily candle LOW.

//    Zone = third candle HIGH -> first candle LOW.

// 4. Adjacent close/open gaps are ignored. Only candle 1 vs candle 3 geometry matters.

// 5. Every visible zone dynamically extends to the OPEN of the current chart candle.

//    Box text is right-aligned and vertically centered, keeping the Daily tag at the

//    current right edge on 1M, 2M, 5M, 15M, 30M, 1H, 4H, Daily, etc.

// 6. DEFAULT lifecycle mode:

//      - One Daily close beyond an FVG does NOT convert it.

//      - Two CONSECUTIVE confirmed Daily closes beyond the far boundary convert it

//        into the opposite-direction IFVG.

//      - After conversion, one confirmed Daily close back through the opposite

//        boundary invalidates/removes that IFVG.

// 7. PERSISTENT CURRENT-PRICE mode (default lifecycle switch OFF):

//      - Original Daily gaps are never permanently invalidated inside lookback.

//      - Current price on native side => original FVG.

//      - Current price beyond opposite side => opposite-direction IFVG.

//      - If current price is inside the zone, the most recently resolved state remains.

// 8. Calendar-day lookback: 5 / 10 / 15 / 30 / 90 / 180 / 365.

//==============================================================================

//------------------------------------------------------------------------------

// 01. Master controls

//------------------------------------------------------------------------------

d_groupMaster = "Daily • 01. Master Controls"

d_enableIndicator = input.bool(true, "Enable indicator", group=d_groupMaster)




d_showZoneText = input.bool(true, "Show timeframe tag", group=d_groupMaster)

d_timeframeTag = input.string("D", "Custom timeframe tag", tooltip="Text shown inside every visible Daily FVG / IFVG box. Example: D, 1D, Daily. Only this tag is displayed on the box; direction and FVG / IFVG wording are intentionally omitted.", group=d_groupMaster)

d_lookbackDays = input.int(

     30,

     "Daily FVG / IFVG lookback, calendar days",

     options=[5, 10, 15, 30, 90, 180, 365],

     group=d_groupMaster)

d_projectionAnchor = input.string(

     "First FVG candle",

     "Zone begins from",

     options=["First FVG candle", "FVG end candle"],

     group=d_groupMaster)

//------------------------------------------------------------------------------

// 02. Classification / lifecycle

//------------------------------------------------------------------------------

d_groupLifecycle = "Daily • 02. Classification / Lifecycle"

d_useConfirmedLifecycle = input.bool(

     true,

     "Require 2 Daily closes for FVG -> IFVG + invalidate reverse IFVG",

     tooltip="ON (default): one opposite Daily close is ignored; two consecutive confirmed Daily closes beyond the FVG convert it to an IFVG. A later confirmed Daily close back through the opposite boundary invalidates the IFVG.\n\nOFF: never permanently invalidate an original gap inside the selected lookback. Classify each zone from current market price: native side = FVG, opposite side = IFVG.",

     group=d_groupLifecycle)

//------------------------------------------------------------------------------

// 03. Daily inventory / minimum size

//------------------------------------------------------------------------------

d_groupInventory = "Daily • 03. Daily Inventory / Minimum Size"

d_minGapD = input.float(

     0.0,

     "Daily: minimum FVG size, points",

     minval=0.0,

     step=0.25,

     group=d_groupInventory)

//------------------------------------------------------------------------------

// 04. Individual Daily controls

//------------------------------------------------------------------------------

d_groupDaily = "Daily • 04. Daily Individual Controls"

d_enableDBullFvg = input.bool(true, "Daily Bullish FVG — plot + alerts", group=d_groupDaily)

d_enableDBearFvg = input.bool(true, "Daily Bearish FVG — plot + alerts", group=d_groupDaily)

d_enableDBullIfvg = input.bool(true, "Daily Bullish IFVG — plot + alerts", group=d_groupDaily)

d_enableDBearIfvg = input.bool(true, "Daily Bearish IFVG — plot + alerts", group=d_groupDaily)

//------------------------------------------------------------------------------

// 05. Visual customization — same colors as original indicator

//------------------------------------------------------------------------------

d_groupVisual = "Daily • 05. Visual Customization"

d_bullishBaseColor = input.color(color.rgb(0, 139, 170), "Bullish cyan-blue", group=d_groupVisual)

d_bearishBaseColor = input.color(color.rgb(132, 78, 170), "Bearish purple", group=d_groupVisual)

d_fvgFillTransparency = input.int(84, "FVG fill transparency", minval=0, maxval=100, group=d_groupVisual)

d_ifvgFillTransparency = input.int(87, "IFVG fill transparency", minval=0, maxval=100, group=d_groupVisual)

d_borderTransparency = input.int(18, "Border transparency", minval=0, maxval=100, group=d_groupVisual)

d_boxBorderWidth = input.int(1, "Box border width", minval=0, maxval=4, group=d_groupVisual)

d_zoneTextColor = input.color(color.new(color.white, 15), "Zone text color", group=d_groupVisual)

//------------------------------------------------------------------------------

// Routing and effective controls

//------------------------------------------------------------------------------

d_isDailyChart = timeframe.isdaily

d_isIntradayChart = timeframe.isintraday

d_supportedChart = d_isDailyChart or d_isIntradayChart

d_canRun = d_enableIndicator and d_supportedChart

d_bullFvgFill = color.new(d_bullishBaseColor, d_fvgFillTransparency)

d_bearFvgFill = color.new(d_bearishBaseColor, d_fvgFillTransparency)

d_bullIfvgFill = color.new(d_bullishBaseColor, d_ifvgFillTransparency)

d_bearIfvgFill = color.new(d_bearishBaseColor, d_ifvgFillTransparency)

d_bullBorder = color.new(d_bullishBaseColor, d_borderTransparency)

d_bearBorder = color.new(d_bearishBaseColor, d_borderTransparency)

int d_DAY_MS = 24 * 60 * 60 * 1000

int d_lookbackMs = d_lookbackDays * d_DAY_MS

// Kind codes:

//   +1 = Bullish FVG

//   -1 = Bearish FVG

//   +2 = Bullish IFVG

//   -2 = Bearish IFVG

//------------------------------------------------------------------------------

// Zone object

//------------------------------------------------------------------------------

type d_Zone

    float lo

    float hi

    int leftTime

    int originTime

    int originDirection

    int kind

    int oppositeCloseCount

    box bx

    bool touched

    int armedAfterBar

    // Permanent original-FVG history, independent of alert re-arming.
    int formationAfterBar

    bool originalFvgRetraced

d_f_zone_text(int kind) =>

    d_showZoneText ? d_timeframeTag : ""

d_f_kind_visible(int kind) =>

    bool master = d_canRun and d_enableDailyMaster

    kind == 1 ? master and (global_enableAllBullish and d_enableAllBullish) and d_enableDBullFvg :

     kind == -1 ? master and (global_enableAllBearish and d_enableAllBearish) and d_enableDBearFvg :

     kind == 2 ? master and (global_enableAllBullish and d_enableAllBullish) and d_enableDBullIfvg :

     master and (global_enableAllBearish and d_enableAllBearish) and d_enableDBearIfvg

d_f_kind_fill(int kind) =>

    kind == 1 ? d_bullFvgFill :

     kind == -1 ? d_bearFvgFill :

     kind == 2 ? d_bullIfvgFill : d_bearIfvgFill

d_f_kind_border(int kind) =>

    kind > 0 ? d_bullBorder : d_bearBorder

d_f_kind_style(int kind) =>

    math.abs(kind) == 1 ? line.style_solid : line.style_dashed

d_f_fixed_left(int firstCandleTime, int endCandleTime) =>

    d_projectionAnchor == "First FVG candle" ? firstCandleTime : endCandleTime

d_f_make_box(

     int leftTime,

     int rightTime,

     float lo,

     float hi,

     int kind) =>

    box.new(

         left=leftTime,

         top=hi,

         right=rightTime,

         bottom=lo,

         xloc=xloc.bar_time,

         extend=extend.none,

         bgcolor=d_f_kind_fill(kind),

         border_color=d_f_kind_border(kind),

         border_width=d_boxBorderWidth,

         border_style=d_f_kind_style(kind),

         text=d_f_zone_text(kind),

         text_color=d_zoneTextColor,

         text_size=size.tiny,

         text_halign=text.align_right,

         text_valign=text.align_center)

d_f_delete_box(box boxId) =>

    if not na(boxId)

        box.delete(boxId)

d_f_new_zone(

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int currentRightTime) =>

    int leftTime = d_f_fixed_left(firstCandleTime, endCandleTime)

    int initialKind = originDirection

    box boxId = na

    if d_f_kind_visible(initialKind)

        boxId := d_f_make_box(leftTime, currentRightTime, lo, hi, initialKind)

    d_Zone.new(

         lo,

         hi,

         leftTime,

         originTime,

         originDirection,

         initialKind,

         0,

         boxId,

         false,

         armedAfterBar,

         armedAfterBar,

         false)

d_f_add_zone(

     array<d_Zone> zones,

     float lo,

     float hi,

     int firstCandleTime,

     int endCandleTime,

     int originTime,

     int originDirection,

     int armedAfterBar,

     int currentRightTime) =>

    d_Zone z = d_f_new_zone(

         lo,

         hi,

         firstCandleTime,

         endCandleTime,

         originTime,

         originDirection,

         armedAfterBar,

         currentRightTime)

    array.push(zones, z)

d_f_prune_lookback(array<d_Zone> zones, int cutoffTime) =>

    int i = array.size(zones) - 1

    while i >= 0

        d_Zone z = array.get(zones, i)

        if z.originTime < cutoffTime

            d_f_delete_box(z.bx)

            array.remove(zones, i)

        i -= 1

// Apply visibility, style, text, and — critically — the dynamic right edge.

d_f_sync_zones(array<d_Zone> zones, int currentRightTime) =>

    int i = 0

    while i < array.size(zones)

        d_Zone z = array.get(zones, i)

        // Ignore the formation candle; remember every later touch, even if hidden.
        if not z.originalFvgRetraced and bar_index > z.formationAfterBar
            bool reachedOriginalGap = z.originDirection == 1 ? low <= z.hi : high >= z.lo
            if reachedOriginalGap
                z.originalFvgRetraced := true

        bool visible = d_f_kind_visible(z.kind) and (not onlyUnmitigatedFvgs or (math.abs(z.kind) == 1 and not z.originalFvgRetraced))

        if visible

            if na(z.bx)

                z.bx := d_f_make_box(z.leftTime, currentRightTime, z.lo, z.hi, z.kind)

            else

                box.set_right(z.bx, currentRightTime)

                box.set_bgcolor(z.bx, d_f_kind_fill(z.kind))

                box.set_border_color(z.bx, d_f_kind_border(z.kind))

                box.set_border_width(z.bx, d_boxBorderWidth)

                box.set_border_style(z.bx, d_f_kind_style(z.kind))

                box.set_text(z.bx, d_f_zone_text(z.kind))

                box.set_text_color(z.bx, d_zoneTextColor)

        else

            d_f_delete_box(z.bx)

            z.bx := na

        array.set(zones, i, z)

        i += 1

//------------------------------------------------------------------------------

// DEFAULT confirmed lifecycle

//------------------------------------------------------------------------------

// One opposite Daily close does not change an FVG.

// Two consecutive opposite Daily closes convert FVG -> IFVG.

// One confirmed reverse Daily close invalidates the IFVG.

d_f_process_confirmed_lifecycle(

     array<d_Zone> zones,

     float sourceClose,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = array.size(zones) - 1

    while i >= 0

        d_Zone z = array.get(zones, i)

        bool removeZone = false

        if z.kind == 1

            // Bullish FVG -> Bearish IFVG after TWO consecutive closes below lo.

            if sourceClose < z.lo

                z.oppositeCloseCount += 1

                if z.oppositeCloseCount >= 2

                    z.kind := -2

                    z.oppositeCloseCount := 0

                    z.touched := false

                    z.armedAfterBar := currentChartBar

                    newBearIfvg := true

            else

                z.oppositeCloseCount := 0

        else if z.kind == -1

            // Bearish FVG -> Bullish IFVG after TWO consecutive closes above hi.

            if sourceClose > z.hi

                z.oppositeCloseCount += 1

                if z.oppositeCloseCount >= 2

                    z.kind := 2

                    z.oppositeCloseCount := 0

                    z.touched := false

                    z.armedAfterBar := currentChartBar

                    newBullIfvg := true

            else

                z.oppositeCloseCount := 0

        else if z.kind == 2

            // Bullish IFVG invalidates on a confirmed Daily close back below lo.

            if sourceClose < z.lo

                removeZone := true

        else if z.kind == -2

            // Bearish IFVG invalidates on a confirmed Daily close back above hi.

            if sourceClose > z.hi

                removeZone := true

        if removeZone

            d_f_delete_box(z.bx)

            array.remove(zones, i)

        else

            array.set(zones, i, z)

        i -= 1

    [newBullIfvg, newBearIfvg]

//------------------------------------------------------------------------------

// PERSISTENT current-price classification

//------------------------------------------------------------------------------

// This mode never permanently invalidates an original FVG inside lookback.

// Classification is based on current market price relative to original geometry.

d_f_process_current_price_classification(

     array<d_Zone> zones,

     float currentPrice,

     int currentChartBar) =>

    bool newBullIfvg = false

    bool newBearIfvg = false

    int i = 0

    while i < array.size(zones)

        d_Zone z = array.get(zones, i)

        int oldKind = z.kind

        int resolvedKind = oldKind

        if z.originDirection == -1

            // Original bearish FVG:

            // below zone = Bearish FVG; above zone = Bullish IFVG.

            if currentPrice > z.hi

                resolvedKind := 2

            else if currentPrice < z.lo

                resolvedKind := -1

        else

            // Original bullish FVG:

            // above zone = Bullish FVG; below zone = Bearish IFVG.

            if currentPrice < z.lo

                resolvedKind := -2

            else if currentPrice > z.hi

                resolvedKind := 1

        if resolvedKind != oldKind

            z.kind := resolvedKind

            z.oppositeCloseCount := 0

            z.touched := false

            z.armedAfterBar := currentChartBar

            if resolvedKind == 2

                newBullIfvg := true

            else if resolvedKind == -2

                newBearIfvg := true

        array.set(zones, i, z)

        i += 1

    [newBullIfvg, newBearIfvg]

// direction: +1 bullish state; -1 bearish state.

d_f_first_touch_kind(

     array<d_Zone> zones,

     int targetKind,

     int direction,

     float chartHigh,

     float chartLow,

     int currentChartBar) =>

    bool pulse = false

    int i = 0

    while i < array.size(zones)

        d_Zone z = array.get(zones, i)

        if z.kind == targetKind

            bool eligible = currentChartBar > z.armedAfterBar

            bool reachedBoundary = direction == 1 ? chartLow <= z.hi : chartHigh >= z.lo

            if eligible and not z.touched and reachedBoundary

                z.touched := true

                array.set(zones, i, z)

                pulse := true

        i += 1

    pulse

//------------------------------------------------------------------------------

// Daily source data

//------------------------------------------------------------------------------

// Daily chart: process current Daily candle only once it closes.

bool d_hasEnoughDailyChartBars = bar_index >= 2

// Intraday charts: request PREVIOUS fully closed Daily candle with a one-bar offset.

// This prevents an unfinished Daily candle from being treated as a confirmed close.

[d_dTimeClosed, d_dTimeCloseClosed, d_dFirstTimeClosed,

 d_dHighClosed, d_dLowClosed, d_dCloseClosed,

 d_dHighTwoBackClosed, d_dLowTwoBackClosed] = request.security(

     syminfo.tickerid,

     "D",

     [time[1], time_close[1], time[3], high[1], low[1], close[1], high[3], low[3]],

     gaps=barmerge.gaps_off,

     lookahead=barmerge.lookahead_on)

int d_dTime = d_isDailyChart ? time : d_dTimeClosed

int d_dTimeClose = d_isDailyChart ? time_close : d_dTimeCloseClosed

int d_dFirstTime = d_isDailyChart ? (d_hasEnoughDailyChartBars ? time[2] : na) : d_dFirstTimeClosed

float d_dHigh = d_isDailyChart ? high : d_dHighClosed

float d_dLow = d_isDailyChart ? low : d_dLowClosed

float d_dClose = d_isDailyChart ? close : d_dCloseClosed

float d_dHighTwoBack = d_isDailyChart ? (d_hasEnoughDailyChartBars ? high[2] : na) : d_dHighTwoBackClosed

float d_dLowTwoBack = d_isDailyChart ? (d_hasEnoughDailyChartBars ? low[2] : na) : d_dLowTwoBackClosed

bool d_sourceClosedD = d_canRun and (

     (d_isDailyChart and d_hasEnoughDailyChartBars and barstate.isconfirmed) or

     (d_isIntradayChart and barstate.isnew and timeframe.change("D") and not na(d_dTimeClosed)))

// On intraday charts, the previous Daily candle was already confirmed before the

// first chart bar of the new day. That first bar can therefore interact with it.

int d_armedAfterBarD = d_isDailyChart ? bar_index : bar_index - 1

// Right edge is ALWAYS the opening time of the current chart candle.

int d_currentZoneRightTime = time

//------------------------------------------------------------------------------

// Inventory

//------------------------------------------------------------------------------

var array<d_Zone> d_dailyZones = array.new<d_Zone>()

//------------------------------------------------------------------------------

// Lookback pruning

//------------------------------------------------------------------------------

int d_currentCutoffTime = time - d_lookbackMs

d_f_prune_lookback(d_dailyZones, d_currentCutoffTime)

//------------------------------------------------------------------------------

// Process confirmed Daily closes and detect new Daily FVGs

//------------------------------------------------------------------------------

bool d_nDBullFvgRaw = false

bool d_nDBearFvgRaw = false

bool d_nDBullIfvgRaw = false

bool d_nDBearIfvgRaw = false

if d_sourceClosedD

    // First update the lifecycle of zones that already existed before this Daily close.

    if d_useConfirmedLifecycle

        [bullIfvgPulse, bearIfvgPulse] = d_f_process_confirmed_lifecycle(

             d_dailyZones,

             d_dClose,

             d_armedAfterBarD)

        d_nDBullIfvgRaw := bullIfvgPulse

        d_nDBearIfvgRaw := bearIfvgPulse

    // Strict three-candle FVG geometry. Adjacent close/open gaps are irrelevant.

    bool bullishGap = not na(d_dHighTwoBack) and d_dLow > d_dHighTwoBack

    bool bearishGap = not na(d_dLowTwoBack) and d_dHigh < d_dLowTwoBack

    float bullishGapSize = bullishGap ? d_dLow - d_dHighTwoBack : 0.0

    float bearishGapSize = bearishGap ? d_dLowTwoBack - d_dHigh : 0.0

    if bullishGap and bullishGapSize >= d_minGapD

        d_f_add_zone(

             d_dailyZones,

             d_dHighTwoBack,

             d_dLow,

             d_dFirstTime,

             d_dTime,

             d_dTime,

             1,

             d_armedAfterBarD,

             d_currentZoneRightTime)

        d_nDBullFvgRaw := true

    if bearishGap and bearishGapSize >= d_minGapD

        d_f_add_zone(

             d_dailyZones,

             d_dHigh,

             d_dLowTwoBack,

             d_dFirstTime,

             d_dTime,

             d_dTime,

             -1,

             d_armedAfterBarD,

             d_currentZoneRightTime)

        d_nDBearFvgRaw := true

// In persistent mode, classification follows CURRENT MARKET PRICE on every chart bar,

// including the live/open candle. This is deliberately independent of Daily closes.

if d_canRun and not d_useConfirmedLifecycle

    [bullIfvgDynamicPulse, bearIfvgDynamicPulse] = d_f_process_current_price_classification(

         d_dailyZones,

         close,

         bar_index)

    d_nDBullIfvgRaw := d_nDBullIfvgRaw or bullIfvgDynamicPulse

    d_nDBearIfvgRaw := d_nDBearIfvgRaw or bearIfvgDynamicPulse

// Re-prune after formation so selected lookback remains authoritative.

d_f_prune_lookback(d_dailyZones, d_currentCutoffTime)

//------------------------------------------------------------------------------

// Dynamic right-edge + text/style synchronization

//------------------------------------------------------------------------------

// Every box ends at the OPEN of whatever chart candle is currently active.

// Because text_halign = text.align_right, the Daily FVG/IFVG tag remains visible

// at the right edge while vertically centered inside the zone.

d_f_sync_zones(d_dailyZones, d_currentZoneRightTime)

//------------------------------------------------------------------------------

// First-retest pulses by CURRENT classification

//------------------------------------------------------------------------------

d_tDBullFvgRaw = d_canRun ? d_f_first_touch_kind(d_dailyZones, 1, 1, high, low, bar_index) : false

d_tDBearFvgRaw = d_canRun ? d_f_first_touch_kind(d_dailyZones, -1, -1, high, low, bar_index) : false

d_tDBullIfvgRaw = d_canRun ? d_f_first_touch_kind(d_dailyZones, 2, 1, high, low, bar_index) : false

d_tDBearIfvgRaw = d_canRun ? d_f_first_touch_kind(d_dailyZones, -2, -1, high, low, bar_index) : false

//------------------------------------------------------------------------------

// Effective alert pulses

//------------------------------------------------------------------------------

d_nDBullFvg = d_canRun and d_enableDailyMaster and (global_enableAllBullish and d_enableAllBullish) and d_enableDBullFvg and d_nDBullFvgRaw

d_nDBearFvg = d_canRun and d_enableDailyMaster and (global_enableAllBearish and d_enableAllBearish) and d_enableDBearFvg and d_nDBearFvgRaw

d_nDBullIfvg = d_canRun and d_enableDailyMaster and (global_enableAllBullish and d_enableAllBullish) and d_enableDBullIfvg and d_nDBullIfvgRaw

d_nDBearIfvg = d_canRun and d_enableDailyMaster and (global_enableAllBearish and d_enableAllBearish) and d_enableDBearIfvg and d_nDBearIfvgRaw

d_tDBullFvg = d_canRun and d_enableDailyMaster and (global_enableAllBullish and d_enableAllBullish) and d_enableDBullFvg and d_tDBullFvgRaw

d_tDBearFvg = d_canRun and d_enableDailyMaster and (global_enableAllBearish and d_enableAllBearish) and d_enableDBearFvg and d_tDBearFvgRaw

d_tDBullIfvg = d_canRun and d_enableDailyMaster and (global_enableAllBullish and d_enableAllBullish) and d_enableDBullIfvg and d_tDBullIfvgRaw

d_tDBearIfvg = d_canRun and d_enableDailyMaster and (global_enableAllBearish and d_enableAllBearish) and d_enableDBearIfvg and d_tDBearIfvgRaw

//==============================================================================

// DAILY FORMATION / CLASSIFICATION ALERTS

//==============================================================================

alertcondition(d_nDBullFvg, title="Daily Bullish FVG Formed", message="{{ticker}}: Daily bullish FVG formed.")

alertcondition(d_nDBearFvg, title="Daily Bearish FVG Formed", message="{{ticker}}: Daily bearish FVG formed.")

alertcondition(d_nDBullIfvg, title="Daily Bullish IFVG Formed", message="{{ticker}}: Daily zone classified as bullish IFVG.")

alertcondition(d_nDBearIfvg, title="Daily Bearish IFVG Formed", message="{{ticker}}: Daily zone classified as bearish IFVG.")

//==============================================================================

// DAILY FIRST-RETEST ALERTS

//==============================================================================

alertcondition(d_tDBullFvg, title="Daily Bullish FVG First Retest", message="{{ticker}}: price reached a Daily bullish FVG.")

alertcondition(d_tDBearFvg, title="Daily Bearish FVG First Retest", message="{{ticker}}: price reached a Daily bearish FVG.")

alertcondition(d_tDBullIfvg, title="Daily Bullish IFVG First Retest", message="{{ticker}}: price reached a Daily bullish IFVG.")

alertcondition(d_tDBearIfvg, title="Daily Bearish IFVG First Retest", message="{{ticker}}: price reached a Daily bearish IFVG.")


// ==============================================================================
// 15M FVG ONLY — CURRENT EXCHANGE TRADING SESSION
// Retain every 15M FVG formed in this session, not only the latest candle.
// Prune at the next exchange Daily session boundary, including overnight sessions.
// Existing engines and alerts remain independent and unchanged.
// ==============================================================================
m15_groupMaster = "15M • 01. Master Controls"
m15_enableIndicator = input.bool(true, "Enable indicator", group=m15_groupMaster)
m15_sessionLookback = input.string("Today only", "15M FVG session lookback", options=["Today only"], tooltip="Retain all 15M fair value gaps formed in the current exchange trading session. Gaps remain when later 15M candles close. Previous-session gaps are removed at the next Daily session boundary. On futures, this includes the overnight portion of the current trading day. The global unmitigated-only checkbox still applies.", group=m15_groupMaster)
m15_showZoneText = input.bool(true, "Show timeframe tag", group=m15_groupMaster)
m15_timeframeTag = input.string("15", "Custom timeframe tag", group=m15_groupMaster)
m15_projectionAnchor = input.string("First FVG candle", "Zone begins from", options=["First FVG candle", "FVG end candle"], group=m15_groupMaster)
m15_groupInventory = "15M • 02. Inventory / Minimum Size"
m15_minGap = input.float(0.0, "15M: minimum FVG size, points", minval=0.0, step=0.25, group=m15_groupInventory)
m15_enableBullFvg = input.bool(true, "15M Bullish FVG — plot", group=m15_groupInventory)
m15_enableBearFvg = input.bool(true, "15M Bearish FVG — plot", group=m15_groupInventory)
m15_groupVisual = "15M • 03. Visual Customization"
m15_bullishBaseColor = input.color(color.rgb(0, 139, 170), "Bullish cyan-blue", group=m15_groupVisual)
m15_bearishBaseColor = input.color(color.rgb(132, 78, 170), "Bearish purple", group=m15_groupVisual)
m15_fvgFillTransparency = input.int(84, "FVG fill transparency", minval=0, maxval=100, group=m15_groupVisual)
m15_borderTransparency = input.int(18, "Border transparency", minval=0, maxval=100, group=m15_groupVisual)
m15_boxBorderWidth = input.int(1, "Box border width", minval=0, maxval=4, group=m15_groupVisual)
m15_zoneTextColor = input.color(color.new(color.white, 15), "Zone text color", group=m15_groupVisual)

bool m15_isSourceChart = timeframe.isintraday and timeframe.in_seconds() == 15 * 60
bool m15_isLowerChart = timeframe.isintraday and timeframe.in_seconds() < 15 * 60
bool m15_canRun = m15_enableIndicator and (m15_isSourceChart or m15_isLowerChart)

// Confirmed source values only on lower charts; no unfinished 15M formation.
[m15_closedTime, m15_closedFirstTime, m15_closedHigh, m15_closedLow, m15_closedHighTwoBack, m15_closedLowTwoBack] = request.security(
     syminfo.tickerid, "15",
     [time[1], time[3], high[1], low[1], high[3], low[3]],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
int m15_sourceTime = m15_isSourceChart ? time : m15_closedTime
int m15_firstTime = m15_isSourceChart ? time[2] : m15_closedFirstTime
float m15_sourceHigh = m15_isSourceChart ? high : m15_closedHigh
float m15_sourceLow = m15_isSourceChart ? low : m15_closedLow
float m15_firstHigh = m15_isSourceChart ? high[2] : m15_closedHighTwoBack
float m15_firstLow = m15_isSourceChart ? low[2] : m15_closedLowTwoBack

// The symbol's Daily opening time is known at session open; it uses no future prices.
int m15_currentSessionStart = request.security(syminfo.tickerid, "D", time, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

type m15_Zone
    float lo
    float hi
    int direction
    int originTime
    int leftTime
    int formationAfterBar
    bool retraced
    box bx

var array<m15_Zone> m15_zones = array.new<m15_Zone>()
var int m15_processedTime = na

// Remove prior-session inventory immediately when the new session starts.
int m15_pruneIndex = array.size(m15_zones) - 1
while m15_pruneIndex >= 0
    m15_Zone z = array.get(m15_zones, m15_pruneIndex)
    if z.originTime < m15_currentSessionStart
        if not na(z.bx)
            box.delete(z.bx)
        array.remove(m15_zones, m15_pruneIndex)
    m15_pruneIndex -= 1

// Each confirmed source candle may ADD a gap; it never replaces earlier session gaps.
// Time-key deduplication also rebuilds correctly during realtime bar rollback.
bool m15_newClosedSource = m15_canRun and not na(m15_sourceTime) and (m15_isLowerChart or barstate.isconfirmed) and (na(m15_processedTime) or m15_sourceTime != m15_processedTime)
if m15_newClosedSource
    m15_processedTime := m15_sourceTime
    // At the session boundary, the lower chart may still report the prior session's
    // last completed 15M candle. Do not re-add a gap from that previous session.
    if m15_sourceTime >= m15_currentSessionStart
        int leftTime = m15_projectionAnchor == "First FVG candle" ? m15_firstTime : m15_sourceTime
        int formationAfterBar = m15_isSourceChart ? bar_index : bar_index - 1
        bool bullGap = not na(m15_firstHigh) and m15_sourceLow > m15_firstHigh and m15_sourceLow - m15_firstHigh >= m15_minGap
        bool bearGap = not na(m15_firstLow) and m15_sourceHigh < m15_firstLow and m15_firstLow - m15_sourceHigh >= m15_minGap
        if bullGap
            array.push(m15_zones, m15_Zone.new(m15_firstHigh, m15_sourceLow, 1, m15_sourceTime, leftTime, formationAfterBar, false, na))
        else if bearGap
            array.push(m15_zones, m15_Zone.new(m15_sourceHigh, m15_firstLow, -1, m15_sourceTime, leftTime, formationAfterBar, false, na))

// Track and draw every retained gap independently, including on the 1M chart.
int m15_zoneIndex = 0
while m15_zoneIndex < array.size(m15_zones)
    m15_Zone z = array.get(m15_zones, m15_zoneIndex)
    // The formation candle itself never counts as a retracement.
    if not z.retraced and bar_index > z.formationAfterBar
        bool reachedGap = z.direction == 1 ? low <= z.hi : high >= z.lo
        if reachedGap
            z.retraced := true
    bool directionEnabled = z.direction == 1 ? global_enableAllBullish and m15_enableAllBullish and m15_enableBullFvg : global_enableAllBearish and m15_enableAllBearish and m15_enableBearFvg
    bool visible = m15_canRun and m15_enable15MMaster and directionEnabled and (not onlyUnmitigatedFvgs or not z.retraced)
    if visible
        color zoneColor = z.direction == 1 ? m15_bullishBaseColor : m15_bearishBaseColor
        if na(z.bx)
            z.bx := box.new(left=z.leftTime, top=z.hi, right=time, bottom=z.lo, xloc=xloc.bar_time, extend=extend.none, bgcolor=color.new(zoneColor, m15_fvgFillTransparency), border_color=color.new(zoneColor, m15_borderTransparency), border_width=m15_boxBorderWidth, border_style=line.style_solid, text=m15_showZoneText ? m15_timeframeTag : "", text_color=m15_zoneTextColor, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)
        else
            box.set_right(z.bx, time)
    else if not na(z.bx)
        box.delete(z.bx)
        z.bx := na
    array.set(m15_zones, m15_zoneIndex, z)
    m15_zoneIndex += 1
````
