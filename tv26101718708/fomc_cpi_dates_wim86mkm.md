# FOMC & CPI Dates

- url: https://www.tradingview.com/script/wIm86mKM-FOMC-CPI-Dates/
- type: indicator
- pine_id: PUB;3914c474004f4fa2a8500d09f13786fa
- version: 1.0

## Description

Displays the FOMC and CPI dates, manually inputted via preset calendar.

## Source Code

````pine
//@version=6
indicator("FOMC & CPI Dates", shorttitle = "FOMC CPI", overlay = true, max_lines_count = 500, max_labels_count = 500)

labelOffsetTicks = input.int(1400, "Label Offset (ticks)", group = "Settings")
tx_c             = input.color(color.new(#faf8f8, 20), "Text Color", group = "Settings")
LB_c             = input.color(color.new(#faf8f8, 100), "Label Color", group = "Settings")
textSizeI        = input.string("Tiny", "Text Size", ["Small", "Tiny", "Normal"], group = "Settings")

textSize = switch textSizeI
    "Small" => size.small
    "Tiny" => size.tiny
    => size.normal

show_fomc_announcement  = input.bool(true, "FOMC Press Conference", inline = "FOMC Press Conference", group = "Settings")
color_fomc_announcement = input.color(color.new(color.blue, 80), "Color", inline = "FOMC Press Conference", group = "Settings")

show_fomc_minutes = input.bool(true, "FOMC Meeting Minutes", inline = "FOMC Meeting Minutes", group = "Settings")
color_fomc_minutes = input.color(color.new(color.lime, 80), "Color", inline = "FOMC Meeting Minutes", group = "Settings")

show_cpi = input.bool(true, "Consumer Price Index (CPI)", inline = "CPI", group = "Settings")
color_cpi = input.color(color.new(color.yellow, 80), "Color", inline = "CPI", group = "Settings")

ts(int y, int m, int d, int h, int min) =>
    timestamp("America/New_York", y, m, d, h, min)

var int[] fomc_minutes_dates = array.from(
     ts(2021, 1, 6, 14, 0), ts(2021, 2, 17, 14, 0), ts(2021, 4, 7, 14, 0), ts(2021, 5, 19, 14, 0),
     ts(2021, 7, 7, 14, 0), ts(2021, 8, 18, 14, 0), ts(2021, 10, 13, 14, 0), ts(2021, 11, 24, 14, 0),
     ts(2022, 1, 5, 14, 0), ts(2022, 2, 16, 14, 0), ts(2022, 4, 6, 14, 0), ts(2022, 5, 25, 14, 0),
     ts(2022, 7, 6, 14, 0), ts(2022, 8, 17, 14, 0), ts(2022, 10, 12, 14, 0), ts(2022, 11, 23, 14, 0),
     ts(2023, 1, 4, 14, 0), ts(2023, 2, 22, 14, 0), ts(2023, 4, 12, 14, 0), ts(2023, 5, 24, 14, 0),
     ts(2023, 7, 5, 14, 0), ts(2023, 8, 16, 14, 0), ts(2023, 10, 11, 14, 0), ts(2023, 11, 21, 14, 0),
     ts(2024, 1, 3, 14, 0), ts(2024, 2, 21, 14, 0), ts(2024, 4, 10, 14, 0), ts(2024, 5, 22, 14, 0),
     ts(2024, 7, 3, 14, 0), ts(2024, 8, 21, 14, 0), ts(2024, 10, 9, 14, 0), ts(2024, 11, 26, 14, 0),
     ts(2025, 1, 8, 14, 0), ts(2025, 2, 19, 14, 0), ts(2025, 4, 9, 14, 0), ts(2025, 5, 28, 14, 0),
     ts(2025, 7, 9, 14, 0), ts(2025, 8, 20, 14, 0), ts(2025, 10, 8, 14, 0), ts(2025, 11, 19, 14, 0),
     ts(2025, 12, 30, 14, 0), ts(2026, 2, 18, 14, 0), ts(2026, 4, 8, 14, 0), ts(2026, 5, 20, 14, 0),
     ts(2026, 7, 8, 14, 0), ts(2026, 8, 19, 14, 0), ts(2026, 10, 7, 14, 0), ts(2026, 11, 18, 14, 0),
     ts(2026, 12, 30, 14, 0)
)

var int[] fomc_announcement_dates = array.from(
     ts(2021, 1, 27, 14, 0), ts(2021, 3, 17, 14, 0), ts(2021, 4, 28, 14, 0), ts(2021, 6, 16, 14, 0),
     ts(2021, 7, 28, 14, 0), ts(2021, 9, 22, 14, 0), ts(2021, 11, 3, 14, 0), ts(2021, 12, 15, 14, 0),
     ts(2022, 1, 26, 14, 0), ts(2022, 3, 16, 14, 0), ts(2022, 5, 4, 14, 0), ts(2022, 6, 15, 14, 0),
     ts(2022, 7, 27, 14, 0), ts(2022, 9, 21, 14, 0), ts(2022, 11, 2, 14, 0), ts(2022, 12, 14, 14, 0),
     ts(2023, 2, 1, 14, 0), ts(2023, 3, 22, 14, 0), ts(2023, 5, 3, 14, 0), ts(2023, 6, 14, 14, 0),
     ts(2023, 7, 26, 14, 0), ts(2023, 9, 20, 14, 0), ts(2023, 11, 1, 14, 0), ts(2023, 12, 13, 14, 0),
     ts(2024, 1, 31, 14, 0), ts(2024, 3, 20, 14, 0), ts(2024, 5, 1, 14, 0), ts(2024, 6, 12, 14, 0),
     ts(2024, 7, 31, 14, 0), ts(2024, 9, 18, 14, 0), ts(2024, 11, 7, 14, 0), ts(2024, 12, 18, 14, 0),
     ts(2025, 1, 29, 14, 0), ts(2025, 3, 19, 14, 0), ts(2025, 5, 7, 14, 0), ts(2025, 6, 18, 14, 0),
     ts(2025, 7, 30, 14, 0), ts(2025, 9, 17, 14, 0), ts(2025, 10, 29, 14, 0), ts(2025, 12, 10, 14, 0),
     ts(2026, 1, 28, 14, 0), ts(2026, 3, 18, 14, 0), ts(2026, 4, 29, 14, 0), ts(2026, 6, 17, 14, 0),
     ts(2026, 7, 29, 14, 0), ts(2026, 9, 16, 14, 0), ts(2026, 10, 28, 14, 0), ts(2026, 12, 9, 14, 0)
)

var int[] cpi_dates = array.from(
     ts(2021, 1, 13, 8, 30), ts(2021, 2, 10, 8, 30), ts(2021, 3, 10, 8, 30), ts(2021, 4, 13, 8, 30),
     ts(2021, 5, 12, 8, 30), ts(2021, 6, 10, 8, 30), ts(2021, 7, 13, 8, 30), ts(2021, 8, 11, 8, 30),
     ts(2021, 9, 14, 8, 30), ts(2021, 10, 13, 8, 30), ts(2021, 11, 10, 8, 30), ts(2021, 12, 10, 8, 30),
     ts(2022, 1, 12, 8, 30), ts(2022, 2, 10, 8, 30), ts(2022, 3, 10, 8, 30), ts(2022, 4, 12, 8, 30),
     ts(2022, 5, 11, 8, 30), ts(2022, 6, 10, 8, 30), ts(2022, 7, 13, 8, 30), ts(2022, 8, 10, 8, 30),
     ts(2022, 9, 13, 8, 30), ts(2022, 10, 13, 8, 30), ts(2022, 11, 10, 8, 30), ts(2022, 12, 13, 8, 30),
     ts(2023, 1, 12, 8, 30), ts(2023, 2, 14, 8, 30), ts(2023, 3, 14, 8, 30), ts(2023, 4, 12, 8, 30),
     ts(2023, 5, 10, 8, 30), ts(2023, 6, 13, 8, 30), ts(2023, 7, 12, 8, 30), ts(2023, 8, 10, 8, 30),
     ts(2023, 9, 13, 8, 30), ts(2023, 10, 12, 8, 30), ts(2023, 11, 14, 8, 30), ts(2023, 12, 12, 8, 30),
     ts(2024, 1, 11, 8, 30), ts(2024, 2, 13, 8, 30), ts(2024, 3, 12, 8, 30), ts(2024, 4, 10, 8, 30),
     ts(2024, 5, 15, 8, 30), ts(2024, 6, 12, 8, 30), ts(2024, 7, 11, 8, 30), ts(2024, 8, 14, 8, 30),
     ts(2024, 9, 11, 8, 30), ts(2024, 10, 10, 8, 30), ts(2024, 11, 13, 8, 30), ts(2024, 12, 11, 8, 30),
     ts(2025, 1, 15, 8, 30), ts(2025, 2, 12, 8, 30), ts(2025, 3, 12, 8, 30), ts(2025, 4, 10, 8, 30),
     ts(2025, 5, 13, 8, 30), ts(2025, 6, 11, 8, 30), ts(2025, 7, 15, 8, 30), ts(2025, 8, 12, 8, 30),
     ts(2025, 9, 11, 8, 30), ts(2025, 10, 24, 8, 30), ts(2025, 12, 18, 8, 30),
     ts(2026, 1, 13, 8, 30), ts(2026, 2, 13, 8, 30), ts(2026, 3, 11, 8, 30), ts(2026, 4, 10, 8, 30),
     ts(2026, 5, 12, 8, 30), ts(2026, 6, 10, 8, 30), ts(2026, 7, 14, 8, 30), ts(2026, 8, 12, 8, 30),
     ts(2026, 9, 11, 8, 30), ts(2026, 10, 14, 8, 30), ts(2026, 11, 10, 8, 30), ts(2026, 12, 10, 8, 30)
)

getUnixTime(_eventArr, _index) =>
    int eventTime = array.get(_eventArr, _index)
    switch
        timeframe.isdaily => eventTime - timeframe.multiplier * 86400000
        timeframe.isweekly => eventTime - timeframe.multiplier * 604800000
        timeframe.ismonthly => eventTime - timeframe.multiplier * 2592000000
        timeframe.isminutes and timeframe.multiplier > 59 => eventTime - timeframe.multiplier * 60000
        => eventTime

drawEvents(_eventArr, _show, _lineColor, _labelText) =>
    if _show and array.size(_eventArr) > 0
        for i = 0 to array.size(_eventArr) - 1
            int eventTime = getUnixTime(_eventArr, i)
            line.new(x1 = eventTime, y1 = high, x2 = eventTime, y2 = low, extend = extend.both, color = _lineColor, width = 1, xloc = xloc.bar_time)
            label.new(x = eventTime, y = high + syminfo.mintick * labelOffsetTicks, text = _labelText, xloc = xloc.bar_time, size = textSize, color = LB_c, textcolor = tx_c)

if barstate.islastconfirmedhistory
    drawEvents(fomc_minutes_dates, show_fomc_minutes, color_fomc_minutes, "F\nO\nM\nC\n\nM")
    drawEvents(cpi_dates, show_cpi, color_cpi, "C\nP\nI")
    drawEvents(fomc_announcement_dates, show_fomc_announcement, color_fomc_announcement, "F\nO\nM\nC\n\nP")
````
