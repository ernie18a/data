# Watermark(by JH-Trades)

- url: https://www.tradingview.com/script/N5V4EnkY-Watermark-by-JH-Trades/
- type: indicator
- pine_id: PUB;41687bdd31934f849ae0f76af0a0c3f0
- version: 1.0

## Description

put your own information as a watermark. Updated to v6

## Source Code

````pine
//@version=6
indicator(title = "Watermark(by JH-Trades)", overlay = true)

//========= TEXT INPUTS =========//
titleText    = input.string("by JH-Trades", "Title", group = "Text")
subtitleText = input.string("", "Subtitle", group = "Text")

//========= SYMBOL INFO =========//
symInfoCheck = input.bool(true, "Show Symbol Info", group = "Watermark position")

symInfo = syminfo.ticker + " | " + timeframe.period + (timeframe.isminutes ? "M" : "")
dateStr = str.format("{0}/{1}/{2}", dayofmonth(time_close), month(time_close), year(time_close))

//========= TEXT POSITION =========//
textVPosition = input.string("middle", "Vertical Position", options = ["top", "middle", "bottom"], group = "Watermark position")
textHPosition = input.string("right", "Horizontal Position", options = ["left", "center", "right"], group = "Watermark position")

//========= SYMBOL INFO POSITION =========//
symVPosition = input.string("bottom", "Vertical Position", options = ["top", "middle", "bottom"], group = "Symbol position")
symHPosition = input.string("center", "Horizontal Position", options = ["left", "center", "right"], group = "Symbol position")

//========= CELL SIZE =========//
width  = input.int(0, "Width",  minval = 0, maxval = 100, tooltip = "Width as % of visual space", group = "Cell size")
height = input.int(0, "Height", minval = 0, maxval = 100, tooltip = "Height as % of visual space", group = "Cell size")

//========= TITLE SETTINGS =========//
c_title  = input.color(color.new(#363a45, 30), "Title Color", group = "Title settings")
s_title  = input.string("large", "Title Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Title settings")
a_title  = input.string("center", "Title Alignment", options = ["center", "left", "right"], group = "Title settings")

//========= SUBTITLE SETTINGS =========//
c_subtitle = input.color(color.new(color.black, 30), "Subtitle Color", group = "Subtitle settings")
s_subtitle = input.string("normal", "Subtitle Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Subtitle settings")
a_subtitle = input.string("center", "Subtitle Alignment", options = ["center", "left", "right"], group = "Subtitle settings")

//========= SYMBOL INFO SETTINGS =========//
c_symInfo = input.color(color.new(color.black, 30), "Symbol Color", group = "Symbol settings")
s_symInfo = input.string("normal", "Symbol Size", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Symbol settings")
a_symInfo = input.string("center", "Symbol Alignment", options = ["center", "left", "right"], group = "Symbol settings")

//========= BACKGROUND =========//
c_bg = input.color(color.new(color.blue, 100), "Background", group = "Background")

//========= TEXT WATERMARK CREATION =========//
var table textWatermark = table.new(textVPosition + "_" + textHPosition, 1, 3)

table.cell(textWatermark, 0, 0, titleText, width = width, height = height, text_color = c_title, text_halign = a_title, text_size = s_title, bgcolor = c_bg)
table.cell(textWatermark, 0, 1, subtitleText, width = width, height = height, text_color = c_subtitle, text_halign = a_subtitle, text_size = s_subtitle, bgcolor = c_bg)

//========= SYMBOL INFO CREATION =========//
if symInfoCheck
    var table symWatermark = table.new(symVPosition + "_" + symHPosition, 5, 5)
    table.cell(symWatermark, 0, 0, dateStr, width = width, height = height, text_color = c_symInfo, text_halign = a_symInfo, text_size = s_symInfo, bgcolor = c_bg)
    table.cell(symWatermark, 0, 1, symInfo, width = width, height = height, text_color = c_symInfo, text_halign = a_symInfo, text_size = s_symInfo, bgcolor = c_bg)
````
