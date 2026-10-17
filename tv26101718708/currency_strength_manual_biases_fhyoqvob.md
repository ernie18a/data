# Currency Strength - Manual Biases       

- url: https://www.tradingview.com/script/FHYoQVOB-Currency-Strength-Manual-Biases/
- type: indicator
- pine_id: PUB;ddb6a5bece294c1284a42c4714c37ffb
- version: 1.0

## Description

Currency Strength — Manual Biases
Most currency strength meters calculate strength from price change over X bars. This one works the other way around: you provide the input. It turns your own directional biases per pair into a ranked currency strength table.
How it works
Each pair bias is a pairwise comparison between two currencies:

EUR/NZD short → NZD is stronger than EUR
GBP/USD short → USD is stronger than GBP

For every bias you set, the stronger currency gets +1 and the weaker one −1. The table (top right of your chart) ranks all currencies from strongest to weakest, showing each currency's net score and the number of pairs it was compared in.
Usage
Open the settings and set a bias per pair: "Long" (base currency stronger), "Short" (quote currency stronger), or "—" (pair not included). All 28 major and cross pairs of the 8 major currencies (EUR, GBP, AUD, NZD, USD, CAD, CHF, JPY) are available. The more pairs you assess, the more reliable the ranking — with only a few biases, one wrong assessment can flip the order.
Why manual instead of automatic?
If your methodology is built on your own top-down analysis, an automatic strength meter measures something different from what you actually trade. This tool doesn't replace your analysis — it organizes it. It shows you the ranking that logically follows from your own pair assessments, so you can spot which pairs combine your strongest and weakest currencies, and check whether your biases are internally consistent.
Note: the ranking is only as good as the biases you feed it. This is an organizational tool, not a signal generator — always validate any pair against your own trading plan before taking a setup.

## Source Code

````pine
//@version=6
indicator("Valutasterkte — manuele biases", overlay = true)

// ─────────────────────────────────────────────────────────────
// Stel per paar je richting in via de instellingen.
// Long  = basisvaluta sterker  |  Short = quotevaluta sterker
// "—"   = paar niet meegenomen
// ─────────────────────────────────────────────────────────────

string OPT_NONE  = "—"
string OPT_LONG  = "Long"
string OPT_SHORT = "Short"

// EUR-paren
bEURUSD = input.string(OPT_NONE, "EUR/USD", options = [ "—", "Long", "Short" ], group = "EUR-paren")
bEURGBP = input.string(OPT_NONE, "EUR/GBP", options = [ "—", "Long", "Short" ], group = "EUR-paren")
bEURJPY = input.string(OPT_NONE, "EUR/JPY", options = [ "—", "Long", "Short" ], group = "EUR-paren")
bEURCHF = input.string(OPT_NONE, "EUR/CHF", options = [ "—", "Long", "Short" ], group = "EUR-paren")
bEURAUD = input.string(OPT_NONE, "EUR/AUD", options = [ "—", "Long", "Short" ], group = "EUR-paren")
bEURNZD = input.string(OPT_NONE, "EUR/NZD", options = [ "—", "Long", "Short" ], group = "EUR-paren")
bEURCAD = input.string(OPT_NONE, "EUR/CAD", options = [ "—", "Long", "Short" ], group = "EUR-paren")

// GBP-paren
bGBPUSD = input.string(OPT_NONE, "GBP/USD", options = [ "—", "Long", "Short" ], group = "GBP-paren")
bGBPJPY = input.string(OPT_NONE, "GBP/JPY", options = [ "—", "Long", "Short" ], group = "GBP-paren")
bGBPCHF = input.string(OPT_NONE, "GBP/CHF", options = [ "—", "Long", "Short" ], group = "GBP-paren")
bGBPAUD = input.string(OPT_NONE, "GBP/AUD", options = [ "—", "Long", "Short" ], group = "GBP-paren")
bGBPNZD = input.string(OPT_NONE, "GBP/NZD", options = [ "—", "Long", "Short" ], group = "GBP-paren")
bGBPCAD = input.string(OPT_NONE, "GBP/CAD", options = [ "—", "Long", "Short" ], group = "GBP-paren")

