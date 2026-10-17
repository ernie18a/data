# 3 MA Color

- url: https://www.tradingview.com/script/kHtsAXAp/
- type: indicator
- pine_id: PUB;52c091e5fc0d49e98ff13c9dd6f0b3b7
- version: 1.0

## Description

3 MA with Line color
- 50 (E)MA is colored according to slope is up or down.
- Shadowed area between MAs

## Source Code

````pine
//
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Goodtier

//@version=6
indicator(title="3 MA Color", overlay = true)

maType1 = input.string(title = "Type", defval = "EMA", options = ["EMA", "SMA"], inline = "1", group = "MA 1")
maLen1 = input.int(title = "Length", defval = 10, minval = 1, inline = "1", group = "MA 1")
maBaseColor1 = input.color(title = "Base", defval = color.gray, inline = "1", group = "MA 1")
maUseSlopeColor1 = input.bool(title = "Slope", defval = false, inline = "1s", group = "MA 1")
maSlopeUpColor1 = input.color(title = "Up", defval = color.gray, inline = "1s", group = "MA 1")
maSlopeDownColor1 = input.color(title = "Down", defval = color.gray, inline = "1s", group = "MA 1")
maWidth1 = input.int(title = "Width", defval = 1, minval = 1, group = "MA 1")
maShowLine1 = input.bool(title = "Show Line", defval = false, group = "MA 1")

maType2 = input.string(title = "Type", defval = "EMA", options = ["EMA", "SMA"], inline = "2", group = "MA 2")
maLen2 = input.int(title = "Length", defval = 20, minval = 1, inline = "2", group = "MA 2")
maBaseColor2 = input.color(title = "Base", defval = color.yellow, inline = "2", group = "MA 2")
maUseSlopeColor2 = input.bool(title = "Slope", defval = false, inline = "2s", group = "MA 2")
maSlopeUpColor2 = input.color(title = "Up", defval = color.yellow, inline = "2s", group = "MA 2")
maSlopeDownColor2 = input.color(title = "Down", defval = color.yellow, inline = "2s", group = "MA 2")
maWidth2 = input.int(title = "Width", defval = 1, minval = 1, group = "MA 2")
maShowLine2 = input.bool(title = "Show Line", defval = false, group = "MA 2")

maType3 = input.string(title = "Type", defval = "EMA", options = ["EMA", "SMA"], inline = "3", group = "MA 3")
maLen3 = input.int(title = "Length", defval = 50, minval = 1, inline = "3", group = "MA 3")
maBaseColor3 = input.color(title = "Base", defval = color.red, inline = "3", group = "MA 3")
maUseSlopeColor3 = input.bool(title = "Slope", defval = true, inline = "3s", group = "MA 3")
maSlopeUpColor3 = input.color(title = "Up", defval = color.green, inline = "3s", group = "MA 3")
maSlopeDownColor3 = input.color(title = "Down", defval = color.red, inline = "3s", group = "MA 3")
maWidth3 = input.int(title = "Width", defval = 1, minval = 1, group = "MA 3")
maShowLine3 = input.bool(title = "Show Line", defval = true, group = "MA 3")

zone12Enabled = input.bool(title = "Show p1-p2", defval = false, group = "Zones")
zone12UpColor = input.color(title = "p1-p2 Up", defval = color.new(color.green, 50), group = "Zones")
zone12DownColor = input.color(title = "p1-p2 Down", defval = color.new(color.red, 50), group = "Zones")
zone23Enabled = input.bool(title = "Show p2-p3", defval = true, group = "Zones")
zone23UpColor = input.color(title = "p2-p3 Up", defval = color.new(color.green, 80), group = "Zones")
zone23DownColor = input.color(title = "p2-p3 Down", defval = color.new(color.red, 80), group = "Zones")

maCalc(_source, _length, _type) =>
	_type == "EMA" ? ta.ema(_source, _length) : ta.sma(_source, _length)

maSlopeColor(_maValue, _baseColor, _useSlopeColor, _upColor, _downColor) =>
	_useSlopeColor ? (_maValue > _maValue[1] ? _upColor : _maValue < _maValue[1] ? _downColor : _baseColor) : _baseColor

ma1 = maCalc(close, maLen1, maType1)
ma2 = maCalc(close, maLen2, maType2)
ma3 = maCalc(close, maLen3, maType3)

maColor1 = maSlopeColor(ma1, maBaseColor1, maUseSlopeColor1, maSlopeUpColor1, maSlopeDownColor1)
maColor2 = maSlopeColor(ma2, maBaseColor2, maUseSlopeColor2, maSlopeUpColor2, maSlopeDownColor2)
maColor3 = maSlopeColor(ma3, maBaseColor3, maUseSlopeColor3, maSlopeUpColor3, maSlopeDownColor3)

p1 = plot(ma1, title = "MA 1", color = maShowLine1 ? maColor1 : na, linewidth = maWidth1, style = plot.style_line)
p2 = plot(ma2, title = "MA 2", color = maShowLine2 ? maColor2 : na, linewidth = maWidth2, style = plot.style_line)
p3 = plot(ma3, title = "MA 3", color = maShowLine3 ? maColor3 : na, linewidth = maWidth3, style = plot.style_line)

fill(p1, p2, color = zone12Enabled ? (ma1 > ma2 ? zone12UpColor : zone12DownColor) : na)
fill(p2, p3, color = zone23Enabled ? (ma2 > ma3 ? zone23UpColor : zone23DownColor) : na)
````
