# Market Adaptive Trend [Interakktive]

- url: https://www.tradingview.com/script/SOZioJML-Market-Adaptive-Trend-Interakktive/
- type: indicator
- pine_id: PUB;2c0c6466f8a54eaba984519b03dff28f
- version: 1.0

## Description

Market Adaptive Trend (MAT) is a diagnostic trend tool that re-tunes its own responsiveness to the live volatility regime — and shows you, in plain English, why it tightened or loosened.

Most "adaptive" trend tools hide their adaptation behind math you cannot audit. MAT does the opposite: it adapts AND it narrates. Every adjustment it makes is shown on the chart, in words, so you can see the reasoning rather than trust a black box.

This is a market-state diagnostic tool, not a signal generator.

█ THE CORE IDEA

A fixed-length moving average has one flaw: it responds the same way in calm markets and violent ones. In a clean trend it lags; in a chop it whipsaws. MAT addresses this by letting the live volatility regime govern how responsive the trend line is — the link most adaptive tools never expose.

MAT continuously measures relative volatility: current ATR divided by its own longer-run average. A reading near 1.00 means volatility is at this market's own baseline; above means more volatile than usual; below means calmer. That single ratio classifies the market into one of three regimes, and each regime changes how the line behaves.

█ THE THREE REGIMES

RIDING (calm) — Volatility below baseline. The line loosens and leans toward its slower estimate, so it rides a clean trend without being shaken out by minor noise.

TIGHTENING (balanced) — Volatility near baseline. The line sits in a balanced blend — neither chasing nor lagging — typical of coiling, pre-expansion conditions.

GUARDED (volatile / stretched) — Volatility above baseline. The line damps its response and becomes slow to flip, and candles tint amber as a caution that conditions are stretched and a flip here is lower-confidence.

█ HOW THE LINE IS BUILT

MAT blends a fast and a slow estimate of price. The blend weight is not fixed — it shifts with the regime above, scaled by an Adaptation Strength input (0 = a fixed blend, 1 = full regime governance). The blended target then drives the visible line through an error-feedback step, so the line moves toward its target proportionally rather than snapping. The calculation uses only confirmed historical data, contains no lookahead, and does not repaint.

█ THE HUD

A compact on-chart panel reports, in plain language:
- Trend — UP / DOWN
- Regime — RIDING / TIGHTENING / GUARDED, with a plain-English volatility descriptor (very calm → below normal → near normal → slightly elevated → high)
- Responsiveness — LOW / MED / HIGH (how reactive the line currently is)
- Read — a one-line summary of the current state

No raw scores are presented as the message — the panel is meant to be read at a glance.

█ HOW TRADERS USE MAT

MAT is designed to provide context, not entries. Common uses:
- Reading whether the current environment favours riding (RIDING) or caution (GUARDED)
- Avoiding low-confidence flips when the regime is GUARDED and conditions are stretched
- Using the regime read as a filter alongside your own entry method
- Framing trend direction with an honest sense of how much to trust it right now

█ SETTINGS OVERVIEW

Adaptive Baseline
- Source, Fast estimate length, Slow estimate length
- Adaptation Strength (how strongly the regime governs responsiveness)

Regime Governor
- Volatility baseline length, ATR length
- Calm threshold (below = RIDING), Volatile threshold (above = GUARDED)

Visual
- Adaptive line, Gradient fill, Edge glow, Color candles, Line width

HUD
- Show HUD, Position, Size

█ DISCLAIMER

This indicator is a market context and diagnostic tool only. It does not generate trade signals, entries, or exits. Past behaviour does not guarantee future price action. Always combine with independent analysis and proper risk management.

## Source Code

````pine
// © Interakktive
// Market Adaptive Trend (MAT) [Interakktive]
// Free diagnostic indicator — a trend baseline that re-tunes its responsiveness
// to the live volatility regime and narrates why, in plain English.
// Diagnostic tool: it reveals how the trend is behaving, not where price "should" go.
// Own implementation. Shahzad Rulebook v7.5+ compliant.
//@version=6
indicator("Market Adaptive Trend [Interakktive]", overlay = true)

