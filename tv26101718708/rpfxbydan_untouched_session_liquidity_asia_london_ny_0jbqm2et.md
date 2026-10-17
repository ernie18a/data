# RPFXBYDAN - Untouched Session Liquidity - Asia / London / NY

- url: https://www.tradingview.com/script/0jBqM2Et-RPFXBYDAN-Untouched-Session-Liquidity-Asia-London-NY/
- type: indicator
- pine_id: PUB;46a888cbc42849338008dcfe811f52f4
- version: 1.0

## Description

RPFXBYDAN - Untouched Session Liquidity — Asia / London / NY

 **What this script does**

This indicator marks the high and low of each Asia, London, and New York trading session and projects those two levels forward as horizontal lines. Unlike a standard session-range indicator that leaves every past level on the chart, this one automatically deletes any level the moment price reaches it. The result is a running inventory of the recent session highs and lows that price has NOT yet run — the liquidity that is still "live" on the chart.

 By default the script keeps the ten most recent sessions per region so you can see whether the current market is respecting, sweeping, or ignoring older session extremes.

 **Why session highs and lows matter**

 Session highs and lows tend to attract price because they collect a predictable pool of stop-loss orders — protective stops from participants who entered inside the previous session's range. Price often gravitates toward these levels, sweeps the liquidity, and reverses. Knowing which specific levels are still untaken (versus already mitigated) is more actionable than seeing every historical level indiscriminately, because only untaken levels still hold that liquidity.

**How the script works, step by step**

 1. On every bar, the script checks whether the bar falls inside the Asia, London, or New York session window, using Pine's timezone-aware time function so detection is correct on any chart regardless of the user's timezone settings.
2. While a session is active, it tracks the running high and low and remembers the bar index at which each was set.
3. The instant a session closes (the first bar the session check flips from true to false), it draws two horizontal lines anchored at those bar indexes — one at the session high, one at the session low — with a text label naming the region.
4. Each new line and label is pushed onto a per-region array. If the array now holds more than the configured lookback count (default ten), the oldest entry is shifted off and deleted.
5. On every subsequent bar, the script walks the array of active lines and compares the current candle's high to each high level and the current candle's low to each low level. Any line whose level has been reached is deleted along with its label. Any line not yet touched has its right edge advanced so the projection stays anchored to the current bar.

The touch check is the mechanism that keeps the chart focused only on liquidity that hasn't been taken yet — it's what differentiates this from a normal "show previous session range" indicator.

 **Timezone handling**

The default Auto mode detects each session in its own home timezone: Asia in Tokyo time, London in London time, and New York in New York time. Because Pine's time function accepts a timezone argument, the detection is correct regardless of what timezone your chart is set to, and daylight saving transitions are handled automatically. If you'd rather have all three sessions interpreted in one specific timezone (for example, always in your local one), the location dropdown lets you select from a menu of common cities and UTC offsets, and the session windows will be read in that timezone instead.

**Inputs**

- Your Location / Timezone — Auto (recommended) or a specific city / UTC offset
- Asia, London, New York Session windows — defaults calibrated to each session's home clock time
- Sessions to Keep — how many recent sessions per region to display (default 10)
- Colors per region, line width, line style, right-extension length, label toggle

**How to use it**

Add the indicator to a 5-minute, 15-minute, 30-minute, or 1-hour chart of any symbol. Give the chart a few days of history to load so the script can walk through session closes and populate the levels. Watch how price interacts with the untaken lines — a clean sweep of an old session high can precede a reversal, while price trading through a level without pausing suggests continuation. Because touched levels are removed automatically, whatever remains on the chart at any moment is the current "menu" of session liquidity worth watching.

Works on any instrument, though it's most useful on FX pairs, index futures, and crypto where session structure is meaningful. Higher timeframes (4H+) compress sessions into a single bar and reduce the value of the lines.

 **Notes**

Session detection uses each session's home timezone in Auto mode; in manual mode you select a single timezone that applies to all three. Both modes automatically handle daylight saving.

