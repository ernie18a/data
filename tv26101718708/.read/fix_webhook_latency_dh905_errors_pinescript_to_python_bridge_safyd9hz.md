# Fix Webhook Latency & DH-905 Errors (PineScript to Python Bridge

- url: https://www.tradingview.com/script/sAFYd9hZ-Fix-Webhook-Latency-DH-905-Errors-PineScript-to-Python-Bridge/
- type: indicator
- pine_id: PUB;66cd876336054c879780eeadb5240e9b
- version: 1.0

## Description

If you are routing TradingView alerts directly to an Indian broker API (like Dhan or Zerodha) and experiencing execution delays or DH-905 lot size rejections, the flaw is in your routing architecture.

The Problem: Dynamic vs. Static Data
PineScript generates dynamic data. A moving average crossover fires a signal based on a dynamic {{close}} price. However, broker APIs require static Exchange Tokens and rigid SEM_LOT_SIZE multipliers (e.g., Nifty = 65).

If you try to pass quantity: 1 directly to the Dhan API, or if your hardcoded exchange token moves out of the ATM range overnight, the exchange rejects the payload. Furthermore, standard third-party webhook routing adds 1 to 2 seconds of latency, destroying your entry price on fast breakouts.

The Middleware Solution
The PineScript above is Step 1. It formats a clean JSON payload containing the dynamic variables.

Step 2 is interception. You must not send this JSON to the broker. You must send it to a localized Python Flask server hosted on a headless Ubuntu VPS.

On startup, your Python server downloads the NSE Scrip Master directly into a Pandas DataFrame stored in RAM. When this PineScript webhook hits your VPS, the Pandas logic instantly snaps the dynamic {{close}} price to the nearest ATM strike, extracts the exact static Exchange Token, and routes the order to the API.

By removing the third-party webhook bottleneck and relying on RAM-cached token lookups, execution time drops to sub-50ms.

The Open-Source Architecture
I engineered this complete routing logic to eliminate my own Nifty options slippage. I have open-sourced the underlying Python Flask and Pandas routing logic so you can build out the middleware yourself.

Check the GitHub repository for the full Python architecture: https://github.com/codetradesalgo-cmyk/dhan-api-tradingview-webhook-python

## Source Code

````pine
//@version=6
indicator("CodeTrades: Institutional JSON Webhook Bridge", overlay=true)

// Simple EMA Crossover condition for demonstration
fastEMA = ta.ema(close, 9)
slowEMA = ta.ema(close, 21)
buySignal = ta.crossover(fastEMA, slowEMA)
sellSignal = ta.crossunder(fastEMA, slowEMA)

// Constructing the dynamic JSON payload for the Python Middleware
// We pass the dynamic {{ticker}} and {{close}}, which the Pandas RAM-cache will translate.
var string payload = ""

if buySignal
    payload := '{"action": "BUY", "symbol": "' + syminfo.ticker + '", "price": ' + str.tostring(close) + ', "type": "ATM_CALL"}'
    alert(payload, alert.freq_once_per_bar_close)

if sellSignal
    payload := '{"action": "SELL", "symbol": "' + syminfo.ticker + '", "price": ' + str.tostring(close) + ', "type": "ATM_PUT"}'
    alert(payload, alert.freq_once_per_bar_close)

plot(fastEMA, color=color.blue, title="Fast EMA")
plot(slowEMA, color=color.red, title="Slow EMA")
````
