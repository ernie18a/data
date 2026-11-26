# [ A L P H A X ] RELAY - Pattern Relay Engine

- url: https://www.tradingview.com/script/kSQg4R62-A-L-P-H-A-X-RELAY-Pattern-Relay-Engine/
- type: indicator
- pine_id: PUB;8efd557889a9482d81ad577f41368304
- version: 1.0

## Description

[b]AlphaX RELAY — Pattern Relay Engine: Formation → Armed → Fired Lifecycle System, Pre-Breakout Detection, Completion Scoring, Volume Coil Confirmation & Real-Time Phase Intelligence[/b]

AlphaX RELAY is a professional-grade chart pattern anticipation system built around a fundamentally different concept from every other pattern indicator — including its companion AlphaX FORGE. Where FORGE detects patterns [i]after[/i] breakout confirmation and fires entry signals on completed formations, RELAY tracks patterns [i]throughout their entire development lifecycle[/i], scoring their completion percentage in real time and alerting you [i]before[/i] the breakout occurs. The RELAY framework divides every pattern's life into three sequential phases — FORMING, ARMED, and FIRED — and updates the phase designation on every bar as price evolves within the formation. When a pattern enters the ARMED zone (price approaching the neckline or boundary within ATR tolerance), RELAY alerts you to prepare. When the breakout fires, the full entry framework activates with computed entry, stop, TP1, and TP2 levels alongside a JSON alert. The result is a system that gives you advance warning of high-probability breakouts rather than reactive confirmation — designed for traders who want to be positioned before the crowd, across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 [b]The RELAY Philosophy — Anticipation Over Confirmation[/b]

Every significant chart pattern begins forming bars or hours before the breakout. A Double Top starts when the second peak forms near the first — at that moment, a skilled technical trader begins watching the neckline. A Head & Shoulders is identifiable from the moment the right shoulder begins forming — before price has reached the neckline. A Bull Flag is established from the moment the pole terminates and consolidation begins.

Most pattern indicators wait until the breakout is confirmed — at which point the pattern is already complete, the first wave of breakout traders has already entered, and the entry price is often significantly beyond the pattern boundary. RELAY inverts this model. By continuously scanning for pattern geometries [i]as they form[/i], scoring their completion, and communicating their phase state in real time, RELAY gives traders the ability to:

[list]
[*]Identify patterns well before breakout — watching them develop in real time on the chart
[*]Receive an ARMED alert when price approaches the trigger level — preparing limit orders or monitoring for the candle close
[*]Enter on the FIRED event with a pre-planned trade, not a reactive chase
[*]Track completion percentage continuously — knowing whether a formation is 65% complete or 95% complete changes the urgency of preparation
[/list]

This anticipatory framework is the core intellectual contribution of RELAY to the AlphaX suite, and it is what distinguishes it from FORGE — two systems covering the same pattern types from opposite temporal perspectives.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 [b]The Three-Phase Lifecycle — FORMING → ARMED → FIRED[/b]

Every pattern in RELAY exists in exactly one of three states at any moment. The phase is computed on every bar and displayed prominently on both the chart label and the dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Phase 1 — FORMING (Purple)[/b]

The pattern geometry has been confirmed — the pivots are in the correct structural relationship and the formation is identifiable. However, price has not yet approached the neckline or boundary level closely enough to be considered imminently actionable.

[b]What FORMING means:[/b] The pattern exists and is valid. Completion percentage is typically 60–80% in this phase. The formation box is drawn on the chart in purple. The neckline or boundary is plotted as a solid purple line. The dashboard shows the pattern name, FORMING phase, and the current completion percentage.

[b]How to use FORMING:[/b] Plan your trade. Note the neckline level. Calculate where your entry, stop, and targets will be if the pattern fires. Set a price alert at the ARMED zone boundary so you are notified when price begins approaching the trigger level. Do not enter yet.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Phase 2 — ARMED (Orange)[/b]

Price has approached the neckline or boundary to within the configurable ATR tolerance (default: 0.35× ATR). The pattern is in its final stage of formation before the breakout. The trigger is imminent.

[b]What ARMED means:[/b] Price is close enough to the neckline that the next 1–5 bars will likely determine whether the pattern fires or fails. Completion percentage typically reaches 85–100% in this phase. The formation box and neckline shift to orange. The dashboard phase row turns orange. An ARMED alert fires.

[b]How to use ARMED:[/b] This is your active preparation signal. If you are trading with limit orders, now is the time to place a limit order at the neckline level. If you prefer market orders on breakout, watch the chart closely for the closing candle confirmation. Review the confluence score — if it is at or above the minimum, the ARMED setup is worth your full attention.

[b]ARMED alert:[/b] Separate alert conditions fire for ARMED Long and ARMED Short, allowing you to set up targeted notifications for the direction you want to trade. The ARMED alert is the pre-breakout awareness signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Phase 3 — FIRED (Yellow-Green / Red)[/b]

Price has closed beyond the neckline or boundary by more than the configured break margin (default: 0.6× ATR). The pattern has completed and the entry framework activates. Completion is 100%.

[b]What FIRED means:[/b] The breakout is confirmed by bar close. The formation box and neckline shift to the directional color — yellow-green for bull patterns, red for bear patterns. Entry, SL, TP1, and TP2 lines are drawn on the chart extending 40 bars forward. All four levels are labeled with exact prices. The TP2 label also shows the computed R:R. A FIRED alert fires with a full JSON payload.

[b]How to use FIRED:[/b] Enter on the next bar's open at or near the entry level shown on the chart. Place the stop at the SL level. Scale out 50% (default) at TP1. Let the remainder run to TP2 or trail with a stop.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Formation Completion Scoring — The Pattern Health Metric[/b]

The completion percentage is a pattern-specific quantitative score that measures how far along the formation has progressed toward its breakout. Unlike a simple binary detection, the completion score gives you continuous awareness of pattern health.

