# FiboZone

- url: https://www.tradingview.com/script/CLy4FYgn-FiboZone/
- type: indicator
- pine_id: PUB;905b3bf2f4834d86be63098e1a7a820f
- version: 1.0

## Description

[b]FiboZone[/b] combines three independent zone-based concepts into a single overlay, so the levels a trader usually keeps on separate scripts can be read against each other on one chart:

1. Fibonacci Pivot Levels - a nine-level pivot grid derived from the previous Daily, Weekly, or Monthly candle.
2. Order Blocks and Breaker Blocks - the last unmitigated supply and demand zones, and what happens to them once price breaks through.
3. Fair Value Gaps - three-candle imbalances, each one tracked until price returns to it.

The value of putting them together is confluence. A Fibonacci pivot is a static level known before the session opens; an order block and an FVG are reactive levels created by price itself. Where a pivot level lands inside an unmitigated order block, or where an FVG forms exactly at S1 or R2, the same price area is being marked by three different methods that were calculated independently of one another. Those overlaps are what the script is designed to make visible.


[b]1. FIBONACCI PIVOT LEVELS[/b]

The pivot grid is calculated from the previous completed higher-timeframe candle, so the levels are fixed for the entire duration of the current period and never move under your feet:

Range = previousHigh - previousLow
PP    = (previousHigh + previousLow + previousClose) / 3

R1 = PP + 0.382 * Range          S1 = PP - 0.382 * Range
R2 = PP + 0.618 * Range          S2 = PP - 0.618 * Range
R3 = PP + 1.000 * Range          S3 = PP - 1.000 * Range
R4 = PP + 1.618 * Range          S4 = PP - 1.618 * Range

Unlike classic floor-trader pivots, which space the levels using the range in whole multiples, this variant projects the range through Fibonacci ratios. The result is a tighter cluster around the pivot point at 0.382 and 0.618, with two wider extension levels at 1.000 and 1.618 that act as targets when a period trends away from its pivot.

Two display modes are available:

- Current period only (default) - only the pivot set for the period in progress is drawn, as horizontal lines starting at the first bar of that period and extending to the right. This keeps the chart clean when you only care about today's levels.
- Show Historical Levels - every period's pivot set is drawn as a stepped plot across the whole chart, so you can review how price behaved around past pivots.

Price labels showing the exact value sit at the right-hand edge. R3 and S3 are drawn dotted to distinguish the 1.000 extension from the rest.

A guard prevents a meaningless configuration: if the chart timeframe is higher than the selected pivot period, for example a Weekly chart with Daily pivots, the levels are hidden and an on-chart warning explains which timeframe is required.


[b]2. ORDER BLOCKS AND BREAKER BLOCKS[/b]

Swing detection. The script tracks a directional state that flips when the bar N positions back sets a new extreme relative to the most recent N bars: a new high turns the state bearish, a new low turns it bullish. Each flip records a confirmed swing top or swing bottom along with its price and bar position. Swing Lookback controls how much structure is required before a point counts as a swing, with a minimum of 3.

Order block construction. When price closes above the most recent swing top that has not yet been crossed, the script walks back from the previous bar to the swing bar and finds the candle with the lowest low in that leg. That single candle, its high as the top and its low as the bottom, becomes the bullish order block: the last down-candle before the move that broke structure. Bearish order blocks mirror this, taking the candle with the highest high in the leg down through a swing bottom.

Use Candle Body switches the boundaries from wick-to-wick to body-only, producing tighter zones.

Breaker blocks. An order block does not simply disappear when it fails. A bullish block is marked as broken the moment min(close, open) closes below its bottom, and from that bar onward it is drawn in the breaker colour while the original portion keeps the order block colour. This is the polarity flip: a level that was demand becomes supply, and it often gets retested from the other side. The block is only discarded once price closes back above its top, which invalidates the flip. Bearish blocks work in reverse.

The two-tone rendering, original zone up to the break and breaker zone from the break onward, is what makes the transition readable at a glance, rather than having a zone silently change colour with no record of where the break happened.

Polarity change markers, optional, mark with a small down or up triangle the swing points that formed inside an already-broken block. These flag the moments where structure was built on top of a flipped level.


[b]3. FAIR VALUE GAPS[/b]

An FVG marks a price range that was crossed in one impulsive move without two-sided trading, an imbalance that price frequently returns to fill.

Detection requires a three-candle pattern where all three candles point in the same direction, which filters out the gaps that form inside choppy, indecisive ranges:

- Bullish FVG: current low is above the high from two bars ago, and the previous close is also above it, with all three candles bullish. The zone spans from that high up to the current low.
- Bearish FVG: current high is below the low from two bars ago, and the previous close is also below it, with all three candles bearish. The zone spans from the current high up to that low.

Auto Threshold, on by default, discards gaps smaller than 10 percent of the average bar range over the last 20 bars. Without it, low-volatility sessions produce dozens of one-tick gaps that carry no information. The threshold adapts to the instrument and timeframe automatically, so no manual tuning per symbol is needed.

Mitigation tracking. A gap is marked mitigated as soon as a later bar's wick reaches into it: a bullish gap when a low touches its top, a bearish gap when a high touches its bottom. Rather than being deleted, a mitigated gap turns grey and shrinks. This is deliberate, because a filled gap is still information. It tells you the imbalance in that area has already been resolved, so the level is no longer a pending magnet. Deleting it would erase that distinction and make an untested gap look identical to a spent one.

