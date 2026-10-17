# Hurst Cycles 

- url: https://www.tradingview.com/script/GCpXfGtf-Hurst-Cycles/
- type: indicator
- pine_id: PUB;dbbcef3ba3674862a37ce6cffb6e6fa3
- version: 1.0

## Description

[b]What it is[/b]. An implementation of J.M. Hurst's nominal cyclic model. Hurst's premise: price movement is partly the sum of several nested cycles of roughly fixed wavelength (20-day, 40-day, 80-day, 20-week, 40-week, 18-month, 54-month...), harmonically related — each roughly half the length of the next — plus an underlying trend and noise. The indicator detects each cycle's troughs from price pivots, marks troughs and peaks with stacked diamonds (peaks defined properly, as the highest high between consecutive troughs), draws each cycle as a sine wave phased to its last trough, sums the enabled cycles into a composite model line that rides the candles, projects expected future trough dates as vertical lines with a tolerance window, and offers FLDs (price displaced forward half a wavelength — crossings generate Hurst's classic targets). Wavelengths are defined in calendar days on the daily timeframe and auto-rescale so the same cycle structure appears on any chart timeframe.


[b]How to use it properly.[/b] The workflow that matches how Hurst actually worked: start on the daily chart with everything at defaults and check whether the diamonds are landing near obvious lows — if the instrument's real cycles run consistently longer or shorter than nominal, adjust the wavelength inputs until troughs line up (Hurst expected the nominal values to be starting points, not universal constants). Then trade the synchrony: the meaningful moments are when several cycles trough together — the composite dipping while multiple vertical windows cluster in the same zone is the signal Hurst's whole method builds toward, and one cycle's window alone is weak evidence. Use the manual anchors as your judgment layer: pivot confirmation takes half a wavelength, so when you believe a major low just printed, enter its date and price and the model re-phases immediately — that's how you keep the projection current instead of half a cycle stale. And treat the tolerance windows as zones to watch for a turn with confirmation from price, never as dates to blindly buy.

[b]Downfalls[/b] — read these before trusting it with money. The structural ones first: cycle troughs confirm half a wavelength after they occur, so every automatic phasing is backward-looking by design — the 18-month cycle's trough isn't machine-confirmed until ~9 months later (manual anchors are the workaround, but then the phasing is your opinion). Second, the tolerance window is a heuristic, not Hurst's statistics — real Hurst analysis derives timing variance from the instrument itself, and this ±% is a stand-in you should tune. Third, the model is phase-only: amplitude weighting is a wavelength-based approximation, and the composite says nothing about how far price moves, only roughly when it might turn. Fourth, pivot detection is mechanical — it will happily phase a cycle off a news-spike low that a human analyst would skip, and in strong trends the shorter cycles' troughs get dragged late (Hurst's own observation). Practical ones: future projections extrapolate calendar time from recent bar spacing, so on stock charts distant dates drift slightly since future weekends aren't skipped; the biggest cycles can't pivot-confirm on intraday charts (Pine's 5000-bar lookback limit) and rely on manual anchors there; history only draws as far back as bars loaded on your chart; and each new confirmed trough re-phases everything, so projections legitimately move over time — that's the method working, not the indicator glitching.

[b]The honest framing[/b]. Cycle analysis is a minority view of how markets work — the academic mainstream is skeptical that fixed-period cycles persist, and even practitioners regard Hurst's model as a probabilistic timing framework, not a prediction machine. Its best use is narrowing when to pay attention and stacking confluence with your other analysis; its worst use is treating a vertical line nine months out as an appointment price is obligated to keep. Nothing it draws is financial advice, and the further into the future a projection extends, the more decorative it becomes.

## Source Code

````pine
//@version=6
indicator("Hurst Cycles — Nominal Model", shorttitle="Hurst Cycles", overlay=true, max_labels_count=500, max_lines_count=500, max_polylines_count=100)

