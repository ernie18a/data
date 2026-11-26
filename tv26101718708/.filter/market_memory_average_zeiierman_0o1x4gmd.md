# Market Memory Average (Zeiierman)

- url: https://www.tradingview.com/script/0O1X4gMd-Market-Memory-Average-Zeiierman/
- type: indicator
- pine_id: PUB;d9249e61173f486fbf9be673ddf502d0
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Market Memory Average (Zeiierman)[/b] is a similarity-based market regime tool that scans historical price behavior to identify past conditions that closely resemble the current market state.

The script compares momentum, RSI, volatility, and relative volume to build a “market memory” model. It then extracts the internal momentum of the most similar historical states and blends them into a dynamic projection line.

The result is an adaptive average that reflects how the market has historically behaved when conditions looked like this, rather than relying on fixed formulas or traditional lagging averages.
[image]https://www.tradingview.com/x/QGxkRFun/[/image]

█ [b]How It Works[/b]

⚪ [b]Market State Encoding[/b]
The script defines the current market using momentum (ROC), RSI, volatility (ATR%), and relative volume. These features describe how the market is behaving, not just price position.

⚪ [b]Historical Similarity Scan[/b]
Each past bar is compared to the current state using a multi-feature distance model.

[b]Closer matches receive higher weights through exponential decay:[/b]
[pine]similarity = 100 * exp(-distance * sensitivity)[/pine]
⚪ [b]Top Match Selection[/b]
The script ranks all historical states and keeps only the most similar ones. These represent past environments that closely resemble current conditions.

⚪ [b]Memory Momentum[/b]
From each match, the script extracts its internal momentum (ROC).

[b]A similarity-weighted average is then calculated:[/b]
[pine]avgMomentum = weightedMomentum / totalWeight[/pine]
⚪ [b]Market Memory Average[/b]

[b]This averaged momentum is applied to the current price to form the line:[/b]
[pine]memoryLine = close * (1 + avgMomentum / 100)[/pine]
The result reflects how similar market states have historically behaved.

⚪ [b]Historical Match Zones[/b]
Optional boxes highlight where similar conditions occurred in the past, along with their similarity strength.

█ [b]How to Use[/b]

⚪ [b]Market Memory Average[/b]
[list]
[*][b]Bullish color →[/b] market conditions align with historically positive momentum.
[*][b]Bearish color →[/b] market conditions align with historically negative momentum.
[/list]
Unlike traditional averages, this line is built from the similarity-weighted momentum of past market matches. The cloud and structure dynamically adapt based on how those historical conditions behaved.

This gives the line a context-driven, memory-based approach, rather than relying on fixed calculations. The result is a dynamic reference for directional bias and regime context, grounded in how the market has behaved under similar conditions before.
[image]https://www.tradingview.com/x/7ymtioy8/[/image]
⚪ [b]Study Historical Match Zones (Example 1)[/b]
The match boxes show where similar market conditions occurred in the past, based on momentum, volatility, RSI, and volume alignment.

Each box represents a moment where the market behaved as it does now.

[b]These zones can help:[/b]
[list]
[*][b]Visualize recurring structures:[/b] See how similar conditions previously formed, such as pullbacks, bottoms, or consolidation phases within a trend.
[*][b]Identify behavioral clustering:[/b] When multiple matches appear around similar types of price action, it suggests the market frequently revisits this behavior.
[*][b]Understand the current environment:[/b] By comparing where those matches occurred (trend, range, recovery), you can interpret what kind of phase the market is currently in.
[*][b]Build a contextual bias:[/b] If most matches come from pullbacks and recoveries (as in the example), the current state aligns more with pause → stabilize → continue behavior, rather than reversal or breakdown conditions.
[/list]
These zones provide context, not prediction, helping you understand how the market is behaving relative to its own history.
[image]https://www.tradingview.com/x/CgHcLOOC/[/image]
⚪ [b]Study Historical Match Zones (Example 2)[/b]
In this example, the current market state most closely aligns with these two highlighted zones.

[b]Both matches formed during bearish conditions:[/b]
[list]
[*]The left match shows a rejection after a strong move up, with momentum quickly flipping into a sharp drop.
[*]The right match shows a weak bounce inside a downtrend, where the price attempted to recover but continued lower.
[/list]

