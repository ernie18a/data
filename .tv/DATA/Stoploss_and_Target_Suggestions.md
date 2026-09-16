<!-- tradingview-pine-id: PUB;31e5c65a8a1640a6b34aaa50b5b16c77 -->
<!-- tradingview-pine-version: 5.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stoploss and Target Suggestions

Source: https://www.tradingview.com/script/QVLZ2UHM-Stoploss-and-Target-Suggestions/

## Description

This indicator puts a line at the Target level and the Stop Loss level set by the user. The lines change position real time as the current bar develops.

In the inputs you can set the number of percents or ATR's, choose if these must be calculated from close of from hl2. You can also set the color of this line.
To the right of the line is the suggested level.
To the left is a label which states how the calculation is done and between brackets what the gain or risk is.
gain and risk are always calculated from close as a percent.

Default settings are: both levels are shown, calculated as 1 ATR from hl2. 
Default color for Target is green and Stop Loss is red.

Use of the indicator.
You can use it in a trading system in which targets and stops are set as a percent or an amount of ATR's and be aware of risk and potential gain.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eykpunter

//@version=6
indicator("Stoploss and Target Suggestions","StopTarget",true, behind_chart = false)

Tsugwish = input.bool(true,"Show Target", group="target")
Tpwish = input.bool(true, "ATR or Percent", group="target")
tlp = input.float(5, "add percent", 0, 100, 0.5, group="target", display=display.none)
tla = input.float(1,"add atr", 0, step=0.5, group="target", display=display.none)
Tcwish=input.bool(true,"from HL2 or close", group="target")
Tcoltext = input.color(color.green, "Target text and line color",group="target")
Tcolback = input.color(color.new(color.white,10),"Target text background color", group="target")
Tcolhi= input.color(color.new(color.lime, 60), "Target value background when higher", group="target")
Tbase=Tcwish? hl2:close

Ssugwish = input.bool(true, "Show Stop Loss", group="stop loss")
Spwish=input.bool(true, "ATR or Percent", group="stop loss")
slp = input.float(5, "subtract percent", 0, 100, 0.5, group="stop loss", display=display.none)
sla = input.float(1, "subtract atr", 0, step=0.5, group="stop loss", display=display.none)
Scwish=input.bool(true, "from hl2 or close", group="stop loss")
Scoltext = input.color(color.red, "Stop Loss text and line color", group="stop loss")
Scolback = input.color(color.new(color.white, 10), "Stop Loss text backgound color", group="stop loss") //added in update
Scolhi = input.color(color.new(color.aqua, 60), "Stop Loss value background when higher", group="stop loss")
Sbase=Scwish? hl2:close
atrval= ta.atr(9)

//
//====================================================================================================================================
//target percent-of-close or close-plus-atr as horizontal line and label
Tpercent= Tbase*tlp/100
Tatr=tla*atrval     
tlc=Tpwish? Tbase+Tatr:Tbase+Tpercent
Thigher=tlc>tlc[1]
Tbackcol=(Thigher?Tcolhi:Tcolback)
lower=tlc<tlc[1]
TgainPerc=(tlc-close)/close*100
mask=TgainPerc<0.1?"#.##": "#.#"

var line targ = na
if not na(targ)
    line.delete(targ[1])
if Tsugwish
    targ:=line.new(bar_index-9,tlc,bar_index,tlc, color=Tcoltext)

var label tarlabel = na
labtxtT1=str.tostring(tlc, "#.##")
if not na(tarlabel)
    label.delete(tarlabel[1])
if barstate.islast and Tsugwish
    tarlabel:=label.new(bar_index+4,tlc,text=labtxtT1,
  color=Tbackcol,textcolor=Tcoltext,style=label.style_label_center,
  size=size.normal,textalign=text.align_left, text_formatting=text.format_bold)

var label tar2label = na
TgainText="(gain " +str.tostring(TgainPerc,mask)+" %)"
txtT2=Tcwish?"hl2 plus ":"close plus "
txtT3= str.tostring(Tpwish?tla:tlp, "#.#")
txtT4=Tpwish? " atr ": "% "
labtxtT2=txtT2+txtT3+txtT4+TgainText
if not na(tar2label)
    label.delete(tar2label[1])
if barstate.islast and Tsugwish
    tar2label:=label.new(bar_index-15,tlc,text=labtxtT2,
  color=Tcolback,textcolor=Tcoltext,style=label.style_label_center,
  size=size.small,textalign=text.align_left)


//==============================================================================================================================================
//stop percent-of-close or close-minus-atr as horizontal line and label
Spercent=Sbase*slp/100 
Satr= sla*atrval
slc=Spwish?Sbase-Satr:Sbase-Spercent
Shigher=slc>slc[1]
Sbackcol=(Shigher?Scolhi:Scolback)
SriskPerc=(close-slc)/close*100
mask:=SriskPerc<0.1? "#.##": "#.#"

var line stp = na
if not na(stp)
    line.delete(stp[1])
if Ssugwish 
    stp:=line.new(bar_index-9,slc,bar_index,slc, color=Scoltext)

var label stplabel = na
labtxts=str.tostring(slc, "#.##")
if not na(stplabel)
    label.delete(stplabel[1])
if barstate.islast and Ssugwish
    stplabel:=label.new(bar_index+4,slc,text=labtxts,
  color=Sbackcol,textcolor=Scoltext,style=label.style_label_center,
  size=size.normal,textalign=text.align_left, text_formatting=text.format_bold)

var label stp2label = na
txtS2=Scwish?"hl2 minus ":"close minus "
txtS3= str.tostring(Spwish?sla:slp, "#.#")
txtS4=Spwish? " atr ":" % "
SriskText="(risk " +str.tostring(SriskPerc,mask)+" %)"
labtxtS2=txtS2+txtS3+txtS4+SriskText

if not na(stp2label)
    label.delete(stp2label[1])
if barstate.islast and Ssugwish
    stp2label:=label.new(bar_index-15,slc,text=labtxtS2,
  color=Scolback,textcolor=Scoltext,style=label.style_label_center,
  size=size.small,textalign=text.align_left, text_formatting=text.format_none)
````
