# Anchor rails - session levels and event countdown [AuraSznfx]

- url: https://www.tradingview.com/script/e3ydtssB-Anchor-rails-session-levels-and-event-countdown-AuraSznfx/
- type: indicator
- pine_id: PUB;4f2076e04d9c4dd4b9ac08ebe1ad1160
- version: 1.0

## Description

Most intraday trading is organized around a handful of scheduled clock times — the London open, the 8:30 and 10:00 data releases, the cash open, the end of the first hour, the 2:00 policy release. This script makes that schedule visible on the chart instead of tracked in your head, and pairs it with the price levels that formed before each one.

There are many scripts that draw session highs and lows. What this one adds is the clock layer on top of them: a countdown to the next scheduled anchor, a phase read-out describing where the current bar sits relative to that anchor, a configurable window marked either side of it, and a running count of how many of the day's tracked levels have already been taken.


WHAT IT DRAWS

Five session ranges: overnight, London, premarket, opening range, and first hour. Each window's start and end time is a session input you can change, so the defaults are a starting point rather than a rule. While a window is open the script tracks its running high and low and shows them as a box. When the window closes, the box is deleted and replaced by two horizontal lines fixed at the final high and low, extended forward a configurable number of bars.

Yesterday's high, low and close, pulled from the daily timeframe with lookahead disabled. An optional midpoint is available.


HOW THE LEVEL-TAKEN LOGIC WORKS

Once a range is locked, each of its two lines is watched independently. The high is marked taken the first time a bar's high exceeds it. The low is marked taken the first time a bar's low falls below it. Detection is one-way and permanent for the session — a level does not un-take itself if price returns.

When a level is taken you can have it dim to a configurable transparency, dim and switch its label to a marked state, or delete outright. That choice is a style preference; the underlying state is tracked the same way regardless.

Note the deliberate limitation: detection uses the bar's high and low, so on a live bar a level can register as taken and then the bar can close back inside the range. If you want confirmed-close behavior instead, use a higher timeframe or wait for the bar to close before acting on the alert.


HOW THE ANCHOR CLOCK WORKS

You enable whichever of the nine preset times you care about, plus one custom hour and minute of your own. Every one is read in the timezone you select at the top of the settings.

On each bar the script builds a timestamp for every enabled anchor on the current date, then finds the nearest one ahead of the current bar close and the nearest one behind it. From those two distances it produces four outputs in the panel:

Time to the next anchor, formatted as a countdown.

A progress bar filling over the final 30 minutes before it.

A phase label, resolved in this priority order: inside the post-anchor window, within 15 minutes after, inside the pre-anchor window, inside 10 minutes, inside 30 minutes, otherwise standby.

A taken count out of the ten tracked level lines.

If every enabled anchor for the day has passed, the countdown rolls to the earliest one on the following day.

The event window is the pre and post minute values you set. When the current bar falls inside it, the chart is optionally tinted, and an alert can fire once as it begins. Nothing about this window predicts direction. It marks that a scheduled release is close, which is information you would otherwise be checking a calendar for.


HOW TO USE IT

Set your timezone first; everything else reads from it. Adjust the five session windows to the instrument you trade — the defaults are built around US index futures on New York time and will not suit an FX or crypto session structure without changes. Then switch off the anchor times that aren't relevant to your market.

The levels show where price has already been tested. The clock shows when the next scheduled event arrives. What you do with either is your decision — this script issues no buy or sell signals and takes no view on direction.


ALERTS

Two alert condition entries are provided, for any level taken and for the event window opening, usable from the standard alert dialog. Individual per-level alerts fire through the alert() function on bar close. Payloads can be sent as plain text or as structured JSON for webhook use, toggled in the settings.


NOTES AND LIMITATIONS

Written in Pine v6.

Locked levels do not repaint. A range only becomes lines after its window has closed, and those values never change afterward.

The daily request uses lookahead_off. No future data is accessed anywhere in the script.

The phase labels describe clock position only. They are not signals and carry no expectation of what price will do.

The script has no view on direction and produces no entry or exit signals. It is a context tool.

