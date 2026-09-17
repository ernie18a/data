<!-- tradingview-pine-id: PUB;e020ba9f17544b5fbd1dd587f27c7df0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pullback Value Recovery [PhenLabs]

Source: https://www.tradingview.com/script/67Oy8iZb-Pullback-Value-Recovery-PhenLabs/

## Description

📊 Pullback Value Recovery [PhenLabs]

Version: Pine Script™ v6

📌 Description

Pullback Value Recovery identifies a specific continuation sequence: a fresh breakout impulse, an established pullback, and a confirmed recovery. Instead of calling every dip a buying opportunity or every bounce a short, it waits for price to recover two separately measured price averages and clear the previous candle.

The two averages follow different groups of bars. One contains closes advancing with the original impulse; the other contains closes retracing against it. Here, “value” means these conditional HLC3 averages, not fair value, institutional positioning, or actual buying and selling pressure.

A qualifying recovery prints one directional marker and a fixed reference-close, structural-stop, 1R and 2R map. If the recovery is too extended or its stop is too wide, the episode is consumed without a signal, and the dashboard explains the rejection.

🚀 Points of Innovation

[*]Two role-conditioned means: advance and retracement bars are accumulated separately after a confirmed seed, rather than blended into one whole-leg VWAP.
[*]Preparation before recovery: a pullback must establish sufficient adverse bars and depth before a later candle can confirm recovery.
[*]Prior-band testing: the recovery candle is tested against averages known before it formed. It cannot move its own confirmation threshold.
[*]Whole-episode volume fallback: missing volume switches both averages to complete equal-bar histories, rather than mixing volume weights with arbitrary unit weights.
[*]Explicit skip semantics: the first prepared structural recovery either produces a plan or is rejected. The same setup cannot issue repeated “second chance” signals.

🔧 Core Components

[*]Impulse seed: a confirmed close breaks the prior rolling range, its directional body meets the ATR threshold, and it closes in the candle's outer quarter.
[*]Advance mean: uses HLC3 from bars whose close-to-close movement agrees with the seed direction. The seed itself belongs to this group.
[*]Retracement mean: uses HLC3 from bars whose close-to-close movement opposes the seed. Unchanged closes are excluded from both groups.
[*]Local pullback: adverse-bar count and the pullback extreme reset after a close beyond the earlier running directional extreme. The cohort means remain anchored to the seed.
[*]Recovery gate: after preparation, a long closes beyond the prior upper cohort mean plus a buffer AND above the previous candle high. A short closes below the prior lower mean minus a buffer AND below the previous candle low.
[*]Risk map: the signal close is the reference price. The stop sits beyond the signal-inclusive pullback extreme; 1R and 2R are arithmetic references from that distance.

🔥 Key Features

[*]Separate, clearly named bullish and bearish confirmed-recovery alerts.
[*]Numeric event and state plots for Pine Screener workflows.
[*]No external symbol requests, lower-timeframe requests, imported libraries, or footprint dependency.
[*]Visible weighting mode, waiting state, rejection reason, and ignored-seed count.
[*]One active setup or observed plan at a time, with capped historical maps.
[*]Confirmed-bar state changes and fixed reference levels.

🎨 Visualization

[*]Blue-violet line: advance-cohort mean.
[*]Amber line: retracement-cohort mean. The means may cross; neither color represents buy/sell delta.
[*]Faint ribbon: the interval between the cohort means while a setup is developing.
[*]Teal / coral triangles: accepted long / short recovery events.
[*]Dashed lines: reference close and structural stop. Dotted lines: 1R and 2R.
[*]Short shaded map: analytical risk/reward regions. A resolved map stops growing; its prices remain fixed.
[*]Retained status: REF | SL means stop threshold breached; REF | 2R means 2R reached/exceeded; ? is same-bar ambiguity; EXP is unresolved expiry; DATA is unknown. Hover the reference label for details. These are observations, not realized trading results.
[*]Dashboard: detailed state information without covering the chart in labels. Table Size offers Compact, Normal, and Large.

📖 Usage Guidelines

Setup

