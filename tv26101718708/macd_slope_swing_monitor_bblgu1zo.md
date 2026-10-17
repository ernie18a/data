# MACD Slope & Swing Monitor

- url: https://www.tradingview.com/script/bbLGU1ZO/
- type: indicator
- pine_id: PUB;9c22d7d601f24298ab959c752c11e3dc
- version: 2.0

## Description

This script is not just another MACD. It is a highly specialized momentum engine designed to quantify trend exhaustion and visualize structural pivots, making it the perfect tool for trading advanced concepts like the "Anti-Setup" (popularized by Linda Raschke) and Hidden Divergences.

While standard MACD shows you the current momentum, it often lags during complex corrections (like Elliott Wave 4th waves or Flat corrections). This indicator solves this by introducing real-time Slope Quantification and past Swing Pivot Detection.

Key Features & The Logic Behind the Mashup:
Dynamic Slope Quantification: Calculates the exact rate of change (Slope) for both the MACD and Signal lines over a user-defined lookback period. This allows traders to spot momentum decay before an actual crossover occurs. The exact values are displayed on a clean, dynamic label that tracks the current bar.

Structural Swing Detection (Pivots): Uses a 5-bar left/right lookback to plot Swing Highs and Lows directly on the oscillator. By locking these markers to the top and bottom of the pane, the script keeps the MACD lines perfectly clean. This is crucial for instantly identifying Hidden Divergences against previous structural peaks.

Custom MA Engine: Unlike standard built-in MACD, this script allows you to independently change the Moving Average type (SMA, EMA, WMA, RMA) for both the Oscillator and the Signal line. (e.g., using EMA for the oscillator and SMA for the signal to refine trade timing).

How to Use:
Trend Continuation (Hidden Divergence): Look for price to make a Lower High / Higher Low, while the MACD Swing markers show a Higher High / Lower Low.

The "Anti" Trigger: Wait for the MACD Slope to sharply reverse back toward the Signal line in the direction of the primary trend. The real-time label will confirm the momentum shift mathematically before the visual hook forms.

## Source Code

````pine
// MACD & Signal の「傾き」と「スイング」を暴く術（ピボット期間調整版）
//@version=5
indicator("MACD Slope & Swing Monitor (Dashboard)", overlay=false)

// パラメータ設定
fast_length   = input.int(12, "MACD Fast Length")
slow_length   = input.int(26, "MACD Slow Length")
signal_length = input.int(9,  "MACD Signal Length")
osc_ma_type   = input.string("EMA", "Oscillator MA type", options=["SMA", "EMA", "WMA", "RMA"])
sig_ma_type   = input.string("SMA", "Signal MA type", options=["SMA", "EMA", "WMA", "RMA"])
lookback      = input.int(3,  "Slope Lookback Period", minval=1)

// ★追加：スイング（ピボット）の期間設定（デフォルトを7に変更）
pivot_left    = input.int(7, "Swing Pivot Left Bars", minval=1)
pivot_right   = input.int(7, "Swing Pivot Right Bars", minval=1)

// MAを計算するカスタム関数
get_ma(src, length, type) =>
    switch type
        "SMA" => ta.sma(src, length)
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        => ta.ema(src, length)

// MACDとSignalの独自計算エンジン
fast_ma    = get_ma(close, fast_length, osc_ma_type)
slow_ma    = get_ma(close, slow_length, osc_ma_type)
macdLine   = fast_ma - slow_ma
signalLine = get_ma(macdLine, signal_length, sig_ma_type)
histLine   = macdLine - signalLine

// 傾き（Slope）の計算
macd_slope   = (macdLine - macdLine[lookback]) / lookback
signal_slope = (signalLine - signalLine[lookback]) / lookback

// ヒストグラムの色分け
hist_color = histLine >= 0 ? (histLine[1] < histLine ? #26A69A : #B2DFDB) : (histLine[1] < histLine ? #EF5350 : #FFCDD2)

// --- 描画 ---
plot(histLine, title="Histogram", color=hist_color, style=plot.style_histogram, linewidth=4)
plot(macdLine, title="MACD", color=#2962FF, linewidth=1)
plot(signalLine, title="Signal", color=#FF6D00, linewidth=1)
hline(0, "Zero Line", color=color.new(color.gray, 70), linestyle=hline.style_dashed)

// ★修正：Swing High & Lowの検出と描画（設定値に連動、オフセットも自動調整）
swing_high = ta.pivothigh(macdLine, pivot_left, pivot_right)
swing_low  = ta.pivotlow(macdLine, pivot_left, pivot_right)

plotshape(swing_high, style=shape.triangledown, location=location.top, color=color.new(#E040FB, 50), size=size.tiny, offset=-pivot_right, title="Swing High")
plotshape(swing_low,  style=shape.triangleup,   location=location.bottom, color=color.new(#00BCD4, 50), size=size.tiny, offset=-pivot_right, title="Swing Low")

// ダッシュボード（Table）の作成
var table slopePanel = table.new(position.top_right, 1, 2, bgcolor=color.new(color.black, 100), frame_width=0)

if barstate.islast
    // 矢印の判定
    m_dir = macd_slope > 0 ? "▲ " : macd_slope < 0 ? "▼ " : "― "
    s_dir = signal_slope > 0 ? "▲ " : signal_slope < 0 ? "▼ " : "― "
    
    // 表示テキストの作成
    macdText   = "MACD Slope: " + m_dir + str.tostring(macd_slope, "#.#####")
    signalText = "Signal Slope: " + s_dir + str.tostring(signal_slope, "#.#####")
    
    // テーブルの書き込み
    table.cell(slopePanel, 0, 0, macdText, text_color=#2962FF, text_size=size.normal, text_halign=text.align_right)
    table.cell(slopePanel, 0, 1, signalText, text_color=#FF6D00, text_size=size.normal, text_halign=text.align_right)
````
