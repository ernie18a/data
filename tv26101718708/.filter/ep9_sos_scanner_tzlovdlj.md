# EP9 SOS Scanner

- url: https://www.tradingview.com/script/TzLovdlj-EP9-SOS-Scanner/
- type: indicator
- pine_id: PUB;eb604fc4df8544228809e663afcfdbac
- version: 1.0

## Description

SOS scanner

Identify when a stock is about to move up.

## Source Code

````pine
//@version=5
// =============================================================================
// EP9 Mechanical System — Start of Swing (SOS) Scanner
// Playbook: EP9 Mechanical System v3 (April 26, 2026)
//
// Purpose: flag bars where all 4 SOS conditions fire on the SAME bar, the
// 8.9M volume gate is met, and the R:R gate (Risk% <= ADR%) passes. Plots
// the conditional stop (LOD vs ADR_FLOOR), T1 (+2R), and T2 (+3R) on PASS bars.
//
// Run on the DAILY timeframe. Intraday values are tentative until 4:00 close.
// =============================================================================

indicator("EP9 SOS Scanner", overlay=true, max_labels_count=500, max_lines_count=500)

// ============== Inputs ==============
g_filters       = "Universe filters"
volThreshold    = input.int(8900000, "Min Volume (shares)", minval=1, group=g_filters)
priceFloor      = input.float(3.0, "Min Price ($)", minval=0.0, step=0.5, group=g_filters)

g_sos           = "SOS parameters"
priorUpCap      = input.float(1.02, "Prior bar up-swing cap (Close[1]/Close[2])", minval=1.0, step=0.01, group=g_sos)
strongCloseMin  = input.float(0.70, "Strong-close threshold (top X% of range)", minval=0.5, maxval=1.0, step=0.05, group=g_sos)

g_stop          = "Stop / R:R"
adrLength       = input.int(14, "ADR length", minval=2, group=g_stop)
rangeDevMult    = input.float(0.3, "Range-developed threshold (× ADR%)", minval=0.0, step=0.05, group=g_stop, tooltip="If today's range_pct < this × ADR%, range is underdeveloped and stop falls to ADR_FLOOR. Section 4.")
adrFloorMult    = input.float(0.5, "ADR floor multiplier", minval=0.0, step=0.05, group=g_stop, tooltip="Stop = Entry − this × ADR% × Entry when range is underdeveloped.")

g_display       = "Display"
// Defaults are intentionally minimal — only the green SOS triangle and tiny
// Stop/T1/T2 markers show by default. Toggle the rest on if you need them.
showLevels      = input.bool(true,  "Plot Stop / T1 / T2 levels (only on SOS bars)", group=g_display)
showLabels      = input.bool(false, "Show data labels on SOS bars", group=g_display)
showStatusTable = input.bool(false, "Show status table", group=g_display)
showChase       = input.bool(false, "Mark SOS bars that fail R:R gate (chases)", group=g_display)
recentOnly      = input.bool(true,  "Show flags only on recent bars", group=g_display, tooltip="When ON, flags render only for the last N trading days. Hides historical SOS triggers that aren't actionable today.")
recentBarsN     = input.int(5,      "Recent bars window (N)", minval=1, group=g_display)
lineExtendBars  = input.int(5,      "Stop/T1/T2 line length (bars forward)", minval=1, maxval=20, group=g_display, tooltip="How many bars forward each Stop/T1/T2 horizontal line extends from the SOS PASS bar. Default 5 matches the playbook's Day 5 hard exit.")