On very low timeframes the drawing limits of 500 lines, boxes and labels can be reached over a long history. Reduce the extend-right value or switch off sessions you do not need.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
//  Anchor Rails - session levels and scheduled-event countdown
//
//  Author:  AuraSznfx
//  Written from scratch. No third-party or open-source code is reused here.
//
//  This source code is subject to the terms of the Mozilla Public License 2.0
//  at https://mozilla.org/MPL/2.0/
//
//  If you reuse any part of this script, TradingView House Rules require that
//  you credit the author, make significant improvements to the original code
//  base (renaming variables, changing inputs, restyling or rearranging code
//  does not qualify), keep it a small proportion of your script, and publish
//  your result open-source unless the author grants written permission
//  otherwise. Reuse in a closed-source or invite-only script requires the
//  author's explicit prior permission.
//
//  What it does:
//  Tracks the high and low of five configurable intraday windows, locks each
//  one into a pair of levels when its window closes, marks a level as taken
//  when price trades through it, and runs a countdown to the next scheduled
//  anchor time with a phase read-out for where the current bar sits relative
//  to it.
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator('Anchor rails - session levels and event countdown [AuraSznfx]', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//─────────────────────────────────────────────────────────────────────────────
// ◈ THEME
//─────────────────────────────────────────────────────────────────────────────
_gTheme = "◈ Theme"

themeChoice = input.string("Neon Cyber", "◈ Color Theme", group = _gTheme, options = ["Neon Cyber", "Midnight Aura", "Sunset Blaze", "Ocean Depth", "Ghost Protocol", "Classic", "Neon Violet", "Plasma", "Blade Runner", "Toxic", "Ghost Wire", "Midnight Blue", "Ember Gold", "Stealth Dark", "Clean Light", "Custom"], tooltip = "Sets the whole colour palette at once.")
tintMode    = input.string("Spectrum", "↳ Rail Colouring", options = ["Spectrum", "Unified"], group = _gTheme, tooltip = "Spectrum gives every session its own shade pulled from the theme.\nUnified paints all highs one colour and all lows another.")

cuHigh    = input.color(#FF1744, "↳ Custom High",    group = _gTheme)
cuLow     = input.color(#00E676, "↳ Custom Low",     group = _gTheme)
cuAccent  = input.color(#FFEA00, "↳ Custom Accent",  group = _gTheme)
cuNeutral = input.color(#78909C, "↳ Custom Neutral", group = _gTheme)

railTransp = input.int(10, "◈ Rail Fade",  minval = 0, maxval = 90, group = _gTheme)
glowOn     = input.bool(true, "◈ Beam Glow", group = _gTheme, tooltip = "Adds a soft halo around every rail so levels read at a glance.")
glowSize   = input.float(1.2, "↳ Glow Spread (% of price)", minval = 0.1, maxval = 10, step = 0.1, group = _gTheme)
glowTransp = input.int(90, "↳ Glow Fade", minval = 60, maxval = 99, group = _gTheme)

cHigh = switch themeChoice
    "Neon Cyber"     => #FF1744
    "Midnight Aura"  => #F472B6
    "Sunset Blaze"   => #EF4444
    "Ocean Depth"    => #F97316
    "Ghost Protocol" => #52525B
    "Classic"        => #F23645
    "Neon Violet"    => #FF4081
    "Plasma"         => #FF006E
    "Blade Runner"   => #448AFF
    "Toxic"          => #D500F9
    "Ghost Wire"     => #FF8A80
    "Midnight Blue"  => #FF6B6B
    "Ember Gold"     => #FF6E40
    "Stealth Dark"   => #EF9A9A
    "Clean Light"    => #C62828
    "Custom"         => cuHigh

cLow = switch themeChoice
    "Neon Cyber"     => #00E676
    "Midnight Aura"  => #6366F1
    "Sunset Blaze"   => #FBBF24
    "Ocean Depth"    => #22D3EE
    "Ghost Protocol" => #A1A1AA
    "Classic"        => #089981
    "Neon Violet"    => #B388FF
    "Plasma"         => #00FFF5
    "Blade Runner"   => #FFAB40
    "Toxic"          => #76FF03
    "Ghost Wire"     => #84FFFF
    "Midnight Blue"  => #00B0FF
    "Ember Gold"     => #FFD740
    "Stealth Dark"   => #A5D6A7
    "Clean Light"    => #2E7D32
    "Custom"         => cuLow

cAccent = switch themeChoice
    "Neon Cyber"     => #FFEA00
    "Midnight Aura"  => #A78BFA
    "Sunset Blaze"   => #FB923C
    "Ocean Depth"    => #38BDF8
    "Ghost Protocol" => #D4D4D8
    "Classic"        => #FF9800
    "Neon Violet"    => #E040FB
    "Plasma"         => #FFD60A
    "Blade Runner"   => #FF6E40
    "Toxic"          => #C6FF00
    "Ghost Wire"     => #EEFF41
    "Midnight Blue"  => #FFD166
    "Ember Gold"     => #FFAB00
    "Stealth Dark"   => #FFE082
    "Clean Light"    => #EF6C00
    "Custom"         => cuAccent

cNeutral = switch themeChoice
    "Neon Cyber"     => #78909C
    "Midnight Aura"  => #64748B
    "Sunset Blaze"   => #9A8478
    "Ocean Depth"    => #64748B
    "Ghost Protocol" => #71717A
    "Classic"        => #787B86
    "Neon Violet"    => #8D8FA6
    "Plasma"         => #5C6B73
    "Blade Runner"   => #607D8B
    "Toxic"          => #7A8B6F
    "Ghost Wire"     => #78909C
    "Midnight Blue"  => #546E7A
    "Ember Gold"     => #8D6E63
    "Stealth Dark"   => #6D7B6E
    "Clean Light"    => #90A4AE
    "Custom"         => cuNeutral

// Spectrum ramp — five on-palette shades derived from the active theme
f_ramp(int i) =>
    float t = i / 5.0
    t < 0.5 ? color.from_gradient(t, 0.0, 0.5, cLow, cAccent) : color.from_gradient(t, 0.5, 1.0, cAccent, cHigh)

//─────────────────────────────────────────────────────────────────────────────
// ◈ SESSIONS
//─────────────────────────────────────────────────────────────────────────────
_gSess = "◈ Sessions"

tzStr = input.string("America/New_York", "◈ Timezone", options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Asia/Tokyo", "UTC"], group = _gSess, tooltip = "All session windows and anchor times below are read in this timezone.")

onOn    = input.bool(true,  "◈ Overnight Range",  group = _gSess, tooltip = "High and low of the overnight window, while the US cash session is closed.")
onSess  = input.session("1800-0930", "↳ Window", group = _gSess)

ldOn    = input.bool(true,  "◈ London Range",     group = _gSess, tooltip = "High and low of the window you define as the London portion of the day.")
ldSess  = input.session("0300-0500", "↳ Window", group = _gSess)

pmOn    = input.bool(true,  "◈ Premarket Range",  group = _gSess, tooltip = "High and low of the window immediately preceding the cash open.")
pmSess  = input.session("0800-0930", "↳ Window", group = _gSess)

orOn    = input.bool(true,  "◈ Opening Range",    group = _gSess, tooltip = "High and low of the first minutes after the cash open.")
orSess  = input.session("0930-0945", "↳ Window", group = _gSess)

ibOn    = input.bool(true,  "◈ First Hour Range", group = _gSess, tooltip = "Initial balance: the high and low of the first hour of the cash session.")
ibSess  = input.session("0930-1030", "↳ Window", group = _gSess)

pdOn    = input.bool(true,  "◈ Yesterday High / Low / Close", group = _gSess)
pdMid   = input.bool(false, "↳ Also Show Midpoint", group = _gSess)

//─────────────────────────────────────────────────────────────────────────────
// ◈ RAIL STYLE
//─────────────────────────────────────────────────────────────────────────────
_gRail = "◈ Rail Style"

railStyleStr = input.string("Solid", "◈ Line Style", options = ["Solid", "Dashed", "Dotted"], group = _gRail)
railWidth    = input.int(2, "◈ Line Width", minval = 1, maxval = 4, group = _gRail)
showMid      = input.bool(false, "◈ Show Middle Of Each Range", group = _gRail)
showLiveBox  = input.bool(true, "◈ Show Range While It Builds", group = _gRail, tooltip = "Draws a box over the session as it forms, then locks it into two lines when the window closes.")
extendBars   = input.int(40, "◈ Extend Right (bars)", minval = 2, maxval = 500, group = _gRail)
tagMode      = input.string("Plain", "◈ Level Names", options = ["Plain", "Short Code"], group = _gRail, tooltip = "Plain = NIGHT HIGH.  Short Code = ONH.")
showTags     = input.bool(true, "◈ Show Level Names", group = _gRail)
tagSizeStr   = input.string("Small", "↳ Text Size", options = ["Tiny", "Small", "Normal"], group = _gRail)

//─────────────────────────────────────────────────────────────────────────────
// ◈ TAKEN LEVELS
//─────────────────────────────────────────────────────────────────────────────
_gSweep = "◈ Taken Levels"

sweepOn    = input.bool(true, "◈ Mark Levels When Taken", group = _gSweep, tooltip = "When price trades through a level it is dimmed, marked, and can fire an alert. Detection is one-way and permanent for the session.")
sweepMode  = input.string("Dim + Mark", "↳ What To Do", options = ["Dim + Mark", "Dim Only", "Delete"], group = _gSweep)
sweepFade  = input.int(72, "↳ How Faded", minval = 30, maxval = 95, group = _gSweep)
sweepAlert = input.bool(true, "↳ Alert When Taken", group = _gSweep)

//─────────────────────────────────────────────────────────────────────────────
// ◈ ANCHOR CLOCK
//─────────────────────────────────────────────────────────────────────────────
_gClock = "◈ Anchor Clock"

clockOn = input.bool(true, "◈ Show Countdown Panel", group = _gClock, tooltip = "Counts down to the next enabled anchor time and reports which phase of the run-up the current bar falls in.")
clockPos = input.string("Top Right", "↳ Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = _gClock)
clockSize = input.string("Small", "↳ Text Size", options = ["Tiny", "Small", "Normal"], group = _gClock)

a0300 = input.bool(true,  "↳ 03:00  London Open",    group = _gClock)
a0830 = input.bool(true,  "↳ 08:30  Data Release",   group = _gClock)
a0930 = input.bool(true,  "↳ 09:30  Cash Open",      group = _gClock)
a1000 = input.bool(true,  "↳ 10:00  Data Release",   group = _gClock)
a1030 = input.bool(true,  "↳ 10:30  First Hour End", group = _gClock)
a1130 = input.bool(false, "↳ 11:30  Midday",         group = _gClock)
a1400 = input.bool(true,  "↳ 14:00  Policy Release", group = _gClock)
a1550 = input.bool(false, "↳ 15:50  Late Session",   group = _gClock)
a1600 = input.bool(false, "↳ 16:00  Cash Close",     group = _gClock)

cusOn = input.bool(false, "↳ Custom Anchor", group = _gClock)
cusH  = input.int(9, "  ↳ Hour",   minval = 0, maxval = 23, group = _gClock)
cusM  = input.int(50, "  ↳ Minute", minval = 0, maxval = 59, group = _gClock)

//─────────────────────────────────────────────────────────────────────────────
// ◈ EVENT WINDOW
//─────────────────────────────────────────────────────────────────────────────
_gThin = "◈ Event Window"

thinOn   = input.bool(true, "◈ Mark Window Around Each Anchor", group = _gThin, tooltip = "Highlights a configurable band of minutes either side of each enabled anchor time, so scheduled events are visible on the chart rather than tracked in your head.")
thinPre  = input.int(2, "↳ Minutes Before", minval = 1, maxval = 30, group = _gThin)
thinPost = input.int(2, "↳ Minutes After",  minval = 0, maxval = 30, group = _gThin)
thinTint = input.bool(true, "↳ Tint The Chart", group = _gThin)
thinFade = input.int(90, "  ↳ Tint Fade", minval = 70, maxval = 99, group = _gThin)

//─────────────────────────────────────────────────────────────────────────────
// ◈ ALERTS
//─────────────────────────────────────────────────────────────────────────────
_gAlert = "◈ Alerts"
useJson = input.bool(true, "◈ Send Structured JSON", group = _gAlert, tooltip = "On: alerts fire a structured JSON payload for webhooks. Off: plain readable text.")

//─────────────────────────────────────────────────────────────────────────────
// ◈ HELPERS
//─────────────────────────────────────────────────────────────────────────────
f_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        => position.top_right

f_lineStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_padR(string s, int w) =>
    string o = s
    while str.length(o) < w
        o := o + " "
    o

f_padL(string s, int w) =>
    string o = s
    while str.length(o) < w
        o := " " + o
    o

f_hms(int secs) =>
    int s = math.max(secs, 0)
    int h = s / 3600
    int m = s % 3600 / 60
    int x = s % 60
    string mm = (m < 10 ? "0" : "") + str.tostring(m)
    string ss = (x < 10 ? "0" : "") + str.tostring(x)
    h > 0 ? str.tostring(h) + ":" + mm + ":" + ss : mm + ":" + ss

f_bar(float frac, int cells) =>
    int filled = math.max(0, math.min(cells, int(math.round(frac * cells))))
    str.repeat("▰", filled) + str.repeat("▱", cells - filled)

tagSz  = f_sz(tagSizeStr)
lnStyle = f_lineStyle(railStyleStr)
int barMs = timeframe.in_seconds(timeframe.period) * 1000
float glowPx = close * (glowSize / 100.0) * 0.5

f_payload(string evt, string lvlName, float px, string extra) =>
    useJson ? '{"indicator":"ANCHOR_RAILS","event":"' + evt + '","level":"' + lvlName + '","ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","price":' + str.tostring(px, format.mintick) + ',"note":"' + extra + '","time":' + str.tostring(time) + '}' : "Anchor rails - " + evt + " " + lvlName + " on " + syminfo.ticker + " at " + str.tostring(px, format.mintick) + (extra == "" ? "" : " (" + extra + ")")

//─────────────────────────────────────────────────────────────────────────────
// ◈ RAIL OBJECT
//─────────────────────────────────────────────────────────────────────────────
type Rail
    float hi     = na
    float lo     = na
    int   tStart = na
    bool  live   = false
    bool  locked = false
    bool  swHi   = false
    bool  swLo   = false
    line  lnHi
    line  lnLo
    line  lnMid
    box   bxLive
    box   glHi
    box   glLo
    label lbHi
    label lbLo

f_clear(Rail r) =>
    line.delete(r.lnHi)
    line.delete(r.lnLo)
    line.delete(r.lnMid)
    box.delete(r.bxLive)
    box.delete(r.glHi)
    box.delete(r.glLo)
    label.delete(r.lbHi)
    label.delete(r.lbLo)
    r.lnHi := na
    r.lnLo := na
    r.lnMid := na
    r.bxLive := na
    r.glHi := na
    r.glLo := na
    r.lbHi := na
    r.lbLo := na

// Returns: 0 = nothing, 1 = high taken this bar, -1 = low taken this bar
f_rail(Rail r, string sess, bool on, color cH, color cL, string tHi, string tLo) =>
    int  ev  = 0
    if not on
        if r.live or r.locked
            f_clear(r)
            r.live := false
            r.locked := false
    else
        bool inS  = not na(time(timeframe.period, sess, tzStr))
        int  rgt  = time_close + barMs * extendBars

        // ── Window opens: wipe yesterday's copy, start tracking ──
        if inS and not r.live
            f_clear(r)
            r.live   := true
            r.locked := false
            r.swHi   := false
            r.swLo   := false
            r.hi     := high
            r.lo     := low
            r.tStart := time
            if showLiveBox
                r.bxLive := box.new(r.tStart, r.hi, time_close, r.lo, xloc = xloc.bar_time, border_color = color.new(cAccent, 55), bgcolor = color.new(cAccent, 92), border_style = line.style_dashed, border_width = 1)

        // ── Window running: grow the range ──
        else if inS and r.live
            r.hi := math.max(r.hi, high)
            r.lo := math.min(r.lo, low)
            if not na(r.bxLive)
                box.set_top(r.bxLive, r.hi)
                box.set_bottom(r.bxLive, r.lo)
                box.set_right(r.bxLive, time_close)
                box.set_border_color(r.bxLive, color.new(cAccent, 55))
                box.set_bgcolor(r.bxLive, color.new(cAccent, 92))

        // ── Window closes: lock the rails in ──
        else if r.live and not inS
            r.live   := false
            r.locked := true
            box.delete(r.bxLive)
            r.bxLive := na

            r.lnHi := line.new(r.tStart, r.hi, rgt, r.hi, xloc = xloc.bar_time, color = color.new(cH, railTransp), style = lnStyle, width = railWidth)
            r.lnLo := line.new(r.tStart, r.lo, rgt, r.lo, xloc = xloc.bar_time, color = color.new(cL, railTransp), style = lnStyle, width = railWidth)
            if showMid
                float md = math.avg(r.hi, r.lo)
                r.lnMid := line.new(r.tStart, md, rgt, md, xloc = xloc.bar_time, color = color.new(cNeutral, 45), style = line.style_dotted, width = 1)
            if glowOn
                r.glHi := box.new(r.tStart, r.hi + glowPx, rgt, r.hi - glowPx, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(cH, glowTransp))
                r.glLo := box.new(r.tStart, r.lo + glowPx, rgt, r.lo - glowPx, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(cL, glowTransp))
            if showTags
                r.lbHi := label.new(rgt, r.hi, tHi + "  " + str.tostring(r.hi, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 25), textcolor = cH, size = tagSz, text_font_family = font.family_monospace)
                r.lbLo := label.new(rgt, r.lo, tLo + "  " + str.tostring(r.lo, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 25), textcolor = cL, size = tagSz, text_font_family = font.family_monospace)

        // ── Locked: extend, restyle for live theme, watch for the take ──
        if r.locked
            // Detection first so styling below reflects it on the same bar
            if sweepOn
                if not r.swHi and high > r.hi
                    r.swHi := true
                    ev := 1
                if not r.swLo and low < r.lo
                    r.swLo := true
                    ev := ev == 1 ? 1 : -1

            bool killHi = r.swHi and sweepMode == "Delete"
            bool killLo = r.swLo and sweepMode == "Delete"

            color useH = r.swHi ? color.new(cH, sweepFade) : color.new(cH, railTransp)
            color useL = r.swLo ? color.new(cL, sweepFade) : color.new(cL, railTransp)

            if killHi
                line.delete(r.lnHi)
                r.lnHi := na
                box.delete(r.glHi)
                r.glHi := na
                label.delete(r.lbHi)
                r.lbHi := na
            if killLo
                line.delete(r.lnLo)
                r.lnLo := na
                box.delete(r.glLo)
                r.glLo := na
                label.delete(r.lbLo)
                r.lbLo := na

            if not na(r.lnHi)
                line.set_x2(r.lnHi, rgt)
                line.set_color(r.lnHi, useH)
                line.set_style(r.lnHi, r.swHi ? line.style_dotted : lnStyle)
            if not na(r.lnLo)
                line.set_x2(r.lnLo, rgt)
                line.set_color(r.lnLo, useL)
                line.set_style(r.lnLo, r.swLo ? line.style_dotted : lnStyle)
            if not na(r.lnMid)
                line.set_x2(r.lnMid, rgt)
                line.set_color(r.lnMid, color.new(cNeutral, 45))
            if not na(r.glHi)
                box.set_right(r.glHi, rgt)
                box.set_top(r.glHi, r.hi + glowPx)
                box.set_bottom(r.glHi, r.hi - glowPx)
                box.set_bgcolor(r.glHi, color.new(cH, r.swHi ? 97 : glowTransp))
            if not na(r.glLo)
                box.set_right(r.glLo, rgt)
                box.set_top(r.glLo, r.lo + glowPx)
                box.set_bottom(r.glLo, r.lo - glowPx)
                box.set_bgcolor(r.glLo, color.new(cL, r.swLo ? 97 : glowTransp))
            if not na(r.lbHi)
                label.set_x(r.lbHi, rgt)
                label.set_textcolor(r.lbHi, useH)
                label.set_text(r.lbHi, (r.swHi and sweepMode == "Dim + Mark" ? "x " : "") + tHi + "  " + str.tostring(r.hi, format.mintick))
            if not na(r.lbLo)
                label.set_x(r.lbLo, rgt)
                label.set_textcolor(r.lbLo, useL)
                label.set_text(r.lbLo, (r.swLo and sweepMode == "Dim + Mark" ? "x " : "") + tLo + "  " + str.tostring(r.lo, format.mintick))
    ev

//─────────────────────────────────────────────────────────────────────────────
// ◈ RAIL INSTANCES
//─────────────────────────────────────────────────────────────────────────────
var Rail rON = Rail.new()
var Rail rLD = Rail.new()
var Rail rPM = Rail.new()
var Rail rOR = Rail.new()
var Rail rIB = Rail.new()

bool plain = tagMode == "Plain"

// Colours resolved every bar so theme swaps reach every draw call
color onH = tintMode == "Unified" ? cHigh : f_ramp(0)
color onL = tintMode == "Unified" ? cLow  : f_ramp(0)
color ldH = tintMode == "Unified" ? cHigh : f_ramp(1)
color ldL = tintMode == "Unified" ? cLow  : f_ramp(1)
color pmH = tintMode == "Unified" ? cHigh : f_ramp(2)
color pmL = tintMode == "Unified" ? cLow  : f_ramp(2)
color orH = tintMode == "Unified" ? cHigh : f_ramp(3)
color orL = tintMode == "Unified" ? cLow  : f_ramp(3)
color ibH = tintMode == "Unified" ? cHigh : f_ramp(4)
color ibL = tintMode == "Unified" ? cLow  : f_ramp(4)

int evON = f_rail(rON, onSess, onOn, onH, onL, plain ? "NIGHT HIGH" : "ONH", plain ? "NIGHT LOW"  : "ONL")
int evLD = f_rail(rLD, ldSess, ldOn, ldH, ldL, plain ? "LONDON HIGH" : "LDH", plain ? "LONDON LOW" : "LDL")
int evPM = f_rail(rPM, pmSess, pmOn, pmH, pmL, plain ? "PRE HIGH"   : "PMH", plain ? "PRE LOW"    : "PML")
int evOR = f_rail(rOR, orSess, orOn, orH, orL, plain ? "OPEN TOP"   : "ORH", plain ? "OPEN BOTTOM": "ORL")
int evIB = f_rail(rIB, ibSess, ibOn, ibH, ibL, plain ? "HOUR TOP"   : "IBH", plain ? "HOUR BOTTOM": "IBL")

//─────────────────────────────────────────────────────────────────────────────
// ◈ YESTERDAY'S LEVELS
//─────────────────────────────────────────────────────────────────────────────
[pdH, pdL, pdC] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]], barmerge.gaps_off, barmerge.lookahead_off)

var line pdHi = na
var line pdLo = na
var line pdCl = na
var line pdMd = na
var label pdHiL = na
var label pdLoL = na
var label pdClL = na

if barstate.islast
    line.delete(pdHi)
    line.delete(pdLo)
    line.delete(pdCl)
    line.delete(pdMd)
    label.delete(pdHiL)
    label.delete(pdLoL)
    label.delete(pdClL)
    if pdOn and not na(pdH)
        int lft = time_close - barMs * 200
        int rgt = time_close + barMs * extendBars
        pdHi := line.new(lft, pdH, rgt, pdH, xloc = xloc.bar_time, color = color.new(cHigh, railTransp + 15), style = line.style_dashed, width = 1)
        pdLo := line.new(lft, pdL, rgt, pdL, xloc = xloc.bar_time, color = color.new(cLow,  railTransp + 15), style = line.style_dashed, width = 1)
        pdCl := line.new(lft, pdC, rgt, pdC, xloc = xloc.bar_time, color = color.new(cNeutral, 30), style = line.style_dashed, width = 1)
        if pdMid
            float md = math.avg(pdH, pdL)
            pdMd := line.new(lft, md, rgt, md, xloc = xloc.bar_time, color = color.new(cNeutral, 60), style = line.style_dotted, width = 1)
        if showTags
            pdHiL := label.new(rgt, pdH, (plain ? "YESTERDAY HIGH" : "PDH") + "  " + str.tostring(pdH, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 25), textcolor = cHigh, size = tagSz, text_font_family = font.family_monospace)
            pdLoL := label.new(rgt, pdL, (plain ? "YESTERDAY LOW"  : "PDL") + "  " + str.tostring(pdL, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 25), textcolor = cLow, size = tagSz, text_font_family = font.family_monospace)
            pdClL := label.new(rgt, pdC, (plain ? "YESTERDAY CLOSE": "PDC") + "  " + str.tostring(pdC, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 25), textcolor = cNeutral, size = tagSz, text_font_family = font.family_monospace)

//─────────────────────────────────────────────────────────────────────────────
// ◈ ANCHOR CLOCK
//─────────────────────────────────────────────────────────────────────────────
var array<int>    anH = array.new<int>()
var array<int>    anM = array.new<int>()
var array<string> anN = array.new<string>()

if barstate.isfirst
    if a0300
        array.push(anH, 3)
        array.push(anM, 0)
        array.push(anN, "LONDON OPEN")
    if a0830
        array.push(anH, 8)
        array.push(anM, 30)
        array.push(anN, "DATA RELEASE")
    if a0930
        array.push(anH, 9)
        array.push(anM, 30)
        array.push(anN, "CASH OPEN")
    if a1000
        array.push(anH, 10)
        array.push(anM, 0)
        array.push(anN, "DATA RELEASE")
    if a1030
        array.push(anH, 10)
        array.push(anM, 30)
        array.push(anN, "HOUR END")
    if a1130
        array.push(anH, 11)
        array.push(anM, 30)
        array.push(anN, "MIDDAY")
    if a1400
        array.push(anH, 14)
        array.push(anM, 0)
        array.push(anN, "POLICY RELEASE")
    if a1550
        array.push(anH, 15)
        array.push(anM, 50)
        array.push(anN, "LATE SESSION")
    if a1600
        array.push(anH, 16)
        array.push(anM, 0)
        array.push(anN, "CASH CLOSE")
    if cusOn
        array.push(anH, cusH)
        array.push(anM, cusM)
        array.push(anN, "CUSTOM")

int    nextTs   = na
string nextName = "-"
int    prevTs   = na
string prevName = "-"

if array.size(anH) > 0
    int Y  = year(time_close, tzStr)
    int Mo = month(time_close, tzStr)
    int Dd = dayofmonth(time_close, tzStr)
    int earliest = na
    for i = 0 to array.size(anH) - 1
        int ts = timestamp(tzStr, Y, Mo, Dd, array.get(anH, i), array.get(anM, i), 0)
        if na(earliest) or ts < earliest
            earliest := ts
        if ts > time_close and (na(nextTs) or ts < nextTs)
            nextTs   := ts
            nextName := array.get(anN, i)
        if ts <= time_close and (na(prevTs) or ts > prevTs)
            prevTs   := ts
            prevName := array.get(anN, i)
    if na(nextTs) and not na(earliest)
        nextTs   := earliest + 86400000
        nextName := "TOMORROW"

int secsTo   = na(nextTs) ? na : int((nextTs - time_close) / 1000)
int secsFrom = na(prevTs) ? na : int((time_close - prevTs) / 1000)

// Phase state machine — describes position relative to the nearest anchor
string clockState = "STANDBY"
color  clockCol   = cNeutral
if not na(secsFrom) and secsFrom <= thinPost * 60
    clockState := "IN WINDOW"
    clockCol   := cHigh
else if not na(secsFrom) and secsFrom <= 900
    clockState := "POST-EVENT"
    clockCol   := cLow
else if not na(secsTo) and secsTo <= thinPre * 60
    clockState := "PRE-EVENT WINDOW"
    clockCol   := cHigh
else if not na(secsTo) and secsTo <= 600
    clockState := "T-10 MIN"
    clockCol   := cAccent
else if not na(secsTo) and secsTo <= 1800
    clockState := "T-30 MIN"
    clockCol   := cAccent

bool inThin = thinOn and ((not na(secsTo) and secsTo <= thinPre * 60) or (not na(secsFrom) and secsFrom <= thinPost * 60))

bgcolor(inThin and thinTint ? color.new(cHigh, thinFade) : na, title = "Event Window Tint")

// Taken counter
int sweptCount = (rON.swHi ? 1 : 0) + (rON.swLo ? 1 : 0) + (rLD.swHi ? 1 : 0) + (rLD.swLo ? 1 : 0) + (rPM.swHi ? 1 : 0) + (rPM.swLo ? 1 : 0) + (rOR.swHi ? 1 : 0) + (rOR.swLo ? 1 : 0) + (rIB.swHi ? 1 : 0) + (rIB.swLo ? 1 : 0)

//─────────────────────────────────────────────────────────────────────────────
// ◈ COUNTDOWN PANEL
//─────────────────────────────────────────────────────────────────────────────
var table hud = table.new(f_pos(clockPos), 2, 6, border_width = 1, frame_width = 1, frame_color = color.new(cAccent, 45), border_color = color.new(cNeutral, 80))

if clockOn and barstate.islast
    color bgH = color.new(cAccent, 88)
    color bgC = color.new(chart.bg_color, 15)
    string sz = clockSize
    float frac = na(secsTo) ? 0.0 : 1.0 - math.min(1.0, secsTo / 1800.0)

    table.cell(hud, 0, 0, "ANCHOR",    bgcolor = bgH, text_color = cAccent, text_size = f_sz(sz), text_halign = text.align_left)
    table.cell(hud, 1, 0, "RAILS",     bgcolor = bgH, text_color = cAccent, text_size = f_sz(sz), text_halign = text.align_right)

    table.cell(hud, 0, 1, "NEXT",      bgcolor = bgC, text_color = cNeutral, text_size = f_sz(sz), text_halign = text.align_left)
    table.cell(hud, 1, 1, nextName,    bgcolor = bgC, text_color = chart.fg_color, text_size = f_sz(sz), text_halign = text.align_right)

    table.cell(hud, 0, 2, "IN",        bgcolor = bgC, text_color = cNeutral, text_size = f_sz(sz), text_halign = text.align_left)
    table.cell(hud, 1, 2, na(secsTo) ? "-" : f_hms(secsTo), bgcolor = bgC, text_color = clockCol, text_size = f_sz(sz), text_halign = text.align_right)

    table.cell(hud, 0, 3, "",          bgcolor = bgC, text_color = cNeutral, text_size = f_sz(sz), text_halign = text.align_left)
    table.cell(hud, 1, 3, f_bar(frac, 10), bgcolor = bgC, text_color = clockCol, text_size = f_sz(sz), text_halign = text.align_right)

    table.cell(hud, 0, 4, "PHASE",     bgcolor = bgC, text_color = cNeutral, text_size = f_sz(sz), text_halign = text.align_left)
    table.cell(hud, 1, 4, clockState,  bgcolor = bgC, text_color = clockCol, text_size = f_sz(sz), text_halign = text.align_right)

    table.cell(hud, 0, 5, "TAKEN",     bgcolor = bgC, text_color = cNeutral, text_size = f_sz(sz), text_halign = text.align_left)
    table.cell(hud, 1, 5, str.tostring(sweptCount) + " / 10", bgcolor = bgC, text_color = sweptCount > 0 ? cAccent : cNeutral, text_size = f_sz(sz), text_halign = text.align_right)

//─────────────────────────────────────────────────────────────────────────────
// ◈ ALERTS
//─────────────────────────────────────────────────────────────────────────────
if sweepAlert and evON != 0
    alert(f_payload("TAKEN", evON == 1 ? "NIGHT_HIGH" : "NIGHT_LOW", close, clockState), alert.freq_once_per_bar_close)
if sweepAlert and evLD != 0
    alert(f_payload("TAKEN", evLD == 1 ? "LONDON_HIGH" : "LONDON_LOW", close, clockState), alert.freq_once_per_bar_close)
if sweepAlert and evPM != 0
    alert(f_payload("TAKEN", evPM == 1 ? "PREMARKET_HIGH" : "PREMARKET_LOW", close, clockState), alert.freq_once_per_bar_close)
if sweepAlert and evOR != 0
    alert(f_payload("TAKEN", evOR == 1 ? "OPEN_RANGE_HIGH" : "OPEN_RANGE_LOW", close, clockState), alert.freq_once_per_bar_close)
if sweepAlert and evIB != 0
    alert(f_payload("TAKEN", evIB == 1 ? "FIRST_HOUR_HIGH" : "FIRST_HOUR_LOW", close, clockState), alert.freq_once_per_bar_close)

bool thinStart = inThin and not inThin[1]
if thinStart
    alert(f_payload("EVENT_WINDOW", nextName, close, "entering window around " + nextName), alert.freq_once_per_bar)

bool anySweep = evON != 0 or evLD != 0 or evPM != 0 or evOR != 0 or evIB != 0
alertcondition(anySweep,  title = "Any level taken",    message = "Anchor rails - a tracked level was just taken")
alertcondition(thinStart, title = "Event window start", message = "Anchor rails - entering the window around the next anchor time")
````
