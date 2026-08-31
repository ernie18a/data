<!-- tradingview-pine-id: PUB;2468f641250d416c9e3f372a6e75db74 -->
<!-- tradingviewscripts-format: 1 -->
# Volume composition / Flowly Indicators

Source: https://www.tradingview.com/script/d4TDeuRU-Volume-composition-Flowly-Indicators/

## Description

— Overview

While net volume is useful information, it can be a blunt data point. Volume composition breaks down the content of volume, allowing a more detailed look inside each volume node. Volume composition consists of the following information:

Total volume (buy and sell). By default gray node.
Dominating volume (buy or sell). By default dark green/dark red node.
Dominating active volume (buy or sell). By default light green/light red node.
Dominating volume as percentage of total volume.
Dominating active volume as percentage of total active volume.

Buy and sell volume is defined by volume associated with lower timeframe up/down moves. This classification is further broken down to passive/active, standing for decreasing/increasing volume, e.g. a move up with volume higher than previous bar volume = active buy volume, a move up with volume lower than previous bar volume = passive buy volume. 

[image]https://www.tradingview.com/x/fTsoQ5kp/[/image]

Volume data is fetched from a lower timeframe that is automatically adjusted to fit the timeframe you're using. By default, the following settings are applied:

Charts <= 30 min: 1 minute timeframe
Charts > 30 min & <= 3 hours : 5 minute timeframe
Charts > 3 hours & <= 8 hours : 15 minute timeframe
Charts > 8 hours & <= 1D: 1 hour timeframe
Charts > 1D & <= 3D : 2 hour timeframe
Charts > 3D: 4 hour timeframe

Timeframe settings can be changed via input menu. The lower the timeframe, the more precision you get but with the cost of less historical data and slower loading time. Users can also choose which source to use for determining buy/sell volume, e.g. using close as source, a close that is higher than previous close would be considered as buy volume. This could be replaced with OHLC4 for example, resulting in a volume direction based on OHLC average.

Volume composition of current chart can also be replaced with any other chart volume composition:

[image]https://www.tradingview.com/x/KNPDCFOs/[/image]

— Visuals

Breakdown of visual elements:

1. Symbol and timeframe used for volume composition calculations. By default the chart that is viewed and automatically selected lower timeframe.
2. Dominating volume threshold exceeded. Can be defined via input menu, 70% of total volume by default.
3. Dominating volume as percentage of total volume. Plotted below volume nodes, without % symbol.
4. Dominating active volume, + or - symbol, standing for buy and sell. Plotted below dominating volume percentage. When dominating volume and dominating active volume sides are in a disagreement (e.g. dominating volume is on buy side while dominating active volume is on sell side) this symbol will appear inside brackets, (+) or (-).
5. Dominating active volume as percentage of total active volume. Plotted below +/- symbol.
6. Dominating active volume threshold exceeded. Can be defined via input menu, 70% by default.

[image]https://www.tradingview.com/x/luqsjjky/[/image]

Dominating volume & active volume percentages can be rounded to single numbers to avoid clutter caused by overlapping values. The percentage values will be rounded to closest single number value, e.g. dominating volume percentage at 54% = 5, dominating volume percentage at 55% = 6.

[image]https://www.tradingview.com/x/n8R0puGv/[/image]
[image]https://www.tradingview.com/x/gYGwezks/[/image]

Volume anomalies can be highlighted on the chart with a color for studying the events and their past implications in greater detail. Available anomalies for highlights are the following:

Buy volume threshold exceeded
Sell volume threshold exceeded
Active buy volume threshold exceeded
Active sell volume threshold exceeded
Volume & active volume divergence

[image]https://www.tradingview.com/x/nUkQv74B/[/image]

— Practical guide

Volume is arguably one of the most important data points as it directly relates to liquidity. High volume can be an indication of strength (price likely to continue moving) or absorption (price likely to halt/turn). Same applies to active volume, but with an element of aggression. High active volume serves as an indication of exuberance or otherwise forceful transacting, like stop losses triggering. With these principles in mind, the composition of volume allows distinguishing potentially important events.

Example #1: Identifying areas of trapped market participants

Often when volume spikes distinctively, we can make the case that price has found sufficient liquidity to halt/turn. Since we know which side was absorbed, in what quantity and type (passive/active), we can identify areas of trapped market participants. In such scenarios, the higher the dominant active volume and volume spike itself, the better.

