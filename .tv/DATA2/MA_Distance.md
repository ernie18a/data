<!-- tradingview-pine-id: PUB;d8442077e4aa40f68821179e16a243c9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MA Distance

Source: https://www.tradingview.com/script/7VgVqMkx-MA-Distance-Stretch-Mean-Reversion-Levels/

## Description

Shows how far price is from the 50 and 200 MA, and whether that distance is normal or overstretched relative to the ticker's own history.

Most "distance from MA" tools give you a raw percentage and leave you to guess whether +23% is a lot. This one measures the rolling mean and standard deviation of that distance over a lookback, converts the current reading into a z‑score, and tells you in plain words where you are.

What you see

📐 % distance from each MA (optional $ distance)
📊 μ / σ — historic mean and standard deviation of that distance over the lookback
🎯 z‑score — how many σ price is from its normal distance
🚦 Status — Normal / Extended / OVERSTRETCHED, with direction arrow and colour‑coded row
📍 ±σ bands — dotted price levels at MA × (1 + μ ± kσ): the actual prices where the stretch would hit your threshold. Use them as mean‑reversion targets or as the level price must hold to stay extended

Settings

Group	Setting	Default
Averages	Fast / Slow MA length	50 / 200
	MA type	SMA (or EMA)
	Use last closed bar	Off — excludes the live candle when on
Stretch	Stats lookback	250 bars
	Extended at	1.0σ
	Overstretched at	2.0σ
	Draw ±σ bands / band width	On / 2.0σ
Display	Show $ distance	Off
	Padding rows	1 — stacks the readout above other bottom‑left tables

Notes

Mean is rarely zero: a name in a long uptrend "normally" sits above its 200 MA, so the z‑score measures stretch against that baseline, not against the MA itself.
Lookback sets the regime. 250 bars on a daily chart ≈ one year; shorten it if you want the stats to reflect recent behaviour only.
Both rows show na until the chart has MA length + lookback bars of history.
All calculations run on every bar; the closed‑bar toggle only shifts what's displayed.

Works on any symbol and timeframe.

---

## Source Code

````pine
//@version=6
indicator("MA Distance", overlay=true)

// ── Inputs ──
g1 = "Averages"
fastLen   = input.int(50,  "Fast MA length", minval=1, group=g1)
slowLen   = input.int(200, "Slow MA length", minval=1, group=g1)
maType    = input.string("SMA", "MA type", options=["SMA", "EMA"], group=g1)
useClosed = input.bool(false, "Use last closed bar (exclude live candle)", group=g1)

g2 = "Stretch"
statLen   = input.int(250, "Stats lookback (bars)", minval=20, group=g2)
extZ      = input.float(1.0, "Extended at (σ)", step=0.25, group=g2)
strZ      = input.float(2.0, "Overstretched at (σ)", step=0.25, group=g2)
showBands = input.bool(true, "Draw ±σ bands", group=g2)
bandZ     = input.float(2.0, "Band width (σ)", step=0.25, group=g2)

g3 = "Display"
showPx    = input.bool(false, "Also show $ distance", group=g3)
padRows   = input.int(1, "Padding rows (to sit above ATR box)", minval=0, maxval=5, group=g3)

// ── MAs (always evaluated) ──
fastMA = maType == "SMA" ? ta.sma(close, fastLen) : ta.ema(close, fastLen)
slowMA = maType == "SMA" ? ta.sma(close, slowLen) : ta.ema(close, slowLen)

plot(fastMA, "Fast MA", color=color.new(color.gray, 40))
plot(slowMA, "Slow MA", color=color.new(color.gray, 40))

// ── Distance series (always evaluated) ──
fPctRaw = (close - fastMA) / fastMA * 100
sPctRaw = (close - slowMA) / slowMA * 100

fMean = ta.sma(fPctRaw, statLen),  fSd = ta.stdev(fPctRaw, statLen)
sMean = ta.sma(sPctRaw, statLen),  sSd = ta.stdev(sPctRaw, statLen)

// ── Bands: price levels where distance = mean ± bandZ·σ ──
fUp = fastMA * (1 + (fMean + bandZ * fSd) / 100)
fDn = fastMA * (1 + (fMean - bandZ * fSd) / 100)
sUp = slowMA * (1 + (sMean + bandZ * sSd) / 100)
sDn = slowMA * (1 + (sMean - bandZ * sSd) / 100)

plot(showBands ? fUp : na, "Fast +σ", color=color.new(color.orange, 60), style=plot.style_circles, linewidth=1)
plot(showBands ? fDn : na, "Fast −σ", color=color.new(color.orange, 60), style=plot.style_circles, linewidth=1)
plot(showBands ? sUp : na, "Slow +σ", color=color.new(color.blue,   60), style=plot.style_circles, linewidth=1)
plot(showBands ? sDn : na, "Slow −σ", color=color.new(color.blue,   60), style=plot.style_circles, linewidth=1)

// ── Readout values ──
o = useClosed ? 1 : 0
px   = close[o]
fPct = fPctRaw[o],  sPct = sPctRaw[o]
fZ   = (fPct - fMean[o]) / fSd[o]
sZ   = (sPct - sMean[o]) / sSd[o]

fmtPct(v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.#") + "%"
fmtPx(v)  => (v >= 0 ? "+" : "") + str.tostring(v, format.mintick)
status(z) => math.abs(z) >= strZ ? (z > 0 ? "OVERSTRETCHED ▲" : "OVERSTRETCHED ▼") :
             math.abs(z) >= extZ ? (z > 0 ? "Extended ▲" : "Extended ▼") : "Normal"
bg(z)     => math.abs(z) >= strZ ? color.new(#8b1e1e, 0) : math.abs(z) >= extZ ? color.new(#7a5a1e, 0) : color.new(#4a4d5c, 0)

// ── Table ──
var tbl = table.new(position.bottom_left, 1, 2 + 5, frame_width=0)

if barstate.islast
    fTxt = str.tostring(fastLen) + " MA: " + fmtPct(fPct) + (showPx ? " (" + fmtPx(px - fastMA[o]) + ")" : "") +
           "  |  μ " + fmtPct(fMean[o]) + "  σ " + str.tostring(fSd[o], "#.#") + "  |  z " + str.tostring(fZ, "#.##") + "  " + status(fZ)
    sTxt = str.tostring(slowLen) + " MA: " + fmtPct(sPct) + (showPx ? " (" + fmtPx(px - slowMA[o]) + ")" : "") +
           "  |  μ " + fmtPct(sMean[o]) + "  σ " + str.tostring(sSd[o], "#.#") + "  |  z " + str.tostring(sZ, "#.##") + "  " + status(sZ)
    table.cell(tbl, 0, 0, fTxt, text_color=color.white, bgcolor=bg(fZ), text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 0, 1, sTxt, text_color=color.white, bgcolor=bg(sZ), text_size=size.normal, text_halign=text.align_left)
    for i = 0 to 4
        table.cell(tbl, 0, 2 + i, i < padRows ? " " : "", bgcolor=color.new(color.white, 100), text_size=size.normal)
````
