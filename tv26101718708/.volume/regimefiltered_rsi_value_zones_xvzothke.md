# Regime-Filtered RSI Value Zones

- url: https://www.tradingview.com/script/XvzOthke-Regime-Filtered-RSI-Value-Zones/
- type: indicator
- pine_id: PUB;e035a7a2c8684553a284a6c3868272b9
- version: 1.0

## Description

Regime-Filtered RSI Value Zones (RFRVZ)

// A three-layer RSI system combining regime detection, momentum direction
// and Z-score confirmation to identify dynamic DCA buy and sell value zones.

A three-layer RSI-based indicator designed to identify high-probability DCA accumulation and distribution zones on any asset.
How it works:
Layer 1 — RSI Momentum Direction
A user-selectable Moving Average is applied directly to the RSI to identify the current momentum direction. Eight MA types are available including SMA, EMA, HMA, DEMA and TEMA giving full flexibility to tune sensitivity. The MA line plots green when RSI is above it and red when below — providing instant momentum bias at a glance.
Layer 2 — RSI Z-Score
The RSI is normalised against its own recent historical distribution using a Z-Score. This identifies whether current RSI momentum is statistically above or below its recent mean — filtering out weak or noise-driven signals and confirming only statistically meaningful momentum moves.
Layer 3 — DCA Value Zones
Two user-defined RSI threshold levels define the Buy Zone and Sell Zone. When RSI drops into the Buy Zone the panel highlights blue and a single DCA In label fires on entry. When RSI reaches the Sell Zone the panel highlights brown and a DCA Out label fires. Labels are state-managed — one label per zone visit, no repeats until RSI exits and re-enters the zone.
Features:

8 selectable MA types for the RSI smoothing layer
Fully adjustable Buy and Sell Zone thresholds
Adjustable Overbought and Oversold reference levels
Optional Z-Score plot rescaled to RSI scale for direct visual comparison
Toggle for DCA In / Out labels
Clean panel background zone highlighting

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Av4link
// Regime-Filtered RSI Value Zones (RFRVZ)
// A three-layer RSI system combining regime detection, momentum direction
// and Z-score confirmation to identify dynamic DCA buy and sell value zones.


import TradingView/ta/10 as ta

//@version=6
indicator("Regime-Filtered RSI Value Zones", shorttitle = "RFRVZ")

// RSI & MA - Double Trouble
// . string option with all of the MA's & a adjustable length parameter with plotting for every MA. 
// . RSI Indicator linked with the MA's adjustable length parameter & optional plotting. 

// Inputs  
grp1 = "RSI & Moving Average's"
grp2 = "Z-Score & DCA in/out Zones"
src_ma   = input.source(high, "RSI & MA Source", group = grp1)

