# Strategy Auto-Optimized by Backpulse

- url: https://www.tradingview.com/script/cOy70wgl/
- type: strategy
- pine_id: PUB;cac18ca06c6a4b5785d4461736db2d60
- version: 1.0

## Description

### 🚀 Modern Pine Script v6 Algorithmic Framework
This strategy is engineered using the latest **Pine Script v6** compiler standard, delivering high execution efficiency and clean modular parameter management.

It combines an adaptive Exponential Moving Average (EMA) momentum engine with dynamic Average True Range (ATR) trailing volatility stops to maximize trending upside while systematically containing drawdown.

---

### 🧠 Key Architecture (Pine Script v6)
* **Trend Confirmation:** Fast EMA (momentum) paired with Slow EMA (regime filter) to prevent false counter-trend signals.
* **Dynamic Volatility Trailing Stop:** Continuously ratchets up during Longs and down during Shorts using the ATR multiplier to protect unrealized P&L.
* **Realistic Slippage & Fees:** Includes standard exchange taker fees (0.075%) and slippage for true-to-life backtest metrics.

---

### ⚙️ Optimization Space (Input Variables)
* `Fast EMA Length`: [5 to 100, step 1]
* `Slow EMA Length`: [20 to 200, step 2]
* `ATR Period`: Lookback window
* `ATR Multiplier`: Trailing stop distance
* `Take Profit %` & `Hard Stop Loss %`

---

### 💡 HOW TO AUTO-OPTIMIZE THIS STRATEGY FOR YOUR TIMEFRAME

Because different crypto, forex, and equity assets display varying volatility signatures, default parameters should always be calibrated to your target timeframe (15m, 1h, 4h, Daily).

Instead of spending hours manually guessing slider numbers in TradingView's native Strategy Tester:
👉 Search for **"Backpulse" on the Google Chrome Web Store** to install the **free Backpulse Extension**.
1. Open this Pine Script v6 strategy on your TradingView chart.
2. The Backpulse extension instantly scans all input sliders.
3. Run automated high-speed parameter sweeps in your browser tab to uncover peak Net Profit, Sharpe Ratio, and lowest Drawdown combinations.
4. Click **"Apply Best Parameters"** to load the winning inputs directly back into your chart with 1 click.

---

### ⚠️ Disclaimer
Historical backtest results are hypothetical and do not guarantee future returns. Always test thoroughly across bull, bear, and consolidation regimes.

*Free & Open Source Pine Script v6 for the quant community.*

## Source Code

````pine
//@version=6
strategy("Strategy Auto-Optimized by Backpulse", 
         shorttitle="Backpulse Optimized", 
         overlay=true, 
         initial_capital=10000, 
         default_qty_type=strategy.percent_of_equity, 
         default_qty_value=100, 
         commission_type=strategy.commission.percent, 
         commission_value=0.075,
         slippage=1)

// ============================================================================
// 1. INPUT PARAMETERS (Optimized for Backpulse Parameter Scanner)
// ============================================================================
grp_trend = "Trend Engine (v6)"
fast_length = input.int(14, "Fast EMA Length", minval=5, maxval=100, step=1, group=grp_trend, tooltip="Shorter moving average period for momentum detection")
slow_length = input.int(44, "Slow EMA Length", minval=20, maxval=200, step=2, group=grp_trend, tooltip="Longer moving average period for baseline trend filter")

grp_vol = "Volatility & Trailing Stop Filter"
atr_period = input.int(14, "ATR Length", minval=5, maxval=50, step=1, group=grp_vol)
atr_mult   = input.float(2.5, "ATR Multiplier", minval=0.5, maxval=6.0, step=0.25, group=grp_vol, tooltip="Trailing stop distance multiplier")

grp_risk = "Risk & Money Management"
tp_percent   = input.float(6.0, "Take Profit %", minval=1.0, maxval=25.0, step=0.5, group=grp_risk)
sl_percent   = input.float(3.0, "Hard Stop Loss %", minval=0.5, maxval=10.0, step=0.5, group=grp_risk)
use_trailing = input.bool(true, "Enable Dynamic Trailing Stop", group=grp_risk)
trade_dir    = input.string("Both", "Trade Direction", options=["Both", "Long Only", "Short Only"], group=grp_risk)

// Date Range Filter
grp_date = "Backtest Timeframe Filter"
start_year = input.int(2023, "Start Year", minval=2015, maxval=2030, group=grp_date)
in_date_range = time >= timestamp(syminfo.timezone, start_year, 1, 1, 0, 0)

// ============================================================================
// 2. INDICATOR LOGIC & CALCULATIONS (Pine Script v6 Core)
// ============================================================================
fast_ema = ta.ema(close, fast_length)
slow_ema = ta.ema(close, slow_length)
atr_val  = ta.atr(atr_period)

// Entry Signals
long_cond  = ta.crossover(fast_ema, slow_ema) and close > slow_ema and in_date_range
short_cond = ta.crossunder(fast_ema, slow_ema) and close < slow_ema and in_date_range

// Dynamic ATR Trailing Stops
var float long_trail_stop = na
var float short_trail_stop = na

if long_cond
    long_trail_stop := close - (atr_val * atr_mult)
else if strategy.position_size > 0 and use_trailing
    long_trail_stop := math.max(nz(long_trail_stop, close - (atr_val * atr_mult)), close - (atr_val * atr_mult))
else
    long_trail_stop := na

if short_cond
    short_trail_stop := close + (atr_val * atr_mult)
else if strategy.position_size < 0 and use_trailing
    short_trail_stop := math.min(nz(short_trail_stop, close + (atr_val * atr_mult)), close + (atr_val * atr_mult))
else
    short_trail_stop := na

// ============================================================================
// 3. EXECUTION LOGIC
// ============================================================================
can_long  = (trade_dir == "Both" or trade_dir == "Long Only")
can_short = (trade_dir == "Both" or trade_dir == "Short Only")

if long_cond and can_long
    strategy.entry("Long", strategy.long)

if short_cond and can_short
    strategy.entry("Short", strategy.short)

// Order Exits with Dynamic Stops
if strategy.position_size > 0
    strategy.exit("Exit Long", "Long", 
                  stop = use_trailing ? long_trail_stop : (strategy.position_avg_price * (1 - sl_percent / 100)), 
                  limit = strategy.position_avg_price * (1 + tp_percent / 100))

if strategy.position_size < 0
    strategy.exit("Exit Short", "Short", 
                  stop = use_trailing ? short_trail_stop : (strategy.position_avg_price * (1 + sl_percent / 100)), 
                  limit = strategy.position_avg_price * (1 - tp_percent / 100))

// ============================================================================
// 4. PLOTS & VISUALIZATION
// ============================================================================
plot(fast_ema, "Fast EMA", color=color.new(#6366f1, 0), linewidth=2)
plot(slow_ema, "Slow EMA", color=color.new(#f59e0b, 0), linewidth=2)
plot(use_trailing and strategy.position_size > 0 ? long_trail_stop : na, "Long Trail Stop", color=color.new(#10b981, 0), style=plot.style_linebr, linewidth=2)
plot(use_trailing and strategy.position_size < 0 ? short_trail_stop : na, "Short Trail Stop", color=color.new(#ef4444, 0), style=plot.style_linebr, linewidth=2)

// Dynamic chart background tint
bgcolor(strategy.position_size > 0 ? color.new(#10b981, 93) : strategy.position_size < 0 ? color.new(#ef4444, 93) : na)
````
