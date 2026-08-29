<!-- tradingview-pine-id: PUB;0a960ccd601141ef818428ad8753d72d -->
<!-- tradingviewscripts-format: 1 -->
# Normalized Ichimoku Oscillator

Source: https://www.tradingview.com/script/cSiGmGMD-Normalized-Ichimoku-Oscillator/

## Description

Overview

The Normalized Ichimoku Oscillator (NIO) transforms the comprehensive insight of the classic Ichimoku Kinko Hyo system into a dedicated momentum oscillator.

While a standard Ichimoku chart is an all-in-one indicator for momentum, trend direction, and support/resistance levels, it can sometimes be difficult to gauge how far price has stretched relative to historical limits. The NIO solves this by measuring the distance between price and the core Ichimoku lines, normalizing them using Average True Range (ATR) to create a clear, bounded perspective.

The Core Concept: Kijun-sen as the Primary Anchor

While price distance from key levels can be visualized on a standard chart, this oscillator quantifies those deviations against historical volatility:

[*]The Primary Line (Kijun-sen): The oscillator centers heavily on the Kijun-sen (Base Line). The Kijun-sen distance serves as your main gauge for medium-term trend stretch and mean reversion.

[*]Supplementary Lines: The Tenkan-sen, Span A, and Span B lines are also included as optional overlays. They allow you to track short-term momentum or cloud-edge distances alongside your primary Kijun-sen analysis, but can be toggled off to keep the chart clean.  

Key Features

[*]ATR Normalization: Converts raw price distances into volatility-adjusted units, making overbought and oversold thresholds reliable across different market conditions and asset volatilitites.

[*]Dedicated Kijun MA: Includes a customizable smoothing Moving Average (EMA, SMA, or HMA) applied to the Kijun deviation line to help spot momentum shifts and trigger crosses.

[*]Overbought / Oversold Thresholds: Features distinct warning and extreme zones (e.g., +/- 2.0 and +/- 3.0 ATR) to help identify potential market exhaustion or trend reversal points.

[*]Visual Shading & Alerts: Dynamic zero-line fill highlights whether price is stretched above or below equilibrium, backed by automated alerts for extreme deviations.

---

## Source Code

````pine
//@version=6
indicator("Normalized Ichimoku Oscillator", shorttitle="NIO", overlay=false)

// ==========================================
// 1. INPUTS
// ==========================================
grp_ichimoku = "Ichimoku Lengths"
tenkanLen = input.int(9, "Tenkan-sen Period", minval=1, group=grp_ichimoku)
kijunLen  = input.int(26, "Kijun-sen Period", minval=1, group=grp_ichimoku)
spanBLen  = input.int(52, "Senkou Span B Period", minval=1, group=grp_ichimoku)
atrLen    = input.int(14, "ATR Normalization Length", minval=1, group=grp_ichimoku)

grp_ma = "Kijun Deviation MA"
showKijunMA = input.bool(true, "Show Kijun MA", group=grp_ma)
maType      = input.string("EMA", "Moving Average Type", options=["EMA", "SMA", "HMA"], group=grp_ma)
maLen       = input.int(10, "MA Length", minval=1, group=grp_ma)

grp_vis = "Oscillator Visibility"
showTenkan = input.bool(true, "Show Tenkan Deviation", group=grp_vis)
showKijun  = input.bool(true, "Show Kijun Deviation (Primary)", group=grp_vis)
showSpanA  = input.bool(true, "Show Span A Deviation", group=grp_vis)
showSpanB  = input.bool(true, "Show Span B Deviation", group=grp_vis)

grp_levels = "Threshold Settings"
obExtreme  = input.float(3.0, "Overbought Extreme", step=0.1, group=grp_levels)
obWarning  = input.float(2.0, "Overbought Warning", step=0.1, group=grp_levels)
osWarning  = input.float(-2.0, "Oversold Warning", step=0.1, group=grp_levels)
osExtreme  = input.float(-3.0, "Oversold Extreme", step=0.1, group=grp_levels)

// ==========================================
// 2. CALCULATIONS
// ==========================================
get_donchian(len) => math.avg(ta.highest(high, len), ta.lowest(low, len))

tenkan = get_donchian(tenkanLen)
kijun  = get_donchian(kijunLen)
spanA  = math.avg(tenkan, kijun)
spanB  = get_donchian(spanBLen)
atr    = ta.atr(atrLen)

// Normalized Distances
oscTenkan = atr > 0 ? (close - tenkan) / atr : 0
oscKijun  = atr > 0 ? (close - kijun) / atr : 0
oscSpanA  = atr > 0 ? (close - spanA) / atr : 0
oscSpanB  = atr > 0 ? (close - spanB) / atr : 0

// MA Calculation Logic
get_ma(src, len, type) =>
    switch type
        "SMA" => ta.sma(src, len)
        "HMA" => ta.hma(src, len)
        => ta.ema(src, len) // Default to EMA

kijunMA = get_ma(oscKijun, maLen, maType)

// ==========================================
// 3. PLOTTING
// ==========================================
p_zero = plot(0, "Equilibrium", color=color.gray, linewidth=1)

plot(showTenkan ? oscTenkan : na, color=color.blue, title="Tenkan Dev")
p_k = plot(showKijun ? oscKijun : na, color=color.white, title="Kijun Dev", linewidth=2)
plot(showSpanA ? oscSpanA : na, color=color.green, title="Span A Dev")
plot(showSpanB ? oscSpanB : na, color=color.orange, title="Span B Dev")

// Plot the selected MA
plot(showKijunMA ? kijunMA : na, color=color.yellow, title="Kijun MA", linewidth=1)

// Shading
fill(p_k, p_zero, oscKijun > 0 ? color.new(color.green, 80) : color.new(color.red, 80), title="Kijun Shading")

// Thresholds
hline(obExtreme, "OB Extreme", color=color.red, linewidth=2)
hline(obWarning, "OB Warning", color=color.new(color.red, 50), linestyle=hline.style_dotted)
hline(osWarning, "OS Warning", color=color.new(color.green, 50), linestyle=hline.style_dotted)
hline(osExtreme, "OS Extreme", color=color.green, linewidth=2)

// ==========================================
// 4. ALERTS
// ==========================================
alertcondition(ta.crossunder(oscKijun, obExtreme), title="Kijun OB Alert", message="Price at 3.0 ATR Kijun Overbought")
alertcondition(ta.crossover(oscKijun, osExtreme), title="Kijun OS Alert", message="Price at -3.0 ATR Kijun Oversold")
````
