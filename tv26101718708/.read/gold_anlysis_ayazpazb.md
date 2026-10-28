# gold anlysis

- url: https://www.tradingview.com/script/AYAZpaZB-gold-anlysis/
- type: indicator
- pine_id: PUB;3205d32f9d644bcea956dd2fda37e06b
- version: 1.0

## Description

Gold trades modestly higher on the day above $4,700 after having touched a fresh 10-day low below $4,660 earlier in the day, but looks to end the week in negative territory. Intensifying US-Iran tensions over the Strait of Hormuz and the lack of progress in peace talks keep investors on edge. Moreover, reviving inflationary fears temper expectations for a more dovish US Federal Reserve and underpin the US Dollar, which is seen weighing on the yellow metal.

## Source Code

````pine
//@version=6
indicator(title="WOW", shorttitle="wow", overlay=true)
len = input.int(9, minval=1, title="Length")
src = input(low, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display = display.data_window)
out = ta.ema(src, len)
showEma100 = input(true,  "Show 100 EMA")
showEma200 = input(true,  "Show 200 EMA")
showBG = input(true,  "Show Background colour")
firstBuyAlert = false
firstSellAlert = false

ema100Color = input(color.new(#ffcc00, 0),    "100 EMA Color") // Purple
ema200Color = input(color.rgb(0, 0, 0),    "200 EMA Color") // Green
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)
lineWidth = input.int(2, "Line Width", minval=1, maxval=5)
plot(showEma100 ? ema100 : na, title="100 EMA", color=ema100Color, linewidth=lineWidth)
plot(showEma200 ? ema200 : na, title="200 EMA", color=ema200Color, linewidth=lineWidth)


// Detect crossovers
goldenCross = ta.crossover(ema100, ema200)
deathCross = ta.crossunder(ema100, ema200)
// Create a checkbox input
withTrend = input.bool(true, title="With the Trend")
twoCandles = input.bool(true, title="Two red or green candle")

bool buyCondition = false
bool sellCondition = false

sellsrc = input(high, title="Source")
sellout = ta.ema(sellsrc, len)

//plot(out, title="EMA", color=color.blue, offset=offset)
showValue = input(false, "Show Current Value")
showLabel = input(false, "Show Price Label")



// Smoothing MA inputs
GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.data_window)
maLengthInput = input.int(14, "Length", group = GRP, display = display.data_window)
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.data_window)
var enableMA = maTypeInput != "None"
var isBB = maTypeInput == "SMA + Bollinger Bands"

// Smoothing MA Calculation
ma(source, length, MAtype) =>
	switch MAtype
		"SMA"                   => ta.sma(source, length)
		"SMA + Bollinger Bands" => ta.sma(source, length)
		"EMA"                   => ta.ema(source, length)
		"SMMA (RMA)"            => ta.rma(source, length)
		"WMA"                   => ta.wma(source, length)
		"VWMA"                  => ta.vwma(source, length)

