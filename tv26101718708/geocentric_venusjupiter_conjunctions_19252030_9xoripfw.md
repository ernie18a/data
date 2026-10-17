# Geocentric Venus/Jupiter Conjunctions 1925-2030

- url: https://www.tradingview.com/script/9xORIPFW-Geocentric-Venus-Jupiter-Conjunctions-1925-2030/
- type: indicator
- pine_id: PUB;15a45425bcc646beb6762a008f87cce5
- version: 1.0

## Description

This TradingView indicator plots vertical lines on historical and future GEO Venus/Jupiter conjunction dates. The standard event dates are marked with lavender vertical lines, while the highlighted red lines identify the subset of conjunctions that also occur square to Chiron. Each line includes event data such as the date and planetary position details, making it easier to visually compare these timing windows against price action across different markets.

## Source Code

````pine
//@version=6
indicator("LUNA 110 Events — Venus/Jupiter Conjunctions", overlay = true, max_lines_count = 500, max_labels_count = 500)

// Uses the exact event timestamps from the CSV in America/New_York time.
// Set Start year to 1950 if you want to reduce the number of plotted historical lines.
startYear      = input.int(1925, "Start year", minval = 1925, maxval = 2030)
lineWidth      = input.int(1, "Line width", minval = 1, maxval = 4)
showTags       = input.bool(true, "Show position tags")
tagTextMode    = input.string("Position", "Tag text", options = ["Position", "Date + Position", "Off"])
showInfoTable  = input.bool(true, "Show visible-range data table")
maxTableRows   = input.int(10, "Max visible events in table", minval = 1, maxval = 15)

lavender = color.rgb(181, 126, 220)
redLine  = color.rgb(255, 0, 0)
tagBg    = color.new(lavender, 20)
lineCol  = color.new(lavender, 0)

// These dates are highlighted in red.
f_isRedDate(string d) =>
    string day = str.substring(d, 0, 10)
    switch day
        "2026-06-09" => true
        "2019-11-24" => true
        "1997-02-05" => true
        "1958-11-06" => true
        "1940-02-20" => true
        "1925-11-26" => true
        => false

var int[]    eventTimes = array.new_int()
var int[]    eventYears = array.new_int()
var string[] eventDates = array.new_string()
var string[] eventPos   = array.new_string()
var string[] eventTips  = array.new_string()

var line[]  drawnLines  = array.new_line()
var label[] drawnLabels = array.new_label()
var table infoTable = table.new(position.top_right, 3, 16, border_width = 1)

f_addEvent(int t, int y, string d, string pos, string tip) =>
    array.push(eventTimes, t)
    array.push(eventYears, y)
    array.push(eventDates, d)
    array.push(eventPos, pos)
    array.push(eventTips, tip)

