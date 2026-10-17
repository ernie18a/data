# The Break

- url: https://www.tradingview.com/script/7UXagprq-The-Break/
- type: indicator
- pine_id: PUB;e773479b98d44002ab1ab1e7dc47562e
- version: 2.0

## Description

A multi-session Initial Balance indicator that maps the day's most-watched ranges onto a single chart. It tracks the first 60 minutes of every major session — Asia, London, and New York — independently, and locks in each one's high, low, and equilibrium the instant the IB window closes.

During the build window, a shaded box grows bar-by-bar so you can watch the range develop in real time. The moment the IB completes, the box freezes, and three lines extend across the rest of the session: IB High, IB Mid, and IB Low. Each session gets its own color, so all three IBs read cleanly on one chart without overlap confusion.

This indicator does one thing and does it cleanly: it draws the ranges. No signals, no entries, no targets — just the structural map you need to see where each session sets its open balance, and where price is trading relative to those levels right now.

A status dashboard in the top-right corner tracks each session's IB state at a glance: building / locked / above/inside / below, plus current price relative to the range and time remaining in the window.

All session times are anchored to a single time zone setting (ET / PT / chart-local), so windows stay correct across futures, FX, and crypto symbols, and the indicator uses extended-hours data. Hence, the Asia and London ranges plot correctly even on RTH-only charts.

Use it for: defining session bias before NY open, marking IB extremes as magnet levels and reaction zones, identifying which session is leading the day, and giving any breakout or reversal strategy a clean structural reference to work from.

Default Sessions (ET)
Asia IB — 18:00–19:00 (Sun–Thu)

London IB — 02:00–03:00

New York IB — 09:30–10:30

Every session window and IB duration is fully editable. Run a 30-minute IB instead, shift NY to your prop firm's window, or turn off any session you don't trade.

Settings to Know
IB duration — 1–240 min (default 60)

Timezone — ET / PT / chart-local

Session colors — independent for Asia / London / NY ranges and lines
Midlinee — toggle equilibrium on/off; solid or dashed

Range box — toggle live build window on/off; adjust transparency

Extend lines — to session end, to next IB start, or full chart.

Dashboard — Small / Medium / Large, or hide entirely

Notes
Built with extended-hours data fetching so Asia and London ranges plot correctly on both ETH and RTH-only charts.

Works on any TradingView symbol; defaults are tuned for NQ, but every input is editable.

Plots are non-repainting — once the IB window closes, the levels are locked.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("The Break", overlay = true)

// --- Constants ---
string G_S1  = "New York"
string G_S2  = "Asia"
string G_S3  = "London"
string G_OR  = "Opening Range"
string G_SET = "General Settings"

// --- Inputs ---
string timezoneInput = input.string("America/New_York", "Timezone", group = G_SET, tooltip = "The timezone for session calculations. Use standard TZ database names (e.g., 'UTC', 'America/New_York', 'Europe/London').")
int ibDuration = input.int(60, "IB Duration (Minutes)", minval = 1, group = G_SET, tooltip = "The duration of the Initial Balance period starting from the session open.")
string timeFormatInput = input.string("24H", "Time Format", options = ["24H", "12H"], group = G_SET, tooltip = "Format used for time display in labels (e.g., 14:30 vs 02:30 PM).")
bool showLabels = input.bool(true, "Show Labels", group = G_SET, tooltip = "Toggle display of price and time labels for the Initial Balance.")

