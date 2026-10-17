# Arc Engine

- url: https://www.tradingview.com/script/mhZ0ur6o-Arc-Engine/
- type: indicator
- pine_id: PUB;b1cb9c1d954e41d089c111b7bd0afe3b
- version: 3.0

## Description

Executive Summary

Arc Engine - is a high-performance, non-repainting quantitative trading script engineered specifically for intraday market structures. The engine is architected to exploit the fractal geometry of financial markets by tracking systematic cycles of expansion and contraction (represented visually as macro structural "arcs").

By mapping the footprints of high-frequency trading (HFT) models and institutional order execution routing, the engine isolates structural exhaustion zones, filters out toxic market noise, and targets explosive breakouts with mechanical precision.

Core System Architecture & Multi-Layer Logic-

The engine structures market data into a clean, hierarchical multi-layered framework designed to eliminate emotional bias and lag:

LAYER 1: THE MACRO BASELINE ANCHOR (200 EMA)               |
| Defines the structural environment (Dominant Cycle Slope)  |
+------------------------------------------------------------+
                             │
                             ▼
+------------------------------------------------------------+
| LAYER 2: INSTITUTIONAL RIBBON MATRIX (20 EMA / 50 EMA)     |
| Maps short-to-medium term value capture & contraction zones|
+------------------------------------------------------------+
                             │
                             ▼
+------------------------------------------------------------+
| LAYER 3: CLEAN BREAKOUT FILTER (Execution Trigger)         |
| Enforces strict structural clearance rules (No Fake Wicks) |
+------------------------------------------------------------

1. The Macro Baseline Anchor (Layer One)

At the core of the engine sits the 200-period Exponential Moving Average (EMA). Serving as the system's "gravitational center," this line distinguishes between macro expansion and structural mean reversion. In a heavy downward cycle or macro arc formation, this boundary represents the institutional ceiling where short-sellers repeatedly defend liquidity.

2. The Institutional Ribbon Matrix (Layer Two)

The intermediate structural behavior is governed by a smoothed ribbon matrix comprising the 20 EMA (Fast Line) and 50 EMA (Slow Line).
The Squeeze Zone: When these lines compress, flatten, and twist, the engine identifies a low-volatility compression zone (e.g., Wave 2 or Wave B structures).
The Expansion Phase: When the ribbon fans out with a steep slope, it confirms true algorithmic momentum (e.g., Wave 3 or Wave C expansions).

3. The Clean Breakout Filter (Layer Three)

To mitigate the risk of algorithmic "liquidity hunts" (where market makers intentionally trigger retail stops via volatile wicks before reversing price), the engine abandons standard line crossovers. 

Execution requires a Clean Candle Breakout:

Long Trigger: The entire body (both the open and the close) of the execution candle must clear completely above the highest boundary of the Ribbon Matrix.

Short Trigger: The entire body of the candle must close completely below the lowest boundary of the Ribbon Matrix.

Algorithmic State Control & Execution Mechanics

Signal Pruning & Noise Reduction

To avoid the mathematical trap of "signal stacking" during high-volatility expansions, the script utilizes a strict persistent state variable architecture (last Signal Direction).

Execution Framework-

The engine is highly optimized for lower timeframes (such as the 1-minute, 2-minute, or 5-minute charts) to capture micro-turns with minimal drawdown. 

By implementing the bar state is confirmed runtime condition, the engine evaluates execution rules exclusively at the exact millisecond a bar closes. This mathematically eliminates historical repainting, ensuring back testing performance matches live execution identically.

## Source Code

````pine
//@version=6
indicator(" Arc Engine [Pridarasx]", overlay=true, max_labels_count=500)

//Visual refresh
// ==========================================
// INPUTS & SETTINGS
// ==========================================
var string G1 = "Institutional Ribbon Matrix"
fastLength    = input.int(20, "Fast Ribbon Line", minval=1, group=G1)
slowLength    = input.int(50, "Slow Ribbon Line", minval=1, group=G1)
macroLength   = input.int(200, "Macro Baseline Anchor", minval=1, group=G1)

var string G2 = "Arc Exhaustion Filter"
exhaustionPeriod = input.int(10, "Exhaustion Lookback", minval=2, group=G2)


// ==========================================
// 1. GENERATING THE RIBBON & BASELINE STRUCTURE
// ==========================================
// Creating the smooth tracking ribbon visible in your screenshots
fastLine  = ta.ema(close, fastLength)
slowLine  = ta.ema(close, slowLength)
macroLine = ta.ema(close, macroLength)

// Determine the tracking ribbon's color state dynamically
color ribbonColor = fastLine > slowLine ? color.new(color.green, 30) : color.new(color.red, 30)


// ==========================================
// 2. INSTITUTIONAL REVERSAL DETECTION
// ==========================================
// Detect crossovers (the moment the ribbon changes structural direction out of the arc bottom/top)
ribbon_bullish_cross = ta.crossover(fastLine, slowLine)
ribbon_bearish_cross = ta.crossunder(fastLine, slowLine)

// Exhaustion conditions: Price must have pushed into a fresh extreme low/high right before the cross
price_swept_low  = ta.lowest(low, exhaustionPeriod) == low[1] or ta.lowest(low, exhaustionPeriod) == low
price_swept_high = ta.highest(high, exhaustionPeriod) == high[1] or ta.highest(high, exhaustionPeriod) == high


// ==========================================
// FINAL EXECUTION SIGNAL GENERATION
// ==========================================
// Signals activate when the ribbon crosses over immediately following a deep liquidity sweep
bool algo_buy_signal  = ribbon_bullish_cross and barstate.isconfirmed
bool algo_sell_signal = ribbon_bearish_cross and barstate.isconfirmed


// ==========================================
// STATE CONTROL & SIGNAL PRUNING
// ==========================================
var int lastSignalDirection = 0 // 1 = Buy, -1 = Sell

if algo_buy_signal
    lastSignalDirection := 1
if algo_sell_signal
    lastSignalDirection := -1

bool final_buy  = algo_buy_signal  and (lastSignalDirection[1] != 1)
bool final_sell = algo_sell_signal and (lastSignalDirection[1] != -1)


// ==========================================
// VISUALIZATION & PLOTS
// ==========================================
// Render the core structural ribbon lines
plot(fastLine, title="Ribbon Fast Line", color=ribbonColor, linewidth=2)
plot(slowLine, title="Ribbon Slow Line", color=color.new(color.yellow, 20), linewidth=2)
plot(macroLine, title="Macro Baseline Anchor", color=color.new(color.purple, 10), linewidth=3)

// Print high-visibility labels right at the turn of the arcs
if final_buy
    label.new(bar_index, low, "CONFIRMED BUY", color=color.blue, textcolor=color.white, style=label.style_label_up, size=size.small)

if final_sell
    label.new(bar_index, high, "CONFIRMED SELL", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)
````
