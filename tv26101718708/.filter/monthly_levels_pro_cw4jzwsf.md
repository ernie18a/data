# Monthly Levels Pro

- url: https://www.tradingview.com/script/cw4JZWsF-Monthly-Levels-Pro/
- type: indicator
- pine_id: PUB;22a9b0089a24413ea015baa402e46150
- version: 1.0

## Description

Monthly Levels Pro — Complete Guide
What It Does
Monthly Levels Pro is a TradingView overlay indicator that automatically plots the high and low of each previous month (and week) as horizontal lines on your chart. The idea is simple but powerful: the high and low of a previous month are significant price levels that traders watch. When price approaches them, they often act as support or resistance. This indicator tracks those levels, shows you how price has interacted with them, and gives you a dashboard showing how far away you currently are from each one.

Core Concepts
Monthly Levels
Every time a new month begins, the indicator saves the previous month's high and low. It stores up to 12 months of history. Each saved month is called a slot — PM1 is the most recent previous month, PM2 is two months ago, and so on up to PM12. The current developing month is called CM — its high and low update in real time as the month progresses.
Weekly Levels
The same concept applies on a weekly basis. PW1 is last week, PW2 is two weeks ago, and so on up to PW4. CW is the current developing week.

How Things Are Calculated
High & Low Tracking
On every bar, the indicator checks whether a new month (or week) has started. When it detects a new month, it saves the previous month's final high and low into arrays, then resets the current month tracker. Within a month, it continuously updates the running high and low using math.max and math.min.
VWAP
Each month and week also tracks a Volume Weighted Average Price. This is calculated by accumulating volume × HLC3 (the average of high, low, and close) and dividing by total volume over the period. This gives a volume-weighted mean price for the entire month or week.
50% Level
The midpoint between each period's high and low. Calculated as (high + low) / 2. Simple but often acts as a magnet for price.
Break Detection
The indicator watches every bar to see if price has crossed through a stored level. You can choose between two modes — wick-based (the default, where any wick through the level counts as a break) or close-based (requires the candle to actually close beyond the level). Each time a level is broken, a counter increments. The break price and time are recorded so a marker can be placed on the chart.
Touch Detection
Separately from breaks, the indicator counts how many times price has touched a level — meaning the wick reached it or exceeded it. A level with many touches but no breaks is considered strong.
Week Detection
New weeks are detected by comparing the day of week between bars. If today's day of week number is less than yesterday's (e.g. Monday after Friday), a new week has begun.

Settings Explained
General

Number of Previous Months — How many past months to draw on the chart. Range is 1 to 12.
Extend Lines to Next Month Only — When ON, lines stop at the start of the next month rather than extending to the right edge of the chart. Useful for keeping things tidy.
Auto-Fade Older Months — Makes older months progressively more transparent so recent levels stand out. PM1 is fully opaque; the oldest visible month fades to whatever the Max Fade % is set to.
Max Fade % — Controls how transparent the oldest month gets when Auto-Fade is ON.

Line Labels

Show Line Labels — Toggles text labels on each line.
Label Position — Where the label sits along the line. Left, Right, Center, or pinned to the current bar.
Bars From Current Bar — Only relevant when Label Position is set to Current Bar. Controls how many bars to the left of the current bar the label appears.
Label Size — Small, Normal, or Large text.
Smart Label Stacking — When two levels are very close in price, their labels would overlap. This setting shifts the lower label down slightly so both remain readable.
Stack Offset Threshold — How close two prices need to be (as a percentage) before the stacking kicks in.

Month Visibility
Individual toggles for CM (current month) and PM1 through PM12. Lets you show or hide specific months without changing the overall count.
Weekly High/Low

Show Weekly Levels — Master toggle for all weekly lines.
Number of Previous Weeks — How many past weeks to draw. 1 to 4.
Show Current Week — Toggles the developing current week's levels.
Extend Weekly Lines to Next Week Only — Same as the monthly equivalent but for weekly lines.
Show Weekly Labels — Toggles text labels on weekly lines.

Line Style & Width
Controls for line thickness (1–4) and style (Solid, Dashed, Dotted) — separately for current month, previous months, current week, previous weeks, 50% lines, and VWAP lines. You can also toggle whether 50% lines and VWAP lines appear at all.
Colors
Individual color pickers for every element — each month slot gets its own color, as do the current month high/low, current week, each previous week slot, 50% lines, VWAP lines, and label backgrounds.
Confluence

Show Confluence Zones — When two or more levels (from different months or weeks) are very close to each other in price, the indicator highlights that area with a colored zone box. Levels that agree across timeframes tend to be stronger.
Confluence Threshold (%) — How close two levels need to be to be considered confluent. At 0.08%, two levels within 0.08% of each other will be highlighted.
Confluence Zone Color — The fill color for the highlighted zone.

Price Scale Labels

Show Price Scale Labels — Plots invisible series that cause TradingView's right-hand price scale to show labeled tick marks at each level, color-coded to match the corresponding month.

Broken Levels

Enable Broken Level Colors — When price has crossed a level, the line color changes to the Broken color (default gray), making it easy to see which levels are still intact.
Require Close for Break — When ON, a level is only considered broken when price closes beyond it, not just wicks through.
Monthly/Weekly Broken Level Color — The color broken lines change to.
Show Break Bar Marker — Places a labeled marker on the chart at the exact bar where each break occurred, showing which level was broken and how many times.
Break Marker Background/Size/Offset — Styling controls for those markers.
Strong Level Min Touches — If a level has been touched this many times without breaking, its line becomes one pixel wider to indicate strength.
Highlight Holding Levels — Levels that have been tested multiple times without breaking get a special color (default gold) and a diamond icon ◆ in their label.
Holding Level Color — The color applied to holding levels.

Distance Dashboard
A table overlay on the chart showing the two nearest levels above and two nearest levels below the current price. For each level it shows the level name, price, distance as a percentage, distance in points, touch count, and break count. Icons indicate whether the level is active (▲▼), broken (⊘), holding (◆), or confluent (★).

Show Distance Dashboard — Master toggle.
Dashboard Position — Corner of the chart where the table appears.
Dashboard Text Size — Small or Normal.
Dashboard Background/Text Color — Appearance controls.
Include Weekly Levels in Dashboard — Whether weekly levels are included in the nearest-level search.

Alerts

Enable Proximity Alerts — Fires an alert when price comes within a set percentage of any level.
Proximity Alert Distance (%) — How close price needs to get to trigger a proximity alert.
Enable Level Crossed Alerts — Fires when price crosses through any level.
Enable Current Month New High/Low Alerts — Fires when the current month sets a new developing high or low.
Enable Reclaim Alerts — Fires when price closes back beyond a level it had previously broken through (a reclaim of a broken level).
Enable Weekly Crossed/Proximity Alerts — Same as the monthly versions but for weekly levels.
Cooldown Mode — Choose whether alert cooldowns are measured in minutes or bars.
Alert Cooldown (Minutes/Bars) — How much time or how many bars must pass before the same alert can fire again, preventing spam.


The Icons and What They Mean
IconMeaning▲ / ▼Level is active (not broken)⊘Level has been broken◆Level is "holding" — tested multiple times without breaking★Level is confluent with another nearby level(Nx)Level has been broken N times

How to Use It Effectively
Start with fewer months. Begin with 3–6 months visible. Too many levels creates clutter. PM1, PM2, and PM3 give you the most relevant recent structure.
Watch PM1 levels first. The most recent previous month's high and low are watched by the most traders and tend to be the most reactive levels on the chart.
Confluence is your strongest signal. When a monthly high lines up within 0.08% of a weekly high, that zone is likely to produce a significant reaction. These are the levels worth planning trades around.
Holding levels with the ◆ icon deserve respect. A level that price has tested multiple times and failed to break is telling you something. These tend to produce sharp rejections when touched again, or explosive moves when they finally do break.
Use the dashboard for quick trade planning. Before entering a trade, glance at the dashboard. It tells you immediately how far you are from the next meaningful level above and below — this helps you assess risk/reward without hunting through the chart manually.
Broken levels can flip. A broken monthly high often becomes support on a pullback (and vice versa for lows). The ⊘ icon makes these easy to spot. Watch for price to return to a broken level — if it holds, that's a potential long setup on a broken high or short setup on a broken low.
VWAP lines add context. The monthly VWAP shows where the average participant in that month is positioned. Price above the VWAP means bulls from that month are profitable on average. Below means they are underwater.
Use Auto-Fade to reduce visual noise. Turning on Auto-Fade keeps recent levels sharp and lets old ones recede into the background. This is especially helpful when showing many months.
Set proximity alerts on key levels. Rather than watching the chart, enable alerts for the closest levels from the dashboard. Set the proximity distance to 0.1–0.2% and let the indicator notify you when price approaches.

Recommended Starting Settings
For most traders on intraday or daily charts, a clean starting point is: 3 previous months, current month ON, 2 previous weeks, current week ON, Auto-Fade ON at 60%, Smart Label Stacking ON, Confluence ON at 0.08%, and the dashboard ON showing weekly levels. From there, adjust colors and line styles to match your chart theme.

## Source Code

