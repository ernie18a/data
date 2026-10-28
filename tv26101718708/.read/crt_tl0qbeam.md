# $ - CRT +

- url: https://www.tradingview.com/script/Tl0QbeaM-CRT/
- type: indicator
- pine_id: PUB;7158b1ff004c4758919494a54f5e8f0f
- version: 1.0

## Description

[b]$ – CRT +[/b]

A Candle Range Theory execution tool built for trading higher timeframe continuations from the 1m chart. It outlines each HTF candle over your lower timeframe bars, measures how deep the new candle's opening wick retraces into the previous candle's body, and flags when a setup is invalidated. On the 1m it adds CISD, swing sweeps, breaks of structure and fair value gaps, so the whole process from HTF bias to LTF entry happens on one chart.

[b]HTF Candle[/b]
[list]
[*]HTF Boxes – a dashed outline around each HTF candle's high/low range (1H by default). The live candle's box expands in real time as new highs and lows print. Keep up to 20 boxes on the chart.
[*]HTF Candle – draws each HTF candle over its 1m bars as a hollow body from open to close with wicks to the high and low, coloured bullish or bearish. The live candle updates tick by tick. Adjustable line width. Drawn on 1m–5m charts only.
[*]Open line – marks the live HTF candle's open across its full period.
[*]Prev midline – a dotted line at the 50% of the previous HTF candle's range, drawn across the current one.
[*]Open tick – a short line marking each HTF candle's open.
[/list]

[b]Invalidation[/b]
The highest probability continuation candles tend to form their opening wick within the closest 30% of the previous candle's body. The probability of continuation drops significantly once the new candle retraces beyond the 50% level of that body.
[list]
[*]Invalidation Lines – when a new HTF candle opens, draws retracement levels measured on the previous candle's body (0% = its close, 100% = its open). After a bearish close the lines sit above the close, after a bullish close below it. Dojis get no lines.
[*]A+ / A – A+ is where the retrace should ideally stay under (30% by default). A is the maximum allowed retrace (50% by default). Both levels and colours are adjustable.
[*]⛔ when invalidated – places a ⛔ beyond the wick of the live HTF candle the moment price trades past the deeper level, and follows the wick as it extends. It means no continuation trade on this candle. Works with the lines toggled off.
[*]Only after ✅ close – only treats the previous candle as a setup if it passed the Close filter.
[*]Min body – skips previous candles whose body is smaller than a set number of pips.
[*]Previous / 1m only – keep lines on earlier candles, or draw them on the 1m chart only to keep higher timeframes clean. Levels are still tracked either way.
[/list]

[b]CISD[/b]
The previous HTF candle's colour sets the side. After a bearish close, a 1m candle must first close above the new candle's open (the top wick is forming). The first bearish 1m candle that then closes below the open of the most recent run of bullish candles is a bearish CISD. Bullish is the mirror.
[list]
[*]One-candle engulfs are ignored – the candle that sets the level needs at least one candle after it before the break counts.
[*]After the first CISD, every flip back the other way is drawn too.
[*]Only active in the first half of each HTF candle, and not after a doji.
[*]Extend 3 bars – carries the line 3 bars past the candle that closed through it.
[/list]

[b]1m Breaks[/b]
[list]
[*]Sweeps – when price wicks through a confirmed 1m swing high or low and closes back inside, a line is drawn from the swing. If a candle closes through that level within the next 2 bars, the sweep is recoloured as a break.
[*]Breaks – when price closes through a 1m swing, a break line is drawn from the swing to the breaking candle.
[*]Choose how many lines stay on the chart, the swing Left/Right strength, and the line style and width.
[*]Require Candle Closure – only closes through a swing trigger the BOS alerts. Wicks through are treated as sweeps.
[/list]

[b]Fair Value Gaps[/b]
[list]
[*]1m FVGs – detected at the close of the third candle and drawn from candle 1. Adjustable length, with an option to extend ahead of current price.
[*]Recolour once tapped – recolours a gap the moment price wicks into it, even by a tick.
[*]Delete on Fill – removes a gap once price closes through its far edge.
[*]Choose how many FVGs stay on the chart, plus separate fill and border colours.
[/list]

[b]Candle Stats[/b]
Above each candle on the chosen timeframe: its range in pips and the top wick as a % of the range. Below: the bottom wick %. The body % is whatever is left. The live candle updates as it develops. Values are measured in pips on forex pairs and in price points on all other markets.

[b]Invalidators[/b]
[list]
[*]Close filter – once each HTF candle closes, marks it ✅ if the wick beyond its close is at most the Max wick % of the range (20% by default), or ⚠️ if not. This is a caution, not an invalidation: ⚠️ just flags a less clean close.
[*]Doji – when an HTF candle closes with a body under the Max body % of its range (33% by default), the next candle is flagged with a ⚠️ at the top of its box.
[*]Small body – also treats a candle as a doji when its body is smaller than a set multiple of the average body of the last N HTF candles. Catches low displacement candles that aren't doji-shaped.
[*]Show icons / Previous candles / 1m only – hover any icon to see exactly why it was given. Checks still run in the background with icons off.
[/list]

[b]Alerts[/b]
[list]
[*]1m Bullish BOS
[*]1m Bearish BOS
[/list]

