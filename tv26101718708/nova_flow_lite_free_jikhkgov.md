# Nova Flow Lite (Free)

- url: https://www.tradingview.com/script/jIkhKGOV-Nova-Flow-Lite-Free/
- type: indicator
- pine_id: PUB;2f15c571ccc34490943b911bc3abfd44
- version: 3.0

## Description

[b]Clean and non‑intrusive trend tool for instant market clarity.
[/b]
[b]Nova Flow Lite[/b] is a clean and non‑intrusive trend tool designed to give traders instant clarity without cluttering the chart.
It highlights the dominant trend with a smooth visual ribbon and adds a soft equilibrium zone to show market balance.
Works on all assets, all timeframes, and both directional and spread trading.

[b]What it shows  
[/b]• Clear trend direction through a smooth visual ribbon
• A soft equilibrium zone showing market balance
• A minimal info panel for instant trend confirmation
• Zero signals, zero noise — pure visual context

[b]Why traders use it  
[/b]For a quick, elegant and intuitive read of market direction without overwhelming the chart.
Perfect for directional setups, spread structures, and multi‑timeframe analysis.

[b]Notes  
[/b]Nova Flow Lite is a simplified version of the Nova series.
A more advanced tool is available for traders who need deeper precision.

[b]Feedback and questions are welcome — you can reach me here on TradingView.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NovaQuantX

//@version=6
indicator("Nova Flow Free v2.1", "Nova Flow Free", overlay=true, max_labels_count=500)

// ─────────────────────────────
// 1. FLOW LINE (EMA 34) + TREND COLOR
// ─────────────────────────────

// EMA rallentate per ridurre precisione
fast = ta.ema(close, 34)
slow = ta.ema(close, 55)

// Trend semplificato (solo colore, no incroci visibili)
trendUp   = fast > slow
trendDown = fast < slow

colUp   = color.new(color.teal, 0)
colDown = color.new(color.red, 0)

flowColor = trendUp ? colUp : colDown

// Glow leggero (effetto premium)
flowGlow = plot(fast, "Flow Glow", color.new(flowColor, 80), 8)
flowLine = plot(fast, "Flow Line", flowColor, 3)

fill(flowGlow, flowLine, color.new(flowColor, 90))

// ─────────────────────────────
// 2. ZONA DI EQUILIBRIO MORBIDA (rimane identica)
// ─────────────────────────────
basis = ta.sma(close, 34)
dev   = ta.stdev(close, 34)

upper = basis + dev
lower = basis - dev

pU = plot(upper, "", color.new(color.gray, 90))
pL = plot(lower, "", color.new(color.gray, 90))

fill(pU, pL, color.new(color.gray, 94))

// ─────────────────────────────
// 3. RIMOZIONE DEL PANNELLO TREND
// (nessun segnale, nessuna conferma)
// ─────────────────────────────
// Nessun pannello → free non operativo
````
