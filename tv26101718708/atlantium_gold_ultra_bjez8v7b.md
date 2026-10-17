# Atlantium Gold Ultra

- url: https://www.tradingview.com/script/Bjez8v7B/
- type: strategy
- pine_id: PUB;a67f21ff190c4b908507c741be842d61
- version: 12.0

## Description

🚀 Strategy Overview: Atlantium Gold Ultra
Atlantium Gold Ultra is a quantitative trading strategy optimized for capturing mid-to-long-term market trends while maintaining a strict focus on capital preservation. The backtesting results from 2024 to early 2026 demonstrate a consistent upward equity curve with remarkable resilience during market shifts.

📊 Key Performance Metrics
Net Profit: +38.92% ($3,892.21 USD).

Profit Factor: 1.747 (Signifying a strong statistical edge).

Max Drawdown: Only 3.49% ($435.03 USD). This reflects an exceptionally conservative risk profile.

Win Rate: 44.21% (149/337 trades).

Analysis: While the win rate is below 50%, the Profit Factor of 1.747 confirms a high Risk:Reward ratio, where winning trades significantly outweigh losing ones.

🧠 Core Philosophy
The strategy is built on the principle of "cutting losses short and letting winners run." Instead of trying to predict every market micro-movement, it utilizes trend-following logic and volatility filters to ensure entries occur only during high-probability setups.

The most standout feature is the Calmar Ratio (the relationship between return and drawdown). With a return of nearly 40% against a tiny 3.49% drawdown, this strategy is ideal for traders looking for low-stress automation or those managing funded accounts.

🛠 Technical Highlights
Trend Resilience: The equity curve shows an acceleration in performance throughout 2025 and 2026, indicating the strategy thrives in trending environments.

Efficient Recovery: Drawdown periods are shallow and recovery factors are high, minimizing the time the account spends in "the red."

Trade Frequency: With 337 trades over approximately two years, the sample size is statistically significant, reducing the likelihood of "curve fitting."

📈 Suggested Description for TradingView
"I am releasing Atlantium Gold Ultra as an open-source tool for the community. This strategy focuses on trend-following with a heavy emphasis on risk management. By keeping the maximum drawdown under 4%, it provides a stable growth path even during volatile periods. Optimized for [Insert Asset/Timeframe], it is designed to be a robust component of a diversified trading portfolio."

Tip for your post: Since the win rate is 44%, make sure to emphasize that the strategy relies on positive expectancy rather than high accuracy. In the trading world, a low drawdown like yours (3.49%) usually gets a lot of "Boosts" and attention!

## Source Code

````pine
//@version=6
strategy("Atlantium Gold - Safe Trader", 
     overlay=true, 
     initial_capital=1400, 
     default_qty_type=strategy.fixed, 
     default_qty_value=1, 
     margin_long=0, 
     margin_short=0,
     pyramiding=0, 
     commission_type=strategy.commission.cash_per_order, 
     commission_value=0.06)

// --- 1. FILTROS DE TIEMPO (Sin Asia + Cierre Viernes) ---
is_allowed_hour = (hour >= 8 and hour <= 19)
is_friday       = dayofweek == dayofweek.friday
is_weekend_near = is_friday and hour >= 20

// --- 2. FILTRO DE NOTICIAS (Basado en Volatilidad) ---
// Si el rango de la vela actual es 2.5 veces mayor que el promedio, asumimos noticia y no operamos.
atr_fast = ta.atr(5)
atr_slow = ta.atr(20)
news_spike = atr_fast > (atr_slow * 2.5)

// --- 3. CONFIGURACIÓN GANADORA BASE ---
ema_f = ta.ema(close, 10)
ema_s = ta.ema(close, 40)
rsi   = ta.rsi(close, 14)
atr   = ta.atr(14)

// --- 4. LÓGICA DE ENTRADA (Sin Hedge) ---
can_trade = strategy.position_size == 0 and is_allowed_hour and not is_weekend_near and not news_spike

long_cond  = can_trade and ta.crossover(ema_f, ema_s) and rsi > 50
short_cond = can_trade and ta.crossunder(ema_f, ema_s) and rsi < 50

// --- 5. GESTIÓN DE RIESGO Y SALIDAS ---
tp_mult = 5.5 
sl_mult = 2.5

var float sl = na
var float tp = na

if (long_cond)
    sl := close - (atr * sl_mult)
    tp := close + (atr * tp_mult)
    strategy.entry("L", strategy.long, comment='{"action":"buy","lots":0.01}')

if (short_cond)
    sl := close + (atr * sl_mult)
    tp := close - (atr * tp_mult)
    strategy.entry("S", strategy.short, comment='{"action":"sell","lots":0.01}')

// --- 6. CIERRE FORZADO VIERNES 20:00h ---
if (is_weekend_near and strategy.position_size != 0)
    strategy.close_all(comment='{"action":"close","reason":"weekend"}')

// Salida normal por TP/SL
if (strategy.position_size != 0)
    strategy.exit("Exit", stop=sl, limit=tp, comment='{"action":"close"}')

// --- VISUALES ---
bgcolor(is_weekend_near ? color.new(color.orange, 80) : na, title="Cierre Viernes")
bgcolor(news_spike ? color.new(color.red, 80) : na, title="Filtro Noticia")
plot(ema_f, color=color.aqua)
plot(ema_s, color=color.white, linewidth=2)
````
