# BFG Level3d

- url: https://www.tradingview.com/script/u3UlkEda-BFG-Level3d/
- type: indicator
- pine_id: PUB;1d1b97e586c24ee18af717968f660689
- version: 9.0

## Description

Level3d is a BFG key-level mapping tool designed to keep the most important market structure levels visible on the chart in one clean view. It plots major daily, weekly, monthly, quarterly, yearly, 4-hour, Monday range, and session-based levels, including Overnight, Early, Core, and Late session ranges. These levels help traders identify likely reaction zones, liquidity areas, support, resistance, session bias, and important price magnets.

What makes Level3d stronger than a standard key-level indicator is its organized multi-timeframe structure, automatic market detection, customizable session templates, timezone-aware range tracking, clean label merging, shorthand options, and active mode display. Instead of cluttering the chart with disconnected levels, Level3d brings the full market map together in a readable, adaptive format built for real trading decisions.

The last Key Levels indicator you will ever need.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © barefootgreenback
// Version 6.0 — Standardized market-session labels on Market Names and removed Session Names mode. Thank you.
//@version=6
//@sbtnc thank you for doing the base code
//@SpacemanBTC thank you for the hard work
indicator(title="BFG Level3d", shorttitle = "Level3d", overlay = true, max_lines_count = 200, max_labels_count = 200, explicit_plot_zorder = true)
//════════════════════════════════════════════════════════════════════
// INPUT GROUPS
//════════════════════════════════════════════════════════════════════
string GRP_LABELS   = "Labels"
string GRP_LINES    = "Lines"
string GRP_SESSIONS = "Market Sessions"
//════════════════════════════════════════════════════════════════════
// CONSTANTS
//════════════════════════════════════════════════════════════════════
const int LEVEL_COUNT = 52
//════════════════════════════════════════════════════════════════════
// SYMBOL / MARKET DETECTION
//════════════════════════════════════════════════════════════════════
symbolRoot   = str.upper(syminfo.root)
symbolTicker = str.upper(syminfo.ticker)
symbolDesc   = str.upper(syminfo.description)
isStockSymbol  = syminfo.type == "stock"
isCryptoSymbol = syminfo.type == "crypto"
isFuturesSymbol = syminfo.type == "futures"
// Futures and commodity symbols can report differently across TradingView feeds.
// This keeps Level3d aligned with the ORZon3d market-detection style.
isDerivativeLike = not isStockSymbol and not isCryptoSymbol
isNQSymbol  = isDerivativeLike and (str.contains(symbolRoot, "NQ") or str.contains(symbolTicker, "NQ"))
isESSymbol  = isDerivativeLike and (str.contains(symbolRoot, "ES") or str.contains(symbolTicker, "ES"))
isYMSymbol  = isDerivativeLike and (str.contains(symbolRoot, "YM") or str.contains(symbolTicker, "YM"))
isRTYSymbol = isDerivativeLike and (str.contains(symbolRoot, "RTY") or str.contains(symbolTicker, "RTY") or str.contains(symbolRoot, "M2K") or str.contains(symbolTicker, "M2K"))
isGCSymbol  = isDerivativeLike and (str.contains(symbolRoot, "GC") or str.contains(symbolTicker, "GC") or str.contains(symbolRoot, "MGC") or str.contains(symbolTicker, "MGC"))
isSISymbol  = isDerivativeLike and (str.contains(symbolRoot, "SI") or str.contains(symbolTicker, "SI") or str.contains(symbolRoot, "SIL") or str.contains(symbolTicker, "SIL"))
isCLSymbol  = isDerivativeLike and (str.contains(symbolRoot, "CL") or str.contains(symbolTicker, "CL") or str.contains(symbolRoot, "MCL") or str.contains(symbolTicker, "MCL"))
isNGSymbol  = isDerivativeLike and (str.contains(symbolRoot, "NG") or str.contains(symbolTicker, "NG"))
isRBSymbol  = isDerivativeLike and (str.contains(symbolRoot, "RB") or str.contains(symbolTicker, "RB"))
isHOSymbol  = isDerivativeLike and (str.contains(symbolRoot, "HO") or str.contains(symbolTicker, "HO"))
isHGSymbol  = isDerivativeLike and (str.contains(symbolRoot, "HG") or str.contains(symbolTicker, "HG"))
isBTCAny = str.contains(symbolRoot, "BTC") or str.contains(symbolTicker, "BTC") or str.contains(symbolRoot, "XBT") or str.contains(symbolTicker, "XBT") or str.contains(symbolRoot, "MBT") or str.contains(symbolTicker, "MBT") or str.contains(symbolDesc, "BITCOIN")
isETHAny = str.contains(symbolRoot, "ETH") or str.contains(symbolTicker, "ETH") or str.contains(symbolRoot, "MET") or str.contains(symbolTicker, "MET") or str.contains(symbolDesc, "ETHEREUM")
isCmeCryptoFutures = isFuturesSymbol and (isBTCAny or isETHAny)
//════════════════════════════════════════════════════════════════════
// USER INPUTS - LINES AND LABELS
//════════════════════════════════════════════════════════════════════
extendLinesRightBars = input.int(defval = 8, title = "Extend Lines Right (Bars)", minval = 0, maxval = 500, group = GRP_LINES)
labelSizeInput = input.string(
     defval = "Normal",
     title = "Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GRP_LABELS
)
string TT_LABEL_MERGE_TOLERANCE = "Number of ticks used to combine labels that are close together. Exact matches always merge. Minimum 1 tick keeps labels readable when levels land on the same price or within one valid market tick."
labelMergeToleranceTicks = input.int(
     defval = 4,
     title = "Label Merge Tolerance (Ticks)",
     minval = 1,
     maxval = 50,
     tooltip = TT_LABEL_MERGE_TOLERANCE,
     group = GRP_LABELS
)
string TT_GLOBAL_TEXT_SHORTHAND = "Enable shorthand labels for all levels. Long labels also automatically fall back to shorthand when they exceed the extension distance."
globalTextShorthand = input.bool(
     defval = false,
     title = "Global Text ShortHand",
     tooltip = TT_GLOBAL_TEXT_SHORTHAND,
     group = GRP_LABELS
)
//════════════════════════════════════════════════════════════════════
// USER INPUTS - MARKET SESSIONS
//════════════════════════════════════════════════════════════════════
string TT_FAMILY_LINE_WIDTH = "Sets the line width for every plotted level in this family."
string TT_SESSION_TEMPLATE_MODE = "Selects the market-session template used for Overnight, Asia Composite, London, Core, Late, and Globex timing. Tokyo and Hong Kong presets use their native market timezones. Auto Detect follows symbol detection. Custom uses the Custom Session Timezone and all custom ranges below."
sessionTemplateMode = input.string(
     defval = "Auto Detect",
     title = "Session Template Mode",
     options = ["Auto Detect", "US Futures", "US Equities", "Global FX", "Metals", "Energy", "Crypto", "Custom"],
     tooltip = TT_SESSION_TEMPLATE_MODE,
     group = GRP_SESSIONS
)
customSessionTZ = input.string(
     defval = "America/New_York",
     title = "Custom Session Timezone",
     options = ["America/New_York", "Etc/UTC", "America/Chicago", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Singapore", "Australia/Sydney"],
     group = GRP_SESSIONS
)
string TT_SESSION_INPUTS = "Custom ranges are used only when Session Template Mode is Custom. Every custom session is interpreted in the selected Custom Session Timezone. Preset Tokyo and Hong Kong ranges use their native local timezones and exclude their midday cash-market breaks. Custom ranges are tracked continuously as entered."
string TT_ASIA_COMPOSITE = "Tracks the broader legacy Asia/overnight range as one optional composite. It is off by default because Tokyo and Hong Kong are now shown separately."
string TT_GLOBEX_ANCHORS = "Plots the true Globex trading-day Open and Close. Globex is a futures trading framework, not a geographic market session, so these labels remain Globex."
string TT_OVERNIGHT_RANGE = "Tracks the US index-futures pre-RTH auction from the Globex open through the 09:30 New York cash open. The completed High and Low become fixed RTH reference levels."
is_overnightrange_enabled = input.bool(defval = true, title = "Overnight", group = GRP_SESSIONS, inline = "Overnight")
OvernightColor = input.color(title = "Color", defval = color.rgb(0, 188, 212), group = GRP_SESSIONS, inline = "Overnight")
OvernightWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "Overnight")
OvernightStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "Overnight")
Overnightt = input.session("1800-0930", "Overnight Range", group = GRP_SESSIONS, tooltip = TT_OVERNIGHT_RANGE)
is_tokyorange_enabled = input.bool(defval = true, title = "Tokyo", group = GRP_SESSIONS, inline = "Tokyo")
TokyoColor            = input.color(title = "Color", defval = color.rgb(255, 234, 0), group = GRP_SESSIONS, inline = "Tokyo")
TokyoWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "Tokyo")
TokyoStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "Tokyo")
Tokyot                = input.session("2000-0230", "Tokyo Open-Close", group = GRP_SESSIONS, tooltip = TT_SESSION_INPUTS)
is_hongkongrange_enabled = input.bool(defval = true, title = "Hong Kong", group = GRP_SESSIONS, inline = "HongKong")
HongKongColor            = input.color(title = "Color", defval = color.rgb(255, 152, 0), group = GRP_SESSIONS, inline = "HongKong")
HongKongWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "HongKong")
HongKongStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "HongKong")
HongKongt                = input.session("2130-0400", "Hong Kong Open-Close", group = GRP_SESSIONS, tooltip = TT_SESSION_INPUTS)
is_asiacompositerange_enabled = input.bool(defval = false, title = "Asia Comp", group = GRP_SESSIONS, inline = "AsiaComposite")
AsiaCompositeColor            = input.color(title = "Color", defval = color.rgb(0, 150, 136), group = GRP_SESSIONS, inline = "AsiaComposite")
AsiaCompositeWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "AsiaComposite")
AsiaCompositeStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "AsiaComposite")
AsiaCompositet                = input.session("1800-0400", "Asia Composite Open-Close", group = GRP_SESSIONS, tooltip = TT_ASIA_COMPOSITE)
is_londonrange_enabled = input.bool(defval = true, title = "London", group = GRP_SESSIONS, inline = "London")
LondonColor            = input.color(title = "Color", defval = color.rgb(255, 82, 82), group = GRP_SESSIONS, inline = "London")
LondonWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "London")
LondonStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "London")
Londont                = input.session("0400-0930", "London Open-Close", group = GRP_SESSIONS, tooltip = TT_SESSION_INPUTS)
is_usrange_enabled = input.bool(defval = true, title = "New York", group = GRP_SESSIONS, inline = "Core")
USColor            = input.color(title = "Color", defval = color.rgb(68, 138, 255), group = GRP_SESSIONS, inline = "Core")
USWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "Core")
USStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "Core")
USt                = input.session("0930-1600", "New York Open-Close", group = GRP_SESSIONS, tooltip = TT_SESSION_INPUTS)
is_laterange_enabled = input.bool(defval = false, title = "After-Hours", group = GRP_SESSIONS, inline = "Late")
LateColor            = input.color(title = "Color", defval = color.rgb(255, 128, 0), group = GRP_SESSIONS, inline = "Late")
LateWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "Late")
LateStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "Late")
Latet                = input.session("1600-1700", "After-Hours Open-Close", group = GRP_SESSIONS, tooltip = TT_SESSION_INPUTS)
is_globexanchors_enabled = input.bool(defval = true, title = "Globex", group = GRP_SESSIONS, inline = "Globex")
GlobexColor             = input.color(title = "Color", defval = color.rgb(96, 125, 139), group = GRP_SESSIONS, inline = "Globex")
GlobexWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = GRP_SESSIONS, inline = "Globex")
GlobexStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESSIONS, inline = "Globex")
Globext                 = input.session("1800-1700", "Globex Open-Close", group = GRP_SESSIONS, tooltip = TT_GLOBEX_ANCHORS)
//════════════════════════════════════════════════════════════════════
// USER INPUTS - LEVEL FAMILIES
//════════════════════════════════════════════════════════════════════
// Timeframe groups use a dedicated Range Color row.
// Component labels remain full-length to match the chart text language.
IntraColor            = input.color(title = "Range Color", defval = color.rgb(156, 39, 176), group = "4hr", inline = "4hrColor")
IntraWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "4hr", inline = "4hrColor")
IntraStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "4hr", inline = "4hrColor")
is_intra_enabled      = input.bool(defval = true, title = "Open        ", group = "4hr", inline = "4hrLevels")
is_intrarange_enabled = input.bool(defval = true, title = "Prev H/L    ", group = "4hr", inline = "4hrLevels")
is_intram_enabled     = input.bool(defval = true, title = "Prev Mid", group = "4hr", inline = "4hrLevels")
DailyColor = input.color(title = "Daily Color", defval = color.rgb(103, 58, 183), group = "Daily / Prior Day", inline = "DailyColor")
DailyWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Daily / Prior Day", inline = "DailyColor")
DailyStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Daily / Prior Day", inline = "DailyColor")
is_daily_enabled = input.bool(defval = true, title = "Daily Open", group = "Daily / Prior Day", inline = "DailyLevels")
PriorDayColor = input.color(title = "Prior Color", defval = color.rgb(103, 58, 183), group = "Daily / Prior Day", inline = "PriorDayColor")
PriorDayWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Daily / Prior Day", inline = "PriorDayColor")
PriorDayStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Daily / Prior Day", inline = "PriorDayColor")
is_priordayrange_enabled = input.bool(defval = true, title = "Prior H/L    ", group = "Daily / Prior Day", inline = "PriorDayLevels")
is_priordaymid_enabled = input.bool(defval = true, title = "Prior Mid", group = "Daily / Prior Day", inline = "PriorDayLevels")
MondayColor       = input.color(title = "Range Color", defval = color.rgb(255, 152, 0), group = "Monday Range", inline = "MondayColor")
MondayWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Monday Range", inline = "MondayColor")
MondayStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Monday Range", inline = "MondayColor")
is_monday_enabled = input.bool(defval = true, title = "High/Low ", group = "Monday Range", inline = "MondayLevels")
is_monday_mid     = input.bool(defval = true, title = "Mid", group = "Monday Range", inline = "MondayLevels")
WeeklyColor            = input.color(title = "Range Color", defval = color.rgb(0, 188, 212), group = "Weekly", inline = "WeeklyColor")
WeeklyWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Weekly", inline = "WeeklyColor")
WeeklyStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Weekly", inline = "WeeklyColor")
is_weekly_enabled      = input.bool(defval = true, title = "Open        ", group = "Weekly", inline = "WeeklyLevels")
is_weeklyrange_enabled = input.bool(defval = true, title = "Prev H/L    ", group = "Weekly", inline = "WeeklyLevels")
is_weekly_mid          = input.bool(defval = true, title = "Prev Mid", group = "Weekly", inline = "WeeklyLevels")
MonthlyColor            = input.color(title = "Range Color", defval = color.rgb(0, 150, 136), group = "Monthly", inline = "MonthlyColor")
MonthlyWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Monthly", inline = "MonthlyColor")
MonthlyStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Monthly", inline = "MonthlyColor")
is_monthly_enabled      = input.bool(defval = true, title = "Open        ", group = "Monthly", inline = "MonthlyLevels")
is_monthlyrange_enabled = input.bool(defval = true, title = "Prev H/L    ", group = "Monthly", inline = "MonthlyLevels")
is_monthly_mid          = input.bool(defval = true, title = "Prev Mid", group = "Monthly", inline = "MonthlyLevels")
QuarterlyColor            = input.color(title = "Range Color", defval = color.rgb(139, 195, 74), group = "Quarterly", inline = "QuarterlyColor")
QuarterlyWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Quarterly", inline = "QuarterlyColor")
QuarterlyStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Quarterly", inline = "QuarterlyColor")
is_quarterly_enabled      = input.bool(defval = true, title = "Open        ", group = "Quarterly", inline = "QuarterlyLevels")
is_quarterlyrange_enabled = input.bool(defval = true, title = "Prev H/L    ", group = "Quarterly", inline = "QuarterlyLevels")
is_quarterly_mid          = input.bool(defval = true, title = "Prev Mid", group = "Quarterly", inline = "QuarterlyLevels")
YearlyColor            = input.color(title = "Range Color", defval = color.rgb(76, 175, 80), group = "Yearly", inline = "YearlyColor")
YearlyWidth = input.int(defval = 1, title = "Width", minval = 1, maxval = 10, tooltip = TT_FAMILY_LINE_WIDTH, group = "Yearly", inline = "YearlyColor")
YearlyStyleInput = input.string(defval = "Solid", title = "Style", options = ["Solid", "Dashed", "Dotted"], group = "Yearly", inline = "YearlyColor")
is_yearly_enabled      = input.bool(defval = true, title = "Open        ", group = "Yearly", inline = "YearlyLevels")
is_yearlyrange_enabled = input.bool(defval = true, title = "Current H/L ", group = "Yearly", inline = "YearlyLevels")
is_yearly_mid          = input.bool(defval = true, title = "Mid", group = "Yearly", inline = "YearlyLevels")
//════════════════════════════════════════════════════════════════════
// TEXT HELPERS
//════════════════════════════════════════════════════════════════════
useShort(string shortTxt, string longTxt) =>
    globalTextShorthand ? shortTxt : longTxt
