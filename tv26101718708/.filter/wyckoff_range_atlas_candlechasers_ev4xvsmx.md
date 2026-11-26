# Wyckoff Range Atlas [CandleChasers]

- url: https://www.tradingview.com/script/ev4XVSmX-Wyckoff-Range-Atlas-CandleChasers/
- type: indicator
- pine_id: PUB;dbe52bd151934a8995867f6abf3c8fd0
- version: 1.0

## Description

[b]Wyckoff Range Atlas[/b] is an indicator for studying trading ranges, price-and-volume events, breakouts, and subsequent retests through a rules-based interpretation of Wyckoff concepts.

[b]Automatic and manual trading ranges
[/b]Automatic mode identifies ranges with low directional efficiency, suitable width relative to ATR, and distinct visits to support and resistance. Adjacent candles at a boundary count as one visit; a new visit requires a configurable number of bars outside the boundary zone.

Once a range is detected, its support, resistance, and ATR scale are frozen. This gives subsequent events a consistent reference. Manual mode lets you enter your own support, resistance, and activation time for discretionary analysis.

[b]Wyckoff event labels
[/b]
- [b]SPR? — Spring candidate:[/b] a shallow move below support that closes strongly back inside the range.
- [b]UT? — Upthrust candidate:[/b] a shallow move above resistance that closes weakly back inside the range.
- [b]TEST — Sweep test:[/b] a later higher low or lower high with narrow spread and reduced volume in Required mode.
- [b]SOS — Sign of strength:[/b] a qualified upward breakout with wide spread, a strong closing location, and elevated relative volume in Required mode.
- [b]SOW — Sign of weakness:[/b] the corresponding qualified downward breakout.
- [b]LPS? / LPSY? — Retest candidates:[/b] a quiet, narrow-spread retest of the broken boundary within a defined window.
- [b]FAIL — Failed breakout:[/b] a close sufficiently back through the previously broken boundary.

Question marks identify interpretive candidates. A spring is not required before a qualified breakout. These patterns do not establish institutional positioning or guarantee a subsequent move.

[b]Higher-timeframe context
[/b]The dashboard includes optional context from completed higher-timeframe candles. It compares the last completed close with an EMA and checks the EMA's direction to display Bullish, Bearish, or Mixed context. This provides a broader trend reference without suppressing chart-timeframe signals. Select a context timeframe higher than the chart timeframe.

[b]Transparent signal diagnostics
[/b]A separate panel preserves the latest signal's relative volume, spread/ATR, closing location, boundary distance, sequence age, rule summary, and higher-timeframe context. These measurements explain the detected pattern; they are not a confidence percentage or a probability of success.

[b]Alerts[/b]
Ten named alert conditions cover range detection and the labeled event types. Configurable detailed JSON alerts include event names, symbol, timeframe, boundary prices, signal-bar timestamps, volume and spread measurements, and context.

For simple notifications, choose a named condition and Once Per Bar Close. For detailed payloads, choose **Any alert() function call** and enable your preferred event families in the indicator settings. New-range JSON notifications are disabled by default. Recreate alerts after changing the indicator's code or settings.

[b]Signal timing and volume modes
[/b]Signals commit at candle close and appear on the detection bar. Labels are not moved backward. Higher-timeframe context uses completed candles. The live volume value in the status dashboard can change during the open candle; last-signal diagnostics remain fixed until the next signal.

Required volume is the default and applies volume qualification to relevant patterns. Price only mode bypasses volume requirements and provides a reduced price-pattern interpretation. Feed volume may represent traded volume or tick activity, depending on the instrument.

[b]Getting started
[/b]
1. Add the indicator to a standard candlestick chart.
2. Start with Automatic mode and the default settings, then adjust the range lookback and event thresholds to the structure you are studying.
3. For Manual mode, enter support below resistance and select when those levels became known.
4. Set a higher context timeframe if using the context dashboard.
5. Choose named alerts or the detailed JSON alert workflow.

[b]Scope and limitations
[/b]Wyckoff Range Atlas is an indicator only. It places no orders and reports no strategy backtest results. It implements selected range events rather than full A–E phase classification, Point and Figure price targets, or proof of accumulation/distribution. Defaults are starting values rather than universally optimized settings.

Price patterns can fail, feed revisions and chart-history changes can affect calculations, and manual levels selected with hindsight can distort historical interpretation. No verified win rate, profitability, or trading edge is claimed.

