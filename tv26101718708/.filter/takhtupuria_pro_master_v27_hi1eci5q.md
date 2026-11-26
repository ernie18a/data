# Takhtupuria Pro master  V2..7

- url: https://www.tradingview.com/script/Hi1eCI5Q-Takhtupuria-Pro-master-V2-7/
- type: indicator
- pine_id: PUB;b84239624fda4a0584cd586376882ef5
- version: 1.0

## Description

Takhtupuria Pro V2
The Takhtupuria Pro V2 is an advanced, all-in-one trading indicator designed for precision scalping and trend-following. By integrating Golden Ratio logic, EMA crossovers, and Fibonacci levels, this tool provides a comprehensive system for modern traders.
Key Features:
 Golden Ratio Signals: Integrated logic to identify potential "Golden Ratio" setups for both standard and reversed market trends.
 Scalping Precision: Features a high-speed 5 EMA + 200 EMA trigger system, optimized for rapid scalping execution.
 Fibonacci Integration: Automatic plotting of key Fibonacci levels (Top, Mid, Bottom) to identify support and resistance zones instantly.
 Advanced Filters: Includes customizable distance (%) and candle-count settings to ensure high-probability entry points.
 Visual Signals: Automated Buy/Sell arrows with configurable visual alerts for real-time decision-making.
How to Use:
 Inputs: Adjust your "Distance %" and "Candle Count" to calibrate the sensitivity of the scalping system to your specific asset.
 Fibonacci: Set your preferred Fibonacci Timeframe (e.g., 15 minutes) to align with your overall strategy.
 Style: Fully customize the colors for EMA lines, Fib levels, and signal arrows to match your chart's unique layout.
Designed by Takhtupuria for traders who require a multi-layered analytical approach in a single, powerful tool.

## Source Code

````pine
//@version=5
indicator("ਤਖਤੂਪੁਰੀਆ ਪ੍ਰੋ ਮਾਸਟਰ V2 (Takhtupuria Pro V2)", overlay=true)

// ==========================================
// 1. ਕੰਟਰੋਲ ਪੈਨਲ (Inputs & Customization)
// ==========================================
gp_switches = "ਸਿਗਨਲ ਸਵਿੱਚਾਂ (On/Off)"
show_mid_dir  = input.bool(true, title="ਗੋਲਡਨ ਰੇਸ਼ੀਓ - ਸਿੱਧਾ ਸਿਗਨਲ", group=gp_switches)
show_mid_rev  = input.bool(false, title="ਗੋਲਡਨ ਰੇਸ਼ੀਓ - ਉਲਟ (ਪੁੱਠਾ) ਸਿਗਨਲ", group=gp_switches)
show_ext_scalp = input.bool(true, title="200 EMA + 5 EMA ਪ੍ਰੋ ਸਕੈਲਪਿੰਗ ਸਿਗਨਲ", group=gp_switches)

gp_scalp_set = "⚙️ 5 EMA + 200 EMA ਸੈਟਿੰਗਜ਼"
ema_fast_len = input.int(5, title="Fast EMA Length (Trigger)", group=gp_scalp_set)
ema_slow_len = input.int(200, title="Slow EMA Length (Trend)", group=gp_scalp_set)
ext_percent  = input.float(90.0, title="200 EMA ਤੋਂ ਦੂਰੀ (Distance %)", minval=1.0, maxval=100.0, group=gp_scalp_set) / 100.0
req_candles  = input.int(2, title="ਕਿੰਨੀਆਂ ਕੈਂਡਲਾਂ ਕਲੋਜ਼ ਚਾਹੀਦੀਆਂ ਨੇ?", minval=1, maxval=5, group=gp_scalp_set)

gp_fib = "📐 ਫਿਬੋਨਾਚੀ ਸੈਟਿੰਗ"
fib_tf = input.timeframe("15", title="Fibonacci Timeframe", group=gp_fib)

// ==========================================
// 2. ਕੈਲਕੂਲੇਸ਼ਨ (EMA, FIB & DISTANCE)
// ==========================================
ema_5   = ta.ema(close, ema_fast_len)
ema_200 = ta.ema(close, ema_slow_len)

// 15-ਮਿੰਟ ਫਿਬੋਨਾਚੀ ਲੈਵਲਸ
h_high = request.security(syminfo.tickerid, fib_tf, ta.highest(high, 20)[1], lookahead=barmerge.lookahead_on)
l_low  = request.security(syminfo.tickerid, fib_tf, ta.lowest(low, 20)[1], lookahead=barmerge.lookahead_on)
r_range = h_high - l_low

