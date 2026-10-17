# US Treasury Auction Dates (10Y/20Y/30Y)

- url: https://www.tradingview.com/script/my0gScLM/
- type: indicator
- pine_id: PUB;1e9c84c906c84517875bf80598e88114
- version: 5.0

## Description

This indicator automatically plots U.S. Treasury auction dates for 10-Year Notes, 20-Year Bonds, and 30-Year Bonds on your chart.

The data used in this indicator is sourced entirely from official U.S. Department of the Treasury channels.  It combines two official data streams to ensure absolute historical accuracy and up-to-date future scheduling:

1. Historical Auction Records (API)
  • Source: U.S. Treasury Fiscal Data API.
  • Endpoint:  v1/accounting/od/auctions_query 
  • Coverage: Complete official historical records from 1979 to the present.
2. Future Tentative Auction Schedules (XML)
  • Source: U.S. Department of the Treasury's official Tentative Auction Schedule service.
  • File URL:  https://home.treasury.gov/system/files/221/Tentative-Auction-Schedule.xml 
  • Coverage: The most recently announced tentative schedules for upcoming months.

New Issues and Reopenings are separate。TIPS are excluded.
This indicator is updated regularly with new auction dates.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © US_Treasury_Auction_Dates

//@version=6
indicator("US Treasury Auction Dates (10Y/20Y/30Y)", shorttitle="TY Auctions", overlay = true, max_labels_count = 500)

// =============================================================================
// ENUMS  (v6: 类型安全的枚举，代替 input.string + options=[...])
// =============================================================================
enum LabelSize
    Tiny   = "tiny"
    Small  = "small"
    Normal = "normal"
    Large  = "large"
    Huge   = "huge"

enum LabelPos
    Above = "above"
    Below = "below"

// =============================================================================
// INPUTS
// =============================================================================
show10Y   = input.bool(true, "Show 10-Year Note Auctions (New Issue)", group = "Display")
show10YR  = input.bool(true, "Show 10-Year Note Auctions (Reopening)", group = "Display")
show20Y   = input.bool(true, "Show 20-Year Bond Auctions (New Issue)", group = "Display")
show20YR  = input.bool(true, "Show 20-Year Bond Auctions (Reopening)", group = "Display")
show30Y   = input.bool(true, "Show 30-Year Bond Auctions (New Issue)", group = "Display")
show30YR  = input.bool(true, "Show 30-Year Bond Auctions (Reopening)", group = "Display")
showUpcoming = input.bool(true, "Show Upcoming Auction Table", group = "Display")