// ═══════════════════════════════════════════════════════════════════════
//  Hurst's nominal model, Sentient-Trader-style display:
//   • Diamonds at cycle TROUGHS (below price) and PEAKS (above price),
//     stacked in rows by cycle degree — each independently toggleable.
//     Peaks are the true crest between consecutive troughs (Hurst's
//     definition), so every completed cycle gets its peak marked.
//   • Per-cycle SINE WAVES phased to each cycle's last confirmed trough
//     (or the lowest low of loaded history if unconfirmed — so the big
//     18m/54m waves always draw). Larger cycles draw taller and thicker.
//   • COMPOSITE MODEL LINE that RIDES THE PRICE CANDLES: drawn around a
//     moving baseline of price (SMA of hl2) with its oscillation scaled
//     in ATR multiples — it sits on the candles rather than down with the
//     sine waves. Its future humps/dips are the forecast peaks/valleys.
//   • MANUAL PHASING ANCHORS: six slots to type in the date and price of
//     an UNCONFIRMED trough or peak. The chosen cycle is re-phased to
//     that point — sine, next-trough verticals, and the composite all
//     shift accordingly.
//   • TIMEFRAME LOCK: wavelengths are defined on a locked timeframe
//     (default 1D — Hurst's calendar-day basis). On any other chart
//     timeframe the cycles auto-rescale to span the same real time, so
//     the daily cycle structure follows you everywhere.
//   • FLDs (median price displaced forward by half a wavelength + 1 bar)
//   • Optional vertical lines: dashed = expected dates of the next N
//     troughs per cycle (configurable), dotted = ± tolerance window
//     around the first
//  Future drawing uses calendar-time extrapolation, so it can extend far
//  beyond TradingView's usual 500-bar limit. On markets with session gaps
//  (stocks), future dates are approximate since weekends aren't skipped.
// ═══════════════════════════════════════════════════════════════════════

// ── General ────────────────────────────────────────────────────────────
grpG     = "General"
mode     = input.string("7-day week (crypto/forex)", "Bar counting", options=["7-day week (crypto/forex)", "5-day week (stocks)"], group=grpG,
     tooltip="Hurst's nominal wavelengths are in calendar days. A daily stock chart only prints ~5 bars per 7 days, so lengths are scaled by 5/7 in stock mode. Crypto/forex daily charts print every day — no scaling.")
lockTF   = input.timeframe("D", "Lock cycles to timeframe", group=grpG,
     tooltip="Wavelengths are defined in units of this timeframe (default 1D = calendar days, Hurst's basis). On any other chart timeframe the cycles auto-rescale to span the same real time — e.g. the 20-day cycle is 17 bars on a daily chart and ~102 bars on a 4H chart, so troughs, peaks, and projections land on the same dates everywhere.")
showTrD  = input.bool(true, "Trough diamonds (below price)", group=grpG)
showPkD  = input.bool(true, "Peak diamonds (above price)", group=grpG)
spaceIn  = input.float(0.6, "Diamond row spacing (ATR multiples)", minval=0.1, step=0.1, group=grpG)
maxFut   = input.int(500, "Max future extension (bars)", minval=100, maxval=5000, group=grpG, tooltip="How far the sine waves and the composite model may extend past the last bar. Vertical trough lines are placed by calendar time and are not limited by this.")
showProj = input.bool(true, "Show next-trough vertical lines", group=grpG, tooltip="Dashed vertical lines = expected dates of each cycle's upcoming troughs (last trough + N wavelengths). Dotted lines = the ± tolerance window around the first one.")
projN    = input.int(1, "Future troughs to project per cycle", minval=1, maxval=12, group=grpG,
     tooltip="How many upcoming troughs to mark with vertical lines for each cycle. 1 = just the next trough; higher values forecast further into the future. Vertical lines are placed by calendar time, so they are not limited by the max future extension setting.")
tolPct   = input.float(15, "Trough window tolerance (% of wavelength)", minval=0, group=grpG)

