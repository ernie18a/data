<!-- tradingview-pine-id: PUB;10220b8683974783b18340d23824e5d5 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Forks [Trendoscope®]

Source: https://www.tradingview.com/script/qAMnMxZI-Volume-Forks-Trendoscope/

## Description

🎲 Volume Forks - Advanced Price Analysis with Recursive Auto-Pitchfork and Angled Volume Profile

The Volume Forks Indicator is a comprehensive research tool that combines two innovative techniques, [Recursive Auto-Pitchfork](https://www.tradingview.com/script/hv8ghOJp-Recursive-Auto-Pitchfork-Trendoscope/) and [Angled Volume Profile](https://www.tradingview.com/script/MgsLckWl-Angled-Volume-Profile-Trendoscope/). This indicator provides traders with valuable insights into price dynamics by integrating accurate pitchfork drawing and volume analysis over angled levels. The indicator does following things

[*] Detects Pitchfork formations automatically on the chart over [Recursive Zigzag](https://www.tradingview.com/script/J6mxhxdn-Recursive-Zigzag-Trendoscope/)
[*] Instead of drawing forks based on fib levels, volume distribution over ABC of pitchfork is calculated and drawn in the direction of the handle. 

🎲 Brief about Pitchfork 
Pitchfork is drawn when price forms ABC pattern. Pitchfork draws a series of parallel lines in the direction of trend which can be used for support and resistance.

There are many methods of drawing pitchfork. In all cases, a line joining B​C  will make the base of pitchfork and fork lines are drawn from different points of the base. All the fork lines will be parallel. But, the handle of the base defines the direction of fork lines. Classification of pitchfork is mainly based on the starting and ending points of the handle.

🎲 Regular Types

Here, end of the handle is always fixed and it will be the mid point of B and C.

🎯 Andrews Pitchfork

[*] Handle starts from A and joins the base at mid of B and C.
[*] Forks are drawn based on fib ratios from the handle

https://www.tradingview.com/x/8F0U7mQW

🎯 Schiff Pitchfork

[*] Handle starts from Bar of A and price of middle of AB and joins the base at mid of B and C
[*] Forks are drawn based on fib ratios from the handle

https://www.tradingview.com/x/TmZjQsi1

🎯 Modified Schiff Pitchfork

[*] Handle starts from mid of A and B and joins the base at mid of B and C
[*] Forks are drawn based on fib ratios from the handle

https://www.tradingview.com/x/DmrFYBjl

🎲 Inside Types

Here, C will act as end of the handle which joins the Base B​C .

🎯 Andrews Pitchfork (Inside)

[*] Handle starts from A and joins the base at C
[*] Forks are drawn based on fib ratios from the handle

https://www.tradingview.com/x/VePxK3PR

🎯 Schiff Pitchfork (Inside)

[*] Handle starts from Bar of A and price of (A+B)/2 and joins the base at C
[*] Forks are drawn based on fib ratios from the handle

https://www.tradingview.com/x/YbEXKAkZ

🎯 Modified Schiff Pitchfork (Inside)

[*] Handle starts from mid of A and B and joins the base at C
[*] Forks are drawn based on fib ratios from the handle

https://www.tradingview.com/x/vsHhZKpv

🎲 Brief about Pitchfork 
The Angled Volume Profile technique expands on the concept of volume profile by measuring volume distribution levels over angled levels rather than just horizontal levels. By selecting a starting point and angle interactively, traders can assess volume distribution within specific price trends. This feature is particularly useful for analysing volume dynamics in trending markets.

🎲 Settings 

Indicator settings include few things which determine the scanning of pitchforks and few which determines drawing of volume profile lines.

https://www.tradingview.com/x/DJoEDg4L/

Please note that, due to pine limitations of 500 lines, if there are too many formations on the chart, volume profile may not appear correctly. If that happens, please reduce the number of volume forks per formation.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd
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
indicator('Volume Forks [Trendoscope®]', 'VF [Trendoscope®]', overlay = true, max_lines_count = 500, max_bars_back = 3000)
import Trendoscope/Drawing/2 as dr
import Trendoscope/ZigzagLite/3 as zg
import Trendoscope/Pitchfork/1 as p
import Trendoscope/utils/1 as ut

theme = input.enum(ut.Theme.DARK, title = 'Theme', group = 'Generic Settings', 
                 tooltip = 'Chart theme settings. Line and label colors are generted based on the theme settings. If dark theme is selected, ' +
                 'lighter colors are used and if light theme is selected, darker colors are used.', display=display.none)
zigzagLength = input.int(13, step = 5, minval = 3, title = 'Length', group = 'Zigzag', tooltip = 'Zigzag length for level 0 zigzag', display=display.none)
depth = input.int(50, 'Depth', step = 25, maxval = 500, group = 'Zigzag', tooltip = 'Zigzag depth refers to max number of pivots to show on chart', display=display.none)
useRealTimeBars = input.bool(true, 'Use Real Time Bars', group = 'Zigzag', tooltip = 'If enabled real time bars are used for calculation. Otherwise, only confirmed bars are used', display=display.none)

typeTooltip = 'Handle Type' + '\nandrews - Pivot A' +
             '\nschiff - X of Pivot A and y from median of Pivot A and B' + 
             '\nmschiff - X and Y are median of Pivot A and Pivot B' + 
             '\n\nNeck Type' + '\nmedian - median of Pivot B and Pivot C' + '\ninside - Pivot C'

pitchforkType = input.string('andrews', 'Type', ['andrews', 'schiff', 'mschiff'], group = 'Pitchfork', inline = 't', display=display.none)
neckType = input.string('inside', '', ['median', 'inside'], group = 'Pitchfork', inline = 't', tooltip = typeTooltip, display=display.none)
handle = pitchforkType == 'andrews' ? 'regular' : pitchforkType
inside = neckType == 'inside'

ratioFrom = input.float(0.25, 'Ratio', minval = 0.0, maxval = 0.5, group = 'Pitchfork', inline = 'r', display=display.none)
ratioTo = input.float(1, '', minval = 0.5, maxval = 1.618, group = 'Pitchfork', inline = 'r', tooltip = 'Range of ratio for which drawing pitchfork is allowed', display=display.none)
numberOfForks = input.int(100, 'Forks', group = 'Pitchfork', inline = 'f', minval = 10, maxval = 200, step = 25, tooltip = 'Number of volume forks', display=display.none)
usePercentile = input.bool(false, 'Percentile', group = 'Pitchfork', tooltip = 'Use percentile of volume to determine the length of forks instead of percentage', display=display.none)
useConfirmedPivot = input.bool(true, 'Use Confirmed Pivots', group = 'Pitchfork', tooltip = 'If set to true, uses last confirmed pivot and ignores the current moving pivot', display=display.none)

extend = false
fill = false

offset = useRealTimeBars ? 0 : 1

themeColors = theme.getColors()
var zg.Zigzag zigzag = zg.Zigzag.new(zigzagLength, depth, offset)
zigzag.calculate(array.from(high, low))

startIndex = useConfirmedPivot ? 1 : 0

method draw(p.PitchforkDrawing this) =>
    this.medianLine.draw()
    this.baseLine.draw()
    this.forkLines.draw()
    this

method get_price(dr.Line this, int bar) =>
    stepPerBar = (this.end.price - this.start.price) / (this.end.index - this.start.index)
    distance = bar - this.start.index
    this.start.price + distance * stepPerBar

array<p.Fork> forks = array.new<p.Fork>()
for i = 0 to numberOfForks - 1 by 1
    forks.push(p.Fork.new(i / (numberOfForks - 1)))

p.PitchforkProperties properties = p.PitchforkProperties.new(forks, handle, inside)

if barstate.islast
    var array<p.Pitchfork> pitchforks = array.new<p.Pitchfork>()
    pitchforks.clear()
    mlzigzag = zigzag
    while mlzigzag.zigzagPivots.size() >= 3 + startIndex
        lineColor = themeColors.pop()
        themeColors.unshift(lineColor)

        p3 = mlzigzag.zigzagPivots.get(startIndex)
        p3Point = p3.point
        p2Point = mlzigzag.zigzagPivots.get(startIndex + 1).point
        p1Point = mlzigzag.zigzagPivots.get(startIndex + 2).point

        if p3.ratio >= ratioFrom and p3.ratio <= ratioTo and p3Point.index - p1Point.index < 500
            dr.LineProperties lProperties = dr.LineProperties.new(color = lineColor)
            p.PitchforkDrawingProperties dProperties = p.PitchforkDrawingProperties.new(extend, fill, commonColor = color.new(lineColor, 70))
            p.Pitchfork pitchFork = p.Pitchfork.new(p1Point, p2Point, p3Point, properties, dProperties, lProperties)
            drawing = pitchFork.createDrawing()
            array<float> forkVolumes = array.new<float>(drawing.forkLines.size(), 0.0)
            for bar = p1Point.index to p3Point.index by 1
                bOpen = open[bar_index - bar]
                bClose = close[bar_index - bar]
                bHigh = high[bar_index - bar]
                bLow = low[bar_index - bar]
                bVol = volume[bar_index - bar]
                for [index, forkLine] in drawing.forkLines
                    linePrice = forkLine.get_price(bar)
                    vMultiplier = linePrice >= math.min(bOpen, bClose) and linePrice <= math.max(bOpen, bClose) ? 2 : linePrice >= bLow and linePrice <= bHigh ? 1 : 0
                    forkVolumes.set(index, forkVolumes.get(index) + bVol * vMultiplier)

            for [index, forkLine] in drawing.forkLines
                vPercent = usePercentile ? forkVolumes.percentrank(index) / 100 : forkVolumes.get(index) / forkVolumes.max()
                forkLine.end.index := forkLine.start.index + int(vPercent * (forkLine.end.index - forkLine.start.index))
                forkLine.end.price := forkLine.start.price + vPercent * (forkLine.end.price - forkLine.start.price)
                forkLine.end.price
            drawing.draw()
            pitchforks.push(pitchFork)
        mlzigzag := mlzigzag.nextlevel()
        mlzigzag
````
