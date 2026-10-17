# Friction Map [NovaLens]

- url: https://www.tradingview.com/script/Eo1vYb0i-Friction-Map-NovaLens/
- type: indicator
- pine_id: PUB;11202ebce5b7468182ead6f54bdd11e8
- version: 1.0

## Description

Friction Map reads price structure the way a floor trader reads a room: it finds the price shelves where the market actually spent time, marks which ones are still live versus which the market has abandoned, and measures how much clear air you have to the nearest live shelf in each direction. It is a map of where structure is, how alive it is, and where the open space sits - not a buy or sell signal.

Most support/resistance tools draw static lines and leave them there forever, so the chart fills with levels that stopped mattering 300 bars ago. Friction Map keeps the same structure honest over time: every shelf carries a freshness that decays once the market stops trading at it, so the orange (live) shelves are the ones price has interacted with recently and the gray (fading) ones visibly age out.


═════════════════════════════════════════


◈ [b]HOW TO READ IT[/b]

Friction Map draws directly on the price chart. There are two views of the same structure.

[b]The shelves.[/b]
[list]
[*][b]Orange = LIVE[/b] - price traded here recently; this is the current structure context.
[*][b]Gray = FADING[/b] - price has not returned in a while; the market has moved on and the shelf dims the longer it stays untouched.
[*][b]Faint dotted = BROKEN[/b] - price closed through it; an x-cross marks the exact bar it failed, and the dotted tail is kept so you can still see it existed.
[*][b]KEY LEVEL[/b] - the strongest live shelf on the map (boldest line, brightest tag). The eye's anchor.
[/list]

[b]The room boxes.[/b] On the right edge, a box runs from current price to the nearest LIVE shelf above and below, with a label that reads the distance as a near-to-far range in ATR, for example "1 to 2.1 ATR" - meaning roughly 1 ATR of clear air, then the shelf running out to 2.1 ATR. ATR units make the read comparable on any symbol and timeframe. Teal means clear room; orange means a live shelf sits within about 1 ATR. When there is no live shelf in a direction the label reads "open air".

[b]The breakout badge.[/b] On a confirmed close that breaks the recent range, and only at the extremes, the map prints a one-word context badge: [b]CLEAR RUNWAY[/b] when there is no live shelf within the runway band ahead, or [b]WALLED[/b] (with the distance) when a live shelf stands within about 1 ATR of the path. Only one CLEAR RUNWAY prints per clear-air leg - no repeats while price keeps running in the same open space, and it resets once price pulls back into a shelf. It is breakout context, never a direction call.

[b]The info panel.[/b] A compact info panel compiles the read: the structure memory in bars; [b]Room above[/b] and [b]Room below[/b] as ATR ranges; [b]Price now[/b] (open air, on a live shelf, or on a fading shelf); [b]Last breakout[/b] (the most recent badge and how many bars ago); [b]Shelves[/b] (how many live versus fading); and a one-line [b]Reading[/b] takeaway.

[b]The two views (Level view).[/b]
[list]
[*][b]Anchored[/b] (default): each shelf line starts at its origin diamond, shows its current live (orange) / fading (gray) state from that origin, and marks the x-cross where it broke. An anchored structure story - where structure formed, how it reads now, and where it broke if broken - not a full per-era ledger.
[*][b]Zones[/b]: every live shelf drawn as a clean full-width band straight across the chart, like a supply/demand map. Instant "where are my levels right now". No origin/break markers; broken shelves drop off.
[/list]


═════════════════════════════════════════


◉ [b]HOW IT WORKS[/b]

[b]The density field.[/b] Across the lookback window, the indicator measures how often each price level sat inside the high-low range of the lookback bars - a time-at-price-style structure read. For every bar it asks which price levels the bar's high-low range covered, and accumulates that into a density field using a difference-array method (O(L+bins) per bar) so the script stays fast even on long charts and heavy lookbacks. Price levels where many bars overlapped are dense; levels price passed through quickly are thin.

[b]Where shelves are born.[/b] A shelf forms at a density peak whose strength clears a RELATIVE floor - it must be at least a set fraction of the strongest peak currently on the map. That relative test is self-calibrating: it adapts to each asset and regime instead of relying on a fixed tick count, so the same indicator is designed to read BTC, SPY, EURUSD and gold without constant retuning. A small absolute floor screens out noise on near-empty windows.

[b]Data-driven width.[/b] Each shelf's band is not a fixed width. It expands outward from the peak for as long as the neighbouring density holds at least half the peak value, then is capped to a readable range in ATR units. A wide consolidation earns a wide shelf; a tight one stays thin.

[b]Aliveness (freshness).[/b] Every shelf carries a freshness equal to an exponential decay of the bars since the band was last traded (2^(-barsSinceTouch / halfLife)). Freshness is 1 while price is in the band and halves every half-life once price leaves. Above the live threshold a shelf renders LIVE (orange); below it the shelf renders FADING (gray) and dims further until it drops off the map.

[b]Causal lifecycle.[/b] Shelves are born on confirmed bars and never re-placed. A shelf becomes BROKEN only when price, after arming on one side with real separation, closes through to the other side - the break bar is frozen and the line continues as a faint dotted tail. The ORIGIN anchor (the earliest bar within the lookback where price actually traded that level) and the BREAK anchor are both set once and never rewritten. That frozen history is the trust element: the map cannot quietly redraw the past to look right.


═════════════════════════════════════════


✦ [b]HOW WE USE IT[/b]

A common read on a liquid crypto or index chart, default memory: price is pushing toward the top of its recent range. The panel Room above reads "0.4 to 1.6 ATR" in orange - there is a live shelf close overhead, so [b]the map reads the upside as walled[/b] in the near term. Room below reads "open air" - nothing live underneath. Price is sitting in open air between an overhead live shelf and abandoned structure far below.

Now price closes through the recent high. Because the nearest live shelf overhead was inside the runway band, the map prints [b]WALLED[/b] with the distance, not CLEAR RUNWAY - the break is into immediate structure, not open space. The badge does not say the break fails; it says there is a live shelf standing in the path, which is the context a discretionary trader wants before deciding whether the move has room.

Flip the situation: a confirmed break with Room ahead reading "open air" prints [b]CLEAR RUNWAY[/b]. In our testing, clear-runway breakouts travelled further on average than walled ones (the effect was modest and weakest on rates). That is an observation about context, not a guarantee about the next bar.

The point of the map is the same in every case: see where the live structure is, see how much clear air you have to it in ATR, and read the breakout against that structure instead of against a static line.


═════════════════════════════════════════


❖ [b]OTHER APPLICATIONS[/b]

[list]
[*][b]Trade-location context[/b]: read entries against the nearest live shelf rather than a static S/R line - the orange shelves are the structure price has interacted with most recently.
[*][b]Breakout context[/b]: CLEAR RUNWAY versus WALLED on a confirmed break, as a read on whether there is open space ahead or a live shelf in the path.
[*][b]Stop and target context[/b]: the room ranges in ATR give a structure-aware sense of where the nearest live shelves sit above and below, for evaluating whether planned stops or targets sit near recent structure or out in open air, instead of at round numbers.
[*][b]Chop filter[/b]: many overlapping live shelves with price standing on one ("on a live shelf" in the panel) is a congested read; sustained open air is cleaner trend space.
[*][b]Structure classifier[/b]: use the Shelves row (live versus fading) and Room rows as a top-down structure filter for any external trade plan, independent of the badges.
[*][b]Alert-driven workflow[/b]: subscribe to the clear-runway and walled breakout alerts and check the chart only when a confirmed breakout actually changes the structural picture.
[/list]


