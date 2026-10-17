# Candle Fingerprint [TradingIQ]

- url: https://www.tradingview.com/script/Q7wvDByp-Candle-Fingerprint-TradingIQ/
- type: indicator
- pine_id: PUB;f6ce96fa210046a19adf2d2f583f9581
- version: 2.0

## Description

Hello Traders!

🔹[b]Candle Fingerprint[/b]

Candle Fingerprint is a pattern-based analysis tool designed to study how price has typically behaved after specific candle structures.
Instead of treating candles as isolated events, this tool compares current candles to historical ones and shows [b]what has usually happened next in similar situations[/b].

Think of it as a way to find [b]historical matches and outcomes for the current candle[/b], not as a fixed prediction engine.

[list]
[*]finds candles with similar structure in the past
[*]compares body size, wicks, volatility, and close position
[*]tracks whether price typically continued or reversed
[*]shows continuation vs reversal rates
[*]displays typical move after similar candles
[*]optional streak-based behavior analysis
[/list]

🔹[b]What the tool shows[/b]

🔸[b]Candle similarity matching[/b]

The script analyzes the current candle and searches historical data for candles with similar structure.
It compares multiple components such as body size, wick proportions, volatility, and where the candle closed within its range.

This helps reveal:
[list]
[*]which past candles looked similar to the current one
[*]how those candles behaved afterward
[*]whether similar setups tended to continue or reverse
[/list]

Instead of assuming what a candle means, you get a [b]historical reference for how similar structures have behaved before[/b].

[image]https://www.tradingview.com/x/ZqgdMk1i/[/image] 

🔸[b]Continuation vs reversal behavior[/b]

Once similar candles are found, the script tracks what happened next.
It calculates how often price continued in the same direction versus reversing.

This allows you to see:
[list]
[*]whether continuation or reversal has been more common
[*]the relative strength of that tendency
[*]how consistent the behavior has been across samples
[/list]

This provides context around the current candle, rather than a guaranteed outcome.

🔸[b]Typical move after the candle[/b]

In addition to direction, the script measures how far price typically moved after similar candles.
It calculates median moves for both continuation and reversal scenarios.

This helps show:
[list]
[*]the typical size of follow-through moves
[*]the difference between continuation and reversal magnitude
[*]how strong or weak reactions have been historically
[/list]

This is not about predicting an exact move, but about understanding [b]what has commonly happened in the past[/b].

[image]https://www.tradingview.com/x/x7ku3KjQ/[/image] 

🔸[b]Visual similarity mapping[/b]

The script highlights the most similar historical candles directly on the chart.
This gives a visual reference for how past setups formed and evolved.

This helps you:
[list]
[*]see real examples of similar price behavior
[*]compare structure side by side
[*]understand how the current setup fits into historical context
[/list]

🔸[b]Candle streak model[/b]

In addition to similarity, the script includes a streak-based model that tracks sequences of consecutive up or down closes.

This allows you to analyze:
[list]
[*]what has typically happened after multiple up closes
[*]what has typically happened after multiple down closes
[*]how continuation vs reversal tendencies shift with streak length
[/list]

This provides a different lens focused on [b]momentum sequences rather than structure[/b].

[image]https://www.tradingview.com/x/vr2fEa58/[/image] 

🔸[b]Confidence context[/b]

The tool evaluates how reliable the observed behavior is based on sample size and consistency.

This helps you understand:
[list]
[*]whether the data is meaningful or limited
[*]how much weight to give the observation
[*]when patterns appear more or less stable
[/list]

🔹[b]How to read it[/b]

Each component gives a different layer of insight:

Candle structure → what the current candle looks like  
Similarity matches → where this pattern appeared before  
Continuation rate → how often price continued  
Reversal rate → how often price reversed  
Typical move → how far price typically moved afterward  
Streak context → how sequences of candles have behaved  

🔹[b]Why this tool is useful[/b]

It gives you:
[list]
[*]a structured way to compare current candles to historical ones
[*]context for whether a setup has tended to continue or reverse
[*]typical move expectations based on past behavior
[*]a data-driven alternative to subjective candle interpretation
[*]multiple perspectives using both structure and streak behavior
[/list]

🔹[b]Best use cases[/b]

[list]
[*]analyzing individual candle behavior
[*]comparing current setups to historical patterns
[*]studying continuation vs reversal tendencies
[*]understanding momentum through candle streaks
[*]adding contextual data to price action analysis
[/list]

🔹[b]Important note[/b]

