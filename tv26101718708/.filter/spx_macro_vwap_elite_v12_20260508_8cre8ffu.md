# SPX Macro VWAP Elite v1.2 | 2026-05-08

- url: https://www.tradingview.com/script/8CRe8ffu-SPX-Macro-VWAP-Elite-v1-2-2026-05-08/
- type: indicator
- pine_id: PUB;922f32ce20e64b258fe0502f5503beee
- version: 1.0

## Description

SPX Buy & Sell signals updated 5/8. This will give user Buy, Strong, Sell & strong sell signals on SPX 5 min chart. this you can use it for QQQ as well.

## Source Code

````pine
//@version=5
indicator("SPX Macro VWAP Elite v1.2 | 2026-05-08", overlay=true, max_labels_count=500)

//--------------------------------------------------
// SETTINGS
//--------------------------------------------------
useTimeFilter   = input.bool(false, "Use 9:30-11:00 & 2:00-3:30 NY Filter?")
useTrendFilter  = input.bool(true, "Use Trend Filter?")
useVolumeFilter = input.bool(false, "Use Volume Filter?")
useATRFilter    = input.bool(true, "Use ATR Candle Strength Filter?")
useMacroFilter  = input.bool(true, "Use 10Y Macro Filter?")

trendLen   = input.int(34, "Hull MA Length")
volLen     = input.int(20, "Volume MA Length")
atrLen     = input.int(14, "ATR Length")
minBodyATR = input.float(0.25, "Minimum Candle Body vs ATR", step=0.05)

bondSymbol = input.symbol("TVC:US10Y", "10 Year Yield Symbol")
oilSymbol  = input.symbol("TVC:USOIL", "Crude Oil Symbol")
macroLen   = input.int(5, "Macro Trend Length")

showCandlePatterns = input.bool(true, "Show Candlestick Pattern Labels?")
usePatternConfirm  = input.bool(false, "Require Candle Pattern Confirmation?")
showFractals       = input.bool(false, "Show Fractals?")
showFractalLevels  = input.bool(false, "Show Fractal S/R Levels?")
useMACDConfirm     = input.bool(false, "Use MACD Pattern Confirmation?")
useMomentumConfirm = input.bool(true, "Use Momentum Confirmation?")

//--------------------------------------------------
// TIME FILTER
//--------------------------------------------------
sess1 = "0930-1100"
sess2 = "1400-1530"
tz = "America/New_York"

t1 = time(timeframe.period, sess1, tz)
t2 = time(timeframe.period, sess2, tz)

inSession = not useTimeFilter or not na(t1) or not na(t2)
bgcolor(useTimeFilter and inSession ? color.new(color.blue, 92) : na)

//--------------------------------------------------
// VWAP
//--------------------------------------------------
vwapVal = ta.vwap(hlc3)
plot(vwapVal, "VWAP", color=color.orange, linewidth=3)

//--------------------------------------------------
// HULL MA TREND
//--------------------------------------------------
hma = ta.hma(close, trendLen)
trendUp = hma > hma[1]
trendDown = hma < hma[1]

plot(hma, "Hull MA", color=trendUp ? color.green : color.red, linewidth=2)

trendOKBuy  = not useTrendFilter or trendUp
trendOKSell = not useTrendFilter or trendDown

//--------------------------------------------------
// VOLUME FILTER
//--------------------------------------------------
volMA = ta.sma(volume, volLen)
volumeOK = not useVolumeFilter or volume > volMA

//--------------------------------------------------
// ATR FILTER
//--------------------------------------------------
atr = ta.atr(atrLen)
body = math.abs(close - open)
validBody = body > atr * 0.20
atrOK = not useATRFilter or body > atr * minBodyATR

//--------------------------------------------------
// MACRO FILTER: 10Y + OIL TABLE
//--------------------------------------------------
tenY = request.security(bondSymbol, timeframe.period, close)
oil  = request.security(oilSymbol, timeframe.period, close)

tenYMA = ta.sma(tenY, macroLen)
oilMA  = ta.sma(oil, macroLen)

tenYRising = tenY > tenYMA
oilRising  = oil > oilMA

macroOKBuy  = not useMacroFilter or not tenYRising
macroOKSell = not useMacroFilter or tenYRising

//--------------------------------------------------
// CANDLE MATH
//--------------------------------------------------
rng = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

bullCandle = close > open
bearCandle = close < open

