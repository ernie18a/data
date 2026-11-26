# Moving Averages For All Timeframes with labels

- url: https://www.tradingview.com/script/UXyvThCY-Moving-Averages-For-All-Timeframes-with-labels/
- type: indicator
- pine_id: PUB;0f694d5e8350488a8de7fac9dd0ea027
- version: 1.0

## Description

[i][b]Moving Averages For All Timeframes with labels[/b][/i]

[b]Moving Average Configurations[/b]
The script is pre-configured with industry-standard default settings to help you identify short-term momentum and long-term trend shifts instantly.

[b]Intraday (Standard Momentum) [/b]
Focuses on fast-acting averages for scalping and day trading:
5 SMA: Ultra-short momentum tracker.
8 SMA: Short-term trend guide.
13 SMA: Core intraday trend anchor.

[b]Daily (The "Gold Standard") [/b]
Utilizes the most widely watched levels by institutional traders:
9 SMA: Short-term momentum.
21 EMA: The "Mean" often used for trend-following entries.
50 SMA: Intermediate trend support/resistance.
200 SMA: The definitive long-term trend indicator.

Weekly (Macro Trends) 
Designed for swing traders and long-term investors:
10, 30, 40, and 50 EMA: A tiered approach to identifying multi-month market cycles.

Weekly Cloud: A default visualization between the 10 and 30 EMAs to spot "value zones".

Monthly (Long-Term Cycles) 
6 and 10 SMA: High-level filters to stay on the right side of multi-year secular trends.

Dynamic Right-Side Labels Unlike standard indicators that crowd the top-left status line, this script generates labels directly on the chart. Each label is color-coordinated with its corresponding line and features a subtle tinted background for high legibility.

## Source Code

````pine
// NOTE: Moving average logic is unchanged.
// Enhancement: Right-side labels showing "Length Type  Value" in MA color with subtle tinted background.

//@version=6
indicator("Moving Averages For All Timeframes", shorttitle="RKB_MA", overlay=true, max_labels_count=500)

//***************************************************************************************
// Inputs
//***************************************************************************************
iWidth = input.int(title="Line Width", defval=1, minval=1, maxval=4)

//------------------------------
// Label Settings (NEW)
//------------------------------
iShowLabels  = input.bool(title="Show MA Labels (Right Side)", defval=true, group="Label Settings")
iLabelOffset = input.int(title="Label Offset (bars to the right)", defval=1, minval=0, maxval=50, group="Label Settings")
iLabelSizeIn = input.string(title="Label Size", defval="small", options=["tiny","small","normal","large","huge"], group="Label Settings")

f_size(_s) =>    _s == "tiny"   ? size.tiny   :    _s == "small"  ? size.small  :    _s == "normal" ? size.normal :    _s == "large"  ? size.large  : size.huge
// Create/Update/Delete a right-side label with subtle tinted background
f_updateLabel(_lbl, _enabled, _price, _text, _col) =>
    label _out = _lbl
    if (not _enabled) or na(_price)
        if not na(_out)
            label.delete(_out)
        _out := na
    else
        int _x = bar_index + iLabelOffset
        color _bg = color.new(_col, 88)  // subtle tinted background
        if na(_out)
            _out := label.new(_x, _price, _text, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=_bg, textcolor=_col, size=f_size(iLabelSizeIn))
        else
            label.set_xy(_out, _x, _price)
            label.set_text(_out, _text)
            label.set_color(_out, _bg)
            label.set_textcolor(_out, _col)
            label.set_size(_out, f_size(iLabelSizeIn))
    _out

//***************************************************************************************
// Intraday Inputs
//***************************************************************************************
iIntraMA1Visible = input.bool(title="", defval=true,  inline="I1", group="Intraday Moving Averages")
iIntraMA1Length  = input.int (title="", defval=5,    minval=1, maxval=5000, inline="I1", group="Intraday Moving Averages")
iIntraMA1Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I1", group="Intraday Moving Averages")
iIntraMA1Source  = input.source(title="", defval=close, inline="I1", group="Intraday Moving Averages")
iIntraMA1Color   = input.color(title="", defval=color.aqua, inline="I1", group="Intraday Moving Averages")

