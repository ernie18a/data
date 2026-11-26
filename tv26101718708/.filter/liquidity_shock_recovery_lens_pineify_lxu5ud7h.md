# Liquidity Shock Recovery Lens [Pineify]

- url: https://www.tradingview.com/script/lxU5Ud7h-Liquidity-Shock-Recovery-Lens-Pineify/
- type: indicator
- pine_id: PUB;de29843e819f417aa357ff3055e68938
- version: 1.0

## Description

[b]Overview[/b]
The pane follows a confirmed high-volume, wide-range bar. Energy and return columns separate fading activity from origin return. Liquidity shock is an OHLCV proxy, not measured order-book depth.

[b]Problem Definition[/b]
A volume spike cannot distinguish persistent displacement from a brief disturbance. A smaller next bar is insufficient: activity may fade while price stays far from its starting point. The question is whether displacement persists, trading contracts inside the shock interval, or price returns efficiently toward the origin. Recovery requires location and participation evidence together.

[b]Design Rationale[/b]
Volume uses a prior-window median and true range uses prior ATR, excluding the candidate. Both triggers must pass. Baselines, the pre-shock close and interval then freeze so an event cannot redefine normality. Restarting on every spike was rejected because it erases an unresolved path. A finite age prevents indefinite retention. Hysteresis reduces threshold flicker but delays transitions; a consecutive-bar origin hold makes completion stricter than activity decay alone.

[b]Key Features[/b]
[list]
[*]Frozen event references and a bounded observation age.
[*]Shock, continuation, absorption and returning states; separate recovery, timeout and data-gap outcomes.
[*]Energy above zero and return quality below zero.
[*]Optional component curves, wash, symbols and dashboard.
[/list]

[b]How It Works[/b]
After full prior coverage, default triggers require volume twice its 50-bar median and true range 1.8 times prior ATR. Seed energy is 100 times x/(1+x), where x is the geometric mean of trigger-relative ratios. Follow-up range and volume blend equally with their previous event values. Residual energy multiplies the seed by their geometric ratio to shock activity, capped at the seed.

Retention is signed origin distance divided by the larger of initial close displacement and a quarter of shock range. Continuation also requires net movement from the shock close divided by accumulated close travel and sustained volume. Absorption uses the share of follow-up closes inside the frozen high-low interval and contracting range. Return progress is retracement from the farthest origin distance divided by that distance; return efficiency divides retracement by close travel since that extreme. A new or equal extreme resets the return path. Both are bounded at 0-1.

After minimum age, priority is continuation, returning, absorption, then shock. Recovery requires consecutive closes near the origin while smoothed range and volume meet frozen-baseline quiet limits. Completion beats timeout only when the full hold is met. Missing price or positive volume ends the event without recovery.

[b]How Multiple Indicators Work Together[/b]
The trigger establishes an event; frozen references keep its aftermath comparable. Retention and net/travel efficiency distinguish persistence from wandering. Residence identifies interval contraction. Return efficiency discounts noisy retracement. Quiet activity cannot finish recovery without origin proximity, and proximity cannot finish it while activity remains elevated.

[b]Trading Ideas and Insights[/b]
Continuation describes observed persistence; absorption means interval residence and range contraction, not proof of hidden orders. Returning may fail before recovery. Timeout means unresolved observation. Compare these states with price structure and execution constraints before using a liquidity shock indicator as trade context.

[b]Unique Aspects[/b]
A spike marker or rolling volatility oscillator loses event context. This lens preserves the original ruler, distinguishes dissipation from efficient origin return, and requires a quiet origin hold. Different entry and exit thresholds stabilize path states; later shocks cannot erase an active path. The contribution lies in frozen references and completion logic.

[b]How to Use[/b]
Use standard candles on liquid stocks, ETFs, futures or crypto with usable volume, initially on 5-minute to daily charts. Wait for maturity and a diamond. Read the field with negative return columns and state text. Squares mark absorption, circles recovery and crosses unresolved endings. Set alerts once per bar close.

