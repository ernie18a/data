<!-- tradingview-pine-id: PUB;eee72fd0fb5943f68247af32c0831559 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# CryptonianEWView

Source: https://www.tradingview.com/script/UFVszoAa-CryptonianEWView/

## Description

Library  "CryptonianEWView"
Cryptonian Elliott Wave View /1. Dedicated presentation-policy layer for Minimal Trader, Balanced, Full Audit and Custom chart modes. Presentation only; no Elliott, Forecast, Trade, Runtime or Audit methodology.

resolve(mode, cleanChart, primaryDegreeLinesOn, secondaryDegreeLinesOn, subSecondaryDegreeLinesOn, alternateCountLinesOn, correctionLinesOn, showPivotSkeleton, showElliottChannels, showPrimaryCount, secondaryDegreeLabelsOn, subSecondaryDegreeLabelsOn, showAlternateCount, showCorrection, showPivotIds, showDevelopingPivot, showCorrectionLevels, showFibModel, showFreshFvg, showInvalidationLevel, showInvalidationTags, showRevisionTags, showTradeLevels, showTradeSignals, showPotentialForecast, forecastAuditOn, forecastAuditLabelsOn, contextForecastRoadmapOn, contextForecastMainLabelOn, contextForecastTargetLabelsOn, htfTradeBridgeGeometryOn, maxTradeLifecycleLabels)
  Parameters:
    mode (string)
    cleanChart (bool)
    primaryDegreeLinesOn (bool)
    secondaryDegreeLinesOn (bool)
    subSecondaryDegreeLinesOn (bool)
    alternateCountLinesOn (bool)
    correctionLinesOn (bool)
    showPivotSkeleton (bool)
    showElliottChannels (bool)
    showPrimaryCount (bool)
    secondaryDegreeLabelsOn (bool)
    subSecondaryDegreeLabelsOn (bool)
    showAlternateCount (bool)
    showCorrection (bool)
    showPivotIds (bool)
    showDevelopingPivot (bool)
    showCorrectionLevels (bool)
    showFibModel (bool)
    showFreshFvg (bool)
    showInvalidationLevel (bool)
    showInvalidationTags (bool)
    showRevisionTags (bool)
    showTradeLevels (bool)
    showTradeSignals (bool)
    showPotentialForecast (bool)
    forecastAuditOn (bool)
    forecastAuditLabelsOn (bool)
    contextForecastRoadmapOn (bool)
    contextForecastMainLabelOn (bool)
    contextForecastTargetLabelsOn (bool)
    htfTradeBridgeGeometryOn (bool)
    maxTradeLifecycleLabels (int)

drawActiveZone(boxStore, labelStore, enabled, startBar, projectionBars, zoneTop, zoneBottom, zoneName, zoneColor, panelColor, labelSize)
  Parameters:
    boxStore (array<box>)
    labelStore (array<label>)
    enabled (bool)
    startBar (int)
    projectionBars (int)
    zoneTop (float)
    zoneBottom (float)
    zoneName (string)
    zoneColor (color)
    panelColor (color)
    labelSize (string)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AYEHAN

//@version=6
// @description Cryptonian Elliott Wave View /2. Dedicated presentation-policy layer for Minimal Trader, Balanced, Full Audit and Custom chart modes. Presentation only; no Elliott, Forecast, Trade, Runtime or Audit methodology.
library("CryptonianEWView", overlay = true)

import AYEHAN/CryptonianEWModel/1 as ewModel

