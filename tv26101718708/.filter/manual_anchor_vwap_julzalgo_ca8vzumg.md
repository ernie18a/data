# Manual Anchor VWAP | julzALGO

- url: https://www.tradingview.com/script/cA8vZUmg-Manual-Anchor-VWAP-julzALGO/
- type: indicator
- pine_id: PUB;168948f80d964826a4fd8851e715d721
- version: 1.0

## Description

📘 Summary
Manual Anchor VWAP  is a fully manual anchored VWAP system designed around a draggable institutional anchor point.
Instead of relying on automatic session resets, the user manually selects where the VWAP calculation begins using the ⚓ DRAG MODE anchor.

This allows traders to anchor VWAP directly to important market events such as:
• Breakouts
• Liquidity sweeps
• Displacement candles
• BOS
• CHoCH
• News spikes
• Major swing highs/lows
The script also includes configurable standard deviation bands to visualize volatility expansion and premium/discount positioning around the anchored VWAP.

📘 Features
✅ Fully manual anchored VWAP
✅ Interactive ⚓ DRAG MODE anchor
✅ Vertical anchor reference line
✅ ±1σ standard deviation bands
✅ ±2σ standard deviation bands
✅ ±3σ standard deviation bands
✅ Institutional-style anchored workflow
✅ Lightweight and clean overlay design
✅ Real-time VWAP recalculation from anchor point
✅ Customizable VWAP, anchor, line, and band colors

📘 Logic
The script calculates VWAP manually from the selected anchor point using cumulative price-volume calculations.
Core calculation:
VWAP = Σ(price × volume) / Σ(volume)
The VWAP begins accumulating only after the manually selected anchor time.
The anchor is controlled through:
⚓ DRAG MODE
https://www.tradingview.com/x/FA3htAYX/
This allows traders to reposition the starting point dynamically depending on the market structure or event they want to analyze.
Standard deviation bands are calculated using volume-weighted variance from the anchored VWAP mean.
This creates institutional-style premium and discount zones around the anchor.

📘 Usage

🔷 Best Anchor Locations
⚓ Liquidity sweeps
⚓ BOS candles
⚓ CHoCH candles
⚓ Strong displacement candles
⚓ News events
⚓ Session opens
⚓ Swing highs and swing lows
⚓ Breakout or breakdown candles

🔷 Institutional Interpretation
The anchored VWAP acts as a dynamic institutional average price from the selected event.
Price above VWAP:
→ Buyers are holding control above institutional average price.
Price below VWAP:
→ Sellers are holding control below institutional average price.
Standard deviation bands help identify:
• Premium zones
• Discount zones
• Exhaustion areas
• Mean reversion areas
• Expansion and volatility extremes

🔷 Example Workflow
⚓ Anchor VWAP at a bullish displacement candle
⬆ Price pulls back into VWAP
🟢 Buyers defend anchored average price
📈 Continuation toward upper deviation bands
Or:
⚓ Anchor VWAP at a liquidity sweep high
⬇ Price rejects below VWAP
🔴 Sellers defend premium area
📉 Continuation toward lower deviation bands

📘 Settings

⚓ Anchor
• Drag Anchor
• Price
• Show Anchor Line
📊 Bands
• Band 1
• Band 2
• Band 3
• Show Bands
🎨 Colors
• VWAP Color
• Anchor Label Color
• Vertical Drag Line Color
• Upper Band Color
• Lower Band Color

📘 Disclaimer
This script is for educational and informational purposes only.
Anchored VWAP analysis does not guarantee future market direction or profitability. Traders should always combine anchored VWAP with proper risk management, market structure analysis, and confirmation tools before making trading decisions.

## Source Code

````pine
// This source code is subject to MPL 2.0
// © julzALGO

//@version=6
indicator("Manual Anchor VWAP | julzALGO", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
anchorTimeInput = input.time(
     timestamp("2026-01-01T00:00:00"),
     "Drag Anchor",
     confirm=true,
     group="Anchor",
     inline="ANCHOR")

anchorPriceInput = input.price(
     100.0,
     "Price",
     confirm=true,
     group="Anchor",
     inline="ANCHOR")

showAnchorLine = input.bool(true, "Show Anchor Line", group="Anchor")
showBands      = input.bool(true, "Show Bands", group="Bands")

mult1 = input.float(1.0, "Band 1", minval=0.1, step=0.1, group="Bands")
mult2 = input.float(2.0, "Band 2", minval=0.1, step=0.1, group="Bands")
mult3 = input.float(3.0, "Band 3", minval=0.1, step=0.1, group="Bands")

vwapColor     = input.color(color.rgb(155, 52, 224), "VWAP Color", group="Colors")
anchorCol     = input.color(color.rgb(144, 158, 163), "Anchor Label Color", group="Colors")
dragLineColor = input.color(#3ea1db, "Vertical Drag Line Color", group="Colors")
bandUpCol     = input.color(color.new(#4caf4f, 31), "Upper Bands", group="Colors")
bandDnCol     = input.color(color.new(#ff5252, 30), "Lower Bands", group="Colors")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MANUAL DRAG ANCHOR ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
anchorActive = time >= anchorTimeInput
anchorStart  = anchorActive and not anchorActive[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ANCHORED VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
price = hl2

var float sumPV  = na
var float sumVol = na
var float sumDev = na

mean = sumVol > 0 ? sumPV / sumVol : price

if anchorStart
    sumPV  := price * volume
    sumVol := volume
    sumDev := 0.0
else if anchorActive
    sumPV  := nz(sumPV) + price * volume
    sumVol := nz(sumVol) + volume
    sumDev := nz(sumDev) + math.pow(price - mean, 2) * volume
else
    sumPV  := na
    sumVol := na
    sumDev := na

vwap   = sumVol > 0 ? sumPV / sumVol : na
stdDev = sumVol > 0 ? math.sqrt(sumDev / sumVol) : na

upper1 = vwap + stdDev * mult1
lower1 = vwap - stdDev * mult1
upper2 = vwap + stdDev * mult2
lower2 = vwap - stdDev * mult2
upper3 = vwap + stdDev * mult3
lower3 = vwap - stdDev * mult3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(vwap, "Anchored VWAP", color=vwapColor, linewidth=2)

plot(showBands ? upper1 : na, "+1σ", color=bandUpCol, style=plot.style_circles)
plot(showBands ? lower1 : na, "-1σ", color=bandDnCol, style=plot.style_circles)
plot(showBands ? upper2 : na, "+2σ", color=bandUpCol, style=plot.style_circles)
plot(showBands ? lower2 : na, "-2σ", color=bandDnCol, style=plot.style_circles)
plot(showBands ? upper3 : na, "+3σ", color=bandUpCol, style=plot.style_circles)
plot(showBands ? lower3 : na, "-3σ", color=bandDnCol, style=plot.style_circles)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMBINED MARINE ANCHOR LABEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label anchorIcon = na
var line anchorLine = na

anchorVisualTime  = anchorTimeInput
anchorVisualPrice = anchorPriceInput

if barstate.islast
    label.delete(anchorIcon)
    line.delete(anchorLine)

    anchorIcon := label.new(
         anchorVisualTime,
         anchorVisualPrice,
         "⚓ DRAG MODE",
         xloc=xloc.bar_time,
         style=label.style_label_center,
         color=anchorCol,
         textcolor=color.black,
         size=size.normal)

    if showAnchorLine
        anchorLine := line.new(
             anchorVisualTime,
             low,
             anchorVisualTime,
             high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=color.new(dragLineColor, 0),
             style=line.style_solid,
             width=1)
````
