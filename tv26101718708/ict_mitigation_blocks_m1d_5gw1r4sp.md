# ICT Mitigation Blocks+ (M1D)

- url: https://www.tradingview.com/script/5gW1r4Sp-ICT-Mitigation-Blocks-M1D/
- type: indicator
- pine_id: PUB;11b6b9e3dea0450ea00ba6b3c2a8fd1c
- version: 1.0

## Description

ICT Mitigation Blocks+ 
Marks mitigation blocks on the chart's own timeframe using the Inner Circle Trader's own definition from Core Content Month 04, and nothing else. One array, drawn clean, so it can be studied on its own.

[b]The definition it follows[/b]

Bearish below; bullish mirrors.

[b]A high, then a swing low.[/b] Price runs up into a high, pulls back to a swing low, and rallies again.

[b]The second high fails.[/b] The rally stalls below the first high: a failure swing, the M shape. No old high is raided. That is what separates a mitigation block from a breaker.

[b]The swing low breaks.[/b] Price closes below the swing low between the two highs. That close is the market structure shift.

[b]The block is the last down-close candle at that low.[/b] It is where the buying took place before the short rally. Those buyers are now underwater, and when price returns to that candle they mitigate their losses: support broken turns resistance.

[b]The body is the block.[/b] Open to close. ICT's hallmark is that price trades back into it without violating the body.

The bullish block mirrors it: a low, a swing high, a higher low that fails to take out the first, then a close above that swing high. The block is the last up-close candle at the swing high.

These are established Inner Circle Trader concepts. This script is original in its implementation of them.

[b]What it draws[/b]

[b]The zone.[/b] One bordered box per block, blue for bullish, red for bearish, from the origin candle to just past the live candle.

[b]The tag.[/b] +MB or -MB on the zone's right edge, centred. Hover it for the exact range, the date it formed and whether price has traded back into it yet.

[b]The table.[/b] Bottom right: the script name, the instrument, the timeframe and a countdown to the candle close.

[b]Why the chart stays clean[/b]

[b]Failure erases.[/b] A close through the far side of the body removes the block.

[b]One zone per price area.[/b] A block that overlaps one already drawn is not drawn. Its details join the drawn zone's tooltip instead.

[b]One per side by default.[/b] The newest live bullish block and the newest live bearish block. Raise it in the settings.

[b]Method and repainting[/b]

All detection runs on closed candles, so nothing appears or disappears while a candle is forming. Swing points come from a standard pivot and confirm the set number of candles after they print, which is inherent to pivot detection. A swing that waits too long for its break is retired. Alerts fire once per bar close when a block forms.

[b]Settings[/b]

Detection: swing strength, which sides to show and how many blocks per side.

Style: bullish and bearish colours, zone fill, right offset and one text size for labels and table.

Table: on or off, and its position.

[b]Analytics only[/b]

This is a study tool. It marks a structure and the block that structure leaves behind. It contains no buy or sell signals, and its alerts announce that a block formed; they are notifications, not trade instructions.

[b]Disclaimer[/b]

This is a decision-support tool for discretionary ICT trading. It is not financial advice, and no market's past behaviour is indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy

//@version=6
indicator("ICT Mitigation Blocks+ (M1D)", "MB+", overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 20)

// Mitigation blocks on the chart timeframe, on ICT's own definition (Core Content Month 04).
//
// A failure swing: a swing low sits between two highs and the second high FAILS to take out the first,
// then a close breaks that swing low, a market structure shift. The last down-close candle at that low
// is the bearish mitigation block, read on the body: trapped longs mitigate when price returns to it.
// The bullish block mirrors it from the last up-close candle at the swing high between two lows, the
// second low failing to take out the first. A close through the body ends it.
//
// Everything is judged on closed candles, so nothing changes while a candle is forming.

// == CONSTANTS ==
const string NY_TZ     = "America/New_York"
const int    MAX_AGE   = 200
const int    KEEP_MAX  = 40
// Deepest candle offset the search may read. The series buffers below hold 500 bars.
const int    REACH_MAX = 490
// 1 = the second extreme raided the first (breaker). 2 = it failed to (mitigation block).
const int    KIND      = 2
const string TAG       = "MB"
const string NAME      = "Mitigation Block"

// == INPUTS ==
const string G_D = "Detection"
const string G_S = "Style"
const string G_T = "Table"