[b]How completion is computed:[/b]
Each pattern type starts with a base completion score that reflects the geometric confirmation of the core structure:
[list]
[*][b]Double Top / Bottom base:[/b] 70% — the two-pivot structure is confirmed
[*][b]Head & Shoulders / Inv H&S base:[/b] 65% — the three-pivot structure with neckline is confirmed
[*][b]Triangles base:[/b] 60–75% — converging trendlines with sufficient base height
[*][b]Flags / Pennants base:[/b] 62% — pole plus parallel or converging consolidation confirmed
[*][b]Wedges base:[/b] 58–78% — converging wedge with correct slope relationship
[/list]

Additional completion points are awarded for:
[list]
[*][b]+15 points[/b] — price is on the correct side of the neckline (below the neckline for Double Tops, above for Double Bottoms)
[*][b]+15–20 points[/b] — price is within the ARMED zone (within ATR tolerance of the neckline or boundary)
[/list]

Maximum possible completion before breakout is 100%. FIRED state also shows 100% on the dashboard.

[b]Minimum formation threshold:[/b] Patterns below the configured minimum completion percentage (default: 55%) are not displayed. This prevents very early, nascent patterns with insufficient structural confirmation from cluttering the chart. Raising this threshold (e.g., to 70%) shows only well-developed formations where the pattern geometry is fully confirmed and price is approaching the trigger.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Pattern Detection — Five Formation Types[/b]

RELAY continuously scans for five pattern families in real time, computing their phase and completion on every bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Double Top / Double Bottom[/b]

Two pivot highs at approximately the same level separated by a pullback low (Double Top), or two pivot lows at approximately the same level separated by a recovery high (Double Bottom). The neckline is the intervening low (Double Top) or high (Double Bottom).

Phase transitions:
[list]
[*]FORMING — geometry confirmed, price not yet near neckline
[*]ARMED — price within 0.35× ATR of the neckline
[*]FIRED — price closes below neckline by 0.6× ATR (Double Top) or above by 0.6× ATR (Double Bottom)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Head & Shoulders / Inverted H&S[/b]

Three-peak structure with a dominant central peak (head) flanked by two lower peaks (shoulders) at approximately equal heights, connected by a potentially sloped neckline through the two intervening lows. The Inverted H&S is the mirror pattern with a dominant central trough.

The neckline for H&S patterns is computed as a projected line through the two neckline pivot points, evaluated at the current bar — producing a dynamically sloped neckline that accurately reflects the true pattern boundary at any point in time.

Phase transitions follow the same ATR-based FORMING → ARMED → FIRED logic, with the ARMED zone assessed against the sloped neckline projection.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Triangles — Ascending, Descending, Symmetrical[/b]

Converging trendlines formed by a falling or flat upper trendline and a rising or flat lower trendline. The three variants are distinguished by slope:
[list]
[*][b]Ascending Triangle[/b] — upper trendline near flat, lower trendline rising. Bull breakout expected
[*][b]Descending Triangle[/b] — lower trendline near flat, upper trendline falling. Bear breakout expected
[*][b]Symmetrical Triangle[/b] — both trendlines converging, neither flat. Can break either direction; RELAY tracks the direction of the actual breakout
[/list]

The ARMED zone is computed relative to the projected upper (bull) or lower (bear) trendline at the current bar. Completion receives a bonus for larger triangle base heights (more than 2× ATR adds 15 points vs 5 points for smaller bases).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Flags and Pennants[/b]

A sharp pole move followed by a consolidation with parallel downward-sloping trendlines (Bull Flag / Pennant) or parallel upward-sloping trendlines (Bear Flag / Pennant). The pole size must be at least 2.5× ATR to qualify as a genuine pole rather than normal price movement.

The upper trendline for Bull Flags and the lower trendline for Bear Flags are the breakout boundaries. The ARMED zone is assessed against the projected trendline level at the current bar. The target is the breakout level plus the full pole distance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Rising and Falling Wedges[/b]

Converging patterns where both trendlines slope in the same direction but the lower trendline has a more extreme slope than the upper (Rising Wedge — bearish) or the upper trendline has a more extreme slope than the lower (Falling Wedge — bullish). The slope relationship distinguishes wedges from flags (which are parallel) and triangles (where lines converge to a point rather than widening).

Completion bonus is proportional to the wedge width in ATR multiples — wider wedges with more price range between the trendlines score higher completion. The target is the high of the wedge origin (Falling Wedge) or the low (Rising Wedge) — the structural measurement move.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏅 [b]The 10-Point Quality Scoring System[/b]

Every active pattern is scored through a 10-point confluence system. Only patterns meeting the minimum score threshold (default: 5) are displayed, and the quality-ranked selection algorithm picks the highest-scoring pattern when multiple formations are active simultaneously.

[b]Score components:[/b]

[b]Formation Completion (up to 2 points):[/b]
Completion at 85% or above scores 2 points. Completion above the configured minimum scores 1 point. This ensures well-developed patterns score higher than nascent formations.

[b]HTF Bias Alignment (up to 2 points):[/b]
Bull pattern with bull HTF, or bear pattern with bear HTF, scores 2 points. When HTF is disabled, 1 neutral point is awarded. Counter-HTF patterns score 0. The HTF filter can be set as a hard block on FIRED patterns — preventing counter-HTF breakout alerts even if the pattern is technically valid.

[b]Non-Chop Market (1 point):[/b]
Choppiness Index below the threshold. Also enforced as a hard gate — extreme chop blocks all patterns from displaying.

[b]Pattern Phase (up to 2 points):[/b]
FIRED scores 2 points, ARMED scores 1 point, FORMING scores 0. This weighting ensures that more advanced phases naturally score higher in the quality ranking — a FIRED pattern will nearly always outscore a FORMING pattern in the selection algorithm.

