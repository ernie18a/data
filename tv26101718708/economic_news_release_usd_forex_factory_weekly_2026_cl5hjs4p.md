# Economic News Release - USD Forex Factory Weekly 2026

- url: https://www.tradingview.com/script/cl5hJS4P-Economic-News-Release-USD-Forex-Factory-Weekly-2026/
- type: indicator
- pine_id: PUB;31cf906259534547ae70ef911169e23b
- version: 2.0

## Description

[b]Economic News Release – USD Forex Factory Weekly[/b]
A compact, chart-integrated economic calendar designed for traders who need immediate visibility of scheduled U.S. economic events without leaving TradingView.

The indicator displays a weekly USD news table based on Forex Factory calendar classifications and is specifically engineered to remain functional during TradingView Bar Replay. Unlike calendar tools that reference the current real-world date, the displayed week is derived from the chart’s active/replay timestamp, allowing historical sessions to be reviewed with the corresponding embedded economic-event schedule.

[b]Key functionality includes:[/b]
[list]
[*]This Week / Next Week selector for quickly switching between the active calendar week and the following week.
[*]Bar Replay compatibility — the calendar follows the historical replay cursor rather than the current date.
[*]USD events classified by Forex Factory impact:
[*]Red — High Impact
[*]Orange — Medium Impact
[*]Gray — Lower Impact
[*]Silver — U.S. market/bank holidays
[*]Independent filters for each impact category.
[*]One row per economic event, preserving the individual time, event name, and impact classification.
[*]Dynamic table sizing — only the rows required for the selected week are displayed, eliminating unnecessary empty space.
[*]Adjustable table text size from Tiny through Huge.
[*]Customizable table position and background transparency.
[*]Event timestamps standardized to America/New_York / Eastern Time, appropriate for U.S. index and futures-market analysis.
[*]Includes major macroeconomic releases, central-bank events, employment data, inflation data, sentiment releases, scheduled speeches, holidays, and other relevant USD calendar events contained in the embedded database.
[/list]

The indicator is intended primarily as a contextual risk-management and historical-review tool. It can be used to identify when price action occurred around scheduled economic catalysts, distinguish ordinary trading periods from event-driven conditions, and perform more accurate historical session analysis in Bar Replay.

Important: Pine Script cannot directly retrieve live Forex Factory calendar data through arbitrary HTTP requests. Consequently, the calendar is embedded within the script and represents a maintained calendar snapshot. Future event dates, times, or classifications may be revised by the original calendar source and therefore require periodic script updates.

This indicator does not generate trade signals or predict market direction. It provides structured economic-calendar context directly on the chart.

## Source Code

````pine
//@version=6

indicator("Forex Factory USD News - RED ORANGE GRAY - 2026", shorttitle = "FF USD News 2026", overlay = true)

// ============================================================================

// 2026 FOREX FACTORY USD ECONOMIC NEWS CALENDAR - CLASSIFICATION AUDIT

// Source: the user's existing 2026 Forex Factory calendar plus updates checked
// against Forex Factory on 2026-10-12 (Oct 12-23 USD releases).
// Additional Sept 30 - Oct 15 spot checks completed on 2026-10-12.
// Sept 30 and Oct 7 medium-impact speaking events missing in the archive
// have been restored using the corresponding historical daily listings.
// Oct 7 FOMC Minutes (high) and Sep 30 Core PCE (high) remain RED.
// These are different events: a day containing an orange event may also
// contain a separate red event. Color ratings are RELEASE-SPECIFIC.
// Other 2026 dates retain the embedded archive and are NOT fully verified.
// Check Forex Factory directly before trading; schedules/impact can change.

// Included:

//   4 = RED / High impact

//   3 = ORANGE / Medium impact

//   1 = GRAY / Holiday or market-schedule event

// Low-impact releases are intentionally excluded.

//

// Only USD releases are shown by default. The optional global-events switch
// can restore existing "All" events such as meetings that may affect markets.
// All timed events are stored in America/New_York (DST-aware).

// Pine Script cannot query Forex Factory directly, so future calendar changes

// require updating this embedded calendar.

//

// Alert setup:

// TradingView -> Create Alert -> Condition -> this indicator

// -> "Any alert() function call"

// ============================================================================

string TZ = "America/New_York"

int ALERT_WINDOW_MS = 60 * 1000

// ============================================================================

// 01. DISPLAY

// ============================================================================

string GROUP_DISPLAY = "1. News Display"

bool showHigh = input.bool(true, "Show RED / High Impact", group = GROUP_DISPLAY)

bool showMedium = input.bool(true, "Show ORANGE / Medium Impact", group = GROUP_DISPLAY)

bool showHoliday = input.bool(true, "Show GRAY / Holidays & Schedule", group = GROUP_DISPLAY)

bool includeGlobalEvents = input.bool(false, "Include Global / All Events", tooltip = "OFF: USD only. ON: USD plus existing global market events.", group = GROUP_DISPLAY)

string weekChoice = input.string(

     "This Week",

     "Display Week",

     options = ["This Week", "Next Week"],

     tooltip = "Replay-safe. This Week follows the week containing the last chart/replay bar. Next Week advances one calendar week.",

     group = GROUP_DISPLAY

)

string tableLocation = input.string(

     "Bottom Center",

     "Table Location",

     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],

     group = GROUP_DISPLAY

)

int tableTransparency = input.int(

     25,

     "Event Row Transparency",

     minval = 0,

     maxval = 100,

     group = GROUP_DISPLAY

)

string tableTextSize = input.string(

     "Small",

     "Table Text Size",

     options = ["Tiny", "Small", "Normal", "Large", "Huge"],

     group = GROUP_DISPLAY

)

// ============================================================================

// 02. ALERTS

// ============================================================================

