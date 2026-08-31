<!-- tradingview-pine-id: PUB;d445c5b82a794a0095040c4910e63bc0 -->
<!-- tradingviewscripts-format: 1 -->
# ABC on Recursive Zigzag [Trendoscope]

Source: https://www.tradingview.com/script/RGNBIIcD-ABC-on-Recursive-Zigzag-Trendoscope/

## Description

There are several implementations of ABC pattern in tradingview and pine script. However, we have made this indicator to provide users additional quantifiable information along with flexibility to experiment and develop their own strategy based on the patterns.

🎲 Highlights of this indicator over other ABC implementations are:

[*] Implementation is based on recursive multi level zigzag allows bigger as well as smaller patterns to be identified
[*] Allows users to set their trading rules with respect to entry, target and stop ratios, experiment and build their own strategy based on the ABC pattern.
[*] Back test summary including win ratio and risk reward will help users understand the profitability based on different settings being used.

🎲 Concept of ABC Pattern
The ABC pattern, also known as the "Corrective Wave" or "Zigzag Pattern," is a fundamental concept in Elliott Wave Theory, which is widely used in technical analysis to identify and predict price movements in financial markets. 

The ABC pattern is a three-wave corrective pattern that typically occurs within the context of a larger impulse or trending wave. It consists of two smaller waves in the opposite direction (A and C) separated by a corrective wave (B). These waves are labeled alphabetically and represent price movements.

Wave A (Impulse Wave): Wave A is the first leg of the ABC pattern and is characterized by a strong price move in the opposite direction of the prevailing trend. It is often driven by a fundamental or sentiment-driven event that temporarily disrupts the trend.

Wave B (Corrective Wave): Wave B is the corrective wave that follows Wave A. It represents a partial retracement of Wave A's price movement. Wave B can take various forms, such as a simple correction or a complex correction (e.g., a triangle or a flat correction). It typically doesn't retrace the entire length of Wave A.

Wave C (Impulse Wave): Wave C is the final leg of the ABC pattern and is characterized by a strong price move in the same direction as the prevailing trend. It often surpasses the starting point of Wave A and confirms the resumption of the larger trend.

🎲 Indicator Components

Upon loading the indicator on the chart, we can observe the following components on the chart.

[*] Pattern Drawings is the graphical representation of present patterns. Please note that it is not necessary for patterns to be there on the chart all the time. Patterns will appear on the chart when price makes the patterns.
[*] Trade Box is the box representing trade signals of the pattern. These trade levels are generated based on the user settings.
[*] Summary Table is the back test summary containing details of historical pattern performance including Win Ratio and Risk Reward.

https://www.tradingview.com/x/NDy11YFT/

🎲 Indicator Settings

Details of each user settings are provided in the tooltips. Below is the snapshot of it.
https://www.tradingview.com/x/Yeewh2zC/

🎲 Alerts

Basic level of alerts are built in the script using alert function to highlight the following conditions:

[*] New ABC Pattern
[*] Updates to existing Pattern

Both conditions will alert simple text messages. There is not much customization provided as part of this indicator. We will consider providing more options in future versions based on the interest and demand shown by users.

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
import Trendoscope/Drawing/2 as dr
import Trendoscope/ZigzagLite/3 as zg
import Trendoscope/utils/1 as ut
import Trendoscope/FibRatios/1 as fibs

indicator('ABC on Recursive Zigzag [Trendoscope]', 'ABC-RZ[Trendoscope]', overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)
theme = input.enum(ut.Theme.DARK, title = 'Theme', group = 'Generic Settings', tooltip = 'Chart theme settings. Line and label colors are generted based on the theme settings. If dark theme is selected, ' + 'lighter colors are used and if light theme is selected, darker colors are used.', display = display.none)

zigzagLength = input.int(13, step = 5, minval = 3, title = 'Length', group = 'Zigzag', tooltip = 'Zigzag length for level 0 zigzag', display = display.none)
depth = input.int(200, 'Depth', step = 25, maxval = 500, group = 'Zigzag', tooltip = 'Zigzag depth refers to max number of pivots to show on chart', display = display.none)
minimumZigZagLevel = input.int(0, 'Minimum Zigzag Level', group = 'Zigzag', minval = 0, tooltip = 'Minimum zigzag level to consider for pattern scanning', display = display.none)