[b]Volume Coil Before Break (1 point):[/b]
Current volume is below the configured fraction of the volume moving average (default: 0.85×). A drying volume condition approaching the neckline is the classic pre-breakout behavior — the market is consolidating on declining interest before the explosive release. This layer rewards patterns where this institutional behavior is present.

[b]R:R at Minimum (1 point):[/b]
The computed R:R between entry and TP2 meets or exceeds the minimum (default: 1.5). Ensures only patterns with adequate measured moves relative to their stop are displayed.

[b]Pattern Size (1 point):[/b]
The pattern height or target distance meets or exceeds 1.5× ATR. Filters micro-patterns with trivial measured moves.

[b]Selection algorithm:[/b]
When multiple patterns qualify simultaneously, RELAY uses a composite ranking that combines the confluence score, completion percentage (weighted at 0.05 per percent), and phase bonus (FIRED: +3, ARMED: +2, FORMING: +0). This ensures that a FIRED pattern with good confluence almost always outranks a FORMING pattern, while also rewarding high-completion ARMED patterns over low-completion FORMING patterns of equal confluence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 [b]Formation Box and Neckline Visualization[/b]

Every active pattern is rendered with two core visual elements:

[b]Formation Box:[/b]
A rectangle spanning the pattern's horizontal range (from the start bar to the current bar) and vertical range (from the neckline to the opposite extreme of the pattern — the tops for bear patterns, the bottoms for bull patterns). The box color reflects the current phase: purple for FORMING, orange for ARMED, yellow-green or red for FIRED. The fill opacity is moderate (88%) — present enough to identify the pattern zone without obscuring price action behind it.

[b]Neckline / Boundary:[/b]
A solid line at the critical breakout level, extending 20 bars beyond the current bar. For patterns with flat necklines (Double Tops, Rectangles), this is a horizontal line. For Head & Shoulders with sloped necklines, the line reflects the slope. The neckline color matches the phase color — shifting through purple, orange, and the directional color as the phase advances.

[b]Phase Label:[/b]
A label at the right edge of the formation showing the pattern name, current phase, and completion percentage. Positioned above price for bear patterns, below for bull patterns. The label color matches the phase.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 13-row real-time dashboard displays the complete state of the current highest-scoring pattern.

[b]RELAY STATE[/b]
[list]
[*][b]Pattern[/b] — the name of the current pattern: Double Top, Head & Shoulders, Asc Triangle, Bull Flag, Falling Wedge, etc. Color-coded yellow-green for bull, red for bear
[*][b]Phase[/b] — FORMING (purple), ARMED (orange), or FIRED (yellow-green/red). The most critical single row in the entire dashboard
[*][b]Formation[/b] — the live completion percentage. Orange when below 80%, yellow-green when above 80%
[*][b]Neckline[/b] — the exact price of the current neckline or boundary level in real time
[/list]

[b]LEVELS (FIRED)[/b]
[list]
[*][b]Entry[/b] — the computed entry price (current bar's open at FIRED). Shows — when pattern is still FORMING or ARMED
[*][b]TP1 / TP2[/b] — both take-profit targets displayed as a price pair
[*][b]Stop[/b] — the computed stop loss level
[/list]

[b]QUALITY[/b]
[list]
[*][b]Confluence[/b] — the pattern's score out of 10. Yellow-green when at or above the minimum threshold
[*][b]HTF · Chop[/b] — HTF bias (▲ BULL, ▼ BEAR, FLAT) and live Choppiness Index displayed on a single row. Orange CI indicates the chop gate is near or active
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Formation Box (FORMING — purple)[/b] — the developing pattern's price range from start to current bar, purple-tinted
[*][b]Formation Box (ARMED — orange)[/b] — box shifts to orange when price enters the ARMED zone. This color change on the chart is itself an alert
[*][b]Formation Box (FIRED — yellow-green / red)[/b] — pattern complete, box color reflects direction
[*][b]Neckline Line (solid, phase color)[/b] — the critical breakout level extending 20 bars forward
[*][b]Phase Label[/b] — pattern name, phase text, and completion percentage. Positioned at the right edge of the formation
[*][b]Entry Line (yellow-green dashed)[/b] — FIRED phase only, with "ENTRY x.xxxx" label
[*][b]SL Line (red dashed)[/b] — FIRED phase only, with "SL x.xxxx" label
[*][b]TP1 Line (lime dotted)[/b] — FIRED phase only, with "TP1 x.xxxx" label
[*][b]TP2 Line (bright yellow-green dashed, width 2)[/b] — FIRED phase only, with "TP2 x.xxxx · R:R x.xx" label
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 [b]JSON Alert System[/b]

RELAY fires a structured JSON alert on every FIRED event, delivering complete trade parameters to webhook receivers.

[b]FIRED JSON structure:[/b]

## Source Code

````pine
// © AlphaX — RELAY v1.0
// Pattern Relay Engine — formation → armed → fired lifecycle.
// Companion to FORGE: scans patterns BEFORE breakout, scores completion %,
// anticipates neckline breaks with HTF confluence, TP1/TP2 on fire.
// Keywords: chart patterns, automatic, multitimeframe, breakout, confluence,
// double top, head and shoulders, triangle, flag, wedge, measured target, educational.

//@version=6
indicator("[ A L P H A X ] RELAY - Pattern Relay Engine", shorttitle="AlphaX RELAY",
  overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=80, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  SCANNER ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpScan = "Scanner Engine"
pivLen         = input.int(8, "Pivot Length", minval=3, maxval=20, group=grpScan,
  tooltip="Fractal sensitivity. Lower = more formations on scalping TFs.")
maxPivots      = input.int(120, "Max Pivots Stored", minval=20, maxval=500, group=grpScan)
symTol         = input.float(8.0, "Level Symmetry (%)", minval=1.0, step=0.5, group=grpScan) / 100
minFormPct     = input.float(55.0, "Min Formation % to Show", minval=40.0, maxval=90.0, step=5.0, group=grpScan)
armedAtr       = input.float(0.35, "ARMED Zone (xATR from neck)", minval=0.1, maxval=1.5, step=0.05, group=grpScan)
atrLen         = input.int(14, "ATR Length", minval=2, maxval=100, group=grpScan)

grpPat = "Pattern Types"
enDouble       = input.bool(true, "Double Top / Bottom", group=grpPat)
enHs           = input.bool(true, "Head & Shoulders / Inv H&S", group=grpPat)
enTriangle     = input.bool(true, "Triangles (Asc / Desc / Sym)", group=grpPat)
enFlag         = input.bool(true, "Flags & Pennants", group=grpPat)
enWedge        = input.bool(true, "Rising / Falling Wedge", group=grpPat)

// ═══════════════════════════════════════════════════════════════════════════════
//  BREAKOUT & QUALITY
// ═══════════════════════════════════════════════════════════════════════════════
grpQual = "AlphaX Quality Layer"
minConf        = input.int(5, "Min Confluence (of 10)", minval=3, maxval=10, group=grpQual)
useHtf         = input.bool(true, "HTF Bias Layer", group=grpQual)
htfTf          = input.timeframe("60", "HTF Timeframe", group=grpQual)
htfFast        = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpQual)
htfSlow        = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpQual)
requireHtfFire = input.bool(false, "Hard Block Counter-HTF FIRED", group=grpQual)
useChop        = input.bool(true, "Block Extreme Chop", group=grpQual)
chopLen        = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpQual)
chopMax        = input.float(62.0, "Chop Block Above", minval=50, maxval=80, step=0.5, group=grpQual)
useVolCoil     = input.bool(true, "Volume Coil Before Break", group=grpQual,
  tooltip="Rewards drying volume into neckline — classic pre-breakout behaviour.")
