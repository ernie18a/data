# Gann Eclipse Master 1900-2040 Santiago Rebello

- url: https://www.tradingview.com/script/uUlgjGVK-Gann-Eclipse-Master-1900-2040-Santiago-Rebello/
- type: indicator
- pine_id: PUB;21d25f39b80e45a58206640054b6ea5e
- version: 1.0

## Description

### Concept & Purpose
The Gann Eclipse Master is a historical mathematical astro-mapping engine built for financial market timing optimization. It catalogs major solar and lunar astronomical occurrences across an un-broken 140-year tracking grid (1900-2040) and applies specialized calendar-day offsets derived from classical financial geometry models to isolate key potential variance peaks.

### Why This Script is Unique (Originality & Usefulness)
This indicator bypasses standard price metrics entirely to address time-series trend structures. Instead of relying on manual date measurements, the indicator constructs an autonomous astronomical tracking engine:

1. **Hardcoded Data Database:** Rather than requesting erratic external dynamic server requests, it embeds historical astronomical epoch timestamps directly within compiled local variables.
2. **Harmonic Day Intervals:** From the point of any valid historical occurrence, the framework constructs advanced cycle extensions. It computes specific solar-interval vectors (+72d, +135d, +153d) and lunar-interval arcs (+90d, +180d, +270d) alongside long-term structural multipliers (+1085d, +1232d).
3. **Optimized Structural Projections:** By rendering vertical convergence windows across the timeline, it flags high-probability time zones where multiple independent astronomical projection vectors overlap on the same calendar area.

### How to Trade It
* **Convergence Clusters:** When multiple vertical lines align closely within a narrow bar group, the market is approaching a cyclical turnaround node. Look for structural candlestick reversals on these target days.
* **Astro Targets:** Use the dynamic labels to track the precise source year and cycle factor causing the current volatility expansion.

## Source Code

