<!-- tradingview-pine-id: PUB;0K4qMVkwotqi64DIDJoVgdgUbLo1KwXI -->
<!-- tradingviewscripts-format: 1 -->
# [PX] External Level

Source: https://www.tradingview.com/script/a35KI2pb-PX-External-Level/

## Description

Hello everyone,

today I'd like to share a script, which enables you to use external logic to plot levels on your chart. 

How does it work?

The concept is based on two scripts. One script, which uses an external input as a trigger to print a new level and one script that calculates an output, which will be fetched.

Sounds complicated? It really is not! Let's take a closer look.

[pine]// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © paaax

//@version=4
study("RSI OS/OB")
l = input(14, "RSI Length")
ob = input(70, "Overbought")
os = input(30, "Oversold")

r = rsi(close, l)

hline(ob)
hline(os)
plot(r, "RSI", color=color.orange)

// The following plot produces an output, which will be fetched the "External Level"-script.
// It evaluates to one of the following three values: 1.0, -1.0 or 0.0
plot(crossover(r, ob) ? 1.0 : crossunder(r, os) ? -1.0 : 0.0, "Output", transp=100)[/pine]

The example script above uses an RSI and two threshold levels (70 and 30). The logic here is, that whenever the RSI is crossing down the lower threshold or crossing up the upper threshold we'd consider the current movement to be either oversold or overbought. Therefore, it's a point of interest, which we could visualize with a level.
The script creates an output when the crossover or crossunder of a threshold happens. A crossover would result in a value of 1.0, a crossunder in a value of -1.0. In all other cases the value would be 0.0.

The output of the RSI script would then be used as an input of the External Level script, which has a "Source"-parameter in its input-section. If the fetched input shows 1.0, then the script prints a resistance level. If it shows -1.0 a support level will be printed. And that's basically it. A very simple approach to print levels on your chart with an infinite number of use cases.
For example, you could use fetch outputs from a MACD script, MA script, outputs based on volume or price movement. Just remember the output has to evaluate to either 1.0 or -1.0 and has to be selected in the input-section.

Hope that might be useful to some of you :)

Please click the "Like"-button and follow me for future open-source script publications.

If you are looking for help with your custom PineScript development, don't hesitate to contact me directly here on Tradingview or through the link in my signature :)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=4

// ------------------------------------------------------------
// ---------------- Author: Pascal Simon (paaax) --------------
// ------------------------------------------------------------
// ---------------- www.tradingview.com/u/paaax/---------------
// ------------------------------------------------------------

study("[PX] External Level", overlay=true)
// INPUT    {
i_rColor = input("black", title="Resistance Level Color", options=["aqua","black","blue","fuchsia","gray","green","lime","maroon","navy","olive","orange","purple","red","silver","teal","white","yellow"])
i_rStyle = input("solid", title="Resistance Level Style", options=['solid','dotted','dashed'])
i_rWidth = input(2, title="Resistance Level Width")

i_sColor = input("red", title="Support Level Color", options=["aqua","black","blue","fuchsia","gray","green","lime","maroon","navy","olive","orange","purple","red","silver","teal","white","yellow"])
i_sStyle = input("solid", title="Support Level Style", options=['solid','dotted','dashed'])
i_sWidth = input(2, title="Support Level Width")

i_extend = input("right", title="Extend", options=["none", "left", "right", "both"])
i_src = input(title="Source", type=input.source, defval=close)   
//} INPUT
// FUNCTION {

//{
f_set_color(_selection)=>
    ret = color.black
    if _selection == "gray"
        ret := color.gray
    if _selection == "green"
        ret := color.green
    if _selection == "aqua"
        ret := color.aqua
    if _selection == "blue"
        ret := color.blue
    if _selection == "fuchsia"
        ret := color.fuchsia
    if _selection == "lime"
        ret := color.lime
    if _selection == "maroon"
        ret := color.maroon
    if _selection == "navy"
        ret := color.navy
    if _selection == "white"
        ret := color.white
    if _selection == "yellow"
        ret := color.yellow
    if _selection == "olive"
        ret := color.olive
    if _selection == "orange"
        ret := color.orange
    if _selection == "purple"
        ret := color.purple
    if _selection == "red"
        ret := color.red
    if _selection == "silver"
        ret := color.silver
    if _selection == "teal"
        ret := color.teal
    ret
//} --- f_set_color()
//{
f_set_style(_selection)=>
    ret = line.style_solid
    if _selection == "dotted"
        ret := line.style_dotted 
    if _selection == "dashed"
        ret := line.style_dashed
    ret
//} --- f_set_style()
//{
f_set_extend(_selection)=>
    ret = extend.none
    if _selection == "left"
        ret := extend.left 
    if _selection == "right"
        ret := extend.right
    if _selection == "both"
        ret := extend.both
    ret    
//} --- f_set_extend()
//} FUNCTION
// INIT{
var r01 = line(na), var r02 = line(na), var r03 = line(na), var r04 = line(na), var r05 = line(na)
var r06 = line(na), var r07 = line(na), var r08 = line(na), var r09 = line(na), var r10 = line(na)
var s01 = line(na), var s02 = line(na), var s03 = line(na), var s04 = line(na), var s05 = line(na)
var s06 = line(na), var s07 = line(na), var s08 = line(na), var s09 = line(na), var s10 = line(na)
//} INIT
// LOGIC    {
if i_src[1] == 1.0

    // delete oldest level
    line.delete(r10)

    // move old levels
    r10 := r09
    r09 := r08
    r08 := r07
    r07 := r06
    r06 := r05
    r05 := r04
    r04 := r03
    r03 := r02
    r02 := r01

    // print new level
    r01 := line.new(
         x1     = bar_index[1], 
         y1     = high[1], 
         x2     = bar_index, 
         y2     = high[1], 
         color  = f_set_color(i_rColor), 
         extend = f_set_extend(i_extend), 
         width  = i_rWidth, 
         style  = f_set_style(i_rStyle))
         
else if i_src[1] == -1.0

    // delete oldest level
    line.delete(s10)

    // move old levels
    s10 := s09
    s09 := s08
    s08 := s07
    s07 := s06
    s06 := s05
    s05 := s04
    s04 := s03
    s03 := s02
    s02 := s01
    
    // print new level
    s01 := line.new(
         x1     = bar_index[1], 
         y1     = low[1], 
         x2     = bar_index, 
         y2     = low[1], 
         color  = f_set_color(i_sColor), 
         extend = f_set_extend(i_extend), 
         width  = i_sWidth, 
         style  = f_set_style(i_sStyle))

//} LOGIC
````