//════════════════════════════════════════════════════════════════════
// TEXT DEFINITIONS
//════════════════════════════════════════════════════════════════════
pdhtext = useShort("PDH", "Prev Day High")
pdltext = useShort("PDL", "Prev Day Low")
dotext  = useShort("DO", "Daily Open")
pdmtext = useShort("PDM", "Prev Day Mid")
pwhtext = useShort("PWH", "Prev Week High")
pwltext = useShort("PWL", "Prev Week Low")
wotext  = useShort("WO", "Weekly Open")
pwmtext = useShort("PWM", "Prev Week Mid")
pmhtext = useShort("PMH", "Prev Month High")
pmltext = useShort("PML", "Prev Month Low")
motext  = useShort("MO", "Monthly Open")
pmmtext = useShort("PMM", "Prev Month Mid")
pqhtext = useShort("PQH", "Prev Quarter High")
pqltext = useShort("PQL", "Prev Quarter Low")
qotext  = useShort("QO", "Quarterly Open")
pqmtext = useShort("PQM", "Prev Quarter Mid")
cyhtext = useShort("CYrH", "Current Year High")
cyltext = useShort("CYrL", "Current Year Low")
yotext  = useShort("YrO", "Yearly Open")
cymtext = useShort("CYrM", "Current Year Mid")
pihtext = useShort("P4hrH", "Prev 4hr High")
piltext = useShort("P4hrL", "Prev 4hr Low")
iotext  = useShort("4hrO", "4hr Open")
pimtext = useShort("P4hrM", "Prev 4hr Mid")
pmonhtext = useShort("Mon-H", "Monday High")
pmonltext = useShort("Mon-L", "Monday Low")
pmonmtext = useShort("Mon-M", "Monday Mid")
overnighthtext = useShort("ON-H", "Overnight High")
overnightltext = useShort("ON-L", "Overnight Low")
tokyohtext = useShort("Tok-H", "Tokyo High")
tokyoltext = useShort("Tok-L", "Tokyo Low")
tokyootext = useShort("Tok-O", "Tokyo Open")
hongkonghtext = useShort("HK-H", "Hong Kong High")
hongkongltext = useShort("HK-L", "Hong Kong Low")
hongkongotext = useShort("HK-O", "Hong Kong Open")
asiahtext = useShort("ASC-H", "Asia Composite High")
asialtext = useShort("ASC-L", "Asia Composite Low")
asiaotext = useShort("ASC-O", "Asia Composite Open")
lhtext  = useShort("Lon-H", "London High")
lltext  = useShort("Lon-L", "London Low")
lotext  = useShort("Lon-O", "London Open")
ushtext = useShort("NY-H", "New York High")
usltext = useShort("NY-L", "New York Low")
usotext = useShort("NY-O", "New York Open")
usctext = useShort("NY-C", "New York Close")
prthctext = useShort("PRTH-C", "Prior RTH Close")
lateotext = useShort("AH-O", "After-Hours Open")
latehtext = useShort("AH-H", "After-Hours High")
lateltext = useShort("AH-L", "After-Hours Low")
latectext = useShort("AH-C", "After-Hours Close")
globexotext = useShort("GX-O", "Globex Open")
globexctext = useShort("GX-C", "Globex Close")
//════════════════════════════════════════════════════════════════════
// STYLE AND TIME HELPERS
//════════════════════════════════════════════════════════════════════
labelSize = switch labelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
resolveLineStyle(string styleInput) =>
    switch styleInput
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
barMs() =>
    int fallback = timeframe.in_seconds(timeframe.period) * 1000
    int nextTime = time("", bars_back = -1)
    int liveMs = not na(nextTime) ? nextTime - time : na(time[1]) ? fallback : time - time[1]
    liveMs > 0 ? liveMs : fallback
