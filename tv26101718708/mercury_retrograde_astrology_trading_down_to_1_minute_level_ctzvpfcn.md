# Mercury Retrograde (Astrology Trading Down to 1 minute level)

- url: https://www.tradingview.com/script/CtZVpFcn-Mercury-Retrograde-Astrology-Trading-Down-to-1-minute-level/
- type: indicator
- pine_id: PUB;b501a3e2e1e241289b5625d6dce12443
- version: 1.0

## Description

The Astro-Trading Edge https://www.youtube.com/watch?v=A94NbgTTJ0w
Mercury Retrograde Data: Precision Down to the Minute

Our script features hardcoded dates for absolute accuracy, providing Mercury Retrograde data with one-minute precision. By simply clicking the Rx (Retrograde) or Direct tags, you can access the exact event times in UTC, clearly displayed in text format.

The Power of Your "Lens"
Ultimately, successful trading is a reflection of your mindset. Visionaries like Warren Buffett, W.D. Gann, and Elon Musk can all look at the exact same chart, yet they arrive at different conclusions because they view the market through different "eyeglasses." Their perspectives are shaped by their unique philosophies and tools.

Adding the Astro Layer
By incorporating the nuances of Mercury Retrograde into your strategy, you add a sophisticated layer to your technical analysis. Elevate your trading journey by integrating the wisdom of financial astrology.

Explore more at: www.gannexplained.com

Refining the Gann perspective — Khit Wong

## Source Code

````pine
//@version=5
indicator("Mercury Retrograde Simplified (2018-2038)", overlay=true)

// Simplified logic for maximum performance and reliability
// Data source: Richard Nolle's Geocentric Tropical Zodiac Tables (UTC)

bool is_retro = false
string current_start_str = ""
string current_end_str = ""
int next_event_ts = 0
string next_event_type = ""
string next_event_str = ""

if false
    is_retro := false
else if time >= 1521763560000 and time <= 1523784420000
    is_retro := true
    current_start_str := "MAR 23, 2018 12:06 AM"
    current_end_str := "APR 15, 2018 09:27 AM"
else if time >= 1532581380000 and time <= 1534652280000
    is_retro := true
    current_start_str := "JUL 26, 2018 05:03 AM"
    current_end_str := "AUG 19, 2018 04:18 AM"
else if time >= 1542417420000 and time <= 1544131500000
    is_retro := true
    current_start_str := "NOV 17, 2018 01:17 AM"
    current_end_str := "DEC 06, 2018 09:25 PM"
else if time >= 1551809100000 and time <= 1553781480000
    is_retro := true
    current_start_str := "MAR 05, 2019 06:05 PM"
    current_end_str := "MAR 28, 2019 01:58 PM"
else if time >= 1562540460000 and time <= 1564632180000
    is_retro := true
    current_start_str := "JUL 07, 2019 11:01 PM"
    current_end_str := "AUG 01, 2019 04:03 AM"
else if time >= 1572535560000 and time <= 1574277900000
    is_retro := true
    current_start_str := "OCT 31, 2019 03:26 PM"
    current_end_str := "NOV 20, 2019 07:25 PM"
else if time >= 1581900060000 and time <= 1583811420000
    is_retro := true
    current_start_str := "FEB 17, 2020 12:41 AM"
    current_end_str := "MAR 10, 2020 03:37 AM"
else if time >= 1592455620000 and time <= 1594542300000
    is_retro := true
    current_start_str := "JUN 18, 2020 04:47 AM"
    current_end_str := "JUL 12, 2020 08:25 AM"
else if time >= 1602636960000 and time <= 1604426280000
    is_retro := true
    current_start_str := "OCT 14, 2020 12:56 AM"
    current_end_str := "NOV 03, 2020 05:58 PM"
else if time >= 1612021200000 and time <= 1613868240000
    is_retro := true
    current_start_str := "JAN 30, 2021 03:40 PM"
    current_end_str := "FEB 21, 2021 12:44 AM"
else if time >= 1622328000000 and time <= 1624398420000
    is_retro := true
    current_start_str := "MAY 29, 2021 10:40 PM"
    current_end_str := "JUN 22, 2021 09:47 PM"
else if time >= 1632719400000 and time <= 1634569860000
    is_retro := true
    current_start_str := "SEP 27, 2021 05:10 AM"
    current_end_str := "OCT 18, 2021 03:11 PM"
else if time >= 1642159920000 and time <= 1643947860000
    is_retro := true
    current_start_str := "JAN 14, 2022 11:32 AM"
    current_end_str := "FEB 04, 2022 04:11 AM"