maType = input.string(title="MA Type (RSI)", defval="EMA", options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"], group = grp1)
regime_ma = input.string(title="Regime MA", defval="DEMA", options=["SMA","EMA","WMA","VWMA","HMA","RMA","DEMA","TEMA"], group = grp1)

rsiLength = input.int(24, "RSI Length", minval=1, group = grp1)
len_ma   = input.int(title="(RSI) MA Length", defval=35, minval=1, group = grp1)

len_regimema = input.int(title="Regime MA Length", defval=185, minval=1, group = grp1)

// RSI Threshold Inputs
rsi_ob = input.int(60, "Overbought Level", minval = 50, maxval = 100, group = grp1)
rsi_os = input.int(40, "Oversold Level",  minval = 0,  maxval = 50,  group = grp1)

plotRSI   = input.bool(true, "Plot RSI?", group = grp1)
plotToggle = input.bool(true, "Plot MA?", group = grp1)

// RSI Calculation 
rsi = ta.rsi(src_ma, rsiLength)

ma_rsi =
     maType == "SMA"  ? ta.sma(rsi, len_ma)  :
     maType == "EMA"  ? ta.ema(rsi, len_ma)  :
     maType == "WMA"  ? ta.wma(rsi, len_ma)  :
     maType == "VWMA" ? ta.vwma(rsi, len_ma) :
     maType == "HMA"  ? ta.hma(rsi, len_ma)  :
     maType == "RMA"  ? ta.rma(rsi, len_ma)  :
     maType == "DEMA" ? ta.dema(rsi, len_ma) :
     maType == "TEMA" ? ta.tema(rsi, len_ma) :
     na

Bull_bear_regime_ma =
     regime_ma == "SMA"  ? ta.sma(close, len_regimema) :
     regime_ma == "EMA"  ? ta.ema(close, len_regimema) :
     regime_ma == "WMA"  ? ta.wma(close, len_regimema) :
     regime_ma == "VWMA" ? ta.vwma(close, len_regimema) :
     regime_ma == "HMA"  ? ta.hma(close, len_regimema) :
     regime_ma == "RMA"  ? ta.rma(close, len_regimema) :
     regime_ma == "DEMA" ? ta.dema(close, len_regimema) :
     regime_ma == "TEMA" ? ta.tema(close, len_regimema) :
     na


// ── RSI Z-Score (applied to RSI — feeds yellow plot) ─────────────────────────
zscore_len   = input.int(27,  "Z-Score Length",    minval=1,           group=grp2)
entry_threshold = input.float(1.1, "Entry Threshold", minval=0.5, maxval=3.0, step=0.1, group=grp2)
plotZscore   = input.bool(false, "Plot Z-Score?",   group=grp2)
showDcaLabels = input.bool(false, "Show DCA In / Out Labels?", group=grp2)

rsi_zscore   = (rsi - ta.sma(rsi, zscore_len)) / ta.stdev(rsi, zscore_len)

// ── Price Z-Score (applied to close — feeds trade conditions) ─────────────────
mean         = ta.sma(close, zscore_len)
stdDev       = ta.stdev(close, zscore_len)
zScore       = stdDev > 0 ? (close - mean) / stdDev : 0
smoothZ      = ta.ema(zScore, 3)

// entry_threshold now actually used
zscore_long  = (smoothZ > entry_threshold)
zscore_short = (smoothZ < entry_threshold)

// zscore_bull   = rsi_zscore > 0
// zscore_bear   = rsi_zscore < 0

// Value Zone Inputs
rsi_buy_zone  = input.int(35, "Buy Zone Level",  minval=0,  maxval=50,  group=grp2)
rsi_sell_zone = input.int(78, "Sell Zone Level", minval=50, maxval=100, group=grp2)

// Z-Score Bull Bear Market Regime Section.
bull_regime = (close > Bull_bear_regime_ma)
bear_regime = (close < Bull_bear_regime_ma)

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// Signal Logic
// rsi_long  = ta.crossover(rsi, ma_rsi)
// rsi_short = ta.crossunder(rsi, ma_rsi)

rsi_long  = (rsi > ma_rsi)
rsi_short = (rsi < ma_rsi)

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// PLOTTING -- PLOTTING -- PLOTTING -- \\
// Zone colour logic
rsi_color = rsi <= rsi_buy_zone  ? color.new(color.blue, 0) :
             rsi >= rsi_sell_zone ? color.new(#8B4513, 0)    :
             rsi > ma_rsi         ? color.new(color.lime, 40) :
                                   color.new(color.red, 40)

// Color rules: green if price above MA, red if below
maColor = rsi > ma_rsi ? color.lime : color.red
// Plot the selected MA only if enabled
plot(plotToggle ? ma_rsi : na, "Selected MA", color = maColor, linewidth = 3)


// Plot RSI
hline(rsi_ob, "Overbought", color = color.red, linewidth = 1)
hline(rsi_os, "Oversold",  color = color.lime, linewidth = 1)
hline(50, "Neutral", color = color.gray, linestyle = hline.style_dotted)
plot(plotRSI ? rsi : na, "RSI", color=rsi_color, linewidth=2)

// Zone hlines — add these alongside your existing hlines
hline(rsi_buy_zone,  "Buy Zone",  color=color.new(color.blue,  40), linewidth=1, linestyle=hline.style_dashed)
hline(rsi_sell_zone, "Sell Zone", color=color.new(#8B4513,     40), linewidth=1, linestyle=hline.style_dashed)


// Panel background shading when inside a zone
bgcolor(rsi <= rsi_buy_zone  ? color.new(color.blue,  77) : na, title="Buy Zone Background")
bgcolor(rsi >= rsi_sell_zone ? color.new(#8B4513,     77) : na, title="Sell Zone Background")

// ── DCA Labels ────────────────────────────────────────────────────────────────

plotshape(showDcaLabels and rsi <= rsi_buy_zone  and not (rsi[1] <= rsi_buy_zone)  ? rsi_buy_zone  - 3 : na,
          title="DCA In",  text="DCA In",  style=shape.labelup,
          location=location.absolute,
          color=color.new(color.blue, 0), textcolor=color.white, size=size.small)

plotshape(showDcaLabels and rsi >= rsi_sell_zone and not (rsi[1] >= rsi_sell_zone) ? rsi_sell_zone + 3 : na,
          title="DCA Out", text="DCA Out", style=shape.labeldown,
          location=location.absolute,
          color=color.new(#8B4513, 0), textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════

// Rescale Z-Score to RSI scale (centres at 50, readable alongside RSI)
zscore_scaled = 50 + (rsi_zscore * 10)
plot(plotZscore ? zscore_scaled : na, "Z-Score", color=color.new(color.yellow, 0), linewidth=1)


// ── Signal Status Table ───────────────────────────────────────────────────────
var table signalTable = table.new(position.top_left, 2, 4,
     border_width=2, border_color=color.new(#9B59B6, 40),
     frame_width=2,  frame_color=color.new(#9B59B6, 20))

// Determine signal values
zscore_signal = smoothZ > entry_threshold     ? 1 : -1
regime_signal = close   > Bull_bear_regime_ma ? 1 : -1
rsi_signal    = rsi     > ma_rsi              ? 1 : -1

// Signal colors
zscore_col = zscore_signal == 1 ? color.new(#27AE60, 10) : color.new(#E74C3C, 10)
regime_col = regime_signal == 1 ? color.new(#27AE60, 10) : color.new(#E74C3C, 10)
rsi_col    = rsi_signal    == 1 ? color.new(#27AE60, 10) : color.new(#E74C3C, 10)

// Signal text
zscore_txt = zscore_signal == 1 ? "▲  1" : "▼  -1"
regime_txt = regime_signal == 1 ? "▲  1" : "▼  -1"
rsi_txt    = rsi_signal    == 1 ? "▲  1" : "▼  -1"

// Header row
table.cell(signalTable, 0, 0, "⬡  SIGNAL",
     text_color=color.new(#E8DAEF, 0), bgcolor=color.new(#6C3483, 10),
     text_size=size.normal, text_halign=text.align_left)
table.cell(signalTable, 1, 0, "STATUS",
     text_color=color.new(#E8DAEF, 0), bgcolor=color.new(#6C3483, 10),
     text_size=size.normal, text_halign=text.align_center)

// RSI row
table.cell(signalTable, 0, 1, "◈  RSI Trend",
     text_color=color.new(#D7BDE2, 0), bgcolor=color.new(#1A1A2E, 20),
     text_size=size.normal, text_halign=text.align_left)
table.cell(signalTable, 1, 1, rsi_txt,
     text_color=color.white, bgcolor=rsi_col,
     text_size=size.normal, text_halign=text.align_center)

// Regime MA row
table.cell(signalTable, 0, 2, "◈  Regime MA",
     text_color=color.new(#D7BDE2, 0), bgcolor=color.new(#1A1A2E, 20),
     text_size=size.normal, text_halign=text.align_left)
table.cell(signalTable, 1, 2, regime_txt,
     text_color=color.white, bgcolor=regime_col,
     text_size=size.normal, text_halign=text.align_center)

// Z-Score row
table.cell(signalTable, 0, 3, "◈  Z-Score Trend",
     text_color=color.new(#D7BDE2, 0), bgcolor=color.new(#1A1A2E, 20),
     text_size=size.normal, text_halign=text.align_left)
table.cell(signalTable, 1, 3, zscore_txt,
     text_color=color.white, bgcolor=zscore_col,
     text_size=size.normal, text_halign=text.align_center)
````
