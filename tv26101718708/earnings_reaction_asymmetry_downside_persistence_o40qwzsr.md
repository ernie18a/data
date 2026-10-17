# Earnings Reaction Asymmetry  & Downside Persistence

- url: https://www.tradingview.com/script/o40qWZSR-Earnings-Reaction-Asymmetry-Downside-Persistence/
- type: indicator
- pine_id: PUB;1812d92c731e49849e5d0ae103c6bd0f
- version: 1.0

## Description

# Earnings Reaction Asymmetry | Relative Risk & Downside Persistence

## Overview

Earnings announcements can produce unusually large price movements. However, the magnitude of an earnings reaction alone does not establish whether that movement is exceptional for a particular stock.

A 3% decline may be significant for a relatively stable company, while the same decline may represent ordinary daily variation for a more volatile stock.

**Earnings Reaction Asymmetry** addresses this distinction by comparing historical earnings-related price movements against randomly sampled, non-earnings trading sessions from the same stock and nearby time periods.

The indicator evaluates three key characteristics:

1. **Downside amplification (A_down):** How much the stock's average downside contribution increases or decreases around earnings compared with ordinary trading sessions.
2. **Upside amplification (A_up):** How much its average upside contribution increases or decreases around earnings compared with ordinary trading sessions.
3. **Downside persistence:** How historical downside amplification is estimated to decline toward normal trading conditions over subsequent sessions.

The objective is not to predict the direction of an upcoming earnings announcement, but to characterize a stock's historical earnings-related risk relative to its own ordinary price behavior.

## 1. Volatility-Normalized Earnings Reactions

To compare stocks with different volatility characteristics, daily price returns are normalized using a trailing 252-session average of True Range expressed relative to the previous closing price.

**Formula:**

Rnorm(t) = [(Close(t) / Close(t-1)) - 1] / LT252(t-1)

Where:

- Rnorm = volatility-normalized daily return.
- LT252 = 252-session average of True Range / previous Close.
- LT252(t-1) = the normalization baseline established before the reaction session.

This measures price movements relative to the stock's established trading range rather than treating all percentage returns as equivalent.

A normalized return of -2.0, for example, represents a decline equal to approximately twice the historical daily relative True Range baseline.

## 2. Matched Non-Earnings Controls

For each historical earnings event, the indicator selects ordinary trading sessions from a configurable nearby time window.

These controls provide a reference distribution of price movements that occurred without an earnings announcement.

Default methodology:

- Control selection window: ±30 trading sessions around the event.
- Earnings exclusion window: ±5 trading sessions.
- Random controls per earnings event: 10.
- Sampling without replacement within each event.
- Deterministic sampling based on ticker, earnings reaction date, and user-defined seed.

Each earnings event is compared against its own matched collection of ordinary sessions.

This approach helps account for differences in volatility and market environment across historical periods.

The fixed random seed makes the selection reproducible under identical data and settings. Users can also change the seed to examine how sensitive the results are to the sampled controls.

## 3. Earnings Downside Amplification (A_down)

The downside measure compares the average negative contribution from earnings reactions with that of ordinary trading sessions.

**Formula:**

A_down = Mean[max(-Rnorm_earnings, 0)] / Mean[max(-Rnorm_controls, 0)]

The means include zero contributions from sessions without a negative return.

**Interpretation:**

- A_down = 1.0: Earnings downside is comparable to ordinary-session downside.
- A_down = 2.0: Earnings downside contribution is twice the ordinary-session baseline.
- A_down = 3.0: Earnings downside contribution is three times the baseline.
- A_down < 1.0: Earnings downside contribution is smaller than the baseline.

For example, if A_down = 3.5, the stock's historical earnings-related downside contribution averaged 3.5 times that of its matched non-earnings sessions.

This captures both the frequency and magnitude of negative movements, rather than measuring only the size of losses on declining sessions.

## 4. Earnings Upside Amplification (A_up)

The same methodology is applied to positive earnings reactions.

**Formula:**

