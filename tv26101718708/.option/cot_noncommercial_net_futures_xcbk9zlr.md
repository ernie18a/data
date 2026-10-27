# COT: Noncommercial Net (Futures)

- url: https://www.tradingview.com/script/XCbK9ZLR-COT-Noncommercial-Net-Futures/
- type: indicator
- pine_id: PUB;67082ca90ef74a9c8e87e57663c042d8
- version: 1.0

## Description

The CFTC publishes Commitment of Traders data every Friday. Inside that report, the "Noncommercial" category — large speculators, managed money, trend-followers — is the one most traders actually want to watch. This script strips everything else away and shows their net stance: Long minus Short, futures contracts only.

Positive values mean large speculators are net long. Negative means net short. A move across zero often marks a meaningful shift in positioning, not just noise.

How it works

The indicator auto-detects the correct CFTC code from the chart's symbol using TradingView's official LibraryCOT, so you don't need to configure anything. Open it on BTC futures, gold, crude oil, the yen — it resolves the code and pulls the right data automatically.

A teal/red histogram shows whether net positioning is positive or negative. A step-line sits on top for precise bar-by-bar reading. Zero is marked with a dashed reference line.

What it doesn't do

It doesn't tell you when to buy or sell. COT data is released weekly and lags several days behind the reporting cutoff — it's positioning context, not a signal. Use it alongside price action and other tools to understand who is leaning which way, not as a standalone trigger.

Notes


Futures only (not futures + options combined)
Noncommercial Long − Noncommercial Short = Net
Data source: CFTC Legacy report via TradingView's LibraryCOT v6
Works on any symbol that has a CFTC code in TradingView's database


Not financial advice. Position sizing and risk management are your responsibility.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © trsasaki

//@version=6
indicator("COT: Noncommercial Net (Futures)", "NC Net", format = format.volume)

// Commitment of Traders — Noncommercial Net, Futures Only
// Auto-detects CFTC code from the chart's symbol.
// Net = Noncommercial Long − Noncommercial Short

import TradingView/LibraryCOT/6 as cot



//#region ———————————————————— Calculations

// @variable CFTC code resolved automatically from the chart symbol.
var string cftcCode = cot.getCFTCCode("")

// @variable Noncommercial long contracts (futures only).
float ncLong = cot.requestCommitmentOfTraders(
    "Legacy", cftcCode, false, "Noncommercial Positions", "Long", "All"
)

// @variable Noncommercial short contracts (futures only).
float ncShort = cot.requestCommitmentOfTraders(
    "Legacy", cftcCode, false, "Noncommercial Positions", "Short", "All"
)

// @variable Net positioning: positive = net long, negative = net short.
float ncNet = ncLong - ncShort

//#endregion



//#region ———————————————————— Display

// Zero reference line
hline(0, "Zero", color.new(color.gray, 40), linestyle = hline.style_dashed)

// Histogram: teal above zero, red below
plot(
    ncNet,
    "NC Net (Histogram)",
    color  = ncNet >= 0 ? color.new(color.teal, 40) : color.new(color.red, 40),
    style  = plot.style_histogram,
    linewidth = 4
)

// Step-line on top for precise reading
plot(
    ncNet,
    "NC Net",
    color     = ncNet >= 0 ? color.teal : color.red,
    style     = plot.style_stepline_diamond,
    linewidth = 1
)

// Info table — bottom right
var table info = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(
        info, 0, 0,
        str.format("COT Noncommercial Net\nFutures Only  |  {0}", syminfo.ticker),
        text_halign = text.align_left,
        text_color  = color.white,
        bgcolor     = color.new(color.blue, 50)
    )

//#endregion
````
