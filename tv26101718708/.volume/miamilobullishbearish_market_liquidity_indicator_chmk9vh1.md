# Mia-MiloBullish/Bearish Market + Liquidity Indicator

- url: https://www.tradingview.com/script/CHMk9vh1-Mia-MiloBullish-Bearish-Market-Liquidity-Indicator/
- type: indicator
- pine_id: PUB;24cb18eb5b10498e891c24e2007c9e7b
- version: 1.0

## Description

The Ultimate All-in-One Market Indicator. Finding the perfect time to enter and exit the market is the biggest challenge in trading. To trade successfully, you need an indicator that highlights buying and selling opportunities, tracks market highs and lows, measures capital flow, and counts down candle time. Here is how a comprehensive technical indicator solves these problems for you. Finding Buying and Selling Opportunities. This indicator serves as your market compass, identifying precise entry and exit points. It scans price action to generate precise buy signals during market dips and sell signals near market peaks. By eliminating guesswork, it helps you execute trades with confidence and discipline. Identifying Highs and Lows. Accurately spotting market turning points is crucial for managing risk. The indicator automatically plots key support and resistance levels, marking the absolute highs and lows of recent price movements. This allows you to place accurate stop-loss orders and target profitable exit zones before the trend reverses. Tracking Market Capital (Volume and Liquidity). To know if a move is real, you must see how much capital is actively moving the market. The indicator includes a built-in volume and capital flow index. It reveals whether institutional money is entering or exiting an asset, helping you avoid false breakouts and trade alongside major market players. Monitoring Candle Time Timing is everything when confirming a trade setup. The indicator features an on-screen countdown timer that shows exactly how much time remains before the current candlestick closes. Knowing the remaining candle time prevents you from rushing into trades prematurely and ensures your entry aligns perfectly with candle confirmation.

## Source Code

````pine
//@version=6
indicator('Bullish/Bearish Market + Liquidity Indicator', overlay = true, max_labels_count = 500, max_lines_count = 500)

// ===== INPUTS =====
emaFastLen = input.int(20, 'Fast EMA', group = 'Trend')
emaSlowLen = input.int(50, 'Slow EMA', group = 'Trend')
emaTrendLen = input.int(200, 'Major Trend EMA', group = 'Trend')
pivotLen = input.int(10, 'Pivot Length', group = 'Support / Resistance')
volMaLen = input.int(20, 'Volume Moving Average', group = 'Volume / Liquidity')
volMult = input.float(1.8, 'High Volume Multiplier', group = 'Volume / Liquidity')
showPanel = input.bool(true, 'Show Panel', group = 'Panel')

// ===== COLORS =====
bullColor = color.new(color.green, 0)
bearColor = color.new(color.red, 0)

// ===== EMAS =====
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
emaTrend = ta.ema(close, emaTrendLen)

plot(emaFast, 'Fast EMA', color = color.green)
plot(emaSlow, 'Slow EMA', color = color.red)
plot(emaTrend, 'EMA 200', color = color.orange)

// ===== MARKET CONDITIONS =====
bullStart = ta.crossover(emaFast, emaSlow) and close > emaTrend
bearStart = ta.crossunder(emaFast, emaSlow) and close < emaTrend

bullMarket = emaFast > emaSlow and close > emaTrend
bearMarket = emaFast < emaSlow and close < emaTrend

plotshape(bullStart, title = 'Bullish Start', style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.normal, text = 'BULL')
plotshape(bearStart, title = 'Bearish Start', style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.normal, text = 'BEAR')

bgcolor(bullMarket ? color.new(color.green, 90) : bearMarket ? color.new(color.red, 90) : na)

// ===== LIQUIDITY / VOLUME =====
volMA = ta.sma(volume, volMaLen)
highVolume = volume > volMA * volMult

buyLiquidity = highVolume and close > open
sellLiquidity = highVolume and close < open

plotshape(buyLiquidity, title = 'Buying Liquidity', style = shape.circle, location = location.belowbar, color = color.lime, size = size.tiny, text = 'BUY')
plotshape(sellLiquidity, title = 'Selling Liquidity', style = shape.circle, location = location.abovebar, color = color.orange, size = size.tiny, text = 'SELL')

// ===== SUPPORT AND RESISTANCE =====
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float resistanceLevel = na
var float supportLevel = na

if not na(pivotHigh)
    resistanceLevel := pivotHigh
    resistanceLevel
line.new(bar_index - pivotLen, pivotHigh, bar_index, pivotHigh, extend = extend.right, color = bearColor, style = line.style_dashed, width = 1)

if not na(pivotLow)
    supportLevel := pivotLow
    supportLevel
line.new(bar_index - pivotLen, pivotLow, bar_index, pivotLow, extend = extend.right, color = bullColor, style = line.style_dashed, width = 1)

// ===== CANDLE DURATION =====
var float candleDurationSec = na
candleDurationSec := na(time[1]) ? na : math.abs(time - time[1]) / 1000.0

// ===== ALERTS =====
alertcondition(bullStart, title = 'Bullish Market Start', message = 'Bullish market started')
alertcondition(bearStart, title = 'Bearish Market Start', message = 'Bearish market started')
alertcondition(buyLiquidity, title = 'Buying Liquidity', message = 'Buying liquidity detected')
alertcondition(sellLiquidity, title = 'Selling Liquidity', message = 'Selling liquidity detected')
alertcondition(highVolume, title = 'High Volume', message = 'High volume detected')

// ===== PANEL =====
var table panel = table.new(position.top_right, 2, 8, border_width = 1)

if showPanel and barstate.islast
    marketStatus = bullMarket ? 'BULLISH' : bearMarket ? 'BEARISH' : 'NEUTRAL'
    marketColor = bullMarket ? bullColor : bearMarket ? bearColor : color.gray

    table.cell(panel, 0, 0, 'PARAMETER', text_color = color.white, bgcolor = color.black)
    table.cell(panel, 1, 0, 'STATUS', text_color = color.white, bgcolor = color.black)

    table.cell(panel, 0, 1, 'Market', text_color = color.white)
    table.cell(panel, 1, 1, marketStatus, text_color = color.white, bgcolor = marketColor)

    table.cell(panel, 0, 2, 'EMA 200 Trend', text_color = color.white)
    table.cell(panel, 1, 2, close > emaTrend ? 'Bullish' : 'Bearish', text_color = close > emaTrend ? color.lime : color.red)

    table.cell(panel, 0, 3, 'High Volume', text_color = color.white)
    table.cell(panel, 1, 3, highVolume ? 'Yes' : 'No', text_color = highVolume ? color.lime : color.gray)

    table.cell(panel, 0, 4, 'Liquidity', text_color = color.white)
    table.cell(panel, 1, 4, buyLiquidity ? 'Buying' : sellLiquidity ? 'Selling' : 'None', text_color = buyLiquidity ? color.lime : sellLiquidity ? color.orange : color.gray)

    table.cell(panel, 0, 5, 'Support', text_color = color.white)
    table.cell(panel, 1, 5, na(supportLevel) ? '-' : str.tostring(supportLevel, format.mintick), text_color = color.lime)

    table.cell(panel, 0, 6, 'Resistance', text_color = color.white)
    table.cell(panel, 1, 6, na(resistanceLevel) ? '-' : str.tostring(resistanceLevel, format.mintick), text_color = color.red)

    table.cell(panel, 0, 7, 'Volume / Candle Time', text_color = color.white)
    table.cell(panel, 1, 7, str.tostring(nz(volume)) + ' / ' + str.tostring(nz(candleDurationSec), '#') + 's', text_color = color.white)
````
