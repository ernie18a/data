# Liquidity Ladder+ (M1D)

- url: https://www.tradingview.com/script/jsGHNXN5-Liquidity-Ladder-M1D/
- type: indicator
- pine_id: PUB;7dd31e7b9f674e439e37bce908747892
- version: 5.0

## Description

[b]OVERVIEW[/b]

MTF Liquidity Ladder maps where resting orders sit above and below price, read from six timeframes at once — 1H, 4H, 7H, 1D, 3D and 1W — and draws only the closest few from each. Nothing else goes on the chart.

A level here is a SWING: a candle whose high dominated the candles either side of it on its own timeframe. That high is where buy stops rest, so it is buyside liquidity (BSL). A swing low is where sell stops rest, so it is sellside liquidity (SSL). A level comes off the chart the moment price trades through it, because liquidity that has been taken is not liquidity any more.

Every line is black and solid, because a pool carries no direction — it is neither bullish nor bearish, it is simply somewhere price may go to fill orders, and colouring it would imply a bias the level does not hold. Weight is the only ranking: the weekly is the widest line on the chart and the hourly the thinnest, so you know which timeframe a level belongs to before you have read its name.

Everything is evaluated on bar close. Confirmed levels do not repaint.

[b]WHAT IT PLOTS[/b]

[list=1]
[*][b]Swing levels from six timeframes.[/b] Buyside (swing highs) above price and sellside (swing lows) below it, for 1H, 4H, 7H, 1D, 3D and 1W. Each timeframe has its own on/off switch, its own line weight and its own right-hand runway.
[*][b]Only the closest 1-10 per timeframe, per side.[/b] A pool forty handles away is not a decision you are about to make, and it costs exactly as much ink as the one you are. The default is two per timeframe per side. Levels further out stay tracked and appear the moment a nearer one is taken.
[*][b]One label per level, at the right end of its own line.[/b] The name sits level with the price, no box behind it, in monospace. The line's right edge and the label's x are the same number used twice, so a name can never end up somewhere its line is not.
[*][b]Six label columns.[/b] Each timeframe stops at its own distance past the live candle — by default 4, 7, 10, 15, 17 and 20 bars from 1H up to 1W — and parks its name there. The families land in six columns instead of contesting one patch of screen, and the column itself tells you the rank.
[*][b]Dates on daily and above, prices on 4H and above.[/b] A daily or weekly level is worth dating, because which day made it changes what it means: the label reads 1D 19/07. An hourly level carries the tag alone. From 4H up, the label also carries the price, since a pool that size is one you plan around.
[/list]

[b]WHAT SEPARATES IT FROM A PREVIOUS-HIGH / PREVIOUS-LOW SCRIPT[/b]

[list=1]
[*][b]Levels that share a price become ONE level.[/b] Two swings resting within a few ticks of each other are one pool, not two. Drawn separately they produce two lines at the same height and two names fighting for the same space. Here they merge into a single line in the senior timeframe's column, at its weight, carrying every tag that sits there — 4H·1H. A candidate is tested against the whole group's envelope rather than just its first member, so a chain of near-misses cannot walk a group away from where it started. Never two names for one price, and never a name nudged off the level it belongs to.
[*][b]Lines anchor to the exact bar that made the swing.[/b] A higher-timeframe pivot only knows which CANDLE made it. Anchor the line at that candle's open and a 4H level begins up to four hours to the left of the high it is named after — visibly adrift from the swing it describes. This script follows each timeframe's candle as it forms, records the exact chart bar its high and its low printed on, and anchors there instead. The date in the label names that same bar. A level older than the chart's loaded history has no bar to anchor to; it falls back to the candle's open, and its origin is off the left edge regardless.
[*][b]A distance gate, because lines pull the price scale.[/b] A weekly pool six hundred points away on a one-minute chart does not sit quietly off-screen. The pane stretches to include it and every candle you were actually reading is flattened into a band. With six timeframes drawing at once that is a chart you cannot trade from. So nothing draws further from price than a multiple of the recent range — the last 300 bars, high to low, which tracks the instrument and the chart timeframe on its own. It gates DRAWING only: the level stays tracked, stays swept, stays alerted, and reappears as soon as price comes back within reach.
[/list]

[b]SETTINGS[/b]

[b]Timeframes[/b]
[list]
[*]One row per timeframe: draw it, how many bars past the live candle it runs, and how heavy its line is. Defaults 1H 4/1, 4H 7/1, 7H 10/1, 1D 15/2, 3D 17/2, 1W 20/3.
[*]The weekly is always the heaviest line and never thinner than 2. If another timeframe is set wider, the weekly is lifted to match rather than the other being cut — no setting is discarded, but the hierarchy holds.
[*]A timeframe hides itself when the chart timeframe reaches or passes it. A 1H level on a 4H chart is not a level, it is the bar you are standing on.
[/list]

[b]Levels[/b]
[list]
[*]Levels per timeframe: 1-10, default 2.
[*]Buyside and Sellside toggles, both on.
[*]Swing strength — bars either side a candle must dominate to count as a swing, default 3.
[*]Merge tolerance in ticks, default 4. Zero merges only prices that match exactly.
[*]Distance gate, as a multiple of the recent range, default 1.5. Zero switches it off.
[/list]

[b]Labels[/b]
[list]
[*]Text size, default small.
[*]Date on 1D, 3D and 1W labels, on.
[*]The words BSL and SSL, off by default — a level above price is Buyside and one below is Sellside, so the words repeat what the chart already says.
[*]Price: Off, 4H and above (default), or Every level.
[/list]

[b]Alerts[/b]
[list]
[*]Announce a sweep from this timeframe up, default 4H.
[/list]

[b]ALERTS[/b]

Sweeps below the chosen floor stay silent. A 1H pool gets tickled all session, and an alert on every one is an alert you stop reading.

[list]
[*]A dynamic alert, at most one per bar, naming the most senior pool taken and the price it went at — for example: 4H BSL taken · 29750.00 · MNQ1!. To use it, choose "Any alert() function call" in the alert dialog.
[*]Two fixed conditions, BSL taken and SSL taken, for anyone who prefers a plain trigger. Both respect the same floor.
[/list]

