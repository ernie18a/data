# BoaBias: Anchored Swing VWAP (MTF) - Touch, Alerts, Stats

- url: https://www.tradingview.com/script/Q7UiNdAv-BoaBias-Anchored-Swing-VWAP-MTF-Touch-Alerts-Stats/
- type: indicator
- pine_id: PUB;25fc8cf811e84d6cb57caa088d693a18
- version: 1.0

## Description

█ [b]WHAT IT DOES[/b]

[b]Chart timeframe:[/b] Multiple [i]anchored[/i] VWAP curves from swing pivots—not session VWAP. Resistance-anchored paths (swing highs) and support-anchored paths (swing lows) draw as polylines and clear after [i]confirmation[/i] (same rules as the inputs: one qualifying close or [i]N bars in a row[/i]). Optional [b]touch markers[/b] when the bar range spans VWAP (green below / red above).

[b]Higher timeframes:[/b] Optional HTF 1–3 reuse the same pivot + anchored-VWAP logic inside [i]request.security[/i] with [i]barmerge.gaps_off[/i] and [i]barmerge.lookahead_off[/i]. Display as a [b]ribbon[/b] (midline ± % of price) or [b]stepped lines[/b]. Up to five concurrent VWAP slots per HTF (plot budget).

[b]Alerts:[/b] Separate [i]alert()[/i] channels—chart VWAP touches and optional HTF 1–3 midline touches when the [i]chart bar’s range[/i] crosses the HTF VWAP. Prefixes: [i]Chart VWAP touch[/i] / [i]HTF VWAP touch[/i] with ticker, price, time, and touched lines on HTF. Create Alert → this script → [i]Any alert() function call[/i]. [b]Alert frequency[/b] input applies to every [i]alert()[/i] from this script (once per bar / once per bar close / all ticks).

[b]Reaction statistics (optional table):[/b] A compact on-chart table aggregates how [i]closed[/i] swing-anchored lines behaved on the [b]chart timeframe only[/b]—not HTF curves. Toggle in inputs; [i]Show stats table[/i] is [b]on[/b] in factory defaults for this build (disable to reduce on-chart load). Cohort splits include touched vs no-touch, K/M-style breakout vs bounce windows after first touch, ATR pierce vs hold, and simple marginal “first event” proxies (swing-side pivot, opposite-side VWAP range touch, close beyond last swing). Numbers are descriptive context, not trade signals or guaranteed forward behaviour. When the table is enabled, lifecycle logic shares a small Pine [b]library[/b] module ([i]BoaBiasVwapSwingRxStats[/i]) so stats stay aligned with line confirmation.

█ [b]REACTION STATS TABLE — WHAT EACH ROW MEANS[/b]

Percent row labels use short tags: [i]b[/i] = “[b]b[/b]” bucket, [i]br[/i] = “[b]br[/b]” (break) bucket in the [b]K/M[/b] and [b]ATR[/b] rules [i]defined in code[/i] (not a broker term). Counts and % are [b]descriptive on history[/b]—not forecasts.

[list]
[*][b]Row 0 (headers) — [i]TF[/i] / [i]Support[/i] / [i]Resistance[/i] / [i]All[/i]:[/b] [i]TF[/i] shows the chart’s period. Columns 1–2 are support- and resistance-anchored [i]closed[/i] lines. [i]All[/i] = mixed view for FE totals and the combined line count.
[*][b]Line 1 — [i]n=[/i] and [i]X lines[/i]:[/b] [i]Support[/i] / [i]Resistance[/i] show how many [i]touched[/i] lines of that type finished (had at least one bar with range spanning VWAP before the line was confirmed and removed). The [i]All[/i] cell shows the total [i]completed[/i] lines: support + resistance anchors that were cleared by confirmation, including [i]no-touch[/i] cases.
[*][b][i]No-touch[/i] row:[/b] For lines that [i]never[/i] had [i]low[/i] ≤ VWAP ≤ [i]high[/i] before the line was confirmed, split by S/R. Percent (where shown) = no-touch count ÷ all [i]completed[/i] lines of that side (touched + no-touch).
[*][b][i]K/M b%[/i] and [i]K/M br%[/i]:[/b] [i]Denominator[/i] = [i]touched[/i] S/R lines only. After the first [i]touch[/i], the script tracks consecutive closes on the [i]break[/i] side of VWAP (K bars) in a post-touch window, and a flag if that ever reaches [b]K[/b] (see inputs). A line is bucketed as [b]K/M br[/b] (break) if, at the confirmation bar, either: (1) the bar is still within [b]M[/b] bars after the first touch, [i]or[/i] (2) the K-hold was reached in the tracked window. Otherwise, among touched lines, it counts in [b]K/M b[/b] ([i]b[/i] = non-`br` in this K/M sense). The [i]All[/i] cell on the K/M rows shows the active [b]K[/b]/[b]M[/b] from inputs.
[*][b][i]ATR b%[/i] and [i]ATR br%[/i]:[/b] [i]Denominator[/i] = touched S/R. Uses ATR = [b]R[/b]×ATR from VWAP (R and ATR length from inputs). A line is [b]ATR br[/b] if, with touch, the confirmation bar is still within [b]M_atr[/b] bars after the first touch [i]or[/i] a pierce of that ATR band occurred in the tracked window. Otherwise the touched line is counted in [b]ATR b[/b]. The [i]All[/i] cell shows [i]ATR length / R / M_atr[/i] used for the rule.
[*][b]FE (marginal) rows — [i]P(≥1)[/i], [i]P(swing)[/i], [i]P(opp)[/i], [i]P(cls)[/i], [i]P(none)[/i]:[/b] Only for [i]touched[/i] lines: before confirmation, the script can record the [i]first bar[/i] of three [i]optional[/i] “events” if they occur. [b]P(≥1):[/b] % where [i]at least one[/i] event occurred. [b]P(swing):[/b] a pivot of the [i]favourable[/i] side (for a resistance-anchored line, a swing [i]low[/i] bar is relevant; for support, a swing [i]high[/i]) is present in the path and used for the timing flag. [b]P(opp):[/b] the range first crosses another [i]active[/i] line of the [i]opposite[/i] type (its VWAP in range). [b]P(cls):[/b] close [i]beyond[/i] the [i]last[/i] recorded swing [i]high[/i] (for support) or [i]low[/i] (for resistance) before confirm. [b]P(none):[/b] % where [i]none[/i] of the three event types fired before the line closed. The [i]All[/i] column pools S+R for the [i]FE P(*)[/i] [i]All[/i] percentages.
[*][b][i]Avg life[/i] row:[/b] Average number of [i]chart bars[/i] from the anchor to confirmation, over [i]all[/i] completed lines. One merged cell in the table shows the value.
[/list]



█ [b]HOW IT WORKS[/b]

[list]
[*][b]Pivots:[/b] [i]ta.pivothigh[/i] / [i]ta.pivotlow[/i] with configurable left/right length. Each anchor seeds cumulative typical-price × volume from the anchor forward; VWAP = cumulative TPV / cumulative volume along that line’s active segment.
[*][b]Touch:[/b] [i]low[/i] ≤ VWAP ≤ [i]high[/i] on an active curve.
[*][b]Confirmation:[/b] Line removal when closes satisfy the far-side rule after the minimum post-anchor bars—[i]One bar[/i] or [i]N bars in a row[/i], per inputs.
[*][b]HTF packaging:[/b] Same mechanics on selected higher TFs; values are pulled without lookahead from the security call.
[*][b]Stats path:[/b] When the stats table is on, the script runs the shared library helpers so counters and polylines use the same confirmation and touch definitions as the visual path; HTF series do not feed those counters.
[/list]


█ [b]WHY THESE PIECES TOGETHER[/b]

Swing-anchored VWAP gives a volume path from structure; MTF ribbons or lines place that structure on a second axis of time; touch markers and alerts flag [i]range overlap[/i] without claiming execution edges; optional stats summarize historical line outcomes for research. The bundle is one overlay for context and notification—not a black-box signal service.

█ [b]HOW TO USE[/b]

