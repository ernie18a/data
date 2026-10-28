# Polo MTF OB & BB_V2

- url: https://www.tradingview.com/script/Xgo3niQx-Polo-MTF-OB-BB-V2/
- type: indicator
- pine_id: PUB;eccef672620444b4aa920411d7cc0009
- version: 1.0

## Description

Polo Multi-TF Order Blocks & Breaker Blocks

A clean multi-timeframe Order Block & Breaker Block indicator designed for traders who want structured Smart Money Concepts (SMC) zones without repainting issues.

This indicator detects Bullish and Bearish Order Blocks from locked higher timeframes and projects them directly onto lower timeframe charts for precise execution and market structure analysis.

Features

• Multi-Timeframe OB & BB Detection
 - Track up to 4 independent higher timeframes simultaneously
 - Example: M15 + M30 + H1 + H4

• Locked HTF Detection
 - Order Blocks are calculated from confirmed higher timeframe candles only
 - Prevents chart timeframe distortion and repaint behavior

• Bullish & Bearish Order Blocks
 - Automatically detects structure break and identifies valid OB zones

• Breaker Block Detection
 - Failed Order Blocks automatically convert into Breaker Blocks

• Fresh vs Un-Fresh Logic
 - OB M15 - F → Fresh / untouched Order Block
 - OB M15 - UF → Mitigated / revisited Order Block
 - BB H1 - F → Fresh Breaker Block
 - BB H1 - UF → Mitigated Breaker Block

• Multi-TF Label System
 - Clean readable labels directly on chart
 - Easy identification of timeframe and zone status

• Custom Styling
 - Separate controls for:
  - OB Fill
  - OB Border
  - Breaker Fill
  - Breaker Border
  - Text Colors

• Clean Visual Structure
 - Dotted Breaker extensions
 - Reduced visual clutter
 - Professional SMC style layout

• Fresh OB Filter
 - Option to display only Fresh / unmitigated zones

Best Usage

This indicator works especially well for:

• Scalping with HTF Bias
• Intraday Market Structure Trading
• Liquidity Sweeps + OB Entries
• Breaker Block Retests
• Smart Money Concepts (SMC) workflows
• Multi-timeframe confluence analysis

Recommended Setup

TF1 → M15
TF2 → M30
TF3 → H1
TF4 → H4

Use lower chart timeframes such as:
• M1
• M5
• M15

for refined entries inside HTF zones.

Notes

• Designed for non-repaint HTF structure logic
• Higher TF zones remain consistent even when changing chart timeframe
• For best performance, keep visible OB count between 1–3 per timeframe

Credits

Original Order Block & Breaker Block open-source concept by LuxAlgo.
This version has been heavily modified, rebuilt, and expanded into a multi-timeframe non-repaint structure system with Fresh / Un-Fresh tracking, multi-TF engines, and custom visualization improvements by Polo.

Built and customized by Polo.

## Source Code

