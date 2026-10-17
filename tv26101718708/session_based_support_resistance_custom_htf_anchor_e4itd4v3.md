# Session Based Support & Resistance (Custom HTF Anchor)

- url: https://www.tradingview.com/script/e4ITd4V3-Session-Based-Support-Resistance-Custom-HTF-Anchor/
- type: indicator
- pine_id: PUB;975a6d850bb443cdb6ee897b81f6426b
- version: 1.0

## Description

[b]HTF SESSION SUPPORT & RESISTANCE[/b]

HTF Session Support & Resistance is designed to estimate potential support and resistance levels using a custom Higher Timeframe (HTF) calculation.

━━━━━━━━━━━━━━━━━━━━
[b]🟡 Main Levels[/b]
The indicator plots three main types of levels:
[list=1]
[*][b]Support & Resistance[/b] – Calculated from the previous HTF candle.
[*][b]Pivot[/b] – The central reference level (yellow line).
[*][b]Expansion Levels[/b] – Additional outer levels based on a customizable multiplier (default: [b]0.9[/b]).[/list]
━━━━━━━━━━━━━━━━━━━━
[b]🟡 How to Use[/b]
This indicator is intended to help identify potential areas where price may react:
[list=1]
[*]Potential support and resistance zones.
[*]Pullbacks or reversals around the Pivot level.
[*]Profit targets and risk management.
[*]Stronger reactions near the Expansion Levels.[/list]
━━━━━━━━━━━━━━━━━━━━
⚙️[i]you can custom your own HTF session anchor time, making it easier to align the levels with your preferred market session.[/i]

⚠️[i] Like any technical indicator, these levels should be used together with price action and your own trading strategy, not as standalone buy or sell signals.[/i]

━━━━━━━━━━━━━━━━━━━━
[i]I hope this indicator helps simplify your chart analysis and becomes a useful part of your trading workflow.[/i]

[b]Best regards,[/b]

[b]Algedo[/b]

## Source Code

````pine
//@version=6

//==================================================
// Support Ressistance Session
// Version: 1.0
// Last Update: 2026
// Author: Algedo
//==================================================
//
// This indicator is is provided for educational purposes only.
//
// It does not constitute financial advice.
// No guarantee of performance or profitability is provided.
//
// Always do your own analysis and manage your risk properly.
// Trading involves risk. The author is not responsible 
// for any losses incurred.
//
// © Algedo - All Rights Reserved
//==================================================
// Support & Inquiries
// Email: begrilcrypto@gmail.com
//==================================================


indicator("HTF Session Support & Resistance [Algedo]", shorttitle = "S/R HTF", overlay = true, max_lines_count = 500, max_labels_count = 500)

isCrypto = syminfo.type == "crypto"

//================ INPUT =================//
G1 = "HTF Settings"
G2 = "Line Settings"
G3 = "Visual Settings"

htfOpt       = input.string("1D", "Timeframe", options = ["1H","2H","4H","6H","8H","12H", "18H", "1D"], group = G1, inline = "htf1")
anchorHour   = input.int(0, "Etc(GMT-0)", minval = 0, maxval = 23, group = G1, inline = "htf")
anchorMin    = input.int(0, ":", minval = 0, maxval = 59, group = G1, inline = "htf")
showExp      = input.bool(true, "Expansion", group = G2, inline = "dev")
multiplier   = input.float(0.9, " ", step = 0.1, minval = 0, group = G2, inline = "dev")
showLabel    = input.bool(true, "Show Level", group = G2, inline="lb")
labelMode    = input.string("Current", " ", options = ["Current", "History"], group = G2, inline="lb")
labelSizeOpt = input.string("Small", " ", options = ["Tiny", "Small", "Normal", "Large"], group = G2, inline="lb")
colRes       = input.color(color.new(color.white, 0), "Lines", group = G3, inline = "lines")
colSup       = input.color(color.new(color.white, 0), " ", group = G3, inline = "lines")
colMid       = input.color(color.new(color.yellow, 0), " ", group = G3, inline = "lines")
colMidZone   = input.color(color.new(color.white, 70), " ", group = G3, inline = "lines")
zoneColor    = input.color(color.new(color.gray, 93), "Box", group = G3, inline = "lines")