// New York
bool s1Enabled = input.bool(true, "Enabled", inline = "S1", group = G_S1)
string s1Time = input.session("0930-1600", "", inline = "S1", group = G_S1)
color s1Color = input.color(color.new(#089981, 0), "Color", inline = "S1", group = G_S1)

// Asia
bool s2Enabled = input.bool(true, "Enabled", inline = "S2", group = G_S2)
string s2Time = input.session("1900-0400", "", inline = "S2", group = G_S2)
color s2Color = input.color(color.new(#5b9cf6, 0), "Color", inline = "S2", group = G_S2)

// London
bool s3Enabled = input.bool(true, "Enabled", inline = "S3", group = G_S3)
string s3Time = input.session("0300-1130", "", inline = "S3", group = G_S3)
color s3Color = input.color(color.new(#f23645, 0), "Color", inline = "S3", group = G_S3)

// Opening Range (reuses the IB engine with short, fixed durations)
string orSession = input.session("0930-1600", "Anchor Session", group = G_OR, tooltip = "Both opening ranges are measured from the OPEN of this session. Default = New York cash open. Use a chart timeframe of 5m or lower for the 5-min range to be accurate (15m or lower for the 15-min range).")
bool or5Enabled  = input.bool(true, "5-Min Range", inline = "OR5", group = G_OR)
color or5Color   = input.color(color.new(#ff9800, 0), "Color", inline = "OR5", group = G_OR)
bool or15Enabled = input.bool(true, "15-Min Range", inline = "OR15", group = G_OR)
color or15Color  = input.color(color.new(#9c27b0, 0), "Color", inline = "OR15", group = G_OR)

// --- Calculation Logic ---
// Function to handle IB tracking for a specific session
calcIB(bool enabled, string sess, string tz, int duration) =>
    var float ibHigh = na
    var float ibLow = na
    var float ibMid = na
    var int ibStartTime = 0
    var int highTime = 0
    var int lowTime = 0
    
    // Check if current bar is within the session
    bool inSess = not na(time(timeframe.period, sess, tz))
    // Detect start of a new session
    bool isNewSess = inSess and not inSess[1]
    
    if isNewSess
        ibHigh := high
        ibLow := low
        ibStartTime := time
        highTime := time
        lowTime := time
    
    // Check if current bar is within the Initial Balance window
    bool inIB = inSess and time < (ibStartTime + duration * 60 * 1000)
    
    if enabled and inSess
        if inIB
            if high > ibHigh or isNewSess
                ibHigh := high
                highTime := time
            if low < ibLow or isNewSess
                ibLow := low
                lowTime := time
            ibMid := (ibHigh + ibLow) / 2
    else
        // Reset outside session
        ibHigh := na
        ibLow := na
        ibMid := na
        
    [ibHigh, ibLow, ibMid, inIB, highTime, lowTime]

// Time formatting helper
formatT(t, tz, fmt) =>
    f = fmt == "24H" ? "HH:mm" : "hh:mm a"
    str.format_time(t, f, tz)

// Process sessions
[s1H, s1L, s1M, s1InIB, s1HT, s1LT] = calcIB(s1Enabled, s1Time, timezoneInput, ibDuration)
[s2H, s2L, s2M, s2InIB, s2HT, s2LT] = calcIB(s2Enabled, s2Time, timezoneInput, ibDuration)
[s3H, s3L, s3M, s3InIB, s3HT, s3LT] = calcIB(s3Enabled, s3Time, timezoneInput, ibDuration)

// Process opening ranges (same engine, fixed 5-min and 15-min durations)
[or5H, or5L, or5M, or5InIB, or5HT, or5LT]      = calcIB(or5Enabled, orSession, timezoneInput, 5)
[or15H, or15L, or15M, or15InIB, or15HT, or15LT] = calcIB(or15Enabled, orSession, timezoneInput, 15)

// --- Visualization ---
// Plot lines for IB levels
plot(s1Enabled ? s1H : na, "New York High", s1Color, 2, plot.style_linebr)
plot(s1Enabled ? s1L : na, "New York Low", s1Color, 2, plot.style_linebr)
plot(s1Enabled ? s1M : na, "New York Mid", color.new(s1Color, 50), 1, plot.style_linebr)

plot(s2Enabled ? s2H : na, "Asia High", s2Color, 2, plot.style_linebr)
plot(s2Enabled ? s2L : na, "Asia Low", s2Color, 2, plot.style_linebr)
plot(s2Enabled ? s2M : na, "Asia Mid", color.new(s2Color, 50), 1, plot.style_linebr)

plot(s3Enabled ? s3H : na, "London High", s3Color, 2, plot.style_linebr)
plot(s3Enabled ? s3L : na, "London Low", s3Color, 2, plot.style_linebr)
plot(s3Enabled ? s3M : na, "London Mid", color.new(s3Color, 50), 1, plot.style_linebr)

// Plot lines for Opening Range levels
plot(or5Enabled ? or5H : na, "5m OR High", or5Color, 2, plot.style_linebr)
plot(or5Enabled ? or5L : na, "5m OR Low", or5Color, 2, plot.style_linebr)
plot(or5Enabled ? or5M : na, "5m OR Mid", color.new(or5Color, 50), 1, plot.style_linebr)

plot(or15Enabled ? or15H : na, "15m OR High", or15Color, 2, plot.style_linebr)
plot(or15Enabled ? or15L : na, "15m OR Low", or15Color, 2, plot.style_linebr)
plot(or15Enabled ? or15M : na, "15m OR Mid", color.new(or15Color, 50), 1, plot.style_linebr)


// Fills for IB Range
p1H = plot(s1Enabled ? s1H : na, "NY Fill High", display = display.none)
p1L = plot(s1Enabled ? s1L : na, "NY Fill Low", display = display.none)
fill(p1H, p1L, color.new(s1Color, 90), "New York IB Area")

p2H = plot(s2Enabled ? s2H : na, "Asia Fill High", display = display.none)
p2L = plot(s2Enabled ? s2L : na, "Asia Fill Low", display = display.none)
fill(p2H, p2L, color.new(s2Color, 90), "Asia IB Area")

p3H = plot(s3Enabled ? s3H : na, "London Fill High", display = display.none)
p3L = plot(s3Enabled ? s3L : na, "London Fill Low", display = display.none)
fill(p3H, p3L, color.new(s3Color, 90), "London IB Area")

// Fills for Opening Range
pOr5H = plot(or5Enabled ? or5H : na, "5m OR Fill High", display = display.none)
pOr5L = plot(or5Enabled ? or5L : na, "5m OR Fill Low", display = display.none)
fill(pOr5H, pOr5L, color.new(or5Color, 90), "5m OR Area")

pOr15H = plot(or15Enabled ? or15H : na, "15m OR Fill High", display = display.none)
pOr15L = plot(or15Enabled ? or15L : na, "15m OR Fill Low", display = display.none)
fill(pOr15H, pOr15L, color.new(or15Color, 90), "15m OR Area")

// Background highlight for the IB period itself
bgcolor(s1Enabled and s1InIB ? color.new(s1Color, 90) : na, title = "New York IB Period")
bgcolor(s2Enabled and s2InIB ? color.new(s2Color, 90) : na, title = "Asia IB Period")
bgcolor(s3Enabled and s3InIB ? color.new(s3Color, 90) : na, title = "London IB Period")

// Background highlight for the Opening Range windows
bgcolor(or5Enabled and or5InIB ? color.new(or5Color, 85) : na, title = "5m OR Period")
bgcolor(or15Enabled and or15InIB ? color.new(or15Color, 90) : na, title = "15m OR Period")


// Label Drawing Logic
drawLabels(enabled, inIB, h, l, ht, lt, c, tz, fmt, name) =>
    // Create labels at the end of the IB period
    if enabled and not inIB and inIB[1] and showLabels
        label.new(bar_index, h, name + " High: " + str.tostring(h, format.mintick) + "\nTime: " + formatT(ht, tz, fmt), color = color.new(c, 100), textcolor = c, style = label.style_label_lower_left, size = size.small)
        label.new(bar_index, l, name + " Low: " + str.tostring(l, format.mintick) + "\nTime: " + formatT(lt, tz, fmt), color = color.new(c, 100), textcolor = c, style = label.style_label_upper_left, size = size.small)

drawLabels(s1Enabled, s1InIB, s1H, s1L, s1HT, s1LT, s1Color, timezoneInput, timeFormatInput, "IB")
drawLabels(s2Enabled, s2InIB, s2H, s2L, s2HT, s2LT, s2Color, timezoneInput, timeFormatInput, "IB")
drawLabels(s3Enabled, s3InIB, s3H, s3L, s3HT, s3LT, s3Color, timezoneInput, timeFormatInput, "IB")
drawLabels(or5Enabled, or5InIB, or5H, or5L, or5HT, or5LT, or5Color, timezoneInput, timeFormatInput, "5m OR")
drawLabels(or15Enabled, or15InIB, or15H, or15L, or15HT, or15LT, or15Color, timezoneInput, timeFormatInput, "15m OR")
````
