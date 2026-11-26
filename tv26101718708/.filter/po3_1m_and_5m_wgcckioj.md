# PO3 1m and 5m

- url: https://www.tradingview.com/script/wGCCKIoJ-PO3-1m-and-5m/
- type: indicator
- pine_id: PUB;675d90966f644789a34a526426a1334c
- version: 1.0

## Description

PO3 1m and 5m
Afiseaza timpul ramas din candelele de 1 si 5 min pentru a putea urmarii PO3

## Source Code

````pine
//@version=5
indicator("Countdown 1m & 5m - Tabel Personalizat", shorttitle="CD 1m/5m", overlay=true, max_labels_count=500)

// ================== SETĂRI PERSONALE ==================
// Poziția tabelului (poți schimba din setări)
table_position_str = input.string("Top Right", "Poziție Tabel", 
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"])

// Culori
color_header_text   = input.color(color.white,  "Culoare text Header")
color_tf_text       = input.color(color.yellow, "Culoare text 1m / 5m")
color_countdown     = input.color(color.lime,   "Culoare Countdown (timp rămas)")

// Dimensiuni font
header_size_str    = input.string("small",  "Dimensiune font Header",     options=["tiny", "small", "normal", "large", "huge"])
tf_size_str        = input.string("normal", "Dimensiune font 1m / 5m",   options=["tiny", "small", "normal", "large", "huge"])
countdown_size_str = input.string("large",  "Dimensiune font Countdown", options=["tiny", "small", "normal", "large", "huge"])

// Convertim textul în poziție și dimensiune reală
get_position(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

get_size(string s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.huge

// ================== FUNCȚIE COUNTDOWN ==================
f_countdown(string tf) =>
    [t_close, t_now] = request.security(syminfo.tickerid, tf, [time_close, timenow])
    
    if not na(t_close) and not na(t_now)
        remaining_ms = t_close - t_now
        if remaining_ms < 0
            "00:00"
        else
            minutes = math.floor(remaining_ms / 60000)
            seconds = math.floor((remaining_ms % 60000) / 1000)
            str.tostring(minutes, "00") + ":" + str.tostring(seconds, "00")
    else
        "00:00"

// ================== COUNTDOWN-URI ==================
cd_1m = f_countdown("1")
cd_5m = f_countdown("5")

// ================== TABEL ==================
var table countdownTable = table.new(position     = get_position(table_position_str),columns      = 2,rows         = 3,bgcolor      = color.new(color.black, 85),border_width = 1,border_color = color.gray)

// Header
table.cell(countdownTable, 0, 0, "TF",        text_color = color_header_text, bgcolor = color.new(color.blue, 60),  text_size = get_size(header_size_str))
table.cell(countdownTable, 1, 0, "Time Left", text_color = color_header_text, bgcolor = color.new(color.blue, 60),  text_size = get_size(header_size_str))

// 1 minut
table.cell(countdownTable, 0, 1, "1m",  text_color = color_tf_text, text_size = get_size(tf_size_str))
table.cell(countdownTable, 1, 1, cd_1m, text_color = color_countdown, text_size = get_size(countdown_size_str), bgcolor = color.new(color.green, 90))

// 5 minute
table.cell(countdownTable, 0, 2, "5m",  text_color = color_tf_text, text_size = get_size(tf_size_str))
table.cell(countdownTable, 1, 2, cd_5m, text_color = color_countdown, text_size = get_size(countdown_size_str), bgcolor = color.new(color.green, 90))
````