export resolve(
     string mode,
     bool cleanChart,
     bool primaryDegreeLinesOn,
     bool secondaryDegreeLinesOn,
     bool subSecondaryDegreeLinesOn,
     bool alternateCountLinesOn,
     bool correctionLinesOn,
     bool showPivotSkeleton,
     bool showElliottChannels,
     bool showPrimaryCount,
     bool secondaryDegreeLabelsOn,
     bool subSecondaryDegreeLabelsOn,
     bool showAlternateCount,
     bool showCorrection,
     bool showPivotIds,
     bool showDevelopingPivot,
     bool showCorrectionLevels,
     bool showFibModel,
     bool showFreshFvg,
     bool showInvalidationLevel,
     bool showInvalidationTags,
     bool showRevisionTags,
     bool showTradeLevels,
     bool showTradeSignals,
     bool showPotentialForecast,
     bool forecastAuditOn,
     bool forecastAuditLabelsOn,
     bool contextForecastRoadmapOn,
     bool contextForecastMainLabelOn,
     bool contextForecastTargetLabelsOn,
     bool htfTradeBridgeGeometryOn,
     int maxTradeLifecycleLabels) =>

    bool custom = mode == "Custom"
    bool balanced = mode == "Balanced"
    bool full = mode == "Full Audit"
    bool minimal = not custom and not balanced and not full

    bool effectiveCleanGeometry = custom ? cleanChart : not full

    bool primaryLines = custom ? (primaryDegreeLinesOn and not cleanChart) : full
    bool secondaryLines = custom ? (secondaryDegreeLinesOn and not cleanChart) : full
    bool subSecondaryLines = custom ? (subSecondaryDegreeLinesOn and not cleanChart) : full
    bool alternateLines = custom ? (alternateCountLinesOn and not cleanChart) : full
    bool correctionLines = custom ? (correctionLinesOn and not cleanChart) : full
    bool pivotSkeleton = custom ? (showPivotSkeleton and not cleanChart) : full
    bool channels = custom ? (showElliottChannels and not cleanChart) : full

    bool primaryLabels = custom ? showPrimaryCount : (balanced or full)
    bool secondaryLabels = custom ? secondaryDegreeLabelsOn : full
    bool subSecondaryLabels = custom ? subSecondaryDegreeLabelsOn : full
    bool alternateLabels = custom ? showAlternateCount : full
    bool correctionLabels = custom ? showCorrection : (balanced or full)
    bool pivotIds = custom ? showPivotIds : full
    bool developingPivot = custom ? showDevelopingPivot : (balanced or full)

    bool correctionLevels = custom ? showCorrectionLevels : true
    bool fibModel = custom ? showFibModel : (balanced or full)
    bool activeZoneOnly = not custom and minimal
    bool freshFvg = custom ? showFreshFvg : (balanced or full)

    bool invalidationLevel = custom ? showInvalidationLevel : true
    bool invalidationTags = custom ? showInvalidationTags : full
    bool revisionTags = custom ? showRevisionTags : full

    bool tradeLevels = custom ? showTradeLevels : true
    bool tradeSignals = custom ? showTradeSignals : (balanced or full)

    bool potentialForecast = custom ? showPotentialForecast : true
    bool forecastAuditGeometry = custom ? forecastAuditOn : full
    bool forecastAuditLabels = custom ? forecastAuditLabelsOn : full
    bool forecastMilestones = custom ? showPotentialForecast : (balanced or full)

    bool contextRoadmap = custom ? contextForecastRoadmapOn : true
    bool contextMainLabel = custom ? contextForecastMainLabelOn : true
    bool contextTargetLabels = custom ? contextForecastTargetLabelsOn : (balanced or full)
    bool htfTradeGeometry = custom ? htfTradeBridgeGeometryOn : true

    int lifecycleHistory = custom ? maxTradeLifecycleLabels : full ? 60 : balanced ? 12 : 1
    string summary = full ? "FULL AUDIT" : balanced ? "BALANCED" : custom ? "CUSTOM" : "MINIMAL TRADER"

    [effectiveCleanGeometry,
     primaryLines, secondaryLines, subSecondaryLines, alternateLines, correctionLines,
     pivotSkeleton, channels,
     primaryLabels, secondaryLabels, subSecondaryLabels, alternateLabels, correctionLabels,
     pivotIds, developingPivot,
     correctionLevels, fibModel, activeZoneOnly, freshFvg,
     invalidationLevel, invalidationTags, revisionTags,
     tradeLevels, tradeSignals,
     potentialForecast, forecastAuditGeometry, forecastAuditLabels, forecastMilestones,
     contextRoadmap, contextMainLabel, contextTargetLabels, htfTradeGeometry,
     lifecycleHistory, summary]

