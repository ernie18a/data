# Multirange Indicator Highlighter: Days, Timezone, Color

- url: https://www.tradingview.com/script/UfVM0mb1-Multirange-Indicator-Highlighter-Days-Timezone-Color/
- type: indicator
- pine_id: PUB;baa3587bcf85435a96d1f6917531094c
- version: 1.0

## Description

[i][b]Multirange Indicator Highlighter: Days, Timezone, Color[/b][/i]

This indicator allows you to highlight up to 3 custom time ranges for every single day of the week (Monday–Sunday). It is perfect for marking Killzones, session opens, or specific volatility windows.

[b][i]Key Features:[/i][/b]

Daily Control: Separate toggles and settings for each day (Mon–Sun).
3 Ranges per Day: Independent start/end times and colors for each slot.
Flexible Format: Supports HH:MM input (e.g., 09:30-11:00).
Smart Timezones: Enter city names (e.g., America/New_York) or offsets (e.g., GMT+2) directly.
Compact UI: Clean, one-line settings for easy configuration.

[i][b]How to use:[/b][/i]
 Set your timezone first, then enable the days and ranges you need. Adjust colors and transparency to keep your chart readable.

## Source Code

````pine
//@version=5
indicator("Multirange Indicator Highlighter: Days, Timezone, Color", overlay=true)

// --- GLOBAL SETTINGS ---
tz_input = input.string("GMT+2", "Timezone", group="Global Settings", tooltip="E.g. GMT+2, America/New_York, Europe/Berlin. Use 'GMT' or 'UTC' followed by + or - for offsets.")

// Helper function to remove colons and check time range
is_in_timerange(time_string) =>
    clean_time = str.replace_all(time_string, ":", "")
    not na(time(timeframe.period, clean_time, tz_input))

// --- CORE COLOR LOGIC ---
get_day_color(day_active, on1, r1, c1, on2, r2, c2, on3, r3, c3) =>
    color res = na
    if day_active
        if on1 and is_in_timerange(r1)
            res := c1
        else if on2 and is_in_timerange(r2)
            res := c2
        else if on3 and is_in_timerange(r3)
            res := c3
    res

// --- INPUTS PER DAY ---

// MONDAY
mon_active = input.bool(true, "Monday", group="Monday")
m_o1=input.bool(true,"",inline="m1",group="Monday"), m_r1=input.string("09:00-11:00","Range 1",inline="m1",group="Monday"), m_c1=input.color(color.new(color.blue, 85),"",inline="m1",group="Monday")
m_o2=input.bool(true,"",inline="m2",group="Monday"), m_r2=input.string("12:00-14:00","Range 2",inline="m2",group="Monday"), m_c2=input.color(color.new(color.purple, 85),"",inline="m2",group="Monday")
m_o3=input.bool(true,"",inline="m3",group="Monday"), m_r3=input.string("15:00-17:00","Range 3",inline="m3",group="Monday"), m_c3=input.color(color.new(color.teal, 85),"",inline="m3",group="Monday")

// TUESDAY
tue_active = input.bool(true, "Tuesday", group="Tuesday")
t_o1=input.bool(true,"",inline="t1",group="Tuesday"), t_r1=input.string("09:00-11:00","Range 1",inline="t1",group="Tuesday"), t_c1=input.color(color.new(color.blue, 85),"",inline="t1",group="Tuesday")
t_o2=input.bool(true,"",inline="t2",group="Tuesday"), t_r2=input.string("12:00-14:00","Range 2",inline="t2",group="Tuesday"), t_c2=input.color(color.new(color.purple, 85),"",inline="t2",group="Tuesday")
t_o3=input.bool(true,"",inline="t3",group="Tuesday"), t_r3=input.string("15:00-17:00","Range 3",inline="t3",group="Tuesday"), t_c3=input.color(color.new(color.teal, 85),"",inline="t3",group="Tuesday")

// WEDNESDAY
wed_active = input.bool(true, "Wednesday", group="Wednesday")
w_o1=input.bool(true,"",inline="w1",group="Wednesday"), w_r1=input.string("09:00-11:00","Range 1",inline="w1",group="Wednesday"), w_c1=input.color(color.new(color.blue, 85),"",inline="w1",group="Wednesday")
w_o2=input.bool(true,"",inline="w2",group="Wednesday"), w_r2=input.string("12:00-14:00","Range 2",inline="w2",group="Wednesday"), w_c2=input.color(color.new(color.purple, 85),"",inline="w2",group="Wednesday")
w_o3=input.bool(true,"",inline="w3",group="Wednesday"), w_r3=input.string("15:00-17:00","Range 3",inline="w3",group="Wednesday"), w_c3=input.color(color.new(color.teal, 85),"",inline="w3",group="Wednesday")