[list]
[*][b]First use:[/b] If the indicator appears in the wrong scale (squashed or fullscreen), right-click the indicator → Pin to scale → Pin to right scale.
[*]Tune pivot length and confirmation mode; enable or disable touch markers, HTF layers, and each alert channel.
[*]Add alert → this script → [i]Any alert() function call[/i]; respect HTF toggles and that HTF alerts need the HTF layer shown and a higher TF than the chart.
[*][b]Higher-timeframe VWAPs:[/b] Show HTF 1–3 on the same chart to reduce [i]time and clicks[/i] switching TFs. The higher-TF midlines/ribbons add [i]structural context[/i] (where swing-based volume paths sit) without leaving the current timeframe.
[*][b]Reaction stats:[/b] The optional table is [b]on[/b] by default; turn it off if the on-chart table or extra compute is not needed. It aggregates how past [i]closed[/i] chart-TF lines behaved (cohort splits, not a live edge claim). That helps [i]reason about relative[/i] bounce/break and related counts on history—useful for [b]testing hypotheses and ideas[/b] (what-if inputs, not guaranteed forward odds).
[*][b]As a set:[/b] HTF + chart VWAP + optional stats supports exploring a [i]wide range[/i] of VWAP interaction ideas on the same price history. Position it as a [b]research and strategy-development[/b] layer (iterate rules on the chart, risk management stays separate)—not a turnkey signal.
[/list]

█ [b]LIMITATIONS[/b]

Meaningful volume improves the curves. Five HTF VWAP slots max per HTF (plot cap). HTF alerts use the [i]midline[/i] VWAP, not ribbon edges. Stats are [b]chart-TF only[/b] and historical. Structural / educational tool—[b]not[/b] financial advice and not a substitute for independent risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// Publication build: chart polylines + optional HTF ribbons + touch markers.
// Reaction stats: import Goldfinch_song/BoaBiasVwapSwingRxStats/1 (see indicators/README_VWAP_RX_LIBRARY.txt).
import Goldfinch_song/BoaBiasVwapSwingRxStats/1 as vrx
// Touch alerts: frequency in inputs; separate alert() for chart vs each HTF (optional toggles).
// Create alert on chart → this indicator → Any alert() function call.
indicator(title="BoaBias: Anchored Swing VWAP (MTF) - Touch, Alerts, Stats",
     shorttitle="BoaBias: Anchored VWAP MTF",
     overlay=true,
     scale=scale.right,
     max_lines_count=500,
     max_polylines_count=100)

// ============================================================================
// VWAP from swing highs (resistance) and swing lows (support).
// Alerts: chart-TF VWAP touches and optional HTF midline touches (bar range vs HTF line).
// Optional higher-timeframe swing VWAPs (stepped between HTF closes; same pivot logic).
// ============================================================================

// ---- Inputs ----
groupDetect = "Swing point detection"
pivotLen = input.int(5, "Pivot length (bars left/right)", minval=1, maxval=50, group=groupDetect)

groupTest = "Confirmation criterion"
confirmMode = input.string("N bars in a row", "Mode", options=["One bar", "N bars in a row"], group=groupTest)
confirmBars = input.int(2, "N bars in a row", minval=2, maxval=10, group=groupTest)

groupTouch = "Touch markers"
showTouchMarkers = input.bool(true, "Show touch markers", tooltip="Green dot below bar = support-anchored VWAP in range; red above = resistance-anchored.", group=groupTouch)

groupAlerts = "Alerts"
alertFreq = input.string("Once per bar", "Alert frequency",
     options=["Once per bar", "Once per bar close", "All ticks"],
     tooltip="Once per bar: first qualifying touch on the bar.\nOnce per bar close: when the bar closes (if still touching).\nAll ticks: every tick while the bar range crosses the level.",
     group=groupAlerts)
alertChartTF = input.bool(true, "Alert on chart VWAP touches", group=groupAlerts, tooltip="Short message. Uses Alert frequency above.")
alertHTF1 = input.bool(true, "Alert on HTF 1 midline touches", group=groupAlerts, tooltip="Chart bar range crosses HTF VWAP midline. Requires HTF 1 shown and valid TF.")
alertHTF2 = input.bool(true, "Alert on HTF 2 midline touches", group=groupAlerts)
alertHTF3 = input.bool(true, "Alert on HTF 3 midline touches", group=groupAlerts)

groupStyle = "Style"
colorFromHigh = input.color(color.red, "VWAP from high color", group=groupStyle)
colorFromLow  = input.color(color.green, "VWAP from low color", group=groupStyle)
lineWidth = input.int(2, "Chart polyline width", minval=1, maxval=4, group=groupStyle)

groupRxStats = "Reaction stats (chart TF, library)"
showRxStatsTable = input.bool(true, "Show stats table", group=groupRxStats)
kHoldBars = input.int(2, "K: consecutive closes past VWAP (break side)", minval=1, maxval=50, group=groupRxStats)
mBarsAfterTouch = input.int(5, "M: bars after first touch (K/M window)", minval=0, maxval=500, group=groupRxStats)
rxAtrLen = input.int(14, "ATR length (pierce rule)", minval=1, maxval=500, group=groupRxStats)
atrRMult = input.float(1.5, "R: pierce multiplier", minval=0.05, maxval=10.0, step=0.05, group=groupRxStats)
mAtrWindow = input.int(5, "M_atr after first touch", minval=0, maxval=500, group=groupRxStats)
tablePos = input.string("top_right", "Stats table position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=groupRxStats)
txtSize = input.string("normal", "Stats table text size", options=["tiny", "small", "normal", "large"], group=groupRxStats)

groupRxColors = "Reaction stats · table colors"
// Table text: chart.fg_color follows TradingView light/dark theme (readable as default label color).
rxTblHdrBg = input.color(color.new(color.gray, 0), "Header and row label bg", group=groupRxColors, tooltip="First row and first-column labels. Opaque by default (not a wash over the chart).")
rxTblSupBg = input.color(color.new(color.green, 82), "Support column bg", group=groupRxColors)
rxTblResBg = input.color(color.new(color.red, 82), "Resistance column bg", group=groupRxColors)
rxTblAllBg = input.color(color.new(color.blue, 80), "All / FE column bg", group=groupRxColors, tooltip="Third data column (All) where FE and aggregate % rows use a fill.")
rxTblPlainBg = input.color(color.new(color.white, 100), "Plain cell bg", group=groupRxColors, tooltip="e.g. timeframe cell, n=lines, parameter hints. 100% transparency = chart background.")
rxTblFooterBg = input.color(color.new(color.teal, 75), "Average life row bg", group=groupRxColors)

groupMtf = "Higher timeframe VWAPs"
showHTF1 = input.bool(true, "Show HTF 1 swing VWAPs", group=groupMtf, tooltip="Up to 5 active VWAPs per HTF. Oldest slot recycled when a 6th anchor appears.")
showHTF2 = input.bool(true, "Show HTF 2 swing VWAPs", group=groupMtf)
showHTF3 = input.bool(false, "Show HTF 3 swing VWAPs", group=groupMtf, tooltip="Optional third HTF (e.g. monthly after daily + weekly). Off by default to limit chart clutter.")
htf1_tf = input.timeframe("D", "HTF 1", group=groupMtf)
htf2_tf = input.timeframe("W", "HTF 2", group=groupMtf)
htf3_tf = input.timeframe("M", "HTF 3", group=groupMtf)
htfDisplayMode = input.string("Ribbon", "HTF display style", options=["Ribbon", "Line"], group=groupMtf, tooltip="Ribbon: filled band around VWAP (no stepped look). Line: stepped line with breaks on na.")
htfRibbonHalfPct = input.float(0.1, "Ribbon half-width (% of price)", minval=0.001, maxval=3.0, step=0.005, group=groupMtf, tooltip="Band = VWAP ± this percent of price.")
htfRibbonFillTrans = input.int(10, "Ribbon fill transparency (0-95)", minval=0, maxval=95, group=groupMtf)
htfTransparency = input.int(10, "HTF line transparency (0-90)", minval=0, maxval=90, group=groupMtf)
htfLineWidth = input.int(4, "HTF line width (Line mode)", minval=1, maxval=4, group=groupMtf)

useHtfRibbon = htfDisplayMode == "Ribbon"

// ---- HTF helpers (same anchored-VWAP logic on HTF series via request.security) ----
f_htf_tf_is_higher(tfStr) =>
    timeframe.in_seconds(tfStr) > timeframe.in_seconds(timeframe.period)

f_na_htf_pack() =>
    [float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na)]

