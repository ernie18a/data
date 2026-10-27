# Buy Sell signals

- url: https://www.tradingview.com/script/ppEwWYS5-Buy-Sell-signals/
- type: indicator
- pine_id: PUB;f2851b5bb0ab4e2d977a924a7f659557
- version: 1.0

## Description

Test Buy Sell Signals.

Test Buy Sell Signals.
Test Buy Sell Signals.

Test Buy Sell Signals.
Test Buy Sell Signals.

Test Buy Sell Signals.
Test Buy Sell Signals.
Test Buy Sell Signals.


Test Buy Sell Signals.Test Buy Sell Signals.
Test Buy Sell Signals.

## Source Code

````pine
//@version=6
indicator('Buy Sell signals', overlay = true)

// --- RSI Divergence Variables ---
len = 14
src = close
lbR = 1
lbL = 5
rangeUpper = 60
rangeLower = 5
plotBull = true
plotBear = true
showTable = input.bool(false, title = 'Show Table')
showTable2 = input.bool(false, title = 'Show Target Table')
spot_atm = input.int(24750, title = 'Reference ATM Strike')
quantity = input.int(25, title = 'Quantity')
bearColor = color.red
bullColor = color.green
textColor = color.white
osc = ta.rsi(src, len)
strike_interval = 50
//_day = input.string('19', title = 'Exp Day', inline = 's1')
//_month = input.string('12', title = 'M', inline = 's1')
//_year = input.string('24', title = 'Y', inline = 's1')

// spot_ = input.symbol ( "NIFTY" , title = "Spot Symbol" )
//spot_ = input.string('NIFTY', title = 'Spot Symbol', options = ['BANKNIFTY', 'NIFTY', 'FINNIFTY', 'MIDCAP'])

// spot =  spot_ == "NSE:BANKNIFTY1!" ? "NSE:BANKNIFTY" : spot_ == "NSE:NIFTY1!" ? "NSE:NIFTY" : spot_ == "NSE:FINNIFTY1!" ? "NSE:FINNIFTY" : spot_ == "NSE:CNXFINANCE" ? "NSE:FINNIFTY" : spot_ == "NSE:MIDCPNIFTY1!" ? "NSE:MIDCPNIFTY" : spot_ == "NSE:CNXMIDCAP" ? "NSE:MIDCPNIFTY" : spot_
//spot = spot_ == 'BANKNIFTY' ? 'NSE:BANKNIFTY' : spot_ == 'NIFTY' ? 'NSE:NIFTY' : spot_ == 'FINNIFTY' ? 'NSE:CNXFINANCE' : 'NSE:CNXMIDCAP'
//spot_close = request.security(spot, timeframe.period, close)

// Bollinger Band settings
length = input(20, title = 'Length')
src1 = close
mult = input(2.0, title = 'Multiplier')
custom_strike_priceC = spot_atm - strike_interval
custom_strike_priceP = spot_atm + strike_interval
// Bollinger Band calculation
basis = ta.sma(src1, length)
dev = mult * ta.stdev(src1, length)
upper_band = basis + dev
lower_band = basis - dev

// Calculate the distance between the upper and lower bands
band_distance = upper_band - lower_band

// Calculate a moving average of the band distance to smooth out fluctuations
band_distance_avg = ta.sma(band_distance, length)

// Define threshold as a percentage of the average band distance
sideways_threshold = 0.9

// Calculate dynamic threshold for sideways market based on percentage of the average band distance
dynamic_threshold = band_distance_avg * sideways_threshold

// Determine if market is sideways or trending based on dynamic threshold
is_sideways = band_distance < dynamic_threshold
is_trending = band_distance >= dynamic_threshold


// --- Divergence Conditions ---
plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper



// Regular Bullish RSI Divergence
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCondAlert = priceLL and oscHL and plFound
bullCond = plotBull and bullCondAlert

