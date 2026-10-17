# OPEN/CLOSE RANGES (Cartoon_Futures)

- url: https://www.tradingview.com/script/u7axwJZS-OPEN-CLOSE-RANGES-Cartoon-Futures/
- type: indicator
- pine_id: PUB;6f235e9991824707947bd672ec7bea4a
- version: 1.0

## Description

OPEN Range indicator
NY Close indicator
London OPEN indicator
Session OPEN indicator
Midnight indicator

keeps historical track of old time markers

time markers are the lower volume ones like session, london, and midnight markeers, The Ny open and NY close markers are also high volume areas

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©Cartoon_Futures

//@version=5
indicator(title="OPEN/CLOSE RANGES (Cartoon_Futures)", overlay=true,max_labels_count = 500, max_boxes_count = 500,max_lines_count = 500)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Inputs
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var g_settings      = "Main Settings"
sessionZone         = input.string('UTC-5', "Timezone", options = ['UTC-10','UTC-9','UTC-8','UTC-7','UTC-6','UTC-5','UTC-4','UTC-3','UTC-2','UTC-1','UTC+0','UTC+1','UTC+2','UTC+3','UTC+4','UTC+5','UTC+6','UTC+7','UTC+8','UTC+9','UTC+10','UTC+11','UTC+12','UTC+13'], tooltip = "Note UTC is not adjusted to reflect Daylight Saving Time changes", group = g_settings)
lbsize              = input.int(30, "Number of session", tooltip="how many sessions do you want to look back and draw", group = g_settings)
box_ext             = input.int(1,"Range Extension (sessions)",tooltip="how many seessions in the future you want lines to extend", group = g_settings)

//Labeling setting
var label_style = label.style_label_right
var label_x_offset = -1 // Horizontal offset for label position
var label_y_offset = 0 // Vertical offset for label position

var g_mainranges    =   "Main Ranges"
use_nyo             = input.bool(true, "", inline = "NYO", group = g_mainranges)
nyo_range           = input.bool(true, "range", inline = "NYO",  group = g_mainranges)
nyo_text            = input.string("NY OPEN", "", inline = "NYO", group = g_mainranges)
nyotime             = input.session("0930-0935", "", inline = "NYO", group = g_mainranges)
nyo_color           = input.color(color.green, "", inline = "NYO", group = g_mainranges)

use_halfgap         =   input.bool(true, "HALF GAP PIVOT", inline="halfgap", group= g_mainranges)
halfgap_color       =   input.color(color.rgb(33, 243, 198), "", inline="halfgap", group= g_mainranges)


use_nyc              = input.bool(true, "", inline = "NYO", group = g_mainranges)
nyc_range            = input.bool(true, "range", inline = "NYO", group = g_mainranges)
nyc_text             = input.string("NY CLOSE", "", inline = "NYO", group = g_mainranges)
nyctime              = input.session("1555-1600", "", inline = "NYO", group = g_mainranges)
nyc_color            = input.color(color.red, "", inline = "NYO", group =g_mainranges)

var g_opens         = "Open Ranges"

use_london           = input.bool(true, "", inline = "london", group = g_opens)
london_range         = input.bool(true, "range", inline = "london", group = g_opens)
london_text          = input.string("LONDON", "", inline = "london", group = g_opens)
londontime           = input.session("0300-0305", "", inline = "london", group = g_opens)
london_color         = input.color(color.yellow, "", inline = "london", group = g_opens)


use_noon             = input.bool(true, "", inline = "noon", group = g_opens)
noon_range           = input.bool(true, "range", inline = "noon", group = g_opens)
noon_text            = input.string("NOON", "", inline = "noon", group = g_opens)
noontime             = input.session("1200-1205", "", inline = "noon", group = g_opens)
noon_color           = input.color(color.rgb(22, 190, 241), "", inline = "noon", group = g_opens)