// Shared fixed right endpoint for ALL lines
lineRightTime() =>
    time + barMs() * extendLinesRightBars
//════════════════════════════════════════════════════════════════════
// HIGHER-TIMEFRAME VALUES
//════════════════════════════════════════════════════════════════════
[daily_time, daily_open]     = request.security(syminfo.tickerid, "D",   [time, open],       lookahead = barmerge.lookahead_on)
[dailyh_time, dailyh_open]   = request.security(syminfo.tickerid, "D",   [time[1], high[1]], lookahead = barmerge.lookahead_on)
[dailyl_time, dailyl_open]   = request.security(syminfo.tickerid, "D",   [time[1], low[1]],  lookahead = barmerge.lookahead_on)
cdailyh_open                 = request.security(syminfo.tickerid, "D",   high,              lookahead = barmerge.lookahead_on)
cdailyl_open                 = request.security(syminfo.tickerid, "D",   low,               lookahead = barmerge.lookahead_on)
[weekly_time, weekly_open]   = request.security(syminfo.tickerid, "W",   [time, open],       lookahead = barmerge.lookahead_on)
[weeklyh_time, weeklyh_open] = request.security(syminfo.tickerid, "W",   [time[1], high[1]], lookahead = barmerge.lookahead_on)
[weeklyl_time, weeklyl_open] = request.security(syminfo.tickerid, "W",   [time[1], low[1]],  lookahead = barmerge.lookahead_on)
[monthly_time, monthly_open]   = request.security(syminfo.tickerid, "M", [time, open],       lookahead = barmerge.lookahead_on)
[monthlyh_time, monthlyh_open] = request.security(syminfo.tickerid, "M", [time[1], high[1]], lookahead = barmerge.lookahead_on)
[monthlyl_time, monthlyl_open] = request.security(syminfo.tickerid, "M", [time[1], low[1]],  lookahead = barmerge.lookahead_on)
[quarterly_time, quarterly_open]   = request.security(syminfo.tickerid, "3M", [time, open],       lookahead = barmerge.lookahead_on)
[quarterlyh_time, quarterlyh_open] = request.security(syminfo.tickerid, "3M", [time[1], high[1]], lookahead = barmerge.lookahead_on)
[quarterlyl_time, quarterlyl_open] = request.security(syminfo.tickerid, "3M", [time[1], low[1]],  lookahead = barmerge.lookahead_on)
[yearly_time, yearly_open]   = request.security(syminfo.tickerid, "12M", [time, open], lookahead = barmerge.lookahead_on)
[yearlyh_time, yearlyh_open] = request.security(syminfo.tickerid, "12M", [time, high], lookahead = barmerge.lookahead_on)
[yearlyl_time, yearlyl_open] = request.security(syminfo.tickerid, "12M", [time, low],  lookahead = barmerge.lookahead_on)
[intra_time, intra_open]     = request.security(syminfo.tickerid, "240", [time, open],       lookahead = barmerge.lookahead_on)
[intrah_time, intrah_open]   = request.security(syminfo.tickerid, "240", [time[1], high[1]], lookahead = barmerge.lookahead_on)
[intral_time, intral_open]   = request.security(syminfo.tickerid, "240", [time[1], low[1]],  lookahead = barmerge.lookahead_on)
//════════════════════════════════════════════════════════════════════
// MARKET SESSION TEMPLATE RESOLUTION
//════════════════════════════════════════════════════════════════════
string US_FUTURES_SESSION_TEMPLATE = "US Futures"
string US_EQUITIES_SESSION_TEMPLATE = "US Equities"
string GLOBAL_FX_SESSION_TEMPLATE = "Global FX"
string METALS_SESSION_TEMPLATE = "Metals"
string ENERGY_SESSION_TEMPLATE = "Energy"
string CRYPTO_SESSION_TEMPLATE = "Crypto"
string CUSTOM_SESSION_TEMPLATE = "Custom"
string autoSessionTemplate = isNQSymbol or isESSymbol or isYMSymbol or isRTYSymbol ? US_FUTURES_SESSION_TEMPLATE :
     isStockSymbol ? US_EQUITIES_SESSION_TEMPLATE :
     isGCSymbol or isSISymbol or isHGSymbol ? METALS_SESSION_TEMPLATE :
     isCLSymbol or isNGSymbol or isRBSymbol or isHOSymbol ? ENERGY_SESSION_TEMPLATE :
     isCryptoSymbol or isCmeCryptoFutures ? CRYPTO_SESSION_TEMPLATE : US_FUTURES_SESSION_TEMPLATE
