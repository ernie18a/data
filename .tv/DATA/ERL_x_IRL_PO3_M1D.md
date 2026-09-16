<!-- tradingview-pine-id: PUB;d679eaa2dcc04a9782be9c44c13bbeba -->
<!-- tradingview-pine-version: 5.0 -->
<!-- tradingviewscripts-format: 1 -->
# ERL x IRL PO3 (M1D)

Source: https://www.tradingview.com/script/bmYj6daL-ERL-x-IRL-PO3-M1D/

## Description

ERL x IRL PO3 
Tracks one ICT sequence from start to finish: a dealing range on a higher timeframe, one side of it raided, a market structure shift on the chart, and then the PD arrays the reversal leaves behind, counted one by one into a grade. It draws the sequence as it happens and reports where you are in it. It is not a signal generator: nothing fires, and the entry is left to you.

What it does

1 · Dealing range. 
The range is found on a higher timeframe — 4H by default; 1H, 6H, Daily and Weekly are options — and followed at chart scope, so every level is anchored on the chart bar that actually printed it. It forms once, from the highest and lowest swings inside the lookback, and then it holds: sweeps, internal swings and lower highs inside it do not touch it. Both sides draw as soon as it exists — the buyside and sellside liquidity, each labelled as the external range liquidity it is, extending to the right edge. It rebuilds only after a close through a side, judged on the range timeframe's candles with the same allowance the sweep uses: the broken side stays in grey, marked broken; the last swing before the breaking leg becomes the new far side; and the new near side forms on price as a dotted line until the range timeframe confirms a swing there, then locks. The thirds are available as dotted lines, and the console names where price sits in them.

2 · Sweep. 
A wick through one side is the raid. The level belongs to the range timeframe, so the reclaim is judged there: price may close beyond the level on the chart, but not for longer than a set number of range candles, one by default. Reclaim inside that and it is a sweep; stay beyond it and it is a break. On the raid the swept side freezes as a dotted, spent line with a Sweep tag on the outside of the level — below a sellside raid, above a buyside one — and the other side is now the draw, and says so. A sweep must cross the level from inside: price sitting beyond a level after a break is never re-read as a fresh raid. An optional failed push at the far side can be required first.

3 · Market structure shift. The gate. After the sweep, the latest chart swing inside the range is the structure to break. The shift confirms on a close through it that is also back inside the swept level, and the leg from the sweep extreme to that close has to clear a displacement floor — the V — or the script keeps waiting rather than calling a grind a shift. The reference swing draws as a short solid line to the break bar, labelled MSS at the swing on its outside; it stops at the break so it is never mistaken for a level. Nothing internal is drawn before this point. An optional New York session window — RTH, the AM killzone or the PM session — restricts which shifts count; it is off by default so the whole chart can be scanned, and on for live alerts it keeps them to the session you trade.

4 · PD arrays and grade. Once the shift confirms, six candidates are counted as they form, each once:

— the displacement gap, +FVG or −FVG, with its consequent encroachment; — the volume imbalance; — the suspension block, drawn with a hard border and its midline; — the inversion gap, an opposite-direction gap the leg closed through; — the breaker; — the optimal trade entry band, 0.62 to 0.79 of the leg.

Absorption keeps one leg from counting twice: a suspension block replaces the gap and the imbalance of its own triplet, and a gap absorbs an imbalance on either of its seams. The OTE is measured the way it is drawn by hand: from the leg's own low or high — the extreme between just before the raid and the shift, not the sweep wick alone — to the first two-candle swing after the shift, a high the next candle does not exceed or a low it does not undercut. It fires when that swing confirms, not on a touch, and a dotted grey diagonal from the leg's start to its end shows the range being measured. By default the band stays at that first swing; a setting lets it follow higher swings until price has traded into it. The band is blackish grey, because it is a measurement rather than a directional array. The breaker uses the failed-block reading shared with the Unicorn Model and the Confluence Engine: an order block exists only where a displacement candle against the setup, with a real body, closed through the last chart swing and left a gap around it, and the block is the run of opposite-close candles immediately before it, wick to wick. It becomes the breaker only when a close passes back through it — the block fails and flips in place, the way a gap inverts. A block price never closed through is an order block and never a breaker. The grade is a count: three arrays for A, four for A+, both inputs. It rides on the draw's own label at the right edge — BSL · ERL · 15m A+ — so no grade tag sits inside price. When the setup ends, taken or retired, the draw line stops dotted and the grade moves to the target's swing, one ATR clear of the line, so it reads as history without sitting on price. An array a close trades through is removed from the chart; the count stands, because the array did form.

5 · Three assets, one draw. On NQ, ES and YM, micros included, the peers are read against the same range. The console reports whether each has taken the draw, names the laggard — the one still to move is the trade — and, when the chart is the laggard, watches for a catch-up gap on a 1H or 30m confirmation timeframe. A SMT is read on the bar it forms: when the chart sweeps a level and a peer holds its own, a solid line runs from the range swing to the sweep extreme — the chart's lower low against the peer's higher low — and the Sweep tag names the peer that held: Sweep · SMT YM. If every peer later takes its level the line is removed and the tag reverts, because the divergence failed.

6 · PO3 candle. 
The live candle of the range timeframe, drawn beside price as a proper candle with a hard border and wicks, offset to the right so it clears the level labels, with its open, high, low and close carried back as lines and tagged. A PO3 price that sits on a live range level merges into that level's label, so nothing stacks. Hidden when the chart is not below the range timeframe.

7 · Console. Two named columns, all in ink. Under the chart timeframe: the verdict and grade; the range and where price sits in it; the draw with its distance and the risk-to-reward from the nearest array; Sweep · MSS · OTE as three ticks. Under the two peers: the draw check; which peers have taken the draw, with any SMT; the catch-up gap when the chart lags; the last completed setup; the range candle's countdown and range. Silent rows are dropped.

Visual grammar

Purple marks bullish arrays, magenta bearish; liquidity, structure and text are black, and the consequent encroachment is dotted grey. A live level is solid; a spent one is dotted. Gaps fill at a light opacity you set; blocks carry a hard border. Every label sits in clear air by construction, not by luck: a level's name sits at the swing that made the level, on its outside — above a high, below a low — where nothing has traded; the Sweep tag at the raid's wick, the same way; the MSS at its reference swing; the OTE bold in the middle of its band; the live range names and every zone caption at the right edge past the last candle. The OTE band is blackish grey. Arrays price has closed through are removed, not faded, and the last five setups per direction stay on the chart as history.

Method & repainting

Every detection path — the range swings, the sweep and its reclaim, the shift, every array, the breaker search and the peer reads — evaluates on closed bars only. The range timeframe is followed at chart scope with no security call, so a range level is fixed to the bar that printed it and never moves. The peers and the catch-up timeframe are read from completed candles with a non-repainting call; the peers are also read on the chart timeframe, on closed bars, so a SMT resolves on the bar it forms. Swings confirm a set number of bars after they print; that is a fixed delay, not a revision.

Two things update live. The console reads current price, and the PO3 candle is the forming candle of the range timeframe, rebuilt on every tick and never left as history.

Settings

Range timeframe, swing strength, lookback and minimum size; the reclaim allowance, sweep expiry, setup retirement and how many setups to keep; the displacement floor; the session window; the gap height floor, OTE band, breaker drawing mode and order-block body; the grade thresholds and minimum risk-to-reward; the peer cross-check and catch-up timeframe; every drawn element individually; the PO3 candle; label size, right offset and fill opacities. Eight alerts: bullish and bearish shift, grade A, grade A+, and the catch-up gap.

