<!-- tradingview-pine-id: PUB;7b00a65f24b4445dac7993779a3124d7 -->
<!-- tradingviewscripts-format: 1 -->
# BK AK-Gann Celestial Cycle

Source: https://www.tradingview.com/script/7s5Hn2as-BK-AK-Gann-Celestial-Cycle/

## Description

BK AK-Gann Celestial Cycle

An open-source, non-commercial celestial timing framework that maps astronomical cycle transitions directly onto the market chart as objective decision windows—not directional trading signals.

Acknowledgment

All glory to G-d.

The AK in BK AK-Gann Celestial Cycle honors my mentor, A.K.—the man whose guidance shaped my discipline, patience, market judgment, and respect for clean execution. I dedicate every indicator I build to his honor.

Celestial Engine Attribution

BK AK-Gann Celestial Cycle uses:

Blueprint Ephemeris by BlueprintResearch
Library: BlueprintResearch/blueprint_ephemeris_lib/7
Library author: Blueprint Research LLC
Library license: CC BY-NC-SA 4.0

Respect and Appreciation for BlueprintResearch

BlueprintResearch’s indicators and celestial research tools are exceptional. The precision, depth, and craftsmanship behind the Blueprint Ephemeris library deserve full recognition, and I am genuinely grateful for the opportunity to build upon that work with proper attribution.

The astronomical engine is a major foundation of BK AK-Gann Celestial Cycle, and full credit belongs to BlueprintResearch for creating and maintaining such a high-quality resource. This acknowledgment reflects my sincere respect and appreciation for the work and does not imply a formal partnership, sponsorship, or endorsement.

Overview

BK AK-Gann Celestial Cycle is designed to place significant astronomical transitions on financial charts with precise timestamps and organized visual context.

The indicator can track:

Solar sign ingresses
Equinoxes and solstices
New and Full Moons
The complete eight-phase lunar cycle
Mercury retrograde and direct stations
North and South lunar-node crossings

Its governing principle is:

Celestial events identify timing windows. Price structure determines direction.

The appearance of a celestial marker does not mean that price must rise, fall, reverse, accelerate, or become more volatile.

Each event should be treated as a timestamp around which traders can evaluate independent market evidence such as:

Swing structure
Support and resistance
VWAP location
Moving-average context
Volume
Momentum
Breakout acceptance
Rejection
Compression and expansion
Gann-Inspired Cycle Framework

BK AK-Gann Celestial Cycle organizes recurring astronomical transitions into measurable angular and time-based divisions.

These include:

Solar ingresses at 30-degree zodiac boundaries
Equinoxes and solstices at major seasonal quarter points
New and Full Moons at opposing points of the lunation cycle
Eight lunar phases divided into 45-degree intervals
Mercury stations marking changes in apparent geocentric motion
Lunar-node crossings based on the Moon’s relationship to the selected node axis

These divisions are displayed as timing references.

They are not presented as predetermined bullish or bearish forecasts.

Adaptive Trading Modes

The indicator includes four operating modes:

Auto
Intraday
Swing
Manual
Auto Mode

Auto mode adjusts the Moon display according to the active chart timeframe.

Below four hours: complete eight-phase lunar cycle
Four hours and above: New and Full Moon display

This provides additional short-cycle detail on intraday charts while reducing clutter on higher timeframes.

Intraday Mode

Intraday mode emphasizes:

Eight-phase Moon transitions
Precise event placement
Same-bar marker separation
Shorter observation windows
Immediate VWAP and structure context
Swing Mode

Swing mode emphasizes broader celestial references such as:

New and Full Moons
Solar ingresses
Seasonal transitions
Mercury stations
Higher-timeframe market structure
Manual Mode

Manual mode follows the user’s exact display selections without automatically changing the event configuration according to timeframe.

Solar Ingresses

A solar ingress occurs when the Sun enters the next 30-degree zodiac division.

The indicator detects the transition and places the corresponding zodiac marker at the calculated event time.

Solar ingresses create recurring monthly cycle partitions that can be reviewed alongside:

Existing trend structure
Important swing levels
Range expansion
Breakout attempts
Volatility changes
VWAP acceptance or rejection

The ingress itself does not provide direction.

Equinoxes and Solstices

The seasonal engine identifies:

March Equinox
June Solstice
September Equinox
December Solstice

These events represent major quarter-year timing divisions.

Because they occur less frequently than ordinary solar ingresses, they can provide broader reference windows for examining:

Weekly structure
Extended directional moves
Major support and resistance tests
Volatility transitions
Larger range changes
Lunar Cycle

The Moon module supports:

Off
New and Full Moon only
Complete eight-phase cycle
New and Full Moon Mode

This mode displays only:

New Moon
Full Moon

It provides a cleaner layout for swing and higher-timeframe analysis.

Eight-Phase Mode

The full lunar cycle includes:

New Moon
Waxing Crescent
First Quarter
Waxing Gibbous
Full Moon
Waning Gibbous
Last Quarter
Waning Crescent

Each phase represents a 45-degree division of the angular relationship between the Sun and Moon.

These phases provide recurring timing intervals. Any continuation, reversal, pause, or volatility interpretation must be confirmed independently through price behavior.

Mercury Stations

The Mercury engine identifies transitions between:

Direct motion
Retrograde motion

Retrograde status is determined through geocentric Mercury speed supplied by the Blueprint Ephemeris library.

The indicator searches within the relevant interval and refines the station timestamp rather than assigning the transition only to a broad calendar date.

Mercury stations should be treated as transition windows for reviewing market structure, volatility, and breakout quality.

No specific market outcome is assumed.

Lunar-Node Crossings

The optional lunar-node module can use:

Mean Node
True Node

It identifies Moon crossings of the selected North and South Node axis.

Node crossings provide another celestial timing layer, but they do not independently establish market direction.

The default Mean Node setting provides a smoother node model, while the True Node includes additional periodic variation.

Refined Event Timing

The indicator does more than compare daily calendar dates.

It searches for astronomical state changes inside the relevant chart interval and refines the transition time through bounded interval calculations.

This timing process is applied to events including:

Solar sign changes
Mercury stations
New and Full Moons
Eight-phase lunar transitions
Lunar-node crossings

Markers use the calculated event timestamp through time-based chart positioning.

The chart timeframe still determines the candle in which the event is visually contained. A transition occurring inside a four-hour bar will necessarily appear within that four-hour chart interval.

Event Markers and Clutter Control

Event markers can be displayed using:

Above/below-candle placement
ATR-based Zenith placement

Users can configure:

Marker size
Horizontal offset
Minimum spacing between event types
Same-bar marker separation
Maximum retained event icons
Moon icon style
Waxing and waning placement
Background shading

When several events occur within the same chart bar, the spread system can shift the markers horizontally to reduce overlap.

Older event markers are automatically removed when the selected maximum is exceeded.

Status and “What’s Next” Table

The optional status table summarizes current celestial conditions and upcoming events.

It can display:

Current solar sign
Current Mercury state
Current lunar phase
Next solar ingress
Next seasonal transition
Next Mercury station
Next lunar event
Next lunar-node crossing

Hovering over each field provides expanded information, timestamps, current chart context, and related upcoming events.

The table can be positioned in any major chart corner or center location.

Display Timezone

Displayed timestamps can use:

New York
Chicago
Denver
Los Angeles
UTC
The chart symbol’s timezone

Changing the display timezone affects only how event times appear in tooltips and the status table.

It does not alter the astronomical calculations.

Market-Context References

The event tooltips include basic chart context from:

Session VWAP
EMA 20
SMA 50
Current price location relative to those references

These measurements provide additional market context around the celestial timestamp.

They are separate from the celestial calculation engine and do not convert an astronomical event into a trading signal.

Alerts

Alerts are available for:

Solar ingresses
Equinoxes and solstices
New Moon
Full Moon
Eight-phase lunar changes
Mercury station retrograde
Mercury station direct
North Node crossing
South Node crossing

Alerts can be restricted to confirmed chart bars.

An alert means the relevant astronomical transition occurred within the evaluated chart interval. It does not constitute a buy, sell, reversal, continuation, or volatility signal.

How to Use BK AK-Gann Celestial Cycle
1. Begin With Auto Mode

Auto mode provides the simplest starting configuration.

It automatically selects:

Eight lunar phases for intraday charts
New and Full Moon events for higher timeframes

Manual mode is available when exact control is preferred.

2. Treat Every Event as a Timing Window

A marker means:

A defined celestial transition occurred at this timestamp.

It does not mean:

Buy
Sell
Reverse
Exit
Increase exposure

Observe how the market behaves before, during, and after the event.

3. Check Market Structure

Determine whether the event occurs near:

A confirmed swing high or low
Prior-day or prior-week structure
VWAP
A major moving average
A consolidation boundary
Established support or resistance

A timing event near an important price reference may deserve greater attention than one occurring in the middle of an unresolved range.

4. Observe Acceptance and Rejection

After the event, evaluate whether price:

Breaks and holds beyond structure
Breaks and returns inside the prior range
Reclaims VWAP
Rejects VWAP
Forms a higher low
Forms a lower high
Expands from compression
Fails to continue after the initial move

Direction must come from market behavior—not from the celestial event name.

5. Match the Window to the Timeframe

On intraday charts, the event bar and the next several bars may be the relevant observation window.

On daily or weekly charts, the event may be reviewed across a broader multi-bar period.

The appropriate window depends on:

Chart timeframe
Instrument volatility
Session structure
Proximity to an important price level
6. Control Visual Density

A practical starting layout is:

Solar ingresses: On
Seasonal events: On
Moon display: Auto
Mercury stations: On
Lunar nodes: Off
Marker size: Tiny
Same-bar spread: 1
Status table: On

Additional events can be enabled after the primary layout is understood.

Recommended Starting Configuration
Trading Mode: Auto
Coordinate System: Geocentric
Solar Ingresses: On
Solstices and Equinoxes: On
Moon Display: Auto
Mercury Stations: On
Lunar Nodes: Off initially
Icon Placement: Zenith
Icon Size: Tiny
Same-Bar Spread: 1
Status Table: On
Realtime Status Updates: Off
Display Timezone: America/New_York
Alerts Confirmed Only: On
Original BK Contribution

The underlying astronomical calculations are supplied by Blueprint Ephemeris by BlueprintResearch and are not claimed as original BK work.

The BK contribution includes the integration and chart framework that:

Organizes celestial events into adaptive operating modes
Detects transitions inside chart intervals
Refines event timestamps
Prevents duplicate event markers
Separates simultaneous chart events
Provides configurable marker placement
Manages marker-retention limits
Builds the status and upcoming-event interface
Applies user-selectable timezone formatting
Connects celestial timing with basic market context
Produces event-specific alerts and tooltips
Presents celestial events as timing filters rather than directional signals
Open-Source and Non-Commercial License

BK AK-Gann Celestial Cycle is published as an open-source, non-commercial indicator.

The celestial engine is provided by:

Blueprint Ephemeris by BlueprintResearch
Library: BlueprintResearch/blueprint_ephemeris_lib/7
Library author: Blueprint Research LLC
License: CC BY-NC-SA 4.0

This indicator may be viewed, studied, modified, and shared for personal, educational, and other non-commercial purposes, subject to the applicable attribution and ShareAlike requirements.

Modified versions must:

Preserve appropriate attribution
Identify that changes were made
Remain non-commercial
Be distributed under the applicable CC BY-NC-SA 4.0 terms

Commercial use, paid access, resale, paid redistribution, or inclusion in a commercial product is not authorized.

Realtime Behavior and Limitations
Realtime astronomical status may update while the active bar develops.
Confirmed-bar alerts wait until the host chart bar closes.
Intrabar alerts may occur earlier when confirmed-only mode is disabled.
Marker precision is still visually limited by the chart timeframe.
Large chart intervals can contain multiple astronomical transitions.
Timezone settings affect presentation, not astronomical computation.
Celestial timing does not establish market causation.
Historical coincidence does not guarantee future behavior.
Astronomical events do not override price structure, volume, or risk management.
Every market interpretation requires independent confirmation.
Risk Disclosure

BK AK-Gann Celestial Cycle is provided for analytical, educational, and timing-research purposes.

It does not provide financial advice, guarantee performance, or predict future market direction with certainty.

Users remain responsible for their own:

Market analysis
Entries
Exits
Position sizing
Invalidation
Order execution
Account risk

Time marks the window. Structure reveals the direction. Execution determines the outcome.

---

## Source Code

````pine
// BK AK-Gann Celestial Cycle
// © Ki11a_B
//
// Open-source, non-commercial publication.
//
// CELESTIAL ENGINE ATTRIBUTION:
// Blueprint Ephemeris by BlueprintResearch
// Library: BlueprintResearch/blueprint_ephemeris_lib/7
// Library author: Blueprint Research LLC
// Library license: CC BY-NC-SA 4.0
//
// This indicator and modified versions are intended solely for
// open-source, personal, educational, and non-commercial use.
//
// Appropriate attribution must be preserved.
// Changes must be identified.
// Commercial use and paid redistribution are not authorized.
//
// No affiliation, sponsorship, or endorsement by
// BlueprintResearch is implied.

//@version=6
indicator(
    "BK AK-Gann Celestial Cycle",
    shorttitle = "🌕♉",
    overlay = true,
    behind_chart = false,
    max_bars_back = 500,
    max_labels_count = 500
)

import BlueprintResearch/blueprint_ephemeris_lib/7 as eph

const string EPHEMERIS_CREDIT = "Blueprint Ephemeris by BlueprintResearch"
const string EPHEMERIS_LIBRARY = "BlueprintResearch/blueprint_ephemeris_lib/7"
const string EPHEMERIS_LICENSE = "CC BY-NC-SA 4.0"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⚙️ Trading Mode (Auto Intraday vs Swing)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var g0 = "⚙️ Trading Mode"
trading_mode = input.string("Auto", "Mode", options=["Auto","Intraday","Swing","Manual"], group=g0,
     tooltip="Auto:\n• Intraday (<4H): 8-phase Moon display and at least one-bar same-event spread.\n• Swing (≥4H/D/W/M): New/Full Moon display.\n\nManual: uses your exact display inputs.")

// Timeframe classification
float tf_sec = timeframe.in_seconds(timeframe.period)
auto_intraday = timeframe.isintraday and not na(tf_sec) and (tf_sec < 4 * 60 * 60)  // < 4H
mode_eff = trading_mode == "Auto" ? (auto_intraday ? "Intraday" : "Swing") : trading_mode
is_manual = mode_eff == "Manual"
is_intraday = mode_eff == "Intraday"
is_swing = mode_eff == "Swing"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var g1 = "🌌 Events"
use_geo              = input.bool(true, "Geocentric (recommended)", group=g1,
     tooltip="Controls planetary longitude coordinates. Sun and Moon remain geocentric in the library. Mercury retrograde speed is always geocentric because retrograde is an Earth-view effect.")
show_sun_ingress     = input.bool(true, "Sun ingresses (monthly) ☀️", group=g1)
show_seasons         = input.bool(true, "Solstices / Equinoxes 🧭", group=g1)

// ✅ FIX (your correction): Auto moon logic is now REVERSED to match your intent.
// Auto (TF-based):
// • Intraday (<4H)  => 8-Phase cycle
// • Swing (≥4H)     => New & Full only
moon_display_in = input.string("Auto (TF-based)", "Moon Display",
     options=["Auto (TF-based)", "Off", "New & Full only", "8-Phase cycle"], group=g1,
     tooltip="Auto (TF-based):\n• Intraday (<4H): 8-Phase cycle\n• Swing (≥4H): New & Full only\n\nOff: no moon markers\nNew & Full only: 🌑 and 🌕 only\n8-Phase cycle: all 8 phase changes")

moon_display = moon_display_in == "Auto (TF-based)" ? (auto_intraday ? "8-Phase cycle" : "New & Full only") : moon_display_in

highlight_newfull_when_8phases_in = input.bool(false, "Use dedicated New/Full markers in 8-Phase", group=g1,
     tooltip="8-Phase already includes New/Full. ON replaces those two generic phase markers with dedicated New/Full markers and tooltips.")

show_mercury         = input.bool(true, "Mercury Retrograde (stations + shading) ☿", group=g1)
show_lunar_nodes      = input.bool(false, "Lunar node crossings ☊☋", group=g1,
     tooltip="Marks Moon crossings of the selected lunar-node axis. Mean Node is the stable default.")
node_type_in          = input.string("Mean Node", "Lunar Node Type",
     options=["Mean Node", "True Node"], group=g1, active=show_lunar_nodes,
     tooltip="Mean Node is smoother and more consistent. True Node includes periodic perturbations.")

var g2 = "⛔ Clutter Control (bars)"
sun_spacing_bars     = input.int(0, "Min bars between Sun ingresses", 0, 500, group=g2)
season_spacing_bars  = input.int(0, "Min bars between Seasons", 0, 500, group=g2)
moon_spacing_bars    = input.int(0, "Min bars between Moon events", 0, 500, group=g2)
merc_spacing_bars    = input.int(0, "Min bars between Mercury stations", 0, 500, group=g2)
node_spacing_bars    = input.int(0, "Min bars between Lunar Node events", 0, 500, group=g2)

// ✅ Enhancement: prevent max_labels exceeded by auto-deleting oldest event labels
max_event_icons      = input.int(450, "Max Event Icons (auto-delete old)", minval=50, maxval=500, group=g2)
only_last_n_symbols  = input.bool(false, "Only Last N Symbols", group=g2)
last_n_symbols       = input.int(7, "Last N Symbols", minval=1, maxval=500, group=g2, active=only_last_n_symbols)

var g3 = "🎨 Display"

// ✅ FIX: Default icon size is now tiny (and NOT overridden by mode).
icon_size_in         = input.string("tiny", "Icon Size", ["tiny","small","normal","large"], group=g3)

// Placement mode
placement_mode = input.string("Zenith (price)", "Icon Placement",
    options=["Above/Below (absolute)", "Zenith (price)"], group=g3,
    tooltip="Above/Below = pins icons above/below candles so they NEVER overlap.\nZenith = ATR-based vertical stacking above price (older style).")

same_bar_spread_bars_in = input.int(1, "Same-bar icon spread (bars)", minval=0, maxval=10, group=g3,
    tooltip="When multiple events happen on the SAME candle, this shifts icons sideways so they don't overlap.\n0 = overlap possible.\n1–3 = clean.")

// Auto mode keeps a minimum one-bar spread intraday. Manual uses the exact input.
same_bar_spread_bars = is_manual ? same_bar_spread_bars_in : (is_intraday ? math.max(same_bar_spread_bars_in, 1) : same_bar_spread_bars_in)

icon_x_offset_bars_in   = input.int(0, "Icon X Offset (bars)", minval=-20, maxval=20, group=g3,
     tooltip="Moves icons left/right in bars.\n0 = aligned to the candle.\n+2 to +6 often looks cleaner.")

// Always honor the requested base offset. Same-bar spread handles collisions.
icon_x_offset_bars = icon_x_offset_bars_in

// Zenith behavior (used only if placement_mode == Zenith)
zenith_atr_mult      = input.float(0.65, "Zenith height (ATR multiple)", 0.10, 3.00, 0.05, group=g3)
zenith_stack_mult    = input.float(0.25, "Zenith stacking (ATR multiple)", 0.05, 1.00, 0.05, group=g3)

// Moon layout (in absolute mode this decides above/below placement)
moon_phase_layout_in = input.string("Waxing Above / Waning Below", "Moon Phase Layout",
    ["Zenith","Waxing Above / Waning Below"], group=g3,
    tooltip="Zenith = moon icons treated as 'above'.\nWaxing/Waning = waxing phases above, waning phases below (clean separation).")

// Moon icon set (phase-distinct)
moon_icon_set = input.string("Emoji 8-Phase", "Moon Icon Set",
    ["Emoji 8-Phase", "Clean Unicode 8-Phase"], group=g3,
    tooltip="Emoji 8-Phase: 🌑🌒🌓🌔🌕🌖🌗🌘\nClean Unicode 8-Phase: ● ◔ ◐ ◕ ○ ◕ ◑ ◔")

// ✅ FIX: Default table text size is now tiny (and NOT overridden by mode).
info_table_text_size_in = input.string("tiny", "Info Table Text Size", ["tiny","small","normal"], group=g3)

shade_mercury_rx     = input.bool(true,  "Shade Mercury Rx period", group=g3)
shade_season_bar     = input.bool(false, "Shade bar on Solstice/Equinox", group=g3)
shade_sun_ingress    = input.bool(false, "Shade bar on Sun ingress", group=g3)
shade_moon_event     = input.bool(false, "Shade bar on New/Full Moon", group=g3)

show_status          = input.bool(true, "Show Status / What’s Next table", group=g3)
live_status_updates  = input.bool(false, "Update Status Table Every Realtime Tick", group=g3,
     active=show_status,
     tooltip="OFF updates on a new bar and at bar close for efficiency. ON refreshes astronomical timers and state on every realtime tick.")