[b]Signal reference
[/b]
| Label | Interpretation | Additional requirement |
| --- | --- | --- |
| SPR? | Support sweep and reclaim | Shallow penetration, strong close, inside range |
| UT? | Resistance sweep and rejection | Shallow penetration, weak close, inside range |
| TEST | Test following a sweep | Higher low/lower high, narrow spread, lower volume |
| SOS | Upward range breakout | Wide spread, close near high, relative volume threshold |
| SOW | Downward range breakout | Wide spread, close near low, relative volume threshold |
| LPS? | Former resistance tested as support | Quiet, narrow candle within retest window |
| LPSY? | Former support tested as resistance | Quiet, narrow candle within retest window |
| FAIL | Qualified breakout invalidated | Close 0.5 frozen ATR back through boundary |

[b]Defaults and tuning
[/b]Defaults are starting values, not optimized parameters. No market or timeframe performance claims have been established.

- Range lookback: 60 bars. Longer values seek broader structures.
- Maximum directional efficiency: 0.25. Lower values demand less net directional movement relative to total close-to-close travel.
- Range width: 2–12 prior ATR. Range boundaries use high/low extremes.
- Boundary visits: two per side. A new visit requires three consecutive bars outside that boundary zone; adjacent candles count as one visit. The boundary zone is capped at 20% of range width to prevent overlapping zones.
- Volume baseline: previous 20 bars, excluding the signal bar.
- Breakout volume: at least 1.3 times baseline.
- Test volume: at most baseline, and below the original sweep bar for sweep tests.
- Maximum sweep: one frozen ATR. Deeper shakeouts are intentionally excluded.
- Sweep test window: 15 bars. Breakout retest window: 25 bars.
- Range expiry: 180 bars after detection, including breakout tracking.

Required volume is the default. Missing/zero current volume suppresses volume-qualified pattern events; range detection and breakout-failure notifications do not require volume. Price only mode bypasses every volume test and must be described as a reduced price-pattern interpretation. Tick volume is a feed-specific activity proxy, not centralized traded volume.

[b]How the state machine behaves
[/b]The detector retains one range at a time. Automatic discovery requires distinct boundary visits. Manual mode bypasses discovery filters and activates one user-defined range. Automatic ranges begin when prior-bar discovery requirements pass; manual ranges begin at the selected activation time once ATR is available. Sweep candidates can occur within a range; a new accepted sweep replaces the pending sweep test. Qualified breaks enter upward/downward breakout tracking. A sweep is not required before a breakout. Each qualified breakout can have one labeled retest. An unqualified escape beyond one frozen ATR ends range tracking without issuing SOS/SOW. After failure or escape, Automatic mode resumes discovery on a later bar. On expiry, a new qualifying automatic range can be detected on the same bar. Manual mode does not automatically reactivate. This is not an A–E phase classifier.

The range plots begin one bar after detection to prevent line connections between separate ranges. No boundaries are drawn backward across their discovery window. Historical event labels remain, subject to TradingView's 300-label retention limit.

[b]Research basis
[/b]Wyckoff's supply/demand and effort/result principles inform the volume/spread filters. Springs, upthrusts, tests, SOS/SOW, and LPS/LPSY inform event sequencing. This indicator does not implement Point and Figure cause/effect counts, price objectives, relative-strength stock selection, or full schematic recognition. Range age is not a substitute for a Point and Figure target.

## Source Code

````pine
//@version=6
// Wyckoff Range Atlas [CandleChasers] — original rules-based interpretation, not a phase oracle.
// Events are committed at bar close. Ranges use prior bars and freeze on detection.
indicator("Wyckoff Range Atlas [CandleChasers]", shorttitle="[CC] WRA", overlay=true, max_labels_count=300, max_bars_back=600)

