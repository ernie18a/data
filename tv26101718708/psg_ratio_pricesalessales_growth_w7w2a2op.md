# PSG Ratio (price-sales/sales growth)

- url: https://www.tradingview.com/script/w7W2a2oP-PSG-Ratio-price-sales-sales-growth/
- type: indicator
- pine_id: PUB;5b6e645cc32a43c49f3700d9cdbebf10
- version: 1.0

## Description

This script plots the ratio of P/S (price-to-sales ratio) to Sales Growth Rate.

## Source Code

````pine
//@version=6
indicator("PSG Ratio · P/S ÷ Sales Growth", shorttitle="PSG", overlay=false, precision=2)

// ─────────── Inputs ───────────
growthBasis   = input.string("FY YoY", "Sales-growth basis", options=["FY YoY", "TTM YoY"])
hideNegGrowth = input.bool(true, "Blank PSG when sales growth ≤ 0 (ratio undefined)")

// ─────────── Fundamental data ───────────
tso    = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ",  ignore_invalid_symbol = true)
revTTM = request.financial(syminfo.tickerid, "TOTAL_REVENUE",            "TTM", ignore_invalid_symbol = true)
revFY  = request.financial(syminfo.tickerid, "TOTAL_REVENUE",            "FY",  ignore_invalid_symbol = true)

// ─────────── Price-to-Sales (updates live with price) ───────────
// Market cap = shares outstanding × current price;  P/S = market cap ÷ TTM revenue
ps = (tso * close) / revTTM

// ─────────── Sales growth, year-over-year, in % ───────────
// FY basis: capture each new annual revenue figure, compare latest to the prior year.
var float fyCurr = na
var float fyPrev = na
if not na(revFY) and (na(fyCurr) or revFY != fyCurr)
    fyPrev := fyCurr
    fyCurr := revFY
growthFY = (fyCurr - fyPrev) / fyPrev * 100

// TTM basis: store each new TTM revenue, compare latest to the figure 4 quarters back.
var ttmHist = array.new_float()
if not na(revTTM) and (array.size(ttmHist) == 0 or revTTM != array.last(ttmHist))
    array.push(ttmHist, revTTM)
float growthTTM = na
if array.size(ttmHist) >= 5
    n = array.size(ttmHist)
    growthTTM := (array.get(ttmHist, n - 1) - array.get(ttmHist, n - 5)) / array.get(ttmHist, n - 5) * 100

growth = growthBasis == "FY YoY" ? growthFY : growthTTM

// ─────────── PSG ───────────
validGrowth = hideNegGrowth ? (growth > 0) : (growth != 0)
psg = validGrowth ? ps / growth : na

plot(psg, "PSG", color=color.new(#00897B, 0), linewidth=2)
hline(1.0, "PSG = 1 (reference)", color=color.gray, linestyle=hline.style_dashed)
hline(0.0, "",                    color=color.new(color.gray, 70))
````
