# ZIZO Zone Projector (Simplified)

- url: https://www.tradingview.com/script/0d3wS08I-ZIZO-Zone-Projector-Simplified/
- type: indicator
- pine_id: PUB;4f905abb3e024d64a015806a3f57f5c3
- version: 1.0

## Description

ZIZO Zone Projector (Simplified)

Static, fixed-anchor deviation zones projected forward from a 200 SMA cross.

Overview

The Zone Projector draws a set of horizontal "cycle zones" above or below a single anchor price. The anchor is the price where a 200-day SMA cross happened. From that anchor it projects five upside zones and five downside zones as fixed percentage offsets, then extends them across a date range you choose.

It answers one question: if this cross marks the start of a leg, where do the stages of that leg sit in price?

The idea

Most zone tools refit to recent data. That makes them look accurate in hindsight and vague in real time.

This does the opposite. You pick one verifiable anchor — a real 200 SMA cross price — and every level is a fixed percentage from it. Nothing moves. Nothing refits. Every number on the chart is a number you chose. That is the point: you can check it.

How it works


You enter the anchor price (the 200 SMA cross price for the active direction).
You pick a direction. Bull draws the five upside zones. Bear draws the five downside zones. Only one side is active at a time.
Each zone is a percentage offset from the anchor:

Bull level = anchor × (1 + offset%)
Bear level = anchor × (1 − offset%)



The zones are drawn from your start date forward for the duration you set.


The stages

Upside — heating up (yellow → red): Optimism, Belief, Thrill, Euphoria, Maximum Risk.

Downside — cooling off (green → blue): Anxiety, Denial, Panic, Capitulation, Maximum Opportunity.

Colours follow the ZIZO heatmap. Hotter means higher risk. Cooler means higher opportunity.

Live cycle map

A small table reads current price against the anchor. It shows the deviation and names the stage price is sitting in. The table updates with live price. The projected levels themselves stay fixed.

How to use it


Find the 200 SMA cross that starts the leg you care about. Read its price.
Enter that price as the anchor. Set direction to match — up-cross = Bull, down-cross = Bear.
Set the start date to the cross date, and a duration that covers the leg.
Adjust the offsets if you want your own calibration. Defaults are the ZIZO BTC set.
Watch the table to see which stage price is in now.


Settings


Asset & Anchor — label, direction, anchor price, start date, duration.
Offsets — the ten percentages (5 up, 5 down), at 5-decimal precision.
Visibility — turn any zone on or off. Hidden zones keep their maths; only the colour goes.
Colours — the ZIZO hot/cool palette, editable.
Style — labels, anchor line, start/finish verticals, fills, transparency, table position, decimals, line width and style.


Notes and limits


This is the manual, static version. You enter the anchor yourself. The auto-anchored MTF version finds the cross for you.
The offsets are chosen values, not a fit. Defaults are tuned for BTC. Re-tune them for other assets or other views.
The zones do not predict. They mark where chosen levels sit. Price can ignore them.
No buy/sell signals and no alerts. This is a roadmap tool, not a trigger.
The levels do not repaint. Only the table's "price now" and "stage" move, because live price moves.
This is a research and charting tool. It is not financial advice.


Open source under MPL 2.0. Read the code, verify the maths, fork it if you want.

Hard money. Don't trust. Verify.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PseudoNakamoto21
//
// ZIZO Zone Projector (Simplified) — static anchored deviation zones projected from a 200 SMA cross price.
// Single custom 5-up/5-down offset set. No per-asset presets.

//@version=6
indicator("ZIZO Zone Projector (Simplified)", "Zone In, Zone Out (Custom)", overlay=true, max_lines_count=500, max_labels_count=500)

// ════════════════ ASSET & ANCHOR ════════════════
assetLabel  = input.string("Asset", "Asset label (display only)", tooltip="Purely cosmetic — shown on labels/table. Does not change any math.", group="▸ Asset & Anchor")
dirStr      = input.string("Bull", "Direction  (only one side draws)", options=["Bull","Bear"], tooltip="Bull: price/SMA above the cross. Bear: below. One anchor in play at a time.", group="▸ Asset & Anchor")
crossPrice  = input.float(0.00000, "Anchor price (active cross)", minval=0.0, step=0.00001, tooltip="The 200 SMA cross price for the ACTIVE direction. Bull = up-cross price; Bear = down-cross price. Must be > 0.", group="▸ Asset & Anchor")
startTime   = input.time(timestamp("01 Sept 2021 00:00 +0000"), "Start date", group="▸ Asset & Anchor")
durDays     = input.int(365, "Duration (days)", minval=1, group="▸ Asset & Anchor")

