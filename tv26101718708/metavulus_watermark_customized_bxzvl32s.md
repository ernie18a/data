# Metavulus Watermark Customized

- url: https://www.tradingview.com/script/BXZvl32S-Metavulus-Watermark-Customized/
- type: indicator
- pine_id: PUB;610fef7c31304ca1a61c45f44c1be16d
- version: 1.0

## Description

A fully customizable TradingView overlay indicator built with Pine Script v6.

This indicator allows traders to create clean, professional-looking chart layouts with fully editable text sections and branding elements directly on the chart.

Features include:

• Editable header and subheader text  
• Custom middle watermark/background text  
• Footer text customization  
• Symbol, timeframe, and date display support  
• Independent control for:
  - Positioning
  - Alignment
  - Text size
  - Colors
  - Backgrounds

Designed for traders, educators, content creators, and analysts who want premium chart presentation aesthetics for screenshots, social media, reports, or personal workflow setups.

Built using Pine Script v6 to leverage the latest TradingView scripting capabilities and maintain compatibility with current TradingView documentation and future updates.

Open-source under the Mozilla Public License 2.0 (MPL 2.0).

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) Metavulus

//@version=6
indicator("Metavulus Watermark Customized", shorttitle = "Metavulus Watermark", overlay = true)
// Metavulus Watermark Customized
// A flexible, open-source watermark overlay for TradingView charts.
const string GROUP_HEADER = "Header"
const string GROUP_MIDDLE = "Middle Background Text"
const string GROUP_FOOTER = "Footer"
const string GROUP_MARKET = "Symbol / Date Info"
const string GROUP_LAYOUT = "Global Layout"
// Global layout.
cellWidth = input.int(0, "Cell Width", minval = 0, maxval = 100, tooltip = "Width as a percentage of the indicator visual space. Use 0 for automatic width.", group = GROUP_LAYOUT)
cellHeight = input.int(0, "Cell Height", minval = 0, maxval = 100, tooltip = "Height as a percentage of the indicator visual space. Use 0 for automatic height.", group = GROUP_LAYOUT)
// Header controls.
showHeader = input.bool(true, "Show Header", group = GROUP_HEADER)
headerText = input.string("METAVULUS", "Header Text", group = GROUP_HEADER)
subHeaderText = input.string("TRADING OPERATING SYSTEM", "Subheader Text", group = GROUP_HEADER)
headerVPosition = input.string("Top", "Vertical Position", options = ["Top", "Middle", "Bottom"], group = GROUP_HEADER)
headerHPosition = input.string("Center", "Horizontal Position", options = ["Left", "Center", "Right"], group = GROUP_HEADER)
headerTextColor = input.color(color.new(color.black, 0), "Header Color", group = GROUP_HEADER)
headerSize = input.string("Huge", "Header Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = GROUP_HEADER)
headerAlign = input.string("Center", "Header Alignment", options = ["Left", "Center", "Right"], group = GROUP_HEADER)
subHeaderTextColor = input.color(color.new(color.black, 35), "Subheader Color", group = GROUP_HEADER)
subHeaderSize = input.string("Normal", "Subheader Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = GROUP_HEADER)
headerBgColor = input.color(color.new(color.white, 100), "Header Background", group = GROUP_HEADER)
// Middle watermark controls.
showMiddleText = input.bool(true, "Show Middle Text", group = GROUP_MIDDLE)
middleText = input.text_area("METAVULUS", "Middle Text", group = GROUP_MIDDLE)
middleVPosition = input.string("Middle", "Vertical Position", options = ["Top", "Middle", "Bottom"], group = GROUP_MIDDLE)
middleHPosition = input.string("Center", "Horizontal Position", options = ["Left", "Center", "Right"], group = GROUP_MIDDLE)
middleTextColor = input.color(color.new(color.black, 86), "Middle Text Color", group = GROUP_MIDDLE)
middleSize = input.string("Huge", "Middle Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = GROUP_MIDDLE)
middleAlign = input.string("Center", "Middle Alignment", options = ["Left", "Center", "Right"], group = GROUP_MIDDLE)
middleBgColor = input.color(color.new(color.white, 100), "Middle Background", group = GROUP_MIDDLE)
middleFrameColor = input.color(color.new(color.black, 100), "Middle Frame Color", group = GROUP_MIDDLE)
middleFrameWidth = input.int(0, "Middle Frame Width", minval = 0, maxval = 5, group = GROUP_MIDDLE)
// Footer controls.
showFooter = input.bool(true, "Show Footer", group = GROUP_FOOTER)
footerText = input.string("PATIENCE  |  DISCIPLINE  |  EXECUTION", "Footer Text", group = GROUP_FOOTER)
footerVPosition = input.string("Bottom", "Vertical Position", options = ["Top", "Middle", "Bottom"], group = GROUP_FOOTER)
footerHPosition = input.string("Center", "Horizontal Position", options = ["Left", "Center", "Right"], group = GROUP_FOOTER)
footerTextColor = input.color(color.new(color.black, 35), "Footer Color", group = GROUP_FOOTER)
footerSize = input.string("Normal", "Footer Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = GROUP_FOOTER)
footerAlign = input.string("Center", "Footer Alignment", options = ["Left", "Center", "Right"], group = GROUP_FOOTER)
footerBgColor = input.color(color.new(color.white, 100), "Footer Background", group = GROUP_FOOTER)
// Symbol/date controls.
showMarketInfo = input.bool(true, "Show Symbol Info", group = GROUP_MARKET)
showDate = input.bool(true, "Show Date", group = GROUP_MARKET)
marketInfoPrefix = input.string("", "Symbol Prefix", tooltip = "Optional text before the symbol/timeframe line.", group = GROUP_MARKET)
marketVPosition = input.string("Bottom", "Vertical Position", options = ["Top", "Middle", "Bottom"], group = GROUP_MARKET)
marketHPosition = input.string("Right", "Horizontal Position", options = ["Left", "Center", "Right"], group = GROUP_MARKET)
marketTextColor = input.color(color.new(color.black, 35), "Symbol / Date Color", group = GROUP_MARKET)
marketSize = input.string("Small", "Symbol / Date Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], group = GROUP_MARKET)
marketAlign = input.string("Right", "Symbol / Date Alignment", options = ["Left", "Center", "Right"], group = GROUP_MARKET)
marketBgColor = input.color(color.new(color.white, 100), "Symbol / Date Background", group = GROUP_MARKET)
sizeFromInput(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.auto
alignFromInput(string value) =>
    switch value
        "Left" => text.align_left
        "Right" => text.align_right
        => text.align_center
positionFromInput(string vertical, string horizontal) =>
    switch vertical + "_" + horizontal
        "Top_Left" => position.top_left
        "Top_Center" => position.top_center
        "Top_Right" => position.top_right
        "Middle_Left" => position.middle_left
        "Middle_Center" => position.middle_center
        "Middle_Right" => position.middle_right
        "Bottom_Left" => position.bottom_left
        "Bottom_Center" => position.bottom_center
        => position.bottom_right
pad2(int value) =>
    value < 10 ? "0" + str.tostring(value) : str.tostring(value)
formatDate(int timestamp) =>
    str.tostring(year(timestamp)) + "-" + pad2(month(timestamp)) + "-" + pad2(dayofmonth(timestamp))
formatTimeframe() =>
    timeframe.isminutes ? timeframe.period + "m" : timeframe.period
dateSource() =>
    na(time_close) ? time : time_close
prefixedMarketInfo() =>
    string line = syminfo.ticker + " | " + formatTimeframe()
    marketInfoPrefix == "" ? line : marketInfoPrefix + " " + line
var table headerTable = table.new(positionFromInput(headerVPosition, headerHPosition), 1, 2)
var table middleTable = table.new(positionFromInput(middleVPosition, middleHPosition), 1, 1, frame_color = middleFrameColor, frame_width = middleFrameWidth)
var table footerTable = table.new(positionFromInput(footerVPosition, footerHPosition), 1, 1)
var table marketTable = table.new(positionFromInput(marketVPosition, marketHPosition), 1, 2)
if barstate.islast
    table.cell(headerTable, 0, 0, showHeader ? headerText : "", width = cellWidth, height = cellHeight, text_color = headerTextColor, text_halign = alignFromInput(headerAlign), text_size = sizeFromInput(headerSize), bgcolor = headerBgColor)
    table.cell(headerTable, 0, 1, showHeader ? subHeaderText : "", width = cellWidth, height = cellHeight, text_color = subHeaderTextColor, text_halign = alignFromInput(headerAlign), text_size = sizeFromInput(subHeaderSize), bgcolor = headerBgColor)
    table.cell(middleTable, 0, 0, showMiddleText ? middleText : "", width = cellWidth, height = cellHeight, text_color = middleTextColor, text_halign = alignFromInput(middleAlign), text_size = sizeFromInput(middleSize), bgcolor = middleBgColor)
    table.cell(footerTable, 0, 0, showFooter ? footerText : "", width = cellWidth, height = cellHeight, text_color = footerTextColor, text_halign = alignFromInput(footerAlign), text_size = sizeFromInput(footerSize), bgcolor = footerBgColor)
    table.cell(marketTable, 0, 0, showDate ? formatDate(dateSource()) : "", width = cellWidth, height = cellHeight, text_color = marketTextColor, text_halign = alignFromInput(marketAlign), text_size = sizeFromInput(marketSize), bgcolor = marketBgColor)
    table.cell(marketTable, 0, 1, showMarketInfo ? prefixedMarketInfo() : "", width = cellWidth, height = cellHeight, text_color = marketTextColor, text_halign = alignFromInput(marketAlign), text_size = sizeFromInput(marketSize), bgcolor = marketBgColor)
````