string selectedSessionTemplate = sessionTemplateMode == "Auto Detect" ? autoSessionTemplate : sessionTemplateMode
bool isUSFuturesSessionTemplate = selectedSessionTemplate == US_FUTURES_SESSION_TEMPLATE
bool isUSEquitiesSessionTemplate = selectedSessionTemplate == US_EQUITIES_SESSION_TEMPLATE
bool isGlobalFXSessionTemplate  = selectedSessionTemplate == GLOBAL_FX_SESSION_TEMPLATE
bool isMetalsSessionTemplate    = selectedSessionTemplate == METALS_SESSION_TEMPLATE
bool isEnergySessionTemplate    = selectedSessionTemplate == ENERGY_SESSION_TEMPLATE
bool isCryptoSessionTemplate    = selectedSessionTemplate == CRYPTO_SESSION_TEMPLATE
bool isCustomSessionTemplate    = selectedSessionTemplate == CUSTOM_SESSION_TEMPLATE
// Tokyo and Hong Kong presets use native local timezones.
// Existing composite, London, Core, and Late template behavior remains in its resolved template timezone.
string coreSessionTZ   = isCustomSessionTemplate ? customSessionTZ : isCryptoSessionTemplate ? "Etc/UTC" : "America/New_York"
string globexSessionTZ = isCustomSessionTemplate ? customSessionTZ : "America/New_York"
string OvernightTZ     = isCustomSessionTemplate ? customSessionTZ : "America/New_York"
string TokyoTZ         = isCustomSessionTemplate ? customSessionTZ : "Asia/Tokyo"
string HongKongTZ      = isCustomSessionTemplate ? customSessionTZ : "Asia/Hong_Kong"
string AsiaCompositeTZ = coreSessionTZ
string LondonTZ        = coreSessionTZ
string TokyoSession = isCustomSessionTemplate ? Tokyot : "0900-1530"
string HongKongSession = isCustomSessionTemplate ? HongKongt : "0930-1600"
string TokyoTradingSession = isCustomSessionTemplate ? TokyoSession : "0900-1130,1230-1530"
string HongKongTradingSession = isCustomSessionTemplate ? HongKongSession : "0930-1200,1300-1600"
string OvernightSession = isCustomSessionTemplate ? Overnightt : "1800-0930"
// Preserve the original broad Asia/overnight range as an optional composite.
string AsiaCompositeSession = isCustomSessionTemplate ? AsiaCompositet :
     isUSFuturesSessionTemplate ? "1800-0400" :
     isUSEquitiesSessionTemplate ? "2100-0400" :
     isGlobalFXSessionTemplate ? "1700-0300" :
     isMetalsSessionTemplate ? "1800-0400" :
     isEnergySessionTemplate ? "1800-0400" :
     isCryptoSessionTemplate ? "0000-0800" : "1800-0400"
// Preserve the established Level3d London / Pre-Core windows.
string LondonSession = isCustomSessionTemplate ? Londont :
     isUSFuturesSessionTemplate ? "0400-0930" :
     isUSEquitiesSessionTemplate ? "0400-0930" :
     isGlobalFXSessionTemplate ? "0300-0930" :
     isMetalsSessionTemplate ? "0400-0820" :
     isEnergySessionTemplate ? "0400-0900" :
     isCryptoSessionTemplate ? "0800-1330" : "0400-0930"
string USSession = isCustomSessionTemplate ? USt :
     isGlobalFXSessionTemplate ? "0930-1600" :
     isMetalsSessionTemplate ? "0820-1330" :
     isEnergySessionTemplate ? "0900-1430" :
     isCryptoSessionTemplate ? "1330-2100" : "0930-1600"
string LateSession = isCustomSessionTemplate ? Latet :
     isUSFuturesSessionTemplate ? "1600-1700" :
     isUSEquitiesSessionTemplate ? "1600-2000" :
     isGlobalFXSessionTemplate ? "1600-1700" :
     isMetalsSessionTemplate ? "1330-1700" :
     isEnergySessionTemplate ? "1430-1700" :
     isCryptoSessionTemplate ? "2100-0000" : "1600-1700"
