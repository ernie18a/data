# RichmondHillCM - VWAP & Volume-Spike Suite V1.3

- url: https://www.tradingview.com/script/RlBK6JmM-RichmondHillCM-VWAP-Volume-Spike-Suite-V1-3/
- type: indicator
- pine_id: PUB;754221b33c9846149461e1577cd470fc
- version: 1.0

## Description

[b]RichmondHillCM — VWAP & Volume-Spike Suite[/b]

A clean, focused overlay that combines an anchored monthly VWAP with above-average volume detection to flag high-conviction bars in real time. Built for the weekly chart but works on any timeframe.

[b]What it does[/b]
The indicator watches for volume spikes — bars where volume rises above its own moving average by a set threshold — and marks each one with a directional triangle:

[b]Green up-triangle (below the bar) [/b]— a volume spike closing on the bullish side (buyers in control)
[b]Red down-triangle (above the bar) [/b]— a volume spike closing on the bearish side (sellers in control)

"Bullish" and "bearish" are, by default, defined relative to the monthly VWAP: a spike closing above VWAP prints an up-triangle; below VWAP prints a down-triangle. This ties conviction (volume) to fair value (VWAP) in a single, easy-to-read signal.

[b]The VWAP structure[/b]
An anchored VWAP resets at the start of each month and acts as the volume-weighted "fair value" pivot. Standard-deviation bands bracket the typical range around it:

Lower bands (−1σ / −2σ / −3σ) — progressively cheap vs fair value; classic long / entry zones
Upper bands (+1σ / +2σ / +3σ) — progressively rich vs fair value; scale-out / short zones
VWAP itself — the mean pivot: reclaim = bullish, lose = bearish

A live summary table lists all seven VWAP levels (±1σ, ±2σ, ±3σ and the mean), the current VWAP zone, the latest volume-vs-average ratio, the live spike state, and a running count of bullish vs bearish spikes. On a weekly chart each month spans roughly 4–5 bars, giving the VWAP and its bands enough data to be meaningful.

[b]Settings
[/b]
Volume MA length and spike threshold (× average)
Direction definition: VWAP-relative (default), Candle (close vs open), or Close-to-Close
Band width (σ multiplier) for the plotted band, plus toggles for bands, shading, and on-chart labels
Optional "confirm on bar close" to avoid intrabar repaint on the live bar
Summary table with a Top / Bottom position toggle
Built-in alerts for bullish/bearish spikes and VWAP reclaim/loss

[b]
How to use it[/b]
Watch for a lower-band tag paired with a bullish spike triangle as a potential long, and an upper-band tag paired with a bearish spike triangle as a scale-out or short. Use the VWAP itself as your mean pivot — trading above it favors longs, below it favors shorts.

[i]For educational and informational purposes only; not financial advice. Always do your own research and manage risk.[/i]

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  RichmondHillCM — VWAP + VOLUME-SPIKE SUITE
//  ► Anchored Monthly VWAP with ±1σ entry bands
//  ► Volume-spike detection (volume above its moving average)
//  ► UP triangle (bullish) / DOWN triangle (bearish) on each qualifying spike
//  ► Weekly-optimized defaults
//
//  SIGNAL LOGIC (simple, robust, always visible)
//  • A "volume spike" = current volume  >  (average volume × threshold).
//  • Direction decides the triangle:
//        - UP  triangle (green, below bar) : spike + bullish direction
//        - DOWN triangle (red,  above bar) : spike + bearish direction
//  • Default direction is VWAP-relative:
//        close ABOVE VWAP = bullish   |   close BELOW VWAP = bearish
//    (switchable to Candle or Close-to-Close in the Volume settings).
//
//  HOW TO TRADE THE VWAP BANDS
//  • VWAP = volume-weighted fair value, reset at the start of each month.
//        - LOWER band  : cheap vs fair value  → long/entry zone
//        - UPPER band  : rich  vs fair value  → scale-out / short zone
//        - VWAP itself : mean pivot — reclaim = bullish, lose = bearish
//  • Weekly chart works well: each month ≈ 4-5 weekly bars of VWAP data.
// ════════════════════════════════════════════════════════════════════════════

