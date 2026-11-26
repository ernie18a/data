# Exhaustion Velocity v6

- url: https://www.tradingview.com/script/3m9pbIhh-Exhaustion-Velocity-v6/
- type: indicator
- pine_id: PUB;b778135349d5492f97396ddbf38d9047
- version: 1.0

## Description

EXHAUSTION VELOCITY v6

WHAT IT DOES

This indicator marks moments where a fast directional move appears to be running out of participants. It does not attempt to predict tops or bottoms ahead of time. It waits for the specific bar where speed, volume and acceleration all point toward a climax rather than a continuation.

THE MEASUREMENTS

Velocity is the price change over a lookback window, normalized by ATR so that moves in quiet conditions and moves in violent conditions are scored on the same scale.

The velocity z score expresses how unusual the current speed is relative to the last sixty bars. A reading near 2 means price is travelling roughly two standard deviations faster than it typically does.

Volume surge compares current volume to its own moving average. Climax bars usually arrive on a flood of volume. Occasionally they arrive on volume vanishing instead, which is why the volume test accepts either a spike or a sharp drop.

Acceleration is the change in velocity from bar to bar. While new participants keep entering, velocity keeps rising. When acceleration flips sign, the flow driving the move has stopped even though price may still be extended.

HOW SIGNALS FIRE

Four independent paths can produce a signal.

Standard climax. Extreme velocity, a qualifying volume condition, and an acceleration flip within a short window of the extreme.

Hard climax. Velocity far beyond the threshold on heavy volume, printed without waiting for the flip, because these bars frequently reverse within the bar itself.

Wick rejection. Extreme velocity combined with a long tail in the direction of the move and a close in the opposite half of the bar range.

Velocity divergence. Price makes a fresh low or high while velocity into that extreme is weaker than it was at the previous one, and the bar closes against the move. This catches second leg exhaustion where the final push arrives with less force than the one before it.

FILTERS

Adaptive threshold. The trigger level can float at a percentile of recent velocity readings rather than sitting at a fixed number, so it tightens automatically in high volatility regimes and loosens in compressed ones.

Stretch requirement. Price must sit a minimum ATR distance from a baseline moving average, which prevents signals in the middle of a range where there is nothing meaningful to revert toward.

Cooldown. A minimum bar spacing between signals so that a messy climax produces one entry instead of a cluster.

READING THE LABELS

Each signal counts how many conditions confirmed it. A plain B or S met one. B plus or S plus met two. B plus plus or S plus plus met three or more, meaning heavy volume, a rejection wick, a divergence and extreme magnitude arrived together. Those are the least frequent and the most selective.

A classic mode toggle is included, which reverts the logic to the original strict rule set so you can compare the additional paths against the baseline on the same chart.

SETTINGS GUIDANCE

If signals feel too frequent for your instrument or timeframe, increase the stretch requirement first, then raise the adaptive percentile, then extend the cooldown. If they feel too rare, lower the percentile and shorten the stretch requirement.

DISCLAIMER

This script is published for educational and informational purposes only. It is not financial advice, investment advice, trading advice, or a recommendation to buy or sell any asset.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
indicator("Exhaustion Velocity v6", overlay = true, max_labels_count = 500)

// ── core inputs
src      = input.source(close, "Source")
lenROC   = input.int(9,     "Velocity Lookback")
lenZ     = input.int(60,    "Z-Score Window")
lenVol   = input.int(20,    "Volume Surge Window")
zThresh  = input.float(2.0, "Climax Z Threshold", step = 0.1)
volMult  = input.float(1.6, "Volume Surge Mult",  step = 0.1)
classic  = input.bool(false,"Classic strict mode (v5 logic)")

// ── extremes
useATR   = input.bool(true, "ATR-normalize velocity",   group = "Extremes")
useAdapt = input.bool(true, "Adaptive Z threshold",     group = "Extremes")
pctIn    = input.float(95,  "Adaptive percentile", minval = 50, maxval = 99.9, step = 0.5, group = "Extremes")
flipWin  = input.int(3,     "Accel flip window (bars)", minval = 0, group = "Extremes")
hardMult = input.float(1.5, "Hard-climax mult",   step = 0.1,  group = "Extremes")
dryMult  = input.float(0.65,"Volume dry-up mult", step = 0.05, group = "Extremes")
wickPct  = input.float(0.45,"Wick rejection ratio", step = 0.05, group = "Extremes")
useDiv   = input.bool(true, "Velocity divergence path", group = "Extremes")
divLen   = input.int(20,    "Divergence lookback", group = "Extremes")

// ── filters
useStr   = input.bool(true, "Require stretch from baseline", group = "Filters")
strLen   = input.int(50,    "Baseline EMA length", group = "Filters")
strATR   = input.float(1.5, "Stretch (ATR)", step = 0.1, group = "Filters")
coolBars = input.int(5,     "Cooldown bars", minval = 0, group = "Filters")
tint     = input.bool(true, "Tint extreme bars", group = "Filters")

