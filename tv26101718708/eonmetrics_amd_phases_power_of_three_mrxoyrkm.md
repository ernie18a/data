# EonMetrics AMD Phases (Power of Three)

- url: https://www.tradingview.com/script/MRXOyRkm-EonMetrics-AMD-Phases-Power-of-Three/
- type: indicator
- pine_id: PUB;ed2682126fc24390b53a5a034c3110f3
- version: 1.0

## Description

AMD Phases (Power of Three) by EonMetrics

https://www.tradingview.com/x/ISZLqOsz/

🔶[b]WHAT IT DOES[/b]

"AMD" stands for Accumulation, Manipulation, Distribution — a classic three-step pattern also known as the "Power of Three". The idea behind the model: price first goes quiet and builds a tight sideways range (accumulation), then briefly pokes out of that range to trigger the stop-losses resting just beyond it and immediately comes back inside (manipulation — a failed breakout, often called a stop hunt or liquidity sweep), and finally makes its real move in the opposite direction of that fake-out (distribution).

This indicator finds and labels these three phases on your chart, in order, as each one completes — and, through a live panel, tells you at every moment which phase is confirmed, which step the model requires next, and at exactly what price the script will register that step.

It is a structure-annotation tool. It does not give buy/sell signals or entry orders. It measures, on the history loaded in your chart, what price actually did after each completed sequence and shows you that count, and it draws the measured objective on the chart as a reference marker — a level the tool measures against, never a recommendation to place an order there.

🔶[b]THE LIVE PANEL — THE PART THAT WORKS WHILE THE PATTERN IS STILL FORMING[/b]

A phase label can only be drawn once that phase has already finished. The panel covers everything before that moment: it reads the script's own state machine out loud, row by row:

- PHASE — which of the three steps is confirmed right now, with a 3-block meter. SCANNING means no qualifying range yet. SWEEP HIGH / SWEEP LOW means an edge was pierced but price has not yet closed back inside, so manipulation is NOT confirmed yet.
- RANGE — the locked upper and lower edge of the current accumulation range.
- NEXT — the step the AMD model requires next.
- LEVEL — the exact price at which this script will register that step: the sweep trigger levels while accumulating, the reclaim price while a sweep is pending, the confirmation level while waiting for distribution.
- WINDOW — how many bars are left before the current episode times out and is discarded.
- FAILS IF — the specific condition that would invalidate the episode.
- EPISODES — a running count on the history loaded in your chart: how many ranges locked (A), how many of those were swept and reclaimed (M), how many reached distribution confirmation (D), and what percentage of locked ranges completed the whole sequence.

Read NEXT and LEVEL as "this is the condition the script is waiting for", never as "this is what price will do". The AMD sequence frequently does not complete. That is precisely why the EPISODES row is built into the panel and why failed episodes stay drawn on the chart by default — so the completion rate you see is the one your own market actually produced, not a selected highlight.

🔶[b]HOW IT DETECTS EACH PHASE (THE EXACT METHOD)[/b]

1. Accumulation ("A" label + blue box): the script measures the total height (highest high minus lowest low) of the last N bars. When that height stays below a chosen multiple of ATR (a standard volatility measure) for enough consecutive closed bars, the area qualifies as an accumulation range and its top and bottom edges are locked in. While price keeps quietly respecting the range, the box keeps extending.

2. Manipulation ("M" label + orange box): after the range is set, the script waits for price to pierce one of the edges by at least a minimum ATR-scaled distance (so a one-tick poke does not count). This alone is NOT manipulation yet — the pierce only counts if price then FAILS to hold outside and closes back inside the range within a small number of bars. If any bar closes beyond the pierced edge and the strict option is enabled, the move is treated as a genuine breakout and the episode is discarded. Only a failed, reclaimed sweep gets the "M" mark.

Optionally, the sweep can be required to also trade through a confirmed swing high or swing low — an actual resting-liquidity level — rather than merely poking past the box edge. This is the strictest available definition of a stop hunt in the script: it rejects pierces of an arbitrary boundary that collected no stops, at the cost of far fewer episodes.

3. Distribution ("D" label, teal for up / red for down): after the failed sweep, the script watches a limited window of bars for confirmation in the opposite direction. By default this confirmation is a structure break, measured against the rolling structure extreme in the 2 × Swing Length bars ending with the sweep. A close beyond that extreme means the sweeping move has been undone. You can switch the confirmation to a close beyond the range midpoint, or beyond the opposite edge of the range (strictest — this requires price to cross the whole range). If price instead takes out the manipulation extreme, or the window runs out, the episode is discarded as failed.

4. Liquidity pools (thin red and teal lines): independently of the phase episodes, the script draws a horizontal line at every confirmed swing high (red, above price) and swing low (teal, below price) — the classic levels where resting stop-loss orders accumulate. Each line stops extending the moment price trades through it, so untapped liquidity stays visible while collected liquidity visibly ends. These lines give context to the phases: sweeps and structure breaks usually happen exactly at them. The levels are tracked internally whether or not the lines are displayed.

https://www.tradingview.com/x/AHPGpIzv/

Everything is evaluated on closed bars only, so labels and boxes do not repaint: once a phase is marked, it stays where it was marked. Only the panel's WINDOW countdown and the current price levels update as new bars close.

🔶[b]ORIGINALITY[/b]

This is not a generic session box or a sweep marker. It uses one closed-bar state machine that requires all three phases to occur in order: a compressed range, a reclaimed sweep beyond that range, and a separately confirmed move away from the swept side. The panel makes the state of that sequence visible before it completes, including its exact confirmation and failure conditions.

The script also keeps failed episodes visible by default and counts them alongside completed ones. That makes the chart show the full record of the model on loaded history, rather than only its completed examples. The Follow-Through table is a separate measurement layer: it evaluates what happened after confirmed sequences using levels derived from each sequence itself.