This tool is based entirely on historical observations and pattern matching.
That means:
[list]
[*]it reflects past behavior, not guaranteed outcomes
[*]it should not be treated as a predictive or deterministic model
[*]similar candles can still produce different results
[*]outputs are best used as context, not certainty
[/list]

🔹[b]Inputs you can customize[/b]

The script includes flexible controls such as:
[list]
[*]model selection (similarity or streak)
[*]candle selection method
[*]table display and positioning
[*]similarity weighting (body, wicks, volatility, close)
[*]history table settings
[*]visual offset and layout
[/list]

[b]Closing Notes[/b]

Candle Fingerprint is built to shift the focus from [b]what a candle looks like[/b] to [b]how similar candles have behaved historically[/b].

It does not attempt to predict the future, but instead provides a structured view of [b]what has typically happened in comparable situations[/b], allowing you to make more informed, contextual decisions.

Thank you for checking it out!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=6
indicator("Candle Fingerprint [TradingIQ]", overlay = true, max_boxes_count = 500, calc_bars_count = 20000, max_labels_count = 500, max_polylines_count = 100)

model         = input.string(defval = "Candle Similarity", title = "Model", options = ["Candle Streak", "Candle Similarity"])
var useCandle = model == "Candle Similarity"

offset       = input.int(defval = 0, minval = 0, title = "Grid Offset", maxval = 200, group = "Candle Streak", active = not useCandle)
showHistoryTab = input.bool(defval = false, title = "Show History Table", group = "Candle Streak", active = not useCandle)
sizeTabH     = input.string(defval = size.normal, title = "History Table Size", options = [size.tiny, size.small, size.normal, size.large, size.huge], group = "Candle Streak", active = not useCandle)
posTabH      = input.string(defval = position.top_right, title = "History Table Position", group = "Candle Streak", options = [position.middle_right, position.top_right, position.bottom_right, position.bottom_left, position.top_left, position.middle_left], active = not useCandle)

