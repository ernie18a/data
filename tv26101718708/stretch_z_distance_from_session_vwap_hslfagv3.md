# Stretch z  distance from session VWAP

- url: https://www.tradingview.com/script/hSLfagv3-Stretch-z-distance-from-session-VWAP/
- type: indicator
- pine_id: PUB;4456683c006e4d6d8b78fe783d4a6966
- version: 1.0

## Description

[b]What it does[/b]

This indicator measures how far price has travelled from the session VWAP and expresses that distance as a normalised score, so the reading means the same thing on a quiet day as on a violent one.

It plots the score in a separate pane with reference bands, and shows a readout of the current value, the band it sits in, the raw distance in points, and where the reading ranks against recent history.

The problem it addresses

Distance from VWAP is a natural thing to watch, but the raw number is not comparable across time or symbols. Ten dollars from VWAP might be an extreme on a quiet gold session and completely ordinary during a high-volatility release. The same is true across instruments: a distance that is stretched on one contract is meaningless on another.

The fix is to divide the distance by a measure of how far price normally sits from VWAP. What comes out is a dimensionless score. A reading of 2 means roughly the same thing regardless of instrument or volatility regime, which makes thresholds portable rather than something you retune every few months.

How it is calculated
z = (price - session VWAP) / dispersion

VWAP is anchored to the session set in the inputs and resets each session.

Dispersion is selectable:

Standard deviation of the spread. The standard deviation of (price - VWAP) over a rolling window. This produces a true z-score, answering how unusual the current distance is compared with how far price normally sits from VWAP on this symbol.
ATR. The daily average true range. This expresses the distance in units of daily range instead. It is easier to reason about in points, but it is not a z-score, and the band thresholds mean something different under it. Pick one convention and stay with it.
The session-anchoring option

This is the part that differs most from a standard VWAP deviation plot, and it is worth understanding before you use the indicator.

A rolling dispersion window carries across the session boundary. At the session open, VWAP resets and the spread collapses toward zero, but the rolling window is still filled with the previous session's much larger spreads. The dispersion estimate is therefore too large in the early session, which makes the score read too small precisely when you are most likely to be looking at it.

The size of the effect depends on your chart timeframe and window length: a 60-bar window on a 5-minute chart does not fully clear the previous session for about five hours.

Switching Anchor the window to the session ON restarts the dispersion estimate at each open and builds it forward. This removes the carry-over. The trade-off is that with only a handful of bars the estimate is noisy, so the first several bars of each session are less reliable in a different way. Neither setting is universally correct; the option exists so you can see the difference on your own charts and choose deliberately rather than inherit an assumption.

The indicator suppresses output while the estimate is still warming up under either setting.

How to use it

Reading the score. Zero means price is at the session VWAP. Positive means above, negative means below. The magnitude is the interesting part: it tells you whether the current distance is normal or unusual for this instrument, rather than merely how far price has moved.

Bands as context, not signals. The bands mark where readings become progressively less common. A reading inside the first band is ordinary. Beyond the second, price is unusually far from where the session has been transacting. Beyond the third, it is far enough that the reading itself is rare. None of these is an instruction to do anything, and the indicator issues no entry or exit signals.

As a filter rather than a trigger. The most straightforward use is as a condition applied to setups you are already trading. Strategies that depend on price being near value behave differently when the score is high, and strategies that depend on price having extended behave differently when it is low. The score gives you a consistent way to describe that condition instead of eyeballing it.

The percentile row. The readout shows where the current absolute reading ranks against the last 500 bars. This separates a reading that is genuinely rare for the symbol from one that merely looks large on the pane. If the score reads 2.5 but the percentile is 80%, that magnitude is common on this instrument and timeframe.

Direction versus magnitude. The sign tells you which side of value price is on; the magnitude tells you how far. These carry different information. Price can be persistently above VWAP with a small score, which describes an orderly trend, or briefly above with a large score, which describes a sharp excursion.

The band scoring table

If you grade setups with a checklist, the optional table maps each band to a point value for up to three named strategies, and shows what the current band is worth to each of them side by side.

This exists because the same reading is not equally meaningful to different approaches. A strategy that enters near value and a strategy that enters after extension will value a high reading very differently, sometimes in opposite directions. Rather than assume one interpretation, the indicator lets you define the mapping yourself.

All twelve point values, and the three strategy names, are inputs. The defaults are placeholders and carry no claim about which values are correct. If you use the table, set the values from your own testing.

Limitations
The score is not predictive. It describes where price currently sits relative to the session's transaction history. It says nothing about what happens next, and an unusual reading can persist for a long time or become more unusual still.

Early-session readings are less reliable under both dispersion settings, for the different reasons described above.

The two normalisers are not interchangeable. Thresholds set under one do not carry over to the other.

The session setting matters. VWAP anchors to it, so an incorrect session for your instrument produces a meaningless spread and therefore a meaningless score.

On very low-volume or illiquid symbols, VWAP itself is unstable, and the score inherits that instability.

The percentile row is relative to the last 500 bars of the chart you are on. Changing timeframe changes what it is comparing against.

The daily ATR is requested with lookahead disabled and uses the previous completed daily bar, so it does not repaint.

Settings

Normaliser - standard deviation of the spread, or ATR.
Rolling window - bars used for the dispersion estimate.
Anchor the window to the session - restart the dispersion estimate at each open.
Daily ATR length - used only when ATR is the normaliser.
Session - the window VWAP anchors to.
Bands - the three reference levels.
Band scoring - optional point mapping for up to three named strategies.
Colours - line, band, shading and table colours.

This indicator is a descriptive tool. It does not generate buy or sell signals and makes no claim about future price movement

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
bool  iFillB = input.bool(true, "Shade beyond band 2", group = grpU)
color iFillC = input.color(color.new(#C9A227, 88), "Shade colour", group = grpU)
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
plot(warming ? na : z, "Stretch z", zc, 2)
hline(0, "Zero", iZero, hline.style_solid)
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
