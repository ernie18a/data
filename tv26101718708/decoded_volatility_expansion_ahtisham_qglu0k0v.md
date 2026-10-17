# Decoded Volatility Expansion [Ahtisham]

- url: https://www.tradingview.com/script/qgLu0K0v-Decoded-Volatility-Expansion-Ahtisham/
- type: strategy
- pine_id: PUB;c6f97f1972e04b19b8d6f71f6448f1df
- version: 1.0

## Description

The Decoded Volatility Expansion engine is built on the principle of Market Compression vs. Expansion. Markets spend the majority of their time in a state of "Consolidation Noise." This strategy is designed to ignore that noise and only commit capital when volatility breaks a specific mathematical threshold—effectively "decoding" the moment a range expansion begin

CORE MECHANICS
The system utilizes a dynamic "Consolidation Box" to map institutional equilibrium before placing strategic stop-entry orders:

Volatility Decoding (ATR-Outlier): Unlike standard breakout bots, this engine uses an ATR-based multiplier to identify "Outlier Volatility." It sets entry triggers beyond the normal noise floor.

Equilibrium Mid-Line: The strategy identifies the zoneMid (Point of Control) of the recent consolidation. This acts as our "Gravity Point" for stop-loss placement, ensuring we exit if the breakout fails to sustain momentum.

Expansion Triggers: The system places passive Stop Orders (Aqua for Long, Orange for Short). These are only filled if the market demonstrates an aggressive expansion state.

Asymmetric Risk Management: Uses a customizable Reward-to-Risk (RR) ratio (Default 2.0) to ensure that winning expansions significantly outweigh "Fakeout" losses.

🎨 VISUAL INTELLIGENCE
The script features a high-fidelity "Hybrid Visual" interface:

The Gray Consolidation Box: A real-time visual representation of the current "Lookback" range being analyzed.

Expansion Labels: Clean, bold labels ("EXPANSION BUY/SELL") trigger at the exact moment of the volatility breakout.

Static Midline: A bold white axis representing the market's fair-value equilibrium during the consolidation phase.

Aqua/Orange Axis: Real-time tracking of the volatility-adjusted trigger levels.

📊 TECHNICAL SPECIFICATIONS
Strategy Type: Volatility Breakout / Momentum Expansion.

Instruments: Highly optimized for XAU/USD (Gold), BTC/USD, and high-beta Equities.

Timeframe: 15m (Scalp/Intraday) or 1H (Swing).

Execution: Orders utilize process_orders_on_close=true for realistic backtesting and to eliminate "repainting" illusions.

🛠️ HOW TO USE
Identify the Box: Observe the gray consolidation zone. This is where the engine is "Decoding" the current volatility.

Monitor the Triggers: Watch the Aqua (Upper) and Orange (Lower) lines. The closer price gets to these lines, the closer the system is to an "Armed" expansion state.

Risk Calibration: Adjust the Outlier Multiplier (default 1.5). Increase it for highly volatile news events to avoid "whipsaws," or decrease it for tighter, low-volatility sessions.

Target Setting: Set your Target Profit based on your specific asset's average daily range (ADR).

📜 VERSION HISTORY
V1.0 (Current): Initial release of the Decoded Expansion Engine with V6 syntax and hybrid visual labels.

⚖️ DISCLAIMER
This is a quantitative strategy for educational and research purposes. Trading high-volatility assets like Gold or Crypto involves significant risk. Always utilize proper position sizing and risk management.

Author: AHTISHAM_EE
Version: PineScript v6

## Source Code

````pine
//@version=6
strategy("Decoded Volatility Expansion - Visual Pro", overlay=true, 
     initial_capital=10000, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=100)

// ==========================
// 1. INPUTS
// ==========================
lookback = input.int(20, title="Consolidation Lookback")
atrLen   = input.int(14, title="Volatility Length")
atrMult  = input.float(1.5, title="Outlier Multiplier")
rrRatio  = input.float(2.0, title="Risk-Reward Ratio")

// ==========================
// 2. DYNAMIC LEVELS
// ==========================
zoneHigh = ta.highest(high[1], lookback)
zoneLow  = ta.lowest(low[1], lookback)
zoneMid  = (zoneHigh + zoneLow) / 2 
offset   = ta.atr(atrLen) * atrMult

buyStopLevel  = zoneHigh + offset
sellStopLevel = zoneLow  - offset

// ==========================
// 3. SL & TP CALCULATION
// ==========================
float longSL  = zoneMid
float longTP  = buyStopLevel + (math.abs(buyStopLevel - longSL) * rrRatio)

float shortSL = zoneMid
float shortTP = sellStopLevel - (math.abs(sellStopLevel - shortSL) * rrRatio)

// ==========================
// 4. EXECUTION & LABEL LOGIC
// ==========================
// Detect entry for label placement
is_long_entry  = strategy.position_size > 0 and strategy.position_size[1] <= 0
is_short_entry = strategy.position_size < 0 and strategy.position_size[1] >= 0

if strategy.position_size == 0
    strategy.entry("Long", strategy.long, stop=buyStopLevel, comment="EXPANSION UP")
    strategy.entry("Short", strategy.short, stop=sellStopLevel, comment="EXPANSION DOWN")

if strategy.position_size > 0
    strategy.exit("L-Exit", "Long", stop=longSL, limit=longTP, comment_loss="Fakeout", comment_profit="Target Hit")

if strategy.position_size < 0
    strategy.exit("S-Exit", "Short", stop=shortSL, limit=shortTP, comment_loss="Fakeout", comment_profit="Target Hit")

// ==========================
// 5. VISUALS (Hybrid Style)
// ==========================
plot(zoneMid, "Midline Equilibrium", color=color.white, linewidth=2)
plot(buyStopLevel, "Buy Stop Trigger", color=color.aqua, style=plot.style_linebr, linewidth=2)
plot(sellStopLevel, "Sell Stop Trigger", color=color.orange, style=plot.style_linebr, linewidth=2)

// Dynamic Labels (The "Forest" Style)
if is_long_entry
    label.new(bar_index, low, "EXPANSION BUY\n(Breakout)", color=color.green, textcolor=color.white, style=label.style_label_up)

if is_short_entry
    label.new(bar_index, high, "EXPANSION SELL\n(Breakout)", color=color.red, textcolor=color.white, style=label.style_label_down)

// Consolidation Box Visual
var box rangeBox = na
if barstate.islast
    box.delete(rangeBox)
    rangeBox := box.new(bar_index[lookback], zoneHigh, bar_index, zoneLow, 
         bgcolor=color.new(color.gray, 90), border_color=color.new(color.gray, 70))
````
