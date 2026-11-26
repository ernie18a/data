# Liquidity Sweep Engine [I.M]

- url: https://www.tradingview.com/script/VgUGvxaP/
- type: indicator
- pine_id: PUB;eba0b09921264c3986339daeb1453bc5
- version: 1.0

## Description

# Liquidity Sweep Engine [I.M]
## Adaptive Ribbon · Smart Zones · Confidence Score

---

## OVERVIEW

The Liquidity Sweep Engine ("LSE [I.M]") is a discretionary-trading companion
that unifies four complementary market-structure components into a single
overlay: an **Adaptive Hull Ribbon**, a **BoS / CHoCH state machine**,
**Smart Zones** with a strength score, and a **Confidence Score panel**.

The screenshot below shows everything working together on BTCUSDT (Binance) on
the 30-minute timeframe — refer back to it throughout the description, since
each section refers to the same chart.

📊 **Live example chart:** 

https://www.tradingview.com/x/hiK8QoQs/

---

## WHAT YOU SEE ON THE CHART

Looking at the example image, from left to right and bottom to top:

- The **blue / purple ribbon** that snakes through the candles is the Adaptive
  Hull Ribbon. Blue means slope-up (bullish momentum), purple means slope-down
  (bearish momentum). The colour change marks where short-term momentum flips.
- Each **"BoS ▲"** or **"BoS ▼"** label at a dashed horizontal line is a
  *Break of Structure* — the moment price closed past an unbroken swing high
  (▲) or low (▼) **in the same direction as the existing trend**.
- Each **"CHoCH ▲"** or **"CHoCH ▼"** label is a *Change of Character* —
  price broke a pivot **against** the current trend, flipping the trend state.
  In the example, "CHoCH ▼" near the top is what told us the bullish leg was
  ending; the BoS ▼ chain that follows is the new bearish trend confirming
  itself.
- The **purple boxes extending to the right** are bearish Smart Zones (created
  on bearish breaks). The **blue box** lower on the chart is a bullish Smart
  Zone. Each zone is anchored to the origin candle of the move that produced
  the break.
- The **EARLY** labels (small flash icons) print the first time price taps a
  non-mitigated zone — a heads-up that an order-block area is being tested.
- The **panel in the bottom-right corner** is the Confidence Score: a 0–100
  reading with a letter grade (D → A+), plus six rows showing the components
  (Trend, Momentum, Volatility, Structure, Ribbon, active Zones).

The rest of the description explains how each of these pieces is computed.

---

## WHAT MAKES IT ORIGINAL

LSE [I.M] is not a wrapper around `ta.pivothigh` / `ta.pivotlow`. The
originality is in how four independent ideas are combined and computed:

**Adaptive Hull Ribbon with slope acceleration**
The ribbon is a Hull Moving Average (HMA) plus its 2-bar-displaced sibling,
drawn as a filled band. A second-derivative reading (`slope1 − slope2`) detects
acceleration changes *before* the two lines cross, producing a "Pre-Bull" or
"Pre-Bear" state in the panel — a leading hint that complements the lagging
visual cross. In the example chart you can see this at the very top of the
move: the ribbon thins and rolls over before the actual colour flip occurs.

**Pivot-tracking BoS / CHoCH state machine**
Pivots are stored in a typed array and individually marked as broken when
price closes past them. The script then classifies each break as BoS or CHoCH
by comparing the break direction against the current trend state, instead of
just printing every pivot violation. This is why in the example you see only
**one** "CHoCH ▼" at the reversal followed by a chain of "BoS ▼" — the trend
flip is announced exactly once, then continuation breaks take over.

**Smart Zones with composite strength score**
When a structural break occurs, the engine looks back to find the last
opposite-coloured candle (the *origin candle*) and creates a zone there. Each
zone receives a 0–100 strength value computed from a 5-bar volume window
around the origin compared to a 20-bar volume average, plus a bullish/bearish
volume ratio. Zones below a user-defined minimum strength are skipped. As
price interacts with the zone, a touch counter is updated; once price closes
through the zone it is marked as **mitigated** and the box is faded rather
than deleted, so the chart keeps its historical context (you can see this in
the example: older zones still visible but visually softer than the active
one).

**Confidence Score**
A single 0–100 reading aggregates four sub-scores: trend strength
(|MHULL−SHULL|/ATR), momentum (RSI distance from 50 in the trend direction),
volatility regime (current ATR vs its 50-bar average) and structure freshness
(CHoCH = 20, BoS = 15, none = 0). Letter grades from D to A+ summarise the
overall environment.

To the author's knowledge no public TradingView script combines these four
exact pieces with this specific scoring and zone-strength logic. Each
component on its own is a known idea; their joint computation and the way
they feed each other is what defines this script.

---

## HOW IT WORKS — STEP BY STEP

### 1. Pivot collection
The script collects pivots using the configurable lookback ("Pivot lookback",
default 10). Each pivot is stored as a typed object with bar index, price,
high/low flag and a *broken* flag.

### 2. BoS vs CHoCH classification
On each bar the script checks whether the close has moved past the most
recent unbroken pivot in the relevant direction. When it has:

- If the break direction matches the current trend state → **BoS**
  (continuation).
- If the break direction reverses the current trend state → **CHoCH** (change
  of character). The trend state is then flipped.

A dashed line is drawn from the broken pivot's bar to the current bar with
the corresponding label. **In the example image**, this is what produces the
horizontal dashed lines and the "BoS ▲ / BoS ▼ / CHoCH ▼" labels.

### 3. Smart Zone generation
On each structural break the script searches the prior 20 bars (configurable)
for the last candle of opposite colour to the move. That candle's high and
low form the top and bottom of the zone box. The zone is drawn extending to
the right and receives a strength score and a bullish-volume percentage.
Boxes use transparency that scales with strength (stronger zones look more
solid). **In the example image**, the two upper purple boxes were created on
the two CHoCH ▼ / BoS ▼ events near the top; the lower blue box was created
on the bullish BoS ▲ at the start of the move.

### 4. Zone lifecycle
- **Active**: visible while price has not closed through it.
- **Touched**: the touch counter increments each time price re-enters the
  zone after leaving it (consecutive bars inside the zone count as a single
  touch).
- **Mitigated**: when price closes past the far edge, the zone is faded and
  stops extending. Mitigated zones remain on the chart by default for
  historical reference; this can be disabled in the inputs.
- **Aged out**: zones older than the configurable maximum age are removed.

### 5. EARLY / CONFIRMED signals
- **EARLY** fires the first bar price enters a non-mitigated zone — an
  anticipatory signal: better entry price, lower confirmation.
- **CONFIRMED** fires when the close reclaims the relevant zone edge after a
  prior touch (close above the bottom for bull zones, close below the top for
  bear zones) — a confirmation signal: worse entry price, higher
  confirmation.

CONFIRMED has visual priority: when both fire on the same bar, only the
CONFIRMED label is shown.

### 6. Confidence Score
Each sub-score is computed every bar:

- **Trend strength (0–40):** `|MHULL − SHULL| / ATR`, scaled and capped.
- **Momentum (0–20):** RSI(14) distance from 50, in the direction of the
  trend.
- **Volatility (0–20):** ATR(14) vs SMA of ATR(14, 50). Higher volatility
  scores higher.
- **Structure (0–20):** 20 if a CHoCH just happened, 15 if a BoS, 0
  otherwise.

The total is mapped to letter grades: A+ ≥ 85, A ≥ 70, B+ ≥ 55, B ≥ 40,
C ≥ 25, D below. **In the example image** the panel reads "Score: 15 D"
because the chart sits in a low-momentum recovery after a sustained
bearish leg — the panel correctly downgrades the environment despite the
local bullish bounce.

---

## HOW TO USE

LSE [I.M] is designed as a **context tool**, not a black-box buy/sell system.
A suggested workflow:

1. **Read the panel first.** A high Confidence grade in the same direction as
   the trend means the environment is aligned. A low grade is a caution flag.
2. **Use BoS / CHoCH labels to anchor bias.** A fresh CHoCH against your
   open-position direction is the most common reason to reduce or exit.
3. **Treat Smart Zones as decision areas, not magic levels.** Touch counts
   and strength values help pick which zones to watch; mitigated zones are
   kept for reference but should not be traded as if they were still active.
4. **EARLY signals favour preparation, CONFIRMED signals favour execution.**
   Aggressive traders may use EARLY with reduced size; more conservative
   traders may wait for CONFIRMED. Both are filtered by the minimum-strength
   input.
5. **Combine timeframes.** The script runs on any symbol and timeframe;
   reading higher-timeframe structure alongside an execution timeframe is the
   intended use.

The script does not place orders, does not include backtest results, and does
not claim a win rate. All decisions remain with the trader.

---

## INPUTS

**Detection**
- *Pivot lookback* — bars on each side required for a pivot. Higher = fewer,
  more significant pivots.
- *Max pivots to track* — array cap to keep the script light.

**Structure (BoS / CHoCH)**
- *Show BoS / Show CHoCH* — toggle each event type.
- *Show broken pivot lines* — dashed line from broken pivot to current bar.
- *Show HH/HL/LH/LL* — optional swing labels.

**Adaptive Ribbon**
- *Ribbon base length* — HMA length (default 55).
- *ATR length / sensitivity* — internal volatility input for slope and
  acceleration reading.
- *Band fill transparency, Glow, Line widths* — pure cosmetics.

**Smart Zones**
- *Trigger on* — BoS only / CHoCH only / both.
- *Min strength* — zones below this score are not drawn.
- *Origin candle lookback / Max age / Max count / Initial length* — geometry
  and lifecycle controls.
- *Keep mitigated zones (faded)* — keep history vs auto-remove on mitigation.
- *Show mid-line / Show touch count* — optional decorations.

**Entry Signals**
- *Show entry signals / Min strength for signal* — gating.
- *Show EARLY signal* — toggle anticipation labels.
- *Show confidence label* — toggle the star/grade text on signals.

