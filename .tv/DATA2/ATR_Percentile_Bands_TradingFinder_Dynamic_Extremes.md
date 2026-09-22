<!-- tradingview-pine-id: PUB;2d7b1859685a4cefb0fdd0759b9f338e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Percentile Bands [TradingFinder] Dynamic Extremes

Source: https://www.tradingview.com/script/kEI4Kzlt-ATR-Percentile-Bands-TradingFinder-Dynamic-Extremes/

## Description

🔵Introduction

Financial markets constantly move between calm conditions and periods of rapid price expansion. A market may trade close to its average for several sessions and then suddenly move into an extreme price zone as volatility increases. In these moments, traders need more than a fixed channel or a standard volatility indicator. 

The ATR Percentile Bands indicator combines Average True Range (ATR), historical price deviation, and percentile analysis to identify dynamic upper and lower bands directly on the price chart. By adapting to both current volatility and historical market behavior, the ATR Percentile Bands indicator helps traders recognize normal price movement, unusual price extensions, and potential reversal zones more clearly.

[image]https://www.tradingview.com/x/SOa4AR4R/[/image]

Unlike traditional ATR bands that calculate band width using only current volatility, this dynamic volatility indicator compares the smoothed ATR distance with the 95th percentile of price deviations from a selected moving average. The indicator then uses the larger value to create adaptive price bands that respond to changing market conditions. A customizable EMA, SMA, RMA, WMA, or HMA forms the central moving average, while multi-layer upper and lower ribbons highlight bullish and bearish extreme zones. 

When price approaches the upper percentile band, the market may be experiencing unusually strong buying pressure; when price reaches the lower percentile band, selling pressure may have pushed the market into a historically extended area. These volatility bands do not define guaranteed overbought or oversold levels, but they provide a structured framework for analyzing price extremes, mean-reversion opportunities, trend continuation, and volatility expansion.

Imagine price falling sharply toward the lower ATR Percentile Band. The first touch may attract attention, but the indicator does not immediately display a Buy Signal. Instead, its three-stage confirmation engine waits for a bullish candle to reject the lower inner band and then monitors the following candles for continued bullish confirmation. The same process works in reverse for a potential Sell Signal near the upper band. This confirmation-based logic helps filter weak reactions and reduces signals created by simple band contact. 

A live information dashboard also displays the current Signal, Price Zone, Trend, Nearest Band, Volatility, and Next Action, allowing traders to understand the complete market context at a glance. As a result, ATR Percentile Bands can support forex trading, cryptocurrency analysis, stock trading, indices, commodities, scalping, day trading, and swing trading across different markets and timeframes.

🔵How to Use

This volatility-based trading indicator helps traders understand where price is positioned relative to its moving average, current market volatility, and historical price deviations. After adding the indicator to the chart, traders should first examine the central moving average and the upper and lower percentile bands. Price movement between the two inner bands represents a relatively normal market condition, while movement inside the upper or lower ribbon indicates that price is entering an extended zone. 

A close above the outer upper band is displayed as Above Upper Band, while a close below the outer lower band is classified as Below Lower Band. These extreme price zones can highlight increased buying or selling pressure, but touching an ATR Percentile Band does not automatically create a Buy Signal or Sell Signal.

Before evaluating a trading signal, traders should review the live dashboard and combine Price Zone, Trend, Nearest Band, and Volatility information. The Trend column shows whether price and the moving average currently support a Bullish, Bearish, or Sideways condition. Nearest Band indicates which inner ATR band is closer to price, while Volatility compares the current ATR with its historical range. 

After price reaches an extreme band, the Signal and Next Action columns can be used to follow the confirmation process. The indicator requires a three-stage candle sequence before publishing a Long or Short Signal, helping separate a simple band touch from a confirmed price reaction. All signal decisions are registered after candle closure, so traders should wait for the active candle to close before interpreting the final signal.

🟣Buy Signal