var label warnLbl = na
if not isCrypto and barstate.islast
    if not na(warnLbl)
        label.delete(warnLbl)
    warnLbl := label.new(bar_index, high, "Only supported for crypto market",
        style = label.style_label_center, textcolor = color.white, color = color.new(color.red, 0), size = size.large)

//================ HTF ENGINE =================//
string TZ = "Etc/GMT-0"

int ANCHOR_TOTAL_MIN = anchorHour * 60 + anchorMin
int SHIFT_MS         = ANCHOR_TOTAL_MIN * 60 * 1000

int HTF_MIN =
     htfOpt == "1H"  ? 60   :
     htfOpt == "2H"  ? 120  :
     htfOpt == "4H"  ? 240  :
     htfOpt == "6H"  ? 360  :
     htfOpt == "8H"  ? 480  :
     htfOpt == "12H" ? 720  :
     htfOpt == "18H" ? 1080 : 1440

int shiftedTime = time - SHIFT_MS
int y  = year(shiftedTime, TZ)
int mo = month(shiftedTime, TZ)
int d  = dayofmonth(shiftedTime, TZ)
int wk = weekofyear(shiftedTime, TZ)
bool isDaily   = htfOpt == "1D"

//------------------------------------------------
// HTF Slot

int htfSlot =
     isDaily
         ? y * 10000 + mo * 100 + d
     : int(math.floor(shiftedTime / (HTF_MIN * 60 * 1000)))

//================ STORAGE =================//
var int prevSlot = na
var float htfOpen  = na
var float htfHigh  = na
var float htfLow   = na
var float htfClose = na
var int   htfStartTime = na
var float htfOpen_C  = na
var float htfHigh_C  = na
var float htfLow_C   = na
var float htfClose_C = na
var int t0 = na
var int t1 = na
var line[] arrRes = array.new_line()
var line[] arrSup = array.new_line()
var line[] arrMid = array.new_line()
var line[] arrMidRes = array.new_line()
var line[] arrMidSup = array.new_line()
var line[] arrResDev1 = array.new_line()
var line[] arrSupDev1 = array.new_line()
var box[] arrZone = array.new_box()
var label lblRes = na
var label lblSup = na
var label lblMid = na
var label lblResDev1 = na
var label lblSupDev1 = na

//================ LABEL =================//
labelSize =
     labelSizeOpt == "Tiny"   ? size.tiny :
     labelSizeOpt == "Small"  ? size.small :
     labelSizeOpt == "Normal" ? size.normal :
     size.large

//================ HTF BUILD =================//
bool isNewHTFBar = na(prevSlot) or htfSlot != prevSlot
prevSlot := htfSlot