**Confidence Score Panel**
- *Show panel / Position* — visibility and corner.

**Alerts / Webhook**
- *Webhook event filter* — All / BoS only / CHoCH only / Retests only.

---

## ALERTS

When an alert is created with this indicator, the alert message contains a
JSON payload such as:

```
{
  "symbol":   "BTCUSDT",
  "tf":       "15",
  "event":    "BUY_CONFIRMED",
  "price":    80000.0,
  "trend":    1,
  "score":    72,
  "grade":    "A",
  "strength": 65,
  "time":     "1715000000000"
}
```

Possible `event` values: `BULLISH_BOS`, `BEARISH_BOS`, `BULLISH_CHOCH`,
`BEARISH_CHOCH`, `BUY_EARLY`, `SELL_EARLY`, `BUY_CONFIRMED`, `SELL_CONFIRMED`.
This format is intended for webhook consumers that need structured data
rather than free text.

---

## NOTES AND LIMITATIONS

- All structural logic is evaluated on bar close
  (`alert.freq_once_per_bar_close`). Intra-bar values may differ from the
  final, confirmed reading.
- The Hull moving average is naturally smoother than EMA/SMA but still lags;
  the slope-acceleration reading is the script's attempt to compensate, not
  eliminate, that lag.
- Volume-based zone strength depends on the symbol providing usable volume
  data. On instruments without reliable volume, strength values will be less
  informative.
- The Confidence Score is a heuristic aid, not a probability. Different
  markets and timeframes will live in different score ranges, and that is
  expected.

---

## DISCLAIMER

This script is published for educational and informational purposes only. It
is not financial advice and does not guarantee any particular outcome. Past
behaviour of the indicator on historical data does not imply future
performance. Trade at your own risk and size positions according to your own
risk management.

## Source Code

````pine
//@version=6
// © igormena
// Liquidity Sweep Engine [I.M] v1 — Adaptive Ribbon · Smart Zones · Confidence Score

indicator("Liquidity Sweep Engine [I.M]", shorttitle="LSE [I.M]", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=200, max_bars_back=2000)

