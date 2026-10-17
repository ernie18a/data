# SMC Alpha Order Overlay

- url: https://www.tradingview.com/script/C69PxmyU-SMC-Alpha-Order-Overlay/
- type: indicator
- pine_id: PUB;7768c58a34a249a89e7a4e962f5705eb
- version: 1.0

## Description

The **SMC Alpha Order Overlay** is a lightweight and clean technical analysis tool designed to help traders identify the macro trend and key structural levels on their charts. 

By utilizing classic pivot logic and moving averages, this indicator automatically highlights significant historical turning points without lagging your chart performance.

### Key Features:
* **200 EMA (Macro Trend Filter):** Automatically plots a 200 Exponential Moving Average. It serves as a visual guide for the primary market direction (Bullish bias when price is above, Bearish bias when price is below).
* **Pivot-Based Support & Resistance:** Uses a 10-period pivot lookback to pinpoint accurate swing highs and swing lows.
* **Break-Line Visualization:** Plots levels using a clean, non-intrusive breaking line style (`style_linebr`) accompanied by clear "RES" (Resistance) and "SUP" (Support) labels exactly where the structural pivot occurred.

### How to Use:
* **Trend Alignment:** Look for buying opportunities when the price trades above the yellow 200 EMA line and selling opportunities when it trades below.
* **Key Levels:** Use the automatically generated Red (RES) and Green (SUP) price levels to identify historical liquidity pools, potential reversal zones, or targets for your trades.

## Source Code

````pine
//@version=6
indicator("SMC Alpha Order Overlay", shorttitle="SMC Alpha", overlay=true)

// --- EMA 200 ---
ema_len = input.int(200, title="EMA Length", minval=1)
ema_200 = ta.ema(close, ema_len)
// Διορθώθηκε: Αφαιρέθηκαν τα εισαγωγικά, μπήκε το καθαρό hex χρώμα
plot(ema_200, "EMA 200", color=#ffeb3b, linewidth=2) 

// --- Support & Resistance Inputs ---
sr_pivot_length = input.int(10, title="S/R Pivot Lookback", minval=1)
sr_show = input.bool(true, title="Show S/R Levels")

// --- S/R Calculation ---
ph_sr = ta.pivothigh(high, sr_pivot_length, sr_pivot_length)
pl_sr = ta.pivotlow(low, sr_pivot_length, sr_pivot_length)

// --- Ασφαλής υπολογισμός για την έκδοση 6 ---
float res_val = na
float sup_val = na

if sr_show and not na(ph_sr)
    res_val := high[sr_pivot_length]

if sr_show and not na(pl_sr)
    sup_val := low[sr_pivot_length]

// --- Plotting levels as breaking lines ---
plot(res_val, "Resistance", color=color.red, linewidth=2, style=plot.style_linebr, offset=-sr_pivot_length)
plot(sup_val, "Support", color=color.green, linewidth=2, style=plot.style_linebr, offset=-sr_pivot_length)

// --- Labels for pivots ---
if sr_show and not na(ph_sr)
    label.new(bar_index[sr_pivot_length], high[sr_pivot_length], "RES", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)

if sr_show and not na(pl_sr)
    label.new(bar_index[sr_pivot_length], low[sr_pivot_length], "SUP", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)
````