[b]Customization[/b]
Baseline length and surprise thresholds select events. Minimum age, age limit, origin tolerance, quiet range/volume limits and hold length govern completion; the continuation threshold governs persistence. The limit must permit minimum age plus the hold. Defaults are starting points. Component curves explain pressure; secondary layers can be hidden.

[b]Assumptions and Limitations[/b]
OHLCV cannot establish depth or aggressive trade direction. Gaps enter true range, feed volume may be incomparable, and synthetic candles alter inputs. Full prior coverage is required; missing or zero event volume invalidates it. States, curves and alerts update at confirmed closes; live candidate ratios can change intrabar. Smoothing and holds add lag. Thresholds affect event selection, and a trend may never revisit the origin. Repeated shocks are ignored while active. Outcomes last one bar before monitoring resumes. Loaded history affects initialization. No profitability or prediction claim is made.

[b]Conclusion[/b]
Use the lens to distinguish fading activity from a quiet return near a frozen origin. Confirmed recovery is an observed event outcome, not evidence that the market is safe or that its next move is known.

## Source Code

````pine
//@version=6
indicator("Liquidity Shock Recovery Lens [Pineify]", shorttitle="Shock Recovery [Pineify]", overlay=false, precision=1, max_bars_back=500)

// Independent implementation: event-locked baselines and a finite recovery path.
// Volume and range are proxies for an observed shock, not measured liquidity.
string detectionGroup = "Shock detection"
int baselineLength = input.int(50, "Prior baseline bars", minval=20, maxval=200, group=detectionGroup)
float volumeTrigger = input.float(2.0, "Volume surprise trigger", minval=1.2, maxval=8.0, step=0.1, group=detectionGroup)
float rangeTrigger = input.float(1.8, "True range / prior ATR trigger", minval=1.1, maxval=6.0, step=0.1, group=detectionGroup)
string pathGroup = "Event path"
int minimumAge = input.int(3, "Minimum follow-up bars", minval=2, maxval=10, group=pathGroup)
int maximumAge = input.int(30, "Maximum follow-up bars", minval=10, maxval=100, group=pathGroup)
float originTolerance = input.float(0.25, "Origin tolerance in frozen ATR", minval=0.05, maxval=1.0, step=0.05, group=pathGroup)
float quietRange = input.float(1.0, "Quiet true range / frozen ATR", minval=0.3, maxval=1.5, step=0.1, group=pathGroup)
float quietVolume = input.float(1.2, "Quiet volume / frozen median", minval=0.5, maxval=2.0, step=0.1, group=pathGroup)
int recoveryHold = input.int(2, "Consecutive quiet origin bars", minval=2, maxval=6, group=pathGroup)
float continuationThreshold = input.float(1.15, "Continuation retention threshold", minval=1.05, maxval=2.0, step=0.05, group=pathGroup)
string visualGroup = "Visual layers"
bool showComponents = input.bool(false, "Show range and volume pressure", group=visualGroup)
bool showStateWash = input.bool(true, "Show confirmed state wash", group=visualGroup)
bool showMarkers = input.bool(true, "Show transition markers", group=visualGroup)
bool showDashboard = input.bool(true, "Show event dashboard", group=visualGroup)
color shockColor = input.color(color.rgb(200, 116, 12), "Shock", group=visualGroup)
color continuationColor = input.color(color.rgb(43, 111, 208), "Continuation", group=visualGroup)
color absorptionColor = input.color(color.rgb(142, 77, 191), "Absorption", group=visualGroup)
color returnColor = input.color(color.rgb(0, 140, 148), "Returning", group=visualGroup)
color recoveredColor = input.color(color.rgb(30, 154, 92), "Recovered", group=visualGroup)
color neutralColor = input.color(color.rgb(122, 126, 136), "Inactive / ended", group=visualGroup)

f_unit(float value) =>
    math.max(0.0, math.min(1.0, value))

