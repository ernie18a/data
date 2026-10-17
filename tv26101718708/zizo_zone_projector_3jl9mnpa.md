# ZIZO Zone Projector

- url: https://www.tradingview.com/script/3jL9mnPA-ZIZO-Zone-Projector/
- type: indicator
- pine_id: PUB;724ee7feeed245a1be3e6f6b99edd114
- version: 1.0

## Description

ZIZO ZONE PROJECTOR

A manual, anchored deviation-zone tool. You give it one reference point — the
price at which the market crossed its 200-day moving average — and it projects
a ladder of fixed percentage-offset zones forward from that point, so you can
see where structurally significant levels sit before price gets there.

Open-source on purpose. Read the code, verify the maths, fork it, improve it.

WHAT IT DOES
Markets spend most of their time at some measurable deviation from a long-run
mean. This tool takes a single anchor (a 200 SMA cross price) and plots five
horizontal zones above it (in an uptrend) or five below it (in a downtrend),
each at a fixed percentage offset from the anchor. The lines are static: once
drawn from the anchor date they hold their level and extend a fixed number of
days forward (default 365). The result is a fixed forward map, not a moving
band that repaints.

The default offsets are derived from a deviation-band model I fit per asset
across full market cycles — the spacing reflects how far each asset has
historically extended from its mean at cycle highs and lows. Presets are
included for BTC, ETH, XRP and SOL, plus an Average preset computed live across
all four. Every offset is fully editable, so you can recalibrate as a cycle
matures and the bands compress. Use my numbers as a starting point, or replace
them entirely with your own.

THE ZONES
Upside (distribution side):
  Conservative Anchor -> Moderate Progression -> Logical Maximum ->
  Strategic Extension -> Aspirational Horizon
Each higher zone marks a progressively more extended deviation from the anchor.

Downside (accumulation side):
  Cautious Accumulation -> Measured Scaling -> Capitulation Opportunity ->
  Full Conviction -> Final Capitulation
Each lower zone marks a progressively deeper discount from the anchor.

HOW TO USE IT
1. Set Direction to Bull (price/SMA above the cross) or Bear (below). Only the
   active side draws — one anchor is in play at a time.
2. Set Anchor price to the price at which the relevant 200 SMA cross occurred.
3. Set Start date to the cross date and Duration (default 365 days).
4. Read the zones as a structured map of where deviation-based levels sit — not
   as buy or sell signals.

INPUTS
- Asset preset (BTC / ETH / XRP / SOL / Average) — switches the full offset set.
- Bull / Bear direction toggle.
- Fully editable upside and downside offsets (5 decimals held internally,
  display rounding configurable).
- Per-zone visibility toggles — show only the zones you want.
- Colour gradient, line style, label decimals, projection duration.

NOTES AND LIMITATIONS
This is a visualisation tool, not a forecast. It draws where deviation levels
would sit for the anchor and offsets you supply. It does not predict that price
will reach them, and it generates no alerts or signals. You provide the anchor
and the offsets; the quality of the map depends entirely on those inputs.
Deviation behaviour.

## Source Code

````pine
//@version=6
indicator("ZIZO Zone Projector", "ZIZO Zones", overlay=true, max_lines_count=500, max_labels_count=500)

// ════════════════ ASSET & ANCHOR ════════════════
asset      = input.string("BTC", "Asset preset", options=["BTC","ETH","XRP","SOL","Average (all 4)"], group="▸ Asset & Anchor")
dirStr     = input.string("Bull", "Direction  (only one side draws)", options=["Bull","Bear"], tooltip="Bull: price/SMA above the cross — upside ladder. Bear: price/SMA below — downside ladder. One anchor in play at a time.", group="▸ Asset & Anchor")
crossPrice = input.float(88382.41, "Anchor price (active cross)", minval=0.0, step=0.00001, tooltip="The 200 SMA cross price for the ACTIVE direction. Bull = up-cross price; Bear = down-cross price. Must be > 0.", group="▸ Asset & Anchor")
startTime  = input.time(timestamp("01 Jan 2024 00:00 +0000"), "Start date", group="▸ Asset & Anchor")
durDays    = input.int(365, "Duration (days)", minval=1, group="▸ Asset & Anchor")