// ============================================================================
// INPUTS
// ============================================================================
g1 = "Adaptive Baseline"
src      = input.source(close, "Source", group = g1)
fastLen  = input.int(10, "Fast estimate length", minval = 2, maxval = 100, group = g1)
slowLen  = input.int(50, "Slow estimate length", minval = 5, maxval = 400, group = g1)
adaptAmt = input.float(0.7, "Adaptation strength", minval = 0.0, maxval = 1.0, step = 0.05, group = g1, tooltip = "How strongly the regime shifts responsiveness. 0 = fixed blend, 1 = full regime governance.")

g2 = "Regime Governor"
volLen   = input.int(50, "Volatility baseline length", minval = 2, group = g2, tooltip = "Relative volatility = ATR / SMA(ATR). Classifies RIDING / TIGHTENING / GUARDED.")
atrLen   = input.int(14, "ATR length", minval = 1, group = g2)
calmTh   = input.float(0.85, "Calm threshold (below = RIDING)", minval = 0.1, step = 0.05, group = g2)
hotTh    = input.float(1.30, "Volatile threshold (above = GUARDED)", minval = 0.5, step = 0.05, group = g2)

g3 = "Visual"
showLine = input.bool(true, "Show adaptive line", group = g3)
showFill = input.bool(true, "Gradient fill", group = g3)
showGlow = input.bool(true, "Edge glow", group = g3)
paintBar = input.bool(true, "Color candles", group = g3)
lineW    = input.int(3, "Line width", minval = 1, maxval = 6, group = g3)

g4 = "HUD"
showHUD  = input.bool(true, "Show HUD", group = g4)
hudPos   = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = g4)
hudSize  = input.string("normal", "Size", options = ["tiny","small","normal","large"], group = g4)

// Brand palette
cBull = #26A69A
cBear = #EF5350
cAmb  = #FFB300
cBg0  = #0A0E14
cBg1  = #121A24
cTxt  = #EAF0F7
cMut  = #8694A6

// ============================================================================
// GLOBAL-SCOPE ta.* (R46b)
// ============================================================================
fastEma = ta.ema(src, fastLen)
slowEma = ta.ema(src, slowLen)
atrVal  = ta.atr(atrLen)
atrBase = ta.sma(atrVal, volLen)

// Relative volatility (~1 = baseline)
relVol = atrVal / math.max(atrBase, syminfo.mintick)

// ============================================================================
// REGIME GOVERNOR — 0 RIDING (calm) · 1 TIGHTENING (mid) · 2 GUARDED (volatile)
// R71: no multi-line ternary — use if/else
// ============================================================================
int regime = 1
if relVol < calmTh
    regime := 0
else if relVol > hotTh
    regime := 2
else
    regime := 1

// Map regime -> responsiveness weight (how much fast estimate leads the blend).
// RIDING: loosen (lean slow, ride). TIGHTENING: balanced. GUARDED: damp (slow to flip).
float baseW = 0.5
float regW  = baseW
if regime == 0
    regW := 0.35
else if regime == 2
    regW := 0.20
else
    regW := 0.55

// Adaptation strength scales how far we move from a neutral 0.5 blend.
float w = 0.5 + (regW - 0.5) * adaptAmt

// ============================================================================
// ADAPTIVE BASELINE — online error-feedback blend (own method, no lookahead)
// var line value pulled toward weighted fast/slow target by an error term.
// ============================================================================
var float mat = na
target = w * fastEma + (1.0 - w) * slowEma
if na(mat)
    mat := target
else
    err = target - mat
    mat := mat + (0.15 + 0.25 * w) * err   // error-feedback step, regime-scaled

// ============================================================================
// TREND STATE
// ============================================================================
var int trend = 0
if mat > mat[1]
    trend := 1
else if mat < mat[1]
    trend := -1

color trendCol = trend == 1 ? cBull : trend == -1 ? cBear : cMut

// ============================================================================
// PLOTS — line, gradient fill, edge glow (built fresh)
// ============================================================================
pLine  = plot(showLine ? mat : na, "MAT", color = trendCol, linewidth = lineW)
pPrice = plot(close, "Price ref", display = display.none, editable = false)

upTop = close > mat ? close : mat
upBot = close > mat ? mat : close
fill(pPrice, pLine, upTop, upBot, showFill and close > mat ? color.new(cBull, 25) : na, showFill and close > mat ? color.new(cBull, 92) : na, title = "Bull fill")
dnTop = close < mat ? mat : close
dnBot = close < mat ? close : mat
fill(pPrice, pLine, dnTop, dnBot, showFill and close < mat ? color.new(cBear, 92) : na, showFill and close < mat ? color.new(cBear, 25) : na, title = "Bear fill")