indicators = matrix.new<float>()
indicatorNames = array.new<string>()

base = input.string('ABC Extension', 'Base', ['ABC Extension', 'BC Retracement'], 'Base on which entry, stop and target are calculated', group = 'ABC', display = display.none)
entryRatio = input.float(0.3, 'Entry Ratio', group = 'ABC', minval = 0.1, step = 0.1, display = display.none, tooltip = 'Entry ratio for the calculation of entry level')
targetRatio = input.float(1.0, 'Target Ratio', group = 'ABC', display = display.none, tooltip = 'Target Ratio for the calculation of target level')
stopRatio = input.float(0.0, 'Stop Ratio', group = 'ABC', maxval = 0.0, step = 0.1, display = display.none, tooltip = 'Stop Ratio for the calculation of stop level')
logScale = input.bool(false, 'Log Scale', group = 'ABC', display = display.none, tooltip = 'Use log scale for scanning and targets')
useClosePricesForEntry = input.bool(true, 'Entry', group = 'Use Close Prices', display = display.none, tooltip = 'Use close prices for tracking', inline = 'ucp')
useClosePricesForTarget = input.bool(true, 'Target', group = 'Use Close Prices', display = display.none, tooltip = 'Use close prices for tracking', inline = 'ucp')
useClosePricesForStop = input.bool(true, 'Stop', group = 'Use Close Prices', display = display.none, tooltip = 'Use close prices for tracking', inline = 'ucp')
useClosePricesForRetest = input.bool(true, 'Retest', group = 'Use Close Prices', display = display.none, tooltip = 'Use close prices for tracking', inline = 'ucp')

tradeConditionTooltip = 'any - no filter\ntrend - Both A and B pivots in the direction of trend. Example, HH, and HL for long signal and LH and LL for short signal\n' + 'reverse - Both A and B pivots in the opposite direction of trend. Example, LH, and LL for long signal and HH and HL for short signal\n' + 'contracting - Consider only if both A and B pivots are either LH or HL\nexpanding - Consider only if both A and B pivots are either HH or LL'

tradeCondition = input.string('any', 'Trade Condition', ['any', 'trend', 'reverse', 'contracting', 'expanding'], group = 'ABC', display = display.none, tooltip = tradeConditionTooltip)

condition = tradeCondition == 'any' ? 0 : tradeCondition == 'trend' ? 1 : tradeCondition == 'reverse' ? 2 : tradeCondition == 'contracting' ? 3 : 4

baseVal = base == 'ABC Extension' ? 1 : 2


var zg.Zigzag zigzag = zg.Zigzag.new(zigzagLength, depth)
zigzag.calculate(array.from(high, low))

type ABCProperties
	int base = 1
	float entryRatio = 0.23
	float targetRatio = 1.0
	float stopRatio = -0.1
	bool logScale = false
	bool useClosePricesForEntry = true
	bool useClosePricesForTarget = false
	bool useClosePricesForStop = true
	bool useClosePricesForRetest = false
	int condition = 0

type ABCDrawing
	dr.Line ab
	dr.Line bc
	dr.Line ac
	dr.Label a
	dr.Label b
	dr.Label c
	dr.Label abcRatio
	dr.Box entryBox
	dr.Box targetBox

type ABC
	int id
	int direction
	zg.Pivot a
	zg.Pivot b
	zg.Pivot c
	color patternColor
	ABCProperties properties
	float entryPrice
	float stopPrice
	float targetPrice
	int status = 0
	ABCDrawing drawing

initialiseCounts(int numberOfStatus) =>
    countMap = map.new<int, int>()
    for i = 0 to numberOfStatus - 1 by 1
        countMap.put(i, 0)
    countMap

var array<ABC> abcdPatterns = array.new<ABC>()
var array<ABC> oldPatterns = array.new<ABC>()

var map<int, int> bullishCounts = initialiseCounts(3)
var map<int, int> bearishCounts = initialiseCounts(3)

var int bullishRetests = 0
var int bearishRetests = 0

