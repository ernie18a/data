# OI+CVD+Ichimoku PRO Strategy

- url: https://www.tradingview.com/script/6NrWx3Fi-OI-CVD-Ichimoku-PRO-Strategy/
- type: strategy
- pine_id: PUB;3ed830ebae03480286fc68c2fb17a4c5
- version: 2.0

## Description

OI+CVD+Ichimoku PRO Strategy is a comprehensive trading system that combines classic trend-following mechanics with real-time institutional Order Flow analysis. This strategy is designed to filter out market noise and capture high-probability momentum moves by validating technical crossovers with actual market money flow.

💡 Core Concept
The strategy operates on a three-tier confirmation system:

Trend Cloud (EMA Cloud): Utilizes a fast and slow EMA (default 13/25) to create a visual "cloud." This indicates the primary momentum; price above the cloud suggests a bullish bias, while price below suggests a bearish bias.

Order Flow Filter (OI + CVD): This is the engine of the strategy. It monitors the Open Interest (OI) and Cumulative Volume Delta (CVD) from the exchange. By requiring a positive/negative threshold for these metrics, the strategy ensures that price breakouts are backed by actual capital inflows, significantly reducing false signals in sideways markets.

Adaptive Risk Management: Features an integrated exit system with support for both ATR-based (volatility-adjusted) and fixed-percentage Stop Losses. It also supports tiered Take Profit levels (TP1/TP2) to allow for partial profit-taking.

⚙️ Customizable Settings
Users have full control over the strategy via the settings panel:

EMA Settings: Customize the speed of the trend cloud to suit your timeframe.

Order Flow Settings: Fine-tune the OI Min Change Threshold and CVD Smoothing Period to filter out weak volatility and focus only on significant market moves.

Stop Loss & Take Profit: Choose between ATR-based (dynamic) or fixed (%) stops. Configure 1 or 2 Take Profit levels to automate your trade management.

🚀 Key Advantages
Clean Visualization: Real-time plotting of entry points, Stop Loss levels, and multiple Take Profit targets directly on your chart.

Data-Driven Entries: Avoids "fakeouts" by requiring institutional participation (OI/CVD confirmation) alongside technical crossovers.

Versatility: Perfectly suited for high-liquidity crypto futures markets (e.g., BTC/USDT) where Open Interest data is available.

📖 How to Use
Add the strategy to your chart.

Adjust the OI Threshold in the settings to filter out minor market fluctuations based on your preferred asset's volatility.

Monitor the EMA Cloud color: Blue indicates a bullish trend, Red indicates a bearish trend.

Only enter positions when the EMA crossover aligns with the Order Flow filter status.

Disclaimer: This tool is for educational purposes only. Trading financial markets involves high risk. Always backtest strategies on historical data and manage your risk carefully before using them on a live account.

Pro-Tips for your TradingView publication:
Visual Proof: Include a screenshot of the strategy showing a clear trend where the Order Flow filter successfully blocked a false signal.

Tags: Use relevant tags like: #trendfollowing #orderflow #openinterest #cvd #ichimoku #cryptotrading #futures #algoritmictrading #momentum #btc

Recommended Timeframes: Mention that this strategy works best on 5m, 15m, or 1h timeframes for the best balance between signal frequency and accuracy.

## Source Code

````pine
//@version=6
strategy("OI+CVD+Ichimoku PRO Strategy", overlay = true, initial_capital = 1000, default_qty_type = strategy.percent_of_equity, default_qty_value = 10)

// --- НАСТРОЙКИ EMA ---
grp_ma = "EMA Settings"
len1 = input.int(13, "EMA 1 (Fast)", group=grp_ma)
len2 = input.int(25, "EMA 2 (Slow)", group=grp_ma)

// --- НАСТРОЙКИ ORDER FLOW ---
grp_of = "Order Flow Settings"
oi_thresh = input.float(0, "OI Min Change Threshold", step=100, group=grp_of)
cvd_len = input.int(14, "CVD Smoothing Period", group=grp_of)

// --- НАСТРОЙКИ ICHIMOKU ---
grp_ichi = "Ichimoku Settings"
use_ichimoku_filter = input.bool(true, "Use Ichimoku Cloud as trend filter?", group=grp_ichi)
tenkanLen = input.int(9, "Tenkan-sen Length", group=grp_ichi)
kijunLen = input.int(26, "Kijun-sen Length", group=grp_ichi)
senkouBLen = input.int(52, "Senkou Span B Length", group=grp_ichi)
displacement = input.int(26, "Cloud Displacement", group=grp_ichi)

// --- НАСТРОЙКИ СТОП-ЛОСС ---
grp_sl = "Stop Loss Settings"
use_atr_sl = input.bool(true, "Use ATR for SL?", group=grp_sl)
sl_fixed = input.float(1.5, "Fixed SL (%)", step=0.1, group=grp_sl)
sl_atr_mult = input.float(1.5, "ATR Multiplier for SL", step=0.1, group=grp_sl)

