# Untested Levels - PD Highs, Lows & Gaps

- url: https://www.tradingview.com/script/IE8SwdY0-Untested-Levels-PD-Highs-Lows-Gaps/
- type: indicator
- pine_id: PUB;e49c0efe50be4770b8f5cc6cf5a26a47
- version: 2.0

## Description

Untested Levels automatically maps the session prices futures traders commonly mark by hand: previous regular-session highs and lows, current and prior overnight highs and lows, previous closes and unfilled gap levels, plus the all-time high.

The purpose is simple: spend less time redrawing levels every morning and keep important price context visible as the market develops. Each line begins where its high, low, or close was established and is labeled with both its name and exact price.

The indicator is designed around the session structure of CME equity index futures, particularly Nasdaq futures (NQ/MNQ) and S&P 500 futures (ES/MES). Its session times are fully configurable, so the same framework can be used with other futures markets whose trading sessions are defined appropriately.

[b]WHY IT IS DIFFERENT[/b]

Many session-level tools either show only the most recent day or remove a level as soon as price reaches it. This indicator maintains a structured history and treats a level's first breach separately from its display timing.

By default, a prior level that is breached during the current trading day remains visible until the day rolls over. This preserves the line for the rest of the session, allowing you to see whether a former high or low is subsequently respected, rejected, or used as support or resistance. If you prefer immediate removal, the "Hide breached levels immediately" setting is available.

Regular-session highs and lows, overnight highs and lows, and prior closes each have their own lookback setting. You can retain more history for one class of level without overcrowding the chart with every other class.

The calculations are session-defined rather than chart-defined. They are built from the symbol's extended-hours feed, so switching the chart between Regular Trading Hours and Electronic Trading Hours does not change the underlying levels. An RTH chart can therefore remain visually clean while still displaying the overnight high and low.

[b]LEVEL NAMES[/b]

The numbering follows trading days, not calendar dates. The overnight session belongs to the same trading day as the regular session that follows it.

    YD High / YD Low
    Yesterday's regular-session high and low.

    PD 2 High / PD 2 Low
    The regular-session high and low from two trading days ago.
    PD 3, PD 4, and later numbers continue in the same way.
    YD is effectively the first prior trading day, so there is no separate
    "PD 1 High" or "PD 1 Low" label.

    ON High / ON Low
    The current trading day's overnight-session high and low.
    These update while the overnight session is forming.

    ETH 1 High / ETH 1 Low
    The overnight high and low associated with yesterday's regular session.
    ETH 1 therefore pairs with YD.

    ETH 2 High / ETH 2 Low
    The overnight high and low from two trading days ago.
    ETH 2 pairs with PD 2, ETH 3 pairs with PD 3, and so on.

    YD Close
    The most recent configured session close. This level always displays when
    previous-close levels are enabled.

    PD 2 Close, PD 3 Close, etc.
    Older configured closes that remain unfilled by a later regular session.
    These levels identify still-open historical gaps within the selected
    gap lookback.

    ATH
    The all-time high. If a displayed high is also the all-time high, its
    normal label receives an ATH prefix. If the all-time high is not one of
    the displayed session levels, a separate ATH line is drawn.

[b]SESSION CALCULATIONS[/b]

Each configured trading day is divided into three parts:

    Overnight session:
    Trading-day start to the regular-session open.
    This produces ON and ETH highs and lows.

    Regular session:
    Regular-session open to regular-session close.
    This produces YD and PD highs and lows.

    Post-close tail:
    Regular-session close to the next trading-day start.
    This does not create a new session high or low, but its price action can
    breach an existing level.

The default times are expressed in Pacific Time:

    Trading day starts:       15:00
    Regular session opens:    06:30
    Regular session closes:   13:15
    Close candle opens:       13:55

The time zone and all session boundaries can be changed in the settings. The "Close candle" input identifies the opening time of the candle whose closing price will be stored. If that exact candle is unavailable, the script uses the last available candle before the selected time.

[b]WHAT COUNTS AS UNTESTED[/b]

A prior regular-session high remains unbreached until later price trades above it. A prior regular-session low remains unbreached until later price trades below it. The calculation considers price action after the level's own regular session, including that day's post-close tail, later overnight sessions, and later regular sessions.

An overnight high or low is evaluated only against price action after that overnight session ends. This prevents the price action that created the level from also invalidating it.

By default, an exact touch does not count as a breach; price must trade through the level. Enable "Exact touch counts as a breach" if you want a touch to invalidate it.

YD High, YD Low, ON High, ON Low, and YD Close remain available as current reference levels even when tested. Older PD and ETH levels are filtered according to their breach status and your selected display timing.

[b]PREVIOUS CLOSES AND GAPS[/b]

YD Close always shows when enabled. Older closes appear as PD n Close only while their gap remains unfilled.

Gap status is based on later regular-session price action. Overnight and post-close-tail activity do not fill a close gap. This keeps the gap logic aligned with the cash-session context rather than allowing overnight movement alone to remove the level.

An alert condition is included for price touching or crossing YD Close during the regular session.

[b]ALL-TIME HIGH[/b]

