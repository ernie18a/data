# Support & Resistance [CandleChasers]

- url: https://www.tradingview.com/script/Apbf3vVC-Support-Resistance-CandleChasers/
- type: indicator
- pine_id: PUB;bdd38a76763144c8bb5276b81d413bce
- version: 1.0

## Description

[b]Support & Resistance [CandleChasers][/b]

A selective support and resistance indicator built to keep meaningful price levels visible without covering the chart in horizontal lines. It combines confirmed swing detection, minimum reaction and spacing rules, evidence-based grading, higher-timeframe confluence, and configurable price-event alerts.

[b]HOW LEVELS ARE IDENTIFIED
[/b]
Support begins with a confirmed swing low; resistance begins with a confirmed swing high. Each side has its own left-side lookback, while a shared right-side confirmation window determines when the swing becomes known.

A candidate must also show a minimum close-based move away, measured in the pivot candle's ATR. Nearby qualifying candidates are grouped into an existing same-role level instead of creating another line. The representative price stays fixed when additional evidence is added.

The defaults use 50 left bars, 3 confirmation bars, a 0.75 ATR minimum reaction, and 0.50 current-chart ATR spacing. These are starting values, not universally optimized settings. The combination of confirmation, reaction qualification, and spacing is intended to reduce minor or closely overlapping levels.

[b]READING THE LINES
[/b]
• Solid: an unbroken level, or a retained unbroken level that reached its configured bar limit.
• Dotted: a level that was broken and retained in history.
• Teal by default: chart-timeframe support.
• Red by default: chart-timeframe resistance.
• Gold and slightly thicker by default: a level containing higher-timeframe evidence. Its source label identifies the role and timeframe.

Until broken is the default extension mode. Alternatively, choose Until broken or bar limit to stop a level when its maximum age is reached. Close and Wick modes are available; both confirm the decision when the chart candle closes. Equality at the threshold is a touch, not a break.

An optional tick or ATR buffer can require price to move beyond the raw level before a break is confirmed. Each buffer freezes at level creation. The line and its price label remain at the original level price.

[b]SELECTIVE DISPLAY AND HISTORY
[/b]
The default view shows up to three supports below price and three resistances above price. Newest is the default selection priority; Nearest and Strongest are also available. Selected active lines receive drawing space first. Recent completed history uses the remaining space, subject to separate broken/expired display limits.

Tracking and display are separate. A hidden active level can still be tracked. At tracking capacity, the oldest created record is retired to admit a new distinct level; retirement is not classified as a break. Completed history is also bounded, with older records removed first. Until broken disables age expiry, not these capacity or display rules.

[b]STRENGTH GRADE: 1–5
[/b]
The original strength grade summarizes qualifying swing evidence:

• Base grade: 1.
• Reaction: +1 at a qualifying reaction of at least 1 ATR, or +2 at 2 ATR or more.
• Additional qualifying swing evidence: up to +2.

Select the minimum grade you want to see. For example, 3 shows grades 3–5. Higher-timeframe discoveries can contribute evidence to a nearby chart level.

[b]EVIDENCE SCORE: 0–100
[/b]
A separate score provides more detail. It combines a base value with capped contributions for qualifying reaction size, additional swing evidence, higher-timeframe source/confluence, source pivot relative volume, and observed price rejections. Repeated visits and age apply penalties. Minimum score filtering is independent of the 1–5 grade.

The score uses: 10 base; up to 30 reaction points; 20 swing-evidence points; 15 source/confluence points; 10 volume points; and 15 rejection points, minus up to 15 repeated-visit points and 10 age points. The total is clamped to 0–100. Completed records retain their evidence and age at completion.

Neither grade nor score is a probability that a level will hold. Hover strength labels for supporting measurements, or use the Detailed dashboard to compare displayed levels.

[b]HIGHER-TIMEFRAME LEVELS
[/b]
An optional source, daily by default, detects confirmed swings using completed higher-timeframe data. Select a timeframe above the chart timeframe. Source labels distinguish chart-only, HTF-only, and shared Chart + HTF evidence. Nearby source discoveries can share one fixed representative line.

HTF levels share the same display and qualification rules as other levels; enabling the source does not guarantee a visible gold line. Adequate source history and swing confirmation are required. Higher-timeframe detection does not classify an entire market phase or guarantee stronger reactions.

[b]ALERTS AND VOLUME FILTERS
[/b]
Ten named conditions cover support/resistance breaks, role-reversal retests, touches, rejections, and approaches. Approach distance can use ticks or chart ATR. Contact tolerance, distinct-visit separation, and per-level event cooldowns are configurable.

Choose Displayed levels or All qualifying levels for notification scope. Displayed-level scope uses a selection calculated from the previous close before the current candle's events are processed, with currently available scoring and spacing values. It can differ from the live selection during that candle. Minimum grade and score apply to notification eligibility. Retest eligibility is captured at the qualifying break.

Independent optional relative-volume filters can qualify new pivot evidence, touch/rejection notifications, and break/retest notifications. They default off. Enabled filters fail when usable volume is unavailable. Notification filtering never keeps a physically broken line active: the level still stops and becomes dotted even if its break alert is suppressed. Approach notifications are distance-based and are not volume-filtered.

