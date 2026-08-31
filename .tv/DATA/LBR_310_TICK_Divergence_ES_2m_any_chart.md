<!-- tradingview-pine-id: PUB;1ada68b65c64407da62e030a362c274d -->
<!-- tradingviewscripts-format: 1 -->
# LBR 3/10 + TICK Divergence [ES 2m → any chart]

Source: https://www.tradingview.com/script/ylssy3rf-LBR-3-10-TICK-Divergence-ES-2m-any-chart/

## Description

Runs Linda Raschke's triple-divergence setup (price + 3/10 oscillator + NYSE TICK) on a fixed ES 2-minute feed and delivers the signals to whatever chart you are actually watching - any symbol, any timeframe.

OVERVIEW

Raschke's "blindfold" setup - price makes a new swing extreme while both the 3/10 oscillator and the NYSE TICK refuse to confirm it - lives on the ES 2-minute chart. But nobody trades staring at one chart all day. You might be on a 15-minute ES chart for structure, on NQ, on SPY, or on an individual stock when the signal fires.

This indicator solves that. The entire signal engine - swing pivots, 3/10 oscillator, divergence logic - executes inside a fixed signal feed (ES 2-min by default) regardless of what chart it is applied to. NYSE TICK bars are streamed separately and joined to the ES pivots by timestamp. When all three legs align, a label prints on YOUR chart, with a tooltip carrying the exact ES time, prices, oscillator readings, and TICK values behind the signal.

Put it on any chart. The signals are always the same signals.

WHY THIS IS DIFFERENT

Two claims, one about the setup and one about the architecture.

The setup. TradingView has divergence engines and TICK divergence tools, but no public script requires the specific LBR combination - price + 3/10 fast line + NYSE TICK diverging at the same two confirmed swing pivots - as a single gated signal. One leg missing = nothing prints.

The architecture. Multi-timeframe divergence tools on TradingView scan higher or lower timeframes of the chart's own symbol. This script does something different: the signal computation is pinned to one fixed symbol and timeframe, independent of the chart. That requires running a fully stateful engine (persistent pivot memory, divergence counters) inside the security context and returning only scalars, plus a chart-side rolling ledger that collects 2-min TICK bars - via a lower-timeframe request when your chart is above 2 minutes - and joins them to ES pivot timestamps. I found no other public script that joins three data streams this way to reproduce one fixed setup on arbitrary charts.

THE SIGNAL

A bullish signal requires all of the following at two confirmed swing lows on the signal feed (bearish is the mirror at swing highs):

1 - Price: lower low. The second ES swing low undercuts the first.

2 - 3/10 oscillator: higher low. The fast line (SMA 3 minus SMA 10) is higher at the second pivot. New price lows, no new momentum lows.

3 - NYSE TICK: higher low. The TICK low at the second pivot sits above the TICK low at the first. Program selling across the whole exchange could not match its earlier intensity.

Additional gates: a minimum/maximum spacing window between the two swings, an optional zero-side filter requiring both oscillator readings below zero for bullish signals (above for bearish), and confirmed pivots only - asymmetric pivot strength with a small right side for fast confirmation. All data is requested without lookahead.

HOW TO USE IT

Setup: add to any chart and leave the defaults - CME_MINI:ES1! at 2 minutes as the signal feed, USI:TICK for confirmation. Swap the signal symbol to MES1!, SPX, or SPY if you prefer; swap the TICK symbol to match your data feed. The TICK requirement can be toggled off, leaving a price + 3/10 double divergence.

Reading a signal: the label prints on your chart bar at the moment the ES-side signal confirms. Hover the tooltip for the audit trail: the ES pivot time, both price extremes, both oscillator readings, and both TICK extremes. Execute on the signal feed's market (ES/MES), not necessarily on the symbol you happen to be watching.

