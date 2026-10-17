# Volatility Reversion Bands Pro [JOAT]

- url: https://www.tradingview.com/script/vPkf0EgS-Volatility-Reversion-Bands-Pro-JOAT/
- type: indicator
- pine_id: PUB;da0de11acd474caba9667da7b8660c27
- version: 1.0

## Description

[b]VOLATILITY REVERSION BANDS PRO [JOAT][/b]

A two-layer reversion envelope: inner Bollinger band for the [i]normal[/i] volatility envelope, outer ATR-extended band for the [i]extreme[/i] envelope. Signals only fire when price has reached the outer ring — the inner band is context, the outer band is the trigger. The result is a clean mean-reversion engine that respects the difference between "stretched" and "actually stretched".

[image]https://www.tradingview.com/x/55PYyKqs/[/image]

[b]Two envelopes, one principle[/b]

[list]
[*] [b]Inner band[/b] — classic Bollinger: basis (SMA or EMA) ± stdev × multiplier. The familiar 20-period, 2-sigma defaults are preserved.
[*] [b]Outer reversion band[/b] — the outer envelope extends [b]inner band ± ATR × multiplier[/b]. This is the band that triggers signals. Setting the ATR multiplier high makes signals rarer but deeper; setting it low makes them frequent and shallower.
[/list]

Reversion bands using stdev alone collapse in low-volatility regimes (too many false signals) and explode in high-volatility regimes (signals come too late). The ATR extension on top of stdev fixes both: ATR adds a constant-floor protection in quiet markets and scales the outer band proportionally in loud ones.

[b]Strong vs weak signals[/b]

Two signal tiers from a single channel-ratio read (close position within the outer band, normalised 0–1):

[list]
[*] [b]Strong signals[/b] — fire on the outer band itself (ratio ≤ 0 or ≥ 1). The high-conviction reversion read.
[*] [b]Weak signals[/b] — fire when ratio reaches a configurable near-band threshold (default 0.10 / 0.90). The "approaching outer band" read — useful for traders who want earlier hints. Easily disabled.
[/list]

A signal cooldown suppresses same-side repetition; an [b]exhaustion arrow[/b] prints when N consecutive bars (default 3) all live in the outer-band zone — a configurable escalating-glyph string ("^", "^^", "^^^"…) makes the run length visible at a glance.

[b]Volatility regime classification[/b]

Independent of signals, the script classifies the current volatility regime by comparing current stdev to its own rolling average over a long lookback (default 100 bars):

[list]
[*] [b]Low regime[/b] — stdev / avgStdev below the low threshold (default 1.0×). Reversion is more reliable here.
[*] [b]High regime[/b] — above the high threshold (default 2.0×). Reversion is less reliable here; trends become dominant.
[*] [b]Normal regime[/b] — in between. Default mode.
[/list]

Background tinting (toggleable, transparency-controlled) paints the chart by regime so the trader can see at a glance whether the current environment is suitable for reversion. This is the "do not fight the tape" filter — when the background is hot, every reversion signal is lower-conviction by definition.

[b]Visual system[/b]

[list]
[*] [b]Bar gradient[/b] — bars are coloured by their position-in-band ratio (bull → mid → bear via plasma palette). At a glance you can see where price is sitting in the channel without reading the value.
[*] [b]Inner band fill[/b] — toggleable shoulder fill between BB and outer reversal bands with configurable transparency.
[*] [b]Inner BB lines[/b] and [b]basis line[/b] are each independently toggleable for traders who want a minimalist or full envelope view.
[*] [b]Signal label style[/b] — Glyph (compact), Text (verbose), or Both.
[/list]

A locked Plasma palette (yellow bull, magenta bear, violet mid) on a deep-void background gives the chart a distinctive look without competing with price action.

[b]Dashboard[/b]

Monospaced table, positionable to any of nine corners, with togglable legend footer. Rows surface current basis, inner band values, outer reversion band values, channel ratio %, stdev / avgStdev ratio, regime label, last signal direction with age, and an exhaustion run counter.

