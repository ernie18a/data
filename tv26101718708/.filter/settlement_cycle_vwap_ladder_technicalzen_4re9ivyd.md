# Settlement Cycle VWAP Ladder [TechnicalZen]

- url: https://www.tradingview.com/script/4rE9ivYD-Settlement-Cycle-VWAP-Ladder-TechnicalZen/
- type: indicator
- pine_id: PUB;7821603ed1714f33bd2e6b81505be356
- version: 2.0

## Description

Must have in a technical trader's toolkit! Four volume-weighted anchors stacked across derivatives-expiry horizons for all major markets.

[b]What This Is[/b]

A multi-horizon VWAP reference stack, anchored to the settlement calendar of your chosen market (options and futures expiry dates). Four volume-weighted levels — monthly, weekly, week-to-date, and session — rendered on the price pane with a 20-bar historical table showing how each has evolved.

The indicator does NOT guess or lag. It computes hard reference levels from actual volume and price, snaps them to real expiry dates (last Thursday for NSE, third Friday for Europe, etc.), and prints them as step-lines and accumulating curves on your chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]What It Does — The Four Ladders[/b]

[list]
[*][b]Monthly Anchor[/b] — N-day VWMA (default 20-day) whose value is [i]snapped[/i] on the monthly expiry day and held flat until the next monthly expiry. This is your longest-horizon volume-weighted reference, updating once a month.

[*][b]Weekly Anchor[/b] — N-day VWMA (default 5-day) snapped every weekly expiry day. Updates once a week. Between expiries it's a flat step-line — deliberately so, because that's what makes it useful as a reference level.

[*][b]Week-to-Date VWAP[/b] — true cumulative VWAP accumulating bar-by-bar through the trading week. Resets the day AFTER weekly expiry (Friday for US / Europe, Monday for NSE Thursday-expiry, Wednesday for BSE Tuesday-expiry). Shows where volume-weighted consensus is building during the current cycle.

[*][b]Session VWAP[/b] — classic daily VWAP, resets at each session open. Tightest anchor, your intraday fair-value line.
[/list]

Stacked, these four tell you where price sits relative to volume-weighted consensus at every horizon: intraday → this week → this month → longer term. When price respects all four from one side, you have a strong directional bias. When price oscillates around the tight ones while respecting the wider ones, you have a range.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Market Presets — Derivatives Expiry Conventions Built In[/b]

Expiry days differ by market. Pick a preset and everything calibrates:

[list]
[*][b]US Standard (3rd Friday)[/b] — SPX, NDX, S&P options, most index futures
[*][b]US EOM (Last Friday)[/b] — SPX / SPY end-of-month options
[*][b]Europe (3rd Friday)[/b] — DAX, FTSE 100, EURO STOXX 50, CAC 40, SMI, IBEX 35, AEX
[*][b]India NSE (Last Thursday)[/b] — NIFTY, Bank NIFTY, stock futures, stock options
[*][b]India BSE (Last Tuesday)[/b] — SENSEX, BANKEX
[*][b]Custom[/b] — pick any weekday + "Third" or "Last" rule manually
[/list]

Selecting the right preset sets the weekly snap day, the monthly snap rule (third vs last occurrence in the month), AND the week-start day for the Week-to-Date accumulator — so your "week" aligns with the actual options cycle.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]How to Use It[/b]

[list=1]
[*]Load with defaults. Pick the market preset that matches your instrument.
[*]Read price relative to the four ladders:
  [list]
  [*]Above all four = strong volume-weighted uptrend across all horizons
  [*]Below all four = strong downtrend
  [*]Mixed (above some, below others) = transitional
  [*]Oscillating around tight (Session, WTD) while respecting wide (Weekly, Monthly) = range within bigger trend
  [/list]
[*]Use the Monthly and Weekly anchors as [b]support / resistance[/b] levels — they're where institutions mark to market at expiry.
[*]Use the Week-to-Date VWAP as an intra-cycle fair value — price far above it = stretched bullish, far below = stretched bearish.
[*]Use the Session VWAP as intraday mean — a classic reversion magnet.
[*]Consult the history table for quick reference to recent values of all four, with date headers showing exactly which bar each column represents.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Main Features[/b]

