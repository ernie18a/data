<!-- tradingview-pine-id: PUB;d445ebc861f34265bfc151867794aa38 -->
<!-- tradingviewscripts-format: 1 -->
# The Oloid (OWMA) — Oloid Weighted Moving Average

Source: https://www.tradingview.com/script/1AnDnjsz-The-Oloid-OWMA-Oloid-Weighted-Moving-Average/

## Description

The Oloid (OWMA) — Oloid Weighted Moving Average

WHAT IT IS

The Oloid is a trend-following indicator built on the geometry of the oloid — a three-dimensional solid discovered by Paul Schatz in 1929. The oloid is the convex hull of two perpendicular circles, each passing through the center of the other. It is one of the few known solids that develops (unrolls) its entire surface onto a plane while rolling, touching every point of its surface exactly once per cycle — no point is missed, no point repeats.

This indicator translates that geometry into a novel, non-linear moving average: the Oloid Weighted Moving Average (OWMA).

MATHEMATICAL LEGACY

OWMA belongs to the lineage of geometry-inspired data analysis tools:

• Fourier Transform (1822) — decomposition of a signal into circular components.
• Wavelet Transform (1980s) — multi-scale analysis with shaped basis functions.
• OWMA (2026) — weighting of time-series data using the developable surface of a three-dimensional geometric solid.

The key innovation: using the coupling of two perpendicular circles as the weighting kernel. Fourier uses single circles. Wavelets use scaled and shifted basis functions. OWMA uses the interaction of two perpendicular oscillating systems to determine the informational value of each data point.

THE CORE IDEA

Every classic moving average weights bars by time: linearly (WMA), exponentially (EMA), or adaptively by a single volatility measure (KAMA, VIDYA). OWMA weights bars by their position on the oloid's developable surface, determined by two coupled market cycles simultaneously:

• Circle A — Momentum cycle. Each bar's local directional efficiency (a 4-bar Kaufman-style efficiency ratio) maps to an angle on the first circle.
• Circle B — Volatility cycle. Each bar's range relative to the recent average range maps to an angle on the second circle.

The oloid's center-of-mass height at the coupled position (alpha, gamma) is:

h(alpha, gamma) = h_min + dh * (0.5 + 0.5 * sin(2*alpha) * sin(2*gamma))

where h_max = sqrt(2)/2 and h_min = 3*sqrt(3)/8 are the exact geometric height extremes of a rolling oloid. The bar's weight is the INVERSE of this height:

• Bars at turning points (height minimum — the moment the rolling oloid "tips over") receive maximum weight. These are transition bars: pivots, regime changes, structure shifts.
• Bars during smooth rolling (height maximum) receive minimum weight. These are continuation bars, carrying less new information.

The result is a moving average that emphasizes market turning points and de-emphasizes continuation — behavior no linear, exponential, or single-factor adaptive MA produces, because the weight depends on the coupled state of two independent cycles, not on time or one factor alone.

HOW IT WORKS ON THE CHART

1. Oloid Line (center). The visible line does not plot OWMA directly — it tracks OWMA with adaptive speed derived from the oloid's current height. Two refinements prevent lag during strong trends:
— Velocity Lead: when adaptation is slow, the line aims where OWMA is going (target = OWMA + delta-OWMA * lead), like the contact point of an oloid rolling down a slope leading its center of mass.
— Adapt Floor: a strong trend (high efficiency ratio) guarantees a minimum tracking speed — gravity keeps the oloid rolling even at maximum height.

2. Oloid Field. ATR-based dynamic bands around the center line. The field narrows as trend efficiency rises (trending markets get a tighter channel) and widens in chop. Field color reflects price position: green above, red below, gray inside.

3. Energy metric (Data Window / dashboard). Energy = efficiency ratio * range regularity. It measures whether the oloid is "rolling" — whether the market has coherent, structured motion. Energy Up / Energy Down split it by the Oloid Line's slope direction. These values are not drawn as chart lines — they live in the dashboard and the Data Window, where the Pine Screener can also read them.

4. Slope Engine. Tracks the slope of RangeReg Bull% — the percentage of bars in the window that made new highs. The slope is classified as RISING / FLAT / FALLING. A flat-to-rising transition marks "momentum awakening": after a structural pause, bullish breadth resumes.

