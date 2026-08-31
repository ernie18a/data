<!-- tradingview-pine-id: PUB;VWXlEdN0iB4LE5Ypk32r6p17TEjPNVpu -->
<!-- tradingviewscripts-format: 1 -->
# Kzx | Position Tracker

Source: https://www.tradingview.com/script/m0DQnluK/

## Description

Simply display a representation of your position

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © K-zax

//@version=4
study(title="Kzx | Position Tracker", shorttitle="Kzx | P-Track", overlay=true)
//==================================================================================================================================================
//
//    IMPUT
//
//==================================================================================================================================================
//  ENTRY
ENTRY_SIDE 	= input(defval="Undefined", title="Position Side", options=["Undefined", "SHORT", "LONG"], group = "Entry")
ENTRY_PRICE = input(defval=0.0, title="Price", type=input.float, minval=0, group = "Entry")
ENTRY_AS_TIME	    = input(title="Entry Time", type=input.bool, defval=false, group = "Entry", inline = "Entry Time")
ENTRY_TIME = input(defval = timestamp("03 Apr 2021 10:45 +0000"), title = "", type = input.time, group = "Entry", inline = "Entry Time")

//  STOP LOSS
AS_SL	    = input(title="Stop Loss", type=input.bool, defval=false, group = "Stop Loss", inline = "SL")
SL_PRICE 	= input(defval=0.0, title="Price", type=input.float, minval=0, group = "Stop Loss", inline = "SL")

//  TAKE PROFIT
AS_TP	    = input(title="Take Profit", type=input.bool, defval=false, group = "Take Profit", inline = "TP")
TP_PRICE 	= input(defval=0.0, title="Price", type=input.float, minval=0, group = "Take Profit", inline = "TP")