[*]Breakout lookback: default 20, range 5–100. Shorter windows admit more local breaks; longer windows require a broader range break.
[*]Impulse body / ATR: default 0.65, range 0.20–2.00. Uses ATR(14) from BEFORE the seed and a directional body, not absolute candle size.
[*]Retracement bars: default 2, range 1–6. Counts adverse closes within the local pullback; they need not be consecutive.
[*]Setup expiry bars: default 48, range 10–150. Seed age is zero; age 48 expires before recovery, leaving default opportunities at ages 1–47.
[*]Mean weighting: Auto uses reported chart volume; Equal bars ignores volume intentionally. Auto falls back for the entire episode if an included bar has missing or nonpositive volume.

Recovery filters

[*]Maximum chase / ATR: default 1.00, range 0.10–3.00. Distance beyond the tested prior outer cohort mean.
[*]Maximum stop distance / ATR: default 2.50, range 0.25–6.00. Rejects oversized reference-close-to-stop distance.
[*]Plan observation bars: default 30, range 5–100. Observes only bars AFTER the signal. Threshold events on the final observation bar take priority over expiry.

Chart presentation

[*]Show risk / reward maps: on by default. Hiding drawings does not disable plan observation or its busy state.
[*]Initial map length: default 12, range 4–30. An unresolved map grows to the current bar only after that initial length.
[*]Retained maps: default 6, range 1–12, including the active map. Older drawing objects are removed first; plotted recovery markers remain.
[*]Show seed markers: off by default to keep the chart clean.
[*]Show dashboard: on by default.
[*]Table Size: Compact by default; Normal and Large are available. Map-dependent and dashboard-dependent controls are grayed out when inactive.

Fixed rules

[*]Minimum pullback depth: 0.35 of frozen seed ATR.
[*]Recovery buffer: 0.05 ATR beyond the prior outer cohort mean.
[*]Origin invalidation and structural-stop padding: 0.10 ATR.
[*]Cooldown: the next 8 bars after an accepted or rejected recovery attempt.
[*]Only a fresh qualifying breakout burst can seed. Impulses while busy are ignored, never queued.

✅ Best Use Cases

[*]Structuring a discretionary pullback-continuation review on standard candles.
[*]Separating an unprepared pullback, an armed recovery, and an overextended entry.
[*]Keeping reference risk visible without a dense multi-indicator layout.
[*]Scanning event/state plots, then inspecting the underlying chart and data mode.

⚠️ Limitations

[*]This is a pattern detector and analytical map, not a strategy backtest. No profitability, win rate, or accuracy is established.
[*]The signal close is a reference, not proof of an executable fill. Gaps may breach a threshold without trading at its exact price.
[*]If stop and 2R are both observed in the same candle, the result is marked ambiguous. OHLC does not establish which happened first.
[*]1R is informational. There is no automatic partial exit, stop-to-breakeven, trailing stop, or position sizing.
[*]One active episode or plan intentionally blocks other opportunities. The dashboard reports fresh seeds ignored while busy.
[*]Reported volume can be tick volume or venue-specific volume. These groups do not identify buyers, sellers, absorption, or order flow.
[*]On a fallback transition, the switch bar cannot signal. The indicator does not manufacture a delayed catch-up event.
[*]Parameters, loaded-history initialization, revised data, and nonstandard chart types can change the result. Use standard candles for acceptance testing.
[*]Signals are evaluated on confirmed bars using information available through that close. Recorded events and fixed plan prices remain unchanged under unchanged inputs, data, and initialization; active means and observation endpoints continue to develop by design.
[*]No setup is a valid state. Consult the dashboard before loosening filters; more signals are not evidence of a stronger edge.

💡 What Makes This Different

[*]The distinction is the advance-versus-retracement partition and the causal recovery sequence, not a renamed moving average or a decorative score.
[*]The two means are role-conditioned across the entire episode, while local pullback readiness resets. This avoids carrying an old pullback stop into every later shallow dip.

⚙️ Under the Hood

