# IC KEY LEVELS & ICE

- url: https://www.tradingview.com/script/cymiqFL8-IC-KEY-LEVELS-ICE/
- type: indicator
- pine_id: PUB;7e9a3186916b411a831b3e2c4dde9bbc
- version: 2.0

## Description

This is the IC Key Levels indicator — a multi-timeframe price level plotting tool built around the concept that key opens, highs, lows, and midpoints from higher timeframes act as significant support/resistance levels on lower timeframe charts.

What it plots

It draws horizontal lines with labels for the following levels, each toggleable independently:

4H — Previous 4H open, high, low, and midpoint
Daily — Current day's open, previous day's high, low, and midpoint
Monday Range — Monday's high, low, and midpoint (resets each week)
Weekly — Current week's open, previous week's high, low, and midpoint
Monthly — Current month's open, previous month's high, low, and midpoint
Quarterly — Current quarter's open, previous quarter's high, low, and midpoint
Yearly — Current year's open, current year's high, low, and midpoint
FX Sessions — London, New York, and Asia session highs, lows, and opens (tracked in each city's local timezone)
Key features

Merge Levels — When two or more levels share the exact same price, their labels are combined into one (e.g. "WO / MO"), preventing label clutter at confluences.

Display Style — Lines can be drawn from where the period opened ("Standard") or anchored to a fixed distance from the right edge of the chart ("Right Anchored"), useful for keeping levels visible regardless of how far you've scrolled.

Global Coloring — A single master color can override all individual timeframe colors at once.

Shorthand Labels — Each group can be switched to abbreviated text (e.g. "PWH" instead of "Prev Week High") to reduce chart noise.

Line customisation — Width (Small/Medium/Large), style (Solid/Dashed/Dotted), and label size are all configurable globally.

The philosophy behind it

This is rooted in ICT (Inner Circle Trader) concepts — hence "IC" in the name. The idea is that institutional order flow tends to react at these periodic open/high/low prices because large participants reference the same levels. The Monday Range in particular is a key ICT concept, as Monday's price action is often considered a "draw" that the rest of the week either sweeps or respects. Session ranges (London, NY, Asia) are similarly used to identify where liquidity was taken and where price may return.

ICE CANDLE LOGIC INCLUDED

## Source Code

````pine
//@version=6
indicator('IC KEY LEVELS & ICE', shorttitle='IC KEY LEVELS & ICE', overlay=true, max_lines_count=500)

// ---------------------------------------------------------------
// ICE CANDLE SETTINGS
// ---------------------------------------------------------------
grp = "ICE Candle Settings"

iceBullColor = input.color(color.yellow, "Bullish ICE Color", group=grp)
iceBearColor = input.color(color.yellow, "Bearish ICE Color", group=grp)
requireWick  = input.bool(true, "Rejection Wick > Directional Wick", group=grp,
                 tooltip="The rejection wick must be larger than the opposite wick (ideal MC filter)")

// ---------------------------------------------------------------
// ICE LEVEL SETTINGS
// ---------------------------------------------------------------
grpLevels = "ICE Candle Levels"

showLevels = input.bool(true,  "Show Levels",    group=grpLevels)
levelColor = input.color(color.new(color.white, 40), "Level Color", group=grpLevels)
levelWidth = input.int(1, "Line Width", minval=1, maxval=4, group=grpLevels)

show50    = input.bool(true, "Show 50% (EQ)",  group=grpLevels)
show33_66 = input.bool(true, "Show 33% / 66%", group=grpLevels)
pct33     = input.float(33.0, "Lower Level %", minval=1.0, maxval=49.0, step=0.5, group=grpLevels,
               tooltip="Default 33%. Measured from wick low to wick high.")
pct66     = input.float(66.0, "Upper Level %", minval=51.0, maxval=99.0, step=0.5, group=grpLevels,
               tooltip="Default 66%. Measured from wick low to wick high.")

// ---------------------------------------------------------------
// ICE MANIPULATION CANDLE LOGIC
// ---------------------------------------------------------------
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bull_sweepsLow   = low  < low[1]
bull_takesHigh   = high > high[1]
bull_closesAbove = close > high[1]
bull_wickFilter  = not requireWick or (lowerWick > upperWick)
bullICE = bull_sweepsLow and bull_takesHigh and bull_closesAbove and bull_wickFilter

bear_sweepsHigh  = high > high[1]
bear_takesLow    = low  < low[1]
bear_closesBelow = close < low[1]
bear_wickFilter  = not requireWick or (upperWick > lowerWick)
bearICE = bear_sweepsHigh and bear_takesLow and bear_closesBelow and bear_wickFilter

// ---------------------------------------------------------------
// ICE CANDLE COLORING
// ---------------------------------------------------------------
barcolor(bullICE ? iceBullColor : bearICE ? iceBearColor : na)

// ---------------------------------------------------------------
// ICE LEVEL LINES
// ---------------------------------------------------------------
if showLevels and (bullICE or bearICE)
    wickRange = high - low

    price50 = low + wickRange * 0.50
    priceLo = low + wickRange * (pct33 / 100)
    priceHi = low + wickRange * (pct66 / 100)

    barMs = timeframe.in_seconds() * 1000
    t1    = int(time)
    t2    = int(time) + int(barMs)

    if show50
        line.new(t1, price50, t2, price50,
                 xloc=xloc.bar_time, color=levelColor, width=levelWidth)

    if show33_66
        line.new(t1, priceLo, t2, priceLo,
                 xloc=xloc.bar_time, color=levelColor, width=levelWidth)
        line.new(t1, priceHi, t2, priceHi,
                 xloc=xloc.bar_time, color=levelColor, width=levelWidth)

// ---------------------------------------------------------------
// ICE ALERTS
// ---------------------------------------------------------------
alertcondition(bullICE, title="Bullish ICE Candle", message="ICE -- Bullish ICE Candle detected! Possible bullish reversal.")
alertcondition(bearICE, title="Bearish ICE Candle", message="ICE -- Bearish ICE Candle detected! Possible bearish reversal.")
alertcondition(bullICE or bearICE, title="Any ICE Candle", message="ICE -- ICE Candle detected!")

// ---------------------------------------------------------------
// KEY LEVELS — GLOBAL SETTINGS
// ---------------------------------------------------------------
displayStyle   = input.string(defval='Standard', title='Display Style', options=['Standard', 'Right Anchored'], inline='Display')
mergebool      = input.bool(defval=true, title='Merge Levels?', inline='Display')
distanceright  = input.int(defval=30, title='Distance', minval=5, maxval=500, inline='Dist')
radistance     = input.int(defval=250, title='Anchor Distance', minval=5, maxval=500, inline='Dist')
labelsize      = input.string(defval='Medium', title='Text Size', options=['Small', 'Medium', 'Large'])
linesize       = input.string(defval='Small', title='Line Width', options=['Small', 'Medium', 'Large'], inline='Line')
linestyle      = input.string(defval='Solid', title='Line Style', options=['Solid', 'Dashed', 'Dotted'], inline='Line')

GlobalTextType     = input.bool(defval=false, title='Global Text ShortHand', tooltip='Enable for shorthand text on all text')
var globalcoloring = input.bool(defval=false, title='Global Coloring', tooltip='Enable for all color controls via one color', inline='GC')
GlobalColor        = input.color(title='', defval=color.white, inline='GC')

// ---------------------------------------------------------------
// KEY LEVELS — SECURITY REQUESTS
// ---------------------------------------------------------------
[daily_time, daily_open]       = request.security(syminfo.tickerid, 'D',   [time, open],       lookahead=barmerge.lookahead_on)
[dailyh_time, dailyh_open]     = request.security(syminfo.tickerid, 'D',   [time[1], high[1]], lookahead=barmerge.lookahead_on)
[dailyl_time, dailyl_open]     = request.security(syminfo.tickerid, 'D',   [time[1], low[1]],  lookahead=barmerge.lookahead_on)

cdailyh_open = request.security(syminfo.tickerid, 'D', high, lookahead=barmerge.lookahead_on)
cdailyl_open = request.security(syminfo.tickerid, 'D', low,  lookahead=barmerge.lookahead_on)

var monday_time = time
var monday_high = high
var monday_low  = low

[weekly_time, weekly_open]     = request.security(syminfo.tickerid, 'W',   [time, open],       lookahead=barmerge.lookahead_on)
[weeklyh_time, weeklyh_open]   = request.security(syminfo.tickerid, 'W',   [time[1], high[1]], lookahead=barmerge.lookahead_on)
[weeklyl_time, weeklyl_open]   = request.security(syminfo.tickerid, 'W',   [time[1], low[1]],  lookahead=barmerge.lookahead_on)

[monthly_time, monthly_open]   = request.security(syminfo.tickerid, 'M',   [time, open],       lookahead=barmerge.lookahead_on)
[monthlyh_time, monthlyh_open] = request.security(syminfo.tickerid, 'M',   [time[1], high[1]], lookahead=barmerge.lookahead_on)
[monthlyl_time, monthlyl_open] = request.security(syminfo.tickerid, 'M',   [time[1], low[1]],  lookahead=barmerge.lookahead_on)

[quarterly_time, quarterly_open]   = request.security(syminfo.tickerid, '3M',  [time, open],       lookahead=barmerge.lookahead_on)
[quarterlyh_time, quarterlyh_open] = request.security(syminfo.tickerid, '3M',  [time[1], high[1]], lookahead=barmerge.lookahead_on)
[quarterlyl_time, quarterlyl_open] = request.security(syminfo.tickerid, '3M',  [time[1], low[1]],  lookahead=barmerge.lookahead_on)

[yearly_time, yearly_open]     = request.security(syminfo.tickerid, '12M', [time, open],       lookahead=barmerge.lookahead_on)
[yearlyh_time, yearlyh_open]   = request.security(syminfo.tickerid, '12M', [time, high],       lookahead=barmerge.lookahead_on)
[yearlyl_time, yearlyl_open]   = request.security(syminfo.tickerid, '12M', [time, low],        lookahead=barmerge.lookahead_on)

[intra_time, intra_open]   = request.security(syminfo.tickerid, '240', [time, open],       lookahead=barmerge.lookahead_on)
[intrah_time, intrah_open] = request.security(syminfo.tickerid, '240', [time[1], high[1]], lookahead=barmerge.lookahead_on)
[intral_time, intral_open] = request.security(syminfo.tickerid, '240', [time[1], low[1]],  lookahead=barmerge.lookahead_on)

// ---------------------------------------------------------------
// KEY LEVELS — INPUTS
// ---------------------------------------------------------------
var is_intra_enabled        = input.bool(defval=false, title='Open',     group='4H',           inline='4H')
var is_intrarange_enabled   = input.bool(defval=false, title='Prev H/L', group='4H',           inline='4H')
var is_intram_enabled       = input.bool(defval=false, title='Prev Mid',  group='4H',          inline='4H')
IntraTextType               = input.bool(defval=false, title='ShortHand', group='4H',          inline='4Hsh')
intra_invalidate_on_close   = input.bool(defval=false, title='Hide Prev 4H H/L if 15m Candle Closes Beyond Level', group='4H',
     tooltip='When ON: if a 15m candle closes above the Prev 4H High or below the Prev 4H Low, that level is removed from the chart.')

var is_daily_enabled        = input.bool(defval=true,  title='Open',     group='Daily',        inline='Daily')
var is_dailyrange_enabled   = input.bool(defval=false, title='Prev H/L', group='Daily',        inline='Daily')
var is_dailym_enabled       = input.bool(defval=false, title='Prev Mid',  group='Daily',       inline='Daily')
DailyTextType               = input.bool(defval=false, title='ShortHand', group='Daily',       inline='Dailysh')

var is_monday_enabled       = input.bool(defval=true,  title='Range',    group='Monday Range', inline='Monday')
var is_monday_mid           = input.bool(defval=true,  title='Mid',      group='Monday Range', inline='Monday')
var untested_monday         = false
MondayTextType              = input.bool(defval=false, title='ShortHand', group='Monday Range', inline='Mondaysh')

var is_weekly_enabled       = input.bool(defval=true,  title='Open',     group='Weekly',       inline='Weekly')
var is_weeklyrange_enabled  = input.bool(defval=true,  title='Prev H/L', group='Weekly',       inline='Weekly')
var is_weekly_mid           = input.bool(defval=true,  title='Prev Mid',  group='Weekly',      inline='Weekly')
WeeklyTextType              = input.bool(defval=false, title='ShortHand', group='Weekly',      inline='Weeklysh')

var is_monthly_enabled      = input.bool(defval=true,  title='Open',     group='Monthly',      inline='Monthly')
var is_monthlyrange_enabled = input.bool(defval=true,  title='Prev H/L', group='Monthly',      inline='Monthly')
var is_monthly_mid          = input.bool(defval=true,  title='Prev Mid',  group='Monthly',     inline='Monthly')
MonthlyTextType             = input.bool(defval=false, title='ShortHand', group='Monthly',     inline='Monthlysh')

var is_quarterly_enabled      = input.bool(defval=true,  title='Open',     group='Quarterly',  inline='Quarterly')
var is_quarterlyrange_enabled = input.bool(defval=false, title='Prev H/L', group='Quarterly',  inline='Quarterly')
var is_quarterly_mid          = input.bool(defval=true,  title='Prev Mid',  group='Quarterly', inline='Quarterly')
QuarterlyTextType             = input.bool(defval=false, title='ShortHand', group='Quarterly', inline='Quarterlysh')

var is_yearly_enabled       = input.bool(defval=true,  title='Open',        group='Yearly',    inline='Yearly')
var is_yearlyrange_enabled  = input.bool(defval=false, title='Current H/L', group='Yearly',    inline='Yearly')
var is_yearly_mid           = input.bool(defval=true,  title='Mid',         group='Yearly',    inline='Yearly')
YearlyTextType              = input.bool(defval=false, title='ShortHand',   group='Yearly',    inline='Yearlysh')

// FX Sessions — H/L range toggles + NEW individual Open line toggles
var is_londonrange_enabled  = input.bool(defval=false, title='London Range',     group='FX Sessions', inline='FX')
var is_london_open_enabled  = input.bool(defval=false, title='London Open',      group='FX Sessions', inline='FX')
var is_usrange_enabled      = input.bool(defval=false, title='New York Range',   group='FX Sessions', inline='FX2')
var is_us_open_enabled      = input.bool(defval=false, title='New York Open',    group='FX Sessions', inline='FX2')
var is_asiarange_enabled    = input.bool(defval=false, title='Asia Range',       group='FX Sessions', inline='FX3')
var is_asia_open_enabled    = input.bool(defval=false, title='Asia Open',        group='FX Sessions', inline='FX3')
SessionTextType             = input.bool(defval=false, title='ShortHand',        group='FX Sessions', inline='FXColor')

// ---------------------------------------------------------------
// FX SESSION LEVEL INVALIDATION — NEW TOGGLE
// When enabled: if a 15m candle closes above a session High or
// below a session Low, that level is hidden from the chart.
// ---------------------------------------------------------------
fx_invalidate_on_close = input.bool(defval=false, title='Hide FX H/L if 15m Candle Closes Beyond Level',
     group='FX Sessions',
     tooltip='When ON: if a 15m candle closes above a session High or below a session Low, that level is removed from the chart.')

Londont = input.session("0800-1600", "London Session (London Time)")
USt     = input.session("0930-1700", "New York Session (New York Time)")
Asiat   = input.session("0900-1800", "Tokyo Session (Tokyo Time)")

DailyColor     = input.color(title='', defval=#08bcd4,      group='Daily',        inline='Dailysh')
MondayColor    = input.color(title='', defval=color.white,  group='Monday Range', inline='Mondaysh')
WeeklyColor    = input.color(title='', defval=#fffcbc,      group='Weekly',       inline='Weeklysh')
MonthlyColor   = input.color(title='', defval=#08d48c,      group='Monthly',      inline='Monthlysh')
YearlyColor    = input.color(title='', defval=color.red,    group='Yearly',       inline='Yearlysh')
quarterlyColor = input.color(title='', defval=color.red,    group='Quarterly',    inline='Quarterlysh')
IntraColor     = input.color(title='', defval=color.orange, group='4H',           inline='4Hsh')
LondonColor    = input.color(title='', defval=color.white,  group='FX Sessions',  inline='FXColor')
USColor        = input.color(title='', defval=color.white,  group='FX Sessions',  inline='FXColor')
AsiaColor      = input.color(title='', defval=color.white,  group='FX Sessions',  inline='FXColor')

// ---------------------------------------------------------------
// KEY LEVELS — LABEL STRINGS
// ---------------------------------------------------------------
var pdhtext   = GlobalTextType or DailyTextType     ? 'PDH'    : 'Prev Day High'
var pdltext   = GlobalTextType or DailyTextType     ? 'PDL'    : 'Prev Day Low'
var dotext    = GlobalTextType or DailyTextType     ? 'DO'     : 'Daily Open'
var pdmtext   = GlobalTextType or DailyTextType     ? 'PDM'    : 'Prev Day Mid'

var pwhtext   = GlobalTextType or WeeklyTextType    ? 'PWH'    : 'Prev Week High'
var pwltext   = GlobalTextType or WeeklyTextType    ? 'PWL'    : 'Prev Week Low'
var wotext    = GlobalTextType or WeeklyTextType    ? 'WO'     : 'Weekly Open'
var pwmtext   = GlobalTextType or WeeklyTextType    ? 'PWM'    : 'Prev Week Mid'

var pmhtext   = GlobalTextType or MonthlyTextType   ? 'PMH'    : 'Prev Month High'
var pmltext   = GlobalTextType or MonthlyTextType   ? 'PML'    : 'Prev Month Low'
var motext    = GlobalTextType or MonthlyTextType   ? 'MO'     : 'Monthly Open'
var pmmtext   = GlobalTextType or MonthlyTextType   ? 'PMM'    : 'Prev Month Mid'

var pqhtext   = GlobalTextType or QuarterlyTextType ? 'PQH'    : 'Prev Quarter High'
var pqltext   = GlobalTextType or QuarterlyTextType ? 'PQL'    : 'Prev Quarter Low'
var qotext    = GlobalTextType or QuarterlyTextType ? 'QO'     : 'Quarterly Open'
var pqmtext   = GlobalTextType or QuarterlyTextType ? 'PQM'    : 'Prev Quarter Mid'

var cyhtext   = GlobalTextType or YearlyTextType    ? 'CYH'    : 'Current Year High'
var cyltext   = GlobalTextType or YearlyTextType    ? 'CYL'    : 'Current Year Low'
var yotext    = GlobalTextType or YearlyTextType    ? 'YO'     : 'Yearly Open'
var cymtext   = GlobalTextType or YearlyTextType    ? 'CYM'    : 'Current Year Mid'

var pihtext   = GlobalTextType or IntraTextType     ? 'P-4H-H' : 'Prev 4H High'
var piltext   = GlobalTextType or IntraTextType     ? 'P-4H-L' : 'Prev 4H Low'
var iotext    = GlobalTextType or IntraTextType     ? '4H-O'   : '4H Open'
var pimtext   = GlobalTextType or IntraTextType     ? 'P-4H-M' : 'Prev 4H Mid'

var pmonhtext = GlobalTextType or MondayTextType    ? 'MDAY-H' : 'Monday High'
var pmonltext = GlobalTextType or MondayTextType    ? 'MDAY-L' : 'Monday Low'
var pmonmtext = GlobalTextType or MondayTextType    ? 'MDAY-M' : 'Monday Mid'

var lhtext    = GlobalTextType or SessionTextType   ? 'Lon-H'  : 'London High'
var lltext    = GlobalTextType or SessionTextType   ? 'Lon-L'  : 'London Low'
var lotext    = GlobalTextType or SessionTextType   ? 'Lon-O'  : 'London Open'

var ushtext   = GlobalTextType or SessionTextType   ? 'NY-H'   : 'New York High'
var usltext   = GlobalTextType or SessionTextType   ? 'NY-L'   : 'New York Low'
var usotext   = GlobalTextType or SessionTextType   ? 'NY-O'   : 'New York Open'

var asiahtext = GlobalTextType or SessionTextType   ? 'AS-H'   : 'Asia High'
var asialtext = GlobalTextType or SessionTextType   ? 'AS-L'   : 'Asia Low'
var asiaotext = GlobalTextType or SessionTextType   ? 'AS-O'   : 'Asia Open'

if globalcoloring
    DailyColor     := GlobalColor
    MondayColor    := GlobalColor
    WeeklyColor    := GlobalColor
    MonthlyColor   := GlobalColor
    YearlyColor    := GlobalColor
    quarterlyColor := GlobalColor
    IntraColor     := GlobalColor

if weekly_time != weekly_time[1]
    untested_monday := false

if is_monday_enabled and not untested_monday
    untested_monday := true
    monday_time     := daily_time
    monday_high     := cdailyh_open
    monday_low      := cdailyl_open

linewidthint = 1
if linesize == 'Medium'
    linewidthint := 2
else if linesize == 'Large'
    linewidthint := 3

var DEFAULT_LINE_WIDTH = linewidthint
var DEFAULT_TAIL_WIDTH = linewidthint

fontsize = size.small
if labelsize == 'Medium'
    fontsize := size.normal
else if labelsize == 'Large'
    fontsize := size.large

linestyles = line.style_solid
if linestyle == 'Dashed'
    linestyles := line.style_dashed
else if linestyle == 'Dotted'
    linestyles := line.style_dotted

var DEFAULT_LABEL_SIZE   = fontsize
var DEFAULT_LABEL_STYLE  = label.style_none
var DEFAULT_EXTEND_RIGHT = distanceright

London = time(timeframe.period, Londont, "Europe/London")
US     = time(timeframe.period, USt,     "America/New_York")
Asia   = time(timeframe.period, Asiat,   "Asia/Tokyo")

var clondonhigh    = 0.0
var clondonlow     = close
var londontime     = time
var flondonhigh    = 0.0
var flondonlow     = 0.0
var flondonopen    = 0.0
var onelondonfalse = false

if not na(London)
    if high > clondonhigh
        clondonhigh := high
    if low < clondonlow
        clondonlow := low
    if onelondonfalse
        londontime  := time
        flondonopen := open
    flondonhigh    := clondonhigh
    flondonlow     := clondonlow
    onelondonfalse := false
else
    if not onelondonfalse
        flondonhigh := clondonhigh
        flondonlow  := clondonlow
    onelondonfalse := true
    clondonhigh    := 0.0
    clondonlow     := close

var cushigh    = 0.0
var cuslow     = close
var ustime     = time
var fushigh    = 0.0
var fuslow     = 0.0
var fusopen    = 0.0
var oneusfalse = false

if not na(US)
    if high > cushigh
        cushigh := high
    if low < cuslow
        cuslow := low
    if oneusfalse
        ustime  := time
        fusopen := open
    fushigh    := cushigh
    fuslow     := cuslow
    oneusfalse := false
else
    if not oneusfalse
        fushigh := cushigh
        fuslow  := cuslow
    oneusfalse := true
    cushigh    := 0.0
    cuslow     := close

var casiahigh    = 0.0
var casialow     = close
var asiatime     = time
var fasiahigh    = 0.0
var fasialow     = 0.0
var fasiaopen    = 0.0
var oneasiafalse = false

if not na(Asia)
    if high > casiahigh
        casiahigh := high
    if low < casialow
        casialow := low
    if oneasiafalse
        asiatime  := time
        fasiaopen := open
    fasiahigh    := casiahigh
    fasialow     := casialow
    oneasiafalse := false
else
    if not oneasiafalse
        fasiahigh := casiahigh
        fasialow  := casialow
    oneasiafalse := true
    casiahigh    := 0.0
    casialow     := close

// ---------------------------------------------------------------
// FX SESSION INVALIDATION — 15M CLOSE CHECKS
// Pull the most recent 15m close to check against session H/L.
// ---------------------------------------------------------------
close_15m = request.security(syminfo.tickerid, '15', close, lookahead=barmerge.lookahead_off)

// London: track if a 15m close has broken above the high or below the low
var london_high_invalidated = false
var london_low_invalidated  = false

// Reset invalidation when the stored levels refresh (new session)
if flondonhigh != flondonhigh[1] or flondonlow != flondonlow[1]
    london_high_invalidated := false
    london_low_invalidated  := false

if fx_invalidate_on_close and not na(close_15m) and flondonhigh != 0.0
    if close_15m > flondonhigh
        london_high_invalidated := true
    if close_15m < flondonlow
        london_low_invalidated  := true

// New York: same logic
var us_high_invalidated = false
var us_low_invalidated  = false

if fushigh != fushigh[1] or fuslow != fuslow[1]
    us_high_invalidated := false
    us_low_invalidated  := false

if fx_invalidate_on_close and not na(close_15m) and fushigh != 0.0
    if close_15m > fushigh
        us_high_invalidated := true
    if close_15m < fuslow
        us_low_invalidated  := true

// Asia: same logic
var asia_high_invalidated = false
var asia_low_invalidated  = false

if fasiahigh != fasiahigh[1] or fasialow != fasialow[1]
    asia_high_invalidated := false
    asia_low_invalidated  := false

if fx_invalidate_on_close and not na(close_15m) and fasiahigh != 0.0
    if close_15m > fasiahigh
        asia_high_invalidated := true
    if close_15m < fasialow
        asia_low_invalidated  := true

// ---------------------------------------------------------------
// 4H LEVEL INVALIDATION — 15M CLOSE CHECKS
// ---------------------------------------------------------------
var intra_high_invalidated = false
var intra_low_invalidated  = false

// Reset when the 4H prev H/L values change (new 4H bar)
if intrah_open != intrah_open[1] or intral_open != intral_open[1]
    intra_high_invalidated := false
    intra_low_invalidated  := false

if intra_invalidate_on_close and not na(close_15m)
    if close_15m > intrah_open
        intra_high_invalidated := true
    if close_15m < intral_open
        intra_low_invalidated  := true

// ---------------------------------------------------------------
// KEY LEVELS — PLOTTING
// ---------------------------------------------------------------
var pricearray = array.new_float(0)
var labelarray = array.new_label(0)

f_LevelMerge(pricearray, labelarray, currentprice, currentlabel, currentcolor) =>
    if array.includes(pricearray, currentprice)
        whichindex = array.indexof(pricearray, currentprice)
        labelhold  = array.get(labelarray, whichindex)
        label.set_text(labelhold, label.get_text(currentlabel) + ' / ' + label.get_text(labelhold))
        label.set_text(currentlabel, '')
        label.set_textcolor(labelhold, currentcolor)
    else
        array.push(pricearray, currentprice)
        array.push(labelarray, currentlabel)

var can_show_daily   = is_daily_enabled and timeframe.isintraday
var can_show_weekly  = is_weekly_enabled and not timeframe.isweekly and not timeframe.ismonthly
var can_show_monthly = is_monthly_enabled and not timeframe.ismonthly

get_limit_right(bars) =>
    timenow + (time - time[1]) * bars

if barstate.islast
    is_weekly_open  = dayofweek == dayofweek.monday
    is_monthly_open = dayofmonth == 1
    can_draw_daily  = (is_weekly_enabled ? not is_weekly_open : true) and (is_monthly_enabled ? not is_monthly_open : true)
    can_draw_weekly = is_monthly_enabled ? not (is_monthly_open and is_weekly_open) : true
    can_draw_intra  = is_intra_enabled
    can_draw_intrah = is_intrarange_enabled
    can_draw_intral = is_intrarange_enabled
    can_draw_intram = is_intram_enabled

    pricearray := array.new_float(0)
    labelarray := array.new_label(0)

    if is_londonrange_enabled
        london_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            londontime := get_limit_right(radistance)

        // High — only draw if not invalidated
        show_lon_high = not (fx_invalidate_on_close and london_high_invalidated)
        show_lon_low  = not (fx_invalidate_on_close and london_low_invalidated)

        var londonh_line  = line.new(x1=londontime, x2=london_limit_right, y1=flondonhigh, y2=flondonhigh, color=LondonColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var londonl_line  = line.new(x1=londontime, x2=london_limit_right, y1=flondonlow,  y2=flondonlow,  color=LondonColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var londonh_label = label.new(x=london_limit_right, y=flondonhigh, text=lhtext, style=DEFAULT_LABEL_STYLE, textcolor=LondonColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        var londonl_label = label.new(x=london_limit_right, y=flondonlow,  text=lltext, style=DEFAULT_LABEL_STYLE, textcolor=LondonColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)

        line.set_xy1(londonh_line, londontime, flondonhigh)
        line.set_xy2(londonh_line, london_limit_right, flondonhigh)
        label.set_xy(londonh_label, london_limit_right, flondonhigh)
        line.set_color(londonh_line, show_lon_high ? LondonColor : color.new(LondonColor, 100))
        label.set_text(londonh_label, show_lon_high ? lhtext : '')
        label.set_textcolor(londonh_label, show_lon_high ? LondonColor : color.new(LondonColor, 100))

        line.set_xy1(londonl_line, londontime, flondonlow)
        line.set_xy2(londonl_line, london_limit_right, flondonlow)
        label.set_xy(londonl_label, london_limit_right, flondonlow)
        line.set_color(londonl_line, show_lon_low ? LondonColor : color.new(LondonColor, 100))
        label.set_text(londonl_label, show_lon_low ? lltext : '')
        label.set_textcolor(londonl_label, show_lon_low ? LondonColor : color.new(LondonColor, 100))

        if mergebool
            if show_lon_high
                f_LevelMerge(pricearray, labelarray, flondonhigh, londonh_label, LondonColor)
            if show_lon_low
                f_LevelMerge(pricearray, labelarray, flondonlow,  londonl_label, LondonColor)

    if is_london_open_enabled
        london_open_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            londontime := get_limit_right(radistance)
        var londono_line  = line.new(x1=londontime, x2=london_open_limit_right, y1=flondonopen, y2=flondonopen, color=LondonColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var londono_label = label.new(x=london_open_limit_right, y=flondonopen, text=lotext, style=DEFAULT_LABEL_STYLE, textcolor=LondonColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(londono_line, londontime, flondonopen)
        line.set_xy2(londono_line, london_open_limit_right, flondonopen)
        label.set_xy(londono_label, london_open_limit_right, flondonopen)
        label.set_text(londono_label, lotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, flondonopen, londono_label, LondonColor)

    if is_usrange_enabled
        us_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            ustime := get_limit_right(radistance)

        show_us_high = not (fx_invalidate_on_close and us_high_invalidated)
        show_us_low  = not (fx_invalidate_on_close and us_low_invalidated)

        var ush_line  = line.new(x1=ustime, x2=us_limit_right, y1=fushigh, y2=fushigh, color=USColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var usl_line  = line.new(x1=ustime, x2=us_limit_right, y1=fuslow,  y2=fuslow,  color=USColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var ush_label = label.new(x=us_limit_right, y=fushigh, text=ushtext, style=DEFAULT_LABEL_STYLE, textcolor=USColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        var usl_label = label.new(x=us_limit_right, y=fuslow,  text=usltext, style=DEFAULT_LABEL_STYLE, textcolor=USColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)

        line.set_xy1(ush_line, ustime, fushigh)
        line.set_xy2(ush_line, us_limit_right, fushigh)
        label.set_xy(ush_label, us_limit_right, fushigh)
        line.set_color(ush_line, show_us_high ? USColor : color.new(USColor, 100))
        label.set_text(ush_label, show_us_high ? ushtext : '')
        label.set_textcolor(ush_label, show_us_high ? USColor : color.new(USColor, 100))

        line.set_xy1(usl_line, ustime, fuslow)
        line.set_xy2(usl_line, us_limit_right, fuslow)
        label.set_xy(usl_label, us_limit_right, fuslow)
        line.set_color(usl_line, show_us_low ? USColor : color.new(USColor, 100))
        label.set_text(usl_label, show_us_low ? usltext : '')
        label.set_textcolor(usl_label, show_us_low ? USColor : color.new(USColor, 100))

        if mergebool
            if show_us_high
                f_LevelMerge(pricearray, labelarray, fushigh, ush_label, USColor)
            if show_us_low
                f_LevelMerge(pricearray, labelarray, fuslow,  usl_label, USColor)

    if is_us_open_enabled
        us_open_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            ustime := get_limit_right(radistance)
        var uso_line  = line.new(x1=ustime, x2=us_open_limit_right, y1=fusopen, y2=fusopen, color=USColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var uso_label = label.new(x=us_open_limit_right, y=fusopen, text=usotext, style=DEFAULT_LABEL_STYLE, textcolor=USColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(uso_line, ustime, fusopen)
        line.set_xy2(uso_line, us_open_limit_right, fusopen)
        label.set_xy(uso_label, us_open_limit_right, fusopen)
        label.set_text(uso_label, usotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, fusopen, uso_label, USColor)

    if is_asiarange_enabled
        asia_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            asiatime := get_limit_right(radistance)

        show_asia_high = not (fx_invalidate_on_close and asia_high_invalidated)
        show_asia_low  = not (fx_invalidate_on_close and asia_low_invalidated)

        var asiah_line  = line.new(x1=asiatime, x2=asia_limit_right, y1=fasiahigh, y2=fasiahigh, color=AsiaColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var asial_line  = line.new(x1=asiatime, x2=asia_limit_right, y1=fasialow,  y2=fasialow,  color=AsiaColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var asiah_label = label.new(x=asia_limit_right, y=fasiahigh, text=asiahtext, style=DEFAULT_LABEL_STYLE, textcolor=AsiaColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        var asial_label = label.new(x=asia_limit_right, y=fasialow,  text=asialtext, style=DEFAULT_LABEL_STYLE, textcolor=AsiaColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)

        line.set_xy1(asiah_line, asiatime, fasiahigh)
        line.set_xy2(asiah_line, asia_limit_right, fasiahigh)
        label.set_xy(asiah_label, asia_limit_right, fasiahigh)
        line.set_color(asiah_line, show_asia_high ? AsiaColor : color.new(AsiaColor, 100))
        label.set_text(asiah_label, show_asia_high ? asiahtext : '')
        label.set_textcolor(asiah_label, show_asia_high ? AsiaColor : color.new(AsiaColor, 100))

        line.set_xy1(asial_line, asiatime, fasialow)
        line.set_xy2(asial_line, asia_limit_right, fasialow)
        label.set_xy(asial_label, asia_limit_right, fasialow)
        line.set_color(asial_line, show_asia_low ? AsiaColor : color.new(AsiaColor, 100))
        label.set_text(asial_label, show_asia_low ? asialtext : '')
        label.set_textcolor(asial_label, show_asia_low ? AsiaColor : color.new(AsiaColor, 100))

        if mergebool
            if show_asia_high
                f_LevelMerge(pricearray, labelarray, fasiahigh, asiah_label, AsiaColor)
            if show_asia_low
                f_LevelMerge(pricearray, labelarray, fasialow,  asial_label, AsiaColor)

    if is_asia_open_enabled
        asia_open_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            asiatime := get_limit_right(radistance)
        var asiao_line  = line.new(x1=asiatime, x2=asia_open_limit_right, y1=fasiaopen, y2=fasiaopen, color=AsiaColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var asiao_label = label.new(x=asia_open_limit_right, y=fasiaopen, text=asiaotext, style=DEFAULT_LABEL_STYLE, textcolor=AsiaColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(asiao_line, asiatime, fasiaopen)
        line.set_xy2(asiao_line, asia_open_limit_right, fasiaopen)
        label.set_xy(asiao_label, asia_open_limit_right, fasiaopen)
        label.set_text(asiao_label, asiaotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, fasiaopen, asiao_label, AsiaColor)

    if can_draw_intra
        intra_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            intra_time := get_limit_right(radistance)
        var intra_line  = line.new(x1=intra_time, x2=intra_limit_right, y1=intra_open, y2=intra_open, color=IntraColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var intra_label = label.new(x=intra_limit_right, y=intra_open, text=iotext, style=DEFAULT_LABEL_STYLE, textcolor=IntraColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(intra_line, intra_time, intra_open)
        line.set_xy2(intra_line, intra_limit_right, intra_open)
        label.set_xy(intra_label, intra_limit_right, intra_open)
        label.set_text(intra_label, iotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, intra_open, intra_label, IntraColor)

    if can_draw_intrah
        intrah_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            intrah_time := get_limit_right(radistance)
        var intrah_line  = line.new(x1=intrah_time, x2=intrah_limit_right, y1=intrah_open, y2=intrah_open, color=IntraColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var intrah_label = label.new(x=intrah_limit_right, y=intrah_open, text=pihtext, style=DEFAULT_LABEL_STYLE, textcolor=IntraColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)

        show_intrah = not (intra_invalidate_on_close and intra_high_invalidated)
        line.set_xy1(intrah_line, intrah_time, intrah_open)
        line.set_xy2(intrah_line, intrah_limit_right, intrah_open)
        label.set_xy(intrah_label, intrah_limit_right, intrah_open)
        line.set_color(intrah_line, show_intrah ? IntraColor : color.new(IntraColor, 100))
        label.set_text(intrah_label, show_intrah ? pihtext : '')
        label.set_textcolor(intrah_label, show_intrah ? IntraColor : color.new(IntraColor, 100))
        if mergebool and show_intrah
            f_LevelMerge(pricearray, labelarray, intrah_open, intrah_label, IntraColor)

    if can_draw_intral
        intral_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            intral_time := get_limit_right(radistance)
        var intral_line  = line.new(x1=intral_time, x2=intral_limit_right, y1=intral_open, y2=intral_open, color=IntraColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var intral_label = label.new(x=intral_limit_right, y=intral_open, text=piltext, style=DEFAULT_LABEL_STYLE, textcolor=IntraColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)

        show_intral = not (intra_invalidate_on_close and intra_low_invalidated)
        line.set_xy1(intral_line, intral_time, intral_open)
        line.set_xy2(intral_line, intral_limit_right, intral_open)
        label.set_xy(intral_label, intral_limit_right, intral_open)
        line.set_color(intral_line, show_intral ? IntraColor : color.new(IntraColor, 100))
        label.set_text(intral_label, show_intral ? piltext : '')
        label.set_textcolor(intral_label, show_intral ? IntraColor : color.new(IntraColor, 100))
        if mergebool and show_intral
            f_LevelMerge(pricearray, labelarray, intral_open, intral_label, IntraColor)

    if can_draw_intram
        intram_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        intram_time        = intrah_time
        intram_open        = (intral_open + intrah_open) / 2
        if displayStyle == 'Right Anchored'
            intram_time := get_limit_right(radistance)
        var intram_line  = line.new(x1=intram_time, x2=intram_limit_right, y1=intram_open, y2=intram_open, color=IntraColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var intram_label = label.new(x=intram_limit_right, y=intram_open, text=pimtext, style=DEFAULT_LABEL_STYLE, textcolor=IntraColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(intram_line, intram_time, intram_open)
        line.set_xy2(intram_line, intram_limit_right, intram_open)
        label.set_xy(intram_label, intram_limit_right, intram_open)
        label.set_text(intram_label, pimtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, intram_open, intram_label, IntraColor)

    if is_monday_enabled
        monday_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            monday_time := get_limit_right(radistance)
        var monday_line  = line.new(x1=monday_time, x2=monday_limit_right, y1=monday_high, y2=monday_high, color=MondayColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monday_label = label.new(x=monday_limit_right, y=monday_high, text=pmonhtext, style=DEFAULT_LABEL_STYLE, textcolor=MondayColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(monday_line, monday_time, monday_high)
        line.set_xy2(monday_line, monday_limit_right, monday_high)
        label.set_xy(monday_label, monday_limit_right, monday_high)
        label.set_text(monday_label, pmonhtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, monday_high, monday_label, MondayColor)

        var monday_low_line  = line.new(x1=monday_time, x2=monday_limit_right, y1=monday_low, y2=monday_low, color=MondayColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monday_low_label = label.new(x=monday_limit_right, y=monday_low, text=pmonltext, style=DEFAULT_LABEL_STYLE, textcolor=MondayColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(monday_low_line, monday_time, monday_low)
        line.set_xy2(monday_low_line, monday_limit_right, monday_low)
        label.set_xy(monday_low_label, monday_limit_right, monday_low)
        label.set_text(monday_low_label, pmonltext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, monday_low, monday_low_label, MondayColor)

    if is_monday_mid
        mondaym_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        mondaym_open        = (monday_high + monday_low) / 2
        if displayStyle == 'Right Anchored'
            monday_time := get_limit_right(radistance)
        var mondaym_line  = line.new(x1=monday_time, x2=mondaym_limit_right, y1=mondaym_open, y2=mondaym_open, color=MondayColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var mondaym_label = label.new(x=mondaym_limit_right, y=mondaym_open, text=pmonmtext, style=DEFAULT_LABEL_STYLE, textcolor=MondayColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(mondaym_line, monday_time, mondaym_open)
        line.set_xy2(mondaym_line, mondaym_limit_right, mondaym_open)
        label.set_xy(mondaym_label, mondaym_limit_right, mondaym_open)
        label.set_text(mondaym_label, pmonmtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, mondaym_open, mondaym_label, MondayColor)

    if is_daily_enabled
        daily_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            daily_time := get_limit_right(radistance)
        var daily_line  = line.new(x1=daily_time, x2=daily_limit_right, y1=daily_open, y2=daily_open, color=DailyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var daily_label = label.new(x=daily_limit_right, y=daily_open, text=dotext, style=DEFAULT_LABEL_STYLE, textcolor=DailyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(daily_line, daily_time, daily_open)
        line.set_xy2(daily_line, daily_limit_right, daily_open)
        label.set_xy(daily_label, daily_limit_right, daily_open)
        label.set_text(daily_label, dotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, daily_open, daily_label, DailyColor)

    if is_dailyrange_enabled
        dailyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            dailyh_time := get_limit_right(radistance)
        var dailyh_line  = line.new(x1=dailyh_time, x2=dailyh_limit_right, y1=dailyh_open, y2=dailyh_open, color=DailyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var dailyh_label = label.new(x=dailyh_limit_right, y=dailyh_open, text=pdhtext, style=DEFAULT_LABEL_STYLE, textcolor=DailyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(dailyh_line, dailyh_time, dailyh_open)
        line.set_xy2(dailyh_line, dailyh_limit_right, dailyh_open)
        label.set_xy(dailyh_label, dailyh_limit_right, dailyh_open)
        label.set_text(dailyh_label, pdhtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, dailyh_open, dailyh_label, DailyColor)

        dailyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            dailyl_time := get_limit_right(radistance)
        var dailyl_line  = line.new(x1=dailyl_time, x2=dailyl_limit_right, y1=dailyl_open, y2=dailyl_open, color=DailyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var dailyl_label = label.new(x=dailyl_limit_right, y=dailyl_open, text=pdltext, style=DEFAULT_LABEL_STYLE, textcolor=DailyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(dailyl_line, dailyl_time, dailyl_open)
        line.set_xy2(dailyl_line, dailyl_limit_right, dailyl_open)
        label.set_xy(dailyl_label, dailyl_limit_right, dailyl_open)
        label.set_text(dailyl_label, pdltext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, dailyl_open, dailyl_label, DailyColor)

    if is_dailym_enabled
        dailym_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        dailym_time        = dailyh_time
        dailym_open        = (dailyl_open + dailyh_open) / 2
        if displayStyle == 'Right Anchored'
            dailym_time := get_limit_right(radistance)
        var dailym_line  = line.new(x1=dailym_time, x2=dailym_limit_right, y1=dailym_open, y2=dailym_open, color=DailyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var dailym_label = label.new(x=dailym_limit_right, y=dailym_open, text=pdmtext, style=DEFAULT_LABEL_STYLE, textcolor=DailyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(dailym_line, dailym_time, dailym_open)
        line.set_xy2(dailym_line, dailym_limit_right, dailym_open)
        label.set_xy(dailym_label, dailym_limit_right, dailym_open)
        label.set_text(dailym_label, pdmtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, dailym_open, dailym_label, DailyColor)

    if is_weekly_enabled
        weekly_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        cweekly_time       = weekly_time
        if displayStyle == 'Right Anchored'
            cweekly_time := get_limit_right(radistance)
        var weekly_line  = line.new(x1=cweekly_time, x2=weekly_limit_right, y1=weekly_open, y2=weekly_open, color=WeeklyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var weekly_label = label.new(x=weekly_limit_right, y=weekly_open, text=wotext, style=DEFAULT_LABEL_STYLE, textcolor=WeeklyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(weekly_line, cweekly_time, weekly_open)
        line.set_xy2(weekly_line, weekly_limit_right, weekly_open)
        label.set_xy(weekly_label, weekly_limit_right, weekly_open)
        label.set_text(weekly_label, wotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, weekly_open, weekly_label, WeeklyColor)

    if is_weeklyrange_enabled
        weeklyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            weeklyh_time := get_limit_right(radistance)
        var weeklyh_line  = line.new(x1=weeklyh_time, x2=weeklyh_limit_right, y1=weeklyh_open, y2=weeklyh_open, color=WeeklyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var weeklyh_label = label.new(x=weeklyh_limit_right, y=weeklyh_open, text=pwhtext, style=DEFAULT_LABEL_STYLE, textcolor=WeeklyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(weeklyh_line, weeklyh_time, weeklyh_open)
        line.set_xy2(weeklyh_line, weeklyh_limit_right, weeklyh_open)
        label.set_xy(weeklyh_label, weeklyh_limit_right, weeklyh_open)
        label.set_text(weeklyh_label, pwhtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, weeklyh_open, weeklyh_label, WeeklyColor)

        weeklyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            weeklyl_time := get_limit_right(radistance)
        var weeklyl_line  = line.new(x1=weeklyl_time, x2=weeklyl_limit_right, y1=weeklyl_open, y2=weeklyl_open, color=WeeklyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var weeklyl_label = label.new(x=weeklyl_limit_right, y=weeklyl_open, text=pwltext, style=DEFAULT_LABEL_STYLE, textcolor=WeeklyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(weeklyl_line, weeklyl_time, weeklyl_open)
        line.set_xy2(weeklyl_line, weeklyl_limit_right, weeklyl_open)
        label.set_xy(weeklyl_label, weeklyl_limit_right, weeklyl_open)
        label.set_text(weeklyl_label, pwltext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, weeklyl_open, weeklyl_label, WeeklyColor)

    if is_weekly_mid
        weeklym_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        weeklym_time        = weeklyh_time
        weeklym_open        = (weeklyl_open + weeklyh_open) / 2
        if displayStyle == 'Right Anchored'
            weeklym_time := get_limit_right(radistance)
        var weeklym_line  = line.new(x1=weeklym_time, x2=weeklym_limit_right, y1=weeklym_open, y2=weeklym_open, color=WeeklyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var weeklym_label = label.new(x=weeklym_limit_right, y=weeklym_open, text=pwmtext, style=DEFAULT_LABEL_STYLE, textcolor=WeeklyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(weeklym_line, weeklym_time, weeklym_open)
        line.set_xy2(weeklym_line, weeklym_limit_right, weeklym_open)
        label.set_xy(weeklym_label, weeklym_limit_right, weeklym_open)
        label.set_text(weeklym_label, pwmtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, weeklym_open, weeklym_label, WeeklyColor)

    if is_yearlyrange_enabled
        yearlyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            yearlyl_time := get_limit_right(radistance)
        var yearlyl_line  = line.new(x1=yearlyl_time, x2=yearlyl_limit_right, y1=yearlyl_open, y2=yearlyl_open, color=YearlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var yearlyl_label = label.new(x=yearlyl_limit_right, y=yearlyl_open, text=cyltext, style=DEFAULT_LABEL_STYLE, textcolor=YearlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(yearlyl_line, yearlyl_time, yearlyl_open)
        line.set_xy2(yearlyl_line, yearlyl_limit_right, yearlyl_open)
        label.set_xy(yearlyl_label, yearlyl_limit_right, yearlyl_open)
        label.set_text(yearlyl_label, cyltext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, yearlyl_open, yearlyl_label, YearlyColor)

        yearlyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            yearlyh_time := get_limit_right(radistance)
        var yearlyh_line  = line.new(x1=yearlyh_time, x2=yearlyh_limit_right, y1=yearlyh_open, y2=yearlyh_open, color=YearlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var yearlyh_label = label.new(x=yearlyh_limit_right, y=yearlyh_open, text=cyhtext, style=DEFAULT_LABEL_STYLE, textcolor=YearlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(yearlyh_line, yearlyh_time, yearlyh_open)
        line.set_xy2(yearlyh_line, yearlyh_limit_right, yearlyh_open)
        label.set_xy(yearlyh_label, yearlyh_limit_right, yearlyh_open)
        label.set_text(yearlyh_label, cyhtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, yearlyh_open, yearlyh_label, YearlyColor)

    if is_yearly_enabled
        yearly_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            yearly_time := get_limit_right(radistance)
        var yearly_line  = line.new(x1=yearly_time, x2=yearly_limit_right, y1=yearly_open, y2=yearly_open, color=YearlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var yearly_label = label.new(x=yearly_limit_right, y=yearly_open, text=yotext, style=DEFAULT_LABEL_STYLE, textcolor=YearlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(yearly_line, yearly_time, yearly_open)
        line.set_xy2(yearly_line, yearly_limit_right, yearly_open)
        label.set_xy(yearly_label, yearly_limit_right, yearly_open)
        label.set_text(yearly_label, yotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, yearly_open, yearly_label, YearlyColor)

    if is_yearly_mid
        yearlym_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        yearlym_time        = yearlyh_time
        yearlym_open        = (yearlyl_open + yearlyh_open) / 2
        if displayStyle == 'Right Anchored'
            yearlym_time := get_limit_right(radistance)
        var yearlym_line  = line.new(x1=yearlym_time, x2=yearlym_limit_right, y1=yearlym_open, y2=yearlym_open, color=YearlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var yearlym_label = label.new(x=yearlym_limit_right, y=yearlym_open, text=cymtext, style=DEFAULT_LABEL_STYLE, textcolor=YearlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(yearlym_line, yearlym_time, yearlym_open)
        line.set_xy2(yearlym_line, yearlym_limit_right, yearlym_open)
        label.set_xy(yearlym_label, yearlym_limit_right, yearlym_open)
        label.set_text(yearlym_label, cymtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, yearlym_open, yearlym_label, YearlyColor)

    if is_quarterly_enabled
        quarterly_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            quarterly_time := get_limit_right(radistance)
        var quarterly_line  = line.new(x1=quarterly_time, x2=quarterly_limit_right, y1=quarterly_open, y2=quarterly_open, color=quarterlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var quarterly_label = label.new(x=quarterly_limit_right, y=quarterly_open, text=qotext, style=DEFAULT_LABEL_STYLE, textcolor=quarterlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(quarterly_line, quarterly_time, quarterly_open)
        line.set_xy2(quarterly_line, quarterly_limit_right, quarterly_open)
        label.set_xy(quarterly_label, quarterly_limit_right, quarterly_open)
        label.set_text(quarterly_label, qotext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, quarterly_open, quarterly_label, quarterlyColor)

    if is_quarterlyrange_enabled
        quarterlyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            quarterlyh_time := get_limit_right(radistance)
        var quarterlyh_line  = line.new(x1=quarterlyh_time, x2=quarterlyh_limit_right, y1=quarterlyh_open, y2=quarterlyh_open, color=quarterlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var quarterlyh_label = label.new(x=quarterlyh_limit_right, y=quarterlyh_open, text=pqhtext, style=DEFAULT_LABEL_STYLE, textcolor=quarterlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(quarterlyh_line, quarterlyh_time, quarterlyh_open)
        line.set_xy2(quarterlyh_line, quarterlyh_limit_right, quarterlyh_open)
        label.set_xy(quarterlyh_label, quarterlyh_limit_right, quarterlyh_open)
        label.set_text(quarterlyh_label, pqhtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, quarterlyh_open, quarterlyh_label, quarterlyColor)

        quarterlyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            quarterlyl_time := get_limit_right(radistance)
        var quarterlyl_line  = line.new(x1=quarterlyl_time, x2=quarterlyl_limit_right, y1=quarterlyl_open, y2=quarterlyl_open, color=quarterlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var quarterlyl_label = label.new(x=quarterlyl_limit_right, y=quarterlyl_open, text=pqltext, style=DEFAULT_LABEL_STYLE, textcolor=quarterlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(quarterlyl_line, quarterlyl_time, quarterlyl_open)
        line.set_xy2(quarterlyl_line, quarterlyl_limit_right, quarterlyl_open)
        label.set_xy(quarterlyl_label, quarterlyl_limit_right, quarterlyl_open)
        label.set_text(quarterlyl_label, pqltext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, quarterlyl_open, quarterlyl_label, quarterlyColor)

    if is_quarterly_mid
        quarterlym_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        quarterlym_time        = quarterlyh_time
        quarterlym_open        = (quarterlyl_open + quarterlyh_open) / 2
        if displayStyle == 'Right Anchored'
            quarterlym_time := get_limit_right(radistance)
        var quarterlym_line  = line.new(x1=quarterlym_time, x2=quarterlym_limit_right, y1=quarterlym_open, y2=quarterlym_open, color=quarterlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var quarterlym_label = label.new(x=quarterlym_limit_right, y=quarterlym_open, text=pqmtext, style=DEFAULT_LABEL_STYLE, textcolor=quarterlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(quarterlym_line, quarterlym_time, quarterlym_open)
        line.set_xy2(quarterlym_line, quarterlym_limit_right, quarterlym_open)
        label.set_xy(quarterlym_label, quarterlym_limit_right, quarterlym_open)
        label.set_text(quarterlym_label, pqmtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, quarterlym_open, quarterlym_label, quarterlyColor)

    if is_monthlyrange_enabled
        monthlyl_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            monthlyl_time := get_limit_right(radistance)
        var monthlyl_line  = line.new(x1=monthlyl_time, x2=monthlyl_limit_right, y1=monthlyl_open, y2=monthlyl_open, color=MonthlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monthlyl_label = label.new(x=monthlyl_limit_right, y=monthlyl_open, text=pmltext, style=DEFAULT_LABEL_STYLE, textcolor=MonthlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(monthlyl_line, monthlyl_time, monthlyl_open)
        line.set_xy2(monthlyl_line, monthlyl_limit_right, monthlyl_open)
        label.set_xy(monthlyl_label, monthlyl_limit_right, monthlyl_open)
        label.set_text(monthlyl_label, pmltext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, monthlyl_open, monthlyl_label, MonthlyColor)

        monthlyh_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            monthlyh_time := get_limit_right(radistance)
        var monthlyh_line  = line.new(x1=monthlyh_time, x2=monthlyh_limit_right, y1=monthlyh_open, y2=monthlyh_open, color=MonthlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monthlyh_label = label.new(x=monthlyh_limit_right, y=monthlyh_open, text=pmhtext, style=DEFAULT_LABEL_STYLE, textcolor=MonthlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(monthlyh_line, monthlyl_time, monthlyh_open)
        line.set_xy2(monthlyh_line, monthlyh_limit_right, monthlyh_open)
        label.set_xy(monthlyh_label, monthlyh_limit_right, monthlyh_open)
        label.set_text(monthlyh_label, pmhtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, monthlyh_open, monthlyh_label, MonthlyColor)

    if is_monthly_mid
        monthlym_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        monthlym_time        = monthlyh_time
        monthlym_open        = (monthlyl_open + monthlyh_open) / 2
        if displayStyle == 'Right Anchored'
            monthlym_time := get_limit_right(radistance)
        var monthlym_line  = line.new(x1=monthlym_time, x2=monthlym_limit_right, y1=monthlym_open, y2=monthlym_open, color=MonthlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monthlym_label = label.new(x=monthlym_limit_right, y=monthlym_open, text=pmmtext, style=DEFAULT_LABEL_STYLE, textcolor=MonthlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(monthlym_line, monthlym_time, monthlym_open)
        line.set_xy2(monthlym_line, monthlym_limit_right, monthlym_open)
        label.set_xy(monthlym_label, monthlym_limit_right, monthlym_open)
        label.set_text(monthlym_label, pmmtext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, monthlym_open, monthlym_label, MonthlyColor)

    if is_monthly_enabled
        monthly_limit_right = get_limit_right(DEFAULT_EXTEND_RIGHT)
        if displayStyle == 'Right Anchored'
            monthly_time := get_limit_right(radistance)
        var monthlyLine  = line.new(x1=monthly_time, x2=monthly_limit_right, y1=monthly_open, y2=monthly_open, color=MonthlyColor, width=DEFAULT_LINE_WIDTH, xloc=xloc.bar_time, style=linestyles)
        var monthlyLabel = label.new(x=monthly_limit_right, y=monthly_open, text=motext, style=DEFAULT_LABEL_STYLE, textcolor=MonthlyColor, size=DEFAULT_LABEL_SIZE, xloc=xloc.bar_time)
        line.set_xy1(monthlyLine, monthly_time, monthly_open)
        line.set_xy2(monthlyLine, monthly_limit_right, monthly_open)
        label.set_xy(monthlyLabel, monthly_limit_right, monthly_open)
        label.set_text(monthlyLabel, motext)
        if mergebool
            f_LevelMerge(pricearray, labelarray, monthly_open, monthlyLabel, MonthlyColor)

        if timeframe.isweekly and dayofweek(monthly_time) != dayofweek.monday
            line.set_x1(monthlyLine, monthly_time - (weekly_time - weekly_time[1]))
````