[b]Alerts[/b]

Four alert conditions, each independently controllable:

[list]
[*] Strong Long / Short (outer band touch reversion)
[*] Weak Long / Short (near-band threshold)
[*] Vol Regime Change
[*] Exhaustion Arrow (consecutive bars in outer-band zone)
[/list]

[image]https://www.tradingview.com/x/q7jI6HuB/[/image]

[b]How to read it[/b]

Two reads, in order of conviction:

[list=1]
[*] [b]Strong signal in a Low or Normal regime[/b] — the script's intended sweet spot. The outer band has been touched, price is statistically far from its mean, and the volatility environment supports the idea of mean-reversion.
[*] [b]Exhaustion arrow[/b] — when 3+ bars sit in the outer band, you usually have either a genuine breakout (the bands themselves will start to expand) or an exhaustion (the next reversal candle will be the signal). Either way, the next move is meaningful.
[/list]

In a High regime, treat strong signals as cautionary at best — the bars are coloured by ratio for a reason; the gradient will tell you when one side is dominating.

[b]Suggested settings[/b]

Defaults (length 20, stdev mult 2.0, ATR mult 1.5) are tuned to 1H–4H on liquid markets — the classical Bollinger settings plus a 1.5-ATR outer cushion. For 5m–15m, drop length to 14 and ATR multiplier to 1.0. For daily and above, raise length to 50 and ATR multiplier to 2.0. The regime thresholds (low 1.0×, high 2.0× of the long-run stdev average) are conservative — tighten the bands if your instrument is unusually quiet.

[b]Originality / what's reused[/b]

Bollinger Bands and ATR are public-domain primitives. The implementation — the outer-band = inner-band ± ATR construction, the channel-ratio bar gradient, the regime classifier with auto-tinted background, the exhaustion-arrow consecutive-bar run logic, the weak/strong signal tiering, and the dashboard's monospaced regime-aware layout — is JOAT-original and tuned together. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. Section-headed source, tooltips on every input, helper functions documented inline. The band engine, the regime classifier, the exhaustion logic, and the dashboard are independent modules — fork or extend any single one without reading the whole file.

[b]Limitations[/b]

Reversion bands are a counter-trend tool by construction. In sustained one-sided moves the outer band will be repeatedly touched without producing a profitable reversion — the High regime tint and the exhaustion-arrow run logic both exist to warn you when you are in this state. Signals are confirmed on bar close (non-repainting), so an intra-bar wick into the outer band that gets reabsorbed will not fire.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title             = "Volatility Reversion Bands Pro [JOAT]",
          shorttitle        = "VRB [JOAT]",
          overlay           = true,
          max_lines_count   = 500,
          max_labels_count  = 500,
          max_boxes_count   = 500,
          max_bars_back     = 5000)

// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================

grpBands   = "+======== Bands ========+"
grpSig     = "+======== Signals ========+"
grpVisuals = "+======== Visuals ========+"
grpRegime  = "+======== Volatility Regime ========+"
grpDash    = "+======== Dashboard ========+"
grpAlerts  = "+======== Alerts ========+"

// --- Bands ----------------------------------------------------------------
length     = input.int   (defval = 20,    title = "Lookback Length",          minval = 2,    maxval = 1000, group = grpBands, tooltip = "Bars used for SMA basis and rolling stdev. 20 is the textbook default.")
mult       = input.float (defval = 2.0,   title = "StDev Multiplier",         minval = 0.1,  maxval = 10.0, step = 0.1, group = grpBands, tooltip = "Width of the inner Bollinger envelope in standard deviations.")
atrMult    = input.float (defval = 1.5,   title = "ATR Multiplier (outer)",   minval = 0.1,  maxval = 10.0, step = 0.1, group = grpBands, tooltip = "Outer reversal band = inner band +/- ATR * this. Higher = fewer signals, deeper extremes.")
atrLen     = input.int   (defval = 0,     title = "ATR Length (0 = use Lookback)", minval = 0, maxval = 1000, group = grpBands, tooltip = "0 means reuse the main lookback period for ATR.")
useEma     = input.bool  (defval = false, title = "Use EMA basis instead of SMA", group = grpBands, tooltip = "When true the basis is an EMA - faster reaction in trending regimes.")

