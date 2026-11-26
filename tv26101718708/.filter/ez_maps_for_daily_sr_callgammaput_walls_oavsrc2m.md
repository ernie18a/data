# EZ Maps for Daily S/R, Call/Gamma/Put walls 

- url: https://www.tradingview.com/script/OavsRc2M-EZ-Maps-for-Daily-S-R-Call-Gamma-Put-walls/
- type: indicator
- pine_id: PUB;6e40b67b2dc444dc85947a9365ac600a
- version: 2.0

## Description

Provides a easy means to insert Support and Resistance, call, put, gamma and many others if you so decide.  Also include Combo strikes for SpotGamma levels . Color coded, flexible...still a WIP but pretty close.  I may add Gamma thresholds but for now I just use one of the s/r levels and change the label.

## Source Code

````pine
//@version=6
indicator("Daily S/R Levels", overlay = true, max_labels_count = 500, max_lines_count = 500)

//====================
// Input Groups
//====================
grpWalls      = "Walls"
grpDayMove    = "SG Implied 1-Day Move"
grpRes        = "Resistance"
grpSup        = "Support"
grpComboT     = "Combo Strikes - Total"
grpComboN     = "Combo Strikes - Next Expiration"
grpDisplay    = "Display"
grpAlerts     = "Alerts"
grpLabels     = "Label Text"
grpColors     = "Colors"
grpLabelMode  = "Label Display Mode"

//====================
// Core Inputs
//====================
callWall  = input.float(0.0, "Call Wall", step = 5.0, group = grpWalls)
hedgeWall = input.float(0.0, "Hedge Wall", step = 5.0, group = grpWalls)
zeroGamma = input.float(0.0, "Zero Gamma", step = 5.0, group = grpWalls)
putWall   = input.float(0.0, "Put Wall", step = 5.0, group = grpWalls)
sgPivot   = input.float(0.0, "SG Pivot", step = 5.0, group = grpWalls)

dayMoveHigh = input.float(0.0, "Day Move High", step = 5.0, group = grpDayMove)
dayMoveLow  = input.float(0.0, "Day Move Low", step = 5.0, group = grpDayMove)

r5 = input.float(0.0, "Previous Day High", step = 5.0, group = grpRes)
r4 = input.float(0.0, "R4", step = 5.0, group = grpRes)
r3 = input.float(0.0, "R3", step = 5.0, group = grpRes)
r2 = input.float(0.0, "R2", step = 5.0, group = grpRes)
r1 = input.float(0.0, "R1", step = 5.0, group = grpRes)

s1 = input.float(0.0, "S1", step = 5.0, group = grpSup)
s2 = input.float(0.0, "S2", step = 5.0, group = grpSup)
s3 = input.float(0.0, "S3", step = 5.0, group = grpSup)
s4 = input.float(0.0, "S4", step = 5.0, group = grpSup)
s5 = input.float(0.0, "Previous Day Low", step = 5.0, group = grpSup)
s6 = input.float(0.0, "Previous Day Close", step = 5.0, group = grpSup)

c1 = input.float(0.0, "C1", step = 5.0, group = grpComboT)
c2 = input.float(0.0, "C2", step = 5.0, group = grpComboT)
c3 = input.float(0.0, "C3", step = 5.0, group = grpComboT)
c4 = input.float(0.0, "C4", step = 5.0, group = grpComboT)
c5 = input.float(0.0, "C5", step = 5.0, group = grpComboT)

cn1 = input.float(0.0, "CN1", step = 5.0, group = grpComboN)
cn2 = input.float(0.0, "CN2", step = 5.0, group = grpComboN)
cn3 = input.float(0.0, "CN3", step = 5.0, group = grpComboN)
cn4 = input.float(0.0, "CN4", step = 5.0, group = grpComboN)
cn5 = input.float(0.0, "CN5", step = 5.0, group = grpComboN)

//====================
// Display Inputs
//====================
showWalls       = input.bool(true, "Show Walls", group = grpDisplay)
showDayMove     = input.bool(true, "Show SG 1-Day Move", group = grpDisplay)
showDayMoveFill = input.bool(true, "Show 1-Day Move Fill", group = grpDisplay)
showResistance  = input.bool(true, "Show Resistance", group = grpDisplay)
showSupport     = input.bool(true, "Show Support", group = grpDisplay)
showComboTotal  = input.bool(true, "Show Total Combo Strikes", group = grpDisplay)
showComboNext   = input.bool(true, "Show Next Exp Combo Strikes", group = grpDisplay)
showLabels      = input.bool(true, "Show Labels", group = grpDisplay)

wallWidth       = input.int(3, "Wall Width", minval = 1, maxval = 6, group = grpDisplay)
levelWidth      = input.int(1, "Level Width", minval = 1, maxval = 4, group = grpDisplay)
comboWidth      = input.int(1, "Combo Width", minval = 1, maxval = 4, group = grpDisplay)
nearDistance    = input.float(5.0, "Near Alert Distance", step = 0.25, group = grpAlerts)
useTinyLabels   = input.bool(false, "Use Tiny Labels", group = grpDisplay)
labelOffsetBars = input.int(2, "Base Label Offset Right", minval = 0, maxval = 50, group = grpDisplay)
labelStep       = input.int(4, "Label Group Spacing", minval = 1, maxval = 20, group = grpDisplay)

labelSize = useTinyLabels ? size.tiny : size.small

//====================
// Label Display Mode
//====================
wallsMode      = input.string("Label + Value", "Walls Label Mode", options = ["Label + Value", "Value Only", "Label Only"], group = grpLabelMode)
dayMoveMode    = input.string("Label + Value", "SG 1-Day Move Label Mode", options = ["Label + Value", "Value Only", "Label Only"], group = grpLabelMode)
resistanceMode = input.string("Label + Value", "Resistance Label Mode", options = ["Label + Value", "Value Only", "Label Only"], group = grpLabelMode)
supportMode    = input.string("Label + Value", "Support Label Mode", options = ["Label + Value", "Value Only", "Label Only"], group = grpLabelMode)
comboTotalMode = input.string("Label + Value", "Total Combo Label Mode", options = ["Label + Value", "Value Only", "Label Only"], group = grpLabelMode)
comboNextMode  = input.string("Label + Value", "Next Exp Combo Label Mode", options = ["Label + Value", "Value Only", "Label Only"], group = grpLabelMode)

