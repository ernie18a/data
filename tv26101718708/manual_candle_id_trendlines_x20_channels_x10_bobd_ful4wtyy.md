# Manual Candle ID Trendlines x20 + Channels x10 + BO/BD

- url: https://www.tradingview.com/script/FuL4WtYy-Manual-Candle-ID-Trendlines-x20-Channels-x10-BO-BD/
- type: indicator
- pine_id: PUB;575b95239c854fc987bb23a45d39de49
- version: 3.0

## Description

# Manual Candle ID Trendlines & Adaptive Channels

This indicator allows traders to manually build precise trendlines and parallel channels by selecting candle IDs instead of relying on automatic pivot detection. It is designed for traders who prefer complete control over their market structure analysis while avoiding the inconsistencies of automatic algorithms.

Unlike traditional trendline tools that depend on pivot settings or swing detection, this script lets you anchor each trendline directly to the exact candle wicks you choose. This makes it suitable for discretionary technical analysis where the trader decides which market structure is important.

## Features

• Up to **20 independent manual trendlines**

* Connect any two candle highs or lows.
* Trendlines automatically extend a user-defined number of candles into the future.
* Individual enable/disable controls.
* Separate colors for high and low trendlines.

• Up to **10 parallel price channels**

* Each channel is constructed from **two manually selected lows** that define the channel slope and **one manually selected high** that determines the channel width.
* Optional channel midline.
* Channels automatically extend forward as new candles appear.

• **Live channel target projection**
For every enabled channel the script continuously calculates where the current candle would intersect the channel.

* Bullish candles display the projected upper channel target.
* Bearish candles display the projected lower channel target.
* Doji candles display the channel midpoint.

Optional price labels and a live summary table can display these projected target levels.

• **Breakout (BO) and Breakdown (BD) detection**
The script can generate signals whenever price crosses an enabled channel boundary.

* BO = Close crosses above the upper channel line.
* BD = Close crosses below the lower channel line.

Signals can be generated either:

* after candle close (default), or
* intrabar for traders who prefer earlier notifications.

Alert conditions are included for both BO and BD events.

## How the calculations work

Trendlines are calculated using the selected candle coordinates. The script computes the slope between the two anchor candles and projects that slope forward for the specified extension length.

Channels use the same manually defined slope from the two selected lows. The selected high determines the vertical offset, producing a parallel upper boundary while maintaining identical slope. A midpoint is then calculated between the two boundaries.

The live target feature continuously evaluates the current candle against the projected channel values to estimate the next interaction level.

## Typical uses

* Manual support and resistance analysis
* Trendline validation
* Building custom trend channels
* Planning breakout and breakdown trades
* Estimating dynamic price targets within channels
* Creating discretionary trading plans without relying on automatic pivot algorithms

## Notes

This indicator is intended as a discretionary charting tool. It does not automatically identify swing points or draw trendlines. The quality of the analysis depends on the trader's choice of anchor candles.

BO and BD signals simply indicate that price crossed an enabled channel boundary. They are not standalone buy or sell recommendations and should be combined with additional market context and risk management.

## Source Code

````pine
//@version=6
indicator("Manual Candle ID Trendlines x20 + Channels x10 + Levels x20", overlay=true, max_lines_count=150, max_labels_count=500, max_bars_back=5000)

// ───── Global
tlAnchorMode = input.string("Wicks", "Trendline anchor mode", options=["Wicks", "Body", "Open", "Close", "Per-point"], group="Global", tooltip="Global mode for trendlines. Wicks uses High for upper TLs and Low for lower TLs. Body uses Body Top/Body Bottom. Open and Close use exact candle Open/Close. Per-point uses each trendline Point 1/Point 2 source inputs below.")
channelAnchorMode = input.string("Wicks", "Channel anchor mode", options=["Wicks", "Body"], group="Global", tooltip="Channels need a true lower and upper boundary. Use Wicks for low/high channels or Body for body-bottom/body-top channels. Open/Close are intentionally not used for channels because they can invert or distort parallel channels.")
projectionMode = input.string("Linear", "Projection math", options=["Linear", "Log"], group="Global", tooltip="Use Log when your chart is on logarithmic scale. This makes projected trendlines and channels pass accurately through the selected candle anchors on log charts.")
lineW       = input.int(2, "Line width", minval=1, maxval=5, group="Global")
extendBars  = input.int(10, "Extend only this many candles ahead", minval=0, maxval=500, group="Global")
highCol     = input.color(color.red, "High / upper lines color", group="Global")
lowCol      = input.color(color.lime, "Low / lower lines color", group="Global")
showNameDots = input.bool(true, "Show trendline name dots", group="Global", tooltip="Adds a small dot at the projected end of each enabled trendline. Hover the dot to see the trendline name.")
nameDotTransp = input.int(0, "Trendline dot transparency", minval=0, maxval=100, group="Global")

// ───── BO / BD signals
showSignals       = input.bool(true, "Show BO / BD signals", group="BO / BD Signals")
signalOnCloseOnly = input.bool(true, "Signal only after candle close", group="BO / BD Signals")
boCol             = input.color(color.lime, "BO color", group="BO / BD Signals")
bdCol             = input.color(color.red, "BD color", group="BO / BD Signals")


// ───── Candle ID labels
showBarID   = input.bool(false, "Show Candle ID above candles", group="Debug")
idSpacing   = input.int(1, "Show every N candles", minval=1, group="Debug")
idTextColor = input.color(color.yellow, "ID text color", group="Debug")

if showBarID and bar_index % idSpacing == 0
    label.new(bar_index, high, str.tostring(bar_index), xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_none, textcolor=idTextColor, size=size.tiny)

// ───── Helpers
f_col(_src) =>
    (_src == "High" or _src == "Body Top") ? highCol : (_src == "Low" or _src == "Body Bottom") ? lowCol : color.gray

f_bodyHigh() =>
    math.max(open, close)

f_bodyLow() =>
    math.min(open, close)

f_anchor(_src) =>
    _src == "High" ? high : _src == "Low" ? low : _src == "Open" ? open : _src == "Close" ? close : _src == "Body Top" ? f_bodyHigh() : f_bodyLow()

f_tlSrc(_customSrc, _baseSide) =>
    tlAnchorMode == "Per-point" ? _customSrc :
     tlAnchorMode == "Open" ? "Open" :
     tlAnchorMode == "Close" ? "Close" :
     tlAnchorMode == "Body" ? (_baseSide == "High" ? "Body Top" : "Body Bottom") :
     (_baseSide == "High" ? "High" : "Low")

f_lowAnchor() =>
    channelAnchorMode == "Body" ? f_bodyLow() : low

f_highAnchor() =>
    channelAnchorMode == "Body" ? f_bodyHigh() : high

f_isLog() =>
    projectionMode == "Log"

f_project(_x1, _y1, _x2, _y2, _x) =>
    canLog = f_isLog() and _y1 > 0 and _y2 > 0
    canLog ? math.exp(math.log(_y1) + (math.log(_y2) - math.log(_y1)) * (_x - _x1) / (_x2 - _x1)) : _y1 + ((_y2 - _y1) / (_x2 - _x1)) * (_x - _x1)

f_logAdd(_base, _offset) =>
    _base > 0 ? math.exp(math.log(_base) + _offset) : na

f_midPrice(_a, _b) =>
    f_isLog() and _a > 0 and _b > 0 ? math.sqrt(_a * _b) : (_a + _b) / 2.0

f_draw(_ln, _dot, _enabled, _id1, _id2, _y1, _y2, _col, _name) =>
    line ln = _ln
    label dot = _dot
    if barstate.islast
        if _enabled and _id1 > 0 and _id2 > 0 and _id1 != _id2 and not na(_y1) and not na(_y2)
            xEnd = bar_index + extendBars
            yEnd = f_project(_id1, _y1, _id2, _y2, xEnd)
            if na(ln)
                ln := line.new(_id1, _y1, xEnd, yEnd, xloc=xloc.bar_index, extend=extend.none, color=_col, width=lineW)
            else
                line.set_xy1(ln, _id1, _y1)
                line.set_xy2(ln, xEnd, yEnd)
                line.set_extend(ln, extend.none)
                line.set_color(ln, _col)
                line.set_width(ln, lineW)
            if showNameDots
                dotText = str.length(_name) > 0 ? _name : "Unnamed trendline"
                if na(dot)
                    dot := label.new(xEnd, yEnd, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_circle, color=color.new(_col, nameDotTransp), textcolor=color.white, size=size.tiny, tooltip=dotText)
                else
                    label.set_xy(dot, xEnd, yEnd)
                    label.set_style(dot, label.style_circle)
                    label.set_color(dot, color.new(_col, nameDotTransp))
                    label.set_textcolor(dot, color.white)
                    label.set_size(dot, size.tiny)
                    label.set_text(dot, "")
                    label.set_tooltip(dot, dotText)
            else
                if not na(dot)
                    label.delete(dot)
                    dot := na
        else
            if not na(ln)
                line.delete(ln)
                ln := na
            if not na(dot)
                label.delete(dot)
                dot := na
    [ln, dot]

