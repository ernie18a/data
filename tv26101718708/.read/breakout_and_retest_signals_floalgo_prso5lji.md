# Breakout and Retest Signals - FloAlgo

- url: https://www.tradingview.com/script/Prso5Lji-Breakout-and-Retest-Signals-FloAlgo/
- type: indicator
- pine_id: PUB;b549125f8db54df0ba1f680a0e13c2f9
- version: 1.0

## Description

This indicator detects breakout and retest signals by identifying key pivot zones and validating price rejection through wick sweeps and volume analysis.

[b]How It Works[/b]

The script operates in three stages:
[list]
[*]Pivot Zone Detection — Identifies swing highs and lows, then constructs zones anchored to the candle body and wick that formed the pivot. Demand zones span from body top down to wick low; supply zones span from wick high down to body bottom.
[*]Rejection Validation — Confirms a valid signal when price sweeps beyond the zone extreme (wick tip) and closes back through the zone body, indicating institutional liquidity capture.
[*]Volume Confirmation — Uses lower timeframe volume delta and buy/sell ratio to validate signal strength, filtering weak rejections with insufficient conviction.
[/list]

[b]Key Advantages[/b]
[list]
[*]No Repaint — Single-period pivot detection ensures signals fire on confirmed historical bars, eliminating repaint delay between alert and visual.
[*]Fixed Width Zones — Zones do not grow indefinitely; they are drawn with fixed horizontal width and trimmed only on signal, keeping charts clean.
[*]Range-Based Overlap Guard — Demand and supply zones cannot overlap; range-based checking prevents conflicting zones from occupying the same price area.
[*]Professional Visuals — No text labels or arrow clutter; only shaded zones and volume ratio splits for clean, professional appearance.
[*]Accurate Zone Geometry — Zones anchored to actual candle body and wick formations, not flat ATR bands.
[*]Auto-Cleanup — Zones are automatically removed one bar after signal or on expiry, preventing chart clutter.
[*]Seconds Chart Support — Volume timeframe input guarded to prevent errors on sub-minute charts.
[*]No Signal Conflicts — Removed confirmation divisor that caused opposing signals on the same bar.
[/list]

[b]Zone Lifecycle[/b]
[list]
[*]Unlike traditional indicators that grow zones indefinitely, this script uses a fixed-width approach:
[*]Zones are drawn from the pivot candle to a fixed future bar (born + maxLife)
[*]Upon signal, the zone right edge is trimmed to the signal bar
[*]The zone remains visible for one bar after the signal, then is automatically removed
[*]Expired zones without signals are cleanly purged to prevent chart clutter
[/list]

[b]Visual Elements[/b]
[list]
[*]Shaded boxes marking demand (green) and supply (red) pivot zones
[*]Volume ratio split boxes within zones showing buy/sell pressure balance
[*]Dashed target projection lines from signal bars
[*]Zone borders fade and thin out after signal confirmation
[/list]

[b]Key Settings[/b]
[list]
[*]Swing Length — Sensitivity of pivot high/low detection
[*]Max Bars Active — Fixed horizontal width of zones in bars
[*]Min Bars Between — Minimum bars between consecutive signals
[*]Max Zones Per Side — Maximum active zones per direction
[*]Volume TF — Frame for volume delta analysis
[*]Show Ratio Split — Display buy/sell volume ratio inside zones
[*]Show TP Line — Display target projection lines
[/list]

## Source Code