//====================
// Label Text Inputs
//====================
callText    = input.string("CW", "Call Wall Label", group = grpLabels)
hedgeText   = input.string("HW", "Hedge Wall Label", group = grpLabels)
zeroText    = input.string("ZG", "Zero Gamma Label", group = grpLabels)
putText     = input.string("PW", "Put Wall Label", group = grpLabels)
sgPivotText = input.string("SGPIVOT", "SG Pivot Label", group = grpLabels)

dmhText = input.string("DMH", "Day Move High Label", group = grpLabels)
dmlText = input.string("DML", "Day Move Low Label", group = grpLabels)

r5Text = input.string("PDH", "Previous Day High Label", group = grpLabels)
r4Text = input.string("R4", "R4 Label", group = grpLabels)
r3Text = input.string("R3", "R3 Label", group = grpLabels)
r2Text = input.string("R2", "R2 Label", group = grpLabels)
r1Text = input.string("R1", "R1 Label", group = grpLabels)

s1Text = input.string("S1", "S1 Label", group = grpLabels)
s2Text = input.string("S2", "S2 Label", group = grpLabels)
s3Text = input.string("S3", "S3 Label", group = grpLabels)
s4Text = input.string("S4", "S4 Label", group = grpLabels)
s5Text = input.string("PDL", "Previous Day Low Label", group = grpLabels)
s6Text = input.string("PDC", "Previous Day Close Label", group = grpLabels)

c1Text = input.string("C1", "C1 Label", group = grpLabels)
c2Text = input.string("C2", "C2 Label", group = grpLabels)
c3Text = input.string("C3", "C3 Label", group = grpLabels)
c4Text = input.string("C4", "C4 Label", group = grpLabels)
c5Text = input.string("C5", "C5 Label", group = grpLabels)

cn1Text = input.string("CN1", "CN1 Label", group = grpLabels)
cn2Text = input.string("CN2", "CN2 Label", group = grpLabels)
cn3Text = input.string("CN3", "CN3 Label", group = grpLabels)
cn4Text = input.string("CN4", "CN4 Label", group = grpLabels)
cn5Text = input.string("CN5", "CN5 Label", group = grpLabels)

//====================
// Color Inputs
//====================
callColor    = input.color(color.red, "Call Wall Color", group = grpColors)
hedgeColor   = input.color(color.fuchsia, "Hedge Wall Color", group = grpColors)
zeroColor    = input.color(color.orange, "Zero Gamma Color", group = grpColors)
putColor     = input.color(color.lime, "Put Wall Color", group = grpColors)
sgPivotColor = input.color(color.silver, "SG Pivot Color", group = grpColors)

dmhColor     = input.color(color.blue, "Day Move High Color", group = grpColors)
dmlColor     = input.color(color.blue, "Day Move Low Color", group = grpColors)
dayFillColor = input.color(color.new(color.blue, 90), "Day Move Fill Color", group = grpColors)

r5Color = input.color(color.new(color.red, 0), "Previous Day High Color", group = grpColors)
r4Color = input.color(color.new(color.red, 5), "R4 Color", group = grpColors)
r3Color = input.color(color.new(color.red, 15), "R3 Color", group = grpColors)
r2Color = input.color(color.new(color.red, 25), "R2 Color", group = grpColors)
r1Color = input.color(color.new(color.red, 35), "R1 Color", group = grpColors)

s1Color = input.color(color.new(color.green, 5), "S1 Color", group = grpColors)
s2Color = input.color(color.new(color.green, 15), "S2 Color", group = grpColors)
s3Color = input.color(color.new(color.green, 25), "S3 Color", group = grpColors)
s4Color = input.color(color.new(color.green, 35), "S4 Color", group = grpColors)
s5Color = input.color(color.new(color.green, 45), "Previous Day Low Color", group = grpColors)
s6Color = input.color(color.new(color.green, 55), "Previous Day Close Color", group = grpColors)

c1Color = input.color(color.aqua, "C1 Color", group = grpColors)
c2Color = input.color(color.aqua, "C2 Color", group = grpColors)
c3Color = input.color(color.aqua, "C3 Color", group = grpColors)
c4Color = input.color(color.aqua, "C4 Color", group = grpColors)
c5Color = input.color(color.aqua, "C5 Color", group = grpColors)

cn1Color = input.color(color.yellow, "CN1 Color", group = grpColors)
cn2Color = input.color(color.yellow, "CN2 Color", group = grpColors)
cn3Color = input.color(color.yellow, "CN3 Color", group = grpColors)
cn4Color = input.color(color.yellow, "CN4 Color", group = grpColors)
cn5Color = input.color(color.yellow, "CN5 Color", group = grpColors)

//====================
// Formatting helpers
//====================
fmtInt(v) =>
    str.tostring(math.round(v), "#")

buildLabel(mode, shortLabel, value) =>
    mode == "Value Only" ? fmtInt(value) : mode == "Label Only" ? shortLabel : shortLabel + " " + fmtInt(value)

isActive(v) =>
    v != 0.0

//====================
// Dynamic label text
//====================
txtCall    = buildLabel(wallsMode, callText, callWall)
txtHedge   = buildLabel(wallsMode, hedgeText, hedgeWall)
txtZero    = buildLabel(wallsMode, zeroText, zeroGamma)
txtPut     = buildLabel(wallsMode, putText, putWall)
txtSGPivot = buildLabel(wallsMode, sgPivotText, sgPivot)

txtDMH = buildLabel(dayMoveMode, dmhText, dayMoveHigh)
txtDML = buildLabel(dayMoveMode, dmlText, dayMoveLow)

txtR5 = buildLabel(resistanceMode, r5Text, r5)
txtR4 = buildLabel(resistanceMode, r4Text, r4)
txtR3 = buildLabel(resistanceMode, r3Text, r3)
txtR2 = buildLabel(resistanceMode, r2Text, r2)
txtR1 = buildLabel(resistanceMode, r1Text, r1)

txtS1 = buildLabel(supportMode, s1Text, s1)
txtS2 = buildLabel(supportMode, s2Text, s2)
txtS3 = buildLabel(supportMode, s3Text, s3)
txtS4 = buildLabel(supportMode, s4Text, s4)
txtS5 = buildLabel(supportMode, s5Text, s5)
txtS6 = buildLabel(supportMode, s6Text, s6)