[b]NOTES[/b]

[list]
[*]Dates are read in New York time on every instrument. An exchange's own timezone would date a CME swing in Chicago, putting a late-evening level on a different day to the rest of a New-York-based workflow.
[*]Toggles and the distance gate affect drawing only. Detection keeps running underneath, so tidying the chart never quietly loses the analysis behind it.
[*]Line and label objects are created once and reused rather than deleted and rebuilt each bar, so the chart does not flicker as price moves between levels.
[*]Six request.security() calls, one per timeframe, all with lookahead off.
[/list]

[b]Disclaimer[/b]

This is an analysis tool. It marks where liquidity rests and when it is taken; it does not generate entries, exits or signals, and it makes no claim about what price will do next.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy
// ═══════════════════════════════════════════════════════════════════════════
//  MTF Liquidity Ladder (M1D)
//  ─────────────────────────────────────────────────────────────────────────
//  The nearest untaken buyside and sellside liquidity, read from six
//  timeframes at once — 1H, 4H, 7H, 1D, 3D, 1W — plus the session and
//  previous-day extremes, drawn as bare black lines.
//
//  A level here is a SWING: a candle whose high dominated the candles either
//  side of it on its own timeframe. That high is where buy stops rest (BSL);
//  a swing low is where sell stops rest (SSL). A level comes OFF the chart
//  the moment price trades through it, because liquidity that has been taken
//  is not liquidity any more.
//
//  Features
//    · Six timeframes, each with its own on/off, line weight and right-hand
//      runway. Only the CLOSEST 1–10 live levels per timeframe per side are
//      drawn.
//    · Session pools — Asia, London KZ and NY AM KZ highs and lows — and the
//      previous day's high and low, filed into the SAME ladder as the swings.
//      A session high resting on a swing high is one pool, not two.
//    · Every line black and solid. A pool carries no direction, so WEIGHT is
//      the only ranking: the weekly is the widest line on the chart.
//    · One label column per family. Levels resting at one price MERGE into a
//      single line and a single name in the senior family's column —
//      1D·PDH·Asia. Never two names for one price.
//    · Lines anchor to the MINUTE the extreme printed.
//    · A distance gate keeps far levels from stretching the price scale. It
//      gates drawing, never detection.
//    · Optional record of taken pools as dotted lines ending at the sweep.
//    · Alerts on a sweep and on a new pool, with a seniority floor.
//
//  Everything is evaluated on bar close. Confirmed levels do not repaint.
// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator('Liquidity Ladder+ (M1D)', 'MTF Liquidity (M1D)',
     overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// == ORIGIN GUARD ==
// A drawing anchored on a stored origin can sit thousands of chart bars back. Placing that x walks the
// `time` series to it, and Pine auto-sizes that buffer from what history happened to need, so a live bar
// that needs one more kills the whole script ("requested historical offset is beyond the historical
// buffer's limit"). Function form buffers `time` alone; anything older than ORIGIN_MAX clamps to the
// buffer's edge and draws short from the left instead of crashing.
const int ORIGIN_MAX = 4900
max_bars_back(time, 5000)
//@function Clamps a bar-time anchor to the oldest bar the drawing engine can still place.
//@param t (int) The stored origin time.
//@returns (int) t, or the time of the oldest reachable bar when t is older than that.
f_xClamp(int t) =>
    math.max(t, time[math.min(bar_index, ORIGIN_MAX)])


// == CONSTANTS ================================================================

const color INK = #000000

//@variable The same ink at full transparency. Two jobs: the callout body behind every label, which
// must never show a background, and parking a pool slot this bar did not need.
const color HIDDEN = color.new(INK, 100)

//@variable Number of TIMEFRAME families. Index order: 0 = 1H, 1 = 4H, 2 = 7H, 3 = 1D, 4 = 3D, 5 = 1W.
const int TF_COUNT = 6

//@variable Every family the ladder files: the six timeframes, then 6 = Asia, 7 = London KZ,
// 8 = NY AM KZ, 9 = previous day.
const int FAM_COUNT = 10
const int FAM_ASIA  = 6
const int FAM_LON   = 7
const int FAM_NYAM  = 8
const int FAM_PD    = 9

//@variable Session windows are read in NEW YORK time on every instrument — ICT's kill zones are
// defined on New York's clock, whatever is being traded.
const string TZ = 'America/New_York'

//@variable Index of the first DAILY-or-higher timeframe family. These are the ones that carry a date.
const int FIRST_DATED = 3

//@variable Live levels retained per timeframe per side before the oldest is dropped. Comfortably
// more than the ten a user can draw, so "closest" always has a real field to choose from.
const int POOL_KEEP = 20

//@variable Session pools stop drawing above this chart timeframe. On a 1H chart a three-hour kill
// zone is three candles and its "high" is just a candle high.
const int SESS_MAX_SEC = 1800

// == INPUTS ===================================================================

const string G_TF  = 'Timeframes'
const string G_SES = 'Sessions & previous day'
const string G_LVL = 'Levels'
const string G_LBL = 'Labels'
const string G_ALR = 'Alerts'

// Each row: draw this family · how many bars past the live candle it stops · how heavy the line is.
bool show1H = input.bool(true, '1H', group = G_TF, inline = 'r1')
int  ext1H  = input.int(10, 'runs', minval = 0, maxval = 200, group = G_TF, inline = 'r1')
int  wid1H  = input.int(1,  'width', minval = 1, maxval = 3, group = G_TF, inline = 'r1')

bool show4H = input.bool(true, '4H', group = G_TF, inline = 'r2')
int  ext4H  = input.int(17, 'runs', minval = 0, maxval = 200, group = G_TF, inline = 'r2')
int  wid4H  = input.int(1,  'width', minval = 1, maxval = 3, group = G_TF, inline = 'r2')