use_midnight         = input.bool(true, "", inline = "midnight", group = g_opens)
midnight_range       = input.bool(false, "range", inline = "midnight", group = g_opens)
midnight_text        = input.string("MIDNIGHT", "", inline = "midnight", group = g_opens)
midnighttime         = input.session("0000-0005", "", inline = "midnight", group = g_opens)
midnight_color       = input.color(color.purple, "", inline = "midnight", group = g_opens) 

use_open1            = input.bool(false, "", inline = "open1", group = g_opens)
open1_range          = input.bool(false, "range", inline = "open1", group = g_opens)
open1_text           = input.string("SESSION OPEN", "", inline = "open1", group = g_opens)
open1time            = input.session("1800-1805", "", inline = "open1", group = g_opens)
open1_color          = input.color(color.black, "", inline = "open1", group = g_opens)


use_open2            = input.bool(false, "", inline = "open2", group = g_opens)
open2_range          = input.bool(false, "range", inline = "open2", group = g_opens)
open2_text           = input.string("OTHER", "", inline = "open2", group = g_opens)
open2time            = input.session("1200-1205", "", inline = "open2", group = g_opens)
open2_color          = input.color(color.rgb(22, 179, 241), "", inline = "open2", group = g_opens)


var g_closes         = "Close Ranges"


use_tas1             = input.bool(false, "", inline = "tas1", group = g_closes)
tas1_range           = input.bool(false, "range", inline = "tas1", group = g_closes)
tas1_text            = input.string("NY CL TAS", "", inline = "tas1", group = g_closes)
tas1time             = input.session("1425-1430", "", inline = "tas1", group = g_closes)
tas1_color           = input.color(color.red, "", inline = "tas1", group = g_closes)

use_tas2             = input.bool(false, "", inline = "tas2", group = g_closes)
tas2_range           = input.bool(false, "range", inline = "tas2", group = g_closes)
tas2_text            = input.string("CL ASIA TAM", "", inline = "tas2", group = g_closes)
tas2time             = input.session("0325-0330", "", inline = "tas2", group = g_closes)
tas2_color           = input.color(color.rgb(22, 179, 241), "", inline = "tas2", group = g_closes)

use_tas3             = input.bool(false, "", inline = "tas3", group = g_closes)
tas3_range           = input.bool(false, "range", inline = "tas3", group = g_closes)
tas3_text            = input.string("CL London TAM", "", inline = "tas3", group = g_closes)
tas3time             = input.session("1125-1130", "", inline = "tas3", group = g_closes)
tas3_color           = input.color(color.yellow, "", inline = "tas3", group = g_closes)

use_tas4             = input.bool(true, "", inline = "tas4", group = g_closes)
tas4_range           = input.bool(false, "range", inline = "tas4", group = g_closes)
tas4_text            = input.string("SESSION CLOSE", "", inline = "tas4", group = g_closes)
tas4time             = input.session("1655-1700", "", inline = "tas4", group = g_closes)
tas4_color           = input.color(color.black, "", inline = "tas4", group = g_closes)

var g_outsidebar    =   "Outsidebar settings"
use_outsidebar      =   input.bool(true,"Outside bar ON?",inline="outside", group= g_outsidebar)
outsidebar_upcolor  =   input.color(color.blue, "UP COLOR",inline="outside", group= g_outsidebar)
outsidebar_dncolor  =   input.color(color.yellow, "DOWN COLOR",inline="outside", group= g_outsidebar)


var g_other          = "Other Settings"
lb_color             = input.color(color.black, "Label Text Color", inline = "lbl" ,group = g_other)
lb_size             = input.string('Small', "Label Size", options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = g_other)
box_transparency     = input.int(70, "Box Transparency", 0, 100, inline = "bx", group = g_other)
boxBorderSize        = input.int(1, title="Box border size", minval=0, inline = "bx", group = g_other)
linethickness        = input.int(2,"Line Thickness",minval=1, group = g_other)



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//variables
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var nyo_line = array.new_line()
var nyo_box = array.new_box()
var nyo_lbl = array.new_label()
nyoISopen = not na(time("", nyotime, sessionZone)) and timeframe.isintraday


