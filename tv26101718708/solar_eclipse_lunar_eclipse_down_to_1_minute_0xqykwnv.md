# Solar Eclipse, Lunar Eclipse (down to 1 minute)

- url: https://www.tradingview.com/script/0xQYkWnv-Solar-Eclipse-Lunar-Eclipse-down-to-1-minute/
- type: indicator
- pine_id: PUB;6eca4f1727c3401d84df264413eccb00
- version: 1.0

## Description

these are the solar eclipse and lunar eclipse down to 1 minute level
this is highly useful to use it together other [url=https://www.youtube.com/watch?v=A94NbgTTJ0w]gann trading[/url] tools to predict market top and bottom.

once you see it with a differnt gann eye glasses. the same chart will be seen differently
and profit can be easily taken as in shown in www.gannexplained.com supported by both khit wong and his student's beokerage statement

the source time is from NASA, and they are all hard coded into the script. this will facilitate you to aware the upcoming and past solar eclipse time. we believe this is the best solar and lunar eclipse indicator you can have in the community

## Source Code

````pine
// @version=5
indicator("Solar Eclipse, Lunar Eclipse (down to 1 minute)", overlay=true, shorttitle="GannExplained Eclipse")

// ==========================================
// 1. 設定與顏色
// ==========================================
groupStyle = "顯示設定"
solarColor = input.color(color.new(#FFD700, 0), "日食線顏色 (Solar)", group=groupStyle)
lunarColor = input.color(color.new(#C0C0C0, 0), "月食線顏色 (Lunar)", group=groupStyle)
lineWidth  = input.int(2, "線條寬度", minval=1, maxval=5, group=groupStyle)
labelPos   = input.string("頂部", "標籤位置", options=["頂部", "底部"], group=groupStyle)

// ==========================================
// 2. 輔助函數
// ==========================================
format_utc_time(t) =>
    int y = year(t, "UTC")
    int m = month(t, "UTC")
    int d = dayofmonth(t, "UTC")
    int h = hour(t, "UTC")
    int mn = minute(t, "UTC")
    str.tostring(y) + "-" + str.tostring(m) + "-" + str.tostring(d) + " " + 
     (h < 10 ? "0" : "") + str.tostring(h) + ":" + 
     (mn < 10 ? "0" : "") + str.tostring(mn) + " UTC"

draw_eclipse(t, isSolar) =>
    color c = isSolar ? solarColor : lunarColor
    string txt = (isSolar ? "SOLAR ECLIPSE\n" : "LUNAR ECLIPSE\n") + format_utc_time(t)
    line.new(t, 0, t, 100, xloc=xloc.bar_time, extend=extend.both, color=c, style=line.style_solid, width=lineWidth)
    label.new(t, labelPos == "頂部" ? high : low, txt, 
      xloc=xloc.bar_time, 
      yloc=labelPos == "頂部" ? yloc.abovebar : yloc.belowbar, 
      color=color.new(c, 20), 
      textcolor=color.black, 
      style=labelPos == "頂部" ? label.style_label_down : label.style_label_up, 
      size=size.large)

// ==========================================
// 3. 高精度食相數據庫 (2020-2035)
// 數據來源：NASA Eclipse Web Site (Five Millennium Catalog of Eclipses)
// ==========================================
if barstate.islast
    // --- 2020 ---
    draw_eclipse(timestamp("UTC", 2020, 01, 10, 19, 10), false) // Lunar
    draw_eclipse(timestamp("UTC", 2020, 06, 05, 19, 25), false) // Lunar
    draw_eclipse(timestamp("UTC", 2020, 06, 21, 06, 40), true)  // Solar
    draw_eclipse(timestamp("UTC", 2020, 07, 05, 04, 30), false) // Lunar
    draw_eclipse(timestamp("UTC", 2020, 11, 30, 09, 43), false) // Lunar
    draw_eclipse(timestamp("UTC", 2020, 12, 14, 16, 14), true)  // Solar

    // --- 2021 ---
    draw_eclipse(timestamp("UTC", 2021, 05, 26, 11, 19), false) // Lunar
    draw_eclipse(timestamp("UTC", 2021, 06, 10, 10, 42), true)  // Solar
    draw_eclipse(timestamp("UTC", 2021, 11, 19, 09, 03), false) // Lunar
    draw_eclipse(timestamp("UTC", 2021, 12, 04, 07, 34), true)  // Solar

    // --- 2022 ---
    draw_eclipse(timestamp("UTC", 2022, 04, 30, 20, 41), true)  // Solar
    draw_eclipse(timestamp("UTC", 2022, 05, 16, 04, 12), false) // Lunar
    draw_eclipse(timestamp("UTC", 2022, 10, 25, 11, 01), true)  // Solar
    draw_eclipse(timestamp("UTC", 2022, 11, 08, 11, 00), false) // Lunar

    // --- 2023 ---
    draw_eclipse(timestamp("UTC", 2023, 04, 20, 04, 17), true)  // Solar
    draw_eclipse(timestamp("UTC", 2023, 05, 05, 17, 23), false) // Lunar
    draw_eclipse(timestamp("UTC", 2023, 10, 14, 17, 59), true)  // Solar
    draw_eclipse(timestamp("UTC", 2023, 10, 28, 20, 14), false) // Lunar

    // --- 2024 ---
    draw_eclipse(timestamp("UTC", 2024, 03, 25, 07, 13), false) // Lunar
    draw_eclipse(timestamp("UTC", 2024, 04, 08, 18, 17), true)  // Solar
    draw_eclipse(timestamp("UTC", 2024, 09, 18, 02, 44), false) // Lunar
    draw_eclipse(timestamp("UTC", 2024, 10, 02, 18, 45), true)  // Solar

    // --- 2025 ---
    draw_eclipse(timestamp("UTC", 2025, 03, 14, 06, 54), false) // Lunar
    draw_eclipse(timestamp("UTC", 2025, 03, 29, 10, 48), true)  // Solar
    draw_eclipse(timestamp("UTC", 2025, 09, 07, 18, 12), false) // Lunar
    draw_eclipse(timestamp("UTC", 2025, 09, 21, 19, 54), true)  // Solar

    // --- 2026 ---
    draw_eclipse(timestamp("UTC", 2026, 02, 17, 12, 13), true)  // Solar
    draw_eclipse(timestamp("UTC", 2026, 03, 03, 11, 34), false) // Lunar
    draw_eclipse(timestamp("UTC", 2026, 08, 12, 17, 47), true)  // Solar
    draw_eclipse(timestamp("UTC", 2026, 08, 28, 04, 14), false) // Lunar

    // --- 2027 ---
    draw_eclipse(timestamp("UTC", 2027, 02, 06, 16, 00), true)  // Solar
    draw_eclipse(timestamp("UTC", 2027, 02, 20, 23, 13), false) // Lunar
    draw_eclipse(timestamp("UTC", 2027, 07, 18, 16, 04), false) // Lunar
    draw_eclipse(timestamp("UTC", 2027, 08, 02, 10, 07), true)  // Solar
    draw_eclipse(timestamp("UTC", 2027, 08, 17, 07, 14), false) // Lunar

    // --- 2028 ---
    draw_eclipse(timestamp("UTC", 2028, 01, 12, 04, 14), false) // Lunar
    draw_eclipse(timestamp("UTC", 2028, 01, 26, 15, 08), true)  // Solar
    draw_eclipse(timestamp("UTC", 2028, 07, 06, 18, 20), false) // Lunar
    draw_eclipse(timestamp("UTC", 2028, 07, 22, 02, 56), true)  // Solar
    draw_eclipse(timestamp("UTC", 2028, 12, 31, 16, 52), false) // Lunar

    // --- 2029 ---
    draw_eclipse(timestamp("UTC", 2029, 01, 14, 17, 13), true)  // Solar
    draw_eclipse(timestamp("UTC", 2029, 06, 12, 04, 06), true)  // Solar
    draw_eclipse(timestamp("UTC", 2029, 06, 26, 03, 22), false) // Lunar
    draw_eclipse(timestamp("UTC", 2029, 07, 11, 15, 37), true)  // Solar
    draw_eclipse(timestamp("UTC", 2029, 12, 05, 15, 03), true)  // Solar
    draw_eclipse(timestamp("UTC", 2029, 12, 20, 22, 42), false) // Lunar

    // --- 2030 ---
    draw_eclipse(timestamp("UTC", 2030, 06, 01, 06, 29), true)  // Solar
    draw_eclipse(timestamp("UTC", 2030, 06, 15, 18, 33), false) // Lunar
    draw_eclipse(timestamp("UTC", 2030, 11, 25, 06, 51), true)  // Solar
    draw_eclipse(timestamp("UTC", 2030, 12, 09, 22, 28), false) // Lunar

    // --- 2031 ---
    draw_eclipse(timestamp("UTC", 2031, 05, 07, 03, 51), false) // Lunar
    draw_eclipse(timestamp("UTC", 2031, 05, 21, 07, 16), true)  // Solar
    draw_eclipse(timestamp("UTC", 2031, 10, 29, 07, 45), false) // Lunar
    draw_eclipse(timestamp("UTC", 2031, 11, 14, 21, 07), true)  // Solar

    // --- 2032 ---
    draw_eclipse(timestamp("UTC", 2032, 04, 25, 15, 14), false) // Lunar
    draw_eclipse(timestamp("UTC", 2032, 05, 09, 07, 26), true)  // Solar
    draw_eclipse(timestamp("UTC", 2032, 10, 18, 19, 03), false) // Lunar
    draw_eclipse(timestamp("UTC", 2032, 11, 03, 05, 34), true)  // Solar

    // --- 2033 ---
    draw_eclipse(timestamp("UTC", 2033, 03, 30, 18, 02), true)  // Solar
    draw_eclipse(timestamp("UTC", 2033, 04, 14, 19, 13), false) // Lunar
    draw_eclipse(timestamp("UTC", 2033, 09, 23, 13, 54), true)  // Solar
    draw_eclipse(timestamp("UTC", 2033, 10, 08, 10, 56), false) // Lunar

    // --- 2034 ---
    draw_eclipse(timestamp("UTC", 2034, 02, 11, 10, 14), false) // Lunar
    draw_eclipse(timestamp("UTC", 2034, 03, 20, 10, 18), true)  // Solar
    draw_eclipse(timestamp("UTC", 2034, 04, 03, 19, 06), false) // Lunar
    draw_eclipse(timestamp("UTC", 2034, 09, 12, 16, 19), true)  // Solar
    draw_eclipse(timestamp("UTC", 2034, 09, 28, 02, 47), false) // Lunar

    // --- 2035 ---
    draw_eclipse(timestamp("UTC", 2035, 02, 11, 14, 02), false) // Lunar
    draw_eclipse(timestamp("UTC", 2035, 02, 22, 09, 06), false) // Lunar
    draw_eclipse(timestamp("UTC", 2035, 03, 09, 23, 05), true)  // Solar
    draw_eclipse(timestamp("UTC", 2035, 08, 19, 01, 12), false) // Lunar
    draw_eclipse(timestamp("UTC", 2035, 09, 02, 01, 56), true)  // Solar
````