[list]
[*][b]Six market presets[/b] plus Custom mode for any derivatives expiry convention worldwide
[*][b]Four stacked VWAP horizons[/b] — monthly, weekly, WTD, session — each independently togglable
[*][b]Session-aware for futures[/b] — NQ, ES, CL, GC and other overnight-session instruments correctly identify their trading date via time_close("D"), so Friday's expiry snap lands on Friday even when the session starts Thursday evening
[*][b]Date-headered history table[/b] — 20 columns of recent values, auto-formatted (HH:mm on intraday, dd MMM on daily+)
[*][b]Adjustable text sizes[/b] — Tiny / Small / Normal / Large / Huge for both data cells and headers
[*][b]Direction-aware colors[/b] — each cell and plot line shows bar-over-bar direction at a glance
[*][b]Step-line plots with diamonds[/b] for the snapshot-held anchors (Monthly, Weekly); circles for WTD; continuous line for Session
[*][b]Same-timeframe bug resolved[/b] — on D charts, VWMAs compute locally to avoid the 1-bar lookahead-off delay that `request.security` introduces; on sub-daily charts, `request.security` uses `lookahead_on` so intraday bars see today's evolving daily VWMA
[*][b]NA guards[/b] — anchors never get clobbered by na on the first snap if chart history is short; they simply stay blank until a valid snap fires
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Key Settings[/b]

[list]
[*][b]Market Preset[/b] — dropdown of expiry conventions (see above)
[*][b]Monthly VWMA length (days)[/b] — default 20
[*][b]Weekly VWMA length (days)[/b] — default 5
[*][b]Source[/b] — price used for VWMA and cumulative calcs (default close)
[*][b]Show Monthly / Weekly / WTD / Session[/b] — four independent plot toggles
[*][b]Show History Table[/b] + position + column count
[*][b]Data Cell Text Size[/b] / [b]Header/Label Text Size[/b] — both adjustable
[*][b]Custom: Monthly Rule[/b] — Third or Last (used only when Market Preset = Custom)
[*][b]Custom: Expiry Weekday[/b] — Mon / Tue / Wed / Thu / Fri (used only when Market Preset = Custom)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Session-Aware Design[/b]

Cash equities (TSLA, AAPL, SPY) have a daily bar that sits squarely on the trading date. Futures (NQ, ES, CL) have an overnight session that starts the previous calendar evening. Most VWAP indicators that use `dayofweek(time)` get NQ wrong — they read Friday's session as Thursday because that's when it started.

This indicator uses `time_close("D")`, which always resolves to the trading date's session close — correct for both cash equities and overnight-session futures. No manual configuration needed; it just works on whatever symbol you load.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Disclaimer[/b]

This is a visualization and analytical tool, not financial advice or a signal service. VWAP levels are reference points — they do not guarantee reversals, breakouts, or any specific market behavior. Past price reactions at these levels do not guarantee future ones. Trade with your own risk management. Every trade can lose.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Four volume-weighted anchors. One chart.[/i]
— TechnicalZen

## Source Code