export drawActiveZone(
     array<box> boxStore,
     array<label> labelStore,
     bool enabled,
     int startBar,
     int projectionBars,
     float zoneTop,
     float zoneBottom,
     string zoneName,
     color zoneColor,
     color panelColor,
     string labelSize) =>

    if barstate.islast
        if array.size(boxStore) > 0
            for i = 0 to array.size(boxStore) - 1
                box.delete(array.get(boxStore, i))
            array.clear(boxStore)

        if array.size(labelStore) > 0
            for i = 0 to array.size(labelStore) - 1
                label.delete(array.get(labelStore, i))
            array.clear(labelStore)

        if enabled and not na(zoneTop) and not na(zoneBottom)
            int x1 = na(startBar) ? math.max(bar_index - 5, 0) : startBar
            int x2 = bar_index + projectionBars
            float top = math.max(zoneTop, zoneBottom)
            float bottom = math.min(zoneTop, zoneBottom)

            box z = box.new(x1, top, x2, bottom,
                 xloc = xloc.bar_index,
                 border_color = color.new(zoneColor, 24),
                 border_width = 1,
                 bgcolor = color.new(zoneColor, 90))

            string sz =
                 labelSize == "Auto" ? size.auto :
                 labelSize == "Tiny" ? size.tiny :
                 labelSize == "Normal" ? size.normal :
                 labelSize == "Large" ? size.large :
                 labelSize == "Huge" ? size.huge : size.small

            string txt = (zoneName == "" ? "ACTIVE ZONE" : zoneName) + "\n" +
                 str.tostring(bottom, format.mintick) + " – " +
                 str.tostring(top, format.mintick)

            label lb = label.new(x2, (top + bottom) * 0.5, txt,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = color.new(panelColor, 10),
                 textcolor = zoneColor,
                 size = sz,
                 tooltip = "Minimal Trader View · active Elliott/Fibonacci zone.\nDetailed Fib levels remain calculated and remain available in the panel / Balanced / Full Audit views.")

            array.push(boxStore, z)
            array.push(labelStore, lb)
    0

// ═════════════════════════════════════════════════════════════════════════════
// VIEW /2 · MINIMAL TRADER V2
// · one prioritized active-trade card
// · tiny endpoint tags instead of stacked full-price labels
// · compact 11-row trader panel
// Presentation only. No Elliott / Forecast / Trade / Runtime methodology.
// ═════════════════════════════════════════════════════════════════════════════

_size2(string value) =>
    value == "Auto" ? size.auto :
     value == "Tiny" ? size.tiny :
     value == "Normal" ? size.normal :
     value == "Large" ? size.large :
     value == "Huge" ? size.huge : size.small

_price2(float value) =>
    na(value) ? "—" : str.tostring(value, format.mintick)

_side2(int direction) =>
    direction == 1 ? "LONG" : direction == -1 ? "SHORT" : "NONE"

_degreeTag2(string degree) =>
    degree == "PRIMARY" ? "P" :
     degree == "SECONDARY" ? "S" :
     degree == "SUB-SECONDARY" ? "SS" :
     degree == "" ? "" : degree

_clearLinesLabels(array<line> lines, array<label> labels) =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)
    0

_preferredBridge(ewModel.TradeBridgePack b) =>
    ewModel.TradeSetup result = ewModel.TradeSetup.new()
    if not na(b)
        if not na(b.primary) and b.primary.active and b.primary.preferred
            result := b.primary
        else if not na(b.secondary) and b.secondary.active and b.secondary.preferred
            result := b.secondary
        else if not na(b.subSecondary) and b.subSecondary.active and b.subSecondary.preferred
            result := b.subSecondary
    result

_levelTag(array<line> lines, array<label> labels,
     int x1, int x2, float price, string tag,
     color lineColor, color panelColor, string labelSize, string lineKind) =>
    if not na(price)
        line_style = lineKind == "dotted" ? line.style_dotted : lineKind == "dashed" ? line.style_dashed : line.style_solid
        array.push(lines, line.new(x1, price, x2, price, xloc = xloc.bar_index,
             color = lineColor, width = tag == "E" ? 2 : 1, style = line_style))
        array.push(labels, label.new(x2, price, tag,
             xloc = xloc.bar_index, style = label.style_label_left,
             color = color.new(panelColor, 8), textcolor = lineColor,
             size = size.tiny,
             tooltip = tag + "  " + _price2(price)))
    0