═════════════════════════════════════════


⚙ [b]GETTING STARTED[/b]

Friction Map ships with pre-tuned memory profiles plus a Custom override. Pick a memory and start reading the map - the default Auto setting matches the chart timeframe for you.

[b]Structure memory:[/b]
[list]
[*][b]Auto (match timeframe)[/b] (default): reads the chart - 30-minute and faster get Short, everything slower gets Medium.
[*][b]Short (60 bars)[/b]: about one trading day on 5m, a week on 1H. Faster-moving map.
[*][b]Medium (120 bars)[/b]: about a month on 1H, six months on 1D. Balanced.
[*][b]Long (240 bars)[/b]: slow, full-cycle structure.
[*][b]Custom[/b]: unlocks the Advanced group for full manual control.
[/list]

[b]Core display:[/b]
[list]
[*][b]Level view[/b]: Anchored (causal story, default) or Zones (clean full-width bands).
[*][b]Structure shelves[/b]: master toggle for the shelf lines. On by default. Under it, three per-state toggles let you choose which states draw:
[list]
[*][b]Live shelves (orange)[/b], [b]Fading shelves (gray)[/b], [b]Broken shelves (dotted)[/b] - all on by default. Turn Broken off to declutter when a level has rebuilt live on top of old broken tails.
[/list]
[*][b]Room boxes + labels[/b]: the price-to-nearest-live-shelf boxes and ATR range labels. On by default.
[*][b]Breakout badge[/b]: CLEAR RUNWAY / WALLED context badges on confirmed breakouts. On by default.
[*][b]Shelf state tags[/b]: a small LIVE / FADING / KEY LEVEL tag at the right end of each shelf. On by default; turn off for a cleaner chart once the colours are familiar.
[*][b]Show real shelf width[/b]: off by default (live shelves get a thin subtle halo). On draws each live shelf at its true data-driven width as a wider transparent band.
[*][b]Info panel[/b]: pick where the summary panel anchors - Top Right (default), Top Left, Bottom Right, Bottom Left, Middle Right, or Off to hide it.
[*][b]Dark theme panel[/b]: panel colours for dark charts; turn off on a light background.
[*][b]Level reach (bars)[/b]: how far back the shelf lines and halos draw, so old structure does not stretch across the whole chart.
[/list]

[b]Appearance / Colours (4 pickers):[/b]
[list]
[*]Live shelf, Fading shelf, Clear air, Broken shelf - each on its own line. The shelf lines, halos, room boxes, tags and badges all reference these inputs, so the palette adapts for colour-blind, light-mode or brand themes without forking the script.
[/list]

[b]Advanced (Memory = Custom only):[/b] Custom opens on the same defaults as the Medium profile (not a live copy of whichever profile you are currently on), so coming from Medium the switch is seamless; coming from Short or Long the map steps to that baseline first. Then every dial below is yours.
[list]
[*][b]Lookback (bars)[/b]: structure memory in bars. Larger = more history considered, slower-moving map.
[*][b]Freshness half-life[/b]: how fast a shelf fades once the market stops trading at it. After this many bars untouched a shelf is at half freshness.
[*][b]Breakout lookback[/b]: a breakout is a confirmed close that newly breaks beyond the prior N-bar high or low (a fresh cross, so a sustained trend does not re-fire it every bar).
[*][b]Min strength (vs strongest)[/b]: a shelf is born only if its density is at least this fraction of the strongest peak on the map. Raise for fewer, stronger shelves.
[*][b]Merge distance (ATR)[/b]: shelf candidates closer than this to an existing shelf refresh it instead of spawning a duplicate.
[*][b]Max shelves[/b]: cap on simultaneously tracked (non-broken) shelves; the weakest is pruned when a stronger one is born.
[*][b]Live threshold[/b]: freshness above this renders a shelf LIVE (orange).
[*][b]Runway band (ATR)[/b]: how far ahead of a breakout to scan for live shelves when deciding CLEAR RUNWAY versus WALLED.
[/list]


═════════════════════════════════════════


△ [b]LIMITATIONS[/b]

[list]
[*][b]Descriptive, not predictive[/b]: Friction Map shows where price spent time and how alive that structure is. It makes no claim that a shelf will hold or that a breakout will follow through. There is no buy or sell signal anywhere in the tool.
[*][b]Time-at-price, not volume[/b]: the density field is built from how much of the traded range sat at each level, not from volume. That keeps the read universally stable across every asset and data feed (crypto volume is fractured by exchange, FX volume is a tick proxy), but it does not weight a busy bar more than a quiet one.
[*][b]Backward-looking by construction[/b]: in fast moves and gaps, room can jump to "open air" quickly as price leaps into untraded territory. That is accurate but may not persist.
[*][b]Room measures to LIVE shelves only[/b]: the room ranges and the badge ignore fading shelves on purpose - the room read focuses on the current (orange) structure. A fading shelf still shows on the chart as a gray line; it just is not counted as room.
[*][b]The breakout effect is context, not edge[/b]: in testing, clear-runway breakouts travelled further than walled ones on average, but the difference was modest and weakest on rates. Treat the badge as context to read alongside your own plan, not as a validated signal.
[*][b]Recency fade[/b]: a structurally important level that has not been traded in a long time will fade from the map even if you still consider it important. Lengthen the memory or half-life if you want older structure to persist.
[/list]


═════════════════════════════════════════


🔔 [b]ALERTS[/b]

Two alert conditions are built in so you can monitor structure without watching every bar:

[list]
[*][b]Clear-runway breakout[/b]: a confirmed breakout into clear air (no live shelf within the runway band ahead).
[*][b]Walled breakout[/b]: a confirmed breakout into nearby live structure (a live shelf within about 1 ATR of the path).
[/list]

Both fire on bar close (gated on `barstate.isconfirmed`) - no intrabar repaint. The indicator also emits a richer alert with a pure-JSON payload for routing to your own automation or webhook stack. The payload carries the brand, the indicator name, the event, the direction, the up and down clearance in ATR, the current price, the ticker, the timeframe and the bar time (the clearance fields are sent as text and read "open" when there is no live shelf that way). Pick ONE mechanism per event - the dropdown alert condition for a simple notification, or the JSON alert for a webhook - so you do not get duplicate notifications. Badges and alerts fire even when the on-chart badge is toggled off; alerts should not require chart clutter.


═════════════════════════════════════════


⌁ [b]NOTES[/b]

[list]
[*]Built on a containment-count density field (time-at-price), with data-driven band width, exponential freshness decay, and a causal frozen lifecycle (origin and break anchors set once and never moved).
[*]Method lineage: the density field is a time-at-price construction, in the tradition of Market Profile (J. Peter Steidlmayer, popularised at the CBOT in the 1980s), which reads structure from where the market spent time rather than from volume. Friction Map adds the freshness decay and the causal live/fading/broken lifecycle on top of that classical time-at-price idea.
[*]Repaint: non-repainting on confirmed bars. Births, breaks, clearance, badges and alerts are computed on bar close; the current bar updates in real time. Live/fading colour reflects current state, so a re-traded faded shelf can re-colour live - no past origin or break anchor is ever changed.
[*]Original construction. The engine is built from first principles for this tool; there is no external reference implementation, so no validation-correlation claim is made.
[*]Open-source under MPL 2.0. Free to use, fork, study.
[/list]

