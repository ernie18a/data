# Central Bank Dealing Range [#]

- url: https://www.tradingview.com/script/VnM16uoH-Central-Bank-Dealing-Range/
- type: indicator
- pine_id: PUB;aabaa7fc2abc4ec3a7f93540d898cfb6
- version: 1.0

## Description

[b] Central Bank Dealing Range [#] [/b]

This indicator visualizes the central bank dealing range and projected price levels derived from historical intraday volatility. It is inspired by widely discussed market concepts involving session ranges and mean reversion or expansion behavior, and is designed strictly for analytical and educational purposes.

The script identifies and plots a defined intraday range (referred to here as the Central Dealing Range). Once the range is established, the indicator calculates its high-to-low distance and projects multiple extension levels above and below the range using configurable deviation multiples. These projected levels help users observe how price interacts with prior volatility boundaries throughout the trading day.

[b]Key Features:[/b]

• [b]Session Range Detection:[/b] Automatically tracks and updates the high and low of selected trading sessions.
• [b]Range Visualization:[/b] Displays the active range as a shaded box on the chart for clear reference.
• [b]Deviation Projections:[/b] Plots multiple user-defined expansion levels based on the measured range.
• [b]Directional Control:[/b] Allows users to display projections on the upside, downside, or both.
• [b]Auto Selection Logic:[/b] Optionally highlights the most relevant range based on recent conditions.
• [b]Timezone Flexibility:[/b] Supports multiple timezone settings to align sessions with user preference.

[b]Important Notes:[/b]

• This tool does not provide trading signals, alerts, or recommendations.
• Past performance or historical range behavior does not guarantee future results.
• This script is for informational and educational use only and should not be considered financial advice.
• Users are responsible for validating any analysis and applying appropriate risk management.

[b]Usage:[/b]

Apply the indicator to intraday charts for best results. Lower timeframes provide more precise session structure, while higher timeframes may reduce visibility due to range compression.


Code base from Daily Protocol [#], which is derived from ICT Everything by coldbrewrosh

## Source Code

````pine
//@version=5
indicator("ICT 2016/2017 M8 - Central Bank Dealing Range [#]", overlay=true, max_lines_count=500, max_labels_count=5, max_boxes_count=500)

// General Settings Inputs
TZI                     = input.string          (defval="UTC -4", title="Timezone Selection", options=["UTC -10", "UTC -7", "UTC -6", "UTC -5", "UTC -4", "UTC -3", "UTC +0", "UTC +1", "UTC +2", "UTC +3", "UTC +3:30", "UTC +4", "UTC +5", "UTC +5:30", "UTC +6", "UTC +7", "UTC +8", "UTC +9", "UTC +9:30", "UTC +10", "UTC +10:30", "UTC +11", "UTC +13", "UTC +13:45"], tooltip="Select the Timezone. ( Shifts Chart Elements )", group="Global Settings")
Timezone                = TZI                   == "UTC -10" ? "GMT-10:00" : TZI == "UTC -7" ? "GMT-07:00" : TZI == "UTC -6" ? "GMT-06:00" : TZI == "UTC -5" ? "GMT-05:00" : TZI == "UTC -4" ? "GMT-04:00" : TZI == "UTC -3" ? "GMT-03:00" : TZI == "UTC +0" ? "GMT+00:00" : TZI == "UTC +1" ? "GMT+01:00" : TZI == "UTC +2" ? "GMT+02:00" : TZI == "UTC +3" ? "GMT+03:00" : TZI == "UTC +3:30" ? "GMT+03:30" : TZI == "UTC +4" ? "GMT+04:00" : TZI == "UTC +5" ? "GMT+05:00" : TZI == "UTC +5:30" ? "GMT+05:30" : TZI == "UTC +6" ? "GMT+06:00" : TZI == "UTC +7" ? "GMT+07:00" : TZI == "UTC +8" ? "GMT+08:00" : TZI == "UTC +9" ? "GMT+09:00" : TZI == "UTC +9:30" ? "GMT+09:30" : TZI == "UTC +10" ? "GMT+10:00" : TZI == "UTC +10:30" ? "GMT+10:30" : TZI == "UTC +11" ? "GMT+11:00" : TZI == "UTC +13" ? "GMT+13:00" : "GMT+13:45"
inputMaxInterval        = input.int             (61, title="Hide Indicator Above Specified Minutes", tooltip="Above 30Min, Chart Will Become Messy & Unreadable", group="Global Settings")
// ASIA, LNDN & NY AM
ShowCBDR                = true
ShowASIA                = false
ShowFLOUT                  = true

// Strings
txt0                    = ""
txt1                    = ""
txt7                    = "CBDR"

// Color
CBDRBoxCol              = (color.new(#f23645, 0))
ASIABoxCol              = (color.new(#673ab7, 0))
FLOUTBoxCol             = (color.new(#ffeb3b, 0))

// Extras
box_text_asia           = false
box_text_asia_col       = (color.new(color.gray, 80))
bool_asia_dev           = true

box_text_cbdr           = false
box_text_cbdr_col       = (color.new(color.gray, 80))
bool_cbdr_dev           = true

box_text_flout          = false
box_text_flout_col      = (color.new(color.gray, 80))
bool_flout_dev          = true

// Table

// SD Lines
ShowDevLN               = input.bool            (title="", defval=true, inline="DEVLN", group="Standard Deviation", tooltip="Deviation Lines")
DEVLNTXT                = input.string          ("SD LINES", title="", inline="DEVLN", group="Standard Deviation")
DevLNCol                = input.color           (color.new(#787b86, 0), "", inline="DEVLN", group="Standard Deviation")
DEVLS                   = input.string          ("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="DEVLN", group="Standard Deviation")
i_DEVLW                 = input.string          ("1px", "", options=["1px","2px", "3px", "4px", "5px"], inline="DEVLN", group="Standard Deviation")
DEVLSS                  = DEVLS=="Solid" ? line.style_solid : DEVLS == "Dotted" ? line.style_dotted : line.style_dashed
DEVLW                   = i_DEVLW=="1px" ? 1 : i_DEVLW == "2px" ? 2 : i_DEVLW == "3px" ? 3 : i_DEVLW == "4px" ? 4 : 5

ShowDev                 = input.bool            (true, '', inline="DEV", group="Standard Deviation")
txt8                    = input.string          ("SD COUNT", title="", inline="DEV", group="Standard Deviation")
SDCountCol              = input.color           (color.new(#787b86, 0), "", inline="DEV", group="Standard Deviation")
DevInput                = input.string          ("4 SD", "", options=["1 SD","2 SD", "3 SD", "4 SD"], inline="DEV", group="Standard Deviation")
DevDirection            = input.string          ("Both", "", options=["Upside Only","Both", "Downside Only"], inline="DEV", group="Standard Deviation", tooltip="SD Count, NULL, SD Count, SD Direction")
DevCount                = DevInput          ==  "1 SD" ? 1 : DevInput == "2 SD" ? 2 : DevInput == "3 SD" ? 3 : 4

Auto_Select             = input.bool            (false, "", group="Standard Deviation", inline="AUTOSD", tooltip="Auto SD Selection | Charter Content, Range Table \nMight Bug Out On Mondays" )
txtSD                   = input.string          ("AUTO SD", "", group="Standard Deviation", inline="AUTOSD")
Tab1txtCol              = input.color           (color.new(#808080, 0), "", inline='AUTOSD', group="Standard Deviation")
TabOptionShow           = input.string          ("Show Table", "", options=["Show Table", "Hide Table"], inline="AUTOSD", group="Standard Deviation")
Stats                   = TabOptionShow     == "Show Table" ? true : false
TabOption1              = input.string          ("Top Right", "", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], inline="AUTOSD", group="Standard Deviation")
tabinp1                 = TabOption1        == "Top Left" ? position.top_left : TabOption1 == "Top Center" ? position.top_center : TabOption1 == "Top Right" ? position.top_right : TabOption1 == "Middle Left" ? position.middle_left : TabOption1 == "Middle Right" ? position.middle_right : TabOption1 == "Bottom Left" ? position.bottom_left : TabOption1 == "Bottom Center" ? position.bottom_center : position.bottom_right
L_Prof                  = true
CellBG                  = color.new(#131722, 100)


//----------------------------------------------


notes                   = ("@shulktrades")



//--------------------END OF INPUTS--------------------//

// Pre-Def
DOM                     = (timeframe.multiplier <= inputMaxInterval) and (timeframe.isintraday)
newDay                  = ta.change(dayofweek)
newWeek                 = ta.change(weekofyear)
newMonth                = ta.change(time("M")) 

transparentcol          = color.rgb(255,255,255,100)

LSVLC                   = color.rgb(255,255,255,100)
NYSVLC                  = color.rgb(255,255,255,100)
PMSVLC                  = color.rgb(255,255,255,100)
ASVLC                   = color.rgb(255,255,255,100)

LSVLS                   = "dotted"
NYSVLS                  = "dotted"
PMSVLS                  = "dotted"
ASVLS                   = "dotted"

// Functions
isToday = false
if year(timenow) == year(time) and month(timenow) == month(time) and dayofmonth(timenow) == dayofmonth(time) 
    isToday := true

// Current Week
thisweek = year(timenow) == year(time) and weekofyear(timenow) == weekofyear(time)
LastOneWeek = year(timenow) == year(time) and weekofyear(timenow-604800000) == weekofyear(time)
LastTwoWeek = year(timenow) == year(time) and weekofyear(timenow-1209600000) == weekofyear(time)
LastThreeWeek = year(timenow) == year(time) and weekofyear(timenow-1814400000) == weekofyear(time)
LastFourWeek = year(timenow) == year(time) and weekofyear(timenow-2419200000) == weekofyear(time)
Last4Weeks = false
if thisweek == true or LastOneWeek == true or LastTwoWeek == true or LastThreeWeek == true or LastFourWeek == true
    Last4Weeks := true

// Function to draw Vertical Lines
vline(Start, Color, linestyle, LineWidth) =>
    line.new(x1=Start, y1=low - ta.tr, x2=Start, y2=high + ta.tr, xloc=xloc.bar_time, extend=extend.both, color=Color, style=linestyle, width=LineWidth)

// Function to convert forex pips into whole numbers
atr = ta.atr(14)
toWhole(number) =>
    if syminfo.type == "forex" // This method only works on forex pairs
        _return = atr < 1.0 ? (number / syminfo.mintick) / 10 : number
        _return := atr >= 1.0 and atr < 100.0 and syminfo.currency == "JPY" ? _return * 100 : _return
    else
        number

// Function for determining the Start of a Session (taken from the Pinescript manual: https://www.tradingview.com/pine-script-docs/en/v5/concepts/Sessions.html )
SessionBegins(sess) =>
    t = time("", sess , Timezone)
    DOM and (not barstate.isfirst) and na(t[1]) and not na(t)

// BarIn Session
BarInSession(sess) =>
    time(timeframe.period, sess, Timezone) != 0

// Label Type Logic
var SFistrue = true



// Session String to int
SeshStartHour(Session) =>
    math.round(str.tonumber(str.substring(Session,0,2)))
SeshStartMins(Session) =>
    math.round(str.tonumber(str.substring(Session,2,4)))
SeshEndHour(Session) =>
    math.round(str.tonumber(str.substring(Session,5,7)))
SeshEndMins(Session) =>
    math.round(str.tonumber(str.substring(Session,7,9)))

// Time periods
CBDR                    = "1400-2000:1234567"
ASIA                    = "2000-0000:1234567"
FLOUT                   = "1400-2000:1234567"
midsesh                 = "0000-1600:1234567"

cbdrOpenTime            = timestamp             (Timezone, year, month, dayofmonth, SeshStartHour(CBDR), SeshStartMins(CBDR), 00)
cbdrEndTime             = timestamp             (Timezone, year, month, dayofmonth, SeshEndHour(CBDR), SeshEndMins(CBDR), 00)
asiaOpenTime            = timestamp             (Timezone, year, month, dayofmonth, SeshStartHour(ASIA), SeshStartMins(ASIA), 00)
asiaEndTime             = timestamp             (Timezone, year, month, dayofmonth, SeshEndHour(ASIA), SeshEndMins(ASIA), 00)+86400000
floutOpenTime           = timestamp             (Timezone, year, month, dayofmonth, SeshStartHour(FLOUT), SeshStartMins(FLOUT), 00)
floutEndTime            = timestamp             (Timezone, year, month, dayofmonth, SeshEndHour(FLOUT), SeshEndMins(FLOUT), 00)
CBDRTime                = time                  (timeframe.period, CBDR, Timezone)
ASIATime                = time                  (timeframe.period, ASIA, Timezone)
FLOUTTime               = time                  (timeframe.period, FLOUT, Timezone)

LabelOnlyToday          = true



            
 // CBDR Stuff
var float cbdr_hi                = na
var float cbdr_lo                = na
var float cbdr_diff              = na
var box   cbdrbox                = na
var line  cbdr_hi_line           = na
var line  cbdr_lo_line           = na
var line  dev01negline           = na
var line  dev02negline           = na
var line  dev03negline           = na
var line  dev04negline           = na
var line  dev01posline           = na
var line  dev02posline           = na
var line  dev03posline           = na
var line  dev04posline           = na 

if SessionBegins(CBDR) and DOM 
    cbdr_hi                 := high
    cbdr_lo                 := low
    cbdr_diff           := cbdr_hi - cbdr_lo
    
    if ShowCBDR
        cbdrbox := box.new(cbdrOpenTime, cbdr_hi, cbdrEndTime, cbdr_lo, color.new(CBDRBoxCol,90), 1, line.style_solid, extend.none, xloc.bar_time, color.new(CBDRBoxCol,90), txt0, size.auto, color.new(box_text_cbdr_col,80), text_wrap=text.wrap_auto)
    if box_text_cbdr == false
        box.set_text(cbdrbox, "")
    if ShowDev and ShowCBDR and bool_cbdr_dev
        for i = 1 to DevCount by 1
            if i == 1
                dev01posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_hi + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev01negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 2
                dev02posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_lo + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev02negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 3
                dev03posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_lo + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev03negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 4
                dev04posline := line.new(cbdrOpenTime, cbdr_hi + cbdr_diff * i, cbdrEndTime, cbdr_lo + cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev04negline := line.new(cbdrOpenTime, cbdr_hi - cbdr_diff * i, cbdrEndTime, cbdr_lo - cbdr_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
else if CBDRTime
    cbdr_hi             := math.max(high, cbdr_hi)
    cbdr_lo             := math.min(low, cbdr_lo)
    cbdr_diff           := cbdr_hi - cbdr_lo
    for i = 1 to DevCount by 1
        if i == 1 and ShowDev
            line.set_y1(dev01posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev01posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev01negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev01negline, cbdr_lo - cbdr_diff * i)
        if i == 2 and ShowDev
            line.set_y1(dev02posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev02posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev02negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev02negline, cbdr_lo - cbdr_diff * i)
        if i == 3 and ShowDev
            line.set_y1(dev03posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev03posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev03negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev03negline, cbdr_lo - cbdr_diff * i)
        if i == 4 and ShowDev
            line.set_y1(dev04posline, cbdr_hi + cbdr_diff * i)
            line.set_y2(dev04posline, cbdr_hi + cbdr_diff * i)

            line.set_y1(dev04negline, cbdr_lo - cbdr_diff * i)
            line.set_y2(dev04negline, cbdr_lo - cbdr_diff * i)
    if (cbdr_hi > cbdr_hi[1])
        if ShowCBDR
            box.set_top(cbdrbox, cbdr_hi)
    if (cbdr_lo < cbdr_lo[1])
        if ShowCBDR
            box.set_bottom(cbdrbox, cbdr_lo)

if DevDirection == "Upside Only"
    line.delete(dev01negline)
    line.delete(dev02negline)
    line.delete(dev03negline)
    line.delete(dev04negline)
else if DevDirection == "Downside Only"
    line.delete(dev01posline)
    line.delete(dev02posline)
    line.delete(dev03posline)
    line.delete(dev04posline)

// ASIA Stuff
var float asia_hi                   = na
var float asia_lo                   = na
var float asia_diff                 = na
var box   asia_box                  = na
var line  asia_hi_line              = na
var line  asia_lo_line              = na
var line  dev01negline_asia         = na
var line  dev02negline_asia         = na
var line  dev03negline_asia         = na
var line  dev04negline_asia         = na
var line  dev01posline_asia         = na
var line  dev02posline_asia         = na
var line  dev03posline_asia         = na
var line  dev04posline_asia         = na 
if SessionBegins(ASIA) and DOM 
    asia_hi                 := high
    asia_lo                 := low
    asia_diff               := asia_hi - asia_lo

    if ShowASIA
        asia_box := box.new(asiaOpenTime, asia_hi, asiaEndTime, asia_lo, color.new(ASIABoxCol,90), 1, line.style_solid, extend.none, xloc.bar_time, color.new(ASIABoxCol,90), txt1, size.auto, color.new(box_text_asia_col,80), text_wrap=text.wrap_auto)
    if box_text_asia == false
        box.set_text(asia_box, "")
    if ShowDev and ShowASIA and bool_asia_dev
        for i = 1 to DevCount by 1
            if i == 1
                dev01posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_hi + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev01negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 2
                dev02posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_lo + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev02negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 3
                dev03posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_lo + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev03negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 4
                dev04posline_asia := line.new(asiaOpenTime, asia_hi + asia_diff * i, asiaEndTime, asia_lo + asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev04negline_asia := line.new(asiaOpenTime, asia_hi - asia_diff * i, asiaEndTime, asia_lo - asia_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
else if ASIATime
    asia_hi             := math.max(high, asia_hi)
    asia_lo             := math.min(low, asia_lo)
    asia_diff           := asia_hi - asia_lo
    for i = 1 to DevCount by 1
        if i == 1 and ShowDev
            line.set_y1(dev01posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev01posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev01negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev01negline_asia, asia_lo - asia_diff * i)
        if i == 2 and ShowDev
            line.set_y1(dev02posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev02posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev02negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev02negline_asia, asia_lo - asia_diff * i)
        if i == 3 and ShowDev
            line.set_y1(dev03posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev03posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev03negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev03negline_asia, asia_lo - asia_diff * i)
        if i == 4 and ShowDev
            line.set_y1(dev04posline_asia, asia_hi + asia_diff * i)
            line.set_y2(dev04posline_asia, asia_hi + asia_diff * i)

            line.set_y1(dev04negline_asia, asia_lo - asia_diff * i)
            line.set_y2(dev04negline_asia, asia_lo - asia_diff * i)
    if (asia_hi > asia_hi[1])
        box.set_top(asia_box, asia_hi)
    if (asia_lo < asia_lo[1])
        box.set_bottom(asia_box, asia_lo)

if DevDirection == "Upside Only"
    line.delete(dev01negline_asia)
    line.delete(dev02negline_asia)
    line.delete(dev03negline_asia)
    line.delete(dev04negline_asia)
else if DevDirection == "Downside Only"
    line.delete(dev01posline_asia)
    line.delete(dev02posline_asia)
    line.delete(dev03posline_asia)
    line.delete(dev04posline_asia)

// FLOUT Stuff
var float flout_hi                  = na
var float flout_lo                  = na
var float flout_diff                = na
var box   floutbox                  = na
var line  flout_hi_line             = na
var line  flout_lo_line             = na
var line  dev01negline_flout        = na
var line  dev02negline_flout        = na
var line  dev03negline_flout        = na
var line  dev04negline_flout        = na
var line  dev01posline_flout        = na
var line  dev02posline_flout        = na
var line  dev03posline_flout        = na
var line  dev04posline_flout        = na 
if SessionBegins(FLOUT) and DOM 
    flout_hi            := high
    flout_lo            := low
    flout_diff          := flout_hi - flout_lo

    if ShowFLOUT
        floutbox := box.new(floutOpenTime, flout_hi, floutEndTime, flout_lo, color.new(FLOUTBoxCol,90), 1, line.style_solid, extend.none, xloc.bar_time, color.new(FLOUTBoxCol,90), txt7, size.auto, color.new(box_text_flout_col,80), text_wrap=text.wrap_auto)
    if box_text_cbdr == false
        box.set_text(floutbox, "")
    if ShowDev and ShowFLOUT and bool_flout_dev
        for i = .5 to DevCount by .5
            if i == .5
                dev01posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_hi + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev01negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 1
                dev02posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_lo + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev02negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 1.5
                dev03posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_lo + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev03negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
            if i == 2
                dev04posline_flout := line.new(floutOpenTime, flout_hi + flout_diff * i, floutEndTime, flout_lo + flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
                dev04negline_flout := line.new(floutOpenTime, flout_hi - flout_diff * i, floutEndTime, flout_lo - flout_diff * i, xloc=xloc.bar_time, color=DevLNCol, style=DEVLSS, width=DEVLW)
else if FLOUTTime
    flout_hi             := math.max(high, flout_hi)
    flout_lo             := math.min(low, flout_lo)
    flout_diff           := flout_hi - flout_lo
    for i = 0.5 to DevCount by 0.5
        if i == 0.5 and ShowDev
            line.set_y1(dev01posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev01posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev01negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev01negline_flout, flout_lo - flout_diff * i)
        if i == 1 and ShowDev
            line.set_y1(dev02posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev02posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev02negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev02negline_flout, flout_lo - flout_diff * i)
        if i == 1.5 and ShowDev
            line.set_y1(dev03posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev03posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev03negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev03negline_flout, flout_lo - flout_diff * i)
        if i == 2 and ShowDev
            line.set_y1(dev04posline_flout, flout_hi + flout_diff * i)
            line.set_y2(dev04posline_flout, flout_hi + flout_diff * i)

            line.set_y1(dev04negline_flout, flout_lo - flout_diff * i)
            line.set_y2(dev04negline_flout, flout_lo - flout_diff * i)
    if (flout_hi > flout_hi[1])
        box.set_top(floutbox, flout_hi)
    if (flout_lo < flout_lo[1])
        box.set_bottom(floutbox, flout_lo)

if DevDirection == "Upside Only"
    line.delete(dev01negline_flout)
    line.delete(dev02negline_flout)
    line.delete(dev03negline_flout)
    line.delete(dev04negline_flout)
else if DevDirection == "Downside Only"
    line.delete(dev01posline_flout)
    line.delete(dev02posline_flout)
    line.delete(dev03posline_flout)
    line.delete(dev04posline_flout)


// Start of Table
cbdrpipc                        = toWhole(cbdr_diff)
asiapipc                        = toWhole(asia_diff)
var color cbdr_cellt_col        = na
var color asia_cellt_col        = na
var color L_profile_col         = na

var color comp_green            = color.new(#1cac78,0)
var color comp_red              = color.new(#ff4040,0)
var color comp_gray             = color.new(#808080,0)
var L_Profile                   = ""

if cbdrpipc > 15 and cbdrpipc < 40
    cbdr_cellt_col  := color.new(#1cac78,0)     // Green
else
    cbdr_cellt_col  := color.new(#ff4040,0)     // Red

if asiapipc >= 20 and asiapipc <= 40
    asia_cellt_col  := color.new(#1cac78,0)     // Green
else
    asia_cellt_col  := color.new(#ff4040,0)     // Red
 
if cbdrpipc > 15 and cbdrpipc < 40
    L_Profile := "CBDR"
    L_profile_col := Tab1txtCol
else if asiapipc >= 20 and asiapipc <= 40
    L_Profile := "ASIA"
    L_profile_col := Tab1txtCol
else
    L_Profile := "FLOUT"
    L_profile_col := Tab1txtCol

if BarInSession(midsesh) and Auto_Select == true and syminfo.type == "forex"
    if cbdrpipc > 15 and cbdrpipc < 40
        // ASIA
        box.delete(asia_box)
        line.delete(dev01posline_asia)
        line.delete(dev01negline_asia)
        line.delete(dev02posline_asia)
        line.delete(dev02negline_asia)
        line.delete(dev03posline_asia)
        line.delete(dev03negline_asia)
        line.delete(dev04posline_asia)
        line.delete(dev04negline_asia)
        // FLOUT
        box.delete(floutbox)
        line.delete(dev01posline_flout)
        line.delete(dev01negline_flout)
        line.delete(dev02posline_flout)
        line.delete(dev02negline_flout)
        line.delete(dev03posline_flout)
        line.delete(dev03negline_flout)
        line.delete(dev04posline_flout)
        line.delete(dev04negline_flout)
    else if asiapipc >= 20 and asiapipc <= 40
        // CBDR
        box.delete(cbdrbox)
        line.delete(dev01posline)
        line.delete(dev01negline)
        line.delete(dev02posline)
        line.delete(dev02negline)
        line.delete(dev03posline)
        line.delete(dev03negline)
        line.delete(dev04posline)
        line.delete(dev04negline)
        // FLOUT
        box.delete(floutbox)
        line.delete(dev01posline_flout)
        line.delete(dev01negline_flout)
        line.delete(dev02posline_flout)
        line.delete(dev02negline_flout)
        line.delete(dev03posline_flout)
        line.delete(dev03negline_flout)
        line.delete(dev04posline_flout)
        line.delete(dev04negline_flout)
    else
        // CBDR
        box.delete(cbdrbox)
        line.delete(dev01posline)
        line.delete(dev01negline)
        line.delete(dev02posline)
        line.delete(dev02negline)
        line.delete(dev03posline)
        line.delete(dev03negline)
        line.delete(dev04posline)
        line.delete(dev04negline)
        // ASIA
        box.delete(asia_box)
        line.delete(dev01posline_asia)
        line.delete(dev01negline_asia)
        line.delete(dev02posline_asia)
        line.delete(dev02negline_asia)
        line.delete(dev03posline_asia)
        line.delete(dev03negline_asia)
        line.delete(dev04posline_asia)
        line.delete(dev04negline_asia)



// Table
var table ICTInfo = table.new(tabinp1, 2, 3, border_width=1)

if barstate.islast and syminfo.type == "forex" and Stats and DOM and (dayofweek != dayofweek.sunday)
    CBDR_cell           = "CBDR "
    Asia_cell           = "Asian Range "
    CBDR_cell_pipc      = "     " + str.tostring(cbdrpipc) + " pips"
    ASIA_cell_pipc      = "     " + str.tostring(asiapipc) + " pips"
    
    if L_Prof == true
        table.cell(ICTInfo, 0, 0, text=" Suggested SD ", bgcolor=CellBG, text_color=Tab1txtCol, text_halign=text.align_left, text_size=size.auto)
    table.cell(ICTInfo, 0, 1, text=" Asian Range ", bgcolor=CellBG, text_color=Tab1txtCol, text_halign=text.align_left, text_size=size.auto)
    table.cell(ICTInfo, 0, 2, text=" CBDR ", bgcolor=CellBG, text_color=Tab1txtCol, text_halign=text.align_left, text_size=size.auto)
    
    if L_Prof == true
        table.cell(ICTInfo, 1, 0, text=" "+ L_Profile + " ", bgcolor=CellBG, text_color=L_profile_col, text_halign=text.align_right, text_size=size.auto)
    table.cell(ICTInfo, 1, 1, text=ASIA_cell_pipc, bgcolor=CellBG, text_color=asia_cellt_col, text_size=size.auto, text_halign=text.align_right)
    table.cell(ICTInfo, 1, 2, text=CBDR_cell_pipc, bgcolor=CellBG, text_color=cbdr_cellt_col, text_size=size.auto, text_halign=text.align_right)

// Color Coding
var color Option1CC             = na
var color Option2CC             = na
var color Option3CC             = na
var color Option4CC             = na


// Day of the Week
txtMon    = "M O N"
txtTue    = "T U E"
txtWed    = "W E D"
txtThu    = "T H U"
txtFri    = "F R I"
txtSat    = "S A T"
txtSun    = "S U N"
````