else if time >= 1652182920000 and time <= 1654243500000
    is_retro := true
    current_start_str := "MAY 10, 2022 11:42 AM"
    current_end_str := "JUN 03, 2022 08:05 AM"
else if time >= 1662781260000 and time <= 1664701440000
    is_retro := true
    current_start_str := "SEP 10, 2022 03:41 AM"
    current_end_str := "OCT 02, 2022 09:04 AM"
else if time >= 1672305360000 and time <= 1674047400000
    is_retro := true
    current_start_str := "DEC 29, 2022 09:16 AM"
    current_end_str := "JAN 18, 2023 01:10 PM"
else if time >= 1682065020000 and time <= 1684121040000
    is_retro := true
    current_start_str := "APR 21, 2023 08:17 AM"
    current_end_str := "MAY 15, 2023 03:24 AM"
else if time >= 1692820200000 and time <= 1694809320000
    is_retro := true
    current_start_str := "AUG 23, 2023 07:50 PM"
    current_end_str := "SEP 15, 2023 08:22 PM"
else if time >= 1702449660000 and time <= 1704164520000
    is_retro := true
    current_start_str := "DEC 13, 2023 06:41 AM"
    current_end_str := "JAN 02, 2024 03:02 AM"
else if time >= 1712009340000 and time <= 1714048920000
    is_retro := true
    current_start_str := "APR 01, 2024 10:09 PM"
    current_end_str := "APR 25, 2024 12:42 PM"
else if time >= 1722832800000 and time <= 1724879640000
    is_retro := true
    current_start_str := "AUG 05, 2024 04:40 AM"
    current_end_str := "AUG 28, 2024 09:14 PM"
else if time >= 1732588020000 and time <= 1734296220000
    is_retro := true
    current_start_str := "NOV 26, 2024 02:27 AM"
    current_end_str := "DEC 15, 2024 08:57 PM"
else if time >= 1742021100000 and time <= 1744023420000
    is_retro := true
    current_start_str := "MAR 15, 2025 06:45 AM"
    current_end_str := "APR 07, 2025 10:57 AM"
else if time >= 1752813660000 and time <= 1754896800000
    is_retro := true
    current_start_str := "JUL 18, 2025 04:41 AM"
    current_end_str := "AUG 11, 2025 07:20 AM"
else if time >= 1762714740000 and time <= 1764438480000
    is_retro := true
    current_start_str := "NOV 09, 2025 06:59 PM"
    current_end_str := "NOV 29, 2025 05:48 PM"
else if time >= 1772088060000 and time <= 1774035300000
    is_retro := true
    current_start_str := "FEB 26, 2026 06:41 AM"
    current_end_str := "MAR 20, 2026 07:35 PM"
else if time >= 1782754800000 and time <= 1784847120000
    is_retro := true
    current_start_str := "JUN 29, 2026 05:40 PM"
    current_end_str := "JUL 23, 2026 10:52 PM"
else if time >= 1792826040000 and time <= 1794585420000
    is_retro := true
    current_start_str := "OCT 24, 2026 07:14 AM"
    current_end_str := "NOV 13, 2026 03:57 PM"
else if time >= 1802193960000 and time <= 1804077300000
    is_retro := true
    current_start_str := "FEB 09, 2027 05:26 PM"
    current_end_str := "MAR 03, 2027 12:35 PM"
else if time >= 1812650700000 and time <= 1814730540000
    is_retro := true
    current_start_str := "JUN 10, 2027 06:05 PM"
    current_end_str := "JUL 04, 2027 07:49 PM"
else if time >= 1822919400000 and time <= 1824732900000
    is_retro := true
    current_start_str := "OCT 07, 2027 02:30 PM"
    current_end_str := "OCT 28, 2027 02:15 PM"
else if time >= 1832323680000 and time <= 1834144200000
    is_retro := true
    current_start_str := "JAN 24, 2028 10:48 AM"
    current_end_str := "FEB 14, 2028 12:30 PM"
else if time >= 1842510600000 and time <= 1844575440000
    is_retro := true
    current_start_str := "MAY 21, 2028 08:30 AM"
    current_end_str := "JUN 14, 2028 06:04 AM"
else if time >= 1852993200000 and time <= 1854873180000
    is_retro := true
    current_start_str := "SEP 19, 2028 04:20 PM"
    current_end_str := "OCT 11, 2028 10:33 AM"
else if time >= 1862465640000 and time <= 1864232940000
    is_retro := true
    current_start_str := "JAN 07, 2029 07:34 AM"
    current_end_str := "JAN 27, 2029 06:29 PM"