int  swingLen = input.int(2, "Swing strength (candles each side)", minval = 1, maxval = 6, group = G_D, tooltip = "How many candles either side confirm a swing high or low. Higher reads fewer, larger swings.")
bool showBull = input.bool(true, "Bullish", group = G_D, inline = "s")
bool showBear = input.bool(true, "Bearish", group = G_D, inline = "s")
int  keepN    = input.int(1, "Blocks shown per side", minval = 1, maxval = 5, group = G_D, tooltip = "The newest live blocks of each direction. A block overlapping one already drawn is left off and named in that zone's tooltip.")

color  bullCol    = input.color(#1D4ED8, "Bullish colour", group = G_S)
color  bearCol    = input.color(#F23645, "Bearish colour", group = G_S)
int    fillTransp = input.int(88, "Zone fill transparency", minval = 0, maxval = 100, group = G_S)
int    runwayBars = input.int(2, "Right offset (bars)", minval = 0, maxval = 200, group = G_S, tooltip = "How far past the live candle each zone reaches before its name.")
string lblSizeIn  = input.string("small", "Text size", options = ["tiny", "small", "normal", "large"], group = G_S, tooltip = "Sets the labels and the table together.")

bool   showTbl  = input.bool(true, "Show table", group = G_T)
string tblPosIn = input.string("Bottom Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Center", "Bottom Center", "Top Left", "Middle Left", "Bottom Left"], group = G_T)

// == HELPERS ==
//@function Resolves a size name to the size constant.
//@param s (string) "tiny", "small", "normal" or "large".
//@returns (string) The size constant.
f_size(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

//@function Resolves a table position name.
//@param s (string) The position name.
//@returns (string) The position constant.
f_pos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Middle Right"  => position.middle_right
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        "Top Left"      => position.top_left
        "Middle Left"   => position.middle_left
        "Bottom Left"   => position.bottom_left
        =>                 position.bottom_right

string LBL_SZ = f_size(lblSizeIn)

//@variable Ink for the labels and the table: white on a dark chart, black on a light one.
bool  INK_DARK = not na(chart.bg_color) and color.r(chart.bg_color) + color.g(chart.bg_color) + color.b(chart.bg_color) < 384
color INK      = INK_DARK ? #FFFFFF : #000000

max_bars_back(open, 500)
max_bars_back(high, 500)
max_bars_back(low, 500)
max_bars_back(close, 500)
max_bars_back(time, 500)

// == MODEL ==
//@type A block.
//@field bull True for the bullish side, which holds price from below.
//@field top Top of the block.
//@field bot Bottom of the block.
//@field t Open time of the origin candle.
//@field tForm Time of the close that confirmed the block.
//@field tested True once price has traded back into the block.
type Block
    bool  bull
    float top
    float bot
    int   t
    int   tForm
    bool  tested = false

//@function Adds a swing pivot to the running sequence of the last three, merging two pivots of one kind into the more extreme.
//@param pr (array<float>) Pivot prices, oldest first.
//@param br (array<int>) Pivot bar indexes.
//@param ty (array<int>) Pivot kinds: 1 high, -1 low.
//@param price (float) The new pivot's price.
//@param bar (int) The new pivot's bar index.
//@param kind (int) 1 for a high, -1 for a low.
//@returns (bool) True when the sequence changed.
f_pivot(array<float> pr, array<int> br, array<int> ty, float price, int bar, int kind) =>
    bool changed = false
    int n = ty.size()
    if n > 0 and ty.get(n - 1) == kind
        float last = pr.get(n - 1)
        if kind == 1 ? price > last : price < last
            pr.set(n - 1, price)
            br.set(n - 1, bar)
            changed := true
    else
        pr.push(price)
        br.push(bar)
        ty.push(kind)
        changed := true
        while ty.size() > 3
            pr.shift()
            br.shift()
            ty.shift()
    changed

//@function The block's top from its origin candle.
//@param k (int) Offset of the origin candle.
//@returns (float) The top: the high for a breaker, the body top otherwise.
f_top(int k) =>
    KIND == 1 ? high[k] : math.max(open[k], close[k])

//@function The block's bottom from its origin candle.
//@param k (int) Offset of the origin candle.
//@returns (float) The bottom: the low for a breaker, the body bottom otherwise.
f_bot(int k) =>
    KIND == 1 ? low[k] : math.min(open[k], close[k])

float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var array<Block> blocks  = array.new<Block>()
var array<float> pvPrice = array.new<float>()
var array<int>   pvBar   = array.new<int>()
var array<int>   pvType  = array.new<int>()

// A swing low waiting for a close below it (bearish), a swing high waiting for a close above it (bullish).
var float bearL    = na
var int   bearLbar = na
var int   bearKind = na
var int   bearArm  = na
var float bullH    = na
var int   bullHbar = na
var int   bullKind = na
var int   bullArm  = na
// The swing each side last broke, so the same swing never arms twice.
var int   bearDone = na
var int   bullDone = na

bool evBull = false
bool evBear = false

if barstate.isconfirmed
    // A close through the body ends a block. A bar that trades into it marks it tested.
    if blocks.size() > 0
        for i = blocks.size() - 1 to 0
            Block b = blocks.get(i)
            if b.bull ? close < b.bot : close > b.top
                blocks.remove(i)
            else if not b.tested and b.tForm < time and low <= b.top and high >= b.bot
                b.tested := true

    if not na(ph)
        if f_pivot(pvPrice, pvBar, pvType, ph, bar_index - swingLen, 1)
            if pvType.size() == 3 and pvType.get(0) == 1 and pvType.get(1) == -1 and (na(bearDone) or pvBar.get(1) != bearDone)
                bearL    := pvPrice.get(1)
                bearLbar := pvBar.get(1)
                bearKind := pvPrice.get(2) > pvPrice.get(0) ? 1 : 2
                bearArm  := bar_index
    if not na(pl)
        if f_pivot(pvPrice, pvBar, pvType, pl, bar_index - swingLen, -1)
            if pvType.size() == 3 and pvType.get(0) == -1 and pvType.get(1) == 1 and (na(bullDone) or pvBar.get(1) != bullDone)
                bullH    := pvPrice.get(1)
                bullHbar := pvBar.get(1)
                bullKind := pvPrice.get(2) < pvPrice.get(0) ? 1 : 2
                bullArm  := bar_index

    // Bearish: a close below the swing low between two highs.
    if not na(bearL) and bar_index - bearArm > MAX_AGE
        bearL := na
    if not na(bearL) and close < bearL
        int kOff = bar_index - bearLbar
        int kPick = na
        if bearKind == KIND and kOff + 3 <= REACH_MAX
            for j = 0 to 3
                int k = kOff + j
                if k <= bar_index and close[k] < open[k]
                    kPick := k
                    break
        if not na(kPick)
            blocks.push(Block.new(bull = false, top = f_top(kPick), bot = f_bot(kPick), t = time[kPick], tForm = time))
            evBear := true
        bearDone := bearLbar
        bearL    := na

    // Bullish: a close above the swing high between two lows.
    if not na(bullH) and bar_index - bullArm > MAX_AGE
        bullH := na
    if not na(bullH) and close > bullH
        int kOff = bar_index - bullHbar
        int kPick = na
        if bullKind == KIND and kOff + 3 <= REACH_MAX
            for j = 0 to 3
                int k = kOff + j
                if k <= bar_index and close[k] > open[k]
                    kPick := k
                    break
        if not na(kPick)
            blocks.push(Block.new(bull = true, top = f_top(kPick), bot = f_bot(kPick), t = time[kPick], tForm = time))
            evBull := true
        bullDone := bullHbar
        bullH    := na

    while blocks.size() > KEEP_MAX
        blocks.shift()

// == DRAWING ==
var array<label> labelStore = array.new<label>()
var array<box>   boxStore   = array.new<box>()

//@function The origin date for a tooltip, New York time, with the clock on intraday charts.
//@param t (int) Origin candle open time.
//@returns (string) The date text.
f_date(int t) =>
    str.format_time(t, timeframe.in_seconds() < 86400 ? "dd MMM HH:mm" : "dd MMM yy", NY_TZ)

// == TABLE ==
//@variable True when the real clock sits inside the live chart candle.
bool LIVE_CLOCK = barstate.isrealtime and timenow >= time and timenow <= time_close
//@variable True in bar replay, where the replayed candle is the clock.
bool CHART_CLOCK = barstate.isrealtime and not LIVE_CLOCK

//@function Time left until the chart candle closes, as h:mm:ss or mm:ss.
//@returns (string) The countdown, or "Closed" when the market is not trading.
f_left() =>
    int now = LIVE_CLOCK ? timenow : CHART_CLOCK ? time_close : na
    int ms  = na(time_close) or na(now) ? na : time_close - now
    if na(ms) or ms < 0
        "Closed"
    else
        int s = int(ms / 1000)
        int h = int(s / 3600)
        int m = int((s % 3600) / 60)
        int r = s % 60
        string mm = (m < 10 ? "0" : "") + str.tostring(m)
        string ss = (r < 10 ? "0" : "") + str.tostring(r)
        h > 0 ? str.tostring(h) + ":" + mm + ":" + ss : mm + ":" + ss

//@function The chart timeframe as a short tag: 1m, 5m, 1H.
//@returns (string) The tag.
f_tfTag() =>
    int sec = timeframe.in_seconds()
    sec < 60 ? str.tostring(sec) + "s" : sec < 3600 ? str.tostring(int(sec / 60)) + "m" : sec < 86400 ? str.tostring(int(sec / 3600)) + "H" : timeframe.period

//@function Writes one name and value row of the table.
//@param t (table) The table.
//@param r (int) Row.
//@param name (string) Name.
//@param val (string) Value.
//@param tip (string) Tooltip on the value.
//@returns (bool) Always true.
f_row(table t, int r, string name, string val, string tip) =>
    table.cell(t, 0, r, name, text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(t, 1, r, val, text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = tip)
    true

var table tbl = na

if barstate.islast
    while labelStore.size() > 0
        label.delete(labelStore.pop())
    while boxStore.size() > 0
        box.delete(boxStore.pop())

    int rightT = time + runwayBars * timeframe.in_seconds() * 1000

    // Newest first. A block overlapping one already drawn is not drawn; its details join that zone's tooltip.
    array<int>    shown = array.new<int>(2, 0)
    array<float>  zTop  = array.new<float>()
    array<float>  zBot  = array.new<float>()
    array<label>  zLbl  = array.new<label>()
    array<string> zTip  = array.new<string>()
    if blocks.size() > 0
        for i = blocks.size() - 1 to 0
            Block b = blocks.get(i)
            int slot = b.bull ? 1 : 0
            if (b.bull ? showBull : showBear) and shown.get(slot) < keepN
                string tip = (b.bull ? "Bull " : "Bear ") + NAME + ": " + str.tostring(b.bot, format.mintick) + " to " + str.tostring(b.top, format.mintick) + " · formed " + f_date(b.t) + " · " + (b.tested ? "tested" : "untested")
                int hit = -1
                if zTop.size() > 0
                    for j = 0 to zTop.size() - 1
                        if b.bot < zTop.get(j) and b.top > zBot.get(j)
                            hit := j
                            break
                if hit >= 0
                    string merged = zTip.get(hit) + "\n" + tip
                    zTip.set(hit, merged)
                    label.set_tooltip(zLbl.get(hit), merged)
                else
                    shown.set(slot, shown.get(slot) + 1)
                    color col = b.bull ? bullCol : bearCol
                    boxStore.push(box.new(b.t, b.top, rightT, b.bot, xloc = xloc.bar_time, border_color = col, border_width = 1, border_style = line.style_solid, bgcolor = color.new(col, fillTransp)))
                    label lb = label.new(rightT, math.avg(b.top, b.bot), (b.bull ? "+" : "-") + TAG, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = INK, size = LBL_SZ, textalign = text.align_left, text_font_family = font.family_monospace, tooltip = tip)
                    labelStore.push(lb)
                    zTop.push(b.top)
                    zBot.push(b.bot)
                    zLbl.push(lb)
                    zTip.push(tip)

    if showTbl
        if na(tbl)
            tbl := table.new(f_pos(tblPosIn), 2, 4, frame_color = INK, frame_width = 1, border_width = 0)
        table.cell(tbl, 0, 0, "MITIGATION BLOCKS+", text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(tbl, 1, 0, CHART_CLOCK ? "REPLAY" : "", text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace)
        f_row(tbl, 1, "INSTRUMENT", syminfo.ticker, syminfo.description)
        f_row(tbl, 2, "TIMEFRAME", f_tfTag(), "Blocks are read on the chart's own candles.")
        f_row(tbl, 3, "CANDLE CLOSES IN", f_left(), CHART_CLOCK ? "Bar replay: timed off the replayed candle, so it steps a chart candle at a time." : "Timed off the live clock. It moves with each price tick, so it can pause when the market is quiet.")
    else if not na(tbl)
        table.delete(tbl)
        tbl := na

// == ALERTS ==
alertcondition(evBull, "Bullish mitigation block formed", "Bullish mitigation block formed on {{ticker}}")
alertcondition(evBear, "Bearish mitigation block formed", "Bearish mitigation block formed on {{ticker}}")
````
