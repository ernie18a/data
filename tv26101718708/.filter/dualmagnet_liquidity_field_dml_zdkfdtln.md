# Dual-Magnet Liquidity Field [DML]

- url: https://www.tradingview.com/script/zDKFdtlN-Dual-Magnet-Liquidity-Field-DML/
- type: indicator
- pine_id: PUB;a746d593529346039f34a8c73d22642e
- version: 1.0

## Description

[b]📊 Dual-Magnet Liquidity Field [DML][/b]
[i]By PhenLabs | Pine Script v6[/i]

https://www.tradingview.com/x/LEeTRved/

The Dual-Magnet Liquidity Field tracks the strongest upside liquidity target and the strongest downside liquidity target at the same time, then converts that competition into a live directional tension model.

Instead of treating every swing high or swing low equally, DML scores each candidate using distance, volume, recency, touch count, and range position. The result is a dual-sided liquidity map that shows where price is statistically being pulled, whether one side is dominant, or whether the market is compressing into a high-tension coil.

DML is built for traders who want a cleaner read on directional liquidity pressure without relying on lagging trend overlays. It is especially useful when price is moving between obvious pools, when both sides are loaded, or when one side starts to decisively overpower the other.

[b]Points of Innovation[/b]
[list]
[*]Simultaneously tracks the strongest upside and downside liquidity magnets instead of forcing a single-target view.
[*]Uses a weighted probability engine that ranks confirmed swing levels by distance, volume, recency, retest density, and range location.
[*]Normalizes each side’s raw score into a 0-100 tension reading against its own historical range.
[*]Converts both tensions into a live dominance ratio where upside % and downside % always sum to 100.
[*]Identifies two distinct states: directional bias when one side clearly dominates, and coil conditions when both sides are strong but balanced.
[*]Visualizes the market as an animated dual-sided field with magnet labels, field lines, zone boxes, and a compact live gauge.
[/list]

[b]Core Components[/b]
[list]
[*][b]Swing Magnet Engine:[/b] Detects confirmed pivot highs and pivot lows, then stores them as active liquidity candidates on both sides of price.
[*][b]Candidate Maintenance Logic:[/b] Tracks touches, removes stale levels, and deletes magnets once they are decisively swept beyond an ATR-based mitigation threshold.
[*][b]Probability Scoring Model:[/b] Ranks every valid candidate with a weighted composite score built from five normalized factors.
[*][b]Tension Engine:[/b] Scales the strongest raw score on each side into a 0-100 pull reading based on its own recent history.
[*][b]Dominance Model:[/b] Converts upside tension and downside tension into a proportional control metric that expresses directional ownership.
[*][b]Signal Layer:[/b] Fires Bull Bias, Bear Bias, and Coil events with cooldown protection to reduce signal spam.
[/list]

[b]Key Features[/b]
[list]
[*]Tracks one best upside magnet above price and one best downside magnet below price at all times.
[*]Only scores levels on the correct side of price, keeping the pull model directionally clean.
[*]ATR-normalized distance logic makes the indicator scale across low-volatility and high-volatility instruments.
[*]Volume factor estimates how much liquidity is likely parked around a pivot relative to baseline participation.
[*]Touch counting increases the score of levels that have been repeatedly tested and may hold stacked stops or resting orders.
[*]Range-position logic boosts upside magnets nearer the upper range and downside magnets nearer the lower range.
[*]Minimum probability threshold filters out weak magnets so only meaningful fields remain visible.
[*]Animated field rendering makes strong directional pull visually obvious on the last bar.
[*]Compact gauge displays upside %, downside %, raw pull, and the live field state in real time.
[*]Built-in alerts support bullish dominance, bearish dominance, and balanced high-tension coil conditions.
[/list]

