# India VIX Expected Move

- url: https://www.tradingview.com/script/63JDsZyu-India-VIX-Expected-Move/
- type: indicator
- pine_id: PUB;b8698c32577e4435a94cc2dc89d635fc
- version: 1.0

## Description

India VIX Expected Move

OVERVIEW
This tool turns India VIX into a daily expected-range estimate and draws it on the chart, anchored to the day's open. It shows how far price is statistically likely to travel today, with plus/minus 1 and 2 standard-deviation bands.

HOW IT WORKS
- 1-sigma daily move = Price x (VIX / 100) / sqrt(annualisation days). The default 252 trading days converts annualised implied volatility into a one-day figure.
- Bands are anchored to the day's open and stay fixed for the session, or can breathe with live VIX (optional).
- Roughly 68% of days finish inside the 1-sigma band and about 95% inside 2-sigma.
- A bias row reads likely direction from price versus the day's open plus a short trend filter - because VIX gives the size of the move, not its direction.

HOW TO USE
- Apply this on the index chart (for example NIFTY), not on the India VIX chart. The VIX value is pulled in automatically as the volatility input.
- Use the bands as realistic targets and as stretched zones: tagging 2-sigma can mark an over-extended, mean-reversion area.
- Read the bias row to see which band is the more likely target for the day.

NOTES
- Expected move is a probability range, not a guarantee; strong trending or high volatility days can exceed the bands. For research and education only; not financial advice.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//   INDIA VIX EXPECTED-MOVE BANDS
//   Today's expected range from implied volatility (current day only).
//   1σ daily move = Price × (VIX/100) ÷ √(annualization days).
//   ±1σ ≈ 68% • ±2σ ≈ 95%.  VIX = size of move, NOT direction.
//   Bias row reads direction from price vs open + short-term trend.
// ════════════════════════════════════════════════════════════════════
indicator("India VIX Expected Move", overlay = true, max_labels_count = 30, max_lines_count = 30)

// ───────────────────────────── INPUTS ──────────────────────────────
gV = "Volatility Source"
vixSym  = input.symbol("NSE:INDIAVIX", "VIX Symbol", group = gV)
annDays = input.int(252, "Annualization Days", minval = 200, maxval = 365, group = gV)
useLive = input.bool(false, "Use Live VIX (else VIX at open)", group = gV)

gB = "Bands"
show2  = input.bool(true, "Show ±2σ Band", group = gB)
rightX = input.int(8, "Extend Right (bars)", minval = 0, group = gB)

gD = "Direction Bias"
biasLen = input.int(20, "Bias Trend Length", minval = 2, group = gD)

