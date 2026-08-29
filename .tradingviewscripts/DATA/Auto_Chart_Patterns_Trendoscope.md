<!-- tradingview-pine-id: PUB;257dbd8cadff432c82aeb9a89ab05dc9 -->
<!-- tradingviewscripts-format: 1 -->
# Auto Chart Patterns [Trendoscope®]

Source: https://www.tradingview.com/script/WZ8B1FIW-Auto-Chart-Patterns-Trendoscope/

## Description

🎲 Introducing our most comprehensive automatic chart pattern recognition indicator.

Last week, we published an idea on how to algorithmically identify and classify chart patterns. 
https://www.tradingview.com/chart/US100/oDKIENQa-Algorithmic-Identification-and-Classification-of-Chart-Patterns/

This indicator is nothing but the initial implementation of the idea. Whatever we explained in that publication that users can do manually to identify and classify the pattern, this indicator will do it for them.

🎲 Process of identifying the patterns.

The bulk of the logic is implemented as part of the library - [chartpatterns](https://www.tradingview.com/script/OuVJr45r-chartpatterns/). The indicator is a shell that captures the user inputs and makes use of the library to deliver the outcome. 

🎯 Here is the list of steps executed to identify the patterns on the chart.

[*] Derive multi level recursive zigzag for multiple base zigzag length and depth combinations.
[*] For each zigzag and level, check the last 5 pivots or 6 pivots (based on the input setting) for possibility of valid trend line pairs.
[*] If there is a valid trend line pair, then there is pattern.

🎯 Rules for identifying the valid trend line pairs

[*] There should be at least two trend lines that does not intersect between the starting and ending pivots.
[*] The upper trend line should touch all the pivot highs of the last 5 or 6 pivots considered for scanning the patterns
[*] The lower trend line should touch all the pivot lows of the last 5 or 6 pivots considered for scanning the patterns.
[*] None of the candles from starting pivot to ending pivot should fall outside the trend lines (above upper trend line and below lower trend line)

The existence of a valid trend line pair signifies the existence of pattern. What type of pattern it is, to identify that we need to go through the classification rules.

🎲 Process of classification of the patterns.

We need to gather the following information before we classify the pattern.

[*] Direction of upper trend line - rising, falling or flat
[*] Direction of lower trend line - rising, falling or flat
[*] Characteristics of trend line pair - converging, expanding, parallel

🎯 Broader Classifications
Broader classification would include the following types.

🚩 Classification Based on Geometrical Shapes
This includes

[*] Wedges - both trend lines are moving in the same direction. But, the trend lines are either converging or diverging and not parallel to each other.
[*] Triangles - trend lines are moving in different directions. Naturally, they are either converging or diverging.
[*] Channels - Both trend lines are moving in the same direction, and they are parallel to each other within the limits of error.

🚩 Classification Based on Pattern Direction
This includes

[*] Ascending/Rising Patterns - No trend line is moving in the downward direction and at least one trend line is moving upwards
[*] Descending/Falling Patterns - No trend line is moving in the upward direction, and at least one trend line is moving downwards.
[*] Flat - Both Trend Lines are Flat
[*] Bi-Directional - Both trend lines are moving in opposite direction and none of them is flat.

🚩 Classification Based on Formation Dynamics
This includes

[*] Converging Patterns - Trend Lines are converging towards each other
[*] Diverging Patterns - Trend Lines are diverging from each other
[*] Parallel Patterns - Trend Lines are parallel to each others

🎯 Individual Pattern Types
Now we have broader classifications. Let's go through in detail to find out fine-grained classification of each individual patterns.

🚩 Ascending/Uptrend Channel
This pattern belongs to the broader classifications - Ascending Patterns, Parallel Patterns and Channels. The rules for the Ascending/Uptrend Channel pattern are as below

[*] Both trend lines are rising
[*] Trend lines are parallel to each other

https://www.tradingview.com/x/botk5Hzj

🚩 Descending/Downtrend Channel
This pattern belongs to the broader classifications - Descending Patterns, Parallel Patterns and Channels. The rules for the Descending/Downtrend Channel pattern are as below

[*] Both trend lines are falling
[*] Trend lines are parallel to each other

https://www.tradingview.com/x/Um1VYOS3

🚩 Ranging Channel
This pattern belongs to the broader classifications - Flat Patterns, Parallel Patterns and Channels. The rules for the Ranging Channel pattern are as below

[*] Both trend lines are flat
[*] Trend lines are parallel to each other

https://www.tradingview.com/x/fmJk8olo

🚩 Rising Wedge - Expanding
This pattern belongs to the broader classifications - Rising Patterns, Diverging Patterns and Wedges. The rules for the Expanding Rising Wedge pattern are as below

[*] Both trend lines are rising
[*] Trend Lines are diverging.

https://www.tradingview.com/x/biIGt77G

🚩 Rising Wedge - Contracting
This pattern belongs to the broader classifications - Rising Patterns, Converging Patterns and Wedges. The rules for the Contracting Rising Wedge pattern are as below

[*] Both trend lines are rising
[*] Trend Lines are converging.

https://www.tradingview.com/x/8bm2MW3Q

🚩 Falling Wedge - Expanding
This pattern belongs to the broader classifications - Falling Patterns, Diverging Patterns and Wedges. The rules for the Expanding Falling Wedge pattern are as below

[*] Both trend lines are falling
[*] Trend Lines are diverging.

https://www.tradingview.com/x/bgG25U9u

🚩 Falling Wedge - Contracting
This pattern belongs to the broader classifications - Falling Patterns, Converging Patterns and Wedges. The rules for the Converging Falling Wedge are as below

[*] Both trend lines are falling
[*] Trend Lines are converging.

https://www.tradingview.com/x/CAuBxNzZ

🚩 Rising/Ascending Triangle - Expanding
This pattern belongs to the broader classifications - Rising Patterns, Diverging Patterns and Triangles. The rules for the Expanding Ascending Triangle pattern are as below

[*] The upper trend line is rising
[*] The lower trend line is flat
[*] Naturally, the trend lines are diverging from each other

https://www.tradingview.com/x/lV4P5N6M

🚩 Rising/Ascending Triangle -  Contracting
This pattern belongs to the broader classifications - Rising Patterns, Converging Patterns and Triangles. The rules for the Contracting Ascending Triangle pattern are as below

[*] The upper trend line is flat
[*] The lower trend line is rising
[*] Naturally, the trend lines are converging.

https://www.tradingview.com/x/WVNjtW3a

🚩 Falling/Descending Triangle - Expanding
This pattern belongs to the broader classifications - Falling Patterns, Diverging Patterns and Triangles. The rules for the Expanding Descending Triangle pattern are as below

[*] The upper trend line is flat
[*] The lower trend line is falling
[*] Naturally, the trend lines are diverging from each other

https://www.tradingview.com/x/dT23FxTh

🚩 Falling/Descending Triangle -  Contracting
This pattern belongs to the broader classifications - Falling Patterns, Converging Patterns and Triangles. The rules for the Contracting Descending Triangle pattern are as below

[*] The upper trend line is falling
[*] The lower trend line is flat
[*] Naturally, the trend lines are converging.

https://www.tradingview.com/x/wehBQlQi

🚩 Converging Triangle
This pattern belongs to the broader classifications - Bi-Directional Patterns, Converging Patterns and Triangles. The rules for the Converging Triangle pattern are as below

[*] The upper trend line is falling
[*] The lower trend line is rising
[*] Naturally, the trend lines are converging.

https://www.tradingview.com/x/4lhUD1An

🚩 Diverging Triangle
This pattern belongs to the broader classifications - Bi-Directional Patterns, Diverging Patterns and Triangles. The rules for the Diverging Triangle pattern are as below

[*] The upper trend line is rising
[*] The lower trend line is falling
[*] Naturally, the trend lines are diverging from each other.

https://www.tradingview.com/x/cGmhW2N0

🎲 Indicator Settings - Auto Chart Patterns

🎯 Zigzag Settings
Zigzag settings allow users to select the number of zigzag combinations to be used for pattern scanning, and also allows users to set zigzag length and depth combinations.

https://www.tradingview.com/x/eyaxJvlW/

🎯 Scanning Settings

[*] Number of Pivots - This can be either 5 or 6. Represents the number of pivots used for identification of patterns.
[*] Error Threshold - Error threshold used for initial trend line validation.
[*] Flat Threshold - Flat angle threshold is used to identify the slope and direction of trend lines.
[*] Last Pivot Direction - Filters patterns based on the last pivot direction. The values can be up, down, both, or custom. When custom is selected, then the individual pattern specific last pivot direction setting is used instead of the generic one.
[*] Verify Bar Ratio - Provides option to ignore extreme patterns where the ratios of zigzag lines are not proportionate to each other. 
[*] Avoid Overlap - When selected, the patterns that overlap with existing patterns will be ignored while scanning. Meaning, if the new pattern starting point falls between the start and end of an existing pattern, it will be ignored.

https://www.tradingview.com/x/5YVy121A/

🎯 Group Classification Filters
Allows users to enable disable patterns based on group classifications.

🚩 Geometric Shapes Based Classifications 

[*] Wedges - Rising Wedge Expanding, Falling Wedge Expanding, Rising Wedge Contracting, Falling Wedge Contracting.
[*] Channels - Ascending Channel, Descending Channel, Ranging Channel
[*] Triangles - Converging Triangle, Diverging Triangle, Ascending Triangle Expanding, Descending Triangle Expanding, Ascending Triangle Contrcting and Descending Triangle Contracting

🚩 Direction Based Classifications 

[*] Rising - Rising Wedge Contracting, Rising Wedge Expanding, Ascending Triangle Contracting, Ascending Triangle Expanding and Ascending Channel
[*] Falling -  Falling Wedge Contracting, Falling Wedge Expanding, Descending Triangle Contracting, Descending Triangle Expanding and Descending Channel
[*] Flat/Bi-directional - Ranging Channel, Converging Triangle, Diverging Triangle

🚩 Formation Dynamics Based Classifications 

[*] Expanding - Rising Wedge Expanding, Falling Wedge Expanding, Ascending Triangle Expanding, Descending Triangle Expanding, Diverging Triangle
[*] Contracting - Rising Wedge Contracting, Falling Wedge Contracting, Ascending Triangle Contracting, Descending Triangle Contracting, Converging Triangle
[*] Parallel - Ascending Channel, Descending Channgel and Ranging Channel

https://www.tradingview.com/x/Hsk1exiT/

🎯 Individual Pattern Filters
These settings allow users to enable/disable individual patterns and also set last pivot direction filter individually for each pattern. Individual Last Pivot direction filters are only considered if the main "Last Pivot Direction" filter is set to "custom"

https://www.tradingview.com/x/SLzdlz1n/

🎯 Display Settings
These are the settings that determine the indicator display. The details are provided in the tooltips and are self explanatory.
https://www.tradingview.com/x/wDlllCcq/

🎯 Alerts
A basic alert message is enabled upon detection of new pattern on the chart.

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

indicator("Auto Chart Patterns [Trendoscope®]", "ACP [Trendoscope®]", overlay = true, max_lines_count=500, max_labels_count=500, max_polylines_count = 100, calc_bars_count = 5000)

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
avoidOverlap = input.bool(true, 'Avoid Overlap',  group='Scanning', inline='a', display = display.none)
repaint = input.bool(false, 'Repaint', 'Avoid Overlap - Will not consider the pattern if it starts before the end of an existing pattern\n\n'+
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
                    currentPattern.draw()
                    this.patterns.push(currentPattern, maxPatterns)
                    alert('New Pattern Alert')
            else
                break
            mlzigzag := mlzigzag.nextlevel()
    true

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
````