// Globex anchors are available for futures-style templates and Custom mode.
bool isGlobexTemplate = isUSFuturesSessionTemplate or isMetalsSessionTemplate or isEnergySessionTemplate or isCustomSessionTemplate
string GlobexSession = isCustomSessionTemplate ? Globext : "1800-1700"
bool showGlobexAnchors = is_globexanchors_enabled and isGlobexTemplate
bool showOvernightRange = is_overnightrange_enabled and (isUSFuturesSessionTemplate or isCustomSessionTemplate)
string activeSessionModeLabelBase = isCustomSessionTemplate ? "Custom Sessions" : selectedSessionTemplate
string activeSessionModeLabel = sessionTemplateMode == "Auto Detect" ? "Auto: " + activeSessionModeLabelBase : activeSessionModeLabelBase
//════════════════════════════════════════════════════════════════════
// MERGE HELPER
//════════════════════════════════════════════════════════════════════
f_LevelMerge(array<float> priceArr, array<label> labelArr, array<line> mergeLineArr, float currentprice, label currentlabel, line currentline, color currentcolor) =>
    float mergeTolerance = syminfo.mintick * labelMergeToleranceTicks
    int whichindex = na
    if array.size(priceArr) > 0
        for i = 0 to array.size(priceArr) - 1
            float storedPrice = array.get(priceArr, i)
            if math.abs(currentprice - storedPrice) <= mergeTolerance
                whichindex := i
                break
    if not na(whichindex)
        label labelhold = array.get(labelArr, whichindex)
        line linehold = array.get(mergeLineArr, whichindex)
        string holdText = label.get_text(labelhold)
        string currText = label.get_text(currentlabel)
        string mergedText = holdText + " / " + currText
        if str.length(mergedText) > extendLinesRightBars
            mergedText := str.replace_all(mergedText, "Prev Day High", "PDH")
            mergedText := str.replace_all(mergedText, "Prev Day Low", "PDL")
            mergedText := str.replace_all(mergedText, "Daily Open", "DO")
            mergedText := str.replace_all(mergedText, "Prev Day Mid", "PDM")
            mergedText := str.replace_all(mergedText, "Prev Week High", "PWH")
            mergedText := str.replace_all(mergedText, "Prev Week Low", "PWL")
            mergedText := str.replace_all(mergedText, "Weekly Open", "WO")
            mergedText := str.replace_all(mergedText, "Prev Week Mid", "PWM")
            mergedText := str.replace_all(mergedText, "Prev Month High", "PMH")
            mergedText := str.replace_all(mergedText, "Prev Month Low", "PML")
            mergedText := str.replace_all(mergedText, "Monthly Open", "MO")
            mergedText := str.replace_all(mergedText, "Prev Month Mid", "PMM")
            mergedText := str.replace_all(mergedText, "Prev Quarter High", "PQH")
            mergedText := str.replace_all(mergedText, "Prev Quarter Low", "PQL")
            mergedText := str.replace_all(mergedText, "Quarterly Open", "QO")
            mergedText := str.replace_all(mergedText, "Prev Quarter Mid", "PQM")
            mergedText := str.replace_all(mergedText, "Current Year High", "CYrH")
            mergedText := str.replace_all(mergedText, "Current Year Low", "CYrL")
            mergedText := str.replace_all(mergedText, "Yearly Open", "YrO")
            mergedText := str.replace_all(mergedText, "Current Year Mid", "CYrM")
            mergedText := str.replace_all(mergedText, "Prev 4hr High", "P4hrH")
            mergedText := str.replace_all(mergedText, "Prev 4hr Low", "P4hrL")
            mergedText := str.replace_all(mergedText, "4hr Open", "4hrO")
            mergedText := str.replace_all(mergedText, "Prev 4hr Mid", "P4hrM")
            mergedText := str.replace_all(mergedText, "Monday High", "Mon-H")
            mergedText := str.replace_all(mergedText, "Monday Low", "Mon-L")
            mergedText := str.replace_all(mergedText, "Monday Mid", "Mon-M")
            mergedText := str.replace_all(mergedText, "Overnight High", "ON-H")
            mergedText := str.replace_all(mergedText, "Overnight Low", "ON-L")
            mergedText := str.replace_all(mergedText, "Overnight Open", "ON-O")
            mergedText := str.replace_all(mergedText, "Tokyo High", "Tok-H")
            mergedText := str.replace_all(mergedText, "Tokyo Low", "Tok-L")
            mergedText := str.replace_all(mergedText, "Tokyo Open", "Tok-O")
            mergedText := str.replace_all(mergedText, "Hong Kong High", "HK-H")
            mergedText := str.replace_all(mergedText, "Hong Kong Low", "HK-L")
            mergedText := str.replace_all(mergedText, "Hong Kong Open", "HK-O")
            mergedText := str.replace_all(mergedText, "Asia Composite High", "ASC-H")
            mergedText := str.replace_all(mergedText, "Asia Composite Low", "ASC-L")
            mergedText := str.replace_all(mergedText, "Asia Composite Open", "ASC-O")
            mergedText := str.replace_all(mergedText, "London High", "Lon-H")
            mergedText := str.replace_all(mergedText, "London Low", "Lon-L")
            mergedText := str.replace_all(mergedText, "London Open", "Lon-O")
            mergedText := str.replace_all(mergedText, "New York High", "NY-H")
            mergedText := str.replace_all(mergedText, "New York Low", "NY-L")
            mergedText := str.replace_all(mergedText, "New York Open", "NY-O")
            mergedText := str.replace_all(mergedText, "New York Close", "NY-C")
            mergedText := str.replace_all(mergedText, "Prior RTH Close", "PRTH-C")
            mergedText := str.replace_all(mergedText, "After-Hours Open", "AH-O")
            mergedText := str.replace_all(mergedText, "After-Hours High", "AH-H")
            mergedText := str.replace_all(mergedText, "After-Hours Low", "AH-L")
            mergedText := str.replace_all(mergedText, "After-Hours Close", "AH-C")
            mergedText := str.replace_all(mergedText, "Globex Open", "GX-O")
            mergedText := str.replace_all(mergedText, "Globex Close", "GX-C")
        int mergedLineRight = lineRightTime()
        int mergedLabelX = mergedLineRight
        // Keep one visible shared label and shared line
        label.set_text(labelhold, mergedText)
        // Retain first-encountered label and line color, width, and style.
        // Do not reset label textcolor.
        // Do not reset linehold color.
        label.set_x(labelhold, mergedLabelX)
        label.set_y(labelhold, currentprice)
        label.set_textalign(labelhold, text.align_left)
        // Hide duplicate label
        label.set_text(currentlabel, "")
        label.set_textcolor(currentlabel, color.new(currentcolor, 100))
        // Hide duplicate overlapping line
        line.set_color(currentline, color.new(currentcolor, 100))
        // Keep line endpoints synced
        line.set_x2(linehold, mergedLineRight)
        line.set_x2(currentline, mergedLineRight)
    else
        array.push(priceArr, currentprice)
        array.push(labelArr, currentlabel)
        array.push(mergeLineArr, currentline)
