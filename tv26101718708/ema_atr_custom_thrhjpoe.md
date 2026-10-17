# EMA + ATR (Custom)

- url: https://www.tradingview.com/script/THrHJPOE-EMA-ATR-Custom/
- type: indicator
- pine_id: PUB;42c4c76374134465867f73111257f721
- version: 2.0

## Description

EMA + ATR (Custom)
Calculate and plot 1.0, 1.5 ATR

## Source Code

````pine
//@version=6
// EMA + ATR 
// Purpose: EMA + ATR 
// Author: Baltser Anton
// version 1.0
indicator("EMA + ATR (Custom)", overlay=true)

// ─── EMA inputs ───────────────────────────────────────────────────────────────
ema_enabled = input.bool(true,  "EMA enabled",  group="EMA")
ema_period   = input.int(125,   "EMA period",   minval=1, group="EMA")

// ─── ATR inputs ───────────────────────────────────────────────────────────────
atr_enabled      = input.bool(true,  "ATR enabled",        group="ATR")
atr_period       = input.int(14,     "ATR period",         minval=1, group="ATR")
atr_line1_enabled  = input.bool(true, "Show Price - ATR",     group="ATR")
atr_line15_enabled = input.bool(true, "Show Price - 1.5 ATR", group="ATR")
atr_sline1_enabled  = input.bool(true, "Show Price + ATR",     group="ATR")
atr_sline15_enabled = input.bool(true, "Show Price + 1.5 ATR", group="ATR")

// ══════════════════════════════════════════════════════════════════════════════
// EMA  — SMA seed (matches MT5 iMA MODE_EMA): first `period` bars averaged,
//         then standard EMA: k = 2/(period+1)
// ══════════════════════════════════════════════════════════════════════════════
var float ema_value  = 0.0
var float ema_sum    = 0.0
var int   ema_count  = 0
var bool  ema_ready  = false

float k = 2.0 / (ema_period + 1)

if not ema_ready
    ema_sum   := ema_sum + close
    ema_count := ema_count + 1
    if ema_count >= ema_period
        ema_value := ema_sum / ema_period  // SMA seed — same starting point as MT5
        ema_ready := true
else
    ema_value := close * k + ema_value * (1 - k)

float ema_plot = (ema_enabled and ema_ready) ? ema_value : na

plot(ema_plot, title="EMA", color=color.new(color.blue, 0), linewidth=2)

// ══════════════════════════════════════════════════════════════════════════════
// ATR  — mirrors ATRManager (Wilder smoothing, SMA seed after `period` bars)
// ══════════════════════════════════════════════════════════════════════════════
float prev_close = nz(close[1], close)

// True Range
float tr = math.max(
     high - low,
     math.abs(high - prev_close),
     math.abs(low  - prev_close)
     )

var float atr_value   = 0.0
var int   atr_count   = 0
var bool  atr_ready   = false
var float atr_sum     = 0.0   // accumulates TR for the SMA seed

if not atr_ready
    atr_sum   := atr_sum + tr
    atr_count := atr_count + 1
    if atr_count >= atr_period
        atr_value := atr_sum / atr_period
        atr_ready := true
else
    // Wilder smoothing: ATR = (ATR * (period - 1) + TR) / period
    atr_value := (atr_value * (atr_period - 1) + tr) / atr_period

float atr_plot = (atr_enabled and atr_ready) ? atr_value : na

// ATR displayed in a separate pane
plot(atr_plot, title="ATR", color=color.new(color.orange, 0), linewidth=1, display=display.pane)

// Price ± ATR lines on the main chart
float atr_line1_plot   = (atr_enabled and atr_ready and atr_line1_enabled)   ? close - atr_value       : na
float atr_line15_plot  = (atr_enabled and atr_ready and atr_line15_enabled)  ? close - atr_value * 1.5 : na
float atr_sline1_plot  = (atr_enabled and atr_ready and atr_sline1_enabled)  ? close + atr_value       : na
float atr_sline15_plot = (atr_enabled and atr_ready and atr_sline15_enabled) ? close + atr_value * 1.5 : na

