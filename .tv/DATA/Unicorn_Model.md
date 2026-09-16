<!-- tradingview-pine-id: PUB;b99da190845348d5a6af6f2682f44c74 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Unicorn Model

Source: https://www.tradingview.com/script/A9LMSD0g-Unicorn-Model/

## Description

Unicorn Model 
Finds the ICT Unicorn and frames its context. A Unicorn forms where a displacement leaves a Breaker behind and the Fair Value Gap that displacement traded through inverts onto it — the same-direction Inversion FVG overlapping the Breaker is what confirms it. Two arrays reinforcing each other at one price, which ICT teaches as a tight, high-probability zone. This tool detects that overlap, marks the Breaker that qualifies, always shows the inversion FVG that makes it one, tracks the liquidity that engineered it, and keeps the HTF bias and the draw on a clean dashboard. It maps structure. It does not fire trades.

The sequence it looks for

The Unicorn is a confluence, not a standalone trigger. Bullish below; bearish mirrors.

[*]Liquidity is taken — price sweeps a sellside low, engineering the reversal.
[*]A swing is broken — displacement closes through the last swing high. The candles immediately before that leg are left behind as an order block, and it becomes a Breaker only once price later closes back through it, the block failing and flipping exactly as an FVG inverts into an IFVG.
[*]The FVG inverts onto the Breaker — a candle body closes through the gap, so it fails and flips polarity into an Inversion FVG. A Breaker that a same-direction IFVG overlaps IS the Unicorn; with no overlapping IFVG it stays a plain Breaker.
[*]Bias frames it — the model needs a clear higher-timeframe read, so a bullish Unicorn shows in a bullish or discount context and a bearish one in premium.
[*]The draw — engineered liquidity in the direction of bias is the target the setup delivers toward.

Because the Unicorn is only as good as its narrative, bias is first-class: qualification is gated to the HTF read by default, and the dashboard keeps the read, the raid and the draw in front of you.

These are established Inner Circle Trader concepts — the Fair Value Gap, the Breaker, market structure shift, liquidity, the Midnight Open and premium/discount. This script is an original implementation of them, and what makes it its own thing is that it resolves the Breaker and the Inversion FVG that confirms it into a single zone rather than plotting each array in isolation.

What it draws

The Unicorn. When a live same-direction IFVG overlaps a Breaker, that box is relabelled Unicorn + or Unicorn -, drawn in purple or magenta with a distinct dashed border so the setup reads at a glance against the solid-bordered arrays around it. It is confirmed once and holds — it does not flicker bar to bar — and the confirming IFVG is kept alive with it. The two live and die together, so a Unicorn always shows the inversion that makes it one.

The ingredients. Drawn faintly beneath: FVGs in blue for bullish and red for bearish, Breakers in a neutral black, each tagged with the chart timeframe. A gap that sits inside the Unicorn or its inversion hides its own box, so the zone is never buried under the ingredient it is built from. Everything invalidates by candle body only — a wick through a zone never counts. A plain FVG inverts the moment one body closes through it; the Breaker and the inversion take a configurable number of body closes to retire, two by default.

The inversion. When a body closes through an FVG it does not vanish, it inverts — flipping polarity to deliver from the other side. The same-direction inversion overlapping a Breaker is what confirms the Unicorn. It is shaded orange, carries no label because orange reads as IFVG on its own, and sits behind the Unicorn so the zone stays in front.

Liquidity. Swing highs are buyside, swing lows are sellside, plus prior-day and prior-week levels as external-range reference, each anchored to the candle that formed it. The outermost live swing each side is tagged Buyside or Sellside Liquidity; inner swings carry Minor tags; prior-period levels keep a dated one. A level that is also an Asia, London or New York session extreme carries that tag too. Every level is removed the instant it is taken — no dotted stub, no lingering line — and an un-taken level that price trends a full range past without returning also clears. Tags that share a price merge into one rather than stacking.

Midnight Open. The 00:00 New York open, a core daily reference and a bias input. Below it leans bullish, above it leans bearish.

The draw. The target the setup delivers toward. It stays hidden until a Unicorn has set up AND its setup-side liquidity has been swept; only then is the opposing draw tagged on that level. That ordering is deliberate — the marker can never read as a standalone entry signal.

Dashboard

HTF bias, bullish or bearish or mixed, auto or manual. Whether a Unicorn is live and which way, falling back to the last one's direction rather than a bare dash. Which side of liquidity was most recently raided. The current draw with its price. Prior-day high and low, tracked even when the lines are hidden. Price against the Midnight Open. And where price sits in the dealing range, discount or premium against the equilibrium.

Reading it in practice

Trade with the dashboard bias. A Unicorn marks the Breaker whose overlapping inversion FVG makes it one; the orange IFVG shows the imbalance it sits within. ICT guidance waits for price to tap the FVG side, places the stop beyond the combined Breaker and FVG extreme — whichever is furthest — and targets the engineered liquidity the draw tag names. A gap left open below a bullish Unicorn range is intended: it shows intent and speed, and is not meant to be filled.

Method and repainting

All detection evaluates on closed bars. Swings, the structure break, the Breaker flip, the FVGs, the inversion and the Unicorn overlap are confirmed on candle close, never intrabar. Once a Unicorn is confirmed it is locked — it does not re-evaluate or flip state bar to bar — and invalidation counts only confirmed body closes, so an in-progress candle, wick included, never removes it. The Midnight Open fixes on its forming bar, and every level anchors to the candle that formed it.

Live zones and levels extend to the right edge for readability. That projection is cosmetic and changes no confirmed level, tap or raid.

Settings

Session timezone, right-side offset and label sizes. Bias mode and whether Unicorns are gated to it. Pivot strength. Liquidity display, per-side level caps, prior day and week levels with their lookbacks, and the raid-relevance window. Session tagging and the three session windows. FVG minimum height and displacement size, both in ATR, the declutter, the cap on live gaps, the framing IFVG, and how many body closes retire a zone. Unicorn colours. Dashboard position, including middle right, and text size.

Analytics only

This is a decision-support tool for discretionary ICT study. It maps zones, structure and context. It contains no alerts and no buy or sell signals, and it does not tell you when to enter or exit. The draw marker is a text label that appears only after a Unicorn has set up and liquidity has been swept, pointing at a liquidity target — not a trade instruction.

Disclaimer

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
//
// ═══════════════════════════════════════════════════════════════════════════
//  UNICORN MODEL   ·   ICT
//  ───────────────────────────────────────────────────────────────────────────
//  Maps the ICT Unicorn: the setup where a Fair Value Gap overlaps a Breaker
//  Block of the same direction. That overlap is a precise, high-probability entry
//  zone — the two arrays reinforcing each other at one price. This tool finds it
//  and frames its context; it does not fire trades.
//
//  The sequence it looks for (bullish; bearish mirrors):
//    1. Liquidity is taken — price sweeps a sellside low, engineering the reversal.
//    2. A swing is broken — displacement CLOSES through the last swing high (MSS). The run
//       before that leg is left behind as an Order Block; it becomes a Breaker only once
//       price later CLOSES back through it (the OB failing, like an FVG inverting to IFVG).
//    3. The FVG inverts onto the Breaker — as displacement closes through the gap it
//       fails and flips into an Inversion FVG (IFVG). A Breaker a same-side IFVG
//       overlaps IS the Unicorn — the inversion is what confirms it.
//    4. Bias frames it — the model needs a clear HTF read, so a bullish Unicorn is
//       shown in a bullish/discount context, a bearish one in premium.
//    5. The draw — engineered liquidity in the direction of bias is the target the
//       setup delivers toward.
//
//  What it draws: the Breaker and the Inversion FVG that confirms it. When a same-side
//  IFVG overlaps the Breaker, that Breaker IS the Unicorn — it is labelled "Unicorn +" /
//  "Unicorn -" and takes the bolder Unicorn hue, and the IFVG it sits on is shaded
//  orange (no label). No overlapping IFVG means it stays a plain Breaker. Swing
//  highs/lows show as buyside/sellside liquidity — only while live, removed the moment
//  they are taken. A dashboard reads bias, the live Unicorn, the raided liquidity and
//  the current draw.
//
//  Visual grammar: only live liquidity is shown — a level is removed the instant it
//  is taken, so nothing lingers once it has done its job, and nothing is left to
//  hang far off the price action. FVGs draw blue (bullish) / red (bearish) and Breakers
//  black; a Breaker a same-side IFVG overlaps becomes the Unicorn, drawn in the brand
//  purple / magenta with a DASHED border to set it apart; the inversion FVG it sits
//  inside is orange. External-range liquidity is tagged Buyside/Sellside; the
//  intermediate swings between them carry a $$$ marker, and tags at the same price merge.
//  Levels anchor to the candle that formed them; zones extend right until price
//  closes through them or trends away and leaves them stale, so the chart keeps only
//  the structure still near price.
//
//  Method & repainting: all detection evaluates on closed bars. The Midnight Open
//  and dealing range fix on their forming bar. A decision-support tool for
//  discretionary ICT trading — not financial advice.
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Unicorn Model", "ICT Unicorn (M1D)", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// ============================================================================
// INPUTS
// ============================================================================
const string G_GEN  = "General"
const string G_BIAS = "HTF Bias"
const string G_STR  = "Swing Structure"
const string G_LIQ  = "Liquidity"
const string G_SESS = "Sessions"
const string G_PDA  = "Breaker & FVG"
const string G_UNI  = "Unicorn"
const string G_DASH = "Dashboard"

