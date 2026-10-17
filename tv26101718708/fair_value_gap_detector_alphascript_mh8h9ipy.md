# Fair Value Gap Detector | AlphaScript

- url: https://www.tradingview.com/script/mH8H9iPy-Fair-Value-Gap-Detector-AlphaScript/
- type: indicator
- pine_id: PUB;31ddf8a27e654d5fb7264e7c183bb104
- version: 1.0

## Description

[b]⚡ Fair Value Gap Detector[/b]

Most fair value gap indicators mark every three-candle gap on the chart — including the weak, meaningless ones. This tool only marks FVGs created by genuine displacement: a strong-bodied move that signals real institutional participation. Fewer gaps, but the ones that matter.

[b]💡 What a fair value gap is[/b]
A fair value gap (FVG) is a three-candle imbalance where price moved so quickly that it left an unfilled gap. In a bullish FVG, the low of the third candle sits above the high of the first — the middle candle's move was so strong it skipped a price range where little trading occurred. Price often returns to "fill" these gaps before continuing, which is why traders watch them as potential entry and reaction zones.

[b]🎯 Why displacement matters[/b]
A gap alone is not significant, gaps form constantly, most from weak or random price action. What makes an FVG worth trading is displacement: the middle candle being a large, decisive move that leaves the gap behind. This tool measures the middle candle's body against ATR and only registers the FVG when that body is large enough to qualify as real displacement, and when it moved in the gap's direction. The result is a chart showing institutional-grade gaps instead of noise.

[b]🔍 How detection works[/b]
On each confirmed three-candle sequence the tool checks:

A valid gap exists (third candle's low above first candle's high for bullish; third's high below first's low for bearish).
The gap is at least a minimum size, measured as a multiple of ATR, so it is instrument-independent.
The middle candle's body is a genuine displacement — at least a configurable multiple of ATR — and pushed in the gap's direction.
Only sequences passing all three become FVG zones. The displacement requirement can be turned off if you prefer the classic "any gap" behavior.

[b]🟩 Mitigation tracking[/b]
Each FVG zone stays active until price fills it. You choose how a fill is counted:

Touch — the gap is mitigated when price reaches its midpoint (the 50% level, where FVGs often react).
Close — the gap is mitigated only when price closes fully through it.
A midline marks the 50% level of every zone.

