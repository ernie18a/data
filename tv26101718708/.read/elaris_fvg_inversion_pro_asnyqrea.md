# Elaris FVG Inversion Pro

- url: https://www.tradingview.com/script/aSNyqRea-Elaris-FVG-Inversion-Pro/
- type: indicator
- pine_id: PUB;f675955213894e10a4aca61faa76fe95
- version: 1.0

## Description

Elaris FVG Inversion Pro

Advanced Fair Value Gap & Inversion Mapping System

Elaris FVG Inversion Pro is a professional-grade market structure and imbalance visualization tool designed to help traders identify fair value gaps (FVGs), inversion fair value gaps (IFVGs), and potential reaction zones directly on the chart.

The indicator focuses on price inefficiencies created by aggressive directional movement and highlights areas where price may revisit, react, continue, or reverse.

Instead of displaying excessive noise, the system uses smart filtering logic, mitigation tracking, and optional trend confirmation to provide a cleaner and more structured view of market imbalance behavior.

━━━━━━━━━━━━━━━━━━
Core Features
━━━━━━━━━━━━━━━━━━

• Bullish & Bearish Fair Value Gap Detection
Automatically identifies three-candle imbalance structures in real time.

• Inversion Fair Value Gaps (IFVG)
Detects when previously established imbalance zones transition into potential reversal zones after invalidation.

• Non-Repainting Confirmed Detection
Signals and zones can be confirmed only after candle close to maintain stable historical plotting.

• Smart Gap Filtering
Optional ATR, volume, and EMA trend filters help reduce low-quality or insignificant zones.

• Dynamic Zone Management
Zones automatically extend forward and can be configured to expire or hide after mitigation.

• Mitigation Tracking
Supports multiple mitigation models including:

* Proximal
* Midpoint (50%)
* Distal

• Quality Scoring System
Each zone is evaluated using volatility and structure-based conditions to help prioritize stronger imbalances.

• Dark & Light Mode Compatible
Designed for clean visibility across different TradingView chart themes.

• Professional Dashboard
Displays active bullish, bearish, and inversion zones along with trend-state information.

━━━━━━━━━━━━━━━━━━
How It Works
━━━━━━━━━━━━━━━━━━

Bullish FVG:
Forms when price leaves an upside imbalance between candles, potentially creating a future demand area.

Bearish FVG:
Forms when price leaves a downside imbalance, potentially acting as future supply.

IFVG:
Occurs when price invalidates an existing FVG and the zone transitions into a potential reversal area.

The indicator can be used for:

* Trend continuation setups
* Pullback entries
* Liquidity-based reactions
* Market structure analysis
* Confluence with support/resistance or liquidity concepts

━━━━━━━━━━━━━━━━━━
Best Practices
━━━━━━━━━━━━━━━━━━

Higher timeframe FVGs generally produce stronger reactions than lower timeframe gaps.

Using the optional EMA and volume filters may help improve signal quality during volatile or choppy market conditions.

For confirmation-based trading approaches, combine FVG reactions with structure breaks, momentum shifts, or liquidity sweeps.

━━━━━━━━━━━━━━━━━━
Notes
━━━━━━━━━━━━━━━━━━

This indicator is intended for technical analysis and educational purposes.

No indicator guarantees future performance, and traders should always apply proper risk management and independent confirmation before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// © ElarisGroup