Create the desired alerts in TradingView and select Once Per Bar Close. Retest alerts require the retest setting to be enabled. Recreate saved alerts after changing the code or inputs.

[b]DASHBOARDS AND LABELS
[/b]
Choose Compact or Detailed layout and Small, Medium, Large, or Hidden size. The dashboard separates tracked records from visible lines and shows filters, source status, relative volume, and recent event information. Detailed layout adds a displayed-level ledger with price, role, grade, score, and source.

Price/strength labels sit above their lines with adjustable spacing. Input values are hidden from the status line while remaining available in Settings → Inputs.

[b]TIMING AND LIMITATIONS
[/b]
Levels begin on their detection candle; they are not backdated to the original swing. Swing confirmation deliberately delays discovery. Break, reaction, and alert decisions commit at chart candle close. Higher-timeframe requests use completed source data.

During an open candle, live price, ATR-based spacing, relative volume, label positions, and which eligible levels are displayed can change. This is distinct from moving a stored level's price. Feed revisions, loaded chart history, and setting changes can alter recalculated results.

If only dotted history is visible, inspect active-record counts, extension mode, minimum score/grade, source confirmation, and display status. The indicator does not invent an active level when no qualifying unbroken candidate exists.

Use standard candlestick charts. Support and resistance are approximate areas of interest even when represented by single lines. They can break, fail to react, or change relevance. This is an analytical indicator, not an automated strategy, and it makes no claim of a verified win rate, profitability, or trading edge.

## Source Code

````pine
//@version=6
// Support & Resistance [CandleChasers] | Release 4.1.2
// Confirmed swing levels, evidence grading, HTF confluence, and price-event alerts.
// Grades/scores summarize rules; neither is a calibrated hold probability.
indicator("Support & Resistance [CandleChasers]", shorttitle="[CC] S/R", overlay=true, scale=scale.none, max_lines_count=500, max_labels_count=100, max_bars_back=2100)