[b]NovaLens[/b]

## Source Code

````pine
//@version=6
// ============================================================================
// Friction Map [NovaLens]
//
// ENGINE MODEL: price-level structure map built from bar-range containment.
//   Detection field: how much of the lookback traded at each price level,
//   accumulated via a difference array (O(L+bins) per bar). Levels are born
//   at field peaks whose strength clears a RELATIVE floor (vs the strongest
//   peak on the current map) - self-calibrating on any asset or regime.
//   A level's band width is data-driven: it spans the price range where the
//   field holds at least half the peak's density.
//   Aliveness: per-level freshness = exponential decay since the band was
//   last traded (2^(-barsSinceTouch/halfLife)).
//   Lifecycle is causal: levels are born on confirmed bars and never re-placed;
//   the ORIGIN and BREAK anchors are frozen. The live/fading colouring reflects
//   CURRENT state, so if a faded shelf is re-traded its recent stretch can
//   re-colour live - this is current-state anchored history, not a frozen
//   per-era ledger.
//
// REPAINT POLICY: non-repainting on confirmed bars. Births, state changes,
//   clearance, runway badges and alerts are computed on barstate.isconfirmed
//   only. Each level is ANCHORED at its ORIGIN bar - the earliest bar where
//   price actually traded that level (computed once at detection, frozen).
//   The origin point and the break point never move - that is the trust
//   signal. Every line runs to a common right edge (the current bar); lines
//   redraw on the last bar to reflect the latest live/fading state, but no
//   past anchor (origin/break bar or price) is ever changed.
//
// HOW TO READ (10 seconds):
//   Each level is a thin horizontal line that STARTS at its ORIGIN - the
//   earliest bar where price actually traded that level - so the left end
//   always sits on real price action, and you see where the structure formed.
//   Every line runs rightward to the SAME right edge (the current bar).
//   The line is colored by CURRENT state, anchored to the shelf's origin:
//     ORANGE = the shelf is currently live (recently traded).
//     GRAY   = the shelf is currently fading (the market has moved on).
//   This is current-state anchored history, not a full per-era ledger.
//   MARKERS pin the causal story:
//     diamond at the left end = ORIGIN (where price first built the level).
//     x-cross                 = BROKE (price closed through it); the line
//                               continues faint-dotted to the right edge.
//   Bolder line + a soft halo = stronger, currently-live structure.
//   KEY LEVEL = the strongest live level, the first one to watch.
//   BOXES at the right edge = your ROOM: distance in ATR from price to the
//     nearest live shelf above and below.
//   CLEAR RUNWAY / WALLED = breakout context, printed only on confirmed
//     breakouts: open path ahead vs a live shelf standing in the path.
//
// HONESTY: descriptive lens, not a signal. Levels are where price spent
//   time, not predictions. No claim that levels hold, no buy/sell language.
// ============================================================================

indicator("Friction Map [NovaLens]", shorttitle = "Friction Map [NovaLens]",
     overlay = true, max_bars_back = 500, max_lines_count = 100,
     max_labels_count = 200, max_boxes_count = 400,
     calc_bars_count = 1500)   // engine runs on the last 1500 bars only - the map only
                               // needs recent history; cuts runtime ~3-4x on long charts
                               // so it stays well under the plan's runtime limit.

// brand metadata (publish standard)
string BRAND_NAME   = "NovaLens"
string BRAND_ENTITY = "NovaLens Quantitative Research"

// ---------------------------------------------------------------- inputs ---
grpP = "Memory"
memSel = input.string("Auto (match timeframe)", "Structure memory", options = ["Auto (match timeframe)", "Short (60 bars)", "Medium (120 bars)", "Long (240 bars)", "Custom"], group = grpP,
     tooltip = "How far back the map remembers structure, in bars of your chart timeframe.\n\nAuto reads the chart: 30-minute charts and faster get Short, everything slower gets Medium.\n\nShort = 60 bars (about 1 trading day on 5m, a week on 1H)\nMedium = 120 bars (about 1 month on 1H, 6 months on 1D, 2.3 years on 1W)\nLong = 240 bars (slow, full-cycle structure)\n\nCustom unlocks the Advanced group below.")