string G1 = "Range discovery"
string rangeMode = input.string("Automatic", "Range mode", options=["Automatic", "Manual"], group=G1)
float manualHigh = input.price(0.0, "Manual resistance", group=G1)
float manualLow = input.price(0.0, "Manual support", group=G1)
int manualStart = input.time(0, "Manual activation time", tooltip="Choose when these levels became known. One range is activated at the first eligible close at/after this time. No automatic rearming.", group=G1)
int visitGap = input.int(3, "Outside bars between boundary visits", minval=1, maxval=20, group=G1)
int length = input.int(60, "Range lookback", minval=20, maxval=300, group=G1)
float maxER = input.float(0.25, "Maximum directional efficiency", minval=0.01, maxval=1, step=0.01, group=G1)
float minWidth = input.float(2.0, "Minimum width / ATR", minval=0.5, group=G1)
float maxWidth = input.float(12.0, "Maximum width / ATR", minval=1, group=G1)
int minTouches = input.int(2, "Minimum distinct visits per boundary", minval=1, maxval=10, group=G1)
int maxAge = input.int(180, "Maximum active range age", minval=20, maxval=1000, group=G1)
string G2 = "Event qualification"
int volLen = input.int(20, "Volume baseline", minval=5, group=G2)
string volMode = input.string("Required", "Volume mode", options=["Required", "Price only"], tooltip="Required suppresses events when volume is unavailable. Price only bypasses volume checks; it is a reduced price-pattern interpretation.", group=G2)
float breakoutRV = input.float(1.3, "Breakout minimum relative volume", minval=0.1, step=0.1, group=G2)
float testRV = input.float(1.0, "Test maximum relative volume", minval=0.1, step=0.1, group=G2)
float bufferATR = input.float(0.15, "Boundary buffer / ATR", minval=0, step=0.05, group=G2)
float sweepATR = input.float(1.0, "Maximum sweep depth / ATR", minval=0.1, step=0.1, group=G2)
int testWindow = input.int(15, "Sweep test window", minval=2, maxval=100, group=G2)
int retestWindow = input.int(25, "Breakout retest window", minval=2, maxval=100, group=G2)
int cooldown = input.int(5, "Sweep cooldown bars", minval=1, group=G2)
string G4 = "Higher-timeframe context"
bool useHTF = input.bool(true, "Show confirmed context", group=G4)
string contextTF = input.timeframe("1D", "Context timeframe", group=G4)
int contextLen = input.int(50, "Context EMA length", minval=5, maxval=300, group=G4)
string G5 = "Detailed alerts"
bool richAlerts = input.bool(true, "Enable JSON alert() messages", group=G5)
bool alertRanges = input.bool(false, "Include new ranges", group=G5)
bool alertSweeps = input.bool(true, "Include sweep candidates", group=G5)
bool alertTests = input.bool(true, "Include sweep tests", group=G5)
bool alertBreaks = input.bool(true, "Include SOS / SOW", group=G5)
bool alertRetests = input.bool(true, "Include LPS / LPSY", group=G5)
bool alertFailures = input.bool(true, "Include failed breaks", group=G5)
string G3 = "Appearance"
bool showDiagnostics = input.bool(true, "Last-signal diagnostics", group=G3)
bool showLabels = input.bool(true, "Event labels", group=G3)
bool showPanel = input.bool(true, "Status panel", group=G3)
bool shade = input.bool(true, "Range fill", group=G3)
color bull = input.color(color.rgb(0, 190, 150), "Demand color", group=G3)
color bear = input.color(color.rgb(240, 90, 110), "Supply color", group=G3)

bool manual = rangeMode == "Manual"
if barstate.isfirst and manual and (manualHigh <= manualLow or manualLow <= 0)
    runtime.error("Manual resistance must exceed positive manual support.")
if barstate.isfirst and not manual and minWidth > maxWidth
    runtime.error("Minimum range width must not exceed maximum width.")
if barstate.isfirst and bufferATR >= sweepATR
    runtime.error("Boundary buffer must be smaller than maximum sweep depth.")
bool validHTF = timeframe.in_seconds(contextTF) > timeframe.in_seconds()
float hClose = na
float hEMA = na
float hPrevEMA = na
if useHTF and validHTF
    // Offset every tuple member; lookahead_on carries only completed HTF values.
    [hc, he, hp] = request.security(syminfo.tickerid, contextTF, [close[1], ta.ema(close, contextLen)[1], ta.ema(close, contextLen)[2]], lookahead=barmerge.lookahead_on)
    hClose := hc
    hEMA := he
    hPrevEMA := hp