````pine
// © FloAlgo
//@version=6
indicator("Breakout and Retest Signals [FloAlgo]", "FloAlgo - Breakout & Retest", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

import TradingView/ta/9

// ══════════════════════════════════════════════════════
// inputs
// ══════════════════════════════════════════════════════

swingLen   = input.int(10,  "Swing Length",       minval=2,  group="Swing")
maxLife    = input.int(400, "Max Bars Active",    minval=20, group="Swing")
minGap     = input.int(3,   "Min Bars Between",   minval=0,  group="Swing")
maxZones   = input.int(5,   "Max Zones Per Side", minval=1, maxval=10, group="Swing")

ltf_       = input.timeframe("1", "Volume TF",       group="Volume", tooltip="Must be ≤ chart timeframe. Use '1' for most charts, match chart TF on seconds/tick charts.")
showRatio  = input.bool(true,     "Show Ratio Split",group="Volume")
showTarget = input.bool(true,     "Show TP Line",    group="Visuals")

cBull      = input.color(#00c176, "Bull", inline="col", group="Visuals")
cBear      = input.color(#ff3d3d, "Bear", inline="col", group="Visuals")

// ══════════════════════════════════════════════════════
// types
// ══════════════════════════════════════════════════════

// Zone geometry:
//   Demand — top=body high of pivot low candle, bot=wick low (extreme rejection point)
//   Supply — top=wick high (extreme), bot=body low of pivot high candle
// Zone right edge is FIXED at spawn time (pvBar + maxLife)
// It does NOT grow every bar. Only trimmed by setBack on signal or expiry.

type Zone
    box   bx
    box   rbx1
    box   rbx2
    line  rmid
    int   state      // 1=active, 2=invalidated (price broke clean through)
    float extreme    // wick tip: low for demand, high for supply
    float bodyHi
    float bodyLo
    int   born       // bar_index of pivot candle
    int   lastSig

// ══════════════════════════════════════════════════════
// helpers
// ══════════════════════════════════════════════════════

solid(color c) => color.rgb(color.r(c), color.g(c), color.b(c))

safeRatio(float a, float b) =>
    av = nz(a, 0.0)
    bv = nz(b, 0.0)
    bv == 0.0 ? 1.0 : math.abs(av / bv)

purge(Zone z) =>
    z.bx.delete()
    z.rbx1.delete()
    z.rbx2.delete()
    z.rmid.delete()

// ratio split drawn once at signal bar — always inside the static zone box
drawRatio(Zone z, int sigBar, float ur, float dr, color cu, color cd) =>
    z.rbx1.delete()
    z.rbx2.delete()
    z.rmid.delete()
    if z.bodyHi > z.bodyLo
        mid  = math.avg(z.bodyHi, z.bodyLo)
        span = math.max(sigBar - z.born, 1)
        ex1  = z.born + int(span * math.min(ur, 1.0))
        ex2  = z.born + int(span * math.min(dr, 1.0))
        z.rbx1 := box.new(z.born, z.bodyHi, math.max(ex1, z.born+1), mid,     border_color=color(na), bgcolor=color.new(cd, 60))
        z.rbx2 := box.new(z.born, mid,      math.max(ex2, z.born+1), z.bodyLo, border_color=color(na), bgcolor=color.new(cu, 60))
        z.rmid := line.new(z.born, mid, sigBar, mid, color=color.new(chart.fg_color, 75), style=line.style_dashed)

// ══════════════════════════════════════════════════════
// core calculations
// ══════════════════════════════════════════════════════

n    = bar_index

// single-period pivot — no confirmation divisor
// pivot fires at bar[swingLen], which is a confirmed historical bar — no repaint
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow (low,  swingLen, swingLen)

// guard: ltf must not exceed chart timeframe (causes RE on seconds charts)
[upv, dnv, dv] = ta.requestUpAndDownVolume(ltf_)

var Zone[] demands  = array.new<Zone>()
var Zone[] supplies = array.new<Zone>()

var bool alertBull = false
var bool alertBear = false
alertBull := false
alertBear := false

// ══════════════════════════════════════════════════════
// spawn demand zone — fixed right edge at born + maxLife
// ══════════════════════════════════════════════════════

if not na(pl)
    pvBar  = n - swingLen
    pvBHi  = math.max(open[swingLen], close[swingLen])
    pvBLo  = math.min(open[swingLen], close[swingLen])
    pvLow  = low[swingLen]

    // skip doji (no body) or flat wick
    if pvBHi > pvLow
        isDup = false
        for z in demands
            if pvLow >= z.extreme and pvLow <= z.bodyHi
                isDup := true
                break
        if not isDup
            for z in supplies
                if z.state == 1 and pvBHi >= z.bodyLo and pvLow <= z.extreme
                    isDup := true
                    break
        if not isDup
            rEdge = pvBar + maxLife
            bx    = box.new(pvBar, pvBHi, rEdge, pvLow, bgcolor=color.new(cBull, 82), border_color=color.new(cBull, 65), border_width=1)
            demands.unshift(Zone.new(bx, box(na), box(na), line(na), 1, pvLow, pvBHi, pvBLo, pvBar, -999))
            if demands.size() > maxZones
                purge(demands.pop())

// ══════════════════════════════════════════════════════
// spawn supply zone — fixed right edge at born + maxLife
// ══════════════════════════════════════════════════════

if not na(ph)
    pvBar  = n - swingLen
    pvBHi  = math.max(open[swingLen], close[swingLen])
    pvBLo  = math.min(open[swingLen], close[swingLen])
    pvHigh = high[swingLen]

    if pvHigh > pvBLo
        isDup = false
        for z in supplies
            if pvHigh <= z.extreme and pvHigh >= z.bodyLo
                isDup := true
                break
        if not isDup
            for z in demands
                if z.state == 1 and pvHigh >= z.extreme and pvBLo <= z.bodyHi
                    isDup := true
                    break
        if not isDup
            rEdge = pvBar + maxLife
            bx    = box.new(pvBar, pvHigh, rEdge, pvBLo, bgcolor=color.new(cBear, 82), border_color=color.new(cBear, 65), border_width=1)
            supplies.unshift(Zone.new(bx, box(na), box(na), line(na), 1, pvHigh, pvHigh, pvBLo, pvBar, -999))
            if supplies.size() > maxZones
                purge(supplies.pop())

// ══════════════════════════════════════════════════════
// process demand zones
// signal = wick below extreme AND close above bodyHi (full rejection)
// invalidate = close below extreme (price accepted below zone)
// ══════════════════════════════════════════════════════

if demands.size() > 0
    for i = demands.size() - 1 to 0
        z = demands.get(i)

        // expired
        if n > z.born + maxLife
            purge(z)
            demands.remove(i)
            continue

        if z.state == 1
            // price closed below wick extreme — zone invalidated
            if close < z.extreme
                purge(z)
                demands.remove(i)
                continue

            // signal: wick below extreme, close above body top
            if low < z.extreme and close > z.bodyHi and n - z.lastSig >= minGap
                ur = safeRatio(nz(upv[swingLen]), nz(dnv[swingLen]))
                dr = safeRatio(nz(dnv[swingLen]), nz(upv[swingLen]))
                z.bx.set_right(n)
                if showRatio
                    drawRatio(z, n, ur, dr, cBull, cBear)
                if showTarget
                    dist = close - z.extreme
                    if dist > 0
                        line.new(n, close, n + 40, close + dist, color=color.new(cBull, 50), style=line.style_dashed, width=1)
                z.lastSig := n
                z.state   := 2
                alertBull := true

        else if z.state == 2
            // keep zone visible on signal bar, remove next bar
            if n > z.lastSig
                purge(z)
                demands.remove(i)

// ══════════════════════════════════════════════════════
// process supply zones
// signal = wick above extreme AND close below bodyLo (full rejection)
// invalidate = close above extreme
// ══════════════════════════════════════════════════════

if supplies.size() > 0
    for i = supplies.size() - 1 to 0
        z = supplies.get(i)

        if n > z.born + maxLife
            purge(z)
            supplies.remove(i)
            continue

        if z.state == 1
            if close > z.extreme
                purge(z)
                supplies.remove(i)
                continue

            if high > z.extreme and close < z.bodyLo and n - z.lastSig >= minGap
                ur = safeRatio(nz(upv[swingLen]), nz(dnv[swingLen]))
                dr = safeRatio(nz(dnv[swingLen]), nz(upv[swingLen]))
                z.bx.set_right(n)
                if showRatio
                    drawRatio(z, n, ur, dr, cBear, cBull)
                if showTarget
                    dist = z.extreme - close
                    if dist > 0
                        line.new(n, close, n + 40, close - dist, color=color.new(cBear, 50), style=line.style_dashed, width=1)
                z.lastSig := n
                z.state   := 2
                alertBear := true

        else if z.state == 2
            if n > z.lastSig
                purge(z)
                supplies.remove(i)

// ══════════════════════════════════════════════════════
// alerts
// ══════════════════════════════════════════════════════

alertcondition(alertBull, "FloAlgo — Bull Signal", "FloAlgo: Bullish breakout & retest signal")
alertcondition(alertBear, "FloAlgo — Bear Signal", "FloAlgo: Bearish breakout & retest signal")
````
