<!-- tradingview-pine-id: PUB;e0c9dff6aa1444f8891aba30958ebef0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# COT Net Positions - Commercials vs Large Speculators

Source: https://www.tradingview.com/script/CcMw5ULT-COT-Net-Positions-Commercials-vs-Large-Speculators/

## Description

Overview

This indicator plots the net positioning (Long minus Short) of Commercial Traders and Large Speculators from the CFTC Commitment of Traders (COT) report, side by side, so you can see how the two groups are positioned relative to each other on the same chart.

How It Works

For each group, net position is calculated as:
Net Position = Long Positions - Short Positions

This is calculated separately for Commercials and for Large Speculators (Non-Commercials). Optionally, either series can be displayed as a percentage of total Open Interest instead of raw contracts:
Net % of Open Interest = 100 * Net Position / Open Interest

This normalization makes readings easier to compare over time and across contract-size changes (e.g. after a rollover or a change in typical position sizes), since raw contract counts alone don't account for changes in overall market participation.

COT data is requested with lookahead disabled, so this indicator does not repaint. Values only change on the bar where new CFTC data is published, regardless of chart timeframe.

Default Settings

Show Commercials: on
Show Large Speculators: on
Display Mode: Contracts (switchable to % of Open Interest)
Info table: on, top right
All adjustable in the script's Settings.

Interpretation

Commercials (often producers, processors and hedgers) and Large Speculators (large funds and managed money) are typically positioned on opposite sides of the market. Watching both net lines together shows the balance between these two groups.
A rising Commercials Net line while Large Speculators Net falls (or vice versa) reflects a shift in who is taking on more directional exposure.
The info table also shows the week-over-week change for each group and the current Open Interest.
Typical Use Cases

Compare Commercial and Large Speculator positioning on one chart
Track how net positioning shifts week to week
Normalize positioning across markets or over long histories using % of Open Interest
Combine with seasonality, price structure, trend and market regime for a fuller picture
Support commodity and futures market research
Limitations

COT data is weekly and delayed: the report reflects positions as of Tuesday and is usually published the following Friday. This indicator is not designed for intraday timing and is not a standalone trading system. Net positioning alone does not predict price direction. Both groups can remain positioned the same way for extended periods, especially in strong trending markets. Past positioning patterns do not guarantee future price behavior.

Symbol Support

Designed for futures and continuous futures charts. Some micro contracts, CFDs, broker-specific symbols or otherwise unsupported markets may not return valid COT data.

Originality

COT data retrieval uses the public TradingView "LibraryCOT" community library. The net-position calculation for both trader groups, the optional % of Open Interest normalization, the weekly change tracking, and the info table are original to this script. It complements the companion "Commercials COT Index Weekly" indicator, which shows Commercial positioning as a normalized 0-100 index rather than as raw/percentage net values.

For educational and research purposes only. This is not financial advice.

---

## Source Code

````pine
//@version=6
// COT Net Positions - Commercials vs Large Speculators
//
// Shows net positioning (Long - Short) for Commercials and Large Speculators
// (Non-Commercials) from the CFTC Commitment of Traders report, with an optional
// normalization to % of Open Interest so readings stay comparable across time
// and contract-size changes.

indicator("COT Net Positions - Commercials vs Large Speculators", shorttitle="COT Net", overlay=false)

import TradingView/LibraryCOT/2 as cot

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
showCommercials = input.bool(true, "Show Commercials", group="Groups")
showLargeSpec   = input.bool(true, "Show Large Speculators", group="Groups")

displayMode = input.string("Contracts", "Display Mode", options=["Contracts", "% of Open Interest"], group="Display")

