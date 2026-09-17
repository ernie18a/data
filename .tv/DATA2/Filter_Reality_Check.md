<!-- tradingview-pine-id: PUB;4289886f525b41c48bdbecf364c3bf9b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Filter Reality Check

Source: https://www.tradingview.com/script/mooQUojq-Filter-Reality-Check/

## Description

# Filter Reality Check — does your condition actually select anything?

My last script measured what entering at random would have produced on a
chart at a given reward-to-risk. The question everybody asked next was the
obvious one: *fine — does my filter beat that?*

Almost nobody measures it. This does.

It resolves every bar in the sample exactly once, then counts the outcome
twice: into the baseline, and into the filtered set if your condition was
true on that bar. Same bars, same distances, same resolutions — so the
difference between the two rates is the filter and nothing else.

## What the table shows

**All bars.** The baseline. What entering at random would have produced
here at your reward-to-risk.

**When condition true.** The same measurement, restricted to bars where
your filter passed.

**The filter is worth.** The difference, in percentage points of hit rate.
This is the number you came for.

**Bars it kept.** What share of the sample survived the condition. This
matters more than it looks: a filter true on 97% of bars is not selecting
anything, and its hit rate will match the baseline for that reason alone.
If this figure is near 100%, the filter is decoration.

**Filtered vs break-even.** Whether the filtered rate clears what your
reward-to-risk actually demands, after costs.

## Conditions you can test

Price above or below a moving average (EMA or SMA, any length), ADX above
a level, RSI above or below a level, volatility rising (ATR above its own
average), volume above a multiple of average, inside a session window, or
**any custom source above a level** — which lets you point it at another
indicator on your chart and test that.

## What you should expect to find

Most filters are worth nothing.

That is the finding, not a failure of the tool. A condition that moves the
hit rate by half a point is a condition you can delete, and knowing which
of yours those are is worth more than adding another indicator. The script
says so plainly when it happens.

Occasionally you will find one that costs you points — where you would
genuinely do better entering at random. Those are worth knowing about
before they are load-bearing in a strategy.

## Method, and its limits

**The condition is read on the entry bar itself**, using only data that
existed then. A filter evaluated with information that arrived later would
flatter itself and the result would be worthless.

**A bar spanning both stop and target counts as a loss.** There is no way
to know which came first from bar data, and being wrong pessimistically is
the only honest way to resolve it.

**Samples that reach neither level within the holding window are reported
as timed out**, not quietly dropped.

**Distances can scale with each historical bar's own ATR**, so the test
uses the volatility of the time rather than today's.

**The table states the period covered.** Six hundred bars is two days on a
5m chart and two years on a daily one, and a percentage with no period
attached invites more confidence than it has earned.

**Thirty resolved samples is the floor.** Below that the script refuses to
draw a conclusion, and it will tell you when your condition was true too
rarely to judge — which happens often with tight filters on short samples.

## What it is not

It places no trades, gives no signals and predicts nothing. It measures
what a condition would have selected on the history in front of you, on
this instrument, over this window. Run it across several windows before
you believe any single number, and check whether the direction you are
testing happened to be the way the market was going.

A filter that improves the hit rate may still be worthless for other
reasons — overfitting, costs, or a sample too small to mean anything.
This measures one thing and only claims that one thing.

Open source. Companion to *Edge Reality Check*, which measures the
baseline this compares against.

---

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Filter Reality Check
//
// Edge Reality Check answers "what would entering at random have produced
// here?". The question everybody asks next is "fine — does my filter beat
// that?", and almost nobody measures it.
//
// This does. It resolves every bar in the sample exactly once, then counts
// the outcome twice: into the baseline, and into the filtered set if your
// condition was true on that bar. The two rates come from identical bars,
// identical distances and identical resolutions, so the difference between
// them is the filter and nothing else.
//
// Most filters turn out to be worth nothing. That is the finding, not a
// failure of the tool — a condition that moves the hit rate by half a point
// is a condition you can drop, and knowing which of yours those are is
// worth more than another indicator.
//
// Not a strategy. It places no trades, gives no signals and predicts nothing.
//
// Released under the Mozilla Public License 2.0
// ─────────────────────────────────────────────────────────────────────────────

indicator("Filter Reality Check", overlay = true, max_bars_back = 3000)

