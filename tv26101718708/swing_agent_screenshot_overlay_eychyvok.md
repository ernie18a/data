# Swing Agent Screenshot Overlay

- url: https://www.tradingview.com/script/eycHYVoK/
- type: indicator
- pine_id: PUB;f8585c6c0b4442fd8b02a573d569105f
- version: 1.0

## Description

Screenshot Standardization Overlay for discretionary multi-timeframe trading workflows.
This overlay is designed to make chart captures consistent and readable across HTF, LTF and trade management phases. It lets you plot primary and secondary zones, invalidation, key levels, entry/stop/targets, plus optional session VWAPs and a custom anchored VWAP.
Built for traders who want structured screenshots for review, journaling, collaboration, or AI-assisted analysis. It does not replace native Volume Profile tools, but helps create a uniform visual framework around them.

## Source Code

````pine
//@version=6
indicator("Swing Agent Screenshot Overlay", overlay=true, max_labels_count=100)

// =========================
// PURPOSE
// Standardize TradingView screenshots for the COT-Driven Swing Decision Pipeline.
// This script DOES NOT replace built-in Volume Profile or built-in AVWAP tools.
// Use it as a clean overlay for zones, invalidation, entry/risk, custom AVWAP and session VWAPs.
// =========================

// -------- Mode --------
mode = input.string("HTF", "Mode", options=["HTF", "LTF", "MANAGE"])
showWatermark = input.bool(true, "Show Mode Watermark")

// -------- Display controls --------
showPrimary = input.bool(true,  "Show Primary Zone")
showSecondary = input.bool(true, "Show Secondary Zone")
showInvalidation = input.bool(true, "Show Invalidation")
showExtraLevel = input.bool(false, "Show Extra Level")
showTradeLevels = input.bool(true, "Show Entry / Stop / TP")

// -------- Zone inputs --------
primaryTop    = input.float(0.0, "Primary Zone Top", step=0.01)
primaryBottom = input.float(0.0, "Primary Zone Bottom", step=0.01)
primaryLabel  = input.string("PRIMARY", "Primary Zone Label")

secondaryTop    = input.float(0.0, "Secondary Zone Top", step=0.01)
secondaryBottom = input.float(0.0, "Secondary Zone Bottom", step=0.01)
secondaryLabel  = input.string("SECONDARY", "Secondary Zone Label")

invalidationLevel = input.float(0.0, "Invalidation Level", step=0.01)
invalidationLabel = input.string("INVALIDATION", "Invalidation Label")

extraLevel = input.float(0.0, "Extra Level", step=0.01)
extraLabel = input.string("EXTRA", "Extra Level Label")

// -------- Trade inputs --------
entryLevel = input.float(0.0, "Entry Level", step=0.01)
entryLabel = input.string("ENTRY", "Entry Label")

stopLevel = input.float(0.0, "Stop Level", step=0.01)
stopLabel = input.string("STOP", "Stop Label")

tp1Level = input.float(0.0, "TP1 Level", step=0.01)
tp1Label = input.string("TP1", "TP1 Label")

tp2Level = input.float(0.0, "TP2 Level", step=0.01)
tp2Label = input.string("TP2", "TP2 Label")

// -------- Custom AVWAP --------
showCustomAVWAP = input.bool(false, "Show Custom AVWAP")
avwapAnchorTime = input.time(timestamp("01 Jan 2026 00:00 +0000"), "AVWAP Anchor Time")
avwapLabel = input.string("AVWAP", "AVWAP Label")

// -------- Session VWAPs --------
showEUVWAP = input.bool(false, "Show EU Session VWAP")
euSession = input.session("0830-1430", "EU Session")
showUSVWAP = input.bool(false, "Show US Session VWAP")
usSession = input.session("1430-2200", "US Session")
userTz = input.string("Europe/Rome", "Session Timezone")