volLen         = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=grpQual)
volCoilMax     = input.float(0.85, "Max Vol vs Avg (coil)", minval=0.4, maxval=1.2, step=0.05, group=grpQual)
brkAtr         = input.float(0.6, "FIRED Break Margin (xATR)", minval=0.1, maxval=2.0, step=0.1, group=grpQual)
minRR          = input.float(1.5, "Min R:R at FIRED", minval=0.5, maxval=5.0, step=0.1, group=grpQual)
cooldown       = input.int(5, "Signal Cooldown (bars)", minval=1, maxval=50, group=grpQual)

// ═══════════════════════════════════════════════════════════════════════════════
//  TARGETS & DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
grpVis = "Targets & Display"
showFormBox    = input.bool(true, "Show Formation Box", group=grpVis)
showNeck       = input.bool(true, "Show Neckline / Boundary", group=grpVis)
showPhaseLbl   = input.bool(true, "Show Phase Labels", group=grpVis)
showFiredLvls  = input.bool(true, "Show Entry / SL / TP1 / TP2 on FIRED", group=grpVis)
tp1Pct         = input.float(50.0, "TP1 (% of Entry → TP2)", minval=10.0, maxval=90.0, step=5.0, group=grpVis) / 100
slPctTgt       = input.float(25.0, "SL % of Target Distance", minval=5.0, maxval=50.0, step=5.0, group=grpVis) / 100
showDash       = input.bool(true, "Show Dashboard", group=grpVis)
dashPos        = input.string("Top Right", "Dashboard Position",
  options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

grpColors = "Colors (AlphaX Palette)"
colBull        = input.color(#c8e624, "Bull", group=grpColors)
colBullBr      = input.color(#d4f03a, "Bull Bright", group=grpColors)
colBear        = input.color(#ff1744, "Bear", group=grpColors)
colBearBr      = input.color(#ff5252, "Bear Bright", group=grpColors)
colForm        = input.color(#8b6fd0, "FORMING", group=grpColors)
colArmed       = input.color(#ff9800, "ARMED", group=grpColors)
colFired       = input.color(#c8e624, "FIRED", group=grpColors)
colNeutral     = input.color(#555555, "Neutral", group=grpColors)
colSlLine      = input.color(#ff1744, "Stop", group=grpColors)
colTp1Line     = input.color(#9ccc65, "TP1", group=grpColors)
colTp2Line     = input.color(#c8e624, "TP2", group=grpColors)
colTextLt      = input.color(#cccccc, "Dash Text", group=grpColors)
colDashBg      = input.color(#1a1a1a, "Dash BG", group=grpColors)
colDashHeader  = input.color(#111111, "Dash Header", group=grpColors)
colDashSec     = input.color(#222222, "Dash Section", group=grpColors)
colDashFrame   = input.color(#c8e624, "Dash Frame", group=grpColors)

grpAlrt = "Alerts"
alertEn        = input.bool(true, "JSON Alerts on FIRED", group=grpAlrt)

// ═══════════════════════════════════════════════════════════════════════════════
//  TYPES
// ═══════════════════════════════════════════════════════════════════════════════
type Pivot
    float p
    int   i

type RelaySetup
    bool   active
    string name
    string phase          // FORMING | ARMED | FIRED
    bool   isBull
    float  completion     // 0–100
    float  neck
    float  height
    float  entry
    float  stop
    float  tp2
    int    startBar
    int    endBar
    int    conf

type DrawBundle
    line[]  lns
    label[] lbls
    box[]   boxes

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════════════════
var RelaySetup EMPTY = RelaySetup.new(false, "", "", false, 0, na, na, na, na, na, na, na, 0)
var array<Pivot> pivH = array.new<Pivot>()
var array<Pivot> pivL = array.new<Pivot>()
var array<DrawBundle> history = array.new<DrawBundle>()

var string dName = "—"
var string dPhase = "IDLE"
var bool   dBull = false
var float  dComp = 0.0
var float  dNeck = na
var float  dEntry = na
var float  dStop = na
var float  dTp1 = na
var float  dTp2 = na
var int    dConf = 0
var int    dLastBar = 0

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE
// ═══════════════════════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
volMa  = ta.sma(volume, volLen)

float ciSum = math.sum(ta.atr(1), chopLen)
float ciHl  = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
float chopIdx = ciHl > 0 ? 100.0 * math.log10(ciSum / ciHl) / math.log10(chopLen) : 50.0
bool chopOk = not useChop or chopIdx < chopMax

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFastE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFast), barmerge.gaps_off, barmerge.lookahead_off)
htfSlowE = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlow), barmerge.gaps_off, barmerge.lookahead_off)
htfBull  = htfFastE > htfSlowE and htfClose > htfFastE
htfBear  = htfFastE < htfSlowE and htfClose < htfFastE

getDashPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_near(float a, float b) =>
    math.abs(a - b) <= (a + b) * 0.5 * symTol

f_proj(float x1, float y1, float x2, float y2, int x) =>
    x2 == x1 ? y1 : y1 + (y2 - y1) / (x2 - x1) * (x - x1)

f_rr(float ep, float sl, float tp) =>
    math.abs(ep - sl) > 0 ? math.abs(tp - ep) / math.abs(ep - sl) : 0.0

f_tp1(float ep, float tp2, bool bull) =>
    float d = math.abs(tp2 - ep)
    bull ? ep + d * tp1Pct : ep - d * tp1Pct

f_conf(RelaySetup s) =>
    if not s.active
        0
    else
        int sc = 0
        sc += s.completion >= 85 ? 2 : s.completion >= minFormPct ? 1 : 0
        sc += s.isBull and htfBull and useHtf ? 2 : not s.isBull and htfBear and useHtf ? 2 : useHtf ? 0 : 1
        sc += chopOk ? 1 : 0
        sc += s.phase == "FIRED" ? 2 : s.phase == "ARMED" ? 1 : 0
        sc += useVolCoil and volMa > 0 and volume <= volMa * volCoilMax ? 1 : 0
        sc += f_rr(s.entry, s.stop, s.tp2) >= minRR ? 1 : 0
        sc += s.height >= atrVal * 1.5 ? 1 : 0
        math.min(sc, 10)

f_phaseColor(string ph) =>
    ph == "FIRED" ? colFired : ph == "ARMED" ? colArmed : colForm

f_clearDrawings() =>
    for b in history
        for ln in b.lns
            if not na(ln)
                line.delete(ln)
        for lb in b.lbls
            if not na(lb)
                label.delete(lb)
        for bx in b.boxes
            if not na(bx)
                box.delete(bx)
    array.clear(history)

// Pivot collection
float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)
if not na(ph)
    pivH.unshift(Pivot.new(ph, bar_index - pivLen))
    if pivH.size() > maxPivots
        pivH.pop()
if not na(pl)
    pivL.unshift(Pivot.new(pl, bar_index - pivLen))
    if pivL.size() > maxPivots
        pivL.pop()

// ═══════════════════════════════════════════════════════════════════════════════
//  FORMATION SCANNERS (lifecycle — not post-breakout only)
// ═══════════════════════════════════════════════════════════════════════════════
detectDoubleForm() =>
    RelaySetup s = EMPTY
    if pivH.size() >= 2 and pivL.size() >= 1 and enDouble
        Pivot p1 = pivH.get(0)
        Pivot p2 = pivH.get(1)
        Pivot mid = pivL.get(0)
        if p1.i > mid.i and mid.i > p2.i and f_near(p1.p, p2.p)
            float neck = mid.p
            float h = (p1.p + p2.p) * 0.5 - neck
            if h > atrVal
                float comp = 70.0
                comp += close < neck ? 15.0 : 0.0
                comp += math.abs(close - neck) <= atrVal * armedAtr ? 15.0 : 0.0
                bool fired = close < neck - atrVal * brkAtr
                string ph = fired ? "FIRED" : math.abs(close - neck) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = neck - h
                float sl = ep + math.abs(tp2 - ep) * slPctTgt
                s := RelaySetup.new(true, "Double Top", ph, false, comp, neck, h, ep, sl, tp2, p2.i, bar_index, 0)
    if not s.active and pivL.size() >= 2 and pivH.size() >= 1 and enDouble
        Pivot p1 = pivL.get(0)
        Pivot p2 = pivL.get(1)
        Pivot mid = pivH.get(0)
        if p1.i > mid.i and mid.i > p2.i and f_near(p1.p, p2.p)
            float neck = mid.p
            float h = neck - (p1.p + p2.p) * 0.5
            if h > atrVal
                float comp = 70.0
                comp += close > neck ? 15.0 : 0.0
                comp += math.abs(close - neck) <= atrVal * armedAtr ? 15.0 : 0.0
                bool fired = close > neck + atrVal * brkAtr
                string ph = fired ? "FIRED" : math.abs(close - neck) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = neck + h
                float sl = ep - math.abs(tp2 - ep) * slPctTgt
                s := RelaySetup.new(true, "Double Bottom", ph, true, comp, neck, h, ep, sl, tp2, p2.i, bar_index, 0)
    s

detectHsForm() =>
    RelaySetup s = EMPTY
    if pivH.size() >= 3 and pivL.size() >= 2 and enHs
        Pivot rs = pivH.get(0)
        Pivot head = pivH.get(1)
        Pivot ls = pivH.get(2)
        Pivot nl = pivL.get(1)
        Pivot nr = pivL.get(0)
        if head.p > rs.p and head.p > ls.p and f_near(rs.p, ls.p)
            float neck = f_proj(nl.i, nl.p, nr.i, nr.p, bar_index)
            float h = head.p - (nl.p + nr.p) * 0.5
            if h > atrVal
                float comp = 65.0
                comp += close < neck ? 12.0 : 0.0
                comp += math.abs(close - neck) <= atrVal * armedAtr ? 18.0 : 0.0
                string ph = close < neck - atrVal * brkAtr ? "FIRED" : math.abs(close - neck) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = neck - h
                float sl = ep + math.abs(tp2 - ep) * slPctTgt
                s := RelaySetup.new(true, "Head & Shoulders", ph, false, comp, neck, h, ep, sl, tp2, ls.i, bar_index, 0)
    if not s.active and pivL.size() >= 3 and pivH.size() >= 2 and enHs
        Pivot rs = pivL.get(0)
        Pivot head = pivL.get(1)
        Pivot ls = pivL.get(2)
        Pivot nh = pivH.get(1)
        Pivot rh = pivH.get(0)
        if head.p < rs.p and head.p < ls.p and f_near(rs.p, ls.p)
            float neck = f_proj(nh.i, nh.p, rh.i, rh.p, bar_index)
            float h = (nh.p + rh.p) * 0.5 - head.p
            if h > atrVal
                float comp = 65.0
                comp += close > neck ? 12.0 : 0.0
                comp += math.abs(close - neck) <= atrVal * armedAtr ? 18.0 : 0.0
                string ph = close > neck + atrVal * brkAtr ? "FIRED" : math.abs(close - neck) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = neck + h
                float sl = ep - math.abs(tp2 - ep) * slPctTgt
                s := RelaySetup.new(true, "Inv H&S", ph, true, comp, neck, h, ep, sl, tp2, ls.i, bar_index, 0)
    s

detectTriangleForm() =>
    RelaySetup s = EMPTY
    if pivH.size() >= 2 and pivL.size() >= 2 and enTriangle
        Pivot h1 = pivH.get(0)
        Pivot h2 = pivH.get(1)
        Pivot l1 = pivL.get(0)
        Pivot l2 = pivL.get(1)
        float uNow = f_proj(h2.i, h2.p, h1.i, h1.p, bar_index)
        float lNow = f_proj(l2.i, l2.p, l1.i, l1.p, bar_index)
        float base = math.abs(f_proj(h2.i, h2.p, h1.i, h1.p, l2.i) - f_proj(l2.i, l2.p, l1.i, l1.p, l2.i))
        bool conv = uNow > lNow and base > atrVal
        if conv
            float su = (h1.p - h2.p) / math.max(1, h1.i - h2.i)
            float sl = (l1.p - l2.p) / math.max(1, l1.i - l2.i)
            bool asc = math.abs(su) < close * 0.0003 and sl > 0
            bool desc = su < 0 and math.abs(sl) < close * 0.0003
            bool bullBreak = close > uNow + atrVal * brkAtr
            bool bearBreak = close < lNow - atrVal * brkAtr
            if bullBreak or (not bearBreak and (asc or su < 0))
                float comp = 60.0 + (base / atrVal > 2 ? 15 : 5)
                comp += math.abs(close - uNow) <= atrVal * armedAtr ? 15.0 : 0.0
                string ph = bullBreak ? "FIRED" : math.abs(close - uNow) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = uNow + base
                float sl = lNow
                string nm = asc ? "Asc Triangle" : "Sym Triangle"
                s := RelaySetup.new(true, nm, ph, true, comp, uNow, base, ep, sl, tp2, l2.i, bar_index, 0)
            else if bearBreak or desc
                float comp = 60.0 + (base / atrVal > 2 ? 15 : 5)
                comp += math.abs(close - lNow) <= atrVal * armedAtr ? 15.0 : 0.0
                string ph = bearBreak ? "FIRED" : math.abs(close - lNow) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = lNow - base
                float sl = uNow
                string nm = desc ? "Desc Triangle" : "Sym Triangle"
                s := RelaySetup.new(true, nm, ph, false, comp, lNow, base, ep, sl, tp2, l2.i, bar_index, 0)
    s

detectFlagForm() =>
    RelaySetup s = EMPTY
    if pivH.size() >= 2 and pivL.size() >= 2 and enFlag
        Pivot h1 = pivH.get(0)
        Pivot h2 = pivH.get(1)
        Pivot l1 = pivL.get(0)
        Pivot l2 = pivL.get(1)
        int sb = math.min(h2.i, l2.i)
        int span = bar_index - sb + 1
        float pole = span > 5 ? ta.highest(high, math.min(span, 120)) - ta.lowest(low, math.min(span, 120)) : 0.0
        float su = (h1.p - h2.p) / math.max(1, h1.i - h2.i)
        float slo = (l1.p - l2.p) / math.max(1, l1.i - l2.i)
        if pole > atrVal * 2.5
            if su < 0 and slo < 0
                float uB = f_proj(h2.i, h2.p, h1.i, h1.p, bar_index)
                float comp = 62.0
                comp += math.abs(close - uB) <= atrVal * armedAtr ? 20.0 : 0.0
                bool fired = close > uB + atrVal * brkAtr
                string ph = fired ? "FIRED" : math.abs(close - uB) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = uB + pole
                float sl = f_proj(l2.i, l2.p, l1.i, l1.p, bar_index)
                s := RelaySetup.new(true, "Bull Flag", ph, true, comp, uB, pole, ep, sl, tp2, sb, bar_index, 0)
            else if su > 0 and slo > 0
                float lB = f_proj(l2.i, l2.p, l1.i, l1.p, bar_index)
                float comp = 62.0
                comp += math.abs(close - lB) <= atrVal * armedAtr ? 20.0 : 0.0
                bool fired = close < lB - atrVal * brkAtr
                string ph = fired ? "FIRED" : math.abs(close - lB) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = lB - pole
                float sl = f_proj(h2.i, h2.p, h1.i, h1.p, bar_index)
                s := RelaySetup.new(true, "Bear Flag", ph, false, comp, lB, pole, ep, sl, tp2, sb, bar_index, 0)
    s

detectWedgeForm() =>
    RelaySetup s = EMPTY
    if pivH.size() >= 2 and pivL.size() >= 2 and enWedge
        Pivot h1 = pivH.get(0)
        Pivot h2 = pivH.get(1)
        Pivot l1 = pivL.get(0)
        Pivot l2 = pivL.get(1)
        float su = (h1.p - h2.p) / math.max(1, h1.i - h2.i)
        float slo = (l1.p - l2.p) / math.max(1, l1.i - l2.i)
        float uB = f_proj(h2.i, h2.p, h1.i, h1.p, bar_index)
        float lB = f_proj(l2.i, l2.p, l1.i, l1.p, bar_index)
        if uB > lB
            if su < 0 and slo < 0 and slo < su
                float comp = 58.0 + math.min(20.0, (uB - lB) / atrVal * 5)
                bool fired = close > uB + atrVal * brkAtr
                string ph = fired ? "FIRED" : math.abs(close - uB) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = h2.p
                float sl = lB
                s := RelaySetup.new(true, "Falling Wedge", ph, true, comp, uB, uB - lB, ep, sl, tp2, l2.i, bar_index, 0)
            else if su > 0 and slo > 0 and slo > su
                float comp = 58.0 + math.min(20.0, (uB - lB) / atrVal * 5)
                bool fired = close < lB - atrVal * brkAtr
                string ph = fired ? "FIRED" : math.abs(close - lB) <= atrVal * armedAtr ? "ARMED" : "FORMING"
                float ep = open
                float tp2 = l2.p
                float sl = uB
                s := RelaySetup.new(true, "Rising Wedge", ph, false, comp, lB, uB - lB, ep, sl, tp2, l2.i, bar_index, 0)
    s

f_pickBest(RelaySetup a, RelaySetup b) =>
    if not b.active
        a
    else if not a.active
        b
    else
        float sa = f_conf(a) + a.completion * 0.05 + (a.phase == "FIRED" ? 3 : a.phase == "ARMED" ? 2 : 0)
        float sb = f_conf(b) + b.completion * 0.05 + (b.phase == "FIRED" ? 3 : b.phase == "ARMED" ? 2 : 0)
        sb > sa ? b : a

// ═══════════════════════════════════════════════════════════════════════════════
//  ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
RelaySetup cand = EMPTY
if bar_index > 200 and chopOk and pivH.size() >= 2 and pivL.size() >= 2
    cand := f_pickBest(cand, detectDoubleForm())
    cand := f_pickBest(cand, detectHsForm())
    cand := f_pickBest(cand, detectTriangleForm())
    cand := f_pickBest(cand, detectFlagForm())
    cand := f_pickBest(cand, detectWedgeForm())

int candConf = f_conf(cand)
if cand.active and cand.completion < minFormPct
    cand := EMPTY
if cand.active and cand.phase == "FIRED" and requireHtfFire
    if cand.isBull and not htfBull
        cand := EMPTY
    if not cand.isBull and not htfBear
        cand := EMPTY
if cand.active and cand.phase == "FIRED" and f_rr(cand.entry, cand.stop, cand.tp2) < minRR
    cand := EMPTY
if cand.active and candConf < minConf
    cand := EMPTY

var int lastFireBar = na
var string lastKey = ""
string candKey = cand.active ? cand.name + cand.phase + str.tostring(cand.startBar) : ""
bool newEvent = cand.active and barstate.isconfirmed and candKey != lastKey and (na(lastFireBar) or bar_index - lastFireBar >= cooldown)

if newEvent
    lastKey := candKey
    if cand.phase == "FIRED"
        lastFireBar := bar_index

    f_clearDrawings()
    DrawBundle db = DrawBundle.new(array.new_line(), array.new_label(), array.new_box())

    dName := cand.name
    dPhase := cand.phase
    dBull := cand.isBull
    dComp := cand.completion
    dNeck := cand.neck
    dEntry := cand.phase == "FIRED" ? cand.entry : na
    dStop := cand.phase == "FIRED" ? cand.stop : na
    dTp2 := cand.phase == "FIRED" ? cand.tp2 : na
    dTp1 := cand.phase == "FIRED" ? f_tp1(cand.entry, cand.tp2, cand.isBull) : na
    dConf := candConf
    dLastBar := bar_index

    color pc = f_phaseColor(cand.phase)
    color bc = cand.isBull ? colBull : colBear

    if showFormBox
        box bx = box.new(cand.startBar, cand.isBull ? cand.neck : cand.neck + cand.height,
          cand.endBar, cand.isBull ? cand.neck + cand.height : cand.neck,
          border_color=color.new(pc, 40), bgcolor=color.new(pc, 88))
        array.push(db.boxes, bx)

    if showNeck
        line ln = line.new(cand.startBar, cand.neck, cand.endBar + 20, cand.neck,
          color=color.new(pc, 0), width=2, style=line.style_solid)
        array.push(db.lns, ln)

    if showPhaseLbl
        string lblTxt = cand.name + "\n" + cand.phase + " " + str.tostring(cand.completion, "#") + "%"
        label lb = label.new(cand.endBar, cand.neck, lblTxt,
          color=color.new(colDashBg, 15), textcolor=pc, style=cand.isBull ? label.style_label_up : label.style_label_down, size=size.small)
        array.push(db.lbls, lb)

    if showFiredLvls and cand.phase == "FIRED"
        int x1 = bar_index
        int x2 = bar_index + 40
        int lx = x2 + 1
        float tp1v = f_tp1(cand.entry, cand.tp2, cand.isBull)
        line le = line.new(x1, cand.entry, x2, cand.entry, color=colBullBr, style=line.style_dashed)
        line ls = line.new(x1, cand.stop, x2, cand.stop, color=colSlLine, style=line.style_dashed)
        line l1 = line.new(x1, tp1v, x2, tp1v, color=colTp1Line, style=line.style_dotted)
        line l2 = line.new(x1, cand.tp2, x2, cand.tp2, color=colTp2Line, style=line.style_dashed, width=2)
        array.push(db.lns, le)
        array.push(db.lns, ls)
        array.push(db.lns, l1)
        array.push(db.lns, l2)
        label lbe = label.new(lx, cand.entry, "ENTRY " + str.tostring(cand.entry, format.mintick),
          style=label.style_label_left, color=color.new(colDashBg, 30), textcolor=colBullBr, size=size.tiny)
        label lbs = label.new(lx, cand.stop, "SL " + str.tostring(cand.stop, format.mintick),
          style=label.style_label_left, color=color.new(colDashBg, 30), textcolor=colSlLine, size=size.tiny)
        label lb1 = label.new(lx, tp1v, "TP1 " + str.tostring(tp1v, format.mintick),
          style=label.style_label_left, color=color.new(colDashBg, 30), textcolor=colTp1Line, size=size.tiny)
        label lb2 = label.new(lx, cand.tp2, "TP2 " + str.tostring(cand.tp2, format.mintick) + "  R:R " + str.tostring(f_rr(cand.entry, cand.stop, cand.tp2), "#.##"),
          style=label.style_label_left, color=color.new(colDashBg, 30), textcolor=colTp2Line, size=size.tiny)
        array.push(db.lbls, lbe)
        array.push(db.lbls, lbs)
        array.push(db.lbls, lb1)
        array.push(db.lbls, lb2)

        if alertEn
            string js = '{"source":"AlphaX RELAY","phase":"FIRED","pattern":"' + cand.name +
                 '","bias":"' + (cand.isBull ? "long" : "short") +
                 '","completion":' + str.tostring(cand.completion) +
                 ',"entry":' + str.tostring(cand.entry, format.mintick) +
                 ',"tp1":' + str.tostring(tp1v, format.mintick) +
                 ',"tp2":' + str.tostring(cand.tp2, format.mintick) +
                 ',"sl":' + str.tostring(cand.stop, format.mintick) +
                 ',"confluence":' + str.tostring(candConf) + '}'
            alert(js, alert.freq_once_per_bar_close)

    array.push(history, db)

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(getDashPos(dashPos), 2, 13,
  border_width=1, border_color=color.new(colDashFrame, 60),
  frame_width=1, frame_color=color.new(colDashFrame, 40))

if showDash and barstate.islast
    color dbg = color.new(colDashBg, 0)
    color sec = color.new(colDashSec, 0)
    color phCol = f_phaseColor(dPhase)

    table.cell(dash, 0, 0, "AlphaX RELAY", text_color=colBull, text_size=size.normal,
      bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period,
      text_color=color.new(colBull, 30), text_size=size.tiny, bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "─── RELAY STATE ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 1, "", bgcolor=sec)

    table.cell(dash, 0, 2, "PATTERN", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 2, dName, text_color=dBull ? colBull : colBear, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 3, "PHASE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 3, dPhase, text_color=phCol, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 4, "FORMATION", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 4, str.tostring(dComp, "#") + "%", text_color=dComp >= 80 ? colBull : colArmed, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 5, "NECKLINE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 5, not na(dNeck) ? str.tostring(dNeck, format.mintick) : "—", text_color=colTextLt, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 6, "─── LEVELS (FIRED) ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 6, "", bgcolor=sec)

    table.cell(dash, 0, 7, "ENTRY", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 7, not na(dEntry) ? str.tostring(dEntry, format.mintick) : "—", text_color=colBullBr, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 8, "TP1 / TP2", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 8, not na(dTp1) ? str.tostring(dTp1, format.mintick) + " / " + str.tostring(dTp2, format.mintick) : "—",
      text_color=colTp2Line, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 9, "STOP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 9, not na(dStop) ? str.tostring(dStop, format.mintick) : "—", text_color=colSlLine, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 10, "─── QUALITY ───", text_color=color.new(colNeutral, 20), text_size=size.tiny, bgcolor=sec, text_halign=text.align_center)
    table.cell(dash, 1, 10, "", bgcolor=sec)

    table.cell(dash, 0, 11, "CONFLUENCE", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 11, str.tostring(dConf) + " / 10", text_color=dConf >= minConf ? colBull : colNeutral, text_size=size.small, bgcolor=dbg)

    table.cell(dash, 0, 12, "HTF · CHOP", text_color=colTextLt, text_size=size.small, bgcolor=dbg)
    table.cell(dash, 1, 12, (htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "FLAT") + " · " + str.tostring(chopIdx, "#.#"),
      text_color=chopOk ? colTextLt : colArmed, text_size=size.small, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(newEvent and cand.phase == "ARMED" and cand.isBull, title="RELAY ARMED Long",
  message="[AlphaX RELAY] ARMED bullish formation on {{ticker}} {{interval}}.")
alertcondition(newEvent and cand.phase == "ARMED" and not cand.isBull, title="RELAY ARMED Short",
  message="[AlphaX RELAY] ARMED bearish formation on {{ticker}} {{interval}}.")
alertcondition(newEvent and cand.phase == "FIRED" and cand.isBull, title="RELAY FIRED Long",
  message="[AlphaX RELAY] FIRED long breakout on {{ticker}} {{interval}}.")
alertcondition(newEvent and cand.phase == "FIRED" and not cand.isBull, title="RELAY FIRED Short",
  message="[AlphaX RELAY] FIRED short breakout on {{ticker}} {{interval}}.")
````