string context = not useHTF ? "Off" : not validHTF ? "Select higher TF" : na(hEMA) or na(hPrevEMA) ? "Warming up" : hClose > hEMA and hEMA > hPrevEMA ? "Bullish" : hClose < hEMA and hEMA < hPrevEMA ? "Bearish" : "Mixed"
float atr = ta.atr(14)
float baseline = ta.sma(volume, volLen)[1]
bool volumeOK = not na(volume) and volume > 0 and not na(baseline) and baseline > 0
bool priceOnly = volMode == "Price only"
float rv = volumeOK ? volume / baseline : na
float spread = math.max(high - low, syminfo.mintick)
float clv = (close - low) / spread
float candidateHi = ta.highest(high[1], length)
float candidateLo = ta.lowest(low[1], length)
float travel = math.sum(math.abs(ta.change(close)), length)[1]
float er = not na(travel) and travel > 0 ? math.abs(close[1] - close[length + 1]) / travel : 1.0
float priorATR = atr[1]
float candidateWidth = candidateHi - candidateLo
bool discovery = bar_index > length + volLen and priorATR > 0 and candidateWidth >= minWidth * priorATR and candidateWidth <= maxWidth * priorATR and er <= maxER

var bool manualUsed = false
var int topVisits = na
var int bottomVisits = na
var float roof = na
var float floor = na
var float unit = na
var int born = na
// 0 searching; 1 range; 2 upward break; -2 downward break.
var int state = 0
var int sweepSide = 0
var int sweepBar = na
var float sweepExtreme = na
var float sweepVolume = na
var int lastSweep = na
var int breakBar = na
var bool retested = false
var string lastEvent = "None"
bool spring = false
bool upthrust = false
bool springTest = false
bool upthrustTest = false
bool sos = false
bool sow = false
bool lps = false
bool lpsy = false
bool failed = false
bool newRange = false
int sequenceAge = na
var string diagnosticEvent = "No signal yet"
var string diagnosticVolume = "—"
var string diagnosticSpread = "—"
var string diagnosticClose = "—"
var string diagnosticDepth = "—"
var string diagnosticSequence = "—"
var string diagnosticRules = "—"
var string diagnosticHTF = "—"