lblSizeIn = input.enum(LabelSize.Small, "Label Size",     group = "Style")
lblPosIn  = input.enum(LabelPos.Above,  "Label Position", group = "Style")
color10Y  = input.color(color.new(#00C4FF, 0), "10-Year Color", group = "Style")
color20Y  = input.color(color.new(#FFD700, 0), "20-Year Color", group = "Style")
color30Y  = input.color(color.new(#FF6B35, 0), "30-Year Color", group = "Style")

// =============================================================================
// HISTORICAL AUCTION DATES  (YYYYMMDD integers, O(n) lookup)
//
// Sources: US Treasury Fiscal Data API (v1/accounting/od/auctions_query)
//          + TreasuryDirect historical auction records
// 10Y Note  → quarterly in early years, monthly from ~2003 onward
// 20Y Bond  → monthly, typically 3rd Wednesday  (reintroduced May 2020)
// 30Y Bond  → monthly, typically 2nd Thursday
//             (No 30Y in Jan 2024 or Jul 2024 per official records)
// =============================================================================

// ---------- 10-YEAR NOTE NEW ISSUES (220 records) ----------
var array<int> dates10Y = array.from(
    // 1979
    19791031,
    // 1980
    19800806, 19801106,
    // 1981
    19810506, 19810805, 19811104,
    // 1982
    19820203, 19820505, 19821104,
    // 1983
    19830202, 19830504, 19830803, 19831109,
    // 1984
    19840509, 19840808, 19841107,
    // 1985
    19850206, 19850508, 19850807, 19851121,
    // 1986
    19860205, 19860507, 19861105,
    // 1987
    19870506, 19870812, 19871104,
    // 1988
    19880203, 19880511, 19880810, 19881109,
    // 1989
    19890208, 19890510, 19890809, 19891113,
    // 1990
    19900207, 19900509, 19900808, 19901107,
    // 1991
    19910206, 19910508, 19910807, 19911106,
    // 1992
    19920506, 19920812,
    // 1993
    19930210, 19930811,
    // 1994
    19940209, 19940511, 19940810, 19941109,
    // 1995
    19950208, 19950510, 19950809, 19951121,
    // 1996
    19960207, 19960508, 19960709, 19961008,
    // 1997
    19970212, 19970507, 19970806,
    // 1998
    19980211, 19980513, 19981104,
    // 1999
    19990512, 19990811,
    // 2000
    20000209, 20000809,
    // 2001
    20010207, 20010808,
    // 2002
    20020206, 20020807, 20021106,
    // 2003
    20030212, 20030508, 20030807, 20031113,
    // 2004
    20040212, 20040513, 20040812, 20041110,
    // 2005
    20050210, 20050512, 20050811, 20051110,
    // 2006
    20060208, 20060511, 20060809, 20061109,
    // 2007
    20070207, 20070508, 20070808, 20071107,
    // 2008
    20080206, 20080507, 20080806, 20081112,
    // 2009
    20090211, 20090506, 20090812, 20091110,
    // 2010
    20100210, 20100512, 20100811, 20101109,
    // 2011
    20110209, 20110511, 20110810, 20111109,
    // 2012
    20120208, 20120509, 20120808, 20121107,
    // 2013
    20130213, 20130508, 20130807, 20131113,
    // 2014
    20140212, 20140507, 20140813, 20141112,
    // 2015
    20150211, 20150513, 20150812, 20151110,
    // 2016
    20160210, 20160511, 20160810, 20161109,
    // 2017
    20170208, 20170510, 20170809, 20171108,
    // 2018
    20180207, 20180509, 20180808, 20181106,
    // 2019
    20190206, 20190508, 20190807, 20191106,
    // 2020
    20200212, 20200512, 20200812, 20201110,
    // 2021
    20210210, 20210512, 20210811, 20211109,
    // 2022
    20220209, 20220511, 20220810, 20221109,
    // 2023
    20230208, 20230510, 20230809, 20231108,
    // 2024
    20240207, 20240508, 20240807, 20241105,
    // 2025
    20250212, 20250506, 20250806, 20251112,
    // 2026
    20260211, 20260512, 20260812, 20261110
    )

// ---------- 10-YEAR NOTE REOPENINGS (197 records) ----------
var array<int> dates10YReopen = array.from(
    // 1996
    19960807, 19961106,
    // 2001
    20011004,
    // 2003
    20030911, 20031211,
    // 2004
    20040311, 20040610, 20040909, 20041209,
    // 2005
    20050310, 20050609, 20050908, 20051208,
    // 2006
    20060309, 20060608, 20060912, 20061213,
    // 2007
    20070313, 20070612, 20070913, 20071213,
    // 2008
    20080313, 20080612, 20080911, 20081211,
    // 2009
    20090108, 20090311, 20090409, 20090610, 20090708, 20090909, 20091007, 20091209,
    // 2010
    20100113, 20100310, 20100407, 20100609, 20100713, 20100908, 20101013, 20101208,
    // 2011
    20110112, 20110309, 20110413, 20110608, 20110713, 20110913, 20111012, 20111213,
    // 2012
    20120111, 20120313, 20120411, 20120613, 20120711, 20120912, 20121010, 20121212,
    // 2013
    20130109, 20130313, 20130410, 20130612, 20130710, 20130911, 20131009, 20131211,
    // 2014
    20140108, 20140312, 20140409, 20140611, 20140709, 20140910, 20141008, 20141210,
    // 2015
    20150113, 20150311, 20150408, 20150610, 20150708, 20150909, 20151007, 20151209,
    // 2016
    20160113, 20160309, 20160413, 20160608, 20160712, 20160912, 20161012, 20161212,
    // 2017
    20170111, 20170308, 20170411, 20170612, 20170712, 20170912, 20171011, 20171211,
    // 2018
    20180110, 20180312, 20180411, 20180611, 20180711, 20180912, 20181010, 20181212,
    // 2019
    20190109, 20190312, 20190410, 20190612, 20190621, 20190710, 20190911, 20191009, 20191210,
    // 2020
    20200108, 20200311, 20200407, 20200609, 20200708, 20200909, 20201007, 20201209,
    // 2021
    20210112, 20210310, 20210412, 20210609, 20210712, 20210908, 20211012, 20211208,
    // 2022
    20220112, 20220309, 20220412, 20220608, 20220712, 20220912, 20221012, 20221212,
    // 2023
    20230111, 20230308, 20230412, 20230612, 20230712, 20230912, 20231011, 20231211,
    // 2024
    20240110, 20240312, 20240410, 20240611, 20240710, 20240911, 20241009, 20241211,
    // 2025
    20250107, 20250312, 20250409, 20250611, 20250709, 20250910, 20251008, 20251209,
    // 2026
    20260112, 20260311, 20260408, 20260610, 20260708, 20260909, 20261007, 20261208,
    // 2027
    20270112
    )

// ---------- 20-YEAR BOND NEW ISSUES ----------
var array<int> dates20Y = array.from(
    // 2020
    20200520, 20200819, 20201118,
    // 2021
    20210217, 20210519, 20210818, 20211117,
    // 2022
    20220216, 20220518, 20220817, 20221116,
    // 2023
    20230215, 20230517, 20230823, 20231120,
    // 2024
    20240221, 20240522, 20240821, 20241120,
    // 2025
    20250219, 20250521, 20250820, 20251119,
    // 2026
    20260218, 20260520, 20260819, 20261118
    )

// ---------- 20-YEAR BOND REOPENINGS ----------
var array<int> dates20YReopen = array.from(
    // 1983
    19831229,
    // 1985
    19850103,
    // 2020
    20200617, 20200722, 20200915, 20201021, 20201221,
    // 2021
    20210120, 20210316, 20210421, 20210615, 20210721, 20210921, 20211020, 20211202, 20211221,
    // 2022
    20220119, 20220323, 20220420, 20220622, 20220720, 20220920, 20221019, 20221221,
    // 2023
    20230118, 20230321, 20230419, 20230621, 20230719, 20230919, 20231018, 20231220,
    // 2024
    20240117, 20240319, 20240417, 20240618, 20240717, 20240917, 20241023, 20241217,
    // 2025
    20250122, 20250318, 20250416, 20250616, 20250723, 20250916, 20251022, 20251217,
    // 2026
    20260121, 20260317, 20260422, 20260616, 20260722, 20260915, 20261021, 20261223,
    // 2027
    20270120
    )

// ---------- 30-YEAR BOND NEW ISSUES ----------
var array<int> dates30Y = array.from(
    // 1979
    19791101,
    // 1980
    19800207, 19800508, 19801107,
    // 1981
    19810507, 19811105,
    // 1982
    19821109,
    // 1983
    19830804,
    // 1984
    19840510, 19840809, 19841108,
    // 1985
    19850207, 19850808, 19851122,
    // 1986
    19860206, 19860508, 19861106,
    // 1987
    19870507, 19870813,
    // 1988
    19880512, 19881117,
    // 1989
    19890209, 19890810,
    // 1990
    19900208, 19900510, 19900809,
    // 1991
    19910207, 19910509, 19910808, 19911107,
    // 1992
    19920813, 19921112,
    // 1993
    19930211, 19930812,
    // 1995
    19950209, 19950810,
    // 1996
    19960208, 19960808, 19961107,
    // 1997
    19970213, 19970807, 19971106,
    // 1998
    19980813, 19981105,
    // 1999
    19990211, 19990812,
    // 2001
    20010208,
    // 2006
    20060209,
    // 2007
    20070208,
    // 2008
    20080207,
    // 2009
    20090212, 20090507, 20090813, 20091112,
    // 2010
    20100211, 20100513, 20100812, 20101110,
    // 2011
    20110210, 20110512, 20110811, 20111110,
    // 2012
    20120209, 20120510, 20120809, 20121108,
    // 2013
    20130214, 20130509, 20130808, 20131114,
    // 2014
    20140213, 20140508, 20140814, 20141113,
    // 2015
    20150212, 20150514, 20150813, 20151112,
    // 2016
    20160211, 20160512, 20160811, 20161110,
    // 2017
    20170209, 20170511, 20170810, 20171109,
    // 2018
    20180208, 20180510, 20180809, 20181107,
    // 2019
    20190207, 20190509, 20190808, 20191107,
    // 2020
    20200213, 20200513, 20200813, 20201112,
    // 2021
    20210211, 20210513, 20210812, 20211110,
    // 2022
    20220210, 20220512, 20220811, 20221110,
    // 2023
    20230209, 20230511, 20230810, 20231109,
    // 2024
    20240208, 20240509, 20240808, 20241106,
    // 2025
    20250213, 20250508, 20250807, 20251113,
    // 2026
    20260212, 20260513, 20260813, 20261112
    )

// ---------- 30-YEAR BOND REOPENINGS ----------
var array<int> dates30YReopen = array.from(
    // 2009
    20090312, 20090611, 20090709, 20090910, 20091008, 20091210,
    // 2010
    20100114, 20100311, 20100408, 20100610, 20100714, 20100909, 20101014, 20101209,
    // 2011
    20110113, 20110310, 20110414, 20110609, 20110714, 20110914, 20111013, 20111214,
    // 2012
    20120112, 20120314, 20120412, 20120614, 20120712, 20120913, 20121011, 20121213,
    // 2013
    20130110, 20130314, 20130411, 20130613, 20130711, 20130912, 20131010, 20131212,
    // 2014
    20140109, 20140313, 20140410, 20140612, 20140710, 20140911, 20141009, 20141211,
    // 2015
    20150114, 20150312, 20150409, 20150611, 20150709, 20150910, 20151008, 20151210,
    // 2016
    20160114, 20160310, 20160414, 20160609, 20160713, 20160913, 20161013, 20161213,
    // 2017
    20170112, 20170309, 20170412, 20170613, 20170713, 20170913, 20171012, 20171212,
    // 2018
    20180111, 20180313, 20180412, 20180612, 20180712, 20180913, 20181011, 20181213,
    // 2019
    20190110, 20190313, 20190411, 20190613, 20190711, 20190912, 20191010, 20191212,
    // 2020
    20200109, 20200312, 20200408, 20200611, 20200709, 20200910, 20201008, 20201210,
    // 2021
    20210113, 20210311, 20210413, 20210610, 20210713, 20210909, 20211013, 20211209,
    // 2022
    20220113, 20220310, 20220413, 20220609, 20220713, 20220913, 20221013, 20221213,
    // 2023
    20230112, 20230309, 20230413, 20230613, 20230713, 20230913, 20231012, 20231212,
    // 2024
    20240111, 20240313, 20240411, 20240613, 20240711, 20240912, 20241010, 20241212,
    // 2025
    20250108, 20250313, 20250410, 20250612, 20250710, 20250911, 20251009, 20251211,
    // 2026
    20260113, 20260312, 20260409, 20260611, 20260709, 20260910, 20261008, 20261210,
    // 2027
    20270113
    )

// =============================================================================
// LOOKUP  (v6: `for v in arr` — cleaner than index-based loop)
// =============================================================================
isInArray(array<int> arr, int val) =>
    found = false
    for v in arr
        if v == val
            found := true
            break
    found

findNextAuction(array<int> newArr, array<int> reopenArr, bool includeNew, bool includeReopen, int currentDate) =>
    int bestDate = na
    string bestType = ""
    if includeNew
        for d in newArr
            if d >= currentDate
                bestDate := d
                bestType := "New"
                break
    if includeReopen
        for d in reopenArr
            if d >= currentDate
                if na(bestDate) or d < bestDate
                    bestDate := d
                    bestType := "Reopen"
                break
    [bestDate, bestType]

dateYear(int dateVal) =>
    int(math.floor(dateVal / 10000))

dateMonth(int dateVal) =>
    int(math.floor(dateVal / 100)) % 100

dateDay(int dateVal) =>
    dateVal % 100

formatDateInt(int dateVal) =>
    na(dateVal) ? "—" : str.tostring(dateYear(dateVal)) + "-" + str.tostring(dateMonth(dateVal), "00") + "-" + str.tostring(dateDay(dateVal), "00")

daysUntil(int dateVal, int currentDate) =>
    if na(dateVal)
        na
    else
        targetTs = timestamp("America/New_York", dateYear(dateVal), dateMonth(dateVal), dateDay(dateVal), 0, 0)
        currentTs = timestamp("America/New_York", dateYear(currentDate), dateMonth(currentDate), dateDay(currentDate), 0, 0)
        int(math.round((targetTs - currentTs) / 86400000))

formatDays(int days) =>
    na(days) ? "—" : days == 0 ? "Today" : str.tostring(days) + "d"

fillUpcomingRow(table tbl, int row, string security, int nextDate, string auctionType, int remainingDays, color accent) =>
    table.cell(tbl, 0, row, security, text_color = accent, bgcolor = color.new(color.black, 82), text_size = size.small)
    table.cell(tbl, 1, row, formatDateInt(nextDate), text_color = color.white, bgcolor = color.new(color.black, 82), text_size = size.small)
    table.cell(tbl, 2, row, auctionType == "" ? "—" : auctionType, text_color = auctionType == "New" ? color.white : color.new(color.white, 25), bgcolor = color.new(color.black, 82), text_size = size.small)
    table.cell(tbl, 3, row, formatDays(remainingDays), text_color = color.white, bgcolor = color.new(accent, 78), text_size = size.small)


// =============================================================================
// CURRENT BAR DATE KEY
// =============================================================================
barDateInt = year * 10000 + month * 100 + dayofmonth
todayDateInt = year(timenow, "America/New_York") * 10000 + month(timenow, "America/New_York") * 100 + dayofmonth(timenow, "America/New_York")

// =============================================================================
// AUCTION DAY FLAGS
// =============================================================================
is10Y  = show10Y and isInArray(dates10Y, barDateInt)
is10YR = show10YR and isInArray(dates10YReopen, barDateInt)
is20Y  = show20Y and isInArray(dates20Y, barDateInt)
is20YR = show20YR and isInArray(dates20YReopen, barDateInt)
is30Y  = show30Y and isInArray(dates30Y, barDateInt)
is30YR = show30YR and isInArray(dates30YReopen, barDateInt)

has10Y = is10Y or is10YR
has20Y = is20Y or is20YR
has30Y = is30Y or is30YR

isAny = has10Y or has20Y or has30Y

// =============================================================================
// v6 RUNTIME LOGGING  (visible in Pine Script Log panel — great for debugging)
// =============================================================================
if isAny and barstate.isconfirmed
    msg = (is10Y ? "10Y " : "") + (is10YR ? "10Y-R " : "") + (is20Y ? "20Y " : "") + (is20YR ? "20Y-R " : "") + (is30Y ? "30Y " : "") + (is30YR ? "30Y-R" : "")
    log.info("Auction day → {0} | {1}-{2,number,00}-{3,number,00}",
             msg, year, month, dayofmonth)

// =============================================================================
// LABEL SIZE & POSITION  (v6: switch expression on enum value)
// =============================================================================
lblSize = switch lblSizeIn
    LabelSize.Tiny   => size.tiny
    LabelSize.Small  => size.small
    LabelSize.Normal => size.normal
    LabelSize.Large  => size.large
    LabelSize.Huge   => size.huge

lblYloc  = lblPosIn == LabelPos.Above ? yloc.abovebar : yloc.belowbar
lblStyle = lblPosIn == LabelPos.Above ? label.style_label_down : label.style_label_up

// =============================================================================
// COLORS  (v6: switch expressions — much cleaner than nested ternary chains)
// =============================================================================
bgColor = switch
    has10Y and has20Y and has30Y => color.new(#8B5CF6, 15)   // all three  → purple
    has10Y and has30Y            => color.new(#4F9FFF, 15)   // 10Y + 30Y  → blue
    has10Y and has20Y            => color.new(#00D4AA, 15)   // 10Y + 20Y  → teal
    has20Y and has30Y            => color.new(#FF9500, 15)   // 20Y + 30Y  → orange
    is10Y                        => color.new(color10Y, 20)
    is10YR                       => color.new(color10Y, 20)
    is20Y                        => color.new(color20Y, 20)
    is20YR                       => color.new(color20Y, 20)
    is30Y                        => color.new(color30Y, 20)
    is30YR                       => color.new(color30Y, 20)
    =>                              na

txtColor = switch
    is10Y and not has20Y and not has30Y  => color10Y
    is10YR and not has20Y and not has30Y => color10Y
    is20Y and not has10Y and not has30Y  => color20Y
    is20YR and not has10Y and not has30Y => color20Y
    is30Y and not has10Y and not has20Y  => color30Y
    is30YR and not has10Y and not has20Y => color30Y
    =>                                      color.white

lineColor = switch
    has10Y and has20Y and has30Y => color.new(#8B5CF6, 50)
    has10Y and has30Y            => color.new(#4F9FFF, 50)
    has10Y and has20Y            => color.new(#00D4AA, 50)
    has20Y and has30Y            => color.new(#FF9500, 50)
    is10Y                        => color.new(color10Y, 50)
    is10YR                       => color.new(color10Y, 50)
    is20Y                        => color.new(color20Y, 50)
    is20YR                       => color.new(color20Y, 50)
    is30Y                        => color.new(color30Y, 50)
    is30YR                       => color.new(color30Y, 50)
    =>                              na

bgHighlight = switch
    has10Y and has20Y and has30Y => color.new(#8B5CF6, 90)
    has10Y and has30Y            => color.new(#4F9FFF, 90)
    has10Y and has20Y            => color.new(#00D4AA, 90)
    has20Y and has30Y            => color.new(#FF9500, 90)
    is10Y                        => color.new(color10Y, 92)
    is10YR                       => color.new(color10Y, 92)
    is20Y                        => color.new(color20Y, 92)
    is20YR                       => color.new(color20Y, 92)
    is30Y                        => color.new(color30Y, 92)
    is30YR                       => color.new(color30Y, 92)
    =>                              na

// =============================================================================
// DRAW
// =============================================================================
var int lastDrawnDate = na
isDrawTime = false
if timeframe.isintraday
    targetTime = timestamp("America/New_York", year, month, dayofmonth, 13, 0)
    if time >= targetTime and (na(lastDrawnDate) or lastDrawnDate != barDateInt)
        isDrawTime := true
        lastDrawnDate := barDateInt
else
    if (ta.change(time("D")) != 0 or bar_index == 0) and (na(lastDrawnDate) or lastDrawnDate != barDateInt)
        isDrawTime := true
        lastDrawnDate := barDateInt

if isAny and isDrawTime
    // Label text
    txt = ""
    if is10Y
        txt := "10Y"
    if is10YR
        txt := "10Y-R"
    if is20Y
        txt := str.length(txt) > 0 ? txt + "\n20Y" : "20Y"
    if is20YR
        txt := str.length(txt) > 0 ? txt + "\n20Y-R" : "20Y-R"
    if is30Y
        txt := str.length(txt) > 0 ? txt + "\n30Y" : "30Y"
    if is30YR
        txt := str.length(txt) > 0 ? txt + "\n30Y-R" : "30Y-R"

    // Tooltip
    tip  = "── US Treasury Auction ──\n"
    tip += is10Y ? "● 10-Year Note (New Issue)\n" : ""
    tip += is10YR ? "○ 10-Year Note (Reopening)\n" : ""
    tip += is20Y ? "● 20-Year Bond (New Issue)\n" : ""
    tip += is20YR ? "○ 20-Year Bond (Reopening)\n" : ""
    tip += is30Y ? "● 30-Year Bond (New Issue)\n" : ""
    tip += is30YR ? "○ 30-Year Bond (Reopening)\n" : ""
    tip += str.tostring(year) + "-" + str.tostring(month, "00") + "-" + str.tostring(dayofmonth, "00")

    label.new(
         bar_index,
         lblPosIn == LabelPos.Above ? high : low,
         text      = txt,
         color     = bgColor,
         textcolor = txtColor,
         size      = lblSize,
         yloc      = lblYloc,
         style     = lblStyle,
         tooltip   = tip
         )

    line.new(
         bar_index, high * 1.001,
         bar_index, low  * 0.999,
         color = lineColor,
         width = 1,
         style = line.style_dashed
         )

bgcolor(bgHighlight, title = "Auction Day Highlight")

// =============================================================================
// UPCOMING AUCTION TABLE
// =============================================================================
var table upcomingTable = table.new(position.top_right, 4, 4, bgcolor = color.new(color.black, 78), border_width = 1, border_color = color.new(color.white, 82), frame_width = 1, frame_color = color.new(color.white, 82))

if barstate.islast
    if showUpcoming
        [next10Y, next10YType] = findNextAuction(dates10Y, dates10YReopen, show10Y, show10YR, todayDateInt)
        [next20Y, next20YType] = findNextAuction(dates20Y, dates20YReopen, show20Y, show20YR, todayDateInt)
        [next30Y, next30YType] = findNextAuction(dates30Y, dates30YReopen, show30Y, show30YR, todayDateInt)

        table.cell(upcomingTable, 0, 0, "Treasury", text_color = color.white, bgcolor = color.new(color.black, 35), text_size = size.small)
        table.cell(upcomingTable, 1, 0, "Next", text_color = color.white, bgcolor = color.new(color.black, 35), text_size = size.small)
        table.cell(upcomingTable, 2, 0, "Type", text_color = color.white, bgcolor = color.new(color.black, 35), text_size = size.small)
        table.cell(upcomingTable, 3, 0, "In", text_color = color.white, bgcolor = color.new(color.black, 35), text_size = size.small)

        fillUpcomingRow(upcomingTable, 1, "10Y", next10Y, next10YType, daysUntil(next10Y, todayDateInt), color10Y)
        fillUpcomingRow(upcomingTable, 2, "20Y", next20Y, next20YType, daysUntil(next20Y, todayDateInt), color20Y)
        fillUpcomingRow(upcomingTable, 3, "30Y", next30Y, next30YType, daysUntil(next30Y, todayDateInt), color30Y)
    else
        table.clear(upcomingTable, 0, 0, 3, 3)
````
