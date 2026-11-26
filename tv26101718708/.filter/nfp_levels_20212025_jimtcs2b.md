# NFP Levels 2021-2025

- url: https://www.tradingview.com/script/jImTCS2B-NFP-Levels-2021-2025/
- type: indicator
- pine_id: PUB;8a62d3dedade4b3e816ac939312d87aa
- version: 3.0

## Description

Based off the great work of rogman (NFP High/Low Levels Plus)

Displays High/Low for NFP release days.
- Uses hard-coded dates for NFP releases 2021-2025.
- Toggle each year on/off independently.
- Each year is drawn in a unique, configurable color.

Session window: 8:30 AM – 3:59 PM EST per NFP day.
Lines are drawn AFTER the session closes.

Dates pulled from https://alfred.stlouisfed.org/release/downloaddates?rid=50

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Based off the great work of rogman (NFP High/Low Levels Plus)
//
// Displays High/Low for NFP release days.
// - Uses hard-coded dates for NFP releases 2021-2025.
// - Toggle each year on/off independently.
// - Each year is drawn in a unique, configurable color.
//
// Session window: 8:30 AM – 3:59 PM EST per NFP day.
// Lines are drawn AFTER the session closes.
//
// Dates pulled from https://alfred.stlouisfed.org/release/downloaddates?rid=50

//@version=6
indicator("NFP Levels 2021-2025", overlay=true, max_lines_count=500, max_labels_count=500)


// ═══════════════════════════════════════════════════════════════════════════════
// ─── YEAR VISIBILITY & COLOR SETTINGS ─────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
var GRP1 = "NFP Year Settings"

bool  show2021  = input.bool(true,  title="Show 2021", inline="yr2021", group=GRP1)
color color2021 = input.color(color.rgb(255, 165,   0), title="Color:", inline="yr2021", group=GRP1)

bool  show2022  = input.bool(true,  title="Show 2022", inline="yr2022", group=GRP1)
color color2022 = input.color(color.rgb( 76, 200, 100), title="Color:", inline="yr2022", group=GRP1)

bool  show2023  = input.bool(true,  title="Show 2023", inline="yr2023", group=GRP1)
color color2023 = input.color(color.rgb(100, 150, 255), title="Color:", inline="yr2023", group=GRP1)

bool  show2024  = input.bool(true,  title="Show 2024", inline="yr2024", group=GRP1)
color color2024 = input.color(color.rgb(255,  80,  80), title="Color:", inline="yr2024", group=GRP1)

bool  show2025  = input.bool(true,  title="Show 2025", inline="yr2025", group=GRP1)
color color2025 = input.color(color.rgb(230, 230,  50), title="Color:", inline="yr2025", group=GRP1)


// ═══════════════════════════════════════════════════════════════════════════════
// ─── LINE / LABEL SETTINGS ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
var GRP2 = "Line & Label Settings"

int hourOffset = input.int(0, title="NFP Start Hour Offset", minval=-12, maxval=12, group="Hour Offset (set to match up with NFP Release Time)")

int lineWidth  = input.int(1,  title="Line Width", options=[1,2,3,4,5], group=GRP2, inline="line")
int lineOffset = input.int(10, title="Offset",     options=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], group=GRP2, inline="line")

bool   showText    = input.bool(true,    title="Show Labels", group=GRP2)
bool   showPrices  = input.bool(false,   title="Show Prices", group=GRP2)
string labSize     = input.string("normal", title="Text Size", options=["small","normal","large","huge"], group=GRP2)
int    labelOffset = input.int(1, title="Label Offset", options=[0,1,2,3,4,5], group=GRP2)

// Total number of NFP sessions tracked.
var int NFP_COUNT = 59


// ═══════════════════════════════════════════════════════════════════════════════
// ─── USER-DEFINED TYPE FOR NFP LEVEL DATA ─────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
type NFPData
    int   sessionStart
    int   sessionEnd
    float finalHigh
    float finalLow
    int   finalTime
    bool  show
    string name
    color lineColor
    line  highLine
    line  lowLine
    label highLabel
    label lowLabel


// ═══════════════════════════════════════════════════════════════════════════════
// ─── HELPER FUNCTIONS ─────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

// Returns the Pine Script size constant matching the given string.
getLabelSize(string sz) =>
    sz == "small" ? size.small : sz == "large" ? size.large : sz == "huge" ? size.huge : size.normal

