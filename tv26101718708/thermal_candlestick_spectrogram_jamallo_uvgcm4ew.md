# Thermal Candlestick Spectrogram [Jamallo]

- url: https://www.tradingview.com/script/UvgCm4ew-Thermal-Candlestick-Spectrogram-Jamallo/
- type: indicator
- pine_id: PUB;615efc3ee2db48379089cf23e16c006f
- version: 1.0

## Description

The [b]Thermal Candlestick Spectrogram[/b] replaces flat, binary candlesticks with a heat-mapped view of price density. Every bar radiates outward from a white-hot core through layers of orange, red, and deep amber — the same way thermal imaging reveals intensity beneath a surface. The result is a chart that doesn't just show you what price did, it shows you how concentrated that move was.

[b]How It Works[/b]

A 7-layer gradient stack is anchored to each candle's midpoint and expands symmetrically toward the edges of the body. Transparency increases with each outer layer, creating a natural falloff that mimics heat dissipation:

[b]White-yellow core[/b] — maximum density at the center of the body
[b]Orange-red mantle[/b] — transitional layers that reveal the spread of price action
[b]Dark outer boundary[/b] — a near-transparent edge that lets candles breathe without hard lines
[b]Fading wicks[/b] — a dual-layer vertical fade that tapers wicks naturally toward the High and Low extremes, reducing visual noise
[b]Anti-aliased price dot[/b] — a precision close marker with a subtle white halo for clean real-time tracking

[b]Design & Performance[/b]

The entire effect runs on a fixed 9-plot architecture (7 body layers + 2 wick layers), keeping script weight low and render performance stable even alongside other indicators. No dynamic loops, no repainting — just a clean, deterministic stack that works across all timeframes and instruments.

[b]Visual Comparison[/b]
[image]https://www.tradingview.com/x/TEj3Ria8/[/image]
[i]Traditional flat candles vs. the Thermal Spectrogram — same data, entirely different depth.[/i]

## Source Code

````pine
//@version=6
indicator("Thermal Candlestick Spectrogram [Jamallo]", overlay=true)

// --- Math ---
body_top   = math.max(open, close)
body_bot   = math.min(open, close)
body_range = body_top - body_bot
mid        = body_bot + (body_range * 0.5)

// Helper function for body slices
get_top(pct) => mid + (body_range * (pct / 2))
get_bot(pct) => mid - (body_range * (pct / 2))

// --- Wick Fade Math ---
top_range = high - body_top
bot_range = body_bot - low

// --- 1. Faded Wicks (2-Layer Optimization) ---
// This creates the "vanishing" effect at the extreme ends
plotcandle(high, high, low, low, "Wick Tip", color=color.new(#2b6a84, 85), bordercolor=na, wickcolor=na)
plotcandle(body_top + (top_range * 0.6), body_top + (top_range * 0.6), body_bot - (bot_range * 0.6), body_bot - (bot_range * 0.6), "Wick Base", color=color.new(#2b6a84, 60), bordercolor=na, wickcolor=na)

// --- 2. 7-Layer Thermal Body Gradient ---
// Transitioning from deep heat (#4a1a00) to the white-hot core (#ffcc00)
plotcandle(get_top(1.00), get_top(1.00), get_bot(1.00), get_bot(1.00), "L1", color=color.new(#4a1a00, 80), bordercolor=na, wickcolor=na)
plotcandle(get_top(0.85), get_top(0.85), get_bot(0.85), get_bot(0.85), "L2", color=color.new(#781c00, 65), bordercolor=na, wickcolor=na)
plotcandle(get_top(0.70), get_top(0.70), get_bot(0.70), get_bot(0.70), "L3", color=color.new(#a81c00, 50), bordercolor=na, wickcolor=na)
plotcandle(get_top(0.55), get_top(0.55), get_bot(0.55), get_bot(0.55), "L4", color=color.new(#d62400, 35), bordercolor=na, wickcolor=na)
plotcandle(get_top(0.40), get_top(0.40), get_bot(0.40), get_bot(0.40), "L5", color=color.new(#f74a00, 20), bordercolor=na, wickcolor=na)
plotcandle(get_top(0.25), get_top(0.25), get_bot(0.25), get_bot(0.25), "L6", color=color.new(#ff8800, 10), bordercolor=na, wickcolor=na)
plotcandle(get_top(0.10), get_top(0.10), get_bot(0.10), get_bot(0.10), "L7", color=color.new(#ffcc00, 0),  bordercolor=na, wickcolor=na)

// --- 3. Price Dot (Smallest width, solid black with faint halo) ---
plot(close, "Price Halo", color=color.new(color.white, 80), linewidth=2, style=plot.style_circles)
plot(close, "Price Center", color=color.new(#000000, 0), linewidth=1, style=plot.style_circles)
````
