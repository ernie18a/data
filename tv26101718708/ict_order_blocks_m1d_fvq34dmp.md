# ICT Order Blocks+ (M1D)

- url: https://www.tradingview.com/script/FvQ34DMp-ICT-Order-Blocks-M1D/
- type: indicator
- pine_id: PUB;68483d62e0b349059efd5b84bbff8eb8
- version: 1.0

## Description

ICT Order Blocks+ 
Marks order blocks on the chart's own timeframe using the Inner Circle Trader's own definition from Core Content Month 04.

[b]The definition it follows[/b]

Bullish below; bearish mirrors.

[b]Structure breaks first.[/b] Price closes above the last swing high. Until that close there is no block, only a suspect.

[b]The block is the lowest down-close candle.[/b] Of the down-close candles in the pullback from that swing high, the one that closed lowest is the order block. Two candles closing on the same price: the one with more open-to-close range wins.

[b]Consecutive candles blend.[/b] Two or more down candles in a row at the extreme are one block, from the highest open of the run to the extreme close. A setting reads the single candle only.

[b]The body is the block.[/b] Open to close, never the wicks. Its high is the level price returns to; its low is where the block fails.

[b]Optional rally-away test.[/b] The leg away from the block must travel two to three times the block's own height before it counts. Off by default.

These are established Inner Circle Trader concepts. This script is original in its implementation of them.

[b]What it draws[/b]

[b]The zone.[/b] One bordered box per block, blue for bullish, red for bearish, from the origin candle to just past the live candle.

[b]The tag.[/b] +OB or -OB on the zone's right edge, centred. Hover it for the exact range, the date it formed and whether price has traded back into it yet.

[b]The table.[/b] Bottom right: the script name, the instrument, the timeframe and a countdown to the candle close.

[b]Why the chart stays clean[/b]

[b]Failure erases.[/b] A close through the far side of the body removes the block.

[b]One zone per price area.[/b] A block that overlaps one already drawn is not drawn. Its details join the drawn zone's tooltip instead.

[b]One per side by default.[/b] The newest live bullish block and the newest live bearish block. Raise it in the settings.

[b]Method and repainting[/b]

All detection runs on closed candles, so nothing appears or disappears while a candle is forming. Swing points come from a standard pivot and confirm the set number of candles after they print, which is inherent to pivot detection. Alerts fire once per bar close when a block forms.

[b]Settings[/b]

Detection: swing strength, blending, the rally-away multiple, which sides to show and how many blocks per side.

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
indicator("ICT Order Blocks+ (M1D)", "OB+", overlay = true, max_lines_count = 20, max_labels_count = 20, max_boxes_count = 20)

// Order blocks on the chart timeframe, on ICT's own definition (Core Content Month 04).
//
// A close above the last swing high makes the bullish block: the LOWEST down-close candle in the
// pullback from that swing high. Consecutive down candles at it blend into ONE block, from the highest
// open to the extreme close. Two candles closing on the same price: the one with more open-to-close
// range wins. A close below the last swing low makes the bearish block the same way, from up candles.
// The block is the body, open to close. A close through the body ends it.
//
// Everything is judged on closed candles, so nothing changes while a candle is forming.

// == CONSTANTS ==
const string NY_TZ     = "America/New_York"
const int    SCAN_MAX  = 40
const int    GROUP_MAX = 4
const int    KEEP_MAX  = 40

// == INPUTS ==
const string G_D = "Detection"
const string G_S = "Style"
const string G_T = "Table"

int   swingLen  = input.int(2, "Swing strength (candles each side)", minval = 1, maxval = 6, group = G_D, tooltip = "How many candles either side confirm a swing high or low. Higher reads fewer, larger swings.")
bool  blendRun  = input.bool(true, "Blend consecutive candles into one block", group = G_D, tooltip = "ICT: two or more down candles in a row at the extreme are ONE bullish block (up candles for a bearish one), from the highest open to the extreme close. Off reads the single extreme candle only.")
float rallyMult = input.float(0.0, "Rally-away multiple (ICT: 2 to 3, 0 = off)", minval = 0.0, maxval = 10.0, step = 0.5, group = G_D, tooltip = "ICT looks for a rally of at least two to three times the block's body height before trusting it. Above 0, a block only registers when the leg away from it has travelled that many block heights. 0 turns the test off.")
bool  showBull  = input.bool(true, "Bullish", group = G_D, inline = "s")
bool  showBear  = input.bool(true, "Bearish", group = G_D, inline = "s")
int   keepN     = input.int(1, "Blocks shown per side", minval = 1, maxval = 5, group = G_D, tooltip = "The newest live blocks of each direction. A block overlapping one already drawn is left off and named in that zone's tooltip.")

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

max_bars_back(open, 100)
max_bars_back(high, 100)
max_bars_back(low, 100)
max_bars_back(close, 100)
max_bars_back(time, 100)

// == MODEL ==
//@type A order block.
//@field bull True for the bullish side, which holds price from below.
//@field top Top of the body (the whole run's body when blended).
//@field bot Bottom of the same body.
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

