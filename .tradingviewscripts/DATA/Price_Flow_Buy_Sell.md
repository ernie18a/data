<!-- tradingview-pine-id: PUB;0d990f9197764b2c98dcc61ccfa518e5 -->
<!-- tradingviewscripts-format: 1 -->
# Price Flow - Buy Sell

Source: https://www.tradingview.com/script/0hiudM0o-Price-Flow-Buy-Sell/

## Description

# Price Flow Buy Sell

**Price Flow Buy Sell** is an adaptive market-flow indicator designed to identify potential BUY and SELL opportunities by analyzing price direction, volatility, momentum, statistical price extremes, and signs of trend exhaustion.

Instead of relying on a basic moving-average crossover, Price Flow Buy Sell continuously estimates the market's dynamic **fair value** and measures how price is behaving around that level.

The goal is simple:

**Identify when price becomes stretched, momentum begins to weaken, and price flow shows signs of changing direction.**

## 🚀 Key Features

### 🟢 Clear BUY & SELL Signals

Price Flow Buy Sell displays easy-to-read signals directly on the chart:

**BUY** signals identify potential bullish reversal opportunities.

**SELL** signals identify potential bearish reversal opportunities.

Signals are not generated from price crossing a single line. Multiple conditions involving price rejection, momentum and market behavior are evaluated before a signal is produced.

---

## 📈 Adaptive Price Flow

At the heart of the indicator is an adaptive statistical regression model that calculates a dynamic **Fair Value Core**.

Unlike a traditional moving average, the calculation uses weighted historical price information and automatically adapts to changing volatility.

This creates a smoother representation of the underlying price flow while helping reduce short-term market noise.

---

## 🌊 Dynamic Fair Value

The central Price Flow line represents the estimated fair value of the market.

Its color provides a quick visual indication of momentum:

🟢 **Green:** Bullish price flow

🔴 **Red:** Bearish price flow

⚪ **Grey/Neutral:** Momentum is weak or transitioning

The indicator analyzes both the **velocity and acceleration** of the fair-value curve rather than simply checking whether price is above or below it.

This can help identify when an existing move is beginning to lose momentum.

---

## 🎯 Adaptive Price Zones

Price Flow Buy Sell automatically creates dynamic Inner and Outer zones around fair value.

### Inner Zones

The Inner Zones represent moderate deviations from fair value.

They are particularly useful when the market is consolidating or trading within a range.

### Outer Zones

The Outer Zones represent more extreme deviations from fair value.

During stronger trends, the indicator becomes more selective and focuses on price rejection around these extreme zones.

This helps reduce the tendency to generate reversal signals too early during powerful market moves.

---

## 🟢 How BUY Signals Are Detected

A potential BUY setup begins when price becomes extended below its calculated fair-value range.

The indicator then looks for evidence that bearish pressure is weakening.

Depending on current market conditions, the system evaluates factors including:

• Price reaching the lower adaptive zone
• Rejection back inside the zone
• Bullish candle confirmation
• Weakening bearish price flow
• Positive momentum acceleration
• Current trend/range conditions

When the required conditions align, a **BUY** signal is displayed below the candle.

The objective is to identify potential bullish reversals after selling pressure begins to lose strength.

---

## 🔴 How SELL Signals Are Detected

A potential SELL setup occurs when price becomes extended above its calculated fair-value range.

The indicator then analyzes whether bullish momentum is beginning to weaken.

Conditions can include:

• Price reaching the upper adaptive zone
• Rejection back inside the zone
• Bearish candle confirmation
• Weakening bullish price flow
• Negative momentum acceleration
• Current trend/range conditions

When the conditions align, a **SELL** signal is displayed above the candle.

The objective is to identify potential bearish reversals after buying pressure begins to lose strength.

---

## 🧠 Automatic Trend & Range Detection

Markets behave differently when trending and ranging.

Price Flow Buy Sell automatically evaluates the strength of the underlying price movement and adjusts its signal logic accordingly.

**Trending Market**

The indicator becomes more selective and primarily looks for reversals from the Outer Zones.

**Ranging Market**

The indicator can use the closer Inner Zones to detect shorter price-flow reversals.

This adaptive behavior allows the same indicator to respond differently as market conditions change.

---

## ⚡ Adaptive Volatility Engine

Market volatility is constantly changing.

When **Adaptive Volatility** is enabled, Price Flow Buy Sell automatically adjusts its calculations using current ATR volatility relative to recent market volatility.

During high volatility, additional smoothing helps reduce noise.

During normal or lower volatility, the indicator can remain more responsive to changes in price flow.

---

## 🛡️ Range Filter

The optional **Range Filter** provides additional momentum confirmation for signals generated around the Inner Zones.

When enabled, the indicator requires evidence that the existing price movement is weakening before generating a signal.

This provides a more selective signal approach.

Traders looking for more aggressive signals can disable the Range Filter.

---

## 🔄 Strict Buy/Sell Alternation

