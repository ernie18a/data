# Algol Outer Orbit: Periastron + Apastron Dates

- url: https://www.tradingview.com/script/lRFJ6u1M-Algol-Outer-Orbit-Periastron-Apastron-Dates/
- type: indicator
- pine_id: PUB;3ac6b7a680b7476e9542392bbc1edfc3
- version: 1.0

## Description

Algol Outer Orbit Indicator

Plots vertical lines marking the periastron and apastron dates of Algol’s F-type companion in its ~1.86-year orbit around the inner eclipsing binary pair.

Teal solid lines = Periastron / closest approach
Orange dashed lines = Apastron / farthest separation

Designed for researching whether Algol’s outer orbital cycle correlates with market pivots, volatility windows, or broader timing patterns.

## Source Code

````pine
//@version=5
indicator("Algol Outer Orbit: Periastron + Apastron Dates", overlay=true, max_lines_count=300, max_labels_count=300)

// Dates are plotted at 00:00 UTC.
// Periastron = closest approach of Algol C / F-type star
// Apastron   = farthest point of Algol C / F-type star

showPeriastron = input.bool(true, "Show Periastron")
showApastron   = input.bool(true, "Show Apastron")
showLabels     = input.bool(false, "Show Labels")

periastronColor = input.color(color.new(color.teal, 0), "Periastron Line Color")
apastronColor   = input.color(color.new(color.orange, 0), "Apastron Line Color")
lineWidth       = input.int(1, "Line Width", minval=1, maxval=4)

var int[] eventTimes = array.new_int()
var bool[] eventIsPeriastron = array.new_bool()
var bool drawn = false

addEvent(int _y, int _m, int _d, bool _isPeriastron) =>
    array.push(eventTimes, timestamp("UTC", _y, _m, _d, 0, 0))
    array.push(eventIsPeriastron, _isPeriastron)