[b]Looking at the current state (circled area), the price is:[/b]
[list]
[*]Breaking down aggressively
[*]Moving similarly to those past rejection phases
[/list]
This suggests the current behavior aligns more with rejection → continuation, rather than stabilization or reversal.
[image]https://www.tradingview.com/x/zjbfYazj/[/image]
█ [b]Settings[/b]
[list]
[*][b]Historical Scan Depth: [/b]Controls how far back the script searches for similar market states.
[*][b]Top Similar Matches:[/b] Determines how many historical matches influence the average.
[*][b]Historical Pattern Length:[/b] Sets the width of the displayed historical match zones.
[*][b]Similarity Sensitivity:[/b] Controls how strict the similarity comparison is.
[*][b]RSI Length:[/b] Defines the oscillator component of the market state.
[*][b]ATR Length:[/b] Controls volatility measurement used in both similarity and cloud calculations.
[*][b]Volume MA Length:[/b] Defines how relative volume is calculated.
[*][b]Average Smoothing:[/b] Controls the responsiveness of the Market Memory Average.
[*][b]Slope Detection Length:[/b] Determines how trend direction is evaluated.
[*][b]Cloud Spread:[/b] Controls how far the cloud extends from the line.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Market Memory Average (Zeiierman)", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 2000)
//}

// ~~ Tooltips {
t1  = "Controls how many historical market states are scanned when searching for conditions similar to the current market. Higher values search more history but may be heavier."
t2  = "Controls how many of the closest historical matches are used. These top-ranked matches influence the Market Memory Average and optional historical match boxes."
t3  = "Controls how many bars are included inside each historical match box. Higher values show a wider historical pattern area."
t4  = "Controls how strict the similarity matching is. Higher values require closer matches and reduce weaker comparisons. Lower values allow broader historical matches."

t5  = "RSI length used as one of the market-state features. The current RSI condition is compared against historical RSI conditions."
t6  = "ATR length used to measure volatility as one of the market-state features. The current volatility condition is compared against historical volatility."
t7  = "Volume moving average length used to calculate relative volume. Current relative volume is compared against historical relative volume."

t8  = "Shows or hides the Market Memory Average line. This line is built from the similarity-weighted momentum of the closest historical matches."
t9  = "Controls the smoothing applied to the Market Memory Average. Higher values create a smoother, slower line. Lower values make it more reactive."
t10 = "Controls how many bars are used to measure the slope of the Market Memory Average for bullish, bearish, or neutral coloring."

t11 = "Shows or hides the Memory Cloud around the Market Memory Average."
t12 = "Controls how far the cloud extends from the Market Memory Average. When the line is bullish, the cloud is below the line. When the line is bearish, the cloud is above the line."
t13 = "Controls the transparency of the Memory Cloud. Higher values make the cloud more transparent."

t14 = "Shows or hides the historical match boxes that mark where the closest past market states occurred."
t15 = "Color used when the Market Memory Average slope is bullish, and for bullish historical match boxes."
t16 = "Color used when the Market Memory Average slope is bearish, and for bearish historical match boxes."
t17 = "Color used when the Market Memory Average slope is neutral, and for neutral historical match boxes."
t18 = "Shows or hides the historical match labels."
t19 = "Controls the size of the historical match label text."
t20 = "Controls the color of the historical match label text."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
gMemory   = "Market Memory"
gFeatures = "Similarity Features"
gAvg      = "Memory Average"
gCloud    = "Memory Cloud"
gStyle    = "Style"

scanDepth   = input.int(300, "Historical Scan Depth", minval = 20, maxval = 2000, tooltip = t1, group = gMemory)
topMatches  = input.int(5, "Top Similar Matches", minval = 2, maxval = 20, tooltip = t2, group = gMemory)
patternBars = input.int(10, "Historical Pattern Length", minval = 3, maxval = 50, tooltip = t3, group = gMemory)
sensitivity = input.float(1.5, "Similarity Sensitivity", minval = 0.1, maxval = 5.0, step = 0.1, tooltip = t4, group = gMemory)