[image]https://www.tradingview.com/x/N9Sd57js/[/image]

Example #2: Identifying a healthy trend

A healthy trend is one that has an active and consistent bid driving it. When this is the case, it can be seen in consistently supportive active volume.

[image]https://www.tradingview.com/x/6zaM5FRS/[/image]

Example #3: Identifying inflection points

When dominant side of volume and dominant side of active volume diverge, something is up. A divergence often marks an area of indecision, hinting an imminent move one way or the other.

[image]https://www.tradingview.com/x/x657AjAr/[/image]

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © quantifytools

//@version=5
indicator("Volume composition / Flowly Indicators", overlay=false, max_boxes_count=500, max_lines_count = 500, max_labels_count=500)


//                      Inputs

//Volume inputs
groupVol = "Volume settings"
i_smoothingType = input.string("SMA", "Volume moving average", options=["SMA", "EMA", "HMA", "RMA", "WMA"], group=groupVol, inline="ma")
i_volSmaLength = input.int(20, "", group=groupVol, inline="ma")
i_source = input.source(close, "Source for volume direction", group=groupVol, tooltip="E.g. current close > previous close = buy volume.")
i_volThreshold = input.int(70, "High volume threshold %", maxval=100, minval=1, group=groupVol)
i_volAThreshold = input.int(70, "High active volume threshold %", maxval=100, minval=1, group=groupVol)
i_relVol = input.bool(false, "Use relative volume", group=groupVol, tooltip = "Relative volume displays volume relative to moving average, e.g. 1.5 = 1.5x higher than moving average")

//Volume source inputs
groupSource = "Volume source"
i_symbolBool = input.bool(false, "Override chart volume with custom symbol volume", group=groupSource)
i_symbolVolume = input.symbol("BTCUSDT", "Symbol for volume data", group=groupSource)

//Timeframe inputs
groupTf = "Timeframe settings"
i_tf1 = input.timeframe("1", "LTF for charts <= 30 min", group=groupTf, tooltip="Choose which timeframes are used for volume data when viewed within a given timeframe bracket. E.g. volume data is pulled from 1 minute timeframe when viewing charts at or below 30 min. The lower the chosen timeframe, the more precision you get, but with the cost of less historical data.")
i_tf2 = input.timeframe("5", "LTF for charts > 30 min & <= 3 hours", group=groupTf)
i_tf3 = input.timeframe("15", "LTF for charts > 3 hours & <= 8 hours", group=groupTf)
i_tf4 = input.timeframe("60", "LTF for charts > 8 hours & <= 1D", group=groupTf)
i_tf5 = input.timeframe("120", "LTF for charts > 1D & <= 3D", group=groupTf)
i_tf6 = input.timeframe("240", "LTF for charts > 3D", group=groupTf)

//Visual inputs
groupVisuals = "Visual settings"
i_displayMode = input.bool(false, "Round percentage values to single numbers", group=groupVisuals, tooltip="Helps with visual clutter when zooming out. Rounded to closest value, e.g. 54% = 5, 56% = 6.")
i_buyVolCol = input.color(color.teal, "Buy volume", group=groupVisuals, inline="buy")
i_buyVolACol = input.color(color.green, "Active", group=groupVisuals, inline="buy")
i_sellVolCol = input.color(color.maroon, "Sell volume", group=groupVisuals, inline="sell")
i_sellVolACol = input.color(color.red, "Active", group=groupVisuals, inline="sell")
i_totalVolCol = input.color(color.gray, "Total volume", group=groupVisuals, inline="total")
i_smaVolCol = input.color(color.gray, "MA", group=groupVisuals, inline="total")

//Anomaly inputs
groupMultiCond = "Multi-condition highlights"

i_multiCondition = input.bool(false, "Multi-condition highlights", group=groupMultiCond, inline="multicond")
i_multiConditionCol = input.color(color.yellow, "", group=groupMultiCond, inline="multicond",tooltip = "Overrides individual anomaly highlights with instances where all selected anomalies occured simultaneously. Example: highlight on a wick down with buy volume threshold and active buy volume threshold exceeded.")
i_candleFormation = input.string("Close ▲", "Candle formation", options=["Close ▲", "Close ▼", "Reversal ▲", "Reversal ▼", "Expansion ▲", "Expansion ▼"], group=groupMultiCond, inline="candle")
i_candleFormationBool = input.bool(false, "", group=groupMultiCond, inline="candle")