// ══════════════════════════════════════════════════════════════════
// IDENTITY PALETTE  (azul = alta  |  roxo = baixa)
// ══════════════════════════════════════════════════════════════════
C_BULL       = #2962FF   // azul vibrante
C_BEAR       = #7C3AED   // roxo profundo
C_BULL_SOFT  = #1565C0
C_BEAR_SOFT  = #4A148C
C_BULL_GLOW  = color.new(#2962FF, 80)
C_BEAR_GLOW  = color.new(#7C3AED, 80)
C_NEUTRAL    = #546E7A
C_TEXT       = color.white
C_PANEL_BG   = color.new(#0D0D1A, 10)

// ══════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════

g_det = "Detection"
pivotLen  = input.int(10, "Pivot lookback", minval=2, maxval=100, group=g_det)
maxPivots = input.int(50, "Max pivots to track", minval=10, maxval=200, group=g_det)

g_struct = "Structure (BoS / CHoCH)"
showBoS         = input.bool(true,  "Show BoS",           group=g_struct)
showCHoCH       = input.bool(true,  "Show CHoCH",         group=g_struct)
showStructLines = input.bool(true,  "Show broken pivot lines", group=g_struct)
showHHLL        = input.bool(false, "Show HH/HL/LH/LL",   group=g_struct)

g_ribbon = "Adaptive Ribbon"
showRibbon     = input.bool(true, "Show Adaptive Ribbon", group=g_ribbon)
ribbonLen      = input.int(55, "Ribbon base length", minval=10, maxval=200, group=g_ribbon)
ribbonAtrLen   = input.int(14, "ATR length (adaptive)", minval=5,  maxval=50,  group=g_ribbon)
ribbonAtrMult  = input.float(1.5, "ATR sensitivity", minval=0.5, maxval=4.0, step=0.1, group=g_ribbon,
     tooltip="Higher = ribbon reacts faster to volatility expansion")
ribbonTransp    = input.int(55, "Band fill transparency", minval=0, maxval=100, group=g_ribbon)
ribbonGlow      = input.bool(true, "Show outer glow", group=g_ribbon)
ribbonMainWidth = input.int(3,  "Main line width", minval=1, maxval=6,  group=g_ribbon)
ribbonGlowWidth = input.int(8,  "Glow line width", minval=2, maxval=20, group=g_ribbon)

g_ob = "Smart Zones"
showOB          = input.bool(true, "Show Smart Zones", group=g_ob)
obSource        = input.string("BoS + CHoCH", "Trigger on",
     options=["BoS only","CHoCH only","BoS + CHoCH"], group=g_ob)
obMinStrength   = input.int(0, "Min strength (0-100)", minval=0, maxval=100, group=g_ob)
obLookback      = input.int(20, "Origin candle lookback", minval=3, maxval=100, group=g_ob)
obMaxAge        = input.int(300, "Max zone age (bars)", minval=20, maxval=1000, group=g_ob)
obMaxCount      = input.int(8,  "Max zones on chart", minval=2, maxval=30, group=g_ob)
obExtendBars    = input.int(30, "Zone initial length", minval=5, maxval=200, group=g_ob)
obKeepMitigated = input.bool(true, "Keep mitigated zones (faded)", group=g_ob)
obShowMidline   = input.bool(false, "Show zone mid-line", group=g_ob)
obShowTouches   = input.bool(true, "Show touch count on zone", group=g_ob)

g_sig = "Entry Signals"
obShowSignals       = input.bool(true, "Show entry signals", group=g_sig)
obSignalMinStrength = input.int(0, "Min zone strength for signal", minval=0, maxval=100, group=g_sig)
showEarly           = input.bool(true, "Show EARLY signal (anticipation)", group=g_sig,
     tooltip="Fires when price enters zone. CONFIRMED fires on close above/below.")
showSignalLabel     = input.bool(true, "Show confidence label", group=g_sig)

g_score = "Confidence Score Panel"
showPanel   = input.bool(true, "Show Confidence Panel", group=g_score)
panelXPos   = input.string("Right", "Panel position", options=["Right","Left"], group=g_score)

g_alt = "Alerts / Webhook"
alertFilter = input.string("All", "Webhook event filter",
     options=["All","BoS only","CHoCH only","Retests only"], group=g_alt)

// ══════════════════════════════════════════════════════════════════
// TYPES
// ══════════════════════════════════════════════════════════════════

type Pivot
    int   idx
    float price
    bool  isHigh
    bool  broken

type SmartZone
    int   leftIdx
    float top
    float bottom
    bool  isBullish
    bool  mitigated
    bool  retested
    int   strength
    int   bullPercent
    int   touches
    box   bxMain
    line  midLine
    label touchLbl

type StructLine
    line  ln
    label lbl

// ══════════════════════════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════════════════════════

var array<Pivot>      pivots      = array.new<Pivot>()
var array<SmartZone>  zones       = array.new<SmartZone>()
var array<StructLine> structLines = array.new<StructLine>()

var int   trend              = 0
var float lastPivotHigh      = na
var int   lastPivotHighIdx   = na
var float lastPivotLow       = na
var int   lastPivotLowIdx    = na
var float prevPivotHighPrice = na
var float prevPivotLowPrice  = na

// early signal state
var bool earlyBuyActive  = false
var bool earlySellActive = false
var int  earlyBuyBar     = na
var int  earlySellBar    = na

// ══════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════

trimPivots() =>
    while pivots.size() > maxPivots
        pivots.shift()

deleteZone(SmartZone z) =>
    box.delete(z.bxMain)
    line.delete(z.midLine)
    label.delete(z.touchLbl)

trimZones() =>
    while zones.size() > obMaxCount
        z = zones.shift()
        deleteZone(z)

// ══════════════════════════════════════════════════════════════════
// ADAPTIVE RIBBON  (HMA + ATR width + slope color blend)
// ══════════════════════════════════════════════════════════════════

atr14     = ta.atr(ribbonAtrLen)
avgVol20  = ta.sma(volume, 20)         // pre-computed every bar for zone metrics
atrNorm   = atr14 / close              // relative ATR (0.001 → 0.05 typical)
atrFactor = math.min(3.0, 1.0 + atrNorm * ribbonAtrMult * 50)

HULL  = ta.hma(close, ribbonLen)
MHULL = HULL
SHULL = HULL[2]

// slope-based early color blending
slope1 = MHULL - MHULL[1]
slope2 = MHULL[1] - MHULL[2]
accel  = slope1 - slope2        // positive = accelerating up

ribbonBullish = MHULL > SHULL
ribbonBearish = MHULL < SHULL

// pre-flip detection: slope reversing before line crossover
preBull = ribbonBearish and accel > 0 and slope1 > 0
preBear = ribbonBullish and accel < 0 and slope1 < 0

ribbonMainColor = ribbonBullish ? color.new(C_BULL, 0) : color.new(C_BEAR, 0)
ribbonEdgeColor = ribbonBullish ? color.new(C_BULL_SOFT, 0) : color.new(C_BEAR_SOFT, 0)

mhullGlow1 = plot(showRibbon and ribbonGlow ? MHULL : na, "MHULL Glow",
     color=color.new(ribbonMainColor, 82), linewidth=ribbonGlowWidth)
shullGlow1 = plot(showRibbon and ribbonGlow ? SHULL : na, "SHULL Glow",
     color=color.new(ribbonMainColor, 82), linewidth=ribbonGlowWidth)
fill(mhullGlow1, shullGlow1, color=color.new(ribbonMainColor, 88), title="Ribbon Outer Glow")

mhullPlot = plot(showRibbon ? MHULL : na, "MHULL",
     color=ribbonEdgeColor, linewidth=ribbonMainWidth)
shullPlot = plot(showRibbon ? SHULL : na, "SHULL",
     color=ribbonEdgeColor, linewidth=ribbonMainWidth)
fill(mhullPlot, shullPlot, color=color.new(ribbonMainColor, ribbonTransp), title="Ribbon Band Fill")

// ══════════════════════════════════════════════════════════════════
// SMART ZONE CREATION
// ══════════════════════════════════════════════════════════════════

findOriginCandle(bool isBullish) =>
    int   foundIdx    = na
    float foundTop    = na
    float foundBottom = na
    for k = 1 to obLookback
        isOpposite = isBullish ? close[k] < open[k] : close[k] > open[k]
        if isOpposite
            foundIdx    := bar_index - k
            foundTop    := high[k]
            foundBottom := low[k]
            break
    [foundIdx, foundTop, foundBottom]

calcZoneMetrics(int originOffset) =>
    float buyVol   = 0.0
    float sellVol  = 0.0
    float totalVol = 0.0
    startK = math.max(0, originOffset - 2)
    endK   = math.min(bar_index, originOffset + 3)
    int samples = 0
    for k = startK to endK
        v = nz(volume[k])
        totalVol += v
        samples  += 1
        if close[k] > open[k]
            buyVol += v
        else if close[k] < open[k]
            sellVol += v
        else
            buyVol  += v * 0.5
            sellVol += v * 0.5
    avgSafe   = avgVol20 > 0 ? avgVol20 : 1.0
    sampleAvg = samples > 0 ? totalVol / samples : 0.0
    int strength = math.min(100, math.max(0, math.round((sampleAvg / avgSafe) * 60)))
    int bullPct  = totalVol > 0 ? math.round(buyVol / totalVol * 100) : 50
    [strength, bullPct]

createSmartZone(bool isBullish) =>
    [originIdx, originTop, originBottom] = findOriginCandle(isBullish)
    if not na(originIdx) and not na(originTop) and not na(originBottom)
        originOffset = bar_index - originIdx
        [strength, bullPct] = calcZoneMetrics(originOffset)
        if strength >= obMinStrength
            cBase       = isBullish ? C_BULL : C_BEAR
            transpFill   = math.max(70, 85 - math.round(strength / 3))
            transpBorder = math.max(40, 60 - math.round(strength / 3))
            cFill       = color.new(cBase, transpFill)
            cBorder     = color.new(cBase, transpBorder)
            bxMain = box.new(originIdx, originTop, originIdx + obExtendBars, originBottom,
                 border_color=cBorder, bgcolor=cFill, border_width=1, extend=extend.right)
            midPrice = (originTop + originBottom) / 2.0
            line midLn = na
            if obShowMidline
                midLn := line.new(originIdx, midPrice, originIdx + obExtendBars, midPrice,
                     color=color.new(cBase, 70), width=1, style=line.style_dashed, extend=extend.right)
            label touchLbl = na
            if obShowTouches
                touchLbl := label.new(originIdx + obExtendBars, originTop,
                     "0×", color=color.new(cBase, 80), textcolor=C_TEXT,
                     style=label.style_label_left, size=size.tiny)
            z = SmartZone.new(originIdx, originTop, originBottom, isBullish, false, false,
                 strength, bullPct, 0, bxMain, midLn, touchLbl)
            zones.push(z)
            trimZones()

updateZones() =>
    if zones.size() > 0
        for i = zones.size() - 1 to 0
            z = zones.get(i)
            // touch count — só conta nova entrada (não cada bar dentro da zona)
            inZoneNow  = high >= z.bottom and low <= z.top
            inZonePrev = high[1] >= z.bottom and low[1] <= z.top
            if inZoneNow and not inZonePrev and not z.mitigated
                z.touches += 1
                if not na(z.touchLbl)
                    label.set_text(z.touchLbl, str.tostring(z.touches) + "×")

            justMitigated = not z.mitigated and (z.isBullish ? close < z.bottom : close > z.top)
            tooOld        = bar_index - z.leftIdx > obMaxAge

            if justMitigated
                if obKeepMitigated
                    z.mitigated := true
                    cFade = z.isBullish ? C_BULL : C_BEAR
                    box.set_bgcolor(z.bxMain, color.new(cFade, 96))
                    box.set_border_color(z.bxMain, color.new(cFade, 90))
                    box.set_extend(z.bxMain, extend.none)
                    if not na(z.midLine)
                        line.set_color(z.midLine, color.new(cFade, 92))
                        line.set_extend(z.midLine, extend.none)
                    if not na(z.touchLbl)
                        label.delete(z.touchLbl)
                else
                    deleteZone(z)
                    zones.remove(i)
                    continue

            if tooOld
                deleteZone(z)
                zones.remove(i)

// ══════════════════════════════════════════════════════════════════
// EARLY + CONFIRMED SIGNALS
// ══════════════════════════════════════════════════════════════════

checkSignals() =>
    bool earlyBuy  = false
    bool earlySell = false
    bool confBuy   = false
    bool confSell  = false
    int  sigStr    = 0

    if zones.size() > 0
        for i = zones.size() - 1 to 0
            z = zones.get(i)
            if z.mitigated or z.strength < obSignalMinStrength
                continue

            if z.isBullish
                inZoneNow  = low  <= z.top    and low  >= z.bottom
                inZonePrev = low[1] <= z.top  and low[1] >= z.bottom
                // EARLY: apenas na primeira barra que entra na zona
                if inZoneNow and not inZonePrev and not z.retested
                    earlyBuy   := true
                    sigStr     := z.strength
                    z.retested := true
                // CONFIRMED: close reconquista a base da zona após o toque
                if z.retested and close > z.bottom and close[1] <= z.bottom
                    confBuy := true
                    sigStr  := z.strength
            else
                inZoneNow  = high >= z.bottom and high <= z.top
                inZonePrev = high[1] >= z.bottom and high[1] <= z.top
                if inZoneNow and not inZonePrev and not z.retested
                    earlySell  := true
                    sigStr     := z.strength
                    z.retested := true
                if z.retested and close < z.top and close[1] >= z.top
                    confSell := true
                    sigStr   := z.strength

    // CONFIRMED tem prioridade visual — não mostra EARLY no mesmo bar
    if confBuy
        earlyBuy  := false
    if confSell
        earlySell := false

    [earlyBuy, earlySell, confBuy, confSell, sigStr]

// ══════════════════════════════════════════════════════════════════
// STRUCTURE LINES
// ══════════════════════════════════════════════════════════════════

drawStructLine(int xStart, int xEnd, float price, bool isBullish, string lblText) =>
    c  = isBullish ? C_BULL : C_BEAR
    ln = line.new(xStart, price, xEnd, price,
         color=color.new(c, 70), style=line.style_dashed, width=1)
    lbl = label.new(math.round((xStart + xEnd) / 2), price, lblText,
         color=color.new(c, 25), textcolor=C_TEXT,
         style=label.style_label_center, size=size.small)
    structLines.push(StructLine.new(ln, lbl))
    while structLines.size() > 20
        old = structLines.shift()
        line.delete(old.ln)
        label.delete(old.lbl)

// ══════════════════════════════════════════════════════════════════
// PIVOT DETECTION
// ══════════════════════════════════════════════════════════════════

ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

if not na(ph)
    pivots.push(Pivot.new(bar_index - pivotLen, ph, true, false))
    prevPivotHighPrice := lastPivotHigh
    lastPivotHigh      := ph
    lastPivotHighIdx   := bar_index - pivotLen

if not na(pl)
    pivots.push(Pivot.new(bar_index - pivotLen, pl, false, false))
    prevPivotLowPrice := lastPivotLow
    lastPivotLow      := pl
    lastPivotLowIdx   := bar_index - pivotLen

trimPivots()

// ══════════════════════════════════════════════════════════════════
// BoS / CHoCH
// ══════════════════════════════════════════════════════════════════

findUnbrokenHigh() =>
    float p   = na
    int   idx = na
    if pivots.size() > 0
        for i = pivots.size() - 1 to 0
            piv = pivots.get(i)
            if piv.isHigh and not piv.broken
                p   := piv.price
                idx := piv.idx
                break
    [p, idx]

findUnbrokenLow() =>
    float p   = na
    int   idx = na
    if pivots.size() > 0
        for i = pivots.size() - 1 to 0
            piv = pivots.get(i)
            if not piv.isHigh and not piv.broken
                p   := piv.price
                idx := piv.idx
                break
    [p, idx]

markBroken(bool isHigh) =>
    if pivots.size() > 0
        for i = pivots.size() - 1 to 0
            piv = pivots.get(i)
            if piv.isHigh == isHigh and not piv.broken
                piv.broken := true
                break

[unbrokenHigh, unbrokenHighIdx] = findUnbrokenHigh()
[unbrokenLow,  unbrokenLowIdx]  = findUnbrokenLow()

bool bosBull   = false
bool bosBear   = false
bool chochBull = false
bool chochBear = false

if not na(unbrokenHigh) and close > unbrokenHigh and close[1] <= unbrokenHigh
    if trend == 1
        bosBull   := true
    else
        chochBull := true
    trend := 1
    markBroken(true)
    if showStructLines
        lblTxt  = chochBull ? "CHoCH ▲" : "BoS ▲"
        showLbl = (chochBull and showCHoCH) or (bosBull and showBoS)
        if showLbl
            drawStructLine(unbrokenHighIdx, bar_index, unbrokenHigh, true, lblTxt)

if not na(unbrokenLow) and close < unbrokenLow and close[1] >= unbrokenLow
    if trend == -1
        bosBear   := true
    else
        chochBear := true
    trend := -1
    markBroken(false)
    if showStructLines
        lblTxt  = chochBear ? "CHoCH ▼" : "BoS ▼"
        showLbl = (chochBear and showCHoCH) or (bosBear and showBoS)
        if showLbl
            drawStructLine(unbrokenLowIdx, bar_index, unbrokenLow, false, lblTxt)

// ══════════════════════════════════════════════════════════════════
// CREATE ZONES ON BREAK
// ══════════════════════════════════════════════════════════════════

shouldCreateZone(bool isBoS, bool isCHoCH) =>
    src = obSource
    (src == "BoS only" and isBoS) or
     (src == "CHoCH only" and isCHoCH) or
     (src == "BoS + CHoCH" and (isBoS or isCHoCH))

if showOB and (bosBull or chochBull) and shouldCreateZone(bosBull, chochBull)
    createSmartZone(true)

if showOB and (bosBear or chochBear) and shouldCreateZone(bosBear, chochBear)
    createSmartZone(false)

if showOB
    updateZones()

// ══════════════════════════════════════════════════════════════════
// SIGNAL EVALUATION
// ══════════════════════════════════════════════════════════════════

bool sigEarlyBuy  = false
bool sigEarlySell = false
bool sigConfBuy   = false
bool sigConfSell  = false
int  sigStrength  = 0

if showOB and obShowSignals
    [eb, es, cb, cs, str] = checkSignals()
    sigEarlyBuy  := eb
    sigEarlySell := es
    sigConfBuy   := cb
    sigConfSell  := cs
    sigStrength  := str

// ══════════════════════════════════════════════════════════════════
// HH / HL / LH / LL
// ══════════════════════════════════════════════════════════════════

if showHHLL and not na(ph)
    structLbl   = na(prevPivotHighPrice) ? "HH" : (ph > prevPivotHighPrice ? "HH" : "LH")
    structColor = structLbl == "HH" ? C_BULL : C_BEAR
    label.new(bar_index - pivotLen, ph, structLbl,
         color=color.new(color.black, 100), textcolor=structColor,
         style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

if showHHLL and not na(pl)
    structLbl   = na(prevPivotLowPrice) ? "HL" : (pl > prevPivotLowPrice ? "HL" : "LL")
    structColor = structLbl == "HL" ? C_BULL : C_BEAR
    label.new(bar_index - pivotLen, pl, structLbl,
         color=color.new(color.black, 100), textcolor=structColor,
         style=label.style_label_up, size=size.small, yloc=yloc.belowbar)

// ══════════════════════════════════════════════════════════════════
// CONFIDENCE SCORE ENGINE
// ══════════════════════════════════════════════════════════════════

// Trend strength (0-40)
trendStrength = math.abs(MHULL - SHULL) / atr14
trendScore    = math.min(40, math.round(trendStrength * 20))

// Momentum (RSI-based, 0-20)
rsi14         = ta.rsi(close, 14)
momScore      = trend == 1 ? math.round(math.max(0, rsi14 - 50) / 50 * 20) :
     trend == -1 ? math.round(math.max(0, 50 - rsi14) / 50 * 20) : 0

// Volatility regime (ATR vs 50-bar ATR avg, 0-20)
atrAvg        = ta.sma(atr14, 50)
volRatio      = atrAvg > 0 ? atr14 / atrAvg : 1.0
volScore      = math.min(20, math.round(volRatio * 10))

// Structure (BoS/CHoCH freshness, 0-20)
structScore   = (bosBull or bosBear) ? 15 : (chochBull or chochBear) ? 20 : 0

totalScore    = trendScore + momScore + volScore + structScore  // max 100

scoreGrade    = totalScore >= 85 ? "A+" :
     totalScore >= 70 ? "A"  :
     totalScore >= 55 ? "B+" :
     totalScore >= 40 ? "B"  :
     totalScore >= 25 ? "C"  : "D"

trendLabel    = trend == 1 ? "BULLISH ▲" : trend == -1 ? "BEARISH ▼" : "NEUTRAL —"
momentumLabel = rsi14 > 65 ? "Strong" : rsi14 > 55 ? "Moderate" : rsi14 < 35 ? "Strong" : rsi14 < 45 ? "Moderate" : "Weak"
volLabel      = volRatio > 1.3 ? "High" : volRatio > 0.8 ? "Normal" : "Low"

// ══════════════════════════════════════════════════════════════════
// LEVEL 2: ENTRY SIGNALS
// ══════════════════════════════════════════════════════════════════

if sigEarlyBuy and showEarly and showSignalLabel
    label.new(bar_index, low, "⚡ EARLY",
         color=color.new(C_BULL, 20), textcolor=C_TEXT,
         style=label.style_label_upper_right, size=size.tiny, yloc=yloc.belowbar)

if sigEarlySell and showEarly and showSignalLabel
    label.new(bar_index, high, "⚡ EARLY",
         color=color.new(C_BEAR, 20), textcolor=C_TEXT,
         style=label.style_label_lower_right, size=size.tiny, yloc=yloc.abovebar)

if sigConfBuy and showSignalLabel
    stars = sigStrength >= 80 ? "★★★★" : sigStrength >= 60 ? "★★★" : sigStrength >= 40 ? "★★" : "★"
    label.new(bar_index, low, stars + " BUY  " + scoreGrade,
         color=color.new(C_BULL, 10), textcolor=C_TEXT,
         style=label.style_label_upper_right, size=size.small, yloc=yloc.belowbar)

if sigConfSell and showSignalLabel
    stars = sigStrength >= 80 ? "★★★★" : sigStrength >= 60 ? "★★★" : sigStrength >= 40 ? "★★" : "★"
    label.new(bar_index, high, stars + " SELL  " + scoreGrade,
         color=color.new(C_BEAR, 10), textcolor=C_TEXT,
         style=label.style_label_lower_right, size=size.small, yloc=yloc.abovebar)

// ══════════════════════════════════════════════════════════════════
// LEVEL 1: CHOCH / BOS LABELS  (biggest visual weight)
// ══════════════════════════════════════════════════════════════════

// (drawn inside drawStructLine — handled above)

// ══════════════════════════════════════════════════════════════════
// CONFIDENCE SCORE PANEL  (table — Level 3 context)
// ══════════════════════════════════════════════════════════════════

var table scorePanel = na

if showPanel
    if na(scorePanel)
        hPos = panelXPos == "Right" ? position.bottom_right : position.bottom_left
        scorePanel := table.new(hPos, 2, 7,
             bgcolor=C_PANEL_BG, border_color=color.new(C_BULL, 50), border_width=1, frame_color=color.new(C_BULL,30), frame_width=1)

    cTrend  = trend == 1 ? color.new(C_BULL, 20) : trend == -1 ? color.new(C_BEAR, 20) : color.new(C_NEUTRAL, 20)
    cGrade  = totalScore >= 70 ? color.new(C_BULL, 20) : totalScore >= 40 ? color.new(#FFA000, 20) : color.new(C_BEAR, 20)

    table.cell(scorePanel, 0, 0, "LSE [I.M]",        text_color=C_TEXT, bgcolor=color.new(C_BULL, 50), text_size=size.small)
    table.cell(scorePanel, 1, 0, "Score: " + str.tostring(totalScore) + " " + scoreGrade,
         text_color=C_TEXT, bgcolor=cGrade, text_size=size.small)

    table.cell(scorePanel, 0, 1, "Trend",             text_color=color.new(C_TEXT,30), text_size=size.tiny)
    table.cell(scorePanel, 1, 1, trendLabel,          text_color=C_TEXT, bgcolor=cTrend, text_size=size.tiny)

    table.cell(scorePanel, 0, 2, "Momentum",          text_color=color.new(C_TEXT,30), text_size=size.tiny)
    table.cell(scorePanel, 1, 2, momentumLabel + " (" + str.tostring(math.round(rsi14)) + ")",
         text_color=C_TEXT, text_size=size.tiny)

    table.cell(scorePanel, 0, 3, "Volatility",        text_color=color.new(C_TEXT,30), text_size=size.tiny)
    table.cell(scorePanel, 1, 3, volLabel,            text_color=C_TEXT, text_size=size.tiny)

    table.cell(scorePanel, 0, 4, "Structure",         text_color=color.new(C_TEXT,30), text_size=size.tiny)
    table.cell(scorePanel, 1, 4, chochBull or chochBear ? "CHoCH ✦" : bosBull or bosBear ? "BoS" : "—",
         text_color=C_TEXT, text_size=size.tiny)

    table.cell(scorePanel, 0, 5, "Ribbon",            text_color=color.new(C_TEXT,30), text_size=size.tiny)
    table.cell(scorePanel, 1, 5, preBull ? "Pre-Bull ⚡" : preBear ? "Pre-Bear ⚡" : ribbonBullish ? "Bull" : "Bear",
         text_color=C_TEXT, text_size=size.tiny)

    table.cell(scorePanel, 0, 6, "Zones",             text_color=color.new(C_TEXT,30), text_size=size.tiny)
    table.cell(scorePanel, 1, 6, str.tostring(zones.size()) + " active",
         text_color=C_TEXT, text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════
// ALERTS / WEBHOOK
// ══════════════════════════════════════════════════════════════════

eventType = sigConfBuy  ? "BUY_CONFIRMED"  :
     sigEarlyBuy  ? "BUY_EARLY"     :
     sigConfSell  ? "SELL_CONFIRMED" :
     sigEarlySell ? "SELL_EARLY"     :
     bosBull      ? "BULLISH_BOS"    :
     bosBear      ? "BEARISH_BOS"    :
     chochBull    ? "BULLISH_CHOCH"  :
     chochBear    ? "BEARISH_CHOCH"  : ""

hasEvent = bosBull or bosBear or chochBull or chochBear or sigEarlyBuy or sigEarlySell or sigConfBuy or sigConfSell

shouldAlert = hasEvent and (
     alertFilter == "All" or
     (alertFilter == "BoS only"     and (bosBull or bosBear)) or
     (alertFilter == "CHoCH only"   and (chochBull or chochBear)) or
     (alertFilter == "Retests only" and (sigEarlyBuy or sigEarlySell or sigConfBuy or sigConfSell)))

if shouldAlert
    json = '{"symbol":"'   + syminfo.ticker
         + '","tf":"'       + timeframe.period
         + '","event":"'    + eventType
         + '","price":'     + str.tostring(close)
         + ',"trend":'      + str.tostring(trend)
         + ',"score":'      + str.tostring(totalScore)
         + ',"grade":"'     + scoreGrade
         + '","strength":'  + str.tostring(sigStrength)
         + ',"time":"'      + str.tostring(time)
         + '"}'
    alert(json, alert.freq_once_per_bar_close)
````