if barstate.isfirst
    f_addEvent(timestamp("America/New_York", 1925, 1, 20, 21, 15, 40), 1925, "1925-01-20 21:15 NY", "Venus/Jupiter 7° 41' 2\" Capricorn", "1925-01-20 21:15 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 7° 41' 2\" Capricorn\nJupiter: Direct 7° 41' 2\" Capricorn\nLongitude: 277.683905°")
    f_addEvent(timestamp("America/New_York", 1925, 11, 26, 15, 18, 57), 1925, "1925-11-26 15:18 NY", "Venus/Jupiter 21° 17' 44\" Capricorn", "1925-11-26 15:18 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 21° 17' 44\" Capricorn\nJupiter: Direct 21° 17' 44\" Capricorn\nLongitude: 291.295693°")
    f_addEvent(timestamp("America/New_York", 1926, 2, 22, 0, 38, 56), 1926, "1926-02-22 00:38 NY", "Venus/Jupiter 11° 3' 49\" Aquarius", "1926-02-22 00:38 NY\nWaxing Conjunction; Angle 0°\nVenus: Retrograde (RX) 11° 3' 49\" Aquarius\nJupiter: Direct 11° 3' 49\" Aquarius\nLongitude: 311.063738°")
    f_addEvent(timestamp("America/New_York", 1926, 3, 18, 21, 0, 38), 1926, "1926-03-18 21:00 NY", "Venus/Jupiter 16° 29' 43\" Aquarius", "1926-03-18 21:00 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 16° 29' 43\" Aquarius\nJupiter: Direct 16° 29' 43\" Aquarius\nLongitude: 316.495364°")
    f_addEvent(timestamp("America/New_York", 1927, 2, 5, 14, 14, 28), 1927, "1927-02-05 14:14 NY", "Venus/Jupiter 4° 11' 57\" Pisces", "1927-02-05 14:14 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 4° 11' 57\" Pisces\nJupiter: Direct 4° 11' 57\" Pisces\nLongitude: 334.199072°")
    f_addEvent(timestamp("America/New_York", 1928, 4, 29, 8, 17, 30), 1928, "1928-04-29 08:17 NY", "Venus/Jupiter 22° 2' 13\" Aries", "1928-04-29 08:17 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 22° 2' 13\" Aries\nJupiter: Direct 22° 2' 13\" Aries\nLongitude: 22.036837°")
    f_addEvent(timestamp("America/New_York", 1929, 7, 14, 17, 5, 13), 1929, "1929-07-14 17:05 NY", "Venus/Jupiter 6° 57' 16\" Gemini", "1929-07-14 17:05 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 6° 57' 16\" Gemini\nJupiter: Direct 6° 57' 16\" Gemini\nLongitude: 66.954337°")
    f_addEvent(timestamp("America/New_York", 1930, 5, 17, 11, 31, 25), 1930, "1930-05-17 11:31 NY", "Venus/Jupiter 20° 51' 42\" Gemini", "1930-05-17 11:31 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 20° 51' 42\" Gemini\nJupiter: Direct 20° 51' 42\" Gemini\nLongitude: 80.861685°")
    f_addEvent(timestamp("America/New_York", 1931, 8, 6, 16, 19, 31), 1931, "1931-08-06 16:19 NY", "Venus/Jupiter 4° 33' 16\" Leo", "1931-08-06 16:19 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 4° 33' 16\" Leo\nJupiter: Direct 4° 33' 16\" Leo\nLongitude: 124.554500°")
    f_addEvent(timestamp("America/New_York", 1932, 10, 19, 20, 56, 30), 1932, "1932-10-19 20:56 NY", "Venus/Jupiter 14° 38' 0\" Virgo", "1932-10-19 20:56 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 14° 38' 0\" Virgo\nJupiter: Direct 14° 38' 0\" Virgo\nLongitude: 164.633340°")
    f_addEvent(timestamp("America/New_York", 1933, 8, 17, 6, 13, 42), 1933, "1933-08-17 06:13 NY", "Venus/Jupiter 25° 4' 31\" Virgo", "1933-08-17 06:13 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 25° 4' 31\" Virgo\nJupiter: Direct 25° 4' 31\" Virgo\nLongitude: 175.075143°")
    f_addEvent(timestamp("America/New_York", 1934, 11, 1, 21, 48, 40), 1934, "1934-11-01 21:48 NY", "Venus/Jupiter 4° 45' 58\" Scorpio", "1934-11-01 21:48 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 4° 45' 58\" Scorpio\nJupiter: Direct 4° 45' 58\" Scorpio\nLongitude: 214.766198°")
    f_addEvent(timestamp("America/New_York", 1936, 1, 15, 16, 50, 11), 1936, "1936-01-15 16:50 NY", "Venus/Jupiter 14° 41' 35\" Sagittarius", "1936-01-15 16:50 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 14° 41' 35\" Sagittarius\nJupiter: Direct 14° 41' 35\" Sagittarius\nLongitude: 254.693002°")
    f_addEvent(timestamp("America/New_York", 1936, 11, 13, 5, 11, 23), 1936, "1936-11-13 05:11 NY", "Venus/Jupiter 25° 55' 18\" Sagittarius", "1936-11-13 05:11 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 25° 55' 18\" Sagittarius\nJupiter: Direct 25° 55' 18\" Sagittarius\nLongitude: 265.921656°")
    f_addEvent(timestamp("America/New_York", 1938, 1, 30, 23, 48, 52), 1938, "1938-01-30 23:48 NY", "Venus/Jupiter 9° 42' 48\" Aquarius", "1938-01-30 23:48 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 9° 42' 48\" Aquarius\nJupiter: Direct 9° 42' 48\" Aquarius\nLongitude: 309.713355°")
    f_addEvent(timestamp("America/New_York", 1939, 4, 22, 0, 41, 31), 1939, "1939-04-22 00:41 NY", "Venus/Jupiter 25° 58' 42\" Pisces", "1939-04-22 00:41 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 25° 58' 42\" Pisces\nJupiter: Direct 25° 58' 42\" Pisces\nLongitude: 355.978228°")
    f_addEvent(timestamp("America/New_York", 1940, 2, 20, 7, 5, 37), 1940, "1940-02-20 07:05 NY", "Venus/Jupiter 9° 52' 35\" Aries", "1940-02-20 07:05 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 9° 52' 35\" Aries\nJupiter: Direct 9° 52' 35\" Aries\nLongitude: 9.876345°")
    f_addEvent(timestamp("America/New_York", 1941, 5, 11, 13, 32, 11), 1941, "1941-05-11 13:32 NY", "Venus/Jupiter 26° 30' 34\" Taurus", "1941-05-11 13:32 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 26° 30' 34\" Taurus\nJupiter: Direct 26° 30' 34\" Taurus\nLongitude: 56.509552°")
    f_addEvent(timestamp("America/New_York", 1942, 8, 1, 22, 50, 58), 1942, "1942-08-01 22:50 NY", "Venus/Jupiter 11° 49' 56\" Cancer", "1942-08-01 22:50 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 11° 49' 56\" Cancer\nJupiter: Direct 11° 49' 56\" Cancer\nLongitude: 101.832142°")
    f_addEvent(timestamp("America/New_York", 1943, 6, 1, 22, 9, 48), 1943, "1943-06-01 22:09 NY", "Venus/Jupiter 24° 9' 43\" Cancer", "1943-06-01 22:09 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 24° 9' 43\" Cancer\nJupiter: Direct 24° 9' 43\" Cancer\nLongitude: 114.161925°")
    f_addEvent(timestamp("America/New_York", 1944, 8, 13, 13, 31, 9), 1944, "1944-08-13 13:31 NY", "Venus/Jupiter 3° 55' 10\" Virgo", "1944-08-13 13:31 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 3° 55' 10\" Virgo\nJupiter: Direct 3° 55' 10\" Virgo\nLongitude: 153.919470°")
    f_addEvent(timestamp("America/New_York", 1945, 10, 30, 7, 34, 45), 1945, "1945-10-30 07:34 NY", "Venus/Jupiter 14° 4' 23\" Libra", "1945-10-30 07:34 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 14° 4' 23\" Libra\nJupiter: Direct 14° 4' 23\" Libra\nLongitude: 194.072921°")
    f_addEvent(timestamp("America/New_York", 1946, 9, 2, 9, 32, 59), 1946, "1946-09-02 09:32 NY", "Venus/Jupiter 25° 35' 29\" Libra", "1946-09-02 09:32 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 25° 35' 29\" Libra\nJupiter: Direct 25° 35' 29\" Libra\nLongitude: 205.591497°")
    f_addEvent(timestamp("America/New_York", 1947, 11, 9, 4, 44, 13), 1947, "1947-11-09 04:44 NY", "Venus/Jupiter 3° 28' 12\" Sagittarius", "1947-11-09 04:44 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 3° 28' 12\" Sagittarius\nJupiter: Direct 3° 28' 12\" Sagittarius\nLongitude: 243.470116°")
    f_addEvent(timestamp("America/New_York", 1949, 1, 26, 2, 59, 47), 1949, "1949-01-26 02:59 NY", "Venus/Jupiter 16° 11' 32\" Capricorn", "1949-01-26 02:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 16° 11' 32\" Capricorn\nJupiter: Direct 16° 11' 32\" Capricorn\nLongitude: 286.192304°")
    f_addEvent(timestamp("America/New_York", 1949, 12, 7, 14, 25, 50), 1949, "1949-12-07 14:25 NY", "Venus/Jupiter 1° 20' 55\" Aquarius", "1949-12-07 14:25 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 1° 20' 55\" Aquarius\nJupiter: Direct 1° 20' 55\" Aquarius\nLongitude: 301.348579°")
    f_addEvent(timestamp("America/New_York", 1950, 1, 27, 20, 19, 1), 1950, "1950-01-27 20:19 NY", "Venus/Jupiter 12° 48' 37\" Aquarius", "1950-01-27 20:19 NY\nWaxing Conjunction; Angle 0°\nVenus: Retrograde (RX) 12° 48' 37\" Aquarius\nJupiter: Direct 12° 48' 37\" Aquarius\nLongitude: 312.810380°")
    f_addEvent(timestamp("America/New_York", 1950, 4, 4, 3, 56, 19), 1950, "1950-04-04 03:56 NY", "Venus/Jupiter 27° 53' 0\" Aquarius", "1950-04-04 03:56 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 27° 53' 0\" Aquarius\nJupiter: Direct 27° 53' 0\" Aquarius\nLongitude: 327.883375°")
    f_addEvent(timestamp("America/New_York", 1951, 2, 11, 13, 45, 51), 1951, "1951-02-11 13:45 NY", "Venus/Jupiter 13° 38' 7\" Pisces", "1951-02-11 13:45 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 13° 38' 7\" Pisces\nJupiter: Direct 13° 38' 7\" Pisces\nLongitude: 343.635152°")
    f_addEvent(timestamp("America/New_York", 1952, 5, 5, 12, 41, 14), 1952, "1952-05-05 12:41 NY", "Venus/Jupiter 1° 37' 35\" Taurus", "1952-05-05 12:41 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 1° 37' 35\" Taurus\nJupiter: Direct 1° 37' 35\" Taurus\nLongitude: 31.626278°")
    f_addEvent(timestamp("America/New_York", 1953, 7, 22, 23, 18, 53), 1953, "1953-07-22 23:18 NY", "Venus/Jupiter 16° 46' 13\" Gemini", "1953-07-22 23:18 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 16° 46' 13\" Gemini\nJupiter: Direct 16° 46' 13\" Gemini\nLongitude: 76.770307°")
    f_addEvent(timestamp("America/New_York", 1954, 5, 23, 8, 6, 33), 1954, "1954-05-23 08:06 NY", "Venus/Jupiter 29° 51' 6\" Gemini", "1954-05-23 08:06 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 29° 51' 6\" Gemini\nJupiter: Direct 29° 51' 6\" Gemini\nLongitude: 89.851744°")
    f_addEvent(timestamp("America/New_York", 1955, 8, 11, 16, 7, 45), 1955, "1955-08-11 16:07 NY", "Venus/Jupiter 12° 45' 9\" Leo", "1955-08-11 16:07 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 12° 45' 9\" Leo\nJupiter: Direct 12° 45' 9\" Leo\nLongitude: 132.752546°")
    f_addEvent(timestamp("America/New_York", 1956, 10, 25, 12, 14, 55), 1956, "1956-10-25 12:14 NY", "Venus/Jupiter 22° 41' 23\" Virgo", "1956-10-25 12:14 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 22° 41' 23\" Virgo\nJupiter: Direct 22° 41' 23\" Virgo\nLongitude: 172.689845°")
    f_addEvent(timestamp("America/New_York", 1957, 8, 22, 6, 26, 57), 1957, "1957-08-22 06:26 NY", "Venus/Jupiter 2° 52' 46\" Libra", "1957-08-22 06:26 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 2° 52' 46\" Libra\nJupiter: Direct 2° 52' 46\" Libra\nLongitude: 182.879517°")
    f_addEvent(timestamp("America/New_York", 1958, 11, 6, 9, 49, 40), 1958, "1958-11-06 09:49 NY", "Venus/Jupiter 12° 27' 36\" Scorpio", "1958-11-06 09:49 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 12° 27' 36\" Scorpio\nJupiter: Direct 12° 27' 36\" Scorpio\nLongitude: 222.459911°")
    f_addEvent(timestamp("America/New_York", 1960, 1, 21, 6, 59, 58), 1960, "1960-01-21 06:59 NY", "Venus/Jupiter 23° 3' 53\" Sagittarius", "1960-01-21 06:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 23° 3' 53\" Sagittarius\nJupiter: Direct 23° 3' 53\" Sagittarius\nLongitude: 263.064773°")
    f_addEvent(timestamp("America/New_York", 1960, 11, 18, 22, 10, 43), 1960, "1960-11-18 22:10 NY", "Venus/Jupiter 4° 32' 54\" Capricorn", "1960-11-18 22:10 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 4° 32' 54\" Capricorn\nJupiter: Direct 4° 32' 54\" Capricorn\nLongitude: 274.548371°")
    f_addEvent(timestamp("America/New_York", 1962, 2, 5, 15, 0, 31), 1962, "1962-02-05 15:00 NY", "Venus/Jupiter 18° 48' 46\" Aquarius", "1962-02-05 15:00 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 18° 48' 46\" Aquarius\nJupiter: Direct 18° 48' 46\" Aquarius\nLongitude: 318.812854°")
    f_addEvent(timestamp("America/New_York", 1963, 4, 28, 18, 27, 31), 1963, "1963-04-28 18:27 NY", "Venus/Jupiter 5° 44' 55\" Aries", "1963-04-28 18:27 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 5° 44' 55\" Aries\nJupiter: Direct 5° 44' 55\" Aries\nLongitude: 5.748664°")
    f_addEvent(timestamp("America/New_York", 1964, 2, 27, 11, 17, 52), 1964, "1964-02-27 11:17 NY", "Venus/Jupiter 19° 49' 14\" Aries", "1964-02-27 11:17 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 19° 49' 14\" Aries\nJupiter: Direct 19° 49' 14\" Aries\nLongitude: 19.820560°")
    f_addEvent(timestamp("America/New_York", 1965, 5, 17, 9, 0, 32), 1965, "1965-05-17 09:00 NY", "Venus/Jupiter 5° 40' 53\" Gemini", "1965-05-17 09:00 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 5° 40' 53\" Gemini\nJupiter: Direct 5° 40' 53\" Gemini\nLongitude: 65.681283°")
    f_addEvent(timestamp("America/New_York", 1966, 8, 7, 12, 3, 35), 1966, "1966-08-07 12:03 NY", "Venus/Jupiter 20° 26' 28\" Cancer", "1966-08-07 12:03 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 20° 26' 28\" Cancer\nJupiter: Direct 20° 26' 28\" Cancer\nLongitude: 110.441094°")
    f_addEvent(timestamp("America/New_York", 1967, 6, 9, 9, 55, 47), 1967, "1967-06-09 09:55 NY", "Venus/Jupiter 2° 58' 46\" Leo", "1967-06-09 09:55 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 2° 58' 46\" Leo\nJupiter: Direct 2° 58' 46\" Leo\nLongitude: 122.979436°")
    f_addEvent(timestamp("America/New_York", 1968, 8, 18, 6, 46, 41), 1968, "1968-08-18 06:46 NY", "Venus/Jupiter 11° 44' 48\" Virgo", "1968-08-18 06:46 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 11° 44' 48\" Virgo\nJupiter: Direct 11° 44' 48\" Virgo\nLongitude: 161.746726°")
    f_addEvent(timestamp("America/New_York", 1969, 11, 3, 23, 2, 41), 1969, "1969-11-03 23:02 NY", "Venus/Jupiter 21° 50' 41\" Libra", "1969-11-03 23:02 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 21° 50' 41\" Libra\nJupiter: Direct 21° 50' 41\" Libra\nLongitude: 201.844736°")
    f_addEvent(timestamp("America/New_York", 1970, 9, 11, 18, 59, 4), 1970, "1970-09-11 18:59 NY", "Venus/Jupiter 4° 23' 9\" Scorpio", "1970-09-11 18:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 4° 23' 9\" Scorpio\nJupiter: Direct 4° 23' 9\" Scorpio\nLongitude: 214.385937°")
    f_addEvent(timestamp("America/New_York", 1970, 11, 11, 3, 52, 42), 1970, "1970-11-11 03:52 NY", "Venus/Jupiter 16° 56' 6\" Scorpio", "1970-11-11 03:52 NY\nWaxing Conjunction; Angle 0°\nVenus: Retrograde (RX) 16° 56' 6\" Scorpio\nJupiter: Direct 16° 56' 6\" Scorpio\nLongitude: 226.935006°")
    f_addEvent(timestamp("America/New_York", 1971, 1, 4, 23, 53, 51), 1971, "1971-01-04 23:53 NY", "Venus/Jupiter 28° 22' 12\" Scorpio", "1971-01-04 23:53 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 28° 22' 12\" Scorpio\nJupiter: Direct 28° 22' 12\" Scorpio\nLongitude: 238.370067°")
    f_addEvent(timestamp("America/New_York", 1971, 11, 14, 4, 23, 2), 1971, "1971-11-14 04:23 NY", "Venus/Jupiter 11° 40' 18\" Sagittarius", "1971-11-14 04:23 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 11° 40' 18\" Sagittarius\nJupiter: Direct 11° 40' 18\" Sagittarius\nLongitude: 251.671800°")
    f_addEvent(timestamp("America/New_York", 1973, 1, 31, 13, 19, 59), 1973, "1973-01-31 13:19 NY", "Venus/Jupiter 24° 58' 29\" Capricorn", "1973-01-31 13:19 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 24° 58' 29\" Capricorn\nJupiter: Direct 24° 58' 29\" Capricorn\nLongitude: 294.974674°")
    f_addEvent(timestamp("America/New_York", 1974, 4, 14, 10, 51, 5), 1974, "1974-04-14 10:51 NY", "Venus/Jupiter 8° 11' 22\" Pisces", "1974-04-14 10:51 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 8° 11' 22\" Pisces\nJupiter: Direct 8° 11' 22\" Pisces\nLongitude: 338.189445°")
    f_addEvent(timestamp("America/New_York", 1975, 2, 17, 15, 22, 50), 1975, "1975-02-17 15:22 NY", "Venus/Jupiter 23° 7' 18\" Pisces", "1975-02-17 15:22 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 23° 7' 18\" Pisces\nJupiter: Direct 23° 7' 18\" Pisces\nLongitude: 353.121548°")
    f_addEvent(timestamp("America/New_York", 1976, 5, 11, 11, 39, 24), 1976, "1976-05-11 11:39 NY", "Venus/Jupiter 10° 57' 15\" Taurus", "1976-05-11 11:39 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 10° 57' 15\" Taurus\nJupiter: Direct 10° 57' 15\" Taurus\nLongitude: 40.954146°")
    f_addEvent(timestamp("America/New_York", 1977, 7, 30, 3, 38, 17), 1977, "1977-07-30 03:38 NY", "Venus/Jupiter 26° 2' 51\" Gemini", "1977-07-30 03:38 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 26° 2' 51\" Gemini\nJupiter: Direct 26° 2' 51\" Gemini\nLongitude: 86.047557°")
    f_addEvent(timestamp("America/New_York", 1978, 5, 29, 0, 41, 50), 1978, "1978-05-29 00:41 NY", "Venus/Jupiter 8° 31' 45\" Cancer", "1978-05-29 00:41 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 8° 31' 45\" Cancer\nJupiter: Direct 8° 31' 45\" Cancer\nLongitude: 98.529079°")
    f_addEvent(timestamp("America/New_York", 1979, 8, 16, 11, 57, 53), 1979, "1979-08-16 11:57 NY", "Venus/Jupiter 20° 45' 16\" Leo", "1979-08-16 11:57 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 20° 45' 16\" Leo\nJupiter: Direct 20° 45' 16\" Leo\nLongitude: 140.754409°")
    f_addEvent(timestamp("America/New_York", 1980, 10, 30, 19, 37, 15), 1980, "1980-10-30 19:37 NY", "Venus/Jupiter 0° 42' 4\" Libra", "1980-10-30 19:37 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 0° 42' 4\" Libra\nJupiter: Direct 0° 42' 4\" Libra\nLongitude: 180.701077°")
    f_addEvent(timestamp("America/New_York", 1981, 8, 27, 12, 15, 16), 1981, "1981-08-27 12:15 NY", "Venus/Jupiter 10° 49' 35\" Libra", "1981-08-27 12:15 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 10° 49' 35\" Libra\nJupiter: Direct 10° 49' 35\" Libra\nLongitude: 190.826334°")
    f_addEvent(timestamp("America/New_York", 1982, 11, 11, 1, 55, 53), 1982, "1982-11-11 01:55 NY", "Venus/Jupiter 20° 21' 46\" Scorpio", "1982-11-11 01:55 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 20° 21' 46\" Scorpio\nJupiter: Direct 20° 21' 46\" Scorpio\nLongitude: 230.362854°")
    f_addEvent(timestamp("America/New_York", 1984, 1, 26, 20, 28, 51), 1984, "1984-01-26 20:28 NY", "Venus/Jupiter 1° 33' 46\" Capricorn", "1984-01-26 20:28 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 1° 33' 46\" Capricorn\nJupiter: Direct 1° 33' 46\" Capricorn\nLongitude: 271.562708°")
    f_addEvent(timestamp("America/New_York", 1984, 11, 24, 21, 15, 14), 1984, "1984-11-24 21:15 NY", "Venus/Jupiter 13° 19' 20\" Capricorn", "1984-11-24 21:15 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 13° 19' 20\" Capricorn\nJupiter: Direct 13° 19' 20\" Capricorn\nLongitude: 283.322299°")
    f_addEvent(timestamp("America/New_York", 1986, 2, 11, 3, 17, 19), 1986, "1986-02-11 03:17 NY", "Venus/Jupiter 27° 45' 37\" Aquarius", "1986-02-11 03:17 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 27° 45' 37\" Aquarius\nJupiter: Direct 27° 45' 37\" Aquarius\nLongitude: 327.760397°")
    f_addEvent(timestamp("America/New_York", 1987, 5, 5, 0, 8, 18), 1987, "1987-05-05 00:08 NY", "Venus/Jupiter 15° 5' 29\" Aries", "1987-05-05 00:08 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 15° 5' 29\" Aries\nJupiter: Direct 15° 5' 29\" Aries\nLongitude: 15.091263°")
    f_addEvent(timestamp("America/New_York", 1988, 3, 5, 17, 19, 25), 1988, "1988-03-05 17:19 NY", "Venus/Jupiter 29° 26' 14\" Aries", "1988-03-05 17:19 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 29° 26' 14\" Aries\nJupiter: Direct 29° 26' 14\" Aries\nLongitude: 29.437157°")
    f_addEvent(timestamp("America/New_York", 1989, 5, 22, 21, 56, 38), 1989, "1989-05-22 21:56 NY", "Venus/Jupiter 14° 30' 41\" Gemini", "1989-05-22 21:56 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 14° 30' 41\" Gemini\nJupiter: Direct 14° 30' 41\" Gemini\nLongitude: 74.511289°")
    f_addEvent(timestamp("America/New_York", 1990, 8, 12, 19, 36, 31), 1990, "1990-08-12 19:36 NY", "Venus/Jupiter 28° 51' 28\" Cancer", "1990-08-12 19:36 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 28° 51' 28\" Cancer\nJupiter: Direct 28° 51' 28\" Cancer\nLongitude: 118.857844°")
    f_addEvent(timestamp("America/New_York", 1991, 6, 18, 6, 11, 10), 1991, "1991-06-18 06:11 NY", "Venus/Jupiter 11° 58' 36\" Leo", "1991-06-18 06:11 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 11° 58' 36\" Leo\nJupiter: Direct 11° 58' 36\" Leo\nLongitude: 131.976732°")
    f_addEvent(timestamp("America/New_York", 1991, 8, 27, 2, 3, 10), 1991, "1991-08-27 02:03 NY", "Venus/Jupiter 26° 32' 59\" Leo", "1991-08-27 02:03 NY\nWaxing Conjunction; Angle 0°\nVenus: Retrograde (RX) 26° 32' 59\" Leo\nJupiter: Direct 26° 32' 59\" Leo\nLongitude: 146.549760°")
    f_addEvent(timestamp("America/New_York", 1991, 10, 15, 13, 34, 8), 1991, "1991-10-15 13:34 NY", "Venus/Jupiter 6° 40' 58\" Virgo", "1991-10-15 13:34 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 6° 40' 58\" Virgo\nJupiter: Direct 6° 40' 58\" Virgo\nLongitude: 156.682815°")
    f_addEvent(timestamp("America/New_York", 1992, 8, 23, 1, 42, 52), 1992, "1992-08-23 01:42 NY", "Venus/Jupiter 19° 38' 10\" Virgo", "1992-08-23 01:42 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 19° 38' 10\" Virgo\nJupiter: Direct 19° 38' 10\" Virgo\nLongitude: 169.636045°")
    f_addEvent(timestamp("America/New_York", 1993, 11, 8, 14, 56, 13), 1993, "1993-11-08 14:56 NY", "Venus/Jupiter 29° 40' 41\" Libra", "1993-11-08 14:56 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 29° 40' 41\" Libra\nJupiter: Direct 29° 40' 41\" Libra\nLongitude: 209.678113°")
    f_addEvent(timestamp("America/New_York", 1994, 9, 29, 17, 50, 53), 1994, "1994-09-29 17:50 NY", "Venus/Jupiter 14° 51' 30\" Scorpio", "1994-09-29 17:50 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 14° 51' 30\" Scorpio\nJupiter: Direct 14° 51' 30\" Scorpio\nLongitude: 224.858470°")
    f_addEvent(timestamp("America/New_York", 1994, 10, 15, 0, 13, 25), 1994, "1994-10-15 00:13 NY", "Venus/Jupiter 17° 56' 9\" Scorpio", "1994-10-15 00:13 NY\nWaxing Conjunction; Angle 0°\nVenus: Retrograde (RX) 17° 56' 9\" Scorpio\nJupiter: Direct 17° 56' 9\" Scorpio\nLongitude: 227.935860°")
    f_addEvent(timestamp("America/New_York", 1995, 1, 14, 16, 50, 44), 1995, "1995-01-14 16:50 NY", "Venus/Jupiter 7° 24' 45\" Sagittarius", "1995-01-14 16:50 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 7° 24' 45\" Sagittarius\nJupiter: Direct 7° 24' 45\" Sagittarius\nLongitude: 247.412426°")
    f_addEvent(timestamp("America/New_York", 1995, 11, 19, 4, 54, 8), 1995, "1995-11-19 04:54 NY", "Venus/Jupiter 19° 52' 37\" Sagittarius", "1995-11-19 04:54 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 19° 52' 37\" Sagittarius\nJupiter: Direct 19° 52' 37\" Sagittarius\nLongitude: 259.876948°")
    f_addEvent(timestamp("America/New_York", 1997, 2, 5, 20, 48, 19), 1997, "1997-02-05 20:48 NY", "Venus/Jupiter 3° 37' 7\" Aquarius", "1997-02-05 20:48 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 3° 37' 7\" Aquarius\nJupiter: Direct 3° 37' 7\" Aquarius\nLongitude: 303.618488°")
    f_addEvent(timestamp("America/New_York", 1998, 4, 22, 19, 13, 25), 1998, "1998-04-22 19:13 NY", "Venus/Jupiter 17° 56' 20\" Pisces", "1998-04-22 19:13 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 17° 56' 20\" Pisces\nJupiter: Direct 17° 56' 20\" Pisces\nLongitude: 347.938896°")
    f_addEvent(timestamp("America/New_York", 1999, 2, 23, 14, 47, 37), 1999, "1999-02-23 14:47 NY", "Venus/Jupiter 2° 24' 41\" Aries", "1999-02-23 14:47 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 2° 24' 41\" Aries\nJupiter: Direct 2° 24' 41\" Aries\nLongitude: 2.411476°")
    f_addEvent(timestamp("America/New_York", 2000, 5, 17, 6, 30, 26), 2000, "2000-05-17 06:30 NY", "Venus/Jupiter 20° 4' 42\" Taurus", "2000-05-17 06:30 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 20° 4' 42\" Taurus\nJupiter: Direct 20° 4' 42\" Taurus\nLongitude: 50.078299°")
    f_addEvent(timestamp("America/New_York", 2001, 8, 5, 18, 49, 56), 2001, "2001-08-05 18:49 NY", "Venus/Jupiter 5° 6' 39\" Cancer", "2001-08-05 18:49 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 5° 6' 39\" Cancer\nJupiter: Direct 5° 6' 39\" Cancer\nLongitude: 95.110751°")
    f_addEvent(timestamp("America/New_York", 2002, 6, 3, 19, 11, 31), 2002, "2002-06-03 19:11 NY", "Venus/Jupiter 17° 10' 27\" Cancer", "2002-06-03 19:11 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 17° 10' 27\" Cancer\nJupiter: Direct 17° 10' 27\" Cancer\nLongitude: 107.174130°")
    f_addEvent(timestamp("America/New_York", 2003, 8, 21, 6, 23, 14), 2003, "2003-08-21 06:23 NY", "Venus/Jupiter 28° 41' 59\" Leo", "2003-08-21 06:23 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 28° 41' 59\" Leo\nJupiter: Direct 28° 41' 59\" Leo\nLongitude: 148.699805°")
    f_addEvent(timestamp("America/New_York", 2004, 11, 4, 21, 10, 32), 2004, "2004-11-04 21:10 NY", "Venus/Jupiter 8° 33' 55\" Libra", "2004-11-04 21:10 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 8° 33' 55\" Libra\nJupiter: Direct 8° 33' 55\" Libra\nLongitude: 188.565286°")
    f_addEvent(timestamp("America/New_York", 2005, 9, 1, 19, 30, 27), 2005, "2005-09-01 19:30 NY", "Venus/Jupiter 18° 41' 34\" Libra", "2005-09-01 19:30 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 18° 41' 34\" Libra\nJupiter: Direct 18° 41' 34\" Libra\nLongitude: 198.692867°")
    f_addEvent(timestamp("America/New_York", 2006, 11, 15, 15, 35, 9), 2006, "2006-11-15 15:35 NY", "Venus/Jupiter 28° 8' 45\" Scorpio", "2006-11-15 15:35 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 28° 8' 45\" Scorpio\nJupiter: Direct 28° 8' 45\" Scorpio\nLongitude: 238.145906°")
    f_addEvent(timestamp("America/New_York", 2008, 2, 1, 6, 33, 24), 2008, "2008-02-01 06:33 NY", "Venus/Jupiter 10° 0' 57\" Capricorn", "2008-02-01 06:33 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 10° 0' 57\" Capricorn\nJupiter: Direct 10° 0' 57\" Capricorn\nLongitude: 280.015908°")
    f_addEvent(timestamp("America/New_York", 2008, 12, 1, 3, 44, 35), 2008, "2008-12-01 03:44 NY", "Venus/Jupiter 22° 14' 48\" Capricorn", "2008-12-01 03:44 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 22° 14' 48\" Capricorn\nJupiter: Direct 22° 14' 48\" Capricorn\nLongitude: 292.246670°")
    f_addEvent(timestamp("America/New_York", 2010, 2, 16, 21, 14, 13), 2010, "2010-02-16 21:14 NY", "Venus/Jupiter 6° 59' 45\" Pisces", "2010-02-16 21:14 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 6° 59' 45\" Pisces\nJupiter: Direct 6° 59' 45\" Pisces\nLongitude: 336.995938°")
    f_addEvent(timestamp("America/New_York", 2011, 5, 11, 10, 42, 5), 2011, "2011-05-11 10:42 NY", "Venus/Jupiter 24° 46' 3\" Aries", "2011-05-11 10:42 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 24° 46' 3\" Aries\nJupiter: Direct 24° 46' 3\" Aries\nLongitude: 24.767482°")
    f_addEvent(timestamp("America/New_York", 2012, 3, 14, 1, 54, 17), 2012, "2012-03-14 01:54 NY", "Venus/Jupiter 9° 33' 46\" Taurus", "2012-03-14 01:54 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 9° 33' 46\" Taurus\nJupiter: Direct 9° 33' 46\" Taurus\nLongitude: 39.562795°")
    f_addEvent(timestamp("America/New_York", 2013, 5, 28, 15, 28, 51), 2013, "2013-05-28 15:28 NY", "Venus/Jupiter 23° 32' 26\" Gemini", "2013-05-28 15:28 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 23° 32' 26\" Gemini\nJupiter: Direct 23° 32' 26\" Gemini\nLongitude: 83.540564°")
    f_addEvent(timestamp("America/New_York", 2014, 8, 18, 1, 21, 18), 2014, "2014-08-18 01:21 NY", "Venus/Jupiter 7° 14' 14\" Leo", "2014-08-18 01:21 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 7° 14' 14\" Leo\nJupiter: Direct 7° 14' 14\" Leo\nLongitude: 127.237229°")
    f_addEvent(timestamp("America/New_York", 2015, 7, 1, 3, 50, 46), 2015, "2015-07-01 03:50 NY", "Venus/Jupiter 21° 37' 30\" Leo", "2015-07-01 03:50 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 21° 37' 30\" Leo\nJupiter: Direct 21° 37' 30\" Leo\nLongitude: 141.624977°")
    f_addEvent(timestamp("America/New_York", 2015, 8, 4, 17, 46, 49), 2015, "2015-08-04 17:46 NY", "Venus/Jupiter 28° 35' 42\" Leo", "2015-08-04 17:46 NY\nWaxing Conjunction; Angle 0°\nVenus: Retrograde (RX) 28° 35' 42\" Leo\nJupiter: Direct 28° 35' 42\" Leo\nLongitude: 148.595119°")
    f_addEvent(timestamp("America/New_York", 2015, 10, 25, 16, 3, 8), 2015, "2015-10-25 16:03 NY", "Venus/Jupiter 15° 38' 44\" Virgo", "2015-10-25 16:03 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 15° 38' 44\" Virgo\nJupiter: Direct 15° 38' 44\" Virgo\nLongitude: 165.645496°")
    f_addEvent(timestamp("America/New_York", 2016, 8, 27, 18, 28, 35), 2016, "2016-08-27 18:28 NY", "Venus/Jupiter 27° 21' 45\" Virgo", "2016-08-27 18:28 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 27° 21' 45\" Virgo\nJupiter: Direct 27° 21' 45\" Virgo\nLongitude: 177.362612°")
    f_addEvent(timestamp("America/New_York", 2017, 11, 13, 3, 15, 29), 2017, "2017-11-13 03:15 NY", "Venus/Jupiter 7° 20' 31\" Scorpio", "2017-11-13 03:15 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 7° 20' 31\" Scorpio\nJupiter: Direct 7° 20' 31\" Scorpio\nLongitude: 217.341834°")
    f_addEvent(timestamp("America/New_York", 2019, 1, 22, 7, 25, 49), 2019, "2019-01-22 07:25 NY", "Venus/Jupiter 16° 3' 42\" Sagittarius", "2019-01-22 07:25 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 16° 3' 42\" Sagittarius\nJupiter: Direct 16° 3' 42\" Sagittarius\nLongitude: 256.061564°")
    f_addEvent(timestamp("America/New_York", 2019, 11, 24, 8, 33, 28), 2019, "2019-11-24 08:33 NY", "Venus/Jupiter 28° 11' 45\" Sagittarius", "2019-11-24 08:33 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 28° 11' 45\" Sagittarius\nJupiter: Direct 28° 11' 45\" Sagittarius\nLongitude: 268.195888°")
    f_addEvent(timestamp("America/New_York", 2021, 2, 11, 9, 59, 36), 2021, "2021-02-11 09:59 NY", "Venus/Jupiter 12° 34' 33\" Aquarius", "2021-02-11 09:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 12° 34' 33\" Aquarius\nJupiter: Direct 12° 34' 33\" Aquarius\nLongitude: 312.575806°")
    f_addEvent(timestamp("America/New_York", 2022, 4, 30, 17, 13, 56), 2022, "2022-04-30 17:13 NY", "Venus/Jupiter 27° 57' 51\" Pisces", "2022-04-30 17:13 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 27° 57' 51\" Pisces\nJupiter: Direct 27° 57' 51\" Pisces\nLongitude: 357.964153°")
    f_addEvent(timestamp("America/New_York", 2023, 3, 2, 0, 35, 54), 2023, "2023-03-02 00:35 NY", "Venus/Jupiter 12° 8' 45\" Aries", "2023-03-02 00:35 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 12° 8' 45\" Aries\nJupiter: Direct 12° 8' 45\" Aries\nLongitude: 12.145865°")
    f_addEvent(timestamp("America/New_York", 2024, 5, 23, 4, 29, 10), 2024, "2024-05-23 04:29 NY", "Venus/Jupiter 29° 23' 4\" Taurus", "2024-05-23 04:29 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 29° 23' 4\" Taurus\nJupiter: Direct 29° 23' 4\" Taurus\nLongitude: 59.384384°")
    f_addEvent(timestamp("America/New_York", 2025, 8, 12, 1, 30, 12), 2025, "2025-08-12 01:30 NY", "Venus/Jupiter 14° 3' 45\" Cancer", "2025-08-12 01:30 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 14° 3' 45\" Cancer\nJupiter: Direct 14° 3' 45\" Cancer\nLongitude: 104.062407°")
    f_addEvent(timestamp("America/New_York", 2026, 6, 9, 15, 59, 12), 2026, "2026-06-09 15:59 NY", "Venus/Jupiter 25° 46' 41\" Cancer", "2026-06-09 15:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 25° 46' 41\" Cancer\nJupiter: Direct 25° 46' 41\" Cancer\nLongitude: 115.778012°")
    f_addEvent(timestamp("America/New_York", 2027, 8, 25, 22, 59, 40), 2027, "2027-08-25 22:59 NY", "Venus/Jupiter 6° 33' 59\" Virgo", "2027-08-25 22:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 6° 33' 59\" Virgo\nJupiter: Direct 6° 33' 59\" Virgo\nLongitude: 156.566301°")
    f_addEvent(timestamp("America/New_York", 2028, 11, 9, 19, 59, 19), 2028, "2028-11-09 19:59 NY", "Venus/Jupiter 16° 26' 6\" Libra", "2028-11-09 19:59 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 16° 26' 6\" Libra\nJupiter: Direct 16° 26' 6\" Libra\nLongitude: 196.435138°")
    f_addEvent(timestamp("America/New_York", 2029, 9, 7, 10, 53, 29), 2029, "2029-09-07 10:53 NY", "Venus/Jupiter 26° 44' 19\" Libra", "2029-09-07 10:53 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 26° 44' 19\" Libra\nJupiter: Direct 26° 44' 19\" Libra\nLongitude: 206.738656°")
    f_addEvent(timestamp("America/New_York", 2030, 11, 20, 10, 41, 9), 2030, "2030-11-20 10:41 NY", "Venus/Jupiter 6° 12' 11\" Sagittarius", "2030-11-20 10:41 NY\nWaxing Conjunction; Angle 0°\nVenus: Direct 6° 12' 11\" Sagittarius\nJupiter: Direct 6° 12' 11\" Sagittarius\nLongitude: 246.203191°")