// Regular Bearish RSI Divergence
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCondAlert = priceHH and oscLH and phFound
bearCond = plotBear and bearCondAlert

// --- Hidden Bullish RSI Divergence
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCondAlert = priceHL and oscLL and plFound
hiddenBullCond = plotBull and hiddenBullCondAlert

// --- Hidden Bearish RSI Divergence
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCondAlert = priceLH and oscHH and phFound
hiddenBearCond = plotBear and hiddenBearCondAlert

// --- RSI Divergence Candle Coloring ---
bearColorFinal = bearCond ? color.new(color.rgb(255, 105, 180), 0) : na // Pink for Bearish Divergence
bullColorFinal = bullCond ? color.new(color.blue, 0) : na // Blue for Bullish Divergence

hiddenBullColorFinal = hiddenBullCond ? color.new(color.blue, 0) : na // Green for Hidden Bullish Divergence
hiddenBearColorFinal = hiddenBearCond ? color.new(color.rgb(255, 105, 180), 0) : na // Red for Hidden Bearish Divergence

barcolor(bearCond ? bearColorFinal : bullCond ? bullColorFinal : hiddenBullCond ? hiddenBullColorFinal : hiddenBearCond ? hiddenBearColorFinal : na)

// --- EMA Logic Variables ---
ema10 = ta.ema(close, 9) // 10-period EMA
ema20 = ta.ema(close, 20) // 20-period EMA
tolerance = 0.001 // Small tolerance to detect when the EMAs are close

//plot(ema10, color=color.blue, linewidth=2, title="SMA")
//plot(ema20, color=color.green, linewidth=2, title="EMA")

emaCrossUp = ta.crossover(ema10, ema20)
emaCrossDown = ta.crossunder(ema10, ema20)
emaTouch = math.abs(ema10 - ema20) < tolerance

// Combine EMA and RSI white candle logic
isWhiteCandle = emaCrossUp or emaCrossDown or emaTouch

// Color the candles white if they meet the white candle condition
barcolor(isWhiteCandle ? color.white : na)

// --- White Candle Logic ---
var float whiteCandleHigh = na
var float whiteCandleClose = na
var float whiteCandleOpen = na
var float whiteCandleAvg = na
var float whiteCandleLow = na
var float prevCandleHigh = na
var float prevCandleLow = na
var float nextCandleHigh = na
var float nextCandleLow = na
var float highestHigh = na
var float lowestLow = na
var float difference = na
var float chighestHigh = na
var float clowestLow = na
var float cdifference = na
var float phighestHigh = na
var float plowestLow = na
var float pdifference = na
var float cewhitecandlehigh = na
var float cewhitecandlelow = na
var float ceprewhitecandlehigh = na
var float ceprewhitecandlelow = na
var float cenextwhitecandlehigh = na
var float cenextwhitecandlelow = na
var float pewhitecandlehigh = na
var float pewhitecandlelow = na
var float peprewhitecandlehigh = na
var float peprewhitecandlelow = na
var float penextwhitecandlehigh = na
var float penextwhitecandlelow = na
var bool isWhiteCandleDetected = false
var float cbuy = na
var float csell = na
var float ctarget = na
var float csloss = na
var float pbuy = na
var float psell = na
var float psloss = na
var float ptarget = na
var int whiteCandleBarIndex = na //
var float volume1 = na
var float volume2 = na
var float volume3 = na
var bool signalGiven = false // Flag to track if a signal was already given for the current white candle




// Variables to store the high and low of the previous white candle
var float prevWhiteCandleHigh = na
var float prevWhiteCandleLow = na
var bool prevWhiteCandleValid = false

// Create a line that connects the high and low of the white candles
var line whiteCandleLine = na
// Define predicted values outside the if block
var float predictedHigh = na
var float predictedLow = na
var float predictedAvg = na
var table t = table.new(position.bottom_center, 4, 3)

