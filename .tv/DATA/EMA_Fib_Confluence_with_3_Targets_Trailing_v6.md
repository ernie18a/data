<!-- tradingview-pine-id: PUB;0dbc7d69be0b4a108e8532cfd6d2aa24 -->
<!-- tradingviewscripts-format: 1 -->
# EMA & Fib Confluence with 3 Targets + Trailing v6

Source: https://www.tradingview.com/script/diZ8Oes6-EMA-Fib-Confluence-with-3-Targets-Trailing-v6/

## Description

EMA & Fib Confluence with 3 Targets + Trailing v6- By MaxTrader6876

OverviewThis script is a fully automated, quantitative trend-following strategy that combines Exponential Moving Averages (EMA) with dynamic Fibonacci retracement levels. By demanding strict structural confirmation between moving average momentum and key mathematical levels, the strategy filters out false breakouts. It features automated position scaling across three separate take-profit levels alongside a dynamic trailing stop mechanism to maximize trend yields.🚦 Core Entry Rules (Confluence Setup)An execution order is only triggered when two distinct conditions align on the same candle:Long Entry: The Fast EMA must be tracking above the Slow EMA (Bullish Trend), AND the market price must execute a clean crossover above the user-defined Fibonacci Entry Level (default: 0.618).Short Entry: The Fast EMA must be tracking below the Slow EMA (Bearish Trend), AND the market price must execute a clean crossunder below the user-defined Fibonacci Entry Level (default: 0.618).📦 Position Scaling & Multi-Target Profit ManagementTo mitigate risk and lock in realized equity, the strategy systematically scales out of active positions:Target 1: Closes 33% of the position size at a 1.0% price move from entry.Target 2: Closes 33% of the position size at a 2.0% price move from entry.Target 3: Closes the final 34% of the position size at a 3.5% price move from entry.🛡️ Risk Management & Dynamic Exit ProtocolsYour capital is protected by two overlapping safety systems:Dynamic Trailing Stop: Tracks the market price at a fixed distance (default: 1.5%). It continually tightens to lock in profits as the trade moves in your favour but will never widen if the price moves against you.EMA Reverse Crossover Safety Net: If the underlying trend shifts aggressively before a profit target or trailing stop is reached, an immediate market close is forced when the EMAs cross back over (e.g., Fast EMA crossing back under the Slow EMA for a Long trade).⚙️ Adjusting Key InputsFast/Slow EMA Lengths: Fine-tune the baseline momentum trend filter (Defaults: 9 and 21).Fibonacci Lookback Period: Changes the number of historical bars used to calculate the absolute swing highs and swing lows (Default: 50 bars).Fib Entry Target Ratio: The specific Fibonacci level required to trigger the confluence entry condition (Default: 0.618).Take Profit/Trailing Percentages: Fully customizable to adapt to different asset volatilities (Crypto, Forex, or Indices).⚠️ DisclaimerThis script is shared for educational and strategic testing purposes only. Past performance does not guarantee future results. Algorithmic trading involves substantial financial risk; ensure you backtest thoroughly on your specific asset and timeframe before deploying live capital via webhooks.

---

## Source Code

````pine
//@version=6
strategy("EMA & Fib Confluence with 3 Targets + Trailing v6", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// --- INPUTS ---
// EMA Lengths
fastEmaLen = input.int(9, title="Fast EMA Length", group="EMA Trend Settings")
slowEmaLen = input.int(21, title="Slow EMA Length", group="EMA Trend Settings")

// Fibonacci Lookback & Levels
fibLookback = input.int(50, title="Fibonacci Lookback Period", group="Fibonacci Levels")
fibLevelEntry = input.float(0.618, title="Fib Entry Target Ratio", group="Fibonacci Levels")

// Take Profit Settings (In Percentages from Entry Price)
tp1_pct = input.float(1.0, title="Target 1 (%)", group="Take Profit Settings") / 100
tp2_pct = input.float(2.0, title="Target 2 (%)", group="Take Profit Settings") / 100
tp3_pct = input.float(3.5, title="Target 3 (%)", group="Take Profit Settings") / 100

// Position Scaling Settings (Must equal 100% total)
tp1_qty = input.float(33.0, title="Target 1 Close Qty (%)", group="Position Scaling")
tp2_qty = input.float(33.0, title="Target 2 Close Qty (%)", group="Position Scaling")
tp3_qty = input.float(34.0, title="Target 3 Close Qty (%)", group="Position Scaling")

// Trailing Stop Settings
trail_pct = input.float(1.5, title="Trailing Distance (%)", group="Trailing Stop Settings") / 100

// --- CALCULATIONS ---
fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)