FVG boxes are drawn at a fixed width, 3 bars by default, rather than extended indefinitely to the right, keeping the chart readable when many gaps are on screen.


[b]REPAINTING BEHAVIOUR[/b]

Confirm Zones On Bar Close is enabled by default. With it on, order blocks and fair value gaps are evaluated only on closed bars, so a zone never appears mid-bar and then vanishes. Turn it off if you prefer to see zones form intrabar, accepting that they may change until the bar closes.

The Fibonacci levels are built from the previous higher-timeframe candle, so they are fixed for the whole period and do not repaint in either mode.


[b]SETTINGS[/b]

Fibonacci Settings
- Show Fibonacci Levels - master toggle for the pivot grid.
- Fibonacci Period - Daily, Weekly, or Monthly.
- Show Historical Levels - off shows only the current period as lines, on shows every period as stepped plots.
- Show All Levels (R3, R4, S3, S4) - hides the 1.000 and 1.618 extensions when off.
- Show Price Labels - level name and value at the right edge.
- Level Extend (bars) - how far past the last bar the current-period lines and labels are placed.
- Individual colours for PP, R1, R2, S1, S2, and the extension levels.

Order Block Settings
- Show Order Blocks - master toggle.
- Swing Lookback - structure required to confirm a swing point, minimum 3. Higher values give fewer, more significant blocks.
- Show Last Bullish OB and Show Last Bearish OB - how many of the most recent blocks to draw, 0 disables that side.
- Use Candle Body - body-only boundaries instead of wick-to-wick.
- Show Historical Polarity Changes - triangle markers on swing points inside broken blocks.
- OB Extend (bars) - how far to the right active blocks are projected.
- Separate colours for bullish and bearish blocks and for their breaker state.

[b]FVG Settings[/b]
- Show FVG Zones - master toggle.
- Show Last Bullish FVG and Show Last Bearish FVG - how many gaps to draw per side, 0 disables that side.
- Auto Threshold - volatility filter for insignificant gaps.
- FVG Width (bars) - box width for unmitigated gaps.
- Colours for bullish, bearish, and mitigated gaps.

[b]General[/b]
- Confirm Zones On Bar Close - see the repainting section above.
- Max History Bars - how far back zones are detected, 3000 by default, 0 for all available history. Lowering it speeds up loading on long intraday histories.


[b]HOW TO USE IT[/b]

The three modules answer different questions, and reading them together is the point.

Establish the framework first. The pivot grid is known before the period opens. PP acts as the balance point for the period: sustained trade above it favours the long side, below it the short side. R1/S1 and R2/S2 are the levels where a normal session tends to stall, while R3/S3 and R4/S4 come into play only when the period trends strongly.

Then look for reactive confirmation. An order block sitting on top of a pivot level is a stronger area than either alone, because a static calculation and an actual footprint of aggressive orders point at the same price. An unmitigated FVG between the current price and a pivot level suggests an unfilled imbalance in the path, which is useful when judging whether a target is likely to be reached in one move.

Use breakers to read failure. When a bullish block flips to breaker and price returns to it from below, an area that failed as support is being tested as resistance. Combined with the pivot grid, a breaker forming just under PP after a failed reclaim gives a different picture than the same breaker forming at R2.

Mitigated gaps set expectations. A cluster of grey, mitigated gaps below price means that region has already been rebalanced, while the remaining coloured gaps mark where imbalance is still open.

Practical starting points: on intraday charts use Daily pivots with Swing Lookback around 10. On 4H and Daily charts use Weekly or Monthly pivots and raise the lookback to 15 to 20, so only major structure produces blocks. Turn off Show All Levels when the extensions sit far outside the period's range and add nothing.

None of these are entry signals on their own. Every zone this script draws is an area of interest that still requires your own confirmation, risk placement, and context.


[b]NOTES AND LIMITATIONS[/b]

- Drawing objects are created once and repositioned rather than deleted and redrawn every bar, which keeps the script responsive on long histories.
- Stored zones are capped at 100 per type internally, and the display is capped at 50 per side, to stay within platform drawing limits.
- Boxes are positioned by bar index rather than by time, so zone widths stay consistent across weekend and holiday gaps.
- The pivot grid requires the chart timeframe to be at or below the selected pivot period.
- Fair value gaps are detected on the chart timeframe only. There is no multi-timeframe FVG option in this version.


[b]ALERTS[/b]

Eleven alert conditions are available: price crossing PP, R1, R2, S1, and S2, plus bullish and bearish order block formation, bullish and bearish breaker block confirmation, and bullish and bearish FVG formation.


[b]CREDITS AND LICENSE[/b]

The order block and breaker block logic in this script is based on LuxAlgo's open-source Pine Script work, used and re-shared under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license (CC BY-NC-SA 4.0). Full credit for that component goes to LuxAlgo.

The Fibonacci pivot module, the fair value gap detection with mitigation tracking, the current-period display mode, the drawing-reuse architecture, and the integration of the three modules are original work by the author. This script was ported from the author's own MetaTrader 5 implementation.

This script is published under the same CC BY-NC-SA 4.0 license.