table_position_in    = input.string("top_right", "Table Position",
    ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group=g3)

// Derived moon flags
show_moon   = moon_display != "Off"
use_moon_nf = moon_display == "New & Full only"
use_moon_8  = moon_display == "8-Phase cycle"

// Icon size map
icon_size = switch icon_size_in
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.tiny

// Info table text size map
info_table_text_size = switch info_table_text_size_in
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    => size.tiny

// Table position const (resolved once)
var table_pos_const = position.top_right
if barstate.isfirst
    table_pos_const := switch table_position_in
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.top_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🕒 Display Time Zone (portable)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var g4 = "🕒 Time Zone"

tz_display_in = input.string("America/New_York", "Display Time Zone",
     options=[
        "America/New_York",      // Eastern (ET)
        "America/Chicago",       // Central (CT)
        "America/Denver",        // Mountain (MT)
        "America/Los_Angeles",   // Pacific (PT)
        "Etc/UTC",               // UTC
        "Chart (symbol)"
     ],
     group=g4,
     tooltip="Affects ALL timestamps shown in tooltips + table.\nDoes NOT change event calculations.\n\nChart (symbol) uses the chart/symbol timezone.")

// Keep the variable name NY_TZ so the rest of your script stays intact.
// Default remains New York (ET).
string NY_TZ = tz_display_in == "Chart (symbol)" ? syminfo.timezone : tz_display_in

