# Kill Zone Marker [DYNA]

- url: https://www.tradingview.com/script/YuiuhlaB-Kill-Zone-Marker-DYNA/
- type: indicator
- pine_id: PUB;061fa342c6f9417b914ec61340a0de79
- version: 1.0

## Description

Kill Zone Marker highlights the three intraday windows that drive the bulk of daily volatility on FX, indices, and crypto: the [b]London Open[/b] (07:00-10:00 UTC), the [b]New York Open[/b] (13:00-16:00 UTC), and the [b]London Close[/b] (15:00-17:00 UTC). Each kill zone gets its own translucent background band so the active high-volatility window is obvious at a glance.

At the start of every kill zone, a small label is posted above the chart showing the rolling average bar-range from the last N completed sessions of that same zone. Use the average as your "expected move" reference -- a target inside it is conservative, a target much beyond it is asking the market to do more than it usually does in that window. All three windows, the timezone they are interpreted in, and the lookback length are user-configurable.


[b]Key Features[/b]

[list]
[*] [b]Three Configurable Kill Zones[/b] -- London Open, New York Open, and London Close windows with independent colors, toggles, and timing. Free-text session strings let you customize each window without code edits.
[*] [b]Rolling Average Range Per Zone[/b] -- Each zone-start label shows the rolling average bar-range across the last N completed sessions of that zone (default N=20). Tells you at a glance whether the current zone is unfolding hot, cold, or about as expected.
[*] [b]Editable Timezone[/b] -- Interpret all three windows in UTC (default), New York, London, Tokyo, Sydney, Kolkata, or any other major financial center.
[*] [b]Color-Coded Legend[/b] -- Optional corner table maps each band color to its kill zone so the chart is always self-explanatory, even before the next zone opens.
[*] [b]Per-Zone Start and End Alerts[/b] -- Six independent alerts (start + end for each of the three zones) so you can tune which transitions you actually want to be notified about.
[*] [b]Theme-Aware Transparency[/b] -- Single transparency input controls all three kill-zone bands together. Tune for bright or dark chart themes.
[*] [b]No Repainting[/b] -- Detection is purely time-based and stable across reloads. The rolling average uses only completed prior sessions; the current zone's in-progress range never feeds back into its own label.
[/list]


[b]How It Works[/b]

For each bar, the indicator checks whether the bar's timestamp (interpreted in the configured timezone) falls inside the London Open, NY Open, or London Close window. If a bar is inside a zone, the chart background for that bar is tinted with that zone's color. The NY Open and London Close windows overlap by default (15:00-16:00 UTC) -- the two band colors stack so the overlap is visible without a separate band.

Zone starts are detected with a daily-anchor timestamp comparison rather than a simple "previous bar was outside the zone" check. This is important because most TradingView intraday charts hide off-hours bars by default, so a naive previous-bar test would only fire on the very first chart load. The anchor-comparison method works reliably whether the chart includes off-hours bars or not.

While inside a zone, the indicator tracks the running high and low across all in-zone bars for that session. When the zone closes, that session's range (high - low) is appended to a rolling array of the last N session ranges and the in-progress trackers reset. The label posted at the start of the [i]next[/i] occurrence of the same zone reads the average from the array -- so it is always backward-looking and never includes the current zone's incomplete data.

[image]https://www.tradingview.com/x/kehF8DHN/[/image]
[i]Three colored background bands mark the London Open, NY Open, and London Close kill zones; small labels at each zone-open report the rolling average range from prior sessions. The legend in the top corner identifies the band-to-zone color mapping.[/i]


[b]Settings[/b]

The three kill-zone strings are entered in TradingView's standard HHMM-HHMM session format and accept the optional day-of-week mask (e.g. [b]0700-1000:23456[/b] to limit London Open to weekdays only). All three windows are interpreted in the same [b]Timezone[/b], which defaults to UTC. The catalog defaults match the standard EST kill-zone definitions (02:00-05:00, 08:00-11:00, 10:00-12:00 EST) converted to UTC.

The [b]Average Range Lookback[/b] input controls how many completed sessions feed each zone's rolling average. Defaults to 20; lower values track the current regime more closely, higher values give a more stable baseline.

The visual block exposes per-zone show toggles, per-zone color pickers, a single [b]Background Transparency[/b] input (default 85), the [b]Show Average-Range Labels[/b] toggle, a [b]Max Labels to Keep[/b] limit (default 40), the [b]Show Legend Table[/b] toggle, and a [b]Legend Position[/b] dropdown that anchors the legend in any chart corner.

The alerts block exposes six toggles -- start and end for each zone -- so you can enable only the transitions you care about.


[b]Alerts[/b]