Price Flow Buy Sell also includes an optional **Strict Buy/Sell Alternation** mode.

When enabled, signals follow the sequence:

**BUY → SELL → BUY → SELL**

A second BUY cannot occur until a SELL has appeared, and vice versa.

This can provide a cleaner chart for traders who prefer directional transitions rather than repeated same-direction signals.

---

## 🔔 BUY & SELL Alerts

TradingView alerts are available for both signal types:

🔔 **BUY Alert**

🔔 **SELL Alert**

Alerts can be used to monitor multiple markets without continuously watching every chart.

---

## ⚙️ Main Settings

**Base Bandwidth**

Controls the responsiveness and smoothness of the Price Flow calculation.

Lower values increase responsiveness, while higher values provide greater smoothing.

**Lookback Window**

Controls the amount of historical price information used in calculating fair value.

**Inner Band Multiplier**

Controls the distance of the Inner Price Flow Zones.

**Outer Band Multiplier**

Controls the distance of the more extreme Outer Price Flow Zones.

**Adaptive Volatility**

Allows the calculation to automatically adjust to changing volatility.

**Range Filter**

Adds momentum confirmation to signals generated during ranging conditions.

**Strict Buy/Sell Alternation**

Prevents consecutive signals in the same direction.

---

## 📊 Suitable Markets

Price Flow Buy Sell can be applied to different liquid markets, including:

• Stocks
• Indices
• Futures
• Commodities
• Forex
• Cryptocurrency

It can also be tested across different chart timeframes depending on the trader's strategy.

---

## 💡 How to Use Price Flow Buy Sell

Rather than treating every BUY or SELL label as an automatic trade, traders can use Price Flow Buy Sell as a confirmation tool alongside:

• Support & Resistance
• VWAP
• Market Structure
• Volume Analysis
• Higher-Timeframe Trend
• RSI / Momentum
• Risk Management

For example, a BUY signal appearing near an established support area can provide stronger context than a BUY signal occurring without supporting market structure.

---

## ⚠️ Important

Price Flow Buy Sell does not attempt to predict the exact top or bottom of every market movement.

The indicator identifies conditions where price has become statistically extended from its estimated fair value while the underlying price flow shows potential signs of momentum exhaustion or reversal.

Signals should therefore be considered trading opportunities rather than guaranteed outcomes.

Always use appropriate risk management and independently evaluate market conditions before making trading decisions.

---

### Price Flow Buy Sell

**Follow the flow. Identify the extremes. Spot potential reversals.**

---

## Source Code

````pine
//@version=6
//@Salqi
indicator('Price Flow - Buy Sell', overlay = true, max_bars_back = 1000)

// kernel parameters
grp_kernel = 'Kernel Physics'
h_val = input.float(8.0, 'Base Bandwidth (h)', minval = 1.0, tooltip = 'Defaults to 8.0 for signal stability (noise reduction).', group = grp_kernel)
lookback = input.int(50, 'Lookback Window', minval = 10, maxval = 500, tooltip = 'Number of historical bars used for kernel regression at each point.', group = grp_kernel)
use_vol = input.bool(true, 'Enable Adaptive Volatility', tooltip = 'If enabled, bandwidth expands during high volatility to reduce noise.', group = grp_kernel)

// envelope settings
grp_env = 'Envelope Statistics'
mult_in = input.float(1.500, 'Inner Band Multiplier (Balanced)', step = 0.1, group = grp_env)
mult_out = input.float(2.800, 'Outer Band Multiplier (Precision)', step = 0.1, group = grp_env)
src = input.source(hlc3, 'Source Price', group = grp_env)

// risk management
grp_risk = 'Risk Management'
filter_rng = input.bool(true, 'Range Filter', tooltip = 'If enabled, signals in the Ranging Zone (Inner Band) only appear when momentum weakens. Helps prevent catching falling knives during breakouts.', group = grp_risk)

// Buy / Sell settings
grp_sig = 'Buy / Sell Signals'
show_buy_sell = input.bool(true, 'Show Buy / Sell Labels', group = grp_sig)
strict_alternation = input.bool(false, 'Strict Buy/Sell Alternation', tooltip = 'When enabled, a BUY must be followed by a SELL before another BUY can appear, and vice versa.', group = grp_sig)