i_volMultiplier = input.float(1, "Volume multiplier", 0.05, 100, step=0.05, inline="volmult", group=groupMultiCond)
i_volMultiplierBool = input.bool(false, "", group=groupMultiCond, inline="volmult")

groupAnomaly = "Anomaly highlights"

i_highlightDomBuyVol = input.bool(false, "Buy volume threshold exceeded", group=groupAnomaly, inline="buyvol")
i_domBuyVolCol = input.color(color.teal, "", group=groupAnomaly, inline="buyvol", tooltip="Colorizes candles on your chart where selected volume anomaly has occured. Useful for gaining reference from the past to get an idea what to expect in the future. Note that context matters a lot.")

i_highlightDomABuyVol = input.bool(false, "Active buy volume threshold exceeded", group=groupAnomaly, inline="buyvola")
i_domABuyVolCol = input.color(color.green, "", group=groupAnomaly, inline="buyvola")

i_highlightDomSellVol = input.bool(false, "Sell volume threshold exceeded", group=groupAnomaly, inline="sellvol")
i_domSellVolCol = input.color(color.maroon, "", group=groupAnomaly, inline="sellvol")

i_highlightDomASellVol = input.bool(false, "Active sell volume threshold exceeded", group=groupAnomaly, inline="sellvola")
i_domASellVolCol = input.color(color.red, "", group=groupAnomaly, inline="sellvola")

i_highlightDivergence = input.bool(false, "Passive-active volume divergence", group=groupAnomaly, inline="divergence")
i_divergenceCol = input.color(color.fuchsia, "", group=groupAnomaly, inline="divergence")


//                      LTF calculations

//If bool is false, use chart symbol, else symbol defined via input menu
volumeSource = i_symbolBool == false ? syminfo.tickerid : i_symbolVolume

//Convert current timeframe into minutes
currentTimeframe = timeframe.in_seconds(timeframe.period) / 60

//Dynamic timeframe logic
dynTf = currentTimeframe <= 30 ? i_tf1 : currentTimeframe > 30 and currentTimeframe <= 180 ? i_tf2 :
 currentTimeframe > 180 and currentTimeframe <= 480 ? i_tf3 : currentTimeframe > 480 and currentTimeframe <= 1440 ? i_tf4 :
  currentTimeframe > 1440 and currentTimeframe <= 4320 ? i_tf5 : currentTimeframe > 4320 ? i_tf6 : na

//Fetching LTF volume
ltfStats() =>

    buyVol = i_source >= i_source[1] ? volume : 0
    sellVol = i_source < i_source[1] ? volume : 0
    
    buyVolActive = i_source >= i_source[1] and volume > volume[1] ? volume : 0
    sellVolActive = i_source < i_source[1] and volume > volume[1] ? volume : 0

    [buyVol, sellVol, i_source, volume, buyVolActive, sellVolActive]


[buyVol, sellVol, ltfSrc, ltfVolume, buyVolActive, sellVolActive]
 = request.security_lower_tf(volumeSource, dynTf, ltfStats())


//                      Arrays

//Sums of sell volume, buy volume and active volumes
totalSellVolNorm = array.sum(sellVol)
totalBuyVolNorm = array.sum(buyVol)
totalVolNorm = totalSellVolNorm + totalBuyVolNorm

totalSellVolANorm = array.sum(sellVolActive)
totalBuyVolANorm = array.sum(buyVolActive)
totalVolANorm = totalSellVolANorm + totalBuyVolANorm

//Total volume MA
smoothedValue(source, length) =>
    i_smoothingType == "SMA" ? ta.sma(source, length) :
     i_smoothingType == "EMA" ? ta.ema(source, length) :
      i_smoothingType == "HMA" ? ta.hma(source, length) :
       i_smoothingType == "RMA" ? ta.rma(source, length) : ta.wma(source, length)

volSma = smoothedValue(totalVolNorm, i_volSmaLength)

//Relative total volume
totalSellVolRel= array.sum(sellVol) / volSma
totalBuyVolRel= array.sum(buyVol) / volSma
totalVolRel = totalSellVolRel + totalBuyVolRel