if barstate.isconfirmed
    if state != 0 and bar_index - born > maxAge
        state := 0
        sweepSide := 0
    bool activateManual = manual and not manualUsed and time >= manualStart and not na(priorATR) and priorATR > 0
    if state == 0 and ((not manual and discovery) or activateManual)
        int topHits = 0
        int bottomHits = 0
        if not manual
            float tolerance = math.min(candidateWidth * 0.2, math.max(priorATR * 0.35, candidateWidth * 0.05))
            int topOutside = visitGap
            int bottomOutside = visitGap
            // Traverse oldest to newest. A visit must leave the zone for visitGap bars.
            for i = length to 1
                bool atTop = high[i] >= candidateHi - tolerance
                bool atBottom = low[i] <= candidateLo + tolerance
                if atTop
                    if topOutside >= visitGap
                        topHits += 1
                    topOutside := 0
                else
                    topOutside += 1
                if atBottom
                    if bottomOutside >= visitGap
                        bottomHits += 1
                    bottomOutside := 0
                else
                    bottomOutside += 1
        if manual or (topHits >= minTouches and bottomHits >= minTouches)
            roof := manual ? manualHigh : candidateHi
            floor := manual ? manualLow : candidateLo
            topVisits := manual ? na : topHits
            bottomVisits := manual ? na : bottomHits
            manualUsed := manual
            unit := priorATR
            born := bar_index
            state := 1
            sweepSide := 0
            lastSweep := na
            breakBar := na
            retested := false
            newRange := true
            lastEvent := manual ? "Manual range activated" : "Range detected"
    sequenceAge := sweepSide != 0 ? bar_index - sweepBar : math.abs(state) == 2 ? bar_index - breakBar : na
    if state == 1
        float pad = unit * bufferATR
        bool allowedSweep = na(lastSweep) or bar_index - lastSweep >= cooldown
        bool volumeReady = priceOnly or volumeOK
        // Double-sided sweeps are intentionally ambiguous and produce no sweep label.
        spring := allowedSweep and volumeReady and low < floor - pad and low >= floor - unit * sweepATR and high <= roof + pad and close > floor and close < roof and clv >= 0.6
        upthrust := allowedSweep and volumeReady and high > roof + pad and high <= roof + unit * sweepATR and low >= floor - pad and close < roof and close > floor and clv <= 0.4
        if spring or upthrust
            sweepSide := spring ? 1 : -1
            sweepBar := bar_index
            sweepExtreme := spring ? low : high
            sweepVolume := volume
            lastSweep := bar_index
            lastEvent := spring ? "Spring candidate" : "Upthrust candidate"
            sequenceAge := 0
        if sweepSide != 0 and bar_index > sweepBar
            bool quiet = priceOnly or (volumeOK and rv <= testRV and volume < sweepVolume)
            bool narrow = spread <= unit
            springTest := sweepSide == 1 and bar_index - sweepBar <= testWindow and low > sweepExtreme and low <= floor + unit * 0.5 and close > floor and close < roof and clv >= 0.55 and quiet and narrow
            upthrustTest := sweepSide == -1 and bar_index - sweepBar <= testWindow and high < sweepExtreme and high >= roof - unit * 0.5 and close < roof and close > floor and clv <= 0.45 and quiet and narrow
            bool invalidSweep = sweepSide == 1 ? low < sweepExtreme : high > sweepExtreme
            if springTest or upthrustTest
                lastEvent := springTest ? "Spring test" : "Upthrust test"
                sweepSide := 0
            else if invalidSweep or bar_index - sweepBar > testWindow
                sweepSide := 0
        bool effort = priceOnly or (volumeOK and rv >= breakoutRV)
        sos := close > roof + pad and close > open and clv >= 0.7 and spread >= unit * 0.8 and effort
        sow := close < floor - pad and close < open and clv <= 0.3 and spread >= unit * 0.8 and effort
        if sos or sow
            state := sos ? 2 : -2
            breakBar := bar_index
            retested := false
            sweepSide := 0
            lastEvent := sos ? "Sign of strength" : "Sign of weakness"
            sequenceAge := 0
        else if close > roof + unit or close < floor - unit
            // Unqualified escape ends the range rather than inventing a SOS/SOW.
            state := 0
            sweepSide := 0
            lastEvent := "Unqualified escape"
    else if math.abs(state) == 2 and bar_index > breakBar
        float pad = unit * bufferATR
        bool quiet = priceOnly or (volumeOK and rv <= testRV)
        lps := state == 2 and not retested and bar_index - breakBar <= retestWindow and low <= roof + unit * 0.5 and low >= roof - unit * 0.5 and close > roof + pad and clv >= 0.55 and spread <= unit and quiet
        lpsy := state == -2 and not retested and bar_index - breakBar <= retestWindow and high >= floor - unit * 0.5 and high <= floor + unit * 0.5 and close < floor - pad and clv <= 0.45 and spread <= unit and quiet
        if lps or lpsy
            retested := true
            lastEvent := lps ? "LPS candidate" : "LPSY candidate"
        failed := state == 2 ? close < roof - unit * 0.5 : close > floor + unit * 0.5
        if failed
            state := 0
            lastEvent := "Breakout failed"

    bool signal = spring or upthrust or springTest or upthrustTest or sos or sow or lps or lpsy or failed
    if signal
        bool upward = spring or springTest or sos or lps
        float depth = spring ? floor - low : upthrust ? high - roof : springTest ? low - floor : upthrustTest ? roof - high : sos or lps ? close - roof : sow or lpsy ? floor - close : state[1] == 2 ? roof - close : close - floor
        diagnosticEvent := lastEvent
        diagnosticVolume := priceOnly ? "BYPASSED (price only)" : volumeOK ? str.tostring(rv, "#.##") + "x baseline" : "Unavailable"
        diagnosticSpread := str.tostring(spread / unit, "#.##") + " frozen ATR"
        diagnosticClose := str.tostring(clv * 100, "#.0") + "% from low"
        diagnosticDepth := str.tostring(depth / unit, "#.##") + " ATR; " + str.tostring(depth, format.mintick)
        diagnosticSequence := na(sequenceAge) ? "—" : str.tostring(sequenceAge) + " bars"
        diagnosticHTF := context
        diagnosticRules := spring or upthrust ? "Shallow sweep + inside close" : springTest or upthrustTest ? "Extreme holds + quiet/narrow" : sos or sow ? "Outward close + spread/effort" : lps or lpsy ? "Boundary holds + quiet/narrow" : "Close through failure threshold"