[b]How to Use[/b]
Apply to a 1m chart with the HTF timeframe set to 1H (or whichever candle you're trading). When an HTF candle closes, check its ✅ / ⚠️ mark. As the next candle opens, watch the opening wick form into the A+ zone of the previous body. If price trades past the A level and a ⛔ prints, there's no continuation trade on that candle. If it holds, look for a CISD in the direction of the previous candle during the first half of the HTF candle, using the 1m sweeps, breaks and FVGs to frame entries.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wintonbanks

//@version=6
indicator('$ - CRT +', overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 5000, explicit_plot_zorder = true)

// ═══════════════════════════════════════════════════════════════════════════════
// HTF Candle   (drawings only)
// ═══════════════════════════════════════════════════════════════════════════════
var string G_H1 = "HTF Candle  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

bxOn       = input.bool(true, "HTF Boxes", group = G_H1, inline = "box")
htfTf      = input.timeframe("60", "", group = G_H1, inline="box", tooltip = "Timeframe for the outlines, HTF candles and Open line.")

bxKeep     = input.int(20, "Boxes", minval = 1, maxval = 20, group = G_H1, inline = "box1", tooltip = "Dashed outline around each HTF candle's high/low range. The live candle's box expands as its high/low develops.\n\nKeep — how many outlines stay on the chart.")
bxCol      = input.color(color.new(#706c69, 80), "", group = G_H1, inline = "box1")

htfOn      = input.bool(false, "HTF Candle", group = G_H1, inline = "htf")
showOpenLn = input.bool(false,  "Open line", group = G_H1, inline = "htf")
htfW       = input.int(1, "Width", minval = 1, maxval = 5, group = G_H1, inline = "htf1", tooltip = "Draws each HTF candle over the 1m bars: a hollow body from open to close with wicks to the high and low. The live candle updates tick by tick. Colours: bullish, bearish. Width sets the line thickness of the body and wicks. Uses the same Keep count as the outlines. Drawn on 1m–5m charts only.")
htfUp      = input.color(color.new(#089981, 80), "", group = G_H1, inline = "htf1")
htfDn      = input.color(color.new(#f23645, 80), "", group = G_H1, inline = "htf1")
midOn = input.bool(false, "Prev midline", group = G_H1, inline = "lv")
ocOn  = input.bool(false, "Open tick", group = G_H1, inline = "lv")
ocCol = input.color(#9c9c9c, "", group = G_H1, inline = "lv", tooltip = "Prev midline\nDotted line at the 50% of the previous candle, drawn across the current one.\n\nOpen tick\nShort line at each candle's open, 5 bars wide.\n\nBoth use the timeframe and Keep count above, and work with HTF Boxes / HTF Candle off.")

// ═══════════════════════════════════════════════════════════════════════════════
// Invalidation
// ═══════════════════════════════════════════════════════════════════════════════
var string G_INV = "Invalidation  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

invOn   = input.bool(true, "Invalidation Lines", group = G_INV, inline = "inv", tooltip = "Statistically, the highest probability Continuation candles will form the opening wick within the closest 30% of the previous candle's body. The probability of a candle continuing in the same direction drops significally if the new candle opens and retraces back above the 50% level of the previous candles body.\n\nInvalidation Lines\nThis draws lines onto the chart to visually depict the 30% adn 50% levels of the previous HTF candle's body.")
invPrev = input.bool(false, "Previous", group = G_INV, inline = "inv")
inv1m   = input.bool(true, "1m only", group = G_INV, inline = "inv")
invLnC  = input.color(color.new(#d1d4dc, 40), "", group = G_INV, inline = "inv.")
invW    = input.int(1, "Width", minval = 1, maxval = 5, group = G_INV, inline = "inv.", tooltip = "Invalidation lines\nWhen a new HTF candle opens, draws retracement levels measured on the PREVIOUS candle's BODY: 0% is its close, 100% is its open. After a bearish close the lines sit above the close (how far the top wick may push), after a bullish close below it. Dojis get no lines.\n\nPrevious candles — off: lines show on the live candle only and are cleared when the next one opens. On: earlier candles keep theirs too (up to the HTF Candle Keep count).\n\n1m only — lines are drawn on the 1m chart only, to keep higher timeframes clean. The levels are still tracked, so the retrace ⛔ works either way.\n\nUses the HTF Candle timeframe.")
invAp   = input.float(30, "A+", minval = 1, maxval = 100, step = 5, group = G_INV, inline = "inv1")
invApC  = input.color(#089981, "", group = G_INV, inline = "inv1")
invA    = input.float(50, "A", minval = 1, maxval = 100, step = 5, group = G_INV, inline = "inv1")
invAC   = input.color(#ff9800, "", group = G_INV, inline = "inv1", tooltip = "A+ — the retrace should ideally stay under this level (default 30%).\nA — the maximum allowed retrace (default 50%). Price trading beyond this line invalidates the continuation.")
invX    = input.bool(false, "⛔ when invalidated", group = G_INV, inline = "inv3", tooltip = "Places ⛔ at the middle of the live HTF candle, beyond its wick (above the top wick after a bearish close, below the bottom wick after a bullish close), the moment price trades past the worst-case level (whichever of A+ / A is deeper). It follows the wick as it extends and means: no continuation trade on this candle.\n\nWorks with the lines toggled off too.")
invFilt = input.bool(false, "Only after ✅ close", group = G_INV, inline = "inv2")
invMin  = input.float(0, "Min body", minval = 0, step = 1, group = G_INV, inline = "inv2", tooltip = "Only after ✅ close — only treat the previous candle as a setup when it passes the Close filter in Invalidators (uses its Max wick % setting).\n\nMin body — skip previous candles whose body is smaller than this, in pips (forex = 10 ticks, everything else = 1 point). 0 = off.\n\nCandles that fail either check get no lines and no ⛔.")

// ═══════════════════════════════════════════════════════════════════════════════
// CISD
// ═══════════════════════════════════════════════════════════════════════════════
var string G_CD = "CISD  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cdOn   = input.bool(false, "CISD", group = G_CD, inline = "cd")
cdBull = input.color(#5b9cf6, "", group = G_CD, inline = "cd")
cdBear = input.color(#5b9cf6, "", group = G_CD, inline = "cd")
cdW    = input.int(3, "Width", minval = 1, maxval = 5, group = G_CD, inline = "cd")
cdExt  = input.bool(false, "Extend 3 bars", group = G_CD, tooltip = "CISD\nThe previous HTF candle's colour sets the side. After a bearish close, a 1m candle must first close ABOVE the new candle's open (the top wick is forming). The first bearish 1m candle that then closes below the open of the most recent run of bullish candles is a bearish CISD. Bullish is the mirror.\n\nThe candle that sets the level needs at least one candle after it before the break. If the very next candle closes through the level, that's a one-candle engulf, not a CISD, and the level is dropped. A later close through it won't count either; a new run has to form.\n\nAfter the first one, every flip back the other way is drawn too.\n\nOnly works in the first half of each HTF candle, and not after a doji.\n\nColours: bullish CISD, bearish CISD.\n\nExtend 3 bars — carries the line 3 bars past the candle that closed through it.")

// ═══════════════════════════════════════════════════════════════════════════════
// 1m Breaks
// ═══════════════════════════════════════════════════════════════════════════════
var string G_BOS = "1m Breaks  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

bosCol   = input.color(#4a4a4a, "",   inline = "breaktoggle", group = G_BOS)
bosOn    = input.bool(false,  "Breaks", group = G_BOS, inline = "breaktoggle")
swCol    = input.color(#f23645, "",   inline = "breaktoggle", group = G_BOS)
swOn     = input.bool(true, "Sweeps",  group = G_BOS, inline = "breaktoggle")
bosShow  = input.string("3 Lines", "", options = ["1 Line","2 Lines","3 Lines","4 Lines","5 Lines","Show All"], inline = "breaktoggle", group = G_BOS)

pvtL     = input.int(1, "Left", minval = 1, inline = "p", group = G_BOS)
pvtR     = input.int(1, "Right", minval = 1, inline = "p", group = G_BOS, tooltip = "Bars left/right required to confirm a 1m swing.")

bosStyle = input.string("Solid", "", options = ["Solid","Dashed","Dotted"], inline = "bs", group = G_BOS)
bosW     = input.int(2, "", minval = 1, inline = "bs", group = G_BOS)

reqClose = input.bool(true, "Require Candle Closure", group = G_BOS, tooltip = "A wick through a swing that closes back inside is a SWEEP, not a break. With this on, only closes through count for the 1m BOS alerts — the sweep still draws.")

sweepRecheck = true
sweepBars    = 2

// ═══════════════════════════════════════════════════════════════════════════════
// Fair Value Gaps
// ═══════════════════════════════════════════════════════════════════════════════
var string G_FVG = "Fair Value Gaps  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

fvg1On    = input.bool(true,  "1m",     inline = "f1.1", group = G_FVG)
fvgExt1   = input.bool(false, "Extend", inline = "f1.1", group = G_FVG)
fvgLen1   = input.int(2, "Length", minval = 1, inline = "f1.1", group = G_FVG, tooltip = "1m — show 1m FVG's.\n\nExtend — extends the FVG's slightly ahead of current price.\n\nLength — box width in 1m bars. At 1 the box spans candle 1 → candle 3.")

fvg1Bull  = input.color(color.new(#f23645, 67), "", inline = "f1.2", group = G_FVG)
fvg1BullB = input.color(color.new(#f23645, 40), "", inline = "f1.2", group = G_FVG)
fvg1Bear  = input.color(color.new(#f23645, 67), "", inline = "f1.2", group = G_FVG)
fvg1BearB = input.color(color.new(#f23645, 40), "", inline = "f1.2", group = G_FVG)
fvg1Show  = input.string("3 FVGs", "", options = ["1 FVG","2 FVGs","3 FVGs","4 FVGs","5 FVGs","Show All"], inline = "f1.2", group = G_FVG)

showMitF  = input.bool(true, "Recolour FVG once tapped", inline = "recol", group = G_FVG, tooltip = "Recolour a gap the moment price wicks into the zone at all, even by a tick. Not the same as filled: filled means price closed through the far edge, which deletes the box.\n\nColours: box, then border.")
cMitFBg   = input.color(color.new(#4a4a4a, 67), "", inline = "recol", group = G_FVG)
cMitFBr   = input.color(color.new(#4a4a4a, 34), "", inline = "recol", group = G_FVG)
delFill   = input.bool(true, "Delete FVG on Fill", group = G_FVG)

// ═══════════════════════════════════════════════════════════════════════════════
// Candle Stats
// ═══════════════════════════════════════════════════════════════════════════════
var string G_CS = "Candle Stats  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

csOn = input.bool(false, "Candle stats", group = G_CS, inline = "cs")
csTf = input.timeframe("60", "", group = G_CS, inline = "cs", tooltip = "Above each candle: its range in pips, then the top wick as a % of the range.\nBelow: the bottom wick %.\nBody % is whatever's left (100 − top − bottom).\n\nThe live candle updates as it develops.\n\nPips: forex = 10 ticks, everything else = 1 point.")

// ═══════════════════════════════════════════════════════════════════════════════
// Invalidators
// ═══════════════════════════════════════════════════════════════════════════════
var string G_WF = "Invalidators  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ivIcons = input.bool(false, "Show icons", group = G_WF, inline = "ic")
icPrev  = input.bool(false, "Previous candles", group = G_WF, inline = "ic")
ic1m    = input.bool(true, "1m only", group = G_WF, inline = "ic", tooltip = "Shows the ✅ / ⚠️ close marks and the doji ⛔ on the chart. Hover any icon to see why it was given.\n\nOff — the checks still run in the background (a doji still hides the Invalidation lines, Only after ✅ close still works), nothing is drawn.\n\nThe retrace ⛔ has its own toggle in the Invalidation group.\n\nPrevious candles — off: only the icons for the trade you're on show: the ✅ / ❌ on the candle that just closed, and any ⛔ on the live candle. They clear when the next candle opens. On: older candles keep theirs too.\n\n1m only — icons (including the retrace ⛔ from the Invalidation group) are drawn on the 1m chart only, to keep higher timeframes clean.")

wfOn  = input.bool(true, "Close filter", group = G_WF, inline = "wf")
wfMax = input.float(20, "Max wick %", minval = 0, maxval = 100, step = 1, group = G_WF, inline = "wf")
wfTf  = input.timeframe("60", "", group = G_WF, inline = "wf", tooltip = "Once each candle closes, marks it ✅ if the wick beyond its close (top wick on a bullish candle, bottom wick on a bearish one) is at most this % of the candle's range, ⚠️ if not. Dojis get ⚠️.\n\nThis is a caution, not an invalidation: ⚠️ just flags a less clean close. The mark sits on the wick being judged. Works whether or not Candle stats is on. Drawn only with Show icons on.")

djOn   = input.bool(true, "Doji", group = G_WF, inline = "dj")
djMax  = input.float(33, "Max body %", minval = 0, maxval = 100, step = 1, group = G_WF, inline = "dj")
djHide = input.bool(true, "Hide lines", group = G_WF, inline = "dj", tooltip = "Doji\nWhen an HTF candle closes with its body under this % of its range (open = close always counts), the next HTF candle is invalidated: no continuation trade this candle. With Show icons on, it gets a ⛔ at the top centre of its box, beyond the high, from the moment it opens; hover it to see the doji's numbers. Measured as a % so it works on every instrument.\n\nHide lines — no Invalidation lines (and no retrace ⛔) on a candle that follows a doji.\n\nUses the HTF Candle timeframe, and the Previous candles toggle next to Show icons decides whether older doji ⛔ marks stay.")
djRel  = input.bool(false, "Small body", group = G_WF, inline = "dj2")
djRelX = input.float(0.5, "under ×", minval = 0.05, step = 0.05, group = G_WF, inline = "dj2")
djLen  = input.int(20, "avg of", minval = 1, maxval = 100, group = G_WF, inline = "dj2", tooltip = "Small body — also treat a candle as a doji when its body is smaller than this multiple of the average body of the previous N HTF candles (e.g. under 0.5 × the last 20). Catches small, low-displacement candles that aren't doji-shaped. A ratio, so it works on every instrument.\n\nNeeds N HTF candles of history before it kicks in.")
djCisd = input.bool(false, "Skip CISD after doji", group = G_WF, inline = "dj3", tooltip = "No CISD lines are drawn on a candle that follows a doji.")

///////////////////
// Calculating
///////////////////
isChart1m  = timeframe.in_seconds(timeframe.period) == 60
iconTfOk   = not ic1m or isChart1m      // icons allowed on this chart timeframe
showIcons  = ivIcons and iconTfOk
isChartLTF = timeframe.in_seconds(timeframe.period) <= 900
isHTFchart = timeframe.in_seconds(timeframe.period) <= 900
isLe5m     = timeframe.in_seconds(timeframe.period) <= 300     // HTF Candle drawings: 1m–5m charts only
chartMs    = timeframe.in_seconds(timeframe.period) * 1000
fvgExtLead = 7 * chartMs

styleOf(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

keepN = switch bosShow
    "1 Line"  => 1
    "2 Lines" => 2
    "3 Lines" => 3
    "4 Lines" => 4
    "5 Lines" => 5
    => 500

fvgKeep = switch fvg1Show
    "1 FVG"  => 1
    "2 FVGs" => 2
    "3 FVGs" => 3
    "4 FVGs" => 4
    "5 FVGs" => 5
    => 500

// ═══════════════════════════════════════════════════════════════════════════════
// 1m BREAK OF STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════════
var float prevH  = na
var float prevL  = na
var int   prevHT = 0
var int   prevLT = 0
var bool  hPres  = false
var bool  lPres  = false

var array<line> bosLines = array.new<line>()

type SweepWatch
    line  ln
    float level
    bool  isHigh
    int   left

var array<SweepWatch> sweepWatch = array.new<SweepWatch>()

drawBreak(price, fromT, isSwp, isHigh) =>
    c  = (swOn and isSwp) ? swCol : bosCol
    ln = line.new(fromT, price, time, price, xloc = xloc.bar_time, color = c, style = styleOf(bosStyle), width = bosW)
    array.push(bosLines, ln)
    while array.size(bosLines) > keepN
        dropped = array.shift(bosLines)
        if array.size(sweepWatch) > 0
            for wi = array.size(sweepWatch) - 1 to 0
                if array.get(sweepWatch, wi).ln == dropped
                    array.remove(sweepWatch, wi)
        line.delete(dropped)
    if swOn and isSwp and sweepRecheck
        array.push(sweepWatch, SweepWatch.new(ln, price, isHigh, sweepBars))
    ln

bool hiBreak = false
bool loBreak = false
bool sweep   = false

// Sweep → Break review. Runs BEFORE detection so a sweep isn't checked on its own bar.
if isChart1m and barstate.isconfirmed and array.size(sweepWatch) > 0
    for wi = array.size(sweepWatch) - 1 to 0
        w = array.get(sweepWatch, wi)
        if (w.isHigh ? close > w.level : close < w.level)
            line.set_color(w.ln, bosCol)
            array.remove(sweepWatch, wi)
        else
            w.left := w.left - 1
            if w.left <= 0
                array.remove(sweepWatch, wi)

if isChart1m
    ph = ta.pivothigh(high, pvtL, pvtR)
    pl = ta.pivotlow(low,  pvtL, pvtR)
    if not na(ph)
        prevH  := ph
        prevHT := time[pvtR]
        hPres  := true
    if not na(pl)
        prevL  := pl
        prevLT := time[pvtR]
        lPres  := true
    if hPres and high > prevH
        hiBreak := true
        hPres   := false
        sweep   := close <= prevH
    if lPres and low < prevL
        loBreak := true
        lPres   := false
        sweep   := close >= prevL
    if bosOn
        if hiBreak
            drawBreak(prevH, prevHT, sweep, true)
        if loBreak
            drawBreak(prevL, prevLT, sweep, false)

bullBOS = hiBreak and (not reqClose or not sweep)
bearBOS = loBreak and (not reqClose or not sweep)

alertcondition(bullBOS, "1m Bullish BOS", "1m bullish break of structure")
alertcondition(bearBOS, "1m Bearish BOS", "1m bearish break of structure")

// ═══════════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
//   Detected natively on the 1m chart at the close of candle 3.
// ═══════════════════════════════════════════════════════════════════════════════
type FVG
    box   bx
    float top
    float bot
    bool  bull
    color col
    color brd
    int   state = 0    // 0 untapped, 1 tapped

var array<FVG> fvgs = array.new<FVG>()

f_fvg_bg(FVG f) => (showMitF and f.state >= 1) ? cMitFBg : f.col
f_fvg_br(FVG f) => (showMitF and f.state >= 1) ? cMitFBr : f.brd

fvgPaint(FVG f) =>
    box.set_bgcolor(f.bx, f_fvg_bg(f))
    box.set_border_color(f.bx, f_fvg_br(f))

makeFVG(bull, top, bot) =>
    int   lX  = time[2]                       // candle 1's open time
    int   rX  = time[1] + fvgLen1 * 60000     // candle 2 + Length bars
    color col = bull ? fvg1Bull  : fvg1Bear
    color brd = bull ? fvg1BullB : fvg1BearB
    bx = box.new(lX, top, rX, bot, xloc = xloc.bar_time, bgcolor = col, border_color = brd, border_width = 1)
    array.push(fvgs, FVG.new(bx, top, bot, bull, col, brd, 0))

if isChart1m and fvg1On and barstate.isconfirmed
    bool fBull = low  > high[2]
    bool fBear = high < low[2]
    if fBull
        makeFVG(true, low, high[2])
    else if fBear
        makeFVG(false, low[2], high)

// ── Maintenance: tap recolour, extend, delete on fill ────────────────
if array.size(fvgs) > 0
    for i = array.size(fvgs) - 1 to 0
        FVG f = array.get(fvgs, i)

        if f.state == 0 and (f.bull ? low < f.top : high > f.bot)
            f.state := 1
            fvgPaint(f)

        if fvgExt1 and time + fvgExtLead > box.get_right(f.bx)
            box.set_right(f.bx, time + fvgExtLead)

        bool filled = f.bull ? close <= f.bot : close >= f.top
        if filled and delFill and barstate.isconfirmed
            box.delete(f.bx)
            array.remove(fvgs, i)

// Count trim — newest kept, oldest dropped.
if array.size(fvgs) > 0
    int kept = 0
    for i = array.size(fvgs) - 1 to 0
        FVG f = array.get(fvgs, i)
        if kept >= fvgKeep
            box.delete(f.bx)
            array.remove(fvgs, i)
        else
            kept += 1

// Hard cap so the drawing budget is never blown.
while array.size(fvgs) > 100
    FVG old = array.shift(fvgs)
    box.delete(old.bx)

// ═══════════════════════════════════════════════════════════════════════════════
// HTF drawings
// ═══════════════════════════════════════════════════════════════════════════════

// ── HTF tracking ─────────────────────────────────────────────────────
newD = isHTFchart and timeframe.change(htfTf)

var float d_o  = na
var float d_h  = na
var float d_l  = na
var int   d_ot = na
var int   d_ct = na
var float pd_h = na     // previous HTF candle's high / low, for the midline
var float pd_l = na
var float pd_o = na     // previous HTF candle's open / close, for the invalidation lines
var float pd_c = na
var int   pd_dir = 0    // previous HTF candle's colour, for CISD

if newD
    pd_h := d_h, pd_l := d_l
    pd_o := d_o, pd_c := close[1]
    pd_dir := na(d_o) ? 0 : close[1] > d_o ? 1 : close[1] < d_o ? -1 : 0
    d_o := open, d_h := high, d_l := low, d_ot := time
    d_ct := nz(time_close(htfTf), time + timeframe.in_seconds(htfTf) * 1000) - chartMs
else if not na(d_o)
    d_h := math.max(d_h, high), d_l := math.min(d_l, low)

// ── Doji check on the previous HTF candle ────────────────────────────
tfLabel(string tf) =>
    int sec = timeframe.in_seconds(tf)
    sec % 86400 == 0 ? str.tostring(sec / 86400) + "D" : sec % 3600 == 0 ? str.tostring(sec / 3600) + "H" : str.tostring(sec / 60) + "m"

htfName = tfLabel(htfTf)

var bool   pdDoji = false                       // the candle that just closed was a doji
var string djWhy  = ""                          // hover text for its ⛔
var array<float> htfBodies = array.new<float>() // recent HTF body sizes, for the Small body check

if newD
    pdDoji := false
    if not na(pd_o) and not na(pd_h)
        float djB  = math.abs(pd_c - pd_o)
        float djR  = pd_h - pd_l
        float djBp = djR > 0 ? djB / djR * 100 : 0.0
        bool  djSm = false
        if djRel and htfBodies.size() >= djLen
            float djAvg = htfBodies.avg()
            djSm := djAvg > 0 and djB < djRelX * djAvg
        pdDoji := djOn and (pd_dir == 0 or djBp < djMax or djSm)
        if pdDoji
            string why = pd_dir == 0 ? "open = close" : djBp < djMax ? "body only " + str.tostring(djBp, "#") + "% of its range (doji = under " + str.tostring(djMax, "#.#") + "%)" : "body " + str.tostring(djB, format.mintick) + ", under " + str.tostring(djRelX, "#.##") + " × the " + str.tostring(djLen) + "-candle average (" + str.tostring(htfBodies.avg(), format.mintick) + ")"
            djWhy := "⚠️ Trade with caution\nThe previous " + htfName + " candle closed as a doji: " + why + ".\nIf it's an obvious sweep doji, this is higher probability."
        htfBodies.push(djB)
        while htfBodies.size() > djLen
            htfBodies.shift()

// ── HTF open line ────────────────────────────────────────────────────
var line opnLn = na

if isHTFchart and not na(d_ot)
    if showOpenLn
        if na(opnLn) or newD
            line.delete(opnLn)
            opnLn := line.new(d_ot, d_o, d_ct, d_o, xloc = xloc.bar_time, color = color.new(#9c9c9c, 40), width = 1, style = line.style_solid)
    else if not na(opnLn)
        line.delete(opnLn)
        opnLn := na

// ── HTF outlines ─────────────────────────────────────────────────────
var array<box> h1Bx = array.new<box>()

if bxOn and newD
    h1Bx.push(box.new(d_ot, d_h, d_ct, d_l, xloc = xloc.bar_time, bgcolor = na, border_color = bxCol, border_style = line.style_dashed, border_width = 1))
    while h1Bx.size() > bxKeep
        h1Bx.shift().delete()
else if bxOn and h1Bx.size() > 0
    h1Bx.last().set_top(d_h), h1Bx.last().set_bottom(d_l)

// ── HTF candle body + wicks ──────────────────────────────────────────
type HC
    box  bd
    line wu
    line wd

var array<HC> hcs = array.new<HC>()

if htfOn and isLe5m and not na(d_ot)
    int   mid = math.round((d_ot + d_ct) / 2)
    float bt  = math.max(d_o, close)
    float bb  = math.min(d_o, close)
    color col = close >= d_o ? htfUp : htfDn
    if newD
        hcs.push(HC.new(box.new(d_ot, bt, d_ct, bb, xloc = xloc.bar_time, bgcolor = na, border_color = col, border_width = htfW), line.new(mid, d_h, mid, bt, xloc = xloc.bar_time, color = col, width = htfW), line.new(mid, bb, mid, d_l, xloc = xloc.bar_time, color = col, width = htfW)))
        while hcs.size() > bxKeep
            HC x = hcs.shift()
            x.bd.delete(), x.wu.delete(), x.wd.delete()
    else if hcs.size() > 0
        HC o = hcs.last()
        o.bd.set_top(bt), o.bd.set_bottom(bb), o.bd.set_border_color(col)
        o.wu.set_y1(d_h), o.wu.set_y2(bt), o.wu.set_color(col)
        o.wd.set_y1(bb), o.wd.set_y2(d_l), o.wd.set_color(col)

// ── Previous candle midline ──────────────────────────────────────────
var array<line> midLns = array.new<line>()

if midOn and newD and not na(pd_h)
    float m = (pd_h + pd_l) / 2
    midLns.push(line.new(d_ot, m, d_ct, m, xloc = xloc.bar_time, color = color.new(#9c9c9c, 40), style = line.style_dotted, width = 1))
    while midLns.size() > bxKeep
        midLns.shift().delete()

// ── Open tick ────────────────────────────────────────────────────────
var array<line> ocLns = array.new<line>()

if ocOn and newD and isHTFchart
    ocLns.push(line.new(d_ot, d_o, d_ot + 4 * chartMs, d_o, xloc = xloc.bar_time, color = ocCol, width = 2))
    while ocLns.size() > bxKeep
        ocLns.shift().delete()

// ── Invalidation lines ───────────────────────────────────────────────
//   Measured on the previous HTF candle's BODY: 0% = its close, 100% = its open.
//   After a bearish close the levels sit above the close, after a bullish close below it.
//   One InvSet per HTF candle: its two lines, their labels, its retrace ⛔ and its doji ⛔.
type InvSet
    line  l1
    label t1
    line  l2
    label t2
    label mk
    label dj

var array<InvSet> invSets = array.new<InvSet>()
var float invLvl  = na      // worst-case level for the live candle
var int   invSide = 0       // previous candle's colour: -1 → watch highs, +1 → watch lows
var bool  invHit  = false   // the live candle has traded past invLvl

// Step markers clear of the Candle Stats text / close filter mark when they share this timeframe.
int    mkPad   = (csOn and csTf == htfTf ? 2 : 0) + (wfOn and showIcons and wfTf == htfTf ? 1 : 0)
string mkPadDn = mkPad == 0 ? "" : mkPad == 1 ? "\n " : mkPad == 2 ? "\n \n " : "\n \n \n "
string mkPadUp = mkPad == 0 ? "" : mkPad == 1 ? " \n" : mkPad == 2 ? " \n \n" : " \n \n \n"

invDel(InvSet s) =>
    line.delete(s.l1)
    label.delete(s.t1)
    line.delete(s.l2)
    label.delete(s.t2)
    label.delete(s.mk)
    label.delete(s.dj)

invDraw(float pct, color txtCol, string tag) =>
    float lvl = pd_c + (pd_o - pd_c) * pct / 100
    // Span the candle's third quarter: midpoint → 75%, so the label (drawn to its right) sits in the last quarter, inside the box.
    int   x1  = d_ot + math.floor((d_ct + chartMs - d_ot) * 0.50 / chartMs) * chartMs
    int   x2  = d_ot + math.floor((d_ct + chartMs - d_ot) * 0.75 / chartMs) * chartMs
    line  ln  = line.new(x1, lvl, x2, lvl, xloc = xloc.bar_time, color = invLnC, style = line.style_solid, width = invW)
    label lb  = label.new(x2, lvl, tag + " " + str.tostring(pct, "#.#") + "%", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100), textcolor = txtCol, size = size.small)
    [ln, lb]

// New HTF candle: clear old lines (unless Invalidation → Previous candles) and old ⛔
// (unless Invalidators → Previous candles), then set up the live one.
if newD and isHTFchart
    for os in invSets
        if not invPrev                // lines and their labels
            line.delete(os.l1), label.delete(os.t1), line.delete(os.l2), label.delete(os.t2)
        if not icPrev                 // retrace ⛔ and doji ⛔
            label.delete(os.mk), label.delete(os.dj)
    if not invPrev and not icPrev
        invSets.clear()
    invLvl  := na
    invSide := 0
    invHit  := false
    bool ok = false
    if pd_dir != 0 and not na(pd_o) and not na(pd_h)
        float pBody  = math.abs(pd_o - pd_c)
        float pRng   = pd_h - pd_l
        float pCsw   = pRng > 0 ? (pd_dir > 0 ? pd_h - pd_c : pd_c - pd_l) / pRng * 100 : 100.0
        float invPip = syminfo.type == "forex" ? syminfo.mintick * 10 : 1.0
        bool  okSize  = invMin <= 0 or pBody / invPip >= invMin
        bool  okClose = not invFilt or pCsw <= wfMax
        ok := okSize and okClose
    if ok or pdDoji
        InvSet s = InvSet.new(na, na, na, na, na, na)
        if ok
            invLvl  := pd_c + (pd_o - pd_c) * math.max(invAp, invA) / 100
            invSide := pd_dir
            if invOn and (not inv1m or isChart1m)
                [l1, t1] = invDraw(invAp, invApC, "A+")
                [l2, t2] = invDraw(invA,  invAC,  "A")
                s.l1 := l1, s.t1 := t1, s.l2 := l2, s.t2 := t2
        if pdDoji and showIcons
            s.dj := label.new(math.round((d_ot + d_ct) / 2), d_h, "⚠️" + mkPadDn, xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.white, 100), size = size.normal, tooltip = djWhy)
        invSets.push(s)
        while invSets.size() > bxKeep
            invDel(invSets.shift())

// Doji ⚠️ — follow the high as the candle extends.
if pdDoji and isHTFchart and invSets.size() > 0
    InvSet s = invSets.last()
    if not na(s.dj)
        s.dj.set_xy(math.round((d_ot + d_ct) / 2), d_h)

// ⛔ — first trade past the worst-case level, then follow the wick. Not after a doji (already invalidated).
if invX and iconTfOk and isHTFchart and not na(invLvl) and invSets.size() > 0
    InvSet s  = invSets.last()
    int    mx = math.round((d_ot + d_ct) / 2)
    float  my = invSide < 0 ? d_h : d_l     // bearish prev → above the high; bullish prev → below the low
    if not invHit and (invSide < 0 ? high > invLvl : low < invLvl)
        invHit := true
        string txt = invSide < 0 ? "⛔" + (pdDoji ? "\n \n " : "") + mkPadDn : mkPadUp + "⛔"
        float  wPct = math.max(invAp, invA)
        string wTag = invA >= invAp ? "A" : "A+"
        string tip  = "⛔ No trade this candle\nPrice traded " + (invSide < 0 ? "above" : "below") + " the " + wTag + " " + str.tostring(wPct, "#.#") + "% level (" + str.tostring(invLvl, format.mintick) + ") of the previous " + htfName + " candle's body: too deep a retrace for a continuation."
        s.mk := label.new(mx, my, txt, xloc = xloc.bar_time, style = invSide < 0 ? label.style_label_down : label.style_label_up, color = color.new(color.white, 100), size = size.normal, tooltip = tip)
    else if invHit and not na(s.mk)
        s.mk.set_xy(mx, my)

// ── CISD ─────────────────────────────────────────────────────────────
var int   cdBias  = 0       // previous HTF candle's colour
var bool  cdStep  = false   // a 1m close beyond the HTF open has happened
var int   cdState = 0       // current delivery: +1 bullish, -1 bearish
var float bullLvl = na      // open of the first candle in the most recent bullish run
var int   bullT   = na
var int   bullIdx = na      // bar_index of that candle
var float bearLvl = na      // open of the first candle in the most recent bearish run
var int   bearT   = na
var int   bearIdx = na
var int   lastDir = 0
var array<line> cdLns = array.new<line>()

// Reset at the HTF open. Runs are NOT cleared here: the opening candle decides below
if isChart1m and newD
    cdBias  := pd_dir
    cdStep  := false
    cdState := -pd_dir      // start in the counter leg, waiting for delivery to flip our way

if cdOn and isChart1m and barstate.isconfirmed and not na(d_o)
    int   dir   = close > open ? 1 : close < open ? -1 : 0
    float cdMid = d_ot + (d_ct + chartMs - d_ot) / 2


    // Opening candle: only a run it belongs to may reach back past the open.
    // Continues the run → keep that run's first candle. Doesn't → drop everything pre-open.
    if newD
        if dir != lastDir
            bullLvl := na, bearLvl := na
        else if dir > 0
            bearLvl := na
        else if dir < 0
            bullLvl := na

    // Step 1: bearish bias needs a close above the open, bullish a close below
    if not cdStep and (cdBias < 0 ? close > d_o : close < d_o)
        cdStep := true

    // The level candle needs at least one candle after it. If the very next candle closes
    // through, that's a one-candle engulf, not a change in delivery: no CISD from that level.
    bool bullInstant = not na(bullLvl) and bar_index - bullIdx == 1 and close < bullLvl
    bool bearInstant = not na(bearLvl) and bar_index - bearIdx == 1 and close > bearLvl

    // Break, checked against runs from BEFORE this candle. First half only.
    if cdStep and time < cdMid
        if cdState > 0 and dir < 0 and not na(bullLvl) and close < bullLvl and not bullInstant
            cdLns.push(line.new(bullT, bullLvl, cdExt ? time + 3 * chartMs : time, bullLvl, xloc = xloc.bar_time, color = cdBear, width = cdW))
            cdState := -1
        else if cdState < 0 and dir > 0 and not na(bearLvl) and close > bearLvl and not bearInstant
            cdLns.push(line.new(bearT, bearLvl, cdExt ? time + 3 * chartMs : time, bearLvl, xloc = xloc.bar_time, color = cdBull, width = cdW))
            cdState := 1
        while cdLns.size() > 100
            cdLns.shift().delete()

    // An engulfed level is spent: a later close beyond it can't confirm a CISD.
    if bullInstant
        bullLvl := na
    if bearInstant
        bearLvl := na

    // Runs: the first candle of a new same-colour run sets the level. Dojis don't end a run.
    if dir > 0 and lastDir != 1
        bullLvl := open, bullT := time, bullIdx := bar_index
    if dir < 0 and lastDir != -1
        bearLvl := open, bearT := time, bearIdx := bar_index
    if dir != 0
        lastDir := dir

// ═══════════════════════════════════════════════════════════════════════════════
// Candle Stats
// ═══════════════════════════════════════════════════════════════════════════════
csPip = syminfo.type == "forex" ? syminfo.mintick * 10 : 1.0
csNew = timeframe.change(csTf)

var float s_o   = na
var float s_h   = na
var float s_l   = na
var int   s_mid = na
var array<label> csLbs = array.new<label>()

if csOn and timeframe.in_seconds() <= timeframe.in_seconds(csTf)
    if csNew or na(s_o)
        s_o := open, s_h := high, s_l := low
        int ct = nz(time_close(csTf), time + timeframe.in_seconds(csTf) * 1000)
        s_mid := time + math.floor((ct - time) / 2 / chartMs) * chartMs     // middle bar of the candle
        color clr = color.new(color.white, 100)
        csLbs.push(label.new(s_mid, high, "", xloc = xloc.bar_time, style = label.style_label_down, color = clr, textcolor = #9c9c9c, size = size.small))
        csLbs.push(label.new(s_mid, low,  "", xloc = xloc.bar_time, style = label.style_label_up,   color = clr, textcolor = #9c9c9c, size = size.small))
        while csLbs.size() > 480
            csLbs.shift().delete()
    else
        s_h := math.max(s_h, high), s_l := math.min(s_l, low)

    float rng = s_h - s_l
    float tw  = rng > 0 ? (s_h - math.max(s_o, close)) / rng * 100 : 0.0
    float bw  = rng > 0 ? (math.min(s_o, close) - s_l) / rng * 100 : 0.0
    label up  = csLbs.get(csLbs.size() - 2)
    label dn  = csLbs.last()
    up.set_xy(s_mid, s_h), up.set_text(str.tostring(rng / csPip, "#.#") + "\n" + str.tostring(tw, "#") + "%")
    dn.set_xy(s_mid, s_l), dn.set_text(str.tostring(bw, "#") + "%")

// ═══════════════════════════════════════════════════════════════════════════════
// Close Filter marks
// ═══════════════════════════════════════════════════════════════════════════════
wfNew = timeframe.change(wfTf)

var float w_o   = na
var float w_h   = na
var float w_l   = na
var int   w_mid = na
var array<label> wfLbs = array.new<label>()

if wfOn and showIcons and timeframe.in_seconds() <= timeframe.in_seconds(wfTf)
    // Candle just closed: judge it with its final OHLC
    if wfNew and not na(w_o)
        float c    = close[1]
        float rng  = w_h - w_l
        bool  bull = c > w_o
        float csw  = rng > 0 ? (bull ? w_h - c : c - w_l) / rng * 100 : 100.0
        string mk  = c != w_o and csw <= wfMax ? "✅" : "⚠️"
        string tip = c == w_o ? "⚠️ Doji close: open = close, no displacement." : csw <= wfMax ? "✅ Clean close: " + (bull ? "top" : "bottom") + " wick is " + str.tostring(csw, "#") + "% of the range (≤ " + str.tostring(wfMax, "#.#") + "%)." : "⚠️ Caution, not a clean close: " + (bull ? "top" : "bottom") + " wick is " + str.tostring(csw, "#") + "% of the range (over " + str.tostring(wfMax, "#.#") + "%). Still tradable."
        bool  pad  = csOn and csTf == wfTf       // step clear of the stats text
        if not icPrev                 // only the candle that just closed keeps its mark
            while wfLbs.size() > 0
                wfLbs.shift().delete()
        wfLbs.push(label.new(w_mid, bull ? w_h : w_l, bull ? mk + (pad ? "\n \n " : "") : (pad ? " \n" : "") + mk, xloc = xloc.bar_time, style = bull ? label.style_label_down : label.style_label_up, color = color.new(color.white, 100), size = size.small, tooltip = tip))
        while wfLbs.size() > 200
            wfLbs.shift().delete()

    // Track the candle now forming (starts on a clean open, so no partial first candle)
    if wfNew
        w_o := open, w_h := high, w_l := low
        int ct = nz(time_close(wfTf), time + timeframe.in_seconds(wfTf) * 1000)
        w_mid := time + math.floor((ct - time) / 2 / chartMs) * chartMs
    else if not na(w_o)
        w_h := math.max(w_h, high), w_l := math.min(w_l, low)
````