if barstate.isfirst
    addEvent(1899, 10, 31, true)   // Cycle -47 periastron
    addEvent(1900, 10, 6, false)   // Cycle -47 apastron
    addEvent(1901, 9, 11, true)    // Cycle -46 periastron
    addEvent(1902, 8, 18, false)   // Cycle -46 apastron
    addEvent(1903, 7, 24, true)    // Cycle -45 periastron
    addEvent(1904, 6, 28, false)   // Cycle -45 apastron
    addEvent(1905, 6, 3, true)     // Cycle -44 periastron
    addEvent(1906, 5, 9, false)    // Cycle -44 apastron
    addEvent(1907, 4, 14, true)    // Cycle -43 periastron
    addEvent(1908, 3, 19, false)   // Cycle -43 apastron
    addEvent(1909, 2, 22, true)    // Cycle -42 periastron
    addEvent(1910, 1, 28, false)   // Cycle -42 apastron
    addEvent(1911, 1, 3, true)     // Cycle -41 periastron
    addEvent(1911, 12, 9, false)   // Cycle -41 apastron
    addEvent(1912, 11, 14, true)   // Cycle -40 periastron
    addEvent(1913, 10, 20, false)  // Cycle -40 apastron
    addEvent(1914, 9, 25, true)    // Cycle -39 periastron
    addEvent(1915, 8, 31, false)   // Cycle -39 apastron
    addEvent(1916, 8, 5, true)     // Cycle -38 periastron
    addEvent(1917, 7, 11, false)   // Cycle -38 apastron
    addEvent(1918, 6, 16, true)    // Cycle -37 periastron
    addEvent(1919, 5, 22, false)   // Cycle -37 apastron
    addEvent(1920, 4, 26, true)    // Cycle -36 periastron
    addEvent(1921, 4, 1, false)    // Cycle -36 apastron
    addEvent(1922, 3, 7, true)     // Cycle -35 periastron
    addEvent(1923, 2, 10, false)   // Cycle -35 apastron
    addEvent(1924, 1, 17, true)    // Cycle -34 periastron
    addEvent(1924, 12, 22, false)  // Cycle -34 apastron
    addEvent(1925, 11, 27, true)   // Cycle -33 periastron
    addEvent(1926, 11, 2, false)   // Cycle -33 apastron
    addEvent(1927, 10, 8, true)    // Cycle -32 periastron
    addEvent(1928, 9, 12, false)   // Cycle -32 apastron
    addEvent(1929, 8, 18, true)    // Cycle -31 periastron
    addEvent(1930, 7, 24, false)   // Cycle -31 apastron
    addEvent(1931, 6, 29, true)    // Cycle -30 periastron
    addEvent(1932, 6, 3, false)    // Cycle -30 apastron
    addEvent(1933, 5, 9, true)     // Cycle -29 periastron
    addEvent(1934, 4, 14, false)   // Cycle -29 apastron
    addEvent(1935, 3, 21, true)    // Cycle -28 periastron
    addEvent(1936, 2, 24, false)   // Cycle -28 apastron
    addEvent(1937, 1, 29, true)    // Cycle -27 periastron
    addEvent(1938, 1, 4, false)    // Cycle -27 apastron
    addEvent(1938, 12, 10, true)   // Cycle -26 periastron
    addEvent(1939, 11, 15, false)  // Cycle -26 apastron
    addEvent(1940, 10, 20, true)   // Cycle -25 periastron
    addEvent(1941, 9, 25, false)   // Cycle -25 apastron
    addEvent(1942, 8, 31, true)    // Cycle -24 periastron
    addEvent(1943, 8, 6, false)    // Cycle -24 apastron
    addEvent(1944, 7, 11, true)    // Cycle -23 periastron
    addEvent(1945, 6, 16, false)   // Cycle -23 apastron
    addEvent(1946, 5, 23, true)    // Cycle -22 periastron
    addEvent(1947, 4, 28, false)   // Cycle -22 apastron
    addEvent(1948, 4, 2, true)     // Cycle -21 periastron
    addEvent(1949, 3, 8, false)    // Cycle -21 apastron
    addEvent(1950, 2, 11, true)    // Cycle -20 periastron
    addEvent(1951, 1, 17, false)   // Cycle -20 apastron
    addEvent(1951, 12, 23, true)   // Cycle -19 periastron
    addEvent(1952, 11, 27, false)  // Cycle -19 apastron
    addEvent(1953, 11, 2, true)    // Cycle -18 periastron
    addEvent(1954, 10, 8, false)   // Cycle -18 apastron
    addEvent(1955, 9, 13, true)    // Cycle -17 periastron
    addEvent(1956, 8, 18, false)   // Cycle -17 apastron
    addEvent(1957, 7, 25, true)    // Cycle -16 periastron
    addEvent(1958, 6, 30, false)   // Cycle -16 apastron
    addEvent(1959, 6, 5, true)     // Cycle -15 periastron
    addEvent(1960, 5, 10, false)   // Cycle -15 apastron
    addEvent(1961, 4, 15, true)    // Cycle -14 periastron
    addEvent(1962, 3, 21, false)   // Cycle -14 apastron
    addEvent(1963, 2, 24, true)    // Cycle -13 periastron
    addEvent(1964, 1, 30, false)   // Cycle -13 apastron
    addEvent(1965, 1, 4, true)     // Cycle -12 periastron
    addEvent(1965, 12, 10, false)  // Cycle -12 apastron
    addEvent(1966, 11, 15, true)   // Cycle -11 periastron
    addEvent(1967, 10, 21, false)  // Cycle -11 apastron
    addEvent(1968, 9, 26, true)    // Cycle -10 periastron
    addEvent(1969, 9, 1, false)    // Cycle -10 apastron
    addEvent(1970, 8, 7, true)     // Cycle -9 periastron
    addEvent(1971, 7, 13, false)   // Cycle -9 apastron
    addEvent(1972, 6, 17, true)    // Cycle -8 periastron
    addEvent(1973, 5, 23, false)   // Cycle -8 apastron
    addEvent(1974, 4, 28, true)    // Cycle -7 periastron
    addEvent(1975, 4, 3, false)    // Cycle -7 apastron
    addEvent(1976, 3, 8, true)     // Cycle -6 periastron
    addEvent(1977, 2, 11, false)   // Cycle -6 apastron
    addEvent(1978, 1, 17, true)    // Cycle -5 periastron
    addEvent(1978, 12, 23, false)  // Cycle -5 apastron
    addEvent(1979, 11, 29, true)   // Cycle -4 periastron
    addEvent(1980, 11, 3, false)   // Cycle -4 apastron
    addEvent(1981, 10, 9, true)    // Cycle -3 periastron
    addEvent(1982, 9, 14, false)   // Cycle -3 apastron
    addEvent(1983, 8, 20, true)    // Cycle -2 periastron
    addEvent(1984, 7, 25, false)   // Cycle -2 apastron
    addEvent(1985, 6, 30, true)    // Cycle -1 periastron
    addEvent(1986, 6, 5, false)    // Cycle -1 apastron
    addEvent(1987, 5, 11, true)    // Cycle 0 periastron
    addEvent(1988, 4, 15, false)   // Cycle 0 apastron
    addEvent(1989, 3, 21, true)    // Cycle 1 periastron
    addEvent(1990, 2, 24, false)   // Cycle 1 apastron
    addEvent(1991, 1, 31, true)    // Cycle 2 periastron
    addEvent(1992, 1, 6, false)    // Cycle 2 apastron
    addEvent(1992, 12, 11, true)   // Cycle 3 periastron
    addEvent(1993, 11, 16, false)  // Cycle 3 apastron
    addEvent(1994, 10, 22, true)   // Cycle 4 periastron
    addEvent(1995, 9, 27, false)   // Cycle 4 apastron
    addEvent(1996, 9, 1, true)     // Cycle 5 periastron
    addEvent(1997, 8, 7, false)    // Cycle 5 apastron
    addEvent(1998, 7, 13, true)    // Cycle 6 periastron
    addEvent(1999, 6, 18, false)   // Cycle 6 apastron
    addEvent(2000, 5, 23, true)    // Cycle 7 periastron
    addEvent(2001, 4, 28, false)   // Cycle 7 apastron
    addEvent(2002, 4, 4, true)     // Cycle 8 periastron
    addEvent(2003, 3, 10, false)   // Cycle 8 apastron
    addEvent(2004, 2, 13, true)    // Cycle 9 periastron
    addEvent(2005, 1, 18, false)   // Cycle 9 apastron
    addEvent(2005, 12, 24, true)   // Cycle 10 periastron
    addEvent(2006, 11, 29, false)  // Cycle 10 apastron
    addEvent(2007, 11, 4, true)    // Cycle 11 periastron
    addEvent(2008, 10, 9, false)   // Cycle 11 apastron
    addEvent(2009, 9, 14, true)    // Cycle 12 periastron
    addEvent(2010, 8, 20, false)   // Cycle 12 apastron
    addEvent(2011, 7, 26, true)    // Cycle 13 periastron
    addEvent(2012, 6, 30, false)   // Cycle 13 apastron
    addEvent(2013, 6, 6, true)     // Cycle 14 periastron
    addEvent(2014, 5, 12, false)   // Cycle 14 apastron
    addEvent(2015, 4, 17, true)    // Cycle 15 periastron
    addEvent(2016, 3, 22, false)   // Cycle 15 apastron
    addEvent(2017, 2, 25, true)    // Cycle 16 periastron
    addEvent(2018, 1, 31, false)   // Cycle 16 apastron
    addEvent(2019, 1, 6, true)     // Cycle 17 periastron
    addEvent(2019, 12, 12, false)  // Cycle 17 apastron
    addEvent(2020, 11, 16, true)   // Cycle 18 periastron
    addEvent(2021, 10, 22, false)  // Cycle 18 apastron
    addEvent(2022, 9, 27, true)    // Cycle 19 periastron
    addEvent(2023, 9, 2, false)    // Cycle 19 apastron
    addEvent(2024, 8, 8, true)     // Cycle 20 periastron
    addEvent(2025, 7, 14, false)   // Cycle 20 apastron
    addEvent(2026, 6, 19, true)    // Cycle 21 periastron
    addEvent(2027, 5, 25, false)   // Cycle 21 apastron
    addEvent(2028, 4, 29, true)    // Cycle 22 periastron
    addEvent(2029, 4, 4, false)    // Cycle 22 apastron
    addEvent(2030, 3, 10, true)    // Cycle 23 periastron

if barstate.islast and not drawn
    for i = 0 to array.size(eventTimes) - 1
        eventTime = array.get(eventTimes, i)
        isPeri = array.get(eventIsPeriastron, i)

        shouldDraw = (isPeri and showPeriastron) or (not isPeri and showApastron)

        if shouldDraw
            lineColor = isPeri ? periastronColor : apastronColor
            lineStyle = isPeri ? line.style_solid : line.style_dashed
            labelText = isPeri ? "Algol Periastron" : "Algol Apastron"

            line.new(
                 x1=eventTime,
                 y1=close,
                 x2=eventTime,
                 y2=close + syminfo.mintick,
                 xloc=xloc.bar_time,
                 extend=extend.both,
                 color=lineColor,
                 style=lineStyle,
                 width=lineWidth
             )

            if showLabels
                label.new(
                     x=eventTime,
                     y=close,
                     xloc=xloc.bar_time,
                     text=labelText,
                     style=label.style_label_down,
                     textcolor=color.white,
                     color=color.new(lineColor, 0),
                     size=size.tiny
                 )

    drawn := true
````