[b]🎨 Customization[/b]
Bullish and bearish fill colors and opacity, midline display, and how far zones extend to the right (a configurable number of bars, so zones don't run infinitely across the chart, or fully infinite if you prefer). Separate toggles for bullish and bearish zones.

[b]📈 How to use it[/b]
Treat an active bullish FVG below price as a potential demand zone and an active bearish FVG above price as potential supply. Watch for price returning to a zone — especially the 50% midline — as a possible reaction point, in the direction of the displacement that created it. Because only displacement gaps are shown, each zone represents a move with real momentum behind it rather than a random imbalance. Combine with your own structure and bias — the tool marks the zones, you make the decisions.

[b]🔔 Alerts[/b]
Bullish FVG formed, bearish FVG formed, and mitigation alerts when a zone is filled.

[b]⚙️ Settings[/b]
ATR length and minimum gap size, displacement requirement and strength, mitigation mode, zone extension length, colors, opacity, midline, and per-direction display toggles.

[b]📌 Notes[/b]
FVGs are detected on confirmed bars only and do not repaint intrabar. Detection strictness depends on the gap-size and displacement settings — tune them to your instrument and timeframe. A fair value gap marks an area of potential interest, not a guaranteed reaction — always combine with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Fair Value Gap Detector | AlphaScript", shorttitle="FVG | AlphaScript", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=100)

// ============================================================
// INPUTS
// ============================================================
grpFilter  = "Filter Settings"
grpDisplay = "Display Settings"

atrLen       = input.int(14,    title="ATR Length",              group=grpFilter)
minAtrMult   = input.float(0.1, title="Min Gap Size (ATR mult)", group=grpFilter, minval=0.0, step=0.05, tooltip="Minimum FVG height as a multiple of ATR. Filters out tiny noise gaps.")
useDisplacement = input.bool(true, title="Require Displacement", group=grpFilter,
     tooltip="Only register an FVG when the middle (gap-creating) candle is a genuine displacement move — a large body relative to ATR — not just any 3-candle gap. This is what separates a real institutional FVG from a weak noise gap.")
dispMult     = input.float(1.0, title="Min Displacement (body × ATR)", group=grpFilter, minval=0.1, maxval=5.0, step=0.1,
     tooltip="The middle candle's body must be at least this multiple of ATR for the FVG to qualify. Higher = stricter, fewer but stronger FVGs. Only applies when Require Displacement is on.")
maxFVGs      = input.int(10,    title="Max FVGs to Display",     group=grpFilter, minval=1, maxval=50)
mitigMode    = input.string("Touch", title="Mitigation Mode", options=["Touch", "Close"], group=grpFilter, tooltip="Touch: FVG mitigated when price closes past the 50% midpoint. Close: FVG mitigated only when price closes through the opposite boundary.")

showBull     = input.bool(true,  title="Show Bullish FVGs",  group=grpDisplay)
showBear     = input.bool(true,  title="Show Bearish FVGs",  group=grpDisplay)
showMidLine  = input.bool(true,  title="Show Mid-Line",      group=grpDisplay)
extendMode   = input.string("Fixed Bars", title="Extend FVGs Right", options=["Infinite","Fixed Bars"], group=grpDisplay, inline="ext")
extendBars   = input.int(300, title="Bars", group=grpDisplay, inline="ext", minval=1, maxval=1000, tooltip="How many bars an FVG box/midline extends to the right. Prevents boxes running infinitely across the chart. Used when Extend = Fixed Bars.")

bullColor    = input.color(color.new(#26a69a, 75), title="Bullish Fill",   group=grpDisplay)
bearColor    = input.color(color.new(#ef5350, 75), title="Bearish Fill",   group=grpDisplay)
midColor     = input.color(color.new(#e0e0e0, 55), title="Mid-Line Color", group=grpDisplay)

// ============================================================
// TYPES
// ============================================================
type FVG
    float   top
    float   bottom
    float   mid
    int     startTime
    bool    isBullish
    bool    mitigated
    box     fvgBox
    line    midLine

// ============================================================
// ARRAYS
// ============================================================
var array<FVG> bullFVGs = array.new<FVG>()
var array<FVG> bearFVGs = array.new<FVG>()

// ============================================================
// CORE CALCULATIONS
// ============================================================
atrVal = ta.atr(atrLen)
minGap = atrVal * minAtrMult
msPerBar = bar_index > 0 ? time - time[1] : 0
f_boxExt() => extendMode == "Infinite" ? extend.right : extend.none

// ============================================================
// SMC FAIR VALUE GAP DETECTION
// ============================================================
bullGapTop    = low[0]
bullGapBot    = high[2]
bearGapTop    = low[2]
bearGapBot    = high[0]

// Displacement: the middle candle (index [1]) is the gap-creating bar.
// A true FVG comes from a strong-bodied displacement, not a weak drift.
midBody      = math.abs(close[1] - open[1])
dispOk       = not useDisplacement or midBody >= atrVal * dispMult
// For a bullish FVG the displacement candle should be bullish (up move);
// for a bearish FVG, bearish (down move). This rejects gaps whose middle
// candle pushed the opposite way.
bullDispDir  = not useDisplacement or close[1] > open[1]
bearDispDir  = not useDisplacement or close[1] < open[1]

bullCondition = barstate.isconfirmed and showBull and (bullGapTop > bullGapBot) and (bullGapTop - bullGapBot) >= minGap and dispOk and bullDispDir
bearCondition = barstate.isconfirmed and showBear and (bearGapTop > bearGapBot) and (bearGapTop - bearGapBot) >= minGap and dispOk and bearDispDir

// ============================================================
// CREATE NEW FVG OBJECTS
// ============================================================
if bullCondition
    fTop   = bullGapTop
    fBot   = bullGapBot
    fMid   = (fTop + fBot) / 2.0
    tStart = time[2]
    tEnd   = extendMode == "Fixed Bars" ? time + extendBars * msPerBar : time

    newBox = box.new(
         left         = tStart,
         top          = fTop,
         right        = tEnd,
         bottom       = fBot,
         xloc         = xloc.bar_time,
         extend       = f_boxExt(),
         bgcolor      = bullColor,
         border_color = color.new(#26a69a, 100),
         border_width = 1
         )

    newLine = showMidLine ? line.new(
         x1     = tStart,
         y1     = fMid,
         x2     = tEnd,
         y2     = fMid,
         xloc   = xloc.bar_time,
         extend = f_boxExt(),
         color  = midColor,
         style  = line.style_dashed,
         width  = 1
         ) : line(na)

    newFVG = FVG.new(fTop, fBot, fMid, tStart, true, false, newBox, newLine)
    bullFVGs.push(newFVG)

    if bullFVGs.size() > maxFVGs
        old = bullFVGs.shift()
        box.delete(old.fvgBox)
        line.delete(old.midLine)

if bearCondition
    fTop   = bearGapTop
    fBot   = bearGapBot
    fMid   = (fTop + fBot) / 2.0
    tStart = time[2]
    tEnd   = extendMode == "Fixed Bars" ? time + extendBars * msPerBar : time

    newBox = box.new(
         left         = tStart,
         top          = fTop,
         right        = tEnd,
         bottom       = fBot,
         xloc         = xloc.bar_time,
         extend       = f_boxExt(),
         bgcolor      = bearColor,
         border_color = color.new(#ef5350, 100),
         border_width = 1
         )

    newLine = showMidLine ? line.new(
         x1     = tStart,
         y1     = fMid,
         x2     = tEnd,
         y2     = fMid,
         xloc   = xloc.bar_time,
         extend = f_boxExt(),
         color  = midColor,
         style  = line.style_dashed,
         width  = 1
         ) : line(na)

    newFVG = FVG.new(fTop, fBot, fMid, tStart, false, false, newBox, newLine)
    bearFVGs.push(newFVG)

    if bearFVGs.size() > maxFVGs
        old = bearFVGs.shift()
        box.delete(old.fvgBox)
        line.delete(old.midLine)

// ============================================================
// MITIGATION CHECK
// ============================================================
bullMitigatedNow = false
if bullFVGs.size() > 0
    for i = bullFVGs.size() - 1 to 0
        if i < bullFVGs.size()
            fvg = bullFVGs.get(i)
            if not fvg.mitigated
                isMitigated = mitigMode == "Touch" ? close < fvg.mid : close < fvg.bottom
                if isMitigated
                    fvg.mitigated    := true
                    bullMitigatedNow := true
                    box.delete(fvg.fvgBox)
                    line.delete(fvg.midLine)
                    _ = bullFVGs.remove(i)

bearMitigatedNow = false
if bearFVGs.size() > 0
    for i = bearFVGs.size() - 1 to 0
        if i < bearFVGs.size()
            fvg = bearFVGs.get(i)
            if not fvg.mitigated
                isMitigated = mitigMode == "Touch" ? close > fvg.mid : close > fvg.top
                if isMitigated
                    fvg.mitigated    := true
                    bearMitigatedNow := true
                    box.delete(fvg.fvgBox)
                    line.delete(fvg.midLine)
                    _ = bearFVGs.remove(i)

// ============================================================
// ALERT CONDITIONS — global scope
// ============================================================
alertcondition(bullCondition,                  title="New Bullish FVG",       message="🟢 New Bullish Fair Value Gap detected on {{ticker}} ({{interval}})")
alertcondition(bearCondition,                  title="New Bearish FVG",       message="🔴 New Bearish Fair Value Gap detected on {{ticker}} ({{interval}})")
alertcondition(bullMitigatedNow,               title="Bullish FVG Mitigated", message="⚡ Bullish FVG mitigated on {{ticker}} ({{interval}}) — price entered the gap")
alertcondition(bearMitigatedNow,               title="Bearish FVG Mitigated", message="⚡ Bearish FVG mitigated on {{ticker}} ({{interval}}) — price entered the gap")
alertcondition(bullCondition or bearCondition, title="Any New FVG",           message="📊 New Fair Value Gap detected on {{ticker}} ({{interval}})")
````
