# Sector Relative Strength (DTR)

- url: https://www.tradingview.com/script/GLMby3wq-Sector-Relative-Strength-DTR/
- type: indicator
- pine_id: PUB;bcdccd9e44194c0b81a52dcae8dc6c3c
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

This indicator ranks the eleven SPDR sector ETFs (plus SPY as a benchmark) by a weighted multi-timeframe rate-of-change composite, plotted as a single line with an accompanying ranking table. The approach replicates a well-known sector rotation framework that uses three overlapping momentum windows to identify which sectors are gaining or losing relative strength on a weekly basis.

The composite score (labeled "DTR") weights a short-term, medium-term, and long-term rate of change so that the effective center of the measurement sits at approximately sixteen weeks. Sectors are ranked by this score each week and the rank change column (R/C) tracks rotational momentum: which sectors are climbing or falling in the standings.


█ [b]HOW IT WORKS[/b]

The DTR score for each sector is computed as:

[pine]DTR = W1 × ROC(8 weeks) + W2 × ROC(16 weeks) + W3 × ROC(32 weeks)[/pine]

where each ROC is a simple percent change (current weekly close versus the close N weeks ago), and the default weights are 50% / 25% / 25%. This weighting places half the emphasis on recent momentum while anchoring the composite with longer-term trend context. The weighted average lookback under default settings is:

[pine](0.50 × 8) + (0.25 × 16) + (0.25 × 32) = 16 weeks[/pine]

All price data is forced to weekly resolution via [i]request.security[/i], so the indicator produces identical results regardless of the chart timeframe. The twelve sectors are ranked in descending order by DTR score each week.


█ [b]SECTOR UNIVERSE[/b]

The indicator tracks twelve symbols:

 • [symbol="AMEX:XLK"]XLK[/symbol] Technology
 • [symbol="AMEX:XLV"]XLV[/symbol] Health Care
 • [symbol="AMEX:XLE"]XLE[/symbol] Energy
 • [symbol="AMEX:XLF"]XLF[/symbol] Financials
 • [symbol="AMEX:XLC"]XLC[/symbol] Communication Services
 • [symbol="AMEX:XLY"]XLY[/symbol] Consumer Discretionary
 • [symbol="AMEX:XLP"]XLP[/symbol] Consumer Staples
 • [symbol="AMEX:XLI"]XLI[/symbol] Industrials
 • [symbol="AMEX:XLB"]XLB[/symbol] Materials
 • [symbol="AMEX:XLRE"]XLRE[/symbol] Real Estate
 • [symbol="AMEX:XLU"]XLU[/symbol] Utilities
 • [symbol="AMEX:SPY"]SPY[/symbol] S&P 500 (benchmark)

SPY is included as the twelfth entry so you can see where the broad market sits relative to individual sectors. A sector ranked above SPY is outperforming the market on the composite momentum measure; a sector ranked below SPY is underperforming.


█ [b]READING THE CHART[/b]

[b]Plotted line[/b]
The yellow line shows the DTR score for one selected sector. When the chart symbol is one of the twelve tracked ETFs, that sector is plotted automatically. When the chart symbol is anything else (an individual stock, a futures contract, crypto), the indicator plots whichever sector is selected in the "Plot Sector" dropdown, which defaults to SPY.

 • DTR above zero: the selected sector has positive weighted momentum across the composite lookback
 • DTR below zero: negative weighted momentum
 • DTR rising: momentum is accelerating
 • DTR falling: momentum is decelerating, even if still positive

The green/red background shading reflects the sign of the plotted DTR score.

[b]Ranking table[/b]
The table (toggled via settings) displays all twelve symbols sorted by DTR score, with five columns:

 • [b]Rank[/b]: current position (1 = strongest)
 • [b]Sector[/b]: ticker and sector name
 • [b]DTR[/b]: the composite score
 • [b]R/C[/b]: rank change from the prior week (positive = improving, shown in green; negative = deteriorating, shown in red)
 • [b]8w ROC[/b]: the short-term rate of change alone, for additional context

