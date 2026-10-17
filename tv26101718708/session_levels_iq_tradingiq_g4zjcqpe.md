# Session Levels IQ [TradingIQ]

- url: https://www.tradingview.com/script/g4zjCqpe-Session-Levels-IQ-TradingIQ/
- type: indicator
- pine_id: PUB;b43ebf8bcaed49b68923da64ac8a1d9d
- version: 2.0

## Description

Hello Traders!
🔹[b]Session Levels IQ[/b]

Session Levels IQ is a session-based percentage grid tool designed to map how far price typically travels away from each session open.

Instead of treating a session as a simple open-high-low-close range, this tool builds a [b]structured level framework[/b] around the session open and tracks [i]which distances tend to get reached, how often they get reached, and what price typically does after touching them[/i].

Think of it as a way to study [b]session expansion behavior around the open[/b].
This indicator records historical observations to show what typically happens. 

[i]It’s not a strict probability model, but more of a history book of past behavior.[/i]

[list]
[*]session-based percentage levels built outward from the open
[*]custom session or timeframe-based session construction
[*]hit-rate tracking for each distance level
[*]typical move-after-hit measurement
[*]normal vs unusual level zoning
[*]optional coloring by historical hit rate or move-after-hit
[*]reference price line for inspecting post-hit behavior
[/list]
🔹[b]What the tool shows[/b]

🔸[b]Session-centered level grid[/b]

Each session begins from its opening price, and the script builds levels outward in configurable percentage intervals.

This creates a structured grid above and below the session open, helping you visualize how price expands relative to where the session started.

This helps reveal:
[list]
[*]how far price tends to travel from the session open
[*]which percentage distances are reached most often
[*]how session expansion behaves over time
[/list]
[image]https://www.tradingview.com/x/C5Lpr06i/[/image] 

🔸[b]Historical hit rate by level[/b]

The script tracks whether each percentage level gets touched across completed sessions.
Over time, this produces a running statistical view of how often price reaches specific distances from the open.

This allows you to observe:
[list]
[*]which distances are commonly reached
[*]which distances are less typical
[*]where session expansion begins to become unusual
[/list]
[image]https://www.tradingview.com/x/obEC6mIi/[/image] 

🔸[b]Typical move after hit[/b]

In addition to tracking whether a level is reached, the script also records what price typically does after touching that level.
For levels that get hit, it measures the median follow-through after contact.

This helps show:
[list]
[*]whether certain levels tend to lead to larger continuation
[*]whether some levels produce relatively small follow-through
[*]how post-hit behavior differs across the grid
[/list]

This is not just about whether price gets somewhere.
It is also about [b]what tends to happen once it gets there[/b].

[image]https://www.tradingview.com/x/s9U4f7n1/[/image] 

🔸[b]Normal vs unusual zones[/b]

A configurable normal range defines which distances from the open are considered relatively typical and which fall outside that range.

Levels inside this zone are treated as normal, while levels beyond it are treated as more unusual.

This helps identify:
[list]
[*]common session movement areas
[*]stretched or less typical expansion zones
[*]where price is trading beyond its more ordinary session behavior
[/list]
[image]https://www.tradingview.com/x/asA6mPlt/[/image] 

🔸[b]Level coloring modes[/b]

The script can visually color levels in different ways depending on what you want to study.
Available modes include:
[list]
[*]By Hit Chance
[*]By Move After
[*]None
[/list]

With hit-chance coloring, levels are shaded based on how frequently they are reached.
With move-after coloring, levels are shaded based on the magnitude of the typical move after price touches them.

This makes it easier to spot:
[list]
[*]frequently reached levels
[*]less common extension areas
[*]levels associated with larger follow-through
[/list]
[image]https://www.tradingview.com/x/U4qXNUcg/[/image] 
[image]https://www.tradingview.com/x/ZeelPU9y/[/image] 

🔸[b]Custom session support[/b]

You can build the framework using either:
[list]
[*]a standard session timeframe such as 1D
[*]a fully custom intraday session window
[/list]

This makes the tool flexible for traders who want to study:
[list]
[*]daily opens
[*]custom market sessions
[*]specific trading windows
[/list]
[image]https://www.tradingview.com/x/W5oOPkZk/[/image] 