// ── Composite model (drawn ON price) ───────────────────────────────────
grpM     = "Composite model (rides the candles)"
showComp = input.bool(true, "Show composite model line", group=grpM)
baseLen  = input.int(50, "Price baseline SMA length", minval=1, group=grpM,
     tooltip="The composite oscillates around this moving average of hl2. Smaller = hugs the candles tighter; larger = smoother centerline.")
compPast = input.int(1000, "Bars of history to draw", minval=50, maxval=7500, group=grpM)
compAmp  = input.float(3.0, "Amplitude (ATR multiples)", minval=0.25, step=0.25, group=grpM,
     tooltip="Peak-to-centerline swing of the composite, in ATR(50) multiples. Raise it if the line looks too flat against the candles.")
compCol  = input.color(color.aqua, "Color", group=grpM)
ampExp   = input.float(0.5, "Amplitude vs wavelength exponent", minval=0, maxval=1, step=0.1, group=grpM,
     tooltip="Hurst observed that longer cycles have larger amplitude. Each cycle is weighted by wavelength^exponent. 0 = all cycles equal, 1 = proportional to wavelength. Also used for the per-cycle sine wave heights.")

// ── Sine wave display ──────────────────────────────────────────────────
grpS     = "Per-cycle sine waves"
sinPast  = input.int(1000, "Bars of history to draw", minval=50, maxval=7500, group=grpS)
sinAmpIn = input.float(3.0, "Base amplitude (ATR multiples, 20-week cycle)", minval=0.25, step=0.25, group=grpS,
     tooltip="Height of the 20-week sine. Other cycles scale by wavelength^exponent (see Composite group), so the 54-month wave draws much taller.")
sinDepth = input.float(4.0, "Baseline depth below lows (ATR multiples)", minval=0.5, step=0.5, group=grpS)

// ── Manual phasing anchors ─────────────────────────────────────────────
grpX = "Manual anchors — unconfirmed trough/peak (re-phases the cycle)"
m1on    = input.bool(false, "Anchor 1", inline="m1", group=grpX)
m1cyc   = input.string("40-week", "", options=["5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month"], inline="m1", group=grpX)
m1kind  = input.string("Trough", "", options=["Trough","Peak"], inline="m1", group=grpX)
m1time  = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor 1 date", group=grpX,
     tooltip="Date of the unconfirmed pivot. Can be in the past (a low/high that printed but hasn't confirmed yet) or slightly in the future.")
m1price = input.price(0.0, "Anchor 1 price", group=grpX,
     tooltip="Price of the unconfirmed pivot — used to place the ✕ marker on the chart.")
m2on    = input.bool(false, "Anchor 2", inline="m2", group=grpX)
m2cyc   = input.string("18-month", "", options=["5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month"], inline="m2", group=grpX)
m2kind  = input.string("Trough", "", options=["Trough","Peak"], inline="m2", group=grpX)
m2time  = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor 2 date", group=grpX)
m2price = input.price(0.0, "Anchor 2 price", group=grpX)
m3on    = input.bool(false, "Anchor 3", inline="m3", group=grpX)
m3cyc   = input.string("20-week", "", options=["5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month"], inline="m3", group=grpX)
m3kind  = input.string("Trough", "", options=["Trough","Peak"], inline="m3", group=grpX)
m3time  = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor 3 date", group=grpX)
m3price = input.price(0.0, "Anchor 3 price", group=grpX)
m4on    = input.bool(false, "Anchor 4", inline="m4", group=grpX)
m4cyc   = input.string("80-day", "", options=["5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month"], inline="m4", group=grpX)
m4kind  = input.string("Trough", "", options=["Trough","Peak"], inline="m4", group=grpX)
m4time  = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor 4 date", group=grpX)
m4price = input.price(0.0, "Anchor 4 price", group=grpX)
m5on    = input.bool(false, "Anchor 5", inline="m5", group=grpX)
m5cyc   = input.string("40-day", "", options=["5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month"], inline="m5", group=grpX)
m5kind  = input.string("Trough", "", options=["Trough","Peak"], inline="m5", group=grpX)
m5time  = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor 5 date", group=grpX)
m5price = input.price(0.0, "Anchor 5 price", group=grpX)
m6on    = input.bool(false, "Anchor 6", inline="m6", group=grpX)
m6cyc   = input.string("54-month", "", options=["5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month"], inline="m6", group=grpX)
m6kind  = input.string("Trough", "", options=["Trough","Peak"], inline="m6", group=grpX)
m6time  = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor 6 date", group=grpX)
m6price = input.price(0.0, "Anchor 6 price", group=grpX)

