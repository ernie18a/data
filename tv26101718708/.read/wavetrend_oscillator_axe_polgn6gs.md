# WaveTrend Oscillator [Axe]

- url: https://www.tradingview.com/script/POLGn6GS/
- type: indicator
- pine_id: PUB;4862c83f37cd45fcab78a430d8565199
- version: 1.0

## Description

## WaveTrend Oscillator [Axe]

**A clean, display-only momentum oscillator — built on the classic WaveTrend with Ehlers low-lag smoothing, an honest four-quadrant divergence engine, strong/weak turning-point tiers, and a multi-timeframe resonance dashboard. It shows you market structure; it does not tell you to buy or sell.**

---

### What it is

WaveTrend Oscillator [Axe] is a refined version of the well-known WaveTrend oscillator, rebuilt on Pine v6. It visualizes **momentum, trend accumulation, and divergence structure** so you can read the state of a market at a glance.

It is a **decision-support / display tool**, by design:

- ❌ No buy/sell arrows
- ❌ No alerts
- ❌ No "90% win-rate" claims

- ✅ Clean structure you can actually read
- ✅ Honest about which signals are reliable and which are not
- ✅ Every layer independently toggleable

You stay in full control of every decision. Think of it as a well-built gauge, not an autopilot.

---

### How it works (the idea, in plain terms)

1. **Price transform** — the math runs on `log(close)`, so a +5% move and a −5% move are treated symmetrically. This matters for crypto's wide range.
2. **Channel deviation** — it measures how far price has stretched from its own moving baseline, then normalizes that by the recent average stretch. The result is a smooth oscillator that swings around zero (roughly between −1 and +1).
3. **Ehlers SuperSmoother core** — instead of a plain EMA, the signal line is smoothed with John Ehlers' 2-pole SuperSmoother filter plus an improved EMA. This gives **less lag and cleaner turns** than a vanilla WaveTrend.
4. **The two lines** — the blue **Signal (sig)** line is the core momentum; the orange **MA** is a short average of it, used as the trigger reference.
5. **Turning points** — when the signal crosses its MA back from an extreme (with recent momentum confirming), the indicator marks a momentum **bottom** or **top**. These are *structural measurement points*, not trade signals.
6. **Divergence** — at each turning point, it compares the current momentum extreme and price extreme against the previous one to classify a divergence.

---

### What you see on the chart

| Layer | What it looks like | Meaning |
|---|---|---|
| **Signal (sig)** | Blue line | Core WaveTrend momentum |
| **MA** | Orange line | Smoothed signal — the trigger reference |
| **OB / OS levels** | Horizontal lines at ±0.65 (default) | Overbought / oversold thresholds |
| **OB / OS zones** | Green / orange fills | Highlight when momentum is in extreme territory |
| **Histogram** | Light-blue / orange area | `sig − ma`; blue when bullish, orange when bearish |
| **OB / OS strength columns** | Red columns above OB, green below OS | How deep momentum has pushed past the threshold |
| **Trend tint** | Subtle green / red pane background | Trend accumulation — deeper tint = stronger trend |
| **Turning dots** | Aqua (bottom) / fuchsia (top) dots | **Full dot = strong** turn (came from a genuine extreme); **faded dot = weak** turn (mid-range) |
| **Divergence lines** | Diagonal lines on the signal | Dashed = regular (reversal); solid = hidden (continuation, faded & off by default) |
| **Divergence labels** | `R↑ / R↓ / H↑ / H↓` tags | Quick read of the divergence type and direction |
| **OB / OS value labels** | Small flag with the sig reading | The exact momentum value when it pierced an extreme |
| **Price-pane zones** | Horizontal line + band on the price chart | A regular-divergence price level; band fades to dashed once price breaks it |
| **MTF dashboard** | Corner table + background highlight | Higher-timeframe momentum state at a glance (see below) |

---

### Divergences explained

A divergence is when **price and momentum disagree**. There are two families, and they mean **opposite** things — so reading them correctly matters.

**Encoding rule:**
- **Line style = type:** dashed = **regular** (reversal), solid = **hidden** (continuation)
- **Line color = direction:** green = bullish, red = bearish

| Label | Type | Pattern | What it suggests |
|---|---|---|---|
| **R↑** (green dashed) | Regular bullish | Price lower low + momentum higher low | Reversal **up** (potential bottom) |
| **R↓** (red dashed) | Regular bearish | Price higher high + momentum lower high | Reversal **down** (potential top) |
| **H↑** (green solid) | Hidden bullish | Price higher low + momentum lower low | Uptrend **continuation** |
| **H↓** (red solid) | Hidden bearish | Price lower high + momentum higher high | Downtrend **continuation** |

⚠️ **A green line is not always "buy a reversal."** A *dashed* green line (R↑) means a bottoming reversal; a *solid* green line (H↑) means follow the existing uptrend. Always read the line style.

**A note on reliability (and why hidden divergence is OFF by default):**
In testing across BTC and ETH on 15m, **regular** divergences were the more dependable structural signal, while **hidden** divergences added little. So this indicator foregrounds regular divergences and keeps hidden ones thin, faded, and **off by default**. You can switch them on, but treat them as low-confidence context — not a signal.

---

### Multi-timeframe (MTF) resonance dashboard

Markets look different on different timeframes, and the strongest reads happen when timeframes **agree**.

The corner dashboard shows the WaveTrend state of **two higher timeframes** alongside your current chart:

- **Auto mode (default):** the two higher timeframes are derived as ×4 and ×16 of your chart. On a 15m chart that's 1h and 4h; on a 3m chart that's 12m and 48m. Switch the chart timeframe and the dashboard adapts automatically.
- **Manual mode:** turn Auto off and pick any two timeframes you like (e.g. 30m and 6h).

Each row shows **Trend** (▲/▼), **Zone** (OB / OS / neutral), and the latest **Divergence** direction. When all three timeframes line up in the same direction, the pane background lights up and the header shows ⚡ — that's "resonance."

The higher-timeframe data is requested **non-repainting**: historical bars never redraw, so what you see on the past is what you would have seen live.

---

### Settings

**Core**
- Channel Length (n1) — `12`
- Average Length (n2) — `25`
- Signal Smoothing — `4`
- MA Period — `4`
- Overbought / Oversold — `±0.65`
- Source — `close`

*(Defaults were tuned on BTC 15m. The original WaveTrend [Krypt] values — 10 / 21 / ±0.75 — are still valid; feel free to retune for your own market and timeframe.)*

**Trend Strength** — toggle the background tint and its intensity.

**Divergence** — show/hide regular (on) and hidden (off) divergences; line width.

**Turning Points** — show dots; dot size; "Only Show Strong Turns" to hide mid-range turns; genuine-extreme lookback.

**OB/OS Columns** — show/hide, colors, transparency.

**Divergence Labels / OB-OS Value Labels** — toggle and size.

**Price Zones** — project regular-divergence levels onto the price pane; max per side, band width, transparency.

**MTF** — show the table; Auto vs manual HTFs; the two multiples or manual timeframes; table position/size; alignment highlight.

**Data Export** — off by default; adds hidden plots used only for offline verification.

---

### How to use it

1. **Read the background tint first.** Green = bullish momentum stacking; red = bearish; clear = no decisive trend (range/chop).
2. **Find structure with the dots and columns.** Aqua dots mark momentum bottoms, fuchsia dots mark tops. Full (strong) dots are the cleaner ones. Tall OB/OS columns mean momentum is deep into an extreme.
3. **Read divergences by label, then line style.** `R↑ / R↓` = reversal (fade the move); `H↑ / H↓` = continuation (follow the trend). Green = bullish bias, red = bearish.
4. **Cross-check with the price-pane zones.** A solid band = the level still holds (live support/resistance). A dashed line with no band = price broke through it.
5. **Confirm with the MTF dashboard.** A setup is strongest when your timeframe and the two higher ones agree (resonance highlight on). When they disagree, be cautious.
6. **Combine layers, and confirm with your own system.** The strongest reads happen when several layers line up — but this tool is *context*, not a trigger. Pair it with your own entries, key levels, volume, or risk rules.

**Timeframes:** primary **15m**; also works on 5m / 1h / 4h. Tuned with crypto (BTC / ETH) in mind, but applicable to any liquid market.

---

### Important notes

- This is a **display / decision-support** indicator. It does **not** generate trade signals or alerts, and it does **not** predict price.
- Historical bars do not repaint.
- Nothing here is financial advice. Trading involves substantial risk of loss. Past behavior of any indicator does not guarantee future results. You are solely responsible for your decisions.

---

### Credits & License

Forked from **"WaveTrend Oscillator [Krypt]"** (Pine v3) and rebuilt on Pine v6, adding: trend-strength tint, a foregrounded regular-divergence engine with de-emphasized hidden divergences, genuine-extreme strong/weak turning-point tiers, OB/OS strength columns, divergence labels (`H↑ / R↑ / H↓ / R↓`), OB/OS value labels, price-pane divergence zones, and a multi-timeframe resonance dashboard; defaults retuned for BTC 15m.

- Original WaveTrend concept — **LazyBear**
- SuperSmoother filter — **John F. Ehlers**
- Price-pane divergence-zone visual idiom — adapted from **"RSI Momentum Divergence Zones [ChartPrime]"**

Published in the same open spirit — please credit the original authors when reusing.

## Source Code

````pine
// @version=6
indicator(title="WaveTrend Oscillator [Axe]", shorttitle="WT_Axe", precision=3, max_lines_count=500, max_labels_count=500)

// ===== Helper Functions =====

dropn(src, n) =>
    na(src[n]) ? na : src

// 2-pole low-pass filter (less lag than EMA)
EhlersSuperSmoother(src, lower) =>
    a1     = math.exp(-math.pi * math.sqrt(2) / lower)
    coeff2 = 2 * a1 * math.cos(math.sqrt(2) * math.pi / lower)
    coeff3 = -math.pow(a1, 2)
    coeff1 = (1 - coeff2 - coeff3) / 2
    float filt = na
    filt := nz(coeff1 * (src + nz(src[1], src)) + coeff2 * filt[1] + coeff3 * nz(filt[2], filt[1]), src)
    filt

// Improved EMA — better sensitivity on first bars
xema(src, len) =>
    mult = 2.0 / (len + 1.0)
    float res = na
    res := mult * src + (1.0 - mult) * nz(res[1], src)
    res

EhlersEmaSmoother(sig, smoothK, smoothP) =>
    EhlersSuperSmoother(xema(sig, smoothK), smoothP)

// step: latches value when xs is true, holds previous otherwise
step(xs, vals) =>
    float res = na
    res := nz(xs ? vals : res[1], vals)
    res

