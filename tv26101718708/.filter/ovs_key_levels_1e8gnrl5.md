# OVS Key Levels

- url: https://www.tradingview.com/script/1E8gnrL5-OVS-Key-Levels/
- type: indicator
- pine_id: PUB;e4c4000dcedd4518bb2db47180190ca2
- version: 1.0

## Description

Key levels in price
Month Open
Week Open
Day Open
Previous Week High / Low
Previous Day High / Low

Previous Days VWAP level 

These are all key prices that price reacts to. 
We are waiting on price to hit these levels and we watch how price reacts. Are we seeing price being rejected? What patterns are we seeing on the lower timeframes, this is key. 


Understanding levels
Trade only the strongest levels. Price and algos are always target HTF levels to take profits or to scale in. 

Patterns 
Is price stair stepping 
is price creating a flag pattern
are we seeing double top and break down
are we seeing large candles in the area and are these large candles holding price?

## Source Code

````pine
//@version=6
// OV Key Levels - Month Open | Week Open | Day Open | Prev Week H/L | Prev Day H/L | Prev Day VWAP
// Created by MasterEdward
indicator(title='OVS Key Levels', shorttitle='OVS key levels', overlay=true, precision=8, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════
// TIMEZONE SETTINGS
// ═══════════════════════════════════════
i_timezone = input.string(
     "Exchange",
     title   = "Timezone",
     options = [
         "Exchange",
         "UTC",
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "Europe/London",
         "Europe/Paris",
         "Europe/Berlin",
         "Asia/Tokyo",
         "Asia/Hong_Kong",
         "Asia/Singapore",
         "Australia/Sydney"
     ],
     tooltip = "Select the timezone used for period boundary detection (month/week/day open). 'Exchange' uses the instrument's native exchange timezone.",
     group   = "Timezone Settings")

// Resolve the timezone string; "Exchange" maps to the symbol's own timezone
tz = i_timezone == "Exchange" ? syminfo.timezone : i_timezone

// ═══════════════════════════════════════
// LABEL SETTINGS
// ═══════════════════════════════════════
i_hide_all_prices = input.bool(false,      title="Hide ALL Prices Globally",   group="Label Settings")
i_label_size      = input.string("Normal", title="Label Size", options=["Auto","Huge","Large","Normal","Small","Tiny"], group="Label Settings")
i_label_bg_color  = input.color(color.rgb(120, 123, 134, 80), title="Label Background Color", group="Label Settings")
i_label_txt_color = input.color(color.rgb(255, 255, 255, 0),  title="Label Text Color",        group="Label Settings")
i_label_x_offset  = input.int(2,     title="Label Horizontal Offset (bars)", minval=-100, maxval=100, group="Label Settings")
i_label_y_offset  = input.float(0.0, title="Label Vertical Offset (price)",  step=0.01,               group="Label Settings")

label_size_mod = switch i_label_size
    "Auto"   => size.auto
    "Huge"   => size.huge
    "Large"  => size.large
    "Normal" => size.normal
    "Small"  => size.small
    "Tiny"   => size.tiny

// ═══════════════════════════════════════
// LABEL TEXT
// ═══════════════════════════════════════
i_mo_label_text     = input.string("MO",     title="Month Open",     group="Label Text")
i_wo_label_text     = input.string("WO",     title="Week Open",      group="Label Text")
i_do_label_text     = input.string("DO",     title="Daily Open",     group="Label Text")
i_pwh_label_text    = input.string("PWH",    title="Prev Week High", group="Label Text")
i_pwl_label_text    = input.string("PWL",    title="Prev Week Low",  group="Label Text")
i_pdh_label_text    = input.string("PDH",    title="Prev Day High",  group="Label Text")
i_pdl_label_text    = input.string("PDL",    title="Prev Day Low",   group="Label Text")
i_pdvwap_label_text = input.string("PDVWAP", title="Prev Day VWAP",  group="Label Text")

// ═══════════════════════════════════════
// SHOW LABEL TOGGLES
// ═══════════════════════════════════════
i_show_mo_label     = input.bool(true, title="Show Month Open Label",     group="Show Labels")
i_show_wo_label     = input.bool(true, title="Show Week Open Label",      group="Show Labels")
i_show_do_label     = input.bool(true, title="Show Daily Open Label",     group="Show Labels")
i_show_pwh_label    = input.bool(true, title="Show Prev Week High Label", group="Show Labels")
i_show_pwl_label    = input.bool(true, title="Show Prev Week Low Label",  group="Show Labels")
i_show_pdh_label    = input.bool(true, title="Show Prev Day High Label",  group="Show Labels")
i_show_pdl_label    = input.bool(true, title="Show Prev Day Low Label",   group="Show Labels")
i_show_pdvwap_label = input.bool(true, title="Show Prev Day VWAP Label",  group="Show Labels")

// ═══════════════════════════════════════
// SHOW PRICE IN LABEL TOGGLES
// ═══════════════════════════════════════
i_mo_show_price     = input.bool(true, title="Month Open Price",     group="Show Price in Label")
i_wo_show_price     = input.bool(true, title="Week Open Price",      group="Show Price in Label")
i_do_show_price     = input.bool(true, title="Daily Open Price",     group="Show Price in Label")
i_pwh_show_price    = input.bool(true, title="Prev Week High Price", group="Show Price in Label")
i_pwl_show_price    = input.bool(true, title="Prev Week Low Price",  group="Show Price in Label")
i_pdh_show_price    = input.bool(true, title="Prev Day High Price",  group="Show Price in Label")
i_pdl_show_price    = input.bool(true, title="Prev Day Low Price",   group="Show Price in Label")
i_pdvwap_show_price = input.bool(true, title="Prev Day VWAP Price",  group="Show Price in Label")

// ═══════════════════════════════════════
// PREV DAY VWAP OPTIONS
// ═══════════════════════════════════════
i_vwap_show          = input.bool(true,          title="Show Prev Day VWAP Line",       group="Prev Day VWAP")
i_vwap_intraday_only = input.bool(true,          title="Show on Intraday Charts Only",  group="Prev Day VWAP")
i_vwap_color         = input.color(color.aqua,   title="Line Color",                    group="Prev Day VWAP")
i_vwap_width         = input.int(2,              title="Line Width", minval=1, maxval=4, group="Prev Day VWAP")

// ═══════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════
formatPrice(p) =>
    str.tostring(p, '#,###,###.00###')

getLabelText(price, txt, showPrice) =>
    showPrice and not i_hide_all_prices ? txt + " : " + formatPrice(price) : txt

makeLabel(price, txt, showPrice) =>
    label.new(
         x         = bar_index + i_label_x_offset,
         y         = price + i_label_y_offset,
         text      = getLabelText(price, txt, showPrice),
         xloc      = xloc.bar_index,
         color     = i_label_bg_color,
         textcolor = i_label_txt_color,
         style     = label.style_label_left,
         size      = label_size_mod)

// ═══════════════════════════════════════
// PRICE DATA
// ═══════════════════════════════════════
monthOpen    = request.security(syminfo.tickerid, 'M', open,       lookahead=barmerge.lookahead_on)
weekOpen     = request.security(syminfo.tickerid, 'W', open,       lookahead=barmerge.lookahead_on)
dayOpen      = request.security(syminfo.tickerid, 'D', open,       lookahead=barmerge.lookahead_on)
prevWeekHigh = request.security(syminfo.tickerid, 'W', high[1],    lookahead=barmerge.lookahead_on)
prevWeekLow  = request.security(syminfo.tickerid, 'W', low[1],     lookahead=barmerge.lookahead_on)
prevDayHigh  = request.security(syminfo.tickerid, 'D', high[1],    lookahead=barmerge.lookahead_on)
prevDayLow   = request.security(syminfo.tickerid, 'D', low[1],     lookahead=barmerge.lookahead_on)
prevDayVwap  = request.security(syminfo.tickerid, 'D', ta.vwap[1], lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════
// PERIOD BOUNDARY CHECKS  (timezone-aware)
// ═══════════════════════════════════════
isCurrentMonth = year(time, tz) == year(timenow, tz) and month(time, tz) == month(timenow, tz)
isCurrentWeek  = year(time, tz) == year(timenow, tz) and weekofyear(time, tz) == weekofyear(timenow, tz)
isCurrentDay   = year(time, tz) == year(timenow, tz) and month(time, tz) == month(timenow, tz) and dayofmonth(time, tz) == dayofmonth(timenow, tz)

// Prevent diagonal connecting lines on period change
mo_unchanged  = ta.change(monthOpen)    == 0
wo_unchanged  = ta.change(weekOpen)     == 0
do_unchanged  = ta.change(dayOpen)      == 0
pwh_unchanged = ta.change(prevWeekHigh) == 0
pwl_unchanged = ta.change(prevWeekLow)  == 0
pdh_unchanged = ta.change(prevDayHigh)  == 0
pdl_unchanged = ta.change(prevDayLow)   == 0

// ═══════════════════════════════════════
// PLOTS (click name in legend → full style panel)
// ═══════════════════════════════════════
plot(isCurrentMonth and mo_unchanged  ? monthOpen    : na, title="Month Open",     color=color.rgb(30,  144, 255), linewidth=2, style=plot.style_line)
plot(isCurrentWeek  and wo_unchanged  ? weekOpen     : na, title="Week Open",      color=color.rgb(255, 140,   0), linewidth=2, style=plot.style_line)
plot(isCurrentWeek  and do_unchanged  ? dayOpen      : na, title="Daily Open",     color=color.rgb(20,   20,  20), linewidth=2, style=plot.style_line)
plot(isCurrentWeek  and pwh_unchanged ? prevWeekHigh : na, title="Prev Week High", color=color.rgb(220,  50,  50), linewidth=1, style=plot.style_line)
plot(isCurrentWeek  and pwl_unchanged ? prevWeekLow  : na, title="Prev Week Low",  color=color.rgb(220,  50,  50), linewidth=1, style=plot.style_line)
plot(isCurrentDay   and pdh_unchanged ? prevDayHigh  : na, title="Prev Day High",  color=color.rgb(20,   20,  20), linewidth=1, style=plot.style_line)
plot(isCurrentDay   and pdl_unchanged ? prevDayLow   : na, title="Prev Day Low",   color=color.rgb(20,   20,  20), linewidth=1, style=plot.style_line)

// ═══════════════════════════════════════
// PREV DAY VWAP — line.new() approach from reference indicator
// A new line segment is created each time the VWAP value changes (= new day).
// x2 is extended to bar_index every bar so it tracks to the right edge cleanly.
// ═══════════════════════════════════════
showVwap = i_vwap_show and (timeframe.isintraday or not i_vwap_intraday_only)

var line vwapLine = na

if showVwap
    // New day detected — close off the old segment and start a fresh line
    if prevDayVwap[1] != prevDayVwap
        line.set_x2(vwapLine, bar_index)
        line.set_extend(vwapLine, extend.none)
        vwapLine := line.new(bar_index, prevDayVwap, bar_index, prevDayVwap,
             width  = i_vwap_width,
             extend = extend.none,
             color  = i_vwap_color)

    // Every bar — push x2 forward so the line reaches the current bar
    if not na(vwapLine) and line.get_x2(vwapLine) != bar_index
        line.set_x2(vwapLine, bar_index)

    // Keep color in sync if user changes it in settings
    line.set_color(vwapLine, i_vwap_color)

// ═══════════════════════════════════════
// LABELS — redrawn every bar to stay at right edge
// ═══════════════════════════════════════
var label lbl_mo     = na
var label lbl_wo     = na
var label lbl_do     = na
var label lbl_pwh    = na
var label lbl_pwl    = na
var label lbl_pdh    = na
var label lbl_pdl    = na
var label lbl_pdvwap = na

label.delete(lbl_mo)
label.delete(lbl_wo)
label.delete(lbl_do)
label.delete(lbl_pwh)
label.delete(lbl_pwl)
label.delete(lbl_pdh)
label.delete(lbl_pdl)
label.delete(lbl_pdvwap)

if i_show_mo_label
    lbl_mo := makeLabel(monthOpen, i_mo_label_text, i_mo_show_price)
if i_show_wo_label
    lbl_wo := makeLabel(weekOpen, i_wo_label_text, i_wo_show_price)
if i_show_do_label
    lbl_do := makeLabel(dayOpen, i_do_label_text, i_do_show_price)
if i_show_pwh_label
    lbl_pwh := makeLabel(prevWeekHigh, i_pwh_label_text, i_pwh_show_price)
if i_show_pwl_label
    lbl_pwl := makeLabel(prevWeekLow, i_pwl_label_text, i_pwl_show_price)
if i_show_pdh_label
    lbl_pdh := makeLabel(prevDayHigh, i_pdh_label_text, i_pdh_show_price)
if i_show_pdl_label
    lbl_pdl := makeLabel(prevDayLow, i_pdl_label_text, i_pdl_show_price)
if i_show_pdvwap_label and showVwap
    lbl_pdvwap := makeLabel(prevDayVwap, i_pdvwap_label_text, i_pdvwap_show_price)
````
