<!-- tradingview-pine-id: PUB;f2e3840fc38d44e6adafe2f1dabdd0eb -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stretch z — distance from session VWAP

Source: https://www.tradingview.com/script/Qn5UJ69c-Stretch-z-distance-from-session-VWAP/

## Description

Stretch z — distance from session VWAP, normalised

Ten dollars from VWAP means something completely different on a dead Tuesday than it does thirty seconds after a number drops. Most "distance from VWAP" tools don't know that — they plot the raw dollar gap and leave you to eyeball whether it looks big today. This pane won't plot a number until it's been made to mean the same thing on any day, in any volatility regime, on any instrument.

The problem with a dollar amount

Raw distance from VWAP isn't comparable across sessions, let alone across symbols. A given point distance on gold during a quiet Asian session and the same point distance thirty seconds after a data release aren't the same event, even though the ruler says they are. The fix is standardisation: divide the raw distance by a measure of how far price normally sits from VWAP right now, and the number stops being "$10" and starts being "how unusual is this, given what unusual looks like today." Do that consistently and the reading also becomes portable — the same z = 2 means roughly the same thing on GC and on NQ, without retuning a single input between them.

Two normalisers, two different claims

You get an explicit choice, because the two options aren't interchangeable and I didn't want to hide that. Dividing by the rolling standard deviation of the spread produces an actual z-score — a statement about how many typical deviations price currently sits from VWAP, with the probabilistic interpretation that implies. Dividing by daily ATR instead produces a distance expressed in units of a familiar, point-based measure — easier to reason about at a glance, portable across timeframes you already think in ATR terms, but it is not a z-score, and the same band thresholds mean something different depending on which one you picked. The tool doesn't pretend these are the same thing wearing different clothes.

Don't trust a variance estimate you just started counting