txtC1 = buildLabel(comboTotalMode, c1Text, c1)
txtC2 = buildLabel(comboTotalMode, c2Text, c2)
txtC3 = buildLabel(comboTotalMode, c3Text, c3)
txtC4 = buildLabel(comboTotalMode, c4Text, c4)
txtC5 = buildLabel(comboTotalMode, c5Text, c5)

txtCN1 = buildLabel(comboNextMode, cn1Text, cn1)
txtCN2 = buildLabel(comboNextMode, cn2Text, cn2)
txtCN3 = buildLabel(comboNextMode, cn3Text, cn3)
txtCN4 = buildLabel(comboNextMode, cn4Text, cn4)
txtCN5 = buildLabel(comboNextMode, cn5Text, cn5)

//====================
// Hidden plots for fill
//====================
pDayHigh = plot(showDayMove and isActive(dayMoveHigh) ? dayMoveHigh : na, title = "Day Move High Fill Anchor", color = color.new(dmhColor, 100), linewidth = 1, display = display.none)
pDayLow  = plot(showDayMove and isActive(dayMoveLow) ? dayMoveLow : na, title = "Day Move Low Fill Anchor", color = color.new(dmlColor, 100), linewidth = 1, display = display.none)
fill(pDayHigh, pDayLow, color = showDayMove and showDayMoveFill and isActive(dayMoveHigh) and isActive(dayMoveLow) ? dayFillColor : color.new(color.white, 100), title = "SG Day Move Fill")

//====================
// Persistent objects
//====================
var line lCall    = na
var line lHedge   = na
var line lZero    = na
var line lPut     = na
var line lSGPivot = na
var line lDMH     = na
var line lDML     = na
var line lR5      = na
var line lR4      = na
var line lR3      = na
var line lR2      = na
var line lR1      = na
var line lS1      = na
var line lS2      = na
var line lS3      = na
var line lS4      = na
var line lS5      = na
var line lS6      = na
var line lC1      = na
var line lC2      = na
var line lC3      = na
var line lC4      = na
var line lC5      = na
var line lCN1     = na
var line lCN2     = na
var line lCN3     = na
var line lCN4     = na
var line lCN5     = na

var label lbCall    = na
var label lbHedge   = na
var label lbZero    = na
var label lbPut     = na
var label lbSGPivot = na
var label lbDMH     = na
var label lbDML     = na
var label lbR5      = na
var label lbR4      = na
var label lbR3      = na
var label lbR2      = na
var label lbR1      = na
var label lbS1      = na
var label lbS2      = na
var label lbS3      = na
var label lbS4      = na
var label lbS5      = na
var label lbS6      = na
var label lbC1      = na
var label lbC2      = na
var label lbC3      = na
var label lbC4      = na
var label lbC5      = na
var label lbCN1     = na
var label lbCN2     = na
var label lbCN3     = na
var label lbCN4     = na
var label lbCN5     = na