// --- Signals --------------------------------------------------------------
showStrong   = input.bool (defval = true,  title = "Show Strong Reversal Signals", group = grpSig)
showWeak     = input.bool (defval = true,  title = "Show Weak Signals (near bands)", group = grpSig)
weakUpperThr = input.float(defval = 0.90,  title = "Weak Upper Threshold", minval = 0.5, maxval = 0.99, step = 0.01, group = grpSig, tooltip = "Ratio at/above which a weak short hint fires.")
weakLowerThr = input.float(defval = 0.10,  title = "Weak Lower Threshold", minval = 0.01, maxval = 0.5, step = 0.01, group = grpSig, tooltip = "Ratio at/below which a weak long hint fires.")
sigCooldown  = input.int  (defval = 5,     title = "Signal Cooldown (bars)", minval = 0, maxval = 200, group = grpSig, tooltip = "Bars to suppress same-side signal repetition.")
showExhaust  = input.bool (defval = true,  title = "Show Exhaustion Arrows (>=3 consecutive)", group = grpSig)
exhaustMin   = input.int  (defval = 3,     title = "Exhaustion Minimum Run", minval = 2, maxval = 20, group = grpSig)

// --- Volatility regime ----------------------------------------------------
regimeLen    = input.int  (defval = 100, title = "Regime Lookback (bars)", minval = 10, maxval = 5000, group = grpRegime, tooltip = "Reference window for the rolling-average stdev used to classify regime.")
lowMult      = input.float(defval = 1.0, title = "Low Regime Threshold (x avg stdev)", minval = 0.1, maxval = 5.0, step = 0.05, group = grpRegime, tooltip = "stdev / avgStdev below this is classified Low.")
highMult     = input.float(defval = 2.0, title = "High Regime Threshold (x avg stdev)", minval = 0.5, maxval = 10.0, step = 0.05, group = grpRegime, tooltip = "stdev / avgStdev above this is classified High.")
showRegimeBg = input.bool (defval = true, title = "Background Tint by Regime", group = grpRegime)
bgIntensity  = input.int  (defval = 92, title = "Background Transparency (0-100)", minval = 70, maxval = 99, group = grpRegime)

// --- Visuals --------------------------------------------------------------
barGradient   = input.bool (defval = true,  title = "Color Bars (gradient by ratio)", group = grpVisuals)
fillBands     = input.bool (defval = true,  title = "Fill Between BB and Outer Bands", group = grpVisuals)
fillBandsAlpha= input.int  (defval = 88,    title = "Band Fill Transparency",  minval = 60, maxval = 99, group = grpVisuals)
showInnerBB   = input.bool (defval = true,  title = "Plot Inner BB Lines",  group = grpVisuals)
showBasis     = input.bool (defval = true,  title = "Plot Basis (mid)",      group = grpVisuals)
labelStyle    = input.string(defval = "Glyph", title = "Signal Label Style", options = ["Glyph","Text","Both"], group = grpVisuals)

// --- Dashboard ------------------------------------------------------------
showDash    = input.bool   (defval = true,         title = "Show Dashboard",   group = grpDash)
dashPosStr  = input.string (defval = "Top Right",  title = "Dashboard Position",
     options = ["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"], group = grpDash)
dashSizeStr = input.string (defval = "Normal",     title = "Dashboard Size",
     options = ["Tiny","Small","Normal","Large","Huge"], group = grpDash)
dashFrameTr = input.int    (defval = 65,           title = "Dashboard Frame Transparency", minval = 0, maxval = 95, group = grpDash)
dashShowLeg = input.bool   (defval = true,         title = "Show Legend Footer", group = grpDash)

