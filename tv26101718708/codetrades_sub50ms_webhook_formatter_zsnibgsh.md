# CodeTrades Sub-50ms Webhook Formatter

- url: https://www.tradingview.com/script/zsnIBgsH-CodeTrades-Sub-50ms-Webhook-Formatter/
- type: indicator
- pine_id: PUB;ca3176be281f4594b97e2b6508376001
- version: 1.0

## Description

Most Indian F&O traders bleed capital because they route TradingView webhooks through third-party servers (Zapier/Make), introducing 1.5s+ of queuing latency during breakouts.

This script formats the exact, strict JSON payload required to bypass those third-party queues. It is designed to be routed directly into a localized Python Flask middleware utilizing a Pandas RAM-cache for O(1) memory lookups. This drops your execution latency to sub-50ms and entirely eliminates DH-905 rejection errors on Dhan and Zerodha.

You can download the mandatory backend Python infrastructure to run this script for free on my GitHub: https://github.com/codetradesalgo-cmyk/dhan-api-tradingview-webhook-python

## Source Code

````pine
//@version=6
indicator("CodeTrades - Institutional Webhook Formatter", overlay=true)

// --- Structural Overview ---
// This script provides a baseline momentum trigger (9/21 EMA) but is specifically 
// engineered to format the strict JSON payload required by the CodeTrades 
// localized Python RAM-Cache engine to bypass API slippage.

float fast_ema = ta.ema(close, 9)
float slow_ema = ta.ema(close, 21)

plot(fast_ema, color=color.blue, title="Fast EMA")
plot(slow_ema, color=color.red, title="Slow EMA")

bool long_cond = ta.crossover(fast_ema, slow_ema)
bool short_cond = ta.crossunder(fast_ema, slow_ema)

// --- Dynamic JSON Payload Construction ---
// Bypassing str.format() to prevent TradingView compiler errors.
// Using explicit string concatenation and type declarations for v6 stability.
build_payload(string action) =>
    '{"symbol": "' + syminfo.ticker + '", "action": "' + action + '", "price": ' + str.tostring(close) + '}'

if long_cond
    alert(build_payload("BUY"), alert.freq_once_per_bar_close)

if short_cond
    alert(build_payload("SELL"), alert.freq_once_per_bar_close)
````