// ════════════════ OFFSETS (%) — 5 Up / 5 Down ════════════════
cU1=input.float(90.91068,  "U1 · Optimism",           step=0.00001, group="Upside Offsets %")
cU2=input.float(177.77071,  "U2 · Belief",             step=0.00001, group="Upside Offsets %")
cU3=input.float(233.46276, "U3 · Thrill",             step=0.00001, group="Upside Offsets %")
cU4=input.float(326.32407, "U4 · Euphoria",           step=0.00001, group="Upside Offsets %")
cU5=input.float(482.47737, "U5 · Maximum Risk",       step=0.00001, group="Upside Offsets %")
cD1=input.float(28.92401,  "D1 · Anxiety",            step=0.00001, group="Downside Offsets %")
cD2=input.float(44.42413,  "D2 · Denial",             step=0.00001, group="Downside Offsets %")
cD3=input.float(50.70259,  "D3 · Panic",              step=0.00001, group="Downside Offsets %")
cD4=input.float(58.04035,  "D4 · Capitulation",       step=0.00001, group="Downside Offsets %")
cD5=input.float(65.80870,  "D5 · Maximum Opportunity",step=0.00001, group="Downside Offsets %")

// ════════════════ ZONE VISIBILITY ════════════════
vU1=input.bool(true,"U1 · Optimism",      group="Zone Visibility — Upside")
vU2=input.bool(true,"U2 · Belief",        group="Zone Visibility — Upside")
vU3=input.bool(true,"U3 · Thrill",        group="Zone Visibility — Upside")
vU4=input.bool(true,"U4 · Euphoria",      group="Zone Visibility — Upside")
vU5=input.bool(true,"U5 · Maximum Risk",  group="Zone Visibility — Upside")
vD1=input.bool(true,"D1 · Anxiety",       group="Zone Visibility — Downside")
vD2=input.bool(true,"D2 · Denial",        group="Zone Visibility — Downside")
vD3=input.bool(true,"D3 · Panic",         group="Zone Visibility — Downside")
vD4=input.bool(true,"D4 · Capitulation",  group="Zone Visibility — Downside")
vD5=input.bool(true,"D5 · Maximum Opportunity", group="Zone Visibility — Downside")