// --- Alerts ---------------------------------------------------------------
alertStrong  = input.bool(defval = true, title = "Alert on Strong Long/Short",  group = grpAlerts)
alertWeak    = input.bool(defval = true, title = "Alert on Weak Long/Short",    group = grpAlerts)
alertRegime  = input.bool(defval = true, title = "Alert on Vol Regime Change",  group = grpAlerts)
alertExhaust = input.bool(defval = true, title = "Alert on Exhaustion Arrow",   group = grpAlerts)

// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Plasma - curated, no theme switcher)
// =============================================================================

const color C_BULL  = #FFEA00   // yellow
const color C_BEAR  = #FF0080   // magenta
const color C_MID   = #B700FF   // violet
const color C_BG    = #0A0014   // deep void
const color C_FRAME_BASE = #1A0930

// Auxiliary colors derived from the palette
color C_TEXT      = color.new(#FFFFFF, 0)
color C_TEXT_DIM  = color.new(#FFFFFF, 30)
color C_FRAME     = color.new(C_FRAME_BASE, dashFrameTr)
color C_HEADER_BG = color.new(C_FRAME_BASE, math.max(0, dashFrameTr - 25))
color C_LOW_TINT  = color.rgb(40, 90, 200, 100)   // overridden after regime classification
color C_HIGH_TINT = color.rgb(255, 130, 30, 100)

// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
// =============================================================================

// Linear two-color RGB gradient (KB 2.1)
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// Multi-stop gradient: ratio in 0..1, stops evenly spaced (KB 2.2)
f_gradient3(float _ratio, color _a, color _b, color _c) =>
    color outc = _a
    if _ratio <= 0.5
        outc := f_colorGradient(_ratio * 2.0, _a, _b)
    else
        outc := f_colorGradient((_ratio - 0.5) * 2.0, _b, _c)
    outc

f_clamp(float _x, float _lo, float _hi) => math.max(_lo, math.min(_x, _hi))

// String -> table position
f_strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// String -> text size
f_strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// Build a "#####" mask string of length n (used by f_fmt)
f_hashMask(int n) =>
    string s = ""
    for _i = 0 to math.max(0, n - 1)
        s += "#"
    s

// Format float to short string (auto-precision)
f_fmt(float v, int prec) =>
    na(v) ? "n/a" : str.tostring(v, "#." + f_hashMask(prec))

// Format percentage
f_pct(float v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "#.##") + "%"

// Build escalating arrow string ("^^^", "^^^^"...)  used for exhaustion glyph
// We use ASCII caret in code, render as triangles glyph in chart labels.
f_repeatGlyph(string ch, int n) =>
    out = ""
    for _i = 0 to math.max(0, n - 1)
        out += ch
    out

// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
// =============================================================================

// Resolve effective ATR length
effAtrLen = atrLen <= 0 ? length : atrLen

// Basis
basis = useEma ? ta.ema(close, length) : ta.sma(close, length)

// Inner Bollinger envelope
sd       = ta.stdev(close, length)
bbUpper  = basis + sd * mult
bbLower  = basis - sd * mult

// Outer ATR-extended reversal envelope
atrVal       = ta.atr(effAtrLen)
atrBand      = atrVal * atrMult
revUpper     = bbUpper + atrBand
revLower     = bbLower - atrBand

// Channel ratio (close position within outer band, 0..1)
denom        = math.max(revUpper - revLower, 1e-10)
ratioRaw     = (close - revLower) / denom
ratio        = f_clamp(ratioRaw, 0.0, 1.0)

// Volatility regime
avgSd        = ta.sma(sd, regimeLen)
regimeRatio  = avgSd > 0 ? sd / avgSd : 1.0
isLowVol     = regimeRatio <  lowMult
isHighVol    = regimeRatio >  highMult
isNormVol    = not isLowVol and not isHighVol
regimeName   = isLowVol ? "Low" : isHighVol ? "High" : "Normal"
regimeColor  = isLowVol ? color.new(#3FA0FF, 0) : isHighVol ? color.new(#FF8230, 0) : color.new(#888888, 0)

// Track regime change
var string lastRegime = "Normal"
regimeChanged = lastRegime != regimeName
if barstate.isconfirmed
    lastRegime := regimeName

// =============================================================================
//  SECTION 5 - STATE / TRACKING
// =============================================================================

// Consecutive-closes-outside-BB counters (positive=above upper, negative=below lower)
var int consecutiveAbove = 0
var int consecutiveBelow = 0
if close > bbUpper
    consecutiveAbove += 1
    consecutiveBelow := 0
else if close < bbLower
    consecutiveBelow += 1
    consecutiveAbove := 0
else
    consecutiveAbove := 0
    consecutiveBelow := 0

// Cooldown tracking
var int lastLongBar  = -10000
var int lastShortBar = -10000

// Last signal label (for dashboard)
var string lastSigLabel = "--"
var int    lastSigBar   = na

// Bars beyond inner band (sustained extension)
barsBeyondInner = consecutiveAbove > 0 ? consecutiveAbove : (consecutiveBelow > 0 ? -consecutiveBelow : 0)

// =============================================================================
//  SECTION 6 - SIGNAL ENGINE
// =============================================================================

// Strong reversal triggers
strongLongRaw  = ta.crossunder(close, revLower)
strongShortRaw = ta.crossover (close, revUpper)

// Weak (band-hugging) hints
weakLongRaw    = ratio <= weakLowerThr
weakShortRaw   = ratio >= weakUpperThr

// Apply cooldown
canLong  = (bar_index - lastLongBar)  >= sigCooldown
canShort = (bar_index - lastShortBar) >= sigCooldown

strongLong  = showStrong and strongLongRaw  and canLong
strongShort = showStrong and strongShortRaw and canShort

weakLong    = showWeak and weakLongRaw  and not strongLong  and canLong  and (consecutiveBelow == 0 or consecutiveBelow == 1)
weakShort   = showWeak and weakShortRaw and not strongShort and canShort and (consecutiveAbove == 0 or consecutiveAbove == 1)

// Exhaustion arrows: emit when consecutive run hits exhaustMin and grows by 1
exhaustUp   = showExhaust and consecutiveAbove >= exhaustMin and ta.change(consecutiveAbove) == 1
exhaustDown = showExhaust and consecutiveBelow >= exhaustMin and ta.change(consecutiveBelow) == 1

// Update cooldown anchors
if strongLong or weakLong
    lastLongBar  := bar_index
if strongShort or weakShort
    lastShortBar := bar_index

// Track last signal for dashboard
if strongLong
    lastSigLabel := "Strong LONG"
    lastSigBar   := bar_index
else if strongShort
    lastSigLabel := "Strong SHORT"
    lastSigBar   := bar_index
else if weakLong
    lastSigLabel := "Weak Long"
    lastSigBar   := bar_index
else if weakShort
    lastSigLabel := "Weak Short"
    lastSigBar   := bar_index
else if exhaustUp
    lastSigLabel := "Exhaustion Up"
    lastSigBar   := bar_index
else if exhaustDown
    lastSigLabel := "Exhaustion Down"
    lastSigBar   := bar_index

// =============================================================================
//  SECTION 7 - PLOTS / FILLS / CANDLES
// =============================================================================

// Outer reversal bands
pRevUpper = plot(revUpper, title = "Reversal Upper", color = color.new(C_BEAR, 0), linewidth = 2)
pRevLower = plot(revLower, title = "Reversal Lower", color = color.new(C_BULL, 0), linewidth = 2)

// Inner BB
pBBUpper  = plot(showInnerBB ? bbUpper : na, title = "BB Upper", color = color.new(C_BEAR, 35), linewidth = 1, style = plot.style_linebr)
pBBLower  = plot(showInnerBB ? bbLower : na, title = "BB Lower", color = color.new(C_BULL, 35), linewidth = 1, style = plot.style_linebr)

// Basis line (slope-colored against itself)
basisSlope     = nz(basis - basis[1], 0.0)
basisSlopeAbs  = ta.ema(math.abs(basisSlope), math.max(2, length))
basisRatio     = basisSlopeAbs > 0 ? f_clamp(0.5 + basisSlope / (2.0 * basisSlopeAbs), 0.0, 1.0) : 0.5
basisColor     = f_colorGradient(basisRatio, C_BEAR, C_BULL)
plot(showBasis ? basis : na, title = "Basis", color = basisColor, linewidth = 2)

// Fills between outer and inner bands (only when both are plotted)
fillUpperColor = color.new(C_BEAR, fillBandsAlpha)
fillLowerColor = color.new(C_BULL, fillBandsAlpha)
fill(pRevUpper, pBBUpper, color = fillBands and showInnerBB ? fillUpperColor : na, title = "Upper Reversal Zone")
fill(pRevLower, pBBLower, color = fillBands and showInnerBB ? fillLowerColor : na, title = "Lower Reversal Zone")

// Bar gradient color: Plasma yellow (low/bull side) -> violet (high/mid side)
// Re-anchored from cyan->purple to Plasma palette bull->mid for visual consistency.
barCol = f_colorGradient(ratio, C_BULL, C_MID)
barcolor(barGradient ? barCol : na, title = "Reversion Heat Bars")

// Background tint by vol regime
bgRegimeCol = isLowVol ? color.new(#3FA0FF, bgIntensity) : isHighVol ? color.new(#FF8230, bgIntensity) : na
bgcolor(showRegimeBg ? bgRegimeCol : na, title = "Vol Regime Tint")

// =============================================================================
//  SECTION 8 - SIGNAL LABEL DRAWINGS
// =============================================================================

// Glyph helpers
strongUpGlyph   = labelStyle == "Glyph" ? "UP+"   : labelStyle == "Text" ? "Strong LONG"  : "UP+ Strong LONG"
strongDownGlyph = labelStyle == "Glyph" ? "DN+"   : labelStyle == "Text" ? "Strong SHORT" : "DN+ Strong SHORT"
weakUpGlyph     = labelStyle == "Glyph" ? "UP"    : labelStyle == "Text" ? "Weak Long"    : "UP Weak Long"
weakDownGlyph   = labelStyle == "Glyph" ? "DN"    : labelStyle == "Text" ? "Weak Short"   : "DN Weak Short"

if strongLong
    label.new(bar_index, low, text = strongUpGlyph,
         style     = label.style_label_up,
         color     = color.new(C_BULL, 0),
         textcolor = color.new(#000000, 0),
         size      = size.small)

if strongShort
    label.new(bar_index, high, text = strongDownGlyph,
         style     = label.style_label_down,
         color     = color.new(C_BEAR, 0),
         textcolor = color.new(#FFFFFF, 0),
         size      = size.small)

if weakLong
    label.new(bar_index, low, text = weakUpGlyph,
         style     = label.style_label_up,
         color     = color.new(C_BULL, 60),
         textcolor = color.new(#FFFFFF, 0),
         size      = size.tiny)

if weakShort
    label.new(bar_index, high, text = weakDownGlyph,
         style     = label.style_label_down,
         color     = color.new(C_BEAR, 60),
         textcolor = color.new(#FFFFFF, 0),
         size      = size.tiny)

// Exhaustion arrows: emit a label whose glyph escalates with the run length
if exhaustUp
    glyphUp = f_repeatGlyph("^", math.min(consecutiveAbove, 7))
    label.new(bar_index, high, text = glyphUp + " x" + str.tostring(consecutiveAbove),
         style     = label.style_label_down,
         color     = color.new(C_BEAR, 25),
         textcolor = color.new(#FFFFFF, 0),
         size      = size.small,
         yloc      = yloc.abovebar,
         tooltip   = "Bull-side exhaustion: " + str.tostring(consecutiveAbove) + " consecutive closes above the upper Bollinger band. Reversion risk rising.")

if exhaustDown
    glyphDn = f_repeatGlyph("v", math.min(consecutiveBelow, 7))
    label.new(bar_index, low,  text = glyphDn + " x" + str.tostring(consecutiveBelow),
         style     = label.style_label_up,
         color     = color.new(C_BULL, 25),
         textcolor = color.new(#000000, 0),
         size      = size.small,
         yloc      = yloc.belowbar,
         tooltip   = "Bear-side exhaustion: " + str.tostring(consecutiveBelow) + " consecutive closes below the lower Bollinger band. Reversion risk rising.")

// =============================================================================
//  SECTION 9 - DASHBOARD
// =============================================================================

dashPos  = f_strToPos(dashPosStr)
dashSize = f_strToSize(dashSizeStr)

// Header bg color depends on regime so user gets a status-at-a-glance
color hdrBg = isHighVol ? color.new(#FF8230, 60) : isLowVol ? color.new(#3FA0FF, 60) : color.new(C_MID, 70)

// Position-in-channel cell color: gradient bull -> mid -> bear
color posCellCol = color.new(f_gradient3(ratio, C_BULL, C_MID, C_BEAR), 70)

// Last-signal cell color
color sigCellCol = lastSigLabel == "Strong LONG" ? color.new(C_BULL, 50) : lastSigLabel == "Strong SHORT" ? color.new(C_BEAR, 50) : lastSigLabel == "Weak Long" ? color.new(C_BULL, 70) : lastSigLabel == "Weak Short" ? color.new(C_BEAR, 70) : lastSigLabel == "Exhaustion Up" ? color.new(C_BEAR, 60) : lastSigLabel == "Exhaustion Down" ? color.new(C_BULL, 60) : color.new(C_BG, 60)

// Sustain cell color
color sustainCol = consecutiveAbove >= 3 ? color.new(C_BEAR, 60) : consecutiveBelow >= 3 ? color.new(C_BULL, 60) : color.new(C_BG, 60)

// Build table
var table dash = table.new(position.top_right, 2, 8,
     bgcolor      = na,
     frame_color  = C_FRAME,
     frame_width  = 1,
     border_color = color.new(C_FRAME, 50),
     border_width = 1)

// Re-create only on first bar to honor user's position selection
if barstate.isfirst
    dash := table.new(dashPos, 2, dashShowLeg ? 8 : 7,
         bgcolor      = na,
         frame_color  = C_FRAME,
         frame_width  = 1,
         border_color = color.new(C_FRAME, 50),
         border_width = 1)

if showDash and barstate.islast
    // Header
    table.cell(dash, 0, 0, "VOLATILITY REVERSION", text_color = C_TEXT, bgcolor = hdrBg,
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 0, "VRBP",                 text_color = C_TEXT, bgcolor = hdrBg,
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 1 - Position in channel
    posPctTxt = str.tostring(ratio * 100.0, "#.#") + "%"
    table.cell(dash, 0, 1, "Channel Position",     text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 80),
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 1, posPctTxt,              text_color = C_TEXT,     bgcolor = posCellCol,
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 2 - Volatility regime
    regimeTxt = regimeName + " (" + str.tostring(regimeRatio, "#.##") + "x)"
    table.cell(dash, 0, 2, "Vol Regime",           text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 80),
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 2, regimeTxt,              text_color = C_TEXT,     bgcolor = color.new(regimeColor, 50),
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 3 - Bars beyond inner band (sustained extension)
    sustainSign = consecutiveAbove > 0 ? "+" : (consecutiveBelow > 0 ? "-" : "")
    sustainAbs  = math.max(consecutiveAbove, consecutiveBelow)
    sustainTxt  = sustainAbs == 0 ? "0 (in BB)" : sustainSign + str.tostring(sustainAbs)
    table.cell(dash, 0, 3, "Bars Beyond Inner",    text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 80),
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 3, sustainTxt,             text_color = C_TEXT,     bgcolor = sustainCol,
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 4 - Last Signal
    sigBarsAgoTxt = na(lastSigBar) ? "--" : (str.tostring(bar_index - lastSigBar) + "b")
    table.cell(dash, 0, 4, "Last Signal",          text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 80),
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 4, lastSigLabel + " | " + sigBarsAgoTxt,
         text_color = C_TEXT, bgcolor = sigCellCol,
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 5 - Mid / Basis price (operational reference)
    midTxt = f_fmt(basis, 4)
    table.cell(dash, 0, 5, "Basis (" + (useEma ? "EMA" : "SMA") + " " + str.tostring(length) + ")",
         text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 80),
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 5, midTxt,
         text_color = C_TEXT,    bgcolor = color.new(basisColor, 65),
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 6 - Width metrics (BB width + ATR band width)
    bbWidth = bbUpper - bbLower
    extWidth = revUpper - revLower
    widthTxt = f_fmt(bbWidth, 4) + " / " + f_fmt(extWidth, 4)
    table.cell(dash, 0, 6, "BB / Outer Width",    text_color = C_TEXT_DIM, bgcolor = color.new(C_BG, 80),
         text_size = dashSize, text_halign = text.align_left,  text_font_family = font.family_monospace)
    table.cell(dash, 1, 6, widthTxt,              text_color = C_TEXT,     bgcolor = color.new(C_BG, 60),
         text_size = dashSize, text_halign = text.align_right, text_font_family = font.family_monospace)

    // Row 7 - Optional legend footer
    if dashShowLeg
        legendTxt = "UP+ DN+ strong  |  UP DN weak  |  ^^^ vvv exhaust"
        table.cell(dash, 0, 7, legendTxt,             text_color = C_TEXT_DIM,
             bgcolor = color.new(C_BG, 75), text_size = size.tiny, text_halign = text.align_left,
             text_font_family = font.family_monospace)
        table.cell(dash, 1, 7, "v1.0",                text_color = C_TEXT_DIM,
             bgcolor = color.new(C_BG, 75), text_size = size.tiny, text_halign = text.align_right,
             text_font_family = font.family_monospace)

// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================

alertcondition(alertStrong  and strongLong,
     title   = "VRBP - Strong Long",
     message = "VRBP [JOAT] STRONG LONG: close crossed under outer reversal band. Sym={{ticker}} TF={{interval}} Px={{close}}")

alertcondition(alertStrong  and strongShort,
     title   = "VRBP - Strong Short",
     message = "VRBP [JOAT] STRONG SHORT: close crossed over outer reversal band. Sym={{ticker}} TF={{interval}} Px={{close}}")

alertcondition(alertWeak    and weakLong,
     title   = "VRBP - Weak Long",
     message = "VRBP [JOAT] WEAK LONG: ratio at/below lower threshold. Sym={{ticker}} TF={{interval}} Px={{close}}")

alertcondition(alertWeak    and weakShort,
     title   = "VRBP - Weak Short",
     message = "VRBP [JOAT] WEAK SHORT: ratio at/above upper threshold. Sym={{ticker}} TF={{interval}} Px={{close}}")

alertcondition(alertRegime  and regimeChanged,
     title   = "VRBP - Vol Regime Change",
     message = "VRBP [JOAT] vol regime changed. Sym={{ticker}} TF={{interval}} Px={{close}}")

alertcondition(alertExhaust and exhaustUp,
     title   = "VRBP - Bull Exhaustion",
     message = "VRBP [JOAT] BULL EXHAUSTION: consecutive closes above upper BB. Sym={{ticker}} TF={{interval}} Px={{close}}")

alertcondition(alertExhaust and exhaustDown,
     title   = "VRBP - Bear Exhaustion",
     message = "VRBP [JOAT] BEAR EXHAUSTION: consecutive closes below lower BB. Sym={{ticker}} TF={{interval}} Px={{close}}")

// =============================================================================
//  END OF FILE
// =============================================================================
````
