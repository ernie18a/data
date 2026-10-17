# MTF Price Line SNIPER AUTO

- url: https://www.tradingview.com/script/yzRhMgJr/
- type: indicator
- pine_id: PUB;4965e51759dc4131b6feaca726f031b3
- version: 1.0

## Description

A professional multi-timeframe price line overlay designed to visualize market structure, momentum, and higher-timeframe context in a single, clean view. This tool replaces traditional candles with smooth price lines and provides flexible combinations for different trading styles—from fast M1 scalping to higher-timeframe bias analysis.

Core Concept

The indicator plots multiple dynamically scaled price lines based on the current chart timeframe:

Chart TF (M1 / current TF) → Entry & execution
x5 → Short-term flow
x15 → Intraday trend structure
H1 → Higher-timeframe context
H4 → Macro direction

All higher timeframes are automatically recalculated relative to your current chart timeframe. This ensures consistency whether you are on M1, M5, or M15—without using traditional HTF requests (no step-like plotting).

Key Features
Smooth Line Rendering
No stair-stepping. All lines are synthetically calculated for a continuous, fluid appearance.
Auto Multi-Timeframe Scaling
Timeframes adjust automatically when switching charts (e.g., M1 → M5 → M15).
Independent Visibility Controls
Each timeframe (Chart, x5, x15, H1, H4) can be individually enabled or disabled.
Customizable Appearance
Fully adjustable colors and line widths for each timeframe.
Momentum Coloring (M1)
Optional neon-based momentum coloring on the chart timeframe:
Green → bullish momentum
Red → bearish momentum
Momentum Overlay on x15 (Optional)
The x15 line can reflect M1 momentum, allowing you to view lower-timeframe pressure within higher-timeframe structure.
RSI-Based Coloring (Optional)
Global RSI filter for overbought/oversold conditions across all lines.
How to Use
1. Pure Line Chart Mode
Disable TradingView candles
Use only the indicator lines
→ Clean structure view (ideal for flow & trend reading)
2. Hybrid Mode (Recommended)
Keep TradingView candles ON
Disable selected lines (e.g., Chart TF or x5)

Example:

Candles ON
Chart line OFF
x5 ON
→ You get candles for execution + x5 flow overlay
Typical Configurations

Scalping (M1)

Chart TF: ON
x5: ON
x15: optional
H1/H4: OFF

Sniper Entries

Chart TF: ON
x5: ON
x15: ON

Bias / Direction

x15: ON
H1: ON
H4: ON
Chart TF: optional
Interpretation
Alignment across timeframes → high-probability moves
Chart TF leads, higher TFs follow → confirms trend development
Divergence between TFs → pullback or weak structure
Flat / crossing lines → ranging market (low quality conditions)
Important Notes
This is a synthetic MTF model, not a direct higher-timeframe feed
Designed for clarity and responsiveness, not lagging confirmation
Best used in combination with your execution logic
Summary

MTF Price Line SNIPER transforms raw price into a structured, multi-layered visual system:

Entry timing (M1)
Flow (x5)
Trend (x15)
Context (H1 / H4)

All in one adaptive, customizable overlay.

## Source Code

````pine
//@version=6
indicator("MTF Price Line SNIPER AUTO (5 TF + MOM + RSI)", overlay=true)

//━━━━━━━━━━ INPUTS ━━━━━━━━━━
src = input.source(close, "Price Source")

// TF TOGGLES
show_chart = input.bool(true, "Show Chart TF")
show_x5    = input.bool(true, "Show x5")
show_x15   = input.bool(true, "Show x15")
show_h1    = input.bool(true, "Show H1")
show_h4    = input.bool(true, "Show H4")

//━━━━━━━━━━ MOMENTUM M1 ━━━━━━━━━━
useMomentum = input.bool(true, "Momentum Color (M1)")
momLen      = input.int(1, "M1 Momentum Sensitivity")

//━━━━━━━━━━ MOMENTUM x15 (NEU LOGIK) ━━━━━━━━━━
useMomentum15 = input.bool(false, "Momentum Color x15 (uses M1)")