A_up = Mean[max(Rnorm_earnings, 0)] / Mean[max(Rnorm_controls, 0)]

**Interpretation:**

- A_up = 1.0: Earnings upside is comparable to ordinary-session upside.
- A_up = 2.0: Earnings upside contribution is twice the ordinary-session baseline.
- A_up = 3.0: Earnings upside contribution is three times the baseline.
- A_up < 1.0: Earnings upside contribution is smaller than the baseline.

Calculating upside and downside independently avoids assuming that a stock with unusually large earnings movements has symmetrical risk in both directions.

## 5. Earnings Reaction Asymmetry (LA)

The indicator combines both amplification measures into a logarithmic asymmetry score.

**Formula:**

LA = ln(A_up / A_down)

**Interpretation:**

- LA > 0: Relative upside amplification exceeds downside amplification.
- LA = 0: Upside and downside amplification are equal.
- LA < 0: Relative downside amplification exceeds upside amplification.

**Example:**

A_up = 4.0

A_down = 2.0

LA = ln(4.0 / 2.0) = 0.693

This indicates that earnings-related upside amplification is twice the downside amplification.

Importantly, a positive LA does not mean that earnings are necessarily bullish or that downside risk is absent. It describes the relative balance between two independently calculated amplification measures.

## 6. Historical Downside Persistence Model

An additional research component estimates how elevated downside amplification may diminish over subsequent trading sessions.

The model uses a stretched-exponential decay function calibrated using historical downside-amplification groups.

**Formula:**

A_down_model(H) = 1 + max(A_down - 1, 0) × exp(-((H - 1) / tau)^k)

Where:

- H = number of trading sessions, from Day 1 through Day 21.
- A_down = initial historical downside amplification.
- tau = quintile-specific decay timescale.
- k = quintile-specific decay shape parameter.
- exp = exponential function.

Stocks are assigned to one of five fixed downside-amplification groups using A_down.

Each group has its own calibrated tau and k parameters.

The indicator evaluates the model at:

- Day 5
- Day 10
- Day 21

A higher modeled value indicates that downside amplification remains further above the ordinary-session reference level.

The model describes the estimated persistence of **relative downside amplification**, not the persistence of an individual price decline.

## 7. Estimated Return to Baseline

The decay model gradually approaches an amplification level of 1.0, representing the ordinary-session baseline.

Because an exponential decay approaches its baseline asymptotically, the indicator uses a configurable tolerance.

**Baseline condition:**

A_down_model(H) <= 1 + tolerance

With the default tolerance of 0.10:

A_down_model(H) <= 1.10

The indicator identifies the first session when the modeled amplification satisfies the baseline condition for three consecutive trading sessions, by default.

It reports both the beginning and completion of this qualifying interval.

If the condition is not satisfied within the 21-session modeling horizon, the table reports that baseline normalization was not reached within the evaluated period.

This is a model-based estimate, not a prediction of the exact date when market volatility or price behavior will normalize.

## 8. Before-Open and After-Close Earnings Assumptions

Earnings announcements occur at different times relative to the trading session.

The indicator therefore evaluates two alternative timing assumptions.

**Before-open assumption:**

Previous session Close → Earnings-marker session Close

**After-close assumption:**

Earnings-marker session Close → Next session Close

Both versions use TradingView's earnings data and a fixed event-marker alignment adjustment.

The two columns are alternative calculation scenarios, not independently verified classifications of when each historical earnings announcement was released.

This allows users to examine the sensitivity of the results to the earnings reaction interval.

## 9. Reading the Indicator Table

The indicator provides a side-by-side comparison of the two earnings timing assumptions.

The table contains:

- Number of historical earnings events analyzed.
- Earnings-event sample date range.
- Number of matched non-earnings controls.
- Mean normalized downside and upside contributions.
- Downside amplification (A_down).
- Upside amplification (A_up).
- Logarithmic asymmetry (LA).
- Fixed historical downside-amplification quintile.
- Modeled downside amplification at Days 5, 10, and 21.
- Estimated baseline-normalization interval.
- Calculation status and recent earnings-return audits.

