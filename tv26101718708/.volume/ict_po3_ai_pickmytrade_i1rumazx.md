# ICT PO3 AI [PickMyTrade]

- url: https://www.tradingview.com/script/I1RUmazx-ICT-PO3-AI-PickMyTrade/
- type: indicator
- pine_id: PUB;ff2d95a789284ed9bf7124ec87e0a549
- version: 1.0

## Description

Every AMD / Power-of-Three script marks where accumulation, manipulation and distribution happened. None answer the question a trader actually has the moment a range locks and gets swept: is THIS raid the kind that expands into distribution, or a pattern that only looked right?

――――――――――――――――――――――――――――――――――――――
https://www.tradingview.com/x/fg5N1kVb/

[b]🔷 WHAT IT MEASURES[/b]
[list]
[*]A locked accumulation range, scored on five independent compression measures — not one pass/fail test
[*]Every raid checked against a weighted pool of real liquidity — previous week/day high-low, Asia high-low, last confirmed swing — never against price alone
[*]A reclaim's own quality — penetration depth, acceptance beyond the level, overshoot, rejection wick — scored before the sequence is trusted
[*]The expansion leg itself: a genuine displacement bar, the first qualifying imbalance, and a market-structure shift back through the range it came from
[/list]

――――――――――――――――――――――――――――――――――――――

[b]🔷 THE ENGINE[/b]
[list]
[*]Three phase scores — Accumulation, Manipulation, Distribution — combined by weighted geometric mean, not a sum: a weak link drags the whole score down, never averaged away
[*]A k-nearest-neighbour search compares every new setup's own 8-property fingerprint against up to 100 stored past outcomes from the same chart — no training, no forecasting, just distance
[*]Whether a signal exists at all is decided by measured price behaviour alone; the analog engine sharpens the read but — outside Gate mode — never adds or removes a signal
[*]Below enough same-direction history, the high-confluence circle tier is disabled outright rather than guessed
[/list]

――――――――――――――――――――――――――――――――――――――

[b]🔷 SIGNALS AND DISPLAY[/b]
[list]
[*]Accumulation and Distribution boxes colored by role, always the same hue for the same tag — never by market bias
[*]A raid marker (×) placed at the sweep extreme, drawn only once the reclaim actually confirms — a location, not an entry
[*]Circle = high confluence, triangle = standard signal; marker opacity (not size) scales with score
[*]Dashboard: phase, the three sub-scores, regime, which liquidity level was raided, entry/stop/target, R-multiple, and the analog library's own sample count
[*]6 alertconditions, plus an optional JSON payload for webhook use
[/list]

――――――――――――――――――――――――――――――――――――――

[b]🔷 INPUTS[/b]
[list]
[*]ATR Length / Compression Window — volatility baseline and consolidation lookback. Default 14 / 20.
[*]Consolidation Sensitivity — Strict/Balanced/Loose compression floor. Default Loose.
[*]Minimum Score / High Confluence Score — structural floor to draw a signal, and the circle-tier threshold. Default 45 / 80.
[*]Higher Timeframe / Use Session Context / Timezone — directional context and session-window fit.
[*]Fallback Target Multiple — used only when no liquidity level qualifies as a target. Default 2.0R.
[*]Adaptive Mode — Off / Advisory / Gate. Default Advisory.
[*]Neighbours Compared / Outcome Horizon — KNN neighbour count and bars until a signal's result is recorded. Default 8 / 24.
[*]Show Accumulation Range, Distribution Zone, Imbalance — display toggles for each zone type.
[*]Zen Mode, Show Dashboard, Dashboard Position/Detail — display toggles; Zen Mode hides everything but zones and signals.
[/list]

――――――――――――――――――――――――――――――――――――――

[b]🔷 REQUIREMENTS AND LIMITATIONS[/b]
[list]
[*]Swing highs/lows used in the liquidity-pool weighting confirm 10 bars after they form, by construction — a level newer than that isn't counted yet
[*]The analog engine's read is thin until its library builds; the sample count travels with every score so that's never hidden
[*]Stored past outcomes are hypothetical — no commission, no slippage — and are not a record of trading results
[*]This script measures a specific, disclosed sequence. It does not predict, and it is not a trading system on its own.
[/list]

――――――――――――――――――――――――――――――――――――――

Built in Pine Script v6. Open source — Mozilla Public License 2.0.

## Source Code

````pine
//@version=6
// Object budgets carry deliberate headroom over the measured worst case, so a
// future edit cannot silently trip Pine's oldest-object auto-deletion (which
// would leave dangling ids inside the FIFO pools).
//   boxes   worst case  9 : _accBox 1 + _hAcc 3 + _distBox 1 + _hDist 3 + _fvgBox 1
//   lines   worst case 14 : _railLn 1 + _hRail 3 + _hStub 8 + _slLn 1 + _tpLn 1
//   labels  worst case 37 : _hRaid 15 + _hScore 20 + _slLb 1 + _tpLb 1
// Deepest history read is ta.percentrank(_atr, 250) on ta.atr(14) ~= 264 bars.
indicator("Power of Three AI [PickMyTrade]", "PO3AI[PMT]",
     overlay          = true,
     max_boxes_count  = 30,
     max_lines_count  = 40,
     max_labels_count = 100,
     max_bars_back    = 500)

// ── WHAT THIS MEASURES ────────────────────────────────────────
// Detects the Accumulation -> Manipulation -> Distribution sequence from
// measured price behaviour only. Session windows are a bounded context term
// worth at most ~6 of 100 score points and can be switched off entirely with
// no change to phase detection.
//
// ── NON-REPAINTING ────────────────────────────────────────────
// Every state change and every signal is evaluated on confirmed bar closes.
// Accumulation boundaries are frozen at qualification and never widen.
// The single higher-timeframe read is written as expression[1] with
// lookahead_on. That pairing is the canonical non-repainting form: the [1]
// steps the read back to the last CLOSED higher-timeframe bar, and lookahead_on
// makes historical and realtime bars return that same value. Using
// lookahead_off with the same [1] would return a two-bar-old value on
// historical bars and a one-bar-old value live - the same bar would carry
// different context after a reload.
// Swing levels come from ta.pivothigh/pivotlow with R = K_PIV_R, so a swing
// high or low younger than 10 bars is not yet published to the engine. Those
// levels feed the liquidity-pool weight, which GATES the manipulation
// transition (S15 T09/T10) and selects the target, so the delay can change
// whether a raid qualifies. It is disclosed in the Minimum Score tooltip and on
// the "Pool raided" dashboard row.
// The raid glyph is anchored at the sweep extreme but is only created once the
// reclaim closes, up to _manipWin bars later. It is a location marker for where
// liquidity was taken, not a bar-of-signal marker, and its own hover tooltip
// says so. The signal marker, by contrast, is always on the bar it fired.
// Previous-session levels are measured from the bars shown on this chart, so an
// extended-hours chart and a regular-hours chart report different values.
// The adaptive layer is built from episodes resolved on the loaded chart
// history. WHETHER a signal is drawn is decided by the structural score alone
// and is therefore independent of how much history loaded. The confluence
// NUMBER that is printed, the marker opacity and the circle/triangle tier do
// blend that layer in, so those can differ between two loads of the same chart.
// Adaptive Mode "Gate" is the one setting that lets the layer suppress a
// signal; it is opt-in and its tooltip says so.
//
// ── PLOT SLOT INVENTORY (limit 64) ────────────────────────────
//   11 x plot         (display.data_window)     11
//   4 x plotshape     (series colour, NO text=) 12
//   1 x bgcolor       (session tint)             1
//   6 x alertcondition                           6
//   TOTAL 30 of 64 worst case.  Keep this block current.
//   alertcondition() ALLOCATES AN INVISIBLE PLOT and counts against the 64.
//   So do bgcolor / barcolor / fill / hline. display = display.data_window does
//   NOT exempt a plot from the budget - it only hides it from the pane.
//   NOTE: the RE10140 incident in ORB_AI_PMT_Styling_v2.pine was caused by
//   TEXT-CARRYING plotshapes (~3 slots each). No plotshape here carries text=.
//
// ── CONFIDENCE IS OPACITY, NOT SIZE ───────────────────────────
// plotshape(size=) is a const argument and cannot vary per bar. Opacity via
// color.new(base, seriesTransp) is the only per-bar channel Pine offers.
// In color.new(), 0 = OPAQUE and 100 = INVISIBLE. Do not invert this.

// ═══════════════════════════════════════════════════════════════
// S02  CONSTANTS
// ═══════════════════════════════════════════════════════════════

// --- S02.1 lifecycle states (Pine has no enum; plain const ints) -----------
int _ST_IDLE     = 0
int _ST_ACC_FORM = 1
int _ST_ACC_CONF = 2
int _ST_MAN_DEV  = 3
int _ST_MAN_CONF = 4
int _ST_DIST_DEV = 5
int _ST_ACTIVE   = 6

// --- S02.2 reason codes ----------------------------------------------------
// Why the last cycle ended. Surfaced in the dashboard so a dead setup can be
// audited without re-reading the chart.
int R_NONE     = 0
int R_STALE    = 1
int R_BREAKOUT = 2
int R_TWOSIDED = 3
int R_ACCEPT   = 4
int R_DEPTH    = 5
int R_TIMEOUT  = 6
int R_NODISP   = 7
int R_NOMSS    = 8
int R_RAIDBRK  = 9
int R_OPPRAID  = 10
int R_LOWSCORE = 11
int R_RISKWIDE = 12
int R_WIN      = 14
int R_LOSS     = 15
int R_NEUTRAL  = 16

// --- S02.3 structural constants -------------------------------------------
// These are hard-coded on purpose. They define WHAT the engine considers a
// consolidation, a raid and an expansion. Exposing them as inputs would let a
// user dissolve the definitions until anything qualifies.
int   K_ACC_MIN_BARS = 8
int   K_ACC_GRACE    = 1
int   K_ACC_MAXAGE   = 60
// ACC_FORM is the one state with no natural terminator: the one-bar grace
// budget renews on every compressed bar, so an alternating compressed /
// non-compressed tape could widen the running range forever. This bounds it.
int   K_FORM_MAXAGE  = 90
float K_ACC_SD       = 1.2
float K_ACC_DRIFT    = 0.10
float K_MBD_MAX      = 0.55
float K_DRF_MIN      = 0.05
float K_DRF_MAX      = 0.75
float K_TOUCH_TOL    = 0.12
float K_EQ_TOL       = 0.25
int   K_TOUCH_SEP    = 2
float K_POOL_TOL     = 0.20
float K_POOL_CLUS    = 0.35
float K_POOL_MIN     = 0.32
float K_DISP_BODY    = 0.55
float K_FVG_MIN      = 0.10
float K_ACCEPT_MAX   = 0.60
float K_DEPTH_VETO_A = 2.00
float K_DEPTH_VETO_W = 0.75
float K_MQ_FLOOR     = 30.0
float K_SL_BUF       = 0.15
float K_SL_MIN       = 0.35
float K_SL_MAX       = 3.00
float K_TP_MIN_R     = 1.00
int   K_PIV_L        = 10
int   K_PIV_R        = 10
float K_WA           = 1.00
float K_WM           = 1.30
float K_WD           = 0.95
float K_WSUM         = 3.25
float K_GA_FLOOR     = 0.25
float K_GM_FLOOR     = 0.30
float K_GD_FLOOR     = 0.30
float K_ML_CAP       = 0.30
float K_ML_M         = 4.0
int   K_LIB_CAP      = 100
int   K_PEND_CAP     = 20
int   K_STAG_WIN     = 6
float K_STAG_STEP    = 1.1
float K_STAG_MAX     = 4.8
float K_OFF_GLYPH    = 1.5
float K_OFF_TEXT     = 1.1
int   K_PROJ         = 12
int   K_KEEP         = 3

// Session strings stay plain (not var) so they qualify as const string for time().
K_SESS_ASIA = "1900-0000"
K_SESS_LDN  = "0200-0500"
K_SESS_NYAM = "0830-1130"
K_SESS_NYPM = "1330-1600"

// --- S02.4 colours ---------------------------------------------------------
// Two hues only. Everything else is a neutral, a panel tone, or the two
// muted lines reserved for stop and target. The two direction hues themselves
// are NOT declared here - they come from the i_c_bull / i_c_bear inputs in
// S03 so the user can restyle them; only the fixed text tones below are const.
color C_NEUT   = #787B86
color C_BULL_T = #4C82FB
color C_BEAR_T = #FF6D00
color C_NEUT_T = #787B86
color C_SL     = #E05252
color C_TP     = #3FA45B
color D_BG     = #0C0E12
color D_KEY    = #9598A1
color D_VAL    = #D1D4DC
color D_BULL   = #5B8DFF
color D_BEAR   = #FF8A3D
color D_WARN   = #FFB74D

// --- S02.5 alpha ladder ----------------------------------------------------
int A_BOLD   = 25
int A_MID    = 45
int A_SOFT   = 62
int A_ZONE   = 78
int A_FAINT  = 88
int A_GHOST  = 93
int A_TINT   = 96

// ═══════════════════════════════════════════════════════════════
// S03  INPUTS
// ═══════════════════════════════════════════════════════════════
// Plain, not var. group= is a const string parameter; `var` controls one-time
// initialisation, not qualification, and must not be relied on to fold back to
// const. Same rule the session strings in S02.3 already follow.
string G_CORE = "Core"
string G_SIG  = "Signal"
string G_CTX  = "Context"
string G_RISK = "Risk Levels"
string G_ENG  = "Adaptive Engine"
string G_DISP = "Display"
string G_VIS  = "Visuals"

i_atr_len   = input.int(14, "ATR Length", minval = 5, maxval = 50, group = G_CORE,
     tooltip = "Volatility baseline. Every distance in this script is expressed in multiples of this ATR rather than in absolute price, so the thresholds are stated in volatility units. Whether a given value suits a given instrument or timeframe still has to be checked on that chart.")
i_acc_len   = input.int(20, "Compression Window", minval = 10, maxval = 60, group = G_CORE,
     tooltip = "Compression measurement window. What counts as a consolidation is genuinely timeframe- and instrument-dependent and cannot be inferred from price alone.")
i_cmp_sens  = input.string("Loose", "Consolidation Sensitivity", options = ["Strict", "Balanced", "Loose"], group = G_CORE,
     tooltip = "Minimum compression score a window must reach to be treated as a consolidation. Five measures are scored and weighted rather than applied as pass/fail tests, so one marginal dimension cannot by itself reject an otherwise clean range. Strict 72 / Balanced 58 / Loose 46. A trending instrument may produce nothing at Strict; if the dashboard shows the compression score repeatedly stalling just under the mark, that is what this input is for. Loosening it admits weaker ranges, so read the score on the dashboard rather than assuming every lock is equal.")

i_sig_min   = input.int(45, "Minimum Score", minval = 40, maxval = 90, group = G_SIG,
     tooltip = "Minimum confluence score for a signal to be drawn. Higher means fewer, more selective marks. Floored at 40 so a setup that only just cleared the internal gates can never be plotted. This threshold is compared against the STRUCTURAL score - the measurement of price behaviour alone, before the adaptive layer is blended in - so the set of signalling bars never depends on how much history the chart loaded. The number printed on the marker is the blended score and can therefore read a little above or below this threshold. Note also that the liquidity-pool term inside the score is built from swing highs and lows that require 10 bars of subsequent price to confirm, so a swing formed in the last 10 bars is not yet counted and a raid on it may be scored lower or rejected outright.")
i_hi_conf   = input.int(80, "High Confluence Score", minval = 65, maxval = 95, group = G_SIG,
     tooltip = "At or above this score the marker becomes a circle instead of a triangle. Expect these to be uncommon. The score is a measurement of how well the current sequence matches the engine's definitions, plus a comparison against stored past episodes. It is not a probability, and nothing here forecasts future price.")

