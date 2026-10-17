# [KTY] Auto Trendlines

- url: https://www.tradingview.com/script/czjJnwDP-KTY-Auto-Trendlines/
- type: indicator
- pine_id: PUB;c1446226eea94b3bb2ae72b815b55d25
- version: 1.0

## Description

[b][KTY] Auto Trendlines[/b]

Automatically detects and draws diagonal trendlines
based on pivot highs and lows.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]🔑 Key Features[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]✅ Auto Trendline Detection[/b]

Scans recent price action and plots dynamic trendlines
that adapt to ongoing market structure.

Bullish (Green): Connects ascending lows — acts as dynamic support
Bearish (Red): Connects descending highs — acts as dynamic resistance

Each trendline includes a soft glow background
for clearer visual weight.
Confirmed segments are drawn solid,
while projected extensions appear dotted.

[b]✅ Multi-Length System[/b]

Two independent trendline groups (L1, L2) run simultaneously,
allowing you to track short-term and longer-term trends
on the same chart.

[b]✅ Smart Anchor Replacement[/b]

Trendline starting points are automatically refined
to prevent the line from cutting through candles,
producing cleaner and more reliable trendlines.

[b]✅ Angle Filter[/b]

Filters out trendlines that are too flat or too steep,
removing noise and keeping only meaningful structures.
Optional angle labels can be enabled in Debug mode
to help you fine-tune the filter range.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]📖 How to Use[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣ Bounce off bullish trendline → higher chance of trend continuation
2️⃣ Rejection at bearish trendline → higher chance of downward move
3️⃣ Trendline break → potential trend reversal or shift in structure

🔄 Trendline Break
- Broken bullish trendline may signal weakening uptrend
- Broken bearish trendline may signal weakening downtrend
- Watch for retest of the broken trendline before entering

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]🔧 Settings[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Trendlines
- Show Trendlines: Toggle visibility on/off
- Bullish Color: Customize bullish trendline color (default: green)
- Bearish Color: Customize bearish trendline color (default: red)

🧪 Lengths
- Show L1 / Length 1: Toggle and set short-term pivot length
- Show L2 / Length 2: Toggle and set longer-term pivot length

🎯 Detection
- Anchor Replacement: Refines trendline start points for cleaner lines
- Future Extension Bars: Length of the projected (dotted) extension
- Break Bars Limit: How long broken trendlines remain on the chart

📐 Angle Filter
- Use Angle Filter: Toggle filtering of flat/steep trendlines
- Min Angle / Max Angle: Allowed angle range for valid trendlines

🐞 Debug
- Show Angle Label: Display the angle (°) at each trendline's start point,
  useful when adjusting the angle filter range

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]🔔 Alerts[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 Bullish Trendline Break: Triggers when price closes below a bullish trendline
🔴 Bearish Trendline Break: Triggers when price closes above a bearish trendline
⚡ Any Trendline Break: Triggers on any trendline break event

Setup: ALT + A → Select 【Auto Trendlines】→ Create alert

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]⚠️ Disclaimer[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is an analysis tool, not a trade signal service.
Based on historical pivot data — does not guarantee future price reactions.
Strong trends or sudden volatility may invalidate trendlines.
All trading decisions and associated risks are solely your responsibility.

## Source Code

````pine
// ██╗  ██╗████████╗██╗   ██╗
// ██║ ██╔╝╚══██╔══╝╚██╗ ██╔╝
// █████╔╝    ██║    ╚████╔╝ 
// ██╔═██╗    ██║     ╚██╔╝  
// ██║  ██╗   ██║      ██║   
// ╚═╝  ╚═╝   ╚═╝      ╚═╝   
// Kim Thank You (김땡큐)

// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator(title='[KTY] Auto Trendlines', shorttitle='[KTY] Trendlines', overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT SETTINGS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Main ───
grp_tl = '✅ Trendlines'
showTrendlines = input.bool(true, "Show Trendlines (Support/Resistance)", group=grp_tl)
upCss          = input.color(color.new(#178e61, 0), title='Bullish Color', inline='colors', group=grp_tl)
dnCss          = input.color(color.new(#c82d39, 0), title='Bearish Color', inline='colors', group=grp_tl)

// ─── Lengths ───
grp_len = '🧪 Lengths'
show1   = input.bool(true, "Show L1", inline='L1', group=grp_len)
length1 = input.int(25, "Length 1", minval=2, inline='L1', group=grp_len)
show2   = input.bool(true, "Show L2", inline='L2', group=grp_len)
length2 = input.int(80, "Length 2", minval=2, inline='L2', group=grp_len)

// ─── Detection ───
grp_det = '🎯 Detection'
useAnchorReplace = input.bool(true,  "Anchor Replacement",  group=grp_det, tooltip="추세선이 캔들을 뚫고 지나가지 않게 시작점을 더 극단적인 캔들로 자동 교체.")
future_bars      = input.int(100,    "Future Extension Bars", minval=10, maxval=500, group=grp_det)
breakBarsLimit   = input.int(200,    "Break Bars Limit",      minval=10, maxval=1000, group=grp_det, tooltip="추세선이 깨진 후 차트에서 유지되는 봉 수.")

// ─── Angle Filter ───
grp_ang = '📐 Angle Filter'
useAngleFilter = input.bool(true,  "Use Angle Filter", group=grp_ang, tooltip="너무 평평하거나 너무 가파른 추세선을 자동 필터링.")
anglA          = input.float(1.0,  "Min Angle (°)", minval=0.0,  maxval=89.0, step=0.5, group=grp_ang)
anglB          = input.float(60.0, "Max Angle (°)", minval=1.0,  maxval=90.0, step=0.5, group=grp_ang)

// ─── Debug ───
grp_debug = '🐞 Debug'
showAngle = input.bool(false, "Show Angle Label (°)", group=grp_debug, tooltip="추세선 시작점에 각도를 표시 (예: 25°). 각도 필터 값 조정 시 참고용.")

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HARDCODED (사용자 노출 안 됨)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── ATR ───
atrLength = 14
atrMultiplier = 0.5

// ─── Visual / Counts ───
maxBearishCount = 3
maxBullishCount = 3
LineStyleEnum1 = line.style_solid
LineStyleEnum2 = line.style_dotted
lineThickness = 2
maxBarsBack_limit = 2000

// ─── Glow & Fill ───
showGlow = true
glowTransp1 = 80
glowTransp2 = 90
fillGlow1Ratio = 1.0
fillGlow2Ratio = 0.8
fillGlow3Ratio = 0.6
fillGlow4Ratio = 0.4
fillGlow5Ratio = 0.2
fillGlowTransp1 = 88
fillGlowTransp2 = 84
fillGlowTransp3 = 80
fillGlowTransp4 = 75
fillGlowTransp5 = 70

bars = 500
height = int(bars / 1)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE FUNCTIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

n = bar_index
Xaxis = math.min(math.max(1, n), bars)
Yaxis = ta.highest(Xaxis) - ta.lowest(Xaxis)

atrValue = ta.atr(atrLength)

calculate_slope(int x1, int x2, float y1, float y2) =>
    diffX = x2 - x1
    diffY = y2 - y1
    diffY_to_Yaxis = Yaxis / diffY
    normalised_slope = height / diffY_to_Yaxis / diffX
    slope = diffY / diffX
    angle = math.round(math.atan(normalised_slope) * 180 / math.pi, 2)
    [normalised_slope, slope, angle]

find_extreme_anchor(int p1Bar, float p1Val, int p2Bar, bool isBullish) =>
    int newBar = p1Bar
    float newVal = p1Val
    if not na(p1Bar) and not na(p2Bar) and p2Bar > p1Bar
        startOffset = n - p2Bar
        endOffset = n - p1Bar
        if endOffset - startOffset > 1
            for offset = startOffset + 1 to endOffset - 1
                if isBullish
                    candleLow = low[offset]
                    if not na(candleLow) and candleLow < newVal
                        newVal := candleLow
                        newBar := n - offset
                else
                    candleHigh = high[offset]
                    if not na(candleHigh) and candleHigh > newVal
                        newVal := candleHigh
                        newBar := n - offset
    [newBar, newVal]

make_angle_label(int barX, float price, float angle, color col, bool isBullish) =>
    label result = na
    if showAngle and not na(barX) and not na(price) and not na(angle)
        result := label.new(barX, price,
             text=str.tostring(math.abs(angle)) + "°",
             style=isBullish ? label.style_label_up : label.style_label_down,
             color=color.new(col, 30),
             textcolor=color.white,
             size=size.small)
    result

// ─── Array helpers ───
add_line(array<line> arr, line ln, int max_count) =>
    array.unshift(arr, ln)
    if array.size(arr) > max_count
        line.delete(array.pop(arr))

add_label(array<label> arr, label lb, int max_count) =>
    array.unshift(arr, lb)
    if array.size(arr) > max_count
        label.delete(array.pop(arr))

add_linefill(array<linefill> arr, linefill lf, int max_count) =>
    array.unshift(arr, lf)
    if array.size(arr) > max_count
        linefill.delete(array.pop(arr))

add_int(array<int> arr, int v, int max_count) =>
    array.unshift(arr, v)
    if array.size(arr) > max_count
        array.pop(arr)

remove_line_at(array<line> arr, int i) =>
    if array.size(arr) > i
        line.delete(array.get(arr, i))
        array.remove(arr, i)

remove_label_at(array<label> arr, int i) =>
    if array.size(arr) > i
        label.delete(array.get(arr, i))
        array.remove(arr, i)

remove_linefill_at(array<linefill> arr, int i) =>
    if array.size(arr) > i
        linefill.delete(array.get(arr, i))
        array.remove(arr, i)

remove_int_at(array<int> arr, int i) =>
    if array.size(arr) > i
        array.remove(arr, i)

remove_tl_set(array<line> solid, array<line> dotted, array<line> g1, array<line> g2,
              array<line> outerExt, array<line> fl1, array<line> fl2, array<line> fl3, array<line> fl4, array<line> fl5,
              array<linefill> fill1, array<linefill> fill2, array<linefill> fill3, array<linefill> fill4, array<linefill> fill5,
              array<line> innerLn, array<label> angLbls, array<int> bb, int i) =>
    remove_line_at(solid, i)
    remove_line_at(dotted, i)
    remove_line_at(g1, i)
    remove_line_at(g2, i)
    remove_line_at(outerExt, i)
    remove_line_at(fl1, i)
    remove_line_at(fl2, i)
    remove_line_at(fl3, i)
    remove_line_at(fl4, i)
    remove_line_at(fl5, i)
    remove_linefill_at(fill1, i)
    remove_linefill_at(fill2, i)
    remove_linefill_at(fill3, i)
    remove_linefill_at(fill4, i)
    remove_linefill_at(fill5, i)
    remove_line_at(innerLn, i)
    remove_label_at(angLbls, i)
    remove_int_at(bb, i)

create_offset_line_atr(int x1, float y1, int dx, float dy, float atrOff, bool isBullish, color col) =>
    float signedOff = isBullish ? atrOff : -atrOff
    y1Off = y1 + signedOff
    dyOff = dy + signedOff
    line.new(x1, y1Off, dx, dyOff, color=color.new(col, 100), style=line.style_solid, width=1)

create_tl_set(int x1, float y1, int x2, float y2, int dx, float dy, float angle, float atrAtCreation, bool isBullish, color col,
              array<line> solidArr, array<line> dottedArr, array<line> g1Arr, array<line> g2Arr,
              array<line> outerExtArr,
              array<line> fl1Arr, array<line> fl2Arr, array<line> fl3Arr, array<line> fl4Arr, array<line> fl5Arr,
              array<linefill> fill1Arr, array<linefill> fill2Arr, array<linefill> fill3Arr, array<linefill> fill4Arr, array<linefill> fill5Arr,
              array<line> innerArr, array<label> angLblArr, array<int> bbArr, int maxCt) =>
    line gl1 = na
    line gl2 = na
    if showGlow
        gl2 := line.new(x1, y1, x2, y2, color=color.new(col, glowTransp2), style=LineStyleEnum1, width=8)
        gl1 := line.new(x1, y1, x2, y2, color=color.new(col, glowTransp1), style=LineStyleEnum1, width=5)
    add_line(g2Arr, gl2, maxCt)
    add_line(g1Arr, gl1, maxCt)
    sl = line.new(x1, y1, x2, y2, color=col, style=LineStyleEnum1, width=lineThickness)
    dl = line.new(x2, y2, dx, dy, color=col, style=LineStyleEnum2, width=lineThickness)
    add_line(solidArr, sl, maxCt)
    add_line(dottedArr, dl, maxCt)

    outerExt = line.new(x1, y1, dx, dy, color=color.new(col, 100), style=line.style_solid, width=1)
    add_line(outerExtArr, outerExt, maxCt)

    baseOffset = atrAtCreation * atrMultiplier

    fl1 = create_offset_line_atr(x1, y1, dx, dy, baseOffset * fillGlow1Ratio, isBullish, col)
    fl2 = create_offset_line_atr(x1, y1, dx, dy, baseOffset * fillGlow2Ratio, isBullish, col)
    fl3 = create_offset_line_atr(x1, y1, dx, dy, baseOffset * fillGlow3Ratio, isBullish, col)
    fl4 = create_offset_line_atr(x1, y1, dx, dy, baseOffset * fillGlow4Ratio, isBullish, col)
    fl5 = create_offset_line_atr(x1, y1, dx, dy, baseOffset * fillGlow5Ratio, isBullish, col)
    add_line(fl1Arr, fl1, maxCt)
    add_line(fl2Arr, fl2, maxCt)
    add_line(fl3Arr, fl3, maxCt)
    add_line(fl4Arr, fl4, maxCt)
    add_line(fl5Arr, fl5, maxCt)

    innerLn = create_offset_line_atr(x1, y1, dx, dy, baseOffset * fillGlow1Ratio, isBullish, col)
    add_line(innerArr, innerLn, maxCt)

    f1 = linefill.new(outerExt, fl5, color.new(col, fillGlowTransp5))
    f2 = linefill.new(fl5,      fl4, color.new(col, fillGlowTransp4))
    f3 = linefill.new(fl4,      fl3, color.new(col, fillGlowTransp3))
    f4 = linefill.new(fl3,      fl2, color.new(col, fillGlowTransp2))
    f5 = linefill.new(fl2,      fl1, color.new(col, fillGlowTransp1))
    add_linefill(fill1Arr, f1, maxCt)
    add_linefill(fill2Arr, f2, maxCt)
    add_linefill(fill3Arr, f3, maxCt)
    add_linefill(fill4Arr, f4, maxCt)
    add_linefill(fill5Arr, f5, maxCt)

    angLbl = make_angle_label(x1, y1, angle, col, isBullish)
    add_label(angLblArr, angLbl, maxCt)

    add_int(bbArr, 0, maxCt)

cleanup_old_trendlines(array<line> solid, array<line> dotted, array<line> g1, array<line> g2,
                       array<line> outerExt,
                       array<line> fl1, array<line> fl2, array<line> fl3, array<line> fl4, array<line> fl5,
                       array<linefill> fill1, array<linefill> fill2, array<linefill> fill3, array<linefill> fill4, array<linefill> fill5,
                       array<line> innerLn, array<label> angLbls, array<int> bb, int currentBar, int maxBars) =>
    if array.size(solid) > 0
        for i = array.size(solid) - 1 to 0
            sl = array.get(solid, i)
            if not na(sl) and currentBar - line.get_x1(sl) > maxBars
                remove_tl_set(solid, dotted, g1, g2, outerExt, fl1, fl2, fl3, fl4, fl5, fill1, fill2, fill3, fill4, fill5, innerLn, angLbls, bb, i)

get_trendline_y(line solidLn, int currentBar) =>
    x1 = line.get_x1(solidLn)
    y1 = line.get_y1(solidLn)
    x2 = line.get_x2(solidLn)
    y2 = line.get_y2(solidLn)
    slope = (y2 - y1) / (x2 - x1)
    y1 + slope * (currentBar - x1)

check_break(array<line> solid, array<line> dotted, array<line> g1, array<line> g2,
            array<line> outerExt,
            array<line> fl1, array<line> fl2, array<line> fl3, array<line> fl4, array<line> fl5,
            array<linefill> fill1, array<linefill> fill2, array<linefill> fill3, array<linefill> fill4, array<linefill> fill5,
            array<line> innerLn, array<label> angLbls, array<int> bb,
            int currentBar, int breakLimit, bool isBullish) =>
    bool breakOccurred = false
    if array.size(innerLn) > 0
        for i = array.size(innerLn) - 1 to 0
            innLn = array.get(innerLn, i)
            if not na(innLn)
                trend_y = get_trendline_y(innLn, currentBar)
                bbVal = array.get(bb, i)
                bool isBroken = false
                if isBullish
                    if close < trend_y
                        isBroken := true
                else
                    if close > trend_y
                        isBroken := true
                if isBroken and bbVal == 0
                    array.set(bb, i, currentBar)
                    breakOccurred := true
                if bbVal > 0 and currentBar - bbVal >= breakLimit
                    remove_tl_set(solid, dotted, g1, g2, outerExt, fl1, fl2, fl3, fl4, fl5, fill1, fill2, fill3, fill4, fill5, innerLn, angLbls, bb, i)
    breakOccurred

draw_trendlines(array<line> solid, array<line> dotted, array<line> g1, array<line> g2,
                array<line> outerExt, array<line> fl1, array<line> fl2, array<line> fl3, array<line> fl4, array<line> fl5,
                array<line> innerLn, int currentBar, int futureBars) =>
    for i = 0 to array.size(solid) - 1
        sl = array.get(solid, i)
        if not na(sl)
            line.set_xy1(sl, line.get_x1(sl), line.get_y1(sl))
            line.set_xy2(sl, line.get_x2(sl), line.get_y2(sl))
        if i < array.size(g1)
            gg1 = array.get(g1, i)
            if not na(gg1)
                line.set_xy1(gg1, line.get_x1(gg1), line.get_y1(gg1))
                line.set_xy2(gg1, line.get_x2(gg1), line.get_y2(gg1))
        if i < array.size(g2)
            gg2 = array.get(g2, i)
            if not na(gg2)
                line.set_xy1(gg2, line.get_x1(gg2), line.get_y1(gg2))
                line.set_xy2(gg2, line.get_x2(gg2), line.get_y2(gg2))

        if not na(sl) and i < array.size(dotted)
            dl = array.get(dotted, i)
            if not na(dl)
                slope = (line.get_y2(sl) - line.get_y1(sl)) / (line.get_x2(sl) - line.get_x1(sl))
                newDx = currentBar + futureBars
                newDy = line.get_y2(sl) + slope * (newDx - line.get_x2(sl))
                line.set_xy1(dl, line.get_x2(sl), line.get_y2(sl))
                line.set_xy2(dl, newDx, newDy)

                extDx = newDx
                if i < array.size(outerExt)
                    oe = array.get(outerExt, i)
                    if not na(oe)
                        oeSlope = (line.get_y2(oe) - line.get_y1(oe)) / (line.get_x2(oe) - line.get_x1(oe))
                        line.set_xy2(oe, extDx, line.get_y1(oe) + oeSlope * (extDx - line.get_x1(oe)))
                if i < array.size(fl1)
                    f = array.get(fl1, i)
                    if not na(f)
                        fSlope = (line.get_y2(f) - line.get_y1(f)) / (line.get_x2(f) - line.get_x1(f))
                        line.set_xy2(f, extDx, line.get_y1(f) + fSlope * (extDx - line.get_x1(f)))
                if i < array.size(fl2)
                    f = array.get(fl2, i)
                    if not na(f)
                        fSlope = (line.get_y2(f) - line.get_y1(f)) / (line.get_x2(f) - line.get_x1(f))
                        line.set_xy2(f, extDx, line.get_y1(f) + fSlope * (extDx - line.get_x1(f)))
                if i < array.size(fl3)
                    f = array.get(fl3, i)
                    if not na(f)
                        fSlope = (line.get_y2(f) - line.get_y1(f)) / (line.get_x2(f) - line.get_x1(f))
                        line.set_xy2(f, extDx, line.get_y1(f) + fSlope * (extDx - line.get_x1(f)))
                if i < array.size(fl4)
                    f = array.get(fl4, i)
                    if not na(f)
                        fSlope = (line.get_y2(f) - line.get_y1(f)) / (line.get_x2(f) - line.get_x1(f))
                        line.set_xy2(f, extDx, line.get_y1(f) + fSlope * (extDx - line.get_x1(f)))
                if i < array.size(fl5)
                    f = array.get(fl5, i)
                    if not na(f)
                        fSlope = (line.get_y2(f) - line.get_y1(f)) / (line.get_x2(f) - line.get_x1(f))
                        line.set_xy2(f, extDx, line.get_y1(f) + fSlope * (extDx - line.get_x1(f)))
                if i < array.size(innerLn)
                    f = array.get(innerLn, i)
                    if not na(f)
                        fSlope = (line.get_y2(f) - line.get_y1(f)) / (line.get_x2(f) - line.get_x1(f))
                        line.set_xy2(f, extDx, line.get_y1(f) + fSlope * (extDx - line.get_x1(f)))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAK FLAGS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool bullishBreak_1 = false
bool bearishBreak_1 = false
bool bullishBreak_2 = false
bool bearishBreak_2 = false

// ─────────────────────────────────────────────────────────────────────────────
// LENGTH #1
// ─────────────────────────────────────────────────────────────────────────────
var array<line>     bearSolid_1   = array.new_line()
var array<line>     bearDotted_1  = array.new_line()
var array<line>     bearGlow1_1   = array.new_line()
var array<line>     bearGlow2_1   = array.new_line()
var array<line>     bearOuterExt_1= array.new_line()
var array<line>     bearFL1_1     = array.new_line()
var array<line>     bearFL2_1     = array.new_line()
var array<line>     bearFL3_1     = array.new_line()
var array<line>     bearFL4_1     = array.new_line()
var array<line>     bearFL5_1     = array.new_line()
var array<linefill> bearFill1_1   = array.new<linefill>()
var array<linefill> bearFill2_1   = array.new<linefill>()
var array<linefill> bearFill3_1   = array.new<linefill>()
var array<linefill> bearFill4_1   = array.new<linefill>()
var array<linefill> bearFill5_1   = array.new<linefill>()
var array<line>     bearInner_1   = array.new_line()
var array<label>    bearAngLbl_1  = array.new_label()
var array<int>      bearBB_1      = array.new_int()
var array<line>     bullSolid_1   = array.new_line()
var array<line>     bullDotted_1  = array.new_line()
var array<line>     bullGlow1_1   = array.new_line()
var array<line>     bullGlow2_1   = array.new_line()
var array<line>     bullOuterExt_1= array.new_line()
var array<line>     bullFL1_1     = array.new_line()
var array<line>     bullFL2_1     = array.new_line()
var array<line>     bullFL3_1     = array.new_line()
var array<line>     bullFL4_1     = array.new_line()
var array<line>     bullFL5_1     = array.new_line()
var array<linefill> bullFill1_1   = array.new<linefill>()
var array<linefill> bullFill2_1   = array.new<linefill>()
var array<linefill> bullFill3_1   = array.new<linefill>()
var array<linefill> bullFill4_1   = array.new<linefill>()
var array<linefill> bullFill5_1   = array.new<linefill>()
var array<line>     bullInner_1   = array.new_line()
var array<label>    bullAngLbl_1  = array.new_label()
var array<int>      bullBB_1      = array.new_int()

var int phx1_1 = na
var float phslope_1 = na
var float phy1_1 = na
var float upper_1 = na
var int plx1_1 = na
var float plslope_1 = na
var float ply1_1 = na
var float lower_1 = na

ph_1 = ta.pivothigh(length1, length1)
pl_1 = ta.pivotlow(length1, length1)

if show1 and showTrendlines
    if not na(ph_1)
        if ph_1 < phy1_1
            int newPhx = phx1_1
            float newPhy = phy1_1
            if useAnchorReplace
                [b, v] = find_extreme_anchor(phx1_1, phy1_1, n - length1, false)
                newPhx := b
                newPhy := v
            [_n1, slope, angle] = calculate_slope(newPhx, n - length1, newPhy, ph_1)
            if not useAngleFilter or (math.abs(angle) > anglA and math.abs(angle) < anglB)
                phslope_1 := slope
                upper_1 := ph_1 + slope * length1
                create_tl_set(newPhx, newPhy, n, upper_1, n + future_bars, upper_1 + phslope_1 * future_bars, angle, atrValue, false, dnCss,
                  bearSolid_1, bearDotted_1, bearGlow1_1, bearGlow2_1, bearOuterExt_1,
                  bearFL1_1, bearFL2_1, bearFL3_1, bearFL4_1, bearFL5_1,
                  bearFill1_1, bearFill2_1, bearFill3_1, bearFill4_1, bearFill5_1,
                  bearInner_1, bearAngLbl_1, bearBB_1, maxBearishCount)
        phy1_1 := ph_1
        phx1_1 := n - length1
    upper_1 += phslope_1

    if not na(pl_1)
        if pl_1 > ply1_1
            int newPlx = plx1_1
            float newPly = ply1_1
            if useAnchorReplace
                [b, v] = find_extreme_anchor(plx1_1, ply1_1, n - length1, true)
                newPlx := b
                newPly := v
            [_n2, slope, angle] = calculate_slope(newPlx, n - length1, newPly, pl_1)
            if not useAngleFilter or (angle > anglA and angle < anglB)
                plslope_1 := slope
                lower_1 := pl_1 + slope * length1
                create_tl_set(newPlx, newPly, n, lower_1, n + future_bars, lower_1 + plslope_1 * future_bars, angle, atrValue, true, upCss,
                  bullSolid_1, bullDotted_1, bullGlow1_1, bullGlow2_1, bullOuterExt_1,
                  bullFL1_1, bullFL2_1, bullFL3_1, bullFL4_1, bullFL5_1,
                  bullFill1_1, bullFill2_1, bullFill3_1, bullFill4_1, bullFill5_1,
                  bullInner_1, bullAngLbl_1, bullBB_1, maxBullishCount)
        ply1_1 := pl_1
        plx1_1 := n - length1
    lower_1 += plslope_1

    cleanup_old_trendlines(bearSolid_1, bearDotted_1, bearGlow1_1, bearGlow2_1, bearOuterExt_1, bearFL1_1, bearFL2_1, bearFL3_1, bearFL4_1, bearFL5_1, bearFill1_1, bearFill2_1, bearFill3_1, bearFill4_1, bearFill5_1, bearInner_1, bearAngLbl_1, bearBB_1, n, maxBarsBack_limit)
    cleanup_old_trendlines(bullSolid_1, bullDotted_1, bullGlow1_1, bullGlow2_1, bullOuterExt_1, bullFL1_1, bullFL2_1, bullFL3_1, bullFL4_1, bullFL5_1, bullFill1_1, bullFill2_1, bullFill3_1, bullFill4_1, bullFill5_1, bullInner_1, bullAngLbl_1, bullBB_1, n, maxBarsBack_limit)

    bearishBreak_1 := check_break(bearSolid_1, bearDotted_1, bearGlow1_1, bearGlow2_1, bearOuterExt_1, bearFL1_1, bearFL2_1, bearFL3_1, bearFL4_1, bearFL5_1, bearFill1_1, bearFill2_1, bearFill3_1, bearFill4_1, bearFill5_1, bearInner_1, bearAngLbl_1, bearBB_1, n, breakBarsLimit, false)
    bullishBreak_1 := check_break(bullSolid_1, bullDotted_1, bullGlow1_1, bullGlow2_1, bullOuterExt_1, bullFL1_1, bullFL2_1, bullFL3_1, bullFL4_1, bullFL5_1, bullFill1_1, bullFill2_1, bullFill3_1, bullFill4_1, bullFill5_1, bullInner_1, bullAngLbl_1, bullBB_1, n, breakBarsLimit, true)

    if array.size(bearSolid_1) > 0
        draw_trendlines(bearSolid_1, bearDotted_1, bearGlow1_1, bearGlow2_1, bearOuterExt_1, bearFL1_1, bearFL2_1, bearFL3_1, bearFL4_1, bearFL5_1, bearInner_1, n, future_bars)
    if array.size(bullSolid_1) > 0
        draw_trendlines(bullSolid_1, bullDotted_1, bullGlow1_1, bullGlow2_1, bullOuterExt_1, bullFL1_1, bullFL2_1, bullFL3_1, bullFL4_1, bullFL5_1, bullInner_1, n, future_bars)

// ─────────────────────────────────────────────────────────────────────────────
// LENGTH #2
// ─────────────────────────────────────────────────────────────────────────────
var array<line>     bearSolid_2   = array.new_line()
var array<line>     bearDotted_2  = array.new_line()
var array<line>     bearGlow1_2   = array.new_line()
var array<line>     bearGlow2_2   = array.new_line()
var array<line>     bearOuterExt_2= array.new_line()
var array<line>     bearFL1_2     = array.new_line()
var array<line>     bearFL2_2     = array.new_line()
var array<line>     bearFL3_2     = array.new_line()
var array<line>     bearFL4_2     = array.new_line()
var array<line>     bearFL5_2     = array.new_line()
var array<linefill> bearFill1_2   = array.new<linefill>()
var array<linefill> bearFill2_2   = array.new<linefill>()
var array<linefill> bearFill3_2   = array.new<linefill>()
var array<linefill> bearFill4_2   = array.new<linefill>()
var array<linefill> bearFill5_2   = array.new<linefill>()
var array<line>     bearInner_2   = array.new_line()
var array<label>    bearAngLbl_2  = array.new_label()
var array<int>      bearBB_2      = array.new_int()
var array<line>     bullSolid_2   = array.new_line()
var array<line>     bullDotted_2  = array.new_line()
var array<line>     bullGlow1_2   = array.new_line()
var array<line>     bullGlow2_2   = array.new_line()
var array<line>     bullOuterExt_2= array.new_line()
var array<line>     bullFL1_2     = array.new_line()
var array<line>     bullFL2_2     = array.new_line()
var array<line>     bullFL3_2     = array.new_line()
var array<line>     bullFL4_2     = array.new_line()
var array<line>     bullFL5_2     = array.new_line()
var array<linefill> bullFill1_2   = array.new<linefill>()
var array<linefill> bullFill2_2   = array.new<linefill>()
var array<linefill> bullFill3_2   = array.new<linefill>()
var array<linefill> bullFill4_2   = array.new<linefill>()
var array<linefill> bullFill5_2   = array.new<linefill>()
var array<line>     bullInner_2   = array.new_line()
var array<label>    bullAngLbl_2  = array.new_label()
var array<int>      bullBB_2      = array.new_int()

var int phx1_2 = na
var float phslope_2 = na
var float phy1_2 = na
var float upper_2 = na
var int plx1_2 = na
var float plslope_2 = na
var float ply1_2 = na
var float lower_2 = na

ph_2 = ta.pivothigh(length2, length2)
pl_2 = ta.pivotlow(length2, length2)

if show2 and showTrendlines
    if not na(ph_2)
        if ph_2 < phy1_2
            int newPhx = phx1_2
            float newPhy = phy1_2
            if useAnchorReplace
                [b, v] = find_extreme_anchor(phx1_2, phy1_2, n - length2, false)
                newPhx := b
                newPhy := v
            [_n1, slope, angle] = calculate_slope(newPhx, n - length2, newPhy, ph_2)
            if not useAngleFilter or (math.abs(angle) > anglA and math.abs(angle) < anglB)
                phslope_2 := slope
                upper_2 := ph_2 + slope * length2
                create_tl_set(newPhx, newPhy, n, upper_2, n + future_bars, upper_2 + phslope_2 * future_bars, angle, atrValue, false, dnCss,
                  bearSolid_2, bearDotted_2, bearGlow1_2, bearGlow2_2, bearOuterExt_2,
                  bearFL1_2, bearFL2_2, bearFL3_2, bearFL4_2, bearFL5_2,
                  bearFill1_2, bearFill2_2, bearFill3_2, bearFill4_2, bearFill5_2,
                  bearInner_2, bearAngLbl_2, bearBB_2, maxBearishCount)
        phy1_2 := ph_2
        phx1_2 := n - length2
    upper_2 += phslope_2

    if not na(pl_2)
        if pl_2 > ply1_2
            int newPlx = plx1_2
            float newPly = ply1_2
            if useAnchorReplace
                [b, v] = find_extreme_anchor(plx1_2, ply1_2, n - length2, true)
                newPlx := b
                newPly := v
            [_n2, slope, angle] = calculate_slope(newPlx, n - length2, newPly, pl_2)
            if not useAngleFilter or (angle > anglA and angle < anglB)
                plslope_2 := slope
                lower_2 := pl_2 + slope * length2
                create_tl_set(newPlx, newPly, n, lower_2, n + future_bars, lower_2 + plslope_2 * future_bars, angle, atrValue, true, upCss,
                  bullSolid_2, bullDotted_2, bullGlow1_2, bullGlow2_2, bullOuterExt_2,
                  bullFL1_2, bullFL2_2, bullFL3_2, bullFL4_2, bullFL5_2,
                  bullFill1_2, bullFill2_2, bullFill3_2, bullFill4_2, bullFill5_2,
                  bullInner_2, bullAngLbl_2, bullBB_2, maxBullishCount)
        ply1_2 := pl_2
        plx1_2 := n - length2
    lower_2 += plslope_2

    cleanup_old_trendlines(bearSolid_2, bearDotted_2, bearGlow1_2, bearGlow2_2, bearOuterExt_2, bearFL1_2, bearFL2_2, bearFL3_2, bearFL4_2, bearFL5_2, bearFill1_2, bearFill2_2, bearFill3_2, bearFill4_2, bearFill5_2, bearInner_2, bearAngLbl_2, bearBB_2, n, maxBarsBack_limit)
    cleanup_old_trendlines(bullSolid_2, bullDotted_2, bullGlow1_2, bullGlow2_2, bullOuterExt_2, bullFL1_2, bullFL2_2, bullFL3_2, bullFL4_2, bullFL5_2, bullFill1_2, bullFill2_2, bullFill3_2, bullFill4_2, bullFill5_2, bullInner_2, bullAngLbl_2, bullBB_2, n, maxBarsBack_limit)

    bearishBreak_2 := check_break(bearSolid_2, bearDotted_2, bearGlow1_2, bearGlow2_2, bearOuterExt_2, bearFL1_2, bearFL2_2, bearFL3_2, bearFL4_2, bearFL5_2, bearFill1_2, bearFill2_2, bearFill3_2, bearFill4_2, bearFill5_2, bearInner_2, bearAngLbl_2, bearBB_2, n, breakBarsLimit, false)
    bullishBreak_2 := check_break(bullSolid_2, bullDotted_2, bullGlow1_2, bullGlow2_2, bullOuterExt_2, bullFL1_2, bullFL2_2, bullFL3_2, bullFL4_2, bullFL5_2, bullFill1_2, bullFill2_2, bullFill3_2, bullFill4_2, bullFill5_2, bullInner_2, bullAngLbl_2, bullBB_2, n, breakBarsLimit, true)

    if array.size(bearSolid_2) > 0
        draw_trendlines(bearSolid_2, bearDotted_2, bearGlow1_2, bearGlow2_2, bearOuterExt_2, bearFL1_2, bearFL2_2, bearFL3_2, bearFL4_2, bearFL5_2, bearInner_2, n, future_bars)
    if array.size(bullSolid_2) > 0
        draw_trendlines(bullSolid_2, bullDotted_2, bullGlow1_2, bullGlow2_2, bullOuterExt_2, bullFL1_2, bullFL2_2, bullFL3_2, bullFL4_2, bullFL5_2, bullInner_2, n, future_bars)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullishBreakAny = bullishBreak_1 or bullishBreak_2
bearishBreakAny = bearishBreak_1 or bearishBreak_2
anyBreak        = bullishBreakAny or bearishBreakAny

alertcondition(bullishBreakAny, title="🟢 Bullish Trendline Break", message="🟢 Bullish trendline broken on {{ticker}} {{interval}}")
alertcondition(bearishBreakAny, title="🔴 Bearish Trendline Break", message="🔴 Bearish trendline broken on {{ticker}} {{interval}}")
alertcondition(anyBreak,        title="⚡ Any Trendline Break",     message="⚡ Trendline break detected on {{ticker}} {{interval}}")
````
