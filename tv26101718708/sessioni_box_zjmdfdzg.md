# Sessioni box

- url: https://www.tradingview.com/script/zJMDFDzG/
- type: indicator
- pine_id: PUB;024bc00459464f4083f7d2c1cdb21fed
- version: 1.0

## Description

indica inizio e fine ogni sessione con dei box mod candela .con accavallamento sessioni

## Source Code

````pine
//@version=5
indicator("Sessioni", overlay=true, max_boxes_count=100)

show_lon = input.bool(true,  "Londra")
show_ny  = input.bool(true,  "New York")
show_tok = input.bool(true,  "Tokyo")
show_syd = input.bool(false, "Sydney")

col_lon = input.color(color.new(#2196F3, 80), "Colore Londra")
col_ny  = input.color(color.new(#FF5722, 80), "Colore New York")
col_tok = input.color(color.new(#FFEB3B, 80), "Colore Tokyo")
col_syd = input.color(color.new(#4CAF50, 80), "Colore Sydney")

is_lon = not na(time("1", "0800-1700:23456", "UTC"))
is_ny  = not na(time("1", "1300-2200:23456", "UTC"))
is_tok = not na(time("1", "0000-0900:1234567", "UTC"))
is_syd = not na(time("1", "2100-0600:1234567", "UTC"))

var float lon_hi = na
var float lon_lo = na
var box   lon_bx = na

var float ny_hi = na
var float ny_lo = na
var box   ny_bx = na

var float tok_hi = na
var float tok_lo = na
var box   tok_bx = na

var float syd_hi = na
var float syd_lo = na
var box   syd_bx = na

// LONDRA
if is_lon and not is_lon[1]
    lon_hi := high
    lon_lo := low
    if show_lon
        lon_bx := box.new(bar_index, high, bar_index, low, border_color=color.new(#2196F3, 40), border_width=1, bgcolor=col_lon)

if is_lon
    if high > lon_hi
        lon_hi := high
    if low < lon_lo
        lon_lo := low
    if not na(lon_bx)
        box.set_top(lon_bx, lon_hi)
        box.set_bottom(lon_bx, lon_lo)
        box.set_right(lon_bx, bar_index)

// NEW YORK
if is_ny and not is_ny[1]
    ny_hi := high
    ny_lo := low
    if show_ny
        ny_bx := box.new(bar_index, high, bar_index, low, border_color=color.new(#FF5722, 40), border_width=1, bgcolor=col_ny)

if is_ny
    if high > ny_hi
        ny_hi := high
    if low < ny_lo
        ny_lo := low
    if not na(ny_bx)
        box.set_top(ny_bx, ny_hi)
        box.set_bottom(ny_bx, ny_lo)
        box.set_right(ny_bx, bar_index)

// TOKYO
if is_tok and not is_tok[1]
    tok_hi := high
    tok_lo := low
    if show_tok
        tok_bx := box.new(bar_index, high, bar_index, low, border_color=color.new(#FFEB3B, 40), border_width=1, bgcolor=col_tok)

if is_tok
    if high > tok_hi
        tok_hi := high
    if low < tok_lo
        tok_lo := low
    if not na(tok_bx)
        box.set_top(tok_bx, tok_hi)
        box.set_bottom(tok_bx, tok_lo)
        box.set_right(tok_bx, bar_index)

// SYDNEY
if is_syd and not is_syd[1]
    syd_hi := high
    syd_lo := low
    if show_syd
        syd_bx := box.new(bar_index, high, bar_index, low, border_color=color.new(#4CAF50, 40), border_width=1, bgcolor=col_syd)

if is_syd
    if high > syd_hi
        syd_hi := high
    if low < syd_lo
        syd_lo := low
    if not na(syd_bx)
        box.set_top(syd_bx, syd_hi)
        box.set_bottom(syd_bx, syd_lo)
        box.set_right(syd_bx, bar_index)
````