// monotonic increase accumulator
casc(xs, start, cond) =>
    float res = na
    prevRes = nz(res[1])
    isReset = prevRes == 0
    val = (start and xs > xs[1] and isReset and cond) ? xs - xs[1] : (xs >= xs[1] and cond ? prevRes + xs - xs[1] : 0.0)
    res := math.abs(nz(val))
    res

// monotonic decrease accumulator
cdesc(xs, start, cond) =>
    float res = na
    prevRes = nz(res[1])
    isReset = prevRes == 0
    val = (start and xs < xs[1] and isReset and cond) ? xs[1] - xs : (xs <= xs[1] and cond ? prevRes + xs[1] - xs : 0.0)
    res := math.abs(nz(val))
    res

findhidden(price, allbottoms, alltops, bottomsteps, topsteps, backtrack) =>
    pricebottoms = step(allbottoms, ta.lowest(price, backtrack))
    pricetops    = step(alltops,    ta.highest(price, backtrack))
    hbull = math.sqrt(cdesc(bottomsteps, true, true) * casc(pricebottoms, true, true))
    hbear = math.sqrt(casc(topsteps, true, true)    * cdesc(pricetops,    true, true))
    [hbull / (1.0 + hbear), hbear / (1.0 + hbull)]

// ===== Types =====
// Price-pane horizontal zone drawn at a regular-divergence level.
// Two lines per zone: thin primary + thick translucent band.
type divZone
    line  primaryLine
    line  bgLine
    float level
    bool  isBull
    bool  isBroken = false

// ===== Inputs =====

n1        = input.int(12,    title="Channel Length",   minval=1)
n2        = input.int(25,    title="Average Length",   minval=1)
smoothing = input.int(4,     title="Signal Smoothing", minval=0)
maperiod  = input.int(4,     title="MA Period",        minval=1)
ob        = input.float(0.65,  title="Overbought Level", minval=0.0)
osLvl     = input.float(-0.65, title="Oversold Level",   maxval=0.0)
showhist  = input.bool(true, title="Histogram")
src       = input.source(close, title="Source")

// --- Trend Strength layer (background tint) ---
showTrend      = input.bool(true, title="Show Trend Strength (background)", group="Trend Strength")
trendIntensity = input.float(80,  title="Tint Intensity", minval=10, maxval=300, step=10, group="Trend Strength")

// --- Divergence layer ---
// Reliability note (BTC/ETH 15m 2022-2026 OOS): REGULAR divergence is the
// "true" reversal signal; HIDDEN divergence showed NEGATIVE forward-return lift
// (worse than the price base rate) and is OFF by default. See
// .planning/specs/wt-axe-l4-calibration/DESIGN-accuracy-upgrade.md.
showRegularDiv = input.bool(true,  title="Show Regular Divergence (dashed) — true reversal", group="Divergence")
showHiddenDiv  = input.bool(false, title="Show Hidden Divergence (solid) — low reliability",  group="Divergence", tooltip="Hidden divergence had NEGATIVE OOS predictive lift on BTC/ETH 15m — kept for completeness but OFF by default. Treat as low-confidence context, not a signal.")
divLineWidth   = input.int(2,      title="Line Width",  minval=1, maxval=5,  group="Divergence")

// --- Turning Points layer ---
// Genuine-Extreme gate: a turn is "strong" only if sig actually reached the
// OB/OS band within the last `genExtLookback` bars. Mid-range turns (sig never
// hit the extreme) had ~0 / negative forward lift OOS — they are de-emphasized.
showTurnPoints      = input.bool(true, title="Show WT Bottom/Top Markers", group="Turning Points")
turnDotSize         = input.int(2,     title="Dot Size", minval=1, maxval=5, group="Turning Points")
showOnlyStrongTurns = input.bool(false, title="Only Show Strong Turns (genuine extreme)", group="Turning Points", tooltip="Hide mid-range turns where sig never reached OB/OS. Strong turns had +1.5pp OOS hit-rate and removed the negative-lift mid-range noise.")
genExtLookback      = input.int(5,     title="Genuine-Extreme Lookback (bars)", minval=1, maxval=20, group="Turning Points", tooltip="A turn is 'strong' if sig hit the OB/OS band within this many bars before it. 3/5/8 tested equivalent.")