f_label(bool event, string caption, bool upward, color tint) =>
    if event and showLabels
        label.new(bar_index, upward ? low : high, caption, style=upward ? label.style_label_up : label.style_label_down, color=color.new(tint, 12), textcolor=color.white, size=size.tiny)
f_label(spring, "SPR?", true, bull)
f_label(upthrust, "UT?", false, bear)
f_label(springTest, "TEST", true, bull)
f_label(upthrustTest, "TEST", false, bear)
f_label(sos, "SOS", true, bull)
f_label(sow, "SOW", false, bear)
f_label(lps, "LPS?", true, bull)
f_label(lpsy, "LPSY?", false, bear)
f_label(failed, "FAIL", state[1] == -2, color.gray)
color rangeColor = state == 2 ? bull : state == -2 ? bear : color.rgb(110, 140, 185)
// Gap the lines when a new range starts; never connect unrelated boundaries.
float upperPlot = state != 0 and not newRange ? roof : na
float lowerPlot = state != 0 and not newRange ? floor : na
p1 = plot(upperPlot, "Frozen resistance", color=rangeColor, linewidth=2, style=plot.style_linebr)
p2 = plot(lowerPlot, "Frozen support", color=rangeColor, linewidth=2, style=plot.style_linebr)
plot(state != 0 and not newRange ? (roof + floor) / 2 : na, "Range midpoint", color=color.new(rangeColor, 65), style=plot.style_linebr)
fill(p1, p2, color=shade ? color.new(rangeColor, 93) : na, title="Trading range")
plot(rv, "Relative volume", display=display.data_window)
plot(er, "Discovery efficiency", display=display.data_window)

var table panel = table.new(position.top_right, 2, 7, bgcolor=color.new(color.rgb(18, 24, 35), 8), frame_color=color.new(color.gray, 65), frame_width=1)
if barstate.islast
    if showPanel
        string status = state == 0 ? "Searching" : state == 1 ? "Trading range" : state == 2 ? "Upward break" : "Downward break"
        table.cell(panel, 0, 0, "[CandleChasers]", text_color=color.white)
        table.cell(panel, 1, 0, "WYCKOFF ATLAS", text_color=rangeColor)
        table.cell(panel, 0, 1, "Structure", text_color=color.silver)
        table.cell(panel, 1, 1, status, text_color=color.white)
        table.cell(panel, 0, 2, "Last event", text_color=color.silver)
        table.cell(panel, 1, 2, lastEvent, text_color=color.white)
        table.cell(panel, 0, 3, "Volume", text_color=color.silver)
        table.cell(panel, 1, 3, priceOnly ? "PRICE ONLY" : volumeOK ? str.tostring(rv, "#.##") + "x" : "UNAVAILABLE", text_color=priceOnly or not volumeOK ? color.orange : color.white)
        table.cell(panel, 0, 4, "Range age", text_color=color.silver)
        table.cell(panel, 1, 4, state != 0 ? str.tostring(bar_index - born) + " bars" : "—", text_color=color.white)
        table.cell(panel, 0, 5, "HTF " + contextTF, text_color=color.silver)
        table.cell(panel, 1, 5, context, text_color=context == "Bullish" ? bull : context == "Bearish" ? bear : color.silver)
        table.cell(panel, 0, 6, manual ? "Range mode" : "Visits R / S", text_color=color.silver)
        table.cell(panel, 1, 6, manual ? manualUsed and state == 0 ? "Manual finished" : "Manual" : state == 0 ? "—" : str.tostring(topVisits) + " / " + str.tostring(bottomVisits), text_color=color.white)
    else
        table.clear(panel, 0, 0, 1, 6)

alertcondition(newRange, "Range detected", "[CandleChasers] WRA: new frozen trading range on {{ticker}} {{interval}}.")
alertcondition(spring, "Spring candidate", "[CandleChasers] WRA: spring candidate on {{ticker}} {{interval}}. Close: {{close}}.")
alertcondition(upthrust, "Upthrust candidate", "[CandleChasers] WRA: upthrust candidate on {{ticker}} {{interval}}. Close: {{close}}.")
alertcondition(springTest, "Spring test", "[CandleChasers] WRA: lower-volume spring test on {{ticker}} {{interval}}.")
alertcondition(upthrustTest, "Upthrust test", "[CandleChasers] WRA: lower-volume upthrust test on {{ticker}} {{interval}}.")
alertcondition(sos, "Sign of strength", "[CandleChasers] WRA: qualified upward range break on {{ticker}} {{interval}}.")
alertcondition(sow, "Sign of weakness", "[CandleChasers] WRA: qualified downward range break on {{ticker}} {{interval}}.")
alertcondition(lps, "LPS candidate", "[CandleChasers] WRA: support retest after SOS on {{ticker}} {{interval}}.")
alertcondition(lpsy, "LPSY candidate", "[CandleChasers] WRA: resistance retest after SOW on {{ticker}} {{interval}}.")
alertcondition(failed, "Failed breakout", "[CandleChasers] WRA: breakout invalidated on {{ticker}} {{interval}}.")


