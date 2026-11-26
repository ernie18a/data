# Bond Yield Strength - 10Y Majors

- url: https://www.tradingview.com/script/hokb8ZuD-Bond-Yield-Strength-10Y-Majors/
- type: indicator
- pine_id: PUB;d32328fab6ce485bbb1efa315467c168
- version: 3.0

## Description

[b]Bond Yield Strength — 10Y Majors[/b]

Track intraday momentum across the 8 major bond markets in a single panel. This indicator plots the change in 10-year government bond yields for USD, EUR, JPY, GBP, AUD, NZD, CAD and CHF, normalized to a common starting point so you can instantly see which currencies are catching a bid in the rates market — and which are getting sold.

[b]What it shows[/b]

Each line represents how far a country's 10Y yield has moved (in basis points or %) since the start of the current period. All 8 lines start at zero on each reset, making relative strength immediately readable. A line climbing above zero means yields are rising in that country (typically bullish for the currency); a line falling below zero means yields are dropping.

The eight benchmarks tracked:
[list]
[*][b]USD[/b] → US10Y (US Treasury)
[*][b]EUR[/b] → DE10Y (German Bund, the eurozone benchmark)
[*][b]JPY[/b] → JP10Y (JGB)
[*][b]GBP[/b] → GB10Y (Gilt)
[*][b]AUD[/b] → AU10Y
[*][b]NZD[/b] → NZ10Y
[*][b]CAD[/b] → CA10Y
[*][b]CHF[/b] → CH10Y
[/list]

[b]Why it's useful[/b]

Rate differentials drive FX. When US yields rip while Bunds stay flat, EUR/USD usually feels it. This indicator gives you that read at a glance, without flipping between 8 separate charts. Particularly useful for:
[list]
[*]Spotting which currencies have a yield tailwind heading into a session
[*]Confirming or fading FX moves against the rates backdrop
[*]Watching the reaction to central bank decisions, CPI releases, and bond auctions across all majors simultaneously
[*]Identifying outliers (one yield diverging from the pack often precedes an FX move)
[/list]

[b]Settings[/b]

[list]
[*][b]Display unit[/b]: basis points (default, the standard rates unit) or percent
[*][b]Reset period[/b]: Daily, Weekly, or Monthly — choose your lookback horizon
[*][b]Line thickness[/b]: 1 to 4
[*][b]End-of-line labels[/b]: toggle currency tags with live values at the right edge of the chart
[*][b]Day separators[/b]: optional dashed verticals at each session boundary
[/list]

[b]Recommended setup[/b]

Apply on a 24-hour symbol (e.g. [b]FX:EURUSD[/b] or any major forex pair) on a 15m to 1h timeframe — bond symbols themselves don't trade overnight, so the chart's time axis needs to come from a continuously-quoted instrument. You can hide the underlying price plot via the chart's visibility toggle to keep only the yield indicator on screen.

[b]Notes[/b]

DE10Y (German Bund) is used as the EUR proxy — it's the de facto eurozone benchmark used by rates desks globally. Data availability for some symbols depends on your TradingView plan; if a yield doesn't render, your plan may not include that exchange.

Feedback and suggestions welcome.

## Source Code

````pine
//@version=6
indicator("Bond Yield Strength — 10Y Majors", overlay=false, precision=1)

// === Inputs ===
useBps     = input.bool(true,  "Show in basis points (else %)")
resetMode  = input.string("Daily", "Reset period", options=["Daily", "Weekly", "Monthly"])
lw         = input.int(1, "Line thickness", minval=1, maxval=4)
showLabels = input.bool(true, "Show currency labels")
showValue  = input.bool(true, "Show value in label")
minGap     = input.float(0.0, "Min label spacing (0 = auto)", minval=0, step=0.1)
showDaySep = input.bool(true, "Show day separators")
sepColor   = input.color(color.new(color.gray, 60), "Day separator color")

// === Period start detection ===
tf = resetMode == "Weekly" ? "W" : resetMode == "Monthly" ? "M" : "D"
isNewPeriod = ta.change(time(tf)) != 0

// === 10Y yield fetch ===
us = request.security("TVC:US10Y", timeframe.period, close)
de = request.security("TVC:DE10Y", timeframe.period, close)
jp = request.security("TVC:JP10Y", timeframe.period, close)
gb = request.security("TVC:GB10Y", timeframe.period, close)
au = request.security("TVC:AU10Y", timeframe.period, close)
nz = request.security("TVC:NZ10Y", timeframe.period, close)
ca = request.security("TVC:CA10Y", timeframe.period, close)
ch = request.security("TVC:CH10Y", timeframe.period, close)

// === Anchor at period start ===
var float usO = na
var float deO = na
var float jpO = na
var float gbO = na
var float auO = na
var float nzO = na
var float caO = na
var float chO = na