string GROUP_ALERTS = "2. Alerts"

string dayAlertMode = input.string(

     "FOMC Days Only",

     "Day Alert Mode",

     options = ["Off", "FOMC Days Only", "RED Days Only", "All Significant Days"],

     tooltip = "FOMC Days Only alerts once on FOMC Statement days. RED Days Only alerts once on any enabled red-folder day. All Significant Days alerts once on any enabled red, orange, or gray-calendar day.",

     group = GROUP_ALERTS

)

bool eventTimeAlerts = input.bool(

     false,

     "Alert When Release Time Arrives",

     tooltip = "Realtime only. Checks on the first received chart update within 60 seconds of scheduled ET release time. Same-time events are grouped together; not an exchange-clock guarantee.",

     group = GROUP_ALERTS

)

// ============================================================================

// 03. CALENDAR STORAGE

// ============================================================================

var array<int> evTs = array.new_int()

var array<string> evName = array.new_string()

var array<int> evImpact = array.new_int()

var array<int> evWeek = array.new_int()

var array<int> evCurrency = array.new_int()  // 0 = USD, 1 = All

var array<int> evFixed = array.new_int()

var array<int> weekStarts = array.new_int()

f_tablePosition(string location) =>

    switch location

        "Top Left" => position.top_left

        "Top Center" => position.top_center

        "Top Right" => position.top_right

        "Middle Left" => position.middle_left

        "Middle Center" => position.middle_center

        "Middle Right" => position.middle_right

        "Bottom Left" => position.bottom_left

        "Bottom Right" => position.bottom_right

        => position.bottom_center

f_textSize(string choice) =>

    switch choice

        "Small" => size.small

        "Normal" => size.normal

        "Large" => size.large

        "Huge" => size.huge

        => size.tiny

f_titleTextSize(string choice) =>

    switch choice

        "Tiny" => size.small

        "Small" => size.normal

        "Normal" => size.large

        "Large" => size.huge

        => size.huge

f_currencyEnabled(int currencyCode) =>
    currencyCode == 0 or includeGlobalEvents

f_impactEnabled(int impact) =>

    impact == 4 ? showHigh :

     impact == 3 ? showMedium :

     impact == 1 ? showHoliday :

     false

f_eventEnabled(int eventIndex) =>
    f_impactEnabled(array.get(evImpact, eventIndex)) and f_currencyEnabled(array.get(evCurrency, eventIndex))

f_impactText(int impact) =>

    impact == 4 ? "RED / High" :

     impact == 3 ? "ORANGE / Medium" :

     impact == 1 ? "GRAY / Holiday" :

     ""

f_impactAlertText(int impact) =>

    impact == 4 ? "RED / HIGH" :

     impact == 3 ? "ORANGE / MEDIUM" :

     impact == 1 ? "GRAY / HOLIDAY-SCHEDULE" :

     "NEWS"

f_impactBg(int impact) =>

    impact == 4 ? color.new(color.red, tableTransparency) :

     impact == 3 ? color.new(color.orange, tableTransparency) :

     impact == 1 ? color.new(color.gray, math.min(tableTransparency + 8, 100)) :

     color.new(color.gray, 88)

f_fixedText(int fixedCode) =>

    fixedCode == 1 ? "All Day" :

     fixedCode == 2 ? "Day 1" :

     fixedCode == 3 ? "Day 2" :

     fixedCode == 4 ? "Day 3" :

     fixedCode == 5 ? "Day 5" :

     fixedCode == 6 ? "Tentative" :

     fixedCode == 7 ? "Oct Data" :

     fixedCode == 8 ? "Nov Data" :

     fixedCode == 9 ? "Feb Data" :

     fixedCode == 10 ? "Dec 13th" :

     ""

f_addEvent(int ts, string eventName, int impact, int weekStart, int currencyCode, int fixedCode) =>

    array.push(evTs, ts)

    array.push(evName, eventName)

    array.push(evImpact, impact)

    array.push(evWeek, weekStart)

    array.push(evCurrency, currencyCode)

    array.push(evFixed, fixedCode)

f_loadWeekStartsPacked(string data) =>

    array<string> rows = str.split(data, ";")

    int rowCount = array.size(rows)

    if rowCount > 0

        for i = 0 to rowCount - 1

            int ymd = int(str.tonumber(array.get(rows, i)))

            int yy = int(ymd / 10000)

            int md = ymd % 10000

            int mm = int(md / 100)

            int dd = md % 100

            array.push(weekStarts, timestamp(TZ, yy, mm, dd, 0, 0))

f_loadPackedEvents(array<string> names, string data) =>

    array<string> rows = str.split(data, ";")

    int rowCount = array.size(rows)

    if rowCount > 0

        for i = 0 to rowCount - 1

            array<string> fields = str.split(array.get(rows, i), ",")

            int weekIndex = int(str.tonumber(array.get(fields, 0)))

            int dateCode = int(str.tonumber(array.get(fields, 1)))

            int timeCode = int(str.tonumber(array.get(fields, 2)))

            int impact = int(str.tonumber(array.get(fields, 3)))

            int currencyCode = int(str.tonumber(array.get(fields, 4)))

            int nameIndex = int(str.tonumber(array.get(fields, 5)))

            int fixedCode = int(str.tonumber(array.get(fields, 6)))

            int mm = int(dateCode / 100)

            int dd = dateCode % 100

            int hh = int(timeCode / 100)

            int min = timeCode % 100

            int ts = timestamp(TZ, 2026, mm, dd, hh, min)

            int weekStart = array.get(weekStarts, weekIndex)

            string eventName = array.get(names, nameIndex)

            f_addEvent(ts, eventName, impact, weekStart, currencyCode, fixedCode)