else if time >= 1872371340000 and time <= 1874430240000
    is_retro := true
    current_start_str := "MAY 01, 2029 11:09 PM"
    current_end_str := "MAY 25, 2029 07:04 PM"
else if time >= 1883045520000 and time <= 1884995880000
    is_retro := true
    current_start_str := "SEP 02, 2029 12:12 PM"
    current_end_str := "SEP 25, 2029 01:58 AM"
else if time >= 1892611920000 and time <= 1894340520000
    is_retro := true
    current_start_str := "DEC 22, 2029 05:32 AM"
    current_end_str := "JAN 11, 2030 05:42 AM"
else if time >= 1902277620000 and time <= 1904329080000
    is_retro := true
    current_start_str := "APR 13, 2030 02:27 AM"
    current_end_str := "MAY 06, 2030 08:18 PM"
else if time >= 1913073900000 and time <= 1915089660000
    is_retro := true
    current_start_str := "AUG 16, 2030 01:25 AM"
    current_end_str := "SEP 08, 2030 09:21 AM"
else if time >= 1922755140000 and time <= 1924464240000
    is_retro := true
    current_start_str := "DEC 06, 2030 02:39 AM"
    current_end_str := "DEC 25, 2030 09:24 PM"
else if time >= 1932251460000 and time <= 1934277720000
    is_retro := true
    current_start_str := "MAR 26, 2031 12:31 AM"
    current_end_str := "APR 18, 2031 11:22 AM"
else if time >= 1943073840000 and time <= 1945139340000
    is_retro := true
    current_start_str := "JUL 29, 2031 06:44 AM"
    current_end_str := "AUG 22, 2031 04:29 AM"
else if time >= 1952888760000 and time <= 1954600080000
    is_retro := true
    current_start_str := "NOV 19, 2031 09:06 PM"
    current_end_str := "DEC 09, 2031 04:28 PM"
else if time >= 1962288780000 and time <= 1964269320000
    is_retro := true
    current_start_str := "MAR 07, 2032 04:13 PM"
    current_end_str := "MAR 30, 2032 02:22 PM"
else if time >= 1973038680000 and time <= 1975129080000
    is_retro := true
    current_start_str := "JUL 10, 2032 02:18 AM"
    current_end_str := "AUG 03, 2032 06:58 AM"
else if time >= 1983008580000 and time <= 1984744740000
    is_retro := true
    current_start_str := "NOV 02, 2032 11:43 AM"
    current_end_str := "NOV 22, 2032 01:59 PM"
else if time >= 1992374040000 and time <= 1994294820000
    is_retro := true
    current_start_str := "FEB 18, 2033 09:14 PM"
    current_end_str := "MAR 13, 2033 02:47 AM"
else if time >= 2002960860000 and time <= 2005049520000
    is_retro := true
    current_start_str := "JUN 21, 2033 10:01 AM"
    current_end_str := "JUL 15, 2033 02:12 PM"
else if time >= 2013112560000 and time <= 2014893960000
    is_retro := true
    current_start_str := "OCT 16, 2033 09:56 PM"
    current_end_str := "NOV 06, 2033 12:46 PM"
else if time >= 2022491280000 and time <= 2024347860000
    is_retro := true
    current_start_str := "FEB 02, 2034 11:08 AM"
    current_end_str := "FEB 23, 2034 10:51 PM"
else if time >= 2032838880000 and time <= 2034911580000
    is_retro := true
    current_start_str := "JUN 02, 2034 05:28 AM"
    current_end_str := "JUN 26, 2034 05:13 AM"
else if time >= 2043198060000 and time <= 2045039280000
    is_retro := true
    current_start_str := "SEP 30, 2034 03:01 AM"
    current_end_str := "OCT 21, 2034 10:28 AM"
else if time >= 2052627720000 and time <= 2054424480000
    is_retro := true
    current_start_str := "JAN 17, 2035 06:22 AM"
    current_end_str := "FEB 07, 2035 01:28 AM"
else if time >= 2062693620000 and time <= 2064754980000
    is_retro := true
    current_start_str := "MAY 13, 2035 06:27 PM"
    current_end_str := "JUN 06, 2035 03:03 PM"
else if time >= 2073263040000 and time <= 2075172840000
    is_retro := true
    current_start_str := "SEP 13, 2035 02:24 AM"
    current_end_str := "OCT 05, 2035 04:54 AM"
else if time >= 2082773220000 and time <= 2084521380000
    is_retro := true
    current_start_str := "JAN 01, 2036 04:07 AM"
    current_end_str := "JAN 21, 2036 09:43 AM"
