# MACD Divergence Engine

- url: https://www.tradingview.com/script/AK9Hx9Zm-MACD-Divergence-Engine/
- type: indicator
- pine_id: PUB;67f7a99c93f64c4da62009c61cd7f7fa
- version: 1.0

## Description

════════════════════════════════════════════════════

[b]OVERVIEW[/b]

MACD Divergence Engine is a rebuild of the classic MACD divergence
detector, redesigned around one question the original never asks:
is this divergence actually worth anything?

A raw divergence is a low-information event. Every oscillator prints
dozens of them, most in conditions where the pattern has no business
working. This engine finds the same structures, then grades each one
from 0 to 100 across ten independent factors and only draws the ones
that clear your threshold. Every signal is labelled with its grade
(A+ / A / B / C / D) and its numeric score, so you can see exactly
how much the model liked it rather than treating all signals alike.

Built on Pine v6. Runs in its own pane with a single zero centre line
as the reference axis.

════════════════════════════════════════════════════

[b]WHAT IT DOES DIFFERENTLY[/b]

1 — VOLATILITY NORMALIZATION

Raw MACD is measured in price units. A reading of 0.8 means something
completely different on an index future, on EURUSD, and on a $3
small-cap. That is why fixed MACD thresholds never transfer between
instruments.

Here the oscillator is divided by ATR, by its own standard deviation,
or by percent-of-price (your choice). Every internal threshold is then
expressed in volatility units, so the zero line, the exhaustion bands
and all ten score components mean the same thing on every symbol and
every timeframe without re-tuning. Raw mode is available if you want
the classic scale back.

2 — MULTI-PIVOT SCAN

Conventional divergence scripts compare the current swing to exactly
one prior swing. Real divergences frequently form against the second
or third pivot back, and those get missed entirely.

This build maintains a rolling ledger of recent pivots, evaluates every
legal pairing inside your bar-gap window, scores each one, and emits
the single strongest. Scan depth is adjustable from 1 to 8.

3 — THE CONFLUENCE MODEL

Each divergence candidate is scored across ten orthogonal factors:

  · MAGNITUDE — how far apart the price swing and the momentum swing
    genuinely are, in ATR and oscillator sigma. Combined as a geometric
    mean so a near-flat price leg cannot be rescued by a large
    oscillator leg. A 0.1-ATR "divergence" scores near zero.

  · EXTREMITY — how stretched the oscillator was at the pivot.
    Reversals want an extreme reading; continuations want a shallow
    pullback that never reached exhaustion, so this factor inverts
    between the two classes.

  · SPACING — pivots too close together are the same swing counted
    twice; too far apart and market structure has changed between them.

  · REGIME FIT — see the next section. Highest-value single filter.

  · EXTENSION — distance from the structural moving average, signed
    toward the intended trade, in ATR.

  · VOLUME — regular divergence wants falling volume on the second
    push, which is what exhaustion looks like. Hidden divergence wants
    rising volume. Neutral on symbols without volume data.

  · HIGHER-TIMEFRAME BIAS — momentum direction on a higher timeframe,
    auto-selected from your chart timeframe or set manually.

  · MOMENTUM SHIFT — is the histogram already turning at the
    confirmation bar, and is the MACD line on the right side of signal.

  · ZERO-LINE INTEGRITY — see below.

  · BAR STRUCTURE — RSI positioning at the pivot plus the rejection
    wick as a proportion of that bar's range.

All ten weights are exposed as inputs. Set any of them to 0 to remove
that factor entirely. The model is auditable, not a black box you have
to take on faith — you can see and change exactly what it rewards.

4 — REGIME AWARENESS

Regular and hidden divergences are opposite trades and fail in opposite
conditions. Regular divergence is mean-reversion and gets destroyed in
strong trends. Hidden divergence is continuation and gets destroyed in
chop. Firing both blindly guarantees you take the wrong one half the
time.

Trend strength is measured by blending Kaufman's Efficiency Ratio (how
straight the path is) with ADX (directional conviction) — two different
questions, deliberately averaged. Direction comes from DMI confirmed by
a structural moving average; when those two disagree the regime is
classified as TRANSITION, which is itself useful information.

The model then scores each divergence class against that measured
regime. Notably, a regular divergence WITH the prevailing trend — a
pullback low that held while momentum improved — is treated as the
highest-quality version of the pattern, while the same structure
against a strong trend is scaled down as the falling-knife trade it is.

5 — GENERALISED ZERO-LINE DISCIPLINE

The classic rule says a bullish divergence should form entirely below
zero. This build extends that: in Strict mode the whole oscillator
segment between both pivots must stay on the correct side of the zero
line, not just the two endpoints. The rule is also correctly inverted
for hidden divergences, which legitimately live on the opposite side of
zero from regular ones. Soft mode checks only the pivot values, and Off
removes the constraint.

════════════════════════════════════════════════════

THE ZERO CENTRE LINE

The pane carries one zero line, drawn as a first-class object rather
than a background hairline, because every threshold in the model is
anchored to it. Above zero is momentum expansion, below is contraction.
It can optionally take its colour from the current regime, giving you
the market state at a glance without reading any numbers. Line width is
adjustable.

