# The Reach Back By New Heightz

- url: https://www.tradingview.com/script/vR1huSdN-The-Reach-Back-By-New-Heightz/
- type: indicator
- pine_id: PUB;8a99c7aba6c64937a5035dda0f344ed7
- version: 1.0

## Description

.The Reach Back By New Heightz.

The Reach Back By New Heightz is a research-focused trading indicator built around the RZM WaveTrend framework and designed to help traders identify potential Reach-Back opportunities after directional price movement.

The indicator combines:

WaveTrend — identifies directional changes, signal crosses, and extreme turns.
WaveTrend Dots — provides visual events that can serve as a cue to begin watching for a potential Reach-Back.
21 EMA — the primary Reach-Back reference used to monitor potential price reactions.
21 EMA Reaction Signals — marks bullish and bearish reactions around the 21 EMA.
50 SMA — provides additional market context and trend reference.
Alerts — optional alerts for WaveTrend dots and 21 EMA reactions.
How the concept is used

The indicator is designed around the idea of waiting rather than chasing.

When a WaveTrend event occurs, the trader can begin watching for price to make its Reach-Back toward the 21 EMA. If price reacts around the EMA, that reaction can then be evaluated alongside the trader's broader RZM structure and confluence.

We don't chase Rocket Ships. We wait for them to land and refuel.

The WaveTrend dots are not buy or sell signals by themselves. They are intended as research and observation tools that help identify moments when a trader may want to begin watching for Reach-Back and RZM confluence.

## Source Code

````pine
//@version=6
indicator("The Reach Back By New Heightz", shorttitle="Reach Back", overlay=true, max_labels_count=500)

//====================================================
// WAVETREND
//====================================================
groupWT = "WaveTrend"

channelLen = input.int(10, "Channel Length", minval=1, group=groupWT)
averageLen = input.int(21, "Average Length", minval=1, group=groupWT)
signalLen = input.int(4, "Signal Length", minval=1, group=groupWT)
obLevel = input.float(53.0, "Overbought", group=groupWT)
osLevel = input.float(-53.0, "Oversold", group=groupWT)

//====================================================
// WAVETREND DOTS
//====================================================
groupDot = "WaveTrend Dots"

showDots = input.bool(true, "Show Dots", group=groupDot)
dotMode = input.string("Direction Change", "Dot Event",
     options=["Direction Change", "Signal Cross", "Extreme Turn"], group=groupDot)

//====================================================
// REACH-BACK
//====================================================
groupEMA = "Reach-Back"

showEMA = input.bool(true, "Show 21 EMA", group=groupEMA)
emaLen = input.int(21, "EMA Length", minval=1, group=groupEMA)
showEMAReaction = input.bool(true, "Mark 21 EMA Reaction", group=groupEMA)
emaTolerance = input.float(0.10, "EMA Touch Tolerance %", minval=0.0, step=0.05, group=groupEMA)

//====================================================
// 50 SMA
//====================================================
groupSMA = "50 SMA"

showSMA = input.bool(true, "Show 50 SMA", group=groupSMA)
smaLen = input.int(50, "SMA Length", minval=1, group=groupSMA)

sma50 = ta.sma(close, smaLen)
plot(showSMA ? sma50 : na, "50 SMA", color=color.blue, linewidth=2)

//====================================================
// ALERTS
//====================================================
groupAlert = "Alerts"

enableDotAlerts = input.bool(true, "Enable WaveTrend Dot Alerts", group=groupAlert)
enableEMAAlerts = input.bool(true, "Enable 21 EMA Reach-Back Alerts", group=groupAlert)

//====================================================
// WAVETREND CALCULATION
//====================================================
ap = hlc3
esa = ta.ema(ap, channelLen)
de = ta.ema(math.abs(ap - esa), channelLen)
ci = de != 0 ? (ap - esa) / (0.015 * de) : 0.0

wt1 = ta.ema(ci, averageLen)
wt2 = ta.sma(wt1, signalLen)

