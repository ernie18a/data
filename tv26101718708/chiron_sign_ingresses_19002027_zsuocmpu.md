# Chiron Sign Ingresses 1900-2027

- url: https://www.tradingview.com/script/ZsUOcMPu-Chiron-Sign-Ingresses-1900-2027/
- type: indicator
- pine_id: PUB;5933421bf997499996ab5f176448a55b
- version: 1.0

## Description

This indicator marks each Chiron sign ingress from 1900 through 2027 with a vertical beige line directly on the price chart. Each line is labeled with the corresponding zodiac sign, making it easy to visually study how Chiron’s movement through the zodiac aligns with historical market cycles and turning points.

Retrograde sign ingresses are shown with dashed lines, while direct ingresses are shown with solid lines. This tool is designed for financial astrology research and cycle analysis, helping traders compare Chiron’s long-term astrological timing with price action across different markets.

## Source Code

````pine
//@version=6
indicator("Chiron Sign Ingresses 1900-2027", overlay=true, max_lines_count=200, max_labels_count=200)

// Inputs
lineColor     = input.color(color.rgb(222, 200, 160), "Line Color - Beige")
lineWidth     = input.int(1, "Line Width", minval=1, maxval=5)
showLabels    = input.bool(true, "Show Zodiac Sign Labels")
useExactTimes = input.bool(false, "Use Exact CSV Event Times")

// Arrays
var int[] ingressTimes = array.new_int()
var bool[] ingressIsRx = array.new_bool()
var string[] ingressLabels = array.new_string()

// Helper function
addIngress(int y, int m, int d, int h, int min, bool isRx, string txt) =>
    eventTime = useExactTimes ? timestamp("America/New_York", y, m, d, h, min) : timestamp("America/New_York", y, m, d, 0, 0)
    array.push(ingressTimes, eventTime)
    array.push(ingressIsRx, isRx)
    array.push(ingressLabels, txt)

