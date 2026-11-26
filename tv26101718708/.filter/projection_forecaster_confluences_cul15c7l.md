# Projection Forecaster - Confluences

- url: https://www.tradingview.com/script/CuL15C7L-Projection-Forecaster-Confluences/
- type: indicator
- pine_id: PUB;ebf31ee8f76b4d21bba51f0d63daf0db
- version: 1.0

## Description

[b] Projection Forecaster - Confluences[/b]

What it is

Projection Forecaster reads five independent market factors, combines them into a single
directional **bias score** from −100 to +100, and then draws a forward-looking
**projection cone** on the chart. The cone shows the *direction* price is currently
leaning and — through its width — *how much confidence* that lean deserves. When the
market is ranging rather than trending, the tool switches to a distinct **orange
"sideways" state** instead of forcing a green/red read.

This is a **probabilistic context tool, not a prediction of the future and not a
buy/sell signal generator.** The cone is a visualization of present-bar conditions
projected forward under a simple drift-and-uncertainty model; it does not claim to know
where price will actually go.

---

### The idea

Most "direction" tools collapse everything into one oscillator, which double-counts the
same edge (e.g. three momentum inputs that all say the same thing). Projection Forecaster
instead deliberately samples **five different dimensions** of the market — trend, momentum,
higher-timeframe context, order flow, and mean-reversion pressure — so each factor adds
*new* information. Those are blended with user weights into one bias, and the bias is then
expressed as a geometric cone so the trader can read direction and conviction at a glance.

---

### The five factors and how each is calculated

Each factor is normalized to roughly the −1 … +1 range (−1 = fully bearish, +1 = fully
bullish) before weighting.

**1. Trend Slope** — the underlying tide.
Uses the EMA stack (EMA-20, EMA-50, EMA-200):
`+0.5 if EMA20 > EMA50 else −0.5`, plus `+0.5 if EMA50 > EMA200 else −0.5`.
Range −1 (fully stacked down) to +1 (fully stacked up).

**2. Momentum** — the push behind the move.
Combines RSI position and the MACD histogram:
`clamp( 0.7 × (RSI−50)/25 + 0.3 × (MACD_histogram / ATR) )`.
RSI is centered on 50; the MACD histogram is normalized by ATR so it scales across
instruments. `clamp` limits the result to −1 … +1.

**3. Higher-Timeframe Bias** — bigger-picture agreement.
Pulls the close and a 50-period EMA from a higher timeframe (4× the current intraday
timeframe; same timeframe on non-intraday charts) using `request.security` with
**lookahead disabled** to avoid future leak. Returns +1 if HTF close > HTF EMA, else −1.

**4. Volume Flow** — who is in control.
Builds a signed-volume series: `sign(close−open) × volume`, smoothed with a 14-period EMA,
then divided by 20-period average volume and clamped to −1 … +1. Positive = net buying
pressure, negative = net selling pressure.

**5. Mean-Reversion** — a deliberate contrarian counterweight.
Measures how stretched price is from the rolling VWAP:
`clamp( −(close − VWAP) / (2 × ATR) )`.
Note the negative sign: when price is far **above** VWAP this factor leans **down**
(over-extension pressure), and vice-versa. It is weighted lightly so it tempers, rather
than overrides, the trend.

**Volatility regime** (`ATR / SMA(ATR, 20)`) is **not** a directional vote. It is used only
to widen the cone when volatility is expanding.

---

### How the bias is combined

```
bias = ( wTrend·Trend + wMom·Momentum + wHTF·HTF + wFlow·Flow + wMR·MeanRev )
       / (wTrend + wMom + wHTF + wFlow + wMR)
```

Weights are user inputs (defaults 0.30 / 0.25 / 0.20 / 0.15 / 0.10) and are
**auto-normalized**, so any combination you choose still produces a bias in −1 … +1.
The result is smoothed with a short EMA (default length 3) to stop bar-to-bar flicker.
`bias × 100` is shown on the dashboard; `50 + bias × 50` is shown as an approximate
"% up" reading purely to make the lean human-readable.

---

### How the projection cone is drawn

The cone is anchored at the current bar's price and extends `Projection Length` bars into
the future (a fixed, user-set horizon — it is a drawn projection, not a forecast of actual
candles).

