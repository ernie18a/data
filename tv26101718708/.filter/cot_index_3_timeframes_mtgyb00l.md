# COT Index 3 Timeframes

- url: https://www.tradingview.com/script/MtGyb00L/
- type: indicator
- pine_id: PUB;3c1f77ecec9a41f0ab37543ef8b6844e
- version: 1.0

## Description

[b]COT Index (Multiple Timeframes) – Follow the Smart Money on Any Chart[/b]

[b]OVERVIEW[/b]

Every week, the CFTC reveals how the largest players in the futures markets are positioned. Commercials – producers, merchants and large hedgers – deal with the underlying asset every day, and their positioning often turns against the crowd at market extremes.

This indicator turns their net position into a clean 0–100 oscillator – across three lookback periods at once and on any chart timeframe you trade. No more switching to a weekly chart, no more inconsistent values between timeframes.


[b]KEY ADVANTAGES[/b]

- Truly timeframe-independent: the lookback counts real weekly COT reports, not chart bars. A 26-week index is always 26 reports – on 1m, 1h, 1D, 1W or 1M.

- Three indices in one pane: short-, medium- and long-term positioning (default 12 / 26 / 52 weeks) side by side. When all three agree, the signal carries real weight.

- Honest history: COT data (as of Tuesday) is published Friday at 15:30 New York time. With "Hide the current week" enabled, each report appears only from its actual release – historical bars show exactly what traders could have known at that moment.

- Smart extreme detection: highlights moments when ALL visible indices reach the upper or lower threshold – as a subtle zone or full background.

- Futures Only or Futures + Options with a single click.

- Built-in symbol corrections for markets like Copper, Lumber, Lithium, Canola, Aluminum and Rough Rice.

- Info panel showing market, CFTC code, data type and release date of the report in use.


[b]HOW TO READ IT[/b]

- 100 = Commercials at their most bullish net position of the period
- 0 = Commercials at their most bearish net position of the period
- Above the Upper Threshold (75) = bullish extreme, below the Lower Threshold (25) = bearish extreme

Extreme readings can point to potential turning points. Combine them with your own price-action or timing tools.


[b]SETTINGS[/b]

- Number of weeks (Index 1 / 2 / 3): lookback periods in weekly reports (default 12 / 26 / 52).
- Show COT Index 1 / 2 / 3: show or hide each index. Hidden indices are excluded from the extreme marking.
- Include Options: switch between Futures Only and Futures + Options data. Not available for every market.
- Hide the current week (default on): uses a report only after its Friday release. Recommended for realistic analysis. Holiday delays are not considered.
- Mark long and short extremes: highlights bars where all visible indices are beyond the thresholds.
- Extreme marking style: "Zone beyond threshold" (subtle) or "Full background" (maximum visibility).
- Upper / Lower Threshold: levels for the lines, zones and extreme check (default 75 / 25).


[b]NOTES[/b]

- Works on all futures markets covered by the CFTC COT report; the CFTC code is detected automatically.
- Uses the Legacy report (Commercial positions); values update once per week.
- "Could not find relevant COT data" means the symbol is not covered, or F+O data is unavailable – try disabling "Include Options".

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DanubeMetrics

indicator('COT Index (Multiple Timeframes)', shorttitle = 'COT Index Multi', format = format.percent, precision = 0, dynamic_requests = true)

import TradingView/LibraryCOT/3 as cot

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMEFRAME INDEPENDENCE
// - COT data is requested with the fixed timeframe "W".
// - Long and Short return their last N weekly values as an array from the
//   weekly context -> "Number of weeks" counts real COT reports, not chart bars.
// - No nested request: syminfo.root / CFTC code are evaluated only in the
//   chart context (otherwise error "source search mode Auto").
// - Charts <= W use lookahead_on (avoids week-start/time-zone offsets),
//   charts > W (1M, 3M, 12M ...) use lookahead_off so the LAST weekly report
//   of the chart bar is used instead of the first one.
// - Result: consistent values on 1m, 1h, 1D, 1W, 1M ...
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const string COT_TF = 'W'

// Inputs
// FIX: minval = 2 (with 1 week min == max -> index would always be na)
weeks1 = input.int(12, 'Number of weeks (Index 1)', minval = 2, tooltip = 'Lookback period for COT Index 1, counted in weekly COT reports (not chart bars). The index shows where the current Commercials net position lies within the min/max range of the last N reports (0 = lowest, 100 = highest). Shorter periods react faster but produce more signals. Minimum 2.')
weeks2 = input.int(26, 'Number of weeks (Index 2)', minval = 2, tooltip = 'Lookback period for COT Index 2, counted in weekly COT reports (not chart bars). Default 26 weeks = approx. half a year (medium-term view). Minimum 2.')
weeks3 = input.int(52, 'Number of weeks (Index 3)', minval = 2, tooltip = 'Lookback period for COT Index 3, counted in weekly COT reports (not chart bars). Default 52 weeks = approx. one year (long-term view). The largest of the three values determines how much history is requested. Minimum 2.')