The currently plotted sector is highlighted with a yellow background in the table. Rows with positive DTR scores have green-tinted backgrounds; negative scores have red-tinted backgrounds.

[b]What to look for[/b]

 • Sectors at the top of the table with positive and rising R/C values are in strong rotational momentum. These are the sectors institutional capital is flowing into.
 • Sectors falling in rank (negative R/C) even while DTR is still positive are showing early deceleration. This is often where rotation out of a sector begins before price breaks down.
 • When SPY sits in the bottom half of the rankings, most sectors are outperforming the broad market, which can indicate a broad-based rally. When SPY is near the top, few sectors are keeping up, suggesting narrow market leadership.
 • Clusters of defensive sectors (XLU, XLP, XLV) rising in rank while cyclicals (XLK, XLY, XLI) fall is a classic late-cycle rotation signal.


█ [b]INPUTS[/b]

 • [b]Short / Medium / Long ROC (weeks)[/b]: the three lookback periods, defaulting to 8, 16, and 32 weeks
 • [b]Weight: Short / Medium / Long ROC[/b]: the weight applied to each period, defaulting to 0.50, 0.25, 0.25. These should sum to 1.0 for a properly scaled composite, though the script does not enforce this, allowing deliberate over- or under-weighting
 • [b]Plot Sector[/b]: which sector's DTR score to plot when the chart symbol is not in the universe. Ignored when the chart symbol matches one of the twelve tracked ETFs
 • [b]Show Ranking Table[/b]: toggle the table on or off
 • [b]Table Position[/b]: corner placement of the ranking table


█ [b]LIMITATIONS AND NOTES[/b]

 • The indicator requires at least 32 weeks of weekly data history to compute the longest default ROC. On symbols or exchanges with limited history, early bars will show [i]na[/i] values.
 • All data is pulled at weekly resolution. The DTR score updates once per week at the weekly close. Intraweek movements are not reflected until the current weekly bar closes.
 • The sector universe is hardcoded to the eleven SPDR Select Sector ETFs plus SPY. These ETFs use the GICS classification system. Some sectors (notably XLC, which replaced the old Telecom sector in 2018) have limited history prior to their inception date.
 • The R/C column compares the current week's rank to the prior week's rank. A single week of rank change can be noisy; persistent rank trends over multiple weeks are more informative.
 • The weights are user-configurable but the "centered at N weeks" interpretation only holds when weights sum to 1.0.


█ [b]METHODOLOGY NOTES[/b]

This approach to sector relative strength analysis is well-established in the technical analysis community. The multi-timeframe weighted ROC method has been used by practitioners including Tom Dorsey (Dorsey Wright & Associates) and other relative strength analysts for decades. The specific weighting scheme implemented here (50% short / 25% medium / 25% long, centered at approximately 16 weeks) comes from a publicly shared analysis of Fidelity sector fund rankings at the time of the March 2000 dot-com peak, which demonstrated the framework's ability to capture sector rotation during a major market inflection.

The SPDR sector ETFs used in this implementation are the most liquid and widely tracked sector vehicles available on US exchanges, making them the natural modern equivalent of the Fidelity sector fund universe used in the original analysis.


═════════════════════════════════════════════════════════════════════════

[b]Disclaimer[/b]: This script is provided for educational and informational purposes only. It is not financial advice. Past indicator behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Sector Relative Strength (DTR)", overlay = false, max_labels_count = 500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
w8  = input.int(8,  "Short ROC (weeks)",  minval = 1)
w16 = input.int(16, "Medium ROC (weeks)", minval = 1)
w32 = input.int(32, "Long ROC (weeks)",   minval = 1)

wt8  = input.float(0.50, "Weight: Short ROC",  minval = 0, maxval = 1, step = 0.05)
wt16 = input.float(0.25, "Weight: Medium ROC", minval = 0, maxval = 1, step = 0.05)
wt32 = input.float(0.25, "Weight: Long ROC",   minval = 0, maxval = 1, step = 0.05)

