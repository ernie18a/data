# Index Peak Dispersion

- url: https://www.tradingview.com/script/LXTgseja-Index-Peak-Dispersion/
- type: indicator
- pine_id: PUB;23c5ed58d165409880db70a87a087dd7
- version: 1.0

## Description

█ OVERVIEW

Index Peak Dispersion plots, in a separate pane, two normalized series computed across a configurable universe of up to twelve equity indexes: the calendar-day dispersion of their all-time-high dates, expressed as a percent of a topping window, and the share of indexes that printed a fresh all-time high within a short recent window. The thesis is that healthy advances register all-time highs across indexes nearly simultaneously, while major distributive tops fragment, spreading index peak dates across weeks or months.

█ HISTORY / BACKGROUND

The concept descends from the non-confirmation principle of Dow Theory as developed by Charles Dow, William Hamilton and Robert Rhea, in which a new high in one average unaccompanied by a new high in another warns that the trend is losing sponsorship. Classic non-confirmation is measured in the price domain: one index fails to exceed its prior peak while another does.

Market historians and technicians, including Robert Prechter, have documented a related phenomenon in the time domain: at major tops, the final all-time highs of the major indexes scatter across the calendar rather than clustering. At the 2000 top, the Dow Industrials peaked in January, the S&P 500 and NASDAQ Composite in March, and the NYSE Composite in September. At the 2007 top, the Dow Jones Composite peaked in July while the Dow Industrials and S&P 500 peaked in October. This script converts that qualitative observation into a mechanical, reproducible statistic.

█ HOW IT WORKS

The script performs the following steps on each bar:

• For each of up to twelve enabled symbols, one same-timeframe [pine]request.security()[/pine] call evaluates a function inside the requested symbol's context. The function maintains a running maximum of closing prices over the symbol's loaded history and records the timestamp of the bar on which that maximum was last exceeded. This running maximum is point-in-time by construction: no future data enters the calculation, and lookahead is off.
• On the chart symbol, each recorded timestamp is converted to an age in calendar days: current bar time minus the all-time-high time, divided by the number of milliseconds in a day.
• Each enabled index with data is classified. An age at or below the fresh window makes it Fresh. An age at or below the topping window makes it part of the in-window set. An age beyond the topping window makes it Stale.
• When the in-window set contains at least the minimum required count of indexes, the dispersion span equals the maximum in-window age minus the minimum in-window age, in calendar days. The plotted dispersion value is that span divided by the topping window length, times 100. When the in-window count is below the minimum, the dispersion plot returns na.
• The participation value equals the count of Fresh indexes divided by the count of enabled indexes with data, times 100, plotted as columns.
• The fractured top condition is true when the dispersion value is at or above the warning threshold while at least one index is Fresh. The pane background is shaded on those bars, and an alert fires on the first bar of each new occurrence. A second alert fires when every enabled index with data is simultaneously Fresh, which marks a synchronized advance, the opposite condition.
• On the last bar, an optional table lists each index with its all-time-high date, age in days and classification, plus summary counts and the raw span in days.

█ HOW TO USE

The script is designed for the 1D timeframe. The running all-time high is intended to operate on daily closes, and both windows are specified in calendar days, so daily resolution matches the granularity of the logic.

In plain terms, the blue columns answer one question: how many of the enabled indexes hit a record high this week? The red line answers another: how spread out in time are everyone's record highs? In a strong market, the indexes peak together, so the columns are tall and the line stays low. At major tops, the market tends to fall apart in slow motion: one index peaks, then months later another, and by the time the last index prints its final record, several others stopped making records long ago. Each new high is carried by fewer indexes, so the columns thin out while the line climbs. The shaded background marks the combination of both: the market is still printing record highs, but the set of indexes confirming them has been shrinking for months. That is the structure documented at the 2000 and 2007 tops. The same combination also appears during rotation phases that resolve higher, so treat it as a statement that conditions resemble past major tops, not as an instruction to act.

Read the two plotted series together. Low dispersion with high participation describes a synchronized advance in which the enabled indexes are registering highs together. Rising dispersion while some indexes continue to print fresh highs describes fragmentation: leadership is narrowing and earlier leaders have stopped confirming. The shaded background marks bars on which the dispersion value is at or above the dashed threshold line while at least one fresh high exists, the specific combination in which fragmentation is present at a live high rather than in an established downtrend.