string tzInput      = input.string("America/New_York", "Session Timezone", options = ["America/New_York", "Europe/London", "Australia/Sydney", "UTC"], group = G_GEN)
int    rightOffset  = input.int(8, "Right-side offset (bars)", minval = 0, maxval = 30, group = G_GEN, tooltip = "Lines & boxes project this many bars past the last candle so labels sit in clear space, never on price.")
string levelLabelSz = input.string("normal", "Line label size", options = ["tiny", "small", "normal", "large"], group = G_GEN)
string zoneLabelSz  = input.string("small",  "Zone label size", options = ["tiny", "small", "normal", "large"], group = G_GEN)

string biasMode  = input.string("Auto", "HTF Bias", options = ["Auto", "Bullish", "Bearish"], group = G_BIAS, tooltip = "The Unicorn needs a clear HTF narrative. Auto reads it from the dealing range (discount = bullish, premium = bearish) stacked with the Midnight Open. Set Bullish/Bearish to force your own HTF read.")
bool   gateBias  = input.bool(true, "Only show Unicorns aligned to bias", group = G_BIAS, tooltip = "ON: a bullish Unicorn shows only in a bullish/discount read, a bearish one only in premium. When the auto read is MIXED both are shown. OFF: flag every FVG∩Breaker overlap.")
bool   showMidnight = input.bool(true, "Show Midnight Open (00:00 NY)", group = G_BIAS, tooltip = "The 00:00 NY open — a core ICT daily reference. Below it leans bullish, above it leans bearish. Feeds the auto bias.")
color  midnightCol  = input.color(color.new(color.gray, 0), "Midnight Open colour", group = G_BIAS)

int pivLeft  = input.int(5, "Pivot Left Strength",  minval = 1, group = G_STR)
int pivRight = input.int(3, "Pivot Right Strength", minval = 1, group = G_STR)

bool  showLiq    = input.bool(true, "Show Buyside / Sellside Liquidity", group = G_LIQ)
color liqColor   = input.color(color.black, "Liquidity line", group = G_LIQ, inline = "lq")
int   liqWidth   = input.int(1, "", minval = 1, maxval = 4, group = G_LIQ, inline = "lq")
bool  showLiqLabels = input.bool(true, "Label liquidity — external tag + Minor swings", group = G_LIQ, tooltip = "Tags the outermost live level each side as Buyside / Sellside Liquidity (external-range liquidity) and marks the intermediate swings as Minor Buyside / Minor Sellside. Buyside labels sit at the right edge on the line, sellside labels at their origin (left) and below the line, to keep the live right edge clear.")
int   maxLiq     = input.int(6, "Max Live Swing Levels per Side", minval = 1, maxval = 20, group = G_LIQ)
bool  showMTF    = input.bool(true, "Prior Day / Week levels (PDH·PDL·PWH·PWL)", group = G_LIQ, tooltip = "External-range reference liquidity — prior day and prior week highs and lows. They obey the same rule as every level: removed the instant they are taken, and cleared if price trends far past.")
int   pdBack     = input.int(2, "Days back", minval = 1, maxval = 5, group = G_LIQ, inline = "mtf")
int   pwBack     = input.int(1, "Weeks back", minval = 1, maxval = 3, group = G_LIQ, inline = "mtf")
int   sweepMemory = input.int(30, "Raid Relevance Window (bars)", minval = 1, group = G_LIQ, tooltip = "How recently liquidity must have been taken to still read as the raid that set up the Unicorn.")

bool   showSessTags = input.bool(true, "Tag session highs / lows", group = G_SESS, tooltip = "When a liquidity level is the high or low of a session's window, label it (e.g. NY High, London Low). Windows below are in the Session Timezone (General).")
string asiaSess     = input.session("2000-0000", "Asia window",     group = G_SESS)
string londonSess   = input.session("0200-0500", "London window",   group = G_SESS)
string nySess       = input.session("0700-1000", "New York window", group = G_SESS)

