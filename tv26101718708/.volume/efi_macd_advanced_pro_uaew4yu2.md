# EFI & MACD Advanced Pro

- url: https://www.tradingview.com/script/uAeW4Yu2-EFI-MACD-Advanced-Pro/
- type: indicator
- pine_id: PUB;8c3d33affa9b4e7eb92529c29afaf4c2
- version: 3.0

## Description

Indicator Synopsis: EFI & MACD Advanced Pro
This custom TradingView indicator—created for Simon20cent—is a dual-momentum confirmation filter designed to isolate high-probability trend phases by synchronising a volume-weighted oscillator with a trend-following moving average cross.
It strips away chart noise by compressing two distinct indicator panels into a single, highly scannable visual pane. 



Core Components & Logic
The system monitors the interaction between two classic technical metrics:
1. Elder’s Force Index (EFI): Measures the directional power of a move by multiplying price change by volume. It determines whether buyers or sellers dominate the volume profile (Value > 0 or < 0). 
2. MACD vs. Signal Line: Tracks classic moving average momentum. A bullish state is triggered when the fast MACD line crosses above the slow Signal line (MACD > Signal). 



Visual Matrix (How to Read the Pane)
The indicator renders exclusively as a zero-anchored Column Chart, utilizing four distinct conditions: 
* 🟩 Bright Green Column (+1.0): Full Bullish Alignment. The EFI is above zero and accelerating upward, while the MACD line is securely above its signal line. 
* 🟥 Bright Red Column (-1.0): Full Bearish Alignment. The EFI is below zero and accelerating downward, while the MACD line is securely below its signal line. 
* 🟦 Light Blue Column (+0.5): Divergence / Market Out of Alignment. The indicators do not agree, but the EFI remains positive (>0), suggesting weak bullish underlying volume.
* 📘 Dark Navy Column (-0.5): Divergence / Market Out of Alignment. The indicators do not agree, but the EFI remains negative (<0), suggesting weak bearish underlying volume. 



Advanced Institutional Features
* Momentum Grading (Two-Tone Gradients): The columns automatically shift to a darker shade of green or red if structural momentum begins to flatten, providing an early structural warning before a trend formally breaks. 
* Trend Exhaustion Alerts (Orange Triangles): Small orange triangles automatically print above or below the columns the exact moment a strong green or red streak loses velocity, marking ideal profit-taking windows.
* Integrated Alert Engine: Features pre-built Pine Script hooks for Bullish Alignment, Bearish Alignment, and Trend Exhaustion, allowing you to link the indicator directly to TradingView phone push notifications or email alerts.

🟢 Long Exit Warning (Orange Triangle pointing Downward)
This prints at the top of the pane (+1.1) to signal it is time to scale out or close a long position. It triggers when you are in a valid long streak (Green columns), but the very next bar suffers a breakdown in power: 
* The Math: The indicator checks if Elder's Force Index (EFI) starts falling compared to the previous bar, OR if the MACD Line slips back below the Signal Line. 
* The Meaning: Buyers are running out of breath. Even though price might still be hovering near the highs, the volume-weighted power (EFI) is dropping, meaning institutional buying pressure has dried up.

🔴 Short Exit Warning (Orange Triangle pointing Upward)
This prints at the bottom of the pane (-1.1) to signal it is time to cover your short position. It triggers when you are in a valid short streak (Red columns), but seller momentum hits exhaustion:
* The Math: The indicator checks if EFI starts rising (climbing back toward zero), OR if the MACD Line crosses back above the Signal Line. 
* The Meaning: Sellers are exhausted. The downward volume is thinning out, and profit-taking by larger players is likely about to cause a bullish bounce or a prolonged squeeze.

💡 Trading Strategy Tip
Do not use these orange triangles to open new trades. Treat them strictly as protective exit signals. When you see one appear while you are in profit, it means the high-velocity phase of that specific wave has ended, and the indicator is about to print unaligned blue columns.

## Source Code

````pine
//@version=6
// Created by Simon20cent
indicator('EFI & MACD ATR-Pro', shorttitle = 'EFI+MACD ATR Pro', overlay = false)

// --- Inputs ---
var string G_EFI   = 'Elder\'s Force Index Settings'
var string G_MACD  = 'MACD Settings'
var string G_ATR   = 'ATR Volatility Filter Settings'
var string G_VIS   = 'Visual Options'

efiLength    = input.int(13, title = 'EFI Length', group = G_EFI)
fastLength   = input.int(12, title = 'MACD Fast Length', group = G_MACD)
slowLength   = input.int(26, title = 'MACD Slow Length', group = G_MACD)
signalLength = input.int(9, title = 'MACD Signal Length', group = G_MACD)

