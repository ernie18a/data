<!-- tradingview-pine-id: PUB;61758fba8de54e97b86fa5a152bc326b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cash Runway & Solvency

Source: https://www.tradingview.com/script/9VO9SAJ9-Cash-Runway-Solvency/

## Description

Cash Runway & Solvency estimates how long a company can keep operating at its current cash burn, using reported quarterly figures rather than estimates.

The script reads two quarterly items: cash and equivalents, and cash flow from operating activities. Both are carried forward between reports so the line is continuous between filings.

If operating cash flow is positive, the company is funding itself and the line sits at the top of the scale. If it is negative, the burn is the absolute value of that figure, and the runway is cash divided by burn, expressed in quarters and capped at 20 so the scale stays readable.

Three reference lines mark the zones: 20 quarters is the self-funding cap, 4 quarters is roughly one year of cash, and 2 quarters is where financing pressure usually starts. The line changes color as it crosses them: teal when self-funding, blue above four quarters, orange between two and four, red below two.

How to read it. A falling line means burn is rising faster than cash, or cash is being consumed without replacement. A jump upward usually means a capital raise, so check for dilution. A flip from red or orange to teal is the quarter the company turned operating cash flow positive.

Notes and limits. Values update only when a new quarterly report is released, so the line steps rather than moves daily. The runway assumes the last reported burn continues unchanged, which it rarely does; it is a snapshot, not a forecast. Financing and investing cash flows are excluded, so a company that keeps raising money can run at low readings for years. It needs reported quarterly financials, so nothing plots on indices, forex, crypto, most funds, and some non-US listings. Banks and insurers do not fit the burn model at all.

---

## Source Code

````pine
// Copyright (c) 2026 Cengiz Ilerler
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/. 
//
// Cash Runway & Solvency
// Estimates how many quarters of cash a company has left at its current operating burn rate,
// from reported quarterly cash and cash flow from operating activities.

//@version=6
indicator("Cash Runway & Solvency", overlay=false)

// Fetch quarterly balance sheet and cash flow data
cash = request.financial(syminfo.tickerid, "CASH_N_EQUIVALENTS", "FQ", ignore_invalid_symbol=true)
ocf  = request.financial(syminfo.tickerid, "CASH_F_OPERATING_ACTIVITIES", "FQ", ignore_invalid_symbol=true)

// Forward-fill quarterly data across bars
var float lastCash = na
var float lastOcf  = na

if not na(cash)
    lastCash := cash
if not na(ocf)
    lastOcf := ocf

// Determine state: Cash burning vs Profitable
isProfitable = not na(lastOcf) and lastOcf >= 0
cashBurn     = (not na(lastOcf) and lastOcf < 0) ? -lastOcf : na

// Calculate runway in quarters (capped at 20 for visual scaling)
float runway = na
if isProfitable
    runway := 20.0
else if not na(cashBurn) and cashBurn > 0 and not na(lastCash)
    runway := math.min(lastCash / cashBurn, 20.0)

// Plot runway line with dynamic color
plotColor = isProfitable ? color.teal : (runway < 2.0 ? color.red : (runway < 4.0 ? color.orange : color.blue))
plot(runway, "Runway (Quarters)", color=plotColor, linewidth=2, style=plot.style_stepline)

// Threshold benchmark lines
hline(20, "Profitable / Self-Funding (No Burn)", color=color.teal, linestyle=hline.style_dotted)
hline(4, "1-Year Safe Baseline (4Q)", color=color.green, linestyle=hline.style_dashed)
hline(2, "6-Month Critical Zone (2Q)", color=color.red, linestyle=hline.style_dashed)
````