else if time >= 2092568700000 and time <= 2094625680000
    is_retro := true
    current_start_str := "APR 23, 2036 01:05 PM"
    current_end_str := "MAY 17, 2036 08:28 AM"
else if time >= 2103305580000 and time <= 2105284860000
    is_retro := true
    current_start_str := "AUG 25, 2036 07:33 PM"
    current_end_str := "SEP 17, 2036 05:21 PM"
else if time >= 2112918960000 and time <= 2114635800000
    is_retro := true
    current_start_str := "DEC 15, 2036 01:56 AM"
    current_end_str := "JAN 03, 2037 10:50 PM"
else if time >= 2122502700000 and time <= 2124546120000
    is_retro := true
    current_start_str := "APR 05, 2037 12:05 AM"
    current_end_str := "APR 28, 2037 03:42 PM"
else if time >= 2133322440000 and time <= 2135361780000
    is_retro := true
    current_start_str := "AUG 08, 2037 05:34 AM"
    current_end_str := "AUG 31, 2037 08:03 PM"
else if time >= 2143057560000 and time <= 2144765100000
    is_retro := true
    current_start_str := "NOV 28, 2037 09:46 PM"
    current_end_str := "DEC 18, 2037 04:05 PM"
else if time >= 2152505040000 and time <= 2154514260000
    is_retro := true
    current_start_str := "MAR 18, 2038 06:04 AM"
    current_end_str := "APR 10, 2038 12:11 PM"
else if time >= 2163308580000 and time <= 2165388000000
    is_retro := true
    current_start_str := "JUL 21, 2038 07:03 AM"
    current_end_str := "AUG 14, 2038 08:40 AM"
else if time >= 2173186140000 and time <= 2174906160000
    is_retro := true
    current_start_str := "NOV 12, 2038 02:49 PM"
    current_end_str := "DEC 02, 2038 12:36 PM"


// Find next event for dashboard
int current_time_ms = time

