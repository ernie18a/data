<!-- tradingview-pine-id: PUB;6cb86999e6774e30959f58c4a2612f8c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Stress Radar

Source: https://www.tradingview.com/script/WdWFZQkn/

## Description

Market Stress Radar

Which assets withstand a market selloff — and which recover first?

Market Stress Radar compares an asset with a selected benchmark during defined market stress episodes. It tracks their losses from a shared reference date, their recovery times, and whether initial relative strength turns into weakness.

READING THE CHART

• Green line: Asset return from its own pre-stress closing price.
• Blue line: Benchmark return from its own pre-stress closing price.
• Zero line: Each instrument’s respective reference price.
• Orange shading: Stress detection day.
• Green triangle: First asset recovery after detection.
• Orange triangle: Delayed relative weakness.
• Gray square: Observation window ended.

Both return lines use the same reference date. They appear during monitored episodes and remain blank between episodes.

HOW STRESS IS DETECTED

By default, the radar examines the benchmark’s three-day return.

A stress episode starts when the decline reaches the larger of:

• A minimum drop of 3%.
• 1.5 × pre-window ATR percentage × √3, using a 20-day ATR.

The volatility measurement comes from before the decline window. This is a scaling rule, not a statistical confidence level.

Detection requires a fresh transition into stress and a confirmed daily close. Only one episode is monitored at a time; additional triggers during that episode are ignored.

RECOVERY: FIRST TOUCH AND EPISODE COMPLETION

The reference prices are frozen at the closing prices immediately before the measured decline window.

D0 is the detection day. An instrument first recovers when it closes at or above its own frozen reference price. A value already above that price on D0 is recorded as D+0.

First recovery does not mean permanent recovery. An asset can recover and subsequently fall back below its reference.

The episode ends when:

• Both instruments close at or above their respective reference prices on the same day; or
• The observation limit is reached — 30 daily bars after detection by default.

Missing or misaligned data ends the episode separately. Elapsed days refer to daily chart bars, which are trading sessions for stocks.

ILLUSTRATIVE EXAMPLE

Suppose BTC falls 8% over the detection window while the chart coin falls 3%.

The coin initially leads BTC by 5 percentage points.

If the coin returns to its own reference price four daily bars after detection, its first recovery is recorded as D+4. If BTC remains below its reference, monitoring continues.

If either instrument never recovers within the observation window, that recovery remains NOT OBSERVED. A timeout is not counted as a successful recovery.

This is a hypothetical example, not a backtest result.

DELAYED RELATIVE WEAKNESS

An initially resilient asset can lose its advantage.

With the default settings, the radar issues one warning per episode when:

• The asset initially leads its benchmark by at least 0.5 percentage points; and
• Its lead later falls to −0.5 percentage points or below.

WEAKNESS OBSERVED records that this happened during the episode. It does not necessarily mean the asset is still underperforming; the latest returns and relative lead show the current relationship.

COMPACT DASHBOARD

The dashboard shows:

• Episode status.
• Asset and benchmark returns.
• First recovery day, or OPEN / NOT OBSERVED.
• Initial and latest relative lead.
• Detection date, elapsed daily bars and reference date.
• Counts of jointly recovered episodes, timeouts and data gaps.

After an episode ends, LAST EPISODE identifies the frozen final values. These are not current returns or trading win rates.

The dashboard can be placed in five positions.

SETUP

Use standard 1D candles.

Automatic benchmark selection:

• Crypto: BINANCE:BTCUSDT.
• USD stocks: AMEX:SPY.

A custom benchmark can also be selected. Use instruments with matching daily sessions and comparable quote currencies. No currency conversion is performed.

ALERTS

Six alert conditions are available:

• New market stress.
• First asset recovery.
• Late relative weakness.
• Both instruments recovered.
• Observation window ended.
• Data gap stopped the episode.

Configure alerts separately in TradingView.

METHOD AND LIMITATIONS

Calculations and event signals use confirmed daily closes. Markers are not backdated to the earlier reference date.

