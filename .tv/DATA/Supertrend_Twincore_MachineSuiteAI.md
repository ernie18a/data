<!-- tradingview-pine-id: PUB;6490249ed2c64b268b1fa22447346e67 -->
<!-- tradingviewscripts-format: 1 -->
# Supertrend Twincore [MachineSuiteAI]

Source: https://www.tradingview.com/script/f8kVx1LK-Supertrend-Twincore-MachineSuiteAI/

## Description

Supertrend Twincore [MachineSuiteAI]

🟦 OVERVIEW

A fast Supertrend flips too often; a slow one flips too late. This script runs both at once and only signals when they agree — and then shows you, with win rates and sample sizes, how that agreement has actually performed on the chart you have loaded.

A signal only appears where the fast core (timing) and the slow core (structure) first align, and only if it passes a gate: clustered whipsaw flips always suppress, and every other filter blocks signals only where measurement shows it helps on this chart. Passed signals are graded A/B/C and draw an Entry / SL / TP1-3 ladder whose outcomes are tracked per grade. Suppressed candidates stay as grey ghost chips with the reason, and a five-row multi-timeframe strip shows the consensus state across timeframes from completed bars.

The idea throughout: the chart never claims more than the data supports, and anything the script believes is checkable in the panel.

🟦 WHAT IS A SUPERTREND?

https://www.tradingview.com/x/1wI3YC1Y/

Supertrend is a public-domain trailing-stop indicator: it offsets price by a multiple of the Average True Range and trails that stop behind the trend. Price above the stop means uptrend, below means downtrend; a close across it flips the state. This script computes its cores with the built-in ta.supertrend() — fast 2.0 × ATR(10) and slow 4.0 × ATR(20) by default.

Its known weakness is structural: in ranging markets the stop is repeatedly crossed and the indicator whipsaws. Filters are the usual answer; this script measures whether each one actually helps on the loaded symbol and timeframe, and the marks and the gate act only on that evidence.

🟦 WHY THIS SCRIPT IS ORIGINAL

https://www.tradingview.com/x/dJ7ISZ96/

The base calculation is a built-in, and the ingredients — win-rate panels, ADX gates, higher-timeframe confirmation, multi-timeframe dashboards, take-profit ladders, signal grades — are established ideas. What's different is the standard everything must meet: beyond one fixed whipsaw rule, nothing gets drawn, nothing blocks a signal, and nothing drives the engine unless the measurements on the loaded chart back it up.

- Graded ladder odds with the cost attached. Grades are fixed and published — A means structural confirmation plus volume, B one of the two, C neither; no opaque score. Every passed signal's ladder is tracked to resolution; the panel shows per grade: TP1-before-SL and SL-first rates, the median furthest level, the median heat (largest adverse move, in ATR units) and the median bars to TP1, each with its own sample size.
- An adaptive engine that has to beat the fixed one first. Both fast cores — fixed and adaptive — are measured as separate signal streams on the loaded chart, and the adaptive core only drives signals while it beats the fixed core by a set margin with enough samples. The A/B row shows the running comparison; on defaults it reports the adaptive layer as inert.
- Gates held to the same standard. The ✓ volume mark and ⚠ counter-trend warning only print where their split beats the base win rate by a configurable margin here. The ADX gate only blocks candidates where high-ADX candidates have beaten low-ADX candidates by that margin on this chart.
- Per-condition win-rate splits. The base candidate win rate, then the same measurement split by signal class, higher-timeframe agreement, volume confirmation, multi-timeframe alignment and volatility regime — six statistics, each with its own sample size, greyed below a minimum sample.
- Two kinds of signals, measured separately. A candidate exists only on the first bar the cores align and is classified as a structural confirmation (the slow core just flipped in) or a pullback rejoin (the fast core returned to a standing slow trend); a double flip on one bar is labeled same-bar. They are different trades, measured separately.
- Suppression you can audit. A gated-out candidate still prints — a hollow grey ghost chip with the specific reason — and still counts in every statistic, so the base rate is never inflated by counting only the survivors.
- Visual discipline. The band claims a direction only while both cores agree; its saturation drains as price nears the structural stop, so the exit warning arrives before the flip; NEUTRAL keeps a directional tint, so the last trend stays readable while standing aside. The price scale is held to the same rule — it carries the structural stop and the ladder's Entry, SL and TP1-3, each in its own colour, and nothing else; the band and the fast core draw on the chart but claim no axis label. Every visual property maps to something measured.

🟦 HOW IT WORKS

https://www.tradingview.com/x/4KC5tr1p/

- Cores: two standard Supertrends — the fast core times entries, the slow core defines structure and is the ladder's trailing stop. Presets: Scalp 1.5×ATR(7)/3.0×ATR(14), Intraday 2.0×ATR(10)/4.0×ATR(20), Swing 3.0×ATR(14)/5.0×ATR(28), or Custom.
- Gate and state model: flip-cluster suppression (2+ fast flips in 10 bars, on by default), the measured ADX gate (default "Where it helps (measured)"), and an optional strict higher-timeframe gate (off by default). The band turns grey NEUTRAL on low ADX (default ADX(14) < 20) or flip clustering.
- Higher-timeframe filter: a third Supertrend one regime up (auto-mapped ≤15m→4H, ≤1H→1D, ≤4H→3D, ≤1D→1W, else 1M; or manual), read from the last completed HTF bar.
- Statistics: on confirmed bars, every candidate — passed and suppressed — resolves N bars later (default 10); a win means the close moved in its direction. Splits grey below the minimum sample (default 20). Chip marks need their split to beat the base rate by ≥3 points (configurable); the ADX gate needs the high-ADX split to beat the low-ADX split by the same margin; volume confirmation is volume above 1.5× its 20-bar average.
- Ladder: at a passed signal's close, Entry is the close, SL is the slow-core stop (or the fast core, or a fixed k×ATR cap), TP1/2/3 default to 1/2/3 × ATR. It trails, marks TP touches ✓, freezes ✕ on an SL break, dims when resolved or consensus is lost, and feeds the per-grade LADDER ODDS rows. A live ladder tracks the right edge of the chart; once its stop is hit it stops there, so it stays a bounded record of that trade — targets it never reached are not credited later just because price eventually passed them, and the frozen right edge makes clear the trade was already over. The stop's ray spans only the stretch where that level was actually in force, because a trailing stop is a staircase rather than one line: on a long it starts below the entry and can ratchet above it, locking in profit, and the amber slow core shows the whole path. Each level prints its exact price on the price scale, so the figure for an order ticket reads straight off the axis while the chart labels stay short. The colours carry the geometry: entry green, the targets in the trade's own direction and the stop in the opposite hue, so the level that ends a trade never reads like the levels that pay it — and the slow core keeps its amber, so the stop stays distinguishable from the line it trails.
- Adaptive engine: a per-volatility-regime fast core A/B-measured against the fixed one, as described above; default factors are inert.
- MTF strip: five rows of full consensus state (UP / DOWN / SPLIT / NEUTRAL, with bars-in-state), each read from that timeframe's last completed bar. Auto mode starts at the chart's own timeframe and climbs — 4H gives 4H/D/W/M/3M. Lower timeframes are omitted by default: their consensus flips many times during a single trade taken here, so it says little about an outcome measured over days. Manual mode accepts any five, defaulting to the classic 15m/1H/4H/D/W.

🟦 HOW TO USE IT

- Read the panel first: consensus state, cores, regime, HTF agreement, then the measured rows. An ↑ means that condition has earned its margin on this chart; its absence means it hasn't.
- Chips carry their evidence: grade letter, live per-grade TP1 odds at sufficient sample, ✓ where volume has helped, ⚠ where fighting the higher timeframe has hurt. Ghost chips mean the script stood aside — the reason is on the chip.
- NEUTRAL and SPLIT mean stand aside. The coach line says this in plain language, and notes that a retouch of the entry after TP1 does not invalidate a live ladder — only the SL does.
- Reversal-only signal mode reserves the headline presentation for slow-core reversals; Discipline display mode strips the chart to the band alone (note: TP/SL alerts only fire while the ladder is drawn).
- Defaults are tuned on liquid crypto from 15-minute to weekly charts; the multipliers and ADX threshold are worth reviewing on other asset classes.

🟦 SETTINGS

Grouped as in the inputs dialog: consensus core (presets or custom multipliers) · higher-timeframe filter · state model & signal gate (ADX, flip-cluster, optional HTF gate, ghost chips) · trade ladder (SL geometry, TP multiples) · grade engine (certified or dynamic wiring) · adaptive engine · MTF strip · visuals and display modes · volume multiple (default 1.5×) · signal stats engine (horizon, minimum sample, gating margin) · JSON webhook alerts.

🟦 ALERTS

Consensus long / short · confirmed reversal long / short · Grade A long / short · TP1 / TP2 / TP3 touched · SL break · NEUTRAL started / ended · volatility regime changed · adaptive engagement changed. Create the classic alert conditions with "Once Per Bar Close" — they evaluate on live bars, and an intrabar state can revert before it counts. Optional JSON alert() events via a single "Any alert() function call" alert: signal events carry grade, entry and levels; TP/SL events identify the touched level; all carry symbol, timeframe, regime and state. The JSON events are close-gated and fire for every passed candidate, including rejoins the Reversal-only display mode demotes.

🟦 REPAINT & DATA NOTES

- All bookkeeping runs on confirmed bars; chips, ladders and statistics commit at bar close. Inside a forming bar the panel's consensus, cores, agreement, volume and coach line update live and are therefore PROVISIONAL — they can revert before the bar shuts. Price can also sit beyond a ladder's stop for the rest of a bar without resolving it: in the core SL modes the stop breaks when that core flips, which needs a confirmed close. The coach line says so when it happens.
- Higher-timeframe and strip values come from each timeframe's last completed bar — no repaint; intrabar changes up there show after that bar closes. The design assumes the HTF sits above the chart's timeframe — with Manual selection, keep it there.
- Ladder TP touches — and the Fixed mode's hard-stop touches — are detected from confirmed bars' highs/lows, starting the bar after entry; a bar touching several levels credits TPs before the stop. In the core SL modes the stop is not touch-based: it resolves only when its core flips, which needs a confirmed close — so a wick through the stop does not end a ladder, and the touch-credited TP rates are structurally friendlier than a hard-stop backtest of the same levels. The Fixed k×ATR mode is the geometry closest to a real hard stop.
- Statistics cover the loaded history and reset when the chart reloads with different history; lower timeframes load fewer bars. Greyed rows just mean the sample is too small to trust.
- Only the most recent 250 chips and ghost chips stay on the chart, so a live ladder's own labels can never be pushed off by TradingView's drawing limit; deep history keeps its band and cores but not its markers. Ladder odds count each ladder when it resolves, and in the rare case that more than 30 are open at once the oldest is counted at its current state rather than discarded — the sample is never silently trimmed.
- On a live bar the volume ratio is partial; judge it near the close. Volume features require a feed that supplies volume.

🟦 CREDITS

The Supertrend concept is public domain (popularized by Olivier Seban); ATR, ADX and the DMI are J. Welles Wilder's. The fixed cores use TradingView's built-in ta.supertrend(); the adaptive core re-implements the same algorithm to accept a per-bar factor. The consensus model, candidate classes, statistics engine, gates, grades, measured ladder, ghost chips, strip and band rendering were written from scratch for this script.

🟦 LIMITATIONS

- Supertrend lags by construction, and requiring two cores to agree makes entries later still — fewer, later, more heavily filtered signals is the intended trade-off.
- The NEUTRAL state derives from lagging measures (ADX, flip counts), so the first signals of a new trend can still arrive grey or be suppressed.
- All statistics are direction-only measurements over a fixed horizon; ladder odds are level measurements (TPs credit on a wick touch, core-mode stops resolve only on a confirmed core flip) — no fees, slippage, sizing or equity math. They are not a strategy backtest, they differ per symbol and timeframe, and they do not predict future outcomes.
- Without volume data the volume filter and its split stay inactive, and certified Grade A (confirmation + volume) is out of reach — signals cap at Grade B on volume-less feeds. Sample sizes on higher timeframes are structurally small; expect greyed rows there.
- The same asset on two different venues can show opposite states. A Supertrend flip is a threshold event: when price sits within a fraction of a percent of the band, a normal inter-exchange spread of a few basis points decides whether it crosses, and once one venue flips its stop jumps to the other side of price, so two nearly identical charts diverge sharply. This is inherent to the calculation, not a data error — treat a signal as belonging to the feed it was measured on, and check the panel's sample sizes on the venue you actually trade.

🟦 DISCLAIMER

This is an educational analysis tool, not investment advice. Historical measurements, however carefully computed, do not predict future results. Trading involves substantial risk.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MachineSuiteAI

//@version=6
// max_bars_back is declared explicitly because the stats engine reads candidate
// series at a user-set offset (up to 100 bars) and ta.barssince has no fixed
// lookback: Pine's automatic inference can come up short and abort the script at
// runtime, which resets the chart viewport on pan/resize. The VALUE is kept at
// the stock 300 — the declaration is what fixes the inference, and the deepest
// reference is lookF = 100, so a larger buffer only adds memory per series
// (which matters on bar-heavy lower-timeframe charts).
indicator("Supertrend Twincore [MachineSuiteAI]", overlay = true, max_labels_count = 500, max_lines_count = 100, max_bars_back = 300)
// Dual-SuperTrend consensus indicator: a fast core and a slow core must agree
// before a signal exists, with an ADX/whipsaw NEUTRAL state, evidence-gated
// filters measured live on the chart (win rates with sample sizes), a graded
// Entry/SL/TP ladder with per-grade hit rates, and a repaint-safe multi-
// timeframe consensus strip. All values commit at bar close.