// ════════════════ BTC OFFSETS (%) ════════════════
bU1=input.float(91.16844, "U1 · Conservative Anchor",   step=0.00001, group="BTC · Upside Offsets %")
bU2=input.float(178.36347,"U2 · Moderate Progression",  step=0.00001, group="BTC · Upside Offsets %")
bU3=input.float(234.30180,"U3 · Logical Maximum",       step=0.00001, group="BTC · Upside Offsets %")
bU4=input.float(327.61590,"U4 · Strategic Extension",   step=0.00001, group="BTC · Upside Offsets %")
bU5=input.float(484.62296,"U5 · Aspirational Horizon",  step=0.00001, group="BTC · Upside Offsets %")
bD1=input.float(26.49415, "D1 · Cautious Accumulation", step=0.00001, group="BTC · Downside Offsets %")
bD2=input.float(42.52417, "D2 · Measured Scaling",      step=0.00001, group="BTC · Downside Offsets %")
bD3=input.float(49.01727, "D3 · Capitulation Opportunity",step=0.00001,group="BTC · Downside Offsets %")
bD4=input.float(56.60589, "D4 · Full Conviction",       step=0.00001, group="BTC · Downside Offsets %")
bD5=input.float(64.63981, "D5 · Shit or Bust",          step=0.00001, group="BTC · Downside Offsets %")

// ════════════════ ETH OFFSETS (%) ════════════════
eU1=input.float(134.43584,"U1 · Conservative Anchor",   step=0.00001, group="ETH · Upside Offsets %")
eU2=input.float(253.95950,"U2 · Moderate Progression",  step=0.00001, group="ETH · Upside Offsets %")
eU3=input.float(332.66035,"U3 · Logical Maximum",       step=0.00001, group="ETH · Upside Offsets %")
eU4=input.float(466.72163,"U4 · Strategic Extension",   step=0.00001, group="ETH · Upside Offsets %")
eU5=input.float(698.52082,"U5 · Aspirational Horizon",  step=0.00001, group="ETH · Upside Offsets %")
eD1=input.float(28.57070, "D1 · Cautious Accumulation", step=0.00001, group="ETH · Downside Offsets %")
eD2=input.float(41.08602, "D2 · Measured Scaling",      step=0.00001, group="ETH · Downside Offsets %")
eD3=input.float(46.36463, "D3 · Capitulation Opportunity",step=0.00001,group="ETH · Downside Offsets %")
eD4=input.float(52.72362, "D4 · Full Conviction",       step=0.00001, group="ETH · Downside Offsets %")
eD5=input.float(59.72656, "D5 · Shit or Bust",          step=0.00001, group="ETH · Downside Offsets %")

// ════════════════ XRP OFFSETS (%) ════════════════
xU1=input.float(134.43126,"U1 · Conservative Anchor",   step=0.00001, group="XRP · Upside Offsets %")
xU2=input.float(267.22787,"U2 · Moderate Progression",  step=0.00001, group="XRP · Upside Offsets %")
xU3=input.float(357.00554,"U3 · Logical Maximum",       step=0.00001, group="XRP · Upside Offsets %")
xU4=input.float(513.22533,"U4 · Strategic Extension",   step=0.00001, group="XRP · Upside Offsets %")
xU5=input.float(790.93267,"U5 · Aspirational Horizon",  step=0.00001, group="XRP · Upside Offsets %")
xD1=input.float(34.80669, "D1 · Cautious Accumulation", step=0.00001, group="XRP · Downside Offsets %")
xD2=input.float(51.41728, "D2 · Measured Scaling",      step=0.00001, group="XRP · Downside Offsets %")
xD3=input.float(57.90384, "D3 · Capitulation Opportunity",step=0.00001,group="XRP · Downside Offsets %")
xD4=input.float(65.28093, "D4 · Full Conviction",       step=0.00001, group="XRP · Downside Offsets %")
xD5=input.float(72.81869, "D5 · Shit or Bust",          step=0.00001, group="XRP · Downside Offsets %")

