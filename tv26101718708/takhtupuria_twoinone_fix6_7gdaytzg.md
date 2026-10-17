# Takhtupuria Two-In-One Fix..6

- url: https://www.tradingview.com/script/7GDaytZG-Takhtupuria-Two-In-One-Fix-6/
- type: indicator
- pine_id: PUB;5850dc8d2a5b451ab810940934e15002
- version: 1.0

## Description

Takhtupuria Two-In-One Fix
This indicator is a powerful, dual-purpose trading solution that combines advanced Crossover Filtering and Reversal Signal detection into a single, seamless workspace. Designed to eliminate market noise, it helps traders focus on high-probability setups.
Key Features:
 Intelligent Crossover Filter: Features a built-in "Sideways Filter" that identifies consolidation zones, preventing premature entries during non-trending markets.
 Precision Reversal System: Includes a customizable "Reversal Filter" that tracks distance from the 200 EMA to spot potential exhaustion and reversal points.
 Visual Customization: Full control over Fast and Slow Moving Averages, with adjustable signal types (EMA/SMA).
 Clear Signals: Automated Buy and Sell arrows plotted directly on the chart, complete with visual zones for trend guidance.
How to Use:
 Inputs: Fine-tune your "Sideways %" and "Reversal Distance %" to match the volatility of the asset you are trading.
 Style: Easily toggle zones, labels, and arrows to keep your chart optimized for your specific strategy.
 Strategy: Best used for identifying breakout opportunities while avoiding traps in flat markets.
Designed by Takhtupuria to provide clarity and technical edge in any market condition.

## Source Code

````pine
//@version=5
indicator("ਤਖਤੂਪੁਰੀਆ ਟੂ-ਇਨ-ਵਨ ਫਿਕਸ (Takhtupuria Two-In-One Fix)", overlay=true)

// ==========================================
// 1. ਕੰਟਰੋਲ ਪੈਨਲ (Inputs & On/Off Switches)
// ==========================================
gp_main = "⚙️ ਮੂਵਿੰਗ ਐਵਰੇਜ ਸੈਟਿੰਗਜ਼"
fast_type   = input.string("EMA", title="Fast Line Type", options=["EMA", "SMA"], group=gp_main)
fast_length = input.int(5, title="Fast Line Length", group=gp_main)
slow_type   = input.string("EMA", title="Slow Line Type", options=["EMA", "SMA"], group=gp_main)
slow_length = input.int(200, title="Slow Line Length", group=gp_main)

gp_engine1 = "🛑 ਇੰਜਣ 1: ਨੇੜੇ ਵਾਲਾ ਸਾਈਡਵੇਅ ਫਿਲਟਰ (Crossover)"
use_sideways_filter = input.bool(true, title="ਸਾਈਡਵੇਅ ਫਿਲਟਰ ਆਨ ਕਰੋ [On/Off]", group=gp_engine1)
sideways_percent    = input.float(0.05, title="ਨੇੜੇ ਵਾਲਾ ਦਾਇਰਾ % (Sideways %)", step=0.01, group=gp_engine1)
confirm_candles     = input.int(1, title="ਕ੍ਰਾਸਓਵਰ ਤੋਂ ਬਾਅਦ ਕੈਂਡਲ ਕਲੋਜ਼ (0-5)", minval=0, maxval=5, group=gp_engine1)

gp_engine2 = "🎯 ਇੰਜਣ 2: ਦੂਰ ਵਾਲਾ ਰੀਵਰਸਲ ਫਿਲਟਰ (Reversal)"
use_reversal_filter = input.bool(true, title="ਦੂਰ ਵਾਲਾ ਰੀਵਰਸਲ ਸਿਗਨਲ ਆਨ ਕਰੋ [On/Off]", group=gp_engine2)
reversal_percent    = input.float(0.50, title="200 EMA ਤੋਂ ਦੂਰੀ %", step=0.05, group=gp_engine2)

// ਮੂਵਿੰਗ ਐਵਰੇਜ ਫੰਕਸ਼ਨ
get_ma(ma_type, len) =>
    ma_type == "EMA" ? ta.ema(close, len) : ta.sma(close, len)