// Pine requires `text`, `style`, `size` on plotshape to be const strings.
// SOS marker uses one plotshape per style choice (below); size is fixed at size.tiny.
tablePosInput   = input.string("Bottom Right", "Status table position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=g_display)

// `switch` avoids multi-line ternary continuation issues.
tablePos = switch tablePosInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

// ============== Volatility ==============
adr14  = ta.sma(high - low, adrLength)
adrPct = adr14 / close * 100.0

// ============== SOS conditions (must all fire SAME bar) ==============
// C1: prior bar not already in an up-swing (Close[1] / Close[2] <= 1.02)
cond1 = (close[1] / close[2]) <= priorUpCap

// C2: strong close — close in top 30% of day's range
rng_today = high - low
cond2 = rng_today > 0 and (close - low) / rng_today >= strongCloseMin

// C3: body expansion — today's body > yesterday's body
// Documented edge case (accepted): if yesterday was a large red bar,
// any positive body today satisfies this. Filter on close-strength + volume
// is intentional; tag occurrences post-hoc in the journal.
cond3 = (close - open) > (close[1] - open[1])

// C4: price floor
cond4 = close >= priceFloor

// Volume gate
volOk = volume >= volThreshold

sosConfirmed = cond1 and cond2 and cond3 and cond4 and volOk

// ============== Stop / Risk / Targets (EOD model — backtest variant) ==============
entry_eod      = close
range_pct      = (high - low) / entry_eod * 100.0
threshold      = rangeDevMult * adrPct
rangeDeveloped = range_pct >= threshold

stop_price  = rangeDeveloped ? low : (entry_eod - adrFloorMult * adrPct / 100.0 * entry_eod)
stop_source = rangeDeveloped ? "LOD" : "ADR_FLOOR"
risk        = entry_eod - stop_price
risk_pct    = risk / entry_eod * 100.0

// R:R gate: PASS if Risk% <= ADR%
rr_pass = risk_pct <= adrPct

t1 = entry_eod + 2.0 * risk
t2 = entry_eod + 3.0 * risk

// ============== Go/No-Go filters (Stage 2 proxy + relative strength) ==============
// Approximates the trend-context check you'd do manually from a Stage Analysis panel.
// Pine can't read TXInv's outputs, so we replicate three filters in-script:
//   1. Price above 30WMA (Stage 2-ish — above the long-term moving average)
//   2. 30WMA rising (long-term trend supporting an upside thesis)
//   3. Relative strength vs benchmark (stock outperforming SPY, simplified Mansfield)
g_filter        = "Go/No-Go filters"
sma30Length     = input.int(150, "30WMA length (trading days)", minval=10, group=g_filter, tooltip="~150 trading days approximates a 30-week moving average. Used for Stage 2 detection.")
maRiseLookback  = input.int(5,   "30WMA rising lookback (bars)", minval=1, group=g_filter)
benchmarkSym    = input.symbol("SPY", "Benchmark for relative strength", group=g_filter)
rsLookback      = input.int(50,  "RS vs benchmark lookback (bars)", minval=10, group=g_filter)

ma30        = ta.sma(close, sma30Length)
aboveMA     = close > ma30
maRising    = ma30 > ma30[maRiseLookback]

benchClose  = request.security(benchmarkSym, timeframe.period, close, lookahead=barmerge.lookahead_off)
rsRatio     = benchClose != 0 ? close / benchClose : na
rsAbove     = not na(rsRatio) and rsRatio > ta.sma(rsRatio, rsLookback)

// Combined Go/No-Go verdicts (only meaningful when SOS_PASS fires).
// goSignal     = strict: all 3 trend filters pass
// goModerate   = relaxed: any 2 of 3 trend filters pass (catches Stage 2 transitions)
filterCount = (aboveMA ? 1 : 0) + (maRising ? 1 : 0) + (rsAbove ? 1 : 0)
goSignal    = sosConfirmed and rr_pass and filterCount >= 3
goModerate  = sosConfirmed and rr_pass and filterCount >= 2

// ============== Plots ==============
// display=display.pane keeps these chart-only so they don't appear as duplicate columns in Pine Screener.
// SOS PASS marker — one plotshape per style choice. Only one fires (the one matching markerStyle).
sosPass      = sosConfirmed and rr_pass
sosColor     = color.new(#26a69a, 0)
// inRecentBars gates chart-display plots so historical SOS triggers don't clutter the chart.
inRecentBars = not recentOnly or (last_bar_index - bar_index) < recentBarsN
// Single SOS marker — Flag with "SOS" text. One plotshape = one chip in Pine Screener.
plotshape(sosPass and inRecentBars, title="SOS", style=shape.flag, location=location.belowbar, color=sosColor, text="SOS", textcolor=chart.fg_color, size=size.tiny, display=display.pane)

plotshape(showChase and sosConfirmed and not rr_pass and inRecentBars,   title="SOS CHASE", style=shape.xcross, location=location.belowbar, color=color.new(#ef5350, 0), size=size.tiny, display=display.pane)

// Stop / T1 / T2 horizontal lines + price labels — MOST RECENT SOS only.
// On each new SOS trigger, delete the previous set so the chart shows just the
// active trade's levels (no stacked labels from older setups).
var array<line>  sosLines  = array.new<line>()
var array<label> sosLabels = array.new<label>()

if showLevels and sosPass and inRecentBars
    // Clear previous SOS levels — keep only the most recent.
    while array.size(sosLines) > 0
        line.delete(array.pop(sosLines))
    while array.size(sosLabels) > 0
        label.delete(array.pop(sosLabels))

    rightX = bar_index + lineExtendBars
    array.push(sosLines,  line.new(bar_index, stop_price, rightX, stop_price, color=color.new(#ef5350, 0), width=1))
    array.push(sosLines,  line.new(bar_index, t1,         rightX, t1,         color=color.new(#42a5f5, 0), width=1))
    array.push(sosLines,  line.new(bar_index, t2,         rightX, t2,         color=color.new(#1e88e5, 0), width=1))
    array.push(sosLabels, label.new(rightX, stop_price, "Stop $" + str.tostring(stop_price, "#.##"), color=color.new(#ef5350, 70), textcolor=chart.fg_color, style=label.style_label_left, size=size.small))
    array.push(sosLabels, label.new(rightX, t1,         "T1 $"   + str.tostring(t1,         "#.##"), color=color.new(#42a5f5, 70), textcolor=chart.fg_color, style=label.style_label_left, size=size.small))
    array.push(sosLabels, label.new(rightX, t2,         "T2 $"   + str.tostring(t2,         "#.##"), color=color.new(#1e88e5, 70), textcolor=chart.fg_color, style=label.style_label_left, size=size.small))

// ============== Pine Screener outputs (always-on numeric columns) ==============
// These become filterable columns in TradingView's Pine Screener (Beta).
// To screen the universe at EOD: pick this indicator → filter SOS_PASS = 1.
// display.data_window keeps them out of the chart pane but visible to the screener
// and to the chart's Data Window panel.
plot(sosConfirmed and rr_pass     ? 1 : 0, title="SOS_PASS",     display=display.data_window)
plot(sosConfirmed and not rr_pass ? 1 : 0, title="SOS_CHASE",    display=display.data_window)
plot(sosConfirmed                 ? 1 : 0, title="SOS_RAW",      display=display.data_window)
plot(volOk                        ? 1 : 0, title="VOL_OK",       display=display.data_window)
plot(rangeDeveloped               ? 1 : 0, title="RANGE_DEV",    display=display.data_window)
plot(rr_pass                      ? 1 : 0, title="RR_GATE_PASS", display=display.data_window)
plot(adrPct,                               title="ADR_PCT",      display=display.data_window)
plot(risk_pct,                             title="RISK_PCT",     display=display.data_window)
// RR_HEADROOM = how much of ADR is unused after accounting for risk, as a percentage.
// 100 = perfect (no risk), 0 = risk equals ADR (gate barely passed), <0 = gate failed.
// Filter ">20" for high-conviction setups: risk uses less than 80% of ADR.
rr_headroom_pct = adrPct > 0 ? 100.0 * (1.0 - (risk_pct / adrPct)) : na
plot(rr_headroom_pct,                      title="RR_HEADROOM",  display=display.data_window)
plot(stop_price,                           title="STOP",         display=display.data_window)
plot(t1,                                   title="T1",           display=display.data_window)
plot(t2,                                   title="T2",           display=display.data_window)
plot(close,                                title="PRICE",        display=display.data_window)
plot(volume,                               title="VOLUME",       display=display.data_window)
plot(goSignal ? 1 : 0,                     title="GO_SIGNAL",    display=display.data_window)
plot(goModerate ? 1 : 0,                   title="GO_MODERATE",  display=display.data_window)
plot(aboveMA  ? 1 : 0,                     title="ABOVE_30WMA",  display=display.data_window)
plot(maRising ? 1 : 0,                     title="MA_RISING",    display=display.data_window)
plot(rsAbove  ? 1 : 0,                     title="RS_POSITIVE",  display=display.data_window)

// Data labels
if showLabels and sosConfirmed and rr_pass
    txt = "SOS PASS  ·  " + stop_source +
          "\nEntry "  + str.tostring(entry_eod, "#.##") +
          "  Stop "   + str.tostring(stop_price, "#.##") +
          "\nT1 "     + str.tostring(t1, "#.##") +
          "  T2 "     + str.tostring(t2, "#.##") +
          "\nRisk% "  + str.tostring(risk_pct, "#.##") +
          "  ADR% "   + str.tostring(adrPct, "#.##")
    label.new(bar_index, low, text=txt, style=label.style_label_up, color=color.new(#26a69a, 75), textcolor=chart.fg_color, size=size.small, yloc=yloc.belowbar)

if showLabels and showChase and sosConfirmed and not rr_pass
    txt = "CHASE — REJECT\nRisk% " + str.tostring(risk_pct, "#.##") + " > ADR% " + str.tostring(adrPct, "#.##")
    label.new(bar_index, low, text=txt, style=label.style_label_up, color=color.new(#ef5350, 75), textcolor=chart.fg_color, size=size.small, yloc=yloc.belowbar)

// ============== Alerts ==============
// Subscribe to "SOS PASS" alert across a watchlist of high-volume names.
alertcondition(sosConfirmed and rr_pass,     title="EP9 SOS PASS",  message="EP9 SOS PASS · {{ticker}} @ {{close}} · stop in description")
alertcondition(sosConfirmed and not rr_pass, title="EP9 SOS CHASE", message="EP9 SOS CHASE (rejected) · {{ticker}} @ {{close}}")

// ============== Status table ==============
var table tbl = table.new(tablePos, 2, 11, border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)
if showStatusTable and barstate.islast
    bg_head = color.new(#0d47a1, 0)
    bg_pass = color.new(#26a69a, 30)
    bg_fail = color.new(#ef5350, 30)
    bg_neut = color.new(color.gray, 80)

    table.cell(tbl, 0, 0, "EP9",          text_color=color.white, bgcolor=bg_head)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=bg_head)

    table.cell(tbl, 0, 1, "Vol ≥ " + str.tostring(volThreshold/1000000.0, "#.#") + "M")
    table.cell(tbl, 1, 1, str.tostring(volume/1000000.0, "#.##") + "M", bgcolor = volOk ? bg_pass : bg_fail)

    table.cell(tbl, 0, 2, "Price ≥ $" + str.tostring(priceFloor, "#.##"))
    table.cell(tbl, 1, 2, str.tostring(close, "#.##"), bgcolor = cond4 ? bg_pass : bg_fail)

    table.cell(tbl, 0, 3, "C1 prior not up")
    table.cell(tbl, 1, 3, cond1 ? "✓" : "✗", bgcolor = cond1 ? bg_pass : bg_fail)

    table.cell(tbl, 0, 4, "C2 strong close")
    table.cell(tbl, 1, 4, cond2 ? "✓" : "✗", bgcolor = cond2 ? bg_pass : bg_fail)

    table.cell(tbl, 0, 5, "C3 body expand")
    table.cell(tbl, 1, 5, cond3 ? "✓" : "✗", bgcolor = cond3 ? bg_pass : bg_fail)

    table.cell(tbl, 0, 6, "ADR%(14)")
    table.cell(tbl, 1, 6, str.tostring(adrPct, "#.##") + "%")

    table.cell(tbl, 0, 7, "Stop source")
    table.cell(tbl, 1, 7, sosConfirmed ? stop_source : "—", bgcolor = bg_neut)

    table.cell(tbl, 0, 8, "Risk% / ADR%")
    table.cell(tbl, 1, 8, sosConfirmed ? (str.tostring(risk_pct, "#.##") + " / " + str.tostring(adrPct, "#.##")) : "—", bgcolor = sosConfirmed ? (rr_pass ? bg_pass : bg_fail) : bg_neut)

    state = sosConfirmed ? (rr_pass ? "PASS" : "CHASE") : "—"
    state_bg = sosConfirmed ? (rr_pass ? bg_pass : bg_fail) : bg_neut
    table.cell(tbl, 0, 9, "SOS")
    table.cell(tbl, 1, 9, state, bgcolor = state_bg, text_color = color.white)

    // Go/No-Go verdict — meaningful only when SOS PASS fires.
    verdict     = sosConfirmed and rr_pass ? (goSignal ? "GO" : "NO-GO") : "—"
    verdict_bg  = sosConfirmed and rr_pass ? (goSignal ? color.new(color.green, 0) : color.new(color.red, 0)) : bg_neut
    detail      = "↑MA " + (aboveMA ? "✓" : "✗") + " · MA↗ " + (maRising ? "✓" : "✗") + " · RS " + (rsAbove ? "✓" : "✗")
    table.cell(tbl, 0, 10, "Go/No-Go")
    table.cell(tbl, 1, 10, verdict + (sosConfirmed and rr_pass ? "  " + detail : ""), bgcolor = verdict_bg, text_color = color.white)
````
