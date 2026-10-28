# Volume Spike Smart Scanner

- url: https://www.tradingview.com/script/as375zGL/
- type: indicator
- pine_id: PUB;47dd44ba68104c0386487bf32f307a20
- version: 1.0

## Description

Volume Spike Smart Scanner

This indicator detects high-probability momentum moves by combining multi-timeframe volume spikes with price action confirmation.

It filters out low-liquidity coins and focuses only on assets with strong capital inflow. The script checks:

Daily liquidity (min $3M volume)
15m and 1h volume spikes (relative increase)
Strong 1h absolute volume (real money entering)
Bullish price confirmation (green candle above EMA20)

When all conditions align, it signals potential early-stage momentum moves.

Designed to reduce noise and highlight real buying pressure, not fake spikes.

## Source Code

````pine
//@version=5
indicator("Volume Spike Smart Scanner", overlay=true)

// === INPUTS ===
minDailyVolume = input.float(3000000, "Min Daily Volume ($)")
min1hVolume    = input.float(1000000, "Min 1H Volume ($)")
volMultiplier15m = input.float(1.8, "15m Volume Multiplier")
volMultiplier1h  = input.float(1.5, "1H Volume Multiplier")

// === EMA ===
ema20 = ta.ema(close, 20)

// === 15m DATA ===
vol15m = volume
avgVol15m = ta.sma(volume, 20)

// === 1H DATA ===
vol1h = request.security(syminfo.tickerid, "60", volume)
prevVol1h = request.security(syminfo.tickerid, "60", volume[1])

// === 1D DATA ===
vol1d = request.security(syminfo.tickerid, "D", volume)

// === CONDITIONS ===

// 1. Likidite filtresi
cond_liquidity = vol1d >= minDailyVolume

// 2. 15m spike
cond_15m = vol15m >= avgVol15m * volMultiplier15m

// 3. 1h spike
cond_1h = vol1h >= prevVol1h * volMultiplier1h

// 4. Absolute hacim
cond_abs = vol1h >= min1hVolume

// 5. Fiyat filtresi
cond_price = close > open and close > ema20

// === FINAL SIGNAL ===
signal = cond_liquidity and cond_15m and cond_1h and cond_abs and cond_price

// === PLOT ===
plotshape(signal, title="BUY SIGNAL", location=location.belowbar, 
     color=color.green, style=shape.labelup, text="BUY")

// === ALERT ===
alertcondition(signal, title="Volume Spike Alert", 
     message="Volume Spike + Price Action Signal!")
````