string G1 = "Levels"
int supportLookback = input.int(50, "Support swing lookback (left bars)", minval=2, maxval=500, group=G1, display=display.none)
int resistanceLookback = input.int(50, "Resistance swing lookback (left bars)", minval=2, maxval=500, group=G1, display=display.none)
int confirmationBars = input.int(3, "Swing confirmation (right bars)", minval=1, maxval=30, group=G1, display=display.none)
float minReaction = input.float(0.75, "Minimum close move away / pivot ATR", minval=0.1, step=0.05, group=G1, display=display.none)
float minSpacing = input.float(0.5, "Minimum level spacing / current ATR", minval=0.1, step=0.1, group=G1, display=display.none)
int supportsShown = input.int(3, "Visible supports below price", minval=1, maxval=10, group=G1, display=display.none)
int resistancesShown = input.int(3, "Visible resistances above price", minval=1, maxval=10, group=G1, display=display.none)
string extensionMode = input.string("Until broken", "Line extension", options=["Until broken or bar limit", "Until broken"], group=G1, display=display.none)
int maxBars = input.int(100, "Maximum line length (bars)", minval=1, maxval=2000, group=G1, tooltip="Ignored in Until broken mode.", display=display.none)
int activeLimit = input.int(100, "Maximum tracked levels", minval=20, maxval=200, group=G1, tooltip="Tracking is separate from display. At capacity the oldest created level is retired to allow new discoveries. Retirement is not a break.", display=display.none)
string breakBy = input.string("Close", "Break levels using", options=["Close", "Wick"], group=G1, tooltip="Both modes confirm at candle close. Wick uses the completed candle's high/low. Equality is a touch, not a break.", display=display.none)
string GS = "Level strength"
int minimumStrength = input.int(1, "Minimum strength to show (1–5)", minval=1, maxval=5, group=GS, tooltip="1 shows all; 3 shows grades 3–5; 5 shows grade 5 only. Applies to display and qualifying alerts. Event scope is configurable under Alerts.", display=display.none)
bool showStrength = input.bool(true, "Show strength numbers on active levels", group=GS, display=display.none)
// Evidence grade, not a probability: base 1 + reaction points (0–2) + extra swing points (0–2).
string GX = "Higher timeframe"
bool useHTF = input.bool(true, "Include confirmed higher-timeframe levels", group=GX, display=display.none)
string sourceTF = input.timeframe("1D", "Higher timeframe", group=GX, display=display.none)
color higherColor = input.color(color.rgb(245, 185, 55), "HTF line / label color", group=GX, display=display.none)
bool higherTags = input.bool(true, "Always label displayed HTF levels", group=GX, display=display.none)
bool higherThick = input.bool(true, "Make HTF lines thicker", group=GX, display=display.none)
string GE = "Expanded scoring"
int minimumScore = input.int(0, "Minimum evidence score (0–100)", minval=0, maxval=100, group=GE, display=display.none)
string ranking = input.string("Newest", "Display priority", options=["Newest", "Nearest", "Strongest"], group=GE, display=display.none)
string GV = "Optional volume filters"
int volumeLength = input.int(20, "Previous-volume baseline bars", minval=5, maxval=200, group=GV, display=display.none)
float requiredRV = input.float(1.2, "Minimum relative volume", minval=0.1, step=0.1, group=GV, display=display.none)
bool filterCreation = input.bool(false, "Require pivot volume for new evidence", group=GV, display=display.none)
bool filterReactions = input.bool(false, "Filter touch / rejection notifications", group=GV, display=display.none)
bool filterTransitions = input.bool(false, "Filter break / retest notifications", group=GV, tooltip="Filters notifications only. Physically broken lines still stop and become dotted regardless of volume.", display=display.none)
string GA = "Alerts and reactions"
string alertScope = input.string("Displayed levels", "New event scope", options=["Displayed levels", "All qualifying levels"], group=GA, tooltip="Displayed means the selection calculated from the previous close before processing this bar. Grade and score filters also apply.", display=display.none)
bool touchesOn = input.bool(true, "Enable touch alerts", group=GA, display=display.none)
bool rejectionsOn = input.bool(true, "Enable rejection alerts", group=GA, display=display.none)
bool approachesOn = input.bool(true, "Enable approach alerts", group=GA, display=display.none)
float contactATR = input.float(0.1, "Contact tolerance / level ATR", minval=0.01, step=0.05, group=GA, display=display.none)
int visitReset = input.int(3, "Outside bars between visits", minval=1, maxval=30, group=GA, display=display.none)
string approachMode = input.string("ATR", "Approach distance mode", options=["ATR", "Ticks"], group=GA, display=display.none)
float approachATR = input.float(0.5, "Approach distance / chart ATR", minval=0.05, step=0.05, group=GA, display=display.none)
int approachTicks = input.int(10, "Approach distance ticks", minval=1, group=GA, display=display.none)
int eventCooldown = input.int(10, "Per-level event cooldown bars", minval=1, maxval=200, group=GA, display=display.none)
string dashboardMode = input.string("Compact", "Dashboard layout", options=["Compact", "Detailed"], group=GA, display=display.none)
string dashboardSize = input.string("Small", "Dashboard size", options=["Small", "Medium", "Large", "Hidden"], group=GA, display=display.none)
string dashboardText = dashboardSize == "Large" ? size.large : dashboardSize == "Medium" ? size.normal : size.small
string G2 = "Optional breakout buffer"
string bufferMode = input.string("Off", "Buffer mode", options=["Off", "Ticks", "ATR"], group=G2, display=display.none)
int bufferTicks = input.int(2, "Buffer ticks", minval=1, maxval=1000, group=G2, display=display.none)
float bufferATR = input.float(0.1, "Buffer / ATR", minval=0.01, step=0.05, group=G2, display=display.none)
int atrLength = input.int(14, "ATR length", minval=2, maxval=200, group=G2, display=display.none)
string G3 = "Optional retests"
bool retestsOn = input.bool(false, "Enable retest alerts", group=G3, display=display.none)
int retestWindow = input.int(20, "Retest window (bars)", minval=1, maxval=500, group=G3, display=display.none)
float retestATR = input.float(0.15, "Retest tolerance / ATR", minval=0.01, step=0.05, group=G3, display=display.none)
string G4 = "Appearance"
bool showPrices = input.bool(true, "Show active price labels", group=G4, display=display.none)
int labelOffset = input.int(3, "Label offset (bars)", minval=0, maxval=50, group=G4, display=display.none)
float labelGapATR = input.float(0.10, "Label gap above line / chart ATR", minval=0, maxval=2, step=0.05, group=G4, display=display.none)
bool showBroken = input.bool(true, "Show broken lines", group=G4, display=display.none)
int drawingBudget = input.int(40, "Total visible line budget", minval=20, maxval=100, group=G4, tooltip="Active selected levels take priority. Only remaining slots can display completed history.", display=display.none)
int brokenShown = input.int(8, "Maximum visible broken lines", minval=0, maxval=50, group=G4, display=display.none)
int expiredShown = input.int(2, "Maximum visible expired lines", minval=0, maxval=20, group=G4, display=display.none)
bool showExpired = input.bool(false, "Show unbroken lines that reached bar limit", group=G4, display=display.none)
int historyLimit = input.int(100, "Completed lines to keep", minval=0, maxval=250, group=G4, display=display.none)
int completedFade = input.int(65, "Completed line transparency", minval=0, maxval=100, group=G4, display=display.none)
color supportColor = input.color(color.rgb(0, 185, 150), "Support color", group=G4, display=display.none)
color resistanceColor = input.color(color.rgb(240, 95, 115), "Resistance color", group=G4, display=display.none)
int lineWidth = input.int(2, "Line width", minval=1, maxval=4, group=G4, display=display.none)

bool untilBroken = extensionMode == "Until broken"
float atr = ta.atr(atrLength)
float candidateResistance = ta.pivothigh(high, resistanceLookback, confirmationBars)
float candidateSupport = ta.pivotlow(low, supportLookback, confirmationBars)
float pivotATR = atr[confirmationBars]
bool scaleReady = not na(pivotATR) and pivotATR > 0