// ── Inputs ───────────────────────────────────────────────────────────────────

grpRisk   = "Stop and target"
grpFilter = "The filter to test"
grpTest   = "How much history to measure"
grpCost   = "Trading costs"
grpStyle  = "Appearance"

direction = input.string("Long", "Direction", options = ["Long", "Short"], group = grpRisk)
useAtr    = input.bool(true, "Size stop and target from ATR", group = grpRisk,
   tooltip = "Distances scale with the volatility of each historical bar, not today's.")
atrLen    = input.int(14, "ATR length", minval = 1, group = grpRisk)
stopMult  = input.float(1.5, "Stop distance",   minval = 0.01, step = 0.1, group = grpRisk)
targetMult= input.float(3.0, "Target distance", minval = 0.01, step = 0.1, group = grpRisk)

filterKind = input.string("Price above moving average", "Condition", group = grpFilter,
   options = ["Price above moving average", "Price below moving average",
              "ADX above level", "RSI above level", "RSI below level",
              "Volatility rising", "Volume above average",
              "Inside session", "Custom source above level"],
   tooltip = "The condition is read on the entry bar itself, using only data that existed then.")

maType   = input.string("EMA", "Moving average type", options = ["EMA", "SMA"], group = grpFilter)
maLen    = input.int(200, "Moving average length", minval = 1, group = grpFilter)
adxLen   = input.int(14, "ADX length", minval = 1, group = grpFilter)
adxLevel = input.float(25.0, "ADX level", minval = 0.0, step = 1.0, group = grpFilter)
rsiLen   = input.int(14, "RSI length", minval = 1, group = grpFilter)
rsiLevel = input.float(50.0, "RSI level", minval = 0.0, maxval = 100.0, step = 1.0, group = grpFilter)
volLen   = input.int(20, "Volume average length", minval = 1, group = grpFilter)
volMult  = input.float(1.5, "Volume multiple", minval = 0.1, step = 0.1, group = grpFilter)
sessStr  = input.session("0800-1600", "Session", group = grpFilter)
srcInput = input.source(close, "Custom source", group = grpFilter)
srcLevel = input.float(0.0, "Custom source level", step = 0.1, group = grpFilter)

sampleBars = input.int(600, "Bars to sample", minval = 50, maxval = 3000, step = 50, group = grpTest,
   tooltip = "600 bars is two days on a 5m chart and two years on a daily one.")
maxHold    = input.int(60, "Bars allowed to resolve", minval = 5, maxval = 500, step = 5, group = grpTest,
   tooltip = "Samples reaching neither level within this many bars are reported as timed out, not dropped.")

costPoints = input.float(0.0, "Cost per round trip, in points", minval = 0.0, step = 0.01, group = grpCost,
   tooltip = "Spread plus commission, in the instrument's own points.")

tblPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpStyle)
txtSize = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpStyle)
showMa  = input.bool(false, "Plot the moving average", group = grpStyle)

// ── The filter, as a series ──────────────────────────────────────────────────
//
// Computed on every bar so it can be read at the historical bar the sample
// entered on. Reading it at the entry bar is the whole point: a filter
// evaluated with information that arrived later would flatter itself, and
// the result would be worthless.

ma  = maType == "SMA" ? ta.sma(close, maLen) : ta.ema(close, maLen)
[_dip, _dim, adxVal] = ta.dmi(adxLen, adxLen)
rsiVal = ta.rsi(close, rsiLen)
atrF   = ta.atr(atrLen)
atrAvg = ta.sma(atrF, atrLen)
volAvg = ta.sma(volume, volLen)
inSess = not na(time(timeframe.period, sessStr))

// Written as a branch rather than a chain of ternaries: Pine will not
// continue a line that ends on a bare "=", and a nine-deep ternary is
// unpleasant to read even where it parses.
filterPass = false
if filterKind == "Price above moving average"
    filterPass := close > ma
else if filterKind == "Price below moving average"
    filterPass := close < ma
else if filterKind == "ADX above level"
    filterPass := adxVal > adxLevel
else if filterKind == "RSI above level"
    filterPass := rsiVal > rsiLevel
else if filterKind == "RSI below level"
    filterPass := rsiVal < rsiLevel
else if filterKind == "Volatility rising"
    filterPass := atrF > atrAvg