if is_retro
    // If currently in retrograde, the next event is the end of the current retrograde
    next_event_type := "Retrograde Ends"
    next_event_str := current_end_str
    next_event_ts := 0 // Placeholder, will be set by if-else below
    if false
        next_event_ts := 0
    else if time >= 1521763560000 and time <= 1523784420000
        next_event_ts := 1523784420000
    else if time >= 1532581380000 and time <= 1534652280000
        next_event_ts := 1534652280000
    else if time >= 1542417420000 and time <= 1544131500000
        next_event_ts := 1544131500000
    else if time >= 1551809100000 and time <= 1553781480000
        next_event_ts := 1553781480000
    else if time >= 1562540460000 and time <= 1564632180000
        next_event_ts := 1564632180000
    else if time >= 1572535560000 and time <= 1574277900000
        next_event_ts := 1574277900000
    else if time >= 1581900060000 and time <= 1583811420000
        next_event_ts := 1583811420000
    else if time >= 1592455620000 and time <= 1594542300000
        next_event_ts := 1594542300000
    else if time >= 1602636960000 and time <= 1604426280000
        next_event_ts := 1604426280000
    else if time >= 1612021200000 and time <= 1613868240000
        next_event_ts := 1613868240000
    else if time >= 1622328000000 and time <= 1624398420000
        next_event_ts := 1624398420000
    else if time >= 1632719400000 and time <= 1634569860000
        next_event_ts := 1634569860000
    else if time >= 1642159920000 and time <= 1643947860000
        next_event_ts := 1643947860000
    else if time >= 1652182920000 and time <= 1654243500000
        next_event_ts := 1654243500000
    else if time >= 1662781260000 and time <= 1664701440000
        next_event_ts := 1664701440000
    else if time >= 1672305360000 and time <= 1674047400000
        next_event_ts := 1674047400000
    else if time >= 1682065020000 and time <= 1684121040000
        next_event_ts := 1684121040000
    else if time >= 1692820200000 and time <= 1694809320000
        next_event_ts := 1694809320000
    else if time >= 1702449660000 and time <= 1704164520000
        next_event_ts := 1704164520000
    else if time >= 1712009340000 and time <= 1714048920000
        next_event_ts := 1714048920000
    else if time >= 1722832800000 and time <= 1724879640000
        next_event_ts := 1724879640000
    else if time >= 1732588020000 and time <= 1734296220000
        next_event_ts := 1734296220000
    else if time >= 1742021100000 and time <= 1744023420000
        next_event_ts := 1744023420000
    else if time >= 1752813660000 and time <= 1754896800000
        next_event_ts := 1754896800000
    else if time >= 1762714740000 and time <= 1764438480000
        next_event_ts := 1764438480000
    else if time >= 1772088060000 and time <= 1774035300000
        next_event_ts := 1774035300000
    else if time >= 1782754800000 and time <= 1784847120000
        next_event_ts := 1784847120000
    else if time >= 1792826040000 and time <= 1794585420000
        next_event_ts := 1794585420000
    else if time >= 1802193960000 and time <= 1804077300000
        next_event_ts := 1804077300000
    else if time >= 1812650700000 and time <= 1814730540000
        next_event_ts := 1814730540000
    else if time >= 1822919400000 and time <= 1824732900000
        next_event_ts := 1824732900000
    else if time >= 1832323680000 and time <= 1834144200000
        next_event_ts := 1834144200000
    else if time >= 1842510600000 and time <= 1844575440000
        next_event_ts := 1844575440000
    else if time >= 1852993200000 and time <= 1854873180000
        next_event_ts := 1854873180000
    else if time >= 1862465640000 and time <= 1864232940000
        next_event_ts := 1864232940000
    else if time >= 1872371340000 and time <= 1874430240000
        next_event_ts := 1874430240000
    else if time >= 1883045520000 and time <= 1884995880000
        next_event_ts := 1884995880000
    else if time >= 1892611920000 and time <= 1894340520000
        next_event_ts := 1894340520000
    else if time >= 1902277620000 and time <= 1904329080000
        next_event_ts := 1904329080000
    else if time >= 1913073900000 and time <= 1915089660000
        next_event_ts := 1915089660000
    else if time >= 1922755140000 and time <= 1924464240000
        next_event_ts := 1924464240000
    else if time >= 1932251460000 and time <= 1934277720000
        next_event_ts := 1934277720000
    else if time >= 1943073840000 and time <= 1945139340000
        next_event_ts := 1945139340000
    else if time >= 1952888760000 and time <= 1954600080000
        next_event_ts := 1954600080000
    else if time >= 1962288780000 and time <= 1964269320000
        next_event_ts := 1964269320000
    else if time >= 1973038680000 and time <= 1975129080000
        next_event_ts := 1975129080000
    else if time >= 1983008580000 and time <= 1984744740000
        next_event_ts := 1984744740000
    else if time >= 1992374040000 and time <= 1994294820000
        next_event_ts := 1994294820000
    else if time >= 2002960860000 and time <= 2005049520000
        next_event_ts := 2005049520000
    else if time >= 2013112560000 and time <= 2014893960000
        next_event_ts := 2014893960000
    else if time >= 2022491280000 and time <= 2024347860000
        next_event_ts := 2024347860000
    else if time >= 2032838880000 and time <= 2034911580000
        next_event_ts := 2034911580000
    else if time >= 2043198060000 and time <= 2045039280000
        next_event_ts := 2045039280000
    else if time >= 2052627720000 and time <= 2054424480000
        next_event_ts := 2054424480000
    else if time >= 2062693620000 and time <= 2064754980000
        next_event_ts := 2064754980000
    else if time >= 2073263040000 and time <= 2075172840000
        next_event_ts := 2075172840000
    else if time >= 2082773220000 and time <= 2084521380000
        next_event_ts := 2084521380000
    else if time >= 2092568700000 and time <= 2094625680000
        next_event_ts := 2094625680000
    else if time >= 2103305580000 and time <= 2105284860000
        next_event_ts := 2105284860000
    else if time >= 2112918960000 and time <= 2114635800000
        next_event_ts := 2114635800000
    else if time >= 2122502700000 and time <= 2124546120000
        next_event_ts := 2124546120000
    else if time >= 2133322440000 and time <= 2135361780000
        next_event_ts := 2135361780000
    else if time >= 2143057560000 and time <= 2144765100000
        next_event_ts := 2144765100000
    else if time >= 2152505040000 and time <= 2154514260000
        next_event_ts := 2154514260000
    else if time >= 2163308580000 and time <= 2165388000000
        next_event_ts := 2165388000000
    else if time >= 2173186140000 and time <= 2174906160000
        next_event_ts := 2174906160000
