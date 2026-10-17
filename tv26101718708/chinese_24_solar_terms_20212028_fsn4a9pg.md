# Chinese 24 Solar Terms (2021-2028)

- url: https://www.tradingview.com/script/fsN4A9pG-Chinese-24-Solar-Terms-2021-2028/
- type: indicator
- pine_id: PUB;84553ec14a1346c8a9a36f02c76642a5
- version: 2.0

## Description

24 Solar Terms (二十四节气) — Traditional Chinese Calendar Markers
This indicator plots the 24 Solar Terms (Jieqi) of the traditional Chinese calendar directly on your chart as vertical lines with bilingual labels (Chinese + English), covering the full period from 2021 to 2028.
The 24 Solar Terms divide the solar year into 24 segments based on the sun's position along the ecliptic. Each term marks a distinct seasonal transition. Because the exact date of each term shifts by ±1 day year to year, this script uses a hand-verified date table (Beijing time, UTC+8) rather than fixed dates, so the markers stay accurate across all years covered.
How traders use it: some market participants track calendar-based cycles and seasonal turning points. These markers let you visually align price action with recurring annual reference points and judge for yourself whether any term coincides with notable swings in your instrument. This is a reference/annotation tool — it generates no buy or sell signals and makes no predictive claims.
Notes:

Dates are based on Beijing time (UTC+8). On charts displayed in UTC, terms near midnight may appear shifted by one day.
Each term is marked once per day; works on daily and intraday timeframes.
To see markers before recent years, scroll left to load more historical bars (subject to your TradingView plan's history limit).

## Source Code

````pine
//@version=6
indicator("Chinese 24 Solar Terms + Mercury Retrograde (2021-2035)", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

show_retro   = input.bool(true,  "Show Mercury Retrograde (orange)")
show_future  = input.bool(true,  "Project upcoming solar terms (yellow)")

// ============ 节气日期表 SOLAR TERMS (Beijing time UTC+8) ============
getTerm(int y, int m, int d) =>
    string r = ""
    if y == 2021
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==3
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2022
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==6
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2023
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==6
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==21
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==6
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==6
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==8
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==8
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==24
            r := "霜降 Frost's Descent"
        if m==11 and d==8
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2024
        if m==1 and d==6
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==19
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==20
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==6
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==22
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==22
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==6
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2025
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==3
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2026
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2027
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==6
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==21
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==6
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==6
            r := "芒种 Grain in Ear"
        if m==6 and d==22
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==8
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==8
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==9
            r := "寒露 Cold Dew"
        if m==10 and d==24
            r := "霜降 Frost's Descent"
        if m==11 and d==8
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2028
        if m==1 and d==6
            r := "小寒 Minor Cold"
        if m==1 and d==21
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==19
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==20
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==6
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==22
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==22
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==21
            r := "小雪 Minor Snow"
        if m==12 and d==6
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2029
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==3
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==22
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2030
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2031
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==6
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==21
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==6
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==6
            r := "芒种 Grain in Ear"
        if m==6 and d==22
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==8
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==8
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==9
            r := "寒露 Cold Dew"
        if m==10 and d==24
            r := "霜降 Frost's Descent"
        if m==11 and d==8
            r := "立冬 Start of Winter"
        if m==11 and d==23
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2032
        if m==1 and d==6
            r := "小寒 Minor Cold"
        if m==1 and d==21
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==19
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==20
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==6
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==22
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==22
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==21
            r := "小雪 Minor Snow"
        if m==12 and d==6
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2033
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==3
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==4
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==22
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==21
            r := "冬至 Winter Solstice"
    if y == 2034
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==18
            r := "雨水 Rain Water"
        if m==3 and d==5
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==20
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==5
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==5
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==7
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==7
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==23
            r := "霜降 Frost's Descent"
        if m==11 and d==7
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    if y == 2035
        if m==1 and d==5
            r := "小寒 Minor Cold"
        if m==1 and d==20
            r := "大寒 Major Cold"
        if m==2 and d==4
            r := "立春 Start of Spring"
        if m==2 and d==19
            r := "雨水 Rain Water"
        if m==3 and d==6
            r := "惊蛰 Awakening of Insects"
        if m==3 and d==21
            r := "春分 Spring Equinox"
        if m==4 and d==5
            r := "清明 Clear and Bright"
        if m==4 and d==20
            r := "谷雨 Grain Rain"
        if m==5 and d==6
            r := "立夏 Start of Summer"
        if m==5 and d==21
            r := "小满 Grain Buds"
        if m==6 and d==6
            r := "芒种 Grain in Ear"
        if m==6 and d==21
            r := "夏至 Summer Solstice"
        if m==7 and d==7
            r := "小暑 Minor Heat"
        if m==7 and d==23
            r := "大暑 Major Heat"
        if m==8 and d==8
            r := "立秋 Start of Autumn"
        if m==8 and d==23
            r := "处暑 End of Heat"
        if m==9 and d==8
            r := "白露 White Dew"
        if m==9 and d==23
            r := "秋分 Autumn Equinox"
        if m==10 and d==8
            r := "寒露 Cold Dew"
        if m==10 and d==24
            r := "霜降 Frost's Descent"
        if m==11 and d==8
            r := "立冬 Start of Winter"
        if m==11 and d==22
            r := "小雪 Minor Snow"
        if m==12 and d==7
            r := "大雪 Major Snow"
        if m==12 and d==22
            r := "冬至 Winter Solstice"
    r

// ============ 节气：历史标记（在已存在的K线上） ============
// SOLAR TERMS — historical markers on existing bars
term = getTerm(year, month, dayofmonth)
is_term = term != ""
new_day = ta.change(time("D")) != 0
is_future = time > timenow

if is_term and new_day and barstate.isconfirmed
    lcolor = is_future ? color.yellow : color.gray
    lstyle = is_future ? line.style_solid : line.style_dotted
    line.new(bar_index, high, bar_index, low, xloc.bar_index, extend.both, lcolor, lstyle, 1)
    label.new(bar_index, high, term, color=color.new(color.yellow, 80), textcolor=color.yellow, size=size.small, style=label.style_label_down)

// ============ 节气：未来投影（用时间坐标，画到K线右侧空白处） ============
// SOLAR TERMS — FUTURE projection using bar_time xloc (draws past the last candle)
// 未来节气没有对应K线，必须用 xloc.bar_time + 时间戳，才能画在价格右侧
var futureTimes  = array.new<int>()
var futureLabels = array.new<string>()
if barstate.isfirst
    // 未来节气：直接 push，不用嵌套函数（v6 不允许函数内定义函数）
    // upcoming terms pushed inline (v6 forbids nested function defs)
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 7, 7, 12, 0)), array.push(futureLabels, "小暑 Minor Heat")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 7, 23, 12, 0)), array.push(futureLabels, "大暑 Major Heat")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 8, 7, 12, 0)), array.push(futureLabels, "立秋 Start of Autumn")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 8, 23, 12, 0)), array.push(futureLabels, "处暑 End of Heat")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 9, 7, 12, 0)), array.push(futureLabels, "白露 White Dew")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 9, 23, 12, 0)), array.push(futureLabels, "秋分 Autumn Equinox")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 10, 8, 12, 0)), array.push(futureLabels, "寒露 Cold Dew")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 10, 23, 12, 0)), array.push(futureLabels, "霜降 Frost's Descent")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 11, 7, 12, 0)), array.push(futureLabels, "立冬 Start of Winter")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 11, 22, 12, 0)), array.push(futureLabels, "小雪 Minor Snow")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 12, 7, 12, 0)), array.push(futureLabels, "大雪 Major Snow")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2026, 12, 22, 12, 0)), array.push(futureLabels, "冬至 Winter Solstice")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 1, 5, 12, 0)), array.push(futureLabels, "小寒 Minor Cold")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 1, 20, 12, 0)), array.push(futureLabels, "大寒 Major Cold")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 2, 4, 12, 0)), array.push(futureLabels, "立春 Start of Spring")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 2, 19, 12, 0)), array.push(futureLabels, "雨水 Rain Water")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 3, 6, 12, 0)), array.push(futureLabels, "惊蛰 Awakening of Insects")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 3, 21, 12, 0)), array.push(futureLabels, "春分 Spring Equinox")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 4, 5, 12, 0)), array.push(futureLabels, "清明 Clear and Bright")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 4, 20, 12, 0)), array.push(futureLabels, "谷雨 Grain Rain")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 5, 6, 12, 0)), array.push(futureLabels, "立夏 Start of Summer")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 5, 21, 12, 0)), array.push(futureLabels, "小满 Grain Buds")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 6, 6, 12, 0)), array.push(futureLabels, "芒种 Grain in Ear")
    array.push(futureTimes, timestamp("Asia/Shanghai", 2027, 6, 22, 12, 0)), array.push(futureLabels, "夏至 Summer Solstice")

