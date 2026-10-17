# Midnight Opening Range (MOR)

- url: https://www.tradingview.com/script/ncizPWLj-Midnight-Opening-Range-MOR/
- type: indicator
- pine_id: PUB;997f493b443a43409b058c25d67bfafa
- version: 1.0

## Description

its a startegy for like midnight opening its a crazy thing mainly for gold

## Source Code

````pine
//@version=6
indicator(title="Midnight Opening Range (MOR)", shorttitle="MOR", overlay=true)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
var string TZ_GROUP   = "Timezone"
var string STYLE_GROUP = "Style"

string  sessionTZ      = input.string("America/New_York", "Timezone",
     options=["America/New_York","America/Chicago","America/Los_Angeles",
              "Europe/London","Europe/Berlin","Asia/Tokyo","Asia/Singapore",
              "Australia/Sydney","UTC"],
     group=TZ_GROUP,
     tooltip="Select the timezone in which 00:00–00:30 defines the MOR window.")

color   highColor      = input.color(color.new(#00E5FF, 0),  "MOR High Color",   group=STYLE_GROUP)
color   lowColor       = input.color(color.new(#FF4081, 0),  "MOR Low Color",    group=STYLE_GROUP)
color   bandColor      = input.color(color.new(#00E5FF, 88), "Band Fill Color",  group=STYLE_GROUP)
int     lineWidth      = input.int(2, "Line Width", minval=1, maxval=4,          group=STYLE_GROUP)
bool    showMidline    = input.bool(true, "Show Midline",                        group=STYLE_GROUP)
color   midColor       = input.color(color.new(#FFFFFF, 70), "Midline Color",    group=STYLE_GROUP)
bool    showLabels     = input.bool(true, "Show Labels",                         group=STYLE_GROUP)
bool    extendLines    = input.bool(true, "Extend Lines to End of Session",      group=STYLE_GROUP)

// ─────────────────────────────────────────────
//  SESSION DETECTION  (00:00 – 00:30 in chosen TZ)
// ─────────────────────────────────────────────
// Returns true for every bar whose open time falls inside [00:00, 00:30)
bool inMorWindow = not na(time("1", "0000-0030", sessionTZ))

// ─────────────────────────────────────────────
//  STATE VARIABLES
// ─────────────────────────────────────────────
var float morHigh      = na
var float morLow       = na
var float morMid       = na
var bool  windowClosed = false          // true once the 00:30 bar has passed

// Detect the first bar of the MOR window each day
bool windowOpen   = inMorWindow
bool windowJustEnded = not inMorWindow and inMorWindow[1]   // rising edge → window just closed

// ─────────────────────────────────────────────
//  CALCULATION  – accumulate H/L inside window
// ─────────────────────────────────────────────
if windowOpen
    morHigh := na(morHigh) ? high : math.max(morHigh, high)
    morLow  := na(morLow)  ? low  : math.min(morLow,  low)

// When the window closes, lock in the midpoint
if windowJustEnded
    morMid       := (morHigh + morLow) / 2
    windowClosed := true

// Reset at the very first bar of a new MOR window
bool newDayWindow = windowOpen and not windowOpen[1]
if newDayWindow
    morHigh      := high
    morLow       := low
    morMid       := na
    windowClosed := false

// ─────────────────────────────────────────────
//  DRAWING – plot levels after window closes
// ─────────────────────────────────────────────
// We use plot() with display logic: only show values once window has closed
float plotHigh = windowClosed ? morHigh : na
float plotLow  = windowClosed ? morLow  : na
float plotMid  = (windowClosed and showMidline) ? morMid : na

plot(plotHigh, "MOR High", color=highColor, linewidth=lineWidth, style=plot.style_linebr)
plot(plotLow,  "MOR Low",  color=lowColor,  linewidth=lineWidth, style=plot.style_linebr)
plot(plotMid,  "MOR Mid",  color=midColor,  linewidth=1,         style=plot.style_linebr)

// Band fill between High and Low
p_high = plot(plotHigh, display=display.none)
p_low  = plot(plotLow,  display=display.none)
fill(p_high, p_low, color=bandColor, title="MOR Band")

// ─────────────────────────────────────────────
//  LABELS  – print once, at the bar the window closes
// ─────────────────────────────────────────────
if windowJustEnded and showLabels
    label.new(bar_index, morHigh,
         text  = "MOR H: " + str.tostring(morHigh, format.mintick),
         color = highColor,
         style = label.style_label_left,
         textcolor = color.black,
         size  = size.small)

    label.new(bar_index, morLow,
         text  = "MOR L: " + str.tostring(morLow, format.mintick),
         color = lowColor,
         style = label.style_label_left,
         textcolor = color.black,
         size  = size.small)

    if showMidline
        label.new(bar_index, morMid,
             text  = "MOR Mid: " + str.tostring(morMid, format.mintick),
             color = midColor,
             style = label.style_label_left,
             textcolor = color.black,
             size  = size.small)

// ─────────────────────────────────────────────
//  BACKGROUND HIGHLIGHT  – shade the 00:00-00:30 window
// ─────────────────────────────────────────────
bgcolor(inMorWindow ? color.new(color.yellow, 92) : na,
     title="MOR Window Background")
````