// Mirrors chart TF logic; max 5 HTF slots. HTF drawing uses 2 plot() per slot (+ fill) to stay under TV plot limit 64.
f_htf_swing_vwap_pack() =>
    int maxLinesHTF = 5
    var array<int> h_anchorBars = array.new_int(maxLinesHTF, 0)
    var array<int> h_anchorTimes = array.new_int(maxLinesHTF, 0)
    var array<float> h_cumTPVs = array.new_float(maxLinesHTF, 0.0)
    var array<float> h_cumVols = array.new_float(maxLinesHTF, 0.0)
    var array<int> h_fromHigh = array.new_int(maxLinesHTF, 0)
    var array<int> h_tested = array.new_int(maxLinesHTF, 1)
    var array<int> h_consecBars = array.new_int(maxLinesHTF, 0)
    var int h_lineCount = 0
    // One plot series per internal line slot (0..4). Packed "first N active" caused diagonal bridges when indices shifted.
    var array<float> h_slotV = array.new_float(maxLinesHTF, float(na))
    var array<float> h_slotFH = array.new_float(maxLinesHTF, float(na))

    for k = 0 to maxLinesHTF - 1
        array.set(h_slotV, k, float(na))
        array.set(h_slotFH, k, float(na))

    float swingHigh = ta.pivothigh(high, pivotLen, pivotLen)
    float swingLow = ta.pivotlow(low, pivotLen, pivotLen)
    bool newHighAnchor = not na(swingHigh)
    bool newLowAnchor = not na(swingLow)

    if newHighAnchor and h_lineCount < maxLinesHTF
        int _anchor = bar_index - pivotLen
        int _anchorTime = time[pivotLen]
        float _tp = (high[pivotLen] + low[pivotLen] + close[pivotLen]) / 3.0
        float _vol = math.max(volume[pivotLen], 1e-10)
        float _cumTPV = _tp * _vol
        float _cumVol = _vol
        for _j = 1 to pivotLen - 1
            float _tpj = (high[pivotLen - _j] + low[pivotLen - _j] + close[pivotLen - _j]) / 3.0
            float _volj = math.max(volume[pivotLen - _j], 1e-10)
            _cumTPV := _cumTPV + _tpj * _volj
            _cumVol := _cumVol + _volj
        int _idx = -1
        for i = 0 to maxLinesHTF - 1
            if array.get(h_tested, i) == 1
                _idx := i
                break
        if _idx < 0
            _idx := h_lineCount
            h_lineCount := math.min(h_lineCount + 1, maxLinesHTF)
        if _idx >= 0
            array.set(h_anchorBars, _idx, _anchor)
            array.set(h_anchorTimes, _idx, _anchorTime)
            array.set(h_cumTPVs, _idx, _cumTPV)
            array.set(h_cumVols, _idx, _cumVol)
            array.set(h_fromHigh, _idx, 1)
            array.set(h_tested, _idx, 0)
            array.set(h_consecBars, _idx, 0)

    if newLowAnchor and h_lineCount < maxLinesHTF
        int _anchor = bar_index - pivotLen
        int _anchorTime = time[pivotLen]
        float _tp = (low[pivotLen] + high[pivotLen] + close[pivotLen]) / 3.0
        float _vol = math.max(volume[pivotLen], 1e-10)
        float _cumTPV = _tp * _vol
        float _cumVol = _vol
        for _j = 1 to pivotLen - 1
            float _tpj = (high[pivotLen - _j] + low[pivotLen - _j] + close[pivotLen - _j]) / 3.0
            float _volj = math.max(volume[pivotLen - _j], 1e-10)
            _cumTPV := _cumTPV + _tpj * _volj
            _cumVol := _cumVol + _volj
        int _idx = -1
        for i = 0 to maxLinesHTF - 1
            if array.get(h_tested, i) == 1
                _idx := i
                break
        if _idx < 0
            _idx := h_lineCount
            h_lineCount := math.min(h_lineCount + 1, maxLinesHTF)
        if _idx >= 0
            array.set(h_anchorBars, _idx, _anchor)
            array.set(h_anchorTimes, _idx, _anchorTime)
            array.set(h_cumTPVs, _idx, _cumTPV)
            array.set(h_cumVols, _idx, _cumVol)
            array.set(h_fromHigh, _idx, 0)
            array.set(h_tested, _idx, 0)
            array.set(h_consecBars, _idx, 0)

    for i = 0 to maxLinesHTF - 1
        if array.get(h_tested, i) == 0
            int _anchor = array.get(h_anchorBars, i)
            if bar_index >= _anchor
                float _vol = math.max(volume, 1e-10)
                float _cumTPV = array.get(h_cumTPVs, i) + (high + low + close) / 3.0 * _vol
                float _cumVol = array.get(h_cumVols, i) + _vol
                array.set(h_cumTPVs, i, _cumTPV)
                array.set(h_cumVols, i, _cumVol)
                float _vwap = _cumVol > 0 ? _cumTPV / _cumVol : na
                bool _isHigh = array.get(h_fromHigh, i) == 1
                if not na(_vwap)
                    int _minBarsAfterAnchor = pivotLen + 2
                    bool _closedAbove = close > _vwap
                    bool _closedBelow = close < _vwap
                    bool _onCorrectSide = _isHigh and _closedAbove or not _isHigh and _closedBelow
                    bool _confirmed = false
                    if bar_index > _anchor + _minBarsAfterAnchor
                        if confirmMode == "One bar"
                            _confirmed := _onCorrectSide
                        else
                            int _cnt = _onCorrectSide ? array.get(h_consecBars, i) + 1 : 0
                            array.set(h_consecBars, i, _cnt)
                            _confirmed := _cnt >= confirmBars
                    if _confirmed
                        array.set(h_tested, i, 1)
                    if array.get(h_tested, i) == 0
                        array.set(h_slotV, i, _vwap)
                        array.set(h_slotFH, i, _isHigh ? 1.0 : 0.0)

    float v0 = array.get(h_slotV, 0)
    float v1 = array.get(h_slotV, 1)
    float v2 = array.get(h_slotV, 2)
    float v3 = array.get(h_slotV, 3)
    float v4 = array.get(h_slotV, 4)
    float fh0 = array.get(h_slotFH, 0)
    float fh1 = array.get(h_slotFH, 1)
    float fh2 = array.get(h_slotFH, 2)
    float fh3 = array.get(h_slotFH, 3)
    float fh4 = array.get(h_slotFH, 4)
    float t0 = not na(v0) ? float(array.get(h_anchorTimes, 0)) : float(na)
    float t1 = not na(v1) ? float(array.get(h_anchorTimes, 1)) : float(na)
    float t2 = not na(v2) ? float(array.get(h_anchorTimes, 2)) : float(na)
    float t3 = not na(v3) ? float(array.get(h_anchorTimes, 3)) : float(na)
    float t4 = not na(v4) ? float(array.get(h_anchorTimes, 4)) : float(na)
    [v0, v1, v2, v3, v4, fh0, fh1, fh2, fh3, fh4, t0, t1, t2, t3, t4]

// Ternary cannot return tuples (CE10163); use if/else inside a function.
f_htf1_pack() =>
    if showHTF1 and f_htf_tf_is_higher(htf1_tf)
        request.security(syminfo.tickerid, htf1_tf, f_htf_swing_vwap_pack(), barmerge.gaps_off, barmerge.lookahead_off)
    else
        f_na_htf_pack()

f_htf2_pack() =>
    if showHTF2 and f_htf_tf_is_higher(htf2_tf)
        request.security(syminfo.tickerid, htf2_tf, f_htf_swing_vwap_pack(), barmerge.gaps_off, barmerge.lookahead_off)
    else
        f_na_htf_pack()

f_htf3_pack() =>
    if showHTF3 and f_htf_tf_is_higher(htf3_tf)
        request.security(syminfo.tickerid, htf3_tf, f_htf_swing_vwap_pack(), barmerge.gaps_off, barmerge.lookahead_off)
    else
        f_na_htf_pack()

bool htf1_ok = f_htf_tf_is_higher(htf1_tf)
bool htf2_ok = f_htf_tf_is_higher(htf2_tf)
bool htf3_ok = f_htf_tf_is_higher(htf3_tf)

[htf1_v0, htf1_v1, htf1_v2, htf1_v3, htf1_v4, htf1_fh0, htf1_fh1, htf1_fh2, htf1_fh3, htf1_fh4, htf1_t0, htf1_t1, htf1_t2, htf1_t3, htf1_t4] = f_htf1_pack()

[htf2_v0, htf2_v1, htf2_v2, htf2_v3, htf2_v4, htf2_fh0, htf2_fh1, htf2_fh2, htf2_fh3, htf2_fh4, htf2_t0, htf2_t1, htf2_t2, htf2_t3, htf2_t4] = f_htf2_pack()