method calculateTargets(ABC this) =>
    this.entryPrice := this.properties.base == 1 ? fibs.extension(this.a.point.price, this.b.point.price, this.c.point.price, this.properties.entryRatio, this.properties.logScale) : fibs.retracement(this.b.point.price, this.c.point.price, this.properties.entryRatio, this.properties.logScale)

    this.targetPrice := this.properties.base == 1 ? fibs.extension(this.a.point.price, this.b.point.price, this.c.point.price, this.properties.targetRatio, this.properties.logScale) : fibs.retracement(this.b.point.price, this.c.point.price, this.properties.targetRatio, this.properties.logScale)

    this.stopPrice := this.properties.base == 1 ? fibs.extension(this.a.point.price, this.b.point.price, this.c.point.price, this.properties.stopRatio, this.properties.logScale) : fibs.retracement(this.b.point.price, this.c.point.price, this.properties.stopRatio, this.properties.logScale)
    this

method withinEntry(ABC this) =>
    dir = this.c.point.price > this.b.point.price ? -1 : 1
    close * dir < this.entryPrice * dir

method delete(ABCDrawing this) =>
    if not na(this)
        this.ab.delete()
        this.bc.delete()
        this.ac.delete()
        this.abcRatio.delete()
        this.a.delete()
        this.b.delete()
        this.c.delete()
        this.entryBox.delete()
        this.targetBox.delete()
    else
        log.info('this should not be na')
    this

method draw(ABCDrawing this) =>
    if not na(this)
        this.ab.draw()
        this.bc.draw()
        this.ac.draw()
        this.abcRatio.draw()
        this.a.draw()
        this.b.draw()
        this.c.draw()
        this.entryBox.draw()
        this.targetBox.draw()
    else
        log.info('this should not be na')
    this

method draw(ABC this) =>
    this.drawing.draw()
    this

method deleteDrawing(ABC this) =>
    if not na(this.drawing)
        this.drawing.delete()
        this.drawing := na
        this.drawing
    this

method createDrawing(ABC this) =>
    if not na(this.drawing)
        this.drawing.delete()

    dr.LineProperties patternLineProps = dr.LineProperties.new(color = this.patternColor, width = 1, style = line.style_solid)
    ab = this.a.point.createLine(this.b.point, patternLineProps)
    bc = this.b.point.createLine(this.c.point, patternLineProps)
    dr.LineProperties angleLineProps = dr.LineProperties.new(color = this.patternColor, width = 0, style = line.style_dotted)
    ac = dr.Line.new(this.a.point, this.c.point, angleLineProps)
    acMidPoint = chart.point.new((this.a.point.time + this.c.point.time) / 2, (this.a.point.index + this.c.point.index) / 2, (this.a.point.price + this.c.point.price) / 2)
    abcRatioValue = fibs.retracementRatio(this.a.point.price, this.b.point.price, this.c.point.price)
    ratioLabelProperties = dr.LabelProperties.new(yloc = yloc.price, textcolor = this.patternColor, style = label.style_none)
    abcRatio = dr.Label.new(acMidPoint, str.tostring(abcRatioValue), properties = ratioLabelProperties)
    pivotLabelPropertiesAC = dr.LabelProperties.new(yloc = this.a.point.price < this.b.point.price ? yloc.belowbar : yloc.abovebar, textcolor = this.patternColor)
    pivotLabelPropertiesBD = dr.LabelProperties.new(yloc = this.a.point.price > this.b.point.price ? yloc.belowbar : yloc.abovebar, textcolor = this.patternColor)
    a = dr.Label.new(this.a.point, 'A', properties = pivotLabelPropertiesAC)
    b = dr.Label.new(this.b.point, 'B', properties = pivotLabelPropertiesBD)
    c = dr.Label.new(this.c.point, 'C', properties = pivotLabelPropertiesAC)

    entryPoint = chart.point.new(this.c.point.time, this.c.point.index, this.entryPrice)
    barDiff = math.min((this.c.point.index - this.a.point.index) / 2, 490)

    entryBoxEndPoint = chart.point.from_index(this.c.point.index + barDiff, this.stopPrice)
    targetBoxEndPoint = chart.point.from_index(this.c.point.index + barDiff, this.targetPrice)

    boxPropertiesEntry = dr.BoxProperties.new(this.patternColor, color.new(color.red, 90))
    boxPropertiesTarget = dr.BoxProperties.new(this.patternColor, color.new(color.green, 90))
    entryBox = dr.Box.new(entryPoint, entryBoxEndPoint, boxPropertiesEntry)
    targetBox = dr.Box.new(entryPoint, targetBoxEndPoint, boxPropertiesTarget)
    this.drawing := ABCDrawing.new(ab, bc, ac, a, b, c, abcRatio, entryBox, targetBox)
    this


