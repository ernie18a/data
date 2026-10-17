# AI UltraTrend X Pro V1

- url: https://www.tradingview.com/script/JWLN9X3s-AI-UltraTrend-X-Pro-V1/
- type: indicator
- pine_id: PUB;c9d6162be7c94b18a09cf8b26c5038a6
- version: 3.0

## Description

The AI UltraTrend X Pro V1 is a high-performance, signal-based indicator engineered to identify explosive trend reversals while aggressively filtering out sideways market noise. Built specifically to handle high-volatility environments like BankNifty, this tool excels at capturing large point moves by combining institutional flow tracking with advanced price-action breakouts.

Key Features

Multi-Segment Mastery: While optimized for the fast-paced nature of BankNifty, the logic is universally applicable across Equity, Forex, Commodities, and Crypto.

Optimized for 3m+ Timeframes: Designed for the 3-minute duration and above, providing a perfect balance between early entries and noise reduction.

Hybrid Execution Logic: Unlike standard indicators that rely solely on crossovers, this script uses a dual-trigger system—line crosses and volatility-backed breakouts—ensuring you never miss a gap-up or a sudden trend explosion.

Intraday & Swing Flexibility: Seamlessly transitions between aggressive Intraday scalping and Positional trend following. The indicator maintains its state, allowing users to carry trades or square off at the end of the session based on their own risk profile.

Advanced Anti-Chop Shield: Features a built-in Volume & Volatility filter that identifies "dead zones" (gray signal areas) to prevent the "multiple entries/exits" common in flat markets.

Dynamic Trailing Stop-Loss: Plots a real-time, ATR-based trailing exit (Yellow Line) that locks in profits while giving the trend enough "breathing room" to survive minor pullbacks.

How to Use

Enter CE: Triggered when the signal turns Green and price breaks recent resistance.

Enter PE: Triggered when the signal turns Red and price breaks recent support.

Stay with the Trend: The background remains color-coded (Green/Red) as long as the trend is healthy.

Exit: Close your position when the signal label flips. 

Best Settings

Timeframe: 3m, 5m, or 15m.

Chart: Works best on standard Candlesticks or Heikin Ashi for smoother trend following.

## Source Code

````pine
//@version=5
indicator("AI UltraTrend X Pro V1", overlay=true)


// ===== Persistent State =====
var int tradeState = 0
var float trailPrice = na
var int lastTradeBar = na

canTrade = na(lastTradeBar) 
// ===== Inputs =====
signalLength = input.int(200, "Signal Sensitivity")
trendLength  = input.int(500, "Major Trend Filter")
atrMult      = input.float(30.0, "Trailing Stop Distance")
volLookback  = input.int(200, "Breakout Lookback")

trendStrengthThresh = input.float(10.5, "Trend Strength (ATR Multiplier)")
noTradeATR          = input.float(10.8, "No Trade Zone (ATR)")
candleATR           = input.float(10.7, "Candle Strength (ATR)")
cooldownBars        = input.int(100, "Cooldown Bars")
src = hl2

smoothSrc = ta.wma(200 * ta.wma(src, signalLength / 200) - ta.wma(src, signalLength), math.round(math.sqrt(signalLength)))

emaTrend = ta.ema(close, trendLength)

// ===== Entry Conditions =====
longCondition =smoothSrc > emaTrend and high > ta.highest(high[1], volLookback) 


plotshape(longCondition  ? low : na,
     title="ENTER CE",
     text="ENTER\nCE",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small)
````