// Snapshot diagnostics describe the last signal, not the changing live candle.
var table diagnostics = table.new(position.bottom_right, 2, 9, bgcolor=color.new(color.rgb(18, 24, 35), 8), frame_color=color.new(color.gray, 65), frame_width=1)
if barstate.islast
    if showDiagnostics
        array<string> keys = array.from("LAST SIGNAL", "Volume", "Spread", "Close location", "Boundary distance", "Sequence age", "Rules passed", "HTF at signal", "Interpretation")
        array<string> values = array.from(diagnosticEvent, diagnosticVolume, diagnosticSpread, diagnosticClose, diagnosticDepth, diagnosticSequence, diagnosticRules, diagnosticHTF, "Pattern; not probability")
        for row = 0 to 8
            table.cell(diagnostics, 0, row, array.get(keys, row), text_color=color.silver, text_size=size.tiny)
            table.cell(diagnostics, 1, row, array.get(values, row), text_color=color.white, text_size=size.tiny)
    else
        table.clear(diagnostics, 0, 0, 1, 8)

f_jsonNumber(float value) =>
    na(value) ? "null" : str.tostring(value, "#.########")
f_escape(string value) =>
    str.replace_all(str.replace_all(value, "\\", "\\\\"), "\"", "\\\"")
f_event(string accumulated, bool include, string name) =>
    include ? accumulated + (str.length(accumulated) > 0 ? "|" : "") + name : accumulated

// Create an alert using 'Any alert() function call' to receive these payloads.
if barstate.isconfirmed and richAlerts
    string events = ""
    events := f_event(events, alertRanges and newRange, "range")
    events := f_event(events, alertSweeps and spring, "spring_candidate")
    events := f_event(events, alertSweeps and upthrust, "upthrust_candidate")
    events := f_event(events, alertTests and springTest, "spring_test")
    events := f_event(events, alertTests and upthrustTest, "upthrust_test")
    events := f_event(events, alertBreaks and sos, "SOS")
    events := f_event(events, alertBreaks and sow, "SOW")
    events := f_event(events, alertRetests and lps, "LPS_candidate")
    events := f_event(events, alertRetests and lpsy, "LPSY_candidate")
    events := f_event(events, alertFailures and failed, "failed_breakout")
    if str.length(events) > 0
        string message = "{\"brand\":\"CandleChasers\",\"indicator\":\"Wyckoff Range Atlas\",\"version\":\"2.0\",\"events\":\"" + events + "\",\"symbol\":\"" + f_escape(syminfo.tickerid) + "\",\"timeframe\":\"" + f_escape(timeframe.period) + "\",\"bar_open_ms\":" + str.tostring(time) + ",\"bar_close_ms\":" + (na(time_close) ? "null" : str.tostring(time_close))
        message += ",\"close\":" + f_jsonNumber(close) + ",\"support\":" + f_jsonNumber(floor) + ",\"resistance\":" + f_jsonNumber(roof) + ",\"frozen_atr\":" + f_jsonNumber(unit) + ",\"relative_volume\":" + f_jsonNumber(rv) + ",\"spread_atr\":" + f_jsonNumber(spread / unit) + ",\"close_location\":" + f_jsonNumber(clv)
        message += ",\"sequence_age_bars\":" + (na(sequenceAge) ? "null" : str.tostring(sequenceAge)) + ",\"range_age_bars\":" + str.tostring(bar_index - born) + ",\"range_mode\":\"" + rangeMode + "\",\"volume_mode\":\"" + volMode + "\",\"context_timeframe\":\"" + f_escape(contextTF) + "\",\"context\":\"" + context + "\"}"
        alert(message, alert.freq_once_per_bar_close)
````