Results depend on the selected instruments, settings and available history. Historical data corrections can change results. Price returns account for splits but exclude dividend income.

Market Stress Radar is a descriptive analysis tool. It does not place trades, predict guaranteed recoveries or establish a profitable trading strategy.

---

## Source Code

````pine
//@version=6
// Original implementation for BotTradeLab. Descriptive stress-event monitor.
indicator("Market Stress Radar", "Stress Radar", overlay = false, precision = 2)

string mode = input.string("Auto", "Benchmark mode", options = ["Auto", "Custom"], group = "Benchmark", display = display.none, tooltip = "Auto: BTCUSDT for crypto, SPY for USD stocks. Choose a benchmark with the same daily session and comparable quote currency.")
string custom = input.symbol("BINANCE:BTCUSDT", "Custom benchmark", group = "Benchmark", display = display.none)
int lookback = input.int(3, "Stress window (days)", minval = 1, maxval = 10, group = "Detection", display = display.none)
float floorDrop = input.float(3.0, "Minimum benchmark drop (%)", minval = 0.1, step = 0.5, group = "Detection", display = display.none)
int atrLen = input.int(20, "Benchmark ATR length", minval = 2, maxval = 100, group = "Detection", display = display.none)
float atrMult = input.float(1.5, "Pre-window volatility multiplier", minval = 0, step = 0.25, group = "Detection", display = display.none, tooltip = "Drop threshold = max(minimum drop, multiplier × pre-window ATR% × sqrt(window)). Uses volatility before the measured decline, not volatility caused by it.")
int maxDays = input.int(30, "Maximum days after detection", minval = 1, maxval = 120, group = "Monitoring", display = display.none)
float leadBuffer = input.float(0.5, "Relative-strength buffer (pp)", minval = 0.1, step = 0.1, group = "Monitoring", display = display.none, tooltip = "Late weakness: initial asset lead >= this buffer, then current lead <= minus this buffer. One warning per episode.")
bool showPanel = input.bool(true, "Show compact dashboard", group = "Display", display = display.none)
string corner = input.string("Middle left", "Dashboard position", options = ["Middle left", "Top left", "Bottom left", "Top right", "Bottom right"], group = "Display", display = display.none)
bool showMarkers = input.bool(true, "Show event markers", group = "Display", display = display.none)

bool crypto = syminfo.type == "crypto"
if barstate.isfirst and (not timeframe.isdaily or timeframe.multiplier != 1 or not chart.is_standard or (not crypto and syminfo.type != "stock") or (not crypto and syminfo.currency != "USD"))
    runtime.error("Use a standard 1D chart of a crypto pair or a USD stock. Match benchmark sessions and quote currencies.")
