# AXIS REVERSAL

- url: https://www.tradingview.com/script/ZyJPE4QX-AXIS-REVERSAL/
- type: strategy
- pine_id: PUB;e96e3273c7e74757b66c2ffae680afc6
- version: 1.0

## Description

AXIS REVERSAL is a high-precision trading strategy engineered to identify critical market pivot points. The algorithm combines dynamic liquidity tracking (Axis Levels) with noise filtration through an adaptive Supertrend and RSI synchronization.

⚡ The Core Logic
The strategy operates on the "coiled spring" principle. It identifies zones where the price has overextended from its equilibrium and is primed for a sharp mean reversion.

Axis Detection: The algorithm continuously scans the market for new local highs and lows (Highest/Lowest) with adjustable sensitivity.

Strike Zones: When a key level is breached but the momentum begins to fade, the strategy enters "Active Standby" mode (visualized as Neon Strike Lines).

RSI Synchronization: Entry only occurs when the oscillator confirms an overbought or oversold state within a specific lookback window.

Trend Confirmation: The final trigger is pulled only upon a directional shift in the adaptive Supertrend, minimizing the risk of "falling knife" entries.

🎨 Cyber-Interface Visualization
We have designed a unique Cyber-Interface to provide full transparency into the algorithm's decision-making process:

✦ (Diamond Icon): Long Entry signal.

⊕ (Crosshair Icon): Short Entry signal.

Neon Strike Lines: Dynamic horizontal levels tracked by the Axis engine. When a line appears, the strategy is "loaded" and ready to trade.

Smart Background: Subtle background tints indicate RSI readiness phases.

⚙️ Risk Management & Parameters
Sensitivity: Controls the depth of the Axis level search. Higher values target global macro-reversals; lower values target local scalping opportunities.

ATR Integration: Automatically adjusts to current market volatility.

Execution Engine: Pre-set with professional-grade Take Profit and Stop Loss parameters to maintain a positive mathematical expectancy.

📈 Trading Recommendations
Timeframes: Optimized for 15m, 1h, and 4h charts.

Leverage: Designed for 1:10 leverage (Margin is set to 10% in properties).

Assets: Highly effective on BTC, ETH, and volatile Altcoin pairs.

Disclaimer: Past performance does not guarantee future results. Always backtest thoroughly before deploying capital on a live account.

Tips for Publication:
Tags: Use Reversal, RSI, Supertrend, MeanReversion, Crypto.

## Source Code

````pine
//@version=5
strategy("AXIS REVERSAL", 
     overlay=true, 
     initial_capital=1000, 
     default_qty_type=strategy.cash, 
     default_qty_value=1000, 
     pyramiding=1, 
     commission_type=strategy.commission.percent, 
     commission_value=0.05,
     margin_long=10.0,
     margin_short=10.0)

// --- Настройки ---
sens = input.int(50, 'Sensitivity')
p    = input.int(10, 'ATR Period')
m    = input.float(2.0, 'ATR Mult')
tp_p = input.float(1.5, "Take Profit %") / 100
sl_p = input.float(1.0, "Stop Loss %") / 100

// --- Математика AXIS ---
rsi = ta.rsi(close, 14)
step = math.max(1, int(sens / 10)) 

atr = ta.atr(p)
var float up = na
var float dn = na
var int trend = 1
up := close[1] > up[1] ? math.max(hl2 - m * atr, up[1]) : hl2 - m * atr
dn := close[1] < dn[1] ? math.min(hl2 + m * atr, dn[1]) : hl2 + m * atr
trend := trend == -1 and close > dn[1] ? 1 : trend == 1 and close < up[1] ? -1 : trend

rsi_dn_zone = ta.barssince(rsi < 30) < 10
rsi_up_zone = ta.barssince(rsi > 70) < 10

// Логика уровней-осей
hi_level = ta.highest(sens)
var int hi_active = 0
if hi_level != hi_level[step] and close > hi_level[step]
    hi_active := 1
if trend == -1 and trend[1] == 1
    hi_active := 0

lo_level = ta.lowest(sens)
var int lo_active = 0
if lo_level != lo_level[step] and close < lo_level[step]
    lo_active := 1
if trend == 1 and trend[1] == -1
    lo_active := 0

var int t_sw = 0
t_sw := (trend == -1 and trend[1] == 1) ? 0 : hi_active != 0 and trend == 1 ? 1 : t_sw[1]
rev_s = t_sw[1] == 1 and t_sw == 0 and rsi_up_zone

var int b_sw = 0
b_sw := (trend == 1 and trend[1] == -1) ? 0 : lo_active != 0 and trend == -1 ? 1 : b_sw[1]
rev_b = b_sw[1] == 1 and b_sw == 0 and rsi_dn_zone

// --- Визуал "AXIS INTERFACE" ---
plot(hi_active ? hi_level : na, color=color.new(#ff0055, 30), style=plot.style_linebr, linewidth=2, title="AXIS High")
plot(lo_active ? lo_level : na, color=color.new(#00ffcc, 30), style=plot.style_linebr, linewidth=2, title="AXIS Low")

// Уникальные маркеры (✦ Diamond / ⊕ Crosshair)
plotchar(rev_b, "B", "✦", location.belowbar, color=#00ffcc, size=size.normal)
plotchar(rev_s, "S", "⊕", location.abovebar, color=#ff0055, size=size.normal)

// Подсветка зоны входа
bgcolor(rev_b ? color.new(#00ffcc, 85) : rev_s ? color.new(#ff0055, 85) : na)

// --- Исполнение ---
if rev_b
    strategy.entry("Long", strategy.long)

if rev_s
    strategy.entry("Short", strategy.short)

// Выход с четкими брендированными метками
strategy.exit("ExL", "Long", 
     stop=strategy.position_avg_price * (1 - sl_p), 
     limit=strategy.position_avg_price * (1 + tp_p), 
     comment_loss="[AXIS-SL]", 
     comment_profit="[AXIS-TP]")

strategy.exit("ExS", "Short", 
     stop=strategy.position_avg_price * (1 + sl_p), 
     limit=strategy.position_avg_price * (1 - tp_p), 
     comment_loss="[AXIS-SL]", 
     comment_profit="[AXIS-TP]")
````