if isWhiteCandle
    // Set the high and low of the white candle when it is detected
   // cewhitecandlehigh := request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, high)
    //cewhitecandlelow := request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, low)
   // pewhitecandlehigh := request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, high)
    //pewhitecandlelow := request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, low)
    whiteCandleHigh := high
    whiteCandleLow := low
    whiteCandleClose := close
    whiteCandleOpen := open
    volume1 := volume
    whiteCandleAvg := (whiteCandleHigh + whiteCandleLow + whiteCandleClose + whiteCandleOpen) / 4

    // Draw a continuous line representing the high of white candles
    if not na(whiteCandleHigh)
        line.set_xy1(whiteCandleLine, bar_index[1], whiteCandleHigh[1])
        line.set_xy2(whiteCandleLine, bar_index, whiteCandleHigh)

    // Draw a continuous line representing the low of white candles
    if not na(whiteCandleLow)
        line.set_xy1(whiteCandleLine, bar_index[1], whiteCandleLow[1])
        line.set_xy2(whiteCandleLine, bar_index, whiteCandleLow)

    predictedHigh := na(whiteCandleHigh) ? na : whiteCandleHigh + whiteCandleHigh - whiteCandleLow
    predictedLow := na(whiteCandleLow) ? na : whiteCandleLow - (whiteCandleHigh - whiteCandleLow)
    predictedAvg := na(whiteCandleHigh) or na(whiteCandleLow) ? na : (whiteCandleHigh + whiteCandleLow) / 2

    whiteCandleBarIndex := bar_index
    isWhiteCandleDetected := true

    //ceprewhitecandlehigh := request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, high[1])
    //ceprewhitecandlelow := request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, low[1])
    //peprewhitecandlehigh := request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, high[1])
    //peprewhitecandlelow := request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, low[1])
    prevCandleHigh := high[1]
    prevCandleLow := low[1]

// Function to log data for copying
log_to_alert(message) =>
    alert(message)

//plot(predictedHigh, color=color.green, linewidth=2, title="Predicted High")
//plot(predictedLow, color=color.red, linewidth=2, title="Predicted Low")
//plot(predictedAvg, color=color.blue, linewidth=2, title="Average of High and Low")

// Check if the current bar is the bar after the white candle (the next candle)
if isWhiteCandleDetected and bar_index == whiteCandleBarIndex + 1
    // Access the next candle (after the white candle)
    //cenextwhitecandlehigh := request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, high) 
    //cenextwhitecandlelow := request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, low)
    //penextwhitecandlehigh := request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, high)
    //penextwhitecandlelow := request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, low)
    nextCandleHigh := high
    nextCandleLow := low
    signalGiven := false
    // Reset the flag to track if we are looking for the next candle
    //isWhiteCandleDetected := false

    // Calculate the highest and lowest values of the previous, white, and next candles
    highestHigh := math.max(whiteCandleHigh, math.max(prevCandleHigh, nextCandleHigh))
    lowestLow := math.min(whiteCandleLow, math.min(prevCandleLow, nextCandleLow))
    difference := highestHigh - lowestLow

    //chighestHigh := math.max(cewhitecandlehigh,math.max(ceprewhitecandlehigh,cenextwhitecandlehigh))
    //clowestLow := math.min(cewhitecandlelow,math.min(ceprewhitecandlelow,cenextwhitecandlelow))
    //cdifference := chighestHigh - clowestLow

    //phighestHigh := math.max(pewhitecandlehigh,math.max(peprewhitecandlehigh,penextwhitecandlehigh))
    //plowestLow := math.min(pewhitecandlelow,math.min(peprewhitecandlelow,penextwhitecandlelow))
    //pdifference := phighestHigh - plowestLow

    // Create a table with one column and one row, positioned at the bottom center
    //var myTable1 = table.new(position.bottom_right, 2, 2)

    // Set the cell content
    //table.cell(myTable1, 0, 0, '5MTF is best', text_color = color.red, text_size = size.auto) // table.cell(myTable1, 0, 1, "Buy or Sell only after the signal.", text_color=color.red, text_size=size.auto)

    // Draw extended horizontal rays for the highest and lowest of the three candles
    //line.new(x1 = bar_index, y1 = highestHigh, x2 = bar_index + 21, y2 = highestHigh, color = color.blue, width = 1, style = line.style_dashed)
    //line.new(x1 = bar_index, y1 = lowestLow, x2 = bar_index + 21, y2 = lowestLow, color = color.white, width = 1, style = line.style_dashed)

    // Draw extended horizontal rays for the high and low of the white candle
    //line.new(x1 = bar_index, y1 = whiteCandleHigh, x2 = bar_index + 18, y2 = whiteCandleHigh, color = color.green, width = 1, style = line.style_solid)
    //line.new(x1 = bar_index, y1 = whiteCandleLow, x2 = bar_index + 18, y2 = whiteCandleLow, color = color.red, width = 1, style = line.style_solid)