wtRising = wt1 > wt1[1]
wtFalling = wt1 < wt1[1]

directionChangeBull = wtRising and not wtRising[1]
directionChangeBear = wtFalling and not wtFalling[1]

signalCrossBull = ta.crossover(wt1, wt2)
signalCrossBear = ta.crossunder(wt1, wt2)

extremeTurnBull = wt1[1] <= osLevel and wtRising
extremeTurnBear = wt1[1] >= obLevel and wtFalling

bullDot = switch dotMode
    "Direction Change" => directionChangeBull
    "Signal Cross" => signalCrossBull
    => extremeTurnBull

bearDot = switch dotMode
    "Direction Change" => directionChangeBear
    "Signal Cross" => signalCrossBear
    => extremeTurnBear

//====================================================
// 21 EMA
//====================================================
ema21 = ta.ema(close, emaLen)

plot(showEMA ? ema21 : na, "Reach-Back EMA", color=color.orange, linewidth=2)

//====================================================
// WAVETREND DOTS — SAME AS RZM WT SOURCE
//====================================================
plotshape(showDots and bullDot,
     title="Bullish WaveTrend Dot",
     style=shape.circle,
     location=location.belowbar,
     size=size.tiny,
     color=color.lime)

plotshape(showDots and bearDot,
     title="Bearish WaveTrend Dot",
     style=shape.circle,
     location=location.abovebar,
     size=size.tiny,
     color=color.red)

//====================================================
// 21 EMA REACTION — SAME AS RZM WT SOURCE
//====================================================
emaToleranceValue = ema21 * emaTolerance / 100.0

emaTouched = low <= ema21 + emaToleranceValue and high >= ema21 - emaToleranceValue

emaBullReaction = emaTouched and close > ema21 and close >= open
emaBearReaction = emaTouched and close < ema21 and close <= open

plotshape(showEMAReaction and emaBullReaction,
     title="Bullish 21 EMA Reaction",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.tiny,
     color=color.aqua)

plotshape(showEMAReaction and emaBearReaction,
     title="Bearish 21 EMA Reaction",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.tiny,
     color=color.fuchsia)

//====================================================
// ALERTS — SAME AS RZM WT SOURCE
//====================================================
alertcondition(enableDotAlerts and bullDot,
     "WAVE DOT — BULLISH",
     "RZM WAVE DOT — BULLISH: Start watching for Reach-Back and RZM confluence. NOT a buy signal.")

alertcondition(enableDotAlerts and bearDot,
     "WAVE DOT — BEARISH",
     "RZM WAVE DOT — BEARISH: Start watching for Reach-Back and RZM confluence. NOT a sell signal.")

alertcondition(enableDotAlerts and (bullDot or bearDot),
     "WAVE DOT — ANY",
     "RZM WAVE DOT: WaveTrend event detected. Start watching for Reach-Back and RZM confluence.")

alertcondition(enableEMAAlerts and emaBullReaction,
     "21 EMA — BULLISH REACTION",
     "RZM 21 EMA: Bullish reaction at the Reach-Back EMA. Check full RZM confluence.")

alertcondition(enableEMAAlerts and emaBearReaction,
     "21 EMA — BEARISH REACTION",
     "RZM 21 EMA: Bearish reaction at the Reach-Back EMA. Check full RZM confluence.")

alertcondition(
     (enableDotAlerts and (bullDot or bearDot)) or
     (enableEMAAlerts and (emaBullReaction or emaBearReaction)),
     "RZM WAVE + EMA — ANY",
     "RZM RESEARCH EVENT: WaveTrend dot or 21 EMA reaction detected. Check Reach-Back and RZM confluence.")

//====================================================
// DATA WINDOW
//====================================================
plot(wt1, "WT1", display=display.data_window)
plot(wt2, "WT2", display=display.data_window)
plot(obLevel, "WT Overbought", display=display.data_window)
plot(osLevel, "WT Oversold", display=display.data_window)
````