f_state(int value) =>
    switch value
        1 => "SHOCK"
        2 => "CONTINUATION"
        3 => "ABSORPTION"
        4 => "RETURNING"
        5 => "RECOVERED"
        6 => "TIMEOUT"
        7 => "DATA GAP"
        => "MONITORING"

f_number(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

if barstate.isfirst and maximumAge < minimumAge + recoveryHold - 1
    runtime.error("Maximum follow-up bars must allow the minimum age plus the full recovery hold.")

float tick = math.max(syminfo.mintick, 0.00000001)
bool validPrice = not na(open) and not na(high) and not na(low) and not na(close) and not na(close[1]) and high >= low
bool validVolume = not na(volume) and volume > 0
float trueRange = ta.tr(true)
float priorATR = ta.atr(baselineLength)[1]
float priorVolume = ta.median(volume[1], baselineLength)
float validPriorCount = math.sum((validPrice[1] and validVolume[1]) ? 1.0 : 0.0, baselineLength)
bool detectorReady = validPrice and validVolume and validPriorCount == baselineLength and not na(priorATR) and priorATR > tick and not na(priorVolume) and priorVolume > 0
float volumeSurprise = detectorReady ? volume / priorVolume : na
float rangeSurprise = detectorReady ? trueRange / priorATR : na
bool shockCandidate = detectorReady and volumeSurprise >= volumeTrigger and rangeSurprise >= rangeTrigger

// State 0 monitoring; 1 shock; 2 continuation; 3 absorption; 4 returning;
// terminal states 5 recovered, 6 timed out, 7 data gap last for one bar.
var bool active = false
var int state = 0
var int age = 0
var int direction = 0
var float origin = na
var float shockHigh = na
var float shockLow = na
var float shockClose = na
var float frozenATR = na
var float frozenVolume = na
var float shockRange = na
var float shockVolume = na
var float displacementScale = na
var float previousClose = na
var float maximumDistance = na
var float returnPath = 0.0
var float totalPath = 0.0
var int insideBars = 0
var int quietBars = 0
var float smoothRange = na
var float smoothVolume = na
var float seedEnergy = na
var float residualEnergy = na
var float retention = na
var float returnProgress = na
var float returnEfficiency = na
var float pathEfficiency = na
var float residence = na

bool newShock = false
bool enteredAbsorption = false
bool recovered = false
bool timedOut = false
bool dataGap = false
bool enteredContinuation = false
bool enteredReturn = false

if barstate.isconfirmed
    if not active
        state := 0
        if shockCandidate
            active := true
            state := 1
            age := 0
            origin := close[1]
            shockHigh := high
            shockLow := low
            shockClose := close
            frozenATR := priorATR
            frozenVolume := priorVolume
            shockRange := math.max(trueRange, tick)
            shockVolume := volume
            direction := close > origin ? 1 : close < origin ? -1 : 0
            displacementScale := math.max(math.abs(close - origin), shockRange * 0.25)
            previousClose := close
            maximumDistance := math.abs(close - origin)
            returnPath := 0.0
            totalPath := 0.0
            insideBars := 0
            quietBars := 0
            smoothRange := trueRange
            smoothVolume := volume
            float excess = math.sqrt((volumeSurprise / volumeTrigger) * (rangeSurprise / rangeTrigger))
            seedEnergy := 100.0 * excess / (1.0 + excess)
            residualEnergy := seedEnergy
            retention := direction * (close - origin) / displacementScale
            returnProgress := 0.0
            returnEfficiency := 0.0
            pathEfficiency := 0.0
            residence := 0.0
            newShock := true
    if active and not newShock
        if not validPrice or not validVolume
            active := false
            state := 7
            dataGap := true
        else
            age += 1
            float stepDistance = math.abs(close - previousClose)
            float currentDistance = math.abs(close - origin)
            totalPath += stepDistance
            if currentDistance >= maximumDistance
                maximumDistance := currentDistance
                returnPath := 0.0
            else
                returnPath += stepDistance
            previousClose := close
            insideBars += close >= shockLow and close <= shockHigh ? 1 : 0
            smoothRange := 0.5 * trueRange + 0.5 * smoothRange
            smoothVolume := 0.5 * volume + 0.5 * smoothVolume
            retention := direction * (close - origin) / displacementScale
            returnProgress := maximumDistance > tick ? f_unit((maximumDistance - currentDistance) / maximumDistance) : 0.0
            returnEfficiency := returnPath > tick ? f_unit((maximumDistance - currentDistance) / returnPath) : 0.0
            pathEfficiency := totalPath > tick ? f_unit(math.abs(close - shockClose) / totalPath) : 0.0
            residence := insideBars / float(age)
            float residualRatio = math.sqrt(math.max(0.0, smoothRange / shockRange) * math.max(0.0, smoothVolume / shockVolume))
            residualEnergy := seedEnergy * f_unit(residualRatio)
            bool quiet = smoothRange / frozenATR <= quietRange and smoothVolume / frozenVolume <= quietVolume
            bool nearOrigin = currentDistance <= originTolerance * frozenATR
            quietBars := age >= minimumAge and quiet and nearOrigin ? quietBars + 1 : 0
            int previousState = state
            // Completion precedes timeout only when its full observed hold is met.
            if quietBars >= recoveryHold
                state := 5
                active := false
                recovered := true
            else if age >= maximumAge
                state := 6
                active := false
                timedOut := true
            else if age >= minimumAge
                // Entry/exit hysteresis avoids one-bar threshold flicker.
                bool continues = direction != 0 and retention >= (state == 2 ? 0.95 : continuationThreshold) and smoothVolume / frozenVolume >= 1.0 and pathEfficiency >= (state == 2 ? 0.25 : 0.4)
                bool returns = returnProgress >= (state == 4 ? 0.25 : 0.4) and returnEfficiency >= (state == 4 ? 0.2 : 0.35)
                bool absorbs = residence >= (state == 3 ? 0.5 : 0.65) and smoothRange / shockRange <= (state == 3 ? 0.9 : 0.7)
                state := continues ? 2 : returns ? 4 : absorbs ? 3 : 1
            enteredAbsorption := state == 3 and previousState != 3
            enteredContinuation := state == 2 and previousState != 2
            enteredReturn := state == 4 and previousState != 4

bool hasEvent = state != 0
bool usableEvent = hasEvent and state != 7
color stateColor = state == 1 ? shockColor : state == 2 ? continuationColor : state == 3 ? absorptionColor : state == 4 ? returnColor : state == 5 ? recoveredColor : neutralColor
float recoveryScore = usableEvent ? 100.0 * returnProgress * returnEfficiency : na
float displayEnergy = usableEvent ? residualEnergy : na
energyPlot = plot(displayEnergy, "Residual shock energy", stateColor, 3, plot.style_linebr)
zeroPlot = plot(0.0, "Zero / path divider", color.new(chart.fg_color, 65), 1)
seedPlot = plot(usableEvent ? seedEnergy : na, "Frozen seed energy", color.new(stateColor, 65), 1, plot.style_linebr)
fill(energyPlot, zeroPlot, color.new(stateColor, 78), "Residual energy field", fillgaps=false)
fill(seedPlot, energyPlot, color.new(stateColor, 93), "Dissipated event energy", fillgaps=false)
plot(-recoveryScore, "Origin return progress x efficiency", color.new(returnColor, 20), 3, plot.style_columns)
plot(showComponents and usableEvent ? 50.0 * math.min(smoothRange / frozenATR, 2.0) : na, "Range pressure (50 = baseline)", color.new(shockColor, 20), 1, plot.style_linebr)
plot(showComponents and usableEvent ? 50.0 * math.min(smoothVolume / frozenVolume, 2.0) : na, "Volume pressure (50 = baseline)", color.new(continuationColor, 20), 1, plot.style_linebr)
hline(100.0, "Energy ceiling", color.new(chart.fg_color, 85), hline.style_dotted)
hline(-100.0, "Return efficiency ceiling", color.new(chart.fg_color, 85), hline.style_dotted)
bgcolor(showStateWash and hasEvent ? color.new(stateColor, 94) : na, title="Confirmed event state")
plotshape(showMarkers and newShock ? displayEnergy : na, "Confirmed shock", shape.diamond, location.absolute, shockColor, size=size.tiny)
plotshape(showMarkers and enteredAbsorption ? displayEnergy : na, "Absorption entered", shape.square, location.absolute, absorptionColor, size=size.tiny)
plotshape(showMarkers and recovered ? -recoveryScore : na, "Recovery completed", shape.circle, location.absolute, recoveredColor, size=size.tiny)
plotshape(showMarkers and (timedOut or dataGap) ? 0.0 : na, "Event ended without recovery", shape.xcross, location.absolute, neutralColor, size=size.tiny)
plot(volumeSurprise, "Live candidate relative volume", display=display.data_window)
plot(rangeSurprise, "Live candidate range / prior ATR", display=display.data_window)
plot(usableEvent ? retention : na, "Signed displacement retention", display=display.data_window)
plot(usableEvent ? residence * 100.0 : na, "Inside shock interval (%)", display=display.data_window)
plot(hasEvent ? age : na, "Confirmed follow-up age", display=display.data_window)
plot(state, "Confirmed state code", display=display.data_window)

var table dashboard = table.new(position.top_right, 2, 7, border_width=1, border_color=color.new(chart.fg_color, 80))
if barstate.islast
    if showDashboard
        color cellBackground = color.new(chart.bg_color, 8)
        table.cell(dashboard, 0, 0, "SHOCK LENS", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 0, detectorReady or hasEvent ? f_state(state) : "BASELINE / DATA", text_color=stateColor, bgcolor=cellBackground)
        table.cell(dashboard, 0, 1, "Age / limit", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 1, hasEvent ? str.tostring(age) + " / " + str.tostring(maximumAge) : "-", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 0, 2, "Residual energy", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 2, f_number(displayEnergy), text_color=stateColor, bgcolor=cellBackground)
        table.cell(dashboard, 0, 3, "Return score / 100", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 3, f_number(recoveryScore), text_color=returnColor, bgcolor=cellBackground)
        table.cell(dashboard, 0, 4, "Retention / inside", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 4, usableEvent ? f_number(retention) + " / " + f_number(residence * 100.0) + "%" : "-", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 0, 5, "Quiet origin hold", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 5, usableEvent ? str.tostring(quietBars) + " / " + str.tostring(recoveryHold) : "-", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 0, 6, "Live volume / range", text_color=chart.fg_color, bgcolor=cellBackground)
        table.cell(dashboard, 1, 6, f_number(volumeSurprise) + " / " + f_number(rangeSurprise), text_color=chart.fg_color, bgcolor=cellBackground)
    else
        table.clear(dashboard, 0, 0, 1, 6)

alertcondition(newShock, "Confirmed liquidity shock proxy", "High volume and wide true range confirmed. A new shock recovery event has started.")
alertcondition(enteredAbsorption, "Confirmed absorption state", "The shock path is spending time inside its frozen interval as range activity contracts.")
alertcondition(recovered, "Confirmed shock recovery", "Price held near the frozen origin with quiet volume and range for the required completed bars.")
alertcondition(timedOut, "Shock observation timed out", "The event reached its age limit without confirmed recovery.")
alertcondition(dataGap, "Shock event data gap", "Missing price or positive volume ended the active event without recovery.")
alertcondition(enteredContinuation, "Confirmed continuation state", "Displacement retention, path efficiency and participation support continuation.")
alertcondition(enteredReturn, "Confirmed returning state", "Price is retracing its farthest observed distance with sufficient return-path efficiency.")
````