````pine
// Settlement Cycle VWAP Ladder [TechnicalZen] — Pine v6 facelift of VWAP_Period_Specific
//
// Four volume-weighted reference levels stacked across horizons, anchored to the selected market's options expiry rhythm:
//   MONTHLY       — N-day VWMA, step-held from the monthly expiry to the next
//   WEEKLY        — N-day VWMA, step-held from weekly expiry to weekly expiry
//   WEEK-TO-DATE  — cumulative VWAP accumulating bar-by-bar through the week, resets the day after weekly expiry
//   SESSION       — daily cumulative VWAP, resets at each new trading session
//
// Market preset sets expiry conventions:
//   US Standard (3rd Friday)    — SPX/NDX standard monthly options
//   US EOM (Last Friday)        — SPX / SPY end-of-month options
//   Europe (3rd Friday)         — DAX, FTSE, EURO STOXX 50, CAC 40, SMI, IBEX 35, AEX
//   India NSE (Last Thursday)   — NIFTY, Bank NIFTY
//   India BSE (Last Tuesday)    — SENSEX, BANKEX
//   Custom                      — pick your own weekday + month rule
//
// Session awareness: all per-bar accumulators use time("D") / time("W"), which TradingView derives
// from the symbol's native trading session. WTD resets the day AFTER weekly expiry (e.g., Monday for
// Friday-expiry markets, Friday for Thursday-expiry NSE markets) so the week aligns with the options cycle.
//
// Bugs fixed from original:
//   - getLastFriday() was mathematically wrong (dead code) — removed entirely
//   - isFirstBarOfDay used barstate.islast (fires once/chart) — replaced with time("D") change
//   - vwapD was ta.vwma(src, 1) which collapses to src — replaced with proper WTD accumulator
//   - Row label "VWAP_D5" was misleading — renamed to "Week-to-Date"
//   - Plot title "Monthly refernce" was used for weekly line and misspelled — fixed
//
// New:
//   - Upgraded to Pine v6 (from v5)
//   - Table gets a date-header row so each column's timestamp is visible
//   - Inputs grouped and labeled honestly
//   - Per-row toggles for each plot

//@version=6
indicator("Settlement Cycle VWAP Ladder [TechnicalZen]", "Settlement VWAP Ladder [TechnicalZen] ", overlay = true)

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
string marketPreset    = input.string("US Standard (3rd Friday)", "Market Preset",
     options = ["US Standard (3rd Friday)", "US EOM (Last Friday)", "Europe (3rd Friday)", "India NSE (Last Thursday)", "India BSE (Last Tuesday)", "Custom"],
     group = "Market", tooltip = "Sets weekly and monthly options-expiry conventions. 'Custom' exposes manual controls below.")
