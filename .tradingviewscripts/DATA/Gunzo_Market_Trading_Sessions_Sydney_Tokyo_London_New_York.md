<!-- tradingview-pine-id: PUB;5a36e877048747faba298d74c848cabc -->
<!-- tradingviewscripts-format: 1 -->
# {Gunzo} Market Trading Sessions (Sydney, Tokyo, London, New York)

Source: https://www.tradingview.com/script/ItaQLrXM/

## Description

Market Trading Sessions is a tool designed to help traders to find the best times of the day for price action trading. It displays non-overlapping visuals for the major trading sessions : Oceania, Asia, Europe, and USA.

OVERVIEW :
This tool has been designed to match all the following requirements that I needed for optimal usage :

[*] Display opening and closing of main markets
[*] See clearly market sessions (non-overlapping colors)
[*] Display Sydney session if wanted
[*] Display GMT hours and days
[*] Visually pleasing design and colors
[*] Highly configurable

As I had trouble finding a script matching all these criteria, I created this tool and I'm sharing it with the TradingView community, hoping you will find it useful too. 

SETTINGS :

[*] Display market sessions on weekends : Display theoretical market sessions times on the weekend which can be useful for non forex markets.
[*] Display session for Oceania\Sydney : Display "Oceania\Sydney" trading session
[*] Display session for Asia\Tokyo : Display "Asia\Tokyo" trading session       
[*] Display session for Europe\London : Display "Europe\London" trading session
[*] Display session for USA\New York : Display "USA\New York" trading session
[*] Display session names : Display names of the session on the visual
[*] Oceania color : Configurable color for the "Oceania\Sydney" sessions
[*] Asia color : Configurable color for the "Asia\Tokyo" sessions
[*] Europe color : Configurable color for the "Europe\London" sessions
[*] USA color : Configurable color for the "USA\New York" sessions
[*] Background color : Configurable color for the table background
[*] Border color : Configurable color for the table borders
[*] Text color : Configurable color for the table text
[*] Header color : Configurable color for the table header (even days)
[*] Header color (alternate) : Configurable color for the table header (odd days)

---

## Source Code

````pine
//@version=4
// 
// THANKS :  
// I want to thank the following pine coders that inspired me to create this tool with their code or their way of coding or their ideas.
//    - ZenAndTheArtOfTrading with https://fr.tradingview.com/script/xitSH979-Trading-Session-Indicator/
//    - UnknownUnicorn468659  with https://fr.tradingview.com/script/vFr5OL9l-Timezone-Sessions-Indicator/
//    
//
 
 
study(title="{Gunzo} Market Trading Sessions (Sydney, Tokyo, London, New York)", shorttitle="{Gunzo} Market Trading Sessions", overlay=false, max_labels_count=500)


// #########################################################################################################
// VARIABLES AND CONSTANTS
// #########################################################################################################