// Display the price level of the high and low with labels
//label.new(bar_index + 70, whiteCandleHigh, text=str.tostring(whiteCandleHigh), color=color.green, style=label.style_label_left, textcolor=color.white, size=size.small)
//label.new(bar_index + 70, whiteCandleLow, text=str.tostring(whiteCandleLow), color=color.red, style=label.style_label_left, textcolor=color.white, size=size.small)

// --- SIGNAL LOGIC ----
// 1. Generate Buy Signal when price closes above the white candle high and only if it's the first occurrence
// 1. Generate Buy Signal when price closes above the white candle high and only if it's the first occurrence
buySignal = high > highestHigh and isWhiteCandleDetected and ema10 > ema20 and not signalGiven and not emaCrossUp

if buySignal
    signalGiven := true // Ensure that the buy signal is triggered only once
    line.new(x1 = bar_index, y1 = highestHigh + difference / 2, x2 = bar_index + 30, y2 = highestHigh + difference /2, color = color.rgb(54, 17, 219), width = 1, style = line.style_dotted)
    line.new(x1 = bar_index, y1 = highestHigh + difference, x2 = bar_index + 30, y2 = highestHigh + difference, color = color.rgb(54, 17, 219), width = 2, style = line.style_solid)
    line.new(x1 = bar_index, y1 = highestHigh + difference * 1.5, x2 = bar_index + 32, y2 = highestHigh + difference * 1.5, color = color.rgb(54, 17, 219), width = 1, style = line.style_dotted)
    line.new(x1 = bar_index, y1 = highestHigh + difference * 2, x2 = bar_index + 32, y2 = highestHigh + difference * 2, color = color.navy, width = 2, style = line.style_solid)
    line.new(x1 = bar_index, y1 = highestHigh + difference * 2.5, x2 = bar_index + 34, y2 = highestHigh + difference * 2.5, color = color.rgb(54, 17, 219), width = 1, style = line.style_dotted)
    line.new(x1 = bar_index, y1 = highestHigh + difference * 3, x2 = bar_index + 34, y2 = highestHigh + difference * 3, color = color.navy, width = 2, style = line.style_solid)
    buyPrice = close
    volume2 := volume
    stoplossPrice = lowestLow
    targetPrice = highestHigh + difference
    //cbuy := chighestHigh
    //csloss := clowestLow
    //ctarget := chighestHigh + cdifference
    //pbuy := plowestLow
    //psloss := phighestHigh
    //ptarget := plowestLow - pdifference




    //if showTable2
    // Update the table with the Buy, Stoploss, and Target prices
      //  table.cell(t, 0, 0, text = 'Buy Price: ' + str.tostring(buyPrice), text_color = color.white, bgcolor = color.green)
        //table.cell(t, 1, 0, text = 'Stoploss: ' + str.tostring(stoplossPrice), text_color = color.white, bgcolor = color.red)
        //table.cell(t, 2, 0, text = 'Target: ' + str.tostring(targetPrice), text_color = color.white, bgcolor = color.blue)
        //table.cell(t, 0, 1, text = 'Margin needed: ' + str.tostring(math.round(quantity * buyPrice)), text_color = color.white, bgcolor = color.red)
        //table.cell(t, 1, 1, text = 'Max Profit: ' + str.tostring(math.round(quantity * (targetPrice - buyPrice))), text_color = color.white, bgcolor = color.green)
        //table.cell(t, 2, 1, text = 'Max Loss: ' + str.tostring(math.round(quantity * (buyPrice - stoplossPrice))), text_color = color.white, bgcolor = color.red)

    //log_to_alert("Buy "+str.tostring(custom_strike_priceC)+" CE:\n" + "Buy Price: " + str.tostring(cbuy) + "\n" + "Stoploss: " + str.tostring(csloss) + "\n" + "Target: " + str.tostring(ctarget) + "\n" + "Margin Needed: " + str.tostring(math.round(quantity * cbuy)) + "\n" + "Max Profit: " + str.tostring(math.round(quantity * (ctarget - cbuy))) + "\n" + "Max Loss: " + str.tostring(math.round(quantity * (cbuy - csloss))))


