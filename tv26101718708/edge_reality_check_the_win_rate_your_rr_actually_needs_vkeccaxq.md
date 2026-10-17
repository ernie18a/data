# Edge Reality Check - the win rate your R:R actually needs

- url: https://www.tradingview.com/script/vkECcaXQ-Edge-Reality-Check-the-win-rate-your-R-R-actually-needs/
- type: indicator
- pine_id: PUB;f55a17ccc03a4862965f8fb4fd7c3e33
- version: 2.0

## Description

Before you build a strategy, it is worth knowing whether the reward-to-risk you have in mind has ever been achievable on the instrument you are trading. Most people find out afterwards.

This measures it. From every bar in the sample it asks one question: did price travel the target distance before it travelled the stop distance? Counting the answers gives the hit rate that entering at random would have produced on this chart — and that is the number any entry signal has to beat.

WHAT THE TABLE SHOWS

Break-even win rate. What your reward-to-risk demands before anything else. At 2:1 that is 33.3%; at 1:2 it is 66.7%. Enter your spread and commission and it recalculates, because small edges usually die there.

The measured hit rate. Not a guess, not an assumption — what actually happened on this chart, over the sample you choose.

The margin between them. If random entries at 2:1 hit 29% here and you need 33.3%, your signal is not looking for an edge, it is clawing back a deficit. If random entries already clear break-even, your signal only has to avoid making things worse. Those are very different projects, and knowing which one you are on is worth ten minutes.

The losing run to expect. Given the measured hit rate and the number of samples, the longest run of losses that ordinary bad luck produces. People abandon working systems inside runs that were always going to happen.

NOTES ON METHOD

Stop and target can be sized from the ATR at each historical bar, so distances scale with the volatility of the time rather than today's.

If a single bar spans both the stop and the target there is no way to know which came first, so it counts as a loss. Being wrong pessimistically is the only honest way to resolve it.

Samples that reach neither level within the holding window are reported separately as timed out, not quietly dropped.

The table states the period the sample covers. Six hundred bars is two days on a 5m chart and two years on a daily one, and a percentage with no period attached invites more confidence than it has earned.

The figure describes the window, not the instrument. A trending period flatters one direction and punishes the other: gold on 1H measured 44.9% for longs over five trending weeks, and 28.1% on 5m over two choppy days. Run it across several windows before you believe any single number, and check whether the direction you are testing happened to be the way the market was going.

This is a baseline, not a backtest. It measures the instrument, not a strategy. A signal that beats it may still be worthless for other reasons — costs, overfitting, or a sample too small to mean anything.

WHAT IT IS NOT

It places no trades, gives no signals and predicts nothing. It tells you what the chart has already done.

Open source. Use it, change it, take it apart.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Edge Reality Check
//
// Measures whether a reward-to-risk has actually been achievable on this
// chart, instead of asking you to guess.
//
// From every bar in the sample it asks one question: did price travel the
// target distance before it travelled the stop distance? Counting the answers
// gives the hit rate that entering at random would have produced — the
// baseline any entry signal has to beat.
//
// That number matters more than most people realise. If random entries at
// 2:1 hit 29% on this instrument and you need 33.3% to break even, then your
// signal is not looking for an edge, it is trying to claw back a deficit.
//
// Not a strategy. It places no trades, gives no signals and predicts nothing.
//
// Released under the Mozilla Public License 2.0
// ─────────────────────────────────────────────────────────────────────────────

indicator("Edge Reality Check", "Edge Reality", overlay = true, max_bars_back = 4000)

// ── Inputs ───────────────────────────────────────────────────────────────────

grpRisk   = "Stop and target"
grpTest   = "How much history to measure"
grpCost   = "Trading costs"
grpStyle  = "Appearance"

direction = input.string("Long", "Direction", options = ["Long", "Short"], group = grpRisk)
useAtr    = input.bool(true, "Size stop and target from ATR", group = grpRisk,
   tooltip = "On: distances are multiples of ATR measured at each bar, so they scale with the volatility of the time. Off: fixed price points.")
atrLen    = input.int(14, "ATR length", minval = 1, group = grpRisk)
stopMult  = input.float(1.5, "Stop distance",   minval = 0.01, step = 0.1, group = grpRisk)
targetMult= input.float(3.0, "Target distance", minval = 0.01, step = 0.1, group = grpRisk)

sampleBars = input.int(600, "Bars to sample", minval = 50, maxval = 3000, step = 50, group = grpTest,
   tooltip = "How far back to test from. More is better evidence and slower to calculate.")
maxHold    = input.int(60, "Bars allowed to resolve", minval = 5, maxval = 500, step = 5, group = grpTest,
   tooltip = "How long a trade gets to reach the target or the stop before it is abandoned as unresolved.")

costPoints = input.float(0.0, "Cost per round trip, in points", minval = 0.0, step = 0.01, group = grpCost,
   tooltip = "Spread plus commission, both ways, in the same units as price. Small edges usually die here.")

tblPos  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpStyle)
txtSize = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpStyle)

// ── Current distances, for display ───────────────────────────────────────────

atr       = ta.atr(atrLen)
stopNow   = useAtr ? atr * stopMult   : stopMult
targetNow = useAtr ? atr * targetMult : targetMult