//════════════════════════════════════════════════════════════════════
// DRAWING OBJECT STORAGE
//════════════════════════════════════════════════════════════════════
var array<line>  lineIds  = array.new_line(LEVEL_COUNT)
var array<label> labelIds = array.new_label(LEVEL_COUNT)
drawLevel(int idx, bool enabled, int sourceTime, float level, string txt, color clr, int lineWidth, string lineStyleInput, array<float> priceArr, array<label> labelArr, array<line> mergeLineArr) =>
    line ln = array.get(lineIds, idx)
    label lb = array.get(labelIds, idx)
    string lineStyle = resolveLineStyle(lineStyleInput)
    if enabled and not na(level) and not na(sourceTime)
        // Shared fixed endpoint
        int lineX2 = lineRightTime()
        // Label midpoint anchored to line endpoint
        int labelX = lineX2
        if na(ln)
            ln := line.new(
                 x1 = sourceTime,
                 y1 = level,
                 x2 = lineX2,
                 y2 = level,
                 xloc = xloc.bar_time,
                 color = clr,
                 width = lineWidth,
                 style = lineStyle
            )
            array.set(lineIds, idx, ln)
        else
            line.set_x1(ln, sourceTime)
            line.set_x2(ln, lineX2)
            line.set_y1(ln, level)
            line.set_y2(ln, level)
            line.set_color(ln, clr)
            line.set_width(ln, lineWidth)
            line.set_style(ln, lineStyle)
        if na(lb)
            lb := label.new(
                 x = labelX,
                 y = level,
                 text = txt,
                 xloc = xloc.bar_time,
                 yloc = yloc.price,
                 style = label.style_label_left,
                 color = color.new(color.rgb(0, 0, 0), 100),
                 textcolor = clr,
                 size = labelSize,
                 textalign = text.align_left
            )
            array.set(labelIds, idx, lb)
        else
            label.set_x(lb, labelX)
            label.set_y(lb, level)
            label.set_text(lb, txt)
            label.set_textcolor(lb, clr)
            label.set_size(lb, labelSize)
            label.set_style(lb, label.style_label_left)
            label.set_color(lb, color.new(color.rgb(0, 0, 0), 100))
            label.set_textalign(lb, text.align_left)
        f_LevelMerge(priceArr, labelArr, mergeLineArr, level, lb, ln, clr)
    else
        if not na(ln)
            line.delete(ln)
            array.set(lineIds, idx, na)
        if not na(lb)
            label.delete(lb)
            array.set(labelIds, idx, na)
//════════════════════════════════════════════════════════════════════
// MONDAY RANGE LOGIC
// Sunday 18:00 New York time is treated as the start of Monday trading.
// Monday range develops from Sunday 18:00 through Monday 17:00.
// Display toggles do NOT affect the math.
//════════════════════════════════════════════════════════════════════
string MONDAY_RANGE_TZ = "America/New_York"
var int   monday_time = na
var float monday_high = na
var float monday_low  = na
int mondayDow    = dayofweek(time, MONDAY_RANGE_TZ)
int mondayHour   = hour(time, MONDAY_RANGE_TZ)
int mondayMinute = minute(time, MONDAY_RANGE_TZ)
int mondayMins   = mondayHour * 60 + mondayMinute
bool isSundayMondayStart = mondayDow == dayofweek.sunday and mondayMins >= 18 * 60
bool isMondayTradingDay  = mondayDow == dayofweek.monday and mondayMins < 17 * 60
bool isMondayTrading     = isSundayMondayStart or isMondayTradingDay
bool mondayWasTrading    = bar_index > 0 ? isMondayTrading[1] : false
bool mondayJustStarted   = isMondayTrading and not mondayWasTrading
if mondayJustStarted
    monday_time := time
    monday_high := high
    monday_low  := low
else if isMondayTrading
    monday_high := na(monday_high) ? high : math.max(monday_high, high)
    monday_low  := na(monday_low)  ? low  : math.min(monday_low, low)
//════════════════════════════════════════════════════════════════════
// MARKET SESSION RANGE TRACKING
//════════════════════════════════════════════════════════════════════
tokyoSessionMarker         = time(timeframe.period, TokyoSession, TokyoTZ)
tokyoTradingMarker         = time(timeframe.period, TokyoTradingSession, TokyoTZ)
hongKongSessionMarker      = time(timeframe.period, HongKongSession, HongKongTZ)
hongKongTradingMarker      = time(timeframe.period, HongKongTradingSession, HongKongTZ)
asiaCompositeSessionMarker = time(timeframe.period, AsiaCompositeSession, AsiaCompositeTZ)
londonSessionMarker        = time(timeframe.period, LondonSession, LondonTZ)
newYorkSessionMarker       = time(timeframe.period, USSession, coreSessionTZ)
lateSessionMarker          = time(timeframe.period, LateSession, coreSessionTZ)
globexSessionMarker        = time(timeframe.period, GlobexSession, globexSessionTZ)
overnightSessionMarker     = time(timeframe.period, OvernightSession, OvernightTZ)
var float tokyoCurrentHigh = na
var float tokyoCurrentLow = na
var int   tokyoStartTime = na
var float tokyoFinalHigh = na
var float tokyoFinalLow = na
var float tokyoFinalOpen = na
var bool  tokyoWasInactive = true
if not na(tokyoSessionMarker)
    if tokyoWasInactive
        tokyoStartTime := time
        tokyoFinalOpen := open
        tokyoCurrentHigh := na
        tokyoCurrentLow := na
    if not na(tokyoTradingMarker)
        tokyoCurrentHigh := na(tokyoCurrentHigh) ? high : math.max(tokyoCurrentHigh, high)
        tokyoCurrentLow := na(tokyoCurrentLow) ? low : math.min(tokyoCurrentLow, low)
        tokyoFinalHigh := tokyoCurrentHigh
        tokyoFinalLow := tokyoCurrentLow
    tokyoWasInactive := false
else
    if not tokyoWasInactive
        tokyoFinalHigh := tokyoCurrentHigh
        tokyoFinalLow := tokyoCurrentLow
    tokyoWasInactive := true
    tokyoCurrentHigh := na
    tokyoCurrentLow := na
var float hongKongCurrentHigh = na
var float hongKongCurrentLow = na
var int   hongKongStartTime = na
var float hongKongFinalHigh = na
var float hongKongFinalLow = na
var float hongKongFinalOpen = na
var bool  hongKongWasInactive = true
if not na(hongKongSessionMarker)
    if hongKongWasInactive
        hongKongStartTime := time
        hongKongFinalOpen := open
        hongKongCurrentHigh := na
        hongKongCurrentLow := na
    if not na(hongKongTradingMarker)
        hongKongCurrentHigh := na(hongKongCurrentHigh) ? high : math.max(hongKongCurrentHigh, high)
        hongKongCurrentLow := na(hongKongCurrentLow) ? low : math.min(hongKongCurrentLow, low)
        hongKongFinalHigh := hongKongCurrentHigh
        hongKongFinalLow := hongKongCurrentLow
    hongKongWasInactive := false
else
    if not hongKongWasInactive
        hongKongFinalHigh := hongKongCurrentHigh
        hongKongFinalLow := hongKongCurrentLow
    hongKongWasInactive := true
    hongKongCurrentHigh := na
    hongKongCurrentLow := na
var float asiaCurrentHigh = na
var float asiaCurrentLow = na
var int   asiaStartTime = na
var float asiaFinalHigh = na
var float asiaFinalLow = na
var float asiaFinalOpen = na
var bool  asiaWasInactive = true
if not na(asiaCompositeSessionMarker)
    if asiaWasInactive
        asiaStartTime := time
        asiaFinalOpen := open
        asiaCurrentHigh := high
        asiaCurrentLow := low
    else
        asiaCurrentHigh := math.max(asiaCurrentHigh, high)
        asiaCurrentLow := math.min(asiaCurrentLow, low)
    asiaFinalHigh := asiaCurrentHigh
    asiaFinalLow := asiaCurrentLow
    asiaWasInactive := false
else
    if not asiaWasInactive
        asiaFinalHigh := asiaCurrentHigh
        asiaFinalLow := asiaCurrentLow
    asiaWasInactive := true
    asiaCurrentHigh := na
    asiaCurrentLow := na