f_initializeCalendar() =>

    f_loadWeekStartsPacked("20251229;20260105;20260112;20260119;20260126;20260202;20260209;20260216;20260223;20260302;20260309;20260316;20260323;20260330;20260406;20260413;20260420;20260427;20260504;20260511;20260518;20260525;20260601;20260608;20260615;20260622;20260629;20260706;20260713;20260720;20260727;20260803;20260810;20260817;20260824;20260831;20260907;20260914;20260921;20260928;20261005;20261012;20261019;20261026;20261102;20261109;20261116;20261123;20261130;20261207;20261214;20261221;20261228")

    array<string> names = str.split("Bank Holiday|ISM Manufacturing PMI|ISM Manufacturing Prices|President Trump Speaks|Average Hourly Earnings m/m|Non-Farm Employment Change|Unemployment Rate|Prelim UoM Consumer Sentiment|Prelim UoM Inflation Expectations|ADP Weekly Employment Change|CPI m/m|CPI y/y|Core CPI m/m|Core CPI y/y|New Home Sales|Core PPI m/m|PPI m/m|Core Retail Sales m/m|Retail Sales m/m|Unemployment Claims|Empire State Manufacturing Index|Philly Fed Manufacturing Index|WEF Annual Meetings|Pending Home Sales m/m|Core PCE Price Index m/m|Final GDP q/q|Final GDP Price Index q/q|Flash Manufacturing PMI|Flash Services PMI|Revised UoM Consumer Sentiment|Core Durable Goods Orders m/m|Durable Goods Orders m/m|CB Consumer Confidence|Richmond Manufacturing Index|FOMC Statement|Federal Funds Rate|FOMC Press Conference|Treasury Currency Report|OPEC-JMMC Meetings|ADP Non-Farm Employment Change|ISM Services PMI|JOLTS Job Openings|Employment Cost Index q/q|FOMC Meeting Minutes|Advance GDP q/q|Advance GDP Price Index q/q|FOMC Member Waller Speaks|Daylight Saving Time Shift|Prelim GDP q/q|Prelim GDP Price Index q/q|FOMC Economic Projections|FOMC Member Powell Speaks|Fed Chairman Warsh Testifies|Fed Chair Nomination Vote|Treasury Sec Bessent Speaks|OPEC Meetings|Revised UoM Inflation Expectations|Fed Chairman Warsh Speaks|Jackson Hole Symposium|Prelim Benchmark Payrolls Revision|Congressional Elections|FOMC Member Kashkari Speaks", "|")

    f_loadPackedEvents(names, "0,101,0,1,0,0,1;1,105,1000,4,0,1,0;1,105,1000,3,0,2,0;1,106,1400,3,0,3,0;1,109,830,4,0,4,0;1,109,830,4,0,5,0;1,109,830,4,0,6,0;1,109,1000,4,0,7,0;1,109,1000,4,0,8,0;2,113,0,3,0,9,10;2,113,815,3,0,9,0;2,113,830,4,0,10,0;2,113,830,4,0,11,0;2,113,830,4,0,12,0;2,113,830,4,0,13,0;2,113,1000,3,0,14,0;2,113,1400,3,0,3,0;2,114,0,3,0,15,7;2,114,0,3,0,16,7;2,114,830,4,0,15,0;2,114,830,4,0,16,0;2,114,830,4,0,17,0;2,114,830,4,0,18,0;2,115,830,4,0,19,0;2,115,830,3,0,20,0;2,115,830,3,0,21,0;3,119,0,1,0,0,1;3,120,0,3,1,22,3;3,120,1300,3,0,3,0;3,121,830,4,0,3,0;3,121,1000,3,0,23,0;3,121,1300,3,0,3,0;3,122,0,3,0,24,7;3,122,830,4,0,19,0;3,122,830,4,0,25,0;3,122,830,3,0,26,0;3,122,1000,4,0,24,0;3,123,0,3,1,22,5;3,123,945,4,0,27,0;3,123,945,4,0,28,0;3,123,1000,3,0,29,0;4,126,830,3,0,30,0;4,126,830,3,0,31,0;4,127,1000,3,0,32,0;4,127,1000,3,0,33,0;4,127,1600,3,0,3,0;4,128,1400,4,0,34,0;4,128,1400,4,0,35,0;4,128,1430,4,0,36,0;4,129,830,4,0,19,0;4,129,1600,3,0,37,0;4,129,1630,3,0,3,0;4,130,830,4,0,15,0;4,130,830,4,0,16,0;4,201,0,3,1,38,1;5,202,1000,4,0,1,0;5,202,1000,3,0,2,0;5,204,815,4,0,39,0;5,204,1000,4,0,40,0;5,204,1000,4,0,41,0;5,205,830,4,0,19,0;5,205,1900,3,0,3,0;5,206,1000,4,0,7,0;5,206,1000,4,0,8,0;6,210,830,4,0,17,0;6,210,830,4,0,18,0;6,210,830,3,0,42,0;6,211,830,4,0,4,0;6,211,830,4,0,5,0;6,211,830,4,0,6,0;6,212,830,4,0,19,0;6,213,830,4,0,10,0;6,213,830,4,0,11,0;6,213,830,4,0,12,0;6,213,830,4,0,13,0;7,216,0,1,0,0,1;7,217,830,3,0,20,0;7,218,830,3,0,30,0;7,218,830,3,0,31,0;7,218,1400,4,0,43,0;7,219,830,4,0,19,0;7,219,830,3,0,21,0;7,219,1000,3,0,23,0;7,219,1600,3,0,3,0;7,220,0,3,0,14,8;7,220,830,4,0,24,0;7,220,830,4,0,44,0;7,220,830,3,0,45,0;7,220,945,4,0,27,0;7,220,945,4,0,28,0;7,220,1000,3,0,14,0;7,220,1245,4,0,3,0;8,223,800,3,0,46,0;8,224,1000,3,0,32,0;8,224,1000,3,0,33,0;8,224,2100,4,0,3,0;8,226,830,4,0,19,0;8,227,830,4,0,15,0;8,227,830,4,0,16,0;9,302,1000,4,0,1,0;9,302,1000,3,0,2,0;9,302,1100,3,0,3,0;9,304,815,4,0,39,0;9,304,1000,4,0,40,0;9,305,830,4,0,19,0;9,306,730,3,0,46,0;9,306,830,4,0,4,0;9,306,830,4,0,5,0;9,306,830,4,0,6,0;9,306,830,4,0,17,0")
    f_loadPackedEvents(names, "9,306,830,4,0,18,0;9,308,300,1,0,47,0;10,309,1730,3,0,3,0;10,311,830,4,0,10,0;10,311,830,4,0,11,0;10,311,830,4,0,12,0;10,311,830,4,0,13,0;10,311,1625,3,0,3,0;10,312,830,4,0,19,0;10,313,830,4,0,24,0;10,313,830,3,0,30,0;10,313,830,3,0,31,0;10,313,830,4,0,48,0;10,313,830,3,0,49,0;10,313,1000,3,0,7,0;10,313,1000,3,0,8,0;10,313,1000,4,0,41,0;11,316,830,3,0,20,0;11,316,1130,3,0,3,0;11,317,1000,3,0,23,0;11,318,830,4,0,15,0;11,318,830,4,0,16,0;11,318,1400,4,0,34,0;11,318,1400,4,0,35,0;11,318,1400,4,0,50,0;11,318,1430,4,0,36,0;11,319,830,4,0,19,0;11,319,830,3,0,21,0;11,319,1000,3,0,14,0;11,321,1330,3,0,51,0;12,324,945,4,0,27,0;12,324,945,4,0,28,0;12,324,1000,3,0,33,0;12,325,1920,3,0,3,0;12,326,830,4,0,19,0;12,326,1600,3,0,3,0;12,327,1000,3,0,29,0;12,327,1730,3,0,3,0;13,330,1030,4,0,51,0;13,331,1000,3,0,32,0;13,331,1000,4,0,41,0;13,401,815,4,0,39,0;13,401,830,4,0,17,0;13,401,830,4,0,18,0;13,401,1000,4,0,1,0;13,401,1000,3,0,2,0;13,401,2100,4,0,3,0;13,402,830,4,0,19,0;13,403,830,4,0,4,0;13,403,830,4,0,5,0;13,403,830,4,0,6,0;13,405,0,4,1,38,1;14,406,1000,4,0,40,0;14,406,1300,4,0,3,0;14,407,830,3,0,30,0;14,407,830,3,0,31,0;14,408,1400,4,0,43,0;14,409,830,3,0,19,0;14,409,830,4,0,24,0;14,409,830,4,0,25,0;14,409,830,3,0,26,0;14,410,830,4,0,10,0;14,410,830,4,0,11,0;14,410,830,4,0,12,0;14,410,830,4,0,13,0;14,410,1000,3,0,7,0;14,410,1000,3,0,8,0;15,414,830,4,0,15,0;15,414,830,4,0,16,0;15,415,600,3,0,3,0;15,415,830,3,0,20,0;15,416,830,3,0,19,0;15,416,830,3,0,21,0;15,416,1900,3,0,3,0;15,417,1400,3,0,46,0;15,417,1700,3,0,3,0;16,421,830,3,0,3,0;16,421,830,4,0,17,0;16,421,830,4,0,18,0;16,421,1000,3,0,23,0;16,421,1000,4,0,52,0;16,423,830,3,0,19,0;16,423,945,3,0,27,0;16,423,945,3,0,28,0;16,424,1000,3,0,29,0;16,425,1200,3,0,3,0;16,425,2245,3,0,3,0;16,426,1900,3,0,3,0;17,428,1000,3,0,32,0;17,429,1400,4,0,34,0;17,429,1400,4,0,35,0;17,429,1430,4,0,36,0;17,430,830,3,0,19,0;17,430,830,4,0,24,0;17,430,830,4,0,42,0;17,430,830,4,0,44,0;17,430,830,3,0,45,0;17,501,1000,3,0,1,0;17,501,1000,3,0,2,0;17,501,1500,3,0,3,0;18,505,0,3,0,14,9;18,505,1000,3,0,14,0;18,505,1000,4,0,40,0;18,505,1000,4,0,41,0;18,506,815,3,0,39,0;18,507,830,3,0,19,0;18,508,830,4,0,4,0;18,508,830,4,0,5,0;18,508,830,4,0,6,0;18,508,1000,3,0,7,0")
    f_loadPackedEvents(names, "18,508,1000,3,0,8,0;18,508,1200,3,0,3,0;19,512,830,4,0,10,0;19,512,830,4,0,11,0;19,512,830,4,0,12,0;19,512,830,4,0,13,0;19,513,830,4,0,15,0;19,513,830,4,0,16,0;19,513,1440,4,0,53,0;19,514,830,4,0,17,0;19,514,830,4,0,18,0;19,514,830,3,0,19,0;20,519,1000,3,0,23,0;20,520,1400,4,0,43,0;20,521,830,3,0,19,0;20,521,830,3,0,21,0;20,521,945,3,0,27,0;20,521,945,3,0,28,0;20,522,1000,3,0,29,0;21,525,0,1,0,0,1;21,526,1000,3,0,32,0;21,528,830,3,0,19,0;21,528,830,4,0,24,0;21,528,830,4,0,48,0;21,528,830,3,0,49,0;21,528,1000,3,0,14,0;21,528,1400,3,0,54,0;21,531,2030,3,0,51,0;22,601,1000,4,0,1,0;22,601,1000,3,0,2,0;22,602,1000,3,0,41,0;22,603,815,4,0,39,0;22,603,1000,4,0,40,0;22,603,1000,3,0,54,0;22,604,830,3,0,19,0;22,604,1000,3,0,54,0;22,604,1500,3,0,3,0;22,605,830,4,0,4,0;22,605,830,4,0,5,0;22,605,830,4,0,6,0;22,607,0,3,1,38,1;22,607,0,3,1,55,1;23,610,830,4,0,10,0;23,610,830,4,0,11,0;23,610,830,4,0,12,0;23,610,830,4,0,13,0;23,611,830,4,0,15,0;23,611,830,4,0,16,0;23,611,830,3,0,19,0;23,612,1000,3,0,7,0;23,612,1000,3,0,8,0;24,617,830,3,0,17,0;24,617,830,3,0,18,0;24,617,1045,3,0,3,0;24,617,1400,4,0,34,0;24,617,1400,4,0,35,0;24,617,1400,4,0,50,0;24,617,1430,4,0,36,0;24,618,830,3,0,19,0;24,618,830,3,0,21,0;24,619,0,1,0,0,1;25,623,945,3,0,27,0;25,623,945,3,0,28,0;25,623,1405,3,0,3,0;25,624,2030,3,0,3,0;25,625,830,3,0,19,0;25,625,830,4,0,24,0;25,625,830,4,0,25,0;25,625,830,3,0,26,0;25,626,1000,3,0,29,0;25,626,1000,3,0,56,0;25,626,1330,3,0,3,0;26,630,1000,3,0,32,0;26,630,1000,3,0,41,0;26,701,815,3,0,39,0;26,701,900,4,0,57,0;26,701,1000,4,0,1,0;26,701,1000,3,0,2,0;26,701,1515,3,0,3,0;26,702,830,4,0,4,0;26,702,830,4,0,5,0;26,702,830,4,0,6,0;26,702,830,3,0,19,0;26,703,0,1,0,0,1;27,706,1000,4,0,40,0;27,708,1400,4,0,43,0;27,709,830,3,0,19,0;28,714,830,4,0,10,0;28,714,830,4,0,11,0;28,714,830,4,0,12,0;28,714,830,4,0,13,0;28,714,1000,4,0,52,0;28,715,830,4,0,15,0;28,715,830,4,0,16,0;28,715,1000,4,0,52,0;28,716,830,3,0,17,0;28,716,830,3,0,18,0;28,716,830,3,0,19,0;28,716,830,3,0,21,0;28,716,2100,3,0,3,0;28,717,1000,3,0,7,0;28,717,1000,3,0,8,0;29,722,1500,3,0,3,0;29,723,830,3,0,19,0;29,724,2055,3,0,3,0;30,727,1450,3,0,3,0;30,728,1000,3,0,32,0;30,729,1400,4,0,34,0;30,729,1400,4,0,35,0;30,729,1430,4,0,36,0")
    f_loadPackedEvents(names, "30,730,830,3,0,19,0;30,730,830,4,0,24,0;30,730,830,4,0,44,0;30,730,830,3,0,45,0;30,731,830,3,0,42,0;30,731,1000,3,0,29,0;30,731,1000,3,0,56,0;30,802,0,3,1,38,1;31,803,1000,4,0,1,0;31,803,1000,3,0,2,0;31,804,1000,3,0,41,0;31,805,815,3,0,39,0;31,805,1000,3,0,40,0;31,805,1630,3,0,3,0;31,806,830,3,0,19,0;31,807,830,4,0,4,0;31,807,830,4,0,5,0;31,807,830,4,0,6,0;32,812,830,4,0,10,0;32,812,830,4,0,11,0;32,812,830,4,0,12,0;32,812,830,4,0,13,0;32,813,830,4,0,15,0;32,813,830,4,0,16,0;32,813,830,3,0,19,0;32,814,830,3,0,17,0;32,814,830,3,0,18,0;32,814,1000,3,0,7,0;32,814,1000,3,0,8,0;32,814,1500,3,0,3,0;33,819,1400,4,0,43,0;33,819,1430,3,0,3,0;33,820,830,3,0,19,0;33,820,830,3,0,21,0;33,821,1900,3,0,3,0;34,824,1300,3,0,54,0;34,825,1000,3,0,32,0;34,826,830,4,0,24,0;34,826,830,4,0,48,0;34,826,830,3,0,49,0;34,827,0,3,1,58,2;34,827,830,3,0,19,0;34,828,0,4,1,58,3;34,828,1000,3,0,29,0;34,828,1000,3,0,56,0;34,828,1000,4,0,57,0;34,828,1000,4,0,59,0;34,829,0,3,1,58,4;35,901,1000,4,0,1,0;35,901,1000,3,0,2,0;35,901,1000,3,0,41,0;35,902,815,3,0,39,0;35,903,830,3,0,19,0;35,903,1000,3,0,40,0;35,904,830,4,0,4,0;35,904,830,4,0,5,0;35,904,830,4,0,6,0;36,907,0,1,0,0,1;36,909,2115,3,0,3,0;36,910,830,4,0,15,0;36,910,830,4,0,16,0;36,910,830,3,0,19,0;36,911,830,4,0,10,0;36,911,830,4,0,11,0;36,911,830,4,0,12,0;36,911,830,4,0,13,0;36,911,1000,3,0,7,0;36,911,1000,3,0,8,0;37,915,1000,3,0,54,0;37,916,830,3,0,17,0;37,916,830,3,0,18,0;37,916,1400,4,0,34,0;37,916,1400,4,0,35,0;37,916,1400,4,0,50,0;37,916,1430,4,0,36,0;37,917,830,3,0,19,0;37,917,830,3,0,21,0;38,922,955,3,0,3,0;38,924,830,3,0,19,0;38,924,1015,3,0,3,0;38,924,1955,3,0,3,0;38,925,1000,3,0,29,0;38,925,1000,3,0,56,0;39,929,1000,3,0,32,0;39,929,1000,3,0,41,0;39,930,815,3,0,39,0;39,930,830,4,0,24,0;39,930,830,4,0,25,0;39,930,830,3,0,26,0;39,930,1530,3,0,3,0;39,930,1800,3,0,61,0;39,1001,830,3,0,19,0;39,1001,1000,3,0,1,0;39,1001,1000,3,0,46,0;39,1002,830,4,0,4,0;39,1002,830,4,0,5,0;39,1002,830,4,0,6,0;39,1004,0,3,1,38,1;40,1005,1000,3,0,40,0;40,1007,1300,3,0,3,0;40,1007,1400,4,0,43,0;40,1008,830,3,0,19,0;40,1009,1000,3,0,7,0;40,1009,1000,3,0,8,0;41,1012,0,1,0,0,1;41,1014,830,4,0,10,0;41,1014,830,4,0,11,0;41,1014,830,4,0,12,0;41,1014,830,4,0,13,0;41,1015,830,4,0,15,0")
    f_loadPackedEvents(names, "41,1015,830,4,0,16,0;41,1015,830,4,0,17,0;41,1015,830,4,0,18,0;41,1015,830,3,0,19,0;41,1015,830,3,0,21,0;41,1015,2330,4,0,57,0;42,1020,1000,3,0,23,0;42,1022,830,3,0,19,0;42,1023,0,3,0,37,6;42,1023,945,3,0,27,0;42,1023,945,3,0,28,0;42,1023,1000,3,0,29,0;42,1023,1000,3,0,56,0;43,1027,1000,3,0,32,0;43,1028,1400,4,0,34,0;43,1028,1400,4,0,35,0;43,1028,1430,4,0,36,0;43,1029,830,3,0,19,0;43,1029,830,4,0,24,0;43,1029,830,4,0,44,0;43,1029,830,3,0,45,0;43,1030,830,3,0,42,0;43,1101,200,1,0,47,0;44,1102,1000,3,0,1,0;44,1103,0,4,0,60,1;44,1103,1000,3,0,41,0;44,1104,815,3,0,39,0;44,1104,1000,3,0,40,0;44,1105,830,3,0,19,0;44,1106,830,4,0,4,0;44,1106,830,4,0,5,0;44,1106,830,4,0,6,0;44,1106,1000,3,0,7,0;44,1106,1000,3,0,8,0;45,1110,830,4,0,10,0;45,1110,830,4,0,11,0;45,1110,830,4,0,12,0;45,1110,830,4,0,13,0;45,1111,0,1,0,0,1;45,1112,830,3,0,19,0;45,1113,830,4,0,15,0;45,1113,830,4,0,16,0;46,1117,830,4,0,17,0;46,1117,830,4,0,18,0;46,1118,1400,4,0,43,0;46,1119,830,3,0,19,0;46,1119,830,3,0,21,0;46,1120,1000,3,0,29,0;46,1120,1000,3,0,56,0;47,1124,1000,3,0,32,0;47,1125,830,3,0,19,0;47,1125,830,4,0,24,0;47,1125,830,4,0,48,0;47,1125,830,3,0,49,0;47,1126,0,1,0,0,1;47,1129,0,3,1,38,1;47,1129,0,3,1,55,1;48,1201,1000,3,0,1,0;48,1201,1000,3,0,41,0;48,1202,815,3,0,39,0;48,1203,830,3,0,19,0;48,1203,1000,3,0,40,0;48,1204,830,4,0,4,0;48,1204,830,4,0,5,0;48,1204,830,4,0,6,0;48,1204,1000,3,0,7,0;48,1204,1000,3,0,8,0;49,1209,1400,4,0,34,0;49,1209,1400,4,0,35,0;49,1209,1400,4,0,50,0;49,1209,1430,4,0,36,0;49,1210,830,4,0,10,0;49,1210,830,4,0,11,0;49,1210,830,4,0,12,0;49,1210,830,4,0,13,0;49,1210,830,3,0,19,0;50,1215,830,4,0,15,0;50,1215,830,4,0,16,0;50,1216,830,4,0,17,0;50,1216,830,4,0,18,0;50,1217,830,3,0,19,0;50,1217,830,3,0,21,0;50,1218,1000,3,0,29,0;50,1218,1000,3,0,56,0;51,1222,1000,3,0,32,0;51,1223,830,4,0,24,0;51,1223,830,4,0,25,0;51,1223,830,3,0,26,0;51,1224,830,3,0,19,0;51,1225,0,1,0,0,1;52,1230,1400,4,0,43,0;52,1231,830,3,0,19,0")

