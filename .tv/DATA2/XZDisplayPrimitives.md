<!-- tradingview-pine-id: PUB;233147018fb849bc8a9d9d3be91b7edc -->
<!-- tradingview-pine-version: 8.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_Display_Primitives

Source: https://www.tradingview.com/script/LEI1ggDF-XZ-Display-Primitives/

## Description

Library  "XZ_Display_Primitives"
Generic bar-time drawing primitives for Pine scripts. Creates, updates or deletes lines, labels and boxes from caller-supplied presentation facts. Contains no trading methodology or analytical authority.

horizontalLine(id, visible, leftTime, rightTime, price, extendRight, lineColor, lineStyle, lineWidth)
  Creates, updates or deletes one horizontal bar-time line.
  Parameters:
    id (line): Existing line handle, or na.
    visible (bool): Whether the line should exist.
    leftTime (int): Left endpoint time.
    rightTime (int): Right endpoint time used when the line is finite and as the current anchor when projected.
    price (float): Horizontal price.
    extendRight (bool): True to project with extend.right, false for a finite segment.
    lineColor (color): Line color.
    lineStyle (string): Pine line style.
    lineWidth (int): Line width.
  Returns: Updated line handle, or na when hidden/invalid.

segmentLine(id, visible, firstTime, firstPrice, secondTime, secondPrice, lineColor, lineStyle, lineWidth)
  Creates, updates or deletes one finite bar-time line segment.
  Parameters:
    id (line): Existing line handle, or na.
    visible (bool): Whether the line should exist.
    firstTime (int): First endpoint time.
    firstPrice (float): First endpoint price.
    secondTime (int): Second endpoint time.
    secondPrice (float): Second endpoint price.
    lineColor (color): Line color.
    lineStyle (string): Pine line style.
    lineWidth (int): Line width.
  Returns: Updated line handle, or na when hidden/invalid.

priceLabel(id, visible, xTime, price, labelText, textColor, backgroundColor, labelStyle, labelSize, tooltipText, textAlign)
  Creates, updates or deletes one price-anchored bar-time label.
  Parameters:
    id (label): Existing label handle, or na.
    visible (bool): Whether the label should exist.
    xTime (int): Label time coordinate.
    price (float): Label price coordinate.
    labelText (string): Visible label text.
    textColor (color): Label text color.
    backgroundColor (color): Label background color.
    labelStyle (string): Pine label style.
    labelSize (string): Pine label size.
    tooltipText (string): Tooltip text.
    textAlign (string): Pine text alignment.
  Returns: Updated label handle, or na when hidden/invalid.

timeBox(id, visible, leftTime, rightTime, top, bottom, extendRight, fillColor, borderColor, borderStyle, borderWidth)
  Creates, updates or deletes one bar-time box.
  Parameters:
    id (box): Existing box handle, or na.
    visible (bool): Whether the box should exist.
    leftTime (int): Left box time.
    rightTime (int): Right box time used when finite and as the current anchor when projected.
    top (float): Top price.
    bottom (float): Bottom price.
    extendRight (bool): True to project with extend.right, false for finite geometry.
    fillColor (color): Box fill color. May be na.
    borderColor (color): Box border color. May be na.
    borderStyle (string): Pine line style for the border.
    borderWidth (int): Border width.
  Returns: Updated box handle, or na when hidden/invalid.

setBoxColors(id, fillColor, borderColor)
  Applies fill and border colors to an existing box without changing geometry.
  Parameters:
    id (box): Box handle.
    fillColor (color): New fill color.
    borderColor (color): New border color.
  Returns: True after the no-op or update.

setBoxBorderColor(id, borderColor)
  Applies only a border color to an existing box without changing geometry.
  Parameters:
    id (box): Box handle.
    borderColor (color): New border color.
  Returns: True after the no-op or update.

setLabelTextColor(id, textColor)
  Applies text color to an existing label without changing its geometry or text.
  Parameters:
    id (label): Label handle.
    textColor (color): New text color.
  Returns: True after the no-op or update.

clearBoxText(id)
  Clears box text without changing geometry or styling.
  Parameters:
    id (box): Box handle.
  Returns: True after the no-op or update.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign

//@version=6
//@description XZ Display Primitives v7. Generic bar-time drawing, object-pool, historical-registry restyling and contextual-muting primitives. Contains no trading methodology, event schema, lifecycle authority or analytical qualification.
library("XZ_Display_Primitives", true)