// ─────────────────────────────── INPUTS ─────────────────────────────────────
grpC = "Consensus core"
preset = input.string("Intraday", "Profile", options = ["Scalp", "Intraday", "Swing", "Custom"], group = grpC,
     tooltip = "Scalp 1.5×ATR(7) / 3.0×ATR(14) · Intraday 2.0×ATR(10) / 4.0×ATR(20) · Swing 3.0×ATR(14) / 5.0×ATR(28). Custom uses the fields below. Intraday is the default on every timeframe; Scalp reacts faster and produces more signals.")
fAtrIn = input.int(10,  "Fast ATR length", minval = 1, maxval = 200, group = grpC)
fFacIn = input.float(2.0, "Fast multiplier", minval = 0.5, step = 0.1, group = grpC)
sAtrIn = input.int(20,  "Slow ATR length", minval = 1, maxval = 200, group = grpC)
sFacIn = input.float(4.0, "Slow multiplier", minval = 0.5, step = 0.1, group = grpC,
     tooltip = "The slow core is the STRUCTURE: its stepped line is the trade ladder's dynamic stop, and the MTF strip reads consensus against it.")
int   fAtr = preset == "Custom" ? fAtrIn : preset == "Scalp" ? 7  : preset == "Swing" ? 14 : 10
float fFac = preset == "Custom" ? fFacIn : preset == "Scalp" ? 1.5 : preset == "Swing" ? 3.0 : 2.0
int   sAtr = preset == "Custom" ? sAtrIn : preset == "Scalp" ? 14 : preset == "Swing" ? 28 : 20
float sFac = preset == "Custom" ? sFacIn : preset == "Scalp" ? 3.0 : preset == "Swing" ? 5.0 : 4.0

grpH = "Higher-timeframe filter"
htfMode = input.string("Auto", "HTF selection", options = ["Auto", "Manual"], group = grpH,
     tooltip = "Auto maps the chart TF up one regime: ≤15m→4H · ≤1H→1D · ≤4H→3D · ≤1D→1W · else 1M.")
htfMan  = input.timeframe("D", "Manual HTF", group = grpH)
htfAtr  = input.int(10, "HTF ATR length", minval = 1, maxval = 200, group = grpH)
htfFac  = input.float(3.0, "HTF multiplier", minval = 0.5, step = 0.1, group = grpH)

grpN = "State model & signal gate"
greyAdx = input.bool(true, "NEUTRAL (grey) when ADX shows no trend", group = grpN,
     tooltip = "Controls the VISUAL neutral state (band grey). Whether low ADX also blocks SIGNALS is decided by the 'ADX gate on signals' setting below — the gate activates only where suppression measurably helps on the loaded chart.")
adxSigGate = input.string("Where it helps (measured)", "ADX gate on signals", options = ["Where it helps (measured)", "Always", "Off"], group = grpN,
     tooltip = "Where it helps (default): low-ADX candidates are suppressed only where the measured split on THIS symbol/timeframe shows suppression improving the win rate by the stats engine's margin (both samples ≥ minimum). Always: classic hard gate. Off: ADX never blocks signals. The flip-cluster gate below is independent and stays on by default.")
adxLen = input.int(14, "…ADX length", minval = 5, maxval = 100, inline = "ax", group = grpN)
adxThr = input.float(20, "threshold", minval = 10, maxval = 40, step = 1, inline = "ax", group = grpN)
greyCluster = input.bool(true, "NEUTRAL (grey) when flips cluster", group = grpN,
     tooltip = "Secondary NEUTRAL source: fast-core flips inside the window = acute whipsaw, regardless of ADX. This toggle also gates signals: flip clusters both grey the band and suppress candidates.")
chopK   = input.int(2,  "…flips within", minval = 2, inline = "ch", group = grpN)
chopWin = input.int(10, "bars", minval = 5, maxval = 100, inline = "ch", group = grpN)
greyHtf = input.bool(false, "NEUTRAL (grey) when HTF disagrees", group = grpN,
     tooltip = "OFF by default: the higher timeframe lags this one by construction. The panel's HTF row and the ⚠ chips already carry the disagreement; turn this on only if you want the strictest possible gate.")
showGhost = input.bool(true, "Ghost chips for suppressed candidates", group = grpN,
     tooltip = "A suppressed candidate is drawn as a hollow grey chip with the suppression reason — the judgment is visible, auditable, and honest.")

grpL = "Trade ladder"
showLadder = input.bool(true, "Draw Entry / SL / TP ladder on passed signals", group = grpL,
     tooltip = "At bar close of a passed signal: ENTRY at close, SL at the slow-core stop (trails as the slow core ratchets), TP1/2/3 at the ATR multiples below. Rays persist until the next signal. Each level's exact price prints on the price scale — entry green, targets in the trade's direction, stop in the opposite hue — so it can be read off for an order. Levels and hit alerts only — never P&L. TP/SL alerts fire only while the drawn ladder is active (ladder on, Full display mode).")
slCoreIn = input.string("Slow core (structural)", "SL core", options = ["Slow core (structural)", "Fast core (tight)", "Fixed (k×ATR hard cap)"], group = grpL,
     tooltip = "The ladder's SL geometry. Slow core (default) = the structural trailing stop — the widest room to run; its cost is heat and time in the trade. Fast core = tight, exits early, gives up continuation. Fixed k×ATR = hard stop at entry ± k×ATR (k below) with the slow-core flip as backstop — a bounded worst case. The per-grade LADDER ODDS accumulate under whichever geometry you pick.")
slKx = input.float(2.5, "…fixed SL distance k×ATR", minval = 0.5, step = 0.1, group = grpL,
     tooltip = "Only used with SL core = Fixed. The tradeoff is monotone: larger k = more ladders survive to their TPs, at the price of a larger bounded worst case.")
tp1x = input.float(1.0, "TP1 ×ATR", minval = 0.1, step = 0.1, inline = "tp", group = grpL)
tp2x = input.float(2.0, "TP2", minval = 0.1, step = 0.1, inline = "tp", group = grpL)
tp3x = input.float(3.0, "TP3", minval = 0.1, step = 0.1, inline = "tp", group = grpL)

grpG = "Grade engine"
gradeMode = input.string("Certified (fixed)", "Grade wiring", options = ["Certified (fixed)", "Dynamic (measured here)"], group = grpG,
     tooltip = "Certified (default): Grade A = confirmation + volume, B = one, C = none — a fixed, published factor set, identical on every chart; the local evidence rows are displays, not wiring. Dynamic: factors participate only where they earn their margin on THIS chart (the panel's ↑ rows).")
mtfMin = input.int(3, "MTF rows for the alignment factor", minval = 1, maxval = 5, group = grpG,
     tooltip = "The MTF-strip factor counts strip rows whose consensus state matches the signal (chart row included); this many matching rows = the factor is present. Used by Dynamic grade wiring only (the default Certified wiring is confirmation + volume); the MTF-aligned stats row measures it either way. Grade thresholds: A = ≥2 factors · B = 1 · C = 0 — no opaque score.")

grpA = "Adaptive engine"
adaMode = input.string("Where it helps (measured)", "Adaptive fast core", options = ["Where it helps (measured)", "Always", "Off"], group = grpA,
     tooltip = "The script always computes BOTH fast cores — fixed (Consensus core settings) and adaptive (per-regime factors below) — and measures both signal streams on this chart. Where it helps (default): the adaptive core drives signals only where its measured split beats the fixed core by the stats margin. The factors below default to 2.0 — equal to the Intraday profile's fixed core, so adaptivity ships inert and must prove itself on your chart first. Change them and the A/B row will tell you the truth.")
facLow  = input.float(2.0, "LOW-vol factor",  minval = 0.5, step = 0.1, inline = "af", group = grpA)
facMid  = input.float(2.0, "MID", minval = 0.5, step = 0.1, inline = "af", group = grpA)
facHigh = input.float(2.0, "HIGH", minval = 0.5, step = 0.1, inline = "af", group = grpA,
     tooltip = "Fast-core factor per volatility regime (ATR length stays the fast core's). ALL defaults are 2.0 — equal to the Intraday profile's fixed core; on the Scalp/Swing profiles they differ from the fixed factor, and the A/B measures them as a real alternative. Change these and the Adaptive row tells you the truth on this chart.")
regWin = input.int(250, "Regime window (bars)", minval = 50, maxval = 500, group = grpA,
     tooltip = "Normalized ATR (ATR/close) percentile-ranked over this window: LOW < p33 · MID · HIGH > p66. Percentile bands — simple, auditable, repaint-safe.")

grpM = "MTF consensus strip"
showStrip = input.bool(true, "Show strip", group = grpM,
     tooltip = "Each row = the FULL consensus state on that timeframe (both cores + NEUTRAL model), read repaint-safe from the last completed bar, with bars since the state changed. ▶ marks the chart's own timeframe.")
stripModeIn = input.string("Auto (follows chart TF)", "Strip timeframes", options = ["Auto (follows chart TF)", "Manual (TF 1–5 below)"], group = grpM,
     tooltip = "Auto (default): the five rows START at the chart's own timeframe and climb — 4H gives 4H/D/W/M/3M, 1D gives D/W/M/3M/12M, 15m gives 15m/1H/4H/D/W. Rows below the chart timeframe are deliberately not shown: a lower-timeframe consensus flips constantly, never governs a decision taken on this chart, and costs far more to compute than the chart itself. Manual: the TF 1–5 fields below, verbatim — their defaults are 15m/1H/4H/D/W, so switching to Manual reproduces the classic sub-chart set exactly, at its compute cost. Display + context only — the certified grades (confirm+volume) never read the strip; the MTF-aligned stats row measures against whichever ladder is shown.")
stripPos = input.string("Bottom left", "Strip position", options = ["Bottom left", "Bottom right", "Top left", "Top right", "Middle left", "Middle right"], group = grpM)
tf1 = input.timeframe("15",  "TF 1", inline = "t1", group = grpM)
tf2 = input.timeframe("60",  "TF 2", inline = "t1", group = grpM)
tf3 = input.timeframe("240", "TF 3", inline = "t2", group = grpM)
tf4 = input.timeframe("D",   "TF 4", inline = "t2", group = grpM)
tf5 = input.timeframe("W",   "TF 5", inline = "t2", group = grpM)

grpV = "Visuals"
vizStyle = input.string("Band (tight)", "Style", options = ["Band (tight)", "Line + cloud"], group = grpV,
     tooltip = "Band (default): the signature breathing band on the fast core, colored by direction, saturated by conviction. Line + cloud: single basis line with the gradient risk-buffer cloud to the fast stop.")
bandSm   = input.int(5, "Flip crossing smoothness (bars)", minval = 1, maxval = 15, group = grpV)
bandSlow = input.int(30, "Band structure length (slow edge)", minval = 10, maxval = 100, group = grpV,
     tooltip = "The band's second edge is a slower EMA — two independently moving curves, so the band twists and breathes with momentum.")
bandCap  = input.float(1.0, "Band body width × ATR", minval = 0.2, maxval = 2.0, step = 0.1, group = grpV)
gradOn   = input.bool(true, "Trend-strength gradient (early-exit warning)", group = grpV,
     tooltip = "Band saturation additionally scales with the ATR-normalized distance of price to the SLOW core. Price approaching the structural stop drains the color — the exit warning arrives before the flip does.")
gradN    = input.float(3.0, "…full saturation at ×ATR from slow core", minval = 0.5, step = 0.5, group = grpV)
showZone = input.bool(true, "Consensus zone (shade between the cores)", group = grpV,
     tooltip = "Shaded ONLY while both cores agree on direction. No shading = the cores are split = no consensus exists.")
showSlow = input.bool(true, "Slow core stepped line (amber)", group = grpV)
showFast = input.bool(true, "Fast core stepped line (thin grey)", group = grpV)
markerStyle = input.string("Chips", "Signal markers", options = ["Chips", "Dots", "Off"], group = grpV,
     tooltip = "Chips carry the evidence marks (✓ volume, ⚠ counter-HTF). Dots are the minimal, low-ink alternative.")
sigModeIn = input.string("All consensus signals", "Signal mode", options = ["All consensus signals", "Reversal-only (slow-core flips)"], group = grpV,
     tooltip = "All consensus signals: confirm AND rejoin candidates print full chips and commit the drawn ladder. Reversal-only: the headline presentation is reserved for signals where the SLOW core flipped into alignment — the structural confirmation class; rejoin candidates print as small context markers and do not redraw the ladder. DISPLAY-ONLY: the stats engine, grade odds and measured ladders still run on every candidate. For alerts in this mode, use the 'Confirmed reversal' alertconditions.")
bandHueIn = input.string("Consensus (calm)", "Band hue follows", options = ["Consensus (calm)", "Fast core (classic)"], group = grpV,
     tooltip = "Consensus (default): the band claims a direction only while BOTH cores agree — split = neutral tint on the slow core's side. The band flips visibly less in this mode. Fast core (classic): hue follows the fast core, the earliest and most active read. Display-only; band geometry and pinch anchors are unchanged either way.")
displayMode = input.string("Full", "Display mode", options = ["Full", "Discipline (band only)"], group = grpV,
     tooltip = "Discipline mode strips the chart to the band alone — no core lines, no markers, no ladder, no zone. The state is the only information; there is nothing to argue with. Note: the ladder's TP/SL alerts only fire while the ladder is drawn, so they are off in this mode.")
