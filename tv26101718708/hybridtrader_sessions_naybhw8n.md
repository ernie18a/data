# HybridTrader Sessions

- url: https://www.tradingview.com/script/NayBHw8n-HybridTrader-Sessions/
- type: indicator
- pine_id: PUB;495398e18b55479a92710c19a25802af
- version: 1.0

## Description

[b]HT Sessions[/b]

HT Sessions provides a clear view of the Asian, London and New York trading sessions, helping you follow how price develops throughout the trading day.

It plots each session’s developing high and low, with optional shading to make the range easy to identify. This gives you a visual reference for assessing whether price is consolidating, extending its range or revisiting levels established earlier in the day.

Key features

[list]
[*]Session ranges: Track the highs and lows of the Asian, London and New York sessions as they develop.
[*]Range lines and optional shading: Choose how prominently session ranges appear on your chart.
[*]London/Asia “hugging” context: Highlight the relationship between London’s developing range and the Asian range, helping you recognise containment and subsequent expansion.
[*]Historical lookback: Review previous sessions to study recurring price behaviour.
[*]Customisable presentation: Control session visibility, colours and display options, with a compact information panel.
[/list]

How to use it

Start by identifying the Asian range, then observe how London behaves around its boundaries. Does price remain contained, move beyond a session high or low, or break out and return inside? Follow the New York session to see how that structure develops later in the day.

These references can support your assessment of potential breakouts, failed breaks and range expansion alongside your own trading methodology.

HT Sessions is a visual analysis tool. It does not generate standalone buy or sell recommendations, and session levels do not guarantee a particular price reaction.

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
//  T.H.E. Sessions
//  Author: firegenie (for The Hidden Edge, DovyFX mentorship group)
//  License: Mozilla Public License 2.0 https://mozilla.org/MPL/2.0/
//
//  Description:
//  • Library + implementation to visualise Asia, London, and New York sessions
//  • Includes session start/stop predicates, hugging detection (Ldn⊂Asia, Asia⊂Ldn)
//  • Uses Theme Tokens for consistent styling
//
//  Notes:
//  • Time zone: fixed UTC (matches stable implementation)
//  • Defaults: Asia 00:00–06:15, London 07:00–11:15, New York 12:00–18:00
//  • Visibility limited to last N days (user-configurable, Replay-friendly)
//  • HUD only displays when a true hugging condition is confirmed
//
//  Version: 1.0.3
//  Changes:
//  • Session time adjustments
//
//  Version: 1.0.2
//  Changes:
//  • Small asthetic changes
//
//  Version: 1.0.1
//  Changes:
//  • Fixed hugging logic so warnings only show on true containment/engulf
//  • Corrected HUD to suppress false “Asia Hugging London” messages
//  • Reworked visibility window to support TradingView Replay mode
//  • Removed unused breach flags for cleaner code
// ════════════════════════════════════════════════════════════════════════════


//@version=6
indicator(title="HybridTrader Sessions", shorttitle = "HT•Session", overlay=true, max_lines_count=500, max_labels_count=200)

var days = 0
days := ta.change(dayofmonth,1)  != 0 ? days+1 : days 

// ── Imports ──────────────────────────────────────────────────────────────────
import firegenie/HT_Sessions_Library/1 as sess
import firegenie/HT_ThemeTokens/1 as theme

// ── Display toggles (no hour inputs) ─────────────────────────────────────────
groupSess = "Sessions"
showAsia   = input.bool(true,  "Show Asia",     group=groupSess, inline="sh")
showLondon = input.bool(true,  "Show London",   group=groupSess, inline="sh")
showNY     = input.bool(true,  "Show New York", group=groupSess, inline="sh")

asiaCol = input.color(color.new(theme.colAsia, 91), "Asia Colour", group = groupSess, inline = "session_colours")
ldnCol = input.color(color.new(theme.colLdn, 91), "London Colour", group = groupSess, inline = "session_colours")
nyCol = input.color(color.new(theme.colNy, 91), "NY Colour", group = groupSess, inline = "session_colours")

groupHugging = "Hugging"
showHuggingOverlay = input.bool(true,  "Highlight London ‘hugging’", group=groupHugging, inline="hg")
showHuggingHUD     = input.bool(false, "Show status label (NY on)",   group=groupHugging, inline="hg")
accent = input.color(color.new(theme.colLdn, 60), "Hugging Highlight Colour", group = groupHugging, inline = "hg")

// ── Visibility window (render only last N days, anchored to right-edge bar) ──
groupVisibility = "Visibility"
visMode    = input.string("Auto (Live)", "Visibility mode",
              options = ["Auto (Live)", "Manual Anchor (UTC)", "Show All"], group=groupVisibility)
