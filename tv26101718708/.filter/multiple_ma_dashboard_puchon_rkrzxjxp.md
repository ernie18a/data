# Multiple MA Dashboard [PUCHON]

- url: https://www.tradingview.com/script/RkrZXJXP-Multiple-MA-Dashboard-PUCHON/
- type: indicator
- pine_id: PUB;3c02587674a0431bb43840f0d23cb51f
- version: 3.0

## Description

[b]📊 Multiple MA Dashboard [PUCHON][/b]

The [b]Multiple MA Dashboard[/b] plots up to 5 moving averages of a chosen type (EMA, SMA, WMA, or RMA) directly on your chart and summarizes their relationship to price in a clean, real-time table. Instead of eyeballing where price sits relative to each average, this indicator gives you an instant Up/Down read and the exact percentage distance for every MA.

[b]✨ Features:[/b]

- 📈 [b]5 Configurable Moving Averages:[/b] Set independent lengths (defaults: 10, 20, 50, 100, 200) sharing one MA type and source.
- 🔁 [b]Switchable MA Type:[/b] Choose between EMA, SMA, WMA, and RMA from a single dropdown — all 5 lines update together.
- 📋 [b]Live Dashboard Table:[/b] Displays each MA's label, trend direction (Up/Down), and percentage distance from price, refreshed on the latest bar.
- 🎨 [b]Dynamic Trend Coloring:[/b] Lines, fills, and table text automatically switch between your chosen "Up" and "Down" colors based on whether price is above or below each MA.
- 🌈 [b]Price-to-MA Fill Zones:[/b] Shaded regions between price and each MA make the gap easy to see at a glance.
- ⚙️ [b]Fully Customizable:[/b] Adjust MA lengths, source, dashboard position, text size, and theme colors to fit your setup.

[b]🧮 Calculation Logic:[/b]

The core [b]getMa[/b] function selects the moving average algorithm based on the user's choice, while each MA's color and table row are derived from a simple comparison between price and that MA.

[pine]
getMa(simple string type, series float src, simple int len) =>
    switch type
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        "RMA" => ta.rma(src, len)
        => ta.ema(src, len)
[/pine]

[b]💡 Interpretation:[/b]

- 🟢 [b]Up (price > MA):[/b] Price is trading above the average — shown in your "Up Trend" color with a positive % distance.
- 🔴 [b]Down (price < MA):[/b] Price is trading below the average — shown in your "Down Trend" color with a negative % distance.
- 📏 [b]% Change:[/b] The percentage gap between price and each MA, useful for gauging how stretched or compressed price is relative to that average.

[b]⚠️ Disclaimer:[/b]
This tool is provided for educational and informational purposes only. It does not constitute financial advice and does not guarantee future performance. Always combine it with your own analysis and proper risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Pine Expert

//@version=6
indicator("Multiple MA Dashboard", shorttitle="Multi MA", overlay=true)

// ————— Constants
string  MA_EMA = "EMA"
string  MA_SMA = "SMA"
string  MA_WMA = "WMA"
string  MA_RMA = "RMA"

// ————— Inputs
// 1. Moving Average Settings
string  maTypeInput   = input.string(MA_EMA, "MA Type", options = [MA_EMA, MA_SMA, MA_WMA, MA_RMA], group = "Moving Average Settings")
float   srcInput      = input.source(close,  "Source",                                              group = "Moving Average Settings")
bool    paintBarInput = input.bool(true,     "Color Candles by Volume",                             group = "Moving Average Settings")

