# MES Momentum Detector 2x Vol and Range (Customizable) K8E

- url: https://www.tradingview.com/script/poWTo2r5-MES-Momentum-Detector-2x-Vol-and-Range-Customizable-K8E/
- type: indicator
- pine_id: PUB;6426546b2567493eaf05571e6a52ad8e
- version: 6.0

## Description

MES Momentum Detector 2x Vol and Range (Customizable) K8E

This script has a customizable indicator that will confirm any candle that is more than 2x the average volume or 2x the average point range for that specific time frame you are in. You can label them as you wish but they are bear and bull by default. The Bull will close within the top 20% of the range and the bear will close 20% from the bottom of the range. 

On whatever timeframe you’re on (1m, 2m, 5m, 10m, etc.), it will only show a signal when:

The bull indicator:
current candle range > 2x average range for that same timeframe
current candle volume > 2x average volume for that same timeframe
candle closes in the top 20% of its range

The bear indicator:
current candle range > 2x average range
current candle volume > 2x average volume
candle closes in the bottom 20% of its range

Optional extras included
(Regular Trading Hours) only filter only shows signals during 9:30 AM – 4:00 PM New York time
table showing current values
separate bullish and bearish arrows
adjustable close-to-extreme % if you want stricter/looser momentum bars

## Source Code

````pine
//@version=6
indicator("2x Volume & Range Momentum Candles — 20% Close K8E", overlay=true)

// ===========================
// INPUT
// ===========================
avgLength  = input.int(20, "Average Length", minval=1)
rangeMult  = input.float(2.0, "Range Multiplier")
volumeMult = input.float(2.0, "Volume Multiplier")
closePct   = input.float(20.0, "Close Near Extreme %")

// ===========================
// SESSION CHECKBOXES
// ===========================
useAsia   = input.bool(false, "Include Asia Session (18:00–03:00 NY)")
useLondon = input.bool(false, "Include London Session (03:00–08:00 NY)")
useNY     = input.bool(true,  "Include New York Session (08:00–17:00 NY)")
useAll    = input.bool(false, "Include ALL Hours (override)")

// ===========================
// SESSION DEFINITIONS
// ===========================
inAsia   = not na(time(timeframe.period, "1800-0300"))
inLondon = not na(time(timeframe.period, "0300-0800"))
inNY     = not na(time(timeframe.period, "0800-1700"))

// If ALL is selected → ignore other filters
sessionOK =
     useAll ? true :
     (useAsia and inAsia) or
     (useLondon and inLondon) or
     (useNY and inNY)

// ===========================
// DATA
// ===========================
currRange = high - low
currVol   = volume

avgRange = ta.sma(currRange, avgLength)
avgVol   = ta.sma(currVol, avgLength)

// ===========================
// CONDITIONS
// ===========================
rangeOK = currRange > avgRange * rangeMult
volOK   = currVol > avgVol * volumeMult

safeRange = math.max(high - low, syminfo.mintick)
closePos  = (close - low) / safeRange

bull = sessionOK and rangeOK and volOK and closePos >= 0.8 and close > open
bear = sessionOK and rangeOK and volOK and closePos <= 0.2 and close < open

// ===========================
// STYLE
// ===========================
pink  = color.fuchsia
white = color.white

// ===========================
// PLOTS
// ===========================
plotshape(bull,
     title="Bull",
     style=shape.labelup,
     location=location.belowbar,
     color=pink,
     text="BULL",
     textcolor=white,
     size=size.small)

plotshape(bear,
     title="Bear",
     style=shape.labeldown,
     location=location.abovebar,
     color=pink,
     text="BEAR",
     textcolor=white,
     size=size.small)
````
