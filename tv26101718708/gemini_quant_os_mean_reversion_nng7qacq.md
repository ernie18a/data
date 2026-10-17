# Gemini Quant OS -Mean Reversion 

- url: https://www.tradingview.com/script/nNG7QaCQ/
- type: indicator
- pine_id: PUB;fba73a56aee94a6a95d1ff27ef4974f0
- version: 1.0

## Description

Gemini Quant OS — Mean Reversion

Overview

Gemini Quant OS — Mean Reversion is a price exhaustion and reversal detection framework designed to identify potential mean reversion opportunities across financial markets.

This script is part of the broader Gemini Quant OS ecosystem.


---

Core Concepts

The framework analyzes statistical price extension and attempts to identify situations where price may be stretched away from its short-term equilibrium.

The model combines:

deviation analysis

volatility bands

ATR expansion

momentum exhaustion

RSI filtering

trend context analysis


The goal is to help traders identify areas where price conditions may become temporarily overextended.


---

Features

Mean reversion signal detection

Price exhaustion zones

Volatility-aware framework

Multi-market compatibility

Adaptive filtering logic

Trend context integration



---

Best Use Cases

Best suited for:

ranging markets

exhaustion phases

volatility spikes

pullback analysis

H1–D1 environments



---

Notes

This script is intended for educational and analytical purposes only.

Not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Gemini_Quant_Lab
//@version=6
indicator("Gemini Mean Reversion Detector", overlay=true, max_labels_count=500)

//==============================
// Inputs (match EA logic)
//==============================
len         = input.int(50, "Regression Period", minval=2)
sigma_entry = input.float(2.0, "Entry Sigma", step=0.1)
sigma_stop  = input.float(3.5, "Stop Sigma", step=0.1)

// Display options
show_fill        = input.bool(true,  "Fill Entry Zone")
show_signals     = input.bool(true,  "Show Entry Signals")
confirm_on_close = input.bool(false, "Confirm signals on bar close")

//==============================
// Core calculations
//==============================

// Linear regression mean
basis = ta.linreg(close, len, 0)

// Standard deviation (visual approximation)
dev = ta.stdev(close, len)

// Safety guard (avoid div by 0 / na)
dev_safe = (not na(dev) and dev != 0.0) ? dev : na

// Bands
upper_entry = basis + dev_safe * sigma_entry
lower_entry = basis - dev_safe * sigma_entry
upper_stop  = basis + dev_safe * sigma_stop
lower_stop  = basis - dev_safe * sigma_stop

// Z-score
z_score = (not na(dev_safe)) ? (close - basis) / dev_safe : na

//==============================
// Plotting
//==============================
plot(basis, title="Mean (Exit)", color=color.gray, linewidth=2)

p_upper = plot(upper_entry, title="Upper Entry Band", color=color.red,   style=plot.style_linebr)
p_lower = plot(lower_entry, title="Lower Entry Band", color=color.green, style=plot.style_linebr)

plot(upper_stop, title="Upper Stop Band", color=color.maroon, style=plot.style_circles)
plot(lower_stop, title="Lower Stop Band", color=color.navy,   style=plot.style_circles)

// IMPORTANT: fill() cannot be used in local scope (inside if)
// Use conditional color instead.
fill(p_upper, p_lower, color = show_fill ? color.new(color.blue, 92) : na)

//==============================
// Entry signals
//==============================
raw_sell = ta.crossover(close, upper_entry)
raw_buy  = ta.crossunder(close, lower_entry)

// If confirm_on_close = true, only fire on confirmed bar close
sell_signal = confirm_on_close ? (raw_sell and barstate.isconfirmed) : raw_sell
buy_signal  = confirm_on_close ? (raw_buy  and barstate.isconfirmed) : raw_buy

// IMPORTANT: Use single-line plotshape to avoid hidden NBSP chars causing EOL errors
plotshape(show_signals and sell_signal, title="SHORT", location=location.abovebar, style=shape.labeldown,
     color=color.red, text="SHORT\n>2σ", textcolor=color.white, size=size.tiny)

plotshape(show_signals and buy_signal, title="LONG", location=location.belowbar, style=shape.labelup,
     color=color.green, text="LONG\n<-2σ", textcolor=color.white, size=size.tiny)

//==============================
// Alerts
//==============================
alertcondition(sell_signal, title="Mean Reversion SHORT", message="Quant MR SHORT signal")
alertcondition(buy_signal,  title="Mean Reversion LONG",  message="Quant MR LONG signal")

//==============================
// Dashboard (Top Right)
//==============================
var table panel = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast
    // Row 0: Z-Score
    table.cell(panel, 0, 0, "Z-Score", bgcolor=color.black, text_color=color.white)
    table.cell(panel, 1, 0,
         na(z_score) ? "NA" : str.tostring(z_score, "#.##"),
         bgcolor = na(z_score) ? color.gray : (z_score >= 0 ? color.red : color.green),
         text_color=color.white)

    // Row 1: Price
    table.cell(panel, 0, 1, "Price", bgcolor=color.black, text_color=color.white)
    table.cell(panel, 1, 1, str.tostring(close, format.mintick), bgcolor=color.gray, text_color=color.white)

    // Row 2: Mean
    table.cell(panel, 0, 2, "Mean", bgcolor=color.black, text_color=color.white)
    table.cell(panel, 1, 2, str.tostring(basis, format.mintick), bgcolor=color.gray, text_color=color.white)

    // Row 3: Dev
    table.cell(panel, 0, 3, "Dev", bgcolor=color.black, text_color=color.white)
    table.cell(panel, 1, 3, na(dev_safe) ? "NA" : str.tostring(dev_safe, format.mintick), bgcolor=color.gray, text_color=color.white)
````
