# Bitcoin Cycle Highs and Lows

- url: https://www.tradingview.com/script/A0Sx24Gr-Bitcoin-Cycle-Highs-and-Lows/
- type: indicator
- pine_id: PUB;b429331811be4de8aa27d6c0addcde60
- version: 1.0

## Description

[b]OVERVIEW[/b]

The Bitcoin Cycle Highs and Lows indicator maps out the historical macro market cycle tops and bottoms of Bitcoin, dating back to 2011. In addition to serving as a visual map of historical market phases, the indicator features an algorithmic projection engine. This engine uses various statistical and geometric decay models to forecast the date and price of future macro highs and lows based on the asset's historical behaviour.

This tool is designed for macro-level market analysis, allowing traders to visualise diminishing returns, cycle duration trends, and phase retracements.

[b]CHART ELEMENTS[/b]

When applied to a chart, the indicator plots several visual elements:

• [b]Vertical Cycle Markers:[/b] Solid vertical lines identify the exact date of historical macro highs (Red) and macro lows (Lime).
• [b]Price & Date Labels:[/b] Located at the anchor of each vertical line, detailing the exact recorded date and price (formatted automatically to the chart's active currency).
• [b]Phase Arrows (Dashed Lines):[/b] Horizontal dashed lines connecting a low to the subsequent high (Bull Phase) or a high to the subsequent low (Bear Phase).
• [b]Phase Statistics:[/b] Floating text labels positioned at the end of each Phase Arrow. These display the duration of the phase in days, the absolute price change, and the percentage move from the previous point.

[b]PREDICTION MODELS[/b]

The indicator includes multiple distinct mathematical models for projecting future dates and prices.

[i]Date Predictors:[/i]

• [b]Previous bar count:[/b] Projects the next date by applying the exact duration of the most recent corresponding cycle.
• [b]Average:[/b] Calculates the simple arithmetic average duration of all historical cycles of the same type.
• [b]Weighted average:[/b] Averages previous cycle lengths but applies a mathematical recency bias, giving more weight to recent cycles to account for cycle duration stabilisation.

[i]Price Predictors:[/i]

• [b]Previous % move:[/b] Projects the next target by applying the exact percentage multiplier of the most recent corresponding cycle.
• [b]Average:[/b] Projects the target using the geometric mean of all historical cycle multipliers, limiting the skew of extreme outliers.
• [b]Diminishing gains:[/b] Analyses the cycle-over-cycle rate of change. It isolates peak-to-peak or trough-to-trough macro moves, calculates the historical decay in those percentage gains, and applies the decayed growth rate to project the next target.
• [b]Fibonacci extension decay:[/b] Evaluates swing ratios by measuring the magnitude of a phase relative to the preceding phase (for example, how far a bull market extended past the previous bear market drop). It calculates the historical decay of that extension premium and applies it to the current swing.

[b]SETTINGS AND INPUTS[/b]

• [b]Predictions:[/b] Determines the number of future cycle highs and lows to project (0 to 9). Set to 0 to disable projections and only view historical data.
• [b]Date predictor:[/b] Selects the algorithmic model used to project the X-axis (time) coordinate of future cycle points.
• [b]Price predictor:[/b] Selects the algorithmic model used to project the Y-axis (price) coordinate of future cycle points.
• [b]Bear/Bull market arrows:[/b] Toggles the visibility of the horizontal dashed lines and their accompanying statistical labels.
• [b]Full height backgrounds:[/b] When true, vertical cycle markers extend infinitely across the Y-axis. When false, markers anchor precisely to the price level of the previous cycle phase, creating a stair-step visualisation.
• [b]Ignore 2011 cycle:[/b] Excludes the extreme volatility and outliers of the 2011 cycle from the indicator's mathematical averages and trend decay calculations.
• [b]Backtest # lows/highs:[/b] A testing feature that temporarily removes the most recent 1 or 2 historical cycle points from the dataset. This allows users to test the prediction models against known outcomes to evaluate their historical accuracy.

## Source Code

````pine
//@version=6
indicator("Bitcoin Cycle Highs and Lows", overlay=true)

// 2 June 2026 - new version by maff, republished

type CyclePoint // Candle of Interest
    int date
    float price
    bool isHigh

isBTC = str.contains(syminfo.ticker, "BTC")

numPredictions = input.int(2, title="Predictions", minval=0, maxval=9, display=display.none, tooltip="The number of cycle highs and lows to predict, following the latest high or low.")
datePredictor = input.string("Weighted average", title="Date predictor", options=["Previous bar count", "Average", "Weighted average"], active=numPredictions>0, display=display.none, tooltip="Date prediction methods:\n\n* Previous bar count: Literally the previous bear or bull cycle length\n\n* Average: All the previous bear or bull cycles' average length\n\n* Weighted average: Averaged previous cycle lengths with more weight given to the most recent cycles")
pricePredictor = input.string("Fibonacci extension decay", title="Price predictor", options=["Previous % move", "Average", "Diminishing gains", "Fibonacci extension decay"], active=numPredictions>0, display=display.none, tooltip="Price prediction methods:\n\n* Previous % move: Literally the previous bear or bull cycle's % price gain/loss\n\n* Average: Geometric average of all the previous bear or bull cycles' price multipliers\n\n* Diminishing gains: Analyzes the rate of change in percentage gains between successive cycle highs (or cycle lows) to project the next target\n\n* Fibonacci extension decay: Measures the magnitude of a phase relative to the preceding phase (Fib extension/retracement), and projects the next target based on the historical decay of that ratio")
showPhaseArrows = input.bool(true, title="Bear/Bull market arrows", display=display.none)
fullHeightBackgrounds = input.bool(false, title="Full height backgrounds", display=display.none)
ignore2011 = input.bool(false, title="Ignore 2011 cycle", display=display.none, tooltip="Excludes the extreme 2011 price movements from all prediction averages and trend calculations.")
backtestCount = input.int(0, title="Backtest # lows/highs", minval=0, maxval=2, active=numPredictions>0, display=display.none, tooltip="Removes this number of most recent actual cycle points, allowing you to compare the prediction with what really happened.")

var cyclePoints = array.from(
     CyclePoint.new(timestamp(2011, 6, 8, 0, 0), na, true),
     CyclePoint.new(timestamp(2011, 11, 18, 0, 0), na, false),
     CyclePoint.new(timestamp(2013, 11, 30, 0, 0), na, true),
     CyclePoint.new(timestamp(2015, 1, 14, 0, 0), na, false),
     CyclePoint.new(timestamp(2017, 12, 17, 0, 0), na, true),
     CyclePoint.new(timestamp(2018, 12, 15, 0, 0), na, false),
     CyclePoint.new(timestamp(2021, 11, 10, 0, 0), na, true),
     CyclePoint.new(timestamp(2022, 11, 21, 0, 0), na, false),
     CyclePoint.new(timestamp(2025, 10, 6, 0, 0), na, true)
 )

if barstate.isfirst
    if numPredictions > 0 and backtestCount > 0
        for i = 1 to backtestCount
            cyclePoints.pop()

if isBTC
    for pt in cyclePoints
        if pt.date >= time and pt.date < time_close
            pt.price := pt.isHigh ? high : low

if isBTC and barstate.islast
    if numPredictions > 0
        for i = 1 to numPredictions
            int sz = cyclePoints.size()
            CyclePoint refStart = cyclePoints.get(sz - 3)
            CyclePoint refEnd = cyclePoints.get(sz - 2)
            CyclePoint lastPt = cyclePoints.get(sz - 1)
            
            bool isPredictingBear = lastPt.isHigh
            
            int sumTimeDiff = 0
            float productPriceMult = 1.0
            int countTime = 0
            int countPrice = 0
            
            float sumWeightedTime = 0.0
            int sumWeights = 0
            
            // Skip indices 0 and 1 (2011 High and Low) if setting is enabled
            int startIdx = ignore2011 ? 2 : 0
            
            for ptIdx = startIdx to sz - 2
                CyclePoint ptStart = cyclePoints.get(ptIdx)
                CyclePoint ptEnd = cyclePoints.get(ptIdx + 1)
                
                bool isHistoricalPhaseBear = ptStart.isHigh
                
                if isHistoricalPhaseBear == isPredictingBear
                    int duration = ptEnd.date - ptStart.date
                    sumTimeDiff += duration
                    countTime += 1
                    
                    // Add to weighted average (recent cycles get larger multipliers)
                    sumWeightedTime += duration * countTime
                    sumWeights += countTime
                    
                    if not na(ptStart.price) and not na(ptEnd.price)
                        float mult = ptEnd.price / ptStart.price
                        productPriceMult *= mult
                        countPrice += 1
                    
            int avgTimeDiff = countTime > 0 ? int(math.round(sumTimeDiff / countTime)) : (refEnd.date - refStart.date)
            int weightedAvgTimeDiff = sumWeights > 0 ? int(math.round(sumWeightedTime / sumWeights)) : avgTimeDiff
            
            float prevPriceMult = na
            if not na(refStart.price) and not na(refEnd.price)
                prevPriceMult := refEnd.price / refStart.price
                
            float avgPriceMult = countPrice > 0 ? math.pow(productPriceMult, 1.0 / countPrice) : prevPriceMult
            
            // --- Diminishing Gains Maths ---
            float diminishingPrice = na
            bool targetIsHigh = not lastPt.isHigh
            float[] targetPrices = array.new_float(0)
            
            for ptIdx = startIdx to sz - 1
                CyclePoint p = cyclePoints.get(ptIdx)
                if p.isHigh == targetIsHigh and not na(p.price)
                    array.push(targetPrices, p.price)
            
            if array.size(targetPrices) >= 2
                float[] gains = array.new_float(0)
                for k = 1 to array.size(targetPrices) - 1
                    float prevP = array.get(targetPrices, k - 1)
                    float currP = array.get(targetPrices, k)
                    if prevP != 0
                        array.push(gains, (currP - prevP) / prevP)
                    
                float nextGain = na
                if array.size(gains) > 1
                    float sumRatio = 0.0
                    int validRatios = 0
                    for k = 1 to array.size(gains) - 1
                        float prevGain = array.get(gains, k - 1)
                        if prevGain != 0
                            sumRatio += array.get(gains, k) / prevGain
                            validRatios += 1
                    if validRatios > 0
                        float avgRatio = sumRatio / validRatios
                        nextGain := array.get(gains, array.size(gains) - 1) * avgRatio
                else if array.size(gains) == 1
                    nextGain := array.get(gains, 0)
                    
                if not na(nextGain)
                    diminishingPrice := array.get(targetPrices, array.size(targetPrices) - 1) * (1 + nextGain)
                    
            // --- Fibonacci Extension Decay Maths ---
            float fibDecayPrice = na
            float[] fibRatios = array.new_float(0)
            
            for ptIdx = math.max(1, startIdx) to sz - 2
                CyclePoint ptPrev = cyclePoints.get(ptIdx - 1)
                CyclePoint ptStart = cyclePoints.get(ptIdx)
                CyclePoint ptEnd = cyclePoints.get(ptIdx + 1)
                
                bool isHistoricalPhaseBear = ptStart.isHigh
                if isHistoricalPhaseBear == isPredictingBear
                    if not na(ptPrev.price) and not na(ptStart.price) and not na(ptEnd.price)
                        float prevMag = math.abs(ptStart.price - ptPrev.price)
                        float currMag = math.abs(ptEnd.price - ptStart.price)
                        if prevMag != 0
                            float ratio = currMag / prevMag
                            // If predicting a Bull High, only decay the "Premium" above 1.0 (100% recovery)
                            if not isPredictingBear
                                ratio := math.max(0.001, ratio - 1.0)
                            array.push(fibRatios, ratio)
            
            float nextFibRatio = na
            if array.size(fibRatios) > 1
                float sumDecay = 0.0
                int validDecays = 0
                for k = 1 to array.size(fibRatios) - 1
                    float prevRatio = array.get(fibRatios, k - 1)
                    if prevRatio != 0
                        sumDecay += array.get(fibRatios, k) / prevRatio
                        validDecays += 1
                if validDecays > 0
                    float avgDecay = sumDecay / validDecays
                    nextFibRatio := array.get(fibRatios, array.size(fibRatios) - 1) * avgDecay
            else if array.size(fibRatios) == 1
                nextFibRatio := array.get(fibRatios, 0)
                
            if not na(nextFibRatio)
                // Add the 1.0 base back to the predicted Premium to get the true extension ratio
                if not isPredictingBear
                    nextFibRatio := 1.0 + nextFibRatio
                    
                float lastPhaseMag = math.abs(lastPt.price - refEnd.price)
                float projectedMag = lastPhaseMag * nextFibRatio
                fibDecayPrice := isPredictingBear ? lastPt.price - projectedMag : lastPt.price + projectedMag
            
            // --- Predictions ---
            int predictedDate = switch datePredictor
                "Previous bar count" => lastPt.date + (refEnd.date - refStart.date)
                "Average" => lastPt.date + avgTimeDiff
                "Weighted average" => lastPt.date + weightedAvgTimeDiff
                => lastPt.date
                
            float predictedPrice = switch pricePredictor
                "Previous % move" => not na(prevPriceMult) and not na(lastPt.price) ? lastPt.price * prevPriceMult : na
                "Average" => not na(avgPriceMult) and not na(lastPt.price) ? lastPt.price * avgPriceMult : na
                "Diminishing gains" => diminishingPrice
                "Fibonacci extension decay" => fibDecayPrice
                => lastPt.price
            
            cyclePoints.push(CyclePoint.new(predictedDate, predictedPrice, not lastPt.isHigh))

    if cyclePoints.size() > 0
        for i = 0 to cyclePoints.size() - 1
            CyclePoint pt = cyclePoints.get(i)
            
            string labelText = str.format("{0,date,dd MMM yyyy}", pt.date)
            float yPos = close // Fallback position if price is N/A
            
            if not na(pt.price)
                labelText += "\n" + str.tostring(math.round(pt.price), "#,##0") + " " + syminfo.currency
                yPos := pt.price
            else
                labelText += "\nPrice N/A"
            
            float y1 = 0.0
            float y2 = 1.0
            string ext = extend.both
            
            if not fullHeightBackgrounds
                ext := extend.none
                y2 := yPos
                
                // Connect to the previous cycle's horizontal line
                float prevPrice = yPos
                if i > 0
                    for j = i - 1 to 0
                        float p = cyclePoints.get(j).price
                        if not na(p)
                            prevPrice := p
                            break
                y1 := prevPrice
            
            line.new(pt.date, y1, pt.date, y2, xloc=xloc.bar_time, extend=ext, width=3, color=pt.isHigh ? color.lime : color.red, style=line.style_solid)
            
            label.new(pt.date, yPos, labelText, xloc=xloc.bar_time, color=pt.isHigh ? color.rgb(0,100,0) : color.red, style=pt.isHigh ? label.style_label_down : label.style_label_up, textcolor=color.white)

        for i = 0 to cyclePoints.size() - 2
            CyclePoint ptStart = cyclePoints.get(i)
            CyclePoint ptEnd = cyclePoints.get(i + 1)
            
            bool isBear = ptStart.isHigh
            color phaseColor = isBear ? color.red : color.lime
            float phaseYPos = ptStart.price
            
            if showPhaseArrows and not na(phaseYPos)
                line.new(ptStart.date, phaseYPos, ptEnd.date, phaseYPos, xloc=xloc.bar_time, color=phaseColor, style=line.style_dashed)
                
                int days = math.round((ptEnd.date - ptStart.date) / 86400000)
                
                string phaseText = str.tostring(days) + " days"
                if not na(ptEnd.price)
                    float priceDiff = ptEnd.price - ptStart.price
                    float pctMove = (priceDiff / ptStart.price) * 100
                    string sign = priceDiff > 0 ? "+" : ""
                    phaseText += "\n" + sign + str.tostring(math.round(priceDiff), "#,##0") + " " + syminfo.currency + "\n" + sign + str.tostring(pctMove, "#.##") + "%"
                    
                label.new(ptEnd.date, phaseYPos, phaseText, xloc=xloc.bar_time, style=isBear ? label.style_label_lower_right : label.style_label_upper_right, color=color.new(color.white, 100), textcolor=color.white)
````
