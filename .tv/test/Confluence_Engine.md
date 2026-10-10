<!-- tradingview-pine-id: PUB;1885e35257424e0eb3326b25815aef04 -->
<!-- tradingview-pine-version: 14.0 -->
<!-- tradingviewscripts-format: 1 -->
# Confluence Engine+

Source: https://www.tradingview.com/script/9pNHhcx6-Confluence-Engine/

## Description

Confluence Engine+ 
Maps the PD arrays taught by ICT. Instead of plotting a dozen isolated objects and leaving you to weigh them by eye, it reads the confluences present at price — a liquidity raid into a discount PD array, confirmed by a breaker, with SMT, inside a killzone — into the ICT directional bias, the current draw on liquidity, and a corner dashboard. It reports context and leaves the trade to you. It is not a signal generator: it does not fire buy or sell orders and it does not place entries or exits.

What it does
Six modules, each toggleable, built so later stages read the state the earlier ones capture.

1 · Killzones & Sessions. Time-gates the London, NY AM and NY PM killzones and marks the Asia, London and New York session highs and lows as unmitigated levels, plus the 00:00 New York Midnight Open — a core daily reference (below it leans the day bullish, above it bearish). Every time window here — the killzones included — is resolved on the session source timeframe rather than the chart's. A killzone is ninety minutes to three hours, narrower than a single higher-timeframe candle, so judged off the chart a candle merely overlapping one would report as fully inside it. The killzone is read at the candle's close, and the Midnight Open the same way, so it still resolves on charts whose own candles never open at 00:00.

2 · Structure & Dealing Range. Pivot highs and lows define the swing structure the arrays build on. The dealing range — the window whose midpoint separates premium from discount — is taken from a fixed higher-timeframe period: the weekly range on 1-hour-and-up charts, the daily range on anything intraday below that.

3 · Liquidity. Session highs and lows (Asia, London, New York) plus prior day and prior week highs and lows are drawn as reference liquidity, each anchored to the candle that formed it. Session extremes are measured on a lower timeframe rather than the chart's: a three-hour London window is shorter than a single 4-hour candle, so read off the chart it would collapse to the high of whichever candle happened to contain it. Sourcing them lower keeps session levels correct on any chart, and charts already at or below that timeframe track natively.
A level tracks the right edge while it rests; the instant price touches it, it is mitigated — the line stops extending at that candle, turns dotted and dims — so taken liquidity stays readable as history and can never be mistaken for a live level. Where levels land close together only the most significant is drawn, a weekly level outranking a prior-day level, which outranks a session level, so near-duplicates never stack. Each level then retires once it ages past its lookback window: the "back" settings are a window in days and weeks, so nothing lingers long after the session or period that formed it.

4 · PD Arrays. Fair Value Gaps (BISI / SIBI), Volume Imbalances, Order Blocks (the candle body before a displacement) and the Order-Block-to-Breaker lifecycle. A FVG registers only when the gap clears a height floor and its middle candle is a genuine displacement candle, so routine three-bar gaps are filtered out. A Volume Imbalance is the FVG's thinner cousin — a two-candle gap between the bodies that a wick still trades through, so the only volume in the gap changed hands in wicks; it carries its own sensitivity floor and lives under the same lifecycle as the FVGs. A new gap also removes any stale opposite-direction gap it overlaps: that range has since been delivered through the other way, so the old one-sided imbalance cannot stand.
An Order Block must earn its place with the full ICT sequence: the close that breaks the prior swing — a structure break grants that credit exactly once, so blocks sit at real breaks rather than printing mid-trend — and the leg must leave a Fair Value Gap behind it. The gap is the displacement evidence: a leg that never gaps did not really displace, and its block never registers. Only the order blocks that matter make the chart. A live block is the body of its origin candle, open to close. When price closes through it the block fails and flips into a Breaker — and a breaker takes the full candle, wick to wick: the displacement behind it is already proven, so the whole candle becomes the array. A percentage-fill mitigation decider governs each array: once price trades a chosen depth into it from the side it is approached from (default 50%, consequent encroachment), the array is mitigated — either faded and kept (dotted, faint, check mark) or removed, whichever you set. A largest-array-wins declutter keeps overlapping zones from stacking.

5 · SMT Divergence. A liquidity-sweep read against a correlated symbol — auto-paired (NQ to ES, ES to NQ, YM to ES, GC to SI, and their micros) or a symbol you set. When your chart takes a swing level but the peer holds its aligned level and refuses to follow, the move lacks participation: a SMT is drawn from the swept level to the sweep. Pooled swings age out after a set number of bars, so a divergence is only ever drawn between swings that were still contemporaries — never between two that are days apart.

6 · Dashboard. A pure confluence read-out of the state each module captures — the ICT bias, and the current draw on liquidity: the nearest unmitigated high above (the resting buyside) and the nearest unmitigated low below (the resting sellside), each named with its distance — where price is being drawn to, read straight from the level engine. When liquidity is taken, the sweep row names the level that was raided — PDH, PDL, a session high or low — rather than a generic flag. Below that, whichever confluences are live (a OB or Breaker tap, a SMT), the killzone, the Midnight Open and the dealing-range position — every row a decision input, nothing that is merely inventory. It reports context; the trade is left to you, and nothing fires.

Visual grammar

Order blocks and breakers draw as levels by default, the way a block is actually read: the proximal edge — the price that gets traded — a solid line in the direction colour, the distal edge dotted, the consequent encroachment dotted grey between them, and a small tag at the right end that renames itself from OB to Breaker when the block flips. Prefer the block as a region instead and one setting draws it as a see-through zone with a hard border. A live gap zone is solid with its label travelling at the live edge; once a zone is mitigated to the chosen fill depth it turns dotted, fades, and its name folds into the zone itself — a faint "✓ name" carried inside the frozen box, quiet by design, so worked zones read as history at a glance. A liquidity level extends while it rests and freezes into a dotted line the moment it is taken — full-strength black by default, with an optional dim. Purple marks bullish arrays, magenta bearish; liquidity and levels are neutral. Nearby level labels merge so the chart stays readable, and objects project a few bars past the last candle so labels sit in clear space, never on price.

Method & repainting
Every detection path — liquidity capture, PD-array formation, mitigation and SMT — evaluates only on closed bars, so nothing is drawn, moved or removed on the strength of an unfinished candle. Once a level, zone or SMT line is on the chart it stays where it was placed. Completed period levels fix at the rollover, and session extremes are read from the closed intrabars of the session source timeframe.

Two things update live, by design. The dashboard reads current price, so the bias and draw rows move during the forming candle and settle at its close; and the right-edge labels re-merge as levels are added or taken. Neither creates or moves a drawn object.

Swing-based features — the order-block structure break and SMT — depend on pivots, which confirm a set number of bars after the swing itself forms. That is a fixed delay, not a revision: a pivot never moves once printed. Session levels also rely on lower-timeframe data, which is available for a limited span of recent history, so they thin out far back on the chart.

Settings
Session timezone, session windows and the session source timeframe, per-array sensitivities and the mitigation decider, block drawing mode (levels or zone), the SMT peer and liquidity memory, and full dashboard controls are all exposed as inputs.

Disclaimer
This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
//
// ═══════════════════════════════════════════════════════════════════════════
//  CONFLUENCE ENGINE+   ·   PD-array analytics
//  ───────────────────────────────────────────────────────────────────────────
//  Maps the PD arrays. Rather than plotting a dozen
//  isolated objects, it weighs the confluences present at price — a liquidity
//  raid into a discount PD array, confirmed by a breaker, with SMT, inside a
//  killzone — into the ICT directional bias, the draw on liquidity, and a corner
//  dashboard. It reports context and leaves the trade to you — it is not a
//  signal generator.
//
//  Modules (each toggleable, built so later stages read earlier state):
//    1. Killzones & Sessions — London / NY AM / NY PM time-gating; Asia / London
//       / NY session highs & lows as unmitigated levels; the 00:00 NY Midnight
//       Open and the Weekly Open as daily and weekly references. Every time
//       window is resolved on the session source timeframe, so none of them
//       widens to fit a higher-timeframe candle.
//    2. Swing Structure — pivots, a dealing range and its premium/discount
//       equilibrium.
//    3. Liquidity — session highs & lows (Asia/London/NY), measured on a lower
//       timeframe so short session windows stay accurate on higher-timeframe charts,
//       plus prior day/week highs & lows — each anchored to the candle that formed
//       it, and frozen, dotted and dimmed once taken.
//    4. PD Arrays — FVG (BISI/SIBI) with its Volume Imbalances absorbed, Suspension Block
//       (a stacked leg whose bodies never trade back through it), the FVG→Inversion
//       lifecycle (a respected gap price closes through flips polarity and trades as
//       the opposite array), Order Block (candle body)
//       and the OB→Breaker lifecycle (a respected block that fails takes the full
//       candle, wick to wick), with a largest-array-wins declutter. Gaps: wicks
//       trade anywhere, bodies decide — a body holding the right side of the
//       consequent encroachment respects the gap (bold ✓); a body closing past it
//       while still inside disrespects it (faded, bold ✗, or removed); a body
//       closing outside removes it, or inverts it if it was respected first.
//       Blocks: any touch that holds inside respects the block; only a body closing
//       through the block, wick and all, ends it — and that close IS the breaker:
//       the block fails and flips in place, the way a gap inverts. A breaker is read
//       as its whole range. Optional consequent-encroachment midline through gaps.
//    5. SMT Divergence — swing-by-swing against a correlated symbol, correlation
//       direction derived from co-movement (works for positive or inverse pairs).
//    6. Dashboard — the ICT bias read, the draw on liquidity, the named sweep and
//       the live confluences. Context, not a call to act.
//
//  BLOCK DRAWING MODE — read before changing it. Order blocks and breakers draw
//  as LEVELS by default (proximal solid, distal solid, CE dotted grey, tag at
//  the right end), NOT as zones. That default was once flipped to zones on the
//  strength of a note claiming the opposite, and reverted the same day. Levels
//  are the wanted default — do not flip it again without being told to in those
//  words.
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Confluence Engine+", "ICT Engine+ (M1D)", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
// PALETTE CONSTANTS
// ----------------------------------------------------------------------------
// C_INK is REAL black. Pine's built-in black constant is #363A45 — a dark slate
// grey, part of TradingView's own UI chrome — so every line and every piece of text
// that used it rendered grey, not black. On a white chart that is plainly visible,
// and it was: level lines, session lines, the midnight open and the whole dashboard.
// Nothing in this script may use that constant. Where black is the requirement it is
// written as the hex, and a grep proving the file is CONSISTENT is not a check that
// it is BLACK — only the hex value is.
// ============================================================================
const color C_INK  = #000000    // real black, not the #363A45 built-in
const color C_MID  = #000000    // consequent encroachment midlines
const color C_INV  = #E8710A    // inversions — their own colour, see below

// ============================================================================
// INPUTS
// ============================================================================
const string G_GEN   = "General"
const string G_KZ    = "Killzone Gating"
const string G_SESS  = "Sessions H/L"
const string G_STR   = "Swing Structure"
const string G_LVL   = "Liquidity — MTF Levels"
const string G_PDA   = "PD Arrays"
const string G_SMT   = "SMT Divergence"
const string G_SCORE = "Dashboard"

string tzInput      = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "America/Chicago", "America/Los_Angeles", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Asia/Hong_Kong", "Australia/Sydney", "UTC"], group = G_GEN)
int    rightOffset  = input.int(8, "Right-side offset (bars)", minval = 0, maxval = 30, group = G_GEN, tooltip = "Lines & boxes project this many bars past the last candle so labels sit in clear space, never on price.")
string levelLabelSz = input.string("small", "Line label size", options = ["tiny", "small", "normal", "large"], group = G_GEN)
string zoneLabelSz  = input.string("small",  "Zone label size", options = ["tiny", "small", "normal", "large"], group = G_GEN)
string eventLabelSz = input.string("small", "SMT label size", options = ["tiny", "small", "normal", "large"], group = G_GEN)
float  combineAtr   = input.float(0.5, "Combine labels within (× ATR)", minval = 0.0, step = 0.1, group = G_GEN, tooltip = "Levels closer than this merge into one label (both lines stay). 0 = never combine.")
bool   showMidnight = input.bool(true, "Show Midnight Open (00:00 NY)", group = G_GEN, tooltip = "The 00:00 NY open — a core ICT daily reference. Below it leans bullish for the day, above it leans bearish. Feeds the ICT Bias.")
color  midnightCol  = input.color(color.new(C_INK, 0), "Midnight Open colour", group = G_GEN)
bool   showWeekOpen = input.bool(false, "Show Weekly Open", group = G_GEN, tooltip = "The open of the current trading week, taken from the weekly candle — Sunday's 18:00 NY open on futures, the venue's own week open elsewhere. A reference level only: it is drawn and labelled but deliberately does NOT feed the ICT Bias, which stays the dealing range plus the Midnight Open. Its label sits further right than the Midnight Open's so the two never stack.")
color  weekOpenCol  = input.color(color.new(C_INK, 0), "Weekly Open colour", group = G_GEN)

string sessLondon = input.session("0200-0500", "London KZ", group = G_KZ)
string sessNYAM   = input.session("0830-1100", "NY AM KZ", group = G_KZ)
string sessNYPM   = input.session("1330-1600", "NY PM KZ", group = G_KZ)

bool   showSess     = input.bool(true, "Show Session Highs / Lows", group = G_SESS)
int    sessDaysBack = input.int(2, "Days back", minval = 1, maxval = 5, group = G_SESS)
bool   showAsiaS    = input.bool(true, "Asia", group = G_SESS, inline = "as")
string sessAsia     = input.session("1800-0000", "", group = G_SESS, inline = "as")
bool   showLonS     = input.bool(true, "London", group = G_SESS, inline = "ln")
string sessLonHL    = input.session("0200-0500", "", group = G_SESS, inline = "ln")
bool   showNyS      = input.bool(true, "New York", group = G_SESS, inline = "ny")
string sessNyHL     = input.session("0930-1100", "", group = G_SESS, inline = "ny")
color  sessColor    = input.color(C_INK, "Session line", group = G_SESS, inline = "ss")
int    sessWidth    = input.int(1, "", minval = 1, maxval = 4, group = G_SESS, inline = "ss")
string sessSrcTf    = input.string("5", "Session source timeframe (min)", options = ["1", "3", "5", "15"], group = G_SESS, tooltip = "Session highs & lows are measured from THIS timeframe, not the chart's. A 3-hour London window is shorter than a single 4H candle, so read off the chart it would just be the high of whichever candle contained it. Sourcing from a lower timeframe keeps Asia / London / NY levels correct on any chart. Ignored when the chart is already at or below this.")