// ════════════════ SOL OFFSETS (%) ════════════════
sU1=input.float(75.84481, "U1 · Conservative Anchor",   step=0.00001, group="SOL · Upside Offsets %")
sU2=input.float(162.46893,"U2 · Moderate Progression",  step=0.00001, group="SOL · Upside Offsets %")
sU3=input.float(219.03566,"U3 · Logical Maximum",       step=0.00001, group="SOL · Upside Offsets %")
sU4=input.float(314.75543,"U4 · Strategic Extension",   step=0.00001, group="SOL · Upside Offsets %")
sU5=input.float(478.83479,"U5 · Aspirational Horizon",  step=0.00001, group="SOL · Upside Offsets %")
sD1=input.float(45.22357, "D1 · Cautious Accumulation", step=0.00001, group="SOL · Downside Offsets %")
sD2=input.float(59.37392, "D2 · Measured Scaling",      step=0.00001, group="SOL · Downside Offsets %")
sD3=input.float(64.87972, "D3 · Capitulation Opportunity",step=0.00001,group="SOL · Downside Offsets %")
sD4=input.float(71.12454, "D4 · Full Conviction",       step=0.00001, group="SOL · Downside Offsets %")
sD5=input.float(77.48300, "D5 · Shit or Bust",          step=0.00001, group="SOL · Downside Offsets %")

// ════════════════ ZONE VISIBILITY ════════════════
vU1=input.bool(true,"U1 · Conservative Anchor",   group="Zone Visibility — Upside",   inline="vu1")
vU2=input.bool(true,"U2 · Moderate Progression",  group="Zone Visibility — Upside",   inline="vu2")
vU3=input.bool(true,"U3 · Logical Maximum",       group="Zone Visibility — Upside",   inline="vu3")
vU4=input.bool(true,"U4 · Strategic Extension",   group="Zone Visibility — Upside",   inline="vu4")
vU5=input.bool(true,"U5 · Aspirational Horizon",  group="Zone Visibility — Upside",   inline="vu5")
vD1=input.bool(true,"D1 · Cautious Accumulation", group="Zone Visibility — Downside", inline="vd1")
vD2=input.bool(true,"D2 · Measured Scaling",      group="Zone Visibility — Downside", inline="vd2")
vD3=input.bool(true,"D3 · Capitulation Opportunity",group="Zone Visibility — Downside",inline="vd3")
vD4=input.bool(true,"D4 · Full Conviction",       group="Zone Visibility — Downside", inline="vd4")
vD5=input.bool(true,"D5 · Shit or Bust",          group="Zone Visibility — Downside", inline="vd5")

