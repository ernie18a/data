# FX Fix Range Boxes

- url: https://www.tradingview.com/script/NxzQlmqN-FX-Fix-Range-Boxes/
- type: indicator
- pine_id: PUB;bd8186b4c18c4d3f804ca158bea0b871
- version: 1.0

## Description

As there for retail investors exists some ambiguity as to the fixes, this indicator enables you to draw a box around the entire timeframe of a fix e.g. 3:50pm to 4:00pm London time, and as well to draw a line at certain time that "most people" use, e.g. 4:00pm London time.

## Source Code

````pine
//@version=6
indicator("FX Fix Range Boxes", overlay=true, max_boxes_count=20, max_lines_count=40, max_labels_count=20)

// ============================================================
//  GENERAL
// ============================================================
tz = input.string("Europe/Lisbon", "Timezone",
     options=["Europe/Lisbon","Europe/London","Europe/Berlin","America/New_York","Asia/Tokyo","UTC"],
     group="General")

transparent = color.new(color.white, 100)

// ============================================================
//  SLOT 1 — CURRENT
// ============================================================
g1c = "Slot 1 — Current"
on1   = input.bool(true,           "Enabled",           group=g1c)
ses1  = input.session("0150-0200", "Window",            group=g1c)
col1  = input.color(color.purple,  "Fill Color",        group=g1c)
fl1   = input.int(85,              "Fill Transparency", minval=0, maxval=100, group=g1c)
lnCol1   = input.color(color.purple, "Line Color (top/bottom)", group=g1c)
lnSty1   = input.string("Solid",     "Line Style",  options=["Solid","Dashed","Dotted"], group=g1c)
lnW1     = input.int(1,              "Line Width",  minval=1, maxval=5, group=g1c)
showLbl1    = input.bool(true,            "Show Label",         group=g1c)
nm1         = input.string("Tokyo Fix",   "Label Text",         group=g1c)
lblBg1      = input.color(color.purple,   "Label Background",   group=g1c)
lblTxt1     = input.color(color.white,    "Label Text Color",   group=g1c)
lblSizeS1   = input.string("small",       "Label Size",   options=["tiny","small","normal","large","huge"], group=g1c)
lblAnchorS1 = input.string("Left arrow",  "Label Anchor", options=["Left arrow","Right arrow","None"], group=g1c)
showFix1    = input.bool(true,            "Show Fix Line",   group=g1c)
fixH1       = input.int(1,                "Fix Hour",   minval=0, maxval=23, group=g1c, inline="fix1")
fixM1       = input.int(55,               "Fix Minute", minval=0, maxval=59, group=g1c, inline="fix1")
fixCol1     = input.color(color.purple,   "Fix Line Color",  group=g1c)
fixSty1     = input.string("Solid",       "Fix Line Style",  options=["Solid","Dashed","Dotted"], group=g1c)
fixLw1      = input.int(2,                "Fix Line Width",  minval=1, maxval=5, group=g1c)

// ============================================================
//  SLOT 1 — PREVIOUS
// ============================================================
g1p = "Slot 1 — Previous"
showPrev1    = input.bool(true,                         "Show Previous",     group=g1p)
pCol1        = input.color(color.new(color.purple, 40), "Fill Color",        group=g1p)
pFl1         = input.int(90,                            "Fill Transparency", minval=0, maxval=100, group=g1p)
pLnCol1      = input.color(color.new(color.purple, 40), "Line Color (top/bottom)", group=g1p)
pLnSty1      = input.string("Dashed",                   "Line Style", options=["Solid","Dashed","Dotted"], group=g1p)
pLnW1        = input.int(1,                             "Line Width", minval=1, maxval=5, group=g1p)
pShowLbl1    = input.bool(true,                         "Show Label",        group=g1p)
pNm1         = input.string("P Tokyo Fix",              "Label Text",        group=g1p)
pLblBg1      = input.color(color.new(color.purple, 40), "Label Background",  group=g1p)
pLblTxt1     = input.color(color.white,                 "Label Text Color",  group=g1p)
pLblSizeS1   = input.string("small",       "Label Size",   options=["tiny","small","normal","large","huge"], group=g1p)
pLblAnchorS1 = input.string("Left arrow",  "Label Anchor", options=["Left arrow","Right arrow","None"], group=g1p)
pShowFix1    = input.bool(true,                         "Show Fix Line",   group=g1p)
pFixCol1     = input.color(color.new(color.purple, 40), "Fix Line Color",  group=g1p)
pFixSty1     = input.string("Dashed",      "Fix Line Style", options=["Solid","Dashed","Dotted"], group=g1p)
pFixLw1      = input.int(2,                "Fix Line Width", minval=1, maxval=5, group=g1p)