This script is a technical analysis tool for research and educational purposes. It is not financial advice, it does not predict future prices, and it makes no claim about profitability. Trade at your own risk.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © XORONX G3DHE
// Order Block / Breaker Block logic: LuxAlgo (Pine Script)
//
// FiboZone Pro - Advanced Trading Zones Indicator
// TradingView port of FiboZone_Pro.mq5 (v1.20)
//     - Fibonacci Pivot Levels (Daily / Weekly / Monthly) + "current period only" mode
//     - Order Blocks + Breaker Blocks
//     - FVG (Fair Value Gap) Detection System with mitigation tracking
//
// Perubahan dari versi TradingView sebelumnya:
//     - Tambah "Show Historical Levels" (off = hanya periode berjalan, digambar sebagai garis)
//     - Box OB/FVG dibuat sekali lalu dipindahkan, bukan delete-all + redraw tiap bar
//     - FVG termitigasi berubah abu-abu dan menyusut, bukan hilang
//     - Batas jumlah OB/FVG yang disimpan (100) + batas history bar
//     - Opsi "Confirm Zones On Bar Close" agar zona tidak repaint intrabar (sama seperti MT5)

//@version=6
indicator('FiboZone', 'FZ - XoRonX', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 5000)

//---------------------------------------------------------------------------------------------------------------------}
//CONSTANTS & STRINGS & INPUTS
//---------------------------------------------------------------------------------------------------------------------{
FVG_AVG_LOOKBACK    = 20    // bar untuk rata-rata range (auto threshold)
FVG_THRESHOLD_RATIO = 0.1   // FVG minimal 10% dari average range
FVG_MITIGATED_BARS  = 2     // lebar box FVG setelah termitigasi
MAX_OB_COUNT        = 100   // batas OB yang disimpan
MAX_FVG_COUNT       = 100   // batas FVG yang disimpan

DAILY               = 'Daily'
WEEKLY              = 'Weekly'
MONTHLY             = 'Monthly'

FIBO_GROUP          = 'Fibonacci Settings'
BLOCKS_GROUP        = 'Order Block Settings'
GAPS_GROUP          = 'FVG Settings'
GENERAL_GROUP       = 'General'

historyTooltip      = 'Off = hanya periode berjalan yang digambar (sebagai garis), On = semua periode digambar (sebagai plot bertingkat)'
useBodyTooltip      = 'Pakai body candle, bukan wick, sebagai batas order block'
polarityTooltip     = 'Tandai swing point yang jatuh di dalam breaker block'
thresholdTooltip    = 'Buang FVG yang lebih kecil dari 10% rata-rata range 20 bar terakhir'
confirmTooltip      = 'On = zona hanya dihitung pada bar yang sudah close (tidak repaint intrabar), sama seperti versi MT5'
maxBarsTooltip      = 'Seberapa jauh ke belakang zona dideteksi. 0 = seluruh history'