// Builds a single NFPData entry from date components and display options.
f_makeNFPEntry(int yr, int mo, int day, int hourOff, bool show, string name, color lineColor) =>
    int ss = timestamp("America/New_York", yr, mo, day,  8 + hourOff, 30)
    int se = timestamp("America/New_York", yr, mo, day, 15 + hourOff, 59)
    NFPData.new(ss, se, na, na, na, show, name, lineColor, na, na, na, na)


// ═══════════════════════════════════════════════════════════════════════════════
// ─── INITIALIZE NFP DATA ARRAY (59 sessions: 2021-2025) ───────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
var NFPData[] nfpDataArray = array.new<NFPData>(NFP_COUNT)

if barstate.isfirst
    // 2021 (indices 0-11)
    array.set(nfpDataArray,  0, f_makeNFPEntry(2021,  1,  8, hourOffset, show2021, "2021 JAN", color2021))
    array.set(nfpDataArray,  1, f_makeNFPEntry(2021,  2,  5, hourOffset, show2021, "2021 FEB", color2021))
    array.set(nfpDataArray,  2, f_makeNFPEntry(2021,  3,  5, hourOffset, show2021, "2021 MAR", color2021))
    array.set(nfpDataArray,  3, f_makeNFPEntry(2021,  4,  2, hourOffset, show2021, "2021 APR", color2021))
    array.set(nfpDataArray,  4, f_makeNFPEntry(2021,  5,  7, hourOffset, show2021, "2021 MAY", color2021))
    array.set(nfpDataArray,  5, f_makeNFPEntry(2021,  6,  4, hourOffset, show2021, "2021 JUN", color2021))
    array.set(nfpDataArray,  6, f_makeNFPEntry(2021,  7,  2, hourOffset, show2021, "2021 JUL", color2021))
    array.set(nfpDataArray,  7, f_makeNFPEntry(2021,  8,  6, hourOffset, show2021, "2021 AUG", color2021))
    array.set(nfpDataArray,  8, f_makeNFPEntry(2021,  9,  3, hourOffset, show2021, "2021 SEP", color2021))
    array.set(nfpDataArray,  9, f_makeNFPEntry(2021, 10,  8, hourOffset, show2021, "2021 OCT", color2021))
    array.set(nfpDataArray, 10, f_makeNFPEntry(2021, 11,  5, hourOffset, show2021, "2021 NOV", color2021))
    array.set(nfpDataArray, 11, f_makeNFPEntry(2021, 12,  3, hourOffset, show2021, "2021 DEC", color2021))
    // 2022 (indices 12-23)
    array.set(nfpDataArray, 12, f_makeNFPEntry(2022,  1,  7, hourOffset, show2022, "2022 JAN", color2022))
    array.set(nfpDataArray, 13, f_makeNFPEntry(2022,  2,  4, hourOffset, show2022, "2022 FEB", color2022))
    array.set(nfpDataArray, 14, f_makeNFPEntry(2022,  3,  4, hourOffset, show2022, "2022 MAR", color2022))
    array.set(nfpDataArray, 15, f_makeNFPEntry(2022,  4,  1, hourOffset, show2022, "2022 APR", color2022))
    array.set(nfpDataArray, 16, f_makeNFPEntry(2022,  5,  6, hourOffset, show2022, "2022 MAY", color2022))
    array.set(nfpDataArray, 17, f_makeNFPEntry(2022,  6,  3, hourOffset, show2022, "2022 JUN", color2022))
    array.set(nfpDataArray, 18, f_makeNFPEntry(2022,  7,  8, hourOffset, show2022, "2022 JUL", color2022))
    array.set(nfpDataArray, 19, f_makeNFPEntry(2022,  8,  5, hourOffset, show2022, "2022 AUG", color2022))
    array.set(nfpDataArray, 20, f_makeNFPEntry(2022,  9,  2, hourOffset, show2022, "2022 SEP", color2022))
    array.set(nfpDataArray, 21, f_makeNFPEntry(2022, 10,  7, hourOffset, show2022, "2022 OCT", color2022))
    array.set(nfpDataArray, 22, f_makeNFPEntry(2022, 11,  4, hourOffset, show2022, "2022 NOV", color2022))
    array.set(nfpDataArray, 23, f_makeNFPEntry(2022, 12,  2, hourOffset, show2022, "2022 DEC", color2022))
    // 2023 (indices 24-35)
    array.set(nfpDataArray, 24, f_makeNFPEntry(2023,  1,  6, hourOffset, show2023, "2023 JAN", color2023))
    array.set(nfpDataArray, 25, f_makeNFPEntry(2023,  2,  3, hourOffset, show2023, "2023 FEB", color2023))
    array.set(nfpDataArray, 26, f_makeNFPEntry(2023,  3, 10, hourOffset, show2023, "2023 MAR", color2023))
    array.set(nfpDataArray, 27, f_makeNFPEntry(2023,  4,  7, hourOffset, show2023, "2023 APR", color2023))
    array.set(nfpDataArray, 28, f_makeNFPEntry(2023,  5,  5, hourOffset, show2023, "2023 MAY", color2023))
    array.set(nfpDataArray, 29, f_makeNFPEntry(2023,  6,  2, hourOffset, show2023, "2023 JUN", color2023))
    array.set(nfpDataArray, 30, f_makeNFPEntry(2023,  7,  7, hourOffset, show2023, "2023 JUL", color2023))
    array.set(nfpDataArray, 31, f_makeNFPEntry(2023,  8,  4, hourOffset, show2023, "2023 AUG", color2023))
    array.set(nfpDataArray, 32, f_makeNFPEntry(2023,  9,  1, hourOffset, show2023, "2023 SEP", color2023))
    array.set(nfpDataArray, 33, f_makeNFPEntry(2023, 10,  6, hourOffset, show2023, "2023 OCT", color2023))
    array.set(nfpDataArray, 34, f_makeNFPEntry(2023, 11,  3, hourOffset, show2023, "2023 NOV", color2023))
    array.set(nfpDataArray, 35, f_makeNFPEntry(2023, 12,  8, hourOffset, show2023, "2023 DEC", color2023))
    // 2024 (indices 36-47)
    array.set(nfpDataArray, 36, f_makeNFPEntry(2024,  1,  5, hourOffset, show2024, "2024 JAN", color2024))
    array.set(nfpDataArray, 37, f_makeNFPEntry(2024,  2,  2, hourOffset, show2024, "2024 FEB", color2024))
    array.set(nfpDataArray, 38, f_makeNFPEntry(2024,  3,  8, hourOffset, show2024, "2024 MAR", color2024))
    array.set(nfpDataArray, 39, f_makeNFPEntry(2024,  4,  5, hourOffset, show2024, "2024 APR", color2024))
    array.set(nfpDataArray, 40, f_makeNFPEntry(2024,  5,  3, hourOffset, show2024, "2024 MAY", color2024))
    array.set(nfpDataArray, 41, f_makeNFPEntry(2024,  6,  7, hourOffset, show2024, "2024 JUN", color2024))
    array.set(nfpDataArray, 42, f_makeNFPEntry(2024,  7,  5, hourOffset, show2024, "2024 JUL", color2024))
    array.set(nfpDataArray, 43, f_makeNFPEntry(2024,  8, 2, hourOffset, show2024, "2024 AUG", color2024))
    array.set(nfpDataArray, 44, f_makeNFPEntry(2024,  9,  6, hourOffset, show2024, "2024 SEP", color2024))
    array.set(nfpDataArray, 45, f_makeNFPEntry(2024, 10,  4, hourOffset, show2024, "2024 OCT", color2024))
    array.set(nfpDataArray, 46, f_makeNFPEntry(2024, 11,  1, hourOffset, show2024, "2024 NOV", color2024))
    array.set(nfpDataArray, 47, f_makeNFPEntry(2024, 12,  6, hourOffset, show2024, "2024 DEC", color2024))
    // 2025 (indices 48-58; no October — see NOTE below)
    array.set(nfpDataArray, 48, f_makeNFPEntry(2025,  1, 10, hourOffset, show2025, "2025 JAN", color2025))
    array.set(nfpDataArray, 49, f_makeNFPEntry(2025,  2,  7, hourOffset, show2025, "2025 FEB", color2025))
    array.set(nfpDataArray, 50, f_makeNFPEntry(2025,  3,  7, hourOffset, show2025, "2025 MAR", color2025))
    array.set(nfpDataArray, 51, f_makeNFPEntry(2025,  4,  4, hourOffset, show2025, "2025 APR", color2025))
    array.set(nfpDataArray, 52, f_makeNFPEntry(2025,  5,  2, hourOffset, show2025, "2025 MAY", color2025))
    array.set(nfpDataArray, 53, f_makeNFPEntry(2025,  6,  6, hourOffset, show2025, "2025 JUN", color2025))
    array.set(nfpDataArray, 54, f_makeNFPEntry(2025,  7,  3, hourOffset, show2025, "2025 JUL", color2025))
    array.set(nfpDataArray, 55, f_makeNFPEntry(2025,  8,  1, hourOffset, show2025, "2025 AUG", color2025))
    array.set(nfpDataArray, 56, f_makeNFPEntry(2025,  9,  5, hourOffset, show2025, "2025 SEP", color2025))
    array.set(nfpDataArray, 57, f_makeNFPEntry(2025, 11, 20, hourOffset, show2025, "2025 NOV", color2025))
    array.set(nfpDataArray, 58, f_makeNFPEntry(2025, 12, 16, hourOffset, show2025, "2025 DEC", color2025))


