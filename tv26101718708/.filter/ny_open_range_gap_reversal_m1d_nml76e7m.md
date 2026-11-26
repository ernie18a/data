# NY Open Range Gap Reversal (M1D)

- url: https://www.tradingview.com/script/NML76e7m-NY-Open-Range-Gap-Reversal-M1D/
- type: indicator
- pine_id: PUB;c037d95e8fa346f59d29de29530e13b4
- version: 2.0

## Description

[b]M1D NY Open Range Gap Reversal[/b]

[b]OVERVIEW[/b]
A reference and marking tool for the New York Regular Trading Hours (RTH) opening gap. It maps the price and time levels of the classic open-gap "manipulation then reversal" sequence so a discretionary trader can read the session at a glance. It draws levels and flags conditions on closed bars — it does not place orders, produce buy/sell calls, or predict outcomes.

[b]THE IDEA[/b]
At the 09:30 ET cash open a gap frequently forms between the prior session's 16:15 ET RTH close and today's open. That gap often produces an early "judas swing": a first push off the open that raids liquidity, fails, and reverses back through the gap toward a gap-fill draw. This indicator frames that sequence with objective, repeatable levels and time windows so the read is consistent from day to day.

[b]WHAT IT DRAWS[/b]
- RTH Open (True Day Open) line, annotated with the day's gap size and direction.
- Opening-gap retracement levels at 25%, 50% (the primary draw, emphasised), 75%, and 100% (full fill = the prior RTH close).
- Shading of the 09:30-10:00 gap-fill window and a 10:00 checkpoint line.
- Opening Range high and low (first N minutes of RTH; default 30).
- Liquidity Sweep flag when the opening-range extreme is taken and price closes back inside (the manipulation leg).
- SMT divergence flag against two correlated index futures (default YM and ES), pivot-based. Each flag names which comparison index diverged (e.g. "SMT - YM"), so a one-sided divergence is distinguishable from both indices disagreeing.
- An info panel showing gap size, live gap-fill percentage, a countdown to the RTH close, the day's directional bias, and which SMT comparison symbols are in play.
- Right-margin labels that sit within a configurable ATR distance of each other are merged into one line of text instead of overlapping illegibly.