The table gives the attribution behind the numbers: which indexes are Fresh, which remain inside the topping window, and which have gone Stale, along with each all-time-high date. Stale entries are non-confirmations older than the topping window and are deliberately excluded from the span so that a single long-dormant index does not saturate the statistic.

The condition is a warning context, not a timing trigger. It identifies an environment consistent with historical distributive tops. It does not predict the date or the existence of a decline.

█ SETTINGS

• Index universe, twelve slots, each with an enable checkbox and a symbol field. Defaults: DJI, DJT, DJU, DJA, SPX, NDX, IXIC, NYA, RUT, SOX, MID, SPXEW. All twelve are enabled by default. Any slot can be repointed to another symbol or disabled.
• Fresh high window, calendar days. Default 7. An index whose all-time high printed within this many days counts as Fresh.
• Topping window, calendar days. Default 378. An index whose all-time high printed within this many days participates in the dispersion span. Older highs are classified Stale.
• Dispersion warning threshold, percent of topping window. Default 25. The dashed reference line and the threshold for the fractured top condition.
• Minimum in-window index count for a valid span. Default 4. Below this count the dispersion plot returns na, which prevents a span computed from too few indexes.
• Show status table. Default on.
• Table position. Default Top right.

█ WHAT MAKES IT ORIGINAL

Breadth and non-confirmation tools on this platform generally measure the price domain: divergences between an index and an internal line, counts of components above a moving average, or new-high and new-low tallies within one exchange universe. This script instead measures the time domain across whole indexes. It reduces the peak-date scatter of a user-defined index universe to a single bounded statistic, the in-window span of all-time-high ages, and pairs it with a participation series so that fragmentation is only flagged while a high is live. The classification into Fresh, in-window and Stale, with the Stale exclusion and the minimum-count validity gate, is what allows the scatter of a historical topping process to be plotted as one continuous, comparable series across eras.

█ NOTES / LIMITATIONS

• The running all-time high is computed only over the bars loaded for each requested symbol. Symbols with short available history, and the early portion of any chart, understate the true age of the all-time high. Treat the plot as reliable only after all enabled symbols have substantial loaded history.
• The logic is designed for the 1D timeframe. On intraday charts the running maximum operates on intraday closes and the calendar-day windows lose their intended granularity. On weekly or monthly charts a fresh window shorter than one bar cannot register.
• All [pine]request.security()[/pine] calls run on the chart timeframe with lookahead off. Values on the developing bar update until the bar closes and do not repaint afterward.
• The script issues twelve security calls. A symbol slot that fails to resolve or returns no data is excluded from every count and appears in the table as No data.
• Ages and spans are measured in calendar days, not trading days, so weekends and holidays are included in the counts.
• The warning threshold is expressed as a percent of the topping window. Changing the topping window changes the day-equivalent of the same percent threshold.
• The dispersion plot returns na whenever fewer than the minimum required indexes have an all-time high inside the topping window.
• The status table renders on the last bar only.

## Source Code

````pine
//@version=6
indicator("Index Peak Dispersion", shorttitle="IPD", overlay=false, precision=1)