// ============================================================================

// 04. INITIALIZE

// ============================================================================

if barstate.isfirst

    f_initializeCalendar()

// ============================================================================

// 05. DATE / WEEK HELPERS

// ============================================================================

f_calendarDay(int mondayTs, int dayOffset) =>
    timestamp(TZ, year(mondayTs, TZ), month(mondayTs, TZ), dayofmonth(mondayTs, TZ) + dayOffset, 0, 0)

f_weekIndexAt(int anchorTs) =>

    int selectedIndex = -1

    int count = array.size(weekStarts)

    if count > 0

        for i = 0 to count - 1

            int mondayStart = array.get(weekStarts, i)

            int sundayActivation = f_calendarDay(mondayStart, -1)

            if anchorTs >= sundayActivation

                selectedIndex := i

    selectedIndex

f_sameDay(int tsA, int tsB) =>

    str.format_time(tsA, "yyyyMMdd", TZ) == str.format_time(tsB, "yyyyMMdd", TZ)

f_countEnabledDayEvents(int dayTs) =>

    int matched = 0

    int count = array.size(evTs)

    if count > 0

        for i = 0 to count - 1

            if f_eventEnabled(i) and f_sameDay(array.get(evTs, i), dayTs)

                matched += 1

    matched

f_countWeekRows(int selectedWeek) =>

    int rowsNeeded = 0

    for dayOffset = 0 to 6

        int dayTs = f_calendarDay(selectedWeek, dayOffset)

        int dayCount = f_countEnabledDayEvents(dayTs)

        rowsNeeded += dayCount > 0 ? dayCount : 1

    rowsNeeded

