# Session Lines & Kill Zones

- url: https://www.tradingview.com/script/7FLxaMiD-Session-Lines-Kill-Zones/
- type: indicator
- pine_id: PUB;2b13a883838745199ee2229c1de96ed0
- version: 1.0

## Description

Optimized for [b]Inner Circle Trader (ICT)[/b] and [b]Smart Money Concepts (SMC)[/b] traders, this indicator automatically highlights critical intraday market sessions and algorithmic "Kill Zones" directly on your chart.

Unlike standard session clocks that clutter your screens, this script features custom-engineered vertical transition lines and pixel-perfect background shading designed **never** to warp or break your chart's price scale.

---

[b]🔑 Key Features[/b]

[list]
[*]
[/list][b]🌐 True GMT-Based Calculations:[/b] Zero reliance on your local broker time. Input your desired GMT offset to seamlessly align your sessions regardless of your data feed.
 
[list]
[*]
[/list][b]🕒 Comprehensive Kill Zone Coverage:[/b] Includes pre-configured, industry-standard tracking for:
[list]
[*][b]Asian Session / Kill Zone
[*]London Open Kill Zone
[*]New York Open Kill Zone
[*]London / New York Overlap (Silver Bullet/Macro windows)[/b]
[/list]



[b]⚙️ Fully Customizable Extra Session:[/b] An independent, fully editable custom session block tailored for tracking specific local market opens, equity hours, or personal macro periods.
[b]📅 Daily Start Line Indicator:[/b] Clean, unobtrusive vertical separators marking the exact start of each new trading day.
[b]📐 Clean Scaling Technology:[/b] Custom written using localized bar anchors. Your price scale remains 100% accurate, allowing you to compress, expand, and read price action smoothly without squeezed candles.

---
[b]🎨 Visual & Control Settings[/b]

* **Timeframe Filtering:** Keep your higher timeframes clean! Set an automatic upper boundary rule (e.g., only show on 1-hour timeframes or lower) to auto-hide the sessions when zooming out to daily or weekly macro views.
* **Toggleable Labels & Borders:** Fully customize your aesthetic. Individually toggle background shading, outer boundary line styles (Solid, Dashed, Dotted), and session floating labels to match your chart's theme.

---

[b]🚀 How to Use It[/b]

1. [b]Judicious Multi-accounting:[/b] Use the background clouds to identify when liquidity is building up (Asian Range) and when algorithmic manipulation typically occurs (London/NY Sweeps).
2. [b]Time-of-Day Execution:[/b] Ensure your setups align with high-volatility session boundaries marked clearly by the vertical transition lines.

[i]Built entirely on the latest [b]Pine Script v6 [/b]architecture for peak execution speed and cross-device display stability.[/i]

## Source Code

````pine
//@version=6
indicator("Session Lines & Kill Zones", overlay=true, max_lines_count=500)

// ═══════════════════════════════════════════
// DAILY START LINE
// ═══════════════════════════════════════════
grpDaily = "── Daily Start Line (GMT) ──"
showLines  = input.bool(true, "Show Daily Start Lines", group=grpDaily)
showOnTF   = input.timeframe("60", "Show on ≤ timeframe", group=grpDaily)
gmtOffset  = input.int(0, "GMT Offset (hours)", minval=-12, maxval=14, group=grpDaily)
dlColor    = input.color(color.new(color.gray, 0), "Color", group=grpDaily)
dlWidth    = input.int(1, "Width", minval=1, maxval=4, group=grpDaily)
dlStyleOpt = input.string("Dashed", "Style", options=["Solid","Dashed","Dotted"], group=grpDaily)
dlStyle    = dlStyleOpt == "Solid" ? line.style_solid : dlStyleOpt == "Dotted" ? line.style_dotted : line.style_dashed

// ═══════════════════════════════════════════
// ASIAN KILL ZONE
// ═══════════════════════════════════════════
grpA = "── Asian Kill Zone ──"
showAsian   = input.bool(true,  "Show Asian Kill Zone",             group=grpA)
asianCol    = input.color(color.new(color.yellow, 80), "Background Color", group=grpA)
asianBorder = input.bool(true,  "Show Border Lines",                group=grpA)
asianBCol   = input.color(color.new(color.yellow, 20), "Border Color",     group=grpA)
asianBW     = input.int(1, "Border Width", minval=1, maxval=4,      group=grpA)
asianBSOpt  = input.string("Solid", "Border Style", options=["Solid","Dashed","Dotted"], group=grpA)
asianBS     = asianBSOpt == "Solid" ? line.style_solid : asianBSOpt == "Dotted" ? line.style_dotted : line.style_dashed
asianStart  = input.int(0,  "Start (GMT hour)", minval=0, maxval=23, group=grpA)
asianEnd    = input.int(4,  "End   (GMT hour)", minval=0, maxval=23, group=grpA)
asianLabel  = input.bool(true, "Show Label",                        group=grpA)

