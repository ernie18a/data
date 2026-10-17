# Fundamentals Box

- url: https://www.tradingview.com/script/QjqLjHgv-Fundamentals-Box/
- type: indicator
- pine_id: PUB;12560bb433b54c1ea60f3520e8ac3f6b
- version: 2.0

## Description

At the top of the box, it shows the company’s market cap in crores, calculated as shares outstanding multiplied by the current price. Next to it, it shows the PE ratio, which is market cap divided by net profit for the trailing twelve months. For loss-making companies, PE shows NA.

Below that is a table of net profit for the last five reported periods, with the latest period first. Each row also shows the percentage change versus the same period a year earlier, coloured green for growth and red for decline. In Settings, you can switch between yearly (FY) and quarterly (FQ) figures.

Compared with the indicator in your screenshot, I removed EPS and Sales and replaced them with net profit, market cap and PE.

Limitations: it works only on stocks, not forex or crypto, and period labels show the reporting date on TradingView. Values are in the company’s reporting currency.

## Source Code

````pine
//@version=6
indicator("Fundamentals Box", overlay = true)

per    = input.string("FY", "Period", options = ["FY", "FQ"], tooltip = "FY = yearly, FQ = quarterly")
cr     = 1e7   // show values in Crores
lag    = per == "FY" ? 1 : 4   // YoY compares with 1 year / 4 quarters back
rows_n = 5

ni    = request.financial(syminfo.tickerid, "NET_INCOME", per,   ignore_invalid_symbol = true)
niTTM = request.financial(syminfo.tickerid, "NET_INCOME", "TTM", ignore_invalid_symbol = true)

// Collect each new reported net profit
var float[] vals  = array.new_float()
var int[]   times = array.new_int()
if not na(ni)
    sz = array.size(vals)
    if sz == 0 or ni != array.get(vals, sz - 1)
        array.push(vals, ni)
        array.push(times, time)

mcap = syminfo.shares_outstanding_total * close
pe   = niTTM > 0 ? mcap / niTTM : na

var table t = table.new(position.top_right, 3, rows_n + 2,
     bgcolor = color.new(color.black, 15), border_color = color.rgb(160, 164, 180), border_width = 1)

if barstate.islast
    // Row 0: market cap and PE
    table.cell(t, 0, 0, "Mkt Cap", text_color = color.white)
    table.cell(t, 1, 0, str.tostring(mcap / cr, "#,##0") + " Cr", text_color = color.aqua)
    table.cell(t, 2, 0, "PE " + (na(pe) ? "NA" : str.tostring(pe, "#.#")), text_color = color.yellow)

    // Row 1: header
    table.cell(t, 0, 1, "Period",         text_color = color.white)
    table.cell(t, 1, 1, "Net Profit (Cr)", text_color = color.white)
    table.cell(t, 2, 1, "%Chg YoY",       text_color = color.white)

    // Rows 2+: latest period first
    sz = array.size(vals)
    for i = 0 to rows_n - 1
        idx = sz - 1 - i
        if idx >= 0
            cur  = array.get(vals, idx)
            prev = idx - lag >= 0 ? array.get(vals, idx - lag) : na
            chg  = (na(prev) or prev == 0) ? na : (cur - prev) / math.abs(prev) * 100
            col  = na(chg) ? color.gray : chg >= 0 ? color.lime : color.red
            table.cell(t, 0, i + 2, str.format_time(array.get(times, idx), "MMM-yy"), text_color = color.white)
            table.cell(t, 1, i + 2, str.tostring(cur / cr, "#,##0.0"), text_color = color.white)
            table.cell(t, 2, i + 2, na(chg) ? "-" : (chg >= 0 ? "+" : "") + str.tostring(chg, "#") + "%", text_color = col)
````
