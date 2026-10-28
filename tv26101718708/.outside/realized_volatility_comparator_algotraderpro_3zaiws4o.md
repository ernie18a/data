# Realized Volatility Comparator [AlgoTraderPro]

- url: https://www.tradingview.com/script/3ZAiWS4O-Realized-Volatility-Comparator-AlgoTraderPro/
- type: indicator
- pine_id: PUB;d392b4ef5e47488c85bfb92ec6360d8e
- version: 1.0

## Description

[b]What it does[/b]
Plots the annualized realized volatility of the chart's symbol and of a second symbol of your choice in the same pane, so you can compare how "nervous" two assets actually are — and how that changes across years. The default comparison is gold, which makes it useful for one specific long-term study: watching Bitcoin's volatility mature toward that of older stores of value.

[b]How it works[/b]
For each symbol the script computes the standard deviation of logarithmic returns over a configurable window, then annualizes it:

[i]realized vol = stdev( ln(close / close[1]), window ) × √(periods per year) × 100[/i]

The annualization factor is derived from the chart timeframe automatically (a 365-day year), so the reading is comparable across daily and weekly charts. The comparison symbol's volatility is computed in its own symbol context via request.security, using its own bar series. An optional simple moving average smooths both lines, and a readout table shows the current value for each symbol plus the ratio between them.

[b]Inputs[/b]
[list]
[*][i]Realized volatility window[/i] — bars in the standard deviation (default 26; suggested 26 on weekly ≈ six months, 90 on daily ≈ one quarter). Shorter = more reactive, longer = smoother regime view.
[*][i]Smoothing[/i] — SMA applied to both lines; 1 = off.
[*][i]Comparison symbol[/i] — any symbol (default OANDA:XAUUSD). Indices, FX, equities all work.
[*][i]Show readout table[/i] — toggles the current-values table.
[*][i]Colors[/i] — line colors for each series.
[/list]

[b]How to read it[/b]
The absolute level tells you the market's current disagreement about the asset's value: a young or contested asset prints high realized volatility; a settled one prints low. The slope across years tells you whether that disagreement is widening or narrowing. The ratio in the table condenses the comparison into one number — how many times more volatile the chart symbol is than the reference.

[b]Suggested study[/b]
Load on BNC:BLX (Bitcoin Liquid Index, history back to 2010) on a weekly chart with the default gold comparison. The full history shows Bitcoin's realized volatility declining cycle after cycle while gold's stays in a low band — a maturation pattern gold itself went through after 1971.

[b]Other uses[/b]
Position sizing context (size inversely to the regime), comparing any two assets' risk regimes before pairing them in a portfolio, or checking whether a "quiet" market is genuinely quiet by historical standards.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algoTraderGTP

// @version=6
indicator("Realized Volatility Comparator [AlgoTraderPro]", shorttitle="RVC [ATP]", overlay=false)

// ── Inputs ─────────────────────────────────────────────────────────────
rv_len     = input.int(26, "Realized volatility window (bars)", minval=5, maxval=500,
     tooltip="Number of bars used for the standard deviation of log returns. Suggested: 26 on weekly charts (~6 months), 90 on daily charts (~1 quarter).")
smooth_len = input.int(1, "Smoothing (1 = off)", minval=1, maxval=50,
     tooltip="Simple moving average applied to both volatility lines. 1 disables smoothing.")
comp_sym   = input.symbol("OANDA:XAUUSD", "Comparison symbol")
show_table = input.bool(true, "Show readout table")
main_col   = input.color(color.rgb(247, 147, 26), "Main symbol color")      // bitcoin orange
comp_col   = input.color(color.rgb(212, 175, 55), "Comparison symbol color") // gold

// ── Annualization ──────────────────────────────────────────────────────
// Periods per year derived from the chart timeframe (365d year; crypto trades every day)
periods_per_year = 31536000.0 / timeframe.in_seconds(timeframe.period)
ann_factor       = math.sqrt(periods_per_year)

// ── Annualized realized volatility, in percent ─────────────────────────
rv(float src) =>
    float r = math.log(src / src[1])
    ta.stdev(r, rv_len) * ann_factor * 100

main_rv_raw = rv(close)
// Computed inside the comparison symbol's own context so its own bar series is used
comp_rv_raw = request.security(comp_sym, timeframe.period, rv(close))

main_rv = ta.sma(main_rv_raw, smooth_len)
comp_rv = ta.sma(comp_rv_raw, smooth_len)

// ── Plots ──────────────────────────────────────────────────────────────
plot(main_rv, "Main realized volatility %",       color=main_col, linewidth=2)
plot(comp_rv, "Comparison realized volatility %", color=comp_col, linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 70))

// ── Readout table ──────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 3, border_width=1)
if barstate.islast and show_table
    float ratio = comp_rv > 0 ? main_rv / comp_rv : na
    table.cell(t, 0, 0, syminfo.ticker,                    text_color=main_col,       text_size=size.small)
    table.cell(t, 1, 0, str.tostring(main_rv, "#.0") + "%", text_color=main_col,      text_size=size.small)
    table.cell(t, 0, 1, syminfo.ticker(comp_sym),           text_color=comp_col,      text_size=size.small)
    table.cell(t, 1, 1, str.tostring(comp_rv, "#.0") + "%", text_color=comp_col,      text_size=size.small)
    table.cell(t, 0, 2, "Ratio",                            text_color=color.gray,    text_size=size.small)
    table.cell(t, 1, 2, str.tostring(ratio, "#.0") + "×",   text_color=color.gray,    text_size=size.small)
````