else
    // Not in retrograde, find the start of the next retrograde
    next_event_type := "Retrograde Starts"
    next_event_ts := 9999999999999 // Initialize with a very large timestamp
    next_event_str := "N/A"
    if false
        next_event_ts := 0
    else if time < 1521763560000 and 1521763560000 < next_event_ts
        next_event_ts := 1521763560000
        next_event_str := "MAR 23, 2018 12:06 AM"
    else if time < 1532581380000 and 1532581380000 < next_event_ts
        next_event_ts := 1532581380000
        next_event_str := "JUL 26, 2018 05:03 AM"
    else if time < 1542417420000 and 1542417420000 < next_event_ts
        next_event_ts := 1542417420000
        next_event_str := "NOV 17, 2018 01:17 AM"
    else if time < 1551809100000 and 1551809100000 < next_event_ts
        next_event_ts := 1551809100000
        next_event_str := "MAR 05, 2019 06:05 PM"
    else if time < 1562540460000 and 1562540460000 < next_event_ts
        next_event_ts := 1562540460000
        next_event_str := "JUL 07, 2019 11:01 PM"
    else if time < 1572535560000 and 1572535560000 < next_event_ts
        next_event_ts := 1572535560000
        next_event_str := "OCT 31, 2019 03:26 PM"
    else if time < 1581900060000 and 1581900060000 < next_event_ts
        next_event_ts := 1581900060000
        next_event_str := "FEB 17, 2020 12:41 AM"
    else if time < 1592455620000 and 1592455620000 < next_event_ts
        next_event_ts := 1592455620000
        next_event_str := "JUN 18, 2020 04:47 AM"
    else if time < 1602636960000 and 1602636960000 < next_event_ts
        next_event_ts := 1602636960000
        next_event_str := "OCT 14, 2020 12:56 AM"
    else if time < 1612021200000 and 1612021200000 < next_event_ts
        next_event_ts := 1612021200000
        next_event_str := "JAN 30, 2021 03:40 PM"
    else if time < 1622328000000 and 1622328000000 < next_event_ts
        next_event_ts := 1622328000000
        next_event_str := "MAY 29, 2021 10:40 PM"
    else if time < 1632719400000 and 1632719400000 < next_event_ts
        next_event_ts := 1632719400000
        next_event_str := "SEP 27, 2021 05:10 AM"
    else if time < 1642159920000 and 1642159920000 < next_event_ts
        next_event_ts := 1642159920000
        next_event_str := "JAN 14, 2022 11:32 AM"
    else if time < 1652182920000 and 1652182920000 < next_event_ts
        next_event_ts := 1652182920000
        next_event_str := "MAY 10, 2022 11:42 AM"
    else if time < 1662781260000 and 1662781260000 < next_event_ts
        next_event_ts := 1662781260000
        next_event_str := "SEP 10, 2022 03:41 AM"
    else if time < 1672305360000 and 1672305360000 < next_event_ts
        next_event_ts := 1672305360000
        next_event_str := "DEC 29, 2022 09:16 AM"
    else if time < 1682065020000 and 1682065020000 < next_event_ts
        next_event_ts := 1682065020000
        next_event_str := "APR 21, 2023 08:17 AM"
    else if time < 1692820200000 and 1692820200000 < next_event_ts
        next_event_ts := 1692820200000
        next_event_str := "AUG 23, 2023 07:50 PM"
    else if time < 1702449660000 and 1702449660000 < next_event_ts
        next_event_ts := 1702449660000
        next_event_str := "DEC 13, 2023 06:41 AM"
    else if time < 1712009340000 and 1712009340000 < next_event_ts
        next_event_ts := 1712009340000
        next_event_str := "APR 01, 2024 10:09 PM"
    else if time < 1722832800000 and 1722832800000 < next_event_ts
        next_event_ts := 1722832800000
        next_event_str := "AUG 05, 2024 04:40 AM"
    else if time < 1732588020000 and 1732588020000 < next_event_ts
        next_event_ts := 1732588020000
        next_event_str := "NOV 26, 2024 02:27 AM"
    else if time < 1742021100000 and 1742021100000 < next_event_ts
        next_event_ts := 1742021100000
        next_event_str := "MAR 15, 2025 06:45 AM"
    else if time < 1752813660000 and 1752813660000 < next_event_ts
        next_event_ts := 1752813660000
        next_event_str := "JUL 18, 2025 04:41 AM"
    else if time < 1762714740000 and 1762714740000 < next_event_ts
        next_event_ts := 1762714740000
        next_event_str := "NOV 09, 2025 06:59 PM"
    else if time < 1772088060000 and 1772088060000 < next_event_ts
        next_event_ts := 1772088060000
        next_event_str := "FEB 26, 2026 06:41 AM"
    else if time < 1782754800000 and 1782754800000 < next_event_ts
        next_event_ts := 1782754800000
        next_event_str := "JUN 29, 2026 05:40 PM"
    else if time < 1792826040000 and 1792826040000 < next_event_ts
        next_event_ts := 1792826040000
        next_event_str := "OCT 24, 2026 07:14 AM"
    else if time < 1802193960000 and 1802193960000 < next_event_ts
        next_event_ts := 1802193960000
        next_event_str := "FEB 09, 2027 05:26 PM"
    else if time < 1812650700000 and 1812650700000 < next_event_ts
        next_event_ts := 1812650700000
        next_event_str := "JUN 10, 2027 06:05 PM"
    else if time < 1822919400000 and 1822919400000 < next_event_ts
        next_event_ts := 1822919400000
        next_event_str := "OCT 07, 2027 02:30 PM"
    else if time < 1832323680000 and 1832323680000 < next_event_ts
        next_event_ts := 1832323680000
        next_event_str := "JAN 24, 2028 10:48 AM"
    else if time < 1842510600000 and 1842510600000 < next_event_ts
        next_event_ts := 1842510600000
        next_event_str := "MAY 21, 2028 08:30 AM"
    else if time < 1852993200000 and 1852993200000 < next_event_ts
        next_event_ts := 1852993200000
        next_event_str := "SEP 19, 2028 04:20 PM"
    else if time < 1862465640000 and 1862465640000 < next_event_ts
        next_event_ts := 1862465640000
        next_event_str := "JAN 07, 2029 07:34 AM"
    else if time < 1872371340000 and 1872371340000 < next_event_ts
        next_event_ts := 1872371340000
        next_event_str := "MAY 01, 2029 11:09 PM"
    else if time < 1883045520000 and 1883045520000 < next_event_ts
        next_event_ts := 1883045520000
        next_event_str := "SEP 02, 2029 12:12 PM"
    else if time < 1892611920000 and 1892611920000 < next_event_ts
        next_event_ts := 1892611920000
        next_event_str := "DEC 22, 2029 05:32 AM"
    else if time < 1902277620000 and 1902277620000 < next_event_ts
        next_event_ts := 1902277620000
        next_event_str := "APR 13, 2030 02:27 AM"
    else if time < 1913073900000 and 1913073900000 < next_event_ts
        next_event_ts := 1913073900000
        next_event_str := "AUG 16, 2030 01:25 AM"
    else if time < 1922755140000 and 1922755140000 < next_event_ts
        next_event_ts := 1922755140000
        next_event_str := "DEC 06, 2030 02:39 AM"
    else if time < 1932251460000 and 1932251460000 < next_event_ts
        next_event_ts := 1932251460000
        next_event_str := "MAR 26, 2031 12:31 AM"
    else if time < 1943073840000 and 1943073840000 < next_event_ts
        next_event_ts := 1943073840000
        next_event_str := "JUL 29, 2031 06:44 AM"
    else if time < 1952888760000 and 1952888760000 < next_event_ts
        next_event_ts := 1952888760000
        next_event_str := "NOV 19, 2031 09:06 PM"
    else if time < 1962288780000 and 1962288780000 < next_event_ts
        next_event_ts := 1962288780000
        next_event_str := "MAR 07, 2032 04:13 PM"
    else if time < 1973038680000 and 1973038680000 < next_event_ts
        next_event_ts := 1973038680000
        next_event_str := "JUL 10, 2032 02:18 AM"
    else if time < 1983008580000 and 1983008580000 < next_event_ts
        next_event_ts := 1983008580000
        next_event_str := "NOV 02, 2032 11:43 AM"
    else if time < 1992374040000 and 1992374040000 < next_event_ts
        next_event_ts := 1992374040000
        next_event_str := "FEB 18, 2033 09:14 PM"
    else if time < 2002960860000 and 2002960860000 < next_event_ts
        next_event_ts := 2002960860000
        next_event_str := "JUN 21, 2033 10:01 AM"
    else if time < 2013112560000 and 2013112560000 < next_event_ts
        next_event_ts := 2013112560000
        next_event_str := "OCT 16, 2033 09:56 PM"
    else if time < 2022491280000 and 2022491280000 < next_event_ts
        next_event_ts := 2022491280000
        next_event_str := "FEB 02, 2034 11:08 AM"
    else if time < 2032838880000 and 2032838880000 < next_event_ts
        next_event_ts := 2032838880000
        next_event_str := "JUN 02, 2034 05:28 AM"
    else if time < 2043198060000 and 2043198060000 < next_event_ts
        next_event_ts := 2043198060000
        next_event_str := "SEP 30, 2034 03:01 AM"
    else if time < 2052627720000 and 2052627720000 < next_event_ts
        next_event_ts := 2052627720000
        next_event_str := "JAN 17, 2035 06:22 AM"
    else if time < 2062693620000 and 2062693620000 < next_event_ts
        next_event_ts := 2062693620000
        next_event_str := "MAY 13, 2035 06:27 PM"
    else if time < 2073263040000 and 2073263040000 < next_event_ts
        next_event_ts := 2073263040000
        next_event_str := "SEP 13, 2035 02:24 AM"
    else if time < 2082773220000 and 2082773220000 < next_event_ts
        next_event_ts := 2082773220000
        next_event_str := "JAN 01, 2036 04:07 AM"
    else if time < 2092568700000 and 2092568700000 < next_event_ts
        next_event_ts := 2092568700000
        next_event_str := "APR 23, 2036 01:05 PM"
    else if time < 2103305580000 and 2103305580000 < next_event_ts
        next_event_ts := 2103305580000
        next_event_str := "AUG 25, 2036 07:33 PM"
    else if time < 2112918960000 and 2112918960000 < next_event_ts
        next_event_ts := 2112918960000
        next_event_str := "DEC 15, 2036 01:56 AM"
    else if time < 2122502700000 and 2122502700000 < next_event_ts
        next_event_ts := 2122502700000
        next_event_str := "APR 05, 2037 12:05 AM"
    else if time < 2133322440000 and 2133322440000 < next_event_ts
        next_event_ts := 2133322440000
        next_event_str := "AUG 08, 2037 05:34 AM"
    else if time < 2143057560000 and 2143057560000 < next_event_ts
        next_event_ts := 2143057560000
        next_event_str := "NOV 28, 2037 09:46 PM"
    else if time < 2152505040000 and 2152505040000 < next_event_ts
        next_event_ts := 2152505040000
        next_event_str := "MAR 18, 2038 06:04 AM"
    else if time < 2163308580000 and 2163308580000 < next_event_ts
        next_event_ts := 2163308580000
        next_event_str := "JUL 21, 2038 07:03 AM"
    else if time < 2173186140000 and 2173186140000 < next_event_ts
        next_event_ts := 2173186140000
        next_event_str := "NOV 12, 2038 02:49 PM"


