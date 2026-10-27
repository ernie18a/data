# Balanced Price Range + V-Shape Indicator

- url: https://www.tradingview.com/script/bgG6yZfg-Balanced-Price-Range-V-Shape-Indicator/
- type: indicator
- pine_id: PUB;da7616232f994d268cf5e171f85f86ac
- version: 1.0

## Description

[b]Balanced Price Range + V-Shape Indicator[/b]

[b]Overview[/b]
This is an open-source intraday scalping model built on ICT-derived price-action concepts. It combines Balanced Price Ranges and V-shaped liquidity-driven reversals into a single contextual system. The scalping method is specific: it looks for a sharp reversal (a "V") off a zone of overlapping imbalance (a Balanced Price Range), but only when that zone is confirmed by higher-timeframe imbalance or a recent liquidity sweep — the kind of fast, location-specific entry used on 1–15 minute charts. Rather than printing every BPR or inverted gap (which is unusably noisy live), it cross-filters them so only confirmed locations are highlighted. The source is fully open; everything below describes exactly what the code does.

[b]Building block 1 — Fair Value Gaps and inversions[/b]
A Fair Value Gap (FVG) is a three-candle imbalance: a gap between candle 1's extreme and candle 3's extreme left unfilled by candle 2. The script detects each FVG as it forms and stores the displacement (middle) candle's open and close for later momentum checks. When price later closes back through a gap, that gap is latched as inverted (an iFVG) — its expected support/resistance role flips.

[b]Building block 2 — Balanced Price Range[/b]
A Balanced Price Range is the price overlap between a fresh FVG and an opposite-direction iFVG. When a new FVG forms and overlaps an opposite inverted gap within a configurable lookback window, the overlapping band is drawn as a BPR. A minimum-size filter (as a percentage of 14-period ATR) discards slivers too thin to matter. BPR zones extend rightward until price closes through them or a max-extension bar limit is reached.

[b]Building block 3 — Liquidity mapping and sweeps[/b]
The script independently maps liquidity from four sources, each toggleable: swing-pivot highs/lows, equal highs/lows (two same-side swings within an ATR tolerance), previous-day high/low, and London / NY-AM session highs and lows. For each level it distinguishes a sweep (wick through, close back — liquidity grab) from a clean break (close beyond — level reclaimed), marking sweeps on the chart.

