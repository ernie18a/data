# Mercury Retrograde 2030

- url: https://www.tradingview.com/script/MYOl35KZ-Mercury-Retrograde-2030/
- type: indicator
- pine_id: PUB;8de5c420e13547098b525f7d0798b196
- version: 1.0

## Description

Mercury Retrograde 2010–2030
Astro cycles

retrograde motion occurs when a planet appears to move backward in its orbit as observed from Earth. This is an optical illusion caused by the relative positions and speeds of Earth and the other planets as they orbit the Sun. Since Earth moves faster on its inner orbit, it can “overtake” outer planets, making those planets appear to reverse direction temporarily.

    Mercury Retrograde: The most famous and frequent, happening about three to four times a year, lasting roughly three weeks each time.
    Venus Retrograde: Occurs approximately every 18 months, lasting about 40-43 days.
    Mars Retrograde: Happens roughly every two years for about two months.
    Outer Planets Retrogrades (Jupiter, Saturn, Uranus, Neptune, Pluto): These planets retrograde once a year or so, lasting several months but with subtler daily impacts.

    Communication and Technology (Mercury Retrograde): Expect misunderstandings, delays, and technical glitches. It’s a good time to revisit old projects rather than start new ones.
    Relationships and Finances (Venus Retrograde): Past relationships may resurface, and financial decisions require extra care. Reflection on values, love, and money is key.
    Action and Ambition (Mars Retrograde): Energy slows down, and patience is tested. Impulsive actions may backfire; use the time to refine strategies.
    Expansion and Opportunities (Jupiter Retrograde): Growth slows for reflection, focusing on inner wisdom rather than external expansion.
    Structure and Discipline (Saturn Retrograde): Reexamine rules, responsibilities, and long-term goals.
    Sudden Change and Innovation (Uranus Retrograde): Internalize revolutionary impulses, reevaluate freedom and progress.
    Dreams and Spirituality (Neptune Retrograde): Heightened intuition but also confusion. Reflect on beliefs and creative inspiration.
    Transformation and Power (Pluto Retrograde): Deep inner transformation, confronting fears, and releasing control issues.

## Source Code

````pine
//@version=6
indicator("Mercury Retrograde 2010–2030", overlay=true, max_boxes_count=100, max_labels_count=200)

//────────────────────────────────────
// SETTINGS
//────────────────────────────────────

showHistorical = input.bool(true, "Shade Historical / Current")
showFuture     = input.bool(true, "Show Future Retrogrades")
showMarkers    = input.bool(true, "Show RX / Direct Markers")

retroColor  = input.color(color.new(color.purple, 85), "Retrograde Color")
borderColor = input.color(color.new(color.purple, 30), "Future Border")
startColor  = input.color(color.purple, "RX Start")
endColor    = input.color(color.teal, "Direct End")

//────────────────────────────────────
// FUNCTIONS
//────────────────────────────────────

inPeriod(startTime, endTime) =>
    time >= startTime and time < endTime

drawFutureZone(startTime, endTime, textLabel) =>
    if barstate.islast and showFuture and endTime > timenow
        float topPrice = close * 1.25
        float bottomPrice = close * 0.75

        box.new(
             left=startTime,
             top=topPrice,
             right=endTime,
             bottom=bottomPrice,
             xloc=xloc.bar_time,
             bgcolor=retroColor,
             border_color=borderColor)

        label.new(
             x=startTime,
             y=topPrice,
             text=textLabel,
             xloc=xloc.bar_time,
             style=label.style_label_down,
             color=startColor,
             textcolor=color.white,
             size=size.tiny)

//────────────────────────────────────
// 2010
//────────────────────────────────────

r2010_1 = inPeriod(timestamp("Etc/UTC",2010,4,18,3,51), timestamp("Etc/UTC",2010,5,11,22,37))
r2010_2 = inPeriod(timestamp("Etc/UTC",2010,8,20,19,56), timestamp("Etc/UTC",2010,9,12,23,9))
r2010_3 = inPeriod(timestamp("Etc/UTC",2010,12,10,11,45), timestamp("Etc/UTC",2010,12,30,7,26))

// 2011
r2011_1 = inPeriod(timestamp("Etc/UTC",2011,3,30,20,36), timestamp("Etc/UTC",2011,4,23,10,0))
r2011_2 = inPeriod(timestamp("Etc/UTC",2011,8,3,3,35), timestamp("Etc/UTC",2011,8,26,22,6))
r2011_3 = inPeriod(timestamp("Etc/UTC",2011,11,24,7,7), timestamp("Etc/UTC",2011,12,14,1,48))

