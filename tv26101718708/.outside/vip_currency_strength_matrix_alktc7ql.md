# VIP Currency Strength Matrix

- url: https://www.tradingview.com/script/ALktC7Ql-VIP-Currency-Strength-Matrix/
- type: indicator
- pine_id: PUB;67b2cf222e5f44138732f7bea9b329dc
- version: 1.0

## Description

VIP Currency Strength Matrix — Round-Robin Strong-Count (SMA/EMA)

OVERVIEW
This indicator scores the 8 major currencies (EUR, GBP, AUD, NZD, USD, CAD, CHF, JPY) using a round-robin "strong-count" method, then builds a pair-difference matrix so you can see, at a glance, which pairs have the wind at their back and which are fighting it. It is a bias and confluence tool, not an entry signal.

HOW IT WORKS
The 8 currencies form 28 unique pairings. For each pair, the indicator checks whether price is above or below a reference moving average (200 SMA by default):
- Price ABOVE the MA -> the BASE currency earns +1 strong-count.
- Price BELOW the MA -> the QUOTE currency earns +1 strong-count.
Each currency is compared against the other seven, so every currency ends with a strong-count from 0 (weakest) to 7 (strongest).

For any pair, the score shown is:
strong-count(base) - strong-count(quote), ranging from -7 to +7.
- Positive = base is stronger (buy-side confluence).
- Negative = quote is stronger (sell-side confluence).
Cells at or beyond the highlight threshold (default 4) are color-coded green (buy) or red (sell).

WHAT YOU SEE
- Currency Strength table: all 8 currencies ranked 0-7, strongest at the top.
- Pair Matrix: all 28 pairs with their difference score, sorted so the strongest buy-side reads sit at the top and the strongest sell-side reads at the bottom.

HOW TO USE IT
1. Use it to establish directional bias first: favor longs on currencies ranked high, shorts on currencies ranked low.
2. A pair scoring +6 or +7 is strongly one-sided, but "strong" is not the same as "a good entry." Wait for price to reach your own level/structure before acting.
3. Look for agreement, not extremes. Alignment across your timeframes is the read you want.

MULTI-TIMEFRAME
Each copy of the indicator computes ONE timeframe (28 data requests). TradingView caps unique data requests at 40 (non-pro) / 64 (pro), so 28 pairs across several timeframes cannot fit in a single script. To watch multiple timeframes at once, add the indicator to your chart several times, set each copy to a different timeframe, and give each its own table position.

IMPORTANT SETUP NOTES
- Run it on a chart timeframe equal to or lower than the timeframe you request. Requesting a lower timeframe than the chart (e.g. asking for 15m while on a 4H chart) forces a heavy data pull across all 28 pairs and can trigger "Memory limits exceeded." If you see that error, lower "History bars per pair" and/or drop to a lower chart timeframe.
- "Data-feed prefix" must be a feed that carries all 28 pairs, including the crosses (OANDA works well).

INPUTS
- Reference MA type and length (default SMA 200)
- History bars per pair (memory control)
- Data-feed prefix
- Timeframe (one per copy)
- Panel tag, table positions, text size
- Buy/Sell highlight threshold (default 4)

HONEST LIMITATIONS
- A round-robin does not mathematically guarantee 8 unique ranks. Cyclical conditions (A>B, B>C, C>A) can produce a tie, showing a 0 or a repeated rank. Treat a 0 as "no clear edge / choppy," not as a defect.
- Strength above/below a long MA is a slow, trend-following read. It tells you direction and context; it does not time entries.

This script is provided for educational and analytical purposes only. It is not financial advice and makes no representation about future results. Always do your own analysis and manage risk.

## Source Code

````pine
//@version=6
// VIP CURRENCY STRENGTH MATRIX (200 SMA, single-timeframe, memory-optimized)
indicator("VIP Currency Strength Matrix", "VIP CSM", overlay = true)

// ------------------------------- Inputs --------------------------------------
grpMA = "Strength engine (Above / Below reference)"
maType   = input.string("SMA", "Reference MA type", options = ["SMA", "EMA"], group = grpMA)
maLen    = input.int(200, "Reference MA length", minval = 2, group = grpMA)
histBars = input.int(300, "History bars per pair", minval = 50, group = grpMA, tooltip = "Caps bars loaded per request (memory control). Auto-raised to at least MA length + 50. If you see 'Memory limits exceeded', lower this and/or run on a 15m chart.")
prefix   = input.string("OANDA:", "Data-feed prefix", group = grpMA, tooltip = "Feed prefix for all 28 pairs, e.g. OANDA:  FX_IDC:  FX:  FOREXCOM:. Must cover every cross.")

grpTF = "Timeframe"
tf1 = input.timeframe("15", "Timeframe", group = grpTF, tooltip = "One TF per copy. For 15/60/240/D at once, add the indicator 4x. Keep the CHART at 15m (or lower) so pulls stay light.")

