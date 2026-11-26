# Windoo TPO Profile v.6 - S.Grey

- url: https://www.tradingview.com/script/sZ5dczz5/
- type: indicator
- pine_id: PUB;c301d73002594d5cb2322e39ad86e70f
- version: 1.0

## Description

# Windoo TPO Profile

[i]To view only TPO, set the candle opacity to "0." Candles must be 30-minute. The indicator has a limited range due to Tradiview limitations. To increase the range, increase the number of ticks. To view historical TPO, use the Profile Date Range. If you don't set the Sessions Lookback, the indicator will show IB without a profile, which will cause mess on the chart.[/i]

Windoo TPO Profile is a professional Market Profile indicator designed to reveal how the auction process develops throughout each trading session. Instead of focusing exclusively on volume, the indicator measures how much time the market spends at each price level and transforms that information into a Time Price Opportunity (TPO) profile. This allows traders to identify areas of acceptance, rejection, balance, and price discovery with exceptional clarity.

Built around the principles of Auction Market Theory, Windoo TPO Profile helps traders understand where the market considers price to be fair and where imbalances begin to develop. By visualizing the distribution of TPOs across the session, the indicator exposes the underlying structure of the auction and highlights the levels that often become important support, resistance, and decision zones.

At the center of every profile is the Point of Control (POC), automatically calculated as the price level that attracted the highest concentration of TPOs during the session. The indicator also calculates Value Area High (VAH) and Value Area Low (VAL), providing a complete view of where the majority of market activity occurred. These levels can be extended into future sessions, allowing traders to monitor how price reacts to previous areas of value.

Windoo TPO Profile supports both standard exchange sessions and fully customized session definitions. Traders can calculate profiles using their preferred trading hours, apply custom time zones, and even restrict profile generation to specific date ranges. The new Date Range mode allows users to analyze only selected periods of market activity, making the indicator especially useful for backtesting, historical studies, and focused market structure analysis. 

To keep charts clean and efficient, the indicator now includes a Sessions Lookback feature that automatically limits the number of historical profiles displayed. Instead of loading every profile available on the chart, traders can focus only on the most recent sessions that are relevant to current market conditions. 

Profiles can be displayed using traditional Market Profile letters or converted into histogram-style bars. Single Prints are automatically detected and highlighted, helping traders identify areas where price moved aggressively through the auction. These zones often become important references for future support, resistance, and price attraction.

One of the most powerful features of Windoo TPO Profile is its advanced profile projection system. Completed profiles can be extended into future chart space, allowing traders to compare current price action with previous auction structures. The indicator can also track and mark developing Point of Control changes during profile formation, providing valuable insight into shifts in market acceptance and sentiment. 

The indicator includes Initial Balance analysis, session highs and lows, opening and closing references, Value Area shading, extended Single Prints, and fully customizable visualization settings. A Smart Visibility Filter can automatically hide profile-related levels until a minimum amount of session data has formed, preventing incomplete or misleading profile information during the earliest stages of a session.

Whether you trade futures, equities, forex, indices, or cryptocurrencies, Windoo TPO Profile provides a complete Auction Market Theory framework for identifying value, imbalance, market acceptance, and key structural levels. By combining traditional Market Profile concepts with modern customization and advanced filtering tools, the indicator delivers a professional-grade environment for understanding how markets establish and distribute value throughout the trading session.
## Main Features & Settings

### Session Configuration

• **Use Session Time** – Build profiles using custom session hours instead of calendar days.

• **Session Calculation** – Define the exact session start and end times.

• **Show Current Session Profile** – Display the developing profile of the active session in real time.

• **Use Profile Date Range** – Restrict profile generation to a specific historical period.

• **Profile Date From / To** – Select the exact dates for profile analysis.

• **Date Range Includes Full Day** – Automatically includes the complete final day of the selected range.

• **Use Sessions Lookback** – Limit the number of historical profiles displayed on the chart.

• **Sessions Lookback** – Define how many previous sessions remain visible.

• **Use Custom Time Zone** – Calculate profiles using a selected market timezone.

• **Calculation Time Zone** – Choose from major global trading centers including New York, Chicago, London, Berlin, Warsaw, Tokyo, Hong Kong, Sydney, and UTC.

---

### Profile Construction

• **Ticks Number Per TPO** – Controls profile resolution and price row size.

• **Round TPO Levels On Tick Number** – Align profile rows with valid market tick increments.

• **TPO Letters Size** – Choose between Tiny, Small, or Normal TPO letters.

• **Display TPO As Bars** – Convert traditional TPO letters into histogram-style profile bars.

• **Main Profile Letter Spacing** – Adjust spacing between TPO letters for improved readability.

• **Custom TPO Character Set** – Define the characters used to build TPO periods.

---

### Profile Layout & Visibility

• **Extend Yesterday's Levels** – Extend important profile levels into future sessions.

• **Profile Layout Mode** – Choose between Session Width and Fixed Width display modes.

• **Fixed Profile Width** – Define a custom width for all profiles.

• **Show TPO's** – Show or hide profile structures.

• **Don't Show Main Profile** – Hide selected profile structures while preserving important references.

• **Hide Main Profiles From / To** – Define which historical profiles are hidden.

• **Hide Profile Data In Hidden Range** – Hide associated profile levels, labels, and markers.

• **Don't Show Current Session Main Profile** – Hide the developing profile while keeping historical profiles visible.

---

### Smart Visibility Filters

• **Hide Profile Data Until Minimum Bars** – Prevent profile-related levels from appearing until sufficient session data has formed.

• **Minimum Bars Before IB/Open/Close/VA** – Define the minimum number of bars required before displaying Initial Balance, POC, VAH, VAL, Open, Close, and other profile data.

This feature helps eliminate incomplete profile calculations during the earliest stage of a session and keeps charts cleaner during profile development.

---

### Point of Control (POC)

• **Show POC As Line** – Display the Point of Control as a horizontal reference line.

• **POC Color** – Customize POC appearance.

• **POC Line Style** – Choose between Solid, Dashed, or Dotted styles.

