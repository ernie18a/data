# ATR from ATH Levels

- url: https://www.tradingview.com/script/VUyUU13i-ATR-from-ATH-Levels/
- type: indicator
- pine_id: PUB;28398ff732524348b4f84275a751c0cb
- version: 1.0

## Description

ATH Levels
This indicator automatically detects the All-Time High (ATH) on any asset and draws five configurable retracement zones below it. Every time a new ATH is set, all levels step up accordingly. This makes it possible to look back in history and see exactly where the levels were relative to previous highs.
How it works
The ATH is calculated bar by bar using the highest high up to that point. Each level is defined by a centerpoint percentage below the ATH. Around that centerpoint sits a zone with an adjustable width. The wider the zone, the more margin around the level.
Levels (default centerpoints)

Level 5: -23.5%
Level 4: -38.2%
Level 3: -49.5%
Level 2: -60.5%
Level 1: -76.5%

Settings

Zone width: makes all zones wider or narrower simultaneously, in steps of 1%
Individual centerpoints: fine-tune each level separately in steps of 0.5%
Table position: place the price table anywhere on the chart

Price table
A real-time table shows the exact dollar prices for the middle, top and bottom of each zone, always based on the current ATH.

## Source Code

````pine
//@version=6
indicator("ATH Levels", overlay=true, max_labels_count=10)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
levelWidth    = input.int(1, "Zone breedte (± om middelpunt)", minval=1, maxval=10, step=1)
tablePosition = input.string("Top Right", "Tabel positie",
                 options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"])

mid5 = input.float(-23.5, "Level 5 middelpunt %", minval=-99.0, maxval=-1.0, step=0.5)
mid4 = input.float(-38.2, "Level 4 middelpunt %", minval=-99.0, maxval=-1.0, step=0.5)
mid3 = input.float(-49.5, "Level 3 middelpunt %", minval=-99.0, maxval=-1.0, step=0.5)
mid2 = input.float(-60.5, "Level 2 middelpunt %", minval=-99.0, maxval=-1.0, step=0.5)
mid1 = input.float(-76.5, "Level 1 middelpunt %", minval=-99.0, maxval=-1.0, step=0.5)

// ─── POSITIE OMZETTEN ─────────────────────────────────────────────────────────
tblPos = switch tablePosition
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Top Center"    => position.top_center
    "Bottom Center" => position.bottom_center
    => position.top_right

// ─── ATH PER BAR ──────────────────────────────────────────────────────────────
ath   = ta.highest(high, bar_index + 1)
halfW = levelWidth / 2.0

// ─── LEVEL PRIJZEN PER BAR ────────────────────────────────────────────────────
top5 = ath * (1 + (mid5 + halfW) / 100)
bot5 = ath * (1 + (mid5 - halfW) / 100)
top4 = ath * (1 + (mid4 + halfW) / 100)
bot4 = ath * (1 + (mid4 - halfW) / 100)
top3 = ath * (1 + (mid3 + halfW) / 100)
bot3 = ath * (1 + (mid3 - halfW) / 100)
top2 = ath * (1 + (mid2 + halfW) / 100)
bot2 = ath * (1 + (mid2 - halfW) / 100)
top1 = ath * (1 + (mid1 + halfW) / 100)
bot1 = ath * (1 + (mid1 - halfW) / 100)

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(ath,  "ATH",          color=color.lime,              linewidth=2)
plot(top5, "Level 5 Boven", color=color.yellow,            linewidth=1)
plot(bot5, "Level 5 Onder", color=color.yellow,            linewidth=1, style=plot.style_circles)
plot(top4, "Level 4 Boven", color=color.orange,            linewidth=1)
plot(bot4, "Level 4 Onder", color=color.orange,            linewidth=1, style=plot.style_circles)
plot(top3, "Level 3 Boven", color=color.red,               linewidth=1)
plot(bot3, "Level 3 Onder", color=color.red,               linewidth=1, style=plot.style_circles)
plot(top2, "Level 2 Boven", color=color.maroon,            linewidth=1)
plot(bot2, "Level 2 Onder", color=color.maroon,            linewidth=1, style=plot.style_circles)
plot(top1, "Level 1 Boven", color=color.rgb(160, 82, 45),  linewidth=1)
plot(bot1, "Level 1 Onder", color=color.rgb(160, 82, 45),  linewidth=1, style=plot.style_circles)

// ─── TABEL ────────────────────────────────────────────────────────────────────
tblPos2 = switch tablePosition
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Top Center"    => position.top_center
    "Bottom Center" => position.bottom_center
    => position.top_right

var table infoTbl = na

if barstate.isfirst
    infoTbl := table.new(tblPos2, 4, 7,
                          bgcolor      = color.new(color.black, 20),
                          border_color = color.new(color.gray, 50),
                          border_width = 1,
                          frame_color  = color.new(color.gray, 30),
                          frame_width  = 1)

    table.cell(infoTbl, 0, 0, "Level",    text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(infoTbl, 1, 0, "Midden $", text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(infoTbl, 2, 0, "Boven $",  text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(infoTbl, 3, 0, "Onder $",  text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(infoTbl, 0, 1, "ATH",      text_color=color.lime,  text_size=size.small, bgcolor=color.new(color.black, 40))
    table.cell(infoTbl, 1, 1, "–",        text_color=color.lime,  text_size=size.small, bgcolor=color.new(color.black, 40))
    table.cell(infoTbl, 2, 1, "–",        text_color=color.lime,  text_size=size.small, bgcolor=color.new(color.black, 40))
    table.cell(infoTbl, 3, 1, "–",        text_color=color.lime,  text_size=size.small, bgcolor=color.new(color.black, 40))

// Tabel bijwerken op laatste bar
if barstate.islast and not na(infoTbl)
   // levels worden via aparte arrays bijgehouden
        

    table.cell_set_text(infoTbl, 1, 1, str.tostring(ath, format.mintick))
    table.cell_set_text(infoTbl, 2, 1, str.tostring(ath, format.mintick))
    table.cell_set_text(infoTbl, 3, 1, str.tostring(ath, format.mintick))

    rowColors = array.from(color.yellow, color.orange, color.red, color.maroon, color.rgb(160, 82, 45))
    rowMids   = array.from(mid5, mid4, mid3, mid2, mid1)
    rowTops   = array.from(top5, top4, top3, top2, top1)
    rowBots   = array.from(bot5, bot4, bot3, bot2, bot1)
    rowLabels = array.from("Level 5", "Level 4", "Level 3", "Level 2", "Level 1")

    for i = 0 to 4
        row    = i + 2
        col    = array.get(rowColors, i)
        midVal = ath * (1 + array.get(rowMids, i) / 100)
        topVal = array.get(rowTops, i)
        botVal = array.get(rowBots, i)
        lbl    = array.get(rowLabels, i)

        table.cell_set_text(infoTbl, 0, row, lbl)
        table.cell_set_text(infoTbl, 1, row, str.tostring(midVal, format.mintick))
        table.cell_set_text(infoTbl, 2, row, str.tostring(topVal, format.mintick))
        table.cell_set_text(infoTbl, 3, row, str.tostring(botVal, format.mintick))
        table.cell_set_text_color(infoTbl, 0, row, col)
        table.cell_set_text_color(infoTbl, 1, row, col)
        table.cell_set_text_color(infoTbl, 2, row, col)
        table.cell_set_text_color(infoTbl, 3, row, col)
        table.cell_set_bgcolor(infoTbl, 0, row, color.new(color.black, 40))
        table.cell_set_bgcolor(infoTbl, 1, row, color.new(color.black, 40))
        table.cell_set_bgcolor(infoTbl, 2, row, color.new(color.black, 40))
        table.cell_set_bgcolor(infoTbl, 3, row, color.new(color.black, 40))
````