// THURSDAY
thu_active = input.bool(true, "Thursday", group="Thursday")
th_o1=input.bool(true,"",inline="th1",group="Thursday"), th_r1=input.string("09:00-11:00","Range 1",inline="th1",group="Thursday"), th_c1=input.color(color.new(color.blue, 85),"",inline="th1",group="Thursday")
th_o2=input.bool(true,"",inline="th2",group="Thursday"), th_r2=input.string("12:00-14:00","Range 2",inline="th2",group="Thursday"), th_c2=input.color(color.new(color.purple, 85),"",inline="th2",group="Thursday")
th_o3=input.bool(true,"",inline="th3",group="Thursday"), th_r3=input.string("15:00-17:00","Range 3",inline="th3",group="Thursday"), th_c3=input.color(color.new(color.teal, 85),"",inline="th3",group="Thursday")

// FRIDAY
fri_active = input.bool(true, "Friday", group="Friday")
f_o1=input.bool(true,"",inline="f1",group="Friday"), f_r1=input.string("09:00-11:00","Range 1",inline="f1",group="Friday"), f_c1=input.color(color.new(color.blue, 85),"",inline="f1",group="Friday")
f_o2=input.bool(true,"",inline="f2",group="Friday"), f_r2=input.string("12:00-14:00","Range 2",inline="f2",group="Friday"), f_c2=input.color(color.new(color.purple, 85),"",inline="f2",group="Friday")
f_o3=input.bool(true,"",inline="f3",group="Friday"), f_r3=input.string("15:00-17:00","Range 3",inline="f3",group="Friday"), f_c3=input.color(color.new(color.teal, 85),"",inline="f3",group="Friday")

// SATURDAY
sat_active = input.bool(false, "Saturday", group="Saturday")
s_o1=input.bool(true,"",inline="s1",group="Saturday"), s_r1=input.string("00:00-00:00","Range 1",inline="s1",group="Saturday"), s_c1=input.color(color.new(color.gray, 85),"",inline="s1",group="Saturday")
s_o2=input.bool(false,"",inline="s2",group="Saturday"), s_r2=input.string("00:00-00:00","Range 2",inline="s2",group="Saturday"), s_c2=input.color(color.new(color.gray, 85),"",inline="s2",group="Saturday")
s_o3=input.bool(false,"",inline="s3",group="Saturday"), s_r3=input.string("00:00-00:00","Range 3",inline="s3",group="Saturday"), s_c3=input.color(color.new(color.gray, 85),"",inline="s3",group="Saturday")

// SUNDAY
sun_active = input.bool(false, "Sunday", group="Sunday")
sn_o1=input.bool(true,"",inline="sn1",group="Sunday"), sn_r1=input.string("00:00-00:00","Range 1",inline="sn1",group="Sunday"), sn_c1=input.color(color.new(color.gray, 85),"",inline="sn1",group="Sunday")
sn_o2=input.bool(false,"",inline="sn2",group="Sunday"), sn_r2=input.string("00:00-00:00","Range 2",inline="sn2",group="Sunday"), sn_c2=input.color(color.new(color.gray, 85),"",inline="sn2",group="Sunday")
sn_o3=input.bool(false,"",inline="sn3",group="Sunday"), sn_r3=input.string("00:00-00:00","Range 3",inline="sn3",group="Sunday"), sn_c3=input.color(color.new(color.gray, 85),"",inline="sn3",group="Sunday")

// --- FINAL RENDERING ---
color final_color = na
if dayofweek == dayofweek.monday
    final_color := get_day_color(mon_active, m_o1, m_r1, m_c1, m_o2, m_r2, m_c2, m_o3, m_r3, m_c3)
else if dayofweek == dayofweek.tuesday
    final_color := get_day_color(tue_active, t_o1, t_r1, t_c1, t_o2, t_r2, t_c2, t_o3, t_r3, t_c3)
else if dayofweek == dayofweek.wednesday
    final_color := get_day_color(wed_active, w_o1, w_r1, w_c1, w_o2, w_r2, w_c2, w_o3, w_r3, w_c3)
else if dayofweek == dayofweek.thursday
    final_color := get_day_color(thu_active, th_o1, th_r1, th_c1, th_o2, th_r2, th_c2, th_o3, th_r3, th_c3)
else if dayofweek == dayofweek.friday
    final_color := get_day_color(fri_active, f_o1, f_r1, f_c1, f_o2, f_r2, f_c2, f_o3, f_r3, f_c3)
else if dayofweek == dayofweek.saturday
    final_color := get_day_color(sat_active, s_o1, s_r1, s_c1, s_o2, s_r2, s_c2, s_o3, s_r3, s_c3)
else if dayofweek == dayofweek.sunday
    final_color := get_day_color(sun_active, sn_o1, sn_r1, sn_c1, sn_o2, sn_r2, sn_c2, sn_o3, sn_r3, sn_c3)

bgcolor(final_color)
````