showTable    = input.bool(true, "Show Info Table", group="Display")
tablePosStr  = input.string("Top Right", "Table Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group="Display")

colComm  = input.color(color.red,  "Commercials Color",       group="Colors")
colLarge = input.color(color.blue, "Large Speculators Color", group="Colors")

// ─────────────────────────────────────────────────────────────────────────────
// CFTC Code Handling (consistent with Commercials COT Index Weekly)
// ─────────────────────────────────────────────────────────────────────────────
rootSymbol = str.upper(syminfo.root)

f_getCftcCode() =>
    string autoCode = cot.convertRootToCOTCode("Auto")
    if rootSymbol == "HG"
        autoCode := "085692"
    else if rootSymbol == "LBR"
        autoCode := "058644"
    autoCode

cftcCode = f_getCftcCode()

// ─────────────────────────────────────────────────────────────────────────────
// COT Data Request
// Note: COT data itself is only published weekly. Requesting it at "1D" and
// letting it step on the chart's native timeframe is intentional - the value
// only changes on the bar where new CFTC data lands, so bar-to-bar deltas
// below are effectively week-over-week deltas regardless of chart timeframe.
// ─────────────────────────────────────────────────────────────────────────────
f_requestCot(metricName, direction) =>
    string cotTicker = cot.COTTickerid("Legacy", cftcCode, false, metricName, direction, "All")
    float cotValue = request.security(cotTicker, "1D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
    if barstate.islastconfirmedhistory and na(cotValue)
        runtime.error("No matching COT data found for this futures symbol.")
    cotValue

commLong   = f_requestCot("Commercial Positions",    "Long")
commShort  = f_requestCot("Commercial Positions",    "Short")
largeLong  = f_requestCot("Noncommercial Positions", "Long")
largeShort = f_requestCot("Noncommercial Positions", "Short")
openInt    = f_requestCot("Open Interest",           "No direction")

// ─────────────────────────────────────────────────────────────────────────────
// Net Positions
// ─────────────────────────────────────────────────────────────────────────────
commNet  = commLong  - commShort
largeNet = largeLong - largeShort

commPct  = openInt != 0 ? commNet  / openInt * 100 : na
largePct = openInt != 0 ? largeNet / openInt * 100 : na

usePct = displayMode == "% of Open Interest"

commPlot  = usePct ? commPct  : commNet
largePlot = usePct ? largePct : largeNet

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Change (see note above: bar-to-bar delta = week-over-week delta)
// ─────────────────────────────────────────────────────────────────────────────
commChange  = commNet  - commNet[1]
largeChange = largeNet - largeNet[1]

// ─────────────────────────────────────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────────────────────────────────────
plot(showCommercials ? commPlot  : na, title="Commercials Net",       color=colComm,  linewidth=2)
plot(showLargeSpec   ? largePlot : na, title="Large Speculators Net", color=colLarge, linewidth=2)

hline(0, title="Zero Line", color=color.gray, linestyle=hline.style_dashed)

// ─────────────────────────────────────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────────────────────────────────────
f_pos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_fmt(x) =>
    na(x) ? "n/a" : str.tostring(x, "#,###")

f_fmtPct(x) =>
    na(x) ? "n/a" : str.tostring(x, "#.##") + "%"

f_fmtChange(x) =>
    na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x, "#,###")

var table t = na
if barstate.isfirst
    t := table.new(f_pos(tablePosStr), 4, 4, border_width=1)

if showTable and barstate.islast
    table.cell(t, 0, 0, "Group",           bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(t, 1, 0, "Net (Contracts)", bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(t, 2, 0, "Net (% OI)",      bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(t, 3, 0, "Weekly Change",   bgcolor=color.new(color.gray, 70), text_color=color.white)

    table.cell(t, 0, 1, "Commercials",       text_color=colComm)
    table.cell(t, 1, 1, f_fmt(commNet))
    table.cell(t, 2, 1, f_fmtPct(commPct))
    table.cell(t, 3, 1, f_fmtChange(commChange))

    table.cell(t, 0, 2, "Large Speculators", text_color=colLarge)
    table.cell(t, 1, 2, f_fmt(largeNet))
    table.cell(t, 2, 2, f_fmtPct(largePct))
    table.cell(t, 3, 2, f_fmtChange(largeChange))

    table.cell(t, 0, 3, "Open Interest", text_color=color.gray)
    table.cell(t, 1, 3, f_fmt(openInt))
    table.cell(t, 2, 3, "-")
    table.cell(t, 3, 3, "-")
````