[htf3_v0, htf3_v1, htf3_v2, htf3_v3, htf3_v4, htf3_fh0, htf3_fh1, htf3_fh2, htf3_fh3, htf3_fh4, htf3_t0, htf3_t1, htf3_t2, htf3_t3, htf3_t4] = f_htf3_pack()

// ---- Lists ----
maxLines = 100
var array<polyline> polylines = array.new<polyline>()
var array<int> anchorBars = array.new_int(maxLines, 0)
var array<int> anchorTimes = array.new_int(maxLines, 0)
var array<float> cumTPVs = array.new_float(maxLines, 0.0)
var array<float> cumVols = array.new_float(maxLines, 0.0)
var array<int> fromHigh = array.new_int(maxLines, 0)
var array<int> tested = array.new_int(maxLines, 1)
var array<int> consecBars = array.new_int(maxLines, 0)
var int lineCount = 0

rxFeU = -1
rxNoTouchS = -1
var array<int> slotTouched = array.new_int(maxLines, 0)
var array<int> firstTouchBar = array.new_int(maxLines, rxNoTouchS)
var array<int> cohortConsec = array.new_int(maxLines, 0)
var array<bool> kMetInWindow = array.new_bool(maxLines, false)
var array<bool> atrMetInWindow = array.new_bool(maxLines, false)
var array<int> feFirstSwingBar = array.new_int(maxLines, rxFeU)
var array<int> feFirstOppBar = array.new_int(maxLines, rxFeU)
var array<int> feFirstBeyondBar = array.new_int(maxLines, rxFeU)
var array<float> rxSnapVwap = array.new_float(maxLines, na)
var array<int> rxCounts = array.new_int(21, 0)
var array<float> rxSumLife = array.new_float(1, 0.0)
var float lastSwingHighPx = na
var float lastSwingLowPx = na

if barstate.isfirst
    for _ = 0 to maxLines - 1
        array.push(polylines, na)

// ---- Swing high / swing low pivots ----
swingHigh = ta.pivothigh(high, pivotLen, pivotLen)
swingLow  = ta.pivotlow(low, pivotLen, pivotLen)
newHighAnchor = not na(swingHigh)
newLowAnchor  = not na(swingLow)
if not na(swingHigh)
    lastSwingHighPx := swingHigh
if not na(swingLow)
    lastSwingLowPx := swingLow

// ---- Allocate / recycle a line slot for a new anchor ----
if newHighAnchor and lineCount < maxLines
    _anchor = bar_index - pivotLen
    _anchorTime = time[pivotLen]
    _tp = (high[pivotLen] + low[pivotLen] + close[pivotLen]) / 3.0
    _vol = math.max(volume[pivotLen], 1e-10)
    _cumTPV = _tp * _vol
    _cumVol = _vol
    for _j = 1 to pivotLen - 1
        _tpj = (high[pivotLen - _j] + low[pivotLen - _j] + close[pivotLen - _j]) / 3.0
        _volj = math.max(volume[pivotLen - _j], 1e-10)
        _cumTPV := _cumTPV + _tpj * _volj
        _cumVol := _cumVol + _volj
    _idx = -1
    for i = 0 to maxLines - 1
        if array.get(tested, i) == 1
            _idx := i
            break
    if _idx < 0
        _idx := lineCount
        lineCount := math.min(lineCount + 1, maxLines)
    if _idx >= 0
        array.set(anchorBars, _idx, _anchor)
        array.set(anchorTimes, _idx, _anchorTime)
        array.set(cumTPVs, _idx, _cumTPV)
        array.set(cumVols, _idx, _cumVol)
        array.set(fromHigh, _idx, 1)
        array.set(tested, _idx, 0)
        array.set(consecBars, _idx, 0)
        vrx.reset_slot_rx(_idx, slotTouched, firstTouchBar, cohortConsec, kMetInWindow, atrMetInWindow, feFirstSwingBar, feFirstOppBar, feFirstBeyondBar, rxNoTouchS, rxFeU)
        _oldPl = array.get(polylines, _idx)
        if not na(_oldPl)
            polyline.delete(_oldPl)
        array.set(polylines, _idx, na)

if newLowAnchor and lineCount < maxLines
    _anchor = bar_index - pivotLen
    _anchorTime = time[pivotLen]
    _tp = (low[pivotLen] + high[pivotLen] + close[pivotLen]) / 3.0
    _vol = math.max(volume[pivotLen], 1e-10)
    _cumTPV = _tp * _vol
    _cumVol = _vol
    for _j = 1 to pivotLen - 1
        _tpj = (high[pivotLen - _j] + low[pivotLen - _j] + close[pivotLen - _j]) / 3.0
        _volj = math.max(volume[pivotLen - _j], 1e-10)
        _cumTPV := _cumTPV + _tpj * _volj
        _cumVol := _cumVol + _volj
    _idx = -1
    for i = 0 to maxLines - 1
        if array.get(tested, i) == 1
            _idx := i
            break
    if _idx < 0
        _idx := lineCount
        lineCount := math.min(lineCount + 1, maxLines)
    if _idx >= 0
        array.set(anchorBars, _idx, _anchor)
        array.set(anchorTimes, _idx, _anchorTime)
        array.set(cumTPVs, _idx, _cumTPV)
        array.set(cumVols, _idx, _cumVol)
        array.set(fromHigh, _idx, 0)
        array.set(tested, _idx, 0)
        array.set(consecBars, _idx, 0)
        vrx.reset_slot_rx(_idx, slotTouched, firstTouchBar, cohortConsec, kMetInWindow, atrMetInWindow, feFirstSwingBar, feFirstOppBar, feFirstBeyondBar, rxNoTouchS, rxFeU)
        _oldPl = array.get(polylines, _idx)
        if not na(_oldPl)
            polyline.delete(_oldPl)
        array.set(polylines, _idx, na)

// ---- Update VWAP, confirmation, touch detection ----
var bool touchFromLow = false
var bool touchFromHigh = false
touchFromLow := false
touchFromHigh := false

rxAtr = ta.atr(rxAtrLen)

if showRxStatsTable
    vrx.chart_cum_pass(anchorBars, cumTPVs, cumVols, tested, maxLines, bar_index, high, low, close, volume)
    vrx.chart_build_snap(rxSnapVwap, anchorBars, cumTPVs, cumVols, tested, maxLines, bar_index)
    for i = 0 to maxLines - 1
        if array.get(tested, i) == 0
            _anchor = array.get(anchorBars, i)
            if bar_index >= _anchor
                _vwap = array.get(rxSnapVwap, i)
                _isHigh = array.get(fromHigh, i) == 1
                if not na(_vwap)
                    _maxLookback = 10000
                    _nBars = bar_index - _anchor + 1
                    _pts = array.new<chart.point>()
                    if _nBars <= _maxLookback
                        _runTPV = 0.0
                        _runVol = 0.0
                        for _k = 0 to math.min(_nBars - 1, 2000)
                            _offset = bar_index - _anchor - _k
                            _tpk = (high[_offset] + low[_offset] + close[_offset]) / 3.0
                            _volk = math.max(volume[_offset], 1e-10)
                            _runTPV := _runTPV + _tpk * _volk
                            _runVol := _runVol + _volk
                            _vwapk = _runVol > 0 ? _runTPV / _runVol : _tpk
                            array.push(_pts, chart.point.from_index(_anchor + _k, _vwapk))
                    if array.size(_pts) >= 2
                        _clr = _isHigh ? colorFromHigh : colorFromLow
                        _oldPl = array.get(polylines, i)
                        if not na(_oldPl)
                            polyline.delete(_oldPl)
                        _pl = polyline.new(_pts, xloc=xloc.bar_index, line_color=_clr, line_width=lineWidth)
                        array.set(polylines, i, _pl)
                    else if _nBars > _maxLookback
                        _oldPl = array.get(polylines, i)
                        if not na(_oldPl)
                            polyline.delete(_oldPl)
                        array.set(polylines, i, na)
                    _touched = low <= _vwap and high >= _vwap
                    if _touched
                        if _isHigh
                            touchFromHigh := true
                        else
                            touchFromLow := true
                    _closedRx = vrx.chart_slot_rx_close(i, rxSnapVwap, anchorBars, fromHigh, tested, consecBars, slotTouched, firstTouchBar, cohortConsec, kMetInWindow, atrMetInWindow, feFirstSwingBar, feFirstOppBar, feFirstBeyondBar, rxCounts, rxSumLife, bar_index, high, low, close, swingHigh, swingLow, lastSwingHighPx, lastSwingLowPx, pivotLen, confirmMode, confirmBars, kHoldBars, mBarsAfterTouch, rxAtr, atrRMult, mAtrWindow, rxNoTouchS, rxFeU, maxLines)
                    if _closedRx
                        _oldPl2 = array.get(polylines, i)
                        if not na(_oldPl2)
                            polyline.delete(_oldPl2)
                        array.set(polylines, i, na)