[b]HOW IT WORKS[/b]
Session handling uses the exchange clock in the America/New_York timezone, so it is daylight-saving safe with no fixed offset. The gap is measured from the prior RTH session's 16:15 ET futures close to the current 09:30 ET open; the electronic/Globex 17:00 ET close is intentionally not used. Directional bias is derived from gap direction: a gap up frames a bearish fade toward the fill, a gap down frames a bullish fade. The Sweep and SMT modules only evaluate on days whose gap is at or above a configurable minimum. The minimum can be expressed as a multiple of the previous day's ATR (the default, 0.15, so the threshold scales with each instrument's own volatility), as a percentage of price, or in raw points. Both modules arm only after the opening range locks (SMT pivot history is still tracked through the range, so the first pivot after the lock has a same-session reference; an input allows SMT inside the range). By default an SMT flag requires BOTH comparison symbols to fail to confirm the chart's pivot; an input relaxes this to either one. A comparison symbol that tracks the same index as the chart cannot diverge from it, so that leg is automatically excluded and the info panel reports which symbols remain active. Line and label activity (extension and new Sweep/SMT detection) stops at a configurable cutoff (default 11:30 ET) and resumes automatically at the next session's open; the info panel is unaffected and keeps updating through the close. All detection is evaluated on bar close (barstate.isconfirmed) to avoid repainting, and prior-day drawings are removed at the 16:15 ET boundary so nothing carries into the next session.

[b]HOW TO USE IT[/b]
Apply to CME equity-index futures (for example MNQ/NQ, MES/ES, MYM/YM) on an intraday execution timeframe such as 1-5 minute. Read the levels as context: the gap-fill levels are potential draws, the opening range and its sweep mark the manipulation leg, and the SMT flag marks a confirming (or diverging) move in the correlated indices. The trader decides where and how to act — the script does not mark an entry. Every module, colour, time window, label size, and the SMT symbol pair are adjustable in the settings.

[b]INPUTS[/b]
Grouped controls for session times, the gap minimum (ATR-relative, percent, or points) and which fib levels to show, opening-range length, timing references, and the Sweep / SMT modules (symbol pair, pivot length, both-or-either divergence, bias filter). Every drawn line and label has its own colour, line style, and label text, on top of global controls for the brand colours, line width, label size, right-margin offset, and info-table position.

[b]NOTES[/b]
- This is an indicator, not a strategy: it does not generate orders, alerts to enter, or performance results.
- It evaluates conditions on closed bars and does not repaint.
- Descriptions of how gaps have tended to behave are informational, not predictive.

[b]DISCLAIMER[/b]
This script is provided for educational and informational purposes only. It is not financial advice and is not a recommendation to buy or sell any instrument. Trading futures carries a substantial risk of loss. Past behaviour is not indicative of future results. You are solely responsible for your own trading decisions. Test thoroughly before relying on it in any live environment.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
//
// ─────────────────────────────────────────────────────────────────────────────
// M1D NY Open Range Gap Reversal
//
// MODEL
//   A NY RTH open reference tool built on price and time only. The 09:30 ET open
//   creates a manipulation-then-reversal sequence: a Judas swing runs off the open
//   to raid liquidity, fails, and price reverses back through the opening gap toward
//   the gap-fill draw. The tool marks the price-and-time references — opening gap
//   fibs, opening-range extremes, the liquidity sweep, and SMT divergence across the
//   equity indices — for the trader's own read. It does not mark an entry trigger,
//   execute, or auto-flip.
//
// SESSION (verified, hard-coded intent)
//   RTH futures session = 09:30–16:15 ET, timezone "America/New_York" (DST handled by the
//   exchange clock — no fixed offset). The gap uses the 16:15 ET futures RTH close, NOT the
//   17:00 ET Globex/ETH close and NOT the 18:00 ET reopen — the ETH boundary is
//   deliberately excluded. Gap endpoints are read from the chart's own bars via the ET
//   clock: today's RTH open = open of the first RTH bar; prior RTH close = close of the
//   last RTH bar of the previous session. This is DST-safe and independent of whether
//   the chart shows ETH or RTH-only bars.
//
// BIAS
//   Gap up  → bearish draw (fade down toward the gap fill).
//   Gap down → bullish draw (fade up toward the gap fill).
//
// DEFAULTS / FORKS (chosen and applied; adjustable via inputs)
//   • Minimum valid gap = 0.15 × the previous completed daily ATR. Below this the day is
//     marked inactive and the Sweep and SMT modules are suppressed. The threshold can also
//     be expressed in raw points or as a % of price, but ATR is the portable default: a
//     fixed point threshold is not comparable across instruments — 40 points is ~0.6% on ES
//     and ~0.08% on YM, so it would arm this tool nearly every day on YM and almost never
//     on ES. ATR-relative asks the same question of every symbol.
//   • SMT pair = CBOT_MINI:YM1! and CME_MINI:ES1!, pivot-based, barmerge.lookahead_off.
//     By default BOTH must fail to confirm the chart's pivot; a comparison symbol that
//     tracks the same index as the chart (ES1! on an ES chart, or a micro against its
//     full-size parent) is detected and dropped, since a series cannot diverge from itself.
//     The info table names the symbols actually in play so a dropped leg is never silent.
//   • Opening range = first 30 min (09:30–10:00), which coincides with the ~70%-fill
//     window; the 10:00 line marks that checkpoint.
//   • The judas sweep AND SMT are drawn only AFTER the opening range locks (default 10:00
//     ET), aligning with the NY AM Macro-1 (09:50–10:10) reversal window. Reversals that
//     complete inside the first 30 minutes are left to manual discretion. SMT pivot history
//     is still tracked through the range, so the first pivot after the lock already has a
//     same-session partner to compare against.
//   • Every drawn line/label has its own colour, line style, and label text input. The
//     RTH Open, OR Hi/Lo, and Gap-fib lines/labels project a fixed number of bars to the
//     right of price (default 10, adjustable — 0 pins them at the current bar).
//   • Info-table gap-fill % is clamped to the RTH-open→prior-close range (0–100%) — it
//     does not keep counting past the fill target if price overshoots it.
//   • Right-margin labels within 0.6 × ATR of each other merge into one line of text
//     (adjustable, 0 disables) so close-together levels never overlap into unreadable text.
//   • Info-table "To Close" countdown keys off the bar's own time_close, not the real-world
//     clock — barstate.isrealtime is also true on Bar Replay's simulated bar, so a
//     wall-clock "now" would silently track the local system clock instead of the
//     replayed/historical bar on screen. Correct in live trading, Replay, and static
//     historical review alike, at the cost of updating once per bar instead of every second.
//   • All line/label extension and new Sweep/SMT detection stop at 11:30 ET (adjustable) —
//     everything freezes in place for the rest of the session and resumes automatically
//     at the next day's RTH open. The info table is unaffected and keeps updating.
//
// All detection is gated on barstate.isconfirmed (bar close) — no repainting.
// Prior-day objects are deleted at the RTH close boundary; nothing bleeds into the next day.
// ─────────────────────────────────────────────────────────────────────────────
//@version=6
indicator("M1D NY Open Range Gap Reversal", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════
string GRP_SESS = "Session (America/New_York)"
string GRP_GAP  = "Opening Gap"
string GRP_OR   = "Opening Range"
string GRP_TIME = "Timing References"
string GRP_SWP  = "Judas / Liquidity Sweep"
string GRP_SMT  = "SMT Divergence"
string GRP_VIZ  = "Visuals — Global"

// ── Session / RTH Open ───────────────────────────────────────────────────────
int    rthOpenHHMM     = input.int(930,  "RTH Open (ET, HHMM)",  group = GRP_SESS, minval = 0, maxval = 2359, tooltip = "09:30 cash open. HHMM format.")
int    rthCloseHHMM    = input.int(1615, "RTH Close (ET, HHMM)", group = GRP_SESS, minval = 0, maxval = 2359, tooltip = "16:15 ET equity-index futures RTH close/settlement. Set 1600 for the cash close. The 17:00 ETH close is intentionally not used.")
bool   showRthOpen     = input.bool(true, "Show RTH Open Line", group = GRP_SESS)
string openLabelTxt    = input.string("RTH Open", "Open Line Label Text", group = GRP_SESS)
color  rthOpenColor    = input.color(color.black, "Open Line Colour", group = GRP_SESS)
string rthOpenStyleKey = input.string("Solid", "Open Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SESS)

// ── Opening gap ──────────────────────────────────────────────────────────────
string gapModeKey   = input.string("× Daily ATR", "Minimum Valid Gap — Measured In", options = ["× Daily ATR", "% of Price", "Points"], group = GRP_GAP, tooltip = "Below the resolved threshold the day is marked inactive and the reversal stack is suppressed. Raw points are not comparable across instruments — 40 points is ~0.6% on ES but ~0.08% on YM — so ATR-relative is the default. Only the field matching this mode is used.")
float  minGapAtr    = input.float(0.15, "    · × Daily ATR", group = GRP_GAP, minval = 0.0, step = 0.05, tooltip = "Multiple of the previous completed daily ATR(14). Falls back to the Points value if daily ATR is unavailable.")
float  minGapPct    = input.float(0.15, "    · % of Price",  group = GRP_GAP, minval = 0.0, step = 0.01, tooltip = "Percent of the RTH open price.")
float  minGapPoints = input.float(40.0, "    · Points",      group = GRP_GAP, minval = 0.0, step = 1.0,  tooltip = "Raw price units.")

bool   showGap25     = input.bool(true, "Show 25%", group = GRP_GAP)
string gap25Text     = input.string("Gap 25%", "25% Label Text", group = GRP_GAP)
color  gap25Color    = input.color(color.black, "25% Colour", group = GRP_GAP)
string gap25StyleKey = input.string("Dotted", "25% Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_GAP)

bool   showGap50      = input.bool(true, "Show 50% (primary draw)", group = GRP_GAP)
string gap50Text      = input.string("Gap 50% (primary draw)", "50% Label Text", group = GRP_GAP)
bool   gap50AutoColor = input.bool(true, "50% Auto-Colour by Bias", group = GRP_GAP, tooltip = "On = uses the Bullish/Bearish colours from Visuals — Global. Off = uses the custom colour below.")
color  gap50Color     = input.color(#7246CE, "50% Custom Colour (if auto off)", group = GRP_GAP)
string gap50StyleKey  = input.string("Solid", "50% Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_GAP, tooltip = "Solid emphasises it as the primary draw.")

bool   showGap75     = input.bool(true, "Show 75%", group = GRP_GAP)
string gap75Text     = input.string("Gap 75%", "75% Label Text", group = GRP_GAP)
color  gap75Color    = input.color(color.black, "75% Colour", group = GRP_GAP)
string gap75StyleKey = input.string("Dotted", "75% Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_GAP)

bool   showGap100     = input.bool(true, "Show 100% (full fill)", group = GRP_GAP)
string gap100Text     = input.string("Gap 100% (Full Fill)", "100% Label Text", group = GRP_GAP)
color  gap100Color    = input.color(color.black, "100% Colour", group = GRP_GAP)
string gap100StyleKey = input.string("Dotted", "100% Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_GAP)

// ── Opening range ────────────────────────────────────────────────────────────
int    orMinutes = input.int(30, "Opening Range (minutes)", group = GRP_OR, minval = 30, step = 5, tooltip = "First N minutes of RTH. Minimum 30. Default 30 coincides with the 09:30–10:00 fill window.")
bool   showOR    = input.bool(true, "Show Opening Range Hi/Lo", group = GRP_OR)

string orHighText     = input.string("OR High", "OR High Label Text", group = GRP_OR)
color  orHighColor    = input.color(color.black, "OR High Colour", group = GRP_OR)
string orHighStyleKey = input.string("Dotted", "OR High Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_OR)

string orLowText     = input.string("OR Low", "OR Low Label Text", group = GRP_OR)
color  orLowColor    = input.color(color.black, "OR Low Colour", group = GRP_OR)
string orLowStyleKey = input.string("Dotted", "OR Low Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_OR)

// ── Timing references ────────────────────────────────────────────────────────
bool   show10am      = input.bool(true, "Show 10:00 Fill-Window Line", group = GRP_TIME, tooltip = "Toggles the 10:00 checkpoint line/label off entirely.")
int    tenRefHHMM    = input.int(1000, "Fill-Window Checkpoint (ET, HHMM)", group = GRP_TIME)
string tenAmText     = input.string("10:00", "10:00 Line Label Text", group = GRP_TIME)
color  tenAmColor    = input.color(color.black, "10:00 Line Colour", group = GRP_TIME)
string tenAmStyleKey = input.string("Dotted", "10:00 Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_TIME)

bool   showFillBox      = input.bool(true, "Shade 09:30–Checkpoint Gap Window", group = GRP_TIME)
bool   fillBoxAutoColor = input.bool(true, "Fill Window Auto-Colour by Bias", group = GRP_TIME, tooltip = "On = uses the Bullish/Bearish colours from Visuals — Global. Off = uses the custom colour below.")
color  fillBoxColor     = input.color(#7246CE, "Fill Window Custom Colour (if auto off)", group = GRP_TIME)

int    stopHHMM = input.int(1130, "Stop All Drawing/Detection After (ET, HHMM)", group = GRP_TIME, minval = 0, maxval = 2359, tooltip = "Lines/labels stop extending and no new Sweep/SMT activity fires after this time — everything freezes for the rest of the session. Resumes automatically at the next day's RTH open. Set to the RTH close time to disable.")

// ── Judas / sweep ────────────────────────────────────────────────────────────
bool   showSweep     = input.bool(true, "Flag Liquidity Sweep (judas)", group = GRP_SWP)
string sweepText     = input.string("Sweep", "Sweep Label Text", group = GRP_SWP)
color  sweepColor    = input.color(color.black, "Sweep Colour", group = GRP_SWP)
string sweepStyleKey = input.string("Solid", "Sweep Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SWP)

// ── SMT divergence ───────────────────────────────────────────────────────────
bool   showSmt     = input.bool(true, "Flag SMT Divergence", group = GRP_SMT)
string smtSym1     = input.symbol("CBOT_MINI:YM1!", "SMT Symbol 1", group = GRP_SMT, tooltip = "YM (E-mini Dow) trades on CBOT, not CME_MINI.")
string smtSym2     = input.symbol("CME_MINI:ES1!", "SMT Symbol 2", group = GRP_SMT)
int    smtPivotLen = input.int(2, "SMT Pivot Length", group = GRP_SMT, minval = 1, maxval = 10, tooltip = "Left/right strength for pivots. 2 suits M1/M5 execution.")
bool   smtBothDir  = input.bool(false, "Show both directions (ignore bias)", group = GRP_SMT, tooltip = "Off = only the bias-aligned SMT (bearish on gap-up, bullish on gap-down).")
bool   smtBothSyms = input.bool(true, "Require BOTH symbols to diverge", group = GRP_SMT, tooltip = "On (AND) = both comparison symbols must fail to confirm the chart's pivot — far fewer, higher-quality flags. Off (OR) = either one is enough, which fires often at low pivot lengths. If only one symbol is usable, AND degrades to that symbol rather than going silent.")
bool   smtInOr     = input.bool(false, "Allow SMT inside the Opening Range", group = GRP_SMT, tooltip = "Off = SMT is only drawn once the Opening Range locks, matching the Sweep module and the model's rule that intra-range reversals are discretionary. Pivot history is tracked through the range either way, so the first pivot after the lock can diverge immediately.")
string smtText     = input.string("SMT", "SMT Label Text", group = GRP_SMT)
string smtStyleKey = input.string("Dotted", "SMT Line Style", options = ["Solid", "Dashed", "Dotted"], group = GRP_SMT, tooltip = "Colour follows the Bullish/Bearish colours in Visuals — Global.")

// ── Visuals — Global ─────────────────────────────────────────────────────────
color  bullCol       = input.color(#7246CE, "Bullish (brand)", group = GRP_VIZ, tooltip = "Used for bullish SMT, and any element with Auto-Colour by Bias on.")
color  bearCol       = input.color(#DB1D9C, "Bearish (brand)", group = GRP_VIZ, tooltip = "Used for bearish SMT, and any element with Auto-Colour by Bias on.")
int    liqWidth      = input.int(1, "Line Width (all lines)", group = GRP_VIZ, minval = 1, maxval = 4)
color  lblTextCol    = input.color(color.black, "Label Text Colour (all labels)", group = GRP_VIZ)
string lblSizeKey    = input.string("normal", "Label Size (all labels)", options = ["tiny", "small", "normal", "large"], group = GRP_VIZ)
int    lblOffsetBars = input.int(20, "Right Offset — Lines & Labels (bars)", group = GRP_VIZ, minval = 0, maxval = 200, tooltip = "How far past the current bar the RTH Open, OR Hi/Lo, and Gap-fib lines/labels project. 0 pins them at the current bar.")
float  lblMergeAtrMult = input.float(0.6, "Label Merge Threshold (× ATR)", group = GRP_VIZ, minval = 0.0, step = 0.1, tooltip = "Right-margin labels within this many ATRs of each other are combined into one line of text so they don't overlap into unreadable garbage. Same default as the Unicorn Model. 0 disables merging. Lines are left alone — only the text merges.")
bool   showTable     = input.bool(true, "Show Info Table", group = GRP_VIZ)
string tablePosKey   = input.string("top_right", "Info Table Position", options = ["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group = GRP_VIZ)

// ═════════════════════════════════════════════════════════════════════════════
// CONSTANTS / GLOBALS
// ═════════════════════════════════════════════════════════════════════════════
string TZ = "America/New_York"

//@function Converts an HHMM integer to minutes-since-midnight.
//@param hhmm (int) Time in HHMM form (e.g. 930 → 570).
//@returns (int) Minutes since midnight.
hhmmToMin(int hhmm) =>
    int(math.floor(hhmm / 100)) * 60 + hhmm % 100

int openMin      = hhmmToMin(rthOpenHHMM)
int closeMin     = hhmmToMin(rthCloseHHMM)
int tenMin       = hhmmToMin(tenRefHHMM)
int orEndMin     = openMin + orMinutes
int stopMin      = hhmmToMin(stopHHMM)

float atrBuf = ta.atr(14)

// Previous completed daily ATR — the instrument-relative yardstick for the gap threshold.
// The [1] offset keeps the figure fixed for the whole session instead of drifting intraday.
float dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_off)

//@function Strips any exchange prefix from a symbol input.
//@param sym (string) e.g. "CBOT_MINI:YM1!".
//@returns (string) e.g. "YM1!" — unchanged when no prefix is present.
stripExchange(string sym) =>
    int colon = str.pos(sym, ":")
    na(colon) ? sym : str.substring(sym, colon + 1)

//@function Normalises a ticker to the index family it tracks, so a micro, a cash index or
//          an ETF is recognised as the same market as its parent future.
//@param s (string) Ticker, e.g. "ES1!", "MNQ1!", "SPY".
//@returns (string) Family key — ES / NQ / YM / RTY — or the cleaned ticker if unrecognised.
indexFamily(string s) =>
    string t = str.replace_all(str.replace_all(str.upper(s), "1!", ""), "2!", "")
    switch t
        "MES"    => "ES"
        "SPX"    => "ES"
        "SP500"  => "ES"
        "SPX500" => "ES"
        "US500"  => "ES"
        "SPY"    => "ES"
        "MNQ"    => "NQ"
        "NDX"    => "NQ"
        "NAS100" => "NQ"
        "US100"  => "NQ"
        "QQQ"    => "NQ"
        "MYM"    => "YM"
        "DJI"    => "YM"
        "US30"   => "YM"
        "DIA"    => "YM"
        "M2K"    => "RTY"
        "RUT"    => "RTY"
        "US2000" => "RTY"
        "IWM"    => "RTY"
        =>          t

// Correlated-index data for SMT (confirmed, non-repainting).
[ym_h, ym_l] = request.security(smtSym1, timeframe.period, [high, low], lookahead = barmerge.lookahead_off)
[es_h, es_l] = request.security(smtSym2, timeframe.period, [high, low], lookahead = barmerge.lookahead_off)

// A comparison symbol that tracks the same index as the chart can never diverge from it:
// "the chart made a higher high" and "that symbol failed to make a higher high" are one
// series contradicting itself, so the leg is silently impossible rather than merely quiet.
// Detect it and drop the leg — the info table reports which symbols survived. Resolved from
// the input strings rather than the requested symbols, so it costs no extra security call
// and settles at compile time instead of waiting on data.
string famChart = indexFamily(syminfo.ticker)
string famSmt1  = indexFamily(stripExchange(smtSym1))
string famSmt2  = indexFamily(stripExchange(smtSym2))
bool   smt1Live = showSmt and famSmt1 != famChart
bool   smt2Live = showSmt and famSmt2 != famChart
int    smtLegs  = (smt1Live ? 1 : 0) + (smt2Live ? 1 : 0)

// Chart pivots for SMT (confirmed pivotLen bars back).
float pivH = ta.pivothigh(high, smtPivotLen, smtPivotLen)
float pivL = ta.pivotlow(low,  smtPivotLen, smtPivotLen)

// ═════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═════════════════════════════════════════════════════════════════════════════
//@function Resolves a size key to a Pine size constant.
//@param key (string) One of "tiny" / "small" / "normal" / "large".
//@returns (const) Pine size constant.
lblSize(string key) =>
    switch key
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        =>          size.small

//@function Resolves a style key to a Pine line style constant.
//@param key (string) One of "Solid" / "Dashed" / "Dotted".
//@returns (const) Pine line style constant.
lineStyle(string key) =>
    switch key
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_dotted

//@function Creates a line, registers it in a store, and returns it.
//@param store (array<line>) Store to register into for lifecycle cleanup.
//@param x1 (int) Left bar index.
//@param y1 (float) Left price.
//@param x2 (int) Right bar index.
//@param y2 (float) Right price.
//@param col (color) Line colour.
//@param stl (string) Line style constant.
//@param w (int) Line width.
//@returns (line) The created line.
mkLine(array<line> store, int x1, float y1, int x2, float y2, color col, string stl, int w) =>
    line ln = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, style = stl, width = w)
    store.push(ln)
    ln

//@function Creates a monospace text-only label, registers it, and returns it.
//@param store (array<label>) Store to register into for lifecycle cleanup.
//@param x (int) Bar index.
//@param y (float) Price.
//@param txt (string) Label text.
//@param col (color) Text colour.
//@param szKey (string) Size key.
//@returns (label) The created label.
mkLabel(array<label> store, int x, float y, string txt, color col, string szKey) =>
    label lbl = label.new(x, y, text = txt, style = label.style_none, textcolor = col, size = lblSize(szKey))
    label.set_text_font_family(lbl, font.family_monospace)
    store.push(lbl)
    lbl

//@function Creates a seamless faint box (border matches fill), registers it, returns it.
//@param store (array<box>) Store to register into for lifecycle cleanup.
//@param l (int) Left bar index.
//@param t (float) Top price.
//@param r (int) Right bar index.
//@param b (float) Bottom price.
//@param colFill (color) Fill and border colour (identical, per the visual standard).
//@returns (box) The created box.
mkBox(array<box> store, int l, float t, int r, float b, color colFill) =>
    box bx = box.new(l, t, r, b, border_color = colFill, border_width = 1, border_style = line.style_dotted, bgcolor = colFill)
    store.push(bx)
    bx

//@function Deletes and empties every object held in the three stores.
//@param ls (array<line>) Line store.
//@param lbs (array<label>) Label store.
//@param bxs (array<box>) Box store.
//@returns (bool) Always true.
clearStores(array<line> ls, array<label> lbs, array<box> bxs) =>
    while ls.size() > 0
        line.delete(ls.shift())
    while lbs.size() > 0
        label.delete(lbs.shift())
    while bxs.size() > 0
        box.delete(bxs.shift())
    true

//@function Maps a position key to a Pine table position constant.
//@param k (string) Position key.
//@returns (const) Table position.
tablePos(string k) =>
    switch k
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left"  => position.bottom_left
        "middle_right" => position.middle_right
        =>                position.top_right

//@function Zero-pads an int to at least two digits.
//@param v (int) Value.
//@returns (string) Padded string.
padZero(int v) =>
    v < 10 ? "0" + str.tostring(v) : str.tostring(v)

//@function Formats a millisecond duration as HH:MM:SS (CLOSED once elapsed).
//@param ms (int) Milliseconds remaining.
//@returns (string) Countdown string.
fmtCountdown(int ms) =>
    int totalSec = ms > 0 ? int(ms / 1000) : 0
    int hh = int(totalSec / 3600)
    int mm = int((totalSec % 3600) / 60)
    int ss = totalSec % 60
    ms <= 0 ? "CLOSED" : padZero(hh) + ":" + padZero(mm) + ":" + padZero(ss)

//@function Builds the gap-context suffix carried on the RTH Open label.
//@param valid (bool) Whether the gap cleared the minimum threshold.
//@param up (bool) Whether the gap is up (bearish draw).
//@param absPts (float) Absolute gap size in price units.
//@param sz (float) Signed gap size — na when there is no prior RTH close to measure from.
//@param thresh (float) The resolved minimum-gap threshold for the day.
//@returns (string) Suffix, or an empty string when no gap could be measured.
gapCtxStr(bool valid, bool up, float absPts, float sz, float thresh) =>
    valid ? " · Gap " + (up ? "+" : "-") + str.tostring(absPts, "#.#") + "pt " + (up ? "Bear" : "Bull") : (not na(sz) ? " · No Gap (<" + str.tostring(thresh, "#.#") + ")" : "")

//@function Names the comparison symbols that failed to confirm the chart's pivot, so an SMT
//          flag says which index actually diverged instead of leaving it to be guessed.
//@param f1 (bool) Whether comparison symbol 1 diverged.
//@param f2 (bool) Whether comparison symbol 2 diverged.
//@param n1 (string) Symbol 1 family name.
//@param n2 (string) Symbol 2 family name.
//@returns (string) e.g. " · YM", " · YM+ES" — empty when neither diverged.
smtWhoStr(bool f1, bool f2, string n1, string n2) =>
    f1 and f2 ? " · " + n1 + "+" + n2 : f1 ? " · " + n1 : f2 ? " · " + n2 : ""

// ═════════════════════════════════════════════════════════════════════════════
// STATE
// ═════════════════════════════════════════════════════════════════════════════
// Object stores (everything drawn is registered here and cleared at the day boundary).
var array<line>  lineStore  = array.new<line>(0)
var array<label> labelStore = array.new<label>(0)
var array<box>   boxStore   = array.new<box>(0)

// Named handles for the per-day reference objects that get extended intraday.
var line  rthOpenLine = na
var line  gap25Line   = na
var line  gap50Line   = na
var line  gap75Line   = na
var line  gap100Line  = na
var line  orHighLine  = na
var line  orLowLine   = na

// Named handles for the per-day level labels (repositioned to the right margin each bar).
var label rthOpenLbl = na
var label gap25Lbl   = na
var label gap50Lbl   = na
var label gap75Lbl   = na
var label gap100Lbl  = na
var label orHighLbl  = na
var label orLowLbl   = na

// Session / gap state.
var int    lastRthDate     = na
var float  lastRthClose    = na
var int    rthOpenBarIdx    = na
var float  dayOpen         = na
var float  prevClose       = na
var float  gapSize         = na
var float  gapAbs          = na
var float  gapThresh       = na
var float  fill25          = na
var float  fill50          = na
var float  fill75          = na
var float  fill100         = na
var bool   gapUp           = false
var bool   gapValid        = false
var bool   gapActive       = false
var bool   gap50Filled     = false
var bool   gap100Filled    = false
var string bias            = "Neutral"
var bool   wasInRth        = false

// Running day / opening-range state.
var float  dayHigh   = na
var float  dayLow    = na
var float  orHigh    = na
var float  orLow     = na
var int    orHighBar = na
var int    orLowBar  = na
var bool   orLocked  = false
var bool   tenDone   = false

// Sweep state.
var bool   sweptHigh = false
var bool   sweptLow  = false

// SMT pivot snapshots (session-scoped).
var float  chPrevPH = na
var float  chPrevPL = na
var int    chPrevPHBar = na
var int    chPrevPLBar = na
var float  ymPrevPH = na
var float  ymPrevPL = na
var float  esPrevPH = na
var float  esPrevPL = na

// Per-bar alert signals (script scope for alertcondition).
bool sigValidGap = false
bool sigSweep    = false
bool sigSmt      = false
bool sigGap50    = false

// ═════════════════════════════════════════════════════════════════════════════
// MAIN — all detection gated on bar close (anti-repaint)
// ═════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed
    int etTod  = hour(time, TZ) * 60 + minute(time, TZ)
    int etDate = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
    bool inRth = etTod >= openMin and etTod < closeMin

    bool isRthOpenBar = inRth and (na(lastRthDate) or etDate != lastRthDate)
    bool rthJustEnded = (not inRth) and wasInRth
    bool doReset = isRthOpenBar or rthJustEnded

    color biasColVal = bias == "Bearish" ? bearCol : bullCol

    // ── Day boundary: clear all objects, drop named handles ──────────────────
    if doReset
        clearStores(lineStore, labelStore, boxStore)
        rthOpenLine := na
        gap25Line   := na
        gap50Line   := na
        gap75Line   := na
        gap100Line  := na
        orHighLine  := na
        orLowLine   := na
        rthOpenLbl  := na
        gap25Lbl    := na
        gap50Lbl    := na
        gap75Lbl    := na
        gap100Lbl   := na
        orHighLbl   := na
        orLowLbl    := na
        gapActive   := false

    // ── New RTH day: compute the gap and draw its references ──────────────────
    if isRthOpenBar
        lastRthDate  := etDate
        rthOpenBarIdx := bar_index
        dayOpen      := open
        prevClose    := lastRthClose
        bool hasGap  = not na(prevClose)
        gapSize      := hasGap ? dayOpen - prevClose : na
        gapAbs       := hasGap ? math.abs(gapSize) : na
        gapUp        := hasGap and gapSize > 0
        // Resolve the minimum-gap threshold into price units for this instrument and day.
        gapThresh    := gapModeKey == "Points" ? minGapPoints : (gapModeKey == "% of Price" ? dayOpen * minGapPct / 100.0 : (na(dailyAtr) ? minGapPoints : dailyAtr * minGapAtr))
        gapValid     := hasGap and gapAbs >= gapThresh
        gapActive    := gapValid
        bias         := not hasGap ? "Neutral" : (gapSize > 0 ? "Bearish" : "Bullish")
        biasColVal   := bias == "Bearish" ? bearCol : bullCol

        // Reset per-day trackers.
        dayHigh := high
        dayLow  := low
        orHigh  := high
        orLow   := low
        orHighBar := bar_index
        orLowBar  := bar_index
        orLocked  := false
        tenDone   := false
        sweptHigh := false
        sweptLow  := false
        gap50Filled  := false
        gap100Filled := false
        chPrevPH := na
        chPrevPL := na
        chPrevPHBar := na
        chPrevPLBar := na
        ymPrevPH := na
        ymPrevPL := na
        esPrevPH := na
        esPrevPL := na

        // Gap context folded into the RTH Open label so it stays readable at the right margin.
        string gapCtx = gapCtxStr(gapValid, gapUp, gapAbs, gapSize, gapThresh)

        // RTH Open line.
        if showRthOpen
            rthOpenLine := mkLine(lineStore, bar_index, dayOpen, bar_index, dayOpen, rthOpenColor, lineStyle(rthOpenStyleKey), liqWidth)
            rthOpenLbl  := mkLabel(labelStore, bar_index, dayOpen, openLabelTxt + gapCtx, lblTextCol, lblSizeKey)

        // Gap fibs (25 / 50 / 75 / 100).
        if gapValid
            fill25  := dayOpen - gapSize * 0.25
            fill50  := dayOpen - gapSize * 0.50
            fill75  := dayOpen - gapSize * 0.75
            fill100 := prevClose
            color gap50ColorVal = gap50AutoColor ? biasColVal : gap50Color
            if showGap25
                gap25Line := mkLine(lineStore, bar_index, fill25, bar_index, fill25, gap25Color, lineStyle(gap25StyleKey), liqWidth)
                gap25Lbl  := mkLabel(labelStore, bar_index, fill25, gap25Text, lblTextCol, lblSizeKey)
            if showGap50
                gap50Line := mkLine(lineStore, bar_index, fill50, bar_index, fill50, gap50ColorVal, lineStyle(gap50StyleKey), liqWidth)
                gap50Lbl  := mkLabel(labelStore, bar_index, fill50, gap50Text, lblTextCol, lblSizeKey)
            if showGap75
                gap75Line := mkLine(lineStore, bar_index, fill75, bar_index, fill75, gap75Color, lineStyle(gap75StyleKey), liqWidth)
                gap75Lbl  := mkLabel(labelStore, bar_index, fill75, gap75Text, lblTextCol, lblSizeKey)
            if showGap100
                gap100Line := mkLine(lineStore, bar_index, fill100, bar_index, fill100, gap100Color, lineStyle(gap100StyleKey), liqWidth)
                gap100Lbl  := mkLabel(labelStore, bar_index, fill100, gap100Text, lblTextCol, lblSizeKey)
            sigValidGap := true

    // ── Running day / opening-range extremes ─────────────────────────────────
    if inRth and not isRthOpenBar
        dayHigh := math.max(dayHigh, high)
        dayLow  := math.min(dayLow, low)

    if inRth and not orLocked
        if etTod < orEndMin
            if high > orHigh
                orHigh := high
                orHighBar := bar_index
            if low < orLow
                orLow := low
                orLowBar := bar_index
        if etTod >= orEndMin
            orLocked := true
            if showOR
                orHighLine := mkLine(lineStore, orHighBar, orHigh, bar_index, orHigh, orHighColor, lineStyle(orHighStyleKey), liqWidth)
                orHighLbl  := mkLabel(labelStore, bar_index, orHigh, orHighText, lblTextCol, lblSizeKey)
                orLowLine  := mkLine(lineStore, orLowBar, orLow, bar_index, orLow, orLowColor, lineStyle(orLowStyleKey), liqWidth)
                orLowLbl   := mkLabel(labelStore, bar_index, orLow, orLowText, lblTextCol, lblSizeKey)

    // ── 10:00 checkpoint line + gap-window shade ─────────────────────────────
    if inRth and not tenDone and etTod >= tenMin
        tenDone := true
        if show10am
            mkLine(lineStore, bar_index, dayLow - atrBuf, bar_index, dayHigh + atrBuf, tenAmColor, lineStyle(tenAmStyleKey), liqWidth)
            mkLabel(labelStore, bar_index, dayHigh + atrBuf, tenAmText, lblTextCol, "small")
        if showFillBox and gapValid and not na(rthOpenBarIdx)
            float wTop = math.max(dayOpen, prevClose)
            float wBot = math.min(dayOpen, prevClose)
            color fillBoxColorVal = fillBoxAutoColor ? biasColVal : fillBoxColor
            mkBox(boxStore, rthOpenBarIdx, wTop, bar_index, wBot, color.new(fillBoxColorVal, 92))

    // ── Judas / liquidity sweep (reversal stack, after OR locks) ──────────────
    // Detected only in the gap-fade direction: gap-up fades a buyside sweep, gap-down a sellside sweep.
    if showSweep and gapValid and inRth and orLocked and etTod < stopMin
        if bias == "Bearish" and not sweptHigh and high > orHigh and close < orHigh
            sweptHigh := true
            mkLine(lineStore, bar_index, high, bar_index + 20, high, sweepColor, lineStyle(sweepStyleKey), liqWidth)
            mkLabel(labelStore, bar_index, high, sweepText, lblTextCol, lblSizeKey)
            sigSweep := true
        if bias == "Bullish" and not sweptLow and low < orLow and close > orLow
            sweptLow := true
            mkLine(lineStore, bar_index, low, bar_index + 20, low, sweepColor, lineStyle(sweepStyleKey), liqWidth)
            mkLabel(labelStore, bar_index, low, sweepText, lblTextCol, lblSizeKey)
            sigSweep := true

    // ── SMT divergence (confirmation) ────────────────────────────────────────
    // Bearish SMT on a chart higher-high that the comparison indices fail to confirm;
    // bullish mirrors on lows.
    //
    // Three gates shape what actually prints:
    //   1. A pivot resolves smtPivotLen bars behind the bar that confirms it, so pivots
    //      landing before the RTH open are discarded outright — their anchor would sit in
    //      pre-market or, on an RTH-only chart, in yesterday's session, drawing an SMT line
    //      back across the session break.
    //   2. Only legs whose symbol tracks a different index than the chart can diverge, and
    //      only legs with data on both pivot bars are counted. With two usable legs the
    //      AND/OR choice applies; with one it falls through to that leg rather than going
    //      silent; with none nothing prints.
    //   3. Pivot history is tracked from the open, but nothing is drawn until the Opening
    //      Range locks (unless overridden) — so the first pivot after the lock already has
    //      a same-session partner to compare against.
    if showSmt and gapValid and inRth and etTod < stopMin
        bool smtDrawOk = orLocked or smtInOr
        if not na(pivH)
            int curBar = bar_index - smtPivotLen
            if not na(rthOpenBarIdx) and curBar >= rthOpenBarIdx
                float chH = pivH
                float ymH = ym_h[smtPivotLen]
                float esH = es_h[smtPivotLen]
                if not na(chPrevPH) and smtDrawOk
                    bool chHigher   = chH > chPrevPH
                    bool leg1Usable = smt1Live and not na(ymH) and not na(ymPrevPH)
                    bool leg2Usable = smt2Live and not na(esH) and not na(esPrevPH)
                    bool leg1Fails  = leg1Usable and ymH < ymPrevPH
                    bool leg2Fails  = leg2Usable and esH < esPrevPH
                    int  usableLegs = (leg1Usable ? 1 : 0) + (leg2Usable ? 1 : 0)
                    bool diverged   = usableLegs == 0 ? false : ((smtBothSyms and usableLegs == 2) ? (leg1Fails and leg2Fails) : (leg1Fails or leg2Fails))
                    if chHigher and diverged and (smtBothDir or bias == "Bearish")
                        mkLine(lineStore, chPrevPHBar, chPrevPH, curBar, chH, bearCol, lineStyle(smtStyleKey), liqWidth)
                        int smtMidH = int(math.round((chPrevPHBar + curBar) / 2.0))
                        mkLabel(labelStore, smtMidH, math.max(chPrevPH, chH) + atrBuf * 0.5, smtText + smtWhoStr(leg1Fails, leg2Fails, famSmt1, famSmt2), lblTextCol, lblSizeKey)
                        sigSmt := true
                chPrevPH    := chH
                chPrevPHBar := curBar
                ymPrevPH    := ymH
                esPrevPH    := esH
        if not na(pivL)
            int curBar = bar_index - smtPivotLen
            if not na(rthOpenBarIdx) and curBar >= rthOpenBarIdx
                float chL = pivL
                float ymL = ym_l[smtPivotLen]
                float esL = es_l[smtPivotLen]
                if not na(chPrevPL) and smtDrawOk
                    bool chLower    = chL < chPrevPL
                    bool leg1Usable = smt1Live and not na(ymL) and not na(ymPrevPL)
                    bool leg2Usable = smt2Live and not na(esL) and not na(esPrevPL)
                    bool leg1Fails  = leg1Usable and ymL > ymPrevPL
                    bool leg2Fails  = leg2Usable and esL > esPrevPL
                    int  usableLegs = (leg1Usable ? 1 : 0) + (leg2Usable ? 1 : 0)
                    bool diverged   = usableLegs == 0 ? false : ((smtBothSyms and usableLegs == 2) ? (leg1Fails and leg2Fails) : (leg1Fails or leg2Fails))
                    if chLower and diverged and (smtBothDir or bias == "Bullish")
                        mkLine(lineStore, chPrevPLBar, chPrevPL, curBar, chL, bullCol, lineStyle(smtStyleKey), liqWidth)
                        int smtMidL = int(math.round((chPrevPLBar + curBar) / 2.0))
                        mkLabel(labelStore, smtMidL, math.min(chPrevPL, chL) - atrBuf * 0.5, smtText + smtWhoStr(leg1Fails, leg2Fails, famSmt1, famSmt2), lblTextCol, lblSizeKey)
                        sigSmt := true
                chPrevPL    := chL
                chPrevPLBar := curBar
                ymPrevPL    := ymL
                esPrevPL    := esL

    // ── Gap-fill progress ────────────────────────────────────────────────────
    if inRth and gapValid and not gap50Filled
        bool hit50 = gapUp ? low <= fill50 : high >= fill50
        if hit50
            gap50Filled := true
            sigGap50 := true
    if inRth and gapValid and gapActive and not gap100Filled
        bool hit100 = gapUp ? low <= fill100 : high >= fill100
        if hit100
            gap100Filled := true
            gapActive := false        // full mitigation — freeze the gap references

    // ── Extend live references + offset lines & labels into the right margin ───
    // Stops at stopMin (default 11:30 ET) — everything freezes in place for the rest of
    // the session and resumes automatically at the next day's RTH open.
    if inRth and etTod < stopMin
        int extX = bar_index + lblOffsetBars
        if not na(rthOpenLine)
            line.set_x2(rthOpenLine, extX)
        if not na(rthOpenLbl)
            label.set_x(rthOpenLbl, extX)
        if not na(orHighLine)
            line.set_x2(orHighLine, extX)
        if not na(orHighLbl)
            label.set_x(orHighLbl, extX)
        if not na(orLowLine)
            line.set_x2(orLowLine, extX)
        if not na(orLowLbl)
            label.set_x(orLowLbl, extX)
        if gapActive
            if not na(gap25Line)
                line.set_x2(gap25Line, extX)
            if not na(gap25Lbl)
                label.set_x(gap25Lbl, extX)
            if not na(gap50Line)
                line.set_x2(gap50Line, extX)
            if not na(gap50Lbl)
                label.set_x(gap50Lbl, extX)
            if not na(gap75Line)
                line.set_x2(gap75Line, extX)
            if not na(gap75Lbl)
                label.set_x(gap75Lbl, extX)
            if not na(gap100Line)
                line.set_x2(gap100Line, extX)
            if not na(gap100Lbl)
                label.set_x(gap100Lbl, extX)

    // ── Merge colliding label TEXT so close-together levels don't overlap ──────
    // Same technique as the Unicorn Model's refreshLiqLabels(): unsorted pairwise scan
    // with a used[] flag array and a plain math.abs() distance check — no need to sort.
    // Lines are left alone (harmless to overlap); only text is combined. Each label's
    // "own" text is recomputed fresh every bar (Pine has no label.get_text()). Absorbed
    // labels are hidden via fully-transparent textcolor (matching Unicorn), not blanked —
    // every candidate's colour is explicitly set every bar, so a label that stops
    // colliding (e.g. once OR High/Low join the pool at the lock) is restored cleanly.
    // Also stops at stopMin, matching the extend block above.
    if inRth and etTod < stopMin
        string gapCtxNow = gapCtxStr(gapValid, gapUp, gapAbs, gapSize, gapThresh)

        var array<float>  lvlPrice = array.new<float>()
        var array<string> lvlText  = array.new<string>()
        var array<label>  lvlLbl   = array.new<label>()
        lvlPrice.clear()
        lvlText.clear()
        lvlLbl.clear()

        if not na(rthOpenLbl)
            lvlPrice.push(dayOpen)
            lvlText.push(openLabelTxt + gapCtxNow)
            lvlLbl.push(rthOpenLbl)
        if gapActive and not na(gap25Lbl)
            lvlPrice.push(fill25)
            lvlText.push(gap25Text)
            lvlLbl.push(gap25Lbl)
        if gapActive and not na(gap50Lbl)
            lvlPrice.push(fill50)
            lvlText.push(gap50Text)
            lvlLbl.push(gap50Lbl)
        if gapActive and not na(gap75Lbl)
            lvlPrice.push(fill75)
            lvlText.push(gap75Text)
            lvlLbl.push(gap75Lbl)
        if gapActive and not na(gap100Lbl)
            lvlPrice.push(fill100)
            lvlText.push(gap100Text)
            lvlLbl.push(gap100Lbl)
        if not na(orHighLbl)
            lvlPrice.push(orHigh)
            lvlText.push(orHighText)
            lvlLbl.push(orHighLbl)
        if not na(orLowLbl)
            lvlPrice.push(orLow)
            lvlText.push(orLowText)
            lvlLbl.push(orLowLbl)

        int m = lvlPrice.size()
        if m > 0
            float mergeTol = atrBuf * lblMergeAtrMult
            array<bool> used = array.new<bool>(m, false)
            for i = 0 to m - 1
                if not used.get(i)
                    used.set(i, true)
                    string combined = lvlText.get(i)
                    if i < m - 1
                        for j = i + 1 to m - 1
                            if not used.get(j) and math.abs(lvlPrice.get(j) - lvlPrice.get(i)) <= mergeTol
                                used.set(j, true)
                                combined := combined + " + " + lvlText.get(j)
                                label.set_textcolor(lvlLbl.get(j), color.new(lblTextCol, 100))
                    label.set_text(lvlLbl.get(i), combined)
                    label.set_textcolor(lvlLbl.get(i), lblTextCol)

    // ── Book-keeping for next bar ────────────────────────────────────────────
    if inRth
        lastRthClose := close
    wasInRth := inRth

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS (script scope)
// ═════════════════════════════════════════════════════════════════════════════
alertcondition(sigValidGap, "Valid Gap (>= min)", "M1D: Valid opening gap on {{ticker}} — reversal stack armed")
alertcondition(sigSweep,    "Liquidity Sweep",    "M1D: Judas liquidity sweep on {{ticker}}")
alertcondition(sigSmt,      "SMT Divergence",     "M1D: SMT divergence on {{ticker}}")
alertcondition(sigGap50,    "Gap 50% Filled",     "M1D: Gap 50% (primary draw) reached on {{ticker}}")

// ═════════════════════════════════════════════════════════════════════════════
// INFO TABLE — M1D branding, live gap-fill %, RTH-close countdown
// ═════════════════════════════════════════════════════════════════════════════
var table infoTable = na
if barstate.islast and showTable
    if na(infoTable)
        infoTable := table.new(tablePos(tablePosKey), 2, 6, frame_color = #7246CE, frame_width = 1, border_color = color.new(#7246CE, 40), border_width = 1)

    // Live gap-fill % — max extent reached this session, including the forming bar.
    float liveHi = math.max(nz(dayHigh, high), high)
    float liveLo = math.min(nz(dayLow, low), low)
    float fillFrac = gapValid ? math.min(1.0, math.max(0.0, gapUp ? (dayOpen - liveLo) / gapSize : (dayOpen - liveHi) / gapSize)) : na
    string fillStr = na(fillFrac) ? "—" : str.tostring(int(math.round(fillFrac * 100))) + "%"
    // A rejected day reports the threshold it failed to clear, so "no gap" is never a
    // mystery — it names the bar the day had to beat.
    string gapStr  = gapValid ? (gapUp ? "+" : "-") + str.tostring(gapAbs, "#.#") + " " + (gapUp ? "Bear" : "Bull") : (not na(gapSize) ? "< " + str.tostring(gapThresh, "#.#") + " min" : "—")

    // Which SMT comparison symbols actually survived the self-comparison check, and on what
    // terms. A dropped leg has to be visible or it reads as a working two-symbol check. The
    // connector carries the AND/OR mode — "YM & ES" needs both to diverge, "YM or ES" either.
    string smtStat = not showSmt ? "Off" : smtLegs == 0 ? "none · both match chart" : smtLegs == 1 ? (smt1Live ? famSmt1 : famSmt2) + " only" : famSmt1 + (smtBothSyms ? " & " : " or ") + famSmt2

    // "Now" for the countdowns: always the current bar's own close time — NOT timenow.
    // barstate.isrealtime is ALSO true on Bar Replay's simulated "live" bar (by platform
    // design, so scripts behave as they would live), so a wall-clock "now" silently tracks
    // the local system clock during replay instead of the replayed bar on screen — completely
    // disconnected from what's displayed. time_close stays correct in live trading, Replay,
    // and static historical review alike, at the cost of updating once per bar instead of
    // ticking every second.
    int nowRef = time_close

    // Countdown to the RTH close.
    int rthCloseTs = timestamp(TZ, year(nowRef, TZ), month(nowRef, TZ), dayofmonth(nowRef, TZ), int(closeMin / 60), closeMin % 60, 0)
    string cdStr = fmtCountdown(rthCloseTs - nowRef)

    color hdrBg = #7246CE
    color valBg = color.new(color.white, 0)
    color keyBg = color.new(#7246CE, 92)
    color biasC = bias == "Bearish" ? bearCol : bias == "Bullish" ? bullCol : color.gray
    color smtC  = not showSmt ? color.gray : smtLegs == 0 ? bearCol : color.black

    table.cell(infoTable, 0, 0, "M1D",         bgcolor = hdrBg, text_color = color.white, text_size = size.normal)
    table.cell(infoTable, 1, 0, "NY OPEN GAP", bgcolor = hdrBg, text_color = color.white, text_size = size.small)
    table.cell(infoTable, 0, 1, "Gap",      bgcolor = keyBg, text_color = color.black, text_size = size.small)
    table.cell(infoTable, 1, 1, gapStr,     bgcolor = valBg, text_color = biasC,       text_size = size.small)
    table.cell(infoTable, 0, 2, "Filled",   bgcolor = keyBg, text_color = color.black, text_size = size.small)
    table.cell(infoTable, 1, 2, fillStr,    bgcolor = valBg, text_color = color.black, text_size = size.normal)
    table.cell(infoTable, 0, 3, "To Close", bgcolor = keyBg, text_color = color.black, text_size = size.small)
    table.cell(infoTable, 1, 3, cdStr,      bgcolor = valBg, text_color = color.black, text_size = size.normal)
    table.cell(infoTable, 0, 4, "Bias",     bgcolor = keyBg, text_color = color.black, text_size = size.small)
    table.cell(infoTable, 1, 4, bias,       bgcolor = valBg, text_color = biasC,       text_size = size.small)
    table.cell(infoTable, 0, 5, "SMT",      bgcolor = keyBg, text_color = color.black, text_size = size.small)
    table.cell(infoTable, 1, 5, smtStat,    bgcolor = valBg, text_color = smtC,        text_size = size.small)
````
