# Candle Time Highlighter

- url: https://www.tradingview.com/script/NMIg4GhY-Candle-Time-Highlighter/
- type: indicator
- pine_id: PUB;6aee3eca0bd84063ae8e4894b937bb26
- version: 1.0

## Description

How annoying is it to wait for 9:30 or another spesific time, then having to draw a vertical line so you could see what time is the time you actually want? with Candle Time highlighter its as simple as opening the indicator settings coloring your candle, and going on with it!!!

## Source Code

````pine
//@version=5
indicator("Candle Time Highlighter", overlay=true)

// Function to check time
is_time(t_str) =>
    parts = str.split(t_str, ":")
    h = str.tonumber(array.get(parts, 0))
    m = str.tonumber(array.get(parts, 1))
    hour(time, "America/New_York") == h and minute(time, "America/New_York") == m

// --- Dropdown Options ---
var string[] time_options = array.from("09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "13:00", "14:00", "15:00", "15:15", "15:30", "15:45", "16:00")

// --- Slot 1 (Checked) ---
use1   = input.bool(true, "", inline="1")
time1  = input.string("09:30", "Candle Time", options=["09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "13:00", "14:00", "15:00", "15:15", "15:30", "15:45", "16:00"], inline="1")
color1 = input.color(#00FFFF, "", inline="1")

// --- Slot 2 (Unchecked) ---
use2   = input.bool(false, "", inline="2")
time2  = input.string("09:45", "Candle Time", options=["09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "13:00", "14:00", "15:00", "15:15", "15:30", "15:45", "16:00"], inline="2")
color2 = input.color(#FF00FF, "", inline="2")

// --- Slot 3 (Unchecked) ---
use3   = input.bool(false, "", inline="3")
time3  = input.string("10:00", "Candle Time", options=["09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "13:00", "14:00", "15:00", "15:15", "15:30", "15:45", "16:00"], inline="3")
color3 = input.color(#FFFF00, "", inline="3")

// --- Slot 4 (Unchecked) ---
use4   = input.bool(false, "", inline="4")
time4  = input.string("10:15", "Candle Time", options=["09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "13:00", "14:00", "15:00", "15:15", "15:30", "15:45", "16:00"], inline="4")
color4 = input.color(#00FF00, "", inline="4")

// --- Slot 5 (Unchecked) ---
use5   = input.bool(false, "", inline="5")
time5  = input.string("10:30", "Candle Time", options=["09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "13:00", "14:00", "15:00", "15:15", "15:30", "15:45", "16:00"], inline="5")
color5 = input.color(#FF8000, "", inline="5")

// --- Coloring Logic ---
target_color = use1 and is_time(time1) ? color1 : 
               use2 and is_time(time2) ? color2 : 
               use3 and is_time(time3) ? color3 : 
               use4 and is_time(time4) ? color4 : 
               use5 and is_time(time5) ? color5 : na

barcolor(target_color)
````