//@function Creates, updates or deletes one horizontal bar-time line.
//@param id Existing line handle, or na.
//@param visible Whether the line should exist.
//@param leftTime Left endpoint time.
//@param rightTime Right endpoint time used when the line is finite and as the current anchor when projected.
//@param price Horizontal price.
//@param extendRight True to project with extend.right, false for a finite segment.
//@param lineColor Line color.
//@param lineStyle Pine line style.
//@param lineWidth Line width.
//@returns Updated line handle, or na when hidden/invalid.
export horizontalLine(
     line id,
     bool visible,
     int leftTime,
     int rightTime,
     float price,
     bool extendRight,
     color lineColor,
     string lineStyle,
     int lineWidth
 ) =>
    line result = id
    bool valid = visible and not na(leftTime) and not na(rightTime) and not na(price)
    if valid
        string lineExtend = extendRight ? extend.right : extend.none
        if na(result)
            result := line.new(
                 x1=leftTime, y1=price, x2=rightTime, y2=price,
                 xloc=xloc.bar_time, extend=lineExtend,
                 color=lineColor, style=lineStyle, width=lineWidth
             )
        else
            line.set_xy1(result, leftTime, price)
            line.set_xy2(result, rightTime, price)
            line.set_extend(result, lineExtend)
            line.set_color(result, lineColor)
            line.set_style(result, lineStyle)
            line.set_width(result, lineWidth)
    else if not na(result)
        line.delete(result)
        result := na
    result

//@function Creates, updates or deletes one finite bar-time line segment.
//@param id Existing line handle, or na.
//@param visible Whether the line should exist.
//@param firstTime First endpoint time.
//@param firstPrice First endpoint price.
//@param secondTime Second endpoint time.
//@param secondPrice Second endpoint price.
//@param lineColor Line color.
//@param lineStyle Pine line style.
//@param lineWidth Line width.
//@returns Updated line handle, or na when hidden/invalid.
export segmentLine(
     line id,
     bool visible,
     int firstTime,
     float firstPrice,
     int secondTime,
     float secondPrice,
     color lineColor,
     string lineStyle,
     int lineWidth
 ) =>
    line result = id
    bool valid = visible and not na(firstTime) and not na(firstPrice) and not na(secondTime) and not na(secondPrice)
    if valid
        if na(result)
            result := line.new(
                 x1=firstTime, y1=firstPrice, x2=secondTime, y2=secondPrice,
                 xloc=xloc.bar_time, extend=extend.none,
                 color=lineColor, style=lineStyle, width=lineWidth
             )
        else
            line.set_xy1(result, firstTime, firstPrice)
            line.set_xy2(result, secondTime, secondPrice)
            line.set_extend(result, extend.none)
            line.set_color(result, lineColor)
            line.set_style(result, lineStyle)
            line.set_width(result, lineWidth)
    else if not na(result)
        line.delete(result)
        result := na
    result

//@function Creates, updates or deletes one price-anchored bar-time label.
//@param id Existing label handle, or na.
//@param visible Whether the label should exist.
//@param xTime Label time coordinate.
//@param price Label price coordinate.
//@param labelText Visible label text.
//@param textColor Label text color.
//@param backgroundColor Label background color.
//@param labelStyle Pine label style.
//@param labelSize Pine label size.
//@param tooltipText Tooltip text.
//@param textAlign Pine text alignment.
//@returns Updated label handle, or na when hidden/invalid.
export priceLabel(
     label id,
     bool visible,
     int xTime,
     float price,
     string labelText,
     color textColor,
     color backgroundColor,
     string labelStyle,
     string labelSize,
     string tooltipText,
     string textAlign
 ) =>
    label result = id
    bool valid = visible and not na(xTime) and not na(price)
    if valid
        if na(result)
            result := label.new(
                 x=xTime, y=price, text=labelText,
                 xloc=xloc.bar_time, yloc=yloc.price,
                 style=labelStyle, color=backgroundColor,
                 textcolor=textColor, size=labelSize,
                 textalign=textAlign, tooltip=tooltipText
             )
        else
            label.set_x(result, xTime)
            label.set_y(result, price)
            label.set_text(result, labelText)
            label.set_style(result, labelStyle)
            label.set_color(result, backgroundColor)
            label.set_textcolor(result, textColor)
            label.set_size(result, labelSize)
            label.set_textalign(result, textAlign)
            label.set_tooltip(result, tooltipText)
    else if not na(result)
        label.delete(result)
        result := na
    result