A potential Buy Setup begins when price moves down to the Lower Inner Band and then shows a valid bullish rejection. The first candle must satisfy three conditions simultaneously: its low must touch or move below the Lower Inner Band, its closing price must return above the Lower Inner Band, and it must close as a bullish candle with the Close above the Open.

The initial Buy Setup conditions are: A valid Buy Setup requires the candle’s low to touch or move below the Lower Inner Band. The price must then recover and close above the Lower Inner Band, while the closing price must also remain above the opening price to confirm that the candle is bullish.

When these conditions are confirmed at candle close, the ATR Percentile Bands indicator does not immediately display a Long Signal. Instead, it saves the bullish setup and sets the confirmation counter to one. At this stage, the dashboard displays Buy Setup, while the Next Action column changes to Wait for Buy. This tells the trader that a bullish reaction has been detected near the lower percentile band, but the complete three-candle confirmation sequence has not yet formed.

[image]https://www.tradingview.com/x/F5R14ntI/[/image]

The second confirmation candle does not need to touch the Lower Inner Band again. It only needs to remain bullish and close above the Lower Inner Band. If these conditions are satisfied, the confirmation counter advances from one to two. The third candle must repeat the same continuation conditions: it must close above its opening price and remain above the Lower Inner Band. Once the third bullish confirmation is completed, the indicator publishes the Long Signal on the third candle.

[image]https://www.tradingview.com/x/ztBcrK1v/[/image]

After confirmation, the Signal column displays Buy Signal, and Next Action changes to Buy Confirmed. The final Long marker may appear several candles away from the original contact with the lower band because only the first candle must directly reject the extreme zone. The second and third candles are continuation confirmations and are not required to interact with the band again.

A pending Buy Setup is cancelled if a following candle is not bullish and does not remain above the Lower Inner Band. If a valid bearish setup forms while the indicator is waiting for bullish confirmation, the signal engine switches direction, cancels the previous Buy Setup, and begins counting the new Sell Setup from one. After a Long or Short Signal is published, the Signal Gap setting prevents another setup from beginning until the selected number of candles has passed. The default Signal Gap is 10 candles.

[image]https://www.tradingview.com/x/1jCuTpYJ/[/image]

For a more structured bullish analysis, traders can combine the Buy Signal with the following conditions:

[*]Price has reacted from the Lower Inner Band or Lower Outer Band;
[*]Price Zone shows Lower Band or Below Lower Band;
[*]Trend is Bullish or begins shifting from Bearish toward Sideways or Bullish;
[*]Volatility is suitable for the trader’s strategy and risk tolerance;
[*]The bullish reaction occurs near support, demand, liquidity, or a significant market structure level;
[*]The completed Long Signal provides an acceptable stop-loss distance and risk-to-reward ratio.

A Buy Signal represents a confirmed bullish reaction within the indicator’s internal logic. It does not guarantee that the market has reached its final low or that an upward trend will continue. In a strong bearish market, price can repeatedly interact with the lower ATR bands. Traders should therefore evaluate the Long Signal together with market structure, volume, trend direction, higher-timeframe context, and risk management.

🟣Sell Signal

A potential Sell Setup begins when price moves up to the Upper Inner Band and then produces a valid bearish rejection. The first candle must meet three conditions at the same time: its high must touch or move above the Upper Inner Band, its closing price must return below the Upper Inner Band, and it must close as a bearish candle with the Close below the Open.

The initial Sell Setup conditions are: The bearish sequence starts when price pushes into or beyond the Upper Inner Band but fails to hold at that level. If sellers regain control before the candle closes, price returns below the band and finishes beneath its opening value. This rejection activates the initial Sell Setup and starts the confirmation process.

Once these conditions are confirmed after candle closure, the indicator saves the bearish setup and sets the confirmation counter to one. It does not publish a Short Signal on the first rejection candle. During this stage, the dashboard displays Sell Setup, while the Next Action column shows Wait for Sell. The first rejection identifies a possible bearish response from the upper extreme zone, but two additional confirmations are still required.