bool show7H = input.bool(true, '7H', group = G_TF, inline = 'r3')
int  ext7H  = input.int(24, 'runs', minval = 0, maxval = 200, group = G_TF, inline = 'r3')
int  wid7H  = input.int(1,  'width', minval = 1, maxval = 3, group = G_TF, inline = 'r3')

bool show1D = input.bool(true, '1D', group = G_TF, inline = 'r4')
int  ext1D  = input.int(31, 'runs', minval = 0, maxval = 200, group = G_TF, inline = 'r4')
int  wid1D  = input.int(2,  'width', minval = 1, maxval = 3, group = G_TF, inline = 'r4')

bool show3D = input.bool(true, '3D', group = G_TF, inline = 'r5')
int  ext3D  = input.int(38, 'runs', minval = 0, maxval = 200, group = G_TF, inline = 'r5')
int  wid3D  = input.int(2,  'width', minval = 1, maxval = 3, group = G_TF, inline = 'r5')

bool show1W = input.bool(true, '1W', group = G_TF, inline = 'r6')
int  ext1W  = input.int(45, 'runs', minval = 0, maxval = 200, group = G_TF, inline = 'r6')
int  wid1W  = input.int(3,  'width', minval = 1, maxval = 3, group = G_TF, inline = 'r6',
     tooltip = 'The weekly is always the heaviest line on the chart and never thinner than 2. If another family is set wider, the weekly is lifted to match rather than the other being cut, so the hierarchy holds.')

bool showSess = input.bool(true, 'Sessions', group = G_SES, inline = 's1')
int  extSess  = input.int(10, 'runs', minval = 0, maxval = 200, group = G_SES, inline = 's1')
int  widSess  = input.int(1,  'width', minval = 1, maxval = 3, group = G_SES, inline = 's1',
     tooltip = 'The high and low of the most recent Asia, London KZ and NY AM KZ window, each as one line. A window\'s pools are replaced when that window next closes, or removed when price takes them. Drawn on charts of 30 minutes and below.')
string asiaSess = input.session('2000-0000', 'Asia', group = G_SES, active = showSess,
     tooltip = 'New York time.')
string lonSess  = input.session('0200-0500', 'London KZ', group = G_SES, active = showSess,
     tooltip = 'New York time.')
string nyamSess = input.session('0830-1100', 'NY AM KZ', group = G_SES, active = showSess,
     tooltip = 'New York time.')

bool showPD = input.bool(true, 'PDH / PDL', group = G_SES, inline = 's2')
int  extPD  = input.int(31, 'runs', minval = 0, maxval = 200, group = G_SES, inline = 's2')
int  widPD  = input.int(2,  'width', minval = 1, maxval = 3, group = G_SES, inline = 's2',
     tooltip = 'The previous daily candle\'s high and low — the same daily candle the 1D timeframe reads, so on futures the day opens with the evening session. Replaced at every new day.')

int nPerTf = input.int(2, 'Levels per timeframe', minval = 1, maxval = 10, group = G_LVL,
     tooltip = 'How many of the CLOSEST live levels each timeframe draws, per side. Two is a ladder readable at a glance; ten is the full field, meant for study rather than execution.')
bool showBsl = input.bool(true, 'Buyside · BSL — highs above price', group = G_LVL)
bool showSsl = input.bool(true, 'Sellside · SSL — lows below price', group = G_LVL)
int swingLen = input.int(3, 'Swing strength (bars)', minval = 1, maxval = 20, group = G_LVL,
     tooltip = 'Bars either side a candle must dominate to count as a swing on its own timeframe. Larger finds fewer, more significant pools. Three is a genuine short-term high on any timeframe without leaving a 1H chart empty.')
int mergeTicks = input.int(4, 'Merge levels within (ticks)', minval = 0, maxval = 200, group = G_LVL,
     tooltip = 'Pools resting this close together are ONE pool, with ONE line and ONE name — the senior family\'s column, every tag on it (1D·PDH·Asia). Measured in ticks so it scales with the instrument: 4 ticks is a point on MNQ. Zero merges only prices that match exactly.')
float gateMult = input.float(1.5, 'Hide levels beyond (× recent range)', minval = 0.0, maxval = 20.0, step = 0.25, group = G_LVL,
     tooltip = 'Lines pull the price scale. A weekly pool six hundred points away on a one-minute chart squashes every candle into a band.\n\nSo nothing is drawn further from price than this many multiples of the recent range — the last 300 bars, high to low, which tracks both the instrument and the chart timeframe. It gates DRAWING only: the level stays tracked and reappears the moment price comes back to it. Zero turns the gate off.')
int keepTaken = input.int(0, 'Keep taken pools (dotted)', minval = 0, maxval = 20, group = G_LVL,
     tooltip = 'The most recent pools price has taken, left on the chart as dotted lines from where they formed to the candle that took them, with no name. Zero removes a pool the moment it is taken.')

string labelSize = input.string('small', 'Label text size',
     options = ['tiny', 'small', 'normal', 'large'], group = G_LBL)
bool showDates = input.bool(true, 'Date on 1D · 3D · 1W labels', group = G_LBL,
     tooltip = 'The day the swing candle printed, as dd/MM — 19/07. A daily or weekly level is worth dating because which week made it changes what it means. An hourly one is not.')
bool showSide = input.bool(false, 'BSL / SSL in the label', group = G_LBL,
     tooltip = 'Off by default: a level above price IS buyside and one below IS sellside, so the words repeat what the chart already says.')
string priceMode = input.string('4H and above', 'Price in the label',
     options = ['Off', '4H and above', 'Every level'], group = G_LBL,
     tooltip = 'A 4H pool or bigger is a level to plan around, so it carries its number, and so does PDH / PDL. A 1H or session pool is read off the chart in the moment. Every level puts the number on all of them.')

string alertFrom = input.string('4H', 'Alert from this rank up',
     options = ['1H', '4H', '7H', '1D', '3D', '1W', 'Off'], group = G_ALR,
     tooltip = 'Pools below this rank stay silent, both when they are taken and when they form. Session pools rank between 1H and 4H; PDH / PDL rank with 1D. A 1H pool gets tickled all session and an alert on every one stops being read.')

