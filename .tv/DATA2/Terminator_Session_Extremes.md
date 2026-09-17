<!-- tradingview-pine-id: PUB;5d76fe5eea284e908cf7e8230c0cd5da -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Terminator Session Extremes

Source: https://www.tradingview.com/script/M7D0TNnl-Terminator-Session-Extremes/

## Description

Terminator Session Extremes — Summary

Purpose: An adaptive predictor that draws the likely daily High and Low on an intraday chart (built for 5m). It's a prediction/visualization tool, not a trade signal.

The core idea

You can't call both daily extremes at the open (~3% dead-on, we proved this). But the market usually prints one extreme early (the counter-trend side) and extends the other way. So the script waits for confirmation, then predicts each side differently.

How it works, step by step

1. Opening range (09:30–09:45) — tracks the first 15 minutes' high/low. No prediction locked yet.
2. Provisional band — while waiting, draws a faint dotted open ± (fraction × range forecast) zone as a placeholder guess (calibrated: 80% edges contain the day's extreme ~80% of the time).
3. Breakout (~09:50) — when price closes beyond the opening range, direction is confirmed, and it locks two lines:
  - Locked extreme (solid, high-confidence) — the counter-trend extreme (the low if it broke up, the high if it broke down). This is the accurate side: it's the day's true extreme ~57% exactly / 62% within ±10 pts on real MNQ.
  - Extension estimate (dashed, rough) — the other side, projected as locked ± 2.2 × opening-range size (a measured move; MAPE ~30%).
4. Self-correct — if price later breaks the opposite side of the opening range (a failed breakout/reversal), it flips direction and re-locks the lines. Fixes the ~39% of reversal days, so accuracy climbs through the session (55%→78%).
5. Alert fires on each lock / re-lock.

---

## Source Code

````pine
//@version=6
// =============================================================================
// Terminator Session Extremes  (adaptive daily High/Low predictor)
// -----------------------------------------------------------------------------
// You cannot call BOTH daily extremes from the open (~3% dead-on, validated on 7y
// real MNQ/MES). What you CAN do: the market prints one extreme early (the
// counter-trend side), then extends the other way. So this tool WAITS for the
// opening range to break (direction confirmation, ~09:50 median), then:
//   * LOCKS the counter-trend extreme = the running extreme up to the breakout.
//     On real futures this IS the day's true extreme 57% exactly / 62% within
//     +-10pt (MNQ). This is the high-confidence predicted High or Low.
//   * ESTIMATES the extension extreme = locked extreme +/- a measured move of the
//     opening-range size (OR-size predicts the day's range better than EWMA:
//     corr 0.66 vs 0.57; MAPE 30% vs 40%). Still a rough target, shown dashed.
//   * Before the breakout it shows a provisional expected-range band (open +/- q
//     * forecast) as the placeholder prediction.
// Prediction / visualization tool - not a trade trigger. Run on a 5m chart.
// =============================================================================
indicator("Terminator Session Extremes", overlay=true, max_lines_count=500, max_labels_count=200)

// ---------------- inputs ----------------
tz       = input.string("America/New_York", "Exchange timezone", group="SESSION")
rthSes   = input.session("0930-1600", "RTH session", group="SESSION")
orMin    = input.int(15, "Opening-range minutes (direction trigger)", minval=5, group="SESSION")
selfCorr = input.bool(true, "Self-correct (re-lock when direction flips)", group="SESSION")
bufFrac  = input.float(0.0, "Breakout buffer (x opening range, higher = surer/later)", minval=0, maxval=1, step=0.05, group="SESSION")

ewLen    = input.int(10, "Range-forecast EWMA length (sessions)", minval=2, group="FORECAST")
covSel   = input.string("80%", "Provisional-band coverage", options=["68%", "80%", "90%"], group="FORECAST")
showBand = input.bool(true, "Show provisional band before breakout", group="FORECAST")
extORm   = input.float(2.2, "Extension = OR-size x", minval=0, step=0.1, group="FORECAST", tooltip="Measured move of the opening-range size projected from the locked extreme. OR-size predicts the day range better than EWMA.")
extEWm   = input.float(0.0, "Extension EWMA weight (optional floor)", minval=0, step=0.1, group="FORECAST")

colLock  = input.color(color.new(color.lime, 0),  "Locked extreme (high-confidence)", group="STYLE")
colExt   = input.color(color.new(color.orange, 0),"Extension estimate", group="STYLE")
colBand  = input.color(color.new(color.gray, 0),  "Provisional band", group="STYLE")
lineWid  = input.int(2, "Line width", minval=1, group="STYLE")
showLbl  = input.bool(true, "Show labels", group="STYLE")

// EWMA-fitted band fractions (q_up / q_dn) from 7y real index futures
qUp = covSel == "68%" ? 0.60 : covSel == "80%" ? 0.78 : 0.98
qDn = covSel == "68%" ? 0.61 : covSel == "80%" ? 0.87 : 1.21

// ---------------- session state ----------------
var float ewR    = na            // EWMA range forecast (through yesterday)
var float fcR    = na            // forecast locked for today
var float o0     = na
var int   t0     = na
var int   tEnd   = na
var float orH    = na
var float orL    = na
var bool  orDone = false
var float sHi    = na
var float sLo    = na
var int   dir    = 0             // +1 broke up (predict LOW), -1 broke down (predict HIGH), 0 not yet
var line  lnLock = na            // high-confidence counter-trend extreme
var line  lnExt  = na            // extension estimate
var label lbLock = na
var label lbExt  = na

f_style() => line.style_dashed
alpha = 2.0 / (ewLen + 1)

in_rth = not na(time(timeframe.period, rthSes, tz))
newSes = in_rth and not in_rth[1]
endSes = (not in_rth) and in_rth[1]

if newSes
    fcR := ewR
    o0 := open
    t0 := time
    tEnd := timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), 16, 0)
    orH := high
    orL := low
    orDone := false
    sHi := high
    sLo := low
    dir := 0
    lnLock := na
    lnExt := na
    lbLock := na
    lbExt := na