string benchmark = mode == "Custom" ? custom : crypto ? "BINANCE:BTCUSDT" : "AMEX:SPY"
string assetId = ticker.new(syminfo.prefix, syminfo.ticker, session.regular, adjustment.splits)
string benchId = ticker.modify(benchmark, session = session.regular, adjustment = adjustment.splits)
[a, aEnd] = request.security(assetId, "1D", [close, time_close], gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off)
[b, bEnd, bAtr] = request.security(benchId, "1D", [close, time_close, ta.atr(atrLen)], gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool aligned = not na(a) and not na(b) and a > 0 and b > 0 and aEnd == bEnd
// Require every pair of bars in the detection window, including the anchor.
bool windowOK = bar_index >= lookback
for offset = 0 to lookback
    windowOK := windowOK and aligned[offset]
float threshold = not na(bAtr[lookback]) and b[lookback] > 0 ? math.max(floorDrop, atrMult * 100 * bAtr[lookback] / b[lookback] * math.sqrt(lookback)) : na
float windowReturn = windowOK ? 100 * (b / b[lookback] - 1) : na
bool stress = windowOK and not na(threshold) and windowReturn <= -threshold
bool candidate = stress and not stress[1] and windowOK[1] and not na(threshold[1])

var bool active = false
var int startBar = na
var int detectionDate = na
var int anchorDate = na
var int age = 0
var float baseA = na
var float baseB = na
var float assetReturn = na
var float benchReturn = na
var float initialLead = na
var float frozenThreshold = na
var int assetRecovery = na
var int benchRecovery = na
var bool warned = false
var string state = "WAITING FOR STRESS"
var int episodes = 0
var int completed = 0
var int timedOut = 0
var int dataGaps = 0
bool started = false
bool assetRecovered = false
bool benchmarkRecovered = false
bool lateWeakness = false
bool ended = false
bool timeout = false
bool invalidated = false

if barstate.isconfirmed
    // Exactly one episode; no same-bar rearming after any terminal condition.
    if active
        age := bar_index - startBar
        if not aligned
            active := false
            invalidated := true
            dataGaps += 1
            assetReturn := na
            benchReturn := na
            state := "DATA GAP — STOPPED"
        else
            assetReturn := 100 * (a / baseA - 1)
            benchReturn := 100 * (b / baseB - 1)
            if na(assetRecovery) and a >= baseA
                assetRecovery := age
                assetRecovered := true
            if na(benchRecovery) and b >= baseB
                benchRecovery := age
                benchmarkRecovered := true
            float lead = assetReturn - benchReturn
            if not warned and initialLead >= leadBuffer and lead <= -leadBuffer
                lateWeakness := true
                warned := true
            state := warned ? "WEAKNESS OBSERVED" : a >= baseA ? "ASSET RECOVERED" : not na(assetRecovery) ? "ASSET RELAPSED" : lead >= leadBuffer ? "RESILIENT" : lead <= -leadBuffer ? "LAGGING" : "MOVING WITH MARKET"
            // Both must be back at their OWN anchors on the same close to finish.
            if a >= baseA and b >= baseB
                active := false
                ended := true
                completed += 1
                state := "BOTH RECOVERED"
            else if age >= maxDays
                active := false
                timeout := true
                timedOut += 1
                state := "WINDOW ENDED"
    else if candidate
        active := true
        started := true
        episodes += 1
        startBar := bar_index
        detectionDate := time
        anchorDate := time[lookback]
        age := 0
        baseA := a[lookback]
        baseB := b[lookback]
        assetReturn := 100 * (a / baseA - 1)
        benchReturn := 100 * (b / baseB - 1)
        initialLead := assetReturn - benchReturn
        frozenThreshold := threshold
        assetRecovery := a >= baseA ? 0 : na
        benchRecovery := na
        warned := false
        state := a >= baseA ? "ASSET ALREADY ABOVE" : initialLead >= leadBuffer ? "RESILIENT" : initialLead <= -leadBuffer ? "LAGGING" : "MOVING WITH MARKET"

// Fixed anchors are historical references; events/markers are never backdated.
bool draw = active or started or ended or timeout
color mint = color.rgb(45, 212, 170)
color blue = color.rgb(96, 165, 250)
color orange = color.rgb(251, 146, 90)
hline(0, "Pre-stress close", color.new(color.gray, 45), hline.style_dashed)
plot(draw and not started ? assetReturn : na, "Asset return from anchor (%)", mint, 2, plot.style_linebr)
plot(draw and not started ? benchReturn : na, "Benchmark return from anchor (%)", blue, 2, plot.style_linebr)
plot(started ? assetReturn : na, "Asset at detection (%)", mint, 3, plot.style_circles, display = display.pane + display.data_window)
plot(started ? benchReturn : na, "Benchmark at detection (%)", blue, 3, plot.style_circles, display = display.pane + display.data_window)
bgcolor(started ? color.new(orange, 85) : na, title = "Stress detected")
plotshape(showMarkers and lateWeakness, "Late weakness", shape.triangledown, location.top, orange, size = size.tiny, display = display.pane)
plotshape(showMarkers and assetRecovered, "Asset first recovery", shape.triangleup, location.bottom, mint, size = size.tiny, display = display.pane)
plotshape(showMarkers and timeout, "Observation window ended", shape.square, location.bottom, color.gray, size = size.tiny, display = display.pane)
plot(draw ? assetReturn - benchReturn : na, "Relative lead (pp)", display = display.data_window)
plot(draw ? initialLead : na, "Initial relative lead (pp)", display = display.data_window)
plot(draw ? frozenThreshold : na, "Detection threshold (%)", display = display.data_window)
plot(draw ? age : na, "Days since detection", display = display.data_window)
plot(draw ? assetRecovery : na, "Asset first recovery day", display = display.data_window)
plot(draw ? benchRecovery : na, "Benchmark first recovery day", display = display.data_window)

f_num(float x) =>
    na(x) ? "—" : str.tostring(x, "0.00")
f_day(int day) =>
    not na(day) ? "D+" + str.tostring(day) : active ? "OPEN" : "NOT OBSERVED"
string panelPosition = corner == "Middle left" ? position.middle_left : corner == "Top left" ? position.top_left : corner == "Bottom left" ? position.bottom_left : corner == "Bottom right" ? position.bottom_right : position.top_right
var table panel = table.new(panelPosition, 2, 8, bgcolor = color.new(color.rgb(20, 27, 40), 12), border_width = 0)
f_cell(int col, int row, string txt, color ink = color.silver) =>
    table.cell(panel, col, row, txt, text_color = ink, text_size = size.small)
if barstate.islast and showPanel
    string status = na(startBar) and not windowOK ? "CHECK DATA / SESSIONS" : state
    f_cell(0, 0, "MARKET STRESS", color.white)
    f_cell(1, 0, active ? "LAST CLOSE" : na(startBar) ? "1D" : "LAST EPISODE", color.white)
    f_cell(0, 1, "Status")
    f_cell(1, 1, status, warned or invalidated ? orange : mint)
    f_cell(0, 2, syminfo.ticker, mint)
    f_cell(1, 2, f_num(assetReturn) + "% · " + (na(startBar) ? "—" : f_day(assetRecovery)), mint)
    f_cell(0, 3, benchmark, blue)
    f_cell(1, 3, f_num(benchReturn) + "% · " + (na(startBar) ? "—" : f_day(benchRecovery)), blue)
    f_cell(0, 4, "Initial → latest lead")
    f_cell(1, 4, f_num(initialLead) + " → " + f_num(assetReturn - benchReturn) + " pp")
    f_cell(0, 5, "Detected / day")
    f_cell(1, 5, na(startBar) ? "—" : str.format_time(detectionDate, "yyyy-MM-dd", "UTC") + " · D+" + str.tostring(age))
    f_cell(0, 6, "Anchor close")
    f_cell(1, 6, na(anchorDate) ? "—" : str.format_time(anchorDate, "yyyy-MM-dd", "UTC"))
    f_cell(0, 7, "Ended / timed out / gaps")
    f_cell(1, 7, str.tostring(completed) + " / " + str.tostring(timedOut) + " / " + str.tostring(dataGaps))

alertcondition(started, "New market stress", "Market Stress Radar: new benchmark stress episode on {{ticker}}. Daily close confirmed.")
alertcondition(assetRecovered, "Asset first recovery", "Market Stress Radar: {{ticker}} first closed back at or above its frozen pre-stress anchor.")
alertcondition(lateWeakness, "Late relative weakness", "Market Stress Radar: initially resilient {{ticker}} now trails its benchmark beyond the configured buffer.")
alertcondition(ended, "Both recovered", "Market Stress Radar: asset and benchmark are both at or above their own pre-stress anchors.")
alertcondition(timeout, "Observation window ended", "Market Stress Radar: observation limit reached on {{ticker}}. Recovery may remain unobserved.")
alertcondition(invalidated, "Data gap stopped episode", "Market Stress Radar: missing or misaligned data stopped the episode on {{ticker}}.")
````
