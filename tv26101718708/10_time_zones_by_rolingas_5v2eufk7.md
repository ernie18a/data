# 10 Time Zones By Rolingas

- url: https://www.tradingview.com/script/5v2EUFk7-10-Time-Zones-By-Rolingas/
- type: indicator
- pine_id: PUB;9fa5d37574a942009223a312cf7ed0fe
- version: 2.0

## Description

You can mark your own time zone and name it by your needs.

## Source Code

````pine
//@version=5
indicator("10 Vertical Text Zones", overlay=true, max_labels_count=500)

// --- Global Settings ---
tz = input.string("UTC", "Global Timezone", tooltip="Example: 'America/New_York', 'UTC'")
txt_transp = input.int(0, "Text Transparency", minval=0, maxval=100)

// --- Fixed Function to convert text to vertical ---
formatVertical(str) =>
    string res = ""
    if str != ""
        for i = 0 to str.length(str) - 1
            res += str.substring(str, i, i + 1) + "\n"
    res

// --- Function to handle Zone and Vertical Label ---
draw_zone(on, sess, col, txt) =>
    var label lbl = na
    in_sess = on and not na(time(timeframe.period, sess, tz))
    is_start = in_sess and na(time(timeframe.period, sess, tz)[1])
    
    if is_start
        lbl := label.new(bar_index, high, formatVertical(txt), 
             color=color.new(color.white, 100), 
             textcolor=color.new(col, txt_transp),
             style=label.style_none,
             yloc=yloc.price,
             textalign=text.align_center)
    
    in_sess ? col : na

// --- Zone Configuration ---
// Formatting: [Toggle] [Time Range] [Text Label] [Color]
z1_on = input.bool(true, "", group="Zone 1", inline="z1"), z1_time = input.session("0000-0200", "", group="Zone 1", inline="z1"), z1_txt = input.string("Post-open liquidation or fake move", "", group="Zone 1", inline="z1"), z1_col = input.color(color.new(color.blue, 85), "", group="Zone 1", inline="z1")
z2_on = input.bool(true, "", group="Zone 2", inline="z2"), z2_time = input.session("0830-1100", "", group="Zone 2", inline="z2"), z2_txt = input.string("Trap formation / Delta reversal window", "", group="Zone 2", inline="z2"), z2_col = input.color(color.new(color.red, 85), "", group="Zone 2", inline="z2")
z3_on = input.bool(false, "", group="Zone 3", inline="z3"), z3_time = input.session("1300-1500", "", group="Zone 3", inline="z3"), z3_txt = input.string("Shift trigger (trend continuation or reversal", "", group="Zone 3", inline="z3"), z3_col = input.color(color.new(color.green, 85), "", group="Zone 3", inline="z3")
z4_on = input.bool(false, "", group="Zone 4", inline="z4"), z4_time = input.session("1900-2100", "", group="Zone 4", inline="z4"), z4_txt = input.string("Fade point / Liquidity trap", "", group="Zone 4", inline="z4"), z4_col = input.color(color.new(color.orange, 85), "", group="Zone 4", inline="z4")
z5_on = input.bool(false, "", group="Zone 5", inline="z5"), z5_time = input.session("0200-0400", "", group="Zone 5", inline="z5"), z5_txt = input.string("Rotation or volume dropoff", "", group="Zone 5", inline="z5"), z5_col = input.color(color.new(color.purple, 85), "", group="Zone 5", inline="z5")
z6_on = input.bool(false, "", group="Zone 6", inline="z6"), z6_time = input.session("0400-0600", "", group="Zone 6", inline="z6"), z6_txt = input.string("Transition into midday compression", "", group="Zone 6", inline="z6"), z6_col = input.color(color.new(color.teal, 85), "", group="Zone 6", inline="z6")
z7_on = input.bool(false, "", group="Zone 7", inline="z7"), z7_time = input.session("0600-0800", "", group="Zone 7", inline="z7"), z7_txt = input.string("Power window", "", group="Zone 7", inline="z7"), z7_col = input.color(color.new(color.yellow, 85), "", group="Zone 7", inline="z7")
z8_on = input.bool(false, "", group="Zone 8", inline="z8"), z8_time = input.session("1000-1200", "", group="Zone 8", inline="z8"), z8_txt = input.string("ZONE 8", "", group="Zone 8", inline="z8"), z8_col = input.color(color.new(color.navy, 85), "", group="Zone 8", inline="z8")
z9_on = input.bool(false, "", group="Zone 9", inline="z9"), z9_time = input.session("1200-1400", "", group="Zone 9", inline="z9"), z9_txt = input.string("ZONE 9", "", group="Zone 9", inline="z9"), z9_col = input.color(color.new(color.gray, 85), "", group="Zone 9", inline="z9")
z10_on = input.bool(false, "", group="Zone 10", inline="z10"), z10_time = input.session("1600-1800", "", group="Zone 10", inline="z10"), z10_txt = input.string("CLOSE", "", group="Zone 10", inline="z10"), z10_col = input.color(color.new(color.black, 85), "", group="Zone 10", inline="z10")

// --- Execute ---
bgcolor(draw_zone(z1_on, z1_time, z1_col, z1_txt))
bgcolor(draw_zone(z2_on, z2_time, z2_col, z2_txt))
bgcolor(draw_zone(z3_on, z3_time, z3_col, z3_txt))
bgcolor(draw_zone(z4_on, z4_time, z4_col, z4_txt))
bgcolor(draw_zone(z5_on, z5_time, z5_col, z5_txt))
bgcolor(draw_zone(z6_on, z6_time, z6_col, z6_txt))
bgcolor(draw_zone(z7_on, z7_time, z7_col, z7_txt))
bgcolor(draw_zone(z8_on, z8_time, z8_col, z8_txt))
bgcolor(draw_zone(z9_on, z9_time, z9_col, z9_txt))
bgcolor(draw_zone(z10_on, z10_time, z10_col, z10_txt))
````