lineW     = input.int(3, "Line width", minval = 1, maxval = 5, group = grpV)
showFill  = input.bool(true, "Trend fill (gradient cloud, Line + cloud style)", group = grpV)
fillTr    = input.int(70, "Fill transparency at the line", minval = 40, maxval = 95, group = grpV)
colorBars = input.bool(false, "Color candles by trend", group = grpV)
showTable = input.bool(true, "State panel", group = grpV)
panelPos  = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right", "Middle left"], group = grpV)
showCoach = input.bool(true, "Coach line (plain-language state)", group = grpV)
cBull = input.color(#00E5FF, "Bull ", inline = "c", group = grpV)
cBear = input.color(#E040FB, "Bear ", inline = "c", group = grpV)
cSlow = input.color(#FFB300, "Slow core ", inline = "s", group = grpV)
cEntry = input.color(#27D98B, "Entry ", inline = "e", group = grpV,
     tooltip = "Entry gets the suite's green, the fourth accent alongside cyan, magenta and amber. The targets take the trade's own direction hue (Bull on a long, Bear on a short) and the STOP takes the opposite one — so the level that ends the trade never reads in the same colour as the levels that pay it, and a glance at the price scale tells you which side of the ladder you are looking at. The slow core stays amber, so the stop remains distinguishable from the line it trails.")
cNeuU = input.color(#7A93A8, "Neutral (was up) ", inline = "n", group = grpV,
     tooltip = "NEUTRAL keeps a directional tint: steel grey after a cyan trend, mauve grey after a magenta one.")
cNeuD = input.color(#A07E9C, "Neutral (was down)", inline = "n", group = grpV)

grpX = "Volume confirmation"
volX = input.float(1.5, "× 20-bar average volume", minval = 0.5, step = 0.1, group = grpX,
     tooltip = "Signals on volume above this multiple get an additive ✓ on their chip — where the stats engine proves it helps here. The panel's vol-confirmed row is the live answer for this chart.")

grpS = "Advanced — signal stats engine"
lookF = input.int(10, "Outcome measured after N bars", minval = 1, maxval = 100, group = grpS,
     tooltip = "Win = close N bars after a consensus candidate moved in its direction. Measured on this symbol/timeframe; the panel splits the win rate by signal class, HTF agreement, volume, MTF alignment, regime and ADX — the machine-verified answer to whether the gates and filters help HERE.")
minSample = input.int(20, "Minimum sample (greyed below)", minval = 1, group = grpS)
gateMode = input.string("Where it helps", "Chip markers (✓ / ⚠)", options = ["Where it helps", "Always", "Off"], group = grpS,
     tooltip = "Where it helps (default): the ✓ volume mark and ⚠ counter-HTF warning appear only when the measured split beats the base candidate win rate by the margin below (both samples ≥ minimum) on THIS symbol/timeframe.")
helpPts  = input.float(3, "…minimum improvement (win-rate points)", minval = 0, step = 0.5, group = grpS)

grpW = "Webhook alerts"
jsonAlerts = input.bool(false, "Fire structured JSON alert() events", group = grpW,
     tooltip = "In addition to the classic alertconditions: signal / TP / SL events fire alert() with a structured JSON payload (event, class, grade, symbol, tf, regime, engine, state, htf, vol; signal events add entry, sl, tp1-3) for webhook consumers. Create one alert on 'Any alert() function call'.")

// ─────────────────────────────── ENGINE ─────────────────────────────────────
// series-factor SuperTrend (exact ta.supertrend algorithm, factor may vary
// per bar — needed because the adaptive core's factor follows the regime)
f_stSer(float fac, simple int len) =>
    float aV = ta.atr(len)
    float lo = hl2 - fac * aV
    float up = hl2 + fac * aV
    var float lb = na
    var float ub = na
    var float stv = na
    var int d = 1
    float pLb = lb
    float pUb = ub
    float pSt = stv
    lb := na(pLb) or lo > pLb or close[1] < pLb ? lo : pLb
    ub := na(pUb) or up < pUb or close[1] > pUb ? up : pUb
    if na(aV[1])
        d := 1
    else if pSt == pUb
        d := close > ub ? -1 : 1
    else
        d := close < lb ? 1 : -1
    stv := d == -1 ? lb : ub
    [stv, d]

// volatility regime: 0 LOW · 1 MID · 2 HIGH (percentile bands, confirmed data)
float normVol = ta.atr(fAtr) / close
float volPr   = ta.percentrank(normVol, regWin)
int   clusterK = volPr < 33 ? 0 : volPr > 66 ? 2 : 1
string clusterNm = clusterK == 0 ? "LOW" : clusterK == 2 ? "HIGH" : "MID"
float facAda = clusterK == 0 ? facLow : clusterK == 2 ? facHigh : facMid

// BOTH fast cores, always: fixed (the shipped default) and adaptive
[stFix, dirFix] = ta.supertrend(fFac, fAtr)
[stAda, dirAda] = f_stSer(facAda, fAtr)
[stSlow, dirS] = ta.supertrend(sFac, sAtr)
bool fixUp  = dirFix < 0
bool adaUp  = dirAda < 0
bool slowUp = dirS < 0

// A/B streams: each core's OWN consensus first-alignments vs the same slow core
bool fixConsUp = fixUp and slowUp
bool fixConsDn = not fixUp and not slowUp
bool adaConsUp = adaUp and slowUp
bool adaConsDn = not adaUp and not slowUp
bool fixCand = (fixConsUp and not fixConsUp[1]) or (fixConsDn and not fixConsDn[1])
bool adaCand = (adaConsUp and not adaConsUp[1]) or (adaConsDn and not adaConsDn[1])
int  fixCandDir = fixConsUp and not fixConsUp[1] ? 1 : fixConsDn and not fixConsDn[1] ? -1 : 0
int  adaCandDir = adaConsUp and not adaConsUp[1] ? 1 : adaConsDn and not adaConsDn[1] ? -1 : 0
var int fxTot = 0
var int fxWin = 0
var int adTot = 0
var int adWin = 0

// engagement: the adaptive core must EARN control here (same pattern as the
// ADX gate and the chip marks) — counters lag one bar by construction
float wrFix = fxTot > 0 ? 100.0 * fxWin / fxTot : na
float wrAda = adTot > 0 ? 100.0 * adWin / adTot : na
bool adaMeasured = fxTot >= minSample and adTot >= minSample
bool adaHelps = adaMeasured and not na(wrFix) and not na(wrAda) and wrAda - wrFix >= helpPts
bool adaOn = adaMode == "Always" or (adaMode == "Where it helps (measured)" and adaHelps)
int regAge = ta.barssince(clusterK != clusterK[1])

// ACTIVE fast core — everything downstream keys off this.
// Flip detection runs on the ACTIVE core's OWN history: an engagement
// switch (adaOn changing) must never synthesize a flip the market never made.
float stF = adaOn ? stAda : stFix
bool fastUp = adaOn ? adaUp : fixUp
bool flipUpF = adaOn ? (adaUp and not adaUp[1]) : (fixUp and not fixUp[1])
bool flipDnF = adaOn ? (not adaUp and adaUp[1]) : (not fixUp and fixUp[1])
bool flipUpS = slowUp and not slowUp[1]
bool flipDnS = not slowUp and slowUp[1]

// consensus: both cores agree — the ONLY condition under which the zone
// shades and a candidate signal can exist (first-alignment bar)
bool consUp = fastUp and slowUp
bool consDn = not fastUp and not slowUp
// candidate = first-alignment on the ACTIVE core's own consensus stream
// (fixCons*/adaCons* above) — immune to engine-engagement switches
bool candLong  = adaOn ? (adaConsUp and not adaConsUp[1]) : (fixConsUp and not fixConsUp[1])
bool candShort = adaOn ? (adaConsDn and not adaConsDn[1]) : (fixConsDn and not fixConsDn[1])
bool candSig   = candLong or candShort
int  candDir   = candLong ? 1 : candShort ? -1 : 0

// higher timeframe: auto-map one regime up
float tfMin = timeframe.in_seconds(timeframe.period) / 60.0
string htfAuto =
     tfMin <= 15   ? "240" :
     tfMin <= 60   ? "D"   :
     tfMin <= 240  ? "3D"  :
     tfMin <= 1440 ? "W"   : "M"
string htfTF = htfMode == "Auto" ? htfAuto : htfMan

// last COMPLETED HTF bar (offset [1] + lookahead_on = confirmed value, no repaint)
f_htfDir() =>
    [_s, _d] = ta.supertrend(htfFac, htfAtr)
    _d
float hDirRaw = request.security(syminfo.tickerid, htfTF, f_htfDir()[1], lookahead = barmerge.lookahead_on)
bool htfUp = hDirRaw < 0
bool agree = consUp ? htfUp : consDn ? not htfUp : fastUp == htfUp

// volume confirmation
float volSMA = ta.sma(nz(volume), 20)
bool  volOk  = not na(volume) and volSMA > 0 and volume > volSMA * volX
float volRatio = volSMA > 0 ? nz(volume) / volSMA : na

var int lastFlipBar = na
// confirmed bars only: an intrabar flip that reverts by the close must not
// move the band's pinch anchor (a reverted flicker left a phantom pinch for
// bandSm bars); signals commit at close anyway, so nothing real is lost
if barstate.isconfirmed and (flipUpF or flipDnF)
    lastFlipBar := bar_index

// candidate context recorded at the candidate bar (resolved lookF bars later)
bool candConf = candLong ? htfUp : candShort ? not htfUp : false

// ── MTF consensus states (repaint-safe; feeds the strip AND the grade engine)
// encoding: state*1000 + min(bars-since-change, 999) · 0 UP · 1 DOWN · 2 SPLIT · 3 NEUTRAL
f_consEnc() =>
    [_f, _df] = ta.supertrend(fFac, fAtr)
    [_s, _ds] = ta.supertrend(sFac, sAtr)
    [_dp, _dm, _ax] = ta.dmi(adxLen, adxLen)
    bool _fu = _df < 0
    bool _su = _ds < 0
    float _fc = math.sum(_fu != _fu[1] ? 1.0 : 0.0, chopWin)
    bool _grey = (greyAdx and _ax < adxThr) or (greyCluster and _fc >= chopK)
    int _stt = _grey ? 3 : _fu and _su ? 0 : not _fu and not _su ? 1 : 2
    int _age = ta.barssince(_stt != _stt[1])
    _stt * 1000.0 + math.min(na(_age) ? 999 : _age, 999)

// AUTO STRIP: the five rows START at the chart's own timeframe and CLIMB the
// rung ladder 15m/1H/4H/D/W/M/3M/12M, clamped at the top. Rows below the chart
// timeframe were removed deliberately: on a consensus read they add almost no
// context (a 15m state flips constantly and never governs a 4H decision) while
// costing the overwhelming majority of the script's compute — a sub-chart row
// must be resampled from far more granular data than the chart itself holds
// (15m under a 4H chart is 16x the bars, and every row runs two supertrends,
// a DMI and a rolling sum). Climbing instead keeps every row cheaper than the
// chart and makes the strip answer the question it is actually for: what do
// the bigger timeframes say? _rung is a simple int, so every timeframe string
// stays a simple ternary — request.security-safe. Manual mode uses TF 1–5.
bool stripAuto = stripModeIn == "Auto (follows chart TF)"
int  _sec  = timeframe.in_seconds(timeframe.period)
int  _rung = _sec <= 900 ? 0 : _sec <= 3600 ? 1 : _sec <= 14400 ? 2 : _sec <= 86400 ? 3 : _sec <= 604800 ? 4 : 5
string tfS1 = stripAuto ? (_rung == 0 ? "15"  : _rung == 1 ? "60"  : _rung == 2 ? "240" : _rung == 3 ? "D"   : _rung == 4 ? "W"   : "M")    : tf1
string tfS2 = stripAuto ? (_rung == 0 ? "60"  : _rung == 1 ? "240" : _rung == 2 ? "D"   : _rung == 3 ? "W"   : _rung == 4 ? "M"   : "3M")   : tf2
string tfS3 = stripAuto ? (_rung == 0 ? "240" : _rung == 1 ? "D"   : _rung == 2 ? "W"   : _rung == 3 ? "M"   : _rung == 4 ? "3M"  : "12M")  : tf3
string tfS4 = stripAuto ? (_rung == 0 ? "D"   : _rung == 1 ? "W"   : _rung == 2 ? "M"   : _rung == 3 ? "3M"  : "12M")                       : tf4
string tfS5 = stripAuto ? (_rung == 0 ? "W"   : _rung == 1 ? "M"   : _rung == 2 ? "3M"  : "12M")                                            : tf5

// Note: request.* cannot live in a conditional block, so these five run even
// with the strip hidden — they also feed the panel's MTF-aligned statistic,
// which must stay honest whether or not the strip is displayed.
float e1 = request.security(syminfo.tickerid, tfS1, f_consEnc()[1], lookahead = barmerge.lookahead_on)
float e2 = request.security(syminfo.tickerid, tfS2, f_consEnc()[1], lookahead = barmerge.lookahead_on)
float e3 = request.security(syminfo.tickerid, tfS3, f_consEnc()[1], lookahead = barmerge.lookahead_on)
float e4 = request.security(syminfo.tickerid, tfS4, f_consEnc()[1], lookahead = barmerge.lookahead_on)
float e5 = request.security(syminfo.tickerid, tfS5, f_consEnc()[1], lookahead = barmerge.lookahead_on)

f_stt(float e) => na(e) ? -1 : int(e / 1000)
int mtfUpCnt = (f_stt(e1) == 0 ? 1 : 0) + (f_stt(e2) == 0 ? 1 : 0) + (f_stt(e3) == 0 ? 1 : 0) + (f_stt(e4) == 0 ? 1 : 0) + (f_stt(e5) == 0 ? 1 : 0)
int mtfDnCnt = (f_stt(e1) == 1 ? 1 : 0) + (f_stt(e2) == 1 ? 1 : 0) + (f_stt(e3) == 1 ? 1 : 0) + (f_stt(e4) == 1 ? 1 : 0) + (f_stt(e5) == 1 ? 1 : 0)
bool candMtf = candLong ? mtfUpCnt >= mtfMin : candShort ? mtfDnCnt >= mtfMin : false
bool candCalm = candSig and clusterK < 2   // LOW/MID regime at the signal bar

// three-state model (VISUAL state): ADX trendlessness + fast-flip clustering.
// Whether ADX also blocks signals is decided further down, by measurement.
[diP, diM, adxV] = ta.dmi(adxLen, adxLen)
float flipCnt = math.sum(flipUpF or flipDnF ? 1.0 : 0.0, chopWin)
bool  cluster = flipCnt >= chopK
// raw ADX read feeds the stats split and the signal gate; the greyAdx toggle
// controls ONLY the visual grey state — exactly what its tooltip promises
bool  adxLowRaw = adxV < adxThr
bool  adxLow  = greyAdx and adxLowRaw
bool  greyState = adxLow or (greyCluster and cluster) or (greyHtf and not agree)
bool  dispFull  = displayMode == "Full"

// candidate CLASS: structural confirmation vs pullback rejoin
bool flippedF = flipUpF or flipDnF
bool flippedS = slowUp != slowUp[1]
bool candConfirm = candSig and flippedS and not flippedF   // slow core flipped in — structural confirmation
bool candRejoin  = candSig and flippedF and not flippedS   // fast core rejoined the standing slow trend
// SIGNAL MODE (display-only): in Reversal-only mode the headline
// presentation (full chips, dots, drawn ladder) is reserved for slow-core
// flips (confirm + same-bar); rejoins demote to quiet context markers.
// Measurement never narrows — every candidate is still counted.
bool revOnly  = sigModeIn == "Reversal-only (slow-core flips)"
bool sigIsRev = flippedS   // the slow core flipped into alignment on this bar

// ── signal stats engine (anti-repaint: confirmed bars, resolved at +lookF) ──
// Flip-stats mechanics, generalized to consensus candidates: base =
// ALL candidates; splits = class / HTF-aligned / volume-confirmed / ADX.
// The ADX split is what the signal gate itself feeds on (measured gate).
var int cTot = 0
var int cWin = 0
var int conTot = 0
var int conWin = 0
var int rejTot = 0
var int rejWin = 0
var int aTot = 0
var int aWin = 0
var int vTot = 0
var int vWin = 0
var int xPTot = 0
var int xPWin = 0
var int xSTot = 0
var int xSWin = 0
var int mTot = 0
var int mWin = 0
var int cmTot = 0
var int cmWin = 0
if barstate.isconfirmed and candSig[lookF]
    bool win = candDir[lookF] * (close - close[lookF]) > 0
    cTot += 1
    cWin += win ? 1 : 0
    if candConfirm[lookF]
        conTot += 1
        conWin += win ? 1 : 0
    if candRejoin[lookF]
        rejTot += 1
        rejWin += win ? 1 : 0
    if candConf[lookF]
        aTot += 1
        aWin += win ? 1 : 0
    if volOk[lookF]
        vTot += 1
        vWin += win ? 1 : 0
    if adxLowRaw[lookF]
        xSTot += 1
        xSWin += win ? 1 : 0
    else
        xPTot += 1
        xPWin += win ? 1 : 0
    if candMtf[lookF]
        mTot += 1
        mWin += win ? 1 : 0
    if candCalm[lookF]
        cmTot += 1
        cmWin += win ? 1 : 0
// A/B stream outcomes (independent of which core is ACTIVE)
if barstate.isconfirmed and fixCand[lookF]
    fxTot += 1
    fxWin += fixCandDir[lookF] * (close - close[lookF]) > 0 ? 1 : 0
if barstate.isconfirmed and adaCand[lookF]
    adTot += 1
    adWin += adaCandDir[lookF] * (close - close[lookF]) > 0 ? 1 : 0

f_pct(int w, int t) => t > 0 ? str.tostring(100.0 * w / t, "#") + "% (" + str.tostring(t) + ")" : "—"

// evidence gate: a filter earns its chip marker only when
// its measured split beats the base rate by helpPts with sufficient samples
float wrBase  = cTot > 0 ? 100.0 * cWin / cTot : na
bool htfHelps  = cTot >= minSample and aTot >= minSample and not na(wrBase) and 100.0 * aWin / aTot >= wrBase + helpPts
bool volHelps  = cTot >= minSample and vTot >= minSample and not na(wrBase) and 100.0 * vWin / vTot >= wrBase + helpPts
bool conHelps  = cTot >= minSample and conTot >= minSample and not na(wrBase) and 100.0 * conWin / conTot >= wrBase + helpPts
bool rejHelps  = cTot >= minSample and rejTot >= minSample and not na(wrBase) and 100.0 * rejWin / rejTot >= wrBase + helpPts
bool mtfHelps  = cTot >= minSample and mTot >= minSample and not na(wrBase) and 100.0 * mWin / mTot >= wrBase + helpPts
bool calmHelps = cTot >= minSample and cmTot >= minSample and not na(wrBase) and 100.0 * cmWin / cmTot >= wrBase + helpPts
bool gateVol  = gateMode == "Always" or (gateMode == "Where it helps" and volHelps)
bool gateHtf  = gateMode == "Always" or (gateMode == "Where it helps" and htfHelps)

// THE MEASURED GATE: ADX suppression must EARN its place the same way chip
// marks do — it activates only where high-ADX candidates measurably beat
// low-ADX candidates by helpPts on this symbol/timeframe (both n ≥ minimum).
float wrAdxP = xPTot > 0 ? 100.0 * xPWin / xPTot : na
float wrAdxS = xSTot > 0 ? 100.0 * xSWin / xSTot : na
bool adxMeasured = xPTot >= minSample and xSTot >= minSample
bool adxHelps  = adxMeasured and not na(wrAdxP) and not na(wrAdxS) and wrAdxP - wrAdxS >= helpPts
bool adxGateOn = adxSigGate == "Always" or (adxSigGate == "Where it helps (measured)" and adxHelps)

// THE GATE: flip-cluster always (acute whipsaw), ADX only where
// measured to help, HTF optional. Suppressed candidates become ghost chips
// carrying the reason — printed judgment, not silence.
bool sigBlocked = (greyCluster and cluster) or (adxGateOn and adxLowRaw) or (greyHtf and not agree)
bool sigLong  = candLong  and not sigBlocked
bool sigShort = candShort and not sigBlocked
bool sigAny   = sigLong or sigShort
bool ghostSig = candSig and sigBlocked
string suppReason = greyCluster and cluster ? "NEUTRAL · whipsaw" :
     adxGateOn and adxLowRaw ? "ADX " + str.tostring(adxV, "#") + " (measured gate)" : "NEUTRAL · HTF split"

var int lastSigBar = na
if barstate.isconfirmed and sigAny
    lastSigBar := bar_index

// ── GRADE ENGINE (evidence-gated) ───────────────────────────────────────────
// A factor scores only if it is EARNED here (measured ↑) AND present on this
// signal. Fixed thresholds: A = ≥2 earned factors · B = 1 · C = 0.
int gradePtsDyn = (conHelps and candConfirm ? 1 : 0) + (volHelps and volOk ? 1 : 0) +
     (htfHelps and candConf ? 1 : 0) + (adxHelps and not adxLowRaw ? 1 : 0) + (mtfHelps and candMtf ? 1 : 0) +
     (calmHelps and candCalm ? 1 : 0)
// certified set: confirmation + volume — fixed, published, identical on every chart
int gradePtsFix = (candConfirm ? 1 : 0) + (volOk ? 1 : 0)
int gradePts = gradeMode == "Dynamic (measured here)" ? gradePtsDyn : gradePtsFix
int gradeNow = gradePts >= 2 ? 0 : gradePts == 1 ? 1 : 2   // 0=A · 1=B · 2=C
f_gLetter(int g) => g == 0 ? "A" : g == 1 ? "B" : "C"
var int curGrade = na
// (in Reversal-only mode curGrade tracks only signals that commit
// the drawn ladder, so the panel's Ladder row never shows a rejoin's grade
// next to a confirm ladder's direction)
if barstate.isconfirmed and sigAny and (not revOnly or sigIsRev)
    curGrade := gradeNow

// ─────────────────────────────── RENDER ─────────────────────────────────────
color cGrey  = #8F9BB3
// BAND HUE: consensus (default) = the band claims a direction only
// while BOTH cores agree — a core split floors conviction to the neutral
// tint of the SLOW core's side (structure remembers). Classic = fast core,
// the earliest read. Display-only: geometry and pinch anchors unchanged.
bool  hueCons  = bandHueIn == "Consensus (calm)"
bool  visUp    = hueCons ? slowUp : fastUp
bool  visSplit = hueCons and not (consUp or consDn)
color cDir   = visUp ? cBull : cBear
float trStr  = math.max(0.0, math.min(1.0, (adxV - 15.0) / 25.0))   // ADX 15→0 … 40→1
// CONVICTION CONTINUUM: ADX strength MERGED with the trend-strength
// gradient — ATR-normalized distance of price to the SLOW core. Price
// riding far from the structural stop = full saturation; price closing in
// on it = the color drains (early-exit warning). NEUTRAL stays the floor.
float atrSlowV = ta.atr(sAtr)
float gradStr  = gradOn and atrSlowV > 0 ? math.min(1.0, math.abs(close - stSlow) / (atrSlowV * gradN)) : 1.0
float conv   = greyState or visSplit ? 0.0 : trStr * (0.30 + 0.70 * gradStr)
color cNeut  = visUp ? cNeuU : cNeuD
color hueNow = color.from_gradient(conv, 0.0, 1.0, cNeut, cDir)
int   lineTr = int(35.0 * (1.0 - conv))
color cTrend = color.new(hueNow, lineTr)
// THE BAND — signature geometry, on the fast core:
// two independent EMAs (fast basis / slow edge), width forced to exactly
// zero on the fast-core flip bar, then eased open (smoothstep); connecting
// geometry takes the END bar's color so hue changes land on the vertex.
float basis = ta.ema(hl2, fAtr)
bool bandMode = vizStyle == "Band (tight)"
float atrV   = ta.atr(fAtr)
float capW   = atrV * bandCap
float slowB  = ta.ema(hl2, bandSlow)
float rawOff = slowB - basis
float offCap = math.max(-capW, math.min(capW, rawOff))
int   sinceFlip = na(lastFlipBar) ? bandSm : bar_index - lastFlipBar
float ramp  = math.min(1.0, sinceFlip * 1.0 / bandSm)
float easeR = ramp * ramp * (3.0 - 2.0 * ramp)   // smoothstep 0→1
float offS  = offCap * easeR
float stS   = basis + offS
float convL   = nz(conv[1], conv)
bool  visUpL  = hueCons ? slowUp[1] : fastUp[1]
color cDirL   = visUpL ? cBull : cBear
color cNeutL  = visUpL ? cNeuU : cNeuD
color hueLagG = color.from_gradient(convL, 0.0, 1.0, cNeutL, cDirL)
color cTrendL = color.new(hueLagG, int(35.0 * (1.0 - convL)))
int   bandTr  = 18 + int(47 * (1.0 - convL))   // 18 (vivid trend) … 65 (visible grey NEUTRAL)
// PRICE-SCALE DISCIPLINE: only levels you could act on get an axis label. The
// band's two edges are a visual envelope, not a price anyone trades, so they
// draw in the pane and stay out of the price scale — which is reserved for the
// structural stop and the ladder's Entry / SL / TP levels.
pBasis = plot(basis, "Trend basis", color = cTrendL, linewidth = lineW, display = display.pane + display.data_window)
pStS = plot(stS, "Slow edge", color = bandMode ? cTrendL : na, linewidth = lineW, display = display.pane + display.data_window)
color bandDense = color.new(hueLagG, bandTr)
color bandLight = color.new(hueLagG, math.min(97, bandTr + 33))
fill(pBasis, pStS, top_value = math.max(basis, stS), bottom_value = math.min(basis, stS),
     top_color = bandMode ? (stS > basis ? bandDense : bandLight) : na,
     bottom_color = bandMode ? (stS > basis ? bandLight : bandDense) : na, title = "Trend band")

// CORES: slow = structural stepped amber (the ladder's dynamic stop);
// fast = thin grey stepped line. Split up/down plots so flips BREAK the
// line instead of drawing vertical spikes.
float sUpPlot = slowUp ? stSlow : na
float sDnPlot = slowUp ? na : stSlow
float fUpPlot = fastUp ? stF : na
float fDnPlot = fastUp ? na : stF
// The slow core keeps its amber price-scale label — it is the structural stop
// and is worth reading even between trades. In the default SL mode the ladder's
// stop trails this same line, so the stop is drawn BLUE: two labels at one
// price, each identifiable, and visibly separate the moment you switch the SL
// core to Fast or Fixed.
pSUp = plot(sUpPlot, "Slow core (up)",   color = showSlow and dispFull ? color.new(cSlow, greyState ? 55 : 15) : na, linewidth = 2, style = plot.style_linebr)
pSDn = plot(sDnPlot, "Slow core (down)", color = showSlow and dispFull ? color.new(cSlow, greyState ? 55 : 15) : na, linewidth = 2, style = plot.style_linebr)
// the fast core is a timing reference, never an order level — pane only
pFUp = plot(fUpPlot, "Fast core (up)",   color = showFast and dispFull ? color.new(cGrey, greyState ? 75 : 45) : na, linewidth = 1, style = plot.style_linebr, display = display.pane + display.data_window)
pFDn = plot(fDnPlot, "Fast core (down)", color = showFast and dispFull ? color.new(cGrey, greyState ? 75 : 45) : na, linewidth = 1, style = plot.style_linebr, display = display.pane + display.data_window)

// CONSENSUS ZONE: continuous invisible anchors on both cores; the fill
// paints ONLY while both cores agree — cyan agreement, magenta agreement,
// nothing when split. Color goes na on either core's flip bar so the tall
// cross-over wedge is never painted (anti-spike rule).
pFa = plot(stF,    "Fast core (zone anchor)", color = color.new(color.white, 100), editable = false, display = display.none)
pSa = plot(stSlow, "Slow core (zone anchor)", color = color.new(color.white, 100), editable = false, display = display.none)
// an engagement switch steps stF without a market flip — blank the zone on
// that bar too, or the fill paints a tall one-bar wedge (anti-spike rule)
bool zoneFlip = flipUpF or flipDnF or flipUpS or flipDnS or adaOn != adaOn[1]
color zoneCol = not (showZone and dispFull) or zoneFlip ? na :
     consUp ? color.new(cBull, greyState ? 94 : 88) :
     consDn ? color.new(cBear, greyState ? 94 : 88) : na
fill(pFa, pSa, color = zoneCol, title = "Consensus zone")

// Line + cloud style: the gradient risk-buffer cloud (fast core)
int denseTr = greyState ? math.min(95, fillTr + 20) : math.min(95, fillTr + int(20 * (1.0 - trStr)))
// the risk-buffer cloud stays keyed to the FAST core regardless of the band
// hue mode — its geometry is the fast core's, so its color must be too
color cDirFast = fastUp ? cBull : cBear
color cDense = color.new(cDirFast, denseTr)
color cFaint = color.new(cDirFast, 98)
bool fillOn = showFill and dispFull and not (flipUpF or flipDnF) and not bandMode
fill(pFa, pBasis, top_value = math.max(stF, basis), bottom_value = math.min(stF, basis),
     top_color = fillOn ? (stF > basis ? cDense : cFaint) : na,
     bottom_color = fillOn ? (stF > basis ? cFaint : cDense) : na, title = "Trend cloud")
barcolor(colorBars and dispFull and (barstate.ishistory or barstate.isconfirmed) ? (greyState ? cNeut : consUp or consDn ? cDir : cGrey) : na, title = "Trend candles")

// ─────────────────────────── TRADE LADDER ───────────────────────────────────
// Committed at bar close of a PASSED signal: ENTRY at close, SL at the
// slow-core stop (dynamic — trails as the slow core ratchets), TP1/2/3 at
// configurable ×ATR. Rays persist until the next passed signal. On an SL
// break (slow core flips against the trade) the ladder freezes and marks ✕.
bool  slFast   = slCoreIn == "Fast core (tight)"
bool  slFixed  = slCoreIn == "Fixed (k×ATR hard cap)"
float slSrc    = slFast ? stF : stSlow
bool  slFlipDnX = slFast ? flipDnF : flipDnS
bool  slFlipUpX = slFast ? flipUpF : flipUpS
string slDesc  = slFixed ? "fixed " + str.tostring(slKx, "#.#") + "×ATR SL" :
     "SL trails the " + (slFast ? "fast" : "slow") + " core"
var line  lnE  = na
var line  lnS  = na
var line  lnT1 = na
var line  lnT2 = na
var line  lnT3 = na
var label lbE  = na
var label lbS  = na
var label lbT1 = na
var label lbT2 = na
var label lbT3 = na
var int   ladDir = 0        // +1 long, -1 short, 0 none/frozen
var int   ladEndBar = na    // bar the stop was hit: a closed ladder stops here
var bool  ladPinned = false // labels already flipped to sit inside the closed span
var float ladSlY   = na     // the stop level actually DRAWN — line, label and price scale all read this
var int   ladSlBar = na     // bar the stop last ratcheted to that level (the ray's left end)
var float ladEntry = na
var float ladT1 = na
var float ladT2 = na
var float ladT3 = na
var bool  t1Hit = false
var bool  t2Hit = false
var bool  t3Hit = false
var int   ladBar = na
var int   ladDirDrawn = 0    // direction of the DRAWN ladder (survives the SL freeze)
var bool  ladStale  = false  // resolved / completed / consensus lost → dimmed
var bool  ladBroken = false  // SL ✕ happened on this ladder
var float ladSlLvl = na      // the fixed k×ATR SL level (Fixed mode only)
// per-bar event flags (consumed by alerts below)
bool evTp1 = false
bool evTp2 = false
bool evTp3 = false
bool evSl  = false

f_delLadder() =>
    line.delete(lnE)
    line.delete(lnS)
    line.delete(lnT1)
    line.delete(lnT2)
    line.delete(lnT3)
    label.delete(lbE)
    label.delete(lbS)
    label.delete(lbT1)
    label.delete(lbT2)
    label.delete(lbT3)

// dim / restore the drawn ladder in one move. Stale = the ladder is history
// (SL ✕, TP3 ✓, or consensus lost) — the rays fade so they cannot be mistaken
// for live guidance; labels stay at full contrast (the ladder's record).
f_ladDim(bool dim) =>
    int dT = dim ? 45 : 0
    color cLadD = ladDirDrawn > 0 ? cBull : cBear
    color cSlD  = ladDirDrawn > 0 ? cBear : cBull   // stop takes the opposite hue to the targets
    line.set_color(lnE,  color.new(#FFFFFF, math.min(95, 40 + dT)))
    line.set_color(lnS,  ladBroken ? color.new(#FF5252, math.min(95, 20 + dT)) : color.new(cSlD, math.min(95, 20 + dT)))
    line.set_color(lnT1, color.new(cLadD, math.min(95, 55 + dT)))
    line.set_color(lnT2, color.new(cLadD, math.min(95, 40 + dT)))
    line.set_color(lnT3, color.new(cLadD, math.min(95, 25 + dT)))

// ANCHORING: a ladder that has been drawn stays pinned ladGap bars to the right
// of the last bar for as long as it is on the chart — including after an SL
// break, when ladDir drops to 0 but the rays and labels remain as the trade's
// record. Keying this on ladDirDrawn rather than ladDir is deliberate: gated on
// ladDir the labels froze the moment a stop was hit and new bars then marched
// straight through them. The gap keeps them clear of the forming bar.
// A CLOSED ladder stops at the bar its stop was hit. Letting it keep tracking
// the right edge dragged a finished trade's unreached targets across price
// action that happened long after it ended — which reads as "the script missed
// TP2 and TP3" when in fact the trade had been stopped out dozens of bars
// before price got there. Frozen, it is a bounded record of its own span, and
// its labels flip to the inside so later candles never run through them.
int ladGap = 3
if barstate.isconfirmed and not na(lnE) and ladDirDrawn != 0
    bool ladClosed = ladDir == 0 and not na(ladEndBar)
    if ladClosed and not ladPinned
        ladPinned := true
        label.set_style(lbE,  label.style_label_right)
        label.set_style(lbS,  label.style_label_right)
        label.set_style(lbT1, label.style_label_right)
        label.set_style(lbT2, label.style_label_right)
        label.set_style(lbT3, label.style_label_right)
    // A TRAILING stop is a staircase, not one level. Record each step and the
    // bar it moved on, then draw the ray only across the stretch where the stop
    // actually sat there. Drawn from the entry instead, a stop that has ratcheted
    // up past the entry claims it was always above it — which for a long reads as
    // an impossible stop, when in fact it started below and locked in profit. The
    // amber slow core already shows the whole staircase; this ray shows the level
    // in force. A fixed k×ATR stop never moves, so its ray spans the whole trade.
    // Never ratchet on the bar the chosen core flips AGAINST the trade: slSrc has
    // already jumped to the far side of price, and this same bar's resolution
    // block will freeze the ladder — ratcheting first would overwrite the stop
    // the trade actually broke at with the post-flip level.
    if ladDir != 0 and not slFixed and slSrc != ladSlY and not (ladDir > 0 ? slFlipDnX : slFlipUpX)
        ladSlY   := slSrc
        ladSlBar := bar_index
    int xR = (ladClosed ? ladEndBar : bar_index) + ladGap
    line.set_x2(lnE, xR)
    line.set_x2(lnT1, xR)
    line.set_x2(lnT2, xR)
    line.set_x2(lnT3, xR)
    line.set_x2(lnS, xR)
    line.set_x1(lnS, ladSlBar)
    line.set_y1(lnS, ladSlY)
    line.set_y2(lnS, ladSlY)
    label.set_y(lbS, ladSlY)
    label.set_x(lbE, xR)
    label.set_x(lbS, xR)
    label.set_x(lbT1, xR)
    label.set_x(lbT2, xR)
    label.set_x(lbT3, xR)

// The live ladder is RESOLVED before a replacement is drawn: on a bar that both
// ends the old ladder and fires a new signal, the old ladder's TP/SL events
// must still be credited and alerted.
if ladDir != 0 and barstate.isconfirmed and not na(lnE)
    // TP touches (marked once, ✓ appended — per-grade hit rates: LADDER ODDS rows).
    // Touch checks start the bar AFTER entry: the entry bar's extremes predate
    // the entry at its close, so they can neither credit a TP nor break the SL.
    if not t1Hit and bar_index > ladBar and (ladDir > 0 ? high >= ladT1 : low <= ladT1)
        t1Hit := true
        evTp1 := true
        label.set_text(lbT1, "TP1 ✓")
    if not t2Hit and bar_index > ladBar and (ladDir > 0 ? high >= ladT2 : low <= ladT2)
        t2Hit := true
        evTp2 := true
        label.set_text(lbT2, "TP2 ✓")
    if not t3Hit and bar_index > ladBar and (ladDir > 0 ? high >= ladT3 : low <= ladT3)
        t3Hit := true
        evTp3 := true
        label.set_text(lbT3, "TP3 ✓")
    // SL break: core modes = the chosen core flips against; Fixed mode =
    // price touches the hard level OR the slow core flips (backstop).
    // TP touches above are credited first.
    bool slBreakNow = bar_index > ladBar and (slFixed ?
         ((ladDir > 0 ? low <= ladSlLvl : high >= ladSlLvl) or (ladDir > 0 ? flipDnS : flipUpS)) :
         (ladDir > 0 ? slFlipDnX : slFlipUpX))
    if slBreakNow
        evSl := true
        label.set_text(lbS, "SL ✕")
        line.set_color(lnS, color.new(#FF5252, 20))
        ladBroken := true
        ladDir := 0
        ladEndBar := bar_index   // the ladder's right edge from here on

if showLadder and dispFull and barstate.isconfirmed and sigAny and (not revOnly or sigIsRev)
    f_delLadder()
    ladDir   := sigLong ? 1 : -1
    ladDirDrawn := ladDir
    ladStale  := false
    ladBroken := false
    ladEndBar := na            // a fresh ladder tracks the right edge again
    ladPinned := false
    ladEntry := close
    ladBar   := bar_index
    float aE = atrV
    ladT1 := ladEntry + ladDir * tp1x * aE
    ladT2 := ladEntry + ladDir * tp2x * aE
    ladT3 := ladEntry + ladDir * tp3x * aE
    t1Hit := false
    t2Hit := false
    t3Hit := false
    ladSlLvl := ladEntry - ladDir * slKx * aE     // fixed hard stop
    float slY = slFixed ? ladSlLvl : slSrc
    ladSlY   := slY                                // single source of truth for the drawn stop
    ladSlBar := bar_index
    color cLad = ladDir > 0 ? cBull : cBear
    lnE  := line.new(bar_index, ladEntry, bar_index + ladGap, ladEntry, color = color.new(#FFFFFF, 40), width = 1, style = line.style_solid)
    color cSl = ladDir > 0 ? cBear : cBull   // the stop is the opposite side of the trade — opposite hue
    lnS  := line.new(bar_index, slY,      bar_index + ladGap, slY,      color = color.new(cSl, 20),  width = 2, style = line.style_solid)
    lnT1 := line.new(bar_index, ladT1, bar_index + ladGap, ladT1, color = color.new(cLad, 55), width = 1, style = line.style_dashed)
    lnT2 := line.new(bar_index, ladT2, bar_index + ladGap, ladT2, color = color.new(cLad, 40), width = 1, style = line.style_dashed)
    lnT3 := line.new(bar_index, ladT3, bar_index + ladGap, ladT3, color = color.new(cLad, 25), width = 1, style = line.style_dashed)
    color cLadTx = ladDir > 0 ? cBull : #FFB3FE   // light pink for shorts — readable on the dark chip
    color cSlTx  = ladDir > 0 ? #FFB3FE : cBull   // the stop's mirror of the same pair
    // Chart labels name the level; the PRICE lives on the price scale, where it
    // is already precise and can be read without crowding the chart.
    lbE  := label.new(bar_index + ladGap, ladEntry, "ENTRY", style = label.style_label_left, color = color.new(#0D1117, 20), textcolor = cEntry, size = size.small,
         tooltip = "Entry — the close of the signal bar.")
    lbS  := label.new(bar_index + ladGap, slY, "SL · " + (slFixed ? str.tostring(slKx, "#.#") + "×ATR fixed" : (slFast ? "fast" : "slow") + " core"), style = label.style_label_left, color = color.new(#0D1117, 20), textcolor = cSlTx, size = size.small,
         tooltip = slFixed ? "Stop — fixed at " + str.tostring(slKx, "#.#") + "×ATR from entry (slow-core flip backstops it)." : "Stop — trails the " + (slFast ? "fast" : "slow") + " core; the level updates as the core ratchets.")
    lbT1 := label.new(bar_index + ladGap, ladT1, "TP1 · " + str.tostring(tp1x, "#.#") + "×ATR", style = label.style_label_left, color = color.new(#0D1117, 20), textcolor = cLadTx, size = size.small,
         tooltip = "TP1 — " + str.tostring(tp1x, "#.#") + "×ATR from entry.")
    lbT2 := label.new(bar_index + ladGap, ladT2, "TP2 · " + str.tostring(tp2x, "#.#") + "×ATR", style = label.style_label_left, color = color.new(#0D1117, 20), textcolor = cLadTx, size = size.small,
         tooltip = "TP2 — " + str.tostring(tp2x, "#.#") + "×ATR from entry.")
    lbT3 := label.new(bar_index + ladGap, ladT3, "TP3 · " + str.tostring(tp3x, "#.#") + "×ATR", style = label.style_label_left, color = color.new(#0D1117, 20), textcolor = cLadTx, size = size.small,
         tooltip = "TP3 — " + str.tostring(tp3x, "#.#") + "×ATR from entry.")

// ── LADDER LEVELS ON THE PRICE SCALE ────────────────────────────────────────
// The drawn ladder is made of lines, and lines never appear on the price axis —
// which is where you read a number off to type into an order ticket. These
// plots plot NOTHING in the pane (display omits display.pane, so the drawn
// ladder stays the only thing on the chart); they exist purely so ENTRY, SL and
// TP1-3 print as highlighted values on the price scale, the same way the cores
// already do. They follow the drawn ladder exactly: present while it is, gone
// when it is, and the SL value tracks the trailing stop.
bool  ladLive = showLadder and dispFull and ladDirDrawn != 0
color cLadPx  = ladDirDrawn > 0 ? cBull : cBear
color cSlPx   = ladDirDrawn > 0 ? cBear : cBull   // stop mirrors the targets
plot(ladLive ? ladEntry : na, "Ladder — ENTRY", color = cEntry,
     display = display.price_scale + display.data_window, editable = false)
// reads ladSlY, the same value the drawn ray and its label use — so a closed
// ladder's axis label shows where the stop actually broke, not wherever the live
// slow core has wandered to since
plot(ladLive ? ladSlY : na, "Ladder — SL", color = cSlPx,
     display = display.price_scale + display.data_window, editable = false)
plot(ladLive ? ladT1 : na, "Ladder — TP1", color = cLadPx,
     display = display.price_scale + display.data_window, editable = false)
plot(ladLive ? ladT2 : na, "Ladder — TP2", color = cLadPx,
     display = display.price_scale + display.data_window, editable = false)
plot(ladLive ? ladT3 : na, "Ladder — TP3", color = cLadPx,
     display = display.price_scale + display.data_window, editable = false)

// STALE-LADDER DIMMING: evaluated every confirmed bar the drawn
// ladder exists. Stale on SL ✕ / TP3 ✓ / consensus lost; re-brightens if
// consensus returns before resolution. Recolors only on state CHANGE.
if barstate.isconfirmed and not na(lnE) and ladDirDrawn != 0
    bool staleNow = ladBroken or t3Hit or (ladDirDrawn > 0 ? not consUp : not consDn)
    if staleNow != ladStale
        ladStale := staleNow
        f_ladDim(ladStale)

// ── MEASURED LADDER: per-grade odds ──────────────────────────────────────────
// Every PASSED signal's ladder is measured independently — TP touches by
// high/low, resolution when the slow core flips against the trade. Grades
// carry the odds the ladder actually produced here: TP1-before-SL, SL-first,
// furthest-level distribution. Counting only — the drawn ladder above is
// untouched. No P&L, no equity.
type LadM
    int dir
    float t1
    float t2
    float t3
    int reached
    int grade
    float entry
    float atrE
    float mae
    int ib
    int t1b
var ladMeas = array.new<LadM>()
var gN   = array.new_int(3, 0)     // resolved ladders per grade
var gTp1 = array.new_int(3, 0)     // reached ≥ TP1 before the SL flip
var gLvl = array.new_int(12, 0)    // grade*4 + furthest level (0–3)
// median HEAT per grade — the max adverse excursion (×ATR at entry) of
// every resolved measured ladder: the cost behind the TP1 hit rates.
var gMaeA = array.new_float()
var gMaeB = array.new_float()
var gMaeC = array.new_float()
// median bars→TP1 per grade — the ladder's time dimension.
var gT1bA = array.new_float()
var gT1bB = array.new_float()
var gT1bC = array.new_float()

// Fold one finished measured ladder into the per-grade odds. Called both when
// a ladder resolves normally AND when the open-ladder buffer overflows: an
// evicted ladder must still be counted, otherwise the published odds quietly
// become survivorship-filtered. The evicted one is always the OLDEST open
// ladder — the one that has had the most time to reach its targets — so
// dropping it uncounted would systematically discard the best-developed
// outcomes, and it would do so most often on low timeframes where signals
// arrive fastest.
f_ladCount(LadM m) =>
    array.set(gN, m.grade, array.get(gN, m.grade) + 1)
    if m.reached >= 1
        array.set(gTp1, m.grade, array.get(gTp1, m.grade) + 1)
    array.set(gLvl, m.grade * 4 + m.reached, array.get(gLvl, m.grade * 4 + m.reached) + 1)
    array<float> maeTgt = m.grade == 0 ? gMaeA : m.grade == 1 ? gMaeB : gMaeC
    array.push(maeTgt, m.mae)
    if array.size(maeTgt) > 200
        array.shift(maeTgt)
    if m.t1b != -1
        array<float> t1Tgt = m.grade == 0 ? gT1bA : m.grade == 1 ? gT1bB : gT1bC
        array.push(t1Tgt, m.t1b)
        if array.size(t1Tgt) > 200
            array.shift(t1Tgt)

if barstate.isconfirmed
    if array.size(ladMeas) > 0
        for k = array.size(ladMeas) - 1 to 0
            LadM m = array.get(ladMeas, k)
            float adv = m.atrE > 0 ? (m.dir > 0 ? m.entry - low : high - m.entry) / m.atrE : 0.0
            if adv > m.mae
                m.mae := adv
            if m.reached < 1 and (m.dir > 0 ? high >= m.t1 : low <= m.t1)
                m.reached := 1
            if m.reached == 1 and (m.dir > 0 ? high >= m.t2 : low <= m.t2)
                m.reached := 2
            if m.reached == 2 and (m.dir > 0 ? high >= m.t3 : low <= m.t3)
                m.reached := 3
            if m.t1b == -1 and m.reached >= 1
                m.t1b := bar_index - m.ib
            // resolution — mode-aware: Fixed = hard-level touch OR
            // slow-flip backstop; core modes = the chosen core flips against
            bool mRes = slFixed ?
                 ((m.dir > 0 ? low <= m.entry - slKx * m.atrE : high >= m.entry + slKx * m.atrE) or (m.dir > 0 ? flipDnS : flipUpS)) :
                 (m.dir > 0 ? slFlipDnX : slFlipUpX)
            if mRes
                f_ladCount(m)
                array.remove(ladMeas, k)
    if sigAny
        int dM = sigLong ? 1 : -1
        array.push(ladMeas, LadM.new(dM, close + dM * tp1x * atrV, close + dM * tp2x * atrV, close + dM * tp3x * atrV, 0, gradeNow, close, atrV, 0.0, bar_index, -1))
        // buffer cap: count the evicted ladder at its current state rather than
        // discarding it — see f_ladCount. Only bites when 30+ signals stack up
        // inside a single slow-core leg.
        if array.size(ladMeas) > 30
            f_ladCount(array.shift(ladMeas))

f_medLvl(int g) =>
    int n = array.get(gN, g)
    int half = (n + 1) / 2
    int cum = 0
    int med = 0
    bool done = false
    for j = 0 to 3
        cum += array.get(gLvl, g * 4 + j)
        if not done and cum >= half and n > 0
            med := j
            done := true
    med

// median furthest level as text — "—" with no resolved ladders, "none"
// when the median ladder reached no TP at all (0 is not a level)
f_lvlTxt(int g) =>
    int n = array.get(gN, g)
    int lvl = f_medLvl(g)
    n == 0 ? "—" : lvl == 0 ? "none" : "TP" + str.tostring(lvl)

f_gradeRow(int g) =>
    int n = array.get(gN, g)
    int t = array.get(gTp1, g)
    n == 0 ? "—" : str.tostring(100.0 * t / n, "#") + "%→TP1 · SL-first " + str.tostring(100.0 * (n - t) / n, "#") + "% (" + str.tostring(n) + ")"

// median heat text per grade (max adverse excursion, ×ATR at entry)
f_maeTxt(int g) =>
    array<float> a = g == 0 ? gMaeA : g == 1 ? gMaeB : gMaeC
    array.size(a) > 0 ? str.tostring(array.median(a), "#.##") + "×ATR" : "—"

// median bars→TP1 text per grade (only ladders that touched TP1)
f_t1Txt(int g) =>
    array<float> a = g == 0 ? gT1bA : g == 1 ? gT1bB : gT1bC
    array.size(a) > 0 ? str.tostring(array.median(a), "#") + " bars" : "—"

// ─────────────────────────── SIGNAL MARKERS ─────────────────────────────────
// Chips, rejoin marks and ghosts are fire-and-forget — nothing deletes them
// individually, so they would grow until TradingView's 500-label ceiling
// starts evicting the OLDEST labels on the chart. The ladder's five labels are
// created before the bar's chip, so they would be the first evicted, and the
// ladder block would then keep mutating destroyed ids. Pool the markers and
// retire the oldest past the cap: the total stays ~255, so the ladder's labels
// are never the eviction candidate.
var array<label> markerPool = array.new<label>()
f_mark(label l) =>
    array.push(markerPool, l)
    if array.size(markerPool) > 250
        label.delete(array.shift(markerPool))

// dots — minimal alternative (passed signals only)
plotshape(markerStyle == "Dots" and dispFull and barstate.isconfirmed and sigLong and (not revOnly or sigIsRev),
     "Signal dot (long)",  style = shape.circle, location = location.belowbar, color = color.new(cBull, 0), size = size.tiny)
plotshape(markerStyle == "Dots" and dispFull and barstate.isconfirmed and sigShort and (not revOnly or sigIsRev),
     "Signal dot (short)", style = shape.circle, location = location.abovebar, color = color.new(cBear, 0), size = size.tiny)

// chips — anchored at the stop of the core that flipped INTO consensus.
// Evidence marks: ✓ volume, ⚠ counter-HTF, both gated.
if markerStyle == "Chips" and dispFull and barstate.isconfirmed and sigAny and (not revOnly or sigIsRev)
    string tags = gateMode == "Off" ? "" :
         (volOk and gateVol ? " ✓" : "") + (not candConf and gateHtf ? " ⚠" : "")
    // grade + live odds on the chip face; odds print only at sufficient
    // sample. Class + ladder detail live in the tooltip.
    int gnN = array.get(gN, gradeNow)
    string gOdds = gnN >= minSample ? " · " + str.tostring(100.0 * array.get(gTp1, gradeNow) / gnN, "#") + "%→TP1 (" + str.tostring(gnN) + ")" : ""
    string chipTip = (candConfirm ? "confirm" : candRejoin ? "rejoin" : "same-bar") +
         " · Grade " + f_gLetter(gradeNow) + " (" + str.tostring(gradePts) + " evidence factor" + (gradePts == 1 ? "" : "s") + ")" +
         (gnN >= minSample ? " · SL-first " + str.tostring(100.0 * (gnN - array.get(gTp1, gradeNow)) / gnN, "#") + "% · median lvl " + f_lvlTxt(gradeNow) : "")
    float anchor = flipUpF or flipDnF ? stF : stSlow
    color chipBg = sigLong ? cBull : cBear
    color chipTx = sigLong ? #0A0E14 : #FFFFFF
    if sigLong
        f_mark(label.new(bar_index, anchor, "▲ LONG · " + f_gLetter(gradeNow) + gOdds + tags, style = label.style_label_up,
             color = color.new(chipBg, 10), textcolor = chipTx, size = size.small, tooltip = chipTip))
    else
        f_mark(label.new(bar_index, anchor, "▼ SHORT · " + f_gLetter(gradeNow) + gOdds + tags, style = label.style_label_down,
             color = color.new(chipBg, 10), textcolor = chipTx, size = size.small, tooltip = chipTip))

// demoted rejoin context markers (Reversal-only mode) — a passed
// rejoin still exists and is still measured, but it prints quiet and small.
// Theme-safe text (chart.fg_color); direction carried by a faint hue wash.
if markerStyle == "Chips" and dispFull and barstate.isconfirmed and sigAny and revOnly and not sigIsRev
    if sigLong
        f_mark(label.new(bar_index, stF, "· rejoin ▲", style = label.style_label_up,
             color = color.new(cBull, 82), textcolor = color.new(chart.fg_color, 25), size = size.tiny,
             tooltip = "Rejoin candidate (fast core rejoined the standing slow trend) — passed the gate, demoted by Reversal-only signal mode. Still measured in the panel's stats."))
    else
        f_mark(label.new(bar_index, stF, "· rejoin ▼", style = label.style_label_down,
             color = color.new(cBear, 82), textcolor = color.new(chart.fg_color, 25), size = size.tiny,
             tooltip = "Rejoin candidate (fast core rejoined the standing slow trend) — passed the gate, demoted by Reversal-only signal mode. Still measured in the panel's stats."))

// ghost chips — the suppressed candidate, with the reason. Hollow grey:
// the chart shows the judgment without claiming a direction.
if showGhost and dispFull and barstate.isconfirmed and ghostSig
    float anchorG = flipUpF or flipDnF ? stF : stSlow
    // theme-safe: text follows the chart's foreground color (dark on light
    // themes, light on dark themes) — a ghost must be quiet, not invisible
    if candLong
        f_mark(label.new(bar_index, anchorG, "◌ long" + (candRejoin ? " · rejoin" : candConfirm ? " · confirm" : " · same-bar") + " · " + suppReason, style = label.style_label_up,
             color = color.new(cGrey, 70), textcolor = color.new(chart.fg_color, 20), size = size.small))
    else
        f_mark(label.new(bar_index, anchorG, "◌ short" + (candRejoin ? " · rejoin" : candConfirm ? " · confirm" : " · same-bar") + " · " + suppReason, style = label.style_label_down,
             color = color.new(cGrey, 70), textcolor = color.new(chart.fg_color, 20), size = size.small))

// ─────────────────────────── MTF CONSENSUS STRIP ────────────────────────────
// Each row: FULL consensus state on that TF (both cores + NEUTRAL model),
// encoded into one float and read from the LAST COMPLETED bar of that TF
// (offset [1] + lookahead_on — repaint-safe).
// encoding: state*1000 + min(bars since state changed, 999)
// state: 0 = UP · 1 = DOWN · 2 = SPLIT · 3 = NEUTRAL
// (encoders e1–e5 are computed earlier — the grade engine consumes them too)

f_pos(string s) =>
    s == "Top left" ? position.top_left : s == "Top right" ? position.top_right :
     s == "Bottom left" ? position.bottom_left : s == "Bottom right" ? position.bottom_right :
     s == "Middle left" ? position.middle_left : position.middle_right

// The monthly branch divides rather than returning a bare "M": the climbing
// auto-strip can reach 3M and 12M, and a flat "M" made those rows read as
// duplicates of the monthly one.
f_tfLabel(string tf) =>
    float m = timeframe.in_seconds(tf) / 60.0
    m < 60 ? str.tostring(m, "#") + "m" : m < 1440 ? str.tostring(m / 60.0, "#") + "H" :
     m < 10080 ? str.tostring(m / 1440.0, "#") + "D" : m < 43200 ? str.tostring(m / 10080.0, "#") + "W" :
     str.tostring(m / 43200.0, "#") + "M"

string lab1 = f_tfLabel(tfS1)
string lab2 = f_tfLabel(tfS2)
string lab3 = f_tfLabel(tfS3)
string lab4 = f_tfLabel(tfS4)
string lab5 = f_tfLabel(tfS5)
int ownSec = timeframe.in_seconds(timeframe.period)
bool own1 = timeframe.in_seconds(tfS1) == ownSec
bool own2 = timeframe.in_seconds(tfS2) == ownSec
bool own3 = timeframe.in_seconds(tfS3) == ownSec
bool own4 = timeframe.in_seconds(tfS4) == ownSec
bool own5 = timeframe.in_seconds(tfS5) == ownSec

// tables rebuild on COMMITTED executions only (load + each bar close): the
// strip reads last-completed HTF bars and the panel's stats change on
// confirmed bars, so per-tick rebuilds with the heavy tooltip strings were
// redundant client render load. Values that genuinely move intra-bar
// refresh in the small live block under the panel.
bool commitTick = barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed)
var table sm = table.new(f_pos(stripPos), 3, 6, bgcolor = #0D1117,
     border_width = 1, border_color = #161B26, frame_color = #2A3140, frame_width = 1)
if showStrip and dispFull and commitTick
    table.clear(sm, 0, 0, 2, 5)
    table.cell(sm, 0, 0, "  CONSENSUS  ", text_color = cBull, text_size = size.tiny, bgcolor = #161B26, text_halign = text.align_left,
         tooltip = "Full consensus state per timeframe: UP/DOWN = both cores agree · SPLIT = cores disagree · NEUTRAL = state model grey (ADX / whipsaw). Read from the last completed bar of each timeframe — no repaint. ▶ marks this chart's own timeframe; other rows never print signals on this chart. All rows evaluate the fixed core settings.")
    table.cell(sm, 1, 0, "", bgcolor = #161B26)
    table.cell(sm, 2, 0, "", bgcolor = #161B26)
    for i = 0 to 4
        string lab = i == 0 ? lab1 : i == 1 ? lab2 : i == 2 ? lab3 : i == 3 ? lab4 : lab5
        bool   own = i == 0 ? own1 : i == 1 ? own2 : i == 2 ? own3 : i == 3 ? own4 : own5
        float  enc = i == 0 ? e1 : i == 1 ? e2 : i == 2 ? e3 : i == 3 ? e4 : e5
        int stt = na(enc) ? -1 : int(enc / 1000)
        int age = na(enc) ? 0 : int(enc % 1000)
        string sTxt = stt == 0 ? "  ▲ UP  " : stt == 1 ? "  ▼ DOWN  " : stt == 2 ? "  ◇ SPLIT  " : stt == 3 ? "  — NEUTRAL  " : "  …  "
        color sBg = stt == 0 ? cBull : stt == 1 ? cBear : stt == 2 ? #2A3140 : #4A5261
        color sTx = stt == 0 ? #0A0E14 : stt == 1 ? #FFFFFF : #B7C0CE
        table.cell(sm, 0, 1 + i, (own ? " ▶ " : "  ") + lab + "  ", text_color = own ? cBull : #B7C0CE, text_size = size.tiny, text_halign = text.align_left,
             tooltip = own ? "This chart's timeframe." : "State read from the last completed " + lab + " bar. Rows other than ▶ never print signals on this chart.")
        table.cell(sm, 1, 1 + i, sTxt, text_color = sTx, text_size = size.tiny, bgcolor = color.new(sBg, stt == 0 or stt == 1 ? 15 : 0))
        table.cell(sm, 2, 1 + i, "  " + str.tostring(age) + "b  ", text_color = #6B7280, text_size = size.tiny, text_halign = text.align_right)

// ─────────────────────────── STATE PANEL ────────────────────────────────────
// The coach row is a MERGED cell — its text sets the whole panel's width, so
// every coach variant stays short; after TP1 the retouch note replaces the SL
// description (which lives in the Ladder row tooltip).
string ladNote = ladDir != 0 ?
     (t1Hit and not t3Hit ? " Ladder TP1 ✓ — only the SL invalidates." :
     " Ladder live — " + slDesc + ".") : ""
// Price can sit beyond the ladder's stop long before anything resolves: in the
// core SL modes the stop is only broken when that core FLIPS, which needs a
// confirmed close. Say so, rather than leaving a live ladder that looks stuck.
float slLive = ladSlY   // the stop level actually in force, as drawn
bool  slBreachLive = ladDir != 0 and not na(slLive) and (ladDir > 0 ? close < slLive : close > slLive)
string coachTxt =
     slBreachLive ? "Price is through the ladder's stop — it resolves at this bar's close, not before." :
     greyCluster and cluster ? "Stand aside — whipsaw cluster." :
     adxLowRaw and adxGateOn ? (adxSigGate == "Always" ? "Stand aside — no trend (ADX); gate on." : "Stand aside — no trend (ADX); measured gate active.") :
     greyHtf and not agree ? "Stand aside — HTF disagrees (strict gate on)." :
     consUp ? (adxLow ? "Cores agree UP; ADX weak (grey band), gate inactive here." : "Both cores agree UP.") + (ladDir > 0 ? ladNote : "") :
     consDn ? (adxLow ? "Cores agree DOWN; ADX weak (grey band), gate inactive here." : "Both cores agree DOWN.") + (ladDir < 0 ? ladNote : "") :
     "Cores split — no consensus. Wait for alignment."

var table tb = table.new(f_pos(panelPos), 2, 22, bgcolor = #0D1117,
     border_width = 1, border_color = #161B26, frame_color = #2A3140, frame_width = 1)
if showTable and commitTick
    table.clear(tb, 0, 0, 1, 21)
    table.cell(tb, 0, 0, "  MSAI ST  ", text_color = cBull, text_size = size.small,
         bgcolor = #161B26, text_halign = text.align_left,
         tooltip = "Dual SuperTrend consensus: fast " + str.tostring(fFac, "#.#") + "×ATR(" + str.tostring(fAtr) + ") + slow " + str.tostring(sFac, "#.#") + "×ATR(" + str.tostring(sAtr) + "). A signal exists only on the bar both cores first align AND the gate allows it. TREND TOOL — the grey NEUTRAL state marks ranging conditions. Educational — not investment advice. · v4.3")
    table.cell(tb, 1, 0, "  " + timeframe.period + " · " + preset + "  ", text_color = #B7C0CE, text_size = size.small, bgcolor = #161B26, text_halign = text.align_right)
    table.cell(tb, 0, 1, "  Consensus", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = greyState ?
             "NEUTRAL: " + (greyAdx and adxV < adxThr ? "ADX " + str.tostring(adxV, "#.#") + " < " + str.tostring(adxThr, "#") + " — no trend to follow" :
             cluster and greyCluster ? str.tostring(chopK) + "+ fast-core flips in " + str.tostring(chopWin) + " bars (acute whipsaw)" :
             "this timeframe and the HTF disagree") :
             consUp or consDn ? "Both cores agree · ADX " + str.tostring(adxV, "#.#") : "Cores disagree — no consensus, no signal.")
    table.cell(tb, 1, 1, greyState ? "  NEUTRAL  " : consUp ? "  UP  " : consDn ? "  DOWN  " : "  SPLIT  ",
         text_color = greyState ? #0A0E14 : consUp ? #0A0E14 : consDn ? #FFFFFF : #B7C0CE,
         text_size = size.small, bgcolor = greyState ? cNeut : consUp ? cBull : consDn ? cBear : #2A3140)
    table.cell(tb, 0, 2, "  Cores", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Fast core = timing, drawn as the THIN GREY stepped line · slow core = structure, drawn as the AMBER stepped line and carrying the amber price-scale label. In the default SL mode the ladder's stop trails that amber staircase, which is why a stop can end up above a long's entry: it ratcheted up with the trend and locked in profit. The ladder's own stop ray shows only the level currently in force, in the trade's opposite hue.")
    table.cell(tb, 1, 2, "  fast " + (fastUp ? "▲" : "▼") + " · slow " + (slowUp ? "▲" : "▼") + "  ",
         text_color = #FFFFFF, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 3, "  Regime", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Volatility regime: normalized ATR percentile-ranked over " + str.tostring(regWin) + " bars — LOW < p33 · MID · HIGH > p66. Percentile bands — auditable, repaint-safe, no ML required. Fast factor in force: " + str.tostring(adaOn ? facAda : fFac, "#.#") + (adaOn ? " (adaptive)" : " — fixed core drives signals") + ".")
    table.cell(tb, 1, 3, "  " + clusterNm + " · " + (na(regAge) ? "—" : str.tostring(regAge) + "b") + " · fac " + str.tostring(adaOn ? facAda : fFac, "#.#") + "  ",
         text_color = clusterK == 2 ? #FFB300 : #FFFFFF, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 4, "  HTF (" + htfTF + ")", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 4, htfUp ? "  UP  " : "  DOWN  ", text_color = htfUp ? #0A0E14 : #FFFFFF,
         text_size = size.small, bgcolor = htfUp ? cBull : cBear)
    table.cell(tb, 0, 5, "  Agreement", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 5, agree ? "  aligned ✓  " : "  divergent  ", text_color = agree ? cBull : #FFB300,
         text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 6, "  Ladder", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Entry at signal close · SL " + (slFixed ? "fixed at " + str.tostring(slKx, "#.#") + "×ATR from entry (hard cap; slow-core flip backstops)" : "at the " + (slFast ? "fast" : "slow") + "-core stop (trailing)") + " · TP1/2/3 at " + str.tostring(tp1x, "#.#") + "/" + str.tostring(tp2x, "#.#") + "/" + str.tostring(tp3x, "#.#") + "×ATR. Levels only — never P&L.")
    table.cell(tb, 1, 6, ladDir == 0 ? "  —  " : "  " + (ladDir > 0 ? "LONG" : "SHORT") + (na(curGrade) ? "" : " · " + f_gLetter(curGrade)) + " · " + str.tostring(bar_index - ladBar) + "b" +
         (t3Hit ? " · TP3 ✓" : t2Hit ? " · TP2 ✓" : t1Hit ? " · TP1 ✓" : "") + "  ",
         text_color = ladDir == 0 ? #FFFFFF : ladDir > 0 ? cBull : cBear, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 7, "  Volume", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Current bar volume vs its 20-bar average — partial on a live bar; judge near the close.")
    table.cell(tb, 1, 7, na(volRatio) ? "  —  " : "  " + str.tostring(volRatio, "#.##") + "× avg" + (volOk ? " ✓  " : "  "),
         text_color = volOk ? cBull : #FFFFFF, text_size = size.small, text_halign = text.align_right)
    // machine-verified signal stats: does each class/filter improve the base rate here?
    color cStat   = cTot >= minSample ? #FFFFFF : #6B7280
    color cStatC  = conTot >= minSample ? cBull : #6B7280
    color cStatR  = rejTot >= minSample ? cBull : #6B7280
    color cStatA  = aTot >= minSample ? cBull : #6B7280
    color cStatV  = vTot >= minSample ? cBull : #6B7280
    color cStatM  = mTot >= minSample ? cBull : #6B7280
    color cStatCm = cmTot >= minSample ? cBull : #6B7280
    table.cell(tb, 0, 8, "  Signals +" + str.tostring(lookF) + "b", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Win rate of ALL consensus candidates (passed AND suppressed), measured " + str.tostring(lookF) + " bars later on this symbol/timeframe. Grey = sample below " + str.tostring(minSample) + ".")
    table.cell(tb, 1, 8, "  " + f_pct(cWin, cTot) + "  ", text_color = cStat, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 9, "  · confirm", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Candidates where the SLOW core flipped into alignment — the structural confirmation class. ↑ = beats the base rate by ≥" + str.tostring(helpPts, "#.#") + " points on THIS symbol/timeframe.")
    table.cell(tb, 1, 9, "  " + f_pct(conWin, conTot) + (conHelps ? " ↑" : "") + "  ", text_color = cStatC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 10, "  · rejoin", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Candidates where the FAST core rejoined the standing slow trend (pullback re-entry). ↑ = beats the base rate by ≥" + str.tostring(helpPts, "#.#") + " points here.")
    table.cell(tb, 1, 10, "  " + f_pct(rejWin, rejTot) + (rejHelps ? " ↑" : "") + "  ", text_color = cStatR, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 11, "  · HTF-aligned", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "↑ = beats the base rate by ≥" + str.tostring(helpPts, "#.#") + " points → the ⚠ counter-HTF warning is active on chips.")
    table.cell(tb, 1, 11, "  " + f_pct(aWin, aTot) + (htfHelps ? " ↑" : "") + "  ", text_color = cStatA, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 12, "  · vol-confirmed", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "↑ = beats the base rate by ≥" + str.tostring(helpPts, "#.#") + " points → the ✓ volume mark is active on chips.")
    table.cell(tb, 1, 12, "  " + f_pct(vWin, vTot) + (volHelps ? " ↑" : "") + "  ", text_color = cStatV, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 13, "  · MTF-aligned", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Candidates where ≥" + str.tostring(mtfMin) + " of the 5 strip rows shared the signal's consensus state. ↑ = the factor participates in grading here.")
    table.cell(tb, 1, 13, "  " + f_pct(mWin, mTot) + (mtfHelps ? " ↑" : "") + "  ", text_color = cStatM, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 14, "  · calm-regime", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Candidates arriving in a LOW/MID volatility regime. The ↑ appears only where this factor earns its margin on THIS chart.")
    table.cell(tb, 1, 14, "  " + f_pct(cmWin, cmTot) + (calmHelps ? " ↑" : "") + "  ", text_color = cStatCm, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 15, "  ADX gate", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Evidence-gated: suppresses low-ADX candidates only where high-ADX candidates beat low-ADX by ≥" + str.tostring(helpPts, "#.#") + " points here. ADX≥thr: " + f_pct(xPWin, xPTot) + " · ADX<thr: " + f_pct(xSWin, xSTot) + ".")
    table.cell(tb, 1, 15, adxSigGate == "Off" ? "  off  " : adxSigGate == "Always" ? "  always on  " :
         not adxMeasured ? "  measuring…  " : adxGateOn ? "  active ↑  " : "  inactive · no measured benefit  ",
         text_color = adxGateOn ? cBull : #B7C0CE, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 16, "  Adaptive", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = "Live A/B of the two fast cores on this chart — adaptive stream " + f_pct(adWin, adTot) + " vs fixed stream " + f_pct(fxWin, fxTot) + ". The adaptive core drives signals only where it beats fixed by ≥" + str.tostring(helpPts, "#.#") + " points (both n ≥ " + str.tostring(minSample) + "). The default factors are inert (equal to fixed); this row is the proof either way.")
    table.cell(tb, 1, 16, adaMode == "Off" ? "  off  " : adaMode == "Always" ? "  always on  " :
         facLow == fFac and facMid == fFac and facHigh == fFac ? "  inert (factors = fixed)  " :
         not adaMeasured ? "  measuring…  " : adaOn ? "  active ↑  " : "  inactive · fixed wins here  ",
         text_color = adaOn ? cBull : #B7C0CE, text_size = size.small, text_halign = text.align_right)
    // LADDER ODDS — the measured ladder, per grade
    color cGA = array.get(gN, 0) >= minSample ? #FFFFFF : #6B7280
    color cGB = array.get(gN, 1) >= minSample ? #FFFFFF : #6B7280
    color cGC = array.get(gN, 2) >= minSample ? #FFFFFF : #6B7280
    table.cell(tb, 0, 17, "  Grade A ladder", text_color = cBull, text_size = size.small, text_halign = text.align_left,
         tooltip = (gradeMode == "Dynamic (measured here)" ? "DYNAMIC MODE: signals with ≥2 locally-earned factors. " : "Grade A = slow-core confirmation + volume ≥ threshold — the certified factor set. ") + "Odds from every resolved ladder here; a bar touching both a TP and the stop credits the TP. Median furthest level: " + f_lvlTxt(0) + " · median heat " + f_maeTxt(0) + " (max adverse excursion before resolution — the cost behind the TP1 rate) · median bars→TP1 " + f_t1Txt(0) + ". Grey = sample below " + str.tostring(minSample) + ".")
    table.cell(tb, 1, 17, "  " + f_gradeRow(0) + "  ", text_color = cGA, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 18, "  Grade B ladder", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = (gradeMode == "Dynamic (measured here)" ? "One locally-earned factor. " : "Confirmation OR volume, not both. ") + "Median furthest level: " + f_lvlTxt(1) + " · median heat " + f_maeTxt(1) + " · median bars→TP1 " + f_t1Txt(1) + ".")
    table.cell(tb, 1, 18, "  " + f_gradeRow(1) + "  ", text_color = cGB, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 19, "  Grade C ladder", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left,
         tooltip = (gradeMode == "Dynamic (measured here)" ? "No locally-earned factors. " : "Consensus alone — neither certified factor present. ") + "Median furthest level: " + f_lvlTxt(2) + " · median heat " + f_maeTxt(2) + " · median bars→TP1 " + f_t1Txt(2) + ".")
    table.cell(tb, 1, 19, "  " + f_gradeRow(2) + "  ", text_color = cGC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 0, 20, "  Last signal", text_color = #B7C0CE, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 20, na(lastSigBar) ? "  —  " : "  " + str.tostring(bar_index - lastSigBar) + " bars ago  ",
         text_color = #FFFFFF, text_size = size.small, text_halign = text.align_right)
    if showCoach
        table.cell(tb, 0, 21, "  " + coachTxt + "  ", text_color = #8FA3B8, text_size = size.tiny, text_halign = text.align_left,
             tooltip = "Plain-language state. Note on the TP1 line: a retouch of the entry after TP1 does not invalidate the ladder — only the SL does.")
        table.merge_cells(tb, 0, 21, 1, 21)

// ── live cells: the values that genuinely move inside a bar ──────────────────
// The COACH line is refreshed here too. Without it the panel carried two
// vintages at once — a live Consensus reading of DOWN next to a coach line
// still narrating the split from the previous close — which reads as a
// contradiction rather than as "this is provisional until the bar shuts".
if showTable and barstate.islast
    table.cell(tb, 1, 1, greyState ? "  NEUTRAL  " : consUp ? "  UP  " : consDn ? "  DOWN  " : "  SPLIT  ",
         text_color = greyState ? #0A0E14 : consUp ? #0A0E14 : consDn ? #FFFFFF : #B7C0CE,
         text_size = size.small, bgcolor = greyState ? cNeut : consUp ? cBull : consDn ? cBear : #2A3140)
    table.cell(tb, 1, 2, "  fast " + (fastUp ? "▲" : "▼") + " · slow " + (slowUp ? "▲" : "▼") + "  ",
         text_color = #FFFFFF, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 1, 5, agree ? "  aligned ✓  " : "  divergent  ", text_color = agree ? cBull : #FFB300,
         text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 1, 7, na(volRatio) ? "  —  " : "  " + str.tostring(volRatio, "#.##") + "× avg" + (volOk ? " ✓  " : "  "),
         text_color = volOk ? cBull : #FFFFFF, text_size = size.small, text_halign = text.align_right)
    if showCoach
        table.cell(tb, 0, 21, "  " + coachTxt + "  ", text_color = slBreachLive ? #FFB300 : #8FA3B8, text_size = size.tiny, text_halign = text.align_left,
             tooltip = "Plain-language state, refreshed live. Readings that move inside a bar (consensus, cores, agreement, volume, this line) are PROVISIONAL — signals, ladders and statistics only commit when the bar closes, so an intrabar reading can revert before it counts.")
        table.merge_cells(tb, 0, 21, 1, 21)

// ─────────────────────────────── ALERTS ─────────────────────────────────────
alertcondition(sigLong,  "Consensus LONG",  "MSAI ST: CONSENSUS LONG — both cores aligned up, gate passed")
alertcondition(sigShort, "Consensus SHORT", "MSAI ST: CONSENSUS SHORT — both cores aligned down, gate passed")
alertcondition(sigLong and sigIsRev,  "Confirmed reversal LONG",  "MSAI ST: CONFIRMED REVERSAL LONG — slow core flipped into alignment (structural confirmation)")
alertcondition(sigShort and sigIsRev, "Confirmed reversal SHORT", "MSAI ST: CONFIRMED REVERSAL SHORT — slow core flipped into alignment (structural confirmation)")
alertcondition(sigLong and gradeNow == 0,  "Grade A LONG",  "MSAI ST: GRADE A LONG — 2+ evidence factors present on this signal")
alertcondition(sigShort and gradeNow == 0, "Grade A SHORT", "MSAI ST: GRADE A SHORT — 2+ evidence factors present on this signal")
alertcondition(evTp1, "TP1 touched", "MSAI ST: TP1 touched")
alertcondition(evTp2, "TP2 touched", "MSAI ST: TP2 touched")
alertcondition(evTp3, "TP3 touched", "MSAI ST: TP3 touched")
alertcondition(evSl,  "SL break", "MSAI ST: SL BREAK — the ladder's stop was invalidated")
alertcondition(not greyState and greyState[1], "Neutral ended (trend resumed)", "MSAI ST: grey NEUTRAL state ended — a clean trend state resumed")
alertcondition(greyState and not greyState[1], "Neutral started (stand aside)", "MSAI ST: entered grey NEUTRAL state — ranging conditions, signals are unreliable here")
alertcondition(clusterK != clusterK[1], "Volatility regime changed", "MSAI ST: volatility regime changed (LOW/MID/HIGH percentile bands)")
alertcondition(adaOn != adaOn[1], "Adaptive engine engagement changed", "MSAI ST: adaptive fast core engagement changed — check the panel's Adaptive row")

// structured JSON payloads for webhooks (single 'Any alert() function call')
if jsonAlerts and barstate.isconfirmed
    string base = '"symbol":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","regime":"' + clusterNm + '","engine":"' + (adaOn ? "adaptive" : "fixed") + '","state":"' +
         (greyState ? "NEUTRAL" : consUp ? "UP" : consDn ? "DOWN" : "SPLIT") + '","htf":"' + (agree ? "aligned" : "divergent") +
         '","vol":"' + (na(volRatio) ? "na" : str.tostring(volRatio, "#.##")) + 'x"'
    if sigAny
        float slJson = slFixed ? close - (sigLong ? 1 : -1) * slKx * atrV : slSrc
        alert('{"event":"consensus_' + (sigLong ? "long" : "short") + '","class":"' +
             (candConfirm ? "confirm" : candRejoin ? "rejoin" : "samebar") + '","grade":"' + f_gLetter(gradeNow) + '",' + base +
             ',"entry":"' + str.tostring(close, format.mintick) + '","sl":"' + str.tostring(slJson, format.mintick) +
             '","tp1":"' + str.tostring(close + (sigLong ? 1 : -1) * tp1x * atrV, format.mintick) +
             '","tp2":"' + str.tostring(close + (sigLong ? 1 : -1) * tp2x * atrV, format.mintick) +
             '","tp3":"' + str.tostring(close + (sigLong ? 1 : -1) * tp3x * atrV, format.mintick) + '"}', alert.freq_once_per_bar_close)
    if evTp1 or evTp2 or evTp3
        alert('{"event":"tp_touch","level":"' + (evTp3 ? "TP3" : evTp2 ? "TP2" : "TP1") + '",' + base + '}', alert.freq_once_per_bar_close)
    if evSl
        alert('{"event":"sl_break",' + base + ',"sl":"' + str.tostring(ladSlY, format.mintick) + '"}', alert.freq_once_per_bar_close)
````