else if filterKind == "Volume above average"
    filterPass := volume > volAvg * volMult
else if filterKind == "Inside session"
    filterPass := inSess
else
    filterPass := srcInput > srcLevel

plot(showMa and (filterKind == "Price above moving average" or filterKind == "Price below moving average") ? ma : na,
   "Moving average", color = color.new(#7a8aa0, 0), linewidth = 1)

// ── Current distances, for display ───────────────────────────────────────────

atr       = ta.atr(atrLen)
stopNow   = useAtr ? atr * stopMult   : stopMult
targetNow = useAtr ? atr * targetMult : targetMult

// ── Break-even, before and after costs ───────────────────────────────────────
//   You need:  winRate * target = (1 - winRate) * stop
//   Which is:  stop / (target + stop)

beRaw = (targetNow + stopNow) > 0 ? stopNow / (targetNow + stopNow) : na

netTarget = targetNow - costPoints
netStop   = stopNow   + costPoints
beNet = netTarget > 0 and (netTarget + netStop) > 0 ? netStop / (netTarget + netStop) : na

rr = stopNow > 0 ? targetNow / stopNow : na

// ── Measure the chart, twice, from one pass ──────────────────────────────────

var int   allWins    = 0
var int   allLosses  = 0
var int   filWins    = 0
var int   filLosses  = 0
var int   unresolved = 0
var int   filBars    = 0
var float allRate    = na
var float filRate    = na
var int   sampleFrom = na
var int   sampleTo   = na

isLong = direction == "Long"

if barstate.islast
    aw = 0
    al = 0
    fw = 0
    fl = 0
    u  = 0
    fb = 0

    sampleFrom := time[math.min(sampleBars, bar_index)]
    sampleTo   := time

    // Start far enough back that every sample has room to resolve forward.
    for i = maxHold to sampleBars
        entry = close[i]
        sDist = useAtr ? nz(atr[i]) * stopMult   : stopMult
        tDist = useAtr ? nz(atr[i]) * targetMult : targetMult

        if sDist > 0 and tDist > 0 and not na(entry)
            // The filter as it stood on the bar being entered.
            passed = filterPass[i] == true
            if passed
                fb += 1

            targetLevel = isLong ? entry + tDist : entry - tDist
            stopLevel   = isLong ? entry - sDist : entry + sDist
            settled = false

            for j = 1 to maxHold
                idx = i - j
                if idx >= 0 and not settled
                    hi = high[idx]
                    lo = low[idx]

                    hitStop   = isLong ? lo <= stopLevel   : hi >= stopLevel
                    hitTarget = isLong ? hi >= targetLevel : lo <= targetLevel

                    // A bar spanning both levels counts as a loss. There is
                    // no way to know which came first, and being wrong
                    // pessimistically is the only honest way to resolve it.
                    if hitStop
                        al += 1
                        if passed
                            fl += 1
                        settled := true
                    else if hitTarget
                        aw += 1
                        if passed
                            fw += 1
                        settled := true

            if not settled
                u += 1

    allWins    := aw
    allLosses  := al
    filWins    := fw
    filLosses  := fl
    unresolved := u
    filBars    := fb
    allRate    := (aw + al) > 0 ? aw / float(aw + al) : na
    filRate    := (fw + fl) > 0 ? fw / float(fw + fl) : na

allSamples = allWins + allLosses
filSamples = filWins + filLosses

// What the filter is worth, in percentage points of hit rate.
delta = na(allRate) or na(filRate) ? na : filRate - allRate

// How selective it is. A filter that keeps 98% of bars is not a filter.
kept = allSamples > 0 ? filSamples / float(allSamples) : na

filMargin = na(filRate) or na(beNet) ? na : filRate - beNet

// ── Verdict ──────────────────────────────────────────────────────────────────

MIN_SAMPLES = 30

verdictText = "Not enough resolved samples yet. Load more history or shorten the target."
verdictCol  = color.new(color.gray, 20)

if allSamples < MIN_SAMPLES
    verdictText := "Only " + str.tostring(allSamples) + " resolved samples in total. Too few to conclude anything."
else if filSamples < MIN_SAMPLES
    verdictText := "Your condition was true on only " + str.tostring(filSamples) +
       " resolved bars. Too few to judge — loosen it or sample more history."
else if not na(delta)
    if delta >= 0.03
        verdictText := "The filter adds " + str.tostring(delta * 100, "#.#") +
           " points of hit rate. Worth keeping."
        verdictCol  := color.new(#1f7a52, 0)
    else if delta <= -0.03
        verdictText := "The filter costs you " + str.tostring(math.abs(delta) * 100, "#.#") +
           " points. You would do better entering at random."
        verdictCol  := color.new(#a83a2f, 0)
    else
        verdictText := "The filter changes the hit rate by " + str.tostring(delta * 100, "#.#") +
           " points. That is nothing. It is not selecting anything."
        verdictCol  := color.new(#97621a, 0)

// ── Table ────────────────────────────────────────────────────────────────────

pos = tblPos == "Top left"     ? position.top_left     :
      tblPos == "Bottom right" ? position.bottom_right :
      tblPos == "Bottom left"  ? position.bottom_left  : position.top_right

size = txtSize == "Tiny"  ? size.tiny  :
       txtSize == "Small" ? size.small :
       txtSize == "Large" ? size.large : size.normal

var table t = table.new(pos, 2, 12, border_width = 1, frame_width = 1,
   frame_color = color.new(color.gray, 60), border_color = color.new(color.gray, 80))

pct(x)   => na(x) ? "—" : str.tostring(x * 100, "#.#") + "%"
num(x)   => na(x) ? "—" : str.tostring(x, "#.##")
price(x) => na(x) ? "—" : str.tostring(x, format.mintick)

if barstate.islast
    headBg = color.new(#16233a, 0)
    rowBg  = color.new(color.gray, 92)

    table.cell(t, 0, 0, "FILTER REALITY CHECK", text_color = color.white, bgcolor = headBg, text_size = size)
    table.cell(t, 1, 0, direction, text_color = color.new(color.white, 30), bgcolor = headBg, text_size = size)

    // Distances, never levels. Printing "your stop would be at 64,233" turns
    // a calculator into something that looks like a trade laid out on a
    // chart, and this tool gives no signals.
    table.cell(t, 0, 1, "Stop / target distance", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 1, price(stopNow) + " / " + price(targetNow), text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 2, "Reward : risk", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 2, num(rr) + " : 1", text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 3, "Break-even win rate", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 3, pct(beNet) + (costPoints > 0 ? "  (after costs)" : ""), text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 4, "Condition", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 4, filterKind, text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 5, "All bars", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 5, pct(allRate) + "  (" + str.tostring(allSamples) + ")", text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 6, "When condition true", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 6, pct(filRate) + "  (" + str.tostring(filSamples) + ")",
       text_color = color.new(#16233a, 0), text_size = size, bgcolor = rowBg)

    deltaCol = na(delta) ? color.gray : delta >= 0.03 ? #1f7a52 : delta <= -0.03 ? #a83a2f : #97621a
    table.cell(t, 0, 7, "The filter is worth", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 7, na(delta) ? "—" : (delta >= 0 ? "+" : "") + str.tostring(delta * 100, "#.#") + " pts",
       text_color = deltaCol, text_size = size, bgcolor = rowBg)

    // A condition true on nearly every bar is not selecting anything, and
    // its hit rate will match the baseline for that reason alone.
    table.cell(t, 0, 8, "Bars it kept", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 8, na(kept) ? "—" : str.tostring(kept * 100, "#.#") + "% of the sample",
       text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 9, "Filtered vs break-even", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 9, na(filMargin) ? "—" : (filMargin >= 0 ? "+" : "") + str.tostring(filMargin * 100, "#.#") + " pts",
       text_size = size, bgcolor = rowBg)

    // A percentage with no period attached invites more confidence than it
    // has earned.
    table.cell(t, 0, 10, "Sample covers", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 10, na(sampleFrom) ? "—" :
       str.format_time(sampleFrom, "d MMM yy", syminfo.timezone) + " to " +
       str.format_time(sampleTo, "d MMM yy", syminfo.timezone) +
       (unresolved > 0 ? "  (" + str.tostring(unresolved) + " timed out)" : ""),
       text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 11, verdictText, text_color = color.white, bgcolor = verdictCol,
       text_size = size, text_halign = text.align_left)
    table.merge_cells(t, 0, 11, 1, 11)
````
