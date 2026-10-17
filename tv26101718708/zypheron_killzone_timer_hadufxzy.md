# Zypheron Killzone Timer

- url: https://www.tradingview.com/script/HAdUfxzy/
- type: indicator
- pine_id: PUB;32617aa35bcf40afb434502371de5933
- version: 1.0

## Description

Hier die Beschreibung für den Killzone Timer:

Title:
Zypheron – Killzone Timer
Short Description:
Highlights the London Open and New York Open Kill Zones directly on your chart — the most powerful trading windows of the day.

Full Description:
⚡ ZYPHERON – KILLZONE TIMER
Liquidity. Structure. Edge.

Automatically highlights the two most important Kill Zones 
of the trading day — London Open and New York Open.
No more missing the highest probability trading windows.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ London Open Kill Zone (07:00 – 09:00 UTC)
✅ New York Open Kill Zone (13:00 – 15:00 UTC)
✅ Dynamic box expands with price action
✅ Session label inside the box
✅ Fully customizable colors and times
✅ Works on all timeframes and instruments

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT ARE KILL ZONES?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Kill Zones are specific time windows where institutional 
players are most active. During these periods the market 
tends to hunt liquidity and create the major moves of the day.
Identifying them is a core concept in SMC & ICT trading.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Start/End hours fully adjustable (UTC)
🎨 Custom colors per Kill Zone
🏷️ Toggle labels on/off
📏 Works best on 1min – 1H charts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PART OF THE ZYPHERON SUITE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This is a free script. Follow for more tools built around 
Liquidity & Structure trading.

🔗 More scripts coming daily.

## Source Code

````pine
//@version=6
indicator("Zypheron – Killzone Timer", shorttitle="ZYPHERON KZ", overlay=true, max_boxes_count=100, max_labels_count=50)

// ═══════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════

var g_lon = "🇬🇧 London Open Killzone"
showLON    = input.bool(true, "Show London Open KZ",   group=g_lon)
lonKZStart = input.int(7,     "Start Hour (UTC)",       group=g_lon, minval=0, maxval=23)
lonKZEnd   = input.int(9,     "End Hour (UTC)",         group=g_lon, minval=0, maxval=23)
lonKZColor = input.color(color.new(#4FC3F7, 88), "London KZ Color", group=g_lon)
lonBorder  = input.color(color.new(#4FC3F7, 40), "London Border",   group=g_lon)

var g_ny = "🗽 New York Open Killzone"
showNY     = input.bool(true, "Show New York Open KZ", group=g_ny)
nyKZStart  = input.int(13,    "Start Hour (UTC)",       group=g_ny, minval=0, maxval=23)
nyKZEnd    = input.int(15,    "End Hour (UTC)",         group=g_ny, minval=0, maxval=23)
nyKZColor  = input.color(color.new(#EF5350, 88), "NY KZ Color",    group=g_ny)
nyBorder   = input.color(color.new(#EF5350, 40), "NY Border",      group=g_ny)

showLabel  = input.bool(true, "Show Labels")

// ═══════════════════════════════════════════════════════════
//  SESSION DETECTION
// ═══════════════════════════════════════════════════════════
barHour = hour(time, "UTC")

inKZ(startH, endH) =>
    barHour >= startH and barHour < endH

inLonKZ = inKZ(lonKZStart, lonKZEnd)
inNYKZ  = inKZ(nyKZStart,  nyKZEnd)

lonKZStarted = inLonKZ and not inLonKZ[1]
lonKZEnded   = not inLonKZ and inLonKZ[1]
nyKZStarted  = inNYKZ  and not inNYKZ[1]
nyKZEnded    = not inNYKZ  and inNYKZ[1]

// ═══════════════════════════════════════════════════════════
//  BOX DRAWING — öffnen bei Start, schließen bei Ende
// ═══════════════════════════════════════════════════════════
var box lonBox = na
var box nyBox  = na

// London KZ
if showLON
    if lonKZStarted
        lonBox := box.new(bar_index, high, bar_index + 1, low,
             bgcolor=lonKZColor,
             border_color=lonBorder,
             border_width=1,
             text=showLabel ? "London KZ" : "",
             text_color=color.new(#4FC3F7, 0),
             text_size=size.small,
             text_valign=text.align_top,
             text_halign=text.align_left,
             extend=extend.none)

    if inLonKZ and not na(lonBox)
        box.set_right(lonBox, bar_index + 1)
        box.set_top(lonBox,   math.max(box.get_top(lonBox), high))
        box.set_bottom(lonBox, math.min(box.get_bottom(lonBox), low))

// NY KZ
if showNY
    if nyKZStarted
        nyBox := box.new(bar_index, high, bar_index + 1, low,
             bgcolor=nyKZColor,
             border_color=nyBorder,
             border_width=1,
             text=showLabel ? "New York KZ" : "",
             text_color=color.new(#EF5350, 0),
             text_size=size.small,
             text_valign=text.align_top,
             text_halign=text.align_left,
             extend=extend.none)

    if inNYKZ and not na(nyBox)
        box.set_right(nyBox, bar_index + 1)
        box.set_top(nyBox,   math.max(box.get_top(nyBox), high))
        box.set_bottom(nyBox, math.min(box.get_bottom(nyBox), low))

// ═══════════════════════════════════════════════════════════
//  INFO TABLE
// ═══════════════════════════════════════════════════════════
var table t = table.new(position.bottom_right, 2, 3,
     bgcolor=color.new(#0a0a0a, 60),
     border_color=color.new(#333333, 0),
     border_width=1, frame_color=color.new(#444444, 0), frame_width=1)

if barstate.islast
    table.cell(t, 0, 0, "ZYPHERON KZ", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 1, 0, "UTC",         text_color=color.new(#00e676, 0), text_size=size.small, bgcolor=color.new(#1a1a2e, 0))
    table.cell(t, 0, 1, "🇬🇧 London KZ", text_color=color.new(#4FC3F7, 0), text_size=size.tiny)
    table.cell(t, 1, 1, str.tostring(lonKZStart) + ":00 – " + str.tostring(lonKZEnd) + ":00", text_color=color.white, text_size=size.tiny)
    table.cell(t, 0, 2, "🗽 New York KZ", text_color=color.new(#EF5350, 0), text_size=size.tiny)
    table.cell(t, 1, 2, str.tostring(nyKZStart) + ":00 – " + str.tostring(nyKZEnd) + ":00", text_color=color.white, text_size=size.tiny)
````
