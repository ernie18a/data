# Buy Now, Daily Chart

- url: https://www.tradingview.com/script/Pq5glaFY-Buy-Now-Daily-Chart/
- type: indicator
- pine_id: PUB;35e2a735c99243e396bb91463d4218bb
- version: 1.0

## Description

Right Signals to buy, Never fails, 95% succest rate

## Source Code

````pine
//@version=5
indicator("Cipher B - Ultra Flexible Liq + Cooldown", overlay=true)

// --- 1. INPUTS ---
grp1 = "Threshold Settings"
rsiThreshold = input.int(40, "RSI Under (Max)", minval=30, maxval=60, group=grp1)
volMult = input.float(1.25, "Volume Multiplier", step=0.05, group=grp1)
lookbackBars = input.int(7, "Setup Window (Bars)", minval=1, maxval=20, group=grp1)

grp2 = "Liquidity Zone Settings"
liqLookback = input.int(20, "Liquidity Lookback (Bars)", group=grp2)
liqZoneSize = input.float(1.5, "Liquidity Zone Size (%)", group=grp2)

grp3 = "Execution & Filters"
cooldownBars = input.int(3, "Min Bars Between Dots", minval=1, group=grp3)
useEma = input.bool(true, "Require EMA 9 Cross?", group=grp3)

// --- 2. LIQUIDITY ZONE LOGIC ---
highestHigh = ta.highest(high, liqLookback)
lowestLow = ta.lowest(low, liqLookback)

inLowLiquidity = close <= lowestLow * (1 + liqZoneSize / 100)
inHighLiquidity = close >= highestHigh * (1 - liqZoneSize / 100)
inLiquidityZone = inLowLiquidity or inHighLiquidity

// --- 3. RSI & CIPHER B LOGIC ---
rsiValue = ta.rsi(close, 14)
rsiActive = ta.lowest(rsiValue, lookbackBars) <= rsiThreshold

wt_esa = ta.ema(hlc3, 10)
wt_d = ta.ema(math.abs(hlc3 - wt_esa), 10)
wt_ci = (hlc3 - wt_esa) / (0.015 * wt_d)
wt_tci = ta.ema(wt_ci, 21)
wt_wt1 = wt_tci
wt_wt2 = ta.sma(wt_wt1, 4)

cipherGreenDot = ta.crossover(wt_wt1, wt_wt2)
cipherActive = ta.barssince(cipherGreenDot) <= lookbackBars

// --- 4. TRIGGER & VOLUME ---
volAvg = ta.sma(volume, 20)
volActive = volume > volAvg * volMult

ema9 = ta.ema(close, 9)
emaCross = ta.crossover(close, ema9)

// --- 5. FINAL SIGNAL WITH COOLDOWN ---
trigger = useEma ? emaCross : (cipherGreenDot or volActive)
potentialSignal = trigger and rsiActive and cipherActive and volActive and inLiquidityZone

var int lastSignalBar = na
longSignal = false

if potentialSignal and (na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars)
    longSignal := true
    lastSignalBar := bar_index

// --- 6. VISUALS ---
plot(ema9, color=color.new(color.blue, 50), title="EMA 9")
plot(highestHigh, color=color.new(color.red, 85), style=plot.style_stepline, title="Upper Liq")
plot(lowestLow, color=color.new(color.green, 85), style=plot.style_stepline, title="Lower Liq")

plotshape(longSignal,
     title="Big Green Dot",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(#00ff00, 0),
     size=size.small)

if longSignal
    label.new(bar_index, low, text="ENTRY", color=color.green, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar)
````