// Highest *enabled* folder impact on this NY date; 4=RED, 3=ORANGE, 1=GRAY.
// Reuses the exact event filter used by the table and alerts.
f_highestDayImpact(int anchorTs) =>
    int strongest = 0
    int count = array.size(evTs)
    if count > 0
        for i = 0 to count - 1
            if f_eventEnabled(i) and f_sameDay(array.get(evTs, i), anchorTs)
                strongest := math.max(strongest, array.get(evImpact, i))
    strongest

f_dayImpactLabel(int impact) =>
    impact == 4 ? "RED DAY" :
     impact == 3 ? "ORANGE DAY" :
     impact == 1 ? "GRAY DAY" : ""

f_hasEnabledToday(int anchorTs) =>

    bool found = false

    int count = array.size(evTs)

    if count > 0

        for i = 0 to count - 1

            if f_eventEnabled(i) and f_sameDay(array.get(evTs, i), anchorTs)

                found := true

    found

f_hasRedToday(int anchorTs) =>
    f_highestDayImpact(anchorTs) == 4

f_hasHolidayToday(int anchorTs) =>

    bool found = false

    int count = array.size(evTs)

    if count > 0

        for i = 0 to count - 1

            if array.get(evImpact, i) == 1 and showHoliday and f_currencyEnabled(array.get(evCurrency, i)) and f_sameDay(array.get(evTs, i), anchorTs)

                found := true

    found