// ── Cycles: enable | wavelength (calendar days) | FLD | Sin ────────────
grpC = "Cycles — Hurst nominal wavelengths (calendar days)"
c1on  = input.bool(false, "5-day",    inline="c1", group=grpC)
c1len = input.float(4.3,  "len",      inline="c1", group=grpC, minval=2)
f1    = input.bool(false, "FLD",      inline="c1", group=grpC)
s1    = input.bool(false, "Sin",      inline="c1", group=grpC)
c2on  = input.bool(false, "10-day",   inline="c2", group=grpC)
c2len = input.float(8.5,  "len",      inline="c2", group=grpC, minval=2)
f2    = input.bool(false, "FLD",      inline="c2", group=grpC)
s2    = input.bool(false, "Sin",      inline="c2", group=grpC)
c3on  = input.bool(true,  "20-day",   inline="c3", group=grpC)
c3len = input.float(17.0, "len",      inline="c3", group=grpC, minval=2)
f3    = input.bool(false, "FLD",      inline="c3", group=grpC)
s3    = input.bool(false, "Sin",      inline="c3", group=grpC)
c4on  = input.bool(true,  "40-day",   inline="c4", group=grpC)
c4len = input.float(34.1, "len",      inline="c4", group=grpC, minval=2)
f4    = input.bool(false, "FLD",      inline="c4", group=grpC)
s4    = input.bool(false, "Sin",      inline="c4", group=grpC)
c5on  = input.bool(true,  "80-day",   inline="c5", group=grpC)
c5len = input.float(68.2, "len",      inline="c5", group=grpC, minval=2)
f5    = input.bool(false, "FLD",      inline="c5", group=grpC)
s5    = input.bool(false, "Sin",      inline="c5", group=grpC)
c6on  = input.bool(true,  "20-week",  inline="c6", group=grpC)
c6len = input.float(136.4, "len",     inline="c6", group=grpC, minval=2)
f6    = input.bool(false, "FLD",      inline="c6", group=grpC)
s6    = input.bool(true,  "Sin",      inline="c6", group=grpC)
c7on  = input.bool(true,  "40-week",  inline="c7", group=grpC)
c7len = input.float(272.8, "len",     inline="c7", group=grpC, minval=2)
f7    = input.bool(false, "FLD",      inline="c7", group=grpC)
s7    = input.bool(true,  "Sin",      inline="c7", group=grpC)
c8on  = input.bool(true,  "18-month", inline="c8", group=grpC)
c8len = input.float(545.6, "len",     inline="c8", group=grpC, minval=2)
f8    = input.bool(false, "FLD",      inline="c8", group=grpC)
s8    = input.bool(true,  "Sin",      inline="c8", group=grpC)
c9on  = input.bool(false, "54-month", inline="c9", group=grpC)
c9len = input.float(1636.8, "len",    inline="c9", group=grpC, minval=2)
f9    = input.bool(false, "FLD",      inline="c9", group=grpC)
s9    = input.bool(true,  "Sin",      inline="c9", group=grpC)

// ── Colors ─────────────────────────────────────────────────────────────
grpK = "Cycle colors"
col1 = input.color(color.gray,    "5-day",    inline="k1", group=grpK)
col2 = input.color(color.silver,  "10-day",   inline="k1", group=grpK)
col3 = input.color(color.teal,    "20-day",   inline="k2", group=grpK)
col4 = input.color(color.green,   "40-day",   inline="k2", group=grpK)
col5 = input.color(color.yellow,  "80-day",   inline="k3", group=grpK)
col6 = input.color(color.orange,  "20-week",  inline="k3", group=grpK)
col7 = input.color(color.red,     "40-week",  inline="k4", group=grpK)
col8 = input.color(color.purple,  "18-month", inline="k4", group=grpK)
col9 = input.color(color.fuchsia, "54-month", inline="k5", group=grpK)