🔶[b]THE FOLLOW-THROUGH TABLE — WHAT HAPPENED AFTER THE PATTERN COMPLETED
[/b]
Completing a pattern and going somewhere afterwards are two different things, so the script measures the second one separately and shows the count in its own small table.

Every level in that measurement comes from the pattern itself, not from a setting you have to guess:

- The reference price is the closing price of the confirmation bar — the bar that produced the "D".
- The risk unit is the distance from that price back to the manipulation extreme, the tip of the sweep. That is the level the model itself treats as invalidation, so it defines one unit of risk.
- The objective is that same distance multiplied by the "Risk / Reward (RR)" setting, in the confirmed direction.

Starting with the first completed bar after confirmation, the script follows price until one of two things happens first: the objective is reached, or price returns to the manipulation extreme. The table reports REACHED, INVALIDATED, UNRESOLVED (still running) and the resulting RATE, for example 20/35 (57%).

At the moment of each confirmation the objective level is also drawn on the chart as a short horizontal line, tagged with the R multiple you chose (1R, 2R, and so on). It is the exact level the table measures against, placed there so you can see where the measurement is taken. It is a marker of the measurement, not a take-profit order and not a recommendation to trade to it — the same caution the whole table carries applies to the line.

The RATE is coloured against the indifference line for the objective you chose, which is 100 / (1 + objective) percent — 50% at a 1.0 objective, 33% at 2.0, 25% at 3.0. That is simply the rate at which the two outcomes cancel each other out arithmetically, before any trading costs. The colour marks which side of that line this particular history fell on; it does not mean the pattern is or is not profitable, because commissions, spread and slippage appear nowhere in this table.

After confirmation, bars where price touched both levels are counted as INVALIDATED, because the order of events inside a single bar cannot be determined from this data. That is the conservative choice and it means the REACHED count is, if anything, understated. The confirmation bar itself establishes the reference price and is not evaluated as a follow-through outcome.

Read this table as a description of what this pattern did on the history your chart happens to have loaded, on the settings you happen to have chosen. It is not a backtest of a trading system: it contains no commission, no spread, no slippage, no position sizing and no partial exits. It is not a forecast. Change the symbol, the timeframe, the settings or the amount of history your plan loads and the number will change. If you find yourself adjusting settings until this number looks good, you are fitting the settings to the past, and the number stops telling you anything.

🔶[b]HOW TO ACTUALLY USE IT (STEP BY STEP)[/b]

1. When a blue "A" box appears, price is compressing. The panel switches to ACCUMULATION and shows the two sweep trigger prices. Liquidity is building above and below that box.
2. When one of those trigger prices is reached, the panel switches to SWEEP HIGH or SWEEP LOW and starts a countdown. This is the moment the model is being tested: price must close back inside the range before the window runs out, or the episode is discarded as a real breakout.
3. When the orange "M" mark appears, the sweep was reclaimed. The panel now shows the confirmation level for distribution and a fresh countdown. The failed breakout side tells you which resting stops were just collected.
4. When the "D" mark appears, price has confirmed movement away from the swept side (teal "D" = confirmed up after a sweep of the lows, red "D" = confirmed down after a sweep of the highs). The three-phase sequence is complete.
5. Check the EPISODES row before you trust the pattern on a new symbol or timeframe. If the completion percentage on your instrument is low, the model is simply not describing that market well — the panel tells you that honestly instead of hiding it.
6. Combine the phase marks with your own analysis (trend, higher-timeframe levels, session times). The indicator describes structure and reports the state of a model; it does not predict price.

🔶[b]EVERY SETTING EXPLAINED[/b]

🔹Accumulation group
- ATR Length — the length of the volatility measure that scales every threshold in the script. Larger = slower to adapt to volatility changes.
- Range Window (bars) — how many recent bars are checked for compression. Larger windows find bigger, slower ranges.
- Max Range Height (x ATR) — how tight the window must be to count as accumulation. Lower = stricter and rarer ranges, higher = looser and more frequent.
- Min Range Age (bars) — how many consecutive closed bars the compression must hold before the range qualifies. Filters out one-bar pauses.
- Episode Cooldown (bars) — how many bars must pass after an episode ends before a new range may qualify. Prevents overlapping back-to-back boxes over the same congestion area.

🔹Manipulation group
- Min Sweep Depth (x ATR) — how far beyond the range edge the wick must reach to count as a sweep. Raise it to ignore shallow pokes; set to 0 to accept any pierce.
- Reclaim Window (bars) — how quickly price must close back inside the range after the sweep. Short = only sharp stop-hunts count; longer = slower fake-outs also count.
- Allow Closes Beyond The Edge — ON (default) tolerates closes outside the swept edge as long as price returns within the reclaim window, so deeper stop-hunts also count. OFF is the strictest definition of a fake-out: any close beyond the swept edge cancels the episode (wicks only).
- Sweep Must Take Out A Liquidity Pool — OFF (default) accepts any sufficiently deep pierce of the range edge. ON additionally requires the same bar to trade through a confirmed swing high or low, so only sweeps that actually reached resting liquidity start a manipulation phase. Expect far fewer episodes with this on.

🔹Distribution group
- Confirmation Level — what counts as the real move: a close beyond the origin of the sweeping leg (Structure Break, default), beyond the range midpoint, or beyond the OPPOSITE edge of the range (strictest, requires crossing the entire range).
- Confirmation Window (bars) — how long after the reclaim the confirmation may arrive before the episode is discarded. Shorter windows produce fewer completed sequences.

🔹Follow-Through group
- Show Follow-Through Table — toggles the outcome table described above.
- Risk / Reward (RR) — how far price must travel in the confirmed direction, as a multiple of the distance from the confirmation close back to the manipulation extreme. Raising it makes the objective harder to reach. This same multiple also sets where the objective line is drawn and what its tag reads.
- Draw Objective Line On Chart — after each distribution, draws a short horizontal line at the measured objective, tagged with the R multiple. It marks the level the table measures against; it is not an order recommendation. Turn it off to keep the chart clean and rely on the table alone.
- Objective Line Length (bars) — how far to the right the objective line and its tag extend.
- Objective Line — the color of that line and tag.
- Position — placement of the table.