if isNewHTFBar and isCrypto

    //===== STORE CLOSED HTF =====//
    if not na(htfOpen)
        htfOpen_C  := htfOpen
        htfHigh_C  := htfHigh
        htfLow_C   := htfLow
        htfClose_C := htfClose

        t1 := t0
        t0 := time

        //===== CALCULATION =====//
        float base = (htfHigh_C + htfLow_C + htfClose_C + htfClose_C) / 4 //HLCC4
        float res  = (base * 2) - htfLow_C
        float sup  = (base * 2) - htfHigh_C
        float midRes = base + ((res - base) * 0.5)
        float midSup = base - ((base - sup) * 0.5)
        float srrng = (res - sup) * multiplier
        float resDev1 = res + srrng
        float supDev1 = sup - srrng

        //===== ESTIMATE HTF BAR LENGTH =====//
        var int prevBarIndex = na
        int x1 = bar_index
        int x2 = not na(prevBarIndex) ? bar_index + (bar_index - prevBarIndex) : bar_index + 1
        prevBarIndex := bar_index

        //===== DRAW LINES =====//
        line lRes = line.new(x1, res, x2, res, color = colRes, width = 1)
        line lSup = line.new(x1, sup, x2, sup, color = colSup, width = 1)
        line lMid = line.new(x1, base, x2, base, color = colMid, width = 1, style = line.style_dashed)
        line lMidRes = line.new(x1, midRes, x2, midRes, color = colMidZone, width = 1, style = line.style_dotted)
        line lMidSup = line.new(x1, midSup, x2, midSup, color = colMidZone, width = 1, style = line.style_dotted)
        
        if not showExp
            box bZone = box.new(left = x1, right = x2, top = res, bottom = sup, bgcolor = zoneColor, border_color = na)

        if showExp
            line lResDev1 = line.new(x1, resDev1, x2, resDev1, color = color.new(colRes, 50), width = 1, style = line.style_dotted)
            line lSupDev1 = line.new(x1, supDev1, x2, supDev1, color = color.new(colSup,50), width = 1, style = line.style_dotted)
            box bZone2 = box.new(left = x1, right = x2, top = resDev1, bottom = supDev1, bgcolor = zoneColor, border_color = na)

        if showLabel

            if labelMode == "Current"

                if not na(lblRes)
                    label.delete(lblRes)
                if not na(lblSup)
                    label.delete(lblSup)
                if not na(lblMid)
                    label.delete(lblMid)
                if not na(lblResDev1)
                    label.delete(lblResDev1)                
                if not na(lblSupDev1)
                    label.delete(lblSupDev1) 

                lblRes := label.new(x = x2, y = res, text = str.tostring(res, format.mintick),
                    style = label.style_label_left, size = labelSize, color = color.new(colRes, 100), textcolor = colRes)
                lblSup := label.new(x = x2, y = sup, text = str.tostring(sup, format.mintick),
                    style = label.style_label_left, size = labelSize, color = color.new(colSup, 100), textcolor = colSup)
                lblMid := label.new(x = x2, y = base, text = str.tostring(base, format.mintick) + " Pivot" ,
                    style = label.style_label_left, size = labelSize, color = color.new(colMid, 100), textcolor = colMid)

                if showExp
                    lblResDev1 := label.new(x = x2, y = resDev1, text = str.tostring(resDev1, format.mintick),
                        style = label.style_label_left, size = labelSize, color = color.new(colMid, 100), textcolor = color.new(colRes, 50))
                    lblSupDev1 := label.new(x = x2, y = supDev1, text = str.tostring(supDev1, format.mintick),
                        style = label.style_label_left, size = labelSize, color = color.new(colMid, 100), textcolor = color.new(colSup, 50))

            if labelMode == "History"

                label.new(x = x2, y = res, text = str.tostring(res, format.mintick),
                    style = label.style_label_left, size = labelSize, color = color.new(colRes, 100), textcolor = colRes)
                label.new(x = x2, y = sup, text = str.tostring(sup, format.mintick),
                    style = label.style_label_left, size = labelSize, color = color.new(colSup, 100), textcolor = colSup)
                label.new(x = x2, y = base, text = str.tostring(base, format.mintick),
                    style = label.style_label_left, size = labelSize, color = color.new(colMid, 100), textcolor = colMid)

                if showExp
                    lblResDev1 := label.new(x = x2, y = resDev1, text = str.tostring(resDev1, format.mintick),
                        style = label.style_label_left, size = labelSize, color = color.new(colMid, 100), textcolor = color.new(colRes, 50))
                    lblSupDev1 := label.new(x = x2, y = supDev1, text = str.tostring(supDev1, format.mintick),
                        style = label.style_label_left, size = labelSize, color = color.new(colMid, 100), textcolor = color.new(colSup, 50))

    //===== START NEW HTF =====//
    htfOpen      := open
    htfHigh      := high
    htfLow       := low
    htfClose     := close
    htfStartTime := time

else
    //===== UPDATE RUNNING HTF =====//
    htfHigh  := math.max(htfHigh, high)
    htfLow   := math.min(htfLow, low)
    htfClose := close
````
