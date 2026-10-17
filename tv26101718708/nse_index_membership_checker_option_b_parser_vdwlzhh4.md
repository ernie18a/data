# NSE Index Membership Checker (Option B parser)

- url: https://www.tradingview.com/script/VDWlzhh4-NSE-Index-Membership-Checker-Option-B-parser/
- type: indicator
- pine_id: PUB;7ec73fb579e04fab9b77608aaebfcd11
- version: 1.0

## Description

Finds the stock is part of which index
Each stock is looked at nifty indices pre coded and uses it as referential to form a table. easier to know if the stock is part of large/mid/small/microcap/sectoral index etc

## Source Code

````pine
//@version=6
indicator("NSE Index Membership Checker (Option B parser)", overlay=true, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS
//──────────────────────────────────────────────────────────────────────────────
showTable        = input.bool(true,  "Show table")
showOnlyMatches  = input.bool(false, "Show only matches (hide ❌ rows)")
showSummaryLabel = input.bool(true,  "Show summary label (last bar)")

tablePosOpt = input.string("Top Right", "Table position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

maxRowsToShow = input.int(40, "Max table rows", minval=10, maxval=200)

// Use multiple text areas to avoid input-size limits for huge indices (Nifty 500 etc.)
data1 = input.text_area("", "Index data (Part 1) — paste Option B lines here")
data2 = input.text_area("", "Index data (Part 2) — optional")
data3 = input.text_area("", "Index data (Part 3) — optional")
data4 = input.text_area("", "Index data (Part 4) — optional")

indexData = data1 + "\n" + data2 + "\n" + data3 + "\n" + data4

// Table position (avoid ternary formatting issues)
tblPos = switch tablePosOpt
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    => position.bottom_left

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────

// Normalize ticker for matching:
// - uppercase + trim
// - decode &amp; -> &
// - convert '-' and '&' to '_' (helps match TradingView ticker variants)
f_norm(sym) =>
    s0 = str.upper(str.trim(sym))
    s1 = str.replace_all(s0, "&AMP;", "&")
    s2 = str.replace_all(s1, "&amp;", "&")
    s3 = str.replace_all(s2, "-", "_")
    s4 = str.replace_all(s3, "&", "_")
    s4

// Clean list: remove spaces/tabs/CR and normalize
f_cleanList(listStr) =>
    a0 = str.replace_all(listStr, " ", "")
    a1 = str.replace_all(a0, "\t", "")
    a2 = str.replace_all(a1, "\r", "")
    f_norm(a2)

// Whole-token membership check using delimiter trick
f_inList(cleanList, tickerNorm) =>
    str.contains("," + cleanList + ",", "," + tickerNorm + ",")

// Safe array get
f_get(arr, i) =>
    i < array.size(arr) ? array.get(arr, i) : ""

//──────────────────────────────────────────────────────────────────────────────
// CORE
//──────────────────────────────────────────────────────────────────────────────
tickerNorm = f_norm(syminfo.ticker)

var string[] names = array.new_string()
var bool[]   hits  = array.new_bool()
var string   summary = ""

// Parse once (first bar)
if barstate.isfirst
    array.clear(names)
    array.clear(hits)
    summary := ""

    if str.length(str.trim(indexData)) == 0
        summary := "Paste Index data in Settings"
    else
        lines = str.split(indexData, "\n")

        for i = 0 to array.size(lines) - 1
            ln = str.trim(array.get(lines, i))

            // Skip blank/comment lines
            if str.length(ln) > 0 and not str.startswith(ln, "//") and not str.startswith(ln, "#")
                if str.contains(ln, "|")
                    parts = str.split(ln, "|")
                    nm = str.trim(f_get(parts, 0))
                    ls = str.trim(f_get(parts, 1))

                    if str.length(nm) > 0 and str.length(ls) > 0
                        clean = f_cleanList(ls)
                        hit = f_inList(clean, tickerNorm)

                        array.push(names, nm)
                        array.push(hits, hit)

                        if hit
                            summary += nm + ", "

        // Trim trailing comma+space
        if str.length(summary) > 2
            summary := str.substring(summary, 0, str.length(summary) - 2)
        else if summary == ""
            summary := "None"

//──────────────────────────────────────────────────────────────────────────────
// TABLE
//──────────────────────────────────────────────────────────────────────────────
var table t = na

if showTable and barstate.isfirst
    t := table.new(tblPos, 2, maxRowsToShow, border_width=1)

if showTable and not na(t)
    // Header row
    table.cell(t, 0, 0, "Ticker", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(t, 1, 0, tickerNorm, text_color=color.white, bgcolor=color.new(color.blue, 0))

    row = 1
    for i = 0 to array.size(names) - 1
        hit = array.get(hits, i)
        if not showOnlyMatches or hit
            if row < maxRowsToShow - 1
                nm = array.get(names, i)
                table.cell(t, 0, row, nm, text_color=color.white, bgcolor=color.new(color.black, 0))
                table.cell(t, 1, row, hit ? "✅ YES" : "❌ NO", text_color=hit ? color.lime : color.red)
                row += 1

    // Summary row
    if row < maxRowsToShow
        table.cell(t, 0, row, "Member of", text_color=color.white, bgcolor=color.new(color.gray, 20))
        table.cell(t, 1, row, summary, text_color=color.white, bgcolor=color.new(color.gray, 20))

//──────────────────────────────────────────────────────────────────────────────
// SUMMARY LABEL
//──────────────────────────────────────────────────────────────────────────────
if showSummaryLabel and barstate.islast
    label.new(bar_index, high, "Member of: " + summary,
        style=label.style_label_down,
        textcolor=color.white,
        color=color.new(color.black, 0))

//──────────────────────────────────────────────────────────────────────────────
// HIDDEN PLOT (ensures the indicator always satisfies CE10246)
//──────────────────────────────────────────────────────────────────────────────
plot(na, title="Hidden Output", display=display.none)
````