// == STYLE RESOLUTION =========================================================

//@function Resolves the label-size input to its size constant.
//@param s (string) one of tiny · small · normal · large
//@returns (string) the matching size.* constant
f_lblSize(string s) =>
    switch s
        'tiny'  => size.tiny
        'small' => size.small
        'large' => size.large
        =>         size.normal

//@variable One resolved size, driving every label on the chart.
string LBL_SZ = f_lblSize(labelSize)

//@variable How far apart two pools may rest and still count as the same pool, in price.
float mergeTol = mergeTicks * syminfo.mintick

//@variable Bars behind the live candle that define "the recent range" for the distance gate.
const int GATE_LEN = 300

//@variable High-to-low of the recent range. The gate is a multiple of this rather than a fixed
// number of points, so one setting behaves the same on MNQ, gold and BTC, and on every timeframe.
float recentRange = ta.highest(high, GATE_LEN) - ta.lowest(low, GATE_LEN)

//@variable Whether the distance gate is doing anything. Off on a chart too short to have a range.
bool gateOn = gateMult > 0 and recentRange > 0

//@function Seniority of a family. Decides whose column a merged pool parks in, the tag order, and
// the alert floor. Sessions sit between 1H and 4H; the previous day ranks with 1D.
//@param t (int) family index 0-9
//@returns (int) rank, higher is more senior
f_rank(int t) =>
    switch t
        0 => 10
        1 => 20
        2 => 30
        3 => 40
        4 => 50
        5 => 60
        9 => 40
        =>   15

//@function The lowest rank whose pools are worth an alert.
//@param s (string) the chosen family name, or Off
//@returns (int) a rank, or 999 for never
f_alertRank(string s) =>
    switch s
        '1H' => 10
        '4H' => 20
        '7H' => 30
        '1D' => 40
        '3D' => 50
        '1W' => 60
        =>      999

//@variable Pools from this rank up are announced; quieter ones are ignored.
int ALERT_RANK = f_alertRank(alertFrom)

//@function Whether a family's label carries its price.
//@param t (int) family index 0-9
//@returns (bool) true if the number goes in the label
f_wantsPrice(int t) =>
    switch priceMode
        'Every level'  => true
        '4H and above' => f_rank(t) >= 20
        =>                false

// The weekly outranks everything. Lift it to whatever the widest junior asks for, and never let it
// sit below 2 — a weekly pool that reads the same weight as an hourly one has lost the only signal
// this script uses to rank the families.
int widJunior = math.max(wid1H, math.max(wid4H, math.max(wid7H, math.max(wid1D, math.max(wid3D, math.max(widSess, widPD))))))
int WID_1W    = math.max(wid1W, math.max(widJunior, 2))

// Every timeframe is measured ONCE, here, from a literal string. timeframe.in_seconds() requires a
// SIMPLE string: a value returned from a switch on a loop counter is a SERIES string and will not
// compile, so the six are resolved up front and compared as plain integers thereafter.
int SEC_1H = timeframe.in_seconds('60')
int SEC_4H = timeframe.in_seconds('240')
int SEC_7H = timeframe.in_seconds('420')
int SEC_1D = timeframe.in_seconds('D')
int SEC_3D = timeframe.in_seconds('3D')
int SEC_1W = timeframe.in_seconds('W')
int SEC_CH = timeframe.in_seconds(timeframe.period)

//@variable Milliseconds in one chart bar. Right-hand runways are measured in bar TIME, never bar
// index — an index coordinate is rejected past roughly ten thousand bars from the live candle, and
// a weekly level can easily be older than that.
int msPerBar = SEC_CH * 1000

//@function The short tag that names a family in its label.
//@param t     (int) family index 0-9
//@param isBuy (bool) side — only the previous day's tag depends on it
//@returns (string) the tag
f_tag(int t, bool isBuy) =>
    switch t
        0 => '1H'
        1 => '4H'
        2 => '7H'
        3 => '1D'
        4 => '3D'
        5 => '1W'
        6 => 'Asia'
        7 => 'London KZ'
        8 => 'NY AM KZ'
        =>   isBuy ? 'PDH' : 'PDL'

//@variable Families in tag order, most senior first. 1D stands before PDH so a merged pool reads
// 1D·PDH, matching the column it parks in.
var array<int> TAG_ORDER = array.from(5, 4, 3, 9, 2, 1, 8, 7, 6, 0)

//@function Builds the M1D alerts-relay JSON payload from the script's own runtime values —
// same field shape the relay already accepts from Session Zones+ and 2022 Model+.
//@param eventName (string) the event slug, e.g. "htf_liquidity_ssl_taken"
//@param price     (float)  the price the pool went at
//@param poolTag   (string) which family swept, e.g. "1H" or "PDH"
//@returns (string) the JSON payload
f_alertJson(string eventName, float price, string poolTag) =>
    '{"event":"' + eventName + '","symbol":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","price":"' + str.tostring(price, format.mintick) + '","time":"' + str.tostring(time) + '","note":"' + poolTag + ' pool swept — not a trade signal"}'

//@function Bars past the live candle this family's lines stop at — and where its names park.
//@param t (int) family index 0-9
//@returns (int) bar count
f_ext(int t) =>
    switch t
        0 => ext1H
        1 => ext4H
        2 => ext7H
        3 => ext1D
        4 => ext3D
        5 => ext1W
        9 => extPD
        =>   extSess

//@function Line weight for a family, with the weekly's rank already enforced.
//@param t (int) family index 0-9
//@returns (int) line width 1-3
f_wid(int t) =>
    switch t
        0 => wid1H
        1 => wid4H
        2 => wid7H
        3 => wid1D
        4 => wid3D
        5 => WID_1W
        9 => widPD
        =>   widSess

//@function Whether this family is switched on.
//@param t (int) family index 0-9
//@returns (bool) true if it should draw
f_on(int t) =>
    switch t
        0 => show1H
        1 => show4H
        2 => show7H
        3 => show1D
        4 => show3D
        5 => show1W
        9 => showPD
        =>   showSess