// ── Core helpers ───────────────────────────────────────────────────────
lockMs  = timeframe.in_seconds(lockTF) * 1000.0
chartMs = timeframe.in_seconds(timeframe.period) * 1000.0
f_eff(dLen) =>
    scale = mode == "5-day week (stocks)" ? 5.0 / 7.0 : 1.0
    math.max(2, math.min(9800, math.round(dLen * scale * lockMs / chartMs)))

atrV     = ta.atr(50)
rowSpace = spaceIn * atrV

// Sine baseline: lowest low of the entire drawn window (so long histories
// never overlap old price), minus the configured ATR depth
var array<float> lowArr  = array.new_float()
var array<float> highArr = array.new_float()
array.push(lowArr, low)
array.push(highArr, high)
float sineBase = na
if barstate.islast
    sStart = math.max(0, bar_index - sinPast)
    sineBase := array.min(array.slice(lowArr, sStart, bar_index + 1)) - sinDepth * atrV

// Per-bar history stores (enable time↔bar mapping without max_bars_back headaches)
var array<int>   tArr    = array.new_int()
var array<float> baseArr = array.new_float()
baseRaw = ta.sma(hl2, baseLen)
array.push(tArr, time)
array.push(baseArr, na(baseRaw) ? hl2 : baseRaw)

// Track global lowest low (fallback phase anchor for unconfirmed big cycles)
var float gLo    = na
var int   gLoBar = na
if na(gLo) or low < gLo
    gLo    := low
    gLoBar := bar_index

// Average ms per bar over the last ~200 bars (for future-time extrapolation)
mspb = bar_index >= 1 ? math.round((time - array.get(tArr, math.max(0, bar_index - 200))) / math.max(1, math.min(200, bar_index))) : 86400000

f_time(x) =>
    x <= bar_index ? array.get(tArr, math.max(0, x)) : time + (x - bar_index) * mspb

f_barFromTime(t) =>
    t <= time ? math.min(bar_index, math.max(0, array.binary_search_leftmost(tArr, t))) : bar_index + math.round((t - time) / mspb)

f_size(row) =>
    row <= 2 ? size.tiny : row <= 4 ? size.small : row <= 6 ? size.normal : size.large

refLenB = f_eff(136.4)   // 20-week reference for amplitude scaling

