# Smart Money Concept [martineye15]

- url: https://www.tradingview.com/script/4U8Xgv0C-Smart-Money-Concept-martineye15/
- type: indicator
- pine_id: PUB;9b36e4586c314c359e0caa7d98d5de78
- version: 1.0

## Description

Smart Money Concepts Toolkit — an all-in-one Smart Money / ICT overlay that auto-detects and draws the core concepts on any symbol and timeframe, then ties them together with a multi-factor confluence filter and a built-in risk:reward trade planner.

WHAT IT DRAWS
- Market structure: swing pivots labelled HH / HL / LH / LL, with Break of Structure (BOS, continuation) and Change of Character (CHoCH, first counter-trend break) and a persistent trend state. An optional faster "internal" structure stream can run alongside the major one.
- Liquidity: Equal Highs / Lows (EQH / EQL) detected within an ATR-based tolerance, plus liquidity sweeps / stop hunts (a wick beyond a prior swing that closes back inside).
- Order blocks: the last opposite-colour candle before a structural break, extended until mitigated. Choose Touch or Close mitigation, wick or body range, swing or internal origin, and optional breaker blocks.
- Fair value gaps: 3-candle imbalances, extended until filled, with Touch or Close fill logic and an option to keep only unfilled gaps.
- Premium / discount: dynamic zones from the current dealing range with a 50% equilibrium line and an optional OTE band (0.62-0.79).
- Sessions / kill zones: optional Asia / London / New York shading with a configurable timezone and session times.

CONFLUENCE ENGINE (optional)
A discreet long/short marker that prints only when the factors YOU enable all agree - any combination of: price in discount/premium, a BOS/CHoCH in the trade direction, an unmitigated order block, an unfilled FVG, an opposing liquidity sweep, and higher-timeframe bias alignment via an HTF EMA. A recency window controls how fresh an event must be to still count. Signals evaluate on bar close and only on the first bar the conditions are met, so they do not spam or flip intrabar.

TRADE SETUP (Risk:Reward)
When enabled, each confluence signal draws a full plan: an entry (market at the signal close, or a limit at the order-block midpoint), a stop anchored to the order block / swing point / ATR that would invalidate the idea (plus an ATR buffer), and TP1 to TP4 placed at your chosen R multiples. Levels project forward and the lines are draggable, so you can fine-tune the plan by hand.

ALERTS
Ready-made alerts for BOS, CHoCH, new bullish/bearish order block, new bullish/bearish FVG, liquidity sweep, and confluence long/short.

HOW TO USE
Add it to a standard candlestick chart. Read the market with structure, liquidity and premium/discount; use order blocks and fair value gaps as areas of interest; then, if you want a filter, enable the confluence engine and turn on only the factors that fit your approach. Enable the trade setup to auto-draw a structure-anchored R:R plan on each signal, and set alerts on the events you care about. Every module toggles independently, so you can keep the chart as clean or as detailed as you like.

WHAT MAKES IT DIFFERENT
Instead of isolating a single SMC concept, it unifies structure, liquidity, order blocks, FVGs, premium/discount and session timing, and adds two things on top: a configurable confluence filter that only signals when multiple user-chosen factors align, and an integrated R:R planner that anchors the stop to the actual level that invalidates the trade and projects targets by R multiple.

REPAINTING & LIMITATIONS
All structural logic is based on confirmed pivots and closed candles; fair value gaps are committed only on a confirmed bar; the higher-timeframe bias uses the previous closed HTF bar. Pivots appear after their lookback (the normal pivot lag), which is not repainting. Live drawings such as order blocks and premium/discount zones update as the current, unclosed bar develops and as new pivots confirm; this is expected behaviour, not a change to confirmed history.

This is a visual, decision-support tool. It is not a strategy, it produces no orders or performance statistics, and it is not financial advice.

## Source Code

````pine
//@version=6
// ============================================================================
//  Smart Money Concepts (SMC)
//  ------------------------------------------------------------------------
//  Visual decision-support tool that auto-detects and draws the core
//  Smart Money / ICT concepts on any symbol and timeframe.
//
//    - Market structure : swing pivots labelled HH / HL / LH / LL, Break of
//                         Structure (BOS) and Change of Character (CHoCH),
//                         with a persistent internal trend state. A faster
//                         "internal" structure stream can be shown alongside.
//    - Liquidity        : Equal Highs / Lows (EQH / EQL) and liquidity sweeps
//                         / stop hunts (wick beyond a level, close back inside).
//    - Order Blocks     : last opposite-colour candle before a structural
//                         break, extended until mitigated; optional breakers.
//    - Fair Value Gaps  : 3-candle imbalances (FVG), extended until filled.
//    - Premium/Discount : dealing-range zones with 50% equilibrium and an
//                         optional OTE band (0.62-0.79).
//    - Sessions         : optional Asia / London / New York kill zones.
//    - Confluence       : optional discreet long/short marker that only prints
//                         when several SMC factors agree (each factor toggleable).
//
//  LEGEND
//    HH/HL/LH/LL  higher-high / higher-low / lower-high / lower-low pivots
//    BOS          break of structure (trend continuation)  -> solid line
//    CHoCH        change of character (first counter-trend break) -> dashed
//    BSL / SSL    buy-side / sell-side liquidity = the swing highs / lows
//    EQH / EQL    equal highs / equal lows (resting liquidity pools)
//    SWEEP        liquidity grab: wick beyond a level, close back inside
//    OB / BB      order block (demand=bull, supply=bear) / breaker block
//    FVG          fair value gap / imbalance
//    PREM / DISC  premium (favour shorts) / discount (favour longs)
//
//  NON-REPAINTING: all structural logic is based on CONFIRMED pivots and
//  CLOSED candles; FVGs are only committed on a confirmed bar and the HTF
//  bias uses the previous closed HTF bar. Pivots simply confirm after their
//  lookback (normal pivot lag) - that is not repainting.
//
//  This is a visual / decision-support tool, NOT financial advice.
// ============================================================================