i_htf       = input.timeframe("240", "Higher Timeframe", group = G_CTX,
     tooltip = "Higher timeframe used for directional and premium/discount context. Read as expression[1] with lookahead on, which is the non-repainting pairing: it always returns the last CLOSED higher-timeframe bar and returns the same value on historical and realtime bars.")
i_sess_ctx  = input.bool(true, "Use Session Context", group = G_CTX,
     tooltip = "Include intraday session windows as a small context term. Turning this off changes nothing about how phases are detected - only the context multiplier. Turn off for 24/7 markets or swing timeframes.")
i_tz        = input.string("America/New_York", "Timezone", group = G_CTX,
     options = ["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "Asia/Shanghai", "UTC", "Exchange"],
     tooltip = "Timezone all session windows and the previous-day boundary are read in. Named zones track daylight saving automatically; fixed offsets do not, which is why none are offered. Previous-day, previous-week and Asia levels are measured only from the bars this chart actually shows, so an extended-hours chart and a regular-hours chart will report different values for the same level.")

i_rr        = input.float(2.0, "Fallback Target Multiple", minval = 1.0, maxval = 5.0, step = 0.5, group = G_RISK,
     tooltip = "Fallback target multiple, used only when no opposing liquidity level sits at least 1R away.")
i_show_sltp = input.bool(true, "Show Entry / Stop / Target", group = G_RISK,
     tooltip = "Draw the entry, stop and target levels for the most recent signal. These are levels derived from the measured sequence for illustration; they are not a recommendation and take no account of commission, slippage or your own risk management.")

i_ml_mode   = input.string("Advisory", "Adaptive Mode", options = ["Off", "Advisory", "Gate"], group = G_ENG,
     tooltip = "No model is trained here. The engine stores past episodes detected on this chart and compares the current one against them by distance. Advisory blends those stored outcomes into the confluence NUMBER that is printed, into the marker opacity and into the circle/triangle tier, but the decision to draw a signal at all is taken on the structural score alone, so Advisory cannot add or remove a signal. Gate additionally suppresses a signal whose stored analogues resolved poorly, and only once at least 50 same-direction episodes exist - in Gate mode the set of signalling bars therefore does depend on how much history the chart has loaded. Choose Off if you want the score itself to depend on price structure alone.")
i_k         = input.int(8, "Neighbours Compared", minval = 5, maxval = 15, group = G_ENG,
     tooltip = "How many recorded same-direction episodes are compared against the current one. Smaller is more local; larger drifts toward the overall base rate. The library is rebuilt from whatever history the chart has loaded, so a chart with more bars can hold more episodes and print a different blended score on the same bar. Set Adaptive Mode to Off if you need the printed score to be independent of loaded history.")
i_out_bars  = input.int(24, "Outcome Horizon (bars)", minval = 8, maxval = 60, group = G_ENG,
     tooltip = "Bars after a signal before its outcome is recorded. This defines what 'resolved' means and should match how long you would actually hold.")

i_zen       = input.bool(false, "Zen Mode", group = G_DISP,
     tooltip = "Strips the chart to phase zones and signal markers only.")
i_dash_on   = input.bool(true, "Show Dashboard", group = G_DISP,
     tooltip = "Compact read-out of the current phase, sub-scores and levels.")
i_dash_pos  = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G_DISP,
     tooltip = "Corner the dashboard is pinned to.")
i_dash_mode = input.string("Full", "Dashboard Detail", options = ["Essential", "Full"], group = G_DISP,
     tooltip = "How much the dashboard shows. Essential keeps only what you act on: the confluence score, the phase, the direction and the entry / stop / target levels. Full adds the diagnostic rows - the three sub-scores, the volatility and structure regime, which liquidity pool was raided and how deep, the higher-timeframe read, the stored-episode count and why the last cycle ended - plus a legend explaining every mark the indicator draws on the chart. Start on Full while you are learning what the marks mean; switch to Essential once you no longer need the key.")
i_json      = input.bool(false, "Emit JSON Alert Payload", group = G_DISP,
     tooltip = "Emit a machine-readable JSON object describing each signal, for use with a webhook. Off by default; the named alert conditions are unaffected either way.")

i_show_acc  = input.bool(true, "Show Accumulation Range", group = G_VIS,
     tooltip = "Draw the frozen consolidation boundary. Deliberately faint - it marks something developing, not something actionable.")
i_show_dist = input.bool(true, "Show Distribution Zone", group = G_VIS,
     tooltip = "Draw the expansion envelope measured from the displacement bar onward.")
i_show_fvg  = input.bool(true, "Show Imbalance", group = G_VIS,
     tooltip = "Draw the first qualifying imbalance inside the expansion leg. One only, never every gap.")
i_c_bull    = input.color(#2962FF, "Bullish", group = G_VIS,
     tooltip = "Geometry hue for long, discount and bullish distribution. On-chart text tones are fixed for contrast and are not affected.")
i_c_bear    = input.color(#FF6D00, "Bearish", group = G_VIS,
     tooltip = "Geometry hue for short, premium and bearish distribution. On-chart text tones are fixed for contrast and are not affected.")

_tz = i_tz == "Exchange" ? syminfo.timezone : i_tz

// ═══════════════════════════════════════════════════════════════
// S04  HELPER FUNCTIONS  (pure, no ta.*)
// ═══════════════════════════════════════════════════════════════
f_c01(float x) =>
    na(x) ? 0.0 : math.max(0.0, math.min(1.0, x))

f_lin(float x, float lo, float hi) =>
    f_c01((x - lo) / (hi - lo + 1e-10))

f_linI(float x, float lo, float hi) =>
    f_c01((hi - x) / (hi - lo + 1e-10))

// Trapezoid: zero outside [lo,hi], one across the [o1,o2] plateau. Used where
// both "too little" and "too much" are evidence against, not for.
f_band(float x, float lo, float o1, float o2, float hi) =>
    float r = 0.0
    if not na(x)
        if x <= lo or x >= hi
            r := 0.0
        else if x < o1
            r := (x - lo) / (o1 - lo + 1e-10)
        else if x <= o2
            r := 1.0
        else
            r := (hi - x) / (hi - o2 + 1e-10)
    r

// Lorentzian per-axis distance: compresses outliers so one wild dimension
// cannot dominate an 8-D neighbour search built on ~100 records.
f_lor(float a, float b) =>
    math.log(1.0 + math.abs(a - b))

// --- opacity kernel --------------------------------------------------------
// Single source of truth for "confidence". Every visual channel derives from
// f_conf so a 56-score and an 88-score can never look the same.
// domain [55,95] -> [80,0]. slope = 80/40 = 2.0
f_conf(float s) =>
    math.round(math.max(0.0, math.min(80.0, 80.0 - (nz(s, 55.0) - 55.0) * 2.0)))

f_mA(float s) =>
    math.round(math.max(0.0, math.min(60.0, f_conf(s) * 0.75)))

// Bounds retuned from [70,90] to the A_SOFT..A_ZONE rungs (formula shape
// unchanged). The old bounds INVERTED at the low end: a just-qualifying
// signal produced 90, fainter than the A_ZONE 78 the box is already created
// with in S16, so signalling made the zone fade. These bounds make a
// signalled fill never fainter than creation and never bolder than A_SOFT,
// which keeps every FILL in the file inside 62-96 and leaves the bolder
// A_BOLD / A_MID rungs to borders, lines and text. This function has no
// other caller, so the retune cannot regress anything else.
f_zA(float s) =>
    math.round(math.max(62.0, math.min(78.0, 62.0 + f_conf(s) * 0.20)))

f_lA(float s) =>
    math.round(math.max(20.0, math.min(60.0, 20.0 + f_conf(s) * 0.50)))

// Re-scaled and re-capped from the raw marker alpha (f_mA, which itself
// ranges ~8 at high confidence to 60 at cold-start floor). The BUY/SELL text
// is the single actionable call on the whole chart, so its legibility floor
// has to be much higher than a decorative element's: capping at 35 (65%
// opaque) still read as faint text over busy candles. This keeps some
// confidence-linked gradation (higher score = a touch more solid) but
// compresses the whole range into 2-15 (85-98% opaque) instead of 8-35.
f_tA(float s) =>
    math.round(math.max(2.0, math.min(15.0, f_mA(s) * 0.25)))

f_meter(float s) =>
    int f = math.max(0, math.min(10, int(math.round(nz(s, 0.0) / 10.0))))
    str.repeat("▰", f) + str.repeat("▱", 10 - f)

// str.tostring(na) renders "NaN". Every computed number on chart or in the
// panel goes through these so an unpopulated cell reads as an em dash.
f_num(float v, int d) =>
    na(v) ? "—" : str.tostring(v, d == 0 ? "#" : d == 1 ? "#.#" : "#.##")

f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

f_jnum(float v, int d) =>
    na(v) ? "null" : str.tostring(v, d == 0 ? "#" : d == 1 ? "#.#" : "#.##")

// FIFO pools. array.shift() returns the evicted element - capture and delete
// it, always, or the drawing survives its own array slot.
f_poolPushL(array<label> a, label id, int cap) =>
    array.push(a, id)
    if array.size(a) > cap
        label.delete(array.shift(a))

f_poolPushB(array<box> a, box id, int cap) =>
    array.push(a, id)
    if array.size(a) > cap
        box.delete(array.shift(a))

f_poolPushLn(array<line> a, line id, int cap) =>
    array.push(a, id)
    if array.size(a) > cap
        line.delete(array.shift(a))

f_reason(int r) =>
    r == R_STALE ? "STALE" : r == R_BREAKOUT ? "BREAKOUT" : r == R_TWOSIDED ? "2SIDED" :
     r == R_ACCEPT ? "ACCEPT" : r == R_DEPTH ? "DEPTH" : r == R_TIMEOUT ? "TIMEOUT" :
     r == R_NODISP ? "NODISP" : r == R_NOMSS ? "NOMSS" : r == R_RAIDBRK ? "RAIDBRK" :
     r == R_OPPRAID ? "OPPRAID" : r == R_LOWSCORE ? "LOWSCORE" : r == R_RISKWIDE ? "RISKWIDE" :
     r == R_WIN ? "TARGET" : r == R_LOSS ? "STOP" :
     r == R_NEUTRAL ? "TIMEOUT" : ""

f_stName(int s) =>
    s == _ST_IDLE ? "IDLE" : s == _ST_ACC_FORM ? "ACCUM FORMING" : s == _ST_ACC_CONF ? "ACCUMULATION" :
     s == _ST_MAN_DEV ? "MANIP DEVELOPING" : s == _ST_MAN_CONF ? "MANIPULATION" :
     s == _ST_DIST_DEV ? "DISTRIBUTION" : "ACTIVE"

f_regVName(int r) =>
    r == 3 ? "DORMANT" : r == 0 ? "LOW" : r == 2 ? "HIGH" : "NORMAL"

f_regSName(int r) =>
    r == 0 ? "COMPRESS" : r == 1 ? "RANGE" : r == 2 ? "EXPAND" : "TREND"

f_kzName(int c) =>
    c == 1 ? "ASIA" : c == 2 ? "LONDON" : c == 3 ? "NY AM" : c == 4 ? "NY PM" : "OFF-SESSION"

// ═══════════════════════════════════════════════════════════════
// S05  BASE CALCULATIONS + REGIME CLASSIFIER
// ═══════════════════════════════════════════════════════════════
// Every ta.* call lives here, at global scope, unconditional. Calling any of
// them inside a branch desynchronises their internal history (CW10003).
_atr     = ta.atr(i_atr_len)
_atrL    = ta.sma(_atr, 100)
_atrR    = _atr / (_atrL + 1e-10)
_volPct  = ta.percentrank(_atr, 250)
_tr      = ta.tr(true)
_cmp20   = ta.sma(_tr, 20) / (ta.sma(_tr, 80) + 1e-10)
_sdC     = ta.stdev(close, i_acc_len)
_sma5    = ta.sma(close, 5)
_spanHi  = ta.highest(high, i_acc_len)
_spanLo  = ta.lowest(low, i_acc_len)
_spanHi4 = ta.highest(high, i_acc_len * 4)
_spanLo4 = ta.lowest(low, i_acc_len * 4)
_maxTR   = ta.highest(_tr, i_acc_len)
_volSma  = ta.sma(volume, 20)
_hasVol  = not na(_volSma) and _volSma > 0
_ph      = ta.pivothigh(high, K_PIV_L, K_PIV_R)
_pl      = ta.pivotlow(low, K_PIV_L, K_PIV_R)

// ADX, manual, no library dependency. _tr above is ta.tr(true), which is the
// same true range the manual house block builds, so it is reused rather than
// recomputed.
_dmp   = high - high[1] > low[1] - low ? math.max(high - high[1], 0.0) : 0.0
_dmm   = low[1] - low > high - high[1] ? math.max(low[1] - low, 0.0) : 0.0
_atr14 = ta.rma(_tr, 14)
_dip   = ta.rma(_dmp, 14) / (_atr14 + 1e-10) * 100
_dim   = ta.rma(_dmm, 14) / (_atr14 + 1e-10) * 100
_dx    = math.abs(_dip - _dim) / (_dip + _dim + 1e-10) * 100
_adx   = ta.rma(_dx, 14)

// --- regime, volatility axis: 0 LOW, 1 NORMAL, 2 HIGH, 3 DORMANT ----------
// DORMANT is tested first because it is a subset of LOW and would otherwise
// never be reachable.
_regV = _volPct < 8 and _atrR < 0.70 ? 3 : (_volPct < 25 or _atrR < 0.80) ? 0 : (_volPct > 75 or _atrR > 1.30) ? 2 : 1

// --- regime, structure axis: 0 COMPRESSING, 1 RANGING, 2 EXPANDING, 3 TRENDING
_regS = _adx >= 23 ? 3 : _cmp20 <= 0.80 ? 0 : _cmp20 >= 1.25 ? 2 : 1

// Frozen copies. Declared here rather than with the rest of the state block
// because every threshold below is a function of them.
var int _regVf = 1
var int _regSf = 1

// DORMANT borrows the LOW threshold row; it differs only by suppressing
// excursion opening entirely.
_rf = _regVf == 3 ? 0 : _regVf
_rl = _regV  == 3 ? 0 : _regV

_minPen  = _rf == 0 ? 0.04 : _rf == 2 ? 0.08 : 0.05
_m1lo    = _rf == 0 ? 0.04 : _rf == 2 ? 0.08 : 0.05
_m1o1    = _rf == 0 ? 0.10 : _rf == 2 ? 0.25 : 0.15
_m1o2    = _rf == 0 ? 0.45 : _rf == 2 ? 0.90 : 0.60
_m1hi    = _rf == 0 ? 0.95 : _rf == 2 ? 1.90 : 1.30
_dispMin = _rf == 0 ? 0.50 : _rf == 2 ? 0.85 : 0.65
_d1lo    = _rf == 0 ? 0.35 : _rf == 2 ? 0.60 : 0.45
_d1hi    = _rf == 0 ? 1.20 : _rf == 2 ? 2.10 : 1.60
_manipWin= _rf == 0 ? 4    : _rf == 2 ? 7    : 5
_distWin = _rf == 0 ? 10   : _rf == 2 ? 14   : 12
_invAtr  = _rf == 0 ? 0.80 : _rf == 2 ? 1.35 : 1.00

// These two gate whether a consolidation can form at all, so they must track
// the live regime rather than a frozen one.
_accWMax = _rl == 0 ? 3.2  : _rl == 2 ? 5.2  : 4.0
_cmpMax  = _rl == 0 ? 0.55 : _rl == 2 ? 0.45 : 0.50