// ── Per-cycle engine ───────────────────────────────────────────────────
f_do(en, lenD, col, sinOn, row, nm, mOn, mTime, mPrice, mPeak) =>
    lenB = f_eff(lenD)
    h    = math.max(2, math.round(lenB / 2.0))
    // Pine limits history references to 5000 bars, and pivot detection
    // reaches back a full wavelength (h bars each side). Cycles whose
    // half-wavelength exceeds 2400 bars therefore can't be pivot-confirmed
    // on this timeframe — they return na here and instead rely on manual
    // anchors or the lowest-low fallback for phasing.
    hp    = math.min(h, 2400)
    plRaw = ta.pivotlow(low, hp, hp)
    pl    = h <= 2400 ? plRaw : na

    var int   lastT    = na
    var float lastTLow = na

    troughConf = en and not na(pl)

    // Troughs: diamond below price + true crest between troughs
    if troughConf
        newTBar = bar_index - h
        newTLow = pl
        if showTrD
            label.new(newTBar, newTLow - rowSpace * (row + 1), "", xloc=xloc.bar_index, yloc=yloc.price,
                 style=label.style_diamond, color=col, size=f_size(row), tooltip=nm + " trough")
        // Hurst's definition: the cycle peak is the highest high between
        // two consecutive troughs of the same degree. Scanning for it
        // directly guarantees a peak diamond for every completed cycle.
        int   crestBar = na
        float crestHi  = na
        if not na(lastT)
            crestBar := lastT
            crestHi  := array.get(highArr, lastT)
            for i = lastT to newTBar
                hv = array.get(highArr, i)
                if hv > crestHi
                    crestHi  := hv
                    crestBar := i
            if showPkD
                label.new(crestBar, crestHi + rowSpace * (row + 1), "", xloc=xloc.bar_index, yloc=yloc.price,
                     style=label.style_diamond, color=col, size=f_size(row), tooltip=nm + " peak")
        lastT    := newTBar
        lastTLow := newTLow

    // ---- last-bar dynamic drawings (projection, verticals, sine, manual marker) ----
    var polyline sinPl   = na
    var array<line> vlines = array.new<line>()
    var label    manLb   = na
    int anchorRet = na

    if barstate.islast
        if not na(sinPl)
            polyline.delete(sinPl)
        for ln in vlines
            line.delete(ln)
        array.clear(vlines)
        if not na(manLb)
            label.delete(manLb)
        if en
            // Manual anchor override (unconfirmed pivot the user typed in)
            int manBar = na
            if mOn
                manBar := f_barFromTime(mTime)
                manLb  := label.new(f_time(manBar), mPrice, "", xloc=xloc.bar_time, yloc=yloc.price,
                     style=label.style_xcross, color=col, size=size.small,
                     tooltip=nm + (mPeak ? " — manual PEAK anchor (unconfirmed)" : " — manual TROUGH anchor (unconfirmed)"))
            // A peak anchor implies the trough sits half a wavelength earlier
            int realAnchor = mOn ? (mPeak ? manBar - h : manBar) : lastT
            anchorRet := not na(realAnchor) ? realAnchor : gLoBar


            // Vertical next-trough timing lines (projN occurrences ahead)
            if showProj and not na(realAnchor)
                tol = math.round(lenB * tolPct / 100.0)
                for k = 1 to projN
                    target = realAnchor + lenB * k
                    array.push(vlines, line.new(f_time(target), low, f_time(target), high, xloc=xloc.bar_time, extend=extend.both,
                         color=color.new(col, 20), style=line.style_dashed))
                    if k == 1
                        array.push(vlines, line.new(f_time(target - tol), low, f_time(target - tol), high, xloc=xloc.bar_time, extend=extend.both,
                             color=color.new(col, 65), style=line.style_dotted))
                        array.push(vlines, line.new(f_time(target + tol), low, f_time(target + tol), high, xloc=xloc.bar_time, extend=extend.both,
                             color=color.new(col, 65), style=line.style_dotted))

            // Per-cycle sine wave (falls back to the lowest low if no anchor)
            if sinOn
                aB     = not na(realAnchor) ? realAnchor : gLoBar
                w      = math.pow(lenB * 1.0 / refLenB, ampExp)
                ampS   = sinAmpIn * atrV * w
                startX     = math.max(0, bar_index - sinPast)
                endX       = bar_index + maxFut
                stepCap    = math.max(1, math.ceil((endX - startX) / 9000.0))
                stepSmooth = math.max(1, math.floor(lenB / 16.0))
                stepI      = math.max(stepCap, stepSmooth)
                pts    = array.new<chart.point>()
                x = startX
                while x <= endX
                    y = sineBase + ampS * (1.0 - math.cos(2.0 * math.pi * (x - aB) / lenB)) / 2.0
                    array.push(pts, chart.point.from_time(f_time(x), y))
                    x += stepI
                if array.size(pts) >= 2
                    sinPl := polyline.new(pts, curved=true, xloc=xloc.bar_time,
                         line_color=color.new(col, row >= 5 ? 0 : 20), line_width=row >= 7 ? 4 : row >= 5 ? 3 : 2)
    [troughConf, anchorRet, lenB]