bool  showPD      = input.bool(true, "Show Breaker & overlapping FVG", group = G_PDA, tooltip = "The two ingredients of the Unicorn.")
color bullZoneCol = input.color(color.new(#1E90FF, 82), "FVG Bull", group = G_PDA, inline = "pd")
color bearZoneCol = input.color(color.new(#CC0000, 82), "Bear", group = G_PDA, inline = "pd")
color brkCol      = input.color(color.new(color.black, 82), "Breaker", group = G_PDA, tooltip = "Breakers are drawn in their own neutral colour, separate from the blue/red FVGs — a Breaker only becomes a coloured (Unicorn) zone once an FVG overlaps it.")
float minFvgAtr   = input.float(0.15, "FVG sensitivity — min height (× ATR)", minval = 0.0, step = 0.05, group = G_PDA, tooltip = "Higher = only larger, more significant gaps register.")
float dispMult    = input.float(1.0, "Displacement body (× ATR)", minval = 0.1, step = 0.1, group = G_PDA, tooltip = "The leg breaking the swing must have a body this large — higher = only violent, reliable displacement.")
bool  declutterPD = input.bool(true, "Declutter — biggest array wins", group = G_PDA, tooltip = "When arrays overlap in the same price area, keep the LARGEST and remove the smaller overlapping ones.")
bool  showIFVG    = input.bool(true, "Show the IFVG the Unicorn sits inside", group = G_PDA, tooltip = "A mitigated FVG inverts (flips polarity) into an IFVG. When one frames a Unicorn Breaker it is shaded orange — no label, orange reads as IFVG.")
color ifvgCol     = input.color(color.new(#FF9500, 70), "IFVG (orange)", group = G_PDA)
int   maxZones    = input.int(6, "Max Live Zones per Type", minval = 1, maxval = 20, group = G_PDA)
int   maxFvgLive  = input.int(3, "Max FVGs shown at once", minval = 1, maxval = 3, group = G_PDA, tooltip = "Hard cap on how many Fair Value Gaps are drawn at once — the oldest drops off as new ones form, so gaps never stack up. Breakers, Unicorns and IFVGs are capped separately by Max Live Zones per Type.")
int   invalidCloses = input.int(2, "Invalidate a zone after N body closes through", minval = 1, maxval = 5, group = G_PDA, tooltip = "A zone (FVG, Breaker, Unicorn, IFVG) is invalidated only when the candle BODY has closed through it this many times in total — WICKS never count. 2 = a wick or a single close-through is tolerated; a second body close (cumulative) kills it. Higher = holds longer. Once a Unicorn is confirmed it stays confirmed until invalidated this way (it does not repaint).")
int   staleBars   = input.int(40, "Retire zone / level after N bars away", minval = 5, group = G_PDA, tooltip = "A zone or an un-taken liquidity level deletes itself once price has left it (by the distance below) and has not traded back within this many bars — clears trended-away bands and floating far-off levels so the chart stays near price.")
float staleRangeMult = input.float(1.0, "…once price is this far past it (× recent range)", minval = 0.25, step = 0.25, group = G_PDA, tooltip = "How far past a level/zone price must travel before it retires, in multiples of the recent price envelope (the on-screen band). 1.0 = a full range off-screen. Higher keeps far levels longer; on-screen levels are always kept.")
int   tapMemory   = input.int(8, "Tap Memory (bars)", minval = 1, group = G_PDA, tooltip = "How recently a Unicorn must have formed to still read as live context in the dashboard.")

bool  showUnicorn = input.bool(true, "Flag Unicorns", group = G_UNI, inline = "uni", tooltip = "A Breaker a live same-side IFVG overlaps is the Unicorn — the inversion gap sitting on the Breaker is what confirms it. Relabelled Unicorn + / Unicorn - and drawn in the bolder hue below.")
color uniBullCol  = input.color(color.new(#7246CE, 45), "Bull", group = G_UNI, inline = "uni")
color uniBearCol  = input.color(color.new(#DB1D9C, 45), "Bear", group = G_UNI, inline = "uni")

bool   showDash  = input.bool(true, "Show Dashboard", group = G_DASH)
string dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G_DASH)
string dashSize  = input.string("small", "Dashboard Text Size", options = ["tiny", "small", "normal", "large"], group = G_DASH)

// ============================================================================
// SHARED CONTEXT & HELPERS
// ============================================================================
float atrVal   = ta.atr(14)
float envRange = ta.highest(200) - ta.lowest(200)  // recent price envelope — the on-screen band

//@function True once price has trended more than a recent envelope past a zone and has
//          not traded back into it within staleBars — the band is now off the price
//          action and should retire rather than hang far away and skew the scale. Using
//          the envelope (not a fixed ATR distance) keeps on-screen levels while clearing
//          only the genuinely far-off ones.
//@param top (float) Zone top.
//@param bottom (float) Zone bottom.
//@param lastTouch (int) Bar index price was last inside the zone.
//@returns (bool) Whether the zone is stale and should be deleted.
zoneStale(float top, float bottom, int lastTouch) =>
    float dist = math.max(bottom - close, close - top)  // > 0 once price sits outside the zone
    not na(lastTouch) and bar_index - lastTouch > staleBars and dist > staleRangeMult * envRange

//@function Short tag for the chart timeframe — the "M" / "H" / "D" marker on each zone.
//@returns (string) e.g. "M5", "M15", "H1", "D".
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

//@function Line-label (text only, colour-matched), anchored at the right edge.
//@param x (int) Bar index anchor.
//@param y (float) Price anchor.
//@param txt (string) Label text.
//@param col (color) Text colour.
//@param sz (string) Size constant.
//@returns (label) The created label.
mkLineLabel(int x, float y, string txt, color col, string sz) =>
    label l = label.new(x, y, txt, xloc.bar_index, yloc.price, color(na), label.style_none, col, sz)
    label.set_text_font_family(l, font.family_monospace)
    l

//@function Box label centred exactly on its anchor (label_center, no bubble).
//@param x (int) Bar index anchor.
//@param y (float) Price anchor.
//@param txt (string) Label text.
//@param col (color) Text colour.
//@param sz (string) Size constant.
//@returns (label) The created label.
mkBoxLabel(int x, float y, string txt, color col, string sz) =>
    label l = label.new(x, y, txt, xloc.bar_index, yloc.price, color(na), label.style_label_center, col, sz)
    label.set_text_font_family(l, font.family_monospace)
    l

// ============================================================================
// MIDNIGHT OPEN (00:00 NY) — bias anchor
// ----------------------------------------------------------------------------
// The 00:00 NY open is a core ICT reference: trading BELOW it leans the day
// bullish (price is discounted vs the daily open), ABOVE it leans bearish. A
// reference midline, so it draws DOTTED. Reset on the first bar of NY 00:00.
// ============================================================================
var float midnightOpen = na
var line  mnLine  = na
var label mnLabel = na
bool newMidnight = timeframe.isintraday and hour(time, tzInput) == 0 and (na(time[1]) or hour(time[1], tzInput) != 0)
if barstate.isconfirmed
    if newMidnight
        midnightOpen := open
        if showMidnight
            line.delete(mnLine)
            label.delete(mnLabel)
            mnLine := line.new(bar_index, midnightOpen, bar_index + rightOffset, midnightOpen, xloc = xloc.bar_index, color = midnightCol, style = line.style_dotted, width = 1)
            mnLabel := mkLineLabel(bar_index + rightOffset, midnightOpen, "12am Open", midnightCol, levelLabelSize)
    if not na(mnLine)
        line.set_x2(mnLine, bar_index + rightOffset)
    if not na(mnLabel)
        label.set_x(mnLabel, bar_index + rightOffset)

// ============================================================================
// MODULE 1 — SWING STRUCTURE
// ----------------------------------------------------------------------------
// Swings are the spine of the model: liquidity rests at them, the swing BREAK is
// the MSS that mints the Breaker, and the dealing-range midpoint separates premium
// from discount for the bias read.
// ============================================================================
float ph = ta.pivothigh(high, pivLeft, pivRight)
float pl = ta.pivotlow(low, pivLeft, pivRight)
bool newPH = not na(ph)
bool newPL = not na(pl)
int phBar = bar_index - pivRight
int plBar = bar_index - pivRight

var float lastSwingHigh = na
var float lastSwingLow  = na
if barstate.isconfirmed
    if newPH
        lastSwingHigh := ph
    if newPL
        lastSwingLow := pl

float equilibrium = not na(lastSwingHigh) and not na(lastSwingLow) and lastSwingHigh > lastSwingLow ? math.avg(lastSwingHigh, lastSwingLow) : na

// ============================================================================
// MODULE 2 — HTF BIAS (auto + manual override)
// ----------------------------------------------------------------------------
// Auto stacks two ICT references: dealing-range position (discount = bullish,
// premium = bearish) and the Midnight Open (below = bullish, above = bearish).
// Both agreeing is conviction; a split is MIXED. A manual choice overrides it.
// biasDir: 1 = bullish, -1 = bearish, 0 = mixed / no read.
// ============================================================================
bool mnBull = not na(midnightOpen) and close < midnightOpen
bool mnBear = not na(midnightOpen) and close > midnightOpen
bool pdBull = not na(equilibrium) and close < equilibrium
bool pdBear = not na(equilibrium) and close > equilibrium
int  biasBull = (mnBull ? 1 : 0) + (pdBull ? 1 : 0)
int  biasBear = (mnBear ? 1 : 0) + (pdBear ? 1 : 0)
int  autoDir = biasBull > biasBear ? 1 : biasBear > biasBull ? -1 : 0
int  biasDir = biasMode == "Bullish" ? 1 : biasMode == "Bearish" ? -1 : autoDir

bool bullBiasOK = not gateBias or biasDir >= 0
bool bearBiasOK = not gateBias or biasDir <= 0

// ============================================================================
// MODULE 3 — LIQUIDITY (swing highs = BSL · swing lows = SSL)
// ----------------------------------------------------------------------------
// Stops rest above swing highs (buy-side) and below swing lows (sell-side). Each
// confirmed swing seeds a level, anchored to the candle that formed it. The instant
// price takes a level it is removed — taken liquidity has done its job and never
// lingers. A level price simply trends far past without returning also retires, so
// nothing hangs in empty space off the price action.
// ============================================================================
type Liq
    float  price
    int    originBar
    bool   isBSL
    string fam = ""    // "" = swing; "PDH"/"PDL"/"PWH"/"PWL" = prior-period family
    string tag = ""    // fixed display label for prior-period levels (dated)
    int    lastTouch = na
    line   ln = na
    label  lbl = na

var array<Liq> liqs = array.new<Liq>()
var int   lastBuysideRaidBar = na
var int   lastSellsideRaidBar = na
var float lastBuysideRaidPx = na
var float lastSellsideRaidPx = na
var int   lastBuysideDrawBar = na   // bar the EXTERNAL buyside draw was taken (a setup's DOL)
var float lastBuysideDrawPx = na
var int   lastSellsideDrawBar = na
var float lastSellsideDrawPx = na
var bool  uniLiveForDraw = false    // prior-bar: is a Unicorn live? (gates the "Draw" label)
var int   uniDirForDraw = 0         // prior-bar: that Unicorn's direction (1 bull / -1 bear)
var int   drawDirShown = 0          // the gated draw, computed ONCE per bar — the single source of
var float drawPxShown = na          // truth read by BOTH the chart × Draw label and the dashboard

//@type Prior-period high/low tracker — records the ORIGIN BAR of the running extreme
//      so a prior day/week level anchors to the candle that made it.
type Trk
    float hi = na
    float lo = na
    int   hiBar = na
    int   loBar = na
    float cHi = na
    float cLo = na
    int   cHiBar = na
    int   cLoBar = na

//@function Rolls the tracker each bar; on a period change it snapshots the closed
//          period's extremes (with their origin bars) and resets for the new one.
//@param t (Trk) The tracker.
//@param isRoll (bool) True on the first bar of a new period.
//@returns (bool) True when a period just closed and a snapshot is ready.
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

var Trk dayTrk  = Trk.new()
var Trk weekTrk = Trk.new()
var float pdhPx = na  // prior-day high / low — tracked for the dashboard even when the lines are hidden
var float pdlPx = na
bool newDay  = timeframe.change("D")
bool newWeek = timeframe.change("W")

//@function Deletes a level's drawings (line + label).
//@param lv (Liq) The level to clear.
//@returns (bool) Always true (drawing side-effect only).
delLiq(Liq lv) =>
    line.delete(lv.ln)
    label.delete(lv.lbl)
    true

//@function Keeps at most `maxLiq` live SWING levels per side, shedding the oldest
//          first while over budget so the chart stays readable. Prior-period levels
//          are capped separately by pruneFam and are not counted here.
//@param isBSL (bool) Side to prune — true = buy-side.
//@returns (bool) Always true.
pruneLiq(bool isBSL) =>
    int cnt = 0
    if liqs.size() > 0
        for i = 0 to liqs.size() - 1
            if liqs.get(i).isBSL == isBSL and liqs.get(i).fam == ""
                cnt += 1
    while cnt > maxLiq
        int idx = -1
        if liqs.size() > 0
            for i = 0 to liqs.size() - 1
                if idx == -1 and liqs.get(i).isBSL == isBSL and liqs.get(i).fam == ""
                    idx := i
        if idx == -1
            cnt := maxLiq
        else
            delLiq(liqs.get(idx))
            liqs.remove(idx)
            cnt -= 1
    true

//@function Keeps at most `cap` levels of a prior-period family (e.g. "PDH"), dropping
//          the oldest as newer periods close.
//@param fam (string) The family key to limit.
//@param cap (int) Maximum same-family levels to retain.
//@returns (bool) Always true.
pruneFam(string fam, int cap) =>
    int cnt = 0
    if liqs.size() > 0
        for i = 0 to liqs.size() - 1
            if liqs.get(i).fam == fam
                cnt += 1
    while cnt > cap
        int idx = -1
        if liqs.size() > 0
            for i = 0 to liqs.size() - 1
                if idx == -1 and liqs.get(i).fam == fam
                    idx := i
        if idx == -1
            cnt := cap
        else
            delLiq(liqs.get(idx))
            liqs.remove(idx)
            cnt -= 1
    true

//@function Seeds a liquidity level, anchored at the candle that formed it. A swing
//          passes fam = "" (capped per side); a prior-period level passes its family
//          and dated tag (capped per family). Every level obeys the same rule: removed
//          on take, retired if price trends far past.
//@param price (float) Level price.
//@param originBar (int) Bar the extreme printed.
//@param isBSL (bool) Side — true = buy-side.
//@param fam (string) "" for a swing, else the prior-period family key.
//@param tag (string) Fixed display label for a prior-period level.
//@param cap (int) Family cap (prior-period only).
//@returns (bool) Always true.
addLiq(float price, int originBar, bool isBSL, string fam, string tag, int cap) =>
    Liq lv = Liq.new(price, originBar, isBSL)
    lv.fam := fam
    lv.tag := tag
    lv.lastTouch := originBar
    if showLiq
        lv.ln := line.new(originBar, price, bar_index + rightOffset, price, xloc = xloc.bar_index, color = liqColor, style = line.style_solid, width = liqWidth)
        if showLiqLabels
            // Swing text is set by refreshLiqLabels once the external rank is known;
            // a prior-period level carries its fixed dated tag from the start.
            lv.lbl := mkLineLabel(bar_index + rightOffset, price, fam == "" ? (isBSL ? "Minor Buyside" : "Minor Sellside") : tag, liqColor, levelLabelSize)
    liqs.push(lv)
    if fam == ""
        pruneLiq(isBSL)
    else
        pruneFam(fam, cap)
    while liqs.size() > 60
        delLiq(liqs.shift())
    true

//@function Extends live levels and removes each the instant it is taken — or once it
//          trends far past and goes stale. Also flags whether the level taken was the
//          EXTERNAL (outermost) pool its side — the draw a setup delivers to. (Pine
//          forbids writing globals in a function, so the caller records the result.)
//@returns (tuple) [buysideRaided, buysidePx, sellsideRaided, sellsidePx, buysideExternal, sellsideExternal].
scanLiq() =>
    bool  bsRaid = false
    float bsPx   = na
    bool  ssRaid = false
    float ssPx   = na
    bool  bsExt  = false
    bool  ssExt  = false
    // The extremes of live liquidity BEFORE this bar's raids — the outermost buyside and
    // sellside are the external-range draws; anything inside them is internal liquidity.
    float topBSL = na
    float botSSL = na
    if liqs.size() > 0
        for j = 0 to liqs.size() - 1
            Liq lp = liqs.get(j)
            if lp.isBSL
                topBSL := na(topBSL) or lp.price > topBSL ? lp.price : topBSL
            else
                botSSL := na(botSSL) or lp.price < botSSL ? lp.price : botSSL
    if liqs.size() > 0
        for i = liqs.size() - 1 to 0
            Liq lv = liqs.get(i)
            if low <= lv.price and high >= lv.price
                lv.lastTouch := bar_index
            bool raided = lv.isBSL ? high > lv.price : low < lv.price
            if raided
                // Taken liquidity is removed the instant price trades through it — record the
                // raid (keeping the furthest one) and flag whether it was the external draw,
                // then delete the level outright.
                if lv.isBSL
                    bsRaid := true
                    bsPx := na(bsPx) or lv.price > bsPx ? lv.price : bsPx
                    if not na(topBSL) and lv.price >= topBSL
                        bsExt := true
                else
                    ssRaid := true
                    ssPx := na(ssPx) or lv.price < ssPx ? lv.price : ssPx
                    if not na(botSSL) and lv.price <= botSSL
                        ssExt := true
                delLiq(lv)
                liqs.remove(i)
            else if zoneStale(lv.price, lv.price, lv.lastTouch)
                // A level price has trended far past and not returned to also clears,
                // so no old level hangs in empty space off the price action.
                delLiq(lv)
                liqs.remove(i)
            else if not na(lv.ln)
                line.set_x2(lv.ln, bar_index + rightOffset)
    [bsRaid, bsPx, ssRaid, ssPx, bsExt, ssExt]

//@function Nearest live opposing liquidity in the bias direction — the draw the
//          Unicorn delivers toward (nearest buyside above in a bullish read, nearest
//          sellside below in a bearish one).
//@param dir (int) Bias direction: 1 = bullish, -1 = bearish.
//@returns (float) The target price, or na if there is none or no directional bias.
nearestDraw(int dir) =>
    float px = na
    if liqs.size() > 0
        for i = 0 to liqs.size() - 1
            Liq lv = liqs.get(i)
            if dir == 1 and lv.isBSL and lv.price > close
                px := na(px) or lv.price < px ? lv.price : px
            else if dir == -1 and not lv.isBSL and lv.price < close
                px := na(px) or lv.price > px ? lv.price : px
    px

//@function The price of the most-recently-formed LIVE level of a prior-period family (e.g.
//          "PDL"). Reads the same liquidity array the chart draws, so the dashboard matches
//          the chart exactly — once price takes a prior-day level it is removed here too, and
//          the row falls back to the next live one (never a stale, already-taken value).
//@param fam (string) The family key — "PDH" / "PDL" / "PWH" / "PWL".
//@returns (float) The level price, or na if none of that family is live.
famLevel(string fam) =>
    float px = na
    int   ob = na
    if liqs.size() > 0
        for i = 0 to liqs.size() - 1
            Liq lv = liqs.get(i)
            if lv.fam == fam and (na(ob) or lv.originBar > ob)
                ob := lv.originBar
                px := lv.price
    px

// ── Session windows — track the high & low (and the bars they printed) of the Asia,
//    London and NY windows so a level that IS a session extreme can be tagged with which.
type Sess
    float hi = na
    float lo = na
    int   hiBar = na
    int   loBar = na
    bool  active = false

//@function Rolls a session tracker: resets on the first in-window bar, then follows the
//          running high/low and the bars they print; goes idle out of window.
//@param s (Sess) The session tracker.
//@param inSess (bool) Whether this bar is inside the session window.
//@returns (bool) Always true.
method step(Sess s, bool inSess) =>
    if inSess
        if not s.active
            s.hi := high
            s.lo := low
            s.hiBar := bar_index
            s.loBar := bar_index
            s.active := true
        else
            if high > s.hi
                s.hi := high
                s.hiBar := bar_index
            if low < s.lo
                s.lo := low
                s.loBar := bar_index
    else
        s.active := false
    true

var Sess asia   = Sess.new()
var Sess london = Sess.new()
var Sess ny     = Sess.new()

//@function Tags a level that is a session extreme — the high or low of the Asia, London or
//          NY window — by matching its origin bar to that session's high / low bar.
//@param ob (int) The level's origin bar.
//@param isBSL (bool) Side — true = buy-side (a high), false = sell-side (a low).
//@returns (string) e.g. "NY High" / "London Low", or "" if it is not a session extreme.
sessTag(int ob, bool isBSL) =>
    string t = ""
    if showSessTags and not na(ob)
        if isBSL
            t := ob == asia.hiBar ? "Asia High" : ob == london.hiBar ? "London High" : ob == ny.hiBar ? "NY High" : ""
        else
            t := ob == asia.loBar ? "Asia Low" : ob == london.loBar ? "London Low" : ob == ny.loBar ? "NY Low" : ""
    t

//@function Refreshes right-edge labels: Buyside/Sellside Liquidity on the outermost swing
//          each side, Minor Buyside/Sellside on inner swings, dated tags on prior-period
//          levels, and a session-extreme tag (e.g. NY High) where one applies. The draw and
//          a coinciding Midnight Open are appended to that one tag (the standalone hides).
//@returns (bool) Always true.
refreshLiqLabels() =>
    if showLiqLabels and liqs.size() > 0
        float hiBSL = na
        float loSSL = na
        for i = 0 to liqs.size() - 1
            Liq lv = liqs.get(i)
            if lv.fam == ""
                if lv.isBSL
                    hiBSL := na(hiBSL) or lv.price > hiBSL ? lv.price : hiBSL
                else
                    loSSL := na(loSSL) or lv.price < loSSL ? lv.price : loSSL
        // The Draw reads the single shared value computed once this bar (drawPxShown) — the exact
        // same number the dashboard shows, so the chart × Draw label and the dashboard can never
        // disagree. It is non-na only once a Unicorn is live and its setup-side liquidity was swept.
        float drawPx = drawPxShown
        float mnTol  = atrVal * 0.3
        float clTol  = atrVal * 0.6
        bool  mnMerged = false
        // Collect each labelled level, then cluster any within clTol into one tag. A
        // standalone external swing keeps its Buyside/Sellside wording; the moment it
        // merges, all swing members collapse to a single $$$ ($$$ already means
        // liquidity), while prior-period levels keep their dated tags.
        array<float>  cp   = array.new<float>()
        array<string> cfam = array.new<string>()
        array<string> ctag = array.new<string>()
        array<bool>   cext = array.new<bool>()
        array<bool>   cbsl = array.new<bool>()
        array<int>    cob  = array.new<int>()
        array<label>  cl   = array.new<label>()
        for i = 0 to liqs.size() - 1
            Liq lv = liqs.get(i)
            if not na(lv.lbl)
                cp.push(lv.price)
                cfam.push(lv.fam)
                ctag.push(lv.tag)
                cext.push(lv.fam == "" and (lv.isBSL ? lv.price == hiBSL : lv.price == loSSL))
                cbsl.push(lv.isBSL)
                cob.push(lv.originBar)
                cl.push(lv.lbl)
        int m = cp.size()
        if m > 0
            array<bool> used = array.new<bool>(m, false)
            for i = 0 to m - 1
                if not used.get(i)
                    used.set(i, true)
                    string mtfPart = cfam.get(i) != "" ? ctag.get(i) : ""
                    bool hasSwing = cfam.get(i) == ""
                    int  clSize = 1
                    bool anyDraw = not na(drawPx) and cp.get(i) == drawPx
                    bool anyMn = showMidnight and not na(midnightOpen) and math.abs(cp.get(i) - midnightOpen) <= mnTol
                    if i < m - 1
                        for j = i + 1 to m - 1
                            if not used.get(j) and math.abs(cp.get(j) - cp.get(i)) <= clTol
                                used.set(j, true)
                                clSize += 1
                                if cfam.get(j) != ""
                                    mtfPart := mtfPart == "" ? ctag.get(j) : mtfPart + "  +  " + ctag.get(j)
                                else
                                    hasSwing := true
                                if not na(drawPx) and cp.get(j) == drawPx
                                    anyDraw := true
                                if showMidnight and not na(midnightOpen) and math.abs(cp.get(j) - midnightOpen) <= mnTol
                                    anyMn := true
                                label.set_textcolor(cl.get(j), color.new(liqColor, 100))  // hide the merged tag
                    string swingPart = hasSwing ? ((clSize == 1 and cext.get(i)) ? (cbsl.get(i) ? "Buyside Liquidity" : "Sellside Liquidity") : (cbsl.get(i) ? "Minor Buyside" : "Minor Sellside")) : ""
                    string combined = mtfPart
                    if swingPart != ""
                        combined := combined == "" ? swingPart : combined + "  +  " + swingPart
                    string sTag = sessTag(cob.get(i), cbsl.get(i))
                    if sTag != ""
                        combined := combined == "" ? sTag : combined + "  ·  " + sTag
                    if anyDraw
                        combined := combined + "  × Draw"
                    if anyMn
                        combined := combined + "  · 12am Open"
                        mnMerged := true
                    // Buyside labels trail the right edge on the line; sellside labels sit back
                    // at their origin (left) and drop BELOW the line (style_label_up hangs the
                    // text under the anchor, transparent bubble) so they clear the price action.
                    int lblX = cbsl.get(i) ? bar_index + rightOffset : cob.get(i)
                    label.set_xy(cl.get(i), lblX, cp.get(i))
                    label.set_style(cl.get(i), cbsl.get(i) ? label.style_none : label.style_label_up)
                    label.set_text(cl.get(i), combined)
                    label.set_textcolor(cl.get(i), liqColor)
        if not na(mnLabel)
            label.set_textcolor(mnLabel, mnMerged ? color.new(midnightCol, 100) : midnightCol)
    true

if barstate.isconfirmed
    if newPH
        addLiq(ph, phBar, true, "", "", maxLiq)
    if newPL
        addLiq(pl, plBar, false, "", "", maxLiq)
    if timeframe.isintraday
        if dayTrk.roll(newDay)
            pdhPx := dayTrk.cHi
            pdlPx := dayTrk.cLo
            if showMTF
                string dt = str.format_time(time[1], "dd/MM", tzInput)
                addLiq(dayTrk.cHi, dayTrk.cHiBar, true,  "PDH", "PDH " + dt, pdBack)
                addLiq(dayTrk.cLo, dayTrk.cLoBar, false, "PDL", "PDL " + dt, pdBack)
        if showMTF and weekTrk.roll(newWeek)
            string wt = str.format_time(time[1], "dd/MM", tzInput)
            addLiq(weekTrk.cHi, weekTrk.cHiBar, true,  "PWH", "PWH " + wt, pwBack)
            addLiq(weekTrk.cLo, weekTrk.cLoBar, false, "PWL", "PWL " + wt, pwBack)
        if showSessTags
            asia.step(not na(time(timeframe.period, asiaSess, tzInput)))
            london.step(not na(time(timeframe.period, londonSess, tzInput)))
            ny.step(not na(time(timeframe.period, nySess, tzInput)))
    [bsRaid, bsPx, ssRaid, ssPx, bsExt, ssExt] = scanLiq()
    if bsRaid
        lastBuysideRaidBar := bar_index
        lastBuysideRaidPx  := bsPx
        if bsExt
            lastBuysideDrawBar := bar_index
            lastBuysideDrawPx  := bsPx
    if ssRaid
        lastSellsideRaidBar := bar_index
        lastSellsideRaidPx  := ssPx
        if ssExt
            lastSellsideDrawBar := bar_index
            lastSellsideDrawPx  := ssPx
    // Compute the gated draw ONCE per bar — the single source of truth both the chart × Draw
    // label and the dashboard Draw row read, so they are always identical (no direction or
    // one-bar mismatch). Fires only once a Unicorn is live and its setup-side liquidity was
    // swept: sellside swept → nearest buyside, buyside swept → nearest sellside; na otherwise.
    bool drawSellSwept = not na(lastSellsideRaidBar) and bar_index - lastSellsideRaidBar <= sweepMemory
    bool drawBuySwept  = not na(lastBuysideRaidBar)  and bar_index - lastBuysideRaidBar  <= sweepMemory
    drawDirShown := uniLiveForDraw and uniDirForDraw == 1 and drawSellSwept ? 1 : uniLiveForDraw and uniDirForDraw == -1 and drawBuySwept ? -1 : 0
    drawPxShown  := drawDirShown == 0 ? na : nearestDraw(drawDirShown)
    refreshLiqLabels()

bool buysideRaidRecent  = not na(lastBuysideRaidBar) and bar_index - lastBuysideRaidBar <= sweepMemory
bool sellsideRaidRecent = not na(lastSellsideRaidBar) and bar_index - lastSellsideRaidBar <= sweepMemory

// ============================================================================
// MODULE 4 — FVG (BISI / SIBI) + IFVG INVERSIONS
// ----------------------------------------------------------------------------
// The imbalance the displacement leaves behind. Drawn faintly; once a candle BODY closes
// through it the FVG does not simply vanish, it INVERTS: it flips polarity and lives on
// as an IFVG (support becomes resistance and vice-versa). That IFVG is what a Breaker
// overlaps to become a Unicorn — so the inversion, tracked here, is the real half of the
// setup; it is shaded orange later, but only while it frames a Unicorn.
// ============================================================================
type FVG
    float top
    float bottom
    int   leftBar
    bool  isBull
    int   lastTouch = na
    box   bx = na
    label lbl = na

type IFVG
    float top
    float bottom
    int   originBar
    bool  isBull        // polarity AFTER inversion — flipped from the source FVG
    int   lastTouch = na
    int   strikes = 0
    box   bx = na

var array<FVG>  fvgs  = array.new<FVG>()
var array<IFVG> ifvgs = array.new<IFVG>()

bool bullFvgNew = barstate.isconfirmed and low > high[2] and (low - high[2]) >= atrVal * minFvgAtr
bool bearFvgNew = barstate.isconfirmed and high < low[2] and (low[2] - high) >= atrVal * minFvgAtr

//@function Biggest-wins declutter for FVGs. Removes live FVGs that price-overlap
//          the candidate and are smaller; returns false if an overlapping one is
//          already bigger (so the candidate is dropped).
//@param nTop (float) Candidate top.
//@param nBot (float) Candidate bottom.
//@returns (bool) Whether to keep the candidate.
fvgKeep(float nTop, float nBot) =>
    bool keep = true
    float nH = nTop - nBot
    if declutterPD and fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            FVG f = fvgs.get(i)
            if nTop >= f.bottom and nBot <= f.top
                if (f.top - f.bottom) >= nH
                    keep := false
                else
                    box.delete(f.bx)
                    label.delete(f.lbl)
                    fvgs.remove(i)
    keep

//@function Creates an FVG zone (faint tint, centred label) if it survives the
//          biggest-wins declutter.
//@param isBull (bool) Gap polarity — true = bullish (BISI).
//@returns (bool) Always true.
createFvg(bool isBull) =>
    float zTop = isBull ? low : low[2]
    float zBot = isBull ? high[2] : high
    if fvgKeep(zTop, zBot)
        int leftB = bar_index - 1
        FVG f = FVG.new(zTop, zBot, leftB, isBull)
        f.lastTouch := bar_index
        if showPD
            color zc = isBull ? bullZoneCol : bearZoneCol
            f.bx := box.new(leftB, zTop, bar_index + rightOffset, zBot, border_color = zc, border_width = 1, border_style = line.style_solid, bgcolor = zc)
            f.lbl := mkBoxLabel(int(math.avg(leftB, bar_index + rightOffset)), math.avg(zTop, zBot), (isBull ? "BISI +" : "SIBI -") + " " + tfTag(), isBull ? color.new(#0A3D91, 0) : color.new(color.black, 0), zoneLabelSize)
        fvgs.push(f)
        while fvgs.size() > maxFvgLive
            FVG old = fvgs.shift()
            box.delete(old.bx)
            label.delete(old.lbl)
    true

if bullFvgNew
    createFvg(true)
if bearFvgNew
    createFvg(false)

if barstate.isconfirmed
    if fvgs.size() > 0
        for i = fvgs.size() - 1 to 0
            FVG f = fvgs.get(i)
            if low <= f.top and high >= f.bottom
                f.lastTouch := bar_index
            // Inversion is by the candle BODY only — a wick or partial touch never counts.
            // One decisive body close THROUGH the gap flips it: the imbalance fails and lives
            // on as an IFVG of the opposite polarity (the ICT Inversion FVG). This is the gap
            // a Breaker overlaps, so the FVG must invert for a Unicorn to exist at all.
            bool through = f.isBull ? close < f.bottom : close > f.top
            if through
                // Mitigated FVG inverts — it flips polarity and persists as an IFVG.
                ifvgs.push(IFVG.new(f.top, f.bottom, f.leftBar, not f.isBull, bar_index))
                while ifvgs.size() > maxZones
                    IFVG oldIv = ifvgs.shift()
                    box.delete(oldIv.bx)
                box.delete(f.bx)
                label.delete(f.lbl)
                fvgs.remove(i)
            else if zoneStale(f.top, f.bottom, f.lastTouch)
                box.delete(f.bx)
                label.delete(f.lbl)
                fvgs.remove(i)
            else
                if not na(f.bx)
                    box.set_right(f.bx, bar_index + rightOffset)
                if not na(f.lbl)
                    label.set_x(f.lbl, int(math.avg(f.leftBar, bar_index + rightOffset)))
                    label.set_y(f.lbl, math.avg(f.top, f.bottom))

// ============================================================================
// MODULE 5 — ORDER BLOCK → BREAKER → UNICORN
// ----------------------------------------------------------------------------
// The displacement that breaks structure leaves an Order Block behind — the run of
// consecutive opposite-side closes immediately before it (a down-close run before an up
// break, an up-close run before a down break), its box spanning exactly those candles'
// high to low. That OB is tracked SILENTLY — it is NOT a Breaker yet. Only once price
// CLOSES THROUGH the OB — the OB failing and flipping, exactly as an FVG inverts into an
// IFVG — does it become a Breaker (drawn), of the opposite polarity to the OB. A Breaker
// a live same-direction IFVG overlaps IS the Unicorn — relabelled "Unicorn +" / "Unicorn -".
// ============================================================================
type SmartBlock
    float top
    float bottom
    int   originBar
    bool  obIsBull      // Order-block polarity: down-run = bullish OB, up-run = bearish OB
    bool  isBull = false // Breaker direction once the OB is passed through (= not obIsBull)
    int   stage = 0     // 0 = pending Order Block (undrawn), 1 = active Breaker (drawn)
    int   lastTouch = na
    bool  isUni = false
    int   uniBar = na   // bar this Breaker became a Unicorn (newest wins — one per swing)
    int   strikes = 0   // cumulative body closes through it — a wick does not count
    box   bx = na
    label lbl = na

var array<SmartBlock> blocks = array.new<SmartBlock>()
var int lastBullUniBar = na
var int lastBearUniBar = na
var int lastUniDir = 0  // direction of the most recently confirmed Unicorn: 1 = bull, -1 = bear
var bool lastUniDelivered = false  // true once that Unicorn retired by delivering to its draw

// The Order Block is a RUN of consecutive same-direction close candles, so the current run
// is tracked (its high, low and first bar) and snapshotted the moment the run flips — the
// completed run immediately before a displacement is the OB.
var float dnHi = na
var float dnLo = na
var int   dnStart = na
var int   dnEnd   = na
var bool  dnOpen  = false
var float upHi = na
var float upLo = na
var int   upStart = na
var int   upEnd   = na
var bool  upOpen  = false
var float lastDnHi = na
var float lastDnLo = na
var int   lastDnStart = na
var int   lastDnEnd   = na
var float lastUpHi = na
var float lastUpLo = na
var int   lastUpStart = na
var int   lastUpEnd   = na
var int   lastBullObOrigin = na
var int   lastBearObOrigin = na

//@function Biggest-wins declutter for blocks (by current box height).
//@param nTop (float) Candidate top.
//@param nBot (float) Candidate bottom.
//@returns (bool) Whether to keep the candidate.
blockKeep(float nTop, float nBot) =>
    bool keep = true
    float nH = nTop - nBot
    if declutterPD and blocks.size() > 0
        for i = blocks.size() - 1 to 0
            SmartBlock b = blocks.get(i)
            if nTop >= b.bottom and nBot <= b.top
                if (b.top - b.bottom) >= nH
                    keep := false
                else
                    box.delete(b.bx)
                    label.delete(b.lbl)
                    blocks.remove(i)
    keep

//@function Registers a PENDING Order Block (undrawn) if it survives declutter — the box
//          spans the OB candles' high/low. It draws only later, once price closes through
//          it and it flips into a Breaker.
//@param obIsBull (bool) Order-block polarity — down-run = bullish, up-run = bearish.
//@param top (float) OB high (run high).
//@param bottom (float) OB low (run low).
//@param originBar (int) First bar of the OB run.
//@returns (bool) Always true.
createOB(bool obIsBull, float top, float bottom, int originBar) =>
    if blockKeep(top, bottom)
        SmartBlock b = SmartBlock.new(top, bottom, originBar, obIsBull)
        b.lastTouch := bar_index
        blocks.push(b)
        while blocks.size() > maxZones
            SmartBlock old = blocks.shift()
            box.delete(old.bx)
            label.delete(old.lbl)
    true

//@function True when a live same-direction IFVG overlaps this Breaker's zone. The
//          IFVG — the imbalance that inverted as displacement closed through it — is
//          what makes a Breaker a Unicorn: no overlapping IFVG, no Unicorn, only a
//          plain Breaker. Bias-gated like the rest of the model.
//@param b (SmartBlock) The active Breaker to test.
//@returns (bool) Whether an IFVG frames this Breaker, so it qualifies as a Unicorn.
brkHostsUnicorn(SmartBlock b) =>
    bool biasOK = (b.isBull and bullBiasOK) or ((not b.isBull) and bearBiasOK)
    bool hosts = false
    if biasOK and ifvgs.size() > 0
        for ii = 0 to ifvgs.size() - 1
            IFVG iv = ifvgs.get(ii)
            if iv.isBull == b.isBull and b.bottom <= iv.top and b.top >= iv.bottom
                hosts := true
    hosts

if barstate.isconfirmed
    bool isDn = close < open
    bool isUp = close > open
    // Extend the current close-run, and snapshot the run that just ended when it flips —
    // the completed opposite-side run is what a displacement leaves behind as a Breaker.
    if isDn
        if not dnOpen
            dnStart := bar_index
            dnHi := high
            dnLo := low
            dnOpen := true
        else
            dnHi := math.max(dnHi, high)
            dnLo := math.min(dnLo, low)
        dnEnd := bar_index
        if upOpen
            lastUpHi := upHi
            lastUpLo := upLo
            lastUpStart := upStart
            lastUpEnd := upEnd
            upOpen := false
    else if isUp
        if not upOpen
            upStart := bar_index
            upHi := high
            upLo := low
            upOpen := true
        else
            upHi := math.max(upHi, high)
            upLo := math.min(upLo, low)
        upEnd := bar_index
        if dnOpen
            lastDnHi := dnHi
            lastDnLo := dnLo
            lastDnStart := dnStart
            lastDnEnd := dnEnd
            dnOpen := false
    else
        // A doji closes neither way — it ends whichever run was open.
        if dnOpen
            lastDnHi := dnHi
            lastDnLo := dnLo
            lastDnStart := dnStart
            lastDnEnd := dnEnd
            dnOpen := false
        if upOpen
            lastUpHi := upHi
            lastUpLo := upLo
            lastUpStart := upStart
            lastUpEnd := upEnd
            upOpen := false
    float bodySize = math.abs(close - open)
    bool bigBody = bodySize >= atrVal * dispMult
    // The displacement must CLOSE through the last swing (a real MSS). The Breaker is the
    // run of opposite-side closes immediately before it — the last down-close run for a
    // bullish break, the last up-close run for a bearish break — taken by its high/low.
    bool bullDisp = isUp and bigBody and not na(lastSwingHigh) and close > lastSwingHigh
    bool bearDisp = isDn and bigBody and not na(lastSwingLow) and close < lastSwingLow
    if bullDisp and not na(lastDnStart) and bar_index - lastDnEnd <= 5 and (na(lastBullObOrigin) or lastDnStart != lastBullObOrigin)
        createOB(true, lastDnHi, lastDnLo, lastDnStart)    // bullish OB — the down-close run before the up break
        lastBullObOrigin := lastDnStart
    if bearDisp and not na(lastUpStart) and bar_index - lastUpEnd <= 5 and (na(lastBearObOrigin) or lastUpStart != lastBearObOrigin)
        createOB(false, lastUpHi, lastUpLo, lastUpStart)   // bearish OB — the up-close run before the down break
        lastBearObOrigin := lastUpStart

if barstate.isconfirmed
    if blocks.size() > 0
        for i = blocks.size() - 1 to 0
            SmartBlock b = blocks.get(i)
            if low <= b.top and high >= b.bottom
                b.lastTouch := bar_index
            if b.stage == 0
                // Pending Order Block — it becomes a Breaker only once a candle BODY CLOSES
                // THROUGH it (the OB fails and flips, exactly as an FVG inverts into an IFVG).
                // A bullish OB closed below flips to a bearish Breaker; a bearish OB closed
                // above to a bullish one — then, and only then, is it drawn.
                bool passedThrough = bar_index > b.originBar and (b.obIsBull ? close < b.bottom : close > b.top)
                if passedThrough
                    b.stage := 1
                    b.isBull := not b.obIsBull
                    if showPD
                        b.bx  := box.new(b.originBar, b.top, bar_index + rightOffset, b.bottom, border_color = brkCol, border_width = 1, border_style = line.style_solid, bgcolor = brkCol)
                        b.lbl := mkBoxLabel(int(math.avg(b.originBar, bar_index + rightOffset)), math.avg(b.top, b.bottom), "Breaker " + tfTag(), color.new(color.black, 0), zoneLabelSize)
                else if zoneStale(b.top, b.bottom, b.lastTouch)
                    blocks.remove(i)  // OB never flipped and price left it — discard it
            else
                // Active Breaker. Opposite-direction body close (invalidCloses cumulative; a
                // wick never counts).
                bool through = b.isBull ? close < b.bottom : close > b.top
                if through
                    b.strikes := b.strikes + 1
                // Delivered — price took the EXTERNAL-range draw in the Breaker's direction (the
                // outermost buyside above a bullish Breaker, outermost sellside below a bearish
                // one). The setup reached its objective (the DOL), so per ICT it is spent and
                // retires; it rides through internal liquidity on the way, so it does NOT vanish
                // the moment price leaves the zone — only once the true draw is taken.
                bool delivered = (b.isBull and lastBuysideDrawBar == bar_index and not na(lastBuysideDrawPx) and lastBuysideDrawPx > b.top) or ((not b.isBull) and lastSellsideDrawBar == bar_index and not na(lastSellsideDrawPx) and lastSellsideDrawPx < b.bottom)
                if b.strikes >= invalidCloses or delivered or zoneStale(b.top, b.bottom, b.lastTouch)
                    // Keep a reference to a Unicorn that delivered — the dashboard reads it back
                    // as "(delivered)" so the setup is still legible after its box leaves.
                    if b.isUni and delivered
                        lastUniDir := b.isBull ? 1 : -1
                        lastUniDelivered := true
                    box.delete(b.bx)
                    label.delete(b.lbl)
                    blocks.remove(i)
                else
                    // Confirm a Unicorn ONCE and lock it — a Breaker a same-direction IFVG has
                    // overlapped stays a Unicorn, and that framing IFVG is kept alive with it, so
                    // the zone holds steady instead of repainting every bar.
                    if showUnicorn and not b.isUni and brkHostsUnicorn(b)
                        b.isUni := true
                        b.uniBar := bar_index
                        lastUniDir := b.isBull ? 1 : -1
                        lastUniDelivered := false
                        color zc = b.isBull ? uniBullCol : uniBearCol
                        if not na(b.bx)
                            box.set_bgcolor(b.bx, zc)
                            // A Unicorn takes a visible DASHED border to set it apart from the
                            // solid-bordered arrays.
                            box.set_border_color(b.bx, color.new(zc, 0))
                            box.set_border_style(b.bx, line.style_dashed)
                        if not na(b.lbl)
                            label.set_text(b.lbl, (b.isBull ? "Unicorn +" : "Unicorn -") + " " + tfTag())
                            label.set_textcolor(b.lbl, color.new(color.black, 0))
                    if b.isUni
                        if b.isBull
                            lastBullUniBar := bar_index
                        else
                            lastBearUniBar := bar_index
                    if not na(b.bx)
                        box.set_right(b.bx, bar_index + rightOffset)
                        if not na(b.lbl)
                            label.set_x(b.lbl, int(math.avg(b.originBar, bar_index + rightOffset)))
                            label.set_y(b.lbl, math.avg(b.top, b.bottom))

// One Unicorn at a time — one setup per swing. When a newer Breaker confirms as a Unicorn
// the older one is superseded, so only the most-recently-confirmed Unicorn is kept.
if barstate.isconfirmed and blocks.size() > 1
    int newestUni = na
    for i = 0 to blocks.size() - 1
        SmartBlock b = blocks.get(i)
        if b.isUni and (na(newestUni) or b.uniBar > newestUni)
            newestUni := b.uniBar
    if not na(newestUni)
        for i = blocks.size() - 1 to 0
            SmartBlock b = blocks.get(i)
            if b.isUni and b.uniBar < newestUni
                box.delete(b.bx)
                label.delete(b.lbl)
                blocks.remove(i)

// Snapshot whether a Unicorn is live (and its direction) for the gated Draw label — the
// liquidity module reads this next bar, as it runs before this one.
if barstate.isconfirmed
    bool anyUniLive = false
    int  liveUniDir = 0
    if blocks.size() > 0
        for i = 0 to blocks.size() - 1
            SmartBlock b = blocks.get(i)
            if b.isUni
                anyUniLive := true
                liveUniDir := b.isBull ? 1 : -1
    uniLiveForDraw := anyUniLive
    uniDirForDraw := liveUniDir

// ============================================================================
// MODULE 6 — THE IFVG THE UNICORN SITS INSIDE
// ----------------------------------------------------------------------------
// An inversion FVG frames the setup: it is the imbalance the Unicorn delivered from.
// Each live IFVG is shaded orange (no label — orange reads as IFVG) only while it
// overlaps a same-direction Unicorn Breaker; otherwise it stays tracked but undrawn. A
// framing inversion is kept alive for the whole Unicorn — it clears only once it trends
// off-screen, or is reclaimed while no Unicorn is framing it.
// ============================================================================
//@function True when a live same-direction Unicorn Breaker overlaps this IFVG, so
//          the inversion is framing a Unicorn and should be shaded.
//@param iv (IFVG) The inversion to test.
//@returns (bool) Whether it currently frames a Unicorn.
ifvgFramesUnicorn(IFVG iv) =>
    bool frames = false
    if blocks.size() > 0
        for bi = 0 to blocks.size() - 1
            SmartBlock b = blocks.get(bi)
            if b.isUni and iv.isBull == b.isBull and b.bottom <= iv.top and b.top >= iv.bottom
                frames := true
    frames

if barstate.isconfirmed
    if ifvgs.size() > 0
        for i = ifvgs.size() - 1 to 0
            IFVG iv = ifvgs.get(i)
            if low <= iv.top and high >= iv.bottom
                iv.lastTouch := bar_index
            bool frames  = ifvgFramesUnicorn(iv)
            // Reclaimed only by the body — invalidCloses body closes through it (cumulative;
            // a wick never counts). While it frames a live Unicorn it is kept alive and drawn
            // no matter what: the Unicorn is DEFINED by this IFVG, so the two live and die
            // together. It retires only once it no longer frames one AND has been reclaimed or
            // has trended off-screen — never while it is still the gap making a Unicorn.
            bool through = iv.isBull ? close < iv.bottom : close > iv.top
            if through
                iv.strikes := iv.strikes + 1
            bool reclaimed = iv.strikes >= invalidCloses
            if not frames and (reclaimed or zoneStale(iv.top, iv.bottom, iv.lastTouch))
                box.delete(iv.bx)
                ifvgs.remove(i)
            else if frames and showIFVG and showPD
                if na(iv.bx)
                    iv.bx := box.new(iv.originBar, iv.top, bar_index + rightOffset, iv.bottom, border_color = ifvgCol, border_width = 1, border_style = line.style_solid, bgcolor = ifvgCol)
                else
                    box.set_right(iv.bx, bar_index + rightOffset)
            else
                box.delete(iv.bx)
                iv.bx := na

// ── Declutter — a BISI / SIBI that sits inside a Unicorn Breaker or the IFVG framing
//    it hides its own box and label, so the premium zone is not buried under the very
//    ingredient it is built from. The gap still exists for detection; only its drawing
//    is suppressed, and it returns the moment it is no longer inside one.
//@function True when this FVG lies inside a live Unicorn Breaker or a shaded IFVG.
//@param f (FVG) The gap to test.
//@returns (bool) Whether the FVG is absorbed and should not draw its own box.
fvgAbsorbed(FVG f) =>
    bool hit = false
    if blocks.size() > 0
        for bi = 0 to blocks.size() - 1
            SmartBlock b = blocks.get(bi)
            if b.isUni and b.bottom <= f.top and b.top >= f.bottom
                hit := true
    if not hit and ifvgs.size() > 0
        for ii = 0 to ifvgs.size() - 1
            IFVG iv = ifvgs.get(ii)
            if not na(iv.bx) and f.bottom <= iv.top and f.top >= iv.bottom
                hit := true
    hit

if barstate.isconfirmed
    if fvgs.size() > 0
        for i = 0 to fvgs.size() - 1
            FVG f = fvgs.get(i)
            if not na(f.bx)
                color zc = f.isBull ? bullZoneCol : bearZoneCol
                bool hide = fvgAbsorbed(f)
                box.set_bgcolor(f.bx, hide ? color.new(zc, 100) : zc)
                box.set_border_color(f.bx, hide ? color.new(zc, 100) : zc)
                if not na(f.lbl)
                    label.set_textcolor(f.lbl, hide ? color.new(zc, 100) : color.new(zc, 0))

// ── Z-order — a Unicorn Breaker overlapped by its IFVG is redrawn last, so the
//    premium zone sits IN FRONT of the orange inversion framing it (Pine layers
//    boxes by creation order — recreating it makes it the newest, hence topmost).
if barstate.isconfirmed
    if blocks.size() > 0
        for i = 0 to blocks.size() - 1
            SmartBlock b = blocks.get(i)
            if b.isUni and not na(b.bx)
                bool overIfvg = false
                if ifvgs.size() > 0
                    for ii = 0 to ifvgs.size() - 1
                        IFVG iv = ifvgs.get(ii)
                        if not na(iv.bx) and b.bottom <= iv.top and b.top >= iv.bottom
                            overIfvg := true
                if overIfvg
                    color zc = b.isBull ? uniBullCol : uniBearCol
                    box.delete(b.bx)
                    label.delete(b.lbl)
                    b.bx  := box.new(b.originBar, b.top, bar_index + rightOffset, b.bottom, border_color = color.new(zc, 0), border_width = 1, border_style = line.style_dashed, bgcolor = zc)
                    b.lbl := mkBoxLabel(int(math.avg(b.originBar, bar_index + rightOffset)), math.avg(b.top, b.bottom), (b.isBull ? "Unicorn +" : "Unicorn -") + " " + tfTag(), color.new(color.black, 0), zoneLabelSize)

bool bullUniRecent = not na(lastBullUniBar) and bar_index - lastBullUniBar <= tapMemory
bool bearUniRecent = not na(lastBearUniBar) and bar_index - lastBearUniBar <= tapMemory

// ============================================================================
// DASHBOARD
// ============================================================================
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
//@returns (bool) Always true.
dashRow(int row, string k, string v, color vcol) =>
    table.cell(dash, 0, row, " " + k + " ", text_color = color.black, text_size = sizeFromStr(dashSize), text_halign = text.align_left, text_font_family = font.family_monospace, bgcolor = DASH_BG)
    table.cell(dash, 1, row, " " + v + " ", text_color = vcol, text_size = sizeFromStr(dashSize), text_halign = text.align_right, text_font_family = font.family_monospace, bgcolor = DASH_BG)
    true

if barstate.islast and showDash
    if na(dash)
        dash := table.new(dashPosConst(dashPos), 2, 9, bgcolor = DASH_BG, frame_color = DASH_LINE, frame_width = 1, border_color = DASH_LINE, border_width = 1)
        table.merge_cells(dash, 0, 0, 1, 0)
    string manualTag = biasMode == "Auto" ? "" : " (manual)"
    string biasState = (biasDir == 1 ? "BULLISH" : biasDir == -1 ? "BEARISH" : "MIXED") + manualTag
    color  biasCol = biasDir == 1 ? color.new(uniBullCol, 0) : biasDir == -1 ? color.new(uniBearCol, 0) : color.black
    // Live Unicorn if one is recent; otherwise fall back to the last one's direction so the
    // row reads "bullish (last)" / "bearish (last)" rather than a bare "-".
    string uniLastTag = lastUniDelivered ? " (delivered)" : " (last)"
    string uniState = bullUniRecent and bearUniRecent ? "both" : bullUniRecent ? "bullish" : bearUniRecent ? "bearish" : lastUniDir == 1 ? "bullish" + uniLastTag : lastUniDir == -1 ? "bearish" + uniLastTag : "-"
    color  uniCol = bullUniRecent and not bearUniRecent ? color.new(uniBullCol, 0) : bearUniRecent and not bullUniRecent ? color.new(uniBearCol, 0) : color.black
    // A single-direction Unicorn that opposes the HTF bias — surface the conflict rather
    // than hide it: flag the row "(counter-bias)" in gray instead of its directional colour.
    int uniShownDir = bullUniRecent and not bearUniRecent ? 1 : bearUniRecent and not bullUniRecent ? -1 : (not bullUniRecent and not bearUniRecent) ? lastUniDir : 0
    if uniShownDir != 0 and biasDir != 0 and uniShownDir != biasDir
        uniState := uniState + " (counter-bias)"
        uniCol := color.new(color.gray, 0)
    string raidState = buysideRaidRecent and sellsideRaidRecent ? "both sides" : buysideRaidRecent ? "buyside taken" : sellsideRaidRecent ? "sellside taken" : "-"
    // Draw reads the SAME single shared value the chart × Draw label uses (drawPxShown /
    // drawDirShown), computed once per bar — so the dashboard and the chart are always identical,
    // never a direction or one-bar mismatch.
    string drawState = na(drawPxShown) ? "-" : (drawDirShown == 1 ? "BSL " : "SSL ") + str.tostring(drawPxShown, format.mintick)
    string mnState = na(midnightOpen) ? "-" : close < midnightOpen ? "below (bull)" : "above (bear)"
    string pdState = na(equilibrium) ? "-" : close < equilibrium ? "discount (bull)" : "premium (bear)"
    // PDH/PDL read the LIVE chart level (matches the lines exactly, and drops a taken level just
    // as the chart does). When the MTF lines are hidden there is nothing to match on-chart, so
    // fall back to the raw prior-day snapshot.
    float pdhLv = showMTF ? famLevel("PDH") : pdhPx
    float pdlLv = showMTF ? famLevel("PDL") : pdlPx
    string pdhState = na(pdhLv) ? "-" : str.tostring(pdhLv, format.mintick)
    string pdlState = na(pdlLv) ? "-" : str.tostring(pdlLv, format.mintick)
    table.cell(dash, 0, 0, " M1D™ · Unicorn ", text_color = color.black, text_size = sizeFromStr(dashSize), text_halign = text.align_center, text_font_family = font.family_monospace, bgcolor = DASH_HEAD)
    dashRow(1, "HTF BIAS", biasState, biasCol)
    dashRow(2, "Unicorn", uniState, uniCol)
    dashRow(3, "Raided", raidState, color.black)
    dashRow(4, "Draw", drawState, color.black)
    dashRow(5, "PDH", pdhState, color.black)
    dashRow(6, "PDL", pdlState, color.black)
    dashRow(7, "12am Open", mnState, color.black)
    dashRow(8, "Dealing range", pdState, color.black)
````