// Visual Settings
bgcolor(is_retro ? color.new(color.red, 85) : na, title="Mercury Retrograde Background")

// Labels for start/end of retrograde
var label last_rx_label = na
var label last_direct_label = na

if is_retro and not is_retro[1] // Retrograde just started
    string tooltip_text = "Mercury Retrograde Starts: " + current_start_str
    last_rx_label := label.new(x=bar_index, y=low, text="Rx", 
                               xloc=xloc.bar_index, yloc=yloc.belowbar, 
                               color=color.new(color.red, 0), textcolor=color.black, 
                               style=label.style_triangledown, tooltip=tooltip_text)
    alert("Mercury Retrograde Started: " + current_start_str, alert.freq_once_per_bar)

if not is_retro and is_retro[1] // Retrograde just ended
    // We need the end_str from the previous bar, which was current_end_str[1]
    string tooltip_text = "Mercury Retrograde Ends: " + current_end_str[1]
    last_direct_label := label.new(x=bar_index, y=high, text="Direct", 
                                  xloc=xloc.bar_index, yloc=yloc.abovebar, 
                                  color=color.new(color.green, 0), textcolor=color.black, 
                                  style=label.style_triangleup, tooltip=tooltip_text)
    alert("Mercury Retrograde Ended: " + current_end_str[1], alert.freq_once_per_bar)