// ── Manual anchor → cycle routing ──────────────────────────────────────
var array<string> cycNames = array.from("5-day","10-day","20-day","40-day","80-day","20-week","40-week","18-month","54-month")
m1idx = array.indexof(cycNames, m1cyc)
m2idx = array.indexof(cycNames, m2cyc)
m3idx = array.indexof(cycNames, m3cyc)
m4idx = array.indexof(cycNames, m4cyc)
m5idx = array.indexof(cycNames, m5cyc)
m6idx = array.indexof(cycNames, m6cyc)
f_mOn(i) => (m1on and m1idx == i) or (m2on and m2idx == i) or (m3on and m3idx == i) or (m4on and m4idx == i) or (m5on and m5idx == i) or (m6on and m6idx == i)
f_mT(i)  => m1on and m1idx == i ? m1time  : m2on and m2idx == i ? m2time  : m3on and m3idx == i ? m3time  : m4on and m4idx == i ? m4time  : m5on and m5idx == i ? m5time  : m6time
f_mP(i)  => m1on and m1idx == i ? m1price : m2on and m2idx == i ? m2price : m3on and m3idx == i ? m3price : m4on and m4idx == i ? m4price : m5on and m5idx == i ? m5price : m6price
f_mK(i)  => (m1on and m1idx == i ? m1kind : m2on and m2idx == i ? m2kind : m3on and m3idx == i ? m3kind : m4on and m4idx == i ? m4kind : m5on and m5idx == i ? m5kind : m6kind) == "Peak"

// ── Run all nine cycles ────────────────────────────────────────────────
[t1, aT1, l1] = f_do(c1on, c1len, col1, s1, 0, "5-day",    f_mOn(0), f_mT(0), f_mP(0), f_mK(0))
[t2, aT2, l2] = f_do(c2on, c2len, col2, s2, 1, "10-day",   f_mOn(1), f_mT(1), f_mP(1), f_mK(1))
[t3, aT3, l3] = f_do(c3on, c3len, col3, s3, 2, "20-day",   f_mOn(2), f_mT(2), f_mP(2), f_mK(2))
[t4, aT4, l4] = f_do(c4on, c4len, col4, s4, 3, "40-day",   f_mOn(3), f_mT(3), f_mP(3), f_mK(3))
[t5, aT5, l5] = f_do(c5on, c5len, col5, s5, 4, "80-day",   f_mOn(4), f_mT(4), f_mP(4), f_mK(4))
[t6, aT6, l6] = f_do(c6on, c6len, col6, s6, 5, "20-week",  f_mOn(5), f_mT(5), f_mP(5), f_mK(5))
[t7, aT7, l7] = f_do(c7on, c7len, col7, s7, 6, "40-week",  f_mOn(6), f_mT(6), f_mP(6), f_mK(6))
[t8, aT8, l8] = f_do(c8on, c8len, col8, s8, 7, "18-month", f_mOn(7), f_mT(7), f_mP(7), f_mK(7))
[t9, aT9, l9] = f_do(c9on, c9len, col9, s9, 8, "54-month", f_mOn(8), f_mT(8), f_mP(8), f_mK(8))