//@function Creates, updates or deletes one bar-time box.
//@param id Existing box handle, or na.
//@param visible Whether the box should exist.
//@param leftTime Left box time.
//@param rightTime Right box time used when finite and as the current anchor when projected.
//@param top Top price.
//@param bottom Bottom price.
//@param extendRight True to project with extend.right, false for finite geometry.
//@param fillColor Box fill color. May be na.
//@param borderColor Box border color. May be na.
//@param borderStyle Pine line style for the border.
//@param borderWidth Border width.
//@returns Updated box handle, or na when hidden/invalid.
export timeBox(
     box id,
     bool visible,
     int leftTime,
     int rightTime,
     float top,
     float bottom,
     bool extendRight,
     color fillColor,
     color borderColor,
     string borderStyle,
     int borderWidth
 ) =>
    box result = id
    bool valid = visible and not na(leftTime) and not na(rightTime) and not na(top) and not na(bottom)
    if valid
        int safeRight = math.max(rightTime, leftTime)
        string boxExtend = extendRight ? extend.right : extend.none
        if na(result)
            result := box.new(
                 left=leftTime, top=top, right=safeRight, bottom=bottom,
                 xloc=xloc.bar_time, extend=boxExtend,
                 bgcolor=fillColor, border_color=borderColor,
                 border_style=borderStyle, border_width=borderWidth
             )
        else
            box.set_left(result, leftTime)
            box.set_right(result, safeRight)
            box.set_top(result, top)
            box.set_bottom(result, bottom)
            box.set_extend(result, boxExtend)
            box.set_bgcolor(result, fillColor)
            box.set_border_color(result, borderColor)
            box.set_border_style(result, borderStyle)
            box.set_border_width(result, borderWidth)
    else if not na(result)
        box.delete(result)
        result := na
    result

//@function Applies fill and border colors to an existing box without changing geometry.
//@param id Box handle.
//@param fillColor New fill color.
//@param borderColor New border color.
//@returns True after the no-op or update.
export setBoxColors(box id, color fillColor, color borderColor) =>
    if not na(id)
        box.set_bgcolor(id, fillColor)
        box.set_border_color(id, borderColor)
    true

//@function Applies only a border color to an existing box without changing geometry.
//@param id Box handle.
//@param borderColor New border color.
//@returns True after the no-op or update.
export setBoxBorderColor(box id, color borderColor) =>
    if not na(id)
        box.set_border_color(id, borderColor)
    true

//@function Applies text color to an existing label without changing its geometry or text.
//@param id Label handle.
//@param textColor New text color.
//@returns True after the no-op or update.
export setLabelTextColor(label id, color textColor) =>
    if not na(id)
        label.set_textcolor(id, textColor)
    true

//@function Clears box text without changing geometry or styling.
//@param id Box handle.
//@returns True after the no-op or update.
export clearBoxText(box id) =>
    if not na(id)
        box.set_text(id, "")
    true

//@function Creates/updates a horizontal line whose right side is projected or finite.
export finiteOrProjectedHorizontalLine(
     line id, bool visible, int leftTime, int rightAnchorTime, int finiteRightTime,
     bool projectLive, float price, color lineColor, string lineStyle, int lineWidth
 ) =>
    int boundedRight = na(finiteRightTime) ? rightAnchorTime : math.max(finiteRightTime, rightAnchorTime)
    int x2 = projectLive ? rightAnchorTime : boundedRight
    horizontalLine(id, visible, leftTime, x2, price, projectLive, lineColor, lineStyle, lineWidth)

//@function Creates/updates a price label at the midpoint between two endpoints.
export midpointPriceLabel(
     label id, bool visible,
     int firstTime, float firstPrice, int secondTime, float secondPrice,
     string labelText, color textColor, color backgroundColor,
     string labelStyle, string labelSize, string tooltipText, string textAlign
 ) =>
    int midTime = not na(firstTime) and not na(secondTime) ? firstTime + int((secondTime - firstTime) / 2) : na
    float midPrice = not na(firstPrice) and not na(secondPrice) ? firstPrice + (secondPrice - firstPrice) * 0.5 : na
    priceLabel(id, visible, midTime, midPrice, labelText, textColor, backgroundColor, labelStyle, labelSize, tooltipText, textAlign)

//@function Updates one five-label 0/25/50/75/100 pool slot.
export fiveLevelPriceLabelPool(
     array<label> pool, int slot, bool visible, int rightTime,
     float q0, float q25, float q50, float q75, float q100,
     color textColor, color backgroundColor, string labelStyle, string labelSize, string textAlign
 ) =>
    int base = slot * 5
    for level = 0 to 4
        label id = array.get(pool, base + level)
        float price = level == 0 ? q0 : level == 1 ? q25 : level == 2 ? q50 : level == 3 ? q75 : q100
        string levelText = level == 0 ? "0%" : level == 1 ? "25%" : level == 2 ? "50%" : level == 3 ? "75%" : "100%"
        id := priceLabel(id, visible, rightTime, price, levelText, textColor, backgroundColor, labelStyle, labelSize, "", textAlign)
        array.set(pool, base + level, id)
    true

//@function Creates one above-bar/below-bar label.
export newBarRelativeLabel(
     int xTime, float price, string labelText, bool aboveBar,
     color textColor, string labelSize, string tooltipText
 ) =>
    label.new(
         x=xTime, y=price, text=labelText,
         xloc=xloc.bar_time, yloc=aboveBar ? yloc.abovebar : yloc.belowbar,
         style=label.style_none, color=color.new(textColor, 100),
         textcolor=textColor, size=labelSize, tooltip=tooltipText
     )