bool show1 = input.bool(true, 'Show COT Index 1', tooltip = 'Shows or hides COT Index 1. A hidden index is neither plotted nor considered in the extreme marking. Use this setting instead of the Style checkboxes.')
bool show2 = input.bool(true, 'Show COT Index 2', tooltip = 'Shows or hides COT Index 2. A hidden index is neither plotted nor considered in the extreme marking. Use this setting instead of the Style checkboxes.')
bool show3 = input.bool(true, 'Show COT Index 3', tooltip = 'Shows or hides COT Index 3. A hidden index is neither plotted nor considered in the extreme marking. Use this setting instead of the Style checkboxes.')

bool includeOptions = input.bool(false, 'Include Options (Futures + Options)', tooltip = 'Off: uses the Futures Only report. On: uses the combined Futures + Options report (options positions converted to futures equivalents). Not every market provides F+O data - if the error "Could not find relevant COT data" appears, disable this option. The table shows "F+O" when enabled.')
// FIX: input.bool instead of input(), default true (avoids look-ahead bias on historical bars)
bool hideCurrentWeek = input.bool(true, 'Hide the current week (use report only after Friday release)', tooltip = 'COT data reflects positions as of Tuesday but is published by the CFTC on Friday at 15:30 New York time. When enabled (recommended), a report is used only from its release onward; before that, the previously published report is used. This avoids look-ahead bias and makes historical bars behave like realtime bars. When disabled, historical bars show the report already from the start of its week (repainting / look-ahead). Holiday-related release delays are not taken into account.')
// FIX: input.bool instead of input()
bool markExtremes = input.bool(false, 'Mark long and short extremes (enabled indices only)', tooltip = 'Highlights extremes when ALL enabled indices are at or above the Upper Threshold (green, long extreme) or at or below the Lower Threshold (red, short extreme). Hidden indices are ignored.')
string markStyle = input.string('Zone beyond threshold', 'Extreme marking style', options = ['Zone beyond threshold', 'Full background'], tooltip = 'Zone beyond threshold: colors only the area between the Upper Threshold and 100 (green) or between 0 and the Lower Threshold (red); the zone moves with the threshold. Full background: colors the entire indicator pane. Only active if "Mark long and short extremes" is enabled.')

// Thresholds: control the threshold lines, the marked zones AND the extreme check
float upperThreshold = input.float(75, 'Upper Threshold', minval = 0, maxval = 100, step = 1, tooltip = 'Upper threshold (0-100) for the green line, the long extreme zone and the long extreme check. Values at or above this level indicate that Commercials are near the top of their net position range (bullish extreme). Must be greater than the Lower Threshold.')
float lowerThreshold = input.float(25, 'Lower Threshold', minval = 0, maxval = 100, step = 1, tooltip = 'Lower threshold (0-100) for the red line, the short extreme zone and the short extreme check. Values at or below this level indicate that Commercials are near the bottom of their net position range (bearish extreme). Must be less than the Upper Threshold.')

if upperThreshold <= lowerThreshold
    runtime.error('Upper Threshold must be greater than Lower Threshold.')

// Fix some symbols (series string is fine: dynamic_requests = true allows series tickers)
string CFTC_Code_fixed = syminfo.root == 'HG' ? '085692' :
                         syminfo.root == 'LBR' ? '058644' :
                         syminfo.root == 'LTH' ? '189691' :
                         syminfo.root == 'RS' ? '135731' :
                         syminfo.root == 'ALI' ? '191691' :
                         syminfo.root == 'ZR' ? '039601' :
                         cot.convertRootToCOTCode('Auto')

// includeOptions = false -> Futures only, true -> Futures + Options combined
longId = cot.COTTickerid('Legacy', CFTC_Code_fixed, includeOptions, 'Commercial Positions', 'Long', 'All')
shortId = cot.COTTickerid('Legacy', CFTC_Code_fixed, includeOptions, 'Commercial Positions', 'Short', 'All')

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WEEKLY HISTORY DIRECTLY FROM THE WEEKLY CONTEXT
// Each of the two requests returns the last N weekly values as an array
// (index 0 = current report, 1 = previous report, ...). No nested
// request -> the CFTC code is determined only in the chart context.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