---

### Value Area (VAH / VAL)

• **Show Value Areas As Lines** – Display Value Area High and Value Area Low.

• **Value Area Lines Color** – Customize VAH and VAL colors.

• **Show Current VAH/VAL After Hours** – Continue displaying developing Value Area levels beyond session completion.

• **Value Area Line Style** – Select Solid, Dashed, or Dotted lines.

• **Value Area Line Extension** – Extend Value Area levels Left, Right, Both, or disable extensions.

• **Value Area Percent** – Define the percentage of TPO activity used for Value Area calculations.

• **Show Market Profile Calculation Area Background** – Shade the Value Area region.

• **Value Area Background Color** – Customize background appearance.

---

### Initial Balance (IB)

• **Show Initial Balance** – Display the opening balance range of the session.

• **IB Color** – Customize Initial Balance color.

---

### Highs & Lows

• **Show High/Low Levels** – Plot session high and low levels.

• **High and Low Colors** – Customize session extreme colors.

---

### Single Prints

• **Highlight Single Prints** – Automatically identify Single Print zones.

• **Single Prints Color** – Customize Single Print appearance.

• **Extend Single Prints** – Project Single Prints into future price action.

• **Extended Single Prints Transparency** – Adjust transparency of projected Single Print zones.

---

### Extended Profile Letters

• **Extend Profile Letters** – Project completed profiles into future chart space.

• **Extend Current Session Letters** – Project the developing profile in real time.

• **Profiles Back To Extend** – Define how many historical profiles remain extended.

• **Extended Profile Right Offset** – Move projected profiles further right.

• **Extended Column Spacing** – Control spacing between projected profile columns.

• **Extended Profile Background Transparency** – Adjust profile visibility.

• **Show POC Color In Extended Profile** – Highlight the POC row inside projected profiles.

---

### Developing POC Analysis

• **Mark Developing POC Changes** – Highlight changes in the developing Point of Control throughout the session.

• **Start POC Change Markers After TPO Periods** – Define after how many TPO periods POC shift analysis begins.

• **POC Change Marker Letter Color** – Customize marker appearance.

This feature allows traders to monitor how market acceptance evolves throughout the auction and identify important shifts in value development.

---

### Open & Close References

• **Opening Price Color** – Customize opening reference markers.

• **Closing Price Color** – Customize closing reference markers.

---

### Additional Statistics

• **Show Total TPO Label** – Display the total number of TPOs generated within the session.

• **TPO Color (Inside Value Area)** – Color used for TPOs inside the Value Area.

• **TPO Color (Outside Value Area)** – Color used for TPOs outside the Value Area.

---

## Windoo TPO Profile Highlights

✔ Real-Time Developing Market Profile

✔ Historical Session Profiles

✔ Point of Control (POC)

✔ Value Area High (VAH)

✔ Value Area Low (VAL)

✔ Initial Balance (IB)

✔ Session High & Low Levels

✔ Open & Close References

✔ Single Print Detection

✔ Extended Single Print Zones

✔ Extended TPO Profiles

✔ Developing POC Migration Analysis

✔ Value Area Background Shading

✔ Multi-Timezone Support

✔ Custom Session Definitions

✔ Date Range Profile Analysis

✔ Sessions Lookback Filtering

✔ Smart Minimum-Bar Visibility System

✔ Histogram and Traditional TPO Modes

✔ Fully Customizable Colors and Layouts

✔ Auction Market Theory Framework

## Source Code

````pine

//@version=6
indicator("Windoo TPO Profile v.6 - S.Grey", overlay=true, max_bars_back=5000, max_boxes_count = 500, max_lines_count = 500)

