# Fair Value Gap Indicator with Fill Tracking and HTF Gaps 

- url: https://www.tradingview.com/script/PQnDPXVm-Fair-Value-Gap-Indicator-with-Fill-Tracking-and-HTF-Gaps/
- type: indicator
- pine_id: PUB;0e1501de3b0341989a13cab3f5d65d6e
- version: 1.0

## Description

🔵 [b]OVERVIEW[/b]

[quote]
[b]Fair Value Gap Indicator with Fill Tracking and HTF Gaps [Viprasol][/b] is an indicator that draws only the fair value gaps (FVG) created by real displacement, tracks how much of each gap has been filled in real time, and keeps statistics on how gaps get revisited and mitigated. It cuts out the clutter of plotting every three-candle gap, and shows how FVGs actually behave on your market instead of leaving you to guess.
[/quote]

🔵 [b]HOW IT WORKS[/b]

[quote]
The indicator detects qualified gaps, follows each one until it is mitigated or expires, and records the outcome:

[b]1 — Gap Detection[/b]

[list]
[*][b]Three-Candle Imbalance:[/b] A bullish FVG forms when the low of the current candle is above the high of the candle two bars back, with a bullish middle candle. Bearish is the mirror. The gap is the untraded price area between candle 1 and candle 3.
[*][b]Size Filter:[/b] The gap height must be at least [i]Minimum gap size[/i] × ATR.
[*][b]Displacement Filter:[/b] The middle candle body must be at least [i]Displacement[/i] × ATR, so only gaps created by a decisive move are kept.
[/list]

[b]2 — Fill Tracking[/b]

[list]
[*][b]Deepest Fill:[/b] For every open gap the indicator records the deepest price that traded back into it.
[*][b]Live Fill %:[/b] The distance traded into the gap divided by the gap height, printed on the box.
[*][b]50% Line:[/b] An optional dotted line at the middle of the gap (consequent encroachment).
[/list]

[b]3 — Mitigation[/b]

[list]
[*][b]Full fill:[/b] The whole gap has been traded through.
[*][b]50% fill:[/b] Price reached consequent encroachment.
[*][b]Close through:[/b] A candle closed beyond the far edge.
[*][b]Expiry:[/b] Gaps left unfilled for longer than the bar limit are removed. Mitigated gaps can stay on the chart, faded.
[/list]

[b]4 — Higher-Timeframe Gaps[/b]

[list]
[*][b]Completed Candles Only:[/b] HTF gaps use the last three completed candles of the [i]Higher timeframe[/i] (no lookahead), so a daily fair value gap appears once the daily candle that completes it has closed.
[/list]
[/quote]

🔵 [b]HOW TO USE[/b]

[quote]
Beyond marking imbalances, you can use the indicator in several ways:

[list=1]
[*][b]Support and Resistance Zones:[/b] Watch fresh bullish FVGs as possible support on pullbacks, and bearish FVGs as possible resistance.
[*][b]Fair Value Gap Entries:[/b] Many traders watch the first return into a gap and its 50% line. The "% filled" label shows how deep price has already gone.
[*][b]Multi-Timeframe Map:[/b] Turn on HTF gaps (for example 4H on a 15m chart) to see which gaps matter on the bigger picture.
[*][b]Match Your Definition:[/b] Pick the mitigation rule that fits how you trade gaps. "Close through" keeps gaps longer than "50% fill".
[*][b]Read the Statistics:[/b] If most gaps on your symbol get fully filled within a few bars, trading away from them is less reliable there.
[/list]
[/quote]

🔵 [b]SETTINGS[/b]

[quote]
[list]
[*][b]Detection:[/b] [i]Minimum gap size[/i], [i]Displacement[/i], [i]ATR length[/i], [i]Gap is mitigated on[/i], [i]Max active gaps per side[/i], [i]Expire unfilled gaps after[/i].
[*][b]Higher-timeframe gaps:[/b] on/off and [i]Higher timeframe[/i].
[*][b]Display:[/b] bullish/bearish toggles, colours, 50% line, live fill %, keep mitigated gaps, statistics table and position.
[/list]
[/quote]

🔵 [b]ALERTS[/b]