if barstate.islast
    xWalls     = bar_index + labelOffsetBars
    xRS        = xWalls + labelStep
    xCombo     = xRS + labelStep
    xComboNext = xCombo + labelStep

    if showWalls
        if isActive(callWall)
            if na(lCall)
                lCall := line.new(bar_index, callWall, bar_index + 1, callWall, xloc = xloc.bar_index, extend = extend.right, color = callColor, width = wallWidth)
            else
                line.set_xy1(lCall, bar_index, callWall)
                line.set_xy2(lCall, bar_index + 1, callWall)
                line.set_color(lCall, callColor)
                line.set_width(lCall, wallWidth)
        else
            line.delete(lCall)
            lCall := na

        if isActive(hedgeWall)
            if na(lHedge)
                lHedge := line.new(bar_index, hedgeWall, bar_index + 1, hedgeWall, xloc = xloc.bar_index, extend = extend.right, color = hedgeColor, width = levelWidth)
            else
                line.set_xy1(lHedge, bar_index, hedgeWall)
                line.set_xy2(lHedge, bar_index + 1, hedgeWall)
                line.set_color(lHedge, hedgeColor)
                line.set_width(lHedge, levelWidth)
        else
            line.delete(lHedge)
            lHedge := na

        if isActive(zeroGamma)
            if na(lZero)
                lZero := line.new(bar_index, zeroGamma, bar_index + 1, zeroGamma, xloc = xloc.bar_index, extend = extend.right, color = zeroColor, width = levelWidth)
            else
                line.set_xy1(lZero, bar_index, zeroGamma)
                line.set_xy2(lZero, bar_index + 1, zeroGamma)
                line.set_color(lZero, zeroColor)
                line.set_width(lZero, levelWidth)
        else
            line.delete(lZero)
            lZero := na

        if isActive(putWall)
            if na(lPut)
                lPut := line.new(bar_index, putWall, bar_index + 1, putWall, xloc = xloc.bar_index, extend = extend.right, color = putColor, width = wallWidth)
            else
                line.set_xy1(lPut, bar_index, putWall)
                line.set_xy2(lPut, bar_index + 1, putWall)
                line.set_color(lPut, putColor)
                line.set_width(lPut, wallWidth)
        else
            line.delete(lPut)
            lPut := na

        if isActive(sgPivot)
            if na(lSGPivot)
                lSGPivot := line.new(bar_index, sgPivot, bar_index + 1, sgPivot, xloc = xloc.bar_index, extend = extend.right, color = sgPivotColor, width = levelWidth)
            else
                line.set_xy1(lSGPivot, bar_index, sgPivot)
                line.set_xy2(lSGPivot, bar_index + 1, sgPivot)
                line.set_color(lSGPivot, sgPivotColor)
                line.set_width(lSGPivot, levelWidth)
        else
            line.delete(lSGPivot)
            lSGPivot := na
    else
        line.delete(lCall), line.delete(lHedge), line.delete(lZero), line.delete(lPut), line.delete(lSGPivot)
        lCall := na, lHedge := na, lZero := na, lPut := na, lSGPivot := na

    if showDayMove
        if isActive(dayMoveHigh)
            if na(lDMH)
                lDMH := line.new(bar_index, dayMoveHigh, bar_index + 1, dayMoveHigh, xloc = xloc.bar_index, extend = extend.right, color = dmhColor, width = levelWidth)
            else
                line.set_xy1(lDMH, bar_index, dayMoveHigh)
                line.set_xy2(lDMH, bar_index + 1, dayMoveHigh)
                line.set_color(lDMH, dmhColor)
                line.set_width(lDMH, levelWidth)
        else
            line.delete(lDMH)
            lDMH := na

        if isActive(dayMoveLow)
            if na(lDML)
                lDML := line.new(bar_index, dayMoveLow, bar_index + 1, dayMoveLow, xloc = xloc.bar_index, extend = extend.right, color = dmlColor, width = levelWidth)
            else
                line.set_xy1(lDML, bar_index, dayMoveLow)
                line.set_xy2(lDML, bar_index + 1, dayMoveLow)
                line.set_color(lDML, dmlColor)
                line.set_width(lDML, levelWidth)
        else
            line.delete(lDML)
            lDML := na
    else
        line.delete(lDMH), line.delete(lDML)
        lDMH := na, lDML := na

    if showResistance
        if isActive(r5)
            if na(lR5)
                lR5 := line.new(bar_index, r5, bar_index + 1, r5, xloc = xloc.bar_index, extend = extend.right, color = r5Color, width = levelWidth)
            else
                line.set_xy1(lR5, bar_index, r5), line.set_xy2(lR5, bar_index + 1, r5), line.set_color(lR5, r5Color), line.set_width(lR5, levelWidth)
        else
            line.delete(lR5), lR5 := na

        if isActive(r4)
            if na(lR4)
                lR4 := line.new(bar_index, r4, bar_index + 1, r4, xloc = xloc.bar_index, extend = extend.right, color = r4Color, width = levelWidth)
            else
                line.set_xy1(lR4, bar_index, r4), line.set_xy2(lR4, bar_index + 1, r4), line.set_color(lR4, r4Color), line.set_width(lR4, levelWidth)
        else
            line.delete(lR4), lR4 := na

        if isActive(r3)
            if na(lR3)
                lR3 := line.new(bar_index, r3, bar_index + 1, r3, xloc = xloc.bar_index, extend = extend.right, color = r3Color, width = levelWidth)
            else
                line.set_xy1(lR3, bar_index, r3), line.set_xy2(lR3, bar_index + 1, r3), line.set_color(lR3, r3Color), line.set_width(lR3, levelWidth)
        else
            line.delete(lR3), lR3 := na

        if isActive(r2)
            if na(lR2)
                lR2 := line.new(bar_index, r2, bar_index + 1, r2, xloc = xloc.bar_index, extend = extend.right, color = r2Color, width = levelWidth)
            else
                line.set_xy1(lR2, bar_index, r2), line.set_xy2(lR2, bar_index + 1, r2), line.set_color(lR2, r2Color), line.set_width(lR2, levelWidth)
        else
            line.delete(lR2), lR2 := na

        if isActive(r1)
            if na(lR1)
                lR1 := line.new(bar_index, r1, bar_index + 1, r1, xloc = xloc.bar_index, extend = extend.right, color = r1Color, width = levelWidth)
            else
                line.set_xy1(lR1, bar_index, r1), line.set_xy2(lR1, bar_index + 1, r1), line.set_color(lR1, r1Color), line.set_width(lR1, levelWidth)
        else
            line.delete(lR1), lR1 := na
    else
        line.delete(lR5), line.delete(lR4), line.delete(lR3), line.delete(lR2), line.delete(lR1)
        lR5 := na, lR4 := na, lR3 := na, lR2 := na, lR1 := na

    if showSupport
        if isActive(s1)
            if na(lS1)
                lS1 := line.new(bar_index, s1, bar_index + 1, s1, xloc = xloc.bar_index, extend = extend.right, color = s1Color, width = levelWidth)
            else
                line.set_xy1(lS1, bar_index, s1), line.set_xy2(lS1, bar_index + 1, s1), line.set_color(lS1, s1Color), line.set_width(lS1, levelWidth)
        else
            line.delete(lS1), lS1 := na

        if isActive(s2)
            if na(lS2)
                lS2 := line.new(bar_index, s2, bar_index + 1, s2, xloc = xloc.bar_index, extend = extend.right, color = s2Color, width = levelWidth)
            else
                line.set_xy1(lS2, bar_index, s2), line.set_xy2(lS2, bar_index + 1, s2), line.set_color(lS2, s2Color), line.set_width(lS2, levelWidth)
        else
            line.delete(lS2), lS2 := na

        if isActive(s3)
            if na(lS3)
                lS3 := line.new(bar_index, s3, bar_index + 1, s3, xloc = xloc.bar_index, extend = extend.right, color = s3Color, width = levelWidth)
            else
                line.set_xy1(lS3, bar_index, s3), line.set_xy2(lS3, bar_index + 1, s3), line.set_color(lS3, s3Color), line.set_width(lS3, levelWidth)
        else
            line.delete(lS3), lS3 := na

        if isActive(s4)
            if na(lS4)
                lS4 := line.new(bar_index, s4, bar_index + 1, s4, xloc = xloc.bar_index, extend = extend.right, color = s4Color, width = levelWidth)
            else
                line.set_xy1(lS4, bar_index, s4), line.set_xy2(lS4, bar_index + 1, s4), line.set_color(lS4, s4Color), line.set_width(lS4, levelWidth)
        else
            line.delete(lS4), lS4 := na

        if isActive(s5)
            if na(lS5)
                lS5 := line.new(bar_index, s5, bar_index + 1, s5, xloc = xloc.bar_index, extend = extend.right, color = s5Color, width = levelWidth)
            else
                line.set_xy1(lS5, bar_index, s5), line.set_xy2(lS5, bar_index + 1, s5), line.set_color(lS5, s5Color), line.set_width(lS5, levelWidth)
        else
            line.delete(lS5), lS5 := na

        if isActive(s6)
            if na(lS6)
                lS6 := line.new(bar_index, s6, bar_index + 1, s6, xloc = xloc.bar_index, extend = extend.right, color = s6Color, width = levelWidth)
            else
                line.set_xy1(lS6, bar_index, s6), line.set_xy2(lS6, bar_index + 1, s6), line.set_color(lS6, s6Color), line.set_width(lS6, levelWidth)
        else
            line.delete(lS6), lS6 := na
    else
        line.delete(lS1), line.delete(lS2), line.delete(lS3), line.delete(lS4), line.delete(lS5), line.delete(lS6)
        lS1 := na, lS2 := na, lS3 := na, lS4 := na, lS5 := na, lS6 := na

    if showComboTotal
        if isActive(c1)
            if na(lC1)
                lC1 := line.new(bar_index, c1, bar_index + 1, c1, xloc = xloc.bar_index, extend = extend.right, color = c1Color, width = comboWidth)
            else
                line.set_xy1(lC1, bar_index, c1), line.set_xy2(lC1, bar_index + 1, c1), line.set_color(lC1, c1Color), line.set_width(lC1, comboWidth)
        else
            line.delete(lC1), lC1 := na

        if isActive(c2)
            if na(lC2)
                lC2 := line.new(bar_index, c2, bar_index + 1, c2, xloc = xloc.bar_index, extend = extend.right, color = c2Color, width = comboWidth)
            else
                line.set_xy1(lC2, bar_index, c2), line.set_xy2(lC2, bar_index + 1, c2), line.set_color(lC2, c2Color), line.set_width(lC2, comboWidth)
        else
            line.delete(lC2), lC2 := na

        if isActive(c3)
            if na(lC3)
                lC3 := line.new(bar_index, c3, bar_index + 1, c3, xloc = xloc.bar_index, extend = extend.right, color = c3Color, width = comboWidth)
            else
                line.set_xy1(lC3, bar_index, c3), line.set_xy2(lC3, bar_index + 1, c3), line.set_color(lC3, c3Color), line.set_width(lC3, comboWidth)
        else
            line.delete(lC3), lC3 := na

        if isActive(c4)
            if na(lC4)
                lC4 := line.new(bar_index, c4, bar_index + 1, c4, xloc = xloc.bar_index, extend = extend.right, color = c4Color, width = comboWidth)
            else
                line.set_xy1(lC4, bar_index, c4), line.set_xy2(lC4, bar_index + 1, c4), line.set_color(lC4, c4Color), line.set_width(lC4, comboWidth)
        else
            line.delete(lC4), lC4 := na

        if isActive(c5)
            if na(lC5)
                lC5 := line.new(bar_index, c5, bar_index + 1, c5, xloc = xloc.bar_index, extend = extend.right, color = c5Color, width = comboWidth)
            else
                line.set_xy1(lC5, bar_index, c5), line.set_xy2(lC5, bar_index + 1, c5), line.set_color(lC5, c5Color), line.set_width(lC5, comboWidth)
        else
            line.delete(lC5), lC5 := na
    else
        line.delete(lC1), line.delete(lC2), line.delete(lC3), line.delete(lC4), line.delete(lC5)
        lC1 := na, lC2 := na, lC3 := na, lC4 := na, lC5 := na

    if showComboNext
        if isActive(cn1)
            if na(lCN1)
                lCN1 := line.new(bar_index, cn1, bar_index + 1, cn1, xloc = xloc.bar_index, extend = extend.right, color = cn1Color, width = comboWidth)
            else
                line.set_xy1(lCN1, bar_index, cn1), line.set_xy2(lCN1, bar_index + 1, cn1), line.set_color(lCN1, cn1Color), line.set_width(lCN1, comboWidth)
        else
            line.delete(lCN1), lCN1 := na

        if isActive(cn2)
            if na(lCN2)
                lCN2 := line.new(bar_index, cn2, bar_index + 1, cn2, xloc = xloc.bar_index, extend = extend.right, color = cn2Color, width = comboWidth)
            else
                line.set_xy1(lCN2, bar_index, cn2), line.set_xy2(lCN2, bar_index + 1, cn2), line.set_color(lCN2, cn2Color), line.set_width(lCN2, comboWidth)
        else
            line.delete(lCN2), lCN2 := na

        if isActive(cn3)
            if na(lCN3)
                lCN3 := line.new(bar_index, cn3, bar_index + 1, cn3, xloc = xloc.bar_index, extend = extend.right, color = cn3Color, width = comboWidth)
            else
                line.set_xy1(lCN3, bar_index, cn3), line.set_xy2(lCN3, bar_index + 1, cn3), line.set_color(lCN3, cn3Color), line.set_width(lCN3, comboWidth)
        else
            line.delete(lCN3), lCN3 := na

        if isActive(cn4)
            if na(lCN4)
                lCN4 := line.new(bar_index, cn4, bar_index + 1, cn4, xloc = xloc.bar_index, extend = extend.right, color = cn4Color, width = comboWidth)
            else
                line.set_xy1(lCN4, bar_index, cn4), line.set_xy2(lCN4, bar_index + 1, cn4), line.set_color(lCN4, cn4Color), line.set_width(lCN4, comboWidth)
        else
            line.delete(lCN4), lCN4 := na

        if isActive(cn5)
            if na(lCN5)
                lCN5 := line.new(bar_index, cn5, bar_index + 1, cn5, xloc = xloc.bar_index, extend = extend.right, color = cn5Color, width = comboWidth)
            else
                line.set_xy1(lCN5, bar_index, cn5), line.set_xy2(lCN5, bar_index + 1, cn5), line.set_color(lCN5, cn5Color), line.set_width(lCN5, comboWidth)
        else
            line.delete(lCN5), lCN5 := na
    else
        line.delete(lCN1), line.delete(lCN2), line.delete(lCN3), line.delete(lCN4), line.delete(lCN5)
        lCN1 := na, lCN2 := na, lCN3 := na, lCN4 := na, lCN5 := na

    if showLabels and showWalls
        if isActive(callWall)
            if na(lbCall)
                lbCall := label.new(xWalls, callWall, txtCall, xloc = xloc.bar_index, style = label.style_label_left, color = callColor, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbCall, xWalls), label.set_y(lbCall, callWall), label.set_text(lbCall, txtCall), label.set_color(lbCall, callColor), label.set_textcolor(lbCall, color.white)
        else
            label.delete(lbCall), lbCall := na

        if isActive(hedgeWall)
            if na(lbHedge)
                lbHedge := label.new(xWalls, hedgeWall, txtHedge, xloc = xloc.bar_index, style = label.style_label_left, color = hedgeColor, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbHedge, xWalls), label.set_y(lbHedge, hedgeWall), label.set_text(lbHedge, txtHedge), label.set_color(lbHedge, hedgeColor), label.set_textcolor(lbHedge, color.white)
        else
            label.delete(lbHedge), lbHedge := na

        if isActive(zeroGamma)
            if na(lbZero)
                lbZero := label.new(xWalls, zeroGamma, txtZero, xloc = xloc.bar_index, style = label.style_label_left, color = zeroColor, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbZero, xWalls), label.set_y(lbZero, zeroGamma), label.set_text(lbZero, txtZero), label.set_color(lbZero, zeroColor), label.set_textcolor(lbZero, color.black)
        else
            label.delete(lbZero), lbZero := na

        if isActive(putWall)
            if na(lbPut)
                lbPut := label.new(xWalls, putWall, txtPut, xloc = xloc.bar_index, style = label.style_label_left, color = putColor, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbPut, xWalls), label.set_y(lbPut, putWall), label.set_text(lbPut, txtPut), label.set_color(lbPut, putColor), label.set_textcolor(lbPut, color.black)
        else
            label.delete(lbPut), lbPut := na

        if isActive(sgPivot)
            if na(lbSGPivot)
                lbSGPivot := label.new(xWalls, sgPivot, txtSGPivot, xloc = xloc.bar_index, style = label.style_label_left, color = sgPivotColor, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbSGPivot, xWalls), label.set_y(lbSGPivot, sgPivot), label.set_text(lbSGPivot, txtSGPivot), label.set_color(lbSGPivot, sgPivotColor), label.set_textcolor(lbSGPivot, color.black)
        else
            label.delete(lbSGPivot), lbSGPivot := na
    else
        label.delete(lbCall), label.delete(lbHedge), label.delete(lbZero), label.delete(lbPut), label.delete(lbSGPivot)
        lbCall := na, lbHedge := na, lbZero := na, lbPut := na, lbSGPivot := na

    if showLabels and showDayMove
        if isActive(dayMoveHigh)
            if na(lbDMH)
                lbDMH := label.new(xWalls, dayMoveHigh, txtDMH, xloc = xloc.bar_index, style = label.style_label_left, color = dmhColor, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbDMH, xWalls), label.set_y(lbDMH, dayMoveHigh), label.set_text(lbDMH, txtDMH), label.set_color(lbDMH, dmhColor), label.set_textcolor(lbDMH, color.white)
        else
            label.delete(lbDMH), lbDMH := na

        if isActive(dayMoveLow)
            if na(lbDML)
                lbDML := label.new(xWalls, dayMoveLow, txtDML, xloc = xloc.bar_index, style = label.style_label_left, color = dmlColor, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbDML, xWalls), label.set_y(lbDML, dayMoveLow), label.set_text(lbDML, txtDML), label.set_color(lbDML, dmlColor), label.set_textcolor(lbDML, color.white)
        else
            label.delete(lbDML), lbDML := na
    else
        label.delete(lbDMH), label.delete(lbDML)
        lbDMH := na, lbDML := na

    if showLabels and showResistance
        if isActive(r5)
            if na(lbR5)
                lbR5 := label.new(xRS, r5, txtR5, xloc = xloc.bar_index, style = label.style_label_left, color = r5Color, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbR5, xRS), label.set_y(lbR5, r5), label.set_text(lbR5, txtR5), label.set_color(lbR5, r5Color), label.set_textcolor(lbR5, color.white)
        else
            label.delete(lbR5), lbR5 := na

        if isActive(r4)
            if na(lbR4)
                lbR4 := label.new(xRS, r4, txtR4, xloc = xloc.bar_index, style = label.style_label_left, color = r4Color, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbR4, xRS), label.set_y(lbR4, r4), label.set_text(lbR4, txtR4), label.set_color(lbR4, r4Color), label.set_textcolor(lbR4, color.white)
        else
            label.delete(lbR4), lbR4 := na

        if isActive(r3)
            if na(lbR3)
                lbR3 := label.new(xRS, r3, txtR3, xloc = xloc.bar_index, style = label.style_label_left, color = r3Color, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbR3, xRS), label.set_y(lbR3, r3), label.set_text(lbR3, txtR3), label.set_color(lbR3, r3Color), label.set_textcolor(lbR3, color.white)
        else
            label.delete(lbR3), lbR3 := na

        if isActive(r2)
            if na(lbR2)
                lbR2 := label.new(xRS, r2, txtR2, xloc = xloc.bar_index, style = label.style_label_left, color = r2Color, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbR2, xRS), label.set_y(lbR2, r2), label.set_text(lbR2, txtR2), label.set_color(lbR2, r2Color), label.set_textcolor(lbR2, color.white)
        else
            label.delete(lbR2), lbR2 := na

        if isActive(r1)
            if na(lbR1)
                lbR1 := label.new(xRS, r1, txtR1, xloc = xloc.bar_index, style = label.style_label_left, color = r1Color, textcolor = color.white, size = labelSize)
            else
                label.set_x(lbR1, xRS), label.set_y(lbR1, r1), label.set_text(lbR1, txtR1), label.set_color(lbR1, r1Color), label.set_textcolor(lbR1, color.white)
        else
            label.delete(lbR1), lbR1 := na
    else
        label.delete(lbR5), label.delete(lbR4), label.delete(lbR3), label.delete(lbR2), label.delete(lbR1)
        lbR5 := na, lbR4 := na, lbR3 := na, lbR2 := na, lbR1 := na

    if showLabels and showSupport
        if isActive(s1)
            if na(lbS1)
                lbS1 := label.new(xRS, s1, txtS1, xloc = xloc.bar_index, style = label.style_label_left, color = s1Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbS1, xRS), label.set_y(lbS1, s1), label.set_text(lbS1, txtS1), label.set_color(lbS1, s1Color), label.set_textcolor(lbS1, color.black)
        else
            label.delete(lbS1), lbS1 := na

        if isActive(s2)
            if na(lbS2)
                lbS2 := label.new(xRS, s2, txtS2, xloc = xloc.bar_index, style = label.style_label_left, color = s2Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbS2, xRS), label.set_y(lbS2, s2), label.set_text(lbS2, txtS2), label.set_color(lbS2, s2Color), label.set_textcolor(lbS2, color.black)
        else
            label.delete(lbS2), lbS2 := na

        if isActive(s3)
            if na(lbS3)
                lbS3 := label.new(xRS, s3, txtS3, xloc = xloc.bar_index, style = label.style_label_left, color = s3Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbS3, xRS), label.set_y(lbS3, s3), label.set_text(lbS3, txtS3), label.set_color(lbS3, s3Color), label.set_textcolor(lbS3, color.black)
        else
            label.delete(lbS3), lbS3 := na

        if isActive(s4)
            if na(lbS4)
                lbS4 := label.new(xRS, s4, txtS4, xloc = xloc.bar_index, style = label.style_label_left, color = s4Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbS4, xRS), label.set_y(lbS4, s4), label.set_text(lbS4, txtS4), label.set_color(lbS4, s4Color), label.set_textcolor(lbS4, color.black)
        else
            label.delete(lbS4), lbS4 := na

        if isActive(s5)
            if na(lbS5)
                lbS5 := label.new(xRS, s5, txtS5, xloc = xloc.bar_index, style = label.style_label_left, color = s5Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbS5, xRS), label.set_y(lbS5, s5), label.set_text(lbS5, txtS5), label.set_color(lbS5, s5Color), label.set_textcolor(lbS5, color.black)
        else
            label.delete(lbS5), lbS5 := na

        if isActive(s6)
            if na(lbS6)
                lbS6 := label.new(xRS, s6, txtS6, xloc = xloc.bar_index, style = label.style_label_left, color = s6Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbS6, xRS), label.set_y(lbS6, s6), label.set_text(lbS6, txtS6), label.set_color(lbS6, s6Color), label.set_textcolor(lbS6, color.black)
        else
            label.delete(lbS6), lbS6 := na
    else
        label.delete(lbS1), label.delete(lbS2), label.delete(lbS3), label.delete(lbS4), label.delete(lbS5), label.delete(lbS6)
        lbS1 := na, lbS2 := na, lbS3 := na, lbS4 := na, lbS5 := na, lbS6 := na

    if showLabels and showComboTotal
        if isActive(c1)
            if na(lbC1)
                lbC1 := label.new(xCombo, c1, txtC1, xloc = xloc.bar_index, style = label.style_label_left, color = c1Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbC1, xCombo), label.set_y(lbC1, c1), label.set_text(lbC1, txtC1), label.set_color(lbC1, c1Color), label.set_textcolor(lbC1, color.black)
        else
            label.delete(lbC1), lbC1 := na

        if isActive(c2)
            if na(lbC2)
                lbC2 := label.new(xCombo, c2, txtC2, xloc = xloc.bar_index, style = label.style_label_left, color = c2Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbC2, xCombo), label.set_y(lbC2, c2), label.set_text(lbC2, txtC2), label.set_color(lbC2, c2Color), label.set_textcolor(lbC2, color.black)
        else
            label.delete(lbC2), lbC2 := na

        if isActive(c3)
            if na(lbC3)
                lbC3 := label.new(xCombo, c3, txtC3, xloc = xloc.bar_index, style = label.style_label_left, color = c3Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbC3, xCombo), label.set_y(lbC3, c3), label.set_text(lbC3, txtC3), label.set_color(lbC3, c3Color), label.set_textcolor(lbC3, color.black)
        else
            label.delete(lbC3), lbC3 := na

        if isActive(c4)
            if na(lbC4)
                lbC4 := label.new(xCombo, c4, txtC4, xloc = xloc.bar_index, style = label.style_label_left, color = c4Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbC4, xCombo), label.set_y(lbC4, c4), label.set_text(lbC4, txtC4), label.set_color(lbC4, c4Color), label.set_textcolor(lbC4, color.black)
        else
            label.delete(lbC4), lbC4 := na

        if isActive(c5)
            if na(lbC5)
                lbC5 := label.new(xCombo, c5, txtC5, xloc = xloc.bar_index, style = label.style_label_left, color = c5Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbC5, xCombo), label.set_y(lbC5, c5), label.set_text(lbC5, txtC5), label.set_color(lbC5, c5Color), label.set_textcolor(lbC5, color.black)
        else
            label.delete(lbC5), lbC5 := na
    else
        label.delete(lbC1), label.delete(lbC2), label.delete(lbC3), label.delete(lbC4), label.delete(lbC5)
        lbC1 := na, lbC2 := na, lbC3 := na, lbC4 := na, lbC5 := na

    if showLabels and showComboNext
        if isActive(cn1)
            if na(lbCN1)
                lbCN1 := label.new(xComboNext, cn1, txtCN1, xloc = xloc.bar_index, style = label.style_label_left, color = cn1Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbCN1, xComboNext), label.set_y(lbCN1, cn1), label.set_text(lbCN1, txtCN1), label.set_color(lbCN1, cn1Color), label.set_textcolor(lbCN1, color.black)
        else
            label.delete(lbCN1), lbCN1 := na

        if isActive(cn2)
            if na(lbCN2)
                lbCN2 := label.new(xComboNext, cn2, txtCN2, xloc = xloc.bar_index, style = label.style_label_left, color = cn2Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbCN2, xComboNext), label.set_y(lbCN2, cn2), label.set_text(lbCN2, txtCN2), label.set_color(lbCN2, cn2Color), label.set_textcolor(lbCN2, color.black)
        else
            label.delete(lbCN2), lbCN2 := na

        if isActive(cn3)
            if na(lbCN3)
                lbCN3 := label.new(xComboNext, cn3, txtCN3, xloc = xloc.bar_index, style = label.style_label_left, color = cn3Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbCN3, xComboNext), label.set_y(lbCN3, cn3), label.set_text(lbCN3, txtCN3), label.set_color(lbCN3, cn3Color), label.set_textcolor(lbCN3, color.black)
        else
            label.delete(lbCN3), lbCN3 := na

        if isActive(cn4)
            if na(lbCN4)
                lbCN4 := label.new(xComboNext, cn4, txtCN4, xloc = xloc.bar_index, style = label.style_label_left, color = cn4Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbCN4, xComboNext), label.set_y(lbCN4, cn4), label.set_text(lbCN4, txtCN4), label.set_color(lbCN4, cn4Color), label.set_textcolor(lbCN4, color.black)
        else
            label.delete(lbCN4), lbCN4 := na

        if isActive(cn5)
            if na(lbCN5)
                lbCN5 := label.new(xComboNext, cn5, txtCN5, xloc = xloc.bar_index, style = label.style_label_left, color = cn5Color, textcolor = color.black, size = labelSize)
            else
                label.set_x(lbCN5, xComboNext), label.set_y(lbCN5, cn5), label.set_text(lbCN5, txtCN5), label.set_color(lbCN5, cn5Color), label.set_textcolor(lbCN5, color.black)
        else
            label.delete(lbCN5), lbCN5 := na
    else
        label.delete(lbCN1), label.delete(lbCN2), label.delete(lbCN3), label.delete(lbCN4), label.delete(lbCN5)
        lbCN1 := na, lbCN2 := na, lbCN3 := na, lbCN4 := na, lbCN5 := na

