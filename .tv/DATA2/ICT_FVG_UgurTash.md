<!-- tradingview-pine-id: PUB;8d472d08145b403a84e1e4cf14087986 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT & FVG [UgurTash]

Source: https://www.tradingview.com/script/9A4AkxQY-ICT-FVG-UgurTash/

## Description

ICT & FVG [UgurTash]

The level that stopped you was never on your chart
You are on the 15m. The setup is clean, the structure agrees, you take it, and price stalls twelve ticks later at nothing. There is no level there. Not on the 15m.
Open the daily and there it is: a gap left three weeks ago, or the block that started the leg you are currently trading against. It was always there. You just could not see it from where you were standing.
That is the problem this script is built around. Everything else it does is support.

What it actually draws
Five higher timeframes at once, projected onto whatever chart you are on. Monthly, weekly, daily, 4H and 1H by default, each with its own colour and its own switch. Every zone is tagged with the timeframe that produced it, so a box reading OB+ [D] is unambiguous: that is a daily bullish order block, seen from the 15m, drawn at its real daily price and its real daily origin bar.
Two kinds of zone come from each timeframe:
Fair Value Gaps. A three candle gap in that timeframe's own bars. A daily FVG is built from daily candles, not from an average of 15m ones.
Order Blocks. The candle a move actually came from, found by structure rather than by colour. More on the method below, because the method is the part that matters.
And because a higher timeframe zone is only interesting while it is still unfilled, each one carries a state you can see at a glance: untouched, tested, or filled.

How an Order Block is found
Most order block scripts take the last opposite coloured candle before a strong move. That sounds right and often is not. In a real displacement leg there is usually a small pause bar somewhere in the middle, and the nearest opposite candle rule will happily mark that pause bar instead of the place the move came from.
This one works differently, in two steps.
Step one, structure. A swing high or low is confirmed only after a set number of bars have failed to exceed it. Nothing happens until price closes beyond that confirmed swing. No break of structure, no block.
Step two, the origin. When the break happens, the leg between the swing point and the breakout bar is scanned, and the block is anchored to the extreme candle of that leg: the lowest low for a bullish block, the highest high for a bearish one. That is the candle the move actually left from, whatever colour it happened to close.
Each swing point can only produce one block. Once it has been broken it is spent, so the same level does not keep re-arming as price chops around it.
The same function runs on the chart timeframe and inside each of the five higher timeframes, so a 1H block and a 1D block are built by an identical definition. They are comparable because they are the same measurement at different scales.
Optional on top of that: Use Candle Body to measure the block from the body instead of the full range, and Break Confirmation, which demands the breakout close clear the swing by a fraction of the swing range before anything is created. Both are off by default.

Higher timeframe blocks do not repaint
This is worth its own paragraph because it is the easiest thing in a multi timeframe script to get quietly wrong.
Confirm MTF Order Blocks On HTF Close is on by default. A higher timeframe block is only published once its own bar has closed. A daily block appears at the daily close and then never moves, never shifts edge, never vanishes on a later reload.
Turn it off and blocks appear as soon as the condition is met inside the forming higher timeframe bar. Earlier, and able to change its mind. The switch is there because some people want that trade off. The default is the honest one.

Breaker Blocks
A block that price closes through does not have to die.
Turn on Show Breaker Blocks and it flips polarity instead. A bullish block that fails becomes resistance, keeps its box, and is relabelled BB-. It stays until price closes back through its far edge, at which point it is genuinely spent and removed.
This is the same idea the script already applies to gaps through Inverse FVG, now applied to blocks, on the chart timeframe and on every higher timeframe alike. Off by default.

Zone states, and what happens when a zone is used up
Three states, and all three are configurable.
Untouched. Full colour. Nobody has been there yet.
Tested. Price has wicked into the zone without closing through it. The fill fades by an amount you set and the border changes to dashed, dotted, solid or nothing. Turn the whole thing off if you would rather not see it.
Filled. Price closed through. This is where the script stops deciding for you: pick Gray Out to keep it greyed and frozen as a record, Delete to clear it off the chart entirely, or Keep to leave it in its original colour. Fair Value Gaps and Order Blocks get that choice separately, because most people want different behaviour from each.
If you trade a clean chart, set filled gaps to Delete and filled blocks to Gray Out. The chart cleans itself and you still keep the history where it matters.

The chart timeframe layer
The higher timeframe module sits on top of a full imbalance engine running on your own chart, and the two are controlled independently. Switching the MTF panel off does not touch your local zones, and vice versa.
Fair Value Gaps with three mitigation definitions (Engulf, Mitigate, Rebalance), a consequent encroachment line, and Liquidity Void mode which merges consecutive gaps into one region.
Inverse FVG. A filled gap flips and starts working from the other side.
Implied FVG. The wick based variant, for the gaps that do not show up as a clean three candle structure.
Volume Imbalance in classic and advanced form, the body to body gaps between consecutive candles.
True GAP and GAP plus inefficiency, for instruments that actually gap.
Order Blocks and Breaker Blocks, by the method described above.
Each family has its own box limit and its own mitigation rule. Nothing is forced on you.

About the way the boxes look
The fills use a rule worth explaining, because it is the reason the chart stays readable with eight families of zone drawn at once.
The colour picker shows what you chose. What gets drawn is a fixed fraction of that opacity, so the default 50 in the settings lands on screen at a density that layers cleanly instead of burying the candles. Move the slider and the chart moves with it. You get an honest number in the settings and a usable chart at the same time, which the usual approaches give you one of but not both.
Borders are off by default, because a fill and a frame competing for the same edge is noise. Set Box Border Width to 1 if you disagree. Tested and filled zones can still draw their own border regardless.

Where to start
Turn off what you are not using. Seriously. With five higher timeframes and eight local zone families all enabled at once the chart is unreadable, and that is a setting problem, not a script problem.
A reasonable starting point for an intraday chart: monthly and weekly off, daily and 4H on, FVG and Order Blocks on, everything else off. Add one thing at a time from there.
Then set the Swing Lookback for each layer. It is the single control that decides how many blocks you get. Low means many, early and noisy. High means few, late and significant. The MTF layer has its own value because higher timeframe bars are scarce and usually want a smaller number than your chart does.

Limitations, honestly
Chart timeframe order blocks move on the live bar. A block is created the moment price closes beyond a swing, and on the forming bar that close is still changing. It can appear and disappear until the bar closes. Higher timeframe blocks do not have this problem when Confirm On HTF Close is on, which is why it is on.
The block scan is bounded. Max Scan Bars defaults to 50. In an unusually long leg the block anchors to the extreme within the last 50 bars rather than the true origin of the move. Raise it if your instrument runs long legs, but it is a real ceiling and you should know it is there.
Zone state is judged on the chart timeframe's closes. A daily zone is marked filled when the chart you are looking at closes through it, not when the daily candle does. On a 5m chart that is a faster verdict than a daily trader would give.
Five higher timeframes means ten data requests. On a slow connection or a thin symbol the script takes a moment to draw. Disable the slots you are not using.
None of this is a signal. There is no entry, no stop, no target, no win rate, nothing backtested and nothing claimed. It draws where price left work undone. What you do about that is the actual trade, and it is yours.

Feedback welcome, particularly the kind that finds something broken.
Nothing here is financial advice.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Base imbalance engine (Volume Imbalance, GAP, FVG, Implied FVG, Inverse FVG) © Vulnerable_human_x.
// The Order Block engine, Breaker Blocks, the multi-timeframe module, the Area fill rule and the
// zone-state system below are additions and are not part of the original author's work.

//@version=6
indicator('ICT & FVG [UgurTash]', shorttitle = 'ICT & FVG [UgurTash]', overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100, max_bars_back = 500,
     behind_chart = true)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 0 · SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════════════════════════

// Area fill rule.
// The colour picker keeps its own value (50 by default) and the slider stays live, but what is
// drawn is 0.4x that opacity. At the 50 default this lands on the same on-screen density as the
// reference "Area" fills, and moving the slider still changes the chart.
//   picker 50 -> drawn 80    picker 75 -> drawn 90    picker 25 -> drawn 70    picker 100 -> drawn 60
f_area(color col) =>
    color.new(col, 100.0 - (100.0 - color.t(col)) * 0.4)

// Maps a border-style name to a Pine line style. 'None' is expressed through the width, not here.
f_borderStyle(string s) =>
    switch s
        'Solid'  => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_solid

// Adds transparency without losing the hue, clamped so the result can never leave 0..100.
f_fade(color col, int extra) =>
    color.new(col, math.min(100.0, color.t(col) + extra))

// The opposite: removes transparency, used by the Highlight Box state. Both work in picker
// space, so the result still has to go through f_area() before it is drawn.
f_boost(color col, int amount) =>
    color.new(col, math.max(0.0, color.t(col) - amount))

// ═══════════════════════════════════════════════════════════════════════════════════════
// 1 · CURRENT TIMEFRAME ZONES (master switches)
// ═══════════════════════════════════════════════════════════════════════════════════════
// These control ONLY what is drawn from the chart's own bars. The higher-timeframe zones have
// their own master switch in the MTF group, so the two are fully independent of each other.
const string G_CUR = '1 · Current Timeframe Zones'

bool showCurFVG = input.bool(true, 'Show Current TF Fair Value Gaps', group = G_CUR, tooltip = 'Master switch for every chart-timeframe FVG drawing: normal FVG, Liquidity Void, Implied FVG and Inverse FVG. Turning it off clears them from the chart immediately and leaves the higher-timeframe zones untouched.')
bool showCurOB  = input.bool(true, 'Show Current TF Order Blocks', group = G_CUR, tooltip = 'Master switch for chart-timeframe Order Blocks and Breaker Blocks. Independent of the MTF panel.')

// ═══════════════════════════════════════════════════════════════════════════════════════
// 2 · ORDER BLOCKS (CURRENT TIMEFRAME)
// ═══════════════════════════════════════════════════════════════════════════════════════
const string G_OB = '2 · Order Blocks (Current TF)'