f_hasFomcStatementToday(int anchorTs) =>

    bool found = false

    int count = array.size(evTs)

    if count > 0

        for i = 0 to count - 1

            int ts = array.get(evTs, i)

            string eventName = array.get(evName, i)

            if array.get(evImpact, i) == 4 and showHigh and f_currencyEnabled(array.get(evCurrency, i)) and f_sameDay(ts, anchorTs) and str.contains(eventName, "FOMC Statement")

                found := true

    found

// ============================================================================

// 06. WEEKLY TABLE

// ============================================================================

f_renderWeek(table target, int selectedWeek, string titleText) =>

    color titleBg = color.new(color.rgb(30, 45, 65), 12)

    color headerBg = color.new(color.rgb(70, 82, 102), 12)

    color noNewsBg = color.new(color.gray, 90)

    string bodySize = f_textSize(tableTextSize)

    string titleSize = f_titleTextSize(tableTextSize)

    table.cell(target, 0, 0, titleText, bgcolor = titleBg, text_color = color.white, text_size = titleSize)

    table.cell(target, 1, 0, "Week of " + str.format_time(selectedWeek, "MMM dd", TZ), bgcolor = titleBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 2, 0, (includeGlobalEvents ? "USD + All" : "USD Only"), bgcolor = titleBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 3, 0, "America/New_York", bgcolor = titleBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 4, 0, (selectedWeek >= timestamp(TZ, 2026, 9, 28, 0, 0) and selectedWeek <= timestamp(TZ, 2026, 10, 12, 0, 0) ? "Spot-checked" : "2026 archive"), bgcolor = titleBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 0, 1, "Day / Date", bgcolor = headerBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 1, 1, "Time ET", bgcolor = headerBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 2, 1, "Currency", bgcolor = headerBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 3, 1, "News / Calendar Event", bgcolor = headerBg, text_color = color.white, text_size = bodySize)

    table.cell(target, 4, 1, "Impact", bgcolor = headerBg, text_color = color.white, text_size = bodySize)

    int row = 2

    int count = array.size(evTs)

    for dayOffset = 0 to 6

        int dayTs = f_calendarDay(selectedWeek, dayOffset)

        int dayMatched = 0
        int dayImpact = f_highestDayImpact(dayTs)

        if count > 0

            for i = 0 to count - 1

                int impact = array.get(evImpact, i)

                int ts = array.get(evTs, i)

                if f_eventEnabled(i) and f_sameDay(ts, dayTs)

                    int fixedCode = array.get(evFixed, i)

                    string timeText = fixedCode == 0 ? str.format_time(ts, "hh:mm a", TZ) : f_fixedText(fixedCode)

                    string currencyText = array.get(evCurrency, i) == 0 ? "USD" : "All"

                    string dayText = dayMatched == 0 ? str.format_time(dayTs, "EEE MMM dd", TZ) + "\n" + f_dayImpactLabel(dayImpact) : ""

                    color rowBg = f_impactBg(impact)
                    color dayBg = dayMatched == 0 ? f_impactBg(dayImpact) : rowBg

                    table.cell(target, 0, row, dayText, bgcolor = dayBg, text_color = color.white, text_size = bodySize)

                    table.cell(target, 1, row, timeText, bgcolor = rowBg, text_color = color.white, text_size = bodySize)

                    table.cell(target, 2, row, currencyText, bgcolor = rowBg, text_color = color.white, text_size = bodySize)

                    table.cell(target, 3, row, array.get(evName, i), bgcolor = rowBg, text_color = color.white, text_size = bodySize)

                    table.cell(target, 4, row, f_impactText(impact), bgcolor = rowBg, text_color = color.white, text_size = bodySize)

                    row += 1

                    dayMatched += 1

        if dayMatched == 0

            table.cell(target, 0, row, str.format_time(dayTs, "EEE MMM dd", TZ), bgcolor = noNewsBg, text_color = color.silver, text_size = bodySize)

            table.cell(target, 1, row, "", bgcolor = noNewsBg)

            table.cell(target, 2, row, "", bgcolor = noNewsBg)

            table.cell(target, 3, row, "No significant news", bgcolor = noNewsBg, text_color = color.silver, text_size = bodySize)

            table.cell(target, 4, row, "", bgcolor = noNewsBg)

            row += 1