// COLORS MOMENTUM
colBull = input.color(color.lime, "Neon Green")
colBear = input.color(color.red, "Neon Red")

//━━━━━━━━━━ RSI ━━━━━━━━━━
useRSI  = input.bool(true, "RSI Coloring")
rsiLen  = input.int(14, "RSI Length")
obLevel = input.int(70)
osLevel = input.int(30)

//━━━━━━━━━━ COLORS BASE ━━━━━━━━━━
col_chart = input.color(color.white, "Chart Color")
col_x5    = input.color(color.orange, "x5 Color")
col_x15   = input.color(color.aqua, "x15 Color")
col_h1    = input.color(color.fuchsia, "H1 Color")
col_h4    = input.color(color.yellow, "H4 Color")

colOB = input.color(color.red, "Overbought Color")
colOS = input.color(color.lime, "Oversold Color")

//━━━━━━━━━━ WIDTH ━━━━━━━━━━
w_chart = input.int(2, "Chart Width")
w_x5    = input.int(2, "x5 Width")
w_x15   = input.int(3, "x15 Width")
w_h1    = input.int(4, "H1 Width")
w_h4    = input.int(5, "H4 Width")

//━━━━━━━━━━ TF IN MINUTEN ━━━━━━━━━━
tf_sec = timeframe.in_seconds(timeframe.period)
tf_min = tf_sec / 60.0

//━━━━━━━━━━ MULTIPLIER (AUTO) ━━━━━━━━━━
mult_chart = 1
mult_x5    = 5
mult_x15   = 15

mult_h1 = math.max(math.round(60 / tf_min), 1)
mult_h4 = math.max(math.round(240 / tf_min), 1)

//━━━━━━━━━━ FUNKTION ━━━━━━━━━━
f_price(_src, mult) =>
    ta.sma(_src, int(mult))

//━━━━━━━━━━ PREISE ━━━━━━━━━━
price_chart = f_price(src, mult_chart)
price_x5    = f_price(src, mult_x5)
price_x15   = f_price(src, mult_x15)
price_h1    = f_price(src, mult_h1)
price_h4    = f_price(src, mult_h4)

//━━━━━━━━━━ RSI ━━━━━━━━━━
rsi_val = ta.rsi(src, rsiLen)

//━━━━━━━━━━ MOMENTUM (M1 BASIS) ━━━━━━━━━━
momUp   = price_chart > price_chart[momLen]
momDown = price_chart < price_chart[momLen]

//━━━━━━━━━━ COLOR LOGIK ━━━━━━━━━━
f_rsi_col(base) =>
    useRSI ? (rsi_val > obLevel ? colOB : rsi_val < osLevel ? colOS : base) : base

// M1 Linie (Priorität: Momentum > RSI > Base)
col_chart_final =
     useMomentum ? (momUp ? colBull : momDown ? colBear : col_chart)
     : f_rsi_col(col_chart)

// x5 Linie (nur RSI)
col5 = f_rsi_col(col_x5)

// x15 Linie (JETZT: nutzt M1 Momentum!)
col15 =
     useMomentum15 ? (momUp ? colBull : momDown ? colBear : col_x15)
     : f_rsi_col(col_x15)

// H1 & H4
col60  = f_rsi_col(col_h1)
col240 = f_rsi_col(col_h4)

//━━━━━━━━━━ PLOT ━━━━━━━━━━
plot(show_chart ? price_chart : na, color=col_chart_final, linewidth=w_chart, title="Chart TF")
plot(show_x5    ? price_x5    : na, color=col5,  linewidth=w_x5,  title="x5")
plot(show_x15   ? price_x15   : na, color=col15, linewidth=w_x15, title="x15")
plot(show_h1    ? price_h1    : na, color=col60, linewidth=w_h1,  title="H1")
plot(show_h4    ? price_h4    : na, color=col240,linewidth=w_h4,  title="H4")
````
