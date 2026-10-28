# IV Rank & Percentile XVI (S&P/ASX200 VIX)

- url: https://www.tradingview.com/script/HU5XeCrz-IV-Rank-Percentile-XVI-S-P-ASX200-VIX/
- type: indicator
- pine_id: PUB;f67f9d477f8b4d5ca1f2bde0f1f752bf
- version: 2.0

## Description

Most IV Rank and IV Percentile indicators on TradingView are built for the US VIX. This one is built specifically for XVI — the S&P/ASX 200 VIX (A-VIX) — so Australian index traders, and anyone trading XJO options, finally get the same volatility context without borrowing a US proxy. It reads straight off the published XVI value, so there's no option-chain reconstruction or estimation involved.

The core idea:

XVI is the ASX's "fear number" — the implied volatility of the XJO, the market's estimate of how much it's about to move over the next 30 days. The problem is that a raw XVI value is meaningless on its own. Is 16 high? Low? You can't know without context. This indicator's whole job is to give that context by answering one question: compared to its own recent history, is volatility currently rich, normal, or cheap?

The two ways it measures that:

IV Rank is the simple one. It looks at the highest and lowest XVI over your lookback window (a year by default) and asks where today sits on that line. XVI at its yearly low reads 0. At its yearly high, 100. Halfway between, 50. That's it — it's just "where in the range are we."
IV Percentile asks a slightly different question: of all the days in the window, what percentage had a lower XVI than today? If it reads 70, then vol is higher than it was on 70% of the past year's days. The reason this one's usually better is that IV Rank gets distorted by a single spike — one brief crash sets a sky-high "yearly high," and then every reading afterward looks artificially low against it for a whole year. Percentile doesn't have that problem because it counts days, so one freak day is just one day. That's why the regime label runs off Percentile by default.

The regime label:

This translates those 0–100 numbers into a single word so you don't have to interpret them each time. You set two thresholds — default 80 and 20. Above 80 it reads HIGH (vol is richer than most of the past year). Below 20, LOW (vol is cheap). Anything between, NORMAL. The thresholds are yours to move: if you think 80 is too strict and want it flagging "high" earlier, drop it to 70. The cutoffs define what you consider rich versus cheap. You can also switch whether the label reads off Percentile or Rank.

Live updating:

The ranking history is built from daily XVI closes (you want to rank against a year of daily data, not intraday noise), but the current reading floats live against that history. As XVI moves through the session, IV Rank, IV Percentile, and the regime word update with it rather than waiting for the daily close.

Settings:

Volatility index — defaults to ASX:XVI. Can be pointed at another volatility index if you want to reuse the tool elsewhere.
History timeframe — the bar size the ranking history is measured on. Daily is standard.
Lookback — how far back it ranks. 252 ≈ one year. Drop it to 90 or 60 for a tighter, more recent read; the long-window and short-window answers genuinely differ when the past year contains a stale spike, so comparing the two is useful.
Regime read from / High threshold / Low threshold — choose whether the label is driven by Percentile or Rank, and set the two cutoffs.
Display — plot the Percentile line on or off, and position the readout table in any corner.

Reading it:

The pane plots IV Rank (aqua) and IV Percentile (orange) on a 0–100 scale, with dashed guide lines at your high and low thresholds and a dotted midline at 50. The corner table shows the live XVI level alongside both readings and the current regime.
A note on the data: because XVI is a calculated index rather than a traded instrument, your reading is only as live as your XVI data feed. On delayed feeds it updates with that delay, which is still perfectly adequate for volatility-regime context.
This script is a volatility-context tool, not a trading system. It tells you where implied volatility sits relative to its own history; it does not generate buy or sell signals, and nothing here is financial advice.

## Source Code

````pine
//@version=6
indicator("IV Rank & Percentile XVI (AUS)", shorttitle = "XVI IVR/IVP", precision = 1)

// ============ Inputs ============
vixSym   = input.symbol("ASX:XVI", "Volatility index",
     tooltip = "The A-VIX (S&P/ASX 200 VIX). This IS the 30-day implied vol of the XJO.", display = display.none)
calcTF   = input.timeframe("D", "History timeframe",
     tooltip = "The bar size the ranking HISTORY is measured on. Daily ('D') is standard — you rank against a year of daily closes. The live value updates on your chart timeframe regardless.", display = display.none)
