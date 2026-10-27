# HA Pullback Big Doji Signals

- url: https://www.tradingview.com/script/aU5xheOF-HA-Pullback-Big-Doji-Signals/
- type: indicator
- pine_id: PUB;fc674e05dab24859becd4669f72d3183
- version: 1.0

## Description

The strategy consists of Jooviers Hybrid Super Scalp which tend to look for 2 pullbacks before a high volume Doji, the indicator will tell you when to buy and sell. THis should only be used as aconfirmation as you must know how to do the strategy yourself.

## Source Code

````pine
//@version=6
indicator("HA Pullback Big Doji Signals", overlay=true, max_labels_count=500)

// Inputs
emaLen = input.int(100, "EMA Length")
minPullbacks = input.int(2, "Minimum Pullback Candles", minval=2, maxval=10)

flatTolerance = input.float(5.0, "Flat Wick Tolerance %", minval=0.0, maxval=20.0, step=0.5)

dojiBodyPercent = input.float(30.0, "Max Doji Body % of Candle", minval=5.0, maxval=50.0, step=1.0)
minWickPercent = input.float(25.0, "Minimum Each Wick % of Candle", minval=5.0, maxval=45.0, step=1.0)

useVolumeFilter = input.bool(true, "Require Strong Doji Volume")
volumeLookback = input.int(3, "Volume Must Beat Last X Candles", minval=1, maxval=3)

preferDojiColor = input.bool(false, "Require Doji Color In Trade Direction")

labelAtrOffset = input.float(0.15, "Label Distance From Candle", minval=0.0, maxval=1.0, step=0.05)

// Heikin Ashi data
haTicker = ticker.heikinashi(syminfo.tickerid)

haOpen  = request.security(haTicker, timeframe.period, open)
haHigh  = request.security(haTicker, timeframe.period, high)
haLow   = request.security(haTicker, timeframe.period, low)
haClose = request.security(haTicker, timeframe.period, close)

// EMA bias
ema100 = ta.ema(haClose, emaLen)
plot(ema100, "EMA 100", color=color.orange, linewidth=2)

aboveEma = haClose > ema100
belowEma = haClose < ema100

// HA candle measurements
haBodyTop = math.max(haOpen, haClose)
haBodyBot = math.min(haOpen, haClose)
haBody = math.abs(haClose - haOpen)
haRange = haHigh - haLow
haUpperWick = haHigh - haBodyTop
haLowerWick = haBodyBot - haLow

safeRange = haRange == 0.0 ? syminfo.mintick : haRange

haGreen = haClose > haOpen
haRed = haClose < haOpen

flatAmount = safeRange * (flatTolerance / 100.0)

// Pullbacks
// Buy setup: red pullback candles above EMA with no/tiny top wick
buyPullbackCandle = aboveEma and haRed and haUpperWick <= flatAmount

// Sell setup: green pullback candles below EMA with no/tiny bottom wick
sellPullbackCandle = belowEma and haGreen and haLowerWick <= flatAmount

var int buyPullbackCount = 0
var int sellPullbackCount = 0

buyPullbackCount := buyPullbackCandle ? buyPullbackCount + 1 : 0
sellPullbackCount := sellPullbackCandle ? sellPullbackCount + 1 : 0

buyPullbacksBeforeDoji = buyPullbackCount[1]
sellPullbacksBeforeDoji = sellPullbackCount[1]

// Doji shape
smallBody = haBody <= safeRange * (dojiBodyPercent / 100.0)
longTopWick = haUpperWick >= safeRange * (minWickPercent / 100.0)
longBottomWick = haLowerWick >= safeRange * (minWickPercent / 100.0)

validDoji = smallBody and longTopWick and longBottomWick

// Doji MUST be bigger than the prior pullback candles.
buyDojiBigger =
     buyPullbacksBeforeDoji == 2 ? haRange > math.max(haRange[1], haRange[2]) :
     buyPullbacksBeforeDoji >= 3 ? haRange > math.max(math.max(haRange[1], haRange[2]), haRange[3]) :
     false

sellDojiBigger =
     sellPullbacksBeforeDoji == 2 ? haRange > math.max(haRange[1], haRange[2]) :
     sellPullbacksBeforeDoji >= 3 ? haRange > math.max(math.max(haRange[1], haRange[2]), haRange[3]) :
     false

// Strong volume on the doji
volumeOk =
     not useVolumeFilter ? true :
     volumeLookback == 1 ? volume >= volume[1] :
     volumeLookback == 2 ? volume >= math.max(volume[1], volume[2]) :
     volume >= math.max(math.max(volume[1], volume[2]), volume[3])

// Preferred doji color
buyColorOk = not preferDojiColor or haGreen
sellColorOk = not preferDojiColor or haRed

// Final doji setups
buyDojiSetup =
     aboveEma and
     buyPullbacksBeforeDoji >= minPullbacks and
     validDoji and
     buyDojiBigger and
     volumeOk and
     buyColorOk

sellDojiSetup =
     belowEma and
     sellPullbacksBeforeDoji >= minPullbacks and
     validDoji and
     sellDojiBigger and
     volumeOk and
     sellColorOk

// Label positions
atr = ta.atr(14)

buyDojiLabelPrice = haLow - atr * labelAtrOffset
sellDojiLabelPrice = haHigh + atr * labelAtrOffset

// Only doji labels
if buyDojiSetup
    label.new(
         bar_index,
         buyDojiLabelPrice,
         "BUY\nDOJI",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal
    )

if sellDojiSetup
    label.new(
         bar_index,
         sellDojiLabelPrice,
         "SELL\nDOJI",
         style=label.style_label_down,
         color=color.maroon,
         textcolor=color.white,
         size=size.normal
    )

// Alerts
alertcondition(buyDojiSetup, "BUY DOJI Setup", "BUY DOJI setup candle on {{ticker}}")
alertcondition(sellDojiSetup, "SELL DOJI Setup", "SELL DOJI setup candle on {{ticker}}")
````