bullPin = validBody and bullCandle and lowerWick >= body * 1.5 and lowerWick > upperWick
bearPin = validBody and bearCandle and upperWick >= body * 1.5 and upperWick > lowerWick

bullEngulf = validBody and bullCandle and close[1] < open[1] and open <= close[1] and close >= open[1]
bearEngulf = validBody and bearCandle and close[1] > open[1] and open >= close[1] and close <= open[1]

darkCloud = validBody and close[1] > open[1] and math.abs(close[1] - open[1]) / rng[1] >= 0.7 and close < open and math.abs(close - open) / rng >= 0.7 and open >= close[1] and close > open[1] and close < ((open[1] + close[1]) / 2)

piercingLine = validBody and close[1] < open[1] and math.abs(open[1] - close[1]) / rng[1] >= 0.7 and close > open and math.abs(close - open) / rng >= 0.7 and open <= close[1] and close < open[1] and close > ((open[1] + close[1]) / 2)

bearHarami = validBody and close[1] > open[1] and open > close and open <= close[1] and low >= open[1] and open - close < close[1] - open[1] and high < high[1] and low > low[1]

bullHarami = validBody and open[1] > close[1] and close > open and close <= open[1] and high <= open[1] and close - open < open[1] - close[1] and high < high[1] and low > low[1]

bullPattern = bullPin or bullEngulf or piercingLine or bullHarami
bearPattern = bearPin or bearEngulf or darkCloud or bearHarami

//--------------------------------------------------
// FRACTALS
//--------------------------------------------------
topFractal = high[2] > high[1] and high[2] > high and high[2] > high[3] and high[2] > high[4]
botFractal = low[2] < low[1] and low[2] < low and low[2] < low[3] and low[2] < low[4]

var float topLevel = na
var float botLevel = na

if topFractal
    topLevel := high[2]

if botFractal
    botLevel := low[2]

plotshape(showFractals and topFractal, title="Top Fractal", color=color.green, style=shape.triangleup, location=location.abovebar, offset=-2, size=size.tiny)
plotshape(showFractals and botFractal, title="Bottom Fractal", color=color.red, style=shape.triangledown, location=location.belowbar, offset=-2, size=size.tiny)

plot(showFractalLevels ? topLevel : na, "Top Fractal Level", color=color.green, linewidth=1)
plot(showFractalLevels ? botLevel : na, "Bottom Fractal Level", color=color.red, linewidth=1)

bullFractalBreak = not na(topLevel) and ta.crossover(close, topLevel)
bearFractalBreak = not na(botLevel) and ta.crossunder(close, botLevel)

//--------------------------------------------------
// MACD CONFIRMATION
//--------------------------------------------------
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

macdBullOK = not useMACDConfirm or histLine > histLine[1]
macdBearOK = not useMACDConfirm or histLine < histLine[1]

//--------------------------------------------------
// VWAP SETUPS
//--------------------------------------------------
vwapBounce =
     low <= vwapVal and
     close > vwapVal and
     close > open and
     body > atr * 0.25

vwapReclaim =
     ta.crossover(close, vwapVal) and
     close > open and
     body > atr * 0.25

vwapRejection =
     high >= vwapVal and
     close < vwapVal and
     close < open and
     body > atr * 0.25

vwapBreakdown =
     close < vwapVal and
     close[1] >= vwapVal[1] and
     close < open and
     body > atr * 0.25

//--------------------------------------------------
// MOMENTUM CONFIRMATION
//--------------------------------------------------
momentumBuy = close > high[1]
momentumSell = close < low[1]

momentumOKBuy = not useMomentumConfirm or momentumBuy
momentumOKSell = not useMomentumConfirm or momentumSell

//--------------------------------------------------
// FINAL BUY / SELL SIGNALS
//--------------------------------------------------
patternOKBuy  = not usePatternConfirm or bullPattern or bullFractalBreak
patternOKSell = not usePatternConfirm or bearPattern or bearFractalBreak

baseBuy =
     barstate.isconfirmed and
     inSession and
     close > vwapVal and
     (vwapBounce or vwapReclaim or bullFractalBreak)

baseSell =
     barstate.isconfirmed and
     inSession and
     close < vwapVal and
     (vwapRejection or vwapBreakdown or bearFractalBreak)

filterBuyScore =
     (trendOKBuy ? 1 : 0) +
     (volumeOK ? 1 : 0) +
     (atrOK ? 1 : 0) +
     (macroOKBuy ? 1 : 0)