// --- НАСТРОЙКИ ТЕЙК-ПРОФИТ ---
grp_tp = "Take Profit Settings"
tp_count = input.int(2, "Number of TPs (1 or 2)", minval=1, maxval=2, group=grp_tp)
tp1_mult = input.float(1.5, "TP 1 (ATR Multiplier)", group=grp_tp)
tp2_mult = input.float(3.0, "TP 2 (ATR Multiplier)", group=grp_tp)

// --- РАСЧЕТЫ EMA/ATR/ORDER FLOW ---
ema1 = ta.ema(close, len1)
ema2 = ta.ema(close, len2)
atr = ta.atr(14)
[oid, oi] = request.security(syminfo.ticker + ".P_OI", timeframe.period, [close - close[1], close], ignore_invalid_symbol = true)
cvd = ta.ema(volume * (close > open ? 1 : -1), cvd_len)

// --- РАСЧЕТЫ ICHIMOKU ---
tenkan  = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
kijun   = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2
senkouA = (tenkan + kijun) / 2
senkouB = (ta.highest(high, senkouBLen) + ta.lowest(low, senkouBLen)) / 2

// облако, которое реально видно на текущем баре, было посчитано displacement баров назад
cloudTopNow = math.max(senkouA[displacement], senkouB[displacement])
cloudBotNow = math.min(senkouA[displacement], senkouB[displacement])

ichimoku_bullish = not use_ichimoku_filter or close > cloudTopNow
ichimoku_bearish = not use_ichimoku_filter or close < cloudBotNow

// --- ЛОГИКА ФИЛЬТРА ---
filter_bullish = (nz(oid, 0) > oi_thresh or cvd > 0) and ichimoku_bullish
filter_bearish = (nz(oid, 0) < -oi_thresh or cvd < 0) and ichimoku_bearish

longCondition  = ta.crossover(ema1, ema2) and filter_bullish
shortCondition = ta.crossunder(ema1, ema2) and filter_bearish

// --- ИСПОЛНЕНИЕ СДЕЛОК ---
var float sl_level = na
var float tp1_level = na
var float tp2_level = na

if longCondition
    sl_level := close - (use_atr_sl ? (atr * sl_atr_mult) : (close * sl_fixed/100))
    tp1_level := close + (atr * tp1_mult)
    tp2_level := close + (atr * tp2_mult)
    strategy.entry("Long", strategy.long)

if shortCondition
    sl_level := close + (use_atr_sl ? (atr * sl_atr_mult) : (close * sl_fixed/100))
    tp1_level := close - (atr * tp1_mult)
    tp2_level := close - (atr * tp2_mult)
    strategy.entry("Short", strategy.short)

// --- ВИЗУАЛИЗАЦИЯ (EMA ОБЛАКО) ---
plot(ema1, color=color.blue, title="EMA Fast")
plot(ema2, color=color.fuchsia, title="EMA Slow")
fill(plot(ema1), plot(ema2), color = ema1 > ema2 ? color.new(color.blue, 80) : color.new(color.red, 80), title="EMA Cloud")

// --- ВИЗУАЛИЗАЦИЯ (НАСТОЯЩЕЕ ОБЛАКО ИШИМОКУ, СО СДВИГОМ ВПЕРЁД) ---
spanA = plot(senkouA, title="Senkou Span A", color=color.new(color.green, 60), offset=displacement)
spanB = plot(senkouB, title="Senkou Span B", color=color.new(color.red, 60), offset=displacement)
fill(spanA, spanB, color = senkouA > senkouB ? color.new(color.green, 90) : color.new(color.red, 90), title="Kumo Cloud")
plot(tenkan, title="Tenkan-sen", color=color.new(color.orange, 40))
plot(kijun, title="Kijun-sen", color=color.new(color.navy, 40))

plot(strategy.position_size != 0 ? sl_level : na, "SL Level", color=color.red, style=plot.style_linebr, linewidth=2)
plot(strategy.position_size != 0 ? tp1_level : na, "TP1 Level", color=color.green, style=plot.style_linebr, linewidth=2)
plot(strategy.position_size != 0 and tp_count == 2 ? tp2_level : na, "TP2 Level", color=color.olive, style=plot.style_linebr, linewidth=2)

// --- ВЫХОДЫ ---
strategy.exit("Exit TP1", "Long", qty_percent=50, limit=tp1_level, stop=sl_level)
strategy.exit("Exit TP2", "Long", qty_percent=100, limit=tp2_level, stop=sl_level)
strategy.exit("Exit TP1", "Short", qty_percent=50, limit=tp1_level, stop=sl_level)
strategy.exit("Exit TP2", "Short", qty_percent=100, limit=tp2_level, stop=sl_level)
````