[*]Conditional anchored accumulators: each cohort keeps sum(HLC3), bar count, sum(HLC3 × volume), and sum(volume). The selected mean is the corresponding ratio. Only bars assigned to that cohort contribute.
[*]Typed episode and plan objects: Pine user-defined types keep the anchor, direction, extrema, preparation latch, and drawing handles together. A bounded UDT array deletes the oldest maps first.
[*]Causal state ordering: the bar's starting phase decides its processing branch. Origin invalidation and expiry precede recovery, and accepted plans are not observed until the next bar.
[*]Prepared latch: enough retracement count/depth plus a close not beyond the buffered band arms a later recovery. This does not require a full traversal from below BOTH means, and the rail crossing need not coincide with the prior-candle break.
[*]Data mode: core calculations need only chart OHLC and optional reported volume. Missing volume has an equal-bar fallback; missing required price data invalidates preparation or makes an active plan unknown. No premium data call is embedded.
[*]Screener & alerts: “PVR Event (+1 long, -1 short)” is +1 or -1 only on an accepted event bar and 0 otherwise. “PVR Armed Direction” exposes +1/-1 for prepared setups. “PVR Phase” is 0 idle, 1 setup, 2 plan. Alerts are “PVR: Long recovery confirmed” and “PVR: Short recovery confirmed”; use Once Per Bar Close. Pine Screener availability and history limits remain subject to TradingView's plan/product rules.

🔬 How It Works

[*]A fresh directional breakout starts an episode and freezes its ATR benchmark.
[*]Advancing and retracing closes feed separate seed-anchored price averages.
[*]The local pullback establishes adverse-bar count, sufficient depth, and a prepared close relative to the cohort band.
[*]A later close recovers the prior band and clears the previous candle boundary.
[*]Chase and stop-distance filters either accept that first structural recovery or consume it as a skipped setup.
[*]An accepted event fixes the analytical map. Subsequent bars resolve it by stop threshold, 2R threshold, ambiguity, data invalidity, or time expiry.

💡 Note:
Start with default settings, inspect both directions, verify symbol-scale attachment, and compare replay/reload behavior before relying on alerts. This tool is an analytical aid, not financial advice.

---

## Source Code

````pine
//@version=6
// Pullback Value Recovery | PhenLabs | Release candidate 1.0.0
// Original method: seed-anchored, close-direction-conditioned HLC3 means.
// Validation status: API/static reviewed; actual Pine Editor acceptance required.
// No trading-performance, fill, order-flow, or fair-value claims.
indicator("Pullback Value Recovery [PhenLabs]", shorttitle="PVR [PhenLabs]", overlay=true, max_bars_back=500, max_lines_count=100, max_labels_count=100, max_boxes_count=50, explicit_plot_zorder=true)

enum WeightMode
    autoVolume = "Auto: volume / equal fallback"
    equalBars = "Equal bars"

enum TableScale
    compact = "Compact"
    normal = "Normal"
    large = "Large"

string SETUP = "Setup"
string RISK = "Recovery filters"
string VIEW = "Chart presentation"
int lookback = input.int(20, "Breakout lookback", minval=5, maxval=100, group=SETUP, tooltip="Seed close must break the prior full window. Only fresh qualifying impulses are admitted; one episode or plan at a time.")
float impulseBody = input.float(0.65, "Impulse body / ATR", minval=0.20, maxval=2.00, step=0.05, group=SETUP, tooltip="Directional candle body divided by ATR(14) from before the seed. The seed must close in its outer quarter.")
int minRetrace = input.int(2, "Retracement bars", minval=1, maxval=6, group=SETUP, tooltip="Adverse close-to-close bars within the current pullback, not necessarily consecutive. Also requires 0.35 seed ATR depth and a prepared close not beyond the recovery gate.")
int episodeBars = input.int(48, "Setup expiry bars", minval=10, maxval=150, group=SETUP, tooltip="Seed is age 0. Expiry at this age occurs before signal evaluation, so 48 allows recovery at ages 1 through 47.")
WeightMode weighting = input.enum(WeightMode.autoVolume, "Mean weighting", group=SETUP, tooltip="Auto uses reported chart volume, which may be tick volume. Any missing/nonpositive volume on an included bar latches BOTH means to equal-bar weighting for this entire episode.")
float maxChase = input.float(1.00, "Maximum chase / ATR", minval=0.10, maxval=3.00, step=0.10, group=RISK, tooltip="Maximum close distance beyond the tested prior outer cohort mean. The first prepared structural recovery consumes the episode even if this filter rejects it.")
float maxRisk = input.float(2.50, "Maximum stop distance / ATR", minval=0.25, maxval=6.00, step=0.25, group=RISK, tooltip="Reference close to pullback extreme plus 0.10 seed ATR padding. Oversized-risk recovery attempts are skipped, not deferred.")
int planBars = input.int(30, "Plan observation bars", minval=5, maxval=100, group=RISK, tooltip="Monitor bars 1 through this number AFTER the signal. Stop/2R on the final bar takes priority over expiry. 1R is informational, not a managed exit.")
bool showPlans = input.bool(true, "Show risk / reward maps", group=VIEW, tooltip="Display fixed analytical levels, not orders or a backtest. Turning this off does not disable plan observation or its busy state.")
int rayBars = input.int(12, "Initial map length", minval=4, maxval=30, group=VIEW, active=showPlans, tooltip="Short initial projection. An unresolved map grows only to the current bar; it stops growing on resolution.")
int retainedPlans = input.int(6, "Retained maps", minval=1, maxval=12, group=VIEW, active=showPlans, tooltip="FIFO cap, including the active map. Signal markers remain in plotted history after old map objects are deleted.")
bool showSeeds = input.bool(false, "Show seed markers", group=VIEW, tooltip="Optional context dots. Recovery triangles remain visible by default.")
bool showDashboard = input.bool(true, "Show dashboard", group=VIEW)
TableScale tableScale = input.enum(TableScale.compact, "Table Size", group=VIEW, active=showDashboard)