// 2. Generate Sell Signal when price closes below the white candle low and only if it's the first occurrence
sellSignal = low < lowestLow and isWhiteCandleDetected and ema10 < ema20 and not signalGiven and not emaCrossDown

if sellSignal
    signalGiven := true // Ensure that the sell signal is triggered only once
    line.new(x1 = bar_index, y1 = lowestLow - difference / 2, x2 = bar_index + 30, y2 = lowestLow - difference / 2, color = color.rgb(210, 20, 115), width = 1, style = line.style_dotted)
    line.new(x1 = bar_index, y1 = lowestLow - difference, x2 = bar_index + 30, y2 = lowestLow - difference, color = color.rgb(210, 20, 115), width = 2, style = line.style_solid)
    line.new(x1 = bar_index, y1 = lowestLow - difference * 1.5, x2 = bar_index + 32, y2 = lowestLow - difference * 1.5, color = color.rgb(210, 20, 115), width = 1, style = line.style_dotted)
    line.new(x1 = bar_index, y1 = lowestLow - difference * 2, x2 = bar_index + 32, y2 = lowestLow - difference * 2, color = color.rgb(255, 105, 180), width = 2, style = line.style_solid)
    line.new(x1 = bar_index, y1 = lowestLow - difference * 2.5, x2 = bar_index + 34, y2 = lowestLow - difference * 2.5, color = color.rgb(210, 20, 115), width = 1, style = line.style_dotted)
    line.new(x1 = bar_index, y1 = lowestLow - difference * 3, x2 = bar_index + 34, y2 = lowestLow - difference * 3, color = color.rgb(255, 105, 180), width = 2, style = line.style_solid)
    sellPrice = close
    volume3 := volume
    stoplossPrice = highestHigh
    targetPrice = lowestLow - difference //  var table t = table.new(position.bottom_center, 3, 1)
    //pbuy := phighestHigh
    //psloss := plowestLow
    //ptarget := phighestHigh + pdifference
    //cbuy := clowestLow
    //csloss:= chighestHigh
    //ctarget:= clowestLow - cdifference

    //if showTable2
    // Update the table with the Buy, Stoploss, and Target prices
      //  table.cell(t, 0, 0, text = 'Sell Price: ' + str.tostring(sellPrice), text_color = color.white, bgcolor = color.green)
        //table.cell(t, 1, 0, text = 'Stoploss: ' + str.tostring(stoplossPrice), text_color = color.white, bgcolor = color.red)
        //table.cell(t, 2, 0, text = 'Target: ' + str.tostring(targetPrice), text_color = color.white, bgcolor = color.blue)
        //table.cell(t, 0, 1, text = 'Margin needed: ' + str.tostring(math.round(quantity * sellPrice)), text_color = color.white, bgcolor = color.red)
        //table.cell(t, 1, 1, text = 'Max Profit: ' + str.tostring(math.round(quantity * (sellPrice - targetPrice))), text_color = color.white, bgcolor = color.green)
        //table.cell(t, 2, 1, text = 'Max Loss: ' + str.tostring(math.round(quantity * (stoplossPrice - sellPrice))), text_color = color.white, bgcolor = color.red)

    // Log to alert
    log_to_alert("Buy "+str.tostring(custom_strike_priceP)+" PE:\n" +"Buy Price: " + str.tostring(pbuy) + "\n" +"Stoploss: " + str.tostring(psloss) + "\n" +"Target: " + str.tostring(ptarget) + "\n" +"Margin Needed: " + str.tostring(math.round(quantity * psloss)) + "\n" +"Max Profit: " + str.tostring(math.round(quantity * (pbuy - ptarget))) + "\n" +"Max Loss: " + str.tostring(math.round(quantity * (psloss - pbuy))))