var london_line = array.new_line()
var london_box = array.new_box()
var london_lbl = array.new_label()
londonISopen = not na(time("", londontime, sessionZone)) and timeframe.isintraday


var noon_line = array.new_line()
var noon_box = array.new_box()
var noon_lbl = array.new_label()
noonISopen = not na(time("", noontime, sessionZone)) and timeframe.isintraday

var midnight_line = array.new_line()
var midnight_box = array.new_box()
var midnight_lbl = array.new_label()
midnightISopen = not na(time("", midnighttime, sessionZone)) and timeframe.isintraday

var open1_line = array.new_line()
var open1_box = array.new_box()
var open1_lbl = array.new_label()
open1ISopen = not na(time("", open1time, sessionZone)) and timeframe.isintraday

var open2_line = array.new_line()
var open2_box = array.new_box()
var open2_lbl = array.new_label()
open2ISopen = not na(time("", open2time, sessionZone)) and timeframe.isintraday

var nyc_line = array.new_line()
var nyc_box = array.new_box()
var nyc_lbl = array.new_label()
nycISopen = not na(time("", nyctime, sessionZone)) and timeframe.isintraday

var tas1_line = array.new_line()
var tas1_box = array.new_box()
var tas1_lbl = array.new_label()
tas1ISopen = not na(time("", tas1time, sessionZone)) and timeframe.isintraday

var tas2_line = array.new_line()
var tas2_box = array.new_box()
var tas2_lbl = array.new_label()
tas2ISopen = not na(time("", tas2time, sessionZone)) and timeframe.isintraday

var tas3_line = array.new_line()
var tas3_box = array.new_box()
var tas3_lbl = array.new_label()
tas3ISopen = not na(time("", tas3time, sessionZone)) and timeframe.isintraday

var tas4_line = array.new_line()
var tas4_box = array.new_box()
var tas4_lbl = array.new_label()
tas4ISopen = not na(time("", tas4time, sessionZone)) and timeframe.isintraday

var halfgap_line = array.new_line()
var halfgap_lbl = array.new_label()
var halgap = float(1)
var lastopen = float(1)
var lastclose =float(1)

var monthtext = string("5")
var monthday = string("12")


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Functions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

check_array(_arr) =>  //function checks the size of the array matches the number of sessions inputed to draw, if so, it deletes the oldest array
    if _arr.size() > lbsize
        _arr.pop().delete()

lineEXToff(_line) =>  //function sets far right postion of the line and turns off the extended line feature
    _line.set_x2(bar_index)
    line.set_extend(_line,extend.none)

boxEXToff (_box) => //function sets far right postion of the box and turns off the extended line feature
    _box.set_right(bar_index)
    box.set_extend(_box, extend.none)

adjustbox2(_box) =>   //function checks to to make sure the box high or low is set after each candle of session, adjusts the right, top and bottom fo the box
    _box.set_right(bar_index)
    _box.set_top(math.max(_box.get_top(),high))
    _box.set_bottom(math.min(_box.get_bottom(),low))

adjustclose(_line,_lbl)=>  //function adjust the close line as after each session in the range
    line.set_xy2(_line,bar_index,close)
    line.set_y1(_line,close)
    label.set_y(_lbl,close + label_y_offset)

get_box_color(_color, _transparency) => //function adjust the Transparency of the box for each range box
    result = color.new(_color, _transparency)

get_label_size(_size) =>
    result = switch _size
        'Tiny' => size.tiny
        'Small' => size.small
        'Normal' => size.normal
        'Large' => size.large
        'Huge' => size.huge
        'Auto' => size.auto
    result