[image]https://www.tradingview.com/x/1RINLaFJ/[/image]

The second confirmation candle must be bearish and must close below the Upper Inner Band. It does not need to touch the upper band again. When both continuation conditions are satisfied, the bearish counter increases from one to two. The third candle must also close below its opening price and remain below the Upper Inner Band. After the third bearish confirmation closes, the indicator displays the final Short Signal.

At confirmation, the Signal column changes to Sell Signal, and Next Action displays Sell Confirmed. Because the final Short marker belongs to the third confirmation candle, it may not appear directly at the original upper-band rejection. This distance is a normal result of the three-stage confirmation model and does not indicate delayed calculation or repainting.

[image]https://www.tradingview.com/x/gi4q9bcZ/[/image]

The Sell Setup is cancelled when the following candle fails to maintain the required bearish continuation and no valid opposite setup is created. If a valid bullish rejection develops while the indicator is waiting for bearish confirmation, the existing Sell Setup is cancelled, the signal direction changes to Buy, and the bullish confirmation counter begins from one. The configured Signal Gap is applied after every published signal to reduce clusters of nearby Long and Short signals.

[image]https://www.tradingview.com/x/axHUbLC6/[/image]

For a more complete bearish analysis, traders can evaluate the Sell Signal alongside these conditions:

[*]Price has rejected the Upper Inner Band or Upper Outer Band;
[*]Price Zone displays Upper Band or Above Upper Band;
[*]Trend is Bearish or begins changing from Bullish toward Sideways or Bearish;
[*]The upper band overlaps resistance, supply, liquidity, or an important market structure level;
[*]Market volatility is compatible with the selected stop loss and position size;
[*]The confirmed Short Signal offers a reasonable risk-to-reward structure.

A Sell Signal confirms a bearish reaction according to the ATR Percentile Bands signal engine, but it should not be interpreted as proof that price has formed a permanent top. During powerful bullish trends, price may remain close to the upper volatility band or repeatedly move beyond it. Traders should use the Short Signal as analytical confirmation and assess the wider trend, market structure, volume, news conditions, stop loss, and capital management before making a trading decision.

🔵Settings

Moving Average Type: Defines the calculation method used for the central moving average. Traders can select EMA, SMA, RMA, WMA, or HMA. EMA is selected by default and responds relatively quickly to recent price changes, while smoother average types can create a more stable band structure.

Moving Average Period: Determines how many candles are included in the central moving average calculation. The default value is 50. A shorter period makes the moving average and dynamic bands react faster to price movement, while a longer period creates a smoother structure with slower changes.

ATR Period: Sets the number of candles used to calculate the Average True Range. The default ATR Period is 14. Lower values respond more quickly to short-term volatility, whereas higher values provide a smoother measurement of market volatility.

ATR Multiplier: Controls the ATR-based distance between the central moving average and the outer volatility bands. Its default value is 2.8. Increasing the ATR Multiplier moves the bands farther from price and can reduce the number of band interactions. Decreasing it creates tighter bands and may produce more frequent setups in volatile or fast-moving markets.

Smooth Period: Specifies the smoothing period applied to the ATR and the final band distance. The default value is 5. A lower Smooth Period makes the ATR Percentile Bands more responsive, while a higher value reduces sudden changes and creates smoother upper and lower ribbons.

Signal Gap: Determines the minimum number of candles required between two published signals. The default Signal Gap is 10 bars. Increasing this value creates more separation between Long and Short Signals, while setting it to zero removes the mandatory waiting period.

Moving Average: Shows or hides the central moving average on the price chart. Disabling this option removes the line from view without changing the calculations of the upper and lower ATR Percentile Bands.

Signals: Controls the visibility of Long and Short markers on the chart. Turning this setting off only hides the signal symbols; the internal signal engine and configured TradingView alerts continue to operate normally.