//@function Whether the chart has outgrown this family. A 1H level on a 4H chart is not a level,
// it is the bar being stood on.
//@param t (int) family index 0-9
//@returns (bool) true if the family must stay hidden
f_outgrown(int t) =>
    bool out = false
    if t >= FAM_ASIA and t <= FAM_NYAM
        out := SEC_CH > SESS_MAX_SEC
    else
        int secs = switch t
            0 => SEC_1H
            1 => SEC_4H
            2 => SEC_7H
            4 => SEC_3D
            5 => SEC_1W
            =>   SEC_1D
        out := SEC_CH >= secs
    out

//@function Live pools a family keeps per side. Timeframes keep a field to choose the closest from;
// a session or the previous day is one high and one low by definition.
//@param t (int) family index 0-9
//@returns (int) the cap
f_keep(int t) =>
    t < TF_COUNT ? POOL_KEEP : 1

// == TYPES ====================================================================

//@type One resting pool of liquidity.
//@field price The extreme itself — the level orders sit at.
//@field born  Bar TIME of the candle that formed it. The anchor, and the date in the label.
//@field tf    Family index 0-9.
//@field buy   True for a high (BSL), false for a low (SSL).
//@field taken Bar TIME of the candle that took it; 0 while it is live.
type Level
    float price = na
    int   born  = 0
    int   tf    = 0
    bool  buy   = true
    int   taken = 0

// == HIGHER-TIMEFRAME SWINGS ==================================================

//@function The latest confirmed swing high and swing low on one timeframe, each with the bar time
// of the candle that made it. One request per family — six in the whole script.
//@param tf  (simple string) the timeframe to read
//@param len (simple int) bars either side a candle must dominate
//@returns [float highPrice, int highTime, float lowPrice, int lowTime]
f_swings(simple string tf, simple int len) =>
    request.security(syminfo.tickerid, tf,
         [ta.pivothigh(high, len, len), time[len], ta.pivotlow(low, len, len), time[len]],
         lookahead = barmerge.lookahead_off)

[ph1H, pht1H, pl1H, plt1H] = f_swings('60',  swingLen)
[ph4H, pht4H, pl4H, plt4H] = f_swings('240', swingLen)
[ph7H, pht7H, pl7H, plt7H] = f_swings('420', swingLen)
[ph1D, pht1D, pl1D, plt1D] = f_swings('D',   swingLen)
[ph3D, pht3D, pl3D, plt3D] = f_swings('3D',  swingLen)
[ph1W, pht1W, pl1W, plt1W] = f_swings('W',   swingLen)

// == EXACT ORIGIN ============================================================

// A higher-timeframe pivot only knows which HTF CANDLE made it. Anchoring the line at that candle's
// OPEN drops it up to a whole timeframe left of the swing it names. So each family's candle is
// followed as it forms and the exact chart bar of its high and its low is recorded. The pivot is
// then anchored to THAT minute.
//
// time(tf) is a plain built-in, not a request — it buckets chart bars by higher-timeframe candle
// without spending one of the six security calls.

//@variable Completed HTF candles per family that keep their exact extreme times. Must exceed the
// swing strength, since a pivot is only confirmed that many candles after it formed.
const int RING = 40

var array<int>   curOpen  = array.new<int>(TF_COUNT, 0)
var array<float> curHi    = array.new<float>(TF_COUNT, na)
var array<int>   curHiT   = array.new<int>(TF_COUNT, 0)
var array<float> curLo    = array.new<float>(TF_COUNT, na)
var array<int>   curLoT   = array.new<int>(TF_COUNT, 0)
var array<int>   ringPos  = array.new<int>(TF_COUNT, 0)
var array<int>   ringOpen = array.new<int>(TF_COUNT * RING, 0)
var array<int>   ringHiT  = array.new<int>(TF_COUNT * RING, 0)
var array<int>   ringLoT  = array.new<int>(TF_COUNT * RING, 0)

int htfOpen1H = nz(time('60'))
int htfOpen4H = nz(time('240'))
int htfOpen7H = nz(time('420'))
int htfOpen1D = nz(time('D'))
int htfOpen3D = nz(time('3D'))
int htfOpen1W = nz(time('W'))

//@function Follows one family's HTF candle as it forms, remembering the exact chart bar its high
// and its low printed on, and archiving both when the candle rolls over.
//@param t       (int) family index 0-5
//@param htfOpen (int) open time of the HTF candle this chart bar belongs to
//@returns (void)
f_track(int t, int htfOpen) =>
    if htfOpen != curOpen.get(t)
        if curOpen.get(t) > 0
            int p = ringPos.get(t)
            ringOpen.set(t * RING + p, curOpen.get(t))
            ringHiT.set(t * RING + p, curHiT.get(t))
            ringLoT.set(t * RING + p, curLoT.get(t))
            ringPos.set(t, (p + 1) % RING)
        curOpen.set(t, htfOpen)
        curHi.set(t, high)
        curHiT.set(t, time)
        curLo.set(t, low)
        curLoT.set(t, time)
    else
        if high > curHi.get(t)
            curHi.set(t, high)
            curHiT.set(t, time)
        if low < curLo.get(t)
            curLo.set(t, low)
            curLoT.set(t, time)

//@function The exact chart bar an HTF candle's extreme printed on.
//@param t       (int) family index 0-5
//@param htfOpen (int) open time of the candle that made the swing
//@param isBuy   (bool) true for its high, false for its low
//@returns (int) that bar's time, or the candle's open when the chart never loaded it
f_exact(int t, int htfOpen, bool isBuy) =>
    int found = 0
    for r = 0 to RING - 1
        if ringOpen.get(t * RING + r) == htfOpen
            found := isBuy ? ringHiT.get(t * RING + r) : ringLoT.get(t * RING + r)
    // A level older than the chart's loaded history has no minute to plot to. Its origin is off the
    // left edge anyway, so the candle's open is the honest best available rather than a guess.
    found > 0 ? found : htfOpen