- **Center / drift line:** `driftPerBar = bias × DriftStrength × ATR`, accumulated over the
  projection length. Stronger, more one-sided bias → steeper center line. In a sideways
  market the drift is cut to 25 % so the line reads flat.
- **Cone width (uncertainty):** `halfWidth = ATR × WidthStrength × bars × (0.35 + (1 − |bias|) × volRegime)`.
  The key idea: width grows when conviction is **low** (`1 − |bias|`) and when volatility is
  expanding. **A confident read produces a narrow cone; an unsure read produces a wide one.**

So the cone's *slope* encodes direction and the cone's *spread* encodes how much to trust it.

---

### The sideways (orange) state

A trending model is misleading in a range, so the script detects ranging conditions two ways:
- **Weak bias:** `|bias|` inside the user "Neutral Dead-Zone", or
- **Low ADX:** standard 14-period ADX below the user threshold (default 20).

When either is true, the cone, center line, read-out, dashboard and an optional background
region all turn **orange** and the label reads "SIDEWAYS — ranging / no clear lean." This
keeps the tool honest in chop instead of painting a false green/red bias.

---

### What it draws on the chart

- The forward projection cone (toggle) and center drift line (toggle).
- A floating plain-English read at the cone tip, e.g. "▲ Leaning UP • Strong conviction (≈72% up)".
- A compact dashboard showing each of the five factors as a mini bar, plus overall bias,
  conviction and direction.
- An optional background tint for the sideways state.

---

### Alerts

Built-in alerts (both as classic `alertcondition` dropdown entries and rich `alert()`
messages that include symbol, timeframe, direction, conviction and the % read):
bias flips **UP** / **DOWN**, conviction turns **Strong+**, and market turns **Sideways**.
All alert logic evaluates on bar close (`alert.freq_once_per_bar_close`) to avoid intrabar
flicker.

---

### How to use it

- Treat the cone as **directional context**, not an entry trigger. Use it to bias your own
  setups: take longs more seriously when the cone is green and narrow; stand aside or expect
  rotation when it is orange.
- A **narrow** cone = factors agree (higher conviction). A **wide** cone = mixed signals or
  high volatility (lower conviction).
- Combine it with your existing levels, structure or strategy — it is designed to *inform* a
  decision, not make it for you.
- Tune the factor weights and the ADX threshold to suit the instrument and timeframe you trade.

---

### Repainting & calculation notes

- All factors are standard closed-bar calculations; higher-timeframe data uses
  `lookahead = barmerge.lookahead_off`, so no future information is used.
- The projection cone is drawn only on the most recent bar and is **recomputed live** as the
  current bar develops — this is expected behaviour for a forward projection and does **not**
  repaint historical bars (no past cones are stored or restated).
- Alerts fire on bar close.

---

### Originality

This script is my own original work. It is not a copy of an existing indicator. The
component techniques it uses (EMA stack, RSI, MACD, VWAP, ADX, ATR) are standard public
concepts; the original contribution is the **specific multi-factor blending into a single
normalized bias and its expression as a drift-and-uncertainty projection cone with an
explicit ADX-based sideways state.** No code from other authors is included.

---

### Disclaimer

This indicator is provided for **educational and informational purposes only**. It does not
constitute financial advice and makes **no guarantee of future results**. Markets involve
risk; past behaviour does not predict future outcomes. Always do your own analysis and manage
your risk. You are solely responsible for your trading decisions.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//   PROJECTION FORECASTER  —  Multi-Factor Bias + Projection Cone   (Pine v6)
//
//   "Which way is price leaning over the next few bars — and how sure are we?"
//
//   Blends 5 NON-REDUNDANT factors into one bias score (-100 … +100), then
//   draws a forward PROJECTION CONE:
//     • center line  = projected drift (momentum + trend slope)
//     • cone width   = uncertainty (ATR + conviction) → wider = less sure
//     • orange state = sideways/ranging market (low ADX or weak bias)
//
//   This is a PROBABILITY READ, not a prophecy. The cone says "lean + how
//   confident", honestly. No repaint of history. No lookahead. Closed-bar logic.
// ══════════════════════════════════════════════════════════════════════════════
indicator("Projection Forecaster",
     shorttitle       = "Projection Forecaster",
     overlay          = true,
     max_lines_count  = 100,
     max_labels_count = 50,
     max_boxes_count  = 50)