string customMonthRule = input.string("Last", "Custom: Monthly Rule",          options = ["Third", "Last"], group = "Market", tooltip = "Only used when Market Preset = Custom. 'Third' = 3rd weekday of month (US/EU standard). 'Last' = last weekday of month (US EOM / India).")
string customWeekday   = input.string("Friday", "Custom: Expiry Weekday",      options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"], group = "Market", tooltip = "Only used when Market Preset = Custom. Applies to both weekly and monthly snap days.")

float  src         = input.source(close, "Source",                             group = "Periods")
int    monthlyLen  = input.int(20,   "Monthly VWMA length (days)",             group = "Periods", minval = 1, maxval = 100, tooltip = "Daily VWMA length whose value is snapped on monthly expiry.")
int    weeklyLen   = input.int(5,    "Weekly VWMA length (days)",              group = "Periods", minval = 1, maxval = 20,  tooltip = "Daily VWMA length whose value is snapped on weekly expiry.")

bool   showMonthly = input.bool(true,  "Show Monthly Anchor",                  group = "Plots")
bool   showWeekly  = input.bool(true,  "Show Weekly Anchor",                   group = "Plots")
bool   showWTD     = input.bool(true,  "Show Week-to-Date VWAP",               group = "Plots")
bool   showSession = input.bool(true,  "Show Session VWAP",                    group = "Plots")

bool   showTable   = input.bool(true,  "Show History Table",                   group = "Table")
string tablePos    = input.string("Bottom Left", "Table Position", options = ["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"], group = "Table")
int    histCols    = input.int(20,   "History Columns",                        group = "Table", minval = 5, maxval = 30, tooltip = "How many past bars to show in the table. Newest bar on the right.")
string tblSizeData = input.string("Normal", "Data Cell Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Table", tooltip = "Size for the numeric VWAP cells.")
string tblSizeHdr  = input.string("Normal", "Header/Label Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Table", tooltip = "Size for the date-header row and row labels.")
color  tblBg       = input.color(color.new(color.white, 10), "Table Background", group = "Table")
color  tblText     = input.color(color.black,                "Table Text",     group = "Table")
color  tblHeaderBg = input.color(color.new(color.silver, 30),"Date-Header BG", group = "Table")
color  tblRowLblBg = input.color(color.new(color.silver, 50),"Row-Label BG",   group = "Table")

f_sz(string s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

//---------------------------------------------------------------------------------------------------------------------}
//---------------------------------------------------------------------------------------------------------------------}
// Resolve market preset into a weekday constant and month rule
int expDow = marketPreset == "India NSE (Last Thursday)" ? dayofweek.thursday  :
             marketPreset == "India BSE (Last Tuesday)"  ? dayofweek.tuesday   :
             marketPreset == "Custom" ? (customWeekday == "Monday"    ? dayofweek.monday    :
                                         customWeekday == "Tuesday"   ? dayofweek.tuesday   :
                                         customWeekday == "Wednesday" ? dayofweek.wednesday :
                                         customWeekday == "Thursday"  ? dayofweek.thursday  :
                                                                        dayofweek.friday) :
             dayofweek.friday   // US / Europe default

string monthRule = marketPreset == "US Standard (3rd Friday)" ? "Third"    :
                   marketPreset == "Europe (3rd Friday)"      ? "Third"    :
                   marketPreset == "Custom"                   ? customMonthRule :
                   "Last"   // US EOM, India NSE, India BSE

// "WTD week" starts the day AFTER weekly expiry, so the week aligns with the options cycle
int weekStartDow = expDow == dayofweek.monday    ? dayofweek.tuesday   :
                   expDow == dayofweek.tuesday   ? dayofweek.wednesday :
                   expDow == dayofweek.wednesday ? dayofweek.thursday  :
                   expDow == dayofweek.thursday  ? dayofweek.friday    :
                   expDow == dayofweek.friday    ? dayofweek.monday    :   // skip weekend
                   dayofweek.monday

//---------------------------------------------------------------------------------------------------------------------}
// Helper — expiry day of the month for a given timestamp, per (weekday, rule).
// rule = "Third" → 3rd occurrence of weekday in the month (US/EU standard monthly options)
// rule = "Last"  → last  occurrence of weekday in the month (US EOM, India)
f_expiryDayOfMonth(int t, int targetDow, string rule) =>
    int y = year(t,  syminfo.timezone)
    int m = month(t, syminfo.timezone)
    int result = 0
    if rule == "Third"
        int firstDow    = dayofweek(timestamp(syminfo.timezone, y, m, 1, 0, 0, 0))
        int daysToFirst = (targetDow - firstDow + 7) % 7
        int firstOccur  = 1 + daysToFirst
        int thirdOccur  = firstOccur + 14
        result := timestamp(syminfo.timezone, y, m, thirdOccur, 0, 0, 0)
    else
        // Day 0 of the NEXT month resolves to the last day of THIS month (classic trick).
        int lastDay = dayofmonth(timestamp(syminfo.timezone, y, m + 1, 0, 0, 0, 0))
        result := timestamp(syminfo.timezone, y, m, lastDay, 0, 0, 0)  // fallback
        for i = lastDay - 6 to lastDay
            if dayofweek(timestamp(syminfo.timezone, y, m, i, 0, 0, 0)) == targetDow
                result := timestamp(syminfo.timezone, y, m, i, 0, 0, 0)
    result

int monthlyExpiryTs = f_expiryDayOfMonth(time, expDow, monthRule)

//---------------------------------------------------------------------------------------------------------------------}
// Daily-VWMA source.
// Problem: request.security(sym, "D", expr) with default lookahead_off introduces a 1-bar delay
// on same-TF — meaning on a D chart the VWMA read is always yesterday's value, and the snap can
// land on na for the first 20 bars or misfire entirely. Fix: compute locally when the chart is
// exactly 1 day (1D / D), use request.security with lookahead_on elsewhere so the D-VWMA reflects
// the currently-forming daily bar on intraday charts.
bool _chartIs1D = timeframe.in_seconds() == 86400
float _localVwmaM = ta.vwma(src, monthlyLen)
float _localVwmaW = ta.vwma(src, weeklyLen)
float _secVwmaM   = request.security(syminfo.tickerid, "D", ta.vwma(src, monthlyLen), lookahead = barmerge.lookahead_on)
float _secVwmaW   = request.security(syminfo.tickerid, "D", ta.vwma(src, weeklyLen),  lookahead = barmerge.lookahead_on)
float dailyVwmaMonthly = _chartIs1D ? _localVwmaM : _secVwmaM
float dailyVwmaWeekly  = _chartIs1D ? _localVwmaW : _secVwmaW

// Use the DAILY bar's CLOSE time (not the bar's native `time`) for day-of-week / day-of-month checks.
// Rationale: futures like NQ/ES/CL stamp the daily bar at the session-start time (e.g., Thu 6pm ET for
// Friday's trading session), so `dayofweek(time)` on NQ's "Friday bar" reads Thursday. `time_close("D")`
// resolves to the session close, which sits squarely on the intended trading date — correct for both
// equities (TSLA 4pm ET) and overnight-session futures (NQ Fri 5pm ET).
int _tcDay = time_close("D")

// 1. MONTHLY — N-day daily VWMA, snapshot on monthly expiry, held flat between.
// Guard against na assignment (would clobber a previously-valid snap and leave the cell blank forever).
var float vwapMonthly = na
if dayofmonth(monthlyExpiryTs) == dayofmonth(_tcDay) and month(monthlyExpiryTs) == month(_tcDay) and not na(dailyVwmaMonthly)
    vwapMonthly := dailyVwmaMonthly

// 2. WEEKLY — N-day daily VWMA, snapshot on weekly expiry (every expDow), held flat between
var float vwapWeekly = na
if dayofweek(_tcDay, syminfo.timezone) == expDow and not na(dailyVwmaWeekly)
    vwapWeekly := dailyVwmaWeekly

// 3. WEEK-TO-DATE — cumulative VWAP, accumulates bar-by-bar, resets the day AFTER weekly expiry
bool  isNewWeek = dayofweek(_tcDay, syminfo.timezone) == weekStartDow and dayofweek(_tcDay[1], syminfo.timezone) != weekStartDow
var float wtdPV = 0.0
var float wtdV  = 0.0
wtdPV := isNewWeek ? src * volume : wtdPV + src * volume
wtdV  := isNewWeek ? volume       : wtdV  + volume
float vwapWTD = wtdV > 0 ? wtdPV / wtdV : na

// 4. SESSION — daily cumulative VWAP, resets at each new trading session.
// time("D") respects the symbol's native session boundary, so this is session-aware without further work.
bool  isNewDay = time("D") != time("D")[1]
var float sessPV = 0.0
var float sessV  = 0.0
sessPV := isNewDay ? src * volume : sessPV + src * volume
sessV  := isNewDay ? volume       : sessV  + volume
float vwapSession = sessV > 0 ? sessPV / sessV : na

//---------------------------------------------------------------------------------------------------------------------}
// Plots — direction-aware coloring
color colMonth = vwapMonthly > nz(vwapMonthly[1], vwapMonthly) ? color.aqua  : vwapMonthly < nz(vwapMonthly[1], vwapMonthly) ? color.purple : color.rgb(182, 210, 20)
color colWeek  = vwapWeekly  > nz(vwapWeekly[1],  vwapWeekly)  ? color.green : vwapWeekly  < nz(vwapWeekly[1],  vwapWeekly)  ? color.red    : color.rgb(28, 224, 178)
color colWTD   = vwapWTD     > nz(vwapWTD[1],     vwapWTD)     ? color.aqua  : vwapWTD     < nz(vwapWTD[1],     vwapWTD)     ? color.purple : color.rgb(195, 47, 225)

plot(showMonthly ? vwapMonthly : na, "VWAP Monthly", color = colMonth,     linewidth = 1, style = plot.style_stepline_diamond)
plot(showWeekly  ? vwapWeekly  : na, "VWAP Weekly",  color = colWeek,      linewidth = 2, style = plot.style_stepline_diamond)
plot(showWTD     ? vwapWTD     : na, "VWAP WTD",     color = colWTD,       linewidth = 1, style = plot.style_circles, join = true)
plot(showSession ? vwapSession : na, "VWAP Session", color = color.yellow, linewidth = 1)

//---------------------------------------------------------------------------------------------------------------------}
// Table — date-header row + 4 VWAP rows × histCols data cells
if showTable and barstate.islast
    string _pos = tablePos == "Top Left"     ? position.top_left     :
                  tablePos == "Top Right"    ? position.top_right    :
                  tablePos == "Middle Left"  ? position.middle_left  :
                  tablePos == "Middle Right" ? position.middle_right :
                  tablePos == "Bottom Right" ? position.bottom_right :
                                               position.bottom_left

    var table T = table.new(_pos, histCols + 1, 5, bgcolor = tblBg, border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1)

    // Resolve user text-size selections
    string _szD = f_sz(tblSizeData)
    string _szH = f_sz(tblSizeHdr)

    // Date format — compact on intraday, readable on daily+
    string dateFmt = timeframe.isintraday ? "dd HH:mm" : "dd MMM"

    // Row 0 — date headers (newest on the right)
    T.cell(0, 0, "Date/Time", text_color = tblText, bgcolor = tblHeaderBg, text_size = _szH, text_halign = text.align_center)
    for i = 0 to histCols - 1
        int col = histCols - i
        T.cell(col, 0, str.format_time(time[i], dateFmt, syminfo.timezone), text_color = tblText, bgcolor = tblHeaderBg, text_size = _szH, text_halign = text.align_center)

    // Row labels (column 0)
    T.cell(0, 1, "Monthly",      text_color = tblText, bgcolor = tblRowLblBg, text_size = _szH, text_halign = text.align_left)
    T.cell(0, 2, "Weekly",       text_color = tblText, bgcolor = tblRowLblBg, text_size = _szH, text_halign = text.align_left)
    T.cell(0, 3, "Week-to-Date", text_color = tblText, bgcolor = tblRowLblBg, text_size = _szH, text_halign = text.align_left)
    T.cell(0, 4, "Session",      text_color = tblText, bgcolor = tblRowLblBg, text_size = _szH, text_halign = text.align_left)

    // Data cells (direction-coded text color)
    for i = 0 to histCols - 1
        int col = histCols - i
        float mVal  = vwapMonthly[i]
        float wVal  = vwapWeekly[i]
        float tVal  = vwapWTD[i]
        float sVal  = vwapSession[i]
        float mPrev = vwapMonthly[i + 1]
        float wPrev = vwapWeekly[i + 1]
        float tPrev = vwapWTD[i + 1]
        float sPrev = vwapSession[i + 1]

        color mTxt = not na(mVal) and not na(mPrev) ? (mVal > mPrev ? color.lime : mVal < mPrev ? color.fuchsia             : tblText) : tblText
        color wTxt = not na(wVal) and not na(wPrev) ? (wVal > wPrev ? color.green : wVal < wPrev ? color.red                 : tblText) : tblText
        color tTxt = not na(tVal) and not na(tPrev) ? (tVal > tPrev ? color.rgb(107, 135, 236) : tVal < tPrev ? color.rgb(236, 135, 107) : tblText) : tblText
        color sTxt = not na(sVal) and not na(sPrev) ? (sVal > sPrev ? color.blue : sVal < sPrev ? color.orange              : tblText) : tblText

        T.cell(col, 1, na(mVal) ? "—" : str.tostring(math.round(mVal, 2)), text_color = mTxt, text_size = _szD, text_halign = text.align_center)
        T.cell(col, 2, na(wVal) ? "—" : str.tostring(math.round(wVal, 2)), text_color = wTxt, text_size = _szD, text_halign = text.align_center)
        T.cell(col, 3, na(tVal) ? "—" : str.tostring(math.round(tVal, 2)), text_color = tTxt, text_size = _szD, text_halign = text.align_center)
        T.cell(col, 4, na(sVal) ? "—" : str.tostring(math.round(sVal, 2)), text_color = sTxt, text_size = _szD, text_halign = text.align_center)

//---------------------------------------------------------------------------------------------------------------------}
````