int pivLeft  = input.int(5, "Pivot Left Strength",  minval = 1, group = G_STR)
int pivRight = input.int(3, "Pivot Right Strength", minval = 1, group = G_STR)
bool  showOTE = input.bool(false, "OTE band on the swing leg", group = G_STR, tooltip = "The optimal trade entry band, measured the way it is drawn by hand: from the last swing low to the last swing high, with the retracement read back from whichever of the two printed later. A leg that ran up retraces down into discount; a leg that ran down retraces up into premium. The leg decides the direction, so the band cannot point somewhere the leg does not. A dotted grey line spans the leg it was measured on. Swing sensitivity is the Pivot Left and Right Strength settings above.")
float oteFrom = input.float(0.62, "OTE band from", minval = 0.5, maxval = 1.0, step = 0.01, group = G_STR)
float oteTo   = input.float(0.79, "OTE band to",   minval = 0.5, maxval = 1.0, step = 0.01, group = G_STR)
color oteCol  = input.color(#4A4A4A, "OTE band colour", group = G_STR, tooltip = "Blackish grey by default: a retracement is a measurement rather than a directional array, so it does not wear the bull or bear colour.")

bool   showPD      = input.bool(true, "Prior Day High / Low", group = G_LVL, inline = "d")
int    pdDaysBack  = input.int(3, "back", minval = 1, maxval = 5, group = G_LVL, inline = "d")
bool   showPW      = input.bool(true, "Prior Week High / Low", group = G_LVL, inline = "w")
int    pwWeeksBack = input.int(1, "back", minval = 1, maxval = 3, group = G_LVL, inline = "w")
color  lvlColor    = input.color(C_INK, "Level line", group = G_LVL, inline = "lv")
int    lvlWidth    = input.int(1, "", minval = 1, maxval = 4, group = G_LVL, inline = "lv")
int    sweepMemory = input.int(30, "Sweep Relevance Window (bars)", minval = 1, group = G_LVL)
float  levelMinGap = input.float(0.75, "Min gap between levels (× ATR)", minval = 0.0, step = 0.25, group = G_LVL, tooltip = "Quality over quantity — when levels land within this distance of each other only the most significant is drawn, so the chart shows meaningful liquidity instead of every near-duplicate. A weekly level outranks a prior-day level, which outranks a session level. 0 = keep them all.")
int    levelDim    = input.int(0, "Mitigated level dim %", minval = 0, maxval = 100, group = G_LVL, tooltip = "Once price touches a level it is mitigated: the line stops extending at that candle and turns dotted. 0 keeps the line at full strength — the dotted style alone marks it as taken; raise this to also fade it.")
bool   sweptMark   = input.bool(true, "Mark a taken level with a ✗", group = G_LVL, tooltip = "A tiny ✗ at the middle of the frozen run, on the OUTSIDE of the level — above a high, below a low — so the mark never sits on the line it is describing. The dotted style says the level stopped extending; the ✗ says liquidity was taken there, which is the part you are reading for.")

// -- PD arrays — per-array sensitivity + declutter ----------------------------
bool  showFVG     = input.bool(true, "Show FVGs", group = G_PDA, inline = "fv")
color bullZoneCol = input.color(color.new(#7246CE, 74), "Bull", group = G_PDA, inline = "fv")
color bearZoneCol = input.color(color.new(#DB1D9C, 74), "Bear", group = G_PDA, inline = "fv")
color invZoneCol  = input.color(color.new(C_INV, 74), "Inverted gap (IFVG / IVI)", group = G_PDA, tooltip = "An inversion carries its OWN colour rather than joining the bull/bear pair. It is not simply a gap that changed direction — it is a gap being read from the opposite side after failing, and the third colour is what makes that legible at a glance instead of looking like an ordinary bullish or bearish gap that has always been there.")
float minFvgAtr   = input.float(0.15, "FVG sensitivity — min height (× ATR)", minval = 0.0, step = 0.05, group = G_PDA, tooltip = "Higher = only larger, more significant gaps register.")
float fvgDispMult = input.float(0.6, "FVG requires displacement — body (× ATR)", minval = 0.0, step = 0.1, group = G_PDA, tooltip = "The candle that OPENS the gap (its middle candle) must have a body at least this large, in the gap's direction, for the FVG to register. This is what makes it a real displacement gap, not every routine three-bar gap — raise it to keep only expansion FVGs, 0 to accept any gap that meets the height above.")
bool  absorbVI    = input.bool(true, "Absorb Volume Imbalances into gaps", group = G_PDA, tooltip = "A Volume Imbalance is a two-candle BODY gap that a wick still trades through — price gapped between the bodies, but a wick bridged the space, so the only volume in the gap changed hands in wicks. It is not a separate array: it is part of the same imbalance as the gap beside it. ON: a body gap on either seam of the displacement candle EXTENDS the zone to that body edge, so one zone carries the whole region. OFF: the zone is the wick gap alone, which understates it.")
bool  showSB      = input.bool(true, "Detect Suspension Blocks", group = G_PDA, tooltip = "Three same-direction candles, each opening beyond the previous one's close, so the bodies never trade back through the leg at either join — a Volume Imbalance on both seams at once, joined through the middle body. It qualifies on its own: a suspension block does not need a fair value gap to be present, and a leg can be stacked tightly enough that every wick overlaps and still never let its bodies trade back. The zone is the whole suspended span, the first candle's close to the last candle's open; where a wick gap is present too, the block's wider span is drawn instead of it.")
bool  showIFVG    = input.bool(false, "Invert gaps price closes through (IFVG / ISB)", group = G_PDA, tooltip = "The FVG's own OB→Breaker lifecycle. A gap that has been respected at least once and is then CLOSED clean through has failed as support or resistance; ICT reads that failed gap as an inversion, and it goes on to trade as the opposite array. ON: the zone flips polarity, retags IFVG (or ISB for an inverted Suspension Block) and lives on under the same rules — a second close through it and it is gone. OFF: a gap closed through is simply deleted. A gap run straight through before it was ever respected is deleted either way — it was never an array in play.")
bool  showGapCE   = input.bool(false, "Consequent encroachment midline on gaps", group = G_PDA, tooltip = "The midpoint of a FVG, Suspension Block or inversion, drawn dotted grey — the ICT consequent encroachment, which is the level a gap is most often respected at. Order blocks and breakers drawn as levels already carry theirs. Note the wording: a range has an EQUILIBRIUM, a PD array has a CONSEQUENT ENCROACHMENT.")
bool  showOB      = input.bool(true, "Show Order Blocks / Breakers", group = G_PDA, tooltip = "An order block registers only when its displacement leg closes through structure AND leaves a Fair Value Gap — the ICT sequence in full. No gap, no order block: only the blocks that matter.")
bool  obRays      = input.bool(true, "Draw blocks as levels, not zones", group = G_PDA, tooltip = "The One Shot One Kill treatment, and the house default: a block is read at its LEVELS — the proximal edge solid in the direction colour (that is the price that gets traded), the distal edge solid too, the consequent encroachment dotted grey, and a small tag at the right end. Off = the block paints as a bordered see-through zone instead. A breaker can still paint as a zone in levels mode — see the next setting.")
bool  brkrZone    = input.bool(true, "Breakers always draw as zones", group = G_PDA, tooltip = "With blocks drawn as levels, a block that fails and flips to a breaker drops its lines and paints as a bordered see-through zone in the breaker colour, so a breaker is never mistaken for a live order block. Off = a breaker keeps the level treatment. No effect when blocks already draw as zones.")
bool  obNeedMSS   = input.bool(true, "OBs require a structure break (MSS)", group = G_PDA, tooltip = "ON: a OB registers only when the displacement CLOSES through the last swing (a real MSS), so OBs sit at genuine swing points, not noise.")
string brkrCandle = input.string("Failed block", "Breaker candle", options = ["Failed block", "Up-close at the low"], group = G_PDA, tooltip = "Which candle a breaker is read from. Failed block, the house default and the same reading the Unicorn Model uses: an order block that price closes through fails and BECOMES the breaker, in place, trading from the other side - exactly as a Fair Value Gap inverts into an IFVG, and with no need for the block to be touched first. The block keeps its own range and flips polarity, colour and tag. The rigour sits at the block-s BIRTH, not at the flip: a block only exists where displacement closed through the prior swing and left a gap behind it, so a block that fails is already a proven array and the close through it is the whole event. Up-close at the low: the ICT breaker CANDLE instead, read from the swing rather than the block - a bearish breaker is the up-close candle group at the swing low that formed before an old high was run, born on the close back below that low. In that reading a failed block is removed rather than flipped.")
bool   brkrIctCandle = brkrCandle == "Up-close at the low"
bool  brkRunClose = input.bool(true, "The run on liquidity must CLOSE beyond the level", group = G_PDA, tooltip = "What counts as the old high or low having been RUN, for the purpose of arming a breaker. ON: a candle has to close beyond it - a higher high or lower low actually put in. OFF: a wick through it is enough. The reversal that completes the breaker has always required a close back through the swing, so ON is the consistent reading: the same standard for the run as for the break. This governs the BREAKER only. The liquidity levels on the chart still mitigate on a touch, because a level being taken and a structural high being made are two different events.")
float grpSimilar  = input.float(2.0, "Group similarity band (x the anchor candle)", minval = 1.0, step = 0.25, group = G_PDA, tooltip = "An order block or breaker is a GROUP of consecutive same-direction candles, and this decides which of them belong to it. A candle joins while it measures between 1/x and x of the ANCHOR candle - the block's extreme-body-close candle, the breaker's first candle at the swing - so the group stays one cluster instead of drifting. The block is measured on its BODY, because a block is a body; the breaker on its whole RANGE, because a breaker is read wick to wick. At 2 a candle joins while it is between half and double the anchor. Lower it to split groups harder, raise it to let more of the run in. This band is an engineering choice, not an ICT figure.")
bool  brkrNeedSeq = input.bool(false, "A breaker needs the full sequence", group = G_PDA, tooltip = "An EXTRA gate on the candle that breaks: a NAMED level taken, and DISPLACEMENT on the break itself. OFF is the default, because in failed-block mode the sequence has already been proven once - a block only exists where displacement closed through the prior swing and left a gap behind it, so asking for displacement again at the flip asks for the same evidence twice and silences real breakers. ON, failed block: the block flips only when the candle taking it out is displacement in that direction AND the matching raid happened before the reversal - a buyside raid before a bullish block breaks down, a sellside raid before a bearish one breaks up. ON, up-close-at-the-low: the run that arms the candidate must land on one of the levels this script draws being raided, not merely a close above the last internal pivot, and the close back through the swing must be displacement. That reading needs it far more, because its candidate is armed off an internal pivot that a range clears on every oscillation.")
float brkrDispAtr = input.float(0.6, "Displacement through the break (x ATR)", minval = 0.0, step = 0.1, group = G_PDA, tooltip = "How large the body of the candle that breaks must be, in ATR, for that break to count as displacement rather than a drift through - the swing in the up-close-at-the-low reading, the block itself in the failed-block reading. Only read when the setting above is on. This multiplier is an engineering choice, not an ICT figure.")
bool  brkrTested  = input.bool(false, "Breaker requires a tested block", group = G_PDA, tooltip = "Failed block mode only. OFF: any order block that price closes through flips to a breaker, tested or not — price runs from the block, takes the liquidity and displaces back through it. ON: a block closed through before price has ever traded back into it is removed; only a block that was tested and held, then failed, flips to a breaker. The breaker itself is drawn the same way in both cases.")
float minObAtr    = input.float(0.25, "OB sensitivity - min body height (x ATR)", minval = 0.0, step = 0.05, group = G_PDA, tooltip = "A block is its BODY, so that is what this measures: the open-to-extreme-close span of the block group must be at least this tall to register. A candle whose body is a point or two is a doji, not an order block, whatever else it satisfies - it has no room for price to be traded from and it clutters the chart. Measured in chart-timeframe ATR so it travels across instruments and timeframes. 0 draws every block that meets the sequence. This floor is an engineering choice, not an ICT figure.")
int   obMinGrade  = input.int(0, "Block grade filter (0 = draw them all)", minval = 0, maxval = 4, group = G_PDA, tooltip = "Correct PLACEMENT does not make a block worth trading. Every block that registers is graded 0-4 on the context it was born into — one point each for: liquidity was raided before the leg that made it; the block sits on the right side of the dealing range (a bullish block in discount, a bearish one in premium); price displaced away from it by at least the ATR distance set below; and it formed inside a killzone. 2 drops the weakest, 3 keeps A-setups only. 0 draws every block.")
bool  obShowGrade = input.bool(false, "Show the grade on the block tag", group = G_PDA, tooltip = "Appends the score to the tag — OB + 15m 3/4. Turn it on while you set the filter above, so you can see what your blocks actually score before you decide where to cut.")
int   arrayMaxAge    = input.int(400, "Retire arrays older than (bars)", minval = 0, group = G_PDA, tooltip = "Any order block, breaker, FVG or inversion older than this is removed, spent or not — it is no longer an array price is drawing to, just a line from another session. Counted in bars of the chart timeframe, so it scales with it. A breaker or inversion counts from its flip, not from the array it came from. 0 = never.")
float arrayMaxDist   = input.float(10.0, "Retire arrays further than (× ATR)", minval = 0.0, step = 0.5, group = G_PDA, tooltip = "Any array whose traded edge sits further from price than this is removed — price is not close to reaching it, so it is not available. Measured from the close to the proximal edge, so an array price is inside or beyond is never far. 0 = off.")
float obDispAtr   = input.float(1.0, "Grade: displacement beyond the block (× ATR)", minval = 0.1, step = 0.1, group = G_PDA, tooltip = "How far past the block price must have travelled, block to displacement close, to earn the displacement point. A leg that barely clears its own origin candle is not displacement.")
bool  declutterPD = input.bool(true, "Declutter — biggest array wins", group = G_PDA, tooltip = "When PD arrays overlap in the same price area, keep the LARGEST and remove the smaller overlapping ones.")
int   maxZones    = input.int(1, "Max Live Zones per Type", minval = 1, maxval = 20, group = G_PDA, tooltip = "How many zones of EACH type are kept on the chart at once — the newest win, the oldest drops off, and a spent zone always goes before a live one. Lower = a more contained, less crowded chart. Order blocks, breakers, FVGs, Suspension Blocks and inversions each carry their own allowance, so a run of breakers cannot push your live order blocks off the chart, and a run of gaps cannot clear your Suspension Blocks. The next setting decides what one allowance covers.")
string capScope   = input.string("Total", "Count the allowance", options = ["Total", "Bullish / bearish", "Above / below price"], group = G_PDA, tooltip = "What one allowance of Max Live Zones covers. Total: the newest N of each type, whichever way they read. Bullish / bearish: N bullish and N bearish of each type, so a run in one direction never clears the other. Above / below price: N of each type above the current price and N below it, so the arrays price is heading into are never pushed off by the ones behind it. A zone is above or below by its edges, and a zone the close sits inside counts on the side it is traded from — a bullish zone below, a bearish zone above.")
int   tapMemory   = input.int(5, "Array Tap Memory (bars)", minval = 1, group = G_PDA)
string mitAction  = input.string("Fade & keep", "On mitigation", options = ["Fade & keep", "Remove"], group = G_PDA, tooltip = "What happens to a gap, Suspension Block or inversion once a body closes past its consequent encroachment while still inside it. Fade & keep — it freezes at that candle, turns dotted + faint and carries a bold ✗, and only the most recently faded gap of each type is kept. Remove — it is deleted for the barest chart. A body closing outside the gap removes it either way. Order blocks do not fade: a block is live until a body closes through it.")
int    zoneFade   = input.int(88, "Mitigated zone fade %", minval = 0, maxval = 100, group = G_PDA, tooltip = "How faint a mitigated zone is drawn, 0 solid to 100 invisible. Sets the transparency of the zone's fill; its dotted border dims in step, at four tenths of this, so the frame always reads stronger than the fill. Applies to FVGs, Suspension Blocks, inversions and blocks drawn as zones.")

bool   smtOn        = input.bool(true, "Enable SMT Divergence", group = G_SMT)
string smtSymbol    = input.symbol("", "Correlated Symbol", group = G_SMT, tooltip = "Leave EMPTY to auto-pair — NQ↔ES, YM→ES, GC→SI (and their micros), so the same NQ/ES divergence reads identically whether the Engine is on the NQ chart or the ES chart. Set a symbol to override.")
int    smtMemory    = input.int(30, "SMT Relevance Window (bars)", minval = 1, group = G_SMT, tooltip = "How recently a SMT must have formed to still count as live context in the confluence stack + dashboard.")
int    smtPivot     = input.int(3, "SMT Pivot Strength", minval = 1, group = G_SMT, tooltip = "Left/right bars for the SMT swing pivots, on both your chart and the peer. Lower = more, smaller swings compared; higher = fewer, cleaner ones.")
int    smtPoolBars  = input.int(120, "SMT Liquidity Memory (bars)", minval = 10, group = G_SMT, tooltip = "How far back a pooled swing stays eligible to be swept. Past this it leaves the pool, so a SMT is never drawn between two swings that are days apart — the divergence is only meaningful between swings that are still contemporaries.")
bool   smtCandleCheck = input.bool(true, "Candle-direction validation", group = G_SMT, tooltip = "Only accept a bullish SMT made by an up candle at the swing, and a bearish SMT by a down candle — filters weak, wrong-way divergences.")
bool   smtDelBroken = input.bool(true, "Remove broken SMTs", group = G_SMT, tooltip = "Delete a SMT once price trades back through its level — the divergence has since been violated. On by default: a violated divergence is not context, and leaving it drawn is what makes a busy session look like a wall of SMT lines.")
int    smtMaxShow   = input.int(3, "Max SMTs per side", minval = 1, maxval = 20, group = G_SMT, tooltip = "Keep at most this many bullish and this many bearish SMTs on the chart — the oldest drop off so lines never stack up.")
bool   smtShowLabel = input.bool(true, "Show SMT labels", group = G_SMT)

bool  showDash  = input.bool(true, "Show Dashboard", group = G_SCORE)
string dashPos  = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_SCORE)
string dashSize = input.string("small", "Dashboard Text Size", options = ["tiny", "small", "normal", "large"], group = G_SCORE)

// ============================================================================
// SHARED CONTEXT & HELPERS
// ============================================================================
float atrVal   = ta.atr(14)
// No ATR in the label layer. An ATR lift is a fixed offset in PRICE, so the gap it leaves shrinks and
// grows in PIXELS every time the chart is zoomed — the label crowds its own line at one zoom and
// floats away at another. Clearance is the label STYLE's job: label_up / label_down offset in pixel
// space and hold the same visible gap at any zoom or range.
color COLOR_NONE = color.new(color.white, 100)

bool newDay  = timeframe.change("D")
bool newWeek = timeframe.change("W")

//@function Auto-pairs the SMT peer from the chart symbol so the same divergence reads on
//          either side of a pair — NQ↔ES, YM→ES, GC→SI, and their micros. Returns na when
//          the symbol has no known pairing (the caller falls back to the chart itself).
//@returns (string) The paired symbol, or na.
smtAutoPeer() =>
    string t = syminfo.ticker
    string res = na
    string m = str.match(t, "^M?(ES|NQ)[1\\w][!\\d]+$")
    if m != ''
        int off = str.startswith(m, "M") ? 1 : 0
        string prefix = str.substring(m, off, 2 + off)
        string suffix = str.substring(m, 2 + off)
        res := "CME_MINI:" + (off == 1 ? "M" : "") + (prefix == "NQ" ? "ES" : "NQ") + suffix
    else if str.contains(t, "MYM")
        res := "CME_MINI:MES1!"
    else if str.contains(t, "YM")
        res := "CME_MINI:ES1!"
    // Metals — prefix inherited from the chart, so the pair follows the chart's own listing.
    else if str.contains(t, "MGC")
        res := syminfo.prefix + ":SIL1!"
    else if str.contains(t, "GC")
        res := syminfo.prefix + ":SI1!"
    else if str.contains(t, "SIL")
        res := syminfo.prefix + ":MGC1!"
    else if str.contains(t, "SI")
        res := syminfo.prefix + ":GC1!"
    // Spot metals — the branches above match contract tickers only.
    else if str.contains(t, "XAU")
        res := syminfo.prefix + ":" + str.replace(t, "XAU", "XAG", 0)
    else if str.contains(t, "XAG")
        res := syminfo.prefix + ":" + str.replace(t, "XAG", "XAU", 0)
    res

//@variable The resolved SMT peer — the user's symbol if set, else the auto-pair, else the
//          chart itself (which harmlessly yields no divergence rather than erroring).
var string smtAuto = smtAutoPeer()
var string smtPeer = smtSymbol != "" ? smtSymbol : (not na(smtAuto) ? smtAuto : syminfo.tickerid)

// Peer OHLC the sweep-based SMT compares swing-by-swing against the chart symbol.
// ignore_invalid_symbol: an unresolvable peer returns na instead of killing the whole indicator.
[smtHH, smtLL, smtOO, smtCC] = request.security(smtPeer, timeframe.period, [high, low, open, close], ignore_invalid_symbol = true)

// The SMT draw and validation walk back through these series at dynamic offsets of up to
// ~5000 bars. The history buffer is scoped to exactly these five series — a script-wide
// max_bars_back in indicator() would buffer EVERY series that deep and pay for it in memory.
max_bars_back(high, 5000)
max_bars_back(low, 5000)
max_bars_back(time, 5000)
max_bars_back(smtHH, 5000)
max_bars_back(smtLL, 5000)

//@variable Short display name of the SMT peer (ticker after the exchange prefix). This IS the SMT label —
//          the divergence line already says what it is, so the label only has to name the other instrument.
var array<string> smtParts = str.split(smtPeer, ":")
string smtName = smtParts.size() > 0 ? array.get(smtParts, smtParts.size() - 1) : smtPeer

//@function Short tag for the chart timeframe — the "M" (minutes) / "H" (hours) /
//          "D" marker shown on each PD array.
//@returns (string) e.g. "M5", "M15", "H1", "H4", "D".
tfTag() =>
    string tag = switch
        timeframe.isseconds                                    => "S" + str.tostring(timeframe.multiplier)
        timeframe.isminutes and timeframe.multiplier % 60 == 0 => "H" + str.tostring(timeframe.multiplier / 60)
        timeframe.isminutes                                    => "M" + str.tostring(timeframe.multiplier)
        timeframe.isdaily                                      => "D"
        timeframe.isweekly                                     => "W"
        timeframe.ismonthly                                    => "MN"
        =>                                                        timeframe.period
    tag

//@function Resolves a size-name string to a Pine size constant.
//@param s (string) One of "tiny" / "small" / "normal" / "large".
//@returns (string) The matching size.* constant.
sizeFromStr(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

string levelLabelSize = sizeFromStr(levelLabelSz)
string zoneLabelSize  = sizeFromStr(zoneLabelSz)
string eventLabelSize = sizeFromStr(eventLabelSz)

color bullTxt = color.new(bullZoneCol, 0)
color bearTxt = color.new(bearZoneCol, 0)

//@function Line-label (text only, colour-matched), anchored at the right edge.
mkLineLabel(int x, float y, string txt, color col, string sz) =>
    label l = label.new(x, y, txt, xloc.bar_index, yloc.price, color(na), label.style_label_left, col, sz)
    label.set_text_font_family(l, font.family_monospace)
    l

//@function Box label centred exactly on its anchor (label_center, no bubble).
mkBoxLabel(int x, float y, string txt, color col, string sz) =>
    label l = label.new(x, y, txt, xloc.bar_index, yloc.price, color(na), label.style_label_center, col, sz)
    label.set_text_font_family(l, font.family_monospace)
    l

var int lastBuysideRaidBar = na
var string lastBuysideRaidName = ""
var string lastSellsideRaidName = ""
var int lastSellsideRaidBar = na

// ============================================================================
// MODULE 1 — KILLZONE WINDOWS (gate only) + SESSION H/L CAPTURE
// ============================================================================
bool inAsiaS = not na(time(timeframe.period, sessAsia, tzInput))
bool inLonS  = not na(time(timeframe.period, sessLonHL, tzInput))
bool inNyS   = not na(time(timeframe.period, sessNyHL, tzInput))

// ── Session source timeframe ─────────────────────────────────────────────────
// Session extremes are measured on a fixed lower timeframe: session windows are shorter
// than one higher-TF candle, so chart-bar tracking would collapse a session to the range
// of whichever candle contained it. Intrabars replay through the same trackers; charts
// at or below the source timeframe track natively.
bool   sessUseLtf = timeframe.in_seconds(timeframe.period) > timeframe.in_seconds(sessSrcTf)
string sessTf     = sessUseLtf ? sessSrcTf : timeframe.period
[ltfHi, ltfLo, ltfOpen, ltfAsia, ltfLon, ltfNy, ltfMidnight, ltfKzLon, ltfKzAm, ltfKzPm] = request.security_lower_tf(syminfo.tickerid, sessTf, [high, low, open, not na(time(timeframe.period, sessAsia, tzInput)), not na(time(timeframe.period, sessLonHL, tzInput)), not na(time(timeframe.period, sessNyHL, tzInput)), hour(time, tzInput) == 0 and (na(time[1]) or hour(time[1], tzInput) != 0), not na(time(timeframe.period, sessLondon, tzInput)), not na(time(timeframe.period, sessNYAM, tzInput)), not na(time(timeframe.period, sessNYPM, tzInput))], ignore_invalid_timeframe = true)

// ── Killzone windows (gate only) ─────────────────────────────────────────────
// Judged from the source timeframe on the candle's LAST intrabar — its close — since the
// grade is struck at close. A higher-TF candle merely overlapping a killzone would
// otherwise read as fully inside it. Charts fine enough to resolve the window natively
// read their own bars.
bool inLondonKZ = false
bool inNYAMKZ   = false
bool inNYPMKZ   = false
if sessUseLtf and ltfKzLon.size() > 0
    int lastItb = ltfKzLon.size() - 1
    inLondonKZ := ltfKzLon.get(lastItb)
    inNYAMKZ   := ltfKzAm.get(lastItb)
    inNYPMKZ   := ltfKzPm.get(lastItb)
else
    inLondonKZ := not na(time(timeframe.period, sessLondon, tzInput))
    inNYAMKZ   := not na(time(timeframe.period, sessNYAM, tzInput))
    inNYPMKZ   := not na(time(timeframe.period, sessNYPM, tzInput))
bool inAnyKZ     = inLondonKZ or inNYAMKZ or inNYPMKZ

// ── Midnight Open (00:00 NY) — daily reference + bias anchor ─────────────────
// The 00:00 NY open is a core ICT reference: trading BELOW it leans the day
// bullish (price is discounted vs the daily open), ABOVE it leans bearish. It
// is a reference midline, so it draws DOTTED. Reset on the first bar of NY 00:00.
//
// Only a chart whose candles align to 00:00 can see that open on its own bars — a 4-hour
// futures candle opens at 18:00 / 22:00 / 02:00, so an hour test against the chart's bars
// never fires there and the reference would silently go missing. It is therefore read from
// the session source timeframe, the same stream the session extremes come from, and falls
// back to the chart's own bars whenever they already resolve it.
var float midnightOpen = na
var line  mnLine  = na
var label mnLabel = na
bool  mnNative  = hour(time, tzInput) == 0 and (na(time[1]) or hour(time[1], tzInput) != 0)
bool  newMidnight = false
float newMnOpen   = na
if timeframe.isintraday
    if sessUseLtf
        if ltfMidnight.size() > 0
            for k = 0 to ltfMidnight.size() - 1
                if ltfMidnight.get(k) and not newMidnight
                    newMidnight := true
                    newMnOpen   := ltfOpen.get(k)
    else
        newMidnight := mnNative
        newMnOpen   := open
// The opens project well past the PD arrays' live edge and their tags, in their own
// lane: Midnight Open first, Weekly Open one rank further right. Both follow the
// right-side offset so the lane moves with it.
const int MN_GAP = 19
const int WK_GAP = 25
int mnX = bar_index + rightOffset + MN_GAP
int wkX = bar_index + rightOffset + WK_GAP
if barstate.isconfirmed
    if newMidnight
        midnightOpen := newMnOpen
        if showMidnight
            line.delete(mnLine)
            label.delete(mnLabel)
            mnLine := line.new(bar_index, midnightOpen, mnX, midnightOpen, xloc = xloc.bar_index, color = midnightCol, style = line.style_dotted, width = 1)
            mnLabel := mkLineLabel(mnX, midnightOpen, "Midnight Open", midnightCol, levelLabelSize)
    if not na(mnLine)
        line.set_x2(mnLine, mnX)
    if not na(mnLabel)
        label.set_x(mnLabel, mnX)

// ── Weekly Open — the week's opening print, a reference level ────────────────
// Read from the weekly candle rather than tracked from a week-change on the chart's
// own bars: the period open is fixed from the first bar of the week, so it is known
// on bar one of the script instead of only after the first rollover it happens to
// see. lookahead is safe for exactly that reason — a period's OPEN cannot change
// once the period has begun, so there is no future value to leak.
//
// It is drawn, not scored. The ICT Bias stays the dealing range plus the Midnight
// Open; folding a third reference into it would quietly change the read every
// existing user already reconciles against their own chart.
float weekOpenSrc = request.security(syminfo.tickerid, "W", open, lookahead = barmerge.lookahead_on)
var float weeklyOpen = na
var line  wkLine  = na
var label wkLabel = na
if barstate.isconfirmed
    if showWeekOpen and not na(weekOpenSrc)
        // Redraw on the week's first bar. The price test alone would miss a week that
        // happened to open at the previous week's exact open, leaving the line anchored
        // a week behind — newWeek is what actually says "new week".
        if newWeek or na(weeklyOpen) or weekOpenSrc != weeklyOpen
            weeklyOpen := weekOpenSrc
            line.delete(wkLine)
            label.delete(wkLabel)
            wkLine  := line.new(bar_index, weeklyOpen, wkX, weeklyOpen, xloc = xloc.bar_index, color = weekOpenCol, style = line.style_dotted, width = 1)
            wkLabel := mkLineLabel(wkX, weeklyOpen, "Weekly Open", weekOpenCol, levelLabelSize)
        if not na(wkLine)
            line.set_x2(wkLine, wkX)
        if not na(wkLabel)
            label.set_x(wkLabel, wkX)
    else if not na(wkLine)
        // Switched off — clear it rather than leaving a stranded line behind.
        line.delete(wkLine)
        label.delete(wkLabel)
        wkLine  := line(na)
        wkLabel := label(na)
        weeklyOpen := na

//@type Forming-period tracker — records the ORIGIN BAR of the running high/low.
type Trk
    bool  active = false
    float hi = na
    float lo = na
    int   hiBar = na
    int   loBar = na
    float cHi = na
    float cLo = na
    int   cHiBar = na
    int   cLoBar = na

//@type One horizontal liquidity level. `fam` groups a level with its own kind, `disp` is the
//      shown text, and `lifeDays` is how many days it stays on the chart. Solid while live;
//      dotted + faded + a ✓ once swept.
type Level
    float  price
    int    originBar
    bool   isHigh
    string fam
    string disp
    color  col
    bool   swept = false
    int    bornBar = na
    int    bornDay = na
    int    lifeDays = na
    int    rank = 0
    line   ln = na
    label  chk = na

method roll(Trk t, bool isRoll) =>
    bool done = false
    if isRoll and not na(t.hi)
        t.cHi := t.hi
        t.cLo := t.lo
        t.cHiBar := t.hiBar
        t.cLoBar := t.loBar
        done := true
    if isRoll or na(t.hi)
        t.hi := high
        t.lo := low
        t.hiBar := bar_index
        t.loBar := bar_index
    else
        if high > t.hi
            t.hi := high
            t.hiBar := bar_index
        if low < t.lo
            t.lo := low
            t.loBar := bar_index
    done

//@function Advances a session tracker by one reading — a chart candle, or one intrabar of
//          the session source timeframe. The origin bar is passed in so the level still
//          anchors to the chart candle that formed the extreme.
//@param inWin (bool) Whether this reading falls inside the session window.
//@param h (float) Reading high.
//@param l (float) Reading low.
//@param bIdx (int) Chart bar index to anchor an extreme to.
//@returns (bool) True on the reading that closes the session.
method sess(Trk t, bool inWin, float h, float l, int bIdx) =>
    bool done = false
    if inWin
        if not t.active
            t.active := true
            t.hi := h
            t.lo := l
            t.hiBar := bIdx
            t.loBar := bIdx
        else
            if h > t.hi
                t.hi := h
                t.hiBar := bIdx
            if l < t.lo
                t.lo := l
                t.loBar := bIdx
    else if t.active
        t.cHi := t.hi
        t.cLo := t.lo
        t.cHiBar := t.hiBar
        t.cLoBar := t.loBar
        t.active := false
        done := true
    done

var array<Level> levels = array.new<Level>()

//@function Deletes a level's drawings (line + any ✓).
delLevel(Level lv) =>
    line.delete(lv.ln)
    label.delete(lv.chk)
    true

//@variable Days elapsed on the chart, stamped onto each level so it can be retired by age.
var int dayCount = 0

//@function Retires levels that have aged past their lookback window — the "back" inputs are
//          a window in days, not a running count.
//@returns (bool) Always true.
expireLevels() =>
    if levels.size() > 0
        for i = levels.size() - 1 to 0
            Level lv = levels.get(i)
            if not na(lv.bornDay) and not na(lv.lifeDays) and dayCount - lv.bornDay >= lv.lifeDays
                delLevel(lv)
                levels.remove(i)
    true

//@function Draws a solid level line from the candle that formed it, extended past price.
//          Near-duplicates within levelMinGap × ATR resolve by significance: a new level is
//          blocked by an equal-or-higher-ranked live level and displaces lesser ones. Ranking
//          matters because a weekly high often sits at the same price as a daily high inside
//          it. Labels are handled by the combine-pass.
//@param lifeDays (int) How many days the level stays on the chart before it is retired.
//@param rank (int) Significance — weekly 3, prior-day 2, session 1.
addLevel(float price, int originBar, bool isHigh, string fam, string disp, color col, int width, int lifeDays, int rank) =>
    float gap = atrVal * levelMinGap
    bool  blocked = false
    if levelMinGap > 0.0 and levels.size() > 0
        for i = levels.size() - 1 to 0
            Level ex = levels.get(i)
            if not ex.swept and math.abs(ex.price - price) <= gap and ex.rank >= rank
                blocked := true
    if not blocked
        // Nothing of equal or greater significance is sitting here, so any lesser
        // near-duplicate steps aside for this level rather than blocking it.
        if levelMinGap > 0.0 and levels.size() > 0
            for i = levels.size() - 1 to 0
                Level ex = levels.get(i)
                if not ex.swept and math.abs(ex.price - price) <= gap
                    delLevel(ex)
                    levels.remove(i)
        Level lv = Level.new(price, originBar, isHigh, fam, disp, col)
        lv.bornBar := bar_index
        lv.bornDay := dayCount
        lv.lifeDays := lifeDays
        lv.rank := rank
        lv.ln := line.new(originBar, price, bar_index + rightOffset, price, xloc = xloc.bar_index, color = col, style = line.style_solid, width = width)
        levels.push(lv)
        while levels.size() > 60
            delLevel(levels.shift())
    true

//@function Extends each live level and MITIGATES it the instant price touches it — a wick to
//          a high (buyside) or a low (sellside). A mitigated level stops extending at the
//          candle that took it and turns dotted. Live levels keep tracking the right edge.
//@returns ([bool, bool, string, string]) Whether a buyside / sellside raid completed here,
//          and the display name of the raided level on each side ("" when none).
scanLevels() =>
    bool raidedUp = false
    bool raidedDn = false
    string upName = ""
    string dnName = ""
    if levels.size() > 0
        for i = levels.size() - 1 to 0
            Level lv = levels.get(i)
            if not lv.swept
                bool fresh = na(lv.bornBar) or bar_index > lv.bornBar   // never mitigate on its own birth bar
                bool touched = fresh and (lv.isHigh ? high >= lv.price : low <= lv.price)
                if touched
                    // A close back through it is a raid (feeds the Sweep confluence); a clean
                    // break simply mitigates. Either way the level freezes here.
                    if lv.isHigh and close < lv.price
                        raidedUp := true
                        upName := lv.disp
                    else if (not lv.isHigh) and close > lv.price
                        raidedDn := true
                        dnName := lv.disp
                    lv.swept := true
                    if not na(lv.ln)
                        line.set_x2(lv.ln, bar_index)                        // stop extending
                        line.set_style(lv.ln, line.style_dotted)
                        line.set_color(lv.ln, color.new(lv.col, levelDim))
                        // A tiny ✗ at the middle of the frozen run, hung on the OUTSIDE of
                        // the level — the label styles point AT the price, so a high takes
                        // style_label_down (body above the line) and a low style_label_up.
                        // The mark never covers the line it is describing.
                        if sweptMark
                            lv.chk := label.new(int(math.avg(lv.originBar, bar_index)), lv.price, "✗", xloc.bar_index, yloc.price, color(na), lv.isHigh ? label.style_label_down : label.style_label_up, C_INK, size.tiny)
                            label.set_text_font_family(lv.chk, font.family_monospace)
                else if not na(lv.ln)
                    line.set_x2(lv.ln, bar_index + rightOffset)
    [raidedUp, raidedDn, upName, dnName]

var Trk dayTrk  = Trk.new()
var Trk weekTrk = Trk.new()
var Trk asiaTrk = Trk.new()
var Trk lonTrk  = Trk.new()
var Trk nyTrk   = Trk.new()

if barstate.isconfirmed and timeframe.isintraday
    if newDay
        dayCount += 1
        expireLevels()
    if dayTrk.roll(newDay) and showPD
        string dt = str.format_time(time[1], "dd/MM", tzInput)
        addLevel(dayTrk.cHi, dayTrk.cHiBar, true,  "PDH", "PDH " + dt, lvlColor, lvlWidth, pdDaysBack, 2)
        addLevel(dayTrk.cLo, dayTrk.cLoBar, false, "PDL", "PDL " + dt, lvlColor, lvlWidth, pdDaysBack, 2)
    if weekTrk.roll(newWeek) and showPW
        string wt = str.format_time(time[1], "dd/MM", tzInput)
        addLevel(weekTrk.cHi, weekTrk.cHiBar, true,  "PWH", "PWH " + wt, lvlColor, lvlWidth, pwWeeksBack * 7, 3)
        addLevel(weekTrk.cLo, weekTrk.cLoBar, false, "PWL", "PWL " + wt, lvlColor, lvlWidth, pwWeeksBack * 7, 3)
    // Replay the source-timeframe intrabars through the trackers (or the chart candle
    // itself when the chart is already at or below the source timeframe).
    bool asiaDone = false
    bool lonDone  = false
    bool nyDone   = false
    if sessUseLtf
        int nItb = ltfHi.size()
        if nItb > 0
            for k = 0 to nItb - 1
                float ih = ltfHi.get(k)
                float il = ltfLo.get(k)
                if asiaTrk.sess(ltfAsia.get(k), ih, il, bar_index)
                    asiaDone := true
                if lonTrk.sess(ltfLon.get(k), ih, il, bar_index)
                    lonDone := true
                if nyTrk.sess(ltfNy.get(k), ih, il, bar_index)
                    nyDone := true
    else
        asiaDone := asiaTrk.sess(inAsiaS, high, low, bar_index)
        lonDone  := lonTrk.sess(inLonS, high, low, bar_index)
        nyDone   := nyTrk.sess(inNyS, high, low, bar_index)
    if asiaDone and showSess and showAsiaS
        addLevel(asiaTrk.cHi, asiaTrk.cHiBar, true,  "Asia High", "Asia High", sessColor, sessWidth, sessDaysBack, 1)
        addLevel(asiaTrk.cLo, asiaTrk.cLoBar, false, "Asia Low",  "Asia Low",  sessColor, sessWidth, sessDaysBack, 1)
    if lonDone and showSess and showLonS
        addLevel(lonTrk.cHi, lonTrk.cHiBar, true,  "London High", "London High", sessColor, sessWidth, sessDaysBack, 1)
        addLevel(lonTrk.cLo, lonTrk.cLoBar, false, "London Low",  "London Low",  sessColor, sessWidth, sessDaysBack, 1)
    if nyDone and showSess and showNyS
        addLevel(nyTrk.cHi, nyTrk.cHiBar, true,  "NY High", "NY High", sessColor, sessWidth, sessDaysBack, 1)
        addLevel(nyTrk.cLo, nyTrk.cLoBar, false, "NY Low",  "NY Low",  sessColor, sessWidth, sessDaysBack, 1)
    [lvUp, lvDn, lvUpNm, lvDnNm] = scanLevels()
    if lvUp
        lastBuysideRaidBar := bar_index
        lastBuysideRaidName := lvUpNm
    if lvDn
        lastSellsideRaidBar := bar_index
        lastSellsideRaidName := lvDnNm

// ============================================================================
// MODULE 2 — SWING STRUCTURE
// ----------------------------------------------------------------------------
// Everything downstream is built from swings: equal highs are clustered pivots and
// SMT compares pivots across markets. The dealing-range equilibrium that separates
// premium from discount is taken from a fixed HTF window (weekly on 1H+, daily below).
// ============================================================================
float ph = ta.pivothigh(high, pivLeft, pivRight)
float pl = ta.pivotlow(low, pivLeft, pivRight)
bool newPH = not na(ph)
bool newPL = not na(pl)
int phBar = bar_index - pivRight
int plBar = bar_index - pivRight

// Each swing is armed when its pivot confirms and consumed by the first confirmed close
// through it (the MSS check in Module 4). A pivot cannot confirm already-broken — its
// confirming right-hand bars stayed on the near side.
var float lastSwingHigh  = na
var float lastSwingLow   = na
var bool  swingHighArmed = false
var bool  swingLowArmed  = false
// The swing's BAR as well as its price — the block search below is scoped by it.
var int   lastSwingHighBar = na
var int   lastSwingLowBar  = na
if barstate.isconfirmed
    if newPH
        lastSwingHigh := ph
        lastSwingHighBar := phBar
        swingHighArmed := true
    if newPL
        lastSwingLow := pl
        lastSwingLowBar := plBar
        swingLowArmed := true
// The bars between a pivot and its confirmation, for the breaker candle: an old level run
// inside that window is a sweep the candidate must already carry when it arms.
float hiSincePiv = ta.highest(high, pivRight)
float loSincePiv = ta.lowest(low, pivRight)
// Close-based twins, for the breaker's run test. Called unconditionally at global scope
// like the pair above — a ta.* call made inside a branch skips bars and returns a
// different number from the same input.
float hiCloseSincePiv = ta.highest(close, pivRight)
float loCloseSincePiv = ta.lowest(close, pivRight)

// ── Dealing range — a fixed higher-TF window rather than the latest swing: the WEEKLY range
//    on 1H-and-up charts, the DAILY range on anything intraday below 1H. Premium/discount is
//    then judged off the range price is actually dealing within. Tracked natively on the chart
//    (running high/low, reset at the period boundary) so there is no repaint from a HTF fetch.
bool  drUseWeekly = timeframe.in_seconds(timeframe.period) >= 3600
var float drHi = na
var float drLo = na
if barstate.isconfirmed
    bool drNew = drUseWeekly ? newWeek : newDay
    if drNew or na(drHi)
        drHi := high
        drLo := low
    else
        drHi := math.max(drHi, high)
        drLo := math.min(drLo, low)

float equilibrium = not na(drHi) and not na(drLo) and drHi > drLo ? math.avg(drHi, drLo) : na

// ── Recent raids ────────────────────────────────────────────────────────────
// Both markers are set above, so these read this bar.
bool buysideRaidRecent = not na(lastBuysideRaidBar) and bar_index - lastBuysideRaidBar <= sweepMemory
bool sellsideRaidRecent = not na(lastSellsideRaidBar) and bar_index - lastSellsideRaidBar <= sweepMemory

// ── ICT bias ────────────────────────────────────────────────────────────────
// Two votes: price against the Midnight Open, and price against the dealing range's
// equilibrium. Computed here rather than in the dashboard so it sits above everything that reads
// it.
bool mnBull = not na(midnightOpen) and close < midnightOpen
bool mnBear = not na(midnightOpen) and close > midnightOpen
bool pdBull = not na(equilibrium) and close < equilibrium
bool pdBear = not na(equilibrium) and close > equilibrium
int  biasBull = (mnBull ? 1 : 0) + (pdBull ? 1 : 0)
int  biasBear = (mnBear ? 1 : 0) + (pdBear ? 1 : 0)
string ictBias = biasBull > biasBear ? (biasBull >= 2 ? "BULLISH" : "Bull lean") : biasBear > biasBull ? (biasBear >= 2 ? "BEARISH" : "Bear lean") : "MIXED"

// ── OTE on the swing leg ─────────────────────────────────────────────────────
// Measured the way it is drawn by hand: from the leg's start to its end, with the retracement
// read back from the END. The last confirmed swing low and swing high are the leg, and whichever
// printed later is its end — so a leg that ran up retraces down into discount, and one that ran
// down retraces up into premium. The leg's own direction IS the band's direction; nothing else
// has to decide it, and it cannot point somewhere the leg does not. A dotted grey line spans the
// leg, so the two candles the band came from and the way it ran are both readable. Blackish grey,
// because a retracement is a measurement and not a directional array. Drawn on the last bar only,
// and beginning where the leg completes: a retracement does not exist until both ends of it do.
var box   oteBx  = na
var label oteLbl = na
var line  oteLegLn = na
if barstate.islast
    bool oteOk = showOTE and not na(lastSwingHigh) and not na(lastSwingLow) and not na(lastSwingHighBar) and not na(lastSwingLowBar) and lastSwingHigh > lastSwingLow
    if oteOk
        float oteRng    = lastSwingHigh - lastSwingLow
        bool  oteLegUp  = lastSwingHighBar > lastSwingLowBar
        float oteAnchor = oteLegUp ? lastSwingHigh : lastSwingLow
        float oteE1     = oteLegUp ? oteAnchor - oteFrom * oteRng : oteAnchor + oteFrom * oteRng
        float oteE2     = oteLegUp ? oteAnchor - oteTo * oteRng : oteAnchor + oteTo * oteRng
        float oteTop    = math.max(oteE1, oteE2)
        float oteBot    = math.min(oteE1, oteE2)
        int   oteL      = math.max(lastSwingHighBar, lastSwingLowBar)
        int   oteR      = bar_index + rightOffset
        color oteFill   = color.new(oteCol, 80)
        int   legX1 = oteLegUp ? lastSwingLowBar : lastSwingHighBar
        float legY1 = oteLegUp ? lastSwingLow : lastSwingHigh
        int   legX2 = oteLegUp ? lastSwingHighBar : lastSwingLowBar
        float legY2 = oteLegUp ? lastSwingHigh : lastSwingLow
        if na(oteBx)
            oteBx  := box.new(oteL, oteTop, oteR, oteBot, border_color = oteFill, border_width = 1, border_style = line.style_solid, bgcolor = oteFill)
            oteLbl := mkLineLabel(oteR, math.avg(oteTop, oteBot), "OTE", C_INK, zoneLabelSize)
            oteLegLn := line.new(legX1, legY1, legX2, legY2, xloc = xloc.bar_index, color = C_MID, width = 1, style = line.style_dotted)
        else
            box.set_lefttop(oteBx, oteL, oteTop)
            box.set_rightbottom(oteBx, oteR, oteBot)
            box.set_border_color(oteBx, oteFill)
            box.set_bgcolor(oteBx, oteFill)
            label.set_xy(oteLbl, oteR, math.avg(oteTop, oteBot))
            line.set_xy1(oteLegLn, legX1, legY1)
            line.set_xy2(oteLegLn, legX2, legY2)
    else
        box.delete(oteBx)
        label.delete(oteLbl)
        line.delete(oteLegLn)
        oteBx  := na
        oteLbl := na
        oteLegLn := na

// ── Shared PD-array respect rule (see Module 4) ──────────────────────────────
// One rule for every gap and order block: wicks trade anywhere, bodies decide. A
// support array (bullish) is respected while bodies close above its consequent
// encroachment, a resistance array (bearish) while they close below it.
bool  mitRemove = mitAction == "Remove"

//@function True when this bar's wick traded into the zone — the touch that respects it,
//          provided the body held.
//@param top (float) Zone top.
//@param bottom (float) Zone bottom.
//@param isSupport (bool) True for a bullish/support array (price approaches from above).
//@returns (bool) Wick inside the zone this bar.
zoneTouched(float top, float bottom, bool isSupport) =>
    isSupport ? low <= top : high >= bottom

//@function True when this bar's body closed past the zone's consequent encroachment —
//          the close that disrespects it.
//@param top (float) Zone top.
//@param bottom (float) Zone bottom.
//@param isSupport (bool) True for a bullish/support array.
//@returns (bool) Close on the wrong side of the midpoint.
bodyPastCE(float top, float bottom, bool isSupport) =>
    float ce = math.avg(top, bottom)
    isSupport ? close < ce : close > ce

//@function The one glyph a zone box carries: a bold ✓ once respected, a bold ✗ once
//          disrespected. Sits at the RIGHT end of the box — the live edge, in the clear
//          space past the last candle, while the zone is live; the disrespecting candle
//          once it has faded. Full black, label size, bold: it has to read from across
//          the chart, not be hunted for at the origin.
//@param bx (box) The zone's box.
//@param glyph (string) "✓" or "✗".
//@returns (bool) Always true.
setBoxGlyph(box bx, string glyph) =>
    if not na(bx)
        box.set_text(bx, glyph)
        box.set_text_color(bx, C_INK)
        box.set_text_size(bx, zoneLabelSize)
        box.set_text_formatting(bx, text.format_bold)
        box.set_text_halign(bx, text.align_right)
        box.set_text_valign(bx, text.align_center)
        box.set_text_font_family(bx, font.family_monospace)
    true

//@function A bold ✓ label for a block, at the RIGHT end of the block on its consequent
//          encroachment — a block carries its name as box text or a ray tag, so its tick
//          is its own object, and it moves with the live edge every bar. In ray mode it
//          hangs just INSIDE the end (the tag hangs off the end to the right); in zone
//          mode just OUTSIDE the box (the tag sits inside it). Either way the two never
//          overlap, whatever the block's height.
//@param x (int) The block's live edge — bar_index + rightOffset.
//@param y (float) The block's consequent encroachment.
//@param style (string) label.style_label_right for rays, label.style_label_left for a zone.
//@returns (label) The tick.
mkTick(int x, float y, string style) =>
    label l = label.new(x, y, "✓", xloc.bar_index, yloc.price, color(na), style, C_INK, zoneLabelSize)
    label.set_text_font_family(l, font.family_monospace)
    label.set_text_formatting(l, text.format_bold)
    l

//@function Applies the disrespected grammar to a PD-array box: freeze at the candle whose
//          body closed past the consequent encroachment, dotted + faint fill, name gone,
//          a single small ✗ as box text. No label object remains on a faded zone.
//@param bx (box) The array's box.
//@param lbl (label) The array's text label — deleted here.
//@param isBull (bool) Array polarity — drives the fade colour.
//@param baseOverride (color) Fade against this colour instead of the directional pair.
//        An inversion is not bullish or bearish — it fades in its own colour, and
//        without this it would fade back into purple or magenta at the last moment.
//@returns (label) na — faded zones carry no label object.
// A default must be a plain literal — `color(na)` is a function call and fails to
// compile with CE10133. Bare `na` is fine: the parameter's declared type is what
// makes it a colour, so nothing is ambiguous about it.
fadeArrayBox(box bx, label lbl, bool isBull, color baseOverride = na) =>
    color base = na(baseOverride) ? (isBull ? bullZoneCol : bearZoneCol) : baseOverride
    color fill = color.new(base, zoneFade)
    color brd  = color.new(base, math.round(zoneFade * 0.4))
    label.delete(lbl)
    if not na(bx)
        box.set_right(bx, bar_index)  // freeze origin → the disrespecting candle, no live-looking stub
        box.set_bgcolor(bx, fill)
        box.set_border_color(bx, brd)
        box.set_border_style(bx, line.style_dotted)
    setBoxGlyph(bx, "✗")
    label(na)

// ============================================================================
// MODULE 4 — PD ARRAYS (FVG · VOLUME IMBALANCE · ORDER BLOCK · BREAKER)
// ----------------------------------------------------------------------------
// Zone lifecycle: solid while live with a centred label; on mitigation the
// box freezes, fades and carries "✓ name" as box text. Where zones overlap the
// largest wins. OB = body of the origin candle; a Breaker always expands to the
// full candle, wick to wick — the displacement is already proven by its FVG. A OB requires a structure
// break (MSS) AND a FVG left by its displacement leg. A Suspension Block — a stacked leg
// whose bodies never trade back through it — runs through the same pipeline as FVGs.
// A new gap removes any live opposite-direction gap it overlaps.
// ============================================================================
//@variable Oldest any array may be, in bars. A drawing re-anchored on an origin further back
//          than the chart's history buffer is a runtime error, so an array this old is retired.
const int ARRAY_MAX_AGE = 4800

type FVG
    float top
    float bottom
    int   bornBar
    int   leftBar
    bool  isBull
    bool  isSB = false        // Suspension Block — the whole suspended span of a stacked leg
    bool  inverted = false    // closed through and flipped — IFVG / IVI
    bool  mitigated = false   // disrespected — a body closed past the CE while inside; faded or removed
    bool  respected = false   // a wick traded in and the body held — the gap has been used
    int   fadedBar = na       // bar it faded; only the most recently faded gap of each kind is kept
    box   bx = na
    label lbl = na
    label chk = na
    line  ce = na             // consequent encroachment midline

var array<FVG> fvgs = array.new<FVG>()

//@function Deletes every drawing a gap owns — box, label, tick and midline. One
//          place to strip a gap, so a new drawing can never be left orphaned on
//          the chart by one of the several paths that remove a gap.
//@param f (FVG) The gap to strip.
//@returns (bool) Always true — called for the deletion, not the value.
delFvgDrawings(FVG f) =>
    box.delete(f.bx)
    label.delete(f.lbl)
    label.delete(f.chk)
    line.delete(f.ce)
    true

//@function A gap's live fill colour. An inversion carries its own colour and does NOT
//          join the directional pair — read the invZoneCol input's note for why. Every
//          path that paints a gap goes through here, including the per-bar repaint in
//          the cross-type declutter, which would otherwise put an inversion back to
//          purple or magenta on the very next bar.
//@param f (FVG) The gap being drawn.
//@returns (color) The fill and border colour for this gap right now.
gapCol(FVG f) =>
    f.inverted ? invZoneCol : f.isBull ? bullZoneCol : bearZoneCol

//@function The one wording for a gap: kind, polarity and timeframe. An inverted gap
//          reads by its LIVE polarity, which is the opposite of the gap that made it.
//@param isSB (bool) True for a Suspension Block rather than a true FVG.
//@param inverted (bool) True once price has closed through and flipped it.
//@param asBull (bool) The gap's live polarity.
//@returns (string) e.g. "BISI + M15", "IFVG - M15", "SB + M15".
gapTag(bool isSB, bool inverted, bool asBull) =>
    string kind = inverted ? (isSB ? "ISB" : "IFVG") : (isSB ? "SB" : (asBull ? "BISI" : "SIBI"))
    kind + (asBull ? " +" : " -") + " " + tfTag()
//@variable Born-bar of the most recent true bull FVG — the proof a displacement leg gapped.
//          Recorded at detection whether or not the box survives declutter: the delivery
//          happened, and that is what validates an order block. VIs do not count.
var int lastBullFvgBirth = na
//@variable Born-bar of the most recent true bear FVG.
var int lastBearFvgBirth = na

// The gap must clear the height floor AND come from a real displacement candle — the
// middle bar of the three (the one that opened the gap) must have a body of its own,
// in the gap's direction. That stops every incidental three-bar gap from registering.
float fvgDispBody = math.abs(close[1] - open[1])
bool  fvgDispOK   = fvgDispBody >= atrVal * fvgDispMult
bool bullFvgNew = barstate.isconfirmed and low > high[2] and (low - high[2]) >= atrVal * minFvgAtr and fvgDispOK and close[1] > open[1]
bool bearFvgNew = barstate.isconfirmed and high < low[2] and (low[2] - high) >= atrVal * minFvgAtr and fvgDispOK and close[1] < open[1]

// Volume Imbalance — a two-candle BODY gap the wicks still bridge: the body gap is the
// imbalance, the wick overlap distinguishes it from an opening gap.
// It is not an array of its own: it WIDENS the gap beside it, in zoneFor() below.

// A body gap across a session or weekend break is a calendar artefact, not displacement, so
// a join spanning more than one bar's worth of time is rejected. The guard is on the
// suspension block only — it is where a daily session break would otherwise manufacture one
// every single day.
float sbBarMs   = timeframe.in_seconds(timeframe.period) * 1000.0
bool  sbContig  = (time - time[1]) <= sbBarMs * 1.5 and (time[1] - time[2]) <= sbBarMs * 1.5

// Three same-direction candles, each opening beyond the previous one's close: the bodies
// never trade back through the leg at either join. That is a Volume Imbalance on both seams
// at once, joined through the middle body, and it qualifies WITHOUT a wick gap — a leg can
// be stacked enough that every wick overlaps and still never let its bodies trade back.
bool sbUpRaw = close[2] > open[2] and close[1] > open[1] and close > open and open[1] > close[2] and open > close[1]
bool sbDnRaw = close[2] < open[2] and close[1] < open[1] and close < open and open[1] < close[2] and open < close[1]

bool bullSbNew = barstate.isconfirmed and showSB and sbContig and sbUpRaw and (open - close[2]) >= atrVal * minFvgAtr
bool bearSbNew = barstate.isconfirmed and showSB and sbContig and sbDnRaw and (close[2] - open) >= atrVal * minFvgAtr

//@function Resolves the zone a qualifying displacement leg should draw.
//          A SUSPENSION BLOCK is the whole suspended span — the first candle's close to the
//          last candle's open — because the bodies never traded back through the leg at
//          either join. It is two Volume Imbalances joined through the middle body, so one
//          zone across the run is the honest shape rather than two seams drawn separately.
//          Anything else is the wick gap, widened at either seam that carries a Volume
//          Imbalance: a BODY gap the wicks still bridge is part of the same region, and the
//          wick gap on its own understates it.
//          The block's span always contains the wick gap's, so preferring it loses nothing.
//@param bull (bool) True for a bullish leg.
//@param isSb (bool) True when the leg qualified as a suspension block.
//@returns [float, float] The zone's top and bottom.
zoneFor(bool bull, bool isSb) =>
    float t = bull ? low     : low[2]
    float b = bull ? high[2] : high
    if isSb
        t := bull ? open     : close[2]
        b := bull ? close[2] : open
    else if absorbVI
        float bNewT = math.max(open,    close)
        float bNewB = math.min(open,    close)
        float bMidT = math.max(open[1], close[1])
        float bMidB = math.min(open[1], close[1])
        float bOldT = math.max(open[2], close[2])
        float bOldB = math.min(open[2], close[2])
        if bull
            if bMidB > bOldT and low[1] <= high[2]
                b := math.min(b, bOldT)
            if bNewB > bMidT and low <= high[1]
                t := math.max(t, bNewB)
        else
            if bMidT < bOldB and high[1] >= low[2]
                t := math.max(t, bOldB)
            if bNewT < bMidB and high >= low[1]
                b := math.min(b, bNewT)
    [t, b]

//@function Biggest-wins declutter for FVGs. Removes live FVGs that PRICE-overlap
//          the candidate and are smaller; returns false if an overlapping one is
//          already bigger (so the candidate is dropped).
fvgKeep(float nTop, float nBot) =>
    bool keep = true
    float nH = nTop - nBot
    if declutterPD and fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            FVG f = fvgs.get(i)
            if not f.mitigated and nTop >= f.bottom and nBot <= f.top
                if (f.top - f.bottom) >= nH
                    keep := false
                else
                    // Removal first, drawings after — `f` still holds the record, and it
                    // keeps this branch off remove()'s element return (CE10235).
                    fvgs.remove(i)
                    delFvgDrawings(f)
    keep

//@function Creates a FVG-family zone (light tint, centred label) if it survives the
//          biggest-wins declutter. Both true FVGs and Suspension Blocks come through here,
//          so both live under the same mitigation and declutter pipeline.
//@param isBull (bool) Gap polarity — true = bullish.
//@param zTop (float) Zone top.
//@param zBot (float) Zone bottom.
//@param isSB (bool) True for a Suspension Block, false for a true FVG (wick gap).
createFvg(bool isBull, float zTop, float zBot, bool isSB) =>
    // A new true FVG removes any live opposite-polarity true FVG it overlaps — that range
    // has since been delivered through the other way.
    if fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            FVG f = fvgs.get(i)
            if not f.mitigated and not f.inverted and f.isBull != isBull and zTop >= f.bottom and zBot <= f.top
                delFvgDrawings(f)
                fvgs.remove(i)
    if fvgKeep(zTop, zBot)
        int leftB = bar_index - 1
        FVG f = FVG.new(zTop, zBot, bar_index - 1, leftB, isBull)
        f.isSB := isSB
        if isSB or showFVG
            color zc = gapCol(f)
            f.bx := box.new(leftB, zTop, bar_index + rightOffset, zBot, border_color = zc, border_width = 1, border_style = line.style_solid, bgcolor = zc)
            // Caption text is BLACK. The zone's fill already carries direction; colouring
            // the name as well says it twice and costs the name its legibility.
            f.lbl := mkBoxLabel(int(math.avg(leftB, bar_index + rightOffset)), math.avg(zTop, zBot), gapTag(isSB, false, isBull), C_INK, zoneLabelSize)
            if showGapCE
                f.ce := line.new(leftB, math.avg(zTop, zBot), bar_index + rightOffset, math.avg(zTop, zBot), color = C_MID, width = 1, style = line.style_dotted)
        fvgs.push(f)
        // Not capped here. FVGs, Suspension Blocks and inversions live in this one
        // array but hold separate allowances, and a gap changes kind mid-life when it
        // inverts, so the cap is applied once at the end of the bar — see pruneGapKind.
    true

// Cap buckets: SIDE_ALL under Total; SIDE_A / SIDE_B are bullish / bearish or above / below price.
const int SIDE_ALL = 0
const int SIDE_A   = 1
const int SIDE_B   = 2

//@function Which bucket of the cap a zone is counted in under the chosen scope.
//@param isBull (bool)  The zone's LIVE direction — a breaker reads opposite to its block.
//@param top    (float) The zone's top.
//@param bottom (float) The zone's bottom.
//@returns (int) SIDE_ALL under Total; otherwise SIDE_A (bullish, or above price) or
//          SIDE_B (bearish, or below price). Above / below reads the zone's EDGES; a zone the
//          close sits inside counts on the side it is traded from — bullish below, bearish above.
capSide(bool isBull, float top, float bottom) =>
    switch capScope
        "Bullish / bearish"   => isBull ? SIDE_A : SIDE_B
        "Above / below price" => bottom > close ? SIDE_A : top < close ? SIDE_B : isBull ? SIDE_B : SIDE_A
        =>                       SIDE_ALL

//@function This gap's kind, for the per-kind cap. An inverted gap counts as an inversion
//          whichever kind it started as — it is a different array now, and that is the
//          whole reason the quotas are separate.
//@param f (FVG) The gap to classify.
//@returns (int) 0 true FVG · 1 Suspension Block · 2 inversion (IFVG / ISB).
gapKind(FVG f) =>
    f.inverted ? 2 : f.isSB ? 1 : 0

//@function Drops the oldest surplus gaps of ONE kind in ONE bucket, so FVGs, Volume
//          Imbalances and inversions each hold their own maxZones allowance. A spent gap
//          goes before a live one; otherwise the oldest goes.
//@param kind (int) The kind to prune, as gapKind() returns it.
//@param side (int) The bucket to prune, as capSide() returns it.
//@returns (bool) Always true — called for the eviction, not the value.
pruneGapKind(int kind, int side) =>
    int n = 0
    if fvgs.size() > 0
        for j = 0 to fvgs.size() - 1
            FVG g = fvgs.get(j)
            if gapKind(g) == kind and capSide(g.isBull, g.top, g.bottom) == side
                n += 1
    // n > maxZones implies at least two gaps of this kind, so the scans below are never
    // handed an empty array (a Pine `for 0 to -1` counts DOWN and would fault).
    while n > maxZones
        int drop = -1
        // Two scans, each stopping at its first hit. The array runs oldest-first, so the
        // first match IS the oldest, and every removal happens after its scan has finished.
        for j = 0 to fvgs.size() - 1
            FVG c = fvgs.get(j)
            if gapKind(c) == kind and capSide(c.isBull, c.top, c.bottom) == side and c.mitigated
                drop := j
                break
        if drop == -1
            for j = 0 to fvgs.size() - 1
                FVG c = fvgs.get(j)
                if gapKind(c) == kind and capSide(c.isBull, c.top, c.bottom) == side
                    drop := j
                    break
        if drop == -1
            break
        delFvgDrawings(fvgs.get(drop))
        fvgs.remove(drop)
        n -= 1
    true

//@function Applies the per-kind gap cap under the chosen scope — once over everything for
//          Total, once per bucket otherwise.
//@param kind (int) The kind to cap, as gapKind() returns it.
//@returns (bool) Always true.
pruneGaps(int kind) =>
    if capScope == "Total"
        pruneGapKind(kind, SIDE_ALL)
    else
        pruneGapKind(kind, SIDE_A)
        pruneGapKind(kind, SIDE_B)
    true

//@function Keeps only the most recently faded gap of each kind. A faded gap is history,
//          and one per kind is all the history the chart carries.
//@returns (bool) Always true.
dropOlderFadedGaps() =>
    int newest0 = -1
    int newest1 = -1
    int newest2 = -1
    if fvgs.size() > 0
        for j = 0 to fvgs.size() - 1
            FVG g = fvgs.get(j)
            if g.mitigated and not na(g.fadedBar)
                int k = gapKind(g)
                if k == 0
                    newest0 := math.max(newest0, g.fadedBar)
                else if k == 1
                    newest1 := math.max(newest1, g.fadedBar)
                else
                    newest2 := math.max(newest2, g.fadedBar)
        for j = fvgs.size() - 1 to 0
            FVG g = fvgs.get(j)
            if g.mitigated and not na(g.fadedBar)
                int k = gapKind(g)
                int newest = k == 0 ? newest0 : k == 1 ? newest1 : newest2
                if g.fadedBar < newest
                    fvgs.remove(j)
                    delFvgDrawings(g)
    true

// Resolved unconditionally at global scope so the reads stay on every bar.
[bullZT, bullZB] = zoneFor(true,  bullSbNew)
[bearZT, bearZB] = zoneFor(false, bearSbNew)

// A leg that qualifies as BOTH draws once, as the suspension block: the block's span always
// contains the wick gap's, so the gap would only be a smaller duplicate sitting inside it.
// `lastBullFvgBirth` is still set by the true FVG alone — a block is displacement evidence
// for the zone it draws, but the order-block sequence asks specifically for a gap, and that
// requirement is unchanged.
if bullSbNew or bullFvgNew
    if bullFvgNew
        lastBullFvgBirth := bar_index - 1
    createFvg(true, bullZT, bullZB, bullSbNew)
if bearSbNew or bearFvgNew
    if bearFvgNew
        lastBearFvgBirth := bar_index - 1
    createFvg(false, bearZT, bearZB, bearSbNew)

//@function Flips a gap price has closed through into its inversion — the FVG's
//          counterpart of the OB→Breaker flip. Polarity, colour and tag change; the
//          prices and the origin bar do not, because it is the same zone being read
//          from the other side. Mitigation resets: the inversion has not been traded
//          into yet AS an inversion, whatever price did to the gap it came from.
//@param f (FVG) The gap to flip.
//@returns (bool) Always true.
invertGap(FVG f) =>
    f.isBull    := not f.isBull
    f.inverted  := true
    f.mitigated := false
    f.respected := false
    f.fadedBar  := na
    // Restart the grace window — the bar that closed through the gap must not also be
    // allowed to count as trading into the inversion it just created.
    f.bornBar := bar_index
    if not na(f.bx)
        color zc = gapCol(f)   // inverted is already true, so this is the inversion colour
        box.set_bgcolor(f.bx, zc)
        box.set_border_color(f.bx, zc)
        box.set_border_style(f.bx, line.style_solid)
        box.set_right(f.bx, bar_index + rightOffset)
        box.set_text(f.bx, "")   // clear the ✓ or ✗ the gap carried — the inversion has earned neither yet
        // The gap may have been faded on the way here, and fading deletes the caption,
        // so the label is rebuilt rather than edited.
        label.delete(f.lbl)
        label.delete(f.chk)
        f.chk := label(na)
        f.lbl := mkBoxLabel(int(math.avg(f.leftBar, bar_index + rightOffset)), math.avg(f.top, f.bottom), gapTag(f.isSB, true, f.isBull), C_INK, zoneLabelSize)
    if not na(f.ce)
        line.set_color(f.ce, C_MID)
        line.set_x2(f.ce, bar_index + rightOffset)
    true

if barstate.isconfirmed
    if fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            FVG f = fvgs.get(i)
            bool through = f.isBull ? close < f.bottom : close > f.top
            // Same retirement as blocks: too old (an inversion counts from its flip, which
            // reset bornBar), too far from price, or past the history buffer outright.
            float gapAway  = f.isBull ? close - f.top : f.bottom - close
            bool  gapOld   = arrayMaxAge > 0 and bar_index - f.bornBar > arrayMaxAge
            bool  gapFar   = arrayMaxDist > 0.0 and gapAway > atrVal * arrayMaxDist
            if gapOld or gapFar or bar_index - f.leftBar > ARRAY_MAX_AGE
                // Same removal order as the close-through branch below, for the same reason.
                fvgs.remove(i)
                delFvgDrawings(f)
            else if through and showIFVG and not f.inverted and f.respected and not f.mitigated
                // Closed clean through a gap that had been respected — the gap failed. ICT
                // reads a failed gap as an inversion, so it flips and goes on trading as the
                // opposite array rather than being cleared off the chart. A gap run straight
                // through before it was ever respected, or one already faded, is no
                // inversion — it takes the branch below.
                invertGap(f)
            else if through
                // Inversions off, never respected, already faded, or this IS one and it has
                // now failed too.
                // One flip per gap — the second close through is the end of it.
                // `f` still holds the record, so the drawings are stripped AFTER the
                // removal: it keeps this branch off remove()'s return value, which is
                // the element and would give the chain mixed branch types (CE10235).
                fvgs.remove(i)
                delFvgDrawings(f)
            else
                if not f.mitigated
                    if not na(f.bx)
                        box.set_right(f.bx, bar_index + rightOffset)
                    if not na(f.lbl)
                        label.set_x(f.lbl, int(math.avg(f.leftBar, bar_index + rightOffset)))
                        label.set_y(f.lbl, math.avg(f.top, f.bottom))
                    // The midline follows the toggle both ways, so ticking it mid-session
                    // lights the gaps already on the chart instead of only future ones.
                    if showGapCE and na(f.ce) and not na(f.bx)
                        f.ce := line.new(f.leftBar, math.avg(f.top, f.bottom), bar_index + rightOffset, math.avg(f.top, f.bottom), color = C_MID, width = 1, style = line.style_dotted)
                    else if not showGapCE and not na(f.ce)
                        line.delete(f.ce)
                        f.ce := line(na)
                    if not na(f.ce)
                        line.set_x2(f.ce, bar_index + rightOffset)
                    // Grace: the bar after birth cannot judge the gap it just made.
                    bool graced = bar_index > f.bornBar + 1
                    if graced and bodyPastCE(f.top, f.bottom, f.isBull)
                        f.mitigated := true
                        f.fadedBar  := bar_index
                        if mitRemove
                            fvgs.remove(i)
                            delFvgDrawings(f)
                        else
                            // Pass the gap's own colour so an inversion fades orange
                            // rather than reverting to the directional pair.
                            f.chk := fadeArrayBox(f.bx, f.lbl, f.isBull, gapCol(f))
                            // The midline freezes with its zone — a live-looking line
                            // running past a spent gap is the thing this grammar avoids.
                            if not na(f.ce)
                                line.set_x2(f.ce, bar_index)
                                line.set_color(f.ce, color.new(C_MID, 80))
                    else if graced and not f.respected and zoneTouched(f.top, f.bottom, f.isBull)
                        // A wick in and the body held — respected. The one mark it earns.
                        f.respected := true
                        setBoxGlyph(f.bx, "✓")

    // Apply the per-kind cap once, after everything that can change a gap's kind or count
    // this bar: the gaps created above, and any that inverted in the loop directly above.
    dropOlderFadedGaps()
    pruneGaps(0)
    pruneGaps(1)
    pruneGaps(2)

// ── Order Block → Breaker ────────────────────────────────────────────────────
const int STAGE_PENDING_OB  = 0
const int STAGE_ACTIVE_BRKR = 1

type SmartBlock
    float top          // current top    (body while OB; full candle once breaker)
    float bottom       // current bottom
    float bodyTop
    float bodyBot
    float fullTop
    float fullBot
    bool  originOutside
    int   originBar
    int   bornBar
    bool  obIsBull
    int   stage = 0
    bool  mitigated = false   // disrespected — a body closed past the CE while inside; faded or removed
    bool  respected = false   // tested and the body held — the block has been used
    int   fadedBar = na       // bar it faded; only the most recently faded OB is kept
    int   grade = 0     // context score at birth, 0-4 — see blockGrade
    int   flipBar = na  // bar the OB became a breaker — the breaker's age runs from here
    box   bx = na
    label lbl = na
    label chk = na
    // OSOK levels mode — a block read at its levels, not painted as a zone.
    line  rayProx = na
    line  rayDist = na
    line  rayMt = na
    label rayLbl = na

//@function Deletes every drawing a block owns — zone box, labels and level rays.
//@param b (SmartBlock) The block to strip.
delBlockDrawings(SmartBlock b) =>
    box.delete(b.bx)
    label.delete(b.lbl)
    label.delete(b.chk)
    line.delete(b.rayProx)
    line.delete(b.rayDist)
    line.delete(b.rayMt)
    label.delete(b.rayLbl)

//@function The one wording for a block, whichever way it is drawn: polarity, kind
//          and timeframe. Zone mode puts this in the box caption, ray mode on the
//          right-end tag, and a faded block drops it for a single ✗.
//@param isBreaker (bool) True once the block has failed and flipped.
//@param asBull (bool) The block's LIVE polarity — a bull OB reads bearish as a breaker.
//@param grade (int) Context score to append, or -1 for none. Only shown when obShowGrade is on.
//@returns (string) e.g. "OB + 15m" or "Breaker - 15m 3/4". Polarity is the +/- suffix, the
//          same wording the gaps use — one grammar for every array on the chart.
blockTag(bool isBreaker, bool asBull, int grade = -1) =>
    string core = (isBreaker ? "Breaker" : "OB") + (asBull ? " +" : " -") + " " + tfTag()
    obShowGrade and grade >= 0 ? core + " " + str.tostring(grade) + "/4" : core

//@function Draws or refreshes a block's OSOK level rays: proximal edge solid in the
//          direction colour (the price that gets traded), distal edge solid, consequent
//          encroachment dotted grey, tag label at the right end. Polarity and tag follow
//          the stage — an active breaker reads flipped.
//@param b (SmartBlock) The block to draw.
updateBlockRays(SmartBlock b) =>
    bool asBull  = b.stage == STAGE_ACTIVE_BRKR ? not b.obIsBull : b.obIsBull
    color rayCol = color.new(asBull ? bullZoneCol : bearZoneCol, 0)
    float pxProx = asBull ? b.top : b.bottom
    float pxDist = asBull ? b.bottom : b.top
    float pxMt   = (b.top + b.bottom) / 2
    int   rayL   = math.max(b.originBar, bar_index - ARRAY_MAX_AGE)
    int   rayR   = bar_index + rightOffset
    // Built the same way as the zone-mode caption, so a level and a box say the
    // same thing: polarity and timeframe, not a bare "OB".
    string tag   = blockTag(b.stage == STAGE_ACTIVE_BRKR, asBull, b.grade)
    if na(b.rayProx)
        b.rayProx := line.new(rayL, pxProx, rayR, pxProx, color = rayCol, width = 1, style = line.style_solid)
        b.rayDist := line.new(rayL, pxDist, rayR, pxDist, color = rayCol, width = 1, style = line.style_solid)
        b.rayMt   := line.new(rayL, pxMt, rayR, pxMt, color = C_MID, width = 1, style = line.style_dotted)
        label rl = label.new(rayR, pxProx, tag, style = label.style_label_left, color = color.new(color.white, 100), textcolor = #000000, size = zoneLabelSize, textalign = text.align_left)
        label.set_text_font_family(rl, font.family_monospace)
        b.rayLbl := rl
    if not na(b.rayProx) and not na(b.rayLbl)
        line.set_xy1(b.rayProx, rayL, pxProx)
        line.set_xy2(b.rayProx, rayR, pxProx)
        line.set_color(b.rayProx, rayCol)
        line.set_xy1(b.rayDist, rayL, pxDist)
        line.set_xy2(b.rayDist, rayR, pxDist)
        line.set_color(b.rayDist, rayCol)
        line.set_xy1(b.rayMt, rayL, pxMt)
        line.set_xy2(b.rayMt, rayR, pxMt)
        label.set_xy(b.rayLbl, rayR, pxProx)
        label.set_text(b.rayLbl, tag)
        label.set_textcolor(b.rayLbl, #000000)
    true

var array<SmartBlock> blocks = array.new<SmartBlock>()
var int lastBullObTapBar = na
var int lastBearObTapBar = na
var int lastBullBrkBar = na
var int lastBearBrkBar = na

// An order block is the candle before the displacement leg, so the most recent up
// and down candle are kept — body, full range, and whether it was an outside sweep
// bar (which is what lets its breaker later use the full range).
var float dnFullHi = na
var float dnFullLo = na
var float dnBodyTop = na
var float dnBodyBot = na
var bool  dnOutside = false
var int   dnBar = na
var float upFullHi = na
var float upFullLo = na
var float upBodyTop = na
var float upBodyBot = na
var bool  upOutside = false
var int   upBar = na
var int   lastBullObOrigin = na
var int   lastBearObOrigin = na
//@type An order block candidate whose structure break has printed but whose leg has not yet
//      left its FVG — a gap needs its third candle, so it can confirm a bar or two after the
//      break. Registers when the leg gaps within the grace window; cancelled when the grace
//      expires or price closes back through the candidate.
type PendingOB
    bool  armed = false
    float bodyTop = na
    float bodyBot = na
    float fullHi = na
    float fullLo = na
    bool  outside = false
    int   obBar = na
    int   breakBar = na

var PendingOB pBullOB = PendingOB.new()
var PendingOB pBearOB = PendingOB.new()
//@variable Bars the leg is given to leave its FVG after the structure break.
const int OB_FVG_GRACE = 3
//@variable Ceiling on the block search. The window itself is the leg, so this only caps a runaway one.
const int OB_SCAN_MAX = 50
//@variable Most consecutive candles one order block may span.
const int OB_GROUP_MAX = 4

//@function Biggest-wins declutter for blocks (by current box height).
blockKeep(float nTop, float nBot) =>
    bool keep = true
    float nH = nTop - nBot
    if declutterPD and blocks.size() > 0
        for i = blocks.size() - 1 to 0
            SmartBlock b = blocks.get(i)
            if not b.mitigated and nTop >= b.bottom and nBot <= b.top
                if (b.top - b.bottom) >= nH
                    keep := false
                else
                    delBlockDrawings(b)
                    blocks.remove(i)
    keep

//@function Scores the CONTEXT a block was born into, 0-4. Placement is already proven by the
//          time this runs — the leg closed through structure and left a gap. This is the
//          separate question of whether the context around it was worth trading: liquidity
//          taken first, right side of the dealing range, real displacement away from it, and
//          a killzone birth. One point each, none weighted above another.
//@param isBullOB (bool) The block's polarity.
//@param fullTop (float) High of the origin candle.
//@param fullBot (float) Low of the origin candle.
//@returns (int) 0-4.
blockGrade(bool isBullOB, float fullTop, float fullBot) =>
    int g = 0
    if isBullOB ? sellsideRaidRecent : buysideRaidRecent
        g += 1
    // na equilibrium = no dealing range yet, so the point is not earned rather than assumed.
    if not na(equilibrium) and (isBullOB ? fullTop < equilibrium : fullBot > equilibrium)
        g += 1
    if (isBullOB ? close - fullTop : fullBot - close) >= atrVal * obDispAtr
        g += 1
    if inAnyKZ
        g += 1
    g

//@function Registers a PendingOB (BODY only) if it makes the grade and survives declutter.
createBlock(bool isBullOB, float bodyTop, float bodyBot, float fullTop, float fullBot, bool outside, int obBar) =>
    int grade = blockGrade(isBullOB, fullTop, fullBot)
    // A block is its BODY, so that is what the floor measures. A one-point body is a doji,
    // not an order block, however well it satisfies the sequence around it.
    bool bigEnough = (bodyTop - bodyBot) >= atrVal * minObAtr
    // Floor and grade both before blockKeep: a block either rejects must not evict a live
    // one on its way out.
    if bigEnough and grade >= obMinGrade and blockKeep(bodyTop, bodyBot)
        SmartBlock b = SmartBlock.new(bodyTop, bodyBot, bodyTop, bodyBot, fullTop, fullBot, outside, obBar, bar_index, isBullOB)
        b.grade := grade
        if showOB
            // One Shot One Kill block treatment, both modes. Default (obRays): the block
            // is read at its LEVELS — proximal solid, distal solid, CE dotted grey, tag
            // at the right end. Zone mode: see-through fill, hard border, caption in the
            // box at the live edge. Either way a block is a candle, never a painted slab.
            if obRays
                updateBlockRays(b)
            else
                color zc = isBullOB ? bullZoneCol : bearZoneCol
                b.bx := box.new(obBar, bodyTop, bar_index + rightOffset, bodyBot, border_color = color.new(zc, 0), border_width = 1, border_style = line.style_solid, bgcolor = color.new(zc, 90), text = blockTag(false, isBullOB, grade), text_size = zoneLabelSize, text_color = #000000, text_halign = text.align_right, text_valign = text.align_center, text_font_family = font.family_monospace)
        blocks.push(b)
        // Not capped here. Order blocks and breakers live in this one array but hold
        // separate allowances, and a block changes kind mid-life, so the cap is applied
        // once at the end of the bar instead — see pruneBlockKind.
    true

// ── The ICT breaker candle ───────────────────────────────────────────────────
// Bearish: the up-close candle group at the swing low that formed before an old high
// was run, born on the close back below that low. Bullish: the down-close group at the
// swing high before an old low was run, born on the close back above that high. One
// candidate per side — the most recent swing before the sweep. A swing that breaks with
// no run on liquidity first prints nothing: the run is what makes the candle a breaker.
type BrkCand
    bool  armed = false
    float swing = na       // the swing price the close must break
    float ref = na         // the old high (bear) / old low (bull) that must be run first
                           // — and, with the sequence on, run as a NAMED level, not a pivot
    bool  swept = false
    float bodyTop = na
    float bodyBot = na
    float fullHi = na
    float fullLo = na
    int   originBar = na

var BrkCand bearCand = BrkCand.new()
var BrkCand bullCand = BrkCand.new()
const int BRK_REACH = 3       // bars past the pivot the breaker candle may sit
const float BRK_MAX_ATR = 2.5 // a candle taller than this is displacement, not a breaker

//@function Registers a breaker straight into the active stage, drawn as a breaker from
//          birth. Grade and declutter as a block; then it lives under the breaker rules.
//@param isBullBrk (bool) The breaker's live polarity.
//@param bodyTop (float) Top of the candle group's body.
//@param bodyBot (float) Bottom of the candle group's body.
//@param fullHi (float) High of the group, wick to wick — the breaker's range.
//@param fullLo (float) Low of the group.
//@param originBar (int) First bar of the group.
createBreaker(bool isBullBrk, float bodyTop, float bodyBot, float fullHi, float fullLo, int originBar) =>
    int grade = blockGrade(isBullBrk, fullHi, fullLo)
    if grade >= obMinGrade and blockKeep(fullHi, fullLo)
        SmartBlock b = SmartBlock.new(fullHi, fullLo, bodyTop, bodyBot, fullHi, fullLo, false, originBar, bar_index, not isBullBrk)
        b.grade := grade
        b.stage := STAGE_ACTIVE_BRKR
        b.flipBar := bar_index
        if showOB
            if obRays and not brkrZone
                updateBlockRays(b)
            else
                color zc = isBullBrk ? bullZoneCol : bearZoneCol
                b.bx := box.new(math.max(originBar, bar_index - ARRAY_MAX_AGE), fullHi, bar_index + rightOffset, fullLo, border_color = color.new(zc, 30), border_width = 1, border_style = line.style_dashed, bgcolor = color.new(zc, 95), text = blockTag(true, isBullBrk, grade), text_size = zoneLabelSize, text_color = #000000, text_halign = text.align_right, text_valign = text.align_center, text_font_family = font.family_monospace)
        blocks.push(b)
    true

//@function Arms a breaker candidate off the pivot that confirmed this bar: the first
//          candle of the wanted colour at or after the pivot and its run forward, up to
//          OB_GROUP_MAX. The run stops at a displacement candle: the breaker is the
//          candles at the swing, never the leg away from it.
//@param c (BrkCand) The side's candidate.
//@param wantUp (bool) True reads up-close candles (a bearish breaker off a low).
//@param swing (float) The pivot price.
//@param ref (float) The old level that must be run.
//@param sweptNow (bool) True if that level was already run before the pivot confirmed.
armBreakerCandidate(BrkCand c, bool wantUp, float swing, float ref, bool sweptNow) =>
    int k0 = na
    for k = pivRight to math.max(pivRight - BRK_REACH, 0)
        if na(k0) and (wantUp ? close[k] > open[k] : close[k] < open[k])
            k0 := k
    float maxH = atrVal * BRK_MAX_ATR
    if not na(k0) and not na(ref) and high[k0] - low[k0] <= maxH
        int kEnd = k0
        // Same law as the order block group, measured on the whole RANGE rather than the body:
        // a breaker is read wick to wick, because all of it is suspected smart-money orders.
        // maxH stays as the absolute displacement ceiling; this adds that the run must also
        // stay similar to its own anchor instead of drifting from tiny to nearly-ceiling.
        float brkAnchor = math.max(high[k0] - low[k0], atrVal * 0.05)
        for j = 1 to OB_GROUP_MAX - 1
            int kj = k0 - j
            bool sameWay = kj >= 0 and (wantUp ? close[kj] > open[kj] : close[kj] < open[kj])
            float brkRj = kj >= 0 ? high[kj] - low[kj] : 0.0
            if sameWay and brkRj <= maxH and brkRj <= brkAnchor * grpSimilar and brkRj * grpSimilar >= brkAnchor
                kEnd := kj
            else
                break
        float fh = high[k0]
        float fl = low[k0]
        for j = kEnd to k0
            fh := math.max(fh, high[j])
            fl := math.min(fl, low[j])
        c.armed := true
        c.swing := swing
        c.ref := ref
        c.swept := sweptNow
        c.bodyTop := wantUp ? close[kEnd] : open[k0]
        c.bodyBot := wantUp ? open[k0] : close[kEnd]
        c.fullHi := fh
        c.fullLo := fl
        c.originBar := bar_index - k0
    true

//@function Drops the oldest surplus blocks of ONE kind in ONE bucket, so order blocks and
//          breakers each hold their own maxZones allowance. They share one array because a
//          breaker IS its order block after the flip. A spent block goes before a live one;
//          otherwise the oldest goes.
//@function Which bucket of the cap a block is counted in — by its LIVE direction, so a
//          breaker counts against the side it now trades as, not the block it came from.
//@param b (SmartBlock) The block.
//@returns (int) As capSide() returns it.
blockSide(SmartBlock b) =>
    bool liveBull = b.stage == STAGE_ACTIVE_BRKR ? not b.obIsBull : b.obIsBull
    capSide(liveBull, b.top, b.bottom)

//@param wantBrkr (bool) True prunes breakers, false prunes order blocks.
//@param side (int) The bucket to prune, as capSide() returns it.
//@returns (bool) Always true — called for the eviction, not the value.
pruneBlockKind(bool wantBrkr, int side) =>
    int n = 0
    if blocks.size() > 0
        for j = 0 to blocks.size() - 1
            SmartBlock b = blocks.get(j)
            if (b.stage == STAGE_ACTIVE_BRKR) == wantBrkr and blockSide(b) == side
                n += 1
    // n > maxZones implies at least two blocks of this kind, so the scans below are
    // never handed an empty array (a Pine `for 0 to -1` counts DOWN and would fault).
    while n > maxZones
        int drop = -1
        // Two scans, each stopping at its first hit. The array runs oldest-first, so the
        // first match IS the oldest, and every removal happens after its scan has finished.
        for j = 0 to blocks.size() - 1
            SmartBlock c = blocks.get(j)
            if (c.stage == STAGE_ACTIVE_BRKR) == wantBrkr and blockSide(c) == side and c.mitigated
                drop := j
                break
        if drop == -1
            for j = 0 to blocks.size() - 1
                SmartBlock c = blocks.get(j)
                if (c.stage == STAGE_ACTIVE_BRKR) == wantBrkr and blockSide(c) == side
                    drop := j
                    break
        if drop == -1
            break
        delBlockDrawings(blocks.get(drop))
        blocks.remove(drop)
        n -= 1
    true

//@function Applies the per-kind block cap under the chosen scope — once over everything
//          for Total, once per bucket otherwise.
//@param wantBrkr (bool) True caps breakers, false caps order blocks.
//@returns (bool) Always true.
pruneBlocks(bool wantBrkr) =>
    if capScope == "Total"
        pruneBlockKind(wantBrkr, SIDE_ALL)
    else
        pruneBlockKind(wantBrkr, SIDE_A)
        pruneBlockKind(wantBrkr, SIDE_B)
    true

//@function Keeps only the most recently faded order block. Breakers never fade — read as
//          their whole range, they are live or gone.
//@returns (bool) Always true.
dropOlderFadedBlocks() =>
    int newest = -1
    if blocks.size() > 0
        for j = 0 to blocks.size() - 1
            SmartBlock b = blocks.get(j)
            if b.mitigated and not na(b.fadedBar)
                newest := math.max(newest, b.fadedBar)
        for j = blocks.size() - 1 to 0
            SmartBlock b = blocks.get(j)
            if b.mitigated and not na(b.fadedBar) and b.fadedBar < newest
                delBlockDrawings(b)
                blocks.remove(j)
    true

if barstate.isconfirmed
    // MSS is a one-shot event: a swing grants structure-break credit once, on the first
    // confirmed close through it, and is consumed even when no OB registers there — a
    // grind through the swing must not bank credit for a later candle. No separate
    // displacement test: FVG registration already enforces displacement, and the leg
    // must leave a FVG for its block to register.
    bool bullBreak = swingHighArmed and not na(lastSwingHigh) and close > lastSwingHigh
    bool bearBreak = swingLowArmed and not na(lastSwingLow) and close < lastSwingLow
    if bullBreak
        swingHighArmed := false
    if bearBreak
        swingLowArmed := false
    bool bullMSS = not obNeedMSS or bullBreak
    bool bearMSS = not obNeedMSS or bearBreak
    bool bullDisp = close > open and bullMSS
    bool bearDisp = close < open and bearMSS
    // Resolve pending order blocks: a leg FVG confirming this bar validates a break from
    // up to OB_FVG_GRACE bars ago. Cancel on grace expiry or a close back through the
    // candidate candle.
    if pBullOB.armed
        if not na(lastBullFvgBirth) and lastBullFvgBirth > pBullOB.obBar
            createBlock(true, pBullOB.bodyTop, pBullOB.bodyBot, pBullOB.fullHi, pBullOB.fullLo, pBullOB.outside, pBullOB.obBar)
            lastBullObOrigin := pBullOB.obBar
            pBullOB.armed := false
        else if bar_index - pBullOB.breakBar > OB_FVG_GRACE or close < pBullOB.fullLo
            pBullOB.armed := false
    if pBearOB.armed
        if not na(lastBearFvgBirth) and lastBearFvgBirth > pBearOB.obBar
            createBlock(false, pBearOB.bodyTop, pBearOB.bodyBot, pBearOB.fullHi, pBearOB.fullLo, pBearOB.outside, pBearOB.obBar)
            lastBearObOrigin := pBearOB.obBar
            pBearOB.armed := false
        else if bar_index - pBearOB.breakBar > OB_FVG_GRACE or close > pBearOB.fullHi
            pBearOB.armed := false
    // The anchor is the extreme BODY CLOSE in the window: lowest close of a down candle for a
    // bullish block, highest close of an up candle for a bearish one. Offsets start at 1 so the
    // displacement candle can never be its own origin.
    dnBar := na
    upBar := na
    float dnLowestClose  = na
    float upHighestClose = na
    // Window = the pullback, anchored on the swing it turned away from: a bullish block sits in
    // the move down from the last swing HIGH.
    int bullSpan = na(lastSwingHighBar) ? 0 : math.min(bar_index - lastSwingHighBar + pivRight, OB_SCAN_MAX)
    int bearSpan = na(lastSwingLowBar)  ? 0 : math.min(bar_index - lastSwingLowBar  + pivRight, OB_SCAN_MAX)
    // The extreme candle anchors a GROUP: the run of consecutive same-direction candles
    // in front of it, up to OB_GROUP_MAX in all. The block is the group's body — open of
    // the first candle to the extreme close — and its full range is the group's, wick to
    // wick. A lone candle is a group of one.
    int dnK = na
    int upK = na
    if bullSpan > 0
        for k = 1 to bullSpan
            if close[k] < open[k] and (na(dnLowestClose) or close[k] < dnLowestClose)
                dnLowestClose := close[k]
                dnK := k
    if bearSpan > 0
        for k = 1 to bearSpan
            if close[k] > open[k] and (na(upHighestClose) or close[k] > upHighestClose)
                upHighestClose := close[k]
                upK := k
    if not na(dnK)
        int kStart = dnK
        // The group is same-direction AND similar in body to the anchor. A candle whose body
        // is far larger is displacement - the leg INTO the block, not part of it - and one far
        // smaller is a different candle doing a different job. Measured on the body, because a
        // live block is drawn as a body. The floor keeps a doji anchor from exploding the ratio.
        float dnAnchor = math.max(math.abs(close[dnK] - open[dnK]), atrVal * 0.05)
        for j = 1 to OB_GROUP_MAX - 1
            float dnBj = math.abs(close[dnK + j] - open[dnK + j])
            if close[dnK + j] < open[dnK + j] and dnBj <= dnAnchor * grpSimilar and dnBj * grpSimilar >= dnAnchor
                kStart := dnK + j
            else
                break
        dnFullHi := high[dnK]
        dnFullLo := low[dnK]
        for j = dnK to kStart
            dnFullHi := math.max(dnFullHi, high[j])
            dnFullLo := math.min(dnFullLo, low[j])
        dnBodyTop := open[kStart]
        dnBodyBot := close[dnK]
        dnOutside := high[dnK] > high[dnK + 1] and low[dnK] < low[dnK + 1]
        dnBar     := bar_index - kStart
    if not na(upK)
        int kStart = upK
        float upAnchor = math.max(math.abs(close[upK] - open[upK]), atrVal * 0.05)
        for j = 1 to OB_GROUP_MAX - 1
            float upBj = math.abs(close[upK + j] - open[upK + j])
            if close[upK + j] > open[upK + j] and upBj <= upAnchor * grpSimilar and upBj * grpSimilar >= upAnchor
                kStart := upK + j
            else
                break
        upFullHi := high[upK]
        upFullLo := low[upK]
        for j = upK to kStart
            upFullHi := math.max(upFullHi, high[j])
            upFullLo := math.min(upFullLo, low[j])
        upBodyTop := close[upK]
        upBodyBot := open[kStart]
        upOutside := high[upK] > high[upK + 1] and low[upK] < low[upK + 1]
        upBar     := bar_index - kStart
    // New candidates: a leg that has already gapped registers its OB immediately; one
    // that has not goes pending until its FVG confirms. No gap within the grace window,
    // no order block.
    if bullDisp and not na(dnBar) and bar_index - dnBar <= OB_SCAN_MAX and close > dnFullHi and (na(lastBullObOrigin) or dnBar != lastBullObOrigin)
        if not na(lastBullFvgBirth) and lastBullFvgBirth > dnBar
            createBlock(true, dnBodyTop, dnBodyBot, dnFullHi, dnFullLo, dnOutside, dnBar)
            lastBullObOrigin := dnBar
        else
            pBullOB.armed := true
            pBullOB.bodyTop := dnBodyTop
            pBullOB.bodyBot := dnBodyBot
            pBullOB.fullHi := dnFullHi
            pBullOB.fullLo := dnFullLo
            pBullOB.outside := dnOutside
            pBullOB.obBar := dnBar
            pBullOB.breakBar := bar_index
    if bearDisp and not na(upBar) and bar_index - upBar <= OB_SCAN_MAX and close < upFullLo and (na(lastBearObOrigin) or upBar != lastBearObOrigin)
        if not na(lastBearFvgBirth) and lastBearFvgBirth > upBar
            createBlock(false, upBodyTop, upBodyBot, upFullHi, upFullLo, upOutside, upBar)
            lastBearObOrigin := upBar
        else
            pBearOB.armed := true
            pBearOB.bodyTop := upBodyTop
            pBearOB.bodyBot := upBodyBot
            pBearOB.fullHi := upFullHi
            pBearOB.fullLo := upFullLo
            pBearOB.outside := upOutside
            pBearOB.obBar := upBar
            pBearOB.breakBar := bar_index
    // Displacement on the candle that breaks the swing, to the same standard the failed-block
    // reading applies to the candle that takes a block out. A swing closed through quietly is
    // a structure that drifted, not one that was run.
    float brkBodyNow = math.abs(close - open)
    bool  brkDispDn  = brkBodyNow >= atrVal * brkrDispAtr and close < open
    bool  brkDispUp  = brkBodyNow >= atrVal * brkrDispAtr and close > open
    if brkrIctCandle
        // Resolve the standing candidates first, then arm the swing that confirmed this
        // bar. A candidate that has already seen its sweep is kept over a later swing —
        // ICT reads the swing BEFORE the run, not a pullback formed after it — but not
        // forever: past the block scan window the swing is history, not a setup.
        if bearCand.armed and bar_index - bearCand.originBar > OB_SCAN_MAX
            bearCand.armed := false
        if bullCand.armed and bar_index - bullCand.originBar > OB_SCAN_MAX
            bullCand.armed := false
        if bearCand.armed
            // A wick through the old high is not a higher high, and an internal pivot is not
            // liquidity. The run is read on the close, and with the sequence on it also has to
            // land on a level this script actually draws being raided — otherwise a range
            // oscillating over its own last swing arms a breaker on every leg.
            if (brkRunClose ? close : high) > bearCand.ref and (not brkrNeedSeq or buysideRaidRecent)
                bearCand.swept := true
            if close < bearCand.swing
                if bearCand.swept and (not brkrNeedSeq or brkDispDn)
                    createBreaker(false, bearCand.bodyTop, bearCand.bodyBot, bearCand.fullHi, bearCand.fullLo, bearCand.originBar)
                bearCand.armed := false
        if bullCand.armed
            if (brkRunClose ? close : low) < bullCand.ref and (not brkrNeedSeq or sellsideRaidRecent)
                bullCand.swept := true
            if close > bullCand.swing
                if bullCand.swept and (not brkrNeedSeq or brkDispUp)
                    createBreaker(true, bullCand.bodyTop, bullCand.bodyBot, bullCand.fullHi, bullCand.fullLo, bullCand.originBar)
                bullCand.armed := false
        if newPL and not (bearCand.armed and bearCand.swept)
            armBreakerCandidate(bearCand, true, pl, lastSwingHigh, not na(lastSwingHigh) and (brkRunClose ? hiCloseSincePiv : hiSincePiv) > lastSwingHigh and (not brkrNeedSeq or buysideRaidRecent))
        if newPH and not (bullCand.armed and bullCand.swept)
            armBreakerCandidate(bullCand, false, ph, lastSwingLow, not na(lastSwingLow) and (brkRunClose ? loCloseSincePiv : loSincePiv) < lastSwingLow and (not brkrNeedSeq or sellsideRaidRecent))

if barstate.isconfirmed
    if blocks.size() > 0
        for i = blocks.size() - 1 to 0
            SmartBlock b = blocks.get(i)
            // Retire a block that is too old or whose traded edge is too far from price to be
            // an array price is drawing to — spent or live, faded history ages out the same.
            bool  brkrNow   = b.stage == STAGE_ACTIVE_BRKR
            bool  liveBull  = brkrNow ? not b.obIsBull : b.obIsBull
            int   ageFrom   = brkrNow and not na(b.flipBar) ? b.flipBar : b.bornBar
            float edgeAway  = liveBull ? close - b.top : b.bottom - close
            bool  tooOld    = arrayMaxAge > 0 and bar_index - ageFrom > arrayMaxAge
            bool  tooFar    = arrayMaxDist > 0.0 and edgeAway > atrVal * arrayMaxDist
            bool  ancient   = bar_index - b.originBar > ARRAY_MAX_AGE
            if ancient or tooOld or tooFar
                delBlockDrawings(b)
                blocks.remove(i)
            else if b.stage == STAGE_PENDING_OB
                // Wick to wick, not body — the same test the Unicorn Model makes, whose
                // block IS its candle group's high and low. A live block is DRAWN at its body
                // because that is the price you trade from, but the block is the whole candle,
                // and its high is the swing high it formed at. Testing the body instead lets
                // price clear the block by a few points, stall under the old high and still
                // mint a breaker for a high that never printed.
                bool violated = b.obIsBull ? close < b.fullBot : close > b.fullTop
                // A breaker is a block that FAILED, and failing means it was RUN through: the
                // candle that takes it out must itself be displacement in that direction, and
                // liquidity must have been taken before the reversal that produced it. A bullish
                // block broken downward wants a buyside raid behind it; a bearish block broken
                // upward wants a sellside raid. Quietly closed through with neither, it is a dead
                // block, not a breaker.
                float brkThruBody = math.abs(close - open)
                bool  brkDispOK   = brkThruBody >= atrVal * brkrDispAtr and (b.obIsBull ? close < open : close > open)
                bool  brkRaidOK   = b.obIsBull ? buysideRaidRecent : sellsideRaidRecent
                bool  brkSeqOK    = not brkrNeedSeq or (brkDispOK and brkRaidOK)
                if violated and (brkrIctCandle or (brkrTested and not b.respected) or not brkSeqOK)
                    // Breakers read from the ICT candle: a failed block is simply gone. Failed
                    // block mode with the tested rule on: run straight through before it was
                    // ever tested was never an array in play, so not a breaker either. Gone.
                    delBlockDrawings(b)
                    blocks.remove(i)
                else if violated
                    // A tested OB failed → Breaker, wherever its bodies sat on the way
                    // through. Flip polarity, colour and label; the breaker then lives
                    // fresh, untested.
                    b.stage := STAGE_ACTIVE_BRKR
                    b.flipBar := bar_index
                    b.respected := false
                    label.delete(b.chk)
                    b.chk := label(na)
                    // A breaker takes the FULL candle range, wick to wick — always.
                    // The displacement context is already proven (no FVG off the
                    // leg, no order block registers), so a failed block earns its
                    // whole candle. Only the live OB is body-only.
                    b.top := b.fullTop
                    b.bottom := b.fullBot
                    if brkrZone and not na(b.rayProx)
                        // Levels mode: the breaker sheds its lines and paints as a zone,
                        // so a failed block never reads as a live one.
                        line.delete(b.rayProx)
                        line.delete(b.rayDist)
                        line.delete(b.rayMt)
                        label.delete(b.rayLbl)
                        b.rayProx := line(na)
                        b.rayDist := line(na)
                        b.rayMt := line(na)
                        b.rayLbl := label(na)
                        color bzc = b.obIsBull ? bearZoneCol : bullZoneCol
                        b.bx := box.new(math.max(b.originBar, bar_index - ARRAY_MAX_AGE), b.top, bar_index + rightOffset, b.bottom, border_color = color.new(bzc, 30), border_width = 1, border_style = line.style_dashed, bgcolor = color.new(bzc, 95), text = blockTag(true, not b.obIsBull, b.grade), text_size = zoneLabelSize, text_color = #000000, text_halign = text.align_right, text_valign = text.align_center, text_font_family = font.family_monospace)
                    if not na(b.bx)
                        box.set_top(b.bx, b.top)
                        box.set_bottom(b.bx, b.bottom)
                    color flip = b.obIsBull ? bearZoneCol : bullZoneCol
                    if not na(b.bx)
                        // A breaker reads lighter than a live block: dashed edge, thinner fill.
                        box.set_bgcolor(b.bx, color.new(flip, 95))
                        box.set_border_color(b.bx, color.new(flip, 30))
                        box.set_border_style(b.bx, line.style_dashed)
                        box.set_right(b.bx, bar_index + rightOffset)
                        box.set_text(b.bx, blockTag(true, not b.obIsBull, b.grade))
                    if not na(b.rayProx)
                        updateBlockRays(b)   // stage is already breaker — rays flip colour, prices and tag
                    if not na(b.lbl)
                        label.delete(b.lbl)
                        b.lbl := label(na)
                else
                    // Live OB — extend, then the touch rule. A block has no consequent
                    // encroachment test: bodies may sit anywhere inside it and it stays
                    // live until one closes through.
                    if not na(b.bx)
                        box.set_right(b.bx, bar_index + rightOffset)
                    if not na(b.rayProx)
                        updateBlockRays(b)
                    if not na(b.lbl)
                        label.set_x(b.lbl, int(math.avg(b.originBar, bar_index + rightOffset)))
                        label.set_y(b.lbl, math.avg(b.top, b.bottom))
                    if not na(b.chk)
                        label.set_xy(b.chk, bar_index + rightOffset, math.avg(b.top, b.bottom))
                    bool graced = bar_index > b.bornBar
                    if graced and zoneTouched(b.top, b.bottom, b.obIsBull)
                        // Tested and held — respected. The tap feeds the dashboard.
                        if b.obIsBull
                            lastBullObTapBar := bar_index
                        else
                            lastBearObTapBar := bar_index
                        if not b.respected
                            b.respected := true
                            b.chk := mkTick(bar_index + rightOffset, math.avg(b.top, b.bottom), na(b.rayProx) ? label.style_label_left : label.style_label_right)
            else
                bool brkIsBull = not b.obIsBull
                bool through = brkIsBull ? close < b.bottom : close > b.top
                if through
                    delBlockDrawings(b)
                    blocks.remove(i)
                else
                    // A breaker is read as its WHOLE range — no consequent encroachment rule.
                    // It lives until a body closes outside it, and a tap respects it.
                    if not na(b.bx)
                        box.set_right(b.bx, bar_index + rightOffset)
                    if not na(b.rayProx)
                        updateBlockRays(b)
                    if not na(b.lbl)
                        label.set_x(b.lbl, int(math.avg(b.originBar, bar_index + rightOffset)))
                        label.set_y(b.lbl, math.avg(b.top, b.bottom))
                    if not na(b.chk)
                        label.set_xy(b.chk, bar_index + rightOffset, math.avg(b.top, b.bottom))
                    if bar_index > b.flipBar and zoneTouched(b.top, b.bottom, brkIsBull)
                        if brkIsBull
                            lastBullBrkBar := bar_index
                        else
                            lastBearBrkBar := bar_index
                        if not b.respected
                            b.respected := true
                            b.chk := mkTick(bar_index + rightOffset, math.avg(b.top, b.bottom), na(b.rayProx) ? label.style_label_left : label.style_label_right)

    // Apply the per-kind cap once, after everything that can change a block's kind or
    // count this bar: the new blocks registered above, and any OB that just flipped to a
    // breaker in the loop directly above. Doing it here rather than at creation is what
    // lets the two kinds hold separate allowances.
    dropOlderFadedBlocks()
    pruneBlocks(false)
    pruneBlocks(true)

// ── Cross-type declutter — a FVG that sits inside a live Order Block / Breaker drawn as a
//    ZONE hides its own box and label, so the higher-order block reads clean and zones never
//    double up. The gap is only hidden, not dropped — it still tracks, and returns the moment
//    it is no longer inside one. Blocks drawn as levels leave no slab to clutter, so every
//    gap shows.
if barstate.isconfirmed
    if fvgs.size() > 0
        for i = 0 to fvgs.size() - 1
            FVG f = fvgs.get(i)
            if not f.mitigated and not na(f.bx)
                bool inside = false
                if not obRays and blocks.size() > 0
                    for bi = 0 to blocks.size() - 1
                        SmartBlock b = blocks.get(bi)
                        if not b.mitigated and b.bottom <= f.top and b.top >= f.bottom
                            inside := true
                color zc = gapCol(f)
                box.set_bgcolor(f.bx, inside ? color.new(zc, 100) : zc)
                box.set_border_color(f.bx, inside ? color.new(zc, 100) : zc)
                box.set_text_color(f.bx, inside ? color.new(C_INK, 100) : C_INK)
                if not na(f.lbl)
                    label.set_textcolor(f.lbl, inside ? color.new(C_INK, 100) : C_INK)
                // The midline hides with its zone. Left visible it would read as a
                // level of the BLOCK, which is the confusion this declutter exists
                // to prevent — and the block already draws its own.
                if not na(f.ce)
                    line.set_color(f.ce, inside ? color.new(C_MID, 100) : C_MID)

bool bullObTapRecent  = not na(lastBullObTapBar) and bar_index - lastBullObTapBar <= tapMemory
bool bearObTapRecent  = not na(lastBearObTapBar) and bar_index - lastBearObTapBar <= tapMemory
bool bullBrkRecent    = not na(lastBullBrkBar) and bar_index - lastBullBrkBar <= tapMemory
bool bearBrkRecent    = not na(lastBearBrkBar) and bar_index - lastBearBrkBar <= tapMemory

// ============================================================================
// MODULE 5 — SMT DIVERGENCE (liquidity-sweep, cross-asset)
// ----------------------------------------------------------------------------
// Both the chart symbol and the peer carry a pool of swing-high (buyside) and swing-low
// (sellside) liquidity. When a new swing SWEEPS one of
// the pooled levels (price takes it) but the peer does NOT sweep its aligned level — its
// extreme stays short of the level taken — the move lacks participation: a SMT, drawn
// from the swept level to the sweep. Each sweep is cross-checked against the peer's pool
// and candle-validated, so only genuine one-sided sweeps register, not every swing. The
// peer OHLC is read on the chart timeframe; detection runs on closed bars.
// ============================================================================
int smtOneBar = timeframe.in_seconds(timeframe.period) * 1000

//@type A drawn SMT — its line, its label, and the price that invalidates it.
type SmtLevel
    line  ln
    label lb
    float price

//@type One pooled swing liquidity: its own price, the bar time it formed, and the OTHER
//      asset's aligned price at that time (the cross-reference the validation reads).
type SmtLiq
    float price
    int   t
    float refPrice = na

var array<SmtLevel> smtSMbu = array.new<SmtLevel>()   // drawn bullish SMTs
var array<SmtLevel> smtSMbe = array.new<SmtLevel>()   // drawn bearish SMTs
var array<SmtLiq>   smtH1 = array.new<SmtLiq>()        // chart swing highs
var array<SmtLiq>   smtL1 = array.new<SmtLiq>()        // chart swing lows
var array<SmtLiq>   smtH2 = array.new<SmtLiq>()        // peer swing highs
var array<SmtLiq>   smtL2 = array.new<SmtLiq>()        // peer swing lows
var float smtLastBUsmt = 0.0
var float smtLastBEsmt = 0.0
var int   lastBullSmtBar = na
var int   lastBearSmtBar = na

//@function Drops pooled swings older than the liquidity memory, so a SMT is only ever drawn
//          between swings recent enough to be compared.
//@param pool (array<SmtLiq>) The pool to age, oldest first.
//@returns (bool) Always true.
smtAgePool(array<SmtLiq> pool) =>
    while pool.size() > 0 and (time - pool.first().t) / smtOneBar > smtPoolBars
        pool.shift()
    true

//@function Pops pooled levels the new pivot has swept (price beyond them), returning the
//          deepest one taken — the liquidity this swing ran through.
//@param src (array<SmtLiq>) The high or low pool to sweep.
//@param price (float) The new pivot price.
//@param up (bool) True for a swing high (buyside), false for a swing low.
//@returns (SmtLiq) The deepest swept level, or na.
smtSweep(array<SmtLiq> src, float price, bool up) =>
    SmtLiq taken = na
    bool cont = true
    while cont and src.size() > 0
        float lp = src.last().price
        if up ? price > lp : price < lp
            taken := src.pop()
        else
            cont := false
    taken

//@function Finds, in the OTHER asset's pool, the level that best matches a swept level in
//          time, so the SMT anchors to the peer's corresponding swing.
//@param s (SmtLiq) The swept level.
//@param pool (array<SmtLiq>) The other asset's pool.
//@param up (bool) Side under test.
//@returns (SmtLiq) The matching peer level (falls back to the swept level's own reference).
smtCheck(SmtLiq s, array<SmtLiq> pool, bool up) =>
    SmtLiq vl = SmtLiq.new(s.refPrice, s.t)
    int sz = pool.size() - 1
    if sz > 0
        bool done = false
        for i = sz to 0
            if not done
                SmtLiq p = pool.get(i)
                if p.t < s.t
                    done := true
                else if p.t > s.t and (up ? p.price < s.refPrice : p.price > s.refPrice)
                    vl := p
                    done := true
    vl

//@function Confirms the sweep sequence between the two assets is valid; returns the bar
//          offset back to the anchoring swing (0 = not valid).
//@param pool (array<SmtLiq>) The chart symbol's pool.
//@param s (SmtLiq) The peer's swept level.
//@param up (bool) Side under test.
//@returns (int) Bar offset, or 0.
smtValidateSMT(array<SmtLiq> pool, SmtLiq s, bool up) =>
    int b = 0
    if pool.size() > 0
        SmtLiq last = pool.last()
        if (up ? last.price > s.refPrice : last.price < s.refPrice) and last.t > s.t
            b := int((time - last.t) / smtOneBar)
    b

//@variable Ceiling for the bar-walks below, under the 5000-bar buffers on high / low / time.
int MAX_BAR_WALK = 4900

//@function Draws one SMT from an anchor time/price to the sweep, walking back to the true
//          swing extremes so the line sits on the wicks, and caps each side at smtMaxShow.
//@returns (float) The SMT's invalidating price (or the last one when nothing is drawn).
smtDrawSMT(int tm, float p1, float p2, bool bull) =>
    bool ok = bull ? low > low[smtPivot] : high < high[smtPivot]
    float outPrice = bull ? smtLastBUsmt : smtLastBEsmt
    if time[smtPivot] - tm > smtOneBar and ok
        int o = smtPivot
        float p2final = p2
        if bull
            while o + 1 <= MAX_BAR_WALK and low[o + 1] <= low[o]
                o := o + 1
            p2final := low[o]
        else
            while o + 1 <= MAX_BAR_WALK and high[o + 1] >= high[o]
                o := o + 1
            p2final := high[o]
        int bars = math.round((time[o] - tm + smtOneBar * smtPivot) / smtOneBar)
        int newTm = tm
        float p1final = p1
        if bars < MAX_BAR_WALK and bars > 0
            while bars > 0 and time[bars] < tm
                bars := bars - 1
            while bars + 1 <= MAX_BAR_WALK and (bull ? low[bars + 1] < low[bars] : high[bars + 1] > high[bars])
                bars := bars + 1
            newTm   := time[bars]
            p1final := bull ? low[bars] : high[bars]
        if time[o] - newTm > smtOneBar
            color c = bull ? bullTxt : bearTxt
            line l = line.new(newTm, p1final, time[o], p2final, xloc = xloc.bar_time, color = c, width = 2, style = line.style_solid)
            label b = na
            if smtShowLabel
                // Sit the label clear of its own line — above a bearish SMT, below a bullish one — so it
                // never lands on the PD-array zone the divergence is pointing at. The anchor is the
                // line's own midpoint and the STYLE does the lifting, so the gap is constant in pixels.
                float lblY = math.avg(p1final, p2final)
                string lblSty = bull ? label.style_label_up : label.style_label_down
                // Text black — the SMT's own line is already drawn in the direction colour.
                b := label.new(math.round(math.avg(newTm, time[o])), lblY, smtName, xloc = xloc.bar_time, style = lblSty, color = COLOR_NONE, textcolor = C_INK, size = eventLabelSize)
                label.set_text_font_family(b, font.family_monospace)
            outPrice := bull ? math.min(p1final, p2final) : math.max(p1final, p2final)
            array<SmtLevel> arr = bull ? smtSMbu : smtSMbe
            arr.push(SmtLevel.new(l, b, outPrice))
            while arr.size() > smtMaxShow
                SmtLevel old = arr.shift()
                line.delete(old.ln)
                label.delete(old.lb)
    outPrice

// Pivots at top level (ta.* must run every bar) — ours + the peer's, symmetric strength.
float smt_h  = ta.pivothigh(high,  smtPivot, smtPivot)
float smt_ht = ta.pivothigh(smtHH, smtPivot, smtPivot)
float smt_l  = ta.pivotlow(low,    smtPivot, smtPivot)
float smt_lt = ta.pivotlow(smtLL,  smtPivot, smtPivot)

if smtOn and barstate.isconfirmed
    // Clean up SMTs price has since traded back through, if enabled.
    if smtDelBroken
        if smtSMbe.size() > 0
            for i = smtSMbe.size() - 1 to 0
                if high > smtSMbe.get(i).price
                    line.delete(smtSMbe.get(i).ln)
                    label.delete(smtSMbe.get(i).lb)
                    smtSMbe.remove(i)
        if smtSMbu.size() > 0
            for i = smtSMbu.size() - 1 to 0
                if low < smtSMbu.get(i).price
                    line.delete(smtSMbu.get(i).ln)
                    label.delete(smtSMbu.get(i).lb)
                    smtSMbu.remove(i)

    // Age the pools before anything is swept, so a stale swing can never anchor a SMT.
    smtAgePool(smtH1)
    smtAgePool(smtL1)
    smtAgePool(smtH2)
    smtAgePool(smtL2)

    int prevBu = smtSMbu.size()
    int prevBe = smtSMbe.size()
    bool downOK = not smtCandleCheck or (close[smtPivot] < open[smtPivot] and smtOO[smtPivot] > smtCC[smtPivot])
    bool upOK   = not smtCandleCheck or (close[smtPivot] > open[smtPivot] and smtCC[smtPivot] > smtOO[smtPivot])

    // ── Bearish: chart / peer swing highs ─────────────────────────────────────────
    SmtLiq s1 = not na(smt_h)  ? smtSweep(smtH1, smt_h,  true) : na
    SmtLiq s2 = not na(smt_ht) ? smtSweep(smtH2, smt_ht, true) : na
    if not na(s1)
        if downOK and time[smtPivot] - s1.t > smtOneBar * smtPivot
            if na(s2)
                if smtHH[smtPivot] < s1.refPrice
                    smtLastBEsmt := smtDrawSMT(s1.t, s1.price, smt_h, false)
                else if smtH2.size() > 0
                    SmtLiq lastH2 = smtH2.last()
                    int b = int((time - lastH2.t) / smtOneBar)
                    if b > 0 and b < 5000 and lastH2.price > smtHH[smtPivot] and high[b] < smt_h
                        smtLastBEsmt := smtDrawSMT(lastH2.t, lastH2.refPrice, smt_h, false)
            else if s1.t < s2.t and smtHH[smtPivot] < s1.refPrice
                smtLastBEsmt := smtDrawSMT(s1.t, s1.price, smt_h, false)
            else if s1.t > s2.t and s2.refPrice > high[smtPivot]
                int b = smtValidateSMT(smtH1, s2, true)
                if (b > 0 and b < 5000) ? smtHH[b] < smt_ht : true
                    SmtLiq lc = smtCheck(s2, smtH1, false)
                    smtLastBEsmt := smtDrawSMT(lc.t, lc.price, high[smtPivot], false)
    else if not na(s2)
        if downOK and time[smtPivot] - s2.t > smtOneBar * smtPivot and s2.refPrice > high[smtPivot]
            int b = smtValidateSMT(smtH1, s2, true)
            if (b > 0 and b < 5000) ? smtHH[b] < smt_ht : true
                SmtLiq lc = smtCheck(s2, smtH1, false)
                smtLastBEsmt := smtDrawSMT(lc.t, lc.price, high[smtPivot], false)

    // ── Bullish: chart / peer swing lows ──────────────────────────────────────────
    SmtLiq s3 = not na(smt_l)  ? smtSweep(smtL1, smt_l,  false) : na
    SmtLiq s4 = not na(smt_lt) ? smtSweep(smtL2, smt_lt, false) : na
    if not na(s3)
        if upOK and time[smtPivot] - s3.t > smtOneBar * smtPivot
            if na(s4)
                if smtLL[smtPivot] > s3.refPrice
                    smtLastBUsmt := smtDrawSMT(s3.t, s3.price, smt_l, true)
                else if smtL2.size() > 0
                    SmtLiq lastL2 = smtL2.last()
                    int b = int((time - lastL2.t) / smtOneBar)
                    if b > 0 and b < 5000 and lastL2.price < smtLL[smtPivot] and low[b] > smt_l
                        smtLastBUsmt := smtDrawSMT(lastL2.t, lastL2.refPrice, smt_l, true)
            else if s3.t < s4.t and smtLL[smtPivot] > s3.refPrice
                smtLastBUsmt := smtDrawSMT(s3.t, s3.price, smt_l, true)
            else if s3.t > s4.t and low[smtPivot] > s4.refPrice
                int b = smtValidateSMT(smtL1, s4, false)
                if (b > 0 and b < 5000) ? smtLL[b] < smt_lt : true
                    SmtLiq lc = smtCheck(s4, smtL1, true)
                    smtLastBUsmt := smtDrawSMT(lc.t, lc.price, low[smtPivot], true)
    else if not na(s4)
        if upOK and time[smtPivot] - s4.t > smtOneBar * smtPivot and low[smtPivot] > s4.refPrice
            int b = smtValidateSMT(smtL1, s4, false)
            if (b > 0 and b < 5000) ? smtLL[b] < smt_lt : true
                SmtLiq lc = smtCheck(s4, smtL1, true)
                smtLastBUsmt := smtDrawSMT(lc.t, lc.price, low[smtPivot], true)

    if smtSMbe.size() > prevBe
        lastBearSmtBar := bar_index
    if smtSMbu.size() > prevBu
        lastBullSmtBar := bar_index

    // Pool the new swings — each records the OTHER asset's aligned price as its reference.
    if not na(smt_h)
        smtH1.push(SmtLiq.new(smt_h, time[smtPivot], smtHH[smtPivot]))
        while smtH1.size() > 60
            smtH1.shift()
    if not na(smt_ht)
        smtH2.push(SmtLiq.new(smt_ht, time[smtPivot], high[smtPivot]))
        while smtH2.size() > 60
            smtH2.shift()
    if not na(smt_l)
        smtL1.push(SmtLiq.new(smt_l, time[smtPivot], smtLL[smtPivot]))
        while smtL1.size() > 60
            smtL1.shift()
    if not na(smt_lt)
        smtL2.push(SmtLiq.new(smt_lt, time[smtPivot], low[smtPivot]))
        while smtL2.size() > 60
            smtL2.shift()

bool bullSmtRecent = not na(lastBullSmtBar) and bar_index - lastBullSmtBar <= smtMemory
bool bearSmtRecent = not na(lastBearSmtBar) and bar_index - lastBearSmtBar <= smtMemory

// ============================================================================
// LABEL COMBINE-PASS — one label per price cluster, at the right edge
// ============================================================================
var array<label> comboLabels = array.new<label>()

if barstate.islast
    while comboLabels.size() > 0
        label.delete(comboLabels.pop())
    array<float>  gP = array.new<float>()
    array<string> gT = array.new<string>()
    array<color>  gC = array.new<color>()
    if levels.size() > 0
        for i = 0 to levels.size() - 1
            Level lv = levels.get(i)
            if not lv.swept
                gP.push(lv.price)
                gT.push(lv.disp)
                gC.push(color.new(lv.col, 0))
    int n = gP.size()
    if n > 0
        float tol = atrVal * combineAtr
        array<bool> used = array.new<bool>()
        for i = 0 to n - 1
            used.push(false)
        int remaining = n
        while remaining > 0
            int seed = -1
            float seedP = na
            for i = 0 to n - 1
                if not used.get(i) and (seed == -1 or gP.get(i) < seedP)
                    seed := i
                    seedP := gP.get(i)
            string combined = ""
            color cc = gC.get(seed)
            float labelP = seedP
            for i = 0 to n - 1
                if not used.get(i) and math.abs(gP.get(i) - seedP) <= tol
                    used.set(i, true)
                    remaining := remaining - 1
                    string tg = gT.get(i)
                    if combined == ""
                        combined := tg
                    else if not str.contains(combined, tg)
                        combined := combined + " + " + tg
                    if gP.get(i) < labelP
                        labelP := gP.get(i)
            comboLabels.push(mkLineLabel(bar_index + rightOffset, labelP, combined, cc, levelLabelSize))

// ============================================================================
// MODULE 6 — DASHBOARD
// ----------------------------------------------------------------------------
// Pure confluence read-out: ICT bias, draw on liquidity, the named sweep, live
// confluences and session state. No alerts, no signals, no buy/sell calls.
// ============================================================================

// ── Dashboard ────────────────────────────────────────────────────────────────
//@function Resolves the dashboard-position input to a Pine position constant.
//@param s (string) The position choice.
//@returns (string) The matching position.* constant.
dashPosConst(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        =>                position.top_right

//@variable Brand-purple header fill.
color DASH_HEAD = color.new(#cd82ff, 49)
color DASH_BG   = color.new(#ffffff, 0)
color DASH_LINE = color.new(#000000, 0)

var table dash = na

//@function Writes one dashboard row: metric | state, monospace on white; the
//          value cell can carry a directional colour.
//@param row (int) Table row index.
//@param k (string) Metric name.
//@param v (string) Metric state.
//@param vcol (color) Value-cell text colour.
dashRow(int row, string k, string v, color vcol) =>
    table.cell(dash, 0, row, " " + k + " ", text_color = C_INK, text_size = sizeFromStr(dashSize), text_halign = text.align_left, text_font_family = font.family_monospace, bgcolor = DASH_BG)
    table.cell(dash, 1, row, " " + v + " ", text_color = vcol, text_size = sizeFromStr(dashSize), text_halign = text.align_right, text_font_family = font.family_monospace, bgcolor = DASH_BG)
    true

//@function Queues one dashboard row into the build lists, so the table renders only the
//          rows that carry information — momentary confluences that are inactive are simply
//          never queued, instead of printing an empty "-".
//@param kA (array<string>) Metric-name list.
//@param vA (array<string>) Value list.
//@param cA (array<color>) Value-colour list.
//@param k (string) Metric name.
//@param v (string) Metric value.
//@param c (color) Value-cell colour.
//@returns (bool) Always true.
pushRow(array<string> kA, array<string> vA, array<color> cA, string k, string v, color c) =>
    kA.push(k)
    vA.push(v)
    cA.push(c)
    true

if barstate.islast and showDash
    // ICT directional bias — dealing-range position (discount = bullish, premium
    // = bearish) stacked with the Midnight Open (below = bullish, above = bearish).
    // Both agreeing is a conviction read; a split is MIXED.
    color  biasCol = biasBull > biasBear ? bullTxt : biasBear > biasBull ? bearTxt : C_INK
    string kzState = not timeframe.isintraday ? "n/a (HTF)" : inLondonKZ ? "London KZ" : inNYAMKZ ? "NY AM KZ" : inNYPMKZ ? "NY PM KZ" : "outside"
    string mnState = na(midnightOpen) ? "-" : close < midnightOpen ? "below (bull)" : "above (bear)"
    // Dealing-range position as a % — 0% at the swing low, 100% at the swing high,
    // 50% = equilibrium. More informative than a bare discount/premium flag.
    float rangePos = not na(equilibrium) and drHi > drLo ? (close - drLo) / (drHi - drLo) * 100.0 : na
    string pdState = na(equilibrium) ? "-" : (close < equilibrium ? "disc " : "prem ") + str.tostring(math.round(math.max(0, math.min(100, rangePos)))) + "% " + (drUseWeekly ? "W" : "D")

    // ── Build only the rows that carry information ──────────────────────────────
    // Context rows are always shown; the momentary confluence rows are queued only
    // when live, so the table never fills with empty "-" placeholders.
    array<string> dK = array.new<string>()
    array<string> dV = array.new<string>()
    array<color>  dC = array.new<color>()
    pushRow(dK, dV, dC, "ICT BIAS", ictBias, biasCol)
    // Draw on liquidity — nearest unmitigated high above (resting buyside) and nearest
    // unmitigated low below (resting sellside), from the level engine.
    float drawUpDist = na
    string drawUpTxt = ""
    float drawDnDist = na
    string drawDnTxt = ""
    if levels.size() > 0
        for i = 0 to levels.size() - 1
            Level lv = levels.get(i)
            if not lv.swept
                if lv.isHigh and lv.price > close and (na(drawUpDist) or lv.price - close < drawUpDist)
                    drawUpDist := lv.price - close
                    drawUpTxt := lv.disp
                if not lv.isHigh and lv.price < close and (na(drawDnDist) or close - lv.price < drawDnDist)
                    drawDnDist := close - lv.price
                    drawDnTxt := lv.disp
    if not na(drawUpDist)
        pushRow(dK, dV, dC, "Draw ↑", drawUpTxt + " · " + str.tostring(drawUpDist, format.mintick), C_INK)
    if not na(drawDnDist)
        pushRow(dK, dV, dC, "Draw ↓", drawDnTxt + " · " + str.tostring(drawDnDist, format.mintick), C_INK)
    // The sweep row names the level that was taken.
    if buysideRaidRecent or sellsideRaidRecent
        string sweepTxt = buysideRaidRecent and sellsideRaidRecent ? lastBuysideRaidName + " + " + lastSellsideRaidName : buysideRaidRecent ? lastBuysideRaidName + " taken" : lastSellsideRaidName + " taken"
        pushRow(dK, dV, dC, "Sweep", sweepTxt, C_INK)
    if bullObTapRecent or bearObTapRecent
        pushRow(dK, dV, dC, "OB tap", bullObTapRecent and bearObTapRecent ? "both" : bullObTapRecent ? "bullish" : "bearish", bullObTapRecent and not bearObTapRecent ? bullTxt : bearObTapRecent and not bullObTapRecent ? bearTxt : C_INK)
    if bullBrkRecent or bearBrkRecent
        pushRow(dK, dV, dC, "Breaker", bullBrkRecent and bearBrkRecent ? "both" : bullBrkRecent ? "bullish" : "bearish", bullBrkRecent and not bearBrkRecent ? bullTxt : bearBrkRecent and not bullBrkRecent ? bearTxt : C_INK)
    if bullSmtRecent or bearSmtRecent
        pushRow(dK, dV, dC, "SMT", bullSmtRecent and bearSmtRecent ? "both" : bullSmtRecent ? "bullish" : "bearish", bullSmtRecent and not bearSmtRecent ? bullTxt : bearSmtRecent and not bullSmtRecent ? bearTxt : C_INK)
    pushRow(dK, dV, dC, "Killzone", kzState, C_INK)
    pushRow(dK, dV, dC, "Midnight O", mnState, C_INK)
    pushRow(dK, dV, dC, "Dealing range", pdState, C_INK)

    // Rebuild the table at the exact height the live rows need (header + queued rows),
    // so it grows and shrinks with the read instead of holding blank lines.
    if not na(dash)
        table.delete(dash)
    dash := table.new(dashPosConst(dashPos), 2, dK.size() + 1, bgcolor = DASH_BG, frame_color = DASH_LINE, frame_width = 1, border_color = DASH_LINE, border_width = 1)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 0, " M1D · Confluence ", text_color = C_INK, text_size = sizeFromStr(dashSize), text_halign = text.align_center, text_font_family = font.family_monospace, bgcolor = DASH_HEAD)
    if dK.size() > 0
        for r = 0 to dK.size() - 1
            dashRow(r + 1, dK.get(r), dV.get(r), dC.get(r))
````