lb_size := get_label_size(lb_size)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Set box colors (has to be below the function to set)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
var color nyo_box_color = get_box_color(nyo_color,box_transparency)
var color london_box_color= get_box_color(london_color,box_transparency)
var color noon_box_color= get_box_color(noon_color,box_transparency)
var color nyc_box_color = get_box_color(nyc_color, box_transparency)
var color midnight_box_color = get_box_color(midnight_color, box_transparency)
var color open1_box_color = get_box_color(open1_color, box_transparency)
var color open2_box_color = get_box_color(open2_color, box_transparency)
var color tas1_box_color = get_box_color(tas1_color, box_transparency)
var color tas2_box_color = get_box_color(tas2_color, box_transparency)
var color tas3_box_color = get_box_color(tas3_color, box_transparency)
var color tas4_box_color = get_box_color(tas4_color, box_transparency)
//var color outsidebarcolor = na

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main logic OUTSIDE BAR
////////////////////////////////////////////////////////////////////////////////////////////////////////

outsidebarcolor = if high > high[1] and low < low[1] and close > close[1] and use_outsidebar
    outsidebar_upcolor
else if high > high[1] and low < low[1] and close < close[1] and use_outsidebar
    outsidebar_dncolor
else
    na
barcolor(color = outsidebarcolor)




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main logic OPEN RANGES
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// NYO session started, this is the very first candle
if use_nyo
    if nyoISopen and not nyoISopen[1]   //checks to see if this is the first candle of the session, if so executes the below code
        nyo_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=nyo_color, width = linethickness))  //draws a new line
        nyo_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, nyo_text, style=label_style, color=nyo_color, textcolor=lb_color, size = lb_size))
        lastopen := open





        if nyo_range //check to see if the range was selected on the inputs to draw a box around opening range
            nyo_box.unshift(box.new(bar_index,high,bar_index + 1, low, nyo_color, boxBorderSize, line.style_solid, extend.right, bgcolor = nyo_box_color))  //add a new box to the nyo box array it is the index 0 of the array
            
        if nyo_line.size() > box_ext  //checks to see if the array number is greater than inputed extension session to draw lines in the future, if so it calls a function to set the righ side of the line and turn off extensions
            lineEXToff(nyo_line.get(box_ext)) //calls function to end extension of line, 
           // lineEXToff(halfgap_line.get(box_ext))
           // label.new(bar_index + label_x_offset, high + label_y_offset, nyo_text, style=label_style, color=nyo_color, textcolor=lb_color, size=lb_size)
        if nyo_box.size( ) > box_ext  
            boxEXToff(nyo_box.get(box_ext))
    else if nyoISopen // executes this code for every candle in the session except the first candle.
        if nyo_range  //checks to see if the you are using the range, if so calls function to adjust the top, bottom and right of the box
            adjustbox2(nyo_box.get(0))

if use_nyc and use_halfgap and use_nyo
    if nyoISopen and not nyoISopen[1]           //halfgap is drawn sametime nyopen is drawn
        if lastopen > lastclose
            halfgap = (lastclose + ((lastopen-lastclose) / 2))
            halfgap_line.unshift(line.new(bar_index,halfgap,bar_index + 10, halfgap, extend=extend.right, color=halfgap_color, width = linethickness))  //draws a new line
            halfgap_lbl.unshift(label.new(bar_index + label_x_offset, halfgap + label_y_offset, "HalfGAP" , style=label_style, color=halfgap_color, textcolor=lb_color, size = lb_size))
        else
            halfgap = (lastopen + ((lastclose-lastopen) / 2))
            halfgap_line.unshift(line.new(bar_index,halfgap,bar_index + 10, halfgap, extend=extend.right, color=halfgap_color, width = linethickness))  //draws a new line
            halfgap_lbl.unshift(label.new(bar_index + label_x_offset, halfgap + label_y_offset, "HalfGAP" , style=label_style, color=halfgap_color, textcolor=lb_color, size = lb_size))
            
        if halfgap_line.size() > box_ext  //checks to see if the array number is greater than inputed extension session to draw lines in the future, if so it calls a function to set the righ side of the line and turn off extensions
            lineEXToff(halfgap_line.get(box_ext))