// 在最后一根实时K线上，一次性画出所有未来节气竖线
// On the last bar, draw all still-future term lines once using time coordinates
if show_future and barstate.islast
    for i = 0 to array.size(futureTimes) - 1
        ft = array.get(futureTimes, i)
        if ft > timenow
            ln = line.new(ft, low, ft, high, xloc.bar_time, extend.both, color.yellow, line.style_solid, 1)
            label.new(ft, high, array.get(futureLabels, i), xloc=xloc.bar_time, color=color.new(color.yellow, 80), textcolor=color.yellow, size=size.small, style=label.style_label_down)

// ============ 水星逆行 MERCURY RETROGRADE ============
// 过去/现在：橙色背景 bgcolor + 起始标签
// 未来：橙色方框 box(xloc.bar_time) + 标签，画在价格右侧空白处
// Past/present: orange bgcolor + label at start. Future: orange time-boxed area + label.

dnum = year * 10000 + month * 100 + dayofmonth

inRetro2(int dn) =>
    bool h = false
    h := h or (dn >= 20210130 and dn <= 20210220)
    h := h or (dn >= 20210529 and dn <= 20210622)
    h := h or (dn >= 20210927 and dn <= 20211018)
    h := h or (dn >= 20220114 and dn <= 20220203)
    h := h or (dn >= 20220510 and dn <= 20220603)
    h := h or (dn >= 20220909 and dn <= 20221002)
    h := h or (dn >= 20221229 and dn <= 20230118)
    h := h or (dn >= 20230421 and dn <= 20230514)
    h := h or (dn >= 20230823 and dn <= 20230915)
    h := h or (dn >= 20231213 and dn <= 20240101)
    h := h or (dn >= 20240401 and dn <= 20240425)
    h := h or (dn >= 20240804 and dn <= 20240828)
    h := h or (dn >= 20241125 and dn <= 20241215)
    h := h or (dn >= 20250315 and dn <= 20250407)
    h := h or (dn >= 20250718 and dn <= 20250811)
    h := h or (dn >= 20251109 and dn <= 20251129)
    h := h or (dn >= 20260226 and dn <= 20260320)
    h := h or (dn >= 20260629 and dn <= 20260723)
    h := h or (dn >= 20261024 and dn <= 20261113)
    h := h or (dn >= 20270209 and dn <= 20270303)
    h := h or (dn >= 20270610 and dn <= 20270704)
    h := h or (dn >= 20271007 and dn <= 20271028)
    h := h or (dn >= 20280124 and dn <= 20280214)
    h := h or (dn >= 20280521 and dn <= 20280614)
    h := h or (dn >= 20280919 and dn <= 20281011)
    h := h or (dn >= 20290107 and dn <= 20290127)
    h := h or (dn >= 20290501 and dn <= 20290525)
    h := h or (dn >= 20290902 and dn <= 20290924)
    h := h or (dn >= 20291222 and dn <= 20300111)
    h := h or (dn >= 20300412 and dn <= 20300506)
    h := h or (dn >= 20300815 and dn <= 20300908)
    h := h or (dn >= 20301205 and dn <= 20301225)
    h := h or (dn >= 20310325 and dn <= 20310418)
    h := h or (dn >= 20310729 and dn <= 20310822)
    h := h or (dn >= 20311119 and dn <= 20311209)
    h := h or (dn >= 20320307 and dn <= 20320330)
    h := h or (dn >= 20320709 and dn <= 20320803)
    h := h or (dn >= 20321102 and dn <= 20321122)
    h := h or (dn >= 20330218 and dn <= 20330312)
    h := h or (dn >= 20330621 and dn <= 20330715)
    h := h or (dn >= 20331016 and dn <= 20331106)
    h := h or (dn >= 20340202 and dn <= 20340223)
    h := h or (dn >= 20340602 and dn <= 20340626)
    h := h or (dn >= 20340929 and dn <= 20341021)
    h := h or (dn >= 20350117 and dn <= 20350206)
    h := h or (dn >= 20350513 and dn <= 20350606)
    h := h or (dn >= 20350912 and dn <= 20351005)
    h := h or (dn >= 20351231 and dn <= 20360121)
    h

retro = inRetro2(dnum)
// 历史/当前：背景着色
bgcolor(show_retro and retro ? color.new(color.orange, 85) : na, title="Mercury Retrograde")

// 在每段逆行的第一天放一个文字标签（仅历史/当前K线）
// label on the first day of each retrograde (existing bars only)
retro_starts_today = retro and not retro[1]
if show_retro and retro_starts_today and barstate.isconfirmed
    label.new(bar_index, low, "☿ Mercury Retrograde", yloc=yloc.belowbar, color=color.new(color.orange, 20), textcolor=color.white, size=size.small, style=label.style_label_up)