else
    for i = 0 to maxLines - 1
        if array.get(tested, i) == 0
            _anchor = array.get(anchorBars, i)
            if bar_index >= _anchor
                _vol = math.max(volume, 1e-10)
                _cumTPV = array.get(cumTPVs, i) + (high + low + close) / 3.0 * _vol
                _cumVol = array.get(cumVols, i) + _vol
                array.set(cumTPVs, i, _cumTPV)
                array.set(cumVols, i, _cumVol)
                _vwap = _cumVol > 0 ? _cumTPV / _cumVol : na
                _isHigh = array.get(fromHigh, i) == 1
                if not na(_vwap)
                    _maxLookback = 10000
                    _nBars = bar_index - _anchor + 1
                    _pts = array.new<chart.point>()
                    if _nBars <= _maxLookback
                        _runTPV = 0.0
                        _runVol = 0.0
                        for _k = 0 to math.min(_nBars - 1, 2000)
                            _offset = bar_index - _anchor - _k
                            _tpk = (high[_offset] + low[_offset] + close[_offset]) / 3.0
                            _volk = math.max(volume[_offset], 1e-10)
                            _runTPV := _runTPV + _tpk * _volk
                            _runVol := _runVol + _volk
                            _vwapk = _runVol > 0 ? _runTPV / _runVol : _tpk
                            array.push(_pts, chart.point.from_index(_anchor + _k, _vwapk))
                    if array.size(_pts) >= 2
                        _clr = _isHigh ? colorFromHigh : colorFromLow
                        _oldPl = array.get(polylines, i)
                        if not na(_oldPl)
                            polyline.delete(_oldPl)
                        _pl = polyline.new(_pts, xloc=xloc.bar_index, line_color=_clr, line_width=lineWidth)
                        array.set(polylines, i, _pl)
                    else if _nBars > _maxLookback
                        _oldPl = array.get(polylines, i)
                        if not na(_oldPl)
                            polyline.delete(_oldPl)
                        array.set(polylines, i, na)
                    _touched = low <= _vwap and high >= _vwap
                    if _touched
                        if _isHigh
                            touchFromHigh := true
                        else
                            touchFromLow := true
                    _minBarsAfterAnchor = pivotLen + 2
                    _closedAbove = close > _vwap
                    _closedBelow = close < _vwap
                    _onCorrectSide = _isHigh and _closedAbove or not _isHigh and _closedBelow
                    _confirmed = false
                    if bar_index > _anchor + _minBarsAfterAnchor
                        if confirmMode == "One bar"
                            _confirmed := _onCorrectSide
                        else
                            _cnt = _onCorrectSide ? array.get(consecBars, i) + 1 : 0
                            array.set(consecBars, i, _cnt)
                            _confirmed := _cnt >= confirmBars
                    if _confirmed
                        array.set(tested, i, 1)
                        _oldPl = array.get(polylines, i)
                        if not na(_oldPl)
                            polyline.delete(_oldPl)
                        array.set(polylines, i, na)