color BULL = #22C7A5
color BEAR = #F07887
color ADVANCE = #7E91E8
color RETRACE = #E8B86D
color INK = #E2E8F2
color MUTED = #9AA7BA
color PANEL = #151C29

type Cohort
    float sumP = 0.0
    float sumPV = 0.0
    float sumV = 0.0
    int count = 0

type Episode
    int dir
    int born
    float atr
    float origin
    float best
    float pullbackPeak = na
    float pullbackExtreme = na
    int adverseBars = 0
    bool hasPullback = false
    bool armed = false
    bool equalMode = false

type Plan
    int dir
    int born
    float entry
    float stop
    float oneR
    float twoR
    line entryLine = na
    line stopLine = na
    line oneLine = na
    line twoLine = na
    box riskBox = na
    box rewardBox = na
    label entryLabel = na
    label stopLabel = na
    label targetLabel = na

f_mean(Cohort c, bool equalMode) =>
    equalMode ? (c.count > 0 ? c.sumP / c.count : na) : (c.sumV > 0 ? c.sumPV / c.sumV : na)

f_price(float value) =>
    na(value) ? "-" : str.tostring(value, format.mintick)

f_delete(Plan p) =>
    if not na(p.entryLine)
        line.delete(p.entryLine)
        line.delete(p.stopLine)
        line.delete(p.oneLine)
        line.delete(p.twoLine)
        box.delete(p.riskBox)
        box.delete(p.rewardBox)
        label.delete(p.entryLabel)
        label.delete(p.stopLabel)
        label.delete(p.targetLabel)

// All global state reassignments remain in the main script scope.
var int phase = 0
var int blockedThrough = -1
var Episode ep = na
var Cohort advance = Cohort.new()
var Cohort retrace = Cohort.new()
var Plan activePlan = na
var array<Plan> maps = array.new<Plan>()
var string lastEvent = "No episode yet"
var string dataMode = "Awaiting seed"
var int ignoredSeeds = 0
var int attempts = 0
var int skipped = 0
var int accepted = 0
var float lastRiskATR = na
var float testedGate = na
var float testedAdvance = na
var float testedRetrace = na

// Unconditional rolling calculations. Prior references exclude the seed candle.
float atrSeries = ta.atr(14)
float priorATR = atrSeries[1]
float priorHigh = ta.highest(high, lookback)[1]
float priorLow = ta.lowest(low, lookback)[1]
bool priceOK = not na(open) and not na(high) and not na(low) and not na(close) and high >= math.max(open, close) and low <= math.min(open, close)
float priorBadPrices = math.sum(priceOK ? 0.0 : 1.0, lookback)[1]
bool warm = bar_index >= math.max(lookback, 15) and not na(priorBadPrices) and priorBadPrices == 0 and not na(priorATR) and priorATR > 0 and not na(priorHigh) and not na(priorLow)
float candleSpan = high - low
bool rawUp = warm and priceOK and candleSpan > 0 and close > priorHigh and close - open >= impulseBody * priorATR and close >= high - 0.25 * candleSpan
bool rawDown = warm and priceOK and candleSpan > 0 and close < priorLow and open - close >= impulseBody * priorATR and close <= low + 0.25 * candleSpan
bool freshUp = rawUp and not rawUp[1]
bool freshDown = rawDown and not rawDown[1]
bool validVolume = not na(volume) and volume > 0

