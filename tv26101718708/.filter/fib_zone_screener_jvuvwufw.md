# Fib Zone Screener

- url: https://www.tradingview.com/script/jVuvWufW-Fib-Zone-Screener/
- type: indicator
- pine_id: PUB;13c363d97dfd4e7baaf368842cc647f4
- version: 2.0

## Description

# Fib Zone Screener — TradingView publish description

## Title
Fib Zone Screener

## Short description (one-liner)
Flags when price is inside a Fibonacci retracement zone — direction-aware, so one setup works for both longs and shorts, and built to filter across a whole watchlist in the Pine Screener.

---

## Full description

**Fib Zone Screener** answers one question, per symbol, on every scan: *has price pulled back into a Fibonacci retracement zone right now — and is it a long or a short?*

It reads pure price action (no pivots, no moving averages, no `request.security`), so it stays fast enough to run across an entire watchlist in the **Pine Screener** while still drawing clean, readable zones on a single chart.

### How it works

For the chosen **Lookback**, the script finds the window's **highest high** and **lowest low**, then decides the swing direction from **which extreme is more recent**:

- **High is more recent** → the last leg was up → **long context** (a pullback is a dip to buy).
- **Low is more recent** → the last leg was down → **short context** (a pullback is a bounce to sell).

Retrace is always measured **from that most-recent extreme back toward the origin**, so the same zone numbers describe both sides:

```
Retrace  0.0 = at the extreme (no pullback)
         0.5 = halfway back
       0.618 = the golden ratio
       0.786 = deep pullback
         1.0 = fully retraced to the origin
```

Because the measurement flips with direction, **you set the zone once and it works for longs and shorts** — you don't need a separate short version or a mirrored scale.

### Three zones, three flags

The indicator returns three yes/no values — one per zone (all boundaries are inputs):

- **In Zone 1** — default **0.5 – 0.618** (the classic golden pullback zone)
- **In Zone 2** — default **0.618 – 0.786** (deeper pullback)
- **In Zone 3** — default **0.786 – 1.0** (very deep / near full retrace)

Each is `1` when price is inside that zone, `0` otherwise.

### On-chart drawing

The selected window's zones are drawn as **outlined boxes**, labelled with their ratios and colored by direction — **teal on the long side, red on the short side** — so a screener hit looks exactly like a hand-drawn fib. The boxes extend a few bars past the current candle so the latest wicks stay visible.

### Using it in the Pine Screener

1. Save the script and add it to your chart, then **star it as a favorite** — the Pine Screener only lists favorited indicators.
2. Open the **Pine Screener**, choose your watchlist and timeframe, and select **Fib Zone Screener**.
3. Add the columns you want (Manage Columns) and filter, for example:
   - **Longs in the golden zone:** `Direction == 1` and `In Zone 1 == 1`
   - **Shorts in the golden zone:** `Direction == -1` and `In Zone 1 == 1`
   - **Deeper pullbacks:** use `In Zone 2 == 1`
4. Change the **Lookback** or any zone's **From/To** and re-scan to look at a different horizon or depth.

"Last N bars" means N bars of the **screener's timeframe** — scan on Daily for daily swings, on 1h for intraday.

### Screener columns

- **In Zone 1 / 2 / 3** — yes/no (1/0) per zone
- **Direction** — `1` long, `-1` short, `0` none
- **Extreme / Origin** — the swing's recent extreme and its starting point, in price
- **Zone 1/2/3 from $ · to $** — the actual price boundaries of each zone, so you can place orders straight from the scan

### Inputs

- **Lookback** — bars used to define the swing (default 100)
- **Zone 1/2/3 From / To** — retrace boundaries of each zone
- **Draw Zones On Chart** and **Extend Right (bars)** — display controls

### Notes

- Swing detection uses the two extreme points of the lookback window, so it reads the dominant range rather than every minor wiggle — deliberately simple, so it behaves identically across hundreds of symbols.
- No repainting from higher-timeframe requests — everything is computed on the chart's own bars.