// == SESSION WINDOWS ==========================================================

// Each window's high and low are followed bar by bar at chart scope, so the exact minute of each
// extreme is known without a request. Index 0 = Asia, 1 = London KZ, 2 = NY AM KZ.
var array<float> sesHi  = array.new<float>(3, na)
var array<int>   sesHiT = array.new<int>(3, 0)
var array<float> sesLo  = array.new<float>(3, na)
var array<int>   sesLoT = array.new<int>(3, 0)
var array<bool>  sesWas = array.new<bool>(3, false)

bool inAsia = not na(time(timeframe.period, asiaSess, TZ))
bool inLon  = not na(time(timeframe.period, lonSess, TZ))
bool inNyam = not na(time(timeframe.period, nyamSess, TZ))

// == LEVEL STORE ==============================================================

//@variable Every live, untaken pool across all families, oldest first.
var array<Level> store = array.new<Level>(0)

//@variable The most recent taken pools, oldest first, capped at the keep input.
var array<Level> spent = array.new<Level>(0)

//@variable The bar time of the last swing filed per timeframe per side, so one confirmed pivot is
// filed once rather than on every chart bar it is visible from. Key = tf * 2 + (buy ? 0 : 1).
var array<int> lastSeen = array.new<int>(TF_COUNT * 2, 0)

//@function Drops the oldest pool in one family/side bucket once the bucket is over its cap.
//@param t     (int) family index
//@param isBuy (bool) side
//@returns (void)
f_prune(int t, bool isBuy) =>
    int held = 0
    int cut  = -1
    // Walk BACKWARDS. The store is chronological, so the last index this pass writes to cut is the
    // lowest matching one — the oldest pool in the bucket.
    if store.size() > 0
        for i = store.size() - 1 to 0
            Level lv = store.get(i)
            if lv.tf == t and lv.buy == isBuy
                held += 1
                cut  := i
    if held > f_keep(t) and cut >= 0
        store.remove(cut)

//@function Removes every live pool of one family. A session or a day is replaced whole when the
// next one closes, whether or not the new extremes survive to be filed — otherwise a window whose
// new high was taken on its closing bar would leave the previous window's high wearing its name.
//@param t (int) family index
//@returns (void)
f_clearFam(int t) =>
    if store.size() > 0
        for i = store.size() - 1 to 0
            if store.get(i).tf == t
                store.remove(i)

//@function Adds a pool to the store and trims its bucket. A pool the current bar has already
// traded through is never filed — it was taken before it could rest.
//@param t     (int) family index
//@param px    (float) the extreme
//@param born  (int) bar time of the candle that made it
//@param isBuy (bool) true for a high
//@returns (bool) true when this is a NEW price worth announcing — not one merging into a pool that
// already rests there, and not below the alert floor
f_add(int t, float px, int born, bool isBuy) =>
    bool fresh = false
    if not na(px) and born > 0 and not (isBuy ? high > px : low < px)
        bool twin = false
        if store.size() > 0
            for i = 0 to store.size() - 1
                Level lv = store.get(i)
                if lv.buy == isBuy and math.abs(lv.price - px) <= mergeTol
                    twin := true
        store.push(Level.new(px, born, t, isBuy, 0))
        f_prune(t, isBuy)
        fresh := not twin and f_rank(t) >= ALERT_RANK
    fresh

//@function Files a newly confirmed swing, once. The HTF candle's open time identifies the swing,
// but the EXACT chart bar its extreme printed on is what gets stored.
//@param t     (int) timeframe family index 0-5
//@param px    (float) the swing extreme, na on bars where none confirmed
//@param htfT  (int) open time of the HTF candle that made it
//@param isBuy (bool) true for a swing high
//@returns (bool) true when a new pool worth announcing was filed
f_file(int t, float px, int htfT, bool isBuy) =>
    bool fresh = false
    int key = t * 2 + (isBuy ? 0 : 1)
    if not na(px) and htfT > 0 and htfT != lastSeen.get(key)
        lastSeen.set(key, htfT)
        fresh := f_add(t, px, f_exact(t, htfT, isBuy), isBuy)
    fresh

//@function Follows one session window and files its high and low on the first bar after it closes.
//@param s      (int) window index 0-2
//@param inside (bool) this bar sits inside the window
//@returns [bool newHigh, bool newLow] whether each filed as a pool worth announcing
f_session(int s, bool inside) =>
    bool newHi = false
    bool newLo = false
    bool was   = sesWas.get(s)
    if inside
        if not was or na(sesHi.get(s))
            sesHi.set(s, high)
            sesHiT.set(s, time)
            sesLo.set(s, low)
            sesLoT.set(s, time)
        else
            if high > sesHi.get(s)
                sesHi.set(s, high)
                sesHiT.set(s, time)
            if low < sesLo.get(s)
                sesLo.set(s, low)
                sesLoT.set(s, time)
    else if was and not na(sesHi.get(s))
        int fam = FAM_ASIA + s
        f_clearFam(fam)
        newHi := f_add(fam, sesHi.get(s), sesHiT.get(s), true)
        newLo := f_add(fam, sesLo.get(s), sesLoT.get(s), false)
        sesHi.set(s, na)
        sesLo.set(s, na)
    sesWas.set(s, inside)
    [newHi, newLo]

//@variable Set on any bar that takes a resting pool from a family worth announcing.
bool bslSwept = false
bool sslSwept = false

//@variable Set on any bar that files a pool at a price nothing already rested at.
bool bslNew = false
bool sslNew = false

//@variable The most senior pool taken this bar, for the spoken alert. Rank -1 when none went.
int   sweptTf   = -1
int   sweptRank = -1
bool  sweptBuy  = false
float sweptPx   = na