[list]
[*] [b]London Open Kill Zone Starting[/b] -- Fires on the first bar of the London Open window each day. [i]"Kill Zone Marker [DYNA]: London Open kill zone has started."[/i]
[*] [b]London Open Kill Zone Ending[/b] -- Fires on the first bar after the London Open window closes. [i]"Kill Zone Marker [DYNA]: London Open kill zone has ended."[/i]
[*] [b]NY Open Kill Zone Starting[/b] -- Fires on the first bar of the NY Open window. [i]"Kill Zone Marker [DYNA]: New York Open kill zone has started."[/i]
[*] [b]NY Open Kill Zone Ending[/b] -- Fires on the first bar after the NY Open window closes. [i]"Kill Zone Marker [DYNA]: New York Open kill zone has ended."[/i]
[*] [b]London Close Kill Zone Starting[/b] -- Fires on the first bar of the London Close window. [i]"Kill Zone Marker [DYNA]: London Close kill zone has started."[/i]
[*] [b]London Close Kill Zone Ending[/b] -- Fires on the first bar after the London Close window closes. [i]"Kill Zone Marker [DYNA]: London Close kill zone has ended."[/i]
[/list]

To set up an alert: open TradingView's Alerts panel, choose "Kill Zone Marker [DYNA]" from the condition dropdown, pick the event you want, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Keep the timezone on UTC unless you have a specific reason to change it. UTC eliminates DST drift and matches how institutional desks reference kill-zone windows.
[*] Use the rolling average as your "expected move" reference for each zone -- targets and stops sized to that average tend to behave more predictably than fixed-pip values.
[*] On dark chart themes, lower the background transparency to 75-82 for stronger color. On light themes, push it up to 88-92 so the bands stay readable.
[*] On instruments that only trade inside one window (e.g. a regional equity market whose session overlaps a single kill zone), turn off the irrelevant kill zones to reduce visual clutter.
[*] If your broker or instrument has a non-standard high-volatility window (e.g. EIA inventory release for energy futures, FOMC release for rates), repurpose one of the three zones to that window -- the rolling average makes any custom window's typical behavior immediately visible.
[*] Use the day-of-week mask (e.g. [b]0700-1000:23456[/b]) to suppress weekend kill-zone bands on forex charts.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Kill Zone Marker is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Kill Zone Marker [DYNA]
// Highlights the three highest-probability intraday volatility windows (London Open, NY Open, London Close) and shows each zone's rolling average range.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Kill Zone Marker [DYNA]", shorttitle = "KZM [DYNA]", overlay = true,
         max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