// @function Minimal HTF bridge: show only the highest-priority preferred candidate.
// One card contains the setup; chart levels use tiny endpoint tags.
export drawHtfTradeCompact(array<line> lines, array<label> labels,
     bool enabled, string timeframeLabel, int projectionBars,
     ewModel.TradeBridgePack bridge,
     color bullColor, color bearColor, color targetColor,
     color stopColor, color panelColor, string labelSize) =>

    if barstate.islast
        _clearLinesLabels(lines, labels)
        ewModel.TradeSetup s = _preferredBridge(bridge)

        if enabled and s.active and s.preferred and s.direction != 0 and not na(s.entry)
            int x1 = bar_index
            int x2 = bar_index + math.max(projectionBars, 5)
            color dirColor = s.direction == 1 ? bullColor : bearColor
            string degreeTag = _degreeTag2(s.degree)
            string head = timeframeLabel + " " + degreeTag + " W" + str.tostring(s.wave) + " " +
                 _side2(s.direction) + " · ACTIVE" +
                 (na(s.rr) ? "" : " · " + str.tostring(s.rr, "#.00") + "R")

            string detail = "E " + _price2(s.entry) +
                 " · SL " + _price2(s.stop) +
                 "\nT1 " + _price2(s.tp1) +
                 (not na(s.tp2) ? " · T2 " + _price2(s.tp2) : "")

            array.push(labels, label.new(
                 bar_index, s.entry, head + "\n" + detail,
                 xloc = xloc.bar_index,
                 style = s.direction == 1 ? label.style_label_up : label.style_label_down,
                 color = color.new(dirColor, 8), textcolor = color.white,
                 size = _size2(labelSize),
                 tooltip = "Minimal Trader · higher-timeframe trade mirror.\n" +
                     "Native " + timeframeLabel + " Elliott structure owns this setup."))

            _levelTag(lines, labels, x1, x2, s.entry, "E", color.new(dirColor, 24), panelColor, labelSize, "dashed")
            _levelTag(lines, labels, x1, x2, s.stop, "SL", color.new(stopColor, 24), panelColor, labelSize, "solid")
            if not na(s.invalidation) and (na(s.stop) or math.abs(s.invalidation - s.stop) > syminfo.mintick)
                _levelTag(lines, labels, x1, x2, s.invalidation, "INV", color.new(stopColor, 52), panelColor, labelSize, "dotted")
            _levelTag(lines, labels, x1, x2, s.tp1, "T1", color.new(targetColor, 22), panelColor, labelSize, "dashed")
            _levelTag(lines, labels, x1, x2, s.tp2, "T2", color.new(targetColor, 42), panelColor, labelSize, "dotted")
    0

// @function Minimal native trade plan: one WAIT/ACTIVE card plus tiny level tags.
export drawTradePlanCompact(array<line> lines, array<label> labels,
     bool showLevels, bool waiting, bool live, int direction,
     int waitingBar, int activeBar, int projectionBars,
     string setupType, float rr,
     float confirmLevel, string gateText,
     float invalidationPlan, float target1Plan, float target2Plan,
     float entryPrice, float stopPrice, float tp1Price, float tp2Price,
     bool useTp2,
     color entryColor, color stopColor, color targetColor, color panelColor,
     string labelSize) =>

    if barstate.islast
        _clearLinesLabels(lines, labels)

        if showLevels and direction != 0 and (waiting or live)
            int x1 = waiting ? (na(waitingBar) ? bar_index : waitingBar) : (na(activeBar) ? bar_index : activeBar)
            int x2 = bar_index + math.max(projectionBars, 5)

            float mainLevel = waiting ? confirmLevel : entryPrice
            string stateText = live ? "ACTIVE" : "WAIT CONFIRM"
            string sideText = _side2(direction)
            string head = (setupType == "" ? "ELLIOTT TRADE" : setupType) + " " + sideText + " · " + stateText +
                 (not na(rr) ? " · " + str.tostring(rr, "#.00") + "R" : "")

            float cardStop = live ? stopPrice : invalidationPlan
            float cardT1 = live ? tp1Price : target1Plan
            float cardT2 = live ? tp2Price : target2Plan

            string detail =
                 (waiting ? (gateText == "" ? "TRIGGER " : gateText + " ") : "E ") + _price2(mainLevel) +
                 " · " + (live ? "SL " : "INV ") + _price2(cardStop) +
                 "\nT1 " + _price2(cardT1) +
                 (useTp2 and not na(cardT2) ? " · T2 " + _price2(cardT2) : "")

            if not na(mainLevel)
                array.push(labels, label.new(
                     bar_index, mainLevel, head + "\n" + detail,
                     xloc = xloc.bar_index,
                     style = direction == 1 ? label.style_label_up : label.style_label_down,
                     color = color.new(entryColor, 8), textcolor = color.white,
                     size = _size2(labelSize)))

            _levelTag(lines, labels, x1, x2, mainLevel, live ? "E" : "TRIG", color.new(entryColor, 12), panelColor, labelSize, "solid")
            _levelTag(lines, labels, x1, x2, cardStop, live ? "SL" : "INV", color.new(stopColor, 14), panelColor, labelSize, "solid")
            _levelTag(lines, labels, x1, x2, cardT1, "T1", color.new(targetColor, 18), panelColor, labelSize, "dashed")
            if useTp2
                _levelTag(lines, labels, x1, x2, cardT2, "T2", color.new(targetColor, 38), panelColor, labelSize, "dotted")
    0

_row2(table panel, int row, string key, string value, color valueColor, string textSize, color panelColor, color mutedColor) =>
    table.cell(panel, 0, row, key, bgcolor = panelColor, text_color = mutedColor,
         text_size = _size2(textSize), text_halign = text.align_left)
    table.cell(panel, 1, row, value, bgcolor = panelColor, text_color = valueColor,
         text_size = _size2(textSize), text_halign = text.align_right)

