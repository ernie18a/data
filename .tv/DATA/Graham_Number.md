<!-- tradingview-pine-id: PUB;g4LDQgbBX5H43UA3jLelCe9JaHiNm3sj -->
<!-- tradingviewscripts-format: 1 -->
# Graham Number

Source: https://www.tradingview.com/script/4YK3z13s-graham-number/

## Description

Graham Number is named after the “father of value investing,” Benjamin Graham, who was a mentor of Warren Buffett. The figure takes into account earnings per share and book value per share to measure a stock's maximum fair market value. In other words, it is the upper end of the price range that a defensive investor should pay for the stock.

The Graham Number = Square Root of (22.5) x (tmm EPS) x (mrq Book Value per Share).

The 22.5 is included in the formula as a rule of thumb to account for Graham's assumption that the price-to-earnings ratio should not be over 15 and the price to book ratio should not be over 1.5 for an undervalued stock. So, the number is generated as (P/E of 15) x (P/B of 1.5) = 22.5.

So the script generates a Graham number plot.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pleadian

//@version=4
study("Graham Number")

epsSpan = input(title="EPS Period", defval="TTM", options=["TTM", "FY", "FQ"])
bpsSpan = input(title="Book Value Per Share Period", defval="FY", options=["FY", "FQ"])
isColoring = input(title="Plot Coloring", type=input.bool, defval=true)

// Diluted EPS
eps = financial(syminfo.tickerid, "EARNINGS_PER_SHARE", epsSpan)
bps = financial(syminfo.tickerid, "BOOK_VALUE_PER_SHARE", bpsSpan)

x = 22.5*eps*bps

c = if x < 0
    color.gray
else if sqrt(x) > close
    color.green
else 
    color.red

plot(x >= 0 ? sqrt(x) : -1, color = isColoring ? c : color.blue)
````