rsiLength = input.int(14, "RSI Length", minval = 1, tooltip = t5, group = gFeatures)
atrLength = input.int(14, "ATR Length", minval = 2, tooltip = t6, group = gFeatures)
volLength = input.int(20, "Volume MA Length", minval = 2, tooltip = t7, group = gFeatures)

showSmartLine     = input.bool(true, "Show Market Memory Average", tooltip = t8, group = gAvg)
smartSmoothLength = input.int(50, "Average Smoothing", minval = 1, maxval = 200, tooltip = t9, group = gAvg)
smartTrendLength  = input.int(20, "Slope Detection Length", minval = 1, maxval = 200, tooltip = t10, group = gAvg)

showCloud   = input.bool(true, "Show Cloud", tooltip = t11, group = gCloud)
cloudSpread = input.float(1.5, "Cloud Spread", minval = 0.1, step = 0.1, tooltip = t12, group = gCloud)
cloudTransp = input.int(65, "Cloud Transparency", minval = 0, maxval = 95, tooltip = t13, group = gCloud)

showMatchBoxes  = input.bool(true, "Show Historical Match Boxes", tooltip = t14, group = gStyle)
bullColor       = input.color(color.new(color.lime, 0), "Bullish", tooltip = t15, group = gStyle)
bearColor       = input.color(color.new(color.red, 0), "Bearish", tooltip = t16, group = gStyle)
neutralColor    = input.color(color.new(color.blue, 0), "Neutral", tooltip = t17, group = gStyle)
showMatchLabels = input.bool(true, "Show Historical Match Labels", tooltip = t18, group = gStyle)
matchLabelSizeIn = input.string("Small", "Label Text Size", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], tooltip = t19, group = gStyle)
matchLabelColor  = input.color(color.gray, "Label Text Color", tooltip = t20, group = gStyle)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
labelSize(txt) =>
    switch txt
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