//if use_halfgap and use_nyc
   // if nyoISopen and not nyoISopen[1]
    //if line.get_x1(nyc_line, 0)
    //  if nyo_box.get_top(0)> nyc_box.get_bottom(0)
        
    //    halfgap_line.eunshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=nyo_color, width = linethickness))



check_array(nyo_line) // calls function to check if array is larger than the inputed lookback session, if so it will remove the oldest object of the array.
check_array(nyo_box)
check_array(nyo_lbl)
check_array(halfgap_line)
check_array(halfgap_lbl)

if use_london
    if londonISopen and not londonISopen[1]   //checks to see if this is the first candle of the session, if so executes the below code
        london_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=london_color, width = linethickness))  //draws a new line
        london_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, london_text, style=label_style, color=london_color, textcolor=lb_color, size = lb_size))
        if london_range //check to see if the range was selected on the inputs to draw a box around opening range
            london_box.unshift(box.new(bar_index,high,bar_index + 1, low, london_color, boxBorderSize, line.style_solid, extend.right, bgcolor = london_box_color))  //add a new box to the london box array it is the index 0 of the array
            
        if london_line.size() > box_ext  //checks to see if the array number is greater than inputed extension session to draw lines in the future, if so it calls a function to set the righ side of the line and turn off extensions
            lineEXToff(london_line.get(box_ext)) //calls function to end extension of line, 
           // label.new(bar_index + label_x_offset, high + label_y_offset, london_text, style=label_style, color=london_color, textcolor=lb_color, size=lb_size)
        if london_box.size( ) > box_ext  
            boxEXToff(london_box.get(box_ext))
    else if londonISopen // executes this code for every candle in the session except the first candle.
        if london_range  //checks to see if the you are using the range, if so calls function to adjust the top, bottom and right of the box
            adjustbox2(london_box.get(0))
// london session started, this is the very first candle
//if use_london
   // if londonISopen and not londonISopen[1]
     //   london_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=london_color, width = linethickness))
       // london_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, london_text, style=label_style, color=london_color, textcolor=lb_color, size=lb_size))
        //if london_range
         //   london_box.unshift(box.new(bar_index,high,bar_index + 1, low, london_color, boxBorderSize, line.style_solid, extend.right, bgcolor = london_box_color))

      //  if london_line.size() > box_ext
        //    lineEXToff(london_line.get(box_ext))
        //if london_box.size( ) > box_ext
          //  boxEXToff(london_box.get(box_ext))
        //else if londonISopen
          //  if london_range
            //    adjustbox2(london_box.get(0))
check_array(london_line) 
check_array(london_box)
check_array(london_lbl)

// noon session started, this is the very first candle
if use_noon
    if noonISopen and not noonISopen[1]
        noon_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=noon_color, width = linethickness))
        noon_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, noon_text, style=label_style, color=noon_color, textcolor=lb_color, size=lb_size))
        if noon_range
            noon_box.unshift(box.new(bar_index,high,bar_index + 1, low, noon_color, boxBorderSize, line.style_solid, extend.right, bgcolor = noon_box_color))

        if noon_line.size() > box_ext
            lineEXToff(noon_line.get(box_ext))
        if noon_box.size( ) > box_ext
            boxEXToff(noon_box.get(box_ext))
    else if noonISopen
        if noon_range
            adjustbox2(noon_box.get(0))
check_array(noon_line)
check_array(noon_box)
check_array(noon_lbl)

