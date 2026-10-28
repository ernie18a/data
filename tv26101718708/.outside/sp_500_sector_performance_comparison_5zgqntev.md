# S&P 500 Sector Performance Comparison

- url: https://www.tradingview.com/script/5zGQNtEV-S-P-500-Sector-Performance-Comparison/
- type: indicator
- pine_id: PUB;4076f168bfdc4a0cb05651b6af3f246b
- version: 3.0

## Description

S&P 500 Sector Performance Comparison created by Edgar Simões.

This indicator compares the performance of all 11 S&P 500 Sector SPDR ETFs in a single normalized chart, making it easy to visualize sector rotation, market leadership, and relative strength across different market environments.

Included sectors:

XLK — Technology
XLF — Financials
XLV — Health Care
XLY — Consumer Discretionary
XLP — Consumer Staples
XLE — Energy
XLI — Industrials
XLB — Materials
XLU — Utilities
XLRE — Real Estate
XLC — Communication Services

Features:

Relative performance comparison in percentage terms
Clear color differentiation for each sector
Easy identification of outperforming and underperforming sectors
Useful for macro analysis, sector rotation strategies, and market trend confirmation
Designed for medium and long-term market analysis

This script helps traders and investors quickly identify:

Risk-on vs risk-off environments
Defensive vs growth leadership
Inflation-sensitive sectors
Momentum and sector rotation trends

Author: Edgar

## Source Code

````pine
//@version=6
indicator("SP500 Sector Performance", overlay=false)

// =====================================
// Função performance
// =====================================
perf(symbol) =>
    p = request.security(symbol, timeframe.period, close)
    startPrice = ta.valuewhen(barstate.isfirst, p, 0)
    100 * ((p / startPrice) - 1)

// =====================================
// Dados
// =====================================
XLK  = perf("AMEX:XLK")
XLF  = perf("AMEX:XLF")
XLV  = perf("AMEX:XLV")
XLY  = perf("AMEX:XLY")
XLP  = perf("AMEX:XLP")
XLE  = perf("AMEX:XLE")
XLI  = perf("AMEX:XLI")
XLB  = perf("AMEX:XLB")
XLU  = perf("AMEX:XLU")
XLRE = perf("AMEX:XLRE")
XLC  = perf("AMEX:XLC")

// =====================================
// Plots
// =====================================
plot(XLK,  "XLK",  color=color.blue,    linewidth=2)
plot(XLF,  "XLF",  color=color.green,   linewidth=2)
plot(XLV,  "XLV",  color=color.red,     linewidth=2)
plot(XLY,  "XLY",  color=color.orange,  linewidth=2)
plot(XLP,  "XLP",  color=color.purple,  linewidth=2)
plot(XLE,  "XLE",  color=color.yellow,  linewidth=2)
plot(XLI,  "XLI",  color=color.teal,    linewidth=2)
plot(XLB,  "XLB",  color=color.fuchsia, linewidth=2)
plot(XLU,  "XLU",  color=color.gray,    linewidth=2)
plot(XLRE, "XLRE", color=color.maroon,  linewidth=2)
plot(XLC,  "XLC",  color=color.aqua,    linewidth=2)

hline(0, "0%", color=color.white, linestyle=hline.style_dotted)


// =====================================
// TABELA (FORÇADA VISÍVEL)
// =====================================
var table t = table.new(position.top_right, 2, 11, border_width=1)

f_row(_row, _ticker, _name, _color) =>
    table.cell(t, 0, _row, _ticker, text_color=_color)
    table.cell(t, 1, _row, _name, text_color=color.white)

if barstate.islast
    f_row(0,  "XLK",  "Technology",             color.blue)
    f_row(1,  "XLF",  "Financials",             color.green)
    f_row(2,  "XLV",  "Health Care",            color.red)
    f_row(3,  "XLY",  "Consumer Discretionary", color.orange)
    f_row(4,  "XLP",  "Consumer Staples",       color.purple)
    f_row(5,  "XLE",  "Energy",                 color.yellow)
    f_row(6,  "XLI",  "Industrials",            color.teal)
    f_row(7,  "XLB",  "Materials",              color.fuchsia)
    f_row(8,  "XLU",  "Utilities",              color.gray)
    f_row(9,  "XLRE", "Real Estate",            color.maroon)
    f_row(10, "XLC",  "Communication Services", color.aqua)
````