//@function Deletes every label in an array and clears the array.
export deleteLabelArray(array<label> ids) =>
    if array.size(ids) > 0
        for i = 0 to array.size(ids) - 1
            label.delete(array.get(ids, i))
        array.clear(ids)
    true

//@function Ensures a line-handle pool contains at least targetSize elements.
export ensureLinePool(array<line> pool, int targetSize) =>
    while array.size(pool) < targetSize
        array.push(pool, na)
    array.size(pool)

//@function Ensures a box-handle pool contains at least targetSize elements.
export ensureBoxPool(array<box> pool, int targetSize) =>
    while array.size(pool) < targetSize
        array.push(pool, na)
    array.size(pool)

//@function Ensures a label-handle pool contains at least targetSize elements.
export ensureLabelPool(array<label> pool, int targetSize) =>
    while array.size(pool) < targetSize
        array.push(pool, na)
    array.size(pool)

//@function Deletes every line in an array and clears the array.
export deleteLineArray(array<line> ids) =>
    if array.size(ids) > 0
        for i = 0 to array.size(ids) - 1
            line id = array.get(ids, i)
            if not na(id)
                line.delete(id)
        array.clear(ids)
    true

//@function Deletes every box in an array and clears the array.
export deleteBoxArray(array<box> ids) =>
    if array.size(ids) > 0
        for i = 0 to array.size(ids) - 1
            box id = array.get(ids, i)
            if not na(id)
                box.delete(id)
        array.clear(ids)
    true

//==============================================================================
// GENERIC PRESENTATION STATE / FORENSIC HELPERS
//==============================================================================

//@function Resolves the common XZ label-size selector.
export resolveLabelSize(string key) =>
    switch key
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

//@function Resolves Solid/Dashed/Dotted into a Pine line style.
export resolveLineStyle(string key) =>
    key == "Dashed" ? line.style_dashed : key == "Dotted" ? line.style_dotted : line.style_solid

//@function Registers a historical label plus caller-owned parallel metadata and enforces a bounded label count.
export registerHistoricalLabel(
     array<label> ids, array<int> detailSequences, array<int> horizonBars,
     array<int> confirmTimes, array<string> originalTexts,
     label id, int detailSequence, int horizonBar, int confirmTime, int limit
 ) =>
    if not na(id)
        array.push(ids, id)
        array.push(detailSequences, detailSequence)
        array.push(horizonBars, horizonBar)
        array.push(confirmTimes, confirmTime)
        array.push(originalTexts, label.get_text(id))
        while array.size(ids) > limit
            label old = array.shift(ids)
            array.shift(detailSequences)
            array.shift(horizonBars)
            array.shift(confirmTimes)
            array.shift(originalTexts)
            if not na(old)
                label.delete(old)
    true

//@function Registers a historical line plus caller-owned parallel metadata and enforces a bounded line count.
export registerHistoricalLine(
     array<line> ids, array<int> detailSequences, array<int> horizonBars,
     array<int> confirmTimes, array<color> originalColors,
     line id, color originalColor, int detailSequence, int horizonBar, int confirmTime, int limit
 ) =>
    if not na(id)
        array.push(ids, id)
        array.push(detailSequences, detailSequence)
        array.push(horizonBars, horizonBar)
        array.push(confirmTimes, confirmTime)
        array.push(originalColors, originalColor)
        while array.size(ids) > limit
            line old = array.shift(ids)
            array.shift(detailSequences)
            array.shift(horizonBars)
            array.shift(confirmTimes)
            array.shift(originalColors)
            if not na(old)
                line.delete(old)
    true

//@function Registers a historical box plus caller-owned parallel metadata and enforces a bounded box count.
export registerHistoricalBox(
     array<box> ids, array<int> detailSequences, array<int> horizonBars,
     array<int> confirmTimes, array<color> originalColors,
     box id, color originalColor, int detailSequence, int horizonBar, int confirmTime, int limit
 ) =>
    if not na(id)
        array.push(ids, id)
        array.push(detailSequences, detailSequence)
        array.push(horizonBars, horizonBar)
        array.push(confirmTimes, confirmTime)
        array.push(originalColors, originalColor)
        while array.size(ids) > limit
            box old = array.shift(ids)
            array.shift(detailSequences)
            array.shift(horizonBars)
            array.shift(confirmTimes)
            array.shift(originalColors)
            if not na(old)
                box.delete(old)
    true