method update(ABC this, zg.Pivot c) =>
    this.c := c
    alert('ABC Pattern Coordinates Updated')
    this.calculateTargets()

    if this.withinEntry()
        this.deleteDrawing().createDrawing().draw()
    this

method createAbc(zg.Zigzag this, ABCProperties props, color patternColor) =>
    var id = 1
    c = this.zigzagPivots.get(0)
    b = this.zigzagPivots.get(1)
    a = this.zigzagPivots.get(2)
    direction = b.point.price > c.point.price ? 1 : -1
    abc = ABC.new(id, direction, a, b, c, patternColor, props)
    id := id + 1
    abc

method scanAbc(zg.Zigzag this, ABCProperties props) =>
    isAbc = false

    if this.zigzagPivots.size() >= 4
        c = this.zigzagPivots.get(0)
        b = this.zigzagPivots.get(1)
        a = this.zigzagPivots.get(2)
        aDir = math.abs(a.dir)
        bDir = math.abs(b.dir)
        conditionInLine = props.condition == 0 or props.condition == 1 and aDir == 1 and bDir == 2 or props.condition == 2 and aDir == 2 and bDir == 1 or props.condition == 3 and aDir == 1 and bDir == 1 or props.condition == 4 and aDir == 2 and bDir == 2
        ratioInLine = c.ratio >= 0.618 and c.ratio <= 0.786
        if ratioInLine and conditionInLine
            existingPattern = false
            isAbc := true
            for p in abcdPatterns
                existingPattern := p.a.point.price == a.point.price and p.b.point.price == b.point.price
                if existingPattern
                    if p.c.point.index > c.point.index and p.status == 0
                        p.update(c)

                    isAbc := false
                    break
    isAbc

method record(ABC pattern) =>
    countMapToSet = pattern.direction > 0 ? bullishCounts : bearishCounts
    countMapToSet.put(pattern.status, countMapToSet.get(pattern.status) + 1)

method removePattern(array<ABC> patterns, int index) =>
    pattern = patterns.remove(index)
    pattern.deleteDrawing()
    pattern.record()

method traverse(array<ABC> patterns) =>
    for i = patterns.size() > 0 ? patterns.size() - 1 : na to 0 by 1
        pattern = patterns.get(i)
        baseTarget = pattern.properties.useClosePricesForTarget ? close : pattern.direction > 0 ? high : low
        baseStop = pattern.properties.useClosePricesForStop ? close : pattern.direction > 0 ? low : high
        baseEntry = pattern.properties.useClosePricesForEntry ? close : pattern.direction > 0 ? high : low
        baseValueRetest = pattern.properties.useClosePricesForRetest ? close : pattern.direction > 0 ? low : high
        baseInvalidation = close
        newStatus = baseTarget * pattern.direction >= pattern.targetPrice * pattern.direction ? 2 : baseEntry * pattern.direction >= pattern.entryPrice * pattern.direction ? 1 : pattern.status
        retested = pattern.status == 1 and baseValueRetest <= pattern.entryPrice

        newStatus := math.max(pattern.status, newStatus)
        closed = newStatus > 0 and baseStop * pattern.direction <= pattern.stopPrice * pattern.direction or newStatus == 0 and baseInvalidation * pattern.direction <= pattern.stopPrice * pattern.direction or pattern.status == 2
        increment = newStatus >= pattern.status
        pattern.status := newStatus
        if closed
            patterns.removePattern(i)

var properties = ABCProperties.new(baseVal, entryRatio, targetRatio, stopRatio, logScale, useClosePricesForEntry, useClosePricesForTarget, useClosePricesForStop, useClosePricesForRetest, condition)
var themeColors = theme.getColors()

