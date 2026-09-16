<!-- tradingview-pine-id: PUB;233147018fb849bc8a9d9d3be91b7edc -->
<!-- tradingview-pine-version: 2.0 -->
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
//@description Generic bar-time drawing primitives for Pine scripts. Creates, updates or deletes lines, labels and boxes from caller-supplied presentation facts. Contains no trading methodology or analytical authority.
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
````