## Source Code

````pine
//@version=6
// =============================================================================
//  Previous Session Highs & Lows (Asia / London / New York)
//  - Keeps the last N session highs/lows (default 10) per session type.
//  - Each level is removed automatically when price touches it.
//  - Timezone is handled automatically: pick your location and the script
//    figures out the right session windows for you. No manual UTC math.
// =============================================================================
indicator("RPFXBYDAN - Untouched Session Liquidity — Asia / London / NY", overlay = true, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
//  TIMEZONE / LOCATION
// =============================================================================
// "Auto" (recommended) detects each session in its own HOME timezone:
//      Asia -> Asia/Tokyo, London -> Europe/London, NY -> America/New_York
// This works on any chart, anywhere in the world - no math required.
//
// If you'd rather have all sessions interpreted in one specific timezone (for
// example, your local one), pick a UTC offset / city below and the script
// will interpret the session windows you see in that timezone.
// =============================================================================

tzMode = input.string("Auto - Home Timezones (Recommended)", "Your Location / Timezone",
    options = [
        "Auto - Home Timezones (Recommended)",
        "UTC (UTC+0)",
        "London (UTC+0 / +1 DST)",
        "Berlin / Paris (UTC+1 / +2 DST)",
        "Moscow (UTC+3)",
        "Dubai (UTC+4)",
        "Mumbai (UTC+5:30)",
        "Singapore / Hong Kong (UTC+8)",
        "Tokyo (UTC+9)",
        "Sydney (UTC+10 / +11 DST)",
        "New York (UTC-5 / -4 DST)",
        "Chicago (UTC-6 / -5 DST)",
        "Denver (UTC-7 / -6 DST)",
        "Los Angeles (UTC-8 / -7 DST)"
    ],
    group   = "Location",
    tooltip = "Auto uses each session's home timezone (Tokyo for Asia, London for London, NY for NY) and just works. Pick a specific city only if you want all sessions interpreted in that one timezone.")

// Resolve display label -> Pine timezone string
getTz(m) =>
    switch m
        "UTC (UTC+0)"                       => "UTC"
        "London (UTC+0 / +1 DST)"           => "Europe/London"
        "Berlin / Paris (UTC+1 / +2 DST)"   => "Europe/Berlin"
        "Moscow (UTC+3)"                    => "Europe/Moscow"
        "Dubai (UTC+4)"                     => "Asia/Dubai"
        "Mumbai (UTC+5:30)"                 => "Asia/Kolkata"
        "Singapore / Hong Kong (UTC+8)"     => "Asia/Singapore"
        "Tokyo (UTC+9)"                     => "Asia/Tokyo"
        "Sydney (UTC+10 / +11 DST)"         => "Australia/Sydney"
        "New York (UTC-5 / -4 DST)"         => "America/New_York"
        "Chicago (UTC-6 / -5 DST)"          => "America/Chicago"
        "Denver (UTC-7 / -6 DST)"           => "America/Denver"
        "Los Angeles (UTC-8 / -7 DST)"      => "America/Los_Angeles"
        => "UTC"

autoMode = tzMode == "Auto - Home Timezones (Recommended)"
userTz   = getTz(tzMode)

// =============================================================================
//  SESSION WINDOWS
// =============================================================================
// Defaults are calibrated to each session's home timezone in Auto mode.
// (Asia 08:00-17:00 Tokyo / London 08:00-17:00 London / NY 08:00-17:00 NY)
// In manual mode they're interpreted in the timezone you selected above.
// =============================================================================
asiaSess   = input.session("0800-1700", "Asia Session",     group = "Sessions",
    tooltip = "Default 0800-1700 Tokyo time in Auto mode. Otherwise interpreted in the timezone you chose.")
londonSess = input.session("0800-1700", "London Session",   group = "Sessions",
    tooltip = "Default 0800-1700 London time in Auto mode. Otherwise interpreted in the timezone you chose.")
nySess     = input.session("0800-1700", "New York Session", group = "Sessions",
    tooltip = "Default 0800-1700 New York time in Auto mode. Otherwise interpreted in the timezone you chose.")

asiaTz   = autoMode ? "Asia/Tokyo"       : userTz
londonTz = autoMode ? "Europe/London"    : userTz
nyTz     = autoMode ? "America/New_York" : userTz

// =============================================================================
//  STYLE / GENERAL
// =============================================================================
asiaCol    = input.color(color.new(color.yellow, 0), "Asia Color",     group = "Style")
londonCol  = input.color(color.new(color.blue,   0), "London Color",   group = "Style")
nyCol      = input.color(color.new(color.red,    0), "New York Color", group = "Style")

lookback   = input.int(10,  "Sessions to Keep (per session)", minval = 1, maxval = 50, group = "General")
lineW      = input.int(1,   "Line Width",            minval = 1, maxval = 5, group = "Style")
extBars    = input.int(50,  "Extend Right (bars)",   minval = 1,             group = "Style")
showLabels = input.bool(true,"Show Labels",                                 group = "Style")
lineStyleI = input.string("Solid", "Line Style", options = ["Solid","Dashed","Dotted"], group = "Style")

ls = lineStyleI == "Solid" ? line.style_solid : lineStyleI == "Dashed" ? line.style_dashed : line.style_dotted

// =============================================================================
//  SESSION DETECTION (timezone-aware)
// =============================================================================
inSess(s, tz) => not na(time(timeframe.period, s, tz))
isAsia   = inSess(asiaSess,   asiaTz)
isLondon = inSess(londonSess, londonTz)
isNY     = inSess(nySess,     nyTz)

// =============================================================================
//  RUNNING SESSION HIGHS / LOWS
// =============================================================================
var float aH  = na
var float aL  = na
var int   aHB = na
var int   aLB = na

var float lH  = na
var float lL  = na
var int   lHB = na
var int   lLB = na

var float nH  = na
var float nL  = na
var int   nHB = na
var int   nLB = na

var array<line>  aHighLines  = array.new<line>()
var array<line>  aLowLines   = array.new<line>()
var array<label> aHighLabels = array.new<label>()
var array<label> aLowLabels  = array.new<label>()

var array<line>  lHighLines  = array.new<line>()
var array<line>  lLowLines   = array.new<line>()
var array<label> lHighLabels = array.new<label>()
var array<label> lLowLabels  = array.new<label>()

var array<line>  nHighLines  = array.new<line>()
var array<line>  nLowLines   = array.new<line>()
var array<label> nHighLabels = array.new<label>()
var array<label> nLowLabels  = array.new<label>()

if isAsia
    if not isAsia[1]
        aH  := high
        aL  := low
        aHB := bar_index
        aLB := bar_index
    if high > aH
        aH  := high
        aHB := bar_index
    if low < aL
        aL  := low
        aLB := bar_index

if isLondon
    if not isLondon[1]
        lH  := high
        lL  := low
        lHB := bar_index
        lLB := bar_index
    if high > lH
        lH  := high
        lHB := bar_index
    if low < lL
        lL  := low
        lLB := bar_index

if isNY
    if not isNY[1]
        nH  := high
        nL  := low
        nHB := bar_index
        nLB := bar_index
    if high > nH
        nH  := high
        nHB := bar_index
    if low < nL
        nL  := low
        nLB := bar_index

// =============================================================================
//  HELPERS
// =============================================================================
trimArrays(lines, labels) =>
    while array.size(lines) > lookback
        oldLine = array.shift(lines)
        if not na(oldLine)
            line.delete(oldLine)
        if array.size(labels) > 0
            oldLbl = array.shift(labels)
            if not na(oldLbl)
                label.delete(oldLbl)
    0

cleanTouched(lines, labels, isHigh) =>
    i = array.size(lines) - 1
    while i >= 0
        ln = array.get(lines, i)
        shouldRemove = na(ln)
        if not shouldRemove
            level   = line.get_y1(ln)
            touched = isHigh ? high >= level : low <= level
            if touched
                line.delete(ln)
                shouldRemove := true
            else
                line.set_x2(ln, bar_index + extBars)
                if array.size(labels) > i
                    lb = array.get(labels, i)
                    if not na(lb)
                        label.set_x(lb, bar_index + extBars)
                shouldRemove := false
        if shouldRemove
            array.remove(lines, i)
            if array.size(labels) > i
                lb = array.get(labels, i)
                if not na(lb)
                    label.delete(lb)
                array.remove(labels, i)
        i := i - 1
    0

// =============================================================================
//  SESSION CLOSE: add new high/low, drop oldest
// =============================================================================
asiaClose   = not isAsia   and isAsia[1]
londonClose = not isLondon and isLondon[1]
nyClose     = not isNY     and isNY[1]

if asiaClose and not na(aH)
    hLine = line.new(aHB, aH, bar_index + extBars, aH, color = asiaCol, width = lineW, style = ls)
    lLine = line.new(aLB, aL, bar_index + extBars, aL, color = asiaCol, width = lineW, style = ls)
    array.push(aHighLines, hLine)
    array.push(aLowLines,  lLine)
    if showLabels
        hLbl = label.new(bar_index + extBars, aH, "Asia High", style = label.style_label_left, color = color.new(asiaCol, 70), textcolor = asiaCol, size = size.small)
        lLbl = label.new(bar_index + extBars, aL, "Asia Low",  style = label.style_label_left, color = color.new(asiaCol, 70), textcolor = asiaCol, size = size.small)
        array.push(aHighLabels, hLbl)
        array.push(aLowLabels,  lLbl)
    trimArrays(aHighLines, aHighLabels)
    trimArrays(aLowLines,  aLowLabels)

if londonClose and not na(lH)
    hLine = line.new(lHB, lH, bar_index + extBars, lH, color = londonCol, width = lineW, style = ls)
    lLine = line.new(lLB, lL, bar_index + extBars, lL, color = londonCol, width = lineW, style = ls)
    array.push(lHighLines, hLine)
    array.push(lLowLines,  lLine)
    if showLabels
        hLbl = label.new(bar_index + extBars, lH, "London High", style = label.style_label_left, color = color.new(londonCol, 70), textcolor = londonCol, size = size.small)
        lLbl = label.new(bar_index + extBars, lL, "London Low",  style = label.style_label_left, color = color.new(londonCol, 70), textcolor = londonCol, size = size.small)
        array.push(lHighLabels, hLbl)
        array.push(lLowLabels,  lLbl)
    trimArrays(lHighLines, lHighLabels)
    trimArrays(lLowLines,  lLowLabels)

if nyClose and not na(nH)
    hLine = line.new(nHB, nH, bar_index + extBars, nH, color = nyCol, width = lineW, style = ls)
    lLine = line.new(nLB, nL, bar_index + extBars, nL, color = nyCol, width = lineW, style = ls)
    array.push(nHighLines, hLine)
    array.push(nLowLines,  lLine)
    if showLabels
        hLbl = label.new(bar_index + extBars, nH, "NY High", style = label.style_label_left, color = color.new(nyCol, 70), textcolor = nyCol, size = size.small)
        lLbl = label.new(bar_index + extBars, nL, "NY Low",  style = label.style_label_left, color = color.new(nyCol, 70), textcolor = nyCol, size = size.small)
        array.push(nHighLabels, hLbl)
        array.push(nLowLabels,  lLbl)
    trimArrays(nHighLines, nHighLabels)
    trimArrays(nLowLines,  nLowLabels)

// =============================================================================
//  PER-BAR: remove touched levels, extend untouched
// =============================================================================
cleanTouched(aHighLines, aHighLabels, true)
cleanTouched(aLowLines,  aLowLabels,  false)
cleanTouched(lHighLines, lHighLabels, true)
cleanTouched(lLowLines,  lLowLabels,  false)
cleanTouched(nHighLines, nHighLabels, true)
cleanTouched(nLowLines,  nLowLabels,  false)
````