// ============================================================================

// 07. DAY-OF ALERT STATE

// ============================================================================

string nyDateKey = str.format_time(time, "yyyyMMdd", TZ)

bool newNyDay = bar_index == 0 or nyDateKey != nyDateKey[1]

var bool todayHasSignificant = false

var bool todayHasRed = false

var bool todayHasHoliday = false

var bool todayHasFomc = false

if barstate.isfirst or newNyDay

    todayHasSignificant := f_hasEnabledToday(time)

    todayHasRed := f_hasRedToday(time)

    todayHasHoliday := f_hasHolidayToday(time)

    todayHasFomc := f_hasFomcStatementToday(time)

alertcondition(

     newNyDay and todayHasSignificant,

     "Significant News Today",

     "SIGNIFICANT NEWS TODAY - RED, ORANGE, or GRAY calendar event(s) are scheduled today."

)

alertcondition(

     newNyDay and todayHasRed,

     "RED Folder News Today",

     "RED FOLDER NEWS TODAY - High-impact calendar event(s) are scheduled today."

)

alertcondition(

     newNyDay and todayHasHoliday,

     "GRAY Holiday / Schedule Today",

     "GRAY CALENDAR EVENT TODAY - Holiday or market-schedule event is listed today."

)

alertcondition(

     newNyDay and todayHasFomc,

     "FOMC Statement Today",

     "FOMC DAY - An FOMC Statement is scheduled today."

)

