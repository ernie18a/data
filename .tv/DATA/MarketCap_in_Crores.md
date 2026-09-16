<!-- tradingview-pine-id: PUB;5077f01b303c4b5baa0d56fe23f82398 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MarketCap (in Crores)

Source: https://www.tradingview.com/script/UkdkvABV-MarketCap-in-Crores/

## Description

What the actual "Market Cap" indicator does:
If you were asking for a description of the code we built earlier, here is how it works:

The Math: It automatically fetches the total number of outstanding shares a company has and multiplies it by the current stock price to find the total Market Capitalization.

The Conversion: Because Indian traders read large numbers differently than the US standard, the script takes that massive raw number and divides it by 10,000,000.

The Result: It plots a clean, easy-to-read line on your chart where the numbers represent exact Rupees in Crores (e.g., displaying "5000" instead of "50,000,000,000").

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yehonatan.bus

//@version=6
indicator("MarketCap (in Crores)", format=format.inherit, overlay=true, scale=scale.none)

// 1 Crore = 10,000,000 (10 Million)
croreDivider = 10000000

// Fetch total shares outstanding using the new v6 request namespace
Outstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")

// Calculate raw Market Cap (Price * Shares)
MarketCapRaw = Outstanding * close

// Convert raw Market Cap to Crores
MarketCapCrore = MarketCapRaw / croreDivider

// --- Inputs (Updated for v6 syntax) ---
transp = input.int(title="Transparency", defval=70, minval=0, maxval=100)
trackprice = input.bool(title="Track Last Value Price", defval=false)

// --- Plotting ---
// In v6, transparency is applied to the color object directly, not the plot function.
plotColor = color.new(color.orange, transp)

// We change the title so the Status Line and Data Window show it is in Crores.
plot(MarketCapCrore, title='MarketCap (Cr)', style=plot.style_line, trackprice=trackprice, color=plotColor)
````
