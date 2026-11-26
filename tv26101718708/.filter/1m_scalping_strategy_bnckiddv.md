# 1M Scalping Strategy

- url: https://www.tradingview.com/script/bncKidDv-1M-Scalping-Strategy/
- type: indicator
- pine_id: PUB;d89550a414dd41b9921a91e36e4486a2
- version: 1.0

## Description

This script is an educational Heikin Ashi and EMA study designed to help traders observe pullback/doji conditions and EMA reclaim behavior.

The script uses Heikin Ashi candle data together with a configurable EMA, defaulted to 100. It is designed mainly for short-term chart review and backtesting, especially on lower timeframes such as the 1-minute chart.

There are two main study conditions included:

1. HA Pullback Watch

The pullback watch condition looks for price location relative to the EMA and a specific Heikin Ashi candle sequence.

For a bullish pullback watch, the script looks for:
- Heikin Ashi price above the EMA
- Two red Heikin Ashi pullback candles
- The pullback candles having little to no upper wick
- A green doji-style Heikin Ashi candle forming after the pullback

For a bearish pullback watch, the script looks for:
- Heikin Ashi price below the EMA
- Two green Heikin Ashi pullback candles
- The pullback candles having little to no lower wick
- A red doji-style Heikin Ashi candle forming after the pullback

These conditions are marked as watch or confirmed conditions depending on whether the candle is still forming or has closed.

2. EMA Reclaim Watch

The EMA reclaim portion of the script looks for price moving from one side of the EMA to the other.

A bullish EMA reclaim condition happens when Heikin Ashi price was recently below the EMA, then pushes back above the EMA with a stronger green candle near the EMA area.

A bearish EMA reclaim condition happens when Heikin Ashi price was recently above the EMA, then pushes back below the EMA with a stronger red candle near the EMA area.

The script includes optional settings for:
- EMA length
- Doji body percentage
- Wick tolerance
- Strong candle body percentage
- EMA reclaim lookback
- EMA touch tolerance
- Volume filter
- Showing or hiding different study markers

The chart markers are intended to help users study possible pullback and EMA reclaim behavior. They are not financial advice, trade recommendations, or guaranteed buy/sell signals. Because the script uses Heikin Ashi data, users should be aware that Heikin Ashi candles are calculated candles and may not represent actual traded prices.

This script should be used for educational study, manual review, and backtesting only. Users should apply their own analysis, risk management, and confirmation before making any trading decisions.

## Source Code

````pine
//@version=6
indicator("HA Pullback and EMA Reclaim Study", overlay=true, max_labels_count=500)

// =====================
// INPUTS
// =====================
emaLength          = input.int(100, "EMA Length")
dojiBodyPercent    = input.float(35.0, "Max Doji Body %", minval=1, maxval=100)
wickToleranceTicks = input.int(1, "Wick Tolerance Ticks", minval=0)

showPullbackSetups = input.bool(true, "Show HA Pullback Watch Setups")
showEMASetups      = input.bool(true, "Show EMA Reclaim Watch Setups")
showConfirmed      = input.bool(true, "Show Confirmed Study Markers")

useVolumeFilter    = input.bool(false, "Use Volume Filter For Confirmed Markers?")
volumeLength       = input.int(20, "Volume MA Length")
volumeMultiplier   = input.float(1.0, "Volume Multiplier", step=0.1)

// EMA reclaim settings
reclaimLookback     = input.int(5, "EMA Reclaim Lookback Bars", minval=1)
strongBodyPercent   = input.float(55.0, "Strong Candle Body %", minval=1, maxval=100)
touchEMATicks       = input.int(10, "Near EMA Tolerance Ticks", minval=0)

// =====================
// HEIKIN ASHI DATA
// =====================
haTicker = ticker.heikinashi(syminfo.tickerid)

haOpen  = request.security(haTicker, timeframe.period, open)
haHigh  = request.security(haTicker, timeframe.period, high)
haLow   = request.security(haTicker, timeframe.period, low)
haClose = request.security(haTicker, timeframe.period, close)
haVol   = request.security(haTicker, timeframe.period, volume)

// =====================
// EMA
// =====================
ema = ta.ema(haClose, emaLength)
plot(ema, "EMA", color=color.orange, linewidth=2)

// =====================
// CANDLE LOGIC
// =====================
tickTol = syminfo.mintick * wickToleranceTicks
emaTol  = syminfo.mintick * touchEMATicks

haBody  = math.abs(haClose - haOpen)
haRange = haHigh - haLow

isGreen = haClose > haOpen
isRed   = haClose < haOpen

bodyPercent = haRange > 0 ? haBody / haRange * 100 : 100
isDoji = bodyPercent <= dojiBodyPercent
isStrongCandle = bodyPercent >= strongBodyPercent

// Red HA candle with no upper wick
noUpperWick = haHigh <= math.max(haOpen, haClose) + tickTol

// Green HA candle with no lower wick
noLowerWick = haLow >= math.min(haOpen, haClose) - tickTol

// Volume filter
volMA = ta.sma(haVol, volumeLength)
highVolume = haVol >= volMA * volumeMultiplier
volumeOK = useVolumeFilter ? highVolume : true

// =====================
// SETUP 1: HA PULLBACK / DOJI STUDY
// =====================

// Bullish watch:
// Above EMA
// 2 red HA pullback candles with no upper wick
// Current candle forms a green doji-style candle

bullPullback1 = isRed[2] and noUpperWick[2]
bullPullback2 = isRed[1] and noUpperWick[1]
bullDojiColor = isGreen
bullDojiShape = isDoji
bullDojiBigger = haRange > math.min(haRange[1], haRange[2])

