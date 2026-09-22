<!-- tradingview-pine-id: PUB;8fdb8dcbe2434984aaa25a4277479316 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# $$$ VSA DIGGA $$$ ver1.0

Source: https://www.tradingview.com/script/eM3wh19g-VSA-DIGGA/

## Description

$$$ VSA DIGGA $$$ ver1.0

A narrow bar on low volume is the market saying "nobody here". VSA DIGGA draws the supply and demand bases those bars reveal, names each one with the VSA, Wyckoff and Crabel events that describe it, keeps only the ones that are still alive — and keeps score of itself, per event, on your symbol.

Tom Williams built Volume Spread Analysis on one observation: the professional money shows itself not in the bars that move, but in the bars that refuse to. A quiet down-bar in an uptrend pull-back that nobody sells into is No Supply. A quiet up-bar in a downtrend rally that nobody buys is No Demand. Where those bars cluster is where the next leg is being prepared.

VSA DIGGA finds those bases, draws them as zones, and does three things most zone indicators do not.

1. Every threshold is a percentile of your own chart

There is no "spread below 0.5 × average" here. A bar is narrow when its high-low spread ranks in the quietest fifth of the last 200 bars, low-volume when its volume does. Wide, high and ultra-high are the 80th, 80th and 95th percentiles. One setting serves gold, an index CFD, a coin and a currency pair, because each symbol defines its own normal.

2. A base is confirmed by its departure — and only live zones stay on the chart

A base bar starts a zone in a FORMING state: faint, dotted, unscored, unalerted. Narrow bars come in clusters, and a cluster that overlaps a forming zone widens it and adds its events instead of stacking a second box. The zone becomes a zone when price leaves it the right way — a close above a demand base, below a supply base. Williams: the following bar's close in the expected direction is the trigger. A close the wrong way while forming, or no departure within 20 bars, cancels it quietly.

This rule was measured before it was written. Without it, on XAUUSD, 60-70% of bases were "broken" while price was still building them, and the chart held two zones at a time.

A confirmed zone then lives until a close beyond its far side breaks it, or until nobody has touched it for 300 bars. Every zone is widened around its bar to at least one median spread, because a base is an area and the bar that revealed it is by definition tiny.

3. Theory as tags, not as a score

Each zone carries the events that describe it, as text on its label and in full on its tooltip. No weights, no 0-100. You read the events; the scoreboard reads them back to you.

On the base bar itself:

[*]NS — No Supply. Down-bar, narrow, volume below each of the previous two bars. Demand.
[*]ND — No Demand. Up-bar, narrow, volume below each of the previous two bars. Supply.
[*]TEST — a low under the prior low, close in the upper half, low volume — and a Stopping Volume or Spring within the last 5 bars. The bar only asks the question; without the climax before it, there is nothing to test.
[*]NR7 / NR4 — Crabel's narrowest range of the last 7 or 4 bars. Contraction before expansion. NR7 is shown alone when both hold.
[*]ID — inside bar.

In the bars just before it (context, 5-bar window):

[*]SV — Stopping Volume / Selling Climax. Wide down-bar, high volume, closing off its lows.
[*]BC — Buying Climax. Wide up-bar, ultra-high volume, above the swing high.
[*]UT — Upthrust. Above the swing high, closes in its lower third, high volume.
[*]SPR — Spring. Under the swing low, closes back above it in its upper half. No volume rule: a spring on low volume is the strongest kind.

A zone with at least one of NS, ND, TEST, NR7, SV, BC, UT or SPR is drawn strong — solid border, fuller fill. NR4 and ID alone do not promote it. Every tag has its own switch, and every switch carries the full definition.

The scoreboard

Per kind and per tag: zones confirmed, zones tested, and how often a tested zone held — travelled at least one zone height in its direction after its first test — before a close broke it. A zone price never came back to proves nothing and is not scored; neither is one that expired, or a base that never departed. The status line counts all of them so the table can be checked against itself, and the last 50 scored zones stay on the chart, frozen where they died, marked ✓ or ✗, so the number can be checked against the picture.

What it measured during development — XAUUSD, volume ignored (pure price rules), default settings:

[*]15m: 704 zones confirmed, 68% tested, 54% of tested zones held one height. 765 forming bases cancelled before departure.
[*]1H: 900 zones, 70% tested, 65% of demand and 55% of supply zones held.
[*]Spring was the best-scoring tag on both (62-68%), on 31 and 46 tested zones — too few to call.

Read those for what they are: the tool describing a chart, with a modest bar ("one zone height") and no control row yet. A held rate without a baseline is a description, not an edge. The point is that the same table runs on your symbol, your timeframe, your settings, and will tell you which events carry anything there.

Alerts

One alert() call per event — a zone confirmed, a strong zone confirmed, a zone tested, its midline touched, a zone held then broken, a zone broken — so a single "Any alert() function call" alert per chart catches everything, with the zone's kind and tags in the message. Six alertconditions for anyone who wants them separately.

Honest limits

[*]Tick volume is not volume. On forex and CFD feeds the volume is a tick count; the status line says so. "Ignore volume" turns every volume rule off and keeps NR7, NR4, ID and Spring, which are pure price.
[*]Nothing repaints. Every state change happens on a closed bar. The forming box is visible while it forms; no verdict flickers.
[*]A zone is one bar's area, widened. On a noisy symbol and a low timeframe most zones live a few dozen bars. That is the finding, not a bug — the history layer is there so you can see it.

Settings worth touching