// midnight session started, this is the very first candle
if use_midnight
    if midnightISopen and not midnightISopen[1]
       // monthday := month
      //  monthtext = " " + str.format_time(time,"M/d", "America/New_York")
        midnight_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=midnight_color, width = linethickness))
        midnight_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, midnight_text, style=label_style, color=midnight_color, textcolor=lb_color, size=lb_size))

        if midnight_range
            midnight_box.unshift(box.new(bar_index,high,bar_index + 1, low, midnight_color, boxBorderSize, line.style_solid, extend.right, bgcolor = midnight_box_color))
            
        if midnight_line.size() > box_ext
            lineEXToff(midnight_line.get(box_ext))
        if midnight_box.size( ) > box_ext
            boxEXToff(midnight_box.get(box_ext))
    else if midnightISopen
        if midnight_range
            adjustbox2(midnight_box.get(0))
check_array(midnight_line)
check_array(midnight_box)
check_array(midnight_lbl)

// open1 session started, this is the very first candle
if use_open1
    if open1ISopen and not open1ISopen[1]
        open1_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=open1_color, width = linethickness))
        open1_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, open1_text, style=label_style, color=open1_color, textcolor=color.yellow, size=lb_size))
        if open1_range
            open1_box.unshift(box.new(bar_index,high,bar_index + 1, low, open1_color, boxBorderSize, line.style_solid, extend.right, bgcolor = open1_box_color))
            
        if open1_line.size() > box_ext
            lineEXToff(open1_line.get(box_ext))
        if open1_box.size( ) > box_ext
            boxEXToff(open1_box.get(box_ext))
    else if open1ISopen
        if open1_range
            adjustbox2(open1_box.get(0))
check_array(open1_line)
check_array(open1_box)
check_array(open1_lbl)

// open2 session started, this is the very first candle
if use_open2
    if open2ISopen and not open2ISopen[1]
        open2_line.unshift(line.new(bar_index,open,bar_index + 10, open, extend=extend.right, color=open2_color, width = linethickness))
        open2_lbl.unshift(label.new(bar_index + label_x_offset, open + label_y_offset, open2_text, style=label_style, color=open2_color, textcolor=lb_color, size=lb_size))
        if open2_range
            open2_box.unshift(box.new(bar_index,high,bar_index + 1, low, open2_color, boxBorderSize, line.style_solid, extend.right, bgcolor = open2_box_color))
            
        if open2_line.size() > box_ext
            lineEXToff(open2_line.get(box_ext))
        if open2_box.size( ) > box_ext
            boxEXToff(open2_box.get(box_ext))
    else if open2ISopen
        if open2_range
            adjustbox2(open2_box.get(0))
check_array(open2_line)
check_array(open2_box)
check_array(open2_lbl)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main logic Close RANGES
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


if use_nyc
    if nycISopen and not nycISopen[1]
        nyc_line.unshift(line.new(bar_index,close,bar_index + 10, close, extend=extend.right, color=nyc_color, width = linethickness))
        nyc_lbl.unshift(label.new(bar_index + label_x_offset, close + label_y_offset, nyc_text, style=label_style, color=nyc_color, textcolor=lb_color, size=lb_size))
        
        if nyc_range
            nyc_box.unshift(box.new(bar_index,high,bar_index + 1, low, nyc_color, boxBorderSize, line.style_solid, extend.right, bgcolor = nyc_box_color))
            lastclose := close
        if nyc_line.size() > box_ext
            lineEXToff(nyc_line.get(box_ext))
        if nyc_box.size( ) > box_ext
            boxEXToff(nyc_box.get(box_ext))
    else if nycISopen
        adjustclose(nyc_line.get(0), nyc_lbl.get(0))
        if nyc_range
            adjustbox2(nyc_box.get(0))
check_array(nyc_line)
check_array(nyc_box)
check_array(nyc_lbl)