var g5 = "🔔 Alerts"
alerts_confirmed_only = input.bool(true, "Trigger only on confirmed bars", group=g5,
     tooltip="ON = event alerts wait for the chart bar to close. OFF = events can trigger intrabar after the astronomical timestamp is reached.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
normalize360(x) =>
    float r = x % 360.0
    r := r < 0 ? r + 360.0 : r


fmt_dhm(int ms) =>
    ms <= 0 ? "0m" :
     str.tostring(int(ms / 86400000.0)) + "d " +
     str.tostring(int((ms % 86400000.0) / 3600000.0)) + "h " +
     str.tostring(int((ms % 3600000.0) / 60000.0)) + "m"

fmt_dt(int ts) =>
    str.format_time(ts, "yyyy-MM-dd HH:mm", NY_TZ)

fmt_dt_compact(int ts) =>
    str.format_time(ts, "MM-dd HH:mm", NY_TZ)

const int MS_H = 3600000
const int MS_D = 86400000

eph.Planet SUN  = eph.Planet.Sun
eph.Planet MOON = eph.Planet.Moon
eph.Planet MERC = eph.Planet.Mercury

lon_at(eph.Planet planet, int t) =>
    normalize360(eph.get_longitude(planet, t, use_geo))

decl_at(eph.Planet planet, int t) =>
    eph.get_declination(planet, t)

mer_speed_at(int t) =>
    eph.get_speed(MERC, t)

sun_sign_at(int t) =>
    int(math.floor(lon_at(SUN, t) / 30.0))

elong_at(int t) =>
    normalize360(lon_at(MOON, t) - lon_at(SUN, t))

node_lon_at(int t) =>
    normalize360(node_type_in == "True Node" ? eph.get_true_north_node_lon(t) : eph.get_mean_north_node_lon(t))

node_phase_at(int t) =>
    normalize360(lon_at(MOON, t) - node_lon_at(t))

// ✅ Upgrade (PRECISION): bounded bisection to get exact change time inside [t0, t1]
find_sign_change_time_in_range(int t0, int t1, int sign0) =>
    if sign0 == sun_sign_at(t1)
        na
    else
        int lo = t0
        int hi = t1
        for j = 1 to 22
            int mid = int(math.floor((lo + hi) / 2))
            if sun_sign_at(mid) != sign0
                hi := mid
            else
                lo := mid
        hi

// v7 native geocentric speed engine. Negative speed = retrograde.
is_mer_rx_at(int t) =>
    float speed = mer_speed_at(t)
    not na(speed) and speed < 0.0

// ✅ Upgrade (PRECISION): bounded bisection to get exact Mercury station time inside [t0, t1]
find_mer_station_time_in_range(int t0, int t1, bool rx0) =>
    if is_mer_rx_at(t1) == rx0
        na
    else
        int lo = t0
        int hi = t1
        for j = 1 to 22
            int mid = int(math.floor((lo + hi) / 2))
            if is_mer_rx_at(mid) != rx0
                hi := mid
            else
                lo := mid
        hi

find_latest_mer_station(int t0, int t1) =>
    int foundT = na
    bool stationToRx = false
    if not na(t0) and not na(t1) and t1 > t0
        int step = 6 * MS_H
        int scanCount = int(math.ceil(float(t1 - t0) / float(step)))
        scanCount := math.max(1, math.min(scanCount, 1500))
        int prevT = t0
        bool prevRx = is_mer_rx_at(prevT)
        for i = 1 to scanCount
            int curT = math.min(t1, t0 + i * step)
            bool curRx = is_mer_rx_at(curT)
            if curRx != prevRx
                int refined = find_mer_station_time_in_range(prevT, curT, prevRx)
                foundT := na(refined) ? curT : refined
                stationToRx := curRx
            prevT := curT
            prevRx := curRx
            if curT >= t1
                break
    [foundT, stationToRx]

find_next_mer_station(int startT, bool curRx) =>
    int step = 6 * MS_H
    int hi = na
    for i = 1 to 700
        int t = startT + i * step
        if is_mer_rx_at(t) != curRx
            hi := t
            break
    if na(hi)
        na
    else
        int lo = hi - step
        for j = 1 to 18
            int mid = int(math.floor((lo + hi) / 2))
            if is_mer_rx_at(mid) != curRx
                hi := mid
            else
                lo := mid
        hi

find_latest_sign_change(int t0, int t1) =>
    int foundT = na
    int enteredSign = na
    if not na(t0) and not na(t1) and t1 > t0
        int step = 12 * MS_H
        int scanCount = int(math.ceil(float(t1 - t0) / float(step)))
        scanCount := math.max(1, math.min(scanCount, 1000))
        int prevT = t0
        int prevSign = sun_sign_at(prevT)
        for i = 1 to scanCount
            int curT = math.min(t1, t0 + i * step)
            int curSign = sun_sign_at(curT)
            if curSign != prevSign
                int refined = find_sign_change_time_in_range(prevT, curT, prevSign)
                foundT := na(refined) ? curT : refined
                enteredSign := curSign
            prevT := curT
            prevSign := curSign
            if curT >= t1
                break
    [foundT, enteredSign]

find_next_sign_change(int startT, int curSign) =>
    int step = 6 * MS_H
    int hi = na
    for i = 1 to 240
        int t = startT + i * step
        if sun_sign_at(t) != curSign
            hi := t
            break
    if na(hi)
        na
    else
        int lo = hi - step
        for j = 1 to 18
            int mid = int(math.floor((lo + hi) / 2))
            if sun_sign_at(mid) != curSign
                hi := mid
            else
                lo := mid
        hi

find_next_seasonal(int startT, int curSign) =>
    int tScan = startT
    int sScan = curSign
    int tOut = na
    string nOut = "-"
    for k = 1 to 10
        int tN = find_next_sign_change(tScan, sScan)
        if na(tN)
            break
        int sN = sun_sign_at(tN)
        if (sN == 0) or (sN == 3) or (sN == 6) or (sN == 9)
            tOut := tN
            nOut := sN == 0 ? "March Equinox" : sN == 3 ? "June Solstice" : sN == 6 ? "September Equinox" : "December Solstice"
            break
        tScan := tN + MS_H
        sScan := sN
    [tOut, nOut]

// ✅ Upgrade (PRECISION): moon crossing helper (continuous in-range unwrap from bar start)
moon_unwrap_from(float base, float e) =>
    e < base ? e + 360.0 : e

moon_unwrap_at(int t, float base) =>
    float e = elong_at(t)
    na(e) ? na : moon_unwrap_from(base, e)

find_moon_cross_time(int t0, int t1, float target) =>
    float base = elong_at(t0)
    if na(base)
        na
    else
        float v1 = moon_unwrap_at(t1, base)

        // ✅ FIX (PERFECT): only count a crossing if the interval STRADDLES the target
        if na(v1) or not (base < target and v1 >= target)
            na
        else
            int lo = t0
            int hi = t1
            for j = 1 to 22
                int mid = int(math.floor((lo + hi) / 2))
                float vm = moon_unwrap_at(mid, base)
                if not na(vm) and vm >= target
                    hi := mid
                else
                    lo := mid
            hi

// Uses direct bisection on short intervals and a 6-hour scan on long chart bars/gaps.
// Returns the latest matching crossing inside [t0, t1].
find_latest_moon_events(int t0, int t1) =>
    int latestNew = na
    int latestFull = na
    if not na(t0) and not na(t1) and t1 > t0
        if t1 - t0 <= 2 * MS_D
            latestNew := find_moon_cross_time(t0, t1, 360.0)
            latestFull := find_moon_cross_time(t0, t1, 180.0)
        else
            int step = 6 * MS_H
            int scanCount = int(math.ceil(float(t1 - t0) / float(step)))
            scanCount := math.max(1, math.min(scanCount, 500))
            int prevT = t0
            for i = 1 to scanCount
                int curT = math.min(t1, t0 + i * step)
                int newHit = find_moon_cross_time(prevT, curT, 360.0)
                int fullHit = find_moon_cross_time(prevT, curT, 180.0)
                if not na(newHit)
                    latestNew := newHit
                if not na(fullHit)
                    latestFull := fullHit
                prevT := curT
                if curT >= t1
                    break
    [latestNew, latestFull]

find_next_moon_event(int startT) =>
    int step = 3 * MS_H
    float prev = elong_at(startT)
    int foundT = na
    string kind = "-"
    for i = 1 to 600
        int t = startT + i * step
        float cur = elong_at(t)
        bool newHit  = (prev > cur)
        bool fullHit = (prev < 180 and moon_unwrap_from(prev, cur) >= 180)
        if newHit
            int tRef = find_moon_cross_time(t - step, t, 360.0)
            foundT := na(tRef) ? t : tRef
            kind := "New Moon"
            break
        if fullHit
            int tRef = find_moon_cross_time(t - step, t, 180.0)
            foundT := na(tRef) ? t : tRef
            kind := "Full Moon"
            break
        prev := cur
    [foundT, kind]

find_next_moon_event_enabled(int startT) =>
    if show_moon
        find_next_moon_event(startT)
    else
        int noTime = na
        [noTime, "-"]

// Lunar-node crossing helper. Phase is Moon longitude minus selected North Node longitude.
node_unwrap_at(int t, float base) =>
    float p = node_phase_at(t)
    na(p) ? na : moon_unwrap_from(base, p)

find_node_cross_time(int t0, int t1, float target) =>
    float base = node_phase_at(t0)
    if na(base)
        na
    else
        float v1 = node_unwrap_at(t1, base)
        if na(v1) or not (base < target and v1 >= target)
            na
        else
            int lo = t0
            int hi = t1
            for j = 1 to 22
                int mid = int(math.floor((lo + hi) / 2))
                float vm = node_unwrap_at(mid, base)
                if not na(vm) and vm >= target
                    hi := mid
                else
                    lo := mid
            hi

find_latest_node_events(int t0, int t1) =>
    int latestNorth = na
    int latestSouth = na
    if not na(t0) and not na(t1) and t1 > t0
        if t1 - t0 <= 2 * MS_D
            latestNorth := find_node_cross_time(t0, t1, 360.0)
            latestSouth := find_node_cross_time(t0, t1, 180.0)
        else
            int step = 6 * MS_H
            int scanCount = int(math.ceil(float(t1 - t0) / float(step)))
            scanCount := math.max(1, math.min(scanCount, 500))
            int prevT = t0
            for i = 1 to scanCount
                int curT = math.min(t1, t0 + i * step)
                int northHit = find_node_cross_time(prevT, curT, 360.0)
                int southHit = find_node_cross_time(prevT, curT, 180.0)
                if not na(northHit)
                    latestNorth := northHit
                if not na(southHit)
                    latestSouth := southHit
                prevT := curT
                if curT >= t1
                    break
    [latestNorth, latestSouth]

find_next_node_event(int startT) =>
    int step = 3 * MS_H
    float prev = node_phase_at(startT)
    int foundT = na
    string kind = "-"
    for i = 1 to 400
        int t = startT + i * step
        float cur = node_phase_at(t)
        bool northHit = prev > cur
        bool southHit = prev < 180.0 and moon_unwrap_from(prev, cur) >= 180.0
        if northHit
            int tRef = find_node_cross_time(t - step, t, 360.0)
            foundT := na(tRef) ? t : tRef
            kind := "North Node"
            break
        if southHit
            int tRef = find_node_cross_time(t - step, t, 180.0)
            foundT := na(tRef) ? t : tRef
            kind := "South Node"
            break
        prev := cur
    [foundT, kind]

find_next_node_event_enabled(int startT) =>
    if show_lunar_nodes
        find_next_node_event(startT)
    else
        int noTime = na
        [noTime, "-"]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Moon 8-Phase helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var string[] moon_icons_emoji = array.from("🌑","🌒","🌓","🌔","🌕","🌖","🌗","🌘")
var string[] moon_icons_clean = array.from("●","◔","◐","◕","○","◕","◑","◔")

var string[] moon_names = array.from("New Moon","Waxing Crescent","First Quarter","Waxing Gibbous","Full Moon","Waning Gibbous","Last Quarter","Waning Crescent")
var string[] moon_short = array.from("New","WaxC","1Q","WaxG","Full","WanG","3Q","WanC")

moon_icon(int idx) =>
    moon_icon_set == "Clean Unicode 8-Phase" ? array.get(moon_icons_clean, idx) : array.get(moon_icons_emoji, idx)

moon_phase8_idx_at(int t) =>
    float e = elong_at(t)
    int idx = int(math.floor(e / 45.0)) % 8
    idx

find_moon_phase8_change_time_in_range(int t0, int t1, int idx0) =>
    if moon_phase8_idx_at(t1) == idx0
        na
    else
        int lo = t0
        int hi = t1
        for j = 1 to 22
            int mid = int(math.floor((lo + hi) / 2))
            if moon_phase8_idx_at(mid) != idx0
                hi := mid
            else
                lo := mid
        hi

find_latest_moon_phase8_change(int t0, int t1) =>
    int foundT = na
    int enteredIdx = na
    if not na(t0) and not na(t1) and t1 > t0
        int step = 12 * MS_H
        int scanCount = int(math.ceil(float(t1 - t0) / float(step)))
        scanCount := math.max(1, math.min(scanCount, 1000))
        int prevT = t0
        int prevIdx = moon_phase8_idx_at(prevT)
        for i = 1 to scanCount
            int curT = math.min(t1, t0 + i * step)
            int curIdx = moon_phase8_idx_at(curT)
            if curIdx != prevIdx
                int refined = find_moon_phase8_change_time_in_range(prevT, curT, prevIdx)
                foundT := na(refined) ? curT : refined
                enteredIdx := curIdx
            prevT := curT
            prevIdx := curIdx
            if curT >= t1
                break
    [foundT, enteredIdx]

find_next_moon_phase8_change(int startT, int curIdx) =>
    int step = 3 * MS_H
    int hi = na
    for i = 1 to 600
        int t = startT + i * step
        if moon_phase8_idx_at(t) != curIdx
            hi := t
            break
    if na(hi)
        na
    else
        int lo = hi - step
        for j = 1 to 18
            int mid = int(math.floor((lo + hi) / 2))
            if moon_phase8_idx_at(mid) != curIdx
                hi := mid
            else
                lo := mid
        hi

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Current state — realtime-safe and 1 ms boundary-safe
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int _tfMs = int(math.max(1000.0, nz(tf_sec, 60.0) * 1000.0))
int _barCloseSafe = na(time_close) ? time + _tfMs : time_close
int _calcTime = barstate.isrealtime ? int(math.min(float(_barCloseSafe), float(timenow))) : _barCloseSafe
int _tPrevClose = bar_index > 0 ? (na(time_close[1]) ? time[1] + _tfMs : time_close[1]) : na
int _tPrevProbe = bar_index > 0 ? (_tPrevClose - 1) : na

sunLon  = lon_at(SUN, _calcTime)

var string[] zodiac_glyphs = array.from("♈","♉","♊","♋","♌","♍","♎","♏","♐","♑","♒","♓")
var string[] zodiac_names  = array.from("Aries","Taurus","Gemini","Cancer","Leo","Virgo","Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces")

sun_sign_idx = int(math.floor(sunLon / 30.0))
sun_glyph    = array.get(zodiac_glyphs, sun_sign_idx)
sun_name     = array.get(zodiac_names,  sun_sign_idx)

[sun_ingress_time, sun_ingress_sign] = find_latest_sign_change((show_sun_ingress or show_seasons) ? _tPrevClose : na, _calcTime)
bool have_sun_ingress_time = bar_index > 0 and not na(float(sun_ingress_time))
sun_ingress_event = show_sun_ingress and have_sun_ingress_time
int sun_event_idx = have_sun_ingress_time ? sun_ingress_sign : sun_sign_idx
string sun_event_glyph = array.get(zodiac_glyphs, sun_event_idx)
int tSunIngr = have_sun_ingress_time ? sun_ingress_time : _calcTime

is_season_sign = (sun_event_idx == 0) or (sun_event_idx == 3) or (sun_event_idx == 6) or (sun_event_idx == 9)
season_event   = show_seasons and have_sun_ingress_time and is_season_sign
season_name = sun_event_idx == 0 ? "March Equinox (0° Aries)" :
              sun_event_idx == 3 ? "June Solstice (0° Cancer)" :
              sun_event_idx == 6 ? "September Equinox (0° Libra)" :
              sun_event_idx == 9 ? "December Solstice (0° Capricorn)" : ""
int season_time = season_event ? tSunIngr : na
bool have_season_time = season_event and not na(float(season_time))
int tSeason = have_season_time ? season_time : _calcTime

mer_rx_end_state = show_mercury ? is_mer_rx_at(_calcTime) : false
is_mer_rx = mer_rx_end_state
[mer_station_time, mer_station_to_rx] = find_latest_mer_station(show_mercury ? _tPrevClose : na, _calcTime)
bool have_mer_station_time = show_mercury and bar_index > 0 and not na(float(mer_station_time))
mer_start = have_mer_station_time and mer_station_to_rx
mer_end = have_mer_station_time and not mer_station_to_rx
int tMer = have_mer_station_time ? mer_station_time : _calcTime

var int _last_new_ts  = na
var int _last_full_ts = na
int _dup_tol = 12 * MS_H

[new_time_raw_scan, full_time_raw_scan] = find_latest_moon_events((show_moon and bar_index > 0) ? _tPrevProbe : na, _calcTime)
int new_time_raw = new_time_raw_scan
int full_time_raw = full_time_raw_scan

bool have_new_time  = not na(float(new_time_raw))
bool have_full_time = not na(float(full_time_raw))

bool new_unique  = have_new_time  and (na(_last_new_ts)  or math.abs(float(new_time_raw  - _last_new_ts))  > float(_dup_tol))
bool full_unique = have_full_time and (na(_last_full_ts) or math.abs(float(full_time_raw - _last_full_ts)) > float(_dup_tol))

new_moon_event  = show_moon and new_unique
full_moon_event = show_moon and full_unique

int tNew  = new_moon_event  ? new_time_raw  : na
int tFull = full_moon_event ? full_time_raw : na

if new_moon_event
    _last_new_ts := new_time_raw
if full_moon_event
    _last_full_ts := full_time_raw

moon_phase8_idx = moon_phase8_idx_at(_calcTime)
[moon_phase8_time, moon_phase8_entered_idx] = find_latest_moon_phase8_change(use_moon_8 ? _tPrevClose : na, _calcTime)
bool have_moon_phase8_time = bar_index > 0 and not na(float(moon_phase8_time))
moon_phase8_event = show_moon and use_moon_8 and have_moon_phase8_time
int moon_phase8_event_idx = moon_phase8_event ? moon_phase8_entered_idx : moon_phase8_idx
int tMoon8 = moon_phase8_event ? moon_phase8_time : _calcTime

var int _last_north_node_ts = na
var int _last_south_node_ts = na
int _node_dup_tol = 24 * MS_H

[north_node_time_raw_scan, south_node_time_raw_scan] = find_latest_node_events((show_lunar_nodes and bar_index > 0) ? _tPrevProbe : na, _calcTime)
int north_node_time_raw = north_node_time_raw_scan
int south_node_time_raw = south_node_time_raw_scan

bool have_north_node_time = not na(float(north_node_time_raw))
bool have_south_node_time = not na(float(south_node_time_raw))

bool north_node_unique = have_north_node_time and (na(_last_north_node_ts) or math.abs(float(north_node_time_raw - _last_north_node_ts)) > float(_node_dup_tol))
bool south_node_unique = have_south_node_time and (na(_last_south_node_ts) or math.abs(float(south_node_time_raw - _last_south_node_ts)) > float(_node_dup_tol))

bool north_node_event = show_lunar_nodes and north_node_unique
bool south_node_event = show_lunar_nodes and south_node_unique

int tNorthNode = north_node_event ? north_node_time_raw : na
int tSouthNode = south_node_event ? south_node_time_raw : na

if north_node_event
    _last_north_node_ts := north_node_time_raw
if south_node_event
    _last_south_node_ts := south_node_time_raw

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Zenith placement (only used in Zenith mode)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(14)
float atrSafe = na(atr) ? (high * 0.01) : atr
float zenBase = high + atrSafe * zenith_atr_mult
float zenStep = atrSafe * zenith_stack_mult

// Stateful TA calculations must execute on every bar.
float contextVwap = ta.vwap(hlc3)
float contextEma20 = ta.ema(close, 20)
float contextSma50 = ta.sma(close, 50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// State (spacing)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int stack = 0
var int lastSunBar    = -100000
var int lastSeasonBar = -100000
var int lastMoonBar   = -100000
var int lastMerBar    = -100000
var int lastNodeBar   = -100000

var label[] eventLabels = array.new<label>()

track_event_label(label l) =>
    if not na(l)
        array.push(eventLabels, l)
        int symbol_limit = only_last_n_symbols ? last_n_symbols : max_event_icons
        while array.size(eventLabels) > symbol_limit
            label old = array.shift(eventLabels)
            if not na(old)
                label.delete(old)

// Time-based X placement. Offsets and same-bar spread now move by actual chart bars.
int _bar_ms = math.max(1, _barCloseSafe - time)

xUseTime(int st, int tEvent) =>
    int shiftMs = (icon_x_offset_bars + st * same_bar_spread_bars) * _bar_ms
    tEvent + shiftMs

yUseAbove(int st) =>
    placement_mode == "Above/Below (absolute)" ? high : (zenBase + zenStep * st)

yUseBelow(int st) =>
    placement_mode == "Above/Below (absolute)" ? low : (low - atrSafe * zenith_atr_mult - zenStep * st)

ylocAbove() =>
    placement_mode == "Above/Below (absolute)" ? yloc.abovebar : yloc.price

ylocBelow() =>
    placement_mode == "Above/Below (absolute)" ? yloc.belowbar : yloc.price

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Icon Tooltip Enhancements (ADDITIVE ONLY — nothing removed)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tf_mode_str_icon() =>
    is_intraday ? "INTRADAY" : is_swing ? "SWING" : "MANUAL"

ctx_line_icon() =>
    string s = ""
    s += "Close vs VWAP: " + (na(contextVwap) ? "-" : (close >= contextVwap ? "ABOVE" : "BELOW"))
    s += " | EMA20: " + (na(contextEma20) ? "-" : (close >= contextEma20 ? "ABOVE" : "BELOW"))
    s += " | SMA50: " + (na(contextSma50) ? "-" : (close >= contextSma50 ? "ABOVE" : "BELOW"))
    s

icon_meta(int t) =>
    string s = ""
    s += "Time: " + fmt_dt(t) + " | TZ: " + NY_TZ + " | Mode: " + tf_mode_str_icon() + "\n"
    s += "Context: " + ctx_line_icon() + "\n"
    s += "Celestial engine: " + EPHEMERIS_CREDIT + "\n"
    s += "Library: " + EPHEMERIS_LIBRARY + " | Rule: event = TIMING FILTER, not a signal.\n\n"
    s

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Icon Tooltips (ENHANCED — additive only)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sun_tip(int startT) =>
    int nSun = find_next_sign_change(startT, sun_sign_at(startT))
    [nSeasonT, nSeasonName] = find_next_seasonal(startT, sun_sign_at(startT))
    bool rxNow = show_mercury ? is_mer_rx_at(startT) : false
    int nMer = show_mercury ? find_next_mer_station(startT, rxNow) : na
    string nMerType = na(nMer) ? "-" : (rxNow ? "Station Direct (end Rx)" : "Station Retrograde (start Rx)")
    [nMoonT, nMoonType] = find_next_moon_event(startT)
    float eventSunLon = lon_at(SUN, startT)
    int eventSunSign = int(math.floor(eventSunLon / 30.0))
    string eventSunGlyph = array.get(zodiac_glyphs, eventSunSign)
    string eventSunName = array.get(zodiac_names, eventSunSign)
    string s = ""
    s += "☀️ SUN INGRESS\n"
    s += icon_meta(startT)
    s += "Now: " + eventSunGlyph + " " + eventSunName + " (≈" + str.tostring(eventSunLon, "#.##") + "°)"
    s += " | Decl: " + str.tostring(decl_at(SUN, startT), "#.##") + "°\n\n"
    s += "Education:\n• Sun advances 30° per sign = monthly vibration.\n• Gann: time segmentation + rhythm shift.\n\n"
    s += "Strategy:\n• Treat ±1–3 bars as decision window.\n• Confirm with VWAP/MAs + swing S/R + volume.\n\n"
    s += "What’s next:\n"
    s += "• Next ingress: " + (na(nSun) ? "-" : (fmt_dt(nSun) + " (" + fmt_dhm(nSun - startT) + ")")) + "\n"
    s += "• Next seasonal: " + (na(nSeasonT) ? "-" : (nSeasonName + " @ " + fmt_dt(nSeasonT) + " (" + fmt_dhm(nSeasonT - startT) + ")")) + "\n"
    s += "• Next Mercury station: " + (na(nMer) ? "-" : (nMerType + " @ " + fmt_dt(nMer) + " (" + fmt_dhm(nMer - startT) + ")")) + "\n"
    s += "• Next New/Full: " + (na(nMoonT) ? "-" : (nMoonType + " ~ " + fmt_dt(nMoonT) + " (" + fmt_dhm(nMoonT - startT) + ")"))
    s

season_tip(int startT) =>
    int eventSign = sun_sign_at(startT)
    string eventSeasonName = eventSign == 0 ? "March Equinox (0° Aries)" :
         eventSign == 3 ? "June Solstice (0° Cancer)" :
         eventSign == 6 ? "September Equinox (0° Libra)" :
         eventSign == 9 ? "December Solstice (0° Capricorn)" : "Seasonal Turn"
    [nSeasonT, nSeasonName] = find_next_seasonal(startT, eventSign)
    int nSun = find_next_sign_change(startT, eventSign)
    string s = ""
    s += "🧭 SEASONAL TURN\n" + eventSeasonName + "\n\n"
    s += icon_meta(startT)
    s += "Education:\n• Equinox/Solstice = quarter-year pivot (≈90° time division).\n\n"
    s += "Strategy:\n• Watch structure breaks / range expansion.\n• Tighten stops on extended legs.\n\n"
    s += "What’s next:\n"
    s += "• Next seasonal: " + (na(nSeasonT) ? "-" : (nSeasonName + " @ " + fmt_dt(nSeasonT) + " (" + fmt_dhm(nSeasonT - startT) + ")")) + "\n"
    s += "• Next ingress: " + (na(nSun) ? "-" : (fmt_dt(nSun) + " (" + fmt_dhm(nSun - startT) + ")"))
    s

mer_tip(int startT, bool isStart) =>
    bool rxNow = is_mer_rx_at(startT)
    int nMer = find_next_mer_station(startT, rxNow)
    string nMerType = na(nMer) ? "-" : (rxNow ? "Station Direct (end Rx)" : "Station Retrograde (start Rx)")
    [nSeasonT, nSeasonName] = find_next_seasonal(startT, sun_sign_at(startT))
    string s = ""
    if isStart
        s += "☿🔄 MERCURY STATION RETROGRADE\n\n"
    else
        s += "☿✅ MERCURY STATION DIRECT\n\n"
    s += icon_meta(startT)
    s += "Longitude: " + str.tostring(lon_at(MERC, startT), "#.##") + "°"
    s += " | Speed: " + str.tostring(mer_speed_at(startT), "#.####") + "°/day"
    s += " | Decl: " + str.tostring(decl_at(MERC, startT), "#.##") + "°\n\n"
    if isStart
        s += "Education:\n• Higher noise: whipsaws/false breaks increase.\n\nStrategy:\n• Cut size 30–50%.\n• Prefer mean-reversion.\n• Breakouts need confirmation.\n\n"
    else
        s += "Education:\n• Continuation improves; trend is cleaner.\n\nStrategy:\n• Restore normal sizing.\n• Breakouts regain reliability.\n\n"
    s += "What’s next:\n"
    s += "• Next station: " + (na(nMer) ? "-" : (nMerType + " @ " + fmt_dt(nMer) + " (" + fmt_dhm(nMer - startT) + ")")) + "\n"
    s += "• Next seasonal: " + (na(nSeasonT) ? "-" : (nSeasonName + " @ " + fmt_dt(nSeasonT) + " (" + fmt_dhm(nSeasonT - startT) + ")"))
    s

moon_tip_newfull(int startT, bool isNew) =>
    [nMoonT, nMoonType] = find_next_moon_event(startT)
    string s = ""
    if isNew
        s += "🌑 NEW MOON\n\n"
    else
        s += "🌕 FULL MOON\n\n"
    s += icon_meta(startT)
    s += "Moon lon: " + str.tostring(lon_at(MOON, startT), "#.##") + "°"
    s += " | Decl: " + str.tostring(decl_at(MOON, startT), "#.##") + "°\n"
    if show_lunar_nodes
        s += "Node axis: " + str.tostring(node_lon_at(startT), "#.##") + "° (" + node_type_in + ")\n"
    s += "\n"
    if isNew
        s += "Education:\n• Lunation reset.\n\nStrategy:\n• Look for initiations after compression; first pullback entries.\n\n"
    else
        s += "Education:\n• Cycle peak; reversal probability rises.\n\nStrategy:\n• Take profits on extensions; watch divergences.\n\n"
    s += "What’s next:\n• Next New/Full: " + (na(nMoonT) ? "-" : (nMoonType + " ~ " + fmt_dt(nMoonT) + " (" + fmt_dhm(nMoonT - startT) + ")"))
    s

moon_phase8_tip(int startT, int idx) =>
    int nxt = find_next_moon_phase8_change(startT, idx)
    int nextIdx = na(nxt) ? na : moon_phase8_idx_at(nxt)
    [nMoonT, nMoonType] = find_next_moon_event(startT)

    string nowName = array.get(moon_names, idx)
    string nowIcon = moon_icon(idx)
    string nextName = na(nextIdx) ? "-" : array.get(moon_names, nextIdx)
    string nextIcon = na(nextIdx) ? "" : moon_icon(nextIdx)

    string s = ""
    s += "🌙 MOON PHASE (8-Phase)\n"
    s += icon_meta(startT)
    s += "Now: " + nowIcon + " " + nowName + "\n"
    s += "Elongation: " + str.tostring(elong_at(startT), "#.##") + "°"
    s += " | Decl: " + str.tostring(decl_at(MOON, startT), "#.##") + "°\n"
    if show_lunar_nodes
        s += "Node phase: " + str.tostring(node_phase_at(startT), "#.##") + "° (" + node_type_in + ")\n"
    s += "\n"
    s += "Education:\n"
    s += "• Crescent → Quarter → Gibbous → Full → reverse.\n"
    s += "• Timing windows only; confirm with structure/VWAP.\n\n"
    s += "Strategy:\n"
    s += "• Quarters/Full = pause/reversal window bias.\n"
    s += "• Crescents/Gibbous = continuation window bias.\n\n"
    s += "What’s next:\n"
    s += "• Next phase: " + (na(nxt) ? "-" : (nextIcon + " " + nextName + " @ " + fmt_dt(nxt) + " (" + fmt_dhm(nxt - startT) + ")")) + "\n"
    s += "• Next New/Full: " + (na(nMoonT) ? "-" : (nMoonType + " ~ " + fmt_dt(nMoonT) + " (" + fmt_dhm(nMoonT - startT) + ")"))
    s

node_tip(int startT, bool isNorth) =>
    [nNodeT, nNodeType] = find_next_node_event_enabled(startT)
    float moonLon = lon_at(MOON, startT)
    float nodeLon = node_lon_at(startT)
    string s = ""
    s += isNorth ? "☊ NORTH NODE CROSSING\n\n" : "☋ SOUTH NODE CROSSING\n\n"
    s += icon_meta(startT)
    s += "Node model: " + node_type_in + "\n"
    s += "Moon longitude: " + str.tostring(moonLon, "#.##") + "°\n"
    s += "North-node longitude: " + str.tostring(nodeLon, "#.##") + "°\n"
    s += "Moon declination: " + str.tostring(decl_at(MOON, startT), "#.##") + "°\n\n"
    s += "Gann context:\n"
    s += "• Node crossings are timing windows tied to the Moon's orbital axis.\n"
    s += "• Treat the timestamp as a potential change in rhythm, not directional proof.\n\n"
    s += "Execution:\n"
    s += "• Confirm with price structure, VWAP acceptance/rejection, and volume.\n"
    s += "• Avoid predicting direction from the node crossing alone.\n\n"
    s += "What's next:\n"
    s += "• Next node crossing: " + (na(nNodeT) ? "-" : (nNodeType + " @ " + fmt_dt(nNodeT) + " (" + fmt_dhm(nNodeT - startT) + ")"))
    s

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Event Labels
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if sun_ingress_event and (bar_index - lastSunBar >= sun_spacing_bars)
    label l = label.new(xUseTime(stack, tSunIngr), yUseAbove(stack), sun_event_glyph,
        xloc=xloc.bar_time, yloc=ylocAbove(), style=label.style_circle, size=icon_size,
        color=color.new(color.yellow, 40), textcolor=color.white,
        tooltip=sun_tip(tSunIngr))
    track_event_label(l)
    lastSunBar := bar_index
    stack += 1

if season_event and (bar_index - lastSeasonBar >= season_spacing_bars)
    string seasonIcon = sun_event_idx == 0 ? "🌷" : sun_event_idx == 3 ? "☀️" : sun_event_idx == 6 ? "🍂" : "❄️"
    label l = label.new(xUseTime(stack, tSeason), yUseAbove(stack), seasonIcon,
        xloc=xloc.bar_time, yloc=ylocAbove(), style=label.style_none, size=icon_size,
        color=color.new(color.white, 100), textcolor=color.white,
        tooltip=season_tip(tSeason))
    track_event_label(l)
    lastSeasonBar := bar_index
    stack += 1

bool skip_nf_in_8phase = use_moon_8 and highlight_newfull_when_8phases_in and (moon_phase8_event_idx == 0 or moon_phase8_event_idx == 4)

if moon_phase8_event and not skip_nf_in_8phase and (bar_index - lastMoonBar >= moon_spacing_bars)
    string icon = moon_icon(moon_phase8_event_idx)
    bool waxing = moon_phase8_event_idx >= 0 and moon_phase8_event_idx <= 3
    bool useWw = moon_phase_layout_in == "Waxing Above / Waning Below"
    bool placeAbove = useWw ? waxing : true

    label l = label.new(xUseTime(stack, tMoon8),
        placeAbove ? yUseAbove(stack) : yUseBelow(stack),
        icon,
        xloc=xloc.bar_time, yloc=placeAbove ? ylocAbove() : ylocBelow(),
        style=label.style_none, size=icon_size,
        color=color.new(color.white, 100), textcolor=color.white,
        tooltip=moon_phase8_tip(tMoon8, moon_phase8_event_idx))
    track_event_label(l)

    lastMoonBar := bar_index
    stack += 1

bool allow_newfull_markers = show_moon and (use_moon_nf or (use_moon_8 and highlight_newfull_when_8phases_in))

if new_moon_event and allow_newfull_markers and (bar_index - lastMoonBar >= moon_spacing_bars)
    label l = label.new(xUseTime(stack, tNew), yUseAbove(stack), "🌑",
        xloc=xloc.bar_time, yloc=ylocAbove(), style=label.style_none, size=icon_size,
        color=color.new(color.white, 100), textcolor=color.white,
        tooltip=moon_tip_newfull(tNew, true))
    track_event_label(l)
    lastMoonBar := bar_index
    stack += 1

if full_moon_event and allow_newfull_markers and (bar_index - lastMoonBar >= moon_spacing_bars)
    label l = label.new(xUseTime(stack, tFull), yUseBelow(stack), "🌕",
        xloc=xloc.bar_time, yloc=ylocBelow(), style=label.style_none, size=icon_size,
        color=color.new(color.white, 100), textcolor=color.white,
        tooltip=moon_tip_newfull(tFull, false))
    track_event_label(l)
    lastMoonBar := bar_index
    stack += 1

if north_node_event and (bar_index - lastNodeBar >= node_spacing_bars)
    label l = label.new(xUseTime(stack, tNorthNode), yUseAbove(stack), "☊",
        xloc=xloc.bar_time, yloc=ylocAbove(), style=label.style_circle, size=icon_size,
        color=color.new(color.aqua, 35), textcolor=color.white,
        tooltip=node_tip(tNorthNode, true))
    track_event_label(l)
    lastNodeBar := bar_index
    stack += 1

if south_node_event and (bar_index - lastNodeBar >= node_spacing_bars)
    label l = label.new(xUseTime(stack, tSouthNode), yUseBelow(stack), "☋",
        xloc=xloc.bar_time, yloc=ylocBelow(), style=label.style_circle, size=icon_size,
        color=color.new(color.purple, 35), textcolor=color.white,
        tooltip=node_tip(tSouthNode, false))
    track_event_label(l)
    lastNodeBar := bar_index
    stack += 1

if mer_start and (bar_index - lastMerBar >= merc_spacing_bars)
    label l = label.new(xUseTime(stack, tMer), yUseAbove(stack), "☿🔄",
        xloc=xloc.bar_time, yloc=ylocAbove(), style=label.style_circle, size=icon_size,
        color=color.new(color.red, 40), textcolor=color.white,
        tooltip=mer_tip(tMer, true))
    track_event_label(l)
    lastMerBar := bar_index
    stack += 1

if mer_end and (bar_index - lastMerBar >= merc_spacing_bars)
    label l = label.new(xUseTime(stack, tMer), yUseAbove(stack), "☿✅",
        xloc=xloc.bar_time, yloc=ylocAbove(), style=label.style_circle, size=icon_size,
        color=color.new(color.green, 40), textcolor=color.white,
        tooltip=mer_tip(tMer, false))
    track_event_label(l)
    lastMerBar := bar_index
    stack += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Shading (matches event-time exact)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool _sun_in_bar    = sun_ingress_event and (tSunIngr >= time and tSunIngr <= _barCloseSafe)
bool _season_in_bar = season_event and (tSeason >= time and tSeason <= _barCloseSafe)
bool _new_in_bar    = new_moon_event and (tNew >= time and tNew <= _barCloseSafe)
bool _full_in_bar   = full_moon_event and (tFull >= time and tFull <= _barCloseSafe)

bgcolor(shade_mercury_rx and is_mer_rx ? color.new(color.red, 92) : na)
bgcolor(shade_season_bar and _season_in_bar ? color.new(color.white, 92) : na)
bgcolor(shade_sun_ingress and _sun_in_bar ? color.new(color.yellow, 93) : na)
bgcolor(shade_moon_event and (_new_in_bar or _full_in_bar) ? color.new(_full_in_bar ? color.orange : color.blue, 92) : na)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE TOOLTIP PLAYBOOKS (UPDATED — HARDCORE EXECUTION)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
compact_tt(string s) =>
    str.trim(str.replace_all(str.replace_all(s, "\n\n\n", "\n\n"), "\n\n", "\n"))

tf_mode_str() =>
    is_intraday ? "INTRADAY" : is_swing ? "SWING" : "MANUAL"

risk_playbook_header() =>
    string s = ""
    s += "MODE: " + tf_mode_str() + " | Chart TZ: " + NY_TZ + "\n"
    s += "Celestial engine: " + EPHEMERIS_CREDIT + "\n"
    s += "Library: " + EPHEMERIS_LIBRARY + " | License: " + EPHEMERIS_LICENSE + "\n"
    s += "Priority stack (always):\n"
    s += "1) Market structure (swing H/L)  2) VWAP / value  3) Event timing\n"
    s += "Execution rule: event = TIMING FILTER, not a signal.\n\n"
    s

status_tip_sun_now(int startT, int nSun, int nSeasonT, string nSeasonName,
     int nMer, string nMerType, int nMoonT, string nMoonType) =>
    float L = lon_at(SUN, startT)
    float degInSign = L - (math.floor(L / 30.0) * 30.0)

    string s = ""
    s += "☀️ SUN STATE (MONTHLY VIBRATION)\n"
    s += risk_playbook_header()
    s += "Now: " + sun_glyph + " " + sun_name + " | Lon: " + str.tostring(L, "#.##") + "°  (+" + str.tostring(degInSign, "#.##") + "° in sign)\n\n"

    s += "WHAT THIS MEANS (GANN LOGIC):\n"
    s += "• Ingress = a hard time-partition (30° step) → rhythm/volatility can re-price.\n"
    s += "• Best use: define a DECISION WINDOW, then trade structure inside that window.\n\n"

    s += "INTRADAY PLAYBOOK:\n"
    s += "• Window: the bar of ingress + next 2–6 bars (depends on TF).\n"
    s += "• Expectation: first impulse often tests liquidity (prior H/L, session VWAP bands).\n"
    s += "• What to look for:\n"
    s += "  - Break + HOLD above VWAP = continuation bias.\n"
    s += "  - Break + FAIL (reclaim VWAP) = mean-reversion bias.\n"
    s += "  - Opening range break after ingress = cleanest entry trigger.\n"
    s += "• Execution:\n"
    s += "  - Mark: prior day H/L + session VWAP + first hour range.\n"
    s += "  - Entry only after structure confirms (higher-low or lower-high on your swing chart).\n"
    s += "  - Stops: beyond last swing pivot; size down into event bars.\n\n"

    s += "SWING PLAYBOOK:\n"
    s += "• Window: ±1–3 bars around the timestamp on Daily/Weekly.\n"
    s += "• What to look for:\n"
    s += "  - Trend continuation: pullback holds prior swing + reclaims key MAs.\n"
    s += "  - Trend reversal: weekly rejection / failed breakout + distribution volume.\n"
    s += "• Execution:\n"
    s += "  - Add only on retest-confirmation, not the first break.\n"
    s += "  - Use multi-timeframe swing points; never ignore the higher TF pivot.\n\n"

    s += "WHAT’S NEXT (TIMERS):\n"
    s += "• Next ingress: " + (na(nSun) ? "-" : (fmt_dt(nSun) + " (" + fmt_dhm(nSun - startT) + ")")) + "\n"
    s += "• Next seasonal: " + (na(nSeasonT) ? "-" : (nSeasonName + " @ " + fmt_dt(nSeasonT) + " (" + fmt_dhm(nSeasonT - startT) + ")")) + "\n"
    s += "• Next Mercury station: " + (na(nMer) ? "-" : (nMerType + " @ " + fmt_dt(nMer) + " (" + fmt_dhm(nMer - startT) + ")")) + "\n"
    s += "• Next New/Full: " + (na(nMoonT) ? "-" : (nMoonType + " ~ " + fmt_dt(nMoonT) + " (" + fmt_dhm(nMoonT - startT) + ")"))
    s

status_tip_mercury_now(int startT, bool rxNow, int nMer, string nMerType) =>
    string s = ""
    s += "☿ MERCURY STATE (NOISE / WHIPSAW REGIME)\n"
    s += risk_playbook_header()
    s += "Now: " + (rxNow ? "RETROGRADE" : "DIRECT")
    s += " | Speed: " + str.tostring(mer_speed_at(startT), "#.####") + "°/day"
    s += " | Decl: " + str.tostring(decl_at(MERC, startT), "#.##") + "°\n\n"

    s += "WHAT THIS MEANS:\n"
    s += "• Retrograde = higher fakeout rate, more stop-runs, more mean-reversion.\n"
    s += "• Direct = trend-following improves, continuation legs travel cleaner.\n\n"

    s += "INTRADAY PLAYBOOK:\n"
    if rxNow
        s += "• DO:\n"
        s += "  - Reduce size; keep risk constant by widening logic not leverage.\n"
        s += "  - Fade extremes back to VWAP (when structure agrees).\n"
        s += "  - Trade ranges: buy support/sell resistance with confirmation.\n"
        s += "• DON’T:\n"
        s += "  - Chase first breakouts. Require break + retest + hold.\n"
        s += "  - Assume news impulse will trend; expect snapbacks.\n\n"
    else
        s += "• DO:\n"
        s += "  - Trade breakouts with retest confirmation.\n"
        s += "  - Let winners run; trail under swing lows/highs.\n"
        s += "• DON’T:\n"
        s += "  - Over-filter; direct periods reward clean momentum.\n\n"

    s += "SWING PLAYBOOK:\n"
    if rxNow
        s += "• Prefer: partial profits sooner, tighter add rules.\n"
        s += "• Signals that matter: weekly rejection candles, failed breakouts, distribution volume.\n"
        s += "• Best trades: reversion back to weekly value after exhaustion.\n\n"
    else
        s += "• Prefer: trend continuation trades and break + hold structures.\n"
        s += "• Best trades: retest holds of major levels; pyramiding after confirmation.\n\n"

    s += "WHAT TO WATCH RIGHT NOW:\n"
    s += "• VWAP reclaim vs VWAP rejection.\n"
    s += "• Liquidity runs of prior day/week highs/lows.\n"
    s += "• Compression → expansion sequence (breakout quality changes by regime).\n\n"

    s += "WHAT’S NEXT:\n"
    s += "• Next station: " + (na(nMer) ? "-" : (nMerType + " @ " + fmt_dt(nMer) + " (" + fmt_dhm(nMer - startT) + ")"))
    show_mercury ? s : "☿ MERCURY STATUS\n\nMercury display is OFF."

status_tip_moon_now(int startT, int idx, int nMoonT, string nMoonType,
     int nPh, int nIdx, int nNodeT, string nNodeType) =>
    if not show_moon
        "🌙 MOON STATUS\n\nMoon Display is OFF."
    else
        string nowName = array.get(moon_names, idx)
        string nowIco  = moon_icon(idx)
        float E = elong_at(startT)

        string s = ""
        s += "🌙 MOON STATE (SHORT-CYCLE TIMING)\n"
        s += risk_playbook_header()
        s += "Now: " + (use_moon_8 ? (nowIco + " " + nowName) : (E < 180 ? "Waxing → Full" : "Waning → New")) + "\n"
        s += "Elongation: " + str.tostring(E, "#.##") + "°"
        s += " | Decl: " + str.tostring(decl_at(MOON, startT), "#.##") + "°\n"
        if show_lunar_nodes
            s += "Node phase: " + str.tostring(node_phase_at(startT), "#.##") + "° (" + node_type_in + ")\n"
        s += "\n"

        s += "WHAT THIS MEANS:\n"
        s += "• Moon is a volatility/timing filter — it does NOT override structure.\n"
        s += "• Use it to anticipate WHEN price is most likely to test key levels.\n\n"

        s += "PHASE BEHAVIOR (PRACTICAL):\n"
        s += "• New → Waxing: initiation / early trend building.\n"
        s += "• 1st Quarter: decision point (pause, rotate, or accelerate).\n"
        s += "• Full: peak / exhaustion window (profit-taking + reversals show up).\n"
        s += "• Last Quarter: secondary decision point (trend resumes or flips).\n\n"

        s += "INTRADAY PLAYBOOK:\n"
        s += "• Use the phase window to choose the RIGHT trade type:\n"
        s += "  - Near Full/Quarters: fade extremes + tighten targets.\n"
        s += "  - Near Crescents/Gibbous: trend continuation after pullback.\n"
        s += "• What to look for:\n"
        s += "  - Divergence at key level (momentum stalls) = reversal fuel.\n"
        s += "  - Clean pullback to VWAP/MA with higher-low = continuation entry.\n\n"

        s += "SWING PLAYBOOK:\n"
        s += "• Near Full: reduce risk on extended positions; stop gets tighter.\n"
        s += "• Near New: watch for new leg to start from base after accumulation.\n"
        s += "• Confirmation must be from Weekly/Daily swing pivots.\n\n"

        s += "WHAT’S NEXT:\n"
        if use_moon_8
            s += "• Next phase: " + (na(nPh) ? "-" : (moon_icon(nIdx) + " " + array.get(moon_names, nIdx) + " @ " + fmt_dt(nPh) + " (" + fmt_dhm(nPh - startT) + ")")) + "\n"
        s += "• Next New/Full: " + (na(nMoonT) ? "-" : (nMoonType + " ~ " + fmt_dt(nMoonT) + " (" + fmt_dhm(nMoonT - startT) + ")"))
        if show_lunar_nodes
            s += "\n• Next node: " + (na(nNodeT) ? "-" : (nNodeType + " @ " + fmt_dt(nNodeT) + " (" + fmt_dhm(nNodeT - startT) + ")"))
        s

status_tip_next_sun(int startT, int nSun) =>
    string s = ""
    s += "NEXT SUN INGRESS (PREP WINDOW)\n"
    s += risk_playbook_header()
    s += "Next time: " + (na(nSun) ? "-" : (fmt_dt(nSun) + " (" + fmt_dhm(nSun - startT) + ")")) + "\n\n"
    s += "WHAT TO DO BEFORE IT HITS:\n"
    s += "• Mark: prior swing H/L, prior day/week H/L, VWAP + value area.\n"
    s += "• Decide: are you in trend mode or range mode right now?\n\n"
    s += "EXECUTION PLAN:\n"
    s += "• Into the timestamp: reduce size; don’t add on first impulse.\n"
    s += "• After the timestamp:\n"
    s += "  - Break + hold = continuation.\n"
    s += "  - Break + fail (reclaim) = reversion.\n"
    s += "• The only “A+” entry is structure confirmation (HL/LH) after the event.\n"
    s

status_tip_next_season(int startT, int nSeasonT, string nSeasonName) =>
    string s = ""
    s += "NEXT SEASONAL TURN (MAJOR TIME QUARTER)\n"
    s += risk_playbook_header()
    s += "Next: " + (na(nSeasonT) ? "-" : (nSeasonName + " @ " + fmt_dt(nSeasonT) + " (" + fmt_dhm(nSeasonT - startT) + ")")) + "\n\n"
    s += "WHAT THIS MEANS:\n"
    s += "• Seasonal turns are higher-grade cycle pivots (90° time division).\n"
    s += "• Expect bigger tests of weekly levels and broader volatility change.\n\n"
    s += "EXECUTION PLAN:\n"
    s += "• Swing traders: tighten risk on stretched legs; focus on weekly pivots.\n"
    s += "• Intraday: expect liquidity runs + range expansion; trade confirmation only.\n"
    s += "• Confirmation: weekly rejection / acceptance at value, not feelings.\n"
    s

status_tip_next_mer(int startT, int nMer, string nMerType) =>
    string s = ""
    s += "NEXT MERCURY STATION (REGIME SHIFT)\n"
    s += risk_playbook_header()
    s += "Next: " + (na(nMer) ? "-" : (nMerType + " @ " + fmt_dt(nMer) + " (" + fmt_dhm(nMer - startT) + ")")) + "\n\n"
    s += "WHAT TO EXPECT:\n"
    s += "• Station = transition window: signals can flip quality.\n"
    s += "• Start Rx: more fakeouts/mean reversion.\n"
    s += "• End Rx: trend clarity improves.\n\n"
    s += "EXECUTION PLAN:\n"
    s += "• 24–72h around station: reduce size, wait for confirmation.\n"
    s += "• Breakouts require retest + hold; otherwise treat as liquidity sweep.\n"
    show_mercury ? s : "NEXT MERCURY STATION\n\nMercury display is OFF."

status_tip_next_node(int startT, int nNodeT, string nNodeType) =>
    if not show_lunar_nodes
        "NEXT LUNAR NODE\n\nLunar node crossings are OFF."
    else
        string s = ""
        s += "NEXT LUNAR NODE CROSSING\n"
        s += risk_playbook_header()
        s += "Node model: " + node_type_in + "\n"
        s += "Next: " + (na(nNodeT) ? "-" : (nNodeType + " @ " + fmt_dt(nNodeT) + " (" + fmt_dhm(nNodeT - startT) + ")")) + "\n\n"
        s += "EXECUTION PLAN:\n"
        s += "• Treat the crossing as a timing window, not directional proof.\n"
        s += "• Confirm with structure, VWAP acceptance/rejection, and volume.\n"
        s

status_tip_next_moon(int startT, int nMoonT, string nMoonType,
     int nPh, int nIdx, int nNodeT, string nNodeType) =>
    if not show_moon
        "NEXT MOON TIMING\n\nMoon Display is OFF."
    else
        string s = ""
        s += "NEXT MOON WINDOW (TIMING FILTER)\n"
        s += risk_playbook_header()

        if use_moon_8
            s += "Next phase: " + (na(nPh) ? "-" : (moon_icon(nIdx) + " " + array.get(moon_names, nIdx) + " @ " + fmt_dt(nPh) + " (" + fmt_dhm(nPh - startT) + ")")) + "\n\n"
            s += "Phase meaning:\n"
            s += "• Crescents/Gibbous = continuation bias.\n"
            s += "• Quarters/Full = decision/reversal bias.\n\n"

        s += "Next New/Full: " + (na(nMoonT) ? "-" : (nMoonType + " ~ " + fmt_dt(nMoonT) + " (" + fmt_dhm(nMoonT - startT) + ")")) + "\n"
        if show_lunar_nodes
            s += "Next node: " + (na(nNodeT) ? "-" : (nNodeType + " @ " + fmt_dt(nNodeT) + " (" + fmt_dhm(nNodeT - startT) + ")")) + "\n"
        s += "\nEXECUTION PLAN:\n"
        s += "• Near Full/New: focus on key level tests and divergences.\n"
        s += "• Don’t pre-guess direction — wait for structure confirmation.\n"
        s

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Status table (HORIZONTAL + COMPACT)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table status = na
if barstate.isfirst and show_status
    status := table.new(table_pos_const, 8, 2, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 70))

var int _last_status_bar = na
int _lsb = na(_last_status_bar) ? -1 : _last_status_bar
bool do_status_update = show_status and barstate.islast and (live_status_updates or barstate.isconfirmed or bar_index != _lsb)

if do_status_update and not na(status)
    _last_status_bar := bar_index

    // Reuse the realtime-safe astronomical calculation timestamp.
    int startT = _calcTime

    int nSun = find_next_sign_change(startT, sun_sign_idx)
    bool rxNow = show_mercury ? is_mer_rx_at(startT) : false
    int nMer = show_mercury ? find_next_mer_station(startT, rxNow) : na
    string nMerType = na(nMer) ? "-" : (rxNow ? "Station Direct" : "Station Retrograde")

    [nSeasonT, nSeasonName] = find_next_seasonal(startT, sun_sign_idx)

    int idx = moon_phase8_idx_at(startT)
    int nPh = show_moon and use_moon_8 ? find_next_moon_phase8_change(startT, idx) : na
    int nIdx = na(nPh) ? na : moon_phase8_idx_at(nPh)
    [nMoonT, nMoonType] = find_next_moon_event_enabled(startT)
    [nNodeT, nNodeType] = find_next_node_event_enabled(startT)

    string ttSunNow = compact_tt(status_tip_sun_now(
         startT, nSun, nSeasonT, nSeasonName, nMer, nMerType, nMoonT, nMoonType))
    string ttMerNow = compact_tt(status_tip_mercury_now(startT, rxNow, nMer, nMerType))
    string ttMoonNow = compact_tt(status_tip_moon_now(
         startT, idx, nMoonT, nMoonType, nPh, nIdx, nNodeT, nNodeType))
    string ttNSun = compact_tt(status_tip_next_sun(startT, nSun))
    string ttNSeason = compact_tt(status_tip_next_season(startT, nSeasonT, nSeasonName))
    string ttNMer = compact_tt(status_tip_next_mer(startT, nMer, nMerType))
    string ttNMoon = compact_tt(status_tip_next_moon(
         startT, nMoonT, nMoonType, nPh, nIdx, nNodeT, nNodeType))
    string ttNNode = compact_tt(status_tip_next_node(startT, nNodeT, nNodeType))

    table.cell(status, 0, 0, "Sun",       text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttSunNow)
    table.cell(status, 1, 0, "Merc",      text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttMerNow)
    table.cell(status, 2, 0, "Moon",      text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttMoonNow)
    table.cell(status, 3, 0, "Next Ingr", text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttNSun)
    table.cell(status, 4, 0, "Next Seas", text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttNSeason)
    table.cell(status, 5, 0, "Next ☿",    text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttNMer)
    table.cell(status, 6, 0, "Next Moon", text_color=color.white, text_size=info_table_text_size, bgcolor=color.new(color.blue, 78), tooltip=ttNMoon)
    table.cell(status, 7, 0, show_lunar_nodes ? "Next Node" : "", text_color=color.white, text_size=info_table_text_size,
         bgcolor=show_lunar_nodes ? color.new(color.blue, 78) : na, tooltip=ttNNode)

    table.cell(status, 0, 1, sun_glyph + " " + sun_name, text_color=color.yellow, text_size=info_table_text_size, tooltip=ttSunNow)
    string mercCell = not show_mercury ? "Off" : is_mer_rx ? "Rx" : "Dir"
    color mercColor = not show_mercury ? color.gray : is_mer_rx ? color.red : color.green
    table.cell(status, 1, 1, mercCell, text_color=mercColor, text_size=info_table_text_size, tooltip=ttMerNow)

    string moonCell = ""
    if not show_moon
        moonCell := "Off"
    else
        if use_moon_8
            moonCell := moon_icon(idx) + " " + array.get(moon_short, idx)
        else
            moonCell := elong_at(startT) < 180 ? "Wax→Full" : "Wan→New"
    table.cell(status, 2, 1, moonCell, text_color=color.white, text_size=info_table_text_size, tooltip=ttMoonNow)

    string nextIngr = na(nSun) ? "-" : fmt_dt_compact(nSun)
    table.cell(status, 3, 1, nextIngr, text_color=color.white, text_size=info_table_text_size, tooltip=ttNSun)

    string nextSeas = na(nSeasonT) ? "-" : (str.substring(nSeasonName, 0, 5) + " " + fmt_dt_compact(nSeasonT))
    table.cell(status, 4, 1, nextSeas, text_color=color.white, text_size=info_table_text_size, tooltip=ttNSeason)

    string nextMer = na(nMer) ? "-" : (nMerType + " " + fmt_dt_compact(nMer))
    table.cell(status, 5, 1, nextMer, text_color=color.white, text_size=info_table_text_size, tooltip=ttNMer)

    string nextMoon = "-"
    if show_moon
        if use_moon_8
            nextMoon := na(nPh) ? "-" : (moon_icon(nIdx) + " " + fmt_dt_compact(nPh))
        else
            string nfIcon = nMoonType == "New Moon" ? "🌑" : nMoonType == "Full Moon" ? "🌕" : "🌙"
            nextMoon := na(nMoonT) ? "-" : (nfIcon + " " + fmt_dt_compact(nMoonT))
    table.cell(status, 6, 1, nextMoon, text_color=color.white, text_size=info_table_text_size, tooltip=ttNMoon)

    string nextNode = ""
    if show_lunar_nodes
        string nodeIcon = nNodeType == "North Node" ? "☊" : nNodeType == "South Node" ? "☋" : "☌"
        nextNode := na(nNodeT) ? "-" : (nodeIcon + " " + fmt_dt_compact(nNodeT))
    table.cell(status, 7, 1, nextNode, text_color=show_lunar_nodes ? color.aqua : color.gray,
         text_size=info_table_text_size, bgcolor=show_lunar_nodes ? na : color.new(color.black, 100), tooltip=ttNNode)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool alert_gate = not alerts_confirmed_only or barstate.isconfirmed

alertcondition(sun_ingress_event and alert_gate,
     title="Gann Celestial — Sun Ingress",
     message="BK AK-Gann Celestial Cycle: Sun ingress reached on {{ticker}} {{interval}}.")

alertcondition(season_event and alert_gate,
     title="Gann Celestial — Seasonal Turn",
     message="BK AK-Gann Celestial Cycle: Equinox/Solstice timing window reached on {{ticker}} {{interval}}.")

alertcondition(new_moon_event and alert_gate,
     title="Gann Celestial — New Moon",
     message="BK AK-Gann Celestial Cycle: New Moon timing window reached on {{ticker}} {{interval}}.")

alertcondition(full_moon_event and alert_gate,
     title="Gann Celestial — Full Moon",
     message="BK AK-Gann Celestial Cycle: Full Moon timing window reached on {{ticker}} {{interval}}.")

alertcondition(moon_phase8_event and alert_gate,
     title="Gann Celestial — 8-Phase Moon Change",
     message="BK AK-Gann Celestial Cycle: Moon entered the next 45-degree phase on {{ticker}} {{interval}}.")

alertcondition(mer_start and alert_gate,
     title="Gann Celestial — Mercury Station Retrograde",
     message="BK AK-Gann Celestial Cycle: Mercury stationed retrograde on {{ticker}} {{interval}}.")

alertcondition(mer_end and alert_gate,
     title="Gann Celestial — Mercury Station Direct",
     message="BK AK-Gann Celestial Cycle: Mercury stationed direct on {{ticker}} {{interval}}.")

alertcondition(north_node_event and alert_gate,
     title="Gann Celestial — North Node Crossing",
     message="BK AK-Gann Celestial Cycle: Moon crossed the selected North Node on {{ticker}} {{interval}}.")

alertcondition(south_node_event and alert_gate,
     title="Gann Celestial — South Node Crossing",
     message="BK AK-Gann Celestial Cycle: Moon crossed the selected South Node on {{ticker}} {{interval}}.")
````