// ============================================================
//  SLOT 2 — CURRENT
// ============================================================
g2c = "Slot 2 — Current"
on2   = input.bool(true,           "Enabled",           group=g2c)
ses2  = input.session("1555-1605", "Window",            group=g2c)
col2  = input.color(color.green,   "Fill Color",        group=g2c)
fl2   = input.int(85,              "Fill Transparency", minval=0, maxval=100, group=g2c)
lnCol2   = input.color(color.green,  "Line Color (top/bottom)", group=g2c)
lnSty2   = input.string("Solid",     "Line Style",  options=["Solid","Dashed","Dotted"], group=g2c)
lnW2     = input.int(1,              "Line Width",  minval=1, maxval=5, group=g2c)
showLbl2    = input.bool(true,            "Show Label",         group=g2c)
nm2         = input.string("WMR Fix",     "Label Text",         group=g2c)
lblBg2      = input.color(color.green,    "Label Background",   group=g2c)
lblTxt2     = input.color(color.white,    "Label Text Color",   group=g2c)
lblSizeS2   = input.string("small",       "Label Size",   options=["tiny","small","normal","large","huge"], group=g2c)
lblAnchorS2 = input.string("Left arrow",  "Label Anchor", options=["Left arrow","Right arrow","None"], group=g2c)
showFix2    = input.bool(true,            "Show Fix Line",   group=g2c)
fixH2       = input.int(16,               "Fix Hour",   minval=0, maxval=23, group=g2c, inline="fix2")
fixM2       = input.int(0,                "Fix Minute", minval=0, maxval=59, group=g2c, inline="fix2")
fixCol2     = input.color(color.green,    "Fix Line Color",  group=g2c)
fixSty2     = input.string("Solid",       "Fix Line Style",  options=["Solid","Dashed","Dotted"], group=g2c)
fixLw2      = input.int(2,                "Fix Line Width",  minval=1, maxval=5, group=g2c)

// ============================================================
//  SLOT 2 — PREVIOUS
// ============================================================
g2p = "Slot 2 — Previous"
showPrev2    = input.bool(true,                        "Show Previous",     group=g2p)
pCol2        = input.color(color.new(color.green, 40), "Fill Color",        group=g2p)
pFl2         = input.int(90,                           "Fill Transparency", minval=0, maxval=100, group=g2p)
pLnCol2      = input.color(color.new(color.green, 40), "Line Color (top/bottom)", group=g2p)
pLnSty2      = input.string("Dashed",                  "Line Style", options=["Solid","Dashed","Dotted"], group=g2p)
pLnW2        = input.int(1,                            "Line Width", minval=1, maxval=5, group=g2p)
pShowLbl2    = input.bool(true,                        "Show Label",        group=g2p)
pNm2         = input.string("P WMR Fix",               "Label Text",        group=g2p)
pLblBg2      = input.color(color.new(color.green, 40), "Label Background",  group=g2p)
pLblTxt2     = input.color(color.white,                "Label Text Color",  group=g2p)
pLblSizeS2   = input.string("small",       "Label Size",   options=["tiny","small","normal","large","huge"], group=g2p)
pLblAnchorS2 = input.string("Left arrow",  "Label Anchor", options=["Left arrow","Right arrow","None"], group=g2p)
pShowFix2    = input.bool(true,                        "Show Fix Line",   group=g2p)
pFixCol2     = input.color(color.new(color.green, 40), "Fix Line Color",  group=g2p)
pFixSty2     = input.string("Dashed",      "Fix Line Style", options=["Solid","Dashed","Dotted"], group=g2p)
pFixLw2      = input.int(2,                "Fix Line Width", minval=1, maxval=5, group=g2p)

