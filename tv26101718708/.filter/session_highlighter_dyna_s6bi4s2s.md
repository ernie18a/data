# Session Highlighter [DYNA]

- url: https://www.tradingview.com/script/S6Bi4S2S-Session-Highlighter-DYNA/
- type: indicator
- pine_id: PUB;79abb80b3b1b498ab1b010e287424724
- version: 1.0

## Description

Session Highlighter color-codes the chart background by the three major global trading sessions -- Asia (Tokyo), London, and New York -- so the active session is obvious at a glance and the handovers between them are unmistakable. A separate overlap band highlights the 13:00-16:00 UTC window when London and New York are simultaneously open, the most volatile FX period of the day. Each session-open is also marked with a small color-coded label above the first bar of the session.

Sessions are configured as free-text time windows interpreted in a user-selected timezone. Default windows match the standard FX session calendar in UTC, but every value -- session times, colors, transparency, alerts -- is editable. The indicator works identically on forex, crypto, futures, and any intraday equity chart that overlaps with one or more global sessions.


[b]Key Features[/b]

[list]
[*] [b]Three Configurable Sessions[/b] -- Asia, London, and New York windows with independent colors, toggles, and timing. Free-text session strings let you customize each window without code edits.
[*] [b]London-NY Overlap Highlight[/b] -- A dedicated overlap band marks the bars where London and NY are simultaneously open -- statistically the highest-volatility FX window of the day.
[*] [b]Editable Timezone[/b] -- Interpret all three sessions in UTC (default), New York, London, Tokyo, Sydney, or any other major financial center.
[*] [b]Session-Open Labels[/b] -- A small label appears above the bar that opens each session, with a configurable history limit so the chart never gets cluttered.
[*] [b]Color-Coded Legend[/b] -- Optional corner table maps each band color to its session (Asia, London, NY, LDN+NY) so the chart is always self-explanatory, even before the next session opens.
[*] [b]Per-Session Alerts[/b] -- Fire alerts independently for Asia open, London open, NY open, and the London-NY overlap start.
[*] [b]Theme-Aware Transparency[/b] -- Single transparency input controls all session bands together. Tune for bright or dark chart themes.
[*] [b]No Repainting[/b] -- Session detection is purely time-based and stable across reloads. Bands and labels never move.
[/list]


[b]How It Works[/b]

For each bar, the indicator checks whether the bar's timestamp (interpreted in the configured timezone) falls inside the Asia, London, and New York session windows. If a bar is inside a session, the chart background for that bar is tinted with the session's color. If a bar is inside both London and New York, an additional overlap tint is layered on top, rendered slightly less transparent than the individual session bands so it stands out from the underlying London and NY layers.

Session opens are detected with a daily-anchor timestamp comparison rather than a simple "previous bar was outside the session" check. This is important because most TradingView intraday charts hide off-hours bars by default, so a naive previous-bar test would only fire on the very first chart load. The anchor-comparison method works reliably whether the chart includes off-hours bars or not.

When a new session opens, the indicator places a small color-coded label ([i]Asia[/i], [i]London[/i], [i]NY[/i], or [i]LDN+NY[/i]) above the first bar of the session. The overlap label reads [b]LDN+NY[/b] rather than a generic "Overlap" so the two source sessions are always explicit. Old labels are deleted automatically once the chart has more than the configured maximum, so the visual stays clean even on very long histories.

[image]SNAPSHOT_URL_SESSION_HIGHLIGHTER_BANDS_AND_OVERLAP[/image]
[i]Three colored background bands mark the Asia, London, and New York sessions; the brighter overlap band marks the bars where London and NY are simultaneously open. Small labels above the chart announce each session open.[/i]


[b]Settings[/b]

