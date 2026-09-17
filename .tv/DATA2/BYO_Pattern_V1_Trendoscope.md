<!-- tradingview-pine-id: PUB;a42f5e6576b24daca2f057ee1a653adb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BYO Pattern V1 [Trendoscope®]

Source: https://www.tradingview.com/script/e2S2v4fl-BYO-Pattern-V1-Trendoscope/

## Description

🎲 Overview

BYO Pattern V1 (Build Your Own Pattern) is a highly flexible open-source indicator that empowers traders to design, define, and automatically detect custom geometric patterns based on Fibonacci ratios between zigzag pivots.

Unlike traditional harmonic or chart pattern indicators that come with fixed, pre-defined rules, this tool puts the power of pattern creation entirely in your hands. You choose the number of pivots (5 or 6), enable the specific ratio conditions you care about, set exact values or ranges, and the indicator scans the chart in real time for matching structures.

Default configuration is set to the classic Three Drives pattern, but you can reconfigure it in seconds to detect almost any ratio-based pattern — including custom variations of ABCD, Gartley-style structures, Three Drives, 5-0, or completely original patterns of your own invention.

🎲 Core Concept

The indicator works on the principle that many powerful reversal and continuation patterns can be described as a sequence of alternating pivots (X-A-B-C-D or X-A-B-C-D-E) whose price legs satisfy specific Fibonacci retracement or extension relationships.

You define those relationships. The script does the heavy lifting:

[*]Builds a zigzag of the required depth
[*]Extracts the most recent 5 or 6 pivots
[*]Calculates the relevant Fibonacci ratios between those pivots
[*]Validates them against your enabled ratio rules (with optional tolerance)
[*]Draws the valid pattern with labels, ratio annotations, and a Potential Reversal Zone (PRZ)

This approach is especially useful for traders who want to:

[*]Test proprietary ratio combinations
[*]Adapt classical patterns to different markets or timeframes
[*]Explore less common structures that commercial indicators ignore
[*]Create rules-based patterns for systematic trading or research

🎲 Supported Pattern Structures

[*]5-Pivot Patterns (X-A-B-C-D) - Classic XABCD-style and many harmonic variations.
[*]6-Pivot Patterns (X-A-B-C-D-E) - Three Drives and more complex multi-leg structures.

🎲 Available Ratio Conditions
You can independently enable and configure the following ratios:

[*]XAB - Retracement of XA by AB
[*]ABC - Retracement of AB by BC
[*]BCD - Retracement of BC by CD
[*]CDE - Retracement of CD by DE (6 pivots only)
[*]XAD - Retracement of XA by AD
[*]XCD - Retracement of XC by CD
[*]ABE - Retracement of AB by BE (6 pivots only)
[*]ADE - Retracement of AD by DE (6 pivots only)

Each ratio can be set as:

[*]An exact value (the Error Percent setting expands it into a tolerance band)
[*]A range (Start Value → End Value)

At least one terminal ratio must be enabled depending on the pivot count (validation is enforced at runtime). For example,

[*]5 pivot pattern should at least have one of the ratio enabled among BCD, XAD or XCD.
[*]6 pivot pattern should at least have one of the ratio enabled among CDE, ABE and ADE

🎲 Key Features

[*]Fully Customizable Pattern Definition — Name, pivot count, and all ratio rules
[*]Error Tolerance — Built-in percentage tolerance for practical real-world matching
[*]Log Scale Support — Calculate ratios on logarithmic scale when needed
[*]Automatic Pattern Drawing - draws patterns with labelling of pivots and ratios
[*]Potential Reversal Zone (PRZ) — Automatically calculated and displayed as a shaded box based on the active terminal ratios
[*]Color Theme Support — Dark / Light theme with automatic color cycling so multiple patterns remain distinguishable
[*]Duplicate Filtering — Prevents redrawing identical pivot sets
[*]Summary Table — Live table showing pattern name, pivot count, active ratio ranges, and total patterns identified
[*]Real-time or Confirmed Bars — Option to include or exclude forming bars