//====================
// Alerts
//====================
nearCall    = showWalls and isActive(callWall) and math.abs(close - callWall) <= nearDistance
nearHedge   = showWalls and isActive(hedgeWall) and math.abs(close - hedgeWall) <= nearDistance
nearZero    = showWalls and isActive(zeroGamma) and math.abs(close - zeroGamma) <= nearDistance
nearPut     = showWalls and isActive(putWall) and math.abs(close - putWall) <= nearDistance
nearSGPivot = showWalls and isActive(sgPivot) and math.abs(close - sgPivot) <= nearDistance

nearDMH = showDayMove and isActive(dayMoveHigh) and math.abs(close - dayMoveHigh) <= nearDistance
nearDML = showDayMove and isActive(dayMoveLow) and math.abs(close - dayMoveLow) <= nearDistance

nearR5 = showResistance and isActive(r5) and math.abs(close - r5) <= nearDistance
nearR4 = showResistance and isActive(r4) and math.abs(close - r4) <= nearDistance
nearR3 = showResistance and isActive(r3) and math.abs(close - r3) <= nearDistance
nearR2 = showResistance and isActive(r2) and math.abs(close - r2) <= nearDistance
nearR1 = showResistance and isActive(r1) and math.abs(close - r1) <= nearDistance

nearS1 = showSupport and isActive(s1) and math.abs(close - s1) <= nearDistance
nearS2 = showSupport and isActive(s2) and math.abs(close - s2) <= nearDistance
nearS3 = showSupport and isActive(s3) and math.abs(close - s3) <= nearDistance
nearS4 = showSupport and isActive(s4) and math.abs(close - s4) <= nearDistance
nearS5 = showSupport and isActive(s5) and math.abs(close - s5) <= nearDistance
nearS6 = showSupport and isActive(s6) and math.abs(close - s6) <= nearDistance