maxWeeks = math.max(weeks1, math.max(weeks2, weeks3))
histLen = maxWeeks + 1   // +1 report reserve for "Hide the current week"

// Runs in the weekly context: collects close[0 .. len-1] = the last len reports
f_history(simple int len) =>
    float[] hist = array.new_float(len, na)
    for i = 0 to len - 1
        array.set(hist, i, close[i])
    [hist, time]

// FIX: lookahead depends on the chart timeframe
// - Chart <= W: lookahead_on prevents a one-week offset caused by different
//   week starts or time zones of the COT symbol and the chart symbol.
// - Chart  > W: weekly data is a LOWER timeframe; lookahead_off returns the
//   last weekly report inside the chart bar (lookahead_on would return the first).
bool chartIsAboveWeekly = timeframe.in_seconds() > timeframe.in_seconds(COT_TF)
lookaheadMode = chartIsAboveWeekly ? barmerge.lookahead_off : barmerge.lookahead_on

[longHist, longTime] = request.security(longId, COT_TF, f_history(histLen), gaps = barmerge.gaps_off, lookahead = lookaheadMode, ignore_invalid_symbol = true)
[shortHist, shortTime] = request.security(shortId, COT_TF, f_history(histLen), gaps = barmerge.gaps_off, lookahead = lookaheadMode, ignore_invalid_symbol = true)

// Net history (Long - Short), only if both series refer to the same report
float[] netHist = array.new_float(histLen, na)
if not na(longHist) and not na(shortHist) and longTime == shortTime
    for i = 0 to histLen - 1
        array.set(netHist, i, array.get(longHist, i) - array.get(shortHist, i))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIDE THE CURRENT WEEK
// The CFTC publishes the data (as of Tuesday) on Friday at 15:30 New York time.
// If the option is enabled, a report is used only from its release onward;
// before that, the most recently published report applies (offset 1).
// Weekly bar starts Sunday or Monday -> Friday of the same week, 15:30 New York.
// Holiday-related delays are not taken into account.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_release_time(int weekStart) =>
    int result = na
    if not na(weekStart)
        // Find the Friday of the report week (regardless of whether the weekly bar
        // starts on Sunday or Monday) and set 15:30 New York as the release time
        int d = weekStart + 4 * 86400000
        for i = 0 to 6
            if dayofweek(d, 'UTC') == dayofweek.friday
                break
            d += 86400000
        result := timestamp('America/New_York', year(d, 'UTC'), month(d, 'UTC'), dayofmonth(d, 'UTC'), 15, 30)
    result

releaseTime = f_release_time(longTime)
// Last bar: always the current time (even if the market is closed),
// historical bars: end of the bar
barKnowledgeTime = barstate.islast ? timenow : math.min(nz(time_close, timenow), timenow)
int offset = hideCurrentWeek and not na(releaseTime) and barKnowledgeTime < releaseTime ? 1 : 0

float netPos = array.get(netHist, offset)
// Report week (start of the COT weekly bar) of the report actually used - internal only
int reportTime = na(longTime) ? na : longTime - offset * 7 * 86400000
// Release date of the report actually used (Friday 15:30 New York of the report week)
int reportReleaseTime = f_release_time(reportTime)

// Unchanged index formula: position of the current net value within the range of the
// last 'weeks' reports (equivalent to ta.lowest/ta.highest over 'weeks' weeks)
calcIndex(simple int weeks) =>
    float minNetPos = na
    float maxNetPos = na
    bool complete = true
    for i = offset to offset + weeks - 1
        v = array.get(netHist, i)
        if na(v)
            complete := false
        else
            minNetPos := na(minNetPos) ? v : math.min(minNetPos, v)
            maxNetPos := na(maxNetPos) ? v : math.max(maxNetPos, v)
    float result = na
    if complete and not na(netPos) and maxNetPos != minNetPos
        result := 100 * (netPos - minNetPos) / (maxNetPos - minNetPos)
    result

commercialsIndex1 = calcIndex(weeks1)
commercialsIndex2 = calcIndex(weeks2)
commercialsIndex3 = calcIndex(weeks3)

if barstate.islastconfirmedhistory and na(netPos)
    runtime.error('Could not find relevant COT data based on the current symbol.')

// Only enabled indices are plotted
plot1 = show1 ? commercialsIndex1 : na
plot2 = show2 ? commercialsIndex2 : na
plot3 = show3 ? commercialsIndex3 : na

