# Break & Re-Test Zones v5.2 Outcome Audit

- url: https://www.tradingview.com/script/Mr386EDe-Break-Re-Test-Zones-v5-2-Outcome-Audit/
- type: indicator
- pine_id: PUB;e684abb7300c45bba987dbbb0d446bda
- version: 7.0

## Description

Here's the full description of the indicator — what it is, what it draws, and how it thinks.
What it is
It's a TradingView indicator that automates the Break & Re-Test strategy on 15-minute Gold and NQ futures. It finds support/resistance zones by itself, watches for one to break, waits for price to come back and confirm the flip, and only then fires a buy or sell signal — with entry, stop, and targets pre-calculated. Two versions exist: the indicator (v5.1) for live trading and chart-reading, and a strategy sibling that runs the identical logic through TradingView's backtester.
What it draws — the five layers
1. Support & resistance zones. Built automatically from swing pivots, drawn as bands (not lines), and colour-coded by where price sits right now: green below price = support, red above = resistance, gray = price inside it ("IN TEST"). Each zone is also classified PRIMARY (solid thick border, likely to hold — earned by having 2 of: multiple touches, overlap with a higher-timeframe level, or a round number inside it) or SECONDARY (dashed, likely to break). White labels show the price and touch count. This is the map.
2. The armed state. When a candle body closes through a zone, that zone turns orange with a "RETEST? / ARMED" label — meaning a break happened and the indicator is now watching for the pullback. It's a watch notice, never an entry, and it lives only while the setup is genuinely armed.
3. The signal / trade package. When price returns and a confirmation candle closes back on the breakout side, the entry fires: a coloured arrow at the candle, a banner with direction and confluence grade ("LONG [B] @ …"), plus dotted rails to the entry, a hollow-circle stop, and blue-square TP1/TP2 targets. Stop goes beyond the zone; targets sit at 1.5R and 2R.
4. The outcome audit. Every fired trade tracks itself: stopped out, the whole package erases; reaches TP1, it's immortalised as a yellow-bordered rectangle spanning the winning run. Only the last couple of winners stay — a pattern library of what worked (winners-only by design, so it's study material, not a scoreboard).
5. Reference levels & tables. Stepped lines mark the previous day's and previous hour's high/low (the walls and fences other traders watch). A dashboard shows session, HTF bias, and zone counts; a pre-entry runsheet grades the nearest armed setup live against every rule (session, touches, gap, room, confluence, confirmation) and gives a GO / NO-TRADE verdict.
How it thinks — the engine
Under the hood it runs a per-zone state machine: each level independently moves live → broken → retested/failed/expired, so many setups can be tracked at once without interfering. Three principles govern everything: a break requires a body close through the zone (wick pokes are ignored); a retest needs a gap of at least one candle so the breakout candle can't be its own retest; and — critically — all decisions are made only at candle close, so signals, stops, and targets never drift intrabar or repaint.
Layered on top is a confluence grader (A/B/C) scoring each setup on higher-timeframe level overlap, breakout volume, and a quiet pullback — with an optional filter to trade only A or B+ setups. Session filters restrict signals to the high-volume London and New York windows (Asia is for marking levels, not trading them).
What it's for
Three jobs, in order of how you'd use them: it draws the map (which levels matter, which will hold vs break, for zone-to-zone planning), it triggers the trade (arms on break, fires on confirmed retest, with risk pre-set), and it keeps you honest (the audit shows real outcomes; the backtest sibling reports win rate and average R per grade so you tune on evidence, not vibes).
The one thing it deliberately doesn't do is pretend the strategy is a money printer — the audit only shows winners by design, and your first raw backtest came back at 25% win rate, which is exactly why the tuned strategy version and its per-grade stats exist: to find where the real edge lives before you risk anything.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
// © BreakAndRetestPro — v4: confluence grading + zone classification
//
//  NEW IN v4:
//   • CONFLUENCE SCORER — every signal graded A/B/C from three checks:
//       HTF level overlap (+2) · breakout volume ≥ x avg (+1) · quiet pullback (+1)
//       A = 3+ pts, B = 2 pts, C = 0-1 pts. Optional filter: A-only / B+ / all
//   • PRIMARY vs SECONDARY ZONES — zones scored on touches, HTF-level overlap
//       and round-number confluence. PRIMARY (likely to hold) = solid border,
//       SECONDARY (likely to break) = dashed border. White text labels.
//       Supports shaded green, resistance shaded red — for zone-to-zone trades.
//   • NEW MARKERS — green up-arrow under long signal candle, red down-arrow
//       above short signal candle; TP = blue square + dotted line + price;
//       SL = red hollow circle + red dotted line + price
//   • Daily prev high/low added to HTF confluence set
// ═════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Break & Re-Test Zones — v7.1", overlay = true, max_bars_back = 500, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ═══ INPUTS ══════════════════════════════════════════════════════════════════
group_sw = "Swing detection"
pivotLeft      = input.int(5, "Pivot left bars",  minval = 1, maxval = 20, group = group_sw)
pivotRight     = input.int(5, "Pivot right bars", minval = 1, maxval = 20, group = group_sw)
maxZonesToShow = input.int(6, "Max zones per side", minval = 1, maxval = 12, group = group_sw)
zoneMaxATR     = input.float(0.5, "Max zone height (x ATR14)", minval = 0.1, step = 0.1, group = group_sw)

group_br = "Break & re-test"
minTouch      = input.int(1, "Min touches before break is valid", minval = 1, group = group_br)
gapBars       = input.int(1, "Min bars between break and retest", minval = 0, group = group_br)
retestMaxBars = input.int(20, "Retest window (bars)", minval = 5, maxval = 100, group = group_br)
useRunaway    = input.bool(true, "Kill setup if price runs away from the zone", group = group_br,
     tooltip = "A retest that needs a big round-trip back to the zone is no longer a retest — the market has moved on. If price travels further than the distance below AWAY from the armed zone, the setup expires early instead of waiting out the clock.")
runawayATR    = input.float(3.0, "  runaway distance (x ATR14)", minval = 1.0, step = 0.5, group = group_br)
failCoolBars  = input.int(10, "Flip-failed cooldown (bars) before level revives", minval = 2, maxval = 50, group = group_br,
     tooltip = "A zone whose flip failed (price closed back through it) stays on the chart in violet, then returns to a normal live level after this many bars.")