plotSector = input.string("SPY S&P500", "Plot Sector", options = ["XLK Tech", "XLV Health", "XLE Energy", "XLF Financial", "XLC Comms", "XLY Discret", "XLP Staples", "XLI Indust", "XLB Materials", "XLRE RealEst", "XLU Utilities", "SPY S&P500"])

showTable = input.bool(true, "Show Ranking Table")
tablePos  = input.string("Top Right", "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"])

// ─────────────────────────────────────────────────────────────────────────────
// SECTOR UNIVERSE
// ─────────────────────────────────────────────────────────────────────────────
// 11 SPDR Sector ETFs + SPY benchmark
var string[] tickers = array.from(
     "AMEX:XLK",  "AMEX:XLV",  "AMEX:XLE",  "AMEX:XLF",  "AMEX:XLC",
     "AMEX:XLY",  "AMEX:XLP",  "AMEX:XLI",  "AMEX:XLB",  "AMEX:XLRE",
     "AMEX:XLU",  "AMEX:SPY")

var string[] names = array.from(
     "XLK Tech",     "XLV Health",   "XLE Energy",  "XLF Financial", "XLC Comms",
     "XLY Discret",  "XLP Staples",  "XLI Indust",  "XLB Materials", "XLRE RealEst",
     "XLU Utilities", "SPY S&P500")

NUM_SECTORS = 12

// ─────────────────────────────────────────────────────────────────────────────
// DTR CALCULATION FUNCTION
// ─────────────────────────────────────────────────────────────────────────────
dtr(float src, int l8, int l16, int l32, float w1, float w2, float w3) =>
    roc8  = (src - src[l8])  / src[l8]  * 100
    roc16 = (src - src[l16]) / src[l16] * 100
    roc32 = (src - src[l32]) / src[l32] * 100
    w1 * roc8 + w2 * roc16 + w3 * roc32

// ─────────────────────────────────────────────────────────────────────────────
// WEEKLY CLOSES VIA request.security
// ─────────────────────────────────────────────────────────────────────────────
wClose(string sym) =>
    request.security(sym, "W", close, barmerge.gaps_off, barmerge.lookahead_off)

float c00 = wClose(array.get(tickers, 0))
float c01 = wClose(array.get(tickers, 1))
float c02 = wClose(array.get(tickers, 2))
float c03 = wClose(array.get(tickers, 3))
float c04 = wClose(array.get(tickers, 4))
float c05 = wClose(array.get(tickers, 5))
float c06 = wClose(array.get(tickers, 6))
float c07 = wClose(array.get(tickers, 7))
float c08 = wClose(array.get(tickers, 8))
float c09 = wClose(array.get(tickers, 9))
float c10 = wClose(array.get(tickers, 10))
float c11 = wClose(array.get(tickers, 11))

// ─────────────────────────────────────────────────────────────────────────────
// DTR SCORES (current and prior bar for rank change)
// ─────────────────────────────────────────────────────────────────────────────
float d00 = dtr(c00, w8, w16, w32, wt8, wt16, wt32)
float d01 = dtr(c01, w8, w16, w32, wt8, wt16, wt32)
float d02 = dtr(c02, w8, w16, w32, wt8, wt16, wt32)
float d03 = dtr(c03, w8, w16, w32, wt8, wt16, wt32)
float d04 = dtr(c04, w8, w16, w32, wt8, wt16, wt32)
float d05 = dtr(c05, w8, w16, w32, wt8, wt16, wt32)
float d06 = dtr(c06, w8, w16, w32, wt8, wt16, wt32)
float d07 = dtr(c07, w8, w16, w32, wt8, wt16, wt32)
float d08 = dtr(c08, w8, w16, w32, wt8, wt16, wt32)
float d09 = dtr(c09, w8, w16, w32, wt8, wt16, wt32)
float d10 = dtr(c10, w8, w16, w32, wt8, wt16, wt32)
float d11 = dtr(c11, w8, w16, w32, wt8, wt16, wt32)