// Plots
plot(plot1, color = color.orange, style = plot.style_line, linewidth = 2, title = 'COT Index 1')
plot(plot2, color = color.yellow, style = plot.style_line, linewidth = 2, title = 'COT Index 2')
plot(plot3, color = color.white, style = plot.style_line, linewidth = 2, title = 'COT Index 3')

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SYMBOL / RELEASE DATE DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table symbolTable = table.new(position.top_right, columns = 1, rows = 1, bgcolor = color.new(color.black, 80), border_width = 1)
if barstate.islast
    // 1. Mapping by ROOT symbol
    rootSymbolName = syminfo.root == 'HG' ? 'Copper' :
                     syminfo.root == 'RS' ? 'Canola' :
                     syminfo.root == 'ALI' ? 'Aluminum' :
                     syminfo.root == 'DX' ? 'U.S. Dollar Index' :
                     syminfo.root == 'LBR' ? 'Lumber' :
                     syminfo.root == 'LTH' ? 'Lithium' :
                     syminfo.root

    // 2. CFTC code mapping (additional check)
    cftcSymbol = CFTC_Code_fixed == '085692' ? 'Copper' :
                 CFTC_Code_fixed == '135731' ? 'Canola' :
                 CFTC_Code_fixed == '191691' ? 'Aluminum' :
                 CFTC_Code_fixed == '098662' ? 'U.S. Dollar Index' :
                 CFTC_Code_fixed == '099741' ? 'Euro FX' :
                 CFTC_Code_fixed == '189691' ? 'Lithium' :
                 rootSymbolName

    // 3. Data check without an additional request + display data type and release date
    hasValidCftcCode = not na(netPos)
    optionsText = includeOptions ? '  •  F+O' : ''
    releaseText = na(reportReleaseTime) ? '' : '  •  Release date (' + str.format_time(reportReleaseTime, 'dd.MM.', 'America/New_York') + ')'
    displayText = hasValidCftcCode ? cftcSymbol + ' (' + CFTC_Code_fixed + ')' + optionsText + releaseText : ''
    table.cell(symbolTable, 0, 0, displayText, text_color = color.white, text_size = size.normal)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THRESHOLD LINES (plots instead of hline -> value only adjustable via Inputs,
// lines, zones and extreme check always use the same thresholds)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pUpper = plot(upperThreshold, 'Upper Threshold', color = color.green, linewidth = 1, editable = true)
pLower = plot(lowerThreshold, 'Lower Threshold', color = color.red, linewidth = 1, editable = true)
pTop = plot(100, 'Top (100)', color = na, display = display.none, editable = false)
pBottom = plot(0, 'Bottom (0)', color = na, display = display.none, editable = false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTREME MARKING: ONLY ENABLED INDICES ARE CONSIDERED
// Green: all enabled indices >= Upper Threshold (long extreme)
// Red:   all enabled indices <= Lower Threshold (short extreme)
// Disabled indices (Show COT Index = off) are ignored.
// 'Zone beyond threshold': zone moves with the threshold (Upper..100 / 0..Lower)
// 'Full background':       whole pane background
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool v1_on = show1 and not na(commercialsIndex1)
bool v2_on = show2 and not na(commercialsIndex2)
bool v3_on = show3 and not na(commercialsIndex3)
bool any_on = v1_on or v2_on or v3_on

bool all_visible_above = any_on and (not v1_on or commercialsIndex1 >= upperThreshold) and (not v2_on or commercialsIndex2 >= upperThreshold) and (not v3_on or commercialsIndex3 >= upperThreshold)
bool all_visible_below = any_on and (not v1_on or commercialsIndex1 <= lowerThreshold) and (not v2_on or commercialsIndex2 <= lowerThreshold) and (not v3_on or commercialsIndex3 <= lowerThreshold)

bool zoneMode = markStyle == 'Zone beyond threshold'

color longZoneColor = markExtremes and zoneMode and all_visible_above ? color.new(color.green, 70) : na
color shortZoneColor = markExtremes and zoneMode and all_visible_below ? color.new(color.red, 70) : na

fill(pUpper, pTop, color = longZoneColor, title = 'Long Extreme Zone', fillgaps = false)
fill(pBottom, pLower, color = shortZoneColor, title = 'Short Extreme Zone', fillgaps = false)

bgColorCondition = markExtremes and not zoneMode and all_visible_above ? color.new(color.green, 85) :
                   markExtremes and not zoneMode and all_visible_below ? color.new(color.red, 85) : na

bgcolor(bgColorCondition, title = 'Extreme Background')
````
