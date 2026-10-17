# Enhanced Volume

- url: https://www.tradingview.com/script/63Lu7zlv-Enhanced-Volume/
- type: indicator
- pine_id: PUB;28feeb996349456c9018dbb5c964b5ca
- version: 2.0

## Description

Enhanced Volume (EV)
A comprehensive volume analysis tool designed to give traders a complete picture of buying and selling activity at a glance.

Key Features:
Relative Volume Colour Coding
Bars are automatically colour-coded based on volume significance — high relative volume bars stand out immediately, while low relative volume bars are flagged to help you avoid low-conviction moves.
Smart Labels
Automatically labels notable volume events directly on the chart:

High relative volume bars (2× average and above)
Highest volume in the past year (HV1Y)
Highest volume ever recorded for the instrument (★ HVE)

All labels display the raw volume figure and the percentage above average so you can assess conviction instantly.
Projected Volume
During the trading session, a projected end-of-day volume bar is calculated based on the current rate of flow. A projected run-rate percentage tells you whether today is on track to be a high or low volume day before the session closes.
2× and 3× Average Lines
Visual reference lines show exactly where 2× and 3× average volume sit, making it easy to gauge how significant the current bar really is.
Up/Down Volume Ratio
Tracks cumulative buying versus selling volume over a configurable lookback period, giving you a directional bias reading based on actual volume flow rather than price alone.
Summary Table
A clean on-chart table displays all key metrics in one place — current volume, average volume, average dollar volume, up/down ratio, relative volume percentage, projected volume, and volume ratio.
Inputs:

SMA length for average volume calculation
High and low relative volume thresholds
1-year lookback period for HV1Y detection
Up/Down volume lookback period
Toggle projected volume bar and 2×/3× lines on or off
Full colour customisation for all bar states

Built for momentum and breakout traders who use volume as a primary confirmation tool.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jimmy_Trader