fib_100 = h_high
fib_500 = h_high - (r_range * 0.500)
fib_000 = l_low

// 200 EMA ਤੋਂ ਦੂਰੀ ਦਾ ਲੌਜਿਕ (Fibonacci Range ਦੇ ਮੁਤਾਬਕ)
dist_threshold = r_range * ext_percent
is_over_extended_high = (high - ema_200) >= dist_threshold
is_over_extended_low  = (ema_200 - low) >= dist_threshold

// ਲਾਈਨਾਂ ਪਲਾਟ ਕਰਨਾ (ਇਹਨਾਂ ਦੇ ਰੰਗ ਸੈਟਿੰਗਜ਼ 'ਚੋਂ ਵੀ ਬਦਲੇ ਜਾ ਸਕਦੇ ਹਨ)
plot(ema_5, color=color.orange, title="5 EMA Line", linewidth=1)
plot(ema_200, color=color.purple, title="200 EMA Trend Line", linewidth=2)
plot(fib_100, color=color.red, title="Fib Top (1.000)")
plot(fib_500, color=color.blue, title="Golden Mid (0.500)", linewidth=2)
plot(fib_000, color=color.green, title="Fib Bottom (0.000)")

// ==========================================
// 3. ਲਗਾਤਾਰ ਕੈਂਡਲਾਂ ਦੀ ਕੰਡੀਸ਼ਨ (Candle Count Filter)
// ==========================================
// ਪਿਛਲੀਆਂ ਕੈਂਡਲਾਂ ਪੂਰੀ ਤਰ੍ਹਾਂ ਕਲੋਜ਼ (Index 1, 2, 3...) ਹੋਣੀਆਂ ਚਾਹੀਦੀਆਂ ਹਨ
buy_candle_cond = true
sell_candle_cond = true

for i = 1 to req_candles
    if close[i] <= open[i] or close[i] <= ema_5[i]
        buy_candle_cond := false
    if close[i] >= open[i] or close[i] >= ema_5[i]
        sell_candle_cond := false

// ==========================================
// 4. ਸਿਗਨਲ ਲੌਜਿਕ (Signals)
// ==========================================
var bool buy_sig = false
var bool sell_sig = false
buy_sig := false
sell_sig := false

c_close = close[1]
c_open  = open[1]

// A. 200 EMA + 5 EMA ਪ੍ਰੋ ਸਕੈਲਪਿੰਗ ਸਿਗਨਲ (ਜਦੋਂ ਮਾਰਕੀਟ ਬਹੁਤ ਦੂਰ ਹੋਵੇ)
if show_ext_scalp
    if is_over_extended_low[1] and buy_candle_cond
        buy_sig := true
    if is_over_extended_high[1] and sell_candle_cond
        sell_sig := true

// B. ਮਿਡਲ ਪਾਰਟ (Golden Ratio) ਲੌਜਿਕ
is_bullish = c_close > ema_200
is_bearish = c_close < ema_200

if show_mid_dir
    if ta.crossover(c_close, fib_500) and is_bullish
        buy_sig := true
    if ta.crossunder(c_close, fib_500) and is_bearish
        sell_sig := true

if show_mid_rev
    if ta.crossunder(c_close, fib_500) and c_open > fib_500 and is_bullish
        buy_sig := true
    if ta.crossover(c_close, fib_500) and c_open < fib_500 and is_bearish
        sell_sig := true

// ਚਾਰਟ 'ਤੇ ਸਾਫ਼ ਅਤੇ ਪੱਕੇ ਤੀਰ (Arrows) ਦਿਖਾਉਣਾ
plotshape(buy_sig, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Buy Arrow")
plotshape(sell_sig, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Sell Arrow")

// ==========================================
// 5. ਸਿੰਗਲ ਮਾਸਟਰ ਅਲਰਟ (100% ਨੋ-ਐਰਰ)
// ==========================================
alert_condition = (buy_sig or sell_sig) and barstate.isconfirmed
alert_msg = "ਤਖਤੂਪੁਰੀਆ PRO ਸਿਗਨਲ! ਲਾਈਵ ਭਾਅ: {{close}}"

alertcondition(alert_condition, title="ਤਖਤੂਪੁਰੀਆ ਮਾਸਟਰ ਅਲਰਟ", message=alert_msg)
````
