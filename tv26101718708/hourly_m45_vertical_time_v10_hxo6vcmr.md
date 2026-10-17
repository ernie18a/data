# Hourly + M45 Vertical Time V1.0

- url: https://www.tradingview.com/script/HxO6vCmr-Hourly-M45-Vertical-Time-V1-0/
- type: indicator
- pine_id: PUB;7e697105118e440babba1e9a744c5ee6
- version: 1.0

## Description

Hourly + M45 Vertical Time V1.0

Hourly + M45 Vertical Time is a visual intraday timing and market-structure indicator designed to make hourly transitions easier to identify while providing advance notice of the upcoming H1 open.

The indicator marks each hourly (:00) open with a vertical line and optional timestamp. It can also mark :45 of every hour, providing a visual 15-minute warning before the next hourly candle begins.

In addition to time markers, the indicator identifies the nearest confirmed swing high and swing low leading into each H1 open, allowing traders to quickly see nearby pre-hour market structure and potential liquidity levels.

KEY FEATURES

H1 Hourly Markers

Vertical line at every hourly :00
Optional hourly timestamp
12-hour or 24-hour time format
Timestamp placement at Bottom, Center, or Top
Adjustable line color, width, and style
Solid, dashed, or dotted lines

M45 — 15-Minute Warning

Optional vertical line at :45 of every hour
Serves as a visual warning that the next H1 candle is 15 minutes away
Independent color, width, and line style
Four label choices:
Full time — 7:45am
Minimal — :45
Countdown — 15m
None — line only

Pre-H1 Swing Identification

Identifies the nearest confirmed swing high and confirmed swing low leading into the H1 open
Marker is placed on the actual candle where the swing occurred, rather than the later candle where the pivot becomes confirmed
Display both swings, high only, or low only
Adjustable swing strength
Selectable search window:
Current Hour
Last 90 Minutes
Last 2 Hours
Choose triangle or dot markers
Independent colors and sizes for swing highs and swing lows
▼ identifies a confirmed swing high
▲ identifies a confirmed swing low

Time Zone Control

New York — Eastern Time
Chicago — Central Time
Uses DST-aware time zones so daylight-saving changes are handled automatically

Alerts

H1 Hourly Open alert
M45 / 15 Minutes Until Next H1 alert
DEFAULT CONCEPT

The indicator is designed around a simple visual sequence:

Previous H1                         Next H1
     │                                │
     │       ▼ Swing High             │
     │          /\                    │
     │         /  \                   │
     │        /    \        :45       │
     │              \        ┊        │
     │               \       ┊        │
     │                \_/    ┊        │
     │                 ▲     ┊        │
     │             Swing Low ┊        │
     │                       ┊        │
    7am                    7:45      8am

The H1 line is the primary time reference.

The M45 line acts as the advance warning.

The swing markers provide market-structure context leading into the next hourly open.

IMPORTANT SWING LOGIC

Swing markers represent confirmed pivots, not simply the highest and lowest candle of the hour.

A swing requires candles on both sides of the potential pivot. Because of this, a swing is only identified after sufficient price action exists to confirm it.

Once confirmed, the marker is placed back on the original swing candle.

Increasing Swing Strength produces fewer, more significant pivots. Decreasing Swing Strength makes the indicator more sensitive and identifies smaller market swings.

SUGGESTED STARTING SETTINGS

For your initial testing on the 4-minute chart, I'd use:

Time Zone:             Chicago (Central)
Time Format:           12 Hour
Timestamp Position:    Bottom

H1 Markers:            ON
H1 Style:              Dashed

M45 Markers:           ON
M45 Style:             Dotted
M45 Label:             :45

Pre-H1 Swings:         ON
Swing Strength:        2
Swing Search Window:   Current Hour
Swing Display:         Both High + Low
Marker Shape:          Triangle

One distinction I want to preserve as we develop this indicator: the swing feature is contextual—it doesn't by itself declare that a swing will be swept, reversed from, or traded. It's showing you where the most recent confirmed structure was before H1 so you can combine that information with your own trading model.

That gives Hourly + M45 Vertical Time V1.0 a very clear job:

TIME → WARNING → STRUCTURE → H1

## Source Code