totalSellVolARel = array.sum(sellVolActive) / volSma
totalBuyVolARel = array.sum(buyVolActive) / volSma
totalVolARel = totalSellVolARel + totalBuyVolARel


//User specified volume type
totalVol = i_relVol == false ? totalVolNorm : totalVolRel
totalBuyVol = i_relVol == false ? totalBuyVolNorm : totalBuyVolRel
totalSellVol = i_relVol == false ? totalSellVolNorm : totalSellVolRel

totalVolA = i_relVol == false ? totalVolANorm : totalVolARel
totalBuyVolA = i_relVol == false ? totalBuyVolANorm : totalBuyVolARel
totalSellVolA = i_relVol == false ? totalSellVolANorm : totalSellVolARel


//Directional volume % of total volume and directional active volume % of total active volume
buyVolPerc = (totalBuyVol / totalVol)
sellVolPerc = (totalSellVol / totalVol)
buyVolPercA = (totalBuyVolA / totalVolA)
sellVolPercA = (totalSellVolA / totalVolA)

//Defining high buy/sell volume
highBuyVol = buyVolPerc * 100 >= i_volThreshold
highSellVol = sellVolPerc * 100 >= i_volThreshold

//Defining high active buy/sell volume
highBuyVolA = buyVolPercA * 100 >= i_volAThreshold
highSellVolA = sellVolPercA * 100 >= i_volAThreshold

//Defining volume-active volume divergence
ActiveVolDisagreement = (buyVolPercA > sellVolPercA and buyVolPerc < sellVolPerc) or (buyVolPercA < sellVolPercA and buyVolPerc > sellVolPerc) 


//                      Multi-condition highlights

//Volume anomaly conditions
highBuyVolStudy = i_multiCondition and i_highlightDomBuyVol ? highBuyVol : na(close) == false
highBuyAVolStudy = i_multiCondition and i_highlightDomABuyVol ? highBuyVolA : na(close) == false
highSellVolStudy = i_multiCondition and i_highlightDomSellVol ? highSellVol : na(close) == false
highSellAVolStudy = i_multiCondition and i_highlightDomASellVol ? highSellVolA : na(close) == false
volDivStudy = i_multiCondition and i_highlightDivergence ? ActiveVolDisagreement : na(close) == false

//Additional conditions

//Open and close position 
closePos = (close - low) / (high - low)
openPos = (open - low) / (high - low)

//Engulfings. Defined by higher high, lower low with a close at 60%/40% of bar range (0% being the very low, 100% being the very high)
engulfingUp = high > high[1] and low < low[1] and closePos > 0.60
engulfingDown = high > high[1] and low < low[1] and closePos < 0.40

//Wicks. Defined by higher high, higher low or lower high, lower low with a close at 60%/40% and open at 40%/60% of bar range.
wickUp = high < high[1] and low < low[1] and closePos > 0.60 and openPos > 0.40
wickDown = high > high[1] and low > low[1] and closePos < 0.40 and openPos < 0.60

//Expansions. Defined by higher high, higher low or lower high, lower low with a close at 70% of bar range and range 1.5x higher than previous.
barRange = high - low
expUp = high > high[1] and low > low[1] and closePos > 0.70 and barRange > (barRange[1] * 1.5)
expDown = high < high[1] and low < low[1] and closePos < 0.30 and barRange > (barRange[1] * 1.5)


//Specified price related condition
candleFormStudy = i_multiCondition and i_candleFormation == "Close ▲" and i_candleFormationBool ? close > close[1] : 
 i_multiCondition and i_candleFormation == "Close ▼" and i_candleFormationBool ? close < close[1] : 
  i_multiCondition and i_candleFormation == "Reversal ▲" and i_candleFormationBool ? wickUp or engulfingUp : 
   i_multiCondition and i_candleFormation == "Reversal ▼" and i_candleFormationBool ? wickDown or engulfingDown :
  i_multiCondition and i_candleFormation == "Expansion ▲" and i_candleFormationBool ? expUp :
 i_multiCondition and i_candleFormation == "Expansion ▼" and i_candleFormationBool ? expDown : na(close) == false

//Volume multiplier condition
volMultStudy = i_volMultiplierBool ? totalVol >= (volSma * i_volMultiplier) : na(close) == false

//Spcified anomaly
studiedAnomaly = highBuyVolStudy and highBuyAVolStudy and highSellVolStudy and highSellAVolStudy and volDivStudy and candleFormStudy and volMultStudy