var string lastDayAlertKey = ""

if barstate.isrealtime and dayAlertMode != "Off"

    bool dayEligible =

         dayAlertMode == "FOMC Days Only" ? todayHasFomc :

         dayAlertMode == "RED Days Only" ? todayHasRed :

         todayHasSignificant

    if dayEligible and lastDayAlertKey != nyDateKey

        string dayMessage =

             todayHasFomc ?

             "FOMC DAY - An FOMC Statement is scheduled today. Check the Economic News table for the exact ET release time." :

             todayHasHoliday and not todayHasRed ?

             "SIGNIFICANT CALENDAR DAY - A holiday/schedule event is listed today. Check the Economic News table." :

             "SIGNIFICANT NEWS TODAY - Check the Economic News table for today's RED / ORANGE / GRAY calendar events."

        alert(dayMessage, alert.freq_once_per_bar)

        lastDayAlertKey := nyDateKey

// ============================================================================

// 08. EXACT RELEASE-TIME ALERTS

// ============================================================================

var int lastEventAlertTs = na

if barstate.isrealtime and eventTimeAlerts

    int dueTs = na

    int dueImpact = 0

    string dueNames = ""

    int count = array.size(evTs)

    if count > 0

        for i = 0 to count - 1

            int impact = array.get(evImpact, i)

            int fixedCode = array.get(evFixed, i)

            int ts = array.get(evTs, i)

            if f_eventEnabled(i) and fixedCode == 0 and timenow >= ts and timenow < ts + ALERT_WINDOW_MS

                if na(dueTs)

                    dueTs := ts

                    dueImpact := impact

                if ts == dueTs

                    string eventName = array.get(evName, i)

                    dueNames := str.length(dueNames) == 0 ? eventName : dueNames + " + " + eventName

                    dueImpact := math.max(dueImpact, impact)

    if not na(dueTs) and (na(lastEventAlertTs) or dueTs != lastEventAlertTs)

        alert(

             f_impactAlertText(dueImpact) + " NEWS NOW - " + dueNames + " - " + str.format_time(dueTs, "hh:mm a", TZ) + " ET",

             alert.freq_once_per_bar

        )

        lastEventAlertTs := dueTs

// ============================================================================

// 09. REPLAY-SAFE WEEKLY TABLE

// ============================================================================

var table newsTable = na

if barstate.islast

    int replayAnchor = time

    int thisWeekIndex = f_weekIndexAt(replayAnchor)

    int selectedIndex = weekChoice == "Next Week" ? thisWeekIndex + 1 : thisWeekIndex

    int lastIndex = array.size(weekStarts) - 1

    string tableTitle =

         weekChoice == "Next Week" ?

         "Next Week Economic News" :

         "This Week Economic News"

    if not na(newsTable)

        table.delete(newsTable)

    if selectedIndex >= 0 and selectedIndex <= lastIndex

        int selectedWeek = array.get(weekStarts, selectedIndex)

        int requiredRows = f_countWeekRows(selectedWeek) + 2

        newsTable := table.new(

             f_tablePosition(tableLocation),

             5,

             requiredRows,

             frame_color = color.new(color.silver, 70),

             frame_width = 1,

             border_color = color.new(color.silver, 85),

             border_width = 1

        )

        f_renderWeek(newsTable, selectedWeek, tableTitle)

    else

        newsTable := table.new(

             f_tablePosition(tableLocation),

             5,

             1,

             frame_color = color.new(color.silver, 70),

             frame_width = 1,

             border_color = color.new(color.silver, 85),

             border_width = 1

        )

        table.cell(

             newsTable,

             0,

             0,

             "No 2026 calendar week available",

             bgcolor = color.new(color.gray, 80),

             text_color = color.white,

             text_size = f_textSize(tableTextSize)

        )
````