nearC1 = showComboTotal and isActive(c1) and math.abs(close - c1) <= nearDistance
nearC2 = showComboTotal and isActive(c2) and math.abs(close - c2) <= nearDistance
nearC3 = showComboTotal and isActive(c3) and math.abs(close - c3) <= nearDistance
nearC4 = showComboTotal and isActive(c4) and math.abs(close - c4) <= nearDistance
nearC5 = showComboTotal and isActive(c5) and math.abs(close - c5) <= nearDistance

nearCN1 = showComboNext and isActive(cn1) and math.abs(close - cn1) <= nearDistance
nearCN2 = showComboNext and isActive(cn2) and math.abs(close - cn2) <= nearDistance
nearCN3 = showComboNext and isActive(cn3) and math.abs(close - cn3) <= nearDistance
nearCN4 = showComboNext and isActive(cn4) and math.abs(close - cn4) <= nearDistance
nearCN5 = showComboNext and isActive(cn5) and math.abs(close - cn5) <= nearDistance

nearAnyLevel = nearCall or nearHedge or nearZero or nearPut or nearSGPivot or nearDMH or nearDML or nearR5 or nearR4 or nearR3 or nearR2 or nearR1 or nearS1 or nearS2 or nearS3 or nearS4 or nearS5 or nearS6 or nearC1 or nearC2 or nearC3 or nearC4 or nearC5 or nearCN1 or nearCN2 or nearCN3 or nearCN4 or nearCN5