// --- OB/OS Strength Columns layer ---
showObColumns  = input.bool(true,  title="Show OB Columns (red)",  group="OB/OS Columns")
showOsColumns  = input.bool(true,  title="Show OS Columns (green)", group="OB/OS Columns")
obColumnColor  = input.color(#ff3b3b, title="OB Column Color",      group="OB/OS Columns")
osColumnColor  = input.color(#00d27a, title="OS Column Color",      group="OB/OS Columns")
columnTransp   = input.int(30,    title="Column Transparency", minval=0, maxval=90, group="OB/OS Columns")

// --- Divergence Labels layer ---
showDivLabels  = input.bool(true, title="Show Divergence Labels (H↑/R↑/H↓/R↓)", group="Divergence Labels")
divLabelSize   = input.string("tiny", title="Label Size", options=["tiny","small","normal","large"], group="Divergence Labels")

// --- OB/OS Value Labels layer ---
showValLabels  = input.bool(true, title="Show OB/OS Value Labels on Crossover", group="OB/OS Value Labels")
valLabelSize   = input.string("tiny", title="Label Size", options=["tiny","small","normal"], group="OB/OS Value Labels")

// --- Price-pane Divergence Zones layer ---
showPriceZones = input.bool(true, title="Show Regular-Divergence Zones on Price",  group="Price Zones")
maxPriceZones  = input.int(6,     title="Max Zones per Side", minval=1, maxval=20,  group="Price Zones")
zoneBandWidth  = input.int(6,     title="Zone Band Width",    minval=2, maxval=15,  group="Price Zones")
zoneBandTransp = input.int(70,    title="Band Transparency",  minval=0, maxval=95,  group="Price Zones")

// --- Data Export (parity / calibration) ---
// When enabled, emits a set of hidden plots with `EXP_` prefix titles.
// TradingView's "Export chart data" feature includes these in the CSV,
// allowing Python parity tests to compare every series bar-by-bar.
// Plots use transparent color so the chart stays visually unchanged.
enableExport = input.bool(false, title="Enable Data Export Mode (parity)", group="Data Export", tooltip="Adds hidden EXP_ plots for sig/ma/turns/divs/zones — picked up by TV CSV export. Leave OFF for normal use.")

// --- MTF 多周期共振 ---
// Auto ×N higher-timeframe WaveTrend state shown as a corner dashboard, plus a
// background highlight when all three timeframes agree (resonance). HTF data is
// requested non-repainting (lookahead_off): historical bars never repaint; the
// rightmost forming HTF bar updates live, as expected for a status readout.
showMTF          = input.bool(true,   title="Show MTF Resonance Table",       group="MTF 多周期")
mtfAuto          = input.bool(true,   title="Auto HTF (× multiple of chart TF)", group="MTF 多周期", tooltip="ON: HTF = current TF × multiple (auto-adapts when you switch chart TF). OFF: use the fixed Manual timeframes below.")
mtfMult1         = input.int(4,        title="Auto · HTF1 ×", minval=2, maxval=240, group="MTF 多周期", tooltip="3m→×10=30m; 15m→×4=1h")
mtfMult2         = input.int(16,       title="Auto · HTF2 ×", minval=2, maxval=480, group="MTF 多周期", tooltip="3m→×120=6h; 15m→×16=4h")
mtfTf1Manual     = input.timeframe("60",  title="Manual · HTF1", group="MTF 多周期", tooltip="Used when Auto HTF is OFF. e.g. 30 = 30m, 360 = 6h")
mtfTf2Manual     = input.timeframe("240", title="Manual · HTF2", group="MTF 多周期", tooltip="Used when Auto HTF is OFF. e.g. 360 = 6h")
mtfTablePos      = input.string("top_right", title="Table Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group="MTF 多周期")
mtfTableSize     = input.string("small", title="Table Size", options=["tiny","small","normal"], group="MTF 多周期")
showMTFResonance = input.bool(true,   title="Highlight Background on Full Alignment", group="MTF 多周期")

// ===== Core Calculations =====

price = math.log(dropn(src, 1))

delta = price - xema(price, n1)
d     = xema(math.abs(delta), n1)
ci    = (d == 0) ? 0 : (delta / d)
sig   = EhlersEmaSmoother(ci, n2, smoothing)
ma    = ta.sma(sig, maperiod)

// ===== Structural Turning Points (measurement only — NOT trade signals) =====

reqpips = 5
sumsig  = math.sum(sig, reqpips)
summa   = math.sum(ma,  reqpips)

allbottoms = ma < ob    and ta.crossover(sig, ma)  and sumsig[1] < summa[1]
alltops    = ma > osLvl and ta.crossunder(sig, ma) and sumsig[1] > summa[1]

// Genuine-Extreme gate (Leg 1): a turn is "strong" only if sig actually reached
// the OB/OS band within the last genExtLookback bars. Mid-range turns (sig never
// hit the extreme) had ~0/negative forward lift OOS and are de-emphasized.
genExtBot   = ta.lowest(sig, genExtLookback)  <= osLvl
genExtTop   = ta.highest(sig, genExtLookback) >= ob
strongBottom = allbottoms and genExtBot
strongTop    = alltops    and genExtTop
weakBottom   = allbottoms and not genExtBot
weakTop      = alltops    and not genExtTop

bottomsteps = step(allbottoms, ma)
topsteps    = step(alltops,    ma)

[hiddenbull, hiddenbear] = findhidden(price, allbottoms, alltops, bottomsteps, topsteps, reqpips)

possiblebull = casc(bottomsteps, bottomsteps[1] < osLvl or (hiddenbull[1] > hiddenbear[1]), sig < ob)
possiblebear = cdesc(topsteps,   topsteps[1] > ob       or (hiddenbear[1] > hiddenbull[1]), sig > osLvl)

bullishtrend = possiblebull / (1.0 + possiblebear)
bearishtrend = possiblebear / (1.0 + possiblebull)

// ===== Plots — WT Core =====

plot(sig, color=color.new(#0094ff, 0), title="Signal")
plot(ma,  color=color.new(#ff6a00, 0), title="SMA")

lineBuyBottom = plot(osLvl, color=color.new(color.orange, 0), title="Oversold Level")
lineSellTop   = plot(ob,    color=color.new(#00bb00, 0),      title="Overbought Level")

lineBuy  = plot(series=(sig < osLvl ? sig : osLvl), color=color.new(color.orange, 100), title="n/a", editable=false)
lineSell = plot(series=(sig > ob    ? sig : ob),    color=color.new(#00bb00,      100), title="n/a", editable=false)

fill(plot1=lineBuy,     plot2=lineBuyBottom, color=color.new(color.orange, 50), title="Oversold area")
fill(plot1=lineSellTop, plot2=lineSell,      color=color.new(#00bb00,      50), title="Overbought area")

plot(showhist ? sig - ma : na, color=sig > ma ? color.new(#5fc8ff, 80) : color.new(#ff9900, 80), style=plot.style_area, title="Histogram")

// ===== OB/OS Strength Columns =====
// Vertical bars showing how deep sig has pushed past OB/OS. Red columns rise
// from the OB level upward to sig; green columns fall from the OS level
// downward to sig. Complements the existing area fills with sharper visual cue.

plot(showObColumns and sig > ob    ? sig : na, color=color.new(obColumnColor, columnTransp), style=plot.style_columns, histbase=ob,    linewidth=1, title="OB Column")
plot(showOsColumns and sig < osLvl ? sig : na, color=color.new(osColumnColor, columnTransp), style=plot.style_columns, histbase=osLvl, linewidth=1, title="OS Column")

// ===== Background Tint — Trend Strength =====
// Net trend (bull − bear) sets the hue; magnitude sets opacity (capped subtle so
// the WT line stays readable). Replaces the old area fills — no shape clutter.

netTrend    = bullishtrend - bearishtrend
tintOpacity = math.min(math.abs(netTrend) * trendIntensity, 25)   // 0..25 opacity
tintTransp  = 100 - tintOpacity                                   // 75..100 transp
bgTint      = netTrend > 0 ? color.new(color.lime, tintTransp) : netTrend < 0 ? color.new(color.red, tintTransp) : na
bgcolor(showTrend ? bgTint : na, title="Trend Strength")

// ===== Plots — Turning Point Markers (dots on sig line) =====
// Two tiers (Leg 1): STRONG turns (sig reached the OB/OS band) render as full-size
// dots; WEAK mid-range turns render as small faded dots, or hidden entirely when
// `showOnlyStrongTurns` is on. Strong turns carry the cleaner forward edge OOS.

weakDotTransp = 65

plot(showTurnPoints and strongBottom ? sig : na, style=plot.style_circles, color=color.new(color.aqua,    0),             linewidth=turnDotSize,        title="WT Bottom (strong)")
plot(showTurnPoints and strongTop    ? sig : na, style=plot.style_circles, color=color.new(color.fuchsia, 0),             linewidth=turnDotSize,        title="WT Top (strong)")
plot(showTurnPoints and not showOnlyStrongTurns and weakBottom ? sig : na, style=plot.style_circles, color=color.new(color.aqua,    weakDotTransp), linewidth=math.max(turnDotSize - 1, 1), title="WT Bottom (weak)")
plot(showTurnPoints and not showOnlyStrongTurns and weakTop    ? sig : na, style=plot.style_circles, color=color.new(color.fuchsia, weakDotTransp), linewidth=math.max(turnDotSize - 1, 1), title="WT Top (weak)")

// ===== Divergence Detection & Lines =====
// At each turning point, compare current vs previous extreme. Two mutually
// exclusive patterns per side:
//   solid  = hidden divergence  (trend continuation)
//   dashed = regular divergence (trend reversal)
// State tracking runs unconditionally so toggling visibility never desyncs it.
// Flags are computed at series level so labels and price zones can consume
// them downstream without duplicating logic.

var int   prevBotBar   = na
var float prevBotMa    = na
var float prevBotPrice = na

var int   prevTopBar   = na
var float prevTopMa    = na
var float prevTopPrice = na

botLow  = ta.lowest(low,  reqpips)
topHigh = ta.highest(high, reqpips)

// Hidden bullish: WT lower low + price higher low → continuation up
// Regular bullish: WT higher low + price lower low → reversal up
// Hidden bearish: WT higher high + price lower high → continuation down
// Regular bearish: WT lower high + price higher high → reversal down
bool hiddenBullDiv = allbottoms and not na(prevBotBar) and ma < prevBotMa and botLow  > prevBotPrice
bool regBullDiv    = allbottoms and not na(prevBotBar) and ma > prevBotMa and botLow  < prevBotPrice
bool hiddenBearDiv = alltops    and not na(prevTopBar) and ma > prevTopMa and topHigh < prevTopPrice
bool regBearDiv    = alltops    and not na(prevTopBar) and ma < prevTopMa and topHigh > prevTopPrice

// Regular divergence = the reliable "true reversal" signal → full styling.
// Hidden divergence = low-reliability (negative OOS lift) → subordinate: thin
// line + faded color so it never competes visually with regular divergences.
hiddenLineWidth = 1
hiddenLineTransp = 55

if hiddenBullDiv and showHiddenDiv
    line.new(prevBotBar, prevBotMa, bar_index, ma, color=color.new(color.lime, hiddenLineTransp), width=hiddenLineWidth, style=line.style_solid)
if regBullDiv and showRegularDiv
    line.new(prevBotBar, prevBotMa, bar_index, ma, color=color.new(color.lime, 0), width=divLineWidth, style=line.style_dashed)
if hiddenBearDiv and showHiddenDiv
    line.new(prevTopBar, prevTopMa, bar_index, ma, color=color.new(color.red,  hiddenLineTransp), width=hiddenLineWidth, style=line.style_solid)
if regBearDiv and showRegularDiv
    line.new(prevTopBar, prevTopMa, bar_index, ma, color=color.new(color.red,  0), width=divLineWidth, style=line.style_dashed)

// State updates — only at confirmed turning points
if allbottoms
    prevBotBar   := bar_index
    prevBotMa    := ma
    prevBotPrice := botLow

if alltops
    prevTopBar   := bar_index
    prevTopMa    := ma
    prevTopPrice := topHigh

// ===== Divergence Labels =====
// Short-symbol tags placed at each detected divergence:
//   H↑ = hidden bullish (continuation up) | R↑ = regular bullish (reversal up)
//   H↓ = hidden bearish (continuation dn) | R↓ = regular bearish (reversal dn)
// Bull labels sit below the WT bottom (pointing up); bear labels sit above the
// WT top (pointing down). Anchored at the same y as the divergence line endpoint.

divSize = switch divLabelSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
    => size.tiny

if showDivLabels and hiddenBullDiv
    label.new(bar_index, ma, text="H↑", style=label.style_label_up,   color=color.new(color.lime, 0), textcolor=color.black, size=divSize)
if showDivLabels and regBullDiv
    label.new(bar_index, ma, text="R↑", style=label.style_label_up,   color=color.new(color.lime, 0), textcolor=color.black, size=divSize)
if showDivLabels and hiddenBearDiv
    label.new(bar_index, ma, text="H↓", style=label.style_label_down, color=color.new(color.red,  0), textcolor=color.white, size=divSize)
if showDivLabels and regBearDiv
    label.new(bar_index, ma, text="R↓", style=label.style_label_down, color=color.new(color.red,  0), textcolor=color.white, size=divSize)

// ===== OB/OS Value Labels =====
// When sig crosses ABOVE the OB level, drop a label showing its current value
// just above the line (label points down to sig). When sig crosses BELOW OS,
// drop one below the line (label points up). One-shot on crossing — not every
// bar while extreme — to keep the pane uncluttered.

valSize = switch valLabelSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    => size.tiny

bool obCrossed = ta.crossover(sig, ob)
bool osCrossed = ta.crossunder(sig, osLvl)

if showValLabels and obCrossed
    label.new(bar_index, sig, text=str.tostring(sig, "#.##"), style=label.style_label_down, color=color.new(#00bb00, 20),       textcolor=color.white, size=valSize)
if showValLabels and osCrossed
    label.new(bar_index, sig, text=str.tostring(sig, "#.##"), style=label.style_label_up,   color=color.new(color.orange, 20), textcolor=color.white, size=valSize)

// ===== Price-pane Divergence Zones =====
// Regular divergences mark S/R-relevant turn points; we project their price
// levels forward as horizontal zones drawn on the *price* pane (force_overlay).
// Each zone is two lines: a thin primary plus a wider translucent band —
// the ChartPrime RSI-Momentum-Div-Zones visual idiom.
// When price closes through the level the zone flips to dashed and the band
// is removed (marking a tested S/R that no longer holds).
// Per side capped at maxPriceZones; oldest auto-removed on overflow.

var array<divZone> bullZones = array.new<divZone>()
var array<divZone> bearZones = array.new<divZone>()

if showPriceZones and regBullDiv
    plBull = line.new(bar_index, botLow, bar_index + 1, botLow, color=color.new(color.lime, 0),              width=1,             style=line.style_solid, force_overlay=true)
    blBull = line.new(bar_index, botLow, bar_index + 1, botLow, color=color.new(color.lime, zoneBandTransp), width=zoneBandWidth, style=line.style_solid, force_overlay=true)
    bullZones.push(divZone.new(plBull, blBull, botLow, true, false))

if showPriceZones and regBearDiv
    plBear = line.new(bar_index, topHigh, bar_index + 1, topHigh, color=color.new(color.red, 0),              width=1,             style=line.style_solid, force_overlay=true)
    blBear = line.new(bar_index, topHigh, bar_index + 1, topHigh, color=color.new(color.red, zoneBandTransp), width=zoneBandWidth, style=line.style_solid, force_overlay=true)
    bearZones.push(divZone.new(plBear, blBear, topHigh, false, false))

while bullZones.size() > maxPriceZones
    oldestBull = bullZones.shift()
    oldestBull.primaryLine.delete()
    oldestBull.bgLine.delete()

while bearZones.size() > maxPriceZones
    oldestBear = bearZones.shift()
    oldestBear.primaryLine.delete()
    oldestBear.bgLine.delete()

if bullZones.size() > 0
    for i = 0 to bullZones.size() - 1
        zb = bullZones.get(i)
        if not zb.isBroken
            if low < zb.level
                zb.primaryLine.set_x2(bar_index)
                zb.primaryLine.set_style(line.style_dashed)
                zb.bgLine.delete()
                zb.isBroken := true
            else
                zb.primaryLine.set_x2(bar_index + 5)
                zb.bgLine.set_x2(bar_index + 5)

if bearZones.size() > 0
    for i = 0 to bearZones.size() - 1
        zs = bearZones.get(i)
        if not zs.isBroken
            if high > zs.level
                zs.primaryLine.set_x2(bar_index)
                zs.primaryLine.set_style(line.style_dashed)
                zs.bgLine.delete()
                zs.isBroken := true
            else
                zs.primaryLine.set_x2(bar_index + 5)
                zs.bgLine.set_x2(bar_index + 5)

// ===== Data Export Plots (transparent — invisible on chart, present in CSV) =====
// Activated by `enableExport` toggle (Data Export group). When ON, "Export chart
// data" includes every series below under its EXP_<name> column. Off by default
// so end-users never see clutter. All plots use color.new(*, 100) (fully
// transparent) + editable=false so toggling them off is a no-op visually.
expColor = color.new(color.black, 100)

plot(enableExport ? sig                                  : na, title="EXP_sig",            color=expColor, editable=false, display=display.data_window)
plot(enableExport ? ma                                   : na, title="EXP_ma",             color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (allbottoms     ? 1.0 : 0.0)         : na, title="EXP_allbottoms",     color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (alltops        ? 1.0 : 0.0)         : na, title="EXP_alltops",        color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (hiddenBullDiv  ? 1.0 : 0.0)         : na, title="EXP_hiddenBullDiv",  color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (regBullDiv     ? 1.0 : 0.0)         : na, title="EXP_regBullDiv",     color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (hiddenBearDiv  ? 1.0 : 0.0)         : na, title="EXP_hiddenBearDiv",  color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (regBearDiv     ? 1.0 : 0.0)         : na, title="EXP_regBearDiv",     color=expColor, editable=false, display=display.data_window)
plot(enableExport ? botLow                               : na, title="EXP_botLow",         color=expColor, editable=false, display=display.data_window)
plot(enableExport ? topHigh                              : na, title="EXP_topHigh",        color=expColor, editable=false, display=display.data_window)
plot(enableExport ? prevBotMa                            : na, title="EXP_prevBotMa",      color=expColor, editable=false, display=display.data_window)
plot(enableExport ? prevTopMa                            : na, title="EXP_prevTopMa",      color=expColor, editable=false, display=display.data_window)
plot(enableExport ? bullishtrend                         : na, title="EXP_bullishtrend",   color=expColor, editable=false, display=display.data_window)
plot(enableExport ? bearishtrend                         : na, title="EXP_bearishtrend",   color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (strongBottom   ? 1.0 : 0.0)         : na, title="EXP_strongBottom",   color=expColor, editable=false, display=display.data_window)
plot(enableExport ? (strongTop      ? 1.0 : 0.0)         : na, title="EXP_strongTop",      color=expColor, editable=false, display=display.data_window)

// ===== MTF Multi-Timeframe Resonance =====
// Auto ×N higher-timeframe WaveTrend state in a corner dashboard + background
// highlight on full alignment. HTF requested non-repainting (lookahead_off):
// history never repaints; the forming HTF bar updates live (expected for status).
// LTF computation above is untouched — this section only READS via request.security.

// Convert a ×multiple of the current timeframe into a TF string.
tfFromMult(_mult) =>
    _mins = timeframe.in_seconds() * _mult / 60
    _mins >= 1440 and _mins % 1440 == 0 ? str.tostring(math.round(_mins / 1440)) + "D" : str.tostring(math.round(_mins))

// Pretty TF label: "15"→"15m", "60"→"1h", "240"→"4h", "1D"→"1D".
fmtTf(_tf) =>
    _m = str.tonumber(_tf)
    na(_m) ? _tf : (_m >= 60 and _m % 60 == 0 ? str.tostring(math.round(_m / 60)) + "h" : str.tostring(math.round(_m)) + "m")

// Full [axe] WT state on an arbitrary timeframe — returns [sig, ma, regBull, regBear].
// Mirrors the LTF core/turn/regular-divergence math; draws nothing (security-safe).
htfState() =>
    _price  = math.log(close)
    _delta  = _price - xema(_price, n1)
    _d      = xema(math.abs(_delta), n1)
    _ci     = (_d == 0) ? 0.0 : (_delta / _d)
    _sig    = EhlersEmaSmoother(_ci, n2, smoothing)
    _ma     = ta.sma(_sig, maperiod)
    _sumsig = math.sum(_sig, reqpips)
    _summa  = math.sum(_ma,  reqpips)
    _allbot = _ma < ob    and ta.crossover(_sig, _ma)  and _sumsig[1] < _summa[1]
    _alltop = _ma > osLvl and ta.crossunder(_sig, _ma) and _sumsig[1] > _summa[1]
    _botLow  = ta.lowest(low,  reqpips)
    _topHigh = ta.highest(high, reqpips)
    var float _pBotMa = na
    var float _pBotPx = na
    var float _pTopMa = na
    var float _pTopPx = na
    _regBull = _allbot and not na(_pBotMa) and _ma > _pBotMa and _botLow  < _pBotPx
    _regBear = _alltop and not na(_pTopMa) and _ma < _pTopMa and _topHigh > _pTopPx
    if _allbot
        _pBotMa := _ma
        _pBotPx := _botLow
    if _alltop
        _pTopMa := _ma
        _pTopPx := _topHigh
    [_sig, _ma, _regBull ? 1.0 : 0.0, _regBear ? 1.0 : 0.0]

mtfTf1 = mtfAuto ? tfFromMult(mtfMult1) : mtfTf1Manual
mtfTf2 = mtfAuto ? tfFromMult(mtfMult2) : mtfTf2Manual

[h1Sig, h1Ma, h1RbRaw, h1ReRaw] = request.security(syminfo.tickerid, mtfTf1, htfState(), lookahead=barmerge.lookahead_off)
[h2Sig, h2Ma, h2RbRaw, h2ReRaw] = request.security(syminfo.tickerid, mtfTf2, htfState(), lookahead=barmerge.lookahead_off)

// Latch the most-recent regular-divergence direction per timeframe (HTF bars are
// sparse on the LTF chart, so a one-bar pulse would rarely be visible otherwise).
mtfLatch(rb, re, prev) =>
    rb > 0 ? 1 : re > 0 ? -1 : prev

var int curDiv = 0
curDiv := mtfLatch(regBullDiv ? 1.0 : 0.0, regBearDiv ? 1.0 : 0.0, curDiv)
var int h1Div = 0
h1Div := mtfLatch(h1RbRaw, h1ReRaw, h1Div)
var int h2Div = 0
h2Div := mtfLatch(h2RbRaw, h2ReRaw, h2Div)

// Resonance = all three timeframes agree on WT direction (sig vs ma).
curBull = sig  > ma
h1Bull  = h1Sig > h1Ma
h2Bull  = h2Sig > h2Ma
bullReso = curBull and h1Bull and h2Bull
bearReso = (not curBull) and (not h1Bull) and (not h2Bull)
bgcolor(showMTFResonance and bullReso ? color.new(color.lime, 82) : showMTFResonance and bearReso ? color.new(color.red, 82) : na, title="MTF Resonance")

// ── Dashboard table ──────────────────────────────────────────────
mtfPos = switch mtfTablePos
    "top_right"     => position.top_right
    "top_left"      => position.top_left
    "bottom_right"  => position.bottom_right
    "bottom_left"   => position.bottom_left
    "middle_right"  => position.middle_right
    => position.top_right

mtfSize = switch mtfTableSize
    "tiny"   => size.tiny
    "small"  => size.small
    "normal" => size.normal
    => size.small

GREEN = #00d27a
RED   = #ff3b3b
GREY  = #9598a1
PANEL = color.new(#161a25, 5)
HDRBG = color.new(#2a2e39, 0)
TXTW  = color.new(#e8e8ea, 0)

trendTxt(_bull)  => _bull ? "▲" : "▼"
trendCol(_bull)  => _bull ? GREEN : RED
zoneTxt(_s)      => _s >= ob ? "OB" : _s <= osLvl ? "OS" : "·"
zoneCol(_s)      => _s >= ob ? RED : _s <= osLvl ? GREEN : GREY
divTxt(_d)       => _d > 0 ? "R↑" : _d < 0 ? "R↓" : "·"
divCol(_d)       => _d > 0 ? GREEN : _d < 0 ? RED : GREY

var table mtfTable = na
if showMTF and barstate.islast
    mtfTable := table.new(mtfPos, 4, 4, bgcolor=PANEL, frame_color=color.new(color.gray, 40), frame_width=1, border_color=color.new(color.gray, 60), border_width=1)
    // header
    table.cell(mtfTable, 0, 0, "TF",    text_color=TXTW, bgcolor=HDRBG, text_size=mtfSize)
    table.cell(mtfTable, 1, 0, "Trend", text_color=TXTW, bgcolor=HDRBG, text_size=mtfSize)
    table.cell(mtfTable, 2, 0, "Zone",  text_color=TXTW, bgcolor=HDRBG, text_size=mtfSize)
    table.cell(mtfTable, 3, 0, "Div",   text_color=TXTW, bgcolor=HDRBG, text_size=mtfSize)
    // row 1: current TF
    table.cell(mtfTable, 0, 1, fmtTf(timeframe.period) + "*", text_color=TXTW, text_size=mtfSize)
    table.cell(mtfTable, 1, 1, trendTxt(curBull), text_color=trendCol(curBull), text_size=mtfSize)
    table.cell(mtfTable, 2, 1, zoneTxt(sig),      text_color=zoneCol(sig),      text_size=mtfSize)
    table.cell(mtfTable, 3, 1, divTxt(curDiv),    text_color=divCol(curDiv),    text_size=mtfSize)
    // row 2: HTF1 (×mult1)
    table.cell(mtfTable, 0, 2, fmtTf(mtfTf1), text_color=TXTW, text_size=mtfSize)
    table.cell(mtfTable, 1, 2, trendTxt(h1Bull), text_color=trendCol(h1Bull), text_size=mtfSize)
    table.cell(mtfTable, 2, 2, zoneTxt(h1Sig),   text_color=zoneCol(h1Sig),   text_size=mtfSize)
    table.cell(mtfTable, 3, 2, divTxt(h1Div),    text_color=divCol(h1Div),    text_size=mtfSize)
    // row 3: HTF2 (×mult2)
    table.cell(mtfTable, 0, 3, fmtTf(mtfTf2), text_color=TXTW, text_size=mtfSize)
    table.cell(mtfTable, 1, 3, trendTxt(h2Bull), text_color=trendCol(h2Bull), text_size=mtfSize)
    table.cell(mtfTable, 2, 3, zoneTxt(h2Sig),   text_color=zoneCol(h2Sig),   text_size=mtfSize)
    table.cell(mtfTable, 3, 3, divTxt(h2Div),    text_color=divCol(h2Div),    text_size=mtfSize)
    // resonance flag on the TF header cell
    if bullReso
        table.cell(mtfTable, 0, 0, "⚡▲", text_color=color.black, bgcolor=GREEN, text_size=mtfSize)
    else if bearReso
        table.cell(mtfTable, 0, 0, "⚡▼", text_color=color.white, bgcolor=RED, text_size=mtfSize)
````