````pine
//@version=5
indicator("Polo MTF OB & BB_V2", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
length        = input.int(10, "Swing Lookback", minval=3)
showBull      = input.int(2, "Show Last Bullish OB Per TF", minval=0)
showBear      = input.int(2, "Show Last Bearish OB Per TF", minval=0)
useBody       = input.bool(false, "Use Candle Body")
showFreshOnly = input.bool(false, "Only Show Fresh OB")
showOBLabels  = input.bool(true, "Show OB / BB Name Labels")

enableTF1 = input.bool(true, "Enable TF1", group="Multi TF")
tf1       = input.timeframe("15", "TF1 Lookup", group="Multi TF")

enableTF2 = input.bool(true, "Enable TF2", group="Multi TF")
tf2       = input.timeframe("30", "TF2 Lookup", group="Multi TF")

enableTF3 = input.bool(true, "Enable TF3", group="Multi TF")
tf3       = input.timeframe("60", "TF3 Lookup", group="Multi TF")

enableTF4 = input.bool(false, "Enable TF4", group="Multi TF")
tf4       = input.timeframe("240", "TF4 Lookup", group="Multi TF")


// Style
bullCss             = input.color(color.new(#2157f3, 80), "Bullish OB Fill", group="Style")
bullBorderCss       = input.color(#2157f3, "Bullish OB Border / Text", group="Style")
bullBreakCss        = input.color(color.new(#ff1100, 80), "Bullish OB → Breaker Fill", group="Style")
bullBreakBorderCss  = input.color(#ff1100, "Bullish OB → Breaker Border / Text", group="Style")

bearCss             = input.color(color.new(#ff5d00, 80), "Bearish OB Fill", group="Style")
bearBorderCss       = input.color(#ff5d00, "Bearish OB Border / Text", group="Style")
bearBreakCss        = input.color(color.new(#0cb51a, 80), "Bearish OB → Breaker Fill", group="Style")
bearBreakBorderCss  = input.color(#0cb51a, "Bearish OB → Breaker Border / Text", group="Style")


//--------------------------------------------------
// Types
//--------------------------------------------------
type ob
    float top
    float btm
    int   loc
    bool  breaker
    int   break_loc
    bool mitigated
    bool breakerMitigated

//--------------------------------------------------
// Functions
//--------------------------------------------------
method notransp(color css) =>
    color.rgb(color.r(css), color.g(css), color.b(css))

f_tfLabel(string tf) =>
    tf == "1" ? "M1" : tf == "3" ? "M3" : tf == "5" ? "M5" : tf == "15" ? "M15" : tf == "30" ? "M30" : tf == "45" ? "M45" : tf == "60" ? "H1" : tf == "120" ? "H2" : tf == "240" ? "H4" : tf == "D" ? "D1" : tf == "W" ? "W1" : tf

method display(ob id, color css, color break_css, color border_css, color break_border_css, string tfName, bool showLabel) =>
    labelText = id.breaker ? "BB " + tfName + (id.breakerMitigated ? " - UF" : " - F") : "OB " + tfName + (id.mitigated ? " - UF" : " - F")

    if id.breaker
        box.new(left=id.loc, top=id.top, right=id.break_loc, bottom=id.btm, border_color=border_css, bgcolor=css, xloc=xloc.bar_time)
        box.new(left=id.break_loc, top=id.top, right=time, bottom=id.btm, border_color=na, bgcolor=break_css, extend=extend.right, xloc=xloc.bar_time)
        line.new(x1=id.break_loc, y1=id.top, x2=time, y2=id.top, xloc=xloc.bar_time, extend=extend.right, color=break_border_css, style=line.style_dashed)
        line.new(x1=id.break_loc, y1=id.btm, x2=time, y2=id.btm, xloc=xloc.bar_time, extend=extend.right, color=break_border_css, style=line.style_dashed)
    else
        box.new(left=id.loc, top=id.top, right=time, bottom=id.btm, border_color=border_css, bgcolor=css, extend=extend.right, xloc=xloc.bar_time)
        line.new(x1=id.loc, y1=id.top, x2=time, y2=id.top, xloc=xloc.bar_time, extend=extend.right, color=border_css)
        line.new(x1=id.loc, y1=id.btm, x2=time, y2=id.btm, xloc=xloc.bar_time, extend=extend.right, color=border_css)
    

    if showLabel
        label.new(x=time, y=(id.top + id.btm) / 2, text=labelText, xloc=xloc.bar_time, style=label.style_label_left, textcolor=id.breaker ? break_border_css : border_css, color=color.new(color.black, 100), size=size.small)

f_get_float(float[] arr, int offset) =>
    array.get(arr, array.size(arr) - 1 - offset)

f_get_int(int[] arr, int offset) =>
    array.get(arr, array.size(arr) - 1 - offset)

f_highest_recent(float[] arrH, int len) =>
    float result = na
    for i = 0 to len - 1
        v = f_get_float(arrH, i)
        result := na(result) ? v : math.max(result, v)
    result

f_lowest_recent(float[] arrL, int len) =>
    float result = na
    for i = 0 to len - 1
        v = f_get_float(arrL, i)
        result := na(result) ? v : math.min(result, v)
    result

f_process(bool enabled, string tf, float[] arrO, float[] arrH, float[] arrL, float[] arrC, int[] arrT, ob[] bullish_ob, ob[] bearish_ob, float[] stF, int[] stI) =>
    [htfO, htfH, htfL, htfC, htfT] = request.security(syminfo.tickerid, tf, [open[1], high[1], low[1], close[1], time[1]], barmerge.gaps_off, barmerge.lookahead_off)
    newHTF = ta.change(htfT) != 0

    if enabled and newHTF and not na(htfT)
        array.push(arrO, htfO)
        array.push(arrH, htfH)
        array.push(arrL, htfL)
        array.push(arrC, htfC)
        array.push(arrT, htfT)

        if array.size(arrT) > length + 2
            htfIndex = array.size(arrT) - 1

            os = array.get(stI, 0)
            topX = array.get(stI, 1)
            topCrossed = array.get(stI, 2) == 1
            btmX = array.get(stI, 3)
            btmCrossed = array.get(stI, 4) == 1
            topY = array.get(stF, 0)
            btmY = array.get(stF, 1)

            upper = f_highest_recent(arrH, length)
            lower = f_lowest_recent(arrL, length)

            candidateHigh = f_get_float(arrH, length)
            candidateLow  = f_get_float(arrL, length)
            candidateX    = htfIndex - length

            prevOs = os
            os := candidateHigh > upper ? 0 : candidateLow < lower ? 1 : os

            if os == 0 and prevOs != 0
                topY := candidateHigh
                topX := candidateX
                topCrossed := false

            if os == 1 and prevOs != 1
                btmY := candidateLow
                btmX := candidateX
                btmCrossed := false

            if not na(topY) and htfC > topY and not topCrossed
                topCrossed := true

                float minima = useBody ? math.min(f_get_float(arrC, 1), f_get_float(arrO, 1)) : f_get_float(arrL, 1)
                float maxima = useBody ? math.max(f_get_float(arrC, 1), f_get_float(arrO, 1)) : f_get_float(arrH, 1)
                int loc = f_get_int(arrT, 1)

                barsFromSwing = htfIndex - topX

                if barsFromSwing > 1
                    for i = 1 to barsFromSwing - 1
                        thisMin = useBody ? math.min(f_get_float(arrC, i), f_get_float(arrO, i)) : f_get_float(arrL, i)
                        thisMax = useBody ? math.max(f_get_float(arrC, i), f_get_float(arrO, i)) : f_get_float(arrH, i)

                        if thisMin < minima
                            minima := thisMin
                            maxima := thisMax
                            loc := f_get_int(arrT, i)

                array.unshift(bullish_ob, ob.new(maxima, minima, loc, false, na, false, false))

            if not na(btmY) and htfC < btmY and not btmCrossed
                btmCrossed := true

                float minima = useBody ? math.min(f_get_float(arrC, 1), f_get_float(arrO, 1)) : f_get_float(arrL, 1)
                float maxima = useBody ? math.max(f_get_float(arrC, 1), f_get_float(arrO, 1)) : f_get_float(arrH, 1)
                int loc = f_get_int(arrT, 1)

                barsFromSwing = htfIndex - btmX

                if barsFromSwing > 1
                    for i = 1 to barsFromSwing - 1
                        thisMin = useBody ? math.min(f_get_float(arrC, i), f_get_float(arrO, i)) : f_get_float(arrL, i)
                        thisMax = useBody ? math.max(f_get_float(arrC, i), f_get_float(arrO, i)) : f_get_float(arrH, i)

                        if thisMax > maxima
                            maxima := thisMax
                            minima := thisMin
                            loc := f_get_int(arrT, i)

                array.unshift(bearish_ob, ob.new(maxima, minima, loc, false, na, false, false))

            if array.size(bullish_ob) > 0
                for i = array.size(bullish_ob) - 1 to 0
                    element = array.get(bullish_ob, i)

                    if not element.breaker
                        if htfT > element.loc and htfL <= element.top and htfH >= element.btm
                            element.mitigated := true

                        if math.min(htfC, htfO) < element.btm
                            element.breaker := true
                            element.break_loc := htfT

                        array.set(bullish_ob, i, element)
                    else
                        if htfT > element.break_loc and htfL <= element.top and htfH >= element.btm
                            element.breakerMitigated := true

                        if htfC > element.top
                            array.remove(bullish_ob, i)
                        else
                            array.set(bullish_ob, i, element)

            if array.size(bearish_ob) > 0
                for i = array.size(bearish_ob) - 1 to 0
                    element = array.get(bearish_ob, i)

                    if not element.breaker
                        if htfT > element.loc and htfH >= element.btm and htfL <= element.top
                            element.mitigated := true

                        if math.max(htfC, htfO) > element.top
                            element.breaker := true
                            element.break_loc := htfT

                        array.set(bearish_ob, i, element)
                    else
                        if htfT > element.break_loc and htfH >= element.btm and htfL <= element.top
                            element.breakerMitigated := true

                        if htfC < element.btm
                            array.remove(bearish_ob, i)
                        else
                            array.set(bearish_ob, i, element)

            array.set(stI, 0, os)
            array.set(stI, 1, topX)
            array.set(stI, 2, topCrossed ? 1 : 0)
            array.set(stI, 3, btmX)
            array.set(stI, 4, btmCrossed ? 1 : 0)
            array.set(stF, 0, topY)
            array.set(stF, 1, btmY)

f_draw(ob[] bullArr, ob[] bearArr, string tf) =>
    tfName = f_tfLabel(tf)

    if showBull > 0 and array.size(bullArr) > 0
        bullCount = math.min(showBull, array.size(bullArr))
        for i = 0 to bullCount - 1
            getOb = array.get(bullArr, i)
            if getOb.breaker or not showFreshOnly or not getOb.mitigated
                getOb.display(bullCss, bullBreakCss, bullBorderCss, bullBreakBorderCss, tfName, showOBLabels)

    if showBear > 0 and array.size(bearArr) > 0
        bearCount = math.min(showBear, array.size(bearArr))
        for i = 0 to bearCount - 1
            getOb = array.get(bearArr, i)
            if getOb.breaker or not showFreshOnly or not getOb.mitigated
                getOb.display(bearCss, bearBreakCss, bearBorderCss, bearBreakBorderCss, tfName, showOBLabels)

//--------------------------------------------------
// TF Storage
//--------------------------------------------------
var arrO1 = array.new_float(), var arrH1 = array.new_float(), var arrL1 = array.new_float(), var arrC1 = array.new_float(), var arrT1 = array.new_int()
var arrO2 = array.new_float(), var arrH2 = array.new_float(), var arrL2 = array.new_float(), var arrC2 = array.new_float(), var arrT2 = array.new_int()
var arrO3 = array.new_float(), var arrH3 = array.new_float(), var arrL3 = array.new_float(), var arrC3 = array.new_float(), var arrT3 = array.new_int()
var arrO4 = array.new_float(), var arrH4 = array.new_float(), var arrL4 = array.new_float(), var arrC4 = array.new_float(), var arrT4 = array.new_int()

var bullish_ob_1 = array.new<ob>(), var bearish_ob_1 = array.new<ob>()
var bullish_ob_2 = array.new<ob>(), var bearish_ob_2 = array.new<ob>()
var bullish_ob_3 = array.new<ob>(), var bearish_ob_3 = array.new<ob>()
var bullish_ob_4 = array.new<ob>(), var bearish_ob_4 = array.new<ob>()

var stF1 = array.from(na, na), var stI1 = array.from(0, -1, 0, -1, 0)
var stF2 = array.from(na, na), var stI2 = array.from(0, -1, 0, -1, 0)
var stF3 = array.from(na, na), var stI3 = array.from(0, -1, 0, -1, 0)
var stF4 = array.from(na, na), var stI4 = array.from(0, -1, 0, -1, 0)

//--------------------------------------------------
// Run Engines
//--------------------------------------------------
f_process(enableTF1, tf1, arrO1, arrH1, arrL1, arrC1, arrT1, bullish_ob_1, bearish_ob_1, stF1, stI1)
f_process(enableTF2, tf2, arrO2, arrH2, arrL2, arrC2, arrT2, bullish_ob_2, bearish_ob_2, stF2, stI2)
f_process(enableTF3, tf3, arrO3, arrH3, arrL3, arrC3, arrT3, bullish_ob_3, bearish_ob_3, stF3, stI3)
f_process(enableTF4, tf4, arrO4, arrH4, arrL4, arrC4, arrT4, bullish_ob_4, bearish_ob_4, stF4, stI4)

//--------------------------------------------------
// Draw
//--------------------------------------------------
for bx in box.all
    bx.delete()

for ln in line.all
    ln.delete()

for lb in label.all
    lb.delete()

if barstate.islast
    if enableTF1
        f_draw(bullish_ob_1, bearish_ob_1, tf1)

    if enableTF2
        f_draw(bullish_ob_2, bearish_ob_2, tf2)

    if enableTF3
        f_draw(bullish_ob_3, bearish_ob_3, tf3)

    if enableTF4
        f_draw(bullish_ob_4, bearish_ob_4, tf4)
````
