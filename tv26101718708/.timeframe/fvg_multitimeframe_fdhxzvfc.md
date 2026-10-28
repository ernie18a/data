# FVG Multi-Timeframe

- url: https://www.tradingview.com/script/fDhXZvFC-FVG-Multi-Timeframe/
- type: indicator
- pine_id: PUB;e7d58c0f66c64faf9a4eb8cb9f659d43
- version: 1.0

## Description

FVG Multi-Timeframe marks fair value gaps on your chart, from up to five timeframes at once.

It's a simple, clean tool: it finds the gaps, draws them, and lets you choose which timeframes to show and in which colours. It doesn't give buy or sell signals.

WHAT IS A FAIR VALUE GAP?

A fair value gap (FVG) is a three-candle pattern that shows an imbalance in the market.

- Bullish FVG: the low of candle 3 is above the high of candle 1.
- Bearish FVG: the high of candle 3 is below the low of candle 1.

The space between candle 1 and candle 3 is the gap. The middle candle that creates it is usually large and strong.

WHY THEY FORM

Fair value gaps appear when one side of the market overwhelms the other. A surprise economic release, a central bank decision or a large order pushes buyers (or sellers) to act at once. Their orders absorb everything available at each price faster than the other side can respond, so price moves quickly in one direction.

As a result, price passed through the prices inside the gap very quickly, with little two-way trading. That one-sided move is the imbalance the gap represents.

WHY TRADERS WATCH THEM

- They show where a strong move started. The gap marks the area where buyers or sellers took clear control.
- Price often returns to them. After a sharp move, markets frequently pull back, and the gap is a common area for that pullback to reach.
- They give reference zones. Many traders watch how price behaves when it comes back to a gap: whether it reacts and continues in the direction of the original move, or closes straight through it.

HOW TRADERS USUALLY USE THEM

The most common approach is to trade in the direction of the move that created the gap. Traders wait for price to correct back into the gap, and look for the market to react there and continue in the direction of the overall trend. A bullish gap in an uptrend is watched as a possible area for the uptrend to resume; a bearish gap in a downtrend as a possible area for the downtrend to resume.

Many traders give more weight to gaps on higher timeframes, to the first time price returns to a gap, and to gaps that line up with their wider analysis.

WHAT THIS INDICATOR DOES

- Multiple timeframes: show gaps from up to five timeframes on one chart. For example, on a 15-minute chart you can see the 1-hour, 4-hour and daily gaps at the same time.
- Colours per timeframe: each timeframe has its own bullish and bearish colour, so you can tell a daily gap from a 1-hour gap at a glance.
- Filled gaps (optional): by default, a gap is removed once a candle closes through it. Turn on "Show filled FVGs" to keep filled gaps on the chart in a lighter shade of their colour. If a gap is filled while its box is still running, the box is cut off at the candle that filled it. This lets you review how past gaps behaved.
- No repainting on higher timeframes: gaps from higher timeframes only appear once their candle has closed.

SETTINGS

Timeframes
- Timeframe 1 to 5: tick a slot to switch it on and choose its timeframe. Timeframe 1 is set to the chart's timeframe by default.
- The two colour boxes next to each timeframe set the bullish (left) and bearish (right) gap colour.
- Timeframes lower than the chart you're viewing are skipped.

Settings
- Look back (candles): how many candles back from the latest candle on your chart the indicator searches for gaps.
- Show filled FVGs: keep filled gaps on the chart in a lighter colour.
- Extend: how far each gap box stretches to the right, in candles of that gap's own timeframe. On higher timeframes this is measured in time, so weekends count towards it.

NOTES

- A gap counts as filled when a candle on your chart closes beyond its far edge: below a bullish gap, or above a bearish gap.
- On the chart's own timeframe, a gap forming on the live candle is only confirmed when that candle closes.
- Not every gap gets revisited, and not every revisit leads to a reaction. Fair value gaps work best as one part of a wider analysis.
- This is an analysis tool, not a buy or sell signal. Use it alongside your own analysis and risk management.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  Fair Value Gaps
//  Built by Jake Koel  ·  © jakekoel
// ─────────────────────────────────────────────────────────────
// Marks fair value gaps (3-candle imbalances) from up to 5 timeframes at once.
// Bullish FVG: candle 3 low is above candle 1 high.
// Bearish FVG: candle 3 high is below candle 1 low.
// A gap counts as filled when a candle closes beyond its far edge
// (below a bullish gap, above a bearish gap).
indicator("Fair Value Gaps", shorttitle = "FVG", overlay = true, max_boxes_count = 500)