glow = atrVal * 0.06
pGlowUp = plot(close - glow, display = display.none, editable = false)
pGlowDn = plot(close + glow, display = display.none, editable = false)
fill(pPrice, pGlowUp, showGlow and close > mat ? color.new(cBull, 50) : na, title = "Bull glow")
fill(pPrice, pGlowDn, showGlow and close < mat ? color.new(cBear, 50) : na, title = "Bear glow")

// Regime-aware candle tint: amber when GUARDED (exhaustion caution), else trend color
candleCol = regime == 2 ? cAmb : trendCol
barcolor(paintBar ? color.new(candleCol, 10) : na, title = "Trend candles")

// ============================================================================
// HUD — plain English, never raw scores (Narrative Engine rule)
// ============================================================================
// HUD position + size resolved at global scope (R71-safe if/else, no series-in-table.new)
string hudPosV = position.top_right
if hudPos == "Top Left"
    hudPosV := position.top_left
else if hudPos == "Bottom Right"
    hudPosV := position.bottom_right
else if hudPos == "Bottom Left"
    hudPosV := position.bottom_left

string hudSizeV = size.normal
if hudSize == "tiny"
    hudSizeV := size.tiny
else if hudSize == "small"
    hudSizeV := size.small
else if hudSize == "large"
    hudSizeV := size.large

regTxt   = regime == 0 ? "RIDING" : regime == 2 ? "GUARDED" : "TIGHTENING"
regCol   = regime == 0 ? cBull : regime == 2 ? cAmb : cTxt
respTxt  = w > 0.55 ? "HIGH" : w < 0.40 ? "LOW" : "MED"
trendTxt = trend == 1 ? "UP" : trend == -1 ? "DOWN" : "FLAT"

// Plain-English volatility descriptor (replaces the raw relVol number — Narrative Engine rule)
volTxt = "near normal"
if relVol < 0.70
    volTxt := "very calm"
else if relVol < 0.90
    volTxt := "below normal"
else if relVol <= 1.15
    volTxt := "near normal"
else if relVol <= 1.40
    volTxt := "slightly elevated"
else
    volTxt := "high"

stateLine = "Trend clean — riding"
if regime == 1
    stateLine := "Volatility coiling — line tightening"
else if regime == 2
    stateLine := "Stretched — guarding, slow to flip"

// Single-column glass strip. Each row is one cell: "Label   Value".
// Near-black translucent bg + hairline muted border = sleek glass-like, not a grid.
cGlass = color.new(#05080C, 18)
cHair  = color.new(#8694A6, 80)

var table hud = table.new(hudPosV, 1, 6, bgcolor = cGlass, frame_color = cHair, frame_width = 1, border_color = color.new(#000000, 100), border_width = 0)

if showHUD and barstate.islast
    ts = hudSizeV
    table.cell(hud, 0, 0, "Market Adaptive Trend [Interakktive]", text_color = cBull, text_halign = text.align_left, text_size = ts)
    table.cell(hud, 0, 1, "Trend  ·  " + trendTxt, text_color = trendCol, text_halign = text.align_left, text_size = ts)
    table.cell(hud, 0, 2, "Regime  ·  " + regTxt + " · " + volTxt, text_color = regCol, text_halign = text.align_left, text_size = ts)
    table.cell(hud, 0, 3, "Responsiveness  ·  " + respTxt, text_color = cTxt, text_halign = text.align_left, text_size = ts)
    table.cell(hud, 0, 4, stateLine, text_color = cTxt, text_halign = text.align_left, text_size = ts)
    table.cell(hud, 0, 5, "Diagnostic — not a signal", text_color = cMut, text_halign = text.align_left, text_size = ts)

// ============================================================================
// ALERTS
// ============================================================================
bullFlip = trend == 1 and trend[1] != 1
bearFlip = trend == -1 and trend[1] != -1
alertcondition(bullFlip, "MAT turned UP", "Market Adaptive Trend turned UP on {{ticker}}")
alertcondition(bearFlip, "MAT turned DOWN", "Market Adaptive Trend turned DOWN on {{ticker}}")
````