use_session_time = input.bool(true, "Use Session Time", group="Session configuration")
session = input.session("0930-1600", title="Session calculation", group="Session configuration")
show_current_session_profile = input.bool(true, "Show Current Session Profile", group="Session configuration")
use_profile_date_range = input.bool(false, "Use Profile Date Range", group="Session configuration")
profile_date_from = input.time(timestamp("18 May 2026 00:00 +0000"), "Profile Date From", group="Session configuration")
profile_date_to = input.time(timestamp("23 May 2026 23:59 +0000"), "Profile Date To", group="Session configuration")
profile_date_to_full_day = input.bool(true, "Date Range To Includes Full Day", group="Session configuration")
use_session_lookback = input.bool(true, "Use Sessions Lookback When Date Range Off", group="Session configuration")
sessions_lookback = input.int(6, "Sessions Lookback", group="Session configuration", minval=1, maxval=50)
use_custom_timezone = input.bool(false, "Use Custom Time Zone", group="Session configuration")
profile_timezone = input.string("America/New_York", "Calculation Time Zone", options=["Etc/UTC", "America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Warsaw", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney"], group="Session configuration")

tick_size = input.int(150, "Ticks number per tpo", group="Global Options") * syminfo.mintick
round_values = input.bool(true, "Round TPO levels on Tick number", group="Global Options")
letters_size = input.string("Small", options=["Normal", "Small", "Tiny"], title="TPO letters size", group="Global Options")
print_as_bars = input.bool(false, "Display TPO as bars", group="Global Options")
extend_levels = input.bool(true, "Extend yesterday's levels", group="Global Options")
profile_layout_mode = input.string("Session Date", "Profile Layout Mode", options=["Session Date", "Fixed Width"], group="Global Options")
fixed_profile_width = input.int(24, "Fixed Profile Width", group="Global Options", minval=1, maxval=200)
show_va_background = input.bool(true, "Show Market Profile calculation area background", group="Global Options")
va_bg_color=input.color(#2962ff10, "Value area background color", group="Global Options")
show_histogram = input.bool(true, "Show TPO's", group="Global Options")
dont_show_main_profile = input.bool(false, "Don't Show Main Profile", group="Global Options")
main_profiles_hide_from = input.int(1, "Hide Main Profiles From", group="Global Options", minval=1, maxval=50)
main_profiles_hide_to = input.int(1, "Hide Main Profiles To", group="Global Options", minval=1, maxval=50)
hide_profile_data_in_range = input.bool(false, "Hide Profile Data In Hidden Range", group="Global Options")
dont_show_current_main_profile = input.bool(false, "Don't Show Current Session Main Profile", group="Global Options")
hide_data_when_profile_too_small = input.bool(true, "Hide Profile Data Until Minimum Bars", group="Global Options")
minimum_bars_for_profile_data = input.int(3, "Minimum Bars Before IB/Open/Close/VA", group="Global Options", minval=1, maxval=100)
show_total_tpo_label = input.bool(true, "Show Total TPO Label", group="Global Options")
tpo_va_color = input.color(color.red, "TPO Color (in VA)", group="Global Options")
tpo_nova_color = input.color(color.orange, "TPO Color (out of VA)", group="Global Options")
limits_color=input.color(color.black, "High and Low colors", group="Highs & Lows")
show_high_low = input.bool(false, "Show high/low levels", group="Highs & Lows")

extend_profile_letters = input.bool(false, "Extend Profile Letters", group="Extended Profile Letters")
extend_current_profile_letters = input.bool(false, "Extend Current Session Letters", group="Extended Profile Letters")
extended_profiles_back = input.int(1, "Profiles Back To Extend", group="Extended Profile Letters", minval=1, maxval=20)
extended_profile_right_offset = input.int(0, "Extended Profile Right Offset", group="Extended Profile Letters", minval=0, maxval=200)
extended_column_spacing = input.float(0.2, "Extended Column Spacing", group="Extended Profile Letters", minval=0, maxval=1, step=0.1)
extended_profile_trans = input.int(75, "Extended Profile Background Transparency", group="Extended Profile Letters", minval=0, maxval=100)
show_extended_profile_poc_color = input.bool(true, "Show POC Color In Extended Profile", group="Extended Profile Letters")
show_poc_change_markers = input.bool(false, "Mark Developing POC Changes", group="Extended Profile Letters")
poc_change_start_periods = input.int(2, "Start POC Change Markers After TPO Periods", group="Extended Profile Letters", minval=1, maxval=20)
poc_change_marker_color = input.color(color.black, "POC Change Marker Letter Color", group="Extended Profile Letters")

poc_col = input.color(#b58900, "POC color", group="POC Options")
show_poc = input.bool(true, "Show POC as line", group="POC Options")
poc_line_style_input = input.string("Solid", "POC Line Style", options=["Solid", "Dotted", "Dashed"], group="POC Options")
show_initial_balance = input.bool(true, "Show Initial Balance", group="IB")
ib_color = input.color(color.black, "IB Color", group="IB")

va_line_color = input.color(#2962ff, "Value area lines color", group="Value area options")
show_va_lines = input.bool(true, "Show value areas as lines",group="Value area options")
show_current_va_after_hours = input.float(2.0, "Show Current VAH/VAL After Hours", minval=0.0, step=0.5, group="Value area options")
va_line_style_input = input.string("Solid", "Value Area Line Style", options=["Solid", "Dotted", "Dashed"], group="Value area options")
va_line_extend_input = input.string("Right", "Value Area Line Extension", options=["None", "Left", "Right", "Both"], group="Value area options")
va_percent = input.int(68, "Value area percent",group="Value area options") / 100

show_singleprints = input.bool(true, "Highlight Single prints", group="Single prints")
sp_col = input.color(#ec407a, "Single prints color", group="Single prints")
extend_sp = input.bool(false, "Extend single prints", group="Single prints")
sp_ext_trans = input.int(80, "Extended single prints transparency", group="Single prints", minval=0, maxval=100)
open_color = input.color(#ff0000, "Opening price color", group="Open/Close")
close_color = input.color(#ff0000, "Closing price color", group="Open/Close")

tpo_spacing = input.float(0.0, "Main Profile Letter Spacing", minval=0, maxval=1, step=0.1)
tpo_spacing_units = int(math.round(tpo_spacing * 10))
extended_column_spacing_units = int(math.round(extended_column_spacing * 10))
extended_column_width_units = math.max(1, 1 + tpo_spacing_units + extended_column_spacing_units)
show_main_profile = true
va_line_style_value = va_line_style_input == "Dotted" ? line.style_dotted : va_line_style_input == "Dashed" ? line.style_dashed : line.style_solid
va_line_extend_value = va_line_extend_input == "Left" ? extend.left : va_line_extend_input == "Right" ? extend.right : va_line_extend_input == "Both" ? extend.both : extend.none
poc_line_style_value = poc_line_style_input == "Dotted" ? line.style_dotted : poc_line_style_input == "Dashed" ? line.style_dashed : line.style_solid

calculation_timezone = use_custom_timezone ? profile_timezone : syminfo.timezone
profile_range_from = math.min(profile_date_from, profile_date_to)
profile_range_to_input = math.max(profile_date_from, profile_date_to)
profile_range_to_full_day = timestamp(calculation_timezone, year(profile_range_to_input, calculation_timezone), month(profile_range_to_input, calculation_timezone), dayofmonth(profile_range_to_input, calculation_timezone), 23, 59)
profile_range_to = profile_date_to_full_day ? profile_range_to_full_day : profile_range_to_input
in_profile_date_range(check_time) =>
    not use_profile_date_range or (check_time >= profile_range_from and check_time <= profile_range_to)
inSession(sess, tz) => na(time(timeframe.period, sess, tz)) == false
daily_boundary = ta.change(time("D", "0000-2359", calculation_timezone)) != 0
sess = inSession(session, calculation_timezone)
session_over = use_session_time ? sess[1] and not sess : daily_boundary
session_start = use_session_time ? sess and not sess[1] : daily_boundary
current_session_active = use_session_time ? sess : true
draw_current_session_profile = show_current_session_profile and barstate.islast and current_session_active

letters = input.string("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@$€£{}[]()*+-/=%&?!", "TPO letters")

letters_size_value = letters_size == "Small" ? size.small : letters_size == "Normal" ? size.normal : size.tiny

bars_nb = 0

var line topline = na
var line botline = na
var line vah_line = na
var line val_line = na
var line poc = na

//var max_score = 0
var poc_price = 0.0
var bars_score = array.new<int>(bars_nb)
var profile_bars = array.new<box>(bars_nb)
var letter_bars = array.new<string>(bars_nb)
var extension_letter_bars = array.new<string>(bars_nb)
var current_profile_boxes = array.new<box>()
var current_profile_lines = array.new<line>()
var current_profile_labels = array.new<label>()
var main_profile_boxes = array.new<box>()
var main_profile_ids = array.new<int>()
var main_profile_colors = array.new<color>()
var profile_data_lines = array.new<line>()
var profile_data_line_ids = array.new<int>()
var profile_data_line_colors = array.new<color>()
var profile_data_line_can_show = array.new<bool>()
var profile_data_labels = array.new<label>()
var profile_data_label_ids = array.new<int>()
var profile_data_label_colors = array.new<color>()
var profile_data_label_can_show = array.new<bool>()
var profile_data_boxes = array.new<box>()
var profile_data_box_ids = array.new<int>()
var profile_data_box_colors = array.new<color>()
var profile_data_box_can_show = array.new<bool>()
var extended_profile_bars = array.new<box>()
var extended_profile_ids = array.new<int>()
var poc_change_marker_boxes = array.new<box>()
var poc_change_marker_ids = array.new<int>()
var profile_sequence = 0
var vah_offset = 0
var val_offset = 0

spaces_string(n) =>
    r = ""
    if n > 0
        for i=0 to n
            r += " "
    r

find_h(start_x, end_x) =>
    h = high[start_x]
    for i=start_x to end_x
        if high[i] > h
            h := high[i]
    h
find_l(start_x, end_x) =>
    l = low[start_x]
    for i=start_x to end_x
        if low[i] < l
            l := low[i]
    l
count_tpo(x, y) =>
    r = 0
    for i=x to y
        r +=  array.get(bars_score,i)
    r

biggest_tpo(x, y) =>
    t1 = array.get(bars_score, x)
    t2 = array.get(bars_score, y)
    t1 >= t2 ? "h": "l"

in_price_row(row_top, row_bottom, offset) =>
    (high[offset] <= row_top and high[offset] >= row_bottom) or (low[offset] <= row_top and low[offset] >= row_bottom) or (high[offset] > row_top and low[offset] < row_bottom)

var session_candles_count = 0
var poc_position = 0
var total_tpo = 0
var open_price = open

if session_start and not session_over
    session_candles_count := 0
    open_price := open
    if hide_data_when_profile_too_small
        if not na(vah_line)
            line.set_extend(vah_line, extend.none)
        if not na(val_line)
            line.set_extend(val_line, extend.none)
        if not na(poc)
            line.set_extend(poc, extend.none)
        if not na(topline)
            line.set_extend(topline, extend.none)
        if not na(botline)
            line.set_extend(botline, extend.none)

min_extended_profile_id = profile_sequence - extended_profiles_back + 1
extended_profile_index = array.size(extended_profile_bars) - 1
while extended_profile_index >= 0
    extended_profile_id_for_cleanup = array.get(extended_profile_ids, extended_profile_index)
    remove_completed_extension = extended_profile_id_for_cleanup <= profile_sequence and (not extend_profile_letters or extended_profile_id_for_cleanup < min_extended_profile_id)
    remove_current_extension = extended_profile_id_for_cleanup > profile_sequence
    if remove_completed_extension or remove_current_extension
        box.delete(array.get(extended_profile_bars, extended_profile_index))
        array.remove(extended_profile_bars, extended_profile_index)
        array.remove(extended_profile_ids, extended_profile_index)
    extended_profile_index -= 1

poc_change_marker_index = array.size(poc_change_marker_boxes) - 1
while poc_change_marker_index >= 0
    poc_change_marker_id_for_cleanup = array.get(poc_change_marker_ids, poc_change_marker_index)
    remove_completed_poc_marker = poc_change_marker_id_for_cleanup <= profile_sequence and (not extend_profile_letters or not show_poc_change_markers or poc_change_marker_id_for_cleanup < min_extended_profile_id)
    remove_current_poc_marker = poc_change_marker_id_for_cleanup > profile_sequence
    if remove_completed_poc_marker or remove_current_poc_marker
        box.delete(array.get(poc_change_marker_boxes, poc_change_marker_index))
        array.remove(poc_change_marker_boxes, poc_change_marker_index)
        array.remove(poc_change_marker_ids, poc_change_marker_index)
    poc_change_marker_index -= 1

if (draw_current_session_profile or session_over) and array.size(current_profile_boxes) > 0
    for i=0 to array.size(current_profile_boxes)-1
        box.delete(array.get(current_profile_boxes, i))
    array.clear(current_profile_boxes)
if (draw_current_session_profile or session_over) and array.size(current_profile_lines) > 0
    for i=0 to array.size(current_profile_lines)-1
        line.delete(array.get(current_profile_lines, i))
    array.clear(current_profile_lines)
if (draw_current_session_profile or session_over) and array.size(current_profile_labels) > 0
    for i=0 to array.size(current_profile_labels)-1
        label.delete(array.get(current_profile_labels, i))
    array.clear(current_profile_labels)

current_session_below_profile_data_minimum = hide_data_when_profile_too_small and current_session_active and session_candles_count + 1 < minimum_bars_for_profile_data
if barstate.islast and current_session_below_profile_data_minimum
    if not na(vah_line)
        line.set_color(vah_line, #00000000)
        line.set_extend(vah_line, extend.none)
    if not na(val_line)
        line.set_color(val_line, #00000000)
        line.set_extend(val_line, extend.none)
    if not na(poc)
        line.set_color(poc, #00000000)
        line.set_extend(poc, extend.none)
    if not na(topline)
        line.set_color(topline, #00000000)
        line.set_extend(topline, extend.none)
    if not na(botline)
        line.set_color(botline, #00000000)
        line.set_extend(botline, extend.none)
    if array.size(current_profile_boxes) > 0
        for i=0 to array.size(current_profile_boxes)-1
            box.delete(array.get(current_profile_boxes, i))
        array.clear(current_profile_boxes)
    if array.size(current_profile_lines) > 0
        for i=0 to array.size(current_profile_lines)-1
            line.delete(array.get(current_profile_lines, i))
        array.clear(current_profile_lines)
    if array.size(current_profile_labels) > 0
        for i=0 to array.size(current_profile_labels)-1
            label.delete(array.get(current_profile_labels, i))
        array.clear(current_profile_labels)

if barstate.islast
    hide_from = math.min(main_profiles_hide_from, main_profiles_hide_to)
    hide_to = math.max(main_profiles_hide_from, main_profiles_hide_to)
    if array.size(main_profile_boxes) > 0
        for i=0 to array.size(main_profile_boxes)-1
            main_profile_back = profile_sequence - array.get(main_profile_ids, i) + 1
            hide_main_profile_box = not show_main_profile or not show_histogram or (dont_show_main_profile and main_profile_back >= hide_from and main_profile_back <= hide_to)
            box.set_text_color(array.get(main_profile_boxes, i), hide_main_profile_box ? #00000000 : array.get(main_profile_colors, i))
    if array.size(profile_data_lines) > 0
        for i=0 to array.size(profile_data_lines)-1
            profile_data_back = profile_sequence - array.get(profile_data_line_ids, i) + 1
            hide_profile_data = not array.get(profile_data_line_can_show, i) or (dont_show_main_profile and hide_profile_data_in_range and profile_data_back >= hide_from and profile_data_back <= hide_to)
            line.set_color(array.get(profile_data_lines, i), hide_profile_data ? #00000000 : array.get(profile_data_line_colors, i))
    if array.size(profile_data_labels) > 0
        for i=0 to array.size(profile_data_labels)-1
            profile_data_back = profile_sequence - array.get(profile_data_label_ids, i) + 1
            hide_profile_data = not array.get(profile_data_label_can_show, i) or (dont_show_main_profile and hide_profile_data_in_range and profile_data_back >= hide_from and profile_data_back <= hide_to)
            label.set_textcolor(array.get(profile_data_labels, i), hide_profile_data ? #00000000 : array.get(profile_data_label_colors, i))
    if array.size(profile_data_boxes) > 0
        for i=0 to array.size(profile_data_boxes)-1
            profile_data_back = profile_sequence - array.get(profile_data_box_ids, i) + 1
            hide_profile_data = not array.get(profile_data_box_can_show, i) or (dont_show_main_profile and hide_profile_data_in_range and profile_data_back >= hide_from and profile_data_back <= hide_to)
            box.set_bgcolor(array.get(profile_data_boxes, i), hide_profile_data ? #00000000 : array.get(profile_data_box_colors, i))

draw_current_profile_allowed = not hide_data_when_profile_too_small or session_candles_count + 1 >= minimum_bars_for_profile_data
draw_profile_event = (session_over and session_candles_count > 1) or (draw_current_session_profile and draw_current_profile_allowed)
draw_profile_time = session_over ? time[1] : time
draw_profile_is_current = draw_current_session_profile and not session_over
draw_profile_range_time = draw_profile_is_current ? time : draw_profile_time
draw_profile_in_date_range = in_profile_date_range(draw_profile_range_time)

//if candle_offset == candles_nb -1
if draw_profile_event and draw_profile_in_date_range
    is_completed_profile = session_over
    profile_start_offset = is_completed_profile ? 1 : 0
    profile_end_offset = session_candles_count
    profile_bar_count = session_candles_count + (is_completed_profile ? 0 : 1)
    if is_completed_profile
        profile_sequence += 1
    profile_visibility_id = is_completed_profile ? profile_sequence : profile_sequence + 1
    hide_from = math.min(main_profiles_hide_from, main_profiles_hide_to)
    hide_to = math.max(main_profiles_hide_from, main_profiles_hide_to)
    main_profile_back_for_draw = is_completed_profile ? 1 : 0
    hide_main_profile_for_draw = (is_completed_profile and dont_show_main_profile and main_profile_back_for_draw >= hide_from and main_profile_back_for_draw <= hide_to) or (not is_completed_profile and dont_show_current_main_profile)
    ext = extend_levels and is_completed_profile ? extend.right: extend.none
    if extend_levels and is_completed_profile
        if not na(vah_line)
            line.set_extend(vah_line, extend.none)
        if not na(val_line)
            line.set_extend(val_line, extend.none)
        if not na(poc)
            line.set_extend(poc, extend.none)
        if not na(topline)
            line.set_extend(topline, extend.none)
        if not na(botline)
            line.set_extend(botline, extend.none)
        
    max_score = 0
    total_tpo := 0
    h = find_h(profile_start_offset, profile_end_offset)
    highest=h
    l = find_l(profile_start_offset, profile_end_offset)
    if round_values
        h := h+tick_size - (h % tick_size)
        l := l - (l % tick_size)
    bars_nb := math.max(1, int(math.ceil((h-l) / tick_size)))
    main_profile_has_enough_data = profile_bar_count >= minimum_bars_for_profile_data and bars_nb > 1
    main_profile_can_draw = show_main_profile and show_histogram and not hide_main_profile_for_draw and main_profile_has_enough_data
    show_profile_data_for_draw = not hide_data_when_profile_too_small or main_profile_can_draw
    box_width = (h-l) / bars_nb
    profile_right = is_completed_profile ? bar_index - 1 : bar_index
    profile_display_width = profile_layout_mode == "Fixed Width" ? fixed_profile_width : profile_bar_count
    profile_left = profile_right - profile_display_width + 1
    profile_close = is_completed_profile ? close[1] : close
    array.clear(profile_bars)
    array.clear(bars_score)
    array.clear(letter_bars)
    array.clear(extension_letter_bars)
    created_poc_for_profile = false
    created_high_low_for_profile = false
    int poc_line_can_show_index = na
    int topline_can_show_index = na
    int botline_can_show_index = na

    if show_main_profile and show_profile_data_for_draw and show_poc
        poc := line.new(profile_left, 0.0, profile_right, 0.0, color=poc_col, width=2, style=poc_line_style_value, extend=ext)
        created_poc_for_profile := true
        if not is_completed_profile
            array.push(current_profile_lines, poc)
        else
            array.push(profile_data_lines, poc)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, poc_col)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
            poc_line_can_show_index := array.size(profile_data_line_can_show) - 1
    if show_main_profile and show_profile_data_for_draw and show_high_low
        topline := line.new(profile_left, h, profile_right, h, color=limits_color, extend=ext)
        botline := line.new(profile_left, l, profile_right, l, color=limits_color, extend=ext)
        created_high_low_for_profile := true
        if not is_completed_profile
            array.push(current_profile_lines, topline)
            array.push(current_profile_lines, botline)
        else
            array.push(profile_data_lines, topline)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, limits_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
            topline_can_show_index := array.size(profile_data_line_can_show) - 1
            array.push(profile_data_lines, botline)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, limits_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
            botline_can_show_index := array.size(profile_data_line_can_show) - 1

    // TPO calculation
    for i=0 to bars_nb-1
        tpo_letters = ""
        extension_tpo_letters = ""
        score = 0
        for x=profile_start_offset to profile_end_offset
            in_bar = (high[x] <= h and high[x] >= h-box_width) or (low[x] <= h and low[x] >= h-box_width) or (high[x] > h and low[x] < h-box_width)
            letter_index = (profile_end_offset - x) % str.length(letters)
            tpo_letter = str.substring(letters, letter_index, letter_index + 1)
            if in_bar
                score += 1
                if x <= session_candles_count
                    tpo_letters := tpo_letter+spaces_string(tpo_spacing_units)+tpo_letters
            extension_tpo_letters := (in_bar ? tpo_letter : " ")+spaces_string(tpo_spacing_units + extended_column_spacing_units)+extension_tpo_letters
                
        if score >= max_score
            max_score := score
            poc_price :=  h - (box_width/2)
            poc_position := i
        
        if show_main_profile and show_profile_data_for_draw and show_poc
            line.set_y1(poc, poc_price)
            line.set_y2(poc, poc_price)
        if print_as_bars
            tpo_letters := ""
        profile_row_width = profile_layout_mode == "Fixed Width" ? math.min(profile_display_width, math.max(1, score)) : score
        profile_box = box.new(profile_left, h, profile_left + profile_row_width - 1, h-box_width, text=tpo_letters, text_size=letters_size_value, text_color=tpo_va_color, text_halign=text.align_left, text_formatting=text.format_bold, bgcolor=#00000000, border_color=#00000000)
        array.insert(profile_bars,i, profile_box)
        if not is_completed_profile
            array.push(current_profile_boxes, profile_box)
        array.insert(bars_score, i, score)
        array.insert(letter_bars, i, tpo_letters)
        array.insert(extension_letter_bars, i, extension_tpo_letters)
        h -= box_width
        total_tpo += score

    main_profile_has_enough_data := profile_bar_count >= minimum_bars_for_profile_data and bars_nb > 1 and total_tpo >= minimum_bars_for_profile_data
    main_profile_can_draw := show_main_profile and show_histogram and not hide_main_profile_for_draw and main_profile_has_enough_data
    show_profile_data_for_draw := not hide_data_when_profile_too_small or main_profile_can_draw
    if hide_data_when_profile_too_small and not show_profile_data_for_draw
        if created_poc_for_profile
            line.set_color(poc, #00000000)
            line.set_extend(poc, extend.none)
            if is_completed_profile and not na(poc_line_can_show_index)
                array.set(profile_data_line_can_show, poc_line_can_show_index, false)
        if created_high_low_for_profile
            line.set_color(topline, #00000000)
            line.set_color(botline, #00000000)
            line.set_extend(topline, extend.none)
            line.set_extend(botline, extend.none)
            if is_completed_profile and not na(topline_can_show_index)
                array.set(profile_data_line_can_show, topline_can_show_index, false)
            if is_completed_profile and not na(botline_can_show_index)
                array.set(profile_data_line_can_show, botline_can_show_index, false)

    // VA Calculation
    vah_price = 0.0
    val_price = 0.0
    vah_offset := poc_position > 0 ? poc_position -1 : poc_position
    val_offset := poc_position < bars_nb -1 ? poc_position +1 : poc_position

    for i=0 to bars_nb-1
        d = vah_offset == 0 ? "l" : val_offset == bars_nb-1 ? "h" : biggest_tpo(vah_offset, val_offset)
        if d == "h"
            vah_offset := vah_offset > 0 ? vah_offset -1 : vah_offset
        else
            val_offset := val_offset < bars_nb-1 ? val_offset +1 : val_offset
        if count_tpo(vah_offset, val_offset) / total_tpo >= va_percent
            break

    vah_price := box.get_top(array.get(profile_bars, vah_offset))-(box_width/2)
    val_price := box.get_bottom(array.get(profile_bars, val_offset))+(box_width/2)

    // Set tpo colors
    for i=0 to bars_nb-1
        bar_col = #00000000
        profile_base_text_col =  (i > vah_offset and i < val_offset ? tpo_va_color : tpo_nova_color)
        extended_text_col = val_offset == i or vah_offset == i ? va_line_color : (poc_position == i and show_extended_profile_poc_color) ? poc_col : (array.get(bars_score, i) == 1 and show_singleprints) ? sp_col : profile_base_text_col
        text_col = val_offset == i or vah_offset == i ? va_line_color : poc_position == i ? poc_col : (array.get(bars_score, i) == 1 and show_singleprints) ? sp_col : profile_base_text_col
        if hide_main_profile_for_draw or not show_main_profile or not show_histogram or (hide_data_when_profile_too_small and not main_profile_has_enough_data)
            text_col := #00000000
        if show_main_profile and show_profile_data_for_draw and not hide_main_profile_for_draw and print_as_bars
            if not extend_sp
                box.set_border_color(array.get(profile_bars, i), text_col)
            box.set_bgcolor(array.get(profile_bars, i), text_col)
        if show_main_profile and show_profile_data_for_draw and not hide_main_profile_for_draw and extend_sp and (array.get(bars_score, i) == 1 and show_singleprints)
            extended_sp_color = color.new(sp_col, transp=sp_ext_trans)
            box.set_right(array.get(profile_bars, i), profile_right)
            box.set_bgcolor(array.get(profile_bars, i), extended_sp_color)
            
        box.set_text_color(array.get(profile_bars, i), text_col)
        if is_completed_profile
            array.push(main_profile_boxes, array.get(profile_bars, i))
            array.push(main_profile_ids, profile_visibility_id)
            array.push(main_profile_colors, extended_text_col)
        can_extend_profile = (is_completed_profile and extend_profile_letters) or (not is_completed_profile and extend_current_profile_letters)
        if can_extend_profile and not print_as_bars and str.length(array.get(letter_bars, i)) > 0
            extended_profile_id = is_completed_profile ? profile_sequence : profile_sequence + 1
            extended_profile_left = profile_right + 1 + extended_profile_right_offset
            extended_profile_right = extended_profile_left + (profile_bar_count * extended_column_width_units) - 1
            extended_profile_box = box.new(extended_profile_left, box.get_top(array.get(profile_bars, i)), extended_profile_right, box.get_bottom(array.get(profile_bars, i)), text=array.get(extension_letter_bars, i), text_size=letters_size_value, text_color=extended_text_col, text_halign=text.align_left, text_font_family=font.family_monospace, text_formatting=text.format_bold, bgcolor=#00000000, border_color=#00000000)
            array.push(extended_profile_bars, extended_profile_box)
            array.push(extended_profile_ids, extended_profile_id)

    can_mark_poc_changes = ((is_completed_profile and extend_profile_letters) or (not is_completed_profile and extend_current_profile_letters)) and show_poc_change_markers and not print_as_bars
    if can_mark_poc_changes
        marker_profile_id = is_completed_profile ? profile_sequence : profile_sequence + 1
        marker_profile_left = profile_right + 1 + extended_profile_right_offset
        marker_profile_right = marker_profile_left + (profile_bar_count * extended_column_width_units) - 1
        marker_start_period = math.min(profile_bar_count - 1, math.max(1, poc_change_start_periods))
        int last_developing_poc = na
        for period=0 to profile_bar_count-1
            period_end_offset = profile_end_offset - period
            developing_max_score = -1
            developing_poc_position = 0
            for row=0 to bars_nb-1
                row_score = 0
                row_top = box.get_top(array.get(profile_bars, row))
                row_bottom = box.get_bottom(array.get(profile_bars, row))
                for x=period_end_offset to profile_end_offset
                    if in_price_row(row_top, row_bottom, x)
                        row_score += 1
                if row_score >= developing_max_score
                    developing_max_score := row_score
                    developing_poc_position := row
            if period >= marker_start_period and not na(last_developing_poc) and developing_poc_position != last_developing_poc
                marker_letter = str.substring(letters, period % str.length(letters), period % str.length(letters) + 1)
                marker_text = ""
                for marker_period=0 to profile_bar_count-1
                    marker_text += (marker_period == period ? marker_letter : " ")+spaces_string(tpo_spacing_units + extended_column_spacing_units)
                poc_change_marker_box = box.new(marker_profile_left, box.get_top(array.get(profile_bars, developing_poc_position)), marker_profile_right, box.get_bottom(array.get(profile_bars, developing_poc_position)), text=marker_text, text_size=letters_size_value, text_color=poc_change_marker_color, text_halign=text.align_left, text_font_family=font.family_monospace, text_formatting=text.format_bold, bgcolor=#00000000, border_color=#00000000)
                array.push(poc_change_marker_boxes, poc_change_marker_box)
                array.push(poc_change_marker_ids, marker_profile_id)
            last_developing_poc := developing_poc_position
        
    //plot vah/val
    current_va_delay_bars = int(math.ceil((show_current_va_after_hours * 3600) / timeframe.in_seconds(timeframe.period)))
    show_current_va_lines = not is_completed_profile and profile_bar_count >= current_va_delay_bars
    if show_main_profile and show_profile_data_for_draw and show_va_lines and (is_completed_profile or show_current_va_lines)
        vah_line := line.new(profile_left, vah_price, profile_right, vah_price, color=va_line_color, style=va_line_style_value, extend=va_line_extend_value)
        val_line := line.new(profile_left, val_price, profile_right, val_price, color=va_line_color, style=va_line_style_value, extend=va_line_extend_value)
        if not is_completed_profile
            array.push(current_profile_lines, vah_line)
            array.push(current_profile_lines, val_line)
        else
            array.push(profile_data_lines, vah_line)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, va_line_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
            array.push(profile_data_lines, val_line)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, va_line_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)

    if show_main_profile and show_profile_data_for_draw
        open_label = label.new(profile_left - 1, open_price, text="o", style=label.style_none, textcolor=open_color)
        if not is_completed_profile
            array.push(current_profile_labels, open_label)
        else
            array.push(profile_data_labels, open_label)
            array.push(profile_data_label_ids, profile_visibility_id)
            array.push(profile_data_label_colors, open_color)
            array.push(profile_data_label_can_show, show_profile_data_for_draw)
    if show_main_profile and show_profile_data_for_draw
        close_label = label.new(profile_left - 1, profile_close, text="c", style=label.style_none, textcolor=close_color)
        if not is_completed_profile
            array.push(current_profile_labels, close_label)
        else
            array.push(profile_data_labels, close_label)
            array.push(profile_data_label_ids, profile_visibility_id)
            array.push(profile_data_label_colors, close_color)
            array.push(profile_data_label_can_show, show_profile_data_for_draw)
    
    if show_main_profile and show_profile_data_for_draw
        open_line = line.new(profile_left - 1, open_price, profile_left, open_price, color=open_color, width=3)
        close_line = line.new(profile_left - 1, profile_close, profile_left, profile_close, color=close_color, width=3)
        if not is_completed_profile
            array.push(current_profile_lines, open_line)
            array.push(current_profile_lines, close_line)
        else
            array.push(profile_data_lines, open_line)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, open_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
            array.push(profile_data_lines, close_line)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, close_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
    
    if show_main_profile and show_profile_data_for_draw and show_initial_balance and profile_bar_count > 1
        ibh = high[session_candles_count] > high[session_candles_count-1] ? high[session_candles_count] : high[session_candles_count-1]
        ibl = low[session_candles_count] < low[session_candles_count-1] ? low[session_candles_count] : low[session_candles_count-1]
        ib_line = line.new(profile_left, ibh, profile_left, ibl, color=ib_color, width=2)
        if not is_completed_profile
            array.push(current_profile_lines, ib_line)
        else
            array.push(profile_data_lines, ib_line)
            array.push(profile_data_line_ids, profile_visibility_id)
            array.push(profile_data_line_colors, ib_color)
            array.push(profile_data_line_can_show, show_profile_data_for_draw)
    if show_main_profile and show_profile_data_for_draw and show_va_background
        va_background_box = box.new(profile_left, vah_price, profile_right, val_price, bgcolor=va_bg_color, border_color=#00000000)
        if not is_completed_profile
            array.push(current_profile_boxes, va_background_box)
        else
            array.push(profile_data_boxes, va_background_box)
            array.push(profile_data_box_ids, profile_visibility_id)
            array.push(profile_data_box_colors, va_bg_color)
            array.push(profile_data_box_can_show, show_profile_data_for_draw)
    if show_main_profile and show_profile_data_for_draw and show_total_tpo_label
        total_tpo_label = label.new(profile_right-(profile_display_width/2), highest,text=str.tostring(total_tpo)+" TPO\n", style=label.style_none, textcolor=tpo_va_color, size=size.small)
        if not is_completed_profile
            array.push(current_profile_labels, total_tpo_label)
        else
            array.push(profile_data_labels, total_tpo_label)
            array.push(profile_data_label_ids, profile_visibility_id)
            array.push(profile_data_label_colors, tpo_va_color)
            array.push(profile_data_label_can_show, show_profile_data_for_draw)

use_session_lookback_filter = not use_profile_date_range and use_session_lookback
lookback_min_profile_id = profile_sequence - sessions_lookback + 1
if use_session_lookback_filter and profile_sequence > sessions_lookback
    main_profile_index = array.size(main_profile_boxes) - 1
    while main_profile_index >= 0
        if array.get(main_profile_ids, main_profile_index) < lookback_min_profile_id
            box.delete(array.get(main_profile_boxes, main_profile_index))
            array.remove(main_profile_boxes, main_profile_index)
            array.remove(main_profile_ids, main_profile_index)
            array.remove(main_profile_colors, main_profile_index)
        main_profile_index -= 1

    profile_data_line_index = array.size(profile_data_lines) - 1
    while profile_data_line_index >= 0
        if array.get(profile_data_line_ids, profile_data_line_index) < lookback_min_profile_id
            line.delete(array.get(profile_data_lines, profile_data_line_index))
            array.remove(profile_data_lines, profile_data_line_index)
            array.remove(profile_data_line_ids, profile_data_line_index)
            array.remove(profile_data_line_colors, profile_data_line_index)
            array.remove(profile_data_line_can_show, profile_data_line_index)
        profile_data_line_index -= 1

    profile_data_label_index = array.size(profile_data_labels) - 1
    while profile_data_label_index >= 0
        if array.get(profile_data_label_ids, profile_data_label_index) < lookback_min_profile_id
            label.delete(array.get(profile_data_labels, profile_data_label_index))
            array.remove(profile_data_labels, profile_data_label_index)
            array.remove(profile_data_label_ids, profile_data_label_index)
            array.remove(profile_data_label_colors, profile_data_label_index)
            array.remove(profile_data_label_can_show, profile_data_label_index)
        profile_data_label_index -= 1

    profile_data_box_index = array.size(profile_data_boxes) - 1
    while profile_data_box_index >= 0
        if array.get(profile_data_box_ids, profile_data_box_index) < lookback_min_profile_id
            box.delete(array.get(profile_data_boxes, profile_data_box_index))
            array.remove(profile_data_boxes, profile_data_box_index)
            array.remove(profile_data_box_ids, profile_data_box_index)
            array.remove(profile_data_box_colors, profile_data_box_index)
            array.remove(profile_data_box_can_show, profile_data_box_index)
        profile_data_box_index -= 1

    extended_profile_index_for_lookback = array.size(extended_profile_bars) - 1
    while extended_profile_index_for_lookback >= 0
        extended_profile_id_for_lookback = array.get(extended_profile_ids, extended_profile_index_for_lookback)
        if extended_profile_id_for_lookback <= profile_sequence and extended_profile_id_for_lookback < lookback_min_profile_id
            box.delete(array.get(extended_profile_bars, extended_profile_index_for_lookback))
            array.remove(extended_profile_bars, extended_profile_index_for_lookback)
            array.remove(extended_profile_ids, extended_profile_index_for_lookback)
        extended_profile_index_for_lookback -= 1

    poc_change_marker_index_for_lookback = array.size(poc_change_marker_boxes) - 1
    while poc_change_marker_index_for_lookback >= 0
        poc_change_marker_id_for_lookback = array.get(poc_change_marker_ids, poc_change_marker_index_for_lookback)
        if poc_change_marker_id_for_lookback <= profile_sequence and poc_change_marker_id_for_lookback < lookback_min_profile_id
            box.delete(array.get(poc_change_marker_boxes, poc_change_marker_index_for_lookback))
            array.remove(poc_change_marker_boxes, poc_change_marker_index_for_lookback)
            array.remove(poc_change_marker_ids, poc_change_marker_index_for_lookback)
        poc_change_marker_index_for_lookback -= 1

if session_start
    session_candles_count := 0
    open_price := open

session_candles_count += 1
````