🔹Liquidity Pools group
- Show Pool Lines — toggles the swing high/low liquidity lines. Detection is unaffected; the levels are always tracked.
- Swing Length (bars) — how dominant a high/low must be (highest/lowest among this many bars on both sides) to count as a swing pivot. Larger = fewer, more significant pivots. This setting also feeds the Structure Break confirmation and the liquidity-pool sweep filter.
- Max Pool Lines Per Side — how many pool lines are kept before the oldest are removed.
- Highs / Lows — the two line colors.

🔹Display group
- Show Phase Boxes / Show A / M / D Labels — toggle the drawing layers separately.
- Keep Failed Episodes (dimmed) — keep discarded episodes on the chart, dimmed and dashed, for honest review; or remove them instantly.
- Max Episodes On Chart — how many past episodes stay on the chart before the oldest drawings are cleaned up.
- Colors — accumulation, manipulation, distribution up and distribution down colors.

🔹Panel group
- Show Live Phase Panel — toggles the panel described above.
- Position / Text Size / Dark Theme — placement and styling of the panel.

🔹Alerts group
- Accumulation Formed, Range Edge Swept (unconfirmed), Manipulation Confirmed, Distribution Confirmed, Episode Failed — enable the events you care about, then create ONE alert on this indicator and pick "Any alert() function call" in the TradingView alert window. Messages include the symbol, timeframe and the relevant price levels. The "Range Edge Swept" alert fires on an unconfirmed sweep, before the reclaim — it is an early heads-up, not a confirmation, and it will often be followed by a failed episode.

🔶[b]LIMITATIONS AND WHAT THIS TOOL DELIBERATELY DOES NOT DO[/b]

No buy or sell signals, no entry orders, no stop-loss levels, no probability or confidence score. The objective line the script draws is the level the Follow-Through table measures against, tagged with the R multiple — it is a measurement marker, not a take-profit recommendation. Detecting a structural pattern is not the same as having a tradable edge, and presenting pattern marks as trade signals would overstate what any indicator of this kind can honestly claim.

The two counters report different things and neither is a trading result. EPISODES measures pattern completion — how often the A-M-D sequence finished at all. FOLLOW-THROUGH measures what price did after it finished, against a distance derived from the pattern. Both are computed only on the bars currently loaded in your chart, both ignore trading costs entirely, and both will change with your symbol, timeframe, settings and the amount of history your plan loads. Neither number is a claim about future performance, and no result from either counter is implied or promised anywhere in this description.

The panel's NEXT and LEVEL rows state the conditions defined by the model, not a forecast. A sequence that reaches manipulation frequently fails before distribution, and a completed sequence is not a prediction that the move will continue.

Ranges, sweeps and structure breaks all depend on the settings you choose; different parameters produce different episodes on the same chart. Treat the defaults as a starting point and check the EPISODES row when you change them.

This tool is for analysis and education. It is not financial advice. Always do your own analysis and manage your own risk.

## Source Code