//No studies selected condition
allStudiesNa = i_highlightDomBuyVol == false and i_highlightDomABuyVol == false and
 i_highlightDomSellVol == false and i_highlightDomASellVol == false and i_highlightDivergence == false and i_candleFormationBool == false and i_volMultiplierBool == false

//Defining multi-condition anomaly
multiCondAnomaly = i_multiCondition and studiedAnomaly and allStudiesNa == false

//Initializing anomaly counter
var int anomalyCount = 0

//If multi-condition anomaly found, add 1 to counter
if multiCondAnomaly
    anomalyCount += 1

//Anomaly counter text for table 
countText = i_multiCondition and allStudiesNa == true ? "Matches: " + str.tostring(0) + "┃" : 
 i_multiCondition and allStudiesNa == false ? "Matches: " + str.tostring(anomalyCount) + "┃" : ""


//                      Plot related calculations 

//If rounded display mode is true, round percentages to single values, else percentage values with no decimals.
roundedBuyVol = i_displayMode == true ? math.round(10 * buyVolPerc, 0) : math.round(buyVolPerc, 2) * 100
roundedSellVol = i_displayMode == true ? math.round(10 * sellVolPerc, 0) : math.round(sellVolPerc, 2) * 100
roundedBuyVolA = i_displayMode == true ? math.round(10 * buyVolPercA, 0) : math.round(buyVolPercA, 2) * 100
roundedSellVolA = i_displayMode == true  ? math.round(10 * sellVolPercA, 0) : math.round(sellVolPercA, 2) * 100

//Dominant volume, dominant active volume and appropriate colors
dominantVolPerc = totalBuyVol >= totalSellVol ? roundedBuyVol : roundedSellVol
dominantVolAPerc = totalBuyVolA >= totalSellVolA ? roundedBuyVolA : roundedSellVolA

dominantVolAbsolute = totalBuyVol >= totalSellVol ? totalBuyVol : totalSellVol
dominantVolAAbsolute = totalBuyVolA >= totalSellVolA ? totalBuyVolA : totalSellVolA

dominantVolCol = totalBuyVol >= totalSellVol ? i_buyVolCol : i_sellVolCol 
dominantVolACol = totalBuyVolA >= totalSellVolA ? i_buyVolACol : i_sellVolACol 


//                      Labels, lines, tables

//If volume data is NA (holidays, weekends etc.), plot no text instead of NaN
dataNotNa = na(totalVol) == false and totalVol > 0
aDataNotNa = na(totalVolA) == false and totalVolA > 0

//Label text for active volume direction and () to indicate divergences
ActiveText = totalBuyVolA >= totalSellVolA and ActiveVolDisagreement == false ? "+" : 
 totalBuyVolA >= totalSellVolA and ActiveVolDisagreement == true ? "(+)" :
  totalBuyVolA < totalSellVolA and ActiveVolDisagreement == false ? "-" :
   totalBuyVolA < totalSellVolA and ActiveVolDisagreement == true ? "(-)" : ""

//Label text for indicating high active volume 
ActiveText2 = highBuyVolA or highSellVolA ? "▲" : ""

//Constructing text for labels
labelText1 = dataNotNa ? "" + str.tostring(dominantVolPerc) : ""
labelText2 = aDataNotNa ? ActiveText + "\n" + str.tostring(dominantVolAPerc) + "\n" + ActiveText2 : ""

//Labels, dominant volume %, dominant active volume % and highlights (divergences, threshold exceeded) if applicable
label.new(x=bar_index, y=0, xloc=xloc.bar_index, text=labelText1, style=label.style_label_center, color=color.new(color.white, 100), textcolor=dominantVolCol, size=size.normal)
label.new(x=bar_index, y=0, xloc=xloc.bar_index, text=labelText2, style=label.style_label_up, color=color.new(color.white, 100), textcolor=dominantVolACol, size=size.normal)

//Line to fill gap between current bar index and next bar index, where real-time volume columns are halfway plotted. 
line.new(bar_index, 0, bar_index+1, 0, xloc=xloc.bar_index, color=color.rgb(38, 38, 38), width=18)