int   obSwingLen  = input.int(10, 'Swing Lookback', minval = 3, maxval = 50, group = G_OB, tooltip = 'Bars used to confirm a swing high or low. A block is only created when price closes beyond a confirmed swing, so this is the main sensitivity control. Lower = more, earlier, noisier blocks.')
bool  obUseBody   = input.bool(false, 'Use Candle Body', group = G_OB, tooltip = 'Measure the block from the candle body instead of the full high-low range.')
int   obScanMax   = input.int(50, 'Max Scan Bars', minval = 10, maxval = 100, group = G_OB, tooltip = 'How far back from the breakout bar the search for the block candle may run. Kept bounded so the history buffer stays inside Pine limits.')
float obBreakFib  = input.float(0.0, 'Break Confirmation (x swing range)', minval = 0.0, maxval = 1.0, step = 0.05, group = G_OB, tooltip = 'Requires the breakout close to clear the swing point by this fraction of the last swing-high to swing-low range before a block is created. 0 disables the filter, so any close beyond the swing counts, which is the standard behaviour.')
int   obMaxBoxes  = input.int(5, 'Max Blocks per Direction', minval = 1, maxval = 20, group = G_OB)
color obBullColor = input.color(color.new(#2157f3, 50), 'Bullish OB', inline = 'ob1', group = G_OB)
color obBearColor = input.color(color.new(#ff5d00, 50), 'Bearish OB', inline = 'ob1', group = G_OB)

bool  obShowBreak    = input.bool(false, 'Show Breaker Blocks', group = G_OB, tooltip = 'A block price closes through does not die: it flips polarity and keeps working from the other side, the same idea the Inverse FVG applies to gaps. The block is only discarded once price closes back through its far edge. With this off, a broken block follows the Mitigated Order Block Action setting instead.')
color obBullBreakCol = input.color(color.new(#ff1100, 50), 'Bullish Break', inline = 'ob2', group = G_OB)
color obBearBreakCol = input.color(color.new(#0cb51a, 50), 'Bearish Break', inline = 'ob2', group = G_OB)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 3 · FAIR VALUE GAP
// ═══════════════════════════════════════════════════════════════════════════════════════
const string G_FVG = '3 · FVG'

bool plotFVG           = false
bool liquidityvoidmode = false

string fvgtype       = input.string('Normal', 'FVG Type', options = ['None', 'Normal', 'Liquidity Void'], inline = 'f18', group = G_FVG, tooltip = 'Consecutively formed FVGs are collectively referred to as a Liquidity Void.')
bool   showifvgInput = input.bool(false, 'IMPLIED FVG', inline = 'f19', group = G_FVG)
bool   invfvgInput   = input.bool(false, 'INVERSE FVG', group = G_FVG, inline = 'f19', tooltip = 'FVG Mitigation type should be set to \'ENGULF\' for Inverse FVG to work')

if fvgtype == 'Normal'
    plotFVG           := true
    liquidityvoidmode := false
    liquidityvoidmode
else if fvgtype == 'Liquidity Void'
    plotFVG           := false
    liquidityvoidmode := true
    liquidityvoidmode
else if fvgtype == 'None'
    plotFVG           := false
    liquidityvoidmode := false
    liquidityvoidmode

// The current-timeframe master switch folds into the FVG-family flags here, so one checkbox
// silences the whole family without touching the MTF module.
if not showCurFVG
    plotFVG           := false
    liquidityvoidmode := false
    liquidityvoidmode

bool showifvg       = showifvgInput and showCurFVG
bool Inversefvgmode = invfvgInput and showCurFVG

color fvgBullColor  = input.color(color.new(color.green, 50), 'Bullish FVG', inline = 'f1', group = G_FVG)
color fvgBearColor  = input.color(color.new(color.red, 50), 'Bearish FVG', inline = 'f1', group = G_FVG)

color ifvgBullColor = input.color(color.new(color.green, 50), 'Bullish IMP.FVG', inline = 'f3', group = G_FVG)
color ifvgBearColor = input.color(color.new(color.red, 50), 'Bearish IMP.FVG', inline = 'f3', group = G_FVG)

color buinvfvgcolor = input.color(color.new(#fbc02d, 50), 'Bullish INV.FVG', inline = 'f4', group = G_FVG)
color beinvfvgcolor = input.color(color.new(#fbc02d, 50), 'Bearish INV.FVG', inline = 'f4', group = G_FVG)

int    fvgMaxBoxSet       = input.int(15, 'FVG/IMP.FVG Box Limit', minval = 1, maxval = 100, group = G_FVG, tooltip = 'Minimum = 1, Maximum = 100')
bool   extendfvgbox       = input.bool(true, 'Extend All Unmitigated Boxes', group = G_FVG, tooltip = 'Also gates the mitigation logic: with this off, boxes neither extend nor change state.')

// ═══════════════════════════════════════════════════════════════════════════════════════
// 4 · VOLUME IMBALANCE
// ═══════════════════════════════════════════════════════════════════════════════════════
const string G_VI = '4 · Volume Imbalance'

bool classicvi  = false
bool advancedvi = false
string vitype = input.string('Classic', 'Volume Imbalance Type', options = ['None', 'Classic', 'Advanced'], group = G_VI, tooltip = 'Classic mode includes only a single type of body gap, while advanced mode covers all body gap variants.')

if vitype == 'Classic'
    classicvi  := true
    advancedvi := false
    advancedvi
else if vitype == 'Advanced'
    classicvi  := false
    advancedvi := true
    advancedvi
else if vitype == 'None'
    classicvi  := false
    advancedvi := false
    advancedvi

color  bullimbalance    = input.color(color.new(#00e640, 50), 'Bullish VI Color', group = G_VI, inline = 'vi1')
color  bearimbalance    = input.color(color.new(#e30000, 50), 'Bearish VI Color', group = G_VI, inline = 'vi1')
int    viMaxBoxSet      = input.int(8, 'Maximum Box Displayed', minval = 1, maxval = 100, group = G_VI, tooltip = 'Minimum = 1, Maximum = 100')
string vimitigationtype = input.string('Engulf', 'VI Mitigation Type', options = ['Engulf', 'Mitigate'], group = G_VI, tooltip = 'Body close below Bullish VI and above Bearish VI required for Engulf Mitigation Type')
bool   extendvibox      = input.bool(true, 'Extend Unmitigated VI Boxes', group = G_VI)
bool   extendallvis     = input.bool(false, 'Extend all VI Boxes', group = G_VI, tooltip = 'Keeps every VI box, mitigated ones included, stretched to the current bar. Overrides the freeze that normally happens when a box is mitigated.')

// ═══════════════════════════════════════════════════════════════════════════════════════
// 5 · GAP
// ═══════════════════════════════════════════════════════════════════════════════════════
const string G_GAP = '5 · GAP'

string gaptype = input.string('True GAP', 'GAPs Type', options = ['None', 'True GAP', 'GAP + Inefficiency'], group = G_GAP, tooltip = 'True GAPs are price zones with no buyside or sellside delivery at all. GAP + Inefficiency, however, cover both regions where there\'s an absence of buyside and sellside activity, and areas with one-sided price action (the gap between the close of the previous candle and the open of the current one).')

bool truegap    = false
bool gapwithimb = false

if gaptype == 'True GAP'
    truegap    := true
    gapwithimb := false
    gapwithimb
else if gaptype == 'GAP + Inefficiency'
    truegap    := false
    gapwithimb := true
    gapwithimb
else if gaptype == 'None'
    truegap    := false
    gapwithimb := false
    gapwithimb

color  gapcolor          = input.color(color.new(#4ec1f7, 50), 'GAP Color', group = G_GAP)
int    gapsMaxBoxSet     = input.int(7, 'Maximum Box Displayed', minval = 1, maxval = 100, group = G_GAP, tooltip = 'Minimum = 1, Maximum = 100')
bool   cegap             = input.bool(true, 'GAP Consequent Encroachment (C.E.)', group = G_GAP)
string cegaplinetype     = input.string(line.style_dashed, 'C.E. Line Style', options = [line.style_dashed, line.style_dotted, line.style_solid], group = G_GAP)
int    cetransparency    = input.int(50, 'C.E. Transparency', minval = 0, maxval = 100, group = G_GAP)
string gapmitigationtype = input.string('Engulf', 'GAP Mitigation Type', options = ['Engulf', 'Rebalance'], group = G_GAP, tooltip = 'Body close or open above/below a GAP is required for Engulf Mitigation Type. Rebalance : Price ranges where buyside or sellside delivery is offered are erased as the candle forms.')
bool   extendgapbox      = input.bool(true, 'Extend Unmitigated GAP Boxes', group = G_GAP)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 6 · MTF HIGHER TIMEFRAME ZONES
// ═══════════════════════════════════════════════════════════════════════════════════════
// Enable MTF Panel controls the higher-timeframe zones and nothing else. Switching it off
// deletes those boxes and leaves everything the chart timeframe draws exactly as it was.
const string G_MTF = '6 · MTF Higher Timeframe Zones'

bool enableMTF   = input.bool(true, 'Enable MTF Panel', group = G_MTF, tooltip = 'Master switch for the higher-timeframe zones only. Chart-timeframe FVGs and Order Blocks have their own switches in the Current Timeframe Zones group and are not affected by this one.')
bool showMTF_FVG = input.bool(true, 'Show MTF FVG', group = G_MTF, inline = 'mtftype')
bool showMTF_OB  = input.bool(true, 'Show MTF Order Blocks', group = G_MTF, inline = 'mtftype')

bool   tf1Enable    = input.bool(true, 'TF 1', group = G_MTF, inline = 'tf1')
string tf1          = input.timeframe('M', '', group = G_MTF, inline = 'tf1')
color  tf1BullColor = input.color(color.new(#1B5E20, 50), '', group = G_MTF, inline = 'tf1')
color  tf1BearColor = input.color(color.new(#7B241C, 50), '', group = G_MTF, inline = 'tf1')

bool   tf2Enable    = input.bool(true, 'TF 2', group = G_MTF, inline = 'tf2')
string tf2          = input.timeframe('W', '', group = G_MTF, inline = 'tf2')
color  tf2BullColor = input.color(color.new(#089981, 50), '', group = G_MTF, inline = 'tf2')
color  tf2BearColor = input.color(color.new(#F23645, 50), '', group = G_MTF, inline = 'tf2')

bool   tf3Enable    = input.bool(true, 'TF 3', group = G_MTF, inline = 'tf3')
string tf3          = input.timeframe('D', '', group = G_MTF, inline = 'tf3')
color  tf3BullColor = input.color(color.new(#4CAF50, 50), '', group = G_MTF, inline = 'tf3')
color  tf3BearColor = input.color(color.new(#FF5252, 50), '', group = G_MTF, inline = 'tf3')

bool   tf4Enable    = input.bool(true, 'TF 4', group = G_MTF, inline = 'tf4')
string tf4          = input.timeframe('240', '', group = G_MTF, inline = 'tf4')
color  tf4BullColor = input.color(color.new(#26A69A, 50), '', group = G_MTF, inline = 'tf4')
color  tf4BearColor = input.color(color.new(#EF5350, 50), '', group = G_MTF, inline = 'tf4')

bool   tf5Enable    = input.bool(true, 'TF 5', group = G_MTF, inline = 'tf5')
string tf5          = input.timeframe('60', '', group = G_MTF, inline = 'tf5')
color  tf5BullColor = input.color(color.new(#80CBC4, 50), '', group = G_MTF, inline = 'tf5')
color  tf5BearColor = input.color(color.new(#EF9A9A, 50), '', group = G_MTF, inline = 'tf5')

int    mtfObSwingLen = input.int(5, 'MTF OB Swing Lookback', minval = 3, maxval = 30, group = G_MTF, tooltip = 'The swing confirmation length used inside each higher timeframe. Kept separate from the chart-timeframe setting because higher-timeframe bars are scarce, so a smaller number is usually right here. Use Candle Body, Max Scan Bars and Break Confirmation are shared with the Order Blocks group.')
int    mtfMaxBoxes   = input.int(5, 'Max Boxes per Timeframe / Type', minval = 1, maxval = 20, group = G_MTF, tooltip = 'Counted separately for bullish FVG, bearish FVG, bullish OB and bearish OB on every enabled timeframe. Five enabled timeframes at 5 boxes is up to 100 boxes on top of everything the chart timeframe draws, against a platform limit of 500.')
bool   mtfConfirmTF  = input.bool(true, 'Confirm MTF Order Blocks On HTF Close', group = G_MTF, tooltip = 'On: a higher-timeframe block is only published once its own bar has closed, so it never moves or disappears after the fact. Off: blocks appear as soon as the condition is met inside the forming higher-timeframe bar, which is earlier but can repaint.')
color  mtfLabelColor = input.color(color.rgb(200, 203, 211), 'MTF Label Color', group = G_MTF, tooltip = 'Kept separate from the fill colour so the timeframe tag stays readable when a zone fades.')
string mtfLabelSize  = input.string(size.tiny, 'MTF Label Size', options = [size.tiny, size.small, size.normal], group = G_MTF)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 7 · BOX STYLE
// ═══════════════════════════════════════════════════════════════════════════════════════
const string G_BOX = '7 · Box Style'

string BoxBorder          = input.string(line.style_solid, 'Box Border Style', options = [line.style_dashed, line.style_dotted, line.style_solid], group = G_BOX, tooltip = 'Only has an effect while Box Border Width is 1 or more.')
int    BoxBorderWidth     = input.int(0, 'Box Border Width', minval = 0, maxval = 4, group = G_BOX, tooltip = 'Default 0, which draws no border and leaves the fill to carry the zone, matching the Area fill style. Raise it to 1 or more to bring Box Border Style, Border Box Transparency and the Highlight Box border back. Tested and mitigated zones can still draw their own border whatever this is set to.')
int    BorderTransparency = input.int(85, 'Border Box Transparency', minval = 0, maxval = 100, group = G_BOX)

bool HighlightBox    = input.bool(true, 'Highlight Box', group = G_BOX, tooltip = 'Brightens a chart-timeframe FVG, VI or GAP box while price is trading inside it, and lets it fall back to its normal fill once price leaves. In the original the brightening was one-way and never reverted.')
int  highlightBoost  = input.int(25, 'Highlight Opacity Boost', minval = 0, maxval = 100, group = G_BOX, tooltip = 'How much opacity a box gains while price is inside it, relative to its own colour rather than a fixed value. The two absolute transparency inputs this replaces could not work once fills started going through the Area rule: a fixed 80 was brighter than the old 90 default but identical to the new one, so the highlight would have been invisible.')

bool   plotBoxLabel  = input.bool(true, 'Plot Label', group = G_BOX)
string BoxLabelSize  = input.string(size.tiny, 'Label Size', options = [size.huge, size.large, size.small, size.tiny, size.auto, size.normal], group = G_BOX)
color  BoxLabelColor = input.color(color.rgb(161, 163, 171), 'Label Color', group = G_BOX, tooltip = 'Kept separate from the fill colour on purpose, so text stays readable when a zone fades.')
string labelhalign   = input.string(text.align_center, 'Label Horizontal Align', options = [text.align_center, text.align_right, text.align_left], group = G_BOX)
string labelvalign   = input.string(text.align_center, 'Label Vertical Align', options = [text.align_top, text.align_center, text.align_bottom], group = G_BOX)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 8 · ZONE STATES
// ═══════════════════════════════════════════════════════════════════════════════════════
// Every Order Block and every Fair Value Gap, on the chart timeframe and on the higher ones,
// walks the same three stages. There is one rule and no per-family variants:
//
//   ARMED     a candle has CLOSED outside the zone. Until that happens nothing is marked, which
//             is what stops the candles that built the zone from counting as a test of it.
//   TESTED    after arming, the first touch of any kind. A wick is enough and it does not matter
//             whether price is inside or outside when the bar closes. Permanent, dashed border.
//   FILLED    price has crossed the zone end to end, far edge included, wick or body. The zone
//             is spent and is handed to the Mitigated action below.
//
// A zone that is entered but not crossed end to end stays in the tested state and keeps its
// dashed border. Volume Imbalance and GAP are not part of this and keep their own settings.
const string G_STATE = '8 · Zone States'

bool   markTested    = input.bool(true, 'Mark Tested Zones', group = G_STATE, tooltip = 'Dashed border on a zone that price has come back and touched without crossing it end to end.')
bool   testedFadeOn  = input.bool(true, 'Fade Fill When Tested', inline = 'ts1', group = G_STATE)
int    testedFadeAmt = input.int(15, 'Amount', minval = 0, maxval = 100, inline = 'ts1', group = G_STATE, tooltip = 'Extra transparency added to the fill once a zone has been tested. 0 leaves the fill alone.')
string testedBorder  = input.string('Dashed', 'Tested Border Style', options = ['None', 'Solid', 'Dashed', 'Dotted'], group = G_STATE)

string mitActionFVG     = input.string('Gray Out', 'Mitigated FVG Action', options = ['Gray Out', 'Delete', 'Keep'], group = G_STATE, tooltip = 'What happens to a gap once price has filled it 100 percent, wick included. Gray Out recolours and freezes it, Delete removes it from the chart, Keep leaves it in its original colour. Applies to chart-timeframe FVG, Implied FVG and the higher-timeframe FVGs. Volume Imbalance and GAP keep their own settings.')
string mitActionOB      = input.string('Gray Out', 'Mitigated Order Block Action', options = ['Gray Out', 'Delete', 'Keep'], group = G_STATE, tooltip = 'The same three choices for Order Blocks, chart timeframe and higher timeframe alike. Ignored for a block that flips into a Breaker Block while Show Breaker Blocks is on.')
color  mitBOXColor      = input.color(color.new(color.gray, 50), 'Mitigated Fill', inline = 'mt1', group = G_STATE)
color  MitBoxLabelColor = input.color(color.rgb(161, 163, 171, 60), 'Mitigated Label', inline = 'mt1', group = G_STATE)
string mitBorder        = input.string('None', 'Mitigated Border Style', options = ['None', 'Solid', 'Dashed', 'Dotted'], group = G_STATE)


// ═══════════════════════════════════════════════════════════════════════════════════════
// 9 · STATE HELPERS
// ═══════════════════════════════════════════════════════════════════════════════════════
// Declared after the inputs because they read them.

// Applies the configured mitigated styling to a box. Returns true when the caller must also
// drop the box from its array, which is the case only for the Delete action.
f_mitBox(box bx, string action) =>
    bool drop = false
    if action == 'Delete'
        box.delete(bx)
        drop := true
    else if action == 'Gray Out'
        box.set_bgcolor(bx, f_area(mitBOXColor))
        box.set_text_color(bx, MitBoxLabelColor)
        if mitBorder == 'None'
            box.set_border_width(bx, 0)
        else
            box.set_border_width(bx, int(math.max(BoxBorderWidth, 1)))
            box.set_border_style(bx, f_borderStyle(mitBorder))
            box.set_border_color(bx, mitBOXColor)
    drop

// Same treatment for a box's Consequent Encroachment line. Safe to call with an na line id.
f_mitLine(line ln, string action) =>
    if not na(ln)
        if action == 'Delete'
            line.delete(ln)
        else if action == 'Gray Out'
            line.set_color(ln, mitBOXColor)
    true

// Applies the configured tested styling. baseCol is the zone's own picker colour, so the fade
// is relative to whatever the user has chosen rather than a hard-coded value.
f_testedBox(box bx, color baseCol) =>
    if testedFadeOn
        box.set_bgcolor(bx, f_area(f_fade(baseCol, testedFadeAmt)))
    if testedBorder == 'None'
        box.set_border_width(bx, BoxBorderWidth)
    else
        box.set_border_width(bx, int(math.max(BoxBorderWidth, 1)))
        box.set_border_style(bx, f_borderStyle(testedBorder))
        box.set_border_color(bx, baseCol)
    true

// Deletes every box in an array and empties it. Used for the "off" state of a feature, so that
// unchecking a switch clears the chart instead of freezing whatever was already drawn.
f_clearBoxes(array<box> a) =>
    if array.size(a) > 0
        for i = array.size(a) - 1 to 0
            box bx = array.get(a, i)
            if not na(bx)
                box.delete(bx)
        array.clear(a)
    true

f_clearLines(array<line> a) =>
    if array.size(a) > 0
        for i = array.size(a) - 1 to 0
            line ln = array.get(a, i)
            if not na(ln)
                line.delete(ln)
        array.clear(a)
    true

// Trims the oldest element off a box array plus its parallel line array, keeping them in lockstep.
f_trimBoxLine(array<box> b, array<line> l, int limit) =>
    if array.size(b) > limit
        box bx = array.shift(b)
        if not na(bx)
            box.delete(bx)
        if array.size(l) > 0
            line ln = array.shift(l)
            if not na(ln)
                line.delete(ln)
    true

f_trimBoxes(array<box> b, int limit) =>
    if array.size(b) > limit
        box bx = array.shift(b)
        if not na(bx)
            box.delete(bx)
    true

// ═══════════════════════════════════════════════════════════════════════════════════════
// 9b · ZONE RECORD AND THE SINGLE STATE MACHINE
// ═══════════════════════════════════════════════════════════════════════════════════════
// One record and one function serve every Order Block and every Fair Value Gap, on the chart
// timeframe and on the higher ones. Keeping the box, its C.E. line and its state in the same
// record is what makes the old parallel-array drift impossible: there is nothing to keep in
// step by hand.
type obZone
    float top     = na
    float btm     = na
    bool  isBull  = true
    bool  armed   = false
    bool  tested  = false
    bool  breaker = false
    bool  dead    = false
    box   bx      = na
    line  ln      = na

f_clearZones(array<obZone> zs) =>
    if array.size(zs) > 0
        for i = array.size(zs) - 1 to 0
            obZone z = array.get(zs, i)
            if not na(z.bx)
                box.delete(z.bx)
            if not na(z.ln)
                line.delete(z.ln)
        array.clear(zs)
    true

f_killZone(obZone z) =>
    if not na(z.bx)
        box.delete(z.bx)
    if not na(z.ln)
        line.delete(z.ln)
    true

// Removes the oldest zone whose dead flag matches, and says whether it found one.
f_dropOldest(array<obZone> zs, bool wantDead) =>
    bool done = false
    if array.size(zs) > 0
        for i = 0 to array.size(zs) - 1
            if array.get(zs, i).dead == wantDead
                f_killZone(array.get(zs, i))
                array.remove(zs, i)
                done := true
                break
    done

// A mitigated record is always sacrificed before a live zone, and this matters more than it
// looks. When the two were evicted in plain chronological order, a chart with Mitigated Action
// set to Gray Out spent its box limit on grey history and pushed old, never filled zones off
// to make room, while the same chart set to Delete kept them. The action a zone gets AFTER it
// is filled was deciding which UNFILLED zones you could see. Now a live zone is dropped only
// when the live ones on their own exceed the limit, which is the same number under every
// setting, and the limit still means what it says: that many boxes, not twice that many.
f_trimZones(array<obZone> zs, int limit) =>
    if array.size(zs) > limit
        if not f_dropOldest(zs, true)
            f_dropOldest(zs, false)
    true

// True when any live, armed zone in the array is being touched on this bar. Used by the alerts.
f_anyTouch(array<obZone> zs) =>
    bool t = false
    if array.size(zs) > 0
        for i = 0 to array.size(zs) - 1
            obZone z = array.get(zs, i)
            if not z.dead and z.armed and low <= z.top and high >= z.btm
                t := true
    t

// Replays the bars a zone was built on top of, from its anchor candle forward to the bar that
// created it, through the same arm / test / fill rule the live engine uses. An Order Block is
// anchored up to Max Scan Bars behind its own breakout, so price has usually already left the
// box and often already come back into it before the zone record exists at all. Without this
// those bars are never judged and a block that was plainly wicked into shows as untouched.
// Returns 0 untouched, 1 tested, 2 filled. Runs in whatever bar space it is called from, so
// the chart engine and the higher-timeframe detector share it.
f_seedState(bool isBull, float top, float btm, int barsBack) =>
    int  st    = 0
    bool armed = false
    if barsBack > 0
        for k = barsBack to 1
            if st != 2
                bool sOut   = isBull ? close[k] > top : close[k] < btm
                bool sTouch = low[k] <= top and high[k] >= btm
                bool sFull  = isBull ? low[k] <= btm : high[k] >= top
                if not armed
                    // The anchor candle cannot arm its own zone: its close is inside its own
                    // range by definition, which is what keeps it from counting as a test.
                    if sOut
                        armed := true
                        armed
                else if sFull
                    st := 2
                    st
                else if sTouch and st == 0
                    st := 1
                    st
    st

// Applies what the replay found to a zone that has just been created, before it joins its
// array. Returns true when the zone was born already filled and the Delete action removed it.
f_seedApply(obZone z, int seed, color baseCol, string action) =>
    bool drop = false
    if seed == 2
        z.dead := true
        f_mitLine(z.ln, action)
        if f_mitBox(z.bx, action)
            drop := true
    else if seed == 1
        z.tested := true
        if markTested
            f_testedBox(z.bx, baseCol)
    drop

// Repaints a live zone's fill from its current state: brighter while price is trading inside
// it, back to normal the moment price leaves, and respecting the tested fade so a zone that
// has already been tested does not silently lose its faded look on the way out. Only ever
// called on zones that are still alive, so it cannot overwrite a mitigated zone's frozen grey.
f_zoneTint(obZone z, color baseCol, color flipCol, bool inside) =>
    color c = z.breaker ? flipCol : baseCol
    if inside
        box.set_bgcolor(z.bx, f_area(f_boost(c, highlightBoost)))
    else
        box.set_bgcolor(z.bx, f_area(z.tested and testedFadeOn ? f_fade(c, testedFadeAmt) : c))
    true

// The state machine. Three stages, in this order, and the order is the whole point:
//
//   ARMED   a candle CLOSES outside the zone. Nothing is marked before that, which is how the
//           candles that built the zone are kept from counting as a test of it. Arming happens
//           on its own bar; testing can only start on the bar after.
//   TESTED  first touch of any kind once armed. A wick counts, a body counts, and it does not
//           matter whether price is inside or outside at the close. Permanent.
//   FILLED  price crosses the zone end to end, far edge included, wick or body. The zone is
//           spent. With flipping enabled it changes polarity instead of dying, which is the
//           Breaker Block for blocks and the Inverse FVG for gaps, the same idea either way.
//
// A zone entered but not crossed end to end stays tested and keeps its dashed border.
// Returns true when the caller must drop the zone from its array.
f_zoneStep(obZone z, color baseCol, color flipCol, string flipLabel, bool canFlip, string action, int rightX, bool doExtend, bool doHighlight) =>
    bool drop = false
    if not z.dead
        bool outside = z.isBull ? close > z.top : close < z.btm
        bool touch   = low <= z.top and high >= z.btm
        bool full    = z.isBull ? low <= z.btm : high >= z.top
        bool inside  = close <= z.top and close >= z.btm
        if not z.armed
            if outside
                z.armed := true
                z.armed
            if doExtend
                box.set_right(z.bx, rightX)
                if not na(z.ln)
                    line.set_x2(z.ln, rightX)
            if doHighlight
                f_zoneTint(z, baseCol, flipCol, inside)
        else if full
            if canFlip and not z.breaker
                z.breaker := true
                z.isBull  := not z.isBull
                z.armed   := false
                z.tested  := false
                box.set_bgcolor(z.bx, f_area(flipCol))
                box.set_border_width(z.bx, BoxBorderWidth)
                box.set_border_style(z.bx, BoxBorder)
                box.set_border_color(z.bx, color.new(flipCol, BorderTransparency))
                if plotBoxLabel
                    box.set_text(z.bx, flipLabel)
                box.set_right(z.bx, rightX)
                if not na(z.ln)
                    line.set_color(z.ln, color.new(flipCol, cetransparency))
                    line.set_x2(z.ln, rightX)
            else
                z.dead := true
                f_mitLine(z.ln, action)
                if f_mitBox(z.bx, action)
                    drop := true
        else
            if doExtend
                box.set_right(z.bx, rightX)
                if not na(z.ln)
                    line.set_x2(z.ln, rightX)
            if touch and not z.tested
                z.tested := true
                if markTested
                    f_testedBox(z.bx, z.breaker ? flipCol : baseCol)
            if doHighlight
                f_zoneTint(z, baseCol, flipCol, inside)
    drop

f_stepAll(array<obZone> zs, color baseCol, color flipCol, string flipLabel, bool canFlip, string action, int rightX, bool doExtend, bool doHighlight) =>
    if array.size(zs) > 0
        for i = array.size(zs) - 1 to 0
            if f_zoneStep(array.get(zs, i), baseCol, flipCol, flipLabel, canFlip, action, rightX, doExtend, doHighlight)
                array.remove(zs, i)
    true

// ═══════════════════════════════════════════════════════════════════════════════════════
// 10 · STATE
// ═══════════════════════════════════════════════════════════════════════════════════════

var bool buvitouch     = false
var bool bevitouch     = false
var bool bugaptouch    = false
var bool begaptouch    = false

bool isbuinversefvg = false
bool isbeinversefvg = false
bool buimpfvgtouch  = false
bool beimpfvgtouch  = false
bool bufvgtouch     = false
bool befvgtouch     = false
bool buinvfvgtouch  = false
bool beinvfvgtouch  = false

var array<box>  _gapsboxesbu  = array.new_box()
var array<box>  _gapsboxesbe  = array.new_box()
var array<box>  _bullishvi    = array.new_box()
var array<box>  _bearishvi    = array.new_box()

// Gap families as zone records. Inverse FVG no longer needs arrays of its own: a flipped gap
// stays in the same array with its direction reversed, exactly like a Breaker Block.
var array<obZone> bullFvgZones  = array.new<obZone>()
var array<obZone> bearFvgZones  = array.new<obZone>()
var array<obZone> bullIfvgZones = array.new<obZone>()
var array<obZone> bearIfvgZones = array.new<obZone>()

var array<line> bugapce       = array.new_line()
var array<line> begapce       = array.new_line()

// ═══════════════════════════════════════════════════════════════════════════════════════
// 11 · VOLUME IMBALANCE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════════════

// Every VI variant builds the same shaped box, so the drawing lives in one place.
f_newVIBox(float t, float b, color col, string txt) =>
    box.new(left = bar_index - 1, top = t, right = bar_index + 1, bottom = b,
         bgcolor = f_area(col), border_style = BoxBorder, border_width = BoxBorderWidth,
         border_color = color.new(col, BorderTransparency),
         text = plotBoxLabel ? txt : na, text_halign = labelhalign, text_valign = labelvalign,
         text_size = BoxLabelSize, text_color = BoxLabelColor)

isBuVItype1(index) =>
    open[index] > close[index + 1] and low[index] <= high[index + 1] and close[index] > open[index] and close[index + 1] > open[index + 1]

isBeVItype1(index) =>
    open[index] < close[index + 1] and high[index] >= low[index + 1] and close[index] < open[index] and close[index + 1] < open[index + 1]

isBuVItype2(index) =>
    open[index] < close[index + 1] and close[index] > open[index] and close[index + 1] > open[index + 1] and high[index] >= low[index + 1]

isBeVItype2(index) =>
    open[index] > close[index + 1] and close[index] < open[index] and close[index + 1] < open[index + 1] and low[index] <= high[index + 1]

isBuVItype3(index) =>
    (open[index] > close[index + 1] or open[index] < close[index + 1]) and close[index] > open[index] and close[index + 1] < open[index + 1] and high[index] >= low[index + 1] and low[index] <= high[index + 1]

isBeVItype3(index) =>
    (open[index] < close[index + 1] or open[index] > close[index + 1]) and close[index] < open[index] and close[index + 1] > open[index + 1] and low[index] <= high[index + 1] and high[index] >= low[index + 1]

// Bullish Volume Imbalance, type 1
if isBuVItype1(0) and (classicvi or advancedvi)
    array.push(_bullishvi, f_newVIBox(open, close[1], bullimbalance, 'VI+'))
    f_trimBoxes(_bullishvi, viMaxBoxSet)

// Bearish Volume Imbalance, type 1
if isBeVItype1(0) and (classicvi or advancedvi)
    array.push(_bearishvi, f_newVIBox(close[1], open, bearimbalance, 'VI-'))
    f_trimBoxes(_bearishvi, viMaxBoxSet)

// Bullish Volume Imbalance, type 2
if isBuVItype2(0) and advancedvi
    array.push(_bullishvi, f_newVIBox(close[1], open, bullimbalance, 'VI+'))
    f_trimBoxes(_bullishvi, viMaxBoxSet)

// Bearish Volume Imbalance, type 2
if isBeVItype2(0) and advancedvi
    array.push(_bearishvi, f_newVIBox(open, close[1], bearimbalance, 'VI-'))
    f_trimBoxes(_bearishvi, viMaxBoxSet)

// Bullish Volume Imbalance, type 3
if isBuVItype3(0) and advancedvi
    array.push(_bullishvi, f_newVIBox(math.max(open, close[1]), math.min(open, close[1]), bullimbalance, 'VI+'))
    f_trimBoxes(_bullishvi, viMaxBoxSet)

// Bearish Volume Imbalance, type 3
if isBeVItype3(0) and advancedvi
    array.push(_bearishvi, f_newVIBox(math.min(open, close[1]), math.max(open, close[1]), bearimbalance, 'VI-'))
    f_trimBoxes(_bearishvi, viMaxBoxSet)

// Reliable "off" state: with the type set to None, clear whatever is still on the chart.
if not classicvi and not advancedvi
    f_clearBoxes(_bullishvi)
    f_clearBoxes(_bearishvi)

// Extend every VI box, mitigated ones included, when the user asks for it.
if extendallvis and array.size(_bullishvi) > 0
    for i = array.size(_bullishvi) - 1 to 0
        box.set_right(array.get(_bullishvi, i), bar_index + 1)
if extendallvis and array.size(_bearishvi) > 0
    for i = array.size(_bearishvi) - 1 to 0
        box.set_right(array.get(_bearishvi, i), bar_index + 1)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 12 · GAP ENGINE
// ═══════════════════════════════════════════════════════════════════════════════════════
// Fix versus the original: a bullish gap used to push a real box into the bullish array AND an
// na placeholder into the bearish one (and the reverse for a bearish gap). Those placeholders
// counted against "Maximum Box Displayed", so the real limit was roughly half of what the input
// said. Each gap now only touches the array that belongs to it.

f_newGapBox(float t, float b, string txt) =>
    box.new(left = bar_index - 1, top = t, right = bar_index + 1, bottom = b,
         bgcolor = f_area(gapcolor), border_color = color.new(gapcolor, BorderTransparency),
         border_style = BoxBorder, border_width = BoxBorderWidth,
         text = plotBoxLabel ? txt : na, text_halign = labelhalign, text_valign = labelvalign,
         text_size = BoxLabelSize, text_color = BoxLabelColor)

f_newGapLine(float y) =>
    // if/else rather than a ternary on purpose: a Pine ternary evaluates both branches, so the
    // ternary form would build a line object even with C.E. switched off and burn line slots.
    line l = na
    if cegap
        l := line.new(bar_index - 1, y, bar_index, y, style = cegaplinetype, color = color.new(gapcolor, cetransparency))
    l

if (high[1] < low or low[1] > high) and (truegap or gapwithimb)
    if high[1] < low
        float gTop = truegap ? low : open
        float gBot = truegap ? high[1] : close[1]
        array.push(_gapsboxesbu, f_newGapBox(gTop, gBot, 'GAP+'))
        array.push(bugapce, f_newGapLine(math.avg(gTop, gBot)))
        f_trimBoxLine(_gapsboxesbu, bugapce, gapsMaxBoxSet)
    else if low[1] > high
        float gTop = truegap ? low[1] : close[1]
        float gBot = truegap ? high : open
        array.push(_gapsboxesbe, f_newGapBox(gTop, gBot, 'GAP-'))
        array.push(begapce, f_newGapLine(math.avg(gTop, gBot)))
        f_trimBoxLine(_gapsboxesbe, begapce, gapsMaxBoxSet)

// Reliable "off" state for GAP boxes.
if not truegap and not gapwithimb
    f_clearBoxes(_gapsboxesbu)
    f_clearBoxes(_gapsboxesbe)
    f_clearLines(bugapce)
    f_clearLines(begapce)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 13 · FAIR VALUE GAP ENGINE
// ═══════════════════════════════════════════════════════════════════════════════════════

isFvgUp(index) =>
    low[index] > high[index + 2] and low[index + 1] <= high[index + 2] and high[index + 1] >= low[index]

isFvgDown(index) =>
    high[index] < low[index + 2] and high[index] >= low[index + 1] and high[index + 1] >= low[index + 2]

// Box and state handed back as one record. Gaps carry no mid-line: Order Blocks never had
// one and the two are meant to read the same way.
f_newFvgZone(bool isBull, int left, float t, float b, color col, string txt) =>
    box bx = box.new(left = left, top = t, right = bar_index, bottom = b,
         bgcolor = f_area(col), border_color = color.new(col, BorderTransparency),
         border_style = BoxBorder, border_width = BoxBorderWidth,
         text = plotBoxLabel ? txt : na, text_halign = labelhalign, text_valign = labelvalign,
         text_size = BoxLabelSize, text_color = BoxLabelColor)
    obZone.new(top = t, btm = b, isBull = isBull, bx = bx)

// Removes the newest zone, used by the Liquidity Void merge below.
f_popZone(array<obZone> zs) =>
    if array.size(zs) > 0
        f_killZone(array.pop(zs))
    true

if isFvgUp(0) and not liquidityvoidmode and (plotFVG or Inversefvgmode)
    array.push(bullFvgZones, f_newFvgZone(true, bar_index - 2, low[0], high[2], fvgBullColor, 'FVG+'))
    f_trimZones(bullFvgZones, fvgMaxBoxSet)

if isFvgDown(0) and not liquidityvoidmode and (plotFVG or Inversefvgmode)
    array.push(bearFvgZones, f_newFvgZone(false, bar_index - 2, low[2], high[0], fvgBearColor, 'FVG-'))
    f_trimZones(bearFvgZones, fvgMaxBoxSet)

if not plotFVG and not liquidityvoidmode and not Inversefvgmode
    f_clearZones(bullFvgZones)
    f_clearZones(bearFvgZones)

// Liquidity Void: consecutive gaps are merged into one region. Gated on Liquidity Void mode
// alone. Running it in Inverse-only mode as the original did drew every standalone gap twice.
bool bulv = false
bool belv = false

if liquidityvoidmode
    if isFvgUp(0) and isFvgUp(1) and array.size(bullFvgZones) > 0
        bulv := true
        obZone lz = array.get(bullFvgZones, array.size(bullFvgZones) - 1)
        float keepBtm  = lz.btm
        int   keepLeft = box.get_left(lz.bx)
        f_popZone(bullFvgZones)
        array.push(bullFvgZones, f_newFvgZone(true, keepLeft, low[0], keepBtm, fvgBullColor, 'LV+'))
        f_trimZones(bullFvgZones, fvgMaxBoxSet)
    else if isFvgUp(0)
        array.push(bullFvgZones, f_newFvgZone(true, bar_index - 2, low[0], high[2], fvgBullColor, 'FVG+'))
        f_trimZones(bullFvgZones, fvgMaxBoxSet)

    if isFvgDown(0) and isFvgDown(1) and array.size(bearFvgZones) > 0
        belv := true
        obZone lz2 = array.get(bearFvgZones, array.size(bearFvgZones) - 1)
        float keepTop   = lz2.top
        int   keepLeft2 = box.get_left(lz2.bx)
        f_popZone(bearFvgZones)
        array.push(bearFvgZones, f_newFvgZone(false, keepLeft2, keepTop, high[0], fvgBearColor, 'LV-'))
        f_trimZones(bearFvgZones, fvgMaxBoxSet)
    else if isFvgDown(0)
        array.push(bearFvgZones, f_newFvgZone(false, bar_index - 2, low[2], high[0], fvgBearColor, 'FVG-'))
        f_trimZones(bearFvgZones, fvgMaxBoxSet)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 14 · IMPLIED FAIR VALUE GAP
// ═══════════════════════════════════════════════════════════════════════════════════════

isBuIFvg(index) =>
    high[index] > high[index + 2] and low[index + 2] < low[index] and low[index] <= high[index + 2] and high[index + 2] - math.max(open[index + 2], close[index + 2]) > (math.max(open[index + 2], close[index + 2]) - math.min(open[index + 2], close[index + 2])) / 2 and math.min(open[index], close[index]) - low[index] > (math.max(open[index], close[index]) - math.min(open[index], close[index])) / 2 and low[index] > low[index + 1] and (high[index + 2] + math.max(open[index + 2], close[index + 2])) / 2 < (math.min(open[index], close[index]) + low[index]) / 2 and high[index] > high[index + 1] and close[index + 1] > open[index + 1]

isBeIFvg(index) =>
    low[index] < low[index + 2] and high[index + 2] > high[index] and high[index] >= low[index + 2] and math.min(open[index + 2], close[index + 2]) - low[index + 2] > (math.max(open[index + 2], close[index + 2]) - math.min(open[index + 2], close[index + 2])) / 2 and high[index] - math.max(open[index], close[index]) > (math.max(open[index], close[index]) - math.min(open[index], close[index])) / 2 and high[index] < high[index + 1] and (math.min(open[index + 2], close[index + 2]) + low[index + 2]) / 2 > (high[index] + math.max(open[index], close[index])) / 2 and low[index] < low[index + 1] and close[index + 1] < open[index + 1]

if isBuIFvg(0) and showifvg
    array.push(bullIfvgZones, f_newFvgZone(true, bar_index - 2, (math.min(open, close) + low) / 2, (high[2] + math.max(open[2], close[2])) / 2, ifvgBullColor, 'Imp.FVG+'))
    f_trimZones(bullIfvgZones, fvgMaxBoxSet)

if isBeIFvg(0) and showifvg
    array.push(bearIfvgZones, f_newFvgZone(false, bar_index - 2, (math.min(open[2], close[2]) + low[2]) / 2, (math.max(open, close) + high) / 2, ifvgBearColor, 'Imp.FVG-'))
    f_trimZones(bearIfvgZones, fvgMaxBoxSet)

if not showifvg
    f_clearZones(bullIfvgZones)
    f_clearZones(bearIfvgZones)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 15 · HIGHLIGHT HELPER
// ═══════════════════════════════════════════════════════════════════════════════════════
// Two-way, unlike the original: a box brightens while price is inside it and falls back to
// its normal fill the moment price leaves. Only ever called on boxes that are still live,
// so it cannot overwrite a mitigated box's frozen colours.
f_highlightBox(box bx, color baseCol, bool inside) =>
    if inside
        box.set_bgcolor(bx, f_area(f_boost(baseCol, highlightBoost)))
        if BoxBorderWidth > 0
            box.set_border_color(bx, f_boost(baseCol, highlightBoost))
    else
        box.set_bgcolor(bx, f_area(baseCol))
        if BoxBorderWidth > 0
            box.set_border_color(bx, color.new(baseCol, BorderTransparency))
    true

// ═══════════════════════════════════════════════════════════════════════════════════════
// 16 · GAP ZONE STATE PASS
// ═══════════════════════════════════════════════════════════════════════════════════════
// Four families, one call each. What used to be six blocks of Engulf, Mitigate and Rebalance
// branching per direction is now the single rule described in the Zone States group.
//
// Flipping is on for the chart-timeframe gaps when Inverse FVG is enabled: a gap filled end to
// end changes polarity and carries on as an inverse gap instead of being mitigated. Implied
// gaps do not flip.

buimpfvgtouch := f_anyTouch(bullIfvgZones)
beimpfvgtouch := f_anyTouch(bearIfvgZones)
bufvgtouch    := f_anyTouch(bullFvgZones)
befvgtouch    := f_anyTouch(bearFvgZones)

f_stepAll(bullFvgZones,  fvgBullColor,  beinvfvgcolor, 'I.FVG-', Inversefvgmode, mitActionFVG, bar_index + 1, extendfvgbox, HighlightBox)
f_stepAll(bearFvgZones,  fvgBearColor,  buinvfvgcolor, 'I.FVG+', Inversefvgmode, mitActionFVG, bar_index + 1, extendfvgbox, HighlightBox)
f_stepAll(bullIfvgZones, ifvgBullColor, ifvgBullColor, 'Imp.FVG+', false, mitActionFVG, bar_index + 1, extendfvgbox, HighlightBox)
f_stepAll(bearIfvgZones, ifvgBearColor, ifvgBearColor, 'Imp.FVG-', false, mitActionFVG, bar_index + 1, extendfvgbox, HighlightBox)

// A gap that has flipped is an inverse gap, which is what the inverse alerts report.
buinvfvgtouch := false
beinvfvgtouch := false
if array.size(bearFvgZones) > 0
    for i = 0 to array.size(bearFvgZones) - 1
        obZone z = array.get(bearFvgZones, i)
        if z.breaker and not z.dead and z.armed and low <= z.top and high >= z.btm
            buinvfvgtouch := true
            buinvfvgtouch
if array.size(bullFvgZones) > 0
    for i = 0 to array.size(bullFvgZones) - 1
        obZone z = array.get(bullFvgZones, i)
        if z.breaker and not z.dead and z.armed and low <= z.top and high >= z.btm
            beinvfvgtouch := true
            beinvfvgtouch

// Inverse-only mode: the base gaps stay invisible until they flip, as before. A flipped zone
// carries its own colour and is left alone.
if not plotFVG and not liquidityvoidmode and Inversefvgmode
    if array.size(bullFvgZones) > 0
        for i = 0 to array.size(bullFvgZones) - 1
            obZone z = array.get(bullFvgZones, i)
            if not z.breaker
                box.set_bgcolor(z.bx, color.new(fvgBullColor, 100))
                box.set_text_color(z.bx, color.new(BoxLabelColor, 100))
                box.set_border_color(z.bx, color.new(fvgBullColor, 100))
                if not na(z.ln)
                    line.set_color(z.ln, color.new(fvgBullColor, 100))
    if array.size(bearFvgZones) > 0
        for i = 0 to array.size(bearFvgZones) - 1
            obZone z = array.get(bearFvgZones, i)
            if not z.breaker
                box.set_bgcolor(z.bx, color.new(fvgBearColor, 100))
                box.set_text_color(z.bx, color.new(BoxLabelColor, 100))
                box.set_border_color(z.bx, color.new(fvgBearColor, 100))
                if not na(z.ln)
                    line.set_color(z.ln, color.new(fvgBearColor, 100))

// ═══════════════════════════════════════════════════════════════════════════════════════
// 20 · VOLUME IMBALANCE, EXTEND AND MITIGATE
// ═══════════════════════════════════════════════════════════════════════════════════════

if array.size(_bullishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Engulf'
    for i = array.size(_bullishvi) - 1 to 0
        box   _box      = array.get(_bullishvi, i)
        float _boxLow   = box.get_bottom(_box)
        int   _boxRight = box.get_right(_box)
        if close >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if close < _boxLow and bar_index == _boxRight
            if f_mitBox(_box, mitActionFVG)
                array.remove(_bullishvi, i)

if array.size(_bearishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Engulf'
    for i = array.size(_bearishvi) - 1 to 0
        box   _box      = array.get(_bearishvi, i)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if close <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if close > _boxHigh and bar_index == _boxRight
            if f_mitBox(_box, mitActionFVG)
                array.remove(_bearishvi, i)

if array.size(_bullishvi) > 0 and extendvibox and vimitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bullishvi) - 1 to 0
        box   _box      = array.get(_bullishvi, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if bar_index == _boxRight
            bool inside = close >= _boxLow and low < _boxHigh
            f_highlightBox(_box, bullimbalance, inside)
            if inside
                buvitouch := true
                buvitouch

if array.size(_bearishvi) > 0 and extendvibox and vimitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_bearishvi) - 1 to 0
        box   _box      = array.get(_bearishvi, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if bar_index == _boxRight
            bool inside = close <= _boxHigh and high > _boxLow
            f_highlightBox(_box, bearimbalance, inside)
            if inside
                bevitouch := true
                bevitouch

if array.size(_bullishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Mitigate'
    for i = array.size(_bullishvi) - 1 to 0
        box   _box      = array.get(_bullishvi, i)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if low > _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if low <= _boxHigh and bar_index == _boxRight
            buvitouch := true
            if f_mitBox(_box, mitActionFVG)
                array.remove(_bullishvi, i)

if array.size(_bearishvi) > 0 and extendvibox and barstate.isconfirmed and vimitigationtype == 'Mitigate'
    for i = array.size(_bearishvi) - 1 to 0
        box   _box      = array.get(_bearishvi, i)
        float _boxLow   = box.get_bottom(_box)
        int   _boxRight = box.get_right(_box)
        if high < _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
        else if high >= _boxLow and bar_index == _boxRight
            bevitouch := true
            if f_mitBox(_box, mitActionFVG)
                array.remove(_bearishvi, i)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 21 · GAP, EXTEND AND MITIGATE
// ═══════════════════════════════════════════════════════════════════════════════════════

if array.size(_gapsboxesbu) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Engulf'
    for i = array.size(_gapsboxesbu) - 1 to 0
        box   _box      = array.get(_gapsboxesbu, i)
        line  _line     = na
        if i < array.size(bugapce)
            _line := array.get(bugapce, i)
        float _boxLow   = box.get_bottom(_box)
        int   _boxRight = box.get_right(_box)
        if close >= _boxLow and open >= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            if not na(_line)
                line.set_x2(_line, bar_index + 1)
        else if (close < _boxLow or open < _boxLow) and bar_index == _boxRight
            f_mitLine(_line, mitActionFVG)
            if f_mitBox(_box, mitActionFVG)
                array.remove(_gapsboxesbu, i)
                if i < array.size(bugapce)
                    array.remove(bugapce, i)

if array.size(_gapsboxesbe) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Engulf'
    for i = array.size(_gapsboxesbe) - 1 to 0
        box   _box      = array.get(_gapsboxesbe, i)
        line  _line     = na
        if i < array.size(begapce)
            _line := array.get(begapce, i)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if close <= _boxHigh and open <= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            if not na(_line)
                line.set_x2(_line, bar_index + 1)
        else if (close > _boxHigh or open > _boxHigh) and bar_index == _boxRight
            f_mitLine(_line, mitActionFVG)
            if f_mitBox(_box, mitActionFVG)
                array.remove(_gapsboxesbe, i)
                if i < array.size(begapce)
                    array.remove(begapce, i)

if array.size(_gapsboxesbu) > 0 and extendgapbox and gapmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_gapsboxesbu) - 1 to 0
        box   _box      = array.get(_gapsboxesbu, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if bar_index == _boxRight
            bool inside = close >= _boxLow and open >= _boxLow and low < _boxHigh
            f_highlightBox(_box, gapcolor, inside)
            if inside
                bugaptouch := true
                bugaptouch

if array.size(_gapsboxesbe) > 0 and extendgapbox and gapmitigationtype == 'Engulf' and HighlightBox
    for i = array.size(_gapsboxesbe) - 1 to 0
        box   _box      = array.get(_gapsboxesbe, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if bar_index == _boxRight
            bool inside = close <= _boxHigh and open <= _boxHigh and high > _boxLow
            f_highlightBox(_box, gapcolor, inside)
            if inside
                begaptouch := true
                begaptouch

if array.size(_gapsboxesbu) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Rebalance'
    for i = array.size(_gapsboxesbu) - 1 to 0
        box   _box      = array.get(_gapsboxesbu, i)
        line  _line     = na
        if i < array.size(bugapce)
            _line := array.get(bugapce, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if low >= _boxHigh and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            if not na(_line)
                line.set_x2(_line, bar_index + 1)
        else if low < _boxHigh and low > _boxLow and bar_index == _boxRight
            box.set_top(_box, low)
            box.set_right(_box, bar_index + 1)
            if not na(_line)
                line.set_x2(_line, bar_index + 1)
                line.set_y1(_line, (low + _boxLow) / 2)
                line.set_y2(_line, (low + _boxLow) / 2)
        else if low <= _boxLow and bar_index == _boxRight
            f_mitLine(_line, mitActionFVG)
            if f_mitBox(_box, mitActionFVG)
                array.remove(_gapsboxesbu, i)
                if i < array.size(bugapce)
                    array.remove(bugapce, i)

if array.size(_gapsboxesbe) > 0 and extendgapbox and barstate.isconfirmed and gapmitigationtype == 'Rebalance'
    for i = array.size(_gapsboxesbe) - 1 to 0
        box   _box      = array.get(_gapsboxesbe, i)
        line  _line     = na
        if i < array.size(begapce)
            _line := array.get(begapce, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if high <= _boxLow and bar_index == _boxRight
            box.set_right(_box, bar_index + 1)
            if not na(_line)
                line.set_x2(_line, bar_index + 1)
        else if high > _boxLow and high < _boxHigh and bar_index == _boxRight
            box.set_bottom(_box, high)
            box.set_right(_box, bar_index + 1)
            if not na(_line)
                line.set_y1(_line, (high + _boxHigh) / 2)
                line.set_y2(_line, (high + _boxHigh) / 2)
                line.set_x2(_line, bar_index + 1)
        else if high >= _boxHigh and bar_index == _boxRight
            f_mitLine(_line, mitActionFVG)
            if f_mitBox(_box, mitActionFVG)
                array.remove(_gapsboxesbe, i)
                if i < array.size(begapce)
                    array.remove(begapce, i)

if array.size(_gapsboxesbu) > 0 and extendgapbox and gapmitigationtype == 'Rebalance' and HighlightBox
    for i = array.size(_gapsboxesbu) - 1 to 0
        box   _box      = array.get(_gapsboxesbu, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if bar_index == _boxRight
            bool inside = low > _boxLow and low < _boxHigh
            f_highlightBox(_box, gapcolor, inside)
            if inside
                bugaptouch := true
                bugaptouch

if array.size(_gapsboxesbe) > 0 and extendgapbox and gapmitigationtype == 'Rebalance' and HighlightBox
    for i = array.size(_gapsboxesbe) - 1 to 0
        box   _box      = array.get(_gapsboxesbe, i)
        float _boxLow   = box.get_bottom(_box)
        float _boxHigh  = box.get_top(_box)
        int   _boxRight = box.get_right(_box)
        if bar_index == _boxRight
            bool inside = high < _boxHigh and high > _boxLow
            f_highlightBox(_box, gapcolor, inside)
            if inside
                begaptouch := true
                begaptouch

// ═══════════════════════════════════════════════════════════════════════════════════════
// 22b · BLOCK CANDLE COLOUR CORRECTION
// ═══════════════════════════════════════════════════════════════════════════════════════
// The leg-extreme scan below finds the candle price actually turned from, and most of the time
// that candle is already the one the classic definition wants: the last down candle before an up
// move, the last up candle before a down move. Sometimes it is not, because a hammer that
// reversed the leg is an up candle holding the lowest low.
//
// This checks only that case. If the extreme candle is already the right colour nothing happens
// and the block is drawn exactly where the scan put it. If it is the wrong colour, its two
// immediate neighbours are examined and the opposite-coloured one replaces it. The block stays
// one candle wide either way.
f_obFix(simple bool isBull, int anchorOff, int span) =>
    int  res = anchorOff
    bool ok  = isBull ? close[anchorOff] < open[anchorOff] : close[anchorOff] > open[anchorOff]
    if not ok
        int  rOff = anchorOff - 1
        int  lOff = anchorOff + 1
        // rOff stops at 1: the breakout candle itself is never a block.
        bool rOk  = rOff >= 1 and (isBull ? close[rOff] < open[rOff] : close[rOff] > open[rOff])
        bool lOk  = lOff <= span and (isBull ? close[lOff] < open[lOff] : close[lOff] > open[lOff])
        if rOk and lOk
            float rv = isBull ? low[rOff] : high[rOff]
            float lv = isBull ? low[lOff] : high[lOff]
            res := (isBull ? lv < rv : lv > rv) ? lOff : rOff
        else if rOk
            res := rOff
        else if lOk
            res := lOff
    res

// ═══════════════════════════════════════════════════════════════════════════════════════
// 23 · CURRENT TIMEFRAME ORDER BLOCK ENGINE
// ═══════════════════════════════════════════════════════════════════════════════════════
// Swing structure first, block second. A confirmed swing high or low is only counted once, and
// the block is the extreme candle of the leg that broke it, not simply the nearest opposite
// coloured candle. In a strong leg the nearest opposite candle is often a small pause bar well
// away from the actual origin of the move, which is why the leg extreme is the better anchor.

var array<obZone> obBullZones = array.new<obZone>()
var array<obZone> obBearZones = array.new<obZone>()

// Unconditional: ta.* must run on every bar to keep its internal state correct, so the swing
// scan is never placed inside an if.
float obUpper = ta.highest(obSwingLen)
float obLower = ta.lowest(obSwingLen)

var int   obOs      = 0
var float obTopY    = na
var int   obTopX    = na
var bool  obTopUsed = true
var float obBtmY    = na
var int   obBtmX    = na
var bool  obBtmUsed = true

// Snapshot before the update: a var still holds the previous bar's committed value at this
// point, which is what the flip test needs, and it avoids history-referencing a var.
int obOsPrev = obOs
obOs := high[obSwingLen] > obUpper ? 0 : low[obSwingLen] < obLower ? 1 : obOs

if obOs == 0 and obOsPrev != 0
    obTopY    := high[obSwingLen]
    obTopX    := bar_index - obSwingLen
    obTopUsed := false
    obTopUsed
if obOs == 1 and obOsPrev != 1
    obBtmY    := low[obSwingLen]
    obBtmX    := bar_index - obSwingLen
    obBtmUsed := false
    obBtmUsed

float obSwingRange = not na(obTopY) and not na(obBtmY) ? math.abs(obTopY - obBtmY) : 0.0

bool obNewBull = false
bool obNewBear = false

// Bullish block: price closes above the last unbroken swing high.
if showCurOB and not na(obTopY) and not obTopUsed and close > obTopY + obSwingRange * obBreakFib
    obTopUsed := true
    int   span   = math.max(1, math.min(bar_index - obTopX - 1, obScanMax))
    float minima = obUseBody ? math.min(open[1], close[1]) : low[1]
    float maxima = obUseBody ? math.max(open[1], close[1]) : high[1]
    int   locOff = 1
    if span >= 2
        for k = 2 to span
            float vLo = obUseBody ? math.min(open[k], close[k]) : low[k]
            if vLo < minima
                minima := vLo
                maxima := obUseBody ? math.max(open[k], close[k]) : high[k]
                locOff := k
    locOff := f_obFix(true, locOff, span)
    maxima := obUseBody ? math.max(open[locOff], close[locOff]) : high[locOff]
    minima := obUseBody ? math.min(open[locOff], close[locOff]) : low[locOff]
    box nb = box.new(left = bar_index - locOff, top = maxima, right = bar_index + 1, bottom = minima,
         bgcolor = f_area(obBullColor), border_color = color.new(obBullColor, BorderTransparency),
         border_style = BoxBorder, border_width = BoxBorderWidth,
         text = plotBoxLabel ? 'OB+' : na, text_halign = labelhalign, text_valign = labelvalign,
         text_size = BoxLabelSize, text_color = BoxLabelColor)
    int     seedBu = f_seedState(true, maxima, minima, locOff)
    obZone  zBu    = obZone.new(top = maxima, btm = minima, isBull = true, armed = true, bx = nb)
    bool    dropBu = f_seedApply(zBu, seedBu, obBullColor, mitActionOB)
    if not dropBu
        array.push(obBullZones, zBu)
        f_trimZones(obBullZones, obMaxBoxes)
    obNewBull := true
    obNewBull

// Bearish block: price closes below the last unbroken swing low.
if showCurOB and not na(obBtmY) and not obBtmUsed and close < obBtmY - obSwingRange * obBreakFib
    obBtmUsed := true
    int   span2   = math.max(1, math.min(bar_index - obBtmX - 1, obScanMax))
    float maxima2 = obUseBody ? math.max(open[1], close[1]) : high[1]
    float minima2 = obUseBody ? math.min(open[1], close[1]) : low[1]
    int   locOff2 = 1
    if span2 >= 2
        for k = 2 to span2
            float vHi = obUseBody ? math.max(open[k], close[k]) : high[k]
            if vHi > maxima2
                maxima2 := vHi
                minima2 := obUseBody ? math.min(open[k], close[k]) : low[k]
                locOff2 := k
    locOff2 := f_obFix(false, locOff2, span2)
    maxima2 := obUseBody ? math.max(open[locOff2], close[locOff2]) : high[locOff2]
    minima2 := obUseBody ? math.min(open[locOff2], close[locOff2]) : low[locOff2]
    box nb2 = box.new(left = bar_index - locOff2, top = maxima2, right = bar_index + 1, bottom = minima2,
         bgcolor = f_area(obBearColor), border_color = color.new(obBearColor, BorderTransparency),
         border_style = BoxBorder, border_width = BoxBorderWidth,
         text = plotBoxLabel ? 'OB-' : na, text_halign = labelhalign, text_valign = labelvalign,
         text_size = BoxLabelSize, text_color = BoxLabelColor)
    int     seedBe = f_seedState(false, maxima2, minima2, locOff2)
    obZone  zBe    = obZone.new(top = maxima2, btm = minima2, isBull = false, armed = true, bx = nb2)
    bool    dropBe = f_seedApply(zBe, seedBe, obBearColor, mitActionOB)
    if not dropBe
        array.push(obBearZones, zBe)
        f_trimZones(obBearZones, obMaxBoxes)
    obNewBear := true
    obNewBear

if showCurOB
    f_stepAll(obBullZones, obBullColor, obBullBreakCol, 'BB-', obShowBreak, mitActionOB, bar_index + 1, true, false)
    f_stepAll(obBearZones, obBearColor, obBearBreakCol, 'BB+', obShowBreak, mitActionOB, bar_index + 1, true, false)
else
    f_clearZones(obBullZones)
    f_clearZones(obBearZones)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 24 · HIGHER TIMEFRAME ORDER BLOCK DETECTOR
// ═══════════════════════════════════════════════════════════════════════════════════════
// Runs inside request.security, in the higher timeframe's own bar space, using the same swing
// and leg-extreme rule as the chart engine above so a 1H block and a 1D block are built by the
// same definition.
//
// Why it publishes a counter rather than a flag. The previous version returned a one-bar "new
// block" pulse and the chart side only read it at the exact moment a new higher-timeframe bar
// opened. By then the pulse had been reset, so the two were never true on the same bar and no
// higher-timeframe block was ever drawn. The block now lives in var storage and what is
// published is a counter that only goes up, which the chart side detects by change instead of
// by catching a pulse. With confirmClose on, every field is published one higher-timeframe bar
// late, so nothing moves or disappears after the fact.
f_htfOB(simple int len, simple bool useBody, simple bool confirmClose, simple float breakFib, simple int scanMax) =>
    var int   os      = 0
    var float topY    = na
    var int   topX    = na
    var bool  topUsed = true
    var float btmY    = na
    var int   btmX    = na
    var bool  btmUsed = true

    var int   bullId   = 0
    var float bullTop  = na
    var float bullBtm  = na
    var int   bullLeft = na
    var int   bullSeed = 0

    var int   bearId   = 0
    var float bearTop  = na
    var float bearBtm  = na
    var int   bearLeft = na
    var int   bearSeed = 0

    // Snapshot of what the previous higher-timeframe bar committed. Taken before anything below
    // can change it, so it is the same thing a [1] would give, without history-referencing a
    // variable that lives inside a function.
    int   prevOs       = os
    int   prevBullId   = bullId
    float prevBullTop  = bullTop
    float prevBullBtm  = bullBtm
    int   prevBullLeft = bullLeft
    int   prevBullSeed = bullSeed
    int   prevBearId   = bearId
    float prevBearTop  = bearTop
    float prevBearBtm  = bearBtm
    int   prevBearLeft = bearLeft
    int   prevBearSeed = bearSeed

    float upper = ta.highest(len)
    float lower = ta.lowest(len)
    os := high[len] > upper ? 0 : low[len] < lower ? 1 : os

    if os == 0 and prevOs != 0
        topY    := high[len]
        topX    := bar_index - len
        topUsed := false
        topUsed
    if os == 1 and prevOs != 1
        btmY    := low[len]
        btmX    := bar_index - len
        btmUsed := false
        btmUsed

    float swingRange = not na(topY) and not na(btmY) ? math.abs(topY - btmY) : 0.0

    if not na(topY) and not topUsed and close > topY + swingRange * breakFib
        topUsed := true
        int   span   = math.max(1, math.min(bar_index - topX - 1, scanMax))
        float minima = useBody ? math.min(open[1], close[1]) : low[1]
        float maxima = useBody ? math.max(open[1], close[1]) : high[1]
        int   locOff = 1
        if span >= 2
            for k = 2 to span
                float vLo = useBody ? math.min(open[k], close[k]) : low[k]
                if vLo < minima
                    minima := vLo
                    maxima := useBody ? math.max(open[k], close[k]) : high[k]
                    locOff := k
        locOff := f_obFix(true, locOff, span)
        maxima := useBody ? math.max(open[locOff], close[locOff]) : high[locOff]
        minima := useBody ? math.min(open[locOff], close[locOff]) : low[locOff]
        bullTop  := maxima
        bullBtm  := minima
        bullLeft := time[locOff]
        bullSeed := f_seedState(true, maxima, minima, locOff)
        bullId   := bullId + 1
        bullId

    if not na(btmY) and not btmUsed and close < btmY - swingRange * breakFib
        btmUsed := true
        int   span2   = math.max(1, math.min(bar_index - btmX - 1, scanMax))
        float maxima2 = useBody ? math.max(open[1], close[1]) : high[1]
        float minima2 = useBody ? math.min(open[1], close[1]) : low[1]
        int   locOff2 = 1
        if span2 >= 2
            for k = 2 to span2
                float vHi = useBody ? math.max(open[k], close[k]) : high[k]
                if vHi > maxima2
                    maxima2 := vHi
                    minima2 := useBody ? math.min(open[k], close[k]) : low[k]
                    locOff2 := k
        locOff2 := f_obFix(false, locOff2, span2)
        maxima2 := useBody ? math.max(open[locOff2], close[locOff2]) : high[locOff2]
        minima2 := useBody ? math.min(open[locOff2], close[locOff2]) : low[locOff2]
        bearTop  := maxima2
        bearBtm  := minima2
        bearLeft := time[locOff2]
        bearSeed := f_seedState(false, maxima2, minima2, locOff2)
        bearId   := bearId + 1
        bearId

    int   pubBullId   = confirmClose ? prevBullId   : bullId
    float pubBullTop  = confirmClose ? prevBullTop  : bullTop
    float pubBullBtm  = confirmClose ? prevBullBtm  : bullBtm
    int   pubBullLeft = confirmClose ? prevBullLeft : bullLeft
    int   pubBullSeed = confirmClose ? prevBullSeed : bullSeed
    int   pubBearId   = confirmClose ? prevBearId   : bearId
    float pubBearTop  = confirmClose ? prevBearTop  : bearTop
    float pubBearBtm  = confirmClose ? prevBearBtm  : bearBtm
    int   pubBearLeft = confirmClose ? prevBearLeft : bearLeft
    int   pubBearSeed = confirmClose ? prevBearSeed : bearSeed

    [pubBullId, pubBullTop, pubBullBtm, pubBullLeft, pubBullSeed, pubBearId, pubBearTop, pubBearBtm, pubBearLeft, pubBearSeed]

// ═══════════════════════════════════════════════════════════════════════════════════════
// 25 · MTF MODULE
// ═══════════════════════════════════════════════════════════════════════════════════════

var array<obZone> mtfBullFVG1 = array.new<obZone>()
var array<obZone> mtfBearFVG1 = array.new<obZone>()
var array<obZone> mtfBullOB1  = array.new<obZone>()
var array<obZone> mtfBearOB1  = array.new<obZone>()

var array<obZone> mtfBullFVG2 = array.new<obZone>()
var array<obZone> mtfBearFVG2 = array.new<obZone>()
var array<obZone> mtfBullOB2  = array.new<obZone>()
var array<obZone> mtfBearOB2  = array.new<obZone>()

var array<obZone> mtfBullFVG3 = array.new<obZone>()
var array<obZone> mtfBearFVG3 = array.new<obZone>()
var array<obZone> mtfBullOB3  = array.new<obZone>()
var array<obZone> mtfBearOB3  = array.new<obZone>()

var array<obZone> mtfBullFVG4 = array.new<obZone>()
var array<obZone> mtfBearFVG4 = array.new<obZone>()
var array<obZone> mtfBullOB4  = array.new<obZone>()
var array<obZone> mtfBearOB4  = array.new<obZone>()

var array<obZone> mtfBullFVG5 = array.new<obZone>()
var array<obZone> mtfBearFVG5 = array.new<obZone>()
var array<obZone> mtfBullOB5  = array.new<obZone>()
var array<obZone> mtfBearOB5  = array.new<obZone>()

// A higher-timeframe slot is only valid if it really is higher than the chart.
bool tf1Valid = timeframe.in_seconds(tf1) > timeframe.in_seconds(timeframe.period)
bool tf2Valid = timeframe.in_seconds(tf2) > timeframe.in_seconds(timeframe.period)
bool tf3Valid = timeframe.in_seconds(tf3) > timeframe.in_seconds(timeframe.period)
bool tf4Valid = timeframe.in_seconds(tf4) > timeframe.in_seconds(timeframe.period)
bool tf5Valid = timeframe.in_seconds(tf5) > timeframe.in_seconds(timeframe.period)

// Data fetch. Unconditional top-level calls, the only safe shape for request.security with a
// simple-string timeframe argument. Only the eight series the gap geometry needs are pulled.
[tf1_t0, tf1_t3, tf1_h1, tf1_l1, tf1_h2, tf1_l2, tf1_h3, tf1_l3] = request.security(syminfo.tickerid, tf1, [time, time[3], high[1], low[1], high[2], low[2], high[3], low[3]], lookahead = barmerge.lookahead_off)
[tf2_t0, tf2_t3, tf2_h1, tf2_l1, tf2_h2, tf2_l2, tf2_h3, tf2_l3] = request.security(syminfo.tickerid, tf2, [time, time[3], high[1], low[1], high[2], low[2], high[3], low[3]], lookahead = barmerge.lookahead_off)
[tf3_t0, tf3_t3, tf3_h1, tf3_l1, tf3_h2, tf3_l2, tf3_h3, tf3_l3] = request.security(syminfo.tickerid, tf3, [time, time[3], high[1], low[1], high[2], low[2], high[3], low[3]], lookahead = barmerge.lookahead_off)
[tf4_t0, tf4_t3, tf4_h1, tf4_l1, tf4_h2, tf4_l2, tf4_h3, tf4_l3] = request.security(syminfo.tickerid, tf4, [time, time[3], high[1], low[1], high[2], low[2], high[3], low[3]], lookahead = barmerge.lookahead_off)
[tf5_t0, tf5_t3, tf5_h1, tf5_l1, tf5_h2, tf5_l2, tf5_h3, tf5_l3] = request.security(syminfo.tickerid, tf5, [time, time[3], high[1], low[1], high[2], low[2], high[3], low[3]], lookahead = barmerge.lookahead_off)

[tf1_buId, tf1_buTop, tf1_buBtm, tf1_buLeft, tf1_buSeed, tf1_beId, tf1_beTop, tf1_beBtm, tf1_beLeft, tf1_beSeed] = request.security(syminfo.tickerid, tf1, f_htfOB(mtfObSwingLen, obUseBody, mtfConfirmTF, obBreakFib, obScanMax), lookahead = barmerge.lookahead_off)
[tf2_buId, tf2_buTop, tf2_buBtm, tf2_buLeft, tf2_buSeed, tf2_beId, tf2_beTop, tf2_beBtm, tf2_beLeft, tf2_beSeed] = request.security(syminfo.tickerid, tf2, f_htfOB(mtfObSwingLen, obUseBody, mtfConfirmTF, obBreakFib, obScanMax), lookahead = barmerge.lookahead_off)
[tf3_buId, tf3_buTop, tf3_buBtm, tf3_buLeft, tf3_buSeed, tf3_beId, tf3_beTop, tf3_beBtm, tf3_beLeft, tf3_beSeed] = request.security(syminfo.tickerid, tf3, f_htfOB(mtfObSwingLen, obUseBody, mtfConfirmTF, obBreakFib, obScanMax), lookahead = barmerge.lookahead_off)
[tf4_buId, tf4_buTop, tf4_buBtm, tf4_buLeft, tf4_buSeed, tf4_beId, tf4_beTop, tf4_beBtm, tf4_beLeft, tf4_beSeed] = request.security(syminfo.tickerid, tf4, f_htfOB(mtfObSwingLen, obUseBody, mtfConfirmTF, obBreakFib, obScanMax), lookahead = barmerge.lookahead_off)
[tf5_buId, tf5_buTop, tf5_buBtm, tf5_buLeft, tf5_buSeed, tf5_beId, tf5_beTop, tf5_beBtm, tf5_beLeft, tf5_beSeed] = request.security(syminfo.tickerid, tf5, f_htfOB(mtfObSwingLen, obUseBody, mtfConfirmTF, obBreakFib, obScanMax), lookahead = barmerge.lookahead_off)

// New-bar and new-block detection at global scope. ta.change and history access both need to
// run on every bar, so neither goes inside the processing function.
bool tf1_newBar = ta.change(tf1_t0) != 0
bool tf2_newBar = ta.change(tf2_t0) != 0
bool tf3_newBar = ta.change(tf3_t0) != 0
bool tf4_newBar = ta.change(tf4_t0) != 0
bool tf5_newBar = ta.change(tf5_t0) != 0

bool tf1_buNew = not na(tf1_buId) and tf1_buId != nz(tf1_buId[1], tf1_buId)
bool tf1_beNew = not na(tf1_beId) and tf1_beId != nz(tf1_beId[1], tf1_beId)
bool tf2_buNew = not na(tf2_buId) and tf2_buId != nz(tf2_buId[1], tf2_buId)
bool tf2_beNew = not na(tf2_beId) and tf2_beId != nz(tf2_beId[1], tf2_beId)
bool tf3_buNew = not na(tf3_buId) and tf3_buId != nz(tf3_buId[1], tf3_buId)
bool tf3_beNew = not na(tf3_beId) and tf3_beId != nz(tf3_beId[1], tf3_beId)
bool tf4_buNew = not na(tf4_buId) and tf4_buId != nz(tf4_buId[1], tf4_buId)
bool tf4_beNew = not na(tf4_beId) and tf4_beId != nz(tf4_beId[1], tf4_beId)
bool tf5_buNew = not na(tf5_buId) and tf5_buId != nz(tf5_buId[1], tf5_buId)
bool tf5_beNew = not na(tf5_beId) and tf5_beId != nz(tf5_beId[1], tf5_beId)

// Gap geometry, computed from closed higher-timeframe bars only.
bool tf1_fvgUp   = tf1_l1 > tf1_h3 and tf1_l2 <= tf1_h3 and tf1_h2 >= tf1_l1
bool tf1_fvgDown = tf1_h1 < tf1_l3 and tf1_h1 >= tf1_l2 and tf1_h2 >= tf1_l3
bool tf2_fvgUp   = tf2_l1 > tf2_h3 and tf2_l2 <= tf2_h3 and tf2_h2 >= tf2_l1
bool tf2_fvgDown = tf2_h1 < tf2_l3 and tf2_h1 >= tf2_l2 and tf2_h2 >= tf2_l3
bool tf3_fvgUp   = tf3_l1 > tf3_h3 and tf3_l2 <= tf3_h3 and tf3_h2 >= tf3_l1
bool tf3_fvgDown = tf3_h1 < tf3_l3 and tf3_h1 >= tf3_l2 and tf3_h2 >= tf3_l3
bool tf4_fvgUp   = tf4_l1 > tf4_h3 and tf4_l2 <= tf4_h3 and tf4_h2 >= tf4_l1
bool tf4_fvgDown = tf4_h1 < tf4_l3 and tf4_h1 >= tf4_l2 and tf4_h2 >= tf4_l3
bool tf5_fvgUp   = tf5_l1 > tf5_h3 and tf5_l2 <= tf5_h3 and tf5_h2 >= tf5_l1
bool tf5_fvgDown = tf5_h1 < tf5_l3 and tf5_h1 >= tf5_l2 and tf5_h2 >= tf5_l3

f_newMtfBox(int leftTime, float top, float btm, color col, string txt) =>
    box.new(left = leftTime, top = top, right = time, bottom = btm, xloc = xloc.bar_time,
         bgcolor = f_area(col), border_color = color.new(col, BorderTransparency),
         border_style = BoxBorder, border_width = BoxBorderWidth,
         text = plotBoxLabel ? txt : na, text_size = mtfLabelSize, text_color = mtfLabelColor,
         text_halign = text.align_right, text_valign = text.align_center)

// One slot's worth of work. Contains no ta.* call and no history access, so it is safe to run
// it conditionally.
f_processMTF(string _tfLabel, bool _tfEnabled, bool _tfValid, color _bullColor, color _bearColor, bool _newBar, int _t3, bool _buNew, float _buTop, float _buBtm, int _buLeft, int _buSeed, bool _beNew, float _beTop, float _beBtm, int _beLeft, int _beSeed, bool _fvgUp, bool _fvgDown, float _l1, float _h3, float _l3, float _h1, array<obZone> _bullFVG, array<obZone> _bearFVG, array<obZone> _bullOB, array<obZone> _bearOB) =>
    bool active = enableMTF and _tfEnabled and _tfValid
    if not active
        // Proper off state. Switching the panel or a slot off now clears its boxes instead of
        // leaving them frozen on the chart, which is what the original did.
        f_clearZones(_bullFVG)
        f_clearZones(_bearFVG)
        f_clearZones(_bullOB)
        f_clearZones(_bearOB)
    else
        if not showMTF_FVG
            f_clearZones(_bullFVG)
            f_clearZones(_bearFVG)
        if not showMTF_OB
            f_clearZones(_bullOB)
            f_clearZones(_bearOB)

        if showMTF_FVG and _newBar and not na(_t3)
            if _fvgUp
                box b1 = f_newMtfBox(_t3, _l1, _h3, _bullColor, 'FVG+ [' + _tfLabel + ']')
                array.push(_bullFVG, obZone.new(top = _l1, btm = _h3, isBull = true, bx = b1))
                f_trimZones(_bullFVG, mtfMaxBoxes)
            if _fvgDown
                box b2 = f_newMtfBox(_t3, _l3, _h1, _bearColor, 'FVG- [' + _tfLabel + ']')
                array.push(_bearFVG, obZone.new(top = _l3, btm = _h1, isBull = false, bx = b2))
                f_trimZones(_bearFVG, mtfMaxBoxes)

        if showMTF_OB and _buNew and not na(_buTop) and not na(_buLeft)
            box    b3 = f_newMtfBox(_buLeft, _buTop, _buBtm, _bullColor, 'OB+ [' + _tfLabel + ']')
            obZone z3 = obZone.new(top = _buTop, btm = _buBtm, isBull = true, armed = true, bx = b3)
            if not f_seedApply(z3, nz(_buSeed), _bullColor, mitActionOB)
                array.push(_bullOB, z3)
                f_trimZones(_bullOB, mtfMaxBoxes)

        if showMTF_OB and _beNew and not na(_beTop) and not na(_beLeft)
            box    b4 = f_newMtfBox(_beLeft, _beTop, _beBtm, _bearColor, 'OB- [' + _tfLabel + ']')
            obZone z4 = obZone.new(top = _beTop, btm = _beBtm, isBull = false, armed = true, bx = b4)
            if not f_seedApply(z4, nz(_beSeed), _bearColor, mitActionOB)
                array.push(_bearOB, z4)
                f_trimZones(_bearOB, mtfMaxBoxes)

        if showMTF_FVG
            f_stepAll(_bullFVG, _bullColor, _bullColor, 'FVG+ [' + _tfLabel + ']', false, mitActionFVG, time, true, false)
            f_stepAll(_bearFVG, _bearColor, _bearColor, 'FVG- [' + _tfLabel + ']', false, mitActionFVG, time, true, false)
        if showMTF_OB
            f_stepAll(_bullOB, _bullColor, obBullBreakCol, 'BB- [' + _tfLabel + ']', obShowBreak, mitActionOB, time, true, false)
            f_stepAll(_bearOB, _bearColor, obBearBreakCol, 'BB+ [' + _tfLabel + ']', obShowBreak, mitActionOB, time, true, false)
    true

f_processMTF(tf1, tf1Enable, tf1Valid, tf1BullColor, tf1BearColor, tf1_newBar, tf1_t3, tf1_buNew, tf1_buTop, tf1_buBtm, tf1_buLeft, tf1_buSeed, tf1_beNew, tf1_beTop, tf1_beBtm, tf1_beLeft, tf1_beSeed, tf1_fvgUp, tf1_fvgDown, tf1_l1, tf1_h3, tf1_l3, tf1_h1, mtfBullFVG1, mtfBearFVG1, mtfBullOB1, mtfBearOB1)
f_processMTF(tf2, tf2Enable, tf2Valid, tf2BullColor, tf2BearColor, tf2_newBar, tf2_t3, tf2_buNew, tf2_buTop, tf2_buBtm, tf2_buLeft, tf2_buSeed, tf2_beNew, tf2_beTop, tf2_beBtm, tf2_beLeft, tf2_beSeed, tf2_fvgUp, tf2_fvgDown, tf2_l1, tf2_h3, tf2_l3, tf2_h1, mtfBullFVG2, mtfBearFVG2, mtfBullOB2, mtfBearOB2)
f_processMTF(tf3, tf3Enable, tf3Valid, tf3BullColor, tf3BearColor, tf3_newBar, tf3_t3, tf3_buNew, tf3_buTop, tf3_buBtm, tf3_buLeft, tf3_buSeed, tf3_beNew, tf3_beTop, tf3_beBtm, tf3_beLeft, tf3_beSeed, tf3_fvgUp, tf3_fvgDown, tf3_l1, tf3_h3, tf3_l3, tf3_h1, mtfBullFVG3, mtfBearFVG3, mtfBullOB3, mtfBearOB3)
f_processMTF(tf4, tf4Enable, tf4Valid, tf4BullColor, tf4BearColor, tf4_newBar, tf4_t3, tf4_buNew, tf4_buTop, tf4_buBtm, tf4_buLeft, tf4_buSeed, tf4_beNew, tf4_beTop, tf4_beBtm, tf4_beLeft, tf4_beSeed, tf4_fvgUp, tf4_fvgDown, tf4_l1, tf4_h3, tf4_l3, tf4_h1, mtfBullFVG4, mtfBearFVG4, mtfBullOB4, mtfBearOB4)
f_processMTF(tf5, tf5Enable, tf5Valid, tf5BullColor, tf5BearColor, tf5_newBar, tf5_t3, tf5_buNew, tf5_buTop, tf5_buBtm, tf5_buLeft, tf5_buSeed, tf5_beNew, tf5_beTop, tf5_beBtm, tf5_beLeft, tf5_beSeed, tf5_fvgUp, tf5_fvgDown, tf5_l1, tf5_h3, tf5_l3, tf5_h1, mtfBullFVG5, mtfBearFVG5, mtfBullOB5, mtfBearOB5)

// ═══════════════════════════════════════════════════════════════════════════════════════
// 26 · ALERTS
// ═══════════════════════════════════════════════════════════════════════════════════════

alertcondition(barstate.isconfirmed and isFvgUp(0), title = 'FVG+', message = 'FVG+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isFvgDown(0), title = 'FVG-', message = 'FVG- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isBuIFvg(0), title = 'Implied.FVG+', message = 'I.FVG+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isBeIFvg(0), title = 'Implied.FVG-', message = 'I.FVG- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and ((isBuVItype1(0) or isBuVItype2(0) or isBuVItype3(0)) and advancedvi or isBuVItype1(0) and classicvi), title = 'VI+', message = 'VI+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
// Fix versus the original: the last term of this condition read isBuVItype1, so in Classic mode
// the bearish alert fired on bullish volume imbalances.
alertcondition(barstate.isconfirmed and ((isBeVItype1(0) or isBeVItype2(0) or isBeVItype3(0)) and advancedvi or isBeVItype1(0) and classicvi), title = 'VI-', message = 'VI- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and high[1] < low, title = 'GAP+', message = 'GAP+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and low[1] > high, title = 'GAP-', message = 'GAP- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isbuinversefvg, title = 'Inverse.FVG+', message = 'Inverse.FVG+ : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and isbeinversefvg, title = 'Inverse.FVG-', message = 'Inverse.FVG- : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and bulv, title = 'LV+', message = 'Bullish Liquidity Void : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and belv, title = 'LV-', message = 'Bearish Liquidity Void : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')

alertcondition(bugaptouch, title = 'GAP(+) Mitigation', message = 'GAP(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(begaptouch, title = 'GAP(-) Mitigation', message = 'GAP(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(buimpfvgtouch, title = 'Implied.FVG(+) Mitigation', message = 'Implied.FVG(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(beimpfvgtouch, title = 'Implied.FVG(-) Mitigation', message = 'Implied.FVG(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(bufvgtouch, title = 'FVG(+) Mitigation', message = 'FVG(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(befvgtouch, title = 'FVG(-) Mitigation', message = 'FVG(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(buvitouch, title = 'VI(+) Mitigation', message = 'VI(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(bevitouch, title = 'VI(-) Mitigation', message = 'VI(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(buinvfvgtouch, title = 'Inverse.FVG(+) Mitigation', message = 'Inverse.FVG(+) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(beinvfvgtouch, title = 'Inverse.FVG(-) Mitigation', message = 'Inverse.FVG(-) Mitigated :{{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')

alertcondition(barstate.isconfirmed and obNewBull, title = 'OB+', message = 'Bullish Order Block : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
alertcondition(barstate.isconfirmed and obNewBear, title = 'OB-', message = 'Bearish Order Block : {{exchange}}:{{ticker}} TIMEFRAME:{{interval}}')
// end of script
````