Narrow spread / Low volume percentile are the sensitivity. Min zone height (× median spread) and Departure within shape what counts as a base. Held = travel × height is the scoreboard's bar — raise it and watch the held rates fall; where they fall slowest is where the zones on your chart actually work. Show zone history keeps the last N scored zones. The palette follows a bright or dark chart on its own.

Release notes : 

Successor to the "NSF/NBF Boxes" script. What changed from that draft, and why:

[*]Percentile thresholds replace the spread-SMA and volume-SMA multipliers. Narrow = 20th percentile of the last 200 bars, wide = 80th, ultra volume = 95th. One setting for every symbol.
[*]Only live zones on the chart. A zone dies on a close beyond its far side or after 300 untouched bars. The last 50 scored zones stay frozen with ✓ / ✗ so the picture matches the table.
[*]A base is confirmed by its departure. Measured on XAUUSD: without this rule 60-70% of bases were "broken" while still forming. Forming zones are faint and unscored; a close the wrong way or 20 bars without departure cancels them.
[*]Ten VSA / Wyckoff / Crabel tags — NS, ND, TEST, NR7, NR4, ID, SV, BC, UT, SPR — each with its full definition on its switch and on the zone's tooltip. The Williams bar-direction rule (down-bar for No Supply, up-bar for No Demand) is now part of the definition; the old close-bias filter stays as an optional stricter base.
[*]A scoreboard per kind and per tag: zones, tested, held %. Untested, expired and never-departed bases are counted but never scored.
[*]One alert() per event so a single "Any alert() function call" covers a chart.
[*]Gone: Test mode, fixed box extension, body-only boxes, auto-extend (zones always follow the chart now).

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PINEDIGGA