// 2012
r2012_1 = inPeriod(timestamp("Etc/UTC",2012,3,12,7,46), timestamp("Etc/UTC",2012,4,4,9,57))
r2012_2 = inPeriod(timestamp("Etc/UTC",2012,7,15,2,4), timestamp("Etc/UTC",2012,8,8,5,36))
r2012_3 = inPeriod(timestamp("Etc/UTC",2012,11,6,22,58), timestamp("Etc/UTC",2012,11,26,22,39))

// 2013
r2013_1 = inPeriod(timestamp("Etc/UTC",2013,2,23,9,37), timestamp("Etc/UTC",2013,3,17,19,58))
r2013_2 = inPeriod(timestamp("Etc/UTC",2013,6,26,13,14), timestamp("Etc/UTC",2013,7,20,18,10))
r2013_3 = inPeriod(timestamp("Etc/UTC",2013,10,21,10,25), timestamp("Etc/UTC",2013,11,10,21,13))

// 2014
r2014_1 = inPeriod(timestamp("Etc/UTC",2014,2,6,21,29), timestamp("Etc/UTC",2014,2,28,14,3))
r2014_2 = inPeriod(timestamp("Etc/UTC",2014,6,7,11,51), timestamp("Etc/UTC",2014,7,1,12,54))
r2014_3 = inPeriod(timestamp("Etc/UTC",2014,10,4,16,58), timestamp("Etc/UTC",2014,10,25,19,29))

// 2015
r2015_1 = inPeriod(timestamp("Etc/UTC",2015,1,21,15,29), timestamp("Etc/UTC",2015,2,11,14,56))
r2015_2 = inPeriod(timestamp("Etc/UTC",2015,5,19,1,31), timestamp("Etc/UTC",2015,6,11,22,41))
r2015_3 = inPeriod(timestamp("Etc/UTC",2015,9,17,17,57), timestamp("Etc/UTC",2015,10,9,15,5))

// 2016
r2016_1 = inPeriod(timestamp("Etc/UTC",2016,1,5,12,44), timestamp("Etc/UTC",2016,1,25,21,44))
r2016_2 = inPeriod(timestamp("Etc/UTC",2016,4,28,17,19), timestamp("Etc/UTC",2016,5,22,13,5))
r2016_3 = inPeriod(timestamp("Etc/UTC",2016,8,30,12,52), timestamp("Etc/UTC",2016,9,22,5,29))
r2016_4 = inPeriod(timestamp("Etc/UTC",2016,12,19,10,49), timestamp("Etc/UTC",2017,1,8,9,39))

// 2017
r2017_1 = inPeriod(timestamp("Etc/UTC",2017,4,9,23,14), timestamp("Etc/UTC",2017,5,3,16,25))
r2017_2 = inPeriod(timestamp("Etc/UTC",2017,8,13,1,1), timestamp("Etc/UTC",2017,9,5,11,20))
r2017_3 = inPeriod(timestamp("Etc/UTC",2017,12,3,7,25), timestamp("Etc/UTC",2017,12,23,1,46))

// 2018
r2018_1 = inPeriod(timestamp("Etc/UTC",2018,3,23,0,6), timestamp("Etc/UTC",2018,4,15,9,27))
r2018_2 = inPeriod(timestamp("Etc/UTC",2018,7,26,5,3), timestamp("Etc/UTC",2018,8,19,4,18))
r2018_3 = inPeriod(timestamp("Etc/UTC",2018,11,17,1,17), timestamp("Etc/UTC",2018,12,6,21,25))

// 2019
r2019_1 = inPeriod(timestamp("Etc/UTC",2019,3,5,18,5), timestamp("Etc/UTC",2019,3,28,13,58))
r2019_2 = inPeriod(timestamp("Etc/UTC",2019,7,7,23,1), timestamp("Etc/UTC",2019,8,1,4,3))
r2019_3 = inPeriod(timestamp("Etc/UTC",2019,10,31,15,26), timestamp("Etc/UTC",2019,11,20,19,25))

// 2020
r2020_1 = inPeriod(timestamp("Etc/UTC",2020,2,17,0,41), timestamp("Etc/UTC",2020,3,10,3,37))
r2020_2 = inPeriod(timestamp("Etc/UTC",2020,6,18,4,47), timestamp("Etc/UTC",2020,7,12,8,25))
r2020_3 = inPeriod(timestamp("Etc/UTC",2020,10,14,0,56), timestamp("Etc/UTC",2020,11,3,17,58))

// 2021
r2021_1 = inPeriod(timestamp("Etc/UTC",2021,1,30,15,40), timestamp("Etc/UTC",2021,2,21,0,44))
r2021_2 = inPeriod(timestamp("Etc/UTC",2021,5,29,22,40), timestamp("Etc/UTC",2021,6,22,21,47))
r2021_3 = inPeriod(timestamp("Etc/UTC",2021,9,27,5,10), timestamp("Etc/UTC",2021,10,18,15,11))