// ── Inputs ───────────────────────────────────────────────────────────────────
string GRP_U = "Index universe"
bool   use01 = input.bool(true, "01", inline="i01", group=GRP_U)
string sym01 = input.symbol("DJ:DJI", "", inline="i01", group=GRP_U)
bool   use02 = input.bool(true, "02", inline="i02", group=GRP_U)
string sym02 = input.symbol("DJ:DJT", "", inline="i02", group=GRP_U)
bool   use03 = input.bool(true, "03", inline="i03", group=GRP_U)
string sym03 = input.symbol("DJ:DJU", "", inline="i03", group=GRP_U)
bool   use04 = input.bool(true, "04", inline="i04", group=GRP_U)
string sym04 = input.symbol("DJ:DJA", "", inline="i04", group=GRP_U)
bool   use05 = input.bool(true, "05", inline="i05", group=GRP_U)
string sym05 = input.symbol("SP:SPX", "", inline="i05", group=GRP_U)
bool   use06 = input.bool(true, "06", inline="i06", group=GRP_U)
string sym06 = input.symbol("NASDAQ:NDX", "", inline="i06", group=GRP_U)
bool   use07 = input.bool(true, "07", inline="i07", group=GRP_U)
string sym07 = input.symbol("NASDAQ:IXIC", "", inline="i07", group=GRP_U)
bool   use08 = input.bool(true, "08", inline="i08", group=GRP_U)
string sym08 = input.symbol("TVC:NYA", "", inline="i08", group=GRP_U)
bool   use09 = input.bool(true, "09", inline="i09", group=GRP_U)
string sym09 = input.symbol("TVC:RUT", "", inline="i09", group=GRP_U)
bool   use10 = input.bool(true, "10", inline="i10", group=GRP_U)
string sym10 = input.symbol("NASDAQ:SOX", "", inline="i10", group=GRP_U)
bool   use11 = input.bool(true, "11", inline="i11", group=GRP_U)
string sym11 = input.symbol("SP:MID", "", inline="i11", group=GRP_U)
bool   use12 = input.bool(true, "12", inline="i12", group=GRP_U)
string sym12 = input.symbol("INDEX:SPXEW", "", inline="i12", group=GRP_U)

string GRP_L = "Logic"
int   freshDays  = input.int(7, "Fresh high window, calendar days", minval=1, group=GRP_L,
     tooltip="An index whose running all-time closing high printed within this many calendar days counts as a fresh high.")
int   windowDays = input.int(378, "Topping window, calendar days", minval=30, group=GRP_L,
     tooltip="An index whose all-time high printed within this many calendar days participates in the dispersion span. Older highs are classified as stale non-confirmations.")
float warnPct    = input.float(25.0, "Dispersion warning threshold, percent of topping window", minval=1.0, maxval=100.0, step=1.0, group=GRP_L)
int   minCount   = input.int(4, "Minimum in-window index count for a valid span", minval=2, group=GRP_L)

string GRP_V = "Display"
bool   showTable = input.bool(true, "Show status table", group=GRP_V)
string tblPosIn  = input.string("Top right", "Table position", options=["Top left", "Top right", "Bottom left", "Bottom right"], group=GRP_V)

// ── Per-symbol running ATH timestamp ─────────────────────────────────────────
// Executed inside each requested symbol's context. Point-in-time by
// construction: the running maximum uses only bars available up to the
// current bar within the loaded history of the requested symbol.
f_athTime() =>
    var float ath  = na
    var int   athT = na
    if na(ath) or close > ath
        ath  := close
        athT := time
    athT