[quote]
[list]
[*][b]New bullish / bearish FVG:[/b] a qualified gap has just formed.
[*][b]Price returned to bullish / bearish FVG:[/b] the first touch back into a gap.
[*][b]FVG mitigated:[/b] a gap met your mitigation rule.
[/list]

All alerts fire once per bar close.
[/quote]

🔵 [b]NOTES[/b]

[quote]
[b]Why this implementation is unique:[/b]

[list]
[*]Displacement and ATR-size filters remove most of the noise that plain FVG scripts plot.
[*]A live fill percentage on every open gap, not just an on/off state.
[*]Three mitigation definitions in one tool.
[*]Non-repainting higher-timeframe gaps built only from completed candles.
[*]A revisit and mitigation record, so you can judge FVG behaviour on your own market.
[/list]

[b]Limitations:[/b]

[list]
[*]A gap is confirmed only when its third candle closes, so it appears one bar after the displacement candle.
[*]Higher-timeframe gaps are drawn from the moment their HTF candle closes, not back in time.
[*]The statistics count chart-timeframe gaps only. They describe this chart's past and do not predict future fills.
[*]The maximum number of active gaps per side caps the boxes, and the oldest gaps are removed first.
[/list]

This script is for education and analysis. It does not give financial advice.
[/quote]

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// (c) viprasol
indicator("Fair Value Gap Indicator with Fill Tracking and HTF Gaps [Viprasol]", "Fair Value Gap [Viprasol]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 200)

// ============================================================ inputs
G_DET = "Detection"
minGapAtr  = input.float(0.25, "Minimum gap size (x ATR)", minval = 0.0, step = 0.05, group = G_DET, tooltip = "Gaps smaller than this fraction of ATR are ignored as noise.")
dispBody   = input.float(0.6, "Displacement: middle candle body >= (x ATR)", minval = 0.0, step = 0.1, group = G_DET, tooltip = "The candle that creates the gap must be a real displacement move. Set 0 to accept every three-candle imbalance.")
atrLen     = input.int(14, "ATR length", minval = 1, group = G_DET)
mitigation = input.string("Full fill", "Gap is mitigated on", options = ["Full fill", "50% fill (consequent encroachment)", "Close through"], group = G_DET)
maxGaps    = input.int(30, "Max active gaps per side", minval = 1, maxval = 100, group = G_DET)
maxAge     = input.int(300, "Expire unfilled gaps after (bars)", minval = 10, group = G_DET)

G_HTF = "Higher-timeframe gaps"
useHtf = input.bool(false, "Show higher-timeframe FVGs", group = G_HTF)
htf    = input.timeframe("240", "Higher timeframe", group = G_HTF, tooltip = "Only completed higher-timeframe candles are used (no lookahead), so HTF gaps appear when the HTF candle closes.")

G_VIS = "Display"
showBull  = input.bool(true, "Bullish gaps", group = G_VIS, inline = "dir")
showBear  = input.bool(true, "Bearish gaps", group = G_VIS, inline = "dir")
bullCol   = input.color(color.new(#26a69a, 75), "Bullish", group = G_VIS, inline = "col")
bearCol   = input.color(color.new(#ef5350, 75), "Bearish", group = G_VIS, inline = "col")
htfBull   = input.color(color.new(#2962ff, 80), "HTF bullish", group = G_VIS, inline = "col2")
htfBear   = input.color(color.new(#ff9800, 80), "HTF bearish", group = G_VIS, inline = "col2")
showMid   = input.bool(true, "Show 50% line (consequent encroachment)", group = G_VIS)
showFill  = input.bool(true, "Show live fill % on each gap", group = G_VIS)
keepFilled = input.bool(false, "Keep mitigated gaps on chart (faded)", group = G_VIS)
showStats = input.bool(true, "Show fill statistics table", group = G_VIS)
tablePos  = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = G_VIS)

// ============================================================ types
type Gap
    float top
    float bot
    bool  bull
    bool  htf
    int   born
    float deepest            // furthest price traded back into the gap
    bool  touched = false
    box   bx      = na
    line  mid     = na

// ============================================================ state
var array<Gap> gaps = array.new<Gap>()
// statistics: [chart bull, chart bear]
var array<int> nBorn  = array.from(0, 0)
var array<int> nTouch = array.from(0, 0)
var array<int> nMit   = array.from(0, 0)
var array<int> sumBarsToMit = array.from(0, 0)

float atr = ta.atr(atrLen)

// ============================================================ helpers
fillPct(Gap g) =>
    float size = g.top - g.bot
    size > 0 ? math.min(100.0, 100.0 * (g.bull ? g.top - g.deepest : g.deepest - g.bot) / size) : 0.0

gapColor(bool bull, bool isHtf) => isHtf ? (bull ? htfBull : htfBear) : (bull ? bullCol : bearCol)

newGap(float top, float bot, bool bull, bool isHtf, int leftBar) =>
    color c  = gapColor(bull, isHtf)
    box   bx = box.new(leftBar, top, bar_index, bot, border_color = color.new(c, 40), bgcolor = c, extend = extend.right, text = isHtf ? "HTF " + htf : "", text_size = size.tiny, text_color = color.new(color.gray, 20), text_halign = text.align_right)
    line  md = showMid ? line.new(leftBar, (top + bot) / 2, bar_index, (top + bot) / 2, extend = extend.right, color = color.new(c, 20), style = line.style_dotted) : na
    gaps.push(Gap.new(top = top, bot = bot, bull = bull, htf = isHtf, born = bar_index, deepest = bull ? top : bot, bx = bx, mid = md))
    // cap the number of active gaps per side and type
    int count  = 0
    int oldest = -1
    for i = 0 to gaps.size() - 1
        Gap q = gaps.get(i)
        if q.bull == bull and q.htf == isHtf
            count += 1
            if oldest == -1
                oldest := i
    if count > maxGaps and oldest >= 0
        Gap o = gaps.remove(oldest)
        o.bx.delete()
        if not na(o.mid)
            o.mid.delete()
    true

retire(Gap g, bool mitigated) =>
    if mitigated and keepFilled
        g.bx.set_extend(extend.none)
        g.bx.set_right(bar_index)
        g.bx.set_bgcolor(color.new(color.gray, 90))
        g.bx.set_border_color(color.new(color.gray, 70))
        g.bx.set_text("")
        if not na(g.mid)
            g.mid.set_extend(extend.none)
            g.mid.set_x2(bar_index)
    else
        g.bx.delete()
        if not na(g.mid)
            g.mid.delete()
    true

// ============================================================ HTF data (completed candles only)
// Values of the last three COMPLETED HTF candles: offsets [1],[2],[3] with lookahead_on do not repaint.
[hH1, hL1, hH3, hL3, hT] = request.security(syminfo.tickerid, htf, [high[1], low[1], high[3], low[3], time[1]], lookahead = barmerge.lookahead_on)
bool htfValid = useHtf and timeframe.in_seconds(htf) > timeframe.in_seconds()
bool htfNew   = htfValid and not na(hT) and hT != hT[1]

// ============================================================ main (bar close only)
bool bullNew = false
bool bearNew = false
bool bullMit = false
bool bearMit = false
bool bullTap = false
bool bearTap = false

if barstate.isconfirmed and not na(atr)
    // --- chart-timeframe gaps: candle 1 = [2], displacement candle = [1], candle 3 = current
    float body1 = math.abs(close[1] - open[1])
    if showBull and low > high[2] and low - high[2] >= minGapAtr * atr and body1 >= dispBody * atr and close[1] > open[1]
        newGap(low, high[2], true, false, bar_index - 2)
        nBorn.set(0, nBorn.get(0) + 1)
        bullNew := true
    if showBear and high < low[2] and low[2] - high >= minGapAtr * atr and body1 >= dispBody * atr and close[1] < open[1]
        newGap(low[2], high, false, false, bar_index - 2)
        nBorn.set(1, nBorn.get(1) + 1)
        bearNew := true
    // --- higher-timeframe gaps from the last three completed HTF candles
    if htfNew
        if showBull and hL1 > hH3
            newGap(hL1, hH3, true, true, bar_index)
        if showBear and hH1 < hL3
            newGap(hL3, hH1, false, true, bar_index)

    // --- update fill / mitigation of every active gap
    int n = gaps.size()
    if n > 0
        for i = n - 1 to 0
            Gap g = gaps.get(i)
            if g.born == bar_index and not g.htf
                continue
            g.deepest := g.bull ? math.min(g.deepest, low) : math.max(g.deepest, high)
            bool  inside = g.bull ? low <= g.top : high >= g.bot
            float pct    = fillPct(g)
            if inside and not g.touched
                g.touched := true
                if not g.htf
                    nTouch.set(g.bull ? 0 : 1, nTouch.get(g.bull ? 0 : 1) + 1)
                if g.bull
                    bullTap := true
                else
                    bearTap := true
            bool mitigated = switch mitigation
                "Full fill"                          => pct >= 100.0
                "50% fill (consequent encroachment)" => pct >= 50.0
                => g.bull ? close < g.bot : close > g.top
            if mitigated
                if not g.htf
                    int k = g.bull ? 0 : 1
                    nMit.set(k, nMit.get(k) + 1)
                    sumBarsToMit.set(k, sumBarsToMit.get(k) + (bar_index - g.born))
                if g.bull
                    bullMit := true
                else
                    bearMit := true
                retire(g, true)
                gaps.remove(i)
            else if bar_index - g.born > maxAge
                retire(g, false)
                gaps.remove(i)
            else if showFill
                g.bx.set_text((g.htf ? "HTF " + htf + "  " : "") + (pct > 0 ? str.tostring(pct, "#") + "% filled" : ""))

// ============================================================ statistics
var table tbl = na
if showStats and barstate.islast
    if na(tbl)
        string pos = tablePos == "Top right" ? position.top_right : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Top left" ? position.top_left : position.bottom_left
        tbl := table.new(pos, 3, 6, bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 60), border_width = 1)
    color hdr = color.new(color.gray, 30)
    table.cell(tbl, 0, 0, "Chart-TF gaps", text_color = color.white, bgcolor = hdr, text_size = size.small)
    table.cell(tbl, 1, 0, "Bullish", text_color = color.white, bgcolor = hdr, text_size = size.small)
    table.cell(tbl, 2, 0, "Bearish", text_color = color.white, bgcolor = hdr, text_size = size.small)
    array<string> rows = array.from("Created", "Revisited", "Mitigated", "Avg bars to mitigate")
    for r = 0 to 3
        table.cell(tbl, 0, r + 1, rows.get(r), text_color = color.white, text_size = size.small)
        for k = 0 to 1
            string v = switch r
                0 => str.tostring(nBorn.get(k))
                1 => nBorn.get(k) > 0 ? str.tostring(100.0 * nTouch.get(k) / nBorn.get(k), "#") + "%" : "-"
                2 => nBorn.get(k) > 0 ? str.tostring(100.0 * nMit.get(k) / nBorn.get(k), "#") + "%" : "-"
                => nMit.get(k) > 0 ? str.tostring(sumBarsToMit.get(k) / nMit.get(k), "#") : "-"
            table.cell(tbl, k + 1, r + 1, v, text_color = color.white, text_size = size.small)
    table.cell(tbl, 0, 5, "Mitigation rule: " + mitigation + ". Historical counts on this chart only.", text_color = color.gray, text_size = size.tiny)
    table.merge_cells(tbl, 0, 5, 2, 5)

// ============================================================ alerts
alertcondition(bullNew, "New bullish FVG", "New bullish fair value gap on {{ticker}} {{interval}}")
alertcondition(bearNew, "New bearish FVG", "New bearish fair value gap on {{ticker}} {{interval}}")
alertcondition(bullTap, "Price returned to bullish FVG", "Price returned into a bullish fair value gap on {{ticker}} {{interval}}")
alertcondition(bearTap, "Price returned to bearish FVG", "Price returned into a bearish fair value gap on {{ticker}} {{interval}}")
alertcondition(bullMit or bearMit, "FVG mitigated", "A fair value gap was mitigated on {{ticker}} {{interval}}")
if bullNew or bearNew or bullTap or bearTap
    alert(syminfo.ticker + " " + timeframe.period + ": " + (bullNew ? "new bullish FVG " : "") + (bearNew ? "new bearish FVG " : "") + (bullTap ? "price in bullish FVG " : "") + (bearTap ? "price in bearish FVG" : ""), alert.freq_once_per_bar_close)
````
