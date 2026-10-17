# SEPA Tightness Monitor

- url: https://www.tradingview.com/script/lvsW5y3q-SEPA-Tightness-Monitor/
- type: indicator
- pine_id: PUB;ab64d2b4044542f897c1d3a7f3af86a1
- version: 1.0

## Description

SEPA Tightness Monitor

This indicator is adapted from a community Pine Script by TradingView user sabesh12, originally published as "Minervini SEPA Pro - Master Dashboard." The original script combined multiple elements including a moving average dashboard, ATR volatility cloud, dynamic stop loss line, and VCP pivot detection into a single overlay.

This version strips the indicator down to its single most useful component for our needs: the **Volatility Contraction Pattern (VCP) tightness calculation**. Tightness is measured as the percentage range between the highest high and lowest low over the last N bars (default 5), expressed as a percentage of the low. When this value drops below 3%, the base is compressing into the kind of tight, low-volatility coil that Mark Minervini's SEPA methodology identifies as a potential breakout setup.

The dashboard displays the current tightness reading alongside the three core moving averages (SMA 50, 150, 200). A "TIGHT" label appears on the chart when tightness is sub-3% and a partial Stage 2 condition is met (price above SMA150, SMA150 above SMA200, SMA50 above SMA150, price above SMA50). Note this Stage 2 check covers four of Minervini's seven Trend Template criteria — it is a partial filter, not a full confirmation.

ATR-based stop loss, the volatility cloud, EMA21, and the candle move display from the original script have been removed. The dynamic ATR stop conflicts with SEPA's chart-based stop placement methodology and should not be used as a position management tool.

## Source Code

````pine
//@version=5
indicator("SEPA Tightness Monitor", overlay=true)

// --- INPUTS ---
sma50Len  = input.int(50,  "SMA 50",  group="Moving Averages")
sma150Len = input.int(150, "SMA 150", group="Moving Averages")
sma200Len = input.int(200, "SMA 200", group="Moving Averages")
vcpLook   = input.int(5,   "VCP Lookback (bars)", group="VCP Logic")
vcpThresh = input.float(3.0, "Tightness Threshold %", group="VCP Logic")

// --- CALCULATIONS ---
sma50  = ta.sma(close, sma50Len)
sma150 = ta.sma(close, sma150Len)
sma200 = ta.sma(close, sma200Len)

// Tightness
high5 = ta.highest(high, vcpLook)
low5  = ta.lowest(low, vcpLook)
vcpTightness = ((high5 - low5) / low5) * 100
isTight = vcpTightness < vcpThresh

// Partial Stage 2 check (4/7 criteria — not full TT)
isStage2Partial = close > sma150 and sma150 > sma200 and sma50 > sma150 and close > sma50

// POI label — only when tight AND partial Stage 2
if isTight and isStage2Partial
    label.new(bar_index, high, "TIGHT", color=color.green, 
              textcolor=color.white, style=label.style_label_down, size=size.small)

// --- DASHBOARD TABLE (minimal) ---
var table dash = table.new(position.bottom_right, 2, 4, border_width=1, frame_color=color.gray)

f_cell(_row, _label, _val, _col) =>
    table.cell(dash, 0, _row, _label, bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=size.small)
    table.cell(dash, 1, _row, _val,   bgcolor=_col,                      text_color=color.white, text_size=size.small)

if barstate.islast
    f_cell(0, "Tightness (VCP)", str.tostring(vcpTightness, "#.##") + "%", 
           isTight ? color.green : color.gray)
    f_cell(1, "SMA 50",  str.tostring(sma50,  "#.##"), color.new(color.blue,   20))
    f_cell(2, "SMA 150", str.tostring(sma150, "#.##"), color.new(color.orange, 20))
    f_cell(3, "SMA 200", str.tostring(sma200, "#.##"), color.new(color.red,    20))
````