[b]Visualization[/b]
[list]
[*][b]Upside Magnet:[/b] Plotted above price with a teal field, floating label, and zone box when the upside candidate qualifies.
[*][b]Downside Magnet:[/b] Plotted below price with a red field, floating label, and zone box when the downside candidate qualifies.
[*][b]Field Lines:[/b] Radiating lines show directional attraction from current price toward each active magnet.
[*][b]Curved Boundary:[/b] The outer field contour helps visually frame the pull zone around each target.
[*][b]Magnet Labels:[/b] Each label shows target price, current pull strength, and touch count.
[*][b]Signal Markers:[/b] Triangle markers flag bull or bear bias, while a lightning symbol flags coil conditions.
[*][b]Tension Gauge:[/b] Summarizes live dominance, raw pull, and whether the field is neutral, coiled, bullish, or bearish.
[/list]

[b]Usage Guidelines[/b]

[b]Probability Engine[/b]

[*][b]Swing Lookback:[/b] Controls pivot significance. Higher values produce fewer, stronger swing magnets and confirm later.
[*][b]Max Candidates / Side:[/b] Sets how many recent swing highs and lows remain active in the engine.
[*][b]Min Probability Threshold:[/b] Filters out weak magnets from display and signal logic.
[*][b]Max Candidate Age:[/b] Removes older levels that are no longer relevant to current structure.
[*][b]Touch Tolerance (xATR):[/b] Defines how close price must come to count as a retest.
[*][b]Sweep Tolerance (xATR):[/b] Defines how far price must close beyond a level before that liquidity is considered taken.


[b]Scoring Weights (advanced)</b]

[*][b]Distance Weight:[/b] Increases the impact of proximity. Higher values favor nearer magnets.
[*][b]Volume Weight:[/b] Increases the impact of relative pivot volume.
[*][b]Recency Weight:[/b] Increases the importance of fresher liquidity levels.
[*][b]Touch Weight:[/b] Gives more influence to magnets that have been repeatedly tested.
[*][b]Range-Position Weight:[/b] Adjusts the importance of where the level sits inside the active range.

[b]Tension & Signals[/b]

[*][b]Tension Normalization Window:[/b] Defines the lookback used to scale each side’s raw score into a 0-100 tension reading.
[*][b]Dominance Threshold (%):[/b] Minimum ownership required for one side to trigger a directional bias.
[*][b]Coil Tension Floor:[/b] Minimum tension both sides must hold before a balanced coil can be flagged.
[*][b]Signal Cooldown (bars):[/b] Minimum bars between signals to reduce repetitive triggers.


[b]Visualization</b]

[*][b]Animate Field Lines:[/b] Cycles a pulse through the field for a more dynamic read on directional attraction.
[*][b]Field Lines / Side:[/b] Controls field density.
[*][b]Pulse Period:[/b] Adjusts animation rhythm.
[*][b]Upside / Downside / Coil Colors:[/b] Customizes visual state colors.
[*][b]Show Tension Gauge:[/b] Toggles the compact dashboard.
[*][b]Gauge Position:[/b] Moves the table to the chart corner that best fits your layout.


[b]Best Use Cases[/b]

[*]Identifying which side of nearby liquidity is exerting the strongest pull.
[*]Separating balanced compression from true directional imbalance.
[*]Timing continuation trades when one side clearly dominates the field.
[*]Monitoring mean-reversion or breakout conditions when both sides remain highly charged.
[*]Filtering discretionary structure reads with an objective tension model.
[*]Adding context to sweep-prone instruments such as crypto, indices, futures, and FX.


[b]Limitations[/b]

[*]DML is a liquidity-pressure framework, not a complete trade system.
[*]Signals can lose effectiveness in extremely noisy, thin, or news-driven conditions.
[*]Because pivots are confirmed swings, new candidates appear only after confirmation delay.
[*]Tension is relative to recent score history, so readings should be interpreted in context rather than as absolute prediction certainty.
[*]Strong pull does not guarantee immediate reversal or continuation without price confirmation.


[b]What Makes This Unique[/b]
[*]Most liquidity tools mark pools. DML ranks them.
[*]Most directional tools give a binary bias. DML shows a live 100% split between competing forces.
[*]Most squeeze-style tools detect compression indirectly. DML defines coil as simultaneous high, balanced attraction to both sides.
[*]Most target tools focus on one destination. DML keeps both magnets alive until the field resolves.