════════════════════════════════════════════════════

[b]READING THE OUTPUT[/b]

  · Solid line between two pivots — regular divergence
  · Dashed line — hidden divergence
  · Label — direction, grade, and score out of 100
  · Dotted line on the price chart — the same divergence mirrored onto
    price, so you can see both legs of the structure at once
  · Shaded band — adaptive exhaustion envelope at ±N sigma
  · Histogram — four-state colouring for expansion and fade above and
    below zero

Grades: A+ is 85 and above, A is 75+, B is 65+, C is 55+, D below that.

════════════════════════════════════════════════════

[b]SETTINGS GUIDE[/b]

Start with defaults. Minimum Score is 60, which is roughly a B grade.

  · Want fewer, higher-conviction signals — raise Minimum Score to 75
    or 85. Expect a large drop in signal count. This is the main dial.
  · Trading continuation setups — enable Hidden divergences.
  · Too few signals on a choppy instrument — set Zero-Line Discipline
    to Soft, or reduce Pivot Left/Right.
  · Divergences forming against older swings are being missed — raise
    Prior Pivots Scanned.
  · Instrument has no meaningful volume (many FX feeds) — set the
    Volume Confirmation weight to 0 rather than leaving it neutral.
  · Want the classic MACD scale back — set Normalization to Raw.

Oscillator MA type is selectable: EMA, SMA, WMA, HMA, DEMA, TEMA,
ZLEMA and KAMA. KAMA adapts its smoothing to the efficiency ratio,
which reduces whipsaw in chop. ZLEMA and TEMA cut lag at the cost of
overshoot.

════════════════════════════════════════════════════

[b]ALERTS[/b]

Five alert conditions are provided: regular bullish, regular bearish,
hidden bullish, hidden bearish, and an A+ grade filter that fires only
on scores of 85 or above.

A structured JSON alert is also emitted on every signal, carrying the
symbol, timeframe, signal type, grade, numeric score, regime state,
higher-timeframe bias, price and ATR — suitable for routing to a
webhook.

════════════════════════════════════════════════════

[b]REPAINTING[/b]

Signals do not repaint. Pivot confirmation requires the configured
number of bars to the right of the pivot, so a divergence is only
detected after those bars have printed and its position never moves
afterwards. The trade-off is inherent to all pivot-based detection:
the signal is by definition late by that many bars. That is disclosed
rather than hidden.

"Evaluate on bar close only" is enabled by default and prevents the
live-bar score components from flickering intrabar.

════════════════════════════════════════════════════

[b]CREDITS[/b]

Based on "MACD Divergences" by @DaviddTech, whose script established
the pivot-comparison structure and the zero-line rule this build starts
from. The divergence detection has been rewritten around a multi-pivot
ledger, and the normalization layer, confluence scoring model, regime
engine and drawing system are new work.

Open source. Use it, read it, change it.

════════════════════════════════════════════════════

[b]DISCLAIMER[/b]

This is an analysis tool, not financial advice and not a trading
system. It identifies and grades a chart pattern; it does not tell you
what to buy or sell, and it does not include position sizing, risk
management or exits. A high score means the model's criteria were met,
not that the trade will work. Divergence is a pattern that fails
regularly, and it fails most often exactly where it is most tempting —
against a strong trend.

No indicator predicts the future. Past behaviour of any pattern does
not guarantee future results. Test anything on your own instruments and
timeframes before risking capital, and size positions on the assumption
that any individual signal can be wrong.

════════════════════════════════════════════════════

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
//  MACD DIVERGENCE ENGINE — INSTITUTIONAL BUILD
//  Rebuilt from "MACD Divergences by @DaviddTech" (Pine v4)
//
//  DESIGN NOTES (why this differs from a retail divergence script)
//  ------------------------------------------------------------------------
//  1. NORMALIZATION. Raw MACD is in price units, so a divergence of "0.8" means
//     something completely different on ES than on EURUSD or a $3 small-cap.
//     Every internal threshold here is expressed in volatility units (ATR /
//     std-dev), which makes the zero line and every score component portable
//     across symbols and timeframes without re-tuning.
//
//  2. MULTI-PIVOT SCAN. The original compares the current pivot to exactly one
//     prior pivot via valuewhen(). Real divergences frequently form against the
//     2nd or 3rd prior swing. We keep a rolling pivot ledger and score every
//     legal pairing, then emit the strongest.
//
//  3. CONFLUENCE MODEL ("black box"). A raw divergence is a low-information
//     event. Each candidate is graded 0-100 across ten orthogonal factors
//     (magnitude, extremity, spacing, regime, extension, volume, HTF bias,
//     momentum shift, zero-line integrity, bar structure). Weights are exposed
//     so the model is auditable rather than genuinely opaque.
//
//  4. REGIME AWARENESS. Regular divergences are mean-reversion trades and die
//     in strong trends; hidden divergences are continuation trades and die in
//     chop. The model scores each class against the measured regime instead of
//     firing both blindly.
//
//  5. NON-REPAINTING BY CONSTRUCTION. Pivots confirm lbR bars after the fact and
//     never move. Live-bar scoring inputs are gated behind "Evaluate on close".
// ═══════════════════════════════════════════════════════════════════════════════

