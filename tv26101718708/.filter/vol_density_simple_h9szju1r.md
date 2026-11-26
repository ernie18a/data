# Vol Density (Simple)

- url: https://www.tradingview.com/script/H9Szju1R-Vol-Density-Simple/
- type: indicator
- pine_id: PUB;add97f0e5e3f47968dc9e1a88301b446
- version: 1.0

## Description

📊 Vol Density — Volume per Price Range

█ What is it?
Vol Density = Volume ÷ (High - Low)

It measures how much volume is packed into each unit of price movement. Think of it as volume concentration — not just "how much was traded", but "how intensely was each price level fought over".


█ How to Read It
🔴 SPIKE (Abnormally High Density)
High volume + Small range = Disagreement

Buyers and sellers are fighting hard but price barely moves. This signals non-consensus.

  • At a relative bottom → likely a SUPPORT level (heavy buying is absorbing sell pressure)
  • At a relative top → likely a RESISTANCE level (heavy selling is absorbing buy pressure)

👉 Action: Watch for reversal or a strong breakout after the compression resolves.


🟢 FLAT / LOW Density
Volume moves price easily = Agreement

Price is moving freely with little resistance. This signals consensus on direction.

  • In an uptrend → trend is strong and accelerating, low friction
  • In a downtrend → selling is unchallenged, capitulation or free-fall

👉 Action: Ride the trend. Don't fade it.


█ Settings
  • Length (20) — MA lookback period
  • Multiplier (1.5) — Spike threshold (× MA)
  • Cap Multiplier (5.0) — Visual cap to prevent extreme spikes from compressing the chart


█ Quick Cheat Sheet
  🔺 Spike + Near Bottom   = Buying absorption   → SUPPORT
  🔺 Spike + Near Top      = Selling absorption  → RESISTANCE
  🔻 Low   + Trending Up   = Low friction        → STRONG UPTREND
  🔻 Low   + Trending Down = No buyers stepping in → STRONG DOWNTREND


█ One Sentence Summary
⚡ High density = battle (reversal zone). Low density = consensus (trend continuation).

## Source Code

````pine
//@version=5
indicator("Vol Density", shorttitle="Vol Density", format=format.volume)

length  = input.int(20, "Length", minval=1)
mult    = input.float(1.5, "Multiplier", step=0.1)
show_ma = input.bool(true, "Show MA")

range_hl = high - low
vol_density = range_hl > 0 ? volume / range_hl : 0

ma = ta.sma(vol_density, length)
threshold = ma * mult

is_up = close >= open
is_spike = vol_density > threshold

bar_color = is_spike and is_up ? color.new(color.teal, 0) : is_spike and not is_up ? color.new(color.red, 0) : is_up ? color.new(color.teal, 60) : color.new(color.red, 60)

plot(vol_density, style=plot.style_columns, color=bar_color, title="Vol Density")
plot(show_ma ? ma : na, color=color.gray, linewidth=1, title="MA")
````