// ───── Trendline Inputs
group01 = "Trendline 01"
en01 = input.bool(false, "Enable 01", group=group01)
src01a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group01)
src01b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group01)
a01 = input.int(0, "Candle ID 1", minval=0, group=group01)
b01 = input.int(0, "Candle ID 2", minval=0, group=group01)
n01 = input.string("TL01", "Trendline name", group=group01, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group02 = "Trendline 02"
en02 = input.bool(false, "Enable 02", group=group02)
src02a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group02)
src02b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group02)
a02 = input.int(0, "Candle ID 1", minval=0, group=group02)
b02 = input.int(0, "Candle ID 2", minval=0, group=group02)
n02 = input.string("TL02", "Trendline name", group=group02, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group03 = "Trendline 03"
en03 = input.bool(false, "Enable 03", group=group03)
src03a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group03)
src03b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group03)
a03 = input.int(0, "Candle ID 1", minval=0, group=group03)
b03 = input.int(0, "Candle ID 2", minval=0, group=group03)
n03 = input.string("TL03", "Trendline name", group=group03, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group04 = "Trendline 04"
en04 = input.bool(false, "Enable 04", group=group04)
src04a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group04)
src04b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group04)
a04 = input.int(0, "Candle ID 1", minval=0, group=group04)
b04 = input.int(0, "Candle ID 2", minval=0, group=group04)
n04 = input.string("TL04", "Trendline name", group=group04, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group05 = "Trendline 05"
en05 = input.bool(false, "Enable 05", group=group05)
src05a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group05)
src05b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group05)
a05 = input.int(0, "Candle ID 1", minval=0, group=group05)
b05 = input.int(0, "Candle ID 2", minval=0, group=group05)
n05 = input.string("TL05", "Trendline name", group=group05, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group06 = "Trendline 06"
en06 = input.bool(false, "Enable 06", group=group06)
src06a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group06)
src06b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group06)
a06 = input.int(0, "Candle ID 1", minval=0, group=group06)
b06 = input.int(0, "Candle ID 2", minval=0, group=group06)
n06 = input.string("TL06", "Trendline name", group=group06, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group07 = "Trendline 07"
en07 = input.bool(false, "Enable 07", group=group07)
src07a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group07)
src07b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group07)
a07 = input.int(0, "Candle ID 1", minval=0, group=group07)
b07 = input.int(0, "Candle ID 2", minval=0, group=group07)
n07 = input.string("TL07", "Trendline name", group=group07, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group08 = "Trendline 08"
en08 = input.bool(false, "Enable 08", group=group08)
src08a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group08)
src08b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group08)
a08 = input.int(0, "Candle ID 1", minval=0, group=group08)
b08 = input.int(0, "Candle ID 2", minval=0, group=group08)
n08 = input.string("TL08", "Trendline name", group=group08, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group09 = "Trendline 09"
en09 = input.bool(false, "Enable 09", group=group09)
src09a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group09)
src09b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group09)
a09 = input.int(0, "Candle ID 1", minval=0, group=group09)
b09 = input.int(0, "Candle ID 2", minval=0, group=group09)
n09 = input.string("TL09", "Trendline name", group=group09, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group10 = "Trendline 10"
en10 = input.bool(false, "Enable 10", group=group10)
src10a = input.string("High", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group10)
src10b = input.string("High", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group10)
a10 = input.int(0, "Candle ID 1", minval=0, group=group10)
b10 = input.int(0, "Candle ID 2", minval=0, group=group10)
n10 = input.string("TL10", "Trendline name", group=group10, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group11 = "Trendline 11"
en11 = input.bool(false, "Enable 11", group=group11)
src11a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group11)
src11b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group11)
a11 = input.int(0, "Candle ID 1", minval=0, group=group11)
b11 = input.int(0, "Candle ID 2", minval=0, group=group11)
n11 = input.string("TL11", "Trendline name", group=group11, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group12 = "Trendline 12"
en12 = input.bool(false, "Enable 12", group=group12)
src12a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group12)
src12b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group12)
a12 = input.int(0, "Candle ID 1", minval=0, group=group12)
b12 = input.int(0, "Candle ID 2", minval=0, group=group12)
n12 = input.string("TL12", "Trendline name", group=group12, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group13 = "Trendline 13"
en13 = input.bool(false, "Enable 13", group=group13)
src13a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group13)
src13b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group13)
a13 = input.int(0, "Candle ID 1", minval=0, group=group13)
b13 = input.int(0, "Candle ID 2", minval=0, group=group13)
n13 = input.string("TL13", "Trendline name", group=group13, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group14 = "Trendline 14"
en14 = input.bool(false, "Enable 14", group=group14)
src14a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group14)
src14b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group14)
a14 = input.int(0, "Candle ID 1", minval=0, group=group14)
b14 = input.int(0, "Candle ID 2", minval=0, group=group14)
n14 = input.string("TL14", "Trendline name", group=group14, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group15 = "Trendline 15"
en15 = input.bool(false, "Enable 15", group=group15)
src15a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group15)
src15b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group15)
a15 = input.int(0, "Candle ID 1", minval=0, group=group15)
b15 = input.int(0, "Candle ID 2", minval=0, group=group15)
n15 = input.string("TL15", "Trendline name", group=group15, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group16 = "Trendline 16"
en16 = input.bool(false, "Enable 16", group=group16)
src16a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group16)
src16b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group16)
a16 = input.int(0, "Candle ID 1", minval=0, group=group16)
b16 = input.int(0, "Candle ID 2", minval=0, group=group16)
n16 = input.string("TL16", "Trendline name", group=group16, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group17 = "Trendline 17"
en17 = input.bool(false, "Enable 17", group=group17)
src17a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group17)
src17b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group17)
a17 = input.int(0, "Candle ID 1", minval=0, group=group17)
b17 = input.int(0, "Candle ID 2", minval=0, group=group17)
n17 = input.string("TL17", "Trendline name", group=group17, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group18 = "Trendline 18"
en18 = input.bool(false, "Enable 18", group=group18)
src18a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group18)
src18b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group18)
a18 = input.int(0, "Candle ID 1", minval=0, group=group18)
b18 = input.int(0, "Candle ID 2", minval=0, group=group18)
n18 = input.string("TL18", "Trendline name", group=group18, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group19 = "Trendline 19"
en19 = input.bool(false, "Enable 19", group=group19)
src19a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group19)
src19b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group19)
a19 = input.int(0, "Candle ID 1", minval=0, group=group19)
b19 = input.int(0, "Candle ID 2", minval=0, group=group19)
n19 = input.string("TL19", "Trendline name", group=group19, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

group20 = "Trendline 20"
en20 = input.bool(false, "Enable 20", group=group20)
src20a = input.string("Low", "Point 1 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group20)
src20b = input.string("Low", "Point 2 source", options=["High", "Low", "Open", "Close", "Body Top", "Body Bottom"], group=group20)
a20 = input.int(0, "Candle ID 1", minval=0, group=group20)
b20 = input.int(0, "Candle ID 2", minval=0, group=group20)
n20 = input.string("TL20", "Trendline name", group=group20, tooltip="Name shown when hovering the dot at the projected end of this trendline.")

// ───── Trendline Prices
y01a = ta.valuewhen(bar_index == a01, f_anchor(f_tlSrc(src01a, "High")), 0)
y01b = ta.valuewhen(bar_index == b01, f_anchor(f_tlSrc(src01b, "High")), 0)
y02a = ta.valuewhen(bar_index == a02, f_anchor(f_tlSrc(src02a, "High")), 0)
y02b = ta.valuewhen(bar_index == b02, f_anchor(f_tlSrc(src02b, "High")), 0)
y03a = ta.valuewhen(bar_index == a03, f_anchor(f_tlSrc(src03a, "High")), 0)
y03b = ta.valuewhen(bar_index == b03, f_anchor(f_tlSrc(src03b, "High")), 0)
y04a = ta.valuewhen(bar_index == a04, f_anchor(f_tlSrc(src04a, "High")), 0)
y04b = ta.valuewhen(bar_index == b04, f_anchor(f_tlSrc(src04b, "High")), 0)
y05a = ta.valuewhen(bar_index == a05, f_anchor(f_tlSrc(src05a, "High")), 0)
y05b = ta.valuewhen(bar_index == b05, f_anchor(f_tlSrc(src05b, "High")), 0)
y06a = ta.valuewhen(bar_index == a06, f_anchor(f_tlSrc(src06a, "High")), 0)
y06b = ta.valuewhen(bar_index == b06, f_anchor(f_tlSrc(src06b, "High")), 0)
y07a = ta.valuewhen(bar_index == a07, f_anchor(f_tlSrc(src07a, "High")), 0)
y07b = ta.valuewhen(bar_index == b07, f_anchor(f_tlSrc(src07b, "High")), 0)
y08a = ta.valuewhen(bar_index == a08, f_anchor(f_tlSrc(src08a, "High")), 0)
y08b = ta.valuewhen(bar_index == b08, f_anchor(f_tlSrc(src08b, "High")), 0)
y09a = ta.valuewhen(bar_index == a09, f_anchor(f_tlSrc(src09a, "High")), 0)
y09b = ta.valuewhen(bar_index == b09, f_anchor(f_tlSrc(src09b, "High")), 0)
y10a = ta.valuewhen(bar_index == a10, f_anchor(f_tlSrc(src10a, "High")), 0)
y10b = ta.valuewhen(bar_index == b10, f_anchor(f_tlSrc(src10b, "High")), 0)
y11a = ta.valuewhen(bar_index == a11, f_anchor(f_tlSrc(src11a, "Low")), 0)
y11b = ta.valuewhen(bar_index == b11, f_anchor(f_tlSrc(src11b, "Low")), 0)
y12a = ta.valuewhen(bar_index == a12, f_anchor(f_tlSrc(src12a, "Low")), 0)
y12b = ta.valuewhen(bar_index == b12, f_anchor(f_tlSrc(src12b, "Low")), 0)
y13a = ta.valuewhen(bar_index == a13, f_anchor(f_tlSrc(src13a, "Low")), 0)
y13b = ta.valuewhen(bar_index == b13, f_anchor(f_tlSrc(src13b, "Low")), 0)
y14a = ta.valuewhen(bar_index == a14, f_anchor(f_tlSrc(src14a, "Low")), 0)
y14b = ta.valuewhen(bar_index == b14, f_anchor(f_tlSrc(src14b, "Low")), 0)
y15a = ta.valuewhen(bar_index == a15, f_anchor(f_tlSrc(src15a, "Low")), 0)
y15b = ta.valuewhen(bar_index == b15, f_anchor(f_tlSrc(src15b, "Low")), 0)
y16a = ta.valuewhen(bar_index == a16, f_anchor(f_tlSrc(src16a, "Low")), 0)
y16b = ta.valuewhen(bar_index == b16, f_anchor(f_tlSrc(src16b, "Low")), 0)
y17a = ta.valuewhen(bar_index == a17, f_anchor(f_tlSrc(src17a, "Low")), 0)
y17b = ta.valuewhen(bar_index == b17, f_anchor(f_tlSrc(src17b, "Low")), 0)
y18a = ta.valuewhen(bar_index == a18, f_anchor(f_tlSrc(src18a, "Low")), 0)
y18b = ta.valuewhen(bar_index == b18, f_anchor(f_tlSrc(src18b, "Low")), 0)
y19a = ta.valuewhen(bar_index == a19, f_anchor(f_tlSrc(src19a, "Low")), 0)
y19b = ta.valuewhen(bar_index == b19, f_anchor(f_tlSrc(src19b, "Low")), 0)
y20a = ta.valuewhen(bar_index == a20, f_anchor(f_tlSrc(src20a, "Low")), 0)
y20b = ta.valuewhen(bar_index == b20, f_anchor(f_tlSrc(src20b, "Low")), 0)

// ───── Trendline Vars
var line l01 = na
var label d01 = na
var line l02 = na
var label d02 = na
var line l03 = na
var label d03 = na
var line l04 = na
var label d04 = na
var line l05 = na
var label d05 = na
var line l06 = na
var label d06 = na
var line l07 = na
var label d07 = na
var line l08 = na
var label d08 = na
var line l09 = na
var label d09 = na
var line l10 = na
var label d10 = na
var line l11 = na
var label d11 = na
var line l12 = na
var label d12 = na
var line l13 = na
var label d13 = na
var line l14 = na
var label d14 = na
var line l15 = na
var label d15 = na
var line l16 = na
var label d16 = na
var line l17 = na
var label d17 = na
var line l18 = na
var label d18 = na
var line l19 = na
var label d19 = na
var line l20 = na
var label d20 = na

// ───── Draw Trendlines
[l01New, d01New] = f_draw(l01, d01, en01, a01, b01, y01a, y01b, f_col(f_tlSrc(src01a, "High")), n01)
l01 := l01New
d01 := d01New
[l02New, d02New] = f_draw(l02, d02, en02, a02, b02, y02a, y02b, f_col(f_tlSrc(src02a, "High")), n02)
l02 := l02New
d02 := d02New
[l03New, d03New] = f_draw(l03, d03, en03, a03, b03, y03a, y03b, f_col(f_tlSrc(src03a, "High")), n03)
l03 := l03New
d03 := d03New
[l04New, d04New] = f_draw(l04, d04, en04, a04, b04, y04a, y04b, f_col(f_tlSrc(src04a, "High")), n04)
l04 := l04New
d04 := d04New
[l05New, d05New] = f_draw(l05, d05, en05, a05, b05, y05a, y05b, f_col(f_tlSrc(src05a, "High")), n05)
l05 := l05New
d05 := d05New
[l06New, d06New] = f_draw(l06, d06, en06, a06, b06, y06a, y06b, f_col(f_tlSrc(src06a, "High")), n06)
l06 := l06New
d06 := d06New
[l07New, d07New] = f_draw(l07, d07, en07, a07, b07, y07a, y07b, f_col(f_tlSrc(src07a, "High")), n07)
l07 := l07New
d07 := d07New
[l08New, d08New] = f_draw(l08, d08, en08, a08, b08, y08a, y08b, f_col(f_tlSrc(src08a, "High")), n08)
l08 := l08New
d08 := d08New
[l09New, d09New] = f_draw(l09, d09, en09, a09, b09, y09a, y09b, f_col(f_tlSrc(src09a, "High")), n09)
l09 := l09New
d09 := d09New
[l10New, d10New] = f_draw(l10, d10, en10, a10, b10, y10a, y10b, f_col(f_tlSrc(src10a, "High")), n10)
l10 := l10New
d10 := d10New
[l11New, d11New] = f_draw(l11, d11, en11, a11, b11, y11a, y11b, f_col(f_tlSrc(src11a, "Low")), n11)
l11 := l11New
d11 := d11New
[l12New, d12New] = f_draw(l12, d12, en12, a12, b12, y12a, y12b, f_col(f_tlSrc(src12a, "Low")), n12)
l12 := l12New
d12 := d12New
[l13New, d13New] = f_draw(l13, d13, en13, a13, b13, y13a, y13b, f_col(f_tlSrc(src13a, "Low")), n13)
l13 := l13New
d13 := d13New
[l14New, d14New] = f_draw(l14, d14, en14, a14, b14, y14a, y14b, f_col(f_tlSrc(src14a, "Low")), n14)
l14 := l14New
d14 := d14New
[l15New, d15New] = f_draw(l15, d15, en15, a15, b15, y15a, y15b, f_col(f_tlSrc(src15a, "Low")), n15)
l15 := l15New
d15 := d15New
[l16New, d16New] = f_draw(l16, d16, en16, a16, b16, y16a, y16b, f_col(f_tlSrc(src16a, "Low")), n16)
l16 := l16New
d16 := d16New
[l17New, d17New] = f_draw(l17, d17, en17, a17, b17, y17a, y17b, f_col(f_tlSrc(src17a, "Low")), n17)
l17 := l17New
d17 := d17New
[l18New, d18New] = f_draw(l18, d18, en18, a18, b18, y18a, y18b, f_col(f_tlSrc(src18a, "Low")), n18)
l18 := l18New
d18 := d18New
[l19New, d19New] = f_draw(l19, d19, en19, a19, b19, y19a, y19b, f_col(f_tlSrc(src19a, "Low")), n19)
l19 := l19New
d19 := d19New
[l20New, d20New] = f_draw(l20, d20, en20, a20, b20, y20a, y20b, f_col(f_tlSrc(src20a, "Low")), n20)
l20 := l20New
d20 := d20New

// ───── Channel Settings
showMid    = input.bool(true, "Show channel midline", group="Channels")
chanW      = input.int(2, "Channel width", minval=1, maxval=5, group="Channels")
chanCol    = input.color(color.aqua, "Channel color", group="Channels")
midCol     = input.color(color.gray, "Midline color", group="Channels")
showChannelNameDots = input.bool(true, "Show channel name dots", group="Channels", tooltip="Adds small dots at the projected end of each enabled channel boundary. Hover the dots to see the channel name.")
channelDotTransp = input.int(0, "Channel dot transparency", minval=0, maxval=100, group="Channels")

showLiveTargets  = input.bool(true, "Show current candle channel target labels", group="Channels Live Target")
showTargetTable   = input.bool(false, "Show live target table", group="Channels Live Target")
targetLabelOffset = input.int(0, "Target label bar offset", minval=0, maxval=20, group="Channels Live Target")
targetLabelTransp = input.int(75, "Target label background transparency", minval=0, maxval=100, group="Channels Live Target")

f_channel(_loLine, _upLine, _midLine, _enabled, _l1, _l2, _h, _yl1, _yl2, _yh) =>
    line lo = _loLine
    line up = _upLine
    line mid = _midLine
    float lowerNow = na
    float upperNow = na
    float midNow = na
    if barstate.islast
        valid = _enabled and _l1 > 0 and _l2 > 0 and _h > 0 and _l1 != _l2 and not na(_yl1) and not na(_yl2) and not na(_yh)
        if valid
            useLogChannel = f_isLog() and _yl1 > 0 and _yl2 > 0 and _yh > 0
            lowAtHigh = f_project(_l1, _yl1, _l2, _yl2, _h)
            xEnd = bar_index + extendBars
            yLowerEnd = f_project(_l1, _yl1, _l2, _yl2, xEnd)
            lowerNow := f_project(_l1, _yl1, _l2, _yl2, bar_index)
            float yUpperStart = na
            float yUpperEnd = na
            float yMidStart = na
            float yMidEnd = na
            if useLogChannel and lowAtHigh > 0 and yLowerEnd > 0 and lowerNow > 0
                offsetLog = math.log(_yh) - math.log(lowAtHigh)
                yUpperStart := f_logAdd(_yl1, offsetLog)
                yUpperEnd := f_logAdd(yLowerEnd, offsetLog)
                upperNow := f_logAdd(lowerNow, offsetLog)
                yMidStart := f_midPrice(_yl1, yUpperStart)
                yMidEnd := f_midPrice(yLowerEnd, yUpperEnd)
                midNow := f_midPrice(lowerNow, upperNow)
            else
                offset = _yh - lowAtHigh
                yUpperStart := _yl1 + offset
                yUpperEnd := yLowerEnd + offset
                upperNow := lowerNow + offset
                yMidStart := f_midPrice(_yl1, yUpperStart)
                yMidEnd := f_midPrice(yLowerEnd, yUpperEnd)
                midNow := f_midPrice(lowerNow, upperNow)
            if na(lo)
                lo := line.new(_l1, _yl1, xEnd, yLowerEnd, xloc=xloc.bar_index, extend=extend.none, color=chanCol, width=chanW)
                up := line.new(_l1, yUpperStart, xEnd, yUpperEnd, xloc=xloc.bar_index, extend=extend.none, color=chanCol, width=chanW)
                if showMid
                    mid := line.new(_l1, yMidStart, xEnd, yMidEnd, xloc=xloc.bar_index, extend=extend.none, color=midCol, width=1, style=line.style_dashed)
            else
                line.set_xy1(lo, _l1, _yl1)
                line.set_xy2(lo, xEnd, yLowerEnd)
                line.set_extend(lo, extend.none)
                line.set_color(lo, chanCol)
                line.set_width(lo, chanW)
                line.set_xy1(up, _l1, yUpperStart)
                line.set_xy2(up, xEnd, yUpperEnd)
                line.set_extend(up, extend.none)
                line.set_color(up, chanCol)
                line.set_width(up, chanW)
                if showMid
                    if na(mid)
                        mid := line.new(_l1, yMidStart, xEnd, yMidEnd, xloc=xloc.bar_index, extend=extend.none, color=midCol, width=1, style=line.style_dashed)
                    else
                        line.set_xy1(mid, _l1, yMidStart)
                        line.set_xy2(mid, xEnd, yMidEnd)
                        line.set_extend(mid, extend.none)
                        line.set_color(mid, midCol)
                        line.set_width(mid, 1)
                        line.set_style(mid, line.style_dashed)
                else
                    if not na(mid)
                        line.delete(mid)
                        mid := na
        else
            if not na(lo)
                line.delete(lo)
                lo := na
            if not na(up)
                line.delete(up)
                up := na
            if not na(mid)
                line.delete(mid)
                mid := na
    [lo, up, mid, lowerNow, upperNow, midNow]

f_target_label(_lbl, _enabled, _target, _isBull, _isBear) =>
    label lbl = _lbl
    if barstate.islast
        if showLiveTargets and _enabled and not na(_target)
            if not na(lbl)
                label.delete(lbl)
            labelStyle = _isBull ? label.style_label_down : _isBear ? label.style_label_up : label.style_label_left
            lbl := label.new(bar_index + targetLabelOffset, _target, str.tostring(_target, format.mintick), xloc=xloc.bar_index, yloc=yloc.price, style=labelStyle, textcolor=color.white, color=color.new(chanCol, targetLabelTransp), size=size.small)
        else
            if not na(lbl)
                label.delete(lbl)
                lbl := na
    lbl

f_channel_dot(_dot, _enabled, _line, _name, _part, _col) =>
    label dot = _dot
    if barstate.islast
        validDot = showChannelNameDots and _enabled and not na(_line)
        if validDot
            x = line.get_x2(_line)
            y = line.get_y2(_line)
            baseName = str.length(_name) > 0 ? _name : "Unnamed channel"
            dotTip = baseName + " — " + _part
            if na(dot)
                dot := label.new(x, y, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_circle, color=color.new(_col, channelDotTransp), textcolor=color.white, size=size.tiny, tooltip=dotTip)
            else
                label.set_xy(dot, x, y)
                label.set_style(dot, label.style_circle)
                label.set_color(dot, color.new(_col, channelDotTransp))
                label.set_textcolor(dot, color.white)
                label.set_size(dot, size.tiny)
                label.set_text(dot, "")
                label.set_tooltip(dot, dotTip)
        else
            if not na(dot)
                label.delete(dot)
                dot := na
    dot

// ───── Channel Inputs: each channel uses 2 low candle IDs + 1 high candle ID
cg01 = "Channel 01 - 2 lows + 1 high"
cen01 = input.bool(false, "Enable Channel 01", group=cg01)
cl011 = input.int(0, "Low Candle ID 1", minval=0, group=cg01)
cl012 = input.int(0, "Low Candle ID 2", minval=0, group=cg01)
ch01  = input.int(0, "High Candle ID", minval=0, group=cg01)
cn01 = input.string("CH01", "Channel name", group=cg01, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg02 = "Channel 02 - 2 lows + 1 high"
cen02 = input.bool(false, "Enable Channel 02", group=cg02)
cl021 = input.int(0, "Low Candle ID 1", minval=0, group=cg02)
cl022 = input.int(0, "Low Candle ID 2", minval=0, group=cg02)
ch02  = input.int(0, "High Candle ID", minval=0, group=cg02)
cn02 = input.string("CH02", "Channel name", group=cg02, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg03 = "Channel 03 - 2 lows + 1 high"
cen03 = input.bool(false, "Enable Channel 03", group=cg03)
cl031 = input.int(0, "Low Candle ID 1", minval=0, group=cg03)
cl032 = input.int(0, "Low Candle ID 2", minval=0, group=cg03)
ch03  = input.int(0, "High Candle ID", minval=0, group=cg03)
cn03 = input.string("CH03", "Channel name", group=cg03, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg04 = "Channel 04 - 2 lows + 1 high"
cen04 = input.bool(false, "Enable Channel 04", group=cg04)
cl041 = input.int(0, "Low Candle ID 1", minval=0, group=cg04)
cl042 = input.int(0, "Low Candle ID 2", minval=0, group=cg04)
ch04  = input.int(0, "High Candle ID", minval=0, group=cg04)
cn04 = input.string("CH04", "Channel name", group=cg04, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg05 = "Channel 05 - 2 lows + 1 high"
cen05 = input.bool(false, "Enable Channel 05", group=cg05)
cl051 = input.int(0, "Low Candle ID 1", minval=0, group=cg05)
cl052 = input.int(0, "Low Candle ID 2", minval=0, group=cg05)
ch05  = input.int(0, "High Candle ID", minval=0, group=cg05)
cn05 = input.string("CH05", "Channel name", group=cg05, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg06 = "Channel 06 - 2 lows + 1 high"
cen06 = input.bool(false, "Enable Channel 06", group=cg06)
cl061 = input.int(0, "Low Candle ID 1", minval=0, group=cg06)
cl062 = input.int(0, "Low Candle ID 2", minval=0, group=cg06)
ch06  = input.int(0, "High Candle ID", minval=0, group=cg06)
cn06 = input.string("CH06", "Channel name", group=cg06, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg07 = "Channel 07 - 2 lows + 1 high"
cen07 = input.bool(false, "Enable Channel 07", group=cg07)
cl071 = input.int(0, "Low Candle ID 1", minval=0, group=cg07)
cl072 = input.int(0, "Low Candle ID 2", minval=0, group=cg07)
ch07  = input.int(0, "High Candle ID", minval=0, group=cg07)
cn07 = input.string("CH07", "Channel name", group=cg07, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg08 = "Channel 08 - 2 lows + 1 high"
cen08 = input.bool(false, "Enable Channel 08", group=cg08)
cl081 = input.int(0, "Low Candle ID 1", minval=0, group=cg08)
cl082 = input.int(0, "Low Candle ID 2", minval=0, group=cg08)
ch08  = input.int(0, "High Candle ID", minval=0, group=cg08)
cn08 = input.string("CH08", "Channel name", group=cg08, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg09 = "Channel 09 - 2 lows + 1 high"
cen09 = input.bool(false, "Enable Channel 09", group=cg09)
cl091 = input.int(0, "Low Candle ID 1", minval=0, group=cg09)
cl092 = input.int(0, "Low Candle ID 2", minval=0, group=cg09)
ch09  = input.int(0, "High Candle ID", minval=0, group=cg09)
cn09 = input.string("CH09", "Channel name", group=cg09, tooltip="Name shown when hovering the dot at the projected end of this channel.")

cg10 = "Channel 10 - 2 lows + 1 high"
cen10 = input.bool(false, "Enable Channel 10", group=cg10)
cl101 = input.int(0, "Low Candle ID 1", minval=0, group=cg10)
cl102 = input.int(0, "Low Candle ID 2", minval=0, group=cg10)
ch10  = input.int(0, "High Candle ID", minval=0, group=cg10)
cn10 = input.string("CH10", "Channel name", group=cg10, tooltip="Name shown when hovering the dot at the projected end of this channel.")

// ───── Channel Prices
c01l1y = ta.valuewhen(bar_index == cl011, f_lowAnchor(), 0)
c01l2y = ta.valuewhen(bar_index == cl012, f_lowAnchor(), 0)
c01hy  = ta.valuewhen(bar_index == ch01, f_highAnchor(), 0)
c02l1y = ta.valuewhen(bar_index == cl021, f_lowAnchor(), 0)
c02l2y = ta.valuewhen(bar_index == cl022, f_lowAnchor(), 0)
c02hy  = ta.valuewhen(bar_index == ch02, f_highAnchor(), 0)
c03l1y = ta.valuewhen(bar_index == cl031, f_lowAnchor(), 0)
c03l2y = ta.valuewhen(bar_index == cl032, f_lowAnchor(), 0)
c03hy  = ta.valuewhen(bar_index == ch03, f_highAnchor(), 0)
c04l1y = ta.valuewhen(bar_index == cl041, f_lowAnchor(), 0)
c04l2y = ta.valuewhen(bar_index == cl042, f_lowAnchor(), 0)
c04hy  = ta.valuewhen(bar_index == ch04, f_highAnchor(), 0)
c05l1y = ta.valuewhen(bar_index == cl051, f_lowAnchor(), 0)
c05l2y = ta.valuewhen(bar_index == cl052, f_lowAnchor(), 0)
c05hy  = ta.valuewhen(bar_index == ch05, f_highAnchor(), 0)
c06l1y = ta.valuewhen(bar_index == cl061, f_lowAnchor(), 0)
c06l2y = ta.valuewhen(bar_index == cl062, f_lowAnchor(), 0)
c06hy  = ta.valuewhen(bar_index == ch06, f_highAnchor(), 0)
c07l1y = ta.valuewhen(bar_index == cl071, f_lowAnchor(), 0)
c07l2y = ta.valuewhen(bar_index == cl072, f_lowAnchor(), 0)
c07hy  = ta.valuewhen(bar_index == ch07, f_highAnchor(), 0)
c08l1y = ta.valuewhen(bar_index == cl081, f_lowAnchor(), 0)
c08l2y = ta.valuewhen(bar_index == cl082, f_lowAnchor(), 0)
c08hy  = ta.valuewhen(bar_index == ch08, f_highAnchor(), 0)
c09l1y = ta.valuewhen(bar_index == cl091, f_lowAnchor(), 0)
c09l2y = ta.valuewhen(bar_index == cl092, f_lowAnchor(), 0)
c09hy  = ta.valuewhen(bar_index == ch09, f_highAnchor(), 0)
c10l1y = ta.valuewhen(bar_index == cl101, f_lowAnchor(), 0)
c10l2y = ta.valuewhen(bar_index == cl102, f_lowAnchor(), 0)
c10hy  = ta.valuewhen(bar_index == ch10, f_highAnchor(), 0)

// ───── Channel Vars
var line c01lo = na
var line c01up = na
var line c01mid = na
var label c01TargetLabel = na
var label c01LoDot = na
var label c01UpDot = na
var label c01MidDot = na
var line c02lo = na
var line c02up = na
var line c02mid = na
var label c02TargetLabel = na
var label c02LoDot = na
var label c02UpDot = na
var label c02MidDot = na
var line c03lo = na
var line c03up = na
var line c03mid = na
var label c03TargetLabel = na
var label c03LoDot = na
var label c03UpDot = na
var label c03MidDot = na
var line c04lo = na
var line c04up = na
var line c04mid = na
var label c04TargetLabel = na
var label c04LoDot = na
var label c04UpDot = na
var label c04MidDot = na
var line c05lo = na
var line c05up = na
var line c05mid = na
var label c05TargetLabel = na
var label c05LoDot = na
var label c05UpDot = na
var label c05MidDot = na
var line c06lo = na
var line c06up = na
var line c06mid = na
var label c06TargetLabel = na
var label c06LoDot = na
var label c06UpDot = na
var label c06MidDot = na
var line c07lo = na
var line c07up = na
var line c07mid = na
var label c07TargetLabel = na
var label c07LoDot = na
var label c07UpDot = na
var label c07MidDot = na
var line c08lo = na
var line c08up = na
var line c08mid = na
var label c08TargetLabel = na
var label c08LoDot = na
var label c08UpDot = na
var label c08MidDot = na
var line c09lo = na
var line c09up = na
var line c09mid = na
var label c09TargetLabel = na
var label c09LoDot = na
var label c09UpDot = na
var label c09MidDot = na
var line c10lo = na
var line c10up = na
var line c10mid = na
var label c10TargetLabel = na
var label c10LoDot = na
var label c10UpDot = na
var label c10MidDot = na

// ───── Draw Channels
[c01loNew, c01upNew, c01midNew, c01LowerNow, c01UpperNow, c01MidNow] = f_channel(c01lo, c01up, c01mid, cen01, cl011, cl012, ch01, c01l1y, c01l2y, c01hy)
c01lo := c01loNew
c01up := c01upNew
c01mid := c01midNew
[c02loNew, c02upNew, c02midNew, c02LowerNow, c02UpperNow, c02MidNow] = f_channel(c02lo, c02up, c02mid, cen02, cl021, cl022, ch02, c02l1y, c02l2y, c02hy)
c02lo := c02loNew
c02up := c02upNew
c02mid := c02midNew
[c03loNew, c03upNew, c03midNew, c03LowerNow, c03UpperNow, c03MidNow] = f_channel(c03lo, c03up, c03mid, cen03, cl031, cl032, ch03, c03l1y, c03l2y, c03hy)
c03lo := c03loNew
c03up := c03upNew
c03mid := c03midNew
[c04loNew, c04upNew, c04midNew, c04LowerNow, c04UpperNow, c04MidNow] = f_channel(c04lo, c04up, c04mid, cen04, cl041, cl042, ch04, c04l1y, c04l2y, c04hy)
c04lo := c04loNew
c04up := c04upNew
c04mid := c04midNew
[c05loNew, c05upNew, c05midNew, c05LowerNow, c05UpperNow, c05MidNow] = f_channel(c05lo, c05up, c05mid, cen05, cl051, cl052, ch05, c05l1y, c05l2y, c05hy)
c05lo := c05loNew
c05up := c05upNew
c05mid := c05midNew
[c06loNew, c06upNew, c06midNew, c06LowerNow, c06UpperNow, c06MidNow] = f_channel(c06lo, c06up, c06mid, cen06, cl061, cl062, ch06, c06l1y, c06l2y, c06hy)
c06lo := c06loNew
c06up := c06upNew
c06mid := c06midNew
[c07loNew, c07upNew, c07midNew, c07LowerNow, c07UpperNow, c07MidNow] = f_channel(c07lo, c07up, c07mid, cen07, cl071, cl072, ch07, c07l1y, c07l2y, c07hy)
c07lo := c07loNew
c07up := c07upNew
c07mid := c07midNew
[c08loNew, c08upNew, c08midNew, c08LowerNow, c08UpperNow, c08MidNow] = f_channel(c08lo, c08up, c08mid, cen08, cl081, cl082, ch08, c08l1y, c08l2y, c08hy)
c08lo := c08loNew
c08up := c08upNew
c08mid := c08midNew
[c09loNew, c09upNew, c09midNew, c09LowerNow, c09UpperNow, c09MidNow] = f_channel(c09lo, c09up, c09mid, cen09, cl091, cl092, ch09, c09l1y, c09l2y, c09hy)
c09lo := c09loNew
c09up := c09upNew
c09mid := c09midNew
[c10loNew, c10upNew, c10midNew, c10LowerNow, c10UpperNow, c10MidNow] = f_channel(c10lo, c10up, c10mid, cen10, cl101, cl102, ch10, c10l1y, c10l2y, c10hy)
c10lo := c10loNew
c10up := c10upNew
c10mid := c10midNew

// ───── Channel name dots: hover the projected end dots to identify each channel
c01LoDot := f_channel_dot(c01LoDot, cen01, c01lo, cn01, "Lower", chanCol)
c01UpDot := f_channel_dot(c01UpDot, cen01, c01up, cn01, "Upper", chanCol)
c01MidDot := f_channel_dot(c01MidDot, cen01 and showMid, c01mid, cn01, "Mid", midCol)
c02LoDot := f_channel_dot(c02LoDot, cen02, c02lo, cn02, "Lower", chanCol)
c02UpDot := f_channel_dot(c02UpDot, cen02, c02up, cn02, "Upper", chanCol)
c02MidDot := f_channel_dot(c02MidDot, cen02 and showMid, c02mid, cn02, "Mid", midCol)
c03LoDot := f_channel_dot(c03LoDot, cen03, c03lo, cn03, "Lower", chanCol)
c03UpDot := f_channel_dot(c03UpDot, cen03, c03up, cn03, "Upper", chanCol)
c03MidDot := f_channel_dot(c03MidDot, cen03 and showMid, c03mid, cn03, "Mid", midCol)
c04LoDot := f_channel_dot(c04LoDot, cen04, c04lo, cn04, "Lower", chanCol)
c04UpDot := f_channel_dot(c04UpDot, cen04, c04up, cn04, "Upper", chanCol)
c04MidDot := f_channel_dot(c04MidDot, cen04 and showMid, c04mid, cn04, "Mid", midCol)
c05LoDot := f_channel_dot(c05LoDot, cen05, c05lo, cn05, "Lower", chanCol)
c05UpDot := f_channel_dot(c05UpDot, cen05, c05up, cn05, "Upper", chanCol)
c05MidDot := f_channel_dot(c05MidDot, cen05 and showMid, c05mid, cn05, "Mid", midCol)
c06LoDot := f_channel_dot(c06LoDot, cen06, c06lo, cn06, "Lower", chanCol)
c06UpDot := f_channel_dot(c06UpDot, cen06, c06up, cn06, "Upper", chanCol)
c06MidDot := f_channel_dot(c06MidDot, cen06 and showMid, c06mid, cn06, "Mid", midCol)
c07LoDot := f_channel_dot(c07LoDot, cen07, c07lo, cn07, "Lower", chanCol)
c07UpDot := f_channel_dot(c07UpDot, cen07, c07up, cn07, "Upper", chanCol)
c07MidDot := f_channel_dot(c07MidDot, cen07 and showMid, c07mid, cn07, "Mid", midCol)
c08LoDot := f_channel_dot(c08LoDot, cen08, c08lo, cn08, "Lower", chanCol)
c08UpDot := f_channel_dot(c08UpDot, cen08, c08up, cn08, "Upper", chanCol)
c08MidDot := f_channel_dot(c08MidDot, cen08 and showMid, c08mid, cn08, "Mid", midCol)
c09LoDot := f_channel_dot(c09LoDot, cen09, c09lo, cn09, "Lower", chanCol)
c09UpDot := f_channel_dot(c09UpDot, cen09, c09up, cn09, "Upper", chanCol)
c09MidDot := f_channel_dot(c09MidDot, cen09 and showMid, c09mid, cn09, "Mid", midCol)
c10LoDot := f_channel_dot(c10LoDot, cen10, c10lo, cn10, "Lower", chanCol)
c10UpDot := f_channel_dot(c10UpDot, cen10, c10up, cn10, "Upper", chanCol)
c10MidDot := f_channel_dot(c10MidDot, cen10 and showMid, c10mid, cn10, "Mid", midCol)

// ───── Live current-candle targets
isBull = close > open
isBear = close < open
c01Target = isBull ? c01UpperNow : isBear ? c01LowerNow : c01MidNow
c02Target = isBull ? c02UpperNow : isBear ? c02LowerNow : c02MidNow
c03Target = isBull ? c03UpperNow : isBear ? c03LowerNow : c03MidNow
c04Target = isBull ? c04UpperNow : isBear ? c04LowerNow : c04MidNow
c05Target = isBull ? c05UpperNow : isBear ? c05LowerNow : c05MidNow
c06Target = isBull ? c06UpperNow : isBear ? c06LowerNow : c06MidNow
c07Target = isBull ? c07UpperNow : isBear ? c07LowerNow : c07MidNow
c08Target = isBull ? c08UpperNow : isBear ? c08LowerNow : c08MidNow
c09Target = isBull ? c09UpperNow : isBear ? c09LowerNow : c09MidNow
c10Target = isBull ? c10UpperNow : isBear ? c10LowerNow : c10MidNow

// Price-only labels at the potential current-candle channel intersection
c01TargetLabel := f_target_label(c01TargetLabel, cen01, c01Target, isBull, isBear)
c02TargetLabel := f_target_label(c02TargetLabel, cen02, c02Target, isBull, isBear)
c03TargetLabel := f_target_label(c03TargetLabel, cen03, c03Target, isBull, isBear)
c04TargetLabel := f_target_label(c04TargetLabel, cen04, c04Target, isBull, isBear)
c05TargetLabel := f_target_label(c05TargetLabel, cen05, c05Target, isBull, isBear)
c06TargetLabel := f_target_label(c06TargetLabel, cen06, c06Target, isBull, isBear)
c07TargetLabel := f_target_label(c07TargetLabel, cen07, c07Target, isBull, isBear)
c08TargetLabel := f_target_label(c08TargetLabel, cen08, c08Target, isBull, isBear)
c09TargetLabel := f_target_label(c09TargetLabel, cen09, c09Target, isBull, isBear)
c10TargetLabel := f_target_label(c10TargetLabel, cen10, c10Target, isBull, isBear)



// ───── Manual Horizontal Level Lines x20
levelGroup = "Manual Level Lines"
levelBackBars = input.int(500, "Level lines extend back candles", minval=0, maxval=5000, group=levelGroup)
levelW = input.int(1, "Level line width", minval=1, maxval=5, group=levelGroup)
levelCol = input.color(color.yellow, "Level line color", group=levelGroup)
showLevelNameDots = input.bool(true, "Show level name dots", group=levelGroup, tooltip="Adds a small dot at the right end of each enabled manual level. Hover the dot to see the level name.")
levelDotTransp = input.int(0, "Level dot transparency", minval=0, maxval=100, group=levelGroup)

f_level(_ln, _dot, _enabled, _price, _name) =>
    line ln = _ln
    label dot = _dot
    if barstate.islast
        valid = _enabled and _price > 0
        x1 = bar_index - levelBackBars
        x2 = bar_index + extendBars
        if valid
            if na(ln)
                ln := line.new(x1, _price, x2, _price, xloc=xloc.bar_index, extend=extend.none, color=levelCol, width=levelW)
            else
                line.set_xy1(ln, x1, _price)
                line.set_xy2(ln, x2, _price)
                line.set_extend(ln, extend.none)
                line.set_color(ln, levelCol)
                line.set_width(ln, levelW)
            if showLevelNameDots
                dotText = str.length(_name) > 0 ? _name + " @ " + str.tostring(_price, format.mintick) : "Level @ " + str.tostring(_price, format.mintick)
                if na(dot)
                    dot := label.new(x2, _price, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_circle, color=color.new(levelCol, levelDotTransp), textcolor=color.white, size=size.tiny, tooltip=dotText)
                else
                    label.set_xy(dot, x2, _price)
                    label.set_style(dot, label.style_circle)
                    label.set_color(dot, color.new(levelCol, levelDotTransp))
                    label.set_textcolor(dot, color.white)
                    label.set_size(dot, size.tiny)
                    label.set_text(dot, "")
                    label.set_tooltip(dot, dotText)
            else
                if not na(dot)
                    label.delete(dot)
                    dot := na
        else
            if not na(ln)
                line.delete(ln)
                ln := na
            if not na(dot)
                label.delete(dot)
                dot := na
    [ln, dot]

// ───── Level Inputs
lvg01 = "Level 01"
len01 = input.bool(false, "Enable 01", group=lvg01)
lprice01 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg01)
lname01 = input.string("LVL01", "Level name", group=lvg01, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg02 = "Level 02"
len02 = input.bool(false, "Enable 02", group=lvg02)
lprice02 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg02)
lname02 = input.string("LVL02", "Level name", group=lvg02, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg03 = "Level 03"
len03 = input.bool(false, "Enable 03", group=lvg03)
lprice03 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg03)
lname03 = input.string("LVL03", "Level name", group=lvg03, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg04 = "Level 04"
len04 = input.bool(false, "Enable 04", group=lvg04)
lprice04 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg04)
lname04 = input.string("LVL04", "Level name", group=lvg04, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg05 = "Level 05"
len05 = input.bool(false, "Enable 05", group=lvg05)
lprice05 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg05)
lname05 = input.string("LVL05", "Level name", group=lvg05, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg06 = "Level 06"
len06 = input.bool(false, "Enable 06", group=lvg06)
lprice06 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg06)
lname06 = input.string("LVL06", "Level name", group=lvg06, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg07 = "Level 07"
len07 = input.bool(false, "Enable 07", group=lvg07)
lprice07 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg07)
lname07 = input.string("LVL07", "Level name", group=lvg07, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg08 = "Level 08"
len08 = input.bool(false, "Enable 08", group=lvg08)
lprice08 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg08)
lname08 = input.string("LVL08", "Level name", group=lvg08, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg09 = "Level 09"
len09 = input.bool(false, "Enable 09", group=lvg09)
lprice09 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg09)
lname09 = input.string("LVL09", "Level name", group=lvg09, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg10 = "Level 10"
len10 = input.bool(false, "Enable 10", group=lvg10)
lprice10 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg10)
lname10 = input.string("LVL10", "Level name", group=lvg10, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg11 = "Level 11"
len11 = input.bool(false, "Enable 11", group=lvg11)
lprice11 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg11)
lname11 = input.string("LVL11", "Level name", group=lvg11, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg12 = "Level 12"
len12 = input.bool(false, "Enable 12", group=lvg12)
lprice12 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg12)
lname12 = input.string("LVL12", "Level name", group=lvg12, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg13 = "Level 13"
len13 = input.bool(false, "Enable 13", group=lvg13)
lprice13 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg13)
lname13 = input.string("LVL13", "Level name", group=lvg13, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg14 = "Level 14"
len14 = input.bool(false, "Enable 14", group=lvg14)
lprice14 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg14)
lname14 = input.string("LVL14", "Level name", group=lvg14, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg15 = "Level 15"
len15 = input.bool(false, "Enable 15", group=lvg15)
lprice15 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg15)
lname15 = input.string("LVL15", "Level name", group=lvg15, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg16 = "Level 16"
len16 = input.bool(false, "Enable 16", group=lvg16)
lprice16 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg16)
lname16 = input.string("LVL16", "Level name", group=lvg16, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg17 = "Level 17"
len17 = input.bool(false, "Enable 17", group=lvg17)
lprice17 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg17)
lname17 = input.string("LVL17", "Level name", group=lvg17, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg18 = "Level 18"
len18 = input.bool(false, "Enable 18", group=lvg18)
lprice18 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg18)
lname18 = input.string("LVL18", "Level name", group=lvg18, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg19 = "Level 19"
len19 = input.bool(false, "Enable 19", group=lvg19)
lprice19 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg19)
lname19 = input.string("LVL19", "Level name", group=lvg19, tooltip="Name shown when hovering the dot at the right end of this level line.")

lvg20 = "Level 20"
len20 = input.bool(false, "Enable 20", group=lvg20)
lprice20 = input.float(0.0, "Price", minval=0.0, step=0.01, group=lvg20)
lname20 = input.string("LVL20", "Level name", group=lvg20, tooltip="Name shown when hovering the dot at the right end of this level line.")

// ───── Level Vars
var line lvl01Line = na
var label lvl01Dot = na
var line lvl02Line = na
var label lvl02Dot = na
var line lvl03Line = na
var label lvl03Dot = na
var line lvl04Line = na
var label lvl04Dot = na
var line lvl05Line = na
var label lvl05Dot = na
var line lvl06Line = na
var label lvl06Dot = na
var line lvl07Line = na
var label lvl07Dot = na
var line lvl08Line = na
var label lvl08Dot = na
var line lvl09Line = na
var label lvl09Dot = na
var line lvl10Line = na
var label lvl10Dot = na
var line lvl11Line = na
var label lvl11Dot = na
var line lvl12Line = na
var label lvl12Dot = na
var line lvl13Line = na
var label lvl13Dot = na
var line lvl14Line = na
var label lvl14Dot = na
var line lvl15Line = na
var label lvl15Dot = na
var line lvl16Line = na
var label lvl16Dot = na
var line lvl17Line = na
var label lvl17Dot = na
var line lvl18Line = na
var label lvl18Dot = na
var line lvl19Line = na
var label lvl19Dot = na
var line lvl20Line = na
var label lvl20Dot = na

// ───── Draw Manual Levels
[lvl01LineNew, lvl01DotNew] = f_level(lvl01Line, lvl01Dot, len01, lprice01, lname01)
lvl01Line := lvl01LineNew
lvl01Dot := lvl01DotNew
[lvl02LineNew, lvl02DotNew] = f_level(lvl02Line, lvl02Dot, len02, lprice02, lname02)
lvl02Line := lvl02LineNew
lvl02Dot := lvl02DotNew
[lvl03LineNew, lvl03DotNew] = f_level(lvl03Line, lvl03Dot, len03, lprice03, lname03)
lvl03Line := lvl03LineNew
lvl03Dot := lvl03DotNew
[lvl04LineNew, lvl04DotNew] = f_level(lvl04Line, lvl04Dot, len04, lprice04, lname04)
lvl04Line := lvl04LineNew
lvl04Dot := lvl04DotNew
[lvl05LineNew, lvl05DotNew] = f_level(lvl05Line, lvl05Dot, len05, lprice05, lname05)
lvl05Line := lvl05LineNew
lvl05Dot := lvl05DotNew
[lvl06LineNew, lvl06DotNew] = f_level(lvl06Line, lvl06Dot, len06, lprice06, lname06)
lvl06Line := lvl06LineNew
lvl06Dot := lvl06DotNew
[lvl07LineNew, lvl07DotNew] = f_level(lvl07Line, lvl07Dot, len07, lprice07, lname07)
lvl07Line := lvl07LineNew
lvl07Dot := lvl07DotNew
[lvl08LineNew, lvl08DotNew] = f_level(lvl08Line, lvl08Dot, len08, lprice08, lname08)
lvl08Line := lvl08LineNew
lvl08Dot := lvl08DotNew
[lvl09LineNew, lvl09DotNew] = f_level(lvl09Line, lvl09Dot, len09, lprice09, lname09)
lvl09Line := lvl09LineNew
lvl09Dot := lvl09DotNew
[lvl10LineNew, lvl10DotNew] = f_level(lvl10Line, lvl10Dot, len10, lprice10, lname10)
lvl10Line := lvl10LineNew
lvl10Dot := lvl10DotNew
[lvl11LineNew, lvl11DotNew] = f_level(lvl11Line, lvl11Dot, len11, lprice11, lname11)
lvl11Line := lvl11LineNew
lvl11Dot := lvl11DotNew
[lvl12LineNew, lvl12DotNew] = f_level(lvl12Line, lvl12Dot, len12, lprice12, lname12)
lvl12Line := lvl12LineNew
lvl12Dot := lvl12DotNew
[lvl13LineNew, lvl13DotNew] = f_level(lvl13Line, lvl13Dot, len13, lprice13, lname13)
lvl13Line := lvl13LineNew
lvl13Dot := lvl13DotNew
[lvl14LineNew, lvl14DotNew] = f_level(lvl14Line, lvl14Dot, len14, lprice14, lname14)
lvl14Line := lvl14LineNew
lvl14Dot := lvl14DotNew
[lvl15LineNew, lvl15DotNew] = f_level(lvl15Line, lvl15Dot, len15, lprice15, lname15)
lvl15Line := lvl15LineNew
lvl15Dot := lvl15DotNew
[lvl16LineNew, lvl16DotNew] = f_level(lvl16Line, lvl16Dot, len16, lprice16, lname16)
lvl16Line := lvl16LineNew
lvl16Dot := lvl16DotNew
[lvl17LineNew, lvl17DotNew] = f_level(lvl17Line, lvl17Dot, len17, lprice17, lname17)
lvl17Line := lvl17LineNew
lvl17Dot := lvl17DotNew
[lvl18LineNew, lvl18DotNew] = f_level(lvl18Line, lvl18Dot, len18, lprice18, lname18)
lvl18Line := lvl18LineNew
lvl18Dot := lvl18DotNew
[lvl19LineNew, lvl19DotNew] = f_level(lvl19Line, lvl19Dot, len19, lprice19, lname19)
lvl19Line := lvl19LineNew
lvl19Dot := lvl19DotNew
[lvl20LineNew, lvl20DotNew] = f_level(lvl20Line, lvl20Dot, len20, lprice20, lname20)
lvl20Line := lvl20LineNew
lvl20Dot := lvl20DotNew

// ───── BO / BD Channel signals
sigReady = signalOnCloseOnly ? barstate.isconfirmed : true
ch01BO = showSignals and sigReady and cen01 and not na(c01UpperNow) and ta.crossover(close, c01UpperNow)
ch01BD = showSignals and sigReady and cen01 and not na(c01LowerNow) and ta.crossunder(close, c01LowerNow)
ch02BO = showSignals and sigReady and cen02 and not na(c02UpperNow) and ta.crossover(close, c02UpperNow)
ch02BD = showSignals and sigReady and cen02 and not na(c02LowerNow) and ta.crossunder(close, c02LowerNow)
ch03BO = showSignals and sigReady and cen03 and not na(c03UpperNow) and ta.crossover(close, c03UpperNow)
ch03BD = showSignals and sigReady and cen03 and not na(c03LowerNow) and ta.crossunder(close, c03LowerNow)
ch04BO = showSignals and sigReady and cen04 and not na(c04UpperNow) and ta.crossover(close, c04UpperNow)
ch04BD = showSignals and sigReady and cen04 and not na(c04LowerNow) and ta.crossunder(close, c04LowerNow)
ch05BO = showSignals and sigReady and cen05 and not na(c05UpperNow) and ta.crossover(close, c05UpperNow)
ch05BD = showSignals and sigReady and cen05 and not na(c05LowerNow) and ta.crossunder(close, c05LowerNow)
ch06BO = showSignals and sigReady and cen06 and not na(c06UpperNow) and ta.crossover(close, c06UpperNow)
ch06BD = showSignals and sigReady and cen06 and not na(c06LowerNow) and ta.crossunder(close, c06LowerNow)
ch07BO = showSignals and sigReady and cen07 and not na(c07UpperNow) and ta.crossover(close, c07UpperNow)
ch07BD = showSignals and sigReady and cen07 and not na(c07LowerNow) and ta.crossunder(close, c07LowerNow)
ch08BO = showSignals and sigReady and cen08 and not na(c08UpperNow) and ta.crossover(close, c08UpperNow)
ch08BD = showSignals and sigReady and cen08 and not na(c08LowerNow) and ta.crossunder(close, c08LowerNow)
ch09BO = showSignals and sigReady and cen09 and not na(c09UpperNow) and ta.crossover(close, c09UpperNow)
ch09BD = showSignals and sigReady and cen09 and not na(c09LowerNow) and ta.crossunder(close, c09LowerNow)
ch10BO = showSignals and sigReady and cen10 and not na(c10UpperNow) and ta.crossover(close, c10UpperNow)
ch10BD = showSignals and sigReady and cen10 and not na(c10LowerNow) and ta.crossunder(close, c10LowerNow)

anyBO = ch01BO or ch02BO or ch03BO or ch04BO or ch05BO or ch06BO or ch07BO or ch08BO or ch09BO or ch10BO
anyBD = ch01BD or ch02BD or ch03BD or ch04BD or ch05BD or ch06BD or ch07BD or ch08BD or ch09BD or ch10BD

plotshape(anyBO, title="BO", text="BO", style=shape.labelup, location=location.belowbar, color=boCol, textcolor=color.white, size=size.tiny)
plotshape(anyBD, title="BD", text="BD", style=shape.labeldown, location=location.abovebar, color=bdCol, textcolor=color.white, size=size.tiny)

alertcondition(anyBO, title="BO Signal", message="BO: price crossed above an enabled channel upper line.")
alertcondition(anyBD, title="BD Signal", message="BD: price crossed below an enabled channel lower line.")

// Optional live target table
targetSide = isBull ? "Bull → Upper" : isBear ? "Bear → Lower" : "Doji → Mid"
var table t = table.new(position.top_right, 3, 11, border_width=1)
if barstate.islast and showTargetTable
    table.cell(t, 0, 0, "Channel", text_color=color.white)
    table.cell(t, 1, 0, "Target", text_color=color.white)
    table.cell(t, 2, 0, "Logic", text_color=color.white)
    table.cell(t, 0, 1, "CH01", text_color=color.white)
    table.cell(t, 1, 1, cen01 and not na(c01Target) ? str.tostring(c01Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 1, cen01 and not na(c01Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 2, "CH02", text_color=color.white)
    table.cell(t, 1, 2, cen02 and not na(c02Target) ? str.tostring(c02Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 2, cen02 and not na(c02Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 3, "CH03", text_color=color.white)
    table.cell(t, 1, 3, cen03 and not na(c03Target) ? str.tostring(c03Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 3, cen03 and not na(c03Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 4, "CH04", text_color=color.white)
    table.cell(t, 1, 4, cen04 and not na(c04Target) ? str.tostring(c04Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 4, cen04 and not na(c04Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 5, "CH05", text_color=color.white)
    table.cell(t, 1, 5, cen05 and not na(c05Target) ? str.tostring(c05Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 5, cen05 and not na(c05Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 6, "CH06", text_color=color.white)
    table.cell(t, 1, 6, cen06 and not na(c06Target) ? str.tostring(c06Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 6, cen06 and not na(c06Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 7, "CH07", text_color=color.white)
    table.cell(t, 1, 7, cen07 and not na(c07Target) ? str.tostring(c07Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 7, cen07 and not na(c07Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 8, "CH08", text_color=color.white)
    table.cell(t, 1, 8, cen08 and not na(c08Target) ? str.tostring(c08Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 8, cen08 and not na(c08Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 9, "CH09", text_color=color.white)
    table.cell(t, 1, 9, cen09 and not na(c09Target) ? str.tostring(c09Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 9, cen09 and not na(c09Target) ? targetSide : "-", text_color=color.white)
    table.cell(t, 0, 10, "CH10", text_color=color.white)
    table.cell(t, 1, 10, cen10 and not na(c10Target) ? str.tostring(c10Target, format.mintick) : "Off", text_color=color.white)
    table.cell(t, 2, 10, cen10 and not na(c10Target) ? targetSide : "-", text_color=color.white)
if barstate.islast and not showTargetTable
    table.clear(t, 0, 0, 2, 10)
````