// global input variables
oceania_session      = input("0800-1600", title="Oceania session (local)",                   type=input.session)
asia_session         = input("0800-1600", title="Asia session (local)",                      type=input.session)
europe_session       = input("0800-1600", title="Europe session (local)",                    type=input.session)
usa_session          = input("0800-1600", title="USA session (local)",                       type=input.session)
displayed_timezone   = input("GMT",       title="Timezone displayed",                        type=input.string, 
                       options=["GMT", "America/Los_Angeles", "America/Phoenix", "America/Vancouver", "America/El_Salvador", "America/Bogota", "America/Chicago", "America/New_York", "America/Toronto", "America/Argentina/Buenos_Aires", "America/Sao_Paulo", "Etc/UTC", "Europe/London", "Europe/Berlin", "Europe/Madrid", "Europe/Paris", "Europe/Warsaw", "Europe/Athens", "Europe/Moscow", "Asia/Tehran", "Asia/Dubai", "Asia/Ashkhabad", "Asia/Kolkata", "Asia/Almaty", "Asia/Bangkok", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Singapore", "Asia/Taipei", "Asia/Seoul", "Asia/Tokyo", "Australia/ACT", "Australia/Adelaide", "Australia/Brisbane", "Australia/Sydney", "Pacific/Auckland", "Pacific/Fakaofo", "Pacific/Chatham", "Pacific/Honolulu"])
session_on_weekends  = input(false,       title="Display market sessions on weekends",       type=input.bool)
show_oceania_session = input(true,        title="Display session for Oceania\\Sydney",       type=input.bool)
show_asia_session    = input(true,        title="Display session for Asia\\Tokyo",           type=input.bool)
show_europe_session  = input(true,        title="Display session for Europe\\London",        type=input.bool)
show_usa_session     = input(true,        title="Display session for USA\\New York",         type=input.bool)
show_session_names   = input(true,        title="Display session names",                     type=input.bool)
oceania_color        = input(#88CF56FF,   title="Oceania color",                             type=input.color)
asia_color           = input(#FF931EFF,   title="Asia color",                                type=input.color)
europe_color         = input(#3FA9F5FF,   title="Europe color",                              type=input.color)
usa_color            = input(#ED1E79FF,   title="USA color",                                 type=input.color)
border_color         = input(#FFFFFFFF,   title="Border color",                              type=input.color)
table_color          = input(#E5E5E5FF,   title="Background color",                          type=input.color)
text_color           = input(#FFFFFFFF,   title="Text color",                                type=input.color)
header_color1        = input(#353233FF,   title="Header color",                              type=input.color)
header_color2        = input(#534F50FF,   title="Header color (alternate)",                  type=input.color)


// session variables with information : weekend or without weekend
final_oceania_session = oceania_session + (session_on_weekends ? ":1234567" : ":23456")
final_asia_session    = asia_session    + (session_on_weekends ? ":1234567" : ":23456")
final_europe_session  = europe_session  + (session_on_weekends ? ":1234567" : ":23456")
final_usa_session     = usa_session     + (session_on_weekends ? ":1234567" : ":23456")

// session timzones
oceania_timezone = "Australia/Sydney"
asia_timezone    = "Asia/Tokyo"
europe_timezone  = "Europe/London"
usa_timezone     = "America/New_York"

// intermediate variables 
delta_period = time - time[1]
daily_period = 60 * 60 * 24 * 1000

// plotting variables
size         = 10
begin        = 60
border       = 1
textsize     = 0

 
// #########################################################################################################
// FUNCTION DEFINITIONS
// #########################################################################################################

// verify current time is included in a session
fn_is_in_session(session, timezone) => 
    not na(time(timeframe.period, session, timezone))
    
// return day of the week as a day name
fn_get_day_name(day_number) =>
    name = day_number == dayofweek.sunday    ? "Sunday"    : 
           day_number == dayofweek.monday    ? "Monday"    : 
           day_number == dayofweek.tuesday   ? "Tuesday"   : 
           day_number == dayofweek.wednesday ? "Wednesday" : 
           day_number == dayofweek.thursday  ? "Thursday"  : 
           day_number == dayofweek.friday    ? "Friday"    : 
           day_number == dayofweek.saturday  ? "Saturday"  : na
    name


// #########################################################################################################
// CALCULATING SESSION MAIN INFORMATION
// #########################################################################################################

// time variables
hour_gmt     = hour(time, displayed_timezone)
day_of_month = dayofmonth(time, displayed_timezone)
day_of_week  = dayofweek(time, displayed_timezone)
day_of_week_name = fn_get_day_name(day_of_week)
day_count    = int(na)
day_count   := day_of_month != day_of_month[1] ? nz(day_count[1]) + 1 : day_count[1]
show_under_daily_timeperiod = delta_period < daily_period

// boolean variables²
is_day_changing    = day_of_month != day_of_month[1]
is_day_continuing  = day_of_month == day_of_month[1]
is_hour_changing   = hour_gmt     != hour_gmt[1]
is_oceania_session = fn_is_in_session(final_oceania_session, oceania_timezone)
is_asia_session    = fn_is_in_session(final_asia_session,    asia_timezone)
is_europe_session  = fn_is_in_session(final_europe_session,  europe_timezone)
is_usa_session     = fn_is_in_session(final_usa_session,     usa_timezone)

// color variables
color_transparent    = color.new(#000000, 100) 
color_header1        = day_count[1] % 2 == 0 ? header_color1 : header_color2
color_header2        = day_count[1] % 2 == 0 ? header_color1 : header_color2
color_oceania_final  = is_oceania_session[1] ? oceania_color : color_transparent
color_asia_final     = is_asia_session[1]    ? asia_color    : color_transparent
color_europe_final   = is_europe_session[1]  ? europe_color  : color_transparent
color_usa_final      = is_usa_session[1]     ? usa_color     : color_transparent


// #########################################################################################################
// PLOTTING SESSIONS
// #########################################################################################################

// plotting background and lines (horizontal and vertical)
bgcolor(table_color, title="Background color", editable=false)
plot(begin - (0*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin - (1*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin - (2*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin - (3*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin - (4*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin - (5*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin - (6*size), color=border_color, style=plot.style_line, linewidth=1, editable=false)
plot(begin, color=border_color, style=plot.style_histogram, linewidth=1, editable=false)

// plotting table
header_top1    = plot(show_under_daily_timeperiod                          ? begin - (0*size) - border : na, title="Header (days)",   style=plot.style_line, color=color_header1,       editable=false)
header_bottom1 = plot(show_under_daily_timeperiod                          ? begin - (1*size) + border : na, title="Header (days)",   style=plot.style_line, color=color_header1,       editable=false)
header_top2    = plot(show_under_daily_timeperiod                          ? begin - (1*size) - border : na, title="Header (hours)",  style=plot.style_line, color=color_header2,       editable=false)
header_bottom2 = plot(show_under_daily_timeperiod                          ? begin - (2*size) + border : na, title="Header (hours)",  style=plot.style_line, color=color_header2,       editable=false)
fill(header_top1, header_bottom1, color=color_header1,       title="Header (days)",   editable=false)
fill(header_top2, header_bottom2, color=color_header2,       title="Header (hours)",  editable=false)

// plottting sesions
oceania_top    = plot(show_under_daily_timeperiod and show_oceania_session ? begin - (2*size) - border : na, title="Oceania session", style=plot.style_line, color=color_oceania_final, editable=false)
oceania_bottom = plot(show_under_daily_timeperiod and show_oceania_session ? begin - (3*size) + border : na, title="Oceania session", style=plot.style_line, color=color_oceania_final, editable=false)
asia_top       = plot(show_under_daily_timeperiod and show_asia_session    ? begin - (3*size) - border : na, title="Asia session",    style=plot.style_line, color=color_asia_final,    editable=false)
asia_bottom    = plot(show_under_daily_timeperiod and show_asia_session    ? begin - (4*size) + border : na, title="Asia session",    style=plot.style_line, color=color_asia_final,    editable=false)
europe_top     = plot(show_under_daily_timeperiod and show_europe_session  ? begin - (4*size) - border : na, title="Europe session",  style=plot.style_line, color=color_europe_final,  editable=false)
europe_bottom  = plot(show_under_daily_timeperiod and show_europe_session  ? begin - (5*size) + border : na, title="Europe session",  style=plot.style_line, color=color_europe_final,  editable=false)
usa_top        = plot(show_under_daily_timeperiod and show_usa_session     ? begin - (5*size) - border : na, title="USA session",     style=plot.style_line, color=color_usa_final,     editable=false)
usa_bottom     = plot(show_under_daily_timeperiod and show_usa_session     ? begin - (6*size) + border : na, title="USA session",     style=plot.style_line, color=color_usa_final,     editable=false)
fill(oceania_top, oceania_bottom, color=color_oceania_final, title="Oceania session", editable=false)
fill(asia_top,    asia_bottom,    color=color_asia_final,    title="Asia session",    editable=false)
fill(europe_top,  europe_bottom,  color=color_europe_final,  title="Europe session",  editable=false)
fill(usa_top,     usa_bottom,     color=color_usa_final,     title="USA session",     editable=false)


// #########################################################################################################
// CALCULATING SESSION LABEL POSITIONS
// #########################################################################################################

begin_day          = int(na)
begin_day         := is_day_continuing ? (is_day_continuing[1] ? begin_day[1] : time[1]) : na
center_day         = is_day_continuing ? (begin_day + time) / 2 : na 

begin_oceania      = int(na)
begin_oceania     := is_oceania_session ? (is_oceania_session[1] ? begin_oceania[1] : time) : na
center_oceania     = is_oceania_session ? (begin_oceania + time) / 2 : na 

begin_asia         = int(na)
begin_asia        := is_asia_session ? (is_asia_session[1] ? begin_asia[1] : time) : na
center_asia        = is_asia_session ? (begin_asia + time) / 2 : na 

begin_europe       = int(na)
begin_europe      := is_europe_session ? (is_europe_session[1] ? begin_europe[1] : time) : na
center_europe      = is_europe_session ? (begin_europe + time) / 2 : na 

begin_usa          = int(na)
begin_usa         := is_usa_session ? (is_usa_session[1] ? begin_usa[1] : time) : na
center_usa         = is_usa_session ? (begin_usa + time) / 2 : na 


// #########################################################################################################
// PLOTTING SESSIONS LABELS
// #########################################################################################################
min_bar_size = 2 // greater or equal 1

var label l_sess0 = na, var label l_sess1 = na, var label l_sess2 = na, var label l_sess3 = na, var label l_sess4 = na

if show_under_daily_timeperiod and barstate.isnew and is_hour_changing
    label.new(x=time, y=begin - (2*size) + border + textsize, text=tostring(hour_gmt), textcolor=text_color, style=label.style_none, xloc = xloc.bar_time, yloc=yloc.price, size=size.normal)

if show_under_daily_timeperiod and barstate.isnew and is_day_continuing
    if is_day_continuing[1]
        label.delete(l_sess0)
    l_sess0 := label.new(x=center_day, y=begin - (1*size) + border + textsize, text=tostring(day_of_week_name), textcolor=text_color, style=label.style_none, xloc = xloc.bar_time, yloc=yloc.price, size=size.normal)

if show_under_daily_timeperiod and show_oceania_session and show_session_names and is_oceania_session and is_oceania_session[min_bar_size-1]
    if is_oceania_session[min_bar_size]
        label.delete(l_sess1)
    l_sess1 := label.new(x=center_oceania, y=begin - (3*size) + border + textsize, text="Sydney",   textcolor=text_color, style=label.style_none, xloc = xloc.bar_time, yloc=yloc.price, size=size.normal)
    
if show_under_daily_timeperiod and show_asia_session and show_session_names and is_asia_session and is_asia_session[min_bar_size-1]
    if is_asia_session[min_bar_size]
        label.delete(l_sess2)
    l_sess2 := label.new(x=center_asia, y=begin - (4*size) + border + textsize, text="Tokyo",    textcolor=text_color, style=label.style_none, xloc = xloc.bar_time, yloc=yloc.price, size=size.normal)

if show_under_daily_timeperiod and show_europe_session and show_session_names and is_europe_session and is_europe_session[min_bar_size-1]
    if is_europe_session[min_bar_size]
        label.delete(l_sess3)
    l_sess3 := label.new(x=center_europe, y=begin - (5*size) + border + textsize, text="London",   textcolor=text_color, style=label.style_none, xloc = xloc.bar_time, yloc=yloc.price, size=size.normal)

if show_under_daily_timeperiod and show_usa_session and show_session_names and is_usa_session and is_usa_session[min_bar_size-1]
    if is_usa_session[min_bar_size]
        label.delete(l_sess4)
    l_sess4 := label.new(x=center_usa, y=begin - (6*size) + border + textsize, text="New York", textcolor=text_color, style=label.style_none, xloc = xloc.bar_time, yloc=yloc.price, size=size.normal)
````