indicator("Smart Money Concepts Toolkit: Structure, Liquidity, OB, FVG & R:R", shorttitle = "SMC", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)
// ============================================================================
//  INPUTS
// ============================================================================
g_ms    = "Market Structure"
g_ob    = "Order Blocks"
g_fvg   = "Fair Value Gaps"
g_liq   = "Liquidity"
g_pd    = "Premium / Discount"
g_sess  = "Sessions / Kill Zones"
g_conf  = "Confluence Signals"
g_trade = "Trade Setup (Risk:Reward)"
g_style = "Style & Colors"

// --- Market Structure ---
showSwing       = input.bool(true,  "Show swing structure (HH/HL/LH/LL)", group = g_ms, tooltip = "Major structure from the larger pivot lookback.")
swingLen        = input.int(25, "Swing pivot lookback", minval = 2, group = g_ms, tooltip = "Bars on each side of a swing pivot. Larger = fewer, more significant swings.")
showInternal    = input.bool(true,  "Show internal structure (BOS/CHoCH)", group = g_ms, tooltip = "Faster structure from the smaller pivot lookback (drawn lighter).")
internalLen     = input.int(5,  "Internal pivot lookback", minval = 1, group = g_ms, tooltip = "Bars on each side of an internal pivot.")
showInternalLbl = input.bool(false, "Label internal swing points", group = g_ms, tooltip = "Also tag internal pivots as HH/HL/LH/LL. Can get busy on low timeframes.")
showStructLines = input.bool(true,  "Show BOS / CHoCH lines & labels", group = g_ms)
maxStruct       = input.int(8,  "Max structure lines kept (per stream)", minval = 1, maxval = 100, group = g_ms, tooltip = "Older BOS/CHoCH lines are pruned beyond this many, per structure stream.")

// --- Order Blocks ---
showOB        = input.bool(true,    "Show order blocks", group = g_ob)
obSource      = input.string("Swing", "Form OBs from", options = ["Swing", "Internal"], group = g_ob, tooltip = "Which structural break creates an order block.")
obMode        = input.string("Wick",  "Order block range", options = ["Wick", "Body"], group = g_ob, tooltip = "Use the full candle high-low (Wick) or only the open-close body.")
maxOB         = input.int(5,        "Max order blocks shown", minval = 1, maxval = 50, group = g_ob)
obMitigation  = input.string("Touch", "Mitigation trigger", options = ["Touch", "Close"], group = g_ob, tooltip = "Touch = price wicks into the block. Close = a candle closes inside/through it.")
obHideMit     = input.bool(false,   "Hide mitigated blocks", group = g_ob, tooltip = "Off = mitigated blocks fade and stop extending; On = they are removed.")
obBreakers    = input.bool(false,   "Show breaker blocks", group = g_ob, tooltip = "When an OB is closed fully through, flip its polarity into a breaker block.")
obShowLabel   = input.bool(true,    "Label order blocks", group = g_ob)

// --- Fair Value Gaps ---
showFVG      = input.bool(true,     "Show fair value gaps", group = g_fvg)
maxFVG       = input.int(5,         "Max FVGs shown", minval = 1, maxval = 50, group = g_fvg)
fvgUnfilled  = input.bool(false,    "Show unfilled FVGs only", group = g_fvg, tooltip = "On = remove a gap once filled; Off = filled gaps fade and stop extending.")
fvgFill      = input.string("Touch", "Fill trigger", options = ["Touch", "Close"], group = g_fvg, tooltip = "Touch = price wicks into the gap. Close = a candle closes inside it.")
fvgShowLabel = input.bool(false,    "Label FVGs", group = g_fvg)

// --- Liquidity ---
showEQ    = input.bool(true,  "Show Equal Highs / Lows (EQH/EQL)", group = g_liq)
eqAtrMult = input.float(0.10, "Equal H/L tolerance (x ATR)", minval = 0.0, step = 0.05, group = g_liq, tooltip = "Two consecutive swings within this fraction of ATR(200) count as equal.")
showSweep = input.bool(true,  "Show liquidity sweeps", group = g_liq, tooltip = "Wick beyond a prior swing that closes back inside (stop hunt).")

// --- Premium / Discount ---
showPD  = input.bool(true,  "Show premium / discount zones", group = g_pd)
showOTE = input.bool(false, "Show OTE band (0.62-0.79)", group = g_pd, tooltip = "Optimal Trade Entry band inside discount (long OTE). Mirror manually for shorts.")

// --- Sessions / Kill Zones ---
showSess = input.bool(false, "Show session kill zones", group = g_sess)
sessTz   = input.string("UTC", "Session timezone", group = g_sess, tooltip = "IANA timezone, e.g. UTC, America/New_York, Europe/London.")
sessAsia = input.session("0000-0600", "Asian range", group = g_sess)
sessLond = input.session("0700-1000", "London open", group = g_sess)
sessNY   = input.session("1200-1500", "New York open", group = g_sess)