// ─────────────────────────────────  INPUTS  ──────────────────────────────────
gMain   = "Forecast"
projBars = input.int(12,  "Projection Length (bars)", minval = 3, maxval = 60, group = gMain,
           tooltip = "How many bars into the future the cone is drawn.")
deadZone = input.float(0.08, "Neutral Dead-Zone", minval = 0.0, maxval = 0.4, step = 0.01, group = gMain,
           tooltip = "Bias inside ±this is shown as NEUTRAL (no strong lean).")
smoothLen = input.int(3, "Bias Smoothing", minval = 1, maxval = 10, group = gMain,
           tooltip = "Smooths the bias score so the cone doesn't flicker bar-to-bar.")

gWts    = "Factor Weights (auto-normalized)"
wTrend  = input.float(0.30, "Trend Slope",       minval = 0, maxval = 1, step = 0.05, group = gWts)
wMom    = input.float(0.25, "Momentum",          minval = 0, maxval = 1, step = 0.05, group = gWts)
wHTF    = input.float(0.20, "Higher-TF Bias",    minval = 0, maxval = 1, step = 0.05, group = gWts)
wFlow   = input.float(0.15, "Volume Flow",       minval = 0, maxval = 1, step = 0.05, group = gWts)
wMR     = input.float(0.10, "Mean-Reversion",    minval = 0, maxval = 1, step = 0.05, group = gWts)

gCone   = "Cone Shape"
driftK  = input.float(0.45, "Drift Strength (ATR×/bar)", minval = 0.05, maxval = 2.0, step = 0.05, group = gCone,
           tooltip = "How far the projected center moves per bar, scaled by ATR and bias.")
widthK  = input.float(0.55, "Width Strength (ATR×)", minval = 0.1, maxval = 2.0, step = 0.05, group = gCone,
           tooltip = "Base width of the uncertainty cone, scaled by ATR.")