// -------- Style --------
primaryColor = input.color(color.new(color.teal, 0), "Primary Color")
secondaryColor = input.color(color.new(color.orange, 0), "Secondary Color")
invalidationColor = input.color(color.new(color.red, 0), "Invalidation Color")
extraColor = input.color(color.new(color.gray, 0), "Extra Level Color")
entryColor = input.color(color.new(color.blue, 0), "Entry Color")
stopColor = input.color(color.new(color.red, 0), "Stop Color")
tp1Color = input.color(color.new(color.green, 0), "TP1 Color")
tp2Color = input.color(color.new(color.lime, 0), "TP2 Color")
avwapColor = input.color(color.new(color.fuchsia, 0), "AVWAP Color")
euVwapColor = input.color(color.new(color.yellow, 0), "EU VWAP Color")
usVwapColor = input.color(color.new(color.aqua, 0), "US VWAP Color")

zoneFillPrimary = color.new(primaryColor, 85)
zoneFillSecondary = color.new(secondaryColor, 88)

// =========================
// Helpers
// =========================
f_label_y(top, bottom) =>
    top != 0.0 and bottom != 0.0 ? (top + bottom) / 2.0 : na

f_has_zone(top, bottom) =>
    top != 0.0 and bottom != 0.0

f_has_level(level) =>
    level != 0.0

// =========================
// Zone plots
// =========================
pPrimaryTop = plot(showPrimary and f_has_zone(primaryTop, primaryBottom) ? primaryTop : na, title="Primary Top", color=primaryColor, linewidth=2, style=plot.style_linebr)
pPrimaryBot = plot(showPrimary and f_has_zone(primaryTop, primaryBottom) ? primaryBottom : na, title="Primary Bottom", color=primaryColor, linewidth=2, style=plot.style_linebr)
fill(pPrimaryTop, pPrimaryBot, color=showPrimary and f_has_zone(primaryTop, primaryBottom) ? zoneFillPrimary : na)

pSecondaryTop = plot(showSecondary and f_has_zone(secondaryTop, secondaryBottom) ? secondaryTop : na, title="Secondary Top", color=secondaryColor, linewidth=2, style=plot.style_linebr)
pSecondaryBot = plot(showSecondary and f_has_zone(secondaryTop, secondaryBottom) ? secondaryBottom : na, title="Secondary Bottom", color=secondaryColor, linewidth=2, style=plot.style_linebr)
fill(pSecondaryTop, pSecondaryBot, color=showSecondary and f_has_zone(secondaryTop, secondaryBottom) ? zoneFillSecondary : na)

plot(showInvalidation and f_has_level(invalidationLevel) ? invalidationLevel : na, title="Invalidation", color=invalidationColor, linewidth=2, style=plot.style_linebr)
plot(showExtraLevel and f_has_level(extraLevel) ? extraLevel : na, title="Extra Level", color=extraColor, linewidth=1, style=plot.style_linebr)

// =========================
// Trade levels
// =========================
plot(showTradeLevels and f_has_level(entryLevel) ? entryLevel : na, title="Entry", color=entryColor, linewidth=2, style=plot.style_linebr)
plot(showTradeLevels and f_has_level(stopLevel) ? stopLevel : na, title="Stop", color=stopColor, linewidth=2, style=plot.style_linebr)
plot(showTradeLevels and f_has_level(tp1Level) ? tp1Level : na, title="TP1", color=tp1Color, linewidth=2, style=plot.style_linebr)
plot(showTradeLevels and f_has_level(tp2Level) ? tp2Level : na, title="TP2", color=tp2Color, linewidth=2, style=plot.style_linebr)

// =========================
// Custom AVWAP
// =========================
var float cumPV = na
var float cumV = na
var bool avwapStarted = false

anchorReached = time >= avwapAnchorTime
newAnchor = anchorReached and not anchorReached[1]

if showCustomAVWAP
    if newAnchor
        cumPV := hlc3 * volume
        cumV := volume
        avwapStarted := true
    else if anchorReached and avwapStarted
        cumPV += hlc3 * volume
        cumV += volume

customAVWAP = showCustomAVWAP and avwapStarted and cumV > 0 ? cumPV / cumV : na
plot(customAVWAP, title="Custom AVWAP", color=avwapColor, linewidth=2)