// ═══════════════════════════════════════════
// LONDON KILL ZONE
// ═══════════════════════════════════════════
grpL = "── London Kill Zone ──"
showLondon   = input.bool(true,  "Show London Kill Zone",            group=grpL)
londonCol    = input.color(color.new(color.blue, 80), "Background Color",  group=grpL)
londonBorder = input.bool(true,  "Show Border Lines",                group=grpL)
londonBCol   = input.color(color.new(color.blue, 20), "Border Color",      group=grpL)
londonBW     = input.int(1, "Border Width", minval=1, maxval=4,      group=grpL)
londonBSOpt  = input.string("Solid", "Border Style", options=["Solid","Dashed","Dotted"], group=grpL)
londonBS     = londonBSOpt == "Solid" ? line.style_solid : londonBSOpt == "Dotted" ? line.style_dotted : line.style_dashed
londonStart  = input.int(7,  "Start (GMT hour)", minval=0, maxval=23, group=grpL)
londonEnd    = input.int(10, "End   (GMT hour)", minval=0, maxval=23, group=grpL)
londonLabel  = input.bool(true, "Show Label",                        group=grpL)

// ═══════════════════════════════════════════
// NEW YORK KILL ZONE
// ═══════════════════════════════════════════
grpN = "── New York Kill Zone ──"
showNY   = input.bool(true,  "Show New York Kill Zone",          group=grpN)
nyCol    = input.color(color.new(color.green, 80), "Background Color", group=grpN)
nyBorder = input.bool(true,  "Show Border Lines",                group=grpN)
nyBCol   = input.color(color.new(color.green, 20), "Border Color",     group=grpN)
nyBW     = input.int(1, "Border Width", minval=1, maxval=4,      group=grpN)
nyBSOpt  = input.string("Solid", "Border Style", options=["Solid","Dashed","Dotted"], group=grpN)
nyBS     = nyBSOpt == "Solid" ? line.style_solid : nyBSOpt == "Dotted" ? line.style_dotted : line.style_dashed
nyStart  = input.int(12, "Start (GMT hour)", minval=0, maxval=23, group=grpN)
nyEnd    = input.int(17, "End   (GMT hour)", minval=0, maxval=23, group=grpN)
nyLabel  = input.bool(true, "Show Label",                        group=grpN)

// ═══════════════════════════════════════════
// LONDON / NEW YORK OVERLAP
// ═══════════════════════════════════════════
grpLN = "── London / NY Overlap ──"
showLonNY   = input.bool(true,  "Show London/NY Overlap",            group=grpLN)
lonNYCol    = input.color(color.new(color.orange, 80), "Background Color", group=grpLN)
lonNYBorder = input.bool(true,  "Show Border Lines",                 group=grpLN)
lonNYBCol   = input.color(color.new(color.orange, 20), "Border Color",     group=grpLN)
lonNYBW     = input.int(1, "Border Width", minval=1, maxval=4,       group=grpLN)
lonNYBSOpt  = input.string("Solid", "Border Style", options=["Solid","Dashed","Dotted"], group=grpLN)
lonNYBS     = lonNYBSOpt == "Solid" ? line.style_solid : lonNYBSOpt == "Dotted" ? line.style_dotted : line.style_dashed
lonNYStart  = input.int(13, "Start (GMT hour)", minval=0, maxval=23, group=grpLN)
lonNYEnd    = input.int(15, "End   (GMT hour)", minval=0, maxval=23, group=grpLN)
lonNYLabel  = input.bool(true, "Show Label",                         group=grpLN)

// ═══════════════════════════════════════════
// CUSTOM SESSION
// ═══════════════════════════════════════════
grpC = "── Custom Session ──"
showCustom   = input.bool(false, "Show Custom Session",               group=grpC)
customName   = input.string("Custom", "Session Name",                 group=grpC)
customCol    = input.color(color.new(color.purple, 80), "Background Color", group=grpC)
customBorder = input.bool(true,  "Show Border Lines",                 group=grpC)
customBCol   = input.color(color.new(color.purple, 20), "Border Color",     group=grpC)
customBW     = input.int(1, "Border Width", minval=1, maxval=4,       group=grpC)
customBSOpt  = input.string("Solid", "Border Style", options=["Solid","Dashed","Dotted"], group=grpC)
customBS     = customBSOpt == "Solid" ? line.style_solid : customBSOpt == "Dotted" ? line.style_dotted : line.style_dashed
customStart  = input.int(20, "Start (GMT hour)", minval=0, maxval=23, group=grpC)
customEnd    = input.int(22, "End   (GMT hour)", minval=0, maxval=23, group=grpC)
customLabel  = input.bool(true, "Show Label",                         group=grpC)