[b]How It Works[/b]

[b]1. Process Step 1 — Build the candidate set[/b]
Confirmed swing highs and lows are registered as upside and downside liquidity magnets. Each candidate stores its price, pivot bar, pivot volume, and a running retest count.

[b]2. Process Step 2 — Score the strongest level on each side[/b]
Every valid candidate is scored using five normalized factors: ATR-normalized distance, relative volume, age decay, touch count, and position inside the active range. The highest composite score above price becomes the active upside magnet, and the highest composite score below price becomes the active downside magnet.

[b]3. Process Step 3 — Convert competition into field state[/b]
The strongest raw score on each side is normalized into a 0-100 tension reading. Those tensions are then converted into upside % and downside % dominance values. When both sides are strong but balanced, DML flags a coil. When one side decisively owns the field, DML flags directional bias.

[quote][b]Important Note[/b]
This indicator does not future-leak its swing logic because pivots are only registered after confirmation. For best results, use DML as a liquidity-context engine alongside your execution model, structure confirmation, and risk management.[/quote]

## Source Code

````pine
//@version=6
// =============================================================================
//  Dual-Magnet Liquidity Field [DML]
// -----------------------------------------------------------------------------
//  Tracks two competing liquidity magnets at once:
//    • the highest-probability UPSIDE target (a swing high above price), and
//    • the highest-probability DOWNSIDE target (a swing low below price).
//  A probability engine scores every candidate level, a tension model converts
//  the winning scores into a 0-100 "pull strength" for each side, and a
//  dominance ratio (upside% vs downside%, summing to 100) drives COIL and
//  DIRECTIONAL-BIAS signals. An animated dual-sided field visualises the pull.
// =============================================================================
indicator("Dual-Magnet Liquidity Field [DML]", overlay = true,
     max_lines_count     = 500,
     max_labels_count    = 500,
     max_boxes_count     = 500,
     max_polylines_count = 100)

// =============================================================================
//  INPUTS
// =============================================================================
// --- Probability engine -------------------------------------------------------
grpEng      = "Probability Engine"
swingLen    = input.int(10,    "Swing Lookback",            minval = 2, maxval = 100, group = grpEng, tooltip = "Bars on each side of a pivot. Larger = more significant (and fewer) swing magnets. Pivots are confirmed swingLen bars after they form, so the engine never future-leaks.")
maxCand     = input.int(20,    "Max Candidates / Side",     minval = 3, maxval = 50,  group = grpEng, tooltip = "How many recent swing highs / lows to keep alive as magnet candidates.")
minProb     = input.float(35., "Min Probability Threshold", minval = 0, maxval = 100, group = grpEng, tooltip = "A magnet must read at least this tension (0-100) to qualify for display and signals.")
staleBars   = input.int(500,   "Max Candidate Age (bars)",  minval = 50,              group = grpEng, tooltip = "Candidates older than this are pruned.")
touchTolAtr = input.float(0.25,"Touch Tolerance (xATR)",    minval = 0.01, step = 0.01, group = grpEng, tooltip = "Band around a level (in ATR units) that counts as a test / touch.")
sweepTolAtr = input.float(0.50,"Sweep Tolerance (xATR)",    minval = 0.05, step = 0.05, group = grpEng, tooltip = "Once price CLOSES beyond a level by more than this (ATR units) the level is considered swept / mitigated and the candidate is removed — it can no longer act as a magnet.")

// --- Scoring weights (advanced) ----------------------------------------------
grpW   = "Scoring Weights (advanced)"
wDist  = input.float(1.0, "Distance weight",   minval = 0, step = 0.1, group = grpW, tooltip = "Closer magnets pull harder (ATR-normalised decay).")
wVol   = input.float(1.0, "Volume weight",     minval = 0, step = 0.1, group = grpW, tooltip = "More volume parked at the level = more resting liquidity.")
wTime  = input.float(0.8, "Recency weight",    minval = 0, step = 0.1, group = grpW, tooltip = "Fresher liquidity is more relevant; decays with age.")
wTouch = input.float(1.2, "Touch weight",      minval = 0, step = 0.1, group = grpW, tooltip = "Repeated tests imply stacked stops / liquidity behind the level.")
wPos   = input.float(0.8, "Range-position weight", minval = 0, step = 0.1, group = grpW, tooltip = "Upside targets score higher near range top, downside near range bottom.")