// ════════════════ COLOURS — ZIZO hot/cool ════════════════
uc1=input.color(#e6e64c,"U1",group="Upside Colours (yellow→red)",inline="uc")
uc2=input.color(#ffcc33,"U2",group="Upside Colours (yellow→red)",inline="uc")
uc3=input.color(#ff9933,"U3",group="Upside Colours (yellow→red)",inline="uc")
uc4=input.color(#ff6633,"U4",group="Upside Colours (yellow→red)",inline="uc")
uc5=input.color(#e6392d,"U5",group="Upside Colours (yellow→red)",inline="uc")
dc1=input.color(#a6d96e,"D1",group="Downside Colours (green→blue)",inline="dc")
dc2=input.color(#3ed9a6,"D2",group="Downside Colours (green→blue)",inline="dc")
dc3=input.color(#2eb8d9,"D3",group="Downside Colours (green→blue)",inline="dc")
dc4=input.color(#1e7cc2,"D4",group="Downside Colours (green→blue)",inline="dc")
dc5=input.color(#0a4d8c,"D5",group="Downside Colours (green→blue)",inline="dc")

// ════════════════ STYLE ════════════════
showLabels = input.bool(true,  "Show price labels", group="Style")
showAnchor = input.bool(true,  "Show anchor (0%) line", group="Style")
showBounds = input.bool(true,  "Show start/finish verticals", group="Style")
showFills  = input.bool(true,  "Fill zones (heat gradient)", group="Style")
fillTransp = input.int(85, "Fill transparency", minval=0, maxval=100, group="Style")
tablePos   = input.string("Top Left", "Cycle-map table", options=["Top Left","Top Right","Bottom Left","Bottom Right","None"], group="Style")
labelDec   = input.int(2, "Label decimals (%)", minval=0, maxval=8, tooltip="Display only. Full 5dp input precision always drives the level maths.", group="Style")
lineWidth  = input.int(1, "Zone line width", minval=1, maxval=4, group="Style")
styleStr   = input.string("Solid", "Zone line style", options=["Solid","Dashed","Dotted"], group="Style")

lineStyle = styleStr == "Dashed" ? line.style_dashed : styleStr == "Dotted" ? line.style_dotted : line.style_solid
isBull    = dirStr == "Bull"

// ── stage names ──
var upNames = array.from("Optimism","Belief","Thrill","Euphoria","Maximum Risk")
var dnNames = array.from("Anxiety","Denial","Panic","Capitulation","Maximum Opportunity")

// ── colour arrays ──
upCols = array.from(uc1,uc2,uc3,uc4,uc5)
dnCols = array.from(dc1,dc2,dc3,dc4,dc5)

// ── offset arrays ──
actU = array.from(cU1,cU2,cU3,cU4,cU5)
actD = array.from(cD1,cD2,cD3,cD4,cD5)

devs  = isBull ? actU : actD
cols  = isBull ? upCols : dnCols
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

        // anchor line (always created so fills have a base; hidden if toggled off)
        anchorCol = showAnchor ? color.new(color.gray, 0) : color.new(color.gray, 100)
        line lnAnchor = line.new(x1, crossPrice, x2, crossPrice, xloc=xloc.bar_time, color=anchorCol, style=line.style_dotted, width=1)
        array.push(L, lnAnchor)
        if showAnchor and showLabels
            array.push(T, label.new(x2, crossPrice, assetLabel + " · cross  " + str.tostring(crossPrice, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.gray,80), textcolor=color.gray, size=size.small))

        line prevLine = lnAnchor
        for i = 0 to 4
            if array.get(vis, i)
                dev = array.get(devs, i)
                col = array.get(cols, i)
                nm  = array.get(names, i)
                lvl = isBull ? crossPrice * (1 + dev/100) : crossPrice * (1 - dev/100)
                if lvl > 0
                    hi := math.max(hi, lvl)
                    lo := math.min(lo, lvl)
                    line ln = line.new(x1, lvl, x2, lvl, xloc=xloc.bar_time, color=col, style=lineStyle, width=lineWidth)
                    array.push(L, ln)
                    if showFills
                        linefill.new(prevLine, ln, color.new(col, fillTransp))
                    prevLine := ln
                    if showLabels
                        txt = nm + "  " + sgn + str.tostring(math.round(dev, labelDec)) + "%  " + str.tostring(lvl, format.mintick)
                        array.push(T, label.new(x2, lvl, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col,85), textcolor=col, size=size.small))

        if showBounds and hi > lo
            array.push(L, line.new(x1, lo, x1, hi, xloc=xloc.bar_time, color=color.new(color.gray,50), style=line.style_dashed, width=1))
            array.push(L, line.new(x2, lo, x2, hi, xloc=xloc.bar_time, color=color.new(color.gray,50), style=line.style_dashed, width=1))

        // ── cycle-position table ──
        if tablePos != "None"
            float devNow = (close - crossPrice) / crossPrice * 100.0
            string posName = ""
            color  posCol  = color.gray
            if isBull
                int reached = -1
                for i = 0 to 4
                    if devNow >= array.get(actU, i)
                        reached := i
                if reached >= 0
                    posName := array.get(upNames, reached)
                    posCol  := array.get(upCols, reached)
                else
                    posName := devNow >= 0 ? "Below Optimism" : "Below cross"
            else
                float d = -devNow
                int reached = -1
                for i = 0 to 4
                    if d >= array.get(actD, i)
                        reached := i
                if reached >= 0
                    posName := array.get(dnNames, reached)
                    posCol  := array.get(dnCols, reached)
                else
                    posName := d >= 0 ? "Above Anxiety" : "Above cross"

            tpos = tablePos=="Top Right" ? position.top_right : tablePos=="Bottom Left" ? position.bottom_left : tablePos=="Bottom Right" ? position.bottom_right : position.top_left
            var table tb = table.new(tpos, 2, 6, bgcolor=color.new(#0d0d1a, 10), border_width=1, border_color=color.new(color.gray, 55), frame_width=1, frame_color=color.new(color.gray, 35))
            cHdr = color.new(#e6e64c, 0)
            cLbl = color.new(color.silver, 10)
            cVal = color.white
            table.cell(tb, 0, 0, "ZIZO · Cycle Map", bgcolor=color.new(#0d0d1a,5), text_color=cHdr, text_size=size.small)
            table.cell(tb, 1, 0, isBull ? "Bull ▲" : "Bear ▼", bgcolor=color.new(#0d0d1a,5), text_color=cHdr, text_size=size.small)
            table.cell(tb, 0, 1, "Asset",  text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 1, assetLabel, text_color=cVal, text_size=size.small)
            table.cell(tb, 0, 2, "Anchor", text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 2, str.tostring(crossPrice, format.mintick), text_color=cVal, text_size=size.small)
            table.cell(tb, 0, 3, "Price now", text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 3, str.tostring(close, format.mintick), text_color=cVal, text_size=size.small)
            table.cell(tb, 0, 4, "vs anchor", text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 4, str.format("{0,number,+0.0}", devNow) + "%", text_color=posCol, text_size=size.small)
            table.cell(tb, 0, 5, "Stage", text_color=cLbl, text_size=size.small)
            table.cell(tb, 1, 5, posName, text_color=posCol, text_size=size.small)
    else
        array.push(T, label.new(bar_index, close, "Set Anchor price > 0 in settings", style=label.style_label_down, color=color.new(color.red,0), textcolor=color.white, size=size.normal))
````