// ==========================================
// 2. ਲਾਈਨਾਂ ਦੀ ਕੈਲਕੂਲੇਸ਼ਨ
// ==========================================
fast_ma = get_ma(fast_type, fast_length)
slow_ma = get_ma(slow_type, slow_length)

// ਇੰਜਣ 1: ਨੇੜੇ ਵਾਲਾ ਸਾਈਡਵੇਅ ਦਾਇਰਾ
zone_buffer = slow_ma * (sideways_percent / 100.0)
upper_sideways = slow_ma + zone_buffer
lower_sideways = slow_ma - zone_buffer

// ਇੰਜਣ 2: ਦੂਰ ਵਾਲਾ ਰੀਵਰਸਲ ਦਾਇਰਾ
rev_buffer = slow_ma * (reversal_percent / 100.0)
upper_reversal = slow_ma + rev_buffer
lower_reversal = slow_ma - rev_buffer

// ਚਾਰਟ 'ਤੇ ਲਾਈਨਾਂ ਪਲਾਟ ਕਰਨਾ
plot(fast_ma, color=color.orange, title="Fast MA (5)", linewidth=1)
plot(slow_ma, color=color.purple, title="Slow MA (200)", linewidth=2)

// ਸਾਈਡਵੇਅ ਅਤੇ ਰੀਵਰਸਲ ਲਾਈਨਾਂ (No Error Version)
plot(use_sideways_filter ? upper_sideways : na, color=color.gray, title="Sideways Top")
plot(use_sideways_filter ? lower_sideways : na, color=color.gray, title="Sideways Bottom")
plot(use_reversal_filter ? upper_reversal : na, color=color.red, title="Reversal Top Zone")
plot(use_reversal_filter ? lower_reversal : na, color=color.green, title="Reversal Bottom Zone")

// ==========================================
// 3. ਸਿਗਨਲ ਲੌਜਿਕ (Signals)
// ==========================================
var bool buy_sig = false
var bool sell_sig = false
buy_sig := false
sell_sig := false

// --- [ਲੌਜਿਕ 1: ਕ੍ਰਾਸਓਵਰ ਸਿਗਨਲ] ---
is_cross_up   = use_sideways_filter ? ta.crossover(fast_ma, upper_sideways) : ta.crossover(fast_ma, slow_ma)
is_cross_down = use_sideways_filter ? ta.crossunder(fast_ma, lower_sideways) : ta.crossunder(fast_ma, slow_ma)

get_confirmed_signal(is_cross_event, count) =>
    result = false
    if count == 0
        result := is_cross_event
    else
        result := is_cross_event[count]
    result

cross_buy  = get_confirmed_signal(is_cross_up, confirm_candles)
cross_sell = get_confirmed_signal(is_cross_down, confirm_candles)

if cross_buy
    buy_sig := true
if cross_sell
    sell_sig := true

// --- [ਲੌਜਿਕ 2: ਦੂਰ ਵਾਲਾ ਰੀਵਰਸਲ ਸਿਗਨਲ] ---
if use_reversal_filter
    if fast_ma[2] < lower_reversal[2] and ta.crossover(fast_ma, fast_ma[1])
        buy_sig := true
    if fast_ma[2] > upper_reversal[2] and ta.crossunder(fast_ma, fast_ma[1])
        sell_sig := true

// ਚਾਰਟ 'ਤੇ ਸਾਫ਼ ਤੀਰ (Arrows) ਦਿਖਾਉਣਾ
plotshape(buy_sig, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Buy Arrow")
plotshape(sell_sig, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Sell Arrow")

// ==========================================
// 4. ਇੱਕੋ ਮਾਸਟਰ ਅਲਰਟ ਸਿਸਟਮ (ਕੈਂਡਲ ਕਲੋਜ਼ 'ਤੇ)
// ==========================================
alert_condition = (buy_sig or sell_sig) and barstate.isconfirmed
alert_msg = "ਤਖਤੂਪੁਰੀਆ ਮਾਸਟਰ ਸਿਗਨਲ! ਲਾਈਵ ਭਾਅ: {{close}}"

alertcondition(alert_condition, title="ਤਖਤੂਪੁਰੀਆ ਮਾਸਟਰ ਅਲਰਟ", message=alert_msg)
````
