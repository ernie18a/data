# 2022 Model+ (M1D)

- url: https://www.tradingview.com/script/aOI7PWOW-2022-Model-M1D/
- type: indicator
- pine_id: PUB;b5536d8e6d1d4de1af585e3e7672a79f
- version: 5.0

## Description

[b]2022 Model+[/b] 
Maps the ICT 2022 Model sequence on the chart and frames it against a multi-timeframe read of structure, liquidity and imbalance.

[b]The 2022 Model is a sequence, not a pattern:[/b] 
Liquidity is raided, price displaces away from the raid, and the displacement leaves a fair value gap that becomes the entry reference. This tool marks the first two stages where they actually happen and draws the context the third is read against.

[b]The marker[/b]
A swing pool is raided by a wick and the candle closes back inside it — a raid that failed, not a break. That arms a setup. If price then displaces away from the raid extreme by more than the threshold before the setup expires, the marker fires: the raided level draws dotted back to where it formed, the leg is shaded, and a label reports its size. A close back through the raided level cancels the setup instead, because the raid held. A deeper wick while the setup is live re-measures from the new extreme.

The threshold is a share of the previous day's range or a fixed point distance. The scaled option is the default and is measured against the day rather than against chart bars, so the same setting means the same thing on any chart timeframe and travels across futures, metals and crypto.

[b]Confirmed events only[/b]
Every marker, level and zone is recorded when the candle that produced it closes, and its position is not recalculated afterwards. The forming candle can draw nothing and remove nothing — a setup found an hour ago sits where it was found, and stays until its own state or the display cap retires it, not until the calculation window moves past it. Alerts follow the same rule.

[b]Three timeframes[/b]
Swept liquidity, market structure shifts and fair value gaps are each read on three timeframes at once — a primary higher timeframe plus a mid and a low layer, all set in one place.

Each of the three is defined once and shared, so the layers can never disagree about what they are looking at, and the higher timeframe is always served first. A level already claimed by a senior timeframe is not drawn again by a junior one, because that is the same event seen at finer resolution. A lower-timeframe read at its own level still draws — catching the move before the higher timeframe confirms it is the entire point of the layer.

[b]Swept liquidity. [/b]
A swing high or low that a later candle raids and then closes back inside. Every sweep draws identically whatever its timeframe, because a spent pool is a spent pool; the label carries the timeframe, which is the one thing the line cannot express.

[b]Market structure shifts.[/b]
A true swing broken by a body close. A true swing is a level price actually turned at: a swing low sits where a down candle gives way to an up candle, not merely at a low that happens to sit below its neighbours. The first close beyond the swing's full wick extreme marks the shift; later closes past it are continuation. The three layers rank by weight and style so the timeframe of a shift reads at a glance.

[b]Fair value gaps.[/b] 
BISI+ and SIBI- zones, gated by gap height and by the displacement that opened them. A zone moves through live, active, inverted and spent, and its border changes with each; that state advances on chart bars, so a zone is marked entered by the bar that actually enters it. Each zone starts at the exact bar whose wick formed its defining edge rather than at a timeframe boundary, so it is always clear which candle the imbalance came off. Overlapping and stacked zones are thinned against a shared budget, so the zone count on the chart is the number set rather than that number once per layer.

[b]The day[/b]
The current day's open, high, low and quadrant ladder, projected across price as a live premium and discount reference. The day boundary is either midnight New York or the symbol's own daily roll.

Beside price, the day is drawn as a projected candle — whole, or opened up into its own quarters or sixths. Split, it also draws dividers and each block's high and low back onto the chart, so the internal shape of the day reads in place as well as beside it. A countdown shows the time left on the block currently forming.

[b]Context[/b]
Previous-day levels. 
The prior day's high, low and midpoint. A level runs to the right while it is still live and stops at the wick that swept it once taken, so the line spans exactly the window in which the level mattered.

[b]SMT divergence. [/b]
Where a swept level was taken on the chart symbol but the correlated market failed to take its matching swing, the two extremes are joined. Index futures, metals and major crypto pair automatically; any symbol can be set manually. A divergence price later trades back through is marked broken rather than removed.

A four-row console reporting day bias, premium or discount, which side the last higher-timeframe sweep took, and which of the previous day's pools have already gone. Everything else draws on the chart at the price it happened, so the console does not repeat it.

Alerts on confirmed closes only, for swept liquidity and structure shifts on each of the three layers, and for the model's own sweep-and-reclaim moment. The forming candle can draw on the chart but can never fire an alert.

[b]Settings[/b]
Grouped in reading order: the model first, then the daily frame, the projected candle, the timeframe engine, then each context layer and finally presentation. Every element switches off independently, and colour, width and label size are exposed throughout.

[b]Notes[/b]
A layer whose timeframe does not sit between the chart and the primary higher timeframe is hidden rather than drawn wrongly.

SMT is unavailable in bar replay — replay rewinds the chart symbol alone, so the correlated symbol keeps returning live data and the two no longer line up. Nothing is drawn rather than something wrong. It is also silent if a paired symbol does not resolve on your data plan; set the symbol manually.

[b]Disclaimer[/b]
This is an analysis tool. It marks structure and delivery — it does not produce trade signals, entries, targets or position sizing.

This is not financial advice. Markets carry risk and past behaviour does not predict future behaviour; every decision taken using this tool is your own.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
// 2022 Model+ (M1D) — the ICT 2022 Model sequence mapped on the chart, framed by a multi-timeframe read
// of structure, liquidity and imbalance.
//
// The marker runs on chart bars: a swing pool raided by a wick, the candle closing back inside to
// confirm the sweep, then the leg displacing away from the raid extreme. Clearing the threshold draws
// the raided level, the leg and its size as one event.
//
// Three timeframes read swept liquidity, true-swing structure shifts and fair value gaps by one shared
// definition each. Higher timeframes are served first, so a level is never marked twice.
//
// The day frames it: open, extremes and quadrants across price, plus the day projected beside price as
// one candle or split into quarters or sixths, with dividers and block extremes drawn back onto the
// chart. Previous-day levels, SMT divergence, a console and confirmed-close alerts complete it.
//
// Every event is recorded once on a confirmed close and kept in a store, so the drawing layer does not
// repaint and a setup stays on the chart after the calculation window has moved past it.

//@version=6
indicator('2022 Model+ (M1D)', '2022+', overlay = true, max_lines_count = 500, max_boxes_count = 150, max_labels_count = 300)

// ── Visual standard ─────────────────────────────────────────────────────────────
// Bullish purple, bearish magenta, everything neutral black, against a white chart.
// Width carries class, style carries state: solid is live, dotted is reference or spent.
const color C_BULL = #7246CE
const color C_BEAR = #DB1D9C

const color C_INK  = #000000

const int   W_LIQ  = 2      // buyside / sellside liquidity: day extremes, PDH / PDL, swept pools
const int   W_MSS  = 2      // market structure shifts
const int   W_REF  = 1      // everything else: opens, midlines, zone borders

// Historical reach for f_extremeTime, which walks time / high / low to find the bar that printed a
// level. Sized to the oldest candle of the 12-candle snapshot: a 1H engine on a 1-minute chart reaches
// 660 bars. Deeper combinations anchor to the window start instead of the true origin bar.
const int LOOKBACK = 800
max_bars_back(time, LOOKBACK)
max_bars_back(high, LOOKBACK)
max_bars_back(low, LOOKBACK)

// ============================================================================
// INPUTS — model, daily frame, MTF engine, context layers, presentation.
// ============================================================================
string GRP_M22 = '① 2022 Model — Displacement'
bool   m22On      = input.bool(true, 'Show 2022 Markers', group = GRP_M22, tooltip = 'The model sequence on CHART bars: a swing pool is raided by a wick, the candle CLOSES back inside to confirm the sweep, and the leg that follows displaces away from the raid extreme. When the leg reaches the point threshold the marker fires: the raided level draws dotted, the leg is highlighted, and a label reports the size.')
// How big a leg has to be before it counts as displacement. The scaled default travels across symbols;
// Points is exact but only means anything on the instrument it was set for.
string m22Mode    = input.string('Points', 'Displacement Measured In', options = ['Points', 'Share of daily range'], group = GRP_M22, tooltip = 'Share of daily range scales the threshold to the symbol, so one setting travels across futures, metals and crypto. Points is a fixed distance and is exact, but only means anything on the instrument it was set for.')
float  m22DayFrac = input.float(0.33, 'Displacement (× previous day range)', minval = 0.05, maxval = 2.0, step = 0.01, group = GRP_M22, tooltip = 'Used only in Share of daily range mode. The previous completed day\'s high-to-low range times this fraction. A third of yesterday\'s range is a leg that visibly breaks the day open rather than every push inside it. Measured against the DAY, not against chart bars, so the threshold does not change when the chart timeframe does.')
float  m22Pts     = input.float(125, 'Displacement (points)', minval = 1, step = 5, group = GRP_M22, tooltip = 'Used only in Points mode. Measured from the raid extreme to the confirming close, and unaffected by the chart timeframe — 130 points is 130 points on any chart. 100-150 suits a Nasdaq micro intraday; every other instrument needs its own number.')
int    m22Swing   = input.int(3, 'Swing Strength (bars)', minval = 1, maxval = 10, group = GRP_M22, tooltip = 'Bars either side a high/low must clear to count as a swing pool. Higher = fewer, more significant pools.')
int    m22Window  = input.int(30, 'Displacement Window (bars)', minval = 1, maxval = 200, group = GRP_M22, tooltip = 'How many bars after the confirmed sweep the leg has to reach the threshold before the setup expires.')
bool   m22ShowLeg = input.bool(true, 'Highlight The Leg', group = GRP_M22, tooltip = 'A shaded box over the displacement leg, from the sweep candle to the confirming candle, spanning raid extreme to close. It carries a hard border in the direction colour so the raided level, the leg and the points label read as ONE event rather than three marks.')
color  m22BullColIn = input.color(C_BULL, 'Bullish', inline = 'm2', group = GRP_M22)
color  m22BearColIn = input.color(C_BEAR, 'Bearish', inline = 'm2', group = GRP_M22)
int    m22Keep    = input.int(6, 'Max Markers Kept', minval = 1, maxval = 30, group = GRP_M22, tooltip = 'How many fired markers stay on the chart — the oldest drop off.')