upCol = input.color(#55ffda, title = "Box 1 Color")
dnCol = input.color(color.rgb(255, 116, 116), title = "Box 2 Color")

usePreviousCandle = input.bool(defval = true, title = "Use Most Previous Candle", group = "Candle Similarity")
chooseCandle      = input.time(defval = timestamp("16 Apr 1800"), title = "Choose Candle To Find Similarity", inline = "CC", group = "Candle Similarity", active = not usePreviousCandle)
showTable         = input.bool(defval = true, title = "Show Candle Stats Table", group = "Candle Similarity", active = useCandle)
sizeTab           = input.string(defval = size.normal, title = "Table Size", options = [size.tiny, size.small, size.normal, size.large, size.huge], group = "Candle Similarity", active = showTable and useCandle)
posTab            = input.string(defval = position.bottom_right, title = "Table Position", group = "Candle Similarity", options = [position.middle_right, position.top_right, position.bottom_right, position.bottom_left, position.top_left, position.middle_left], active = showTable and useCandle)
advInputs         = input.bool(defval = false, title = "Use Advanced Inputs (Higher Numbers = More Important)", group = "Advanced Inputs")
bodyImp           = input.float(defval = 1.3, minval = 0, maxval = 2, step = 0.1, title = "How similar should the candle body sizes be?", active = advInputs, group = "Advanced Inputs")
wickImp           = input.float(defval = 1, minval = 0, maxval = 2, step = 0.1, title = "How similar should the wick sizes be?", active = advInputs, group = "Advanced Inputs")
atrImp            = input.float(defval = 0.8, minval = 0, maxval = 2, step = 0.1, title = "How similar should overall candle volatility be?", active = advInputs, group = "Advanced Inputs")
closeImp          = input.float(defval = 0.7, minval = 0, maxval = 2, step = 0.1, title = "How similar should candle close positions be within their range?", active = advInputs, group = "Advanced Inputs")



type candleHistories 

    array<float> continueReturn 
    array<float> reverseReturn 

type candleStructure

    float bodySize 
    float upperWickPer
    float lowerWickPer 
    float rangeATR 
    float signReturn 
    float closePos
    int   timeP  = time  
    float highP  = high 
    float lowP   = low 
    int   time1 
    int   timeN
    float nextBarReturn

type labelBox 

    box   candleBox 
    label candleLabel
    label n1
    label n2 
    label n3
    label n4

var returnHistoryBull = array.new<candleHistories>(1, candleHistories.new(array.new<float>(), array.new<float>()))
var returnHistoryBear = array.new<candleHistories>(1, candleHistories.new(array.new<float>(), array.new<float>()))

var candleStructureHistory = array.new<candleStructure>()
var timeArr                = array.new<int>()

if candleStructureHistory.size() > 0 

    last = candleStructureHistory.last()

    last.nextBarReturn := close / close[1] - 1

candleStructureHistory.push(candleStructure.new(

                                         math.abs(close - open) / (high - low), 
                                         (high - math.max(open, close)) / (high - low), 
                                         (math.min(open, close) - low) / (high - low),
                                         (high - low) / ta.atr(14),
                                         math.sign(close - close[1]),
                                         (close - low) / (high - low),
                                         time1 = time[1], 
                                         timeN = time("", -1)
                                         )), timeArr.push(time)


var firstBarTime = time 

if usePreviousCandle
    chooseCandle := time[1]

if time >= chooseCandle and time[1] < chooseCandle

    line.new(time, high, time, low - syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(chart.fg_color, 50))
    
var candleDraw = array.new<labelBox>(25)
    
if barstate.isfirst and useCandle

    for i = 0 to 24

        candleDraw.set(i, labelBox.new(
                     box.new(time, close, time, close, xloc = xloc.bar_time, bgcolor = color(na), border_color = #ff65fb, border_width = 2), 
                     label.new(time, close, style = label.style_label_center, color = #00000000, textcolor = #ff65fb, text = "⬤", size = 7, xloc = xloc.bar_time), 
                     label.new(time, close, style = label.style_label_center, color = #00000000, textcolor = color.new(#ff65fb, 94), text = "⬤", size = 12, xloc = xloc.bar_time), 
                     label.new(time, close, style = label.style_label_center, color = #00000000, textcolor = color.new(#ff65fb, 96), text = "⬤", size = 16, xloc = xloc.bar_time), 
                     label.new(time, close, style = label.style_label_center, color = #00000000, textcolor = color.new(#ff65fb, 98), text = "⬤", size = 20, xloc = xloc.bar_time), 
                     label.new(time, close, style = label.style_label_center, color = #00000000, textcolor = color.new(#ff65fb, 99), text = "⬤", size = 24, xloc = xloc.bar_time)

                     ))

atr = ta.atr(14) / 2

if barstate.islast and model == "Candle Similarity"


    distArr        = array.new<float>()
    indArr         = array.new<int>()

    getIndex = int(na)

    if chooseCandle >= firstBarTime 

        getIndex := timeArr.binary_search_rightmost(chooseCandle)

        self = candleStructureHistory.get(getIndex)

        for [i, data] in candleStructureHistory

            if i == getIndex
                continue

            if data.signReturn != self.signReturn
                continue

            dist = 
                 math.abs(data.bodySize  - self.bodySize)  * bodyImp +
                 math.abs(data.upperWickPer - self.upperWickPer) * wickImp + 
                 math.abs(data.lowerWickPer - self.lowerWickPer) * wickImp +
                 math.abs(data.rangeATR - self.rangeATR) * atrImp  +
                 math.abs(data.closePos - self.closePos) * closeImp

            binSearch = distArr.binary_search_rightmost(dist)

            distArr.insert(binSearch, dist)
            indArr .insert(binSearch, i)

        returnArrPos = array.new<float>(), returnArrNeg = array.new<float>()

        posReturn = 0, negReturn = 0


        for i = 0 to math.min(24, indArr.size() - 1)

            getInd = candleStructureHistory.get(indArr.get(i))

            switch math.sign(getInd.nextBarReturn) 

                1 =>  posReturn += 1, returnArrPos.push(getInd.nextBarReturn)
                -1 => negReturn += 1, returnArrNeg.push(getInd.nextBarReturn)

            getDraw = candleDraw.get(i)

            getDraw.candleBox.set_lefttop(getInd.time1, getInd.highP)
            getDraw.candleBox.set_rightbottom(getInd.timeN, getInd.lowP)

            getDraw.candleLabel.set_xy(getInd.timeP, getInd.highP + atr)
            getDraw.n1.set_xy(getInd.timeP, getInd.highP + atr)
            getDraw.n2.set_xy(getInd.timeP, getInd.highP + atr)
            getDraw.n3.set_xy(getInd.timeP, getInd.highP + atr)
            getDraw.n4.set_xy(getInd.timeP, getInd.highP + atr)


        var currCandleLabel = label(na)
        var currCandleBox   = box  (na)

        currCandleLabel.delete()
        currCandleBox  .delete()

        totalSize = posReturn + negReturn

        [continueReturn, reverseReturn, continueReturnArr, reverseReturnArr] = switch self.signReturn

            1  => [posReturn, negReturn, returnArrPos.copy(), returnArrNeg.copy()]
            -1 => [negReturn, posReturn, returnArrNeg.copy(), returnArrPos.copy()]

        continueRate = continueReturn / totalSize
        reverseRate  = reverseReturn  / totalSize

        bestRate = math.max(continueRate, reverseRate)

        txt = "Usual Next Bar: "

        [side, sideArr] = switch 

            bestRate == continueRate => ["Continue", continueReturnArr.copy()]
            =>                          ["Reverse",   reverseReturnArr.copy()]

        txt  += side + "\n" + side + " Rate: " + str.tostring(bestRate * 100, "###") + "%\n" + "Typical " + side + " Move: " + str.tostring(sideArr.median() * 100, format.percent)

        currCandleBox   := box.new(self.time1, self.highP, self.timeN, self.lowP, xloc = xloc.bar_time, bgcolor = #00000000, border_color = color.blue, border_width = 2)
            
        if usePreviousCandle
            var extra = box(na)
            extra.delete()

            extra := currCandleBox.copy()
            currCandleBox.set_bottom(high[1])
            extra.set_top(low[1])

        if not showTable
            currCandleLabel := label.new(self.timeP, self.highP, xloc = xloc.bar_time, yloc = yloc.abovebar, color = #00000000, textcolor = chart.fg_color, text = txt)

        if showTable

            var tab    = table.new(posTab, 99, 99, 
                                        bgcolor       = #20222C, 
                                        border_color  = #363843, 
                                        frame_color   = #363843, 
                                        border_width  = 1, 
                                        frame_width   = 1, 
                                        force_overlay = true
                                        )

            rateCol = color.from_gradient(bestRate, .5, .75, color.white, color.yellow)

            tab.cell(0, 0, "Usual Next Bar:", text_color = color.white, text_size = sizeTab)
            tab.cell(1, 0, side, text_color = color.white, text_size = sizeTab)

            tab.cell(0, 1, side + " Rate:" , text_color = color.white, text_size = sizeTab)
            tab.cell(1, 1, str.tostring(bestRate * 100, "###") + "%", text_color = rateCol, text_size = sizeTab)

            selfSign = math.sign(self.signReturn)

            [moveCol, oppMoveCol] = switch selfSign

                1 => [upCol, dnCol]
                =>   [dnCol, upCol]

            tab.cell(0, 2,  "Typical Continue Move: ", text_color = color.white, text_size = sizeTab)
            tab.cell(1, 2, str.tostring(continueReturnArr.median() * 100, format.percent), text_color = moveCol, text_size = sizeTab)

            tab.cell(0, 3,  "Typical Reverse Move: ", text_color = color.white, text_size = sizeTab)
            tab.cell(1, 3, str.tostring(reverseReturnArr.median() * 100, format.percent), text_color = oppMoveCol, text_size = sizeTab)


        var lineDrawings = array.new<line>()
        var boxDrawings = array.new<box>()

        if lineDrawings.size() > 0 

            size = lineDrawings.size()

            for i = 0 to size - 1
                lineDrawings.shift().delete()

        if boxDrawings.size() > 0 

            size = boxDrawings.size()

            for i = 0 to size - 1
                boxDrawings.shift().delete()

        var revLab = label(na)
        revLab.delete()

        pArr = array.from(continueReturnArr.percentile_nearest_rank(75),
                          continueReturnArr.percentile_nearest_rank(25), 
                          reverseReturnArr .percentile_nearest_rank(25), 
                          reverseReturnArr .percentile_nearest_rank(75)
                           )


        avgContinue = close[1] * (1 + math.avg(pArr.first(), pArr.get(1)))
        avgReverse  = close[1] * (1 + math.avg(pArr.get(-2), pArr.last()))

        botContinue = close[1] * (1 + math.min(pArr.first(), pArr.get(1)))
        botReverse  = close[1] * (1 + math.min(pArr.get(-2), pArr.last()))

        rangeBotContinue = (avgContinue - botContinue) / 25
        rangeBotReverse  = (avgReverse  - botReverse)  / 25

        [g1col, g2col] = switch self.signReturn

            1  => [upCol, dnCol]
            -1 => [dnCol, upCol]

        colArr = array.from(g1col, color.new(g1col, 50), g2col, color.new(g2col, 50))

        for i = 0 to 24 

            grad1 = color.from_gradient(i, 0, 24, #00000000, color.new(g1col, 90))
            grad2 = color.from_gradient(i, 0, 24,color.new(g1col, 90), #00000000)

            grad3 = color.from_gradient(i, 0, 24, #00000000, color.new(g2col, 90))
            grad4 = color.from_gradient(i, 0, 24,color.new(g2col, 90), #00000000)

            boxDrawings.push(box.new(bar_index + offset, botContinue + rangeBotContinue * (i + 1), bar_index + 5 + offset, botContinue + rangeBotContinue * i, border_color = color(na), bgcolor = grad1))
            boxDrawings.push(box.new(bar_index + offset, avgContinue + rangeBotContinue * (i + 1), bar_index + 5 + offset, avgContinue + rangeBotContinue * i, border_color = color(na), bgcolor = grad2))
            boxDrawings.push(box.new(bar_index + offset, botReverse + rangeBotReverse * (i + 1), bar_index + 5 + offset, botReverse + rangeBotReverse * i, border_color = color(na), bgcolor = grad3))
            boxDrawings.push(box.new(bar_index + offset, avgReverse + rangeBotReverse * (i + 1), bar_index + 5 + offset, avgReverse + rangeBotReverse * i, border_color = color(na), bgcolor = grad4))

        for [i, data] in pArr

            lineDrawings.push(line.new(bar_index + offset, close[1] * (1 + data), bar_index + 5 + offset, close[1] * (1 + data), color = colArr.get(i)))

        isContinue = side == "Continue"

        [y1, y2] = switch isContinue 

            true => [close[1] * (1 + pArr.first()), close[1] * (1 + pArr.get(1))]
            =>      [close[1] * (1 + pArr.get(-2)), close[1] * (1 + pArr.last())]

        bottom = math.min(y1, y2)
        top    = math.max(y1, y2)

        Range = (top - bottom) / 4

        var tableBox = array.new<box>(5)

        for boxes in tableBox
            boxes.delete()

        col = switch 

            y1 < open => dnCol
            =>           upCol

        tableBox.set(0, box.new(bar_index + 5 + offset, y1, bar_index + 10 + offset, y2, border_color = #1C2234, bgcolor = #14181E))
        tableBox.set(1, box.new(bar_index + 5 + offset, top, bar_index + 10 + offset, top - Range, text = "Usual Next Bar: " + side, border_color = col, bgcolor = #00000000, text_color = color.white))
        tableBox.set(2, box.new(bar_index + 5 + offset, top - Range, bar_index + 10 + offset, top - Range * 2, text = "Rate: " + str.tostring(bestRate * 100, "###") + "%", border_color = col, bgcolor = #00000000, text_color = color.white))
        tableBox.set(3, box.new(bar_index + 5 + offset, top - Range * 2, bar_index + 10 + offset, top - Range * 3, text = "Typical Continue Move: " + str.tostring(continueReturnArr.median() * 100, format.percent), border_color = col, bgcolor = #00000000, text_color = color.white))
        tableBox.set(4, box.new(bar_index + 5 + offset, top - Range * 3, bar_index + 10 + offset, top - Range * 4, text = "Typical Reverse Move: " + str.tostring(reverseReturnArr.median() * 100, format.percent), border_color = col, bgcolor = #00000000, text_color = color.white))
                         

var upCount = -1
var dnCount = -1

if close > close[1] and barstate.isconfirmed

    if dnCount > -1

        for i = 0 to dnCount

            index = returnHistoryBear  .get(i)
            ins   = index.reverseReturn.binary_search_rightmost(close / close[1] - 1)

            index.reverseReturn.insert(ins, close / close[1] - 1)

    upCount += 1, dnCount := -1

    if upCount > 0

        if upCount >= returnHistoryBull.size() 

            returnHistoryBull.push(candleHistories.new(array.new<float>(), array.new<float>()))
            returnHistoryBear.push(candleHistories.new(array.new<float>(), array.new<float>()))

        for i = 0 to upCount - 1

            index = returnHistoryBull   .get(i)
            ins   = index.continueReturn.binary_search_rightmost(close / close[1] - 1)

            index.continueReturn.insert(ins, close / close[1] - 1)


else if close < close[1] and barstate.isconfirmed

    if upCount > -1

        for i = 0 to upCount 

            index = returnHistoryBull.get(i)
            ins   = index.reverseReturn.binary_search_rightmost(close / close[1] - 1)

            index.reverseReturn.insert(ins, close / close[1] - 1)


    dnCount += 1, upCount := -1

    if dnCount > 0

        if dnCount >= returnHistoryBear.size() 

            returnHistoryBear.push(candleHistories.new(array.new<float>(), array.new<float>()))
            returnHistoryBull.push(candleHistories.new(array.new<float>(), array.new<float>()))

        for i = 0 to dnCount - 1

            index = returnHistoryBear.get(i)
            ins   = index.continueReturn.binary_search_rightmost(close / close[1] - 1)

            index.continueReturn.insert(ins, close / close[1] - 1)

if barstate.islast and showHistoryTab and not useCandle

    var tab    = table.new(posTabH, 99, 99, 
                                    bgcolor       = #20222C, 
                                    border_color  = #363843, 
                                    frame_color   = #363843, 
                                    border_width  = 1, 
                                    frame_width   = 1, 
                                    force_overlay = true
                                    )
    
    tab.cell(0, 0, text = "Streak", text_color = chart.fg_color, text_size = sizeTabH)
    tab.cell(1, 0, text = "Bull\nContinue",  text_size = sizeTabH, text_color = upCol)
    tab.cell(2, 0, text = "Bull\nReverse" ,  text_size = sizeTabH, text_color = dnCol)
    tab.cell(3, 0, text = "Bear\nContinue",  text_size = sizeTabH, text_color = dnCol)
    tab.cell(4, 0, text = "Bear\nReverse" ,  text_size = sizeTabH, text_color = upCol)


    for i = 0 to returnHistoryBull.size() - 1

        getBullInd = returnHistoryBull.get(i)
        getBearInd = returnHistoryBear.get(i)
    
        bullContinueP = nz(getBullInd.continueReturn.size() / (getBullInd.reverseReturn.size() + getBullInd.continueReturn.size()) * 100)
        bearContinueP = nz(getBearInd.continueReturn.size() / (getBearInd.reverseReturn.size() + getBearInd.continueReturn.size()) * 100)

        bullContinuePtxt = switch bullContinueP == 0

            false => str.tostring(bullContinueP, "###") + "%" 
            =>       "-"

        bearContinuePtxt = switch bearContinueP == 0

            false => str.tostring(bearContinueP, "###") + "%" 
            =>       "-"
    

        grad1 = color.from_gradient(bullContinueP, 50, 65, color.white, upCol)
        grad2 = color.from_gradient(100 - bullContinueP, 50, 65, color.white, dnCol)
        grad3 = color.from_gradient(bearContinueP, 50, 65, color.white, dnCol)
        grad4 = color.from_gradient(100 - bearContinueP, 50, 65, color.white, upCol)

                
        if nz(getBullInd.continueReturn.size()) + nz(getBullInd.reverseReturn.size()) > 5
        
            tab.cell(0, i + 1, str.tostring(i + 1), text_color = chart.fg_color, text_size = sizeTabH)
            tab.cell(1, i + 1, bullContinuePtxt, text_color = grad1, text_size = sizeTabH)
            tab.cell(2, i + 1, str.tostring(100 - bullContinueP, "###") + "%", text_color = grad2, text_size = sizeTabH)
                
        if nz(getBearInd.continueReturn.size()) + nz(getBearInd.reverseReturn.size()) > 5
            
            tab.cell(0, i + 1, str.tostring(i + 1), text_color = chart.fg_color, text_size = sizeTabH)
            tab.cell(3, i + 1, bearContinuePtxt, text_color = grad3, text_size = sizeTabH)
            tab.cell(4, i + 1, str.tostring(100 - bearContinueP, "###") + "%", text_color = grad4, text_size = sizeTabH)


pArr = array.from(float(na), na, na, na)
candleHistories getInd = na

if upCount > -1 or dnCount > -1 

    getInd := switch 

        upCount > -1 => returnHistoryBull.get(upCount)
        dnCount > -1 => returnHistoryBear.get(dnCount)

    sizeContinue = getInd.continueReturn.size()
    sizeReverse  = getInd.reverseReturn .size()

    if sizeContinue > 0 and sizeReverse > 0

        pArr := array.from(
                    getInd.continueReturn.get(math.min(sizeContinue - 1, math.round(sizeContinue * .75))),
                    getInd.continueReturn.get(math.min(sizeContinue - 1, math.round(sizeContinue * .25))),
                    getInd.reverseReturn .get(math.min(sizeReverse - 1, math.round(sizeReverse  * .25))),
                    getInd.reverseReturn .get(math.min(sizeReverse - 1, math.round(sizeReverse  * .75)))
             )

r1 = close[1] * (1 + pArr.first())
r2 = close[1] * (1 + pArr.get(1))
r3 = close[1] * (1 + pArr.get(-2))
r4 = close[1] * (1 + pArr.last())


var min  = float(na)
var max  = float(na)
absRange = math.abs(r2 - r1)


if not na(r1) and not na(r2)

    if na(min) or na(max)

        min := absRange
        max := absRange

    min := math.min(min, absRange)
    max := math.max(max, absRange)

topPlot = math.avg(math.max(r1, r4), math.max(r2, r3))
botPlot = math.avg(math.min(r1, r4), math.min(r2, r3))

modulo = bar_index % 2

// plot(modulo == 0  ? topPlot : na, color = color.blue, style = plot.style_steplinebr)
// plot(modulo == 1  ? topPlot : na, color = color.blue, style = plot.style_steplinebr)
// plot(modulo == 0  ? botPlot : na, color = color.rgb(236, 33, 243), style = plot.style_steplinebr)
// plot(modulo == 1  ? botPlot : na, color = color.rgb(236, 33, 243), style = plot.style_steplinebr)


//color.from_gradient(absRange, min, max, color.new(color.blue, 90), color.blue))
// p2 = plot(math.max(r2, r3), color = color.blue, display = display.none)//color.from_gradient(absRange, min, max, color.new(color.blue, 90), color.blue))


// plot(r2, style = plot.style_steplinebr, color = color.from_gradient(absRange, min, max, color.new(color.blue, 90), color.blue))

if barstate.islast and model == "Candle Streak"

    var lineDrawings = array.new<line>()
    var boxDrawings = array.new<box>()
    var streakBox = box(na)
    streakBox.delete()



    if lineDrawings.size() > 0 

        size = lineDrawings.size()

        for i = 0 to size - 1
            lineDrawings.shift().delete()

    if boxDrawings.size() > 0 

        size = boxDrawings.size()

        for i = 0 to size - 1
            boxDrawings.shift().delete()

    preText = switch 

        upCount > -1 => str.tostring(upCount + 1) + " Up Closes"
        dnCount > -1 => str.tostring(dnCount + 1) + " Down Closes"

    maxN = 0., minN = 10e10 
    for i = 1 to math.max(upCount, dnCount) + 1
        maxN := math.max(high[i], maxN)
        minN := math.min(low[i], minN)

    streakBox := box.new(bar_index - math.max(upCount, dnCount) - 1, maxN, bar_index - 1, minN, bgcolor = color.new(color.blue, 75), border_color = #00000000, border_width = 2)

    if math.max(upCount, dnCount) == 0

        preText := str.substring(preText, 0, str.length(preText) - 1)

    var revLab = label(na)
    revLab.delete()

    continueAmt = getInd.continueReturn.size()
    reverseAmt  = getInd.reverseReturn.size()
    totalAmt    = continueAmt + reverseAmt

    continuationRate = continueAmt / totalAmt 
    reverseRate      = 1 - continuationRate

    usedRate = math.max(continuationRate, reverseRate)

    // se = math.sqrt(usedRate * (1 - usedRate) / totalAmt)

    confScore = math.abs(usedRate - 0.5) * math.sqrt(totalAmt)

    isContinue = continueAmt > reverseAmt

    medianMove = switch isContinue

        true => getInd.continueReturn.median()
        =>      getInd.reverseReturn .median()

    colArr = array.from(upCol, color.new(upCol, 50), dnCol, color.new(dnCol, 50))

    avgContinue = close[1] * (1 + math.avg(pArr.first(), pArr.get(1)))
    avgReverse  = close[1] * (1 + math.avg(pArr.get(-2), pArr.last()))

    botContinue = close[1] * (1 + math.min(pArr.first(), pArr.get(1)))
    botReverse  = close[1] * (1 + math.min(pArr.get(-2), pArr.last()))

    rangeBotContinue = (avgContinue - botContinue) / 25
    rangeBotReverse  = (avgReverse  - botReverse)  / 25

    for i = 0 to 24 

        grad1 = color.from_gradient(i, 0, 24, #00000000, color.new(upCol, 90))
        grad2 = color.from_gradient(i, 0, 24,color.new(upCol, 90), #00000000)

        grad3 = color.from_gradient(i, 0, 24, #00000000, color.new(dnCol, 90))
        grad4 = color.from_gradient(i, 0, 24,color.new(dnCol, 90), #00000000)

        boxDrawings.push(box.new(bar_index + offset, botContinue + rangeBotContinue * (i + 1), bar_index + 5 + offset, botContinue + rangeBotContinue * i, border_color = color(na), bgcolor = grad1))
        boxDrawings.push(box.new(bar_index + offset, avgContinue + rangeBotContinue * (i + 1), bar_index + 5 + offset, avgContinue + rangeBotContinue * i, border_color = color(na), bgcolor = grad2))
        boxDrawings.push(box.new(bar_index + offset, botReverse + rangeBotReverse * (i + 1), bar_index + 5 + offset, botReverse + rangeBotReverse * i, border_color = color(na), bgcolor = grad3))
        boxDrawings.push(box.new(bar_index + offset, avgReverse + rangeBotReverse * (i + 1), bar_index + 5 + offset, avgReverse + rangeBotReverse * i, border_color = color(na), bgcolor = grad4))


    for [i, data] in pArr

        lineDrawings.push(line.new(bar_index + offset, close[1] * (1 + data), bar_index + 5 + offset, close[1] * (1 + data), color = colArr.get(i)))

    confidenceTxt = switch
        totalAmt  < 10   => "Confidence: Low"       
        confScore < 0.35 => "Confidence: Low"
        confScore < 0.85 => "Confidence: Medium"
        =>                  "Confidence: High"

    nextBarTxt = switch isContinue 

        true => preText + "\nUsual Next Bar: Continue\nContinue Rate: " + str.tostring(continuationRate * 100, "###.#") + "%\nTypical Continue Move: " + str.tostring(medianMove * 100, format.percent) + confidenceTxt
        =>      preText + "\nUsual Next Bar: Reverse\nReverse Rate: " + str.tostring(reverseRate * 100, "###.#") + "%\nTypical Reverse Move: " + str.tostring(medianMove * 100, format.percent) + confidenceTxt

    nextBarTxtN = switch isContinue

        true => "Continue"
        =>      "Reverse"

    // revLab    := label.new(bar_index + 10, open, textcolor = chart.fg_color, color = color.new(chart.fg_color, 90), style = label.style_text_outline, text = nextBarTxt)

    [y1, y2] = switch isContinue 

        true => [close[1] * (1 + pArr.first()), close[1] * (1 + pArr.get(1))]
        =>      [close[1] * (1 + pArr.get(-2)), close[1] * (1 + pArr.last())]

    bottom = math.min(y1, y2)
    top    = math.max(y1, y2)

    Range = (top - bottom) / 5

    var tableBox = array.new<box>(6)

    for boxes in tableBox
        boxes.delete()

    // col = switch 
        
    //     isContinue and close[1] > close[2] => upCol 
    //     isContinue and close[1] < close[2] => dnCol
    //     not isContinue and close[1] < close[2] => dnCol
    //     not isContinue and close[1] > close[2] => dnCol

    col = switch isContinue
        
        true => color.new(upCol, 70)
        =>      color.new(dnCol, 70)

    tableBox.set(0, box.new(bar_index + 5 + offset, y1, bar_index + 10 + offset, y2, border_color = #1C2234, bgcolor = #14181E))
    tableBox.set(1, box.new(bar_index + 5 + offset, top, bar_index + 10 + offset, top - Range, text = preText, border_color = col, bgcolor = #00000000, text_color = color.white))
    tableBox.set(2, box.new(bar_index + 5 + offset, top - Range, bar_index + 10 + offset, top - Range * 2, text = "Usual Next Bar: " + nextBarTxtN, border_color = col, bgcolor = #00000000, text_color = color.white))
    tableBox.set(3, box.new(bar_index + 5 + offset, top - Range * 2, bar_index + 10 + offset, top - Range * 3, text = nextBarTxtN + " Rate: " + str.tostring(usedRate * 100, "###") + "%", border_color = col, bgcolor = #00000000, text_color = color.white))
    tableBox.set(4, box.new(bar_index + 5 + offset, top - Range * 3, bar_index + 10 + offset, top - Range * 4, text = "Typical " + nextBarTxtN + " Move: " + str.tostring(medianMove * 100, format.percent), border_color = col, bgcolor = #00000000, text_color = color.white))
    tableBox.set(5, box.new(bar_index + 5 + offset, top - Range * 4, bar_index + 10 + offset, top - Range * 5, text = confidenceTxt, border_color = col, bgcolor = #00000000, text_color = color.white))
````
