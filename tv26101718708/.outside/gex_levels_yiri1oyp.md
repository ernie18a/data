# GEX Levels

- url: https://www.tradingview.com/script/YiRI1OYP-GEX-Levels/
- type: indicator
- pine_id: PUB;9ff9ec528440400c9a9b4bca360225a9
- version: 3.0

## Description

this is an editable gex level indicator very simple. must self populate data

## Source Code

````pine
//@version=6
indicator("QQQ GEX Levels - May 29 1DTE", overlay=true)

// ── EDITABLE INPUTS ──
c1_strike = input.float(740.0, "C1 Strike (Call Wall)")
c1_oi     = input.string("14,033", "C1 OI Label")

c2_strike = input.float(750.0, "C2 Strike")
c2_oi     = input.string("14,905", "C2 OI Label")

c3_strike = input.float(745.0, "C3 Strike")
c3_oi     = input.string("5,589", "C3 OI Label")

c4_strike = input.float(747.0, "C4 Strike")
c4_oi     = input.string("1,983", "C4 OI Label")

bg_strike = input.float(735.0, "Battleground Strike")
bg_oi     = input.string("8,569", "Battleground OI Label")

p1_strike = input.float(730.0, "P1 Strike (Nearest Support)")
p1_oi     = input.string("5,397", "P1 OI Label")

p2_strike = input.float(728.0, "P2 Strike")
p2_oi     = input.string("8,249", "P2 OI Label")

p3_strike = input.float(725.0, "P3 Strike")
p3_oi     = input.string("8,270", "P3 OI Label")

p4_strike = input.float(720.0, "P4 Strike (Dealer Floor)")
p4_oi     = input.string("10,513", "P4 OI Label")

// ── REGIME TABLE INPUTS ──
reg_regime  = input.string("CALL Skew",           "Regime")
reg_bias    = input.string("Bullish / Pin $735",  "Bias")
reg_resist  = input.string("$740 Call Wall",      "Next Resist")
reg_support = input.string("$730 Flipped Support","Next Support")
reg_dist    = input.string("$730-$740 Band",      "Distance")

if barstate.islast

    // CALL LINES
    line.new(bar_index-1, c1_strike, bar_index, c1_strike, extend=extend.both, color=color.new(color.green,0),  width=3)
    line.new(bar_index-1, c2_strike, bar_index, c2_strike, extend=extend.both, color=color.new(color.green,30), width=2)
    line.new(bar_index-1, c3_strike, bar_index, c3_strike, extend=extend.both, color=color.new(color.green,50), width=1)
    line.new(bar_index-1, c4_strike, bar_index, c4_strike, extend=extend.both, color=color.new(color.green,55), width=1)

    // BATTLEGROUND
    line.new(bar_index-1, bg_strike, bar_index, bg_strike, extend=extend.both, color=color.yellow, width=3, style=line.style_dashed)

    // PUT LINES
    line.new(bar_index-1, p1_strike, bar_index, p1_strike, extend=extend.both, color=color.new(color.red,0),    width=2)
    line.new(bar_index-1, p2_strike, bar_index, p2_strike, extend=extend.both, color=color.new(color.red,20),   width=2)
    line.new(bar_index-1, p3_strike, bar_index, p3_strike, extend=extend.both, color=color.new(color.red,30),   width=2)
    line.new(bar_index-1, p4_strike, bar_index, p4_strike, extend=extend.both, color=color.new(color.purple,20),width=2)

    // CALL LABELS
    label.new(bar_index, c1_strike, "C1 " + str.tostring(c1_strike) + " | " + c1_oi + " OI WALL",    style=label.style_label_left, color=color.green,              textcolor=color.white, size=size.small)
    label.new(bar_index, c2_strike, "C2 " + str.tostring(c2_strike) + " | " + c2_oi + " OI CEILING", style=label.style_label_left, color=color.green,              textcolor=color.white, size=size.small)
    label.new(bar_index, c3_strike, "C3 " + str.tostring(c3_strike) + " | " + c3_oi + " OI",         style=label.style_label_left, color=color.new(color.green,20),textcolor=color.white, size=size.tiny)
    label.new(bar_index, c4_strike, "C4 " + str.tostring(c4_strike) + " | " + c4_oi + " OI",         style=label.style_label_left, color=color.new(color.green,20),textcolor=color.white, size=size.tiny)

    // BATTLEGROUND LABEL
    label.new(bar_index, bg_strike, "BG " + str.tostring(bg_strike) + " | " + bg_oi + " OI ATM BATTLEGROUND", style=label.style_label_left, color=color.yellow, textcolor=color.black, size=size.small)

    // PUT LABELS
    label.new(bar_index, p1_strike, "P1 " + str.tostring(p1_strike) + " | " + p1_oi + " OI",         style=label.style_label_left, color=color.red,               textcolor=color.white, size=size.small)
    label.new(bar_index, p2_strike, "P2 " + str.tostring(p2_strike) + " | " + p2_oi + " OI",         style=label.style_label_left, color=color.red,               textcolor=color.white, size=size.small)
    label.new(bar_index, p3_strike, "P3 " + str.tostring(p3_strike) + " | " + p3_oi + " OI",         style=label.style_label_left, color=color.red,               textcolor=color.white, size=size.small)
    label.new(bar_index, p4_strike, "P4 " + str.tostring(p4_strike) + " | " + p4_oi + " OI FLOOR",   style=label.style_label_left, color=color.purple,            textcolor=color.white, size=size.small)

    // REGIME TABLE
    var table t = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black,20), border_width=1)
    table.cell(t,0,0,"Regime",      text_color=color.white, bgcolor=color.navy)
    table.cell(t,1,0, reg_regime,   text_color=color.lime)
    table.cell(t,0,1,"Bias",        text_color=color.white, bgcolor=color.navy)
    table.cell(t,1,1, reg_bias,     text_color=color.lime)
    table.cell(t,0,2,"Next Resist", text_color=color.white, bgcolor=color.navy)
    table.cell(t,1,2, reg_resist,   text_color=color.green)
    table.cell(t,0,3,"Next Support",text_color=color.white, bgcolor=color.navy)
    table.cell(t,1,3, reg_support,  text_color=color.red)
    table.cell(t,0,4,"Distance",    text_color=color.white, bgcolor=color.navy)
    table.cell(t,1,4, reg_dist,     text_color=color.gray)

// ALERTS
alertcondition(close >= c1_strike, "BREAK: Call Wall",        "QQQ broke above Call Wall")
alertcondition(close <= p1_strike, "BREAK: P1 Support",       "QQQ lost P1 support")
alertcondition(close <= p2_strike, "BREAK: P2 Shelf",         "QQQ below P2 shelf")
alertcondition(close >= bg_strike and close <= bg_strike+0.5, "AT BATTLEGROUND",  "QQQ at Battleground level")
````