The three session strings are entered in TradingView's standard HHMM-HHMM session format and accept the optional day-of-week mask (e.g. [b]0700-1600:23456[/b] to limit London to weekdays only). All three windows are interpreted in the same [b]Timezone[/b], which defaults to UTC. Switch the timezone dropdown if you prefer to express the sessions in local exchange time -- the indicator will then anchor the session boundaries to that timezone, including DST handling.

The visual block exposes per-session show toggles, per-session color pickers, the [b]London-NY Overlap[/b] toggle and color, a single [b]Background Transparency[/b] input (default 88), the [b]Show Session Labels[/b] toggle, a [b]Max Labels to Keep[/b] limit (default 30), the [b]Show Legend Table[/b] toggle, and a [b]Legend Position[/b] dropdown that anchors the legend in any chart corner. The overlap band is rendered with 10 less transparency than the configured value so it remains visible when stacked on top of the London and NY bands.

The alerts block exposes one toggle per event so you can enable only the alerts you care about.


[b]Alerts[/b]

[list]
[*] [b]Asia Session Open[/b] -- Fires on the first bar of the Asia session each day. [i]"Session Highlighter [DYNA]: Asia (Tokyo) session has opened."[/i]
[*] [b]London Session Open[/b] -- Fires on the first bar of the London session each day. [i]"Session Highlighter [DYNA]: London session has opened."[/i]
[*] [b]NY Session Open[/b] -- Fires on the first bar of the New York session each day. [i]"Session Highlighter [DYNA]: New York session has opened."[/i]
[*] [b]London-NY Overlap Start[/b] -- Fires on the first bar where London and NY are both open. [i]"Session Highlighter [DYNA]: London-New York overlap window has started."[/i]
[/list]

To set up an alert: open TradingView's Alerts panel, choose "Session Highlighter [DYNA]" from the condition dropdown, pick the event you want, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Keep the timezone on UTC unless you have a specific reason to change it. UTC eliminates DST drift and matches how institutional desks reference session windows.
[*] On dark chart themes, lower the background transparency to 80-85 for stronger session colors. On light themes, push it up to 90-95 so the bands stay readable.
[*] The London-NY overlap is the highest-volatility FX window of the day. Expect larger ranges and consider tighter risk parameters during this band.
[*] On markets that only trade inside one session (e.g. Indian equities cover only Asia/early-London), turn off the irrelevant session bands to reduce clutter.
[*] If your broker uses a non-standard session window, just edit the session string -- the indicator picks up the change immediately, including the overlap.
[*] Use the day-of-week mask (e.g. [b]0700-1600:23456[/b]) to suppress weekend session bands on forex charts.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Session Highlighter is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis tool, not financial advice. Always use proper position sizing and risk management.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Session Highlighter [DYNA]
// Color-codes the chart background by major trading sessions (Asia, London, New York) and highlights the London-NY overlap.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Session Highlighter [DYNA]", shorttitle = "SH [DYNA]", overlay = true,
         max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