//@function Removes one registered historical label and matching parallel metadata.
export deleteHistoricalLabel(
     array<label> ids, array<int> detailSequences, array<int> horizonBars,
     array<int> confirmTimes, array<string> originalTexts, label id
 ) =>
    if not na(id)
        int idx = array.indexof(ids, id)
        if idx >= 0
            array.remove(ids, idx)
            array.remove(detailSequences, idx)
            array.remove(horizonBars, idx)
            array.remove(confirmTimes, idx)
            array.remove(originalTexts, idx)
        label.delete(id)
    true

//@function Retrieves the original text stored for a registered label.
export historicalLabelText(array<label> ids, array<string> originalTexts, label id) =>
    string result = ""
    if not na(id)
        int idx = array.indexof(ids, id)
        if idx >= 0
            result := array.get(originalTexts, idx)
    result

//@function Restores semantic label presentation without changing geometry or tooltip.
export restoreSemanticLabel(label id, string originalText, color semanticColor, bool textOnly, string labelSize) =>
    if not na(id)
        if str.length(originalText) > 0
            label.set_text(id, originalText)
        label.set_textcolor(id, textOnly ? semanticColor : color.white)
        label.set_color(id, textOnly ? color.new(semanticColor, 100) : semanticColor)
        label.set_size(id, labelSize)
    true

//@function Applies a quiet contextual mute to a label without changing geometry or text.
export muteLabel(label id, int textTransparency, int backgroundTransparency) =>
    if not na(id)
        label.set_textcolor(id, color.new(color.white, textTransparency))
        label.set_color(id, color.new(color.black, backgroundTransparency))
    true

//@function Applies a transparency-only contextual mute to a line.
export muteLine(line id, color baseColor, int transparency) =>
    if not na(id)
        line.set_color(id, color.new(baseColor, transparency))
    true

//@function Applies a minimum transparency contextual mute to a box fill and border.
export muteBox(box id, color baseColor, int minimumTransparency) =>
    if not na(id)
        int mutedTransparency = int(math.max(color.t(baseColor), float(minimumTransparency)))
        color muted = color.new(baseColor, mutedTransparency)
        box.set_border_color(id, muted)
        box.set_bgcolor(id, muted)
    true

//@function Sets one line color without changing geometry.
export setLineColor(line id, color lineColor) =>
    if not na(id)
        line.set_color(id, lineColor)
    true

//==============================================================================
// v5 GENERIC FOCUSED-STYLE RESOLUTION
//==============================================================================

//@function Resolves a shared string override only when the caller-selected family is focused and the override is not the inherit token.
export focusedString(bool focused, string overrideValue, string nativeValue, string inheritToken) =>
    focused and overrideValue != inheritToken ? overrideValue : nativeValue

//@function Resolves a positive integer override only when the caller-selected family is focused; non-positive override values inherit the native value.
export focusedPositiveInt(bool focused, int overrideValue, int nativeValue) =>
    focused and overrideValue > 0 ? overrideValue : nativeValue

//@function Parses the standard Native/1/2/3/4 width selector. Native returns zero so callers can inherit their family default.
export parseWidth(string key) =>
    key == "1" ? 1 : key == "2" ? 2 : key == "3" ? 3 : key == "4" ? 4 : 0

//@function Resolves an override/native family colour and applies caller-supplied transparency. Unified applies the override to every family; focused applies it only to the selected family.
export familyColor(bool unified, bool focused, color overrideColor, color nativeColor, int transparency) =>
    color.new(unified or focused ? overrideColor : nativeColor, transparency)

//@function Resolves an integer presentation override behind an explicit enable switch for one focused family.
export focusedInt(bool focused, bool overrideEnabled, int overrideValue, int nativeValue) =>
    focused and overrideEnabled ? overrideValue : nativeValue

//==============================================================================
// v6 GENERIC HISTORICAL-REGISTRY PRESENTATION
//==============================================================================

_insideHistoricalScope(int confirmationBar, int confirmTime, bool allHistory, int horizonStartBar, bool useManualStart, int manualStartTime) =>
    bool insideHorizon = allHistory or confirmationBar >= horizonStartBar
    bool insideManual = not useManualStart or (not na(confirmTime) and confirmTime >= manualStartTime)
    insideHorizon and insideManual

//@function Fully suppresses one label without deleting its handle or changing its geometry/tooltip.
export suppressLabel(label id) =>
    if not na(id)
        label.set_text(id, "")
        label.set_color(id, color.new(color.black, 100))
        label.set_textcolor(id, color.new(color.white, 100))
    true

//@function Fully suppresses every non-na label in an array without deleting handles.
export suppressLabelArray(array<label> ids) =>
    if array.size(ids) > 0
        for i = 0 to array.size(ids) - 1
            suppressLabel(array.get(ids, i))
    true

//@function Applies caller-supplied text and size to one existing label without changing geometry, colors or tooltip.
export setLabelTextSize(label id, string labelText, string labelSize) =>
    if not na(id)
        label.set_text(id, labelText)
        label.set_size(id, labelSize)
    true

