# RS/Correlation Panel

- url: https://www.tradingview.com/script/TGSOjQEG-RS-Correlation-Panel/
- type: indicator
- pine_id: PUB;84487bb7b82449d787f0129f457d5ade
- version: 1.0

## Description

**RS/Correlation Panel**

A single-table dashboard that benchmarks the current chart's symbol against any reference ticker you choose (SPY, QQQ, BTC, or any other symbol) across multiple timeframes — correlation, today's relative performance, short-term relative strength, and a longer IBD-style relative strength rating — plus historical daily move statistics for the symbol itself.

**Inputs**
- **Benchmark Ticker** — the symbol to compare against. Defaults to SPY, but accepts any ticker (QQQ, individual stocks, or crypto via its exchange prefix, e.g. COINBASE:BTCUSD).
- **Correlation Lookback (bars)** — number of bars used for the rolling correlation calculation. Default 20.
- **Daily Stats Lookback (days)** — number of trading days used to calculate average rise/fall and green/red day percentages. Default 60.
- **Short-Term RS/RW Lookback (bars)** — the window used for the medium-term relative strength/weakness reading, sitting between the 1-day and quarterly reads. Default 10.
- **Table Position** — corner of the chart where the table is displayed.

**Table Rows**

- **Correlation** — rolling correlation coefficient between the symbol and the benchmark over the chosen lookback, tagged Strong / Moderate / Weak based on absolute value.
- **Symbol's Today's Move / Benchmark's Today's Move** — each instrument's current-session percent change, calculated from that day's open to the live/last close.
- **RS/RW Today** — the difference between the symbol's and benchmark's daily percent change. Positive means the symbol is outperforming the benchmark today; negative means it's underperforming.
- **N-Bar RS/RW** — the same outperformance/underperformance concept, but measured as the difference in rate-of-change over the user-defined short-term lookback (default 10 bars). This fills the gap between a single day's move and a full quarterly trend.
- **IBD-Style RS** — a quarterly-weighted relative strength calculation modeled on the classic IBD Relative Strength methodology: the symbol's and benchmark's trailing performance are each computed across four rolling quarters (weighted 40/20/20/20, most recent quarter weighted heaviest), then compared as a percentage difference. This is a slower-moving, trend-level strength read — it won't react much to a single day's move, by design.
- **Avg % Rise / Fall** — average percentage gain on up days and average percentage loss on down days, calculated over the Daily Stats Lookback period.
- **Green Days % / Red Days %** — percentage of days in the lookback period that closed up versus down.

**Notes**
- All relative-strength and correlation metrics reference the same user-selected benchmark, so switching the input updates every row consistently.
- The IBD-Style RS calculation is a reproduction of the standard quarterly-weighted RS methodology and is intended to complement — not replace — short-term price action analysis.
- This is a decision-support tool, not a standalone trading signal. Always confirm readings against price structure, volume, and catalysts before acting.

## Source Code

````pine
//@version=6
indicator("RS/Correlation Panel", overlay=true, max_labels_count=500)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
benchTicker   = input.symbol("SPY", "Benchmark Ticker (SPY / QQQ / BTC / any)")
corrLen       = input.int(20, "Correlation Lookback (bars)", minval=5)
statsDays     = input.int(60, "Daily Stats Lookback (days)", minval=10, maxval=300)
stLen         = input.int(10, "Short-Term RS/RW Lookback (bars)", minval=2, maxval=60)
tablePos      = input.string("Bottom Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"])

posMap = tablePos == "Top Right" ? position.top_right :
         tablePos == "Top Left" ? position.top_left :
         tablePos == "Bottom Left" ? position.bottom_left : position.bottom_right

// ─────────────────────────────
// LIVE SERIES (current symbol)
// ─────────────────────────────
dailyOpen  = request.security(syminfo.tickerid, "D", open)
dailyClose = request.security(syminfo.tickerid, "D", close)
symTodayMove = (dailyClose - dailyOpen) / dailyOpen * 100

// ─────────────────────────────
// BENCHMARK SERIES
// ─────────────────────────────
benchClose      = request.security(benchTicker, timeframe.period, close)
benchDailyOpen  = request.security(benchTicker, "D", open)
benchDailyClose = request.security(benchTicker, "D", close)
benchTodayMove  = (benchDailyClose - benchDailyOpen) / benchDailyOpen * 100

// ─────────────────────────────
// CORRELATION + RS/RW
// ─────────────────────────────
corrVal = ta.correlation(close, benchClose, corrLen)
rsrw    = symTodayMove - benchTodayMove   // >0 = outperforming benchmark today, 1-day

// short-term (N-bar) RS/RW — the "middle ground" between today and the quarterly IBD read
stRsrw  = ta.roc(close, stLen) - ta.roc(benchClose, stLen)

// ─────────────────────────────
// IBD-STYLE QUARTERLY RS (Skyte's formula, ported)
// This reproduces the same math as the standalone "RS SPY" indicator,
// so you can read it here and drop the separate one.
// ─────────────────────────────
oneYear = 252

f_quarter_perf(data, n) =>
    i = n
    refCandle = i * oneYear / 4
    baseCandle = (i - 1) * oneYear / 4
    while (na(data[refCandle]) and i > 1)
        i := i - 1
        refCandle := i * oneYear / 4
        baseCandle := (i - 1) * oneYear / 4
    ta.roc(data[baseCandle], refCandle)