// ATR Filter Inputs & Toggle
useAtrFilter = input.bool(true, title = 'Enable ATR Volatility Filter', group = G_ATR)
atrLength    = input.int(14, title = 'ATR Length', group = G_ATR)
atrThreshold = input.float(0.15, title = 'Min MACD/ATR Distance Threshold', step = 0.05, tooltip = 'Filters out minor crossovers when enabled.', group = G_ATR)

useGradient  = input.bool(true, title = 'Use Gradient Colors (Based on Momentum Strength)', group = G_VIS)
showShapes   = input.bool(true, title = 'Show Trend Reversal Shapes', group = G_VIS)

// --- Calculations ---
// Elder's Force Index (EFI)
rawEFI = volume * (close - nz(close[1])) 
efi = ta.ema(rawEFI, efiLength)

// MACD
[macdLine, signalLine, macdHist] = ta.macd(close, fastLength, slowLength, signalLength)

// Average True Range (ATR)
atr = ta.atr(atrLength)

// --- Volatility-Adjusted Gap Filter ---
macdSignalGap = macdLine - signalLine
normalizedGap = atr > 0 ? (macdSignalGap / atr) : 0

// --- Condition Logic ---
efiAboveZero = efi > 0
efiBelowZero = efi < 0

// Standard crossover rules vs Volatility-filtered crossover rules
macdAboveSignal = macdLine > signalLine
macdBelowSignal = macdLine < signalLine

macdValidBullish = useAtrFilter ? (normalizedGap > atrThreshold) : macdAboveSignal
macdValidBearish = useAtrFilter ? (normalizedGap < -atrThreshold) : macdBelowSignal

// Core Signals
bool longCondition  = efiAboveZero and macdValidBullish
bool shortCondition = efiBelowZero and macdValidBearish

// --- Advanced Feature 1: Multi-Shade Gradients ---
macdGrowing = ta.rising(math.abs(macdHist), 1)
bool longStrong  = ta.rising(efi, 1) and macdGrowing
bool shortStrong = ta.falling(efi, 1) and macdGrowing

color c_green = useGradient ? (longStrong ? #00ff88 : #00aa55) : color.green
color c_red   = useGradient ? (shortStrong ? #ff3344 : #aa2233) : color.red
color c_blue  = useGradient ? (efi >= 0 ? #3399ff : #1155aa) : color.blue

// Assign column heights and color palettes
float plotValue = na
color histColor = na

if longCondition
    plotValue := 1.0
    histColor := c_green
else if shortCondition
    plotValue := -1.0
    histColor := c_red
else
    plotValue := (efi >= 0) ? 0.5 : -0.5
    histColor := c_blue

// --- Rendering ---
hline(0, 'Zero Line', color = color.new(color.gray, 50), linestyle = hline.style_dashed)

// Core Visual Columns
plot(plotValue, title = 'EFI+MACD Bias', color = histColor, style = plot.style_columns, linewidth = 4)

// --- Advanced Feature 2: Early Warning Reversal Signals ---
// FIXED: Replaced recursive self-checks with proper history indices [1]
bool longExhaustion  = longCondition[1] and not longCondition and (ta.falling(efi, 1) or not macdValidBullish)
bool shortExhaustion = shortCondition[1] and not shortCondition and (ta.rising(efi, 1) or not macdValidBearish)

plotshape(showShapes and longExhaustion ? 1.1 : na, title = 'Long Exit Warning', style = shape.triangledown, location = location.absolute, color = color.orange, size = size.small)
plotshape(showShapes and shortExhaustion ? -1.1 : na, title = 'Short Exit Warning', style = shape.triangleup, location = location.absolute, color = color.orange, size = size.small)

// --- Advanced Feature 3: Optimized Alert Engine ---
// FIXED: Restored index offsets [1] to allow state transitions to trigger alerts correctly
alertcondition(longCondition and not longCondition[1], title = 'New Bullish Alignment', message = 'EFI and MACD are aligned BULLISH on {{exchange}}:{{ticker}} ({{interval}} frame)') 
alertcondition(shortCondition and not shortCondition[1], title = 'New Bearish Alignment', message = 'EFI and MACD are aligned BEARISH on {{exchange}}:{{ticker}} ({{interval}} frame)') 
alertcondition(longExhaustion or shortExhaustion, title = 'Trend Exhaustion Warning', message = 'EFI/MACD alignment has broken down on {{exchange}}:{{ticker}}')
````