// Store in arrays for ranking
var float[] dtrScores     = array.new_float(NUM_SECTORS, 0.0)
var float[] dtrScoresPrev = array.new_float(NUM_SECTORS, 0.0)
var int[]   ranks         = array.new_int(NUM_SECTORS, 0)
var int[]   ranksPrev     = array.new_int(NUM_SECTORS, 0)
var int[]   indices       = array.new_int(NUM_SECTORS, 0)
var int[]   indicesPrev   = array.new_int(NUM_SECTORS, 0)

// Current DTR scores
array.set(dtrScores, 0,  d00)
array.set(dtrScores, 1,  d01)
array.set(dtrScores, 2,  d02)
array.set(dtrScores, 3,  d03)
array.set(dtrScores, 4,  d04)
array.set(dtrScores, 5,  d05)
array.set(dtrScores, 6,  d06)
array.set(dtrScores, 7,  d07)
array.set(dtrScores, 8,  d08)
array.set(dtrScores, 9,  d09)
array.set(dtrScores, 10, d10)
array.set(dtrScores, 11, d11)

// Previous bar DTR scores (for rank change)
array.set(dtrScoresPrev, 0,  d00[1])
array.set(dtrScoresPrev, 1,  d01[1])
array.set(dtrScoresPrev, 2,  d02[1])
array.set(dtrScoresPrev, 3,  d03[1])
array.set(dtrScoresPrev, 4,  d04[1])
array.set(dtrScoresPrev, 5,  d05[1])
array.set(dtrScoresPrev, 6,  d06[1])
array.set(dtrScoresPrev, 7,  d07[1])
array.set(dtrScoresPrev, 8,  d08[1])
array.set(dtrScoresPrev, 9,  d09[1])
array.set(dtrScoresPrev, 10, d10[1])
array.set(dtrScoresPrev, 11, d11[1])

// ─────────────────────────────────────────────────────────────────────────────
// RANKING (descending by DTR score)
// ─────────────────────────────────────────────────────────────────────────────
// Build index arrays and sort by score descending
for i = 0 to NUM_SECTORS - 1
    array.set(indices, i, i)
    array.set(indicesPrev, i, i)

// Simple insertion sort (current)
for i = 1 to NUM_SECTORS - 1
    j = i
    while j > 0 and array.get(dtrScores, array.get(indices, j)) > array.get(dtrScores, array.get(indices, j - 1))
        tmpIdx = array.get(indices, j)
        array.set(indices, j, array.get(indices, j - 1))
        array.set(indices, j - 1, tmpIdx)
        j -= 1

// Derive rank from sorted position
for i = 0 to NUM_SECTORS - 1
    array.set(ranks, array.get(indices, i), i + 1)

// Simple insertion sort (previous)
for i = 1 to NUM_SECTORS - 1
    j = i
    while j > 0 and array.get(dtrScoresPrev, array.get(indicesPrev, j)) > array.get(dtrScoresPrev, array.get(indicesPrev, j - 1))
        tmpIdx = array.get(indicesPrev, j)
        array.set(indicesPrev, j, array.get(indicesPrev, j - 1))
        array.set(indicesPrev, j - 1, tmpIdx)
        j -= 1

for i = 0 to NUM_SECTORS - 1
    array.set(ranksPrev, array.get(indicesPrev, i), i + 1)

// ─────────────────────────────────────────────────────────────────────────────
// RESOLVE PLOTTED SECTOR (dropdown selection, or chart symbol if in universe)
// ─────────────────────────────────────────────────────────────────────────────
// Find the index matching the dropdown selection
plotIdx = -1
for i = 0 to NUM_SECTORS - 1
    if array.get(names, i) == plotSector
        plotIdx := i

// Check if chart symbol is in the universe
chartIdx = -1
for i = 0 to NUM_SECTORS - 1
    if str.contains(syminfo.tickerid, str.replace(array.get(tickers, i), "AMEX:", ""))
        chartIdx := i

// Use chart symbol if it's in the universe, otherwise use dropdown
activeIdx = chartIdx >= 0 ? chartIdx : plotIdx