SIGNALS — TWO INDEPENDENT ENTRY ENGINES

• LONG-SLOPE (Pure Slope — enabled by default): RRB slope transitions flat-to-rising while close is above the Oloid Center. Catches "momentum awakening" — trend starts after a structural pause.
• LONG (OWMA Cross — off by default, optional): close crosses above the upper field boundary, with all filters passing. A dedicated filter blocks these entries while the slope is falling ("tired trend" protection). Enable this engine if you want additional breakout-style entries alongside the slope engine.
• SHORT / CLOSE: mirror logic below the field (part of the OWMA Cross engine, so they appear only when that engine is enabled); in "Long Only" mode a short signal closes the long instead. With the default configuration, positions are closed by the selected exit mode's stop.

Signal filters: an Energy window (default 0–20% — signals are suppressed when momentum is overheated), an optional minimum efficiency ratio, and a cooldown between signals.

EXIT MODES (selectable)

• Wide ATR (default, x3.5): a loose trailing stop that lets winners develop and captures more of the favorable excursion.
• ATR Trail (x2.0): classic tighter trail.
• Slope+Stop: exits when the RRB slope turns falling (momentum exhausting), with a fixed protective stop as the floor.
• Hybrid: fixed protective stop for the first N bars, then an ATR trail activates.

The current trailing stop is plotted as a step-line while a position is open.

HOW TO USE IT

1. Add to any symbol and timeframe. Defaults (Radius 21, Long Only, Pure Slope engine, Wide ATR exit) are a reasonable starting point for daily charts of trending assets.
2. Watch the dashboard (top right): Circle A (trend efficiency), Circle B (volatility state), Energy with its window check, Field width and direction, Slope state, and the active stop level.
3. Higher-quality entries tend to occur when: Energy is in the lower half of the window and rising, volatility (Circle B) is below ~110%, and the Field is narrow or narrowing (squeeze conditions).
4. Pine Screener: the "Energy Up Trend" value is exported to the Data Window — filter "Energy Up Trend between 3 and 20" to scan for symbols entering a sustained bullish momentum phase.
5. Alerts are provided for both entry engines, exits, the Bullish Trend Zone, and slope-state transitions (diagnostic).

INPUTS SUMMARY

