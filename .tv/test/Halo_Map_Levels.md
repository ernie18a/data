<!-- tradingview-pine-id: PUB;66ff6145935f4314953430beb04ea763 -->
<!-- tradingviewscripts-format: 1 -->
# Halo Map Levels

Source: https://www.tradingview.com/script/xJIBi0cL-Halo-SOL-ETH-4H-Scenario-Map/

## Description

An open-source visual scenario map for the SOLUSDT and ETHUSDT 4-hour charts. It plots two transparent decision zones and the key upside, invalidation and downside levels used in the accompanying Halo market analysis.

SOL map: 71.9–72.6 decision zone, 73.6–74.3 reclaim zone, 75.4 upside and 70.5 downside after a 4H close below 71.9.

ETH map: 1,820–1,840 demand zone, 1,879–1,900 reclaim zone, 1,940 upside and 1,800 downside after a 4H close below 1,820.

The colors are intentionally simple: green for demand/decision, orange for reclaim, red for upside decision and blue for invalidation/downside. The script is a visual analysis aid only. It does not generate entries, execute trades or predict outcomes. Maps, not predictions.

---

## Source Code

````pine
//@version=6
indicator("Halo Map Levels", overlay=true, max_labels_count=20)

isSOL = str.contains(syminfo.ticker, "SOL")
isETH = str.contains(syminfo.ticker, "ETH")

demandLow  = isSOL ? 71.9 : isETH ? 1820.0 : na
demandHigh = isSOL ? 72.6 : isETH ? 1840.0 : na
reclaimLow  = isSOL ? 73.6 : isETH ? 1879.0 : na
reclaimHigh = isSOL ? 74.3 : isETH ? 1900.0 : na
upside      = isSOL ? 75.4 : isETH ? 1940.0 : na
downside    = isSOL ? 70.5 : isETH ? 1800.0 : na

pDemandLow  = plot(demandLow, "Demand low", color=color.new(color.green, 20), linewidth=1, style=plot.style_linebr)
pDemandHigh = plot(demandHigh, "Demand high", color=color.new(color.green, 20), linewidth=1, style=plot.style_linebr)
fill(pDemandLow, pDemandHigh, color=color.new(color.green, 88), title="Demand zone")

pReclaimLow  = plot(reclaimLow, "Reclaim low", color=color.new(color.orange, 15), linewidth=1, style=plot.style_linebr)
pReclaimHigh = plot(reclaimHigh, "Reclaim high", color=color.new(color.orange, 15), linewidth=1, style=plot.style_linebr)
fill(pReclaimLow, pReclaimHigh, color=color.new(color.orange, 89), title="Reclaim zone")

plot(upside, "Upside", color=color.new(color.red, 10), linewidth=1, style=plot.style_linebr)
plot(downside, "Downside", color=color.new(color.blue, 5), linewidth=1, style=plot.style_linebr)

var label demandLabel = na
var label reclaimLabel = na
var label upsideLabel = na
var label invalidLabel = na
var label downsideLabel = na

if barstate.islast and (isSOL or isETH)
    label.delete(demandLabel)
    label.delete(reclaimLabel)
    label.delete(upsideLabel)
    label.delete(invalidLabel)
    label.delete(downsideLabel)
    demandText = isSOL ? "DECISION 71.9–72.6" : "DEMAND 1,820–1,840"
    reclaimText = isSOL ? "RECLAIM 73.6–74.3" : "RECLAIM 1,879–1,900"
    upsideText = isSOL ? "UPSIDE 75.4" : "UPSIDE 1,940"
    invalidText = isSOL ? "4H CLOSE <71.9 INVALIDATES" : "4H CLOSE <1,820 INVALIDATES"
    downsideText = isSOL ? "DOWNSIDE 70.5" : "DOWNSIDE 1,800"
    demandLabel := label.new(bar_index + 1, demandHigh, demandText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.green, 5), textcolor=color.white, size=size.small)
    reclaimLabel := label.new(bar_index + 1, reclaimHigh, reclaimText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
    upsideLabel := label.new(bar_index + 1, upside, upsideText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.red, 5), textcolor=color.white, size=size.small)
    invalidLabel := label.new(bar_index + 1, demandLow, invalidText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.blue, 10), textcolor=color.white, size=size.small)
    downsideLabel := label.new(bar_index + 1, downside, downsideText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.blue, 5), textcolor=color.white, size=size.small)

// © halo_trader
````
