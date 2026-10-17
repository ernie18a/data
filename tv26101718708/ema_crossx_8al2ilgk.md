# EMA CrossX

- url: https://www.tradingview.com/script/8al2ILgk-EMA-CrossX/
- type: strategy
- pine_id: PUB;a3dd41f72c6946c49ed5395ac772642c
- version: 1.0

## Description

EMA CrossX is a buy-only trend-following strategy built around a simple but effective dual EMA crossover system. It is designed to catch bullish momentum shifts by entering long positions when the fast EMA crosses above the slow EMA, with optional delayed entries to help filter noise and reduce early false signals.

The strategy includes strict built-in risk controls using fixed stop loss and take profit levels, along with an optional trailing stop mode for traders who prefer to let winners run. It is best suited for short-term momentum trading, scalping, and intraday trend continuation setups.

🔑 FEATURES
[list]
[*]Buy-Only Trend Logic: Focuses only on bullish crossover setups for cleaner directional bias and simpler trade management.
[*]Delayed Entry Filter: Optional candle delay after crossover helps reduce false entries during choppy price action.
[*]Flexible Exit Control: Choose between strict fixed TP/SL or dynamic trailing stop behavior based on market conditions.
[/list]

⚙️ HOW TO USE
[list]
[*]Add the strategy to your chart.
[*]Adjust Fast EMA Length and Slow EMA Length to match your preferred market or timeframe.
[*]Use Entry Delay (Candles) to filter aggressive entries and reduce noise.
[*]Set your preferred Take Profit and Stop Loss point values.
[*]Enable Trailing Stop if you want to ride stronger bullish moves instead of using fixed targets.
[*]A buy signal is generated when the fast EMA crosses above the slow EMA and the selected delay condition is met.
[/list]

⚠️ NOTES & DISCLAIMERS
[list]
[*]This is a buy-only strategy, designed for bullish market conditions and upward momentum environments.
[*]Works best on fast-moving assets and lower timeframes where momentum and continuation matter most.
[*]Users are encouraged to experiment with EMA lengths, delay settings, and risk values to better fit different market conditions and instruments.
[*]Trailing stop mode can help maximize strong moves, while fixed TP mode is better for tighter scalping setups.
[*]Always use proper risk management before deploying on live capital.
[/list]

## Source Code

````pine
//@version=5
strategy("EMA CrossX", overlay=true, initial_capital=1000, default_qty_type=strategy.fixed, default_qty_value=1)

// --- INPUTS ---
fastLen  = input.int(9, "Fast EMA Length")
slowLen  = input.int(19, "Slow EMA Length")
waitBars = input.int(2, "Entry Delay (Candles)", minval=0)

// Strict Risk Inputs
takeProfitPoints = input.float(4.0, "Take Profit (Points)")
stopLossPoints   = input.float(2.5, "Stop Loss (Points)")

// Trailing Option
useTrailing      = input.bool(true, "Enable Trailing Stop (Overrides Fixed TP)?")
trailingDistPts  = input.float(1.0, "Trailing Distance (Points)")

// --- CALCULATIONS ---
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
plot(emaFast, color=color.blue, title="EMA Fast")
plot(emaSlow, color=color.orange, title="EMA Slow")

// --- LOGIC ---
// 1. Identify Cross
crossHappened = ta.crossover(emaFast, emaSlow)

// 2. Check Delay
// If waitBars = 3, we enter if the cross happened 3 bars ago
enterLong = crossHappened[waitBars]

// --- EXECUTION ---
if enterLong
    strategy.entry("Long", strategy.long)

// --- STRICT EXIT LOGIC ---

if strategy.position_size > 0
    float entryPrice = strategy.position_avg_price
    
    // Calculate Exact Price Levels
    float slLevel = entryPrice - stopLossPoints
    float tpLevel = entryPrice + takeProfitPoints
    
    // TRAILING LOGIC vs FIXED LOGIC
    if useTrailing
        // Convert points to ticks for trailing offset
        float trailOffsetTicks = trailingDistPts / syminfo.mintick
        // Strict Trailing Exit
        strategy.exit("Exit Trail", "Long", stop=slLevel, trail_points=0, trail_offset=trailOffsetTicks)
    else
        // STRICT Fixed Exit using LIMIT (TP) and STOP (SL)
        strategy.exit("Exit Fixed", "Long", stop=slLevel, limit=tpLevel)

// --- VISUAL CONFIRMATION ---
plotshape(crossHappened, style=shape.cross, location=location.belowbar, color=color.gray, size=size.tiny, title="Cross")
plotshape(enterLong, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Buy", text="BUY")
````