float volumeBase = ta.sma(volume, volumeLength)[1]
float rv = not na(volume) and volume > 0 and volumeBase > 0 ? volume / volumeBase : na
float pivotVolume = rv[confirmationBars]
bool reactionVolumeOK = not filterReactions or (not na(rv) and rv >= requiredRV)
bool transitionVolumeOK = not filterTransitions or (not na(rv) and rv >= requiredRV)
bool validHTF = timeframe.in_seconds(sourceTF) > timeframe.in_seconds()
f_htf() =>
    float hh = ta.pivothigh(high, resistanceLookback, confirmationBars)
    float ll = ta.pivotlow(low, supportLookback, confirmationBars)
    float aa = ta.atr(atrLength)
    float vb = ta.sma(volume, volumeLength)[1]
    float vv = not na(volume) and volume > 0 and vb > 0 ? volume / vb : na
    [hh[1], ll[1], close[1], aa[confirmationBars + 1], aa[1], vv[confirmationBars + 1], not na(hh[1]) ? time[confirmationBars + 1] : na, not na(ll[1]) ? time[confirmationBars + 1] : na]
float hHigh = na
float hLow = na
float hClose = na
float hPivotATR = na
float hDetectATR = na
float hRV = na
int hHighTime = na
int hLowTime = na
if useHTF and validHTF
    [hh, ll, cc, pa, da, vv, ht, lt] = request.security(syminfo.tickerid, sourceTF, f_htf(), lookahead=barmerge.lookahead_on)
    hHigh := hh
    hLow := ll
    hClose := cc
    hPivotATR := pa
    hDetectATR := da
    hRV := vv
    hHighTime := ht
    hLowTime := lt
var int lastHTFHigh = na
var int lastHTFLow = na

type Level
    line drawing
    float price
    float buffer
    float scale
    int born
    bool isSupport
    int stamp
    int ended = na
    bool wasBroken = false
    int evidence = 1
    float reaction = 0.0
    int lastEvidencePivot = na
    label strengthLabel = na
    bool chartSource = false
    bool higherSource = false
    float pivotRV = na
    int lastHTFPivot = na
    int visits = 0
    int rejections = 0
    int outside = 0
    int rejectedVisit = -1
    int lastTouch = na
    int lastRejection = na
    int lastApproach = na
    bool wasNear = false
    int ageAtEnd = -1
var array<Level> active = array.new<Level>()
var array<Level> completed = array.new<Level>()
var label supportLabel = na
var label resistanceLabel = na
var float upwardRetest = na
var float downwardRetest = na
var float upwardTolerance = na
var float downwardTolerance = na
var int upwardBreakBar = na
var int downwardBreakBar = na
bool supportBroken = false
bool resistanceBroken = false
bool supportRetest = false
bool resistanceRetest = false
bool supportTouch = false
bool resistanceTouch = false
bool supportRejection = false
bool resistanceRejection = false
bool supportApproach = false
bool resistanceApproach = false
var bool upwardEligible = false
var bool downwardEligible = false
var string latestEvent = "None"
var int latestEventTime = na

f_grade(Level level) =>
    int reactionPoints = level.reaction >= 2.0 ? 2 : level.reaction >= 1.0 ? 1 : 0
    1 + reactionPoints + math.min(2, math.max(0, level.evidence - 1))

f_score(Level level) =>
    float reactionPoints = math.min(30.0, level.reaction * 10)
    float swingPoints = math.min(20.0, math.max(0, level.evidence - 1) * 5)
    float confluence = level.higherSource and level.chartSource ? 15.0 : level.higherSource ? 10.0 : 0.0
    float volumePoints = na(level.pivotRV) ? 0 : math.min(10.0, math.max(0, level.pivotRV - 1) * 10)
    float rejectionPoints = math.min(15.0, level.rejections * 5)
    float testPenalty = math.min(15.0, math.max(0, level.visits - 3) * 3)
    int age = level.ageAtEnd >= 0 ? level.ageAtEnd : bar_index - level.born
    float agePenalty = math.min(10.0, age / 100.0)
    math.max(0, math.min(100, 10 + reactionPoints + swingPoints + confluence + volumePoints + rejectionPoints - testPenalty - agePenalty))
f_qualifies(Level level) =>
    f_grade(level) >= minimumStrength and f_score(level) >= minimumScore
f_source(Level level) =>
    level.higherSource ? (level.chartSource ? "Chart " + timeframe.period + " + HTF " + sourceTF : "HTF " + sourceTF) : "Chart " + timeframe.period
f_ready(int previous) =>
    na(previous) or bar_index - previous >= eventCooldown
f_select(float referencePrice) =>
    array<int> picked = array.new_int()
    if array.size(active) > 0
        for role = 0 to 1
            bool supportRole = role == 0
            int count = supportRole ? supportsShown : resistancesShown
            for slot = 0 to count - 1
                int best = -1
                float bestRank = 1e30
                for i = 0 to array.size(active) - 1
                    Level level = array.get(active, i)
                    bool correctSide = supportRole ? level.price <= referencePrice : level.price >= referencePrice
                    bool spaced = true
                    if array.size(picked) > 0
                        for j = 0 to array.size(picked) - 1
                            Level shown = array.get(active, array.get(picked, j))
                            if shown.isSupport == supportRole and math.abs(level.price - shown.price) < atr * minSpacing
                                spaced := false
                    float distance = math.abs(referencePrice - level.price) / math.max(atr, syminfo.mintick)
                    float rank = ranking == "Newest" ? -level.born * 1000.0 + math.min(999, distance) : ranking == "Strongest" ? -f_score(level) * 1000 + math.min(999, distance) : distance - math.min(10, level.evidence) * 0.000001
                    if f_qualifies(level) and level.isSupport == supportRole and correctSide and spaced and not array.includes(picked, i) and rank < bestRank
                        best := i
                        bestRank := rank
                if best >= 0
                    array.push(picked, best)
    picked