float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var array<Block> blocks = array.new<Block>()
var float swHi       = na
var int   swHiBar    = na
var bool  swHiBroken = true
var float swLo       = na
var int   swLoBar    = na
var bool  swLoBroken = true

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
        swHi       := ph
        swHiBar    := bar_index - swingLen
        swHiBroken := false
    if not na(pl)
        swLo       := pl
        swLoBar    := bar_index - swingLen
        swLoBroken := false

    // Bullish: a close above the swing high. The lowest down-close candle in the move down from it.
    if not swHiBroken and close > swHi
        swHiBroken := true
        int span = math.min(bar_index - swHiBar, SCAN_MAX, bar_index)
        int kBest = na
        float lowest = na
        if span > 0
            for k = 1 to span
                if close[k] < open[k]
                    bool better = na(lowest) or close[k] < lowest or (close[k] == lowest and (open[k] - close[k]) > (open[kBest] - close[kBest]))
                    if better
                        lowest := close[k]
                        kBest  := k
        if not na(kBest)
            int kStart = kBest
            if blendRun
                for j = 1 to GROUP_MAX - 1
                    if kBest + j <= bar_index and close[kBest + j] < open[kBest + j]
                        kStart := kBest + j
                    else
                        break
            // ICT: a blended block begins at the highest of its candles.
            float grpTop = open[kBest]
            for j = kBest to kStart
                grpTop := math.max(grpTop, open[j])
            float bodyH = grpTop - close[kBest]
            float legHi = high
            if kBest > 1
                for j = 1 to kBest - 1
                    legHi := math.max(legHi, high[j])
            if rallyMult <= 0 or legHi - grpTop >= rallyMult * bodyH
                blocks.push(Block.new(bull = true, top = grpTop, bot = close[kBest], t = time[kStart], tForm = time))
                evBull := true

    // Bearish: a close below the swing low. The highest up-close candle in the rally from it.
    if not swLoBroken and close < swLo
        swLoBroken := true
        int span = math.min(bar_index - swLoBar, SCAN_MAX, bar_index)
        int kBest = na
        float highest = na
        if span > 0
            for k = 1 to span
                if close[k] > open[k]
                    bool better = na(highest) or close[k] > highest or (close[k] == highest and (close[k] - open[k]) > (close[kBest] - open[kBest]))
                    if better
                        highest := close[k]
                        kBest   := k
        if not na(kBest)
            int kStart = kBest
            if blendRun
                for j = 1 to GROUP_MAX - 1
                    if kBest + j <= bar_index and close[kBest + j] > open[kBest + j]
                        kStart := kBest + j
                    else
                        break
            float grpBot = open[kBest]
            for j = kBest to kStart
                grpBot := math.min(grpBot, open[j])
            float bodyH = close[kBest] - grpBot
            float legLo = low
            if kBest > 1
                for j = 1 to kBest - 1
                    legLo := math.min(legLo, low[j])
            if rallyMult <= 0 or grpBot - legLo >= rallyMult * bodyH
                blocks.push(Block.new(bull = false, top = close[kBest], bot = grpBot, t = time[kStart], tForm = time))
                evBear := true

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
                string tip = (b.bull ? "Bull OB: " : "Bear OB: ") + str.tostring(b.bot, format.mintick) + " to " + str.tostring(b.top, format.mintick) + " · formed " + f_date(b.t) + " · " + (b.tested ? "tested" : "untested")
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
                    label lb = label.new(rightT, math.avg(b.top, b.bot), b.bull ? "+OB" : "-OB", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = INK, size = LBL_SZ, textalign = text.align_left, text_font_family = font.family_monospace, tooltip = tip)
                    labelStore.push(lb)
                    zTop.push(b.top)
                    zBot.push(b.bot)
                    zLbl.push(lb)
                    zTip.push(tip)

    if showTbl
        if na(tbl)
            tbl := table.new(f_pos(tblPosIn), 2, 4, frame_color = INK, frame_width = 1, border_width = 0)
        table.cell(tbl, 0, 0, "ORDER BLOCKS+", text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(tbl, 1, 0, CHART_CLOCK ? "REPLAY" : "", text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace)
        f_row(tbl, 1, "INSTRUMENT", syminfo.ticker, syminfo.description)
        f_row(tbl, 2, "TIMEFRAME", f_tfTag(), "Blocks are read on the chart's own candles.")
        f_row(tbl, 3, "CANDLE CLOSES IN", f_left(), CHART_CLOCK ? "Bar replay: timed off the replayed candle, so it steps a chart candle at a time." : "Timed off the live clock. It moves with each price tick, so it can pause when the market is quiet.")
    else if not na(tbl)
        table.delete(tbl)
        tbl := na

// == ALERTS ==
alertcondition(evBull, "Bullish order block formed", "Bullish order block formed on {{ticker}}")
alertcondition(evBear, "Bearish order block formed", "Bearish order block formed on {{ticker}}")
````