_band2(table panel, int row, string title, color titleColor, string textSize, color bandColor) =>
    table.cell(panel, 0, row, title, bgcolor = bandColor, text_color = titleColor,
         text_size = _size2(textSize), text_halign = text.align_left)
    table.cell(panel, 1, row, "", bgcolor = bandColor, text_size = _size2(textSize))

// @function Reduced Minimal-Trader information panel.
// Deep rules, guideline diagnostics and degree audit stay in Balanced/Full Audit.
export renderMinimalPanel(table panel,
     string bodySize, string headerSize, string footerSize,
     string symbolTf, string mtfText,
     string primaryText, color primaryColor,
     string currentPhaseText, color phaseColor,
     string forecastText, color forecastColor,
     string activeZoneText, color zoneColor,
     string invalidationText, color invalidationColor,
     bool nativeWaiting, bool nativeLive, int nativeDirection, string nativeSetupType, float nativeRr,
     float nativeEntry, float nativeStop, float nativeTp1, float nativeTp2,
     string htfTimeframe, ewModel.TradeBridgePack bridge,
     string nestedText, color nestedColor,
     string lastEvent,
     string auditStatus, color auditColor,
     color pendingColor, color mutedColor, color textColor,
     color panelColor, color bandColor, color bullColor, color bearColor, color targetColor) =>

    ewModel.TradeSetup htf = _preferredBridge(bridge)
    bool nativeBusy = nativeWaiting or nativeLive

    string tradeText = "NONE"
    string targetText = "—"
    color tradeColor = mutedColor

    if nativeBusy and nativeDirection != 0
        tradeText := (nativeSetupType == "" ? "ELLIOTT" : nativeSetupType) + " " +
             _side2(nativeDirection) + " · " + (nativeLive ? "ACTIVE" : "WAIT") +
             (not na(nativeRr) ? " · " + str.tostring(nativeRr, "#.00") + "R" : "")
        tradeColor := nativeDirection == 1 ? bullColor : bearColor
        targetText := "E " + _price2(nativeEntry) +
             " · SL " + _price2(nativeStop) +
             " · T1 " + _price2(nativeTp1) +
             (not na(nativeTp2) ? " · T2 " + _price2(nativeTp2) : "")
    else if htf.active and htf.preferred
        tradeText := htfTimeframe + " " + _degreeTag2(htf.degree) + " W" + str.tostring(htf.wave) + " " +
             _side2(htf.direction) + " · HTF · " + str.tostring(htf.rr, "#.00") + "R"
        tradeColor := htf.direction == 1 ? bullColor : bearColor
        targetText := "E " + _price2(htf.entry) +
             " · SL " + _price2(htf.stop) +
             " · T1 " + _price2(htf.tp1) +
             (not na(htf.tp2) ? " · T2 " + _price2(htf.tp2) : "")

    _band2(panel, 0, "ELLIOTT INFO · MINIMAL TRADER", pendingColor, headerSize, bandColor)
    _row2(panel, 1, "SYMBOL / TF", symbolTf, textColor, bodySize, panelColor, mutedColor)
    _row2(panel, 2, "MTF", mtfText, pendingColor, bodySize, panelColor, mutedColor)
    _row2(panel, 3, "PRIMARY", primaryText, primaryColor, bodySize, panelColor, mutedColor)
    _row2(panel, 4, "CURRENT PHASE", currentPhaseText, phaseColor, bodySize, panelColor, mutedColor)
    _row2(panel, 5, "POTENTIAL EW", forecastText, forecastColor, bodySize, panelColor, mutedColor)
    _row2(panel, 6, "ACTIVE ZONE", activeZoneText, zoneColor, bodySize, panelColor, mutedColor)
    _row2(panel, 7, "INVALIDATION", invalidationText, invalidationColor, bodySize, panelColor, mutedColor)
    _row2(panel, 8, "TRADE", tradeText, tradeColor, bodySize, panelColor, mutedColor)
    _row2(panel, 9, "E / SL / TARGETS", targetText, tradeColor == mutedColor ? targetColor : tradeColor, bodySize, panelColor, mutedColor)
    _row2(panel, 10, "NESTED EW", nestedText, nestedColor, bodySize, panelColor, mutedColor)
    _row2(panel, 11, "LAST EVENT", lastEvent, pendingColor, bodySize, panelColor, mutedColor)
    _band2(panel, 12, "AUDIT " + auditStatus, auditColor, footerSize, bandColor)
    0
````
