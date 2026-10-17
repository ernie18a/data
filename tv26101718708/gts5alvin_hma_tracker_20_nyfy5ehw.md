# GTS5.alvin - HMA Tracker 2.0

- url: https://www.tradingview.com/script/nyFY5eHw-GTS5-alvin-HMA-Tracker-2-0/
- type: indicator
- pine_id: PUB;28aa68029f5f414abdb2babc4fecf9a6
- version: 1.0

## Description

Momentum. Strength. Clarity.

🚀 [b]Overview[/b]

[b]HMA Tracker™ 2.0[/b] is a next-generation momentum indicator that transforms the Hull Moving Average into a real-time trend intelligence system.

Instead of simply showing direction, it reveals:

📍 Market bias (Bullish / Bearish)
⚡ Momentum strength (0–100%)
🧠 Expansion vs exhaustion phases
🎨 Dynamic visual intensity based on volatility

This is not just a moving average…


👉 [b]It’s a live momentum radar for price action.[/b]


🧠 [b]What Makes It Different[/b]

Traditional indicators tell you:

“Price is going up or down”

[b]HMA Tracker™ tells you[/b]:

“How strong the move is… and whether it’s accelerating or dying.”

It achieves this by comparing:

⚡ Current HMA (momentum)
📊 HMA Lookback Average (equilibrium)

Then measuring the distance between them as a normalized strength score.


📊 [b]Core Features[/b]

🎯 [b]1. Real-Time Bias Detection[/b]
🟢 Bullish trend detection
🔴 Bearish trend detection
Instant flip signals when momentum shifts


⚡ [b]2. Strength-Based Momentum Engine (0–100%)[/b]

📉 0–30% → Weak / Chop / Range
📊 30–70% → Building momentum
🚀 70–100% → Strong expansion or exhaustion zone


🎨 [b]3. Dynamic Color Intensity System[/b]

🌫️ Faded colors → weak momentum
🔥 Bright neon colors → strong expansion

Color intensity automatically adapts to volatility conditions.

🧩 [b]4. Smart Dashboard (Top-Right Panel)[/b]

Live readout of:

🟢 BULLISH / 🔴 BEARISH bias
📊 Strength percentage
⚡ Market state (Weak / Building / Expansion)


🧠 [b]5. Expansion vs Exhaustion Logic[/b]

This indicator helps you visually identify:

🚀 Expansion phases (trend acceleration)
⚠️ Exhaustion zones (momentum fading)
🔄 Early reversal signals


🔥 [b]How to Use It[/b]

📈[b] Trend Continuation Setup[/b]
Bias = Bullish
Strength = 60%–100%
👉 Ride momentum, avoid early exits


🧨 [b]Exhaustion Warning[/b]
Strength spikes (80–100%)
Then begins fading
👉 Possible reversal or pullback incoming


⚪ [b]Chop / No Trade Zone[/b]
Strength below 30%
👉 Market is ranging or indecisive


🎯 [b]Flip Signals[/b]
🔴 → 🟢 = bullish transition
🟢 → 🔴 = bearish transition

Best used with structure or liquidity zones.


[b]💡 Built For Traders Who Want Clarity
[/b]
Perfect for:

⚡ Scalpers (1m–5m)
📊 Intraday traders
🧠 Momentum traders
🎯 Trend followers


🧪[b] Best Markets[/b]

🥇 Gold (XAUUSD)
💱 Forex pairs
🪙 Crypto (BTC / ETH)
📈 Indices (NAS100 / US30)


⚙️ [b]Default Settings[/b]

⏱️ HMA Length: 55
📊 Lookback Average: 55
📏 Strength Normalization: 100
🖥️ Timeframe: Optimized for 1-minute charts


🔥 [b]Why Traders Use It[/b]

✔ Eliminates guessing
✔ Shows real momentum strength
✔ Adapts to volatility automatically
✔ Works across all markets
✔ Combines trend + momentum in one tool


🧠 [b]Pro Strategy Tip
[/b]
The real edge comes from:

👉 [b]Watching strength transitions, not just direction[/b]

Weak → Strong = Entry confirmation
Strong → Weak = Exit / reversal warning


💬[b] Final Note[/b]

[b]HMA Tracker™  2.0[/b] doesn’t just show direction…

👉 It shows [b]the force behind the move[/b]

So you’re no longer trading candles.

You’re trading [b]momentum itself.[/b]


⚠️ [b]Disclaimer[/b]

This indicator is for educational and informational purposes only. It does not constitute financial advice. Trading involves risk.

## Source Code

````pine
//@version=5
indicator("GTS5.alvin - HMA Tracker™ 2.0", overlay=true)

// === INPUTS ===
hmaLength        = input.int(55, "HMA Length")
lookbackLength   = input.int(55, "HMA Lookback Avg")
strengthLookback = input.int(100, "Strength Normalization")

src = input.source(close, "Source")

showBG     = input.bool(true, "Show Background")
showLabels = input.bool(true, "Show Flip Labels")
showDash   = input.bool(true, "Show Dashboard")

// === HMA FUNCTION ===
hma(src, length) =>
    ta.wma(2 * ta.wma(src, length / 2) - ta.wma(src, length), math.round(math.sqrt(length)))

// === CALCULATIONS ===
hmaValue = hma(src, hmaLength)
hmaAvg   = ta.sma(hmaValue, lookbackLength)

// === STRENGTH ===
distance = math.abs(hmaValue - hmaAvg)
maxDist  = ta.highest(distance, strengthLookback)
normDist = maxDist != 0 ? distance / maxDist : 0

strengthPercent = math.round(normDist * 100)

// === BIAS ===
bullish = hmaValue > hmaAvg
bearish = hmaValue < hmaAvg

// === COLOR INTENSITY ===
transparency = 100 - math.min(normDist * 100, 100)

bullColor = color.new(color.lime, transparency)
bearColor = color.new(color.red, transparency)

hmaColor = bullish ? bullColor : bearColor

// === PLOTS ===
plot(hmaValue, "HMA", color=hmaColor, linewidth=3)
plot(hmaAvg, "HMA Avg", color=color.gray)

// === BACKGROUND ===
bgcolor(showBG ? (bullish ? color.new(color.green, transparency + 20) : color.new(color.red, transparency + 20)) : na)

// === LABELS ===
if showLabels and bullish and not bullish[1]
    label.new(bar_index, low, "BULL", style=label.style_label_up, color=color.green, textcolor=color.white)

if showLabels and bearish and not bearish[1]
    label.new(bar_index, high, "BEAR", style=label.style_label_down, color=color.red, textcolor=color.white)

// === DASHBOARD ===
var table dash = table.new(position.top_right, 1, 3)

if showDash
    // Bias text
    biasText = bullish ? "BULLISH" : "BEARISH"
    biasColor = bullish ? color.lime : color.red

    // Strength zone
    strengthZone = strengthPercent >= 70 ? "EXPANSION" :
                   strengthPercent >= 30 ? "BUILDING" : "WEAK"

    // Glow effect via color intensity
    dashBg = color.new(biasColor, transparency)

    table.cell(dash, 0, 0, "HMA TRACKER", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 0, 1, biasText, text_color=color.white, bgcolor=dashBg)
    table.cell(dash, 0, 2, str.tostring(strengthPercent) + "% " + strengthZone, text_color=color.white, bgcolor=dashBg)

// === ALERTS ===
bullFlip = bullish and not bullish[1]
bearFlip = bearish and not bearish[1]

alertcondition(bullFlip, "Bullish Flip", "HMA Tracker turned Bullish")
alertcondition(bearFlip, "Bearish Flip", "HMA Tracker turned Bearish")
````