// ── Break-even, before and after costs ───────────────────────────────────────

beRaw = (targetNow + stopNow) > 0 ? stopNow / (targetNow + stopNow) : na

netTarget = targetNow - costPoints
netStop   = stopNow   + costPoints
beNet = netTarget > 0 and (netTarget + netStop) > 0 ? netStop / (netTarget + netStop) : na

rr = stopNow > 0 ? targetNow / stopNow : na

// ── Measure the chart ────────────────────────────────────────────────────────

var int   wins       = 0
var int   losses     = 0
var int   unresolved = 0
var float measured   = na
var int   sampleFrom = na
var int   sampleTo   = na

isLong = direction == "Long"

if barstate.islast
    w = 0
    l = 0
    u = 0

    sampleFrom := time[math.min(sampleBars, bar_index)]
    sampleTo   := time

    // Start far enough back that every sample has room to resolve forward.
    for i = maxHold to sampleBars
        entry = close[i]
        sDist = useAtr ? nz(atr[i]) * stopMult   : stopMult
        tDist = useAtr ? nz(atr[i]) * targetMult : targetMult

        if sDist > 0 and tDist > 0 and not na(entry)
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

                    // If a single bar spans both levels there is no way to
                    // know which came first, so it counts as a loss. Being
                    // wrong in the pessimistic direction is the only honest
                    // way to resolve it.
                    if hitStop
                        l += 1
                        settled := true
                    else if hitTarget
                        w += 1
                        settled := true

            if not settled
                u += 1

    wins       := w
    losses     := l
    unresolved := u
    measured   := (w + l) > 0 ? w / float(w + l) : na

samples = wins + losses
margin  = na(measured) or na(beNet) ? na : measured - beNet

// Expected longest run of losses across the resolved sample:
//   log(n * p) / log(1 / (1 - p))
lossProb    = na(measured) ? na : 1.0 - measured
expectedRun = not na(measured) and measured > 0 and lossProb > 0 and samples * measured > 1 ?
   math.log(samples * measured) / math.log(1.0 / lossProb) : na

// ── Verdict ──────────────────────────────────────────────────────────────────

verdictText = "Not enough resolved samples yet. Load more history or shorten the target."
verdictCol  = color.new(color.gray, 20)

if not na(margin) and samples >= 30
    if margin >= 0.05
        verdictText := "Entering at random here already clears break-even. A signal only has to avoid making it worse."
        verdictCol  := color.new(#1f7a52, 0)
    else if margin >= 0.0
        verdictText := "Random entries roughly break even at this reward-to-risk. Your signal has to do all the work."
        verdictCol  := color.new(#97621a, 0)
    else
        verdictText := "Random entries lose money at this reward-to-risk. Your signal must beat " + str.tostring(beNet * 100, "#.#") + "% just to stand still."
        verdictCol  := color.new(#a83a2f, 0)
else if samples > 0 and samples < 30
    verdictText := "Only " + str.tostring(samples) + " resolved samples. Too few to conclude anything."

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

    table.cell(t, 0, 0, "EDGE REALITY CHECK", text_color = color.white, bgcolor = headBg, text_size = size)
    table.cell(t, 1, 0, direction, text_color = color.new(color.white, 30), bgcolor = headBg, text_size = size)

    table.cell(t, 0, 1, "Stop / target distance", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 1, price(stopNow) + " / " + price(targetNow), text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 2, "As % of price", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 2, close > 0 ?
       str.tostring(stopNow / close * 100, "#.##") + "% / " + str.tostring(targetNow / close * 100, "#.##") + "%" : "—",
       text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 3, "Reward : risk", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 3, num(rr) + " : 1", text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 4, "Break-even win rate", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 4, pct(beRaw), text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 5, "After costs", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 5, pct(beNet), text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 6, "Measured on this chart", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 6, pct(measured), text_color = color.new(#16233a, 0), text_size = size, bgcolor = rowBg)

    marginCol = na(margin) ? color.gray : margin >= 0.05 ? #1f7a52 : margin >= 0 ? #97621a : #a83a2f
    table.cell(t, 0, 7, "Margin over break-even", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 7, na(margin) ? "—" : (margin >= 0 ? "+" : "") + str.tostring(margin * 100, "#.#") + " pts",
       text_color = marginCol, text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 8, "Resolved samples", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 8, str.tostring(samples) + (unresolved > 0 ? "  (" + str.tostring(unresolved) + " timed out)" : ""),
       text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 9, "Sample covers", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 9, na(sampleFrom) ? "—" :
       str.format_time(sampleFrom, "d MMM yy", syminfo.timezone) + " to " +
       str.format_time(sampleTo, "d MMM yy", syminfo.timezone),
       text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 10, "Expect a losing run of", text_size = size, bgcolor = rowBg)
    table.cell(t, 1, 10, na(expectedRun) ? "—" : str.tostring(math.round(expectedRun)) + " in " + str.tostring(samples),
       text_size = size, bgcolor = rowBg)

    table.cell(t, 0, 11, verdictText, text_color = color.white, bgcolor = verdictCol,
       text_size = size, text_halign = text.align_left)
    table.merge_cells(t, 0, 11, 1, 11)
````