abcdPatterns.traverse()
oldPatterns.traverse()

if zigzag.flags.newPivot
    mlzigzag = zigzag
    while mlzigzag.zigzagPivots.size() >= 3
        if mlzigzag.level >= minimumZigZagLevel
            isAbcd = mlzigzag.scanAbc(properties)
            if isAbcd
                patternColor = themeColors.shift()
                alert('New ABC Pattern Detected')
                pattern = mlzigzag.createAbc(properties, patternColor).calculateTargets()
                if pattern.withinEntry()
                    pattern.createDrawing().draw()
                    abcdPatterns.push(pattern)
                    while abcdPatterns.size() > 10
                        last = abcdPatterns.shift()
                        oldPatterns.push(last)
                        last.deleteDrawing()

                themeColors.push(patternColor)
        mlzigzag := mlzigzag.nextlevel()
        mlzigzag

while abcdPatterns.size() < 10 and oldPatterns.size() > 0
    restoreOld = oldPatterns.pop()
    abcdPatterns.unshift(restoreOld)
    restoreOld.draw()

if barstate.islast
    var closedStatsTable = table.new(position.top_right, 6, 3, border_color = chart.bg_color)
    closedStatsTable.clear(0, 0, 5, 2)
    closedStatsTable.cell(0, 0, 'Direction\\Status', text_color = color.white, bgcolor = color.maroon)
    closedStatsTable.cell(1, 0, 'Invalid', text_color = color.white, bgcolor = color.maroon)
    closedStatsTable.cell(2, 0, 'Stopped', text_color = color.white, bgcolor = color.maroon)
    closedStatsTable.cell(3, 0, 'Complete', text_color = color.white, bgcolor = color.maroon)
    closedStatsTable.cell(4, 0, 'Win Ratio', text_color = color.white, bgcolor = color.maroon)
    closedStatsTable.cell(5, 0, 'Risk Reward', text_color = color.white, bgcolor = color.maroon)
    closedStatsTable.cell(0, 1, 'Bullish', text_color = color.white, bgcolor = color.new(color.green, 50))
    closedStatsTable.cell(0, 2, 'Bearish', text_color = color.white, bgcolor = color.new(color.red, 50))

    bullishInvalid = bullishCounts.get(0)
    bullishStopped = bullishCounts.get(1)
    bullishCompleted = bullishCounts.get(2)
    riskReward = (targetRatio - entryRatio) / (entryRatio - stopRatio)
    bullishBgColor = color.new(color.green, 70)
    closedStatsTable.cell(1, 1, str.tostring(bullishInvalid), text_color = color.white, bgcolor = bullishBgColor)
    closedStatsTable.cell(2, 1, str.tostring(bullishStopped), text_color = color.white, bgcolor = bullishBgColor)
    closedStatsTable.cell(3, 1, str.tostring(bullishCompleted), text_color = color.white, bgcolor = bullishBgColor)
    closedStatsTable.cell(4, 1, str.tostring(bullishCompleted * 100 / (bullishCompleted + bullishStopped), format.percent), text_color = color.white, bgcolor = bullishBgColor)
    closedStatsTable.cell(5, 1, str.tostring(riskReward, '#.##'), text_color = color.white, bgcolor = bullishBgColor)

    bearishInvalid = bearishCounts.get(0)
    bearishStopped = bearishCounts.get(1)
    bearishCompleted = bearishCounts.get(2)
    bearishBgColor = color.new(color.red, 70)
    closedStatsTable.cell(1, 2, str.tostring(bearishInvalid), text_color = color.white, bgcolor = bearishBgColor)
    closedStatsTable.cell(2, 2, str.tostring(bearishStopped), text_color = color.white, bgcolor = bearishBgColor)
    closedStatsTable.cell(3, 2, str.tostring(bearishCompleted), text_color = color.white, bgcolor = bearishBgColor)
    closedStatsTable.cell(4, 2, str.tostring(bearishCompleted * 100 / (bearishCompleted + bearishStopped), format.percent), text_color = color.white, bgcolor = bearishBgColor)
    closedStatsTable.cell(5, 2, str.tostring(riskReward, '#.##'), text_color = color.white, bgcolor = bearishBgColor)
````
