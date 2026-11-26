# MACD + RSI + EFI + CVD PRO

- url: https://www.tradingview.com/script/4Xa0dgpl-macd-rsi-efi-cvd-pro/
- type: indicator
- pine_id: PUB;52bb4f7e800442efab8ab5f01b1c60b8
- version: 1.0

## Description

Скрипка — струнный смычковый музыкальный инструмент высокого регистра, используемый как сольно, так и в составе оркестра. Обладает богатым звучанием и широким диапазоном возможностей. Один из самых популярных инструментов в классической музыке, также находит применение в джазе, фолке, роке и других стилях.

## Source Code

````pine
//@version=6
indicator("MACD + RSI + EFI + CVD PRO", overlay=false, format=format.volume)

import TradingView/ta/8

// ===================== MACD INPUTS =====================
src           = input.source(close, "Source")
fast_length   = input.int(12, "MACD Fast Length")
slow_length   = input.int(26, "MACD Slow Length")
signal_length = input.int(9,  "MACD Signal Smoothing", minval=1)

hist_scale     = input.float(1.0, "Histogram Scale", step=0.1)
normalize_hist = input.bool(false, "Normalize Histogram")
norm_period    = input.int(100, "Normalization Period")

col_grow_above = input.color(#26A69A, "Grow Above (rising)")
col_fall_above = input.color(#B2DFDB, "Grow Above (falling)")
col_grow_below = input.color(#FFCDD2, "Grow Below (rising)")
col_fall_below = input.color(#EF5350, "Grow Below (falling)")
col_macd       = input.color(#0094ff, "MACD line")
col_signal     = input.color(#ff6a00, "Signal line")
line_w         = input.int(2, "Line width", minval=1, maxval=5)

// ===================== MACD =====================
fast_ma = ta.ema(src, fast_length)
slow_ma = ta.ema(src, slow_length)

macd   = fast_ma - slow_ma
signal = ta.ema(macd, signal_length)
hist   = macd - signal

norm_denom = math.max(ta.highest(math.abs(hist), norm_period), 1e-10)
hist_plot  = normalize_hist ? hist / norm_denom : hist * hist_scale

hist_color =
     hist >= 0 ?
         (hist > hist[1] ? col_grow_above : col_fall_above) :
         (hist > hist[1] ? col_grow_below : col_fall_below)

plot(hist_plot, title="Histogram", style=plot.style_columns, color=hist_color)
plot(macd,   "MACD",   color=col_macd,   linewidth=line_w)
plot(signal, "Signal", color=col_signal, linewidth=line_w)

hline(0)

// ===================== RSI =====================
rsi_len = input.int(14, "RSI Length")
rsi     = ta.rsi(src, rsi_len)

rsi_overbought = input.int(70, "RSI Overbought")
rsi_oversold   = input.int(30, "RSI Oversold")

rsi_scale = input.float(0.00035, "RSI Scale")

rsi_plot = (rsi - 50) * rsi_scale
ob_level = (rsi_overbought - 50) * rsi_scale
os_level = (rsi_oversold - 50) * rsi_scale

plot(rsi_plot, color=color.purple, title="RSI", linewidth=2)

h_ob = hline(ob_level, "Overbought", color=color.red)
h_os = hline(os_level, "Oversold", color=color.green)

fill(h_ob, h_os, color=color.new(color.purple, 90))

// ===================== EFI =====================
efi_len = input.int(13, "EFI Length")
efi_raw = (close - close[1]) * volume
efi     = ta.ema(efi_raw, efi_len)

efi_scale = input.float(0.0000001, "EFI Scale")
plot(efi * efi_scale, color=color.green, linewidth=2, title="EFI")

// ===================== CVD =====================
anchorInput = input.timeframe("1D", "CVD Anchor Period")
useCustomTimeframe = input.bool(false, "Use custom CVD timeframe")
lowerTFInput = input.timeframe("1", "CVD Lower TF", active=useCustomTimeframe)

lowerTF = useCustomTimeframe ? lowerTFInput :
     timeframe.isseconds  ? "1S" :
     timeframe.isintraday ? "1"  :
     timeframe.isdaily    ? "5"  :
     "60"

[openVol, maxVol, minVol, lastVol] = ta.requestVolumeDelta(lowerTF, anchorInput)

cvd_scale = input.float(0.0000001, "CVD Scale")
cvd_value = lastVol * cvd_scale

cvd_color = lastVol >= openVol ? color.teal : color.red

plot(cvd_value, color=cvd_color, linewidth=2, title="CVD")

// Проверка объема
var float cumVol = 0.0
cumVol += nz(volume)

if barstate.islast and cumVol == 0
    runtime.error("No volume data for this symbol.")
````