🎲 How Detection Works

[*]A zigzag is calculated using the user-defined length.
[*]When a new pivot is confirmed (and enough pivots exist), the script extracts the latest 5 or 6 points.
[*]All relevant Fibonacci ratios are calculated.
[*]Each enabled ratio is validated against its defined range (or exact value ± error percent).
[*]If all enabled ratios pass validation and the pattern is not a duplicate of an already drawn one, it is accepted.
[*]The pattern is drawn with the next available theme color, labels, ratio annotations, and PRZ (if applicable).

🎲 Settings Guide

🎯 Zigzag Group

[*]Length — Controls the sensitivity of the underlying zigzag (higher = fewer, more significant pivots)
[*]Depth - Depth of zigzag level 1 to be considered for recursive zigzag calculation. Higher depth will result in more recursive levels and hence will scan higher number of patterns. However, this will also slow down the algorithm and can lead to runtime errors
[*]Use Real Time Bars — Include the current forming bar in calculations

https://www.tradingview.com/x/iy6hl0Qh/
🎯 Pattern Group

[*]Title — Custom name that appears in the summary table and can help you identify different configurations
[*]Number of Pivots — Choose 5 or 6
[*]Error Percent — Tolerance applied when a ratio is set as an exact value
[*]Log Scale — Use logarithmic price differences for ratio calculations

https://www.tradingview.com/x/sBz4Ztx5/
🎯 Ratios Group

[*]Individual enable toggles + Start/End value inputs for every supported ratio
[*]Only the ratios you enable are checked
[*]CBE, ABE, and ADE ratios are only available for 6 pivot patterns

https://www.tradingview.com/x/OJcqiPlN/
🎯 Display Group

[*]Theme (Dark / Light)
[*]Show / Hide Pivot Labels
[*]Show / Hide Ratio Labels
[*]Show / Hide Summary Table

https://www.tradingview.com/x/c086MldU/
🎲 Example Use Cases

[*]Load the default Three Drives configuration and study how frequently it appears on your instruments
[*]Recreate a classical ABCD pattern by setting 5 pivots and enabling XAB + ABC + BCD with the classic ratios
[*]Design a proprietary 6-leg structure and backtest its appearance across multiple symbols
[*]Use tight error percentages for high-precision setups or wider ranges for more frequent signals