f_hideLabel(Level level) =>
    if not na(level.strengthLabel)
        label.delete(level.strengthLabel)
        level.strengthLabel := na
    true

f_hide(Level level) =>
    f_hideLabel(level)
    if not na(level.drawing)
        line.delete(level.drawing)
        level.drawing := na
    true

f_finish(Level level, bool broken) =>
    f_hideLabel(level)
    level.ended := nz(time_close, time)
    level.wasBroken := broken
    level.ageAtEnd := bar_index - level.born
    if not na(level.drawing)
        line.set_extend(level.drawing, extend.none)
    if historyLimit > 0
        array.push(completed, level)
        while array.size(completed) > historyLimit
            f_hide(array.shift(completed))
    else
        f_hide(level)
    true

f_add(float price, bool isSupport, float sourceATR, float sourceClose, float sourceVolume, bool higher, int pivotKey, float detectATR) =>
    float reaction = math.abs(sourceClose - price) / sourceATR
    int pivotIndex = bar_index - confirmationBars
    int match = -1
    float closest = 1e30
    if array.size(active) > 0
        for i = 0 to array.size(active) - 1
            Level other = array.get(active, i)
            float distance = math.abs(other.price - price)
            if other.isSupport == isSupport and distance <= math.max(syminfo.mintick, atr * minSpacing) and distance < closest
                match := i
                closest := distance
    if match >= 0
        Level other = array.get(active, match)
        // Reject adjacent confirmation windows as additional evidence.
        other.chartSource := other.chartSource or not higher
        other.higherSource := other.higherSource or higher
        bool separated = higher ? na(other.lastHTFPivot) or pivotKey != other.lastHTFPivot : na(other.lastEvidencePivot) or pivotIndex - other.lastEvidencePivot > confirmationBars
        if separated
            other.evidence += 1
            other.reaction := math.max(other.reaction, reaction)
            other.pivotRV := na(other.pivotRV) ? sourceVolume : na(sourceVolume) ? other.pivotRV : math.max(other.pivotRV, sourceVolume)
            if higher
                other.lastHTFPivot := pivotKey
            else
                other.lastEvidencePivot := pivotIndex
        true
    else
        if array.size(active) >= activeLimit
            int victim = 0
            int oldest = bar_index + 1
            for i = 0 to array.size(active) - 1
                Level other = array.get(active, i)
                if other.born < oldest
                    victim := i
                    oldest := other.born
            f_hide(array.remove(active, victim))
        // Start at detection; fixed representative price is never moved by clustering.
        float sourceBuffer = bufferMode == "Ticks" ? bufferTicks * syminfo.mintick : bufferMode == "ATR" ? detectATR * bufferATR : 0.0
        Level level = Level.new(na, price, sourceBuffer, sourceATR, bar_index, isSupport, time)
        level.reaction := reaction
        level.lastEvidencePivot := higher ? na : pivotIndex
        level.lastHTFPivot := higher ? pivotKey : na
        level.chartSource := not higher
        level.higherSource := higher
        level.pivotRV := sourceVolume
        level.outside := visitReset
        array.push(active, level)
        true
    true