// visuals
grp_vis = 'Visuals'
col_bull = input.color(#00ffaa, 'Bullish', group = grp_vis)
col_bear = input.color(#ff0044, 'Bearish', group = grp_vis)
col_neut = input.color(#434651, 'Neutral/Grey', group = grp_vis)

// gaussian kernel (endpoint estimator)
// calculates per-bar to ensure no repainting

// volatility adjustment
atr_len = 20
vol_raw = ta.atr(atr_len)
vol_base = ta.sma(vol_raw, 100)
vol_ratio = use_vol ? vol_raw / (vol_base == 0 ? 1 : vol_base) : 1.0
vol_mod = math.max(0.5, math.min(vol_ratio, 2.0))
h_eff = h_val * vol_mod

// kernel regression loop
var float y_hat = 0.0
float num = 0.0
float den = 0.0

for i = 0 to lookback by 1
    float dist = float(i)
    float w = math.exp(-math.pow(dist, 2) / (2 * math.pow(h_eff, 2)))
    num := num + w * src[i]
    den := den + w

y_hat := num / den

// statistical bounds (mae)
float error = math.abs(src - y_hat)
float mae = ta.sma(error, lookback)

float upper_in = y_hat + mae * mult_in
float lower_in = y_hat - mae * mult_in
float upper_out = y_hat + mae * mult_out
float lower_out = y_hat - mae * mult_out

// visual gradient engine
// velocity & acceleration
float velocity = y_hat - y_hat[1]
float accel = velocity - velocity[1]

// smooth velocity slightly for cleaner colors
float vel_vis = ta.ema(velocity, 5)

// normalize gradient
float vel_stdev = ta.stdev(velocity, 20)
bool is_trending = math.abs(velocity) > vel_stdev * 0.5

// saturation limit (2 sigma)
float vel_max = vel_stdev * 2.0

// calculate gradient color
color dyn_col = vel_vis > 0 ? color.from_gradient(vel_vis, 0, vel_max, col_neut, col_bull) : color.from_gradient(vel_vis, -vel_max, 0, col_bear, col_neut)

// signal logic
// physics check (using raw velocity for precision)
bool bull_weaken = velocity > 0 and accel < 0
bool bear_weaken = velocity < 0 and accel > 0

// crossover events (rejection)
bool sell_rejection_out = high > upper_out and close < upper_out and close < open
bool buy_rejection_out = low < lower_out and close > lower_out and close > open

bool sell_rejection_in = high > upper_in and close < upper_in and close < open
bool buy_rejection_in = low < lower_in and close > lower_in and close > open

// prevent signal spamming
bool new_sell_out = sell_rejection_out and not sell_rejection_out[1]
bool new_buy_out = buy_rejection_out and not buy_rejection_out[1]
bool new_sell_in = sell_rejection_in and not sell_rejection_in[1]
bool new_buy_in = buy_rejection_in and not buy_rejection_in[1]

bool signal_short = false
bool signal_long = false

// regime logic
if is_trending
    // strict rules for trending (outer band only)
    signal_short := new_sell_out and bull_weaken
    signal_long := new_buy_out and bear_weaken
else
    // flexible rules for ranging
    if filter_rng
        // physics check required for inner band
        signal_short := new_sell_in and bull_weaken
        signal_long := new_buy_in and bear_weaken
    else
        // aggressive mode
        signal_short := new_sell_in
        signal_long := new_buy_in

// strict alternation
var int last_signal = 0

bool buy_signal = signal_long and (not strict_alternation or last_signal != 1)
bool sell_signal = signal_short and (not strict_alternation or last_signal != -1)

if buy_signal
    last_signal := 1
else if sell_signal
    last_signal := -1

// visualization
plot(y_hat, 'Fair Value Core', color = dyn_col, linewidth = 2)

// inner glow
plot(y_hat, 'Fair Value Glow 1', color = color.new(dyn_col, 50), linewidth = 4)
plot(y_hat, 'Fair Value Glow 2', color = color.new(dyn_col, 80), linewidth = 8)

// envelope plots
p_mid = plot(y_hat, display = display.none)
p_u1 = plot(upper_in, 'Upper Inner', color = color.new(dyn_col, 80))
p_l1 = plot(lower_in, 'Lower Inner', color = color.new(dyn_col, 80))
p_u2 = plot(upper_out, 'Upper Outer', color = color.new(dyn_col, 60))
p_l2 = plot(lower_out, 'Lower Outer', color = color.new(dyn_col, 60))

// probability cloud fills
fill(p_mid, p_u1, color = color.new(dyn_col, 90), title = 'Bull Zone')
fill(p_mid, p_l1, color = color.new(dyn_col, 90), title = 'Bear Zone')
fill(p_u1, p_u2, color = color.new(dyn_col, 80), title = 'Bull Extreme')
fill(p_l1, p_l2, color = color.new(dyn_col, 80), title = 'Bear Extreme')

// BUY / SELL markers
plotshape(show_buy_sell and buy_signal, title = 'BUY', style = shape.labelup, location = location.belowbar, color = col_bull, text = 'BUY', textcolor = color.black, size = size.small)
plotshape(show_buy_sell and sell_signal, title = 'SELL', style = shape.labeldown, location = location.abovebar, color = col_bear, text = 'SELL', textcolor = color.white, size = size.small)

// alerts
alertcondition(buy_signal, title = 'BUY Alert', message = 'BUY signal on {{ticker}} at {{close}}')
alertcondition(sell_signal, title = 'SELL Alert', message = 'SELL signal on {{ticker}} at {{close}}')
````
