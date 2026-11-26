# Track n Trail 

- url: https://www.tradingview.com/script/RV7gLXQN-Track-n-Trail/
- type: indicator
- pine_id: PUB;b84fc9f35c234743a87ddb40367e2648
- version: 1.0

## Description

Track n Trail – Multi-Filter Trend Indicator

Track n Trail is a trend-following indicator designed to identify high-probability buy and sell opportunities by combining multiple confirmation tools into a single system.

## Source Code

````pine
//@version=5
indicator("Track n Trail ", overlay=true)

// ===== TOGGLES =====
useATR      = input.bool(true, "Use RT")
useFast     = input.bool(true, "Use Fast trend")
useSlow     = input.bool(true, "Use Slow trend")
useSMA      = input.bool(true, "Use S Length")
useVWAP     = input.bool(true, "Use Line filter")
useEMA      = input.bool(true, "Use E Length")
showSignals = input.bool(true, "Show Buy/Sell Signals")

// ===== FIXED VALUES =====
atrPeriod   = useATR  ? 1   : 10
factorFast  = useFast ? 1.0 : 2.0
factorSlow  = useSlow ? 1.0 : 3.0
smaLength   = 44
emaLength   = 21
emaSource   = close

// ===== ATR =====
atr = ta.atr(atrPeriod)

// ===== SUPERTREND FUNCTION =====
supertrend(factor) =>
    upperband = hl2 + factor * atr
    lowerband = hl2 - factor * atr
    var float finalUpper = na
    var float finalLower = na
    var int trend = 1

    finalUpper := na(finalUpper[1]) ? upperband : (close[1] > finalUpper[1] ? math.max(upperband, finalUpper[1]) : upperband)
    finalLower := na(finalLower[1]) ? lowerband : (close[1] < finalLower[1] ? math.min(lowerband, finalLower[1]) : lowerband)

    trend := close > finalUpper[1] ? 1 : close < finalLower[1] ? -1 : nz(trend[1], 1)

    [trend, finalUpper, finalLower]

// ===== SUPERTRENDS =====
[trendFast, upFast, dnFast] = supertrend(factorFast)
[trendSlow, upSlow, dnSlow] = supertrend(factorSlow)

// ===== SMA =====
smaHigh = ta.sma(high, smaLength)
smaLow  = ta.sma(low, smaLength)

// ===== VWAP =====
vwap = ta.vwap(close)

// ===== EMA =====
emaValue = ta.ema(emaSource, emaLength)

// ===== CONDITIONS =====
smaBuyCond  = useSMA  ? close > smaHigh : true
smaSellCond = useSMA  ? close < smaLow  : true

vwapBuyCond  = useVWAP ? close > vwap : true
vwapSellCond = useVWAP ? close < vwap : true

emaBuyCond  = useEMA ? close > emaValue : true
emaSellCond = useEMA ? close < emaValue : true

// ===== FINAL SIGNAL =====
buy  = trendFast == 1 and trendSlow == 1 and smaBuyCond and vwapBuyCond and emaBuyCond
sell = trendFast == -1 and trendSlow == -1 and smaSellCond and vwapSellCond and emaSellCond

// ===== PLOTS =====
plot(trendFast == 1 ? dnFast : upFast, color=color.green, linewidth=2, title="Fast ST")
plot(trendSlow == 1 ? dnSlow : upSlow, color=color.red, linewidth=2, title="Slow ST")

ph = plot(smaHigh, color=color.blue, linewidth=2, title="SMA High")
pl = plot(smaLow, color=color.orange, linewidth=2, title="SMA Low")
fill(ph, pl, color=color.new(color.blue, 90))

plot(vwap, color=color.yellow, linewidth=2, title="VWAP")
plot(emaValue, color=color.purple, linewidth=2, title="EMA")

// ===== SIGNAL PLOTS (WITH TOGGLE) =====
plotshape(showSignals and buy, location=location.belowbar, color=color.green, style=shape.labelup, text="BUY", size=size.small)
plotshape(showSignals and sell, location=location.abovebar, color=color.red, style=shape.labeldown, text="SELL", size=size.small)
````