````pine
//@version=6
indicator('EonMetrics AMD Phases (Power of Three)', 'AMD Phases by EonMetrics', overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ═════════════════════════════════════════════════════════════════════════════
//  ACCUMULATION
// ═════════════════════════════════════════════════════════════════════════════
grpAcc = 'Accumulation'

atrLen = input.int(14, 'ATR Length', minval=1, maxval=200,
  group   = grpAcc,
  tooltip = 'Length of the ATR used to scale every threshold in the script (range height, sweep depth). 14 is the common default; raising it makes all thresholds react slower to volatility changes.')

rangeW = input.int(20, 'Range Window (bars)', minval=5, maxval=200,
  group   = grpAcc,
  tooltip = 'How many recent bars are examined for a sideways range. The high-low span of the last W bars must stay compressed for the window to qualify as accumulation.')

rangeK = input.float(4.0, 'Max Range Height (x ATR)', minval=0.5, maxval=10.0, step=0.1,
  group   = grpAcc,
  tooltip = 'Compression threshold. The window counts as contained only while (highest - lowest) of the last W bars is at most this many ATRs. Smaller = tighter, rarer ranges; larger = looser, more frequent ranges.')

rangeM = input.int(4, 'Min Range Age (bars)', minval=1, maxval=50,
  group   = grpAcc,
  tooltip = 'The containment condition must hold for at least this many consecutive closed bars before the range qualifies as accumulation and its edges are locked. Filters out one-bar pauses.')

epCooldown = input.int(10, 'Episode Cooldown (bars)', minval=0, maxval=100,
  group   = grpAcc,
  tooltip = 'Minimum number of bars after an episode ends (completed or failed) before a new accumulation range may qualify. Prevents overlapping back-to-back boxes over the same congestion area.')

// ═════════════════════════════════════════════════════════════════════════════
//  MANIPULATION
// ═════════════════════════════════════════════════════════════════════════════
grpMan = 'Manipulation'

minSweep = input.float(0.25, 'Min Sweep Depth (x ATR)', minval=0.0, maxval=5.0, step=0.05,
  group   = grpMan,
  tooltip = 'How far beyond the locked range edge a wick must reach to count as a sweep, in ATR units. Prevents every one-tick poke from starting a manipulation phase. 0 accepts any pierce.')

reclaimWin = input.int(5, 'Reclaim Window (bars)', minval=1, maxval=20,
  group   = grpMan,
  tooltip = 'After the sweep, price must CLOSE back inside the range within this many bars for the move to count as manipulation. If it keeps trading outside longer than this, the episode is discarded as a genuine breakout.')

allowCloseBeyond = input.bool(true, 'Allow Closes Beyond The Edge',
  group   = grpMan,
  tooltip = 'ON (default): closes beyond the swept edge are tolerated as long as price closes back inside within the reclaim window - deeper stop-hunts also count. OFF (strict): a bar that CLOSES beyond the swept edge immediately disqualifies the episode - only pure wick sweeps count as manipulation.')

requirePoolSweep = input.bool(false, 'Sweep Must Take Out A Liquidity Pool',
  group   = grpMan,
  tooltip = 'OFF (default): any pierce of the locked range edge that reaches the minimum depth can start the manipulation phase. ON (stricter): the same bar must also trade through a confirmed swing high (upside sweep) or swing low (downside sweep) - the resting-liquidity levels drawn by the Liquidity Pools layer. This rejects pierces of an arbitrary box edge that did not actually collect any stops, at the cost of far fewer episodes.')

// ═════════════════════════════════════════════════════════════════════════════
//  DISTRIBUTION
// ═════════════════════════════════════════════════════════════════════════════
grpDist = 'Distribution'

distMode = input.string('Structure Break', 'Confirmation Level', options=['Structure Break', 'Opposite Edge', 'Range Midpoint'],
  group   = grpDist,
  tooltip = 'What confirms distribution after the reclaimed sweep. Structure Break (default) = a close beyond the origin of the leg that produced the sweep - the extreme of the bars immediately preceding the pierce, which is the base the sweeping push started from. Breaking it means the move that swept the edge has been fully undone. Range Midpoint = a close beyond the middle of the range. Opposite Edge = a close beyond the far side of the range (strictest, requires crossing the whole range).')

distWin = input.int(24, 'Confirmation Window (bars)', minval=1, maxval=100,
  group   = grpDist,
  tooltip = 'How many bars after the reclaim the distribution confirmation may arrive. If price does not confirm within this window, or takes out the manipulation extreme first, the episode is discarded.')

// ═════════════════════════════════════════════════════════════════════════════
//  LIQUIDITY POOLS
// ═════════════════════════════════════════════════════════════════════════════
grpPool = 'Liquidity Pools'

showPools = input.bool(true, 'Show Pool Lines', group=grpPool,
  tooltip = 'Draws a horizontal line at every confirmed swing high (above price) and swing low (below price) - the classic resting-liquidity levels. Each line stops extending the moment price trades through it. The levels themselves are always tracked internally, so hiding the lines does not change detection.')

swingLen = input.int(5, 'Swing Length (bars)', minval=1, maxval=25,
  group   = grpPool,
  tooltip = 'A swing high/low is confirmed when it is the highest/lowest point among this many bars on BOTH sides. Larger = fewer, more significant pivots. Also feeds the Structure Break confirmation of the Distribution phase.')

maxPools = input.int(12, 'Max Pool Lines Per Side', minval=1, maxval=50,
  group   = grpPool,
  tooltip = 'Maximum number of pool lines kept per side; the oldest are removed first.')

poolHiCol = input.color(#EF5350, 'Highs', inline='pc', group=grpPool)
poolLoCol = input.color(#26A69A, 'Lows', inline='pc', group=grpPool)

// ═════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═════════════════════════════════════════════════════════════════════════════
grpVis = 'Display'

showBoxes   = input.bool(true, 'Show Phase Boxes', group=grpVis)
showLabels  = input.bool(true, 'Show A / M / D Labels', group=grpVis)
keepFailed  = input.bool(true, 'Keep Failed Episodes (dimmed)', group=grpVis,
  tooltip = 'ON: episodes that fail (real breakout, no reclaim, no confirmation) stay on the chart dimmed with a dashed border, useful for review. OFF: failed episodes are removed immediately.')
maxEpisodes = input.int(20, 'Max Episodes On Chart', minval=1, maxval=80, group=grpVis,
  tooltip = 'Maximum number of past episodes kept on the chart. The oldest drawings are removed once the limit is exceeded.')

accColor  = input.color(#5B9CF6, 'Accumulation', inline='c1', group=grpVis)
manColor  = input.color(#F0A44B, 'Manipulation', inline='c1', group=grpVis)
distUpCol = input.color(#26A69A, 'Distribution Up', inline='c2', group=grpVis)
distDnCol = input.color(#EF5350, 'Distribution Down', inline='c2', group=grpVis)

// ═════════════════════════════════════════════════════════════════════════════
//  FOLLOW-THROUGH
// ═════════════════════════════════════════════════════════════════════════════
grpRes = 'Follow-Through'

showRes = input.bool(true, 'Show Follow-Through Table', group=grpRes,
  tooltip = 'After each confirmed distribution, the script measures what price did next: whether it travelled the chosen distance in the confirmed direction before returning to the manipulation extreme. The table counts those outcomes on the bars loaded in this chart. It is a measurement of how the pattern behaved on this history - not a trade record, not a recommendation, and not a projection of future results.')

targetR = input.float(1.0, 'Risk / Reward (RR)', minval=0.25, maxval=10.0, step=0.25,
  group   = grpRes,
  tooltip = 'Choose the desired risk/reward ratio for the measured objective. Risk is defined by the pattern itself: the gap between the closing price of the confirmation bar and the manipulation extreme (the tip of the sweep). A value of 1.0 means 1R; 2.0 means 2R.')

showObjLine = input.bool(true, 'Draw Objective Line On Chart', group=grpRes,
  tooltip = 'After each distribution confirmation, draws a short horizontal line at the measured objective - the same level the Follow-Through table measures against, at Objective (x risk) from the confirmation close. It marks where the measurement is taken; it is not a recommendation to place an order there.')

objBars = input.int(8, 'Objective Line Length (bars)', minval=2, maxval=50, group=grpRes,
  tooltip = 'How many bars to the right the objective line and its TP tag extend.')

objCol = input.color(#FFD54F, 'Objective Line', group=grpRes)

resPos = input.string('Bottom Right', 'Position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=grpRes)

// ═════════════════════════════════════════════════════════════════════════════
//  PANEL
// ═════════════════════════════════════════════════════════════════════════════
grpPan = 'Panel'

showPanel = input.bool(true, 'Show Live Phase Panel', group=grpPan,
  tooltip = 'A table showing which phase of the sequence is active right now, which step the AMD model requires next and at what price this script will register it, how many bars remain before the episode expires, and what would invalidate it. It reports the state of the model, not a forecast of price.')

panPos = input.string('Top Right', 'Position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=grpPan)
panSiz = input.string('Small', 'Text Size', options=['Tiny', 'Small', 'Normal', 'Large'], group=grpPan)
panDark = input.bool(true, 'Dark Theme', group=grpPan)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════
grpAl = 'Alerts'

alertAcc  = input.bool(false, 'Accumulation Formed', group=grpAl)
alertSwp  = input.bool(false, 'Range Edge Swept (unconfirmed)', group=grpAl)
alertMan  = input.bool(true,  'Manipulation Confirmed', group=grpAl)
alertDist = input.bool(true,  'Distribution Confirmed', group=grpAl)
alertFail = input.bool(false, 'Episode Failed', group=grpAl,
  tooltip = 'Enable the alert types you want, then create ONE alert on this indicator choosing the option: Any alert() function call. Messages include symbol, timeframe and the relevant price levels.')

// ═════════════════════════════════════════════════════════════════════════════
//  DETECTION STATE
// ═════════════════════════════════════════════════════════════════════════════

float atr = ta.atr(atrLen)
float hh  = ta.highest(high, rangeW)
float ll  = ta.lowest(low, rangeW)
float ph  = ta.pivothigh(swingLen, swingLen)
float pl  = ta.pivotlow(swingLen, swingLen)
float legLo = ta.lowest(low, swingLen * 2)
float legHi = ta.highest(high, swingLen * 2)

var int   state     = 0
var int   rangeAge  = 0
var float accHi     = na
var float accLo     = na
var int   sweepDir  = 0
var int   sweepBar  = na
var float sweepExt  = na
var float legOrig   = na
var int   manipBar  = na
var int   lastEpEnd = na
var box   accBox    = na
var box   manBox    = na


var int cntFormed   = 0
var int cntManip    = 0
var int cntComplete = 0
var int cntFailed   = 0

var array<box>   epBoxes  = array.new<box>()
var array<label> epLabels = array.new<label>()

var array<float> trkInv = array.new<float>()
var array<float> trkObj = array.new<float>()
var array<int>   trkDir = array.new<int>()

var int resReach = 0
var int resInval = 0

var array<line> objLines = array.new<line>()

var array<line>  poolLines  = array.new<line>()
var array<float> poolLevels = array.new<float>()
var array<bool>  poolIsUp   = array.new<bool>()
var array<bool>  poolActive = array.new<bool>()

trimDrawings() =>
    while epBoxes.size() > maxEpisodes * 2
        box.delete(epBoxes.shift())
    while epLabels.size() > maxEpisodes * 3
        label.delete(epLabels.shift())

pushPool(line ln, float lvl, bool isUp) =>
    poolLines.push(ln)
    poolLevels.push(lvl)
    poolIsUp.push(isUp)
    poolActive.push(true)
    while poolLines.size() > maxPools * 2
        line old = poolLines.shift()
        if not na(old)
            line.delete(old)
        poolLevels.shift()
        poolIsUp.shift()
        poolActive.shift()

bool epFailed    = false
bool manConfirm  = false
bool distConfirm = false
bool sweepStart  = false
bool poolTapUp   = false
bool poolTapDn   = false

// ═════════════════════════════════════════════════════════════════════════════
//  ENGINE
// ═════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and not na(atr) and atr > 0
    // ── Follow-through: resolve open measurements from earlier confirmations ──
    int nTrk = trkDir.size()
    if nTrk > 0
        for i = nTrk - 1 to 0
            int   td  = trkDir.get(i)
            float inv = trkInv.get(i)
            float obj = trkObj.get(i)
            bool  hitObj = td > 0 ? low <= obj : high >= obj
            bool  hitInv = td > 0 ? high >= inv : low <= inv
            if hitObj or hitInv
                if hitObj and not hitInv
                    resReach := resReach + 1
                else
                    resInval := resInval + 1
                trkDir.remove(i)
                trkInv.remove(i)
                trkObj.remove(i)

    // ── Liquidity pools: expire tapped levels, register fresh confirmed pivots ──
    int nPool = poolLines.size()
    if nPool > 0
        for i = 0 to nPool - 1
            if poolActive.get(i)
                float lvl  = poolLevels.get(i)
                bool  isUp = poolIsUp.get(i)
                bool  tapped = isUp ? high >= lvl : low <= lvl
                if tapped
                    poolActive.set(i, false)
                    if isUp
                        poolTapUp := true
                    else
                        poolTapDn := true
                    line ln = poolLines.get(i)
                    if not na(ln)
                        line.set_x2(ln, bar_index)
                        line.set_extend(ln, extend.none)
    if not na(ph)
        line lnH = showPools ? line.new(bar_index - swingLen, ph, bar_index, ph, extend=extend.right, color=color.new(poolHiCol, 30), width=1) : na
        pushPool(lnH, ph, true)
    if not na(pl)
        line lnL = showPools ? line.new(bar_index - swingLen, pl, bar_index, pl, extend=extend.right, color=color.new(poolLoCol, 30), width=1) : na
        pushPool(lnL, pl, false)

    float span      = hh - ll
    bool  contained = span <= rangeK * atr

    // ── 0: scan for a qualifying accumulation range ─────────────────────────
    if state == 0
        rangeAge := contained ? rangeAge + 1 : 0
        bool cooled = na(lastEpEnd) or bar_index - lastEpEnd >= epCooldown
        if rangeAge >= rangeM and cooled
            accHi := hh
            accLo := ll
            state := 1
            cntFormed := cntFormed + 1
            if showBoxes
                accBox := box.new(bar_index - rangeW + 1, accHi, bar_index, accLo, border_color=color.new(accColor, 35), border_width=1, bgcolor=color.new(accColor, 82))
                epBoxes.push(accBox)
            if showLabels
                epLabels.push(label.new(bar_index, accHi, 'A', style=label.style_label_down, color=color.new(accColor, 20), textcolor=color.white, size=size.small, tooltip='Accumulation: range compressed under ' + str.tostring(rangeK) + ' x ATR for ' + str.tostring(rangeM) + '+ bars. Edges locked.'))
            if alertAcc
                alert(str.format('AMD Phases | {0} {1} | Accumulation formed: {2} - {3}', syminfo.ticker, timeframe.period, str.tostring(accLo, format.mintick), str.tostring(accHi, format.mintick)), alert.freq_once_per_bar_close)

    // ── 1: accumulation active — watch for a sweep of either edge ───────────
    else if state == 1
        bool depthHi  = high > accHi + minSweep * atr
        bool depthLo  = low < accLo - minSweep * atr
        bool pierceHi = requirePoolSweep ? depthHi and poolTapUp : depthHi
        bool pierceLo = requirePoolSweep ? depthLo and poolTapDn : depthLo
        if pierceHi or pierceLo
            float upExc = high - accHi
            float dnExc = accLo - low
            sweepDir := pierceHi and pierceLo ? (upExc >= dnExc ? 1 : -1) : pierceHi ? 1 : -1
            sweepBar := bar_index
            sweepExt := sweepDir > 0 ? high : low
            legOrig := sweepDir > 0 ? legLo : legHi
            state := 2
            sweepStart := true
        else if high <= accHi and low >= accLo
            if showBoxes and not na(accBox)
                box.set_right(accBox, bar_index)
        else
            float newHi = math.max(accHi, high)
            float newLo = math.min(accLo, low)
            if newHi - newLo <= rangeK * atr
                accHi := newHi
                accLo := newLo
                if showBoxes and not na(accBox)
                    box.set_right(accBox, bar_index)
                    box.set_top(accBox, accHi)
                    box.set_bottom(accBox, accLo)
            else
                epFailed := true

    // ── 2: swept — waiting for the reclaim close back inside ────────────────
    if state == 2
        sweepExt := sweepDir > 0 ? math.max(sweepExt, high) : math.min(sweepExt, low)
        bool closedBeyond = sweepDir > 0 ? close > accHi : close < accLo
        bool closedInside = sweepDir > 0 ? close <= accHi : close >= accLo
        if closedInside
            manConfirm := true
        else if closedBeyond and not allowCloseBeyond
            epFailed := true
        else if bar_index - sweepBar >= reclaimWin
            epFailed := true

    // ── 3: manipulation confirmed — waiting for distribution confirmation ───
    if state == 3 and not manConfirm
        float mid        = (accHi + accLo) / 2.0
        float confirmLvl = distMode == 'Structure Break' ? legOrig : distMode == 'Opposite Edge' ? (sweepDir > 0 ? accLo : accHi) : mid
        bool  distHit      = sweepDir > 0 ? close < confirmLvl : close > confirmLvl
        bool  extremeTaken = sweepDir > 0 ? close > sweepExt : close < sweepExt
        if distHit
            distConfirm := true
        else if extremeTaken
            epFailed := true
        else if bar_index - manipBar >= distWin
            epFailed := true

// ═════════════════════════════════════════════════════════════════════════════
//  OUTCOME HANDLING
// ═════════════════════════════════════════════════════════════════════════════
if sweepStart and alertSwp
    alert(str.format('AMD Phases | {0} {1} | Range edge swept: {2} at {3} - awaiting reclaim', syminfo.ticker, timeframe.period, sweepDir > 0 ? 'highs' : 'lows', str.tostring(sweepExt, format.mintick)), alert.freq_once_per_bar_close)

if manConfirm
    state := 3
    manipBar := bar_index
    cntManip := cntManip + 1
    if showBoxes
        manBox := box.new(sweepBar, sweepDir > 0 ? sweepExt : accLo, bar_index, sweepDir > 0 ? accHi : sweepExt, border_color=color.new(manColor, 35), border_width=1, bgcolor=color.new(manColor, 80))
        epBoxes.push(manBox)
    if showLabels
        epLabels.push(label.new(sweepBar, sweepExt, 'M', style=sweepDir > 0 ? label.style_label_down : label.style_label_up, color=color.new(manColor, 20), textcolor=color.white, size=size.small, tooltip=(sweepDir > 0 ? 'Manipulation: swept the range highs and closed back inside.' : 'Manipulation: swept the range lows and closed back inside.')))
    if alertMan
        alert(str.format('AMD Phases | {0} {1} | Manipulation confirmed: {2} swept and reclaimed (extreme {3})', syminfo.ticker, timeframe.period, sweepDir > 0 ? 'highs' : 'lows', str.tostring(sweepExt, format.mintick)), alert.freq_once_per_bar_close)
    trimDrawings()

if distConfirm
    color dCol = sweepDir > 0 ? distDnCol : distUpCol
    cntComplete := cntComplete + 1
    float rDist = math.abs(close - sweepExt)
    if rDist > 0
        float objLvl = sweepDir > 0 ? close - targetR * rDist : close + targetR * rDist
        trkDir.push(sweepDir)
        trkInv.push(sweepExt)
        trkObj.push(objLvl)
        if showObjLine
            line ol = line.new(bar_index, objLvl, bar_index + objBars, objLvl, color=color.new(objCol, 0), style=line.style_solid, width=2)
            objLines.push(ol)
            if showLabels
                epLabels.push(label.new(bar_index + objBars, objLvl, str.tostring(targetR, '#.##') + 'R', style=label.style_label_left, color=color.new(objCol, 20), textcolor=#131722, size=size.tiny, tooltip='Measured objective: ' + str.tostring(targetR, '#.##') + ' R from the distribution close. This is the level the Follow-Through table measures against - not a recommendation to place an order there.'))
            while objLines.size() > maxEpisodes
                line oldOl = objLines.shift()
                if not na(oldOl)
                    line.delete(oldOl)
    if showLabels
        epLabels.push(label.new(bar_index, sweepDir > 0 ? high : low, 'D', style=sweepDir > 0 ? label.style_label_down : label.style_label_up, color=color.new(dCol, 15), textcolor=color.white, size=size.small, tooltip=(sweepDir > 0 ? 'Distribution: confirmed DOWN - closed beyond the confirmation level after the failed sweep of the highs.' : 'Distribution: confirmed UP - closed beyond the confirmation level after the failed sweep of the lows.')))
    if alertDist
        alert(str.format('AMD Phases | {0} {1} | Distribution confirmed {2} at {3}', syminfo.ticker, timeframe.period, sweepDir > 0 ? 'DOWN' : 'UP', str.tostring(close, format.mintick)), alert.freq_once_per_bar_close)
    state := 0
    rangeAge := 0
    lastEpEnd := bar_index
    accHi := na
    accLo := na
    sweepDir := 0
    sweepBar := na
    sweepExt := na
    manipBar := na
    accBox := na
    manBox := na
    trimDrawings()

if epFailed
    cntFailed := cntFailed + 1
    if keepFailed
        if not na(accBox)
            box.set_bgcolor(accBox, color.new(accColor, 91))
            box.set_border_color(accBox, color.new(accColor, 55))
            box.set_border_style(accBox, line.style_dashed)
        if not na(manBox)
            box.set_bgcolor(manBox, color.new(manColor, 91))
            box.set_border_color(manBox, color.new(manColor, 55))
            box.set_border_style(manBox, line.style_dashed)
    else
        if not na(accBox)
            box.delete(accBox)
        if not na(manBox)
            box.delete(manBox)
    if alertFail
        alert(str.format('AMD Phases | {0} {1} | Episode failed - the sequence did not complete', syminfo.ticker, timeframe.period), alert.freq_once_per_bar_close)
    state := 0
    rangeAge := 0
    lastEpEnd := bar_index
    accHi := na
    accLo := na
    sweepDir := 0
    sweepBar := na
    sweepExt := na
    manipBar := na
    accBox := na
    manBox := na

// ═════════════════════════════════════════════════════════════════════════════
//  PANEL RENDER
// ═════════════════════════════════════════════════════════════════════════════
color pnBg  = panDark ? #161A25 : #FFFFFF
color pnTx  = panDark ? #D1D4DC : #131722
color pnMut = panDark ? #787B86 : #9598A1

txtSz = panSiz == 'Tiny' ? size.tiny : panSiz == 'Small' ? size.small : panSiz == 'Normal' ? size.normal : size.large

pnPos = panPos == 'Top Left' ? position.top_left : panPos == 'Top Center' ? position.top_center : panPos == 'Top Right' ? position.top_right : panPos == 'Middle Left' ? position.middle_left : panPos == 'Middle Right' ? position.middle_right : panPos == 'Bottom Left' ? position.bottom_left : panPos == 'Bottom Center' ? position.bottom_center : position.bottom_right

var table P = table.new(pnPos, 2, 8, bgcolor=pnBg, border_width=1, border_color=color.new(pnMut, 82), frame_color=color.new(pnMut, 55), frame_width=1)

f_px(float x) => na(x) ? '-' : str.tostring(x, format.mintick)

f_row(int r, string lab, string val, color vc, string tip) =>
    table.cell(P, 0, r, lab, text_color=pnMut, text_size=txtSz, text_halign=text.align_left, tooltip=tip)
    table.cell(P, 1, r, val, text_color=vc, text_size=txtSz, text_halign=text.align_right, tooltip=tip)

if barstate.islast
    if not showPanel
        table.clear(P, 0, 0, 1, 7)
    else
        string stName = state == 0 ? 'SCANNING' : state == 1 ? 'ACCUMULATION' : state == 2 ? (sweepDir > 0 ? 'SWEEP HIGH' : 'SWEEP LOW') : 'MANIPULATION'
        string stMet  = state == 0 ? '░░░ 0/3' : state == 3 ? '██░ 2/3' : '█░░ 1/3'
        color  stCol  = state == 0 ? pnMut : state == 1 ? accColor : manColor

        float trigHi = na(accHi) ? na : accHi + minSweep * atr
        float trigLo = na(accLo) ? na : accLo - minSweep * atr
        float pMid   = na(accHi) or na(accLo) ? na : (accHi + accLo) / 2.0
        float cfLvl  = distMode == 'Structure Break' ? legOrig : distMode == 'Opposite Edge' ? (sweepDir > 0 ? accLo : accHi) : pMid

        string rgTxt = na(accHi) or na(accLo) ? '-' : f_px(accLo) + ' - ' + f_px(accHi)

        string nxTxt = state == 0 ? 'Compression under ' + str.tostring(rangeK) + ' x ATR' : state == 1 ? 'Sweep beyond a range edge' : state == 2 ? 'Close back inside the range' : sweepDir > 0 ? 'Close below confirmation level' : 'Close above confirmation level'

        string lvTxt = state == 1 ? 'H ' + f_px(trigHi) + '  L ' + f_px(trigLo) : state == 2 ? (sweepDir > 0 ? 'close <= ' + f_px(accHi) : 'close >= ' + f_px(accLo)) : state == 3 ? f_px(cfLvl) : '-'

        int barsLeft = state == 2 ? reclaimWin - (bar_index - sweepBar) : state == 3 ? distWin - (bar_index - manipBar) : na
        string wnTxt = state == 0 ? '-' : state == 1 ? 'open' : str.tostring(math.max(barsLeft, 0)) + ' bars left'

        string fbTxt = state == 0 ? '-' : state == 1 ? 'Range expands past ' + str.tostring(rangeK) + ' x ATR' : state == 2 ? (allowCloseBeyond ? 'No reclaim inside the window' : 'Any close beyond ' + f_px(sweepDir > 0 ? accHi : accLo)) : 'Close beyond ' + f_px(sweepExt) + ' or timeout'

        string epTxt = str.tostring(cntFormed) + ' A  ' + str.tostring(cntManip) + ' M  ' + str.tostring(cntComplete) + ' D' + (cntFormed > 0 ? '  (' + str.tostring(100.0 * cntComplete / cntFormed, '#') + '%)' : '')

        string tipNext = 'The next step the AMD model requires, and the price at which this script will register it. This is the condition the script is waiting for, not a forecast of price. Sequences frequently fail - the EPISODES row shows how often the full A-M-D sequence actually completed on the history loaded in this chart.'
        string tipEp   = 'Counted on the bars currently loaded in your chart. A = accumulation ranges locked, M = sweeps that closed back inside, D = sequences that reached distribution confirmation. The percentage is how many locked ranges completed the full sequence. It measures pattern completion only - it is not a trading result and says nothing about profit.'

        table.cell(P, 0, 0, 'AMD PHASES', text_color=pnTx, text_size=txtSz, text_halign=text.align_left, bgcolor=color.new(stCol, 86), tooltip='Live state of the Accumulation - Manipulation - Distribution sequence on this chart. Everything is evaluated on closed bars.')
        table.cell(P, 1, 0, stMet, text_color=stCol, text_size=txtSz, text_halign=text.align_right, bgcolor=color.new(stCol, 86), tooltip='How many of the three phases of the current episode are confirmed.')

        f_row(1, 'PHASE',    stName, stCol, 'The phase currently confirmed. SCANNING = no qualifying range yet. SWEEP HIGH / SWEEP LOW = an edge was pierced but the reclaim has not happened yet, so manipulation is not confirmed.')
        f_row(2, 'RANGE',    rgTxt,  pnTx,  'The locked edges of the current accumulation range.')
        f_row(3, 'NEXT',     nxTxt,  pnTx,  tipNext)
        f_row(4, 'LEVEL',    lvTxt,  pnTx,  tipNext)
        f_row(5, 'WINDOW',   wnTxt,  pnTx,  'Bars remaining before the current episode expires and is discarded. Accumulation itself has no time limit.')
        f_row(6, 'FAILS IF', fbTxt,  pnTx,  'What would invalidate the current episode and discard it.')
        f_row(7, 'EPISODES', epTxt,  pnTx,  tipEp)

// ═════════════════════════════════════════════════════════════════════════════
//  FOLLOW-THROUGH RENDER
// ═════════════════════════════════════════════════════════════════════════════
rsPos = resPos == 'Top Left' ? position.top_left : resPos == 'Top Center' ? position.top_center : resPos == 'Top Right' ? position.top_right : resPos == 'Middle Left' ? position.middle_left : resPos == 'Middle Right' ? position.middle_right : resPos == 'Bottom Left' ? position.bottom_left : resPos == 'Bottom Center' ? position.bottom_center : position.bottom_right

var table R = table.new(rsPos, 2, 5, bgcolor=pnBg, border_width=1, border_color=color.new(pnMut, 82), frame_color=color.new(pnMut, 55), frame_width=1)

f_rrow(int r, string lab, string val, color vc, string tip) =>
    table.cell(R, 0, r, lab, text_color=pnMut, text_size=txtSz, text_halign=text.align_left, tooltip=tip)
    table.cell(R, 1, r, val, text_color=vc, text_size=txtSz, text_halign=text.align_right, tooltip=tip)

if barstate.islast
    if not showRes
        table.clear(R, 0, 0, 1, 4)
    else
        int   nRes  = resReach + resInval
        float rate  = nRes > 0 ? 100.0 * resReach / nRes : na
        float brEven = 100.0 / (1.0 + targetR)
        color rCol   = na(rate) ? pnMut : rate >= brEven ? distUpCol : distDnCol

        string tipHdr = 'Measured on the bars currently loaded in this chart. After every confirmed distribution the script records the closing price of the confirmation bar, treats the distance from there to the manipulation extreme as the structural risk, and then follows price forward until it either travels the chosen objective in the confirmed direction or returns to the manipulation extreme. Whichever happens first is the outcome. It measures how the pattern behaved on this history. It is not a trade record, it includes no costs or slippage, and it does not predict future outcomes.'
        string tipTie = 'Bars where price touched both the objective and the manipulation extreme are counted as invalidated, because intrabar order cannot be determined on this data.'

        table.cell(R, 0, 0, 'FOLLOW-THROUGH', text_color=pnTx, text_size=txtSz, text_halign=text.align_left, bgcolor=color.new(pnMut, 86), tooltip=tipHdr)
        table.cell(R, 1, 0, str.tostring(targetR, '#.##') + ' R', text_color=pnTx, text_size=txtSz, text_halign=text.align_right, bgcolor=color.new(pnMut, 86), tooltip='The objective distance as a multiple of the structural risk defined by the pattern.')

        f_rrow(1, 'REACHED',     str.tostring(resReach), distUpCol, 'Confirmations where price travelled the full objective before returning to the manipulation extreme.')
        f_rrow(2, 'INVALIDATED', str.tostring(resInval), distDnCol, 'Confirmations where price returned to the manipulation extreme first.' + '\n\n' + tipTie)
        f_rrow(3, 'UNRESOLVED',  str.tostring(trkDir.size()), pnMut, 'Confirmations still running: neither the objective nor the manipulation extreme has been touched yet.')
        f_rrow(4, 'RATE',        nRes > 0 ? str.tostring(resReach) + '/' + str.tostring(nRes) + '  (' + str.tostring(rate, '#') + '%)' : '-', rCol, tipHdr + '\n\nThe colour compares this rate to the indifference line for the chosen objective, which is 100 / (1 + objective) = ' + str.tostring(brEven, '#.#') + '%. At that rate the reached and invalidated outcomes cancel out before any costs. It marks which side of that arithmetic line this history fell on. It does not mean the pattern is profitable: commissions, spread and slippage are not included anywhere in this table.')
````
