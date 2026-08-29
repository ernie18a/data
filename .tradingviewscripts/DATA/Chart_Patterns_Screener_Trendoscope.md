<!-- tradingview-pine-id: PUB;2590687910d8445394340097cf50770b -->
<!-- tradingviewscripts-format: 1 -->
# Chart Patterns Screener [Trendoscope®]

Source: https://www.tradingview.com/script/a7a6yS0y-Chart-Patterns-Screener-Trendoscope/

## Description

🎲 Overview

Chart Patterns Screener is an advanced Pine Script designed to automatically detect and display classical chart patterns on TradingView. It is a specialized, fine-tuned version of the popular [Auto Chart Patterns](https://www.tradingview.com/script/WZ8B1FIW-Auto-Chart-Patterns-Trendoscope/) indicator, optimized specifically for use with the Pine Screener.

🎲 How to Use This Script as Indicator
Since most of the settings are inherited from Auto Chart Patterns, let us first discuss on how to use the indicator before dwelving into the settings.

When you first add the indicator to a chart, you may see a large note or minimal visuals.
This is intentional.
https://www.tradingview.com/x/qkcZVBKQ/

Not to worry, This script is not designed to be used as a regular chart indicator. It was built primarily for scanning across many symbols using TradingView’s [Pine Screener](https://www.tradingview.com/pine-screener/) utility. 

Two Ways to Use It on Chart (if still needed):

[*] Goto the settings of the script and disable the "Note" checkbox. This will let you use the script as an indicator - however the features as indicator are limited when compared to the original  [Auto Chart Patterns [Trendoscope®]](https://www.tradingview.com/script/WZ8B1FIW-Auto-Chart-Patterns-Trendoscope/)
[*] Use the original [Auto Chart Patterns [Trendoscope®]](https://www.tradingview.com/script/WZ8B1FIW-Auto-Chart-Patterns-Trendoscope/)

🎲 How to Use This Script with Pine-Screener
🎯 Add Script to Favourites
You must add this script to your favourites before it appears in the Pine Screener. You can do so by clicking on "Add to favourites" button in the top right corner of the script publication page.

https://www.tradingview.com/x/HiODYrCZ/
🎯 Open Pine Screener Utility
Pine Screener can be opened directly through the direct link - https://www.tradingview.com/pine-screener/ or we can go through the menus on tradingview home page to find the utility.

https://www.tradingview.com/x/1nIfrfaz/
🎯 Load Your watchlist
Watchlist can be created manually or through other screeners. 

Here is a video publication on how to use Tradingivew default stock screener which also explains how to create a watchlist by using the utility.
https://www.tradingview.com/chart/MU/DoUNxymi-Tradingview-Stock-Screener-Simple-and-powerful-tool/

For this demonstration, let us use one of the pre-existing watchlist. Also note that pine-screener has a limitation that watchlist can contain maxium 1000 symbols.
https://www.tradingview.com/x/xh3KSMUb/
🎯 Load the script/Indicator to Pine-Screener

Click on "Choose Indicator" dropdown and select the Chart Pattern Screener [Trendoscope®] from the alphabetically sorted list of indicators. Please note that the dropdown will only have the indicators that are marked as favourites.
https://www.tradingview.com/x/MokrswtD/

Indicator settings and timeframe can be further changed to suit the needs.
https://www.tradingview.com/x/KcExhdmD/
🎯 Select Scanning Criteria and Scan
Indicator settings can have some options shown by default. However, users can click on the + symbol next to "Scan" button to explore other options Availlable.

[*]Current Patterns - contain the number of any pattern available on specific instrument. Hence, they can be used to catch symbols having any pattern on the chart.
[*]Other options however are to catch symbols having specific type of patterns

https://www.tradingview.com/x/NDFezZrQ/
All the filter options have number of patterns of specific types actively present on each instruments. Hence, in order to filter the symbols having these types of patterns, we just need to set the condition if the value is more than 0

https://www.tradingview.com/x/KpuwdmQs/
Examples
To find symbols with any active pattern:

[*]Set condition: Current Patterns > 0

To find specific patterns (example):

[*]Set condition: Rising Wedge > 0 to filter symbols having Rising Wedge patterns
[*]Set condition: Ascending Channel > 0 to filter symbols having Ascending Channel patterns
[*]Set condition: Contracting Triangle > 0 to filter symbols having Contracting Triangle patterns

Once you set the conditions, you can click on Scan to filter the watchlist
https://www.tradingview.com/x/gUHGFKWZ/

🎲 Settings Overview
🎯 Screener Settings
This group of settings contain parameters that are related to screener functionality.

A pattern formed 1000 bars ago may not really mean anything as all the trading opportunity of that pattern would be already over. Hence, in order to find active patterns we need to limit on how many bars back we should check. We provide two options to identify how far we need to look back

[*] Fixed - In the fixed option, we rely on the Fixed number of bars to look back for active patterns. If Fixed bars are 20, this means, we only look for patterns that are formed in last 20 bars.
[*] Relative - This is slightly complex option where number of bars to look before depends on the size of the pattern. We set the percentage of size as number of bars through input. This means, if the pattern spawns 100 bars, the screener will flag it only if it is formed within 20 bars (considering 20% is set as relative percent). However, bigger pattern spawing 150 bars will be flagged if it has formed within 30 bars.

https://www.tradingview.com/x/0dHsg6UW/
🎯 Chart Pattern Settings
These settings are same as what is defined in [Auto Chart Patterns [Trendoscope®]](https://www.tradingview.com/script/WZ8B1FIW-Auto-Chart-Patterns-Trendoscope/).
https://www.tradingview.com/x/1I1Y8eQw/

🎲 Refernces

[*] [Pine Screener - Powerful tool for building programmable screener](https://www.tradingview.com/chart/BTCUSDT/qOOuqPSb-Pine-Screener-Powerful-tool-for-building-programmable-screener/)
[*] [Tradingview Stock Screener - Simple and powerful tool](https://www.tradingview.com/chart/MU/DoUNxymi-Tradingview-Stock-Screener-Simple-and-powerful-tool/)
[*] [Auto Chart Patterns [Trendoscope®]](https://www.tradingview.com/script/WZ8B1FIW-Auto-Chart-Patterns-Trendoscope/).

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

import Trendoscope/utils/6 as ut
import Trendoscope/ohlc/3 as o
import Trendoscope/LineWrapper/2 as wr
import Trendoscope/ZigzagLite/4 as zg

import Trendoscope/abstractchartpatterns/10 as p
import Trendoscope/basechartpatterns/9 as bp

indicator("Chart Patterns Screener [Trendoscope®]", "CPS [Trendoscope®]", overlay = true, max_lines_count=500, max_labels_count=500, max_polylines_count = 100, calc_bars_count = 500)
enum ScreeningMethod
    Fixed
    Relative

showWarning = input.bool(true, 'Note', 'Show/Hide message stating the program is supposed to be used with pine-screener and not indicator', group='Screener', display=display.none)
screeningMethod = input.enum(ScreeningMethod.Fixed, "Screening Method", group='Screener', tooltip = "Method for scanning patterns.\n\tFixed - formed in last N Bars.\n\tRelative - N bars identified relative to the size of pattern", display = display.none)
fixedScreenerBars = input.int(20, 'Fixed Bars', minval=1, step=5, tooltip = 'Number of bars in the past where patterns are formed', group='Screener', display=display.none, active = screeningMethod == ScreeningMethod.Fixed)
relativeScreenerPercent = input.int(20, 'Relative % Bars', minval=1, step=5, tooltip = "Number of bars to look back for patterns as percent of pattern size", group='Screener', display=display.none, active = screeningMethod == ScreeningMethod.Relative)

openSource = input.source(open, '', inline='cs', group='Source', display = display.none)
highSource = input.source(high, '', inline='cs', group='Source', display = display.none)
lowSource = input.source(low, '', inline='cs', group='Source', display = display.none)
closeSource = input.source(close, '', inline='cs', group='Source', display = display.none, tooltip = 'Source on which the zigzag and pattern calculation is done')

useZigzag1 = input.bool(true, '', group = 'Zigzag', inline='z1', display = display.none)
zigzagLength1 = input.int(8, step=5, minval=1, title='', group='Zigzag', inline='z1', display=display.none)
depth1 = input.int(55, "", step=25, maxval=500, group='Zigzag', inline='z1', display=display.none, tooltip = 'Enable and set Length and Dept of Zigzag 1')

useZigzag2 = input.bool(false, '', group = 'Zigzag', inline='z2', display = display.none)
zigzagLength2 = input.int(13, step=5, minval=1, title='', group='Zigzag', inline='z2', display=display.none)
depth2 = input.int(34, "", step=25, maxval=500, group='Zigzag', inline='z2', display=display.none, tooltip = 'Enable and set Length and Dept of Zigzag 2')

useZigzag3 = input.bool(false, '', group = 'Zigzag', inline='z3', display = display.none)
zigzagLength3 = input.int(21, step=5, minval=1, title='', group='Zigzag', inline='z3', display=display.none)
depth3 = input.int(21, "", step=25, maxval=500, group='Zigzag', inline='z3', display=display.none, tooltip = 'Enable and set Length and Dept of Zigzag 3')

useZigzag4 = input.bool(false, '', group = 'Zigzag', inline='z4', display = display.none)
zigzagLength4 = input.int(34, step=5, minval=1, title='', group='Zigzag', inline='z4', display=display.none)
depth4 = input.int(13, "", step=25, maxval=500, group='Zigzag', inline='z4', display=display.none, tooltip = 'Enable and set Length and Dept of Zigzag 4')

numberOfPivots = input.int(5, "Number of Pivots", [5, 6], 'Number of pivots used for pattern identification.', group='Scanning', display = display.none)
errorThresold = input.float(20.0, 'Error Threshold', 0.0, 100, 5, 'Error Threshold for trend line validation', group='Scanning', display = display.none)
flatThreshold = input.float(20.0, 'Flat Threshold', 0.0, 30, 5, 'Ratio threshold to identify the slope of trend lines', group='Scanning', display = display.none)
lastPivotDirection = input.string('both', 'Last Pivot Direction', ['up', 'down', 'both', 'custom'], 'Filter pattern based on the last pivot direction. '+
                             'This option is useful while backtesting individual patterns. When custom is selected, then the individual pattern last pivot direction setting is used',
                             group='Scanning', display=display.none)
checkBarRatio = input.bool(true, 'Verify Bar Ratio ', 'Along with checking the price, also verify if the bars are proportionately placed.', group='Scanning', inline = 'br', display = display.none)
barRatioLimit = input.float(0.382, '', group='Scanning', display = display.none, inline='br')
avoidOverlap = input.bool(false, 'Avoid Overlap',  group='Scanning', inline='a', display = display.none)
repaint = input.bool(true, 'Repaint', 'Avoid Overlap - Will not consider the pattern if it starts before the end of an existing pattern\n\n'+
                     'Repaint - Uses real time bars to search for patterns. If unselected, then only use confirmed bars.', 
                     group='Scanning', inline='a', display = display.none)

allowChannels = input.bool(true, 'Channels', group='Pattern Groups - Geometric Shapes', display = display.none, inline='g')
allowWedges = input.bool(true, 'Wedge', group='Pattern Groups - Geometric Shapes', display = display.none, inline='g')
allowTriangles = input.bool(true, 'Triangle', group='Pattern Groups - Geometric Shapes', display = display.none, inline='g',
         tooltip = 'Channels - Trend Lines are parralel to each other creating equidistance price channels'+
                     '\n\t- Ascending Channel\n\t- Descending Channel\n\t- Ranging Channel'+
                     '\n\nWedges - Trend lines are either converging or diverging from each other and both the trend lines are moving in the same direction'+
                     '\n\t- Rising Wedge (Expanding)\n\t- Rising Wedge (Contracting)\n\t- Falling Wedge (Expanding)\n\t- Falling Wedge (Contracting)'+
                     '\n\nTriangles - Trend lines are either converging or diverging from each other and both trend lines are moving in different directions'+
                     '\n\t- Converging Triangle\n\t- Diverging Triangle\n\t- Ascending Triangle (Contracting)\n\t- Ascending Triangle (Expanding)\n\t- Descending Triangle(Contracting)\n\t- Descending Triangle(Expanding)')

allowRisingPatterns = input.bool(true, 'Rising', group='Pattern Groups - Direction', display = display.none, inline = 'd')
allowFallingPatterns = input.bool(true, 'Falling', group='Pattern Groups - Direction', display = display.none, inline = 'd')
allowNonDirectionalPatterns = input.bool(true, 'Flat/Bi-Directional', group='Pattern Groups - Direction', display = display.none, inline = 'd',
         tooltip = 'Rising - Either both trend lines are moving up or one trend line is flat and the other one is moving up.'+
                     '\n\t- Ascending Channel\n\t- Rising Wedge (Expanding)\n\t- Rising Wedge (Contracting)\n\t- Ascending Triangle (Expanding)\n\t- Ascending Triangle (Contracting)'+
                     '\n\nFalling - Either both trend lines are moving down or one trend line is flat and the other one is moving down.'+
                     '\n\t- Descending Channel\n\t- Falling Wedge (Expanding)\n\t- Falling Wedge (Contracting)\n\t- Descending Triangle (Expanding)\n\t- Descending Triangle (Contracting)'+
                     '\n\nFlat/Bi-Directional - Trend Lines move in different directions or both flat.'+
                     '\n\t- Ranging Channel\n\t- Converging Triangle\n\t- Diverging Triangle')

allowExpandingPatterns = input.bool(true, 'Expanding', group='Pattern Groups - Formation Dynamics', display = display.none, inline = 'f')
allowContractingPatterns = input.bool(true, 'Contracting', group='Pattern Groups - Formation Dynamics', display = display.none, inline='f')
allowParallelChannels = input.bool(true, 'Parallel', group = 'Pattern Groups - Formation Dynamics', display = display.none, inline = 'f',
         tooltip = 'Expanding - Trend Lines are diverging from each other.'+
                     '\n\t- Rising Wedge (Expanding)\n\t- Falling Wedge (Expanding)\n\t- Ascending Triangle (Expanding)\n\t- Descending Triangle (Expanding)\n\t- Diverging Triangle'+
                     '\n\nContracting - Trend Lines are converging towards each other.'+
                     '\n\t- Rising Wedge (Contracting)\n\t- Falling Wedge (Contracting)\n\t- Ascending Triangle (Contracting)\n\t- Descending Triangle (Contracting)\n\t- Converging Triangle'+
                     '\n\nParallel - Trend Lines are almost parallel to each other.'+
                     '\n\t- Ascending Channel\n\t- Descending Channel\n\t- Ranging Channel')

allowUptrendChannel = input.bool(true, 'Ascending  ', group = 'Price Channels', inline='uc', display = display.none)
upTrendChannelLastPivotDirection = input.string('both', '', ['up', 'down', 'both'], inline='uc', group='Price Channels', display = display.none,
             tooltip='Enable Ascending Channel and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowDowntrendChannel = input.bool(true, 'Descending', group = 'Price Channels', inline='dc', display = display.none)
downTrendChannelLastPivotDirection = input.string('both', '', ['up', 'down', 'both'], inline='dc', group='Price Channels', display = display.none,
             tooltip='Enable Descending Channel and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowRangingChannel = input.bool(true, 'Ranging   ', group = 'Price Channels', inline='rc', display = display.none)
rangingChannelLastPivotDirection = input.string('both', '', ['up', 'down', 'both'], inline='rc', group='Price Channels', display = display.none,
             tooltip='Enable Ranging Channel and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowRisingWedgeExpanding = input.bool(true, 'Rising    ', inline='rwe', group = 'Expanding Wedges', display = display.none)
risingWedgeExpandingLastPivotDirection = input.string('down', '', ['up', 'down', 'both'], inline='rwe', group='Expanding Wedges', display = display.none,
             tooltip='Enable Rising Wedge (Expanding) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowFallingWedgeExpanding = input.bool(true, 'Falling   ', inline='fwe', group = 'Expanding Wedges', display = display.none)
fallingWedgeExpandingLastPivotDirection = input.string('up', '', ['up', 'down', 'both'], inline='fwe', group='Expanding Wedges', display = display.none,
             tooltip='Enable Falling Wedge (Expanding) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowRisingWedgeContracting = input.bool(true, 'Rising    ', inline='rwc', group = 'Contracting Wedges', display = display.none)
risingWedgeContractingLastPivotDirection = input.string('down', '', ['up', 'down', 'both'], inline='rwc', group='Contracting Wedges', display = display.none,
             tooltip='Enable Rising Wedge (Contracting) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowFallingWedgeContracting = input.bool(true, 'Falling   ', inline='fwc', group = 'Contracting Wedges', display = display.none)
fallingWedgeContractingLastPivotDirection = input.string('up', '', ['up', 'down', 'both'], inline='fwc', group='Contracting Wedges', display = display.none,
             tooltip='Enable Falling Wedge (Contracting) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowRisingTriangleExpanding = input.bool(true, 'Ascending  ', inline='rte', group = 'Expanding Triangles', display = display.none)
risingTriangleExpandingLastPivotDirection = input.string('up', '', ['up', 'down', 'both'], inline='rte', group='Expanding Triangles', display = display.none,
             tooltip='Enable Ascending Triangle (Expanding) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowFallingTriangleExpanding = input.bool(true, 'Descending', inline='fte', group = 'Expanding Triangles', display = display.none)
fallingTriangleExpandingLastPivotDirection = input.string('down', '', ['up', 'down', 'both'], inline='fte', group='Expanding Triangles', display = display.none,
             tooltip='Enable Descending Triangle (Expanding) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowExpandingTriangle = input.bool(true, 'Diverging ', inline='dt', group = 'Expanding Triangles', display = display.none)
divergineTriangleLastPivotDirection = input.string('both', '', ['up', 'down', 'both'], inline='dt', group='Expanding Triangles', display = display.none,
             tooltip='Enable Diverging Triangle and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')


allowRisingTriangleConverging= input.bool(true, 'Ascending  ', inline='rtc', group = 'Contracting Triangles', display = display.none)
risingTriangleContractingLastPivotDirection = input.string('up', '', ['up', 'down', 'both'], inline='rtc', group='Contracting Triangles', display = display.none,
             tooltip='Enable Ascending Triangle (Contracting) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowFallingTriangleConverging = input.bool(true, 'Descending', inline='ftc', group = 'Contracting Triangles', display = display.none)
fallingTriangleContractingLastPivotDirection = input.string('down', '', ['up', 'down', 'both'], inline='ftc', group='Contracting Triangles', display = display.none,
             tooltip='Enable Descending Triangle (Contracting) and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowConvergingTriangle = input.bool(true, 'Converging ', inline='ct', group = 'Contracting Triangles', display = display.none)
convergingTriangleLastPivotDirection = input.string('both', '', ['up', 'down', 'both'], inline='ct', group='Contracting Triangles', display = display.none,
             tooltip='Enable Converging Triangle and select the last pivot direction filter. Last pivot direction will only be used if the Generic Last Pivot Direction parameter is set to Custom')

allowedPatterns = array.from(
     false,
     allowUptrendChannel and allowRisingPatterns and allowParallelChannels and allowChannels,
     allowDowntrendChannel and allowFallingPatterns and allowParallelChannels and allowChannels,
     allowRangingChannel and allowNonDirectionalPatterns and allowParallelChannels and allowChannels,
     allowRisingWedgeExpanding and allowRisingPatterns and allowExpandingPatterns and allowWedges,
     allowFallingWedgeExpanding and allowFallingPatterns and allowExpandingPatterns and allowWedges,
     allowExpandingTriangle and allowNonDirectionalPatterns and allowExpandingPatterns and allowTriangles,
     allowRisingTriangleExpanding and allowRisingPatterns and allowExpandingPatterns and allowTriangles,
     allowFallingTriangleExpanding and allowFallingPatterns and allowExpandingPatterns and allowTriangles,
     allowRisingWedgeContracting and allowRisingPatterns and allowContractingPatterns and allowWedges,
     allowFallingWedgeContracting and allowFallingPatterns and allowContractingPatterns and allowWedges,
     allowConvergingTriangle and allowNonDirectionalPatterns and allowContractingPatterns and allowTriangles,
     allowFallingTriangleConverging and allowFallingPatterns and allowContractingPatterns and allowTriangles,
     allowRisingTriangleConverging and allowRisingPatterns and allowContractingPatterns and allowTriangles
     )

getLastPivotDirectionInt(lastPivotDirection)=>lastPivotDirection == 'up'? 1 : lastPivotDirection == 'down'? -1 : 0
allowedLastPivotDirections = array.from( 
     0,
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(upTrendChannelLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(downTrendChannelLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(rangingChannelLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(risingWedgeExpandingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(fallingWedgeExpandingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(divergineTriangleLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(risingTriangleExpandingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(fallingTriangleExpandingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(risingWedgeContractingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(fallingWedgeContractingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(convergingTriangleLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(fallingTriangleContractingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection),
     lastPivotDirection == 'custom'? getLastPivotDirectionInt(risingTriangleContractingLastPivotDirection) : getLastPivotDirectionInt(lastPivotDirection)
     )

theme = input.enum(ut.Theme.DARK, title='Theme', group='Display', inline='pc',
         tooltip='Chart theme settings. Line and label colors are generted based on the theme settings. If dark theme is selected, '+
         'lighter colors are used and if light theme is selected, darker colors are used.\n\n'+
         'Pattern Line width - to be used for drawing pattern lines', display=display.none)
patternLineWidth = input.int(2, '', minval=1, inline='pc', group = 'Display', display = display.none)

useCustomColors = input.bool(false, 'Custom Colors', group='Display', display = display.none)
customColorsArray = array.from(
     input.color(color.rgb(251, 244, 109), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(141, 186, 81), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(74, 159, 245), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(255, 153, 140), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(255, 149, 0), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(0, 234, 211), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(167, 153, 183), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(255, 210, 113), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(119, 217, 112), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(95, 129, 228), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(235, 146, 190), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(198, 139, 89), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(200, 149, 149), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(196, 182, 182), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(255, 190, 15), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(192, 226, 24), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(153, 140, 235), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(206, 31, 107), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(251, 54, 64), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(194, 255, 217), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(255, 219, 197), '', '', inline='c1', group = 'Display', display = display.none),
     input.color(color.rgb(121, 180, 183), '', '', inline='c1', group = 'Display', display = display.none)
 )
showPatternLabel = input.bool(true, 'Pattern Label', inline='pl1', group = 'Display', display = display.none)
patternLabelSize = input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline='pl1', group = 'Display', display = display.none,
                     tooltip = 'Option to display Pattern Label and select the size')

showPivotLabels = input.bool(true, 'Pivot Labels ', inline='pl2', group = 'Display', display = display.none, tooltip = 'Option to display pivot labels and select the size')
pivotLabelSize = input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline='pl2', group = 'Display', display = display.none)

showZigzag = input.bool(true, 'Zigzag', inline='z', group = 'Display', display = display.none)
zigzagColor = input.color(color.blue, '', inline='z', group = 'Display', display = display.none, tooltip = 'Option to display zigzag within pattern and the default zigzag line color')

deleteOldPatterns = input.bool(true, 'Max Patterns', inline='do', group = 'Display', display = display.none)
maxPatterns = input.int(20, '', minval=1, step=5, inline = 'do', group = 'Display', display = display.none, tooltip = 'If selected, only last N patterns will be preserved on the chart.')

errorRatio = errorThresold/100
flatRatio = flatThreshold/100
showLabel = true
offset = 0

type Scanner
    bool enabled
    string ticker
    string timeframe
    p.ScanProperties sProperties
    p.DrawingProperties dProperties
    array<p.Pattern> patterns
    array<zg.Zigzag> zigzags

method getZigzagAndPattern(Scanner this, int length, int depth, array<o.OHLC> ohlcArray, int offset=0)=>
    var zg.Zigzag zigzag = zg.Zigzag.new(length, depth, 0)
    var map<int, int> lastDBar = map.new<int, int>()
    zigzag.calculate(array.from(highSource, lowSource))

    var validPatterns = 0
    mlzigzag = zigzag
    if(zigzag.flags.newPivot)
        while(mlzigzag.zigzagPivots.size() >= 6+offset)
            lastBar = mlzigzag.zigzagPivots.first().point.index
            lastDir = int(math.sign(mlzigzag.zigzagPivots.first().dir))
            if(lastDBar.contains(mlzigzag.level)? lastDBar.get(mlzigzag.level) < lastBar : true)
                lastDBar.put(mlzigzag.level, lastBar)
                [valid, currentPattern] = mlzigzag.find(this.sProperties, this.dProperties, this.patterns, ohlcArray)
                if(valid)
                    validPatterns+=1
                    // currentPattern.draw()
                    this.patterns.push(currentPattern, maxPatterns)
                    alert('New Pattern Alert')
            else
                break
            mlzigzag := mlzigzag.nextlevel()
    true

method increment(array<int> counts, p.Pattern pattern)=>
    counts.set(pattern.patternType, counts.get(pattern.patternType)+1)

method scan(Scanner this)=>
    var array<o.OHLC> ohlcArray = array.new<o.OHLC>()
    var array<p.Pattern> patterns = array.new<p.Pattern>()
    ohlcArray.push(o.OHLC.new(openSource, highSource, lowSource, closeSource))
    if(useZigzag1)
        this.getZigzagAndPattern(zigzagLength1, depth1, ohlcArray)
    if(useZigzag2)
        this.getZigzagAndPattern(zigzagLength2, depth2, ohlcArray)
    if(useZigzag3)
        this.getZigzagAndPattern(zigzagLength3, depth3, ohlcArray)
    if(useZigzag4)
        this.getZigzagAndPattern(zigzagLength4, depth4, ohlcArray)

var scanner = Scanner.new(true, "", "", 
             p.ScanProperties.new(
                     offset, numberOfPivots, errorRatio, flatRatio, checkBarRatio, barRatioLimit, avoidOverlap, 
                     allowedPatterns=allowedPatterns, allowedLastPivotDirections= allowedLastPivotDirections, themeColors = useCustomColors? customColorsArray : theme.getColors()),
             p.DrawingProperties.new(
                     patternLineWidth, showZigzag, 1, zigzagColor, showPatternLabel, patternLabelSize, 
                     showPivotLabels, pivotLabelSize, deleteOnPop = deleteOldPatterns),
             array.new<p.Pattern>())

if(barstate.isconfirmed or repaint)
    scanner.scan()

array<p.Pattern> currentPatterns = array.new<p.Pattern>()

array<int> counts = array.new<int>(14, 0)

if(barstate.islast or barstate.islastconfirmedhistory)
    for i= scanner.patterns.size() > 0? scanner.patterns.size()-1 : na to 0
        pattern = scanner.patterns.get(i)
        firstPoint = pattern.points.first()
        lastPoint = pattern.points.last()
        barsToLookBack = screeningMethod == ScreeningMethod.Fixed? fixedScreenerBars : math.ceil((lastPoint.index-firstPoint.index)*relativeScreenerPercent/100)
        if(lastPoint.index > bar_index-barsToLookBack)
            currentPatterns.push(pattern)
            pattern.draw()
            counts.increment(pattern)
        else
            scanner.patterns.remove(i)

plot(currentPatterns.size(), "Current Patterns", color.aqua, display = display.data_window)
plot(counts.get(1), "Uptrend Channel", color.aqua, display = display.data_window)
plot(counts.get(2), "Downtrend Channel", color.aqua, display = display.data_window)
plot(counts.get(3), "Ranging Channel", color.aqua, display = display.data_window)
plot(counts.get(4), "Expanding Rising Wedge", color.aqua, display = display.data_window)
plot(counts.get(5), "Expanding Falling Wedge", color.aqua, display = display.data_window)
plot(counts.get(6), "Expanding Triangle", color.aqua, display = display.data_window)
plot(counts.get(7), "Expanding Rising Triangle", color.aqua, display = display.data_window)
plot(counts.get(8), "Expanding Falling Triangle", color.aqua, display = display.data_window)
plot(counts.get(9), "Contracting Rising Wedge", color.aqua, display = display.data_window)
plot(counts.get(10), "Contracting Falling Wedge", color.aqua, display = display.data_window)
plot(counts.get(11), "Converging Triangle", color.aqua, display = display.data_window)
plot(counts.get(12), "Converging Falling Triange", color.aqua, display = display.data_window)
plot(counts.get(13), "Converging Rising Triangle", color.aqua, display = display.data_window)
plot(counts.get(4)+counts.get(9), "Rising Wedge", color.aqua, display = display.data_window)
plot(counts.get(5)+counts.get(10), "Falling Wedge", color.aqua, display = display.data_window)
plot(counts.get(9)+counts.get(10), "Contracting Wedge", color.aqua, display = display.data_window)
plot(counts.get(4)+counts.get(5), "Expanding Wedge", color.aqua, display = display.data_window)
plot(counts.get(4)+counts.get(5)+counts.get(9)+counts.get(10), "Wedge", color.aqua, display = display.data_window)
plot(counts.get(7)+counts.get(13), "Rising Triangle", color.aqua, display = display.data_window)
plot(counts.get(8)+counts.get(12), "Falling Triangle", color.aqua, display = display.data_window)
plot(counts.get(11)+counts.get(12)+counts.get(13), "Contracting Triangle", color.aqua, display = display.data_window)
plot(counts.get(6)+counts.get(7)+counts.get(8), "Expanding Triangle", color.aqua, display = display.data_window)
plot(counts.get(6)+counts.get(7)+counts.get(8) + 
         counts.get(11)+counts.get(12)+counts.get(13), "Triangle", color.aqua, display = display.data_window)

if(showWarning)
    warningTable = table.new(position.middle_center, 1, 2, color.new(color.aqua, 60), chart.fg_color, 1, chart.fg_color, 1)
    warningTable.cell(0, 0, 'Note', text_color=chart.fg_color, bgcolor = color.new(color.maroon, 30), text_size=size.large, text_formatting = text.format_bold)
    warningTable.cell(0, 1, 'The script is built to be used with pine-screener and not as indicator on chart.'+
                 '\nThe equivalent indicator is a different script - Auto Chart Patterns [Trendoscope®].'+
                 '\nPlease check the how-to video and related scripts in the linked ideas', 
                  text_color=chart.fg_color, text_size=size.large, text_halign=text.align_left, text_font_family = font.family_monospace)
````