// AUD-paren
bAUDUSD = input.string(OPT_NONE, "AUD/USD", options = [ "—", "Long", "Short" ], group = "AUD-paren")
bAUDJPY = input.string(OPT_NONE, "AUD/JPY", options = [ "—", "Long", "Short" ], group = "AUD-paren")
bAUDCHF = input.string(OPT_NONE, "AUD/CHF", options = [ "—", "Long", "Short" ], group = "AUD-paren")
bAUDNZD = input.string(OPT_NONE, "AUD/NZD", options = [ "—", "Long", "Short" ], group = "AUD-paren")
bAUDCAD = input.string(OPT_NONE, "AUD/CAD", options = [ "—", "Long", "Short" ], group = "AUD-paren")

// NZD-paren
bNZDUSD = input.string(OPT_NONE, "NZD/USD", options = [ "—", "Long", "Short" ], group = "NZD-paren")
bNZDJPY = input.string(OPT_NONE, "NZD/JPY", options = [ "—", "Long", "Short" ], group = "NZD-paren")
bNZDCHF = input.string(OPT_NONE, "NZD/CHF", options = [ "—", "Long", "Short" ], group = "NZD-paren")
bNZDCAD = input.string(OPT_NONE, "NZD/CAD", options = [ "—", "Long", "Short" ], group = "NZD-paren")

// USD-paren
bUSDJPY = input.string(OPT_NONE, "USD/JPY", options = [ "—", "Long", "Short" ], group = "USD-paren")
bUSDCHF = input.string(OPT_NONE, "USD/CHF", options = [ "—", "Long", "Short" ], group = "USD-paren")
bUSDCAD = input.string(OPT_NONE, "USD/CAD", options = [ "—", "Long", "Short" ], group = "USD-paren")

// CAD/CHF-paren
bCADJPY = input.string(OPT_NONE, "CAD/JPY", options = [ "—", "Long", "Short" ], group = "Overige")
bCADCHF = input.string(OPT_NONE, "CAD/CHF", options = [ "—", "Long", "Short" ], group = "Overige")
bCHFJPY = input.string(OPT_NONE, "CHF/JPY", options = [ "—", "Long", "Short" ], group = "Overige")

// ── scores ──────────────────────────────────────────────────
var array<string> curs = array.from("EUR", "GBP", "AUD", "NZD", "USD", "CAD", "CHF", "JPY")

applyBias(array<int> scores, array<int> counts, string bias, string base, string quote) =>
    if bias != "—"
        int iB = array.indexof(curs, base)
        int iQ = array.indexof(curs, quote)
        int sIdx = bias == "Long" ? iB : iQ
        int wIdx = bias == "Long" ? iQ : iB
        array.set(scores, sIdx, array.get(scores, sIdx) + 1)
        array.set(scores, wIdx, array.get(scores, wIdx) - 1)
        array.set(counts, sIdx, array.get(counts, sIdx) + 1)
        array.set(counts, wIdx, array.get(counts, wIdx) + 1)

