# NDX VPA Sniper (Breakout, Trap, Exhaustion)

- url: https://www.tradingview.com/script/qAVYUhyb-NDX-VPA-Sniper-Breakout-Trap-Exhaustion/
- type: indicator
- pine_id: PUB;1f6bfe20075248fc97984d027c38624c
- version: 1.0

## Description

I create this script using the fundamental analysis of the book 'A Complete Guide to Volume Price Analysis' by Anna Coulling.

It's not meant as a standalone indicator, but to be used along with your current favorite indicators to add an extra level of reassurance before clicking any buttons and potentially getting on the wrong side of a trade.

## Source Code

````pine
//@version=6
indicator("NDX VPA Sniper (Breakout, Trap, Exhaustion)", overlay=true)

// === INPUTS ===
volLength     = input.int(20, "Volume MA Length")
volMultiplier = input.float(2.5, "High Volume Multiplier (NDX tuned)")
lookback      = input.int(30, "Key Level Lookback (NDX tuned)")

useTrendFilter = input.bool(true, "Use EMA Trend Filter")

// === VOLUME ===
volMA  = ta.sma(volume, volLength)
highVol = volume > volMA * volMultiplier

// === TREND FILTER ===
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

bullTrend = ema9 > ema21
bearTrend = ema9 < ema21

// === LEVELS ===
highestLevel = ta.highest(high, lookback)
lowestLevel  = ta.lowest(low, lookback)

// === BREAKOUTS (Filtered) ===
bullBreakout = close > highestLevel[1] and volume > volMA and (useTrendFilter ? bullTrend : true)
bearBreakout = close < lowestLevel[1] and volume > volMA and (useTrendFilter ? bearTrend : true)

// === TRAPS (Stronger Logic for NDX) ===
bullTrap = high > highestLevel[1] and close < highestLevel[1] and highVol and (useTrendFilter ? not bullTrend : true)
bearTrap = low < lowestLevel[1] and close > lowestLevel[1] and highVol and (useTrendFilter ? not bearTrend : true)

// === EXHAUSTION ===
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
bodySize  = math.abs(close - open)

exhaustion = highVol and (
     upperWick > bodySize or 
     lowerWick > bodySize
)

// === VISUALS ===

// EMA Trend
plot(ema9,  color=color.blue, title="EMA 9")
plot(ema21, color=color.orange, title="EMA 21")

// Signals
plotshape(bullBreakout, title="Bull Breakout", location=location.belowbar,
     color=color.green, style=shape.triangleup, size=size.small)

plotshape(bearBreakout, title="Bear Breakout", location=location.abovebar,
     color=color.red, style=shape.triangledown, size=size.small)

plotshape(bullTrap, title="Bull Trap", location=location.abovebar,
     color=color.orange, style=shape.xcross, size=size.small)

plotshape(bearTrap, title="Bear Trap", location=location.belowbar,
     color=color.orange, style=shape.xcross, size=size.small)

plotshape(exhaustion, title="Exhaustion", location=location.top,
     color=color.yellow, style=shape.circle, size=size.tiny)

// === OPTIONAL: BAR COLOR FOR VOLUME ===
barcolor(volume > volMA ? color.new(color.green, 70) : color.new(color.red, 80))

// === ALERTS ===
alertcondition(bullBreakout, title="Bullish Breakout", message="NDX Bullish breakout with volume")
alertcondition(bearBreakout, title="Bearish Breakout", message="NDX Bearish breakout with volume")

alertcondition(bullTrap, title="Bull Trap", message="NDX Bull trap (reversal down)")
alertcondition(bearTrap, title="Bear Trap", message="NDX Bear trap (reversal up)")

alertcondition(exhaustion, title="Exhaustion", message="NDX Possible exhaustion move")
````
