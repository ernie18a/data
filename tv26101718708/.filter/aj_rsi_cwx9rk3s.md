# AJ - RSI

- url: https://www.tradingview.com/script/cwX9Rk3s-AJ-RSI/
- type: indicator
- pine_id: PUB;6169d112778143b692e1bc47c5e57403
- version: 3.0

## Description

# AJ - RSI — Multi-Timeframe RSI with Configurable Higher-TF Lock

## Overview
**AJ - RSI** is a clean, publish-ready Relative Strength Index that lets you **lock the RSI calculation to any timeframe you choose**, regardless of the timeframe your chart is on. By default it displays the **Monthly RSI (14)** on every chart — 1 minute, 1 hour, daily, weekly, monthly — so you always keep the higher-timeframe trend context in front of you while trading a lower timeframe.

## What makes it different
- **Timeframe-locked RSI:** Trade on a 15-minute chart while watching the true Monthly RSI. No need to flip charts.
- **Matches the built-in RSI exactly** on the requested timeframe (same length, same source, same math) — verified against TradingView's native RSI.
- **Non-repainting historical data.** Uses `request.security` with `barmerge.lookahead_off`, so no future-leak on closed bars.
- **Configurable RSI-based MA** (SMA / EMA / WMA / RMA) with adjustable length.
- **Three clear reference bands** — Overbought (80, red dotted), Midline (50, green solid), Oversold (30, green dotted) — with a subtle shaded zone for readability.

## How to use
- **Trend filter:** Monthly RSI > 50 = long-term uptrend bias; < 50 = downtrend bias. Trade lower-TF setups only in the direction of the higher-TF regime.
- **Momentum shifts:** A monthly RSI crossover above 50 often marks a durable trend change; crossunder below 50 signals loss of long-term momentum.
- **Overbought / Oversold:** Readings above 80 or below 30 on the higher timeframe highlight stretched conditions worthy of caution or mean-reversion attention.
- **RSI vs. its MA:** Use crossovers of the RSI and its moving average as an early momentum confirmation.
- **Weekly / Daily setups:** Change the Timeframe input to Weekly, Daily, or any other TF to reuse the same framework at different horizons.

## Inputs
**RSI**
- RSI Length (default 14)
- Source (default close)
- Timeframe — Chart, 1 min, 5 min, 1 Hour, 1 Day, 1 Week, 1 Month, Quarter (default 1 Month). Select "Chart" to follow the current chart timeframe.

**RSI Moving Average**
- MA Length (default 14)
- MA Type — SMA / EMA / WMA / RMA (default SMA)

**Levels**
- Upper Band (default 80, red dotted)
- Mid Band (default 50, green solid)
- Lower Band (default 30, green dotted)

## Built-in alerts
- RSI crosses above 50
- RSI crosses below 50
- RSI crosses above the Upper Band
- RSI crosses below the Lower Band

## Notes on behavior
- On the current (still-forming) higher-timeframe bar, the RSI updates in real time — the same way the built-in RSI would if you switched the chart to that timeframe. Historical bars are stable.
- The Line style / color / thickness of every plot and band can be adjusted from the indicator's **Style** tab.

## Disclaimer
This script is provided for educational and informational purposes only. It is not financial advice and does not constitute a recommendation to buy or sell any security. Past performance of any indicator does not guarantee future results. Always do your own research and manage your risk.

**Author:** Ayyanar Jayabalan

## Source Code

````pine
//@version=6
// ============================================================================
// Name   : AJ - RSI  v1.1
// Author : Ayyanar Jayabalan
// ----------------------------------------------------------------------------
// Multi-timeframe RSI that stays locked to a chosen timeframe (default: 1 Month)
// regardless of the chart timeframe. Select "Chart" to follow the chart TF.
// Non-repainting on historical bars via request.security + lookahead_off.
// ============================================================================
indicator("AJ - RSI", shorttitle="AJ-RSI", overlay=false, precision=2)

// ---------------- Inputs ----------------
grpCore   = "RSI"
rsiLen    = input.int(14, "RSI Length", minval=1, group=grpCore)
srcSel    = input.source(close, "Source", group=grpCore)

