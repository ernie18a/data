# R3D RTP H4 25% NY SWEEP CONFIRM

- url: https://www.tradingview.com/script/ARESvvpf/
- type: indicator
- pine_id: PUB;587f103ac2fd4f16bc2a60445567ff47
- version: 1.0

## Description

estrategia basada en crt tomando alto de h4 en la vela de las 10 en busca de bajo de dicha vela.

## Source Code

````pine
//@version=6
indicator("R3D RTP H4 25% NY SWEEP CONFIRM", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

tz = "America/New_York"

trade_len = input.int(5,"Order Width")


//====================
// RANGO H4 06-10 NY
//====================

range_time = not na(time(timeframe.period,"0600-1000",tz))
entry_time = not na(time(timeframe.period,"1000-1100",tz))

start = range_time and not range_time[1]


var float range_high = na
var float range_low = na

var box range_box = na

var bool active = false
var bool done = false

var bool sell_setup = false
var bool buy_setup = false

var float swing_high = na
var float swing_low = na

var line level25 = na



// CREAR RANGO

if start

    range_high := high
    range_low := low

    active := false
    done := false

    sell_setup := false
    buy_setup := false

    swing_high := na
    swing_low := na


    range_box := box.new(
     bar_index,
     high,
     bar_index,
     low,
     bgcolor=color.new(color.blue,85),
     border_color=color.blue)




// ACTUALIZAR RANGO

if range_time

    range_high := math.max(range_high,high)
    range_low := math.min(range_low,low)


    box.set_top(range_box,range_high)
    box.set_bottom(range_box,range_low)
    box.set_right(range_box,bar_index)





//====================
// SWEEP + RECHAZO
//====================

if entry_time and not active and not done


    // TOMA DEL ALTO Y RECHAZO

    if high > range_high and close < high

        active := true
        sell_setup := true

        swing_high := high


        entry = range_high - ((swing_high-range_low)*0.25)


        level25 := line.new(
         bar_index,
         entry,
         bar_index+20,
         entry,
         color=color.red,
         width=2)



    // TOMA DEL BAJO Y RECHAZO

    if low < range_low and close > low

        active := true
        buy_setup := true

        swing_low := low


        entry = range_low + ((range_high-swing_low)*0.25)


        level25 := line.new(
         bar_index,
         entry,
         bar_index+20,
         entry,
         color=color.green,
         width=2)





//====================
// SELL 25%
//====================

if sell_setup and not done and entry_time


    entry = range_high - ((swing_high-range_low)*0.25)

    tp = range_low


    if low <= entry


        done := true


        box.new(
         bar_index,
         swing_high,
         bar_index+trade_len,
         entry,
         bgcolor=color.new(color.gray,85))


        box.new(
         bar_index,
         entry,
         bar_index+trade_len,
         tp,
         bgcolor=color.new(color.blue,85))


        label.new(
         bar_index,
         swing_high,
         "SELL H4 25%",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)




//====================
// BUY 25%
//====================

if buy_setup and not done and entry_time


    entry = range_low + ((range_high-swing_low)*0.25)

    tp = range_high


    if high >= entry


        done := true


        box.new(
         bar_index,
         tp,
         bar_index+trade_len,
         entry,
         bgcolor=color.new(color.blue,85))


        box.new(
         bar_index,
         entry,
         bar_index+trade_len,
         swing_low,
         bgcolor=color.new(color.gray,85))


        label.new(
         bar_index,
         swing_low,
         "BUY H4 25%",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)
````