[b]The V-Shape gate — how the pieces work together[/b]
A BPR is upgraded to a "V-BPR" and an entry arrow only fires when the location passes a context gate with two independent confirmation paths, either of which validates the setup:
[list]
[*]HTF FVG tap (continuation path): Fair Value Gaps are read from a higher timeframe (chart TF × a user multiplier, snapped to the nearest standard resolution). The gate checks whether price recently tapped a still-valid HTF gap of matching direction, and whether the BPR sits inside or within an ATR buffer of it.
[*]Liquidity sweep (reversal path): a correct-side sweep — a low taken for a long, a high taken for a short — within a recent bar window.
[/list]
Two candle-level filters refine the trigger: a clean-V-tip rule (the inversion candle must be preceded by an opposite-direction candle, enforcing a real reversal at the tip) and a strong-close rule (the inverting candle must reclaim a set percentage of the displacement candle's body, confirming momentum). An optional clear-path filter rejects a setup when un-swept opposite-side liquidity rests within an ATR danger zone in the trade's direction, since that pool is often taken first.

[b]Chart Examples: 
[/b]
[image][url=https://www.tradingview.com/x/JI5vou8e/]https://www.tradingview.com/x/JI5vou8e/[/url][/image][/image]
[image][url=https://www.tradingview.com/x/BhfsTNrJ/]https://www.tradingview.com/x/BhfsTNrJ/[/url][/image]
[image]https://www.tradingview.com/x/nyH7qUPe/[/image]
[image]https://www.tradingview.com/x/kULttUvz/[/image]

[b]Settings reference[/b]
Settings: max BPRs shown, iFVG lookback window, min BPR size (% ATR), max zone extension.
Higher-TF FVG: show/hide, timeframe multiplier, max stored, colour.
V-Shape Gate & Entry: master gate toggle, HTF-tap window, zone proximity buffer, sweep-path toggle and window, clean-V-tip, clear-path toggle and danger-zone size, hide-non-V-BPR, entry-marker toggle, strong-close percentage.
Liquidity & Sweeps: toggles for swing / PDH-PDL / session / equal-H-L sources, pivot strength, equal tolerance, session windows (NY time), max levels, sweep marking, colours.
Colors: bull/bear BPR, FVG/iFVG components, liquidity, sweep marks.

[b]How to use it[/b]
Apply to 1–15 minute charts. Drawn BPRs show overlapping imbalance; thicker V-BPR zones and ▲/▼ markers show locations that passed the gate. Each entry marker's tooltip audits why it fired (which path confirmed it and the reclaim %). Begin with the gate on to see only confirmed scalps; loosen by disabling individual filters, or enable "Hide BPRs that fail the gate" to declutter. Alerts fire on confirmed long and short V-Shape entries.

[b]Non-repainting[/b]
All higher-timeframe and previous-day data is requested with offset historical expressions, so no future data is used on historical bars; entries evaluate only on confirmed bar closes and do not repaint.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Fun_Trades

//@version=6
indicator("Balanced Price Range + V-Shape Indicator", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ─── Inputs ───────────────────────────────────────────────────
var GRP_SETTINGS = "Settings"
int   maxBprInput         = input.int(30, "Max BPRs on chart", minval = 1, maxval = 100, group = GRP_SETTINGS)
bool  showComponentsInput = input.bool(false, "Show FVG & iFVG zones", group = GRP_SETTINGS)
int   lookbackInput       = input.int(10, "iFVG lookback (bars)", minval = 1, maxval = 200, group = GRP_SETTINGS,
     tooltip = "Only match iFVGs that were invalidated within this many bars of the new FVG. Also caps how long after an FVG forms that its inversion can still fire a V-Shape entry.")
float minOverlapTickInput = input.float(0.5, "Min BPR size (% of ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = GRP_SETTINGS,
     tooltip = "Minimum overlap size as a percentage of the 14-period ATR. Filters out tiny sliver BPRs that aren't meaningful. Set to 0 to disable.")
int   maxExtInput         = input.int(20, "Max extension (bars)", minval = 1, maxval = 500, group = GRP_SETTINGS,
     tooltip = "BPR zones stop extending after this many bars, even if price hasn't closed through. Set higher if you want zones to linger longer.")

var GRP_HTF = "Higher-TF FVG"
bool  showHtfFvgInput  = input.bool(false, "Show HTF FVG", group = GRP_HTF)
int   htfMultInput     = input.int(5, "HTF timeframe = chart × …", minval = 2, maxval = 60, group = GRP_HTF,
     tooltip = "HTF FVG is read from a higher timeframe = chart TF × this number, snapped to the nearest standard TF. On 1m, ×5 ≈ 5m; on 30s, ×5 ≈ 3m. The resolved TF is printed on the box.")
int   maxHtfFvgInput   = input.int(10, "Max HTF FVGs", minval = 1, maxval = 50, group = GRP_HTF)
color htfFvgColorInput = input.color(color.new(color.gray, 70), "HTF FVG", group = GRP_HTF, active = showHtfFvgInput)

var GRP_VS = "V-Shape Gate & Entry"
bool  gateHtfInput     = input.bool(true, "Require V-Shape context (HTF tap or sweep)", group = GRP_VS,
     tooltip = "When on, a BPR is tagged V-BPR and an entry only fires with valid context: price recently tapped a still-valid HTF FVG of matching direction, OR (if enabled) a correct-side liquidity level was swept just before the inversion.")
int   htfTapWinInput   = input.int(15, "Max bars since HTF FVG tap", minval = 1, maxval = 100, group = GRP_VS, active = gateHtfInput,
     tooltip = "Price must have tapped the HTF FVG within this many bars before the signal.")
float htfProxInput     = input.float(25.0, "Zone proximity to HTF FVG (% of ATR)", minval = 0.0, maxval = 200.0, step = 5.0, group = GRP_VS, active = gateHtfInput,
     tooltip = "The BPR/iFVG must overlap the HTF FVG or sit within this buffer (% of 14-period ATR) of its edge. Larger = looser.")
bool  ctxSweepInput    = input.bool(true, "Allow liquidity-sweep context (reversal path)", group = GRP_VS, active = gateHtfInput,
     tooltip = "Also accept a setup when a correct-side liquidity level (a low for longs, a high for shorts) was swept just before the inversion — even with no HTF FVG tap. This is the reversal path.")
int   sweepWinInput    = input.int(12, "Max bars since sweep", minval = 1, maxval = 100, group = GRP_VS, active = ctxSweepInput,
     tooltip = "A correct-side liquidity sweep must have occurred within this many bars before the inversion candle.")
bool  cleanVTipInput   = input.bool(true, "Require clean V-tip", group = GRP_VS,
     tooltip = "The inversion candle must be preceded by a candle of the OPPOSITE direction (long: prior candle bearish; short: prior candle bullish). Enforces a sharp reversal at the tip. Turn off if it blocks single-candle V reversals.")
bool  clearPathInput   = input.bool(true, "Require clear liquidity path (no resting opposite pool nearby)", group = GRP_VS,
     tooltip = "Block a long if an un-swept LOW rests just below the entry (or a short if an un-swept HIGH rests just above). That resting pool is a downside/upside draw that often gets taken first. Uses your enabled liquidity types.")
float pathBufInput     = input.float(150.0, "Path danger zone (% of ATR)", minval = 10.0, maxval = 500.0, step = 10.0, group = GRP_VS, active = clearPathInput,
     tooltip = "How far below a long entry (or above a short) to scan for resting opposite-side liquidity, as % of the 14-period ATR. Larger = stricter / rejects more. 150% ≈ 1.5 ATR.")
bool  hideNonVsInput   = input.bool(false, "Hide BPRs that fail the gate", group = GRP_VS, active = gateHtfInput)
bool  vsEntryShowInput = input.bool(true, "Show V-Shape entry markers", group = GRP_VS)
float strongCloseInput = input.float(90.0, "Strong close: % of displacement body reclaimed", minval = 0.0, maxval = 150.0, step = 5.0, group = GRP_VS,
     tooltip = "The inverting candle must close at least this far back through the body (open→close) of the displacement candle that made the FVG. 100% = closes at/beyond that candle's open. 90% = 90% of the way back.")

var GRP_LIQ = "Liquidity & Sweeps"
bool   useSwingInput   = input.bool(true, "Swing highs/lows", group = GRP_LIQ)
int    pivotLenInput   = input.int(5, "Swing pivot strength", minval = 1, maxval = 50, group = GRP_LIQ,
     tooltip = "Bars required on each side to confirm a pivot. Higher = fewer, more significant swings. A pivot confirms this many bars after it forms.")
bool   usePdInput      = input.bool(true, "PDH / PDL", group = GRP_LIQ)
bool   useSessionInput = input.bool(true, "Session highs/lows", group = GRP_LIQ)
string londonSesInput  = input.session("0200-0500", "London session (NY time)", group = GRP_LIQ, active = useSessionInput)
string nyamSesInput    = input.session("0930-1100", "NY AM session (NY time)", group = GRP_LIQ, active = useSessionInput)
bool   useEqInput      = input.bool(true, "Equal highs/lows", group = GRP_LIQ)
float  eqTolInput      = input.float(10.0, "Equal H/L tolerance (% of ATR)", minval = 1.0, maxval = 100.0, step = 1.0, group = GRP_LIQ,
     tooltip = "Two consecutive same-side swings count as equal if their prices are within this % of the 14-period ATR.", active = useEqInput)
int    maxLiqInput     = input.int(25, "Max liquidity levels", minval = 1, maxval = 100, group = GRP_LIQ)
bool   markSweepsInput = input.bool(false, "Mark sweeps", group = GRP_LIQ)
color  liqHighColInput = input.color(color.new(#f23645, 30), "High liquidity", inline = "liqc", group = GRP_LIQ)
color  liqLowColInput  = input.color(color.new(#089981, 30), "Low liquidity",  inline = "liqc", group = GRP_LIQ)
color  sweptColInput   = input.color(color.new(#ffeb3b, 0), "Sweep mark", group = GRP_LIQ)

var GRP_COLORS = "Colors"
color bullBprColorInput   = input.color(color.new(#089981, 60), "Bull BPR", inline = "bpr", group = GRP_COLORS)
color bearBprColorInput   = input.color(color.new(#f23645, 60), "Bear BPR", inline = "bpr", group = GRP_COLORS)
color fvgColorInput       = input.color(color.new(#2962ff, 85), "FVG",  inline = "comp", group = GRP_COLORS, active = showComponentsInput)
color ifvgColorInput      = input.color(color.new(#ff6d00, 85), "iFVG", inline = "comp", group = GRP_COLORS, active = showComponentsInput)

// ─── Constants ────────────────────────────────────────────────
string TZ = "America/New_York"

// ─── Types ────────────────────────────────────────────────────
type FVG
    float  top
    float  bottom
    bool   isBull
    int    startBar
    float  dispOpen      = na
    float  dispClose     = na
    bool   isInvalidated = false
    bool   isUsed        = false
    bool   entryFired    = false

type BPR
    float  top
    float  bottom
    float  fvgTop
    float  fvgBot
    float  ifvgTop
    float  ifvgBot
    bool   isBull
    int    startBar
    int    ifvgBar
    bool   isVShape      = false
    bool   isClosed      = false
    box    bprBox        = na
    box    fvgBox        = na
    box    ifvgBox       = na
    label  lbl           = na

type HtfFVG
    float  top
    float  bottom
    bool   isBull
    int    startBar
    bool   isMitigated = false
    int    lastTapBar  = na
    box    bx          = na
    label  lbl         = na

type Liq
    float  price
    bool   isHigh
    string kind
    int    originBar
    bool   isSwept   = false
    int    sweptBar  = na
    bool   isBroken  = false
    line   ln        = na
    label  lbl       = na
    label  swpLbl    = na

// ─── Arrays ───────────────────────────────────────────────────
var array<FVG>    fvgArray    = array.new<FVG>()
var array<BPR>    bprArray    = array.new<BPR>()
var array<HtfFVG> htfFvgArray = array.new<HtfFVG>()
var array<Liq>    liqArray    = array.new<Liq>()
var array<label>  vsMarkers   = array.new<label>()

// ─── Helpers ──────────────────────────────────────────────────
float atrVal = ta.atr(14)

deleteBprDrawings(BPR b) =>
    if not na(b.bprBox)
        box.delete(b.bprBox)
    if not na(b.fvgBox)
        box.delete(b.fvgBox)
    if not na(b.ifvgBox)
        box.delete(b.ifvgBox)
    if not na(b.lbl)
        label.delete(b.lbl)

// Snap chart-TF × mult (seconds) to the nearest standard TF string (never below chart TF)
f_resolveHtfTf(int mult) =>
    int t = timeframe.in_seconds() * mult
    t < 3      ? "1S"  :
     t < 8     ? "5S"  :
     t < 13    ? "10S" :
     t < 23    ? "15S" :
     t < 45    ? "30S" :
     t < 90    ? "1"   :
     t < 150   ? "2"   :
     t < 240   ? "3"   :
     t < 450   ? "5"   :
     t < 750   ? "10"  :
     t < 1350  ? "15"  :
     t < 2700  ? "30"  :
     t < 5400  ? "60"  :
     t < 10800 ? "120" :
     t < 50400 ? "240" : "1D"

// Create a liquidity level + its drawings, push to array
f_addLiq(float price, bool isHigh, string kind, int originBar) =>
    color c = isHigh ? liqHighColInput : liqLowColInput
    Liq q = Liq.new(price = price, isHigh = isHigh, kind = kind, originBar = originBar)
    q.ln  := line.new(originBar, price, bar_index + 1, price, color = c, width = 1, style = line.style_dotted)
    q.lbl := label.new(bar_index + 1, price, kind, style = label.style_label_left,
         color = color.new(color.black, 100), textcolor = c, size = size.tiny)
    array.push(liqArray, q)

// Fraction of the displacement candle's body (open→close) reclaimed by the inverting close
f_reclaimFrac(bool tradeBull, float dispOpen, float dispClose, float invClose) =>
    float body = math.abs(dispOpen - dispClose)
    body > 0 ? (tradeBull ? (invClose - dispClose) / (dispOpen - dispClose) : (dispClose - invClose) / (dispClose - dispOpen)) : 1.0

// V-Shape gate: does this zone react off a recently-tapped, still-valid HTF FVG of matching direction?
f_passesHtf(bool isBull, float zTop, float zBot) =>
    bool pass = false
    if array.size(htfFvgArray) > 0
        float buf = atrVal * (htfProxInput / 100.0)
        for hi = array.size(htfFvgArray) - 1 to 0
            HtfFVG g = array.get(htfFvgArray, hi)
            if not g.isMitigated and g.isBull == isBull
                bool tappedRecently = not na(g.lastTapBar) and (bar_index - g.lastTapBar <= htfTapWinInput)
                bool near           = zTop >= (g.bottom - buf) and zBot <= (g.top + buf)
                if tappedRecently and near
                    pass := true
                    break
    pass

// Was a correct-side liquidity level swept within `win` bars? (long wants a swept low, short a swept high)
// Was a correct-side liquidity level swept within `win` bars? Returns [found, name, price].
f_recentSweep(bool tradeBull, int win) =>
    bool   found = false
    string nm    = ""
    float  px    = na
    if array.size(liqArray) > 0
        for i = array.size(liqArray) - 1 to 0
            Liq q = array.get(liqArray, i)
            if q.isSwept and not na(q.sweptBar) and (bar_index - q.sweptBar <= win)
                if (tradeBull and not q.isHigh) or (not tradeBull and q.isHigh)
                    found := true
                    nm    := q.kind
                    px    := q.price
                    break
    [found, nm, px]

// Valid V-Shape context = HTF FVG tap OR (if enabled) a recent correct-side sweep.
// Returns [ok, reason] where reason describes the trigger for auditing.
f_hasContext(bool tradeBull, float zTop, float zBot) =>
    bool   htfOk   = f_passesHtf(tradeBull, zTop, zBot)
    bool   sweepOk = false
    string swNm    = ""
    float  swPx    = na
    if ctxSweepInput
        [s, n, p] = f_recentSweep(tradeBull, sweepWinInput)
        sweepOk := s
        swNm    := n
        swPx    := p
    string reason = htfOk ? "HTF tap" : sweepOk ? ("swept " + swNm + " @ " + str.tostring(swPx, format.mintick)) : "none"
    [htfOk or sweepOk, reason]


// Clean runway: is there an UN-swept opposite-side pool within `buf` of the entry, in the trade's path?
// Long → un-swept LOW resting below the entry (a downside draw). Short → un-swept HIGH resting above.
f_restingPoolInPath(bool tradeBull, float ref, float buf) =>
    bool blocked = false
    if array.size(liqArray) > 0
        for i = array.size(liqArray) - 1 to 0
            Liq q = array.get(liqArray, i)
            if not q.isSwept and not q.isBroken
                if tradeBull and not q.isHigh and q.price < ref and q.price >= ref - buf
                    blocked := true
                    break
                else if not tradeBull and q.isHigh and q.price > ref and q.price <= ref + buf
                    blocked := true
                    break
    blocked


// ─── HTF FVG (context) ────────────────────────────────────────
string htfTf = f_resolveHtfTf(htfMultInput)

[hH1, hL1, hH3, hL3, hTime] = request.security(syminfo.tickerid, htfTf,
     [high[1], low[1], high[3], low[3], time[1]], lookahead = barmerge.lookahead_on)

bool newHtfBar = ta.change(hTime) != 0
bool htfBull   = hL1 > hH3
bool htfBear   = hH1 < hL3
int  htfAnchor = math.max(0, bar_index - math.round(3.0 * htfMultInput))

if newHtfBar
    if htfBull
        HtfFVG g = HtfFVG.new(top = hL1, bottom = hH3, isBull = true, startBar = htfAnchor)
        if showHtfFvgInput
            g.bx  := box.new(htfAnchor, g.top, bar_index + 1, g.bottom,
                 border_color = color.new(htfFvgColorInput, 40), bgcolor = htfFvgColorInput, border_width = 1)
            g.lbl := label.new(bar_index + 1, math.avg(g.top, g.bottom), "HTF " + htfTf,
                 style = label.style_label_left, color = color.new(color.black, 100),
                 textcolor = color.new(color.gray, 20), size = size.small)
        array.push(htfFvgArray, g)
    if htfBear
        HtfFVG g = HtfFVG.new(top = hL3, bottom = hH1, isBull = false, startBar = htfAnchor)
        if showHtfFvgInput
            g.bx  := box.new(htfAnchor, g.top, bar_index + 1, g.bottom,
                 border_color = color.new(htfFvgColorInput, 40), bgcolor = htfFvgColorInput, border_width = 1)
            g.lbl := label.new(bar_index + 1, math.avg(g.top, g.bottom), "HTF " + htfTf,
                 style = label.style_label_left, color = color.new(color.black, 100),
                 textcolor = color.new(color.gray, 20), size = size.small)
        array.push(htfFvgArray, g)

if array.size(htfFvgArray) > 0
    for i = array.size(htfFvgArray) - 1 to 0
        HtfFVG g = array.get(htfFvgArray, i)
        if not g.isMitigated
            bool mitigated = g.isBull ? close < g.bottom : close > g.top
            if mitigated
                g.isMitigated := true
            else
                if high >= g.bottom and low <= g.top
                    g.lastTapBar := bar_index
                if not na(g.bx)
                    box.set_right(g.bx, bar_index + 1)
                if not na(g.lbl)
                    label.set_x(g.lbl, bar_index + 1)

while array.size(htfFvgArray) > maxHtfFvgInput
    HtfFVG oldHtf = array.shift(htfFvgArray)
    if not na(oldHtf.bx)
        box.delete(oldHtf.bx)
    if not na(oldHtf.lbl)
        label.delete(oldHtf.lbl)

// ─── Liquidity levels ─────────────────────────────────────────
float eqTol = atrVal * (eqTolInput / 100.0)

float ph       = ta.pivothigh(pivotLenInput, pivotLenInput)
float pl       = ta.pivotlow(pivotLenInput, pivotLenInput)
int   pivotBar = bar_index - pivotLenInput
var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(ph)
    bool isEq = useEqInput and not na(lastSwingHigh) and math.abs(ph - lastSwingHigh) <= eqTol
    if isEq
        f_addLiq(ph, true, "EQH", pivotBar)
    else if useSwingInput
        f_addLiq(ph, true, "Swing", pivotBar)
    lastSwingHigh := ph
if not na(pl)
    bool isEq = useEqInput and not na(lastSwingLow) and math.abs(pl - lastSwingLow) <= eqTol
    if isEq
        f_addLiq(pl, false, "EQL", pivotBar)
    else if useSwingInput
        f_addLiq(pl, false, "Swing", pivotBar)
    lastSwingLow := pl

[pdhVal, pdlVal] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
bool newDay = ta.change(time("D")) != 0
if usePdInput and newDay and not na(pdhVal)
    f_addLiq(pdhVal, true,  "PDH", bar_index)
    f_addLiq(pdlVal, false, "PDL", bar_index)

bool inLondon = not na(time(timeframe.period, londonSesInput, TZ))
bool inNyam   = not na(time(timeframe.period, nyamSesInput, TZ))

var float lonHigh = na
var float lonLow  = na
var int   lonHB   = na
var int   lonLB   = na
var bool  prevLon = false
var float nyHigh  = na
var float nyLow   = na
var int   nyHB    = na
var int   nyLB    = na
var bool  prevNy  = false

if useSessionInput
    if inLondon
        if not prevLon
            lonHigh := high
            lonLow  := low
            lonHB   := bar_index
            lonLB   := bar_index
        else
            if high > lonHigh
                lonHigh := high
                lonHB   := bar_index
            if low < lonLow
                lonLow := low
                lonLB  := bar_index
    if prevLon and not inLondon and not na(lonHigh)
        f_addLiq(lonHigh, true,  "London H", lonHB)
        f_addLiq(lonLow,  false, "London L", lonLB)
    prevLon := inLondon

    if inNyam
        if not prevNy
            nyHigh := high
            nyLow  := low
            nyHB   := bar_index
            nyLB   := bar_index
        else
            if high > nyHigh
                nyHigh := high
                nyHB   := bar_index
            if low < nyLow
                nyLow := low
                nyLB  := bar_index
    if prevNy and not inNyam and not na(nyHigh)
        f_addLiq(nyHigh, true,  "NYAM H", nyHB)
        f_addLiq(nyLow,  false, "NYAM L", nyLB)
    prevNy := inNyam

// ─── Sweep detection + level management ───────────────────────
if array.size(liqArray) > 0
    for i = array.size(liqArray) - 1 to 0
        Liq q = array.get(liqArray, i)
        if not q.isSwept and not q.isBroken
            if q.isHigh
                if close > q.price
                    q.isBroken := true
                else if high > q.price
                    q.isSwept  := true
                    q.sweptBar := bar_index
            else
                if close < q.price
                    q.isBroken := true
                else if low < q.price
                    q.isSwept  := true
                    q.sweptBar := bar_index

            if q.isSwept
                if markSweepsInput
                    q.swpLbl := label.new(bar_index, q.price, "✕",
                         style = q.isHigh ? label.style_label_down : label.style_label_up,
                         color = color.new(color.black, 100), textcolor = sweptColInput, size = size.tiny)
                if not na(q.ln)
                    line.set_x2(q.ln, bar_index)
                if not na(q.lbl)
                    label.set_x(q.lbl, bar_index)
            else if q.isBroken
                if not na(q.ln)
                    line.set_x2(q.ln, bar_index)
                if not na(q.lbl)
                    label.delete(q.lbl)
                    q.lbl := na
            else
                if not na(q.ln)
                    line.set_x2(q.ln, bar_index + 1)
                if not na(q.lbl)
                    label.set_x(q.lbl, bar_index + 1)

while array.size(liqArray) > maxLiqInput
    Liq oldLiq = array.shift(liqArray)
    if not na(oldLiq.ln)
        line.delete(oldLiq.ln)
    if not na(oldLiq.lbl)
        label.delete(oldLiq.lbl)
    if not na(oldLiq.swpLbl)
        label.delete(oldLiq.swpLbl)

// ─── Step 1: Invalidate FVGs → iFVGs + V-Shape entry on inversion close ─
bool vsEntryLong  = false
bool vsEntryShort = false

if array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        FVG f = array.get(fvgArray, i)

        // One-way invalidation latch (drives the BPR/iFVG machinery)
        if not f.isInvalidated
            if f.isBull and close < f.bottom
                f.isInvalidated := true
            else if not f.isBull and close > f.top
                f.isInvalidated := true

        // V-Shape entry: fire on the candle that closes through (inverts) the FVG.
        // Evaluated on bar close (barstate.isconfirmed) so it never repaints.
        if not f.entryFired and barstate.isconfirmed
            bool invUp   = not f.isBull and close > f.top    and close[1] <= f.top
            bool invDown = f.isBull     and close < f.bottom and close[1] >= f.bottom
            if invUp or invDown
                bool  tradeBull = invUp
                bool  recent    = bar_index - f.startBar <= lookbackInput
                float frac      = f_reclaimFrac(tradeBull, f.dispOpen, f.dispClose, close)
                bool  strong    = frac >= (strongCloseInput / 100.0)
                bool  tipOk     = not cleanVTipInput ? true : (tradeBull ? close[1] < open[1] : close[1] > open[1])
                bool   gateOk     = true
                string gateReason = "gate off"
                if gateHtfInput
                    [go, gr] = f_hasContext(tradeBull, f.top, f.bottom)
                    gateOk     := go
                    gateReason := gr
                bool   gated      = gateOk
                float pathBuf   = atrVal * (pathBufInput / 100.0)
                bool  pathOk    = not clearPathInput ? true : not f_restingPoolInPath(tradeBull, tradeBull ? low : high, pathBuf)
                string fvgName  = (f.isBull ? "bull" : "bear") + " FVG " + str.tostring(f.bottom, format.mintick) + "–" + str.tostring(f.top, format.mintick)
                string audit    = "inv " + fvgName + " · " + gateReason + " · reclaim " + str.tostring(math.round(frac * 100)) + "%"
                if recent and strong and tipOk and gated and pathOk
                    f.entryFired := true
                    if tradeBull and not vsEntryLong
                        vsEntryLong := true
                        if vsEntryShowInput
                            label lbL = label.new(bar_index, low, "▲",
                                 style = label.style_label_up,
                                 color = color.new(color.black, 100),
                                 textcolor = color.new(bullBprColorInput, 0), size = size.small,
                                 tooltip = "▲ " + audit)
                            array.push(vsMarkers, lbL)
                    else if not tradeBull and not vsEntryShort
                        vsEntryShort := true
                        if vsEntryShowInput
                            label lbS = label.new(bar_index, high, "▼",
                                 style = label.style_label_down,
                                 color = color.new(color.black, 100),
                                 textcolor = color.new(bearBprColorInput, 0), size = size.small,
                                 tooltip = "▼ " + audit)
                            array.push(vsMarkers, lbS)

while array.size(vsMarkers) > maxBprInput
    label oldM = array.shift(vsMarkers)
    label.delete(oldM)

alertcondition(vsEntryLong,  title = "V-Shape Long Entry",  message = "V-Shape long entry — iFVG inversion")
alertcondition(vsEntryShort, title = "V-Shape Short Entry", message = "V-Shape short entry — iFVG inversion")

// ─── Step 2: Detect new FVGs ─────────────────────────────────
bool newBullFvg = low > high[2]
bool newBearFvg = high < low[2]

float bullFvgTop = low
float bullFvgBot = high[2]
float bearFvgTop = low[2]
float bearFvgBot = high

if newBullFvg
    array.push(fvgArray, FVG.new(top = bullFvgTop, bottom = bullFvgBot, isBull = true, startBar = bar_index - 1, dispOpen = open[1], dispClose = close[1]))

if newBearFvg
    array.push(fvgArray, FVG.new(top = bearFvgTop, bottom = bearFvgBot, isBull = false, startBar = bar_index - 1, dispOpen = open[1], dispClose = close[1]))

// ─── Step 3: Check new FVGs against iFVGs for BPR ────────────
// Bullish BPR = new bullish FVG overlapping a bearish iFVG
if newBullFvg and array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        FVG f = array.get(fvgArray, i)
        if f.isInvalidated and not f.isBull and not f.isUsed
            if bar_index - f.startBar > lookbackInput
                continue
            float oTop = math.min(bullFvgTop, f.top)
            float oBot = math.max(bullFvgBot, f.bottom)
            if oTop > oBot
                float minSize = atrVal * (minOverlapTickInput / 100.0)
                if oTop - oBot < minSize
                    continue
                bool passes = true
                if gateHtfInput
                    [ok, _r] = f_hasContext(true, oTop, oBot)
                    passes := ok
                if gateHtfInput and hideNonVsInput and not passes
                    f.isUsed := true
                    break
                f.isUsed := true
                bool isVs = gateHtfInput and passes
                BPR b = BPR.new(
                     top = oTop, bottom = oBot,
                     fvgTop = bullFvgTop, fvgBot = bullFvgBot,
                     ifvgTop = f.top, ifvgBot = f.bottom,
                     isBull = true, startBar = bar_index, ifvgBar = f.startBar, isVShape = isVs)
                b.bprBox := box.new(f.startBar, oTop, bar_index + 1, oBot,
                     border_color = color.new(bullBprColorInput, 0), bgcolor = bullBprColorInput,
                     border_width = isVs ? 2 : 1)
                b.lbl := label.new(bar_index + 1, math.avg(oTop, oBot), isVs ? "V-BPR" : "BPR",
                     style = label.style_label_left,
                     color = color.new(color.black, 100),
                     textcolor = color.new(bullBprColorInput, 0),
                     size = size.small)
                if showComponentsInput
                    b.fvgBox := box.new(b.startBar, bullFvgTop, bar_index + 1, bullFvgBot,
                         border_color = fvgColorInput, bgcolor = color.new(fvgColorInput, 92),
                         border_style = line.style_dashed, border_width = 1)
                    b.ifvgBox := box.new(b.startBar, f.top, bar_index + 1, f.bottom,
                         border_color = ifvgColorInput, bgcolor = color.new(ifvgColorInput, 92),
                         border_style = line.style_dashed, border_width = 1)
                array.push(bprArray, b)
                break

// Bearish BPR = new bearish FVG overlapping a bullish iFVG
if newBearFvg and array.size(fvgArray) > 0
    for i = array.size(fvgArray) - 1 to 0
        FVG f = array.get(fvgArray, i)
        if f.isInvalidated and f.isBull and not f.isUsed
            if bar_index - f.startBar > lookbackInput
                continue
            float oTop = math.min(bearFvgTop, f.top)
            float oBot = math.max(bearFvgBot, f.bottom)
            if oTop > oBot
                float minSize = atrVal * (minOverlapTickInput / 100.0)
                if oTop - oBot < minSize
                    continue
                bool passes = true
                if gateHtfInput
                    [ok, _r] = f_hasContext(false, oTop, oBot)
                    passes := ok
                if gateHtfInput and hideNonVsInput and not passes
                    f.isUsed := true
                    break
                f.isUsed := true
                bool isVs = gateHtfInput and passes
                BPR b = BPR.new(
                     top = oTop, bottom = oBot,
                     fvgTop = bearFvgTop, fvgBot = bearFvgBot,
                     ifvgTop = f.top, ifvgBot = f.bottom,
                     isBull = false, startBar = bar_index, ifvgBar = f.startBar, isVShape = isVs)
                b.bprBox := box.new(f.startBar, oTop, bar_index + 1, oBot,
                     border_color = color.new(bearBprColorInput, 0), bgcolor = bearBprColorInput,
                     border_width = isVs ? 2 : 1)
                b.lbl := label.new(bar_index + 1, math.avg(oTop, oBot), isVs ? "V-BPR" : "BPR",
                     style = label.style_label_left,
                     color = color.new(color.black, 100),
                     textcolor = color.new(bearBprColorInput, 0),
                     size = size.small)
                if showComponentsInput
                    b.fvgBox := box.new(b.startBar, bearFvgTop, bar_index + 1, bearFvgBot,
                         border_color = fvgColorInput, bgcolor = color.new(fvgColorInput, 92),
                         border_style = line.style_dashed, border_width = 1)
                    b.ifvgBox := box.new(b.startBar, f.top, bar_index + 1, f.bottom,
                         border_color = ifvgColorInput, bgcolor = color.new(ifvgColorInput, 92),
                         border_style = line.style_dashed, border_width = 1)
                array.push(bprArray, b)
                break

// ─── Step 4: Manage BPRs — extend or mark closed ─────────────
if array.size(bprArray) > 0
    for i = array.size(bprArray) - 1 to 0
        BPR b = array.get(bprArray, i)
        if not b.isClosed
            bool closedThrough = b.isBull ? close < b.bottom : close > b.top
            bool maxExtReached = bar_index - b.startBar >= maxExtInput
            if closedThrough or maxExtReached
                b.isClosed := true
            else
                if not na(b.bprBox)
                    box.set_right(b.bprBox, bar_index + 1)
                if not na(b.lbl)
                    label.set_x(b.lbl, bar_index + 1)
                    label.set_y(b.lbl, math.avg(b.top, b.bottom))
                if not na(b.fvgBox)
                    box.set_right(b.fvgBox, bar_index + 1)
                if not na(b.ifvgBox)
                    box.set_right(b.ifvgBox, bar_index + 1)

// ─── Step 5: Enforce max BPR count ───────────────────────────
while array.size(bprArray) > maxBprInput
    BPR oldest = array.shift(bprArray)
    deleteBprDrawings(oldest)

// ─── Cleanup stale FVGs (memory hygiene) ─────────────────────
while array.size(fvgArray) > 500
    array.shift(fvgArray)
````