color LO_DEFAULT = #26c6da  // London Open kill zone — cyan
color NO_DEFAULT = #ab47bc  // New York Open kill zone — purple
color LC_DEFAULT = #ffa726  // London Close kill zone — amber

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
string i_loSession = input.session("0700-1000", "London Open Kill Zone",  group = GRP_CORE, tooltip = "London Open kill zone window. Default 07:00-10:00 UTC = 02:00-05:00 EST. The first burst of European participation, historically the most active window for GBP and EUR pairs.")
string i_noSession = input.session("1300-1600", "New York Open Kill Zone", group = GRP_CORE, tooltip = "New York Open kill zone window. Default 13:00-16:00 UTC = 08:00-11:00 EST. US open + the first hour of cash-equity flow; typically the strongest directional window for USD pairs and US indices.")
string i_lcSession = input.session("1500-1700", "London Close Kill Zone", group = GRP_CORE, tooltip = "London Close kill zone window. Default 15:00-17:00 UTC = 10:00-12:00 EST. The European close drives end-of-day positioning and frequently produces sharp reversals.")
string i_timezone  = input.string("UTC", "Timezone",
                                  options = ["UTC", "America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "Asia/Singapore", "Asia/Kolkata", "Australia/Sydney"],
                                  group = GRP_CORE, tooltip = "Timezone used to interpret all three kill-zone strings. Defaults to UTC; the catalog defaults match standard EST kill-zone definitions converted to UTC.")
int    i_avgPeriod = input.int(20, "Average Range Lookback (sessions)", minval = 1, maxval = 200, step = 1, group = GRP_CORE, tooltip = "Number of completed kill-zone sessions used to compute each zone's rolling average range. The label shown at the start of each kill zone reports this average.")

// --- Visual ---
bool  i_showLO     = input.bool(true,        "Show London Open Zone",   group = GRP_VIS, tooltip = "Toggle the London Open background band and label.")
color i_loColor    = input.color(LO_DEFAULT, "London Open Color",       group = GRP_VIS, tooltip = "Background tint color for the London Open kill zone.")
bool  i_showNO     = input.bool(true,        "Show New York Open Zone", group = GRP_VIS, tooltip = "Toggle the New York Open background band and label.")
color i_noColor    = input.color(NO_DEFAULT, "New York Open Color",     group = GRP_VIS, tooltip = "Background tint color for the New York Open kill zone.")
bool  i_showLC     = input.bool(true,        "Show London Close Zone",  group = GRP_VIS, tooltip = "Toggle the London Close background band and label.")
color i_lcColor    = input.color(LC_DEFAULT, "London Close Color",      group = GRP_VIS, tooltip = "Background tint color for the London Close kill zone.")
int   i_bgTransp   = input.int(85, "Background Transparency", minval = 50, maxval = 95, step = 1, group = GRP_VIS, tooltip = "Higher = more transparent background fill. Lower values give stronger color but may overpower other indicators on the chart.")
bool  i_showLabels = input.bool(true, "Show Average-Range Labels",       group = GRP_VIS, tooltip = "Place a small label above the bar that opens each kill zone, showing the zone name and the rolling average range from prior sessions.")
int   i_maxLabels  = input.int(40, "Max Labels to Keep", minval = 1, maxval = 200, step = 1, group = GRP_VIS, tooltip = "How many kill-zone labels to keep on the chart. Older labels are deleted automatically.")
bool  i_showLegend = input.bool(true, "Show Legend Table",               group = GRP_VIS, tooltip = "Show a small color-coded legend in the chosen chart corner so the band-to-zone mapping is always visible without waiting for a zone to open.")
string i_legendPos = input.string("Top Right", "Legend Position",
                                  options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"],
                                  group = GRP_VIS, tooltip = "Anchor corner for the legend table.")

// --- Alerts ---
bool i_alertLOStart = input.bool(true, "Alert: London Open Starting",  group = GRP_ALERT, tooltip = "Fire on the first bar of the London Open kill zone each day.")
bool i_alertLOEnd   = input.bool(true, "Alert: London Open Ending",    group = GRP_ALERT, tooltip = "Fire on the first bar after the London Open kill zone closes.")
bool i_alertNOStart = input.bool(true, "Alert: NY Open Starting",      group = GRP_ALERT, tooltip = "Fire on the first bar of the New York Open kill zone each day.")
bool i_alertNOEnd   = input.bool(true, "Alert: NY Open Ending",        group = GRP_ALERT, tooltip = "Fire on the first bar after the New York Open kill zone closes.")
bool i_alertLCStart = input.bool(true, "Alert: London Close Starting", group = GRP_ALERT, tooltip = "Fire on the first bar of the London Close kill zone each day.")
bool i_alertLCEnd   = input.bool(true, "Alert: London Close Ending",   group = GRP_ALERT, tooltip = "Fire on the first bar after the London Close kill zone closes.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Kill-zone detection ---
// `time("D", session, tz)` returns a daily anchor for every bar inside the
// configured session window and `na` otherwise. Comparing the anchor to the
// prior bar's anchor reliably identifies the first bar of a new zone even on
// charts that hide off-hours bars (the default for most TradingView intraday
// charts). See memory file pine_session_detection.md for context.
int  loDay = time("D", i_loSession, i_timezone)
int  noDay = time("D", i_noSession, i_timezone)
int  lcDay = time("D", i_lcSession, i_timezone)

bool inLO = not na(loDay)
bool inNO = not na(noDay)
bool inLC = not na(lcDay)

bool startLO = inLO and (na(loDay[1]) or loDay != loDay[1])
bool startNO = inNO and (na(noDay[1]) or noDay != noDay[1])
bool startLC = inLC and (na(lcDay[1]) or lcDay != lcDay[1])

// "Ending" fires on the first bar after the zone closes — the previous bar was
// inside the zone and the current bar is outside. This means the published
// average range and any in-zone observations are complete.
bool endLO = not inLO and not na(loDay[1])
bool endNO = not inNO and not na(noDay[1])
bool endLC = not inLC and not na(lcDay[1])

// --- Per-zone running average range ---
// On the first in-zone bar we seed dayHigh/dayLow with the bar's own high/low.
// On subsequent in-zone bars we extend them. On the bar where the zone ends we
// push (dayHigh - dayLow) onto the rolling array, then trim to i_avgPeriod.
zoneRange(bool isStart, bool isIn, bool isEnd, float curHigh, float curLow, array<float> ranges, int lookback) =>
    var float dh = na
    var float dl = na
    if isStart
        dh := curHigh
        dl := curLow
    else if isIn
        dh := math.max(nz(dh, curHigh), curHigh)
        dl := math.min(nz(dl, curLow),  curLow)
    if isEnd and not na(dh) and not na(dl)
        array.push(ranges, dh - dl)
        while array.size(ranges) > lookback
            array.shift(ranges)
        dh := na
        dl := na
    array.size(ranges) > 0 ? array.avg(ranges) : na

var array<float> loRanges = array.new<float>()
var array<float> noRanges = array.new<float>()
var array<float> lcRanges = array.new<float>()

float loAvg = zoneRange(startLO, inLO, endLO, high, low, loRanges, i_avgPeriod)
float noAvg = zoneRange(startNO, inNO, endNO, high, low, noRanges, i_avgPeriod)
float lcAvg = zoneRange(startLC, inLC, endLC, high, low, lcRanges, i_avgPeriod)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Background bands ---
bgcolor(i_showLO and inLO ? color.new(i_loColor, i_bgTransp) : na, title = "London Open Zone")
bgcolor(i_showNO and inNO ? color.new(i_noColor, i_bgTransp) : na, title = "NY Open Zone")
bgcolor(i_showLC and inLC ? color.new(i_lcColor, i_bgTransp) : na, title = "London Close Zone")

// --- Zone-start labels with rolling average range ---
labelText(string name, float avg) =>
    na(avg) ? name + "\nAvg: —" : name + "\nAvg: " + str.tostring(avg, format.mintick)

var array<label> labelHandles = array.new<label>()

if i_showLabels and barstate.isconfirmed
    if startLO and i_showLO
        array.push(labelHandles, label.new(bar_index, na, labelText("London Open",  loAvg), yloc = yloc.abovebar, style = label.style_label_down, color = i_loColor, textcolor = color.white, size = size.small))
    if startNO and i_showNO
        array.push(labelHandles, label.new(bar_index, na, labelText("NY Open",      noAvg), yloc = yloc.abovebar, style = label.style_label_down, color = i_noColor, textcolor = color.white, size = size.small))
    if startLC and i_showLC
        array.push(labelHandles, label.new(bar_index, na, labelText("London Close", lcAvg), yloc = yloc.abovebar, style = label.style_label_down, color = i_lcColor, textcolor = color.white, size = size.small))
    while array.size(labelHandles) > i_maxLabels
        label old = array.shift(labelHandles)
        if not na(old)
            label.delete(old)

// --- Legend table ---
// Rebuilt on the last bar so position / color / toggle changes pick up immediately.
var table legend = na

if barstate.islast
    if not na(legend)
        table.delete(legend)
        legend := na
    if i_showLegend
        pos = switch i_legendPos
            "Top Left"     => position.top_left
            "Top Right"    => position.top_right
            "Middle Left"  => position.middle_left
            "Middle Right" => position.middle_right
            "Bottom Left"  => position.bottom_left
            "Bottom Right" => position.bottom_right
            =>                position.top_right
        int rowsCount = (i_showLO ? 1 : 0) + (i_showNO ? 1 : 0) + (i_showLC ? 1 : 0)
        if rowsCount > 0
            legend := table.new(pos, 1, rowsCount, border_width = 1, border_color = color.new(NEUTRAL_COLOR, 60))
            int r = 0
            if i_showLO
                table.cell(legend, 0, r, " London Open ",  bgcolor = color.new(i_loColor, 25), text_color = color.white, text_size = size.small)
                r := r + 1
            if i_showNO
                table.cell(legend, 0, r, " NY Open ",      bgcolor = color.new(i_noColor, 25), text_color = color.white, text_size = size.small)
                r := r + 1
            if i_showLC
                table.cell(legend, 0, r, " London Close ", bgcolor = color.new(i_lcColor, 25), text_color = color.white, text_size = size.small)
                r := r + 1

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(startLO and i_alertLOStart, title = "London Open Kill Zone Starting",  message = "Kill Zone Marker [DYNA]: London Open kill zone has started.")
alertcondition(endLO   and i_alertLOEnd,   title = "London Open Kill Zone Ending",    message = "Kill Zone Marker [DYNA]: London Open kill zone has ended.")
alertcondition(startNO and i_alertNOStart, title = "NY Open Kill Zone Starting",      message = "Kill Zone Marker [DYNA]: New York Open kill zone has started.")
alertcondition(endNO   and i_alertNOEnd,   title = "NY Open Kill Zone Ending",        message = "Kill Zone Marker [DYNA]: New York Open kill zone has ended.")
alertcondition(startLC and i_alertLCStart, title = "London Close Kill Zone Starting", message = "Kill Zone Marker [DYNA]: London Close kill zone has started.")
alertcondition(endLC   and i_alertLCEnd,   title = "London Close Kill Zone Ending",   message = "Kill Zone Marker [DYNA]: London Close kill zone has ended.")
````