The ATH calculation combines available chart history, extended-hours intraday history, and extended daily history. If the ATH matches a displayed high, that label is prefixed with ATH and emphasized. Otherwise, the indicator creates a standalone ATH level so the price remains marked even when it falls outside the selected session lookbacks.

[b]LOOKBACKS AND DISPLAY CONTROLS[/b]

The indicator provides independent controls for:

    • Regular-session high/low lookback
    • Overnight high/low lookback
    • Prior-close and gap lookback
    • YD, PD, ON, ETH, close, ATH, and label visibility
    • Immediate or end-of-day removal of breached levels
    • Exact-touch breach behavior
    • Session times and time zone
    • Colors, line style, line width, label size, and label offset

Separating the lookbacks makes it possible to retain a broad history of untested highs and lows while using a shorter window for overnight levels or gaps.

[b]RTH AND ETH CHART BEHAVIOR[/b]

All session values are requested from extended-hours data, so the same calculated levels appear whether the chart is displaying RTH or ETH candles.

TradingView scripts only execute when the chart receives a bar. An RTH chart therefore cannot update live while its chart session is closed. To handle this, "Roll levels at the regular session close" is enabled by default. It advances the labels and removes levels breached during the completed day on the final regular-session bar, leaving a frozen RTH chart in the correct end-of-session state. The extended-hours feed completes the normal rollover when the next chart session begins.

For live overnight development of ON High and ON Low, use an ETH chart.

[b]HOW TO USE THE LEVELS[/b]

These lines identify historically significant prices; they do not predict which level price will visit or how price will react when it gets there. Traders may use them as context for targets, breakouts, failed breakouts, support/resistance flips, gap fills, and confluence with their own trade setups.

The retained-line behavior is especially useful after a breach: instead of losing the reference immediately, you can observe whether price returns to the level and changes its behavior around it later in the same session.

[b]LIMITATIONS[/b]

This indicator is intended for intraday charts. Its session calculations use an extended-hours intraday feed, set to five minutes by default. Available lookback depth depends on the amount of intraday history TradingView provides for the symbol and the user's plan.

Session defaults are designed for the stated CME equity index futures workflow. Confirm and adjust the time zone, trading-day start, regular-session boundaries, and close-candle time before using the indicator on another market.

Holiday schedules, shortened sessions, missing bars, exchange data differences, and delayed feeds can affect the levels. Use standard price charts and verify the settings for the instrument being traded.