// 未来逆行区间：用时间坐标方框标出（无K线，bgcolor 无效）
// FUTURE retrogrades: time-coordinate boxes (no candles exist, so bgcolor can't paint them)
var array<int> frStart = array.new<int>()
var array<int> frEnd   = array.new<int>()
if barstate.isfirst
    array.push(frStart, timestamp("America/New_York",2021,1,30,0,0)), array.push(frEnd, timestamp("America/New_York",2021,2,20,23,59))
    array.push(frStart, timestamp("America/New_York",2021,5,29,0,0)), array.push(frEnd, timestamp("America/New_York",2021,6,22,23,59))
    array.push(frStart, timestamp("America/New_York",2021,9,27,0,0)), array.push(frEnd, timestamp("America/New_York",2021,10,18,23,59))
    array.push(frStart, timestamp("America/New_York",2022,1,14,0,0)), array.push(frEnd, timestamp("America/New_York",2022,2,3,23,59))
    array.push(frStart, timestamp("America/New_York",2022,5,10,0,0)), array.push(frEnd, timestamp("America/New_York",2022,6,3,23,59))
    array.push(frStart, timestamp("America/New_York",2022,9,9,0,0)), array.push(frEnd, timestamp("America/New_York",2022,10,2,23,59))
    array.push(frStart, timestamp("America/New_York",2022,12,29,0,0)), array.push(frEnd, timestamp("America/New_York",2023,1,18,23,59))
    array.push(frStart, timestamp("America/New_York",2023,4,21,0,0)), array.push(frEnd, timestamp("America/New_York",2023,5,14,23,59))
    array.push(frStart, timestamp("America/New_York",2023,8,23,0,0)), array.push(frEnd, timestamp("America/New_York",2023,9,15,23,59))
    array.push(frStart, timestamp("America/New_York",2023,12,13,0,0)), array.push(frEnd, timestamp("America/New_York",2024,1,1,23,59))
    array.push(frStart, timestamp("America/New_York",2024,4,1,0,0)), array.push(frEnd, timestamp("America/New_York",2024,4,25,23,59))
    array.push(frStart, timestamp("America/New_York",2024,8,4,0,0)), array.push(frEnd, timestamp("America/New_York",2024,8,28,23,59))
    array.push(frStart, timestamp("America/New_York",2024,11,25,0,0)), array.push(frEnd, timestamp("America/New_York",2024,12,15,23,59))
    array.push(frStart, timestamp("America/New_York",2025,3,15,0,0)), array.push(frEnd, timestamp("America/New_York",2025,4,7,23,59))
    array.push(frStart, timestamp("America/New_York",2025,7,18,0,0)), array.push(frEnd, timestamp("America/New_York",2025,8,11,23,59))
    array.push(frStart, timestamp("America/New_York",2025,11,9,0,0)), array.push(frEnd, timestamp("America/New_York",2025,11,29,23,59))
    array.push(frStart, timestamp("America/New_York",2026,2,26,0,0)), array.push(frEnd, timestamp("America/New_York",2026,3,20,23,59))
    array.push(frStart, timestamp("America/New_York",2026,6,29,0,0)), array.push(frEnd, timestamp("America/New_York",2026,7,23,23,59))
    array.push(frStart, timestamp("America/New_York",2026,10,24,0,0)), array.push(frEnd, timestamp("America/New_York",2026,11,13,23,59))
    array.push(frStart, timestamp("America/New_York",2027,2,9,0,0)), array.push(frEnd, timestamp("America/New_York",2027,3,3,23,59))
    array.push(frStart, timestamp("America/New_York",2027,6,10,0,0)), array.push(frEnd, timestamp("America/New_York",2027,7,4,23,59))
    array.push(frStart, timestamp("America/New_York",2027,10,7,0,0)), array.push(frEnd, timestamp("America/New_York",2027,10,28,23,59))
    array.push(frStart, timestamp("America/New_York",2028,1,24,0,0)), array.push(frEnd, timestamp("America/New_York",2028,2,14,23,59))
    array.push(frStart, timestamp("America/New_York",2028,5,21,0,0)), array.push(frEnd, timestamp("America/New_York",2028,6,14,23,59))
    array.push(frStart, timestamp("America/New_York",2028,9,19,0,0)), array.push(frEnd, timestamp("America/New_York",2028,10,11,23,59))
    array.push(frStart, timestamp("America/New_York",2029,1,7,0,0)), array.push(frEnd, timestamp("America/New_York",2029,1,27,23,59))
    array.push(frStart, timestamp("America/New_York",2029,5,1,0,0)), array.push(frEnd, timestamp("America/New_York",2029,5,25,23,59))
    array.push(frStart, timestamp("America/New_York",2029,9,2,0,0)), array.push(frEnd, timestamp("America/New_York",2029,9,24,23,59))
    array.push(frStart, timestamp("America/New_York",2029,12,22,0,0)), array.push(frEnd, timestamp("America/New_York",2030,1,11,23,59))
    array.push(frStart, timestamp("America/New_York",2030,4,12,0,0)), array.push(frEnd, timestamp("America/New_York",2030,5,6,23,59))
    array.push(frStart, timestamp("America/New_York",2030,8,15,0,0)), array.push(frEnd, timestamp("America/New_York",2030,9,8,23,59))
    array.push(frStart, timestamp("America/New_York",2030,12,5,0,0)), array.push(frEnd, timestamp("America/New_York",2030,12,25,23,59))
    array.push(frStart, timestamp("America/New_York",2031,3,25,0,0)), array.push(frEnd, timestamp("America/New_York",2031,4,18,23,59))
    array.push(frStart, timestamp("America/New_York",2031,7,29,0,0)), array.push(frEnd, timestamp("America/New_York",2031,8,22,23,59))
    array.push(frStart, timestamp("America/New_York",2031,11,19,0,0)), array.push(frEnd, timestamp("America/New_York",2031,12,9,23,59))
    array.push(frStart, timestamp("America/New_York",2032,3,7,0,0)), array.push(frEnd, timestamp("America/New_York",2032,3,30,23,59))
    array.push(frStart, timestamp("America/New_York",2032,7,9,0,0)), array.push(frEnd, timestamp("America/New_York",2032,8,3,23,59))
    array.push(frStart, timestamp("America/New_York",2032,11,2,0,0)), array.push(frEnd, timestamp("America/New_York",2032,11,22,23,59))
    array.push(frStart, timestamp("America/New_York",2033,2,18,0,0)), array.push(frEnd, timestamp("America/New_York",2033,3,12,23,59))
    array.push(frStart, timestamp("America/New_York",2033,6,21,0,0)), array.push(frEnd, timestamp("America/New_York",2033,7,15,23,59))
    array.push(frStart, timestamp("America/New_York",2033,10,16,0,0)), array.push(frEnd, timestamp("America/New_York",2033,11,6,23,59))
    array.push(frStart, timestamp("America/New_York",2034,2,2,0,0)), array.push(frEnd, timestamp("America/New_York",2034,2,23,23,59))
    array.push(frStart, timestamp("America/New_York",2034,6,2,0,0)), array.push(frEnd, timestamp("America/New_York",2034,6,26,23,59))
    array.push(frStart, timestamp("America/New_York",2034,9,29,0,0)), array.push(frEnd, timestamp("America/New_York",2034,10,21,23,59))
    array.push(frStart, timestamp("America/New_York",2035,1,17,0,0)), array.push(frEnd, timestamp("America/New_York",2035,2,6,23,59))
    array.push(frStart, timestamp("America/New_York",2035,5,13,0,0)), array.push(frEnd, timestamp("America/New_York",2035,6,6,23,59))
    array.push(frStart, timestamp("America/New_York",2035,9,12,0,0)), array.push(frEnd, timestamp("America/New_York",2035,10,5,23,59))
    array.push(frStart, timestamp("America/New_York",2035,12,31,0,0)), array.push(frEnd, timestamp("America/New_York",2036,1,21,23,59))

if show_retro and barstate.islast
    for i = 0 to array.size(frStart) - 1
        s = array.get(frStart, i)
        e = array.get(frEnd, i)
        // 只处理结束时间在未来的逆行段 (only future retrogrades)
        if e > timenow
            // 用密集竖线填充整个逆行区间，外观与历史橙色背景一致（非方框）
            // fill the whole span with dense vertical lines — looks like the orange bgcolor band, not a box
            // 每 2 天画一根较粗竖线，视觉上连成一片橙色（总线数控制在上限内）
            // a wide vertical line every 2 days — merges into a solid orange band, stays under the line cap
            stepMs = 86400000 * 2
            t = s
            while t <= e
                line.new(t, low, t, high, xloc.bar_time, extend.both, color.new(color.orange, 85), line.style_solid, 4)
                t := t + stepMs
            // 段首放一个标签 label at the start of the span
            label.new(s, high, "☿ Mercury Retrograde", xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.orange, 20), textcolor=color.white, size=size.small, style=label.style_label_down)
````