// =========================
// Session VWAP helper
// =========================
f_session_vwap(_session, _tz) =>
    inSess = not na(time(timeframe.period, _session, _tz))
    startSess = inSess and not inSess[1]
    var float sPV = na
    var float sV = na
    if startSess
        sPV := hlc3 * volume
        sV := volume
    else if inSess
        sPV += hlc3 * volume
        sV += volume
    [inSess and sV > 0 ? sPV / sV : na, inSess]

[euVWAP, euOn] = f_session_vwap(euSession, userTz)
[usVWAP, usOn] = f_session_vwap(usSession, userTz)

plot(showEUVWAP and euOn ? euVWAP : na, title="EU Session VWAP", color=euVwapColor, linewidth=2)
plot(showUSVWAP and usOn ? usVWAP : na, title="US Session VWAP", color=usVwapColor, linewidth=2)

// =========================
// Labels on last bar only
// =========================
var label lblPrimary = na
var label lblSecondary = na
var label lblInvalid = na
var label lblExtra = na
var label lblEntry = na
var label lblStop = na
var label lblTP1 = na
var label lblTP2 = na
var label lblAVWAP = na
var label lblEUVWAP = na
var label lblUSVWAP = na
var label lblMode = na

if barstate.islast
    label.delete(lblPrimary)
    label.delete(lblSecondary)
    label.delete(lblInvalid)
    label.delete(lblExtra)
    label.delete(lblEntry)
    label.delete(lblStop)
    label.delete(lblTP1)
    label.delete(lblTP2)
    label.delete(lblAVWAP)
    label.delete(lblEUVWAP)
    label.delete(lblUSVWAP)
    label.delete(lblMode)

    if showPrimary and f_has_zone(primaryTop, primaryBottom)
        lblPrimary := label.new(bar_index, f_label_y(primaryTop, primaryBottom), primaryLabel, style=label.style_label_left, textcolor=color.white, color=primaryColor)
    if showSecondary and f_has_zone(secondaryTop, secondaryBottom)
        lblSecondary := label.new(bar_index, f_label_y(secondaryTop, secondaryBottom), secondaryLabel, style=label.style_label_left, textcolor=color.white, color=secondaryColor)
    if showInvalidation and f_has_level(invalidationLevel)
        lblInvalid := label.new(bar_index, invalidationLevel, invalidationLabel, style=label.style_label_left, textcolor=color.white, color=invalidationColor)
    if showExtraLevel and f_has_level(extraLevel)
        lblExtra := label.new(bar_index, extraLevel, extraLabel, style=label.style_label_left, textcolor=color.white, color=extraColor)

    if showTradeLevels and f_has_level(entryLevel)
        lblEntry := label.new(bar_index, entryLevel, entryLabel, style=label.style_label_left, textcolor=color.white, color=entryColor)
    if showTradeLevels and f_has_level(stopLevel)
        lblStop := label.new(bar_index, stopLevel, stopLabel, style=label.style_label_left, textcolor=color.white, color=stopColor)
    if showTradeLevels and f_has_level(tp1Level)
        lblTP1 := label.new(bar_index, tp1Level, tp1Label, style=label.style_label_left, textcolor=color.white, color=tp1Color)
    if showTradeLevels and f_has_level(tp2Level)
        lblTP2 := label.new(bar_index, tp2Level, tp2Label, style=label.style_label_left, textcolor=color.white, color=tp2Color)

    if showCustomAVWAP and not na(customAVWAP)
        lblAVWAP := label.new(bar_index, customAVWAP, avwapLabel, style=label.style_label_left, textcolor=color.white, color=avwapColor)
    if showEUVWAP and not na(euVWAP)
        lblEUVWAP := label.new(bar_index, euVWAP, "EU VWAP", style=label.style_label_left, textcolor=color.black, color=euVwapColor)
    if showUSVWAP and not na(usVWAP)
        lblUSVWAP := label.new(bar_index, usVWAP, "US VWAP", style=label.style_label_left, textcolor=color.black, color=usVwapColor)

    if showWatermark
        lblMode := label.new(bar_index, high, mode, style=label.style_label_down, textcolor=color.white, color=color.new(color.black, 65))
````