gS = "Style"
col1   = input.color(#7e57c2, "±1σ Color", group = gS)
col2   = input.color(#42a5f5, "±2σ Color", group = gS)
colAnc = input.color(color.new(color.gray, 20), "Open Anchor Color", group = gS)
showTbl = input.bool(true, "Show Status Box", group = gS)

// ───────────────────────────── ENGINE ──────────────────────────────
tch = ta.change(time("D"))
isNew = na(tch) or tch != 0

vixNow = request.security(vixSym, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

var float anchor = na
var float vixRef = na
var int   openBar = na
if isNew
    anchor := open
    vixRef := vixNow
    openBar := bar_index

vixUse = useLive ? vixNow : vixRef
sigmaD = not na(vixUse) ? (vixUse / 100) / math.sqrt(annDays) : na
m1 = not na(anchor) and not na(sigmaD) ? anchor * sigmaD : na
up1 = anchor + m1
dn1 = anchor - m1
up2 = anchor + 2 * m1
dn2 = anchor - 2 * m1

// directional bias
ema = ta.ema(close, biasLen)
biasUp = not na(anchor) and close > anchor and ema > ema[1]
biasDn = not na(anchor) and close < anchor and ema < ema[1]

// safety: this belongs on the index (NIFTY), not on the VIX chart
isVixChart = str.contains(str.upper(syminfo.ticker), "VIX")
var label warn = na
if barstate.islast and isVixChart and na(warn)
    warn := label.new(bar_index, high, "⚠ Apply this on NIFTY, not on India VIX", style = label.style_label_down, color = color.orange, textcolor = color.white, size = size.normal)

// ───────────────────────────── DRAW (today only) ───────────────────
f_fmt(p) => str.tostring(p, format.mintick)
var line lnA = na, var line lnU1 = na, var line lnD1 = na, var line lnU2 = na, var line lnD2 = na
var label la = na, var label lu1 = na, var label ld1 = na, var label lu2 = na, var label ld2 = na

if barstate.islast and not na(m1)
    line.delete(lnA), line.delete(lnU1), line.delete(lnD1), line.delete(lnU2), line.delete(lnD2)
    label.delete(la), label.delete(lu1), label.delete(ld1), label.delete(lu2), label.delete(ld2)
    x2 = bar_index + rightX
    w1u = biasUp ? 3 : 1
    w1d = biasDn ? 3 : 1
    lnA  := line.new(openBar, anchor, x2, anchor, color = colAnc, style = line.style_dashed)
    lnU1 := line.new(openBar, up1, x2, up1, color = col1, width = w1u)
    lnD1 := line.new(openBar, dn1, x2, dn1, color = col1, width = w1d)
    if show2
        lnU2 := line.new(openBar, up2, x2, up2, color = col2, width = 1)
        lnD2 := line.new(openBar, dn2, x2, dn2, color = col2, width = 1)
    xl = x2 + 1
    lu1 := label.new(xl, up1, "+1σ  " + f_fmt(up1), style = label.style_label_left, color = color.new(col1, 0), textcolor = color.white, size = size.small)
    ld1 := label.new(xl, dn1, "-1σ  " + f_fmt(dn1), style = label.style_label_left, color = color.new(col1, 0), textcolor = color.white, size = size.small)
    la  := label.new(xl, anchor, "Open  " + f_fmt(anchor), style = label.style_label_left, color = color.new(color.gray, 10), textcolor = color.white, size = size.tiny)
    if show2
        lu2 := label.new(xl, up2, "+2σ  " + f_fmt(up2), style = label.style_label_left, color = color.new(col2, 0), textcolor = color.white, size = size.small)
        ld2 := label.new(xl, dn2, "-2σ  " + f_fmt(dn2), style = label.style_label_left, color = color.new(col2, 0), textcolor = color.white, size = size.small)

// ───────────────────────────── STATUS BOX ──────────────────────────
biasTxt = biasUp ? "▲ Up — target +1σ" : biasDn ? "▼ Down — target -1σ" : "• Neutral / range"
biasCol = biasUp ? #26a69a : biasDn ? #ef5350 : color.gray

var table tb = table.new(position.bottom_right, 2, 4, border_width = 1)
if showTbl and barstate.islast and not na(m1)
    table.cell(tb, 0, 0, useLive ? "India VIX (live)" : "India VIX (open)", text_color = color.white, bgcolor = color.new(#1e1e2e, 0), text_size = size.small)
    table.cell(tb, 1, 0, str.tostring(vixUse, "0.00"), text_color = color.white, bgcolor = color.new(col1, 10), text_size = size.small)
    table.cell(tb, 0, 1, "Exp. Move (1σ)", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tb, 1, 1, "±" + str.tostring(m1, "0") + " (" + str.tostring(sigmaD * 100, "0.00") + "%)", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(tb, 0, 2, "Day Range (1σ)", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tb, 1, 2, f_fmt(dn1) + " - " + f_fmt(up1), text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small)
    table.cell(tb, 0, 3, "Bias", text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = size.small)
    table.cell(tb, 1, 3, biasTxt, text_color = color.white, bgcolor = color.new(biasCol, 10), text_size = size.small)
````