bool longEvent = false
bool shortEvent = false
bool longSeed = false
bool shortSeed = false
float eventY = na
float bandAdvance = na
float bandRetrace = na
int eventCode = 0

if barstate.isconfirmed
    int startPhase = phase
    if startPhase != 0 and (freshUp or freshDown)
        ignoredSeeds := ignoredSeeds + 1

    if startPhase == 2
        // Signal bar never enters this branch. Ranges do not establish fill order.
        int planAge = bar_index - activePlan.born
        bool stopObserved = priceOK and (activePlan.dir == 1 ? low <= activePlan.stop : high >= activePlan.stop)
        bool targetObserved = priceOK and (activePlan.dir == 1 ? high >= activePlan.twoR : low <= activePlan.twoR)
        bool terminal = not priceOK or stopObserved or targetObserved or planAge >= planBars
        if showPlans and not na(activePlan.entryLine)
            int rightEdge = terminal ? bar_index : math.max(activePlan.born + rayBars, bar_index)
            line.set_x2(activePlan.entryLine, rightEdge)
            line.set_x2(activePlan.stopLine, rightEdge)
            line.set_x2(activePlan.oneLine, rightEdge)
            line.set_x2(activePlan.twoLine, rightEdge)
            box.set_right(activePlan.riskBox, rightEdge)
            box.set_right(activePlan.rewardBox, rightEdge)
        if terminal
            lastEvent := not priceOK ? "Plan: data unknown" : stopObserved and targetObserved ? "Stop + 2R: ambiguous" : stopObserved ? "Stop threshold breached" : targetObserved ? "2R reached / exceeded" : "Plan expired unresolved"
            if showPlans and not na(activePlan.entryLabel)
                string resultTag = not priceOK ? "DATA" : stopObserved and targetObserved ? "?" : stopObserved ? "SL" : targetObserved ? "2R" : "EXP"
                label.delete(activePlan.entryLabel)
                activePlan.entryLabel := label.new(activePlan.born, activePlan.entry, "REF | " + resultTag, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(PANEL, 15), textcolor=INK, size=size.tiny, tooltip=lastEvent + "\nThreshold observation, not a fill or profit result. SL=stop; ?=same-bar stop and 2R; EXP=unresolved expiry; DATA=unknown.")
            phase := 0

    else if startPhase == 1
        int age = bar_index - ep.born
        bool badPrice = not priceOK or na(close[1])
        bool invalidated = priceOK and (ep.dir == 1 ? low <= ep.origin : high >= ep.origin)
        if badPrice or invalidated or age >= episodeBars
            lastEvent := badPrice ? "Setup: invalid price data" : invalidated ? "Seed origin invalidated" : "Setup expired"
            phase := 0
        else
            // Freeze prior-cohort measurements BEFORE including this candle.
            float priorAdvance = f_mean(advance, ep.equalMode)
            float priorRetrace = f_mean(retrace, ep.equalMode)
            float directionalChange = ep.dir * (close - close[1])
            bool included = directionalChange != 0
            bool switched = weighting == WeightMode.autoVolume and not ep.equalMode and included and not validVolume
            bool wasArmed = ep.armed
            if switched
                ep.equalMode := true
                ep.armed := false
                lastEvent := "Equal fallback: re-arming"
                dataMode := "Equal bars (fallback)"
            float outerRail = ep.dir == 1 ? math.max(priorAdvance, priorRetrace) : math.min(priorAdvance, priorRetrace)
            float gate = outerRail + ep.dir * 0.05 * ep.atr
            bool candleConfirmed = ep.dir == 1 ? close > high[1] : close < low[1]
            bool structuralRecovery = wasArmed and not switched and not na(gate) and ep.dir * (close - gate) > 0 and candleConfirmed
            float inclusiveExtreme = ep.hasPullback ? (ep.dir == 1 ? math.min(ep.pullbackExtreme, low) : math.max(ep.pullbackExtreme, high)) : na

            if structuralRecovery
                attempts := attempts + 1
                blockedThrough := bar_index + 8
                testedAdvance := priorAdvance
                testedRetrace := priorRetrace
                testedGate := gate
                float stop = inclusiveExtreme - ep.dir * 0.10 * ep.atr
                float riskDistance = ep.dir * (close - stop)
                float chaseDistance = ep.dir * (close - outerRail)
                lastRiskATR := riskDistance / ep.atr
                bool riskOK = not na(riskDistance) and riskDistance > 0 and riskDistance <= maxRisk * ep.atr
                bool chaseOK = chaseDistance <= maxChase * ep.atr
                if riskOK and chaseOK
                    accepted := accepted + 1
                    longEvent := ep.dir == 1
                    shortEvent := ep.dir == -1
                    eventCode := ep.dir
                    eventY := ep.dir == 1 ? low - 0.15 * ep.atr : high + 0.15 * ep.atr
                    activePlan := Plan.new(dir=ep.dir, born=bar_index, entry=close, stop=stop, oneR=close + ep.dir * riskDistance, twoR=close + ep.dir * 2.0 * riskDistance)
                    lastEvent := ep.dir == 1 ? "Long recovery confirmed" : "Short recovery confirmed"
                    phase := 2
                    if showPlans
                        color directionColor = ep.dir == 1 ? BULL : BEAR
                        int rightEdge = bar_index + rayBars
                        activePlan.riskBox := box.new(left=bar_index, top=math.max(close, stop), right=rightEdge, bottom=math.min(close, stop), xloc=xloc.bar_index, border_color=color.new(BEAR, 100), bgcolor=color.new(BEAR, 93))
                        activePlan.rewardBox := box.new(left=bar_index, top=math.max(close, activePlan.twoR), right=rightEdge, bottom=math.min(close, activePlan.twoR), xloc=xloc.bar_index, border_color=color.new(directionColor, 100), bgcolor=color.new(directionColor, 95))
                        activePlan.entryLine := line.new(bar_index, close, rightEdge, close, xloc=xloc.bar_index, color=color.new(INK, 25), style=line.style_dashed)
                        activePlan.stopLine := line.new(bar_index, stop, rightEdge, stop, xloc=xloc.bar_index, color=color.new(BEAR, 15), style=line.style_dashed)
                        activePlan.oneLine := line.new(bar_index, activePlan.oneR, rightEdge, activePlan.oneR, xloc=xloc.bar_index, color=color.new(directionColor, 55), style=line.style_dotted)
                        activePlan.twoLine := line.new(bar_index, activePlan.twoR, rightEdge, activePlan.twoR, xloc=xloc.bar_index, color=color.new(directionColor, 15), style=line.style_dotted)
                        activePlan.entryLabel := label.new(bar_index, close, "REF", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(PANEL, 15), textcolor=INK, size=size.tiny, tooltip="Analytical reference close, not an executed entry. 1R is the faint middle line.")
                        activePlan.stopLabel := label.new(bar_index, stop, "STOP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(PANEL, 15), textcolor=BEAR, size=size.tiny)
                        activePlan.targetLabel := label.new(bar_index, activePlan.twoR, "2R", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(PANEL, 15), textcolor=directionColor, size=size.tiny)
                        array.push(maps, activePlan)
                        if array.size(maps) > retainedPlans
                            Plan oldest = array.shift(maps)
                            f_delete(oldest)
                else
                    skipped := skipped + 1
                    lastEvent := not riskOK and not chaseOK ? "Skipped: risk + chase" : not riskOK ? "Skipped: stop too wide" : "Skipped: too extended"
                    phase := 0

            // Keep episode-wide means, but reset pullback readiness at a new leg.
            // A new-leg boundary is a CLOSE beyond the earlier best high/low.
            if phase == 1
                bool newLeg = ep.dir * (close - ep.best) > 0
                if newLeg
                    ep.hasPullback := false
                    ep.armed := false
                    ep.adverseBars := 0
                    ep.pullbackPeak := na
                    ep.pullbackExtreme := na
                else
                    if directionalChange < 0
                        if not ep.hasPullback
                            ep.hasPullback := true
                            ep.pullbackPeak := ep.best
                            ep.pullbackExtreme := ep.dir == 1 ? low : high
                        ep.adverseBars := ep.adverseBars + 1
                    if ep.hasPullback
                        ep.pullbackExtreme := ep.dir == 1 ? math.min(ep.pullbackExtreme, low) : math.max(ep.pullbackExtreme, high)
                ep.best := ep.dir == 1 ? math.max(ep.best, high) : math.min(ep.best, low)

            if directionalChange > 0
                advance.sumP := advance.sumP + hlc3
                advance.count := advance.count + 1
                if validVolume
                    advance.sumPV := advance.sumPV + hlc3 * volume
                    advance.sumV := advance.sumV + volume
            else if directionalChange < 0
                retrace.sumP := retrace.sumP + hlc3
                retrace.count := retrace.count + 1
                if validVolume
                    retrace.sumPV := retrace.sumPV + hlc3 * volume
                    retrace.sumV := retrace.sumV + volume

            if phase == 1
                float nowAdvance = f_mean(advance, ep.equalMode)
                float nowRetrace = f_mean(retrace, ep.equalMode)
                float nowOuter = ep.dir == 1 ? math.max(nowAdvance, nowRetrace) : math.min(nowAdvance, nowRetrace)
                float depth = ep.hasPullback ? ep.dir * (ep.pullbackPeak - ep.pullbackExtreme) : 0.0
                bool prepared = ep.hasPullback and ep.adverseBars >= minRetrace and depth >= 0.35 * ep.atr
                // Latched readiness avoids demanding rail-cross and candle-break
                // on the same bar. It cannot become a signal until a later bar.
                if prepared and not na(nowOuter) and ep.dir * (close - (nowOuter + ep.dir * 0.05 * ep.atr)) <= 0
                    ep.armed := true
                bandAdvance := nowAdvance
                bandRetrace := nowRetrace
            else if structuralRecovery
                // Display the exact snapshot tested, not signal-shifted means.
                bandAdvance := testedAdvance
                bandRetrace := testedRetrace

    else if startPhase == 0 and warm and priceOK and bar_index > blockedThrough
        if freshUp or freshDown
            int direction = freshUp ? 1 : -1
            bool useEqual = weighting == WeightMode.equalBars or not validVolume
            ep := Episode.new(dir=direction, born=bar_index, atr=priorATR, origin=direction == 1 ? low - 0.10 * priorATR : high + 0.10 * priorATR, best=direction == 1 ? high : low, equalMode=useEqual)
            advance := Cohort.new(sumP=hlc3, sumPV=validVolume ? hlc3 * volume : 0.0, sumV=validVolume ? volume : 0.0, count=1)
            retrace := Cohort.new()
            phase := 1
            longSeed := direction == 1
            shortSeed := direction == -1
            dataMode := weighting == WeightMode.equalBars ? "Equal bars (selected)" : useEqual ? "Equal bars (fallback)" : "Reported volume"
            lastEvent := direction == 1 ? "Bullish impulse seeded" : "Bearish impulse seeded"
            testedGate := na
            testedAdvance := na
            testedRetrace := na
            // Deliberate seed-bar gap prevents joining independent episodes.

// On the open bar, hold the last committed episode means. No intrabar events.
if not barstate.isconfirmed and phase == 1
    bandAdvance := f_mean(advance, ep.equalMode)
    bandRetrace := f_mean(retrace, ep.equalMode)

// Numeric screen fields come first, with no influence on the pane's scale.
plot(eventCode, "PVR Event (+1 long, -1 short)", display=display.data_window)
plot(phase, "PVR Phase (0 idle, 1 setup, 2 plan)", display=display.data_window)
plot(phase == 1 ? (ep.armed ? ep.dir : 0) : 0, "PVR Armed Direction", display=display.data_window)
plot(longEvent or shortEvent ? testedGate : na, "PVR Tested Recovery Gate", display=display.data_window)
plot(phase == 2 ? activePlan.entry : na, "PVR Reference Close", display=display.data_window)
plot(phase == 2 ? activePlan.stop : na, "PVR Structural Stop", display=display.data_window)
plot(phase == 2 ? activePlan.twoR : na, "PVR 2R Reference", display=display.data_window)
plot(phase == 0 ? na : (ep.equalMode ? 0 : 1), "PVR Weighting (0 equal, 1 volume)", display=display.data_window)
plot(high, "Price anchor high", color=color.new(color.white, 100), display=display.pane, editable=false)
plot(low, "Price anchor low", color=color.new(color.white, 100), display=display.pane, editable=false)
pAdvance = plot(bandAdvance, "Advance cohort mean", color=color.new(ADVANCE, 12), linewidth=1, style=plot.style_linebr, display=display.pane)
pRetrace = plot(bandRetrace, "Retracement cohort mean", color=color.new(RETRACE, 12), linewidth=1, style=plot.style_linebr, display=display.pane)
fill(pAdvance, pRetrace, color=color.new(ADVANCE, 91), title="Cohort band", fillgaps=false)
// Float-or-na is intentional: location.absolute requires a price series.
plotshape(longEvent ? eventY : na, title="Long recovery", style=shape.triangleup, location=location.absolute, color=BULL, size=size.small)
plotshape(shortEvent ? eventY : na, title="Short recovery", style=shape.triangledown, location=location.absolute, color=BEAR, size=size.small)
plotshape(showSeeds and longSeed ? low - 0.10 * priorATR : na, title="Bullish seed", style=shape.circle, location=location.absolute, color=color.new(BULL, 50), size=size.tiny)
plotshape(showSeeds and shortSeed ? high + 0.10 * priorATR : na, title="Bearish seed", style=shape.circle, location=location.absolute, color=color.new(BEAR, 50), size=size.tiny)

alertcondition(longEvent, "PVR: Long recovery confirmed", "PVR long recovery confirmed on {{ticker}} {{interval}} at {{close}}. Analytical reference only; inspect the structural stop and data mode.")
alertcondition(shortEvent, "PVR: Short recovery confirmed", "PVR short recovery confirmed on {{ticker}} {{interval}} at {{close}}. Analytical reference only; inspect the structural stop and data mode.")

var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(PANEL, 5), frame_color=color.new(MUTED, 70), frame_width=1)
if barstate.islast
    if showDashboard
        string fontSize = tableScale == TableScale.compact ? size.small : tableScale == TableScale.normal ? size.normal : size.large
        string stateText = not warm ? "WARMING UP" : phase == 2 ? "OBSERVING PLAN" : phase == 1 ? (ep.armed ? "RECOVERY ARMED" : ep.hasPullback ? "BUILDING PULLBACK" : "WAITING PULLBACK") : bar_index <= blockedThrough ? "COOLDOWN" : "WAITING IMPULSE"
        color stateColor = phase == 0 ? MUTED : ep.dir == 1 ? BULL : BEAR
        string progress = phase == 1 ? str.tostring(ep.adverseBars) + "/" + str.tostring(minRetrace) + " adverse | age " + str.tostring(bar_index - ep.born) : phase == 2 ? "Bar " + str.tostring(bar_index - activePlan.born) + "/" + str.tostring(planBars) : "Fresh range break required"
        string recoveryHint = phase == 1 ? (ep.armed ? "Clear band + prior candle" : "Depth + count + band reset") : "One setup / plan at a time"
        table.cell(dash, 0, 0, "𓄀", text_color=INK, text_size=fontSize, text_halign=text.align_left)
        table.cell(dash, 1, 0, "PVR 1.0", text_color=MUTED, text_size=fontSize, text_halign=text.align_right)
        table.cell(dash, 0, 1, "State", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 1, stateText, text_color=stateColor, text_size=fontSize)
        table.cell(dash, 0, 2, "Data", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 2, dataMode, text_color=INK, text_size=fontSize)
        table.cell(dash, 0, 3, "Progress", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 3, progress, text_color=INK, text_size=fontSize)
        table.cell(dash, 0, 4, "Next gate", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 4, recoveryHint, text_color=INK, text_size=fontSize)
        table.cell(dash, 0, 5, "Last event", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 5, lastEvent, text_color=INK, text_size=fontSize)
        table.cell(dash, 0, 6, "Ref / Stop / 2R", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 6, phase == 2 ? f_price(activePlan.entry) + " / " + f_price(activePlan.stop) + " / " + f_price(activePlan.twoR) : "-", text_color=INK, text_size=fontSize)
        table.cell(dash, 0, 7, "Accepted / skipped", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 7, str.tostring(accepted) + " / " + str.tostring(skipped), text_color=INK, text_size=fontSize, tooltip="Counts in loaded history, NOT wins or losses. A skipped recovery consumes its episode.")
        table.cell(dash, 0, 8, "Seeds ignored: busy", text_color=MUTED, text_size=fontSize)
        table.cell(dash, 1, 8, str.tostring(ignoredSeeds), text_color=MUTED, text_size=fontSize, tooltip="Fresh impulses occurring while a setup or plan was active, including its terminal bar. They are never queued.")
    else
        table.clear(dash, 0, 0, 1, 8)
````
