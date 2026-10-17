# Days of the Week Futures

- url: https://www.tradingview.com/script/xiOAEzBS-Days-of-the-Week-Futures/
- type: indicator
- pine_id: PUB;acb9fe0ae4e94786a35d5a1bc097fc4d
- version: 2.0

## Description

Features:

Day labels pinned to bottom of chart — SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY stay locked to the viewport as you scroll and zoom
Vertical separator lines at the start of each trading day (Sunday evening through Friday)
Sunday highlighted in dark red to mark the weekly open, while weekdays use a neutral black
Fully customizable — adjust line colors, thickness, transparency, and label anchor times
Separate Sunday anchor hour to accommodate the Sunday evening futures open (defaults to 9 PM ET)

Settings:

Weekday Line Color — color for Mon–Fri separators
Sunday Line Color — color for the Sunday weekly open line
Separator Line Width — adjust thickness (1–4)
Weekday Label Anchor Hour (ET) — when labels appear for Mon–Fri (default: noon)
Sunday Label Anchor Hour (ET) — when Sunday label appears (default: 9 PM)

## Source Code

````pine
//@version=6
indicator('Days of the Week Futures + Econ Dots', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════
//  Day separators + weekday names + ForexFactory-style economic impact dots.
//
//  Pine is sandboxed (no HTTP), so the calendar is baked in as a string
//  constant below. Regenerate it with ff_pine_gen.py and paste the block
//  between the FF-CAL markers. Nothing else in this file needs to change.
//
//  Impact codes:  2 = FF "High"   -> red dot
//                 1 = FF "Medium" -> yellow dot
// ═══════════════════════════════════════════════════════════════════════════

// ─── INPUTS ────────────────────────────────────────────────────────────────
gL = 'Day separators'
lineColor = input.color(color.new(color.black, 40), 'Weekday line color', group = gL)
sundayColor = input.color(color.new(color.maroon, 40), 'Sunday line color', group = gL)
lineWidth = input.int(3, 'Separator line width', minval = 1, maxval = 4, group = gL)

gD = 'Day labels'
labelHour = input.int(12, 'Weekday label anchor hour', minval = 0, maxval = 23, group = gD)
sundayHour = input.int(21, 'Sunday label anchor hour', minval = 0, maxval = 23, group = gD)

gE = 'Economic events'
showDots = input.bool(true, 'Show impact dots', group = gE)
hiColor = input.color(color.red, 'High impact', group = gE)
medColor = input.color(color.yellow, 'Medium impact', group = gE)
showTip = input.bool(false, 'Hover tooltip below bar (lists the events)', group = gE)
tintHigh = input.bool(false, 'Tint background on high-impact days', group = gE)
tintTrans = input.int(93, 'Tint transparency', minval = 50, maxval = 99, group = gE)

labelCol = color.new(color.black, 40)

// ─── GENERATED CALENDAR ────────────────────────────────────────────────────
// ══ FF-CAL BEGIN ═══ generated 2026-08-28 07:46 | EUR,GBP,USD | high,medium | 119 days (67 red) | 2026-06-01 → 2027-06-30 | 2 chunk(s) ══
CAL1 = '20260601:2:USD ISM Manufacturing PMI|20260603:2:USD ISM Services PMI|20260604:1:USD Unemployment Claims|20260605:2:USD Non-Farm Payrolls + Unemployment Rate|20260610:2:USD CPI m/m + Core CPI|20260611:1:USD Unemployment Claims|20260617:2:USD FOMC Statement / Rate Decision|20260618:2:GBP BoE Bank Rate • USD Unemployment Claims|20260625:1:USD Unemployment Claims|20260630:1:EUR Flash CPI Estimate y/y|20260701:2:USD ISM Manufacturing PMI|20260702:1:USD Unemployment Claims|20260703:2:USD Non-Farm Payrolls + Unemployment Rate • USD ISM Services PMI|20260709:1:USD Unemployment Claims|20260714:2:USD CPI m/m + Core CPI|20260716:1:USD Unemployment Claims|20260723:1:USD Unemployment Claims|20260729:2:USD FOMC Statement / Rate Decision|20260730:2:GBP BoE Bank Rate • USD Unemployment Claims|20260731:1:EUR Flash CPI Estimate y/y|20260803:2:USD ISM Manufacturing PMI|20260805:2:USD ISM Services PMI|20260806:1:USD Unemployment Claims|20260807:2:USD Non-Farm Payrolls + Unemployment Rate|20260812:2:USD CPI m/m + Core CPI|20260813:1:USD Unemployment Claims|20260820:1:USD Unemployment Claims|20260824:1:USD Treasury Sec Bessent Speaks|20260825:1:USD CB Consumer Confidence|20260826:2:USD Core PCE Price Index m/m • USD Prelim GDP q/q|20260827:1:USD Unemployment Claims|20260828:2:USD Fed Chairman Warsh Speaks • USD Prelim Benchmark Payrolls Revision • USD Revised UoM Inflation Expectations|20260831:1:EUR Flash CPI Estimate y/y|20260901:2:USD ISM Manufacturing PMI|20260903:2:USD ISM Services PMI • USD Unemployment Claims|20260904:2:USD Non-Farm Payrolls + Unemployment Rate|20260910:2:EUR ECB Rate Decision • USD Unemployment Claims|20260911:2:USD CPI m/m + Core CPI|20260916:2:USD FOMC Statement / Rate Decision|20260917:2:GBP BoE Bank Rate • USD Unemployment Claims|20260924:1:USD Unemployment Claims|20260930:1:EUR Flash CPI Estimate y/y|20261001:2:USD ISM Manufacturing PMI • USD Unemployment Claims|20261002:2:USD Non-Farm Payrolls + Unemployment Rate|20261005:2:USD ISM Services PMI|20261008:1:USD Unemployment Claims|20261014:2:USD CPI m/m + Core CPI|20261015:1:USD Unemployment Claims|20261022:1:USD Unemployment Claims|20261028:2:USD FOMC Statement / Rate Decision|20261029:2:EUR ECB Rate Decision • USD Unemployment Claims|20261030:1:EUR Flash CPI Estimate y/y|20261102:2:USD ISM Manufacturing PMI|20261104:2:USD ISM Services PMI|20261105:2:GBP BoE Bank Rate • USD Unemployment Claims|20261106:2:USD Non-Farm Payrolls + Unemployment Rate|20261110:2:USD CPI m/m + Core CPI|20261112:1:USD Unemployment Claims|20261119:1:USD Unemployment Claims|20261126:1:USD Unemployment Claims|20261130:1:EUR Flash CPI Estimate y/y|20261201:2:USD ISM Manufacturing PMI|20261203:2:USD ISM Services PMI • USD Unemployment Claims|20261204:2:USD Non-Farm Payrolls + Unemployment Rate|20261209:2:USD FOMC Statement / Rate Decision|20261210:2:USD CPI m/m + Core CPI • USD Unemployment Claims|20261217:2:EUR ECB Rate Decision • GBP BoE Bank Rate • USD Unemployment Claims|20261224:1:USD Unemployment Claims|20261231:1:USD Unemployment Claims • EUR Flash CPI Estimate y/y|20270101:2:USD Non-Farm Payrolls + Unemployment Rate • USD ISM Manufacturing PMI|20270105:2:USD ISM Services PMI|20270107:1:USD Unemployment Claims|20270114:1:USD Unemployment Claims|20270121:1:USD Unemployment Claims|20270127:2:USD FOMC Statement / Rate Decision|20270128:1:USD Unemployment Claims|20270129:1:EUR Flash CPI Estimate y/y|20270201:2:USD ISM Manufacturing PMI|20270203:2:USD ISM Services PMI|20270204:2:EUR ECB Rate Decision • GBP BoE Bank Rate • USD Unemployment Claims|20270205:2:USD Non-Farm Payrolls + Unemployment Rate|20270211:1:USD Unemployment Claims|20270218:1:USD Unemployment Claims|20270225:1:USD Unemployment Claims|20270226:1:EUR Flash CPI Estimate y/y|20270301:2:USD ISM Manufacturing PMI'
CAL2 = '20270303:2:USD ISM Services PMI|20270304:1:USD Unemployment Claims|20270305:2:USD Non-Farm Payrolls + Unemployment Rate|20270311:1:USD Unemployment Claims|20270317:2:USD FOMC Statement / Rate Decision|20270318:2:EUR ECB Rate Decision • GBP BoE Bank Rate • USD Unemployment Claims|20270325:1:USD Unemployment Claims|20270331:1:EUR Flash CPI Estimate y/y|20270401:2:USD ISM Manufacturing PMI • USD Unemployment Claims|20270402:2:USD Non-Farm Payrolls + Unemployment Rate|20270405:2:USD ISM Services PMI|20270408:1:USD Unemployment Claims|20270415:1:USD Unemployment Claims|20270422:1:USD Unemployment Claims|20270428:2:USD FOMC Statement / Rate Decision|20270429:2:EUR ECB Rate Decision • GBP BoE Bank Rate • USD Unemployment Claims|20270430:1:EUR Flash CPI Estimate y/y|20270503:2:USD ISM Manufacturing PMI|20270505:2:USD ISM Services PMI|20270506:1:USD Unemployment Claims|20270507:2:USD Non-Farm Payrolls + Unemployment Rate|20270513:1:USD Unemployment Claims|20270520:1:USD Unemployment Claims|20270527:1:USD Unemployment Claims|20270531:1:EUR Flash CPI Estimate y/y|20270601:2:USD ISM Manufacturing PMI|20270603:2:USD ISM Services PMI • USD Unemployment Claims|20270604:2:USD Non-Farm Payrolls + Unemployment Rate|20270609:2:USD FOMC Statement / Rate Decision|20270610:2:EUR ECB Rate Decision • USD Unemployment Claims|20270617:2:GBP BoE Bank Rate • USD Unemployment Claims|20270624:1:USD Unemployment Claims|20270630:1:EUR Flash CPI Estimate y/y'
var CAL_PARTS = array.from(CAL1, CAL2)
// ══ FF-CAL END ═══ regenerate with: python3 ff_pine_gen.py --clip ══

// ─── PARSE CALENDAR ONCE ───────────────────────────────────────────────────
var array<int> calDate = array.new_int()
var array<int> calImp = array.new_int()
var array<string> calTxt = array.new_string()

if barstate.isfirst
    for c = 0 to array.size(CAL_PARTS) - 1 by 1
        rows = str.split(array.get(CAL_PARTS, c), '|')
        n = array.size(rows)
        for i = 0 to n > 0 ? n - 1 : 0 by 1
            f = n > 0 ? str.split(array.get(rows, i), ':') : array.new_string(0)
            if array.size(f) >= 3
                dnum = str.tonumber(array.get(f, 0))
                inum = str.tonumber(array.get(f, 1))
                if not na(dnum) and not na(inum)
                    array.push(calDate, int(dnum))
                    array.push(calImp, int(inum))
                    array.push(calTxt, array.get(f, 2))

// ─── TODAY'S EVENT LOOKUP ───────────────────────────────────────────────────
dkey = year * 10000 + month * 100 + dayofmonth
idx = array.size(calDate) > 0 ? array.indexof(calDate, dkey) : -1
hasEv = idx >= 0
evImp = hasEv ? array.get(calImp, idx) : 0
evTxt = hasEv ? array.get(calTxt, idx) : ''
dotCol = evImp == 2 ? hiColor : medColor

// ─── SEPARATOR LINES ───────────────────────────────────────────────────────
isNewDay = dayofweek != dayofweek[1]
if isNewDay and dayofweek >= 1 and dayofweek <= 6
    col = dayofweek == dayofweek.sunday ? sundayColor : lineColor
    line.new(x1 = bar_index, y1 = high, x2 = bar_index, y2 = low, extend = extend.both, color = col, width = lineWidth, style = line.style_solid)

// ─── ANCHOR BAR (timeframe-agnostic: first bar at/after the anchor hour) ────
// Replaces the old `hour == labelHour and minute == 0` test, which silently
// dropped labels on any timeframe without a bar landing exactly on the hour.
anchorHr = dayofweek == dayofweek.sunday ? sundayHour : labelHour
anchorHrEff = timeframe.isdwm ? 0 : anchorHr
var int lastAnchorDom = na
bool isAnchor = false
if hour >= anchorHrEff and (na(lastAnchorDom) or lastAnchorDom != dayofmonth)
    lastAnchorDom := dayofmonth
    isAnchor := true
    isAnchor

// ─── DAY LABELS PINNED TO BOTTOM ───────────────────────────────────────────
plotchar(isAnchor and dayofweek == dayofweek.sunday, text = 'SUNDAY', char = '', color = labelCol, textcolor = labelCol, location = location.bottom, title = 'Sunday')
plotchar(isAnchor and dayofweek == dayofweek.monday, text = 'MONDAY', char = '', color = labelCol, textcolor = labelCol, location = location.bottom, title = 'Monday')
plotchar(isAnchor and dayofweek == dayofweek.tuesday, text = 'TUESDAY', char = '', color = labelCol, textcolor = labelCol, location = location.bottom, title = 'Tuesday')
plotchar(isAnchor and dayofweek == dayofweek.wednesday, text = 'WEDNESDAY', char = '', color = labelCol, textcolor = labelCol, location = location.bottom, title = 'Wednesday')
plotchar(isAnchor and dayofweek == dayofweek.thursday, text = 'THURSDAY', char = '', color = labelCol, textcolor = labelCol, location = location.bottom, title = 'Thursday')
plotchar(isAnchor and dayofweek == dayofweek.friday, text = 'FRIDAY', char = '', color = labelCol, textcolor = labelCol, location = location.bottom, title = 'Friday')

// ─── IMPACT DOT ────────────────────────────────────────────────────────────
// Declared AFTER the day labels so it stacks one row ABOVE the day name.
// If your TradingView build stacks the other way, move this line above the
// six plotchar calls and the dot drops back under the name.
plotchar(showDots and isAnchor and hasEv, char = '●', text = '', color = dotCol, textcolor = dotCol, location = location.bottom, size = size.small, title = 'Econ impact dot')

// ─── OPTIONAL EXTRAS ───────────────────────────────────────────────────────
if showDots and showTip and isAnchor and hasEv
    label.new(bar_index, low, text = '', yloc = yloc.belowbar, style = label.style_circle, color = color.new(dotCol, 20), size = size.tiny, tooltip = evTxt)

bgcolor(tintHigh and hasEv and evImp == 2 ? color.new(hiColor, tintTrans) : na, title = 'High-impact day tint')
````
