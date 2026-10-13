<!-- tradingview-pine-id: PUB;ad9c7af4c59e433f9963700c9360dbc1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Institutional Breadth & Momentum Panel (ADD & TICK)

Source: https://www.tradingview.com/script/QEwrfO20-Institutional-Breadth-Momentum-Panel-ADD-TICK/

## Description

** Overview

The **Institutional Breadth & Momentum Panel (ADD & TICK)** is a specialized real-time order flow and intermarket dashboard designed for intraday traders operating index futures (ES, NQ, YM, RTY) and major equities.

Rather than relying on traditional lagging momentum oscillators, this tool combines two core market internal metrics directly from the New York Stock Exchange (NYSE):

1. NYSE TICK ([symbol="USI:TICK"]USI:TICK[/symbol]): Measures institutional aggression and order flow pressure in real time.

2. NYSE Advance-Decline Line ([symbol="USI:ADD"]USI:ADD[/symbol]): Tracks broad-market participation and overall underlying market health.

** Key Components

 1. NYSE TICK (Histogram)
The TICK measures the net difference between stocks trading on an uptick versus a downtick across the entire market.

- Institutional Buying Surge (+1000 Threshold):** Highlighted in solid green. Indicates aggressive   institutional buying, short squeezes, or strong breakout momentum.
- Institutional Selling Panic (-1000 Threshold):** Highlighted in solid red. Indicates institutional liquidation, stop sweeps, or strong downward pressure.
- Neutral / Rotation Zone:** Softly colored histogram tracking intraday balance between buyers and sellers.

2. NYSE ADD (Orange Line)
The Advance-Decline Line provides top-down confirmation of market direction:

- An ascending ADD confirms that price rallies are backed by broad-market participation.
- A flat/descending ADD during price rallies signals divergence and potential exhaustion.

** Key Features:

Pine Script v6 Codebase: Clean, non-repainting execution utilizing historical closed bars (`close[1]`) for intermarket symbol requests to guarantee backtest accuracy without lookahead bias.
- Built-In Alerts:** Integrated alert conditions triggered when the NYSE TICK crosses extreme institutional thresholds ($\pm 1000$).
- Customizable Symbols:** Allows custom data feed tickers (`USI:ADD`, `INDEX:ADD`, etc.) to fit your specific market data provider settings.

** Best Practices & Practical Application:

- Intraday Execution: Optimized for 1-minute, 5-minute, and 15-minute timeframes on E-mini S&P 500 (ES1!), Nasdaq (NQ1!), and SPY/QQQ.
- Breakout Confirmation:** Use extreme TICK readings (+1000 / -1000) to confirm key level breakouts.
- Exhaustion Trades:** Look for extreme TICK spikes occurring at key daily support/resistance levels to identify high-probability mean-reversion setups.

---

## Source Code

````pine
//@version=6
indicator("Institutional Breadth & Momentum Panel (ADD & TICK)", 
     overlay=false, 
     shorttitle="Breadth_Pro_v6")

// ==========================
// INPUTS
// ==========================
group_sym   = "Símbolos de Amplitud"
symADD      = input.symbol("USI:ADD", title="Ticker ADD", group=group_sym)
symTICK     = input.symbol("USI:TICK", title="Ticker TICK", group=group_sym)

group_th    = "Umbrales e Intensidad"
tickExtreme = input.int(1000, title="Umbral Extremo TICK", group=group_th)

// ==========================
// CAPTURA DE DATOS INTERMERCADO
// ==========================
dataADD  = request.security(symADD, timeframe.period, close[1], ignore_invalid_symbol=true)
dataTICK = request.security(symTICK, timeframe.period, close[1], ignore_invalid_symbol=true)

// ==========================
// CÁLCULO DE COLORES DEL TICK
// ==========================
color colorTick = color.gray

if not na(dataTICK)
    if dataTICK >= tickExtreme
        colorTick := color.green
    else if dataTICK <= -tickExtreme
        colorTick := color.red
    else if dataTICK > 0
        colorTick := color.new(color.green, 60)
    else
        colorTick := color.new(color.red, 60)

// ==========================
// TRACEDO VISUAL
// ==========================
// Plot del TICK en Histograma
plot(dataTICK, title="NYSE TICK", color=colorTick, style=plot.style_histogram, linewidth=2)

// Líneas de Referencia para el TICK
hline(0, "Línea Cero", color=color.gray, linestyle=hline.style_solid)
hline(tickExtreme, title="Compra Extrema", color=color.green, linestyle=hline.style_dashed)
hline(-tickExtreme, title="Venta Extrema", color=color.red, linestyle=hline.style_dashed)

// Plot del ADD (Escalado en eje secundario para evitar solapamiento)
plot(dataADD, title="NYSE ADD", color=color.orange, linewidth=2, style=plot.style_line, force_overlay=false)

// ==========================
// ALERTAS
// ==========================
alertcondition(dataTICK >= tickExtreme, title="TICK Extremo Alcista", message="NYSE TICK superó +1000: Presión Institucional Alcista")
alertcondition(dataTICK <= -tickExtreme, title="TICK Extremo Bajista", message="NYSE TICK cayó de -1000: Presión Institucional Bajista")
````
