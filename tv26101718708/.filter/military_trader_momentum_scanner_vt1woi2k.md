# Military Trader Momentum Scanner

- url: https://www.tradingview.com/script/VT1woi2k-Military-Trader-Momentum-Scanner/
- type: indicator
- pine_id: PUB;b27bc01ebf0b443cb4bf00706876b31b
- version: 1.0

## Description

Military Trader – Momentum Scanner
Military Trader – Momentum Scanner is a momentum-based intraday trading indicator designed to identify high-probability long setups in stocks exhibiting strong price and volume expansion.
The scanner combines five key elements commonly found in leading momentum stocks:

Price above VWAP – confirms institutional buying strength and intraday trend direction.
9 EMA above 20 EMA – identifies bullish short-term momentum.
Volume spike detection – highlights unusual trading activity and increased market participation.
New intraday high breakout – confirms that buyers are pushing the stock into fresh territory.
Bullish price candle – ensures momentum is actively continuing at the signal bar.

When all conditions align, the indicator plots a green "MOMO" signal below the candle and can trigger an alert, helping traders quickly identify potential breakout opportunities.
How to Use
The Momentum Long signal is best suited for:

Small-cap momentum stocks
Earnings-related movers
Gap-and-go setups
High relative volume stocks
Intraday breakout trading

A typical trade setup occurs when a stock is trending above VWAP, volume rapidly increases, and price breaks to a new high of the day while maintaining bullish EMA alignment.
Trade Opportunity Identification
This indicator helps traders focus on stocks that are demonstrating:
✅ Strong buying pressure
✅ Increasing momentum
✅ Institutional support above VWAP
✅ Expansion in volume
✅ Breakout confirmation
Rather than predicting reversals, the scanner is designed to identify stocks already under accumulation and showing signs of momentum continuation, making it particularly useful for day traders seeking breakout and trend-following opportunities.
Risk Disclaimer
This indicator is a trade scanner and not a standalone trading system. Users should combine signals with proper risk management, position sizing, market context, support/resistance analysis, and volume confirmation before entering any trade.

## Source Code

````pine
//@version=6
indicator("Warrior Trader – Momentum Scanner (v6)", overlay=true)

// === INPUTS ===
emaFastLen     = input.int(9, "Fast EMA")
emaSlowLen     = input.int(20, "Slow EMA")
volLookback    = input.int(20, "Volume Avg Length")
volMultiplier  = input.float(1.5, "Volume Spike Multiplier")

// === MOVING AVERAGES ===
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// === VWAP ===
vwapValue = ta.vwap(hlc3)

// === VOLUME ===
avgVolume   = ta.sma(volume, volLookback)
volumeSpike = volume > avgVolume * volMultiplier

// === INTRADAY HIGH (DAILY RESET, BAR-0 SAFE) ===
barsSinceSessionStartRaw = ta.barssince(ta.change(time("D")) != 0)
barsSinceSessionStart = na(barsSinceSessionStartRaw) ? 0 : barsSinceSessionStartRaw
intradayHigh = ta.highest(high, barsSinceSessionStart + 1)
newHigh = high >= intradayHigh[1]

// === MOMENTUM CONDITIONS ===
aboveVWAP     = close > vwapValue
emaBullish    = emaFast > emaSlow
bullishCandle = close > open

// === WARRIOR TRADER LONG SETUP ===
longSetup = aboveVWAP and emaBullish and volumeSpike and newHigh and bullishCandle

// === PLOTS ===
plot(emaFast, color=color.orange, linewidth=2, title="9 EMA")
plot(emaSlow, color=color.blue, linewidth=2, title="20 EMA")
plot(vwapValue, color=color.purple, linewidth=2, title="VWAP")

plotshape(
    longSetup,
    title="Momentum Long",
    style=shape.triangleup,
    location=location.belowbar,
    size=size.small,
    color=color.lime,
    text="MOMO"
)

// === ALERT ===
alertcondition(
    longSetup,
    title="Warrior Trader Momentum Long",
    message="Warrior Trader Momentum LONG setup detected"
)
````
