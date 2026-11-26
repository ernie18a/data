# Market Dashboard + Support & Resistance

- url: https://www.tradingview.com/script/zUfc2gLi-Market-Dashboard-Support-Resistance/
- type: indicator
- pine_id: PUB;3916a2f18a6d440ba36f0f02a3d1be9e
- version: 1.0

## Description

a neat little scription to give you a snapshot of what is going on.

## Source Code

````pine
//@version=6
indicator('Market Dashboard + Support & Resistance', overlay = true)

// =====================
// INPUTS
// =====================
atrLength = input.int(14, 'ATR Length', minval = 1)

pivotLength = input.int(20, 'Support/Resistance Lookback', minval = 5)

nearLowPercent = input.float(1.0, 'Near Low % Threshold', step = 0.1)
nearHighPercent = input.float(1.0, 'Near High % Threshold', step = 0.1)

highATRPercent = input.float(5.0, 'High ATR % Threshold', step = 0.1)
lowATRPercent = input.float(1.0, 'Low ATR % Threshold', step = 0.1)

nearATRHigh = input.float(0.5, 'Near High ATR Distance', step = 0.1)
nearATRLow = input.float(0.5, 'Near Low ATR Distance', step = 0.1)

highlightLowThreshold = input.float(0.05, 'Highlight Near Low %', step = 0.01)
highlightHighThreshold = input.float(0.05, 'Highlight Near High %', step = 0.01)

squeezeThreshold = input.float(1.0, 'ATR Squeeze %', step = 0.1)

// =====================
// LEVELS
// =====================
dayLow = request.security(syminfo.tickerid, 'D', low)
dayHigh = request.security(syminfo.tickerid, 'D', high)

yesterdayClose = request.security(syminfo.tickerid, 'D', close[1])

currentPrice = close

// =====================
// SUPPORT / RESISTANCE
// =====================
nextResistance = ta.highest(high, pivotLength)
nextSupport = ta.lowest(low, pivotLength)

resistanceDistance = (nextResistance - currentPrice) / currentPrice * 100
supportDistance = (currentPrice - nextSupport) / currentPrice * 100

// =====================
// CALCULATIONS
// =====================
percentFromLow = (currentPrice - dayLow) / dayLow * 100
percentBelowHigh = (dayHigh - currentPrice) / dayHigh * 100
percentFromYClose = (currentPrice - yesterdayClose) / yesterdayClose * 100

// =====================
// ATR
// =====================
atr = ta.atr(atrLength)

atrPercent = atr / currentPrice * 100

atrToHigh = (dayHigh - currentPrice) / atr
atrToLow = (currentPrice - dayLow) / atr

// =====================
// ATR BIAS
// =====================
buyBias = atrToLow < atrToHigh
sellBias = atrToHigh < atrToLow

// =====================
// CONDITIONS
// =====================
nearLowHighlight = percentFromLow <= highlightLowThreshold
nearHighHighlight = percentBelowHigh <= highlightHighThreshold

atrBreakoutHigh = atrToHigh <= nearATRHigh
atrBreakoutLow = atrToLow <= nearATRLow

atrSqueeze = atrPercent <= squeezeThreshold

yCloseCrossUp = ta.crossover(close, yesterdayClose)
yCloseCrossDown = ta.crossunder(close, yesterdayClose)

// =====================
// COLORS
// =====================
lowBg = nearLowHighlight ? color.orange : color.red
lowTxt = color.white

highBg = nearHighHighlight ? color.lime : color.green
highTxt = color.white

yCloseBg = yCloseCrossUp or yCloseCrossDown ? color.rgb(13, 9, 240) : color.rgb(36, 5, 209)
yCloseTxt = color.white

atrFlashBg = color.gray
atrFlashTxt = color.white

if atrBreakoutHigh or atrBreakoutLow
    atrFlashBg := color.purple
    atrFlashBg

else if atrSqueeze
    atrFlashBg := color.yellow
    atrFlashTxt := color.black
    atrFlashTxt

else if buyBias
    atrFlashBg := color.lime
    atrFlashBg

else if sellBias
    atrFlashBg := color.red
    atrFlashBg

// STATIC SUPPORT / RESISTANCE COLORS
resBg = color.orange
resTxt = color.white

supBg = color.teal
supTxt = color.white

// =====================
// TABLE
// =====================
var table t = table.new(position.top_right, 4, 8, border_width = 1)

txtSize = size.small