showFiboInput           = input.bool(   true,       'Show Fibonacci Levels',            group = FIBO_GROUP)
periodInput             = input.string( DAILY,      'Fibonacci Period',                 group = FIBO_GROUP,     options = [DAILY, WEEKLY, MONTHLY])
showFiboHistoryInput    = input.bool(   false,      'Show Historical Levels',           group = FIBO_GROUP,     tooltip = historyTooltip)
showAllLevelsInput      = input.bool(   true,       'Show All Levels (R3, R4, S3, S4)', group = FIBO_GROUP)
showLabelInput          = input.bool(   true,       'Show Price Labels',                group = FIBO_GROUP)
fiboExtendInput         = input.int(    20,         'Level Extend (bars)',              group = FIBO_GROUP,     minval = 0, maxval = 500)
ppColorInput            = input.color(  #0000ff,    'PP',                               group = FIBO_GROUP,     inline = 'fibo1')
r1ColorInput            = input.color(  #ffa500,    'R1',                               group = FIBO_GROUP,     inline = 'fibo1')
r2ColorInput            = input.color(  #ff0000,    'R2',                               group = FIBO_GROUP,     inline = 'fibo1')
s1ColorInput            = input.color(  #008080,    'S1',                               group = FIBO_GROUP,     inline = 'fibo2')
s2ColorInput            = input.color(  #008000,    'S2',                               group = FIBO_GROUP,     inline = 'fibo2')
extraColorInput         = input.color(  #ffd700,    'R3/R4/S3/S4',                      group = FIBO_GROUP,     inline = 'fibo2')

showOBInput             = input.bool(   true,       'Show Order Blocks',                group = BLOCKS_GROUP)
swingLookbackInput      = input.int(    10,         'Swing Lookback',                   group = BLOCKS_GROUP,   minval = 3)
showBullOBInput         = input.int(    10,         'Show Last Bullish OB',             group = BLOCKS_GROUP,   minval = 0, maxval = 50)
showBearOBInput         = input.int(    10,         'Show Last Bearish OB',             group = BLOCKS_GROUP,   minval = 0, maxval = 50)
useBodyInput            = input.bool(   false,      'Use Candle Body',                  group = BLOCKS_GROUP,   tooltip = useBodyTooltip)
showPolarityInput       = input.bool(   false,      'Show Historical Polarity Changes', group = BLOCKS_GROUP,   tooltip = polarityTooltip)
obExtendInput           = input.int(    50,         'OB Extend (bars)',                 group = BLOCKS_GROUP,   minval = 1, maxval = 500)
bullOBColorInput        = input.color(color.new(#191970, 80), 'Bullish OB',             group = BLOCKS_GROUP,   inline = 'ob1')
bullBreakColorInput     = input.color(color.new(#000000, 80), 'Breaker',                group = BLOCKS_GROUP,   inline = 'ob1')
bearOBColorInput        = input.color(color.new(#8b4513, 80), 'Bearish OB',             group = BLOCKS_GROUP,   inline = 'ob2')
bearBreakColorInput     = input.color(color.new(#000000, 80), 'Breaker',                group = BLOCKS_GROUP,   inline = 'ob2')

showFVGInput            = input.bool(   true,       'Show FVG Zones',                   group = GAPS_GROUP)
showBullFVGInput        = input.int(    10,         'Show Last Bullish FVG',            group = GAPS_GROUP,     minval = 0, maxval = 50)
showBearFVGInput        = input.int(    10,         'Show Last Bearish FVG',            group = GAPS_GROUP,     minval = 0, maxval = 50)
fvgAutoThresholdInput   = input.bool(   true,       'Auto Threshold',                   group = GAPS_GROUP,     tooltip = thresholdTooltip)
fvgExtendInput          = input.int(    3,          'FVG Width (bars)',                 group = GAPS_GROUP,     minval = 1, maxval = 500)
bullFVGColorInput       = input.color(color.new(#1e90ff, 50), 'Bullish FVG',            group = GAPS_GROUP,     inline = 'fvg1')
bearFVGColorInput       = input.color(color.new(#ff7f50, 50), 'Bearish FVG',            group = GAPS_GROUP,     inline = 'fvg1')
fvgMitigatedColorInput  = input.color(color.new(#696969, 70), 'Mitigated FVG',          group = GAPS_GROUP)

confirmOnCloseInput     = input.bool(   true,       'Confirm Zones On Bar Close',       group = GENERAL_GROUP,  tooltip = confirmTooltip)
maxBarsInput            = input.int(    3000,       'Max History Bars',                 group = GENERAL_GROUP,  minval = 0, tooltip = maxBarsTooltip)

//---------------------------------------------------------------------------------------------------------------------}
//DATA STRUCTURES & VARIABLES
//---------------------------------------------------------------------------------------------------------------------{
// @type            UDT representing an order block
// @field top       top price of the block
// @field btm       bottom price of the block
// @field loc       bar index the block originates from
// @field breaker   true once the block has been broken
// @field breakLoc  bar index the block was broken at
type ob
    float top       = na
    float btm       = na
    int   loc       = na
    bool  breaker   = false
    int   breakLoc  = na

// @type            UDT representing a swing point
// @field y         price level of the swing
// @field x         bar index of the swing
// @field crossed   true once price has crossed the swing level
type swing
    float y         = na
    int   x         = na
    bool  crossed   = false

// @type                UDT holding all cross-bar zone state
// @field os            oscillator state, 0 = bearish leg, 1 = bullish leg
// @field prevOs        oscillator state of the previously processed bar
// @field bullConf      1 when a swing top sits inside a bullish breaker block
// @field prevBullConf  bullConf of the previously processed bar
// @field bearConf      1 when a swing bottom sits inside a bearish breaker block
// @field prevBearConf  bearConf of the previously processed bar
type zoneState
    int os              = 0
    int prevOs          = 0
    int bullConf        = 0
    int prevBullConf    = 0
    int bearConf        = 0
    int prevBearConf    = 0

// @type            UDT representing a Fair Value Gap
// @field top       upper bound of the gap
// @field btm       lower bound of the gap
// @field barIndex  bar index of the middle candle (creation bar = barIndex + 1)
// @field mitigated true once price has touched the gap
type fvg
    float top       = na
    float btm       = na
    int   barIndex  = na
    bool  mitigated = false

// @type            UDT representing alerts as bool fields
type alerts
    bool bullishOrderBlock      = false
    bool bearishOrderBlock      = false
    bool bullishBreakerBlock    = false
    bool bearishBreakerBlock    = false
    bool bullishFairValueGap    = false
    bool bearishFairValueGap    = false

// @variable                        storage for bullish order blocks, newest first
var array<ob> bullishOB             = array.new<ob>()
// @variable                        storage for bearish order blocks, newest first
var array<ob> bearishOB             = array.new<ob>()
// @variable                        storage for bullish fair value gaps, newest first
var array<fvg> bullishFVG           = array.new<fvg>()
// @variable                        storage for bearish fair value gaps, newest first
var array<fvg> bearishFVG           = array.new<fvg>()
// @variable                        last detected swing top
var swing swingTop                  = swing.new()
// @variable                        last detected swing bottom
var swing swingBtm                  = swing.new()
// @variable                        swing / breaker detection state
var zoneState state                 = zoneState.new()
// @variable                        boxes for the order block area
var array<box> bullOBBoxes          = array.new<box>()
var array<box> bearOBBoxes          = array.new<box>()
// @variable                        boxes for the breaker area of a broken order block
var array<box> bullBreakBoxes       = array.new<box>()
var array<box> bearBreakBoxes       = array.new<box>()
// @variable                        boxes for the fair value gaps
var array<box> bullFVGBoxes         = array.new<box>()
var array<box> bearFVGBoxes         = array.new<box>()
// @variable                        first bar index of the current pivot period
var int periodStartIndex            = 0
// @variable                        alerts in current bar
alerts currentAlerts                = alerts.new()

// @variable                        swing lookback, minval 3 as in the MT5 version
int swingLength                     = math.max(swingLookbackInput, 3)
// @variable                        max = useBody ? math.max(close, open) : high
float maxSource                     = useBodyInput ? math.max(close, open) : high
// @variable                        min = useBody ? math.min(close, open) : low
float minSource                     = useBodyInput ? math.min(close, open) : low
// @variable                        upper = ta.highest(len)
float upper                         = ta.highest(swingLength)
// @variable                        lower = ta.lowest(len)
float lower                         = ta.lowest(swingLength)
// @variable                        average bar range used by the FVG auto threshold
float averageRange                  = nz(ta.sma(high - low, FVG_AVG_LOOKBACK), ta.cum(high - low) / (bar_index + 1))
// @variable                        true when the bar is inside the requested history window
bool inHistoryWindow                = maxBarsInput == 0 or (last_bar_index - bar_index) < maxBarsInput
// @variable                        true when zones may be evaluated on this bar
bool processBar                     = inHistoryWindow and (not confirmOnCloseInput or barstate.isconfirmed)
// @variable                        true on the bar the drawings are (re)positioned
bool drawBar                        = barstate.islastconfirmedhistory or barstate.islast

// we create the needed boxes for displaying order blocks and fair value gaps at the first execution
if barstate.isfirst
    if showOBInput
        if showBullOBInput > 0
            for index = 1 to showBullOBInput
                bullOBBoxes.push(   box.new(na, na, na, na, border_color = na, bgcolor = na))
                bullBreakBoxes.push(box.new(na, na, na, na, border_color = na, bgcolor = na))
        if showBearOBInput > 0
            for index = 1 to showBearOBInput
                bearOBBoxes.push(   box.new(na, na, na, na, border_color = na, bgcolor = na))
                bearBreakBoxes.push(box.new(na, na, na, na, border_color = na, bgcolor = na))
    if showFVGInput
        if showBullFVGInput > 0
            for index = 1 to showBullFVGInput
                bullFVGBoxes.push(box.new(na, na, na, na, border_color = na, bgcolor = na))
        if showBearFVGInput > 0
            for index = 1 to showBearFVGInput
                bearFVGBoxes.push(box.new(na, na, na, na, border_color = na, bgcolor = na))

// @function        strip the transparency off a color
// @param css       source color
// @returns         color
method notransp(color css) => color.rgb(color.r(css), color.g(css), color.b(css))

//---------------------------------------------------------------------------------------------------------------------}
//FIBONACCI PIVOT LEVELS
//---------------------------------------------------------------------------------------------------------------------{
// @variable                        timeframe the pivot is calculated from
string pivotTimeframe               = periodInput == WEEKLY ? 'W' : periodInput == MONTHLY ? 'M' : 'D'
// @variable                        false when the chart timeframe is higher than the pivot timeframe (IsValidTimeframe)
bool validTimeframe                 = timeframe.in_seconds() <= timeframe.in_seconds(pivotTimeframe)
// @variable                        true when the fibonacci levels are drawn
bool fiboActive                     = showFiboInput and validTimeframe

[previousHigh, previousLow, previousClose] = request.security(syminfo.tickerid, pivotTimeframe, [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)

// the pivot is based on the PREVIOUS completed period, same as the MT5 version
float pivotRange    = previousHigh - previousLow
float pivotPoint    = (previousHigh + previousLow + previousClose) / 3.0

float levelPP       = fiboActive ? pivotPoint : na
float levelR1       = fiboActive ? pivotPoint + 0.382 * pivotRange : na
float levelR2       = fiboActive ? pivotPoint + 0.618 * pivotRange : na
float levelS1       = fiboActive ? pivotPoint - 0.382 * pivotRange : na
float levelS2       = fiboActive ? pivotPoint - 0.618 * pivotRange : na
float levelR3       = fiboActive and showAllLevelsInput ? pivotPoint + pivotRange : na
float levelR4       = fiboActive and showAllLevelsInput ? pivotPoint + 1.618 * pivotRange : na
float levelS3       = fiboActive and showAllLevelsInput ? pivotPoint - pivotRange : na
float levelS4       = fiboActive and showAllLevelsInput ? pivotPoint - 1.618 * pivotRange : na

// track the first bar of the current pivot period for the "current period only" mode
if timeframe.change(pivotTimeframe)
    periodStartIndex := bar_index

// lines are only used by the "current period only" mode
var line linePP = na
var line lineR1 = na
var line lineR2 = na
var line lineS1 = na
var line lineS2 = na
var line lineR3 = na
var line lineR4 = na
var line lineS3 = na
var line lineS4 = na

// labels are shown in both modes
var label labelPP = na
var label labelR1 = na
var label labelR2 = na
var label labelS1 = na
var label labelS2 = na
var label labelR3 = na
var label labelR4 = na
var label labelS3 = na
var label labelS4 = na
var label warningLabel = na

// @function            create a price level label at the right of the chart
// @param levelColor    background color
// @returns             label ID
newLevelLabel(color levelColor) => label.new(na, na, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(levelColor, 50), textcolor = color.white, size = size.small)

if barstate.isfirst and showFiboInput
    if not showFiboHistoryInput
        linePP := line.new(na, na, na, na, color = ppColorInput)
        lineR1 := line.new(na, na, na, na, color = r1ColorInput)
        lineR2 := line.new(na, na, na, na, color = r2ColorInput)
        lineS1 := line.new(na, na, na, na, color = s1ColorInput)
        lineS2 := line.new(na, na, na, na, color = s2ColorInput)
        if showAllLevelsInput
            lineR3 := line.new(na, na, na, na, color = extraColorInput, style = line.style_dotted)
            lineR4 := line.new(na, na, na, na, color = extraColorInput)
            lineS3 := line.new(na, na, na, na, color = extraColorInput, style = line.style_dotted)
            lineS4 := line.new(na, na, na, na, color = extraColorInput)
    if showLabelInput
        labelPP := newLevelLabel(ppColorInput)
        labelR1 := newLevelLabel(r1ColorInput)
        labelR2 := newLevelLabel(r2ColorInput)
        labelS1 := newLevelLabel(s1ColorInput)
        labelS2 := newLevelLabel(s2ColorInput)
        if showAllLevelsInput
            labelR3 := newLevelLabel(extraColorInput)
            labelR4 := newLevelLabel(extraColorInput)
            labelS3 := newLevelLabel(extraColorInput)
            labelS4 := newLevelLabel(extraColorInput)

// timeframe warning - the chart timeframe is too high for the selected pivot period
if barstate.isfirst and showFiboInput and not validTimeframe
    string warningMsg = periodInput == DAILY ? '⚠️ Timeframe harus D1 atau lebih rendah!' : periodInput == WEEKLY ? '⚠️ Timeframe harus W1 atau lebih rendah!' : '⚠️ Timeframe harus M1 atau lebih rendah!'
    warningLabel := label.new(na, na, warningMsg, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.red, textcolor = color.white, size = size.normal)

// @function            position a pivot level line over the current period
// @param l_ine         line to update
// @param price         price level, na hides the line
// @param levelColor    line color
// @returns             void
updateLevelLine(line l_ine, float price, color levelColor) =>
    if not na(l_ine)
        l_ine.set_color(na(price) ? color(na) : levelColor)
        if not na(price)
            l_ine.set_xy1(periodStartIndex, price)
            l_ine.set_xy2(last_bar_index + fiboExtendInput, price)

// @function            position a pivot level label at the right of the chart
// @param l_abel        label to update
// @param tag           level name
// @param price         price level, na hides the label
// @param levelColor    background color
// @returns             void
updateLevelLabel(label l_abel, string tag, float price, color levelColor) =>
    if not na(l_abel)
        l_abel.set_color(    na(price) ? color(na) : color.new(levelColor, 50))
        l_abel.set_textcolor(na(price) ? color(na) : color.white)
        if not na(price)
            l_abel.set_xy(last_bar_index + (showFiboHistoryInput ? 0 : fiboExtendInput), price)
            l_abel.set_text(' ' + tag + ': ' + str.tostring(price, format.mintick))

//---------------------------------------------------------------------------------------------------------------------}
//ORDER BLOCKS - same logic as the LuxAlgo Pine Script the MT5 version was ported from
//---------------------------------------------------------------------------------------------------------------------{
// @function        detect swing tops and bottoms
// @returns         void
// os := high[len] > upper ? 0 : low[len] < lower ? 1 : os
detectSwings() =>
    state.prevOs := state.os
    state.os     := high[swingLength] > upper ? 0 : low[swingLength] < lower ? 1 : state.os

    if state.os == 0 and state.prevOs != 0
        swingTop.y          := high[swingLength]
        swingTop.x          := bar_index - swingLength
        swingTop.crossed    := false

    if state.os == 1 and state.prevOs != 1
        swingBtm.y          := low[swingLength]
        swingBtm.x          := bar_index - swingLength
        swingBtm.crossed    := false

// @function        store a new bullish order block and update the existing ones
// @returns         void
processBullishOB() =>
    if not na(swingTop.y) and close > swingTop.y and not swingTop.crossed
        swingTop.crossed := true

        float minima    = maxSource[1]
        float maxima    = minSource[1]
        int   location  = bar_index - 1

        for i = 1 to (bar_index - swingTop.x) - 1
            minima      := math.min(minSource[i], minima)
            maxima      := minima == minSource[i] ? maxSource[i] : maxima
            location    := minima == minSource[i] ? bar_index - i : location

        if bullishOB.size() >= MAX_OB_COUNT
            bullishOB.pop()
        bullishOB.unshift(ob.new(maxima, minima, location))
        currentAlerts.bullishOrderBlock := true

    state.bullConf := 0

    if bullishOB.size() > 0
        for i = bullishOB.size() - 1 to 0
            ob element = bullishOB.get(i)

            if not element.breaker
                if math.min(close, open) < element.btm
                    element.breaker     := true
                    element.breakLoc    := bar_index
                    currentAlerts.bullishBreakerBlock := true
            else
                if close > element.top
                    bullishOB.remove(i)
                else if i < showBullOBInput and swingTop.y < element.top and swingTop.y > element.btm
                    state.bullConf := 1

    if showPolarityInput and state.bullConf > state.prevBullConf
        label.new(swingTop.x, swingTop.y, '▼', color = na, textcolor = bearOBColorInput.notransp(), style = label.style_label_down, size = size.tiny)
    state.prevBullConf := state.bullConf

// @function        store a new bearish order block and update the existing ones
// @returns         void
processBearishOB() =>
    if not na(swingBtm.y) and close < swingBtm.y and not swingBtm.crossed
        swingBtm.crossed := true

        float minima    = minSource[1]
        float maxima    = maxSource[1]
        int   location  = bar_index - 1

        for i = 1 to (bar_index - swingBtm.x) - 1
            maxima      := math.max(maxSource[i], maxima)
            minima      := maxima == maxSource[i] ? minSource[i] : minima
            location    := maxima == maxSource[i] ? bar_index - i : location

        if bearishOB.size() >= MAX_OB_COUNT
            bearishOB.pop()
        bearishOB.unshift(ob.new(maxima, minima, location))
        currentAlerts.bearishOrderBlock := true

    state.bearConf := 0

    if bearishOB.size() > 0
        for i = bearishOB.size() - 1 to 0
            ob element = bearishOB.get(i)

            if not element.breaker
                if math.max(close, open) > element.top
                    element.breaker     := true
                    element.breakLoc    := bar_index
                    currentAlerts.bearishBreakerBlock := true
            else
                if close < element.btm
                    bearishOB.remove(i)
                else if i < showBearOBInput and swingBtm.y > element.btm and swingBtm.y < element.top
                    state.bearConf := 1

    if showPolarityInput and state.bearConf > state.prevBearConf
        label.new(swingBtm.x, swingBtm.y, '▲', color = na, textcolor = bullOBColorInput.notransp(), style = label.style_label_up, size = size.tiny)
    state.prevBearConf := state.bearConf

// @function            draw order blocks as boxes, the breaker area gets its own box
// @param orderBlocks   order block storage
// @param b_oxes        boxes for the order block area
// @param breakBoxes    boxes for the breaker area
// @param obColor       order block color
// @param breakColor    breaker color
// @returns             void
drawOrderBlocks(array<ob> orderBlocks, array<box> b_oxes, array<box> breakBoxes, color obColor, color breakColor) =>
    if b_oxes.size() > 0
        int shown       = math.min(b_oxes.size(), orderBlocks.size())
        int rightIndex  = last_bar_index + obExtendInput

        for i = 0 to b_oxes.size() - 1
            box b_ox        = b_oxes.get(i)
            box breakBox    = breakBoxes.get(i)

            if i < shown
                ob element = orderBlocks.get(i)

                b_ox.set_lefttop(       element.loc, element.top)
                b_ox.set_rightbottom(   element.breaker ? element.breakLoc : rightIndex, element.btm)
                b_ox.set_border_color(  obColor)
                b_ox.set_bgcolor(       obColor)

                if element.breaker
                    breakBox.set_lefttop(       element.breakLoc, element.top)
                    breakBox.set_rightbottom(   rightIndex, element.btm)
                    breakBox.set_border_color(  breakColor)
                    breakBox.set_bgcolor(       breakColor)
                else
                    breakBox.set_border_color(  na)
                    breakBox.set_bgcolor(       na)
            else
                b_ox.set_border_color(      na)
                b_ox.set_bgcolor(           na)
                breakBox.set_border_color(  na)
                breakBox.set_bgcolor(       na)

//---------------------------------------------------------------------------------------------------------------------}
//FAIR VALUE GAPS
//---------------------------------------------------------------------------------------------------------------------{
// @function        detect a fair value gap on the current bar
// @returns         void
// all three candles must point in the same direction, gap measured between high[2]/low[0] and low[2]/high[0]
detectFVG() =>
    bool allBullish = close > open and close[1] > open[1] and close[2] > open[2]
    bool allBearish = close < open and close[1] < open[1] and close[2] < open[2]

    if allBullish or allBearish
        float last2High = high[2]
        float last2Low  = low[2]
        float lastClose = close[1]

        bool bullishGap = allBullish and low  > last2High and lastClose > last2High
        bool bearishGap = allBearish and high < last2Low  and lastClose < last2Low

        if bullishGap or bearishGap
            float threshold = fvgAutoThresholdInput ? averageRange * FVG_THRESHOLD_RATIO : 0

            if bullishGap and (low - last2High) >= threshold
                if bullishFVG.size() >= MAX_FVG_COUNT
                    bullishFVG.pop()
                bullishFVG.unshift(fvg.new(low, last2High, bar_index - 1))
                currentAlerts.bullishFairValueGap := true

            if bearishGap and (last2Low - high) >= threshold
                if bearishFVG.size() >= MAX_FVG_COUNT
                    bearishFVG.pop()
                bearishFVG.unshift(fvg.new(last2Low, high, bar_index - 1))
                currentAlerts.bearishFairValueGap := true

// @function        flag fair value gaps whose zone has been touched by a wick
// @returns         void
// only bars AFTER the creation bar (barIndex + 1) are checked
checkFVGMitigation() =>
    if bullishFVG.size() > 0
        for i = bullishFVG.size() - 1 to 0
            fvg element = bullishFVG.get(i)
            if not element.mitigated and bar_index > element.barIndex + 1 and low <= element.top
                element.mitigated := true

    if bearishFVG.size() > 0
        for i = bearishFVG.size() - 1 to 0
            fvg element = bearishFVG.get(i)
            if not element.mitigated and bar_index > element.barIndex + 1 and high >= element.btm
                element.mitigated := true

// @function                draw fair value gaps as boxes, only a few bars wide
// @param fairValueGaps     fair value gap storage
// @param b_oxes            boxes for the fair value gaps
// @param normalColor       color of an untouched gap
// @param mitigatedColor    color of a mitigated gap
// @returns                 void
drawFairValueGaps(array<fvg> fairValueGaps, array<box> b_oxes, color normalColor, color mitigatedColor) =>
    if b_oxes.size() > 0
        int shown = math.min(b_oxes.size(), fairValueGaps.size())

        for i = 0 to b_oxes.size() - 1
            box b_ox = b_oxes.get(i)

            if i < shown
                fvg element    = fairValueGaps.get(i)
                color gapColor = element.mitigated ? mitigatedColor : normalColor

                b_ox.set_lefttop(       element.barIndex, element.top)
                b_ox.set_rightbottom(   element.barIndex + (element.mitigated ? FVG_MITIGATED_BARS : fvgExtendInput), element.btm)
                b_ox.set_border_color(  gapColor)
                b_ox.set_bgcolor(       gapColor)
            else
                b_ox.set_border_color(  na)
                b_ox.set_bgcolor(       na)

//---------------------------------------------------------------------------------------------------------------------}
//EXECUTION
//---------------------------------------------------------------------------------------------------------------------{
if processBar
    if showOBInput and (showBullOBInput > 0 or showBearOBInput > 0)
        detectSwings()

        if showBullOBInput > 0
            processBullishOB()

        if showBearOBInput > 0
            processBearishOB()

    if showFVGInput and (showBullFVGInput > 0 or showBearFVGInput > 0)
        detectFVG()
        checkFVGMitigation()

if drawBar
    if showOBInput
        drawOrderBlocks(bullishOB, bullOBBoxes, bullBreakBoxes, bullOBColorInput, bullBreakColorInput)
        drawOrderBlocks(bearishOB, bearOBBoxes, bearBreakBoxes, bearOBColorInput, bearBreakColorInput)

    if showFVGInput
        drawFairValueGaps(bullishFVG, bullFVGBoxes, bullFVGColorInput, fvgMitigatedColorInput)
        drawFairValueGaps(bearishFVG, bearFVGBoxes, bearFVGColorInput, fvgMitigatedColorInput)

    if showFiboInput
        if not showFiboHistoryInput
            updateLevelLine(linePP, levelPP, ppColorInput)
            updateLevelLine(lineR1, levelR1, r1ColorInput)
            updateLevelLine(lineR2, levelR2, r2ColorInput)
            updateLevelLine(lineS1, levelS1, s1ColorInput)
            updateLevelLine(lineS2, levelS2, s2ColorInput)
            updateLevelLine(lineR3, levelR3, extraColorInput)
            updateLevelLine(lineR4, levelR4, extraColorInput)
            updateLevelLine(lineS3, levelS3, extraColorInput)
            updateLevelLine(lineS4, levelS4, extraColorInput)

        if showLabelInput
            updateLevelLabel(labelPP, 'PP', levelPP, ppColorInput)
            updateLevelLabel(labelR1, 'R1', levelR1, r1ColorInput)
            updateLevelLabel(labelR2, 'R2', levelR2, r2ColorInput)
            updateLevelLabel(labelS1, 'S1', levelS1, s1ColorInput)
            updateLevelLabel(labelS2, 'S2', levelS2, s2ColorInput)
            updateLevelLabel(labelR3, 'R3', levelR3, extraColorInput)
            updateLevelLabel(labelR4, 'R4', levelR4, extraColorInput)
            updateLevelLabel(labelS3, 'S3', levelS3, extraColorInput)
            updateLevelLabel(labelS4, 'S4', levelS4, extraColorInput)

    if not na(warningLabel)
        warningLabel.set_xy(last_bar_index, high)

// historical levels are drawn as stepped plots, one segment per period
fiboHistoryDisplay = showFiboInput and showFiboHistoryInput ? display.all : display.none

plot(showFiboHistoryInput ? levelPP : na, 'PP', ppColorInput,    linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelR1 : na, 'R1', r1ColorInput,    linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelR2 : na, 'R2', r2ColorInput,    linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelS1 : na, 'S1', s1ColorInput,    linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelS2 : na, 'S2', s2ColorInput,    linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelR3 : na, 'R3', extraColorInput, linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelR4 : na, 'R4', extraColorInput, linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelS3 : na, 'S3', extraColorInput, linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)
plot(showFiboHistoryInput ? levelS4 : na, 'S4', extraColorInput, linewidth = 1, style = plot.style_linebr, display = fiboHistoryDisplay)

//---------------------------------------------------------------------------------------------------------------------}
//ALERTS
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(ta.cross(close, levelPP),            'Price Cross PP',           'Price crossed Pivot Point')
alertcondition(ta.cross(close, levelR1),            'Price Cross R1',           'Price crossed R1 (0.382)')
alertcondition(ta.cross(close, levelR2),            'Price Cross R2',           'Price crossed R2 (0.618)')
alertcondition(ta.cross(close, levelS1),            'Price Cross S1',           'Price crossed S1 (0.382)')
alertcondition(ta.cross(close, levelS2),            'Price Cross S2',           'Price crossed S2 (0.618)')

alertcondition(currentAlerts.bullishOrderBlock,     'Bullish Order Block',      'Bullish order block formed')
alertcondition(currentAlerts.bearishOrderBlock,     'Bearish Order Block',      'Bearish order block formed')
alertcondition(currentAlerts.bullishBreakerBlock,   'Bullish Breaker Block',    'Bullish order block turned into a breaker')
alertcondition(currentAlerts.bearishBreakerBlock,   'Bearish Breaker Block',    'Bearish order block turned into a breaker')
alertcondition(currentAlerts.bullishFairValueGap,   'Bullish FVG',              'Bullish FVG formed')
alertcondition(currentAlerts.bearishFairValueGap,   'Bearish FVG',              'Bearish FVG formed')

//---------------------------------------------------------------------------------------------------------------------}
````