if barstate.isconfirmed
    array<int> notificationSelection = f_select(close[1])
    if retestsOn and not na(upwardRetest) and bar_index > upwardBreakBar
        if bar_index - upwardBreakBar > retestWindow or close < upwardRetest - upwardTolerance
            upwardRetest := na
        else if low <= upwardRetest + upwardTolerance and low >= upwardRetest - upwardTolerance and close > upwardRetest and close > open
            supportRetest := upwardEligible and transitionVolumeOK
            upwardRetest := na
    if retestsOn and not na(downwardRetest) and bar_index > downwardBreakBar
        if bar_index - downwardBreakBar > retestWindow or close > downwardRetest + downwardTolerance
            downwardRetest := na
        else if high >= downwardRetest - downwardTolerance and high <= downwardRetest + downwardTolerance and close < downwardRetest and close < open
            resistanceRetest := downwardEligible and transitionVolumeOK
            downwardRetest := na

    // Reverse traversal allows removal without skipping any remaining levels.
    if array.size(active) > 0
        for i = array.size(active) - 1 to 0
            Level level = array.get(active, i)
            if not na(level.drawing)
                line.set_x2(level.drawing, nz(time_close, time))
            bool broken = level.isSupport ? (breakBy == "Close" ? close : low) < level.price - level.buffer : (breakBy == "Close" ? close : high) > level.price + level.buffer
            bool eligible = f_qualifies(level) and (alertScope == "All qualifying levels" or array.includes(notificationSelection, i))
            bool expired = not untilBroken and bar_index - level.born >= maxBars
            if broken or expired
                f_finish(level, broken)
                array.remove(active, i)
                if broken
                    supportBroken := supportBroken or (level.isSupport and eligible and transitionVolumeOK)
                    resistanceBroken := resistanceBroken or (not level.isSupport and eligible and transitionVolumeOK)
                    // Of simultaneous breaks, use the most recently created level per role.
                    if retestsOn and eligible and level.isSupport and (na(downwardBreakBar) or downwardBreakBar != bar_index)
                        downwardEligible := eligible
                        downwardRetest := level.price
                        downwardTolerance := math.max(syminfo.mintick, level.scale * retestATR)
                        downwardBreakBar := bar_index
                    if retestsOn and eligible and not level.isSupport and (na(upwardBreakBar) or upwardBreakBar != bar_index)
                        upwardEligible := eligible
                        upwardRetest := level.price
                        upwardTolerance := math.max(syminfo.mintick, level.scale * retestATR)
                        upwardBreakBar := bar_index

            else
                float tolerance = math.max(syminfo.mintick, level.scale * contactATR)
                bool contact = high >= level.price - tolerance and low <= level.price + tolerance
                bool freshVisit = contact and level.outside >= visitReset
                if contact
                    if freshVisit
                        level.visits += 1
                    level.outside := 0
                else
                    level.outside += 1
                if freshVisit and eligible and reactionVolumeOK and touchesOn and f_ready(level.lastTouch)
                    level.lastTouch := bar_index
                    supportTouch := supportTouch or level.isSupport
                    resistanceTouch := resistanceTouch or not level.isSupport
                bool rejection = level.isSupport ? contact and low >= level.price - tolerance and close > level.price + tolerance and close > open : contact and high <= level.price + tolerance and close < level.price - tolerance and close < open
                if rejection and level.rejectedVisit != level.visits
                    level.rejectedVisit := level.visits
                    level.rejections += 1
                    if eligible and reactionVolumeOK and rejectionsOn and f_ready(level.lastRejection)
                        level.lastRejection := bar_index
                        supportRejection := supportRejection or level.isSupport
                        resistanceRejection := resistanceRejection or not level.isSupport
                float nearDistance = approachMode == "ATR" ? atr * approachATR : syminfo.mintick * approachTicks
                float distance = math.abs(close - level.price)
                bool correctSide = level.isSupport ? close > level.price : close < level.price
                bool near = correctSide and distance <= nearDistance
                if approachesOn and eligible and near and not level.wasNear and not contact and f_ready(level.lastApproach)
                    level.lastApproach := bar_index
                    supportApproach := supportApproach or level.isSupport
                    resistanceApproach := resistanceApproach or not level.isSupport
                level.wasNear := near

    // Confirmed turning points only. Qualification uses information available now.
    if scaleReady and not na(candidateResistance)
        bool reacted = candidateResistance - close >= pivotATR * minReaction
        bool notBroken = (breakBy == "Close" ? close : high) <= candidateResistance
        if reacted and notBroken and (not filterCreation or (not na(pivotVolume) and pivotVolume >= requiredRV))
            f_add(candidateResistance, false, pivotATR, close, pivotVolume, false, time[confirmationBars], atr[1])
    if scaleReady and not na(candidateSupport)
        bool reacted = close - candidateSupport >= pivotATR * minReaction
        bool notBroken = (breakBy == "Close" ? close : low) >= candidateSupport
        if reacted and notBroken and (not filterCreation or (not na(pivotVolume) and pivotVolume >= requiredRV))
            f_add(candidateSupport, true, pivotATR, close, pivotVolume, false, time[confirmationBars], atr[1])

    if useHTF and validHTF and not na(hPivotATR) and hPivotATR > 0
        bool creationVolumeOK = not filterCreation or (not na(hRV) and hRV >= requiredRV)
        if not na(hHighTime) and (na(lastHTFHigh) or hHighTime != lastHTFHigh)
            if not na(hHigh) and hHigh - hClose >= hPivotATR * minReaction and (breakBy == "Close" ? close : high) <= hHigh and creationVolumeOK
                f_add(hHigh, false, hPivotATR, hClose, hRV, true, hHighTime, hDetectATR)
            lastHTFHigh := hHighTime
        if not na(hLowTime) and (na(lastHTFLow) or hLowTime != lastHTFLow)
            if not na(hLow) and hClose - hLow >= hPivotATR * minReaction and (breakBy == "Close" ? close : low) >= hLow and creationVolumeOK
                f_add(hLow, true, hPivotATR, hClose, hRV, true, hLowTime, hDetectATR)
            lastHTFLow := hLowTime
    string eventText = supportBroken or resistanceBroken ? "Break" : supportRetest or resistanceRetest ? "Retest" : supportRejection or resistanceRejection ? "Rejection" : supportTouch or resistanceTouch ? "Touch" : supportApproach or resistanceApproach ? "Approach" : ""
    if str.length(eventText) > 0
        latestEvent := eventText
        latestEventTime := time_close

var table dashboard = table.new(position.top_right, 2, 13, bgcolor=color.new(color.rgb(18, 24, 35), 8), frame_color=color.new(color.gray, 65), frame_width=1)
var table ledger = table.new(position.bottom_right, 5, 21, bgcolor=color.new(color.rgb(18, 24, 35), 8))

