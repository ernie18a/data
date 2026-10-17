# XAUUSD Sessions - Parth 

- url: https://www.tradingview.com/script/EmCmwHSr-XAUUSD-Sessions-Parth/
- type: indicator
- pine_id: PUB;cfec369527574924915ce77d4619eeca
- version: 1.0

## Description

suitable for all the charts. 

i was struggling to find session box which i can train my self to under stand price reaction in perticular session. this is the best thing i made and so much helpful if you are only focusing on sessions.

## Source Code

````pine
//@version=5
indicator("XAUUSD Sessions - Hollow Boxes", overlay=true, max_boxes_count=500)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
// Session Times (Set to standard UTC/GMT forex hours)
asiaSession   = input.session("0000-0800:23456", "Asian Session Time", group="Session Settings")
londonSession = input.session("0700-1600:23456", "London Session Time", group="Session Settings")
nySession     = input.session("1200-2100:23456", "New York Session Time", group="Session Settings")

// Border Colors (No background colors will be used)
colorAsia   = input.color(#00bcd4, "Asian Border Color", group="Style Settings")
colorLondon = input.color(#ff9800, "London Border Color", group="Style Settings")
colorNY     = input.color(#e91e63, "New York Border Color", group="Style Settings")

// ==========================================
// 2. VARIABLE INITIALIZATION
// ==========================================
var box asiaBox   = na
var box londonBox = na
var box nyBox     = na

// ==========================================
// 3. ASIAN SESSION ENGINE
// ==========================================
inAsia    = not na(time(timeframe.period, asiaSession, "UTC"))
wasInAsia = not na(time(timeframe.period, asiaSession, "UTC"))[1]

if inAsia and not wasInAsia
    asiaBox := box.new(
         left=bar_index, 
         top=high, 
         right=bar_index, 
         bottom=low, 
         bgcolor=color.new(color.white, 100), // 100% Transparent background
         border_color=colorAsia, 
         border_width=1, 
         border_style=line.style_dotted, 
         text="asian session", 
         text_size=size.small, 
         text_color=color.new(chart.fg_color, 30), 
         text_valign=text.align_top, 
         text_halign=text.align_left
         )
else if inAsia and not na(asiaBox)
    box.set_top(asiaBox, math.max(high, box.get_top(asiaBox)))
    box.set_bottom(asiaBox, math.min(low, box.get_bottom(asiaBox)))
    box.set_right(asiaBox, bar_index)

// ==========================================
// 4. LONDON SESSION ENGINE
// ==========================================
inLondon    = not na(time(timeframe.period, londonSession, "UTC"))
wasInLondon = not na(time(timeframe.period, londonSession, "UTC"))[1]

if inLondon and not wasInLondon
    londonBox := box.new(
         left=bar_index, 
         top=high, 
         right=bar_index, 
         bottom=low, 
         bgcolor=color.new(color.white, 100), // 100% Transparent background
         border_color=colorLondon, 
         border_width=1, 
         border_style=line.style_dotted, 
         text="london session", 
         text_size=size.small, 
         text_color=color.new(chart.fg_color, 30), 
         text_valign=text.align_top, 
         text_halign=text.align_left
         )
else if inLondon and not na(londonBox)
    box.set_top(londonBox, math.max(high, box.get_top(londonBox)))
    box.set_bottom(londonBox, math.min(low, box.get_bottom(londonBox)))
    box.set_right(londonBox, bar_index)

// ==========================================
// 5. NEW YORK SESSION ENGINE
// ==========================================
inNY    = not na(time(timeframe.period, nySession, "UTC"))
wasInNY = not na(time(timeframe.period, nySession, "UTC"))[1]

if inNY and not wasInNY
    nyBox := box.new(
         left=bar_index, 
         top=high, 
         right=bar_index, 
         bottom=low, 
         bgcolor=color.new(color.white, 100), // 100% Transparent background
         border_color=colorNY, 
         border_width=1, 
         border_style=line.style_dotted, 
         text="new york session", 
         text_size=size.small, 
         text_color=color.new(chart.fg_color, 30), 
         text_valign=text.align_top, 
         text_halign=text.align_left
         )
else if inNY and not na(nyBox)
    box.set_top(nyBox, math.max(high, box.get_top(nyBox)))
    box.set_bottom(nyBox, math.min(low, box.get_bottom(nyBox)))
    box.set_right(nyBox, bar_index)
````