plotDTR  = switch activeIdx
    0  => d00
    1  => d01
    2  => d02
    3  => d03
    4  => d04
    5  => d05
    6  => d06
    7  => d07
    8  => d08
    9  => d09
    10 => d10
    11 => d11
    => float(na)

plotRank    = activeIdx >= 0 ? array.get(ranks, activeIdx) : int(na)
plotRankChg = activeIdx >= 0 ? array.get(ranksPrev, activeIdx) - array.get(ranks, activeIdx) : int(na)
plotLabel   = activeIdx >= 0 ? array.get(names, activeIdx) : "N/A"

// ─────────────────────────────────────────────────────────────────────────────
// PLOT
// ─────────────────────────────────────────────────────────────────────────────
plot(plotDTR, "DTR Score", color = color.new(color.yellow, 0), linewidth = 2)
hline(0, "Zero", color = color.gray, linestyle = hline.style_dotted)

// Color background based on DTR sign
bgcolor(not na(plotDTR) ? (plotDTR > 0 ? color.new(color.green, 90) : color.new(color.red, 90)) : na)

// ─────────────────────────────────────────────────────────────────────────────
// RANKING TABLE
// ─────────────────────────────────────────────────────────────────────────────
if showTable and barstate.islast
    tblPos = switch tablePos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

    var tbl = table.new(tblPos, 5, NUM_SECTORS + 1, border_width = 1)

    // Header
    table.cell(tbl, 0, 0, "Rank",   text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tbl, 1, 0, "Sector", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tbl, 2, 0, "DTR",    text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tbl, 3, 0, "R/C",    text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tbl, 4, 0, "8w ROC", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)

    for row = 0 to NUM_SECTORS - 1
        idx      = array.get(indices, row)
        score    = array.get(dtrScores, idx)
        rnk      = row + 1
        rnkPrev  = array.get(ranksPrev, idx)
        rnkChg   = rnkPrev - rnk
        sectorNm = array.get(names, idx)

        // 8w ROC for extra context
        roc8val = switch idx
            0  => (c00 - c00[w8]) / c00[w8] * 100
            1  => (c01 - c01[w8]) / c01[w8] * 100
            2  => (c02 - c02[w8]) / c02[w8] * 100
            3  => (c03 - c03[w8]) / c03[w8] * 100
            4  => (c04 - c04[w8]) / c04[w8] * 100
            5  => (c05 - c05[w8]) / c05[w8] * 100
            6  => (c06 - c06[w8]) / c06[w8] * 100
            7  => (c07 - c07[w8]) / c07[w8] * 100
            8  => (c08 - c08[w8]) / c08[w8] * 100
            9  => (c09 - c09[w8]) / c09[w8] * 100
            10 => (c10 - c10[w8]) / c10[w8] * 100
            11 => (c11 - c11[w8]) / c11[w8] * 100
            => 0.0

        // Row colors
        bgClr = score > 0 ? color.new(color.green, 85) : color.new(color.red, 85)

        // Highlight plotted sector row
        if idx == activeIdx
            bgClr := color.new(color.yellow, 70)

        rcStr  = rnkChg > 0 ? "+" + str.tostring(rnkChg) : str.tostring(rnkChg)
        rcClr  = rnkChg > 0 ? color.green : rnkChg < 0 ? color.red : color.gray

        table.cell(tbl, 0, row + 1, str.tostring(rnk),                       text_color = color.white, bgcolor = bgClr, text_size = size.small)
        table.cell(tbl, 1, row + 1, sectorNm,                                text_color = color.white, bgcolor = bgClr, text_size = size.small)
        table.cell(tbl, 2, row + 1, str.tostring(score, "#.##"),              text_color = color.white, bgcolor = bgClr, text_size = size.small)
        table.cell(tbl, 3, row + 1, rcStr,                                    text_color = rcClr,       bgcolor = bgClr, text_size = size.small)
        table.cell(tbl, 4, row + 1, str.tostring(roc8val, "#.##") + "%",      text_color = color.white, bgcolor = bgClr, text_size = size.small)
````
