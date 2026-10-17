# JJB OTT Alert Relay

- url: https://www.tradingview.com/script/IaVQhgN7-JJB-OTT-Alert-Relay/
- type: indicator
- pine_id: PUB;f95996b105614467ba174bd024fa9403
- version: 2.0

## Description

[b]JJB OTT Alert Relay
[/b]A bridge indicator that exposes Optimized Trend Tracker (OTT) Buy/Sell signals as alert conditions for automated webhook notifications.

[b]🔍 What This Does
[/b]The Optimized Trend Tracker by TradingView generates clean Buy/Sell crossover signals but doesn't expose alertcondition() natively. This relay indicator mirrors the OTT's Support and OTT lines, detects crossovers, and surfaces them as alert conditions — so you can catch signals via webhook, email, or push without watching the chart.

🟢 Buy Signal: Support line crosses above OTT line
🔴 Sell Signal: Support line crosses below OTT line

[b]⚙️ Setup (One-Time, 60 Seconds)
[/b]
1. Add both indicators to your chart:

The original Optimized Trend Tracker (Community Script)
This JJB OTT Alert Relay
2. Wire the inputs:

Open JJB OTT Alert Relay → Settings → Inputs
Set "Support Line" → #1 Optimized Trend Tracker: Support Line
Set "OTT Line" → #1 Optimized Trend Tracker: OTT
3. Verify the match:

Both indicators should show identical Support and OTT values in the Data Window. If they match, the relay is wired correctly.

[b]🔔 Creating the Alert
[/b]
Open TradingView's Alert dialog
Condition → "Any alert() function call"
Select "JJB OTT Alert Relay" as the source
Paste your webhook URL
Use this JSON message template:
{"topic":"JJB BTC OTT","title":"BTC OTT {{strategy.order.action}}","message":"OTT Signal: {{strategy.order.action}} | Price: {{close}} | Interval: {{interval}}","tags":["{{strategy.order.action}}","bitcoin"],"passphrase":"YOUR_WEBHOOK_PASSPHRASE"}
Replace YOUR_WEBHOOK_PASSPHRASE with your actual webhook passphrase. The {{strategy.order.action}} placeholder resolves to "buy" or "sell" on each crossover.

Set expiration (default 30 days) and create.
💡 One alert covers both signals. No need for separate buy/sell alerts.

[b]📊 Signal Logic
[/b]
Condition	Signal	Meaning
Support ↑ crosses above OTT	🟢 BUY	Trend turning bullish
Support ↓ crosses below OTT	🔴 SELL	Trend turning bearish
This is a trend-following system — signals are infrequent (typically 2-4 per quarter on daily timeframe) but high-quality. Each signal confirms a structural shift, not noise.

📌 Tips
Daily timeframe is the sweet spot — lower timeframes generate more noise
The relay mirrors the original OTT exactly — it doesn't recalculate
If you change OTT's settings, the relay picks them up automatically via the wired inputs
The plot on your chart confirms the wiring: green line = Support, blue line = OTT

[b]🔧 Requirements
[/b]
Original Optimized Trend Tracker indicator on the same chart
Basic Pine Script v5+ (TradingView)

Author: JJB | Version: 1.0

## Source Code

````pine
//@version=6
indicator("JJB OTT Alert Relay", overlay=true)

// Source Inputs
ottLine     = input.source(close, "OTT Line")
supportLine = input.source(close, "Support Line")

// Style Settings
showLabels  = input.bool(true, "Show Signal Labels", group="Style")

// Cross Detection
crossUp     = ta.crossover(supportLine, ottLine)
crossDown   = ta.crossunder(supportLine, ottLine)

// Plot Lines
plot(ottLine,     title="OTT Line",     color=color.orange, linewidth=2)
plot(supportLine, title="Support Line", color=color.blue,   linewidth=2)

// Signal Labels
if showLabels
    if crossUp
        label.new(bar_index, low, "B", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small, yloc=yloc.belowbar)
    if crossDown
        label.new(bar_index, high, "S", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// Alerts
alertcondition(crossUp,   title="OTT Buy",  message="OTT BUY")
alertcondition(crossDown, title="OTT Sell", message="OTT SELL")
````