stock_perf = 0.4 * f_quarter_perf(close, 1) + 0.2 * f_quarter_perf(close, 2) + 0.2 * f_quarter_perf(close, 3) + 0.2 * f_quarter_perf(close, 4)
ref_perf   = 0.4 * f_quarter_perf(benchClose, 1) + 0.2 * f_quarter_perf(benchClose, 2) + 0.2 * f_quarter_perf(benchClose, 3) + 0.2 * f_quarter_perf(benchClose, 4)
ibdRS      = (stock_perf - ref_perf) / ref_perf * 100

// ─────────────────────────────
// DAILY STATS (avg rise/fall, green/red day %)
// Pulled from daily timeframe, completed days only
// ─────────────────────────────
f_dailyChanges(len) =>
    arr = array.new_float(0)
    for i = 1 to len
        o = open[i]
        c = close[i]
        array.push(arr, (c - o) / o * 100)
    arr

changesArr = request.security(syminfo.tickerid, "D", f_dailyChanges(statsDays))

var float avgRise  = na
var float avgFall  = na
var float greenPct = na
var float redPct   = na

if barstate.islast
    riseSum = 0.0
    fallSum = 0.0
    riseCnt = 0
    fallCnt = 0
    n = array.size(changesArr)
    for i = 0 to n - 1
        v = array.get(changesArr, i)
        if v > 0
            riseSum += v
            riseCnt += 1
        else if v < 0
            fallSum += v
            fallCnt += 1
    avgRise  := riseCnt > 0 ? riseSum / riseCnt : na
    avgFall  := fallCnt > 0 ? fallSum / fallCnt : na
    greenPct := n > 0 ? riseCnt / n * 100 : na
    redPct   := n > 0 ? fallCnt / n * 100 : na

// ─────────────────────────────
// COLOR HELPERS
// ─────────────────────────────
posColor = color.new(color.green, 70)
negColor = color.new(color.red, 70)
neuColor = color.new(color.gray, 80)

f_bg(v) => na(v) ? neuColor : v > 0 ? posColor : v < 0 ? negColor : neuColor
f_txt(v, dec) => na(v) ? "n/a" : str.tostring(v, "#." + str.repeat("#", dec)) + "%"

// ─────────────────────────────
// TABLE
// ─────────────────────────────
var table t = table.new(posMap, 2, 10, border_width=1, border_color=color.gray, frame_color=color.gray, frame_width=1)

if barstate.islast
    corrLabel = na(corrVal) ? "n/a" : str.tostring(corrVal, "#.##")
    corrTag   = na(corrVal) ? "" : math.abs(corrVal) > 0.7 ? "Strong" : math.abs(corrVal) > 0.4 ? "Moderate" : "Weak"
    rsTag     = rsrw > 0 ? "Outperforming" : rsrw < 0 ? "Underperforming" : "In-line"

    table.cell(t, 0, 0, "Benchmark", bgcolor=color.new(color.blue, 60), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, benchTicker, bgcolor=color.new(color.blue, 60), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 1, corrTag + " Corr to " + benchTicker, bgcolor=neuColor, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, corrLabel, bgcolor=neuColor, text_color=color.white, text_size=size.small)

    table.cell(t, 0, 2, syminfo.ticker + " Today's Move", bgcolor=f_bg(symTodayMove), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, f_txt(symTodayMove, 2), bgcolor=f_bg(symTodayMove), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 3, benchTicker + " Today's Move", bgcolor=f_bg(benchTodayMove), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, f_txt(benchTodayMove, 2), bgcolor=f_bg(benchTodayMove), text_color=color.white, text_size=size.small)

    stTag = stRsrw > 0 ? "Outperforming" : stRsrw < 0 ? "Underperforming" : "In-line"
    ibdTag = ibdRS > 0 ? "Strength" : ibdRS < 0 ? "Weakness" : "Neutral"

    table.cell(t, 0, 4, "RS/RW vs " + benchTicker + " Today (" + rsTag + ")", bgcolor=f_bg(rsrw), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, f_txt(rsrw, 2), bgcolor=f_bg(rsrw), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 5, str.tostring(stLen) + "-Bar RS/RW (" + stTag + ")", bgcolor=f_bg(stRsrw), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, f_txt(stRsrw, 2), bgcolor=f_bg(stRsrw), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 6, "IBD-Style RS vs " + benchTicker + " (" + ibdTag + ")", bgcolor=f_bg(ibdRS), text_color=color.white, text_size=size.small)
    table.cell(t, 1, 6, f_txt(ibdRS, 2), bgcolor=f_bg(ibdRS), text_color=color.white, text_size=size.small)

    table.cell(t, 0, 7, "Avg % Rise / Fall (" + str.tostring(statsDays) + "d)", bgcolor=neuColor, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 7, f_txt(avgRise, 2) + " / " + f_txt(avgFall, 2), bgcolor=neuColor, text_color=color.white, text_size=size.small)

    table.cell(t, 0, 8, "Green Days %", bgcolor=posColor, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 8, f_txt(greenPct, 2), bgcolor=posColor, text_color=color.white, text_size=size.small)

    table.cell(t, 0, 9, "Red Days %", bgcolor=negColor, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 9, f_txt(redPct, 2), bgcolor=negColor, text_color=color.white, text_size=size.small)
````
