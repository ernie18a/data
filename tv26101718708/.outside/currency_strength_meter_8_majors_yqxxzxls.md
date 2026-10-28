# Currency Strength Meter - 8 Majors

- url: https://www.tradingview.com/script/YQxXzxls-Currency-Strength-Meter-8-Majors/
- type: indicator
- pine_id: PUB;3f91d31b44774e249e14e300cf2d279b
- version: 1.0

## Description

calculates the relative strength of of the 8 major currencies. Using rsi aggregated across all 28 major currency pairs instead of rely on 1 single pair.

For each currency,RSI is pulled from every pair it appears in. When the currency is the base, RSI is used as is, when its the quote, RSI is inverted (100- RSI), since a rising pair means the quote currency is weakening. These values are averaged into one strength score per currency and plotted as a line.

A rising line means that the currency is strengthening, a falling line means its weakening. The table ranks all currencies live from strongest to weakest and any currency can be toggled off in settings. RSI length and timeframe are adjustable. This is a momentum gauge meant to support your own trading decisions, not a standalone signal system.

## Source Code

````pine
//@version=6
indicator('Currency Strength Meter - 8 Majors', overlay = false)

// ── Inputs ─────────────────────────────────────────────
rsiLen = input.int(14, 'RSI Length')
rsiTF = input.timeframe('1', 'RSI Timeframe')

showUSD = input.bool(true, 'Show USD', group = 'Currencies')
showEUR = input.bool(true, 'Show EUR', group = 'Currencies')
showGBP = input.bool(true, 'Show GBP', group = 'Currencies')
showJPY = input.bool(true, 'Show JPY', group = 'Currencies')
showCHF = input.bool(true, 'Show CHF', group = 'Currencies')
showCAD = input.bool(true, 'Show CAD', group = 'Currencies')
showAUD = input.bool(true, 'Show AUD', group = 'Currencies')
showNZD = input.bool(true, 'Show NZD', group = 'Currencies')

f_rsi(sym) =>
    float r = request.security(sym, rsiTF, ta.rsi(close, rsiLen), lookahead = barmerge.lookahead_off)
    r

// ── Pull RSI for all 28 pairs ──
float EURUSD = f_rsi('FX:EURUSD')
float GBPUSD = f_rsi('FX:GBPUSD')
float AUDUSD = f_rsi('FX:AUDUSD')
float NZDUSD = f_rsi('FX:NZDUSD')
float USDJPY = f_rsi('FX:USDJPY')
float USDCHF = f_rsi('FX:USDCHF')
float USDCAD = f_rsi('FX:USDCAD')
float EURGBP = f_rsi('FX:EURGBP')
float EURJPY = f_rsi('FX:EURJPY')
float EURCHF = f_rsi('FX:EURCHF')
float EURCAD = f_rsi('FX:EURCAD')
float EURAUD = f_rsi('FX:EURAUD')
float EURNZD = f_rsi('FX:EURNZD')
float GBPJPY = f_rsi('FX:GBPJPY')
float GBPCHF = f_rsi('FX:GBPCHF')
float GBPCAD = f_rsi('FX:GBPCAD')
float GBPAUD = f_rsi('FX:GBPAUD')
float GBPNZD = f_rsi('FX:GBPNZD')
float AUDJPY = f_rsi('FX:AUDJPY')
float AUDCHF = f_rsi('FX:AUDCHF')
float AUDCAD = f_rsi('FX:AUDCAD')
float AUDNZD = f_rsi('FX:AUDNZD')
float NZDJPY = f_rsi('FX:NZDJPY')
float NZDCHF = f_rsi('FX:NZDCHF')
float NZDCAD = f_rsi('FX:NZDCAD')
float CADJPY = f_rsi('FX:CADJPY')
float CADCHF = f_rsi('FX:CADCHF')
float CHFJPY = f_rsi('FX:CHFJPY')