// 3. Always give Buy signal on Blue Candle (but not if the current candle closes above the Blue candle high)
buySignalBlue = bullCond and close <= high
buySignalBlue1 = hiddenBullCond and close <= high // Only give Buy signal if not above the Blue candle

// 4. Always give Sell signal on Rose (Pink) Candle (but not if the current candle closes below the Rose candle low)
sellSignalRose = hiddenBearCond and close >= low
sellSignalRose1 = bearCond and close >= low // Only give Sell signal if not below the Rose candle

// --- Volume Logic ---
// Calculate 20-period moving average of volume
volMA = ta.sma(volume, 20)

// Check if the current volume is above the 20-period volume moving average
volumeCondition = volume > volMA

volcon1 = volume1 < volume2
volcon2 = volume1 < volume3
// Final Buy and Sell Signals
finalBuySignal = buySignal
finalSellSignal = sellSignal

// Plotting Blue signals when volume condition is met
plotshape(finalBuySignal and volumeCondition, title = 'Buy Signal (Blue)', location = location.belowbar, color = color.blue, style = shape.labelup, text = 'BUY', textcolor = color.white)
plotshape(finalSellSignal and volumeCondition, title = 'Sell Signal (Blue)', location = location.abovebar, color = color.blue, style = shape.labeldown, text = 'SELL', textcolor = color.white)

//plotshape(finalBuySignal and volcon1, title = 'Buy Signal (Good)', location = location.belowbar, color = color.fuchsia, style = shape.labelup, text = 'GBUY', textcolor = color.white)
//plotshape(finalSellSignal and volcon2, title = 'Sell Signal (Good)', location = location.abovebar, color = color.fuchsia, style = shape.labeldown, text = 'GSELL', textcolor = color.white)

// Normal Buy/Sell signals (without volume condition) for other candles
plotshape(finalBuySignal and not volumeCondition, title = 'Normal Buy Signal', location = location.belowbar, color = color.green, style = shape.labelup, text = 'BUY', textcolor = color.white)
plotshape(finalSellSignal and not volumeCondition, title = 'Normal Sell Signal', location = location.abovebar, color = color.red, style = shape.labeldown, text = 'SELL', textcolor = color.white)

// Plotting BUY DIVERGENCE signals when MA condition is met
//plotshape(emaCrossUp, title = 'Up', location = location.belowbar, color = color.green, style = shape.labelup, text = 'U', textcolor = color.red)
//plotshape(emaCrossDown, title = 'Down', location = location.abovebar, color = color.red, style = shape.labeldown, text = 'D', textcolor = color.yellow)



// ---- ALERT CONDITIONS ----
// Buy Signal Alert Condition
alertcondition(finalBuySignal, title = 'Buy Signal', message = 'Buy Signal Triggered!')