indicator("MACD Divergence Engine [Institutional]", "MDE", overlay = false,
     max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

// ═══════════════════════════════════════════════════════════════════════════════
//  GROUPS
// ═══════════════════════════════════════════════════════════════════════════════
G_CORE = "① CORE OSCILLATOR"
G_NORM = "② NORMALIZATION & REGIME"
G_DIV  = "③ DIVERGENCE ENGINE"
G_SCR  = "④ CONFLUENCE MODEL"
G_VIS  = "⑤ VISUALS"

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — CORE
// ═══════════════════════════════════════════════════════════════════════════════
fastLen = input.int(12, "Fast", minval = 2, group = G_CORE, inline = "L")
slowLen = input.int(26, "Slow", minval = 3, group = G_CORE, inline = "L")
sigLen  = input.int(9,  "Signal", minval = 1, maxval = 50, group = G_CORE, inline = "L")
src     = input.source(close, "Source", group = G_CORE)
maType  = input.string("EMA", "Oscillator MA", group = G_CORE,
     options = ["EMA", "SMA", "WMA", "HMA", "DEMA", "TEMA", "ZLEMA", "KAMA"],
     tooltip = "KAMA adapts its smoothing to the efficiency ratio — less whipsaw in chop, " +
               "faster in trend. ZLEMA/TEMA reduce lag at the cost of overshoot.")
sigType = input.string("EMA", "Signal MA", group = G_CORE,
     options = ["EMA", "SMA", "WMA", "HMA", "DEMA", "TEMA", "ZLEMA", "KAMA"])

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — NORMALIZATION & REGIME
// ═══════════════════════════════════════════════════════════════════════════════
normMode = input.string("ATR (Volatility Units)", "Normalization", group = G_NORM,
     options = ["Raw (Classic)", "ATR (Volatility Units)", "Std-Dev (Z-Score)", "% of Price"],
     tooltip = "Raw reproduces the classic MACD scale. Everything else rescales the " +
               "oscillator so thresholds, bands and the zero line mean the same thing " +
               "on every symbol and timeframe.")
normLen   = input.int(50, "Normalization Lookback", minval = 5, group = G_NORM)
erLen     = input.int(20, "Efficiency Ratio Length", minval = 2, group = G_NORM)
adxLen    = input.int(14, "DI Length", minval = 2, group = G_NORM, inline = "ADX")
adxSmooth = input.int(14, "ADX Smoothing", minval = 1, group = G_NORM, inline = "ADX")
trendLen  = input.int(200, "Structural Trend MA", minval = 10, group = G_NORM)
htfEnable = input.bool(true, "Higher-Timeframe Bias Filter", group = G_NORM)
htfInput  = input.timeframe("", "HTF (blank = auto)", group = G_NORM)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — DIVERGENCE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
lbL         = input.int(5, "Pivot Left", minval = 1, group = G_DIV, inline = "P")
lbR         = input.int(5, "Pivot Right", minval = 1, group = G_DIV, inline = "P")
rangeLower  = input.int(5,  "Min Pivot Gap", minval = 1, group = G_DIV, inline = "R")
rangeUpper  = input.int(60, "Max Pivot Gap", minval = 5, group = G_DIV, inline = "R")
scanDepth   = input.int(3, "Prior Pivots Scanned", minval = 1, maxval = 8, group = G_DIV,
     tooltip = "The original script only ever compares against the single most recent " +
               "pivot. Scanning 2-4 back catches divergences that form against an " +
               "earlier swing — common at major turning points.")
showRegular = input.bool(true,  "Regular (reversal)", group = G_DIV, inline = "T")
showHidden  = input.bool(false, "Hidden (continuation)", group = G_DIV, inline = "T")
zeroMode    = input.string("Strict", "Zero-Line Discipline", group = G_DIV,
     options = ["Off", "Soft", "Strict"],
     tooltip = "Strict: the entire oscillator segment between both pivots must stay on " +
               "the correct side of zero (the original 'don't touch zero' rule, " +
               "generalised). Soft: only the two pivot values must. Off: no constraint.")
confirmClose = input.bool(true, "Evaluate on bar close only", group = G_DIV,
     tooltip = "Keeps live-bar score components from flickering intrabar.")

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — CONFLUENCE MODEL
// ═══════════════════════════════════════════════════════════════════════════════
minScore = input.int(60, "Minimum Score to Emit", minval = 0, maxval = 100, group = G_SCR,
     tooltip = "60 ≈ B grade. Raise to 75+ for A-grade only — far fewer signals.")
wMag = input.float(2.0, "Divergence Magnitude", minval = 0, maxval = 10, step = 0.5, group = G_SCR,
     tooltip = "How far apart the price swing and the momentum swing actually are, " +
               "measured in ATR and oscillator sigma. A 0.1-ATR 'divergence' is noise.")
wExt = input.float(1.5, "Oscillator Extremity", minval = 0, maxval = 10, step = 0.5, group = G_SCR)
wSpc = input.float(1.0, "Pivot Spacing Quality", minval = 0, maxval = 10, step = 0.5, group = G_SCR)
wReg = input.float(2.0, "Regime Fit", minval = 0, maxval = 10, step = 0.5, group = G_SCR,
     tooltip = "Penalises regular divergences inside strong trends and hidden " +
               "divergences inside chop. This is the single highest-value filter.")
wExn = input.float(1.5, "Price Extension from Mean", minval = 0, maxval = 10, step = 0.5, group = G_SCR)
wVol = input.float(1.0, "Volume Confirmation", minval = 0, maxval = 10, step = 0.5, group = G_SCR,
     tooltip = "Regular divergence wants FALLING volume on the second push (exhaustion). " +
               "Hidden wants rising volume (continuation). Neutral if no volume data.")
wHtf = input.float(1.5, "HTF Bias Alignment", minval = 0, maxval = 10, step = 0.5, group = G_SCR)
wMom = input.float(1.5, "Momentum Shift Confirm", minval = 0, maxval = 10, step = 0.5, group = G_SCR)
wZro = input.float(2.0, "Zero-Line Integrity", minval = 0, maxval = 10, step = 0.5, group = G_SCR)
wStr = input.float(1.0, "Bar Structure / RSI", minval = 0, maxval = 10, step = 0.5, group = G_SCR)

// ═══════════════════════════════════════════════════════════════════════════════
//  INPUTS — VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
mirrorPrice = input.bool(true, "Mirror divergence lines on price chart", group = G_VIS)
showBands   = input.bool(true, "Adaptive Exhaustion Bands", group = G_VIS, inline = "B")
bandMult    = input.float(2.0, "σ", minval = 0.5, step = 0.25, group = G_VIS, inline = "B")
showGlow    = input.bool(true, "Line glow", group = G_VIS)
zeroDynamic = input.bool(true, "Colour zero line by regime", group = G_VIS)
zeroWidth   = input.int(2, "Zero line width", minval = 1, maxval = 4, group = G_VIS)
maxDraw     = input.int(40, "Max drawings retained", minval = 5, maxval = 200, group = G_VIS)

cMacd    = input.color(#4D8FFF, "MACD", group = G_VIS, inline = "C1")
cSignal  = input.color(#FFAA33, "Signal", group = G_VIS, inline = "C1")
cZero    = input.color(#8892A6, "Zero", group = G_VIS, inline = "C1")
cGrowUp  = input.color(#00E5B4, "Hist ▲ grow", group = G_VIS, inline = "C2")
cFallUp  = input.color(#0E7C68, "fade", group = G_VIS, inline = "C2")
cGrowDn  = input.color(#7A2038, "Hist ▼ fade", group = G_VIS, inline = "C3")
cFallDn  = input.color(#FF3B69, "grow", group = G_VIS, inline = "C3")
cBull    = input.color(#00E5B4, "Bull", group = G_VIS, inline = "C4")
cBear    = input.color(#FF3B69, "Bear", group = G_VIS, inline = "C4")
cHBull   = input.color(#2DD4BF, "H-Bull", group = G_VIS, inline = "C5")
cHBear   = input.color(#FB7185, "H-Bear", group = G_VIS, inline = "C5")

// ═══════════════════════════════════════════════════════════════════════════════
//  PURE HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
f_clamp(float v, float lo, float hi) =>
    na(v) ? lo : math.max(lo, math.min(hi, v))

// Kaufman Adaptive MA — smoothing constant driven by the efficiency ratio.
f_kama(series float s, simple int len) =>
    float chg = math.abs(s - s[len])
    float vol = math.sum(math.abs(s - s[1]), len)
    float er  = vol > 0 ? chg / vol : 0.0
    float sc  = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2)
    var float k = na
    k := na(k[1]) ? s : k[1] + sc * (s - k[1])
    k

// All branches are computed unconditionally: ta.* functions must run every bar
// to hold consistent internal state, even when their result is discarded.
f_ma(series float s, simple int len, simple string t) =>
    float _sma  = ta.sma(s, len)
    float _ema  = ta.ema(s, len)
    float _wma  = ta.wma(s, len)
    float _hma  = ta.hma(s, len)
    float _e1   = _ema
    float _e2   = ta.ema(_e1, len)
    float _e3   = ta.ema(_e2, len)
    float _dema = 2 * _e1 - _e2
    float _tema = 3 * (_e1 - _e2) + _e3
    int   _lag  = int(math.floor((len - 1) / 2))
    float _zl   = ta.ema(s + s - s[_lag], len)
    float _kama = f_kama(s, len)
    switch t
        "SMA"   => _sma
        "EMA"   => _ema
        "WMA"   => _wma
        "HMA"   => _hma
        "DEMA"  => _dema
        "TEMA"  => _tema
        "ZLEMA" => _zl
        "KAMA"  => _kama
        =>         _ema

// Extreme value of a series across a bar-offset window [newerOff .. olderOff].
f_segExtreme(series float s, int newerOff, int olderOff, bool wantMax) =>
    float r = na
    if newerOff <= olderOff
        for k = newerOff to olderOff
            float v = s[k]
            if not na(v)
                r := na(r) ? v : (wantMax ? math.max(r, v) : math.min(r, v))
    r

f_grade(float s) =>
    s >= 85 ? "A+" : s >= 75 ? "A" : s >= 65 ? "B" : s >= 55 ? "C" : "D"

f_htfAuto() =>
    string r = timeframe.period
    if timeframe.isseconds
        r := "15"
    else if timeframe.isminutes
        int m = timeframe.multiplier
        r := m <= 5 ? "60" : m <= 15 ? "240" : m <= 60 ? "D" : "W"
    else if timeframe.isdaily
        r := "W"
    else if timeframe.isweekly
        r := "M"
    else
        r := "12M"
    r

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 1 — OSCILLATOR CONSTRUCTION
// ═══════════════════════════════════════════════════════════════════════════════
float fastMA  = f_ma(src, fastLen, maType)
float slowMA  = f_ma(src, slowLen, maType)
float macdRaw = fastMA - slowMA

float nATR = ta.atr(normLen)
float nSTD = ta.stdev(macdRaw, normLen)
float nPCT = src / 100.0
float scale = switch normMode
    "ATR (Volatility Units)" => nATR
    "Std-Dev (Z-Score)"      => nSTD
    "% of Price"             => nPCT
    =>                          1.0
scale := (na(scale) or scale <= 0) ? 1.0 : scale

float oscN  = macdRaw / scale
float sigN  = f_ma(oscN, sigLen, sigType)
float histN = oscN - sigN

// Reference dispersion of the oscillator — used to express "how extreme is this
// pivot" in sigma rather than in arbitrary units.
float oscScale = math.max(nz(ta.stdev(oscN, normLen * 2)), 1e-10)

// Adaptive exhaustion envelope
float bandSD = ta.stdev(oscN, normLen)
float bandUp = bandSD * bandMult
float bandDn = -bandSD * bandMult

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 2 — REGIME ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
float atrVal = ta.atr(14)
float erChg  = math.abs(close - close[erLen])
float erVol  = math.sum(math.abs(close - close[1]), erLen)
float er     = erVol > 0 ? erChg / erVol : 0.0
[diP, diM, adxVal] = ta.dmi(adxLen, adxSmooth)
float basis  = ta.ema(close, trendLen)
float rsiVal = ta.rsi(close, 14)
// Hoisted to global scope: ta.* calls carry per-bar series state and cannot be
// evaluated inside the pivot-scan loop. We index the precomputed series instead.
float volSma = ta.sma(volume, 3)

// Trend power: efficiency ratio (path straightness) blended with ADX (directional
// conviction). Two different questions, deliberately averaged.
float trendPower = f_clamp(er * 0.5 + f_clamp(adxVal / 45.0, 0, 1) * 0.5, 0, 1)
// Direction is taken from DMI (responsive) confirmed by the structural MA (slow).
// Disagreement between the two is itself information — it marks transition.
bool  diBull     = diP > diM
bool  aboveBasis = close > basis
bool  dirUp      = diBull and aboveBasis
bool  dirDn      = not diBull and not aboveBasis
bool  conflicted = not dirUp and not dirDn

string regimeTxt = conflicted        ? "TRANSITION"                                       :
                   trendPower > 0.60 ? (dirUp ? "TREND ▲ STRONG" : "TREND ▼ STRONG")      :
                   trendPower > 0.35 ? (dirUp ? "TREND ▲ WEAK"   : "TREND ▼ WEAK")        :
                                         "RANGE / CHOP"
color regimeCol = conflicted        ? #FFD166 :
                  trendPower > 0.60 ? (dirUp ? #00E5B4 : #FF3B69) :
                  trendPower > 0.35 ? (dirUp ? #7BE38F : #FB7185) : #8892A6

// Higher-timeframe momentum bias
f_htfBias() =>
    float f = ta.ema(close, fastLen)
    float s = ta.ema(close, slowLen)
    float m = f - s
    float g = ta.ema(m, sigLen)
    int b = m > g and m > 0 ? 1 : m < g and m < 0 ? -1 : 0
    b

string htfRes = htfInput == "" ? f_htfAuto() : htfInput
int htfBias = htfEnable ? int(nz(request.security(syminfo.tickerid, htfRes, f_htfBias(),
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off))) : 0

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 3 — CONFLUENCE MODEL
//  Ten factors, each normalised to 0..1, weighted, expressed as 0..100.
// ═══════════════════════════════════════════════════════════════════════════════
f_conf(bool isBull, bool isHidden, float cO, float pO, float cP, float pP,
       int cOff, int pOff, float zeroScore) =>
    int   gap  = pOff - cOff
    float atrC = math.max(nz(atrVal[cOff]), syminfo.mintick)

    // 1 ── MAGNITUDE. Both legs must be materially large; geometric mean so a
    //      near-zero price leg cannot be rescued by a large oscillator leg.
    float pMove = math.abs(cP - pP) / atrC
    float oMove = math.abs(cO - pO) / oscScale
    float sMag  = math.sqrt(f_clamp(pMove / 2.0, 0, 1) * f_clamp(oMove / 1.0, 0, 1))

    // 2 ── EXTREMITY. Reversals want a stretched oscillator; continuations want a
    //      shallow pullback that never reached exhaustion.
    float extr  = f_clamp(math.abs(cO) / (oscScale * 1.5), 0, 1)
    float sExt  = isHidden ? f_clamp(1.0 - extr / 1.2, 0, 1) : extr

    // 3 ── SPACING. Pivots too close are the same swing; too far and the market
    //      has structurally changed between them.
    float ideal = math.max((rangeLower + rangeUpper) / 2.0, 1.0)
    float sSpc  = f_clamp(1.0 - math.abs(gap - ideal) / ideal, 0, 1)

    // 4 ── REGIME FIT. The dominant filter.
    //  · Hidden div is a continuation trade: it needs the trend behind it, and is
    //    close to worthless against it.
    //  · Regular div WITH the trend is a pullback that held — the highest-quality
    //    version of the pattern. Regular div AGAINST the trend is the classic
    //    counter-trend reversal: acceptable in chop, a falling knife in a strong
    //    trend, so it scales inversely with measured trend power.
    bool withTrend = isBull ? dirUp : dirDn
    bool vsTrend   = isBull ? dirDn : dirUp
    float sReg = isHidden ? (withTrend ? f_clamp(trendPower * 1.2, 0, 1)
                           : vsTrend   ? 0.05
                           :             trendPower * 0.40)
                          : (withTrend ? 0.85
                           : vsTrend   ? f_clamp(1.0 - trendPower, 0, 1) * 0.85
                           :             0.60)

    // 5 ── EXTENSION. Distance from the structural mean, signed toward the trade.
    float dev   = (nz(close[cOff]) - nz(basis[cOff])) / atrC
    float dirDev = isBull ? -dev : dev            // >0 = stretched in our favour
    float sExn  = isHidden ? f_clamp((-dirDev + 1.0) / 3.0, 0, 1)
                           : f_clamp(dirDev / 3.0, 0, 1)

    // 6 ── VOLUME. Exhaustion vs. participation.
    float vNow  = nz(volSma[cOff])
    float vPrv  = nz(volSma[pOff])
    float sVol  = 0.5
    if vPrv > 0 and vNow > 0
        float ratio = vNow / vPrv
        sVol := isHidden ? f_clamp((ratio - 0.6) / 0.8, 0, 1)
                         : f_clamp((1.4 - ratio) / 0.8, 0, 1)

    // 7 ── HTF ALIGNMENT. Both classes want the higher timeframe pointing the
    //      same way as the intended trade.
    float sHtf = not htfEnable ? 0.5 :
         isBull ? (htfBias > 0 ? 1.0 : htfBias == 0 ? 0.5 : 0.1)
                 : (htfBias < 0 ? 1.0 : htfBias == 0 ? 0.5 : 0.1)

    // 8 ── MOMENTUM SHIFT. Is the oscillator already turning at confirmation?
    bool histTurn = isBull ? (histN > histN[1] and histN[1] <= histN[2])
                           : (histN < histN[1] and histN[1] >= histN[2])
    bool lineOk   = isBull ? oscN > sigN : oscN < sigN
    float sMom = (histTurn ? 0.6 : 0.0) + (lineOk ? 0.4 : 0.0)

    // 9 ── ZERO-LINE INTEGRITY (precomputed by caller).
    float sZro = zeroScore

    // 10 ─ STRUCTURE. RSI positioning plus rejection-wick proportion at the pivot.
    float r    = nz(rsiVal[cOff], 50)
    float sRsi = isBull ? f_clamp((45 - r) / 20.0, 0, 1) : f_clamp((r - 55) / 20.0, 0, 1)
    float rng  = math.max(nz(high[cOff]) - nz(low[cOff]), syminfo.mintick)
    float wick = isBull ? (math.min(nz(open[cOff]), nz(close[cOff])) - nz(low[cOff])) / rng
                         : (nz(high[cOff]) - math.max(nz(open[cOff]), nz(close[cOff]))) / rng
    float sStr = sRsi * 0.6 + f_clamp(wick / 0.5, 0, 1) * 0.4

    float wSum = wMag + wExt + wSpc + wReg + wExn + wVol + wHtf + wMom + wZro + wStr
    float total = wSum <= 0 ? 0.0 :
         (sMag * wMag + sExt * wExt + sSpc * wSpc + sReg * wReg + sExn * wExn +
          sVol * wVol + sHtf * wHtf + sMom * wMom + sZro * wZro + sStr * wStr) / wSum * 100.0
    f_clamp(total, 0, 100)

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 4 — PIVOT LEDGER
// ═══════════════════════════════════════════════════════════════════════════════
var array<float> phO = array.new<float>(0)
var array<float> phP = array.new<float>(0)
var array<int>   phB = array.new<int>(0)
var array<float> plO = array.new<float>(0)
var array<float> plP = array.new<float>(0)
var array<int>   plB = array.new<int>(0)
int STORE = 12

f_push(array<float> ao, array<float> ap, array<int> ab, float o, float p, int b) =>
    array.unshift(ao, o)
    array.unshift(ap, p)
    array.unshift(ab, b)
    if array.size(ao) > STORE
        array.pop(ao)
        array.pop(ap)
        array.pop(ab)

// Drawing registry — bounded so long histories never blow the object limit.
var array<line>  regLines  = array.new<line>(0)
var array<label> regLabels = array.new<label>(0)

f_emit(bool isBull, bool isHidden, int pB, float pO, float pP, int cB, float cO, float cP, float sc) =>
    color c = isBull ? (isHidden ? cHBull : cBull) : (isHidden ? cHBear : cBear)
    string tag = (isBull ? "▲ " : "▼ ") + (isHidden ? "H-" : "") + (isBull ? "BULL" : "BEAR")
    line l = line.new(pB, pO, cB, cO, xloc = xloc.bar_index, color = c, width = 2,
         style = isHidden ? line.style_dashed : line.style_solid)
    label lb = label.new(cB, cO, tag + "  " + f_grade(sc) + "  " + str.tostring(sc, "#"),
         xloc = xloc.bar_index, yloc = yloc.price,
         style = isBull ? label.style_label_up : label.style_label_down,
         color = color.new(c, 12), textcolor = #0B0E14, size = size.small)
    array.push(regLines, l)
    array.push(regLabels, lb)
    if mirrorPrice
        line lm = line.new(pB, pP, cB, cP, xloc = xloc.bar_index, color = color.new(c, 25),
             width = 1, style = line.style_dotted, force_overlay = true)
        array.push(regLines, lm)
    while array.size(regLines) > maxDraw * 2
        line.delete(array.shift(regLines))
    while array.size(regLabels) > maxDraw
        label.delete(array.shift(regLabels))
    true

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 5 — DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
float phVal = ta.pivothigh(oscN, lbL, lbR)
float plVal = ta.pivotlow(oscN, lbL, lbR)
bool  phFound = not na(phVal)
bool  plFound = not na(plVal)
int   minGap  = math.max(rangeLower, lbL + lbR)
bool  gateOk  = confirmClose ? barstate.isconfirmed : true

// Live signal flags (reset every bar; set below when a candidate clears the model)
bool  bullReg = false
bool  bullHid = false
bool  bearReg = false
bool  bearHid = false
float firedScore = 0.0

var string lastType = "—"

// ── BEARISH: pivot highs in the oscillator ────────────────────────────────────
if phFound
    float cO = oscN[lbR]
    float cP = high[lbR]
    int   cB = bar_index - lbR
    int   cOff = lbR
    float best = -1.0
    int   bestIdx = -1
    bool  bestHid = false
    int   n = math.min(array.size(phO), scanDepth)
    if n > 0 and gateOk
        for i = 0 to n - 1
            float pO = array.get(phO, i)
            float pP = array.get(phP, i)
            int   pB = array.get(phB, i)
            int   gap = cB - pB
            if gap >= minGap and gap <= rangeUpper
                int  pOff = bar_index - pB
                bool regular = cP > pP and cO < pO      // higher price high, lower momentum high
                bool hidden  = cP < pP and cO > pO      // lower price high, higher momentum high
                if (regular and showRegular) or (hidden and showHidden)
                    bool wantBelow = hidden
                    float segE = f_segExtreme(oscN, cOff, pOff, wantBelow)
                    bool pure = na(segE) ? false : (wantBelow ? segE < 0 : segE > 0)
                    bool ends = wantBelow ? (cO < 0 and pO < 0) : (cO > 0 and pO > 0)
                    bool zOk  = zeroMode == "Strict" ? pure : zeroMode == "Soft" ? ends : true
                    if zOk
                        float zS = pure ? 1.0 : ends ? 0.5 : 0.0
                        float sc = f_conf(false, hidden, cO, pO, cP, pP, cOff, pOff, zS)
                        if sc > best
                            best := sc
                            bestIdx := i
                            bestHid := hidden
    if bestIdx >= 0 and best >= minScore
        f_emit(false, bestHid, array.get(phB, bestIdx), array.get(phO, bestIdx),
             array.get(phP, bestIdx), cB, cO, cP, best)
        bearReg := not bestHid
        bearHid := bestHid
        firedScore := best
        lastType := (bestHid ? "HIDDEN BEAR" : "BEAR")
    f_push(phO, phP, phB, cO, cP, cB)

// ── BULLISH: pivot lows in the oscillator ─────────────────────────────────────
if plFound
    float cO = oscN[lbR]
    float cP = low[lbR]
    int   cB = bar_index - lbR
    int   cOff = lbR
    float best = -1.0
    int   bestIdx = -1
    bool  bestHid = false
    int   n = math.min(array.size(plO), scanDepth)
    if n > 0 and gateOk
        for i = 0 to n - 1
            float pO = array.get(plO, i)
            float pP = array.get(plP, i)
            int   pB = array.get(plB, i)
            int   gap = cB - pB
            if gap >= minGap and gap <= rangeUpper
                int  pOff = bar_index - pB
                bool regular = cP < pP and cO > pO      // lower price low, higher momentum low
                bool hidden  = cP > pP and cO < pO      // higher price low, lower momentum low
                if (regular and showRegular) or (hidden and showHidden)
                    bool wantBelow = not hidden
                    float segE = f_segExtreme(oscN, cOff, pOff, wantBelow)
                    bool pure = na(segE) ? false : (wantBelow ? segE < 0 : segE > 0)
                    bool ends = wantBelow ? (cO < 0 and pO < 0) : (cO > 0 and pO > 0)
                    bool zOk  = zeroMode == "Strict" ? pure : zeroMode == "Soft" ? ends : true
                    if zOk
                        float zS = pure ? 1.0 : ends ? 0.5 : 0.0
                        float sc = f_conf(true, hidden, cO, pO, cP, pP, cOff, pOff, zS)
                        if sc > best
                            best := sc
                            bestIdx := i
                            bestHid := hidden
    if bestIdx >= 0 and best >= minScore
        f_emit(true, bestHid, array.get(plB, bestIdx), array.get(plO, bestIdx),
             array.get(plP, bestIdx), cB, cO, cP, best)
        bullReg := not bestHid
        bullHid := bestHid
        firedScore := best
        lastType := (bestHid ? "HIDDEN BULL" : "BULL")
    f_push(plO, plP, plB, cO, cP, cB)

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 6 — RENDER
// ═══════════════════════════════════════════════════════════════════════════════
color histCol = histN >= 0 ? (histN > nz(histN[1]) ? cGrowUp : cFallUp)
                           : (histN > nz(histN[1]) ? cGrowDn : cFallDn)
plot(histN, "Histogram", style = plot.style_columns, color = color.new(histCol, 25))

pBandU = plot(showBands ? bandUp : na, "Exhaustion +σ", color = color.new(cZero, 65), style = plot.style_line)
pBandL = plot(showBands ? bandDn : na, "Exhaustion −σ", color = color.new(cZero, 65), style = plot.style_line)
fill(pBandU, pBandL, color = color.new(cZero, 96), title = "Band Fill")

// Glow: stacked translucent copies read as depth without extra objects on price.
plot(showGlow ? oscN : na, "MACD Glow 2", color = color.new(cMacd, 88), linewidth = 5)
plot(showGlow ? oscN : na, "MACD Glow 1", color = color.new(cMacd, 75), linewidth = 3)
pMacd = plot(oscN, "MACD", color = cMacd, linewidth = 2)
plot(sigN, "Signal", color = cSignal, linewidth = 2)

// ── THE ZERO CENTER LINE ─────────────────────────────────────────────────────
// Single reference axis. Above = expansion, below = contraction. Every threshold
// in the model is anchored to it, so it is drawn as a first-class object rather
// than a background hairline.
color zCol = zeroDynamic ? color.new(regimeCol, 20) : cZero
pZero = plot(0.0, "Zero Center Line", color = zCol, linewidth = zeroWidth)
fill(pMacd, pZero, color = color.new(oscN >= 0 ? cGrowUp : cFallDn, 90), title = "Momentum Flow")

bgcolor(bullReg or bullHid ? color.new(cBull, 90) : bearReg or bearHid ? color.new(cBear, 90) : na,
     title = "Signal Tint")

// ═══════════════════════════════════════════════════════════════════════════════
//  LAYER 7 — ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
bool anyBull = bullReg or bullHid
bool anyBear = bearReg or bearHid
bool aPlus   = (anyBull or anyBear) and firedScore >= 85

alertcondition(bullReg, "Regular Bullish Divergence", "MDE: Regular BULL divergence — {{ticker}} {{interval}}")
alertcondition(bearReg, "Regular Bearish Divergence", "MDE: Regular BEAR divergence — {{ticker}} {{interval}}")
alertcondition(bullHid, "Hidden Bullish Divergence",  "MDE: Hidden BULL divergence — {{ticker}} {{interval}}")
alertcondition(bearHid, "Hidden Bearish Divergence",  "MDE: Hidden BEAR divergence — {{ticker}} {{interval}}")
alertcondition(aPlus,   "A+ Grade Signal Only",       "MDE: A+ GRADE divergence — {{ticker}} {{interval}}")

if anyBull or anyBear
    alert('{"engine":"MDE","symbol":"' + syminfo.tickerid + '","tf":"' + timeframe.period +
         '","signal":"' + lastType + '","grade":"' + f_grade(firedScore) +
         '","score":' + str.tostring(firedScore, "#") +
         ',"regime":"' + regimeTxt + '","htf_bias":' + str.tostring(htfBias) +
         ',"price":' + str.tostring(close) + ',"atr":' + str.tostring(atrVal, "#.#####") + '}',
         alert.freq_once_per_bar_close)
````