// ── DECLARATION ─────────────────────────────────────────────────────────────
indicator("RichmondHillCM - VWAP & Volume-Spike Suite V1.3", overlay=true,
     max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════
//  INPUTS — MONTHLY VWAP + ±σ BANDS
// ════════════════════════════════════════════════════════════════════════════
grpVwap     = "Monthly VWAP + Bands"
showVwap    = input.bool(true,  "Show Monthly VWAP",  group=grpVwap)
showBands   = input.bool(true,  "Show ±σ Bands",      group=grpVwap)
vwapMult    = input.float(1.0,  "Band Width (σ multiplier)", minval=0.1, step=0.1, group=grpVwap) // 1.0 = ±1σ
vwapSrc     = input.source(hlc3,"VWAP Source",        group=grpVwap) // hlc3 = standard VWAP price
fillBands   = input.bool(true,  "Shade Band Zone",    group=grpVwap)
showVwapLbl = input.bool(true,  "Label VWAP / Bands on Chart", group=grpVwap)

// ════════════════════════════════════════════════════════════════════════════
//  INPUTS — VOLUME SPIKE (above-average volume) + DIRECTION
// ════════════════════════════════════════════════════════════════════════════
grpVol          = "Volume Spike"
showTriangles   = input.bool(true, "Show Up/Down Volume-Spike Triangles", group=grpVol)
volumeMaLength  = input.int(28,  "Volume MA Length",             minval=1,   group=grpVol)
volumeThreshold = input.float(1.7,"Spike Threshold (× avg vol)", minval=1.0, step=0.1, group=grpVol)
dirMode         = input.string("VWAP", "Direction Definition",
     options=["VWAP", "Candle", "Close-Close"], group=grpVol,
     tooltip="VWAP: close vs monthly VWAP.  Candle: close vs open.  Close-Close: close vs prior close.")
showSpikeText   = input.bool(true, "Label Triangles (VOL▲ / VOL▼)", group=grpVol)
confirmOnClose  = input.bool(false,"Confirm on Bar Close (no intrabar repaint)", group=grpVol)

// ════════════════════════════════════════════════════════════════════════════
//  INPUTS — SUMMARY TABLE
// ════════════════════════════════════════════════════════════════════════════
grpTbl    = "Summary Table"
showTable = input.bool(true, "Show Summary Table", group=grpTbl)
tblVert   = input.string("Top", "Table Position (Top / Bottom)",
     options=["Top","Bottom"], group=grpTbl)   // right-aligned; default = Top Right

tablePosition(v) =>
    v == "Bottom" ? position.bottom_right : position.top_right

// ════════════════════════════════════════════════════════════════════════════
//  CALCULATIONS — VOLUME SPIKE
// ────────────────────────────────────────────────────────────────────────────
//  A spike = current volume above (average volume × threshold). The hasVol
//  guard keeps the signal quiet on symbols that report no / zero volume.
// ════════════════════════════════════════════════════════════════════════════
volumeMa    = ta.sma(volume, volumeMaLength)
hasVol      = not na(volume) and volume > 0
volumeSpike = hasVol and not na(volumeMa) and volume > volumeMa * volumeThreshold
volRatio    = (not na(volumeMa) and volumeMa != 0) ? volume / volumeMa : na

// ════════════════════════════════════════════════════════════════════════════
//  CALCULATIONS — ANCHORED MONTHLY VWAP + ±σ BANDS
// ────────────────────────────────────────────────────────────────────────────
//  ta.vwap with a stdev multiplier returns [vwap, upperBand, lowerBand],
//  all reset on the monthly anchor.
// ════════════════════════════════════════════════════════════════════════════
monthAnchor = timeframe.change("M")   // true at the start of each new month
// Call ta.vwap at 1σ to obtain the VWAP and one standard-deviation unit, then
// derive the ±1σ / ±2σ / ±3σ levels (and the user-set plotted band) from it.
[vwap, vwapUp1, vwapLo1] = ta.vwap(vwapSrc, monthAnchor, 1.0)
sigma   = (na(vwap) or na(vwapUp1)) ? na : vwapUp1 - vwap   // one standard deviation

vwapUp2 = na(sigma) ? na : vwap + 2 * sigma
vwapUp3 = na(sigma) ? na : vwap + 3 * sigma
vwapLo2 = na(sigma) ? na : vwap - 2 * sigma
vwapLo3 = na(sigma) ? na : vwap - 3 * sigma

// User-configurable plotted band (Band Width σ multiplier)
vwapUpper = na(sigma) ? na : vwap + vwapMult * sigma
vwapLower = na(sigma) ? na : vwap - vwapMult * sigma

// ════════════════════════════════════════════════════════════════════════════
//  SIGNALS — VOLUME-SPIKE UP / DOWN TRIANGLES
// ════════════════════════════════════════════════════════════════════════════
aboveVwap = not na(vwap) and close > vwap
belowVwap = not na(vwap) and close < vwap

dirUp = dirMode == "VWAP"   ? aboveVwap :
         dirMode == "Candle" ? close > open :
         close > close[1]                                   // Close-Close
dirDn = dirMode == "VWAP"   ? belowVwap :
         dirMode == "Candle" ? close < open :
         close < close[1]                                   // Close-Close

// Raw spike signals
spikeUpRaw = volumeSpike and dirUp
spikeDnRaw = volumeSpike and dirDn

// Optionally require the bar to be closed (avoids intrabar repaint on live bar)
barOk   = not confirmOnClose or barstate.isconfirmed
spikeUp = spikeUpRaw and barOk
spikeDn = spikeDnRaw and barOk

// ════════════════════════════════════════════════════════════════════════════
//  STATISTICS — running counts & current state
// ════════════════════════════════════════════════════════════════════════════
var int cntUp = 0
var int cntDn = 0
cntUp := cntUp + (spikeUp ? 1 : 0)
cntDn := cntDn + (spikeDn ? 1 : 0)

vwapZone = na(vwap) ? "—" :
     close > vwapUpper ? "Above Upper" :
     close < vwapLower ? "Below Lower" :
     close > vwap      ? "Upper Half"  : "Lower Half"

// ════════════════════════════════════════════════════════════════════════════
//  PLOTTING — VWAP + BANDS
// ════════════════════════════════════════════════════════════════════════════
pVwap  = plot(showVwap  ? vwap      : na, color=color.new(color.teal, 0),
     title="Monthly VWAP", linewidth=2, style=plot.style_stepline)
pUpper = plot(showBands ? vwapUpper : na, color=color.new(color.teal, 40),
     title="VWAP Upper σ", linewidth=1, style=plot.style_stepline)
pLower = plot(showBands ? vwapLower : na, color=color.new(color.teal, 40),
     title="VWAP Lower σ", linewidth=1, style=plot.style_stepline)
fill(pUpper, pLower, color=fillBands and showBands ? color.new(color.teal, 92) : na, title="VWAP Band Zone")

// ── Curve name labels at the right edge (last bar only) ──────────────────────
drawCurveLabel(float yval, string txt, color col, bool show) =>
    if show and barstate.islast and not na(yval)
        label.new(bar_index + 3, yval, txt,
             style=label.style_label_left, color=color.new(col, 0),
             textcolor=color.white, size=size.small)

drawCurveLabel(vwap,      "Monthly VWAP",  color.teal, showVwapLbl and showVwap)
drawCurveLabel(vwapUpper, "VWAP +σ",       color.teal, showVwapLbl and showBands)
drawCurveLabel(vwapLower, "VWAP −σ (buy)", color.teal, showVwapLbl and showBands)

// ════════════════════════════════════════════════════════════════════════════
//  PLOTTING — VOLUME-SPIKE TRIANGLES
// ────────────────────────────────────────────────────────────────────────────
//  plotshape's text= must be a CONST string, so it can't be toggled by an
//  input. The triangles are drawn textless here; the optional VOL▲ / VOL▼
//  labels are added separately via label.new (which accepts a series string).
// ════════════════════════════════════════════════════════════════════════════
plotshape(showTriangles and spikeUp, title="Bullish Volume Spike",
     location=location.belowbar, color=color.new(color.lime, 0),
     style=shape.triangleup, size=size.small)

plotshape(showTriangles and spikeDn, title="Bearish Volume Spike",
     location=location.abovebar, color=color.new(color.red, 0),
     style=shape.triangledown, size=size.small)

// Optional text labels for the spike triangles (toggleable)
if showTriangles and showSpikeText and spikeUp
    label.new(bar_index, low, "VOL▲", yloc=yloc.belowbar,
         style=label.style_label_up, color=color.new(color.lime, 0),
         textcolor=color.white, size=size.tiny)

if showTriangles and showSpikeText and spikeDn
    label.new(bar_index, high, "VOL▼", yloc=yloc.abovebar,
         style=label.style_label_down, color=color.new(color.red, 0),
         textcolor=color.white, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
//  SUMMARY TABLE
// ════════════════════════════════════════════════════════════════════════════
f(float x) => str.tostring(x, format.mintick)
var table stats = table.new(position.top_right, 2, 13,
     bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 60), border_width=1)

if showTable and barstate.islast
    table.set_position(stats, tablePosition(tblVert))

    cHdr = color.new(color.blue, 0)
    cLbl = color.new(color.gray, 80)
    grn  = color.new(color.green, 0)
    red  = color.new(color.red, 0)

    table.cell(stats, 0, 0, "VWAP + VOL SPIKE", text_color=color.white, bgcolor=cHdr, text_size=size.small)
    table.cell(stats, 1, 0, timeframe.period,   text_color=color.white, bgcolor=cHdr, text_size=size.small)

    // Upper standard-deviation bands (rich vs fair value)
    table.cell(stats, 0, 1, "VWAP +3σ", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 1, na(vwapUp3) ? "—" : f(vwapUp3), text_color=red, text_size=size.small)

    table.cell(stats, 0, 2, "VWAP +2σ", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 2, na(vwapUp2) ? "—" : f(vwapUp2), text_color=red, text_size=size.small)

    table.cell(stats, 0, 3, "VWAP +1σ", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 3, na(vwapUp1) ? "—" : f(vwapUp1), text_color=red, text_size=size.small)

    // Mean
    table.cell(stats, 0, 4, "Monthly VWAP", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 4, na(vwap) ? "—" : f(vwap), text_color=color.aqua, text_size=size.small)

    // Lower standard-deviation bands (cheap vs fair value → buy zones)
    table.cell(stats, 0, 5, "VWAP −1σ", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 5, na(vwapLo1) ? "—" : f(vwapLo1), text_color=grn, text_size=size.small)

    table.cell(stats, 0, 6, "VWAP −2σ", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 6, na(vwapLo2) ? "—" : f(vwapLo2), text_color=grn, text_size=size.small)

    table.cell(stats, 0, 7, "VWAP −3σ (buy)", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 7, na(vwapLo3) ? "—" : f(vwapLo3), text_color=grn, text_size=size.small)

    table.cell(stats, 0, 8, "VWAP Zone", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 8, vwapZone,
         text_color=vwapZone == "Below Lower" ? grn : vwapZone == "Above Upper" ? red : color.white,
         text_size=size.small)

    table.cell(stats, 0, 9, "Vol vs Avg", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 9, na(volRatio) ? "—" : str.tostring(volRatio, "#.##") + "x",
         text_color=volumeSpike ? color.orange : color.white, text_size=size.small)

    table.cell(stats, 0, 10, "Spike Now", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 10, spikeUp ? "BULLISH ▲" : spikeDn ? "BEARISH ▼" : volumeSpike ? "SPIKE" : "None",
         text_color=spikeUp ? grn : spikeDn ? red : volumeSpike ? color.orange : color.gray, text_size=size.small)

    table.cell(stats, 0, 11, "Up ▲ / Down ▼", text_color=color.white, bgcolor=cLbl, text_size=size.small)
    table.cell(stats, 1, 11, str.tostring(cntUp) + " / " + str.tostring(cntDn),
         text_color=color.white, text_size=size.small)

    table.cell(stats, 0, 12, "richmondhillcm.com", text_color=color.gray, bgcolor=cLbl, text_size=size.tiny)
    table.cell(stats, 1, 12, "RichmondHillCM",     text_color=color.gray, text_size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════
alertcondition(spikeUp, title="Bullish Volume Spike (Up Triangle)",
     message="Bullish volume spike: above-average volume with bullish direction.")
alertcondition(spikeDn, title="Bearish Volume Spike (Down Triangle)",
     message="Bearish volume spike: above-average volume with bearish direction.")
alertcondition(ta.crossover(close, vwap),  title="Reclaimed Monthly VWAP",
     message="Bullish: price crossed ABOVE the monthly VWAP (mean reclaim).")
alertcondition(ta.crossunder(close, vwap), title="Lost Monthly VWAP",
     message="Bearish: price crossed BELOW the monthly VWAP (mean loss).")

//  ───────────────────────
````