// Sell Signal Alert Condition
alertcondition(finalSellSignal, title = 'Sell Signal', message = 'Sell Signal Triggered!')

// Combined Buy or Sell Signal Alert Condition
alertcondition(finalBuySignal or finalSellSignal, title = 'Buy or Sell Signal', message = 'Buy or Sell Signal Triggered!')

// Combined Direction or Sell Signal Alert Condition
alertcondition(emaCrossUp or emaCrossDown, title = 'Up or Down Direction', message = 'Up or Down Direction Changed!')
// --- Plotting the 10 and 20 Period EMAs ---
plot(ema10, title="EMA 10", color=color.orange, linewidth=1)  // Plot the 10-period EMA in orange
plot(ema20, title="EMA 20", color=color.blue, linewidth=1)   // Plot the 20-period EMA in blue

// --- Table Setup ---
//var myTable = table.new(position.top_right, 6, 6, border_width = 1)

// Recent signal logic
var string recentSignal = 'None'
var string recentDirection = 'None'
var string recentTrend = 'None'

// Check recent signal on the current chart
if finalBuySignal
    recentSignal := 'BUY'
    recentSignal
if finalSellSignal
    recentSignal := 'SELL'
    recentSignal

if emaCrossUp
    recentDirection := 'Up'
    recentDirection

if emaCrossDown
    recentDirection := 'Down'
    recentDirection


ema_value1 = ta.ema(whiteCandleAvg, 64)
if close > ema_value1
    recentTrend := 'Up'
    recentTrend

if close < ema_value1
    recentTrend := 'Down'
    recentTrend


//screener_func() =>


    //[recentSignal, recentDirection, recentTrend]


//[resignal01, redirection01, recenttrend01] = request.security(spot_ + _year + _month + _day + 'C' + str.tostring(custom_strike_priceC), timeframe.period, screener_func())
//[resignal03, redirection03, recenttrend03] = request.security(spot_ + _year + _month + _day + 'P' + str.tostring(custom_strike_priceP), timeframe.period, screener_func())


// Condition 3: Opposite direction between group 1 and group 2
//oppositeDirection = recenttrend01 != recenttrend03
// Final condition for "isTrending"
//isTrending = oppositeDirection

// Column headers
//if barstate.islast and showTable
  //  table.cell(myTable, 0, 0, 'TimeFrame', text_color = color.white, bgcolor = color.blue)
//    table.cell(myTable, 1, 0, 'Strike', text_color = color.white, bgcolor = color.blue)
  //  table.cell(myTable, 2, 0, 'Buy/Sell Aftre close', text_color = color.white, bgcolor = color.blue)
    //table.cell(myTable, 3, 0, 'Target', text_color = color.white, bgcolor = color.blue)
//    table.cell(myTable, 4, 0, 'SL', text_color = color.white, bgcolor = color.blue)


    // Row data
  //  table.cell(myTable, 0, 1, timeframe.period, text_color = color.black, bgcolor = color.olive)
    //table.cell(myTable, 1, 1, str.tostring(custom_strike_priceC) + 'CE', text_color = color.black, bgcolor = color.green)
    //table.cell(myTable, 2, 1, str.tostring(cbuy), bgcolor = redirection01 == 'Up' ? color.new(color.green, 10) : color.new(color.red, 10))
    //table.cell(myTable, 3, 1, str.tostring(ctarget), bgcolor = resignal01 == 'BUY' ? color.new(color.green, 10) : color.new(color.red, 10))
    //table.cell(myTable, 4, 1, str.tostring(csloss), bgcolor = recenttrend01 == 'Up' ? color.new(color.green, 10) : color.new(color.red, 10))

    //table.cell(myTable, 0, 3, timeframe.period, text_color = color.black, bgcolor = color.olive)
    //table.cell(myTable, 1, 3, str.tostring(custom_strike_priceP) + 'PE', text_color = color.black, bgcolor = color.red)
    //table.cell(myTable, 2, 3, str.tostring(pbuy), bgcolor = redirection03 == 'Up' ? color.new(color.green, 10) : color.new(color.red, 10))
    //table.cell(myTable, 3, 3, str.tostring(ptarget), bgcolor = resignal03 == 'BUY' ? color.new(color.green, 10) : color.new(color.red, 10))
    //table.cell(myTable, 4, 3, str.tostring(psloss), bgcolor = recenttrend03 == 'Up' ? color.new(color.green, 10) : color.new(color.red, 10))