// --- Confluence Signals ---
cEnable    = input.bool(false, "Enable confluence signals", group = g_conf, tooltip = "Discreet long/short marker that prints only when the enabled factors below all agree.")
cLong      = input.bool(true,  "Allow long signals",  group = g_conf)
cShort     = input.bool(true,  "Allow short signals", group = g_conf)
cLookback  = input.int(10, "Event recency window (bars)", minval = 1, group = g_conf, tooltip = "How recent a structure break / sweep must be to still count.")
cReqZone   = input.bool(true,  "Require discount/premium",        group = g_conf)
cReqStruct = input.bool(true,  "Require BOS/CHoCH in direction",  group = g_conf)
cReqOB     = input.bool(true,  "Require unmitigated OB",          group = g_conf)
cReqFVG    = input.bool(false, "Require unfilled FVG in direction", group = g_conf)
cReqSweep  = input.bool(true,  "Require opposing liquidity sweep", group = g_conf)
cReqHtf    = input.bool(false, "Require HTF bias alignment",      group = g_conf)
cHtfTf     = input.timeframe("240", "HTF for bias", group = g_conf)
cHtfLen    = input.int(50, "HTF EMA length for bias", minval = 1, group = g_conf)

// --- Trade Setup (Risk:Reward) ---
showTrade  = input.bool(false, "Show trade setup (entry / SL / TP)", group = g_trade, tooltip = "Draws a full trade plan on each confluence signal. Enabling this also activates the confluence engine.")
tradeEntry = input.string("Market (signal close)", "Entry", options = ["Market (signal close)", "OB midpoint (limit)"], group = g_trade, tooltip = "Market = enter at the signal bar close. OB midpoint = a limit back into the order block that triggered the signal.")
tradeSL    = input.string("Order block", "Stop-loss anchor", options = ["Order block", "Swing point", "ATR"], group = g_trade, tooltip = "Where the stop sits (before the buffer). Order block = just past the OB that invalidates the idea. Falls back to ATR if no OB/swing is available.")
slBufAtr   = input.float(0.25, "Stop buffer (x ATR)", minval = 0.0, step = 0.05, group = g_trade, tooltip = "Extra room past the anchor so a clean wick doesn't stop you out.")
slAtrMult  = input.float(1.5, "ATR stop distance (x ATR)", minval = 0.1, step = 0.1, group = g_trade, tooltip = "Used only when the stop anchor is ATR (or as the fallback).")
tp1R       = input.float(1.0, "TP1 (R)", minval = 0.1, step = 0.1, group = g_trade, inline = "tp")
tp2R       = input.float(2.0, "TP2 (R)", minval = 0.1, step = 0.1, group = g_trade, inline = "tp")
tp3R       = input.float(3.0, "TP3 (R)", minval = 0.1, step = 0.1, group = g_trade, inline = "tp")
tp4R       = input.float(4.0, "TP4 (R)", minval = 0.1, step = 0.1, group = g_trade, inline = "tp")
tradeExt   = input.int(40, "Project levels (bars)", minval = 5, group = g_trade)
showRR     = input.bool(true, "Show R / price labels", group = g_trade)