A separate **Control-date audit** view displays actual sampled control dates, corresponding daily returns, and normalized returns.

This provides additional transparency into the control observations used in the calculations.

## 10. Potential Applications

This indicator is intended as a quantitative earnings-event risk analysis tool.

It can help answer several research questions:

- Does a stock historically exhibit unusually large downside reactions around earnings?
- Is its earnings-related upside amplification greater or smaller than its downside amplification?
- How do earnings-related movements compare with ordinary trading behavior?
- Does the estimated downside amplification persist beyond the initial reaction?
- How sensitive are the results to assumptions about earnings timing and randomly selected control sessions?

The metrics may complement trend-following, momentum, volatility, or portfolio risk-management systems.

They are not standalone buy or sell signals.

## 11. Important Methodological Considerations

This indicator is based on historical observations and fixed model parameters.

Historical earnings reactions do not guarantee similar behavior during future announcements.

Results may be affected by sample size, changing volatility regimes, random control sampling, corporate developments, and event-date alignment.

The matched-control methodology provides a contemporaneous reference for ordinary trading behavior but does not eliminate every source of market or statistical uncertainty.

The downside persistence model represents a historical empirical approximation. Its parameters were calibrated using five controls per event, while the current script defaults to ten. Changing the control count does not automatically recalibrate the fixed quintile boundaries or persistence parameters.

Consequently, persistence estimates should be interpreted as exploratory research outputs rather than independently validated forecasts.

The indicator is designed for standard daily stock charts, and all model horizons are expressed in trading sessions.

## Research and Development Credit

The underlying concept, research design, methodology, metric definitions, and analytical framework are original work of the author.

AI assistance was used to support Pine Script implementation, code refinement, and debugging.

**Disclaimer:** This indicator is provided for educational and quantitative research purposes only. It is not financial advice and does not guarantee future trading outcomes.

## Source Code

````pine
//@version=6
// Earnings Downside: Open vs Close Table v14 (compact table)
// Concept, methodology and research design: original work of the author.
// AI assistance  was used to help improve and debug the code.
// Two timing assumptions using TradingView EPS events; no date lookup.
// Before-open: prior close -> EPS-marker session close.
// After-close: EPS-marker session close -> next trading session close.
// Alternatives, not verified release-time classifications.
// A fixed alignment (reactionShift) shifts both columns' base event date.
// M random matched controls per event (default M = 10). Fixed quintile boundaries unchanged.
// A_down = (sum of max(-Rnorm,0) over N events / N) / (sum over M*N controls / (M*N))
// A_up   = (sum of max( Rnorm,0) over N events / N) / (sum over M*N controls / (M*N))
// Compact version: calculations are identical to v14; only table rows were reduced.
indicator("Earnings Reaction Asymmetry | Relative Risk & Downside Persistence", overlay = true, max_bars_back = 300)

int requestedEvents = input.int(20, "Prior earnings events", minval = 5, maxval = 100)
// Fixed EPS-marker alignment (sessions). -1 corrects the observed one-session marker delay; set to 0 to use the raw feed date.
int reactionShift = -1
bool showAudit = input.bool(true, "Show recent close-to-close return audit")
string tableView = input.string("Scores", "Table view", options = ["Scores", "Control-date audit"])
int auditEventRank = input.int(1, "Audit earnings event (1 = newest selected)", minval = 1, maxval = 100)
int controlWindow = input.int(30, "Control anchor window +/- sessions", minval = 5, maxval = 120)
int exclusionWindow = input.int(5, "Exclude control anchors +/- earnings sessions", minval = 0, maxval = 30)
int controlSeed = input.int(42, "Control sampling seed", minval = 1, maxval = 1000000000)
int controlsPerEvent = input.int(10, "Random controls per earnings event", minval = 5, maxval = 60, tooltip = "Default 10. More controls reduce seed-to-seed noise, but each event needs at least this many eligible control days or the table shows N/A. Draws are sequential, so the first 5 controls are identical for every setting. Quintile boundaries, tau and k were fitted with 5 controls per event.")
float tolerance = input.float(0.10, "Baseline tolerance above 1", minval = 0.001, maxval = 1.0, step = 0.01, tooltip = "0.10 means A_down <= 1.10. A fitted exponential approaches 1 asymptotically.")
int sustainedSessions = input.int(3, "Consecutive sessions at baseline", minval = 1, maxval = 5)
string corner = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"])
string textSize = input.string("Small", "Table text size", options = ["Small", "Normal", "Large"])