// ── Per-currency strength: average RSI across all pairs it appears in ──
float usd = math.avg(100.0 - EURUSD, 100.0 - GBPUSD, 100.0 - AUDUSD, 100.0 - NZDUSD, USDJPY, USDCHF, USDCAD)
float eur = math.avg(EURUSD, EURGBP, EURJPY, EURCHF, EURCAD, EURAUD, EURNZD)
float gbp = math.avg(GBPUSD, 100.0 - EURGBP, GBPJPY, GBPCHF, GBPCAD, GBPAUD, GBPNZD)
float jpy = math.avg(100.0 - USDJPY, 100.0 - EURJPY, 100.0 - GBPJPY, 100.0 - AUDJPY, 100.0 - NZDJPY, 100.0 - CADJPY, 100.0 - CHFJPY)
float chf = math.avg(100.0 - USDCHF, 100.0 - EURCHF, 100.0 - GBPCHF, 100.0 - AUDCHF, 100.0 - NZDCHF, 100.0 - CADCHF, CHFJPY)
float cad = math.avg(100.0 - USDCAD, 100.0 - EURCAD, 100.0 - GBPCAD, 100.0 - AUDCAD, 100.0 - NZDCAD, CADJPY, CADCHF)
float aud = math.avg(AUDUSD, 100.0 - EURAUD, 100.0 - GBPAUD, AUDJPY, AUDCHF, AUDCAD, AUDNZD)
float nzd = math.avg(NZDUSD, 100.0 - EURNZD, 100.0 - GBPNZD, 100.0 - AUDNZD, NZDJPY, NZDCHF, NZDCAD)

// ── Plot lines only if their toggle is on ──
plot(showUSD ? usd : na, 'USD', color = color.new(color.green, 0), linewidth = 1)
plot(showEUR ? eur : na, 'EUR', color = color.new(#87CEFA, 0), linewidth = 1)
plot(showGBP ? gbp : na, 'GBP', color = color.new(color.red, 0), linewidth = 1)
plot(showJPY ? jpy : na, 'JPY', color = color.new(color.fuchsia, 0), linewidth = 1)
plot(showCHF ? chf : na, 'CHF', color = color.new(color.lime, 0), linewidth = 1)
plot(showCAD ? cad : na, 'CAD', color = color.new(color.yellow, 0), linewidth = 1)
plot(showAUD ? aud : na, 'AUD', color = color.new(color.aqua, 0), linewidth = 1)
plot(showNZD ? nzd : na, 'NZD', color = color.new(color.purple, 0), linewidth = 1)

hline(50, 'Midline', color = color.gray, linestyle = hline.style_dashed)

// ── Ranked table, strongest to weakest — only includes checked currencies ──
var table t = table.new(position.top_right, 2, 9, border_width = 1)

if barstate.islast
    array<string> names = array.new_string(0)
    array<float> vals = array.new_float(0)

    if showUSD
        array.push(names, 'USD')
        array.push(vals, usd)
    if showEUR
        array.push(names, 'EUR')
        array.push(vals, eur)
    if showGBP
        array.push(names, 'GBP')
        array.push(vals, gbp)
    if showJPY
        array.push(names, 'JPY')
        array.push(vals, jpy)
    if showCHF
        array.push(names, 'CHF')
        array.push(vals, chf)
    if showCAD
        array.push(names, 'CAD')
        array.push(vals, cad)
    if showAUD
        array.push(names, 'AUD')
        array.push(vals, aud)
    if showNZD
        array.push(names, 'NZD')
        array.push(vals, nzd)

    int n = array.size(vals)

    // manual swap sort — descending
    if n > 1
        for i = 0 to n - 2 by 1
            for j = 0 to n - 2 - i by 1
                float vj = array.get(vals, j)
                float vj1 = array.get(vals, j + 1)
                if vj < vj1
                    string nj = array.get(names, j)
                    string nj1 = array.get(names, j + 1)
                    array.set(vals, j, vj1)
                    array.set(vals, j + 1, vj)
                    array.set(names, j, nj1)
                    array.set(names, j + 1, nj)

    table.cell(t, 0, 0, 'Currency', bgcolor = color.gray, text_color = color.white)
    table.cell(t, 1, 0, 'Strength', bgcolor = color.gray, text_color = color.white)

    for i = 0 to n - 1 by 1
        float v = array.get(vals, i)
        string nm = array.get(names, i)
        color bg = v >= 50.0 ? color.new(color.green, 75) : color.new(color.red, 75)
        table.cell(t, 0, i + 1, nm, bgcolor = bg, text_color = color.white)
        table.cell(t, 1, i + 1, str.tostring(v, '#.##'), bgcolor = bg, text_color = color.white)
````