````pine
//@version=6
indicator("Hourly + M45 Vertical Time V1.0", shorttitle="H1 + M45 Time V1.0",
     overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// HOURLY + M45 VERTICAL TIME — V1.0
//
// FEATURES
// - H1 (:00) vertical time markers
// - M45 (:45) 15-minute warning markers
// - Eastern / Central DST-aware timezone selection
// - 12-hour / 24-hour time display
// - Bottom / Center / Top timestamp positioning
// - Independent H1 and M45 line styling
// - M45 labels: Full Time / :45 / 15m / None
// - H1 and M45 alerts
// - Pre-H1 confirmed swing high / swing low identification
// - Swing search windows: Current Hour / Last 90 Minutes / Last 2 Hours
// - Adjustable swing strength
// - Circle or triangle swing markers
// - Independent high/low colors and sizes
// ============================================================================


// ============================================================================
// 1. TIME SETTINGS
// ============================================================================

groupTime = "1. Time Settings"

showH1 = input.bool(true, "Show Hourly (:00) Markers", group=groupTime)
showM45 = input.bool(true, "Show M45 (:45) Markers", group=groupTime)

timezoneChoice = input.string(
     "Chicago (Central)",
     "Time Zone",
     options=["New York (Eastern)", "Chicago (Central)"],
     group=groupTime)

timeFormat = input.string(
     "12 Hour",
     "Time Format",
     options=["12 Hour", "24 Hour"],
     group=groupTime)

labelPosition = input.string(
     "Bottom",
     "Timestamp Position",
     options=["Bottom", "Center", "Top"],
     group=groupTime)

string selectedTZ =
     timezoneChoice == "New York (Eastern)" ?
     "America/New_York" :
     "America/Chicago"


// ============================================================================
// 2. H1 (:00) STYLE
// ============================================================================

groupH1 = "2. H1 (:00) Style"

h1Color = input.color(
     color.new(color.gray, 25),
     "H1 Line Color",
     group=groupH1)

h1StyleInput = input.string(
     "Dashed",
     "H1 Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupH1)

h1Width = input.int(
     1,
     "H1 Line Width",
     minval=1,
     maxval=4,
     group=groupH1)

showH1Label = input.bool(
     true,
     "Show H1 Timestamp",
     group=groupH1)

h1LabelColor = input.color(
     color.black,
     "H1 Timestamp Color",
     group=groupH1)

h1LabelSizeInput = input.string(
     "Normal",
     "H1 Timestamp Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupH1)


// ============================================================================
// 3. M45 (:45) STYLE
// ============================================================================

groupM45 = "3. M45 (:45) Style"

m45Color = input.color(
     color.new(color.gray, 65),
     "M45 Line Color",
     group=groupM45)

m45StyleInput = input.string(
     "Dotted",
     "M45 Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group=groupM45)

m45Width = input.int(
     1,
     "M45 Line Width",
     minval=1,
     maxval=4,
     group=groupM45)

m45LabelStyle = input.string(
     ":45",
     "M45 Label Style",
     options=["Full Time", ":45", "15m", "None"],
     group=groupM45)

m45LabelColor = input.color(
     color.new(color.gray, 10),
     "M45 Label Color",
     group=groupM45)

m45LabelSizeInput = input.string(
     "Small",
     "M45 Label Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupM45)


// ============================================================================
// 4. PRE-H1 SWING MARKERS
// ============================================================================

groupSwing = "4. Pre-H1 Swing Markers"

showSwings = input.bool(
     true,
     "Show Pre-H1 Swings",
     group=groupSwing)

swingDisplay = input.string(
     "Both High + Low",
     "Show Swing Markers",
     options=["Both High + Low", "High Only", "Low Only"],
     group=groupSwing)

swingStrength = input.int(
     2,
     "Swing Strength",
     minval=1,
     maxval=10,
     tooltip="Number of candles required on each side of a pivot. Higher values identify stronger, less frequent swings.",
     group=groupSwing)

swingSearchWindow = input.string(
     "Current Hour",
     "Swing Search Window",
     options=["Current Hour", "Last 90 Minutes", "Last 2 Hours"],
     tooltip="Controls how far before each H1 open the indicator may search for the nearest confirmed swing high and low.",
     group=groupSwing)

swingShape = input.string(
     "Triangle",
     "Marker Shape",
     options=["Triangle", "Circle"],
     group=groupSwing)

swingHighColor = input.color(
     color.red,
     "Swing High Color",
     group=groupSwing)

swingLowColor = input.color(
     color.lime,
     "Swing Low Color",
     group=groupSwing)

swingHighSizeInput = input.string(
     "Small",
     "Swing High Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupSwing)

swingLowSizeInput = input.string(
     "Small",
     "Swing Low Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupSwing)


// ============================================================================
// 5. DISPLAY
// ============================================================================

groupDisplay = "5. Display"

historyDays = input.int(
     5,
     "Historical Days To Display",
     minval=1,
     maxval=10,
     tooltip="Limits how far back H1, M45 and finalized swing markers are drawn.",
     group=groupDisplay)


// ============================================================================
// 6. ALERTS
// ============================================================================

groupAlerts = "6. Alerts"

enableH1Alert = input.bool(
     true,
     "Enable H1 Alert Condition",
     group=groupAlerts)

enableM45Alert = input.bool(
     true,
     "Enable M45 / 15-Minute Warning",
     group=groupAlerts)


// ============================================================================
// 7. HELPER FUNCTIONS
// ============================================================================

f_lineStyle(string styleInput) =>
    switch styleInput
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted


f_labelSize(string sizeInput) =>
    switch sizeInput
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal


f_markerSize(string sizeInput) =>
    switch sizeInput
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal


f_hourText(int hr) =>
    string result = ""

    if timeFormat == "24 Hour"
        result := str.tostring(hr, "00") + ":00"
    else
        int displayHour = hr % 12
        displayHour := displayHour == 0 ? 12 : displayHour
        string suffix = hr < 12 ? "am" : "pm"
        result := str.tostring(displayHour) + suffix

    result


f_m45FullText(int hr) =>
    string result = ""

    if timeFormat == "24 Hour"
        result := str.tostring(hr, "00") + ":45"
    else
        int displayHour = hr % 12
        displayHour := displayHour == 0 ? 12 : displayHour
        string suffix = hr < 12 ? "am" : "pm"
        result := str.tostring(displayHour) + ":45" + suffix

    result


f_m45Text(int hr) =>
    switch m45LabelStyle
        "Full Time" => f_m45FullText(hr)
        ":45"       => ":45"
        "15m"       => "15m"
        => ""


f_timestampLabelStyle() =>
    switch labelPosition
        "Top"    => label.style_label_down
        "Center" => label.style_none
        => label.style_label_up


// Search window in milliseconds.
f_searchWindowMs() =>
    switch swingSearchWindow
        "Last 90 Minutes" => 90 * 60 * 1000
        "Last 2 Hours"    => 120 * 60 * 1000
        => 60 * 60 * 1000


// ============================================================================
// 8. CONVERT INPUT SETTINGS
// ============================================================================

h1LineStyle = f_lineStyle(h1StyleInput)
m45LineStyle = f_lineStyle(m45StyleInput)

h1LabelSize = f_labelSize(h1LabelSizeInput)
m45LabelSize = f_labelSize(m45LabelSizeInput)

swingHighSize = f_markerSize(swingHighSizeInput)
swingLowSize = f_markerSize(swingLowSizeInput)

int swingWindowMs = f_searchWindowMs()


// ============================================================================
// 9. TIME / EVENT DETECTION
// ============================================================================

int localHour = hour(time, selectedTZ)
int currentYear = year(time, selectedTZ)
int currentMonth = month(time, selectedTZ)
int currentDay = dayofmonth(time, selectedTZ)

int thisHourTimestamp = timestamp(
     selectedTZ,
     currentYear,
     currentMonth,
     currentDay,
     localHour,
     0)

int thisM45Timestamp = timestamp(
     selectedTZ,
     currentYear,
     currentMonth,
     currentDay,
     localHour,
     45)


// Detect when target timestamp occurs inside the chart bar.
bool crossesH1 =
     time <= thisHourTimestamp and
     time_close > thisHourTimestamp

bool crossesM45 =
     time <= thisM45Timestamp and
     time_close > thisM45Timestamp

bool newH1Event =
     crossesH1 and not crossesH1[1]

bool newM45Event =
     crossesM45 and not crossesM45[1]


// ============================================================================
// 10. HISTORY FILTER
// ============================================================================

int historyMilliseconds =
     historyDays * 24 * 60 * 60 * 1000

bool insideHistory =
     time >= timenow - historyMilliseconds


// ============================================================================
// 11. TIMESTAMP LABEL Y POSITION
// ============================================================================

float barRange =
     math.max(high - low, syminfo.mintick * 10)

f_timestampY() =>
    switch labelPosition
        "Top"    => high + barRange * 2.0
        "Center" => hl2
        => low - barRange * 2.0


// ============================================================================
// 12. SWING DETECTION
// ============================================================================
//
// A swing is confirmed using ta.pivothigh / ta.pivotlow.
//
// IMPORTANT:
// Pine confirms the swing AFTER swingStrength right-side candles exist.
// We therefore store the timestamp and price of the ORIGINAL pivot candle,
// not the later confirmation candle.
//
// The actual swing markers are finalized when the next H1 arrives.
// ============================================================================

float confirmedPivotHigh =
     ta.pivothigh(high, swingStrength, swingStrength)

float confirmedPivotLow =
     ta.pivotlow(low, swingStrength, swingStrength)


// Candidate nearest swing high.
var float candidateHighPrice = na
var int candidateHighTime = na

// Candidate nearest swing low.
var float candidateLowPrice = na
var int candidateLowTime = na


// Timestamp of actual pivot candle.
int pivotCandleTime =
     time[swingStrength]


// Store newest confirmed swing high.
if not na(confirmedPivotHigh)

    candidateHighPrice := confirmedPivotHigh
    candidateHighTime := pivotCandleTime


// Store newest confirmed swing low.
if not na(confirmedPivotLow)

    candidateLowPrice := confirmedPivotLow
    candidateLowTime := pivotCandleTime


// ============================================================================
// 13. DRAW H1 + FINALIZE PRE-H1 SWINGS
// ============================================================================

if showH1 and newH1Event and insideHistory

    // ------------------------------------------------------------------------
    // H1 VERTICAL LINE
    // ------------------------------------------------------------------------

    line.new(
         x1=thisHourTimestamp,
         y1=low,
         x2=thisHourTimestamp,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=h1Color,
         style=h1LineStyle,
         width=h1Width)


    // ------------------------------------------------------------------------
    // H1 TIMESTAMP
    // ------------------------------------------------------------------------

    if showH1Label

        label.new(
             x=thisHourTimestamp,
             y=f_timestampY(),
             text=f_hourText(localHour),
             xloc=xloc.bar_time,
             yloc=yloc.price,
             style=f_timestampLabelStyle(),
             textcolor=h1LabelColor,
             color=color.new(color.white, 100),
             size=h1LabelSize,
             textalign=text.align_center)


    // ------------------------------------------------------------------------
    // DETERMINE VALID PRE-H1 SEARCH WINDOW
    // ------------------------------------------------------------------------

    int searchStart =
         thisHourTimestamp - swingWindowMs


    bool validHigh =
         showSwings and
         not na(candidateHighTime) and
         candidateHighTime >= searchStart and
         candidateHighTime < thisHourTimestamp


    bool validLow =
         showSwings and
         not na(candidateLowTime) and
         candidateLowTime >= searchStart and
         candidateLowTime < thisHourTimestamp


    bool allowHigh =
         swingDisplay == "Both High + Low" or
         swingDisplay == "High Only"


    bool allowLow =
         swingDisplay == "Both High + Low" or
         swingDisplay == "Low Only"


    // ------------------------------------------------------------------------
    // FINAL SWING HIGH MARKER
    //
    // Triangle points DOWN toward the actual swing-high price.
    // ------------------------------------------------------------------------

    if validHigh and allowHigh

        if swingShape == "Triangle"

            label.new(
                 x=candidateHighTime,
                 y=candidateHighPrice,
                 text="▼",
                 xloc=xloc.bar_time,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=swingHighColor,
                 size=swingHighSize)

        else

            label.new(
                 x=candidateHighTime,
                 y=candidateHighPrice,
                 text="●",
                 xloc=xloc.bar_time,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=swingHighColor,
                 size=swingHighSize)


    // ------------------------------------------------------------------------
    // FINAL SWING LOW MARKER
    //
    // Triangle points UP toward the actual swing-low price.
    // ------------------------------------------------------------------------

    if validLow and allowLow

        if swingShape == "Triangle"

            label.new(
                 x=candidateLowTime,
                 y=candidateLowPrice,
                 text="▲",
                 xloc=xloc.bar_time,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=swingLowColor,
                 size=swingLowSize)

        else

            label.new(
                 x=candidateLowTime,
                 y=candidateLowPrice,
                 text="●",
                 xloc=xloc.bar_time,
                 yloc=yloc.price,
                 style=label.style_none,
                 textcolor=swingLowColor,
                 size=swingLowSize)


// ============================================================================
// 14. DRAW M45
// ============================================================================

if showM45 and newM45Event and insideHistory

    line.new(
         x1=thisM45Timestamp,
         y1=low,
         x2=thisM45Timestamp,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=m45Color,
         style=m45LineStyle,
         width=m45Width)

    if m45LabelStyle != "None"

        label.new(
             x=thisM45Timestamp,
             y=f_timestampY(),
             text=f_m45Text(localHour),
             xloc=xloc.bar_time,
             yloc=yloc.price,
             style=f_timestampLabelStyle(),
             textcolor=m45LabelColor,
             color=color.new(color.white, 100),
             size=m45LabelSize,
             textalign=text.align_center)


// ============================================================================
// 15. ALERT CONDITIONS
// ============================================================================

bool h1AlertSignal =
     enableH1Alert and newH1Event

bool m45AlertSignal =
     enableM45Alert and newM45Event


alertcondition(
     h1AlertSignal,
     title="H1 Hourly Open",
     message="H1 hourly open has occurred.")

alertcondition(
     m45AlertSignal,
     title="M45 - 15 Minutes Until Next H1",
     message="M45 reached. 15 minutes until the next H1 open.")
````