// Delete and redraw on the last bar so changes to visible range, inputs, or timeframe update cleanly.
if barstate.islast
    if array.size(drawnLines) > 0
        for i = 0 to array.size(drawnLines) - 1
            line.delete(array.get(drawnLines, i))
    if array.size(drawnLabels) > 0
        for i = 0 to array.size(drawnLabels) - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnLines)
    array.clear(drawnLabels)

    float y1 = low - syminfo.mintick
    float y2 = high + syminfo.mintick
    float tagY = high + nz(ta.atr(14), high * 0.01)

    int visibleCount = 0

    for i = 0 to array.size(eventTimes) - 1
        int t = array.get(eventTimes, i)
        int y = array.get(eventYears, i)
        string d = array.get(eventDates, i)
        string pos = array.get(eventPos, i)
        string tip = array.get(eventTips, i)

        if y >= startYear
            color thisLineColor = f_isRedDate(d) ? redLine : lineCol
            line ln = line.new(x1 = t, y1 = y1, x2 = t, y2 = y2, xloc = xloc.bar_time, extend = extend.both, color = thisLineColor, width = lineWidth)
            array.push(drawnLines, ln)

            bool wantTag = showTags and tagTextMode != "Off"
            if wantTag
                string tagText = tagTextMode == "Date + Position" ? d + "\n" + pos : pos
                label lb = label.new(x = t, y = tagY, text = tagText, xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_down, color = tagBg, textcolor = color.white, size = size.tiny, tooltip = tip)
                array.push(drawnLabels, lb)

            if showInfoTable and t >= chart.left_visible_bar_time and t <= chart.right_visible_bar_time and visibleCount < maxTableRows
                visibleCount += 1

    // Rebuild table showing events currently inside the visible chart window.
    for r = 0 to 15
        for c = 0 to 2
            table.cell(infoTable, c, r, "", text_size = size.tiny)

    if showInfoTable
        table.cell(infoTable, 0, 0, "Date",     text_color = color.white, bgcolor = lavender, text_size = size.tiny)
        table.cell(infoTable, 1, 0, "Event",    text_color = color.white, bgcolor = lavender, text_size = size.tiny)
        table.cell(infoTable, 2, 0, "Position", text_color = color.white, bgcolor = lavender, text_size = size.tiny)

        int row = 1
        for i = 0 to array.size(eventTimes) - 1
            int t = array.get(eventTimes, i)
            int y = array.get(eventYears, i)
            if y >= startYear and t >= chart.left_visible_bar_time and t <= chart.right_visible_bar_time and row <= maxTableRows
                table.cell(infoTable, 0, row, array.get(eventDates, i), text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.tiny)
                table.cell(infoTable, 1, row, "Venus/Jupiter",        text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.tiny)
                table.cell(infoTable, 2, row, array.get(eventPos, i),   text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.tiny)
                row += 1

        if row == 1
            table.cell(infoTable, 0, 1, "No events in visible range", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.tiny)
            table.cell(infoTable, 1, 1, "", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.tiny)
            table.cell(infoTable, 2, 1, "", text_color = color.white, bgcolor = color.new(color.black, 20), text_size = size.tiny)
````