target1RR     = input.float(1.5, "Target 1 R:R", minval = 1.0, maxval = 5.0, step = 0.1, group = group_br)
target2RR     = input.float(2.0, "Target 2 R:R", minval = 1.0, maxval = 5.0, step = 0.1, group = group_br)

group_cf = "Confluence"
volMult   = input.float(1.2, "Breakout volume >= x of 20-bar avg", minval = 1.0, step = 0.1, group = group_cf)
htfTolATR = input.float(0.25, "HTF-level overlap tolerance (x ATR)", minval = 0.05, step = 0.05, group = group_cf)
roundStep = input.float(50.0, "Round-number step (NQ 50 / Gold 10)", minval = 0.1, group = group_cf)
useSweep  = input.bool(true, "ICT: liquidity sweep before break (+1)", group = group_cf,
     tooltip = "Break preceded by a raid on the opposite side's liquidity: a candle wicks through the prior swing high/low then closes back inside, within the max-age window below.")
sweepLen  = input.int(20, "  sweep: prior high/low lookback (bars)", minval = 5, group = group_cf)
sweepAge  = input.int(12, "  sweep: max bars between sweep and break", minval = 1, group = group_cf)
useDisp   = input.bool(true, "ICT: displacement break candle (+1)", group = group_cf,
     tooltip = "The break candle's BODY must be at least this many ATRs — conviction/MSS-quality, not a drift through the level.")
dispMult  = input.float(0.6, "  displacement: body >= x ATR14", minval = 0.2, step = 0.1, group = group_cf)
useFVG    = input.bool(true, "ICT: FVG in the breakout leg (+1)", group = group_cf,
     tooltip = "A Fair Value Gap printed from the break bar through the retest phase — the retest into the zone is also a return into imbalance.")
minGrade  = input.string("C - all setups", "Signal filter", options = ["A only", "B and above", "C - all setups"], group = group_cf,
     tooltip = "New 7-point scale: HTF 2 + volume 1 + quiet 1 + sweep 1 + displacement 1 + FVG 1. A >= 5, B = 3-4, C <= 2.")

group_sess = "Session filter"
useSessionFilter = input.bool(true,  "Filter by sessions", group = group_sess)
incLondon        = input.bool(true,  "London open (03:00-05:00 NY)", group = group_sess)
incNY            = input.bool(true,  "New York (09:30-11:30 NY)",    group = group_sess)
incAsia          = input.bool(false, "Asia (18:00-03:00 NY)",        group = group_sess)

group_aud = "Audit & runsheet"
showAudit     = input.bool(true, "Audit: keep only PROVEN setups (hit TP1)", group = group_aud,
     tooltip = "A trade earns a permanent yellow box only when it reaches Target 1. Stopped-out trades erase themselves completely.")
maxAudit      = input.int(2, "Successful setups kept on chart", minval = 1, maxval = 10, group = group_aud)
showChecklist = input.bool(true, "Show pre-entry runsheet (bottom right)", group = group_aud)
useRoomFilter = input.bool(false, "Block signals without room to HTF level", group = group_aud)
roomRR        = input.float(1.0, "Min room to HTF level (in R)", minval = 0.5, step = 0.5, group = group_aud)

group_disp = "Display"
showZones      = input.bool(true, "Show S/R zones",  group = group_disp)
showSecondary  = input.bool(true, "Show SECONDARY zones", group = group_disp,
     tooltip = "Off = only PRIMARY zones draw while levels are live. A secondary zone still reappears the moment it breaks (orange RETEST?) or flip-fails (violet) — active setups are never hidden.")
showSignals    = input.bool(true, "Show signals",    group = group_disp)
showDashboard  = input.bool(true, "Show dashboard",  group = group_disp)
showHTFLevels  = input.bool(true, "Show HTF + daily levels", group = group_disp)
maxTradesShown = input.int(2, "Max OPEN trades drawn at once", minval = 1, maxval = 6, group = group_disp)
showArrowHist  = input.bool(false, "Keep signal arrows for ALL historical signals", group = group_disp,
     tooltip = "Off = clean history: only proven setups (yellow boxes) and currently-open trade packages remain visible.")
showBreakLbls  = input.bool(true, "Show break arrows (outline = armed, on break candle)", group = group_disp,
     tooltip = "Outline up/down arrow marks the candle that BROKE a zone (armed, watching for retest). The solid filled arrow at the retest is the actual entry. Outline = watching, solid = go.")
zoneExtend     = input.int(30, "Extend zones right (bars)", minval = 5, maxval = 100, group = group_disp)
lineLen        = input.int(20, "SL/TP line length (bars)",  minval = 10, maxval = 150, group = group_disp)

