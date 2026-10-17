# Equal Highs and Lows [D4A]

- url: https://www.tradingview.com/script/gyTQb5sr-Equal-Highs-and-Lows-D4A/
- type: indicator
- pine_id: PUB;10147ef695ee47ae9e758180e97a2c67
- version: 1.0

## Description

[b]Overview[/b]

This indicator identifies and displays **Relative Equal High (EQH)** and **Equal Low (EQL)** zones, highlighting price levels where the market has stalled or reversed from before. These areas are considered liquidity zones because they mark locations where price has previously paused, reversed, or encountered significant buying or selling activity, and as a result there is a concentration of buy-stops or sell-stops in these zones. In trading approaches such as Smart Money Concepts (SMC/ICT), equal highs and lows are considered important liquidity targets that may influence future market movement, as larger participants are thought to seek the liquidity concentrated around these levels.

[b]How this script is different from other similar tools[/b]
- It marks two pivots as Equal Highs only if the second pivot is lower (within the threshold) than the 1st one and likewise, two pivots are marked as Equal Lows only if the second pivot is situated higher (within the threshold) than the 1st pivot. In other words the price has still a reason to re-visit this area
- It provides three different, user configurable pivot lengths that the script scans at the same type in search of EQHL. Most scripts use only one pivot length thus missing on many potential targets
- Apart from main labels, it draws also side labels at defined location which can be convenient to see all EQHL target levels at glance

[b]How It Works[/b]
The indicator analyses **pivot highs** and **pivot lows** to locate meaningful swing points on the chart. When two consecutive pivots form within a user-defined price threshold, they are recognized as an Equal Highs or Equal Lows. A line is then drawn between the matching pivots, and the zone is labelled for easy identification.

Since market prices rarely align at exactly the same value, the indicator includes a **ATR Threshold** setting. This parameter specifies the maximum percentage difference allowed between two pivot levels for them to qualify as equal, giving traders the flexibility to adjust the detection based on market volatility and their preferred level of precision.

[b]How to Use[/b]
(EQH/EQL) are strong liquidity targets: Use the marked levels as potential targets for take-profits, as price often seeks out these "equal" levels to sweep liquidity.

[b]SETTINGS[/b]
- Show EQHL - show labels and drawings
- # of bars to use - limits the number of bars used to find EQHL
- Threshold / ATR Length - are used to establish difference between two levels being considered "equal high" or "equal low"
- Show Labels - define labels shown
- Show Side Labels - enables additional labels on the side of the chart
- Right Coordinate - how many bars to the right the side labels are displayed at
- Pivot Length - there are three different lengths to configure to cover large distance difference between two pivots
- Remove All Drawings After Sweep - when EQH or EQL levels are swept, the corresponding drawings are removed from memory

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator('Equal Highs & Lows', shorttitle = 'EQHLT', overlay = true)

var g_EQHL = "Relative Equal Highs / Lows"
show_eqhl         = input.bool(true, 'Show EQHL    ', inline = 'eqhl1', group = g_EQHL)
liq_count         = input.int(1000, '# of bars to use', inline = 'eqhl1', group = g_EQHL)
threshold         = input.float(0.4, 'Threshold', minval = 0, maxval = 1, step = 0.1, inline = 'eqhl2', group = g_EQHL)
confluenceAtrLength = input.int(100, '    ATR Length', minval = 1, inline = 'eqhl2', group = g_EQHL, tooltip = "ATR is used for threshold calculation")
lb_strH           = input.string("EQH", "Show Labels  ", inline = "label1", group = g_EQHL)
lb_strL           = input.string("EQL", "", inline = "label1", group = g_EQHL)
side_label        = input.bool(true,  'Show Side Labels    ', inline = "label2", group = g_EQHL)
overlap            = input.int(14, 'Right Coordinate', minval = 1, inline = 'label2', group = g_EQHL)