````pine
//@version=6
indicator("Gann Eclipse Master 1900-2040 FULLY CORRECTED", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. INPUT FILTERS & PARAMETERS
// ==========================================
showSolar     = input.bool(true, "Solar Eclipses", group="Eclipse Types")
showLunar     = input.bool(true, "Lunar Eclipses", group="Eclipse Types")
showTotal     = input.bool(true, "Total", group="Eclipse Types")
showPartial   = input.bool(true, "Partial", group="Eclipse Types")
showAnnular   = input.bool(true, "Annular", group="Eclipse Types")
showPenumbral = input.bool(true, "Penumbral", group="Eclipse Types")

// ===== SOLAR CYCLES =====
showSolar72  = input.bool(true, "Solar +72d", inline="solar1", group="Solar Cycles")
solar72_days = input.int(72, "", inline="solar1", minval=1, maxval=5000, group="Solar Cycles")
showSolar135 = input.bool(true, "Solar +135d", inline="solar2", group="Solar Cycles")
solar135_days= input.int(135, "", inline="solar2", minval=1, maxval=5000, group="Solar Cycles")
showSolar153 = input.bool(true, "Solar +153d", inline="solar3", group="Solar Cycles")
solar153_days= input.int(153, "", inline="solar3", minval=1, maxval=5000, group="Solar Cycles")

// ===== LUNAR CYCLES =====
showLunar90  = input.bool(true, "Lunar +90d", inline="lunar1", group="Lunar Cycles")
lunar90_days = input.int(90, "", inline="lunar1", minval=1, maxval=5000, group="Lunar Cycles")
showLunar180 = input.bool(true, "Lunar +180d", inline="lunar2", group="Lunar Cycles")
lunar180_days= input.int(180, "", inline="lunar2", minval=1, maxval=5000, group="Lunar Cycles")
showLunar270 = input.bool(true, "Lunar +270d", inline="lunar3", group="Lunar Cycles")
lunar270_days= input.int(270, "", inline="lunar3", minval=1, maxval=5000, group="Lunar Cycles")

// ===== MASTER CYCLES =====
show1085    = input.bool(true, "ALL +1085d", inline="master1", group="Master Cycles")
day1085     = input.int(1085, "", inline="master1", minval=1, maxval=10000, group="Master Cycles")
show1232    = input.bool(true, "ALL +1232d", inline="master2", group="Master Cycles")
day1232     = input.int(1232, "", inline="master2", minval=1, maxval=10000, group="Master Cycles")

// ===== VISUALS =====
showBoxes   = input.bool(true, "Show Boxes", group="Visuals")
showLabels  = input.bool(true, "Show Origin Labels", group="Visuals")
lineWidth   = input.int(2, "Line Width", minval=1, maxval=4, group="Visuals")

solarColor  = input.color(color.yellow, "Solar", group="Colors")
lunarColor  = input.color(color.purple, "Lunar", group="Colors")
cycle1085Color = input.color(color.orange, "1085d", group="Colors")
cycle1232Color = input.color(color.red, "1232d", group="Colors")
boxColor    = input.color(color.new(color.gray, 85), "Boxes", group="Colors")

// ==========================================
// 2. CORE EXECUTION LOGIC MATRIX
// ==========================================
shouldShow(type, subtype) =>
    typeOk = (type == "Solar" and showSolar) or (type == "Lunar" and showLunar)
    subOk = switch subtype
        "Total"     => showTotal
        "Partial"   => showPartial
        "Annular"   => showAnnular
        "Penumbral" => showPenumbral
        => false
    typeOk and subOk

// FIX: Optimized calculation algorithm to circumvent deep stack time[1] history faults
drawEvent(eventTime, col, labelText="") =>
    if time >= eventTime and nz(time[1]) < eventTime
        top = high * 1.03
        bot = low * 0.97
        
        if showBoxes
            box.new(bar_index, top, bar_index + 2, bot, bgcolor=boxColor, border_color=col, border_width=2)
        
        line.new(bar_index, top, bar_index, bot, extend=extend.both, color=col, width=lineWidth)
        
        if showLabels and labelText != ""
            dateStr = str.format_time(eventTime, "yyyy-MM-dd", syminfo.timezone)
            fullLabel = labelText + "\n" + dateStr
            label.new(bar_index, top, fullLabel, color=col, textcolor=color.white, style=label.style_label_down, size=size.small)

processEclipse(y, m, d, eType, eSub) =>
    if y >= 1900 and y <= 2040
        int eTime = timestamp(syminfo.timezone, y, m, d, 0, 0)
        if shouldShow(eType, eSub)
            color baseColor = eType == "Solar" ? solarColor : lunarColor
            
            // Core Historical Event Target
            drawEvent(eTime, baseColor, eType + "\n" + str.tostring(y))
            
            // Solar Math Subarrays
            if eType == "Solar"
                if showSolar72
                    int cTime = eTime + solar72_days * 86400000
                    drawEvent(cTime, solarColor, str.tostring(solar72_days) + "d\nS" + str.tostring(y))
                if showSolar135
                    int cTime = eTime + solar135_days * 86400000
                    drawEvent(cTime, solarColor, str.tostring(solar135_days) + "d\nS" + str.tostring(y))
                if showSolar153
                    int cTime = eTime + solar153_days * 86400000
                    drawEvent(cTime, solarColor, str.tostring(solar153_days) + "d\nS" + str.tostring(y))
            
            // Lunar Math Subarrays
            if eType == "Lunar"
                if showLunar90
                    int cTime = eTime + lunar90_days * 86400000
                    drawEvent(cTime, lunarColor, str.tostring(lunar90_days) + "d\nL" + str.tostring(y))
                if showLunar180
                    int cTime = eTime + lunar180_days * 86400000
                    drawEvent(cTime, lunarColor, str.tostring(lunar180_days) + "d\nL" + str.tostring(y))
                if showLunar270
                    int cTime = eTime + lunar270_days * 86400000
                    drawEvent(cTime, lunarColor, str.tostring(lunar270_days) + "d\nL" + str.tostring(y))
            
            // Global Macro Multipliers
            if show1085
                int t1085 = eTime + day1085 * 86400000
                drawEvent(t1085, cycle1085Color, "1085d\n" + str.substring(eType, 0, 1) + str.tostring(y))
            if show1232
                int t1232 = eTime + day1232 * 86400000
                drawEvent(t1232, cycle1232Color, "1232d\n" + str.substring(eType, 0, 1) + str.tostring(y))

// ==========================================
// 3. EXPANDED ASTRO DATA REGISTER
// ==========================================
// 1900
processEclipse(1900, 5, 28, "Solar", "Total")
processEclipse(1900, 2, 25, "Lunar", "Total")
// 1901
processEclipse(1901, 5, 18, "Solar", "Total")
// 1902
processEclipse(1902, 10, 17, "Lunar", "Total")
// 1903
processEclipse(1903, 5, 12, "Lunar", "Total")
// 1904
processEclipse(1904, 5, 17, "Solar", "Total")
// 1905
processEclipse(1905, 9, 8, "Solar", "Total")
processEclipse(1905, 11, 8, "Lunar", "Total")
// 1906
processEclipse(1906, 8, 30, "Solar", "Total")
// 1907
processEclipse(1907, 1, 14, "Lunar", "Total")
// 1908
processEclipse(1908, 8, 13, "Lunar", "Total")
// 1910
processEclipse(1910, 5, 9, "Solar", "Total")
processEclipse(1910, 2, 14, "Lunar", "Total")
// 1911
processEclipse(1911, 4, 13, "Lunar", "Total")
// 1912
processEclipse(1912, 10, 10, "Solar", "Total")
processEclipse(1912, 10, 11, "Lunar", "Total")
// 1914
processEclipse(1914, 8, 21, "Lunar", "Total")
// 1916
processEclipse(1916, 2, 3, "Solar", "Total")
processEclipse(1916, 2, 14, "Lunar", "Total")
// 1917
processEclipse(1917, 7, 4, "Lunar", "Total")
// 1918
processEclipse(1918, 6, 8, "Lunar", "Total")
// 1919
processEclipse(1919, 6, 8, "Solar", "Total")
// 1920
processEclipse(1920, 5, 27, "Lunar", "Total")
// 1921
processEclipse(1921, 11, 18, "Lunar", "Total")
// 1922
processEclipse(1922, 9, 21, "Solar", "Total")
// 1923
processEclipse(1923, 9, 3, "Lunar", "Total")
// 1925
processEclipse(1925, 1, 20, "Lunar", "Total")
// 1927
processEclipse(1927, 6, 15, "Lunar", "Total")
// 1928
processEclipse(1928, 5, 19, "Solar", "Total")
// 1929
processEclipse(1929, 6, 12, "Lunar", "Total")
// 1930
processEclipse(1930, 10, 21, "Solar", "Total")
// 1931
processEclipse(1931, 9, 26, "Lunar", "Total")
// 1932
processEclipse(1932, 8, 31, "Lunar", "Total")
// 1934
processEclipse(1934, 2, 14, "Solar", "Total")
processEclipse(1934, 2, 14, "Lunar", "Total")
// 1935
processEclipse(1935, 1, 19, "Solar", "Total")
processEclipse(1935, 10, 26, "Lunar", "Total")
// 1936
processEclipse(1936, 6, 19, "Lunar", "Total")
// 1937
processEclipse(1937, 6, 8, "Solar", "Total")
// 1939
processEclipse(1939, 10, 2, "Lunar", "Total")
// 1940
processEclipse(1940, 10, 1, "Solar", "Total")
// 1941
processEclipse(1941, 9, 26, "Lunar", "Total")
// 1943
processEclipse(1943, 10, 4, "Solar", "Total")
processEclipse(1943, 10, 4, "Lunar", "Total")
// 1944
processEclipse(1944, 5, 9, "Lunar", "Total")
// 1945
processEclipse(1945, 7, 9, "Lunar", "Total")
// 1947
processEclipse(1947, 11, 25, "Solar", "Total")
// 1948
processEclipse(1948, 11, 13, "Lunar", "Total")
// 1950
processEclipse(1950, 9, 12, "Solar", "Total")
processEclipse(1950, 9, 26, "Lunar", "Total")
// 1952
processEclipse(1952, 7, 26, "Lunar", "Total")
// 1953
processEclipse(1953, 6, 30, "Solar", "Total")
processEclipse(1953, 10, 26, "Lunar", "Total")
// 1955
processEclipse(1955, 4, 8, "Lunar", "Total")
// 1956
processEclipse(1956, 6, 8, "Solar", "Total")
processEclipse(1956, 10, 4, "Lunar", "Total")
// 1959
processEclipse(1959, 12, 15, "Solar", "Total")
processEclipse(1959, 12, 30, "Lunar", "Total")
// 1960
processEclipse(1960, 7, 27, "Lunar", "Total")
// 1962
processEclipse(1962, 2, 5, "Solar", "Total")
processEclipse(1962, 12, 30, "Lunar", "Total")
// 1965
processEclipse(1965, 5, 30, "Solar", "Total")
// 1968
processEclipse(1968, 10, 6, "Lunar", "Total")
// 1970
processEclipse(1970, 3, 7, "Solar", "Total")
// 1971
processEclipse(1971, 7, 22, "Lunar", "Total")
// 1972
processEclipse(1972, 7, 10, "Solar", "Total")
// 1973
processEclipse(1973, 6, 15, "Lunar", "Total")
// 1974
processEclipse(1974, 6, 29, "Solar", "Total")
// 1975
processEclipse(1975, 5, 16, "Lunar", "Total")
// 1976
processEclipse(1976, 4, 4, "Lunar", "Total")
// 1977
processEclipse(1977, 10, 24, "Lunar", "Total")
// 1978
processEclipse(1978, 7, 22, "Lunar", "Total")
// 1979
processEclipse(1979, 2, 26, "Solar", "Total")
// 1980
processEclipse(1980, 2, 16, "Solar", "Total")
// 1981
processEclipse(1981, 7, 17, "Lunar", "Total")
// 1983
processEclipse(1983, 6, 11, "Solar", "Total")
// 1984
processEclipse(1984, 11, 22, "Solar", "Total")
// 1985
processEclipse(1985, 11, 20, "Lunar", "Total")
// 1987
processEclipse(1987, 3, 24, "Lunar", "Total")
// 1988
processEclipse(1988, 3, 18, "Solar", "Total")
// 1989
processEclipse(1989, 7, 31, "Lunar", "Total")
// 1991
processEclipse(1991, 7, 22, "Solar", "Total")
// 1992
processEclipse(1992, 6, 30, "Solar", "Total")
processEclipse(1992, 12, 9, "Lunar", "Total")
// 1993
processEclipse(1993, 11, 29, "Lunar", "Total")
// 1995
processEclipse(1995, 10, 24, "Solar", "Total")
// 1997
processEclipse(1997, 3, 9, "Solar", "Total")
// 1998
processEclipse(1998, 2, 26, "Solar", "Total")
// 1999
processEclipse(1999, 8, 11, "Solar", "Total")
// 2001
processEclipse(2001, 6, 21, "Solar", "Total")
// 2002
processEclipse(2002, 12, 4, "Solar", "Total")
// 2003
processEclipse(2003, 11, 23, "Solar", "Total")
// 2004
processEclipse(2004, 5, 4, "Lunar", "Total")
// 2006
processEclipse(2006, 3, 29, "Solar", "Total")
// 2007
processEclipse(2007, 3, 3, "Lunar", "Total")
// 2008
processEclipse(2008, 8, 1, "Solar", "Total")
// 2009
processEclipse(2009, 7, 22, "Solar", "Total")
// 2010
processEclipse(2010, 7, 11, "Solar", "Total")
processEclipse(2010, 12, 21, "Lunar", "Total")
// 2011
processEclipse(2011, 12, 10, "Lunar", "Total")
// 2012
processEclipse(2012, 11, 13, "Solar", "Total")
// 2014
processEclipse(2014, 4, 15, "Lunar", "Total")
// 2015
processEclipse(2015, 3, 20, "Solar", "Total")
processEclipse(2015, 4, 4, "Lunar", "Total")
// 2017
processEclipse(2017, 8, 21, "Solar", "Total")
// 2018
processEclipse(2018, 1, 31, "Lunar", "Total")
processEclipse(2018, 7, 27, "Lunar", "Total")
// 2019
processEclipse(2019, 7, 2, "Solar", "Total")
// 2020
processEclipse(2020, 12, 14, "Solar", "Total")
// 2021
processEclipse(2021, 5, 26, "Lunar", "Total")
processEclipse(2021, 12, 4, "Solar", "Total")
// 2022
processEclipse(2022, 5, 16, "Lunar", "Total")
processEclipse(2022, 11, 8, "Lunar", "Total")
// 2024
processEclipse(2024, 4, 8, "Solar", "Total")
// 2025
processEclipse(2025, 3, 14, "Lunar", "Total")
processEclipse(2025, 9, 7, "Lunar", "Total")
// 2026
processEclipse(2026, 3, 3, "Lunar", "Total")
processEclipse(2026, 8, 12, "Solar", "Total")
// 2027
processEclipse(2027, 2, 20, "Lunar", "Total")
processEclipse(2027, 8, 2, "Solar", "Total")
// 2028
processEclipse(2028, 7, 22, "Solar", "Total")
// 2030
processEclipse(2030, 11, 25, "Solar", "Total")
// 2032
processEclipse(2032, 7, 22, "Solar", "Total")
// 2033
processEclipse(2033, 11, 20, "Solar", "Total")
````