daysToShow = input.int(7, "Days to show", minval=1, maxval=90, group=groupVisibility)
anchorUtc = timestamp("2025-01-01 00:00 +0000") // input.time(timestamp("2025-01-01 00:00 +0000"), "Manual anchor date (UTC)", group=groupVisibility)

DAY_MS = 24 * 60 * 60 * 1000

float cutoff = na
if visMode == "Auto (Live)"
    cutoff := (timenow - (timenow % DAY_MS)) - (daysToShow - 1) * DAY_MS
else if visMode == "Manual Anchor (UTC)"
    cutoff := (anchorUtc - (anchorUtc % DAY_MS)) - (daysToShow - 1) * DAY_MS

bool visibleLastN = visMode == "Show All" or time >= cutoff



// ──  colours  ───────────────────────────────────────────

asiaFillCol = color.new(asiaCol,80)
ldnFillCol  = color.new(ldnCol,80)
nyFillCol   = color.new(nyCol,80)
hugFillCol  = accent

// ── Fixed, minute-precise specs (UTC) ────────────────────────────────────────
// Asia 00:00–06:15, London 08:00–11:00, New York 13:00–19:00
asia = sess.make("Asia",   0, 0,  6, 5)
ldn  = sess.make("London", 7, 0, 11, 5)
ny   = sess.make("NewYork",12, 0, 18, 5)

// ── Predicates (library) ─────────────────────────────────────────────────────
asia_active  = sess.in_session(asia)
asia_started = sess.session_started(asia)
asia_ended   = sess.session_ended(asia)

ldn_active   = sess.in_session(ldn)
ldn_started  = sess.session_started(ldn)
ldn_ended    = sess.session_ended(ldn)

ny_active    = sess.in_session(ny)
ny_started   = sess.session_started(ny)
ny_ended     = sess.session_ended(ny)

// ── Helpers (pure; no plots) ─────────────────────────────────────────────────
int dom = dayofmonth

// ── State (mirrors stable logic) ─────────────────────────────────────────────
var float asia_hi = na
var float asia_lo = na
var float asia_hi_end = na
var float asia_lo_end = na
var int   asia_end_dom = na

var float ldn_hi = na
var float ldn_lo = na
var float ldn_hi_end = na
var float ldn_lo_end = na
var int   ldn_end_dom = na
var bool  ldn_breachHi = false
var bool  ldn_breachLo = false
var bool  asia_breachHi = false
var bool  asia_breachLo = false
var int   ldn_hugStartBar = na
var bool  ldn_hugs_asia_confirmed = false
var bool  asia_hugs_ldn_confirmed = false

var float ny_hi = na
var float ny_lo = na
var float ny_hi_end = na
var float ny_lo_end = na
var int   ny_end_dom = na

// ── Asia range (running & latched) ───────────────────────────────────────────
if asia_started
    asia_hi := high
    asia_lo := low
else if asia_active
    asia_hi := math.max(nz(asia_hi, high), high)
    asia_lo := math.min(nz(asia_lo, low),  low)

if asia_ended
    asia_hi_end := asia_hi
    asia_lo_end := asia_lo
    asia_end_dom := dom
    asia_hi := na
    asia_lo := na

// ── London range + hugging detection ─────────────────────────────────────────
if ldn_started
    ldn_hi := high
    ldn_lo := low
    ldn_hugStartBar := na
else if ldn_active
    ldn_hi := math.max(nz(ldn_hi, high), high)
    ldn_lo := math.min(nz(ldn_lo, low),  low)

    bool haveAsia       = not na(asia_hi_end) and not na(asia_lo_end)
    bool sameDayAsAsia  = haveAsia and (asia_end_dom == dom)

    // Bar-wise truth of the three relationships
    bool ldnContainsAsia = sameDayAsAsia and haveAsia and (ldn_hi >= asia_hi_end and ldn_lo <= asia_lo_end)   // London engulfs Asia
    bool asiaContainsLdn = sameDayAsAsia and haveAsia and (ldn_hi <= asia_hi_end and ldn_lo >= asia_lo_end)   // London is inside Asia
    bool huggingNow      = ldnContainsAsia or asiaContainsLdn

    // Start/clear hugging state strictly from the above truth
    if huggingNow and na(ldn_hugStartBar)
        ldn_hugStartBar := bar_index
    if not huggingNow and not na(ldn_hugStartBar)
        ldn_hugStartBar := na