// Smoothing MA plots
smoothingMA = enableMA ? ma(out, maLengthInput, maTypeInput) : na
sellsmoothingMA = enableMA ? ma(sellout, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(out, maLengthInput) * bbMultInput : na
//plot(smoothingMA, "EMA-based MA", color=color.green, display = enableMA ? display.all : display.none, editable = enableMA)

//plot(sellsmoothingMA, "EMA-based MA", color=color.red, display = enableMA ? display.all : display.none, editable = enableMA)
// Display current value in Data Window
plotchar(enableMA ? smoothingMA : na, "EMA Value", "", location.top)

// // Optional: Label on last bar
if barstate.islast and showLabel
    label.new(bar_index, smoothingMA, text="EMA(" + str.tostring(len) + "): " + str.tostring(smoothingMA, format.mintick), style=label.style_label_left, color=color.new(color.blue, 90), textcolor=color.black, size=size.small )

// Condition check
ema100Above200 = ema100 > ema200

ema200Above100 = ema100 < ema200
// Candle conditions
currentGreen = close > open
previousGreen = close[1] > open[1]

twoGreenCandles = currentGreen and previousGreen  
twoRedCandles = (open[1] > close[1]) and (open > close)

if ema100Above200
    firstBuyAlert := true
if ema200Above100
    firstSellAlert:= true

if withTrend
    if twoCandles
        buyCondition := ema100Above200 and high[1] < smoothingMA and close > high[1] and twoGreenCandles
        sellCondition := ema200Above100 and low[1] > sellsmoothingMA and close < low[1] and twoRedCandles
    else
        buyCondition := ema100Above200 and high[1] < smoothingMA and close > high[1] 
        sellCondition := ema200Above100 and low[1] > sellsmoothingMA and close < low[1]
else
    if twoCandles
        buyCondition := high[1] < smoothingMA and close > high[1] and twoGreenCandles
        sellCondition := low[1] > sellsmoothingMA and close < low[1] and twoRedCandles
    else
        buyCondition := high[1] < smoothingMA and close > high[1] 
        sellCondition := low[1] > sellsmoothingMA and close < low[1]



//plotshape(series=buyCondition, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.triangleup, text="B")
barcolor(sellCondition ? color.new(#000000, 0) : na, title="Sell Alert Candle Color")

barcolor(buyCondition ? color.new(#f7ff13, 0) : na, title="Buy Alert Candle Color")

//plotshape(series=sellCondition, title="Sell Signal", location=location.abovebar, color=color.red, style=shape.triangledown, text="S")

firstBuyAlertCondition = firstBuyAlert and buyCondition
firstSellAlertCondition = firstSellAlert and sellCondition

if buyCondition
    firstBuyAlert := false
if sellCondition
    firstSellAlert := false


// Create alert conditions
alertcondition(firstBuyAlertCondition, title="9EMA First Buy Alert", message="9 EMA First Buy Setup.")

alertcondition(firstSellAlertCondition, title="9EMA First Sell Alert", message="9 EMA First Sell Setup.")



// Create alert conditions
alertcondition(buyCondition, title="9EMA Buy Alert", message="9 EMA Buy Setup.")

alertcondition(sellCondition, title="9EMA Sell Alert", message="9 EMA Sell Setup.")




// Pause candle code

// Define green and red candles
greenCandle = close > open
redCandle = close < open

pattern = 
     greenCandle[3] and      // 2 candles ago: Green
     greenCandle[2] and      // 1 candle ago: Green
     redCandle[1] and        // Current candle: Red
     greenCandle[0] and      // Next candle (shifted back): Green
     close[0] > high[1]      // Next candle closes above red candle's high

// Shift detection back by 1 candle since we're checking future close
detectPattern = pattern[0] 
// if detectPattern
//     label.new(bar_index, high, "B", style=label.style_label_down, yloc=yloc.abovebar, color=color.green, textcolor=color.white)
// Highlight the red candle (3rd in pattern) when the next candle confirms
//bgcolor(detectPattern ? color.new(color.green, 85) : na, title="Pattern Background")

// Optional: Mark the 4th candle (green above red) with an arrow
// plotshape(detectPattern and greenCandle[0], 
//      style=shape.triangleup, 
//      location=location.belowbar, 
//      color=color.green, 
//      size=size.small, 
//      title="Bullish Confirmation")
alertcondition( condition = detectPattern, title = "Pause candle Buy", message = "Bullish reversal pattern detected on {{ticker}} (Time: {{time}})" )     


patternBearish = 
     redCandle[3] and         // 2 candles ago: Red
     redCandle[2] and         // 1 candle ago: Red
     greenCandle[1] and       // Current candle: Green
     redCandle[0] and         // Next candle (shifted back): Red
     close[0] < low[1]        // Next candle closes below green candle's low

// Shift detection back by 1 candle (since we check future close)
detectPatternRed = patternBearish[0] 
// Highlight the green candle (3rd in pattern) when confirmed
//bgcolor(detectPatternRed ? color.new(color.red, 85) : na, title="Pattern Background")
redbg = ema100 < ema200 and showBG
greebg = ema100 > ema200 and showBG
bgcolor(redbg ? color.new(color.red, 85) : na, title="Pattern Background")
bgcolor(greebg ? color.new(color.green, 85) : na, title="Pattern Background")


// Mark the 4th candle (red below low) with a down arrow
// plotshape(detectPatternRed and redCandle[0], 
//           style=shape.triangledown, 
//           location=location.abovebar, 
//           yloc=yloc.abovebar,
//           color=color.red, 
//           size=size.small, 
//           title="Bearish Confirmation")

buyCondition200ema = high[1] < smoothingMA and close > high[1]  
sellCondition200ema = low[1] > sellsmoothingMA and close < low[1]  


//greebg and
//and redbg

alertconditionbuy200 = buyCondition200ema and close < ema200  
alertconditionsell200 = sellCondition200ema and close > ema200  

BuyConditionWith200EMA = buyCondition and close < ema200
SellConditionWith200EMA = sellCondition and close > ema200

alertcondition(BuyConditionWith200EMA, title="9EMA Buy below 200", message="Below 200 EMA BUY")
alertcondition(SellConditionWith200EMA, title="9EMA Sell above 200", message="Above 200 EMA SELL")


// Alert when pattern completes
alertcondition( condition = detectPatternRed, title = "pause candle sell", message = "Bearish continuation pattern detected on {{ticker}} (Time: {{time}})" )
// if detectPatternRed
//     label.new(bar_index, high, "S", style=label.style_label_down, yloc=yloc.abovebar, color=color.red, textcolor=color.white)


alertcondition(goldenCross, title="Golden Cross (EMA 100 > EMA 200)", message="EMA 100 crossed above EMA 200")
alertcondition(deathCross, title="Death Cross (EMA 100 < EMA 200)", message="EMA 100 crossed below EMA 200")
````