````pine
//@version=6
indicator("Monthly Levels Pro", shorttitle="Mth Levels", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ═══════════════════════════════════════════════════════════════════════
// PURE HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════

getLineStyle(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>          line.style_dotted

getMonthName(t) =>
    switch month(t)
        1  => "January"
        2  => "February"
        3  => "March"
        4  => "April"
        5  => "May"
        6  => "June"
        7  => "July"
        8  => "August"
        9  => "September"
        10 => "October"
        11 => "November"
        =>   "December"

getMonthShort(t) =>
    switch month(t)
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        =>   "Dec"

getSize(s) =>
    switch s
        "Normal" => size.normal
        "Large"  => size.large
        =>           size.small

getLblSize(s) =>
    switch s
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

// ═══════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════

// ── General ─────────────────────────────────────────────────────────────
i_numMonths  = input.int(3,     "Number of Previous Months", minval=1, maxval=12, group="General")
i_extendOnly = input.bool(false,"Extend Lines to Next Month Only", tooltip="If OFF, lines extend to the right edge of the chart", group="General")
i_autoFade   = input.bool(false,"Auto-Fade Older Months", tooltip="When ON, PM1 is fully opaque and older months fade progressively. Affects chart lines only.", group="General")
i_maxFade    = input.int(70,    "Max Fade % (Oldest Month)", minval=10, maxval=90, step=5, tooltip="How transparent the oldest visible month becomes when Auto-Fade is ON.", group="General")

// ── Line Labels ──────────────────────────────────────────────────────────
i_showLbls    = input.bool(true,      "Show Line Labels",           group="Line Labels")
i_lblPos      = input.string("Center","Label Position",             options=["Left","Right","Center","Current Bar"], group="Line Labels")
i_lblBarOff   = input.int(5,          "Bars From Current Bar",      minval=1, maxval=50, tooltip="Only used when Label Position = Current Bar", group="Line Labels")
i_lblSize     = input.string("Normal","Label Size",                 options=["Small","Normal","Large"], group="Line Labels")
i_lblStack    = input.bool(true,      "Smart Label Stacking",       tooltip="Offsets labels that overlap due to nearby price levels", group="Line Labels")
i_lblStackThr = input.float(0.08,     "Stack Offset Threshold (%)", minval=0.01, maxval=1.0, step=0.01, tooltip="If two labels are within this % of each other, the lower one shifts down", group="Line Labels")

// ── Month Visibility ─────────────────────────────────────────────────────
i_showCurr = input.bool(true, "CM — Show Current Month",   group="Month Visibility")
i_showM1   = input.bool(true, "PM1 — Show  (Most Recent)", group="Month Visibility")
i_showM2   = input.bool(true, "PM2 — Show",                group="Month Visibility")
i_showM3   = input.bool(true, "PM3 — Show",                group="Month Visibility")
i_showM4   = input.bool(true, "PM4 — Show",                group="Month Visibility")
i_showM5   = input.bool(true, "PM5 — Show",                group="Month Visibility")
i_showM6   = input.bool(true, "PM6 — Show",                group="Month Visibility")
i_showM7   = input.bool(true, "PM7 — Show",                group="Month Visibility")
i_showM8   = input.bool(true, "PM8 — Show",                group="Month Visibility")
i_showM9   = input.bool(true, "PM9 — Show",                group="Month Visibility")
i_showM10  = input.bool(true, "PM10 — Show",               group="Month Visibility")
i_showM11  = input.bool(true, "PM11 — Show",               group="Month Visibility")
i_showM12  = input.bool(true, "PM12 — Show  (Oldest)",     group="Month Visibility")

// ── Weekly High/Low ──────────────────────────────────────────────────────
i_showWeekly   = input.bool(true, "Show Weekly Levels",                      group="Weekly High/Low")
i_numWeeks     = input.int(2,     "Number of Previous Weeks", minval=1, maxval=4, group="Weekly High/Low")
i_showCurrWeek = input.bool(true, "Show Current Week",                       group="Weekly High/Low")
i_wExtendOnly  = input.bool(false,"Extend Weekly Lines to Next Week Only",   group="Weekly High/Low")
i_showWLabels  = input.bool(true, "Show Weekly Labels",                      group="Weekly High/Low")

// ── Line Style & Width ───────────────────────────────────────────────────
// Month
i_lineWidth     = input.int(1,         "Month Line Width",             minval=1, maxval=4,                        group="Line Style & Width")
i_currLineStyle = input.string("Solid","CM Line Style",                options=["Solid","Dashed","Dotted"],        group="Line Style & Width")
i_lineStyle     = input.string("Solid","Previous Month Line Style",    options=["Solid","Dashed","Dotted"],        group="Line Style & Width")
i_showMid       = input.bool(false,    "Show 50% Lines",                                                          group="Line Style & Width")
i_midStyle      = input.string("Dotted","50% Line Style",             options=["Solid","Dashed","Dotted"],        group="Line Style & Width")
i_showVWAP      = input.bool(false,    "Show VWAP Lines",                                                         group="Line Style & Width")
i_vwapStyle     = input.string("Dotted","VWAP Line Style",            options=["Solid","Dashed","Dotted"],        group="Line Style & Width")
// Weekly
i_wLineWidth    = input.int(1,         "Weekly Line Width",            minval=1, maxval=4,                        group="Line Style & Width")
i_cwLineStyle   = input.string("Solid","CW Line Style",                options=["Solid","Dashed","Dotted"],        group="Line Style & Width")
i_wLineStyle    = input.string("Solid","Previous Week Line Style",     options=["Solid","Dashed","Dotted"],        group="Line Style & Width")

// ── Colors ───────────────────────────────────────────────────────────────
// Label
i_lblBgCol = input.color(color.black,  "Label Background Color",                                                  group="Colors")
// 50% / VWAP line colors
i_midCol   = input.color(#ffffff,      "50% Line Color",                                                          group="Colors")
i_vwapCol  = input.color(#ffffff,      "VWAP Line Color",                                                         group="Colors")
// Month colors
i_cmHigh  = input.color(#00e676,       "CM High Color",                                                           group="Colors")
i_cmLow   = input.color(#ff5252,       "CM Low Color",                                                            group="Colors")
i_m1Col   = input.color(#26a69a,       "PM1 Color",                                                               group="Colors")
i_m2Col   = input.color(#42a5f5,       "PM2 Color",                                                               group="Colors")
i_m3Col   = input.color(#ab47bc,       "PM3 Color",                                                               group="Colors")
i_m4Col   = input.color(#26c6da,       "PM4 Color",                                                               group="Colors")
i_m5Col   = input.color(#9ccc65,       "PM5 Color",                                                               group="Colors")
i_m6Col   = input.color(#ffa726,       "PM6 Color",                                                               group="Colors")
i_m7Col   = input.color(#ef5350,       "PM7 Color",                                                               group="Colors")
i_m8Col   = input.color(#66bb6a,       "PM8 Color",                                                               group="Colors")
i_m9Col   = input.color(#5c6bc0,       "PM9 Color",                                                               group="Colors")
i_m10Col  = input.color(#8d6e63,       "PM10 Color",                                                              group="Colors")
i_m11Col  = input.color(#26c6da,       "PM11 Color",                                                              group="Colors")
i_m12Col  = input.color(#bdbdbd,       "PM12 Color",                                                              group="Colors")
// Weekly colors
i_cwHigh  = input.color(#00bcd4,       "CW High Color",                                                           group="Colors")
i_cwLow   = input.color(#ff9800,       "CW Low Color",                                                            group="Colors")
i_pw1Col  = input.color(#4dd0e1,       "PW1 Color",                                                               group="Colors")
i_pw2Col  = input.color(#80deea,       "PW2 Color",                                                               group="Colors")
i_pw3Col  = input.color(#b2ebf2,       "PW3 Color",                                                               group="Colors")
i_pw4Col  = input.color(#e0f7fa,       "PW4 Color",                                                               group="Colors")

// ── Confluence ──────────────────────────────────────────────────────────
i_showConf     = input.bool(true,                      "Show Confluence Zones",    group="Confluence", tooltip="Highlights areas where monthly and weekly levels cluster together.")
i_confThresh   = input.float(0.08,                     "Confluence Threshold (%)", minval=0.01, maxval=1.0, step=0.01, group="Confluence", tooltip="Levels within this % of each other are considered confluent.")
i_confCol      = input.color(color.new(#ffeb3b, 75),   "Confluence Zone Color",    group="Confluence")

// ── Price Scale Labels ───────────────────────────────────────────────────
i_showPriceScale = input.bool(true, "Show Price Scale Labels",
     tooltip="PM1 = most recent previous month, PM2 = 2 months ago, and so on up to PM12. CM = current developing month. H = High, L = Low. Colors match each month's High/Low colors. 50% lines show on chart only.",
     group="Price Scale Labels")

// ── Broken Levels ────────────────────────────────────────────────────────
i_showBroken      = input.bool(true,      "Enable Broken Level Colors",    group="Broken Levels")
i_requireClose    = input.bool(false,     "Require Close for Break",       tooltip="When ON, a break is only confirmed when the close (not just a wick) crosses the level.", group="Broken Levels")
i_mBrokenCol      = input.color(#9e9e9e,  "Monthly Broken Level Color",    group="Broken Levels")
i_showWBroken     = input.bool(true,      "Enable Weekly Broken Colors",   group="Broken Levels")
i_wBrokenCol      = input.color(#9e9e9e,  "Weekly Broken Level Color",     group="Broken Levels")
i_showBreakMarker = input.bool(true,      "Show Break Bar Marker",          tooltip="Places a single consolidated marker on the most recent break bar showing total break count.", group="Broken Levels")
i_markerBgCol     = input.color(#1e1e2e,  "Break Marker Background Color",  group="Broken Levels")
i_markerSize      = input.string("Small",  "Break Marker Size",             options=["Small","Normal","Large"], group="Broken Levels")
i_markerOffset    = input.float(1.0,       "Break Marker Offset (%)",       minval=0.1, maxval=5.0, step=0.1, tooltip="How far the marker sits away from the bar. Increase if markers overlap candles.", group="Broken Levels")
i_strongTouchMin  = input.int(2,           "Strong Level Min Touches",     minval=2, maxval=10, tooltip="Levels tested this many times without breaking get a wider line to show strength.", group="Broken Levels")
i_showHolding     = input.bool(true,       "Highlight Holding Levels",     tooltip="Levels tested multiple times without breaking get a special color and icon.", group="Broken Levels")
i_holdingCol      = input.color(#ffc107,   "Holding Level Color",          group="Broken Levels")

// ── Distance Dashboard ───────────────────────────────────────────────────
i_showDash      = input.bool(true,          "Show Distance Dashboard",  group="Distance Dashboard")
i_dashPos       = input.string("Top Right", "Dashboard Position",       options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Distance Dashboard")
i_dashTxtSize   = input.string("Small",     "Dashboard Text Size",      options=["Small","Normal"], group="Distance Dashboard")
i_dashBgCol     = input.color(color.new(#1e1e2e, 10), "Dashboard Background", group="Distance Dashboard")
i_dashTxtCol    = input.color(#e0e0e0,      "Dashboard Text Color",     group="Distance Dashboard")
i_dashIncWeekly = input.bool(true,          "Include Weekly Levels in Dashboard", group="Distance Dashboard")

// ── Alerts ───────────────────────────────────────────────────────────────
i_alertsOn      = input.bool(false, "Enable Proximity Alerts",                  group="Alerts")
i_alertPct      = input.float(0.1,  "Proximity Alert Distance (%)", minval=0.01, maxval=5.0, step=0.01, group="Alerts")
i_alertCrossed  = input.bool(false, "Enable Level Crossed Alerts",              group="Alerts")
i_alertNewHL    = input.bool(false, "Enable Current Month New High/Low Alerts", group="Alerts")
i_alertReclaim  = input.bool(false, "Enable Reclaim Alerts",                    tooltip="Fires when price closes back beyond a level it previously broke through.", group="Alerts")
i_alertWkCross  = input.bool(false, "Enable Weekly Crossed Alerts",             group="Alerts")
i_alertWkProx   = input.bool(false, "Enable Weekly Proximity Alerts",           group="Alerts")
i_cooldownMode  = input.string("Minutes", "Cooldown Mode",                      options=["Minutes", "Bars"], group="Alerts")
i_alertCooldown = input.int(60,     "Alert Cooldown (Minutes)", minval=1, maxval=240, group="Alerts")
i_barCooldown   = input.int(5,      "Alert Cooldown (Bars)",   minval=1, maxval=50, group="Alerts")

// ═══════════════════════════════════════════════════════════════════════
// INPUT-DEPENDENT HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════

slotVisible(i) =>
    switch i
        0  => i_showM1
        1  => i_showM2
        2  => i_showM3
        3  => i_showM4
        4  => i_showM5
        5  => i_showM6
        6  => i_showM7
        7  => i_showM8
        8  => i_showM9
        9  => i_showM10
        10 => i_showM11
        =>    i_showM12

slotCol(i) =>
    switch i
        0  => i_m1Col
        1  => i_m2Col
        2  => i_m3Col
        3  => i_m4Col
        4  => i_m5Col
        5  => i_m6Col
        6  => i_m7Col
        7  => i_m8Col
        8  => i_m9Col
        9  => i_m10Col
        10 => i_m11Col
        =>    i_m12Col

weekSlotCol(i) =>
    switch i
        0  => i_pw1Col
        1  => i_pw2Col
        2  => i_pw3Col
        =>    i_pw4Col

slotFade(i) =>
    i_autoFade and i_numMonths > 1 ? int(math.round(float(i) / float(i_numMonths - 1) * float(i_maxFade))) : 0

// ═══════════════════════════════════════════════════════════════════════
// MONTHLY DATA TRACKING
// ═══════════════════════════════════════════════════════════════════════

var array<float> mHighs            = array.new<float>()
var array<float> mLows             = array.new<float>()
var array<float> mVWAPs            = array.new<float>()
var array<int>   mStartTimes       = array.new<int>()
var array<int>   mEndTimes         = array.new<int>()
var array<int>   mHighBreakTimes   = array.new<int>()
var array<float> mHighBreakPrices  = array.new<float>()
var array<int>   mLowBreakTimes    = array.new<int>()
var array<float> mLowBreakPrices   = array.new<float>()
var array<int>   mHighBreakCount   = array.new<int>()
var array<int>   mLowBreakCount    = array.new<int>()
var array<int>   mHighTouches      = array.new<int>()
var array<int>   mLowTouches       = array.new<int>()
var array<int>   mHighAlertLast    = array.new<int>()
var array<int>   mLowAlertLast     = array.new<int>()
var array<int>   mProxAlertLast    = array.new<int>()
var array<int>   mHighAlertBarIdx  = array.new<int>()
var array<int>   mLowAlertBarIdx   = array.new<int>()
var array<int>   mProxAlertBarIdx  = array.new<int>()

var float currHigh      = na
var float currLow       = na
var int   currStartTime = 0
var float prevCurrHigh  = na
var float prevCurrLow   = na

// VWAP tracking for current month
var float currVwapNum   = 0.0
var float currVwapDen   = 0.0
var float currVWAP      = na

// VWAP tracking for current week
var float currWVwapNum  = 0.0
var float currWVwapDen  = 0.0
var float currWVWAP     = na

isNewMonth = bar_index > 0 and (month(time) != month(time[1]) or year(time) != year(time[1]))

if bar_index == 0
    currHigh      := high
    currLow       := low
    currStartTime := time
    prevCurrHigh  := high
    prevCurrLow   := low
    currVwapNum   := volume * hlc3
    currVwapDen   := volume
    currVWAP      := currVwapDen > 0 ? currVwapNum / currVwapDen : hlc3
else if isNewMonth
    float finalVWAP = currVwapDen > 0 ? currVwapNum / currVwapDen : (currHigh + currLow) / 2.0
    array.unshift(mHighs,           currHigh)
    array.unshift(mLows,            currLow)
    array.unshift(mVWAPs,           finalVWAP)
    array.unshift(mStartTimes,      currStartTime)
    array.unshift(mEndTimes,        time)
    array.unshift(mHighBreakTimes,  0)
    array.unshift(mHighBreakPrices, 0.0)
    array.unshift(mLowBreakTimes,   0)
    array.unshift(mLowBreakPrices,  0.0)
    array.unshift(mHighBreakCount,  0)
    array.unshift(mLowBreakCount,   0)
    array.unshift(mHighTouches,     0)
    array.unshift(mLowTouches,      0)
    array.unshift(mHighAlertLast,   0)
    array.unshift(mLowAlertLast,    0)
    array.unshift(mProxAlertLast,   0)
    array.unshift(mHighAlertBarIdx, 0)
    array.unshift(mLowAlertBarIdx,  0)
    array.unshift(mProxAlertBarIdx, 0)
    while array.size(mHighs) > 12
        array.pop(mHighs)
        array.pop(mLows)
        array.pop(mVWAPs)
        array.pop(mStartTimes)
        array.pop(mEndTimes)
        array.pop(mHighBreakTimes)
        array.pop(mHighBreakPrices)
        array.pop(mLowBreakTimes)
        array.pop(mLowBreakPrices)
        array.pop(mHighBreakCount)
        array.pop(mLowBreakCount)
        array.pop(mHighTouches)
        array.pop(mLowTouches)
        array.pop(mHighAlertLast)
        array.pop(mLowAlertLast)
        array.pop(mProxAlertLast)
        array.pop(mHighAlertBarIdx)
        array.pop(mLowAlertBarIdx)
        array.pop(mProxAlertBarIdx)
    prevCurrHigh  := currHigh
    prevCurrLow   := currLow
    currHigh      := high
    currLow       := low
    currStartTime := time
    currVwapNum   := volume * hlc3
    currVwapDen   := volume
    currVWAP      := currVwapDen > 0 ? currVwapNum / currVwapDen : hlc3
else
    prevCurrHigh := currHigh
    prevCurrLow  := currLow
    currHigh     := math.max(nz(currHigh, high), high)
    currLow      := math.min(nz(currLow,  low),  low)
    currVwapNum  += volume * hlc3
    currVwapDen  += volume
    currVWAP     := currVwapDen > 0 ? currVwapNum / currVwapDen : hlc3

// ═══════════════════════════════════════════════════════════════════════
// WEEKLY DATA TRACKING  (#3 — fixed week detection)
// ═══════════════════════════════════════════════════════════════════════

var array<float> wHighs           = array.new<float>()
var array<float> wLows            = array.new<float>()
var array<float> wVWAPs           = array.new<float>()
var array<int>   wStartTimes      = array.new<int>()
var array<int>   wEndTimes        = array.new<int>()
var array<int>   wHighBreakTimes  = array.new<int>()
var array<float> wHighBreakPrices = array.new<float>()
var array<int>   wLowBreakTimes   = array.new<int>()
var array<float> wLowBreakPrices  = array.new<float>()
var array<int>   wHighBreakCount  = array.new<int>()
var array<int>   wLowBreakCount   = array.new<int>()
var array<int>   wHighTouches     = array.new<int>()
var array<int>   wLowTouches      = array.new<int>()
var array<int>   wHighAlertLast   = array.new<int>()
var array<int>   wLowAlertLast    = array.new<int>()
var array<int>   wProxAlertLast   = array.new<int>()
var array<int>   wHighAlertBarIdx = array.new<int>()
var array<int>   wLowAlertBarIdx  = array.new<int>()
var array<int>   wProxAlertBarIdx = array.new<int>()

var float currWHigh      = na
var float currWLow       = na
var int   currWStartTime = 0

// #3 fix: use dayofweek comparison instead of weekofyear
isNewWeek = bar_index > 0 and (dayofweek(time) < dayofweek(time[1]) or (year(time) != year(time[1]) and month(time) == month(time[1]) == false) or (time - time[1] > 5 * 24 * 60 * 60 * 1000))

if bar_index == 0
    currWHigh      := high
    currWLow       := low
    currWStartTime := time
    currWVwapNum   := volume * hlc3
    currWVwapDen   := volume
    currWVWAP      := currWVwapDen > 0 ? currWVwapNum / currWVwapDen : hlc3
else if isNewWeek
    float finalWVWAP = currWVwapDen > 0 ? currWVwapNum / currWVwapDen : (currWHigh + currWLow) / 2.0
    array.unshift(wHighs,           currWHigh)
    array.unshift(wLows,            currWLow)
    array.unshift(wVWAPs,           finalWVWAP)
    array.unshift(wStartTimes,      currWStartTime)
    array.unshift(wEndTimes,        time)
    array.unshift(wHighBreakTimes,  0)
    array.unshift(wHighBreakPrices, 0.0)
    array.unshift(wLowBreakTimes,   0)
    array.unshift(wLowBreakPrices,  0.0)
    array.unshift(wHighBreakCount,  0)
    array.unshift(wLowBreakCount,   0)
    array.unshift(wHighTouches,     0)
    array.unshift(wLowTouches,      0)
    array.unshift(wHighAlertLast,   0)
    array.unshift(wLowAlertLast,    0)
    array.unshift(wProxAlertLast,   0)
    array.unshift(wHighAlertBarIdx, 0)
    array.unshift(wLowAlertBarIdx,  0)
    array.unshift(wProxAlertBarIdx, 0)
    while array.size(wHighs) > 4
        array.pop(wHighs)
        array.pop(wLows)
        array.pop(wVWAPs)
        array.pop(wStartTimes)
        array.pop(wEndTimes)
        array.pop(wHighBreakTimes)
        array.pop(wHighBreakPrices)
        array.pop(wLowBreakTimes)
        array.pop(wLowBreakPrices)
        array.pop(wHighBreakCount)
        array.pop(wLowBreakCount)
        array.pop(wHighTouches)
        array.pop(wLowTouches)
        array.pop(wHighAlertLast)
        array.pop(wLowAlertLast)
        array.pop(wProxAlertLast)
        array.pop(wHighAlertBarIdx)
        array.pop(wLowAlertBarIdx)
        array.pop(wProxAlertBarIdx)
    currWHigh      := high
    currWLow       := low
    currWStartTime := time
    currWVwapNum   := volume * hlc3
    currWVwapDen   := volume
    currWVWAP      := currWVwapDen > 0 ? currWVwapNum / currWVwapDen : hlc3
else
    currWHigh    := math.max(nz(currWHigh, high), high)
    currWLow     := math.min(nz(currWLow,  low),  low)
    currWVwapNum += volume * hlc3
    currWVwapDen += volume
    currWVWAP    := currWVwapDen > 0 ? currWVwapNum / currWVwapDen : hlc3

// ═══════════════════════════════════════════════════════════════════════
// BREAK & TOUCH DETECTION — MONTHLY  (#2 — close-based break option)
// ═══════════════════════════════════════════════════════════════════════

int  mSz   = array.size(mHighs)
int  mChkN = math.min(i_numMonths, mSz)
int  coolMs = i_alertCooldown * 60 * 1000

if mSz > 0 and mChkN > 0 and not isNewMonth
    for i = 0 to mChkN - 1
        if i < mSz
            float h  = array.get(mHighs, i)
            float l  = array.get(mLows,  i)

            // #2: close-based or wick-based break detection
            bool hBrokenNow = i_requireClose ? (close > h and close[1] <= h) : (high > h and high[1] <= h)
            bool lBrokenNow = i_requireClose ? (close < l and close[1] >= l) : (low < l and low[1] >= l)

            if hBrokenNow
                array.set(mHighBreakTimes,  i, time)
                array.set(mHighBreakPrices, i, i_requireClose ? close : high)
                array.set(mHighBreakCount,  i, array.get(mHighBreakCount, i) + 1)

            if lBrokenNow
                array.set(mLowBreakTimes,  i, time)
                array.set(mLowBreakPrices, i, i_requireClose ? close : low)
                array.set(mLowBreakCount,  i, array.get(mLowBreakCount, i) + 1)

            // Touch = wick reached the level (unchanged)
            if high >= h
                array.set(mHighTouches, i, array.get(mHighTouches, i) + 1)
            if low <= l
                array.set(mLowTouches, i, array.get(mLowTouches, i) + 1)

// ═══════════════════════════════════════════════════════════════════════
// BREAK & TOUCH DETECTION — WEEKLY  (#2 — close-based break option)
// ═══════════════════════════════════════════════════════════════════════

int wSz   = array.size(wHighs)
int wChkN = math.min(i_numWeeks, wSz)

if wSz > 0 and wChkN > 0 and not isNewWeek
    for i = 0 to wChkN - 1
        if i < wSz
            float wh = array.get(wHighs, i)
            float wl = array.get(wLows,  i)

            bool whBrokenNow = i_requireClose ? (close > wh and close[1] <= wh) : (high > wh and high[1] <= wh)
            bool wlBrokenNow = i_requireClose ? (close < wl and close[1] >= wl) : (low < wl and low[1] >= wl)

            if whBrokenNow
                array.set(wHighBreakTimes,  i, time)
                array.set(wHighBreakPrices, i, i_requireClose ? close : high)
                array.set(wHighBreakCount,  i, array.get(wHighBreakCount, i) + 1)

            if wlBrokenNow
                array.set(wLowBreakTimes,  i, time)
                array.set(wLowBreakPrices, i, i_requireClose ? close : low)
                array.set(wLowBreakCount,  i, array.get(wLowBreakCount, i) + 1)

            if high >= wh
                array.set(wHighTouches, i, array.get(wHighTouches, i) + 1)
            if low <= wl
                array.set(wLowTouches, i, array.get(wLowTouches, i) + 1)

// ═══════════════════════════════════════════════════════════════════════
// BROKEN STATUS HELPERS (for drawing — uses close or high/low based on toggle)
// ═══════════════════════════════════════════════════════════════════════

f_isHighBroken(float h) =>
    i_requireClose ? close > h : high > h

f_isLowBroken(float l) =>
    i_requireClose ? close < l : low < l

// ═══════════════════════════════════════════════════════════════════════
// CONFLUENCE HELPER  (#6)
// ═══════════════════════════════════════════════════════════════════════

f_isConfluent(float lvl, array<float> allLvls, array<string> allSources, string mySource) =>
    bool result = false
    if not na(lvl) and array.size(allLvls) > 0
        float threshold = lvl * (i_confThresh / 100.0)
        for j = 0 to array.size(allLvls) - 1
            float other = array.get(allLvls, j)
            string oSrc = array.get(allSources, j)
            if not na(other) and other != lvl and oSrc != mySource and math.abs(lvl - other) <= threshold
                result := true
                break
    result

// ═══════════════════════════════════════════════════════════════════════
// COOLDOWN HELPER  (#11)
// ═══════════════════════════════════════════════════════════════════════

f_isCooled(int lastTime, int lastBarIdx) =>
    if i_cooldownMode == "Minutes"
        (time - lastTime) >= coolMs
    else
        (bar_index - lastBarIdx) >= i_barCooldown

// ═══════════════════════════════════════════════════════════════════════
// SLOT VALUE EXTRACTION (price scale)
// ═══════════════════════════════════════════════════════════════════════

slotH(i) =>
    mSz > i and i_numMonths > i and i_showPriceScale and slotVisible(i) ? array.get(mHighs, i) : na
slotL(i) =>
    mSz > i and i_numMonths > i and i_showPriceScale and slotVisible(i) ? array.get(mLows, i) : na

s1h  = slotH(0)
s1l  = slotL(0)
s2h  = slotH(1)
s2l  = slotL(1)
s3h  = slotH(2)
s3l  = slotL(2)
s4h  = slotH(3)
s4l  = slotL(3)
s5h  = slotH(4)
s5l  = slotL(4)
s6h  = slotH(5)
s6l  = slotL(5)
s7h  = slotH(6)
s7l  = slotL(6)
s8h  = slotH(7)
s8l  = slotL(7)
s9h  = slotH(8)
s9l  = slotL(8)
s10h = slotH(9)
s10l = slotL(9)
s11h = slotH(10)
s11l = slotL(10)
s12h = slotH(11)
s12l = slotL(11)

cmh = i_showCurr and not na(currHigh) and i_showPriceScale ? currHigh : na
cml = i_showCurr and not na(currLow)  and i_showPriceScale ? currLow  : na

// ═══════════════════════════════════════════════════════════════════════
// PRICE SCALE PLOTS
// ═══════════════════════════════════════════════════════════════════════

plot(s1h,  "PM1 H",  color=i_showBroken and not na(s1h)  and f_isHighBroken(s1h)  ? i_mBrokenCol : i_m1Col,   display=display.price_scale)
plot(s1l,  "PM1 L",  color=i_showBroken and not na(s1l)  and f_isLowBroken(s1l)   ? i_mBrokenCol : i_m1Col,   display=display.price_scale)
plot(s2h,  "PM2 H",  color=i_showBroken and not na(s2h)  and f_isHighBroken(s2h)  ? i_mBrokenCol : i_m2Col,   display=display.price_scale)
plot(s2l,  "PM2 L",  color=i_showBroken and not na(s2l)  and f_isLowBroken(s2l)   ? i_mBrokenCol : i_m2Col,   display=display.price_scale)
plot(s3h,  "PM3 H",  color=i_showBroken and not na(s3h)  and f_isHighBroken(s3h)  ? i_mBrokenCol : i_m3Col,   display=display.price_scale)
plot(s3l,  "PM3 L",  color=i_showBroken and not na(s3l)  and f_isLowBroken(s3l)   ? i_mBrokenCol : i_m3Col,   display=display.price_scale)
plot(s4h,  "PM4 H",  color=i_showBroken and not na(s4h)  and f_isHighBroken(s4h)  ? i_mBrokenCol : i_m4Col,   display=display.price_scale)
plot(s4l,  "PM4 L",  color=i_showBroken and not na(s4l)  and f_isLowBroken(s4l)   ? i_mBrokenCol : i_m4Col,   display=display.price_scale)
plot(s5h,  "PM5 H",  color=i_showBroken and not na(s5h)  and f_isHighBroken(s5h)  ? i_mBrokenCol : i_m5Col,   display=display.price_scale)
plot(s5l,  "PM5 L",  color=i_showBroken and not na(s5l)  and f_isLowBroken(s5l)   ? i_mBrokenCol : i_m5Col,   display=display.price_scale)
plot(s6h,  "PM6 H",  color=i_showBroken and not na(s6h)  and f_isHighBroken(s6h)  ? i_mBrokenCol : i_m6Col,   display=display.price_scale)
plot(s6l,  "PM6 L",  color=i_showBroken and not na(s6l)  and f_isLowBroken(s6l)   ? i_mBrokenCol : i_m6Col,   display=display.price_scale)
plot(s7h,  "PM7 H",  color=i_showBroken and not na(s7h)  and f_isHighBroken(s7h)  ? i_mBrokenCol : i_m7Col,   display=display.price_scale)
plot(s7l,  "PM7 L",  color=i_showBroken and not na(s7l)  and f_isLowBroken(s7l)   ? i_mBrokenCol : i_m7Col,   display=display.price_scale)
plot(s8h,  "PM8 H",  color=i_showBroken and not na(s8h)  and f_isHighBroken(s8h)  ? i_mBrokenCol : i_m8Col,   display=display.price_scale)
plot(s8l,  "PM8 L",  color=i_showBroken and not na(s8l)  and f_isLowBroken(s8l)   ? i_mBrokenCol : i_m8Col,   display=display.price_scale)
plot(s9h,  "PM9 H",  color=i_showBroken and not na(s9h)  and f_isHighBroken(s9h)  ? i_mBrokenCol : i_m9Col,   display=display.price_scale)
plot(s9l,  "PM9 L",  color=i_showBroken and not na(s9l)  and f_isLowBroken(s9l)   ? i_mBrokenCol : i_m9Col,   display=display.price_scale)
plot(s10h, "PM10 H", color=i_showBroken and not na(s10h) and f_isHighBroken(s10h) ? i_mBrokenCol : i_m10Col,  display=display.price_scale)
plot(s10l, "PM10 L", color=i_showBroken and not na(s10l) and f_isLowBroken(s10l)  ? i_mBrokenCol : i_m10Col,  display=display.price_scale)
plot(s11h, "PM11 H", color=i_showBroken and not na(s11h) and f_isHighBroken(s11h) ? i_mBrokenCol : i_m11Col,  display=display.price_scale)
plot(s11l, "PM11 L", color=i_showBroken and not na(s11l) and f_isLowBroken(s11l)  ? i_mBrokenCol : i_m11Col,  display=display.price_scale)
plot(s12h, "PM12 H", color=i_showBroken and not na(s12h) and f_isHighBroken(s12h) ? i_mBrokenCol : i_m12Col,  display=display.price_scale)
plot(s12l, "PM12 L", color=i_showBroken and not na(s12l) and f_isLowBroken(s12l)  ? i_mBrokenCol : i_m12Col,  display=display.price_scale)
plot(cmh,  "CM H",   color=i_cmHigh, display=display.price_scale)
plot(cml,  "CM L",   color=i_cmLow,  display=display.price_scale)

// ═══════════════════════════════════════════════════════════════════════
// DRAWING ARRAYS
// ═══════════════════════════════════════════════════════════════════════

var array<line>  drawnLines  = array.new<line>()
var array<label> drawnLabels = array.new<label>()
var array<box>   drawnBoxes  = array.new<box>()
var table        dashTable   = na

// ═══════════════════════════════════════════════════════════════════════
// LABEL POSITION HELPER
// ═══════════════════════════════════════════════════════════════════════

getLabelX(x1, x2, barMs) =>
    switch i_lblPos
        "Left"        => x1
        "Right"       => x2
        "Current Bar" => time - i_lblBarOff * barMs
        =>               int(math.round((x1 + x2) / 2.0))

getLabelAlign() =>
    switch i_lblPos
        "Left"        => label.style_label_right
        "Right"       => label.style_label_left
        "Current Bar" => label.style_label_left
        =>               label.style_label_center

// ═══════════════════════════════════════════════════════════════════════
// SMART STACK HELPER
// ═══════════════════════════════════════════════════════════════════════

smartStack(price, placedPrices) =>
    float adjusted = price
    float threshold = price * (i_lblStackThr / 100.0)
    int   attempts  = 0
    bool  conflict  = true
    while conflict and attempts < 20
        conflict := false
        int sz = array.size(placedPrices)
        if sz > 0
            for j = 0 to sz - 1
                float placed = array.get(placedPrices, j)
                if math.abs(adjusted - placed) < threshold
                    adjusted -= threshold
                    conflict  := true
                    attempts  += 1
                    break
    adjusted

// ═══════════════════════════════════════════════════════════════════════
// MIDPOINT HELPERS — separate 50% and VWAP  (#1)
// ═══════════════════════════════════════════════════════════════════════

f_get50(float h, float l) =>
    (h + l) / 2.0

// ═══════════════════════════════════════════════════════════════════════
// MAIN DRAWING BLOCK
// ═══════════════════════════════════════════════════════════════════════

if barstate.islast

    // Clear old drawings
    for l in drawnLines
        line.delete(l)
    for lb in drawnLabels
        label.delete(lb)
    for b in drawnBoxes
        box.delete(b)
    array.clear(drawnLines)
    array.clear(drawnLabels)
    array.clear(drawnBoxes)

    int   barMs     = int(timeframe.in_seconds() * 1000)
    int   rightEdge = time + barMs * 20
    var   array<float> placedLabelPrices = array.new<float>()
    array.clear(placedLabelPrices)

    pStyle  = getLineStyle(i_lineStyle)
    cStyle  = getLineStyle(i_currLineStyle)
    mStyle  = getLineStyle(i_midStyle)
    vStyle  = getLineStyle(i_vwapStyle)
    wStyle  = getLineStyle(i_wLineStyle)
    wCStyle = getLineStyle(i_cwLineStyle)
    lblAlign = getLabelAlign()
    lblSz    = getLblSize(i_lblSize)
    mrkSz    = getSize(i_markerSize)

    float mrkOffset = close * (i_markerOffset / 100.0)

    // ── BUILD ALL-LEVELS ARRAYS FOR CONFLUENCE (#6) ──────────────────
    var array<float>  confPrices  = array.new<float>()
    var array<string> confSources = array.new<string>()
    array.clear(confPrices)
    array.clear(confSources)

    int n = math.min(i_numMonths, mSz)
    if n > 0
        for i = 0 to n - 1
            if slotVisible(i) and mSz > i
                array.push(confPrices, array.get(mHighs, i))
                array.push(confSources, "M" + str.tostring(i))
                array.push(confPrices, array.get(mLows, i))
                array.push(confSources, "M" + str.tostring(i))
    if i_showCurr and not na(currHigh)
        array.push(confPrices, currHigh)
        array.push(confSources, "CM")
        array.push(confPrices, currLow)
        array.push(confSources, "CM")
    if i_showWeekly
        int wn2 = math.min(i_numWeeks, wSz)
        if wn2 > 0
            for i = 0 to wn2 - 1
                if wSz > i
                    array.push(confPrices, array.get(wHighs, i))
                    array.push(confSources, "W" + str.tostring(i))
                    array.push(confPrices, array.get(wLows, i))
                    array.push(confSources, "W" + str.tostring(i))
        if i_showCurrWeek and not na(currWHigh)
            array.push(confPrices, currWHigh)
            array.push(confSources, "CW")
            array.push(confPrices, currWLow)
            array.push(confSources, "CW")

    // ── PREVIOUS MONTHS ─────────────────────────────────────────────
    if n > 0
        for i = 0 to n - 1
            if slotVisible(i)
                float h    = array.get(mHighs,      i)
                float l    = array.get(mLows,       i)
                float vwap = mSz > i and array.size(mVWAPs) > i ? array.get(mVWAPs, i) : na
                float mid  = f_get50(h, l)
                int   x1   = array.get(mStartTimes, i)
                int   x2   = i_extendOnly ? array.get(mEndTimes, i) : rightEdge
                int   fade = slotFade(i)

                bool  highBroken = i_showBroken and f_isHighBroken(h)
                bool  lowBroken  = i_showBroken and f_isLowBroken(l)
                int   hTouches   = mSz > i ? array.get(mHighTouches, i) : 0
                int   lTouches   = mSz > i ? array.get(mLowTouches,  i) : 0
                int   hWidth     = (not highBroken and hTouches >= i_strongTouchMin) ? math.min(i_lineWidth + 1, 4) : i_lineWidth
                int   lWidth     = (not lowBroken  and lTouches >= i_strongTouchMin) ? math.min(i_lineWidth + 1, 4) : i_lineWidth

                // #7 — holding level detection
                bool hHolding = i_showHolding and not highBroken and hTouches >= i_strongTouchMin
                bool lHolding = i_showHolding and not lowBroken  and lTouches >= i_strongTouchMin

                color hCol = color.new(highBroken ? i_mBrokenCol : slotCol(i), fade)
                color lCol = color.new(lowBroken  ? i_mBrokenCol : slotCol(i), fade)
                color mCol = color.new(i_midCol, fade)
                color vCol = color.new(i_vwapCol, fade)

                // #6 — confluence check
                bool hConf = i_showConf and f_isConfluent(h, confPrices, confSources, "M" + str.tostring(i))
                bool lConf = i_showConf and f_isConfluent(l, confPrices, confSources, "M" + str.tostring(i))

                // Draw lines
                array.push(drawnLines, line.new(x1, h,   x2, h,   xloc=xloc.bar_time, color=hCol, width=hWidth, style=pStyle))
                array.push(drawnLines, line.new(x1, l,   x2, l,   xloc=xloc.bar_time, color=lCol, width=lWidth, style=pStyle))
                if i_showMid
                    array.push(drawnLines, line.new(x1, mid, x2, mid, xloc=xloc.bar_time, color=mCol, width=1, style=mStyle))
                if i_showVWAP and not na(vwap)
                    array.push(drawnLines, line.new(x1, vwap, x2, vwap, xloc=xloc.bar_time, color=vCol, width=1, style=vStyle))

                // #6 — confluence zone boxes
                if hConf
                    float cThr = h * (i_confThresh / 100.0)
                    array.push(drawnBoxes, box.new(x1, h + cThr / 4, x2, h - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))
                if lConf
                    float cThr = l * (i_confThresh / 100.0)
                    array.push(drawnBoxes, box.new(x1, l + cThr / 4, x2, l - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))

                // Line Labels
                if i_showLbls
                    int    lx      = getLabelX(x1, x2, barMs)
                    string mName   = getMonthName(array.get(mStartTimes, i))
                    string slotPfx = "PM" + str.tostring(i + 1) + "-" + mName
                    int    hBkCnt  = mSz > i ? array.get(mHighBreakCount, i) : 0
                    int    lBkCnt  = mSz > i ? array.get(mLowBreakCount,  i) : 0

                    // Build label text with icons for broken (#8 count), holding (#7 ◆), confluence (#6 ★)
                    string hSuffix = highBroken ? " (" + str.tostring(hBkCnt) + "x)" : ""
                    string lSuffix = lowBroken  ? " (" + str.tostring(lBkCnt) + "x)" : ""
                    string hIcons  = (hHolding ? " ◆" : "") + (hConf ? " ★" : "")
                    string lIcons  = (lHolding ? " ◆" : "") + (lConf ? " ★" : "")
                    string hLblTxt = slotPfx + " High" + hSuffix + hIcons
                    string lLblTxt = slotPfx + " Low"  + lSuffix + lIcons

                    float hAdj = i_lblStack ? smartStack(h,   placedLabelPrices) : h
                    float lAdj = i_lblStack ? smartStack(l,   placedLabelPrices) : l

                    color hLblCol = hHolding ? i_holdingCol : (highBroken ? i_mBrokenCol : slotCol(i))
                    color lLblCol = lHolding ? i_holdingCol : (lowBroken  ? i_mBrokenCol : slotCol(i))

                    array.push(drawnLabels, label.new(lx, hAdj, hLblTxt, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=hLblCol, size=lblSz))
                    array.push(placedLabelPrices, hAdj)
                    array.push(drawnLabels, label.new(lx, lAdj, lLblTxt, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=lLblCol, size=lblSz))
                    array.push(placedLabelPrices, lAdj)
                    if i_showMid
                        float mAdj = i_lblStack ? smartStack(mid, placedLabelPrices) : mid
                        array.push(drawnLabels, label.new(lx, mAdj, slotPfx + " 50%", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_midCol, size=lblSz))
                        array.push(placedLabelPrices, mAdj)
                    if i_showVWAP and not na(vwap)
                        float vAdj = i_lblStack ? smartStack(vwap, placedLabelPrices) : vwap
                        array.push(drawnLabels, label.new(lx, vAdj, slotPfx + " VWAP", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_vwapCol, size=lblSz))
                        array.push(placedLabelPrices, vAdj)

                // #8 — consolidated break markers (show if break was ever recorded)
                if i_showBreakMarker and mSz > i
                    int   hbt    = array.get(mHighBreakTimes,  i)
                    float hbp    = array.get(mHighBreakPrices, i)
                    int   lbt    = array.get(mLowBreakTimes,   i)
                    float lbp    = array.get(mLowBreakPrices,  i)
                    int   hBkCnt = array.get(mHighBreakCount,  i)
                    int   lBkCnt = array.get(mLowBreakCount,   i)
                    string mName = getMonthName(array.get(mStartTimes, i))
                    if hbt > 0 and hBkCnt > 0
                        array.push(drawnLabels, label.new(hbt, hbp + mrkOffset, "BROKEN ▲ (" + str.tostring(hBkCnt) + "x) " + mName + " High", xloc=xloc.bar_time, style=label.style_label_down, color=i_markerBgCol, textcolor=#00e676, size=mrkSz))
                    if lbt > 0 and lBkCnt > 0
                        array.push(drawnLabels, label.new(lbt, lbp - mrkOffset, "BROKEN ▼ (" + str.tostring(lBkCnt) + "x) " + mName + " Low",  xloc=xloc.bar_time, style=label.style_label_up,   color=i_markerBgCol, textcolor=#ff5252, size=mrkSz))

    // ── CURRENT MONTH ────────────────────────────────────────────────
    if i_showCurr and not na(currHigh)
        float cMid  = f_get50(currHigh, currLow)
        string cmName = getMonthName(currStartTime)

        array.push(drawnLines, line.new(currStartTime, currHigh, rightEdge, currHigh, xloc=xloc.bar_time, color=i_cmHigh, width=i_lineWidth, style=cStyle))
        array.push(drawnLines, line.new(currStartTime, currLow,  rightEdge, currLow,  xloc=xloc.bar_time, color=i_cmLow,  width=i_lineWidth, style=cStyle))
        if i_showMid
            array.push(drawnLines, line.new(currStartTime, cMid, rightEdge, cMid, xloc=xloc.bar_time, color=i_midCol, width=1, style=mStyle))
        if i_showVWAP and not na(currVWAP)
            array.push(drawnLines, line.new(currStartTime, currVWAP, rightEdge, currVWAP, xloc=xloc.bar_time, color=i_vwapCol, width=1, style=vStyle))

        // Confluence for CM
        bool cmhConf = i_showConf and f_isConfluent(currHigh, confPrices, confSources, "CM")
        bool cmlConf = i_showConf and f_isConfluent(currLow,  confPrices, confSources, "CM")
        if cmhConf
            float cThr = currHigh * (i_confThresh / 100.0)
            array.push(drawnBoxes, box.new(currStartTime, currHigh + cThr / 4, rightEdge, currHigh - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))
        if cmlConf
            float cThr = currLow * (i_confThresh / 100.0)
            array.push(drawnBoxes, box.new(currStartTime, currLow + cThr / 4, rightEdge, currLow - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))

        if i_showLbls
            int   cx   = getLabelX(currStartTime, rightEdge, barMs)
            float hAdj = i_lblStack ? smartStack(currHigh, placedLabelPrices) : currHigh
            float lAdj = i_lblStack ? smartStack(currLow,  placedLabelPrices) : currLow
            string hIc = cmhConf ? " ★" : ""
            string lIc = cmlConf ? " ★" : ""
            array.push(drawnLabels, label.new(cx, hAdj, "CM-" + cmName + " High" + hIc, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_cmHigh, size=lblSz))
            array.push(placedLabelPrices, hAdj)
            array.push(drawnLabels, label.new(cx, lAdj, "CM-" + cmName + " Low"  + lIc, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_cmLow,  size=lblSz))
            array.push(placedLabelPrices, lAdj)
            if i_showMid
                float mAdj = i_lblStack ? smartStack(cMid, placedLabelPrices) : cMid
                array.push(drawnLabels, label.new(cx, mAdj, "CM-" + cmName + " 50%", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_midCol, size=lblSz))
                array.push(placedLabelPrices, mAdj)
            if i_showVWAP and not na(currVWAP)
                float vAdj = i_lblStack ? smartStack(currVWAP, placedLabelPrices) : currVWAP
                array.push(drawnLabels, label.new(cx, vAdj, "CM-" + cmName + " VWAP", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_vwapCol, size=lblSz))
                array.push(placedLabelPrices, vAdj)

    // ── WEEKLY LEVELS ────────────────────────────────────────────────
    if i_showWeekly
        int wn = math.min(i_numWeeks, wSz)

        // Previous weeks
        if wn > 0
            for i = 0 to wn - 1
                float wh   = array.get(wHighs,      i)
                float wl   = array.get(wLows,       i)
                float wvwap = wSz > i and array.size(wVWAPs) > i ? array.get(wVWAPs, i) : na
                float wMid = f_get50(wh, wl)
                int   wx1  = array.get(wStartTimes, i)
                int   wx2  = i_wExtendOnly ? array.get(wEndTimes, i) : rightEdge

                bool  wHBroken  = i_showWBroken and f_isHighBroken(wh)
                bool  wLBroken  = i_showWBroken and f_isLowBroken(wl)
                int   wHTouches = wSz > i ? array.get(wHighTouches, i) : 0
                int   wLTouches = wSz > i ? array.get(wLowTouches,  i) : 0
                int   whWidth   = (not wHBroken and wHTouches >= i_strongTouchMin) ? math.min(i_wLineWidth + 1, 4) : i_wLineWidth
                int   wlWidth   = (not wLBroken and wLTouches >= i_strongTouchMin) ? math.min(i_wLineWidth + 1, 4) : i_wLineWidth

                bool whHolding = i_showHolding and not wHBroken and wHTouches >= i_strongTouchMin
                bool wlHolding = i_showHolding and not wLBroken and wLTouches >= i_strongTouchMin

                color whCol = wHBroken ? i_wBrokenCol : weekSlotCol(i)
                color wlCol = wLBroken ? i_wBrokenCol : weekSlotCol(i)

                bool whConf = i_showConf and f_isConfluent(wh, confPrices, confSources, "W" + str.tostring(i))
                bool wlConf = i_showConf and f_isConfluent(wl, confPrices, confSources, "W" + str.tostring(i))

                array.push(drawnLines, line.new(wx1, wh,   wx2, wh,   xloc=xloc.bar_time, color=whCol, width=whWidth, style=wStyle))
                array.push(drawnLines, line.new(wx1, wl,   wx2, wl,   xloc=xloc.bar_time, color=wlCol, width=wlWidth, style=wStyle))
                if i_showMid
                    array.push(drawnLines, line.new(wx1, wMid, wx2, wMid, xloc=xloc.bar_time, color=i_midCol, width=1, style=mStyle))
                if i_showVWAP and not na(wvwap)
                    array.push(drawnLines, line.new(wx1, wvwap, wx2, wvwap, xloc=xloc.bar_time, color=i_vwapCol, width=1, style=vStyle))

                if whConf
                    float cThr = wh * (i_confThresh / 100.0)
                    array.push(drawnBoxes, box.new(wx1, wh + cThr / 4, wx2, wh - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))
                if wlConf
                    float cThr = wl * (i_confThresh / 100.0)
                    array.push(drawnBoxes, box.new(wx1, wl + cThr / 4, wx2, wl - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))

                if i_showLbls and i_showWLabels
                    int    wlx   = getLabelX(wx1, wx2, barMs)
                    string wPfx  = "PW" + str.tostring(i + 1)
                    int    whBkCnt = wSz > i ? array.get(wHighBreakCount, i) : 0
                    int    wlBkCnt = wSz > i ? array.get(wLowBreakCount,  i) : 0
                    string whSuf = wHBroken ? " (" + str.tostring(whBkCnt) + "x)" : ""
                    string wlSuf = wLBroken ? " (" + str.tostring(wlBkCnt) + "x)" : ""
                    string whIc  = (whHolding ? " ◆" : "") + (whConf ? " ★" : "")
                    string wlIc  = (wlHolding ? " ◆" : "") + (wlConf ? " ★" : "")

                    color whLblCol = whHolding ? i_holdingCol : whCol
                    color wlLblCol = wlHolding ? i_holdingCol : wlCol

                    float  whAdj = i_lblStack ? smartStack(wh,   placedLabelPrices) : wh
                    float  wlAdj = i_lblStack ? smartStack(wl,   placedLabelPrices) : wl
                    array.push(drawnLabels, label.new(wlx, whAdj, wPfx + " High" + whSuf + whIc, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=whLblCol, size=lblSz))
                    array.push(placedLabelPrices, whAdj)
                    array.push(drawnLabels, label.new(wlx, wlAdj, wPfx + " Low"  + wlSuf + wlIc, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=wlLblCol, size=lblSz))
                    array.push(placedLabelPrices, wlAdj)
                    if i_showMid
                        float wmAdj = i_lblStack ? smartStack(wMid, placedLabelPrices) : wMid
                        array.push(drawnLabels, label.new(wlx, wmAdj, wPfx + " 50%", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_midCol, size=lblSz))
                        array.push(placedLabelPrices, wmAdj)
                    if i_showVWAP and not na(wvwap)
                        float wvAdj = i_lblStack ? smartStack(wvwap, placedLabelPrices) : wvwap
                        array.push(drawnLabels, label.new(wlx, wvAdj, wPfx + " VWAP", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_vwapCol, size=lblSz))
                        array.push(placedLabelPrices, wvAdj)

                // #8 — consolidated break markers for weekly (show if break was ever recorded)
                if i_showBreakMarker and wSz > i
                    int   whbt    = array.get(wHighBreakTimes,  i)
                    float whbp    = array.get(wHighBreakPrices, i)
                    int   wlbt    = array.get(wLowBreakTimes,   i)
                    float wlbp    = array.get(wLowBreakPrices,  i)
                    int   whBkCnt = array.get(wHighBreakCount,  i)
                    int   wlBkCnt = array.get(wLowBreakCount,   i)
                    string wkName = "PW" + str.tostring(i + 1)
                    if whbt > 0 and whBkCnt > 0
                        array.push(drawnLabels, label.new(whbt, whbp + mrkOffset, "BROKEN ▲ (" + str.tostring(whBkCnt) + "x) " + wkName + " High", xloc=xloc.bar_time, style=label.style_label_down, color=i_markerBgCol, textcolor=#00e676, size=mrkSz))
                    if wlbt > 0 and wlBkCnt > 0
                        array.push(drawnLabels, label.new(wlbt, wlbp - mrkOffset, "BROKEN ▼ (" + str.tostring(wlBkCnt) + "x) " + wkName + " Low",  xloc=xloc.bar_time, style=label.style_label_up,   color=i_markerBgCol, textcolor=#ff5252, size=mrkSz))

        // Current week
        if i_showCurrWeek and not na(currWHigh)
            float cwMid = f_get50(currWHigh, currWLow)
            array.push(drawnLines, line.new(currWStartTime, currWHigh, rightEdge, currWHigh, xloc=xloc.bar_time, color=i_cwHigh, width=i_wLineWidth, style=wCStyle))
            array.push(drawnLines, line.new(currWStartTime, currWLow,  rightEdge, currWLow,  xloc=xloc.bar_time, color=i_cwLow,  width=i_wLineWidth, style=wCStyle))
            if i_showMid
                array.push(drawnLines, line.new(currWStartTime, cwMid, rightEdge, cwMid, xloc=xloc.bar_time, color=i_midCol, width=1, style=mStyle))
            if i_showVWAP and not na(currWVWAP)
                array.push(drawnLines, line.new(currWStartTime, currWVWAP, rightEdge, currWVWAP, xloc=xloc.bar_time, color=i_vwapCol, width=1, style=vStyle))

            bool cwHConf = i_showConf and f_isConfluent(currWHigh, confPrices, confSources, "CW")
            bool cwLConf = i_showConf and f_isConfluent(currWLow,  confPrices, confSources, "CW")
            if cwHConf
                float cThr = currWHigh * (i_confThresh / 100.0)
                array.push(drawnBoxes, box.new(currWStartTime, currWHigh + cThr / 4, rightEdge, currWHigh - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))
            if cwLConf
                float cThr = currWLow * (i_confThresh / 100.0)
                array.push(drawnBoxes, box.new(currWStartTime, currWLow + cThr / 4, rightEdge, currWLow - cThr / 4, xloc=xloc.bar_time, border_color=color.new(i_confCol, 50), bgcolor=i_confCol))

            if i_showLbls and i_showWLabels
                int   cwlx  = getLabelX(currWStartTime, rightEdge, barMs)
                float whAdj = i_lblStack ? smartStack(currWHigh, placedLabelPrices) : currWHigh
                float wlAdj = i_lblStack ? smartStack(currWLow,  placedLabelPrices) : currWLow
                string cwHIc = cwHConf ? " ★" : ""
                string cwLIc = cwLConf ? " ★" : ""
                array.push(drawnLabels, label.new(cwlx, whAdj, "CW High" + cwHIc, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_cwHigh, size=lblSz))
                array.push(placedLabelPrices, whAdj)
                array.push(drawnLabels, label.new(cwlx, wlAdj, "CW Low"  + cwLIc, xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_cwLow,  size=lblSz))
                array.push(placedLabelPrices, wlAdj)
                if i_showMid
                    float wmAdj = i_lblStack ? smartStack(cwMid, placedLabelPrices) : cwMid
                    array.push(drawnLabels, label.new(cwlx, wmAdj, "CW 50%", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_midCol, size=lblSz))
                    array.push(placedLabelPrices, wmAdj)
                if i_showVWAP and not na(currWVWAP)
                    float wvAdj = i_lblStack ? smartStack(currWVWAP, placedLabelPrices) : currWVWAP
                    array.push(drawnLabels, label.new(cwlx, wvAdj, "CW VWAP", xloc=xloc.bar_time, style=lblAlign, color=i_lblBgCol, textcolor=i_vwapCol, size=lblSz))
                    array.push(placedLabelPrices, wvAdj)

    // ═══════════════════════════════════════════════════════════════════
    // DISTANCE DASHBOARD  (#4 — 2 above/2 below, #5 — Dist Pts column, #6 — confluence star, #7 — holding icon)
    // ═══════════════════════════════════════════════════════════════════

    if i_showDash
        var array<float>  dashPrices  = array.new<float>()
        var array<string> dashNames   = array.new<string>()
        var array<int>    dashTouches = array.new<int>()
        var array<bool>   dashBroken  = array.new<bool>()
        var array<int>    dashBreaks  = array.new<int>()
        var array<bool>   dashConf    = array.new<bool>()
        var array<bool>   dashHold    = array.new<bool>()
        array.clear(dashPrices)
        array.clear(dashNames)
        array.clear(dashTouches)
        array.clear(dashBroken)
        array.clear(dashBreaks)
        array.clear(dashConf)
        array.clear(dashHold)

        // Current month
        if i_showCurr and not na(currHigh)
            string cmN   = "CM-" + getMonthShort(currStartTime)
            float  cMid2 = f_get50(currHigh, currLow)
            array.push(dashPrices, currHigh), array.push(dashNames, cmN + " H"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, i_showConf and f_isConfluent(currHigh, confPrices, confSources, "CM")), array.push(dashHold, false)
            array.push(dashPrices, currLow),  array.push(dashNames, cmN + " L"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, i_showConf and f_isConfluent(currLow,  confPrices, confSources, "CM")), array.push(dashHold, false)
            if i_showMid
                array.push(dashPrices, cMid2), array.push(dashNames, cmN + " 50%"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)
            if i_showVWAP and not na(currVWAP)
                array.push(dashPrices, currVWAP), array.push(dashNames, cmN + " VWAP"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)

        // Previous months
        int dn = math.min(i_numMonths, mSz)
        if dn > 0
            for i = 0 to dn - 1
                if slotVisible(i) and mSz > i
                    float  dh   = array.get(mHighs, i)
                    float  dl   = array.get(mLows,  i)
                    float  dvwap = array.size(mVWAPs) > i ? array.get(mVWAPs, i) : na
                    float  dm   = f_get50(dh, dl)
                    int    dht  = array.get(mHighTouches, i)
                    int    dlt  = array.get(mLowTouches,  i)
                    int    dhbc = array.get(mHighBreakCount, i)
                    int    dlbc = array.get(mLowBreakCount,  i)
                    bool   dhBr = f_isHighBroken(dh)
                    bool   dlBr = f_isLowBroken(dl)
                    string dN   = "PM" + str.tostring(i + 1) + "-" + getMonthShort(array.get(mStartTimes, i))
                    bool   dhConf = i_showConf and f_isConfluent(dh, confPrices, confSources, "M" + str.tostring(i))
                    bool   dlConf = i_showConf and f_isConfluent(dl, confPrices, confSources, "M" + str.tostring(i))
                    bool   dhHold = i_showHolding and not dhBr and dht >= i_strongTouchMin
                    bool   dlHold = i_showHolding and not dlBr and dlt >= i_strongTouchMin
                    array.push(dashPrices, dh), array.push(dashNames, dN + " H"), array.push(dashTouches, dht), array.push(dashBroken, dhBr), array.push(dashBreaks, dhbc), array.push(dashConf, dhConf), array.push(dashHold, dhHold)
                    array.push(dashPrices, dl), array.push(dashNames, dN + " L"), array.push(dashTouches, dlt), array.push(dashBroken, dlBr), array.push(dashBreaks, dlbc), array.push(dashConf, dlConf), array.push(dashHold, dlHold)
                    if i_showMid
                        array.push(dashPrices, dm), array.push(dashNames, dN + " 50%"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)
                    if i_showVWAP and not na(dvwap)
                        array.push(dashPrices, dvwap), array.push(dashNames, dN + " VWAP"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)

        // Weekly levels
        if i_showWeekly and i_dashIncWeekly
            if i_showCurrWeek and not na(currWHigh)
                float cwMid2 = f_get50(currWHigh, currWLow)
                bool cwHConf = i_showConf and f_isConfluent(currWHigh, confPrices, confSources, "CW")
                bool cwLConf = i_showConf and f_isConfluent(currWLow,  confPrices, confSources, "CW")
                array.push(dashPrices, currWHigh), array.push(dashNames, "CW H"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, cwHConf), array.push(dashHold, false)
                array.push(dashPrices, currWLow),  array.push(dashNames, "CW L"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, cwLConf), array.push(dashHold, false)
                if i_showMid
                    array.push(dashPrices, cwMid2), array.push(dashNames, "CW 50%"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)
                if i_showVWAP and not na(currWVWAP)
                    array.push(dashPrices, currWVWAP), array.push(dashNames, "CW VWAP"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)
            int wdn = math.min(i_numWeeks, wSz)
            if wdn > 0
                for i = 0 to wdn - 1
                    if wSz > i
                        float  wdh   = array.get(wHighs, i)
                        float  wdl   = array.get(wLows,  i)
                        float  wdvwap = array.size(wVWAPs) > i ? array.get(wVWAPs, i) : na
                        float  wdm   = f_get50(wdh, wdl)
                        int    wdht  = array.get(wHighTouches, i)
                        int    wdlt  = array.get(wLowTouches,  i)
                        int    wdhbc = array.get(wHighBreakCount, i)
                        int    wdlbc = array.get(wLowBreakCount,  i)
                        bool   wdhBr = f_isHighBroken(wdh)
                        bool   wdlBr = f_isLowBroken(wdl)
                        string wdN   = "PW" + str.tostring(i + 1)
                        bool   wdhConf = i_showConf and f_isConfluent(wdh, confPrices, confSources, "W" + str.tostring(i))
                        bool   wdlConf = i_showConf and f_isConfluent(wdl, confPrices, confSources, "W" + str.tostring(i))
                        bool   wdhHold = i_showHolding and not wdhBr and wdht >= i_strongTouchMin
                        bool   wdlHold = i_showHolding and not wdlBr and wdlt >= i_strongTouchMin
                        array.push(dashPrices, wdh), array.push(dashNames, wdN + " H"), array.push(dashTouches, wdht), array.push(dashBroken, wdhBr), array.push(dashBreaks, wdhbc), array.push(dashConf, wdhConf), array.push(dashHold, wdhHold)
                        array.push(dashPrices, wdl), array.push(dashNames, wdN + " L"), array.push(dashTouches, wdlt), array.push(dashBroken, wdlBr), array.push(dashBreaks, wdlbc), array.push(dashConf, wdlConf), array.push(dashHold, wdlHold)
                        if i_showMid
                            array.push(dashPrices, wdm), array.push(dashNames, wdN + " 50%"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)
                        if i_showVWAP and not na(wdvwap)
                            array.push(dashPrices, wdvwap), array.push(dashNames, wdN + " VWAP"), array.push(dashTouches, 0), array.push(dashBroken, false), array.push(dashBreaks, 0), array.push(dashConf, false), array.push(dashHold, false)

        // #4 — Find 2 closest above and 2 closest below
        int   totalLevels = array.size(dashPrices)
        int   above1i = -1
        int   above2i = -1
        int   below1i = -1
        int   below2i = -1
        float above1  = na
        float above2  = na
        float below1  = na
        float below2  = na

        if totalLevels > 0
            for i = 0 to totalLevels - 1
                float p = array.get(dashPrices, i)
                if p > close
                    if na(above1) or p < above1
                        above2  := above1
                        above2i := above1i
                        above1  := p
                        above1i := i
                    else if na(above2) or p < above2
                        above2  := p
                        above2i := i
                if p < close
                    if na(below1) or p > below1
                        below2  := below1
                        below2i := below1i
                        below1  := p
                        below1i := i
                    else if na(below2) or p > below2
                        below2  := p
                        below2i := i

        // Build table — #4: 7 rows, #5: 7 columns (added Dist Pts)
        table.delete(dashTable)
        tPos = switch i_dashPos
            "Top Left"     => position.top_left
            "Bottom Right" => position.bottom_right
            "Bottom Left"  => position.bottom_left
            =>                position.top_right

        tSz = i_dashTxtSize == "Normal" ? size.normal : size.small

        dashTable := table.new(tPos, 7, 8, bgcolor=i_dashBgCol, border_color=color.new(#ffffff, 80), border_width=1, frame_color=color.new(#ffffff,70), frame_width=1)

        // Header row
        table.cell(dashTable, 0, 0, "NEAREST LEVELS", text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))
        table.cell(dashTable, 1, 0, "Price",           text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))
        table.cell(dashTable, 2, 0, "Dist %",          text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))
        table.cell(dashTable, 3, 0, "Dist Pts",        text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))
        table.cell(dashTable, 4, 0, "Touches",         text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))
        table.cell(dashTable, 5, 0, "Breaks",          text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))
        table.cell(dashTable, 6, 0, "",                text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d4e, 0))

        color aboveRowBg = color.new(#1a2a1a, 0)
        color belowRowBg = color.new(#2a1a1a, 0)
        color greenCol   = color.new(#00e676, 0)
        color redCol     = color.new(#ff5252, 0)

        // Above 2 (row 1)
        if above2i >= 0
            float  p    = array.get(dashPrices,  above2i)
            string nm   = array.get(dashNames,   above2i)
            int    t    = array.get(dashTouches, above2i)
            bool   br   = array.get(dashBroken,  above2i)
            int    bk   = array.get(dashBreaks,  above2i)
            bool   cf   = array.get(dashConf,    above2i)
            bool   hd   = array.get(dashHold,    above2i)
            float  dist = math.abs(close - p) / close * 100
            float  dPts = math.abs(close - p)
            string icon = br ? " ⊘" : " ▲"
            string extra = (hd ? " ◆" : "") + (cf ? " ★" : "")
            table.cell(dashTable, 0, 1, nm + icon + extra,                  text_color=greenCol,     text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 1, 1, str.tostring(p, format.mintick),    text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 2, 1, str.tostring(dist, "#.##") + "%",   text_color=greenCol,     text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 3, 1, str.tostring(dPts, format.mintick), text_color=greenCol,     text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 4, 1, str.tostring(t),                    text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 5, 1, str.tostring(bk),                   text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 6, 1, "",                                 text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
        else
            table.cell(dashTable, 0, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 1, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 2, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 3, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 4, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 5, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 6, 1, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)

        // Above 1 (row 2)
        if above1i >= 0
            float  p    = array.get(dashPrices,  above1i)
            string nm   = array.get(dashNames,   above1i)
            int    t    = array.get(dashTouches, above1i)
            bool   br   = array.get(dashBroken,  above1i)
            int    bk   = array.get(dashBreaks,  above1i)
            bool   cf   = array.get(dashConf,    above1i)
            bool   hd   = array.get(dashHold,    above1i)
            float  dist = math.abs(close - p) / close * 100
            float  dPts = math.abs(close - p)
            string icon = br ? " ⊘" : " ▲"
            string extra = (hd ? " ◆" : "") + (cf ? " ★" : "")
            table.cell(dashTable, 0, 2, nm + icon + extra,                  text_color=greenCol,     text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 1, 2, str.tostring(p, format.mintick),    text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 2, 2, str.tostring(dist, "#.##") + "%",   text_color=greenCol,     text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 3, 2, str.tostring(dPts, format.mintick), text_color=greenCol,     text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 4, 2, str.tostring(t),                    text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 5, 2, str.tostring(bk),                   text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 6, 2, "",                                 text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
        else
            table.cell(dashTable, 0, 2, "None above", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 1, 2, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 2, 2, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 3, 2, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 4, 2, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 5, 2, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)
            table.cell(dashTable, 6, 2, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=aboveRowBg)

        // Current price (row 3)
        table.cell(dashTable, 0, 3, "Current Price",                     text_color=color.new(#ffeb3b, 0), text_size=tSz, bgcolor=color.new(#2d2d2d, 0))
        table.cell(dashTable, 1, 3, str.tostring(close, format.mintick), text_color=color.new(#ffeb3b, 0), text_size=tSz, bgcolor=color.new(#2d2d2d, 0))
        table.cell(dashTable, 2, 3, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d2d, 0))
        table.cell(dashTable, 3, 3, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d2d, 0))
        table.cell(dashTable, 4, 3, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d2d, 0))
        table.cell(dashTable, 5, 3, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d2d, 0))
        table.cell(dashTable, 6, 3, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=color.new(#2d2d2d, 0))

        // Below 1 (row 4)
        if below1i >= 0
            float  p    = array.get(dashPrices,  below1i)
            string nm   = array.get(dashNames,   below1i)
            int    t    = array.get(dashTouches, below1i)
            bool   br   = array.get(dashBroken,  below1i)
            int    bk   = array.get(dashBreaks,  below1i)
            bool   cf   = array.get(dashConf,    below1i)
            bool   hd   = array.get(dashHold,    below1i)
            float  dist = math.abs(close - p) / close * 100
            float  dPts = math.abs(close - p)
            string icon = br ? " ⊘" : " ▼"
            string extra = (hd ? " ◆" : "") + (cf ? " ★" : "")
            table.cell(dashTable, 0, 4, nm + icon + extra,                  text_color=redCol,       text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 1, 4, str.tostring(p, format.mintick),    text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 2, 4, str.tostring(dist, "#.##") + "%",   text_color=redCol,       text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 3, 4, str.tostring(dPts, format.mintick), text_color=redCol,       text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 4, 4, str.tostring(t),                    text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 5, 4, str.tostring(bk),                   text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 6, 4, "",                                 text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
        else
            table.cell(dashTable, 0, 4, "None below", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 1, 4, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 2, 4, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 3, 4, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 4, 4, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 5, 4, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 6, 4, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)

        // Below 2 (row 5)
        if below2i >= 0
            float  p    = array.get(dashPrices,  below2i)
            string nm   = array.get(dashNames,   below2i)
            int    t    = array.get(dashTouches, below2i)
            bool   br   = array.get(dashBroken,  below2i)
            int    bk   = array.get(dashBreaks,  below2i)
            bool   cf   = array.get(dashConf,    below2i)
            bool   hd   = array.get(dashHold,    below2i)
            float  dist = math.abs(close - p) / close * 100
            float  dPts = math.abs(close - p)
            string icon = br ? " ⊘" : " ▼"
            string extra = (hd ? " ◆" : "") + (cf ? " ★" : "")
            table.cell(dashTable, 0, 5, nm + icon + extra,                  text_color=redCol,       text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 1, 5, str.tostring(p, format.mintick),    text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 2, 5, str.tostring(dist, "#.##") + "%",   text_color=redCol,       text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 3, 5, str.tostring(dPts, format.mintick), text_color=redCol,       text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 4, 5, str.tostring(t),                    text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 5, 5, str.tostring(bk),                   text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 6, 5, "",                                 text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
        else
            table.cell(dashTable, 0, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 1, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 2, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 3, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 4, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 5, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)
            table.cell(dashTable, 6, 5, "—", text_color=i_dashTxtCol, text_size=tSz, bgcolor=belowRowBg)

        // Footer legend
        table.cell(dashTable, 0, 6, "▲▼ = Active  ⊘ = Broken  ◆ = Holding  ★ = Confluence", text_color=color.new(i_dashTxtCol, 40), text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))
        table.cell(dashTable, 1, 6, "", text_color=i_dashTxtCol, text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))
        table.cell(dashTable, 2, 6, "", text_color=i_dashTxtCol, text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))
        table.cell(dashTable, 3, 6, "", text_color=i_dashTxtCol, text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))
        table.cell(dashTable, 4, 6, "", text_color=i_dashTxtCol, text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))
        table.cell(dashTable, 5, 6, "", text_color=i_dashTxtCol, text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))
        table.cell(dashTable, 6, 6, "", text_color=i_dashTxtCol, text_size=size.tiny, bgcolor=color.new(#1e1e2e, 0))

// ═══════════════════════════════════════════════════════════════════════
// ALERTS  (#9 — weekly alerts, #10 — reclaim alerts, #11 — bar cooldown)
// ═══════════════════════════════════════════════════════════════════════

if barstate.isconfirmed
    int   mN        = math.min(i_numMonths, mSz)
    float threshold = i_alertPct / 100.0

    // ── Current month new high/low alert ────────────────────────────
    if i_alertNewHL and not na(currHigh)
        if currHigh > prevCurrHigh
            alert("CM New High: " + str.tostring(currHigh, format.mintick) + " — " + getMonthName(currStartTime), alert.freq_once_per_bar)
        if currLow < prevCurrLow
            alert("CM New Low: "  + str.tostring(currLow,  format.mintick) + " — " + getMonthName(currStartTime), alert.freq_once_per_bar)

    // ── Per-level monthly proximity + crossed + reclaim alerts ──────
    if mN > 0
        for i = 0 to mN - 1
            if slotVisible(i) and mSz > i
                float  h       = array.get(mHighs, i)
                float  l       = array.get(mLows,  i)
                float  mid     = f_get50(h, l)
                int    lastH   = array.get(mHighAlertLast, i)
                int    lastL   = array.get(mLowAlertLast,  i)
                int    lastP   = array.get(mProxAlertLast, i)
                int    lastHB  = array.get(mHighAlertBarIdx, i)
                int    lastLB  = array.get(mLowAlertBarIdx,  i)
                int    lastPB  = array.get(mProxAlertBarIdx, i)
                string mName   = getMonthName(array.get(mStartTimes, i))
                bool   hCooled = f_isCooled(lastH, lastHB)
                bool   lCooled = f_isCooled(lastL, lastLB)
                bool   pCooled = f_isCooled(lastP, lastPB)

                // Crossed alerts (#2 — uses close or wick based on toggle)
                if i_alertCrossed
                    bool hCross = i_requireClose ? (close > h and close[1] <= h) : (high > h and high[1] <= h)
                    bool lCross = i_requireClose ? (close < l and close[1] >= l) : (low < l and low[1] >= l)
                    if hCross and hCooled
                        alert("CROSSED: " + mName + " PM" + str.tostring(i+1) + " High " + str.tostring(h, format.mintick), alert.freq_once_per_bar)
                        array.set(mHighAlertLast, i, time)
                        array.set(mHighAlertBarIdx, i, bar_index)
                    if lCross and lCooled
                        alert("CROSSED: " + mName + " PM" + str.tostring(i+1) + " Low " + str.tostring(l, format.mintick), alert.freq_once_per_bar)
                        array.set(mLowAlertLast, i, time)
                        array.set(mLowAlertBarIdx, i, bar_index)

                // #10 — Reclaim alerts
                if i_alertReclaim
                    if close > h and close[1] < h and hCooled
                        alert("RECLAIM: " + mName + " PM" + str.tostring(i+1) + " High " + str.tostring(h, format.mintick), alert.freq_once_per_bar)
                        array.set(mHighAlertLast, i, time)
                        array.set(mHighAlertBarIdx, i, bar_index)
                    if close < l and close[1] > l and lCooled
                        alert("RECLAIM: " + mName + " PM" + str.tostring(i+1) + " Low " + str.tostring(l, format.mintick), alert.freq_once_per_bar)
                        array.set(mLowAlertLast, i, time)
                        array.set(mLowAlertBarIdx, i, bar_index)

                if i_alertsOn and pCooled
                    if math.abs(close - h) / h <= threshold
                        alert("NEAR: " + mName + " PM" + str.tostring(i+1) + " High " + str.tostring(h, format.mintick), alert.freq_once_per_bar)
                        array.set(mProxAlertLast, i, time)
                        array.set(mProxAlertBarIdx, i, bar_index)
                    else if math.abs(close - l) / l <= threshold
                        alert("NEAR: " + mName + " PM" + str.tostring(i+1) + " Low " + str.tostring(l, format.mintick), alert.freq_once_per_bar)
                        array.set(mProxAlertLast, i, time)
                        array.set(mProxAlertBarIdx, i, bar_index)
                    else if math.abs(close - mid) / mid <= threshold
                        alert("NEAR: " + mName + " PM" + str.tostring(i+1) + " 50% " + str.tostring(mid, format.mintick), alert.freq_once_per_bar)
                        array.set(mProxAlertLast, i, time)
                        array.set(mProxAlertBarIdx, i, bar_index)

    // ── Current month proximity ──────────────────────────────────────
    if i_alertsOn and i_showCurr and not na(currHigh)
        float  cMid  = f_get50(currHigh, currLow)
        string cName = getMonthName(currStartTime)
        if math.abs(close - currHigh) / currHigh <= threshold
            alert("NEAR: CM " + cName + " High " + str.tostring(currHigh, format.mintick), alert.freq_once_per_bar)
        if math.abs(close - currLow)  / currLow  <= threshold
            alert("NEAR: CM " + cName + " Low "  + str.tostring(currLow,  format.mintick), alert.freq_once_per_bar)
        if math.abs(close - cMid)     / cMid     <= threshold
            alert("NEAR: CM " + cName + " 50% "  + str.tostring(cMid,     format.mintick), alert.freq_once_per_bar)

    // ── #9 — Weekly crossed + proximity + reclaim alerts ────────────
    int wkN = math.min(i_numWeeks, wSz)
    if wkN > 0
        for i = 0 to wkN - 1
            if wSz > i
                float  wh      = array.get(wHighs, i)
                float  wl      = array.get(wLows,  i)
                float  wMid    = f_get50(wh, wl)
                int    wLastH  = array.get(wHighAlertLast,   i)
                int    wLastL  = array.get(wLowAlertLast,    i)
                int    wLastP  = array.get(wProxAlertLast,   i)
                int    wLastHB = array.get(wHighAlertBarIdx, i)
                int    wLastLB = array.get(wLowAlertBarIdx,  i)
                int    wLastPB = array.get(wProxAlertBarIdx, i)
                string wkName  = "PW" + str.tostring(i + 1)
                bool   whCooled = f_isCooled(wLastH, wLastHB)
                bool   wlCooled = f_isCooled(wLastL, wLastLB)
                bool   wpCooled = f_isCooled(wLastP, wLastPB)

                if i_alertWkCross
                    bool whCross = i_requireClose ? (close > wh and close[1] <= wh) : (high > wh and high[1] <= wh)
                    bool wlCross = i_requireClose ? (close < wl and close[1] >= wl) : (low < wl and low[1] >= wl)
                    if whCross and whCooled
                        alert("CROSSED: " + wkName + " High " + str.tostring(wh, format.mintick), alert.freq_once_per_bar)
                        array.set(wHighAlertLast, i, time)
                        array.set(wHighAlertBarIdx, i, bar_index)
                    if wlCross and wlCooled
                        alert("CROSSED: " + wkName + " Low " + str.tostring(wl, format.mintick), alert.freq_once_per_bar)
                        array.set(wLowAlertLast, i, time)
                        array.set(wLowAlertBarIdx, i, bar_index)

                // #10 — Weekly reclaim alerts
                if i_alertReclaim
                    if close > wh and close[1] < wh and whCooled
                        alert("RECLAIM: " + wkName + " High " + str.tostring(wh, format.mintick), alert.freq_once_per_bar)
                        array.set(wHighAlertLast, i, time)
                        array.set(wHighAlertBarIdx, i, bar_index)
                    if close < wl and close[1] > wl and wlCooled
                        alert("RECLAIM: " + wkName + " Low " + str.tostring(wl, format.mintick), alert.freq_once_per_bar)
                        array.set(wLowAlertLast, i, time)
                        array.set(wLowAlertBarIdx, i, bar_index)

                if i_alertWkProx and wpCooled
                    if math.abs(close - wh) / wh <= threshold
                        alert("NEAR: " + wkName + " High " + str.tostring(wh, format.mintick), alert.freq_once_per_bar)
                        array.set(wProxAlertLast, i, time)
                        array.set(wProxAlertBarIdx, i, bar_index)
                    else if math.abs(close - wl) / wl <= threshold
                        alert("NEAR: " + wkName + " Low " + str.tostring(wl, format.mintick), alert.freq_once_per_bar)
                        array.set(wProxAlertLast, i, time)
                        array.set(wProxAlertBarIdx, i, bar_index)
                    else if math.abs(close - wMid) / wMid <= threshold
                        alert("NEAR: " + wkName + " 50% " + str.tostring(wMid, format.mintick), alert.freq_once_per_bar)
                        array.set(wProxAlertLast, i, time)
                        array.set(wProxAlertBarIdx, i, bar_index)
````