https://www.tradingview.com/x/RcX1Ed8I/
You can also try out some other simple harmonic patterns. There are lots of educational ideas published in tradingview about harmonic ratios. One such example is [Advanced Harmonic Pattern Ratios](https://www.tradingview.com/chart/BTCUSD/qcXlS1MQ-Advanced-Harmonic-Pattern-Ratios/) by [cmjohnson36](https://www.tradingview.com/u/cmjohnson36/)

However, the real power of this indicator is that you can build your own set of ratio combinations and come up with new patterns.

🎲 Important Notes

[*]This is a detection and visualization tool. It does not generate buy/sell signals or manage trades.
[*]Pattern quality still depends on the quality of the underlying zigzag. Experiment with different Length values.
[*]For 6-pivot patterns, at least one of CDE / ABE / ADE must be enabled.
[*]For 5-pivot patterns, at least one of BCD / XAD / XCD must be enabled.

Your Patterns. Your Rules. Design it. Detect it. Trade it.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd, Trendoscope®
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒                        
//@version=6
indicator("BYO Pattern V1 [Trendoscope®]", "BYOPv1.0[Trendoscope®]", true)
import Trendoscope/Zigzag/11 as zg
import Trendoscope/utils/1 as ut
import Trendoscope/FibRatios/1 as fibs

type Ratio
    string ratioTitle
    bool enable
    float startValue
    float endValue

type Scanner
    string patternName
    int numberOfPivots
    float errorPercent
    bool logScale
    array<Ratio> ratios
    bool displayPivotLabels
    bool displayRatioLabels

type DrawingProperties
    color lineColor = color.blue
    color textColor = color.blue
    int lineWidth = 1
    bool showPivotLabels = true
    bool showRatioLabels = true
    string xloc = xloc.bar_time
    bool force_overlay = false

type Pattern
    int id
    Scanner scanner
    array<chart.point> pivots
    array<float> ratios
    polyline pLine
    array<label> pivotLabels
    box prz
    array<line> ratioLines
    array<label> ratioLabels
    DrawingProperties drawingProperties
    bool hasPrz = false
    bool valid = false

zigzagLength = input.int(5, step = 5, minval = 1, title = 'Length', group = 'Zigzag', 
            tooltip = 'Zigzag length for level 0 zigzag', display = display.none)
depth = input.int(50, 'Depth', step = 25, minval=25, maxval = 500, group = 'Zigzag', 
            tooltip = 'Zigzag depth refers to max number of pivots to be considered for level 0 zigzag.' + 
            ' This number will also impact the recursive calculation of zigzags and number of patterns scanned.'+
            ' Higher depth will slow down the alogirthm and may even lead to runtime error. Lower depth will reduce the number of patterns scanned', 
            display = display.none)
useRealTimeBars = input.bool(true, 'Use Real Time Bars', group = 'Zigzag', 
            tooltip = 'If enabled real time bars are used for calculation. Otherwise, only confirmed bars are used', 
            display = display.none)

patternName = input.string("Three Drives", "Title", tooltip = "Pattern Title/Name", group='Pattern', display = display.none)
numberOfPivots = input.int(6, "Number of Pivots", [5, 6], tooltip = "Number of pivots in the pattern", group='Pattern', display = display.none)
errorPercent = input.float(20, 'Error Percent', tooltip = 'Error threshold to be used when ratios are absolute and not in range.', group='Pattern', display = display.none)
logScale = input.bool(false, 'Log Scale', 'Use log scale for calculation of ratios', group='Pattern', display = display.none)
// depth = numberOfPivots
enableXabRatio = input.bool(true, "XAB", inline='xab', group='Ratios', display = display.none, 
                    tooltip = 'Ratio of XAB Leg. Applicable for both 5 and 6 pivot patterns')
xabRatio = Ratio.new(
                "XAB",
                enableXabRatio,
                input.float(0.618, '', inline='xab', group = 'Ratios', active=enableXabRatio, display = display.none),
                input.float(0.618, '', inline='xab', group = 'Ratios', active=enableXabRatio, display = display.none)
            )

enableAbcRatio = input.bool(true, "ABC", inline='abc', group='Ratios', display = display.none, 
                    tooltip = 'Ratio of ABC Leg. Applicable for both 5 and 6 pivot patterns')
abcRatio = Ratio.new(
                "ABC",
                enableAbcRatio,
                input.float(1.272, '', inline='abc', group = 'Ratios', active=enableAbcRatio, display = display.none),
                input.float(1.272, '', inline='abc', group = 'Ratios', active=enableAbcRatio, display = display.none)
            )

enableBcdRatio = input.bool(true, "BCD", inline='bcd', group='Ratios', display = display.none, 
                    tooltip = 'Ratio of BCD Leg. Applicable for both 5 and 6 pivot patterns')
bcdRatio = Ratio.new(
                "BCD",
                enableBcdRatio,
                input.float(0.618, '', inline='bcd', group = 'Ratios', active=enableBcdRatio, display = display.none),
                input.float(0.618, '', inline='bcd', group = 'Ratios', active=enableBcdRatio, display = display.none)
            )

enableCdeRatio = numberOfPivots == 6? input.bool(true, "CDE", inline='cde', group='Ratios', display = display.none, 
                    active = numberOfPivots == 6,
                    tooltip = 'Ratio of CDE Leg. Applicable only for 6 pivot patterns') : false
cdeRatio = Ratio.new(
                "CDE",
                enableCdeRatio,
                input.float(1.272, '', inline='cde', group = 'Ratios', active=enableCdeRatio, display = display.none),
                input.float(1.272, '', inline='cde', group = 'Ratios', active=enableCdeRatio, display = display.none)
            )

enableXadRatio = input.bool(false, "XAD", inline='xad', group='Ratios', display = display.none, 
                    tooltip = 'Ratio of XAD Leg. Applicable for both 5 and 6 pivot patterns')
xadRatio = Ratio.new(
                "XAD",
                enableXadRatio,
                input.float(0.382, '', inline='xad', group = 'Ratios', active=enableXadRatio, display = display.none),
                input.float(0.618, '', inline='xad', group = 'Ratios', active=enableXadRatio, display = display.none)
            )

enableXcdRatio = input.bool(false, "XCD", inline='xcd', group='Ratios', display = display.none, 
                    tooltip = 'Ratio of XCD Leg. Applicable for both 5 and 6 pivot patterns')
xcdRatio = Ratio.new(
                "XCD",
                enableXcdRatio,
                input.float(0.382, '', inline='xcd', group = 'Ratios', active=enableXcdRatio, display = display.none),
                input.float(1.000, '', inline='xcd', group = 'Ratios', active=enableXcdRatio, display = display.none)
            )

enableAbeRatio = numberOfPivots == 6? input.bool(false, "ABE", inline='abe', group='Ratios', display = display.none, 
                    active = numberOfPivots == 6,
                    tooltip = 'Ratio of ABE Leg. Applicable only for 6 pivot patterns') : false
abeRatio = Ratio.new(
                "ABE",
                enableAbeRatio,
                input.float(1.000, '', inline='abe', group = 'Ratios', active=enableAbeRatio, display = display.none),
                input.float(2.618, '', inline='abe', group = 'Ratios', active=enableAbeRatio, display = display.none)
            )

enableAdeRatio = numberOfPivots == 6? input.bool(false, "ADE", inline='ade', group='Ratios', display = display.none, 
                    active = numberOfPivots == 6,
                    tooltip = 'Ratio of CDE Leg. Applicable only for 6 pivot patterns') : false
adeRatio = Ratio.new(
                "ADE",
                enableAdeRatio,
                input.float(1.000, '', inline='ade', group = 'Ratios', active=enableAdeRatio, display = display.none),
                input.float(2.618, '', inline='ade', group = 'Ratios', active=enableAdeRatio, display = display.none)
            )

theme = input.enum(ut.Theme.DARK, title = 'Theme', group = 'Display', 
            tooltip = 'Chart theme settings. Line and label colors are generted based on the theme settings. If dark theme is selected, ' + 
            'lighter colors are used and if light theme is selected, darker colors are used.', display = display.none, inline='t')
showPivotLabels = input.bool(true, 'Pivot Labels', 'Display XABCD(E) pivot labels', group='Display', display = display.none)
showRatioLabels = input.bool(true, 'Ratio Labels', 'Display ratio values and the labels', group='Display', display = display.none)
showSummaryTable = input.bool(true, 'Summary', 'Display summary table', group='Display', display = display.none)

if( numberOfPivots == 6 and not (cdeRatio.enable or abeRatio.enable or adeRatio.enable))
    runtime.error('For 6 Pivot pattern, at least one among CDE, ABE, ADE Ratios must be enabled')

if( numberOfPivots == 5 and not (bcdRatio.enable or xadRatio.enable or xcdRatio.enable))
    runtime.error('For 5 Pivot pattern, at least one among BCD, XAD, XCD Ratios must be enabled')

var themeColors = theme.getColors()
offset = useRealTimeBars ? 0 : 1
var array<Pattern> patterns = array.new<Pattern>()

Scanner scanner = Scanner.new(patternName, numberOfPivots, errorPercent, logScale, 
            array.from(xabRatio, abcRatio, bcdRatio, cdeRatio, xadRatio, xcdRatio, abeRatio, adeRatio), showPivotLabels, showRatioLabels)

method getRange(Ratio r, float errorPercent)=>
    startRange = r.startValue == r.endValue? r.startValue * (100-errorPercent)/100 : r.startValue
    endRange = r.startValue == r.endValue? r.endValue * (100+errorPercent)/100 : r.endValue
    [startRange, endRange]

method validateRatio(Ratio r, float ratio, float errorPercent)=>
    valid=true
    if(r.enable)
        [startRange, endRange] = r.getRange(errorPercent)
        valid := ratio >= startRange and ratio <= endRange
    valid

retracementRatio(x, a, b, l)=>fibs.retracementRatio(x.price, a.price, b.price, l)

method calculateRatios(Pattern p)=>
    x = p.pivots.last()
    a = p.pivots.get(p.scanner.numberOfPivots-2)
    b = p.pivots.get(p.scanner.numberOfPivots-3)
    c = p.pivots.get(p.scanner.numberOfPivots-4)
    d = p.pivots.get(p.scanner.numberOfPivots-5)
    e = p.scanner.numberOfPivots==6?p.pivots.get(p.scanner.numberOfPivots-6):d
    p.ratios := array.new<float>()
    p.ratios.push(retracementRatio(x, a, b, p.scanner.logScale))
    p.ratios.push(retracementRatio(a, b, c, p.scanner.logScale))
    p.ratios.push(retracementRatio(b, c, d, p.scanner.logScale))
    p.ratios.push(retracementRatio(c, d, e, p.scanner.logScale))
    p.ratios.push(retracementRatio(x, a, d, p.scanner.logScale))
    p.ratios.push(retracementRatio(x, c, b, p.scanner.logScale))
    p.ratios.push(retracementRatio(a, b, e, p.scanner.logScale))
    p.ratios.push(retracementRatio(a, d, e, p.scanner.logScale))
    p

method validate(Pattern p)=>
    p.valid := true
    for [i, ratio] in p.scanner.ratios
        p.valid := p.valid and ratio.validateRatio(p.ratios.get(i), p.scanner.errorPercent)
    p

retracement(chart.point p1, chart.point p2, Ratio r, float errorPercent, bool logScale=false)=>
    [startRange, endRange] = r.getRange(errorPercent)
    startValue = fibs.retracement(p1.price, p2.price, startRange, logScale)
    endValue = fibs.retracement(p1.price, p2.price, endRange, logScale)
    [startValue, endValue]

getMidPoint(p1, p2)=>chart.point.new((p1.time+p2.time)/2, (p1.index+p2.index)/2, (p1.price+p2.price)/2)

method draw(Pattern p)=>
    x = p.pivots.last()
    a = p.pivots.get(p.scanner.numberOfPivots-2)
    b = p.pivots.get(p.scanner.numberOfPivots-3)
    c = p.pivots.get(p.scanner.numberOfPivots-4)
    d = p.pivots.get(p.scanner.numberOfPivots-5)
    e = p.scanner.numberOfPivots==6?p.pivots.get(p.scanner.numberOfPivots-6):d

    dir = x.price > a.price? 1 : -1

    p.pLine := polyline.new(p.pivots, false, false, xloc.bar_time, p.drawingProperties.lineColor, line_style = line.style_solid, line_width = 2)

    p.pivotLabels := array.new<label>()
    p.ratioLines := array.new<line>()
    p.ratioLabels := array.new<label>()
    if(p.drawingProperties.showPivotLabels)
        p.pivotLabels.push(label.new(x, 'X', xloc.bar_time, yloc.price, na, dir > 0? label.style_label_lower_right : label.style_label_upper_right, p.drawingProperties.lineColor, size.normal))
        p.pivotLabels.push(label.new(a, 'A', xloc.bar_time, yloc.price, na, dir > 0? label.style_label_upper_right : label.style_label_lower_right, p.drawingProperties.lineColor, size.normal))
        p.pivotLabels.push(label.new(b, 'B', xloc.bar_time, yloc.price, na, dir > 0? label.style_label_down : label.style_label_up, p.drawingProperties.lineColor, size.normal))
        p.pivotLabels.push(label.new(c, 'C', xloc.bar_time, yloc.price, na, dir > 0? label.style_label_up : label.style_label_down, p.drawingProperties.lineColor, size.normal))
        p.pivotLabels.push(label.new(d, 'D', xloc.bar_time, yloc.price, na, dir > 0? label.style_label_lower_left : label.style_label_upper_left, p.drawingProperties.lineColor, size.normal))
        if(p.scanner.numberOfPivots == 6)
            p.pivotLabels.push(label.new(e, 'E', xloc.bar_time, yloc.price, na, dir > 0? label.style_label_upper_left : label.style_label_lower_left, p.drawingProperties.lineColor, size.normal))
    if(p.drawingProperties.showRatioLabels)
        if(p.scanner.ratios.get(0).enable)
            p.ratioLines.push(line.new(x, b, xloc.bar_time, extend.none, p.drawingProperties.lineColor, line.style_dotted, 1))
            p.ratioLabels.push(label.new(getMidPoint(x, b), 'XAB : '+str.tostring(p.ratios.get(0)), xloc.bar_time, yloc.price, na, 
                        dir > 0? label.style_label_lower_right : label.style_label_upper_right, p.drawingProperties.lineColor, size.small))
        if(p.scanner.ratios.get(1).enable)
            p.ratioLines.push(line.new(a, c, xloc.bar_time, extend.none, p.drawingProperties.lineColor, line.style_dotted, 1))
            p.ratioLabels.push(label.new(getMidPoint(a, c), 'ABC : '+str.tostring(p.ratios.get(1)), xloc.bar_time, yloc.price, na, 
                        dir > 0? label.style_label_upper_right : label.style_label_lower_right, p.drawingProperties.lineColor, size.small))
        if(p.scanner.ratios.get(2).enable)
            p.ratioLines.push(line.new(b, d, xloc.bar_time, extend.none, p.drawingProperties.lineColor, line.style_dotted, 1))
            p.ratioLabels.push(label.new(getMidPoint(b, d), 'BCD : '+str.tostring(p.ratios.get(2)), xloc.bar_time, yloc.price, na, 
                        dir > 0? label.style_label_lower_left : label.style_label_upper_left, p.drawingProperties.lineColor, size.small))
        if(p.scanner.ratios.get(3).enable)
            p.ratioLines.push(line.new(c, e, xloc.bar_time, extend.none, p.drawingProperties.lineColor, line.style_dotted, 1))
            p.ratioLabels.push(label.new(getMidPoint(c, e), 'CDE : '+str.tostring(p.ratios.get(3)), xloc.bar_time, yloc.price, na, 
                        dir > 0? label.style_label_upper_left : label.style_label_lower_left, p.drawingProperties.lineColor, size.small))
        if(p.scanner.ratios.get(4).enable or p.scanner.ratios.get(5).enable)
            p.ratioLines.push(line.new(x, d, xloc.bar_time, extend.none, p.drawingProperties.lineColor, line.style_dotted, 1))
            ratioLbl = (p.scanner.ratios.get(4).enable? 'XAD : '+str.tostring(p.ratios.get(4)) : '') +
                         (p.scanner.ratios.get(4).enable and p.scanner.ratios.get(5).enable? ' / ':'') +
                         (p.scanner.ratios.get(5).enable? 'XCD : '+str.tostring(p.ratios.get(5)) : '')
            p.ratioLabels.push(label.new(getMidPoint(x, d), ratioLbl, xloc.bar_time, yloc.price, na, 
                        dir > 0? label.style_label_down : label.style_label_up, p.drawingProperties.lineColor, size.small))
        if(p.scanner.ratios.get(6).enable or p.scanner.ratios.get(7).enable)
            p.ratioLines.push(line.new(a, e, xloc.bar_time, extend.none, p.drawingProperties.lineColor, line.style_dotted, 1))
            ratioLbl = (p.scanner.ratios.get(6).enable? 'ABE : '+str.tostring(p.ratios.get(6)) : '') +
                         (p.scanner.ratios.get(6).enable and p.scanner.ratios.get(7).enable? ' / ':'') +
                         (p.scanner.ratios.get(7).enable? 'ADE : '+str.tostring(p.ratios.get(7)) : '')
            p.ratioLabels.push(label.new(getMidPoint(a, e), ratioLbl, xloc.bar_time, yloc.price, na, 
                        dir > 0? label.style_label_up : label.style_label_down, p.drawingProperties.lineColor, size.small))
    p.hasPrz := p.scanner.numberOfPivots == 6? p.scanner.ratios.get(3).enable or p.scanner.ratios.get(6).enable or p.scanner.ratios.get(7).enable :
                     p.scanner.ratios.get(2).enable or p.scanner.ratios.get(4).enable or p.scanner.ratios.get(5).enable
    float przStartPrice = na
    float przEndPrice = na
    if(p.scanner.numberOfPivots == 6 and (p.scanner.ratios.get(3).enable or p.scanner.ratios.get(6).enable or p.scanner.ratios.get(7).enable))
        if(p.scanner.ratios.get(3).enable)
            [start,end] = retracement(c, d, p.scanner.ratios.get(3), p.scanner.errorPercent)
            przStartPrice := start
            przEndPrice := end
        if(p.scanner.ratios.get(6).enable)
            [start,end] = retracement(a, b, p.scanner.ratios.get(6), p.scanner.errorPercent)
            przStartPrice := na(przStartPrice)? start : (przStartPrice < przEndPrice? math.max(przStartPrice, start) : math.min(przStartPrice, start))
            przEndPrice := na(przStartPrice)? end : (przStartPrice < przEndPrice? math.min(przEndPrice, end) : math.max(przEndPrice, end))
        if(p.scanner.ratios.get(7).enable)
            [start,end] = retracement(a, d, p.scanner.ratios.get(7), p.scanner.errorPercent)
            przStartPrice := na(przStartPrice)? start : (przStartPrice < przEndPrice? math.max(przStartPrice, start) : math.min(przStartPrice, start))
            przEndPrice := na(przStartPrice)? end : (przStartPrice < przEndPrice? math.min(przEndPrice, end) : math.max(przEndPrice, end))
    if(p.scanner.numberOfPivots == 5 and (p.scanner.ratios.get(2).enable or p.scanner.ratios.get(4).enable or p.scanner.ratios.get(5).enable))
        if(p.scanner.ratios.get(2).enable)
            [start,end] = retracement(b, c, p.scanner.ratios.get(2), p.scanner.errorPercent)
            przStartPrice := start
            przEndPrice := end
        if(p.scanner.ratios.get(4).enable)
            [start,end] = retracement(x, a, p.scanner.ratios.get(4), p.scanner.errorPercent)
            przStartPrice := na(przStartPrice)? start : (przStartPrice < przEndPrice? math.max(przStartPrice, start) : math.min(przStartPrice, start))
            przEndPrice := na(przStartPrice)? end : (przStartPrice < przEndPrice? math.min(przEndPrice, end) : math.max(przEndPrice, end))
        if(p.scanner.ratios.get(5).enable)
            [start,end] = retracement(x, c, p.scanner.ratios.get(5), p.scanner.errorPercent)
            przStartPrice := na(przStartPrice)? start : (przStartPrice < przEndPrice? math.max(przStartPrice, start) : math.min(przStartPrice, start))
            przEndPrice := na(przStartPrice)? end : (przStartPrice < przEndPrice? math.min(przEndPrice, end) : math.max(przEndPrice, end))

    if(p.hasPrz)
        p.prz := box.new(chart.point.new(time, p.scanner.numberOfPivots == 6? e.index:d.index, przStartPrice), 
                         chart.point.new(time, p.scanner.numberOfPivots == 6? e.index+3:d.index+3, przEndPrice),
                         p.drawingProperties.lineColor, 0, line.style_dotted, extend.none, xloc.bar_index, color.new(p.drawingProperties.lineColor, 70))

method checkIfPatternExist(array<Pattern> this, Pattern pattern)=>
    duplicate = false
    for i=this.size()>0?this.size()-1:na to 0
        p = this.get(i)
        match = true
        for [j, pivot] in p.pivots
            nPivot = pattern.pivots.get(j)
            if(pivot.index != nPivot.index and j != 0)
                match := false
                break
        if(match)
            duplicate := true
            break
    duplicate

method scan(Scanner scanner, zg.Zigzag zigzag)=>
    var id = 0
    if(not na(zigzag) and zigzag.flags.newPivot)
        mlzigzag = zigzag
        while(mlzigzag.zigzagPivots.size()>=scanner.numberOfPivots)
            Pattern p = Pattern.new(id, scanner, mlzigzag.zigzagPivots.getPoints().slice(0, numberOfPivots)).calculateRatios().validate()
            if(p.valid and not patterns.checkIfPatternExist(p))
                id+=1
                pColor = themeColors.pop()
                themeColors.unshift(pColor)
                p.drawingProperties := DrawingProperties.new(pColor, pColor, 2, scanner.displayPivotLabels, scanner.displayRatioLabels)
                p.draw()
                patterns.push(p)
            mlzigzag := mlzigzag.nextlevel()

    // if(not na(zigzag) and zigzag.flags.newPivot and zigzag.zigzagPivots.size()>=scanner.numberOfPivots)
    //     Pattern p = Pattern.new(id, scanner, zigzag.zigzagPivots.getPoints().slice(0, numberOfPivots)).calculateRatios().validate()
    //     if(p.valid and not patterns.checkIfPatternExist(p))
    //         id+=1
    //         pColor = themeColors.pop()
    //         themeColors.unshift(pColor)
    //         p.drawingProperties := DrawingProperties.new(pColor, pColor, 2, scanner.displayPivotLabels, scanner.displayRatioLabels)
    //         p.draw()
    //         patterns.push(p)

method printSummary(Scanner scanner, array<Pattern> patterns)=>
    tbl = table.new(position.bottom_right, 2, 15, color.aqua, chart.fg_color, 1, chart.fg_color, 1)
    tbl.cell(0, 0, 'Pattern', text_color = chart.fg_color, bgcolor = color.maroon)
    tbl.cell(1, 0, scanner.patternName, text_color = color.black, bgcolor = color.aqua)
    tbl.cell(0, 1, 'Pivots', text_color = chart.fg_color, bgcolor = color.maroon)
    tbl.cell(1, 1, str.tostring(scanner.numberOfPivots), text_color = color.black, bgcolor = color.aqua)
    for [i, ratio] in scanner.ratios
        if(ratio.enable)
            [startRange, endRange] = ratio.getRange(scanner.errorPercent)
            tbl.cell(0, 2+i, ratio.ratioTitle, text_color = chart.fg_color, bgcolor = color.maroon)
            tbl.cell(1, 2+i, str.tostring(startRange)+'-'+str.tostring(endRange), text_color = color.black, bgcolor = color.aqua)
    tbl.cell(0, 2+scanner.ratios.size(), 'Identified', text_color = chart.fg_color, bgcolor = color.maroon)
    tbl.cell(1, 2+scanner.ratios.size(), str.tostring(patterns.size()), text_color = color.black, bgcolor = color.aqua)
var zg.Zigzag zigzag = zg.Zigzag.new(zigzagLength, depth, offset)
zigzag.calculate()
scanner.scan(zigzag)
if(showSummaryTable and (barstate.islast or barstate.islastconfirmedhistory))
    scanner.printSummary(patterns)
````
