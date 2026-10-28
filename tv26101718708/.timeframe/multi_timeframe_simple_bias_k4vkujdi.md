# Multi Timeframe Simple Bias

- url: https://www.tradingview.com/script/K4vKUJDi/
- type: indicator
- pine_id: PUB;34e5315c3a1f484181b1f20af3770c30
- version: 2.0

## Description

Multi Timeframe Simple Bias by MoneyK is a clean and compact multi-timeframe trend dashboard designed to provide an immediate view of directional bias across several market horizons.

How it works

The indicator compares the closing price of each timeframe with its own 50-period Exponential Moving Average (EMA).

UP — price is above the EMA 50.

DOWN — price is below the EMA 50.

Each timeframe is calculated independently, so the dashboard provides a simple snapshot of short-term, intraday, swing, and higher-timeframe direction without requiring the user to switch charts.

Timeframes

The table displays:

1M · 5M · 15M · 1H · 4H · 1D · 1W

This makes it easy to identify whether several timeframes are aligned or whether the market is showing mixed directional conditions.

Visual Design

The indicator uses a compact centered table with simple color coding:

Green = UP

Red = DOWN

The table size can be adjusted to suit different chart layouts.

An optional EMA 50 can also be displayed directly on the current chart. It is hidden by default to keep the workspace clean.

Intended Use

Multi Timeframe Simple Bias is designed as a quick visual context tool rather than a standalone entry or exit system.

It can be useful for:

Checking directional alignment across multiple timeframes.

Identifying conflicting short-term and higher-timeframe conditions.

Adding simple trend context to an existing trading methodology.

Avoiding unnecessary chart switching during intraday analysis.

The indicator intentionally keeps its logic simple: one consistent EMA-based bias definition applied across every timeframe.

Credits

This script is based on the open-source “Bias TF Table” by Martyn8.

The original concept and EMA-based multi-timeframe bias logic are credited to Martyn8.

This MoneyK adaptation adds a revised timeframe structure including the 1-minute timeframe, a centered compact presentation, adjustable table sizing, simplified settings, fixed EMA 50 bias reference, and an updated visual layout.

Published open-source in accordance with TradingView's rules for adaptations of open-source scripts.

Disclaimer

This indicator is intended for technical analysis and informational purposes only. It does not provide financial advice or constitute a recommendation to buy or sell any financial instrument.

## Source Code

````pine
//@version=6
indicator("Multi Timeframe Simple Bias", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
emaLength = 50
showEma   = input.bool(false, title="Show EMA on Chart", display=display.none)
tableSize = input.string("Small", title="Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

// ─────────────────────────────────────────────────────────────────────────────
// ORIGINAL BIAS ENGINE — UNCHANGED
// ─────────────────────────────────────────────────────────────────────────────
f_get_bias(_tf) =>
    price_tf = request.security(syminfo.tickerid, _tf, close)
    ema_tf   = request.security(syminfo.tickerid, _tf, ta.ema(close, emaLength))
    bias     = price_tf > ema_tf ? "UP" : "DOWN"
    color    = price_tf > ema_tf ? color.rgb(5, 49, 1) : color.rgb(116, 1, 1)
    [bias, color]

[bias_1m, color_1m]   = f_get_bias("1")
[bias_5m, color_5m]   = f_get_bias("5")
[bias_15m, color_15m] = f_get_bias("15")
[bias_1h, color_1h]   = f_get_bias("60")
[bias_4h, color_4h]   = f_get_bias("240")
[bias_d, color_d]     = f_get_bias("D")
[bias_w, color_w]     = f_get_bias("W")

// ─────────────────────────────────────────────────────────────────────────────
// TABLE VISUALS
// ─────────────────────────────────────────────────────────────────────────────
f_table_text_size(_size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

headerBg = color.rgb(24, 24, 24)
labelBg  = color.rgb(52, 52, 52)
frameCol = color.rgb(92, 92, 92)
textCol  = color.white
txtSize  = f_table_text_size(tableSize)

var biasTable = table.new(
     position.top_center,
     8,
     2,
     bgcolor=color.new(color.black, 100),
     frame_color=frameCol,
     frame_width=1,
     border_color=color.rgb(70, 70, 70),
     border_width=1)

if barstate.islast
    table.cell(biasTable, 0, 0, "TF",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 1, 0, "1M",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 2, 0, "5M",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 3, 0, "15M", text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 4, 0, "1H",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 5, 0, "4H",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 6, 0, "1D",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 7, 0, "1W",  text_color=textCol, bgcolor=headerBg, text_size=txtSize, text_halign=text.align_center)

    table.cell(biasTable, 0, 1, "BIAS",   text_color=textCol, bgcolor=labelBg,    text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 1, 1, bias_1m,  text_color=textCol, bgcolor=color_1m,  text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 2, 1, bias_5m,  text_color=textCol, bgcolor=color_5m,  text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 3, 1, bias_15m, text_color=textCol, bgcolor=color_15m, text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 4, 1, bias_1h,  text_color=textCol, bgcolor=color_1h,  text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 5, 1, bias_4h,  text_color=textCol, bgcolor=color_4h,  text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 6, 1, bias_d,   text_color=textCol, bgcolor=color_d,   text_size=txtSize, text_halign=text.align_center)
    table.cell(biasTable, 7, 1, bias_w,   text_color=textCol, bgcolor=color_w,   text_size=txtSize, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────────────────────────
// EMA DISPLAY
// ─────────────────────────────────────────────────────────────────────────────
plot(showEma ? ta.ema(close, emaLength) : na, color=color.rgb(247, 247, 248), linewidth=1, title="EMA", display=display.all - display.status_line - display.price_scale)
````