var float londonCurrentHigh = na
var float londonCurrentLow = na
var int   londonStartTime = na
var float londonFinalHigh = na
var float londonFinalLow = na
var float londonFinalOpen = na
var bool  londonWasInactive = true
if not na(londonSessionMarker)
    if londonWasInactive
        londonStartTime := time
        londonFinalOpen := open
        londonCurrentHigh := high
        londonCurrentLow := low
    else
        londonCurrentHigh := math.max(londonCurrentHigh, high)
        londonCurrentLow := math.min(londonCurrentLow, low)
    londonFinalHigh := londonCurrentHigh
    londonFinalLow := londonCurrentLow
    londonWasInactive := false
else
    if not londonWasInactive
        londonFinalHigh := londonCurrentHigh
        londonFinalLow := londonCurrentLow
    londonWasInactive := true
    londonCurrentHigh := na
    londonCurrentLow := na
var float newYorkCurrentHigh = na
var float newYorkCurrentLow = na
var float newYorkCurrentClose = na
var int   newYorkCurrentCloseTime = na
var int   newYorkStartTime = na
var float newYorkFinalHigh = na
var float newYorkFinalLow = na
var float newYorkFinalOpen = na
var float newYorkFinalClose = na
var int   newYorkFinalCloseTime = na
var float priorRthClose = na
var int   priorRthCloseTime = na
var bool  newYorkWasInactive = true
if not na(newYorkSessionMarker)
    if newYorkWasInactive
        newYorkStartTime := time
        newYorkFinalOpen := open
        newYorkCurrentHigh := high
        newYorkCurrentLow := low
    else
        newYorkCurrentHigh := math.max(newYorkCurrentHigh, high)
        newYorkCurrentLow := math.min(newYorkCurrentLow, low)
    newYorkCurrentClose := close
    newYorkCurrentCloseTime := time_close
    newYorkFinalHigh := newYorkCurrentHigh
    newYorkFinalLow := newYorkCurrentLow
    newYorkWasInactive := false
else
    if not newYorkWasInactive
        newYorkFinalHigh := newYorkCurrentHigh
        newYorkFinalLow := newYorkCurrentLow
        newYorkFinalClose := newYorkCurrentClose
        newYorkFinalCloseTime := newYorkCurrentCloseTime
        priorRthClose := newYorkFinalClose
        priorRthCloseTime := newYorkFinalCloseTime
    newYorkWasInactive := true
    newYorkCurrentHigh := na
    newYorkCurrentLow := na
    newYorkCurrentClose := na
    newYorkCurrentCloseTime := na
var float lateCurrentHigh = na
var float lateCurrentLow = na
var float lateCurrentClose = na
var int   lateCurrentCloseTime = na
var int   lateStartTime = na
var float lateFinalHigh = na
var float lateFinalLow = na
var float lateFinalOpen = na
var float lateFinalClose = na
var int   lateFinalCloseTime = na
var bool  lateWasInactive = true
if not na(lateSessionMarker)
    if lateWasInactive
        lateStartTime := time
        lateFinalOpen := open
        lateCurrentHigh := high
        lateCurrentLow := low
    else
        lateCurrentHigh := math.max(lateCurrentHigh, high)
        lateCurrentLow := math.min(lateCurrentLow, low)
    lateCurrentClose := close
    lateCurrentCloseTime := time_close
    lateFinalHigh := lateCurrentHigh
    lateFinalLow := lateCurrentLow
    lateWasInactive := false
else
    if not lateWasInactive
        lateFinalHigh := lateCurrentHigh
        lateFinalLow := lateCurrentLow
        lateFinalClose := lateCurrentClose
        lateFinalCloseTime := lateCurrentCloseTime
    lateWasInactive := true
    lateCurrentHigh := na
    lateCurrentLow := na
    lateCurrentClose := na
    lateCurrentCloseTime := na
var float overnightCurrentHigh = na
var float overnightCurrentLow = na
var int   overnightStartTime = na
var float overnightFinalHigh = na
var float overnightFinalLow = na
var bool  overnightWasInactive = true
if not na(overnightSessionMarker)
    if overnightWasInactive
        overnightStartTime := time
        overnightCurrentHigh := high
        overnightCurrentLow := low
    else
        overnightCurrentHigh := math.max(overnightCurrentHigh, high)
        overnightCurrentLow := math.min(overnightCurrentLow, low)
    overnightFinalHigh := overnightCurrentHigh
    overnightFinalLow := overnightCurrentLow
    overnightWasInactive := false
else
    if not overnightWasInactive
        overnightFinalHigh := overnightCurrentHigh
        overnightFinalLow := overnightCurrentLow
    overnightWasInactive := true
    overnightCurrentHigh := na
    overnightCurrentLow := na
var float globexCurrentClose = na
var int   globexCurrentCloseTime = na
var int   globexStartTime = na
var float globexFinalOpen = na
var float globexFinalClose = na
var int   globexFinalCloseTime = na
var bool  globexWasInactive = true
if not na(globexSessionMarker)
    if globexWasInactive
        globexStartTime := time
        globexFinalOpen := open
    globexCurrentClose := close
    globexCurrentCloseTime := time_close
    globexWasInactive := false
else
    if not globexWasInactive
        globexFinalClose := globexCurrentClose
        globexFinalCloseTime := globexCurrentCloseTime
    globexWasInactive := true
    globexCurrentClose := na
    globexCurrentCloseTime := na
var array<float> mergePriceArray = array.new_float()
var array<label> mergeLabelArray = array.new_label()
var array<line>  mergeLineArray = array.new_line()
//════════════════════════════════════════════════════════════════════
// ACTIVE MODE LABEL
//════════════════════════════════════════════════════════════════════
// Active Mode table visibility is controlled from TradingView's Style tab.
var table activeModeTable = table.new(position.bottom_right, 1, 1, border_width = 1)
if barstate.islast
    string activeModeText = "Level3d  " + activeSessionModeLabel +
         "\nOvernight: " + (showOvernightRange ? OvernightSession + "  " + OvernightTZ : "N/A for template") +
         "\nTokyo: " + TokyoSession + "  " + TokyoTZ +
         "\nHong Kong: " + HongKongSession + "  " + HongKongTZ +
         "\nLondon: " + LondonSession + "  " + LondonTZ +
         "\nCore: " + USSession + "  " + coreSessionTZ +
         "\nLate: " + LateSession + "  " + coreSessionTZ +
         "\nGlobex: " + (isGlobexTemplate ? GlobexSession + "  " + globexSessionTZ : "N/A for template")
    table.cell(
         activeModeTable,
         0,
         0,
         activeModeText,
         text_color = color.rgb(0, 255, 255),
         bgcolor = color.new(color.rgb(0, 0, 0), 75),
         text_size = size.small,
         text_halign = text.align_left
    )