The Raschke approach: this is a countertrend scalp against an exhausting move. The label is the condition, not the entry - enter on price confirmation (first strong rotation back in the signal's direction on the 2-min), stop beyond the divergence extreme, first target the middle of the prior swing. Take profits actively; divergence fades an extended move, it does not promise a new trend.

The Grimes perspective: Adam Grimes, who uses the same 3/10, stresses that momentum divergence is only worth fading when the move is overextended. The engine is deliberately minimal, so apply that filter yourself: weight signals that appear after a sustained one-way push - late in a morning sell-off, at a measured-move completion - over signals surfacing in quiet mid-range trade. And even if you never fade anything, a bearish triple divergence firing while you are long is an objective warning that the leg has lost its sponsorship.

FEATURES AND INPUTS

- Signal Feed: symbol and timeframe the engine runs on - fixed, independent of the chart.
- 3/10 Oscillator: fast and slow SMA lengths; zero-side filter toggle.
- Swing Detection: pivot strength left/right (right side sets confirmation lag); min/max spacing between the two swings, measured in signal-feed bars.
- TICK Confirmation: on/off toggle; TICK symbol input.
- Display: bullish and bearish colors.
- Tooltips on every label with the full audit trail from the signal feed.
- Alerts two ways: dynamic alert() messages carrying the exact ES signal time, plus static alertcondition() entries for standard alert dialogs. All fire on confirmed signals only.

LIMITATIONS

- Signals confirm a couple of signal-feed bars after the true swing (confirmed pivots don't repaint, but they lag). On charts slower than the signal timeframe, the label additionally waits for your chart bar to update - a 15-min chart can surface a signal minutes after the 2-min confirmation. For execution timing, alerts fire from the feed, not your chart bar.
- The label anchors to the chart bar where the signal arrived; the tooltip carries the exact signal-feed pivot time and values.
- Lookback is bounded by TradingView's intraday history for 2-min data and by the script's rolling TICK ledger, so deep history will show fewer signals than a native 2-min chart would.
- TICK is meaningful only for US equities and index products during regular NYSE hours.
- Countertrend by nature: in a runaway trend, price can print divergence after divergence while grinding on. Raschke's own warning - don't hunt divergences in the strongest trends.
- This identifies a condition; it is not an entry system. Trigger, stop, and target are yours.

THANKS

Credit to Linda Bradford Raschke (LBRGroup, Street Smarts) for the 3/10 oscillator and the triple-divergence setup, and to Adam Grimes (The Art and Science of Technical Analysis) for the momentum-divergence framework. Educational tool, not financial advice.

---

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// LBR 3/10 + TICK Triple Divergence — ES 2-MIN ENGINE, ANY CHART  (v2, low-mem)
//
// Signal engine (pivots, 3/10 osc, divergence) executes inside the ES 2-min
// context via request.security and returns ONLY scalars. TICK 2-min bars are
// streamed to the chart as scalars (plain security on charts ≤ 2-min,
// security_lower_tf on charts > 2-min) and collected into ONE chart-side
// rolling ledger, then joined to ES pivots by timestamp.
//
// This replaces the previous design that returned arrays through
// request.security — that forced per-bar history of large collections and
// blew the memory limit (RE10139).
// ─────────────────────────────────────────────────────────────────────────────
indicator("LBR 3/10 + TICK Divergence [ES 2m → any chart]", "LBR ES2m AnyChart",
     overlay = true, max_labels_count = 500, dynamic_requests = true)

// ════ INPUTS ════
grpSrc          = "Signal Feed (fixed, independent of chart)"
srcSym          = input.symbol("CME_MINI:ES1!", "Signal symbol", group = grpSrc)
srcTF           = input.timeframe("2", "Signal timeframe", group = grpSrc)

grpOsc          = "3/10 Oscillator"
fastLen         = input.int(3,  "Fast SMA length",  minval = 1, group = grpOsc)
slowLen         = input.int(10, "Slow SMA length",  minval = 2, group = grpOsc)
zeroSideFilter  = input.bool(true, "Require osc on correct side of zero (bull < 0, bear > 0)", group = grpOsc)

grpPiv          = "Swing Detection (in signal-feed bars)"
leftBars        = input.int(5, "Pivot strength — left bars",  minval = 1, group = grpPiv)
rightBars       = input.int(2, "Pivot strength — right bars (confirmation lag)", minval = 1, group = grpPiv)
minSpacing      = input.int(5,  "Min bars between the two swings", minval = 1,  group = grpPiv)
maxSpacing      = input.int(60, "Max bars between the two swings", minval = 5,  group = grpPiv)

grpTick         = "TICK Confirmation"
useTick         = input.bool(true, "Require TICK divergence", group = grpTick)
tickSym         = input.symbol("USI:TICK", "TICK symbol", group = grpTick)

grpVis          = "Display"
bullColor       = input.color(color.new(color.lime, 0), "Bullish color", group = grpVis)
bearColor       = input.color(color.new(color.red,  0), "Bearish color", group = grpVis)

// ════ SIGNAL ENGINE — runs bar-by-bar inside the ES 2-min context ════
// Returns cumulative signal counts plus the pivot times/values of the most
// recent price+osc divergence. Scalars only — cheap on memory.
f_engine() =>
    osc = ta.sma(close, fastLen) - ta.sma(close, slowLen)
    pl  = ta.pivotlow(low,  leftBars, rightBars)
    ph  = ta.pivothigh(high, leftBars, rightBars)

    var float prevPL  = na
    var float prevOL  = na
    var int   prevTL  = na
    var int   prevBL  = na
    var float prevPH  = na
    var float prevOH  = na
    var int   prevTH  = na
    var int   prevBH  = na
    var int   bullCnt = 0
    var int   bearCnt = 0
    var int   bT1 = na
    var int   bT2 = na
    var float bP1 = na
    var float bP2 = na
    var float bO1 = na
    var float bO2 = na
    var int   sT1 = na
    var int   sT2 = na
    var float sP1 = na
    var float sP2 = na
    var float sO1 = na
    var float sO2 = na

    if not na(pl)
        oscAt = osc[rightBars]
        tAt   = time[rightBars]
        bAt   = bar_index - rightBars
        spac  = na(prevBL) ? na : bAt - prevBL
        if not na(prevPL) and not na(spac) and spac >= minSpacing and spac <= maxSpacing
            zeroOK = not zeroSideFilter or (oscAt < 0 and prevOL < 0)
            if pl < prevPL and oscAt > prevOL and zeroOK
                bullCnt += 1
                bT1 := prevTL
                bT2 := tAt
                bP1 := prevPL
                bP2 := pl
                bO1 := prevOL
                bO2 := oscAt
        prevPL := pl
        prevOL := oscAt
        prevTL := tAt
        prevBL := bAt

    if not na(ph)
        oscAt = osc[rightBars]
        tAt   = time[rightBars]
        bAt   = bar_index - rightBars
        spac  = na(prevBH) ? na : bAt - prevBH
        if not na(prevPH) and not na(spac) and spac >= minSpacing and spac <= maxSpacing
            zeroOK = not zeroSideFilter or (oscAt > 0 and prevOH > 0)
            if ph > prevPH and oscAt < prevOH and zeroOK
                bearCnt += 1
                sT1 := prevTH
                sT2 := tAt
                sP1 := prevPH
                sP2 := ph
                sO1 := prevOH
                sO2 := oscAt
        prevPH := ph
        prevOH := oscAt
        prevTH := tAt
        prevBH := bAt

    [bullCnt, bearCnt, bT1, bT2, bP1, bP2, bO1, bO2, sT1, sT2, sP1, sP2, sO1, sO2]

[bullCnt, bearCnt, bT1, bT2, bP1, bP2, bO1, bO2, sT1, sT2, sP1, sP2, sO1, sO2] =
     request.security(srcSym, srcTF, f_engine(), barmerge.gaps_off, barmerge.lookahead_off)

// ════ TICK LEDGER — built CHART-SIDE from scalar feeds (low memory) ════
// One set of rolling arrays lives at chart scope. Entries dedup by bar time,
// which also handles realtime recalculation.
var array<int>   tikT = array.new_int()
var array<float> tikL = array.new_float()
var array<float> tikH = array.new_float()

f_push(int tm, float lo, float hi) =>
    if not na(tm)
        n = array.size(tikT)
        if n == 0 or array.last(tikT) != tm
            if n >= 3000
                array.shift(tikT)
                array.shift(tikL)
                array.shift(tikH)
            array.push(tikT, tm)
            array.push(tikL, lo)
            array.push(tikH, hi)
        else
            array.set(tikL, array.size(tikL) - 1, lo)
            array.set(tikH, array.size(tikH) - 1, hi)

chartAboveSrcTF = timeframe.in_seconds() > timeframe.in_seconds(srcTF)

if chartAboveSrcTF
    // chart TF > 2-min: pull ALL 2-min TICK sub-bars of each chart bar
    [lt, ll, lh] = request.security_lower_tf(tickSym, srcTF, [time, low, high])
    if array.size(lt) > 0
        for i = 0 to array.size(lt) - 1
            f_push(array.get(lt, i), array.get(ll, i), array.get(lh, i))
else
    // chart TF ≤ 2-min: each 2-min TICK bar appears at least once
    [tm1, lo1, hi1] = request.security(tickSym, srcTF, [time, low, high],
         barmerge.gaps_off, barmerge.lookahead_off)
    f_push(tm1, lo1, hi1)

// timestamp → value lookup
f_at(array<float> vArr, int t) =>
    idx = na(t) ? -1 : array.indexof(tikT, t)
    idx >= 0 ? array.get(vArr, idx) : na

// ════ CHART-SIDE SIGNAL DETECTION (any symbol, any timeframe) ════
newBullPrelim = bar_index > 0 and not na(bullCnt[1]) and bullCnt > bullCnt[1]
newBearPrelim = bar_index > 0 and not na(bearCnt[1]) and bearCnt > bearCnt[1]

tl1 = f_at(tikL, bT1)
tl2 = f_at(tikL, bT2)
th1 = f_at(tikH, sT1)
th2 = f_at(tikH, sT2)

bullTickOK = not useTick or (not na(tl1) and not na(tl2) and tl2 > tl1)
bearTickOK = not useTick or (not na(th1) and not na(th2) and th2 < th1)

bullSignal = newBullPrelim and bullTickOK
bearSignal = newBearPrelim and bearTickOK

// ════ VISUALS — anchored to the chart's own bars, render on any symbol ════
if bullSignal
    label.new(bar_index, low, "LBR ▲ ES2m",
         style = label.style_label_up, color = color.new(bullColor, 15),
         textcolor = color.black, size = size.small, yloc = yloc.belowbar,
         tooltip = srcSym + " " + srcTF + "m  " + str.format_time(bT2, "HH:mm", syminfo.timezone) +
                   "\nPrice LL: "    + str.tostring(bP1) + " → " + str.tostring(bP2) +
                   "\n3/10 osc HL: " + str.tostring(bO1, "#.##") + " → " + str.tostring(bO2, "#.##") +
                   (useTick ? "\nTICK HL: " + str.tostring(tl1, "#") + " → " + str.tostring(tl2, "#") : ""))
    alert("LBR setup ▲ " + srcSym + " " + srcTF + "m: price LL + 3/10 HL + TICK HL @ " +
         str.format_time(bT2, "HH:mm", syminfo.timezone), alert.freq_once_per_bar)

if bearSignal
    label.new(bar_index, high, "LBR ▼ ES2m",
         style = label.style_label_down, color = color.new(bearColor, 15),
         textcolor = color.white, size = size.small, yloc = yloc.abovebar,
         tooltip = srcSym + " " + srcTF + "m  " + str.format_time(sT2, "HH:mm", syminfo.timezone) +
                   "\nPrice HH: "    + str.tostring(sP1) + " → " + str.tostring(sP2) +
                   "\n3/10 osc LH: " + str.tostring(sO1, "#.##") + " → " + str.tostring(sO2, "#.##") +
                   (useTick ? "\nTICK LH: " + str.tostring(th1, "#") + " → " + str.tostring(th2, "#") : ""))
    alert("LBR setup ▼ " + srcSym + " " + srcTF + "m: price HH + 3/10 LH + TICK LH @ " +
         str.format_time(sT2, "HH:mm", syminfo.timezone), alert.freq_once_per_bar)

plotshape(bullSignal, "LBR bull (ES 2m)", style = shape.triangleup,   location = location.belowbar,
     color = bullColor, size = size.tiny)
plotshape(bearSignal, "LBR bear (ES 2m)", style = shape.triangledown, location = location.abovebar,
     color = bearColor, size = size.tiny)

// ════ STATIC ALERTCONDITIONS (alternative to the dynamic alert() calls) ════
alertcondition(bullSignal, "LBR Bullish Triple Divergence (ES 2m)",
     "LBR setup ▲ ES 2m: price LL + 3/10 HL + TICK HL")
alertcondition(bearSignal, "LBR Bearish Triple Divergence (ES 2m)",
     "LBR setup ▼ ES 2m: price HH + 3/10 LH + TICK LH")
````