color ASIA_DEFAULT    = #f9a825
color LONDON_DEFAULT  = #5c6bc0
color NY_DEFAULT      = #66bb6a
color OVERLAP_DEFAULT = #e91e63

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
string i_asiaSession   = input.session("0000-0900", "Asia (Tokyo) Session", group = GRP_CORE, tooltip = "Tokyo session window. Default 00:00-09:00 covers the standard Tokyo FX session in the selected timezone.")
string i_londonSession = input.session("0700-1600", "London Session",        group = GRP_CORE, tooltip = "London session window. Default 07:00-16:00 covers the standard London FX session in the selected timezone.")
string i_nySession     = input.session("1300-2200", "New York Session",      group = GRP_CORE, tooltip = "New York session window. Default 13:00-22:00 covers the standard NY FX session in the selected timezone.")
string i_timezone      = input.string("UTC",        "Timezone",              options = ["UTC", "America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "Asia/Singapore", "Asia/Kolkata", "Australia/Sydney"], group = GRP_CORE, tooltip = "Timezone used to interpret all three session strings. Defaults to UTC; switch to a regional timezone if you prefer to express the session windows in local time.")

// --- Visual ---
bool  i_showAsia       = input.bool(true,             "Show Asia Session",       group = GRP_VIS, tooltip = "Toggle the Asia (Tokyo) background band.")
color i_asiaColor      = input.color(ASIA_DEFAULT,    "Asia Color",              group = GRP_VIS, tooltip = "Background tint color for the Asia session.")
bool  i_showLondon     = input.bool(true,             "Show London Session",     group = GRP_VIS, tooltip = "Toggle the London background band.")
color i_londonColor    = input.color(LONDON_DEFAULT,  "London Color",            group = GRP_VIS, tooltip = "Background tint color for the London session.")
bool  i_showNY         = input.bool(true,             "Show New York Session",   group = GRP_VIS, tooltip = "Toggle the New York background band.")
color i_nyColor        = input.color(NY_DEFAULT,      "NY Color",                group = GRP_VIS, tooltip = "Background tint color for the New York session.")
bool  i_showOverlap    = input.bool(true,             "Show London-NY Overlap",  group = GRP_VIS, tooltip = "Highlight the bars where London and New York are simultaneously open. Historically the most volatile FX window of the day.")
color i_overlapColor   = input.color(OVERLAP_DEFAULT, "Overlap Color",           group = GRP_VIS, tooltip = "Background tint color for the London-NY overlap.")
int   i_bgTransparency = input.int(88, "Background Transparency", minval = 50, maxval = 95, step = 1, group = GRP_VIS, tooltip = "Higher = more transparent background fill. The overlap band is rendered slightly less transparent so it stands out from the individual session bands.")
bool   i_showLabels    = input.bool(true,             "Show Session Labels",     group = GRP_VIS, tooltip = "Place a small label above the bar that opens each session.")
int    i_maxLabels     = input.int(30, "Max Labels to Keep", minval = 1, maxval = 200, step = 1, group = GRP_VIS, tooltip = "How many session-open labels to keep on the chart. Older labels are deleted automatically.")
bool   i_showLegend    = input.bool(true,             "Show Legend Table",       group = GRP_VIS, tooltip = "Show a small color-coded legend in the chosen chart corner so the band-to-session mapping is always visible without waiting for a session to open.")
string i_legendPos     = input.string("Top Right",    "Legend Position",         options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = GRP_VIS, tooltip = "Anchor corner for the legend table.")

// --- Alerts ---
bool i_alertAsia    = input.bool(true, "Alert: Asia Session Open",       group = GRP_ALERT, tooltip = "Fire an alert on the first bar of the Asia session each day.")
bool i_alertLondon  = input.bool(true, "Alert: London Session Open",     group = GRP_ALERT, tooltip = "Fire an alert on the first bar of the London session each day.")
bool i_alertNY      = input.bool(true, "Alert: NY Session Open",         group = GRP_ALERT, tooltip = "Fire an alert on the first bar of the New York session each day.")
bool i_alertOverlap = input.bool(true, "Alert: London-NY Overlap Start", group = GRP_ALERT, tooltip = "Fire an alert on the first bar where London and NY are simultaneously open.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Session detection ---
// `time("D", session, tz)` returns a daily-anchor timestamp for every bar inside
// the configured session window and `na` otherwise. Comparing the anchor to the
// prior bar's anchor reliably identifies the first bar of a new session even on
// charts that hide off-hours bars (the default for most intraday TradingView
// charts). See memory file pine_session_detection.md for context.
int  asiaDay   = time("D", i_asiaSession,   i_timezone)
int  londonDay = time("D", i_londonSession, i_timezone)
int  nyDay     = time("D", i_nySession,     i_timezone)

bool inAsia   = not na(asiaDay)
bool inLondon = not na(londonDay)
bool inNY     = not na(nyDay)

bool newAsia   = inAsia   and (na(asiaDay[1])   or asiaDay   != asiaDay[1])
bool newLondon = inLondon and (na(londonDay[1]) or londonDay != londonDay[1])
bool newNY     = inNY     and (na(nyDay[1])     or nyDay     != nyDay[1])

// --- London-NY overlap ---
// `nz()` doesn't accept bool in Pine v6, so track the prior bar's overlap state
// in a `var` flag instead. Initial value `false` means the first in-overlap bar
// after script load is treated as a fresh overlap start.
var bool prevOverlap = false
bool inOverlap  = inLondon and inNY
bool newOverlap = inOverlap and not prevOverlap
prevOverlap := inOverlap

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Background bands ---
bgcolor(i_showAsia    and inAsia    ? color.new(i_asiaColor,    i_bgTransparency) : na, title = "Asia Session")
bgcolor(i_showLondon  and inLondon  ? color.new(i_londonColor,  i_bgTransparency) : na, title = "London Session")
bgcolor(i_showNY      and inNY      ? color.new(i_nyColor,      i_bgTransparency) : na, title = "NY Session")
bgcolor(i_showOverlap and inOverlap ? color.new(i_overlapColor, math.max(i_bgTransparency - 10, 50)) : na, title = "London-NY Overlap")

// --- Session-open labels ---
var array<label> labelHandles = array.new<label>()

if i_showLabels and barstate.isconfirmed
    if newAsia
        array.push(labelHandles, label.new(bar_index, na, "Asia",    yloc = yloc.abovebar, style = label.style_label_down, color = i_asiaColor,    textcolor = color.white, size = size.small))
    if newLondon
        array.push(labelHandles, label.new(bar_index, na, "London",  yloc = yloc.abovebar, style = label.style_label_down, color = i_londonColor,  textcolor = color.white, size = size.small))
    if newNY
        array.push(labelHandles, label.new(bar_index, na, "NY",      yloc = yloc.abovebar, style = label.style_label_down, color = i_nyColor,      textcolor = color.white, size = size.small))
    if newOverlap and i_showOverlap
        array.push(labelHandles, label.new(bar_index, na, "LDN+NY", yloc = yloc.abovebar, style = label.style_label_down, color = i_overlapColor, textcolor = color.white, size = size.small))
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
        int rowsCount = (i_showAsia ? 1 : 0) + (i_showLondon ? 1 : 0) + (i_showNY ? 1 : 0) + (i_showOverlap ? 1 : 0)
        if rowsCount > 0
            legend := table.new(pos, 1, rowsCount, border_width = 1, border_color = color.new(NEUTRAL_COLOR, 60))
            int r = 0
            if i_showAsia
                table.cell(legend, 0, r, " Asia ",   bgcolor = color.new(i_asiaColor,    25), text_color = color.white, text_size = size.small)
                r := r + 1
            if i_showLondon
                table.cell(legend, 0, r, " London ", bgcolor = color.new(i_londonColor,  25), text_color = color.white, text_size = size.small)
                r := r + 1
            if i_showNY
                table.cell(legend, 0, r, " NY ",     bgcolor = color.new(i_nyColor,      25), text_color = color.white, text_size = size.small)
                r := r + 1
            if i_showOverlap
                table.cell(legend, 0, r, " LDN+NY ", bgcolor = color.new(i_overlapColor, 25), text_color = color.white, text_size = size.small)
                r := r + 1

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(newAsia    and i_alertAsia,    title = "Asia Session Open",       message = "Session Highlighter [DYNA]: Asia (Tokyo) session has opened.")
alertcondition(newLondon  and i_alertLondon,  title = "London Session Open",     message = "Session Highlighter [DYNA]: London session has opened.")
alertcondition(newNY      and i_alertNY,      title = "New York Session Open",   message = "Session Highlighter [DYNA]: New York session has opened.")
alertcondition(newOverlap and i_alertOverlap, title = "London-NY Overlap Start", message = "Session Highlighter [DYNA]: London-New York overlap window has started.")
````