string GRP_DAY = '② Daily PO3 Range'
bool   showDay    = input.bool(true, 'Show Daily Range', group = GRP_DAY, tooltip = 'The single PO3 candle this tool keeps: the forming day\'s open, high, low and quadrants, projected across price as the live premium/discount frame.')
string daySource  = input.string('Daily Bar', 'Day Boundary', options = ['Midnight (True Day)', 'Daily Bar'], group = GRP_DAY, tooltip = 'Midnight (True Day) — midnight to midnight New York, the boundary the Midnight Open marks. Daily Bar — the symbol\'s own session open (18:00 NY on futures), so a holiday\'s shortened session still counts as its own day.')
bool   showDayQuad = input.bool(true, 'Quadrants (75% / EQ / 25%)', group = GRP_DAY, tooltip = 'The premium / discount ladder inside the day\'s range, drawn as dotted midlines. The extremes are liquidity and draw heavier; these are reference.')
color  dayColorIn  = input.color(color.new(#000000, 0), 'Colour', group = GRP_DAY)
int    dayWidth   = input.int(1, 'High / Low Line Width', minval = 1, maxval = 4, group = GRP_DAY, tooltip = 'Width of the day high and day low lines. The open and quadrant lines stay at width 1 (reference).')
bool   showDayLabels = input.bool(true, 'Labels', group = GRP_DAY)
int    dayExtend  = input.int(12, 'Extend Right (bars)', minval = 0, maxval = 50, group = GRP_DAY, tooltip = 'Runway past the live candle for the range lines and their labels. Each label family parks at a different distance so they cannot collide at the right edge.')

string GRP_CAND = '③ Daily PO3 Candle'
bool   showCand   = input.bool(true, 'Show PO3 Candle', group = GRP_CAND, tooltip = 'The forming day projected beside price — as one candle, or as its own quarters or sixths (see Day Shown As). Uses the same Day Boundary as the Daily PO3 Range, so with Midnight (True Day) this is the midnight-open day.')
// Whole day, or split into quarters or sixths. Blocks are cut from the same Day Boundary as the rest of
// the tool, so with Midnight (True Day) the first 6H block starts at the Midnight Open.
string candSplit  = input.string('Whole day', 'Day Shown As', options = ['Whole day', '4 × 6H', '6 × 4H'], group = GRP_CAND, tooltip = 'Whole day is one candle. 4 × 6H cuts the day into quarters, 6 × 4H into sixths. Blocks accumulate from chart bars against the day boundary, so the split follows the Day Boundary setting rather than a fixed clock.')
int    candOffset = input.int(15, 'Offset From Price', minval = 3, maxval = 100, group = GRP_CAND, tooltip = 'A MINIMUM, not an exact position. The candle is pushed further right automatically if the daily-range or previous-day label runways would otherwise reach into it — a level line crossing the candle body makes both unreadable. Raise this to add more air; lowering it below the runways has no effect.')
string candSize   = input.string('Medium', 'Candle Size', options = ['Small', 'Medium', 'Large'], group = GRP_CAND)
bool   candEq     = input.bool(true, 'EQ Line', group = GRP_CAND, tooltip = 'Dotted 50% (equilibrium) line across the candle body.')
// Softened black rather than pure #000000, so the projected candle reads as the same kind of object as
// the chart's own candles rather than an overlay on top of them.
color  candBullBodyIn = input.color(color.new(#ffffff, 0), 'Bull Body', inline = 'cb', group = GRP_CAND)
color  candBearBodyIn = input.color(color.new(#505050, 0), 'Bear Body', inline = 'cb', group = GRP_CAND)
color  candOutlineIn = input.color(color.new(#000000, 0), 'Outline / Wick', group = GRP_CAND)
// The split drawn back onto price. Reads the same block accumulator as the projected candles, so a
// divider always lands where the candle beside it changed.
bool   showBlkDiv   = input.bool(true, 'Block Dividers', group = GRP_CAND, tooltip = 'Vertical line at each block boundary, cut from the Day Boundary — so with Midnight (True Day) the first divider IS the Midnight Open. Only drawn when the day is split.')
// A boundary is a point in time, not a level that can be spent, so it draws solid by default.
string blkDivStyle  = input.string('Solid', 'Divider Style', options = ['Solid', 'Dotted', 'Dashed'], group = GRP_CAND, tooltip = 'Line style for the block dividers only. The block high and low lines are always solid.')
bool   showBlkHL    = input.bool(true, 'Block High / Low', group = GRP_CAND, tooltip = 'The high and low of each block drawn across that block\'s own span, so the divided range reads on the chart as well as on the projected candles. Only drawn when the day is split.')
color  blkColorIn    = input.color(color.new(#505050, 35), 'Divider / Level Colour', group = GRP_CAND)
bool   showCandTimer = input.bool(true, 'Countdown', group = GRP_CAND, tooltip = 'Time remaining on the block currently forming, or on the whole day when it is not split. Sits above the projected candles and counts live; shows --:--:-- when the market is closed and there is no tick to count against.')

string GRP_SMT = '⑦ SMT Divergence'
bool   smtOn      = input.bool(true, 'Show SMT', group = GRP_SMT, tooltip = 'Cross-market divergence on the HTF sweeps: our candle sweeps a swing high/low but the correlated peer fails to take its matching swing — the move lacked participation. NOT AVAILABLE IN BAR REPLAY: replay rewinds the chart symbol only, so the peer keeps returning live data and the two no longer line up, and no divergence is drawn rather than a wrong one. It also stays silent if the paired symbol does not resolve — set the symbol manually if you expect divergences and see none.')
string smtSymbol  = input.symbol('', 'Correlated Symbol', group = GRP_SMT, tooltip = 'Leave EMPTY to auto-pair — MNQ↔MES, MYM→MES (and NQ↔ES, YM→ES full-size), GC→SI. Set a symbol to override.')
color  smtBullColIn = input.color(C_BULL, 'Bullish', inline = 'sm', group = GRP_SMT, tooltip = 'A bullish SMT (our low swept, the peer holding its low) draws purple; a bearish SMT (our high swept, the peer holding its high) draws magenta — the same direction colours used across the tool.')
color  smtBearColIn = input.color(C_BEAR, 'Bearish', inline = 'sm', group = GRP_SMT)
bool   smtLabels  = input.bool(true, 'SMT Labels', group = GRP_SMT)
int    smtMax     = input.int(4, 'Max SMTs Shown', minval = 1, maxval = 20, group = GRP_SMT)
bool   smtHideBrk = input.bool(true, 'Remove Broken SMTs', group = GRP_SMT, tooltip = 'An SMT is broken once price trades back through the extreme that formed it. ON removes it entirely. OFF keeps it drawn dotted and dimmed.')

string GRP_HTF = '④ MTF Engine'
// Three timeframes, defined once here — the sweep, MSS and gap layers all read them.
string htfTf   = input.timeframe('60', 'HTF Timeframe', group = GRP_HTF, tooltip = 'The primary higher timeframe. Fair value gaps, SMT, and the heaviest sweep and MSS reads all come from here. Must be above the chart timeframe.')
string midTf   = input.timeframe('15', 'Mid Timeframe', group = GRP_HTF, tooltip = 'The confirmation layer. Draws sweeps and market structure shifts only — no gaps, no SMT. Hides silently unless it sits above the chart timeframe and below the HTF.')
string lowTf   = input.timeframe('5', 'Low Timeframe', group = GRP_HTF, tooltip = 'The execution layer. Same as the mid layer, one step down. On a 1m chart all three stack: HTF frame, mid confirmation, low trigger.')

string GRP_FVG = '⑤ Fair Value Gaps'
bool   showFvg       = input.bool(true, 'Show FVGs', group = GRP_FVG, tooltip = 'BISI+ (buyside imbalance) and SIBI- (sellside imbalance): a 3-candle gap — the current candle\'s extreme fails to reach the extreme from 2 candles back, and the candle between them displaced hard enough to open real space. Master switch for all three timeframe layers.')
// Gaps run the same three-timeframe stack as sweeps and shifts, off the MTF Engine timeframes.
bool   fvgMidOn      = input.bool(true, 'Mid-TF Gaps', inline = 'fvl', group = GRP_FVG)
bool   fvgLowOn      = input.bool(true, 'Low-TF Gaps', inline = 'fvl', group = GRP_FVG)
float  fvgMinAtr     = input.float(0.1, 'Min Gap Height (× avg HTF range)', minval = 0.0, step = 0.05, group = GRP_FVG)
float  fvgDispMult   = input.float(0.5, 'Min Displacement (× avg HTF range)', minval = 0.0, step = 0.1, group = GRP_FVG)
bool   showFvgLabels = input.bool(true, 'Labels', group = GRP_FVG)
color  fvgBullColorIn = input.color(color.new(C_BULL, 80), 'BISI+', inline = 'fv', group = GRP_FVG)
color  fvgBearColorIn = input.color(color.new(C_BEAR, 80), 'SIBI-', inline = 'fv', group = GRP_FVG)
color  fvgInvColorIn  = input.color(color.new(#ff5600, 80), 'Inverted', inline = 'fv', group = GRP_FVG, tooltip = 'An inversion is a THIRD state, not a direction — the zone still trades, but opposite to how it was built. It gets its own hue for that reason; the caption carries IFVG and the dashboard reports which way it now leans.')
bool   fvgInvert     = input.bool(true, 'Inversion (IFVG)', group = GRP_FVG, tooltip = 'A gap closed clean through has inverted — the old support is now resistance, or the reverse. Closing back through in the original direction takes the gap back and the zone is spent.')
int    fvgExtend     = input.int(3, 'Extend Right (bars)', minval = 0, maxval = 100, group = GRP_FVG, tooltip = 'The BASE distance a zone runs past the live candle. Each layer adds its own offset on top — the primary furthest, the low layer nearest price — so the three layers\' captions land in separate columns instead of stacking in one. Kept short because the long runway belongs to level LINES, which need parking space for their labels; a filled box gains nothing from empty chart.')
int    maxFvg        = input.int(5, 'Max Zones Shown', minval = 1, maxval = 20, group = GRP_FVG, tooltip = 'A TOTAL count of live and inverted zones across all three timeframe layers, not a per-layer allowance. The newest win and the layers are served highest timeframe first, so raising this adds lower-timeframe detail rather than more of the same.')
int    maxSpentFvg   = input.int(2, 'Max Spent Zones Shown', minval = 0, maxval = 20, group = GRP_FVG, tooltip = 'Spent zones — closed through and then reclaimed — draw from their own budget so history can never crowd out live context. Set to 0 to hide them entirely without turning off Keep Spent Gaps.')
bool   fvgHideMit    = input.bool(false, 'Remove Touched Gaps', group = GRP_FVG)
bool   fvgDeclutter  = input.bool(true, 'Declutter Overlap', group = GRP_FVG)
float  fvgOverlapPct = input.float(0, 'Overlap Tolerance (%)', minval = 0, maxval = 100, step = 5, group = GRP_FVG, tooltip = 'How much of a gap may overlap a gap already drawn before it is dropped. 0 = no overlap at all: the higher timeframe gap is kept and any gap sharing its price is not drawn.')
bool   fvgNearOn     = input.bool(true, 'Remove Stacked Zones', group = GRP_FVG)
float  fvgNearMult   = input.float(0.2, 'Stack Distance (× avg HTF range)', minval = 0.0, step = 0.05, group = GRP_FVG)
bool   fvgKeepFill   = input.bool(false, 'Keep Spent Gaps', group = GRP_FVG)
bool   fvgMergeVi    = input.bool(true, 'Absorb Volume Imbalances into Gaps', group = GRP_FVG, tooltip = 'A volume imbalance — a BODY gap the wicks still bridge — on either seam of the gap\'s displacement candle extends the zone to the VI\'s body edge. The imbalance is one region, and the wick gap alone understates it.')
bool   fvgShowSb     = input.bool(true, 'Detect Suspension Blocks', group = GRP_FVG, tooltip = 'SB+ / SB-: three same-direction HTF candles, each opening beyond the previous close, so the bodies never trade back through the leg. Drawn as one zone from the first close to the last open, labelled SB, and it takes the place of the gap on that leg. Same logic as Confluence Engine+.')
color  fvgLblColorIn  = input.color(color.rgb(27, 27, 27), 'Label Colour', group = GRP_FVG)

string GRP_SWEEP = '⑥ HTF Sweeps'
bool  showSweeps      = input.bool(true, 'Show Sweeps', group = GRP_SWEEP, tooltip = 'Swing liquidity on the HTF snapshot: a swing high or swing low that a later HTF candle raids and then CLOSES back inside.')
bool  showSweepLabels = input.bool(true, 'Sweep Labels', group = GRP_SWEEP)
color sweepColorIn     = input.color(color.new(#000000, 0), 'Colour', group = GRP_SWEEP, tooltip = 'Black: a liquidity pool is neither bullish nor bearish, so it carries no directional hue. It draws dotted, because a swept level is spent.')
int   sweepWidth      = input.int(1, 'Line Width', minval = 1, maxval = 4, group = GRP_SWEEP, tooltip = 'Width of every sweep line, the HTF sweeps, the raided levels of the model and a taken PDH or PDL.')
int   maxSweeps       = input.int(6, 'Max Sweeps Shown', minval = 1, maxval = 20, group = GRP_SWEEP, tooltip = 'Applies per layer, so each timeframe gets its own allowance and a busy HTF cannot starve the execution read.')
// Toggled separately from the MSS layers, so a timeframe can show sweeps without structure shifts.
bool  swpMidOn        = input.bool(true, 'Mid-TF Sweep Layer', group = GRP_SWEEP)
bool  swpLowOn        = input.bool(true, 'Low-TF Sweep Layer', group = GRP_SWEEP)

string GRP_MSS = '⑧ Market Structure Shift'
bool   showMss     = input.bool(true, 'Show MSS', group = GRP_MSS, tooltip = 'A TRUE swing broken by a body close on the HTF snapshot. The FIRST candle to CLOSE beyond the swing\'s full wick extreme marks the shift; later closes past the same level are continuation.')
color  mssBullColIn = input.color(C_BULL, 'Bullish', inline = 'ms', group = GRP_MSS)
color  mssBearColIn = input.color(C_BEAR, 'Bearish', inline = 'ms', group = GRP_MSS)
bool   mssLabels   = input.bool(true, 'MSS Labels', group = GRP_MSS)
// MSS carries its own text size — a shift is a headline event, so it reads a step larger.
string mssLblSize  = input.string('small', 'MSS Label Size', options = ['tiny', 'small', 'normal', 'large'], group = GRP_MSS, tooltip = 'Text size for the MSS labels only. Every other label follows the size under Labels.')
int    mssMax      = input.int(2, 'Max MSS Shown', minval = 1, maxval = 20, group = GRP_MSS)
// Minimum separation between two shifts on the same layer. A candidate inside this distance is skipped
// and the scan keeps walking back. Scaled to the layer's own candle range.
float  mssSepMult  = input.float(1.0, 'Min MSS Separation (× avg range)', minval = 0.0, step = 0.1, group = GRP_MSS, tooltip = 'How far apart two structure shifts on the same layer must be before both are drawn, as a multiple of that timeframe\'s average candle range. 0 disables the check and draws every shift found. Raise it if the shifts still read as one cluster.')
// Lower-timeframe MSS layers — the same true-swing engine, each on its own snapshot. A layer draws only
// while its timeframe sits above the chart timeframe and below the MTF Engine timeframe.
bool   mssMidOn    = input.bool(true, 'Mid-TF MSS Layer', group = GRP_MSS, tooltip = 'A second MSS read at the Mid Timeframe (set under MTF Engine). Solid, width 1 — same style as the HTF shift but lighter, because it is the same kind of event one rank down.')
int    mssMidMax   = input.int(2, 'Max Mid MSS Shown', minval = 1, maxval = 20, group = GRP_MSS)
bool   mssLowOn    = input.bool(true, 'Low-TF MSS Layer', group = GRP_MSS, tooltip = 'A third MSS read at the Low Timeframe. Dashed, width 1 — the only layer that changes style, so the execution shift is never mistaken for the two above it.')
int    mssLowMax   = input.int(2, 'Max Low MSS Shown', minval = 1, maxval = 20, group = GRP_MSS)

string GRP_PD = '⑨ Previous-Day Levels'
bool   showPD       = input.bool(true, 'Show PDH / PDL', group = GRP_PD, tooltip = 'The previous completed day\'s high and low, using the same day boundary as the Daily PO3 Range. Solid while unswept; dotted + dimmed the instant price trades through it today.')
bool   showPdEq     = input.bool(true, 'Show PD EQ', group = GRP_PD)
bool   showPdLabels = input.bool(true, 'Labels', group = GRP_PD)
color  pdColorIn     = input.color(color.new(#000000, 0), 'Colour', group = GRP_PD)
int    pdExtend     = input.int(22, 'Extend Right (bars)', minval = 0, maxval = 100, group = GRP_PD, tooltip = 'Deliberately longer than the daily range runway so the two label families park at different distances and never overlap.')

string GRP_LBL = '⑩ Labels'
string labelSize = input.string('small', 'Label Text Size', options = ['tiny', 'small', 'normal', 'large'], group = GRP_LBL, tooltip = 'One size for every label this tool draws. The dashboard has its own size under Dashboard.')
string chartTheme = input.string('Light', 'Chart theme', options = ['Light', 'Dark'], group = GRP_LBL, tooltip = 'Dark lightens every colour the script draws on the chart - gaps, the displacement leg, sweeps, structure shifts, SMT, the daily range, the PO3 candle and its dividers, and every label - so they read on a dark background. The colours you set are kept and lifted, not replaced. The dashboard ink follows the theme.')

//@function Resolves the label size input to a size constant.
//@returns  (string) The size constant.
f_lblSize(string s) =>
    switch s
        'tiny'   => size.tiny
        'normal' => size.normal
        'large'  => size.large
        =>          size.small
string LBL_SZ = f_lblSize(labelSize)
// Structure-shift text, one input of its own — see the MSS group.
string MSS_SZ = f_lblSize(mssLblSize)
// Block divider style, resolved once — see the PO3 Candle group.
string BLK_DIV_STY = blkDivStyle == 'Dotted' ? line.style_dotted : blkDivStyle == 'Dashed' ? line.style_dashed : line.style_solid
// ============================================================================
// CHART THEME — Light draws every colour exactly as set. Dark lifts each one toward white so it reads
// on a black background; black and near-black ink becomes light ink, the dashboard included.
// ============================================================================
bool isDark = chartTheme == 'Dark'

//@function A colour lifted toward white on the Dark theme, unchanged on Light.
//@param c (color) The colour as set.
//@param tDrop (int) Transparency points removed on Dark, so fills hold up on a dark background.
//@returns (color) The colour to draw with.
f_lift(color c, int tDrop) =>
    float t = color.t(c)
    isDark ? color.rgb(color.r(c) + (255 - color.r(c)) * 0.45, color.g(c) + (255 - color.g(c)) * 0.45, color.b(c) + (255 - color.b(c)) * 0.45, math.max(t - tDrop, 0)) : c

//@function A line or text colour for the theme: black and near-black become light ink on Dark, anything else is lifted.
//@param c (color) The colour as set.
//@returns (color) The colour to draw with.
f_ink(color c) =>
    isDark and color.r(c) < 40 and color.g(c) < 40 and color.b(c) < 40 ? color.new(#E6E6EF, color.t(c)) : f_lift(c, 0)

color INK = isDark ? #E6E6EF : C_INK
color MID = isDark ? #A3A6B0 : color.gray

color m22BullCol   = f_lift(m22BullColIn, 0)
color m22BearCol   = f_lift(m22BearColIn, 0)
color dayColor     = f_ink(dayColorIn)
color candBullBody = f_lift(candBullBodyIn, 0)
color candBearBody = f_lift(candBearBodyIn, 0)
color candOutline  = f_ink(candOutlineIn)
color blkColor     = f_ink(blkColorIn)
color smtBullCol   = f_lift(smtBullColIn, 0)
color smtBearCol   = f_lift(smtBearColIn, 0)
color fvgBullColor = f_lift(fvgBullColorIn, 10)
color fvgBearColor = f_lift(fvgBearColorIn, 10)
color fvgInvColor  = f_lift(fvgInvColorIn, 10)
color fvgLblColor  = f_ink(fvgLblColorIn)
color sweepColor   = f_ink(sweepColorIn)
color mssBullCol   = f_lift(mssBullColIn, 0)
color mssBearCol   = f_lift(mssBearColIn, 0)
color pdColor      = f_ink(pdColorIn)

string GRP_DASH = '⑪ Dashboard'
bool   showDash = input.bool(true, 'Show Dashboard', group = GRP_DASH)
string dashPos  = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = GRP_DASH)
string dashSize = input.string(size.small, 'Text Size', options = [size.tiny, size.small, size.normal, size.large], group = GRP_DASH)

string GRP_ALERT = '⑫ Alerts'
// No new detection — these expose alert() calls on conditions the model already computes. Turning a
// layer's display off silences its alert too.
bool alertSweepOn = input.bool(true, 'Liquidity Sweep Alerts', group = GRP_ALERT, tooltip = 'Fires when a swing pool on the HTF, Mid or Low sweep layer is raided by a wick and the candle CLOSES back inside — the confirmed candle only, the forming one can never fire this. Respects each layer\'s own Show Sweeps toggle.')
bool alertMssOn   = input.bool(true, 'MSS Alerts', group = GRP_ALERT, tooltip = 'Fires when a true swing on the HTF, Mid or Low MSS layer is broken by a CLOSED candle\'s body — the forming candle can still draw a shift on the chart, but can never confirm this alert. Respects each layer\'s own Show MSS toggle.')

//@function Builds the M1D alerts-relay JSON payload from the script's own runtime values.
//          TradingView's {{ticker}}/{{interval}}/{{close}}/{{time}} placeholders only substitute
//          inside alertcondition()'s message argument — inside a dynamic alert() call they ship as
//          the literal eight characters, which is what reached Telegram before this fix.
//@param eventName (string) the event slug, e.g. "sweep_bsl_bear_H4"
//@returns (string) the JSON payload
f_alertJson(string eventName) =>
    '{"event":"' + eventName + '","symbol":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","price":"' + str.tostring(close, format.mintick) + '","time":"' + str.tostring(time) + '","note":"Analysis alert — not a trade signal"}'

// ============================================================================
// VALIDITY
// ============================================================================
bool htfValid = timeframe.in_seconds(htfTf) > timeframe.in_seconds(timeframe.period)
// A lower layer is valid only above the chart timeframe and below the MTF Engine timeframe.
// Invalid = hidden, no warning.
bool midValid = timeframe.in_seconds(midTf) > timeframe.in_seconds(timeframe.period) and timeframe.in_seconds(midTf) < timeframe.in_seconds(htfTf)
bool lowValid = timeframe.in_seconds(lowTf) > timeframe.in_seconds(timeframe.period) and timeframe.in_seconds(lowTf) < timeframe.in_seconds(htfTf)
// A layer that is not valid draws NOTHING — but request.security is global and spends its buffers
// regardless, so an invalid layer costs full memory for output that is thrown away. On a daily chart
// the 60 / 15 / 5 defaults all sit below the chart timeframe: three sub-daily contexts are requested
// across the whole daily history, 145 series deep, and the script throws "Memory limits exceeded"
// before it draws a thing. Ask the chart's own timeframe instead when a layer is invalid — one bar per
// chart bar, and the same discarded output. A VALID layer resolves to its own timeframe unchanged, so
// nothing about what is drawn moves.
// simple-qualified on purpose: request.security takes a simple timeframe, and a series string will not
// compile (RULE 18).
simple string htfReq = timeframe.in_seconds(htfTf) > timeframe.in_seconds(timeframe.period) ? htfTf : timeframe.period
simple string midReq = timeframe.in_seconds(midTf) > timeframe.in_seconds(timeframe.period) and timeframe.in_seconds(midTf) < timeframe.in_seconds(htfTf) ? midTf : timeframe.period
simple string lowReq = timeframe.in_seconds(lowTf) > timeframe.in_seconds(timeframe.period) and timeframe.in_seconds(lowTf) < timeframe.in_seconds(htfTf) ? lowTf : timeframe.period

// ============================================================================
// HTF SNAPSHOT — one security call. Index 0 is the live/forming candle, accumulated from chart bars;
// indices 1-11 are confirmed closed candles, pinned with lookahead_on.
//
// Twelve candles. Every offset in the tuple is another requested series, and request.security is the
// dominant memory cost here — a deeper snapshot throws "Memory limits exceeded". Keep the SMT peer
// snapshot at this same depth: it is read at indices taken from this array.
// ============================================================================
bool newHtfBar = timeframe.change(htfTf)
var float o0 = na
var float h0 = na
var float l0 = na
var float c0 = na
var int   t0 = na
if newHtfBar or na(o0)
    o0 := open
    h0 := high
    l0 := low
    c0 := close
    t0 := time(htfTf)
else
    h0 := math.max(h0, high)
    l0 := math.min(l0, low)
    c0 := close

[o1,h1,l1,c1,t1, o2,h2,l2,c2,t2, o3,h3,l3,c3,t3, o4,h4,l4,c4,t4, o5,h5,l5,c5,t5,
 o6,h6,l6,c6,t6, o7,h7,l7,c7,t7, o8,h8,l8,c8,t8, o9,h9,l9,c9,t9, o10,h10,l10,c10,t10,
 o11,h11,l11,c11,t11] =
     request.security(syminfo.tickerid, htfReq,
     [open[1],high[1],low[1],close[1],time[1], open[2],high[2],low[2],close[2],time[2], open[3],high[3],low[3],close[3],time[3], open[4],high[4],low[4],close[4],time[4], open[5],high[5],low[5],close[5],time[5],
      open[6],high[6],low[6],close[6],time[6], open[7],high[7],low[7],close[7],time[7], open[8],high[8],low[8],close[8],time[8], open[9],high[9],low[9],close[9],time[9], open[10],high[10],low[10],close[10],time[10],
      open[11],high[11],low[11],close[11],time[11]],
      lookahead = barmerge.lookahead_on)

// ============================================================================
// MID / LOW SNAPSHOTS — same shape as the HTF snapshot: index 0 is the live/forming candle accumulated
// from chart bars, indices 1-9 are confirmed closed candles pinned with lookahead_on.
//
// Ten candles — as deep as these layers' own caps can consume. request.security load is fixed at
// compile time, so switching a layer off in the settings hides its drawings but recovers no memory.
// ============================================================================
bool newMidBar = timeframe.change(midTf)
var float mdO0 = na
var float mdH0 = na
var float mdL0 = na
var float mdC0 = na
var int   mdT0 = na
if newMidBar or na(mdO0)
    mdO0 := open
    mdH0 := high
    mdL0 := low
    mdC0 := close
    mdT0 := time(midTf)
else
    mdH0 := math.max(mdH0, high)
    mdL0 := math.min(mdL0, low)
    mdC0 := close

[mdO1,mdH1,mdL1,mdC1,mdT1, mdO2,mdH2,mdL2,mdC2,mdT2, mdO3,mdH3,mdL3,mdC3,mdT3, mdO4,mdH4,mdL4,mdC4,mdT4, mdO5,mdH5,mdL5,mdC5,mdT5, mdO6,mdH6,mdL6,mdC6,mdT6, mdO7,mdH7,mdL7,mdC7,mdT7, mdO8,mdH8,mdL8,mdC8,mdT8, mdO9,mdH9,mdL9,mdC9,mdT9] =
     request.security(syminfo.tickerid, midReq,
     [open[1],high[1],low[1],close[1],time[1], open[2],high[2],low[2],close[2],time[2], open[3],high[3],low[3],close[3],time[3], open[4],high[4],low[4],close[4],time[4], open[5],high[5],low[5],close[5],time[5], open[6],high[6],low[6],close[6],time[6], open[7],high[7],low[7],close[7],time[7], open[8],high[8],low[8],close[8],time[8], open[9],high[9],low[9],close[9],time[9]],
      lookahead = barmerge.lookahead_on)

bool newLowBar = timeframe.change(lowTf)
var float lwO0 = na
var float lwH0 = na
var float lwL0 = na
var float lwC0 = na
var int   lwT0 = na
if newLowBar or na(lwO0)
    lwO0 := open
    lwH0 := high
    lwL0 := low
    lwC0 := close
    lwT0 := time(lowTf)
else
    lwH0 := math.max(lwH0, high)
    lwL0 := math.min(lwL0, low)
    lwC0 := close

[lwO1,lwH1,lwL1,lwC1,lwT1, lwO2,lwH2,lwL2,lwC2,lwT2, lwO3,lwH3,lwL3,lwC3,lwT3, lwO4,lwH4,lwL4,lwC4,lwT4, lwO5,lwH5,lwL5,lwC5,lwT5, lwO6,lwH6,lwL6,lwC6,lwT6, lwO7,lwH7,lwL7,lwC7,lwT7, lwO8,lwH8,lwL8,lwC8,lwT8, lwO9,lwH9,lwL9,lwC9,lwT9] =
     request.security(syminfo.tickerid, lowReq,
     [open[1],high[1],low[1],close[1],time[1], open[2],high[2],low[2],close[2],time[2], open[3],high[3],low[3],close[3],time[3], open[4],high[4],low[4],close[4],time[4], open[5],high[5],low[5],close[5],time[5], open[6],high[6],low[6],close[6],time[6], open[7],high[7],low[7],close[7],time[7], open[8],high[8],low[8],close[8],time[8], open[9],high[9],low[9],close[9],time[9]],
      lookahead = barmerge.lookahead_on)

// ============================================================================
// HELPERS
// ============================================================================
// NOT gated on barstate.isrealtime — that gate is what held the countdown at '--:--:--'. The label is
// only ever built on the last bar, and that bar stays HISTORICAL until a fresh tick arrives after the
// script loads, so a delayed feed or a quiet period never cleared it. `timenow` is the wall clock and is
// valid on any bar, so the boundary is the only input that matters.
//@function HH:MM:SS remaining until `closeMs`, measured against `timenow`.
//@param closeMs (int) Boundary the countdown runs to.
//@returns (string) The remaining time, or '--:--:--' past the boundary or with none known.
f_countdown(int closeMs) =>
    string result = '--:--:--'
    if not na(closeMs)
        int remaining = math.round((closeMs - timenow) / 1000)
        if remaining > 0
            int hrs  = math.floor(remaining / 3600)
            int mins = math.floor((remaining % 3600) / 60)
            int secs = remaining % 60
            result := str.tostring(hrs, '00') + ':' + str.tostring(mins, '00') + ':' + str.tostring(secs, '00')
    result

//@function Short TF tag for labels, e.g. '15m', '90m', '1H', '1D'.
f_tfLabel(string tf) =>
    int s = timeframe.in_seconds(tf)
    s < 60 ? str.tostring(s) + 's' : s < 86400 ? (s % 3600 == 0 ? str.tostring(s / 3600) + 'H' : str.tostring(math.round(s / 60.0)) + 'm') : s % 604800 == 0 ? str.tostring(s / 604800) + 'W' : s % 86400 == 0 ? str.tostring(s / 86400) + 'D' : tf

//@function Exact chart-bar time inside [winStart, winEnd) whose high/low equals `level`, so a raided-level
//          line anchors to the bar that actually formed it rather than the candle's open (origin-anchoring).
f_extremeTime(bool isHigh, float level, int winStart, int winEnd) =>
    int found = winStart
    int lo = 0
    int hi = LOOKBACK - 1
    while lo < hi
        int mid = int((lo + hi) / 2)
        int tm  = time[mid]
        if na(tm) or tm < winEnd
            hi := mid
        else
            lo := mid + 1
    for k = lo to LOOKBACK - 1
        int kt = time[k]
        if na(kt) or kt < winStart
            break
        if (isHigh and high[k] == level) or (not isHigh and low[k] == level)
            found := kt
            break
    found

//@function Whether the candle at `idx` completes a TRUE swing on the HTF arrays: a swing LOW sits at the
//          turn from a DOWN candle to an UP candle, a swing HIGH at the turn from an UP candle to a DOWN one.
//@returns  (bool) True when idx is a swing of the requested type.
f_isSwing(array<float> sO, array<float> sH, array<float> sL, array<float> sC, int idx, bool wantLow) =>
    bool ok = false
    if idx >= 1 and idx + 1 <= sL.size() - 1
        float lv  = wantLow ? sL.get(idx) : sH.get(idx)
        bool  geo = wantLow ? (lv < sL.get(idx - 1) and lv < sL.get(idx + 1)) : (lv > sH.get(idx - 1) and lv > sH.get(idx + 1))
        if geo
            bool up    = sC.get(idx)     > sO.get(idx)
            bool dn    = sC.get(idx)     < sO.get(idx)
            bool upOld = sC.get(idx + 1) > sO.get(idx + 1)
            bool dnOld = sC.get(idx + 1) < sO.get(idx + 1)
            bool upNew = sC.get(idx - 1) > sO.get(idx - 1)
            bool dnNew = sC.get(idx - 1) < sO.get(idx - 1)
            ok := wantLow ? ((up and dnOld) or (dn and upNew)) : ((dn and upOld) or (up and dnNew))
    ok

//@function The nearest still-unraided swing that candle `i` raids and CLOSES back inside — a wick beyond
//          the level with the body back within. Nothing between the swing and the raiding candle may
//          have taken the level already. Shared by the sweep and SMT recorders.
//@param i        (int)  Index of the candidate raiding candle.
//@param num      (int)  Snapshot size.
//@param wantHigh (bool) true = look for a swing HIGH above, false = a swing LOW below.
//@returns (int) Index of the swept swing, or na.
f_sweptIdx(array<float> aH, array<float> aL, array<float> aC, int i, int num, bool wantHigh) =>
    int found = na
    float hi = aH.get(i)
    float li = aL.get(i)
    float ci = aC.get(i)
    if i + 2 <= num - 2 and not na(hi) and not na(li) and not na(ci)
        for p = i + 2 to num - 2
            if not na(found)
                break
            float hp = aH.get(p)
            float lp = aL.get(p)
            bool  isSwing = wantHigh ? (not na(hp) and hp > aH.get(p - 1) and hp > aH.get(p + 1) and hi > hp and ci < hp) : (not na(lp) and lp < aL.get(p - 1) and lp < aL.get(p + 1) and li < lp and ci > lp)
            if isSwing
                bool first = true
                for m = i + 1 to p - 1
                    if wantHigh ? aH.get(m) > hp : aL.get(m) < lp
                        first := false
                        break
                if first
                    found := p
    found

//@function Auto-pairs the SMT peer from the chart symbol.
//@returns  (string) The paired symbol, or na when the symbol has no known pairing.
f_smtAutoPeer() =>
    // Equity indices, precious metals and BTC/ETH. Micros pair to micros, never across contract sizes.
    string t = syminfo.ticker
    string res = na
    string m = str.match(t, "^M?(ES|NQ)[1\\w][!\\d]+$")
    if m != ''
        int off = str.startswith(m, 'M') ? 1 : 0
        string prefix = str.substring(m, off, 2 + off)
        string suffix = str.substring(m, 2 + off)
        res := 'CME_MINI:' + (off == 1 ? 'M' : '') + (prefix == 'NQ' ? 'ES' : 'NQ') + suffix
    else if str.contains(t, 'MYM')
        res := 'CME_MINI:MES1!'
    else if str.contains(t, 'YM')
        res := 'CME_MINI:ES1!'
    else if str.contains(t, 'M2K')
        res := 'CME_MINI:MES1!'
    else if str.contains(t, 'RTY')
        res := 'CME_MINI:ES1!'
    // Metals take the chart's own prefix — full-size contracts are on COMEX, micros on COMEX_MINI, and a
    // hardcoded exchange resolves to a non-existent symbol. Order matters: MGC contains GC, SIL contains SI.
    else if str.contains(t, 'MGC')
        res := syminfo.prefix + ':SIL1!'
    else if str.contains(t, 'GC')
        res := syminfo.prefix + ':SI1!'
    else if str.contains(t, 'SIL')
        res := syminfo.prefix + ':MGC1!'
    else if str.contains(t, 'SI')
        res := syminfo.prefix + ':GC1!'
    else if str.contains(t, 'MBT')
        res := 'CME:MET1!'
    else if str.contains(t, 'MET')
        res := 'CME:MBT1!'
    else if str.startswith(t, 'BTC')
        res := syminfo.prefix + ':' + str.replace(t, 'BTC', 'ETH', 0)
    else if str.startswith(t, 'ETH')
        res := syminfo.prefix + ':' + str.replace(t, 'ETH', 'BTC', 0)
    res

// ============================================================================
// SMT PEER SNAPSHOT — the second security, on the SAME HTF grid as the main snapshot, so peer candle i
// lines up with chart candle i and the two can be compared index-for-index with no time matching.
// ============================================================================
var string smtAuto = f_smtAutoPeer()
var string smtPeer = smtSymbol != '' ? smtSymbol : (not na(smtAuto) ? smtAuto : syminfo.tickerid)
var array<string> smtParts = str.split(smtPeer, ':')
string smtName = smtParts.size() > 0 ? smtParts.get(smtParts.size() - 1) : smtPeer

// Peer's forming HTF candle — no lookahead, current bar only. The open time comes back with it: the
// index-for-index comparison holds only while both symbols start their HTF candles at the same moment.
// ignore_invalid_symbol so an unresolved pairing returns na instead of throwing — na peer data simply
// never passes the comparison, costing the divergence rather than the whole indicator.
[ph0, pl0, pt0] = request.security(smtPeer, htfReq, [high, low, time], ignore_invalid_symbol = true)
// Peer's confirmed closed HTF candles, pinned with lookahead_on to match the main snapshot.
[ph1,pl1, ph2,pl2, ph3,pl3, ph4,pl4, ph5,pl5, ph6,pl6, ph7,pl7, ph8,pl8, ph9,pl9, ph10,pl10,
 ph11,pl11] =
     request.security(smtPeer, htfReq,
     [high[1],low[1], high[2],low[2], high[3],low[3], high[4],low[4], high[5],low[5], high[6],low[6], high[7],low[7], high[8],low[8], high[9],low[9], high[10],low[10],
      high[11],low[11]],
      lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

// ============================================================================
// DAILY PO3 RANGE — the forming day's open, extremes and quadrants.
// The boundary is midnight New York (True Day) or the symbol's own daily roll. The range accumulates on
// every bar and hands the previous day's values over on the roll, which is what feeds PDH / PDL.
// ============================================================================
int  nyDay        = dayofmonth(time, 'America/New_York')
bool midnightRoll = not na(nyDay[1]) and nyDay != nyDay[1]
bool useMidnight  = daySource == 'Midnight (True Day)'
// Daily Bar mode rolls on the symbol's own SESSION open, not on the daily bar. TradingView folds a
// holiday's shortened session into the next trading day's daily bar (Labor Day 2026: Sun 18:00 to Tue
// 17:00 NY as one bar), so a roll keyed on that bar skipped Monday evening, the day ran 47 hours and the
// last block of a split day swallowed all of Tuesday. session.isfirstbar fires at every session open.
bool dayRoll      = useMidnight ? midnightRoll : session.isfirstbar

var float dayOpen  = na
var float dayHi    = na
var float dayLo    = na
var int   dayT     = na
var int   dayHiT   = na
var int   dayLoT   = na
var float pdH      = na
var float pdL      = na
var int   pdT      = na
var int   pdHT     = na
var int   pdLT     = na
if dayRoll
    pdH     := dayHi
    pdL     := dayLo
    pdT     := dayT
    pdHT    := dayHiT
    pdLT    := dayLoT
    dayOpen := open
    dayHi   := high
    dayLo   := low
    dayT    := time
    dayHiT  := time
    dayLoT  := time
else
    // Seeded on first touch so a chart beginning mid-day does not feed na into the running extreme.
    if na(dayOpen)
        dayOpen := open
    if na(dayHi) or high > dayHi
        dayHi  := high
        dayHiT := time
    if na(dayLo) or low < dayLo
        dayLo  := low
        dayLoT := time
    dayT := na(dayT) ? time : dayT

float pdEq = not na(pdH) and not na(pdL) ? (pdH + pdL) / 2.0 : na

// The day's TRUE close, which is what the countdown counts to. dayT is the day's first BAR, not the
// boundary, so dayT + 24h overshoots by an hour on a futures day that runs 23. In Daily Bar mode the
// symbol's own daily close is the exact answer, and time_close() is a built-in — no security call.
// Clipped to 24h past the open: on a merged holiday bar time_close('D') is the NEXT day's close.
int dayCloseMs = useMidnight ? dayT + 86400000 : math.min(nz(time_close('D'), dayT + 86400000), dayT + 86400000)

// ── The day's internal blocks ──────────────────────────────────────────────────────────────────────
// Quarters (4 × 6H) or sixths (6 × 4H) of the same day, accumulated from chart bars rather than pulled
// as a fourth security call — a 6H request would roll on the exchange's boundary, not this tool's.
//
// A bar's block is its distance from the day open divided by the block length, so the split follows the
// Day Boundary setting. The last block absorbs the overhang of a 23-hour futures day.
int BLK_MAX = 6
var array<float> blkO = array.new<float>(BLK_MAX, na)
var array<float> blkH = array.new<float>(BLK_MAX, na)
var array<float> blkL = array.new<float>(BLK_MAX, na)
var array<float> blkC = array.new<float>(BLK_MAX, na)

int blkCount = candSplit == '4 × 6H' ? 4 : candSplit == '6 × 4H' ? 6 : 1
int blkMs    = candSplit == '4 × 6H' ? 21600000 : candSplit == '6 × 4H' ? 14400000 : 86400000

if dayRoll
    for b = 0 to BLK_MAX - 1
        blkO.set(b, na)
        blkH.set(b, na)
        blkL.set(b, na)
        blkC.set(b, na)
// Runs after the day accumulator above, so dayT is already this day's open on the roll bar itself.
if blkCount > 1 and not na(dayT)
    int bi = math.min(blkCount - 1, math.max(0, int((time - dayT) / blkMs)))
    if na(blkO.get(bi))
        blkO.set(bi, open)
        blkH.set(bi, high)
        blkL.set(bi, low)
    else
        blkH.set(bi, math.max(blkH.get(bi), high))
        blkL.set(bi, math.min(blkL.get(bi), low))
    blkC.set(bi, close)

// Sweep state for the previous-day levels, reset on the roll. The sweep time is captured on the first
// bar whose wick reaches the level and never updated — a later revisit is price trading through an
// already-spent level, not a second sweep.
var bool pdHSwept  = false
var bool pdLSwept  = false
var int  pdHSweptT = na
var int  pdLSweptT = na
if dayRoll
    pdHSwept  := false
    pdLSwept  := false
    pdHSweptT := na
    pdLSweptT := na
if not na(pdH) and high >= pdH and not pdHSwept
    pdHSwept  := true
    pdHSweptT := time
if not na(pdL) and low <= pdL and not pdLSwept
    pdLSwept  := true
    pdLSweptT := time

// ============================================================================
// 2022 MODEL DISPLACEMENT — chart-timeframe engine.
// Swing pools come from chart pivots. A pool is raided when a candle wicks beyond it; the sweep is
// confirmed when that candle closes back inside, which arms a pending leg. From the raid extreme the
// market has `m22Window` bars to displace by the threshold in the reversal direction, and the marker
// fires. A close back beyond the raided level cancels the setup; a deeper wick extends the raid extreme
// and the displacement re-measures from there.
// ============================================================================
var array<float> poolHi  = array.new<float>()
var array<int>   poolHiT = array.new<int>()
var array<float> poolLo  = array.new<float>()
var array<int>   poolLoT = array.new<int>()
int MAX_POOLS = 30

// One pending setup per side — a fresh confirmed sweep replaces the old one.
var bool  pendBearOn  = false
var float pendBearLvl = na
var float pendBearExt = na
var int   pendBearLvlT = na
var int   pendBearSwT  = na
var int   pendBearAge  = 0
var bool  pendBullOn  = false
var float pendBullLvl = na
var float pendBullExt = na
var int   pendBullLvlT = na
var int   pendBullSwT  = na
var int   pendBullAge  = 0

var array<line>  m22Lines = array.new<line>()
var array<label> m22Labs  = array.new<label>()
var array<box>   m22Boxes = array.new<box>()

//@function Prunes the oldest 2022 marker set once the keep cap is exceeded. Each fired marker is one
//          line + one label + one box slot, so the three stores prune in step.
f_pruneM22() =>
    while m22Lines.size() > m22Keep
        line.delete(m22Lines.shift())
    while m22Labs.size() > m22Keep
        label.delete(m22Labs.shift())
    while m22Boxes.size() > m22Keep
        box.delete(m22Boxes.shift())
    true

bool fire22Bull = false
bool fire22Bear = false
var string last22 = '-'

// The pivot calls must stay at GLOBAL scope (CW10003). ta.pivothigh / ta.pivotlow reference their own
// past values, so they need one execution per calculation to build a consistent history — inside a
// conditional, the "m22Swing bars back" they measure from becomes whichever bar the call last ran on.
// The pools are still only pushed on a confirmed close, gated below.
float ph = ta.pivothigh(high, m22Swing, m22Swing)
float pl = ta.pivotlow(low, m22Swing, m22Swing)
// One resolved threshold, so the firing test reads the same in either mode.
//
// The scaled mode measures against the previous day's range, not chart-bar ATR: a displacement leg is a
// fixed distance in price, while an ATR multiple would demand roughly six times the travel on 5m as on
// 1m. Falls back to the point value before a previous day exists.
float pdRange   = not na(pdH) and not na(pdL) and pdH > pdL ? pdH - pdL : na
float m22Thresh = m22Mode == 'Points' ? m22Pts : (not na(pdRange) ? pdRange * m22DayFrac : m22Pts)

if barstate.isconfirmed
    // ── Age / cancel / fire the pending legs first, on this bar's confirmed close ──
    if pendBearOn
        pendBearAge += 1
        if close > pendBearLvl
            // Closed back above the raided level — the raid held, no reversal. Setup cancelled.
            pendBearOn := false
        else
            if high > pendBearExt
                pendBearExt := high
            if pendBearExt - close >= m22Thresh
                fire22Bear := true
                int ptsBear = math.round(pendBearExt - close)
                if m22On
                    // Three marks, one event, connecting left to right: the raided pool runs from where it
                    // formed to the sweep candle, the leg box picks up at that candle, the label sits at
                    // the far end.
                    m22Lines.push(line.new(pendBearLvlT, pendBearLvl, pendBearSwT, pendBearLvl, xloc = xloc.bar_time, color = INK, width = sweepWidth, style = line.style_dotted))
                    if m22ShowLeg
                        m22Boxes.push(box.new(pendBearSwT, pendBearExt, time, close, xloc = xloc.bar_time, border_color = color.new(m22BearCol, 0), border_width = W_REF, border_style = line.style_solid, bgcolor = color.new(m22BearCol, 90)))
                    // Displacement down — the label anchors on the box's top edge (the raid extreme), which
                    // is clear of both the shading and the candles. Text black and bold; the box carries
                    // the direction.
                    label m22bl = label.new(time, pendBearExt, '▼ ' + str.tostring(ptsBear) + 'pt', xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.white, 100), textcolor = INK, size = LBL_SZ, text_formatting = text.format_bold)
                    label.set_text_font_family(m22bl, font.family_monospace)
                    m22Labs.push(m22bl)
                    f_pruneM22()
                last22 := 'Bear ' + str.tostring(ptsBear) + 'pt'
                pendBearOn := false
            else if pendBearAge > m22Window
                pendBearOn := false
    if pendBullOn
        pendBullAge += 1
        if close < pendBullLvl
            pendBullOn := false
        else
            if low < pendBullExt
                pendBullExt := low
            if close - pendBullExt >= m22Thresh
                fire22Bull := true
                int ptsBull = math.round(close - pendBullExt)
                if m22On
                    m22Lines.push(line.new(pendBullLvlT, pendBullLvl, pendBullSwT, pendBullLvl, xloc = xloc.bar_time, color = INK, width = sweepWidth, style = line.style_dotted))
                    if m22ShowLeg
                        m22Boxes.push(box.new(pendBullSwT, close, time, pendBullExt, xloc = xloc.bar_time, border_color = color.new(m22BullCol, 0), border_width = W_REF, border_style = line.style_solid, bgcolor = color.new(m22BullCol, 90)))
                    // Displacement up — the mirror: below the box's bottom edge.
                    label m22ul = label.new(time, pendBullExt, '▲ ' + str.tostring(ptsBull) + 'pt', xloc = xloc.bar_time, style = label.style_label_up, color = color.new(color.white, 100), textcolor = INK, size = LBL_SZ, text_formatting = text.format_bold)
                    label.set_text_font_family(m22ul, font.family_monospace)
                    m22Labs.push(m22ul)
                    f_pruneM22()
                last22 := 'Bull ' + str.tostring(ptsBull) + 'pt'
                pendBullOn := false
            else if pendBullAge > m22Window
                pendBullOn := false

    // ── Collect new swing pools (confirmed pivots) ──
    if not na(ph)
        poolHi.push(ph)
        poolHiT.push(time[m22Swing])
        while poolHi.size() > MAX_POOLS
            poolHi.shift()
            poolHiT.shift()
    if not na(pl)
        poolLo.push(pl)
        poolLoT.push(time[m22Swing])
        while poolLo.size() > MAX_POOLS
            poolLo.shift()
            poolLoT.shift()

    // ── Sweep detection against the pools ──
    // A wick beyond the pool with a close back inside arms the pending leg; a body close through it
    // spends the level without arming anything. Either way the pool is removed — the liquidity is taken.
    // Iterated backwards so removals cannot drift the index.
    int hiSz = poolHi.size()
    if hiSz > 0
        for i = hiSz - 1 to 0
            float lvl = poolHi.get(i)
            if high > lvl
                if close < lvl
                    // Confirmed buyside sweep — arms (or refreshes) the bearish setup.
                    pendBearOn   := true
                    pendBearLvl  := lvl
                    pendBearExt  := high
                    pendBearLvlT := poolHiT.get(i)
                    pendBearSwT  := time
                    pendBearAge  := 0
                poolHi.remove(i)
                poolHiT.remove(i)
    int loSz = poolLo.size()
    if loSz > 0
        for i = loSz - 1 to 0
            float lvl = poolLo.get(i)
            if low < lvl
                if close > lvl
                    // Confirmed sellside sweep — arms (or refreshes) the bullish setup.
                    pendBullOn   := true
                    pendBullLvl  := lvl
                    pendBullExt  := low
                    pendBullLvlT := poolLoT.get(i)
                    pendBullSwT  := time
                    pendBullAge  := 0
                poolLo.remove(i)
                poolLoT.remove(i)

alertcondition(fire22Bull, '2022 Model Bullish', 'Bullish 2022 displacement on {{ticker}}: sellside sweep + displacement up')
alertcondition(fire22Bear, '2022 Model Bearish', 'Bearish 2022 displacement on {{ticker}}: buyside sweep + displacement down')

// ============================================================================
// DRAW OBJECT STORES — the HTF engine and daily range redraw on the last bar.
// ============================================================================
var array<line>  dayLines = array.new<line>()
var array<label> dayLabs  = array.new<label>()
var array<box>   candBoxes = array.new<box>()
var array<line>  candWicks = array.new<line>()
var array<line>  blkLines  = array.new<line>()
var array<label> blkLabs   = array.new<label>()
var array<line>  smtLines  = array.new<line>()
var array<label> smtLabs   = array.new<label>()
var array<line>  swLines  = array.new<line>()
var array<label> swLabels = array.new<label>()
var array<line>  pdLines  = array.new<line>()
var array<label> pdLabs   = array.new<label>()
var array<box>   fvgBoxes = array.new<box>()
// Price bands already occupied by a drawn zone, shared by every FVG layer so the higher timeframe
// claims a band first. Rebuilt each render alongside the boxes themselves.
var array<float> drawnTop = array.new<float>()
var array<float> drawnBot = array.new<float>()
var array<bool>  drawnUp  = array.new<bool>()
// The candle range of the layer that recorded each band, so a 5m zone tested against a 1H band is judged
// on the 1H scale rather than its own smaller units.
var array<float> drawnAtr = array.new<float>()
// Zone budgets, shared across all layers — Max Zones Shown counts boxes on the chart, not per layer.
// Held in an array because Pine forbids assigning to a global scalar inside a function (CE10088), and
// these increment inside f_fvgLayer. Index 0 = live and inverted, index 1 = spent.
var array<int> fvgUsed = array.new<int>(2, 0)
// Swept levels already drawn this render — cross-layer dedup, since a swing low is usually a swing low
// on every timeframe at once.
var array<float> swpLvls = array.new<float>()
var array<line>  mssLines = array.new<line>()
var array<label> mssLabs  = array.new<label>()
// Levels already claimed by a drawn MSS this render. Layers run highest timeframe first, so a lower
// layer finding a shift at a claimed level is the same shift at finer resolution and is skipped. A
// lower-timeframe shift at its own level still draws.
var array<float> mssLvls = array.new<float>()
var label       warnLbl  = na
var table       dashTbl  = na

// Alert dedup — the last confirmed sweep/shift time already alerted, per layer and per side. A time
// rather than an index, because every index shifts on every new bar.
var int lastSweepBsHtf = na
var int lastSweepSsHtf = na
var int lastSweepBsMid = na
var int lastSweepSsMid = na
var int lastSweepBsLow = na
var int lastSweepSsLow = na
var int lastMssBearHtf = na
var int lastMssBullHtf = na
var int lastMssBearMid = na
var int lastMssBullMid = na
var int lastMssBearLow = na
var int lastMssBullLow = na

// ============================================================================
// CONFIRMED EVENT STORES — the persistence layer.
//
// The MTF snapshots are a rolling window twelve candles deep (ten on the mid and low layers), so
// detection re-run from that window can only see the last few hours. These stores keep each event as it
// is found, so how long something stays on the chart is decided by its own lifecycle and the display
// caps rather than by how far back the snapshot reaches.
//
// Two rules:
//   1. An event is recorded once, on a confirmed close, and its geometry is never recomputed. The
//      forming candle cannot add, move or delete one.
//   2. State — a gap being entered, a divergence being broken — updates forward only.
// ============================================================================

//@variable One market structure shift: the swing level, the bar that formed it, the bar that broke it.
type MssEvt
    float  lvl
    int    originT
    int    endT
    bool   bear
    string tag

//@variable One swept liquidity pool: the level, the bar that formed it, the bar that raided it.
type SwpEvt
    float  lvl
    int    originT
    int    endT
    string tag
    bool   isHigh

//@variable One fair value gap plus its live lifecycle. touched / filled / reclaimed advance forward
//          on chart bars, so a gap keeps its true state after it leaves the snapshot window.
type FvgEvt
    float  top
    float  bot
    int    originT
    bool   up
    string tag
    float  atr
    bool   touched   = false
    bool   filled    = false
    bool   reclaimed = false
    bool   sb        = false

//@variable One SMT divergence: the peer's swing extreme, our sweeping extreme, and whether price has
//          since traded back through the extreme that formed it.
type SmtEvt
    float  refLvl
    int    refT
    float  swpLvl
    int    swpT
    bool   isHigh
    string tag
    string peer
    bool   broken = false

var array<MssEvt> mssStore = array.new<MssEvt>()
var array<SwpEvt> swpStore = array.new<SwpEvt>()
var array<FvgEvt> fvgStore = array.new<FvgEvt>()
var array<SmtEvt> smtStore = array.new<SmtEvt>()

// How many of each event kind is remembered — well above any display cap. The caps decide what is
// drawn; this decides what is available to draw. Pruned oldest-first.
const int EVT_KEEP = 60

//@function Pads a label's text with a blank line on its anchor side so it sits one text line clear of
//          another label at the same price — a SMT rides a swept level by construction. A spacer line
//          holds that separation at any zoom, which a price offset would not.
//@param sty (string) The label style the text will be drawn with.
//@returns (string) The padded text.
f_lblStack(string txt, string sty) =>
    // The trailing spacer carries a space — a fully empty last line can be trimmed off.
    sty == label.style_label_down ? txt + '\n ' : sty == label.style_label_up ? '\n' + txt : txt

//@function Average high-low range of a snapshot's candles — a stand-in for ATR at that timeframe's own
//          resolution, since a snapshot array carries no incremental ta.atr() series. Each layer's gates
//          measure against its own value.
//@returns (float) The mean range, or na when the snapshot is empty.
f_avgRange(array<float> aH, array<float> aL) =>
    float sum = 0.0
    int   n   = 0
    // From index 1: index 0 is the forming candle, and its part-built range would make every gate that
    // scales off this value drift on a clock rather than on price.
    for k = 1 to aH.size() - 1
        float hk = aH.get(k)
        float lk = aL.get(k)
        if not na(hk) and not na(lk)
            sum += hk - lk
            n += 1
    n > 0 ? sum / n : na

// ============================================================================
// RECORDERS — run on a layer's own candle close and add anything newly confirmed to the stores.
//
// All of these skip snapshot index 0, the forming candle: an event that depends on it can still be
// undone before that candle closes. Re-scanning an already-scanned window is harmless, since each
// recorder checks the store first, keyed on the layer, the origin bar and the level.
// ============================================================================

//@function Records structure shifts found in one snapshot that are not already stored.
//@param tol (float) Price tolerance for treating two levels as the same shift.
//@returns  (bool) Always true — called for its effect on the store.
f_recMss(array<float> aO, array<float> aH, array<float> aL, array<float> aC, array<int> aT, string tag, float tol) =>
    int n = aO.size()
    if n >= 4
        for s = 2 to n - 2
            for d = 0 to 1
                bool bear = d == 0
                if not f_isSwing(aO, aH, aL, aC, s, bear)
                    continue
                float lvl = bear ? aL.get(s) : aH.get(s)
                if na(lvl) or na(aT.get(s)) or na(aT.get(s - 1))
                    continue
                // The breaking candle must be closed — j == 0 is the forming one and is skipped.
                int bj = na
                for j = s - 2 to 0
                    if j == 0
                        continue
                    float cj = aC.get(j)
                    if na(cj)
                        continue
                    if bear ? cj < lvl : cj > lvl
                        bj := j
                        break
                if na(bj)
                    continue
                int oT = f_extremeTime(not bear, lvl, aT.get(s), aT.get(s - 1))
                int eT = aT.get(bj - 1)
                if na(oT) or na(eT) or oT >= eT
                    continue
                bool known = false
                if mssStore.size() > 0
                    for k = 0 to mssStore.size() - 1
                        MssEvt e = mssStore.get(k)
                        if e.tag == tag and e.originT == oT and math.abs(e.lvl - lvl) <= tol
                            known := true
                            break
                if not known
                    mssStore.push(MssEvt.new(lvl = lvl, originT = oT, endT = eT, bear = bear, tag = tag))
        while mssStore.size() > EVT_KEEP
            mssStore.shift()
    true

//@function Records swept liquidity pools found in one snapshot that are not already stored.
f_recSwp(array<float> aH, array<float> aL, array<float> aC, array<int> aT, string tag, float tol) =>
    int n = aH.size()
    if n >= 4
        for i = 1 to n - 2
            if na(aH.get(i)) or na(aL.get(i)) or na(aC.get(i)) or na(aT.get(i))
                continue
            int tiEnd = aT.get(i - 1)
            if na(tiEnd)
                continue
            int sH = f_sweptIdx(aH, aL, aC, i, n, true)
            int sL = f_sweptIdx(aH, aL, aC, i, n, false)
            if not na(sH) and not na(aT.get(sH)) and not na(aT.get(sH - 1))
                float lvl = aH.get(sH)
                int   oT  = f_extremeTime(true, lvl, aT.get(sH), aT.get(sH - 1))
                if not na(oT) and not na(lvl) and oT < tiEnd
                    bool known = false
                    if swpStore.size() > 0
                        for k = 0 to swpStore.size() - 1
                            SwpEvt e = swpStore.get(k)
                            if e.tag == tag and e.isHigh and e.originT == oT and math.abs(e.lvl - lvl) <= tol
                                known := true
                                break
                    if not known
                        swpStore.push(SwpEvt.new(lvl = lvl, originT = oT, endT = tiEnd, tag = tag, isHigh = true))
            if not na(sL) and not na(aT.get(sL)) and not na(aT.get(sL - 1))
                float lvl = aL.get(sL)
                int   oT  = f_extremeTime(false, lvl, aT.get(sL), aT.get(sL - 1))
                if not na(oT) and not na(lvl) and oT < tiEnd
                    bool known = false
                    if swpStore.size() > 0
                        for k = 0 to swpStore.size() - 1
                            SwpEvt e = swpStore.get(k)
                            if e.tag == tag and not e.isHigh and e.originT == oT and math.abs(e.lvl - lvl) <= tol
                                known := true
                                break
                    if not known
                        swpStore.push(SwpEvt.new(lvl = lvl, originT = oT, endT = tiEnd, tag = tag, isHigh = false))
        while swpStore.size() > EVT_KEEP
            swpStore.shift()
    true

//@function Records fair value gaps found in one snapshot that are not already stored, seeding each
//          one's lifecycle from the candles that already followed it. Without that seed a gap found on
//          chart load would read as untouched no matter how long ago price traded through it.
f_recFvg(array<float> aO, array<float> aH, array<float> aL, array<float> aC, array<int> aT, float layerAtr, string tag, float barMs) =>
    int num = aO.size()
    if num >= 4 and not na(layerAtr) and layerAtr > 0
        for i = 1 to num - 3
            float hiI = aH.get(i)
            float loI = aL.get(i)
            float oM  = aO.get(i + 1)
            float cM  = aC.get(i + 1)
            float hiO = aH.get(i + 2)
            float loO = aL.get(i + 2)
            int   tM   = aT.get(i + 1)
            int   tOld = aT.get(i + 2)
            if na(hiI) or na(loI) or na(oM) or na(cM) or na(hiO) or na(loO) or na(tM) or na(tOld)
                continue
            bool dispBull = cM > oM and (cM - oM) >= layerAtr * fvgDispMult
            bool dispBear = cM < oM and (oM - cM) >= layerAtr * fvgDispMult
            bool bullGap  = loI > hiO and (loI - hiO) >= layerAtr * fvgMinAtr and dispBull
            bool bearGap  = hiI < loO and (loO - hiI) >= layerAtr * fvgMinAtr and dispBear
            // A SUSPENSION BLOCK: three same-direction candles, each opening beyond the previous close,
            // so the bodies never trade back through the leg at either join. It is two volume imbalances
            // joined through the middle body and qualifies without a wick gap, so it is tested here and
            // takes the leg's place when it holds. A join spanning more than one candle's worth of time
            // is a session or weekend break, not displacement. Same logic as Confluence Engine+.
            bool isSb = false
            if fvgShowSb
                float sOI = aO.get(i)
                float sCI = aC.get(i)
                float sOO = aO.get(i + 2)
                float sCO = aC.get(i + 2)
                int   sTI = aT.get(i)
                if not na(sOI) and not na(sCI) and not na(sOO) and not na(sCO) and not na(sTI)
                    bool contig = (sTI - tM) <= barMs * 1.5 and (tM - tOld) <= barMs * 1.5
                    bool sbUp = contig and sCO > sOO and cM > oM and sCI > sOI and oM > sCO and sOI > cM and (sOI - sCO) >= layerAtr * fvgMinAtr
                    bool sbDn = contig and sCO < sOO and cM < oM and sCI < sOI and oM < sCO and sOI < cM and (sCO - sOI) >= layerAtr * fvgMinAtr
                    if sbUp or sbDn
                        isSb    := true
                        bullGap := sbUp
                        bearGap := sbDn
            if not bullGap and not bearGap
                continue
            float zTop  = bullGap ? loI : loO
            float zBot  = bullGap ? hiO : hiI
            if isSb
                zTop := bullGap ? aO.get(i) : aC.get(i + 2)
                zBot := bullGap ? aC.get(i + 2) : aO.get(i)
            // A volume imbalance on either seam of the displacement candle — a BODY gap the wicks still
            // bridge — is part of the same imbalance, so the zone absorbs it and the edge extends to the
            // VI's body edge. Same reading as the PO3 Matrix+ gap engine: the wick gap alone understates
            // the region. Runs before the store lookup, so a zone is only ever known at its final edges.
            if fvgMergeVi and not isSb
                float oI  = aO.get(i)
                float cI  = aC.get(i)
                float oO  = aO.get(i + 2)
                float cO  = aC.get(i + 2)
                float hiM = aH.get(i + 1)
                float loM = aL.get(i + 1)
                if not na(oI) and not na(cI) and not na(oO) and not na(cO) and not na(hiM) and not na(loM)
                    float bIT = math.max(oI, cI)
                    float bIB = math.min(oI, cI)
                    float bMT = math.max(oM, cM)
                    float bMB = math.min(oM, cM)
                    float bOT = math.max(oO, cO)
                    float bOB = math.min(oO, cO)
                    if bullGap
                        if bMB > bOT and loM <= hiO      // lower seam VI — extend the bottom down
                            zBot := math.min(zBot, bOT)
                        if bIB > bMT and loI <= hiM      // upper seam VI — extend the top up
                            zTop := math.max(zTop, bIB)
                    else
                        if bMT < bOB and hiM >= loO      // upper seam VI — extend the top up
                            zTop := math.max(zTop, bOB)
                        if bIT < bMB and hiI >= loM      // lower seam VI — extend the bottom down
                            zBot := math.min(zBot, bIT)
            int   tOrig = f_extremeTime(bullGap, bullGap ? hiO : loO, tOld, tM)
            if na(tOrig)
                continue
            bool known = false
            if fvgStore.size() > 0
                for k = 0 to fvgStore.size() - 1
                    FvgEvt g = fvgStore.get(k)
                    if g.tag == tag and g.originT == tOrig and math.abs(g.top - zTop) <= syminfo.mintick and math.abs(g.bot - zBot) <= syminfo.mintick
                        known := true
                        break
            if known
                continue
            // Seed the lifecycle from the newer candles already in the window, oldest-newer first so
            // the events resolve in the order they happened — an inversion is order-dependent.
            bool tch = false
            bool fil = false
            bool rec = false
            for w = 0 to i - 1
                int   q  = i - 1 - w
                float hq = aH.get(q)
                float lq = aL.get(q)
                float cq = aC.get(q)
                if na(hq) or na(lq) or na(cq)
                    continue
                bool inZone  = lq <= zTop and hq >= zBot
                bool through = bullGap ? cq < zBot : cq > zTop
                bool back    = bullGap ? cq > zTop : cq < zBot
                if not fil
                    if inZone
                        tch := true
                    if through
                        fil := true
                else if back
                    rec := true
            fvgStore.push(FvgEvt.new(top = zTop, bot = zBot, originT = tOrig, up = bullGap, tag = tag, atr = layerAtr, touched = tch, filled = fil, reclaimed = rec, sb = isSb))
        while fvgStore.size() > EVT_KEEP
            fvgStore.shift()
    true

//@function Records SMT divergences found in one snapshot that are not already stored. A divergence is
//          the chart symbol sweeping a swing the correlated peer failed to take; `broken` is seeded
//          from the candles that already traded after it.
f_recSmt(array<float> aH, array<float> aL, array<float> aC, array<int> aT, array<float> pkH, array<float> pkL, string tag, string peer) =>
    int n = aH.size()
    if n >= 4
        for i = 1 to n - 2
            float hi = aH.get(i)
            float li = aL.get(i)
            if na(hi) or na(li) or na(aC.get(i)) or na(aT.get(i))
                continue
            int endT = aT.get(i - 1)
            if na(endT)
                continue
            int sH = f_sweptIdx(aH, aL, aC, i, n, true)
            int sL = f_sweptIdx(aH, aL, aC, i, n, false)
            if na(sH) and na(sL)
                continue
            float postHi = na
            float postLo = na
            for j = 0 to i - 1
                float hj = aH.get(j)
                float lj = aL.get(j)
                if not na(hj) and (na(postHi) or hj > postHi)
                    postHi := hj
                if not na(lj) and (na(postLo) or lj < postLo)
                    postLo := lj
            if not na(sH) and not na(aT.get(sH)) and not na(aT.get(sH - 1))
                float pNow = pkH.get(i)
                float pRef = pkH.get(sH)
                if not na(pNow) and not na(pRef) and pNow <= pRef
                    float refLvl = aH.get(sH)
                    int   refT   = f_extremeTime(true, refLvl, aT.get(sH), aT.get(sH - 1))
                    int   swpT   = f_extremeTime(true, hi, aT.get(i), endT)
                    if not na(refT) and not na(swpT)
                        bool known = false
                        if smtStore.size() > 0
                            for k = 0 to smtStore.size() - 1
                                SmtEvt e = smtStore.get(k)
                                if e.tag == tag and e.isHigh and e.refT == refT and e.swpT == swpT
                                    known := true
                                    break
                        if not known
                            smtStore.push(SmtEvt.new(refLvl = refLvl, refT = refT, swpLvl = hi, swpT = swpT, isHigh = true, tag = tag, peer = peer, broken = not na(postHi) and postHi > hi))
            if not na(sL) and not na(aT.get(sL)) and not na(aT.get(sL - 1))
                float pNow = pkL.get(i)
                float pRef = pkL.get(sL)
                if not na(pNow) and not na(pRef) and pNow >= pRef
                    float refLvl = aL.get(sL)
                    int   refT   = f_extremeTime(false, refLvl, aT.get(sL), aT.get(sL - 1))
                    int   swpT   = f_extremeTime(false, li, aT.get(i), endT)
                    if not na(refT) and not na(swpT)
                        bool known = false
                        if smtStore.size() > 0
                            for k = 0 to smtStore.size() - 1
                                SmtEvt e = smtStore.get(k)
                                if e.tag == tag and not e.isHigh and e.refT == refT and e.swpT == swpT
                                    known := true
                                    break
                        if not known
                            smtStore.push(SmtEvt.new(refLvl = refLvl, refT = refT, swpLvl = li, swpT = swpT, isHigh = false, tag = tag, peer = peer, broken = not na(postLo) and postLo < li))
        while smtStore.size() > EVT_KEEP
            smtStore.shift()
    true

//@function Advances every stored gap's lifecycle on the current closed chart bar. Forward only — a gap
//          that has left the snapshot window keeps its true state instead of being re-derived wrongly.
f_updFvg() =>
    if fvgStore.size() > 0
        for k = 0 to fvgStore.size() - 1
            FvgEvt g = fvgStore.get(k)
            if g.reclaimed
                continue
            bool inZone  = low <= g.top and high >= g.bot
            bool through = g.up ? close < g.bot : close > g.top
            bool back    = g.up ? close > g.top : close < g.bot
            if not g.filled
                if inZone
                    g.touched := true
                if through
                    g.filled := true
            else if back
                g.reclaimed := true
    true

//@function Marks a stored divergence broken once price trades back through the extreme that formed it.
f_updSmt() =>
    if smtStore.size() > 0
        for k = 0 to smtStore.size() - 1
            SmtEvt s = smtStore.get(k)
            if s.broken
                continue
            if (s.isHigh and high > s.swpLvl) or (not s.isHigh and low < s.swpLvl)
                s.broken := true
    true

//@function Draws the STORED fair value gaps for ONE timeframe layer. Detection lives in f_recFvg (a
//          3-candle gap: the current candle's extreme fails to reach the extreme from 2 candles back,
//          with the candle between them displacing hard enough to open real space) and the lifecycle
//          — live → active (entered) → inverted (closed through, the break holding) → spent (closed
//          through then reclaimed) — is advanced forward on chart bars by f_updFvg. This function only
//          decides which of the stored zones are shown and how they look.
//@param fTag     (string) Caption prefix and store key, e.g. '15m'.
//@param extBars  (int)    How far past the live candle this layer's zones run. Each layer gets its own
//                         distance so the captions land in separate columns instead of stacking.
//@param edgeCap  (bool)   true = caption at the zone's outer edge, false = centred. The primary layer
//                         takes the edges, so a fine zone inside a coarse one captions elsewhere.
//@returns (string) Direction of the newest live zone, for the console. '-' when there is none.
f_fvgLayer(string fTag, int extBars, bool edgeCap) =>
    string dir = '-'
    int    msPerBarL = timeframe.in_seconds(timeframe.period) * 1000
    if fvgStore.size() > 0
        // Newest first, so when the display caps bite it is the oldest zones that drop off.
        for gi = fvgStore.size() - 1 to 0
            FvgEvt g = fvgStore.get(gi)
            if g.tag != fTag
                continue
            float layerAtr  = g.atr
            float zTop      = g.top
            float zBot      = g.bot
            bool  bullGap   = g.up
            bool  touched   = g.touched
            bool  filled    = g.filled
            bool  reclaimed = g.reclaimed
            bool inverted = fvgInvert and filled and not reclaimed
            bool consumed = filled and not inverted
            if consumed and not fvgKeepFill
                continue
            if touched and not filled and fvgHideMit
                continue
            // Budget shared across every layer. A spent zone draws from its own smaller allowance so it
            // cannot crowd out a live one.
            int budgetSlot = consumed ? 1 : 0
            if fvgUsed.get(budgetSlot) >= (consumed ? maxSpentFvg : maxFvg)
                continue
            // Declutter applies to every drawn zone, spent ones included — fading a zone changes how it
            // looks, not how many boxes are on the pane. The bands are shared across layers and layers
            // run highest timeframe first, so a 15m gap inside an already-drawn 1H gap is dropped.
            bool zUp = inverted ? not bullGap : bullGap
            if fvgDeclutter or fvgNearOn
                if drawnTop.size() > 0
                    bool  clash = false
                    float zH    = zTop - zBot
                    for z = 0 to drawnTop.size() - 1
                        // Positive = shared height; negative = the seam between the two zones.
                        float ovl = math.min(zTop, drawnTop.get(z)) - math.max(zBot, drawnBot.get(z))
                        if fvgDeclutter and ovl > 0 and zH > 0 and (ovl / zH) * 100.0 > fvgOverlapPct
                            clash := true
                            break
                        // Judged on the LARGER of the two scales, so a fine-timeframe zone cannot slip
                        // past a coarse-timeframe band by measuring the gap in its own small units.
                        float nearRef = math.max(layerAtr, drawnAtr.get(z))
                        if fvgNearOn and ovl <= 0 and -ovl <= nearRef * fvgNearMult and drawnUp.get(z) == zUp
                            clash := true
                            break
                    if clash
                        continue
                drawnTop.push(zTop)
                drawnBot.push(zBot)
                drawnUp.push(zUp)
                drawnAtr.push(layerAtr)
            // Set only now that the zone is certain to be drawn — reporting a direction from a zone that
            // was then capped or decluttered away would put the console at odds with the chart.
            if not consumed and dir == '-'
                dir := (zUp ? 'Bullish' : 'Bearish') + (inverted ? ' (inv)' : '')
            color  zBase  = inverted ? fvgInvColor : bullGap ? fvgBullColor : fvgBearColor
            color  zCol   = consumed ? color.new(zBase, 95) : zBase
            color  bCol   = color.new(zBase, consumed ? 90 : touched ? 75 : 45)
            string bSty   = (inverted or (not touched and not consumed)) ? line.style_solid : line.style_dotted
            // BISI / SIBI name how the imbalance was BUILT; inverting does not rebuild it, so the
            // name is kept and IFVG is appended.
            string fName  = (g.sb ? (bullGap ? ' SB+' : ' SB-') : (bullGap ? ' BISI+' : ' SIBI-')) + (inverted ? ' IFVG' : '')
            // No state word — the border carries it: solid for live and inverted, dotted once entered or
            // spent. IFVG stays, since an inversion is a different object rather than a state.
            string fState = ''
            int    fRight = time + extBars * msPerBarL
            // Left edge = the chart bar whose wick formed the gap's defining edge, resolved once by
            // f_recFvg. The HTF candle's open time would sit up to twelve bars earlier.
            int    tOrig  = g.originT
            // Caption is box-native text at the right edge, never a style_none label straddling its own
            // price. Top of a bullish zone, bottom of a bearish one, so stacked zones caption apart.
            fvgBoxes.push(box.new(tOrig, zTop, fRight, zBot, xloc = xloc.bar_time, border_color = bCol, border_width = 1, border_style = bSty, bgcolor = zCol, text = showFvgLabels ? fTag + fName + fState : '', text_size = LBL_SZ, text_color = fvgLblColor, text_halign = text.align_right, text_valign = edgeCap ? (zUp ? text.align_top : text.align_bottom) : text.align_center, text_font_family = font.family_monospace))
            fvgUsed.set(budgetSlot, fvgUsed.get(budgetSlot) + 1)
    dir

//@function Draws the stored swept liquidity pools for ONE timeframe layer. Detection lives in f_recSwp,
//          which shares f_sweptIdx with the SMT recorder. Every sweep draws identically at any
//          timeframe — black, liquidity width, dotted — so the label carries the timeframe instead of
//          repeating the word Sweep.
//@param tfTag  (string) Label text and store key, e.g. '1H'.
//@param maxN   (int)    Max pools drawn for this layer.
//@param swpTol (float)  How close two swept levels must be in price to be the same pool seen at two
//                       resolutions. Layers run highest first, so the senior timeframe keeps the mark.
//@returns (int) Number of pools drawn.
f_sweepLayer(string tfTag, int maxN, float swpTol) =>
    int shown = 0
    if swpStore.size() > 0
        // Newest first, so the cap keeps the most recent pools rather than whichever were found first.
        for si = swpStore.size() - 1 to 0
            if shown >= maxN
                break
            SwpEvt e = swpStore.get(si)
            if e.tag != tfTag
                continue
            // Already claimed by a senior timeframe? Same pool, seen finer — skip it. Layers run highest
            // first, so the surviving line and label belong to the largest timeframe that saw the raid.
            bool taken = false
            if swpLvls.size() > 0
                for v = 0 to swpLvls.size() - 1
                    if math.abs(swpLvls.get(v) - e.lvl) <= swpTol
                        taken := true
                        break
            if taken
                continue
            swpLvls.push(e.lvl)
            swLines.push(line.new(e.originT, e.lvl, e.endT, e.lvl, xloc = xloc.bar_time, color = sweepColor, width = sweepWidth, style = line.style_dotted))
            if showSweepLabels
                // At the origin, text to the LEFT of it (style_label_right anchors the pointer on the
                // right) so it sits before the line rather than on it. An SMT off the same sweep labels
                // above the level instead, so the two share an origin without sharing a space.
                label swl = label.new(e.originT, e.lvl, tfTag, xloc = xloc.bar_time, color = color.new(color.white, 100), style = label.style_label_right, textcolor = sweepColor, size = LBL_SZ)
                label.set_text_font_family(swl, font.family_monospace)
                swLabels.push(swl)
            shown += 1
    shown

//@function Draws the STORED structure shifts for ONE timeframe layer. Detection lives in f_recMss —
//          a TRUE swing (f_isSwing) whose full wick extreme is broken by the first body close beyond
//          it, recorded once on a closed candle. This reads that store, so a shift keeps its line for
//          as long as the display cap allows rather than only while it sits inside the snapshot.
//@param tfTag  (string) Label prefix and store key, e.g. '15m'.
//@param maxN   (int)    Max shifts drawn for this layer.
//@param lWidth (int)    Line width for this layer.
//@param lSty   (string) Line style. Layers rank by width first — HTF at W_MSS, the two lower at 1 — and
//                       the low layer then goes dashed so it is never confused with the mid layer.
//@param tol    (float)  How close two shifts must be in price to count as the same shift. A level within
//                       tol of one already in mssLvls is skipped, so the senior timeframe supersedes.
//@param sepRef (float)  This layer's average candle range, for the same-layer separation rule.
//@returns (int) Number of shifts drawn.
f_mssLayer(string tfTag, int maxN, int lWidth, string lSty, float tol, float sepRef) =>
    int shown = 0
    // Levels this layer has drawn, and the minimum gap between two of them. Separate from mssLvls, which
    // supersedes across layers at a tighter tolerance — merging the two would let this layer's spacing
    // rule suppress it near a senior layer's level.
    array<float> layerLvls = array.new<float>()
    float sepDist = na(sepRef) ? 0.0 : sepRef * mssSepMult
    if mssStore.size() > 0
        // Newest first, so the cap keeps the most recent shifts.
        for si = mssStore.size() - 1 to 0
            if shown >= maxN
                break
            MssEvt e = mssStore.get(si)
            if e.tag != tfTag
                continue
            float refLvl = e.lvl
            // Superseded? A shift already drawn at this price by a senior timeframe is the same event.
            bool taken = false
            if mssLvls.size() > 0
                for v = 0 to mssLvls.size() - 1
                    if math.abs(mssLvls.get(v) - refLvl) <= tol
                        taken := true
                        break
            if taken
                continue
            // Too close to a shift this layer already drew? Skip it and keep walking back for a
            // genuinely different level.
            bool crowded = false
            if sepDist > 0 and layerLvls.size() > 0
                for v = 0 to layerLvls.size() - 1
                    if math.abs(layerLvls.get(v) - refLvl) < sepDist
                        crowded := true
                        break
            if crowded
                continue
            layerLvls.push(refLvl)
            color mCol = e.bear ? mssBearCol : mssBullCol
            mssLines.push(line.new(e.originT, refLvl, e.endT, refLvl, xloc = xloc.bar_time, color = mCol, width = lWidth, style = lSty))
            if mssLabels
                // At the swing that formed the shift (the line's left end), text on the outer side of the
                // level. Off the price rather than on it, which keeps it clear of the sweep label — the
                // usual sequence is a pool swept and then broken, so the two share a level constantly.
                label msl = label.new(e.originT, refLvl, tfTag + ' MSS', xloc = xloc.bar_time, color = color.new(color.white, 100), style = e.bear ? label.style_label_upper_left : label.style_label_lower_left, textcolor = mCol, size = MSS_SZ)
                label.set_text_font_family(msl, font.family_monospace)
                mssLabs.push(msl)
            mssLvls.push(refLvl)
            shown += 1
    shown

//@function Alert-only MSS scan — the same true-swing engine as the recorders (f_isSwing, unmodified),
//          with the breaking candle restricted to a closed one (index >= 1).
//@param aO..aT   (array) Layer snapshot, index 0 = forming candle, the rest confirmed closed candles.
//@param wantBear (bool)  true = bearish shift (swing low broken by a close below it), false = bullish.
//@returns (int) Time of the most recent confirmed swing that shifted, or na when none qualify.
f_alertMss(array<float> aO, array<float> aH, array<float> aL, array<float> aC, array<int> aT, bool wantBear) =>
    int swingTime = na
    int num = aO.size()
    for s = 2 to num - 2
        if not na(swingTime)
            break
        if not f_isSwing(aO, aH, aL, aC, s, wantBear)
            continue
        float refLvl = wantBear ? aL.get(s) : aH.get(s)
        int   bj = na
        for j = s - 2 to 0
            if j == 0
                continue
            float cj = aC.get(j)
            if na(cj)
                continue
            if wantBear ? cj < refLvl : cj > refLvl
                bj := j
                break
        if not na(bj)
            swingTime := aT.get(s)
    swingTime

// ============================================================================
// SNAPSHOT ARRAYS + RECORDING DRIVER
//
// The arrays are built at GLOBAL scope so the recorders, which run on candle closes, and the render,
// which runs on the last bar, read the same data. Building them inside the render block instead would
// confine detection to whatever the window holds on the bar being drawn.
//
// Recording is gated on each layer's OWN candle close: a 1H event can only appear when a 1H candle
// closes, so scanning every chart bar would be the same work repeated twelve times over. Re-scanning a
// window already scanned is harmless — the recorders check the store before they write.
// ============================================================================
array<float> aO = array.from(o0,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11)
array<float> aH = array.from(h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11)
array<float> aL = array.from(l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11)
array<float> aC = array.from(c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11)
array<int>   aT = array.from(t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11)
// Peer highs/lows on the same index grid — used only to answer "did the peer take its swing too?".
// Same length as the arrays above by construction: these are read at indices produced from them.
array<float> pkH = array.from(ph0,ph1,ph2,ph3,ph4,ph5,ph6,ph7,ph8,ph9,ph10,ph11)
array<float> pkL = array.from(pl0,pl1,pl2,pl3,pl4,pl5,pl6,pl7,pl8,pl9,pl10,pl11)

array<float> mdAO = array.from(mdO0,mdO1,mdO2,mdO3,mdO4,mdO5,mdO6,mdO7,mdO8,mdO9)
array<float> mdAH = array.from(mdH0,mdH1,mdH2,mdH3,mdH4,mdH5,mdH6,mdH7,mdH8,mdH9)
array<float> mdAL = array.from(mdL0,mdL1,mdL2,mdL3,mdL4,mdL5,mdL6,mdL7,mdL8,mdL9)
array<float> mdAC = array.from(mdC0,mdC1,mdC2,mdC3,mdC4,mdC5,mdC6,mdC7,mdC8,mdC9)
array<int>   mdAT = array.from(mdT0,mdT1,mdT2,mdT3,mdT4,mdT5,mdT6,mdT7,mdT8,mdT9)

array<float> lwAO = array.from(lwO0,lwO1,lwO2,lwO3,lwO4,lwO5,lwO6,lwO7,lwO8,lwO9)
array<float> lwAH = array.from(lwH0,lwH1,lwH2,lwH3,lwH4,lwH5,lwH6,lwH7,lwH8,lwH9)
array<float> lwAL = array.from(lwL0,lwL1,lwL2,lwL3,lwL4,lwL5,lwL6,lwL7,lwL8,lwL9)
array<float> lwAC = array.from(lwC0,lwC1,lwC2,lwC3,lwC4,lwC5,lwC6,lwC7,lwC8,lwC9)
array<int>   lwAT = array.from(lwT0,lwT1,lwT2,lwT3,lwT4,lwT5,lwT6,lwT7,lwT8,lwT9)

int   num    = 12
float htfAtr = f_avgRange(aH, aL)
float midAtr = f_avgRange(mdAH, mdAL)
float lowAtr = f_avgRange(lwAH, lwAL)

// How close two levels must be in price to be treated as ONE event seen at two resolutions. Shared by
// the sweep layers and the structure-shift layers so "the same level" means the same thing to both.
// Scaled to the primary candle range rather than a fixed tick count, which would supersede everything
// on one instrument and nothing on another.
float lvlTol   = not na(htfAtr) and htfAtr > 0 ? htfAtr * 0.10 : syminfo.mintick * 4
int   msPerBar = timeframe.in_seconds(timeframe.period) * 1000

string htfTag = f_tfLabel(htfTf)
string midTag = f_tfLabel(midTf)
string lowTag = f_tfLabel(lowTf)

// The peer reads correctly only while its HTF candles open at the same moment as the chart's. Otherwise
// the comparison spans different periods, so SMT is withheld rather than drawn wrongly.
bool smtAligned = not na(pt0) and not na(t0) and pt0 == t0

// ── Record, on each layer's own candle close ───────────────────────────────────
if htfValid and newHtfBar
    bool _rm1 = f_recMss(aO, aH, aL, aC, aT, htfTag, lvlTol)
    bool _rs1 = f_recSwp(aH, aL, aC, aT, htfTag, lvlTol)
    bool _rf1 = f_recFvg(aO, aH, aL, aC, aT, htfAtr, htfTag, timeframe.in_seconds(htfTf) * 1000.0)
    bool _rt1 = smtOn and smtAligned ? f_recSmt(aH, aL, aC, aT, pkH, pkL, htfTag, smtName) : true
if htfValid and midValid and newMidBar
    bool _rm2 = f_recMss(mdAO, mdAH, mdAL, mdAC, mdAT, midTag, lvlTol)
    bool _rs2 = f_recSwp(mdAH, mdAL, mdAC, mdAT, midTag, lvlTol)
    bool _rf2 = f_recFvg(mdAO, mdAH, mdAL, mdAC, mdAT, midAtr, midTag, timeframe.in_seconds(midTf) * 1000.0)
if htfValid and lowValid and newLowBar
    bool _rm3 = f_recMss(lwAO, lwAH, lwAL, lwAC, lwAT, lowTag, lvlTol)
    bool _rs3 = f_recSwp(lwAH, lwAL, lwAC, lwAT, lowTag, lvlTol)
    bool _rf3 = f_recFvg(lwAO, lwAH, lwAL, lwAC, lwAT, lowAtr, lowTag, timeframe.in_seconds(lowTf) * 1000.0)

// ── Advance stored state on every CLOSED chart bar ─────────────────────────────
// Chart-bar resolution rather than snapshot resolution: a gap is entered by the bar that actually
// enters it, and a divergence breaks on the bar that actually takes the extreme back.
if barstate.isconfirmed
    bool _uf = f_updFvg()
    bool _us = f_updSmt()

// ============================================================================
// RENDER — clear + redraw on the last bar from the stores.
// ============================================================================
if barstate.islast
    for _d in dayLines
        line.delete(_d)
    dayLines.clear()
    for _dl in dayLabs
        label.delete(_dl)
    dayLabs.clear()
    for _cb in candBoxes
        box.delete(_cb)
    candBoxes.clear()
    for _cw in candWicks
        line.delete(_cw)
    candWicks.clear()
    for _bl in blkLines
        line.delete(_bl)
    blkLines.clear()
    for _bll in blkLabs
        label.delete(_bll)
    blkLabs.clear()
    for _sm in smtLines
        line.delete(_sm)
    smtLines.clear()
    for _sml in smtLabs
        label.delete(_sml)
    smtLabs.clear()
    for _s in swLines
        line.delete(_s)
    swLines.clear()
    for _sl in swLabels
        label.delete(_sl)
    swLabels.clear()
    for _pl in pdLines
        line.delete(_pl)
    pdLines.clear()
    for _pll in pdLabs
        label.delete(_pll)
    pdLabs.clear()
    for _fb in fvgBoxes
        box.delete(_fb)
    fvgBoxes.clear()
    drawnTop.clear()
    drawnBot.clear()
    drawnUp.clear()
    drawnAtr.clear()
    swpLvls.clear()
    fvgUsed.set(0, 0)
    fvgUsed.set(1, 0)
    for _ms in mssLines
        line.delete(_ms)
    mssLines.clear()
    for _msl in mssLabs
        label.delete(_msl)
    mssLabs.clear()
    mssLvls.clear()
    if not na(dashTbl)
        table.delete(dashTbl)
        dashTbl := na

    if not htfValid
        if na(warnLbl)
            warnLbl := label.new(bar_index, high, '2022 Model+ — set the MTF Engine timeframe above the chart timeframe', xloc = xloc.bar_index, style = label.style_label_down, color = color.new(C_BEAR, 0), textcolor = color.white, size = LBL_SZ, text_font_family = font.family_monospace)
        else
            label.set_xy(warnLbl, bar_index, high)
    else
        if not na(warnLbl)
            label.delete(warnLbl)
            warnLbl := na

        // Snapshot arrays, ranges and tolerances all come from the global block above, so the render
        // and the recorders can never be looking at different data.

        // ── Daily PO3 range: open / H / 75 / EQ / 25 / L of the forming day ────────────
        if showDay and not na(dayOpen) and not na(dayHi) and not na(dayLo) and dayHi > dayLo
            float dR     = dayHi - dayLo
            int   dRight = time + dayExtend * msPerBar
            string openTag = useMidnight ? 'Midnight Open' : 'Day Open'
            // High and low anchor at the bar that printed them, at the High / Low Line Width input. The
            // open runs from the day boundary bar and draws dotted, like every other reference level.
            dayLines.push(line.new(dayT, dayOpen, dRight, dayOpen, xloc = xloc.bar_time, color = dayColor, width = W_REF, style = line.style_dotted))
            dayLines.push(line.new(dayHiT, dayHi, dRight, dayHi, xloc = xloc.bar_time, color = dayColor, width = dayWidth, style = line.style_solid))
            dayLines.push(line.new(dayLoT, dayLo, dRight, dayLo, xloc = xloc.bar_time, color = dayColor, width = dayWidth, style = line.style_solid))
            // Quadrants stop SHORT of the extremes' runway so the two label families cannot meet.
            int qRight = time + math.max(0, dayExtend - 6) * msPerBar
            if showDayQuad
                dayLines.push(line.new(dayT, dayLo + dR * 0.75, qRight, dayLo + dR * 0.75, xloc = xloc.bar_time, color = MID, width = W_REF, style = line.style_dotted))
                dayLines.push(line.new(dayT, dayLo + dR * 0.5,  qRight, dayLo + dR * 0.5,  xloc = xloc.bar_time, color = MID, width = W_REF, style = line.style_dotted))
                dayLines.push(line.new(dayT, dayLo + dR * 0.25, qRight, dayLo + dR * 0.25, xloc = xloc.bar_time, color = MID, width = W_REF, style = line.style_dotted))
            if showDayLabels
                array<float>  dyP = array.from(dayOpen, dayHi, dayLo, dayLo + dR * 0.75, dayLo + dR * 0.5, dayLo + dR * 0.25)
                array<string> dyT = array.from(openTag, 'Day H', 'Day L', '75%', 'EQ', '25%')
                array<bool>   dyQ = array.from(false, false, false, true, true, true)
                for qi = 0 to 5
                    bool isQuad = dyQ.get(qi)
                    if isQuad and not showDayQuad
                        continue
                    // Each family parks at its own distance right: quadrants nearest, day extremes next,
                    // previous-day levels furthest. Two levels at the same price then still read cleanly.
                    label dyl = label.new(isQuad ? qRight : dRight, dyP.get(qi), dyT.get(qi), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = isQuad ? MID : INK, size = LBL_SZ)
                    label.set_text_font_family(dyl, font.family_monospace)
                    dayLabs.push(dyl)

        // ── Daily PO3 candle — the forming day drawn as ONE projected candle beside price ──
        if showCand and not na(dayOpen) and not na(dayHi) and not na(dayLo)
            int   cHalf = candSize == 'Large' ? 5 : candSize == 'Medium' ? 3 : 1
            // Offset From Price is a minimum, not a position: the candle starts beyond the furthest label
            // runway in use plus room for that label's text, so no level line runs through its body.
            int   lvlRunway = math.max(showDay ? dayExtend : 0, showPD ? pdExtend : 0)
            int   cBase = bar_index + math.max(candOffset, lvlRunway + 10 + cHalf)
            int   cStep = cHalf * 2 + 2
            // One candle for the whole day, or one per block — both through the same drawing.
            for b = 0 to blkCount - 1
                float bOpen = blkCount > 1 ? blkO.get(b) : dayOpen
                float bHi   = blkCount > 1 ? blkH.get(b) : dayHi
                float bLo   = blkCount > 1 ? blkL.get(b) : dayLo
                float bClose = blkCount > 1 ? blkC.get(b) : close
                // A block that has not started yet is simply absent — no placeholder, no zero-height box.
                if na(bOpen) or na(bHi) or na(bLo) or na(bClose)
                    continue
                int   cX    = cBase + b * cStep
                bool  cBull = bClose >= bOpen
                float cBt   = math.max(bOpen, bClose)
                float cBb   = math.min(bOpen, bClose)
                if cBt == cBb
                    cBt := cBt + syminfo.mintick
                candBoxes.push(box.new(cX - cHalf, cBt, cX + cHalf, cBb, xloc = xloc.bar_index, bgcolor = cBull ? candBullBody : candBearBody, border_color = candOutline, border_width = 1))
                candWicks.push(line.new(cX, bHi, cX, cBt, xloc = xloc.bar_index, color = candOutline, width = 1))
                candWicks.push(line.new(cX, cBb, cX, bLo, xloc = xloc.bar_index, color = candOutline, width = 1))
                if candEq and bHi > bLo
                    float cEq = (bHi + bLo) / 2.0
                    candWicks.push(line.new(cX - cHalf, cEq, cX + cHalf, cEq, xloc = xloc.bar_index, color = candOutline, width = 1, style = line.style_dotted))

            // ── The split drawn back onto price ────────────────────────────────────────
            // Dividers at each block boundary, plus each block's high and low across its own span.
            // Boundaries use the same dayT + b × blkMs arithmetic that assigned every bar to its block.
            if blkCount > 1 and not na(dayT)
                for b = 0 to blkCount - 1
                    int bStart = dayT + b * blkMs
                    if bStart > time
                        continue
                    // The last block runs to the day's end; every other one to the next boundary. Both are
                    // clipped at the live bar — a block that has not finished has not reached its edge.
                    int bEnd = math.min(time, b == blkCount - 1 ? dayT + blkCount * blkMs : dayT + (b + 1) * blkMs)
                    if showBlkDiv
                        // A time marker, not a price level: extended both ways so it reads as a boundary
                        // in the chart rather than as something tracking price.
                        blkLines.push(line.new(bStart, close, bStart, close + syminfo.mintick, xloc = xloc.bar_time, color = blkColor, width = W_REF, style = BLK_DIV_STY, extend = extend.both))
                    if showBlkHL and not na(blkH.get(b)) and not na(blkL.get(b))
                        blkLines.push(line.new(bStart, blkH.get(b), bEnd, blkH.get(b), xloc = xloc.bar_time, color = blkColor, width = W_REF, style = line.style_solid))
                        blkLines.push(line.new(bStart, blkL.get(b), bEnd, blkL.get(b), xloc = xloc.bar_time, color = blkColor, width = W_REF, style = line.style_solid))

            // ── Countdown on the block (or day) currently forming ──────────────────────
            if showCandTimer and not na(dayT)
                // Which block is live right now, by the same arithmetic the accumulator uses. With no
                // split there is one block and its close is the day boundary.
                int liveIdx  = blkCount > 1 ? math.min(blkCount - 1, math.max(0, int((time - dayT) / blkMs))) : 0
                // A block ends at its own boundary; the last block, and the undivided day, end at the
                // day's true close. Every block is clipped to it so no countdown runs past the day.
                int liveEnd  = blkCount > 1 ? (na(dayCloseMs) ? dayT + (liveIdx + 1) * blkMs : math.min(dayCloseMs, dayT + (liveIdx + 1) * blkMs)) : dayCloseMs
                // Taken straight from the split setting rather than derived from blkMs — dividing the
                // millisecond span back down to minutes goes through a float and can render as '360.0'.
                string tTag  = blkCount > 1 ? (candSplit == '4 × 6H' ? '6H ' : '4H ') + str.tostring(liveIdx + 1) + '/' + str.tostring(blkCount) : 'Day'
                float blockTop = na
                for b = 0 to blkCount - 1
                    float bh = blkCount > 1 ? blkH.get(b) : dayHi
                    if not na(bh) and (na(blockTop) or bh > blockTop)
                        blockTop := bh
                if not na(blockTop)
                    int xMid = cBase + (blkCount - 1) * cStep / 2
                    // Lifted a tenth of the day's range clear of the block top so the countdown sits well
                    // above the projected candle instead of crowding the live price line beside it.
                    float timerY = blockTop + (dayHi - dayLo) * 0.10
                    label tmr = label.new(xMid, timerY, tTag + '\n' + f_countdown(liveEnd), xloc = xloc.bar_index, style = label.style_label_down, color = color.new(color.white, 100), textcolor = candOutline, size = LBL_SZ)
                    label.set_text_font_family(tmr, font.family_monospace)
                    blkLabs.push(tmr)

        // ── Fair value gaps — primary, mid and low timeframes ─────────────────────────
        // Layers run highest first: they share one set of occupied price bands, so a 1H zone claims its
        // band before the lower layers look at theirs. f_fvgLayer returns a direction that nothing here
        // consumes — the console has no gap row, since every zone draws at the price it happened.
        string _fvgDirUnused = '-'
        if showFvg
            // Three caption columns, senior timeframe furthest right, execution layer nearest price.
            _fvgDirUnused := f_fvgLayer(htfTag, fvgExtend + 24, true)

        // ── HTF sweeps + SMT + MSS, all drawn from the stores ──────────────────────────
        // Nothing here re-detects — the recorders wrote these events on the candle closes that produced
        // them.
        if showSweeps
            int _hSwp = f_sweepLayer(htfTag, maxSweeps, lvlTol)

        // Which side the most recent HTF pool was taken from, for the console's HTF Sweep row. Read
        // from the same store that drew the lines, so the console and the chart cannot disagree.
        string lastSweepDir = '-'
        if swpStore.size() > 0
            for si = swpStore.size() - 1 to 0
                SwpEvt e = swpStore.get(si)
                if e.tag != htfTag
                    continue
                lastSweepDir := e.isHigh ? 'Buyside' : 'Sellside'
                break

        // ── SMT divergence ─────────────────────────────────────────────────────────────
        // The line joins the two diverging extremes, each anchored to the bar that formed it. f_updSmt
        // marks one broken once price trades back through it; broken draws dotted and dimmed, or drops.
        if smtOn and smtStore.size() > 0
            int smtShown = 0
            for si = smtStore.size() - 1 to 0
                if smtShown >= smtMax
                    break
                SmtEvt e = smtStore.get(si)
                if e.broken and smtHideBrk
                    continue
                color  sBase = e.isHigh ? smtBearCol : smtBullCol
                color  sCol  = e.broken ? color.new(sBase, 55) : sBase
                string sSty  = e.broken ? line.style_dotted : line.style_solid
                smtLines.push(line.new(e.refT, e.refLvl, e.swpT, e.swpLvl, xloc = xloc.bar_time, color = sCol, width = W_REF, style = sSty))
                if smtLabels
                    // At the origin swing, on the outer side of it — clear of the candle and of the line
                    // running away to the right. No background, never straddling the line.
                    string sSty2 = e.isHigh ? label.style_label_down : label.style_label_up
                    label sl = label.new(e.refT, e.refLvl, f_lblStack(e.tag + ' SMT vs ' + e.peer, sSty2), xloc = xloc.bar_time, color = color.new(color.white, 100), style = sSty2, textcolor = sCol, size = LBL_SZ)
                    label.set_text_font_family(sl, font.family_monospace)
                    smtLabs.push(sl)
                smtShown += 1

        // ── Market Structure Shift — the primary layer ─────────────────────────────────
        // Same shared engine as the mid and low layers below, run first so it claims its levels before
        // they do and a shift is never marked twice at two resolutions.
        if showMss
            int _hMss = f_mssLayer(htfTag, mssMax, W_MSS, line.style_solid, lvlTol, htfAtr)

        // ── Mid / low timeframe layers — the fractal read ──────────────────────────────
        // The HTF frames the draw; these confirm delivery inside it. All three read the same stores
        // through the same functions, keyed by timeframe tag.
        //
        // Sweeps draw identically at every timeframe — a spent pool is a spent pool, and only the label
        // separates them. Shifts rank: HTF solid width 2, mid solid width 1, low dashed width 1.
        // The dashboard's sweep row stays a HTF read.
        if midValid and (mssMidOn or swpMidOn or fvgMidOn)
            if showFvg and fvgMidOn
                string _mdFvg = f_fvgLayer(midTag, fvgExtend + 12, false)
            if showSweeps and swpMidOn
                int _mdSwp = f_sweepLayer(midTag, maxSweeps, lvlTol)
            if showMss and mssMidOn
                int _mdMss = f_mssLayer(midTag, mssMidMax, W_REF, line.style_solid, lvlTol, midAtr)
        if lowValid and (mssLowOn or swpLowOn or fvgLowOn)
            if showFvg and fvgLowOn
                string _lwFvg = f_fvgLayer(lowTag, fvgExtend, false)
            if showSweeps and swpLowOn
                int _lwSwp = f_sweepLayer(lowTag, maxSweeps, lvlTol)
            if showMss and mssLowOn
                int _lwMss = f_mssLayer(lowTag, mssLowMax, W_REF, line.style_dashed, lvlTol, lowAtr)

        // ── Previous-day levels (PDH / PDL / PD EQ) ────────────────────────────────────
        // Fed by the daily accumulator's handover, so they share the Day Boundary setting.
        if showPD and not na(pdH) and not na(pdL)
            color pdHCol  = pdHSwept ? color.new(pdColor, 60) : pdColor
            color pdLCol  = pdLSwept ? color.new(pdColor, 60) : pdColor
            int pdRightT = time + pdExtend * msPerBar
            int pdHOrig  = na(pdHT) ? pdT : pdHT
            int pdLOrig  = na(pdLT) ? pdT : pdLT
            // PDH and PDL are liquidity — heavier width, solid while live, dotted once taken.
            // A LIVE level runs out to the right runway, because it is still a destination. A SWEPT level
            // stops at the wick that took it: the line then spans exactly the window in which the level
            // mattered, from the bar that formed it to the bar that mitigated it, and claims nothing after.
            int pdHEnd = pdHSwept and not na(pdHSweptT) ? pdHSweptT : pdRightT
            int pdLEnd = pdLSwept and not na(pdLSweptT) ? pdLSweptT : pdRightT
            if not na(pdHOrig)
                pdLines.push(line.new(pdHOrig, pdH, pdHEnd, pdH, xloc = xloc.bar_time, color = pdHCol, width = pdHSwept ? sweepWidth : W_LIQ, style = pdHSwept ? line.style_dotted : line.style_solid))
            if not na(pdLOrig)
                pdLines.push(line.new(pdLOrig, pdL, pdLEnd, pdL, xloc = xloc.bar_time, color = pdLCol, width = pdLSwept ? sweepWidth : W_LIQ, style = pdLSwept ? line.style_dotted : line.style_solid))
            string pdDate = na(pdT) ? '' : ' ' + str.format_time(pdT, 'dd/MM', 'America/New_York')
            if showPdLabels
                // Only the ANCHOR moves when a level is swept, never the side the text sits on. A live
                // level labels in the right-hand runway where its line still reaches; a swept level's line
                // stops at the wick that took it, so its label follows to that terminus rather than sitting
                // alone in empty chart with nothing tying it to the level it names.
                //
                // The side is fixed: PDH above its level, PDL below, centred on the anchor. That reads
                // the way the levels do — a ceiling and a floor — and it is the placement clear of price
                // at a sweep bar, where the candle that took the level sits on the opposite side.
                // style_label_down puts text above the anchor, style_label_up puts it below.
                int pdHLblT = pdHSwept ? pdHEnd : pdRightT
                int pdLLblT = pdLSwept ? pdLEnd : pdRightT
                label pdhL = label.new(pdHLblT, pdH, 'PDH' + pdDate + (pdHSwept ? ' swept' : ''), xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.white, 100), textcolor = pdHCol, size = LBL_SZ)
                label.set_text_font_family(pdhL, font.family_monospace)
                pdLabs.push(pdhL)
                label pdlL = label.new(pdLLblT, pdL, 'PDL' + pdDate + (pdLSwept ? ' swept' : ''), xloc = xloc.bar_time, style = label.style_label_up, color = color.new(color.white, 100), textcolor = pdLCol, size = LBL_SZ)
                label.set_text_font_family(pdlL, font.family_monospace)
                pdLabs.push(pdlL)
            if showPdEq and not na(pdEq)
                color pdEqCol = color.new(pdColor, 20)
                // PD EQ is a derived midline, not liquidity — reference width, always dotted.
                pdLines.push(line.new(na(pdT) ? time : pdT, pdEq, pdRightT, pdEq, xloc = xloc.bar_time, color = pdEqCol, width = W_REF, style = line.style_dotted))
                if showPdLabels
                    label pdeL = label.new(pdRightT, pdEq, 'PD EQ', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = pdEqCol, size = LBL_SZ)
                    label.set_text_font_family(pdeL, font.family_monospace)
                    pdLabs.push(pdeL)

        // ── Dashboard / Trade Context ──────────────────────────────────────────────────
        if showDash
            string dPos = switch dashPos
                'Top Left'     => position.top_left
                'Bottom Right' => position.bottom_right
                'Bottom Left'  => position.bottom_left
                =>                position.top_right
            string dayName = switch dayofweek(time, 'America/New_York')
                dayofweek.monday    => 'Monday'
                dayofweek.tuesday   => 'Tuesday'
                dayofweek.wednesday => 'Wednesday'
                dayofweek.thursday  => 'Thursday'
                dayofweek.friday    => 'Friday'
                dayofweek.saturday  => 'Saturday'
                =>                     'Sunday'
            bool   dBull = not na(dayOpen) and close >= dayOpen
            string dBias = na(dayOpen) ? '' : dBull ? 'BULLISH' : 'BEARISH'
            float  dEq   = not na(dayHi) and not na(dayLo) ? (dayHi + dayLo) / 2.0 : na
            string dZone = na(dEq) ? '' : close >= dEq ? 'PREMIUM' : 'DISCOUNT'
            string dSwp  = lastSweepDir == '-' or lastSweepDir == '' ? '' : str.upper(lastSweepDir)
            // Which of yesterday's pools today has taken. Reads the same state that terminates the lines.
            string dPdSwp = na(pdH) or na(pdL) ? '' : pdHSwept and pdLSwept ? 'PDH + PDL' : pdHSwept ? 'PDH TAKEN' : pdLSwept ? 'PDL TAKEN' : 'BOTH LIVE'
            // Name, instrument and timeframe, then the day's readings. A reading with nothing to say is
            // left out. No MSS, FVG or SMT row: those draw on the chart at the price they happened.
            array<string> dK = array.from('2022 MODEL+', 'INSTRUMENT', 'TIMEFRAME', 'DAY')
            array<string> dV = array.from('', syminfo.ticker, f_tfLabel(timeframe.period), str.upper(dayName))
            if dBias != ''
                dK.push('DAY BIAS')
                dV.push(dBias)
            if dZone != ''
                dK.push('ZONE')
                dV.push(dZone)
            if dSwp != ''
                dK.push('HTF SWEEP')
                dV.push(dSwp)
            if dPdSwp != ''
                dK.push('PD SWEEP')
                dV.push(dPdSwp)
            dashTbl := table.new(dPos, 2, dK.size(), frame_color = INK, frame_width = 1, border_width = 0)
            for r = 0 to dK.size() - 1
                table.cell(dashTbl, 0, r, dK.get(r), text_color = INK, text_size = dashSize, text_halign = text.align_left, text_font_family = font.family_monospace)
                table.cell(dashTbl, 1, r, dV.get(r), text_color = INK, text_size = dashSize, text_halign = text.align_left, text_font_family = font.family_monospace)

        // ── Alert layer — HTF / Mid / Low sweeps and MSS ───────────────────────────────
        // Confirmed-close-only, reusing the global snapshot arrays and the same primitives the recorders
        // call. barstate.islast is true on every realtime tick of the forming bar, so the isconfirmed
        // gate below is what makes these fire once, on the tick a bar closes — it is not redundant.
        if barstate.isconfirmed
            // Liquidity sweeps — index 1 is the freshest closed candle on that layer; index 0 (forming)
            // is never tested.
            if alertSweepOn
                if showSweeps
                    int htfSwH = f_sweptIdx(aH, aL, aC, 1, num, true)
                    int htfSwL = f_sweptIdx(aH, aL, aC, 1, num, false)
                    if not na(htfSwH) and aT.get(1) != lastSweepBsHtf
                        lastSweepBsHtf := aT.get(1)
                        alert(f_alertJson('sweep_bsl_bear_' + f_tfLabel(htfTf)), alert.freq_once_per_bar_close)
                    if not na(htfSwL) and aT.get(1) != lastSweepSsHtf
                        lastSweepSsHtf := aT.get(1)
                        alert(f_alertJson('sweep_ssl_bull_' + f_tfLabel(htfTf)), alert.freq_once_per_bar_close)
                if midValid and swpMidOn
                    int mdSwH = f_sweptIdx(mdAH, mdAL, mdAC, 1, mdAH.size(),true)
                    int mdSwL = f_sweptIdx(mdAH, mdAL, mdAC, 1, mdAH.size(),false)
                    if not na(mdSwH) and mdAT.get(1) != lastSweepBsMid
                        lastSweepBsMid := mdAT.get(1)
                        alert(f_alertJson('sweep_bsl_bear_' + f_tfLabel(midTf)), alert.freq_once_per_bar_close)
                    if not na(mdSwL) and mdAT.get(1) != lastSweepSsMid
                        lastSweepSsMid := mdAT.get(1)
                        alert(f_alertJson('sweep_ssl_bull_' + f_tfLabel(midTf)), alert.freq_once_per_bar_close)
                if lowValid and swpLowOn
                    int lwSwH = f_sweptIdx(lwAH, lwAL, lwAC, 1, lwAH.size(),true)
                    int lwSwL = f_sweptIdx(lwAH, lwAL, lwAC, 1, lwAH.size(),false)
                    if not na(lwSwH) and lwAT.get(1) != lastSweepBsLow
                        lastSweepBsLow := lwAT.get(1)
                        alert(f_alertJson('sweep_bsl_bear_' + f_tfLabel(lowTf)), alert.freq_once_per_bar_close)
                    if not na(lwSwL) and lwAT.get(1) != lastSweepSsLow
                        lastSweepSsLow := lwAT.get(1)
                        alert(f_alertJson('sweep_ssl_bull_' + f_tfLabel(lowTf)), alert.freq_once_per_bar_close)

            // Market structure shifts — f_alertMss only, restricted to a CLOSED breaking candle.
            if alertMssOn
                if showMss
                    int htfMssBear = f_alertMss(aO, aH, aL, aC, aT, true)
                    int htfMssBull = f_alertMss(aO, aH, aL, aC, aT, false)
                    if not na(htfMssBear) and htfMssBear != lastMssBearHtf
                        lastMssBearHtf := htfMssBear
                        alert(f_alertJson('mss_bear_' + f_tfLabel(htfTf)), alert.freq_once_per_bar_close)
                    if not na(htfMssBull) and htfMssBull != lastMssBullHtf
                        lastMssBullHtf := htfMssBull
                        alert(f_alertJson('mss_bull_' + f_tfLabel(htfTf)), alert.freq_once_per_bar_close)
                if midValid and mssMidOn
                    int mdMssBear = f_alertMss(mdAO, mdAH, mdAL, mdAC, mdAT, true)
                    int mdMssBull = f_alertMss(mdAO, mdAH, mdAL, mdAC, mdAT, false)
                    if not na(mdMssBear) and mdMssBear != lastMssBearMid
                        lastMssBearMid := mdMssBear
                        alert(f_alertJson('mss_bear_' + f_tfLabel(midTf)), alert.freq_once_per_bar_close)
                    if not na(mdMssBull) and mdMssBull != lastMssBullMid
                        lastMssBullMid := mdMssBull
                        alert(f_alertJson('mss_bull_' + f_tfLabel(midTf)), alert.freq_once_per_bar_close)
                if lowValid and mssLowOn
                    int lwMssBear = f_alertMss(lwAO, lwAH, lwAL, lwAC, lwAT, true)
                    int lwMssBull = f_alertMss(lwAO, lwAH, lwAL, lwAC, lwAT, false)
                    if not na(lwMssBear) and lwMssBear != lastMssBearLow
                        lastMssBearLow := lwMssBear
                        alert(f_alertJson('mss_bear_' + f_tfLabel(lowTf)), alert.freq_once_per_bar_close)
                    if not na(lwMssBull) and lwMssBull != lastMssBullLow
                        lastMssBullLow := lwMssBull
                        alert(f_alertJson('mss_bull_' + f_tfLabel(lowTf)), alert.freq_once_per_bar_close)
````