//Initializing table
var settingsTable = table.new(position = position.top_right, columns = 50, rows = 50, bgcolor = color.new(#2d2d2d, 100), border_width = 1, border_color=color.new(color.black, 100))

//Populating table cell
tableSymbol = volumeSource == i_symbolVolume ? i_symbolVolume : syminfo.ticker
table.cell(table_id = settingsTable, column = 1, row = 0, text = countText + str.tostring(tableSymbol) + " / " + str.tostring(dynTf) , text_color=color.white) 


//                      Plots

//Plots for volume columns, SMA and 0 line
pTotalVol = plot(totalBuyVol + totalSellVol, title="Total volume", color=i_totalVolCol, style=plot.style_columns, display=display.all - display.status_line)
pDomVol = plot(dominantVolAbsolute, title="Dominating volume", color=dominantVolCol, style=plot.style_columns, display=display.all - display.status_line)
pDomVolA = plot(dominantVolAAbsolute, title="Dominating active volume", color=dominantVolACol, style=plot.style_columns, display=display.all - display.status_line)
pSma = plot(i_relVol == false ? volSma : 1, title="Volume SMA", color=i_smaVolCol, style=plot.style_line, linewidth=1, display=display.all - display.status_line)
p0 = plot(0, title="0 line", color=color.rgb(38, 38, 38), linewidth=18, display=display.all - display.status_line)

//Plots for high buy/sell volume
plotshape(highBuyVol and barstate.isconfirmed ? totalBuyVol + totalSellVol : na, title="High buy volume threshold exceeded", style=shape.diamond, text="", color=i_buyVolCol, location=location.absolute, size=size.auto, textcolor=color.white, display=display.all - display.status_line)
plotshape(highSellVol and barstate.isconfirmed ? totalBuyVol + totalSellVol : na, title="High sell volume threshold exceeded", style=shape.diamond, text="", color=i_sellVolCol, location=location.absolute, size=size.auto, textcolor=color.white, display=display.all - display.status_line)
plotshape(multiCondAnomaly ? totalBuyVol + totalSellVol : na, title="Multi-condition anomaly", style=shape.xcross, text="", color=i_multiConditionCol, location=location.absolute, size=size.tiny, textcolor=color.white, display=display.all - display.status_line)

//Bar highlighter

highlightCond = i_highlightDomBuyVol and highBuyVol ? i_domBuyVolCol : i_highlightDomSellVol and highSellVol? i_domSellVolCol : i_highlightDomABuyVol and highBuyVolA ? i_domABuyVolCol :
 i_highlightDomASellVol and highSellVolA ? i_domASellVolCol : i_highlightDivergence and ActiveVolDisagreement ? i_divergenceCol : na

barcolor(i_multiCondition == false ? highlightCond : multiCondAnomaly ? i_multiConditionCol : na)


 
//                      Alerts

//Individual
alertcondition(highBuyVol and barstate.isconfirmed, "Buy volume threshold exceeded", "Buy volume threshold exceeded anomaly detected.")
alertcondition(highSellVol and barstate.isconfirmed, "Sell volume threshold exceeded", "Sell volume threshold exceeded anomaly detected.")
alertcondition(highBuyVolA and barstate.isconfirmed, "Active buy volume threshold exceeded", "Active buy volume threshold exceeded anomaly detected.")
alertcondition(highSellVolA and barstate.isconfirmed, "Active sell volume threshold exceeded", "Active sell volume threshold exceeded anomaly detected.")
alertcondition(ActiveVolDisagreement and barstate.isconfirmed, "Volume/active volume divergence", "Volume/active volume divergence anomaly detected.")
alertcondition(multiCondAnomaly and barstate.isconfirmed, "Multi-condition anomaly", "Multi-condition anomaly detected.")

//Grouped
alertcondition((highBuyVol or highSellVol) and barstate.isconfirmed, "Buy volume or sell volume threshold exceeded", "Buy volume or sell volume threshold exceeded anomaly detected.")
alertcondition((highBuyVolA or highSellVolA) and barstate.isconfirmed, "Active buy volume or active sell volume threshold exceeded", "Active buy volume or sell volume threshold exceeded anomaly detected.")
alertcondition((highBuyVolA or highSellVolA or highBuyVol or highSellVol or ActiveVolDisagreement) and barstate.isconfirmed, "Any volume anomaly (any type of volume threshold exceeded or volume/active volume divergence)", "A volume anomaly (any type of volume threshold exceeded or volume/active volume divergence) detected.")
````