// 2022
r2022_1 = inPeriod(timestamp("Etc/UTC",2022,1,14,11,32), timestamp("Etc/UTC",2022,2,4,4,11))
r2022_2 = inPeriod(timestamp("Etc/UTC",2022,5,10,11,42), timestamp("Etc/UTC",2022,6,3,8,5))
r2022_3 = inPeriod(timestamp("Etc/UTC",2022,9,10,3,41), timestamp("Etc/UTC",2022,10,2,9,4))
r2022_4 = inPeriod(timestamp("Etc/UTC",2022,12,29,9,16), timestamp("Etc/UTC",2023,1,18,13,10))

// 2023
r2023_1 = inPeriod(timestamp("Etc/UTC",2023,4,21,8,17), timestamp("Etc/UTC",2023,5,15,3,24))
r2023_2 = inPeriod(timestamp("Etc/UTC",2023,8,23,19,50), timestamp("Etc/UTC",2023,9,15,20,22))
r2023_3 = inPeriod(timestamp("Etc/UTC",2023,12,13,6,41), timestamp("Etc/UTC",2024,1,2,3,2))

// 2024
r2024_1 = inPeriod(timestamp("Etc/UTC",2024,4,1,22,9), timestamp("Etc/UTC",2024,4,25,12,42))
r2024_2 = inPeriod(timestamp("Etc/UTC",2024,8,5,4,40), timestamp("Etc/UTC",2024,8,28,21,14))
r2024_3 = inPeriod(timestamp("Etc/UTC",2024,11,26,2,27), timestamp("Etc/UTC",2024,12,15,20,57))

// 2025
r2025_1 = inPeriod(timestamp("Etc/UTC",2025,3,15,6,45), timestamp("Etc/UTC",2025,4,7,10,57))
r2025_2 = inPeriod(timestamp("Etc/UTC",2025,7,18,4,41), timestamp("Etc/UTC",2025,8,11,7,20))
r2025_3 = inPeriod(timestamp("Etc/UTC",2025,11,9,18,59), timestamp("Etc/UTC",2025,11,29,17,48))

// 2026
s2026_1 = timestamp("Etc/UTC",2026,2,26,6,41)
e2026_1 = timestamp("Etc/UTC",2026,3,20,19,35)

s2026_2 = timestamp("Etc/UTC",2026,6,29,17,40)
e2026_2 = timestamp("Etc/UTC",2026,7,23,22,52)

s2026_3 = timestamp("Etc/UTC",2026,10,24,7,14)
e2026_3 = timestamp("Etc/UTC",2026,11,13,15,57)

r2026_1 = inPeriod(s2026_1,e2026_1)
r2026_2 = inPeriod(s2026_2,e2026_2)
r2026_3 = inPeriod(s2026_3,e2026_3)

// 2027
s2027_1 = timestamp("Etc/UTC",2027,2,9,17,26)
e2027_1 = timestamp("Etc/UTC",2027,3,3,12,35)

s2027_2 = timestamp("Etc/UTC",2027,6,10,18,5)
e2027_2 = timestamp("Etc/UTC",2027,7,4,19,49)

s2027_3 = timestamp("Etc/UTC",2027,10,7,14,30)
e2027_3 = timestamp("Etc/UTC",2027,10,28,14,15)

r2027_1 = inPeriod(s2027_1,e2027_1)
r2027_2 = inPeriod(s2027_2,e2027_2)
r2027_3 = inPeriod(s2027_3,e2027_3)

// 2028
s2028_1 = timestamp("Etc/UTC",2028,1,24,10,48)
e2028_1 = timestamp("Etc/UTC",2028,2,14,12,30)

s2028_2 = timestamp("Etc/UTC",2028,5,21,8,30)
e2028_2 = timestamp("Etc/UTC",2028,6,14,6,4)

s2028_3 = timestamp("Etc/UTC",2028,9,19,16,20)
e2028_3 = timestamp("Etc/UTC",2028,10,11,10,33)

r2028_1 = inPeriod(s2028_1,e2028_1)
r2028_2 = inPeriod(s2028_2,e2028_2)
r2028_3 = inPeriod(s2028_3,e2028_3)

// 2029
s2029_1 = timestamp("Etc/UTC",2029,1,7,7,34)
e2029_1 = timestamp("Etc/UTC",2029,1,27,18,29)

s2029_2 = timestamp("Etc/UTC",2029,5,1,23,9)
e2029_2 = timestamp("Etc/UTC",2029,5,25,19,4)

s2029_3 = timestamp("Etc/UTC",2029,9,2,12,12)
e2029_3 = timestamp("Etc/UTC",2029,9,25,1,58)