// --- Style & Colors ---
colBull    = input.color(#26a69a, "Bullish",      group = g_style, inline = "c1")
colBear    = input.color(#ef5350, "Bearish",      group = g_style, inline = "c1")
colNeutral = input.color(#787b86, "Structure",    group = g_style, inline = "c2")
colLiq     = input.color(#ff9800, "Liquidity",    group = g_style, inline = "c2")
colSweep   = input.color(#9c27b0, "Sweep",        group = g_style, inline = "c3")
colEq      = input.color(#b2b5be, "Equilibrium",  group = g_style, inline = "c3")
colPrem    = input.color(#ef5350, "Premium",      group = g_style, inline = "c4")
colDisc    = input.color(#26a69a, "Discount",     group = g_style, inline = "c4")
boxTransp  = input.int(88, "Order block / FVG fill transparency", minval = 0, maxval = 100, group = g_style)
zoneTransp = input.int(92, "Zone fill transparency (P/D, sessions)", minval = 0, maxval = 100, group = g_style)
lblSizeOpt = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = g_style)
lineW      = input.int(1, "Structure line width", minval = 1, maxval = 4, group = g_style)

// ============================================================================
//  DERIVED CONSTANTS
// ============================================================================
lblSize   = lblSizeOpt == "Tiny" ? size.tiny : lblSizeOpt == "Normal" ? size.normal : size.small
atr       = ta.atr(200)
eqTol     = nz(atr, 0.0) * eqAtrMult
useBodyOB = obMode == "Body"

// ============================================================================
//  TYPES
// ============================================================================
// One self-contained market-structure stream (used for both swing & internal).
// Per-bar event flags are reset at the top of processStructure() every bar.
type Structure
    float ph        = na     // last confirmed pivot high price (persists)
    float pl        = na     // last confirmed pivot low price (persists)
    int   phBar     = na     // bar_index of the last pivot high
    int   plBar     = na     // bar_index of the last pivot low
    float prevPh    = na     // previous pivot high (for HH/LH classification + EQH)
    float prevPl    = na
    int   prevPhBar = na
    int   prevPlBar = na
    bool  phCrossed = false  // has the last pivot high been broken by a CLOSE?
    bool  plCrossed = false
    bool  phSwept   = false  // has the last pivot high been swept (wick only)?
    bool  plSwept   = false
    int   trend     = 0      // +1 bullish, -1 bearish, 0 undetermined
    bool  bosUp     = false  // ---- per-bar events ----
    bool  bosDown   = false
    bool  chochUp   = false
    bool  chochDown = false
    bool  sweepHigh = false
    bool  sweepLow  = false
    bool  newPH     = false  // a new pivot high was confirmed this bar
    bool  newPL     = false

type OrderBlock
    box   bx
    label lb
    float top
    float bot
    bool  bull
    bool  mitigated  = false
    bool  breaker    = false
    int   createdBar = na

type Fvg
    box   bx
    label lb
    float top
    float bot
    bool  bull
    bool  filled     = false
    int   createdBar = na

// ============================================================================
//  STATE (persistent across bars)
// ============================================================================
var Structure swingMS    = Structure.new()
var Structure internalMS = Structure.new()

// drawing collections (pruned to keep the chart clean and under object limits)
var array<line>  swingLines     = array.new<line>()
var array<label> swingLabels    = array.new<label>()
var array<line>  internalLines  = array.new<line>()
var array<label> internalLabels = array.new<label>()
var array<line>  eqLines        = array.new<line>()
var array<label> eqLabels       = array.new<label>()
var array<label> sigLabels      = array.new<label>()
var array<OrderBlock> obs       = array.new<OrderBlock>()
var array<Fvg>        fvgs       = array.new<Fvg>()

// trade-setup drawings (latest plan only)
var array<line>  tradeLines  = array.new<line>()
var array<label> tradeLabels = array.new<label>()
var array<box>   tradeBoxes  = array.new<box>()

// last opposite-colour candle, used to locate order blocks without scanning
var float dnH       = na
var float dnL       = na
var float dnBodyTop = na
var float dnBodyBot = na
var int   dnBar     = na
var float upH       = na
var float upL       = na
var float upBodyTop = na
var float upBodyBot = na
var int   upBar     = na

// premium / discount handles (a single set, redrawn each bar)
var box  pdPremBox = na
var box  pdDiscBox = na
var box  pdOteBox  = na
var line pdEqLine  = na

// ============================================================================
//  HELPER FUNCTIONS
// ============================================================================

// Create and track a bullish/bearish order block box (+ optional label).
createOB(bool isBull, float t, float b, int leftBar) =>
    color base = isBull ? colBull : colBear
    box bx = box.new(leftBar, t, bar_index, b, xloc = xloc.bar_index, border_color = color.new(base, 40), border_width = 1, bgcolor = color.new(base, boxTransp), extend = extend.none)
    label lb = na
    if obShowLabel
        lb := label.new(leftBar, t, isBull ? "Bull OB" : "Bear OB", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(base, 0), size = size.tiny)
    array.push(obs, OrderBlock.new(bx = bx, lb = lb, top = t, bot = b, bull = isBull, createdBar = bar_index))
    // prune oldest beyond the cap
    while array.size(obs) > maxOB
        OrderBlock old = array.shift(obs)
        box.delete(old.bx)
        label.delete(old.lb)

// Create and track a fair value gap box (+ optional label).
createFVG(bool isBull, float t, float b, int leftBar) =>
    color base = isBull ? colBull : colBear
    box bx = box.new(leftBar, t, bar_index, b, xloc = xloc.bar_index, border_color = color.new(base, 75), border_width = 1, bgcolor = color.new(base, math.min(boxTransp + 2, 100)), extend = extend.none)
    label lb = na
    if fvgShowLabel
        lb := label.new(leftBar, (t + b) / 2.0, "FVG", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(base, 10), size = size.tiny)
    array.push(fvgs, Fvg.new(bx = bx, lb = lb, top = t, bot = b, bull = isBull, createdBar = bar_index))
    while array.size(fvgs) > maxFVG
        Fvg old = array.shift(fvgs)
        box.delete(old.bx)
        label.delete(old.lb)

// Process one structure stream: classify pivots, detect sweeps, BOS & CHoCH,
// and draw them. `pvH`/`pvL` are the pivot results computed in the global scope
// (kept there so ta.pivot* always receives a simple int and runs every bar).
// `len` only locates the pivot's bar. `isInternal` selects styling/arrays and
// whether the stream is drawn. The object `s` is mutated in place (by reference).
processStructure(Structure s, float pvH, float pvL, int len, bool isInternal) =>
    // reset per-bar events
    s.bosUp     := false
    s.bosDown   := false
    s.chochUp   := false
    s.chochDown := false
    s.sweepHigh := false
    s.sweepLow  := false
    s.newPH     := false
    s.newPL     := false

    array<line>  lns         = isInternal ? internalLines  : swingLines
    array<label> lbls        = isInternal ? internalLabels : swingLabels
    bool         labelSwings = isInternal ? showInternalLbl : showSwing
    bool         visible     = isInternal ? showInternal : true
    float        lblOff      = nz(atr, 0.0) * 0.3

    // ---- 1) Liquidity sweeps (swing stream only): wick beyond, close inside ----
    // A sweep is mutually exclusive with a break (close beyond) on the same level.
    if showSweep and not isInternal
        if not na(s.ph) and not s.phCrossed and not s.phSwept and high > s.ph and close < s.ph
            s.sweepHigh := true
            s.phSwept   := true
            array.push(lbls, label.new(bar_index, high + lblOff, "SWEEP", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(colSweep, 20), textcolor = color.white, size = size.tiny))
        if not na(s.pl) and not s.plCrossed and not s.plSwept and low < s.pl and close > s.pl
            s.sweepLow := true
            s.plSwept  := true
            array.push(lbls, label.new(bar_index, low - lblOff, "SWEEP", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(colSweep, 20), textcolor = color.white, size = size.tiny))

    // ---- 2) Structural breaks on CLOSE ----
    // CHoCH = the FIRST break against the prevailing trend; BOS = continuation.
    // The trend flips on CHoCH and persists on BOS.
    if not na(s.ph) and not s.phCrossed and close > s.ph
        s.chochUp   := s.trend < 0          // was bearish -> bullish change of character
        s.bosUp     := not s.chochUp         // otherwise a continuation break
        s.phCrossed := true
        s.trend     := 1
        if showStructLines and visible
            color c = isInternal ? colNeutral : colBull
            array.push(lns, line.new(s.phBar, s.ph, bar_index, s.ph, xloc = xloc.bar_index, color = color.new(c, isInternal ? 35 : 0), style = s.chochUp ? line.style_dashed : line.style_solid, width = lineW))
            array.push(lbls, label.new(bar_index, s.ph, s.chochUp ? "CHoCH" : "BOS", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(c, isInternal ? 25 : 0), size = isInternal ? size.tiny : lblSize))

    if not na(s.pl) and not s.plCrossed and close < s.pl
        s.chochDown := s.trend > 0
        s.bosDown   := not s.chochDown
        s.plCrossed := true
        s.trend     := -1
        if showStructLines and visible
            color c = isInternal ? colNeutral : colBear
            array.push(lns, line.new(s.plBar, s.pl, bar_index, s.pl, xloc = xloc.bar_index, color = color.new(c, isInternal ? 35 : 0), style = s.chochDown ? line.style_dashed : line.style_solid, width = lineW))
            array.push(lbls, label.new(bar_index, s.pl, s.chochDown ? "CHoCH" : "BOS", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(c, isInternal ? 25 : 0), size = isInternal ? size.tiny : lblSize))

    // ---- 3) Record newly confirmed pivots & classify HH/HL/LH/LL ----
    if not na(pvH)
        s.newPH := true
        string tag = na(s.ph) ? "H" : (pvH > s.ph ? "HH" : "LH")   // vs the PREVIOUS high
        if labelSwings and visible
            array.push(lbls, label.new(bar_index - len, pvH, tag, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(tag == "HH" ? colBull : colBear, 25), textcolor = color.white, size = isInternal ? size.tiny : lblSize))
        s.prevPh    := s.ph                  // shift current -> previous
        s.prevPhBar := s.phBar
        s.ph        := pvH                   // store the new pivot
        s.phBar     := bar_index - len
        s.phCrossed := false
        s.phSwept   := false

    if not na(pvL)
        s.newPL := true
        string tag = na(s.pl) ? "L" : (pvL < s.pl ? "LL" : "HL")
        if labelSwings and visible
            array.push(lbls, label.new(bar_index - len, pvL, tag, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(tag == "LL" ? colBear : colBull, 25), textcolor = color.white, size = isInternal ? size.tiny : lblSize))
        s.prevPl    := s.pl
        s.prevPlBar := s.plBar
        s.pl        := pvL
        s.plBar     := bar_index - len
        s.plCrossed := false
        s.plSwept   := false

    // ---- prune this stream's drawings ----
    while array.size(lns) > maxStruct
        line oldln = array.shift(lns)
        line.delete(oldln)
    while array.size(lbls) > maxStruct * 3
        label oldlb = array.shift(lbls)
        label.delete(oldlb)

// Draw a full trade plan (entry / SL / TP1-4) for a confluence signal.
// Latest-only: the previous plan is cleared first. `sl` must already sit on the
// protective side of `entry`; R (risk) is the entry-to-stop distance, and each
// take-profit is placed at its R multiple of that distance.
drawTrade(bool isLong, float entry, float sl) =>
    while array.size(tradeLines) > 0
        line.delete(array.shift(tradeLines))
    while array.size(tradeLabels) > 0
        label.delete(array.shift(tradeLabels))
    while array.size(tradeBoxes) > 0
        box.delete(array.shift(tradeBoxes))
    float risk = math.abs(entry - sl)
    if risk > 0
        int   x1  = bar_index
        int   x2  = bar_index + tradeExt
        int   dir = isLong ? 1 : -1
        float tp1 = entry + dir * tp1R * risk
        float tp2 = entry + dir * tp2R * risk
        float tp3 = entry + dir * tp3R * risk
        float tp4 = entry + dir * tp4R * risk
        color cR  = colBear                                  // risk leg = red
        color cW  = colBull                                  // reward leg = green
        // zone boxes: entry->stop (risk) and entry->TP4 (reward)
        array.push(tradeBoxes, box.new(x1, math.max(entry, sl),  x2, math.min(entry, sl),  xloc = xloc.bar_index, border_color = color.new(cR, 80), bgcolor = color.new(cR, 90)))
        array.push(tradeBoxes, box.new(x1, math.max(entry, tp4), x2, math.min(entry, tp4), xloc = xloc.bar_index, border_color = color.new(cW, 80), bgcolor = color.new(cW, 92)))
        // level lines (draggable in TradingView to fine-tune by hand)
        array.push(tradeLines, line.new(x1, entry, x2, entry, xloc = xloc.bar_index, color = color.new(colNeutral, 0), width = 2))
        array.push(tradeLines, line.new(x1, sl,    x2, sl,    xloc = xloc.bar_index, color = color.new(cR, 0), width = 1))
        array.push(tradeLines, line.new(x1, tp1,   x2, tp1,   xloc = xloc.bar_index, color = color.new(cW, 20), style = line.style_dashed, width = 1))
        array.push(tradeLines, line.new(x1, tp2,   x2, tp2,   xloc = xloc.bar_index, color = color.new(cW, 20), style = line.style_dashed, width = 1))
        array.push(tradeLines, line.new(x1, tp3,   x2, tp3,   xloc = xloc.bar_index, color = color.new(cW, 20), style = line.style_dashed, width = 1))
        array.push(tradeLines, line.new(x1, tp4,   x2, tp4,   xloc = xloc.bar_index, color = color.new(cW, 0),  style = line.style_dashed, width = 1))
        if showRR
            array.push(tradeLabels, label.new(x2, entry, (isLong ? "LONG @ " : "SHORT @ ") + str.tostring(entry, format.mintick) + "  R:R 1:" + str.tostring(tp4R, "0.0"), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(colNeutral, 10), textcolor = color.white, size = size.small))
            array.push(tradeLabels, label.new(x2, sl,  "SL " + str.tostring(sl, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(cR, 10), textcolor = color.white, size = size.tiny))
            array.push(tradeLabels, label.new(x2, tp1, "TP1 " + str.tostring(tp1, format.mintick) + "  " + str.tostring(tp1R, "0.0") + "R", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(cW, 10), textcolor = color.white, size = size.tiny))
            array.push(tradeLabels, label.new(x2, tp2, "TP2 " + str.tostring(tp2, format.mintick) + "  " + str.tostring(tp2R, "0.0") + "R", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(cW, 10), textcolor = color.white, size = size.tiny))
            array.push(tradeLabels, label.new(x2, tp3, "TP3 " + str.tostring(tp3, format.mintick) + "  " + str.tostring(tp3R, "0.0") + "R", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(cW, 10), textcolor = color.white, size = size.tiny))
            array.push(tradeLabels, label.new(x2, tp4, "TP4 " + str.tostring(tp4, format.mintick) + "  " + str.tostring(tp4R, "0.0") + "R", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(cW, 10), textcolor = color.white, size = size.tiny))

// ============================================================================
//  MAIN
// ============================================================================

// --- pivots (computed globally so ta.pivot* receives a simple int) ---
swingPH    = ta.pivothigh(swingLen, swingLen)
swingPL    = ta.pivotlow(swingLen, swingLen)
internalPH = ta.pivothigh(internalLen, internalLen)
internalPL = ta.pivotlow(internalLen, internalLen)

// --- process both structure streams (internal state is kept even when hidden,
//     so order blocks / confluence can still use it) ---
processStructure(swingMS, swingPH, swingPL, swingLen, false)
processStructure(internalMS, internalPH, internalPL, internalLen, true)

// stream that feeds order blocks & confluence
Structure obStruct = obSource == "Internal" ? internalMS : swingMS
bool bullBreak = obStruct.bosUp  or obStruct.chochUp
bool bearBreak = obStruct.bosDown or obStruct.chochDown

// --- dealing range (most recent confirmed swing high & low) ---
float rngTop  = swingMS.ph
float rngBot  = swingMS.pl
bool  pdValid = not na(rngTop) and not na(rngBot) and rngTop > rngBot
float eqLevel = pdValid ? (rngTop + rngBot) / 2.0 : na

// --- Equal Highs / Lows: a fresh swing within tolerance of the previous one ---
if showEQ and swingMS.newPH and not na(swingMS.prevPh) and math.abs(swingMS.ph - swingMS.prevPh) <= eqTol
    float lvl = (swingMS.ph + swingMS.prevPh) / 2.0
    array.push(eqLines, line.new(swingMS.prevPhBar, lvl, swingMS.phBar, lvl, xloc = xloc.bar_index, color = color.new(colLiq, 0), style = line.style_dotted, width = 1))
    array.push(eqLabels, label.new(swingMS.phBar, lvl, "EQH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(colLiq, 0), size = size.tiny))
if showEQ and swingMS.newPL and not na(swingMS.prevPl) and math.abs(swingMS.pl - swingMS.prevPl) <= eqTol
    float lvl = (swingMS.pl + swingMS.prevPl) / 2.0
    array.push(eqLines, line.new(swingMS.prevPlBar, lvl, swingMS.plBar, lvl, xloc = xloc.bar_index, color = color.new(colLiq, 0), style = line.style_dotted, width = 1))
    array.push(eqLabels, label.new(swingMS.plBar, lvl, "EQL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, textcolor = color.new(colLiq, 0), size = size.tiny))
while array.size(eqLines) > maxStruct
    line oldln = array.shift(eqLines)
    line.delete(oldln)
while array.size(eqLabels) > maxStruct
    label oldlb = array.shift(eqLabels)
    label.delete(oldlb)

// --- Order blocks form on a structural break, using the last opposite candle
//     recorded UP TO the previous bar (the impulse origin) ---
bool newBullOB = false
bool newBearOB = false
if showOB and bullBreak and not na(dnBar)
    createOB(true, useBodyOB ? dnBodyTop : dnH, useBodyOB ? dnBodyBot : dnL, dnBar)
    newBullOB := true
if showOB and bearBreak and not na(upBar)
    createOB(false, useBodyOB ? upBodyTop : upH, useBodyOB ? upBodyBot : upL, upBar)
    newBearOB := true

// update last opposite-colour candle trackers with the (now closed) current bar
if close < open
    dnH       := high
    dnL       := low
    dnBodyTop := open
    dnBodyBot := close
    dnBar     := bar_index
else if close > open
    upH       := high
    upL       := low
    upBodyTop := close
    upBodyBot := open
    upBar     := bar_index

// --- Order block maintenance: extend, mitigate, optional breaker flip ---
bool  bullObActive = false
bool  bearObActive = false
float activeBullTop = na     // most recent live OB of each side (for stop anchoring)
float activeBullBot = na
float activeBearTop = na
float activeBearBot = na
int oi = 0
while oi < array.size(obs)
    OrderBlock ob = array.get(obs, oi)
    bool removed = false
    if ob.breaker
        box.set_right(ob.bx, bar_index)              // breakers keep extending
        if ob.bull
            bearObActive := true                      // a bullish OB that flipped is now bearish
        else
            bullObActive := true
    else if not ob.mitigated
        box.set_right(ob.bx, bar_index)
        if bar_index > ob.createdBar
            bool fullThrough = ob.bull ? close < ob.bot : close > ob.top
            if fullThrough and obBreakers
                ob.breaker := true
                color bcol = ob.bull ? colBear : colBull
                box.set_bgcolor(ob.bx, color.new(bcol, math.min(boxTransp + 4, 100)))
                box.set_border_color(ob.bx, color.new(bcol, 40))
                if not na(ob.lb)
                    label.set_text(ob.lb, ob.bull ? "Bear BB" : "Bull BB")
                    label.set_textcolor(ob.lb, bcol)
            else
                bool tapped = ob.bull ? (obMitigation == "Close" ? close <= ob.top : low <= ob.top) : (obMitigation == "Close" ? close >= ob.bot : high >= ob.bot)
                if tapped
                    ob.mitigated := true
                    if obHideMit
                        box.delete(ob.bx)
                        label.delete(ob.lb)
                        array.remove(obs, oi)
                        removed := true
                    else
                        box.set_bgcolor(ob.bx, color.new(ob.bull ? colBull : colBear, math.min(boxTransp + 7, 100)))
                        box.set_border_color(ob.bx, color.new(ob.bull ? colBull : colBear, 70))
        if not removed and not ob.mitigated and not ob.breaker
            if ob.bull
                bullObActive  := true
                activeBullTop := ob.top
                activeBullBot := ob.bot
            else
                bearObActive  := true
                activeBearTop := ob.top
                activeBearBot := ob.bot
    if not removed
        oi := oi + 1

// --- Fair value gaps: 3-candle imbalance, committed on a confirmed bar ---
bool newBullFVG = false
bool newBearFVG = false
if showFVG and barstate.isconfirmed
    // na guards keep the first bars from forming an na-typed bool (v6)
    bool bullFvgRaw = not na(high[2]) and low > high[2]   // gap between high[2] and low[0]
    bool bearFvgRaw = not na(low[2])  and high < low[2]   // gap between low[2] and high[0]
    if bullFvgRaw
        createFVG(true, low, high[2], bar_index - 1)
        newBullFVG := true
    if bearFvgRaw
        createFVG(false, low[2], high, bar_index - 1)
        newBearFVG := true

// --- FVG maintenance: extend, fill/rebalance ---
bool bullFvgActive = false
bool bearFvgActive = false
int fi = 0
while fi < array.size(fvgs)
    Fvg f = array.get(fvgs, fi)
    bool removed = false
    if not f.filled
        box.set_right(f.bx, bar_index)
        if bar_index > f.createdBar
            bool filled = f.bull ? (fvgFill == "Close" ? close <= f.top : low <= f.top) : (fvgFill == "Close" ? close >= f.bot : high >= f.bot)
            if filled
                f.filled := true
                if fvgUnfilled
                    box.delete(f.bx)
                    label.delete(f.lb)
                    array.remove(fvgs, fi)
                    removed := true
                else
                    box.set_bgcolor(f.bx, color.new(f.bull ? colBull : colBear, math.min(boxTransp + 8, 100)))
                    box.set_border_color(f.bx, color.new(f.bull ? colBull : colBear, 90))
        if not removed and not f.filled
            if f.bull
                bullFvgActive := true
            else
                bearFvgActive := true
    if not removed
        fi := fi + 1

// --- Premium / Discount / Equilibrium (single set, redrawn each bar) ---
if showPD and pdValid
    box.delete(pdPremBox)
    box.delete(pdDiscBox)
    box.delete(pdOteBox)
    line.delete(pdEqLine)
    int leftX  = int(math.min(nz(swingMS.phBar, bar_index), nz(swingMS.plBar, bar_index)))
    int rightX = bar_index + 8
    pdPremBox := box.new(leftX, rngTop, rightX, eqLevel, xloc = xloc.bar_index, border_color = color.new(colPrem, 85), bgcolor = color.new(colPrem, zoneTransp), text = "Premium", text_color = color.new(colPrem, 40), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)
    pdDiscBox := box.new(leftX, eqLevel, rightX, rngBot, xloc = xloc.bar_index, border_color = color.new(colDisc, 85), bgcolor = color.new(colDisc, zoneTransp), text = "Discount", text_color = color.new(colDisc, 40), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom)
    pdEqLine  := line.new(leftX, eqLevel, rightX, eqLevel, xloc = xloc.bar_index, color = color.new(colEq, 0), style = line.style_dashed, width = 1)
    if showOTE
        float ote62 = rngTop - 0.62 * (rngTop - rngBot)
        float ote79 = rngTop - 0.79 * (rngTop - rngBot)
        pdOteBox := box.new(leftX, ote62, rightX, ote79, xloc = xloc.bar_index, border_color = color.new(colDisc, 80), bgcolor = color.new(colDisc, math.max(zoneTransp - 6, 0)), text = "OTE", text_color = color.new(colDisc, 30), text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
else
    box.delete(pdPremBox)
    box.delete(pdDiscBox)
    box.delete(pdOteBox)
    line.delete(pdEqLine)

// --- Sessions / Kill Zones (subtle background) ---
bool isAsia = false
bool isLond = false
bool isNY   = false
if showSess
    isAsia := not na(time(timeframe.period, sessAsia, sessTz))
    isLond := not na(time(timeframe.period, sessLond, sessTz))
    isNY   := not na(time(timeframe.period, sessNY, sessTz))
bgcolor(showSess and isAsia ? color.new(colNeutral, math.min(zoneTransp + 2, 100)) : na, title = "Asian session")
bgcolor(showSess and isLond ? color.new(colLiq,     math.min(zoneTransp + 2, 100)) : na, title = "London session")
bgcolor(showSess and isNY   ? color.new(colBull,    math.min(zoneTransp + 2, 100)) : na, title = "New York session")

// --- Optional HTF bias (non-repainting: previous CLOSED HTF bar) ---
float htfEma   = request.security(syminfo.tickerid, cHtfTf, ta.ema(close, cHtfLen)[1], lookahead = barmerge.lookahead_on)
float htfClose = request.security(syminfo.tickerid, cHtfTf, close[1], lookahead = barmerge.lookahead_on)
int   htfBias  = not na(htfEma) and not na(htfClose) ? (htfClose > htfEma ? 1 : htfClose < htfEma ? -1 : 0) : 0

// --- Confluence signals ---
// nz() guards barssince (na until first event) so we never form an na bool (v6).
int barsBullStruct = nz(ta.barssince(obStruct.bosUp  or obStruct.chochUp),  1000000)
int barsBearStruct = nz(ta.barssince(obStruct.bosDown or obStruct.chochDown), 1000000)
int barsSslSweep   = nz(ta.barssince(swingMS.sweepLow),  1000000)   // sell-side swept -> bullish
int barsBslSweep   = nz(ta.barssince(swingMS.sweepHigh), 1000000)   // buy-side swept  -> bearish

bool inDiscount = not na(eqLevel) and close < eqLevel
bool inPremium  = not na(eqLevel) and close > eqLevel

bool longOK = (cEnable or showTrade) and cLong
longOK := longOK and (not cReqZone   or inDiscount)
longOK := longOK and (not cReqStruct or barsBullStruct <= cLookback)
longOK := longOK and (not cReqOB     or bullObActive)
longOK := longOK and (not cReqFVG    or bullFvgActive)
longOK := longOK and (not cReqSweep  or barsSslSweep <= cLookback)
longOK := longOK and (not cReqHtf    or htfBias >= 1)

bool shortOK = (cEnable or showTrade) and cShort
shortOK := shortOK and (not cReqZone   or inPremium)
shortOK := shortOK and (not cReqStruct or barsBearStruct <= cLookback)
shortOK := shortOK and (not cReqOB     or bearObActive)
shortOK := shortOK and (not cReqFVG    or bearFvgActive)
shortOK := shortOK and (not cReqSweep  or barsBslSweep <= cLookback)
shortOK := shortOK and (not cReqHtf    or htfBias <= -1)

bool longSig  = bar_index > 0 and longOK  and not longOK[1]   // rising edge only (no spam)
bool shortSig = bar_index > 0 and shortOK and not shortOK[1]

if cEnable and longSig and barstate.isconfirmed
    array.push(sigLabels, label.new(bar_index, low, "▲ LONG", xloc = xloc.bar_index, yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colBull, 0), textcolor = color.white, size = lblSize))
if cEnable and shortSig and barstate.isconfirmed
    array.push(sigLabels, label.new(bar_index, high, "▼ SHORT", xloc = xloc.bar_index, yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colBear, 0), textcolor = color.white, size = lblSize))
while array.size(sigLabels) > 100
    label oldlb = array.shift(sigLabels)
    label.delete(oldlb)

// --- Trade setup: draw entry / SL / TP on a confluence signal ---
if showTrade and (longSig or shortSig) and barstate.isconfirmed
    bool  isLong = longSig
    float buf    = nz(atr, 0.0) * slBufAtr
    float entry  = close
    if tradeEntry == "OB midpoint (limit)"
        entry := isLong ? (na(activeBullTop) ? close : (activeBullTop + activeBullBot) / 2.0) : (na(activeBearTop) ? close : (activeBearTop + activeBearBot) / 2.0)
    float sl = na
    if tradeSL == "Order block"
        sl := isLong ? (na(activeBullBot) ? na : activeBullBot - buf) : (na(activeBearTop) ? na : activeBearTop + buf)
    else if tradeSL == "Swing point"
        sl := isLong ? (na(swingMS.pl) ? na : swingMS.pl - buf) : (na(swingMS.ph) ? na : swingMS.ph + buf)
    if na(sl) or tradeSL == "ATR"                          // ATR mode, or fallback when no structure
        sl := isLong ? entry - nz(atr, 0.0) * slAtrMult : entry + nz(atr, 0.0) * slAtrMult
    drawTrade(isLong, entry, sl)

// ============================================================================
//  ALERTS  (messages use {{ticker}} / {{interval}} / {{close}} placeholders)
// ============================================================================
bool alBOS   = swingMS.bosUp  or swingMS.bosDown
bool alCHoCH = swingMS.chochUp or swingMS.chochDown
bool alSweep = swingMS.sweepHigh or swingMS.sweepLow

alertcondition(alBOS,      "BOS (swing)",       "SMC: Break of Structure on {{ticker}} {{interval}} @ {{close}}")
alertcondition(alCHoCH,    "CHoCH (swing)",     "SMC: Change of Character on {{ticker}} {{interval}} @ {{close}}")
alertcondition(newBullOB,  "New bullish OB",    "SMC: New bullish order block on {{ticker}} {{interval}} @ {{close}}")
alertcondition(newBearOB,  "New bearish OB",    "SMC: New bearish order block on {{ticker}} {{interval}} @ {{close}}")
alertcondition(newBullFVG, "New bullish FVG",   "SMC: New bullish FVG on {{ticker}} {{interval}} @ {{close}}")
alertcondition(newBearFVG, "New bearish FVG",   "SMC: New bearish FVG on {{ticker}} {{interval}} @ {{close}}")
alertcondition(alSweep,    "Liquidity sweep",   "SMC: Liquidity sweep on {{ticker}} {{interval}} @ {{close}}")
alertcondition(longSig,    "Confluence LONG",   "SMC: Confluence LONG on {{ticker}} {{interval}} @ {{close}}")
alertcondition(shortSig,   "Confluence SHORT",  "SMC: Confluence SHORT on {{ticker}} {{interval}} @ {{close}}")
````