// ── tabel ───────────────────────────────────────────────────
var table t = table.new(position.top_right, 4, 9, bgcolor = color.new(#161f2e, 10), border_width = 1, border_color = color.new(#2a3850, 0))

if barstate.islast
    array<int> scores = array.new_int(8, 0)
    array<int> counts = array.new_int(8, 0)

    applyBias(scores, counts, bEURUSD, "EUR", "USD")
    applyBias(scores, counts, bEURGBP, "EUR", "GBP")
    applyBias(scores, counts, bEURJPY, "EUR", "JPY")
    applyBias(scores, counts, bEURCHF, "EUR", "CHF")
    applyBias(scores, counts, bEURAUD, "EUR", "AUD")
    applyBias(scores, counts, bEURNZD, "EUR", "NZD")
    applyBias(scores, counts, bEURCAD, "EUR", "CAD")
    applyBias(scores, counts, bGBPUSD, "GBP", "USD")
    applyBias(scores, counts, bGBPJPY, "GBP", "JPY")
    applyBias(scores, counts, bGBPCHF, "GBP", "CHF")
    applyBias(scores, counts, bGBPAUD, "GBP", "AUD")
    applyBias(scores, counts, bGBPNZD, "GBP", "NZD")
    applyBias(scores, counts, bGBPCAD, "GBP", "CAD")
    applyBias(scores, counts, bAUDUSD, "AUD", "USD")
    applyBias(scores, counts, bAUDJPY, "AUD", "JPY")
    applyBias(scores, counts, bAUDCHF, "AUD", "CHF")
    applyBias(scores, counts, bAUDNZD, "AUD", "NZD")
    applyBias(scores, counts, bAUDCAD, "AUD", "CAD")
    applyBias(scores, counts, bNZDUSD, "NZD", "USD")
    applyBias(scores, counts, bNZDJPY, "NZD", "JPY")
    applyBias(scores, counts, bNZDCHF, "NZD", "CHF")
    applyBias(scores, counts, bNZDCAD, "NZD", "CAD")
    applyBias(scores, counts, bUSDJPY, "USD", "JPY")
    applyBias(scores, counts, bUSDCHF, "USD", "CHF")
    applyBias(scores, counts, bUSDCAD, "USD", "CAD")
    applyBias(scores, counts, bCADJPY, "CAD", "JPY")
    applyBias(scores, counts, bCADCHF, "CAD", "CHF")
    applyBias(scores, counts, bCHFJPY, "CHF", "JPY")

    // sorteer indexen op score (aflopend), alleen valuta's met minstens 1 vergelijking
    array<int> order = array.new_int()
    for i = 0 to 7
        if array.get(counts, i) > 0
            array.push(order, i)
    int n = array.size(order)
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - 2 - i
                int a = array.get(order, j)
                int b = array.get(order, j + 1)
                if array.get(scores, b) > array.get(scores, a)
                    array.set(order, j, b)
                    array.set(order, j + 1, a)

    // koprij
    table.cell(t, 0, 0, "#",      text_color = color.new(#7d8ca3, 0), text_size = size.small)
    table.cell(t, 1, 0, "Valuta", text_color = color.new(#7d8ca3, 0), text_size = size.small)
    table.cell(t, 2, 0, "Score",  text_color = color.new(#7d8ca3, 0), text_size = size.small)
    table.cell(t, 3, 0, "Verg.",  text_color = color.new(#7d8ca3, 0), text_size = size.small)

    for r = 0 to 7
        if r < n
            int ci = array.get(order, r)
            int sc = array.get(scores, ci)
            color scol = sc > 0 ? color.new(#4fd08a, 0) : sc < 0 ? color.new(#f0705f, 0) : color.new(#7d8ca3, 0)
            table.cell(t, 0, r + 1, str.tostring(r + 1),                text_color = color.new(#7d8ca3, 0), text_size = size.small)
            table.cell(t, 1, r + 1, array.get(curs, ci),                text_color = color.new(#dce6f2, 0), text_size = size.normal)
            table.cell(t, 2, r + 1, (sc > 0 ? "+" : "") + str.tostring(sc), text_color = scol, text_size = size.normal)
            table.cell(t, 3, r + 1, str.tostring(array.get(counts, ci)) + "×", text_color = color.new(#7d8ca3, 0), text_size = size.small)
        else
            table.cell(t, 0, r + 1, "")
            table.cell(t, 1, r + 1, "")
            table.cell(t, 2, r + 1, "")
            table.cell(t, 3, r + 1, "")
````