// Dashboard
var table dashboard_table = table.new(position.top_right, 2, 3, border_width=1)

if barstate.islast
    string status_text = is_retro ? "Status: Retrograde" : "Status: Direct"
    string next_event_text = "Next Event: " + next_event_type
    string next_event_time_text = "Time (UTC): " + next_event_str

    // Calculate countdown
    int remaining_ms = next_event_ts - current_time_ms
    string countdown_text = ""
    if next_event_ts != 0 and remaining_ms > 0
        int days = remaining_ms / (1000 * 60 * 60 * 24)
        int hours = (remaining_ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)
        int minutes = (remaining_ms % (1000 * 60 * 60)) / (1000 * 60)
        countdown_text := "Countdown: " + str.tostring(days) + "d " + str.tostring(hours) + "h " + str.tostring(minutes) + "m"
    else if next_event_ts != 0 and remaining_ms <= 0
        countdown_text := "Countdown: Event Passed"
    else
        countdown_text := "Countdown: N/A"

    table.cell(dashboard_table, 0, 0, status_text, text_color=is_retro ? color.red : color.green, text_size=size.small)
    table.cell(dashboard_table, 0, 1, next_event_text, text_color=color.black, text_size=size.small)
    table.cell(dashboard_table, 1, 0, next_event_time_text, text_color=color.black, text_size=size.small)
    table.cell(dashboard_table, 1, 1, countdown_text, text_color=color.black, text_size=size.small)
````