//@version=6
indicator("Elaris FVG Inversion Pro", shorttitle="Elaris FVG Pro", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=3000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore   = "Core Detection"
groupFilter = "Smart Filters"
groupZones  = "Zone Management"
groupVisual = "Visual Design"
groupDash   = "Dashboard"
groupAlert  = "Alerts"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBullFVG = input.bool(true, "Show Bullish FVG", group=groupCore)
showBearFVG = input.bool(true, "Show Bearish FVG", group=groupCore)
showIFVG    = input.bool(true, "Show Inversion FVG", group=groupCore)

minGapPct   = input.float(0.05, "Minimum Gap Size %", minval=0.0, step=0.01, group=groupCore)
confirmBars = input.bool(true, "Use Confirmed Candle Only", group=groupCore, tooltip="Keeps detection non-repainting by only confirming signals after candle close.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SMART FILTERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
useAtrFilter = input.bool(true, "Use ATR Gap Filter", group=groupFilter)
atrLen       = input.int(14, "ATR Length", minval=1, group=groupFilter)
minAtrMult   = input.float(0.15, "Minimum Gap / ATR", minval=0.0, step=0.05, group=groupFilter)

useTrendFilter = input.bool(false, "Use EMA Trend Filter", group=groupFilter)
emaLen         = input.int(200, "EMA Length", minval=1, group=groupFilter)

useVolumeFilter = input.bool(false, "Use Volume Expansion Filter", group=groupFilter)
volLen          = input.int(20, "Volume MA Length", minval=1, group=groupFilter)
volMult         = input.float(1.1, "Volume Multiplier", minval=0.1, step=0.1, group=groupFilter)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE MANAGEMENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
maxZones        = input.int(25, "Maximum Active Zones", minval=5, maxval=100, group=groupZones)
extendBars      = input.int(150, "Extend Zones Bars", minval=20, maxval=500, group=groupZones)
validityBars    = input.int(500, "Zone Validity Bars", minval=20, maxval=3000, group=groupZones)
deleteMitigated = input.bool(false, "Delete Mitigated Zones", group=groupZones)
deleteExpired   = input.bool(true, "Delete Expired Zones", group=groupZones)

mitigationMode = input.string("50%", "Mitigation Level", options=["Proximal", "50%", "Distal"], group=groupZones)
inversionMode  = input.string("Close Through Zone", "Inversion Trigger", options=["Close Through Zone", "Wick Through Zone"], group=groupZones)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL DESIGN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
themeMode = input.string("Dark", "Theme Mode", options=["Dark", "Light"], group=groupVisual)

bullColor = input.color(color.rgb(20, 190, 148), "Bullish FVG Color", group=groupVisual)
bearColor = input.color(color.rgb(230, 75, 75), "Bearish FVG Color", group=groupVisual)
ifvgBullColor = input.color(color.rgb(80, 180, 255), "Bullish IFVG Color", group=groupVisual)
ifvgBearColor = input.color(color.rgb(255, 170, 65), "Bearish IFVG Color", group=groupVisual)

zoneTransparency = input.int(82, "Zone Transparency", minval=0, maxval=100, group=groupVisual)
showMidline      = input.bool(true, "Show 50% Midline", group=groupVisual)
showLabels       = input.bool(true, "Show Signal Labels", group=groupVisual)
showQualityText  = input.bool(true, "Show Zone Quality Text", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashPosition  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableFvgAlerts      = input.bool(true, "Alert New FVG", group=groupAlert)
enableIfvgAlerts     = input.bool(true, "Alert New IFVG", group=groupAlert)
enableMitigateAlerts = input.bool(true, "Alert Mitigation", group=groupAlert)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
ema = ta.ema(close, emaLen)
volMa = ta.sma(volume, volLen)

confirmed = confirmBars ? barstate.isconfirmed : true

bullGap = low - high[2]
bearGap = low[2] - high

bullGapPct = high[2] != 0 ? bullGap / high[2] * 100 : 0
bearGapPct = low[2] != 0 ? bearGap / low[2] * 100 : 0

bullAtrOk = not useAtrFilter or bullGap >= atr * minAtrMult
bearAtrOk = not useAtrFilter or bearGap >= atr * minAtrMult

bullTrendOk = not useTrendFilter or close > ema
bearTrendOk = not useTrendFilter or close < ema

volumeOk = not useVolumeFilter or volume > volMa * volMult

bullFvgRaw = confirmed and low > high[2]
bearFvgRaw = confirmed and high < low[2]

bullFvg = bullFvgRaw and bullGapPct >= minGapPct and bullAtrOk and bullTrendOk and volumeOk
bearFvg = bearFvgRaw and bearGapPct >= minGapPct and bearAtrOk and bearTrendOk and volumeOk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[]   zoneBoxes     = array.new_box()
var line[]  midLines      = array.new_line()
var label[] zoneLabels    = array.new_label()
var float[] zoneTops      = array.new_float()
var float[] zoneBottoms   = array.new_float()
var int[]   zoneDirs      = array.new_int()
var int[]   zoneBornBars  = array.new_int()
var bool[]  zoneInverted  = array.new_bool()
var bool[]  zoneMitigated = array.new_bool()
var float[] zoneScores    = array.new_float()

// Direction: 1 = bullish demand, -1 = bearish supply

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_dash_pos(pos) =>
    pos == "Top Right" ? position.top_right :
     pos == "Top Left" ? position.top_left :
     pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_text_color() =>
    themeMode == "Dark" ? color.white : color.rgb(20, 24, 32)

f_panel_bg() =>
    themeMode == "Dark" ? color.rgb(18, 22, 30) : color.rgb(245, 247, 250)

f_border_color() =>
    themeMode == "Dark" ? color.rgb(70, 75, 90) : color.rgb(190, 195, 205)

f_mid_level(top, bottom, dir) =>
    mitigationMode == "50%" ? (top + bottom) / 2 :
     mitigationMode == "Proximal" ? (dir == 1 ? top : bottom) :
     dir == 1 ? bottom : top

f_quality_score(gap, gapPct) =>
    atrScore = atr > 0 ? math.min((gap / atr) * 35, 35) : 0
    pctScore = math.min(gapPct * 8, 35)
    volScore = volumeOk ? 15 : 0
    trendScore = useTrendFilter ? 15 : 10
    math.round(math.min(atrScore + pctScore + volScore + trendScore, 100))

f_quality_text(score) =>
    score >= 80 ? "A+" :
     score >= 65 ? "A" :
     score >= 50 ? "B" :
     "C"

f_add_zone(top, bottom, dir, isInversion, score) =>
    baseColor = isInversion ? (dir == 1 ? ifvgBullColor : ifvgBearColor) : (dir == 1 ? bullColor : bearColor)
    labelText = showQualityText ? (isInversion ? "IFVG " : "FVG ") + f_quality_text(score) : ""
    
    b = box.new(
         left=bar_index - 2,
         top=top,
         right=bar_index + extendBars,
         bottom=bottom,
         border_color=color.new(baseColor, 20),
         bgcolor=color.new(baseColor, zoneTransparency),
         text=labelText,
         text_color=f_text_color(),
         text_size=size.tiny,
         text_halign=text.align_right,
         text_valign=text.align_center
     )

    mid = (top + bottom) / 2
    ln = line.new(
         x1=bar_index - 2,
         y1=mid,
         x2=bar_index + extendBars,
         y2=mid,
         color=showMidline ? color.new(baseColor, 35) : color.new(baseColor, 100),
         style=line.style_dotted,
         width=1
     )

    array.push(zoneBoxes, b)
    array.push(midLines, ln)
    array.push(zoneLabels, na)
    array.push(zoneTops, top)
    array.push(zoneBottoms, bottom)
    array.push(zoneDirs, dir)
    array.push(zoneBornBars, bar_index)
    array.push(zoneInverted, isInversion)
    array.push(zoneMitigated, false)
    array.push(zoneScores, score)

    if array.size(zoneBoxes) > maxZones
        oldBox = array.shift(zoneBoxes)
        oldLine = array.shift(midLines)
        oldLabel = array.shift(zoneLabels)
        array.shift(zoneTops)
        array.shift(zoneBottoms)
        array.shift(zoneDirs)
        array.shift(zoneBornBars)
        array.shift(zoneInverted)
        array.shift(zoneMitigated)
        array.shift(zoneScores)

        box.delete(oldBox)
        line.delete(oldLine)
        if not na(oldLabel)
            label.delete(oldLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE FVG ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newBullFvg = bullFvg and showBullFVG
newBearFvg = bearFvg and showBearFVG

if newBullFvg
    score = f_quality_score(bullGap, bullGapPct)
    f_add_zone(low, high[2], 1, false, score)

if newBearFvg
    score = f_quality_score(bearGap, bearGapPct)
    f_add_zone(low[2], high, -1, false, score)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE UPDATES / MITIGATION / INVERSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool bullMitigatedSignal = false
var bool bearMitigatedSignal = false
var bool bullIfvgSignal = false
var bool bearIfvgSignal = false

bullMitigatedSignal := false
bearMitigatedSignal := false
bullIfvgSignal := false
bearIfvgSignal := false

activeBull = 0
activeBear = 0
activeIFVG = 0

if array.size(zoneBoxes) > 0
    for i = array.size(zoneBoxes) - 1 to 0
        b = array.get(zoneBoxes, i)
        ln = array.get(midLines, i)
        top = array.get(zoneTops, i)
        bottom = array.get(zoneBottoms, i)
        dir = array.get(zoneDirs, i)
        born = array.get(zoneBornBars, i)
        inverted = array.get(zoneInverted, i)
        mitigated = array.get(zoneMitigated, i)
        score = array.get(zoneScores, i)

        expired = bar_index - born > validityBars

        box.set_right(b, bar_index + extendBars)
        line.set_x2(ln, bar_index + extendBars)

        inversionBear = not inverted and dir == 1 and (inversionMode == "Close Through Zone" ? close < bottom : low < bottom)
        inversionBull = not inverted and dir == -1 and (inversionMode == "Close Through Zone" ? close > top : high > top)

        if showIFVG and inversionBear
            array.set(zoneDirs, i, -1)
            array.set(zoneInverted, i, true)
            array.set(zoneMitigated, i, false)
            box.set_bgcolor(b, color.new(ifvgBearColor, zoneTransparency))
            box.set_border_color(b, color.new(ifvgBearColor, 20))
            box.set_text(b, showQualityText ? "IFVG " + f_quality_text(score) : "")
            line.set_color(ln, showMidline ? color.new(ifvgBearColor, 35) : color.new(ifvgBearColor, 100))
            bearIfvgSignal := true

            if showLabels
                lb = label.new(bar_index, high, "Bearish IFVG", style=label.style_label_down, color=color.new(ifvgBearColor, 0), textcolor=color.white, size=size.small)
                array.set(zoneLabels, i, lb)

        if showIFVG and inversionBull
            array.set(zoneDirs, i, 1)
            array.set(zoneInverted, i, true)
            array.set(zoneMitigated, i, false)
            box.set_bgcolor(b, color.new(ifvgBullColor, zoneTransparency))
            box.set_border_color(b, color.new(ifvgBullColor, 20))
            box.set_text(b, showQualityText ? "IFVG " + f_quality_text(score) : "")
            line.set_color(ln, showMidline ? color.new(ifvgBullColor, 35) : color.new(ifvgBullColor, 100))
            bullIfvgSignal := true

            if showLabels
                lb = label.new(bar_index, low, "Bullish IFVG", style=label.style_label_up, color=color.new(ifvgBullColor, 0), textcolor=color.white, size=size.small)
                array.set(zoneLabels, i, lb)

        dirNow = array.get(zoneDirs, i)
        level = f_mid_level(top, bottom, dirNow)

        bullMitigation = not mitigated and dirNow == 1 and low <= level and high >= bottom
        bearMitigation = not mitigated and dirNow == -1 and high >= level and low <= top

        if bullMitigation
            array.set(zoneMitigated, i, true)
            bullMitigatedSignal := true
            box.set_bgcolor(b, color.new(bullColor, 90))

            if showLabels
                lb = label.new(bar_index, low, "FVG Tap", style=label.style_label_up, color=color.new(bullColor, 0), textcolor=color.white, size=size.tiny)
                array.set(zoneLabels, i, lb)

        if bearMitigation
            array.set(zoneMitigated, i, true)
            bearMitigatedSignal := true
            box.set_bgcolor(b, color.new(bearColor, 90))

            if showLabels
                lb = label.new(bar_index, high, "FVG Tap", style=label.style_label_down, color=color.new(bearColor, 0), textcolor=color.white, size=size.tiny)
                array.set(zoneLabels, i, lb)

        if array.get(zoneInverted, i)
            activeIFVG += 1
        else if array.get(zoneDirs, i) == 1
            activeBull += 1
        else
            activeBear += 1

        shouldDelete = (deleteMitigated and array.get(zoneMitigated, i)) or (deleteExpired and expired)

        if shouldDelete
            oldBox = array.remove(zoneBoxes, i)
            oldLine = array.remove(midLines, i)
            oldLabel = array.remove(zoneLabels, i)
            array.remove(zoneTops, i)
            array.remove(zoneBottoms, i)
            array.remove(zoneDirs, i)
            array.remove(zoneBornBars, i)
            array.remove(zoneInverted, i)
            array.remove(zoneMitigated, i)
            array.remove(zoneScores, i)

            box.delete(oldBox)
            line.delete(oldLine)
            if not na(oldLabel)
                label.delete(oldLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA VISUAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(useTrendFilter ? ema : na, "Trend EMA", color=color.new(f_text_color(), 35), linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(f_dash_pos(dashPosition), 2, 6, border_width=1)

if barstate.islast and showDashboard
    table.clear(dash, 0, 0, 1, 5)

    panelBg = f_panel_bg()
    txt = f_text_color()
    border = f_border_color()

    table.cell(dash, 0, 0, "Elaris FVG Pro", bgcolor=panelBg, text_color=txt, text_size=size.small)
    table.cell(dash, 1, 0, "Live Map", bgcolor=panelBg, text_color=txt, text_size=size.small)

    table.cell(dash, 0, 1, "Bullish FVG", bgcolor=panelBg, text_color=txt)
    table.cell(dash, 1, 1, str.tostring(activeBull), bgcolor=color.new(bullColor, 80), text_color=txt)

    table.cell(dash, 0, 2, "Bearish FVG", bgcolor=panelBg, text_color=txt)
    table.cell(dash, 1, 2, str.tostring(activeBear), bgcolor=color.new(bearColor, 80), text_color=txt)

    table.cell(dash, 0, 3, "IFVG Zones", bgcolor=panelBg, text_color=txt)
    table.cell(dash, 1, 3, str.tostring(activeIFVG), bgcolor=color.new(ifvgBullColor, 82), text_color=txt)

    table.cell(dash, 0, 4, "Trend Filter", bgcolor=panelBg, text_color=txt)
    table.cell(dash, 1, 4, useTrendFilter ? (close > ema ? "Bullish" : "Bearish") : "Off", bgcolor=panelBg, text_color=txt)

    table.cell(dash, 0, 5, "Mode", bgcolor=panelBg, text_color=txt)
    table.cell(dash, 1, 5, confirmBars ? "Non-Repaint" : "Realtime", bgcolor=panelBg, text_color=txt)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(enableFvgAlerts and newBullFvg, "New Bullish FVG", "Elaris FVG Pro: New Bullish Fair Value Gap detected.")
alertcondition(enableFvgAlerts and newBearFvg, "New Bearish FVG", "Elaris FVG Pro: New Bearish Fair Value Gap detected.")

alertcondition(enableIfvgAlerts and bullIfvgSignal, "Bullish IFVG", "Elaris FVG Pro: Bearish FVG inverted into Bullish IFVG.")
alertcondition(enableIfvgAlerts and bearIfvgSignal, "Bearish IFVG", "Elaris FVG Pro: Bullish FVG inverted into Bearish IFVG.")

alertcondition(enableMitigateAlerts and bullMitigatedSignal, "Bullish FVG Mitigation", "Elaris FVG Pro: Bullish FVG mitigation/tap detected.")
alertcondition(enableMitigateAlerts and bearMitigatedSignal, "Bearish FVG Mitigation", "Elaris FVG Pro: Bearish FVG mitigation/tap detected.")
````