//@function Restyles caller-owned historical line/box registries for temporal scope, older-history fade and Current-only suppression. All analytical meaning is resolved by the caller before invocation.
export restyleHistoricalLinesBoxes(
     array<line> lineIds, array<int> lineDetailSequences, array<int> lineHorizonBars, array<int> lineConfirmTimes, array<color> lineColors,
     array<box> boxIds, array<int> boxDetailSequences, array<int> boxHorizonBars, array<int> boxConfirmTimes, array<color> boxColors,
     int eventCountNow, int recentDetailEvents, bool currentOnly,
     bool allHistory, int horizonStartBar, bool useManualStart, int manualStartTime,
     string olderHistoryMode, int olderHistoryFade
 ) =>
    int oldThreshold = math.max(eventCountNow - recentDetailEvents, 0)

    if array.size(lineIds) > 0
        for i = 0 to array.size(lineIds) - 1
            line id = array.get(lineIds, i)
            if not na(id)
                color baseColor = array.get(lineColors, i)
                if currentOnly
                    line.set_color(id, color.new(baseColor, 100))
                else
                    bool isOlder = array.get(lineDetailSequences, i) <= oldThreshold and eventCountNow > recentDetailEvents
                    bool insideScope = _insideHistoricalScope(array.get(lineHorizonBars, i), array.get(lineConfirmTimes, i), allHistory, horizonStartBar, useManualStart, manualStartTime)
                    if not insideScope
                        line.set_color(id, color.new(baseColor, 100))
                    else if isOlder
                        int fade = olderHistoryMode == "Hidden" ? 100 : int(math.max(color.t(baseColor), float(olderHistoryFade)))
                        line.set_color(id, color.new(baseColor, fade))
                    else
                        line.set_color(id, baseColor)

    if array.size(boxIds) > 0
        for i = 0 to array.size(boxIds) - 1
            box id = array.get(boxIds, i)
            if not na(id)
                color baseColor = array.get(boxColors, i)
                if currentOnly
                    color hiddenColor = color.new(baseColor, 100)
                    box.set_border_color(id, hiddenColor)
                    box.set_bgcolor(id, hiddenColor)
                else
                    bool isOlder = array.get(boxDetailSequences, i) <= oldThreshold and eventCountNow > recentDetailEvents
                    bool insideScope = _insideHistoricalScope(array.get(boxHorizonBars, i), array.get(boxConfirmTimes, i), allHistory, horizonStartBar, useManualStart, manualStartTime)
                    if not insideScope
                        color hiddenColor = color.new(baseColor, 100)
                        box.set_border_color(id, hiddenColor)
                        box.set_bgcolor(id, hiddenColor)
                    else if isOlder
                        int fade = olderHistoryMode == "Hidden" ? 100 : int(math.max(color.t(baseColor), float(olderHistoryFade)))
                        color fadedColor = color.new(baseColor, fade)
                        box.set_border_color(id, fadedColor)
                        box.set_bgcolor(id, fadedColor)
                    else
                        box.set_border_color(id, baseColor)
                        box.set_bgcolor(id, baseColor)
    true

//@function Contextually mutes only historical objects that are presently visible under caller-supplied temporal/detail scope. It never determines analytical relevance or focus membership.
export muteHistoricalRegistries(
     array<label> labelIds, array<int> labelDetailSequences, array<int> labelHorizonBars, array<int> labelConfirmTimes,
     array<line> lineIds, array<int> lineDetailSequences, array<int> lineHorizonBars, array<int> lineConfirmTimes, array<color> lineColors,
     array<box> boxIds, array<int> boxDetailSequences, array<int> boxHorizonBars, array<int> boxConfirmTimes, array<color> boxColors,
     int eventCountNow, int recentDetailEvents, bool currentOnly,
     bool allHistory, int horizonStartBar, bool useManualStart, int manualStartTime,
     string olderHistoryMode,
     int labelTextTransparency, int labelBackgroundTransparency, int lineTransparency, int boxTransparency
 ) =>
    int oldThreshold = math.max(eventCountNow - recentDetailEvents, 0)

    if not currentOnly and array.size(labelIds) > 0
        for i = 0 to array.size(labelIds) - 1
            label id = array.get(labelIds, i)
            if not na(id)
                bool isOlder = array.get(labelDetailSequences, i) <= oldThreshold and eventCountNow > recentDetailEvents
                bool visibleByScope = _insideHistoricalScope(array.get(labelHorizonBars, i), array.get(labelConfirmTimes, i), allHistory, horizonStartBar, useManualStart, manualStartTime) and not (isOlder and olderHistoryMode == "Hidden")
                if visibleByScope
                    muteLabel(id, labelTextTransparency, labelBackgroundTransparency)

    if not currentOnly and array.size(lineIds) > 0
        for i = 0 to array.size(lineIds) - 1
            line id = array.get(lineIds, i)
            if not na(id)
                bool isOlder = array.get(lineDetailSequences, i) <= oldThreshold and eventCountNow > recentDetailEvents
                bool visibleByScope = _insideHistoricalScope(array.get(lineHorizonBars, i), array.get(lineConfirmTimes, i), allHistory, horizonStartBar, useManualStart, manualStartTime) and not (isOlder and olderHistoryMode == "Hidden")
                if visibleByScope
                    muteLine(id, array.get(lineColors, i), lineTransparency)

    if not currentOnly and array.size(boxIds) > 0
        for i = 0 to array.size(boxIds) - 1
            box id = array.get(boxIds, i)
            if not na(id)
                bool isOlder = array.get(boxDetailSequences, i) <= oldThreshold and eventCountNow > recentDetailEvents
                bool visibleByScope = _insideHistoricalScope(array.get(boxHorizonBars, i), array.get(boxConfirmTimes, i), allHistory, horizonStartBar, useManualStart, manualStartTime) and not (isOlder and olderHistoryMode == "Hidden")
                if visibleByScope
                    muteBox(id, array.get(boxColors, i), boxTransparency)
    true

