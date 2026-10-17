# Moon Cycles

- url: https://www.tradingview.com/script/JsUplj0o-Moon-Cycles/
- type: indicator
- pine_id: PUB;f6b1a8efc50948269a1643599f3db76d
- version: 1.0

## Description

Overview
Marks the four primary lunar phases (new, first quarter, full, last quarter) directly on the chart using an astronomical calculation, for traders who track lunar-cycle-based market sentiment/timing frameworks.

How it's calculated
Uses the standard synodic month constant (29.530588853 days) against a known reference new moon (6 Jan 2000) to compute a continuous lunar-cycle phase fraction (0 to 1) for the current bar's timestamp, then flags a phase transition whenever that fraction crosses a phase boundary (0.0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter) between the current and prior bar.

How to use it
This isn't a trading signal on its own — it's a calendar overlay for traders who want lunar phases visible alongside price action as one input among others. Label text is configurable (emoji only, with meaning, with date, or all three) and vertical lines can optionally mark new/full moons for easier visual alignment with price swings.

## Source Code

````pine
//@version=6
indicator("Moon Cycles", overlay = true, max_labels_count = 500, max_lines_count = 500)

// === Phase Settings ===
showNew    = input.bool(true,  "🌑 New Moon",           group = "Phases")
showFirstQ = input.bool(true,  "🌓 First Quarter",      group = "Phases")
showFull   = input.bool(true,  "🌕 Full Moon",          group = "Phases")
showLastQ  = input.bool(true,  "🌗 Last Quarter",       group = "Phases")

// === Display Settings ===
moonSize    = input.string("normal", "Moon Size", options = ["tiny", "small", "normal", "large", "huge"], group = "Appearance")
labelMode   = input.string("emoji only", "Label Text", options = ["emoji only", "emoji + meaning", "emoji + date", "emoji + meaning + date"], group = "Appearance")
showLines   = input.bool(true,  "Vertical lines for new/full moon",  group = "Appearance")
newLineCol  = input.color(color.new(color.blue,   70), "New Moon line color",  group = "Appearance")
fullLineCol = input.color(color.new(color.yellow, 60), "Full Moon line color", group = "Appearance")
lineStyle   = input.string("dashed", "Line Style", options = ["solid", "dashed", "dotted"], group = "Appearance")

sz = moonSize == "tiny"  ? size.tiny  :
     moonSize == "small" ? size.small :
     moonSize == "large" ? size.large :
     moonSize == "huge"  ? size.huge  : size.normal

ls = lineStyle == "solid"  ? line.style_solid  :
     lineStyle == "dotted" ? line.style_dotted : line.style_dashed

// === Phase Calculation ===
refNewMoon = timestamp("UTC", 2000, 1, 6, 18, 14)
synodicMs  = 29.530588853 * 86400000.0

cyclesNow  = (time    - refNewMoon) / synodicMs
cyclesPrev = (time[1] - refNewMoon) / synodicMs

phaseNow  = cyclesNow  - math.floor(cyclesNow)
phasePrev = cyclesPrev - math.floor(cyclesPrev)

// === Phase Detection ===
isNew    = phasePrev > 0.9  and phaseNow < 0.1
isFirstQ = phasePrev < 0.25 and phaseNow >= 0.25
isFull   = phasePrev < 0.5  and phaseNow >= 0.5
isLastQ  = phasePrev < 0.75 and phaseNow >= 0.75

// === Meanings ===
newMeaning  = "🌑 NEW MOON\n─────────────\n📅 " + str.format_time(time, "dd MMM yyyy", "UTC+8") + "\n\n● Cycle Reset\n● Watch for new trend initiation\n● Sentiment shift possible\n● Low → potential reversal UP"
firstMeaning = "🌓 FIRST QUARTER\n─────────────\n📅 " + str.format_time(time, "dd MMM yyyy", "UTC+8") + "\n\n● Momentum building\n● Trend continuation likely\n● Breakout watch"
fullMeaning  = "🌕 FULL MOON\n─────────────\n📅 " + str.format_time(time, "dd MMM yyyy", "UTC+8") + "\n\n● Cycle Peak\n● Heightened volatility\n● Sentiment extreme possible\n● High → potential reversal DOWN"
lastMeaning  = "🌗 LAST QUARTER\n─────────────\n📅 " + str.format_time(time, "dd MMM yyyy", "UTC+8") + "\n\n● Momentum fading\n● Consolidation / distribution\n● Cycle winding down"

// === Label Builder ===
transparent = color.new(color.black, 100)

buildLabel(string emoji, string meaning, string shortMeaning) =>
    dateStr = str.format_time(time, "dd.MM", "UTC+8")
    labelMode == "emoji + meaning"           ? emoji + "\n" + shortMeaning :
     labelMode == "emoji + date"             ? emoji + "\n" + dateStr :
     labelMode == "emoji + meaning + date"   ? emoji + "\n" + shortMeaning + "\n" + dateStr :
     emoji

drawMoon(bool cond, string emoji, string meaning, string shortMeaning) =>
    if cond
        txt = buildLabel(emoji, meaning, shortMeaning)
        label.new(bar_index, high, txt,
             yloc    = yloc.abovebar,
             color   = transparent,
             style   = label.style_none,
             size    = sz,
             tooltip = meaning)

// === Labels ===
drawMoon(showNew    and isNew,    "🌑", newMeaning,   "Reset")
drawMoon(showFirstQ and isFirstQ, "🌓", firstMeaning, "Momentum")
drawMoon(showFull   and isFull,   "🌕", fullMeaning,  "Peak")
drawMoon(showLastQ  and isLastQ,  "🌗", lastMeaning,  "Fade")

// === Vertical Lines ===
if showLines and showNew and isNew
    line.new(bar_index, low, bar_index, high, extend = extend.both, color = newLineCol, style = ls)

if showLines and showFull and isFull
    line.new(bar_index, low, bar_index, high, extend = extend.both, color = fullLineCol, style = ls)
````