// ── Composite model line — drawn AROUND PRICE ──────────────────────────
var polyline compPl = na
if barstate.islast
    if not na(compPl)
        polyline.delete(compPl)
    if showComp
        anch = array.new_int()
        lens = array.new_int()
        ons  = array.new_bool()
        array.push(anch, aT1)
        array.push(anch, aT2)
        array.push(anch, aT3)
        array.push(anch, aT4)
        array.push(anch, aT5)
        array.push(anch, aT6)
        array.push(anch, aT7)
        array.push(anch, aT8)
        array.push(anch, aT9)
        array.push(lens, l1)
        array.push(lens, l2)
        array.push(lens, l3)
        array.push(lens, l4)
        array.push(lens, l5)
        array.push(lens, l6)
        array.push(lens, l7)
        array.push(lens, l8)
        array.push(lens, l9)
        array.push(ons, c1on)
        array.push(ons, c2on)
        array.push(ons, c3on)
        array.push(ons, c4on)
        array.push(ons, c5on)
        array.push(ons, c6on)
        array.push(ons, c7on)
        array.push(ons, c8on)
        array.push(ons, c9on)
        sumW = 0.0
        for i = 0 to 8
            if array.get(ons, i) and not na(array.get(anch, i))
                sumW += math.pow(array.get(lens, i) * 1.0 / refLenB, ampExp)
        if sumW > 0
            startX   = math.max(0, bar_index - compPast)
            endX     = bar_index + maxFut
            int minLen = 999999
            for i = 0 to 8
                if array.get(ons, i) and not na(array.get(anch, i))
                    minLen := math.min(minLen, array.get(lens, i))
            stepCap    = math.max(1, math.ceil((endX - startX) / 9000.0))
            stepSmooth = math.max(1, math.floor(minLen / 16.0))
            stepI      = math.max(stepCap, stepSmooth)
            lastBase = array.get(baseArr, bar_index)
            pts      = array.new<chart.point>()
            x = startX
            while x <= endX
                v = 0.0
                for i = 0 to 8
                    if array.get(ons, i) and not na(array.get(anch, i))
                        wI = math.pow(array.get(lens, i) * 1.0 / refLenB, ampExp)
                        v += wI * -math.cos(2.0 * math.pi * (x - array.get(anch, i)) / array.get(lens, i))
                v /= sumW
                b = x <= bar_index ? array.get(baseArr, x) : lastBase
                array.push(pts, chart.point.from_time(f_time(x), b + compAmp * atrV * v))
                x += stepI
            if array.size(pts) >= 2
                compPl := polyline.new(pts, curved=true, xloc=xloc.bar_time, line_color=compCol, line_width=2)

// ── FLDs (median price displaced forward by half a wavelength + 1) ─────
plot(c1on and f1 ? hl2 : na, "5-day FLD",    color=col1, offset=math.round(f_eff(c1len) / 2) + 1)
plot(c2on and f2 ? hl2 : na, "10-day FLD",   color=col2, offset=math.round(f_eff(c2len) / 2) + 1)
plot(c3on and f3 ? hl2 : na, "20-day FLD",   color=col3, offset=math.round(f_eff(c3len) / 2) + 1)
plot(c4on and f4 ? hl2 : na, "40-day FLD",   color=col4, offset=math.round(f_eff(c4len) / 2) + 1)
plot(c5on and f5 ? hl2 : na, "80-day FLD",   color=col5, offset=math.round(f_eff(c5len) / 2) + 1)
plot(c6on and f6 ? hl2 : na, "20-week FLD",  color=col6, offset=math.round(f_eff(c6len) / 2) + 1)
plot(c7on and f7 ? hl2 : na, "40-week FLD",  color=col7, offset=math.round(f_eff(c7len) / 2) + 1)
plot(c8on and f8 ? hl2 : na, "18-month FLD", color=col8, offset=math.round(f_eff(c8len) / 2) + 1)
plot(c9on and f9 ? hl2 : na, "54-month FLD", color=col9, offset=math.round(f_eff(c9len) / 2) + 1)

// ── Alerts (troughs confirm half a wavelength after they occur) ────────
alertcondition(t1, "5-Day Cycle Trough Confirmed",    "Hurst 5-day cycle trough confirmed")
alertcondition(t2, "10-Day Cycle Trough Confirmed",   "Hurst 10-day cycle trough confirmed")
alertcondition(t3, "20-Day Cycle Trough Confirmed",   "Hurst 20-day cycle trough confirmed")
alertcondition(t4, "40-Day Cycle Trough Confirmed",   "Hurst 40-day cycle trough confirmed")
alertcondition(t5, "80-Day Cycle Trough Confirmed",   "Hurst 80-day cycle trough confirmed")
alertcondition(t6, "20-Week Cycle Trough Confirmed",  "Hurst 20-week cycle trough confirmed")
alertcondition(t7, "40-Week Cycle Trough Confirmed",  "Hurst 40-week cycle trough confirmed")
alertcondition(t8, "18-Month Cycle Trough Confirmed", "Hurst 18-month cycle trough confirmed")
alertcondition(t9, "54-Month Cycle Trough Confirmed", "Hurst 54-month cycle trough confirmed")
````
