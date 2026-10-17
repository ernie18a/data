# Futures Point Values

- url: https://www.tradingview.com/script/kKXY8rHM-Futures-Point-Values/
- type: indicator
- pine_id: PUB;69f557df91d54c47b77e7d0236b8a81a
- version: 1.0

## Description

This indicator assists in improving the calculation of risks and points within the Futures markets of Nasdaq and S&P 500.

## Source Code

````pine
//@version=5
indicator("Futures Point Values", overlay=true, max_labels_count=0)

// Detect ticker
is_mnq = str.contains(syminfo.ticker, "MNQ")
is_nq  = str.contains(syminfo.ticker, "NQ") and not is_mnq
is_mes = str.contains(syminfo.ticker, "MES")
is_es  = str.contains(syminfo.ticker, "ES") and not is_mes

var string txt = ""

if is_mnq
    txt := "MNQ  |  ×1:  1pt = $2  |  5pt = $10  |  10pt = $20  ●  ×5:  1pt = $10  |  5pt = $50  |  10pt = $100"
else if is_nq
    txt := "NQ   |  ×1:  1pt = $20  |  5pt = $100  |  10pt = $200  ●  ×5:  1pt = $100  |  5pt = $500  |  10pt = $1,000"
else if is_mes
    txt := "MES  |  ×1:  1pt = $5  |  5pt = $25  |  10pt = $50  ●  ×5:  1pt = $25  |  5pt = $125  |  10pt = $250"
else if is_es
    txt := "ES   |  ×1:  1pt = $50  |  5pt = $250  |  10pt = $500  ●  ×5:  1pt = $250  |  5pt = $1,250  |  10pt = $2,500"

// Only render on recognised symbols
if txt != ""
    var table t = table.new(position.top_right, 1, 1, bgcolor=color.new(color.black, 100))
    table.cell(
         table_id    = t,
         column      = 0,
         row         = 0,
         text        = txt,
         text_color  = color.new(color.gray, 30),
         text_size   = size.small,
         bgcolor     = color.new(color.black, 100)
     )
````