bullWatch =
     showPullbackSetups and
     haClose > ema and
     bullPullback1 and
     bullPullback2 and
     bullDojiColor and
     bullDojiShape

bullConfirm =
     showConfirmed and
     barstate.isconfirmed and
     haClose > ema and
     bullPullback1 and
     bullPullback2 and
     bullDojiColor and
     bullDojiShape and
     bullDojiBigger and
     volumeOK

// Bearish watch:
// Below EMA
// 2 green HA pullback candles with no lower wick
// Current candle forms a red doji-style candle

bearPullback1 = isGreen[2] and noLowerWick[2]
bearPullback2 = isGreen[1] and noLowerWick[1]
bearDojiColor = isRed
bearDojiShape = isDoji
bearDojiBigger = haRange > math.min(haRange[1], haRange[2])

bearWatch =
     showPullbackSetups and
     haClose < ema and
     bearPullback1 and
     bearPullback2 and
     bearDojiColor and
     bearDojiShape

bearConfirm =
     showConfirmed and
     barstate.isconfirmed and
     haClose < ema and
     bearPullback1 and
     bearPullback2 and
     bearDojiColor and
     bearDojiShape and
     bearDojiBigger and
     volumeOK

// =====================
// SETUP 2: EMA RECLAIM / REJECTION STUDY
// =====================

wasBelowEMA = ta.lowest(haClose - ema, reclaimLookback) < 0
wasAboveEMA = ta.highest(haClose - ema, reclaimLookback) > 0

touchingEMA = haLow <= ema + emaTol and haHigh >= ema - emaTol

emaReclaimUp =
     showEMASetups and
     barstate.isconfirmed and
     wasBelowEMA and
     haClose > ema and
     isGreen and
     isStrongCandle and
     touchingEMA and
     volumeOK

emaReclaimDown =
     showEMASetups and
     barstate.isconfirmed and
     wasAboveEMA and
     haClose < ema and
     isRed and
     isStrongCandle and
     touchingEMA and
     volumeOK

possibleEMAReclaimUp =
     showEMASetups and
     not barstate.isconfirmed and
     wasBelowEMA and
     haClose > ema and
     isGreen and
     touchingEMA

possibleEMAReclaimDown =
     showEMASetups and
     not barstate.isconfirmed and
     wasAboveEMA and
     haClose < ema and
     isRed and
     touchingEMA

// =====================
// CHART MARKERS
// =====================

plotshape(
     bullWatch and not bullConfirm,
     title="Bullish Pullback Watch",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     text="BW",
     textcolor=color.white,
     size=size.small
)

plotshape(
     bearWatch and not bearConfirm,
     title="Bearish Pullback Watch",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     text="SW",
     textcolor=color.white,
     size=size.small
)

plotshape(
     bullConfirm,
     title="Bullish Pullback Confirmed",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="BC",
     textcolor=color.black,
     size=size.small
)

plotshape(
     bearConfirm,
     title="Bearish Pullback Confirmed",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SC",
     textcolor=color.white,
     size=size.small
)

plotshape(
     possibleEMAReclaimUp and not emaReclaimUp,
     title="Possible EMA Reclaim Up",
     style=shape.circle,
     location=location.belowbar,
     color=color.aqua,
     text="ERU?",
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     possibleEMAReclaimDown and not emaReclaimDown,
     title="Possible EMA Reclaim Down",
     style=shape.circle,
     location=location.abovebar,
     color=color.fuchsia,
     text="ERD?",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     emaReclaimUp,
     title="EMA Reclaim Up",
     style=shape.labelup,
     location=location.belowbar,
     color=color.aqua,
     text="ERU",
     textcolor=color.black,
     size=size.small
)

plotshape(
     emaReclaimDown,
     title="EMA Reclaim Down",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.fuchsia,
     text="ERD",
     textcolor=color.white,
     size=size.small
)

// =====================
// ALERT CONDITIONS
// =====================

alertcondition(
     bullWatch,
     title="Bullish Pullback Watch",
     message="Bullish HA pullback watch forming."
)

alertcondition(
     bearWatch,
     title="Bearish Pullback Watch",
     message="Bearish HA pullback watch forming."
)

alertcondition(
     bullConfirm,
     title="Bullish Pullback Confirmed",
     message="Bullish HA pullback study condition confirmed."
)

alertcondition(
     bearConfirm,
     title="Bearish Pullback Confirmed",
     message="Bearish HA pullback study condition confirmed."
)

alertcondition(
     possibleEMAReclaimUp,
     title="Possible EMA Reclaim Up",
     message="Possible EMA reclaim upward condition forming."
)

alertcondition(
     possibleEMAReclaimDown,
     title="Possible EMA Reclaim Down",
     message="Possible EMA reclaim downward condition forming."
)

alertcondition(
     emaReclaimUp,
     title="EMA Reclaim Up Confirmed",
     message="EMA reclaim upward study condition confirmed."
)

alertcondition(
     emaReclaimDown,
     title="EMA Reclaim Down Confirmed",
     message="EMA reclaim downward study condition confirmed."
)

alertcondition(
     bullWatch or bearWatch,
     title="Any Pullback Watch",
     message="HA pullback watch condition forming."
)

alertcondition(
     possibleEMAReclaimUp or possibleEMAReclaimDown,
     title="Any EMA Reclaim Watch",
     message="EMA reclaim watch condition forming."
)

alertcondition(
     bullWatch or bearWatch or possibleEMAReclaimUp or possibleEMAReclaimDown,
     title="Any Watch Condition",
     message="A study watch condition is forming."
)

alertcondition(
     bullConfirm or bearConfirm or emaReclaimUp or emaReclaimDown,
     title="Any Confirmed Condition",
     message="A study condition has confirmed."
)
````