//==============================================================================
// v7 GENERIC HISTORICAL REGISTRY STATE
//==============================================================================

//@type Bundles generic historical drawing handles and caller-supplied presentation metadata.
// The registry stores no analytical meaning. Callers decide all text, classes, colours, admission,
// ordering and semantic compact forms before registration.
export type HistoricalRegistry
    array<label> label_ids
    array<int> label_detail_sequences
    array<int> label_horizon_bars
    array<int> label_confirm_times
    array<string> label_original_texts
    array<string> label_compact_texts
    array<line> line_ids
    array<int> line_detail_sequences
    array<int> line_horizon_bars
    array<int> line_confirm_times
    array<color> line_colors
    array<box> box_ids
    array<int> box_detail_sequences
    array<int> box_horizon_bars
    array<int> box_confirm_times
    array<color> box_colors

//@function Creates an empty generic historical drawing registry.
export newHistoricalRegistry() =>
    HistoricalRegistry.new(
         array.new<label>(), array.new_int(), array.new_int(), array.new_int(), array.new_string(), array.new_string(),
         array.new<line>(), array.new_int(), array.new_int(), array.new_int(), array.new_color(),
         array.new<box>(), array.new_int(), array.new_int(), array.new_int(), array.new_color())

//@function True when a label ID is still retained by the generic historical registry.
export registryHasLabel(HistoricalRegistry state, label id) =>
    not na(id) and array.indexof(state.label_ids, id) >= 0

//@function True when a line ID is still retained by the generic historical registry.
export registryHasLine(HistoricalRegistry state, line id) =>
    not na(id) and array.indexof(state.line_ids, id) >= 0

//@function True when a box ID is still retained by the generic historical registry.
export registryHasBox(HistoricalRegistry state, box id) =>
    not na(id) and array.indexof(state.box_ids, id) >= 0

//@function Number of retained labels in a generic historical registry.
export registryLabelCount(HistoricalRegistry state) => array.size(state.label_ids)

//@function Number of retained lines in a generic historical registry.
export registryLineCount(HistoricalRegistry state) => array.size(state.line_ids)

//@function Number of retained boxes in a generic historical registry.
export registryBoxCount(HistoricalRegistry state) => array.size(state.box_ids)

//@function Registers a label with caller-resolved original/compact text and enforces a bounded count.
export registerRegistryLabel(HistoricalRegistry state, label id, int detailSequence, int horizonBar, int confirmTime, string compactText, int limit) =>
    if not na(id)
        array.push(state.label_ids, id)
        array.push(state.label_detail_sequences, detailSequence)
        array.push(state.label_horizon_bars, horizonBar)
        array.push(state.label_confirm_times, confirmTime)
        array.push(state.label_original_texts, label.get_text(id))
        array.push(state.label_compact_texts, compactText)
        while array.size(state.label_ids) > limit
            label old = array.shift(state.label_ids)
            array.shift(state.label_detail_sequences)
            array.shift(state.label_horizon_bars)
            array.shift(state.label_confirm_times)
            array.shift(state.label_original_texts)
            array.shift(state.label_compact_texts)
            if not na(old)
                label.delete(old)
    true

//@function Registers a line with caller-resolved colour and enforces a bounded count.
export registerRegistryLine(HistoricalRegistry state, line id, color originalColor, int detailSequence, int horizonBar, int confirmTime, int limit) =>
    registerHistoricalLine(state.line_ids, state.line_detail_sequences, state.line_horizon_bars, state.line_confirm_times, state.line_colors, id, originalColor, detailSequence, horizonBar, confirmTime, limit)