// ═══════════════════════════════════════════════════════════════════════════════
// ─── SINGLE request.security() — ALL 59 SESSIONS ──────────────────────────────
//
// All session high/low tracking is done inside one function evaluated on 30-min
// bars. On each bar, we loop over all 59 session windows and update running
// highs/lows for any window whose time range contains the current bar.
//
// Returns two float arrays: [highs, lows], each of length NFP_COUNT.
// ═══════════════════════════════════════════════════════════════════════════════
f_allSessionsHL() =>
    var float[] sh = array.new_float(59, na)
    var float[] sl = array.new_float(59, na)

    // Session start/end timestamps (America/New_York). Indexed 0-58.
    // Each row: [year, month, day]. Start = 08:30+offset, End = 15:59+offset.
    // These must be literals here; hourOffset is captured from the outer scope.
    int[] ss_times = array.from(
         timestamp("America/New_York", 2021,  1,  8,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  2,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  3,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  4,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  5,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  6,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  7,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  8,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021,  9,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021, 10,  8,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021, 11,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2021, 12,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  1,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  2,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  3,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  4,  1,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  5,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  6,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  7,  8,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  8,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022,  9,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022, 10,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022, 11,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2022, 12,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  1,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  2,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  3, 10,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  4,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  5,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  6,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  7,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  8,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023,  9,  1,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023, 10,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023, 11,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2023, 12,  8,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  1,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  2,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  3,  8,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  4,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  5,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  6,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  7,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  8,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024,  9,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024, 10,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024, 11,  1,  8 + hourOffset, 30),
         timestamp("America/New_York", 2024, 12,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  1, 10,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  2,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  3,  7,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  4,  4,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  5,  2,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  6,  6,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  7,  3,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  8,  1,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025,  9,  5,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025, 11, 20,  8 + hourOffset, 30),
         timestamp("America/New_York", 2025, 12, 16,  8 + hourOffset, 30))

    int[] se_times = array.from(
         timestamp("America/New_York", 2021,  1,  8, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  2,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  3,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  4,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  5,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  6,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  7,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  8,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021,  9,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021, 10,  8, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021, 11,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2021, 12,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  1,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  2,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  3,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  4,  1, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  5,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  6,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  7,  8, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  8,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022,  9,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022, 10,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022, 11,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2022, 12,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  1,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  2,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  3, 10, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  4,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  5,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  6,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  7,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  8,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023,  9,  1, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023, 10,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023, 11,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2023, 12,  8, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  1,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  2,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  3,  8, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  4,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  5,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  6,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  7,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  8,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024,  9,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024, 10,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024, 11,  1, 15 + hourOffset, 59),
         timestamp("America/New_York", 2024, 12,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  1, 10, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  2,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  3,  7, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  4,  4, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  5,  2, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  6,  6, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  7,  3, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  8,  1, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025,  9,  5, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025, 11, 20, 15 + hourOffset, 59),
         timestamp("America/New_York", 2025, 12, 16, 15 + hourOffset, 59))

    for i = 0 to 58
        int ss = array.get(ss_times, i)
        int se = array.get(se_times, i)
        // On a daily timeframe, match by calendar date (year/month/day) so the
        // full day's high/low is captured.  On intraday timeframes, use the
        // original 8:30–3:59 session-window check.
        bool inSession = timeframe.isdaily ?
             (year(time, "America/New_York")       == year(ss, "America/New_York")       and
              month(time, "America/New_York")      == month(ss, "America/New_York")      and
              dayofmonth(time, "America/New_York") == dayofmonth(ss, "America/New_York")) :
             (time >= ss and time <= se)
        if inSession
            float curH = array.get(sh, i)
            float curL = array.get(sl, i)
            array.set(sh, i, na(curH) ? high : math.max(curH, high))
            array.set(sl, i, na(curL) ? low  : math.min(curL, low))

    [sh, sl]