lookback = input.int(252, "Lookback (bars on history TF)", minval = 20,
     tooltip = "How many bars back to rank against. 252 ≈ 1 year of daily bars. Drop to 90 or 60 for a tighter, more recent read.", display = display.none)

regimeSrc = input.string("IV Percentile", "Regime read from", options = ["IV Percentile", "IV Rank"], group = "Regime",
     tooltip = "Also sets which line is the main (thick) line.", display = display.none)
hiThresh  = input.float(75, "High threshold", minval = 50, maxval = 100, group = "Regime", display = display.none)
loThresh  = input.float(25, "Low threshold",  minval = 0,  maxval = 50,  group = "Regime", display = display.none)
vhThresh  = input.float(90, "Very high threshold", minval = 50, maxval = 100, group = "Regime", display = display.none)
vlThresh  = input.float(10, "Very low threshold",  minval = 0,  maxval = 50,  group = "Regime", display = display.none)

showSec   = input.bool(true, "Show secondary line", group = "Display",
     tooltip = "The line the regime is NOT read from, drawn thin and faded.", display = display.none)
showZones = input.bool(true, "Regime zones",             group = "Display", display = display.none)
showGlow  = input.bool(true, "Highlight when in a zone", group = "Display", display = display.none)

gSty      = "Style"
cPct      = input.color(#ffab40, "IV Percentile", group = gSty, inline = "ln", display = display.none)
cRank     = input.color(#4fc3f7, "IV Rank",       group = gSty, inline = "ln", display = display.none)
mainW     = input.int(2, "Line width  main", minval = 1, maxval = 4, group = gSty, inline = "lw", display = display.none)
secW      = input.int(1, "secondary",        minval = 1, maxval = 4, group = gSty, inline = "lw", display = display.none)
cHigh     = input.color(#e53935, "High vol",  group = gSty, inline = "zc", display = display.none)
cLow      = input.color(#43a047, "Low vol",   group = gSty, inline = "zc", display = display.none)
zoneStr   = input.string("Normal", "Zone intensity", options = ["Subtle", "Normal", "Strong"], group = gSty, display = display.none)

gRd       = "Readout"
showTbl   = input.bool(true, "Show readout", group = gRd, display = display.none)
tblPos    = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gRd, display = display.none)
tblSize   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gRd, display = display.none)
showChg   = input.bool(true, "Show daily change (▲▼)", group = gRd, display = display.none)

// ============ Colours ============
// Deeper shades are derived from the chosen high / low colours, so changing one
// colour re-tints the whole zone, the glow and the regime label together.
shade(color c, float f) =>
    color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f)

cVHigh    = shade(cHigh, 0.75)   // VERY HIGH label
cHighDeep = shade(cHigh, 0.50)   // darkest end of the zone
cVLow     = shade(cLow, 0.75)
cLowDeep  = shade(cLow, 0.50)
cNorm     = #787b86
cGrey     = #9598a1

// Zone intensity: shifts every zone / glow transparency together (fully clear stays clear)
zShift = zoneStr == "Subtle" ? 8 : zoneStr == "Strong" ? -10 : 0
zt(float t) =>
    t >= 100 ? 100.0 : math.max(0.0, math.min(100.0, t + zShift))

// ============ History: the last N completed closes on the history timeframe ============
// Built inside the history timeframe, so the ranking is always against real daily
// (or whatever TF) closes — whatever timeframe the chart is on.
histCloses(int n) =>
    var array<float> a = array.new_float()
    if bar_index > 0 and not na(close[1])
        array.push(a, close[1])
        if array.size(a) > n
            array.shift(a)
    a

hist = request.security(vixSym, calcTF, histCloses(lookback), lookahead = barmerge.lookahead_off)

// LIVE current XVI on the chart's own timeframe (updates intraday)
xvi = request.security(vixSym, timeframe.period, close)

// ============ Rank & percentile of the live value against that history ============
float ivRank = na
float ivPct  = na
if not na(hist) and not na(xvi)
    int n = array.size(hist)
    if n > 0
        float hi = math.max(array.max(hist), xvi)   // live print can be a new extreme
        float lo = math.min(array.min(hist), xvi)
        ivRank := hi - lo != 0 ? (xvi - lo) / (hi - lo) * 100 : na
        int nBelow = 0
        for v in hist
            nBelow += v < xvi ? 1 : 0
        ivPct := 100.0 * nBelow / n

// Value at the end of the previous history bar (yesterday on 'D'), for the ▲▼ change
r1 = ivRank[1]
p1 = ivPct[1]
var float prevRank = na
var float prevPct  = na
if timeframe.change(calcTF)
    prevRank := r1
    prevPct  := p1

// ============ Main / secondary line + regime ============
isPct   = regimeSrc == "IV Percentile"
mainVal = isPct ? ivPct  : ivRank
secVal  = isPct ? ivRank : ivPct
mainCol = isPct ? cPct   : cRank
secCol  = isPct ? cRank  : cPct

// Very high / very low always sit outside high / low, even if the inputs overlap
vhLvl = math.max(vhThresh, hiThresh)
vlLvl = math.min(vlThresh, loThresh)

regime = na(mainVal)        ? "n/a"       :
         mainVal >= vhLvl   ? "VERY HIGH" :
         mainVal >= hiThresh ? "HIGH"     :
         mainVal <= vlLvl   ? "VERY LOW"  :
         mainVal <= loThresh ? "LOW"      : "NORMAL"
regCol = regime == "VERY HIGH" ? cVHigh : regime == "HIGH" ? cHigh :
         regime == "VERY LOW"  ? cVLow  : regime == "LOW"  ? cLow  : cNorm

// ============ Scale lock 0–100 ============
hline(100, "Scale top",    color = color.new(cGrey, 100), editable = false)
hline(0,   "Scale bottom", color = color.new(cGrey, 100), editable = false)

// ============ Regime zones: clear at the threshold, easing into colour towards the extreme ============
// High band (75→90) fades in from clear to a light tint; the very-high band (90→100)
// carries on from that tint to deep red. Mirrored in green below. No hard edges.
p100  = plot(100,      "Zone top",            color = na, display = display.none, editable = false)
pVHi  = plot(vhLvl,    "Very high threshold", color = na, display = display.none, editable = false)
pHi   = plot(hiThresh, "High threshold",      color = na, display = display.none, editable = false)
pLo   = plot(loThresh, "Low threshold",       color = na, display = display.none, editable = false)
pVLo  = plot(vlLvl,    "Very low threshold",  color = na, display = display.none, editable = false)
p0    = plot(0,        "Zone bottom",         color = na, display = display.none, editable = false)

fill(pHi, pVHi, vhLvl, hiThresh,
     showZones ? color.new(cHigh, zt(85)) : na, showZones ? color.new(cHigh, 100) : na, "High zone", editable = false)
fill(pVHi, p100, 100, vhLvl,
     showZones ? color.new(cHighDeep, zt(50)) : na, showZones ? color.new(cHigh, zt(85)) : na, "Very high zone", editable = false)
fill(pVLo, pLo, loThresh, vlLvl,
     showZones ? color.new(cLow, 100) : na, showZones ? color.new(cLow, zt(85)) : na, "Low zone", editable = false)
fill(p0, pVLo, vlLvl, 0,
     showZones ? color.new(cLow, zt(85)) : na, showZones ? color.new(cLowDeep, zt(50)) : na, "Very low zone", editable = false)

// ============ Lines ============
// Colours and widths come from the Style inputs (they follow whichever line is main)
pSec  = plot(showSec ? secVal : na, "Secondary line", color = color.new(secCol, 30), linewidth = secW,  editable = false)
pMain = plot(mainVal, "Main line", color = mainCol, linewidth = mainW, editable = false)

// ============ Glow: while the main line is in a zone, the area between it and the threshold ============
// uses the SAME gradient as the zone behind it, just a touch stronger. The colour at any
// height matches the zone at that height, so the glow blends in rather than sitting on top.
inHigh  = showGlow and not na(mainVal) and mainVal > hiThresh
inVHigh = showGlow and not na(mainVal) and mainVal > vhLvl
inLow   = showGlow and not na(mainVal) and mainVal < loThresh
inVLow  = showGlow and not na(mainVal) and mainVal < vlLvl

pGHi  = plot(inHigh  ? math.min(mainVal, vhLvl) : na, "Glow high",      color = na, display = display.none, editable = false)
pGVHi = plot(inVHigh ? mainVal                  : na, "Glow very high", color = na, display = display.none, editable = false)
pGLo  = plot(inLow   ? math.max(mainVal, vlLvl) : na, "Glow low",       color = na, display = display.none, editable = false)
pGVLo = plot(inVLow  ? mainVal                  : na, "Glow very low",  color = na, display = display.none, editable = false)

fill(pHi, pGHi, vhLvl, hiThresh, color.new(cHigh, zt(72)), color.new(cHigh, zt(94)), "High glow", editable = false)
fill(pVHi, pGVHi, 100, vhLvl, color.new(cHighDeep, zt(38)), color.new(cHigh, zt(72)), "Very high glow", editable = false)
fill(pGLo, pLo, loThresh, vlLvl, color.new(cLow, zt(94)), color.new(cLow, zt(72)), "Low glow", editable = false)
fill(pGVLo, pVLo, vlLvl, 0, color.new(cLow, zt(72)), color.new(cLowDeep, zt(38)), "Very low glow", editable = false)

// ============ Readout ============
bgHead = color.new(#131722, 5)
bgRow  = color.new(#131722, 25)
tsz    = tblSize == "Tiny" ? size.tiny   : tblSize == "Normal" ? size.normal : size.small
tszBig = tblSize == "Tiny" ? size.small  : tblSize == "Normal" ? size.large  : size.normal

metricRow(table tb, int r, string lbl, float v, float pv, color c) =>
    float d = na(v) or na(pv) ? na : v - pv
    string arrow = na(d) ? "" : d >= 0.05 ? "▲ " : d <= -0.05 ? "▼ " : "• "
    color  dCol  = na(d) ? cGrey : d >= 0.05 ? cHigh : d <= -0.05 ? cLow : cGrey
    table.cell(tb, 0, r, lbl, text_color = cGrey, bgcolor = bgRow, text_size = tsz, text_halign = text.align_left)
    table.cell(tb, 1, r, na(v) ? "—" : str.tostring(v, "0.0"), text_color = c, bgcolor = bgRow, text_size = tsz, text_halign = text.align_right)
    if showChg
        table.cell(tb, 2, r, na(d) ? "" : arrow + str.tostring(math.abs(d), "0.0"), text_color = dCol, bgcolor = bgRow, text_size = tsz,
             text_halign = text.align_right, tooltip = "Change since the previous history bar's close (yesterday on 'D').")

pos = tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.top_right
var table t = table.new(pos, showChg ? 3 : 2, 4, border_width = 0, frame_width = 0)

if showTbl and barstate.islast
    table.cell(t, 0, 0, "XVI", text_color = cGrey, bgcolor = bgHead, text_size = tsz, text_halign = text.align_left)
    table.cell(t, 1, 0, na(xvi) ? "—" : str.tostring(xvi, "0.00"), text_color = color.white, bgcolor = bgHead, text_size = tszBig, text_halign = text.align_right)
    if showChg
        table.cell(t, 2, 0, " " + regime + " ", text_color = color.white, bgcolor = regCol, text_size = tsz)
    metricRow(t, 1, isPct ? "IV Pct"  : "IV Rank", mainVal, isPct ? prevPct  : prevRank, mainCol)
    metricRow(t, 2, isPct ? "IV Rank" : "IV Pct",  secVal,  isPct ? prevRank : prevPct,  secCol)
    if not showChg
        // Two-column layout: regime label gets its own row
        table.cell(t, 0, 3, "Regime", text_color = cGrey, bgcolor = bgRow, text_size = tsz, text_halign = text.align_left)
        table.cell(t, 1, 3, " " + regime + " ", text_color = color.white, bgcolor = regCol, text_size = tsz)

// ============ Alerts ============
regRank  = regime == "VERY HIGH" ? 2 : regime == "HIGH" ? 1 : regime == "LOW" ? -1 : regime == "VERY LOW" ? -2 : 0
regRank1 = regRank[1]
alertcondition(regRank != regRank1 and not na(mainVal), "Regime change",
     "XVI vol regime changed. Check the IV Rank / Percentile readout.")
alertcondition(regRank >= 1 and regRank1 < 1, "Entered HIGH vol", "XVI entered the HIGH vol zone.")
alertcondition(regRank == 2 and regRank1 < 2, "Entered VERY HIGH vol", "XVI entered the VERY HIGH vol zone.")
alertcondition(regRank <= -1 and regRank1 > -1, "Entered LOW vol", "XVI entered the LOW vol zone.")
alertcondition(regRank == -2 and regRank1 > -2, "Entered VERY LOW vol", "XVI entered the VERY LOW vol zone.")
````
