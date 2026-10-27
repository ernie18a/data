# DAX EMA47 PRO Structure System (5M FIXED)

- url: https://www.tradingview.com/script/a18RIDh1-DAX-EMA47-PRO-Structure-System-5M-FIXED/
- type: indicator
- pine_id: PUB;1f7f0b09a9244d178781c6f0c105885b
- version: 1.0

## Description

This system is still:

probability filter, not prediction engine
DAX will still fake signals during:
news spikes
liquidity grabs
EMA chop zones

So your real edge remains:

“Only take signals when market is trending + session active”

## Source Code

````pine
//@version=5
indicator("DAX EMA47 PRO Structure System (5M FIXED)", overlay=true)

//────────────────────────────
// INPUTS
//────────────────────────────
emaFastLen = input.int(47, "EMA 47")
emaHTFLen  = input.int(200, "HTF EMA (15M)")
atrLen     = input.int(14, "ATR Length")
atrFilter  = input.float(1.0, "Min ATR Filter")

sessionLondon = input.session("0700-1100", "London Session")
sessionNY     = input.session("1300-1700", "NY Session")

//────────────────────────────
// CORE CALCULATIONS
//────────────────────────────
ema47 = ta.ema(close, emaFastLen)
emaHTF = request.security(syminfo.tickerid, "15", ta.ema(close, emaHTFLen))
atr = ta.atr(atrLen)

// PLOTS
plot(ema47, color=color.orange, linewidth=2)
plot(emaHTF, color=color.blue, linewidth=2)

//────────────────────────────
// SESSION FILTER
//────────────────────────────
inLondon = not na(time(timeframe.period, sessionLondon))
inNY = not na(time(timeframe.period, sessionNY))
inSession = inLondon or inNY

//────────────────────────────
// TREND FILTER
//────────────────────────────
bullTrend = close > emaHTF
bearTrend = close < emaHTF

//────────────────────────────
// STRUCTURE
//────────────────────────────
higherLow = low > ta.lowest(low, 5)[1]
lowerHigh = high < ta.highest(high, 5)[1]

//────────────────────────────
// EMA STATE
//────────────────────────────
emaRising = ema47 > ema47[1]
emaFalling = ema47 < ema47[1]

//────────────────────────────
// VOLATILITY FILTER
//────────────────────────────
volOk = atr > atrFilter

//────────────────────────────
// REJECTION LOGIC (FIXED STYLE)
//────────────────────────────
bullRejection = (low <= ema47) and (close > ema47) and (close > open)
bearRejection = (high >= ema47) and (close < ema47) and (close < open)

//────────────────────────────
// FINAL SIGNALS (FIXED LINE BREAKS)
//────────────────────────────
longSignal =inSession and volOk and bullTrend and emaRising and bullRejection and higherLow

shortSignal =inSession and volOk and bearTrend and emaFalling and bearRejection and lowerHigh

//────────────────────────────
// PLOTS
//────────────────────────────
plotshape(longSignal, title="GO LONG", location=location.belowbar,
     color=color.lime, style=shape.labelup, text="GO LONG")

plotshape(shortSignal, title="GO SHORT", location=location.abovebar,
     color=color.red, style=shape.labeldown, text="GO SHORT")

//────────────────────────────
// ALERTS
//────────────────────────────
alertcondition(longSignal, title="LONG ALERT", message="DAX PRO SYSTEM LONG")
alertcondition(shortSignal, title="SHORT ALERT", message="DAX PRO SYSTEM SHORT")
````