// State changes only on a CLOSED bar — a level that is removed mid-bar and restored when the bar
// closes lower is a repaint, and an alert fired from it is a lie.
if barstate.isconfirmed
    // The daily candle that is about to be archived IS the previous day. Read it before tracking
    // rolls it over, so PDH / PDL carry the exact minute their extremes printed.
    bool  dayRoll = htfOpen1D != curOpen.get(3) and curOpen.get(3) > 0
    float pdh     = curHi.get(3)
    int   pdhT    = curHiT.get(3)
    float pdl     = curLo.get(3)
    int   pdlT    = curLoT.get(3)

    // Every family's candle is followed FIRST, so the exact minute of a swing is already on record
    // by the time the pivot that names it is confirmed and filed below.
    f_track(0, htfOpen1H)
    f_track(1, htfOpen4H)
    f_track(2, htfOpen7H)
    f_track(3, htfOpen1D)
    f_track(4, htfOpen3D)
    f_track(5, htfOpen1W)

    // Spent liquidity comes off first, so a pool that forms at a price just taken is not
    // immediately deleted by its own bar. Iterate BACKWARDS: removing an element shuffles every
    // index above it, and a forward loop would step straight over the next pool.
    if store.size() > 0
        for i = store.size() - 1 to 0
            Level lv = store.get(i)
            bool taken = lv.buy ? high > lv.price : low < lv.price
            if taken
                int rk = f_rank(lv.tf)
                if rk >= ALERT_RANK
                    if lv.buy
                        bslSwept := true
                    else
                        sslSwept := true
                    if rk > sweptRank
                        sweptRank := rk
                        sweptTf   := lv.tf
                        sweptBuy  := lv.buy
                        sweptPx   := lv.price
                if keepTaken > 0
                    spent.push(Level.new(lv.price, lv.born, lv.tf, lv.buy, time))
                    while spent.size() > keepTaken
                        spent.shift()
                store.remove(i)

    // One spoken alert per bar, naming the most senior pool that went and the price it went at.
    // alertcondition's message is fixed at compile time and cannot say which level was taken, so
    // this fires dynamically as JSON the relay can parse — never plain text (see f_alertJson).
    if sweptTf >= 0
        string sweptEvent = 'htf_liquidity_' + (sweptBuy ? 'bsl' : 'ssl') + '_taken'
        alert(f_alertJson(sweptEvent, sweptPx, f_tag(sweptTf, sweptBuy)), alert.freq_once_per_bar_close)

    // Each call sits LEFT of `or`. `and` / `or` short-circuit in v6, so `bslNew or f_file(...)` would
    // skip the filing entirely once the flag was already set.
    bslNew := f_file(0, ph1H, pht1H, true)  or bslNew
    sslNew := f_file(0, pl1H, plt1H, false) or sslNew
    bslNew := f_file(1, ph4H, pht4H, true)  or bslNew
    sslNew := f_file(1, pl4H, plt4H, false) or sslNew
    bslNew := f_file(2, ph7H, pht7H, true)  or bslNew
    sslNew := f_file(2, pl7H, plt7H, false) or sslNew
    bslNew := f_file(3, ph1D, pht1D, true)  or bslNew
    sslNew := f_file(3, pl1D, plt1D, false) or sslNew
    bslNew := f_file(4, ph3D, pht3D, true)  or bslNew
    sslNew := f_file(4, pl3D, plt3D, false) or sslNew
    bslNew := f_file(5, ph1W, pht1W, true)  or bslNew
    sslNew := f_file(5, pl1W, plt1W, false) or sslNew

    [aHi, aLo] = f_session(0, inAsia)
    [lHi, lLo] = f_session(1, inLon)
    [nHi, nLo] = f_session(2, inNyam)
    bslNew := bslNew or aHi or lHi or nHi
    sslNew := sslNew or aLo or lLo or nLo

    if dayRoll
        f_clearFam(FAM_PD)
        bslNew := f_add(FAM_PD, pdh, pdhT, true)  or bslNew
        sslNew := f_add(FAM_PD, pdl, pdlT, false) or sslNew

// == DRAWING POOL =============================================================

// Objects are created ONCE and then reused. Nothing is deleted and rebuilt on a bar, so the 500
// cap is never approached and the chart does not flicker as price moves between levels.
var array<line>  lnPool = array.new<line>(0)
var array<label> lbPool = array.new<label>(0)
var array<line>  spPool = array.new<line>(0)

//@function Grows the object pool until slot i exists.
//@param i (int) slot index
//@returns (void)
f_ensure(int i) =>
    while lnPool.size() <= i
        line ln = line.new(time, close, time, close, xloc = xloc.bar_time,
             color = HIDDEN, style = line.style_solid, width = 1)
        label lb = label.new(time, close, '', xloc = xloc.bar_time,
             style     = label.style_label_left,
             color     = HIDDEN,
             textcolor = INK,
             size      = LBL_SZ,
             textalign = text.align_left)
        label.set_text_font_family(lb, font.family_monospace)
        lnPool.push(ln)
        lbPool.push(lb)

//@function Grows the taken-pool line pool until slot i exists. No labels: a taken pool is a record
// of where delivery happened, not a level to read a name off.
//@param i (int) slot index
//@returns (void)
f_ensureSpent(int i) =>
    while spPool.size() <= i
        spPool.push(line.new(time, close, time, close, xloc = xloc.bar_time,
             color = HIDDEN, style = line.style_dotted, width = 1))

//@function Builds one level's name: the family tags, then only what the senior family earns. The
// date and the price both come from the SENIOR level, so a merged name and the line under it are
// always describing the same pool.
//@param lv  (Level) the senior pool in the group
//@param tag (string) the family tags, senior first — "4H" or "1D·PDH·Asia"
//@returns (string) the label text
f_text(Level lv, string tag) =>
    string txt = tag
    if showSide
        txt := txt + (lv.buy ? ' BSL' : ' SSL')
    if showDates and lv.tf >= FIRST_DATED and lv.tf < TF_COUNT
        txt := txt + ' ' + str.format_time(lv.born, 'dd/MM', TZ)
    if f_wantsPrice(lv.tf)
        txt := txt + ' ' + str.tostring(lv.price, format.mintick)
    txt

// == RENDER ===================================================================