// --- Tension & signals --------------------------------------------------------
grpSig    = "Tension & Signals"
normLen   = input.int(200,   "Tension Normalization Window", minval = 20,              group = grpSig, tooltip = "Lookback used to scale each raw score into a 0-100 tension reading against its OWN history. So '70' literally means 'top 30% of range'.")
domThresh = input.float(65., "Dominance Threshold (%)",      minval = 50, maxval = 95, group = grpSig, tooltip = "A side must own at least this % of total pull to fire a directional-bias signal (opposing side then sits below 100-this).")
coilFloor = input.float(70., "Coil Tension Floor",           minval = 0,  maxval = 100,group = grpSig, tooltip = "Both sides must read at least this tension (0-100) AND be near-balanced to flag a COIL.")
cooldown  = input.int(15,    "Signal Cooldown (bars)",       minval = 0,               group = grpSig, tooltip = "Minimum bars between fired signals to suppress spam.")

// --- Visualization ------------------------------------------------------------
grpVis     = "Visualization"
animate    = input.bool(true,  "Animate Field Lines",  group = grpVis, tooltip = "Cycles a bright pulse through the field lines bar-to-bar to suggest movement toward the magnet.")
nFieldLine = input.int(6,      "Field Lines / Side",   minval = 1, maxval = 12, group = grpVis)
pulseLen   = input.int(8,      "Pulse Period (bars)",  minval = 2, group = grpVis)
upCol      = input.color(#26a69a, "Upside Color",       group = grpVis)
dnCol      = input.color(#ef5350, "Downside Color",     group = grpVis)
coilCol    = input.color(#ffb300, "Neutral / Coil Color", group = grpVis)
showGauge  = input.bool(true,  "Show Tension Gauge",   group = grpVis)
gaugePos   = input.string("Top Right", "Gauge Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = grpVis)

// map the string position input to a Pine position constant
gaugePosition = switch gaugePos
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    => position.top_right

// =============================================================================
//  SERIES HELPERS  (declared before functions so the functions can read them)
// =============================================================================
atr      = ta.atr(14)                       // volatility unit for all scale-free maths
volSma   = ta.sma(volume, 20)               // baseline volume for the volume factor
rangeLen = swingLen * 5                      // window defining the "current range"
hiRange  = ta.highest(high, rangeLen)
loRange  = ta.lowest(low,  rangeLen)

// =============================================================================
//  PERSISTENT STATE
// =============================================================================
// Candidate magnets are stored in parallel arrays (one set per side).
//   *Price  -> the level price
//   *Bar    -> bar_index when the pivot formed (for age / recency)
//   *Vol    -> volume printed on the pivot bar (resting-liquidity proxy)
//   *Touch  -> running count of retests since formation
var array<float> upPrice = array.new<float>()
var array<int>   upBar   = array.new<int>()
var array<float> upVol   = array.new<float>()
var array<int>   upTouch = array.new<int>()

var array<float> dnPrice = array.new<float>()
var array<int>   dnBar    = array.new<int>()
var array<float> dnVol    = array.new<float>()
var array<int>   dnTouch  = array.new<int>()

// Drawing-object pools — everything here is deleted & rebuilt each redraw so we
// never accumulate objects and never hit the per-script drawing limits.
var array<line>     fLines  = array.new<line>()
var array<label>    fLabels = array.new<label>()
var array<box>      fBoxes  = array.new<box>()
var array<polyline> fPolys  = array.new<polyline>()

// =============================================================================
//  PROBABILITY ENGINE
// -----------------------------------------------------------------------------
//  Scores every candidate on the correct side of price and returns the single
//  best magnet for that side. Five normalised (0..1) sub-scores are combined
//  with user weights into a raw composite; the raw composite is later scaled to
//  a 0-100 tension against its own history.
// =============================================================================
scoreSide(array<float> prices, array<int> bars, array<float> vols, array<int> touches, bool isUp) =>
    float bestScore = 0.0
    float bestPrice = na
    int   bestTouch = 0
    int   bestBar   = na
    float rng = math.max(hiRange - loRange, syminfo.mintick)
    int   n   = array.size(prices)
    if n > 0
        for i = 0 to n - 1
            float lvl = array.get(prices, i)
            // only score a target on the correct side of price:
            //   upside magnets must be ABOVE price, downside BELOW price.
            bool correctSide = isUp ? (lvl > close) : (lvl < close)
            if correctSide
                // 1) DISTANCE — closer magnets exert stronger pull (ATR-normalised decay)
                float distAtr = math.abs(lvl - close) / math.max(atr, syminfo.mintick)
                float fDist   = math.exp(-distAtr / 5.0)                              // 0..1
                // 2) VOLUME — liquidity parked at the level vs baseline volume
                float fVol    = math.min(array.get(vols, i) / math.max(volSma, 1), 3.0) / 3.0
                // 3) RECENCY — fresh liquidity is more relevant, decays with age
                float age     = bar_index - array.get(bars, i)
                float fTime   = math.exp(-age / (normLen / 2.0))                      // 0..1
                // 4) TOUCHES — repeated tests imply stacked stops behind the level
                float fTouch  = math.min(array.get(touches, i), 10) / 10.0            // 0..1
                // 5) RANGE POSITION — upside stronger near range top, downside near bottom
                float pos     = (lvl - loRange) / rng                                 // 0..1
                float fPos    = isUp ? pos : (1.0 - pos)
                // weighted composite (range ~0 .. sum-of-weights)
                float raw = wDist * fDist + wVol * fVol + wTime * fTime + wTouch * fTouch + wPos * fPos
                if raw > bestScore
                    bestScore := raw
                    bestPrice := lvl
                    bestTouch := array.get(touches, i)
                    bestBar   := array.get(bars, i)
    [bestScore, bestPrice, bestTouch, bestBar]

// =============================================================================
//  DRAWING HELPERS
// =============================================================================
// Wipe every object created on the previous redraw.
clearDrawings() =>
    if array.size(fLines) > 0
        for i = 0 to array.size(fLines) - 1
            line.delete(array.get(fLines, i))
        array.clear(fLines)
    if array.size(fLabels) > 0
        for i = 0 to array.size(fLabels) - 1
            label.delete(array.get(fLabels, i))
        array.clear(fLabels)
    if array.size(fBoxes) > 0
        for i = 0 to array.size(fBoxes) - 1
            box.delete(array.get(fBoxes, i))
        array.clear(fBoxes)
    if array.size(fPolys) > 0
        for i = 0 to array.size(fPolys) - 1
            polyline.delete(array.get(fPolys, i))
        array.clear(fPolys)

// Render one side of the field: a fan of radiating lines from current price to
// the magnet, a curved polyline tying the fan tips into a "field boundary", a
// zone box at the level, and a floating data label. xloc.bar_time is used for
// all coordinates so the drawing stays stable on live / replay charts.
drawField(float magPrice, float tension, int touches, color baseCol, bool isUp, bool qualified) =>
    if qualified and not na(magPrice)
        int t0 = time
        int dt = na(time[1]) ? 0 : time - time[1]          // ms per bar (for future projection)
        // line WIDTH scales with pull strength (1..4)
        int w = 1 + int(math.round(tension / 33.0))
        // base TRANSPARENCY scales inversely with pull (stronger pull = more opaque)
        int baseT = math.max(10, math.min(85, int(80 - 0.6 * tension)))
        // PULSE — index of the line that is currently "lit", advanced each bar
        int active = animate ? int(bar_index % math.min(nFieldLine, pulseLen)) : -1

        // --- radiating field lines ---
        for j = 0 to nFieldLine - 1
            int   reach  = 3 + j * 2                                   // each line reaches further right
            int   endT   = t0 + reach * dt
            float spread = (j - (nFieldLine - 1) / 2.0) / math.max(nFieldLine, 1)
            float endY   = magPrice + spread * atr * 0.6              // fan the tips around the level
            int   lt     = (animate and j == active) ? math.max(0, baseT - 35) : baseT
            line ln = line.new(t0, close, endT, endY, xloc = xloc.bar_time,
                 width = w, color = color.new(baseCol, lt))
            array.push(fLines, ln)

        // --- field-boundary polyline through the fan tips ---
        array<chart.point> pts = array.new<chart.point>()
        for j = 0 to nFieldLine - 1
            int   reach  = 3 + j * 2
            int   endT   = t0 + reach * dt
            float spread = (j - (nFieldLine - 1) / 2.0) / math.max(nFieldLine, 1)
            float endY   = magPrice + spread * atr * 0.6
            array.push(pts, chart.point.from_time(endT, endY))
        polyline pl = polyline.new(pts, curved = true, xloc = xloc.bar_time,
             line_color = color.new(baseCol, math.min(92, baseT + 12)), line_width = 1)
        array.push(fPolys, pl)

        // --- magnet zone box ---
        box bx = box.new(t0, magPrice + atr * 0.15, t0 + 6 * dt, magPrice - atr * 0.15,
             xloc = xloc.bar_time, border_color = color.new(baseCol, 45),
             bgcolor = color.new(baseCol, math.max(62, baseT)))
        array.push(fBoxes, bx)

        // --- floating magnet label: arrow + price + pull% + touch count ---
        string arrow = isUp ? "▲" : "▼"
        string txt   = arrow + "  " + str.tostring(magPrice, format.mintick) + "\n" +
             str.tostring(tension, "#.0") + "%  •  " + str.tostring(touches) + "T"
        label lb = label.new(t0 + 7 * dt, magPrice, txt, xloc = xloc.bar_time,
             style = isUp ? label.style_label_down : label.style_label_up,
             color = color.new(baseCol, 12), textcolor = color.white, size = size.small)
        array.push(fLabels, lb)

// =============================================================================
//  1) DETECT SWINGS & REGISTER CANDIDATES  (runs every bar — confirmed pivots)
// =============================================================================
ph       = ta.pivothigh(swingLen, swingLen)     // confirmed swing high (na until confirmed)
pl       = ta.pivotlow(swingLen, swingLen)      // confirmed swing low
pivotBar = bar_index - swingLen                  // the bar where the pivot actually occurred

if not na(ph)
    array.push(upPrice, ph)
    array.push(upBar,   pivotBar)
    array.push(upVol,   volume[swingLen])
    array.push(upTouch, 0)
    if array.size(upPrice) > maxCand            // keep only the most recent maxCand
        array.shift(upPrice)
        array.shift(upBar)
        array.shift(upVol)
        array.shift(upTouch)

if not na(pl)
    array.push(dnPrice, pl)
    array.push(dnBar,   pivotBar)
    array.push(dnVol,   volume[swingLen])
    array.push(dnTouch, 0)
    if array.size(dnPrice) > maxCand
        array.shift(dnPrice)
        array.shift(dnBar)
        array.shift(dnVol)
        array.shift(dnTouch)

// =============================================================================
//  2) MAINTAIN CANDIDATES  — count touches, prune swept / stale levels
// =============================================================================
float tol   = atr * touchTolAtr
float sweep = atr * sweepTolAtr

// upside candidates (iterate downward so removals don't shift unseen indices)
int iu = array.size(upPrice) - 1
while iu >= 0
    float lvl     = array.get(upPrice, iu)
    int   bornBar = array.get(upBar,   iu)
    bool  swept   = close > lvl + sweep                       // closed decisively above -> taken
    bool  stale   = (bar_index - bornBar) > staleBars
    if swept or stale
        array.remove(upPrice, iu)
        array.remove(upBar,   iu)
        array.remove(upVol,   iu)
        array.remove(upTouch, iu)
    else if high >= lvl - tol and high <= lvl + tol           // a retest of the level
        array.set(upTouch, iu, array.get(upTouch, iu) + 1)
    iu := iu - 1

// downside candidates
int id = array.size(dnPrice) - 1
while id >= 0
    float lvl     = array.get(dnPrice, id)
    int   bornBar = array.get(dnBar,   id)
    bool  swept   = close < lvl - sweep
    bool  stale   = (bar_index - bornBar) > staleBars
    if swept or stale
        array.remove(dnPrice, id)
        array.remove(dnBar,   id)
        array.remove(dnVol,   id)
        array.remove(dnTouch, id)
    else if low >= lvl - tol and low <= lvl + tol
        array.set(dnTouch, id, array.get(dnTouch, id) + 1)
    id := id - 1

// =============================================================================
//  3) SELECT THE BEST MAGNET PER SIDE
// =============================================================================
[rawUp, upMag, upMagTouch, upMagBar] = scoreSide(upPrice, upBar, upVol, upTouch, true)
[rawDn, dnMag, dnMagTouch, dnMagBar] = scoreSide(dnPrice, dnBar, dnVol, dnTouch, false)

// =============================================================================
//  4) TENSION SCORE (0-100) — scale each raw score against its OWN recent range
//     so "70" means "top 30% of historical pull".
// =============================================================================
rawUpHi   = ta.highest(rawUp, normLen)
rawUpLo   = ta.lowest(rawUp,  normLen)
rawDnHi   = ta.highest(rawDn, normLen)
rawDnLo   = ta.lowest(rawDn,  normLen)
tensionUp = rawUpHi > rawUpLo ? 100.0 * (rawUp - rawUpLo) / (rawUpHi - rawUpLo) : 0.0
tensionDn = rawDnHi > rawDnLo ? 100.0 * (rawDn - rawDnLo) / (rawDnHi - rawDnLo) : 0.0

// a magnet must exist AND clear the minimum probability to qualify
bool upQual   = not na(upMag) and tensionUp >= minProb
bool dnQual   = not na(dnMag) and tensionDn >= minProb
bool bothQual = upQual and dnQual

// =============================================================================
//  5) DOMINANCE RATIO — upside% vs downside%, always summing to 100
// =============================================================================
float total = tensionUp + tensionDn
float upPct = total > 0 ? 100.0 * tensionUp / total : 50.0
float dnPct = 100.0 - upPct

// =============================================================================
//  6) SIGNAL LOGIC + COOLDOWN
// =============================================================================
// COIL  -> both sides high (>= coilFloor) AND near-balanced (neither owns >= domThresh)
bool coilRaw = bothQual and tensionUp >= coilFloor and tensionDn >= coilFloor and math.max(upPct, dnPct) < domThresh
// BIAS  -> one side owns >= domThresh while the other falls below (100 - domThresh)
bool bullRaw = bothQual and upPct >= domThresh and dnPct <= (100.0 - domThresh)
bool bearRaw = bothQual and dnPct >= domThresh and upPct <= (100.0 - domThresh)

// cooldown gate to prevent re-triggering on consecutive bars
var int lastSig = na
bool canFire = na(lastSig) or (bar_index - lastSig) >= cooldown
bool coilSig = coilRaw and canFire
bool bullSig = bullRaw and canFire
bool bearSig = bearRaw and canFire
if coilSig or bullSig or bearSig
    lastSig := bar_index

// =============================================================================
//  7) PERSISTENT, CHEAP HISTORY PLOTS  (no drawing-object cost)
// =============================================================================
plot(upQual ? upMag : na, "Upside Magnet",   color = color.new(upCol, 0), style = plot.style_circles, linewidth = 1)
plot(dnQual ? dnMag : na, "Downside Magnet", color = color.new(dnCol, 0), style = plot.style_circles, linewidth = 1)
plot(upPct, "Upside %",   color = color.new(upCol, 0), display = display.data_window)
plot(dnPct, "Downside %", color = color.new(dnCol, 0), display = display.data_window)
plot(tensionUp, "Tension Up", display = display.data_window)
plot(tensionDn, "Tension Dn", display = display.data_window)

// signal markers — these live on every bar in history without using object pools
plotshape(bullSig, title = "Bull Bias", style = shape.triangleup,   location = location.belowbar, color = upCol,   size = size.small, text = "▲BIAS", textcolor = upCol)
plotshape(bearSig, title = "Bear Bias", style = shape.triangledown, location = location.abovebar, color = dnCol,   size = size.small, text = "▼BIAS", textcolor = dnCol)
plotchar(coilSig,  title = "Coil",      char = "⚡",                location = location.abovebar, color = coilCol, size = size.normal)
bgcolor(coilSig ? color.new(coilCol, 90) : na, title = "Coil background")

// alerts
alertcondition(bullSig, "DML Bull Bias", "DML: upside magnet dominant — bullish pull")
alertcondition(bearSig, "DML Bear Bias", "DML: downside magnet dominant — bearish pull")
alertcondition(coilSig, "DML Coil",      "DML: field coiled — high, balanced tension")

// =============================================================================
//  8) ANIMATED FIELD  — drawn only on the last bar (cleared & rebuilt each tick)
// =============================================================================
if barstate.islast
    clearDrawings()
    drawField(upMag, tensionUp, upMagTouch, upCol, true,  upQual)
    drawField(dnMag, tensionDn, dnMagTouch, dnCol, false, dnQual)

// =============================================================================
//  9) TENSION GAUGE  — compact live dominance / state readout
// =============================================================================
var table gauge   = na
var bool   gMerged = false

if not showGauge and not na(gauge)
    table.delete(gauge)
    gauge   := na
    gMerged := false

if showGauge
    if na(gauge)
        gauge := table.new(gaugePosition, 2, 5, border_width = 1, border_color = color.new(color.gray, 50))
    if barstate.islast
        // current state label + colour
        string stState = "NEUTRAL"
        color  stCol   = color.gray
        if coilRaw
            stState := "⚡ COILED"
            stCol   := coilCol
        else if bullRaw
            stState := "▲ BULL BIAS"
            stCol   := upCol
        else if bearRaw
            stState := "▼ BEAR BIAS"
            stCol   := dnCol

        // row 0 — title (merged across both columns)
        table.cell(gauge, 0, 0, "DUAL-MAGNET FIELD", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 20))
        // row 1 — side headers
        table.cell(gauge, 0, 1, "▲ UPSIDE",   text_color = color.white, text_size = size.small, bgcolor = color.new(upCol, 25))
        table.cell(gauge, 1, 1, "DOWNSIDE ▼", text_color = color.white, text_size = size.small, bgcolor = color.new(dnCol, 25))
        // row 2 — dominance %
        table.cell(gauge, 0, 2, str.tostring(upPct, "#.0") + "%", text_color = color.white, text_size = size.small, bgcolor = color.new(upCol, 55))
        table.cell(gauge, 1, 2, str.tostring(dnPct, "#.0") + "%", text_color = color.white, text_size = size.small, bgcolor = color.new(dnCol, 55))
        // row 3 — raw pull strength
        table.cell(gauge, 0, 3, "Pull " + str.tostring(tensionUp, "#"), text_color = color.white, text_size = size.tiny, bgcolor = color.new(upCol, 80))
        table.cell(gauge, 1, 3, "Pull " + str.tostring(tensionDn, "#"), text_color = color.white, text_size = size.tiny, bgcolor = color.new(dnCol, 80))
        // row 4 — live state (merged)
        table.cell(gauge, 0, 4, stState, text_color = color.white, text_size = size.small, bgcolor = color.new(stCol, 15))

        if not gMerged
            table.merge_cells(gauge, 0, 0, 1, 0)
            table.merge_cells(gauge, 0, 4, 1, 4)
            gMerged := true
````
