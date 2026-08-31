<!-- tradingview-pine-id: PUB;cf7752de8b4246fd8a8c97b35323ce7d -->
<!-- tradingviewscripts-format: 1 -->
# Recursive Auto-Pitchfork [Trendoscope®]

Source: https://www.tradingview.com/script/hv8ghOJp-Recursive-Auto-Pitchfork-Trendoscope/

## Description

"Say Hi" to object oriented programming with Pinescript using types and methods. This is the beginning of new era of Pinescript where we are moving from isolated scripts containing indicator and strategies to whole ecosystem of Object Oriented Programming with libraries of highly reusable components. Those who are familiar with programming would have already realised how big these improvements are and what it brings to the table.

With this script, I am not just providing an indicator for traders but also an introduction for programmers on how to design and build object oriented components in Pinescript using types and methods. Big thanks to Tradingview and Pine development team for making this happen. We look forward for many such gifts in the future :)

 🎲 Architecture

As mentioned before, we are not just building an indicator here. But, an ecosystem of components. Using Types and Methods we can visualise libraries as Classes. Thus, we can build an ecosystem of libraries in layered approach to enhance effective code reusability.

Generic architecture can be visualised as below

[https://www.tradingview.com/x/den84oaX/](https://www.tradingview.com/x/den84oaX/)

Coming to the specific case of Auto Pitchfork indicator, the indicator code is less than 50 lines for logic and around 100 lines of inputs. But, most of the heavy-lifting is done by the libraries underneath. Here is a snapshot of related libraries and how they are connected.

[https://www.tradingview.com/x/lmYZslzy/](https://www.tradingview.com/x/lmYZslzy/)

All libraries are divided into two portions.

[*] Types - Contains only type definitions
[*] Methods - Contains only method definitions related to the types defined in the Types library

Together, these libraries can be visualised as Class. Methods are defined in such a way all exported methods are related to Types and no other functions or features are defined. If we need further functionality which does not depend on the types, we need to do this via some other library and use them here. Similarly, we should not define any methods related to these types in other libraries.

Reason for splitting the libraries to types and methods is to enable updating methods without disturbing types. Since libraries create interdependencies due to versioning, it is best if we do less updates on the type definitions. Splitting the two enables adding more features while keeping the type definition version intact.

 🎲 Base Libraries
Base libraries are those which does not have any dependency. They form basic structures which are later used in other libraries. These libraries need to be crafted carefully so that minimal updates are done later on. Any updates on these libraries will impact all the dependent libraries and scripts.

🎯 Drawing

[*] [DrawingTypes](https://www.tradingview.com/script/63c8VXSa-DrawingTypes/) - Defines basic drawing types Point, Line, Label, Box, Linefill and related property types.
[*] [DrawingMethods](https://www.tradingview.com/script/eNM7BFaR-DrawingMethods/) - All the methods or functionality surrounding Basic types are defined here.

 🎲 Layer 1 Libraries
These are the libraries which has direct dependency on base libraries. 
🎯 Zigzag

[*] [ZigzagTypes](https://www.tradingview.com/script/uZKDIy4N-ZigzagTypes/) - Types required for defining Zigzag and Divergence
[*] [ZigzagMethods](https://www.tradingview.com/script/kO5FUZVr-ZigzagMethods/) - Methods associated with Zigzag Type definitions. 

🎯Pitchfork

[*] [PitchforkTypes](https://www.tradingview.com/script/ine0QCxF-PitchforkTypes/) - Basic and Drawing Types for Pitchfork objects
[*] [PitchforkMethods](https://www.tradingview.com/script/eUSeK6kz-PitchforkMethods/) - Methods associated with Pitchfork type definitions

 🎲 Indicator and Settings 
Indicator draws pitchfork based on recursive zigzag configurations. Recursive zigzag is derived with following logic:

[*] Base level zigzag is calculated with regular zigzag algorithm with given length and depth
[*] Next level zigzag is calculated based on base zigzag. And we recursively calculate higher level zigzags until we are left with 4 or less pivots or when no further reduction is possible

On every level of zigzag, we then check the last 3 pivots and draw pitchfork based on the retracement ratio.

Indicator settings are summarised in the tooltips and are as below.

[https://www.tradingview.com/x/GYpDN9yV/](https://www.tradingview.com/x/GYpDN9yV/)

Finally, big thanks to my partner [@CryptoArch_](https://www.tradingview.com/u/CryptoArch_/) for bringing up the topic of pitchfork for our next development.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd Trendoscope®
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
indicator('Recursive Auto-Pitchfork [Trendoscope®]', 'RAPF [Trendoscope®]', overlay = true, max_lines_count = 500)
import Trendoscope/Drawing/2 as dr
import Trendoscope/ZigzagLite/3 as zg
import Trendoscope/Pitchfork/1 as p
import Trendoscope/utils/1 as ut

theme = input.enum(ut.Theme.DARK, title = 'Theme', group = 'Generic Settings', tooltip = 'Chart theme settings. Line and label colors are generted based on the theme settings. If dark theme is selected, ' + 'lighter colors are used and if light theme is selected, darker colors are used.', display = display.none)
zigzagLength = input.int(13, step = 5, minval = 3, title = 'Length', group = 'Zigzag', tooltip = 'Zigzag length for level 0 zigzag', display = display.none)
depth = input.int(50, 'Depth', step = 25, maxval = 500, group = 'Zigzag', tooltip = 'Zigzag depth refers to max number of pivots to show on chart', display = display.none)
useRealTimeBars = input.bool(true, 'Use Real Time Bars', group = 'Zigzag', tooltip = 'If enabled real time bars are used for calculation. Otherwise, only confirmed bars are used', display = display.none)

typeTooltip = 'Handle Type' + '\nandrews - Pivot A' + '\n\tschiff - X of Pivot A and y from median of Pivot A and B' + '\n\tmschiff - X and Y are median of Pivot A and Pivot B' + '\n\nNeck Type' + '\n\tmedian - median of Pivot B and Pivot C' + '\n\tinside - Pivot C'

pitchforkType = input.string('andrews', 'Type', ['andrews', 'schiff', 'mschiff'], group = 'Pitchfork', inline = 't', display = display.none)
neckType = input.string('median', '', ['median', 'inside'], group = 'Pitchfork', inline = 't', tooltip = typeTooltip, display = display.none)

handle = pitchforkType == 'andrews' ? 'regular' : pitchforkType
inside = neckType == 'inside'

ratioFrom = input.float(0.25, 'Ratio', minval = 0.0, maxval = 0.5, group = 'Pitchfork', inline = 'r', display = display.none)
ratioTo = input.float(1, '', minval = 0.5, maxval = 1.618, group = 'Pitchfork', inline = 'r', tooltip = 'Range of ratio for which drawing pitchfork is allowed', display = display.none)
useConfirmedPivot = input.bool(true, 'Use Confirmed Pivots', group = 'Pitchfork', tooltip = 'If set to true, uses last confirmed pivot and ignores the current moving pivot', display = display.none)

includeRatio1 = input.bool(false, '', inline = 'r1', group = 'Forks', display = display.none)
ratio1 = input.float(0.236, '', inline = 'r1', group = 'Forks', display = display.none)
color1 = input.color(#f77c80, '', inline = 'r1', group = 'Forks', display = display.none)

includeRatio2 = input.bool(false, '', inline = 'r1', group = 'Forks', display = display.none)
ratio2 = input.float(0.382, '', inline = 'r1', group = 'Forks', display = display.none)
color2 = input.color(#ffb74d, '', inline = 'r1', group = 'Forks', display = display.none)

includeRatio3 = input.bool(true, '', inline = 'r2', group = 'Forks', display = display.none)
ratio3 = input.float(0.500, '', inline = 'r2', group = 'Forks', display = display.none)
color3 = input.color(#fff176, '', inline = 'r2', group = 'Forks', display = display.none)

includeRatio4 = input.bool(false, '', inline = 'r2', group = 'Forks', display = display.none)
ratio4 = input.float(0.618, '', inline = 'r2', group = 'Forks', display = display.none)
color4 = input.color(#81c784, '', inline = 'r2', group = 'Forks', display = display.none)

includeRatio5 = input.bool(false, '', inline = 'r3', group = 'Forks', display = display.none)
ratio5 = input.float(0.786, '', inline = 'r3', group = 'Forks', display = display.none)
color5 = input.color(#42bda8, '', inline = 'r3', group = 'Forks', display = display.none)

includeRatio6 = input.bool(false, '', inline = 'r3', group = 'Forks', display = display.none)
ratio6 = input.float(0.886, '', inline = 'r3', group = 'Forks', display = display.none)
color6 = input.color(#4dd0e1, '', inline = 'r3', group = 'Forks', display = display.none)

includeRatio7 = input.bool(true, '', inline = 'r4', group = 'Forks', display = display.none)
ratio7 = input.float(1.000, '', inline = 'r4', group = 'Forks', display = display.none)
color7 = input.color(#5b9cf6, '', inline = 'r4', group = 'Forks', display = display.none)

includeRatio8 = input.bool(false, '', inline = 'r4', group = 'Forks', display = display.none)
ratio8 = input.float(1.130, '', inline = 'r4', group = 'Forks', display = display.none)
color8 = input.color(#9575cd, '', inline = 'r4', group = 'Forks', display = display.none)

includeRatio9 = input.bool(false, '', inline = 'r5', group = 'Forks', display = display.none)
ratio9 = input.float(1.272, '', inline = 'r5', group = 'Forks', display = display.none)
color9 = input.color(#ba68c8, '', inline = 'r5', group = 'Forks', display = display.none)

includeRatio10 = input.bool(false, '', inline = 'r5', group = 'Forks', display = display.none)
ratio10 = input.float(1.382, '', inline = 'r5', group = 'Forks', display = display.none)
color10 = input.color(#f06292, '', inline = 'r5', group = 'Forks', display = display.none)

includeRatio11 = input.bool(false, '', inline = 'r6', group = 'Forks', display = display.none)
ratio11 = input.float(1.618, '', inline = 'r6', group = 'Forks', display = display.none)
color11 = input.color(#faa1a4, '', inline = 'r6', group = 'Forks', display = display.none)

includeRatio12 = input.bool(false, '', inline = 'r6', group = 'Forks', display = display.none)
ratio12 = input.float(2.000, '', inline = 'r6', group = 'Forks', display = display.none)
color12 = input.color(#4caf50, '', inline = 'r6', group = 'Forks', display = display.none)

extend = input.bool(true, 'Extend', group = 'Display', tooltip = 'Extend fork lines to right', display = display.none)
fill = input.bool(true, 'Fill', group = 'Display', inline = 'f', display = display.none)
transparency = input.int(95, 'Transparency', group = 'Display', inline = 'f', tooltip = 'Fill Forkline with background color', display = display.none)

offset = useRealTimeBars ? 0 : 1

themeColors = theme.getColors()
var zg.Zigzag zigzag = zg.Zigzag.new(zigzagLength, depth, offset)
zigzag.calculate(array.from(high, low))

startIndex = useConfirmedPivot ? 1 : 0

includes = array.from(includeRatio1, includeRatio2, includeRatio3, includeRatio4, includeRatio5, includeRatio6, includeRatio7, includeRatio8, includeRatio9, includeRatio10, includeRatio11, includeRatio12)
ratios = array.from(ratio1, ratio2, ratio3, ratio4, ratio5, ratio6, ratio7, ratio8, ratio9, ratio10, ratio11, ratio12)
colors = array.from(color1, color2, color3, color4, color5, color6, color7, color8, color9, color10, color11, color12)

array<p.Fork> forks = array.new<p.Fork>()
for [i, include] in includes
    if include
        forks.push(p.Fork.new(ratios.get(i), colors.get(i), include))

p.PitchforkProperties properties = p.PitchforkProperties.new(forks, handle, inside)
p.PitchforkDrawingProperties dProperties = p.PitchforkDrawingProperties.new(extend, fill, transparency)

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
            p.Pitchfork pitchFork = p.Pitchfork.new(p1Point, p2Point, p3Point, properties, dProperties, lProperties)
            drawing = pitchFork.createDrawing()
            drawing.draw()
            pitchforks.push(pitchFork)
        mlzigzag := mlzigzag.nextlevel()
        mlzigzag
````