Open source. Feedback and suggestions welcome.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Fib Zone Screener  (lightweight — built for the Pine Screener)
//
// Three lookback VIEWS, three fib zones each, drawn on one chart. A longer
// lookback captures a bigger swing, so the three views act like short / mid /
// long horizons (≈ intraday / daily / weekly) WITHOUT request.security.
//
//   For each view: find the window's highest high and lowest low, decide swing
//   direction from which extreme is MORE RECENT, then measure retrace from that
//   extreme so the zones work for longs AND shorts:
//     up-swing   (high newer than low)  → pullback measured DOWN from the high
//     down-swing (low newer than high)  → bounce   measured UP   from the low
//   Retrace: 0 = at the extreme, 0.5 = halfway, 1.0 = fully retraced.
//
// SCREENER: still single-lookback. "Flags From View" picks which view feeds the
// columns (In Zone 1/2/3, Direction, price levels). Nothing else is a column —
// the zones draw as boxes, which add no columns.
// CHART: each view its own color; direction shown by ▲/▼ in the label.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Fib Zone Screener", shorttitle="FibZone", overlay=true, max_boxes_count=20)

// ═══ INPUTS ══════════════════════════════════════════════════════════════════
// Three views (enable + lookback). Bigger lookback ≈ higher timeframe.
v1on  = input.bool(true,  "View 1", inline="v1", group="Views", tooltip="Show/hide this view's boxes.")
v1lb  = input.int(100, "", minval=5, maxval=1000, inline="v1", group="Views", tooltip="Lookback in BARS. Approx span (stocks RTH / 24h market):\n1H ≈ 14d / 4d\n2H ≈ 25d / 8d\n4H ≈ 50d / 17d\n(≈ 7 / 4 / 2 bars per day at 1H / 2H / 4H in US regular hours)")
v1col = input.color(#2962FF, "", inline="v1", group="Views")
v2on  = input.bool(true,  "View 2", inline="v2", group="Views", tooltip="Show/hide this view's boxes.")
v2lb  = input.int(200, "", minval=5, maxval=1000, inline="v2", group="Views", tooltip="Lookback in BARS. Approx span (stocks RTH / 24h market):\n1H ≈ 29d / 8d\n2H ≈ 50d / 17d\n4H ≈ 100d / 33d")
v2col = input.color(#FF9800, "", inline="v2", group="Views")
v3on  = input.bool(false, "View 3", inline="v3", group="Views", tooltip="Show/hide this view's boxes.")
v3lb  = input.int(400, "", minval=5, maxval=1000, inline="v3", group="Views", tooltip="Lookback in BARS. Approx span (stocks RTH / 24h market):\n1H ≈ 57d / 17d\n2H ≈ 100d / 33d\n4H ≈ 200d / 67d")
v3col = input.color(#AB47BC, "", inline="v3", group="Views")
flagsView = input.string("View 1", "Flags From View", options=["View 1","View 2","View 3"], group="Views",
            tooltip="Which view drives the screener columns. The chart still draws all enabled views.")

showFib   = input.bool(true, "Draw Zones On Chart", group="Display")
showLabels= input.bool(true, "Show Labels", group="Display", tooltip="Ratio + lookback label inside each box.")
rightExt  = input.int(10, "Extend Right (bars)", minval=0, maxval=100, group="Display",
            tooltip="How far past the current bar the boxes reach, so the latest candle's wicks stay visible.")
showInfo  = input.bool(true, "Show Info Box (bars → time)", group="Display",
            tooltip="Live translation of each view's lookback into a time span, based on the LOADED timeframe's actual bars per day.")
infoPos   = input.string("Top Right", "Info Box Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Display")

z1From = input.float(0.5,   "Zone 1 from", minval=0, maxval=1, step=0.014, inline="z1", group="Zones")
z1To   = input.float(0.618, "to",          minval=0, maxval=1, step=0.014, inline="z1", group="Zones")
z2From = input.float(0.618, "Zone 2 from", minval=0, maxval=1, step=0.014, inline="z2", group="Zones")
z2To   = input.float(0.786, "to",          minval=0, maxval=1, step=0.014, inline="z2", group="Zones")
z3From = input.float(0.786, "Zone 3 from", minval=0, maxval=1, step=0.014, inline="z3", group="Zones")
z3To   = input.float(1.0,   "to",          minval=0, maxval=1, step=0.014, inline="z3", group="Zones")

// ═══ SWING PER VIEW (direction-aware) ════════════════════════════════════════
// Returns [hi, lo, rng, bull]. Called every bar so the ta.* state stays valid.
swingOf(_lb) =>
    _hi  = ta.highest(high, _lb)
    _lo  = ta.lowest(low, _lb)
    _ho  = ta.highestbars(high, _lb)   // ≤ 0; closer to 0 = more recent
    _lb2 = ta.lowestbars(low, _lb)
    _rng = _hi - _lo
    [_hi, _lo, _rng, _rng > 0 and _ho > _lb2]

[hi1, lo1, rng1, bull1] = swingOf(v1lb)
[hi2, lo2, rng2, bull2] = swingOf(v2lb)
[hi3, lo3, rng3, bull3] = swingOf(v3lb)

// Price of a retrace fraction: down from the high (long) or up from the low (short).
lvlv(_r, _hi, _lo, _rng, _bull) => _rng > 0 ? (_bull ? _hi - _rng * _r : _lo + _rng * _r) : na

// ═══ SCREENER VALUES — from the selected view ════════════════════════════════
pHi   = flagsView == "View 1" ? hi1   : flagsView == "View 3" ? hi3   : hi2
pLo   = flagsView == "View 1" ? lo1   : flagsView == "View 3" ? lo3   : lo2
pRng  = flagsView == "View 1" ? rng1  : flagsView == "View 3" ? rng3  : rng2
pBull = flagsView == "View 1" ? bull1 : flagsView == "View 3" ? bull3 : bull2
retr  = pRng > 0 ? (pBull ? (pHi - close) / pRng : (close - pLo) / pRng) : na

// ── Deepest retrace of THIS pullback (since the most-recent extreme) ──────────
// Measured only from the impulse extreme to now — so a deep dip BEFORE this swing
// began doesn't count. Powers the "Clean" flags: in a zone now AND never went
// deeper than that zone during the current pullback.
pLb       = flagsView == "View 1" ? v1lb : flagsView == "View 3" ? v3lb : v2lb
extOff    = pBull ? ta.highestbars(high, pLb) : ta.lowestbars(low, pLb)     // ≤ 0 offset to the extreme (na early on)
lenSince  = na(extOff) ? 1 : math.max(1, 1 - extOff)                        // bars from the extreme to now (≥ 1)
deepLevel = pBull ? ta.lowest(low, lenSince) : ta.highest(high, lenSince)
maxRetr   = pRng > 0 and not na(deepLevel) ? (pBull ? (pHi - deepLevel) / pRng : (deepLevel - pLo) / pRng) : na

inBand(_a, _b) => not na(retr) and retr >= _a and retr <= _b ? 1 : 0
plot(inBand(z1From, z1To), "In Zone 1", display=display.data_window)
plot(inBand(z2From, z2To), "In Zone 2", display=display.data_window)
plot(inBand(z3From, z3To), "In Zone 3", display=display.data_window)

// "Clean" = in the zone now AND the pullback never dipped past that zone's deep
// edge since the extreme (never reached zone 2 / zone 3). 1 = clean, 0 = not.
plot(inBand(z1From, z1To) == 1 and not na(maxRetr) and maxRetr <= z1To ? 1 : 0, "Clean Z1", display=display.data_window)
plot(inBand(z2From, z2To) == 1 and not na(maxRetr) and maxRetr <= z2To ? 1 : 0, "Clean Z2", display=display.data_window)
plot(na(maxRetr) ? na : maxRetr * 100, "Max Retr %", display=display.data_window)  // deepest of this pullback

// Direction: 1 = long (up-swing), −1 = short (down-swing), 0 = none.
plot(na(retr) ? 0 : pBull ? 1 : -1, "Direction", display=display.data_window)

// Price levels of the selected view (actual $ — add the columns you want).
plot(pBull ? pHi : pLo, "Extreme", display=display.data_window)   // recent swing extreme (retrace 0)
plot(pBull ? pLo : pHi, "Origin",  display=display.data_window)   // start of the swing (retrace 1.0)
plot(lvlv(z1From, pHi, pLo, pRng, pBull), "Zone 1 from $", display=display.data_window)
plot(lvlv(z1To,   pHi, pLo, pRng, pBull), "Zone 1 to $",   display=display.data_window)
plot(lvlv(z2From, pHi, pLo, pRng, pBull), "Zone 2 from $", display=display.data_window)
plot(lvlv(z2To,   pHi, pLo, pRng, pBull), "Zone 2 to $",   display=display.data_window)
plot(lvlv(z3From, pHi, pLo, pRng, pBull), "Zone 3 from $", display=display.data_window)
plot(lvlv(z3To,   pHi, pLo, pRng, pBull), "Zone 3 to $",   display=display.data_window)

// ═══ DRAW ALL ENABLED VIEWS AS BOXES ═════════════════════════════════════════
// Each view has its own color; direction is shown by an arrow in the label
// (▲ = long side, ▼ = short side). Thin outline so nothing competes with candles.
var box[] boxes = array.new_box(0)

makeBox(_from, _to, _lb, _hi, _lo, _rng, _bull, _col) =>
    _t    = lvlv(_from, _hi, _lo, _rng, _bull)
    _b    = lvlv(_to,   _hi, _lo, _rng, _bull)
    _left = math.max(0, bar_index - _lb)                     // never before the first bar
    _bx   = box.new(_left, math.max(_t, _b), bar_index + rightExt, math.min(_t, _b),
                    border_color=color.new(_col, 0), border_width=1, bgcolor=na)
    if showLabels
        box.set_text(_bx, str.tostring(_lb) + (_bull ? " ▲ " : " ▼ ") + str.tostring(_from, "0.###") + "–" + str.tostring(_to, "0.###"))
        box.set_text_color(_bx, color.new(_col, 0))
        box.set_text_halign(_bx, text.align_left)
        box.set_text_valign(_bx, text.align_center)
        box.set_text_size(_bx, size.small)
    _bx

drawView(_on, _lb, _hi, _lo, _rng, _bull, _col) =>
    if _on and _rng > 0
        array.push(boxes, makeBox(z1From, z1To, _lb, _hi, _lo, _rng, _bull, _col))
        array.push(boxes, makeBox(z2From, z2To, _lb, _hi, _lo, _rng, _bull, _col))
        array.push(boxes, makeBox(z3From, z3To, _lb, _hi, _lo, _rng, _bull, _col))

if showFib and barstate.islast
    // Rebuild from scratch each update so nothing goes stale or accumulates.
    for b in boxes
        box.delete(b)
    array.clear(boxes)
    drawView(v1on, v1lb, hi1, lo1, rng1, bull1, v1col)
    drawView(v2on, v2lb, hi2, lo2, rng2, bull2, v2col)
    drawView(v3on, v3lb, hi3, lo3, rng3, bull3, v3col)

// ═══ INFO BOX — translate each lookback (bars) into time on the loaded TF ═════
// Bars-per-day is measured empirically for intraday charts (average over the last
// ~20 days), so the span is exact for whatever instrument/session is loaded.
isNewDay = ta.change(time("D")) != 0
var int   _cntToday  = 0
var float[] _dayCounts = array.new_float(0)
if barstate.isfirst
    _cntToday := 1
else if isNewDay
    if _cntToday > 0
        array.push(_dayCounts, _cntToday)
        if array.size(_dayCounts) > 20
            array.shift(_dayCounts)
    _cntToday := 1
else
    _cntToday += 1
avgBpd = array.size(_dayCounts) > 0 ? array.avg(_dayCounts) : na

// Days represented by one bar: intraday = 1/bars-per-day; daily = 1; W/M ≈ 5/21 trading days.
perBarDays = timeframe.isintraday ? (na(avgBpd) ? na : 1.0 / avgBpd) : timeframe.isweekly ? 5.0 : timeframe.ismonthly ? 21.0 : 1.0
spanDays(_lb) => na(perBarDays) ? na : _lb * perBarDays
// Auto-scale the unit: days → weeks → months (trading-day based: 5/wk, 21/mo).
fmtSpan(_d) => na(_d) ? "…" : _d >= 42 ? str.tostring(_d / 21, "#.#") + " mo" : _d >= 10 ? str.tostring(_d / 5, "#.#") + " wk" : str.tostring(_d, "#.#") + " d"

posOf(_p) => _p == "Top Left" ? position.top_left : _p == "Bottom Right" ? position.bottom_right : _p == "Bottom Left" ? position.bottom_left : position.top_right

infoRow(_tbl, _r, _on, _lb, _col) =>
    table.cell(_tbl, 0, _r, str.tostring(_lb) + " bars", text_color=_on ? _col : color.new(_col, 55), text_size=size.small)
    table.cell(_tbl, 1, _r, fmtSpan(spanDays(_lb)) + (_on ? "" : " (off)"), text_color=_on ? _col : color.new(_col, 55), text_size=size.small)

var table info = table.new(posOf(infoPos), 2, 4, bgcolor=color.new(color.black, 80), frame_color=color.new(color.gray, 50), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)
if showInfo and barstate.islast
    table.cell(info, 0, 0, timeframe.period, text_color=color.silver, text_size=size.small)
    table.cell(info, 1, 0, "≈ span", text_color=color.silver, text_size=size.small)
    infoRow(info, 1, v1on, v1lb, v1col)
    infoRow(info, 2, v2on, v2lb, v2col)
    infoRow(info, 3, v3on, v3lb, v3col)
````
