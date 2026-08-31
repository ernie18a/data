<!-- tradingview-pine-id: PUB;1048fa103aab46908257f0623175e381 -->
<!-- tradingviewscripts-format: 1 -->
# Fair Value Gap

Source: https://www.tradingview.com/script/erbzoVY8-Fair-Value-Gap/

## Description

█ OVERVIEW

This indicator displays the Fair Value Gap of the current timeframe and an additional higher timeframe. For each FVG the gaps act as targets creating bullish and bearish gaps that are often filled.

█ FEATURES

[*] MTF Options
[*] MidPoint FIll
[*] Delete Old On Fill
[*] Label FVG Timeframe

MTF Options
Enabling the MTF Options will allow the user to use the "MTF Timeframe" setting to choose what HTF Fair Value Gap to display

MidPoint FIll
A line plot at the Half way point will be included in the Fair Value Gap, this will be used to delete the gap when reached instead of a full fill.

Delete Old On Fill
Deletes historical Fair Value Gaps when filled.
Label FVG Timeframe
Labels Every Fair Value gap with there relevant timeframe to make it easier to determine which gap is being filled.

█ HOW TO USE IT

The indicator is quite straight forward in its application, providing users with targets that are often filled as they are seen as market imbalance. 
Just applying it to your chart will provide the existing Fair Value Gaps. MTF Confluence is helpful in seeing what is happening on the macro perspective.

█ SUGGESTION

My suggestion for clarity is to use a different color to some degree between the MTF and Current TF as Opposed to text, keeps the chart clear.

█ LIMITATIONS OF PINE (Please read)