//════════════════════════════════════════════════════════════════════
// PLOTTING
//════════════════════════════════════════════════════════════════════
if barstate.islast
    array.clear(mergePriceArray)
    array.clear(mergeLabelArray)
    array.clear(mergeLineArray)
    // Market Sessions
    // Draw specific markets before composite/framework anchors so their colors win label merges.
    drawLevel(42, is_tokyorange_enabled, tokyoStartTime, tokyoFinalHigh, tokyohtext, TokyoColor, TokyoWidth, TokyoStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(43, is_tokyorange_enabled, tokyoStartTime, tokyoFinalLow,  tokyoltext, TokyoColor, TokyoWidth, TokyoStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(44, is_tokyorange_enabled, tokyoStartTime, tokyoFinalOpen, tokyootext, TokyoColor, TokyoWidth, TokyoStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(45, is_hongkongrange_enabled, hongKongStartTime, hongKongFinalHigh, hongkonghtext, HongKongColor, HongKongWidth, HongKongStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(46, is_hongkongrange_enabled, hongKongStartTime, hongKongFinalLow,  hongkongltext, HongKongColor, HongKongWidth, HongKongStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(47, is_hongkongrange_enabled, hongKongStartTime, hongKongFinalOpen, hongkongotext, HongKongColor, HongKongWidth, HongKongStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(0, is_londonrange_enabled, londonStartTime, londonFinalHigh, lhtext, LondonColor, LondonWidth, LondonStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(1, is_londonrange_enabled, londonStartTime, londonFinalLow,  lltext, LondonColor, LondonWidth, LondonStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(2, is_londonrange_enabled, londonStartTime, londonFinalOpen, lotext, LondonColor, LondonWidth, LondonStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(3, is_usrange_enabled, newYorkStartTime, newYorkFinalHigh, ushtext, USColor, USWidth, USStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(4, is_usrange_enabled, newYorkStartTime, newYorkFinalLow, usltext, USColor, USWidth, USStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(5, is_usrange_enabled, newYorkStartTime, newYorkFinalOpen, usotext, USColor, USWidth, USStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(39, is_usrange_enabled, newYorkFinalCloseTime, newYorkFinalClose, usctext, USColor, USWidth, USStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(40, is_usrange_enabled, priorRthCloseTime, priorRthClose, prthctext, USColor, USWidth, USStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(36, is_laterange_enabled, lateStartTime, lateFinalOpen, lateotext, LateColor, LateWidth, LateStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(37, is_laterange_enabled, lateStartTime, lateFinalHigh, latehtext, LateColor, LateWidth, LateStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(38, is_laterange_enabled, lateStartTime, lateFinalLow, lateltext, LateColor, LateWidth, LateStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(41, is_laterange_enabled, lateFinalCloseTime, lateFinalClose, latectext, LateColor, LateWidth, LateStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Broad pre-RTH/composite levels follow specific markets in merge priority.
    drawLevel(50, showOvernightRange, overnightStartTime, overnightFinalHigh, overnighthtext, OvernightColor, OvernightWidth, OvernightStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(51, showOvernightRange, overnightStartTime, overnightFinalLow, overnightltext, OvernightColor, OvernightWidth, OvernightStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(6, is_asiacompositerange_enabled, asiaStartTime, asiaFinalHigh, asiahtext, AsiaCompositeColor, AsiaCompositeWidth, AsiaCompositeStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(7, is_asiacompositerange_enabled, asiaStartTime, asiaFinalLow,  asialtext, AsiaCompositeColor, AsiaCompositeWidth, AsiaCompositeStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(8, is_asiacompositerange_enabled, asiaStartTime, asiaFinalOpen, asiaotext, AsiaCompositeColor, AsiaCompositeWidth, AsiaCompositeStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Globex remains the full futures-day framework: Open and Close only.
    drawLevel(48, showGlobexAnchors, globexStartTime, globexFinalOpen, globexotext, GlobexColor, GlobexWidth, GlobexStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(49, showGlobexAnchors, globexFinalCloseTime, globexFinalClose, globexctext, GlobexColor, GlobexWidth, GlobexStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // 4H
    float intram_open = (intral_open + intrah_open) / 2.0
    drawLevel(9,  is_intra_enabled,      intra_time,  intra_open,  iotext,  IntraColor, IntraWidth, IntraStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(10, is_intrarange_enabled, intrah_time, intrah_open, pihtext, IntraColor, IntraWidth, IntraStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(11, is_intrarange_enabled, intral_time, intral_open, piltext, IntraColor, IntraWidth, IntraStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(12, is_intram_enabled,     intrah_time, intram_open, pimtext, IntraColor, IntraWidth, IntraStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Daily
    drawLevel(16, is_daily_enabled, daily_time, daily_open, dotext, DailyColor, DailyWidth, DailyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Prior Day
    float dailym_open = (dailyl_open + dailyh_open) / 2.0
    drawLevel(17, is_priordayrange_enabled, dailyh_time, dailyh_open, pdhtext, PriorDayColor, PriorDayWidth, PriorDayStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(18, is_priordayrange_enabled, dailyl_time, dailyl_open, pdltext, PriorDayColor, PriorDayWidth, PriorDayStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(19, is_priordaymid_enabled, dailyh_time, dailym_open, pdmtext, PriorDayColor, PriorDayWidth, PriorDayStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Monday Range
    float mondaym_open = not na(monday_high) and not na(monday_low) ? (monday_high + monday_low) / 2.0 : na
    drawLevel(13, is_monday_enabled, monday_time, monday_high,  pmonhtext, MondayColor, MondayWidth, MondayStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(14, is_monday_enabled, monday_time, monday_low,   pmonltext, MondayColor, MondayWidth, MondayStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(15, is_monday_mid,     monday_time, mondaym_open, pmonmtext, MondayColor, MondayWidth, MondayStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Weekly
    float weeklym_open = (weeklyl_open + weeklyh_open) / 2.0
    drawLevel(20, is_weekly_enabled,      weekly_time,  weekly_open,  wotext,  WeeklyColor, WeeklyWidth, WeeklyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(21, is_weeklyrange_enabled, weeklyh_time, weeklyh_open, pwhtext, WeeklyColor, WeeklyWidth, WeeklyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(22, is_weeklyrange_enabled, weeklyl_time, weeklyl_open, pwltext, WeeklyColor, WeeklyWidth, WeeklyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(23, is_weekly_mid,          weeklyh_time, weeklym_open, pwmtext, WeeklyColor, WeeklyWidth, WeeklyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Monthly
    float monthlym_open = (monthlyl_open + monthlyh_open) / 2.0
    drawLevel(24, is_monthly_enabled,      monthly_time,  monthly_open,  motext,  MonthlyColor, MonthlyWidth, MonthlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(25, is_monthlyrange_enabled, monthlyh_time, monthlyh_open, pmhtext, MonthlyColor, MonthlyWidth, MonthlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(26, is_monthlyrange_enabled, monthlyl_time, monthlyl_open, pmltext, MonthlyColor, MonthlyWidth, MonthlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(27, is_monthly_mid,          monthlyh_time, monthlym_open, pmmtext, MonthlyColor, MonthlyWidth, MonthlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Quarterly
    float quarterlym_open = (quarterlyl_open + quarterlyh_open) / 2.0
    drawLevel(28, is_quarterly_enabled,      quarterly_time,  quarterly_open,  qotext,  QuarterlyColor, QuarterlyWidth, QuarterlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(29, is_quarterlyrange_enabled, quarterlyh_time, quarterlyh_open, pqhtext, QuarterlyColor, QuarterlyWidth, QuarterlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(30, is_quarterlyrange_enabled, quarterlyl_time, quarterlyl_open, pqltext, QuarterlyColor, QuarterlyWidth, QuarterlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(31, is_quarterly_mid,          quarterlyh_time, quarterlym_open, pqmtext, QuarterlyColor, QuarterlyWidth, QuarterlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    // Yearly
    float yearlym_open = (yearlyl_open + yearlyh_open) / 2.0
    drawLevel(32, is_yearly_enabled,      yearly_time,  yearly_open,  yotext,  YearlyColor, YearlyWidth, YearlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(33, is_yearlyrange_enabled, yearlyh_time, yearlyh_open, cyhtext, YearlyColor, YearlyWidth, YearlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(34, is_yearlyrange_enabled, yearlyl_time, yearlyl_open, cyltext, YearlyColor, YearlyWidth, YearlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
    drawLevel(35, is_yearly_mid,          yearlyh_time, yearlym_open, cymtext, YearlyColor, YearlyWidth, YearlyStyleInput, mergePriceArray, mergeLabelArray, mergeLineArray)
````