tfChoice  = input.string("1 Month", "Timeframe",
     options=["Chart","1 min","5 min","1 Hour","1 Day","1 Week","1 Month","Quarter"],
     tooltip="Locks RSI to this timeframe regardless of chart TF. 'Chart' follows the chart.",
     group=grpCore)

grpMA     = "RSI Moving Average"
maLen     = input.int(14, "MA Length", minval=1, group=grpMA)
maType    = input.string("SMA", "MA Type", options=["SMA","EMA","WMA","RMA"], group=grpMA)

grpLevels = "Levels"
upperLvl  = input.int(80, "Upper Band", group=grpLevels)
midLvl    = input.int(50, "Mid Band",   group=grpLevels)
lowerLvl  = input.int(30, "Lower Band", group=grpLevels)

grpRS      = "Relative Strength (vs Index)"
rsEnable   = input.bool(false, "Show Relative Strength", group=grpRS,
     tooltip="Off by default. Enable to compute and plot Mansfield RS vs the benchmark.")
rsSymbol   = input.symbol("NSE:CNX500", "Comparative Index", group=grpRS,
     tooltip="Benchmark used for Mansfield Relative Strength. Default NSE:CNX500.")
rsLen      = input.int(50, "RS Smoothing Length", minval=1, group=grpRS,
     tooltip="Lookback for the ratio SMA in the Mansfield RS formula.")
rsPosCol   = input.color(color.green, "RS Line Color (Above 0)", group=grpRS)
rsNegCol   = input.color(color.red,   "RS Line Color (Below 0)", group=grpRS)
rsZeroCol  = input.color(color.black, "Zero Line Color",         group=grpRS)

grpMk         = "RS Cross Markers (on RSI line)"
showRsMarkers = input.bool(true, "Show RS-Cross Dots on RSI Line", group=grpMk,
     tooltip="Plots a small filled circle on the RSI line when Relative Strength (vs Index) crosses zero.")
rsUpDotCol    = input.color(color.green, "Above-0 Dot Color", group=grpMk)
rsDnDotCol    = input.color(color.red,   "Below-0 Dot Color", group=grpMk)

// ---------------- Timeframe resolution ----------------
f_tf() =>
    switch tfChoice
        "Chart"   => timeframe.period
        "1 min"   => "1"
        "5 min"   => "5"
        "1 Hour"  => "60"
        "1 Day"   => "D"
        "1 Week"  => "W"
        "1 Month" => "M"
        "Quarter" => "3M"
        => "M"

tfRes = f_tf()

// ---------------- MA helper ----------------
f_ma(series float src, simple int len, simple string t) =>
    switch t
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "RMA" => ta.rma(src, len)
        => ta.sma(src, len)

// ---------------- Calculations ----------------
// Match built-in RSI on the target TF exactly: request the current higher-TF
// value with lookahead_off (safe, no future leak). On the current bar this
// reflects the still-forming higher-TF RSI, identical to what the built-in
// RSI shows when the chart is switched to that TF.
rsiTF = ta.rsi(srcSel, rsiLen)
maTF  = f_ma(rsiTF, maLen, maType)

rsiVal = request.security(syminfo.tickerid, tfRes, rsiTF, lookahead=barmerge.lookahead_off)
maVal  = request.security(syminfo.tickerid, tfRes, maTF,  lookahead=barmerge.lookahead_off)

// ---------------- Relative Strength (Mansfield) ----------------
// RS% = ((Stock / Index) / SMA(Stock / Index, len) - 1) * 100
// Positive = stock outperforming the benchmark; Negative = underperforming.
idxClose = request.security(rsSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)
ratio    = idxClose != 0 ? close / idxClose : na
rsRaw    = (ratio / ta.sma(ratio, rsLen) - 1) * 100
rsSeries = rsEnable ? rsRaw : na
rsColor  = rsSeries >= 0 ? rsPosCol : rsNegCol

// RS zero-crossings — computed independently of rsEnable so the dot markers
// on the RSI line can be shown even when the RS line itself is hidden.
rsCrossUp = ta.crossover(rsRaw, 0)
rsCrossDn = ta.crossunder(rsRaw, 0)