I see many users going on different indicators with MTF in mind and trying to use it for LTF data e.g. 1hour chart, and selecting 5min in chart settings.
This is not recommended by the team themselves and should be noted for use always use HTF: [https://www.tradingview.com/pine-script-docs/en/v4/essential/Context_switching_the_security_function.html](https://www.tradingview.com/pine-script-docs/en/v4/essential/Context_switching_the_security_function.html)   

To understand how to use fair value gaps I recommend learning about the subject some more, searching online will provide you resources. The internet is your friend when learning. All the best.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © spacemanbtc

//@version=5
indicator("Fair Value Gap",shorttitle= "Fair Value Gap SpaceManBTC", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)



//Fair Value Gap
//V1, 2022.4.12

//This indicator displays the fair value gap of the current timeframe AND an optional higher time frame.

//What the script does is take into account the values of the current bar high/low and compare with 2 bars previous
//The "gap" is generated from the lack of overlap between these bars
//Bearish or Bullish gaps determined via whether the gap is above or below price, as they tend to be filled gaps can be used as targets.


// ———————————————————— Inputs {

// Standard practice declared input variables with i_ easier to identify
i_tf = input.timeframe("D", "MTF Timeframe", group = "MTF Settings")
i_mtf = input.string(defval = "Current TF",group = "MTF Settings", title = "MTF Options", options = ["Current TF", "Current + HTF", "HTF"])
i_tfos = input.int(defval = 10,title = "Offset", minval = 0, maxval = 500 ,group = "MTF Settings", inline = "OS")
i_mtfos = input.int(defval = 20,title = "MTF Offset", minval = 0, maxval = 500 ,group = "MTF Settings", inline = "OS")
i_fillByMid = input.bool(false, "MidPoint Fill",group = "General Settings", tooltip = "When enabled FVG is filled when midpoint is tested")
i_deleteonfill = input.bool(true, "Delete Old On Fill",group = "General Settings")
i_labeltf = input.bool(true,"Label FVG Timeframe",group = "General Settings")


i_bullishfvgcolor = input.color(color.new(color.green,90), "Bullish FVG", group = "Coloring", inline = "BLFVG")
i_mtfbullishfvgcolor = input.color(color.new(color.lime,80), "MTF Bullish FVG", group = "Coloring", inline = "BLFVG")
i_bearishfvgcolor = input.color(color.new(color.red,90), "Bearish FVG", group = "Coloring", inline = "BRFVG")
i_mtfbearishfvgcolor = input.color(color.new(color.maroon,80), "MTF Bearish FVG", group = "Coloring", inline = "BRFVG")
i_midPointColor = input.color(color.new(color.white,85), "MidPoint Color", group = "Coloring")
i_textColor = input.color(color.white, "Text Color", group = "Coloring")

// }

// ———————————————————— Global data {
//Using current bar data for HTF highs and lows instead of security to prevent future leaking
var htfH = open
var htfL = open

if close > htfH 
    htfH:= close
if close < htfL
    htfL := close


//Security Data, used for HTF Bar Data reference


sClose = request.security(syminfo.tickerid, i_tf, close[1], barmerge.gaps_off, barmerge.lookahead_on)
sHighP2 = request.security(syminfo.tickerid, i_tf, high[2], barmerge.gaps_off, barmerge.lookahead_on)
sLowP2 = request.security(syminfo.tickerid, i_tf, low[2], barmerge.gaps_off, barmerge.lookahead_on)
sOpen = request.security(syminfo.tickerid, i_tf, open[1], barmerge.gaps_off, barmerge.lookahead_on)
sBar = request.security(syminfo.tickerid, i_tf, bar_index, barmerge.gaps_off, barmerge.lookahead_on)


// }




//var keyword can be used to hold data in memory, with pinescript all data is lost including variables unless the var keyword is used to preserve this data
var bullishgapholder = array.new_box(0)
var bearishgapholder = array.new_box(0)
var bullishmidholder = array.new_line(0)
var bearishmidholder = array.new_line(0)
var bullishlabelholder = array.new_label(0)
var bearishlabelholder = array.new_label(0)
var transparentcolor = color.new(color.white,100)



// ———————————————————— Functions {

//function paramaters best declared with '_' this helps defer from variables in the function scope declaration and elsewhere e.g. close => _close
f_gapCreation(_upperlimit,_lowerlimit,_midlimit,_bar,_boxholder,_midholder,_labelholder,_boxcolor,_mtfboxcolor, _htf)=>
    timeholder = str.tostring(i_tf)
    offset = i_mtfos
    boxbgcolor = _mtfboxcolor
    if _htf == false
        timeholder := str.tostring(timeframe.period)
        offset := i_tfos
        boxbgcolor := _boxcolor
    array.push(_boxholder,box.new(_bar,_upperlimit,_bar+1,_lowerlimit,border_color=transparentcolor,bgcolor = boxbgcolor, extend = extend.right))
    if i_fillByMid 
        array.push(_midholder,line.new(_bar,_midlimit,_bar+1,_midlimit,color = i_midPointColor, extend = extend.right))
    if i_labeltf
  
        
   
        array.push(_labelholder,label.new(_bar+ offset,_midlimit * 0.999, text = timeholder + " FVG", style =label.style_none, size = size.normal, textcolor = i_textColor))
        
//checks for gap between current candle and 2 previous candle e.g. low of current candle and high of the candle before last, this is the fair value gap.
f_gapLogic(_close,_high,_highp2,_low,_lowp2,_open,_bar,_htf)=>
    
    if _open > _close

        if _high - _lowp2 < 0
            
            upperlimit = _close - (_close - _lowp2 )
            lowerlimit = _close - (_close-_high)
            midlimit = (upperlimit + lowerlimit) / 2
            f_gapCreation(upperlimit,lowerlimit,midlimit,_bar,bullishgapholder,bullishmidholder,bullishlabelholder,i_bullishfvgcolor,i_mtfbullishfvgcolor,_htf)
          
    else
        
        if _low - _highp2 > 0 
            upperlimit = _close - (_close-_low)
            lowerlimit = _close- (_close - _highp2),
            midlimit = (upperlimit + lowerlimit) / 2
            f_gapCreation(upperlimit,lowerlimit,midlimit,_bar,bearishgapholder,bearishmidholder,bearishlabelholder,i_bearishfvgcolor,i_mtfbearishfvgcolor,_htf)
        


//Used to remove the gap from its relevant array as a result of it being filled.
f_gapDeletion(_currentgap,_i,_boxholder,_midholder,_labelholder)=>
   
    array.remove(_boxholder,_i)
    if i_fillByMid
        currentmid=array.get(_midholder,_i)
        array.remove(_midholder,_i)
       
        if i_deleteonfill
            line.delete(currentmid)
        else
            line.set_extend(currentmid, extend.none)
            line.set_x2(currentmid,bar_index)
    if i_deleteonfill
        box.delete(_currentgap)
        
        
    else
        box.set_extend(_currentgap,extend.none)
        box.set_right(_currentgap,bar_index)
    if i_labeltf
        currentlabel=array.get(_labelholder,_i)
        array.remove(_labelholder,_i)
        if i_deleteonfill
            label.delete(currentlabel)


//checks if gap has been filled either by 0.5 fill (i_fillByMid) or SHRINKS the gap to reflect the true value gap left.
f_gapCheck(_high,_low)=>

    if array.size(bullishgapholder) > 0

        for i = array.size(bullishgapholder)-1 to 0
            currentgap = array.get(bullishgapholder,i)
            currenttop = box.get_top(currentgap)
            if i_fillByMid 
                currentmid = array.get(bullishmidholder,i)
                currenttop := line.get_y1(currentmid)
            
                
            if _high >= currenttop
                f_gapDeletion(currentgap,i,bullishgapholder,bullishmidholder,bullishlabelholder)
            if _high > box.get_bottom(currentgap) and _high < box.get_top(currentgap)
               
                box.set_bottom(currentgap,_high)
       
    if array.size(bearishgapholder) > 0

        for i = array.size(bearishgapholder)-1 to 0
            currentgap = array.get(bearishgapholder,i)
            currentbottom = box.get_bottom(currentgap)
            if i_fillByMid 
                currentmid = array.get(bearishmidholder,i)
                currentbottom := line.get_y1(currentmid)           
            if _low <= currentbottom
                f_gapDeletion(currentgap,i,bearishgapholder,bearishmidholder,bearishlabelholder)
       
            if _low < box.get_top(currentgap) and _low > box.get_bottom(currentgap)
       
                box.set_top(currentgap,_low)      
                
                
// pine provided function to determine a new bar
is_newbar(res) =>
    t = time(res)
    not na(t) and (na(t[1]) or t > t[1])

if is_newbar(i_tf)
    htfH := open
    htfL := open

// }



// User Input, allow MTF data calculations
if is_newbar(i_tf) and (i_mtf == "Current + HTF" or i_mtf == "HTF")
    f_gapLogic(sClose,htfH,sHighP2,htfL,sLowP2,sOpen,bar_index,true)
    
// Use current Timeframe data to provide gap logic
if (i_mtf == "Current + HTF" or i_mtf == "Current TF")
    f_gapLogic(close[1],high,high[2],low,low[2],open[1],bar_index,false)

f_gapCheck(high,low)
````