if barstate.islast

    // HEADER
    table.cell(t, 0, 0, 'MARKET DASHBOARD', text_color = color.white, bgcolor = color.black, text_size = txtSize)

    table.cell(t, 1, 0, '', bgcolor = color.black)
    table.cell(t, 2, 0, '', bgcolor = color.black)
    table.cell(t, 3, 0, '', bgcolor = color.black)

    // =====================
    // TODAY LOW
    // =====================
    table.cell(t, 0, 1, 'Today\'s Low', text_color = lowTxt, bgcolor = lowBg, text_size = txtSize)

    table.cell(t, 1, 1, str.tostring(dayLow, format.mintick), text_color = lowTxt, bgcolor = lowBg, text_size = txtSize)

    // =====================
    // TODAY HIGH
    // =====================
    table.cell(t, 2, 1, 'Today\'s High', text_color = highTxt, bgcolor = highBg, text_size = txtSize)

    table.cell(t, 3, 1, str.tostring(dayHigh, format.mintick), text_color = highTxt, bgcolor = highBg, text_size = txtSize)

    // =====================
    // DISTANCES
    // =====================
    table.cell(t, 0, 2, 'Above Low %', text_color = color.white, bgcolor = color.red, text_size = txtSize)

    table.cell(t, 1, 2, str.tostring(percentFromLow, '#.##') + '%', text_color = color.white, bgcolor = color.red, text_size = txtSize)

    table.cell(t, 2, 2, 'Below High %', text_color = color.white, bgcolor = color.green, text_size = txtSize)

    table.cell(t, 3, 2, str.tostring(percentBelowHigh, '#.##') + '%', text_color = color.white, bgcolor = color.green, text_size = txtSize)

    // =====================
    // YESTERDAY CLOSE
    // =====================
    table.cell(t, 0, 3, 'Yesterday Close', text_color = yCloseTxt, bgcolor = yCloseBg, text_size = txtSize)

    table.cell(t, 1, 3, str.tostring(yesterdayClose, format.mintick), text_color = yCloseTxt, bgcolor = yCloseBg, text_size = txtSize)

    table.cell(t, 2, 3, 'From Y Close %', text_color = yCloseTxt, bgcolor = yCloseBg, text_size = txtSize)

    table.cell(t, 3, 3, str.tostring(percentFromYClose, '#.##') + '%', text_color = yCloseTxt, bgcolor = yCloseBg, text_size = txtSize)

    // =====================
    // CURRENT PRICE + ATR
    // =====================
    table.cell(t, 0, 4, 'Current Price', text_color = color.white, bgcolor = color.gray, text_size = txtSize)

    table.cell(t, 1, 4, str.tostring(currentPrice, format.mintick), text_color = color.white, bgcolor = color.gray, text_size = txtSize)

    table.cell(t, 2, 4, 'ATR (' + str.tostring(atrLength) + ')', text_color = atrFlashTxt, bgcolor = atrFlashBg, text_size = txtSize)

    table.cell(t, 3, 4, str.tostring(atr, format.mintick), text_color = atrFlashTxt, bgcolor = atrFlashBg, text_size = txtSize)

    // =====================
    // ATR DETAILS
    // =====================
    table.cell(t, 0, 5, 'ATR %', text_color = atrFlashTxt, bgcolor = atrFlashBg, text_size = txtSize)

    table.cell(t, 1, 5, str.tostring(atrPercent, '#.##') + '%', text_color = atrFlashTxt, bgcolor = atrFlashBg, text_size = txtSize)

    table.cell(t, 2, 5, 'ATR Bias', text_color = atrFlashTxt, bgcolor = atrFlashBg, text_size = txtSize)

    table.cell(t, 3, 5, buyBias ? 'BUY BIAS' : sellBias ? 'SELL BIAS' : 'NEUTRAL', text_color = atrFlashTxt, bgcolor = atrFlashBg, text_size = txtSize)

    // =====================
    // RESISTANCE
    // =====================
    table.cell(t, 0, 6, 'Next Resistance', text_color = resTxt, bgcolor = resBg, text_size = txtSize)

    table.cell(t, 1, 6, str.tostring(nextResistance, format.mintick), text_color = resTxt, bgcolor = resBg, text_size = txtSize)

    table.cell(t, 2, 6, 'Resistance %', text_color = resTxt, bgcolor = resBg, text_size = txtSize)

    table.cell(t, 3, 6, str.tostring(resistanceDistance, '#.##') + '%', text_color = resTxt, bgcolor = resBg, text_size = txtSize)

    // =====================
    // SUPPORT
    // =====================
    table.cell(t, 0, 7, 'Next Support', text_color = supTxt, bgcolor = supBg, text_size = txtSize)

    table.cell(t, 1, 7, str.tostring(nextSupport, format.mintick), text_color = supTxt, bgcolor = supBg, text_size = txtSize)

    table.cell(t, 2, 7, 'Support %', text_color = supTxt, bgcolor = supBg, text_size = txtSize)

    table.cell(t, 3, 7, str.tostring(supportDistance, '#.##') + '%', text_color = supTxt, bgcolor = supBg, text_size = txtSize)

// =====================
// ALERT CONDITIONS
// =====================

// HIGH / LOW BREAKS
alertcondition(close > dayHigh, title = 'Break Above Day High', message = 'Price broke ABOVE today\'s high')

alertcondition(close < dayLow, title = 'Break Below Day Low', message = 'Price broke BELOW today\'s low')

// YESTERDAY CLOSE
alertcondition(ta.crossover(close, yesterdayClose), title = 'Cross Above Yesterday Close', message = 'Price crossed ABOVE yesterday\'s close')

alertcondition(ta.crossunder(close, yesterdayClose), title = 'Cross Below Yesterday Close', message = 'Price crossed BELOW yesterday\'s close')

// NEAR HIGH / LOW
alertcondition(percentFromLow < nearLowPercent, title = 'Near Day Low', message = 'Price is near today\'s low')

alertcondition(percentBelowHigh < nearHighPercent, title = 'Near Day High', message = 'Price is near today\'s high')

// ATR VOLATILITY
alertcondition(atrPercent > highATRPercent, title = 'High ATR Volatility', message = 'ATR volatility is HIGH')

alertcondition(atrPercent < lowATRPercent, title = 'Low ATR Volatility', message = 'ATR volatility is LOW')

// ATR BIAS
alertcondition(buyBias, title = 'ATR Buy Bias', message = 'ATR bias switched to BUY')

alertcondition(sellBias, title = 'ATR Sell Bias', message = 'ATR bias switched to SELL')

// ATR BREAKOUT ZONES
alertcondition(atrToHigh < nearATRHigh, title = 'Near Breakout High', message = 'Price is within ATR threshold of today\'s high')

alertcondition(atrToLow < nearATRLow, title = 'Near Breakdown Low', message = 'Price is within ATR threshold of today\'s low')

// ATR SQUEEZE
alertcondition(atrSqueeze, title = 'ATR Squeeze', message = 'ATR volatility compression detected')
````