// Add merged row with "No Trade" if all trends are Down
//if isTrending
    // Place "No Trade" in the first column and leave the other columns empty
  //  table.cell(myTable, 2, 5, 'Option Buying', text_color = color.white, bgcolor = color.gray)
//else // Leave the row empty if not all trends are Down
  //  table.cell(myTable, 2, 5, 'Option Selling', text_color = color.white, bgcolor = color.gray)

Rsi_value = 14
hl = 80
ll = 20
rs = ta.rsi(close, Rsi_value)

sma_value = 70
sma1 = ta.sma(close, sma_value)

dist_SMA = 1
candle_length = 1

//iff_1 = high < sma1 ? color.new(color.red,30) : color.new(color.yellow,30)
//iff_2 = low > sma1 ? color.new(color.lime,30) : iff_1
//mycolor = rs >= hl or rs <= ll ? color.new(color.yellow,30) : iff_2
//plot(sma1, title='SMA', color=mycolor, linewidth=1)

gaps = sma1 + dist_SMA //Gap between price and SMA for Sell
gapb = sma1 - dist_SMA //Gap between price and SMA for Buy
chartgap = bool(gaps) or bool(gapb) //for both below or above the SMA 
gap1 = sma1 + 5
gapvalue = open / 100 * candle_length //setting % with its Share price
gapp = high - low > gapvalue //or rs<50     // Condition for Min candle size to be eligible for giving signal - Buy Calls
gapp2 = high - low > gapvalue //or rs>55    // Condition for Min candle size to be eligible for giving signal - Sell Calls
bull = open < close and high - low > 2 * gapvalue and close > (high + open) / 2
bear = open > close and high - low > 2 * gapvalue and close < (low + open) / 2


rev1 = rs > 68 and open > close and open > gaps and high - low > gapvalue + 0.5 and low != close //over red candles  "S" - uptrend
rev1a = rs > 90 and open < close and close > gaps and high != close and open != low // over green candles"S" - uptrend
sellrev = rev1 or rev1a

rev2 = rs < 50 and open < close and open < gapb and open == low //over green candles"B"
rev3 = rs < 30 and open > close and high > gapb and open != high and barstate.isconfirmed != bear //over red candles"B"
rev4 = rs < 85 and close == high and high - low > gapvalue and open < close //over green candle in both trends
hlrev_s = ta.crossunder(rs, hl)
llrev_b = ta.crossover(rs, ll) and open < close
plotshape(hlrev_s, title = 'Reversal1', style = shape.labeldown, color = color.new(color.yellow, 20), text = '!', textcolor = color.new(color.black, 20))
plotshape(llrev_b, title = 'Reversal2', style = shape.labelup, color = color.new(color.yellow, 20), text = '!', textcolor = color.new(color.black, 20), location = location.belowbar)

ema_length = 64
ema_value = ta.ema(whiteCandleAvg, ema_length)

iff_3 = close < ema_value ? color.new(color.red, 30) : color.new(color.yellow, 30)
iff_4 = close > ema_value ? color.new(color.lime, 30) : iff_3
mycolor = rs >= hl or rs <= ll ? color.new(color.yellow, 30) : iff_4


plot(isWhiteCandleDetected ? ema_value : na, color = mycolor, linewidth = 1, title = 'EMA for White Candles')

//plot(candlesToTarget, title="Candles to Target", color=color.blue, linewidth=2, style=plot.style_line)
````