// Use daily bars when on a daily chart (requesting a lower timeframe than the
// chart is not permitted by TradingView).  For intraday charts use 30-minute
// bars so the session-window logic remains precise.
string reqTf = timeframe.isdaily ? "D" : "30"
[shArr, slArr] = request.security(syminfo.tickerid, reqTf, f_allSessionsHL(), gaps=barmerge.gaps_off)


// ═══════════════════════════════════════════════════════════════════════════════
// ─── STORE FINAL VALUES ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
var float[] finalHighs = array.new_float(NFP_COUNT, na)
var float[] finalLows  = array.new_float(NFP_COUNT, na)
var int[]   finalTimes = array.new_int(NFP_COUNT,   na)

int barEndTime = time_close

for i = 0 to 58
    NFPData data = array.get(nfpDataArray, i)
    if not na(shArr) and not na(slArr)
        float sh = array.get(shArr, i)
        float sl = array.get(slArr, i)
        if barEndTime >= data.sessionEnd and na(array.get(finalHighs, i)) and not na(sh)
            array.set(finalHighs, i, sh)
            array.set(finalLows,  i, sl)
            array.set(finalTimes, i, time_close)
    data.finalHigh := array.get(finalHighs, i)
    data.finalLow  := array.get(finalLows,  i)
    data.finalTime := array.get(finalTimes, i)