// ---------------- RSI Line Coloring ----------------
// State tracks the most recent RS zero-crossing direction.
// 1 = bullish (after green dot), -1 = bearish (after red dot), 0 = no cross yet.
var int rsState = 0
if rsCrossUp
    rsState := 1
if rsCrossDn
    rsState := -1

lightGreenCol = #90EE90
darkGreenCol  = #006400
lightRedCol   = #FF7F7F
darkRedCol    = #CC0000

// Dark green  : green state + above mid band
// Light green : green state + below mid band, OR no state + above RSI MA
// Dark red    : red state + below mid band
// Light red   : red state + above mid band, OR no state + below RSI MA
rsiLineColor = switch
    rsState == 1  and rsiVal >= midLvl  => darkGreenCol
    rsState == 1  and rsiVal <  midLvl  => lightGreenCol
    rsState == -1 and rsiVal <= midLvl  => darkRedCol
    rsState == -1 and rsiVal >  midLvl  => lightRedCol
    rsiVal > maVal                      => lightGreenCol
    => lightRedCol

// ---------------- Plots ----------------
plot(rsiVal, title="RSI",    color=rsiLineColor,   linewidth=2, style=plot.style_line)
// RSI MA: thin line at 50% opacity. Change Line Style to "Dashed" from the
// Style tab if you prefer a hyphen/dashed look (Pine can't set that default).
plot(maVal,  title="RSI MA", color=color.new(color.black, 50), linewidth=1, style=plot.style_line)

hline(upperLvl, title="Upper Band", color=color.new(color.red, 0),   linestyle=hline.style_dotted, linewidth=1)
hline(midLvl,   title="Mid Band",   color=color.new(color.green, 0), linestyle=hline.style_solid,  linewidth=1)
hline(lowerLvl, title="Lower Band", color=color.new(color.green, 0), linestyle=hline.style_dotted, linewidth=1)

// Subtle fill between upper and lower for readability (hidden by default;
// enable from the Style tab if you want the shaded band).
uBand = hline(upperLvl, display=display.none)
lBand = hline(lowerLvl, display=display.none)
fill(uBand, lBand, color=color.new(color.gray, 92), title="Band Fill", display=display.none)

// ---------------- Relative Strength plot ----------------
// Tip: RS oscillates around 0 while RSI is 0-100. Right-click the RS plot and
// choose "Move to > New pane" (or a separate scale) if you want it on its own axis.
plot(rsSeries, title="Relative Strength", color=rsColor, linewidth=1, style=plot.style_line)
hline(0, title="RS Zero Line", color=rsZeroCol, linestyle=hline.style_dotted, linewidth=1, display=display.none)

// RS-cross markers plotted at the RSI value so they sit on the RSI line.
plotshape(showRsMarkers and rsCrossUp ? rsiVal : na, title="RS Cross Up (on RSI)",
     style=shape.circle, location=location.absolute, color=rsUpDotCol, size=size.tiny)
plotshape(showRsMarkers and rsCrossDn ? rsiVal : na, title="RS Cross Down (on RSI)",
     style=shape.circle, location=location.absolute, color=rsDnDotCol, size=size.tiny)

alertcondition(ta.crossover(rsSeries, 0),  title="RS crosses above 0", message="Relative Strength crossed above 0 (outperforming benchmark)")
alertcondition(ta.crossunder(rsSeries, 0), title="RS crosses below 0", message="Relative Strength crossed below 0 (underperforming benchmark)")

// ---------------- Alerts ----------------
alertcondition(ta.crossover(rsiVal, midLvl),  title="RSI crosses above 50", message="RSI crossed above 50")
alertcondition(ta.crossunder(rsiVal, midLvl), title="RSI crosses below 50", message="RSI crossed below 50")
alertcondition(ta.crossover(rsiVal, upperLvl),  title="RSI crosses above Upper", message="RSI crossed above upper band")
alertcondition(ta.crossunder(rsiVal, lowerLvl), title="RSI crosses below Lower", message="RSI crossed below lower band")
````