// ---- Stats table (chart TF, last bar) ----
nSupTouchBreak = array.get(rxCounts, 0)
nSupTouchBounce = array.get(rxCounts, 1)
nSupNoTouch = array.get(rxCounts, 2)
nResTouchBreak = array.get(rxCounts, 3)
nResTouchBounce = array.get(rxCounts, 4)
nResNoTouch = array.get(rxCounts, 5)
nSupAtrBreak = array.get(rxCounts, 6)
nSupAtrBounce = array.get(rxCounts, 7)
nResAtrBreak = array.get(rxCounts, 8)
nResAtrBounce = array.get(rxCounts, 9)
nSupMgSwing = array.get(rxCounts, 10)
nSupMgOpp = array.get(rxCounts, 11)
nSupMgBeyond = array.get(rxCounts, 12)
nSupMgAny = array.get(rxCounts, 13)
nSupMgNone = array.get(rxCounts, 14)
nResMgSwing = array.get(rxCounts, 15)
nResMgOpp = array.get(rxCounts, 16)
nResMgBeyond = array.get(rxCounts, 17)
nResMgAny = array.get(rxCounts, 18)
nResMgNone = array.get(rxCounts, 19)
nCompleted = array.get(rxCounts, 20)
sumLife = array.get(rxSumLife, 0)
supCohort = nSupTouchBreak + nSupTouchBounce
resCohort = nResTouchBreak + nResTouchBounce
nTouchAll = supCohort + resCohort
nNoTouchAll = nSupNoTouch + nResNoTouch
pctKmBounceSup = supCohort > 0 ? 100.0 * nSupTouchBounce / supCohort : na
pctKmBreakSup = supCohort > 0 ? 100.0 * nSupTouchBreak / supCohort : na
pctKmBounceRes = resCohort > 0 ? 100.0 * nResTouchBounce / resCohort : na
pctKmBreakRes = resCohort > 0 ? 100.0 * nResTouchBreak / resCohort : na
pctAtrBounceSup = supCohort > 0 ? 100.0 * nSupAtrBounce / supCohort : na
pctAtrBreakSup = supCohort > 0 ? 100.0 * nSupAtrBreak / supCohort : na
pctAtrBounceRes = resCohort > 0 ? 100.0 * nResAtrBounce / resCohort : na
pctAtrBreakRes = resCohort > 0 ? 100.0 * nResAtrBreak / resCohort : na
pctFeMgAnySup = supCohort > 0 ? 100.0 * nSupMgAny / supCohort : na
pctFeMgAnyRes = resCohort > 0 ? 100.0 * nResMgAny / resCohort : na
pctFeMgSwingSup = supCohort > 0 ? 100.0 * nSupMgSwing / supCohort : na
pctFeMgOppSup = supCohort > 0 ? 100.0 * nSupMgOpp / supCohort : na
pctFeMgBeyondSup = supCohort > 0 ? 100.0 * nSupMgBeyond / supCohort : na
pctFeMgNoneSup = supCohort > 0 ? 100.0 * nSupMgNone / supCohort : na
pctFeMgSwingRes = resCohort > 0 ? 100.0 * nResMgSwing / resCohort : na
pctFeMgOppRes = resCohort > 0 ? 100.0 * nResMgOpp / resCohort : na
pctFeMgBeyondRes = resCohort > 0 ? 100.0 * nResMgBeyond / resCohort : na
pctFeMgNoneRes = resCohort > 0 ? 100.0 * nResMgNone / resCohort : na
nAllMgSwing = nSupMgSwing + nResMgSwing
nAllMgOpp = nSupMgOpp + nResMgOpp
nAllMgBeyond = nSupMgBeyond + nResMgBeyond
nAllMgAny = nSupMgAny + nResMgAny
nAllMgNone = nSupMgNone + nResMgNone
pctFeMgAnyAll = nTouchAll > 0 ? 100.0 * nAllMgAny / nTouchAll : na
pctFeMgSwingAll = nTouchAll > 0 ? 100.0 * nAllMgSwing / nTouchAll : na
pctFeMgOppAll = nTouchAll > 0 ? 100.0 * nAllMgOpp / nTouchAll : na
pctFeMgBeyondAll = nTouchAll > 0 ? 100.0 * nAllMgBeyond / nTouchAll : na
pctFeMgNoneAll = nTouchAll > 0 ? 100.0 * nAllMgNone / nTouchAll : na
avgLife = nCompleted > 0 ? sumLife / nCompleted : na
supLinesAll = supCohort + nSupNoTouch
resLinesAll = resCohort + nResNoTouch
pctNoTouchSup = supLinesAll > 0 ? 100.0 * nSupNoTouch / supLinesAll : na
pctNoTouchRes = resLinesAll > 0 ? 100.0 * nResNoTouch / resLinesAll : na
pctNoTouchAll = nCompleted > 0 ? 100.0 * nNoTouchAll / nCompleted : na
pos = tablePos == "top_left" ? position.top_left : tablePos == "top_center" ? position.top_center : tablePos == "top_right" ? position.top_right : tablePos == "middle_left" ? position.middle_left : tablePos == "middle_center" ? position.middle_center : tablePos == "middle_right" ? position.middle_right : tablePos == "bottom_left" ? position.bottom_left : tablePos == "bottom_center" ? position.bottom_center : position.bottom_right
tSize = txtSize == "tiny" ? size.tiny : txtSize == "small" ? size.small : txtSize == "normal" ? size.normal : size.large
var table rxTbl = table.new(pos, 4, 14, border_width=1)
if showRxStatsTable and barstate.islast
    table.cell(rxTbl, 0, 0, "TF", text_color=chart.fg_color, bgcolor=rxTblHdrBg, text_size=tSize)
    table.cell(rxTbl, 1, 0, "Support", text_color=chart.fg_color, bgcolor=rxTblHdrBg, text_size=tSize)
    table.cell(rxTbl, 2, 0, "Resistance", text_color=chart.fg_color, bgcolor=rxTblHdrBg, text_size=tSize)
    table.cell(rxTbl, 3, 0, "All", text_color=chart.fg_color, bgcolor=rxTblHdrBg, text_size=tSize)
    table.cell(rxTbl, 0, 1, timeframe.period, text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 1, 1, "n=" + str.tostring(supCohort), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 1, "n=" + str.tostring(resCohort), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 1, str.tostring(nCompleted) + " lines", text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 0, 2, "No-touch", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 2, str.tostring(nSupNoTouch) + (na(pctNoTouchSup) ? "" : " (" + str.tostring(pctNoTouchSup, "#.#") + "%)"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 2, str.tostring(nResNoTouch) + (na(pctNoTouchRes) ? "" : " (" + str.tostring(pctNoTouchRes, "#.#") + "%)"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 2, str.tostring(nNoTouchAll) + (na(pctNoTouchAll) ? "" : " (" + str.tostring(pctNoTouchAll, "#.#") + "%)"), text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 0, 3, "K/M b%", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 3, na(pctKmBounceSup) ? "—" : str.tostring(pctKmBounceSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 3, na(pctKmBounceRes) ? "—" : str.tostring(pctKmBounceRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 3, " ", text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 0, 4, "K/M br%", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 4, na(pctKmBreakSup) ? "—" : str.tostring(pctKmBreakSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 4, na(pctKmBreakRes) ? "—" : str.tostring(pctKmBreakRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 4, str.tostring(kHoldBars) + "/" + str.tostring(mBarsAfterTouch), text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 0, 5, "ATR b%", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 5, na(pctAtrBounceSup) ? "—" : str.tostring(pctAtrBounceSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 5, na(pctAtrBounceRes) ? "—" : str.tostring(pctAtrBounceRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 5, " ", text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 0, 6, "ATR br%", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 6, na(pctAtrBreakSup) ? "—" : str.tostring(pctAtrBreakSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 6, na(pctAtrBreakRes) ? "—" : str.tostring(pctAtrBreakRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 6, str.tostring(rxAtrLen) + "/" + str.tostring(atrRMult, "#.#") + "/M" + str.tostring(mAtrWindow), text_color=chart.fg_color, bgcolor=rxTblPlainBg, text_size=tSize)
    table.cell(rxTbl, 0, 7, "FE P(≥1)", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 7, na(pctFeMgAnySup) ? "—" : str.tostring(pctFeMgAnySup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 7, na(pctFeMgAnyRes) ? "—" : str.tostring(pctFeMgAnyRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 7, na(pctFeMgAnyAll) ? "—" : str.tostring(pctFeMgAnyAll, "#.#"), text_color=chart.fg_color, bgcolor=rxTblAllBg, text_size=tSize)
    table.cell(rxTbl, 0, 8, "FE P(swing)", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 8, na(pctFeMgSwingSup) ? "—" : str.tostring(pctFeMgSwingSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 8, na(pctFeMgSwingRes) ? "—" : str.tostring(pctFeMgSwingRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 8, na(pctFeMgSwingAll) ? "—" : str.tostring(pctFeMgSwingAll, "#.#"), text_color=chart.fg_color, bgcolor=rxTblAllBg, text_size=tSize)
    table.cell(rxTbl, 0, 9, "FE P(opp)", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 9, na(pctFeMgOppSup) ? "—" : str.tostring(pctFeMgOppSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 9, na(pctFeMgOppRes) ? "—" : str.tostring(pctFeMgOppRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 9, na(pctFeMgOppAll) ? "—" : str.tostring(pctFeMgOppAll, "#.#"), text_color=chart.fg_color, bgcolor=rxTblAllBg, text_size=tSize)
    table.cell(rxTbl, 0, 10, "FE P(cls)", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 10, na(pctFeMgBeyondSup) ? "—" : str.tostring(pctFeMgBeyondSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 10, na(pctFeMgBeyondRes) ? "—" : str.tostring(pctFeMgBeyondRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 10, na(pctFeMgBeyondAll) ? "—" : str.tostring(pctFeMgBeyondAll, "#.#"), text_color=chart.fg_color, bgcolor=rxTblAllBg, text_size=tSize)
    table.cell(rxTbl, 0, 11, "FE P(none)", bgcolor=rxTblHdrBg, text_color=chart.fg_color, text_size=tSize)
    table.cell(rxTbl, 1, 11, na(pctFeMgNoneSup) ? "—" : str.tostring(pctFeMgNoneSup, "#.#"), text_color=chart.fg_color, bgcolor=rxTblSupBg, text_size=tSize)
    table.cell(rxTbl, 2, 11, na(pctFeMgNoneRes) ? "—" : str.tostring(pctFeMgNoneRes, "#.#"), text_color=chart.fg_color, bgcolor=rxTblResBg, text_size=tSize)
    table.cell(rxTbl, 3, 11, na(pctFeMgNoneAll) ? "—" : str.tostring(pctFeMgNoneAll, "#.#"), text_color=chart.fg_color, bgcolor=rxTblAllBg, text_size=tSize)
    table.cell(rxTbl, 0, 12, "Avg life", bgcolor=rxTblFooterBg, text_color=chart.fg_color, text_size=tSize)
    table.merge_cells(rxTbl, 1, 12, 3, 12)
    table.cell(rxTbl, 1, 12, na(avgLife) ? "—" : str.tostring(avgLife, "#.##"), bgcolor=rxTblFooterBg, text_color=chart.fg_color, text_size=tSize)

// ---- HTF midline vs chart bar (for alerts) ----
var array<float> htf1TouchP = array.new_float()
var array<int> htf1TouchFh = array.new_int()
var array<int> htf1TouchAt = array.new_int()
var array<float> htf2TouchP = array.new_float()
var array<int> htf2TouchFh = array.new_int()
var array<int> htf2TouchAt = array.new_int()
var array<float> htf3TouchP = array.new_float()
var array<int> htf3TouchFh = array.new_int()
var array<int> htf3TouchAt = array.new_int()

array.clear(htf1TouchP)
array.clear(htf1TouchFh)
array.clear(htf1TouchAt)
array.clear(htf2TouchP)
array.clear(htf2TouchFh)
array.clear(htf2TouchAt)
array.clear(htf3TouchP)
array.clear(htf3TouchFh)
array.clear(htf3TouchAt)

f_pub_htf_slot(bool want, bool showTf, bool tfOk, float v, float fhFlag, float anchF) =>
    if want and showTf and tfOk and not na(v) and low <= v and high >= v
        float atf = not na(anchF) and anchF > 0 ? anchF : 0.0
        [1.0, fhFlag, atf]
    else
        [0.0, 0.0, 0.0]

[pub1x0, pub1f0, pub1a0] = f_pub_htf_slot(alertHTF1, showHTF1, htf1_ok, htf1_v0, htf1_fh0, htf1_t0)
if pub1x0 > 0.5
    array.push(htf1TouchP, htf1_v0)
    array.push(htf1TouchFh, int(pub1f0))
    array.push(htf1TouchAt, int(math.round(pub1a0)))
[pub1x1, pub1f1, pub1a1] = f_pub_htf_slot(alertHTF1, showHTF1, htf1_ok, htf1_v1, htf1_fh1, htf1_t1)
if pub1x1 > 0.5
    array.push(htf1TouchP, htf1_v1)
    array.push(htf1TouchFh, int(pub1f1))
    array.push(htf1TouchAt, int(math.round(pub1a1)))
[pub1x2, pub1f2, pub1a2] = f_pub_htf_slot(alertHTF1, showHTF1, htf1_ok, htf1_v2, htf1_fh2, htf1_t2)
if pub1x2 > 0.5
    array.push(htf1TouchP, htf1_v2)
    array.push(htf1TouchFh, int(pub1f2))
    array.push(htf1TouchAt, int(math.round(pub1a2)))
[pub1x3, pub1f3, pub1a3] = f_pub_htf_slot(alertHTF1, showHTF1, htf1_ok, htf1_v3, htf1_fh3, htf1_t3)
if pub1x3 > 0.5
    array.push(htf1TouchP, htf1_v3)
    array.push(htf1TouchFh, int(pub1f3))
    array.push(htf1TouchAt, int(math.round(pub1a3)))
[pub1x4, pub1f4, pub1a4] = f_pub_htf_slot(alertHTF1, showHTF1, htf1_ok, htf1_v4, htf1_fh4, htf1_t4)
if pub1x4 > 0.5
    array.push(htf1TouchP, htf1_v4)
    array.push(htf1TouchFh, int(pub1f4))
    array.push(htf1TouchAt, int(math.round(pub1a4)))

[pub2x0, pub2f0, pub2a0] = f_pub_htf_slot(alertHTF2, showHTF2, htf2_ok, htf2_v0, htf2_fh0, htf2_t0)
if pub2x0 > 0.5
    array.push(htf2TouchP, htf2_v0)
    array.push(htf2TouchFh, int(pub2f0))
    array.push(htf2TouchAt, int(math.round(pub2a0)))
[pub2x1, pub2f1, pub2a1] = f_pub_htf_slot(alertHTF2, showHTF2, htf2_ok, htf2_v1, htf2_fh1, htf2_t1)
if pub2x1 > 0.5
    array.push(htf2TouchP, htf2_v1)
    array.push(htf2TouchFh, int(pub2f1))
    array.push(htf2TouchAt, int(math.round(pub2a1)))
[pub2x2, pub2f2, pub2a2] = f_pub_htf_slot(alertHTF2, showHTF2, htf2_ok, htf2_v2, htf2_fh2, htf2_t2)
if pub2x2 > 0.5
    array.push(htf2TouchP, htf2_v2)
    array.push(htf2TouchFh, int(pub2f2))
    array.push(htf2TouchAt, int(math.round(pub2a2)))
[pub2x3, pub2f3, pub2a3] = f_pub_htf_slot(alertHTF2, showHTF2, htf2_ok, htf2_v3, htf2_fh3, htf2_t3)
if pub2x3 > 0.5
    array.push(htf2TouchP, htf2_v3)
    array.push(htf2TouchFh, int(pub2f3))
    array.push(htf2TouchAt, int(math.round(pub2a3)))
[pub2x4, pub2f4, pub2a4] = f_pub_htf_slot(alertHTF2, showHTF2, htf2_ok, htf2_v4, htf2_fh4, htf2_t4)
if pub2x4 > 0.5
    array.push(htf2TouchP, htf2_v4)
    array.push(htf2TouchFh, int(pub2f4))
    array.push(htf2TouchAt, int(math.round(pub2a4)))

[pub3x0, pub3f0, pub3a0] = f_pub_htf_slot(alertHTF3, showHTF3, htf3_ok, htf3_v0, htf3_fh0, htf3_t0)
if pub3x0 > 0.5
    array.push(htf3TouchP, htf3_v0)
    array.push(htf3TouchFh, int(pub3f0))
    array.push(htf3TouchAt, int(math.round(pub3a0)))
[pub3x1, pub3f1, pub3a1] = f_pub_htf_slot(alertHTF3, showHTF3, htf3_ok, htf3_v1, htf3_fh1, htf3_t1)
if pub3x1 > 0.5
    array.push(htf3TouchP, htf3_v1)
    array.push(htf3TouchFh, int(pub3f1))
    array.push(htf3TouchAt, int(math.round(pub3a1)))
[pub3x2, pub3f2, pub3a2] = f_pub_htf_slot(alertHTF3, showHTF3, htf3_ok, htf3_v2, htf3_fh2, htf3_t2)
if pub3x2 > 0.5
    array.push(htf3TouchP, htf3_v2)
    array.push(htf3TouchFh, int(pub3f2))
    array.push(htf3TouchAt, int(math.round(pub3a2)))
[pub3x3, pub3f3, pub3a3] = f_pub_htf_slot(alertHTF3, showHTF3, htf3_ok, htf3_v3, htf3_fh3, htf3_t3)
if pub3x3 > 0.5
    array.push(htf3TouchP, htf3_v3)
    array.push(htf3TouchFh, int(pub3f3))
    array.push(htf3TouchAt, int(math.round(pub3a3)))
[pub3x4, pub3f4, pub3a4] = f_pub_htf_slot(alertHTF3, showHTF3, htf3_ok, htf3_v4, htf3_fh4, htf3_t4)
if pub3x4 > 0.5
    array.push(htf3TouchP, htf3_v4)
    array.push(htf3TouchFh, int(pub3f4))
    array.push(htf3TouchAt, int(math.round(pub3a4)))

fnPubFmt(int _t) =>
    str.format("{0,date,dd.MM.yyyy HH:mm}", _t)

fnPubHtfMsg(string htfLab, string tfStr, array<float> ps, array<int> fhs, array<int> ats) =>
    _msg = "HTF VWAP touch | " + syminfo.ticker + " | " + htfLab + " (" + tfStr + ") | Close: " + str.tostring(close, format.mintick) + " | Bar: " + fnPubFmt(time)
    _n = array.size(ps)
    if _n > 0
        _msg := _msg + "\n--- Touched ---"
        for j = 0 to _n - 1
            _type = array.get(fhs, j) == 1 ? "Resistance" : "Support"
            _at = array.get(ats, j)
            _msg := _msg + "\n" + _type + ": " + str.tostring(array.get(ps, j), format.mintick) + (_at > 0 ? " | Anchor: " + fnPubFmt(_at) : "")
    _msg

// ---- Alerts: chart + optional HTF ----
_pubAlertFreq = alertFreq == "Once per bar" ? alert.freq_once_per_bar : alertFreq == "All ticks" ? alert.freq_all : alert.freq_once_per_bar_close

anyChartTouch = touchFromLow or touchFromHigh
if alertChartTF and anyChartTouch
    alert("Chart VWAP touch | " + syminfo.ticker + " | Price: " + str.tostring(close, format.mintick) + " | Time: " + fnPubFmt(time), _pubAlertFreq)

if alertHTF1 and array.size(htf1TouchP) > 0
    alert(fnPubHtfMsg("HTF1", htf1_tf, htf1TouchP, htf1TouchFh, htf1TouchAt), _pubAlertFreq)

if alertHTF2 and array.size(htf2TouchP) > 0
    alert(fnPubHtfMsg("HTF2", htf2_tf, htf2TouchP, htf2TouchFh, htf2TouchAt), _pubAlertFreq)

if alertHTF3 and array.size(htf3TouchP) > 0
    alert(fnPubHtfMsg("HTF3", htf3_tf, htf3TouchP, htf3TouchFh, htf3TouchAt), _pubAlertFreq)

// ---- HTF visuals: fixed slot per index; Ribbon = fill between VWAP ± %; Line = stepped segments ----
f_htf_plot_color(float fhFlag, color cHi, color cLo) =>
    fhFlag == 1.0 ? color.new(cHi, htfTransparency) : color.new(cLo, htfTransparency)

f_htf_ribbon_half(float v, float halfPct) =>
    not na(v) ? v * halfPct / 100.0 : float(na)

f_htf_ribbon_fill_col(float fhFlag, color cHi, color cLo, int transp) =>
    fhFlag == 1.0 ? color.new(cHi, transp) : color.new(cLo, transp)

// Line mode: upper plot = VWAP (lower plot na). Ribbon: both edges + fill. Avoids a third plot() per slot (RE10140).
f_htf_slot_hi(bool on, bool ok, float v) =>
    on and ok and not na(v) ? (useHtfRibbon ? v + f_htf_ribbon_half(v, htfRibbonHalfPct) : v) : na

f_htf_slot_lo(bool on, bool ok, float v) =>
    on and ok and not na(v) ? (useHtfRibbon ? v - f_htf_ribbon_half(v, htfRibbonHalfPct) : na) : na

_htfFillT = useHtfRibbon ? htfRibbonFillTrans : 100

// HTF 1
ph1_0 = plot(f_htf_slot_hi(showHTF1, htf1_ok, htf1_v0), title="HTF1 VWAP 0", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf1_fh0, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl1_0 = plot(f_htf_slot_lo(showHTF1, htf1_ok, htf1_v0), title="", display=display.none, editable=false)
fill(ph1_0, pl1_0, color=useHtfRibbon and showHTF1 and htf1_ok and not na(htf1_v0) ? f_htf_ribbon_fill_col(htf1_fh0, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF1 band 0")

ph1_1 = plot(f_htf_slot_hi(showHTF1, htf1_ok, htf1_v1), title="HTF1 VWAP 1", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf1_fh1, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl1_1 = plot(f_htf_slot_lo(showHTF1, htf1_ok, htf1_v1), title="", display=display.none, editable=false)
fill(ph1_1, pl1_1, color=useHtfRibbon and showHTF1 and htf1_ok and not na(htf1_v1) ? f_htf_ribbon_fill_col(htf1_fh1, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF1 band 1")

ph1_2 = plot(f_htf_slot_hi(showHTF1, htf1_ok, htf1_v2), title="HTF1 VWAP 2", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf1_fh2, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl1_2 = plot(f_htf_slot_lo(showHTF1, htf1_ok, htf1_v2), title="", display=display.none, editable=false)
fill(ph1_2, pl1_2, color=useHtfRibbon and showHTF1 and htf1_ok and not na(htf1_v2) ? f_htf_ribbon_fill_col(htf1_fh2, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF1 band 2")

ph1_3 = plot(f_htf_slot_hi(showHTF1, htf1_ok, htf1_v3), title="HTF1 VWAP 3", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf1_fh3, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl1_3 = plot(f_htf_slot_lo(showHTF1, htf1_ok, htf1_v3), title="", display=display.none, editable=false)
fill(ph1_3, pl1_3, color=useHtfRibbon and showHTF1 and htf1_ok and not na(htf1_v3) ? f_htf_ribbon_fill_col(htf1_fh3, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF1 band 3")

ph1_4 = plot(f_htf_slot_hi(showHTF1, htf1_ok, htf1_v4), title="HTF1 VWAP 4", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf1_fh4, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl1_4 = plot(f_htf_slot_lo(showHTF1, htf1_ok, htf1_v4), title="", display=display.none, editable=false)
fill(ph1_4, pl1_4, color=useHtfRibbon and showHTF1 and htf1_ok and not na(htf1_v4) ? f_htf_ribbon_fill_col(htf1_fh4, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF1 band 4")

// HTF 2
ph2_0 = plot(f_htf_slot_hi(showHTF2, htf2_ok, htf2_v0), title="HTF2 VWAP 0", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf2_fh0, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl2_0 = plot(f_htf_slot_lo(showHTF2, htf2_ok, htf2_v0), title="", display=display.none, editable=false)
fill(ph2_0, pl2_0, color=useHtfRibbon and showHTF2 and htf2_ok and not na(htf2_v0) ? f_htf_ribbon_fill_col(htf2_fh0, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF2 band 0")

ph2_1 = plot(f_htf_slot_hi(showHTF2, htf2_ok, htf2_v1), title="HTF2 VWAP 1", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf2_fh1, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl2_1 = plot(f_htf_slot_lo(showHTF2, htf2_ok, htf2_v1), title="", display=display.none, editable=false)
fill(ph2_1, pl2_1, color=useHtfRibbon and showHTF2 and htf2_ok and not na(htf2_v1) ? f_htf_ribbon_fill_col(htf2_fh1, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF2 band 1")

ph2_2 = plot(f_htf_slot_hi(showHTF2, htf2_ok, htf2_v2), title="HTF2 VWAP 2", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf2_fh2, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl2_2 = plot(f_htf_slot_lo(showHTF2, htf2_ok, htf2_v2), title="", display=display.none, editable=false)
fill(ph2_2, pl2_2, color=useHtfRibbon and showHTF2 and htf2_ok and not na(htf2_v2) ? f_htf_ribbon_fill_col(htf2_fh2, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF2 band 2")

ph2_3 = plot(f_htf_slot_hi(showHTF2, htf2_ok, htf2_v3), title="HTF2 VWAP 3", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf2_fh3, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl2_3 = plot(f_htf_slot_lo(showHTF2, htf2_ok, htf2_v3), title="", display=display.none, editable=false)
fill(ph2_3, pl2_3, color=useHtfRibbon and showHTF2 and htf2_ok and not na(htf2_v3) ? f_htf_ribbon_fill_col(htf2_fh3, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF2 band 3")

ph2_4 = plot(f_htf_slot_hi(showHTF2, htf2_ok, htf2_v4), title="HTF2 VWAP 4", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf2_fh4, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl2_4 = plot(f_htf_slot_lo(showHTF2, htf2_ok, htf2_v4), title="", display=display.none, editable=false)
fill(ph2_4, pl2_4, color=useHtfRibbon and showHTF2 and htf2_ok and not na(htf2_v4) ? f_htf_ribbon_fill_col(htf2_fh4, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF2 band 4")

// HTF 3
ph3_0 = plot(f_htf_slot_hi(showHTF3, htf3_ok, htf3_v0), title="HTF3 VWAP 0", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf3_fh0, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl3_0 = plot(f_htf_slot_lo(showHTF3, htf3_ok, htf3_v0), title="", display=display.none, editable=false)
fill(ph3_0, pl3_0, color=useHtfRibbon and showHTF3 and htf3_ok and not na(htf3_v0) ? f_htf_ribbon_fill_col(htf3_fh0, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF3 band 0")

ph3_1 = plot(f_htf_slot_hi(showHTF3, htf3_ok, htf3_v1), title="HTF3 VWAP 1", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf3_fh1, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl3_1 = plot(f_htf_slot_lo(showHTF3, htf3_ok, htf3_v1), title="", display=display.none, editable=false)
fill(ph3_1, pl3_1, color=useHtfRibbon and showHTF3 and htf3_ok and not na(htf3_v1) ? f_htf_ribbon_fill_col(htf3_fh1, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF3 band 1")

ph3_2 = plot(f_htf_slot_hi(showHTF3, htf3_ok, htf3_v2), title="HTF3 VWAP 2", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf3_fh2, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl3_2 = plot(f_htf_slot_lo(showHTF3, htf3_ok, htf3_v2), title="", display=display.none, editable=false)
fill(ph3_2, pl3_2, color=useHtfRibbon and showHTF3 and htf3_ok and not na(htf3_v2) ? f_htf_ribbon_fill_col(htf3_fh2, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF3 band 2")

ph3_3 = plot(f_htf_slot_hi(showHTF3, htf3_ok, htf3_v3), title="HTF3 VWAP 3", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf3_fh3, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl3_3 = plot(f_htf_slot_lo(showHTF3, htf3_ok, htf3_v3), title="", display=display.none, editable=false)
fill(ph3_3, pl3_3, color=useHtfRibbon and showHTF3 and htf3_ok and not na(htf3_v3) ? f_htf_ribbon_fill_col(htf3_fh3, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF3 band 3")

ph3_4 = plot(f_htf_slot_hi(showHTF3, htf3_ok, htf3_v4), title="HTF3 VWAP 4", display=useHtfRibbon ? display.none : display.all, color=useHtfRibbon ? color.new(color.white, 100) : f_htf_plot_color(htf3_fh4, colorFromHigh, colorFromLow), linewidth=useHtfRibbon ? 1 : htfLineWidth, style=useHtfRibbon ? plot.style_line : plot.style_linebr)
pl3_4 = plot(f_htf_slot_lo(showHTF3, htf3_ok, htf3_v4), title="", display=display.none, editable=false)
fill(ph3_4, pl3_4, color=useHtfRibbon and showHTF3 and htf3_ok and not na(htf3_v4) ? f_htf_ribbon_fill_col(htf3_fh4, colorFromHigh, colorFromLow, _htfFillT) : na, title="HTF3 band 4")

// ---- Touch markers (chart TF) ----
plotshape(showTouchMarkers and touchFromLow, style=shape.circle, location=location.belowbar, color=colorFromLow, size=size.tiny, title="Touch Support")
plotshape(showTouchMarkers and touchFromHigh, style=shape.circle, location=location.abovebar, color=colorFromHigh, size=size.tiny, title="Touch Resistance")
````
