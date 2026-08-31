<!-- tradingview-pine-id: PUB;b5041937c5714f82a19728a32fc68009 -->
<!-- tradingviewscripts-format: 1 -->
# Kloom VWAP Bands

Source: https://www.tradingview.com/script/X8PbMqYA-Kloom-VWAP-Bands-Anchored-VWAP-with-St-Dev-Bands/

## Description

Session/week/month-anchored VWAP with two standard-deviation bands and a live deviation readout.

How it works
• VWAP accumulates price x volume from the chosen anchor (session, week or month).
• Bands at +/-1 and +/-2 standard deviations are computed from the true volume-weighted variance - not from a moving-average approximation, which understates the spread on volume spikes.
• A table shows the current deviation in sigma: beyond +2 or -2 price is statistically stretched relative to the anchor's own volume profile.

How to use it
Mean reversion: fade moves beyond the outer band back toward VWAP in ranging markets. Trend confirmation: price holding above VWAP with the upper band rising is a strong session. Anchor and band multipliers are configurable.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KloomStudio

//@version=6
indicator("Kloom VWAP Bands", shorttitle="K.VWAP", overlay=true)

// ── Inputs ─────────────────────────────────────────────────────────────────────
grp     = "VWAP"
anchor  = input.string("Session", "Anchor period", options=["Session", "Week", "Month"], group=grp)
src     = input.source(hlc3, "Source", group=grp)
showB1  = input.bool(true,  "Show band 1", group=grp)
mult1   = input.float(1.0, "Band 1 multiplier (st.dev)", minval=0.1, maxval=5, step=0.25, group=grp)
showB2  = input.bool(true,  "Show band 2", group=grp)
mult2   = input.float(2.0, "Band 2 multiplier (st.dev)", minval=0.1, maxval=5, step=0.25, group=grp)

// ── Anchor change detection ────────────────────────────────────────────────────
newSession = timeframe.change("D")
newWeek    = timeframe.change("W")
newMonth   = timeframe.change("M")
newPeriod  = anchor == "Session" ? newSession : anchor == "Week" ? newWeek : newMonth

// ── VWAP + stdev accumulation ──────────────────────────────────────────────────
var float sumPV  = 0.0
var float sumV   = 0.0
var float sumPV2 = 0.0
if newPeriod
    sumPV  := 0.0
    sumV   := 0.0
    sumPV2 := 0.0
vol = nz(volume, 0)
sumPV  += src * vol
sumV   += vol
sumPV2 += src * src * vol

vwap    = sumV > 0 ? sumPV / sumV : na
variance = sumV > 0 ? math.max(sumPV2 / sumV - vwap * vwap, 0.0) : na
stdev   = math.sqrt(variance)

up1 = vwap + stdev * mult1
dn1 = vwap - stdev * mult1
up2 = vwap + stdev * mult2
dn2 = vwap - stdev * mult2

// ── Plots ──────────────────────────────────────────────────────────────────────
plot(vwap, "VWAP", color=color.new(color.aqua, 0), linewidth=2)
pU1 = plot(showB1 ? up1 : na, "Upper 1", color=color.new(color.teal, 55))
pD1 = plot(showB1 ? dn1 : na, "Lower 1", color=color.new(color.teal, 55))
pU2 = plot(showB2 ? up2 : na, "Upper 2", color=color.new(color.orange, 60))
pD2 = plot(showB2 ? dn2 : na, "Lower 2", color=color.new(color.orange, 60))
fill(pU1, pD1, color=color.new(color.teal, 96), title="Band 1 fill")
fill(pU2, pD2, color=color.new(color.orange, 97), title="Band 2 fill")

// ── Position vs VWAP table ─────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 2, border_width=1)
if barstate.islast
    dev     = stdev > 0 ? (close - vwap) / stdev : na
    devTxt  = str.tostring(dev, "#.##") + " σ"
    devCol  = math.abs(dev) > mult2 ? color.new(color.orange, 30) : color.new(color.black, 40)
    table.cell(t, 0, 0, "VWAP", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(t, 1, 0, str.tostring(vwap, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(t, 0, 1, "Deviation", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(t, 1, 1, devTxt, text_color=color.white, bgcolor=devCol, text_size=size.small)
````
