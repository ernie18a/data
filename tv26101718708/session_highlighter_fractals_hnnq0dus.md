# Session Highlighter & Fractals

- url: https://www.tradingview.com/script/HnNQ0dUS-Session-Highlighter-Fractals/
- type: indicator
- pine_id: PUB;1b63125b50794d9b8ecc3025f9824676
- version: 1.0

## Description

Session Highlighter & Fractals
A clean session-tracking tool built for intraday traders who want to see exactly where price sits relative to the Asian, London, and New York sessions — combined with Williams Fractal swing points for structure reference.
Features:

Three independently configurable sessions (Asian, London, New York) — each with its own time window, on/off toggle, and color
Background highlighting for the full duration of each active session, with an adjustable transparency slider so the shading never overwhelms your price action
Start/End labels on every session transition — fully customizable text (defaults to "Asian Start", "Asian End", etc.) so you can rename them to match your own trading vocabulary
Timezone control — a dropdown of standard timezones so session boundaries align exactly with whatever timezone your chart is displaying, rather than relying on the exchange's default timezone
Williams Fractals — classic 5-bar swing high/low detection, plotted directly on the chart with green/red triangle markers
Built-in alerts for both bullish and bearish fractal prints, so you can get notified the moment a new swing point forms without watching the chart

How to use it:
Set your chart's timezone (bottom-right clock icon), then match that same timezone in the indicator's settings so session windows line up correctly. Adjust each session's start/end time if you trade a custom window rather than the standard session hours. Toggle labels on or off depending on whether you want a cleaner chart or explicit markers at every transition.
This script is intended as a visual and structural reference tool — it does not generate buy/sell signals and should be combined with your own strategy, risk management, and market analysis.

## Source Code

````pine
//@version=6
indicator("Session Highlighter & Fractals", shorttitle="Sessions & Fractals", overlay=true, max_labels_count=500)

// ============ SESSION SETTINGS ============
showSessions   = input.bool(true, "Show Session Highlighting", group="Sessions")
bgTransparency = input.int(85, "Background Transparency", minval=0, maxval=99, group="Sessions")

asianSession  = input.session("0000-0900", "Asian Session",  group="Sessions")
londonSession = input.session("0800-1600", "London Session", group="Sessions")
nySession     = input.session("1300-2200", "New York Session", group="Sessions")

showAsian  = input.bool(true, "Show Asian",  group="Sessions", inline="show1")
showLondon = input.bool(true, "Show London", group="Sessions", inline="show1")
showNY     = input.bool(true, "Show New York", group="Sessions", inline="show1")

colAsian  = input.color(color.yellow, "Asian Color",  group="Sessions", inline="col1")
colLondon = input.color(color.orange, "London Color", group="Sessions", inline="col1")
colNY     = input.color(color.aqua,   "New York Color", group="Sessions", inline="col1")

// ============ LABEL SETTINGS ============
showLabels = input.bool(true, "Show Start/End Labels", group="Labels")

lblAsianStart  = input.string("Asian Start",  "Asian Start Label",  group="Labels")
lblAsianEnd    = input.string("Asian End",    "Asian End Label",    group="Labels")
lblLondonStart = input.string("London Start", "London Start Label", group="Labels")
lblLondonEnd   = input.string("London End",   "London End Label",   group="Labels")
lblNYStart     = input.string("NY Start",     "NY Start Label",     group="Labels")
lblNYEnd       = input.string("NY End",       "NY End Label",       group="Labels")

// Timezone: pick the SAME timezone you have set on your chart (clock icon, bottom-right)
sessionTZ = input.string("UTC", "Chart Timezone (must match your chart's clock setting)",
     options=["UTC", "GMT-12", "GMT-11", "GMT-10", "GMT-9", "GMT-8", "America/Los_Angeles",
     "GMT-7", "America/Denver", "GMT-6", "America/Chicago", "GMT-5", "America/New_York",
     "GMT-4", "America/Sao_Paulo", "GMT-3", "GMT-2", "GMT-1", "GMT0",
     "Europe/London", "Europe/Lisbon", "GMT+1", "Europe/Paris", "Europe/Berlin",
     "Europe/Madrid", "Africa/Lagos", "GMT+2", "Europe/Athens", "Africa/Cairo",
     "GMT+3", "Europe/Moscow", "Asia/Riyadh", "GMT+4", "Asia/Dubai", "GMT+5",
     "Asia/Karachi", "GMT+5:30", "Asia/Kolkata", "GMT+6", "Asia/Dhaka", "GMT+7",
     "Asia/Bangkok", "GMT+8", "Asia/Shanghai", "Asia/Singapore", "Asia/Hong_Kong",
     "GMT+9", "Asia/Tokyo", "Asia/Seoul", "GMT+9:30", "Australia/Adelaide",
     "GMT+10", "Australia/Sydney", "GMT+11", "GMT+12", "Pacific/Auckland"],
     group="Sessions")

// ============ SESSION DETECTION ============
inAsian  = not na(time("", asianSession, sessionTZ))
inLondon = not na(time("", londonSession, sessionTZ))
inNY     = not na(time("", nySession, sessionTZ))

asianStart  = inAsian and not inAsian[1]
asianEnd    = not inAsian and inAsian[1]
londonStart = inLondon and not inLondon[1]
londonEnd   = not inLondon and inLondon[1]
nyStart     = inNY and not inNY[1]
nyEnd       = not inNY and inNY[1]

// ============ BACKGROUND HIGHLIGHTING ============
asianBg  = showSessions and showAsian  and inAsian  ? color.new(colAsian, bgTransparency)  : na
londonBg = showSessions and showLondon and inLondon ? color.new(colLondon, bgTransparency) : na
nyBg     = showSessions and showNY     and inNY     ? color.new(colNY, bgTransparency)     : na

bgcolor(asianBg, title="Asian Session Background")
bgcolor(londonBg, title="London Session Background")
bgcolor(nyBg, title="New York Session Background")

// ============ START/END LABELS ============
f_label(_cond, _col, _text, _up) =>
    if _cond
        label.new(bar_index, _up ? high : low, text=_text,
             style=_up ? label.style_label_down : label.style_label_up,
             color=color.new(_col, 0), textcolor=color.white, size=size.small,
             yloc=_up ? yloc.abovebar : yloc.belowbar)

if showLabels and showSessions and showAsian
    f_label(asianStart, colAsian, lblAsianStart, true)
    f_label(asianEnd, colAsian, lblAsianEnd, false)

if showLabels and showSessions and showLondon
    f_label(londonStart, colLondon, lblLondonStart, true)
    f_label(londonEnd, colLondon, lblLondonEnd, false)

if showLabels and showSessions and showNY
    f_label(nyStart, colNY, lblNYStart, true)
    f_label(nyEnd, colNY, lblNYEnd, false)

// ============ WILLIAMS FRACTALS ============
upFractal = high[2] > high[4] and high[2] > high[3] and high[2] > high[1] and high[2] > high[0]
downFractal = low[2] < low[4] and low[2] < low[3] and low[2] < low[1] and low[2] < low[0]

plotshape(downFractal, style=shape.triangleup, location=location.belowbar, offset=-2, color=color.green, title="Bullish Williams Fractal")
plotshape(upFractal, style=shape.triangledown, location=location.abovebar, offset=-2, color=color.red, title="Bearish Williams Fractal")

alertcondition(downFractal, title="Bullish Williams Fractal", message="Bullish Williams Fractal Printed")
alertcondition(upFractal, title="Bearish Williams Fractal", message="Bearish Williams Fractal Printed")
````