🔸[b]Whole-number level emphasis[/b]

The script can optionally emphasize whole-number percentage distances so that major percentage thresholds stand out more clearly on the chart.

This can help when you want to quickly distinguish:
[list]
[*]major percentage levels
[*]minor intermediate levels
[*]cleaner structural reference points
[/list]

🔸[b]Reference price line[/b]

An optional draggable reference line lets you place a price directly onto a level and inspect the typical move after that level is hit.

This gives you a visual way to explore:
[list]
[*]how levels behave after being reached
[*]which zones tend to continue further
[*]which levels show more limited follow-through
[/list]

This feature is best viewed as [b]exploratory context[/b], not as a standalone signal.
[image]https://www.tradingview.com/x/toQtlDkk/[/image] 
[image]https://www.tradingview.com/x/7rIVgZ1M/[/image] 

🔸[b]Session range box[/b]

The script can also draw a box around the current session’s working range, helping frame the active expansion area as the session develops.

This gives additional context for:
[list]
[*]the current session’s high-to-low development
[*]where the grid sits relative to the active range
[*]how much of the session’s expansion has already formed
[/list]

🔹[b]How to read it[/b]

Each component provides a different layer of session information:

Session open → anchor point for the grid  
Percentage levels → structured expansion distances from the open  
Hit chance → how often a level gets reached across sessions  
Move after hit → typical follow-through once a level is touched  
Normal range → common vs unusual expansion territory  
Reference line → exploratory view of post-hit behavior  

🔹[b]Why this tool is useful[/b]

It gives you:
[list]
[*]a structured way to study session expansion around the open
[*]historical context for which distances are commonly reached
[*]visibility into which extensions are relatively unusual
[*]insight into what price typically does after contacting a level
[*]a contextual framework for session movement analysis
[/list]

🔹[b]Best use cases[/b]

[list]
[*]studying how far sessions typically expand from the open
[*]identifying common vs stretched extension zones
[*]comparing likely and unlikely distance levels
[*]adding structure to open-based session analysis
[*]exploring how price tends to behave after touching key percentage levels
[/list]

🔹[b]Important note[/b]

This tool is based on historical session behavior and percentage-distance tracking.

That means:
[list]
[*]it is descriptive, not predictive certainty
[*]results depend on the instrument and timeframe being analyzed
[*]smaller level spacing creates more detail, but also more density
[*]typical move-after-hit is informational and should not be treated too literally
[/list]

🔹[b]Inputs you can customize[/b]

The script includes flexible controls such as:
[list]
[*]custom session toggle
[*]custom session time
[*]session timeframe
[*]level spacing percentage
[*]normal range percentage
[*]label detail level
[*]label size
[*]label side
[*]show all stored levels
[*]whole-number level emphasis
[*]session range box display
[*]level coloring mode
[*]reference price line
[/list]
[image]https://www.tradingview.com/x/uzGu1sOI/[/image] 
[b]Closing Notes[/b]

Session Levels IQ is built to shift the focus from simply asking [b]where price is now[/b] to asking [b]how far price has historically tended to travel from a session open, how often those levels are reached, and what usually happens after contact[/b].

It helps turn session expansion into a more [b]structured and measurable framework[/b], so you can view open-based movement with more context than raw candles alone.