group_sig = "Colors"
supFill   = input.color(color.new(#00C853, 88), "Support fill (primary)",   group = group_sig)
supFill2  = input.color(color.new(#00C853, 94), "Support fill (secondary)", group = group_sig)
supBorder = input.color(color.new(#00C853, 40), "Support border",           group = group_sig)
resFill   = input.color(color.new(#FF5252, 88), "Resistance fill (primary)",   group = group_sig)
resFill2  = input.color(color.new(#FF5252, 94), "Resistance fill (secondary)", group = group_sig)
resBorder = input.color(color.new(#FF5252, 40), "Resistance border",           group = group_sig)
brkFill   = input.color(color.new(#FFA726, 85), "Broken zone fill",   group = group_sig)
brkBorder = input.color(color.new(#FFA726, 25), "Broken zone border", group = group_sig)
entryCol  = input.color(#00E676, "Long / arrows up",  group = group_sig)
shortCol  = input.color(#FF1744, "Short / arrows down", group = group_sig)
stopCol   = input.color(#FF1744, "Stop loss",  group = group_sig)
tp1Col    = input.color(#448AFF, "Target 1",   group = group_sig)
tp2Col    = input.color(#448AFF, "Target 2",   group = group_sig)

// Pine keeps only a limited window of bar history for drawing coordinates.
// The default ceiling is 300 bars and max_bars_back does NOT reliably raise it
// for box/label x-coords, so every drawing anchor is clamped BELOW that floor.
MAXBACK = 250

atr = ta.atr(14)
volSMA = ta.sma(volume, 20)
_tickSize = syminfo.mintick

// ═══ ICT/SMC SERIES (computed every bar) ═════════════════════════════════════
barBody   = math.abs(close - open)
bullFVG   = low > high[2]                    // bullish Fair Value Gap completing this bar
bearFVG   = high < low[2]
prevLoX   = ta.lowest(low, sweepLen)[1]
prevHiX   = ta.highest(high, sweepLen)[1]
sweptLow  = low  < prevLoX and close > prevLoX    // sell-side liquidity raided, rejected
sweptHigh = high > prevHiX and close < prevHiX    // buy-side liquidity raided, rejected
bsLoSweep = ta.barssince(sweptLow)
bsHiSweep = ta.barssince(sweptHigh)
swpLongOK  = not na(bsLoSweep) and bsLoSweep <= sweepAge   // recent raid below → fuel for a long break
swpShortOK = not na(bsHiSweep) and bsHiSweep <= sweepAge

// ═══ SESSIONS ════════════════════════════════════════════════════════════════
nyMins() =>
    hour(time, "America/New_York") * 100 + minute(time, "America/New_York")

isLondonSession() => nyMins() >= 300  and nyMins() < 500
isNYSession()     => nyMins() >= 930  and nyMins() < 1130
isAsiaSession()   => nyMins() >= 1800 or  nyMins() < 300

isValidSession() =>
    not useSessionFilter or (incLondon and isLondonSession()) or (incNY and isNYSession()) or (incAsia and isAsiaSession())

// ═══ HTF + DAILY LEVELS (previous COMPLETED candles — no repaint) ════════════
htf = timeframe.multiplier >= 60 ? "D" : "60"
[htfPO, htfPH, htfPL, htfPC] = request.security(syminfo.tickerid, htf, [open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[dPH, dPL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
htfBullish = htfPC > htfPO
htfBearish = htfPC < htfPO

plot(showHTFLevels ? htfPH : na, "HTF prev high",   color = color.new(#FFA726, 40), style = plot.style_linebr, linewidth = 1)
plot(showHTFLevels ? htfPL : na, "HTF prev low",    color = color.new(#AB47BC, 40), style = plot.style_linebr, linewidth = 1)
plot(showHTFLevels ? dPH : na,   "Daily prev high", color = color.new(#FFA726, 65), style = plot.style_linebr, linewidth = 2)
plot(showHTFLevels ? dPL : na,   "Daily prev low",  color = color.new(#AB47BC, 65), style = plot.style_linebr, linewidth = 2)

f_roomOK(isLong, entry, stop) =>
    risk = math.abs(entry - stop)
    if isLong
        na(htfPH) or htfPH <= entry or (htfPH - entry) >= risk * roomRR
    else
        na(htfPL) or htfPL >= entry or (entry - htfPL) >= risk * roomRR

// ═══ CONFLUENCE HELPERS ══════════════════════════════════════════════════════
f_nearLevel(lv, t, b, tol) =>
    not na(lv) and lv >= b - tol and lv <= t + tol

f_htfConfluence(t, b) =>
    tol = htfTolATR * atr
    f_nearLevel(htfPH, t, b, tol) or f_nearLevel(htfPL, t, b, tol) or f_nearLevel(dPH, t, b, tol) or f_nearLevel(dPL, t, b, tol)

f_hasRound(t, b) =>
    math.ceil(b / roundStep) * roundStep <= t

gradeReq = minGrade == "A only" ? 3 : minGrade == "B and above" ? 2 : 1

// ═══ ZONE STORAGE ════════════════════════════════════════════════════════════
// state: 0 live | 1 broken up (long pending) | 2 broken down (short pending) | 3 dead
var int[]   zBar    = array.new_int(0)
var float[] zTop    = array.new_float(0)
var float[] zBot    = array.new_float(0)
var bool[]  zIsSup  = array.new_bool(0)
var int[]   zState  = array.new_int(0)
var int[]   zTch    = array.new_int(0)
var int[]   zBrk    = array.new_int(0)
var int[]   zLtc    = array.new_int(0)
var float[] zBrkVR  = array.new_float(0)   // breakout volume / 20-bar avg
var bool[]  zSwp    = array.new_bool(0)    // ICT: liquidity sweep preceded the break
var bool[]  zDsp    = array.new_bool(0)    // ICT: displacement break candle
var bool[]  zFvg    = array.new_bool(0)    // ICT: FVG in the breakout leg
var bool[]  zPrim   = array.new_bool(0)    // cached: is this THE nearest strong zone on its side
var float[] zPbSum  = array.new_float(0)   // pullback volume accumulator
var int[]   zPbN    = array.new_int(0)
var label[] zArmLbl = array.new_label(0)   // the zone's ARMED label — lives and dies with the setup

f_delZone(i) =>
    lbl = array.get(zArmLbl, i)
    if not na(lbl)
        label.delete(lbl)
    array.remove(zArmLbl, i)
    array.remove(zBar, i), array.remove(zTop, i), array.remove(zBot, i)
    array.remove(zIsSup, i), array.remove(zState, i), array.remove(zTch, i)
    array.remove(zBrk, i), array.remove(zLtc, i)
    array.remove(zBrkVR, i), array.remove(zPbSum, i), array.remove(zPbN, i)
    array.remove(zSwp, i), array.remove(zDsp, i), array.remove(zFvg, i)
    if array.size(zPrim) > i
        array.remove(zPrim, i)

f_clearArm(i) =>
    lbl = array.get(zArmLbl, i)
    if not na(lbl)
        label.delete(lbl)
    array.set(zArmLbl, i, label(na))

f_overlaps(t, b) =>
    hit = false
    if array.size(zTop) > 0
        for i = 0 to array.size(zTop) - 1
            if array.get(zState, i) != 3 and b <= array.get(zTop, i) and t >= array.get(zBot, i)
                hit := true
    hit

f_countSide(isSup) =>
    c = 0
    if array.size(zIsSup) > 0
        for i = 0 to array.size(zIsSup) - 1
            if array.get(zIsSup, i) == isSup
                c += 1
    c

f_dropOldest(isSup) =>
    // Evict the oldest LIVE zone first; an armed setup (RETEST?) is only
    // evicted if there is no live zone left to sacrifice
    int idx = -1
    if array.size(zIsSup) > 0
        for i = 0 to array.size(zIsSup) - 1
            if array.get(zIsSup, i) == isSup and array.get(zState, i) == 0
                idx := i
                break
        if idx == -1
            for i = 0 to array.size(zIsSup) - 1
                if array.get(zIsSup, i) == isSup
                    idx := i
                    break
    if idx >= 0
        f_delZone(idx)

f_addZone(t, b, isSup) =>
    if not f_overlaps(t, b)
        if f_countSide(isSup) >= maxZonesToShow
            f_dropOldest(isSup)
        array.push(zBar, bar_index - pivotRight)
        array.push(zTop, t), array.push(zBot, b)
        array.push(zIsSup, isSup)
        array.push(zState, 0), array.push(zTch, 1)
        array.push(zBrk, 0),  array.push(zLtc, bar_index)
        array.push(zBrkVR, 0.0), array.push(zPbSum, 0.0), array.push(zPbN, 0)
        array.push(zSwp, false), array.push(zDsp, false), array.push(zFvg, false)
        array.push(zPrim, false)
        array.push(zArmLbl, label(na))
        // BORN ALREADY BROKEN: in fast moves the break happens BEFORE the pivot
        // confirms (pivotRight-bar lag), so the close-cross can never fire later.
        // Arm the retest at creation instead of leaving a dead flipped zone.
        n = array.size(zState) - 1
        if close < b
            array.set(zState, n, 2), array.set(zBrk, n, bar_index)
            array.set(zBrkVR, n, volSMA > 0 ? volume / volSMA : 1.0)
            array.set(zSwp, n, swpShortOK), array.set(zDsp, n, barBody >= dispMult * atr), array.set(zFvg, n, bearFVG)
            if showSignals and showBreakLbls
                array.set(zArmLbl, n, label.new(bar_index, high + _tickSize * 4, "▼",
                     color = color.new(color.black, 100), textcolor = color.new(shortCol, 25),
                     style = label.style_label_down, size = size.small))
        else if close > t
            array.set(zState, n, 1), array.set(zBrk, n, bar_index)
            array.set(zBrkVR, n, volSMA > 0 ? volume / volSMA : 1.0)
            array.set(zSwp, n, swpLongOK), array.set(zDsp, n, barBody >= dispMult * atr), array.set(zFvg, n, bullFVG)
            if showSignals and showBreakLbls
                array.set(zArmLbl, n, label.new(bar_index, low - _tickSize * 4, "▲",
                     color = color.new(color.black, 100), textcolor = color.new(entryCol, 25),
                     style = label.style_label_up, size = size.small))

// Zone importance: PRIMARY (likely to hold) needs 2+ of: multi-touch, HTF overlap, round number
// Eligibility bar: a zone is "strong" if it clears 2 of 3 (touches, HTF, round)
f_isStrong(i) =>
    t = array.get(zTop, i), b = array.get(zBot, i)
    pts = (array.get(zTch, i) >= 2 ? 1 : 0) + (f_htfConfluence(t, b) ? 1 : 0) + (f_hasRound(t, b) ? 1 : 0)
    pts >= 2

// PRIMARY is RELATIVE: exactly the single NEAREST strong live zone above price
// (primary resistance) and below price (primary support). Everything else is
// secondary, however strong. Recomputed each bar; results cached in zPrim.
f_recomputePrimary() =>
    // clear
    if array.size(zPrim) > 0
        for i = 0 to array.size(zPrim) - 1
            array.set(zPrim, i, false)
    // nearest strong resistance ABOVE price and support BELOW price
    int resIdx = -1
    float resDist = na
    int supIdx = -1
    float supDist = na
    if array.size(zTop) > 0
        for i = 0 to array.size(zTop) - 1
            if array.get(zState, i) == 0 and f_isStrong(i)
                t = array.get(zTop, i), b = array.get(zBot, i)
                if b > close and (na(resDist) or (b - close) < resDist)
                    resDist := b - close
                    resIdx := i
                if t < close and (na(supDist) or (close - t) < supDist)
                    supDist := close - t
                    supIdx := i
    if resIdx >= 0
        array.set(zPrim, resIdx, true)
    if supIdx >= 0
        array.set(zPrim, supIdx, true)

f_isPrimary(i) =>
    array.size(zPrim) > i and array.get(zPrim, i)

// Signal grade: HTF overlap +2, breakout volume +1, quiet pullback +1
// Signal grade — 7-point scale: HTF overlap +2, breakout volume +1, quiet
// pullback +1, liquidity sweep +1, displacement +1, FVG +1.
// A >= 5, B = 3-4, C <= 2. Contributor letters: H V Q S D F.
f_grade(i) =>
    t = array.get(zTop, i), b = array.get(zBot, i)
    brkR = array.get(zBrkVR, i)
    pbN  = array.get(zPbN, i)
    pbR  = pbN > 0 and volSMA > 0 ? (array.get(zPbSum, i) / pbN) / volSMA : brkR
    htfOK   = f_htfConfluence(t, b)
    volOK   = brkR >= volMult
    quietOK = pbR < brkR
    swpOK   = useSweep and array.get(zSwp, i)
    dspOK   = useDisp  and array.get(zDsp, i)
    fvgOK   = useFVG   and array.get(zFvg, i)
    pts = (htfOK ? 2 : 0) + (volOK ? 1 : 0) + (quietOK ? 1 : 0) + (swpOK ? 1 : 0) + (dspOK ? 1 : 0) + (fvgOK ? 1 : 0)
    grade = pts >= 5 ? "A" : pts >= 3 ? "B" : "C"
    rank  = pts >= 5 ? 3 : pts >= 3 ? 2 : 1
    contrib = (htfOK ? "H" : "") + (volOK ? "V" : "") + (quietOK ? "Q" : "") + (swpOK ? "S" : "") + (dspOK ? "D" : "") + (fvgOK ? "F" : "")
    [grade, rank, contrib]

// ═══ SWING DETECTION ═════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLeft, pivotRight)
pl = ta.pivotlow(low, pivotLeft, pivotRight)

if barstate.isconfirmed and not na(pl)
    b = low[pivotRight]
    t = math.min(high[pivotRight], b + zoneMaxATR * atr)
    f_addZone(t, b, true)

if barstate.isconfirmed and not na(ph)
    t = high[pivotRight]
    b = math.max(low[pivotRight], t - zoneMaxATR * atr)
    f_addZone(t, b, false)

// ═══ SIGNAL DRAWINGS (pruned) — TP squares, SL hollow circles ════════════════
var line[]  tradeLns  = array.new_line(0)
var label[] tradeLbls = array.new_label(0)
// One trade = exactly 4 lines + 8 labels, created in order. Trade r's drawings
// therefore live at lines[r*4..r*4+3] and labels[r*8..r*8+7]. Drawings are only
// ever removed whole-trade, at resolution (see OUTCOME AUDIT below).

f_slMark(y, dir) =>
    array.push(tradeLns, line.new(bar_index, y, bar_index + lineLen, y, color = stopCol, width = 1, style = line.style_dotted))
    array.push(tradeLbls, label.new(bar_index + lineLen, y, "○", style = label.style_none, textcolor = stopCol, size = size.large))
    array.push(tradeLbls, label.new(bar_index + lineLen + 4, y, dir + "-SL " + str.tostring(y, format.mintick),
         style = label.style_label_left, color = color.new(stopCol, 90), textcolor = stopCol, size = size.small))

f_tpMark(y, col, txt, dir) =>
    array.push(tradeLns, line.new(bar_index, y, bar_index + lineLen, y, color = col, width = 1, style = line.style_dotted))
    array.push(tradeLbls, label.new(bar_index + lineLen, y, "", style = label.style_square, color = col, size = size.tiny))
    array.push(tradeLbls, label.new(bar_index + lineLen + 4, y, dir + "-" + txt + " " + str.tostring(y, format.mintick),
         style = label.style_label_left, color = color.new(col, 90), textcolor = col, size = size.small))

f_drawTrade(isLong, entry, stop, grade) =>
    risk = math.abs(entry - stop)
    tp1 = isLong ? entry + risk * target1RR : entry - risk * target1RR
    tp2 = isLong ? entry + risk * target2RR : entry - risk * target2RR
    dirCol = isLong ? entryCol : shortCol
    dir = isLong ? "L" : "S"
    array.push(tradeLbls, label.new(bar_index, isLong ? high + _tickSize * 8 : low - _tickSize * 8,
         (isLong ? "LONG [" : "SHORT [") + grade + "] @ " + str.tostring(entry, format.mintick),
         color = color.new(dirCol, 85), textcolor = dirCol,
         style = isLong ? label.style_label_down : label.style_label_up, size = size.normal))
    array.push(tradeLns, line.new(bar_index, entry, bar_index + lineLen, entry, color = color.new(dirCol, 30), width = 1, style = line.style_dotted))
    array.push(tradeLbls, label.new(bar_index + lineLen + 4, entry, dir + "-ENTRY " + str.tostring(entry, format.mintick),
         style = label.style_label_left, color = color.new(dirCol, 90), textcolor = dirCol, size = size.small))
    f_slMark(stop, dir)
    f_tpMark(tp1, tp1Col, "TP1", dir)
    f_tpMark(tp2, tp2Col, "TP2", dir)

// ═══ OUTCOME AUDIT — only trades that reach TP1 earn a permanent mark ════════
var float[] atEntry  = array.new_float(0)
var float[] atStop   = array.new_float(0)
var float[] atTp1    = array.new_float(0)
var bool[]  atIsLong = array.new_bool(0)
var int[]   atBar    = array.new_int(0)
var float[] atZTop   = array.new_float(0)   // the zone that was pierced — kept for the audit
var float[] atZBot   = array.new_float(0)
var int[]   atZBar   = array.new_int(0)     // break bar of that zone
var box[]   winBoxes = array.new_box(0)
var label[] winLbls  = array.new_label(0)

f_removeTrade(r) =>
    for j = 1 to 4
        line.delete(array.get(tradeLns, r * 4))
        array.remove(tradeLns, r * 4)
    for j = 1 to 8
        label.delete(array.get(tradeLbls, r * 8))
        array.remove(tradeLbls, r * 8)
    array.remove(atEntry, r), array.remove(atStop, r), array.remove(atTp1, r)
    array.remove(atIsLong, r), array.remove(atBar, r)
    array.remove(atZTop, r), array.remove(atZBot, r), array.remove(atZBar, r)

f_markSuccess(r) =>
    isL = array.get(atIsLong, r)
    e   = array.get(atEntry, r)
    s   = array.get(atStop, r)
    t1  = array.get(atTp1, r)
    zt  = array.get(atZTop, r)
    zb  = array.get(atZBot, r)
    zbar = math.max(array.get(atZBar, r), bar_index - MAXBACK)
    // The pierced zone — origin evidence, drawn from break bar to TP1 bar
    array.push(winBoxes, box.new(zbar, zt, bar_index, zb,
         bgcolor = color.new(#FFA726, 88), border_color = color.new(#FFA726, 25),
         border_width = 1, border_style = line.style_dashed))
    // The winning run — entry to TP1
    array.push(winBoxes, box.new(math.max(array.get(atBar, r), bar_index - MAXBACK), isL ? t1 : s, bar_index, isL ? s : t1,
         bgcolor = color.new(#FFEB3B, 94), border_color = color.new(#FFEB3B, 0), border_width = 2))
    array.push(winLbls, label.new(math.max(array.get(atBar, r), bar_index - MAXBACK), isL ? t1 : s,
         (isL ? "✔ LONG" : "✔ SHORT") + " hit TP1 (+" + str.tostring(target1RR, "#.#") + "R) | entry " + str.tostring(e, format.mintick) +
         " | zone " + str.tostring(zb, format.mintick) + "–" + str.tostring(zt, format.mintick),
         color = color.new(#FFEB3B, 82), textcolor = color.new(#FFEB3B, 0),
         style = label.style_label_lower_left, size = size.small))
    while array.size(winBoxes) > maxAudit * 2
        box.delete(array.shift(winBoxes))
    while array.size(winLbls) > maxAudit
        label.delete(array.shift(winLbls))

// ═══ PER-ZONE STATE MACHINE ══════════════════════════════════════════════════
bool longSignal       = false
bool shortSignal      = false
bool resistanceBroken = false
bool supportBroken    = false

// Runs on CONFIRMED bars only. On the live candle nothing is decided until the
// close — so entries, stops and targets are computed exactly once and never
// drift with intrabar ticks (runsheet rule 5: wait for the candle to close).
if barstate.isconfirmed and array.size(zTop) > 0
    for i = array.size(zTop) - 1 to 0
        st = array.get(zState, i)
        t  = array.get(zTop, i)
        b  = array.get(zBot, i)

        if st == 0
            entered = high >= b and low <= t
            if entered and (close > t or close < b) and bar_index - array.get(zLtc, i) >= 3
                array.set(zTch, i, array.get(zTch, i) + 1)
                array.set(zLtc, i, bar_index)
            // Break = closes CROSS the zone edge (catches gaps and zones created
            // after price already left, unlike the old open-side condition)
            if close > t and close[1] <= t
                array.set(zState, i, 1), array.set(zBrk, i, bar_index)
                array.set(zBrkVR, i, volSMA > 0 ? volume / volSMA : 1.0)
                array.set(zPbSum, i, 0.0), array.set(zPbN, i, 0)
                array.set(zSwp, i, swpLongOK), array.set(zDsp, i, barBody >= dispMult * atr), array.set(zFvg, i, bullFVG)
                resistanceBroken := true
                if showSignals and showBreakLbls
                    array.set(zArmLbl, i, label.new(bar_index, low - _tickSize * 4, "▲",
                         color = color.new(color.black, 100), textcolor = color.new(entryCol, 25),
                         style = label.style_label_up, size = size.small))
            else if close < b and close[1] >= b
                array.set(zState, i, 2), array.set(zBrk, i, bar_index)
                array.set(zBrkVR, i, volSMA > 0 ? volume / volSMA : 1.0)
                array.set(zPbSum, i, 0.0), array.set(zPbN, i, 0)
                array.set(zSwp, i, swpShortOK), array.set(zDsp, i, barBody >= dispMult * atr), array.set(zFvg, i, bearFVG)
                supportBroken := true
                if showSignals and showBreakLbls
                    array.set(zArmLbl, i, label.new(bar_index, high + _tickSize * 4, "▼",
                         color = color.new(color.black, 100), textcolor = color.new(shortCol, 25),
                         style = label.style_label_down, size = size.small))

        else if st == 1
            bars = bar_index - array.get(zBrk, i)
            confirmNow = bars > gapBars and low <= t and close > t and array.get(zTch, i) >= minTouch and isValidSession()
            if close < b
                array.set(zState, i, 4), array.set(zBrk, i, bar_index)   // flip failed — keep level, recolour
                f_clearArm(i)
            else if bars > retestMaxBars
                array.set(zState, i, 0), array.set(zBrk, i, 0)
                f_clearArm(i)
            else if useRunaway and close > t + runawayATR * atr
                // Price ran away upward without retesting — the round trip needed
                // is too large for this to still be a retest. Expire early.
                array.set(zState, i, 0), array.set(zBrk, i, 0)
                f_clearArm(i)
            else if confirmNow
                stopL = b - _tickSize * 3
                [grade, rank, _c] = f_grade(i)
                if (not useRoomFilter or f_roomOK(true, close, stopL)) and rank >= gradeReq
                    longSignal := true
                    if showSignals
                        f_drawTrade(true, close, stopL, grade)
                        array.push(atEntry, close), array.push(atStop, stopL)
                        array.push(atTp1, close + (close - stopL) * target1RR)
                        array.push(atIsLong, true), array.push(atBar, bar_index)
                        array.push(atZTop, t), array.push(atZBot, b), array.push(atZBar, array.get(zBrk, i))
                        if array.size(atEntry) > maxTradesShown
                            f_removeTrade(0)
                    array.set(zState, i, 3)
            else
                array.set(zPbSum, i, array.get(zPbSum, i) + volume)
                array.set(zPbN, i, array.get(zPbN, i) + 1)
                if bullFVG
                    array.set(zFvg, i, true)

        else if st == 2
            bars = bar_index - array.get(zBrk, i)
            confirmNow = bars > gapBars and high >= b and close < b and array.get(zTch, i) >= minTouch and isValidSession()
            if close > t
                array.set(zState, i, 4), array.set(zBrk, i, bar_index)   // flip failed — keep level, recolour
                f_clearArm(i)
            else if bars > retestMaxBars
                array.set(zState, i, 0), array.set(zBrk, i, 0)
                f_clearArm(i)
            else if useRunaway and close < b - runawayATR * atr
                // Price ran away downward without retesting — expire early.
                array.set(zState, i, 0), array.set(zBrk, i, 0)
                f_clearArm(i)
            else if confirmNow
                stopS = t + _tickSize * 3
                [grade, rank, _c] = f_grade(i)
                if (not useRoomFilter or f_roomOK(false, close, stopS)) and rank >= gradeReq
                    shortSignal := true
                    if showSignals
                        f_drawTrade(false, close, stopS, grade)
                        array.push(atEntry, close), array.push(atStop, stopS)
                        array.push(atTp1, close - (stopS - close) * target1RR)
                        array.push(atIsLong, false), array.push(atBar, bar_index)
                        array.push(atZTop, t), array.push(atZBot, b), array.push(atZBar, array.get(zBrk, i))
                        if array.size(atEntry) > maxTradesShown
                            f_removeTrade(0)
                    array.set(zState, i, 3)
            else
                array.set(zPbSum, i, array.get(zPbSum, i) + volume)
                array.set(zPbN, i, array.get(zPbN, i) + 1)
                if bearFVG
                    array.set(zFvg, i, true)

        else if st == 4
            // FLIP FAILED cooldown: the level is still real — after a few bars
            // it revives as a normal live zone (dynamic role colours it correctly)
            if bar_index - array.get(zBrk, i) > failCoolBars
                array.set(zState, i, 0), array.set(zBrk, i, 0)

if array.size(zState) > 0
    for i = array.size(zState) - 1 to 0
        if array.get(zState, i) == 3
            f_delZone(i)

f_recomputePrimary()

// ═══ TRADE RESOLUTION — losers erase themselves, winners turn yellow ═════════
// Conservative tie-break: if one candle touches both stop and TP1, it counts
// as a stop. The audit must never flatter you.
bool tp1Hit = false
bool slHit  = false
if barstate.isconfirmed and array.size(atEntry) > 0
    for r = array.size(atEntry) - 1 to 0
        if bar_index > array.get(atBar, r)
            isL = array.get(atIsLong, r)
            s   = array.get(atStop, r)
            t1  = array.get(atTp1, r)
            if (isL and low <= s) or (not isL and high >= s)
                slHit := true
                f_removeTrade(r)
            else if (isL and high >= t1) or (not isL and low <= t1)
                tp1Hit := true
                if showAudit
                    f_markSuccess(r)
                f_removeTrade(r)

// ENTRY arrows = solid + large ("go"), distinct from the outline break arrows.
// These are the actual confirmed signals and always show for the live/last bars.
plotshape(showSignals and longSignal,  "Long entry",  shape.arrowup,   location.belowbar, entryCol, size = size.large)
plotshape(showSignals and shortSignal, "Short entry", shape.arrowdown, location.abovebar, shortCol, size = size.large)

// ═══ DRAW ZONES — PRIMARY (holds) vs SECONDARY (likely breaks) ═══════════════
var box[]   zBoxes = array.new_box(0)
var label[] zLbls  = array.new_label(0)

if showZones and barstate.islast
    for bx in zBoxes
        box.delete(bx)
    for lb in zLbls
        label.delete(lb)
    array.clear(zBoxes), array.clear(zLbls)
    rightEdge = bar_index + zoneExtend
    if array.size(zTop) > 0
        for i = 0 to array.size(zTop) - 1
            t = array.get(zTop, i), b = array.get(zBot, i)
            st = array.get(zState, i)
            isSup = array.get(zIsSup, i)
            primary = f_isPrimary(i)
            if not (not showSecondary and st == 0 and not primary)
                // Role is DYNAMIC — decided by where price is NOW, not by the pivot
                // that created the zone. A support that price broke below therefore
                // re-displays as resistance (the flip), never as stale support.
                roleSup = close > t     // zone fully below price → acts as support
                roleRes = close < b     // zone fully above price → acts as resistance
                armed   = st == 1 or st == 2
                fillC   = armed ? brkFill : st == 4 ? color.new(#AB47BC, 86) : roleSup ? (primary ? supFill : supFill2) : roleRes ? (primary ? resFill : resFill2) : color.new(color.gray, 88)
                borderC = armed ? brkBorder : st == 4 ? color.new(#AB47BC, 30) : roleSup ? supBorder : roleRes ? resBorder : color.new(color.gray, 45)
                array.push(zBoxes, box.new(math.max(array.get(zBar, i), bar_index - MAXBACK), t, rightEdge, b,
                     bgcolor = fillC, border_color = borderC,
                     border_width = primary ? 2 : 1,
                     border_style = primary ? line.style_solid : line.style_dashed))
                origin = st == 0 and roleRes and isSup ? "(ex-S) " : st == 0 and roleSup and not isSup ? "(ex-R) " : ""
                tag = armed ? (st == 1 ? "RETEST? LONG " : "RETEST? SHORT ") : st == 4 ? "FLIP FAILED " : roleSup or roleRes ? (primary ? "PRIMARY " : "SECONDARY ") + (roleSup ? "SUPPORT " : "RESISTANCE ") + origin : "IN TEST "
                array.push(zLbls, label.new(rightEdge - 2, (t + b) / 2,
                     tag + str.tostring(isSup ? b : t, format.mintick) + " (" + str.tostring(array.get(zTch, i)) + "t)",
                     color = color.new(borderC, 75), textcolor = color.white,
                     style = label.style_label_left, size = size.small))

// ═══ PRE-ENTRY RUNSHEET ══════════════════════════════════════════════════════
f_mark(ok) => ok ? "PASS" : "FAIL"
f_markClr(ok) => ok ? color.new(#00E676, 0) : color.new(#FF5252, 0)

if showChecklist and barstate.islast
    int   ni = -1
    float nd = na
    if array.size(zTop) > 0
        for i = 0 to array.size(zTop) - 1
            if array.get(zState, i) == 1 or array.get(zState, i) == 2
                d = math.abs((array.get(zTop, i) + array.get(zBot, i)) / 2 - close)
                if na(nd) or d < nd
                    nd := d
                    ni := i

    var table cl = table.new(position.bottom_right, 2, 14,
         bgcolor = color.new(#0B0E14, 5), border_width = 1, border_color = color.new(#3D5A80, 40),
         frame_width = 1, frame_color = color.new(#EE9B00, 40))

    table.cell(cl, 0, 0, "PRE-ENTRY RUNSHEET", text_color = color.new(#EE9B00, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(cl, 1, 0, "", text_size = size.small)

    if ni == -1
        table.cell(cl, 0, 1, "Setup armed:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 1, "NONE — wait for a breakout", text_color = color.gray, text_size = size.tiny, text_halign = text.align_right)
        for r = 2 to 13
            table.cell(cl, 0, r, "", text_size = size.tiny)
            table.cell(cl, 1, r, "", text_size = size.tiny)
    else
        isLong = array.get(zState, ni) == 1
        t   = array.get(zTop, ni)
        b   = array.get(zBot, ni)
        tch = array.get(zTch, ni)
        bars = bar_index - array.get(zBrk, ni)
        barsLeft = retestMaxBars - bars
        hypEntry = isLong ? t : b
        hypStop  = isLong ? b - _tickSize * 3 : t + _tickSize * 3
        okSess   = isValidSession()
        okTouch  = tch >= minTouch
        okGap    = bars > gapBars
        okWin    = barsLeft >= 0
        okRoom   = f_roomOK(isLong, hypEntry, hypStop)
        [grade, rank, gContrib] = f_grade(ni)
        okGrade  = rank >= gradeReq
        biasAligned = isLong ? htfBullish : htfBearish
        confirmNow  = isLong ? (low <= t and close > t) : (high >= b and close < b)
        allCore  = okSess and okTouch and okGap and okWin and okRoom and okGrade

        table.cell(cl, 0, 1, "Direction:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 1, isLong ? "LONG (res broken)" : "SHORT (sup broken)", text_color = isLong ? entryCol : shortCol, text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 2, "1. Session window:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 2, f_mark(okSess), text_color = f_markClr(okSess), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 3, "2. Level touches:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 3, str.tostring(tch) + "/" + str.tostring(minTouch) + " " + f_mark(okTouch), text_color = f_markClr(okTouch), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 4, "3. Body-close break:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 4, "PASS (" + str.tostring(bars) + " bars ago)", text_color = f_markClr(true), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 5, "4. Gap after break:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 5, f_mark(okGap), text_color = f_markClr(okGap), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 6, "5. Retest window:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 6, str.tostring(math.max(barsLeft, 0)) + " bars left " + f_mark(okWin), text_color = f_markClr(okWin), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 7, "6. Room to HTF level:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 7, f_mark(okRoom), text_color = f_markClr(okRoom), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 8, "7. Grade (H V Q S D F):", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 8, grade + " [" + (gContrib == "" ? "none" : gContrib) + "] " + f_mark(okGrade), text_color = f_markClr(okGrade), text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 9, "8. HTF bias aligned:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 9, biasAligned ? "YES" : "NO (advisory)", text_color = biasAligned ? color.new(#00E676, 0) : color.orange, text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 10, "  → close " + (isLong ? "ABOVE" : "BELOW") + ":", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 10, str.tostring(isLong ? t : b, format.mintick), text_color = color.new(#EE9B00, 0), text_size = size.tiny, text_halign = text.align_right)
        trigPx = isLong ? t : b
        distPx = math.abs(close - trigPx)
        distATR = atr > 0 ? distPx / atr : 0.0
        distClr = distATR <= 1.0 ? color.new(#00E676, 0) : distATR <= 2.0 ? color.orange : color.new(#FF5252, 0)
        table.cell(cl, 0, 11, "  distance to trigger:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 11, str.tostring(distPx, format.mintick) + " pts (" + str.tostring(distATR, "#.#") + " ATR)", text_color = distClr, text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 12, "9. Confirmation candle:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 12, confirmNow ? "FORMING — wait for close" : "not yet", text_color = confirmNow ? color.orange : color.gray, text_size = size.tiny, text_halign = text.align_right)
        table.cell(cl, 0, 13, "ALL CORE CHECKS:", text_color = color.new(#EE9B00, 0), text_size = size.tiny, text_halign = text.align_left)
        table.cell(cl, 1, 13, allCore ? "GO if candle confirms" : "NO TRADE", text_color = f_markClr(allCore), text_size = size.tiny, text_halign = text.align_right)

// ═══ DASHBOARD ═══════════════════════════════════════════════════════════════
if showDashboard and barstate.islast
    string sessionName = "OFF HOURS"
    color  sessionClr  = color.gray
    if isLondonSession()
        sessionName := "LONDON OPEN", sessionClr := color.orange
    else if isNYSession()
        sessionName := "NY OPEN", sessionClr := color.green
    else if isAsiaSession()
        sessionName := "ASIA (mark levels)", sessionClr := color.blue

    pendingSetups = 0
    primaryCount = 0
    liveHold = 0
    armedLong = 0
    armedShort = 0
    flipFailed = 0
    if array.size(zState) > 0
        for i = 0 to array.size(zState) - 1
            stt = array.get(zState, i)
            if stt == 0
                liveHold += 1
                if f_isPrimary(i)
                    primaryCount += 1
            else if stt == 1
                armedLong += 1
                pendingSetups += 1
            else if stt == 2
                armedShort += 1
                pendingSetups += 1
            else if stt == 4
                flipFailed += 1

    var table dash = table.new(position.top_right, 2, 9,
         bgcolor = color.new(#0B0E14, 5), border_width = 1, border_color = color.new(#3D5A80, 40),
         frame_width = 1, frame_color = color.new(#EE9B00, 40))
    table.cell(dash, 0, 0, "B&R DASHBOARD", text_color = color.new(#EE9B00, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, "", text_size = size.small)
    table.cell(dash, 0, 1, "Session:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, sessionName, text_color = sessionClr, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 2, "HTF bias:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, htfBullish ? "BULLISH" : htfBearish ? "BEARISH" : "NEUTRAL", text_color = htfBullish ? color.green : htfBearish ? color.red : color.gray, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 3, "ZONE STATE", text_color = color.new(#EE9B00, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, "", text_size = size.tiny)
    table.cell(dash, 0, 4, "  live (holding):", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(liveHold) + "  (" + str.tostring(primaryCount) + " primary)", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 5, "  RETEST? long:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(armedLong), text_color = armedLong > 0 ? color.new(#00E676, 0) : color.gray, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 6, "  RETEST? short:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(armedShort), text_color = armedShort > 0 ? color.new(#FF5252, 0) : color.gray, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 7, "  flip failed:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(flipFailed), text_color = flipFailed > 0 ? color.new(#AB47BC, 0) : color.gray, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 8, "Total armed:", text_color = color.new(#98C1D9, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(pendingSetups), text_color = pendingSetups > 0 ? color.orange : color.gray, text_size = size.tiny, text_halign = text.align_right)

// ═══ ALERTS ══════════════════════════════════════════════════════════════════
alertcondition(resistanceBroken, title = "Resistance breakout", message = 'B&R: resistance broken on {{ticker}} at {{close}}. Watch for retest.')
alertcondition(supportBroken,    title = "Support breakout",    message = 'B&R: support broken on {{ticker}} at {{close}}. Watch for retest.')
alertcondition(longSignal,       title = "Long entry",  message = 'B&R LONG on {{ticker}} at {{close}} — retest confirmed (see grade on chart).')
alertcondition(shortSignal,      title = "Short entry", message = 'B&R SHORT on {{ticker}} at {{close}} — retest confirmed (see grade on chart).')
alertcondition(longSignal or shortSignal, title = "Any entry", message = 'B&R signal on {{ticker}} at {{close}}.')
alertcondition(tp1Hit, title = "TP1 reached", message = 'B&R: open trade reached TP1 on {{ticker}} — setup marked as proven.')
alertcondition(slHit,  title = "Stop hit",    message = 'B&R: open trade stopped out on {{ticker}} — drawings cleared.')
````