// DISPLAY
OFFSET 	    = input(defval=5, title="offset", type=input.integer, minval=2, group = "Display")
LABEL_OFFSET = input(defval=10, title="Label offset", type=input.integer, minval=2, group = "Display")
ENTRY_COLOR = input(title="Entry", type=input.color, defval=color.yellow)
SL_COLOR    = input(title="SL", type=input.color, defval=#cc141e)
TP_COLOR    = input(title="TP", type=input.color, defval=#2caa83)
LOSS_COLOR  = input(title="Loss", type=input.color, defval=#cc141e)
GAIN_COLOR  = input(title="Gain", type=input.color, defval=#2caa83)
BG_COLOR  = input(title="Background", type=input.color, defval=#2d2d2e)
LEVEL_WIDTH  = input(defval=1, title="Level Line Width", type=input.integer, minval=1)
STATUS_WIDTH  = input(defval=4, title="Status Line Width", type=input.integer, minval=1)

//==================================================================================================================================================
//
//    INDICATOR
//
//==================================================================================================================================================
//  DISPLAY CONDITIONS
var isShort = ENTRY_SIDE == "SHORT" ? true : false
var isLong = ENTRY_SIDE == "LONG" ? true : false
var isActive = (isShort or isLong) and ENTRY_PRICE > 0.0 ? true : false

var slIsValid = SL_PRICE > 0 and ((isShort and SL_PRICE > ENTRY_PRICE) or (isLong and SL_PRICE < ENTRY_PRICE))
var slIsActive = isActive and AS_SL and slIsValid

var tpIsValid = TP_PRICE > 0 and ((isShort and TP_PRICE < ENTRY_PRICE) or (isLong and TP_PRICE > ENTRY_PRICE))
var tpIsActive = isActive and AS_TP and tpIsValid

// INDICATOR OFFSET
timeOffset = time[1] - time[2]
baseOffset = time + OFFSET * timeOffset
xLabel = baseOffset + (timeOffset * LABEL_OFFSET)

pnlStatus = 0
color pnlColor = na
pnlPercent = 0.0
if (isActive)
    pnlStatus := (isShort and close < ENTRY_PRICE) or (isLong and close > ENTRY_PRICE) ? 1 : -1
    pnlColor := pnlStatus == 1 ? GAIN_COLOR : LOSS_COLOR
    pnlPercent := pnlStatus * floor(((close / ENTRY_PRICE) - 1 ) * 10000) / 100

slPnlPercent = 0.0
if (slIsActive)
    slPnlPercent := floor(((SL_PRICE / ENTRY_PRICE) - 1 ) * 10000) / 100

tpPnlPercent = 0.0
if (tpIsActive)
    tpPnlPercent := floor(((TP_PRICE / ENTRY_PRICE) - 1 ) * 10000) / 100

//==================================================================================================================================================
//
//    DISPLAY
//
//==================================================================================================================================================
// BG
var line bgLine = na
if (isActive and (slIsActive  or tpIsActive))
    line.delete(bgLine)
    y1 = isLong and AS_SL ? SL_PRICE : isShort and AS_TP ? TP_PRICE : ENTRY_PRICE
    y2 = isShort and AS_SL ? SL_PRICE : isLong and AS_TP ? TP_PRICE : ENTRY_PRICE
    bgLine := line.new(x1 = baseOffset, y1 = y1, x2 = baseOffset, y2 = y2, xloc = xloc.bar_time, extend = extend.none, color = BG_COLOR, style = line.style_solid, width=STATUS_WIDTH)

// SL
var line slLine = na
var label slLabel = na
if (slIsActive)
    line.delete(slLine)
    label.delete(slLabel)
    slLine := line.new(x1 = time, y1=SL_PRICE, x2 = baseOffset, y2=SL_PRICE, xloc = xloc.bar_time, extend = extend.none, style = line.style_solid, color=SL_COLOR, width=LEVEL_WIDTH)
    slLabel := label.new(text = tostring(SL_PRICE)+' | '+tostring(slPnlPercent)+' %', x = xLabel, y = SL_PRICE, textcolor= SL_COLOR, xloc = xloc.bar_time, style = label.style_none)
    
// TP
var line tpLine = na
var label tpLabel = na

if (tpIsActive)
    line.delete(tpLine)
    label.delete(tpLabel)
    tpLine := line.new(x1 = time, y1=TP_PRICE, x2 = baseOffset, y2=TP_PRICE, xloc = xloc.bar_time, extend = extend.none, style = line.style_solid, color=TP_COLOR, width=LEVEL_WIDTH)
    tpLabel := label.new(text = tostring(TP_PRICE)+' | '+tostring(tpPnlPercent)+' %', x = xLabel, y = TP_PRICE, textcolor= TP_COLOR, xloc = xloc.bar_time, style = label.style_none)

// ENTRY
var line entryLine = na
var label entryLabel = na
var line statusLine = na
var label statusLabel = na
if (isActive)
    line.delete(entryLine)
    label.delete(entryLabel)
    line.delete(statusLine)
    label.delete(statusLabel)
    x1 = ENTRY_AS_TIME and ENTRY_TIME < timenow ? ENTRY_TIME : time
    
    // Entry
    entryLine := line.new(x1 = x1, y1=ENTRY_PRICE, x2 = baseOffset, y2=ENTRY_PRICE, xloc = xloc.bar_time, extend = extend.none, style = line.style_solid, color=ENTRY_COLOR, width=LEVEL_WIDTH)
    entryLabel := label.new(text = tostring(ENTRY_PRICE)+' | '+tostring(pnlPercent)+' %', x = xLabel, y = ENTRY_PRICE, textcolor= pnlColor, xloc = xloc.bar_time, style = label.style_none)
    
    // Status
    statusLine := line.new(x1 = baseOffset, y1 = ENTRY_PRICE, x2 = baseOffset, y2 = close, xloc = xloc.bar_time, extend = extend.none, color = pnlColor, style = line.style_solid, width=STATUS_WIDTH)
````