_volFit    = _regVf == 0 ? 0.55 : _regVf == 2 ? 0.85 : 1.00
_structFit = _regSf == 0 ? 1.00 : _regSf == 1 ? 0.90 : _regSf == 2 ? 0.85 : 0.70
_regimeFit = _volFit * _structFit

// ═══════════════════════════════════════════════════════════════
// S06  HTF CONTEXT  (the single higher-timeframe read)
// ═══════════════════════════════════════════════════════════════
// The ONLY higher-timeframe read in this file. A grep for the security call
// must return exactly one hit.
// Every element carries its own [1] INSIDE the parentheses, paired with
// lookahead_on. That pairing - and only that pairing - is provably identical on
// historical and realtime bars: the [1] steps the read back to the last CLOSED
// higher-timeframe bar, and lookahead_on stops the historical branch stepping
// back a second time. lookahead_off with the same [1] would deliver a two-bar-
// old value historically and a one-bar-old value live, so a bar would carry
// different context after a reload. lookahead_on is only safe BECAUSE every
// element is offset; never remove a [1] here without removing lookahead_on.
// Do NOT use this pattern for discrete previous-period levels - see S07.
[_hF, _hS, _hHi, _hLo] = request.security(syminfo.tickerid, i_htf,
     [ta.ema(close, 21)[1], ta.ema(close, 55)[1],
      ta.highest(high, 20)[1], ta.lowest(low, 20)[1]],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

_htfOk = timeframe.in_seconds(i_htf) >= timeframe.in_seconds(timeframe.period)
_htfTr = not _htfOk ? 0 : _hF > _hS ? 1 : _hF < _hS ? -1 : 0
_htfPD = not _htfOk ? 0.5 : (close - _hLo) / (_hHi - _hLo + 1e-10)
_premS = f_c01((_htfPD - 0.40) / 0.40)
_discS = f_c01((0.60 - _htfPD) / 0.40)

f_htfAlign(int d) =>
    float r = 0.5
    if _htfOk
        float trs = d > 0 ? (_htfTr == 1 ? 1.0 : _htfTr == 0 ? 0.5 : 0.0) : (_htfTr == -1 ? 1.0 : _htfTr == 0 ? 0.5 : 0.0)
        float pds = d > 0 ? _discS : _premS
        r := 0.60 * trs + 0.40 * pds
    r

// ═══════════════════════════════════════════════════════════════
// S07  DAY / WEEK / ASIA LATCHES + KILLZONE FLAGS
// ═══════════════════════════════════════════════════════════════
// No higher-timeframe read here. Ever. With lookahead_off a daily context read
// already returns yesterday, so an extra [1] silently returns the day before
// yesterday - a wrong level with no error to show for it.
_dayKey = year(time, _tz) * 10000 + month(time, _tz) * 100 + dayofmonth(time, _tz)
_wkKey  = year(time, _tz) * 100 + weekofyear(time, _tz)
_newDay = _dayKey != nz(_dayKey[1], _dayKey)
_newWk  = _wkKey != nz(_wkKey[1], _wkKey)

var float _runDH = na
var float _runDL = na
var float _runWH = na
var float _runWL = na
var float _pdh = na
var float _pdl = na
var float _pwh = na
var float _pwl = na
var float _adr = na
var bool  _adrSeeded = false

// RULE for all six running extremes in this file: seed with na(x) ? v : ...
// math.max(na, x) is na, and a var float seeded na then fed through math.max
// stays na for the entire chart, silently, forever.
if _newDay
    _pdh := _runDH
    _pdl := _runDL
    float dr = (na(_runDH) or na(_runDL)) ? na : _runDH - _runDL
    if not na(dr)
        // Discard the FIRST measured day. Loaded history can begin mid-session,
        // and a partial first day seeds this EMA low enough that the daily-range
        // fraction gate below rejects every lock for roughly fifteen sessions.
        if not _adrSeeded
            _adrSeeded := true
        else
            _adr := na(_adr) ? dr : _adr + (dr - _adr) / 14.0
    _runDH := high
    _runDL := low
else
    _runDH := na(_runDH) ? high : math.max(_runDH, high)
    _runDL := na(_runDL) ? low : math.min(_runDL, low)

if _newWk
    _pwh := _runWH
    _pwl := _runWL
    _runWH := high
    _runWL := low
else
    _runWH := na(_runWH) ? high : math.max(_runWH, high)
    _runWL := na(_runWL) ? low : math.min(_runWL, low)

// Asia latch. One midnight-crossing window, so the window-entry transition
// always fires and no two-sided construction is needed.
_inAsia    = timeframe.isintraday and not na(time(timeframe.period, K_SESS_ASIA, _tz))
_asiaStart = _inAsia and not _inAsia[1]
var float _runAsiaH = na
var float _runAsiaL = na
var float _asiaH = na
var float _asiaL = na
if _asiaStart
    _asiaH := _runAsiaH
    _asiaL := _runAsiaL
    _runAsiaH := high
    _runAsiaL := low
else if _inAsia
    _runAsiaH := na(_runAsiaH) ? high : math.max(_runAsiaH, high)
    _runAsiaL := na(_runAsiaL) ? low : math.min(_runAsiaL, low)

// Killzone code: 0 OTHER, 1 ASIA, 2 LONDON, 3 NY_AM, 4 NY_PM.
_inLdn  = timeframe.isintraday and not na(time(timeframe.period, K_SESS_LDN, _tz))
_inNyAm = timeframe.isintraday and not na(time(timeframe.period, K_SESS_NYAM, _tz))
_inNyPm = timeframe.isintraday and not na(time(timeframe.period, K_SESS_NYPM, _tz))
_kz = _inNyAm ? 3 : _inNyPm ? 4 : _inLdn ? 2 : _inAsia ? 1 : 0

// Frozen killzone stamps. Declared here because the session prior reads them.
var int _accSess = 0
var int _manSess = 0
var int _sigSess = 0

f_sessFit(int code, int phase) =>
    phase == 0 ? (code == 1 ? 1.00 : code == 2 ? 0.50 : code == 3 ? 0.45 : code == 4 ? 0.70 : 0.60) :
     phase == 1 ? (code == 1 ? 0.45 : code == 2 ? 1.00 : code == 3 ? 0.90 : code == 4 ? 0.55 : 0.50) :
     (code == 1 ? 0.40 : code == 2 ? 0.85 : code == 3 ? 1.00 : code == 4 ? 0.70 : 0.55)

// A FUNCTION, not a global assignment. A reclaim, a displacement and a market-
// structure shift can all resolve on one bar, and _manSess is stamped inside
// that cascade. A global assignment here would be evaluated at the top of the
// bar and would score the setup with the PREVIOUS cycle's killzone, or with the
// uninitialised seed on the first cascade of the chart. Called at the moment of
// use, it reads the stamp that was just written.
// The distribution term reads the LIVE killzone: at the candidate bar that is
// exactly the signal killzone, and _sigSess has not been stamped yet.
f_sessionPrior() =>
    0.45 * f_sessFit(_manSess, 1) + 0.35 * f_sessFit(_kz, 2) + 0.20 * f_sessFit(_accSess, 0)

// ═══════════════════════════════════════════════════════════════
// S08  LIQUIDITY LEVEL SET + POOL TIER
// ═══════════════════════════════════════════════════════════════
// Ten scalars, no arrays. Reference levels (session opens, midnight open,
// VWAP) are never raid targets and are deliberately absent from the set.
var float _lastPH = na
var float _lastPL = na
if not na(_ph)
    _lastPH := _ph
if not na(_pl)
    _lastPL := _pl

f_tier(float lvl, int side) =>
    float tol = math.max(K_POOL_TOL * _atr, syminfo.mintick * 4)
    float t = 0.0
    float a = side > 0 ? _pwh : _pwl
    if not na(a) and math.abs(lvl - a) <= tol
        t := math.max(t, 1.00)
    a := side > 0 ? _pdh : _pdl
    if not na(a) and math.abs(lvl - a) <= tol
        t := math.max(t, 0.85)
    a := side > 0 ? _asiaH : _asiaL
    if not na(a) and math.abs(lvl - a) <= tol
        t := math.max(t, 0.65)
    a := side > 0 ? _lastPH : _lastPL
    if not na(a) and math.abs(lvl - a) <= tol
        t := math.max(t, 0.50)
    math.max(t, 0.30)

f_tierName(float lvl, int side) =>
    float tol = math.max(K_POOL_TOL * _atr, syminfo.mintick * 4)
    string nm = side > 0 ? "RANGE HI" : "RANGE LO"
    float a = side > 0 ? _lastPH : _lastPL
    if not na(a) and math.abs(lvl - a) <= tol
        nm := side > 0 ? "SWING H" : "SWING L"
    a := side > 0 ? _asiaH : _asiaL
    if not na(a) and math.abs(lvl - a) <= tol
        nm := side > 0 ? "ASIA H" : "ASIA L"
    a := side > 0 ? _pdh : _pdl
    if not na(a) and math.abs(lvl - a) <= tol
        nm := side > 0 ? "PDH" : "PDL"
    a := side > 0 ? _pwh : _pwl
    if not na(a) and math.abs(lvl - a) <= tol
        nm := side > 0 ? "PWH" : "PWL"
    nm

f_clusterN(float lvl, int side) =>
    float r = math.max(K_POOL_CLUS * _atr, syminfo.mintick * 8)
    int n = 0
    float a = side > 0 ? _pwh : _pwl
    n += (not na(a) and math.abs(lvl - a) <= r) ? 1 : 0
    a := side > 0 ? _pdh : _pdl
    n += (not na(a) and math.abs(lvl - a) <= r) ? 1 : 0
    a := side > 0 ? _asiaH : _asiaL
    n += (not na(a) and math.abs(lvl - a) <= r) ? 1 : 0
    a := side > 0 ? _lastPH : _lastPL
    n += (not na(a) and math.abs(lvl - a) <= r) ? 1 : 0
    n

// Touch count is passed in rather than read from state: this function is
// defined before the state block and must stay free of it.
f_pool(float lvl, int side, int touches) =>
    float tierS = f_tier(lvl, side)
    float cluS  = f_lin(f_clusterN(lvl, side), 0, 3)
    float touS  = f_lin(touches, 1, 4)
    0.50 * tierS + 0.25 * cluS + 0.25 * touS

// ═══════════════════════════════════════════════════════════════
// S09  PHASE PRIMITIVES
// ═══════════════════════════════════════════════════════════════
_span     = _spanHi - _spanLo
_cmpRatio = _span / (_spanHi4 - _spanLo4 + 1e-10)
_drift    = math.abs(_sma5 - _sma5[i_acc_len]) / (i_acc_len * _atr + 1e-10)
_mbd      = _maxTR / (_span + 1e-10)

// Five measures, SCORED and weighted rather than applied as a five-way AND.
// The AND form was the reason this engine produced nothing: each test is
// individually reasonable, but requiring all five simultaneously for
// K_ACC_MIN_BARS consecutive bars is a far stronger claim than the sum of its
// parts, and on trending intraday futures it is close to unsatisfiable. The
// binding term was _cmpRatio: demanding the window span stay under ~45% of the
// 4x window rejects any consolidation sitting inside a live trend leg, which is
// exactly where accumulation before a raid actually happens.
//
// Each measure is mapped through a soft ramp — full credit while comfortably
// inside its old threshold, decaying to zero past it — so one marginal
// dimension degrades the score instead of vetoing the range outright. This is
// the same weighted-confluence shape the rest of this file already uses, rather
// than a boolean chain.
_cmpSpan = f_linI(_span / (_atr + 1e-10),  _accWMax     * 0.60, _accWMax     * 1.60)
_cmpDisp = f_linI(_sdC  / (_atr + 1e-10),  K_ACC_SD     * 0.60, K_ACC_SD     * 1.60)
_cmpDrft = f_linI(_drift,                  K_ACC_DRIFT  * 0.50, K_ACC_DRIFT  * 2.50)
_cmpRel  = f_linI(_cmpRatio,               _cmpMax      * 0.70, _cmpMax      * 1.70)
_cmpDom  = f_linI(_mbd,                    K_MBD_MAX    * 0.70, K_MBD_MAX    * 1.50)

// Weights: relative compression and flatness are what actually distinguish a
// consolidation from a pause in a trend, so they carry most of the score.
// Absolute width and dispersion are size descriptors. Bar dominance is a
// sanity term and is weighted lowest — but see the hard veto below.
_cmpScore = 100.0 * (0.28 * _cmpRel + 0.24 * _cmpDrft + 0.20 * _cmpSpan + 0.16 * _cmpDisp + 0.12 * _cmpDom)

_cmpMin = i_cmp_sens == "Strict" ? 72.0 : i_cmp_sens == "Loose" ? 46.0 : 58.0

// One hard veto survives the move to scoring: a window whose range was created
// almost entirely by a single bar is an impulse followed by quiet, not an
// accumulation, and no combination of the other four terms should rescue it.
// Set well above K_MBD_MAX so it only catches the degenerate case.
_cmpVeto = _mbd > 0.80

_compressed = _cmpScore >= _cmpMin and not _cmpVeto

// ═══════════════════════════════════════════════════════════════
// S10  LEARNING TYPE + STATE
// ═══════════════════════════════════════════════════════════════
// A UDT, not parallel primitive arrays. Parallel arrays require every
// array.remove to be repeated N times in lockstep; one omission desynchronises
// the library permanently and silently.
type Po3Rec
    int   dir    = 0
    int   barIdx = 0
    float entry  = na
    float tp     = na
    float sl     = na
    float rr     = na
    float mfe    = 0.0
    float mae    = 0.0
    int   lbl    = -1
    float z1     = 0.0
    float z2     = 0.0
    float z3     = 0.0
    float z4     = 0.0
    float z5     = 0.0
    float z6     = 0.0
    float z7     = 0.0
    float z8     = 0.0

var array<Po3Rec> g_pend = array.new<Po3Rec>()
var array<Po3Rec> g_libL = array.new<Po3Rec>()
var array<Po3Rec> g_libS = array.new<Po3Rec>()

// Running total of resolved labels across both libraries. Maintained at the two
// sites that mutate them so the panel's base rate is an O(1) read instead of a
// 200-record rescan on every realtime tick of the last bar.
var float g_libSum = 0.0
var int   g_libN   = 0

// --- persistent state ------------------------------------------------------
// Declared ahead of the scoring builders because those builders read it.
var int _st       = _ST_IDLE
var int _dir      = 0
var int _rDir     = 0
var int _seq      = 0
var int _stBar    = 0
var int _reason   = R_NONE
var int _accBars  = 0
var int _miss     = 0
var int _startBar = na
var int _lockBar  = na
var int _manBar   = na
var int _dispBar  = na
var int _sigBar   = na
var int _excBar   = na
var int _excBars  = 0
var int _closesBeyond = 0
var int _consecBeyond = 0
var int _barsBeyond   = 0
var int _touchHi  = 0
var int _touchLo  = 0
var int _purgeCnt = 0
var int _purgeBar = na
var int _poolCnt  = 0

// Memo of the last level actually raided, so a shallow sweep that was rejected
// cannot be re-locked and re-swept every few bars, feeding the library a run of
// near-duplicate episodes on one price.
var float _lastRaidLvl = na
var int   _lastRaidBar = na

var int _startTime = na
var int _dispTime  = na
var int _fvgTime   = na

var float _runHi   = na
var float _runLo   = na
var float _accHi   = na
var float _accLo   = na
var float _accW    = na
var float _atrLock = na
var float _aq      = na
var float _mq      = na
var float _dq      = na
var float _lvl     = na
var float _poolSig = na
var float _excExt  = na
var float _volBeyond = 0.0
var float _extO    = na
var float _extH    = na
var float _extL    = na
var float _extC    = na
var float _mssRef  = na
var float _legBodyRat = 0.0
var float _fvgHi   = na
var float _fvgLo   = na
var float _fvgSize = na
var float _distHi  = na
var float _distLo  = na
var float _score   = na
var float _entry   = na
var float _sl      = na
var float _tp      = na
var float _R       = na
var float _rrMult  = na
var float _knnAtSig = na
var float _depthShow = na
var float _acceptShow = na
var float _chainShow = na
var float _ctxShow = na
// Captures the composite score of EVERY scored candidate, pass or fail -
// unlike _score, which only ever holds the score of a candidate that cleared
// the gate. Lets the Data Window answer "how close did the last raid get"
// instead of only ever showing na when nothing signalled.
var float _lastRawC = na

var bool _fvgFound   = false
var bool _tpFound    = false
var bool _volModeT   = false
var bool _coldAtSig  = false
var int  _libnAtSig  = na
var string _poolName = "—"

_live  = _st != _ST_IDLE
_nDir  = _dir == 1 ? array.size(g_libL) : _dir == -1 ? array.size(g_libS) : 0
_cold  = _nDir < i_k

// ═══════════════════════════════════════════════════════════════
// S11  M2a LIFECYCLE — PENDING RESOLUTION
// ═══════════════════════════════════════════════════════════════
// Runs before scoring so a library record resolved on this bar is already
// visible to this bar's neighbour search.
var bool _pendDone = false
var int  _pendRsn  = R_NONE
_pendDone := false

if barstate.isconfirmed and array.size(g_pend) > 0
    // Descending, and only reachable when the array is non-empty: with size 0
    // "for i = -1 to 0" runs UPWARD and array.get(x, -1) is a runtime error.
    for i = array.size(g_pend) - 1 to 0
        Po3Rec r = array.get(g_pend, i)
        float R = math.max(nz(r.rr, 0.0), syminfo.mintick)
        if r.dir > 0
            r.mfe := math.max(r.mfe, (high - r.entry) / R)
            r.mae := math.max(r.mae, (r.entry - low) / R)
        else
            r.mfe := math.max(r.mfe, (r.entry - low) / R)
            r.mae := math.max(r.mae, (high - r.entry) / R)
        bool hitTP = r.dir > 0 ? high >= r.tp : low <= r.tp
        bool hitSL = r.dir > 0 ? low <= r.sl : high >= r.sl
        int rsn = R_NONE
        if hitTP and hitSL
            // Intrabar ordering is unknowable from bar data. Resolve against.
            r.lbl := 0
            rsn := R_LOSS
        else if hitTP
            r.lbl := 1
            rsn := R_WIN
        else if hitSL
            r.lbl := 0
            rsn := R_LOSS
        else if bar_index - r.barIdx >= i_out_bars
            // Resolve a timeout by excursion, not to 0. Labelling every slow
            // mover a loss biases the library against the low-volatility regime.
            r.lbl := (r.mfe >= 0.80 and r.mfe > r.mae) ? 1 : 0
            rsn := R_NEUTRAL
        if r.lbl >= 0
            array<Po3Rec> lib = g_libS
            if r.dir == 1
                lib := g_libL
            array.push(lib, r)
            g_libSum += r.lbl
            g_libN += 1
            while array.size(lib) > K_LIB_CAP
                Po3Rec ev = array.shift(lib)
                g_libSum -= ev.lbl
                g_libN -= 1
            array.remove(g_pend, i)
            if r.barIdx == nz(_sigBar, -1)
                _pendDone := true
                _pendRsn := rsn

// ═══════════════════════════════════════════════════════════════
// S12  M3 SCORING — AQ / MQ / DQ  (sub-score builders)
// ═══════════════════════════════════════════════════════════════
// Returns a packed 4-slot array rather than a tuple so it can be called from
// inside the state machine without relying on local-scope tuple destructuring.
// [0]=touchHi [1]=touchLo [2]=eqHi [3]=eqLo
f_scanTouches(int nBars, float hiB, float loB) =>
    float tolT = math.max(K_TOUCH_TOL * _atr, syminfo.mintick * 4)
    float tolE = math.max(K_EQ_TOL * _atr, syminfo.mintick * 6)
    int tH = 0
    int tL = 0
    int lastH = -99
    int lastL = -99
    float eh1 = na
    float eh2 = na
    float el1 = na
    float el2 = na
    int n = math.min(nBars, 90)
    for i = 0 to n - 1
        // The rejection clause is what makes a touch evidence of DEFENCE
        // rather than an artefact of highest(): the bar had to be pushed back.
        if high[i] >= hiB - tolT and i - lastH >= K_TOUCH_SEP and math.min(close[i], open[i]) < hiB - tolT * 0.5
            tH += 1
            lastH := i
            if na(eh1) or high[i] > eh1
                eh2 := eh1
                eh1 := high[i]
            else if na(eh2) or high[i] > eh2
                eh2 := high[i]
        if low[i] <= loB + tolT and i - lastL >= K_TOUCH_SEP and math.max(close[i], open[i]) > loB + tolT * 0.5
            tL += 1
            lastL := i
            if na(el1) or low[i] < el1
                el2 := el1
                el1 := low[i]
            else if na(el2) or low[i] < el2
                el2 := low[i]
    float eqH = (tH < 2 or na(eh2)) ? 0.0 : f_c01(1.0 - math.abs(eh1 - eh2) / (tolE + 1e-10))
    float eqL = (tL < 2 or na(el2)) ? 0.0 : f_c01(1.0 - math.abs(el1 - el2) / (tolE + 1e-10))
    // var + overwrite, the same pattern f_knn uses. Single call site, and all
    // four slots are rewritten on every call, so the persistent array cannot
    // alias stale values. tH / tL are cast explicitly: array.set binds value to
    // the array's declared element type, which is the one place the int -> float
    // widening should not be left to inference.
    var array<float> out = array.new<float>(4, 0.0)
    array.set(out, 0, tH + 0.0)
    array.set(out, 1, tL + 0.0)
    array.set(out, 2, eqH)
    array.set(out, 3, eqL)
    out

f_calcAQ(int tH, int tL, float eqH, float eqL, int nBars, float w, float atrL) =>
    float a1 = f_linI(_cmpRatio, 0.18, 0.60)
    float a2 = f_band(w / (atrL + 1e-10), 0.8, 1.4, 3.2, 5.5)
    float a3 = f_lin(math.min(tH, tL), 1, 4)
    float a4 = 0.5 * eqH + 0.5 * eqL
    float a5 = f_band(nBars, 8, 14, 45, 90)
    100.0 * (0.28 * a1 + 0.16 * a2 + 0.20 * a3 + 0.22 * a4 + 0.14 * a5)

// Acceptance beyond the raided level. Volume is preferred; when the feed has
// none, the time proxy is used. It is the only volume consumer in the file, so
// no weight anywhere needs renormalising.
f_acceptVol() =>
    _hasVol ? _volBeyond / (_volSma * math.max(_excBars, 1) + 1e-10) : _barsBeyond / math.max(_excBars, 1.0)

// Three independent readings of the same question: how much did price ACCEPT
// the far side of the raided level. Closes beyond it are the strongest single
// reading, so the count is consumed here rather than being maintained on every
// excursion bar and discarded.
f_accept() =>
    0.50 * f_c01(f_acceptVol()) + 0.30 * f_c01(_consecBeyond / 3.0) + 0.20 * f_c01(_closesBeyond / math.max(_excBars, 1.0))

f_depthA() =>
    math.abs(_excExt - _lvl) / (_atrLock + 1e-10)

f_depthW() =>
    math.abs(_excExt - _lvl) / (_accW + 1e-10)

f_calcMQ() =>
    float pen = math.abs(_excExt - _lvl)
    float dA = pen / (_atrLock + 1e-10)
    // Reclaim strength, measured in ATR - NOT as a fraction of sweep depth.
    // The old rejFrac = rec/pen form could never score below 0.75, so 15 of
    // m3's 20 points were unconditional: the reclaim gate at T11 already
    // requires close to clear _lvl by eps = 0.05 * _atrLock, and because eps
    // is absolute while pen is not, a SHALLOWER sweep produced a LARGER
    // rejFrac for the same minimal reclaim - the term was anti-correlated
    // with setup quality at the shallow end. Measuring the overshoot in the
    // same unit the gate uses puts the band's floor exactly at the gate
    // boundary, so 0 is reachable and the term is monotone in reclaim
    // strength. Depth is still priced by m1 and by the K_DEPTH_VETO_* vetoes.
    float over = (_rDir < 0 ? close - _lvl : _lvl - close) / (_atrLock + 1e-10)
    float rng = math.max(_extH - _extL, syminfo.mintick)
    float wick = _rDir < 0 ? (math.min(_extO, _extC) - _extL) / rng : (_extH - math.max(_extO, _extC)) / rng
    float acc = f_accept()
    float m1 = f_band(dA, _m1lo, _m1o1, _m1o2, _m1hi)
    float m2 = f_c01(1.0 - acc / K_ACCEPT_MAX)
    float m3 = f_lin(over, 0.05, 0.50)
    float m4 = f_lin(wick, 0.25, 0.65)
    float m5 = nz(_poolSig, 0.0)
    float m6 = f_band(_excBars, 0.5, 1, 3, 7)
    100.0 * (0.18 * m1 + 0.24 * m2 + 0.20 * m3 + 0.12 * m4 + 0.20 * m5 + 0.06 * m6)

// d1 is measured from the frozen level, not from the excursion extreme, so it
// does not re-score the rejection wick that m3 already priced.
f_calcDQ() =>
    float dispAtr = math.abs(close - _lvl) / (_atrLock + 1e-10)
    float d1 = f_lin(dispAtr, _d1lo, _d1hi)
    float d2 = _fvgFound ? 0.45 + 0.55 * f_lin(_fvgSize / (_atrLock + 1e-10), 0.10, 0.45) : 0.0
    // Graded, not boolean. f_calcDQ has one call site, and it sits inside the
    // `else if mss` branch whose condition is character-for-character this
    // same test on the same bar - so as a boolean this term was a hard 1.0 and
    // handed every setup 20 undeserved DQ points. Same base-plus-grade shape
    // d2 uses above: the shift is guaranteed to EXIST here, so it earns a base
    // credit, and the clearance beyond the reference earns the rest.
    float d3 = 0.45 + 0.55 * f_lin(math.abs(close - _mssRef) / (_atrLock + 1e-10), 0.02, 0.40)
    float d4 = f_lin(_legBodyRat, 0.45, 0.80)
    float d5 = f_linI(bar_index - _manBar, 1, 10)
    100.0 * (0.32 * d1 + 0.20 * d2 + 0.20 * d3 + 0.14 * d4 + 0.14 * d5)

// ═══════════════════════════════════════════════════════════════
// S13  M3 SCORING — COMPOSITE + KNN BLEND
// ═══════════════════════════════════════════════════════════════
// Geometric chain, not a sum: a weak link cannot be bought back by a strong
// one. math.max(g, 0.01) only guards log(0); 0.01 sits far below every floor.
f_chainValid() =>
    nz(_aq, 0.0) / 100.0 >= K_GA_FLOOR and nz(_mq, 0.0) / 100.0 >= K_GM_FLOOR and nz(_dq, 0.0) / 100.0 >= K_GD_FLOOR

f_chain() =>
    float gA = math.max(nz(_aq, 0.0) / 100.0, 0.01)
    float gM = math.max(nz(_mq, 0.0) / 100.0, 0.01)
    float gD = math.max(nz(_dq, 0.0) / 100.0, 0.01)
    float c = math.exp((K_WA * math.log(gA) + K_WM * math.log(gM) + K_WD * math.log(gD)) / K_WSUM)
    c * (1.0 - 0.10 * math.min(_purgeCnt, 2))

f_targetRoom(float tp, bool tpFound) =>
    tpFound ? f_band(math.abs(tp - close) / (_atr + 1e-10), 0.3, 1.2, 6.0, 12.0) : 0.55

// Session context is capped by construction: 0.22 x 0.36 x 100 = 7.9 raw
// points on a perfect chain. Sessions cannot create, block or relabel a phase.
f_ctxScore(int dir, float tp, bool tpFound) =>
    float tr = f_targetRoom(tp, tpFound)
    float drHi = dir > 0 ? _accHi : _excExt
    float drLo = dir > 0 ? _excExt : _accLo
    // Sign-crossing denominator: guard with mintick, never with 1e-10.
    float pd = (close - drLo) / math.max(drHi - drLo, syminfo.mintick)
    float pdPos = dir > 0 ? f_c01((0.55 - pd) / 0.40) : f_c01((pd - 0.45) / 0.40)
    i_sess_ctx ? 0.30 * f_htfAlign(dir) + 0.22 * f_sessionPrior() + 0.20 * _regimeFit + 0.18 * tr + 0.10 * pdPos : (0.30 * f_htfAlign(dir) + 0.20 * _regimeFit + 0.18 * tr + 0.10 * pdPos) / 0.78

f_raw(float chain, float ctx) =>
    f_c01(chain * (0.72 + 0.36 * ctx)) * 100.0

// Fingerprint is 8-D, not 20-D: against a 100-record library a 20-D nearest
// neighbour is noise. Called only on the candidate bar - legal, because no
// ta.* history lives inside it.
f_knn(int dir, float z1, float z2, float z3, float z4, float z5, float z6, float z7, float z8) =>
    array<Po3Rec> lib = g_libS
    if dir == 1
        lib := g_libL
    int n = array.size(lib)
    float conf = na
    if n >= i_k
        float base = 0.0
        for j = 0 to n - 1
            Po3Rec hb = array.get(lib, j)
            base += hb.lbl
        base /= n
        var array<float> sd = array.new<float>()
        array.clear(sd)
        for j = 0 to n - 1
            Po3Rec h = array.get(lib, j)
            array.push(sd, f_lor(z1, h.z1) + f_lor(z2, h.z2) + f_lor(z3, h.z3) + f_lor(z4, h.z4) + f_lor(z5, h.z5) + f_lor(z6, h.z6) + f_lor(z7, h.z7) + f_lor(z8, h.z8))
        float vs = 0.0
        float ne = 0.0
        for _k = 0 to math.min(i_k, n) - 1
            int mi = 0
            float mv = array.get(sd, 0)
            for j = 1 to array.size(sd) - 1
                if array.get(sd, j) < mv
                    mv := array.get(sd, j)
                    mi := j
            float w = 1.0 / (1.0 + mv)
            ne += w
            Po3Rec hn = array.get(lib, mi)
            vs += w * hn.lbl
            // Mask, never remove: removing would desynchronise sd from lib.
            array.set(sd, mi, 1e12)
        conf := (vs + K_ML_M * base) / (ne + K_ML_M)
    conf

// Authority ramps in with sample count and is hard-capped. This weight is
// applied to the DISPLAYED score only - the signal gate in S15 tests the raw
// structural score - so Advisory changes the number printed on a bar, never
// whether that bar signals. Gate mode is the single exception and blocks
// through its own flag, not through this weight.
f_mlWeight(int nDir) =>
    float lambda = f_c01((nDir - i_k) / (50.0 - i_k))
    i_ml_mode == "Off" ? 0.0 : K_ML_CAP * lambda

f_blend(float raw, float knn, float mlW) =>
    na(knn) or mlW == 0.0 ? raw : (1.0 - mlW) * raw + mlW * 100.0 * knn

// ═══════════════════════════════════════════════════════════════
// S14  M4 TRADE LEVELS  (builders — defined ahead of the state machine
//      that consumes them at the signal transition)
// ═══════════════════════════════════════════════════════════════
// Tick rounding is directional: the stop rounds AWAY from entry and the target
// rounds TOWARD it, so rounding can never flatter the reported R.
f_slRaw(int dir, float excExt, float atrL) =>
    dir > 0 ? excExt - K_SL_BUF * atrL : excExt + K_SL_BUF * atrL

f_slFloor(int dir, float entry, float slRaw, float atrL) =>
    float minD = math.max(K_SL_MIN * atrL, syminfo.mintick * 4)
    float s = slRaw
    if math.abs(entry - s) < minD
        s := dir > 0 ? entry - minD : entry + minD
    s

f_slRound(int dir, float s) =>
    dir > 0 ? math.floor(s / syminfo.mintick) * syminfo.mintick : math.ceil(s / syminfo.mintick) * syminfo.mintick

f_tpFold(float curIn, float cand, int dir, float entry, float minD, float barrier) =>
    float b = curIn
    if not na(cand) and not na(barrier)
        bool ok = dir > 0 ? (cand > barrier and cand - entry >= minD) : (cand < barrier and entry - cand >= minD)
        if ok
            b := na(b) ? cand : (dir > 0 ? math.min(b, cand) : math.max(b, cand))
    b

// Nearest opposing pool beyond the frozen boundary and at least 1R away.
// Returns na when nothing qualifies; the caller then falls back to i_rr.
f_findTP(int dir, float entry, float R) =>
    float minD = K_TP_MIN_R * R
    float barrier = dir > 0 ? _accHi : _accLo
    float near = na
    near := f_tpFold(near, dir > 0 ? _pwh : _pwl, dir, entry, minD, barrier)
    near := f_tpFold(near, dir > 0 ? _pdh : _pdl, dir, entry, minD, barrier)
    near := f_tpFold(near, dir > 0 ? _asiaH : _asiaL, dir, entry, minD, barrier)
    near := f_tpFold(near, dir > 0 ? _lastPH : _lastPL, dir, entry, minD, barrier)
    near

// ═══════════════════════════════════════════════════════════════
// S15  M2b STATE MACHINE
// ═══════════════════════════════════════════════════════════════
var float _legBodyAbs = 0.0

// Event locals. Plain locals, NEVER var: one var here and the corresponding
// alert fires on every subsequent bar, forever.
ev_accStart = false
ev_accEnd   = false
ev_lock     = false
ev_manip    = false
ev_dist     = false
ev_sig      = false
ev_hi       = false
ev_fail     = false

if barstate.isconfirmed
    int _hops = 0

    // --- T00  day roll ----------------------------------------------------
    // A day roll must NOT kill a live sequence. _newDay is true on EVERY bar of
    // a Daily chart and on every bar of any timeframe that prints one bar per
    // session, and it is true far too often on 4H, Weekly, or a 1H regular-hours
    // equity session (6.5 bars/day, below K_ACC_MIN_BARS). Resetting the state
    // here made accumulation - and therefore every signal - unreachable on all
    // of them. Every state is bounded by its own timeout (K_FORM_MAXAGE,
    // K_ACC_MAXAGE, _manipWin, _manipWin * 2, _distWin, i_out_bars), so nothing
    // is left open by letting a sequence cross a date boundary.
    if _newDay
        _purgeCnt := 0

    // --- T01  IDLE -> ACC_FORM -------------------------------------------
    if _st == _ST_IDLE and _hops < 3 and _compressed
        _st := _ST_ACC_FORM
        _stBar := bar_index
        _startBar := bar_index
        _startTime := time
        _runHi := high
        _runLo := low
        _accBars := 1
        _miss := 0
        // A new sequence must not inherit the previous cycle's raid readings.
        // These are written only at the raid (T09/T10) and the reclaim (T11),
        // so without a clear here the "Pool raided" and "Depth · Accept" rows
        // keep describing a dead sequence on a DIFFERENT range while Phase
        // reads ACCUM FORMING. Cleared at T01 rather than at the lock because
        // every cycle passes through here, so this covers ACC_FORM too.
        // Deliberately NOT cleared: _lastRaidLvl / _lastRaidBar, whose whole
        // purpose is to survive across cycles as the anti-re-raid memo.
        _poolSig    := na
        _poolName   := "—"
        _poolCnt    := 0
        _depthShow  := na
        _acceptShow := na
        _volModeT   := false
        // _reason is NOT reset here. S02.2 documents this row as existing "so
        // a dead setup can be audited without re-reading the chart" - but a
        // new consolidation can start forming on the very next bar after one
        // dies, and resetting the reason here was wiping it before the
        // dashboard's "Engine · Last" row ever got read. It now only changes
        // at an actual ev_fail or ev_sig/T23 outcome, so it always reflects
        // the last COMPLETED cycle, however soon the next one starts.
        ev_accStart := true
        _hops += 1

    // --- T02 / T03 / T04 / T05  ACC_FORM ---------------------------------
    if _st == _ST_ACC_FORM and _hops < 3
        if _stBar != bar_index
            if _compressed
                _accBars += 1
                _runHi := na(_runHi) ? high : math.max(_runHi, high)
                _runLo := na(_runLo) ? low : math.min(_runLo, low)
                _miss := 0
            else if _miss < K_ACC_GRACE
                _miss += 1
                _accBars += 1
                _runHi := na(_runHi) ? high : math.max(_runHi, high)
                _runLo := na(_runLo) ? low : math.min(_runLo, low)
            else
                _st := _ST_IDLE
                _stBar := bar_index
                _accBars := 0
                _miss := 0
                ev_accEnd := true
                _hops += 1
        // T04b  max age. The grace budget is renewed by every compressed bar, so
        // an alternating compressed / non-compressed tape can never fall through
        // the else above. Without this bound the running boundary keeps widening
        // and a multi-ATR drift can eventually be frozen as a "consolidation".
        if _st == _ST_ACC_FORM and bar_index - _startBar > K_FORM_MAXAGE and _hops < 3
            _st := _ST_IDLE
            _stBar := bar_index
            _accBars := 0
            _miss := 0
            _reason := R_STALE
            ev_accEnd := true
            _hops += 1
        // T05 is tested after the streak update, on the same bar.
        if _st == _ST_ACC_FORM and _accBars >= K_ACC_MIN_BARS and _compressed and _hops < 3
            float wTrial = _runHi - _runLo
            float drf = wTrial / (nz(_adr, 0.0) + 1e-10)
            bool drfOk = na(_adr) or (drf >= K_DRF_MIN and drf <= K_DRF_MAX)
            if drfOk
                array<float> tt = f_scanTouches(_accBars, _runHi, _runLo)
                int tHt = int(array.get(tt, 0))
                int tLt = int(array.get(tt, 1))
                float eqHt = array.get(tt, 2)
                float eqLt = array.get(tt, 3)
                float aqT = f_calcAQ(tHt, tLt, eqHt, eqLt, _accBars, wTrial, _atr)
                if aqT >= 25.0
                    // FREEZE. Boundaries never widen after this point.
                    _accHi := _runHi
                    _accLo := _runLo
                    _accW := wTrial
                    _atrLock := _atr
                    _lockBar := bar_index
                    _touchHi := tHt
                    _touchLo := tLt
                    _aq := aqT
                    _mq := na
                    _dq := na
                    // Freeze the regime HERE, at the lock, not at the raid.
                    // _minPen and _invAtr are derived from _regVf at global
                    // scope, at the top of the bar, and they are consumed by the
                    // ACC_CONF block - which runs strictly before any raid. A
                    // freeze at the raid therefore gated sweep detection and
                    // breakout invalidation with the PREVIOUS sequence's regime.
                    // Locking it here also means every threshold this sequence
                    // uses comes from one regime reading, taken on an earlier bar
                    // than any bar that reads it.
                    _regVf := _regV
                    _regSf := _regS
                    // The plan reset that used to sit here now lives in T23,
                    // where the trade actually resolves. Clearing it at the
                    // LOCK was too late to do the job its own comment claimed:
                    // ACC_FORM runs BEFORE the lock, so a dead setup's entry,
                    // stop and target were still on the panel throughout the
                    // very state the comment named, and throughout IDLE too.
                    // Scope the opposing-raid penalty. It is earned by a dead
                    // sequence, so it has to survive the lock to mean anything -
                    // but not for the rest of the session, discounting setups
                    // that share nothing with the range that was purged.
                    if not na(_purgeBar) and bar_index - _purgeBar > K_ACC_MAXAGE
                        _purgeCnt := 0
                    _accSess := _kz
                    _seq += 1
                    _st := _ST_ACC_CONF
                    _stBar := bar_index
                    ev_lock := true
                    _hops += 1

    // --- T06 / T07 / T08 / T09 / T10  ACC_CONF ---------------------------
    if _st == _ST_ACC_CONF and _hops < 3 and _stBar != bar_index
        bool penLo = low < _accLo - _minPen * _atrLock
        bool penHi = high > _accHi + _minPen * _atrLock
        if bar_index - _lockBar > K_ACC_MAXAGE
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_STALE
            ev_fail := true
            _hops += 1
        else if close > _accHi + _invAtr * _atrLock or close < _accLo - _invAtr * _atrLock
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_BREAKOUT
            ev_fail := true
            _hops += 1
        else if penLo and penHi
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_TWOSIDED
            ev_fail := true
            _hops += 1
        else if penLo and _regV != 3 and f_pool(_accLo, -1, _touchLo) >= K_POOL_MIN and (na(_lastRaidLvl) or bar_index - _lastRaidBar > K_ACC_MAXAGE or math.abs(_accLo - _lastRaidLvl) > K_POOL_TOL * _atr)
            // The freshness clause is what stops one pool being raided over and
            // over: a shallow sweep that scores below the manipulation floor
            // returns the sequence to IDLE with price back inside a range that is
            // usually still compressed, so the identical level would otherwise
            // re-lock and re-sweep every few bars, feeding the library a run of
            // near-duplicate episodes on one price.
            _rDir := -1
            _dir := 1
            _lvl := _accLo
            _poolSig := f_pool(_accLo, -1, _touchLo)
            _poolName := f_tierName(_accLo, -1)
            _poolCnt := f_clusterN(_accLo, -1)
            _lastRaidLvl := _accLo
            _lastRaidBar := bar_index
            _excExt := low
            _excBar := bar_index
            _excBars := 0
            _volBeyond := 0.0
            _barsBeyond := 0
            _closesBeyond := 0
            _consecBeyond := 0
            _extO := open
            _extH := high
            _extL := low
            _extC := close
            _legBodyAbs := 0.0
            _legBodyRat := 0.0
            _fvgFound := false
            _fvgHi := na
            _fvgLo := na
            _fvgSize := na
            _st := _ST_MAN_DEV
            _stBar := bar_index
            _hops += 1
        else if penHi and _regV != 3 and f_pool(_accHi, 1, _touchHi) >= K_POOL_MIN and (na(_lastRaidLvl) or bar_index - _lastRaidBar > K_ACC_MAXAGE or math.abs(_accHi - _lastRaidLvl) > K_POOL_TOL * _atr)
            _rDir := 1
            _dir := -1
            _lvl := _accHi
            _poolSig := f_pool(_accHi, 1, _touchHi)
            _poolName := f_tierName(_accHi, 1)
            _poolCnt := f_clusterN(_accHi, 1)
            _lastRaidLvl := _accHi
            _lastRaidBar := bar_index
            _excExt := high
            _excBar := bar_index
            _excBars := 0
            _volBeyond := 0.0
            _barsBeyond := 0
            _closesBeyond := 0
            _consecBeyond := 0
            _extO := open
            _extH := high
            _extL := low
            _extC := close
            _legBodyAbs := 0.0
            _legBodyRat := 0.0
            _fvgFound := false
            _fvgHi := na
            _fvgLo := na
            _fvgSize := na
            _st := _ST_MAN_DEV
            _stBar := bar_index
            _hops += 1

    // --- excursion accounting (single site, covers the open bar too) ------
    if _st == _ST_MAN_DEV
        _excBars += 1
        float bf = f_c01((_rDir < 0 ? _lvl - low : high - _lvl) / math.max(high - low, syminfo.mintick))
        _volBeyond += (_hasVol ? volume : 0.0) * bf
        _barsBeyond += bf > 0.0 ? 1 : 0
        bool cb = _rDir < 0 ? close < _lvl : close > _lvl
        _closesBeyond += cb ? 1 : 0
        _consecBeyond := cb ? _consecBeyond + 1 : 0
        if (_rDir < 0 and low < _excExt) or (_rDir > 0 and high > _excExt)
            _excExt := _rDir < 0 ? low : high
            _excBar := bar_index
            _extO := open
            _extH := high
            _extL := low
            _extC := close

    // --- T11 / T12 / T13  MAN_DEV ----------------------------------------
    if _st == _ST_MAN_DEV and _hops < 3
        float eps = math.max(0.05 * _atrLock, syminfo.mintick * 2)
        bool reclaim = _rDir < 0 ? close >= _lvl + eps : close <= _lvl - eps
        float av = f_acceptVol()
        float dA = f_depthA()
        float dW = f_depthW()
        if reclaim
            float mqT = f_calcMQ()
            if mqT >= K_MQ_FLOOR
                _mq := mqT
                _depthShow := dA
                _acceptShow := f_accept()
                _volModeT := not _hasVol
                // The structure shift must be a break of the boundary the raid
                // came FROM. The previous reference was a 5-bar window measured
                // at the reclaim bar, which lies inside the raid and therefore
                // sits well below the range high on a long: the test was true on
                // essentially every bar that reached DIST_DEV, so d3 was a
                // constant and handed every setup an undeserved 20 points of DQ.
                _mssRef := _dir > 0 ? _accHi : _accLo
                _manBar := bar_index
                _manSess := _kz
                _st := _ST_MAN_CONF
                _stBar := bar_index
                ev_manip := true
                _hops += 1
            else
                _st := _ST_IDLE
                _stBar := bar_index
                _reason := R_LOWSCORE
                ev_fail := true
                _hops += 1
        else if _consecBeyond >= 3 or av > K_ACCEPT_MAX
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_ACCEPT
            ev_fail := true
            _hops += 1
        else if dA > K_DEPTH_VETO_A or dW > K_DEPTH_VETO_W
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_DEPTH
            ev_fail := true
            _hops += 1
        else if _excBars >= _manipWin
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_TIMEOUT
            ev_fail := true
            _hops += 1

    // --- T14 / T19  expansion-leg accounting (shared, single site) --------
    if _st == _ST_MAN_CONF or _st == _ST_DIST_DEV
        float bodyAbs = math.abs(close - open)
        if bodyAbs > _legBodyAbs
            _legBodyAbs := bodyAbs
            _legBodyRat := bodyAbs / math.max(high - low, syminfo.mintick)
        // First qualifying imbalance only. Never chased, never replaced.
        if not _fvgFound
            if _dir > 0 and low > high[2] and (low - high[2]) >= K_FVG_MIN * _atrLock
                _fvgFound := true
                _fvgHi := low
                _fvgLo := high[2]
                _fvgSize := low - high[2]
                _fvgTime := time[2]
            else if _dir < 0 and high < low[2] and (low[2] - high) >= K_FVG_MIN * _atrLock
                _fvgFound := true
                _fvgHi := low[2]
                _fvgLo := high
                _fvgSize := low[2] - high
                _fvgTime := time[2]
        if _st == _ST_DIST_DEV
            _distHi := na(_distHi) ? high : math.max(_distHi, high)
            _distLo := na(_distLo) ? low : math.min(_distLo, low)

    // --- T15 / T16 / T17 / T18  MAN_CONF ---------------------------------
    if _st == _ST_MAN_CONF and _hops < 3
        bool raidBrk = _dir > 0 ? close < _excExt : close > _excExt
        bool oppRaid = _dir > 0 ? (high > _accHi + _minPen * _atrLock and close <= _accHi) : (low < _accLo - _minPen * _atrLock and close >= _accLo)
        float bodyAbsN = math.abs(close - open)
        bool disp = bodyAbsN >= _dispMin * _atrLock and bodyAbsN / math.max(high - low, syminfo.mintick) >= K_DISP_BODY and (_dir > 0 ? close > open : close < open)
        if raidBrk
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_RAIDBRK
            ev_fail := true
            _hops += 1
        else if oppRaid
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_OPPRAID
            _purgeCnt += 1
            _purgeBar := bar_index
            ev_fail := true
            _hops += 1
        else if disp
            _dispBar := bar_index
            _dispTime := time
            _distHi := high
            _distLo := low
            _st := _ST_DIST_DEV
            _stBar := bar_index
            ev_dist := true
            _hops += 1
        else if bar_index - _manBar > _manipWin * 2
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_NODISP
            ev_fail := true
            _hops += 1

    // --- T17 / T18 / T20 / T21 / T22  DIST_DEV ---------------------------
    if _st == _ST_DIST_DEV and _hops < 3
        bool raidBrk2 = _dir > 0 ? close < _excExt : close > _excExt
        bool oppRaid2 = _dir > 0 ? (high > _accHi + _minPen * _atrLock and close <= _accHi) : (low < _accLo - _minPen * _atrLock and close >= _accLo)
        bool mss = _dir > 0 ? close > _mssRef : close < _mssRef
        if raidBrk2
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_RAIDBRK
            ev_fail := true
            _hops += 1
        else if oppRaid2
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_OPPRAID
            _purgeCnt += 1
            _purgeBar := bar_index
            ev_fail := true
            _hops += 1
        else if mss
            _dq := f_calcDQ()
            bool cv = f_chainValid()
            float entryC = close
            float slR = f_slFloor(_dir, entryC, f_slRaw(_dir, _excExt, _atrLock), _atrLock)
            // A sweep this deep is a different condition, not a wide version of
            // the same one. Reject it; a clamped stop would misreport its R.
            bool riskOk = math.abs(entryC - slR) <= K_SL_MAX * _atrLock
            float slC = f_slRound(_dir, slR)
            float RC = math.max(math.abs(entryC - slC), syminfo.mintick)
            float tpC = f_findTP(_dir, entryC, RC)
            bool tpF = not na(tpC)
            if not tpF
                tpC := _dir > 0 ? entryC + i_rr * RC : entryC - i_rr * RC
            // Same directional rounding rule, applied so TP moves toward entry.
            tpC := f_slRound(_dir, tpC)
            float chainC = f_chain()
            float ctxC = f_ctxScore(_dir, tpC, tpF)
            float rawC = f_raw(chainC, ctxC)
            // Recorded here, before any pass/fail branch below, so a rejected
            // candidate still leaves a number on the Data Window instead of na.
            _lastRawC := rawC
            float trC = f_targetRoom(tpC, tpF)
            float knnC = f_knn(_dir, nz(_aq, 0.0) / 100.0, nz(_mq, 0.0) / 100.0, nz(_dq, 0.0) / 100.0, nz(_volPct, 0.0) / 100.0, _regSf / 3.0, f_htfAlign(_dir), nz(_poolSig, 0.0), trC)
            int nD = _dir == 1 ? array.size(g_libL) : array.size(g_libS)
            float mlW = f_mlWeight(nD)
            float finalC = f_blend(rawC, knnC, mlW)
            bool gateBlock = i_ml_mode == "Gate" and not na(knnC) and knnC < 0.45 and nD >= 50
            // The score gate below tests rawC, the structural score, NOT the
            // blended one. g_libL / g_libS are built only from episodes that
            // resolved on the bars this chart happened to load, so gating on the
            // blend would make signal EXISTENCE a function of how much history is
            // loaded: the same bar would show a marker on one chart and nothing
            // on another. rawC is a pure function of measured price behaviour.
            // finalC still drives the number printed, the marker opacity and the
            // confluence tier. gateBlock is the one exception, and it is opt-in
            // through Adaptive Mode = Gate.
            if not riskOk
                _st := _ST_IDLE
                _stBar := bar_index
                _reason := R_RISKWIDE
                ev_fail := true
                _hops += 1
            else if not cv or rawC < i_sig_min or gateBlock
                _st := _ST_IDLE
                _stBar := bar_index
                _reason := R_LOWSCORE
                ev_fail := true
                _hops += 1
            else
                _entry := entryC
                _sl := slC
                _tp := tpC
                _R := RC
                _tpFound := tpF
                _rrMult := math.abs(tpC - entryC) / RC
                _score := finalC
                _chainShow := chainC
                _ctxShow := ctxC
                _knnAtSig := knnC
                _libnAtSig := nD
                _coldAtSig := nD < i_k
                _sigBar := bar_index
                _sigSess := _kz
                _reason := R_NONE
                Po3Rec rec = Po3Rec.new(dir = _dir, barIdx = bar_index, entry = entryC, tp = tpC, sl = slC, rr = RC, mfe = 0.0, mae = 0.0, lbl = -1, z1 = nz(_aq, 0.0) / 100.0, z2 = nz(_mq, 0.0) / 100.0, z3 = nz(_dq, 0.0) / 100.0, z4 = nz(_volPct, 0.0) / 100.0, z5 = _regSf / 3.0, z6 = f_htfAlign(_dir), z7 = nz(_poolSig, 0.0), z8 = trC)
                array.push(g_pend, rec)
                while array.size(g_pend) > K_PEND_CAP
                    array.shift(g_pend)
                _st := _ST_ACTIVE
                _stBar := bar_index
                ev_sig := true
                ev_hi := finalC >= i_hi_conf and not _coldAtSig
                _hops += 1
        else if bar_index - _dispBar > _distWin
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := R_NOMSS
            ev_fail := true
            _hops += 1

    // --- T23  ACTIVE ------------------------------------------------------
    if _st == _ST_ACTIVE and _hops < 3 and _stBar != bar_index
        if _pendDone or bar_index - _sigBar > i_out_bars
            _st := _ST_IDLE
            _stBar := bar_index
            _reason := _pendDone ? _pendRsn : R_NEUTRAL
            // Plan reset. ACTIVE is entered only at the signal and left only
            // here, and these fields are written only on the way in, so this
            // is the single point at which a plan can go stale. Clearing it
            // here - rather than at the next lock, where it used to sit -
            // means the panel stops presenting a resolved trade's entry, stop
            // and target the moment it resolves, instead of carrying them
            // through IDLE and the whole of the next ACCUM FORMING.
            // _reason is deliberately NOT cleared: row 12 labels it "Last"
            // and it must survive to report TARGET / STOP / TIMEOUT.
            _score    := na
            _entry    := na
            _sl       := na
            _tp       := na
            _R        := na
            _rrMult   := na
            _knnAtSig := na
            _tpFound  := false
            _hops += 1

// --- per-candidate alert latch --------------------------------------------
// _st != _st[1] cannot be used to detect these transitions: a bar can cascade
// ACC_CONF -> MAN_CONF or DIST_DEV -> ACTIVE, so the intermediate state never
// appears at a bar boundary and its alert would silently never fire.
var int _aManip = -1
var int _aSig   = -1
var int _aHi    = -1

fire_manip = ev_manip and _aManip != _seq
if fire_manip
    _aManip := _seq
fire_sig = ev_sig and _aSig != _seq
if fire_sig
    _aSig := _seq
fire_hi = ev_hi and _aHi != _seq
if fire_hi
    _aHi := _seq
// No per-sequence latch on this one. _seq only increments at the LOCK, so an
// invalidation that happens before any lock would be latched against a stale
// sequence number and silently suppressed for every later pre-lock failure.
// ev_fail is a plain local and the if / else-if chains above admit at most one
// invalidation per bar, so no latch is needed.
fire_fail = ev_fail

// A high-confluence signal must not also fire the ordinary one.
fire_sig_only = fire_sig and not fire_hi

// ═══════════════════════════════════════════════════════════════
// S18  DATA-WINDOW PLOTS  (hoisted above S16 so "PO3 Score" is the first
//      plot* call in the file. The six alert messages reference it BY NAME
//      via {{plot("PO3 Score")}}, so they survive a reorder - but the
//      positional {{plot_0}} form does not, and keeping the score first
//      means both spellings resolve to the same series.)
// ═══════════════════════════════════════════════════════════════
_scoreShown = _score
plot(_scoreShown, "PO3 Score", display = display.data_window)
plot(_st, "PO3 State", display = display.data_window)

// Compression diagnostics. Data-window only, so they cost no chart space and
// carry no visual weight, but they make the consolidation gate MEASURABLE
// instead of guessable: open the Data Window, hover any bar, and the exact
// sub-measure that is holding the score down is readable directly. This engine
// previously shipped with a five-way pass/fail gate that produced nothing on
// three separate instruments, and the absence of exactly this readout is why
// that took a live chart to discover.
plot(_cmpScore, "Compression Score", display = display.data_window)
plot(_cmpMin,   "Compression Needed", display = display.data_window)
plot(_cmpRel,   "· relative compression", display = display.data_window)
plot(_cmpDrft,  "· flatness", display = display.data_window)
plot(_cmpSpan,  "· width", display = display.data_window)
plot(_cmpDisp,  "· dispersion", display = display.data_window)
plot(_cmpDom,   "· bar dominance", display = display.data_window)

// Same treatment for the FINAL score gate. _scoreShown (PO3 Score, above)
// only ever holds a value when a candidate actually cleared i_sig_min, so a
// chart with zero signals gives no way to tell "candidates are dying before
// they're ever scored" (structure never confirming) apart from "candidates
// are being scored but landing under the bar" (thresholds too strict for
// this instrument). Last Candidate Score answers that directly: hover any
// bar after a raid died and compare it to Minimum Score Needed. Still na
// means the sequence never reached the DIST_DEV market-structure-shift test
// at all - look at the Phase row's reason instead.
plot(_lastRawC, "Last Candidate Score", display = display.data_window)
plot(i_sig_min, "Minimum Score Needed", display = display.data_window)

// ═══════════════════════════════════════════════════════════════
// S16  M5 VISUALS
// ═══════════════════════════════════════════════════════════════
_dirCol  = _dir > 0 ? i_c_bull : _dir < 0 ? i_c_bear : C_NEUT
_dirColT = _dir > 0 ? C_BULL_T : _dir < 0 ? C_BEAR_T : C_NEUT_T

// Millisecond bounds. With xloc.bar_time the left/right arguments are
// TIMESTAMPS, not indices; mixing conventions in one object is a runtime error.
// Derived from the timeframe, NOT from time - time[1]: that delta is the whole
// weekend or overnight gap on the first bar of a session, so a box created
// there projected K_PROJ multiples of a 65-hour "bar" and stretched weeks into
// the future - permanently, since the right edge is only re-set while the
// sequence is live. nz(..., 60) is defensive cover for tick/non-standard
// charts where in_seconds can be na.
_barMs  = math.max(nz(timeframe.in_seconds(timeframe.period), 60) * 1000, 1)
_rightT = time + _barMs * K_PROJ

// --- glyph stagger ---------------------------------------------------------
// Assigned BEFORE the anchor series is built so the plot and the score label
// agree on the same y.
var int   _lastBullBar = na
var int   _lastBearBar = na
var float _lastBullOff = K_OFF_GLYPH
var float _lastBearOff = K_OFF_GLYPH
_offL = not na(_lastBullBar) and bar_index - _lastBullBar <= K_STAG_WIN ? math.min(_lastBullOff + K_STAG_STEP, K_STAG_MAX) : K_OFF_GLYPH
_offS = not na(_lastBearBar) and bar_index - _lastBearBar <= K_STAG_WIN ? math.min(_lastBearOff + K_STAG_STEP, K_STAG_MAX) : K_OFF_GLYPH
if ev_sig and _dir > 0
    _lastBullBar := bar_index
    _lastBullOff := _offL
if ev_sig and _dir < 0
    _lastBearBar := bar_index
    _lastBearOff := _offS

_bullY = low - _atr * _offL
_bearY = high + _atr * _offS

// Cold start disables the circle tier outright and pins triangles to a fixed
// transparency. Encoding cold start as extra transparency would erase the
// marker on a light theme.
bullSig = ev_sig and _dir > 0
bearSig = ev_sig and _dir < 0
bullHi  = bullSig and _score >= i_hi_conf and not _coldAtSig
bullStd = bullSig and not bullHi
bearHi  = bearSig and _score >= i_hi_conf and not _coldAtSig
bearStd = bearSig and not bearHi

// style= is a const argument and cannot switch at runtime, so the high and
// standard tiers must be mutually exclusive series.
plotshape(bullHi ? _bullY : na, "PO3 Long High", shape.circle, location.absolute, color.new(i_c_bull, f_mA(_score)), size = size.small)
plotshape(bullStd ? _bullY : na, "PO3 Long", shape.triangleup, location.absolute, color.new(i_c_bull, _coldAtSig ? 55 : f_mA(_score)), size = size.small)
plotshape(bearHi ? _bearY : na, "PO3 Short High", shape.circle, location.absolute, color.new(i_c_bear, f_mA(_score)), size = size.small)
plotshape(bearStd ? _bearY : na, "PO3 Short", shape.triangledown, location.absolute, color.new(i_c_bear, _coldAtSig ? 55 : f_mA(_score)), size = size.small)

// Session tint sits at the very bottom of the hierarchy and must read as
// almost nothing.
bgcolor(i_sess_ctx and not i_zen and _kz != 0 ? color.new(C_NEUT, A_TINT) : na, title = "Session Tint")

// --- accumulation range ----------------------------------------------------
var box  _accBox = na
var bool _accBoxLocked = false
var array<box> _hAcc = array.new<box>()

// Fixed by role, not by HTF lean or trade direction: ACC is always orange,
// DIST (below) is always blue. An HTF-lean-based ACC color used to show the
// SAME "ACC" tag in blue, orange, or grey depending on context, which read as
// a broken/inconsistent indicator rather than a deliberate signal - fixed
// 2026-08-20 after live user feedback on a BTCUSD chart.
_accCol = i_c_bear

if i_show_acc
    if ev_accStart
        if not na(_accBox)
            if _accBoxLocked
                f_poolPushB(_hAcc, _accBox, K_KEEP)
            else
                box.delete(_accBox)
        // Short type tag only ("ACC"), top-RIGHT. Without it an accumulation
        // box and a distribution box are two identical rectangles. Kept to
        // three letters and pinned to the opposite corner from DIST's tag so
        // the two can never overlap into unreadable text the way the old
        // full-word captions did; the dashboard Phase row carries the detail.
        _accBox := box.new(_startTime, high, _rightT, low, xloc = xloc.bar_time, border_color = color.new(_accCol, A_SOFT), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(_accCol, A_GHOST), text = i_zen ? "" : "ACC", text_color = color.new(_accCol, A_SOFT), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_top)
        _accBoxLocked := false
    if ev_accEnd and not na(_accBox) and not _accBoxLocked
        box.delete(_accBox)
        _accBox := na
    if not na(_accBox) and _st == _ST_ACC_FORM and not ev_accStart
        box.set_top(_accBox, _runHi)
        box.set_bottom(_accBox, _runLo)
        box.set_right(_accBox, _rightT)
        // HTF bias can flip while a range is still forming; keep the box's
        // lean current rather than freezing whatever it read on the first bar.
        // The tag colour is re-applied alongside the border and fill - without
        // it a flip mid-formation leaves the "ACC" text in the previous hue.
        box.set_border_color(_accBox, color.new(_accCol, A_SOFT))
        box.set_bgcolor(_accBox, color.new(_accCol, A_GHOST))
        box.set_text_color(_accBox, color.new(_accCol, A_SOFT))
    // LOCK: a five-property jump, not the old single 62->55 border nudge, so
    // "this is now a confirmed structural range" reads as an actual event.
    // Reuses A_BOLD (already the distribution box's own border alpha) rather
    // than a new alpha tier, so a locked ACC range and a live DIST zone read
    // as the same grade of "confirmed" rather than needing a third rung.
    if ev_lock and not na(_accBox)
        box.set_top(_accBox, _accHi)
        box.set_bottom(_accBox, _accLo)
        // Solid, width 1 - not the old dashed width-2 border. Two independent
        // accumulation cycles can legitimately land bars apart, and a heavy
        // dashed edge on both reads as one smeared shape at the seam. A thin
        // solid line, matching the crisp rectangles the OB AI / SR AI
        // publication charts already use, stays legible even touching another
        // box, and still steps up from FORMING's dotted style to mark "this
        // range is now confirmed."
        box.set_border_style(_accBox, line.style_solid)
        box.set_border_color(_accBox, color.new(_accCol, A_BOLD))
        box.set_border_width(_accBox, 1)
        box.set_bgcolor(_accBox, color.new(_accCol, A_ZONE))
        box.set_text_color(_accBox, color.new(_accCol, A_BOLD))
        _accBoxLocked := true
    // RECEDE #1: fades toward the background now that the raid is the story,
    // but stays _accCol (fixed orange) - the box never changes hue, only fades.
    if ev_manip and not na(_accBox)
        box.set_border_color(_accBox, color.new(_accCol, A_SOFT))
        box.set_bgcolor(_accBox, color.new(_accCol, A_FAINT))
        box.set_text_color(_accBox, color.new(_accCol, A_SOFT))
    // RECEDE #2: by displacement, ACC is a breadcrumb - it must never compete
    // with the now-dominant distribution zone for attention.
    if ev_dist and not na(_accBox)
        box.set_border_color(_accBox, color.new(_accCol, A_FAINT))
        box.set_bgcolor(_accBox, color.new(_accCol, A_GHOST))
        box.set_text_color(_accBox, color.new(_accCol, A_FAINT))
    if not na(_accBox) and _live and _st != _ST_ACC_FORM
        box.set_right(_accBox, _rightT)

// --- distribution zone + rail ---------------------------------------------
var box  _distBox = na
var line _railLn  = na
var array<box>  _hDist = array.new<box>()
var array<line> _hRail = array.new<line>()

// DIST box is fixed blue (mirrors ACC's fixed orange above) - the rail line,
// raid marker, and signal label below stay _dirCol/_dirColT on purpose, since
// those genuinely encode long-vs-short trade direction. Only the ACC/DIST
// ZONE TAGS themselves needed to stop varying by context.
_distCol  = i_c_bull
_distColT = C_BULL_T

if i_show_dist
    if ev_dist
        if not na(_distBox)
            f_poolPushB(_hDist, _distBox, K_KEEP)
        // bgcolor/rail color were f_zA(55.0) / f_lA(55.0) - 55.0 was a
        // placeholder plugged into the CONFIDENCE formula before any real
        // score exists yet at displacement time, which evaluated to ~10%
        // opaque and made the zone nearly invisible for its entire DIST_DEV
        // life. Decoupled to fixed A_ZONE/A_MID instead: the zone announces
        // itself the instant displacement confirms, independent of a score
        // that will not exist until ev_sig (below) re-grades it for real.
        // Short type tag ("DIST"), top-LEFT - the opposite corner from ACC's
        // top-right tag, so the two can never overlap even where a
        // distribution zone sits directly on top of the range it came from.
        _distBox := box.new(_dispTime, _distHi, _rightT, _distLo, xloc = xloc.bar_time, border_color = color.new(_distCol, A_BOLD), border_width = 1, border_style = line.style_solid, bgcolor = color.new(_distCol, A_ZONE), text = i_zen ? "" : "DIST", text_color = color.new(_distColT, A_BOLD), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)
        if not na(_railLn)
            f_poolPushLn(_hRail, _railLn, K_KEEP)
        _railLn := line.new(_manBar, _lvl, bar_index + K_PROJ, _lvl, color = color.new(_dirCol, A_MID), width = 2, style = line.style_solid)
    // Each handle is guarded on its own identity. The box and the rail are
    // created together today, but nothing in the code enforces that, and a
    // line.set_* on an na id is a runtime error with no compile-time warning.
    if not na(_distBox) and (_st == _ST_DIST_DEV or _st == _ST_ACTIVE)
        box.set_top(_distBox, _distHi)
        box.set_bottom(_distBox, _distLo)
        box.set_right(_distBox, _rightT)
        if not na(_railLn)
            line.set_x2(_railLn, bar_index + K_PROJ)
    if ev_sig and not na(_distBox)
        box.set_bgcolor(_distBox, color.new(_distCol, f_zA(_score)))
    if ev_sig and not na(_railLn)
        line.set_color(_railLn, color.new(_dirCol, f_lA(_score)))

// --- first imbalance inside the expansion leg ------------------------------
var box _fvgBox = na
_fvgNew = _fvgFound and not _fvgFound[1]

// Confirmed bars only. Every other object in this file is mutated from inside
// the confirmed block; leaving this one at global scope let an intrabar wick
// through the midpoint delete the box on a tick and Pine's realtime rollback
// restore it on the next, so it blinked for reasons no closed bar recorded.
// The state test also replaces _live: _live is true again as soon as a NEW
// accumulation starts forming, which was stretching a dead cycle's box across
// it and then mid-testing it against the opposite direction.
if i_show_fvg and not i_zen and barstate.isconfirmed
    if _fvgNew
        box.delete(_fvgBox)
        _fvgBox := box.new(_fvgTime, _fvgHi, _rightT, _fvgLo, xloc = xloc.bar_time, border_color = color.new(_dirCol, 55), border_width = 1, border_style = line.style_dotted, bgcolor = color.new(_dirCol, A_FAINT))
    if not na(_fvgBox) and (_st == _ST_MAN_CONF or _st == _ST_DIST_DEV or _st == _ST_ACTIVE)
        box.set_right(_fvgBox, _rightT)
    if not na(_fvgBox) and not na(_fvgHi) and not na(_fvgLo)
        float mid = (_fvgHi + _fvgLo) * 0.5
        if (_dir > 0 and low <= mid) or (_dir < 0 and high >= mid)
            box.delete(_fvgBox)
            _fvgBox := na
// Clear on any cycle end, not only at the next lock, so a box cannot outlive
// the direction that built it.
if (ev_lock or ev_fail) and not na(_fvgBox)
    box.delete(_fvgBox)
    _fvgBox := na

// --- raid marker + stub ----------------------------------------------------
var array<label> _hRaid = array.new<label>()
var array<line>  _hStub = array.new<line>()

if ev_manip
    // Icon-only (the xcross glyph itself): a caption word here ("RAIDED")
    // reads as jargon to someone just trying to tell buy from sell, and it
    // could collide with the distribution box's own text when a raid and a
    // displacement land close together. Full detail (which level, its
    // weight) already lives on the dashboard's "Pool raided" row and in
    // this label's own hover tooltip - the chart stays icon-only.
    // The tooltip states the anchor explicitly: this glyph sits on the bar that
    // made the sweep extreme, but it is only created once the reclaim closes,
    // which can be several bars later. It marks a LOCATION, not a bar on which
    // anything was signalled.
    string rtip = "Liquidity taken at " + f_px(_lvl) + " (" + _poolName + "). Pool weight " + f_num(_poolSig, 2) + ", depth " + f_num(f_depthA(), 2) + " ATR, reclaimed on close. This mark is placed on the bar that made the sweep extreme, but it is drawn only once the reclaim bar closes - it marks where liquidity was taken, not a bar to act on."
    label rlb = label.new(_excBar, _excExt, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_xcross, color = color.new(_dirCol, A_BOLD), textcolor = color.new(_dirColT, A_BOLD), size = size.small, tooltip = rtip)
    f_poolPushL(_hRaid, rlb, 15)
    if not i_zen
        // x1 now traces from the range's own origin (_startBar), not just
        // lock-to-raid, so the line reads as one continuous price thread from
        // ACC's frozen edge through to the raid rather than a short stub.
        line rst = line.new(_startBar, _lvl, _excBar + 3, _lvl, color = color.new(_dirCol, A_BOLD), width = 2, style = line.style_dashed)
        f_poolPushLn(_hStub, rst, 8)

// --- score label -----------------------------------------------------------
var array<label> _hScore = array.new<label>()

if ev_sig and not i_zen
    float gy = _dir > 0 ? _bullY : _bearY
    float ty = _dir > 0 ? gy - _atr * K_OFF_TEXT : gy + _atr * K_OFF_TEXT
    float usedOff = _dir > 0 ? _offL : _offS
    // At the stagger ceiling the text is dropped rather than stacking a rung.
    if usedOff < K_STAG_MAX
        // BUY/SELL spelled out explicitly - the triangle direction and colour
        // already encode this, but a bare score number ("PO3 ~62") makes a
        // viewer check colour/orientation to tell which side it is. Text is
        // free here: this is a label, not a plotshape, so it does not touch
        // the plot-slot budget the header comment tracks.
        label slb = label.new(bar_index, ty, "PO3 " + (_dir > 0 ? "BUY " : "SELL ") + (_coldAtSig ? "~" : "") + f_num(_score, 0), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(_dirColT, f_tA(_score)), size = size.small)
        f_poolPushL(_hScore, slb, 20)

// --- stop / target singletons ---------------------------------------------
// Mutated, never deleted and recreated. When no plan is live their y is set
// to na so they leave the viewport without leaving the object budget.
var line  _slLn = na
var line  _tpLn = na
var label _slLb = na
var label _tpLb = na

if i_show_sltp
    if ev_sig
        int lalp = i_zen ? 55 : 35
        if na(_slLn)
            _slLn := line.new(bar_index, _sl, bar_index + K_PROJ, _sl, color = color.new(C_SL, lalp), width = 1, style = line.style_dashed)
            _tpLn := line.new(bar_index, _tp, bar_index + K_PROJ, _tp, color = color.new(C_TP, lalp), width = 1, style = line.style_dashed)
        else
            line.set_xy1(_slLn, bar_index, _sl)
            line.set_xy2(_slLn, bar_index + K_PROJ, _sl)
            line.set_color(_slLn, color.new(C_SL, lalp))
            line.set_xy1(_tpLn, bar_index, _tp)
            line.set_xy2(_tpLn, bar_index + K_PROJ, _tp)
            line.set_color(_tpLn, color.new(C_TP, lalp))
        if not i_zen
            if na(_slLb)
                _slLb := label.new(bar_index + K_PROJ + 3, _sl, "SL " + f_px(_sl), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(C_SL, 20), size = size.tiny)
                _tpLb := label.new(bar_index + K_PROJ + 3, _tp, "TP " + f_px(_tp), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(C_TP, 20), size = size.tiny)
            else
                label.set_xy(_slLb, bar_index + K_PROJ + 3, _sl)
                label.set_text(_slLb, "SL " + f_px(_sl))
                label.set_xy(_tpLb, bar_index + K_PROJ + 3, _tp)
                label.set_text(_tpLb, "TP " + f_px(_tp))
    if not na(_slLn) and _st == _ST_ACTIVE and not ev_sig
        line.set_x2(_slLn, bar_index + K_PROJ)
        line.set_x2(_tpLn, bar_index + K_PROJ)
        if not na(_slLb)
            label.set_x(_slLb, bar_index + K_PROJ + 3)
            label.set_x(_tpLb, bar_index + K_PROJ + 3)
    if not na(_slLn) and _st != _ST_ACTIVE
        line.set_y1(_slLn, na)
        line.set_y2(_slLn, na)
        line.set_y1(_tpLn, na)
        line.set_y2(_tpLn, na)
        if not na(_slLb)
            label.set_y(_slLb, na)
            label.set_y(_tpLb, na)

// ═══════════════════════════════════════════════════════════════
// S17  M5 DASHBOARD
// ═══════════════════════════════════════════════════════════════
// The panel is a fixed dark plate on BOTH themes: Pine cannot read the user's
// theme, so all panel text is light and D_WARN is confined to it.
f_scoreBand(float s) =>
    na(s) ? "—" : s >= 80 ? "HIGH" : s >= 65 ? "MID" : "LOW"

// O(1) read of the running totals maintained in S11. The libraries only mutate
// inside barstate.isconfirmed, so this cannot change between ticks of a bar -
// rescanning up to 200 records on every tick of the last bar bought nothing.
f_baseRate() =>
    g_libN > 0 ? g_libSum / g_libN : na

_pill = _st == _ST_ACTIVE ? (_dir > 0 ? "● LONG" : "● SHORT") : (_st == _ST_MAN_CONF or _st == _ST_DIST_DEV) ? "● ARMED" : (_st == _ST_ACC_FORM or _st == _ST_ACC_CONF or _st == _ST_MAN_DEV) ? "● WATCHING" : _regV == 3 ? "◐ DORMANT" : _cold ? "◐ COLD" : "● QUIET"
_pillCol = _st == _ST_ACTIVE ? (_dir > 0 ? D_BULL : D_BEAR) : (_st == _ST_MAN_CONF or _st == _ST_DIST_DEV) ? D_VAL : _regV == 3 ? D_WARN : D_KEY
// _dir is set at the raid and never cleared, so during ACC_FORM / ACC_CONF it
// still holds the PREVIOUS cycle's side. Those are exactly the states in which
// no direction has been established yet - nothing has been raided - so the
// panel must not assert one. Gated for DISPLAY only: clearing _dir itself
// would force _cold true via _nDir and strand the status pill on "COLD".
_dirLive  = _st >= _ST_MAN_DEV ? _dir : 0
_phaseCol = _dirLive > 0 ? D_BULL : _dirLive < 0 ? D_BEAR : C_NEUT

// Row budget, and the rule that governs it: a table declared with fewer rows
// than the mode goes on to write drops the overflow SILENTLY - there is no
// error to catch. So the count below must always equal the number of rows the
// widest mode writes, and the writer below must never emit a row index >= it.
// Both modes are driven by one cursor in the writer, so adding a row means
// bumping only the constant that matches its mode.
//   Essential  7 : header + score + Phase + Bias + Entry + SL/TP + R multiple
//   Full      19 : the above, plus A/M/D, Regime, Pool, Depth, HTF and Engine
//                  interleaved in their original order, plus a 6-row chart key
bool _dashFull = i_dash_mode == "Full"
int _dashRows = _dashFull ? 19 : 7
var table dash = na
if i_dash_on and not i_zen and na(dash)
    if i_dash_pos == "Top Right"
        dash := table.new(position.top_right, 2, _dashRows, bgcolor = color.new(D_BG, 8), border_color = color.new(C_NEUT, 78), border_width = 1, frame_color = color.new(C_NEUT, 55), frame_width = 1)
    else if i_dash_pos == "Top Left"
        dash := table.new(position.top_left, 2, _dashRows, bgcolor = color.new(D_BG, 8), border_color = color.new(C_NEUT, 78), border_width = 1, frame_color = color.new(C_NEUT, 55), frame_width = 1)
    else if i_dash_pos == "Bottom Right"
        dash := table.new(position.bottom_right, 2, _dashRows, bgcolor = color.new(D_BG, 8), border_color = color.new(C_NEUT, 78), border_width = 1, frame_color = color.new(C_NEUT, 55), frame_width = 1)
    else
        dash := table.new(position.bottom_left, 2, _dashRows, bgcolor = color.new(D_BG, 8), border_color = color.new(C_NEUT, 78), border_width = 1, frame_color = color.new(C_NEUT, 55), frame_width = 1)

// Written once, on the last bar only. A 19-row panel rewritten every bar is
// hundreds of thousands of table.cell() calls for no visible difference.
if i_dash_on and not i_zen and barstate.islast and not na(dash)
    int mlN = array.size(g_libL) + array.size(g_libS)
    // "Samples", not "Learning": nothing is trained. And the stored resolved
    // fraction is NOT printed on the panel - a bare number on the chart surface
    // invites being read as a result the indicator produced. It lives in the row
    // tooltip instead, stated next to exactly what it is and is not.
    string mlState = i_ml_mode == "Off" ? "Off" : mlN < i_k ? "Samples " + str.tostring(mlN) + "/" + str.tostring(i_k) : "Active " + str.tostring(mlN)
    string mlTip = "Count of past episodes stored from the history loaded on this chart. No model is trained: the engine compares the current episode against stored ones by distance. Stored outcomes are hypothetical, assume no commission and no slippage, resolve a bar that touched both stop and target against the setup, and are not a record of trading results. Stored fraction resolved at target: " + f_num(f_baseRate(), 2) + "."
    bool subOk = not na(_aq) and not na(_mq) and not na(_dq)
    float subMin = subOk ? math.min(_aq, math.min(_mq, _dq)) : na
    color dirPanel = _dir > 0 ? D_BULL : _dir < 0 ? D_BEAR : C_NEUT
    string htfTxt = not _htfOk ? "n/a" : i_htf + " " + (_htfTr == 1 ? "▲" : _htfTr == -1 ? "▼" : "▬") + " · " + (_htfPD >= 0.60 ? "Premium" : _htfPD <= 0.40 ? "Discount" : "Equilibrium")
    color htfCol = not _htfOk ? C_NEUT : _htfTr == 1 ? D_BULL : _htfTr == -1 ? D_BEAR : C_NEUT

    // One cursor drives both modes, so Essential packs its rows contiguously
    // instead of leaving holes where the diagnostic rows were. Every row below
    // advances it exactly once; the Full-only rows are wrapped in `if
    // _dashFull`. The cursor must never exceed _dashRows - 1 (see the note on
    // the declaration above: overflow is dropped silently, with no error).
    int r = 0

    // Header banner: the title row gets its own more-opaque cell background
    // (D_BG,0 vs the panel's D_BG,8) so it reads as a title strip rather than
    // blending into the rest of the panel.
    table.cell(dash, 0, r, "PO3 AI", width = 12, text_color = D_VAL, text_halign = text.align_left, text_size = size.small, bgcolor = color.new(D_BG, 0), tooltip = "Accumulation - Manipulation - Distribution sequence detection, scored 0-100 on measured price behaviour. \"AI\" here means an adaptive confluence-scoring engine: weighted measurements of the sequence, plus a distance comparison against past episodes stored from this chart's own history. No model is trained, nothing is forecast, and the score is not a probability.")
    table.cell(dash, 1, r, _pill, width = 0, text_color = _pillCol, text_halign = text.align_right, text_size = size.small, bgcolor = color.new(D_BG, 0))
    r += 1

    table.cell(dash, 0, r, f_num(_scoreShown, 0), width = 12, text_color = D_VAL, text_halign = text.align_left, text_size = size.large)
    // Gradient runs grey -> direction hue and is clamped to [40,90]. The score
    // is a magnitude of confluence, not a direction: a bear->bull gradient
    // would paint a weak long orange.
    table.cell(dash, 1, r, f_meter(_scoreShown) + "  " + f_scoreBand(_scoreShown), width = 0, text_color = color.from_gradient(nz(_scoreShown, 40.0), 40, 90, C_NEUT, dirPanel), text_halign = text.align_right, text_size = size.small)
    r += 1

    table.cell(dash, 0, r, "Phase", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small, tooltip = "Current stage of the sequence, how many bars it has held, and the live compression score against the score a window must reach to be treated as a consolidation. If the engine is drawing nothing, this row is where to look: a compression score that keeps stalling below the second number means no range is qualifying on this instrument and timeframe, which is what the Consolidation Sensitivity input adjusts.")
    // The compression readout rides on the Phase row rather than taking a row of
    // its own. It is the single most useful number when nothing is being drawn,
    // so it belongs where the user already looks first - and it survives into
    // Essential mode, where the diagnostic rows below are hidden.
    table.cell(dash, 1, r, f_stName(_st) + " · " + str.tostring(bar_index - _stBar) + "b · cmp " + str.tostring(math.round(nz(_cmpScore, 0.0))) + "/" + str.tostring(math.round(_cmpMin)), width = 0, text_color = _phaseCol, text_halign = text.align_right, text_size = size.small)
    r += 1

    table.cell(dash, 0, r, "Bias", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, r, _dirLive > 0 ? "LONG" : _dirLive < 0 ? "SHORT" : "—", width = 0, text_color = _dirLive > 0 ? D_BULL : _dirLive < 0 ? D_BEAR : D_VAL, text_halign = text.align_right, text_size = size.small)
    r += 1

    // --- diagnostic rows: Full mode only ------------------------------------
    if _dashFull
        table.cell(dash, 0, r, "A / M / D", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small, tooltip = "The three phase sub-scores that feed the headline number: Accumulation quality, Manipulation quality, Distribution quality, each 0-100. They combine as a weighted geometric mean, so a weak link drags the total down rather than being averaged away.")
        // Coloured by the WEAKEST link: a 95/95/40 sequence is a 40 sequence.
        table.cell(dash, 1, r, f_num(_aq, 0) + " / " + f_num(_mq, 0) + " / " + f_num(_dq, 0), width = 0, text_color = subOk ? color.from_gradient(subMin, 40, 90, C_NEUT, dirPanel) : D_VAL, text_halign = text.align_right, text_size = size.small)
        r += 1

        table.cell(dash, 0, r, "Regime", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
        table.cell(dash, 1, r, f_regVName(_regV) + " · " + f_regSName(_regS), width = 0, text_color = _regV == 3 ? D_WARN : D_VAL, text_halign = text.align_right, text_size = size.small)
        r += 1

        table.cell(dash, 0, r, "Pool raided", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small, tooltip = "Which liquidity level the sweep took, the weight that level carried, and - as \"xN\" - how many separate reference levels sat clustered within tolerance of it. Swing highs and lows in this weighting confirm 10 bars after the swing forms, so a level newer than that is not yet included.")
        // The cluster count is appended here rather than printed on the chart:
        // it is exactly the kind of detail that belongs in the panel, and it is
        // the only place _poolCnt is read now that the raid glyph is icon-only.
        table.cell(dash, 1, r, na(_poolSig) ? "—" : _poolName + " · " + f_num(_poolSig, 2) + (_poolCnt >= 2 ? " x" + str.tostring(_poolCnt) : ""), width = 0, text_color = D_VAL, text_halign = text.align_right, text_size = size.small)
        r += 1

        table.cell(dash, 0, r, "Depth · Accept", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
        table.cell(dash, 1, r, na(_depthShow) ? "—" : f_num(_depthShow, 2) + "A · " + f_num(_acceptShow, 2) + (_volModeT ? " (t)" : ""), width = 0, text_color = D_VAL, text_halign = text.align_right, text_size = size.small)
        r += 1

        table.cell(dash, 0, r, "HTF", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
        table.cell(dash, 1, r, htfTxt, width = 0, text_color = htfCol, text_halign = text.align_right, text_size = size.small)
        r += 1

    // --- trade levels: both modes -------------------------------------------
    table.cell(dash, 0, r, "Entry", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, r, f_px(_entry), width = 0, text_color = D_VAL, text_halign = text.align_right, text_size = size.small)
    r += 1

    table.cell(dash, 0, r, "SL / TP", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, r, f_px(_sl) + " / " + f_px(_tp) + (na(_tp) or _tpFound ? "" : " (R)"), width = 0, text_color = D_VAL, text_halign = text.align_right, text_size = size.small)
    r += 1

    table.cell(dash, 0, r, "R multiple", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
    table.cell(dash, 1, r, na(_rrMult) ? "—" : f_num(_rrMult, 1) + "R", width = 0, text_color = D_VAL, text_halign = text.align_right, text_size = size.small)
    r += 1

    if _dashFull
        table.cell(dash, 0, r, "Engine · Last", width = 12, text_color = D_KEY, text_halign = text.align_left, text_size = size.small)
        table.cell(dash, 1, r, mlState + " · " + (_reason == R_NONE ? "—" : f_reason(_reason)), width = 0, text_color = mlN < i_k ? D_WARN : D_VAL, text_halign = text.align_right, text_size = size.small, tooltip = mlTip)
        r += 1

        // --- chart key: what every mark on the chart means -------------------
        // The chart itself is deliberately icon-only - no captions beyond the
        // ACC / DIST tags and the BUY / SELL score label - so this is where the
        // vocabulary is defined. It is the reason Full is the default mode.
        table.cell(dash, 0, r, "Chart key", width = 12, text_color = D_VAL, text_halign = text.align_left, text_size = size.tiny, bgcolor = color.new(D_BG, 0))
        table.cell(dash, 1, r, "", width = 0, text_color = D_VAL, text_halign = text.align_right, text_size = size.tiny, bgcolor = color.new(D_BG, 0))
        r += 1

        // Fixed by role now, not by HTF lean - ACC is always orange, so the
        // legend swatch can show that hue directly instead of a neutral tone.
        table.cell(dash, 0, r, "ACC", width = 12, text_color = color.new(i_c_bear, 0), text_halign = text.align_left, text_size = size.tiny, tooltip = "Dotted box, tagged ACC in its top-right corner: the consolidation the engine is tracking. Faint while the range is still forming and still widening; it brightens and switches to a dashed border at the moment the range qualifies and its boundaries freeze. Always orange - fixed by role, independent of HTF lean or trade direction.")
        table.cell(dash, 1, r, "Accumulation range", width = 0, text_color = D_KEY, text_halign = text.align_right, text_size = size.tiny)
        r += 1

        table.cell(dash, 0, r, "DIST", width = 12, text_color = color.new(i_c_bull, 0), text_halign = text.align_left, text_size = size.tiny, tooltip = "Solid box, tagged DIST in its top-left corner: the expansion leg away from the raided level, drawn once a displacement bar confirms. Always blue - fixed by role, independent of trade direction. Its fill deepens with the score when a signal fires.")
        table.cell(dash, 1, r, "Distribution zone", width = 0, text_color = D_KEY, text_halign = text.align_right, text_size = size.tiny)
        r += 1

        // Called out on its own line and labelled "not an entry" because the
        // xcross is the mark most easily mistaken for a signal: it is bright,
        // direction-coloured, and sits at an obvious swing extreme.
        table.cell(dash, 0, r, "✕", width = 12, text_color = C_NEUT_T, text_halign = text.align_left, text_size = size.tiny, tooltip = "Liquidity raid marker. It is placed on the bar that made the sweep extreme, but it is only drawn once the reclaim bar closes - which can be several bars later. It marks WHERE liquidity was taken. It is not an entry and not a bar to act on.")
        table.cell(dash, 1, r, "Raid · not an entry", width = 0, text_color = D_KEY, text_halign = text.align_right, text_size = size.tiny)
        r += 1

        // Coloured in i_c_bull / i_c_bear - the same two inputs that colour
        // every glyph in S16 - rather than a neutral tone, so the legend's hue
        // always matches what is on the chart even if the user changes them.
        table.cell(dash, 0, r, "▲ Long", width = 12, text_color = color.new(i_c_bull, 0), text_halign = text.align_left, text_size = size.tiny, tooltip = "● circle = high confluence (score ≥ High Confluence Score, warm library only). ▲ triangle = standard long signal. Both are drawn on the bar the signal fired, and carry a \"PO3 BUY\" label with the score.")
        table.cell(dash, 1, r, "● hi · ▲ std", width = 0, text_color = color.new(i_c_bull, 0), text_halign = text.align_right, text_size = size.tiny)
        r += 1

        table.cell(dash, 0, r, "▼ Short", width = 12, text_color = color.new(i_c_bear, 0), text_halign = text.align_left, text_size = size.tiny, tooltip = "● circle = high confluence (score ≥ High Confluence Score, warm library only). ▼ triangle = standard short signal. Both are drawn on the bar the signal fired, and carry a \"PO3 SELL\" label with the score.")
        table.cell(dash, 1, r, "● hi · ▼ std", width = 0, text_color = color.new(i_c_bear, 0), text_halign = text.align_right, text_size = size.tiny)

// ═══════════════════════════════════════════════════════════════
// S19  M6 ALERTS
// ═══════════════════════════════════════════════════════════════
// message is a const string, so the score cannot be interpolated - it rides
// the {{plot("PO3 Score")}} placeholder and is resolved at fire time.
// The bodies carry the neutral short name only. The account naming convention
// covers the indicator TITLE; it does not extend to payloads delivered to
// third-party endpoints, and the name adds nothing the alert's own title does
// not already give the user.
alertcondition(fire_sig_only and _dir > 0, "PO3 Long",
     "PO3 {{ticker}} {{interval}}: bullish PO3 sequence confirmed at {{close}}. Confluence {{plot(\"PO3 Score\")}}.")
alertcondition(fire_sig_only and _dir < 0, "PO3 Short",
     "PO3 {{ticker}} {{interval}}: bearish PO3 sequence confirmed at {{close}}. Confluence {{plot(\"PO3 Score\")}}.")
alertcondition(fire_hi and _dir > 0, "PO3 Long High Confluence",
     "PO3 {{ticker}} {{interval}}: bullish PO3 sequence confirmed, high confluence, at {{close}}. Confluence {{plot(\"PO3 Score\")}}.")
alertcondition(fire_hi and _dir < 0, "PO3 Short High Confluence",
     "PO3 {{ticker}} {{interval}}: bearish PO3 sequence confirmed, high confluence, at {{close}}. Confluence {{plot(\"PO3 Score\")}}.")
alertcondition(fire_manip, "PO3 Manipulation Confirmed",
     "PO3 {{ticker}} {{interval}}: liquidity raid confirmed and reclaimed at {{close}}. Awaiting expansion.")
alertcondition(fire_fail, "PO3 Setup Invalidated",
     "PO3 {{ticker}} {{interval}}: developing PO3 sequence invalidated at {{close}}.")

// Structured payload, OPT-IN. ml and libn emit null during cold start, never
// 0.5: a consumer must be able to tell "measured as neutral" from "not
// measurable". Off by default - a machine-readable order-shaped object should
// be something the user asks for, not something every user emits.
if fire_sig and i_json
    string _js = '{"ev":"PO3","sym":"' + syminfo.tickerid + '","tf":"' + timeframe.period + '","dir":' + str.tostring(_dir) + ',"seq":' + str.tostring(_seq) + ',"score":' + f_jnum(_score, 0) + ',"aq":' + f_jnum(_aq, 0) + ',"mq":' + f_jnum(_mq, 0) + ',"dq":' + f_jnum(_dq, 0) + ',"chain":' + f_jnum(_chainShow, 2) + ',"ctx":' + f_jnum(_ctxShow, 2) + ',"pool":"' + _poolName + '","poolsig":' + f_jnum(_poolSig, 2) + ',"depth":' + f_jnum(_depthShow, 2) + ',"accept":' + f_jnum(_acceptShow, 2) + ',"regime":"' + f_regVName(_regVf) + '/' + f_regSName(_regSf) + '","sess":"' + f_kzName(_sigSess) + '","entry":' + f_jnum(_entry, 2) + ',"sl":' + f_jnum(_sl, 2) + ',"tp":' + f_jnum(_tp, 2) + ',"rr":' + f_jnum(_rrMult, 2) + ',"ml":' + f_jnum(_knnAtSig, 2) + ',"libn":' + f_jnum(_libnAtSig, 0) + '}'
    alert(_js, alert.freq_once_per_bar_close)
````
