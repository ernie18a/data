# GBR Micro Kernel Trend [Laplace Smoothing]

- url: https://www.tradingview.com/script/raTZQ8IM-GBR-Micro-Kernel-Trend-Laplace-Smoothing/
- type: indicator
- pine_id: PUB;b130df8735b14ae88a8a4dbf07bb2c10
- version: 1.0

## Description

The GBR Micro Kernel Trend is the ultimate solution for lower-timeframe scalpers (1m-5m) who are tired of traditional moving averages whipping them out of trades.

Instead of basic averaging, this indicator utilizes a Nadaraya-Watson Kernel Regression (with a Laplace probability distribution) to dynamically smooth out market noise. The result is a buttery-smooth trend line that doesn't blindly hug the candles, allowing the price to breathe during minor pullbacks.

🔥 Core Features:

Laplace Smoothing Engine: Filters out erratic wicks and micro-chop, focusing strictly on the true directional momentum.

Adjustable Bandwidth (h): Fully customizable. Increase the 'h' value to distance the line from the price for longer holds, or decrease it for hyper-sensitive scalp entries.

Minimalist Sniper Signals: Stripped of all retail clutter. Provides elegant, low-opacity UV Green ▲ and UV Red ▼ markers exclusively at trend reversal points.

Strictly Non-Repainting: Operates strictly on closed bar data. Once a signal is printed, it stays there.

🎯 How to execute:
Wait for the noise to settle. Enter your trade when the Kernel line shifts color and prints the reversal marker. For the highest win rate, ensure your entries align with a higher timeframe macro trend.

## Source Code

````pine
//@version=6
indicator("GBR Micro Kernel Trend", overlay=true)

// ==========================================
// 1. SETTINGS (UI)
// ==========================================
grp = "Kernel Smoothing Settings"
h = input.float(14.0, title="Smoothing Bandwidth (h)", step=1.0, group=grp, tooltip="Növeld ezt a számot, ha túl közel van a gyertyákhoz (késleltet, de simít). Csökkentsd, ha gyorsabb reakciót akarsz!")
window = input.int(50, title="Calculation Window", group=grp)
src = input.source(close, title="Source", group=grp)

// ==========================================
// 2. GBR CORPORATE IDENTITY (UV COLORS)
// ==========================================
colBuy  = color.new(#00FF00, 0)
colSell = color.new(#FF0033, 0)

// ==========================================
// 3. LAPLACE KERNEL ALGORITHM
// ==========================================
float sum = 0.0
float sumw = 0.0

for i = 0 to window
    weight = math.exp(-math.abs(i) / h)
    sum += nz(src[i]) * weight
    sumw += weight

float kernel = sum / sumw

// ==========================================
// 4. TREND DIRECTION & LOGIC
// ==========================================
bool isBull = kernel > kernel[1]
bool isBear = kernel < kernel[1]

var int dir = 1
if isBull
    dir := 1
else if isBear
    dir := -1

color lineCol = dir == 1 ? colBuy : colSell

// ==========================================
// 5. DRAWING THE SMOOTH LINE
// ==========================================
plot(kernel, color=lineCol, linewidth=3, title="GBR Kernel Line")

// ==========================================
// 6. GBR SNIPER SIGNALS
// ==========================================
bool buySig  = dir == 1 and dir[1] == -1
bool sellSig = dir == -1 and dir[1] == 1

// Diszkrét, letisztult nyilak a fordulópontokon
plotshape(buySig,  title="Buy Signal",  style=shape.labelup,   location=location.belowbar, color=color.new(colBuy, 85),  text="▲", textcolor=colBuy,  size=size.tiny)
plotshape(sellSig, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(colSell, 85), text="▼", textcolor=colSell, size=size.tiny)
````