Disclaimer

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
// ERL x IRL PO3 (M1D)
//
// Modules: dealing range on a higher timeframe (followed at chart scope, levels anchored on the bar
// that printed them) · failed push · sweep · MSS with displacement gate and NY session window ·
// arrays +FVG / VI / SB / IFVG / Breaker / OTE, graded · position in range · RR to draw ·
// NQ / ES / YM cross-check with catch-up gap · console · alerts.
//
//@version=6
indicator('ERL x IRL PO3 (M1D)', 'ERLxIRL', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// The breaker and lookback-sweep searches walk bar history from the MSS back to the swings they
// reference; give the price series enough history for that walk on a wide range.
max_bars_back(open, 600)
max_bars_back(high, 600)
max_bars_back(low, 600)
max_bars_back(close, 600)
// `time` alone goes to the ceiling: every drawing here is anchored on a stored origin, and placing that
// x walks `time` back to it. 600 covered a 5m chart; on 1m yesterday's swing is ~1,400 bars back and the
// script would stop with "requested historical offset is beyond the historical buffer's limit".
max_bars_back(time, 5000)

// ============================================================================
// VISUAL STANDARD — see the indicator-visual-style skill
// ============================================================================
// Bullish purple, bearish magenta, everything neutral black, against a WHITE chart.
// Black is the hex. Pine's color.black is #363A45 slate grey and renders grey on white.
const color C_BULL = #7246CE
const color C_BEAR = #DB1D9C
const color C_INK  = #000000
const color C_GRAY = #787B86
const color C_NONE = color.new(#FFFFFF, 100)

// ============================================================================
// INPUTS
// ============================================================================
const string G_RANGE = 'Dealing range (higher timeframe)'
const string G_SETUP = 'Setup (chart timeframe)'
const string G_SESS  = 'Session (New York time)'
const string G_ARR   = 'PD arrays and grade'
const string G_XC    = 'Cross-check NQ · ES · YM'
const string G_PO3   = 'PO3 candle (range timeframe)'
const string G_SHOW  = 'Display'
const string G_STYLE = 'Style'

string rangeTf      = input.timeframe('240', 'Range timeframe',                         group = G_RANGE,
     tooltip = 'The draw is found here, executed on the chart. 1H · 4H · 6H · Daily · Weekly.')
int    htfLen       = input.int(3,     'Range swing strength (candles each side)',       minval = 1,  maxval = 10,  group = G_RANGE)
int    lookbackCdl  = input.int(60,    'Range lookback (range-timeframe candles)',       minval = 10, maxval = 300, group = G_RANGE,
     tooltip = 'The window the FIRST range is built from: its highest and lowest swings. After that the range holds until a close through a side, and rebuilds from the breaking leg.')
float  minRangeAtr  = input.float(2.0, 'Minimum range (x ATR14)',                        minval = 0,  step = 0.5,   group = G_RANGE)
bool   requirePush  = input.bool(false, 'Require a failed push at the far side',                                    group = G_RANGE,
     tooltip = 'Off: the sweep is the trigger and whatever forms after it is tracked. On: the range must first have pushed at the far side and failed.')
int    pushReachPct = input.int(75,    'Failed push must reach (% of range)',            minval = 0,  maxval = 100, group = G_RANGE)

int   pivLen      = input.int(3,     'Execution swing strength (bars each side)',    minval = 1,  maxval = 20,   group = G_SETUP)
float minDispAtr  = input.float(1.0, 'MSS displacement from the sweep (x ATR14)',   minval = 0,  step = 0.25,   group = G_SETUP,
     tooltip = 'The V. The leg from the sweep extreme to the MSS close has to clear this, or the shift is a grind and the script keeps waiting.')
int   reclaimCdl  = input.int(1,     'Sweep must reclaim within (range-timeframe candles)', minval = 1, maxval = 10, group = G_SETUP,
     tooltip = 'A wick through the level is the sweep. The level belongs to the range timeframe, so the reclaim is judged there: price may close beyond the level on the chart, but not for longer than this many range candles — after that the raid is a break.')
int   sweepExpiry = input.int(150,   'Sweep expires after (bars) without MSS',       minval = 5,  maxval = 1000, group = G_SETUP)
int   setupMaxAge = input.int(300,   'Retire a live setup after (bars from MSS)',    minval = 20, maxval = 2000, group = G_SETUP)
int   keepSetups  = input.int(5,     'Keep last setups per direction',               minval = 1,  maxval = 10,   group = G_SETUP)
bool  showEarly   = input.bool(false, 'Show the sweep before the MSS confirms',                                  group = G_SETUP)

string sessMode = input.string('Off', 'MSS must confirm inside',
     options = ['Off', 'RTH 09:30-16:00', 'NY AM KZ 08:30-11:00', 'NY PM 13:30-16:00'], group = G_SESS,
     tooltip = 'New York time. Off shows every setup, for scanning back through the chart. A window keeps the live alerts to the session you trade. Ignored on Daily and higher.')

float minGapAtr = input.float(0.1,  'Minimum gap height (x ATR14)', minval = 0, step = 0.05, group = G_ARR,
     tooltip = 'Applies to the displacement gap, the volume imbalance and the suspension block.')
float oteFrom   = input.float(0.62, 'OTE band from',                minval = 0.5, maxval = 1, step = 0.01, group = G_ARR)
float oteTo     = input.float(0.79, 'OTE band to',                  minval = 0.5, maxval = 1, step = 0.01, group = G_ARR)
string oteSwing = input.string('Range timeframe', 'OTE leg ends at the first swing of', options = ['Range timeframe', 'Chart (two-candle)'], group = G_ARR,
     tooltip = 'Range timeframe: the leg ends at the first swing the range timeframe confirms after the MSS — the swing you would draw the fib to on the higher timeframe. Chart: the first two-candle swing on this chart, which on a low timeframe can be a very small leg.')
bool  oteRatchet = input.bool(false, 'OTE follows higher swings until touched', group = G_ARR,
     tooltip = 'Off: the leg ends at the FIRST two-candle swing after the MSS and the band stays there. On: each higher swing re-measures the band until price has traded into it.')
int   oteLook   = input.int(75, 'OTE leg lookback (bars)', minval = 5, maxval = 300, group = G_ARR,
     tooltip = 'A cap. The leg starts at the lowest low (highest high) between just before the first breach of the level and the MSS bar, but never further back than this many bars. It is the 0 of the fib.')
string brkMode  = input.string('Levels', 'Breaker drawing', options = ['Levels', 'Zone'], group = G_ARR)
float obDispAtr = input.float(1.0, 'Order block displacement body (x ATR14)', minval = 0.1, step = 0.1, group = G_ARR,
     tooltip = 'The Unicorn / Confluence Engine reading. An order block exists only where a candle with a body this large closed through the last chart swing and left a gap behind it. The breaker is that block once a close passes back through it.')
int   gradeA    = input.int(3, 'Arrays for grade A',  minval = 1, maxval = 6, group = G_ARR)
int   gradeAp   = input.int(4, 'Arrays for grade A+', minval = 1, maxval = 6, group = G_ARR,
     tooltip = 'Six candidates: +FVG, VI, SB, IFVG, Breaker, OTE. A suspension block replaces the gap and imbalance of its own triplet; a gap absorbs the imbalance on its own seams.')
float minRR     = input.float(2.0, 'Minimum risk-to-reward to the draw', minval = 0.5, step = 0.5, group = G_ARR,
     tooltip = 'Measured from the nearest internal array to the target, with the stop at the sweep extreme. A minimum, not a target.')

bool   xcOn   = input.bool(true, 'Cross-check the peers', group = G_XC,
     tooltip = 'NQ pairs with ES and YM, ES with NQ and YM, YM with NQ and ES, micros included. Off automatically on anything else.')
string gapTf  = input.string('60', 'Catch-up gap timeframe', options = ['30', '60'], group = G_XC,
     tooltip = 'When the chart is the laggard, a fair value gap here in the catch-up direction, formed after the others took the level, is the confirmation.')

bool showFvg     = input.bool(true, 'Displacement gap (+FVG / -FVG)', group = G_SHOW)
bool showVi      = input.bool(true, 'Volume imbalance (VI)',           group = G_SHOW)
bool showSb      = input.bool(true, 'Suspension block (SB+ / SB-)',    group = G_SHOW)
bool showIfvg    = input.bool(true, 'IFVG',                            group = G_SHOW)
bool showBrk     = input.bool(true, 'Breaker',                         group = G_SHOW)
bool showOte     = input.bool(true, 'OTE',                             group = G_SHOW)
bool showCe      = input.bool(true, 'Consequent encroachment (gap, IFVG, SB midline)', group = G_SHOW)
bool drawRange   = input.bool(true, 'Dealing range (both sides, before any setup)', group = G_SHOW,
     tooltip = 'The range draws as soon as it exists. The raided side freezes as the spent sweep line, the other side is the draw. A side that breaks stays up alone in grey until the range timeframe prints a new swing.')
bool showSmt     = input.bool(true, 'SMT on chart (peer held the swept level)', group = G_SHOW,
     tooltip = 'A line across the chart\'s own two lows (or highs) at the sweep, tagged with the peer that did not take its level. Removed if every peer takes it.')
bool showMssLvl  = input.bool(false, 'The level a close must break for the MSS', group = G_SHOW,
     tooltip = 'Marks the chart swing a close has to clear for the shift to confirm, from the sweep until the MSS prints. It follows the newest qualifying swing, and is not drawn when that swing sits at or past the draw.')
bool showThirds  = input.bool(false, 'Range thirds (dotted)',          group = G_SHOW)

// ── The liquidity POOLS either side of the range. The dealing range gives two levels - its own
//    edges - and that was every level this script drew. These are the pools price is actually
//    reaching for between them. Ported from BSL/SSL Liquidity (M1D): the same pivot pools, the
//    same equal-level merge, the same previous-period levels, the same NEW YORK clock.
string G_LIQ = 'Liquidity pools'
bool  poolsOn   = input.bool(true,  'Draw liquidity pools', group = G_LIQ, tooltip = 'The dealing range draws its two edges and nothing else. These are the pools between and beyond them - the swing highs and lows price is reaching for. Solid while live, dotted once taken, the same language as every other level here.')
bool  poolSwing = input.bool(true,  'Swing pools',    inline = 'ps', group = G_LIQ)
bool  poolPd    = input.bool(true,  'PDH / PDL',      inline = 'ps', group = G_LIQ)
bool  poolPw    = input.bool(true,  'PWH / PWL',      inline = 'ps', group = G_LIQ)
bool  poolPaired= input.bool(true,  'Swing pools must be PAIRED (REH / REL)', group = G_LIQ, tooltip = 'A lone swing high is not resting liquidity - it is one candle. A pool needs TWO pivots within the tolerance below, the Liquidity Levels+ definition. Off draws every swing, which is what fills the chart with lines.')
bool  poolOutside= input.bool(true, 'External only - nothing inside the dealing range', group = G_LIQ, tooltip = 'ERL is EXTERNAL range liquidity. A pool between the two range edges is internal and is not drawn; the range edges themselves already say where the draw is.')
float poolEqAtr = input.float(0.20, 'Equal-level tolerance (x ATR)', minval = 0.02, step = 0.05, group = G_LIQ, tooltip = 'Two swings within this much of one another are ONE pool, and it is labelled REH or REL. This is what stops a dozen near-identical highs drawing as a dozen lines.')
int   poolMax   = input.int(5,      'Max pools per side', minval = 1, maxval = 12, group = G_LIQ, tooltip = 'Nearest to price first. A cap, not a filter - the pools beyond it still exist, they are just not drawn.')
float poolMaxAtr= input.float(8.0,  'Max distance from price (x ATR)', minval = 1.0, step = 0.5, group = G_LIQ, tooltip = 'A pool further than this is not in play on this chart and is not drawn.')
bool  poolKeep  = input.bool(false, 'Keep taken liquidity on the chart', group = G_LIQ, tooltip = 'Off: liquidity that has been run is GONE - pools, both dealing-range edges and the broken side. A level that has been taken is not a draw any more and drawing it dotted still leaves it on the chart to be read as one. On: it stays, dotted and grey, which is the record of where price has already been.')
bool showConsole = input.bool(true, 'Console',                         group = G_SHOW)
string conPos    = input.string('Top right', 'Console position', options = ['Top right', 'Top left', 'Bottom right', 'Bottom left'], group = G_SHOW)

bool  showPo3     = input.bool(true, 'Draw the current range-timeframe candle beside price', group = G_PO3,
     tooltip = 'The PO3 read: the live candle of the range timeframe, rebuilt on every tick, never left as history. Hidden when the chart is not below the range timeframe.')
int   po3Gap      = input.int(10, 'Gap past the level labels (bars)', minval = 1, maxval = 500, group = G_PO3, tooltip = 'Counted from the right offset where the level labels sit, so the candle always clears them.')
int   po3Wide     = input.int(6,  'Candle width (bars)',        minval = 1, maxval = 100, group = G_PO3)
color po3Up       = input.color(#FFFFFF, 'Up body',   group = G_PO3, inline = 'po3')
color po3Dn       = input.color(#4A4A4A, 'Down body', group = G_PO3, inline = 'po3')
color po3Edge     = input.color(#000000, 'Outline / wick', group = G_PO3)
bool  po3Levels   = input.bool(true, 'Open / high / low / close lines', group = G_PO3)
bool  po3Divider  = input.bool(true, 'Open divider',                    group = G_PO3)
bool  po3FullDiv  = input.bool(true, 'Divider runs full height',        group = G_PO3)
bool  po3Tags     = input.bool(true, 'Price tags',                      group = G_PO3)

string labelSize = input.string('small', 'Label text size', options = ['tiny', 'small', 'normal', 'large'], group = G_STYLE)
int   runwayBars = input.int(10, 'Right offset (bars)',       minval = 0, maxval = 100, group = G_STYLE)
int   liqWidth   = input.int(2,  'Liquidity line width',      minval = 1, maxval = 4,   group = G_STYLE)
color liqCol     = input.color(#000000, 'Liquidity line colour',  group = G_STYLE,
     tooltip = 'The two dealing range sides, the swept level and the draw. A side left behind by a break stays grey, and every name stays black.')
// Opacity, not transparency: the number you set is how solid the fill is.
int   gapOpac    = input.int(25, 'Gap fill opacity (%)',      minval = 0, maxval = 100, group = G_STYLE, tooltip = '+FVG / -FVG, VI and IFVG. The house figure is 35; 25 is a shade lighter.')
int   blockOpac  = input.int(12, 'Block fill opacity (%)',    minval = 0, maxval = 100, group = G_STYLE, tooltip = 'SB and the breaker zone. The border stays solid.')
color oteCol     = input.color(#4A4A4A, 'OTE band colour',       group = G_STYLE, tooltip = 'Blackish grey by default: the OTE is a measurement, not a directional array, so it does not wear the direction colour.')
int   bandOpac   = input.int(20, 'OTE band opacity (%)',      minval = 0, maxval = 100, group = G_STYLE)
int   gapFill    = 100 - gapOpac
int   blockFill  = 100 - blockOpac
int   bandFill   = 100 - bandOpac

// ============================================================================
// RESOLVED CONSTANTS
// ============================================================================
//@function Resolves the label size input once.
//@param s (string) The input value
//@returns (string) A size.* constant
f_lblSize(string s) =>
    switch s
        'tiny'  => size.tiny
        'small' => size.small
        'large' => size.large
        =>         size.normal

string LBL_SZ   = f_lblSize(labelSize)
const int CON_COLS = 2   // Setup · Peers & context
const int CON_ROWS = 5   // name-over-value pairs down each column, under a header row
int    chartSec = timeframe.in_seconds(timeframe.period)
int    msPerBar = chartSec * 1000
int    htfSec   = timeframe.in_seconds(rangeTf)
// The reclaim allowance in chart bars: one range candle's worth of chart bars, times the input.
int    reclaimBars = math.max(1, math.round(reclaimCdl * math.max(1.0, htfSec / timeframe.in_seconds())))
bool   sameTf   = htfSec <= chartSec
int    htfMs    = (sameTf ? chartSec : htfSec) * 1000
bool   gapOnChart = timeframe.in_seconds(gapTf) <= chartSec

//@function Names a timeframe the way a trader says it.
//@param sec (int) The timeframe in seconds
//@returns (string) e.g. 5m, 1H, Daily
f_tfName(int sec) =>
    switch
        sec < 60             => str.tostring(sec) + 's'
        sec < 3600           => str.tostring(sec / 60) + 'm'
        sec < 86400          => str.tostring(sec / 3600) + 'H'
        sec == 86400         => 'Daily'
        sec < 604800         => str.tostring(sec / 86400) + 'D'
        sec == 604800        => 'Weekly'
        =>                      'Monthly'

string TF_NAME  = f_tfName(chartSec)
string RTF_NAME = f_tfName(htfSec)
string GTF_NAME = f_tfName(timeframe.in_seconds(gapTf))

string sessStr = switch sessMode
    'NY AM KZ 08:30-11:00' => '0830-1100'
    'NY PM 13:30-16:00'    => '1330-1600'
    =>                        '0930-1600'

int  sessT  = time(timeframe.period, sessStr, 'America/New_York')
bool inSess = sessMode == 'Off' or not timeframe.isintraday or not na(sessT)

// ── Peers, resolved from the symbol root ──
string root    = syminfo.root
bool   isIndex = root == 'NQ' or root == 'MNQ' or root == 'ES' or root == 'MES' or root == 'YM' or root == 'MYM'
string peer1Sym = switch root
    'NQ'  => 'CME_MINI:ES1!'
    'MNQ' => 'CME_MINI:ES1!'
    'ES'  => 'CME_MINI:NQ1!'
    'MES' => 'CME_MINI:NQ1!'
    'YM'  => 'CME_MINI:NQ1!'
    'MYM' => 'CME_MINI:NQ1!'
    =>       syminfo.tickerid
string peer2Sym = switch root
    'YM'  => 'CME_MINI:ES1!'
    'MYM' => 'CME_MINI:ES1!'
    =>       isIndex ? 'CBOT_MINI:YM1!' : syminfo.tickerid
string peer1Name = switch root
    'NQ'  => 'ES'
    'MNQ' => 'ES'
    =>       'NQ'
string peer2Name = root == 'YM' or root == 'MYM' ? 'ES' : 'YM'
string selfName  = root == 'MNQ' ? 'NQ' : root == 'MES' ? 'ES' : root == 'MYM' ? 'YM' : root
bool   xcLive    = xcOn and isIndex

float atr     = ta.atr(14)
// Equal-level work is STRUCTURAL, so it is measured on the range timeframe, not the chart's. On a
// 1m chart ta.atr(14) spans fourteen minutes: scaled by 0.20 it made the merge tolerance smaller
// than a tick, so a band of near-identical highs drew as a line each instead of one EQH. Capped
// because the length is a bar count and a deep intraday chart would otherwise ask for thousands.
int   atrStructLen = math.min(500, math.max(14, 14 * htfSec / chartSec))
float atrStruct    = ta.atr(atrStructLen)
float ph      = ta.pivothigh(high, pivLen, pivLen)
float pl      = ta.pivotlow(low, pivLen, pivLen)
// The OTE leg's swings, the two-candle reading: a high the candle after it does not exceed, above
// the candle before it — the top of an up move with the turn-down after it. Ties on the turn count,
// so a double-top candle pair still reads as one swing. Mirror for the low. Known one bar after.
float ph2     = high[1] >= high and high[1] > high[2] ? high[1] : na
float pl2     = low[1] <= low and low[1] < low[2] ? low[1] : na

// ── The range timeframe, followed at chart scope so every level knows its bar (no request) ──
int  htfT      = sameTf ? time : time(rangeTf)
bool newCandle = htfT != htfT[1]

// ── Peers and the catch-up timeframe: the previous COMPLETED candle, non-repainting ──
[p1H, p1L, p1T] = request.security(peer1Sym, rangeTf, [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[p2H, p2L, p2T] = request.security(peer2Sym, rangeTf, [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[gH1, gL1, gH3, gL3, gT1] = request.security(syminfo.tickerid, gapTf, [high[1], low[1], high[3], low[3], time[1]], lookahead = barmerge.lookahead_on)
// The peers on the chart timeframe, so a SMT is read on the bar it forms rather than on the next range candle.
[q1H, q1L] = request.security(peer1Sym, timeframe.period, [high, low])
[q2H, q2L] = request.security(peer2Sym, timeframe.period, [high, low])
bool p1New = p1T != p1T[1]
bool p2New = p2T != p2T[1]
bool gNew  = gT1 != gT1[1]

// ============================================================================
// STORES
// ============================================================================
const int POOL_CAP   = 80
const int SWING_CAP  = 60
const int CANDLE_CAP = 400
const int ZONE_CAP   = 120

// A confirmed swing. bi and tm are the CHART bar that printed it; ord orders swings of one store
// (the range-timeframe candle count for higher-timeframe swings, the bar index for chart swings);
// ct is the range-timeframe candle's open time; raid says the swing ran the prior extreme and
// closed back inside it — a failed push.
type Swing
    float px
    int   tm
    int   bi
    int   ord
    int   ct
    bool  raid = false

// One pool of resting liquidity. `touches` counts the swings that merged into it - two or more and
// it is an EQH/EQL rather than a lone swing, which is the distinction that makes a level worth
// reaching for. `taken` is set the moment price trades through it, wick included: a raid is a raid
// whether or not the candle closed there.
type Pool
    float  px
    int    tm
    bool   isHigh
    bool   taken   = false
    int    touches = 1
    string origin  = 'Swing'
    line   ln      = na
    label  lb      = na

// One completed candle of a peer on the range timeframe.
type Candle
    float h
    float l
    int   t

// An imbalance the reversal can count. kind: 0 wick gap (FVG) · 1 volume imbalance · 2 suspension
// block. bi is the candle the kind is keyed on — the gap's middle candle, the imbalance's later
// candle, the block's third candle — so absorption between kinds is an index comparison. det is the
// bar it was detected on. mit flips once a close has traded through the far edge.
type Zone
    int   kind
    float top
    float bot
    int   tm
    int   bi
    int   det
    bool  mit = false

//@variable Range-timeframe candles followed at chart scope: extremes, where each printed, closes.
var array<float> hH    = array.new<float>()
var array<float> hL    = array.new<float>()
var array<float> hC    = array.new<float>()
var array<int>   hHiTm = array.new<int>()
var array<int>   hHiBi = array.new<int>()
var array<int>   hLoTm = array.new<int>()
var array<int>   hLoBi = array.new<int>()
var array<int>   hCt   = array.new<int>()
var int          htfN  = 0

//@variable The candle currently forming on the range timeframe.
var float curO    = na
var float curH    = na
var float curL    = na
var float curC    = na
var int   curHiTm = na
var int   curHiBi = na
var int   curLoTm = na
var int   curLoBi = na
var int   curCt   = na

//@variable Confirmed range-timeframe swings (the dealing range) and chart swings (execution).
var array<Swing> hHi = array.new<Swing>()
var array<Swing> hLo = array.new<Swing>()
var array<Swing> cHi = array.new<Swing>()
var array<Swing> cLo = array.new<Swing>()

//@variable Resting liquidity pools - merged swing EQH/EQL plus the previous day and week.
var array<Pool> pools = array.new<Pool>()

//@variable Peer candles on the range timeframe.
var array<Candle> peer1 = array.new<Candle>()
var array<Candle> peer2 = array.new<Candle>()

//@variable Completed fair value gaps on the catch-up timeframe: times, by direction.
var array<int> gapUpTm = array.new<int>()
var array<int> gapDnTm = array.new<int>()

//@variable Bullish and bearish imbalances on the chart, chronological.
var array<Zone> bullZ = array.new<Zone>()
var array<Zone> bearZ = array.new<Zone>()

//@variable The last pivLen + 1 bars, index 0 = this bar, for the OTE touch test.
var array<float> recLow  = array.new<float>()
var array<float> recHigh = array.new<float>()

//@function The most extreme swing at or after an ordinal — highest for d = 1, lowest for d = -1.
//@param sw (array<Swing>) The store
//@param minOrd (int) Oldest ordinal to consider
//@param d (int) 1 for highest, -1 for lowest
//@returns (float) The extreme, or na
f_extreme(array<Swing> sw, int minOrd, int d) =>
    float r = na
    int n = sw.size()
    if n > 0
        for i = 0 to n - 1
            Swing s = sw.get(i)
            if s.ord >= minOrd and (na(r) or d * (s.px - r) > 0)
                r := s.px
    r

// ── The dealing range: forms once from the lookback's extreme swings, then HOLDS. It rebuilds
//    only after a close through a side, judged with the same reclaim allowance the sweep uses:
//    the broken side is spent, the last swing before the breaking leg becomes the new far side,
//    and the near side FORMS on price until the range timeframe confirms a swing there. ──
var float drHiPx   = na
var int   drHiTm   = na
var int   drHiBi   = na
var int   drHiCt   = na
var bool  drLoRaided = false
var bool  drHiRaided = false
var float drLoPx   = na
var int   drLoTm   = na
var int   drLoBi   = na
var int   drLoCt   = na
var bool  drHiPend = false
var bool  drLoPend = false
var int   drOutHi  = 0
var int   drOutLo  = 0
var int   drBreakBi  = na
var int   drBrokeDir = 0     // 1 the high broke, -1 the low broke, 0 neither
var float drBrokePx  = na
var int   drBrokeTm  = na

//@function The most extreme swing at or after an ordinal, as a swing.
//@param sw (array<Swing>) The store
//@param minOrd (int) Oldest ordinal to consider
//@param d (int) 1 for highest, -1 for lowest
//@returns (Swing) The swing, or na
f_extSwing(array<Swing> sw, int minOrd, int d) =>
    Swing r = na
    int n = sw.size()
    if n > 0
        for i = 0 to n - 1
            Swing x = sw.get(i)
            if x.ord >= minOrd and (na(r) or d * (x.px - r.px) > 0)
                r := x
    r

//@function The most recent swing at or before a bar.
//@param sw (array<Swing>) The store
//@param maxBi (int) The bar
//@returns (Swing) The swing, or na
f_lastSwing(array<Swing> sw, int maxBi) =>
    Swing r = na
    int n = sw.size()
    if n > 0
        for i = 0 to n - 1
            Swing x = sw.get(i)
            if x.bi <= maxBi and (na(r) or x.bi > r.bi)
                r := x
    r

//@function Appends a swing and prunes past the cap.
//@param sw (array<Swing>) The store
//@param s (Swing) The swing
//@returns (void)
f_pushSwing(array<Swing> sw, Swing s) =>
    sw.push(s)
    if sw.size() > SWING_CAP
        sw.shift()

//@function Appends an imbalance to its store and prunes the oldest past the cap.
//@param store (array<Zone>) The direction's store
//@param kind (int) 0 gap · 1 volume imbalance · 2 suspension block
//@param top (float) Top
//@param bot (float) Bottom
//@param tm (int) Origin time
//@param bi (int) Key candle index
//@returns (void)
f_pushZone(array<Zone> store, int kind, float top, float bot, int tm, int bi) =>
    store.push(Zone.new(kind, top, bot, tm, bi, bar_index))
    if store.size() > ZONE_CAP
        store.shift()

//@function Marks stored imbalances a close has traded through — a gap that failed before the MSS
//          must not be counted as the reversal's displacement.
//@param store (array<Zone>) The store
//@param d (int) The store's direction
//@returns (void)
f_markMitigated(array<Zone> store, int d) =>
    int n = store.size()
    if n > 0
        for i = 0 to n - 1
            Zone z = store.get(i)
            if not z.mit
                float far = d > 0 ? z.bot : z.top
                if d * (close - far) < 0
                    z.mit := true

//@function Appends a peer candle and prunes past the cap.
//@param pc (array<Candle>) The peer's store
//@param h (float) High
//@param l (float) Low
//@param t (int) Candle open time
//@returns (void)
f_pushCandle(array<Candle> pc, float h, float l, int t) =>
    if not na(h) and not na(t)
        pc.push(Candle.new(h, l, t))
        if pc.size() > CANDLE_CAP
            pc.shift()

//@function Tests whether the candle R back in a range-timeframe series is a confirmed pivot.
//@param v (array<float>) Highs (isHigh) or lows
//@param isHigh (bool) Pivot high or pivot low
//@returns (int) The array index of the pivot, or -1
f_htfPivot(array<float> v, bool isHigh) =>
    int n   = v.size()
    int idx = n - 1 - htfLen
    int r   = -1
    if idx >= htfLen
        float c = v.get(idx)
        bool ok = true
        for i = idx - htfLen to idx + htfLen
            if i != idx
                float o = v.get(i)
                if isHigh ? o >= c : o <= c
                    ok := false
        if ok
            r := idx
    r

// ============================================================================
// DRAWING HELPERS
// ============================================================================
//@function A transparent monospace callout.
//@param x (int) Bar time
//@param y (float) Price
//@param txt (string) Text
//@param sty (string) A label.style_* constant
//@returns (label) The label
f_lbl(int x, float y, string txt, string sty) =>
    label l = label.new(x, y, txt, xloc = xloc.bar_time, style = sty, color = C_NONE,
         textcolor = C_INK, size = LBL_SZ, textalign = text.align_left)
    label.set_text_font_family(l, font.family_monospace)
    l

//@function A horizontal level in bar time.
//@param x1 (int) Start time
//@param x2 (int) End time
//@param y (float) Price
//@param c (color) Colour
//@param w (int) Width
//@param sty (string) A line.style_* constant
//@returns (line) The line
f_level(int x1, int x2, float y, color c, int w, string sty) =>
    line.new(x1, y, x2, y, xloc = xloc.bar_time, color = c, width = w, style = sty)

//@function A zone box plus its caption label on the centre line past the right edge.
//@param x1 (int) Origin time
//@param top (float) Top
//@param x2 (int) Right edge time
//@param bot (float) Bottom
//@param base (color) Direction colour
//@param opac (int) Fill transparency
//@param hardEdge (bool) True draws a full-opacity border (blocks)
//@param cap (string) Caption
//@returns ([box, label]) The box and its caption
f_zone(int x1, float top, int x2, float bot, color base, int opac, bool hardEdge, string cap) =>
    color fill = color.new(base, opac)
    color edge = hardEdge ? color.new(base, 0) : fill
    box b = box.new(x1, top, x2, bot, xloc = xloc.bar_time, border_color = edge, border_width = 1,
         border_style = line.style_solid, bgcolor = fill)
    // A PD array's name sits in the MIDDLE of its own zone, the way the OTE band's does - not
    // hung off the right edge, where it reads as belonging to whatever is beside the zone rather
    // than to the zone itself.
    label l = f_lbl(int(math.avg(x1, x2)), math.avg(top, bot), cap, label.style_label_center)
    [b, l]

//@function Re-centres a zone's caption in its box. Called wherever the box's right edge moves, so
//          the name travels with the zone instead of staying where it was first drawn.
//@param l (label) The caption.
//@param b (box) Its zone.
//@returns (bool) Always true.
f_zoneCap(label l, box b) =>
    if not na(l) and not na(b)
        label.set_xy(l, int(math.avg(box.get_left(b), box.get_right(b))), math.avg(box.get_top(b), box.get_bottom(b)))
    true

// ============================================================================
// THE SETUP
// ============================================================================
// state: 0 idle · 1 armed (range + failed push) · 2 swept · 3 live (MSS confirmed) · 4 frozen · 5 dead
type Setup
    int   dir
    int   state        = 0
    float liq          = na
    int   liqTm        = na
    int   liqBi        = na
    int   liqCt        = na
    float tgt          = na
    int   tgtTm        = na
    int   tgtBi        = na
    int   tgtCt        = na
    float pushPx       = na
    int   pushTm       = na
    int   pushBi       = na
    bool  justArmed    = false
    float sweepPx      = na
    int   sweepTm      = na
    int   sweepBi      = na
    // The candle that first wicked the level: the level line stops here and the Sweep tag sits here.
    int   firstSweepTm = na
    // The chart swing the SMT line starts from: the last same-side swing before the raid.
    int   smtFromTm    = na
    float smtFromPx    = na
    int   firstSweepBi = na
    int   outsideBars  = 0
    float mssRef       = na
    int   mssRefTm     = na
    int   mssRefBi     = na
    int   mssTm        = na
    int   mssBi        = na
    bool  waitDisp     = false
    bool  hasFvg       = false
    bool  hasVi        = false
    bool  hasSb        = false
    bool  hasIfvg      = false
    bool  hasBrk       = false
    bool  hasOte       = false
    int   fvgBi        = na
    int   viBi         = na
    int   sbBi         = na
    float fvgTop       = na
    float fvgBot       = na
    float viTop        = na
    float viBot        = na
    float sbTop        = na
    float sbBot        = na
    float ifvgTop      = na
    float ifvgBot      = na
    bool  brkPending   = false
    float brkTop       = na
    float brkBot       = na
    int   brkTm        = na
    float legExt       = na
    float legStart     = na
    int   legStartTm   = na
    float oteTop       = na
    float oteBot       = na
    bool  oteTouched   = false
    int   grade        = 0
    bool  drawn        = false
    // cross-check
    bool  xcSet        = false
    float p1TgtLvl     = na
    float p2TgtLvl     = na
    float p1LiqLvl     = na
    float p2LiqLvl     = na
    int   tgtWinEnd    = na
    int   liqWinEnd    = na
    int   p1TgtTaken   = na
    int   p2TgtTaken   = na
    int   p1LiqTaken   = na
    int   p2LiqTaken   = na
    bool  selfTgtTaken = false
    bool  catchUp      = false
    int   xcTgtCt      = na
    int   xcLiqCt      = na
    string outcome     = ''
    string gradeTxt    = '0/6'
    // drawings
    line  fvgCe        = na
    line  sbCe         = na
    line  ifvgCe       = na
    line  liqLn        = na
    label liqLbl       = na
    line  tgtLn        = na
    label tgtLbl       = na
    line  mssLn        = na
    label mssLbl       = na
    line  mssPendLn    = na
    label mssPendLbl   = na
    line  smtLn        = na
    label smtLbl       = na
    box   fvgBx        = na
    label fvgLbl       = na
    box   viBx         = na
    label viLbl        = na
    box   sbBx         = na
    label sbLbl        = na
    box   ifvgBx       = na
    label ifvgLbl      = na
    line  brkP         = na
    line  brkD         = na
    line  brkCe        = na
    label brkLbl       = na
    box   brkBx        = na
    box   oteBx        = na
    label oteLbl       = na
    line  oteLeg       = na

// Per-bar events, read by the alert layer.
type Ev
    bool swept   = false
    bool mss     = false
    bool a       = false
    bool ap      = false
    bool catchUp = false
    bool broke   = false
    int  brokeCt = na

//@function Deletes the displacement gap's drawing and clears its reference.
//@param s (Setup) The setup
//@returns (void)
f_eraseFvg(Setup s) =>
    box.delete(s.fvgBx)
    label.delete(s.fvgLbl)
    line.delete(s.fvgCe)
    s.fvgBx  := na
    s.fvgLbl := na
    s.fvgCe  := na

//@function Deletes the volume imbalance's drawing and clears its reference.
//@param s (Setup) The setup
//@returns (void)
f_eraseVi(Setup s) =>
    box.delete(s.viBx)
    label.delete(s.viLbl)
    s.viBx  := na
    s.viLbl := na

//@function Deletes the suspension block's drawing and clears its reference.
//@param s (Setup) The setup
//@returns (void)
f_eraseSb(Setup s) =>
    box.delete(s.sbBx)
    label.delete(s.sbLbl)
    line.delete(s.sbCe)
    s.sbBx  := na
    s.sbLbl := na
    s.sbCe  := na

//@function Deletes the IFVG's drawing and clears its reference.
//@param s (Setup) The setup
//@returns (void)
f_eraseIfvg(Setup s) =>
    box.delete(s.ifvgBx)
    label.delete(s.ifvgLbl)
    line.delete(s.ifvgCe)
    s.ifvgBx  := na
    s.ifvgLbl := na
    s.ifvgCe  := na

//@function Deletes the breaker's drawings and clears their references.
//@param s (Setup) The setup
//@returns (void)
f_eraseBrk(Setup s) =>
    line.delete(s.brkP)
    line.delete(s.brkD)
    line.delete(s.brkCe)
    label.delete(s.brkLbl)
    box.delete(s.brkBx)
    s.brkP   := na
    s.brkD   := na
    s.brkCe  := na
    s.brkLbl := na
    s.brkBx  := na

//@function Deletes the OTE band's drawing and clears its reference.
//@param s (Setup) The setup
//@returns (void)
f_eraseOte(Setup s) =>
    box.delete(s.oteBx)
    label.delete(s.oteLbl)
    line.delete(s.oteLeg)
    s.oteBx  := na
    s.oteLbl := na
    s.oteLeg := na

//@function Deletes every drawing a setup owns.
//@param s (Setup) The setup
//@returns (void)
f_wipe(Setup s) =>
    line.delete(s.liqLn)
    label.delete(s.liqLbl)
    line.delete(s.tgtLn)
    label.delete(s.tgtLbl)
    line.delete(s.mssLn)
    label.delete(s.mssLbl)
    line.delete(s.mssPendLn)
    label.delete(s.mssPendLbl)
    line.delete(s.smtLn)
    label.delete(s.smtLbl)
    f_eraseFvg(s)
    f_eraseVi(s)
    f_eraseSb(s)
    f_eraseIfvg(s)
    f_eraseBrk(s)
    f_eraseOte(s)

//@function The grade text for a count of formed arrays.
//@param c (int) 0..6
//@returns (string) A+, A, or n/6
f_gradeText(int c) =>
    c >= gradeAp ? 'A+' : c >= gradeA ? 'A' : str.tostring(c) + '/6'

//@function The draw's label: the level's name, then the grade of the setup that targets it —
//          one label at the runway carries both, so no separate grade tag sits inside price.
//@param s (Setup) The setup
//@returns (string) e.g. "BSL · ERL · 15m A+"
f_tgtText(Setup s) =>
    (s.dir > 0 ? 'BSL' : 'SSL') + ' · ERL · ' + TF_NAME + ' ' + s.gradeTxt

//@function Recounts the formed arrays, rewrites the draw label and raises the A / A+ events.
//@param s (Setup) The setup
//@param ev (Ev) This bar's event flags
//@returns (void)
f_grade(Setup s, Ev ev) =>
    int c = (s.hasFvg ? 1 : 0) + (s.hasVi ? 1 : 0) + (s.hasSb ? 1 : 0) + (s.hasIfvg ? 1 : 0) + (s.hasBrk ? 1 : 0) + (s.hasOte ? 1 : 0)
    if c >= gradeA and s.grade < gradeA
        ev.a := true
    if c >= gradeAp and s.grade < gradeAp
        ev.ap := true
    s.grade    := c
    s.gradeTxt := f_gradeText(c)
    if not na(s.tgtLbl)
        label.set_text(s.tgtLbl, f_tgtText(s))

//@function Draws the swept level and its name. The name sits at the swing that made the level, on
//          the outside; the line is dotted and stops at the raid, which is what reports the sweep.
//@param s (Setup) The setup
//@returns (void)
f_drawSweep(Setup s) =>
    if not s.drawn
        int d = s.dir
        int sweepAt = na(s.firstSweepTm) ? s.sweepTm : s.firstSweepTm
        // The line stops at the candle that wicked the level and is dotted, which is what says the
        // level was taken — the style carries the event, so no tag sits in price to announce it.
        s.liqLn    := f_level(s.liqTm, sweepAt, s.liq, liqCol, liqWidth, line.style_dotted)
        // The name sits on the OUTSIDE of the level — below a sellside sweep, above a buyside one —
        // at the swing that made it, where nothing has traded.
        s.liqLbl   := f_lbl(s.liqTm, s.liq, (d > 0 ? 'SSL' : 'BSL') + ' · ERL', d > 0 ? label.style_label_up : label.style_label_down)
        s.drawn    := true

//@function Draws the breaker as levels or as a zone once it has confirmed.
//@param s (Setup) The setup
//@param runway (int) Right-hand end for lines
//@param zoneEnd (int) Right-hand end for boxes
//@returns (void)
f_drawBreaker(Setup s, int runway, int zoneEnd) =>
    int d = s.dir
    color c = d > 0 ? C_BULL : C_BEAR
    float prox = d > 0 ? s.brkTop : s.brkBot
    float dist = d > 0 ? s.brkBot : s.brkTop
    if brkMode == 'Zone'
        [b, l] = f_zone(s.brkTm, s.brkTop, zoneEnd, s.brkBot, c, blockFill, true, 'Breaker')
        s.brkBx  := b
        s.brkLbl := l
    else
        s.brkP   := f_level(s.brkTm, runway, prox, c, 1, line.style_solid)
        s.brkD   := f_level(s.brkTm, runway, dist, c, 1, line.style_dotted)
        s.brkCe  := f_level(s.brkTm, runway, math.avg(s.brkTop, s.brkBot), C_GRAY, 1, line.style_dotted)
        s.brkLbl := f_lbl(runway, prox, 'Breaker', label.style_label_lower_left)

//@function Registers one same-direction imbalance against the setup, applying absorption: a
//          suspension block replaces the gap and the imbalance of its own triplet; a gap absorbs the
//          imbalance on either of its seams. Each kind registers once.
//@param s (Setup) The setup
//@param z (Zone) The imbalance
//@param zoneEnd (int) Right-hand end for boxes
//@returns (void)
f_register(Setup s, Zone z, int zoneEnd) =>
    int d = s.dir
    color c = d > 0 ? C_BULL : C_BEAR
    if z.kind == 2 and not s.hasSb
        s.hasSb := true
        s.sbBi  := z.bi
        s.sbTop := z.top
        s.sbBot := z.bot
        if showSb
            [b, l] = f_zone(z.tm, z.top, zoneEnd, z.bot, c, blockFill, true, (d > 0 ? 'SB+' : 'SB-') + ' · IRL')
            s.sbBx  := b
            s.sbLbl := l
            if showCe
                s.sbCe := f_level(z.tm, zoneEnd, math.avg(z.top, z.bot), C_GRAY, 1, line.style_dotted)
        if s.hasFvg and s.fvgBi == z.bi - 1
            s.hasFvg := false
            f_eraseFvg(s)
        if s.hasVi and (s.viBi == z.bi - 1 or s.viBi == z.bi)
            s.hasVi := false
            f_eraseVi(s)
    else if z.kind == 0 and not s.hasFvg and not (s.hasSb and z.bi == s.sbBi - 1)
        s.hasFvg := true
        s.fvgBi  := z.bi
        s.fvgTop := z.top
        s.fvgBot := z.bot
        if showFvg
            [b, l] = f_zone(z.tm, z.top, zoneEnd, z.bot, c, gapFill, false, (d > 0 ? '+FVG' : '-FVG') + ' · IRL')
            s.fvgBx  := b
            s.fvgLbl := l
            if showCe
                s.fvgCe := f_level(z.tm, zoneEnd, math.avg(z.top, z.bot), C_GRAY, 1, line.style_dotted)
        if s.hasVi and (s.viBi == z.bi or s.viBi == z.bi + 1)
            s.hasVi := false
            f_eraseVi(s)
    else if z.kind == 1 and not s.hasVi and not (s.hasSb and (z.bi == s.sbBi - 1 or z.bi == s.sbBi)) and not (s.hasFvg and (z.bi == s.fvgBi or z.bi == s.fvgBi + 1))
        s.hasVi := true
        s.viBi  := z.bi
        s.viTop := z.top
        s.viBot := z.bot
        if showVi
            [b, l] = f_zone(z.tm, z.top, zoneEnd, z.bot, c, gapFill, false, 'VI · IRL')
            s.viBx  := b
            s.viLbl := l
    true

//@function Registers every unmitigated same-direction imbalance after the sweep, blocks first so
//          absorption resolves the same way whatever order they formed in.
//@param s (Setup) The setup
//@param gz (array<Zone>) Same-direction store
//@param zoneEnd (int) Right-hand end for boxes
//@param onlyNew (bool) True limits the scan to imbalances detected this bar
//@returns (void)
f_scanZones(Setup s, array<Zone> gz, int zoneEnd, bool onlyNew) =>
    int n = gz.size()
    if n > 0
        for pass = 0 to 2
            int kind = pass == 0 ? 2 : pass == 1 ? 0 : 1
            for i = 0 to n - 1
                Zone z = gz.get(i)
                if z.kind == kind and not z.mit and z.bi > s.sweepBi and (not onlyNew or z.det == bar_index)
                    f_register(s, z, zoneEnd)

//@function Looks for the nearest opposite-direction gap that this bar's close has body-closed
//          through, among gaps formed after the failed push. Draws it as the IFVG.
//@param s (Setup) The setup
//@param ogz (array<Zone>) Opposite-direction store
//@param zoneEnd (int) Right-hand end for boxes
//@returns (void)
f_tryIfvg(Setup s, array<Zone> ogz, int zoneEnd) =>
    int d = s.dir
    float bestKey = na
    int   bestI   = -1
    int n = ogz.size()
    if n > 0
        for i = 0 to n - 1
            Zone z = ogz.get(i)
            if z.kind == 0 and z.bi > s.pushBi and z.bi < bar_index
                float thr = d > 0 ? z.top : z.bot
                if d * (close - thr) > 0
                    if na(bestKey) or d * (thr - bestKey) > 0
                        bestKey := thr
                        bestI   := i
    if bestI >= 0
        Zone z = ogz.get(bestI)
        s.hasIfvg := true
        s.ifvgTop := z.top
        s.ifvgBot := z.bot
        if showIfvg
            [b, l] = f_zone(z.tm, z.top, zoneEnd, z.bot, d > 0 ? C_BULL : C_BEAR, gapFill, false, 'IFVG · IRL')
            s.ifvgBx  := b
            s.ifvgLbl := l
            if showCe
                s.ifvgCe := f_level(z.tm, zoneEnd, math.avg(z.top, z.bot), C_GRAY, 1, line.style_dotted)

//@function Draws or re-measures the OTE band off the reversal leg.
//@param s (Setup) The setup
//@param legTm (int) Time of the swing that completed the leg
//@param zoneEnd (int) Right-hand end for boxes
//@returns (void)
f_drawOte(Setup s, int legTm, int zoneEnd) =>
    int d = s.dir
    float span = math.abs(s.legExt - s.legStart)
    float a = s.legExt - d * oteFrom * span
    float b = s.legExt - d * oteTo * span
    s.oteTop := math.max(a, b)
    s.oteBot := math.min(a, b)
    // Two guarded blocks, no else: an if/else that ends a function is its return value and the
    // branches would have to agree on type (CE10235).
    bool fresh = na(s.oteBx)
    if showOte and fresh
        [bx, l] = f_zone(legTm, s.oteTop, zoneEnd, s.oteBot, oteCol, bandFill, false, 'OTE')
        s.oteBx  := bx
        s.oteLbl := l
        // f_zone centres every zone caption, so the band needs no repositioning here - doing it by
        // hand is what left the name on the top edge on its first bar. Bold is the BAND's own mark
        // and stays: a PD array's name is read beside price, the dealing band's is read through it.
        label.set_text_formatting(s.oteLbl, text.format_bold)
        // The leg being measured — one dotted grey diagonal from the sweep extreme to the swing
        // that completed it: the 0 and the 1 of the fib, nothing more.
        s.oteLeg := line.new(s.legStartTm, s.legStart, legTm, s.legExt, xloc = xloc.bar_time, color = C_GRAY, width = 1, style = line.style_dotted)
    if showOte and not fresh
        box.set_lefttop(s.oteBx, legTm, s.oteTop)
        box.set_bottom(s.oteBx, s.oteBot)
        f_zoneCap(s.oteLbl, s.oteBx)
        line.set_xy1(s.oteLeg, s.legStartTm, s.legStart)
        line.set_xy2(s.oteLeg, legTm, s.legExt)
    true

//@function The OTE stage, run on every bar a setup is live including the MSS bar itself. The band
//          fires on the swing that completes the leg and re-measures on a higher one until price has
//          traded into it; the touch test covers the bars between the swing and its confirmation.
//@param s (Setup) The setup
//@param newOp (float) An opposite-side two-candle swing confirmed this bar, or na
//@param newOpTm (int) Its time
//@param newOpBi (int) Its bar index
//@param zoneEnd (int) Right-hand end for boxes
//@returns (void)
f_tryOte(Setup s, float newOp, int newOpTm, int newOpBi, int zoneEnd) =>
    int d = s.dir
    bool drewNow = false
    if not na(newOp) and newOpBi > s.sweepBi and d * (newOp - s.mssRef) > 0
        if not s.hasOte or (oteRatchet and not s.oteTouched and d * (newOp - s.legExt) > 0)
            s.legExt := newOp
            s.hasOte := true
            drewNow  := true
            f_drawOte(s, newOpTm, zoneEnd)
    if s.hasOte and not s.oteTouched and not na(s.oteTop)
        // On the bar the band is drawn, every bar since the swing is checked — a range-timeframe
        // swing confirms many chart bars after it prints.
        int kMax = drewNow ? math.min(math.max(bar_index - newOpBi, 0), 500) : 0
        for k = 0 to kMax
            bool hit = d > 0 ? low[k] <= s.oteTop : high[k] >= s.oteBot
            if hit
                s.oteTouched := true

// ── Cross-check ──────────────────────────────────────────────────────────────
//@function The peer's level corresponding to one of the chart's range swings: its extreme over the
//          range-timeframe candles within the swing's own confirmation window.
//@param pc (array<Candle>) The peer's candles
//@param ct (int) The chart swing's range-timeframe candle open time
//@param wantHigh (bool) High side or low side
//@returns ([float, int]) The level and the window's end time
f_peerLevel(array<Candle> pc, int ct, bool wantHigh) =>
    int   lo  = ct - htfLen * htfMs
    int   hi  = ct + htfLen * htfMs
    float lvl = na
    int n = pc.size()
    if n > 0 and not na(ct)
        for i = 0 to n - 1
            Candle c = pc.get(i)
            if c.t >= lo and c.t <= hi
                float v = wantHigh ? c.h : c.l
                if na(lvl) or (wantHigh ? v > lvl : v < lvl)
                    lvl := v
    [lvl, hi]

//@function The first peer candle after the window that traded through the level, or na.
//@param pc (array<Candle>) The peer's candles
//@param lvl (float) The level
//@param winEnd (int) The window's end time
//@param wantHigh (bool) High side or low side
//@returns (int) The candle's open time, or na
f_peerTaken(array<Candle> pc, float lvl, int winEnd, bool wantHigh) =>
    int r = na
    int n = pc.size()
    if n > 0 and not na(lvl)
        for i = 0 to n - 1
            Candle c = pc.get(i)
            if na(r) and c.t > winEnd and (wantHigh ? c.h > lvl : c.l < lvl)
                r := c.t
    r

//@function Fixes the peers' corresponding levels once the range is fixed (at the sweep), and reads
//          whether each has already been taken.
//@param s (Setup) The setup
//@returns (void)
f_xcSet(Setup s) =>
    if xcLive and not s.xcSet
        bool tgtHigh = s.dir > 0
        [l1, e1] = f_peerLevel(peer1, s.tgtCt, tgtHigh)
        [l2, e2] = f_peerLevel(peer2, s.tgtCt, tgtHigh)
        [m1, f1] = f_peerLevel(peer1, s.liqCt, not tgtHigh)
        [m2, f2] = f_peerLevel(peer2, s.liqCt, not tgtHigh)
        s.p1TgtLvl  := l1
        s.p2TgtLvl  := l2
        s.p1LiqLvl  := m1
        s.p2LiqLvl  := m2
        s.tgtWinEnd := e1
        s.liqWinEnd := f1
        s.xcSet     := true

//@function Re-reads the peers' taken state; cheap enough to run on every new peer candle.
//@param s (Setup) The setup
//@returns (void)
f_xcUpdate(Setup s) =>
    if s.xcSet
        bool tgtHigh = s.dir > 0
        if na(s.p1TgtTaken)
            s.p1TgtTaken := f_peerTaken(peer1, s.p1TgtLvl, s.tgtWinEnd, tgtHigh)
        if na(s.p2TgtTaken)
            s.p2TgtTaken := f_peerTaken(peer2, s.p2TgtLvl, s.tgtWinEnd, tgtHigh)
        if na(s.p1LiqTaken)
            s.p1LiqTaken := f_peerTaken(peer1, s.p1LiqLvl, s.liqWinEnd, not tgtHigh)
        if na(s.p2LiqTaken)
            s.p2LiqTaken := f_peerTaken(peer2, s.p2LiqLvl, s.liqWinEnd, not tgtHigh)

//@function Whether the chart is the laggard on the target side: at least one peer took its level
//          and the chart has not.
//@param s (Setup) The setup
//@returns (bool)
f_isLaggard(Setup s) =>
    s.xcSet and not s.selfTgtTaken and (not na(s.p1TgtTaken) or not na(s.p2TgtTaken))

//@function Reads the peers on the chart timeframe: a peer that trades through its own level on
//          this bar has taken it. Runs for a swept or live setup, so the SMT resolves on the bar.
//@param s (Setup) The setup
//@param e1 (float) Peer 1's extreme on this bar on the sweep side
//@param e2 (float) Peer 2's extreme on this bar on the sweep side
//@returns (void)
f_peerLiqChart(Setup s, float e1, float e2) =>
    if s.xcSet and s.state >= 2 and s.state <= 3
        if na(s.p1LiqTaken) and not na(s.p1LiqLvl) and s.dir * (s.p1LiqLvl - e1) > 0
            s.p1LiqTaken := time
        if na(s.p2LiqTaken) and not na(s.p2LiqLvl) and s.dir * (s.p2LiqLvl - e2) > 0
            s.p2LiqTaken := time

//@function Draws the SMT once the sweep is on the chart: a line from the range swing to the sweep
//          extreme — the chart's lower low (or higher high) — named on the Sweep tag with the peer that held.
//          Removed if every peer takes its level; the divergence has failed.
//@param s (Setup) The setup
//@returns (void)
f_drawSmt(Setup s) =>
    // The divergence is between the raid's extreme and the CHART swing just before it - the higher
    // high the peer failed to match. The range swing is days back on a 1m chart, and a line from
    // there ran flat under the level and never read as an SMT. Resolved lazily, once the pivots
    // either side of the raid have had time to confirm; falls back to the range swing if none.
    if na(s.smtFromTm)
        array<Swing> pool = s.dir < 0 ? hHi : hLo
        int n = pool.size()
        if n > 0
            for i = n - 1 to 0
                Swing w = pool.get(i)
                if w.bi < s.sweepBi and w.bi > s.liqBi and s.dir * (w.px - s.sweepPx) > 0
                    s.smtFromTm := w.tm
                    s.smtFromPx := w.px
                    break
    int   smtX1 = na(s.smtFromTm) ? s.liqTm : s.smtFromTm
    float smtY1 = na(s.smtFromTm) ? s.liq   : s.smtFromPx
    bool p1Held = na(s.p1LiqTaken)
    bool p2Held = na(s.p2LiqTaken)
    bool held   = showSmt and xcLive and s.xcSet and s.drawn and s.state >= 2 and s.state <= 3 and (p1Held or p2Held)
    if not held and not na(s.smtLn)
        line.delete(s.smtLn)
        s.smtLn := na
        label.delete(s.smtLbl)
        s.smtLbl := na
    if held
        // The SMT has its own tag at the divergence extreme; the Sweep tag stays at the level.
        string who = 'SMT ' + (p1Held and p2Held ? peer1Name + ' · ' + peer2Name : p1Held ? peer1Name : peer2Name)
        if na(s.smtLn)
            s.smtLn := line.new(smtX1, smtY1, s.sweepTm, s.sweepPx, xloc = xloc.bar_time, color = C_INK, width = 1, style = line.style_solid)
        else
            line.set_xy1(s.smtLn, smtX1, smtY1)
            line.set_xy2(s.smtLn, s.sweepTm, s.sweepPx)
        if na(s.smtLbl)
            s.smtLbl := f_lbl(s.sweepTm, s.sweepPx, who, s.dir > 0 ? label.style_label_up : label.style_label_down)
        else
            label.set_xy(s.smtLbl, s.sweepTm, s.sweepPx)
            label.set_text(s.smtLbl, who)
    true

//@function The time the first peer took the target side, or na.
//@param s (Setup) The setup
//@returns (int)
f_laggardSince(Setup s) =>
    int a = s.p1TgtTaken
    int b = s.p2TgtTaken
    na(a) ? b : na(b) ? a : math.min(a, b)

//@function The catch-up confirmation: a fair value gap in the setup's direction on the catch-up
//          timeframe (or the chart, when the chart is not below it), formed after the peers took the
//          level.
//@param s (Setup) The setup
//@param gz (array<Zone>) Same-direction chart imbalances
//@returns (bool)
f_catchUpGap(Setup s, array<Zone> gz) =>
    bool r = false
    int since = f_laggardSince(s)
    if not na(since)
        if gapOnChart
            int n = gz.size()
            if n > 0
                for i = 0 to n - 1
                    Zone z = gz.get(i)
                    if z.kind == 0 and z.tm > since
                        r := true
        else
            array<int> src = s.dir > 0 ? gapUpTm : gapDnTm
            int n = src.size()
            if n > 0
                for i = 0 to n - 1
                    if src.get(i) > since
                        r := true
    r

//@function Advances one direction's setup by one confirmed bar.
//@param s (Setup) The setup for this direction
//@param ev (Ev) This bar's event flags for this direction
//@param hist (array<Setup>) The history store setups join once they draw
//@param sw (array<Swing>) Swept-side range swings
//@param op (array<Swing>) Opposite-side range swings
//@param cOp (array<Swing>) Opposite-side chart swings — the structure the MSS breaks
//@param gz (array<Zone>) Same-direction imbalances
//@param ogz (array<Zone>) Opposite-direction imbalances
//@returns (Setup) The setup to carry into the next bar — the same object, or a fresh one
f_run(Setup s, Ev ev, array<Setup> hist, array<Swing> sw, array<Swing> op, array<Swing> cOp, array<Zone> gz, array<Zone> ogz) =>
    int   d       = s.dir
    float ext     = d > 0 ? low : high
    int   runway  = time + runwayBars * msPerBar
    int   zoneEnd = time + 2 * msPerBar
    color dirCol  = d > 0 ? C_BULL : C_BEAR
    Setup out     = s
    s.justArmed := false

    if s.state <= 1
        bool wasArmed = s.state == 1
        // ── The range: the held dealing range, read by direction. Both sides must be locked. ──
        bool  haveDr = not na(drHiPx) and not na(drLoPx) and not drHiPend and not drLoPend
        float liq    = haveDr ? (d > 0 ? drLoPx : drHiPx) : na
        int   liqTm  = haveDr ? (d > 0 ? drLoTm : drHiTm) : na
        int   liqBi  = haveDr ? (d > 0 ? drLoBi : drHiBi) : na
        int   liqCt  = haveDr ? (d > 0 ? drLoCt : drHiCt) : na
        float tgt    = haveDr ? (d > 0 ? drHiPx : drLoPx) : na
        int   tgtTm  = haveDr ? (d > 0 ? drHiTm : drLoTm) : na
        int   tgtBi  = haveDr ? (d > 0 ? drHiBi : drLoBi) : na
        int   tgtCt  = haveDr ? (d > 0 ? drHiCt : drLoCt) : na
        float rng    = math.abs(tgt - liq)
        // ── The failed push: the latest opposite range swing after the target that reached it and held ──
        float pushPx = na
        int   pushTm = na
        int   pushBi = na
        bool  tgtRaid = false
        int m = op.size()
        if haveDr and m > 0
            float reach = liq + d * rng * pushReachPct / 100
            for i = 0 to m - 1
                Swing x = op.get(i)
                if x.bi == tgtBi
                    tgtRaid := x.raid
                if x.bi > tgtBi and d * (x.px - reach) >= 0 and (na(pushBi) or x.bi > pushBi)
                    pushPx := x.px
                    pushTm := x.tm
                    pushBi := x.bi
            // A target that itself raided the prior extreme and closed back inside is the failed push.
            if na(pushBi) and (tgtRaid or not requirePush)
                pushPx := tgt
                pushTm := tgtTm
                pushBi := tgtBi
        bool armed = haveDr and not na(pushBi) and rng >= minRangeAtr * atr and d * (tgt - close) > 0
        s.liq    := liq
        s.liqTm  := liqTm
        s.liqBi  := liqBi
        s.liqCt  := liqCt
        s.tgt    := tgt
        s.tgtTm  := tgtTm
        s.tgtBi  := tgtBi
        s.tgtCt  := tgtCt
        s.pushPx := pushPx
        s.pushTm := pushTm
        s.pushBi := pushBi
        s.state  := armed ? 1 : 0
        s.justArmed := armed and not wasArmed
        // The peers are read against the range as soon as there is one, so the open-draw verdict
        // is on the console before any sweep. Re-read whenever the range's swings change.
        if not na(liq) and not na(tgt)
            if s.xcTgtCt != s.tgtCt or s.xcLiqCt != s.liqCt
                s.xcSet      := false
                s.p1TgtTaken := na
                s.p2TgtTaken := na
                s.p1LiqTaken := na
                s.p2LiqTaken := na
                s.xcTgtCt    := s.tgtCt
                s.xcLiqCt    := s.liqCt
                f_xcSet(s)
                f_xcUpdate(s)
        // ── The sweep on this bar: a wick through the level, the candle closing back inside.
        //    Bars inside the range swing's confirmation lag are searched at global scope. ──
        if armed and d * (liq - ext) > 0 and d * (close[1] - liq) > 0 and bar_index > s.pushBi
            s.state        := 2
            s.outsideBars  := d * (close - liq) < 0 ? 1 : 0
            s.sweepPx      := ext
            s.sweepTm      := time
            s.sweepBi      := bar_index
            s.firstSweepBi := bar_index
            s.firstSweepTm := time
            ev.swept       := true
            f_xcSet(s)
            f_xcUpdate(s)
            if showEarly or drawRange
                f_drawSweep(s)

    else if s.state == 2
        s.outsideBars := d * (close - s.liq) < 0 ? s.outsideBars + 1 : 0
        if s.outsideBars > reclaimBars
            // Price has stayed beyond the level — the raid became a break, not a sweep.
            ev.broke   := true
            ev.brokeCt := s.liqCt
            f_wipe(s)
            out := Setup.new(dir = d)
        else if d * (close - s.tgt) > 0
            // The target went before structure shifted — nothing to grade.
            f_wipe(s)
            out := Setup.new(dir = d)
        else if bar_index - s.firstSweepBi > sweepExpiry
            f_wipe(s)
            out := Setup.new(dir = d)
        else
            if d * (s.sweepPx - ext) > 0
                s.sweepPx := ext
                s.sweepTm := time
                s.sweepBi := bar_index
            // ── The structure to break: the latest opposite CHART swing since the push, inside the target ──
            float ref   = s.pushPx
            int   refTm = s.pushTm
            int   refBi = s.pushBi
            int m = cOp.size()
            if m > 0
                for i = 0 to m - 1
                    Swing x = cOp.get(i)
                    if x.bi > refBi and d * (s.tgt - x.px) > 0
                        ref   := x.px
                        refTm := x.tm
                        refBi := x.bi
            s.mssRef   := ref
            s.mssRefTm := refTm
            s.mssRefBi := refBi
            s.waitDisp := false
            // ── The level a close has to clear, drawn from the sweep until the MSS prints. It is
            //    the same reference the confirmation below tests, so the line cannot promise a
            //    break the script would not accept, and it follows the reference as newer swings
            //    form. Dotted at width 1: a reference, against the confirmed MSS line's solid 2.
            if showMssLvl and d * (s.tgt - s.mssRef) > 0
                if na(s.mssPendLn)
                    s.mssPendLn  := f_level(s.mssRefTm, runway, s.mssRef, dirCol, 1, line.style_dotted)
                    s.mssPendLbl := f_lbl(s.mssRefTm, s.mssRef, 'MSS · pending', d > 0 ? label.style_label_down : label.style_label_up)
                else
                    line.set_xy1(s.mssPendLn, s.mssRefTm, s.mssRef)
                    line.set_xy2(s.mssPendLn, runway, s.mssRef)
                    label.set_xy(s.mssPendLbl, s.mssRefTm, s.mssRef)
            else
                line.delete(s.mssPendLn)
                label.delete(s.mssPendLbl)
                s.mssPendLn  := na
                s.mssPendLbl := na
            // The reference has to sit inside the target; a reference AT the target is the target.
            if d * (s.tgt - s.mssRef) > 0 and d * (close - s.mssRef) > 0 and d * (close - s.liq) > 0
                bool dispOk = d * (close - s.sweepPx) >= minDispAtr * atr
                if not dispOk
                    // The V has not formed — a grinding reaction is not confirmed yet. Wait.
                    s.waitDisp := true
                else if not inSess
                    // Structure shifted outside the window — this one is not the setup.
                    f_wipe(s)
                    out := Setup.new(dir = d)
                else
                    // ── MSS confirmed: the gate opens, everything draws at its origin ──
                    s.state := 3
                    s.mssTm := time
                    s.mssBi := bar_index
                    // The OTE measures from the leg's own extreme — the lowest low (highest high)
                    // from just before the first breach of the level to this bar, capped by the
                    // lookback — not from the sweep wick alone, and not from an older low either.
                    int legN = math.min(math.min(bar_index - s.firstSweepBi + 3, oteLook), bar_index)
                    s.legStart   := ext
                    s.legStartTm := time
                    for i = 0 to legN
                        float e = d > 0 ? low[i] : high[i]
                        if d * (s.legStart - e) > 0
                            s.legStart   := e
                            s.legStartTm := time[i]
                    ev.mss  := true
                    f_drawSweep(s)
                    s.tgtLn    := f_level(s.tgtTm, runway, s.tgt, liqCol, liqWidth, line.style_solid)
                    // Outside its own level - above a buyside draw, below a sellside one - so the
                    // name begins where the line stops instead of printing along it.
                    s.tgtLbl   := f_lbl(runway, s.tgt, f_tgtText(s), d > 0 ? label.style_label_lower_left : label.style_label_upper_left)
                    // The pending level has been taken; the confirmed line replaces it.
                    line.delete(s.mssPendLn)
                    label.delete(s.mssPendLbl)
                    s.mssPendLn  := na
                    s.mssPendLbl := na
                    // The MSS line stops at the break bar — run on, it reads as a level it is not.
                    // The grade rides on the draw's own label at the runway (see f_tgtText).
                    s.mssLn    := f_level(s.mssRefTm, time, s.mssRef, dirCol, 2, line.style_solid)
                    s.mssLbl   := f_lbl(s.mssRefTm, s.mssRef, 'MSS', d > 0 ? label.style_label_down : label.style_label_up)
                    s.brkPending := true
                    f_scanZones(s, gz, zoneEnd, false)
                    f_tryIfvg(s, ogz, zoneEnd)
                    hist.push(s)

    else if s.state == 3
        if d * (close - s.sweepPx) < 0
            // Closed back through the sweep extreme — the reversal failed. Gone, not greyed.
            f_wipe(s)
            s.state := 5
            out := Setup.new(dir = d)
        else
            bool done = d * (close - s.tgt) > 0
            bool old  = bar_index - s.mssBi > setupMaxAge
            // ── Arrays forming one by one ──
            f_scanZones(s, gz, zoneEnd, true)
            if not s.hasIfvg
                f_tryIfvg(s, ogz, zoneEnd)
            if s.brkPending and not s.hasBrk and not na(s.brkTop)
                float prox = d > 0 ? s.brkTop : s.brkBot
                if d * (close - prox) > 0
                    s.hasBrk     := true
                    s.brkPending := false
                    if showBrk
                        f_drawBreaker(s, runway, zoneEnd)
            // ── Mitigation: a close through the far edge deletes the drawing, the count stands ──
            if not na(s.fvgBx) and d * (close - (d > 0 ? s.fvgBot : s.fvgTop)) < 0
                f_eraseFvg(s)
            if not na(s.viBx) and d * (close - (d > 0 ? s.viBot : s.viTop)) < 0
                f_eraseVi(s)
            if not na(s.sbBx) and d * (close - (d > 0 ? s.sbBot : s.sbTop)) < 0
                f_eraseSb(s)
            if not na(s.ifvgBx) and d * (close - (d > 0 ? s.ifvgBot : s.ifvgTop)) < 0
                f_eraseIfvg(s)
            if not na(s.brkLbl) and d * (close - (d > 0 ? s.brkBot : s.brkTop)) < 0
                f_eraseBrk(s)
            if not na(s.oteBx) and d * (close - (d > 0 ? s.oteBot : s.oteTop)) < 0
                f_eraseOte(s)
            // ── Live edges ──
            line.set_x2(s.tgtLn, runway)
            label.set_x(s.tgtLbl, runway)
            if not na(s.fvgBx)
                box.set_right(s.fvgBx, zoneEnd)
                f_zoneCap(s.fvgLbl, s.fvgBx)
                line.set_x2(s.fvgCe, zoneEnd)
            if not na(s.viBx)
                box.set_right(s.viBx, zoneEnd)
                f_zoneCap(s.viLbl, s.viBx)
            if not na(s.sbBx)
                box.set_right(s.sbBx, zoneEnd)
                f_zoneCap(s.sbLbl, s.sbBx)
                line.set_x2(s.sbCe, zoneEnd)
            if not na(s.ifvgBx)
                box.set_right(s.ifvgBx, zoneEnd)
                f_zoneCap(s.ifvgLbl, s.ifvgBx)
                line.set_x2(s.ifvgCe, zoneEnd)
            if not na(s.oteBx)
                box.set_right(s.oteBx, zoneEnd)
                f_zoneCap(s.oteLbl, s.oteBx)
            if not na(s.brkLbl)
                if not na(s.brkBx)
                    box.set_right(s.brkBx, zoneEnd)
                    f_zoneCap(s.brkLbl, s.brkBx)
                else
                    line.set_x2(s.brkP, runway)
                    line.set_x2(s.brkD, runway)
                    line.set_x2(s.brkCe, runway)
                    label.set_x(s.brkLbl, runway)
            if done or old
                // Taken or retired: the setup freezes as history. The draw line stops here, dotted,
                // and the grade reads a full ATR clear of it, centred, above a high and below a
                // low — never on the line, never on the ERL name that shares the swing.
                line.set_style(s.tgtLn, line.style_dotted)
                line.set_x2(s.tgtLn, time)
                label.set_xy(s.tgtLbl, s.tgtTm, s.tgt + d * atr)
                label.set_style(s.tgtLbl, label.style_label_center)
                s.state   := 4
                s.outcome := done ? 'target taken' : 'retired'
                out := Setup.new(dir = d)

    // The chart's own wick through the target, read the same way the peers are.
    if s.state >= 2 and s.state <= 3 and not s.selfTgtTaken
        float oppExt = d > 0 ? high : low
        if d * (oppExt - s.tgt) > 0
            s.selfTgtTaken := true
    out

//@function Finds the order block the leg into the sweep left behind, the Unicorn / Confluence
//          Engine reading: walking back from the sweep extreme, the first displacement candle
//          against the setup — body at least obDispAtr x ATR, closing through the last chart swing
//          on that side, with a gap left around it — and the run of consecutive opposite-close
//          candles immediately before it (up to four, within five bars). Wick to wick. That block
//          becomes the breaker once a close passes back through it; a block price never closed
//          through is an order block and never a breaker. Called every bar at global scope; does
//          its work only when active.
//@param d (int) Setup direction
//@param barsBack (int) Bars from the current bar back to the sweep extreme
//@param legEnd (int) Bars from the current bar back to the swing the leg into the sweep came from
//@param sw (array<Swing>) The chart swings on the sweep side (lows for a bull setup)
//@param active (bool) True on the bar the MSS confirmed
//@returns ([float, float, int, bool]) top, bottom, origin time, found
f_findBlock(int d, int barsBack, int legEnd, array<Swing> sw, bool active) =>
    float top   = na
    float bot   = na
    int   tm    = na
    bool  found = false
    if active and barsBack >= 1 and barsBack <= 480 and bar_index > barsBack + 80
        int k = barsBack
        // The walk stops at the swing the leg into the sweep came from: a block older than that
        // leg belongs to another move and is not this reversal's breaker.
        while k <= math.min(legEnd, barsBack + 60) and not found
            // The displacement candle: against the setup, a real body, a gap around it.
            bool against = d > 0 ? close[k] < open[k] : close[k] > open[k]
            bool body    = math.abs(close[k] - open[k]) >= obDispAtr * atr
            bool gap     = d > 0 ? low[k + 1] > high[k - 1] : high[k + 1] < low[k - 1]
            bool through = false
            if against and body and gap
                // Closed through the last chart swing on that side that formed before it.
                int   dispBi = bar_index - k
                float swPx   = na
                int   swBi   = na
                int n = sw.size()
                if n > 0
                    for i = 0 to n - 1
                        Swing x = sw.get(i)
                        if x.bi < dispBi and (na(swBi) or x.bi > swBi)
                            swBi := x.bi
                            swPx := x.px
                through := not na(swPx) and d * (swPx - close[k]) > 0
            if through
                // The block: the first opposite-close candle within five bars before the
                // displacement, and the consecutive run of the same colour behind it.
                int k0 = na
                int j  = k + 1
                while j <= k + 5 and na(k0)
                    bool opp = d > 0 ? close[j] > open[j] : close[j] < open[j]
                    if opp
                        k0 := j
                    j += 1
                if not na(k0)
                    top := high[k0]
                    bot := low[k0]
                    tm  := time[k0]
                    int cnt = 1
                    int m   = k0 + 1
                    bool more = true
                    while cnt < 4 and more
                        bool same = d > 0 ? close[m] > open[m] : close[m] < open[m]
                        if same
                            top := math.max(top, high[m])
                            bot := math.min(bot, low[m])
                            tm  := time[m]
                            cnt += 1
                            m   += 1
                        else
                            more := false
                    found := true
            k += 1
    [top, bot, tm, found]

//@function Applies the block search result on the MSS bar: the order block the leg into the sweep
//          left behind (see f_findBlock) confirms as a breaker once a close passes through it — the
//          block fails and flips in place, the way a gap inverts — this bar or later.
//@param s (Setup) The setup
//@param top (float) Block top
//@param bot (float) Block bottom
//@param tm (int) Block origin time
//@param found (bool) Whether a block was found
//@returns (void)
f_setBreaker(Setup s, float top, float bot, int tm, bool found) =>
    if not found
        s.brkPending := false
    if found
        s.brkTop := top
        s.brkBot := bot
        s.brkTm  := tm
        float prox = s.dir > 0 ? top : bot
        if s.dir * (close - prox) > 0
            s.hasBrk     := true
            s.brkPending := false
            if showBrk
                f_drawBreaker(s, time + runwayBars * msPerBar, time + 2 * msPerBar)
    true

//@function Searches the bars inside the range swing's confirmation lag for a sweep that printed
//          before the setup could arm: the deepest wick through the level, with no run of closes
//          beyond it longer than the reclaim count since. Called every bar at global scope; does its
//          work only when active.
//@param d (int) Setup direction
//@param liq (float) The swept level
//@param maxBack (int) How many bars back to search (the bar after the push is the limit)
//@param active (bool) True on the bar the setup armed
//@returns ([float, int, int, bool]) extreme, time, bar index, found
f_findSweep(int d, float liq, int maxBack, bool active) =>
    float px    = na
    int   tm    = na
    int   bi    = na
    bool  found = false
    if active and maxBack >= 1 and bar_index > maxBack + 5
        bool  chain = true
        int   outCt = 0
        float cPx   = na
        int   cTm   = na
        int   cBi   = na
        int k = 1
        while k <= math.min(maxBack, 540) and chain
            float ck = close[k]
            bool inside = d * (ck - liq) >= 0
            outCt := inside ? 0 : outCt + 1
            if outCt > reclaimBars
                chain := false
            else
                float ek = d > 0 ? low[k] : high[k]
                if d * (liq - ek) > 0 and (na(cPx) or d * (cPx - ek) > 0)
                    cPx := ek
                    cTm := time[k]
                    cBi := bar_index - k
                // The excursion is a sweep only once an older close inside the level is reached:
                // a run that never came from inside is a break still in progress.
                if inside and not na(cPx)
                    px    := cPx
                    tm    := cTm
                    bi    := cBi
                    found := true
                k += 1
    [px, tm, bi, found]

//@function Applies a lookback sweep found on the arming bar.
//@param s (Setup) The setup
//@param px (float) The sweep extreme
//@param tm (int) Its time
//@param bi (int) Its bar index
//@param found (bool) Whether one was found
//@returns (void)
f_applySweep(Setup s, float px, int tm, int bi, bool found) =>
    if found and s.state == 1
        s.state        := 2
        s.sweepPx      := px
        s.sweepTm      := tm
        s.sweepBi      := bi
        s.firstSweepBi := bi
        s.firstSweepTm := tm
        f_xcSet(s)
        f_xcUpdate(s)
        if showEarly or drawRange
            f_drawSweep(s)
    if found and s.state == 2 and s.dir * (s.sweepPx - px) > 0
        s.sweepPx      := px
        s.sweepTm      := tm
        s.sweepBi      := bi
        if bi < s.firstSweepBi
            s.firstSweepBi := bi
            s.firstSweepTm := tm
    true

// ============================================================================
// RUN
// ============================================================================
//@variable The live bullish and bearish setups.
var Setup bull = Setup.new(dir = 1)
var Setup bear = Setup.new(dir = -1)
//@variable Setups that have drawn, oldest first, pruned per direction.
var array<Setup> hist = array.new<Setup>()
var Ev evBull = Ev.new()
var Ev evBear = Ev.new()

evBull.swept   := false
evBull.mss     := false
evBull.a       := false
evBull.ap      := false
evBull.catchUp := false
evBull.broke   := false
evBear.swept   := false
evBear.mss     := false
evBear.a       := false
evBear.ap      := false
evBear.catchUp := false
evBear.broke   := false

float newPh   = na
float newPl   = na
int   newPvTm = na
int   newPvBi = na
float newHtfHi   = na
int   newHtfHiTm = na
int   newHtfHiBi = na
float newHtfLo   = na
int   newHtfLoTm = na
int   newHtfLoBi = na

// A body gap across a session or weekend break is a calendar artefact, not displacement.
bool joinNear = (time - time[1]) <= msPerBar * 1.5
bool joinFar  = (time[1] - time[2]) <= msPerBar * 1.5

if barstate.isconfirmed
    // ── The last pivLen + 1 bars, this bar first ──
    recLow.clear()
    recHigh.clear()
    for k = 0 to pivLen
        recLow.push(low[k])
        recHigh.push(high[k])

    // ── Follow the range timeframe: complete the previous candle, confirm its swings ──
    if newCandle and not na(curH)
        hH.push(curH)
        hL.push(curL)
        hC.push(curC)
        hHiTm.push(curHiTm)
        hHiBi.push(curHiBi)
        hLoTm.push(curLoTm)
        hLoBi.push(curLoBi)
        hCt.push(curCt)
        htfN += 1
        if hH.size() > CANDLE_CAP
            hH.shift()
            hL.shift()
            hC.shift()
            hHiTm.shift()
            hHiBi.shift()
            hLoTm.shift()
            hLoBi.shift()
            hCt.shift()
        int nC = hH.size()
        int ordBase = htfN - nC
        int iH = f_htfPivot(hH, true)
        if iH >= 0
            float prevMax = f_extreme(hHi, htfN - lookbackCdl, 1)
            float pxH = hH.get(iH)
            float maxC = na
            for j = iH to nC - 1
                maxC := na(maxC) ? hC.get(j) : math.max(maxC, hC.get(j))
            bool raid = not na(prevMax) and pxH > prevMax and maxC < prevMax
            f_pushSwing(hHi, Swing.new(pxH, hHiTm.get(iH), hHiBi.get(iH), ordBase + iH, hCt.get(iH), raid))
            newHtfHi   := pxH
            newHtfHiTm := hHiTm.get(iH)
            newHtfHiBi := hHiBi.get(iH)
        int iL = f_htfPivot(hL, false)
        if iL >= 0
            float prevMin = f_extreme(hLo, htfN - lookbackCdl, -1)
            float pxL = hL.get(iL)
            float minC = na
            for j = iL to nC - 1
                minC := na(minC) ? hC.get(j) : math.min(minC, hC.get(j))
            bool raid = not na(prevMin) and pxL < prevMin and minC > prevMin
            f_pushSwing(hLo, Swing.new(pxL, hLoTm.get(iL), hLoBi.get(iL), ordBase + iL, hCt.get(iL), raid))
            newHtfLo   := pxL
            newHtfLoTm := hLoTm.get(iL)
            newHtfLoBi := hLoBi.get(iL)
    if newCandle
        curO    := open
        curH    := high
        curL    := low
        curHiTm := time
        curHiBi := bar_index
        curLoTm := time
        curLoBi := bar_index
        curCt   := htfT
    else
        if high > curH
            curH    := high
            curHiTm := time
            curHiBi := bar_index
        if low < curL
            curL    := low
            curLoTm := time
            curLoBi := bar_index
    curC := close

    // ── The dealing range: form once, hold, rebuild only on a close through a side ──
    if na(drHiPx) or na(drLoPx)
        Swing hiS = f_extSwing(hHi, htfN - lookbackCdl, 1)
        Swing loS = f_extSwing(hLo, htfN - lookbackCdl, -1)
        if not na(hiS) and not na(loS) and hiS.px - loS.px >= minRangeAtr * atr
            drHiPx := hiS.px
            drHiTm := hiS.tm
            drHiBi := hiS.bi
            drHiCt := hiS.ct
            drLoPx := loS.px
            drLoTm := loS.tm
            drLoBi := loS.bi
            drLoCt := loS.ct
            drHiPend := false
            drLoPend := false
            drOutHi  := 0
            drOutLo  := 0
    else
        // A forming side follows price, and locks on the first range-timeframe swing after the break.
        if drHiPend
            if high >= drHiPx
                drHiPx := high
                drHiTm := time
                drHiBi := bar_index
                drHiCt := htfT
            if hHi.size() > 0
                Swing lastH = hHi.last()
                if lastH.bi >= drBreakBi
                    drHiPx := lastH.px
                    drHiTm := lastH.tm
                    drHiBi := lastH.bi
                    drHiCt := lastH.ct
                    drHiPend   := false
                    drBrokeDir := 0
        if drLoPend
            if low <= drLoPx
                drLoPx := low
                drLoTm := time
                drLoBi := bar_index
                drLoCt := htfT
            if hLo.size() > 0
                Swing lastL = hLo.last()
                if lastL.bi >= drBreakBi
                    drLoPx := lastL.px
                    drLoTm := lastL.tm
                    drLoBi := lastL.bi
                    drLoCt := lastL.ct
                    drLoPend   := false
                    drBrokeDir := 0
        // A close through a side, held past the reclaim allowance, is a break: that side is spent.
        if not drHiPend and not drLoPend
            drOutHi := close > drHiPx ? drOutHi + 1 : 0
            drOutLo := close < drLoPx ? drOutLo + 1 : 0
            if drOutHi > reclaimBars
                drBrokeDir := 1
                drBrokePx  := drHiPx
                drBrokeTm  := drHiTm
                drBreakBi  := bar_index - drOutHi
                Swing org = f_lastSwing(hLo, drBreakBi)
                if not na(org)
                    drLoPx := org.px
                    drLoTm := org.tm
                    drLoBi := org.bi
                    drLoCt := org.ct
                float mx = high
                int   mk = 0
                for k = 0 to drOutHi
                    if high[k] > mx
                        mx := high[k]
                        mk := k
                drHiPx := mx
                drHiTm := time[mk]
                drHiBi := bar_index - mk
                drHiCt := htfT[mk]
                drHiPend := true
                drOutHi  := 0
                drOutLo  := 0
            else if drOutLo > reclaimBars
                drBrokeDir := -1
                drBrokePx  := drLoPx
                drBrokeTm  := drLoTm
                drBreakBi  := bar_index - drOutLo
                Swing org = f_lastSwing(hHi, drBreakBi)
                if not na(org)
                    drHiPx := org.px
                    drHiTm := org.tm
                    drHiBi := org.bi
                    drHiCt := org.ct
                float mn = low
                int   mk = 0
                for k = 0 to drOutLo
                    if low[k] < mn
                        mn := low[k]
                        mk := k
                drLoPx := mn
                drLoTm := time[mk]
                drLoBi := bar_index - mk
                drLoCt := htfT[mk]
                drLoPend := true
                drOutHi  := 0
                drOutLo  := 0

    // ── Chart swings: the structure the MSS breaks and the leg the OTE measures ──
    if not na(ph)
        f_pushSwing(cHi, Swing.new(ph, time[pivLen], bar_index - pivLen, bar_index - pivLen, htfT[pivLen], false))
        newPh := ph
    if not na(pl)
        f_pushSwing(cLo, Swing.new(pl, time[pivLen], bar_index - pivLen, bar_index - pivLen, htfT[pivLen], false))
        newPl := pl
    if not na(ph) or not na(pl)
        newPvTm := time[pivLen]
        newPvBi := bar_index - pivLen

    // ── Peers and the catch-up timeframe ──
    if p1New
        f_pushCandle(peer1, p1H, p1L, p1T)
    if p2New
        f_pushCandle(peer2, p2H, p2L, p2T)
    if gNew and not na(gT1)
        if gL1 > gH3
            gapUpTm.push(gT1)
        if gH1 < gL3
            gapDnTm.push(gT1)
        if gapUpTm.size() > 50
            gapUpTm.shift()
        if gapDnTm.size() > 50
            gapDnTm.shift()

    // ── Mitigation of stored imbalances, before this bar's new ones join ──
    f_markMitigated(bullZ, 1)
    f_markMitigated(bearZ, -1)
    // ── Confirmed imbalances: suspension block, wick gap, volume imbalance ──
    float minH = minGapAtr * atr
    bool sbUp = close[2] > open[2] and close[1] > open[1] and close > open and open[1] > close[2] and open > close[1]
    bool sbDn = close[2] < open[2] and close[1] < open[1] and close < open and open[1] < close[2] and open < close[1]
    if joinNear and joinFar and sbUp and open - close[2] >= minH
        f_pushZone(bullZ, 2, open, close[2], time[2], bar_index)
    if joinNear and joinFar and sbDn and close[2] - open >= minH
        f_pushZone(bearZ, 2, close[2], open, time[2], bar_index)
    if low > high[2] and low - high[2] >= minH
        f_pushZone(bullZ, 0, low, high[2], time[1], bar_index - 1)
    if high < low[2] and low[2] - high >= minH
        f_pushZone(bearZ, 0, low[2], high, time[1], bar_index - 1)
    float bodyLo  = math.min(open, close)
    float bodyHi  = math.max(open, close)
    float pBodyLo = math.min(open[1], close[1])
    float pBodyHi = math.max(open[1], close[1])
    if joinNear and bodyLo > pBodyHi and low <= high[1] and bodyLo - pBodyHi >= minH
        f_pushZone(bullZ, 1, bodyLo, pBodyHi, time[1], bar_index)
    if joinNear and bodyHi < pBodyLo and high >= low[1] and pBodyLo - bodyHi >= minH
        f_pushZone(bearZ, 1, pBodyLo, bodyHi, time[1], bar_index)

    // ── Advance both directions ──
    bull := f_run(bull, evBull, hist, hLo, hHi, cHi, bullZ, bearZ)
    bear := f_run(bear, evBear, hist, hHi, hLo, cLo, bearZ, bullZ)
    // A side that has been raided stays dotted for as long as this range holds: solid is live,
    // dotted is spent, so the line itself reports the sweep and no tag has to sit in price. The
    // flags clear when the side moves, which is the range rebuilding rather than the same level
    // being raided twice.
    if drLoPx != drLoPx[1]
        drLoRaided := false
    if drHiPx != drHiPx[1]
        drHiRaided := false
    if evBull.swept
        drLoRaided := true
    if evBear.swept
        drHiRaided := true

    // ── The peers on this bar, and the SMT drawn where the sweep is ──
    f_peerLiqChart(bull, q1L, q2L)
    f_peerLiqChart(bear, q1H, q2H)
    f_drawSmt(bull)
    f_drawSmt(bear)

// ── Sweeps inside the range swing's confirmation lag, on the bar a setup arms ──
bool bullSwReq = barstate.isconfirmed and bull.justArmed
bool bearSwReq = barstate.isconfirmed and bear.justArmed
int  bullSwBack = bullSwReq ? bar_index - bull.pushBi - 1 : 0
int  bearSwBack = bearSwReq ? bar_index - bear.pushBi - 1 : 0
[swPxB, swTmB, swBiB, swFB] = f_findSweep(1, bull.liq, bullSwBack, bullSwReq)
[swPxS, swTmS, swBiS, swFS] = f_findSweep(-1, bear.liq, bearSwBack, bearSwReq)
if bullSwReq
    f_applySweep(bull, swPxB, swTmB, swBiB, swFB)
if bearSwReq
    f_applySweep(bear, swPxS, swTmS, swBiS, swFS)

if barstate.isconfirmed
    // ── OTE, on every live bar including the one the MSS confirmed on ──
    if bull.state == 3
        if oteSwing == 'Range timeframe'
            f_tryOte(bull, newHtfHi, newHtfHiTm, newHtfHiBi, time + 2 * msPerBar)
        else
            f_tryOte(bull, ph2, time[1], bar_index - 1, time + 2 * msPerBar)
        f_grade(bull, evBull)
    if bear.state == 3
        if oteSwing == 'Range timeframe'
            f_tryOte(bear, newHtfLo, newHtfLoTm, newHtfLoBi, time + 2 * msPerBar)
        else
            f_tryOte(bear, pl2, time[1], bar_index - 1, time + 2 * msPerBar)
        f_grade(bear, evBear)
    // ── Cross-check: re-read the peers on their new candles, watch for the catch-up gap ──
    if p1New or p2New
        f_xcUpdate(bull)
        f_xcUpdate(bear)
    if bull.state >= 2 and bull.state <= 3 and not bull.catchUp and f_isLaggard(bull) and f_catchUpGap(bull, bullZ)
        bull.catchUp   := true
        evBull.catchUp := true
    if bear.state >= 2 and bear.state <= 3 and not bear.catchUp and f_isLaggard(bear) and f_catchUpGap(bear, bearZ)
        bear.catchUp   := true
        evBear.catchUp := true

// The breaker search reads bar history, so it runs at global scope on every bar and only works
// on the bar an MSS confirmed.
bool bullBrkReq = barstate.isconfirmed and bull.state == 3 and bull.mssBi == bar_index and bull.brkPending and na(bull.brkTop)
bool bearBrkReq = barstate.isconfirmed and bear.state == 3 and bear.mssBi == bar_index and bear.brkPending and na(bear.brkTop)
int  bullBack   = bullBrkReq ? bar_index - bull.sweepBi : 0
int  bearBack   = bearBrkReq ? bar_index - bear.sweepBi : 0
// The leg into the sweep starts at the last chart swing on the far side before the sweep bar.
Swing bullOrg  = bullBrkReq ? f_lastSwing(cHi, bull.sweepBi - 1) : na
Swing bearOrg  = bearBrkReq ? f_lastSwing(cLo, bear.sweepBi - 1) : na
int  bullLeg   = bullBrkReq and not na(bullOrg) ? bar_index - bullOrg.bi : bullBack + 60
int  bearLeg   = bearBrkReq and not na(bearOrg) ? bar_index - bearOrg.bi : bearBack + 60
[bkT, bkB, bkTm, bkF] = f_findBlock(1, bullBack, bullLeg, cLo, bullBrkReq)
[skT, skB, skTm, skF] = f_findBlock(-1, bearBack, bearLeg, cHi, bearBrkReq)
if bullBrkReq
    f_setBreaker(bull, bkT, bkB, bkTm, bkF)
    f_grade(bull, evBull)
if bearBrkReq
    f_setBreaker(bear, skT, skB, skTm, skF)
    f_grade(bear, evBear)

// ── History: drop dead setups, keep the last N per direction ──
if barstate.isconfirmed and hist.size() > 0
    for i = hist.size() - 1 to 0
        if hist.get(i).state == 5
            hist.remove(i)
    int nBull = 0
    int nBear = 0
    if hist.size() > 0
        for i = 0 to hist.size() - 1
            if hist.get(i).dir > 0
                nBull += 1
            else
                nBear += 1
    while nBull > keepSetups or nBear > keepSetups
        int victimDir = nBull > keepSetups ? 1 : -1
        int victimI   = -1
        if hist.size() > 0
            for i = 0 to hist.size() - 1
                if victimI < 0 and hist.get(i).dir == victimDir
                    victimI := i
        if victimI >= 0
            Setup v = hist.get(victimI)
            f_wipe(v)
            v.state := 5
            hist.remove(victimI)
        if victimDir > 0
            nBull -= 1
        else
            nBear -= 1

// ============================================================================
// RANGE THIRDS — the position of price, optional dotted lines
// ============================================================================
//@function The setup whose range the console and the thirds read: the live one, else the swept one,
//          else whichever direction currently holds a range.
//@returns (Setup) A setup, possibly with no range, never na
f_focus() =>
    Setup r = bull
    if bull.state == 3 and bear.state == 3
        r := bull.mssBi >= bear.mssBi ? bull : bear
    else if bull.state == 3
        r := bull
    else if bear.state == 3
        r := bear
    else if bull.state == 2 and bear.state == 2
        r := bull.sweepBi >= bear.sweepBi ? bull : bear
    else if bull.state == 2
        r := bull
    else if bear.state == 2
        r := bear
    else if na(bull.tgt) and not na(bear.tgt)
        r := bear
    r

//@function Where price sits in a range.
//@param lo (float) Range low
//@param hi (float) Range high
//@returns (string) top third · middle · bottom third, or empty
f_position(float lo, float hi) =>
    string r = ''
    if not na(lo) and not na(hi) and hi > lo
        float f = (close - lo) / (hi - lo)
        r := f > 2.0 / 3.0 ? 'top third' : f < 1.0 / 3.0 ? 'bottom third' : 'middle'
    r

// ============================================================================
// DEALING RANGE — on the chart as soon as it exists
// ============================================================================
//@function Keeps one side of the range drawn, or removes it.
//@param ln (line) The existing line or na
//@param lb (label) The existing label or na
//@param show (bool) Whether the side shows
//@param x1 (int) The swing's time
//@param x2 (int) Right-hand end
//@param px (float) The level
//@param txt (string) Label text
//@param c (color) Line colour
//@param sty (string) Line style
//@returns ([line, label]) The drawings, na when hidden
f_rngSide(line ln, label lb, bool show, int x1, int x2, float px, string txt, color c, string sty, bool isHigh) =>
    line  l2 = ln
    label b2 = lb
    if not show and not na(l2)
        line.delete(l2)
        label.delete(b2)
        l2 := na
        b2 := na
    // The name sits OUTSIDE its own level - above a buyside pool, below a sellside one - anchored by
    // its corner at the line's end, so the text begins exactly where the line stops and runs away
    // into clear space. Centring it on the anchor, whichever side, printed it straight through the
    // line it was naming.
    string lSty = isHigh ? label.style_label_lower_left : label.style_label_upper_left
    if show and na(l2)
        l2 := f_level(x1, x2, px, c, liqWidth, sty)
        b2 := f_lbl(x2, px, txt, lSty)
    if show and not na(l2)
        line.set_xy1(l2, x1, px)
        line.set_xy2(l2, x2, px)
        line.set_color(l2, c)
        line.set_style(l2, sty)
        label.set_xy(b2, x2, px)
        label.set_text(b2, txt)
        label.set_style(b2, lSty)
    [l2, b2]

var line  rngHiLn  = na
var line  rngLoLn  = na
var line  rngBrkLn = na
var label rngHiLbl = na
var label rngLoLbl = na
var label rngBrkLbl = na

if drawRange
    int  runway = time + runwayBars * msPerBar
    bool have   = not na(drHiPx) and not na(drLoPx)
    // A side a setup already draws — the sweep line on the raided side, the target line after the
    // MSS — is not drawn twice.
    bool loOwned = bull.state >= 2 or bear.state >= 3
    bool hiOwned = bear.state >= 2 or bull.state >= 3
    // A raided side is spent. Unless he is keeping taken liquidity, it comes OFF - the dotted style
    // says it is spent, but a line on the chart is still a line being read as a draw.
    bool showLo  = have and not loOwned and (poolKeep or not drLoRaided)
    bool showHi  = have and not hiOwned and (poolKeep or not drHiRaided)
    string loTxt = 'SSL · ERL · ' + RTF_NAME + (drLoPend ? ' · forming' : bear.state == 2 ? ' · draw' : '')
    string hiTxt = 'BSL · ERL · ' + RTF_NAME + (drHiPend ? ' · forming' : bull.state == 2 ? ' · draw' : '')
    // SOLID IS LIVE, DOTTED IS SPENT — the one line-style rule this whole stack runs on, and the
    // only thing the style is allowed to say. A side that is still FORMING has not been taken, so it
    // is live and it is SOLID; "forming" is carried by the text, which is where a provisional state
    // belongs. Only a RAID dots a side. (Before this, a forming side drew dotted and a broken side
    // drew solid — the rule exactly inverted on both.)
    [l1, b1] = f_rngSide(rngLoLn, rngLoLbl, showLo, drLoTm, runway, drLoPx, loTxt, liqCol, drLoRaided ? line.style_dotted : line.style_solid, false)
    [l2, b2] = f_rngSide(rngHiLn, rngHiLbl, showHi, drHiTm, runway, drHiPx, hiTxt, liqCol, drHiRaided ? line.style_dotted : line.style_solid, true)
    // The side price closed through stays, grey, until the side replacing it has formed. It is spent,
    // so it is DOTTED, and the word is gone with it: the same ruling that removed the Sweep tag —
    // a label paying to say what the style already says.
    bool showBrk = have and drBrokeDir != 0 and poolKeep
    string brkTxt = (drBrokeDir > 0 ? 'BSL' : 'SSL') + ' · ERL · ' + RTF_NAME
    [l3, b3] = f_rngSide(rngBrkLn, rngBrkLbl, showBrk, drBrokeTm, runway, drBrokePx, brkTxt, C_GRAY, line.style_dotted, drBrokeDir > 0)
    rngLoLn   := l1
    rngLoLbl  := b1
    rngHiLn   := l2
    rngHiLbl  := b2
    rngBrkLn  := l3
    rngBrkLbl := b3

var line thirdLo  = na
var line thirdHi  = na
var label thirdLoLbl = na
var label thirdHiLbl = na

// ============================================================================
// LIQUIDITY POOLS
// ============================================================================
//@function Books a pool, or merges it into an unswept one already at that price. Merging is what
//          makes a cluster of near-equal highs ONE level called EQH instead of six lines: the pool
//          keeps the MORE EXTREME price, because that is the one a raid has to take out.
//@param px (float) The level.
//@param tm (int) Bar time of the swing that made it.
//@param isHigh (bool) Buyside or sellside.
//@param origin (string) What made it - 'Swing', 'PDH', 'PWL' and so on.
//@param tol (float) Equal-level tolerance in price.
//@returns (bool) Always true.
f_bookPool(float px, int tm, bool isHigh, string origin, float tol) =>
    if not na(px) and not na(tm)
        bool merged = false
        if pools.size() > 0
            for i = 0 to pools.size() - 1
                Pool p = pools.get(i)
                if not merged and p.isHigh == isHigh and not p.taken and math.abs(p.px - px) <= tol
                    merged     := true
                    p.touches  += 1
                    p.px       := isHigh ? math.max(p.px, px) : math.min(p.px, px)
                    // A period level keeps its own name; two plain swings become an equal pool.
                    p.origin   := p.origin == 'Swing' and origin == 'Swing' ? (isHigh ? 'REH' : 'REL') : p.origin
        if not merged
            pools.push(Pool.new(px = px, tm = tm, isHigh = isHigh, origin = origin))
        while pools.size() > POOL_CAP
            Pool old = pools.shift()
            if not na(old.ln)
                line.delete(old.ln)
            if not na(old.lb)
                label.delete(old.lb)
    true

// Book the chart's own confirmed swings. ph/pl are the script's existing pivots, so a pool and the
// structure this script already reads come from the same definition rather than a second one.
float poolTol = nz(atrStruct, atr) * poolEqAtr
if poolsOn and poolSwing and barstate.isconfirmed
    if not na(ph)
        f_bookPool(ph, time[pivLen], true,  'Swing', poolTol)
    if not na(pl)
        f_bookPool(pl, time[pivLen], false, 'Swing', poolTol)

// Previous day and previous week, on the NEW YORK clock - these are ICT definitions stated in New
// York time, so any other clock reports a different window under the same name.
[pdH_, pdL_, pdT_] = request.security(syminfo.tickerid, 'D', [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[pwH_, pwL_, pwT_] = request.security(syminfo.tickerid, 'W', [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
if poolsOn and poolPd and not na(pdT_) and pdT_ != nz(pdT_[1], 0)
    f_bookPool(pdH_, pdT_, true,  'PDH', poolTol)
    f_bookPool(pdL_, pdT_, false, 'PDL', poolTol)
if poolsOn and poolPw and not na(pwT_) and pwT_ != nz(pwT_[1], 0)
    f_bookPool(pwH_, pwT_, true,  'PWH', poolTol)
    f_bookPool(pwL_, pwT_, false, 'PWL', poolTol)

// Taken the moment price trades through, WICK INCLUDED - a raid is a raid whether or not the candle
// closed beyond it. Untaken pools are dropped entirely unless he is keeping them.
if poolsOn and pools.size() > 0
    for i = pools.size() - 1 to 0
        Pool p = pools.get(i)
        if not p.taken and (p.isHigh ? high >= p.px : low <= p.px)
            p.taken := true
        if p.taken and not poolKeep
            if not na(p.ln)
                line.delete(p.ln)
            if not na(p.lb)
                label.delete(p.lb)
            pools.remove(i)

// ── Draw the pools: nearest to price first, capped per side, out of range dropped ──────────
if poolsOn and barstate.islast and pools.size() > 0
    int   pRun   = time + runwayBars * msPerBar
    float maxDst = atr * poolMaxAtr
    int   shownH = 0
    int   shownL = 0
    // Nearest first, so the cap keeps the pools in play rather than the oldest ones.
    array<int> nearIdx = array.new<int>()
    for i = 0 to pools.size() - 1
        nearIdx.push(i)
    for a = 0 to nearIdx.size() - 1
        for b = 0 to nearIdx.size() - 2
            Pool x = pools.get(nearIdx.get(b))
            Pool y = pools.get(nearIdx.get(b + 1))
            if math.abs(x.px - close) > math.abs(y.px - close)
                int t = nearIdx.get(b)
                nearIdx.set(b, nearIdx.get(b + 1))
                nearIdx.set(b + 1, t)
    for k = 0 to nearIdx.size() - 1
        Pool p = pools.get(nearIdx.get(k))
        bool room = p.isHigh ? shownH < poolMax : shownL < poolMax
        bool near = math.abs(p.px - close) <= maxDst
        // A lone swing is one candle, not resting liquidity. Liquidity Levels+ draws a pool only
        // when TWO pivots rest at the same price, and that is the definition used here: a plain
        // 'Swing' has merged nothing, so it never reaches the chart. A named period level - PDH,
        // PWL - is a pool on its own and is exempt.
        bool paired = not poolPaired or p.origin != 'Swing'
        // ERL is EXTERNAL. Anything resting between the two range edges is internal liquidity and
        // belongs to the range, not beside it - drawing it is what buried the chart in lines.
        // A range with a side still forming is not a range yet - filtering against its provisional
        // edges made pools blink out and back as those edges settled.
        bool drReady = not na(drHiPx) and not na(drLoPx) and not drHiPend and not drLoPend
        bool outside = not poolOutside or not drReady or p.px >= drHiPx or p.px <= drLoPx
        // Taken is taken. The take block already drops a run pool from the store when he is not
        // keeping them; this is the second gate, for the bar it is taken on.
        bool show = room and near and paired and outside and (poolKeep or not p.taken)
        if show
            if p.isHigh
                shownH += 1
            else
                shownL += 1
        string ptxt = (p.isHigh ? 'BSL' : 'SSL') + ' · ' + p.origin + (p.touches > 1 ? ' x' + str.tostring(p.touches) : '') + ' '
        // Same language as every other level in this script: solid while live, dotted once taken.
        [pl2, pb2] = f_rngSide(p.ln, p.lb, show, p.tm, pRun, p.px, ptxt, p.taken ? C_GRAY : liqCol, p.taken ? line.style_dotted : line.style_solid, p.isHigh)
        p.ln := pl2
        p.lb := pb2

if showThirds and barstate.islast
    Setup f = f_focus()
    float lo = math.min(f.liq, f.tgt)
    float hi = math.max(f.liq, f.tgt)
    if not na(lo) and not na(hi)
        int   x1 = math.max(f.liqTm, f.tgtTm)
        int   x2 = time + runwayBars * msPerBar
        float t1 = lo + (hi - lo) / 3
        float t2 = lo + 2 * (hi - lo) / 3
        if na(thirdLo)
            thirdLo    := f_level(x1, x2, t1, C_GRAY, 1, line.style_dotted)
            thirdHi    := f_level(x1, x2, t2, C_GRAY, 1, line.style_dotted)
            // Splayed apart: the lower third's name sits below its line, the upper third's above,
            // so neither crosses its own line and the two never meet in the middle.
            thirdLoLbl := f_lbl(x2, t1, '1/3', label.style_label_upper_left)
            thirdHiLbl := f_lbl(x2, t2, '2/3', label.style_label_lower_left)
        else
            line.set_xy1(thirdLo, x1, t1)
            line.set_xy2(thirdLo, x2, t1)
            line.set_xy1(thirdHi, x1, t2)
            line.set_xy2(thirdHi, x2, t2)
            label.set_xy(thirdLoLbl, x2, t1)
            label.set_xy(thirdHiLbl, x2, t2)

// ============================================================================
// CONSOLE — verdict first, silent rows dropped
// ============================================================================
//@function Resolves the console position input.
//@param p (string) The input value
//@returns (string) A position.* constant
f_pos(string p) =>
    switch p
        'Top left'     => position.top_left
        'Bottom right' => position.bottom_right
        'Bottom left'  => position.bottom_left
        =>                position.top_right

var table con = na

//@function Writes one console cell: the name in italics with the value beneath it, both ink.
//@param col (int) Column — 0 the setup, 1 the peers and context
//@param row (int) Pair index down that column, 0-based
//@param name (string) Top line
//@param val (string) Bottom line
//@param bold (bool) Bold the value
//@returns (void)
f_col(int col, int row, string name, string val, bool bold) =>
    int r = 1 + 2 * row
    table.cell(con, col, r, name, text_color = C_INK, text_size = LBL_SZ, text_halign = text.align_left,
         text_font_family = font.family_monospace, bgcolor = #FFFFFF, text_formatting = text.format_italic)
    if bold
        table.cell(con, col, r + 1, val, text_color = C_INK, text_size = LBL_SZ, text_halign = text.align_left,
             text_font_family = font.family_monospace, bgcolor = #FFFFFF, text_formatting = text.format_bold)
    else
        table.cell(con, col, r + 1, val, text_color = C_INK, text_size = LBL_SZ, text_halign = text.align_left,
             text_font_family = font.family_monospace, bgcolor = #FFFFFF)

//@function Writes a column header on the console's top row.
//@param col (int) Column
//@param txt (string) Header text
//@returns (void)
f_head(int col, string txt) =>
    table.cell(con, col, 0, txt, text_color = C_INK, text_size = LBL_SZ, text_halign = text.align_left,
         text_font_family = font.family_monospace, bgcolor = #FFFFFF, text_formatting = text.format_bold)

//@function Risk-to-reward from the nearest internal array to the draw, stop at the sweep extreme.
//@param s (Setup) A live setup
//@returns (float) The ratio, or na when no array has formed
f_rr(Setup s) =>
    int d = s.dir
    float entry = na
    if s.hasSb
        entry := d > 0 ? s.sbTop : s.sbBot
    else if s.hasFvg
        entry := d > 0 ? s.fvgTop : s.fvgBot
    else if s.hasVi
        entry := d > 0 ? s.viTop : s.viBot
    else if s.hasIfvg
        entry := d > 0 ? s.ifvgTop : s.ifvgBot
    else if s.hasOte
        entry := d > 0 ? s.oteTop : s.oteBot
    float risk   = math.abs(entry - s.sweepPx)
    float reward = math.abs(s.tgt - entry)
    (na(entry) or risk <= 0) ? na : reward / risk

//@function One peer's state on the target side, as console text.
//@param taken (int) The taken time, or na
//@returns (string)
f_peerWord(int taken) =>
    na(taken) ? 'lags' : 'taken'

//@function The most recent finished setup in the history store, or na.
//@returns (Setup)
f_lastDone() =>
    Setup r = na
    int n = hist.size()
    if n > 0
        for i = 0 to n - 1
            Setup h = hist.get(i)
            if h.state == 4 and (na(r) or h.mssBi > r.mssBi)
                r := h
    r

//@function A price as text at the symbol's tick.
//@param p (float) The price
//@returns (string)
f_px(float p) =>
    str.tostring(p, format.mintick)

//@function Formats a millisecond span as a countdown.
//@param ms (int) Milliseconds remaining
//@returns (string) hh:mm:ss, prefixed with days when over a day
f_countdown(int ms) =>
    int totalSec = math.max(math.floor(ms / 1000), 0)
    int days = math.floor(totalSec / 86400)
    int hrs  = math.floor((totalSec % 86400) / 3600)
    int mins = math.floor((totalSec % 3600) / 60)
    int secs = totalSec % 60
    string hhmmss = str.format('{0,number,00}:{1,number,00}:{2,number,00}', hrs, mins, secs)
    days > 0 ? str.tostring(days) + 'd ' + hhmmss : hhmmss

// ============================================================================
// PO3 CANDLE — the live range-timeframe candle beside price, as PO3 Candle (M1D) draws it
// ============================================================================
// Rebuilt in place on every tick of the last bar, never left as history. Sanctioned candle-body
// colours (white up, dark down, black outline) — it is a literal candle, not a directional array.
var box   po3Body   = na
var line  po3WickUp = na
var line  po3WickDn = na
var line  po3LvlO   = na
var line  po3LvlH   = na
var line  po3LvlL   = na
var line  po3LvlC   = na
var line  po3Div    = na
var label po3TagO   = na
var label po3TagH   = na
var label po3TagL   = na
var label po3TagC   = na
bool po3Valid = showPo3 and not sameTf

//@function Creates a dotted reference line once, then moves it; removes it when not shown.
//@param existing (line) The stored handle, na on first call
//@param x1 (int) Left time
//@param x2 (int) Right time
//@param price (float) The level
//@param show (bool) Whether the line should exist
//@returns (line) The live handle, or na
f_po3Level(line existing, int x1, int x2, float price, bool show) =>
    line h = existing
    if not show
        line.delete(h)
        h := na
    else if na(h)
        h := line.new(x1, price, x2, price, xloc = xloc.bar_time, color = po3Edge, width = 1, style = line.style_dotted)
    else
        line.set_xy1(h, x1, price)
        line.set_xy2(h, x2, price)
    h

//@function Creates a price tag once, then moves it; removes it when not shown.
//@param existing (label) The stored handle, na on first call
//@param x (int) Anchor time
//@param price (float) The level
//@param show (bool) Whether the tag should exist
//@returns (label) The live handle, or na
f_po3Tag(label existing, int x, float price, bool show) =>
    label h = existing
    if not show
        label.delete(h)
        h := na
    else if na(h)
        h := f_lbl(x, price, f_px(price), label.style_label_lower_left)
    else
        label.set_xy(h, x, price)
        label.set_text(h, f_px(price))
    h

// The candle's live values. On the bar that opens a new range candle the aggregates still hold the
// previous one until that bar confirms, so the bar's own values are used instead.
float po3O  = newCandle ? open : curO
float po3H  = newCandle ? high : math.max(curH, high)
float po3L  = newCandle ? low  : math.min(curL, low)
float po3C  = close
int   po3Ct = newCandle ? htfT : curCt

// A PO3 price sitting on a live ERL is ONE level: the ERL label carries the candle's name for it
// and the candle's own tag and line are dropped, so nothing stacks on the line or gets clipped.
bool po3MergeO = false
bool po3MergeH = false
bool po3MergeL = false
bool po3MergeC = false
if barstate.islast and hist.size() > 0
    float tol = syminfo.mintick
    for i = 0 to hist.size() - 1
        Setup hs = hist.get(i)
        if (hs.state == 3 or hs.state == 4) and not na(hs.tgtLbl)
            string extra = ''
            if po3Valid
                if math.abs(po3O - hs.tgt) <= tol
                    extra += ' · ' + RTF_NAME + ' open'
                    po3MergeO := true
                if math.abs(po3H - hs.tgt) <= tol
                    extra += ' · ' + RTF_NAME + ' high'
                    po3MergeH := true
                if math.abs(po3L - hs.tgt) <= tol
                    extra += ' · ' + RTF_NAME + ' low'
                    po3MergeL := true
                if math.abs(po3C - hs.tgt) <= tol
                    extra += ' · ' + RTF_NAME + ' close'
                    po3MergeC := true
            label.set_text(hs.tgtLbl, f_tgtText(hs) + extra)

if barstate.islast and po3Valid
    int   leftX   = time + (runwayBars + po3Gap) * msPerBar
    int   rightX  = leftX + po3Wide * msPerBar
    int   midX    = leftX + math.round(po3Wide * msPerBar / 2)
    bool  isUp    = po3C >= po3O
    color bodyCol = isUp ? po3Up : po3Dn
    float bodyTop = math.max(po3O, po3C)
    float bodyBot = math.min(po3O, po3C)
    if bodyTop - bodyBot < syminfo.mintick
        // A doji still gets a body one tick tall, so the candle never collapses to a line.
        bodyTop := bodyBot + syminfo.mintick
    // Body — a candle IS a block, so it shows a hard edge; the fill says direction.
    if na(po3Body)
        po3Body := box.new(leftX, bodyTop, rightX, bodyBot, xloc = xloc.bar_time, border_color = po3Edge, border_width = 1, bgcolor = bodyCol)
    else
        box.set_lefttop(po3Body, leftX, bodyTop)
        box.set_rightbottom(po3Body, rightX, bodyBot)
        box.set_bgcolor(po3Body, bodyCol)
    // Wicks — from the body to each extreme, up the centre of the body.
    if na(po3WickUp)
        po3WickUp := line.new(midX, bodyTop, midX, po3H, xloc = xloc.bar_time, color = po3Edge, width = 1)
        po3WickDn := line.new(midX, bodyBot, midX, po3L, xloc = xloc.bar_time, color = po3Edge, width = 1)
    else
        line.set_xy1(po3WickUp, midX, bodyTop)
        line.set_xy2(po3WickUp, midX, po3H)
        line.set_xy1(po3WickDn, midX, bodyBot)
        line.set_xy2(po3WickDn, midX, po3L)
    // Reference lines — each price carried back to the bar that opened the candle. The close is
    // the live price, so its line runs only from the live candle to the drawn one.
    po3LvlO := f_po3Level(po3LvlO, po3Ct, leftX, po3O, po3Levels and not po3MergeO)
    po3LvlH := f_po3Level(po3LvlH, po3Ct, midX,  po3H, po3Levels and not po3MergeH)
    po3LvlL := f_po3Level(po3LvlL, po3Ct, midX,  po3L, po3Levels and not po3MergeL)
    po3LvlC := f_po3Level(po3LvlC, time,  leftX, po3C, po3Levels and not po3MergeC)
    // Open divider — the left wall of the candle's zone.
    if po3Divider
        if na(po3Div)
            po3Div := line.new(po3Ct, po3H, po3Ct, po3L, xloc = xloc.bar_time, color = po3Edge, width = 1, style = line.style_dotted, extend = po3FullDiv ? extend.both : extend.none)
        else
            line.set_xy1(po3Div, po3Ct, po3H)
            line.set_xy2(po3Div, po3Ct, po3L)
    // Price tags at the candle's right edge.
    po3TagO := f_po3Tag(po3TagO, rightX, po3O, po3Tags and not po3MergeO)
    po3TagH := f_po3Tag(po3TagH, rightX, po3H, po3Tags and not po3MergeH)
    po3TagL := f_po3Tag(po3TagL, rightX, po3L, po3Tags and not po3MergeL)
    po3TagC := f_po3Tag(po3TagC, rightX, po3C, po3Tags and not po3MergeC)

if showConsole and barstate.islast
    if na(con)
        con := table.new(f_pos(conPos), CON_COLS, 1 + 2 * CON_ROWS, bgcolor = #FFFFFF, frame_color = C_INK, frame_width = 1, border_width = 0)
    table.clear(con, 0, 0, CON_COLS - 1, 2 * CON_ROWS)
    Setup f = f_focus()
    float rLo = math.min(f.liq, f.tgt)
    float rHi = math.max(f.liq, f.tgt)
    string pos = f_position(rLo, rHi)
    string dirWord = f.dir > 0 ? 'Long' : 'Short'
    // ── Column 0: the setup on this chart — verdict, range, draw, sequence ──
    f_head(0, 'Setup · ' + TF_NAME)
    int cL = 0
    if f.state == 3
        f_col(0, cL, dirWord, f_gradeText(f.grade), true)
    else if f.state == 2
        f_col(0, cL, dirWord, f.waitDisp ? 'Swept · no displacement' : 'Swept · no MSS', true)
    else
        f_col(0, cL, 'Waiting', f.state == 1 ? 'Armed' : 'No range', true)
    cL += 1
    if not na(rLo) and not na(rHi)
        f_col(0, cL, 'Range ' + RTF_NAME + ' · ' + pos, f_px(rLo) + '–' + f_px(rHi), false)
        cL += 1
        if f.state >= 2
            string rrTxt = ''
            if f.state == 3
                float rr = f_rr(f)
                if not na(rr)
                    rrTxt := ' · RR ' + str.tostring(rr, '#.0') + (rr >= minRR ? ' ✓' : '')
            f_col(0, cL, 'Draw ' + (f.dir > 0 ? 'BSL ' : 'SSL ') + f_px(f.tgt), f_px(math.abs(f.tgt - close)) + ' away' + rrTxt, false)
        else
            f_col(0, cL, 'Draw', 'BSL +' + f_px(rHi - close) + ' · SSL −' + f_px(close - rLo), false)
        cL += 1
    if f.state >= 2
        f_col(0, cL, 'Sweep · MSS · OTE', '✓ · ' + (f.state == 3 ? '✓' : '·') + ' · ' + (f.hasOte ? '✓' : '·'), false)
        cL += 1
    // ── Column 1: the peers, then context — draw check, peers, catch-up, last, range candle ──
    f_head(1, xcLive ? peer1Name + ' · ' + peer2Name : 'Context')
    int cR = 0
    if f.xcSet
        bool p1T = not na(f.p1TgtTaken)
        bool p2T = not na(f.p2TgtTaken)
        string verdict = f.selfTgtTaken and p1T and p2T ? 'Taken · all three' :
             not f.selfTgtTaken and (p1T or p2T) ? 'Laggard ' + selfName + ' · trade' :
             f.selfTgtTaken and not (p1T and p2T) ? 'Peer lags ' + (p1T ? peer2Name : peer1Name) :
             'Open draw'
        string smtTxt = ''
        if f.state >= 2 and (na(f.p1LiqTaken) or na(f.p2LiqTaken))
            smtTxt := ' · SMT ' + (na(f.p1LiqTaken) ? peer1Name : peer2Name)
        f_col(1, cR, 'Draw check', verdict, true)
        cR += 1
        f_col(1, cR, 'Draw taken', f_peerWord(f.p1TgtTaken) + ' · ' + f_peerWord(f.p2TgtTaken) + smtTxt, false)
        cR += 1
        if f_isLaggard(f)
            f_col(1, cR, 'Catch-up gap ' + GTF_NAME, f.catchUp ? '✓' : '·', false)
            cR += 1
    Setup last = f_lastDone()
    if not na(last) and last.state == 4 and f.state != 3
        f_col(1, cR, 'Last', (last.dir > 0 ? 'Long' : 'Short') + ' · ' + f_gradeText(last.grade) + ' · ' + last.outcome, false)
        cR += 1
    if po3Valid
        f_col(1, cR, RTF_NAME + ' candle', f_countdown(time_close(rangeTf) - timenow) + ' · ' + f_px(po3H - po3L) + ' range', false)
        cR += 1

// ============================================================================
// ALERTS — script scope, confirmed closes only
// ============================================================================
bool alBullSw  = evBull.swept
bool alBearSw  = evBear.swept
bool alBullMss = evBull.mss
bool alBearMss = evBear.mss
bool alBullA   = evBull.a
bool alBearA   = evBear.a
bool alBullAp  = evBull.ap
bool alBearAp  = evBear.ap
bool alBullCu  = evBull.catchUp
bool alBearCu  = evBear.catchUp

alertcondition(alBullSw,  'Sellside swept · watching for the MSS', 'ERL x IRL PO3: sellside liquidity swept on {{ticker}} {{interval}}, watching for the MSS')
alertcondition(alBearSw,  'Buyside swept · watching for the MSS',  'ERL x IRL PO3: buyside liquidity swept on {{ticker}} {{interval}}, watching for the MSS')
alertcondition(alBullMss, 'Bullish MSS confirmed', 'ERL x IRL PO3: bullish MSS confirmed on {{ticker}} {{interval}}')
alertcondition(alBearMss, 'Bearish MSS confirmed', 'ERL x IRL PO3: bearish MSS confirmed on {{ticker}} {{interval}}')
alertcondition(alBullA,   'Bullish grade A',       'ERL x IRL PO3: bullish setup graded A on {{ticker}} {{interval}}')
alertcondition(alBearA,   'Bearish grade A',       'ERL x IRL PO3: bearish setup graded A on {{ticker}} {{interval}}')
alertcondition(alBullAp,  'Bullish grade A+',      'ERL x IRL PO3: bullish setup graded A+ on {{ticker}} {{interval}}')
alertcondition(alBearAp,  'Bearish grade A+',      'ERL x IRL PO3: bearish setup graded A+ on {{ticker}} {{interval}}')
alertcondition(alBullCu,  'Bullish catch-up gap',  'ERL x IRL PO3: {{ticker}} is the laggard, bullish catch-up gap printed')
alertcondition(alBearCu,  'Bearish catch-up gap',  'ERL x IRL PO3: {{ticker}} is the laggard, bearish catch-up gap printed')
````