if barstate.islast
    float labelGap = math.max(syminfo.mintick * 2, nz(atr, syminfo.mintick) * labelGapATR)
    float nearestSupport = na
    float nearestResistance = na
    float supportDistance = 1e30
    float resistanceDistance = 1e30
    array<int> selected = f_select(close)
    array<int> selectedHistory = array.new_int()
    int selectedBroken = 0
    int selectedExpired = 0
    int historySlots = math.max(0, drawingBudget - array.size(selected))
    if array.size(completed) > 0
        for i = array.size(completed) - 1 to 0
            Level level = array.get(completed, i)
            bool allowedHistory = level.wasBroken ? showBroken and selectedBroken < brokenShown : showExpired and selectedExpired < expiredShown
            if allowedHistory and f_qualifies(level) and array.size(selectedHistory) < historySlots
                array.push(selectedHistory, i)
                if level.wasBroken
                    selectedBroken += 1
                else
                    selectedExpired += 1
        // Free excluded historical objects before allocating any active objects.
        for i = 0 to array.size(completed) - 1
            if not array.includes(selectedHistory, i)
                f_hide(array.get(completed, i))
    if array.size(active) > 0
        // Free excluded live objects too; persistent selected objects are reused.
        for i = 0 to array.size(active) - 1
            if not array.includes(selected, i)
                f_hide(array.get(active, i))
    if array.size(active) > 0
        for i = 0 to array.size(active) - 1
            Level level = array.get(active, i)
            if array.includes(selected, i)
                color tint = level.higherSource ? higherColor : level.isSupport ? supportColor : resistanceColor
                int drawnWidth = higherThick and level.higherSource ? math.min(5, lineWidth + 1) : lineWidth
                if na(level.drawing)
                    level.drawing := line.new(level.stamp, level.price, nz(time_close, time + 1), level.price, xloc=xloc.bar_time, extend=untilBroken ? extend.right : extend.none, color=tint, width=drawnWidth, force_overlay=true)
                else
                    line.set_x2(level.drawing, nz(time_close, time))
                    line.set_color(level.drawing, tint)
                    line.set_width(level.drawing, drawnWidth)
                    line.set_style(level.drawing, line.style_solid)
                if showStrength or (higherTags and level.higherSource)
                    string gradeText = (level.isSupport ? "S · " : "R · ") + (showStrength ? str.tostring(f_grade(level)) + "/5 · " : "") + f_source(level)
                    string details = "Evidence grade: " + gradeText + " (not hold probability)\nBest qualifying close reaction: " + str.tostring(level.reaction, "#.##") + " ATR\nQualifying separated swings: " + str.tostring(level.evidence) + "\nEvidence score: " + str.tostring(f_score(level), "#") + "/100\nSources: " + f_source(level) + "\nPrice rejections: " + str.tostring(level.rejections) + " · visits: " + str.tostring(level.visits)
                    if na(level.strengthLabel)
                        level.strengthLabel := label.new(bar_index + labelOffset, level.price + labelGap, (showPrices ? str.tostring(level.price, format.mintick) + "  " : "") + gradeText, style=label.style_label_lower_left, color=color.new(tint, 85), textcolor=tint, size=size.tiny, force_overlay=true)
                    else
                        label.set_xy(level.strengthLabel, bar_index + labelOffset, level.price + labelGap)
                        label.set_text(level.strengthLabel, (showPrices ? str.tostring(level.price, format.mintick) + "  " : "") + gradeText)
                    label.set_tooltip(level.strengthLabel, details)
                else
                    f_hideLabel(level)
                float distance = math.abs(close - level.price)
                if level.isSupport and distance < supportDistance
                    supportDistance := distance
                    nearestSupport := level.price
                if not level.isSupport and distance < resistanceDistance
                    resistanceDistance := distance
                    nearestResistance := level.price
            else
                f_hide(level)
    // Recent broken history has its own small display budget, independent of live levels.
    int shownBroken = 0
    int shownExpired = 0
    if array.size(completed) > 0
        for i = array.size(completed) - 1 to 0
            Level level = array.get(completed, i)
            if array.includes(selectedHistory, i)
                if level.wasBroken
                    shownBroken += 1
                else
                    shownExpired += 1
                color tint = color.new(level.higherSource ? higherColor : level.isSupport ? supportColor : resistanceColor, completedFade)
                string style = level.wasBroken ? line.style_dotted : line.style_solid
                int drawnWidth = higherThick and level.higherSource ? math.min(5, lineWidth + 1) : lineWidth
                if na(level.drawing)
                    level.drawing := line.new(level.stamp, level.price, level.ended, level.price, xloc=xloc.bar_time, extend=extend.none, color=tint, style=style, width=drawnWidth, force_overlay=true)
                else
                    line.set_x2(level.drawing, level.ended)
                    line.set_extend(level.drawing, extend.none)
                    line.set_color(level.drawing, tint)
                    line.set_style(level.drawing, style)
                    line.set_width(level.drawing, drawnWidth)
            else
                f_hide(level)
    // Label only the nearest active level per original role to keep the chart clean.
    if showPrices and not showStrength and not na(nearestResistance)
        string caption = "R  " + str.tostring(nearestResistance, format.mintick)
        if na(resistanceLabel)
            resistanceLabel := label.new(bar_index + labelOffset, nearestResistance + labelGap, caption, style=label.style_label_lower_left, color=color.new(resistanceColor, 85), textcolor=resistanceColor, size=size.small, force_overlay=true)
        else
            label.set_xy(resistanceLabel, bar_index + labelOffset, nearestResistance + labelGap)
            label.set_text(resistanceLabel, caption)
    else if not na(resistanceLabel)
        label.delete(resistanceLabel)
        resistanceLabel := na
    if showPrices and not showStrength and not na(nearestSupport)
        string caption = "S  " + str.tostring(nearestSupport, format.mintick)
        if na(supportLabel)
            supportLabel := label.new(bar_index + labelOffset, nearestSupport + labelGap, caption, style=label.style_label_lower_left, color=color.new(supportColor, 85), textcolor=supportColor, size=size.small, force_overlay=true)
        else
            label.set_xy(supportLabel, bar_index + labelOffset, nearestSupport + labelGap)
            label.set_text(supportLabel, caption)
    else if not na(supportLabel)
        label.delete(supportLabel)
        supportLabel := na

    int activeSupportCount = 0
    int activeResistanceCount = 0
    if array.size(active) > 0
        for i = 0 to array.size(active) - 1
            Level level = array.get(active, i)
            if level.isSupport
                activeSupportCount += 1
            else
                activeResistanceCount += 1
    if dashboardSize != "Hidden"
        string supportText = na(nearestSupport) ? "—" : str.tostring(nearestSupport, format.mintick)
        string resistanceText = na(nearestResistance) ? "—" : str.tostring(nearestResistance, format.mintick)
        array<string> keys = array.from("[CandleChasers]", "Tracked / shown", "Minimum grade / score", "Nearest support", "Nearest resistance", "Higher timeframe", "Live relative volume", "Notification scope", "Last event", "Last event time (UTC)", "Active S / R records", "Drawn live / history / cap", "Display status")
        array<string> values = array.from("S/R 4.1.2", str.tostring(array.size(active)) + " / " + str.tostring(array.size(selected)), str.tostring(minimumStrength) + "/5 · " + str.tostring(minimumScore) + "/100", supportText, resistanceText, not useHTF ? "Off" : validHTF ? sourceTF + " completed data" : "Select a higher timeframe", na(rv) ? "Unavailable" : str.tostring(rv, "#.##") + "x", alertScope, latestEvent, na(latestEventTime) ? "—" : str.format_time(latestEventTime, "MM-dd HH:mm", "UTC"), str.tostring(activeSupportCount) + " / " + str.tostring(activeResistanceCount), str.tostring(array.size(selected)) + " / " + str.tostring(array.size(selectedHistory)) + " / " + str.tostring(drawingBudget), array.size(selected) > 0 ? ranking + " · " + extensionMode : array.size(active) == 0 ? "No live levels: broken, expired or unconfirmed" : "Live levels excluded by filters / price side")
        for row = 0 to 12
            table.cell(dashboard, 0, row, array.get(keys, row), text_color=color.silver, text_size=dashboardText)
            table.cell(dashboard, 1, row, array.get(values, row), text_color=color.white, text_size=dashboardText)
    else
        table.clear(dashboard, 0, 0, 1, 12)
    table.clear(ledger, 0, 0, 4, 20)
    if dashboardSize != "Hidden" and dashboardMode == "Detailed"
        array<string> headers = array.from("Role", "Price", "Grade", "Score", "Source")
        for col = 0 to 4
            table.cell(ledger, col, 0, array.get(headers, col), text_color=color.silver, text_size=dashboardText)
        if array.size(selected) > 0
            for row = 0 to array.size(selected) - 1
                Level level = array.get(active, array.get(selected, row))
                color tint = level.higherSource ? higherColor : level.isSupport ? supportColor : resistanceColor
                array<string> cells = array.from(level.isSupport ? "S" : "R", str.tostring(level.price, format.mintick), str.tostring(f_grade(level)), str.tostring(f_score(level), "#"), f_source(level))
                for col = 0 to 4
                    table.cell(ledger, col, row + 1, array.get(cells, col), text_color=tint, text_size=dashboardText)