int t01 = request.security(sym01, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t02 = request.security(sym02, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t03 = request.security(sym03, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t04 = request.security(sym04, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t05 = request.security(sym05, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t06 = request.security(sym06, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t07 = request.security(sym07, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t08 = request.security(sym08, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t09 = request.security(sym09, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t10 = request.security(sym10, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t11 = request.security(sym11, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)
int t12 = request.security(sym12, timeframe.period, f_athTime(), lookahead=barmerge.lookahead_off)

// ── Collection ───────────────────────────────────────────────────────────────
f_ageDays(int athT) =>
    na(athT) ? na : (time - athT) / 86400000.0

array<string> syms  = array.new<string>()
array<float>  ages  = array.new<float>()
array<int>    athTs = array.new<int>()

f_collect(bool en, string s, int athT) =>
    if en
        array.push(syms, s)
        array.push(ages, f_ageDays(athT))
        array.push(athTs, athT)

f_collect(use01, sym01, t01)
f_collect(use02, sym02, t02)
f_collect(use03, sym03, t03)
f_collect(use04, sym04, t04)
f_collect(use05, sym05, t05)
f_collect(use06, sym06, t06)
f_collect(use07, sym07, t07)
f_collect(use08, sym08, t08)
f_collect(use09, sym09, t09)
f_collect(use10, sym10, t10)
f_collect(use11, sym11, t11)
f_collect(use12, sym12, t12)

// ── Metrics ──────────────────────────────────────────────────────────────────
int   enabledCnt = array.size(syms)
int   dataCnt    = 0
int   freshCnt   = 0
int   inWinCnt   = 0
int   staleCnt   = 0
float minIn      = na
float maxIn      = na

if enabledCnt > 0
    for i = 0 to enabledCnt - 1
        float a = array.get(ages, i)
        if not na(a)
            dataCnt += 1
            if a <= freshDays
                freshCnt += 1
            if a <= windowDays
                inWinCnt += 1
                minIn := na(minIn) ? a : math.min(minIn, a)
                maxIn := na(maxIn) ? a : math.max(maxIn, a)
            else
                staleCnt += 1

float spanDays = inWinCnt >= minCount ? maxIn - minIn : na
float dispPct  = na(spanDays) ? na : 100.0 * spanDays / windowDays
float freshPct = dataCnt > 0 ? 100.0 * freshCnt / dataCnt : na
bool  fractured = not na(dispPct) and dispPct >= warnPct and freshCnt >= 1
bool  unanimous = dataCnt > 0 and freshCnt == dataCnt

// ── Plots ────────────────────────────────────────────────────────────────────
color C_DISP  = #f23645
color C_FRESH = #2962ff
color C_GRAY  = #787b86
color C_GREEN = #089981

plot(freshPct, "Fresh ATH participation, percent of indexes with data", style=plot.style_columns, color=color.new(C_FRESH, 70))
plot(dispPct, "Peak dispersion, percent of topping window", color=C_DISP, linewidth=2)
hline(warnPct, "Dispersion warning threshold", color=color.new(C_GRAY, 0), linestyle=hline.style_dashed)
bgcolor(fractured ? color.new(C_DISP, 88) : na, title="Fractured top condition")

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(fractured and not fractured[1], "Fractured top warning", "Index Peak Dispersion: dispersion crossed the warning threshold while at least one enabled index printed a fresh all-time high")
alertcondition(unanimous and not unanimous[1], "Unanimous fresh highs", "Index Peak Dispersion: every enabled index with data printed a fresh all-time high inside the fresh window")

// ── Status table ─────────────────────────────────────────────────────────────
f_short(string s) =>
    array<string> parts = str.split(s, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : s

var table tb = na

if showTable and barstate.islast
    string tblPos = switch tblPosIn
        "Top left"    => position.top_left
        "Top right"   => position.top_right
        "Bottom left" => position.bottom_left
        =>               position.bottom_right
    if na(tb)
        tb := table.new(tblPos, 4, 15, border_width=1, border_color=color.new(C_GRAY, 80))
    table.cell(tb, 0, 0, "Index",    text_size=size.small, bgcolor=color.new(C_GRAY, 70))
    table.cell(tb, 1, 0, "ATH date", text_size=size.small, bgcolor=color.new(C_GRAY, 70))
    table.cell(tb, 2, 0, "Age, d",   text_size=size.small, bgcolor=color.new(C_GRAY, 70))
    table.cell(tb, 3, 0, "Status",   text_size=size.small, bgcolor=color.new(C_GRAY, 70))
    if enabledCnt > 0
        for i = 0 to enabledCnt - 1
            float  a   = array.get(ages, i)
            int    tms = array.get(athTs, i)
            string st  = na(a) ? "No data" : a <= freshDays ? "Fresh" : a <= windowDays ? "Window" : "Stale"
            color  sc  = na(a) ? color.new(C_GRAY, 0) : a <= freshDays ? C_GREEN : a <= windowDays ? color.new(C_GRAY, 0) : C_DISP
            table.cell(tb, 0, i + 1, f_short(array.get(syms, i)), text_size=size.small, text_halign=text.align_left)
            table.cell(tb, 1, i + 1, na(tms) ? "-" : str.format("{0,date,yyyy-MM-dd}", tms), text_size=size.small)
            table.cell(tb, 2, i + 1, na(a) ? "-" : str.tostring(a, "#"), text_size=size.small)
            table.cell(tb, 3, i + 1, st, text_size=size.small, text_color=sc)
    table.cell(tb, 0, 13, "Span, d",   text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 1, 13, na(spanDays) ? "-" : str.tostring(spanDays, "#"), text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 2, 13, "In window", text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 3, 13, str.tostring(inWinCnt), text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 0, 14, "Fresh",     text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 1, 14, str.tostring(freshCnt), text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 2, 14, "Stale",     text_size=size.small, bgcolor=color.new(C_GRAY, 85))
    table.cell(tb, 3, 14, str.tostring(staleCnt), text_size=size.small, bgcolor=color.new(C_GRAY, 85))
````