//@version=6
indicator("Enhanced Volume", shorttitle="EV", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
length_sma              = input.int(50,    "SMA Length",                              minval=1)
high_rel_vol_threshold  = input.float(2.0, "High Relative Volume Threshold",          minval=1.0, step=0.1)
low_rel_vol_threshold   = input.float(0.4, "Low Relative Volume Threshold",           minval=0.1, step=0.1)
lookback_period         = input.int(252,   "Lookback Period for Highest Volume (1Y)", minval=1)
Up_Down_Period          = input.int(50,    "Up/Down Volume Length")

// ─── COLOURS ──────────────────────────────────────────────────────────────────
HighRelColour = input.color(color.lime,                 "High Relative Volume",  group="Bar Colours")
lowRelColor   = input.color(color.orange,               "Low Relative Volume",   group="Bar Colours")
upColour      = input.color(color.rgb(219, 224, 230),   "Up Bar",                group="Bar Colours")
downColour    = input.color(color.rgb(219, 224, 230),   "Down Bar",              group="Bar Colours")

// ─── PROJECTED VOLUME ─────────────────────────────────────────────────────────
showProjected = input.bool(true,                        "Show Projected Volume Bar",    inline="proj", group="Projected Volume")
projColor     = input.color(color.new(color.aqua, 80),  " ",                            inline="proj", group="Projected Volume")
showLines     = input.bool(true,                        "Show 2x / 3x Volume Lines",    group="Projected Volume")

// ─── VOLUME CALCULATIONS ──────────────────────────────────────────────────────
vol         = volume
sma_vol     = ta.sma(vol, length_sma)
vol_ratio   = vol / sma_vol                            // e.g. 2.0 = 2× average

is_high_rel_vol = vol_ratio >= high_rel_vol_threshold
is_low_rel_vol  = vol_ratio < low_rel_vol_threshold

// Relative volume expressed as a % change (for labels/table)
rel_vol_pct = (vol_ratio - 1.0) * 100.0

// Highest volume over lookback and all-time
highest_vol_1y  = ta.highest(vol, lookback_period)
is_highest_1y   = vol >= highest_vol_1y and vol > 0
is_hve          = ta.highest(volume, math.min(11000, bar_index + 1)) == volume

// Closing range — upper 50% = strong close
close_range      = (close - low) / (high - low) * 100
high_close_range = close_range >= 50

// ─── BAR COLOURS ──────────────────────────────────────────────────────────────
barColor = is_high_rel_vol          ? HighRelColour :
           is_low_rel_vol and vol < vol[1] ? lowRelColor :
           vol > vol[1]             ? upColour : downColour

plotcandle(0, vol, 0, vol, title="Volume Bars", bordercolor=barColor, color=barColor, wickcolor=barColor)
plot(sma_vol, title="Volume SMA", color=color.blue)

// ─── LABELS ───────────────────────────────────────────────────────────────────
// High relative volume (not a 1Y high)
if is_high_rel_vol and vol_ratio < high_rel_vol_threshold * 2 and not is_highest_1y
    label.new(bar_index, vol,
     text  = str.tostring(volume, format.volume) + " (+" + str.tostring(rel_vol_pct, "#") + "%)",
     color = color.white, style = label.style_label_down,
     textcolor = color.black, yloc = yloc.price, size = size.small)

// Very high relative volume (2×+ threshold, not a 1Y high)
if vol_ratio >= high_rel_vol_threshold * 2 and not is_highest_1y
    label.new(bar_index, vol,
     text  = str.tostring(volume, format.volume) + " (+" + str.tostring(rel_vol_pct, "#") + "%)",
     color = color.white, style = label.style_label_down,
     textcolor = color.black, yloc = yloc.price, size = size.small)

// 1Y high or HVE
if is_highest_1y or is_hve
    hveText = is_hve ? " ★ HVE" : " HV1Y"
    label.new(bar_index, y=volume,
     text  = str.tostring(volume, format.volume) + " (+" + str.tostring(rel_vol_pct, "#") + "%)" + hveText,
     color = color.purple, style = label.style_label_down,
     textcolor = color.white, yloc = yloc.price, size = size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(is_high_rel_vol and high_close_range, title="High Relative Volume Alert",   message="High Relative Volume with Strong Close detected!")
alertcondition(is_highest_1y,                        title="Highest Volume in Year Alert", message="Highest Volume in Over a Year detected!")
alertcondition(is_hve,                               title="Highest Volume Ever Alert",    message="New All-Time Highest Volume detected!")

// ─── UP/DOWN VOLUME RATIO ─────────────────────────────────────────────────────
isUp   = close > close[1]
isDown = close < close[1]

upVolume    = isUp   ? volume : 0.0
downVolume  = isDown ? volume : 0.0

sumUpVol    = math.sum(upVolume,   Up_Down_Period)
sumDownVol  = math.sum(downVolume, Up_Down_Period)

upDownRatio = sumDownVol != 0 ? sumUpVol / sumDownVol : na

// ─── PROJECTED VOLUME ─────────────────────────────────────────────────────────
avg_dollar_vol = ta.sma(vol * close, length_sma)

float volSec  = na
float projVol = volume

timePassed = timenow - time
timeLeft   = time_close - timenow

if timeLeft > 0
    volSec  := volume / timePassed
    projVol := volume + (volSec * timeLeft)

runRate = (projVol / sma_vol * 100) - 100

isIntraday = timeLeft > 0 and timeframe.isdaily

plotcandle(0, isIntraday and showProjected ? projVol : na, 0, isIntraday and showProjected ? projVol : na,
 title="Projected Volume", bordercolor=projColor, color=projColor, wickcolor=projColor)

// ─── 2× / 3× LINES ───────────────────────────────────────────────────────────
twoX   = sma_vol * 2
threeX = sma_vol * 3

var line twoXLine   = na
var line threeXLine = na

if barstate.islast and showLines and timeframe.isdaily
    if not na(twoXLine)
        twoXLine.delete()
    if not na(threeXLine)
        threeXLine.delete()
    twoXLine   := line.new(bar_index[1], twoX,   bar_index + 1, twoX,   color=color.gray, width=2)
    threeXLine := line.new(bar_index[1], threeX, bar_index + 1, threeX, color=color.gray, width=2)

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_left, 8, 1,
 bgcolor=color.white, frame_width=1, frame_color=color.black,
 border_color=color.black, border_width=1)

if barstate.islast//
    table.cell(tbl, 0, 0, "Volume : "       + str.tostring(volume,        format.volume),                       text_color=color.black,                              text_size=size.small)
    table.cell(tbl, 1, 0, "Avg Vol : "      + str.tostring(sma_vol,       format.volume),                       text_color=color.black,                              text_size=size.small)
    table.cell(tbl, 2, 0, "Avg $ Vol : "    + str.tostring(avg_dollar_vol, format.volume),                      text_color=color.black,                              text_size=size.small)
    table.cell(tbl, 3, 0, "Up/Dn Vol : "    + str.format("{0,number,#.##}", upDownRatio),                       text_color=upDownRatio >= 1 ? color.green : color.red, text_size=size.small)
    table.cell(tbl, 4, 0, "Rel Vol : "      + str.format("{0,number,+#.#;-#.#}", rel_vol_pct) + "%",           text_color=rel_vol_pct > 0 ? color.green : color.black, text_size=size.small)
    table.cell(tbl, 5, 0, "Proj Run Rate : "+ str.format("{0,number,+#.#;-#.#}", runRate) + "%",               text_color=color.black,                              text_size=size.small)
    table.cell(tbl, 6, 0, "Proj Vol : "     + str.tostring(projVol,       format.volume),                       text_color=color.black,                              text_size=size.small)
    table.cell(tbl, 7, 0, "Vol Ratio : "    + str.format("{0,number,#.##}x", vol_ratio),                       text_color=is_high_rel_vol ? color.green : color.black, text_size=size.small)
````