// Unchanged fixed A_down boundaries. Equality stays in the lower bracket.
f_quintile(float a) =>
    int q = na(a) ? na : a <= 1.9430173358425074 ? 1 : a <= 2.726773890663 ? 2 : a <= 3.6845873998294874 ? 3 : a <= 4.671472787395273 ? 4 : 5
    q

f_tau(int q) =>
    switch q
        1 => 1.813
        2 => 2.689
        3 => 2.886
        4 => 3.431
        5 => 3.934
        => float(na)

f_k(int q) =>
    switch q
        1 => 1.702
        2 => 0.818
        3 => 0.678
        4 => 0.692
        5 => 0.633
        => float(na)

f_bracket(int q) =>
    switch q
        1 => "A_down <= 1.943"
        2 => "1.943 < A_down <= 2.727"
        3 => "2.727 < A_down <= 3.685"
        4 => "3.685 < A_down <= 4.671"
        5 => "A_down > 4.671"
        => "N/A"

f_curve(float a, float tau, float k, int h) =>
    na(a) or na(tau) or na(k) ? float(na) : 1.0 + math.max(a - 1.0, 0.0) * math.exp(-math.pow((h - 1.0) / tau, k))

f_num(float v) =>
    na(v) ? "N/A" : str.tostring(v, "#.###")

f_streak(int startDay, int endDay) =>
    na(startDay) ? "Not within 21 sessions" : "Day " + str.tostring(startDay) + " -> Day " + str.tostring(endDay)

// Local Park-Miller PRNG, reinitialized for each symbol/event. This avoids
// dependence on the order/number of table refreshes or global random calls.
f_symbol_hash(string symbol) =>
    string canonical = str.upper(str.replace_all(symbol, ".", "-"))
    string alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.:/_-"
    int hash = 1
    for j = 0 to str.length(canonical) - 1
        int pos = str.pos(alphabet, str.substring(canonical, j, j + 1))
        int code = na(pos) or pos < 0 ? 0 : pos + 1
        hash := (hash * 131 + code) % 2147483647
    hash

f_random_index(int initialState, int count) =>
    int state = initialState
    int draw = na
    // Rejection sampling avoids modulo bias for any remaining pool size.
    int limit = 2147483646 - (2147483646 % count)
    while na(draw)
        state := (state * 16807) % 2147483647
        int u = state - 1
        if u < limit
            draw := u % count
    [state, draw]

if barstate.isfirst and not (timeframe.isdaily and timeframe.multiplier == 1)
    runtime.error("Use this indicator on a standard 1D stock chart. All horizons are trading sessions.")

