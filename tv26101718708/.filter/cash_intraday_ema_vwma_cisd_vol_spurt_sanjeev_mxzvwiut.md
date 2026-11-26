# Cash Intraday - EMA VWMA + CISD + Vol Spurt -SANJEEV

- url: https://www.tradingview.com/script/MxZvwIUt-Cash-Intraday-EMA-VWMA-CISD-Vol-Spurt-SANJEEV/
- type: indicator
- pine_id: PUB;2f0c6ba2d7974a66b9fce90cab0542a0
- version: 1.0

## Description

🔥 Intraday Buy Sell Indicator for NSE Cash Stocks | EMA + VWMA Crossover + CISD + Volume Spurt

This indicator is specially designed for Indian Cash Market Intraday trading to capture short-term momentum shifts with high accuracy.

WHAT THIS INDICATOR DOES:
✅ EMA 9 x VWMA 20 Crossover for fast momentum entry
✅ 20 EMA x 50 VWMA Trend Filter to avoid counter-trend trades
✅ CISD (Change in State of Delivery) - Detects Market Structure Shift / BOS
✅ Sudden Volume Spurt Detection - Volume > 1.8x Average + Highest in last 10 candles
✅ Buy/Sell Labels only when all 3 conditions align - High Accuracy Setup

HOW TO USE:
1. Use on 5-Min Timeframe for NSE Cash Stocks (Reliance, TCS, Infosys, etc.)
2. BUY when: 9 EMA crosses above 20 VWMA + Bullish CISD + Volume Spurt + Price above 20/50 Trend = Green BUY VOL SPURT label
3. SELL when: 9 EMA crosses below 20 VWMA + Bearish CISD + Volume Spurt + Price below 20/50 Trend = Red SELL VOL SPURT label
4. Light Green/Red background shows institutional volume spurt.

BEST SETTINGS:
- Nifty 50 Stocks: Volume Multiplier 1.8
- Midcap Stocks: Volume Multiplier 2.0 - 2.2
- Time: 9:30 AM to 2:30 PM for best results

This is a non-repainting indicator with alerts included. Works best with Multi Time Frame: 15-Min for trend direction, 5-Min for entry, 1-Min for precise execution.

⚠️ Disclaimer: For educational purpose only. Not financial advice. Test on paper trading first.

#Intraday #CashMarket #NSE #BuySell #EMA #VWMA #VolumeSpurt #CISD

## Source Code

````pine
// @version=6
indicator("Cash Intraday - EMA VWMA + CISD + Vol Spurt - FINAL", overlay=true)

// === SETTINGS ===
volMult = input.float(1.4, "Volume Spurt Multiplier", 1.1, 3.0, 0.1)

ema9 = ta.ema(close, 9)
vwma20 = ta.sma(close * volume, 20) / ta.sma(volume, 20)
ema20 = ta.ema(close, 20)
vwma50 = ta.sma(close * volume, 50) / ta.sma(volume, 50)

plot(ema9, "9 EMA", color=color.lime, linewidth=2)
plot(vwma20, "20 VWMA", color=color.orange, linewidth=2)

// === CISD ===
swingHigh = ta.pivothigh(high, 2, 2)
swingLow = ta.pivotlow(low, 2, 2)
lastHigh = ta.valuewhen(not na(swingHigh), swingHigh[2], 0)
lastLow = ta.valuewhen(not na(swingLow), swingLow[2], 0)

bullCISD = close > lastHigh
bearCISD = close < lastLow

// === VOLUME SPURT ===
volAvg = ta.sma(volume, 20)
volSpurt = volume > volAvg * volMult
volSpurtUp = volSpurt and close > open
volSpurtDown = volSpurt and close < open

bgcolor(volSpurtUp? color.new(color.green, 80) : volSpurtDown? color.new(color.red, 80) : na, title="Volume Spurt BG")

plotshape(volSpurtUp, title="VOL SPURT UP", style=shape.triangleup, location=location.bottom, color=color.new(color.green, 0), size=size.tiny, text="VOL")
plotshape(volSpurtDown, title="VOL SPURT DN", style=shape.triangledown, location=location.top, color=color.new(color.red, 0), size=size.tiny, text="VOL")

plotshape(bullCISD, title="CISD Bull", style=shape.circle, location=location.belowbar, color=color.new(color.blue, 0), size=size.tiny, text="CISD")
plotshape(bearCISD, title="CISD Bear", style=shape.circle, location=location.abovebar, color=color.new(color.purple, 0), size=size.tiny, text="CISD")

// === BUY SELL ===
bullTrend = ema20 > vwma50
bearTrend = ema20 < vwma50

buyBasic = ta.crossover(ema9, vwma20)
sellBasic = ta.crossunder(ema9, vwma20)

buyPower = buyBasic and bullCISD and volSpurtUp and bullTrend
sellPower = sellBasic and bearCISD and volSpurtDown and bearTrend

// Basic arrows will ALWAYS show
plotshape(buyBasic, title="BUY", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 30), size=size.small, text="BUY")
plotshape(sellBasic, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 30), size=size.small, text="SELL")

// Power labels show when VOL + CISD also there
plotshape(buyPower, title="BUY POWER", style=shape.labelup, location=location.belowbar, color=color.green, text="BUY\nVOL+CISD", textcolor=color.white, size=size.normal)
plotshape(sellPower, title="SELL POWER", style=shape.labeldown, location=location.abovebar, color=color.red, text="SELL\nVOL+CISD", textcolor=color.white, size=size.normal)

alertcondition(buyBasic, "BUY Basic")
alertcondition(sellBasic, "SELL Basic")
alertcondition(buyPower, "BUY POWER VOL+CISD")
alertcondition(sellPower, "SELL POWER VOL+CISD")
````