int     len1Input     = input.int(10,  "MA 1 Length", inline = "L1", group = "Moving Average Settings")
color   col1Input     = input.color(#FF1100, "",      inline = "L1", group = "Moving Average Settings")

int     len2Input     = input.int(20,  "MA 2 Length", inline = "L2", group = "Moving Average Settings")
color   col2Input     = input.color(#FF8800, "",      inline = "L2", group = "Moving Average Settings")

int     len3Input     = input.int(50,  "MA 3 Length", inline = "L3", group = "Moving Average Settings")
color   col3Input     = input.color(#FFDD00, "",      inline = "L3", group = "Moving Average Settings")

int     len4Input     = input.int(100, "MA 4 Length", inline = "L4", group = "Moving Average Settings")
color   col4Input     = input.color(#00CC00, "",      inline = "L4", group = "Moving Average Settings")

int     len5Input     = input.int(200, "MA 5 Length", inline = "L5", group = "Moving Average Settings")
color   col5Input     = input.color(#0044FF, "",      inline = "L5", group = "Moving Average Settings")

// 2. Dashboard Settings
string  tbPosInput    = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = "Dashboard Settings")
string  txtSizeInput  = input.string("Small",        "Text Size",          options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Dashboard Settings")

// 3. Theme Colors (สำหรับใช้กับตัวหนังสือในตาราง Dashboard และสีแท่งเทียน)
color   upColorInput  = input.color(color.teal, "Up Trend Color",   group = "Theme Colors")
color   dnColorInput  = input.color(color.red,  "Down Trend Color", group = "Theme Colors")

// ————— Functions
getMa(simple string type, series float src, simple int len) =>
    switch type
        MA_EMA => ta.ema(src, len)
        MA_SMA => ta.sma(src, len)
        MA_WMA => ta.wma(src, len)
        MA_RMA => ta.rma(src, len)
        => ta.ema(src, len)

getTablePos(simple string pos) =>
    switch pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        => position.bottom_right

getTextSize(simple string sz) =>
    switch sz
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_updateTableRow(table tbl, int rIndex, string maName, float maVal, float src, color upCol, color dnCol, string tSize) =>
    float pctDiff = ((src - maVal) / maVal) * 100
    bool  isUp    = src > maVal
    
    string dirStr = isUp ? "Up" : "Down"
    color  tColor = isUp ? upCol : dnCol
    string pctStr = (pctDiff > 0 ? "+" : "") + str.tostring(pctDiff, "#.##") + "%"

    table.cell(tbl, 0, rIndex, maName, text_color = color.white, text_size = tSize)
    table.cell(tbl, 1, rIndex, dirStr, text_color = tColor,      text_size = tSize)
    table.cell(tbl, 2, rIndex, pctStr, text_color = tColor,      text_size = tSize)

// ————— Calculations
float ma1 = getMa(maTypeInput, srcInput, len1Input)
float ma2 = getMa(maTypeInput, srcInput, len2Input)
float ma3 = getMa(maTypeInput, srcInput, len3Input)
float ma4 = getMa(maTypeInput, srcInput, len4Input)
float ma5 = getMa(maTypeInput, srcInput, len5Input)

// ประเมินเทรนด์หลัก (ใช้ MA1 เป็นเกณฑ์สำหรับสีของแท่งเทียน)
color trendColorMain = srcInput > ma1 ? upColorInput : dnColorInput

// ————— Visuals
p_src = plot(srcInput, title="Price Anchor", display=display.none, editable=false)

// วาดเส้น MA ด้วยสี Custom ที่ผู้ใช้เลือก
p_ma1 = plot(ma1, title="MA 1 Line", color=col1Input, linewidth=1)
p_ma2 = plot(ma2, title="MA 2 Line", color=col2Input, linewidth=2)
p_ma3 = plot(ma3, title="MA 3 Line", color=col3Input, linewidth=3)
p_ma4 = plot(ma4, title="MA 4 Line", color=col4Input, linewidth=4)
p_ma5 = plot(ma5, title="MA 5 Line", color=col5Input, linewidth=5)

// เติมสี Gradient ให้เข้ากับสีเส้นที่เลือก (โปร่งใสที่แท่งเทียน และเข้มขึ้นที่เส้น MA)
fill(p_ma1, p_src, srcInput, ma1, color(na), color.new(col1Input, 88))
fill(p_ma2, p_src, srcInput, ma2, color(na), color.new(col2Input, 88))
fill(p_ma3, p_src, srcInput, ma3, color(na), color.new(col3Input, 90))
fill(p_ma4, p_src, srcInput, ma4, color(na), color.new(col4Input, 92))
fill(p_ma5, p_src, srcInput, ma5, color(na), color.new(col5Input, 92))

// สีแท่งเทียน Volume (อิงจากทิศทางของราคาเทียบกับ MA 1)
float volNorm   = ta.stdev(volume, 200)
float nVol      = volNorm > 0 ? math.min(4., volume / volNorm) : 1.
color candleCol = color.from_gradient(nVol, 0, 4, color.new(trendColorMain, 70), trendColorMain)
barcolor(paintBarInput ? candleCol : na)

// ┌────────────────────────────── Dashboard Table ───────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
string dashSize = getTextSize(txtSizeInput)

var table dashTable = table.new(getTablePos(tbPosInput), columns = 3, rows = 6, bgcolor = color.new(color.black, 70), border_color = color.new(color.gray, 50), border_width = 1)

if barstate.islast
    table.cell(dashTable, 0, 0, "Moving Average", text_color = color.white, bgcolor = color.new(color.gray, 70), text_size = dashSize)
    table.cell(dashTable, 1, 0, "Up/Down",        text_color = color.white, bgcolor = color.new(color.gray, 70), text_size = dashSize)
    table.cell(dashTable, 2, 0, "% Change",       text_color = color.white, bgcolor = color.new(color.gray, 70), text_size = dashSize)

    f_updateTableRow(dashTable, 1, maTypeInput + " " + str.tostring(len1Input), ma1, srcInput, upColorInput, dnColorInput, dashSize)
    f_updateTableRow(dashTable, 2, maTypeInput + " " + str.tostring(len2Input), ma2, srcInput, upColorInput, dnColorInput, dashSize)
    f_updateTableRow(dashTable, 3, maTypeInput + " " + str.tostring(len3Input), ma3, srcInput, upColorInput, dnColorInput, dashSize)
    f_updateTableRow(dashTable, 4, maTypeInput + " " + str.tostring(len4Input), ma4, srcInput, upColorInput, dnColorInput, dashSize)
    f_updateTableRow(dashTable, 5, maTypeInput + " " + str.tostring(len5Input), ma5, srcInput, upColorInput, dnColorInput, dashSize)
````