// ============================================================
//  HELPERS
// ============================================================
toLineStyle(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

toSize(s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large :
     s == "huge"  ? size.huge  :
     size.normal

toLabelStyle(s) =>
    s == "Right arrow" ? label.style_label_right :
     s == "None"        ? label.style_none        :
     label.style_label_left

lblSize1    = toSize(lblSizeS1)
lblSize2    = toSize(lblSizeS2)
lblAnchor1  = toLabelStyle(lblAnchorS1)
lblAnchor2  = toLabelStyle(lblAnchorS2)
pLblSize1   = toSize(pLblSizeS1)
pLblSize2   = toSize(pLblSizeS2)
pLblAnchor1 = toLabelStyle(pLblAnchorS1)
pLblAnchor2 = toLabelStyle(pLblAnchorS2)

// ============================================================
//  LOGIC
// ============================================================
in1 = on1 and not na(time(timeframe.period, ses1, tz))
in2 = on2 and not na(time(timeframe.period, ses2, tz))

fixHit1 = on1 and showFix1 and hour(time, tz) == fixH1 and minute(time, tz) == fixM1 and (hour(time[1], tz) != fixH1 or minute(time[1], tz) != fixM1)
fixHit2 = on2 and showFix2 and hour(time, tz) == fixH2 and minute(time, tz) == fixM2 and (hour(time[1], tz) != fixH2 or minute(time[1], tz) != fixM2)

var box   b1     = na
var label l1     = na
var line  topLn1 = na
var line  botLn1 = na
var line  fxLn1  = na
var box   pb1    = na
var label pl1    = na
var line  pTopLn1 = na
var line  pBotLn1 = na
var line  pFxLn1  = na

var box   b2     = na
var label l2     = na
var line  topLn2 = na
var line  botLn2 = na
var line  fxLn2  = na
var box   pb2    = na
var label pl2    = na
var line  pTopLn2 = na
var line  pBotLn2 = na
var line  pFxLn2  = na

// ----- Slot 1 -----
if in1 and not in1[1]
    if not na(pb1)
        box.delete(pb1)
    if not na(pl1)
        label.delete(pl1)
    if not na(pTopLn1)
        line.delete(pTopLn1)
    if not na(pBotLn1)
        line.delete(pBotLn1)
    if not na(pFxLn1)
        line.delete(pFxLn1)

    pb1     := b1
    pl1     := l1
    pTopLn1 := topLn1
    pBotLn1 := botLn1
    pFxLn1  := fxLn1

    if not na(pb1)
        box.set_right(pb1, bar_index)
        box.set_bgcolor(pb1, color.new(pCol1, pFl1))
    if not na(pl1)
        label.set_xy(pl1, bar_index, box.get_top(pb1))
        label.set_text(pl1, pNm1)
        label.set_color(pl1, pLblBg1)
        label.set_textcolor(pl1, pLblTxt1)
        label.set_size(pl1, pLblSize1)
        label.set_style(pl1, pLblAnchor1)
    if not na(pTopLn1)
        line.set_x2(pTopLn1, bar_index)
        line.set_color(pTopLn1, pLnCol1)
        line.set_style(pTopLn1, toLineStyle(pLnSty1))
        line.set_width(pTopLn1, pLnW1)
    if not na(pBotLn1)
        line.set_x2(pBotLn1, bar_index)
        line.set_color(pBotLn1, pLnCol1)
        line.set_style(pBotLn1, toLineStyle(pLnSty1))
        line.set_width(pBotLn1, pLnW1)
    if not na(pFxLn1)
        line.set_x2(pFxLn1, bar_index)
        line.set_color(pFxLn1, pFixCol1)
        line.set_style(pFxLn1, toLineStyle(pFixSty1))
        line.set_width(pFxLn1, pFixLw1)

    if not na(pb1) and not showPrev1
        box.delete(pb1)
        pb1 := na
    if not na(pl1) and (not showPrev1 or not pShowLbl1)
        label.delete(pl1)
        pl1 := na
    if not na(pTopLn1) and not showPrev1
        line.delete(pTopLn1)
        pTopLn1 := na
    if not na(pBotLn1) and not showPrev1
        line.delete(pBotLn1)
        pBotLn1 := na
    if not na(pFxLn1) and (not showPrev1 or not pShowFix1)
        line.delete(pFxLn1)
        pFxLn1 := na

    b1 := box.new(bar_index, high, bar_index, low,
         border_color=transparent, bgcolor=color.new(col1, fl1))
    l1 := showLbl1 ? label.new(bar_index, high, nm1,
         style=lblAnchor1, color=lblBg1, textcolor=lblTxt1, size=lblSize1) : na
    topLn1 := line.new(bar_index, high, bar_index, high,
         xloc=xloc.bar_index, color=lnCol1, style=toLineStyle(lnSty1), width=lnW1)
    botLn1 := line.new(bar_index, low, bar_index, low,
         xloc=xloc.bar_index, color=lnCol1, style=toLineStyle(lnSty1), width=lnW1)
    fxLn1 := na

else if in1 and not na(b1)
    box.set_right(b1, bar_index)
    newTop1 = math.max(box.get_top(b1), high)
    newBot1 = math.min(box.get_bottom(b1), low)
    box.set_top(b1, newTop1)
    box.set_bottom(b1, newBot1)
    if not na(topLn1)
        line.set_x2(topLn1, bar_index)
        line.set_y1(topLn1, newTop1)
        line.set_y2(topLn1, newTop1)
    if not na(botLn1)
        line.set_x2(botLn1, bar_index)
        line.set_y1(botLn1, newBot1)
        line.set_y2(botLn1, newBot1)
    if not na(l1)
        label.set_xy(l1, bar_index, newTop1)

else if not na(b1)
    box.set_right(b1, bar_index)
    if not na(topLn1)
        line.set_x2(topLn1, bar_index)
    if not na(botLn1)
        line.set_x2(botLn1, bar_index)
    if not na(l1)
        label.set_xy(l1, bar_index, box.get_top(b1))

if fixHit1 and not na(b1)
    fxLn1 := line.new(bar_index, open, bar_index, open,
         xloc=xloc.bar_index, extend=extend.none,
         color=fixCol1, style=toLineStyle(fixSty1), width=fixLw1)
if not na(fxLn1)
    line.set_x2(fxLn1, bar_index)

// ----- Slot 2 -----
if in2 and not in2[1]
    if not na(pb2)
        box.delete(pb2)
    if not na(pl2)
        label.delete(pl2)
    if not na(pTopLn2)
        line.delete(pTopLn2)
    if not na(pBotLn2)
        line.delete(pBotLn2)
    if not na(pFxLn2)
        line.delete(pFxLn2)

    pb2     := b2
    pl2     := l2
    pTopLn2 := topLn2
    pBotLn2 := botLn2
    pFxLn2  := fxLn2

    if not na(pb2)
        box.set_right(pb2, bar_index)
        box.set_bgcolor(pb2, color.new(pCol2, pFl2))
    if not na(pl2)
        label.set_xy(pl2, bar_index, box.get_top(pb2))
        label.set_text(pl2, pNm2)
        label.set_color(pl2, pLblBg2)
        label.set_textcolor(pl2, pLblTxt2)
        label.set_size(pl2, pLblSize2)
        label.set_style(pl2, pLblAnchor2)
    if not na(pTopLn2)
        line.set_x2(pTopLn2, bar_index)
        line.set_color(pTopLn2, pLnCol2)
        line.set_style(pTopLn2, toLineStyle(pLnSty2))
        line.set_width(pTopLn2, pLnW2)
    if not na(pBotLn2)
        line.set_x2(pBotLn2, bar_index)
        line.set_color(pBotLn2, pLnCol2)
        line.set_style(pBotLn2, toLineStyle(pLnSty2))
        line.set_width(pBotLn2, pLnW2)
    if not na(pFxLn2)
        line.set_x2(pFxLn2, bar_index)
        line.set_color(pFxLn2, pFixCol2)
        line.set_style(pFxLn2, toLineStyle(pFixSty2))
        line.set_width(pFxLn2, pFixLw2)

    if not na(pb2) and not showPrev2
        box.delete(pb2)
        pb2 := na
    if not na(pl2) and (not showPrev2 or not pShowLbl2)
        label.delete(pl2)
        pl2 := na
    if not na(pTopLn2) and not showPrev2
        line.delete(pTopLn2)
        pTopLn2 := na
    if not na(pBotLn2) and not showPrev2
        line.delete(pBotLn2)
        pBotLn2 := na
    if not na(pFxLn2) and (not showPrev2 or not pShowFix2)
        line.delete(pFxLn2)
        pFxLn2 := na

    b2 := box.new(bar_index, high, bar_index, low,
         border_color=transparent, bgcolor=color.new(col2, fl2))
    l2 := showLbl2 ? label.new(bar_index, high, nm2,
         style=lblAnchor2, color=lblBg2, textcolor=lblTxt2, size=lblSize2) : na
    topLn2 := line.new(bar_index, high, bar_index, high,
         xloc=xloc.bar_index, color=lnCol2, style=toLineStyle(lnSty2), width=lnW2)
    botLn2 := line.new(bar_index, low, bar_index, low,
         xloc=xloc.bar_index, color=lnCol2, style=toLineStyle(lnSty2), width=lnW2)
    fxLn2 := na

else if in2 and not na(b2)
    box.set_right(b2, bar_index)
    newTop2 = math.max(box.get_top(b2), high)
    newBot2 = math.min(box.get_bottom(b2), low)
    box.set_top(b2, newTop2)
    box.set_bottom(b2, newBot2)
    if not na(topLn2)
        line.set_x2(topLn2, bar_index)
        line.set_y1(topLn2, newTop2)
        line.set_y2(topLn2, newTop2)
    if not na(botLn2)
        line.set_x2(botLn2, bar_index)
        line.set_y1(botLn2, newBot2)
        line.set_y2(botLn2, newBot2)
    if not na(l2)
        label.set_xy(l2, bar_index, newTop2)

else if not na(b2)
    box.set_right(b2, bar_index)
    if not na(topLn2)
        line.set_x2(topLn2, bar_index)
    if not na(botLn2)
        line.set_x2(botLn2, bar_index)
    if not na(l2)
        label.set_xy(l2, bar_index, box.get_top(b2))

if fixHit2 and not na(b2)
    fxLn2 := line.new(bar_index, open, bar_index, open,
         xloc=xloc.bar_index, extend=extend.none,
         color=fixCol2, style=toLineStyle(fixSty2), width=fixLw2)
if not na(fxLn2)
    line.set_x2(fxLn2, bar_index)
````