// ════════════════ COLOURS ════════════════
uc1=input.color(#FFEB3B,"U1",group="Upside Colours (yellow→red)",inline="uc")
uc2=input.color(#FFC107,"U2",group="Upside Colours (yellow→red)",inline="uc")
uc3=input.color(#FF9800,"U3",group="Upside Colours (yellow→red)",inline="uc")
uc4=input.color(#FF5722,"U4",group="Upside Colours (yellow→red)",inline="uc")
uc5=input.color(#F44336,"U5",group="Upside Colours (yellow→red)",inline="uc")
dc1=input.color(#66BB6A,"D1",group="Downside Colours (green→blue)",inline="dc")
dc2=input.color(#26A69A,"D2",group="Downside Colours (green→blue)",inline="dc")
dc3=input.color(#00ACC1,"D3",group="Downside Colours (green→blue)",inline="dc")
dc4=input.color(#1E88E5,"D4",group="Downside Colours (green→blue)",inline="dc")
dc5=input.color(#0D47A1,"D5",group="Downside Colours (green→blue)",inline="dc")

// ════════════════ STYLE ════════════════
showLabels = input.bool(true, "Show price labels", group="Style")
showAnchor = input.bool(true, "Show anchor (0%) line", group="Style")
showBounds = input.bool(true, "Show start/finish verticals", group="Style")
labelDec   = input.int(2, "Label decimals (%)", minval=0, maxval=8, tooltip="Display only. Full 5dp input precision always drives the level maths.", group="Style")
lineWidth  = input.int(1, "Zone line width", minval=1, maxval=4, group="Style")
styleStr   = input.string("Solid", "Zone line style", options=["Solid","Dashed","Dotted"], group="Style")

lineStyle = styleStr == "Dashed" ? line.style_dashed : styleStr == "Dotted" ? line.style_dotted : line.style_solid
isBull    = dirStr == "Bull"

// ── zone names ──
var upNames = array.from("Conservative Anchor","Moderate Progression","Logical Maximum","Strategic Extension","Aspirational Horizon")
var dnNames = array.from("Cautious Accumulation","Measured Scaling","Capitulation Opportunity","Full Conviction","Shit or Bust")

// ── per-asset arrays ──
btcU=array.from(bU1,bU2,bU3,bU4,bU5), btcD=array.from(bD1,bD2,bD3,bD4,bD5)
ethU=array.from(eU1,eU2,eU3,eU4,eU5), ethD=array.from(eD1,eD2,eD3,eD4,eD5)
xrpU=array.from(xU1,xU2,xU3,xU4,xU5), xrpD=array.from(xD1,xD2,xD3,xD4,xD5)
solU=array.from(sU1,sU2,sU3,sU4,sU5), solD=array.from(sD1,sD2,sD3,sD4,sD5)

// ── average (live, tracks edits) ──
avgU=array.new<float>(), avgD=array.new<float>()
for i = 0 to 4
    array.push(avgU, (array.get(btcU,i)+array.get(ethU,i)+array.get(xrpU,i)+array.get(solU,i))/4)
    array.push(avgD, (array.get(btcD,i)+array.get(ethD,i)+array.get(xrpD,i)+array.get(solD,i))/4)

// ── select active asset ──
actU = asset=="BTC"?btcU : asset=="ETH"?ethU : asset=="XRP"?xrpU : asset=="SOL"?solU : avgU
actD = asset=="BTC"?btcD : asset=="ETH"?ethD : asset=="XRP"?xrpD : asset=="SOL"?solD : avgD

// ── select active direction ──
devs  = isBull ? actU : actD
cols  = isBull ? array.from(uc1,uc2,uc3,uc4,uc5) : array.from(dc1,dc2,dc3,dc4,dc5)
names = isBull ? upNames : dnNames
vis   = isBull ? array.from(vU1,vU2,vU3,vU4,vU5) : array.from(vD1,vD2,vD3,vD4,vD5)
sgn   = isBull ? "+" : "-"

var line[]  L = array.new<line>()
var label[] T = array.new<label>()

if barstate.islast
    for ln in L
        line.delete(ln)
    array.clear(L)
    for lb in T
        label.delete(lb)
    array.clear(T)

    if crossPrice > 0
        x1 = startTime
        x2 = startTime + durDays * 86400000
        float hi = crossPrice
        float lo = crossPrice

        if showAnchor
            array.push(L, line.new(x1, crossPrice, x2, crossPrice, xloc=xloc.bar_time, color=color.new(color.gray,0), style=line.style_dotted, width=1))
            if showLabels
                array.push(T, label.new(x2, crossPrice, asset + " anchor  " + str.tostring(crossPrice, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.gray,80), textcolor=color.gray, size=size.small))

        for i = 0 to 4
            if array.get(vis, i)
                dev = array.get(devs, i)
                col = array.get(cols, i)
                nm  = array.get(names, i)
                lvl = isBull ? crossPrice * (1 + dev/100) : crossPrice * (1 - dev/100)
                if lvl > 0
                    hi := math.max(hi, lvl)
                    lo := math.min(lo, lvl)
                    array.push(L, line.new(x1, lvl, x2, lvl, xloc=xloc.bar_time, color=col, style=lineStyle, width=lineWidth))
                    if showLabels
                        txt = nm + "  " + sgn + str.tostring(math.round(dev, labelDec)) + "%  " + str.tostring(lvl, format.mintick)
                        array.push(T, label.new(x2, lvl, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col,85), textcolor=col, size=size.small))

        if showBounds and hi > lo
            array.push(L, line.new(x1, lo, x1, hi, xloc=xloc.bar_time, color=color.new(color.gray,50), style=line.style_dashed, width=1))
            array.push(L, line.new(x2, lo, x2, hi, xloc=xloc.bar_time, color=color.new(color.gray,50), style=line.style_dashed, width=1))
    else
        array.push(T, label.new(bar_index, close, "Set Anchor price > 0 in settings", style=label.style_label_down, color=color.new(color.red,0), textcolor=color.white, size=size.normal))
````