// ── series (all ta.* hoisted: v6 short-circuits and/or)
atrV     = ta.atr(14)
den      = useATR ? (nz(atrV) <= 0 ? 1.0 : atrV) : 1.0
roc      = (src - src[lenROC]) / den
mu       = ta.sma(roc, lenZ)
sd       = ta.stdev(roc, lenZ)
zRoc     = nz(sd) == 0 ? 0.0 : (roc - mu) / sd
zAbs     = math.abs(zRoc)
zPct     = ta.percentile_linear_interpolation(zAbs, lenZ * 3, pctIn)
zDyn     = classic ? zThresh : useAdapt ? math.max(zThresh * 0.7, nz(zPct, zThresh)) : zThresh

volAvg   = ta.sma(volume, lenVol)
volSurge = nz(volAvg) <= 0 ? 1.0 : volume / volAvg
evs      = zRoc * volSurge

accel    = roc - roc[1]
turnUp   = accel > 0 and accel[1] <= 0
turnDn   = accel < 0 and accel[1] >= 0

zLowW    = ta.lowest(zRoc,  flipWin + 1)
zHighW   = ta.highest(zRoc, flipWin + 1)
zLoDiv   = ta.lowest(zRoc,  divLen)[1]
zHiDiv   = ta.highest(zRoc, divLen)[1]
loDiv    = ta.lowest(low,   divLen)
hiDiv    = ta.highest(high, divLen)
base     = ta.ema(close, strLen)

rng      = high - low
lowWick  = rng <= 0 ? 0.0 : (math.min(open, close) - low) / rng
upWick   = rng <= 0 ? 0.0 : (high - math.max(open, close)) / rng
clv      = rng <= 0 ? 0.5 : (close - low) / rng
volOK    = volSurge >= volMult or volSurge <= dryMult
strDn    = not useStr or (base - close) >= strATR * atrV
strUp    = not useStr or (close - base) >= strATR * atrV

divBull  = useDiv and low  <= loDiv and zRoc > nz(zLoDiv, 0) and zRoc <= -zDyn * 0.6 and close > open
divBear  = useDiv and high >= hiDiv and zRoc < nz(zHiDiv, 0) and zRoc >=  zDyn * 0.6 and close < open

// ── trigger paths
b1 = zLowW  <= -zDyn and volOK and turnUp
b2 = zRoc   <= -zDyn * hardMult and volSurge >= volMult
b3 = zLowW  <= -zDyn and lowWick >= wickPct and clv >= 0.5
s1 = zHighW >=  zDyn and volOK and turnDn
s2 = zRoc   >=  zDyn * hardMult and volSurge >= volMult
s3 = zHighW >=  zDyn and upWick >= wickPct and clv <= 0.5

cB = zRoc <= -zThresh and volSurge >= volMult and accel > 0 and accel[1] <= 0
cS = zRoc >=  zThresh and volSurge >= volMult and accel < 0 and accel[1] >= 0

rawB = classic ? cB : (b1 or b2 or b3 or divBull) and strDn
rawS = classic ? cS : (s1 or s2 or s3 or divBear) and strUp

// ── cooldown dedupe
var int lastB = -10000
var int lastS = -10000
buySig  = rawB and bar_index - lastB > coolBars
sellSig = rawS and bar_index - lastS > coolBars
lastB  := buySig  ? bar_index : lastB
lastS  := sellSig ? bar_index : lastS

// ── confluence tier
scB = (volSurge >= volMult ? 1 : 0) + (lowWick >= wickPct ? 1 : 0) + (divBull ? 1 : 0) + (zRoc <= -zDyn * hardMult ? 1 : 0)
scS = (volSurge >= volMult ? 1 : 0) + (upWick  >= wickPct ? 1 : 0) + (divBear ? 1 : 0) + (zRoc >=  zDyn * hardMult ? 1 : 0)
txB = scB >= 3 ? "B++" : scB == 2 ? "B+" : "B"
txS = scS >= 3 ? "S++" : scS == 2 ? "S+" : "S"

if buySig
    label.new(bar_index, low, txB, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.black, size = size.small)
alert("EVS BUY " + txB + "  z=" + str.tostring(zRoc, "#.##") + "  vol=" + str.tostring(volSurge, "#.##"), alert.freq_once_per_bar_close)

if sellSig
    label.new(bar_index, high, txS, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.black, size = size.small)
alert("EVS SELL " + txS + "  z=" + str.tostring(zRoc, "#.##") + "  vol=" + str.tostring(volSurge, "#.##"), alert.freq_once_per_bar_close)

bgcolor(tint and zRoc <= -zDyn ? color.new(color.lime, 88) : tint and zRoc >= zDyn ? color.new(color.red, 88) : na)

alertcondition(buySig,  "Buy Climax",  "EVS Buy — fear exhaustion")
alertcondition(sellSig, "Sell Climax", "EVS Sell — greed exhaustion")
````