show1      = input.bool(true,'',  inline = 's1', group = g_EQHL)
pivotLen1  = input.int(2,'Pivot Length',  inline = 's1', group = g_EQHL, minval = 1)
bull_c1    = input.color(color.rgb(0,255,0,0),  '',         group = g_EQHL, inline = 's1')
bear_c1    = input.color(color.rgb(255,0,0,0),  '',              group = g_EQHL, inline = 's1')
style1     = input.string(line.style_dotted,    '',              group = g_EQHL, inline = 's1', options = [line.style_dashed, line.style_dotted, line.style_solid])

show2      = input.bool(true,'', inline = 's2', group = g_EQHL)
pivotLen2  = input.int(5,'Pivot Length', inline = 's2', group = g_EQHL, minval = 1)
bull_c2    = input.color(color.rgb(0,200,255,0),  '', group = g_EQHL, inline = 's2')
bear_c2    = input.color(color.rgb(255,165,0,0),  '', group = g_EQHL, inline = 's2')
style2     = input.string(line.style_dotted, '', group = g_EQHL, inline = 's2', options = [line.style_dashed, line.style_dotted, line.style_solid])

show3      = input.bool(true, '', inline = 's3', group = g_EQHL)
pivotLen3  = input.int(12, 'Pivot Length', inline = 's3', group = g_EQHL, minval = 1)
bull_c3    = input.color(color.rgb(50,100,255,0),  '', group = g_EQHL, inline = 's3')
bear_c3    = input.color(color.rgb(255,0,255,0),  '', group = g_EQHL, inline = 's3')
style3     = input.string(line.style_dotted, '', group = g_EQHL, inline = 's3', options = [line.style_dashed, line.style_dotted, line.style_solid])

sweeped           = input.bool(true,  'Remove All Drawings After Sweep', group = g_EQHL)

mode_switch = last_bar_index - bar_index <= liq_count
atr         = ta.atr(confluenceAtrLength)

// Pivots
phigh1 = ta.pivothigh(pivotLen1, pivotLen1)
plow1  = ta.pivotlow(pivotLen1,  pivotLen1)
phigh2 = ta.pivothigh(pivotLen2, pivotLen2)
plow2  = ta.pivotlow(pivotLen2,  pivotLen2)
phigh3 = ta.pivothigh(pivotLen3, pivotLen3)
plow3  = ta.pivotlow(pivotLen3,  pivotLen3)

// ARRAYS — one per set
var float[] highs1 = array.new_float(0),  var int[] highsBarIdx1 = array.new_int(0)
var line[]  highsL1 = array.new<line>(0), var label[] highsLbl1  = array.new<label>(0), var label[] highsLbl1b = array.new<label>(0)
var float[] lows1  = array.new_float(0),  var int[]  lowsBarIdx1 = array.new_int(0)
var line[]  lowsL1  = array.new<line>(0), var label[] lowsLbl1   = array.new<label>(0), var label[] lowsLbl1b  = array.new<label>(0)

var float[] highs2 = array.new_float(0),  var int[] highsBarIdx2 = array.new_int(0)
var line[]  highsL2 = array.new<line>(0), var label[] highsLbl2  = array.new<label>(0), var label[] highsLbl2b = array.new<label>(0)
var float[] lows2  = array.new_float(0),  var int[]  lowsBarIdx2 = array.new_int(0)
var line[]  lowsL2  = array.new<line>(0), var label[] lowsLbl2   = array.new<label>(0), var label[] lowsLbl2b  = array.new<label>(0)

var float[] highs3 = array.new_float(0),  var int[] highsBarIdx3 = array.new_int(0)
var line[]  highsL3 = array.new<line>(0), var label[] highsLbl3  = array.new<label>(0), var label[] highsLbl3b = array.new<label>(0)
var float[] lows3  = array.new_float(0),  var int[]  lowsBarIdx3 = array.new_int(0)
var line[]  lowsL3  = array.new<line>(0), var label[] lowsLbl3   = array.new<label>(0), var label[] lowsLbl3b  = array.new<label>(0)

