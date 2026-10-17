# Amavasya Friday + Ekadashi Tuesday

- url: https://www.tradingview.com/script/bSrtr0y6-Amavasya-Friday-Ekadashi-Tuesday/
- type: indicator
- pine_id: PUB;25d490614c6e4a2cab8e0e9a2973f95c
- version: 1.0

## Description

The script determines the Amavasya and Ekadashi in the coming 3years from a time forecasting perspective.

## Source Code

````pine
//@version=5
indicator("Amavasya Friday + Ekadashi Tuesday", overlay=true, max_lines_count=500, max_boxes_count=500)

//====================================================
// USER SETTINGS
//====================================================
showAmavasya  = input.bool(true, "Show Amavasya on Friday")
showEkadashi  = input.bool(true, "Show Ekadashi on Tuesday")
showHighlight = input.bool(true, "Show Highlight")
showLabels    = input.bool(true, "Show Labels")

amavasyaColor = input.color(color.red, "Amavasya Bar Color")
ekadashiColor = input.color(color.green, "Ekadashi Bar Color")

barWidth    = input.int(2, "Bar Thickness", minval=1, maxval=10)
fillOpacity = input.int(85, "Highlight Transparency", minval=0, maxval=100)

barType = input.string("Solid", "Bar Type", options=["Solid", "Dashed", "Dotted"])

//====================================================
// PRE-FILLED DATES
//====================================================
amavasyaDatesInput = input.string("2026-04-17, 2027-06-04", title="Amavasya Dates (Friday only, comma separated)")
ekadashiDatesInput = input.string("2026-09-22, 2026-10-06, 2027-01-19, 2027-02-02, 2027-06-01", title="Ekadashi Dates (Tuesday only, comma separated)")

//====================================================
// HELPERS
//====================================================
lineStyle = barType == "Dashed" ? line.style_dashed : barType == "Dotted" ? line.style_dotted : line.style_solid

f_trim(_s) =>
    str.trim(_s)

f_parseDate(_dateStr) =>
    s = f_trim(_dateStr)
    parts = str.split(s, "-")
    y = array.size(parts) == 3 ? int(str.tonumber(array.get(parts, 0))) : na
    m = array.size(parts) == 3 ? int(str.tonumber(array.get(parts, 1))) : na
    d = array.size(parts) == 3 ? int(str.tonumber(array.get(parts, 2))) : na
    not na(y) and not na(m) and not na(d) ? timestamp(syminfo.timezone, y, m, d, 0, 0) : na

f_nextDay(_ts) =>
    _ts + 24 * 60 * 60 * 1000

f_drawVertical(_ts, _color, _text) =>
    if showHighlight
        box.new(
             left=_ts,
             right=f_nextDay(_ts),
             top=10000000000.0,
             bottom=-10000000000.0,
             xloc=xloc.bar_time,
             bgcolor=color.new(_color, fillOpacity),
             border_width=0)

    line.new(
         x1=_ts,
         y1=10000000000.0,
         x2=_ts,
         y2=-10000000000.0,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=_color,
         width=barWidth,
         style=lineStyle)

    if showLabels
        label.new(
             x=_ts,
             y=high,
             xloc=xloc.bar_time,
             text=_text,
             style=label.style_label_down,
             color=_color,
             textcolor=color.white,
             size=size.small)

//====================================================
// DRAW ONLY ON LAST BAR
//====================================================
if barstate.islast
    amaList = str.split(amavasyaDatesInput, ",")
    for i = 0 to array.size(amaList) - 1
        dt = f_parseDate(array.get(amaList, i))
        if showAmavasya and not na(dt)
            f_drawVertical(dt, amavasyaColor, "Amavasya")

    ekaList = str.split(ekadashiDatesInput, ",")
    for i = 0 to array.size(ekaList) - 1
        dt = f_parseDate(array.get(ekaList, i))
        if showEkadashi and not na(dt)
            f_drawVertical(dt, ekadashiColor, "Ekadashi")
````