plot(atr_line1_plot,   title="Price - ATR",       color=color.new(color.orange, 0), linewidth=1, style=plot.style_line)
plot(atr_line15_plot,  title="Price - 1.5x ATR",  color=color.new(color.yellow, 0), linewidth=1, style=plot.style_line)
plot(atr_sline1_plot,  title="Price + ATR",        color=color.new(color.orange, 0), linewidth=1, style=plot.style_line)
plot(atr_sline15_plot, title="Price + 1.5x ATR",   color=color.new(color.yellow, 0), linewidth=1, style=plot.style_line)

// ══════════════════════════════════════════════════════════════════════════════
// ATR table — bottom-right corner
// ══════════════════════════════════════════════════════════════════════════════
if atr_enabled and barstate.islast
    var table atr_table = table.new(position.bottom_right, 4, 6,
         border_width=1,
         border_color=color.new(color.gray, 60),
         bgcolor=color.new(color.black, 70))

    // header row
    table.cell(atr_table, 0, 0, "ATR x",    text_color=color.gray,   text_size=size.small)
    table.cell(atr_table, 1, 0, "Value",    text_color=color.gray,   text_size=size.small)
    table.cell(atr_table, 2, 0, "%",        text_color=color.gray,   text_size=size.small)
    table.cell(atr_table, 3, 0, "Price-x",  text_color=color.gray,   text_size=size.small)

    string atr_str       = atr_ready ? str.tostring(atr_value,               format.mintick) : "—"
    string atr15_str     = atr_ready ? str.tostring(atr_value * 1.5,         format.mintick) : "—"
    string atr_pct       = atr_ready ? str.tostring(atr_value       / close * 100, "#.##") + "%" : "—"
    string atr15_pct     = atr_ready ? str.tostring(atr_value * 1.5 / close * 100, "#.##") + "%" : "—"
    string price_atr     = atr_ready ? str.tostring(close - atr_value,       format.mintick) : "—"
    string price_atr15   = atr_ready ? str.tostring(close - atr_value * 1.5, format.mintick) : "—"
    string sprice_atr    = atr_ready ? str.tostring(close + atr_value,       format.mintick) : "—"
    string sprice_atr15  = atr_ready ? str.tostring(close + atr_value * 1.5, format.mintick) : "—"

    // long side (Price - ATR)
    table.cell(atr_table, 0, 1, "ATR 1.0",   text_color=color.white,  text_size=size.normal)
    table.cell(atr_table, 1, 1, atr_str,     text_color=color.orange, text_size=size.normal)
    table.cell(atr_table, 2, 1, atr_pct,     text_color=color.orange, text_size=size.normal)
    table.cell(atr_table, 3, 1, price_atr,   text_color=color.orange, text_size=size.normal)

    table.cell(atr_table, 0, 2, "ATR 1.5",   text_color=color.white,  text_size=size.normal)
    table.cell(atr_table, 1, 2, atr15_str,   text_color=color.yellow, text_size=size.normal)
    table.cell(atr_table, 2, 2, atr15_pct,   text_color=color.yellow, text_size=size.normal)
    table.cell(atr_table, 3, 2, price_atr15, text_color=color.yellow, text_size=size.normal)

    // separator
    table.cell(atr_table, 0, 3, "─────",     text_color=color.gray,   text_size=size.small)
    table.cell(atr_table, 1, 3, "SHORT",      text_color=color.gray,   text_size=size.small)
    table.cell(atr_table, 2, 3, "─────",     text_color=color.gray,   text_size=size.small)
    table.cell(atr_table, 3, 3, "─────",     text_color=color.gray,   text_size=size.small)

    // short side (Price + ATR)
    table.cell(atr_table, 0, 4, "ATR 1.0",    text_color=color.white,  text_size=size.normal)
    table.cell(atr_table, 1, 4, atr_str,      text_color=color.orange, text_size=size.normal)
    table.cell(atr_table, 2, 4, atr_pct,      text_color=color.orange, text_size=size.normal)
    table.cell(atr_table, 3, 4, sprice_atr,   text_color=color.orange, text_size=size.normal)

    table.cell(atr_table, 0, 5, "ATR 1.5",    text_color=color.white,  text_size=size.normal)
    table.cell(atr_table, 1, 5, atr15_str,    text_color=color.yellow, text_size=size.normal)
    table.cell(atr_table, 2, 5, atr15_pct,    text_color=color.yellow, text_size=size.normal)
    table.cell(atr_table, 3, 5, sprice_atr15, text_color=color.yellow, text_size=size.normal)
````