grpD = "Display"
panelTag       = input.string("", "Panel tag (optional header label)", group = grpD, tooltip = "Blank shows the raw timeframe. Or type 15m / 1H / 4H / Daily to label each copy.")
showStrength   = input.bool(true, "Show currency-strength table", group = grpD)
showMatrix     = input.bool(true, "Show pair-difference matrix", group = grpD)
sortMatrix     = input.bool(true, "Sort matrix by strongest signal", group = grpD)
highlightThresh= input.int(4, "Buy/Sell highlight threshold", minval = 1, maxval = 7, group = grpD)
strPos = input.string("bottom_left",  "Strength table position", group = grpD, options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"])
matPos = input.string("bottom_right", "Matrix table position", group = grpD, options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"])
txtSize= input.string("small", "Text size", options = ["tiny","small","normal","large"], group = grpD)

barsReq = math.max(histBars, maLen + 50)

// ------------------------- Currency / pair maps ------------------------------
// Index: 0 EUR  1 GBP  2 AUD  3 NZD  4 USD  5 CAD  6 CHF  7 JPY
var string[] CCY = array.from("EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY")
var string[] PAIRS = array.from("EURUSD","EURGBP","EURJPY","EURCHF","EURAUD","EURNZD","EURCAD","GBPUSD","GBPJPY","GBPCHF","GBPAUD","GBPNZD","GBPCAD","AUDUSD","AUDJPY","AUDCHF","AUDNZD","AUDCAD","NZDUSD","NZDJPY","NZDCHF","NZDCAD","USDJPY","USDCHF","USDCAD","CADJPY","CADCHF","CHFJPY")
var int[] BASE  = array.from(0,0,0,0,0,0,0, 1,1,1,1,1,1, 2,2,2,2,2, 3,3,3,3, 4,4,4, 5,5, 6)
var int[] QUOTE = array.from(4,1,7,6,2,3,5, 4,7,6,2,3,5, 4,7,6,3,5, 4,7,6,5, 7,6,5, 7,6, 7)

// ------------------------------- Helpers -------------------------------------
f_pos(string s) =>
    switch s
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right
        => position.bottom_right

f_size(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

f_orderDesc(int[] vals, int n) =>
    idx = array.new_int(n)
    for i = 0 to n - 1
        array.set(idx, i, i)
    for i = 0 to n - 2
        mj = i
        for j = i + 1 to n - 1
            if array.get(vals, array.get(idx, j)) > array.get(vals, array.get(idx, mj))
                mj := j
        if mj != i
            t = array.get(idx, i)
            array.set(idx, i, array.get(idx, mj))
            array.set(idx, mj, t)
    idx

f_diffCol(int d) =>
    ad  = math.abs(d)
    col = color.new(color.gray, 88)
    if d >= highlightThresh
        col := color.from_gradient(ad, highlightThresh, 7, color.rgb(30,120,60),  color.rgb(20,200,95))
    else if d <= -highlightThresh
        col := color.from_gradient(ad, highlightThresh, 7, color.rgb(140,45,45), color.rgb(225,35,35))
    else if d > 0
        col := color.new(color.green, 80)
    else if d < 0
        col := color.new(color.red, 80)
    col

// core round-robin for one timeframe -> [strongCounts(8), pairDiffs(28)]
f_calc(string tf) =>
    counts = array.new_int(8, 0)
    for i = 0 to 27
        sym = prefix + array.get(PAIRS, i)
        [c, m] = request.security(sym, tf, [close, maType == "EMA" ? ta.ema(close, maLen) : ta.sma(close, maLen)], ignore_invalid_symbol = true, calc_bars_count = barsReq)
        if not na(c) and not na(m)
            b = array.get(BASE,  i)
            q = array.get(QUOTE, i)
            if c > m
                array.set(counts, b, array.get(counts, b) + 1)
            else
                array.set(counts, q, array.get(counts, q) + 1)
    diffs = array.new_int(28, 0)
    for i = 0 to 27
        array.set(diffs, i, array.get(counts, array.get(BASE, i)) - array.get(counts, array.get(QUOTE, i)))
    [counts, diffs]

// ------------------------------ Computation ----------------------------------
[counts1, diffs1] = f_calc(tf1)
lbl = panelTag == "" ? tf1 : panelTag

// ------------------------------- Tables --------------------------------------
var table tS = table.new(f_pos(strPos), 2, 9,  frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)
var table tM = table.new(f_pos(matPos), 2, 29, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if barstate.islast
    tsz   = f_size(txtSize)
    hdrBg = color.new(color.gray, 15)

    if showStrength
        table.cell(tS, 0, 0, "CCY", text_color = color.white, bgcolor = hdrBg, text_size = tsz)
        table.cell(tS, 1, 0, lbl,   text_color = color.white, bgcolor = hdrBg, text_size = tsz)
        ord = f_orderDesc(counts1, 8)
        for r = 0 to 7
            ci = array.get(ord, r)
            v1 = array.get(counts1, ci)
            table.cell(tS, 0, r + 1, array.get(CCY, ci), text_color = color.white, bgcolor = color.new(color.black, 15), text_size = tsz)
            table.cell(tS, 1, r + 1, str.tostring(v1), text_color = color.white, bgcolor = color.from_gradient(v1, 0, 7, color.rgb(190,45,45), color.rgb(35,160,75)), text_size = tsz)

    if showMatrix
        table.cell(tM, 0, 0, "PAIR", text_color = color.white, bgcolor = hdrBg, text_size = tsz)
        table.cell(tM, 1, 0, lbl,    text_color = color.white, bgcolor = hdrBg, text_size = tsz)
        mord = f_orderDesc(diffs1, 28)
        for r = 0 to 27
            pi = sortMatrix ? array.get(mord, r) : r
            d1 = array.get(diffs1, pi)
            table.cell(tM, 0, r + 1, array.get(PAIRS, pi), text_color = color.white, bgcolor = color.new(color.black, 15), text_size = tsz)
            table.cell(tM, 1, r + 1, (d1 > 0 ? "+" : "") + str.tostring(d1), text_color = color.white, bgcolor = f_diffCol(d1), text_size = tsz)
````