Thank you for checking it out and thank you TradingView!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=6
indicator("Session Levels IQ [TradingIQ]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_polylines_count = 100, max_lines_count = 500, calc_bars_count = 75000)

enum levelInfo 

    reg  = "Regular"
    det  = "Detailed"
    min  = "Minimal (Hover Over Label For More Info)"
    none = "None"

onlyShowHistoricalHitChance = input.bool(defval = true, title = "Only Show Hit Chance", tooltip = "This setting controls whether to show all level information, or only the hit chance")
customRangeUse      = input.bool(defval = false, title = "Use Custom Session", tooltip = "Turn this on to define your own session time instead of using the session timeframe below.", inline = "session", group = "Main Settings")
customRange         = input.session(defval = "0000-2345", title = "Custom Session Time", tooltip = "The exact session time used to build the levels when custom session is enabled.", inline = "session", active = customRangeUse, group = "Main Settings")
tf                  = input.timeframe("1D", title = "Session Timeframe", tooltip = "Used to define each session when custom session is turned off. Example: 1D creates a new set of levels each day.", active = not customRangeUse, group = "Main Settings")
step                = input.float(defval = 0.25, minval = 0.05, title = "Level Spacing (%)", tooltip = "Distance between each level as a percent of price. Smaller values create more levels.", step = 0.05, group = "Main Settings") / 100

gradientAno         = input.bool(defval = false, title = "Highlight Unusual Level Area", tooltip = "Shows background color around levels considered outside the normal range.", group = "Style Settings (Important)")
labelSize           = input.string(defval = size.small, title = "Level Label Size", tooltip = "Controls the size of the text shown on level labels.", options = [size.auto, size.tiny, size.small, size.normal, size.large], group = "Style Settings (Important)")
detailedLevelInfo   = input.enum(defval = levelInfo.reg, title = "Label Detail Level", tooltip = "Controls how much information is shown on each level label.", options = [levelInfo.reg, levelInfo.det, levelInfo.min, levelInfo.none], group = "Style Settings (Important)")
grayArea            = input.float(defval = 1, minval = 0, title = "Normal Range (%)", tooltip = "Levels inside this percent range are treated as normal. Levels outside it are treated as unusual.", step = 0.25, group = "Style Settings (Important)")
expandInts          = input.bool(defval = false, title = "Emphasize Whole Number Levels", tooltip = "Makes whole percent levels stand out more visually.", group = "Style Settings (Important)")
showAll             = input.bool(defval = false, title = "Show All Stored Levels", tooltip = "Shows all levels the script has stored, not just the most immediately relevant ones.", group = "Style Settings (Important)")
labelLoc            = input.string(defval = "Right", title = "Label Side", tooltip = "Choose whether labels appear on the right or left side of the levels.", options = ["Right", "Left"], group = "Style Settings (Important)")
showSessionRange    = input.bool(defval = false, title = "Show Session Range Box", tooltip = "Draws a box around the current session's high and low range.", group = "Style Settings (Important)")

coloring            = input.string(defval = "None", title = "Level Color Mode", tooltip = "Choose whether levels are colored by hit chance, move after hit, or not colored by data.", options = ["By Hit Chance", "By Move After", "None"], group = "Level Coloring")
anomalyCol          = input.color(#ff0088, title = "Unusual Level Color", tooltip = "Color used for levels outside the normal range.", group = "Level Coloring")
normCol             = input.color(color.gray, title = "Normal Level Color", tooltip = "Color used for levels inside the normal range.", group = "Level Coloring")
moreTypical         = input.color(defval = color.gray, title = "Higher Hit Chance Color", tooltip = "Color used for levels that are hit more often.", group = "Level Coloring", active = coloring == "By Hit Chance")
lessTypical         = input.color(defval = #ff0088, title = "Lower Hit Chance Color", tooltip = "Color used for levels that are hit less often.", group = "Level Coloring", active = coloring == "By Hit Chance")
largeCol            = input.color(defval = #5d55ff, title = "Larger Move Color", tooltip = "Color used for levels that tend to have a bigger move after being hit.", group = "Level Coloring", active = coloring == "By Move After")
smallCol            = input.color(defval = color.gray, title = "Smaller Move Color", tooltip = "Color used for levels that tend to have a smaller move after being hit.", group = "Level Coloring", active = coloring == "By Move After")

showP               = input.bool(defval = false, title = "Show Reference Price Line", tooltip = "Shows a draggable price line so you can inspect the typical move after a level is hit.", group = "Typical Move Line (Curiosity Only)")
priceLine           = input.price(defval = 0, title = "Reference Price", tooltip = "Move this line onto a level to visualize the typical move after that level is hit.", active = showP, group = "Typical Move Line (Curiosity Only)")
type levelsDraw 

    line  levelLine 
    label levelLabel


type typicalMove 

    float levelPrice 
    float levelPercent
    array<float> differences
    bool hit = false
    float median



gradientAroundLine(int numberOfBoxes, float rangeTop, float rangeBottom, color lineColor, color bottomGradientColor, color topGradientColor, 
	 int x1, float y1, int x2, float y2, string xloc, string extend, int lineWidth, bool forceOverlay, int gradientTransp = 80) => 

	var gradientBoxes = array.new<box>(numberOfBoxes), var priceLine2 = line(na)

	Range = (rangeTop - rangeBottom) / numberOfBoxes

	half = numberOfBoxes / 2

	priceLine2.delete()	

	for boxes in gradientBoxes
		boxes.delete()

	if forceOverlay

		priceLine2 := line.new(x1, y1, x2, y2, xloc, extend, lineColor, width = lineWidth, force_overlay = true)

		for i = 0 to numberOfBoxes - 1

			getTop = rangeBottom + (Range * (i + 1))
			getBot = rangeBottom + (Range * i)

			gradient = switch i < half

				true => color.from_gradient(i, 0, half, chart.bg_color, bottomGradientColor)
				=>      color.from_gradient(i, half, numberOfBoxes - 1, topGradientColor, chart.bg_color)

			finalColor = color.new(gradient, gradientTransp)

			gradientBoxes.set(i, box.new(x1, getTop, x2, getBot, border_color = color(na), extend = extend, xloc = xloc, bgcolor = finalColor, force_overlay = true))


	else 

		priceLine2 := line.new(x1, y1, x2, y2, xloc, extend, lineColor, width = lineWidth)

		for i = 0 to numberOfBoxes - 1

			getTop = rangeBottom + (Range * (i + 1))
			getBot = rangeBottom + (Range * i)

			gradient = switch i < half

				true => color.from_gradient(i, 0, half, chart.bg_color, bottomGradientColor)
				=>      color.from_gradient(i, half, numberOfBoxes - 1, topGradientColor, chart.bg_color)

			finalColor = color.new(gradient, gradientTransp)

			gradientBoxes.set(i, box.new(x1, getTop, x2, getBot, border_color = color(na), extend = extend, xloc = xloc, bgcolor = finalColor))

	[priceLine2, gradientBoxes]



method showMove(array<typicalMove> typicalMoves) => 

    if barstate.islast and showP
        for data in typicalMoves

            if priceLine >= data.levelPrice and priceLine <= data.levelPrice * (1 + step)

                medMove = data.levelPrice * (1 + data.differences.median() / 100)

                gradientAroundLine(50, medMove * 1.005,  medMove * .995, anomalyCol, anomalyCol, anomalyCol, time[1], medMove, time, medMove, xloc.bar_time, extend.both, 2, true, 85) 
            

getLevels() => 

    var stats = matrix.new<float>(1, 2, 0)
    var masterCount = 0
    var gradBoxes = array.new<box>(50)


    var typicalMoves = array.new<typicalMove>()

    var typicalMovesPercent = array.new<float>()

    var levels = array.new<float>()
    var levelsFloat = array.new<float>()
    var levelsDrawings = array.new<levelsDraw>()

    var openTime = time, var openPrice = open

    getRange = time("", customRange)

    rangeChange = na(getRange[1]) and not na(getRange)

    var max = high, var min = low
    var stepUp = step, var stepDn = step 
    var boxRange = box(na)
    var minMed = float(na) 
    var maxMed = float(na)   

    var medianArr = array.new<float>()

    if timeframe.change(tf) and not customRangeUse or customRangeUse and rangeChange
        
        if gradBoxes.size() > 0 
            for i = 0 to gradBoxes.size() - 1
                gradBoxes.set(i, na)

        var labelLocF = switch labelLoc 

            "Left" => label.style_label_left 
            =>        label.style_label_right

        if levelsDrawings.size() > 0 

            if levelsDrawings.size() > 0 
                for data in levelsDrawings
                    data.levelLabel.set_style(labelLocF)

                    if labelLoc == "Left"

                        data.levelLabel.set_x(openTime)

        levelsDrawings := array.new<levelsDraw>()

        if typicalMoves.size() == 0 

            typicalMoves.push(typicalMove.new(open, 0, array.new<float>(), false))
            typicalMovesPercent.push(0)

        if typicalMoves.size() > 0 

            for data in typicalMoves 

                if data.levelPercent != 0 and data.hit

                    if data.levelPrice > openPrice 
                        if max >= data.levelPrice 

                            data.differences.push((max - data.levelPrice) / data.levelPrice * 100)
                            data.median := data.differences.median()

                    if data.levelPrice < openPrice 
                        if min <= data.levelPrice

                            data.differences.push((min - data.levelPrice) / data.levelPrice * 100)
                            data.median := data.differences.median()    

                data.hit := false

        levels.clear()
        levels := array.from(open)
        levelsFloat.clear()
        levelsFloat := array.from(0)
        openTime := time 
        openPrice := open
        masterCount += 1
        max := high 
        min := low
        stepUp := step 
        stepDn := step
        boxRange := box(na)

        if typicalMoves.size() > 0

            copyMedian = array.new<float>(typicalMoves.size())

            for [i, data] in typicalMoves 
                
                data.levelPrice := openPrice * (1 + data.levelPercent / 100)

                if data.median != 0

                    copyMedian.set(i, math.abs(data.median))

            medianArr := copyMedian.copy()

            minMed := medianArr.median(), maxMed := medianArr.max()


    typicalMoves.showMove()


    if levels.size() > 0 

        max := math.max(high, max)
        min := math.min(low, min)

        if not customRangeUse or customRangeUse and not na(getRange)

            while high > openPrice * (1 + stepUp)

                levels.push(openPrice * (1 + stepUp))
                levelsFloat.push(levelsFloat.last() + step * 100)

                stepUp += step
                upInd = typicalMovesPercent.indexof(levelsFloat.last())

                if upInd == -1


                    typicalMoves.push(typicalMove.new(levels.last(), levelsFloat.last(), array.new<float>(), high >= levels.last()))
                    typicalMovesPercent.push(levelsFloat.last())

                else 

                    index = typicalMoves.get(typicalMovesPercent.indexof(levelsFloat.last()))
                    index.levelPrice := levels.last()
                    index.hit := high >= levels.last()


                if levelsFloat.last() > stats.get(stats.rows() - 1, 0)

                    initialVal = switch 

                        high >= levels.last() => 1
                        =>                       0

                    stats.add_row(stats.rows(), array.from(levelsFloat.last(), initialVal))

                else if high >= levels.last()

                    getCol   = stats.col(0)
                    getIndex = getCol.indexof(levelsFloat.last())

                    stats.set(getIndex, 1, stats.get(getIndex, 1) + 1)

    
            while low < openPrice * (1 - stepDn)

                levels.unshift(openPrice * (1 - stepDn))
                levelsFloat.unshift(levelsFloat.first() - step * 100)
                
                stepDn += step
                dnInd = typicalMovesPercent.indexof(levelsFloat.first())

                if dnInd == -1

                    typicalMoves.unshift(typicalMove.new(levels.first(), levelsFloat.first(), array.new<float>(), low <= levels.first()))
                    typicalMovesPercent.unshift(levelsFloat.first())

                else 

                    index = typicalMoves.get(typicalMovesPercent.indexof(levelsFloat.first()))
                    index.levelPrice := levels.first()
                    index.hit := low <= levels.first()

                if levelsFloat.first() < stats.get(0, 0)

                    initialVal = switch 

                        low <= levels.first() => 1
                        =>                       0

                    stats.add_row(0, array.from(levelsFloat.first(), initialVal))

                else if low <= levels.first()

                    getCol   = stats.col(0)
                    getIndex = getCol.indexof(levelsFloat.first())

                    stats.set(getIndex, 1, stats.get(getIndex, 1) + 1)


            boxRange.delete()

            top = openPrice * (1 + stepUp), bottom = openPrice * (1 - stepDn) 

            if showSessionRange

                boxRange := box.new(openTime, bottom, time, top, xloc = xloc.bar_time, bgcolor = #00000000, border_color = color.new(chart.fg_color, 50), border_style = line.style_dotted)

            
            if na(gradBoxes.first())
                for i = 0 to 49 
                    gradBoxes.set(i, box.new(time, close, time, close, xloc = xloc.bar_time, border_color = color(na)))

            topRange = (top - openPrice) / 25
            botRange = (openPrice - bottom) / 25
            count = 0

            if gradientAno and levelsFloat.size() > 0

                getCol = stats.col(0)

                for i = 0 to 49

                    getBox = gradBoxes.get(i)

                    if i < 25 

                        getBox.set_lefttop      (openTime, bottom + (botRange * (i + 1)))
                        getBox.set_rightbottom  (time, bottom + (botRange * i))

                        percDistance = ((bottom + (botRange * i) - openPrice)) / openPrice * 100
                
                        getTrueAmount = stats.get(getCol.binary_search_leftmost(percDistance), 1) / masterCount * 100

                        gradCol = color.from_gradient(getTrueAmount, 0, 50, color.new(anomalyCol, 80), #00000000)

                        getBox.set_bgcolor(gradCol)

                    else 

                        topBot = openPrice + (topRange * count)

                        getBox.set_lefttop      (openTime, openPrice + (topRange * (count + 1)))
                        getBox.set_rightbottom  (time, topBot)


                        percDistance = (topBot - openPrice) / openPrice * 100
                
                        getTrueAmount = stats.get(getCol.binary_search_leftmost(percDistance), 1) / masterCount * 100

                        gradCol = switch 

                            getTrueAmount == 0 => #00000000
                            => color.from_gradient(getTrueAmount, 0, 50, color.new(anomalyCol, 80), #00000000)

                        getBox.set_bgcolor(gradCol)

                        count += 1

            if levelsDrawings.size() > 0 

                size = levelsDrawings.size() - 1

                for i = size to 0

                    getIndex = levelsDrawings.get(i)

                    getIndex.levelLine.delete()
                    getIndex.levelLabel.delete()
                    levelsDrawings.remove(i)

            getCol = stats.col(0)

            var underLineLab = levelsDraw.new()
            var overLineLab  = levelsDraw.new()

            underLineLab.levelLabel.delete()
            underLineLab.levelLine .delete()

            overLineLab.levelLabel.delete()
            overLineLab.levelLine .delete()

            getLevelsSize = levels.size()

            [distString, cHstring, MAHstring] = switch detailedLevelInfo == levelInfo.det

                true => ["Distance: ", " Chance Hit: ", " Move After Hit: "]
                =>      [" ", " ", " "]

            if not showAll or showAll and time < time_tradingday

                for [i, data] in levels 

                    getFloat = levelsFloat.get(i)

                    col = switch 

                        getFloat > -grayArea and getFloat < grayArea => color.new(normCol, 75)
                        => color.new(anomalyCol, 75)

                    width = switch 

                        getFloat == int(getFloat) => 3
                        => 1

                    if not expandInts 
                        width := 1

                    getTrueAmount = stats.get(getCol.indexof(getFloat), 1)


                    txt = switch

                        getTrueAmount != 0 => distString + str.tostring(getFloat, format.percent) + cHstring + str.tostring(getTrueAmount / masterCount * 100, "###") + "%"
                        =>                 str.tostring(getFloat, format.percent)

                    if close >= data and close < data * (1 + step)

                        col := switch 
                            getFloat > -grayArea and getFloat < grayArea => normCol
                            => anomalyCol

                        width := 1

                    median = 0.

                    if typicalMoves.size() > 0

                        index = typicalMoves.get(typicalMovesPercent.indexof(getFloat))

                        median := index.median

                        switch na(median)

                            false => txt += MAHstring + str.tostring(median, format.percent)
                            =>       txt += "-"
                    
                    tooltip = txt 

                    switch detailedLevelInfo

                        levelInfo.min => txt := "-"
                        levelInfo.none => txt := ""

                    gradient = switch coloring
                        "By Hit Chance" => color.from_gradient(getTrueAmount / masterCount * 100, 0, 50, lessTypical, moreTypical)
                        "By Move After" => color.from_gradient(math.abs(median), minMed, maxMed, smallCol, largeCol)
                        "None"          => normCol

                    if getFloat == 0 

                        if detailedLevelInfo == levelInfo.reg or detailedLevelInfo == levelInfo.det
                            txt := "0.00%"

                        gradient := normCol

                    if onlyShowHistoricalHitChance
                        txt := cHstring + str.tostring(getTrueAmount / masterCount * 100, "###") + "%"

                    levelsDrawings.push(levelsDraw.new(

                         line.new(openTime, data, time, data, xloc = xloc.bar_time, color = col, width = width),
                         label.new(time, math.avg(data, data * (1 + step)), text = txt, xloc = xloc.bar_time, textcolor = gradient, style = label.style_label_left, color = #00000000, size = labelSize, tooltip = tooltip)                 
                         ))

                    if close >= data and close < data * (1 + step)

                        levelsDrawings.push(levelsDraw.new(

                             line.new(openTime, data, time, data, xloc = xloc.bar_time, color = color.new(col, 80), width = 5),
                             na             
                             ))

                    if i == 0 

                        if getCol.includes(getFloat - step * 100)

                            getIndex = getCol.indexof(getFloat - step * 100)

                            getFloat0      = getCol.get(getIndex) / 100
                            getTrueAmount0 = stats .get(getIndex, 1)


                            txt0 = switch

                                getFloat0 != 0 => distString + str.tostring(getFloat0 * 100, format.percent) + cHstring + str.tostring(getTrueAmount0 / masterCount * 100, "###") + "%"
                                =>                 str.tostring(getFloat0 * 100, format.percent)

                            median0 = 0.

                            if typicalMoves.size() > 0
                            
                                index = typicalMoves.get(typicalMovesPercent.indexof(getFloat - step * 100))
                                                        
                                median0 := index.median

                                switch na(median0)
                                
                                    false => txt0 += MAHstring + str.tostring(median0, format.percent)
                                    =>       txt0 += "-"


                            col0 = switch 

                                getFloat0 > -grayArea and getFloat0 < grayArea => color.new(normCol, 75)
                                => color.new(anomalyCol, 75)

                            width0 = switch 

                                getFloat0 == int(getFloat0) => 3
                                => 1

                            if not expandInts 
                                width0 := 1

                            gradientNew = switch coloring
                                "By Hit Chance" => color.from_gradient(getTrueAmount0 / masterCount * 100, 0, 50, lessTypical, moreTypical)
                                "By Move After" => color.from_gradient(math.abs(median0), minMed, maxMed, smallCol, largeCol)
                                "None"          => normCol

                            if getFloat0 == 0 

                                gradientNew := normCol

                            tooltip0 = txt0
                            if onlyShowHistoricalHitChance
                                txt0 := cHstring + str.tostring(getTrueAmount0 / masterCount * 100, "###") + "%"

                            switch detailedLevelInfo

                                levelInfo.min => txt0 := "-"
                                levelInfo.none => txt0 := ""

                            underLineLab.levelLine  := line.new (openTime, openPrice * (1 + getFloat0), time, openPrice * (1 + getFloat0), xloc = xloc.bar_time, width = width0, style = line.style_dotted, color = chart.fg_color)
                            underLineLab.levelLabel := label.new(time, math.avg(openPrice * (1 + getFloat0), openPrice * (1 + (getFloat0 + step))), xloc = xloc.bar_time, text = txt0, style = label.style_label_left, color = #00000000, size = labelSize, textcolor = gradientNew, tooltip = tooltip0)


                    if i == getLevelsSize - 1

                        if getCol.includes(getFloat + step * 100)

                            getIndex = getCol.indexof(getFloat + step * 100)

                            getFloat0      = getCol.get(getIndex) / 100
                            getTrueAmount0 = stats .get(getIndex, 1)


                            txt0 = switch

                                getFloat0 != 0 => distString + str.tostring(getFloat0 * 100, format.percent) + cHstring + str.tostring(getTrueAmount0 / masterCount * 100, "###") + "%"
                                =>                 str.tostring(getFloat0 * 100, format.percent)
                            
                            median0 = 0.

                            if typicalMoves.size() > 0
                            
                                index = typicalMoves.get(typicalMovesPercent.indexof(getFloat + step * 100))
                                                                
                                median0 := index.median

                                switch na(median0)
                                
                                    false => txt0 += MAHstring + str.tostring(median0, format.percent)
                                    =>       txt0 += "-"


                            col0 = switch 

                                getFloat0 > -grayArea and getFloat0 < grayArea => color.new(normCol, 75)
                                => color.new(anomalyCol, 75)

                            width0 = switch 

                                getFloat0 == int(getFloat0) => 3
                                => 1

                            if not expandInts 
                                width0 := 1


                            gradientNew = switch coloring
                                "By Hit Chance" => color.from_gradient(getTrueAmount0 / masterCount * 100, 0, 50, lessTypical, moreTypical)
                                "By Move After" => color.from_gradient(math.abs(median0), minMed, maxMed, smallCol, largeCol)
                                "None"          => normCol

                            if getFloat0 == 0 

                                gradientNew := normCol

                            tooltip0 = txt0

                            if onlyShowHistoricalHitChance
                                txt0 := cHstring + str.tostring(getTrueAmount0 / masterCount * 100, "###") + "%"

                            switch detailedLevelInfo

                                levelInfo.min => txt0 := "-"
                                levelInfo.none => txt0 := ""


                            overLineLab.levelLine  := line.new (openTime, openPrice * (1 + getFloat0), time, openPrice * (1 + getFloat0), xloc = xloc.bar_time, width = width0, style = line.style_dotted, color = chart.fg_color)
                            overLineLab.levelLabel := label.new(time, math.avg(openPrice * (1 + getFloat0), openPrice * (1 + (getFloat0 + step))), xloc = xloc.bar_time, text = txt0, style = label.style_label_left, color = #00000000, size = labelSize, textcolor = gradientNew, tooltip = tooltip0)

            else

                if showAll and stats.rows() > 0

                    for i = 0 to stats.rows() - 1

                        getFloat = stats.get(i, 0)

                        col = switch 

                            getFloat > -grayArea and getFloat < grayArea => color.new(normCol, 75)
                            => color.new(anomalyCol, 75)

                        width = switch 

                            getFloat == int(getFloat) => 3
                            => 1

                        if not expandInts 
                            width := 1

                        getTrueAmount = stats.get(i, 1)

                        txt = switch

                            getTrueAmount != 0 => str.tostring(getFloat, format.percent) + cHstring + str.tostring(getTrueAmount / masterCount * 100, "###") + "%"
                            =>                 str.tostring(getFloat, format.percent)
        
                        median = 0.

                        if typicalMoves.size() > 0 and getFloat != 0
                            
                            index = typicalMoves.get(typicalMovesPercent.indexof(getFloat))

                            median := index.median

                            switch na(median)

                                false => txt += MAHstring + str.tostring(median, format.percent)
                                =>       txt += "-"
                            

                        gradient = switch coloring
                            "By Hit Chance" => color.from_gradient(getTrueAmount / masterCount * 100, 0, 50, lessTypical, moreTypical)
                            "By Move After" => color.from_gradient(math.abs(median), minMed, maxMed, smallCol, largeCol)
                            "None"          => normCol
                            
                        tooltip = txt 

                        switch detailedLevelInfo

                            levelInfo.min => txt := "-"
                            levelInfo.none => txt := ""
                        if onlyShowHistoricalHitChance
                            txt := cHstring + str.tostring(getTrueAmount / masterCount * 100, "###") + "%"

                        levelsDrawings.push(levelsDraw.new(

                             line.new(openTime, openPrice * (1 + getFloat / 100), time, openPrice * (1 + getFloat / 100), xloc = xloc.bar_time, color = col, width = width),
                             label.new(time, math.avg(openPrice * (1 + getFloat / 100), openPrice * (1 + getFloat / 100 + step)), text = txt, xloc = xloc.bar_time, textcolor = gradient, style = label.style_label_left, color = #00000000, size = labelSize, tooltip = tooltip)                 
                             ))

    0
            

getLevels()

if barstate.islast 
    var pLine = line(na)
    pLine.delete()
    var pLabel = label(na)
    pLabel.delete()

    if showP 
        pLine  := line.new(bar_index - 1, priceLine, bar_index, priceLine, color = chart.fg_color, extend = extend.both, width = 2)

        if priceLine == 0 
            pLabel := label.new(bar_index, 0, text = "Drag Me Up To The Current Grid To See What Price Typically Does Once Hitting A Level (Curiosity Only - Don't Take This Too Seriously)", textcolor = chart.fg_color, size = size.normal)
````