//@version=6
//@VSA DIGGA — narrow-spread supply / demand zones, read the Williams way (Sep 2026 — ver1.0)
// Successor to the author's "NSF/NBF Boxes". A narrow bar on low volume is the market saying
// "nobody here" — a base of demand in an uptrend pull-back (NBF), a base of supply in a
// downtrend rally (NSF). Every zone carries the VSA / Wyckoff / Crabel events that describe it
// as TAGS, not as a score; only live zones stay on the chart; every threshold is a percentile
// of the symbol's own recent bars; and the indicator keeps score of itself — per tag — so
// what it claims and what it delivered sit on screen together.
indicator("$$$ VSA DIGGA $$$ ver1.0", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

string BUILD = "b5"

//══════════════════════════════════════════════════════════════════════
// ① INPUTS
//══════════════════════════════════════════════════════════════════════
string G0 = "▶️ Start from here"
string G1 = "📦 Zones"
string G2 = "🏷 Tags"
string G3 = "📊 Statistics"
string G4 = "🎨 Style"

vsTheme    = input.string("Auto", "☯ Chart Background Colors", group = G0, options = ["Auto", "User"], display = display.none,
     tooltip = "Auto: detects whether your chart background is bright or dark and applies the matching palette. User: the colors below are used instead.")
vsNoVol    = input.bool(false, "Ignore volume", group = G0, display = display.none,
     tooltip = "For symbols without usable volume. The base zone then needs only a narrow spread, and every volume-based tag (NS, ND, TEST, SV, BC, UT) is switched off. NR7 / NR4 / ID / SPR keep working — they are pure price.")
vsLook     = input.int(200, "Percentile lookback (bars)", group = G0, minval = 20, maxval = 1000, display = display.none,
     tooltip = "How many bars the spread and volume percentiles are ranked over. Every 'narrow', 'wide', 'low', 'high' in this script is a rank inside this window — the symbol defines its own normal.")
vsEmaOn    = input.bool(true, "EMA background", group = G0, display = display.none,
     tooltip = "Williams: background analysis precedes bar reading. On: NBF only above the EMA (uptrend pull-back), NSF only below it (downtrend rally). Off: the bar's own direction decides — a down-bar is a demand base, an up-bar a supply base.")
vsEmaLen   = input.int(200, "EMA length", group = G0, minval = 2, maxval = 1000, display = display.none)

vsPctNar   = input.int(20, "Narrow spread — percentile", group = G1, minval = 1, maxval = 99, display = display.none,
     tooltip = "A bar is narrow when its high-low spread ranks at or below this percentile of the lookback. 20 = the quietest fifth of bars.")
vsPctLow   = input.int(20, "Low volume — percentile", group = G1, minval = 1, maxval = 99, display = display.none,
     tooltip = "A bar is low-volume when its volume ranks at or below this percentile of the lookback.")
vsBias     = input.bool(false, "Close bias", group = G1, display = display.none,
     tooltip = "Stricter base: NBF needs the close in the lower half of the bar, NSF in the upper half. Off by default — the NS / ND tags already carry the Williams bar-direction rule.")
vsMinH     = input.float(1.0, "Min zone height (× median spread)", group = G1, minval = 0.0, maxval = 5.0, step = 0.1, display = display.none,
     tooltip = "A base is an AREA, not the narrow bar that revealed it — and a narrow bar is by definition tiny, so a zone drawn on its range alone is broken by the next close. The zone is widened around the bar's midpoint to at least this many median spreads of the lookback. 0 keeps the raw bar range.")
vsFormBars = input.int(20, "Departure within (bars)", group = G1, minval = 1, maxval = 500, display = display.none,
     tooltip = "A base becomes a zone only when price LEAVES it in the zone's direction — a close above an NBF, below an NSF. Until then it is forming: drawn faint, not scored, not alerted. A close the wrong way while forming, or no departure within this many bars, cancels it quietly. Measured on XAUUSD: without this rule 60-70% of bases were 'broken' before they ever finished forming.")
vsMerge    = input.bool(true, "Merge overlapping zones", group = G1, display = display.none,
     tooltip = "Narrow bars come in clusters — that cluster IS the base. On: a new base bar that overlaps a FORMING zone of the same kind widens that zone and adds its tags instead of stacking a second box on top. Off: every base bar is its own zone. A base bar landing on an already confirmed zone never spawns a new one either way — it is a test of that zone.")
vsExpire   = input.int(300, "Expire after (bars untouched, 0 = never)", group = G1, minval = 0, maxval = 5000, display = display.none,
     tooltip = "A zone nobody has come back to is not a zone, it is a line across your chart. After this many bars since its birth or its last test it is removed quietly — no outcome recorded, because nothing was proved.")
vsMaxLive  = input.int(40, "Max live zones", group = G1, minval = 1, maxval = 150, display = display.none,
     tooltip = "Cap on zones kept on the chart. When exceeded the oldest is removed as expired. 40 zones × 3 objects stays far inside TradingView's drawing limits.")
vsHeldMult = input.float(1.0, "Held = travel × zone height", group = G1, minval = 0.1, maxval = 10.0, step = 0.1, display = display.none,
     tooltip = "Scoreboard rule. A zone counts as HELD if, after its first test, price travelled at least this many zone heights in the zone's direction before a close broke it. Otherwise BROKEN. Untested zones are never scored.")
vsMinTags  = input.int(0, "Draw only zones with ≥ tags", group = G1, minval = 0, maxval = 5, display = display.none,
     tooltip = "0 draws every base. 1 keeps only bases with at least one tag. Filtered bases are not created at all, so the scoreboard measures exactly what you see.")
vsHistN    = input.int(50, "Show zone history (last N, 0 = off)", group = G1, minval = 0, maxval = 150, display = display.none,
     tooltip = "Scored zones — tested, then broken — stay on the chart after they die: frozen at the bar that broke them, faint, with ✓ (held) or ✗ (broken) at the edge. Hover for what the zone was. Exactly the zones the held % is made of, so the number and the picture can be checked against each other. Untested, expired and aborted bases are removed.")
vsMidOn    = input.bool(true, "Show midline", group = G1, display = display.none)
vsLblOn    = input.bool(true, "Show labels", group = G1, display = display.none,
     tooltip = "Zone kind, its tags and ×n tests at the right edge. Hover the label for every tag's full name and rule, the zone's state and its travel.")

vsTagNS    = input.bool(true, "NS — No Supply", group = G2, display = display.none,
     tooltip = "NS = No Supply (Williams). Down-bar (close below the prior close), narrow spread, volume below EACH of the previous two bars. A pull-back nobody wants to sell into — bullish. Attaches to NBF.")
vsTagND    = input.bool(true, "ND — No Demand", group = G2, display = display.none,
     tooltip = "ND = No Demand (Williams). Up-bar (close above the prior close), narrow spread, volume below EACH of the previous two bars. A rally nobody wants to buy — bearish. Attaches to NSF.")
vsTagTEST  = input.bool(true, "TEST — Test of supply", group = G2, display = display.none,
     tooltip = "TEST (Williams). Low below the prior bar's low, close in the upper half, low volume — AND a Stopping Volume or Spring within the context window. The bar only asks the question; the earlier climax is what makes the answer meaningful. Attaches to NBF.")
vsTagNR    = input.bool(true, "NR7 / NR4 — Narrow Range", group = G2, display = display.none,
     tooltip = "NR7 / NR4 (Crabel). The bar's range is the narrowest of the last 7 (or 4) bars, itself included. Contraction precedes expansion. NR7 implies NR4, so only NR7 is shown when both hold. NR7 counts as a strong tag, NR4 does not. Attaches to both kinds.")
vsTagID    = input.bool(true, "ID — Inside bar", group = G2, display = display.none,
     tooltip = "ID = Inside Day / bar. High at or below the prior high and low at or above the prior low. With NR4 it is Crabel's ID/NR4 double compression. Not a strong tag on its own. Attaches to both kinds.")
vsTagSV    = input.bool(true, "SV — Stopping Volume", group = G2, display = display.none,
     tooltip = "SV = Stopping Volume / Selling Climax (Williams). Wide down-bar on high volume that closes off its lows — the fall was absorbed. Context tag: attaches to an NBF born within the context window after it.")
vsTagBC    = input.bool(true, "BC — Buying Climax", group = G2, display = display.none,
     tooltip = "BC = Buying Climax (Williams). Wide up-bar on ULTRA-high volume that pushes above the recent swing high — the rally was sold into. Context tag: attaches to an NSF born within the context window after it.")
vsTagUT    = input.bool(true, "UT — Upthrust", group = G2, display = display.none,
     tooltip = "UT = Upthrust (Williams). Pushes above the recent swing high, closes in the lower third of its range, high volume — a breakout that was refused. Context tag: attaches to an NSF born within the context window after it.")
vsTagSPR   = input.bool(true, "SPR — Spring", group = G2, display = display.none,
     tooltip = "SPR = Spring (Wyckoff). Low below the recent swing low, close back above that low and in the upper half of the bar — a break that was refused. No volume rule: a spring on LOW volume is the strongest kind. Context tag: attaches to an NBF born within the context window after it.")
vsCtxK     = input.int(5, "Context window (bars)", group = G2, minval = 1, maxval = 50, display = display.none,
     tooltip = "How many bars after a climax / spring / upthrust a new base may still claim it as context.")
vsSwing    = input.int(20, "Swing lookback (bars)", group = G2, minval = 3, maxval = 200, display = display.none,
     tooltip = "The prior swing high / low that BC, UT and SPR must break: the highest high / lowest low of this many bars before the current one.")
vsPctWide  = input.int(80, "Wide spread — percentile", group = G2, minval = 1, maxval = 99, display = display.none,
     tooltip = "Spread rank at or above this is 'wide' (SV, BC).")
vsPctHigh  = input.int(80, "High volume — percentile", group = G2, minval = 1, maxval = 99, display = display.none,
     tooltip = "Volume rank at or above this is 'high' (SV, UT).")
vsPctUltra = input.int(95, "Ultra volume — percentile", group = G2, minval = 1, maxval = 99, display = display.none,
     tooltip = "Volume rank at or above this is 'ultra-high' (BC).")

vsDashOn   = input.bool(true, "Show scoreboard", group = G3, display = display.none,
     tooltip = "Per kind and per tag: zones born, zones tested, and how often a tested zone HELD before it was broken. The indicator's opinion and its record, side by side. Untested and expired zones are counted but never scored.")
vsDashPos  = input.string("bottom_right", "Position", group = G3, options = ["top_left", "top_right", "bottom_left", "bottom_right"], display = display.none)
vsDashSize = input.string("small", "Text size", group = G3, options = ["tiny", "small", "normal", "large"], display = display.none)

colNbf     = input.color(#26a69a, "NBF (demand)", group = G4, inline = "c", display = display.none)
colNsf     = input.color(#ef5350, "NSF (supply)", group = G4, inline = "c", display = display.none)
vsFillS    = input.int(72, "Fill transparency — strong", group = G4, minval = 0, maxval = 100, display = display.none)
vsFillW    = input.int(90, "Fill transparency — weak", group = G4, minval = 0, maxval = 100, display = display.none)
vsFillH    = input.int(80, "Fill transparency — history", group = G4, minval = 0, maxval = 100, display = display.none,
     tooltip = "Dead, scored zones. Their border runs 20 points more opaque than this, their ✓ / ✗ fully opaque.")
vsLblSize  = input.string("tiny", "Label size", group = G4, options = ["tiny", "small", "normal"], display = display.none)

_sz(string _s) => _s == "tiny" ? size.tiny : _s == "small" ? size.small : _s == "large" ? size.large : size.normal
_pos(string _p) => _p == "top_left" ? position.top_left : _p == "top_right" ? position.top_right : _p == "bottom_left" ? position.bottom_left : position.bottom_right

// ── PALETTE ──────────────────────────────────────────────────────────────────
// Same detection as the rest of the family: luminance of the chart background, threshold 128.
// Grey is banned — on black it reads as disabled. The weak zone is the same hue, more transparent
// and dashed, never a greyed-out one.
float _bgLuma  = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  isBright = _bgLuma > 128
bool  _userCol = vsTheme == "User"
color cNbf  = _userCol ? colNbf : isBright ? #00796b : #26a69a
color cNsf  = _userCol ? colNsf : isBright ? #c62828 : #ef5350
color cFg   = isBright ? #363a45 : #e8eaed
color cLine = color.new(cFg, 60)
color cCell = color.new(chart.bg_color, 15)
color cHdr  = color.new(cFg, 85)

//══════════════════════════════════════════════════════════════════════
// ② BAR READING — percentiles, base, tags
//══════════════════════════════════════════════════════════════════════
// Every ta.* call lives here, unconditional, so history and realtime rank the same bars.
bool  _realVol = not (syminfo.type == "forex" or syminfo.type == "cfd")
bool  useVol   = not vsNoVol
float vol      = nz(volume)
float spread   = high - low
float closePos = spread > 0 ? (close - low) / spread : 0.5
float ema      = ta.ema(close, vsEmaLen)

float pSprNar   = ta.percentile_nearest_rank(spread, vsLook, vsPctNar)
float pSprWide  = ta.percentile_nearest_rank(spread, vsLook, vsPctWide)
float pSprMed   = ta.percentile_nearest_rank(spread, vsLook, 50)
float pVolLow   = ta.percentile_nearest_rank(vol, vsLook, vsPctLow)
float pVolHigh  = ta.percentile_nearest_rank(vol, vsLook, vsPctHigh)
float pVolUltra = ta.percentile_nearest_rank(vol, vsLook, vsPctUltra)
float sprRank   = ta.percentrank(spread, vsLook)
float volRank   = ta.percentrank(vol, vsLook)
float swingHi   = ta.highest(high[1], vsSwing)
float swingLo   = ta.lowest(low[1], vsSwing)
float low6      = ta.lowest(spread[1], 6)
float low3      = ta.lowest(spread[1], 3)

bool warm     = bar_index >= math.max(vsLook, vsSwing) + 2
bool isNarrow = warm and spread > 0 and spread <= pSprNar
bool volLow   = not useVol or vol <= pVolLow
bool volUnder = useVol and vol < vol[1] and vol < vol[2]
bool upBar    = close > close[1]
bool dnBar    = close < close[1]

// Base. With the EMA off the bar's direction is the only background there is.
bool bullBg = vsEmaOn ? close > ema : dnBar
bool bearBg = vsEmaOn ? close < ema : upBar
bool nbfBar = isNarrow and volLow and bullBg and (not vsBias or closePos <= 0.5)
bool nsfBar = isNarrow and volLow and bearBg and (not vsBias or closePos >= 0.5)

// Context events — any bar. barssince is na before the first one; treat that as "never".
bool svBar  = useVol and dnBar and spread >= pSprWide and vol >= pVolHigh  and closePos >= 0.5
bool bcBar  = useVol and upBar and spread >= pSprWide and vol >= pVolUltra and high > swingHi
bool utBar  = useVol and high > swingHi and closePos <= 1.0 / 3.0 and vol >= pVolHigh
bool sprBar = low < swingLo and closePos >= 0.5 and close > swingLo
int sinceSV  = nz(ta.barssince(svBar),  1000000)
int sinceBC  = nz(ta.barssince(bcBar),  1000000)
int sinceUT  = nz(ta.barssince(utBar),  1000000)
int sinceSPR = nz(ta.barssince(sprBar), 1000000)

// Bar-level tags on the base bar.
bool tNS   = vsTagNS   and useVol and dnBar and isNarrow and volUnder
bool tND   = vsTagND   and useVol and upBar and isNarrow and volUnder
bool tTEST = vsTagTEST and useVol and low < low[1] and closePos >= 0.5 and vol <= pVolLow and (sinceSV <= vsCtxK or sinceSPR <= vsCtxK)
bool tNR7  = vsTagNR   and warm and spread < low6
bool tNR4  = vsTagNR   and warm and spread < low3 and not tNR7
bool tID   = vsTagID   and high <= high[1] and low >= low[1]
bool tSV   = vsTagSV   and sinceSV  <= vsCtxK
bool tBC   = vsTagBC   and sinceBC  <= vsCtxK
bool tUT   = vsTagUT   and sinceUT  <= vsCtxK
bool tSPR  = vsTagSPR  and sinceSPR <= vsCtxK

// Bitmask — the order is the row order of the scoreboard and the label.
int B_NS = 1
int B_ND = 2
int B_TEST = 4
int B_NR4 = 8
int B_NR7 = 16
int B_ID = 32
int B_SV = 64
int B_BC = 128
int B_UT = 256
int B_SPR = 512
int STRONG_MASK = B_NS + B_ND + B_TEST + B_NR7 + B_SV + B_BC + B_UT + B_SPR
var string[] TAG_KEY  = array.from("NS", "ND", "TEST", "NR4", "NR7", "ID", "SV", "BC", "UT", "SPR")
var string[] TAG_NAME = array.from("No Supply", "No Demand", "Test of supply", "Narrow Range 4", "Narrow Range 7", "Inside bar",
     "Stopping Volume / Selling Climax", "Buying Climax", "Upthrust", "Spring")
var string[] TAG_RULE = array.from(
     "down-bar, narrow spread, volume below each of the previous two bars",
     "up-bar, narrow spread, volume below each of the previous two bars",
     "low under the prior low, close in the upper half, low volume, after SV or SPR",
     "narrowest range of the last 4 bars",
     "narrowest range of the last 7 bars",
     "high ≤ prior high and low ≥ prior low",
     "wide down-bar, high volume, close off the lows (context)",
     "wide up-bar, ultra volume, above the swing high (context)",
     "above the swing high, close in the lower third, high volume (context)",
     "under the swing low, close back above it in the upper half (context)")

int tagsNbf = (tNS ? B_NS : 0) + (tTEST ? B_TEST : 0) + (tNR4 ? B_NR4 : 0) + (tNR7 ? B_NR7 : 0) + (tID ? B_ID : 0) + (tSV ? B_SV : 0) + (tSPR ? B_SPR : 0)
int tagsNsf = (tND ? B_ND : 0) + (tNR4 ? B_NR4 : 0) + (tNR7 ? B_NR7 : 0) + (tID ? B_ID : 0) + (tBC ? B_BC : 0) + (tUT ? B_UT : 0)

// Pine has no bitwise operators; the mask is walked bit by bit. Ten bits, ten iterations.
f_bit(int _m, int _i) => math.floor(_m / math.pow(2, _i)) % 2 == 1

f_bits(int _m) =>
    int _n = 0
    for _i = 0 to 9
        if f_bit(_m, _i)
            _n += 1
    _n

f_and(int _a, int _b) =>
    int _r = 0
    for _i = 0 to 9
        if f_bit(_a, _i) and f_bit(_b, _i)
            _r += int(math.pow(2, _i))
    _r

f_or(int _a, int _b) =>
    int _r = 0
    for _i = 0 to 9
        if f_bit(_a, _i) or f_bit(_b, _i)
            _r += int(math.pow(2, _i))
    _r

f_tagText(int _m) =>
    string _s = ""
    for _i = 0 to 9
        if f_bit(_m, _i)
            _s += " · " + array.get(TAG_KEY, _i)
    _s

f_tagTip(int _m) =>
    string _s = ""
    for _i = 0 to 9
        if f_bit(_m, _i)
            _s += array.get(TAG_KEY, _i) + " = " + array.get(TAG_NAME, _i) + ": " + array.get(TAG_RULE, _i) + "\n"
    _s

//══════════════════════════════════════════════════════════════════════
// ③ ZONES — one type, one array, one pass per bar
//══════════════════════════════════════════════════════════════════════
type Zone
    box   bx
    line  mid
    label lb
    int   kind        // 1 = NBF (demand) · -1 = NSF (supply)
    float top
    float bot
    int   born
    int   bornTime
    int   lastTouch
    int   state       // 0 FORMING · 1 FRESH (departed) · 2 TESTED
    int   tests
    int   tags
    bool  strong
    float extreme     // travel in the zone's direction, counted after the first test

var Zone[] zones = array.new<Zone>()

// Dead-but-scored zones kept for the eye. Box + a ✓/✗ label, nothing else.
type Hist
    box   bx
    label lb
var Hist[] hist = array.new<Hist>()

// Scoreboard counters: index 0-9 = tags, 10 = NBF, 11 = NSF.
var int[] cZones   = array.new_int(12, 0)
var int[] cTested  = array.new_int(12, 0)
var int[] cHeld    = array.new_int(12, 0)
var int[] cBroken  = array.new_int(12, 0)
var int[] cExpired = array.new_int(12, 0)
var int[] cUntested = array.new_int(12, 0)   // broken before anyone came back: proves nothing, scored nowhere
var int[] cAborted  = array.new_int(12, 0)   // never departed: was a cluster of quiet bars, not a base

f_count(int[] _arr, int _tags, int _kind) =>
    if _kind != 0
        int _k = _kind == 1 ? 10 : 11
        array.set(_arr, _k, array.get(_arr, _k) + 1)
    for _i = 0 to 9
        if f_bit(_tags, _i)
            array.set(_arr, _i, array.get(_arr, _i) + 1)

f_kindTxt(Zone _z) => _z.kind == 1 ? "NBF" : "NSF"
f_col(Zone _z) => _z.kind == 1 ? cNbf : cNsf

f_restyle(Zone _z) =>
    color _c  = f_col(_z)
    _z.strong := f_and(_z.tags, STRONG_MASK) > 0
    bool _form = _z.state == 0
    box.set_bgcolor(_z.bx, color.new(_c, _form ? 94 : _z.strong ? vsFillS : vsFillW))
    box.set_border_color(_z.bx, color.new(_c, _form ? 60 : _z.strong ? 0 : 35))
    box.set_border_style(_z.bx, _form ? line.style_dotted : _z.strong ? line.style_solid : line.style_dashed)
    box.set_top(_z.bx, _z.top)
    box.set_bottom(_z.bx, _z.bot)
    if not na(_z.mid)
        float _m = (_z.top + _z.bot) / 2
        line.set_y1(_z.mid, _m)
        line.set_y2(_z.mid, _m)
    if not na(_z.lb)
        string _txt = f_kindTxt(_z) + f_tagText(_z.tags) + (_z.state == 0 ? " · forming" : _z.tests > 0 ? " · ×" + str.tostring(_z.tests) : "")
        float  _h   = _z.top - _z.bot
        string _tip = f_kindTxt(_z) + (_z.kind == 1 ? " — demand base (narrow bar, low volume, uptrend)" : " — supply base (narrow bar, low volume, downtrend)") + "\n"
             + (_z.strong ? "STRONG" : "weak") + " · " + (_z.state == 0 ? "FORMING — waiting for a close " + (_z.kind == 1 ? "above" : "below") + " the zone" : _z.state == 1 ? "FRESH — departed, untested" : "TESTED ×" + str.tostring(_z.tests)) + "\n"
             + (_z.tests > 0 and _h > 0 ? "travel " + str.tostring(_z.extreme / _h, "#.00") + " × height (held at " + str.tostring(vsHeldMult, "#.0") + ")\n" : "")
             + "born " + str.format_time(_z.bornTime, "yyyy-MM-dd HH:mm", syminfo.timezone) + "\n"
             + (_z.tags > 0 ? "— tags —\n" + f_tagTip(_z.tags) : "no tags")
        label.set_text(_z.lb, _txt)
        label.set_tooltip(_z.lb, _tip)
        label.set_y(_z.lb, _z.kind == 1 ? _z.bot : _z.top)

f_kill(Zone _z) =>
    box.delete(_z.bx)
    if not na(_z.mid)
        line.delete(_z.mid)
    if not na(_z.lb)
        label.delete(_z.lb)

// A scored zone is not deleted but frozen where it died, so the chart shows what the table counts.
f_freeze(Zone _z, bool _held) =>
    if vsHistN == 0
        f_kill(_z)
    else
        color _c = f_col(_z)
        if not na(_z.mid)
            line.delete(_z.mid)
        box.set_right(_z.bx, bar_index)
        box.set_bgcolor(_z.bx, color.new(_c, vsFillH))
        box.set_border_color(_z.bx, color.new(_c, math.max(0, vsFillH - 20)))
        box.set_border_style(_z.bx, line.style_dashed)
        float  _h   = _z.top - _z.bot
        string _tip = f_kindTxt(_z) + f_tagText(_z.tags) + "\n" + (_held ? "HELD" : "BROKEN") + " · tested ×" + str.tostring(_z.tests)
             + (_h > 0 ? " · travel " + str.tostring(_z.extreme / _h, "#.00") + " × height" : "") + "\n"
             + "born " + str.format_time(_z.bornTime, "yyyy-MM-dd HH:mm", syminfo.timezone)
        label _l = na
        if not na(_z.lb)
            _l := _z.lb
            label.set_text(_l, _held ? "✓" : "✗")
            label.set_tooltip(_l, _tip)
            label.set_x(_l, bar_index)
            label.set_y(_l, _z.kind == 1 ? _z.bot : _z.top)
            label.set_color(_l, color.new(_c, 100))
            label.set_textcolor(_l, _c)
            label.set_size(_l, size.small)
        else
            _l := label.new(bar_index, _z.kind == 1 ? _z.bot : _z.top, _held ? "✓" : "✗", tooltip = _tip,
                 style = _z.kind == 1 ? label.style_label_up : label.style_label_down, color = color.new(_c, 100), textcolor = _c, size = size.small)
        array.push(hist, Hist.new(bx = _z.bx, lb = _l))
        while array.size(hist) > vsHistN
            Hist _old = array.shift(hist)
            box.delete(_old.bx)
            label.delete(_old.lb)

// Per-bar alert buckets — one alert() per event kind, however many zones fired it.
string aNew = ""
string aStrong = ""
string aTest = ""
string aMid = ""
string aHeld = ""
string aBroken = ""
f_evt(string _s, Zone _z) => (str.length(_s) > 0 ? _s + " | " : "") + f_kindTxt(_z) + f_tagText(_z.tags)

if barstate.isconfirmed
    bool isBase   = nbfBar or nsfBar
    int  baseKind = nbfBar ? 1 : -1
    int  baseTags = nbfBar ? tagsNbf : tagsNsf
    bool merged   = false

    // ── lifecycle, oldest last so removal is index-safe ──
    int n = array.size(zones)
    if n > 0
        for i = n - 1 to 0
            Zone z = array.get(zones, i)
            bool overlap     = low <= z.top and high >= z.bot
            bool prevOverlap = low[1] <= z.top and high[1] >= z.bot
            bool sameBase    = isBase and z.kind == baseKind and overlap
            bool against     = z.kind == 1 ? close < z.bot : close > z.top
            bool removed     = false
            if z.state == 0
                // FORMING: the cluster may still grow; a close the right way confirms it, the wrong way cancels it.
                bool departed = z.kind == 1 ? close > z.top : close < z.bot
                if vsMerge and sameBase
                    z.top       := math.max(z.top, high)
                    z.bot       := math.min(z.bot, low)
                    z.tags      := f_or(z.tags, baseTags)
                    z.lastTouch := bar_index
                    merged      := true
                    f_restyle(z)
                else if against or bar_index - z.born >= vsFormBars
                    f_count(cAborted, z.tags, z.kind)
                    f_kill(z)
                    array.remove(zones, i)
                    removed := true
                else if departed
                    z.state     := 1
                    z.lastTouch := bar_index
                    f_count(cZones, z.tags, z.kind)
                    f_restyle(z)
                    aNew := f_evt(aNew, z)
                    if z.strong
                        aStrong := f_evt(aStrong, z)
            else
                bool expired = vsExpire > 0 and bar_index - z.lastTouch >= vsExpire
                if expired
                    f_count(cExpired, z.tags, z.kind)
                    f_kill(z)
                    array.remove(zones, i)
                    removed := true
                else if against
                    float h = z.top - z.bot
                    if z.tests == 0
                        f_count(cUntested, z.tags, z.kind)
                        f_kill(z)
                    else
                        bool held = h > 0 and z.extreme >= vsHeldMult * h
                        if held
                            f_count(cHeld, z.tags, z.kind)
                            aHeld := f_evt(aHeld, z)
                        else
                            f_count(cBroken, z.tags, z.kind)
                            aBroken := f_evt(aBroken, z)
                        f_freeze(z, held)
                    array.remove(zones, i)
                    removed := true
                else
                    // A base bar landing on a confirmed zone is a test of it, never a new zone.
                    if sameBase
                        merged := true
                    bool justTested = false
                    if overlap and not prevOverlap
                        z.tests += 1
                        z.lastTouch := bar_index
                        if z.state == 1
                            z.state   := 2
                            z.extreme := 0.0
                            f_count(cTested, z.tags, z.kind)
                        justTested := true
                        aTest := f_evt(aTest, z)
                        if low <= (z.top + z.bot) / 2 and high >= (z.top + z.bot) / 2
                            aMid := f_evt(aMid, z)
                    if z.tests > 0 and not justTested
                        z.extreme := math.max(z.extreme, z.kind == 1 ? high - z.top : z.bot - low)
                    if justTested
                        f_restyle(z)
            if not removed
                box.set_right(z.bx, bar_index)
                if not na(z.mid)
                    line.set_x2(z.mid, bar_index)
                if not na(z.lb)
                    label.set_x(z.lb, bar_index)

    // ── birth ──
    if isBase and not merged and f_bits(baseTags) >= vsMinTags
        while array.size(zones) >= vsMaxLive
            Zone old = array.get(zones, 0)
            f_count(cExpired, old.tags, old.kind)
            f_kill(old)
            array.remove(zones, 0)
        color c  = baseKind == 1 ? cNbf : cNsf
        float hz = math.max(spread, vsMinH * nz(pSprMed))
        float mz = (high + low) / 2
        float tz = mz + hz / 2
        float bz = mz - hz / 2
        Zone zn = Zone.new(kind = baseKind, top = tz, bot = bz, born = bar_index, bornTime = time, lastTouch = bar_index,
             state = 0, tests = 0, tags = baseTags, strong = false, extreme = 0.0)
        zn.bx := box.new(bar_index, tz, bar_index, bz, border_width = 1)
        if vsMidOn
            zn.mid := line.new(bar_index, mz, bar_index, mz, color = color.new(c, 20), width = 1, style = line.style_dashed)
        if vsLblOn
            zn.lb := label.new(bar_index, baseKind == 1 ? bz : tz, "", style = baseKind == 1 ? label.style_label_up : label.style_label_down,
                 color = color.new(c, 80), textcolor = c, size = _sz(vsLblSize))
        f_restyle(zn)
        array.push(zones, zn)

//══════════════════════════════════════════════════════════════════════
// ④ ALERTS — one alert() per event kind; "Any alert() function call" catches them all
//══════════════════════════════════════════════════════════════════════
string _hdr = "VSA DIGGA · " + syminfo.ticker + " · " + timeframe.period + " · "
if barstate.isconfirmed
    if str.length(aNew) > 0
        alert(_hdr + "NEW zone: " + aNew, alert.freq_once_per_bar_close)
    if str.length(aStrong) > 0
        alert(_hdr + "STRONG zone: " + aStrong, alert.freq_once_per_bar_close)
    if str.length(aTest) > 0
        alert(_hdr + "TESTED: " + aTest, alert.freq_once_per_bar_close)
    if str.length(aMid) > 0
        alert(_hdr + "MIDLINE touched: " + aMid, alert.freq_once_per_bar_close)
    if str.length(aHeld) > 0
        alert(_hdr + "HELD then broken: " + aHeld, alert.freq_once_per_bar_close)
    if str.length(aBroken) > 0
        alert(_hdr + "BROKEN: " + aBroken, alert.freq_once_per_bar_close)

alertcondition(str.length(aNew) > 0,    "New zone",        "VSA DIGGA — NBF/NSF zone confirmed by departure on {{ticker}} {{interval}}")
alertcondition(str.length(aStrong) > 0, "New strong zone", "VSA DIGGA — new STRONG zone on {{ticker}} {{interval}}")
alertcondition(str.length(aTest) > 0,   "Zone tested",     "VSA DIGGA — zone tested on {{ticker}} {{interval}} at {{close}}")
alertcondition(str.length(aMid) > 0,    "Midline touched", "VSA DIGGA — midline touched on {{ticker}} {{interval}} at {{close}}")
alertcondition(str.length(aHeld) > 0,   "Zone held",       "VSA DIGGA — zone held its ground and is now broken on {{ticker}} {{interval}}")
alertcondition(str.length(aBroken) > 0, "Zone broken",     "VSA DIGGA — zone broken on {{ticker}} {{interval}} at {{close}}")

//══════════════════════════════════════════════════════════════════════
// ⑤ SCOREBOARD — the indicator keeps a record of itself
//══════════════════════════════════════════════════════════════════════
// zones = bases that DEPARTED (a forming cluster that never left is 'aborted', not a zone).
// held % = held / (held + broken), over TESTED zones only. A zone price never came back to —
// whether it expired or was simply run through — proves nothing either way and is not scored.
// Rows for tags you switched off are not shown.
var table dash = table.new(_pos(vsDashPos), 4, 16, frame_color = cLine, frame_width = 1, border_color = cLine, border_width = 1)

f_row(int _r, string _name, int _i, color _c) =>
    int _h = array.get(cHeld, _i)
    int _b = array.get(cBroken, _i)
    string _pct = _h + _b > 0 ? str.tostring(math.round(100.0 * _h / (_h + _b))) + "%" : "—"
    table.cell(dash, 0, _r, _name,                               text_color = _c,  text_size = _sz(vsDashSize), bgcolor = cCell, text_halign = text.align_left)
    table.cell(dash, 1, _r, str.tostring(array.get(cZones, _i)),  text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cCell)
    table.cell(dash, 2, _r, str.tostring(array.get(cTested, _i)), text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cCell)
    table.cell(dash, 3, _r, _pct,                                text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cCell)

if barstate.islast and vsDashOn
    table.clear(dash, 0, 0, 3, 15)
    table.cell(dash, 0, 0, "VSA DIGGA ver1.0 · " + BUILD, text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cHdr, text_halign = text.align_left)
    table.cell(dash, 1, 0, "zones",  text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cHdr)
    table.cell(dash, 2, 0, "tested", text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cHdr)
    table.cell(dash, 3, 0, "held",   text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cHdr)
    int r = 1
    f_row(r, "NBF", 10, cNbf)
    r += 1
    f_row(r, "NSF", 11, cNsf)
    r += 1
    bool[] on = array.from(vsTagNS and useVol, vsTagND and useVol, vsTagTEST and useVol, vsTagNR, vsTagNR, vsTagID, vsTagSV and useVol, vsTagBC and useVol, vsTagUT and useVol, vsTagSPR)
    for i = 0 to 9
        if array.get(on, i)
            f_row(r, array.get(TAG_KEY, i), i, cFg)
            r += 1
    int liveNbf = 0
    int liveNsf = 0
    int forming = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone zi = array.get(zones, i)
            if zi.state == 0
                forming += 1
            else if zi.kind == 1
                liveNbf += 1
            else
                liveNsf += 1
    table.cell(dash, 0, r, "live " + str.tostring(liveNbf) + " / " + str.tostring(liveNsf) + " · forming " + str.tostring(forming)
         + " · aborted " + str.tostring(array.get(cAborted, 10) + array.get(cAborted, 11))
         + " · expired " + str.tostring(array.get(cExpired, 10) + array.get(cExpired, 11))
         + " · untested breaks " + str.tostring(array.get(cUntested, 10) + array.get(cUntested, 11)),
         text_color = cFg, text_size = _sz(vsDashSize), bgcolor = cCell, text_halign = text.align_left)
    table.merge_cells(dash, 0, r, 3, r)
    r += 1
    string _volTxt = not useVol ? "volume ignored — NS/ND/TEST/SV/BC/UT off" : (_realVol ? "" : "tick volume (forex/cfd)")
    table.cell(dash, 0, r, "bar: spread P" + str.tostring(math.round(sprRank)) + " · vol P" + str.tostring(math.round(volRank)) + (str.length(_volTxt) > 0 ? " · " + _volTxt : ""),
         text_color = isNarrow ? (useVol and vol <= pVolLow ? cNbf : cFg) : cFg, text_size = _sz(vsDashSize), bgcolor = cCell, text_halign = text.align_left)
    table.merge_cells(dash, 0, r, 3, r)

// Data window — the bar's reading, on any bar, by hand.
plot(sprRank, "spread P-rank", display = display.data_window, editable = false)
plot(volRank, "volume P-rank", display = display.data_window, editable = false)
plot(nbfBar ? 1 : 0, "NBF bar", display = display.data_window, editable = false)
plot(nsfBar ? 1 : 0, "NSF bar", display = display.data_window, editable = false)
````
