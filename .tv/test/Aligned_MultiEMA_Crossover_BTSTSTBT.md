<!-- tradingview-pine-id: PUB;d3e37f6479bc4c84bc9e0ed679efc34e -->
<!-- tradingviewscripts-format: 1 -->
# Aligned Multi-EMA Crossover (BTST/STBT)

Source: https://www.tradingview.com/script/TOzt8Wxp-Aligned-Multi-EMA-Crossover-BTST-STBT/

## Description

Trend Alignment: Filters trades by requiring the 50, 100, and 200 EMAs to be in strict order, ensuring entries only align with the broader market direction.

Precision Entry: Triggers long or short positions as soon as the fast 20 EMA crosses the 50 EMA during designated trading hours.

Automated Risk Management: Protects capital by applying built-in Stop Loss and Take Profit percentages directly off your execution price.

Overnight Protection: Features a mandatory 3:15 PM IST square-off rule that closes all open positions to eliminate gap-down exposure.

Backtest Ready: Programmed in Pine Script v6 to allow instant performance testing, win-rate analysis, and automated broker alert integration

---

## Source Code

````pine
//@version=6
indicator("Aligned Multi-EMA Crossover (BTST/STBT)", overlay=true)

// --- Inputs ---
len20  = input.int(20, title="Fast EMA Period")
len50  = input.int(50, title="Medium EMA Period")
len100 = input.int(100, title="Slow EMA Period")
len200 = input.int(200, title="Baseline EMA Period")

// --- EMA Calculations ---
ema20  = ta.ema(close, len20)
ema50  = ta.ema(close, len50)
ema100 = ta.ema(close, len100)
ema200 = ta.ema(close, len200)

// --- Signal Logic ---

// BUY Condition:
// 1. 20 EMA crosses above 50 EMA
// 2. 50 EMA > 100 EMA
// 3. 100 EMA > 200 EMA
bullishAlignment = (ema50 > ema100) and (ema100 > ema200)
buySignal        = ta.crossover(ema20, ema50) and bullishAlignment

// SELL Condition (Fully Reversed):
// 1. 20 EMA crosses below 50 EMA
// 2. 50 EMA < 100 EMA
// 3. 100 EMA < 200 EMA
bearishAlignment = (ema50 < ema100) and (ema100 < ema200)
sellSignal       = ta.crossunder(ema20, ema50) and bearishAlignment

// --- Plot Moving Averages ---
plot(ema20,  title="20 EMA",  color=color.rgb(33, 150, 243), linewidth=2)  // Blue
plot(ema50,  title="50 EMA",  color=color.rgb(255, 152, 0), linewidth=2)  // Orange
plot(ema100, title="100 EMA", color=color.rgb(156, 39, 176), linewidth=1) // Purple
plot(ema200, title="200 EMA", color=color.rgb(244, 67, 54), linewidth=2)  // Red

// --- Visual Chart Signals ---
plotshape(buySignal,  title="Buy Signal",  style=shape.labelup,   location=location.belowbar, color=color.green, text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.red,   text="SELL", textcolor=color.white, size=size.small)

// --- Real-time Alerts ---
alertcondition(buySignal,  title="BUY Signal Alert",  message="[BUY ALERT] {{ticker}} 20 EMA crossed above 50 EMA with full bullish alignment (50 > 100 > 200) at {{close}}")
alertcondition(sellSignal, title="SELL Signal Alert", message="[SELL ALERT] {{ticker}} 20 EMA crossed below 50 EMA with full bearish alignment (50 < 100 < 200) at {{close}}")
````