else if in_rth
    sHi := math.max(nz(sHi, high), high)
    sLo := math.min(nz(sLo, low), low)
    if not orDone
        if time < t0 + orMin * 60000
            orH := math.max(nz(orH, high), high)
            orL := math.min(nz(orL, low), low)
        else
            orDone := true

// provisional band drawn once when the OR completes (before breakout)
if in_rth and orDone and not orDone[1] and showBand and not na(fcR) and fcR > 0
    line.new(t0, o0 + qUp*fcR, tEnd, o0 + qUp*fcR, xloc=xloc.bar_time, color=color.new(colBand, 30), width=1, style=line.style_dotted)
    line.new(t0, o0 - qDn*fcR, tEnd, o0 - qDn*fcR, xloc=xloc.bar_time, color=color.new(colBand, 30), width=1, style=line.style_dotted)

// (re)lock on a confirmed break of the opening range. First break sets the
// prediction; if selfCorr, a later break of the OPPOSITE edge flips direction and
// re-locks the counter-trend extreme (self-correcting on whipsaw / failed breakouts).
if in_rth and orDone and not na(fcR) and fcR > 0 and (selfCorr or dir == 0)
    float orSize = orH - orL
    float upT = orH + bufFrac * orSize
    float dnT = orL - bufFrac * orSize
    bool flip = false
    bool bull = false
    if dir <= 0 and close > upT
        dir := 1
        bull := true
        flip := true
    else if dir >= 0 and close < dnT
        dir := -1
        bull := false
        flip := true
    if flip
        float lockExtreme = bull ? sLo : sHi                     // counter-trend extreme = high-confidence prediction
        float extAmt = extORm * orSize + extEWm * fcR            // OR measured-move (+ optional EWMA floor)
        float extEstimate = bull ? lockExtreme + extAmt : lockExtreme - extAmt
        string lkTxt = (bull ? "Pred LOW  " : "Pred HIGH  ") + str.tostring(lockExtreme, format.mintick)
        string exTxt = (bull ? "Pred HIGH (est)  " : "Pred LOW (est)  ") + str.tostring(extEstimate, format.mintick)
        bool first = na(lnLock)
        if first
            lnLock := line.new(t0, lockExtreme, tEnd, lockExtreme, xloc=xloc.bar_time, color=colLock, width=lineWid, style=line.style_solid)
            lnExt  := line.new(t0, extEstimate, tEnd, extEstimate, xloc=xloc.bar_time, color=colExt, width=lineWid, style=f_style())
            if showLbl
                lbLock := label.new(tEnd, lockExtreme, lkTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=colLock, size=size.small, textalign=text.align_left)
                lbExt  := label.new(tEnd, extEstimate, exTxt, xloc=xloc.bar_time, style=label.style_none, textcolor=colExt, size=size.small, textalign=text.align_left)
        else
            line.set_y1(lnLock, lockExtreme)
            line.set_y2(lnLock, lockExtreme)
            line.set_y1(lnExt, extEstimate)
            line.set_y2(lnExt, extEstimate)
            if showLbl
                label.set_y(lbLock, lockExtreme)
                label.set_text(lbLock, lkTxt)
                label.set_y(lbExt, extEstimate)
                label.set_text(lbExt, exTxt)
        alert("Session extremes " + (first ? "locked: " : "re-locked: ") + (bull ? "predicted LOW " : "predicted HIGH ") + str.tostring(lockExtreme, format.mintick), alert.freq_once_per_bar)

// update the EWMA range forecast at each RTH close (for use next session)
if endSes and not na(sHi) and not na(sLo)
    float sRange = sHi - sLo
    ewR := na(ewR) ? sRange : alpha * sRange + (1 - alpha) * ewR
````