Show Table: Displays or hides the live information dashboard. The table summarizes the current Signal, Price Zone, Trend, Nearest Band, Volatility, and Next Action.

Table Size: Changes the text size of the dashboard. Available options include Tiny, Small, Normal, and Large, allowing the table to fit different chart layouts and screen sizes.

Table Position: Selects the dashboard location on the chart. The table can be placed in any of the nine standard positions: Top Left, Top Center, Top Right, Middle Left, Center, Middle Right, Bottom Left, Bottom Center, or Bottom Right.

Alert: Enables or disables the dynamic alert messages generated by the indicator. When this option is active, traders can create TradingView alerts for confirmed Long and Short Signals.

Message Frequency: Determines how frequently the indicator is allowed to send an alert message. All sends every valid event, Once Per Bar limits notifications to one event per candle, and Once Per Bar Close sends the alert only after the candle has closed. Once Per Bar Close is the default option and is the most consistent choice for the confirmed-candle signal logic.

🔵Conclusion

The ATR Percentile Bands indicator combines current market volatility with historical price deviation to create adaptive upper and lower bands around a customizable moving average. By comparing the smoothed ATR distance with the 95th percentile of recent price deviations, the indicator adjusts its band width as market conditions change. The multi-layer ribbons highlight normal price movement, extended price zones, and unusually strong deviations, while the live dashboard summarizes Signal, Price Zone, Trend, Nearest Band, Volatility, and Next Action in one view.

Its three-stage confirmation system separates a simple band interaction from a confirmed bullish or bearish reaction. Long and Short Signals are published only after the required candle sequence is completed, helping traders evaluate price rejection with greater context. These signals should be combined with market structure, trend direction, volume, support and resistance, higher-timeframe analysis, and risk management. As an adaptive volatility and price-extreme analysis tool, the indicator can support forex, cryptocurrency, stock, index, and commodity traders across scalping, intraday, and swing-trading strategies.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingFinder

//@version=6

indicator("ATR Percentile Bands [TradingFinder] Dynamic Extremes", "Dynamic Percentile", overlay = true, behind_chart = true, max_labels_count = 200)

movingAverageType = input.string("EMA", "Moving Average Type", options = ["EMA", "SMA", "RMA", "WMA", "HMA"], group = "Logical Settings")
movingAveragePeriod = input.int(50, "Moving Average Period", minval = 2, maxval = 500, group = "Logical Settings")
atrPeriod = input.int(14, "ATR Period", minval = 2, maxval = 500, group = "Logical Settings")
atrMultiplier = input.float(2.8, "ATR Multiplier", minval = 0.5, maxval = 10.0, step = 0.1, group = "Logical Settings")
smoothPeriod = input.int(5, "Smooth Period", minval = 1, maxval = 100, group = "Logical Settings")
signalGap = input.int(10, "Signal Gap", minval = 0, maxval = 500, group = "Logical Settings")

showMovingAverage = input.bool(true, "Moving Average", group = "Display Settings")
showSignals = input.bool(true, "Signals", group = "Display Settings")