• Oloid Geometry: Radius (base period of both circles, default 21), Circle Coupling (0.5 = the oloid's natural geometry), Meander Intensity.
• Signals: mode (Long Only / Short Only / Both), Energy window, minimum ER, cooldown.
• Slope Engine: enable/disable each engine, falling-slope filter, slope smoothing and flat threshold.
• Exit Mode: the four modes described above with their parameters.

NOTES

• The indicator is self-contained: all mathematics is computed from the oloid's parametric geometry (height function, surface development, coupling), plus standard building blocks (ATR, efficiency ratio, SMA/EMA smoothing).
• A square-root recency decay is combined with the oloid surface weight, so the total weighting respects both surface position and recency.
• Signals are generated on bar close and do not repaint: the position state machine uses confirmed values only.
• This is a technical analysis tool, not financial advice. Test on your instruments and timeframes before using signals in live trading.

---

## Source Code

````pine
//@version=6
indicator("The Oloid (OWMA) — Oloid Weighted Moving Average", shorttitle="Oloid", overlay=true, max_labels_count=50)

g1 = "Oloid Geometry"
int   i_radius    = input.int(21, "Radius (Base Period)", minval=5, maxval=200, group=g1, tooltip="The fundamental period r of the Oloid's circles.")
float i_coupling  = input.float(0.5, "Circle Coupling", minval=0.0, maxval=1.0, step=0.1, group=g1, tooltip="How strongly the two circles influence each other. 0.5 = Oloid's natural geometry.")
float i_meander   = input.float(1.0, "Meander Intensity", minval=0.1, maxval=3.0, step=0.1, group=g1, tooltip="Controls how much the Oloid line meanders vs follows price.")

g2 = "Display"
bool  i_showLine  = input.bool(true, "Show Oloid Line", group=g2)
bool  i_showOWMA  = input.bool(false, "Show OWMA (target line)", group=g2, tooltip="Shows the Oloid Weighted Moving Average — the target that the Oloid Line follows. OWMA is the true oloid-weighted price; the Oloid Line meanders toward it with adaptive speed.")
bool  i_showFill  = input.bool(true, "Show Oloid Field", group=g2)
bool  i_showSig   = input.bool(true, "Show Signals", group=g2)
bool  i_showDash  = input.bool(true, "Show Dashboard", group=g2)
string i_dashSize = input.string("Normal", "Dashboard Size", options=["Tiny","Small","Normal","Large"], group=g2)

g3 = "Signals"
string i_sigMode  = input.string("Long Only", "Signal Mode", options=["Long Only","Short Only","Both"], group=g3, tooltip="Long Only: LONG entries + SHORT as exit signal. Best for trending/crypto.\nShort Only: SHORT entries + LONG as exit.\nBoth: independent LONG and SHORT.")
float i_energyMin = input.float(0.0, "Min Energy %", minval=0.0, maxval=30.0, step=1.0, group=g3, tooltip="Minimum energy to allow signals. 0% captures early trend entries. Use visual scoring (Vol<110, Field narrowing, Energy rising) to assess signal quality.")
float i_energyMax = input.float(20.0, "Max Energy %", minval=0.0, maxval=50.0, step=1.0, group=g3, tooltip="Maximum energy — above this, momentum is overheated, signals suppressed. 0 = disabled.")
float i_erMin     = input.float(0.0, "Min ER (Circle A) %", minval=0.0, maxval=50.0, step=5.0, group=g3, tooltip="Minimum Efficiency Ratio to allow signals. 0 = disabled.")
int   i_cooldown  = input.int(5, "Signal Cooldown", minval=1, maxval=30, group=g3)
float i_atrMult   = input.float(2.0, "ATR Stop Multiplier", minval=1.0, maxval=5.0, step=0.5, group=g3, tooltip="Used only by the 'ATR Trail' exit mode.")

g4 = "Slope Engine"
bool  i_engineOWMA   = input.bool(false, "(1) OWMA Cross Engine", group=g4, tooltip="Close crosses above the upper field boundary for LONG. Disabling leaves only the Slope engine.")
bool  i_engineSlope  = input.bool(true,  "(2) Pure Slope Engine", group=g4, tooltip="RRB slope transitions flat-to-rising AND close > Oloid Center. Tagged 'LONG-SLOPE'. Fires independently of the OWMA cross — catches momentum awakening events.")
bool  i_filterFalling = input.bool(true, "(B) Block OWMA Cross when slope falling", group=g4, tooltip="Filters the OWMA Cross engine only — the Pure Slope engine is immune. Removes 'tired trend' entries that fire after momentum has already peaked.")
int   i_slopeSmooth  = input.int(1, "Slope Smoothing (bars)", minval=1, maxval=10, group=g4, tooltip="SMA window for slope calculation. Default 1 — slope must react instantly; smoothing >1 adds lag.")
float i_flatThr      = input.float(2.0, "Flat threshold % per window", minval=0.5, maxval=10.0, step=0.5, group=g4, tooltip="If RRB change over the smoothing window is between ±X%, state is FLAT. Larger value = stricter rising/falling classification.")

g5 = "Exit Mode"
string i_exitMode = input.string("Wide ATR", "Exit Strategy", options=["ATR Trail", "Wide ATR", "Slope+Stop", "Hybrid"], group=g5, tooltip="Wide ATR (default, x3.5): looser trail, captures more of the favorable excursion | ATR Trail (x2.0): tighter classic trail | Slope+Stop: exit on RRB falling + protective stop | Hybrid: protective stop + ATR trail after a delay")
float i_wideMult  = input.float(3.5, "Wide ATR multiplier", minval=1.5, maxval=8.0, step=0.5, group=g5, tooltip="Used by 'Wide ATR' mode. Larger = looser trail, more upside capture but bigger giveback.")
float i_protectStop = input.float(12.0, "Protective Stop %", minval=3.0, maxval=30.0, step=1.0, group=g5, tooltip="Used by Slope+Stop and Hybrid modes. Hard stop below entry as a protective floor.")
int   i_hybridDelay = input.int(5, "Hybrid: bars before ATR trail activates", minval=1, maxval=30, group=g5, tooltip="Hybrid mode only. First N bars after entry use only the fixed % protective stop. After N bars, the ATR trail also activates.")
float i_hybridATR = input.float(2.5, "Hybrid: ATR multiplier after delay", minval=1.5, maxval=6.0, step=0.5, group=g5, tooltip="Hybrid mode only. ATR trail multiplier used after the bar delay.")
int   i_slopeMinBars = input.int(3, "Slope+Stop: min bars before slope exit", minval=1, maxval=30, group=g5, tooltip="Slope+Stop mode only. Wait N bars after entry before slope=falling can trigger an exit.")

float dirMove   = math.abs(close - close[i_radius])
float totalMove = math.sum(math.abs(close - close[1]), i_radius)
float er_A      = totalMove > 0 ? dirMove / totalMove : 0

float trendDir  = close > close[i_radius] ? 1.0 : -1.0
float alpha     = trendDir * er_A * (2.0 * math.pi / 3.0)

float xA = math.sin(alpha)
float yA = -math.cos(alpha)

float atrNow  = ta.atr(i_radius)
float atrSlow = ta.atr(i_radius * 3)
float volRatio = atrSlow > 0 ? atrNow / atrSlow : 1.0

float hhChange = math.max(math.sign(ta.change(ta.highest(i_radius))), 0)
float llChange = math.max(math.sign(ta.change(ta.lowest(i_radius)) * -1), 0)
float rangeReg = ta.sma(hhChange > 0 or llChange > 0 ? 1.0 : 0.0, i_radius)

float rangeReg_bull = ta.sma(hhChange > 0 ? 1.0 : 0.0, i_radius)
float rrb_pct = rangeReg_bull * 100
float rrb_now  = ta.sma(rrb_pct, i_slopeSmooth)
float rrb_prev = ta.sma(rrb_pct, i_slopeSmooth)[i_slopeSmooth]
float rrb_slope = rrb_now - rrb_prev
int slopeState = rrb_slope > i_flatThr ? 1 : rrb_slope < -i_flatThr ? -1 : 0

float gamma = (volRatio - 1.0) * math.pi * rangeReg

float yB = -math.cos(gamma)
float zB = math.sin(gamma)

float v = i_coupling
float oloid_x = xA * (1.0 - v)
float oloid_y = yA * (1.0 - v) + yB * v
float oloid_z = zB * v

float oloid_energy = math.sqrt(oloid_x * oloid_x + oloid_y * oloid_y + oloid_z * oloid_z)
float sqrt3 = math.sqrt(3.0)
float oloid_norm = oloid_energy / sqrt3

float h_max = math.sqrt(2.0) / 2.0
float h_min = 3.0 * math.sqrt(3.0) / 8.0
float delta_h = h_max - h_min

float height_phase = math.sin(2.0 * alpha) * math.sin(2.0 * gamma)
float oloid_height = h_min + (h_max - h_min) * (0.5 + 0.5 * height_phase)

float adapt_raw = 1.0 - (oloid_height - h_min) / delta_h
float adapt_oloid = math.max(0.01, math.min(1.0, adapt_raw * i_meander * oloid_norm))
float adapt_floor = 0.05 + er_A * 0.3
float adapt = math.max(adapt_floor, adapt_oloid)

float avgRange = ta.sma(high - low, i_radius)

float o_sumW = 0.0
float o_sumWP = 0.0

for i = 0 to i_radius - 1
    float localDir = math.abs(nz(close[i]) - nz(close[i + 4], close[i]))
    float localTotal = math.abs(nz(close[i]) - nz(close[i + 1])) + math.abs(nz(close[i + 1]) - nz(close[i + 2])) + math.abs(nz(close[i + 2]) - nz(close[i + 3])) + math.abs(nz(close[i + 3]) - nz(close[i + 4]))
    float localER = localTotal > 0 ? localDir / localTotal : 0
    float localTrendDir = nz(close[i]) > nz(close[i + 4], close[i]) ? 1.0 : -1.0
    float alpha_i = localTrendDir * localER * (2.0 * math.pi / 3.0)

    float localRange = nz(high[i]) - nz(low[i])
    float localVolRatio = avgRange > 0 ? localRange / avgRange : 1.0
    float gamma_i = (localVolRatio - 1.0) * math.pi

    float h_phase_i = math.sin(2.0 * alpha_i) * math.sin(2.0 * gamma_i)
    float h_i = h_min + delta_h * (0.5 + 0.5 * h_phase_i)

    float h_normalized = (h_i - h_min) / delta_h
    float oloidWeight = 1.5 - h_normalized

    float recency = math.pow(1.0 - float(i) / float(i_radius), 0.5)

    float finalWeight = oloidWeight * recency
    o_sumWP += nz(close[i]) * finalWeight
    o_sumW += finalWeight

float oloidWMA = o_sumW > 0 ? o_sumWP / o_sumW : close

var float oloidLine = na
float owma_velocity = oloidWMA - nz(oloidWMA[1], oloidWMA)
float lead_factor = 3.0 * (1.0 - adapt)
float owma_target = oloidWMA + owma_velocity * lead_factor
oloidLine := nz(oloidLine[1], close) + adapt * (owma_target - nz(oloidLine[1], close))

float atrField = ta.atr(i_radius)
float trendNarrow = 1.0 - er_A * 0.5
float fieldWidth = atrField * 0.5 * i_meander * trendNarrow

float oloidUpper = oloidLine + fieldWidth
float oloidLower = oloidLine - fieldWidth

float fieldPct = oloidLine != 0 ? (oloidUpper - oloidLower) / oloidLine * 100 : 0
float fieldPct5 = fieldPct[5]
bool fieldNarrowing = fieldPct < nz(fieldPct5, fieldPct)
bool fieldWidening = fieldPct > nz(fieldPct5, fieldPct)

float fieldRank = ta.percentile_nearest_rank(fieldPct, 63, 50)
bool fieldAtLow = fieldPct <= ta.percentile_nearest_rank(fieldPct, 63, 10)
bool fieldAtHigh = fieldPct >= ta.percentile_nearest_rank(fieldPct, 63, 90)

float energy = er_A * rangeReg
float energySmooth = ta.ema(energy, i_radius)

float energyMom = energySmooth - energySmooth[5]
bool energyRising = energyMom > 0
bool energyFalling = energyMom < 0

bool oloidBullish = oloidLine > oloidLine[1]
float energyUp   = oloidBullish ? energySmooth * 100 : 0.0
float energyDown = oloidBullish ? 0.0 : energySmooth * 100

var int eupStreak = 0
eupStreak := energyUp > 0 ? eupStreak + 1 : 0

bool energyBaseRising = energySmooth > energySmooth[3]

bool eupRising3 = energyUp > 0 and energyUp > nz(energyUp[3])
bool eupRising5 = energyUp > nz(energyUp[5]) or nz(energyUp[5]) == 0
bool eupAboveMin = energyUp > 1.0
bool eupEstablished = eupStreak >= 3
bool eupTrending = eupRising3 and eupRising5 and eupAboveMin and eupEstablished and energyBaseRising
float energyUpTrend = eupTrending ? energyUp : 0.0

float energyPct = energySmooth * 100
float erPct = er_A * 100

bool phaseCoherent = er_A > 0.03 or rangeReg > 0.2

bool energyAboveMin = i_energyMin == 0 or energyPct >= i_energyMin
bool energyBelowMax = i_energyMax == 0 or energyPct <= i_energyMax
bool energyInWindow = energyAboveMin and energyBelowMax

bool erOK = i_erMin == 0 or erPct >= i_erMin

bool signalAllowed = phaseCoherent and energyInWindow and erOK

var int posState = 0
var int lastSigBar = 0
var int posEntryBar = 0
var float posEntryPrice = 0.0
var float trailStop = na
bool cooled = (bar_index - lastSigBar) >= i_cooldown

bool _crossAbove = ta.crossover(close, oloidUpper)
bool _crossBelow = ta.crossunder(close, oloidLower)

bool _alreadyAbove = close > oloidUpper and close[1] > oloidUpper[1] and posState == 0
bool _alreadyBelow = close < oloidLower and close[1] < oloidLower[1] and posState == 0

bool slopeAllowsOWMA = not i_filterFalling or slopeState != -1

bool longCond = i_engineOWMA and (_crossAbove or _alreadyAbove) and signalAllowed and cooled and slopeAllowsOWMA
bool shortCond = i_engineOWMA and (_crossBelow or _alreadyBelow) and signalAllowed and cooled

bool _slopeFlatToRising = slopeState == 1 and slopeState[1] == 0
bool _aboveCenter = close > oloidLine
bool slopeEntryCond = i_engineSlope and _slopeFlatToRising and _aboveCenter and signalAllowed and cooled and posState == 0 and (i_sigMode == "Long Only" or i_sigMode == "Both")

float atrVal = ta.atr(14)

bool fireLong = false
bool fireShort = false
bool fireSlopeEntry = false
bool closeOnOpposite = false

if i_sigMode == "Long Only"
    fireLong := longCond and posState <= 0
    fireSlopeEntry := slopeEntryCond and not fireLong
    closeOnOpposite := shortCond and posState == 1
if i_sigMode == "Short Only"
    fireShort := shortCond and posState >= 0
    closeOnOpposite := longCond and posState == -1
if i_sigMode == "Both"
    fireLong := longCond and posState <= 0
    fireSlopeEntry := slopeEntryCond and not fireLong
    fireShort := shortCond and posState >= 0

if fireLong
    posState := 1
    posEntryBar := bar_index
    posEntryPrice := close
    lastSigBar := bar_index
    trailStop := close - atrVal * i_atrMult

if fireSlopeEntry
    posState := 1
    posEntryBar := bar_index
    posEntryPrice := close
    lastSigBar := bar_index
    trailStop := close - atrVal * i_atrMult

if fireShort
    posState := -1
    posEntryBar := bar_index
    posEntryPrice := close
    lastSigBar := bar_index
    trailStop := close + atrVal * i_atrMult

if closeOnOpposite
    posState := 0
    lastSigBar := bar_index
    trailStop := na

int barsInPos = posState != 0 ? (bar_index - posEntryBar) : 0
float pctFromEntry = posState != 0 and posEntryPrice > 0 ? (close - posEntryPrice) / posEntryPrice * 100 : 0

if posState == 1
    bool _doExit = false

    if i_exitMode == "ATR Trail"
        float _newStop = close - atrVal * i_atrMult
        if _newStop > trailStop
            trailStop := _newStop
        if close < trailStop
            _doExit := true

    if i_exitMode == "Wide ATR"
        float _newStop = close - atrVal * i_wideMult
        if _newStop > trailStop
            trailStop := _newStop
        if close < trailStop
            _doExit := true

    if i_exitMode == "Slope+Stop"
        if pctFromEntry <= -i_protectStop
            _doExit := true
        else if barsInPos >= i_slopeMinBars and slopeState == -1
            _doExit := true

    if i_exitMode == "Hybrid"
        if pctFromEntry <= -i_protectStop
            _doExit := true
        else if barsInPos >= i_hybridDelay
            float _newStop = close - atrVal * i_hybridATR
            if _newStop > trailStop
                trailStop := _newStop
            if not na(trailStop) and close < trailStop
                _doExit := true

    if _doExit
        posState := 0
        trailStop := na

if posState == -1
    float newStop = close + atrVal * i_atrMult
    if newStop < trailStop
        trailStop := newStop
    if close > trailStop
        posState := 0
        trailStop := na

bool exitLong = posState == 0 and posState[1] == 1
bool exitShort = posState == 0 and posState[1] == -1

color fieldBull = color.new(#00E676, 85)
color fieldBear = color.new(#FF5252, 85)
color fieldNeutral = color.new(#9E9E9E, 90)
color fieldCol = close > oloidUpper ? fieldBull : close < oloidLower ? fieldBear : fieldNeutral

color lineCol = oloidLine > oloidLine[1] ? color.new(#00E676, 10) : color.new(#FF5252, 10)
color bandCol = oloidLine > oloidLine[1] ? color.new(#00E676, 70) : color.new(#FF5252, 70)

pCenter = plot(i_showLine ? oloidLine : na, "Oloid Center", lineCol, 2)
plot(i_showOWMA ? oloidWMA : na, "OWMA", color.new(#58a6ff, 30), 1, plot.style_line)
pUpper = plot(i_showLine ? oloidUpper : na, "Oloid Upper", bandCol, 1)
pLower = plot(i_showLine ? oloidLower : na, "Oloid Lower", bandCol, 1)
fill(pUpper, pLower, i_showFill ? fieldCol : na, title="Oloid Field")

plot(posState != 0 ? trailStop : na, "Stop", posState == 1 ? color.new(#00E676, 40) : color.new(#FF5252, 40), 1, plot.style_stepline_diamond)

plotshape(i_showSig and fireLong, "LONG", shape.labelup, location.belowbar, color.new(#00BFA5, 0), size=size.normal, text="LONG", textcolor=color.white)
plotshape(i_showSig and fireSlopeEntry, "LONG-SLOPE", shape.labelup, location.belowbar, color.new(#7CB342, 0), size=size.normal, text="LONG\nSLOPE", textcolor=color.white)
plotshape(i_showSig and fireShort, "SHORT", shape.labeldown, location.abovebar, color.new(#FF6D00, 0), size=size.normal, text="SHORT", textcolor=color.white)
plotshape(i_showSig and closeOnOpposite, "CLOSE", shape.xcross, location.abovebar, color.new(#FFC107, 0), size=size.small, text="CLOSE", textcolor=color.new(#FFC107, 0))
plotshape(i_showSig and exitLong and not closeOnOpposite, "×", shape.xcross, location.abovebar, color.new(#FFC107, 40), size=size.tiny)
plotshape(i_showSig and exitShort and not closeOnOpposite, "×", shape.xcross, location.belowbar, color.new(#FFC107, 40), size=size.tiny)

barcolor(fireLong ? #00E676 : fireSlopeEntry ? #7CB342 : fireShort ? #FF5252 : na)

float dbg_circleA = er_A * 100
float dbg_circleB = volRatio * 100
float dbg_energy = energySmooth * 100
float dbg_rangeReg = rangeReg * 100
float owmaGap = oloidWMA != 0 ? (close - oloidWMA) / oloidWMA * 100 : 0

plot(dbg_circleA, "Circle A (ER%)", color.new(#1D9E75, 100), display=display.data_window)
plot(dbg_circleB, "Circle B (Vol%)", color.new(#D85A30, 100), display=display.data_window)
plot(dbg_energy, "Energy%", color.new(#7F77DD, 100), display=display.data_window)
plot(energyUp, "Energy Up%", color.new(#00E676, 100), display=display.data_window)
plot(energyDown, "Energy Down%", color.new(#FF5252, 100), display=display.data_window)
plot(energyUpTrend, "Energy Up Trend", color.new(#00E676, 100), display=display.data_window)
plot(dbg_rangeReg, "RangeReg%", color.new(#d29922, 100), display=display.data_window)
plot(owmaGap, "Surface Gap%", color.new(#58a6ff, 100), display=display.data_window)
plot(fieldPct, "Field Width%", color.new(#c9d1d9, 100), display=display.data_window)
plot(rrb_pct, "RangeReg Bull%", color.new(#7CB342, 100), display=display.data_window)
plot(rrb_slope, "RRB Slope", color.new(#7CB342, 100), display=display.data_window)
plot(slopeState, "Slope State (-1/0/1)", color.new(#7CB342, 100), display=display.data_window)

if i_showDash and barstate.islast
    var table d = table.new(position.top_right, 2, 10, bgcolor=color.new(#0d1117, 5), border_color=color.new(#30363d, 40), border_width=1, frame_color=color.new(#21262d, 20), frame_width=2)
    sz = i_dashSize == "Tiny" ? size.tiny : i_dashSize == "Small" ? size.small : i_dashSize == "Large" ? size.large : size.normal

    table.cell(d, 0, 0, "◎", text_color=#58a6ff, text_size=sz, bgcolor=color.new(#161b22, 0))
    table.cell(d, 1, 0, "OLOID", text_color=#58a6ff, text_size=sz, bgcolor=color.new(#161b22, 0))

    color cA = er_A > 0.3 ? #3fb950 : er_A > 0.15 ? #d29922 : #8b949e
    table.cell(d, 0, 1, "Circle A", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 1, str.tostring(erPct, "#.#") + "%" + (erOK ? " ✓" : " ✗"), text_color=cA, text_size=sz)

    color cB = volRatio > 1.2 ? #f85149 : volRatio > 0.8 ? #d29922 : #3fb950
    table.cell(d, 0, 2, "Circle B", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 2, str.tostring(volRatio, "#.##") + "x vol", text_color=cB, text_size=sz)

    color eCol = energyInWindow ? (energyRising ? #3fb950 : #d29922) : #f85149
    table.cell(d, 0, 3, "Energy", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 3, str.tostring(energyPct, "#.#") + "% [" + str.tostring(i_energyMin, "#") + "-" + str.tostring(i_energyMax, "#") + "]" + (energyInWindow ? " ✓" : " ✗"), text_color=eCol, text_size=sz)

    color phCol = signalAllowed ? #3fb950 : #f85149
    table.cell(d, 0, 4, "Signal", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 4, signalAllowed ? "Ready ✓" : "Blocked ✗", text_color=phCol, text_size=sz)

    string fieldDir = fieldNarrowing ? "◀" : fieldWidening ? "▶" : "="
    string fieldState = fieldAtLow ? "squeeze" : fieldAtHigh ? "wide" : fieldPct < 2.5 ? "narrow" : fieldPct < 5 ? "normal" : "wide"
    color fieldQCol = (fieldNarrowing and fieldPct < 3) ? #3fb950 : (fieldNarrowing) ? #58a6ff : (fieldWidening and fieldPct > 5) ? #f85149 : #d29922
    table.cell(d, 0, 5, "Field", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 5, str.tostring(fieldPct, "#.#") + "% " + fieldDir + " " + fieldState, text_color=fieldQCol, text_size=sz)

    table.cell(d, 0, 6, "Surface", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 6, str.tostring(owmaGap, "#.##") + "% gap", text_color=math.abs(owmaGap) < 0.5 ? #3fb950 : #d29922, text_size=sz)

    color pc = posState == 1 ? #3fb950 : posState == -1 ? #f85149 : #8b949e
    table.cell(d, 0, 7, "Position", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 7, (posState == 1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT") + " [" + i_sigMode + "]", text_color=pc, text_size=sz)

    string slopeLbl = slopeState == 1 ? "▲ rising" : slopeState == -1 ? "▼ falling" : "─ flat"
    color slopeCol = slopeState == 1 ? #3fb950 : slopeState == -1 ? #f85149 : #8b949e
    table.cell(d, 0, 8, "Slope", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 8, slopeLbl + " (" + str.tostring(rrb_pct, "#.#") + "%)", text_color=slopeCol, text_size=sz)

    table.cell(d, 0, 9, "Stop", text_color=#8b949e, text_size=sz)
    table.cell(d, 1, 9, not na(trailStop) ? str.tostring(trailStop, format.mintick) : "—", text_color=#d29922, text_size=sz)

alertcondition(fireLong, title="◎ Oloid LONG", message="Oloid: LONG — price crossed above Oloid field. {{ticker}} {{interval}} @ {{close}}")
alertcondition(fireSlopeEntry, title="◎ Oloid LONG-SLOPE", message="Oloid: LONG-SLOPE — RRB slope flat→rising + close above Oloid Center (momentum awakening). {{ticker}} {{interval}} @ {{close}}")
alertcondition(fireLong or fireSlopeEntry, title="◎ Oloid Any LONG", message="Oloid: LONG entry (any engine). {{ticker}} {{interval}} @ {{close}}")
alertcondition(fireShort, title="◎ Oloid SHORT", message="Oloid: SHORT — price crossed below Oloid field. {{ticker}} {{interval}} @ {{close}}")
alertcondition(exitLong or exitShort, title="◎ Oloid Exit", message="Oloid: Position closed. {{ticker}} {{interval}} @ {{close}}")
alertcondition(eupTrending and not eupTrending[1], title="◎ Bullish Trend Zone", message="Oloid: Bullish Trend Zone started — Energy Up rising sustainably. {{ticker}} {{interval}} @ {{close}}")

bool _slopeToRising  = slopeState == 1 and slopeState[1] != 1
bool _slopeToFalling = slopeState == -1 and slopeState[1] != -1
alertcondition(_slopeToRising,  title="◎ Slope → Rising",  message="Oloid: RRB slope turned RISING (momentum forming). {{ticker}} {{interval}} @ {{close}}")
alertcondition(_slopeToFalling, title="◎ Slope → Falling", message="Oloid: RRB slope turned FALLING (momentum exhausting). {{ticker}} {{interval}} @ {{close}}")
````