gVis    = "Visuals"
showCone   = input.bool(true,  "Show Projection Cone",     group = gVis)
showCenter = input.bool(true,  "Show Center Drift Line",   group = gVis)
showRead   = input.bool(true,  "Show Plain-English Read",  group = gVis)
showDash   = input.bool(true,  "Show Bias Dashboard",      group = gVis)
showBg     = input.bool(false, "Background Tint by Bias",  group = gVis)
colUp      = input.color(color.new(#26a69a, 0), "Up Color",   group = gVis)
colDn      = input.color(color.new(#ef5350, 0), "Down Color", group = gVis)
colSide    = input.color(color.new(#ff9800, 0), "Sideways (orange)", group = gVis)
showSideBg = input.bool(true,  "Sideways/Range Background", group = gVis)

gRange  = "Range Detection"
rangeOn   = input.bool(true, "Detect Sideways via ADX", group = gRange,
            tooltip = "When ADX is low, the market is ranging — shown as orange instead of green/red.")
adxThresh = input.int(20, "ADX Range Threshold", minval = 10, maxval = 40, group = gRange,
            tooltip = "ADX below this = sideways/chop. Higher = more readings count as 'ranging'.")

// ───────────────────────────────  HELPERS  ───────────────────────────────────
f_clamp(x) => math.max(-1.0, math.min(1.0, x))

// ─────────────────────────────  CORE SERIES  ─────────────────────────────────
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
rsi    = ta.rsi(close, 14)
atr    = ta.atr(14)
volMa  = ta.sma(volume, 20)
[macdLine, macdSig, macdHist] = ta.macd(close, 12, 26, 9)
vwap   = ta.vwap(hlc3)

// Higher-timeframe bias (4× current intraday TF, no lookahead)
htfTfStr = timeframe.isintraday ? str.tostring(timeframe.multiplier * 4) : timeframe.period
htfEma   = request.security(syminfo.tickerid, htfTfStr, ta.ema(close, 50), lookahead = barmerge.lookahead_off)
htfClose = request.security(syminfo.tickerid, htfTfStr, close,             lookahead = barmerge.lookahead_off)

// ──────────────────────────────  FACTORS  ────────────────────────────────────
// Each returns a directional score in roughly [-1, +1]. Independent reads, so
// they add information instead of double-counting the same edge.

// 1) Trend slope — EMA stack (the tide)
trendScore = (ema20 > ema50 ? 0.5 : -0.5) + (ema50 > ema200 ? 0.5 : -0.5)

// 2) Momentum — RSI position + MACD histogram (push behind the move)
momScore = f_clamp(0.7 * ((rsi - 50.0) / 25.0) + 0.3 * (macdHist / atr))

// 3) Higher-TF bias — bigger-picture agreement
htfScore = htfClose > htfEma ? 1.0 : -1.0

// 4) Volume flow — net buying vs selling pressure
barSign  = close > open ? 1.0 : close < open ? -1.0 : 0.0
flowScore = f_clamp(ta.ema(barSign * volume, 14) / (volMa + 1e-9))

// 5) Mean-reversion — overstretched vs VWAP pulls the OTHER way (contrarian)
mrScore  = f_clamp(-(close - vwap) / (2.0 * atr))

// Volatility regime — NOT directional. Used to widen the cone when vol expands.
volRegime = atr / (ta.sma(atr, 20) + 1e-9)   // ~1 = normal, >1 = expanding

// ────────────────────────────  COMBINE BIAS  ─────────────────────────────────
wSum   = wTrend + wMom + wHTF + wFlow + wMR
wSum  := wSum <= 0 ? 1.0 : wSum
biasRaw = (wTrend * trendScore + wMom * momScore + wHTF * htfScore
           + wFlow * flowScore + wMR * mrScore) / wSum
bias    = f_clamp(ta.ema(biasRaw, smoothLen))

absB       = math.abs(bias)
isNeutral  = absB < deadZone

// Sideways = weak bias OR a low-ADX ranging market. Either way: orange, not green/red.
[diPlus, diMinus, adx] = ta.dmi(14, 14)
isRanging  = rangeOn and adx < adxThresh
isSideways = isNeutral or isRanging

dirUp      = bias > 0 and not isSideways
dirDn      = bias < 0 and not isSideways
biasCol    = isSideways ? colSide : dirUp ? colUp : colDn

// Pseudo-probability of "up" for an honest, plain read (50% = no edge)
probUp     = math.round(50.0 + bias * 50.0)
convTxt    = isSideways ? "Range / chop" : absB < 0.30 ? "Low" :
             absB < 0.55 ? "Moderate" : absB < 0.75 ? "Strong" : "Very strong"
dirTxt     = isSideways ? "SIDEWAYS" : dirUp ? "UP" : "DOWN"

// ───────────────────────────  PROJECTION CONE  ───────────────────────────────
// Drift per bar scales with bias (direction + strength) and ATR.
// Half-width grows with bars, ATR, and UNCERTAINTY (1-|bias|) and vol regime,
// so a confident read gives a tight cone, an unsure one gives a wide cone.
driftPerBar = bias * driftK * atr * (isSideways ? 0.25 : 1.0)   // flatten in chop
uncertainty = (1.0 - absB) * volRegime
halfWidthEnd = atr * widthK * projBars * (0.35 + uncertainty)

centerEnd = close + driftPerBar * projBars
upperEnd  = centerEnd + halfWidthEnd
lowerEnd  = centerEnd - halfWidthEnd

var line   lnUp     = na
var line   lnLo     = na
var line   lnCenter = na
var linefill lf     = na
var label  lbRead   = na

if barstate.islast
    line.delete(lnUp)
    line.delete(lnLo)
    line.delete(lnCenter)
    linefill.delete(lf)
    label.delete(lbRead)
    x1 = bar_index
    x2 = bar_index + projBars
    fillCol = color.new(biasCol, 82)

    if showCone
        lnUp := line.new(x1, close, x2, upperEnd, xloc.bar_index, color = color.new(biasCol, 45), width = 1, style = line.style_dashed)
        lnLo := line.new(x1, close, x2, lowerEnd, xloc.bar_index, color = color.new(biasCol, 45), width = 1, style = line.style_dashed)
        lf   := linefill.new(lnUp, lnLo, fillCol)

    if showCenter
        lnCenter := line.new(x1, close, x2, centerEnd, xloc.bar_index, color = biasCol, width = 2)

    if showRead
        readTxt = isSideways
             ? "↔  SIDEWAYS  •  ranging / no clear lean  (≈" + str.tostring(probUp) + "% up)"
             : (dirUp ? "▲  Leaning UP" : "▼  Leaning DOWN") + "  •  " + convTxt
               + " conviction  (≈" + str.tostring(probUp) + "% up)"
        lbRead := label.new(x2, centerEnd, readTxt, xloc.bar_index,
             style = dirDn ? label.style_label_up : label.style_label_down,
             color = color.new(biasCol, 15), textcolor = color.white, size = size.normal)

// ──────────────────────────────  DASHBOARD  ──────────────────────────────────
// Mini score bar, e.g. "▰▰▰··" — filled blocks ≈ factor strength
f_bar(s) =>
    n = math.round(math.abs(s) * 5)
    str.repeat(s >= 0 ? "▰" : "▱", math.max(n, 0)) + str.repeat("·", 5 - n)

// Render one labelled factor row into the dashboard
f_row(tbl, r, lbl, sc) =>
    table.cell(tbl, 0, r, lbl, text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, r, f_bar(sc), text_color = sc >= 0 ? colUp : colDn, text_size = size.small)

var table t = na
if showDash and barstate.islast
    if na(t)
        t := table.new(position.top_right, 2, 8, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 40))
    table.cell(t, 0, 0, "FORECAST", text_color = color.white, bgcolor = color.new(biasCol, 10), text_size = size.normal)
    table.cell(t, 1, 0, dirTxt + "  " + str.tostring(probUp) + "%↑", text_color = color.white, bgcolor = color.new(biasCol, 10), text_size = size.normal)
    f_row(t, 1, "Trend",     trendScore)
    f_row(t, 2, "Momentum",  momScore)
    f_row(t, 3, "Higher-TF", htfScore)
    f_row(t, 4, "Flow",      flowScore)
    f_row(t, 5, "Mean-Rev",  mrScore)
    table.cell(t, 0, 6, "Conviction", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 6, convTxt, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 7, "Bias", text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(t, 1, 7, str.tostring(math.round(bias * 100)), text_color = biasCol, text_size = size.small)

// ──────────────────────────────  BACKDROP  ───────────────────────────────────
bgTint = showSideBg and isSideways ? color.new(colSide, 88) :
         showBg and not isSideways ? color.new(biasCol, 92) : na
bgcolor(bgTint)

// ───────────────────────────────  ALERTS  ────────────────────────────────────
gAlert    = "Alerts"
aFlip     = input.bool(true,  "Alert on bias flip (UP / DOWN)", group = gAlert)
aStrong   = input.bool(true,  "Alert when conviction turns Strong+", group = gAlert)
aNeutral  = input.bool(false, "Alert when market turns Sideways",    group = gAlert)

// State-change triggers (fire once, on the transition only)
flipUp     = dirUp and not dirUp[1]
flipDn     = dirDn and not dirDn[1]
strongNow  = absB >= 0.55 and not isSideways
enterStrong = strongNow and not strongNow[1]
goNeutral  = isSideways and not isSideways[1]

// Tag so the phone notification reads cleanly: "Forecaster [BTCUSD 15]: …"
tag = "Forecaster [" + syminfo.ticker + " " + timeframe.period + "]: "

// Static conditions → selectable in TradingView's "Create Alert" dropdown
alertcondition(flipUp,      "Bias flipped UP",        "Forecaster: bias flipped UP")
alertcondition(flipDn,      "Bias flipped DOWN",      "Forecaster: bias flipped DOWN")
alertcondition(enterStrong, "Conviction → Strong",    "Forecaster: conviction turned Strong+")
alertcondition(goNeutral,   "Turned Sideways",        "Forecaster: market turned sideways / ranging")

// Dynamic alerts → rich, live message (use "Any alert() function call" in TV)
if aFlip and flipUp
    alert(tag + "Bias flipped ▲ UP • " + convTxt + " • ≈" + str.tostring(probUp) + "% up", alert.freq_once_per_bar_close)
if aFlip and flipDn
    alert(tag + "Bias flipped ▼ DOWN • " + convTxt + " • ≈" + str.tostring(probUp) + "% up", alert.freq_once_per_bar_close)
if aStrong and enterStrong
    alert(tag + "Conviction → " + convTxt + " " + dirTxt + " • ≈" + str.tostring(probUp) + "% up", alert.freq_once_per_bar_close)
if aNeutral and goNeutral
    alert(tag + "Market turned ↔ SIDEWAYS / ranging • ≈" + str.tostring(probUp) + "% up", alert.freq_once_per_bar_close)
````
