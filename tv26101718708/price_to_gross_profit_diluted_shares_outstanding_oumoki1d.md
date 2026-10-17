# Price to Gross Profit (Diluted Shares outstanding)

- url: https://www.tradingview.com/script/oUMoki1d-Price-to-Gross-Profit-Diluted-Shares-outstanding/
- type: indicator
- pine_id: PUB;0ee4f4fe3f1d4046aa64e65de42f7463
- version: 1.0

## Description

compares market cap (price) to gross profit. 

help when looking at growing companies that are not PE profitable yet or investing heavy into capex or R&D.

## Source Code

````pine
//@version=6
indicator("Price to Gross Profit (Diluted)", shorttitle="P/GP Diluted", overlay=false)

// ────────────────────────────────────────
// Fetch Diluted Financial Data
// ────────────────────────────────────────
// Using Diluted Shares Outstanding (Quarterly) for accurate valuation
float shares_diluted = request.financial(syminfo.tickerid, "DILUTED_SHARES_OUTSTANDING", "FQ", gaps=barmerge.gaps_off)
float gross_profit_ttm = request.financial(syminfo.tickerid, "GROSS_PROFIT", "TTM", gaps=barmerge.gaps_off)

// ────────────────────────────────────────
// Calculate Market Cap (Diluted)
// Market Cap = Current Price * Diluted Shares Outstanding
float market_cap_diluted = na(shares_diluted) ? na : (close * shares_diluted)

// ────────────────────────────────────────
// Price / Gross Profit (Diluted)
// Formula: Diluted Market Cap / Gross Profit TTM
float p_to_gp_diluted = na(market_cap_diluted) or na(gross_profit_ttm) or gross_profit_ttm <= 0 ? na : (market_cap_diluted / gross_profit_ttm)

// ────────────────────────────────────────
// Visuals & Plotting
// ────────────────────────────────────────
plot(p_to_gp_diluted, "P/GP Diluted Ratio", color=color.blue, linewidth=2)

// Horizontal zero line for context
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)

// Manage Live Value Label (updates with each bar/tick)
var label lbl = na
if barstate.islastconfirmedhistory and not na(p_to_gp_diluted)
    label.delete(lbl)
    lbl := label.new(bar_index, p_to_gp_diluted, str.tostring(p_to_gp_diluted, "#.##") + "×",
         color     = color.blue,
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.normal,
         yloc      = yloc.price)
````