cleanupOverlaps(float[] prices, int[] barIdxArr, line[] lines, label[] labels, label[] labels2, float newPrice, int newBarIdx, float atrVal, float thresh) =>
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            idx           = array.size(prices) - 1 - i
            existingPrice = array.get(prices, idx)
            existingBar   = array.get(barIdxArr, idx)
            priceClose    = math.abs(existingPrice - newPrice) <= atrVal * thresh
            barClose      = math.abs(existingBar - newBarIdx) <= 500
            if priceClose and barClose
                line.delete(array.get(lines,   idx))
                label.delete(array.get(labels,  idx))
                label.delete(array.get(labels2, idx))
                array.remove(prices,    idx)
                array.remove(barIdxArr, idx)
                array.remove(lines,     idx)
                array.remove(labels,    idx)
                array.remove(labels2,   idx)

drawAndStore(float[] prices, int[] barIdxArr, line[] lines, label[] labels, label[] labels2,
             int fromBar, float fromPrice, int toBar, float toPrice,
             color clr, string styl, string lbl, bool isHigh) =>
    ln    = line.new(fromBar, fromPrice, toBar, toPrice, color = clr, style = styl)
    lbPos = isHigh ? label.style_label_down : label.style_label_up
    lb    = label.new(int(math.avg(toBar, fromBar)), toPrice, lbl, color = #00000000, textcolor = clr, style = lbPos, size = size.small)
    lb2   = side_label ? label.new(bar_index, toPrice, lbl, color = #00000000, textcolor = clr, style = lbPos, size = size.small) : na
    array.push(prices,    toPrice)
    array.push(barIdxArr, toBar)
    array.push(lines,     ln)
    array.push(labels,    lb)
    array.push(labels2,   lb2)

processSweep(float[] prices, int[] barIdxArr, line[] lines, label[] labels, label[] labels2, bool isHigh) =>
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            idx   = array.size(prices) - 1 - i
            level = array.get(prices, idx)
            swept = isHigh ? high > level : low < level
            if swept
                line.delete(array.get(lines,   idx))
                label.delete(array.get(labels,  idx))
                label.delete(array.get(labels2, idx))
                array.remove(prices,    idx)
                array.remove(barIdxArr, idx)
                array.remove(lines,     idx)
                array.remove(labels,    idx)
                array.remove(labels2,   idx)

updateRightLabels(label[] labels2) =>
    if array.size(labels2) > 0 and show_eqhl
        for i = 0 to array.size(labels2) - 1
            label.set_x(array.get(labels2, i), bar_index + overlap)

// SET 1 LOGIC
var float prevHigh1 = 0.0, var int highX1 = 0
var float prevLow1  = 0.0, var int lowX1  = 0

if bool(phigh1) and mode_switch and show_eqhl
    hi_max = math.max(phigh1, prevHigh1)
    hi_min = math.min(phigh1, prevHigh1)
    if hi_max < hi_min + atr * threshold and hi_max <= prevHigh1 and prevHigh1 != 0 and show1
        drawAndStore(highs1, highsBarIdx1, highsL1, highsLbl1, highsLbl1b, highX1, prevHigh1, bar_index - pivotLen1, phigh1, bear_c1, style1, lb_strH, true)
    prevHigh1 := phigh1
    highX1    := bar_index - pivotLen1

if bool(plow1) and mode_switch and show_eqhl
    lo_max = math.max(plow1, prevLow1)
    lo_min = math.min(plow1, prevLow1)
    if lo_min > lo_max - atr * threshold and lo_min >= prevLow1 and prevLow1 != 0 and show1
        drawAndStore(lows1, lowsBarIdx1, lowsL1, lowsLbl1, lowsLbl1b, lowX1, prevLow1, bar_index - pivotLen1, plow1, bull_c1, style1, lb_strL, false)
    prevLow1 := plow1
    lowX1    := bar_index - pivotLen1

// SET 2 LOGIC
var float prevHigh2 = 0.0, var int highX2 = 0
var float prevLow2  = 0.0, var int lowX2  = 0

if bool(phigh2) and mode_switch and show_eqhl
    hi_max = math.max(phigh2, prevHigh2)
    hi_min = math.min(phigh2, prevHigh2)
    if hi_max < hi_min + atr * threshold and hi_max <= prevHigh2 and prevHigh2 != 0
        if show2
            cleanupOverlaps(highs1, highsBarIdx1, highsL1, highsLbl1, highsLbl1b, phigh2, bar_index - pivotLen2, atr, threshold)
            drawAndStore(highs2, highsBarIdx2, highsL2, highsLbl2, highsLbl2b, highX2, prevHigh2, bar_index - pivotLen2, phigh2, bear_c2, style2, lb_strH, true)
    prevHigh2 := phigh2
    highX2    := bar_index - pivotLen2

if bool(plow2) and mode_switch and show_eqhl
    lo_max = math.max(plow2, prevLow2)
    lo_min = math.min(plow2, prevLow2)
    if lo_min > lo_max - atr * threshold and lo_min >= prevLow2 and prevLow2 != 0
        if show2
            cleanupOverlaps(lows1,  lowsBarIdx1,  lowsL1,  lowsLbl1,  lowsLbl1b,  plow2,  bar_index - pivotLen2, atr, threshold)
            drawAndStore(lows2, lowsBarIdx2, lowsL2, lowsLbl2, lowsLbl2b, lowX2, prevLow2, bar_index - pivotLen2, plow2, bull_c2, style2, lb_strL, false)
    prevLow2 := plow2
    lowX2    := bar_index - pivotLen2

// SET 3 LOGIC
var float prevHigh3 = 0.0, var int highX3 = 0
var float prevLow3  = 0.0, var int lowX3  = 0

if bool(phigh3) and mode_switch and show_eqhl
    hi_max = math.max(phigh3, prevHigh3)
    hi_min = math.min(phigh3, prevHigh3)
    if hi_max < hi_min + atr * threshold and hi_max <= prevHigh3 and prevHigh3 != 0
        if show3
            cleanupOverlaps(highs1, highsBarIdx1, highsL1, highsLbl1, highsLbl1b, phigh3, bar_index - pivotLen3, atr, threshold)
            cleanupOverlaps(highs2, highsBarIdx2, highsL2, highsLbl2, highsLbl2b, phigh3, bar_index - pivotLen3, atr, threshold)
            drawAndStore(highs3, highsBarIdx3, highsL3, highsLbl3, highsLbl3b, highX3, prevHigh3, bar_index - pivotLen3, phigh3, bear_c3, style3, lb_strH, true)
    prevHigh3 := phigh3
    highX3    := bar_index - pivotLen3

if bool(plow3) and mode_switch and show_eqhl
    lo_max = math.max(plow3, prevLow3)
    lo_min = math.min(plow3, prevLow3)
    if lo_min > lo_max - atr * threshold and lo_min >= prevLow3 and prevLow3 != 0
        if show3
            cleanupOverlaps(lows1,  lowsBarIdx1,  lowsL1,  lowsLbl1,  lowsLbl1b,  plow3,  bar_index - pivotLen3, atr, threshold)
            cleanupOverlaps(lows2,  lowsBarIdx2,  lowsL2,  lowsLbl2,  lowsLbl2b,  plow3,  bar_index - pivotLen3, atr, threshold)
            drawAndStore(lows3, lowsBarIdx3, lowsL3, lowsLbl3, lowsLbl3b, lowX3, prevLow3, bar_index - pivotLen3, plow3, bull_c3, style3, lb_strL, false)
    prevLow3 := plow3
    lowX3    := bar_index - pivotLen3

updateRightLabels(highsLbl1b), updateRightLabels(lowsLbl1b), updateRightLabels(highsLbl2b), updateRightLabels(lowsLbl2b), updateRightLabels(highsLbl3b), updateRightLabels(lowsLbl3b)

if sweeped and show_eqhl
    processSweep(highs1, highsBarIdx1, highsL1, highsLbl1, highsLbl1b, true)
    processSweep(lows1,  lowsBarIdx1,  lowsL1,  lowsLbl1,  lowsLbl1b,  false)
    processSweep(highs2, highsBarIdx2, highsL2, highsLbl2, highsLbl2b, true)
    processSweep(lows2,  lowsBarIdx2,  lowsL2,  lowsLbl2,  lowsLbl2b,  false)
    processSweep(highs3, highsBarIdx3, highsL3, highsLbl3, highsLbl3b, true)
    processSweep(lows3,  lowsBarIdx3,  lowsL3,  lowsLbl3,  lowsLbl3b,  false)
````