filterSellScore =
     (trendOKSell ? 1 : 0) +
     (volumeOK ? 1 : 0) +
     (atrOK ? 1 : 0) +
     (macroOKSell ? 1 : 0)

buySignal =
     baseBuy and
     filterBuyScore >= 3 and
     patternOKBuy and
     macdBullOK and
     momentumOKBuy

sellSignal =
     baseSell and
     filterSellScore >= 3 and
     patternOKSell and
     macdBearOK and
     momentumOKSell

strongBuy =
     buySignal and
     vwapReclaim and
     filterBuyScore == 4

strongSell =
     sellSignal and
     vwapBreakdown and
     filterSellScore == 4

//--------------------------------------------------
// VISUAL BUY / SELL SIGNALS
//--------------------------------------------------
plotshape(buySignal and not strongBuy, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(strongBuy, title="STRONG BUY", text="STRONG\nBUY", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.small)

plotshape(sellSignal and not strongSell, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)
plotshape(strongSell, title="STRONG SELL", text="STRONG\nSELL", style=shape.labeldown, location=location.abovebar, color=color.maroon, textcolor=color.white, size=size.small)

barcolor(strongBuy ? color.lime : buySignal ? color.green : strongSell ? color.maroon : sellSignal ? color.red : na)

//--------------------------------------------------
// OPTIONAL CANDLE PATTERN LABELS
//--------------------------------------------------
plotshape(showCandlePatterns and bullPin, title="Bull Pin", text="Bull\nPin", style=shape.arrowup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showCandlePatterns and bearPin, title="Bear Pin", text="Bear\nPin", style=shape.arrowdown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(showCandlePatterns and bullEngulf, title="Bull Engulf", text="Bull\nEngulf", style=shape.arrowup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showCandlePatterns and bearEngulf, title="Bear Engulf", text="Bear\nEngulf", style=shape.arrowdown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(showCandlePatterns and piercingLine, title="Piercing Line", text="Piercing", style=shape.arrowup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)

plotshape(showCandlePatterns and darkCloud, title="Dark Cloud", text="Dark\nCloud", style=shape.arrowdown, location=location.abovebar, color=color.maroon, textcolor=color.white, size=size.tiny)

plotshape(showCandlePatterns and bullHarami, title="Bull Harami", text="Bull\nHarami", style=shape.arrowup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showCandlePatterns and bearHarami, title="Bear Harami", text="Bear\nHarami", style=shape.arrowdown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

//--------------------------------------------------
// MACRO TABLE
//--------------------------------------------------
var table macroTable = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast
    table.cell(macroTable, 0, 0, "10Y", text_color=color.white, bgcolor=color.black)
    table.cell(macroTable, 1, 0, tenYRising ? "Rising" : "Falling", text_color=color.white, bgcolor=tenYRising ? color.red : color.green)

    table.cell(macroTable, 0, 1, "Oil", text_color=color.white, bgcolor=color.black)
    table.cell(macroTable, 1, 1, oilRising ? "Rising" : "Falling", text_color=color.white, bgcolor=oilRising ? color.red : color.green)

    table.cell(macroTable, 0, 2, "Macro", text_color=color.white, bgcolor=color.black)
    table.cell(macroTable, 1, 2, macroOKBuy ? "Bull OK" : macroOKSell ? "Bear OK" : "Mixed", text_color=color.white, bgcolor=macroOKBuy ? color.green : macroOKSell ? color.red : color.gray)

    table.cell(macroTable, 0, 3, "Filters", text_color=color.white, bgcolor=color.black)
    table.cell(macroTable, 1, 3, "Buy " + str.tostring(filterBuyScore) + "/4 | Sell " + str.tostring(filterSellScore) + "/4", text_color=color.white, bgcolor=color.gray)

//--------------------------------------------------
// ALERTS
//--------------------------------------------------
alertcondition(buySignal, title="BUY Signal", message="SPX Macro VWAP Elite: BUY Signal")
alertcondition(sellSignal, title="SELL Signal", message="SPX Macro VWAP Elite: SELL Signal")
alertcondition(strongBuy, title="STRONG BUY Signal", message="SPX Macro VWAP Elite: STRONG BUY Signal")
alertcondition(strongSell, title="STRONG SELL Signal", message="SPX Macro VWAP Elite: STRONG SELL Signal")
````