//@function Registers a box with caller-resolved colour and enforces a bounded count.
export registerRegistryBox(HistoricalRegistry state, box id, color originalColor, int detailSequence, int horizonBar, int confirmTime, int limit) =>
    registerHistoricalBox(state.box_ids, state.box_detail_sequences, state.box_horizon_bars, state.box_confirm_times, state.box_colors, id, originalColor, detailSequence, horizonBar, confirmTime, limit)

//@function Removes one label and matching registry metadata.
export deleteRegistryLabel(HistoricalRegistry state, label id) =>
    if not na(id)
        int idx = array.indexof(state.label_ids, id)
        if idx >= 0
            array.remove(state.label_ids, idx)
            array.remove(state.label_detail_sequences, idx)
            array.remove(state.label_horizon_bars, idx)
            array.remove(state.label_confirm_times, idx)
            array.remove(state.label_original_texts, idx)
            array.remove(state.label_compact_texts, idx)
        label.delete(id)
    true

//@function Retrieves caller-supplied original text for one retained label.
export registryOriginalLabelText(HistoricalRegistry state, label id) =>
    historicalLabelText(state.label_ids, state.label_original_texts, id)

//@function True when any registry family most recently admitted an object on the supplied horizon bar.
export registryMutatedOnBar(HistoricalRegistry state, int horizonBar) =>
    bool labelMutation = array.size(state.label_horizon_bars) > 0 and array.get(state.label_horizon_bars, array.size(state.label_horizon_bars) - 1) == horizonBar
    bool lineMutation = array.size(state.line_horizon_bars) > 0 and array.get(state.line_horizon_bars, array.size(state.line_horizon_bars) - 1) == horizonBar
    bool boxMutation = array.size(state.box_horizon_bars) > 0 and array.get(state.box_horizon_bars, array.size(state.box_horizon_bars) - 1) == horizonBar
    labelMutation or lineMutation or boxMutation

//@function Applies temporal/detail presentation to all three drawing families. Compact label text is caller supplied at registration; no semantic transformation occurs here.
export restyleRegistry(
     HistoricalRegistry state,
     int eventCountNow, int recentDetailEvents, bool currentOnly,
     bool allHistory, int horizonStartBar, bool useManualStart, int manualStartTime,
     string olderHistoryMode, int olderHistoryFade
 ) =>
    int oldThreshold = math.max(eventCountNow - recentDetailEvents, 0)

    if currentOnly
        suppressLabelArray(state.label_ids)
    else if array.size(state.label_ids) > 0
        for i = 0 to array.size(state.label_ids) - 1
            label id = array.get(state.label_ids, i)
            if not na(id)
                bool isOlder = array.get(state.label_detail_sequences, i) <= oldThreshold and eventCountNow > recentDetailEvents
                bool insideScope = _insideHistoricalScope(array.get(state.label_horizon_bars, i), array.get(state.label_confirm_times, i), allHistory, horizonStartBar, useManualStart, manualStartTime)
                if not insideScope or (isOlder and olderHistoryMode == "Hidden")
                    suppressLabel(id)
                else if isOlder
                    setLabelTextSize(id, array.get(state.label_compact_texts, i), size.small)

    restyleHistoricalLinesBoxes(
         state.line_ids, state.line_detail_sequences, state.line_horizon_bars, state.line_confirm_times, state.line_colors,
         state.box_ids, state.box_detail_sequences, state.box_horizon_bars, state.box_confirm_times, state.box_colors,
         eventCountNow, recentDetailEvents, currentOnly,
         allHistory, horizonStartBar, useManualStart, manualStartTime,
         olderHistoryMode, olderHistoryFade)
    true

//@function Applies generic contextual muting across a bundled historical registry.
export muteRegistry(
     HistoricalRegistry state,
     int eventCountNow, int recentDetailEvents, bool currentOnly,
     bool allHistory, int horizonStartBar, bool useManualStart, int manualStartTime,
     string olderHistoryMode,
     int labelTextTransparency, int labelBackgroundTransparency, int lineTransparency, int boxTransparency
 ) =>
    muteHistoricalRegistries(
         state.label_ids, state.label_detail_sequences, state.label_horizon_bars, state.label_confirm_times,
         state.line_ids, state.line_detail_sequences, state.line_horizon_bars, state.line_confirm_times, state.line_colors,
         state.box_ids, state.box_detail_sequences, state.box_horizon_bars, state.box_confirm_times, state.box_colors,
         eventCountNow, recentDetailEvents, currentOnly,
         allHistory, horizonStartBar, useManualStart, manualStartTime,
         olderHistoryMode,
         labelTextTransparency, labelBackgroundTransparency, lineTransparency, boxTransparency)
    true
````