Untested Levels is a charting and market-context tool, not a trading system. It does not provide entries, exits, profit targets, or guarantees of future support or resistance.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Macrodoser
//@version=6
indicator("Untested Levels - PD Highs, Lows & Gaps", "UT Lvls", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── Display toggles ──────────────────────────────────────────────
// Quick on/off switches for every line type, all in one place.
grpT = "Display toggles"
showYD          = input.bool(true, "Show YD High/Low", group = grpT)
showPD          = input.bool(true, "Show unbreached PD Highs/Lows", group = grpT)
showON          = input.bool(true, "Show Overnight High/Low", group = grpT, tooltip = "Today's overnight session (the vivid ON High/Low lines).")
showPriorON     = input.bool(true, "Show unbreached ETH Highs/Lows", group = grpT, tooltip = "Prior days' overnight levels (ETH n High/Low) while unbreached.")
showPrevClose   = input.bool(true, "Show YD Close", group = grpT)
showPriorCloses = input.bool(true, "Show prior gap closes (PD n Close)", group = grpT, tooltip = "Show closes older than yesterday while their gap is unfilled. Off = only YD Close.")
showATH         = input.bool(true, "Show ATH (all-time high)", group = grpT, tooltip = "Off = no standalone ATH line and no bold ATH prefix on level labels.")
showLabels      = input.bool(true, "Show labels", group = grpT, tooltip = "Off = draw the level lines only, with no name/price labels. Lines are unaffected.")

// ─── Session ──────────────────────────────────────────────────────
grpS = "Session"
tz            = input.string("America/Los_Angeles", "Time zone", options = ["America/Los_Angeles", "America/Denver", "America/Phoenix", "America/Chicago", "America/New_York", "America/Anchorage", "Pacific/Honolulu", "America/Vancouver", "America/Toronto", "America/Mexico_City", "America/Bogota", "America/Lima", "America/Santiago", "America/Sao_Paulo", "America/Argentina/Buenos_Aires", "Europe/London", "Europe/Dublin", "Europe/Lisbon", "Europe/Madrid", "Europe/Paris", "Europe/Amsterdam", "Europe/Brussels", "Europe/Zurich", "Europe/Berlin", "Europe/Rome", "Europe/Stockholm", "Europe/Oslo", "Europe/Copenhagen", "Europe/Warsaw", "Europe/Athens", "Europe/Helsinki", "Europe/Istanbul", "Europe/Moscow", "Africa/Johannesburg", "Asia/Jerusalem", "Asia/Riyadh", "Asia/Dubai", "Asia/Karachi", "Asia/Kolkata", "Asia/Bangkok", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Taipei", "Asia/Seoul", "Asia/Tokyo", "Australia/Perth", "Australia/Sydney", "Australia/Melbourne", "Pacific/Auckland", "UTC"], group = grpS, tooltip = "Time zone the session times below are interpreted in. Defaults match CME Globex hours expressed in US Pacific time — if you change the time zone, adjust the session times to match.")
startHour     = input.int(15, "Trading day starts — hour (0–23)", minval = 0, maxval = 23, group = grpS)
startMinute   = input.int(0, "Trading day starts — minute", minval = 0, maxval = 59, group = grpS)
rthHour       = input.int(6, "Regular session opens — hour (0–23)", minval = 0, maxval = 23, group = grpS)
rthMinute     = input.int(30, "Regular session opens — minute", minval = 0, maxval = 59, group = grpS)
rthCloseHour  = input.int(13, "Regular session closes — hour (0–23)", minval = 0, maxval = 23, group = grpS, tooltip = "Enter the ACTUAL close time (default 13:15). Candles are counted by their open time, so on a 5-minute feed the 13:10 candle — which closes at 13:15 — is still included. Do not enter 13:10 here.")
rthCloseMin   = input.int(15, "Regular session closes — minute", minval = 0, maxval = 59, group = grpS)
touchIsBreach = input.bool(false, "Exact touch counts as a breach", group = grpS)
instantHide   = input.bool(false, "Hide breached levels immediately (instead of at day end)", group = grpS)
rollAtClose   = input.bool(true, "Roll levels at the regular session close (instead of day end)", group = grpS)

// ─── Previous day highs & lows ────────────────────────────────────
grpP = "Previous day highs & lows"
lookback   = input.int(30, "Days to look back", minval = 1, maxval = 90, group = grpP, tooltip = "Applies to the YD/PD High-Low levels only — overnight levels and gap closes have their own lookbacks.")
inclTail   = input.bool(false, "Include post-close session in PD/YD levels", group = grpP, tooltip = "Off (default, cash-focused): PD/YD High/Low are strictly the regular session, and the post-close tail (default 1:15–3:00 PM) is ignored for its own day — it can neither set the level nor breach it, so the cash extreme stays marked even if the tail trades through it. On (futures-friendly): levels run from the regular open to the day end, so a tail extreme sets/moves the level. Either way the tail still counts toward breaching OLDER days' levels, and gap fills are regular-session-only.")
hiColor    = input.color(color.new(#03FF0E, 0), "High color", group = grpP)
loColor    = input.color(color.new(#FF1001, 0), "Low color", group = grpP)

// ─── Overnight levels ─────────────────────────────────────────────
grpO = "Overnight levels"
onLookback = input.int(10, "Overnight lookback (days)", minval = 1, maxval = 90, group = grpO)
onTf       = input.timeframe("5", "Overnight data timeframe", group = grpO)
curOnHiColor = input.color(color.new(#FF9800, 0), "ON high color (today's overnight)", group = grpO)
curOnLoColor = input.color(color.new(#FF9800, 0), "ON low color (today's overnight)", group = grpO)
onHiColor    = input.color(color.new(#00E2FF, 0), "ETH high color (prior days)", group = grpO)
onLoColor    = input.color(color.new(#FFE501, 0), "ETH low color (prior days)", group = grpO)

// ─── Previous close ───────────────────────────────────────────────
grpC = "Previous close"
pcHour        = input.int(13, "Close candle — hour (0–23)", minval = 0, maxval = 23, group = grpC, tooltip = "The line marks the CLOSE of the candle that OPENS at this time (default 13:55 = the regular-session settlement candle). Example: to mark the 13:15 close on a 5-minute feed, enter 13:10 — the open of the candle that closes at 13:15. If that exact candle is missing, the last candle before it is used. Captured from the extended-hours feed, so it shows on RTH and ETH charts alike.")
pcMinute      = input.int(55, "Close candle — minute", minval = 0, maxval = 59, group = grpC)
pcColor       = input.color(color.new(#FF00FF, 0), "Close color", group = grpC)
pcLookback    = input.int(10, "Gap lookback (days)", minval = 1, maxval = 90, group = grpC, tooltip = "How many prior daily closes to track. YD Close always shows; older closes ('PD n Close') show only while their gap is unfilled — no later REGULAR session has traded back to the level (overnight action doesn't fill a gap).")
alertGapFill  = input.bool(true, "Alert when price touches YD Close (gap fill)", group = grpC)

// ─── General ──────────────────────────────────────────────────────
// Styling shared by every level type.
grpG = "General"
lineWidth  = input.int(1, "Line width", minval = 1, maxval = 4, group = grpG)
lineStyleOpt = input.string("dotted", "Line style", options = ["dotted", "dashed", "solid"], group = grpG)
lblSizeOpt = input.string("small", "Label size", options = ["tiny", "small", "normal", "large"], group = grpG)
lblOffset  = input.int(8, "Label offset (bars right of last candle)", minval = 0, maxval = 100, group = grpG)
lblTransp  = input.int(80, "Label background transparency", minval = 0, maxval = 100, group = grpG, tooltip = "Labels take their level's color: the text is drawn in it and the background is a semi-transparent tint of it.")
athColor   = input.color(color.new(#FFFFFF, 0), "ATH color (standalone line/label)", group = grpG)

lblSize = switch lblSizeOpt
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    => size.large

lineStyle = switch lineStyleOpt
    "dotted" => line.style_dotted
    "dashed" => line.style_dashed
    => line.style_solid

// Label factory — takes the level's color: text drawn in it, background a
// semi-transparent tint of it (same look as the ADR Projection labels).
// ATH levels get an "ATH" prefix and bold text. Returns na (no label) when
// labels are toggled off — the lines are drawn independently either way.
f_mkLabel(int x, float y, string txt, color col, bool bold) =>
    showLabels ? label.new(x, y, txt, xloc.bar_index, yloc.price, color.new(col, lblTransp), label.style_label_left, col, lblSize, text_formatting = bold ? text.format_bold : text.format_none) : label(na)

// Line factory — the line ends exactly at the label's tip (lblOffset bars
// past the last candle; future bars are uniformly spaced by the chart
// timeframe, so bar offset * timeframe converts to a time coordinate).
// The second anchor is forced at least one full chart bar right of the
// first: level timestamps come from the intraday data feed, which can sit
// up to a bar AHEAD of the chart bar's open time, so a level that forms on
// the current bar could otherwise produce a near-zero-length line that
// TradingView renders as a vertical tick.
int tfMs = timeframe.in_seconds() * 1000
f_mkLine(int t1, float y, color col) =>
    line.new(t1, y, math.max(time + lblOffset * tfMs, t1 + tfMs), y, xloc.bar_time, extend.none, col, lineStyle, lineWidth)

// Running all-time max of high + the time it printed
// (one independent instance per call site)
f_runMax() =>
    var float a = na
    var int   t = na
    if na(a) or high > a
        a := high
        t := time
    [a, t]

// ─── Trading-day boundary ─────────────────────────────────────────
// A "trading day" starts at the chosen hour:minute in the chosen time
// zone (default 15:00 America/Los_Angeles = CME Globex open).
startMins    = startHour * 60 + startMinute
rthMins      = rthHour * 60 + rthMinute
rthCloseMins = rthCloseHour * 60 + rthCloseMin
pcMins       = pcHour * 60 + pcMinute

f_minsIntoDay() =>
    mid = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 0, 0)
    [math.floor((time - mid) / 60000), mid]

f_dayStart() =>
    [mins, mid] = f_minsIntoDay()
    mins >= startMins ? mid + startMins * 60000 : mid + startMins * 60000 - 86400000

// ─── Session tracking (runs on the extended-hours feed) ───────────
// Executes inside request.security on the extended version of the
// symbol, so it sees every session regardless of the chart's RTH/ETH
// mode. Each trading day is split by the clock into three portions:
//   overnight (day start → regular open)  → ON/ETH levels
//   regular   (regular open → close)      → PD/YD levels
//   tail      (regular close → day end)   → folded into the PD/YD level
//              with the tail toggle on; ignored for its own day's levels
//              otherwise (it can neither set nor breach them), though it
//              still counts in the full-day extremes that breach OLDER
//              days' levels
// Full-day and post-open ("rest") extremes are kept for breach logic;
// the rest extremes (with timestamps) also become the PD/YD levels when
// the post-close tail is folded in via the toggle.
f_eth() =>
    int  ds = f_dayStart()
    bool nd = na(ds[1]) or ds != ds[1]
    [mins, _] = f_minsIntoDay()
    bool isON  = mins >= startMins or mins < rthMins
    bool isRTH = mins >= rthMins and mins < rthCloseMins
    var float ethHi   = na
    var float ethLo   = na
    var float restHi  = na
    var float restLo  = na
    var int   restHiT = na
    var int   restLoT = na
    var float rthHi   = na
    var float rthLo   = na
    var int   rthHiT  = na
    var int   rthLoT  = na
    var float onHi    = na
    var float onLo    = na
    var int   onHiT   = na
    var int   onLoT   = na
    var bool  onLive  = false
    var float onHiD   = na
    var float onLoD   = na
    var int   onHiTD  = na
    var int   onLoTD  = na
    var int   onIdD   = na
    var float ethHiD  = na
    var float ethLoD  = na
    var float restHiD = na
    var float restLoD = na
    var int   restHiTD = na
    var int   restLoTD = na
    var float rthHiD  = na
    var float rthLoD  = na
    var int   rthHiTD = na
    var int   rthLoTD = na
    var int   ethIdD  = na
    var float athE    = na
    var int   athET   = na
    var float pcCl    = na
    var int   pcClT   = na
    var float pcClD   = na
    var int   pcClTD  = na
    if nd
        // finalize an overnight that ran to the end of its day (holidays)
        if onLive
            onHiD  := onHi
            onLoD  := onLo
            onHiTD := onHiT
            onLoTD := onLoT
            onIdD  := ds[1]
            onLive := false
        if not na(ethHi)
            ethHiD  := ethHi
            ethLoD  := ethLo
            restHiD := restHi
            restLoD := restLo
            restHiTD := restHiT
            restLoTD := restLoT
            rthHiD  := rthHi
            rthLoD  := rthLo
            rthHiTD := rthHiT
            rthLoTD := rthLoT
            ethIdD  := ds[1]
        // finalize the day's session close (holidays with no capture keep the prior one)
        if not na(pcCl)
            pcClD  := pcCl
            pcClTD := pcClT
        pcCl   := na
        pcClT  := na
        ethHi  := na
        ethLo  := na
        restHi := na
        restLo := na
        restHiT := na
        restLoT := na
        rthHi  := na
        rthLo  := na
        rthHiT := na
        rthLoT := na
        onHi   := na
        onLo   := na
        onHiT  := na
        onLoT  := na
        onLive := isON
    if onLive and not isON
        // regular session opened — overnight is complete
        onHiD  := onHi
        onLoD  := onLo
        onHiTD := onHiT
        onLoTD := onLoT
        onIdD  := ds
        onLive := false
    // accumulate this bar into its portions
    ethHi := na(ethHi) ? high : math.max(ethHi, high)
    ethLo := na(ethLo) ? low : math.min(ethLo, low)
    // running capture of the day's session close: the close of the last
    // bar that OPENS at or before the close-candle time (default 13:55)
    if mins <= pcMins and mins < startMins
        pcCl  := close
        pcClT := time
    if na(athE) or high > athE
        athE  := high
        athET := time
    if onLive
        if na(onHi) or high > onHi
            onHi  := high
            onHiT := time
        if na(onLo) or low < onLo
            onLo  := low
            onLoT := time
    if isRTH
        if na(rthHi) or high > rthHi
            rthHi  := high
            rthHiT := time
        if na(rthLo) or low < rthLo
            rthLo  := low
            rthLoT := time
    if not isON
        if na(restHi) or high > restHi
            restHi  := high
            restHiT := time
        if na(restLo) or low < restLo
            restLo  := low
            restLoT := time
    [onHiD, onLoD, onHiTD, onLoTD, onIdD, ethHiD, ethLoD, restHiD, restLoD, rthHiD, rthLoD, rthHiTD, rthLoTD, ethIdD, ethHi, ethLo, restHi, restLo, ds, onHi, onLo, onHiT, onLoT, onLive, athE, athET, rthHi, rthLo, rthHiT, rthLoT, pcClD, pcClTD, pcCl, pcClT, restHiTD, restLoTD, restHiT, restLoT]

ethTicker = ticker.modify(syminfo.tickerid, session.extended)
[onHiD, onLoD, onHiTD, onLoTD, onIdD, ethHiD, ethLoD, restHiD, restLoD, rthHiD, rthLoD, rthHiTD, rthLoTD, ethIdD, ethHiLive, ethLoLive, restHiLive, restLoLive, ethCurId, onHiLive, onLoLive, onHiTLive, onLoTLive, onLiveNow, athEth, athETime, rthHiLive, rthLoLive, rthHiTLive, rthLoTLive, pcCloseD, pcCloseTD, pcCloseLive, pcCloseTLive, restHiTimeD, restLoTimeD, restHiTLive, restLoTLive] = request.security(ethTicker, onTf, f_eth())

// ─── Early rollover at the regular-session close ──────────────────
// An RTH chart never sees the 3 PM day end — it freezes at the close.
// So on the FINAL bar of the regular session (and through the tail on
// ETH charts), the display rolls early: today becomes YD, numbering
// shifts, and today's action counts toward breaches. The real feed
// rollover at the day end takes over seamlessly with the same values.
float tfMin = timeframe.in_seconds() / 60.0
[chartMins, chartMid] = f_minsIntoDay()
bool rollNow = rollAtClose and chartMins >= rthMins and chartMins < startMins and chartMins + tfMin >= rthCloseMins

// ─── YD Close ─────────────────────────────────────────────────────
// Yesterday's session close (close of the candle opening at the
// close-candle time, default 13:55). After the early roll it becomes
// today's — best-available on a frozen RTH chart (whose bars stop
// before 13:55), exact on ETH, and corrected at the next session.
float ydClose = rollNow and not na(pcCloseLive) ? pcCloseLive : pcCloseD

// Gap-fill alert: price touches or crosses YD Close during the regular session
bool inRegNow = chartMins >= rthMins and chartMins < rthCloseMins
bool gapFill = alertGapFill and showPrevClose and inRegNow and not na(ydClose) and ((low <= ydClose and high >= ydClose) or (close[1] < ydClose and close >= ydClose) or (close[1] > ydClose and close <= ydClose))
alertcondition(gapFill, title = "YD Close touched (gap fill)", message = "Price touched YD Close - gap filled on {{ticker}}")

// ─── All-time high ────────────────────────────────────────────────
// True ATH = max of the chart's own history, the intraday extended
// feed, and the extended DAILY feed (daily history reaches back
// decades, so an old ATH beyond intraday history still counts).
// Intraday sources win ties so the line anchors with wick precision.
[athChart, athChartT] = f_runMax()
[athDaily, athDailyT] = request.security(ethTicker, "1D", f_runMax())
float ath  = athChart
int   athT = athChartT
if not na(athEth) and athEth >= ath
    ath  := athEth
    athT := athETime
if not na(athDaily) and athDaily > ath
    ath  := athDaily
    athT := athDailyT

// ─── Archive completed sessions ───────────────────────────────────
var pdHis   = array.new<float>()   // PD/YD levels (RTH-only unless the tail toggle is on)
var pdLos   = array.new<float>()
var pdHiTs  = array.new<int>()
var pdLoTs  = array.new<int>()
var pdIds   = array.new<int>()
var onHighs   = array.new<float>() // overnight (ON/ETH) levels
var onLows    = array.new<float>()
var onHiTimes = array.new<int>()
var onLoTimes = array.new<int>()
var onIds     = array.new<int>()
var gapHis  = array.new<float>()   // RTH-only extremes — gap fills stay regular-session-pure
var gapLos  = array.new<float>()   // even when the tail is folded into the PD levels
var pdCls   = array.new<float>()   // daily session closes (gap levels)
var pdClTs  = array.new<int>()
var pdClIds = array.new<int>()
var ethHis  = array.new<float>()   // full-day + post-open data for breach checks
var ethLos  = array.new<float>()
var restHis = array.new<float>()
var restLos = array.new<float>()
var ethIds  = array.new<int>()

if not na(onIdD) and (array.size(onIds) == 0 or array.get(onIds, array.size(onIds) - 1) != onIdD)
    array.push(onHighs, onHiD)
    array.push(onLows, onLoD)
    array.push(onHiTimes, onHiTD)
    array.push(onLoTimes, onLoTD)
    array.push(onIds, onIdD)
    if array.size(onIds) > onLookback
        array.shift(onHighs)
        array.shift(onLows)
        array.shift(onHiTimes)
        array.shift(onLoTimes)
        array.shift(onIds)

if not na(ethIdD) and (array.size(ethIds) == 0 or array.get(ethIds, array.size(ethIds) - 1) != ethIdD)
    array.push(ethHis, ethHiD)
    array.push(ethLos, ethLoD)
    array.push(restHis, restHiD)
    array.push(restLos, restLoD)
    array.push(ethIds, ethIdD)
    if array.size(ethIds) > math.max(math.max(lookback, onLookback), pcLookback) + 2
        array.shift(ethHis)
        array.shift(ethLos)
        array.shift(restHis)
        array.shift(restLos)
        array.shift(ethIds)
    // days with no regular session (full holidays) don't produce a PD level.
    // By default the PD level is RTH-only; with the tail toggle on it's
    // the post-open extreme (regular open → day end) instead. The gap
    // arrays always keep the RTH-only extremes for gap-fill checks.
    if not na(rthHiD)
        array.push(pdHis, inclTail ? restHiD : rthHiD)
        array.push(pdLos, inclTail ? restLoD : rthLoD)
        array.push(pdHiTs, inclTail ? restHiTimeD : rthHiTD)
        array.push(pdLoTs, inclTail ? restLoTimeD : rthLoTD)
        array.push(gapHis, rthHiD)
        array.push(gapLos, rthLoD)
        array.push(pdIds, ethIdD)
        // retained to the larger of the two lookbacks: the PD display loop
        // is capped at `lookback`, while gap-fill checks may reach further
        if array.size(pdIds) > math.max(lookback, pcLookback)
            array.shift(pdHis)
            array.shift(pdLos)
            array.shift(pdHiTs)
            array.shift(pdLoTs)
            array.shift(gapHis)
            array.shift(gapLos)
            array.shift(pdIds)
        // archive the day's session close for gap tracking
        if not na(pcCloseD)
            array.push(pdCls, pcCloseD)
            array.push(pdClTs, pcCloseTD)
            array.push(pdClIds, ethIdD)
            if array.size(pdClIds) > pcLookback
                array.shift(pdCls)
                array.shift(pdClTs)
                array.shift(pdClIds)

// ─── Draw levels (recomputed on the latest bar) ───────────────────
var lines  = array.new<line>()
var labels = array.new<label>()

if barstate.islast
    for ln in lines
        line.delete(ln)
    array.clear(lines)
    for lb in labels
        if not na(lb)
            label.delete(lb)
    array.clear(labels)

    int lblX  = bar_index + lblOffset
    float eps = syminfo.mintick * 0.25    // tolerance for ATH comparison
    bool athDrawn = false                 // did any drawn level carry the ATH flag?
    bool rolled   = rollNow and not na(rthHiLive)

    // Early-rolled YD from today's live regular session. With the tail
    // folded in, the level keeps updating through the post-close tail on
    // ETH charts (a frozen RTH chart catches up at its next tick).
    if rolled and showYD
        float eyHi  = inclTail ? restHiLive : rthHiLive
        float eyLo  = inclTail ? restLoLive : rthLoLive
        int   eyHiT = inclTail ? restHiTLive : rthHiTLive
        int   eyLoT = inclTail ? restLoTLive : rthLoTLive
        bool eyAth = showATH and eyHi >= ath - eps
        athDrawn := athDrawn or eyAth
        array.push(lines, f_mkLine(eyHiT, eyHi, hiColor))
        array.push(labels, f_mkLabel(lblX, eyHi, (eyAth ? "ATH  " : "") + "YD High  " + str.tostring(eyHi, format.mintick), hiColor, eyAth))
        array.push(lines, f_mkLine(eyLoT, eyLo, loColor))
        array.push(labels, f_mkLabel(lblX, eyLo, "YD Low  " + str.tostring(eyLo, format.mintick), loColor, false))

    // ── YD Close & prior unfilled gap closes ──
    // YD Close always shows. Older closes ("PD n Close") show only while
    // their gap is unfilled — no later day's range has reached the level.
    // All closes share one color/styling. The early roll shifts numbering
    // by one and promotes today's live close to YD Close, like the PD levels.
    if showPrevClose
        if rolled and not na(pcCloseLive)
            array.push(lines, f_mkLine(pcCloseTLive, pcCloseLive, pcColor))
            array.push(labels, f_mkLabel(lblX, pcCloseLive, "YD Close  " + str.tostring(pcCloseLive, format.mintick), pcColor, false))
        int nc = array.size(pdCls)
        if nc > 0
            for k = 1 to nc
                int ci    = nc - k               // k = days back (1 = yesterday)
                int dispC = k + (rolled ? 1 : 0)
                float cv  = array.get(pdCls, ci)
                int   cid = array.get(pdClIds, ci)
                // gap filled = a later REGULAR session's range reached the
                // close level — overnight/tail action never fills a gap
                // (the gap arrays stay RTH-only regardless of the PD tail
                // toggle). In default end-of-day mode the current live day
                // is ignored, so a gap filled today survives until the roll.
                float bHi = instantHide or rolled ? rthHiLive : na
                float bLo = instantHide or rolled ? rthLoLive : na
                int j = array.size(pdIds) - 1
                while j >= 0 and array.get(pdIds, j) > cid
                    float ch = array.get(gapHis, j)
                    float cl = array.get(gapLos, j)
                    if not na(ch)
                        bHi := na(bHi) ? ch : math.max(bHi, ch)
                    if not na(cl)
                        bLo := na(bLo) ? cl : math.min(bLo, cl)
                    j -= 1
                bool gapFilled = not na(bHi) and not na(bLo) and (touchIsBreach ? bHi >= cv and bLo <= cv : bHi > cv and bLo < cv)
                if dispC == 1 or (showPriorCloses and not gapFilled)
                    array.push(lines, f_mkLine(array.get(pdClTs, ci), cv, pcColor))
                    array.push(labels, f_mkLabel(lblX, cv, (dispC == 1 ? "YD Close  " : "PD " + str.tostring(dispC) + " Close  ") + str.tostring(cv, format.mintick), pcColor, false))

    // ── PD/YD levels ──
    // A level is breached by anything after its own trading DAY: any
    // later full day and (in instant mode) today's live extended action.
    // Its own day's post-close tail never breaches it — with the tail
    // toggle on the tail is part of the level, and with it off the tail
    // is ignored outright so the cash-session extreme stays marked even
    // if the tail traded through it. In default (end-of-day) hide mode
    // the current day is ignored, so a level breached today survives
    // until the day rolls over.
    int nAll = array.size(pdHis)
    int n = math.min(nAll, lookback)
    if n > 0
        for k = 1 to n
            int idx   = nAll - k             // k = days back (1 = yesterday)
            int dispK = k + (rolled ? 1 : 0) // early roll shifts numbering by one
            float hi  = array.get(pdHis, idx)
            float lo  = array.get(pdLos, idx)
            int   pid = array.get(pdIds, idx)

            float bHi = instantHide or rolled ? ethHiLive : na
            float bLo = instantHide or rolled ? ethLoLive : na
            int j = array.size(ethIds) - 1
            while j >= 0 and array.get(ethIds, j) > pid
                float ch = array.get(ethHis, j)
                float cl = array.get(ethLos, j)
                if not na(ch)
                    bHi := na(bHi) ? ch : math.max(bHi, ch)
                if not na(cl)
                    bLo := na(bLo) ? cl : math.min(bLo, cl)
                j -= 1

            bool hiBreached = not na(bHi) and (touchIsBreach ? bHi >= hi : bHi > hi)
            bool loBreached = not na(bLo) and (touchIsBreach ? bLo <= lo : bLo < lo)

            bool drawHi = dispK == 1 ? showYD : showPD and not hiBreached
            bool drawLo = dispK == 1 ? showYD : showPD and not loBreached

            if drawHi
                bool isAth = showATH and hi >= ath - eps
                athDrawn := athDrawn or isAth
                array.push(lines, f_mkLine(array.get(pdHiTs, idx), hi, hiColor))
                array.push(labels, f_mkLabel(lblX, hi, (isAth ? "ATH  " : "") + (dispK == 1 ? "YD High  " : "PD " + str.tostring(dispK) + " High  ") + str.tostring(hi, format.mintick), hiColor, isAth))
            if drawLo
                array.push(lines, f_mkLine(array.get(pdLoTs, idx), lo, loColor))
                array.push(labels, f_mkLabel(lblX, lo, (dispK == 1 ? "YD Low  " : "PD " + str.tostring(dispK) + " Low  ") + str.tostring(lo, format.mintick), loColor, false))

    // ── Overnight levels ──
    // The overnight session belongs to the SAME trading day as the RTH
    // that follows it, so the current day's overnight is unnumbered
    // ("ON High/Low") and prior sessions are numbered by trading days
    // back ("ETH 1" = yesterday's overnight, pairing with YD; "ETH 2"
    // pairs with PD 2; etc.).
    if showON or showPriorON
        // Current overnight still in progress (visible on ETH charts):
        // draw it live, updating with every candle.
        if showON and onLiveNow and not na(onHiLive)
            bool liveIsAth = showATH and onHiLive >= ath - eps
            athDrawn := athDrawn or liveIsAth
            array.push(lines, f_mkLine(onHiTLive, onHiLive, curOnHiColor))
            array.push(labels, f_mkLabel(lblX, onHiLive, (liveIsAth ? "ATH  " : "") + "ON High  " + str.tostring(onHiLive, format.mintick), curOnHiColor, liveIsAth))
            array.push(lines, f_mkLine(onLoTLive, onLoLive, curOnLoColor))
            array.push(labels, f_mkLabel(lblX, onLoLive, "ON Low  " + str.tostring(onLoLive, format.mintick), curOnLoColor, false))
        int m = array.size(onHighs)
        // Does the most recent completed overnight belong to the current
        // trading day? (True during/after RTH; false while the next
        // overnight is live-forming, since the day has rolled over.)
        bool topIsToday = m > 0 and array.get(onIds, m - 1) == ethCurId
        if m > 0
            for k = 1 to m
                int oi = m - k               // k = 1 is the most recent completed overnight
                // After the early roll, today's overnight pairs with the
                // early-rolled YD, so it's numbered ETH 1 (not vivid "ON").
                bool isToday = k == 1 and topIsToday and not rolled
                int  ethN    = (topIsToday ? k - 1 : k) + (rolled ? 1 : 0)
                float oh  = array.get(onHighs, oi)
                float ol  = array.get(onLows, oi)
                int   oid = array.get(onIds, oi)

                // Breach = anything AFTER the overnight session ended:
                // the rest of its own day, every later day, and (in
                // instant mode) today's live extended action.
                float bHi = na
                float bLo = na
                if instantHide or rolled
                    bHi := oid == ethCurId ? restHiLive : ethHiLive
                    bLo := oid == ethCurId ? restLoLive : ethLoLive
                int j = array.size(ethIds) - 1
                while j >= 0 and array.get(ethIds, j) >= oid
                    float ch = array.get(ethIds, j) == oid ? array.get(restHis, j) : array.get(ethHis, j)
                    float cl = array.get(ethIds, j) == oid ? array.get(restLos, j) : array.get(ethLos, j)
                    if not na(ch)
                        bHi := na(bHi) ? ch : math.max(bHi, ch)
                    if not na(cl)
                        bLo := na(bLo) ? cl : math.min(bLo, cl)
                    j -= 1

                bool ohBreached = not na(bHi) and (touchIsBreach ? bHi >= oh : bHi > oh)
                bool olBreached = not na(bLo) and (touchIsBreach ? bLo <= ol : bLo < ol)

                // Today's completed overnight follows the ON toggle; prior
                // days' ETH n levels follow their own toggle.
                bool showThis = isToday ? showON : showPriorON

                if showThis and (isToday or not ohBreached)
                    bool onIsAth = showATH and oh >= ath - eps
                    athDrawn := athDrawn or onIsAth
                    array.push(lines, f_mkLine(array.get(onHiTimes, oi), oh, isToday ? curOnHiColor : onHiColor))
                    array.push(labels, f_mkLabel(lblX, oh, (onIsAth ? "ATH  " : "") + (isToday ? "ON High  " : "ETH " + str.tostring(ethN) + " High  ") + str.tostring(oh, format.mintick), isToday ? curOnHiColor : onHiColor, onIsAth))
                if showThis and (isToday or not olBreached)
                    array.push(lines, f_mkLine(array.get(onLoTimes, oi), ol, isToday ? curOnLoColor : onLoColor))
                    array.push(labels, f_mkLabel(lblX, ol, (isToday ? "ON Low  " : "ETH " + str.tostring(ethN) + " Low  ") + str.tostring(ol, format.mintick), isToday ? curOnLoColor : onLoColor, false))

    // ── Standalone ATH ──
    // If no drawn level happens to sit at the all-time high (it's
    // beyond the lookback windows, breach-hidden, or printed in the
    // tail session), draw it as its own line so it's always marked.
    if showATH and not athDrawn and not na(ath)
        array.push(lines, f_mkLine(athT, ath, athColor))
        array.push(labels, f_mkLabel(lblX, ath, "ATH  " + str.tostring(ath, format.mintick), athColor, true))
````