if barstate.islast
    // ── 1 · SELECT ───────────────────────────────────────────────────────────
    // The closest N live pools per family per side, gathered BEFORE anything is drawn. Nothing can
    // notice that a 1D high and the Asia high are resting at one price until every family's picks
    // sit in the same list, which is why selecting and drawing are two passes and not one.
    array<Level> sel = array.new<Level>(0)
    for t = 0 to FAM_COUNT - 1
        // Toggles gate DRAWING only. Detection above ran regardless.
        if f_on(t) and not f_outgrown(t)
            for side = 0 to 1
                bool isBuy = side == 0
                if (isBuy and showBsl) or (not isBuy and showSsl)
                    array<int>   pick = array.new<int>(0)
                    array<float> gap  = array.new<float>(0)
                    if store.size() > 0
                        for i = store.size() - 1 to 0
                            Level lv = store.get(i)
                            if lv.tf == t and lv.buy == isBuy
                                // Buyside rests ABOVE price, sellside BELOW. A pool on the wrong
                                // side of price has been passed and is waiting to be pruned on
                                // the close.
                                float d = isBuy ? lv.price - close : close - lv.price
                                if d > 0 and (not gateOn or d <= recentRange * gateMult)
                                    pick.push(i)
                                    gap.push(d)

                    if gap.size() > 0
                        // Named sortIdx rather than order: a variable named after the order.*
                        // namespace breaks (CE10150) the moment order.ascending is referenced.
                        array<int> sortIdx = gap.sort_indices(order.ascending)
                        int take = math.min(nPerTf, sortIdx.size())
                        for k = 0 to take - 1
                            sel.push(store.get(pick.get(sortIdx.get(k))))

    // ── 2 · MERGE, THEN DRAW ─────────────────────────────────────────────────
    // Pools resting within the tolerance of each other are ONE pool. They get one line, in the
    // SENIOR family's column and at its weight, carrying every tag that sits there — 1D·PDH·Asia.
    // Never two names for one price, and a collision is always resolved by merging, never by
    // nudging a name off the level it belongs to.
    int slot = 0
    if sel.size() > 0
        array<bool> claimed = array.new<bool>(sel.size(), false)
        for i = 0 to sel.size() - 1
            if not claimed.get(i)
                claimed.set(i, true)
                Level a      = sel.get(i)
                Level senior = a
                float grpLo  = a.price
                float grpHi  = a.price

                //@variable Which families rest at this price. A bool per family also dedupes two
                // pools from the SAME family at one price down to a single tag.
                array<bool> present = array.new<bool>(FAM_COUNT, false)
                present.set(a.tf, true)

                if i < sel.size() - 1
                    for j = i + 1 to sel.size() - 1
                        if not claimed.get(j)
                            Level b = sel.get(j)
                            // Tested against the group's whole ENVELOPE, not just its first member,
                            // so a chain of near-misses cannot walk a group further than the
                            // tolerance ever permitted.
                            if b.buy == a.buy and b.price >= grpHi - mergeTol and b.price <= grpLo + mergeTol
                                claimed.set(j, true)
                                present.set(b.tf, true)
                                grpLo := math.min(grpLo, b.price)
                                grpHi := math.max(grpHi, b.price)
                                if f_rank(b.tf) > f_rank(senior.tf)
                                    senior := b

                string tag = ''
                for r = 0 to FAM_COUNT - 1
                    int fam = TAG_ORDER.get(r)
                    if present.get(fam)
                        tag := tag == '' ? f_tag(fam, a.buy) : tag + '·' + f_tag(fam, a.buy)

                int edge = time + f_ext(senior.tf) * msPerBar
                f_ensure(slot)
                line  ln = lnPool.get(slot)
                label lb = lbPool.get(slot)
                // The line's right edge and the label's x are THE SAME NUMBER used twice. A name
                // computed apart from its line can end up where the line is not.
                line.set_xy1(ln, f_xClamp(senior.born), senior.price)
                line.set_xy2(ln, edge, senior.price)
                line.set_color(ln, INK)
                line.set_width(ln, f_wid(senior.tf))
                line.set_style(ln, line.style_solid)
                label.set_xy(lb, edge, senior.price)
                label.set_text(lb, f_text(senior, tag))
                label.set_textcolor(lb, INK)
                label.set_size(lb, LBL_SZ)
                slot += 1

    // Park every slot this bar did not need. Transparent, empty, and out of the way — kept rather
    // than deleted so the next bar reuses them instead of churning objects.
    if lnPool.size() > slot
        for i = slot to lnPool.size() - 1
            line.set_color(lnPool.get(i), HIDDEN)
            label.set_text(lbPool.get(i), '')
            label.set_textcolor(lbPool.get(i), HIDDEN)

    // ── 3 · TAKEN POOLS ──────────────────────────────────────────────────────
    // Dotted, width 1, from the minute the pool formed to the candle that took it. Same family
    // toggles and the same distance gate as the live ladder.
    int spSlot = 0
    if spent.size() > 0
        for i = spent.size() - 1 to 0
            Level sp = spent.get(i)
            float d  = math.abs(sp.price - close)
            if f_on(sp.tf) and not f_outgrown(sp.tf) and (not gateOn or d <= recentRange * gateMult)
                f_ensureSpent(spSlot)
                line sl = spPool.get(spSlot)
                line.set_xy1(sl, f_xClamp(sp.born), sp.price)
                line.set_xy2(sl, f_xClamp(sp.taken), sp.price)
                line.set_color(sl, INK)
                spSlot += 1
    if spPool.size() > spSlot
        for i = spSlot to spPool.size() - 1
            line.set_color(spPool.get(i), HIDDEN)

// == ALERTS ===================================================================

alertcondition(bslSwept, 'BSL taken', 'Buyside liquidity taken on {{ticker}} at {{close}}')
alertcondition(sslSwept, 'SSL taken', 'Sellside liquidity taken on {{ticker}} at {{close}}')
alertcondition(bslNew, 'New BSL', 'New buyside pool on {{ticker}}')
alertcondition(sslNew, 'New SSL', 'New sellside pool on {{ticker}}')
````