There are two ways to estimate "normal" dispersion, and each has a real cost. A rolling window (60 bars by default) gives a stable estimate built on a real sample size, but it can straddle a session boundary — at 09:35 that window is still mostly measuring yesterday's regime, not today's. A session-anchored estimate restarts at the open and builds its variance forward, bar by bar, from a running sum and sum-of-squares (with Bessel's correction applied for a proper sample variance) — statistically cleaner, because it only ever describes the session you're actually in, but noisy and untrustworthy for the first handful of bars, when "normal dispersion" is being estimated off three or four data points. Rather than plot a confident-looking number built on a sample too small to support it, the pane suppresses the reading — and the alerts — until the estimate has enough bars behind it to mean something.

A parametric score deserves a non-parametric gut check

A z-score's "how unusual is this" framing leans on the reading behaving roughly like a normal distribution, and a futures spread doesn't always cooperate with that assumption. So alongside the z-score itself, the readout reports where the current |z| ranks against its own trailing 500-bar history — the same question, asked empirically, without needing the distribution to be well-behaved. If the two ever disagree meaningfully, that disagreement is informative on its own.

The bands aren't decorative — they're calibrated

Distance from VWAP isn't universally good or bad; what it means depends entirely on what you're trying to do with it. The readout scores the same z-band differently for three separate trade setups, and the weighting isn't monotonic in the same direction for all three — one setup scores highest when price sits close to VWAP and falls off as stretch increases, while another actually peaks in the 2–3σ band rather than near zero, which lines up with what earlier backtesting on that setup already found. Treating "how stretched is price" as a conditioning variable that different setups respond to differently, rather than a single filter everyone reads the same way, is the actual point of the table — a live, at-a-glance version of a relationship that was originally found by looking backward, not a number invented for the chart.

How I actually use it

Before taking any of the three setups this table tracks, I check the band and the points column, not just the raw z-score — a "big" z-score isn't automatically good or bad news, and the table already tells me which setup it favors and which it doesn't. The percentile column is my sanity check against the regime itself: a 2–3σ reading on a slow, thin session is a genuinely rare event; the same reading thirty seconds into a volatile one might barely be top-quartile, and the percentile is what tells the two apart when the z-score alone can't. The two band-cross alerts do the actual watching — I don't need to sit on the pane all session waiting for the reading to become interesting; it tells me when it has.

(Default window length and weights are set to match a scoring workbook I built earlier in this framework — you don't need that workbook to use this pane, but if the defaults look oddly specific, that's why.)

No time travel

Session VWAP is a standard, non-repainting session-anchored calculation. Daily ATR is retrieved through a security request with lookahead explicitly disabled and offset by one bar before the request, the documented non-repainting pattern for higher-timeframe data. Nothing on the pane, and no alert it fires, depends on information that wasn't available at the time.

What's proven, and what isn't yet

The normalisation logic and the small-sample discipline are sound on their own statistical merits — that part doesn't need a backtest to justify it. The per-setup weights are a different matter: they encode a relationship I'd already found in earlier research on this framework's setups, not a fresh statistical test run by this indicator itself, and the three band edges (1σ, 2σ, 3σ) are conventional defaults rather than something optimised inside this script. A companion scoring workbook in the same framework carries Monte-Carlo-validated adaptive thresholds; this pane trades that adaptivity for a lighter, always-on read, and it's worth knowing which tool you're looking at if the two ever disagree.

Limitations

Runs on any TradingView plan — unlike footprint-based tools, this only needs price and volume, not order-by-order data.
Built for standard candlestick charts; since it emits alertconditions, treat it like any signal-generating script and avoid Heikin Ashi, Renko, or other synthetic chart types.
Session-anchored mode needs roughly 20 bars into the session before its reading is trustworthy; the pane stays blank until then rather than show a number that isn't earned yet.
Default bands and setup weights are tuned for the framework and instrument I built this on; treat them as a starting point, not a universal constant, on a different symbol or session.

---

## Source Code

````pine
//@version=6
// =========================================================================
//  STRETCH z — DISTANCE FROM SESSION VWAP, NORMALISED
//
//  Companion to the continuation scorecard. Reports the live z reading, the
//  band it falls in, and what that band is worth to each setup.
//
//  z = (price - session VWAP) / normaliser
//
//  Raw distance from VWAP is not comparable across days or instruments:
//  $10 from VWAP is an extreme on a quiet gold session and noise during a
//  release. Dividing by a measure of normal dispersion makes the number mean
//  the same thing in any volatility regime, and makes it portable between
//  GC and NQ without retuning.
// =========================================================================

indicator("Stretch z — distance from session VWAP", overlay = false, max_labels_count = 50)

grpC = "① CALCULATION"
string iNorm  = input.string("Std dev of spread (matches scorecard)", "Normaliser", options = ["Std dev of spread (matches scorecard)", "ATR (literal 'ATR stretch')"], group = grpC, tooltip = "Std dev of spread = a true statistical z-score: how unusual is this distance versus how far price normally sits from VWAP. This is what the scorecard uses.\n\nATR = distance expressed in units of daily ATR. Easier to reason about in points, but it is not a z-score and the band thresholds mean something different.")
int    iWin   = input.int(60, "Rolling window (bars)", minval = 10, group = grpC, tooltip = "Window for the standard deviation of the VWAP spread. 60 matches the scorecard.")
bool   iAnchor = input.bool(false, "Anchor the window to the session", group = grpC, tooltip = "OFF (default) = a rolling window that crosses the session boundary, identical to the scorecard.\n\nON = restart the dispersion estimate at each session open. Cleaner statistically, because a rolling window at 09:35 is still mostly measuring yesterday, but the readings will then differ from the scorecard. See the notes in the description.")
int    iATRLen = input.int(14, "Daily ATR length", minval = 2, group = grpC)
string iSess  = input.session("0830-1700", "Session (anchors VWAP)", group = grpC)

grpB = "② BANDS"
float iB1 = input.float(1.0, "Band 1", step = 0.1, group = grpB)
float iB2 = input.float(2.0, "Band 2", step = 0.1, group = grpB)
float iB3 = input.float(3.0, "Band 3", step = 0.1, group = grpB)

grpW = "③ SETUP WEIGHTS (points awarded per band)"
bool  iShowW = input.bool(true, "Show the setup weighting table", group = grpW)
string iS2n = input.string("Value Acceptance", "Setup 1 name", group = grpW)
string iS4n = input.string("Balance Break", "Setup 2 name", group = grpW)
string iS5n = input.string("Trend Pullback", "Setup 3 name", group = grpW)
int iS2a = input.int(4, "S1: |z|<1", group = grpW, inline = "s2")
int iS2b = input.int(3, "1-2", group = grpW, inline = "s2")
int iS2c = input.int(1, "2-3", group = grpW, inline = "s2")
int iS2d = input.int(0, ">3", group = grpW, inline = "s2")
int iS4a = input.int(4, "S2: |z|<1", group = grpW, inline = "s4")
int iS4b = input.int(3, "1-2", group = grpW, inline = "s4")
int iS4c = input.int(1, "2-3", group = grpW, inline = "s4")
int iS4d = input.int(0, ">3", group = grpW, inline = "s4")
int iS5a = input.int(1, "S3: |z|<1", group = grpW, inline = "s5")
int iS5b = input.int(2, "1-2", group = grpW, inline = "s5")
int iS5c = input.int(4, "2-3", group = grpW, inline = "s5")
int iS5d = input.int(1, ">3", group = grpW, inline = "s5")

grpU = "④ COLOURS"
color iUp   = input.color(#2E7D6B, "z above VWAP", group = grpU)
color iDn   = input.color(#A64B5F, "z below VWAP", group = grpU)
color iB1c  = input.color(color.new(#8E9BAE, 40), "Band 1 line", group = grpU)
color iB2c  = input.color(color.new(#C9A227, 30), "Band 2 line", group = grpU)
color iB3c  = input.color(color.new(#B0413E, 20), "Band 3 line", group = grpU)
color iZero = input.color(color.new(#8E9BAE, 60), "Zero line", group = grpU)
bool  iHue    = input.bool(true, "Shade when stretched (fades in past band 2)", group = grpU)
color iHueUp  = input.color(#D85A30, "Stretched-above hue", group = grpU)
color iHueDn  = input.color(#1D9E75, "Stretched-below hue", group = grpU)
bool  iFillB  = input.bool(false, "Also shade the static band zone", group = grpU)
color iFillC  = input.color(color.new(#C9A227, 92), "Static band colour", group = grpU)
bool  iShowT = input.bool(true, "Show readout table", group = grpU)
string iPos  = input.string("Top right", "Table position", options = ["Top right", "Middle right", "Bottom right", "Top left"], group = grpU)

// ── session anchoring ─────────────────────────────────────────────────────
bool inSess  = not na(time(timeframe.period, iSess))
bool newSess = inSess and not inSess[1]

float vw = ta.vwap(hlc3)
float spread = close - vw

float atrD = request.security(syminfo.tickerid, "D", ta.atr(iATRLen)[1], lookahead = barmerge.lookahead_off)

// rolling dispersion — matches the scorecard
float sdRoll = ta.stdev(spread, iWin)

// session-anchored dispersion, built forward from the open
var float sSum  = 0.0
var float sSumSq = 0.0
var int   sN    = 0
if newSess
    sSum   := 0.0
    sSumSq := 0.0
    sN     := 0
if inSess
    sSum   := sSum + spread
    sSumSq := sSumSq + spread * spread
    sN     := sN + 1
float sdSess = na
if sN > 1
    float mean = sSum / sN
    float varr = (sSumSq / sN) - (mean * mean)
    sdSess := varr > 0 ? math.sqrt(varr * sN / (sN - 1)) : na

bool useATR = iNorm == "ATR (literal 'ATR stretch')"
float sdPick = iAnchor ? sdSess : sdRoll
float norm = useATR ? atrD : sdPick

float z = 0.0
if not na(norm) and norm != 0
    z := spread / norm

// the estimate is unreliable until the window has filled
bool warming = iAnchor ? (sN < 20) : (bar_index < iWin)

// ── band and weights ──────────────────────────────────────────────────────
float az = math.abs(z)
string band = ">3"
if az < iB1
    band := "<1"
else if az < iB2
    band := "1-2"
else if az < iB3
    band := "2-3"

pickW(int a, int b, int c, int d) =>
    int r = d
    if band == "<1"
        r := a
    else if band == "1-2"
        r := b
    else if band == "2-3"
        r := c
    r

int w2 = pickW(iS2a, iS2b, iS2c, iS2d)
int w4 = pickW(iS4a, iS4b, iS4c, iS4d)
int w5 = pickW(iS5a, iS5b, iS5c, iS5d)

// how unusual is this reading historically, on this symbol and timeframe
float pctl = ta.percentrank(az, 500)

// ── plot ──────────────────────────────────────────────────────────────────
color zc = z >= 0 ? iUp : iDn
zPlot = plot(warming ? na : z, "Stretch z", zc, 2)
midPlot = plot(0, "mid", color = na, editable = false, display = display.none)
hline(0, "Zero", iZero, hline.style_solid)

// Gradient hue: transparent at band 2, fully saturated at band 3 and beyond.
// The shading is a visual restatement of the score - it fades in exactly where
// the reading stops being ordinary, so the pane reads at a glance.
fill(zPlot, midPlot, iB3, iB2, iHue ? color.new(iHueUp, 20) : na, iHue ? color.new(iHueUp, 100) : na, title = "Stretched above")
fill(zPlot, midPlot, -iB2, -iB3, iHue ? color.new(iHueDn, 100) : na, iHue ? color.new(iHueDn, 20) : na, title = "Stretched below")
b1u = hline(iB1, "+1", iB1c, hline.style_dotted)
b1d = hline(-iB1, "-1", iB1c, hline.style_dotted)
b2u = hline(iB2, "+2", iB2c, hline.style_dashed)
b2d = hline(-iB2, "-2", iB2c, hline.style_dashed)
hline(iB3, "+3", iB3c, hline.style_solid)
hline(-iB3, "-3", iB3c, hline.style_solid)
fill(b2u, b1u, color = iFillB ? iFillC : na, title = "Stretched above")
fill(b1d, b2d, color = iFillB ? iFillC : na, title = "Stretched below")

// ── readout ───────────────────────────────────────────────────────────────
var table t = table.new(iPos == "Top right" ? position.top_right : iPos == "Middle right" ? position.middle_right : iPos == "Bottom right" ? position.bottom_right : position.top_left, 2, 9, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 60))

cell(int r, int c, string s, color bg, color fg, simple string sz) =>
    table.cell(t, c, r, s, text_color = fg, bgcolor = bg, text_size = sz)

if barstate.islast and iShowT
    table.clear(t, 0, 0, 1, 8)
    color hdr = color.new(#C3D2E4, 0)
    color bod = color.new(#EDEFF2, 0)
    color ink = #34435A
    int r = 0
    cell(r, 0, "STRETCH z", hdr, ink, size.normal)
    cell(r, 1, warming ? "warming up" : str.tostring(math.round(z * 100) / 100), hdr, ink, size.normal)
    r += 1
    cell(r, 0, "Band", bod, ink, size.small)
    cell(r, 1, "|z| " + band, bod, ink, size.small)
    r += 1
    cell(r, 0, "Distance from VWAP", bod, ink, size.small)
    cell(r, 1, str.tostring(math.round(spread / syminfo.mintick) * syminfo.mintick), bod, ink, size.small)
    r += 1
    cell(r, 0, "Normaliser", bod, ink, size.small)
    cell(r, 1, useATR ? "ATR " + str.tostring(math.round(nz(atrD) * 100) / 100) : "SD " + str.tostring(math.round(nz(sdPick) * 100) / 100), bod, ink, size.small)
    r += 1
    cell(r, 0, "|z| percentile (500 bars)", bod, ink, size.small)
    cell(r, 1, warming ? "-" : str.tostring(math.round(pctl)) + "%", bod, ink, size.small)
    r += 1
    if iShowW
        cell(r, 0, "POINTS BY SETUP", hdr, ink, size.small)
        cell(r, 1, "", hdr, ink, size.small)
        r += 1
        cell(r, 0, iS2n, bod, ink, size.small)
        cell(r, 1, str.tostring(w2), bod, ink, size.small)
        r += 1
        cell(r, 0, iS4n, bod, ink, size.small)
        cell(r, 1, str.tostring(w4), bod, ink, size.small)
        r += 1
        cell(r, 0, iS5n, bod, ink, size.small)
        cell(r, 1, str.tostring(w5), bod, ink, size.small)

// ── alerts ────────────────────────────────────────────────────────────────
bool crossed2 = ta.cross(az, iB2) and not warming
bool crossed3 = ta.cross(az, iB3) and not warming
alertcondition(crossed2, "Stretch z crossed band 2", "Stretch z crossed the second band")
alertcondition(crossed3, "Stretch z crossed band 3", "Stretch z crossed the third band")
````
