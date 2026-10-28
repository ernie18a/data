# GBR MTF Scalp Sniper [Trend + Volatility]

- url: https://www.tradingview.com/script/Jbrom1Xy-GBR-MTF-Scalp-Sniper-Trend-Volatility/
- type: indicator
- pine_id: PUB;fcb1b25efa11401899aabc1446954f1f
- version: 1.0

## Description

The GBR MTF Scalp Sniper is designed for aggressive 5-minute scalpers who want precision without fighting the macro trend.

🔥 Core Features:

HTF Boss Filter: Automatically pulls a higher timeframe (e.g., 1H) trend filter. It strictly prevents you from taking LONG signals in a Macro Bear Market, and SHORT signals in a Macro Bull Market.

Micro Trigger: Uses a fast momentum crossover to snipe entries right as the pullback ends and the main trend resumes.

Volatility Shield: Built-in ATR volume filter ensures signals are only generated when the market is actively moving, keeping you out of dead consolidation chop.

Zero Clutter: No messy moving averages painted all over your screen. Just a highly visible, minimalist UV Green ▲ or UV Red ▼ when the conditions align perfectly.

🎯 Execution: Best used on a 5m chart alongside the GBR Smart Delta. Enter on the arrow, place your stop loss behind the recent pivot, and ride the macro trend.

## Source Code

````pine
//@version=6
indicator("GBR MTF Scalp Sniper", overlay=true, max_labels_count=200)

// ==========================================
// 1. SETTINGS (UI)
// ==========================================
grp1 = "Macro Trend Filter (The Boss)"
macroTf  = input.timeframe("60", title="HTF Timeframe (e.g. 1H)", group=grp1)
macroLen = input.int(50, title="HTF EMA Length", group=grp1)

grp2 = "Micro Trigger (The Sniper)"
microLen = input.int(9, title="Micro EMA Length", group=grp2)
useVol   = input.bool(true, title="Use ATR Volatility Filter", group=grp2)

// ==========================================
// 2. GBR CORPORATE IDENTITY (UV COLORS)
// ==========================================
colBuy  = color.new(#00FF00, 0) // UV Green (Buy)
colSell = color.new(#FF0033, 0) // UV Red (Sell)

// ==========================================
// 3. LOGIC & CALCULATIONS
// ==========================================
// Macro Trend (HTF)
macroEma = ta.ema(close, macroLen)
htfTrend = request.security(syminfo.tickerid, macroTf, macroEma)

// Micro Trend (Current TF)
microEma = ta.ema(close, microLen)

// Volatility Filter (Is the market actually moving?)
myAtr = ta.atr(14)
avgAtr = ta.sma(myAtr, 50)
volFilter = useVol ? (myAtr > avgAtr) : true

// ==========================================
// 4. SIGNAL GENERATION
// ==========================================
// LONG: Ár a makro trend felett, momentum felfelé tör, és van volatilitás
longCond  = close > htfTrend and ta.crossover(close, microEma) and volFilter

// SHORT: Ár a makro trend alatt, momentum lefelé tör, és van volatilitás
shortCond = close < htfTrend and ta.crossunder(close, microEma) and volFilter

// ==========================================
// 5. DRAWING SIGNALS (Minimalist Labels)
// ==========================================
if longCond
    label.new(bar_index, low - ta.atr(14), text="▲", color=color.new(color.white, 100), textcolor=colBuy, style=label.style_label_up, size=size.normal)

if shortCond
    label.new(bar_index, high + ta.atr(14), text="▼", color=color.new(color.white, 100), textcolor=colSell, style=label.style_label_down, size=size.normal)
````
