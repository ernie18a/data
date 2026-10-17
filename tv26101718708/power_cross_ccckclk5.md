# Power Cross

- url: https://www.tradingview.com/script/cCCKCLK5-Power-Cross/
- type: indicator
- pine_id: PUB;e97030562cdb4efa8cf5ef9db0ff70f9
- version: 1.0

## Description

PowerCross Indicator –  
Dual Momentum Mastery : 
where you can Discover the ultimate confluence engine: PowerCross fuses two independent, high-precision crossover systems into one powerful visual framework to take the probable swing trade.  
1. Classic Power Cross (Price Momentum)
The 20-period EMA aggressively crosses the 50-period SMA, instantly revealing explosive trend shifts. When the fast EMA storms above the slower SMA, a bright green bullish signal fires; when it plunges below, a vivid red bearish alert appears. This classic setup captures powerful directional moves with surgical accuracy.   
2. RSI Momentum Cross (Hidden Strength)
Simultaneously, the 14-period RSI dances across its own 21-period SMA line. A teal bullish arrow signals RSI momentum surging above its average; a purple bearish arrow warns of fading strength below it. This second layer uncovers hidden buying/selling pressure that price action alone often misses.  Both systems operate independently yet complement each other perfectly. Distinct colors, crystal-clear arrows, colored bars, and subtle background highlights let you spot high-conviction setups at a glance — on any timeframe, any market.  Precision. Clarity. Dual-edge advantage.
PowerCross — where price and momentum align for winning trades.

## Source Code

````pine
//@version=6
indicator("Power Cross", shorttitle="PowerCross", overlay=true)

// ── Power Cross (20 EMA × 50 SMA) ─────────────────────────────────────
ema20 = ta.ema(close, 20)
sma50 = ta.sma(close, 50)

// Plot the moving averages
plot(ema20, color=color.blue, title="20 EMA", linewidth=2)
plot(sma50, color=color.orange, title="50 SMA", linewidth=2)

// Detect Power Cross
bullCross = ta.crossover(ema20, sma50)   // 20 EMA crosses above 50 SMA
bearCross = ta.crossunder(ema20, sma50)  // 20 EMA crosses below 50 SMA


// ── RSI Momentum Cross (separate signal - RSI14 × its own 21 SMA) ─────
rsi = ta.rsi(close, 14)
rsiSMA21 = ta.sma(rsi, 21)

bullRSI = ta.crossover(rsi, rsiSMA21)   // RSI crosses above its 21 SMA
bearRSI = ta.crossunder(rsi, rsiSMA21)  // RSI crosses below its 21 SMA


// ── Visual Signals (same style as original Power Cross) ───────────────
// Combined bar coloring - Power Cross has priority, RSI is separate color
barcolor(
     bullCross ? color.green :
     bearCross ? color.red :
     bullRSI   ? color.teal :
     bearRSI   ? color.purple : na,
     title="Crossover Bar Color")

// Power Cross arrows (original green/red)
plotshape(bullCross, title="Bullish Power Cross", location=location.belowbar, 
          color=color.green, style=shape.triangleup, size=size.small)

plotshape(bearCross, title="Bearish Power Cross", location=location.abovebar, 
          color=color.red, style=shape.triangledown, size=size.small)

// RSI Cross arrows (separate teal/purple signals - same exact style)
plotshape(bullRSI, title="Bullish RSI Cross", location=location.belowbar, 
          color=color.teal, style=shape.triangleup, size=size.small)

plotshape(bearRSI, title="Bearish RSI Cross", location=location.abovebar, 
          color=color.purple, style=shape.triangledown, size=size.small)

// Combined subtle background highlight (Power Cross priority)
bgcolor(
     bullCross ? color.new(color.green, 90) :
     bearCross ? color.new(color.red, 90) :
     bullRSI   ? color.new(color.teal, 90) :
     bearRSI   ? color.new(color.purple, 90) : na)
````
