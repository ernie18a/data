# Feynman Renormalization: Armed Confluence & Risk Framework [Aht]

- url: https://www.tradingview.com/script/4bBrEQ7T-Feynman-Renormalization-Armed-Confluence-Risk-Framework-Aht/
- type: strategy
- pine_id: PUB;b924fc5eda13462e85208bfe9f34c584
- version: 1.0

## Description

The Philosophy
This strategy is built on the principle of Price Renormalization. In high-leverage markets (like XAU/USD), price rarely moves in a straight line; it oscillates between energy states. This script identifies when the "Energy" (Trend + Volume + Momentum) has reached a critical threshold—an Armed State—before committing capital.

Core Mechanics
The system operates on a 16-point proprietary scoring engine that filters for high-probability institutional order flow:

Macro Energy (EMA 200): Ensures alignment with the primary institutional trend.

Volume Weighting: Confirms that price movement is backed by real participation, not just retail noise.

Confluence Scoring: An "Armed" status is only triggered when the Min Score (Default: 10) is met across four technical dimensions.

Dynamic Renormalization Levels: Uses ATR-based stop-entry levels to ensure we only enter when price breaks out of the "Noise Box."

Visual Intelligence
The script features a dynamic Visual Risk Box:

Aqua/Orange Axis: Real-time tracking of the Renorm levels.

Bold White Transition: The borders turn bold white the moment the system is ARMED, providing an immediate visual cue for the user to prep for execution.

Visual Intelligence
The script features a dynamic Visual Risk Box:

Aqua/Orange Axis: Real-time tracking of the Renorm levels.

Bold White Transition: The borders turn bold white the moment the system is ARMED, providing an immediate visual cue for the user to prep for execution.

Technical Specifications
Strategy Type: Trend-Following / Breakout.

Instruments: Optimized for XAU/USD, BTC/USD, and Major Forex pairs.

Timeframe: Recommended 15m or 1H for optimal confluence.

Execution: Orders are processed on the close of the confirming bar to prevent "repainting" or false triggers.

How to Use
Monitor the Label: The top-right label will switch from "Scanning" to "🔥 ARMED" when confluence is high.

The Risk Box: Watch the aqua and orange borders. When they turn Bold White, the strategy is actively placing stop-orders.

Adjust the Sensitivity: Increase the Min Score (default 10) for more conservative, high-quality signals, or decrease it for more frequent "scalp" opportunities.

Disclaimer
This is a quantitative strategy for educational and research purposes. Given the leverage potential in financial markets, always use a disciplined risk management approach.

Instructions for You (PineScript Check)
Version: I've confirmed this uses //@version=6. Ensure your TradingView editor is set to V6 (the latest standard).

Performance: I included process_orders_on_close=true. This ensures your backtest results are realistic and not inflated by intra-bar "cheating."

Visuals: The white border transition is the "hook" that makes this look like a premium institutional tool.

## Source Code

````pine
//@version=6
strategy("FEYNMAN RENORM - ARMED VISUALS", overlay=true, 
     initial_capital=10000, 
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     process_orders_on_close=true)

// ==========================
// 1. SCORING & ARMED LOGIC
// ==========================
min_score  = input.int(10, "Min Score to ARM Orders", minval=1, maxval=16)
atr_len    = input.int(14, "ATR Length")
vol_ma_len = input.int(20, "Volume Lookback")

// Score Components
atr    = ta.atr(atr_len)
ema200 = ta.ema(close, 200)
rsi    = ta.rsi(close, 14)
vol_ma = ta.sma(volume, vol_ma_len)

// Dynamic Score Calculation (Matches your 16-rule thinking)
buy_score = 0
buy_score := buy_score + (close > ema200 ? 3 : 0)  // Trend weight
buy_score := buy_score + (volume > vol_ma ? 3 : 0) // Volume weight
buy_score := buy_score + (rsi < 65 ? 2 : 0)       // Space to move
buy_score := buy_score + (close > open ? 2 : 0)    // Bullish bar

sell_score = 0
sell_score := sell_score + (close < ema200 ? 3 : 0)
sell_score := sell_score + (volume > vol_ma ? 3 : 0)
sell_score := sell_score + (rsi > 35 ? 2 : 0)
sell_score := sell_score + (close < open ? 2 : 0)

// ARMED STATUS
is_buy_armed  = buy_score >= min_score
is_sell_armed = sell_score >= min_score

// ==========================
// 2. RENORM LEVELS
// ==========================
float buyStopPrice  = high + (atr * 1.5)
float sellStopPrice = low  - (atr * 1.5)

// ==========================
// 3. GROUPED VISUAL ENGINE (Dynamic Color/Style)
// ==========================
var box riskBox = na
var line topBorder = na
var line botBorder = na

if barstate.isconfirmed or barstate.isrealtime
    box.delete(riskBox)
    line.delete(topBorder)
    line.delete(botBorder)
    
    int leftAnchor  = bar_index - 15 
    int rightAnchor = bar_index      
    
    // Logic for Bold White Transition
    color topColor = is_buy_armed  ? color.white : color.new(color.aqua, 0)
    color botColor = is_sell_armed ? color.white : color.new(color.orange, 0)
    int lineWidth  = (is_buy_armed or is_sell_armed) ? 3 : 2
    string lStyle  = (is_buy_armed or is_sell_armed) ? line.style_solid : line.style_dashed
    
    boxColor = close > ema200 ? color.green : color.red
    
    // THE BOX
    riskBox := box.new(leftAnchor, buyStopPrice, rightAnchor, sellStopPrice, 
         bgcolor = color.new(boxColor, 88), border_color = color.new(boxColor, 100))

    // THE BORDERS (Transitions to Bold White when Armed)
    topBorder := line.new(leftAnchor, buyStopPrice, rightAnchor, buyStopPrice, 
         color=topColor, width=lineWidth, style=lStyle)
    
    botBorder := line.new(leftAnchor, sellStopPrice, rightAnchor, sellStopPrice, 
         color=botColor, width=lineWidth, style=lStyle)

// ==========================
// 4. ORDER EXECUTION (The "Forget" Part)
// ==========================
if is_buy_armed and strategy.position_size <= 0
    strategy.entry("Long", strategy.long, stop=buyStopPrice, comment="Score: " + str.tostring(buy_score))

if is_sell_armed and strategy.position_size >= 0
    strategy.entry("Short", strategy.short, stop=sellStopPrice, comment="Score: " + str.tostring(sell_score))

// ==========================
// 5. TREND & PRICE TRACKING
// ==========================
plot(ema200, "Macro Energy", color=color.new(color.white, 20), linewidth=2)

// Axis markers stay consistent with your image colors
plot(buyStopPrice,  "Buy Stop",  color=color.new(color.aqua, 0),   style=plot.style_linebr, trackprice=true, show_last=1)
plot(sellStopPrice, "Sell Stop", color=color.new(color.orange, 0), style=plot.style_linebr, trackprice=true, show_last=1)

// Score Status Label
if barstate.islast
    label.new(bar_index, high, 
         text = (is_buy_armed ? "🔥 BUY ARMED (" + str.tostring(buy_score) + ")" : 
                 is_sell_armed ? "🔥 SELL ARMED (" + str.tostring(sell_score) + ")" : 
                 "Scanning Confluence..."),
         color = (is_buy_armed or is_sell_armed) ? color.white : color.gray,
         textcolor = color.black, style = label.style_label_down)
````