if use_tas1
    if tas1ISopen and not tas1ISopen[1]
        tas1_line.unshift(line.new(bar_index,close,bar_index + 10, close, extend=extend.right, color=tas1_color, width = linethickness))
        tas1_lbl.unshift(label.new(bar_index + label_x_offset, close + label_y_offset, tas1_text, style=label_style, color=tas1_color, textcolor=lb_color, size=lb_size))
        if tas1_range
            tas1_box.unshift(box.new(bar_index,high,bar_index + 1, low, tas1_color, boxBorderSize, line.style_solid, extend.right, bgcolor = tas1_box_color))
            
        if tas1_line.size() > box_ext
            lineEXToff(tas1_line.get(box_ext))
        if tas1_box.size( ) > box_ext
            boxEXToff(tas1_box.get(box_ext))
    else if tas1ISopen
        adjustclose(tas1_line.get(0),tas1_lbl.get(0))
        if tas1_range
            adjustbox2(tas1_box.get(0))
check_array(tas1_line)
check_array(tas1_box)
check_array(tas1_lbl)

if use_tas2
    if tas2ISopen and not tas2ISopen[1]
        tas2_line.unshift(line.new(bar_index,close,bar_index + 10, close, extend=extend.right, color=tas2_color, width = linethickness))
        tas2_lbl.unshift(label.new(bar_index + label_x_offset, close + label_y_offset, tas2_text, style=label_style, color=tas2_color, textcolor=lb_color, size=lb_size))
        if tas2_range
            tas2_box.unshift(box.new(bar_index,high,bar_index + 1, low, tas2_color, boxBorderSize, line.style_solid, extend.right, bgcolor = tas2_box_color))
            
        if tas2_line.size() > box_ext
            lineEXToff(tas2_line.get(box_ext))
        if tas2_box.size( ) > box_ext
            boxEXToff(tas2_box.get(box_ext))
    else if tas2ISopen
        adjustclose(tas2_line.get(0),tas2_lbl.get(0))
        if tas2_range
            adjustbox2(tas2_box.get(0))
check_array(tas2_line)
check_array(tas2_box)
check_array(tas2_lbl)

if use_tas3
    if tas3ISopen and not tas3ISopen[1]
        tas3_line.unshift(line.new(bar_index,close,bar_index + 10, close, extend=extend.right, color=tas3_color, width = linethickness))
        tas3_lbl.unshift(label.new(bar_index + label_x_offset, close + label_y_offset, tas3_text, style=label_style, color=tas3_color, textcolor=lb_color, size=lb_size))
        if tas3_range
            tas3_box.unshift(box.new(bar_index,high,bar_index + 1, low, tas3_color, boxBorderSize, line.style_solid, extend.right, bgcolor = tas3_box_color))
            
        if tas3_line.size() > box_ext
            lineEXToff(tas3_line.get(box_ext))
        if tas3_box.size( ) > box_ext
            boxEXToff(tas3_box.get(box_ext))
    else if tas3ISopen
        adjustclose(tas3_line.get(0),tas3_lbl.get(0))
        if tas3_range
            adjustbox2(tas3_box.get(0))
check_array(tas3_line)
check_array(tas3_box)
check_array(tas3_lbl)


if use_tas4
    if tas4ISopen and not tas4ISopen[1]
        tas4_line.unshift(line.new(bar_index,close,bar_index + 10, close, extend=extend.right, color=tas4_color, width = linethickness))
        tas4_lbl.unshift(label.new(bar_index + label_x_offset, close + label_y_offset, tas4_text, style=label_style, color=tas4_color, textcolor=color.yellow, size=lb_size))
        if tas4_range
            tas4_box.unshift(box.new(bar_index,high,bar_index + 1, low, tas4_color, boxBorderSize, line.style_solid, extend.right, bgcolor = tas4_box_color))
            
        if tas4_line.size() > box_ext
            lineEXToff(tas4_line.get(box_ext))
        if tas4_box.size( ) > box_ext
            boxEXToff(tas4_box.get(box_ext))
    else if tas4ISopen
        adjustclose(tas4_line.get(0),tas4_lbl.get(0))
        if tas4_range
            adjustbox2(tas4_box.get(0))
check_array(tas4_line)
check_array(tas4_box)
check_array(tas4_lbl)
````