s2029_4 = timestamp("Etc/UTC",2029,12,22,5,32)
e2029_4 = timestamp("Etc/UTC",2030,1,11,5,42)

r2029_1 = inPeriod(s2029_1,e2029_1)
r2029_2 = inPeriod(s2029_2,e2029_2)
r2029_3 = inPeriod(s2029_3,e2029_3)
r2029_4 = inPeriod(s2029_4,e2029_4)

// 2030
s2030_1 = timestamp("Etc/UTC",2030,4,13,2,27)
e2030_1 = timestamp("Etc/UTC",2030,5,6,20,18)

s2030_2 = timestamp("Etc/UTC",2030,8,16,1,25)
e2030_2 = timestamp("Etc/UTC",2030,9,8,9,21)

s2030_3 = timestamp("Etc/UTC",2030,12,6,2,39)
e2030_3 = timestamp("Etc/UTC",2030,12,25,21,24)

r2030_1 = inPeriod(s2030_1,e2030_1)
r2030_2 = inPeriod(s2030_2,e2030_2)
r2030_3 = inPeriod(s2030_3,e2030_3)

//────────────────────────────────────
// COMBINE ALL PERIODS
//────────────────────────────────────

isRetrograde =
     r2010_1 or r2010_2 or r2010_3 or
     r2011_1 or r2011_2 or r2011_3 or
     r2012_1 or r2012_2 or r2012_3 or
     r2013_1 or r2013_2 or r2013_3 or
     r2014_1 or r2014_2 or r2014_3 or
     r2015_1 or r2015_2 or r2015_3 or
     r2016_1 or r2016_2 or r2016_3 or r2016_4 or
     r2017_1 or r2017_2 or r2017_3 or
     r2018_1 or r2018_2 or r2018_3 or
     r2019_1 or r2019_2 or r2019_3 or
     r2020_1 or r2020_2 or r2020_3 or
     r2021_1 or r2021_2 or r2021_3 or
     r2022_1 or r2022_2 or r2022_3 or r2022_4 or
     r2023_1 or r2023_2 or r2023_3 or
     r2024_1 or r2024_2 or r2024_3 or
     r2025_1 or r2025_2 or r2025_3 or
     r2026_1 or r2026_2 or r2026_3 or
     r2027_1 or r2027_2 or r2027_3 or
     r2028_1 or r2028_2 or r2028_3 or
     r2029_1 or r2029_2 or r2029_3 or r2029_4 or
     r2030_1 or r2030_2 or r2030_3

//────────────────────────────────────
// HISTORICAL SHADING
//────────────────────────────────────

bgcolor(showHistorical and isRetrograde ? retroColor : na)

//────────────────────────────────────
// START / END MARKERS
//────────────────────────────────────

retroStart = isRetrograde and not isRetrograde[1]
retroEnd   = not isRetrograde and isRetrograde[1]

plotshape(
     showMarkers and retroStart,
     title="Mercury Retrograde Start",
     style=shape.labeldown,
     location=location.abovebar,
     color=startColor,
     textcolor=color.white,
     text="☿ RX",
     size=size.tiny)

plotshape(
     showMarkers and retroEnd,
     title="Mercury Direct",
     style=shape.labelup,
     location=location.belowbar,
     color=endColor,
     textcolor=color.white,
     text="☿ D",
     size=size.tiny)

//────────────────────────────────────
// FUTURE PROJECTED BOXES
//────────────────────────────────────

drawFutureZone(s2026_3,e2026_3,"☿ RX\nOct 24–Nov 13")

drawFutureZone(s2027_1,e2027_1,"☿ RX\nFeb 9–Mar 3")
drawFutureZone(s2027_2,e2027_2,"☿ RX\nJun 10–Jul 4")
drawFutureZone(s2027_3,e2027_3,"☿ RX\nOct 7–Oct 28")

drawFutureZone(s2028_1,e2028_1,"☿ RX\nJan 24–Feb 14")
drawFutureZone(s2028_2,e2028_2,"☿ RX\nMay 21–Jun 14")
drawFutureZone(s2028_3,e2028_3,"☿ RX\nSep 19–Oct 11")

drawFutureZone(s2029_1,e2029_1,"☿ RX\nJan 7–Jan 27")
drawFutureZone(s2029_2,e2029_2,"☿ RX\nMay 1–May 25")
drawFutureZone(s2029_3,e2029_3,"☿ RX\nSep 2–Sep 25")
drawFutureZone(s2029_4,e2029_4,"☿ RX\nDec 22–Jan 11")

drawFutureZone(s2030_1,e2030_1,"☿ RX\nApr 13–May 6")
drawFutureZone(s2030_2,e2030_2,"☿ RX\nAug 16–Sep 8")
drawFutureZone(s2030_3,e2030_3,"☿ RX\nDec 6–Dec 25")
````
