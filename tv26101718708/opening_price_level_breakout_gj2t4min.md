# Opening Price Level Breakout

- url: https://www.tradingview.com/script/Gj2t4MIn/
- type: indicator
- pine_id: PUB;c0fb18ebf8c84c208790dd73eab79e04
- version: 3.0

## Description

[i]A lightweight yet effective indicator designed for traders who need to monitor price breakouts at key historical levels — without cluttering their setup with multiple scripts.[/i]

[b]What it does[/b]
Plots a fixed price level on the chart and fires an alert when the daily opening price breaks above it. Simple premise, high signal value: the opening price is a cleaner breakout trigger than an intraday cross, filtering out noise and false moves caused by wicks.
[b]The problem it solves[/b]
TradingView's native alert system does not support dynamic level recalculation across a watchlist in bulk. Setting up separate scripts for 3M, 6M, and 12M highs across multiple tickers burns through your alert slots fast — especially on Essential and Plus plans where limits are tight. This indicator consolidates the logic into a single, reusable tool: one script, one alert per ticker, any level you need.

[b]Inputs[/b]

Price Level — the exact price to monitor (e.g. the 3M, 6M, or 12M high pulled from your analysis)
Level Label — a descriptive tag for your own reference (Max 3M / Max 6M / Max 12M / Custom)
Level Color — visual customization for multi-instance use on the same chart

How to use it

Add the indicator to your chart and set the Price Level input to the historical high you want to monitor
Create an alert using the Opening Price Level Breakout condition with trigger set to Once per bar on the 1D timeframe
Repeat for each ticker in your watchlist
Done — TradingView's servers handle execution; no need to keep the any chart open!

Pro tip: You can stack multiple instances of this indicator on the same chart — one per level — each with a different color. One alert slot per instance, full multi-level coverage on a single ticker.
Note: Due to a Pine Script constraint, alertcondition only accepts constant strings in the message field. Dynamic label injection at runtime is not supported, so the level label is intentionally kept as a chart-side reference only.

breakout, alerts, opening price, historical high, watchlist, daily.

## Source Code

````pine
//@version=6
indicator("Opening Price Level Breakout", overlay=true)

// ─── IMPOSTAZIONI ───────────────────────────────────────────
target_ticker = input.string(
     title="Reference Ticker",
     defval="MSFT",
     tooltip="Manually enter the ticker this price level refers to"
     )

price_level = input.float(
     title="Price Level",
     defval=100.0,
     minval=0.0,
     tooltip="Enter the price level to monitor (e.g. 3M, 6M or 12M high)"
     )

level_label = input.string(
     title="Level Label",
     defval="Max 12M",
     options=["Max 3M", "Max 6M", "Max 12M", "Custom Level"],
     tooltip="Used as a chart-side reference only"
     )

level_color = input.color(
     title="Level Color",
     defval=color.purple
     )

// ─── PLOT ───────────────────────────────────────────────────
plot(price_level, "Level", color=level_color, linewidth=2, style=plot.style_stepline)

// ─── LABEL CON TICKER DI RIFERIMENTO MANUALE ────────────────
var label tickerLabel = na
if barstate.islast
    label.delete(tickerLabel)
    tickerLabel := label.new(
         bar_index, price_level,
         text=target_ticker + " | " + level_label + ": " + str.tostring(price_level, "#.##"),
         color=level_color,
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small
         )

// ─── CONDIZIONE ─────────────────────────────────────────────
breakout = open > price_level

// ─── ALERT ──────────────────────────────────────────────────
alertcondition(
     breakout,
     "Opening Price Level Breakout",
     "🚨 {{ticker}} | Open above price level | O={{open}}"
     )
````
