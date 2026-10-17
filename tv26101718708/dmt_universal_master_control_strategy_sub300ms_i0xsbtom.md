# DMT Universal Master Control Strategy Sub-300ms

- url: https://www.tradingview.com/script/i0XSbToM/
- type: strategy
- pine_id: PUB;b098f0c058184259af71a2b7fc0fb7b4
- version: 1.0

## Description

High-speed algorithmic trading automation for TradingView. 🚀⚡️

This script is the DMT Universal Master Control, specifically designed to connect your TradingView charts to the DearmasTrader execution engine with sub-300ms latency.

Main Features:

Zero-Latency Execution: Built on a C# and Redis in-memory architecture for professional-grade speed.
Universal Filters: Toggle EMAs (9, 21, 200), RSI, and Bollinger Bands directly from the settings menu without code.
Auto-JSON Payloads: The strategy automatically generates and sends the correct JSON message to your Webhook.
No-Code Required: Fully adjustable parameters for any trading style (Scalping, Trend, or Mean Reversion).
How to Connect:

Get your Bot Secret from dearmastrader.com.
Paste the secret into the script settings.
Create an alert, select this strategy, and use the following Webhook URL: https://app.dearmastrader.com/api/webhooks/tv/44012... (or your specific endpoint).
IMPORTANT: In the Alert Message box, paste exactly: {{strategy.order.alert_message}}

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DearmasTrader - Senior Quant & Architecht

//@version=6
strategy("DMT - Estrategia Universal Editable", overlay=true, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// =========================================================================
// 1. CONFIGURACIÓN DE DEARMASTRADER
// =========================================================================
botSecret = input.string("PEGAR_AQUI_TU_SECRET", "DMT Bot Secret", group="DearmasTrader Config")
pair      = input.string("auto", "Par (auto = usar gráfico)", group="DearmasTrader Config")
ticker    = pair == "auto" ? syminfo.ticker : pair

// =========================================================================
// 2. FILTROS Y ACTIVADORES (Editable sin código)
// =========================================================================
useEMA    = input.bool(true, "Usar Cruce de EMAs?", group="Estrategia")
emaFast   = input.int(9, "EMA Rápida", group="Estrategia")
emaSlow   = input.int(21, "EMA Lenta", group="Estrategia")

useRSI    = input.bool(false, "Filtrar por RSI?", group="Estrategia")
rsiLen    = input.int(14, "RSI Longitud", group="Estrategia")
rsiOverB  = input.int(70, "Sobrecompra", group="Estrategia")
rsiOverS  = input.int(30, "Sobreventa", group="Estrategia")

useTrend  = input.bool(true, "Filtro de Tendencia (EMA 200)?", group="Estrategia")

// =========================================================================
// 3. CÁLCULOS TÉCNICOS
// =========================================================================
valEMA_F = ta.ema(close, emaFast)
valEMA_S = ta.ema(close, emaSlow)
valEMA_T = ta.ema(close, 200)
valRSI   = ta.rsi(close, rsiLen)

// Condiciones Lógicas
bool L_EMA   = useEMA ? ta.crossover(valEMA_F, valEMA_S) : true
bool S_EMA   = useEMA ? ta.crossunder(valEMA_F, valEMA_S) : true

bool L_RSI   = useRSI ? valRSI < rsiOverS : true
bool S_RSI   = useRSI ? valRSI > rsiOverB : true

bool L_Trend = useTrend ? close > valEMA_T : true
bool S_Trend = useTrend ? close < valEMA_T : true

// Entrada Final
longSignal  = L_EMA and L_RSI and L_Trend
shortSignal = S_EMA and S_RSI and S_Trend

// =========================================================================
// 4. PAYLOADS JSON (Para Webhooks DMT)
// =========================================================================
longJson  = '{"action": "OPEN", "direction": "LONG", "pair": "' + ticker + '", "token": "' + botSecret + '"}'
shortJson = '{"action": "OPEN", "direction": "SHORT", "pair": "' + ticker + '", "token": "' + botSecret + '"}'
closeJson = '{"action": "CLOSE", "pair": "' + ticker + '", "token": "' + botSecret + '"}'

// =========================================================================
// 5. EJECUCIÓN
// =========================================================================
if (longSignal)
    strategy.entry("Long", strategy.long, alert_message=longJson)

if (shortSignal)
    strategy.entry("Short", strategy.short, alert_message=shortJson)

// Visualización
plot(valEMA_F, color=color.blue, title="EMA Rápida")
plot(valEMA_S, color=color.orange, title="EMA Lenta")
plot(useTrend ? valEMA_T : na, color=color.white, linewidth=2, title="EMA Trend")
````