matchLabelSize = labelSize(matchLabelSizeIn)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ UDT for historical pattern matches {
type PatternMatch
    float similarity
    float momentum
    int   barsAgo
    int   direction
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Feature calculations {
roc1   = ta.roc(close, 1)
roc3   = ta.roc(close, 3)
roc5   = ta.roc(close, 5)
rsiVal = ta.rsi(close, rsiLength) / 100.0
atrVal = ta.atr(atrLength) / close * 100.0
volMA  = ta.sma(volume, volLength)
volRel = volMA != 0 ? volume / volMA : 1.0

max_bars_back(roc1, 2000)
max_bars_back(roc3, 2000)
max_bars_back(roc5, 2000)
max_bars_back(rsiVal, 2000)
max_bars_back(atrVal, 2000)
max_bars_back(volRel, 2000)
max_bars_back(close, 2000)
max_bars_back(high, 2000)
max_bars_back(low, 2000)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Current pattern features {
curRoc1 = roc1
curRoc3 = roc3
curRoc5 = roc5
curRsi  = rsiVal
curAtr  = atrVal
curVol  = volRel

var array<PatternMatch> matches = array.new<PatternMatch>()
var array<box> matchBoxes = array.new<box>()
var array<label> matchLabels = array.new<label>()

var float similaritySmartLine = na

if bar_index > scanDepth + patternBars
    matches.clear()

    int maxScan = math.min(scanDepth, bar_index - patternBars - 1)

    for barsAgo = patternBars + 1 to maxScan
        float histRoc1 = roc1[barsAgo]
        float histRoc3 = roc3[barsAgo]
        float histRoc5 = roc5[barsAgo]
        float histRsi  = rsiVal[barsAgo]
        float histAtr  = atrVal[barsAgo]
        float histVol  = volRel[barsAgo]

        float d1 = math.abs(curRoc1 - histRoc1) / 2.0
        float d2 = math.abs(curRoc3 - histRoc3) / 4.0
        float d3 = math.abs(curRoc5 - histRoc5) / 6.0
        float d4 = math.abs(curRsi - histRsi) * 2.0
        float d5 = math.abs(curAtr - histAtr) / 2.0
        float d6 = math.abs(curVol - histVol) / 1.5

        float distance = d1 + d2 + d3 + d4 + d5 + d6
        float similarity = 100.0 * math.exp(-distance * sensitivity)

        float momentum = histRoc5
        int direction = momentum > 0 ? 1 : momentum < 0 ? -1 : 0

        matches.push(PatternMatch.new(similarity, momentum, barsAgo, direction))

    matches.sort(order.descending, sort_field = "similarity")

    int rows = math.min(topMatches, matches.size())

    float weightedMomentum = 0.0
    float totalWeight = 0.0

    for i = 0 to rows - 1
        PatternMatch m = matches.get(i)

        weightedMomentum += m.momentum * m.similarity
        totalWeight += m.similarity

    float avgWeightedMomentum = totalWeight != 0 ? weightedMomentum / totalWeight : na

    similaritySmartLine := showSmartLine and rows > 0 ? close * (1 + avgWeightedMomentum / 100.0) : na

    if barstate.islast
        if matchBoxes.size() > 0
            for b in matchBoxes
                box.delete(b)
            matchBoxes.clear()

        if matchLabels.size() > 0
            for lb in matchLabels
                label.delete(lb)
            matchLabels.clear()

        array<int> boxLefts = array.new_int()
        array<int> boxRights = array.new_int()
        array<float> boxTops = array.new_float()
        array<float> boxBots = array.new_float()
        array<string> boxTexts = array.new_string()
        array<int> boxDirs = array.new_int()

        if showMatchBoxes
            for i = 0 to rows - 1
                PatternMatch m = matches.get(i)

                int rightIndex = bar_index - m.barsAgo
                int leftIndex  = rightIndex - patternBars

                float boxHigh = high[m.barsAgo]
                float boxLow  = low[m.barsAgo]

                for j = 0 to patternBars - 1
                    boxHigh := math.max(boxHigh, high[m.barsAgo + j])
                    boxLow  := math.min(boxLow, low[m.barsAgo + j])

                string matchText = "#" + str.tostring(i + 1) + " " + str.tostring(m.similarity, "#.##") + "%"

                bool merged = false

                if array.size(boxLefts) > 0
                    for k = 0 to array.size(boxLefts) - 1
                        int existingLeft  = array.get(boxLefts, k)
                        int existingRight = array.get(boxRights, k)
                        float existingTop = array.get(boxTops, k)
                        float existingBot = array.get(boxBots, k)

                        bool timeOverlap = leftIndex <= existingRight and rightIndex >= existingLeft
                        bool priceOverlap = boxLow <= existingTop and boxHigh >= existingBot

                        if timeOverlap and priceOverlap
                            array.set(boxLefts, k, math.min(existingLeft, leftIndex))
                            array.set(boxRights, k, math.max(existingRight, rightIndex))
                            array.set(boxTops, k, math.max(existingTop, boxHigh))
                            array.set(boxBots, k, math.min(existingBot, boxLow))
                            array.set(boxTexts, k, array.get(boxTexts, k) + "\n" + matchText)
                            array.set(boxDirs, k, array.get(boxDirs, k) + m.direction)
                            merged := true
                            break

                if not merged
                    array.push(boxLefts, leftIndex)
                    array.push(boxRights, rightIndex)
                    array.push(boxTops, boxHigh)
                    array.push(boxBots, boxLow)
                    array.push(boxTexts, matchText)
                    array.push(boxDirs, m.direction)

            if array.size(boxLefts) > 0
                for k = 0 to array.size(boxLefts) - 1
                    int dirSum = array.get(boxDirs, k)
                    color boxColor = dirSum > 0 ? bullColor : dirSum < 0 ? bearColor : neutralColor

                    int left = array.get(boxLefts, k)
                    int right = array.get(boxRights, k)
                    float top = array.get(boxTops, k)
                    float bot = array.get(boxBots, k)

                    box histBox = box.new(
                         left = left,
                         right = right,
                         top = top,
                         bottom = bot,
                         bgcolor = color.new(boxColor, 85),
                         border_color = boxColor
                    )

                    matchBoxes.push(histBox)

                    float labelY = dirSum >= 0 ? bot : top

                    if showMatchLabels
                        label histLabel = label.new(
                             x = int(math.avg(left, right)),
                             y = labelY,
                             text = array.get(boxTexts, k),
                             style = dirSum >= 0 ? label.style_label_up : label.style_label_down,
                             textcolor = matchLabelColor,
                             color = color.new(color.black, 100),
                             size = matchLabelSize
                        )

                        matchLabels.push(histLabel)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Similarity Trend Line {
smoothedSmartLine = ta.ema(similaritySmartLine, smartSmoothLength)
smartSlope = smoothedSmartLine - smoothedSmartLine[smartTrendLength]
smartColor = smartSlope > 0 ? bullColor : smartSlope < 0 ? bearColor : neutralColor

cloudLine = smoothedSmartLine
cloudRef = smoothedSmartLine + ta.atr(atrLength) * cloudSpread * (smartSlope > 0 ? -1 : smartSlope < 0 ? 1 : 0)

cloudA = not na(cloudLine) and not na(cloudRef) ? cloudLine + (cloudRef - cloudLine) * 0.25 : na
cloudB = not na(cloudLine) and not na(cloudRef) ? cloudLine + (cloudRef - cloudLine) * 0.50 : na
cloudC = not na(cloudLine) and not na(cloudRef) ? cloudLine + (cloudRef - cloudLine) * 0.75 : na

pCloudLine = plot(showCloud ? cloudLine : na, "Cloud Main", color = color.new(chart.fg_color, 100), display = display.none)
pCloudA    = plot(showCloud ? cloudA : na, "Cloud Layer A", color = color.new(chart.fg_color, 100), display = display.none)
pCloudB    = plot(showCloud ? cloudB : na, "Cloud Layer B", color = color.new(chart.fg_color, 100), display = display.none)
pCloudC    = plot(showCloud ? cloudC : na, "Cloud Layer C", color = color.new(chart.fg_color, 100), display = display.none)
pCloudRef  = plot(showCloud ? cloudRef : na, "Cloud Reference", color = color.new(chart.fg_color, 100), display = display.none)

fill(pCloudLine, pCloudA, color = showCloud ? color.new(smartColor, math.max(0, cloudTransp - 18)) : na, title = "Cloud Fill 1")
fill(pCloudA, pCloudB, color = showCloud ? color.new(smartColor, math.max(0, cloudTransp - 6)) : na, title = "Cloud Fill 2")
fill(pCloudB, pCloudC, color = showCloud ? color.new(smartColor, math.min(95, cloudTransp + 6)) : na, title = "Cloud Fill 3")
fill(pCloudC, pCloudRef, color = showCloud ? color.new(smartColor, math.min(95, cloudTransp + 18)) : na, title = "Cloud Fill 4")

plot(showSmartLine ? smoothedSmartLine : na, "Market Memory Average", color = smartColor, linewidth = 3)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
crossUp = ta.crossover(close, smoothedSmartLine)
crossDn = ta.crossunder(close, smoothedSmartLine)

avgBull = smartSlope > 0
avgBear = smartSlope < 0
avgNeutral = smartSlope == 0

avgBullChange = avgBull and not avgBull[1]
avgBearChange = avgBear and not avgBear[1]
avgNeutralChange = avgNeutral and not avgNeutral[1]

alertcondition(crossUp, "Price Crossed Above Average", "Price crossed above the Market Memory Average.")
alertcondition(crossDn, "Price Crossed Below Average", "Price crossed below the Market Memory Average.")

alertcondition(avgBullChange, "Average Changed Bullish", "Market Memory Average changed to bullish coloring.")
alertcondition(avgBearChange, "Average Changed Bearish", "Market Memory Average changed to bearish coloring.")
alertcondition(avgNeutralChange, "Average Changed Neutral", "Market Memory Average changed to neutral coloring.")

alertcondition(crossUp or crossDn, "Any Average Cross", "Price crossed the Market Memory Average.")
alertcondition(avgBullChange or avgBearChange or avgNeutralChange, "Any Average Color Change", "Market Memory Average changed color.")
alertcondition(crossUp or crossDn or avgBullChange or avgBearChange or avgNeutralChange, "Any Market Memory Alert", "A Market Memory Average alert condition triggered.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