iIntraMA2Visible = input.bool(title="", defval=true,  inline="I2", group="Intraday Moving Averages")
iIntraMA2Length  = input.int (title="", defval=8,    minval=1, maxval=5000, inline="I2", group="Intraday Moving Averages")
iIntraMA2Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I2", group="Intraday Moving Averages")
iIntraMA2Source  = input.source(title="", defval=close, inline="I2", group="Intraday Moving Averages")
iIntraMA2Color   = input.color(title="", defval=#4F8B45, inline="I2", group="Intraday Moving Averages")

iIntraMA3Visible = input.bool(title="", defval=true,  inline="I3", group="Intraday Moving Averages")
iIntraMA3Length  = input.int (title="", defval=13,   minval=1, maxval=5000, inline="I3", group="Intraday Moving Averages")
iIntraMA3Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I3", group="Intraday Moving Averages")
iIntraMA3Source  = input.source(title="", defval=close, inline="I3", group="Intraday Moving Averages")
iIntraMA3Color   = input.color(title="", defval=#C23E38, inline="I3", group="Intraday Moving Averages")

iIntraMA4Visible = input.bool(title="", defval=false, inline="I4", group="Intraday Moving Averages")
iIntraMA4Length  = input.int (title="", defval=20,   minval=1, maxval=5000, inline="I4", group="Intraday Moving Averages")
iIntraMA4Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I4", group="Intraday Moving Averages")
iIntraMA4Source  = input.source(title="", defval=close, inline="I4", group="Intraday Moving Averages")
iIntraMA4Color   = input.color(title="", defval=color.gray, inline="I4", group="Intraday Moving Averages")

iIntraMA5Visible = input.bool(title="", defval=false, inline="I5", group="Intraday Moving Averages")
iIntraMA5Length  = input.int (title="", defval=60,   minval=1, maxval=5000, inline="I5", group="Intraday Moving Averages")
iIntraMA5Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I5", group="Intraday Moving Averages")
iIntraMA5Source  = input.source(title="", defval=close, inline="I5", group="Intraday Moving Averages")
iIntraMA5Color   = input.color(title="", defval=color.purple, inline="I5", group="Intraday Moving Averages")

iIntraCloud = input.bool(title="Show Moving Average Cloud", defval=false, inline="I6", group="Intraday Moving Averages",
     tooltip="Fill area between the first two defined moving averages with color.")
iIntraCloudColorUp   = input.color(title="   Up", defval=color.new(color.green, 90), inline="I6", group="Intraday Moving Averages")
iIntraCloudColorDown = input.color(title="Down", defval=color.new(color.red, 90), inline="I6", group="Intraday Moving Averages")

//***************************************************************************************
// Daily Inputs
//***************************************************************************************
iDailyMA1Visible = input.bool(title="", defval=true,  inline="I7", group="Daily Moving Averages")
iDailyMA1Length  = input.int (title="", defval=10,   minval=1, maxval=5000, inline="I7", group="Daily Moving Averages")
iDailyMA1Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I7", group="Daily Moving Averages")
iDailyMA1Source  = input.source(title="", defval=close, inline="I7", group="Daily Moving Averages")
iDailyMA1Color   = input.color(title="", defval=color.aqua, inline="I7", group="Daily Moving Averages")

iDailyMA2Visible = input.bool(title="", defval=true,  inline="I8", group="Daily Moving Averages")
iDailyMA2Length  = input.int (title="", defval=21,   minval=1, maxval=5000, inline="I8", group="Daily Moving Averages")
iDailyMA2Type    = input.string(title="", defval="EMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I8", group="Daily Moving Averages")
iDailyMA2Source  = input.source(title="", defval=close, inline="I8", group="Daily Moving Averages")
iDailyMA2Color   = input.color(title="", defval=#4F8B45, inline="I8", group="Daily Moving Averages")

iDailyMA3Visible = input.bool(title="", defval=true,  inline="I9", group="Daily Moving Averages")
iDailyMA3Length  = input.int (title="", defval=50,   minval=1, maxval=5000, inline="I9", group="Daily Moving Averages")
iDailyMA3Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I9", group="Daily Moving Averages")
iDailyMA3Source  = input.source(title="", defval=close, inline="I9", group="Daily Moving Averages")
iDailyMA3Color   = input.color(title="", defval=#C23E38, inline="I9", group="Daily Moving Averages")

iDailyMA4Visible = input.bool(title="", defval=true,  inline="I10", group="Daily Moving Averages")
iDailyMA4Length  = input.int (title="", defval=200,  minval=1, maxval=5000, inline="I10", group="Daily Moving Averages")
iDailyMA4Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I10", group="Daily Moving Averages")
iDailyMA4Source  = input.source(title="", defval=close, inline="I10", group="Daily Moving Averages")
iDailyMA4Color   = input.color(title="", defval=color.gray, inline="I10", group="Daily Moving Averages")

iDailyMA5Visible = input.bool(title="", defval=false, inline="I11", group="Daily Moving Averages")
iDailyMA5Length  = input.int (title="", defval=300,  minval=1, maxval=500,  inline="I11", group="Daily Moving Averages")
iDailyMA5Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I11", group="Daily Moving Averages")
iDailyMA5Source  = input.source(title="", defval=close, inline="I11", group="Daily Moving Averages")
iDailyMA5Color   = input.color(title="", defval=color.purple, inline="I11", group="Daily Moving Averages")

iDailyCloud = input.bool(title="Show Moving Average Cloud", defval=false, inline="I12", group="Daily Moving Averages",
     tooltip="Fill area between the first two defined moving averages with color.")
iDailyCloudColorUp   = input.color(title="   Up", defval=color.new(color.green, 90), inline="I12", group="Daily Moving Averages")
iDailyCloudColorDown = input.color(title="Down", defval=color.new(color.red, 90), inline="I12", group="Daily Moving Averages")

iWeeklyOnDaily      = input.bool(title="Show Weekly on Daily", defval=false, inline="I13", group="Daily Moving Averages")
iWeeklyOnDailyColor = input.color(title="", defval=color.olive, inline="I13", group="Daily Moving Averages")

//***************************************************************************************
// Weekly Inputs
//***************************************************************************************
iWeeklyMA1Visible = input.bool(title="", defval=true,  inline="I14", group="Weekly Moving Averages")
iWeeklyMA1Length  = input.int (title="", defval=10,   minval=1, maxval=5000, inline="I14", group="Weekly Moving Averages")
iWeeklyMA1Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I14", group="Weekly Moving Averages")
iWeeklyMA1Source  = input.source(title="", defval=close, inline="I14", group="Weekly Moving Averages")
iWeeklyMA1Color   = input.color(title="", defval=#C23E38, inline="I14", group="Weekly Moving Averages")

iWeeklyMA2Visible = input.bool(title="", defval=true,  inline="I15", group="Weekly Moving Averages")
iWeeklyMA2Length  = input.int (title="", defval=20,   minval=1, maxval=5000, inline="I15", group="Weekly Moving Averages")
iWeeklyMA2Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I15", group="Weekly Moving Averages")
iWeeklyMA2Source  = input.source(title="", defval=close, inline="I15", group="Weekly Moving Averages")
iWeeklyMA2Color   = input.color(title="", defval=#92959D, inline="I15", group="Weekly Moving Averages")

iWeeklyMA3Visible = input.bool(title="", defval=false, inline="I16", group="Weekly Moving Averages")
iWeeklyMA3Length  = input.int (title="", defval=40,   minval=1, maxval=5000, inline="I16", group="Weekly Moving Averages")
iWeeklyMA3Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I16", group="Weekly Moving Averages")
iWeeklyMA3Source  = input.source(title="", defval=close, inline="I16", group="Weekly Moving Averages")
iWeeklyMA3Color   = input.color(title="", defval=#4F8B45, inline="I16", group="Weekly Moving Averages")

iWeeklyMA4Visible = input.bool(title="", defval=false, inline="I17", group="Weekly Moving Averages")
iWeeklyMA4Length  = input.int (title="", defval=100,  minval=1, maxval=5000, inline="I17", group="Weekly Moving Averages")
iWeeklyMA4Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I17", group="Weekly Moving Averages")
iWeeklyMA4Source  = input.source(title="", defval=close, inline="I17", group="Weekly Moving Averages")
iWeeklyMA4Color   = input.color(title="", defval=color.aqua, inline="I17", group="Weekly Moving Averages")

iWeeklyCloud = input.bool(title="Show Moving Average Cloud", defval=false, inline="I18", group="Weekly Moving Averages",
     tooltip="Fill area between the first two defined moving averages with color.")
iWeeklyCloudColorUp   = input.color(title="   Up", defval=color.new(color.green, 90), inline="I18", group="Weekly Moving Averages")
iWeeklyCloudColorDown = input.color(title="Down", defval=color.new(color.red, 90), inline="I18", group="Weekly Moving Averages")

//***************************************************************************************
// Monthly Inputs
//***************************************************************************************
iMonthlyMA1Visible = input.bool(title="", defval=false, inline="I19", group="Monthly Moving Averages")
iMonthlyMA1Length  = input.int (title="", defval=6,    minval=1, maxval=5000, inline="I19", group="Monthly Moving Averages")
iMonthlyMA1Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I19", group="Monthly Moving Averages")
iMonthlyMA1Source  = input.source(title="", defval=close, inline="I19", group="Monthly Moving Averages")
iMonthlyMA1Color   = input.color(title="", defval=#C23E38, inline="I19", group="Monthly Moving Averages")

iMonthlyMA2Visible = input.bool(title="", defval=true,  inline="I20", group="Monthly Moving Averages")
iMonthlyMA2Length  = input.int (title="", defval=10,   minval=1, maxval=5000, inline="I20", group="Monthly Moving Averages")
iMonthlyMA2Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I20", group="Monthly Moving Averages")
iMonthlyMA2Source  = input.source(title="", defval=close, inline="I20", group="Monthly Moving Averages")
iMonthlyMA2Color   = input.color(title="", defval=#92959D, inline="I20", group="Monthly Moving Averages")

iMonthlyMA3Visible = input.bool(title="", defval=false, inline="I21", group="Monthly Moving Averages")
iMonthlyMA3Length  = input.int (title="", defval=24,   minval=1, maxval=5000, inline="I21", group="Monthly Moving Averages")
iMonthlyMA3Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I21", group="Monthly Moving Averages")
iMonthlyMA3Source  = input.source(title="", defval=close, inline="I21", group="Monthly Moving Averages")
iMonthlyMA3Color   = input.color(title="", defval=#4F8B45, inline="I21", group="Monthly Moving Averages")

iMonthlyMA4Visible = input.bool(title="", defval=false, inline="I22", group="Monthly Moving Averages")
iMonthlyMA4Length  = input.int (title="", defval=40,   minval=1, maxval=5000, inline="I22", group="Monthly Moving Averages")
iMonthlyMA4Type    = input.string(title="", defval="SMA", options=["SMA","EMA","RMA","VWMA","WMA"], inline="I22", group="Monthly Moving Averages")
iMonthlyMA4Source  = input.source(title="", defval=close, inline="I22", group="Monthly Moving Averages")
iMonthlyMA4Color   = input.color(title="", defval=color.aqua, inline="I22", group="Monthly Moving Averages")

iMonthlyCloud = input.bool(title="Show Moving Average Cloud", defval=false, inline="I23", group="Monthly Moving Averages",
     tooltip="Fill area between the first two defined moving averages with color.")
iMonthlyCloudColorUp   = input.color(title="   Up", defval=color.new(color.green, 90), inline="I23", group="Monthly Moving Averages")
iMonthlyCloudColorDown = input.color(title="Down", defval=color.new(color.red, 90), inline="I23", group="Monthly Moving Averages")

//***************************************************************************************
// Plot moving averages (ORIGINAL LOGIC PRESERVED)
//***************************************************************************************

//---------------------------------------------------
// Intraday
//---------------------------------------------------
intraMA1 = 0.0
intraMA2 = 0.0
intraMA3 = 0.0
intraMA4 = 0.0
intraMA5 = 0.0
if timeframe.isintraday
    intraMA1 := iIntraMA1Type == "SMA" ? ta.sma(iIntraMA1Source, iIntraMA1Length) : iIntraMA1Type == "EMA" ? ta.ema(iIntraMA1Source, iIntraMA1Length) : iIntraMA1Type == "RMA" ? ta.rma(iIntraMA1Source, iIntraMA1Length) : iIntraMA1Type == "VWMA" ? ta.vwma(iIntraMA1Source, iIntraMA1Length) : ta.wma(iIntraMA1Source, iIntraMA1Length)
    intraMA2 := iIntraMA2Type == "SMA" ? ta.sma(iIntraMA2Source, iIntraMA2Length) : iIntraMA2Type == "EMA" ? ta.ema(iIntraMA2Source, iIntraMA2Length) : iIntraMA2Type == "RMA" ? ta.rma(iIntraMA2Source, iIntraMA2Length) : iIntraMA2Type == "VWMA" ? ta.vwma(iIntraMA2Source, iIntraMA2Length) : ta.wma(iIntraMA2Source, iIntraMA2Length)
    intraMA3 := iIntraMA3Type == "SMA" ? ta.sma(iIntraMA3Source, iIntraMA3Length) : iIntraMA3Type == "EMA" ? ta.ema(iIntraMA3Source, iIntraMA3Length) : iIntraMA3Type == "RMA" ? ta.rma(iIntraMA3Source, iIntraMA3Length) : iIntraMA3Type == "VWMA" ? ta.vwma(iIntraMA3Source, iIntraMA3Length) : ta.wma(iIntraMA3Source, iIntraMA3Length)
    intraMA4 := iIntraMA4Type == "SMA" ? ta.sma(iIntraMA4Source, iIntraMA4Length) : iIntraMA4Type == "EMA" ? ta.ema(iIntraMA4Source, iIntraMA4Length) : iIntraMA4Type == "RMA" ? ta.rma(iIntraMA4Source, iIntraMA4Length) : iIntraMA4Type == "VWMA" ? ta.vwma(iIntraMA4Source, iIntraMA4Length) : ta.wma(iIntraMA4Source, iIntraMA4Length)
    intraMA5 := iIntraMA5Type == "SMA" ? ta.sma(iIntraMA5Source, iIntraMA5Length) : iIntraMA5Type == "EMA" ? ta.ema(iIntraMA5Source, iIntraMA5Length) : iIntraMA5Type == "RMA" ? ta.rma(iIntraMA5Source, iIntraMA5Length) : iIntraMA5Type == "VWMA" ? ta.vwma(iIntraMA5Source, iIntraMA5Length) : ta.wma(iIntraMA5Source, iIntraMA5Length)

i1 = plot(iIntraMA1Visible and timeframe.isintraday ? intraMA1 : na, title="Intraday Moving Average #1", color=iIntraMA1Color, linewidth=iWidth)
i2 = plot(iIntraMA2Visible and timeframe.isintraday ? intraMA2 : na, title="Intraday Moving Average #2", color=iIntraMA2Color, linewidth=iWidth)
plot(iIntraMA3Visible and timeframe.isintraday ? intraMA3 : na, title="Intraday Moving Average #3", color=iIntraMA3Color, linewidth=iWidth)
plot(iIntraMA4Visible and timeframe.isintraday ? intraMA4 : na, title="Intraday Moving Average #4", color=iIntraMA4Color, linewidth=iWidth)
plot(iIntraMA5Visible and timeframe.isintraday ? intraMA5 : na, title="Intraday Moving Average #5", color=iIntraMA5Color, linewidth=iWidth)

fillColor = color.rgb(0, 0, 0, 100)
if iIntraCloud
    fillColor := intraMA1 < intraMA2 ? iIntraCloudColorDown : iIntraCloudColorUp
fill(i1, i2, color=fillColor)

//---------------------------------------------------
// Daily
//---------------------------------------------------
dailyMA1 = 0.0
dailyMA2 = 0.0
dailyMA3 = 0.0
dailyMA4 = 0.0
dailyMA5 = 0.0
if timeframe.isdaily
    dailyMA1 := iDailyMA1Type == "SMA" ? ta.sma(iDailyMA1Source, iDailyMA1Length) : iDailyMA1Type == "EMA" ? ta.ema(iDailyMA1Source, iDailyMA1Length) : iDailyMA1Type == "RMA" ? ta.rma(iDailyMA1Source, iDailyMA1Length) : iDailyMA1Type == "VWMA" ? ta.vwma(iDailyMA1Source, iDailyMA1Length) : ta.wma(iDailyMA1Source, iDailyMA1Length)
    dailyMA2 := iDailyMA2Type == "SMA" ? ta.sma(iDailyMA2Source, iDailyMA2Length) : iDailyMA2Type == "EMA" ? ta.ema(iDailyMA2Source, iDailyMA2Length) : iDailyMA2Type == "RMA" ? ta.rma(iDailyMA2Source, iDailyMA2Length) : iDailyMA2Type == "VWMA" ? ta.vwma(iDailyMA2Source, iDailyMA2Length) : ta.wma(iDailyMA2Source, iDailyMA2Length)
    dailyMA3 := iDailyMA3Type == "SMA" ? ta.sma(iDailyMA3Source, iDailyMA3Length) : iDailyMA3Type == "EMA" ? ta.ema(iDailyMA3Source, iDailyMA3Length) : iDailyMA3Type == "RMA" ? ta.rma(iDailyMA3Source, iDailyMA3Length) : iDailyMA3Type == "VWMA" ? ta.vwma(iDailyMA3Source, iDailyMA3Length) : ta.wma(iDailyMA3Source, iDailyMA3Length)
    dailyMA4 := iDailyMA4Type == "SMA" ? ta.sma(iDailyMA4Source, iDailyMA4Length) : iDailyMA4Type == "EMA" ? ta.ema(iDailyMA4Source, iDailyMA4Length) : iDailyMA4Type == "RMA" ? ta.rma(iDailyMA4Source, iDailyMA4Length) : iDailyMA4Type == "VWMA" ? ta.vwma(iDailyMA4Source, iDailyMA4Length) : ta.wma(iDailyMA4Source, iDailyMA4Length)
    dailyMA5 := iDailyMA5Type == "SMA" ? ta.sma(iDailyMA5Source, iDailyMA5Length) : iDailyMA5Type == "EMA" ? ta.ema(iDailyMA5Source, iDailyMA5Length) : iDailyMA5Type == "RMA" ? ta.rma(iDailyMA5Source, iDailyMA5Length) : iDailyMA5Type == "VWMA" ? ta.vwma(iDailyMA5Source, iDailyMA5Length) : ta.wma(iDailyMA5Source, iDailyMA5Length)

d1 = plot(iDailyMA1Visible and timeframe.isdaily ? dailyMA1 : na, title="Daily Moving Average #1", color=iDailyMA1Color, linewidth=iWidth)
d2 = plot(iDailyMA2Visible and timeframe.isdaily ? dailyMA2 : na, title="Daily Moving Average #2", color=iDailyMA2Color, linewidth=iWidth)
plot(iDailyMA3Visible and timeframe.isdaily ? dailyMA3 : na, title="Daily Moving Average #3", color=iDailyMA3Color, linewidth=iWidth)
plot(iDailyMA4Visible and timeframe.isdaily ? dailyMA4 : na, title="Daily Moving Average #4", color=iDailyMA4Color, linewidth=iWidth)
plot(iDailyMA5Visible and timeframe.isdaily ? dailyMA5 : na, title="Daily Moving Average #5", color=iDailyMA5Color, linewidth=iWidth)

// Weekly on Daily (original)
w = request.security(syminfo.tickerid, "W", ta.sma(close, 10), lookahead=barmerge.lookahead_on)
plot(iWeeklyOnDaily and timeframe.isdaily ? w : na, color=iWeeklyOnDailyColor, linewidth=1, title="Weekly on Daily")

fillColor := color.rgb(0, 0, 0, 100)
if iDailyCloud
    fillColor := dailyMA1 < dailyMA2 ? iDailyCloudColorDown : iDailyCloudColorUp
fill(d1, d2, color=fillColor)

//---------------------------------------------------
// Weekly
//---------------------------------------------------
weeklyMA1 = 0.0
weeklyMA2 = 0.0
weeklyMA3 = 0.0
weeklyMA4 = 0.0
if timeframe.isweekly
    weeklyMA1 := iWeeklyMA1Type == "SMA" ? ta.sma(iWeeklyMA1Source, iWeeklyMA1Length) : iWeeklyMA1Type == "EMA" ? ta.ema(iWeeklyMA1Source, iWeeklyMA1Length) : iWeeklyMA1Type == "RMA" ? ta.rma(iWeeklyMA1Source, iWeeklyMA1Length) : iWeeklyMA1Type == "VWMA" ? ta.vwma(iWeeklyMA1Source, iWeeklyMA1Length) : ta.wma(iWeeklyMA1Source, iWeeklyMA1Length)
    weeklyMA2 := iWeeklyMA2Type == "SMA" ? ta.sma(iWeeklyMA2Source, iWeeklyMA2Length) : iWeeklyMA2Type == "EMA" ? ta.ema(iWeeklyMA2Source, iWeeklyMA2Length) : iWeeklyMA2Type == "RMA" ? ta.rma(iWeeklyMA2Source, iWeeklyMA2Length) : iWeeklyMA2Type == "VWMA" ? ta.vwma(iWeeklyMA2Source, iWeeklyMA2Length) : ta.wma(iWeeklyMA2Source, iWeeklyMA2Length)
    weeklyMA3 := iWeeklyMA3Type == "SMA" ? ta.sma(iWeeklyMA3Source, iWeeklyMA3Length) : iWeeklyMA3Type == "EMA" ? ta.ema(iWeeklyMA3Source, iWeeklyMA3Length) : iWeeklyMA3Type == "RMA" ? ta.rma(iWeeklyMA3Source, iWeeklyMA3Length) : iWeeklyMA3Type == "VWMA" ? ta.vwma(iWeeklyMA3Source, iWeeklyMA3Length) : ta.wma(iWeeklyMA3Source, iWeeklyMA3Length)
    weeklyMA4 := iWeeklyMA4Type == "SMA" ? ta.sma(iWeeklyMA4Source, iWeeklyMA4Length) : iWeeklyMA4Type == "EMA" ? ta.ema(iWeeklyMA4Source, iWeeklyMA4Length) : iWeeklyMA4Type == "RMA" ? ta.rma(iWeeklyMA4Source, iWeeklyMA4Length) : iWeeklyMA4Type == "VWMA" ? ta.vwma(iWeeklyMA4Source, iWeeklyMA4Length) : ta.wma(iWeeklyMA4Source, iWeeklyMA4Length)

w1 = plot(iWeeklyMA1Visible and timeframe.isweekly ? weeklyMA1 : na, title="Weekly Moving Average #1", color=iWeeklyMA1Color, linewidth=iWidth)
w2 = plot(iWeeklyMA2Visible and timeframe.isweekly ? weeklyMA2 : na, title="Weekly Moving Average #2", color=iWeeklyMA2Color, linewidth=iWidth)
plot(iWeeklyMA3Visible and timeframe.isweekly ? weeklyMA3 : na, title="Weekly Moving Average #3", color=iWeeklyMA3Color, linewidth=iWidth)
plot(iWeeklyMA4Visible and timeframe.isweekly ? weeklyMA4 : na, title="Weekly Moving Average #4", color=iWeeklyMA4Color, linewidth=iWidth)

fillColor := color.rgb(0, 0, 0, 100)
if iWeeklyCloud
    fillColor := weeklyMA1 < weeklyMA2 ? iWeeklyCloudColorDown : iWeeklyCloudColorUp
fill(w1, w2, color=fillColor)

//---------------------------------------------------
// Monthly
//---------------------------------------------------
monthlyMA1 = 0.0
monthlyMA2 = 0.0
monthlyMA3 = 0.0
monthlyMA4 = 0.0
if timeframe.ismonthly
    monthlyMA1 := iMonthlyMA1Type == "SMA" ? ta.sma(iMonthlyMA1Source, iMonthlyMA1Length) : iMonthlyMA1Type == "EMA" ? ta.ema(iMonthlyMA1Source, iMonthlyMA1Length) : iMonthlyMA1Type == "RMA" ? ta.rma(iMonthlyMA1Source, iMonthlyMA1Length) : iMonthlyMA1Type == "VWMA" ? ta.vwma(iMonthlyMA1Source, iMonthlyMA1Length) : ta.wma(iMonthlyMA1Source, iMonthlyMA1Length)
    monthlyMA2 := iMonthlyMA2Type == "SMA" ? ta.sma(iMonthlyMA2Source, iMonthlyMA2Length) : iMonthlyMA2Type == "EMA" ? ta.ema(iMonthlyMA2Source, iMonthlyMA2Length) : iMonthlyMA2Type == "RMA" ? ta.rma(iMonthlyMA2Source, iMonthlyMA2Length) : iMonthlyMA2Type == "VWMA" ? ta.vwma(iMonthlyMA2Source, iMonthlyMA2Length) : ta.wma(iMonthlyMA2Source, iMonthlyMA2Length)
    monthlyMA3 := iMonthlyMA3Type == "SMA" ? ta.sma(iMonthlyMA3Source, iMonthlyMA3Length) : iMonthlyMA3Type == "EMA" ? ta.ema(iMonthlyMA3Source, iMonthlyMA3Length) : iMonthlyMA3Type == "RMA" ? ta.rma(iMonthlyMA3Source, iMonthlyMA3Length) : iMonthlyMA3Type == "VWMA" ? ta.vwma(iMonthlyMA3Source, iMonthlyMA3Length) : ta.wma(iMonthlyMA3Source, iMonthlyMA3Length)
    monthlyMA4 := iMonthlyMA4Type == "SMA" ? ta.sma(iMonthlyMA4Source, iMonthlyMA4Length) : iMonthlyMA4Type == "EMA" ? ta.ema(iMonthlyMA4Source, iMonthlyMA4Length) : iMonthlyMA4Type == "RMA" ? ta.rma(iMonthlyMA4Source, iMonthlyMA4Length) : iMonthlyMA4Type == "VWMA" ? ta.vwma(iMonthlyMA4Source, iMonthlyMA4Length) : ta.wma(iMonthlyMA4Source, iMonthlyMA4Length)

m1 = plot(iMonthlyMA1Visible and timeframe.ismonthly ? monthlyMA1 : na, title="Monthly Moving Average #1", color=iMonthlyMA1Color, linewidth=iWidth)
m2 = plot(iMonthlyMA2Visible and timeframe.ismonthly ? monthlyMA2 : na, title="Monthly Moving Average #2", color=iMonthlyMA2Color, linewidth=iWidth)
plot(iMonthlyMA3Visible and timeframe.ismonthly ? monthlyMA3 : na, title="Monthly Moving Average #3", color=iMonthlyMA3Color, linewidth=iWidth)
plot(iMonthlyMA4Visible and timeframe.ismonthly ? monthlyMA4 : na, title="Monthly Moving Average #4", color=iMonthlyMA4Color, linewidth=iWidth)

fillColor := color.rgb(0, 0, 0, 100)
if iMonthlyCloud
    fillColor := monthlyMA1 < monthlyMA2 ? iMonthlyCloudColorDown : iMonthlyCloudColorUp
fill(m1, m2, color=fillColor)

//***************************************************************************************
// RIGHT-SIDE MA LABELS (NEW) — Length + Type + Value
//***************************************************************************************

// IMPORTANT: v6 requires typed label vars if initialized with na (each one declared separately)
var label li1 = na
var label li2 = na
var label li3 = na
var label li4 = na
var label li5 = na

var label ld1 = na
var label ld2 = na
var label ld3 = na
var label ld4 = na
var label ld5 = na
var label lwd = na

var label lw1 = na
var label lw2 = na
var label lw3 = na
var label lw4 = na

var label lm1 = na
var label lm2 = na
var label lm3 = na
var label lm4 = na

if barstate.islast
    // Intraday
    li1 := f_updateLabel(li1, iShowLabels and timeframe.isintraday and iIntraMA1Visible, intraMA1, str.tostring(iIntraMA1Length) + " " + iIntraMA1Type + "  " + str.tostring(intraMA1, format.mintick), iIntraMA1Color)
    li2 := f_updateLabel(li2, iShowLabels and timeframe.isintraday and iIntraMA2Visible, intraMA2, str.tostring(iIntraMA2Length) + " " + iIntraMA2Type + "  " + str.tostring(intraMA2, format.mintick), iIntraMA2Color)
    li3 := f_updateLabel(li3, iShowLabels and timeframe.isintraday and iIntraMA3Visible, intraMA3, str.tostring(iIntraMA3Length) + " " + iIntraMA3Type + "  " + str.tostring(intraMA3, format.mintick), iIntraMA3Color)
    li4 := f_updateLabel(li4, iShowLabels and timeframe.isintraday and iIntraMA4Visible, intraMA4, str.tostring(iIntraMA4Length) + " " + iIntraMA4Type + "  " + str.tostring(intraMA4, format.mintick), iIntraMA4Color)
    li5 := f_updateLabel(li5, iShowLabels and timeframe.isintraday and iIntraMA5Visible, intraMA5, str.tostring(iIntraMA5Length) + " " + iIntraMA5Type + "  " + str.tostring(intraMA5, format.mintick), iIntraMA5Color)

    // Daily
    ld1 := f_updateLabel(ld1, iShowLabels and timeframe.isdaily and iDailyMA1Visible, dailyMA1, str.tostring(iDailyMA1Length) + " " + iDailyMA1Type + "  " + str.tostring(dailyMA1, format.mintick), iDailyMA1Color)
    ld2 := f_updateLabel(ld2, iShowLabels and timeframe.isdaily and iDailyMA2Visible, dailyMA2, str.tostring(iDailyMA2Length) + " " + iDailyMA2Type + "  " + str.tostring(dailyMA2, format.mintick), iDailyMA2Color)
    ld3 := f_updateLabel(ld3, iShowLabels and timeframe.isdaily and iDailyMA3Visible, dailyMA3, str.tostring(iDailyMA3Length) + " " + iDailyMA3Type + "  " + str.tostring(dailyMA3, format.mintick), iDailyMA3Color)
    ld4 := f_updateLabel(ld4, iShowLabels and timeframe.isdaily and iDailyMA4Visible, dailyMA4, str.tostring(iDailyMA4Length) + " " + iDailyMA4Type + "  " + str.tostring(dailyMA4, format.mintick), iDailyMA4Color)
    ld5 := f_updateLabel(ld5, iShowLabels and timeframe.isdaily and iDailyMA5Visible, dailyMA5, str.tostring(iDailyMA5Length) + " " + iDailyMA5Type + "  " + str.tostring(dailyMA5, format.mintick), iDailyMA5Color)

    // Weekly on Daily (label)
    lwd := f_updateLabel(lwd, iShowLabels and timeframe.isdaily and iWeeklyOnDaily, w, "W 10 SMA  " + str.tostring(w, format.mintick), iWeeklyOnDailyColor)

    // Weekly
    lw1 := f_updateLabel(lw1, iShowLabels and timeframe.isweekly and iWeeklyMA1Visible, weeklyMA1, str.tostring(iWeeklyMA1Length) + " " + iWeeklyMA1Type + "  " + str.tostring(weeklyMA1, format.mintick), iWeeklyMA1Color)
    lw2 := f_updateLabel(lw2, iShowLabels and timeframe.isweekly and iWeeklyMA2Visible, weeklyMA2, str.tostring(iWeeklyMA2Length) + " " + iWeeklyMA2Type + "  " + str.tostring(weeklyMA2, format.mintick), iWeeklyMA2Color)
    lw3 := f_updateLabel(lw3, iShowLabels and timeframe.isweekly and iWeeklyMA3Visible, weeklyMA3, str.tostring(iWeeklyMA3Length) + " " + iWeeklyMA3Type + "  " + str.tostring(weeklyMA3, format.mintick), iWeeklyMA3Color)
    lw4 := f_updateLabel(lw4, iShowLabels and timeframe.isweekly and iWeeklyMA4Visible, weeklyMA4, str.tostring(iWeeklyMA4Length) + " " + iWeeklyMA4Type + "  " + str.tostring(weeklyMA4, format.mintick), iWeeklyMA4Color)

    // Monthly
    lm1 := f_updateLabel(lm1, iShowLabels and timeframe.ismonthly and iMonthlyMA1Visible, monthlyMA1, str.tostring(iMonthlyMA1Length) + " " + iMonthlyMA1Type + "  " + str.tostring(monthlyMA1, format.mintick), iMonthlyMA1Color)
    lm2 := f_updateLabel(lm2, iShowLabels and timeframe.ismonthly and iMonthlyMA2Visible, monthlyMA2, str.tostring(iMonthlyMA2Length) + " " + iMonthlyMA2Type + "  " + str.tostring(monthlyMA2, format.mintick), iMonthlyMA2Color)
    lm3 := f_updateLabel(lm3, iShowLabels and timeframe.ismonthly and iMonthlyMA3Visible, monthlyMA3, str.tostring(iMonthlyMA3Length) + " " + iMonthlyMA3Type + "  " + str.tostring(monthlyMA3, format.mintick), iMonthlyMA3Color)
    lm4 := f_updateLabel(lm4, iShowLabels and timeframe.ismonthly and iMonthlyMA4Visible, monthlyMA4, str.tostring(iMonthlyMA4Length) + " " + iMonthlyMA4Type + "  " + str.tostring(monthlyMA4, format.mintick), iMonthlyMA4Color)
````