if isNewPeriod or na(usO)
    usO := us
    deO := de
    jpO := jp
    gbO := gb
    auO := au
    nzO := nz
    caO := ca
    chO := ch

// === Variation since period start ===
m   = useBps ? 100.0 : 1.0
usd = (us - usO) * m
eur = (de - deO) * m
jpy = (jp - jpO) * m
gbp = (gb - gbO) * m
aud = (au - auO) * m
nzd = (nz - nzO) * m
cad = (ca - caO) * m
chf = (ch - chO) * m

// === Colors ===
cUSD = color.rgb(245,158,11)
cEUR = color.rgb(239,68,68)
cJPY = color.rgb(34,211,238)
cGBP = color.rgb(34,197,94)
cAUD = color.rgb(59,130,246)
cNZD = color.rgb(236,72,153)
cCAD = color.rgb(168,85,247)
cCHF = color.rgb(120,53,15)

// === Plots ===
plot(usd, "USD", color=cUSD, linewidth=lw)
plot(eur, "EUR", color=cEUR, linewidth=lw)
plot(jpy, "JPY", color=cJPY, linewidth=lw)
plot(gbp, "GBP", color=cGBP, linewidth=lw)
plot(aud, "AUD", color=cAUD, linewidth=lw)
plot(nzd, "NZD", color=cNZD, linewidth=lw)
plot(cad, "CAD", color=cCAD, linewidth=lw)
plot(chf, "CHF", color=cCHF, linewidth=lw)

hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// === End-of-line labels (non-overlapping) ===
unit = useBps ? " bps" : "%"

var label[] lblArr = array.new<label>(0)
var line[]  lnArr  = array.new<line>(0)

// Check at least one value is valid
hasData = not na(usd) or not na(eur) or not na(jpy) or not na(gbp) or not na(aud) or not na(nzd) or not na(cad) or not na(chf)

if showLabels and barstate.islast and hasData
    // Clear previous labels and connectors
    for lbl in lblArr
        label.delete(lbl)
    for ln in lnArr
        line.delete(ln)
    array.clear(lblArr)
    array.clear(lnArr)

    // Replace na with 0 to keep arrays safe
    vUSD = na(usd) ? 0.0 : usd
    vEUR = na(eur) ? 0.0 : eur
    vJPY = na(jpy) ? 0.0 : jpy
    vGBP = na(gbp) ? 0.0 : gbp
    vAUD = na(aud) ? 0.0 : aud
    vNZD = na(nzd) ? 0.0 : nzd
    vCAD = na(cad) ? 0.0 : cad
    vCHF = na(chf) ? 0.0 : chf

    vals  = array.from(vUSD, vEUR, vJPY, vGBP, vAUD, vNZD, vCAD, vCHF)
    names = array.from("USD", "EUR", "JPY", "GBP", "AUD", "NZD", "CAD", "CHF")
    cols  = array.from(cUSD, cEUR, cJPY, cGBP, cAUD, cNZD, cCAD, cCHF)

    // Auto gap based on amplitude
    vMax    = array.max(vals)
    vMin    = array.min(vals)
    vRange  = vMax - vMin
    autoGap = math.max(useBps ? 0.5 : 0.05, vRange * 0.05)
    gap     = minGap > 0 ? minGap : autoGap

    // Sort ascending and compute display positions
    sortedIdx = array.sort_indices(vals, order.ascending)
    dispY     = array.new<float>(8, 0.0)

    for i = 0 to 7
        oi = array.get(sortedIdx, i)
        v  = array.get(vals, oi)
        if i == 0
            array.set(dispY, oi, v)
        else
            prevOi   = array.get(sortedIdx, i - 1)
            prevDisp = array.get(dispY, prevOi)
            array.set(dispY, oi, math.max(v, prevDisp + gap))

    // Draw labels and connector lines
    xOffset = 3
    for i = 0 to 7
        v   = array.get(vals, i)
        y   = array.get(dispY, i)
        nm  = array.get(names, i)
        c   = array.get(cols, i)
        txt = showValue ? nm + "  " + str.tostring(v, "#.#") + unit : nm

        ln  = line.new(bar_index, v, bar_index + xOffset, y, xloc=xloc.bar_index, color=color.new(c, 40), width=1)
        lbl = label.new(bar_index + xOffset, y, txt, xloc=xloc.bar_index, color=c, textcolor=color.white, style=label.style_label_left, size=size.small)

        array.push(lnArr, ln)
        array.push(lblArr, lbl)

// === Day separators ===
isNewDay = ta.change(time("D")) != 0
if showDaySep and isNewDay
    line.new(bar_index, 0, bar_index, 0, xloc=xloc.bar_index, extend=extend.both, color=sepColor, style=line.style_dashed, width=1)
````