alertcondition(nearCall,    title = "Near Call Wall",    message = "Price is near Call Wall")
alertcondition(nearHedge,   title = "Near Hedge Wall",   message = "Price is near Hedge Wall")
alertcondition(nearZero,    title = "Near Zero Gamma",   message = "Price is near Zero Gamma")
alertcondition(nearPut,     title = "Near Put Wall",     message = "Price is near Put Wall")
alertcondition(nearSGPivot, title = "Near SG Pivot",     message = "Price is near SG Pivot")

alertcondition(nearDMH, title = "Near Day Move High", message = "Price is near Day Move High")
alertcondition(nearDML, title = "Near Day Move Low",  message = "Price is near Day Move Low")

alertcondition(nearR5, title = "Near Previous Day High", message = "Price is near Previous Day High")
alertcondition(nearR4, title = "Near R4", message = "Price is near R4")
alertcondition(nearR3, title = "Near R3", message = "Price is near R3")
alertcondition(nearR2, title = "Near R2", message = "Price is near R2")
alertcondition(nearR1, title = "Near R1", message = "Price is near R1")

alertcondition(nearS1, title = "Near S1", message = "Price is near S1")
alertcondition(nearS2, title = "Near S2", message = "Price is near S2")
alertcondition(nearS3, title = "Near S3", message = "Price is near S3")
alertcondition(nearS4, title = "Near S4", message = "Price is near S4")
alertcondition(nearS5, title = "Near Previous Day Low", message = "Price is near Previous Day Low")
alertcondition(nearS6, title = "Near Previous Day Close", message = "Price is near Previous Day Close")

alertcondition(nearC1, title = "Near C1", message = "Price is near C1")
alertcondition(nearC2, title = "Near C2", message = "Price is near C2")
alertcondition(nearC3, title = "Near C3", message = "Price is near C3")
alertcondition(nearC4, title = "Near C4", message = "Price is near C4")
alertcondition(nearC5, title = "Near C5", message = "Price is near C5")

alertcondition(nearCN1, title = "Near CN1", message = "Price is near CN1")
alertcondition(nearCN2, title = "Near CN2", message = "Price is near CN2")
alertcondition(nearCN3, title = "Near CN3", message = "Price is near CN3")
alertcondition(nearCN4, title = "Near CN4", message = "Price is near CN4")
alertcondition(nearCN5, title = "Near CN5", message = "Price is near CN5")

alertcondition(nearAnyLevel, title = "Near Any Key Level", message = "Price is near at least one key level")
````