// Long-term baseline is the prior anchor's 252-session mean TR / previous Close.
// Daily EPS and prices are committed only after the chart bar is confirmed.
float eps = request.earnings(syminfo.tickerid, earnings.actual, gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float longTR = ta.sma(ta.tr(true) / close[1], 252)
float normalizedReturn = close[1] > 0 and longTR[1] > 0 ? (close / close[1] - 1.0) / longTR[1] : na
// Control returns use LT252 on the anchor, already lagged one day.
float normalizedControl = close[1] > 0 and longTR[2] > 0 ? (close / close[1] - 1.0) / longTR[2] : na
bool epsEvent = not na(eps)
var array<float> rawReturns = array.new<float>()
var array<float> returns = array.new<float>()
var array<float> controlReturns = array.new<float>()
var array<int> dates = array.new<int>()
var array<int> epsIndices = array.new<int>()

if barstate.isconfirmed
    int index = array.size(returns)
    array.push(rawReturns, close[1] > 0 ? close / close[1] - 1.0 : na)
    array.push(returns, normalizedReturn)
    array.push(controlReturns, normalizedControl)
    array.push(dates, time)
    if epsEvent
        array.push(epsIndices, index)

string tablePosition = corner == "Top left" ? position.top_left : corner == "Bottom right" ? position.bottom_right : corner == "Bottom left" ? position.bottom_left : position.top_right
string fontSize = textSize == "Normal" ? size.normal : textSize == "Large" ? size.large : size.small
color labelBG = color.rgb(29, 41, 56)
color valueBG = color.rgb(17, 27, 40)
color ink = color.rgb(231, 238, 245)
var table panel = table.new(tablePosition, 3, 20, frame_color = color.rgb(81, 99, 120), frame_width = 1, border_width = 1, border_color = color.rgb(42, 56, 73))

f_row(int row, string label, string value, color valueColor, int column) =>
    table.cell(panel, 0, row, label, bgcolor = labelBG, text_color = ink, text_size = fontSize, text_halign = text.align_left)
    table.cell(panel, column, row, value, bgcolor = valueBG, text_color = valueColor, text_size = fontSize, text_halign = text.align_right)

// Recalculate at load and at a completed daily Close, never every live tick.
if barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed)
    table.clear(panel, 0, 0, 2, 19)
    for assumption = 0 to 1
        int bars = array.size(returns)
        array<int> eventIndices = array.new<int>()
        array<int> eventMarkerIndices = array.new<int>()
        if array.size(epsIndices) > 0
            for e = 0 to array.size(epsIndices) - 1
                int marker = array.get(epsIndices, e)
                int ri = marker + reactionShift + assumption
                if ri >= 1 and ri < bars
                    array.push(eventIndices, ri)
                    array.push(eventMarkerIndices, marker)
        int totalEvents = array.size(eventIndices)
        int selected = 0
        int matchedControlEvents = 0
        int newestSelected = na
        int oldestSelected = na
        float earnDown = 0.0
        float earnUp = 0.0
        float controlDown = 0.0
        float controlUp = 0.0
        int auditReaction = na
        int auditPoolSize = na
        array<int> auditAnchors = array.new<int>()
        array<float> auditNorms = array.new<float>()
        float aDown = na
        float aUp = na
        string status = "Insufficient usable earnings history"

        if bars > 252 and totalEvents > 0
            // Exclude control anchors within +/- exclusionWindow completed reaction sessions.
            array<bool> blocked = array.new<bool>(bars, false)
            for e = 0 to totalEvents - 1
                int reactionIndex = array.get(eventIndices, e)
                int lo = math.max(0, reactionIndex - exclusionWindow)
                int hi = math.min(bars - 1, reactionIndex + exclusionWindow)
                if reactionIndex + 20 < bars and not na(array.get(returns, reactionIndex))
                    for j = lo to hi
                        array.set(blocked, j, true)

            // Scan newest first. Each selected event must have a normalized return
            // and five available ordinary-day controls. Never silently use fewer N.
            for back = 0 to totalEvents - 1
                if selected >= requestedEvents
                    break
                int ri = array.get(eventIndices, totalEvents - 1 - back)
                float eventReturn = array.get(returns, ri)
                if not na(eventReturn) and ri + 20 < bars
                    selected += 1
                    newestSelected := na(newestSelected) ? array.get(dates, ri) : newestSelected
                    oldestSelected := array.get(dates, ri)
                    array<float> candidates = array.new<float>()
                    array<int> candidateAnchors = array.new<int>()
                    // Control ANCHOR indices within +/- controlWindow of the reaction. Require full 21 sessions.
                    int lo = math.max(253, ri - controlWindow)
                    int hi = math.min(bars - 22, ri + controlWindow)
                    if hi >= lo
                        for j = lo to hi
                            float r = array.get(controlReturns, j + 1)
                            if not array.get(blocked, j) and not na(r)
                                array.push(candidates, r)
                                array.push(candidateAnchors, j)
                    int nc = array.size(candidates)
                    if selected == auditEventRank
                        auditReaction := ri
                        auditPoolSize := nc
                    if nc >= controlsPerEvent
                        matchedControlEvents += 1
                        earnDown += math.max(-eventReturn, 0.0)
                        earnUp += math.max(eventReturn, 0.0)
                        // Five seeded random controls WITHOUT replacement.
                        // Seed depends on symbol and reaction date, never bar_index.
                        int eventDay = int(math.floor(array.get(dates, ri) / 86400000.0))
                        int randomState = 1 + ((f_symbol_hash(syminfo.ticker) + eventDay + controlSeed) % 2147483646)
                        for c = 0 to controlsPerEvent - 1
                            [nextState, ci] = f_random_index(randomState, array.size(candidates))
                            randomState := nextState
                            float r = array.remove(candidates, ci)
                            int chosenAnchor = array.remove(candidateAnchors, ci)
                            if selected == auditEventRank
                                array.push(auditAnchors, chosenAnchor)
                                array.push(auditNorms, r)
                            controlDown += math.max(-r, 0.0)
                            controlUp += math.max(r, 0.0)

            if selected == requestedEvents and matchedControlEvents == requestedEvents
                aDown := controlDown > 0 ? float(controlsPerEvent) * earnDown / controlDown : na
                aUp := controlUp > 0 ? float(controlsPerEvent) * earnUp / controlUp : na
                status := na(aDown) ? "No ordinary-day downside denominator" : "Calculated / timing assumption"

        int q = f_quintile(aDown)
        float tau = f_tau(q)
        float k = f_k(q)
        float la = not na(aDown) and not na(aUp) and aDown > 0 and aUp > 0 ? math.log(aUp / aDown) : na
        int firstBaseline = na
        int confirmedBaseline = na
        // Evaluate the fixed model only inside its 1..21 fitted horizon.
        if not na(aDown)
            int streak = 0
            for h = 1 to 21
                float estimate = f_curve(aDown, tau, k, h)
                streak := estimate <= 1.0 + tolerance + 1e-10 ? streak + 1 : 0
                if na(firstBaseline) and streak >= sustainedSessions
                    firstBaseline := h - sustainedSessions + 1
                    confirmedBaseline := h

        string sampleText = str.tostring(selected) + " / " + str.tostring(requestedEvents)
        string rangeText = na(oldestSelected) ? "N/A" : str.format_time(oldestSelected, "yyyy-MM-dd") + " to " + str.format_time(newestSelected, "yyyy-MM-dd")
        string asOf = bars > 0 ? str.format_time(array.get(dates, bars - 1), "yyyy-MM-dd") : "Waiting for completed bar"
        color riskInk = na(q) ? color.silver : q >= 4 ? color.rgb(255, 160, 126) : color.rgb(125, 218, 185)
        string header = assumption == 0 ? "Before-open assumption" : "After-close assumption"
        int col = assumption + 1

        if tableView == "Scores"
            f_row(0, syminfo.ticker + " / v14", header, ink, col)
            f_row(1, "Completed data through", asOf, ink, col)
            f_row(2, "Return interval", assumption == 0 ? "Prior close -> event close" : "Event close -> next close", ink, col)
            f_row(3, "Usable earnings events", sampleText, ink, col)
            f_row(4, "First / last reaction in sample", rangeText, ink, col)
            f_row(5, "Matched controls", str.tostring(matchedControlEvents * controlsPerEvent) + " / " + str.tostring(requestedEvents * controlsPerEvent), ink, col)
            f_row(6, "Earnings mean: down / up", selected > 0 and matchedControlEvents == selected ? f_num(earnDown / selected) + " / " + f_num(earnUp / selected) : "N/A", ink, col)
            f_row(7, "Controls mean: down / up", matchedControlEvents > 0 ? f_num(controlDown / (matchedControlEvents * controlsPerEvent)) + " / " + f_num(controlUp / (matchedControlEvents * controlsPerEvent)) : "N/A", ink, col)
            f_row(8, "A_down", f_num(aDown), riskInk, col)
            f_row(9, "A_up", f_num(aUp), ink, col)
            f_row(10, "LA = log(A_up / A_down)", f_num(la), ink, col)
            f_row(11, "Fixed quintile / bracket", na(q) ? "N/A" : "Q" + str.tostring(q) + " | " + f_bracket(q), riskInk, col)
            f_row(12, "Model A_down / Day 5", f_num(f_curve(aDown, tau, k, 5)), ink, col)
            f_row(13, "Model A_down / Day 10", f_num(f_curve(aDown, tau, k, 10)), ink, col)
            f_row(14, "Model A_down / Day 21", f_num(f_curve(aDown, tau, k, 21)), ink, col)
            f_row(15, "Baseline streak (start -> complete)", na(aDown) ? "N/A" : f_streak(firstBaseline, confirmedBaseline), ink, col)
            f_row(16, "Calculation status", status, ink, col)

            // Audit the most recent events actually eligible for the 21-session study.
            int auditFound = 0
            if showAudit and totalEvents > 0
                for back = 0 to totalEvents - 1
                    if auditFound >= 3
                        break
                    int pos = totalEvents - 1 - back
                    int ri = array.get(eventIndices, pos)
                    if ri + 20 < bars and not na(array.get(returns, ri))
                        string anchorDate = str.format_time(array.get(dates, ri - 1), "yyyy-MM-dd", syminfo.timezone)
                        string reactionDate = str.format_time(array.get(dates, ri), "yyyy-MM-dd", syminfo.timezone)
                        float rawNorm = array.get(returns, ri)
                        float rawPct = array.get(rawReturns, ri) * 100.0
                        f_row(17 + auditFound, "Close -> close " + str.tostring(auditFound + 1), anchorDate + " -> " + reactionDate + "\nReturn=" + f_num(rawPct) + "% / Rnorm=" + f_num(rawNorm), ink, col)
                        auditFound += 1
            if auditFound < 3
                for j = auditFound to 2
                    f_row(17 + j, "Event audit " + str.tostring(j + 1), showAudit ? "No usable event" : "Hidden", ink, col)
        else
            f_row(0, syminfo.ticker + " / v14", header, ink, col)
            f_row(1, "Selected event rank", str.tostring(auditEventRank) + " / newest first", ink, col)
            string eventInterval = na(auditReaction) ? "No selected event" : str.format_time(array.get(dates, auditReaction - 1), "yyyy-MM-dd", syminfo.timezone) + " -> " + str.format_time(array.get(dates, auditReaction), "yyyy-MM-dd", syminfo.timezone)
            f_row(2, "Earnings close -> close", eventInterval, ink, col)
            f_row(3, "Earnings Rnorm", na(auditReaction) ? "N/A" : f_num(array.get(returns, auditReaction)), ink, col)
            f_row(4, "Eligible control anchors", na(auditPoolSize) ? "N/A" : str.tostring(auditPoolSize), ink, col)
            for c = 0 to 4
                string controlText = "Unavailable"
                if c < array.size(auditAnchors)
                    int anchor = array.get(auditAnchors, c)
                    controlText := str.format_time(array.get(dates, anchor), "yyyy-MM-dd", syminfo.timezone) + " -> " + str.format_time(array.get(dates, anchor + 1), "yyyy-MM-dd", syminfo.timezone) + "\nReturn=" + f_num(array.get(rawReturns, anchor + 1) * 100.0) + "% / Rnorm=" + f_num(array.get(auditNorms, c))
                f_row(5 + c, "Control close -> close " + str.tostring(c + 1), controlText, ink, col)
            f_row(10, "Window / exclusion / seed / controls per event", "+/-" + str.tostring(controlWindow) + " / +/-" + str.tostring(exclusionWindow) + " / " + str.tostring(controlSeed) + " / " + str.tostring(controlsPerEvent), ink, col)
````