if ldn_ended
    ldn_hi_end := ldn_hi
    ldn_lo_end := ldn_lo
    ldn_end_dom := dom

    // Session-end confirmations (same logic, using end-of-session extremes)
    bool haveAsiaEnd      = not na(asia_hi_end) and not na(asia_lo_end)
    bool sameDayAsAsiaEnd = haveAsiaEnd and (ldn_end_dom == asia_end_dom)

    ldn_hugs_asia_confirmed  := sameDayAsAsiaEnd and haveAsiaEnd and (ldn_hi_end >  asia_hi_end) and (ldn_lo_end <  asia_lo_end) // London engulfs Asia
    asia_hugs_ldn_confirmed  := sameDayAsAsiaEnd and haveAsiaEnd and (ldn_hi_end <= asia_hi_end) and (ldn_lo_end >= asia_lo_end) // London inside Asia

    ldn_hi := na
    ldn_lo := na

// ── New York range (running & latched) ───────────────────────────────────────
if ny_started
    ny_hi := high
    ny_lo := low
else if ny_active
    ny_hi := math.max(nz(ny_hi, high), high)
    ny_lo := math.min(nz(ny_lo, low),  low)

if ny_ended
    ny_hi_end := ny_hi
    ny_lo_end := ny_lo
    ny_end_dom := dom
    ny_hi := na
    ny_lo := na
    // Day turnover resets confirmations (stable behaviour)
    ldn_hugs_asia_confirmed := false
    asia_hugs_ldn_confirmed := false

// ── PLOTS (global scope only) ────────────────────────────────────────────────
bool ldn_hug_now = showLondon and ldn_active and not na(ldn_hugStartBar) and bar_index >= ldn_hugStartBar

// Asia
asia_hi_plot = plot(showAsia and asia_active and visibleLastN ? asia_hi : na,
                   title="Asia High", style=plot.style_linebr, color=na)
asia_lo_plot = plot(showAsia and asia_active and visibleLastN ? asia_lo : na,
                   title="Asia Low",  style=plot.style_linebr, color=na)
fill(asia_hi_plot, asia_lo_plot, color=asiaFillCol, title="Asia Session Fill")

// London
ldn_hi_plot  = plot(showLondon and ldn_active and visibleLastN ? ldn_hi : na,
                   title="London High", style=plot.style_linebr, color=na)
ldn_lo_plot  = plot(showLondon and ldn_active and visibleLastN ? ldn_lo : na,
                   title="London Low",  style=plot.style_linebr, color=na)
fill(ldn_hi_plot, ldn_lo_plot, color=ldnFillCol, title="London Session Fill")

// London hugging overlay
ldn_hi_plot_hug = plot(showLondon and showHuggingOverlay and ldn_hug_now and visibleLastN ? ldn_hi : na,
                   title="London High (hug)", style=plot.style_linebr, color=na)
ldn_lo_plot_hug = plot(showLondon and showHuggingOverlay and ldn_hug_now and visibleLastN ? ldn_lo : na,
                   title="London Low (hug)",  style=plot.style_linebr, color=na)
fill(ldn_hi_plot_hug, ldn_lo_plot_hug, color=hugFillCol, title="London Session Fill (hug)")

// New York
ny_hi_plot   = plot(showNY and ny_active and visibleLastN ? ny_hi : na,
                   title="NY High", style=plot.style_linebr, color=na)
ny_lo_plot   = plot(showNY and ny_active and visibleLastN ? ny_lo : na,
                   title="NY Low",  style=plot.style_linebr, color=na)
fill(ny_hi_plot, ny_lo_plot, color=nyFillCol, title="New York Session Fill")

// HUD — only display if a hug is actually confirmed
var label hug_warning = na

bool huggingConfirmed = (ldn_hugs_asia_confirmed or asia_hugs_ldn_confirmed)

if showHuggingHUD and ny_active and visibleLastN and barstate.islast and huggingConfirmed
    string msg = ldn_hugs_asia_confirmed ? "London Hugging Asia\n(Do not enter any trades)"
                                         : "Asia Hugging London\n(Do not enter any trades)"
    float yMid = (ny_hi + ny_lo) / 2
    if na(hug_warning)
        hug_warning := label.new(x=bar_index + 1, y=yMid,
               text=msg, color=theme.colAccent, textcolor=theme.txtAccent,
               style=label.style_label_left, size=size.normal)
    else
        label.set_x(hug_warning, bar_index + 1)
        label.set_y(hug_warning, yMid)
        label.set_text(hug_warning, msg)
else
    if not na(hug_warning)
        label.delete(hug_warning)
        hug_warning := na
````