plot(fastEma, color=color.green, title="Fast EMA")
plot(slowEma, color=color.red, title="Slow EMA")

highestHigh = ta.highest(high, fibLookback)
lowestLow = ta.lowest(low, fibLookback)
priceRange = highestHigh - lowestLow

fibLongLevel = highestHigh - (priceRange * fibLevelEntry)
fibShortLevel = lowestLow + (priceRange * fibLevelEntry)

// --- SIGNALS & MUTABLE TRACKERS ---
buyConfluence  = (fastEma > slowEma) and ta.crossover(close, fibLongLevel)
sellConfluence = (fastEma < slowEma) and ta.crossunder(close, fibShortLevel)

// Persistent state variables for managing trade execution levels
var float entryPrice = na
var float t1_price = na
var float t2_price = na
var float t3_price = na
var float trailingStop = na
var int activePositionType = 0 // 1 = Long, -1 = Short, 0 = None

// Detect Entry Changes to Lock Targets
if (buyConfluence and activePositionType == 0)
    entryPrice := close
    t1_price := close * (1 + tp1_pct)
    t2_price := close * (1 + tp2_pct)
    t3_price := close * (1 + tp3_pct)
    trailingStop := close * (1 - trail_pct)
    activePositionType := 1
    strategy.entry("Long", strategy.long)

if (sellConfluence and activePositionType == 0)
    entryPrice := close
    t1_price := close * (1 - tp1_pct)
    t2_price := close * (1 - tp2_pct)
    t3_price := close * (1 - tp3_pct)
    trailingStop := close * (1 + trail_pct)
    activePositionType := -1
    strategy.entry("Short", strategy.short)

// --- TRAILING STOP & EXECUTION LOGIC ---
if (strategy.position_size > 0 and activePositionType == 1)
    // Scale out at calculated profit thresholds using specific exit IDs
    strategy.exit("T1 Long", from_entry="Long", qty_percent=tp1_qty, limit=t1_price)
    strategy.exit("T2 Long", from_entry="Long", qty_percent=tp2_qty, limit=t2_price)
    strategy.exit("T3 Long", from_entry="Long", qty_percent=tp3_qty, limit=t3_price)
    
    // Tighten dynamic trailing stop if price advances upwards
    if (close * (1 - trail_pct) > trailingStop)
        trailingStop := close * (1 - trail_pct)
        
    // Hard check for trailing stop breakout or adverse reverse EMA crossover
    if (close <= trailingStop or ta.crossunder(fastEma, slowEma))
        strategy.close("Long", comment="Trailing Stop or Reverse Cross")
        activePositionType := 0

if (strategy.position_size < 0 and activePositionType == -1)
    // Scale out at calculated profit thresholds using specific exit IDs
    strategy.exit("T1 Short", from_entry="Short", qty_percent=tp1_qty, limit=t1_price)
    strategy.exit("T2 Short", from_entry="Short", qty_percent=tp2_qty, limit=t2_price)
    strategy.exit("T3 Short", from_entry="Short", qty_percent=tp3_qty, limit=t3_price)
    
    // Tighten dynamic trailing stop if price falls downwards
    if (close * (1 + trail_pct) < trailingStop)
        trailingStop := close * (1 + trail_pct)
        
    // Hard check for trailing stop breakout or adverse reverse EMA crossover
    if (close >= trailingStop or ta.crossover(fastEma, slowEma))
        strategy.close("Short", comment="Trailing Stop or Reverse Cross")
        activePositionType := 0

// Reset state completely if position vanishes via other means
if (strategy.position_size == 0)
    activePositionType := 0
````