// ═══════════════════════════════════════════════════════════════════════════════
// ─── DRAW LINES AND LABELS ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════
if not (timeframe.isweekly or timeframe.ismonthly)
    string labelSz   = getLabelSize(labSize)
    int currentTime  = time_close
    int timeframeMs  = timeframe.in_seconds(timeframe.period) * 1000
    int futureTime   = currentTime + (lineOffset  * timeframeMs)
    int lblTime      = futureTime  + (labelOffset * timeframeMs)

    for i = 0 to 58
        NFPData data = array.get(nfpDataArray, i)

        if not na(data.finalHigh) and data.show and not na(data.finalTime)
            color c = data.lineColor

            // High line
            if na(data.highLine)
                data.highLine := line.new(data.finalTime, data.finalHigh, futureTime, data.finalHigh,
                     xloc=xloc.bar_time, color=c, width=lineWidth)
            else
                line.set_x2(data.highLine, futureTime)
                line.set_color(data.highLine, c)

            // Low line
            if na(data.lowLine)
                data.lowLine := line.new(data.finalTime, data.finalLow, futureTime, data.finalLow,
                     xloc=xloc.bar_time, color=c, width=lineWidth)
            else
                line.set_x2(data.lowLine, futureTime)
                line.set_color(data.lowLine, c)

            // Labels
            if showText
                string highText = data.name + " NFP High" + (showPrices ? " " + str.tostring(data.finalHigh) : "")
                string lowText  = data.name + " NFP Low"  + (showPrices ? " " + str.tostring(data.finalLow)  : "")

                if na(data.highLabel)
                    data.highLabel := label.new(lblTime, data.finalHigh, highText,
                         xloc=xloc.bar_time, style=label.style_label_left,
                         color=color.new(c, 100), textcolor=c, size=labelSz)
                else
                    label.set_text(data.highLabel, highText)
                    label.set_xy(data.highLabel, lblTime, data.finalHigh)
                    label.set_textcolor(data.highLabel, c)

                if na(data.lowLabel)
                    data.lowLabel := label.new(lblTime, data.finalLow, lowText,
                         xloc=xloc.bar_time, style=label.style_label_left,
                         color=color.new(c, 100), textcolor=c, size=labelSz)
                else
                    label.set_text(data.lowLabel, lowText)
                    label.set_xy(data.lowLabel, lblTime, data.finalLow)
                    label.set_textcolor(data.lowLabel, c)
````