grpD = "Display"
levelView    = input.string("Anchored", "Level view", options = ["Anchored", "Zones"], group = grpD, tooltip = "Two ways to draw the same levels.\n\nANCHORED (default): each line starts at the bar the level actually formed (the diamond), splits into a live era and a fading era, and shows where it broke. The causal story - when structure formed and died.\n\nZONES: every live level drawn as a clean full-width band straight across the chart, like a supply/demand map. Instant 'where are my levels right now'. No origin/break markers; broken levels drop off.")
showLevels   = input.bool(true,  "Structure shelves",       group = grpD, tooltip = "The price bands where the market spent serious time. Band width comes from the data: a wide consolidation gets a wide shelf.\n\nOrange = LIVE (traded there recently)\nGray = FADING (the market left)\nFaint dotted edge = BROKEN (price closed through)\n\nMaster toggle for shelf lines; use the three below to pick which states draw.")
showLive     = input.bool(true,  "Live shelves (orange)",   group = grpD, tooltip = "Show LIVE shelves - structure price has traded recently and is acting on now.")
showFading   = input.bool(true,  "Fading shelves (gray)",   group = grpD, tooltip = "Show FADING shelves - structure the market has been leaving; they dim the longer they stay untouched.")
showBroken   = input.bool(true,  "Broken shelves (dotted)", group = grpD, tooltip = "Show BROKEN shelves - levels price has closed through, drawn as a faint dotted tail. Turn off to declutter when a level has rebuilt LIVE on top of old broken tails.")
showCorridor = input.bool(true,  "Room boxes + labels",     group = grpD, tooltip = "Your room in each direction: a box from current price to the nearest live shelf above and below, labeled in ATR units.\n\nATR units make the read comparable on any symbol and timeframe: 0.5 ATR is close on BTC and on SPY alike.\n\nTeal = plenty of room\nOrange = a live shelf within 1 ATR")
showBadge    = input.bool(true,  "Breakout badge",          group = grpD, tooltip = "Prints only when a confirmed close breaks the recent range, and only at the extremes:\n\nCLEAR RUNWAY = no live shelf in the path ahead\nWALLED (+ distance) = a live shelf within about 1 ATR of the path\n\nIn testing, clear-runway breakouts traveled further than walled ones on average (weakest on rates).\n\nOnly one CLEAR RUNWAY prints per clear-air leg (no repeats while price keeps running in the same open space). Breakout context, never a buy or sell signal.")
showTags     = input.bool(true,  "Shelf state tags",        group = grpD, tooltip = "A small LIVE or FADING tag at the right end of each tracked shelf, so the color never needs guessing. The strongest live shelf is tagged KEY LEVEL.\n\nTurn off for a cleaner chart once the colors are familiar.")
panelDark    = input.bool(true,  "Dark theme panel",        group = grpD, tooltip = "Panel colors for dark charts. Turn off on a light chart background.")
showRealW    = input.bool(false, "Show real shelf width",   group = grpD, tooltip = "Off (default): live shelves get a thin, subtle halo so the chart stays calm.\n\nOn: each LIVE shelf is drawn at its TRUE data-driven width - the full price zone where the trade actually concentrated - as a wider transparent band. A fat consolidation reads as a fat zone, a tight one stays thin.\n\nThe width is real structure the engine already measures (capped so a huge range cannot fill the screen). Fading and broken shelves stay thin lines either way.")
panelPosS    = input.string("Top Right", "Info panel", options = ["Off", "Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = grpD,
     tooltip = "Show the summary panel and pick where it anchors. Choose Off to hide it entirely. Move it if it overlaps the symbol watermark or another indicator's panel.")

grpC = "Colors"
colLive  = input.color(#E67E22, "Live shelf",      group = grpC)
colStale = input.color(#7C8AA0, "Fading shelf",    group = grpC)
colClear = input.color(#1ABC9C, "Clear air",       group = grpC)
colBrkn  = input.color(#566273, "Broken shelf",    group = grpC)
levelReach = input.int(180, "Level reach (bars)", minval = 30, maxval = 500, group = grpD, tooltip = "How far back the level lines and halos draw, in bars. Caps the visual so old levels do not stretch across the whole chart.")

grpA = "Advanced (Memory = Custom only)"
aLbars  = input.int(120, "Lookback (bars)",        minval = 40, maxval = 300, group = grpA, tooltip = "Structure memory in bars. Larger = more history considered, slower-moving map.\n\nApplies only when Memory = Custom.")
aHalf   = input.int(30,  "Freshness half-life",    minval = 5,  maxval = 120, group = grpA, tooltip = "How fast a shelf fades once the market stops trading at it.\n\nAfter this many bars untouched a shelf is at half freshness; after about 3 half-lives it reads fully abandoned.\n\n30 bars is about 6 weeks on a daily chart.\n\nApplies only when Memory = Custom.")
aBrkLb  = input.int(20,  "Breakout lookback",      minval = 10, maxval = 60,  group = grpA, tooltip = "A breakout = a confirmed close beyond the prior N-bar high or low.\n\n20 keeps it meaningful without being rare.\n\nApplies only when Memory = Custom.")
aRelStr = input.float(0.30, "Min strength (vs strongest)", minval = 0.10, maxval = 0.90, step = 0.05, group = grpA, tooltip = "A shelf is born only if its density is at least this fraction of the STRONGEST peak on the current map. Self-calibrating: it adapts to every asset and regime.\n\nRaise for fewer, stronger shelves.\n\nApplies only when Memory = Custom.")
aMerge  = input.float(1.5, "Merge distance (ATR)", minval = 0.4, maxval = 3.0, step = 0.1, group = grpA, tooltip = "Shelf candidates closer than this (in ATR) to an existing shelf refresh it instead of spawning a duplicate.\n\nWider = fewer, broader shelves.\n\nApplies only when Memory = Custom.")
aMaxLv  = input.int(6,   "Max shelves",            minval = 3,  maxval = 16,  group = grpA, tooltip = "Cap on simultaneously tracked (non-broken) shelves; the weakest is pruned when a stronger one is born.\n\nApplies only when Memory = Custom.")
aFresh  = input.float(0.50, "Live threshold",      minval = 0.2, maxval = 0.9, step = 0.05, group = grpA, tooltip = "Freshness above this renders a shelf LIVE (orange).\n\n0.50 means touched within one half-life. Below half of this value it renders fully faded.\n\nApplies only when Memory = Custom.")
aAhead  = input.float(2.0, "Runway band (ATR)",    minval = 1.0, maxval = 4.0, step = 0.5, group = grpA, tooltip = "How far ahead of a breakout to scan for live shelves when deciding CLEAR RUNWAY vs WALLED.\n\n2.0 ATR matches the band the effect was tested on.\n\nApplies only when Memory = Custom.")

// memory resolution: bound to the CHART TIMEFRAME, not a trading style
tfSec    = timeframe.in_seconds()
isCustom = memSel == "Custom"
memAuto  = memSel == "Auto (match timeframe)"
memShort = memSel == "Short (60 bars)"  or (memAuto and tfSec <= 1800)
memLong  = memSel == "Long (240 bars)"
L      = isCustom ? aLbars  : memShort ? 60 : memLong ? 240 : 120
HALF   = isCustom ? aHalf   : memShort ? 15 : memLong ? 60  : 30
BRKLB  = isCustom ? aBrkLb  : memLong ? 40 : 20
RELSTR = isCustom ? aRelStr : 0.30
MERGE  = isCustom ? aMerge  : 1.5
MAXLV  = isCustom ? aMaxLv  : 6
FRESHL = isCustom ? aFresh  : 0.50
AHEAD  = isCustom ? aAhead  : 2.0
NBINS  = 50
ABSMIN = 0.04           // absolute floor: >= 4% of lookback bars (garbage guard)
KEEPBR = 200            // bars a broken level stays drawn before drop
MAXAGE = 400            // bars an untouched shelf survives
FRESHS = FRESHL * 0.5   // below this, fully faded rendering
panelAnchor = panelPosS == "Top Left" ? position.top_left : panelPosS == "Bottom Right" ? position.bottom_right : panelPosS == "Bottom Left" ? position.bottom_left : panelPosS == "Middle Right" ? position.middle_right : position.top_right
showPanel   = panelPosS != "Off"

// ------------------------------------------------------------- the engine --
atr = ta.atr(14)
warm = bar_index >= L + 20 and not na(atr) and atr > 0
// hoisted ta.* calls (must run every bar for series consistency)
gridLo = ta.lowest(low[1], L)        // prior-bar window: matches the density loop (bars 1..L), so the current bar cannot stretch the grid before it is binned
gridHi = ta.highest(high[1], L)
prevHi = ta.highest(high[1], BRKLB)  // trailing high/low of the prior BRKLB bars (excludes current)
prevLo = ta.lowest(low[1], BRKLB)

// level UDT: band frozen at birth; state forward-only; drawing segmented
type Lvl
    float price       // band mid, frozen at birth
    float top         // band top, data-driven width, frozen at birth
    float bot         // band bottom, frozen at birth
    int   birthBar
    float birthStr    // strength RELATIVE to the field max at birth (frozen)
    int   state       // 1 live, 2 tested, 3 broken
    int   side        // last side fully outside band: -1, 0, +1
    bool  armed       // has been fully outside band since birth/refresh
    float fresh       // 2^(-barsSinceTouch/HALF): 1 = being traded now
    int   lastTouch   // last bar whose range overlapped the band
    int   brokeBar
    int   liveUntilBar // last bar this level was LIVE (era boundary for drawing)
    int   originBar    // earliest bar price actually traded this level (frozen)

var array<Lvl> lvls = array.new<Lvl>()

// line color by current freshness: live = orange, faded = gray
lineCol(float fresh) =>
    fresh >= FRESHL ? colLive : colStale

// room/corridor colour by CLEARANCE state (never by direction):
// teal = clear or open, orange = a live shelf is within ~1 ATR.
roomColor(float clearance) =>
    na(clearance) or clearance > 1.0 ? colClear : colLive

// drawing is decoupled from the engine (rendered fresh on the last bar),
// so dropping a level is just removing it from the state array.
dropLevel(int idx) =>
    array.remove(lvls, idx)

// freshness = exponential decay since the band was last traded.
freshOf(int lastTouch) =>
    math.pow(2.0, -(bar_index - lastTouch) / float(HALF))

// first (earliest) and last (most recent) touch of the band, in bars-ago.
// firstAgo = largest i with a touch (the ORIGIN); lastAgo = smallest i (freshness).
firstLastTouch(float top, float bot) =>
    int firstAgo = na
    int lastAgo  = na
    for i = 1 to L
        if low[i] <= top and high[i] >= bot
            if na(lastAgo)
                lastAgo := i
            firstAgo := i
    [firstAgo, lastAgo]

// ---- per-bar pipeline (confirmed bars only); order: lifecycle -> births ->
// ---- clearance/runway -> render. Corridor never points at a just-broken shelf.
var float clrUp  = na   // near-edge clearance up (ATR) - drives the badge + export
var float clrDn  = na
var float upNear = na   // price: near edge (bot) of the nearest LIVE shelf above
var float upFar  = na   // price: far edge (top) of that shelf
var float dnNear = na   // price: near edge (top) of the nearest LIVE shelf below
var float dnFar  = na   // price: far edge (bot)
var int lastBrkBar = na
var string lastBrkTag = na
var int crDir = 0   // active clear-runway leg: +1 up, -1 down, 0 none (regime-reset dedup)
var array<label> badges = array.new<label>()
bool fcClear  = false
bool fcWalled = false

if warm and barstate.isconfirmed
    // -- 1) lifecycle ------------------------------------------------------
    if array.size(lvls) > 0
        for i = array.size(lvls) - 1 to 0
            Lvl lv = array.get(lvls, i)
            if (lv.state == 3 and bar_index - lv.brokeBar > KEEPBR) or (lv.state != 3 and bar_index - lv.lastTouch > MAXAGE)
                dropLevel(i)
                continue
            if lv.state == 3
                continue
            if low <= lv.top and high >= lv.bot
                lv.lastTouch := bar_index
            lv.fresh := freshOf(lv.lastTouch)
            if lv.fresh >= FRESHL
                lv.liveUntilBar := bar_index
            // arming needs real separation (not in-zone wiggle)
            bw = (lv.top - lv.bot) / 2.0
            armDist = math.max(bw, 0.75 * atr)
            farAbove = close > lv.price + armDist
            farBelow = close < lv.price - armDist
            inBand = close <= lv.top and close >= lv.bot
            if farAbove or farBelow
                ns = farAbove ? 1 : -1
                if lv.armed and lv.side != 0 and ns != lv.side
                    lv.state := 3
                    lv.brokeBar := bar_index
                else
                    lv.side := ns
                    lv.armed := true
            else if inBand and lv.armed and lv.state == 1
                lv.state := 2

    // -- 1b) total-budget cap: keep object counts safe on choppy intraday.
    // prune OLDEST BROKEN first, then OLDEST FADING; a live shelf is never pruned here.
    while array.size(lvls) > MAXLV + 8
        int brkIdx = -1
        int fadeIdx = -1
        int oldestBrkBar = 1000000000
        int oldestFadeTouch = 1000000000
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state == 3
                if lv.brokeBar < oldestBrkBar
                    oldestBrkBar := lv.brokeBar
                    brkIdx := i
            else if lv.fresh < FRESHL
                if lv.lastTouch < oldestFadeTouch
                    oldestFadeTouch := lv.lastTouch
                    fadeIdx := i
        int dropIdx = brkIdx >= 0 ? brkIdx : fadeIdx
        if dropIdx < 0
            break
        dropLevel(dropIdx)

    // -- 2) births: difference-array field accumulation (O(L+bins)) --------
    span = gridHi - gridLo
    if span > 0
        step = span / NBINS
        dDiff = array.new<float>(NBINS + 2, 0.0)
        for i = 1 to L
            bLo = math.max(0, int(math.floor((low[i] - gridLo) / step)))
            bHi = math.min(NBINS, int(math.floor((high[i] - gridLo) / step)))
            if bHi >= bLo
                array.set(dDiff, bLo, array.get(dDiff, bLo) + 1.0)
                array.set(dDiff, bHi + 1, array.get(dDiff, bHi + 1) - 1.0)
        dens = array.new<float>(NBINS + 1, 0.0)
        float acc = 0.0
        float maxD = 0.0
        for b = 0 to NBINS
            acc += array.get(dDiff, b)
            array.set(dens, b, acc)
            maxD := math.max(maxD, acc)
        // smooth (integer counts plateau; ties kill strict peak tests)
        sm = array.new<float>(NBINS + 1, 0.0)
        for b = 1 to NBINS - 1
            array.set(sm, b, (array.get(dens, b - 1) + array.get(dens, b) + array.get(dens, b + 1)) / 3.0)
        if maxD > 0
            for b = 1 to NBINS - 1
                d0 = array.get(dens, b)
                // RELATIVE strength floor (self-calibrating) + small absolute guard
                if d0 < RELSTR * maxD or d0 < ABSMIN * L
                    continue
                if array.get(sm, b) <= array.get(sm, b - 1) or array.get(sm, b) < array.get(sm, b + 1)
                    continue
                p = gridLo + (b + 0.5) * step
                // data-driven band: expand while neighbors hold >= half the peak
                int bL = b
                int bR = b
                while bL > 0 and array.get(dens, bL - 1) >= 0.5 * d0
                    bL -= 1
                while bR < NBINS - 1 and array.get(dens, bR + 1) >= 0.5 * d0
                    bR += 1
                float bTop = gridLo + (bR + 1.0) * step
                float bBot = gridLo + float(bL) * step
                // cap band half-width to keep shelves readable (0.15..0.6 ATR)
                float halfW = math.min(math.max((bTop - bBot) / 2.0, 0.15 * atr), 0.6 * atr)
                bTop := p + halfW
                bBot := p - halfW
                [firstAgo, lastAgo] = firstLastTouch(bTop, bBot)
                if na(lastAgo)
                    continue
                touchBar  = bar_index - lastAgo
                originBar = bar_index - firstAgo
                f = freshOf(touchBar)
                // freshness decides RENDERING (live vs faded), not existence
                if f < 0.10
                    continue
                merged = false
                if array.size(lvls) > 0
                    for i = 0 to array.size(lvls) - 1
                        Lvl lv = array.get(lvls, i)
                        if lv.state == 3
                            continue                        // a broken level does not suppress new structure, so a rebuilt level re-forms cleanly
                        if math.abs(lv.price - p) <= MERGE * atr
                            merged := true
                            if lv.state == 2 and lv.fresh >= FRESHL
                                lv.state := 1
                                lv.armed := false
                                lv.side  := 0
                                lv.liveUntilBar := bar_index
                            break
                if not merged
                    nAlive = 0
                    weakest = -1
                    float weakScore = 1e18
                    if array.size(lvls) > 0
                        for i = 0 to array.size(lvls) - 1
                            Lvl lv = array.get(lvls, i)
                            if lv.state != 3
                                nAlive += 1
                                // keep-score: LIVE levels always outrank FADING ones (+100),
                                // then by birth strength. So the cap prunes old fading
                                // structure before recent live structure near price.
                                float score = (lv.fresh >= FRESHL ? 100.0 : 0.0) + lv.birthStr
                                if score < weakScore
                                    weakScore := score
                                    weakest := i
                    relNow = d0 / maxD
                    float newScore = 100.0 + relNow   // a newborn level is live
                    if nAlive >= MAXLV and weakest >= 0 and newScore > weakScore
                        dropLevel(weakest)
                        nAlive -= 1
                    if nAlive < MAXLV
                        int initState     = f >= FRESHL ? 1 : 2          // born-faded levels start as tested, so internal state matches the visual
                        int initLiveUntil = f >= FRESHL ? bar_index : touchBar
                        Lvl nl = Lvl.new(p, bTop, bBot, bar_index, relNow, initState, 0, false, f, touchBar, na, initLiveUntil, originBar)
                        array.push(lvls, nl)

    // -- 3) clearance: the nearest LIVE shelf each way as a NEAR->FAR edge range.
    // near edge = where clear air ends (price first meets structure); far edge = where
    // the shelf ends. LIVE only (fading skipped). clrUp/clrDn = the NEAR-edge distance.
    upNear := na
    upFar  := na
    dnNear := na
    dnFar  := na
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state == 3 or lv.fresh < FRESHL
                continue
            if close <= lv.top and close >= lv.bot
                continue                                   // standing on this shelf, not "room"
            if lv.bot > close and (na(upNear) or lv.bot < upNear)
                upNear := lv.bot                            // near edge of nearest live shelf above
                upFar  := lv.top
            if lv.top < close and (na(dnNear) or lv.top > dnNear)
                dnNear := lv.top                            // near edge of nearest live shelf below
                dnFar  := lv.bot
    clrUp := na(upNear) ? na : (upNear - close) / atr
    clrDn := na(dnNear) ? na : (close - dnNear) / atr

    // -- 4) runway badge (breakouts only, extremes only) -------------------
    // regime reset: once price closes back inside any live/tested shelf, the clear-air leg ends
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lvR = array.get(lvls, i)
            if lvR.state != 3 and close <= lvR.top and close >= lvR.bot
                crDir := 0
                break
    brokeUp = close > prevHi and close[1] <= prevHi[1]   // fresh cross above the trailing high (fires once, not every bar of a trend)
    brokeDn = close < prevLo and close[1] >= prevLo[1]
    if (brokeUp or brokeDn) and (na(lastBrkBar) or bar_index - lastBrkBar >= 5)
        aheadClr = brokeUp ? clrUp : clrDn
        dir = brokeUp ? 1 : -1
        isClear  = na(aheadClr) or aheadClr > AHEAD
        isWalled = not isClear and aheadClr <= 1.0
        tag = isClear ? "CLEAR RUNWAY" : isWalled ? "WALLED " + str.tostring(aheadClr, "#.#") + " ATR" : ""
        suppress = isClear and crDir == dir   // one CLEAR RUNWAY per clear-air leg: no repeat while still running in the same open space
        if tag != "" and not suppress
            lastBrkBar := bar_index
            lastBrkTag := tag
            fcClear  := isClear
            fcWalled := isWalled
            crDir := isClear ? dir : 0
            if showBadge
                bcol = fcClear ? colClear : colLive
                lb = label.new(bar_index, brokeUp ? low - atr * 0.6 : high + atr * 0.6, tag, style = brokeUp ? label.style_label_up : label.style_label_down, color = color.new(bcol, 15), textcolor = color.white, size = size.small, tooltip = "Breakout context read.\n\nModest follow-through difference in testing, strongest on trending assets, weaker on rates.\n\nNot a buy or sell signal.")
                array.push(badges, lb)
                if array.size(badges) > 2
                    label.delete(array.shift(badges))
            dirStr = brokeUp ? "up" : "down"
            cu = na(clrUp) ? "open" : str.tostring(clrUp, "#.##")
            cd = na(clrDn) ? "open" : str.tostring(clrDn, "#.##")
            msg = '{"brand":"' + BRAND_NAME + '","indicator":"FrictionMap","event":"' + (fcWalled ? "walled_breakout" : "clear_runway") + '","dir":"' + dirStr + '","clearance_up":"' + cu + '","clearance_down":"' + cd + '","price":"' + str.tostring(close, format.mintick) + '","sym":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","time":"' + str.tostring(time) + '"}'
            alert(msg, alert.freq_once_per_bar_close)

// alert discoverability (static fallbacks in TV's alert dropdown)
alertcondition(fcClear,  "Clear-runway breakout", "Friction Map: confirmed breakout into clear air. Context read, not a signal.")
alertcondition(fcWalled, "Walled breakout",       "Friction Map: confirmed breakout into nearby live structure. Context read, not a signal.")

// data-window engine exports (legend hygiene: hidden from chart)
plot(clrUp, "clearance_up_atr (engine)",   display = display.data_window, editable = false)
plot(clrDn, "clearance_down_atr (engine)", display = display.data_window, editable = false)

// ------------------------------------------------------ structure lines ---
// Each level draws as a thin line ANCHORED AT ITS BIRTH BAR (not a fixed
// lookback), split into a LIVE era (orange) and a FADING era (gray) at the
// real bar the level last went live, with a birth diamond and a break x-cross.
// Clean like flat lines, but the causal story (when it formed, when it died)
// is preserved - that is the trust element. A soft halo on live levels keeps
// the sense of zone width so wide consolidations still read fatter.
var array<line>  lvLn   = array.new<line>()
var array<box>   lvHalo = array.new<box>()
var array<label> lvMark = array.new<label>()

if barstate.islast and showLevels and warm
    for ln in lvLn
        line.delete(ln)
    array.clear(lvLn)
    for bx in lvHalo
        box.delete(bx)
    array.clear(lvHalo)
    for mk in lvMark
        label.delete(mk)
    array.clear(lvMark)
    // strongest live level = KEY (boldest + brightest)
    float keyS = -1.0
    int   keyI = -1
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state != 3 and lv.fresh >= FRESHL and lv.birthStr > keyS
                keyS := lv.birthStr
                keyI := i
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            bool broken = lv.state == 3
            bool isKey  = i == keyI
            bool _live = not broken and lv.fresh >= FRESHL
            bool _fade = not broken and lv.fresh < FRESHL
            if (broken and not showBroken) or (_live and not showLive) or (_fade and not showFading)
                continue
            int wid   = isKey ? 3 : lv.birthStr >= 0.55 ? 2 : 1
            float halfThin = math.min(math.max((lv.top - lv.bot) / 2.0, 0.05 * atr), 0.13 * atr)  // soft cosmetic glow that hugs the line (not a band)
            float halfReal = math.max((lv.top - lv.bot) / 2.0, 0.05 * atr)
            float halfH = showRealW ? halfReal : halfThin
            if levelView == "Zones"
                // ZONES: clean full-width S/R bands across the chart, current-state
                // colour, no origin/break markers. Broken levels drop off the map.
                if not broken
                    color zcol = lineCol(lv.fresh)
                    int leftX  = math.max(0, bar_index - levelReach)
                    int rightX = bar_index
                    if lv.fresh >= FRESHL or showRealW
                        int haloA = lv.fresh >= FRESHL ? (showRealW ? (isKey ? 80 : 86) : (isKey ? 84 : 89)) : 91
                        array.push(lvHalo, box.new(leftX, lv.price + halfH, rightX, lv.price - halfH, border_color = na, bgcolor = color.new(zcol, haloA)))
                    array.push(lvLn, line.new(leftX, lv.price, rightX, lv.price, color = color.new(zcol, isKey ? 0 : 12), width = wid))
            else
                // ANCHORED (default): the causal story - origin to now, era split, markers.
                int startX = math.max(0, lv.originBar)
                int endX   = bar_index
                if endX <= startX
                    endX := startX + 1
                int breakX = broken ? math.max(startX, math.min(lv.brokeBar, endX)) : endX
                int liveEnd = (not broken and lv.fresh >= FRESHL) ? endX : lv.liveUntilBar
                liveEnd := math.max(startX, math.min(liveEnd, breakX))
                int liveT = broken ? 62 : (isKey ? 0 : 14)
                int fadeT = broken ? 74 : 48
                if liveEnd > startX
                    array.push(lvLn, line.new(startX, lv.price, liveEnd, lv.price, color = color.new(colLive, liveT), width = wid))
                if breakX > liveEnd
                    array.push(lvLn, line.new(liveEnd, lv.price, breakX, lv.price, color = color.new(colStale, fadeT), width = broken ? 1 : wid))
                if broken and endX > breakX
                    array.push(lvLn, line.new(breakX, lv.price, endX, lv.price, color = color.new(colBrkn, 30), width = 1, style = line.style_dotted))
                if not broken and lv.fresh >= FRESHL
                    int haloA = showRealW ? (isKey ? 76 : 83) : (isKey ? 82 : 88)
                    array.push(lvHalo, box.new(startX, lv.price + halfH, endX, lv.price - halfH, border_color = na, bgcolor = color.new(colLive, haloA)))
                color bmCol = broken ? colBrkn : lv.fresh >= FRESHL ? colLive : colStale
                array.push(lvMark, label.new(startX, lv.price, "◆", style = label.style_none, textcolor = color.new(bmCol, 28), size = size.tiny, tooltip = "Origin: the earliest bar within the lookback where price traded this level - where the shelf first formed. The anchor is frozen. It marks where structure built, not a real-time prediction."))
                if broken
                    array.push(lvMark, label.new(breakX, lv.price, "", style = label.style_xcross, color = color.new(colBrkn, 12), size = size.tiny, tooltip = "Broke here: price closed beyond the opposite side after first separating to one side. The break point is frozen; the faint dotted tail shows the level is gone."))

// ------------------------------------------------------------- corridor ---
var box upBox = na
var box dnBox = na
var label upLab = na
var label dnLab = na

if barstate.islast and showCorridor and warm
    if not na(upBox)
        box.delete(upBox)
    if not na(dnBox)
        box.delete(dnBox)
    if not na(upLab)
        label.delete(upLab)
    if not na(dnLab)
        label.delete(dnLab)
    x1 = bar_index + 3      // sit just right of the chart edge, in clear space
    x2 = bar_index + 11
    if not na(upNear)
        // single room box: runs from price to the LEVEL LINE (band centre),
        // clearance-coloured; the near->far RANGE lives in the label
        cU = roomColor(clrUp)
        upMid = (upNear + upFar) / 2.0
        upBox := box.new(x1, upMid, x2, close, bgcolor = color.new(cU, 85), border_color = color.new(cU, 55), border_width = 1)
        nU = (upNear - close) / atr
        fU = (upFar - close) / atr
        upLab := label.new(x2, (close + upMid) / 2.0, "↑ " + str.tostring(nU, "#.#") + " to " + str.tostring(fU, "#.#") + " ATR  ·  " + str.tostring(upNear, format.mintick), style = label.style_label_left, color = color.new(cU, 65), textcolor = color.new(color.white, 0), size = size.small, tooltip = "Room above: clear air until the near edge (" + str.tostring(nU, "#.#") + " ATR), then a live shelf to its far edge (" + str.tostring(fU, "#.#") + " ATR).")
    else
        upLab := label.new(x2, close + AHEAD * atr, "↑ open air", style = label.style_label_left, color = color.new(colClear, 65), textcolor = color.new(color.white, 0), size = size.small, tooltip = "No live shelf above current price. Upside path is open as far as the map can see.")
    if not na(dnNear)
        cD = roomColor(clrDn)
        dnMid = (dnNear + dnFar) / 2.0
        dnBox := box.new(x1, close, x2, dnMid, bgcolor = color.new(cD, 85), border_color = color.new(cD, 55), border_width = 1)
        nD = (close - dnNear) / atr
        fD = (close - dnFar) / atr
        dnLab := label.new(x2, (close + dnMid) / 2.0, "↓ " + str.tostring(nD, "#.#") + " to " + str.tostring(fD, "#.#") + " ATR  ·  " + str.tostring(dnNear, format.mintick), style = label.style_label_left, color = color.new(cD, 65), textcolor = color.new(color.white, 0), size = size.small, tooltip = "Room below: clear air until the near edge (" + str.tostring(nD, "#.#") + " ATR), then a live shelf to its far edge (" + str.tostring(fD, "#.#") + " ATR).")
    else
        dnLab := label.new(x2, close - AHEAD * atr, "↓ open air", style = label.style_label_left, color = color.new(colClear, 65), textcolor = color.new(color.white, 0), size = size.small, tooltip = "No live shelf below current price. Downside path is open as far as the map can see.")

// ------------------------------------------------------- shelf state tags ---
var array<label> tags = array.new<label>()

if barstate.islast and showTags and warm
    if array.size(tags) > 0
        for i = 0 to array.size(tags) - 1
            label.delete(array.get(tags, i))
        array.clear(tags)
    // strongest live shelf = the KEY LEVEL (the eye's anchor)
    float keyStr = -1.0
    int keyIdx = -1
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state != 3 and lv.fresh >= FRESHL and lv.birthStr > keyStr
                keyStr := lv.birthStr
                keyIdx := i
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            bool broken = lv.state == 3
            if broken and levelView == "Zones"
                continue                                    // Zones view drops broken levels
            bool _liveT = not broken and lv.fresh >= FRESHL
            bool _fadeT = not broken and lv.fresh < FRESHL
            if (broken and not showBroken) or (_liveT and not showLive) or (_fadeT and not showFading)
                continue
            bool isKey  = i == keyIdx and not broken
            // tag text + colour by state; broken levels now get a BROKEN tag at the
            // right end of their dead-tail so the dotted line is self-explanatory
            string tg = broken ? "BROKEN" : isKey ? "KEY LEVEL" : lv.fresh >= FRESHL ? "LIVE" : "FADING"
            color tc = broken ? colBrkn : lv.fresh >= FRESHL ? colLive : colStale
            string tip = broken ? "BROKEN\n\nPrice closed straight through this level - the X marks the exact bar it failed.\n\nThe dotted trail is kept so you can still see the level existed and where it broke, then it drops off the map." : isKey ? "KEY LEVEL\n\nThe strongest live shelf on the map: where recent trade is most concentrated." : lv.fresh >= FRESHL ? "LIVE SHELF\n\nPrice traded here very recently, so the level is still current.\n\nThe orange shelves are the ones the market is acting on now." : "FADING SHELF\n\nPrice has not returned here in a while; the market has moved on.\n\nIt dims the longer it stays untouched, then drops off the map."
            int tagT = broken ? 68 : isKey ? 55 : 78
            int txtT = broken ? 25 : isKey ? 0 : 15
            array.push(tags, label.new(bar_index, lv.price, tg, style = label.style_label_left, color = color.new(tc, tagT), textcolor = color.new(color.white, txtT), size = size.tiny, tooltip = tip))

// ---------------------------------------------------------------- panel ---
// Dashboard look: borderless striped rows, colored value chips.
var table pan = table.new(panelAnchor, 2, 7, border_width = 0, frame_color = color.new(#7C8AA0, 82), frame_width = 1)

if barstate.islast and showPanel
    bgA  = panelDark ? color.new(#0E1622, 6)  : color.new(#FFFFFF, 6)
    bgB  = panelDark ? color.new(#15202F, 6)  : color.new(#F0F3F7, 6)
    txc  = panelDark ? color.new(#D9E2EC, 0)  : color.new(#1B2733, 0)
    hdc  = panelDark ? color.new(#1B2A3D, 0)  : color.new(#E2E8F0, 0)
    mut  = color.new(txc, 45)
    table.clear(pan, 0, 0, 1, 6)
    memStr = (memAuto ? "Auto · " : "") + str.tostring(L) + " bars"
    table.cell(pan, 0, 0, "FRICTION MAP", bgcolor = hdc, text_color = txc, text_size = size.small, text_halign = text.align_left, tooltip = "A map of live vs abandoned price structure, plus your room to the nearest live shelf each way.\n\nKey: orange = live shelf, gray = fading, dotted = broken, teal = clear air.\n\nDescriptive lens, not a signal.\n\n" + BRAND_ENTITY)
    table.cell(pan, 1, 0, memStr, bgcolor = hdc, text_color = mut, text_size = size.small, text_halign = text.align_right, tooltip = "Structure memory in bars of this chart's timeframe. Auto matches the timeframe.")
    // display-only near/far edges vs the CURRENT close
    float dUpN = na
    float dUpF = na
    float dDnN = na
    float dDnF = na
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state == 3 or lv.fresh < FRESHL
                continue
            if close <= lv.top and close >= lv.bot
                continue
            if lv.bot > close and (na(dUpN) or lv.bot < dUpN)
                dUpN := lv.bot
                dUpF := lv.top
            if lv.top < close and (na(dDnN) or lv.top > dDnN)
                dDnN := lv.top
                dDnF := lv.bot
    sUp = na(dUpN) ? "open" : "↑ " + str.tostring((dUpN - close) / atr, "#.#") + " to " + str.tostring((dUpF - close) / atr, "#.#") + " ATR  ·  " + str.tostring(dUpN, format.mintick)
    sDn = na(dDnN) ? "open" : "↓ " + str.tostring((close - dDnN) / atr, "#.#") + " to " + str.tostring((close - dDnF) / atr, "#.#") + " ATR  ·  " + str.tostring(dDnN, format.mintick)
    cUp = na(dUpN) or (dUpN - close) / atr > 1.0 ? colClear : colLive
    cDn = na(dDnN) or (close - dDnN) / atr > 1.0 ? colClear : colLive
    table.cell(pan, 0, 1, "Room above", bgcolor = bgA, text_color = mut, text_size = size.small, text_halign = text.align_left, tooltip = "From price to the nearest LIVE shelf above, as a range: clear air until the near edge, then the shelf to its far edge (in ATR).\n\n'open' = no live shelf above.")
    table.cell(pan, 1, 1, sUp, bgcolor = bgA, text_color = cUp, text_size = size.small, text_halign = text.align_right)
    table.cell(pan, 0, 2, "Room below", bgcolor = bgB, text_color = mut, text_size = size.small, text_halign = text.align_left, tooltip = "From price to the nearest LIVE shelf below, as a range (near edge to far edge, in ATR).")
    table.cell(pan, 1, 2, sDn, bgcolor = bgB, text_color = cDn, text_size = size.small, text_halign = text.align_right)
    string ctx = "open air"
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state != 3 and close <= lv.top and close >= lv.bot
                ctx := lv.fresh >= FRESHL ? "on a live shelf" : "on a fading shelf"
                break
    cCtx = ctx == "open air" ? colClear : ctx == "on a live shelf" ? colLive : colStale
    table.cell(pan, 0, 3, "Price now", bgcolor = bgA, text_color = mut, text_size = size.small, text_halign = text.align_left, tooltip = "Where price sits: open air, on a live shelf, or on a fading shelf.")
    table.cell(pan, 1, 3, ctx, bgcolor = color.new(cCtx, 80), text_color = cCtx, text_size = size.small, text_halign = text.align_right)
    rwTxt = na(lastBrkTag) ? "none recent" : lastBrkTag + " · " + str.tostring(bar_index - lastBrkBar) + "b ago"
    cRw = na(lastBrkTag) ? mut : str.startswith(lastBrkTag, "WALLED") ? colLive : colClear
    table.cell(pan, 0, 4, "Last breakout", bgcolor = bgB, text_color = mut, text_size = size.small, text_halign = text.align_left, tooltip = "Most recent breakout context. CLEAR RUNWAY = open path ahead; WALLED = a live shelf in the path.\n\nContext, never a buy or sell signal.")
    table.cell(pan, 1, 4, rwTxt, bgcolor = na(lastBrkTag) ? bgB : color.new(cRw, 80), text_color = cRw, text_size = size.small, text_halign = text.align_right)
    nL = 0
    nS = 0
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl lv = array.get(lvls, i)
            if lv.state == 3
                continue
            if lv.fresh >= FRESHL
                nL += 1
            else
                nS += 1
    table.cell(pan, 0, 5, "Shelves", bgcolor = bgA, text_color = mut, text_size = size.small, text_halign = text.align_left, tooltip = "Tracked structure: live (orange, traded recently) vs fading (gray, the market left).")
    table.cell(pan, 1, 5, str.tostring(nL) + " live · " + str.tostring(nS) + " fading", bgcolor = bgA, text_color = txc, text_size = size.small, text_halign = text.align_right)
    string rd = ctx == "on a live shelf" ? "trading inside live structure" : ctx == "on a fading shelf" ? "sitting on abandoned structure" : "open air: " + (na(dUpN) ? "clear above" : str.tostring((dUpN - close) / atr, "#.#") + " up") + ", " + (na(dDnN) ? "clear below" : str.tostring((close - dDnN) / atr, "#.#") + " down")
    table.cell(pan, 0, 6, "Reading", bgcolor = bgB, text_color = mut, text_size = size.small, text_halign = text.align_left, tooltip = "The one-line takeaway. Check your room both ways, focus on the orange (live) shelves, and read the badge on breakouts.")
    table.cell(pan, 1, 6, rd, bgcolor = bgB, text_color = color.new(txc, 25), text_size = size.small, text_halign = text.align_right)

// --------------------------------------------------------------- warmup ---
if not warm and barstate.islast and showPanel
    table.clear(pan, 0, 0, 1, 6)
    table.cell(pan, 0, 0, "FRICTION MAP", text_color = color.gray, text_size = size.small)
    table.cell(pan, 1, 0, "warming up", text_color = color.gray, text_size = size.small, text_halign = text.align_right, tooltip = "Not enough bars yet to compute the map at this memory setting. No state is faked during warmup.")
````