// Load CSV-derived dates after 1900
if barstate.isfirst
    addIngress(1901, 1, 12, 20, 14, false, "Capricorn")
    addIngress(1901, 8, 8, 12, 4, true, "Sagittarius RX")
    addIngress(1901, 9, 29, 19, 9, false, "Capricorn")

    addIngress(1904, 4, 22, 7, 37, false, "Aquarius")
    addIngress(1904, 5, 20, 9, 58, true, "Capricorn RX")
    addIngress(1905, 1, 12, 20, 48, false, "Aquarius")

    addIngress(1910, 3, 20, 3, 33, false, "Pisces")
    addIngress(1910, 8, 29, 5, 12, true, "Aquarius RX")
    addIngress(1911, 1, 15, 4, 27, false, "Pisces")

    addIngress(1918, 3, 31, 6, 45, false, "Aries")
    addIngress(1918, 10, 22, 12, 39, true, "Pisces RX")
    addIngress(1919, 1, 28, 12, 46, false, "Aries")

    addIngress(1926, 5, 24, 21, 55, false, "Taurus")
    addIngress(1926, 10, 20, 2, 54, true, "Aries RX")
    addIngress(1927, 3, 25, 6, 16, false, "Taurus")

    addIngress(1933, 6, 6, 22, 21, false, "Gemini")
    addIngress(1933, 12, 22, 2, 42, true, "Taurus RX")
    addIngress(1934, 3, 23, 9, 2, false, "Gemini")

    addIngress(1937, 8, 27, 13, 13, false, "Cancer")
    addIngress(1937, 11, 22, 21, 10, true, "Gemini RX")
    addIngress(1938, 5, 28, 8, 35, false, "Cancer")

    addIngress(1940, 9, 29, 22, 37, false, "Leo")
    addIngress(1940, 12, 27, 0, 6, true, "Cancer RX")
    addIngress(1941, 6, 16, 14, 30, false, "Leo")

    addIngress(1943, 7, 26, 18, 38, false, "Virgo")

    addIngress(1944, 11, 17, 23, 19, false, "Libra")
    addIngress(1945, 3, 23, 22, 55, true, "Virgo RX")
    addIngress(1945, 7, 22, 12, 26, false, "Libra")

    addIngress(1946, 11, 10, 2, 11, false, "Scorpio")

    addIngress(1948, 11, 28, 7, 57, false, "Sagittarius")

    addIngress(1951, 2, 8, 20, 25, false, "Capricorn")
    addIngress(1951, 6, 18, 9, 12, true, "Sagittarius RX")
    addIngress(1951, 11, 8, 11, 22, false, "Capricorn")

    addIngress(1955, 1, 27, 11, 29, false, "Aquarius")

    addIngress(1960, 3, 26, 8, 41, false, "Pisces")
    addIngress(1960, 8, 19, 2, 28, true, "Aquarius RX")
    addIngress(1961, 1, 20, 20, 51, false, "Pisces")

    addIngress(1968, 4, 1, 2, 9, false, "Aries")
    addIngress(1968, 10, 18, 18, 32, true, "Pisces RX")
    addIngress(1969, 1, 30, 3, 14, false, "Aries")

    addIngress(1976, 5, 28, 7, 12, false, "Taurus")
    addIngress(1976, 10, 13, 18, 43, true, "Aries RX")
    addIngress(1977, 3, 28, 14, 6, false, "Taurus")

    addIngress(1983, 6, 21, 9, 55, false, "Gemini")
    addIngress(1983, 11, 29, 8, 17, true, "Taurus RX")
    addIngress(1984, 4, 10, 23, 19, false, "Gemini")

    addIngress(1988, 6, 21, 5, 40, false, "Cancer")

    addIngress(1991, 7, 21, 11, 53, false, "Leo")

    addIngress(1993, 9, 3, 13, 31, false, "Virgo")

    addIngress(1995, 9, 9, 10, 27, false, "Libra")

    addIngress(1996, 12, 29, 6, 16, false, "Scorpio")
    addIngress(1997, 4, 4, 11, 48, true, "Libra RX")
    addIngress(1997, 9, 2, 23, 25, false, "Scorpio")

    addIngress(1999, 1, 7, 5, 29, false, "Sagittarius")
    addIngress(1999, 6, 1, 5, 49, true, "Scorpio RX")
    addIngress(1999, 9, 21, 22, 32, false, "Sagittarius")

    addIngress(2001, 12, 11, 18, 5, false, "Capricorn")

    addIngress(2005, 2, 21, 12, 35, false, "Aquarius")
    addIngress(2005, 7, 31, 23, 43, true, "Capricorn RX")
    addIngress(2005, 12, 5, 20, 6, false, "Aquarius")

    addIngress(2010, 4, 20, 2, 33, false, "Pisces")
    addIngress(2010, 7, 20, 5, 39, true, "Aquarius RX")
    addIngress(2011, 2, 8, 14, 58, false, "Pisces")

    addIngress(2018, 4, 17, 4, 11, false, "Aries")
    addIngress(2018, 9, 25, 20, 9, true, "Pisces RX")
    addIngress(2019, 2, 18, 4, 9, false, "Aries")

    addIngress(2026, 6, 19, 17, 20, false, "Taurus")
    addIngress(2026, 9, 17, 21, 50, true, "Aries RX")
    addIngress(2027, 4, 14, 10, 58, false, "Taurus")

// Draw lines once
var bool linesDrawn = false

if barstate.islast and not linesDrawn
    for i = 0 to array.size(ingressTimes) - 1
        t = array.get(ingressTimes, i)
        isRx = array.get(ingressIsRx, i)
        txt = array.get(ingressLabels, i)

        line.new(
             x1=t,
             y1=low,
             x2=t,
             y2=high,
             xloc=xloc.bar_time,
             extend=extend.both,
             color=lineColor,
             width=lineWidth,
             style=isRx ? line.style_dashed : line.style_solid
        )

        if showLabels
            label.new(
                 x=t,
                 y=high,
                 text=txt,
                 xloc=xloc.bar_time,
                 yloc=yloc.price,
                 style=label.style_label_down,
                 color=color.new(lineColor, 0),
                 textcolor=color.black,
                 size=size.tiny
            )

    linesDrawn := true
````