showTable = input.bool(true, "Show Table", group = "Table Settings")
tableSizeInput = input.string(size.small, "Table Size", options = [size.tiny, size.small, size.normal, size.large], group = "Table Settings")
tablePositionInput = input.string(position.top_right, "Table Position", options = [position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group = "Table Settings")

alertEnabled = input.bool(true, "Alert", group = "Alert Settings")
messageFrequency = input.string("Once Per Bar Close", "Message Frequency", options = ["All", "Once Per Bar", "Once Per Bar Close"], group = "Alert Settings")



movingAverage(float source, int period, string averageType) =>
    averageType == "EMA" ? ta.ema(source, period) : averageType == "SMA" ? ta.sma(source, period) : averageType == "RMA" ? ta.rma(source, period) : averageType == "WMA" ? ta.wma(source, period) : ta.hma(source, period)


average = movingAverage(close, movingAveragePeriod, movingAverageType)
atr = ta.ema(ta.atr(atrPeriod), smoothPeriod)
atrDistance = atr * atrMultiplier


priceDeviation = math.abs(close - average)
percentileDistance = ta.percentile_linear_interpolation(priceDeviation, 200,  95)
rawOuterDistance = math.max(atrDistance, nz(percentileDistance, atrDistance))
outerDistance = ta.ema(rawOuterDistance, smoothPeriod)
innerDistance = outerDistance * 0.62
volatilityRank = ta.percentrank(atr, 200)

upperInnerBand = average + innerDistance
upperOuterBand = average + outerDistance
lowerInnerBand = average - innerDistance
lowerOuterBand = average - outerDistance


upperStop1 = upperInnerBand + (upperOuterBand - upperInnerBand) * 0.25
upperStop2 = upperInnerBand + (upperOuterBand - upperInnerBand) * 0.50
upperStop3 = upperInnerBand + (upperOuterBand - upperInnerBand) * 0.75
lowerStop1 = lowerInnerBand + (lowerOuterBand - lowerInnerBand) * 0.25
lowerStop2 = lowerInnerBand + (lowerOuterBand - lowerInnerBand) * 0.50
lowerStop3 = lowerInnerBand + (lowerOuterBand - lowerInnerBand) * 0.75


longSetup = low <= lowerInnerBand and close > lowerInnerBand and close > open
shortSetup = high >= upperInnerBand and close < upperInnerBand and close < open

var int pendingDirection = 0
var int confirmationCount = 0
var int lastPublishedSignal = na

longSignal = false
shortSignal = false
signalGapQualified = na(lastPublishedSignal) or bar_index - lastPublishedSignal >= signalGap

if barstate.isconfirmed
    if pendingDirection == 0
        if signalGapQualified and longSetup
            pendingDirection := 1
            confirmationCount := 1
        else if signalGapQualified and shortSetup
            pendingDirection := -1
            confirmationCount := 1
    else if pendingDirection == 1
        if shortSetup
            pendingDirection := -1
            confirmationCount := 1
        else if close > lowerInnerBand and close > open
            confirmationCount += 1
        else
            pendingDirection := 0
            confirmationCount := 0
    else if pendingDirection == -1
        if longSetup
            pendingDirection := 1
            confirmationCount := 1
        else if close < upperInnerBand and close < open
            confirmationCount += 1
        else
            pendingDirection := 0
            confirmationCount := 0

    if pendingDirection == 1 and confirmationCount >= 3
        longSignal := true
        lastPublishedSignal := bar_index
        pendingDirection := 0
        confirmationCount := 0
    else if pendingDirection == -1 and confirmationCount >= 3
        shortSignal := true
        lastPublishedSignal := bar_index
        pendingDirection := 0
        confirmationCount := 0


upperInnerPlot = plot(upperInnerBand, "Upper Band Inner", color = color.new(#E91E63, 82), linewidth = 1)
upperStop1Plot = plot(upperStop1, "Upper Band Gradient 1", color = color.new(#E91E63, 100), editable = false)
upperStop2Plot = plot(upperStop2, "Upper Band Center", color = color.new(#E91E63, 12), linewidth = 1)
upperStop3Plot = plot(upperStop3, "Upper Band Gradient 3", color = color.new(#E91E63, 100), editable = false)
upperOuterPlot = plot(upperOuterBand, "Upper Band Outer", color = color.new(#E91E63, 4), linewidth = 1)

lowerInnerPlot = plot(lowerInnerBand, "Lower Band Inner", color = color.new(#00C6A2, 82), linewidth = 1)
lowerStop1Plot = plot(lowerStop1, "Lower Band Gradient 1", color = color.new(#00C6A2, 100), editable = false)
lowerStop2Plot = plot(lowerStop2, "Lower Band Center", color = color.new(#00C6A2, 12), linewidth = 1)
lowerStop3Plot = plot(lowerStop3, "Lower Band Gradient 3", color = color.new(#00C6A2, 100), editable = false)
lowerOuterPlot = plot(lowerOuterBand, "Lower Band Outer", color = color.new(#00C6A2, 4), linewidth = 1)

plot(showMovingAverage ? average : na, "Moving Average", color = color.new(#A8B0BE, 55), linewidth = 1)

fill(upperInnerPlot, upperStop1Plot, color = color.new(#E91E63, 94), title = "Upper Band Layer 1")
fill(upperStop1Plot, upperStop2Plot, color = color.new(#E91E63, 86), title = "Upper Band Layer 2")
fill(upperStop2Plot, upperStop3Plot, color = color.new(#E91E63, 73), title = "Upper Band Layer 3")
fill(upperStop3Plot, upperOuterPlot, color = color.new(#E91E63, 53), title = "Upper Band Layer 4")

fill(lowerInnerPlot, lowerStop1Plot, color = color.new(#00C6A2, 94), title = "Lower Band Layer 1")
fill(lowerStop1Plot, lowerStop2Plot, color = color.new(#00C6A2, 86), title = "Lower Band Layer 2")
fill(lowerStop2Plot, lowerStop3Plot, color = color.new(#00C6A2, 73), title = "Lower Band Layer 3")
fill(lowerStop3Plot, lowerOuterPlot, color = color.new(#00C6A2, 53), title = "Lower Band Layer 4")

plotshape(showSignals and longSignal, "Long Signal", shape.triangleup, location.belowbar, #00c600, 0, "Long Signal", #00c600, true, size.small)
plotshape(showSignals and shortSignal, "Short Signal", shape.triangledown, location.abovebar, #e91e1e, 0, "Short Signal", #e91e1e, true, size.small)


marketState = longSignal ? "Buy Signal" : shortSignal ? "Sell Signal" : pendingDirection == 1 ? "Buy Setup" : pendingDirection == -1 ? "Sell Setup" : "No Signal"
marketStateColor = longSignal or pendingDirection == 1 ? #26D6AD : shortSignal or pendingDirection == -1 ? #F16B82 : #B5C3D8

extremeZone = close > upperOuterBand ? "Above Upper Band" : close >= upperInnerBand ? "Upper Band" : close < lowerOuterBand ? "Below Lower Band" : close <= lowerInnerBand ? "Lower Band" : close >= average ? "Above Average" : "Below Average"
extremeZoneColor = close >= upperInnerBand ? #F16B82 : close <= lowerInnerBand ? #26D6AD : #56CFE0

bullishTrend = close > average and average > average[1]
bearishTrend = close < average and average < average[1]
trendState = bullishTrend ? "Bullish" : bearishTrend ? "Bearish" : "Sideways"
trendStateColor = bullishTrend ? #26D6AD : bearishTrend ? #F16B82 : #FFBF69

bandsReady = not na(upperInnerBand) and not na(lowerInnerBand)
distanceToUpperPercent = bandsReady and close != 0 ? math.abs(upperInnerBand - close) / math.abs(close) * 100 : na
distanceToLowerPercent = bandsReady and close != 0 ? math.abs(close - lowerInnerBand) / math.abs(close) * 100 : na
upperBandIsNearest = bandsReady and distanceToUpperPercent <= distanceToLowerPercent
nearestBand = not bandsReady ? "Loading" : close >= upperInnerBand ? "At Upper Band" : close <= lowerInnerBand ? "At Lower Band" : upperBandIsNearest ? str.tostring(distanceToUpperPercent, "#.##") + "% to Upper" : str.tostring(distanceToLowerPercent, "#.##") + "% to Lower"
nearestBandColor = not bandsReady ? #B5C3D8 : close >= upperInnerBand ? #F16B82 : close <= lowerInnerBand ? #26D6AD : upperBandIsNearest ? #F16B82 : #26D6AD

volatilityState = na(volatilityRank) ? "Loading" : volatilityRank >= 80 ? "High" : volatilityRank <= 20 ? "Low" : "Normal"
volatilityStateColor = na(volatilityRank) ? #B5C3D8 : volatilityRank >= 80 ? #F16B82 : volatilityRank <= 20 ? #56CFE0 : #26D6AD

nextStep = longSignal ? "Buy Confirmed" : shortSignal ? "Sell Confirmed" : pendingDirection == 1 ? "Wait for Buy" : pendingDirection == -1 ? "Wait for Sell" : close >= upperInnerBand ? "Look for Sell" : close <= lowerInnerBand ? "Look for Buy" : "Wait"
nextStepColor = longSignal or pendingDirection == 1 or close <= lowerInnerBand ? #26D6AD : shortSignal or pendingDirection == -1 or close >= upperInnerBand ? #F16B82 : #B5C3D8

var table decisionTable = table.new(tablePositionInput, 6, 3, bgcolor = #0D1A3F, frame_color = #1C306D, frame_width = 1, border_color = #1C306D, border_width = 1)

if barstate.isfirst
    table.merge_cells(decisionTable, 0, 0, 5, 0)

if barstate.islast
    if showTable
        table.cell(decisionTable, 0, 0, "♦ TradingFinder ♦", bgcolor = #0D1A3F, text_color = #56CFE0, text_size = tableSizeInput)

        A = array.from("Signal", "Price Zone", "Trend", "Nearest Band", "Volatility", "Next Action")
        for column = 0 to 5
            table.cell(decisionTable, column, 1, array.get(A, column), bgcolor = #1C306D, text_color = color.white, text_size = tableSizeInput)

        table.cell(decisionTable, 0, 2, marketState, bgcolor = color.new(marketStateColor, 84), text_color = marketStateColor, text_size = tableSizeInput)
        table.cell(decisionTable, 1, 2, extremeZone, bgcolor = #0D1732, text_color = extremeZoneColor, text_size = tableSizeInput)
        table.cell(decisionTable, 2, 2, trendState, bgcolor = color.new(trendStateColor, 88), text_color = trendStateColor, text_size = tableSizeInput)
        table.cell(decisionTable, 3, 2, nearestBand, bgcolor = #0D1732, text_color = nearestBandColor, text_size = tableSizeInput, tooltip = "Shows which inner band is closest and the remaining distance as a percentage of price.")
        table.cell(decisionTable, 4, 2, volatilityState, bgcolor = color.new(volatilityStateColor, 90), text_color = volatilityStateColor, text_size = tableSizeInput)
        table.cell(decisionTable, 5, 2, nextStep, bgcolor = color.new(nextStepColor, 86), text_color = nextStepColor, text_size = tableSizeInput)
    else
        table.clear(decisionTable, 0, 0, 5, 2)


longAlert = alertEnabled and longSignal
shortAlert = alertEnabled and shortSignal

alertcondition(longAlert, " Long Signal", " Long Signal on {{ticker}} after three consecutive confirmations.")
alertcondition(shortAlert, " Short Signal", " Short Signal on {{ticker}} after three consecutive confirmations.")
alertcondition(longAlert or shortAlert, " Any Signal", " confirmed signal on {{ticker}}.")

alertFrequency = messageFrequency == "All" ? alert.freq_all : messageFrequency == "Once Per Bar" ? alert.freq_once_per_bar : alert.freq_once_per_bar_close
if longAlert
    alert("LONG SIGNAL " + syminfo.ticker + " 3 consecutive confirmations", alertFrequency)
if shortAlert
    alert("SHORT SIGNAL " + syminfo.ticker + " 3 consecutive confirmations", alertFrequency)
````