alertcondition(supportBroken, "Support broken", "[CandleChasers] Support broken on {{ticker}} {{interval}}. Close: {{close}}.")
alertcondition(resistanceBroken, "Resistance broken", "[CandleChasers] Resistance broken on {{ticker}} {{interval}}. Close: {{close}}.")
alertcondition(supportRetest, "Broken resistance retested as support", "[CandleChasers] Broken resistance retested as support on {{ticker}} {{interval}}.")
alertcondition(resistanceRetest, "Broken support retested as resistance", "[CandleChasers] Broken support retested as resistance on {{ticker}} {{interval}}.")

alertcondition(supportTouch, "Support touch", "[CandleChasers] Qualifying support touch on {{ticker}} {{interval}}.")
alertcondition(resistanceTouch, "Resistance touch", "[CandleChasers] Qualifying resistance touch on {{ticker}} {{interval}}.")
alertcondition(supportRejection, "Support rejection", "[CandleChasers] Qualifying support rejection on {{ticker}} {{interval}}.")
alertcondition(resistanceRejection, "Resistance rejection", "[CandleChasers] Qualifying resistance rejection on {{ticker}} {{interval}}.")
alertcondition(supportApproach, "Approaching support", "[CandleChasers] Approaching qualifying support on {{ticker}} {{interval}}.")
alertcondition(resistanceApproach, "Approaching resistance", "[CandleChasers] Approaching qualifying resistance on {{ticker}} {{interval}}.")
````