// ═══════════════════════════════════════════
// CORE LOGIC
// ═══════════════════════════════════════════
tfOk       = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(showOnTF)
barHourGMT = (hour(time, "UTC") + gmtOffset + 24) % 24
gmtDay     = math.floor(time / 86400000)
newGMTDay  = ta.change(gmtDay) != 0

inZone(startH, endH) =>
    startH < endH ? (barHourGMT >= startH and barHourGMT < endH)
                  : (barHourGMT >= startH or  barHourGMT < endH)

// ── Zone state booleans ──
isAsian  = tfOk and showAsian  and inZone(asianStart,  asianEnd)
isLondon = tfOk and showLondon and inZone(londonStart, londonEnd)
isNY     = tfOk and showNY     and inZone(nyStart,     nyEnd)
isLonNY  = tfOk and showLonNY  and inZone(lonNYStart,  lonNYEnd)
isCustom = tfOk and showCustom and inZone(customStart, customEnd)

// ═══════════════════════════════════════════
// BGCOLOR — must be at global scope (Pine v6 rule)
// ═══════════════════════════════════════════
bgcolor(isAsian  ? asianCol  : na, title="Asian KZ")
bgcolor(isLondon ? londonCol : na, title="London KZ")
bgcolor(isNY     ? nyCol     : na, title="NY KZ")
bgcolor(isLonNY  ? lonNYCol  : na, title="Lon/NY Overlap")
bgcolor(isCustom ? customCol : na, title="Custom Session")

// ═══════════════════════════════════════════
// BORDER LINES + LABELS — on zone transitions
// ═══════════════════════════════════════════
var bool wasAsian  = false
var bool wasLondon = false
var bool wasNY     = false
var bool wasLonNY  = false
var bool wasCustom = false

// FIXED: Anchored strictly to the high and low of the bar. 
// No horizontal extension, and no chart scaling distortion.
drawBorderLine(col, w, st) =>
    line.new(bar_index, low, bar_index, high,
             color=col, width=w, style=st, extend=extend.none)

drawLabel(txt, col) =>
    label.new(bar_index, high, txt,
              color     = color.new(col, 60),
              textcolor = color.white,
              style     = label.style_label_down,
              size      = size.small)

if tfOk
    // Asian borders
    if asianBorder
        if isAsian and not wasAsian
            drawBorderLine(asianBCol, asianBW, asianBS)
            if asianLabel
                drawLabel("Asian", color.yellow)
        if not isAsian and wasAsian
            drawBorderLine(asianBCol, asianBW, asianBS)

    // London borders
    if londonBorder
        if isLondon and not wasLondon
            drawBorderLine(londonBCol, londonBW, londonBS)
            if londonLabel
                drawLabel("London", color.blue)
        if not isLondon and wasLondon
            drawBorderLine(londonBCol, londonBW, londonBS)

    // NY borders
    if nyBorder
        if isNY and not wasNY
            drawBorderLine(nyBCol, nyBW, nyBS)
            if nyLabel
                drawLabel("NY", color.green)
        if not isNY and wasNY
            drawBorderLine(nyBCol, nyBW, nyBS)

    // London/NY overlap borders
    if lonNYBorder
        if isLonNY and not wasLonNY
            drawBorderLine(lonNYBCol, lonNYBW, lonNYBS)
            if lonNYLabel
                drawLabel("Lon/NY", color.orange)
        if not isLonNY and wasLonNY
            drawBorderLine(lonNYBCol, lonNYBW, lonNYBS)

    // Custom borders
    if customBorder
        if isCustom and not wasCustom
            drawBorderLine(customBCol, customBW, customBS)
            if customLabel
                drawLabel(customName, color.purple)
        if not isCustom and wasCustom
            drawBorderLine(customBCol, customBW, customBS)

    wasAsian  := isAsian
    wasLondon := isLondon
    wasNY     := isNY
    wasLonNY  := isLonNY
    wasCustom := isCustom

// ═══════════════════════════════════════════
// DAILY START LINE
// ═══════════════════════════════════════════
// FIXED: Anchored cleanly to high/low to respect the scale.
if barstate.isnew and showLines and tfOk and newGMTDay
    line.new(bar_index, low, bar_index, high, color=dlColor, width=dlWidth, style=dlStyle, extend=extend.none)
````