// ───────────────────────── Inputs ─────────────────────────
color BLUE = color.new(#5B8DEF, 70)
string G_TF  = "Timeframes"
string TT_TF = "Tick to show this timeframe's gaps.\nLeft colour: bullish FVG. Right colour: bearish FVG.\nTimeframes lower than your chart are skipped."

bool   on1 = input.bool(true, "Timeframe 1", inline = "tf1", group = G_TF)
string tf1 = input.timeframe("", "", inline = "tf1", group = G_TF)
color  bu1 = input.color(BLUE, "", inline = "tf1", group = G_TF)
color  be1 = input.color(BLUE, "", inline = "tf1", group = G_TF, tooltip = TT_TF)

bool   on2 = input.bool(false, "Timeframe 2", inline = "tf2", group = G_TF)
string tf2 = input.timeframe("15", "", inline = "tf2", group = G_TF)
color  bu2 = input.color(BLUE, "", inline = "tf2", group = G_TF)
color  be2 = input.color(BLUE, "", inline = "tf2", group = G_TF)

bool   on3 = input.bool(false, "Timeframe 3", inline = "tf3", group = G_TF)
string tf3 = input.timeframe("60", "", inline = "tf3", group = G_TF)
color  bu3 = input.color(BLUE, "", inline = "tf3", group = G_TF)
color  be3 = input.color(BLUE, "", inline = "tf3", group = G_TF)

bool   on4 = input.bool(false, "Timeframe 4", inline = "tf4", group = G_TF)
string tf4 = input.timeframe("240", "", inline = "tf4", group = G_TF)
color  bu4 = input.color(BLUE, "", inline = "tf4", group = G_TF)
color  be4 = input.color(BLUE, "", inline = "tf4", group = G_TF)

bool   on5 = input.bool(false, "Timeframe 5", inline = "tf5", group = G_TF)
string tf5 = input.timeframe("D", "", inline = "tf5", group = G_TF)
color  bu5 = input.color(BLUE, "", inline = "tf5", group = G_TF)
color  be5 = input.color(BLUE, "", inline = "tf5", group = G_TF)

string G_GEN      = "Settings"
int    lookback   = input.int(300, "Look back (candles)", minval = 10, maxval = 5000, group = G_GEN, tooltip = "How many chart candles back from the latest candle the indicator searches for gaps.")
bool   showFilled = input.bool(false, "Show filled FVGs", group = G_GEN, tooltip = "Off: a gap disappears once a candle closes through it.\nOn: filled gaps stay on the chart in a lighter shade of their colour, ending at the candle that filled them.")
int    extendN    = input.int(30, "Extend", minval = 0, group = G_GEN, tooltip = "How many candles each gap box stretches to the right, counted in that gap's own timeframe.")

// ───────────────────────── Detection ─────────────────────────
// Gap formed by the 3 candles ending o candles ago.
// Returns: bullish?, bearish?, top of gap, bottom of gap, open time of candle 1
gapAt(int o) =>
    bool  bull = low[o] > high[o + 2]
    bool  bear = high[o] < low[o + 2]
    float top  = bull ? low[o] : bear ? low[o + 2] : na
    float bot  = bull ? high[o + 2] : bear ? high[o] : na
    [bull, bear, top, bot, time[o + 2]]

type Gap
    float top
    float bot
    bool  isBull
    box   b
    int   rightEnd
    bool  htf

bool inWindow = bar_index >= last_bar_index - lookback

// Lighter version of a colour for filled gaps
fade(color c) =>
    color.new(c, math.min(100, color.t(c) + 18))

// Finds, draws and updates the gaps of one timeframe slot.
// Each call keeps its own list of gaps (var inside a function is separate per call).
runSlot(bool on, string tfIn, color bullCol, color bearCol) =>
    var array<Gap> active = array.new<Gap>()
    var int lastT = na

    string tf     = tfIn == "" ? timeframe.period : tfIn
    float  tfSec  = timeframe.in_seconds(tf)
    float  chSec  = timeframe.in_seconds()
    bool   valid  = on and tfSec >= chSec
    bool   useHTF = valid and tfSec > chSec

    // Higher timeframe: only gaps from finished candles (no repainting)
    [hBull, hBear, hTop, hBot, hT] = request.security(syminfo.tickerid, useHTF ? tf : timeframe.period, gapAt(1), lookahead = barmerge.lookahead_on)
    // Chart timeframe
    [cBull, cBear, cTop, cBot, cT] = gapAt(0)

    bool  isBull = useHTF ? hBull : cBull
    bool  isBear = useHTF ? hBear : cBear
    float gTop   = useHTF ? hTop  : cTop
    float gBot   = useHTF ? hBot  : cBot
    int   gT     = useHTF ? hT    : cT

    // New gap (added once, even when a higher-timeframe value repeats over several chart candles)
    if valid and inWindow and (isBull or isBear) and (na(lastT) or gT != lastT)
        lastT := gT
        color col  = isBull ? bullCol : bearCol
        box   bx   = na
        int   rEnd = na
        if useHTF
            rEnd := gT + (extendN + 3) * int(tfSec * 1000)
            bx   := box.new(gT, gTop, rEnd, gBot, xloc = xloc.bar_time, border_color = na, bgcolor = col)
        else
            rEnd := bar_index + extendN
            bx   := box.new(bar_index - 2, gTop, rEnd, gBot, border_color = na, bgcolor = col)
        active.unshift(Gap.new(gTop, gBot, isBull, bx, rEnd, useHTF))
        if active.size() > 500
            active.pop()

    // Filled gaps: a close beyond the far edge
    if active.size() > 0
        for i = active.size() - 1 to 0
            Gap g = active.get(i)
            bool filled = g.isBull ? close < g.bot : close > g.top
            if filled
                if showFilled
                    g.b.set_bgcolor(fade(g.isBull ? bullCol : bearCol))
                    int nowX = g.htf ? time : bar_index
                    if nowX < g.rightEnd
                        g.b.set_right(nowX)
                else
                    g.b.delete()
                active.remove(i)
    true

runSlot(on1, tf1, bu1, be1)
runSlot(on2, tf2, bu2, be2)
runSlot(on3, tf3, bu3, be3)
runSlot(on4, tf4, bu4, be4)
runSlot(on5, tf5, bu5, be5)

// ───────────────────────── Signature ─────────────────────────
var table sig = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(sig, 0, 0, "@jakekoel", text_color = color.new(color.gray, 30), text_size = size.small)
````
