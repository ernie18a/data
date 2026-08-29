<!-- tradingview-pine-id: PUB;a6f9adb8adb642c49c41d417f02b7482 -->
<!-- tradingviewscripts-format: 1 -->
# MACD Trend Phase MTF by [Itto Ryu]

Source: https://www.tradingview.com/script/osxqVQak-MACD-Trend-Phase-MTF-by-Itto-Ryu/

## Description

# MACD Trend Phase MTF by [Itto Ryu] — User Manual (Publication Version)

---

## 1 · Purpose

This indicator answers one question: **"Where are we in the trend lifecycle?"** — not merely "has MACD crossed yet?"

A single MACD can only describe momentum state; it cannot describe trend *phase*, because phase emerges from the relationship between multiple timeframes. This script reads a PPO-normalized MACD across three time layers — a slow timeframe sets the regime, a mid timeframe defines the phase, and the chart timeframe tracks entry timing — then outputs an instantly readable phase name, a multi-timeframe dashboard, and a weighted consensus verdict (MAJOR).

Because everything is normalized to percentages, it works on any market and any symbol: index futures, stocks, crypto, or forex.

## 2 · Methodology

**Engine — PPO (Percentage Price Oscillator):**
```
PPO    = (EMA(close,12) − EMA(close,26)) / EMA(close,26) × 100
Signal = EMA(PPO, 9)
Hist   = PPO − Signal
```
PPO is used instead of raw MACD so thresholds stay constant across markets and across years (raw MACD is denominated in price units and cannot be compared across symbols).

**Phase state machine (computed on the Phase TF, default 4H):** each timeframe uses only three features:
1. **Regime** — PPO above/below zero
2. **Impulse** — PPO above/below its signal line
3. **Leg-peak memory** — is the latest impulse leg's PPO peak lower than the previous leg's peak? (structural momentum divergence)

Combined with the slow-TF regime, this yields 9 phases:

| Phase | Condition | Meaning |
|---|---|---|
| ESTABLISHED BULL | Slow bull + mid bull + impulse up | Fully aligned uptrend |
| BULL PULLBACK | Mid bull + impulse down + peaks not declining | Correction inside an uptrend — a classic continuation setup |
| WEAKENING BULL | Mid bull + impulse down + lower peaks | Late-stage uptrend — momentum thinning |
| EMERGING BULL | Mid bull but slow TF not yet bull | New trend, not yet confirmed |
| TRANSITION / CHOP | \|PPO\| < chop threshold | No phase — directionless market |
| (4 BEAR phases = mirror) | | BEAR RALLY = the mirror continuation setup |

**Anti-flicker:** the committed phase changes only after the new raw phase persists for N chart bars (default 2) — hysteresis prevents flickering.

**Timing signal:** when the phase is a pullback phase and the chart-TF histogram inflects back in the trend direction (`hist > hist[1]` after falling, or the mirror), a ▲/▼ triangle prints on the price chart. The idea: the higher timeframe defines *where* momentum entries make conceptual sense; the chart timeframe shows *when* the counter-move is fading.

**MAJOR consensus:** each grid TF scores its phase (Established ±1.0, Pullback ±0.75, Emerging ±0.5, Weakening ±0.25, Chop 0), weighted by timeframe (default 30m×1, 1H×1.5, 4H×2, D×3) → summed into a net % → |net| ≥ 20% = LONG/SHORT lean, ≥ 50% = strong. This is a structured way of reading multi-timeframe agreement at a glance — higher timeframes get louder votes.

## 3 · Defaults (Inputs)

| Input | Default | Rationale |
|---|---|---|
| Regime TF | D | Slowest layer; only its zero-line side is used |
| Phase TF | 240 (4H) | Phase-defining layer — roughly 4–6× the chart TF works well |
| Fast / Slow / Signal | 12 / 26 / 9 | Standard values, identical on every TF — deliberately untuned |
| Chop threshold | 0.10% | \|PPO\| below this = directionless market |
| Phase confirm bars | 2 | Hysteresis against phase flicker |
| Grid TFs | 30m / 1H / 4H / D | Dashboard rows |
| Weights | 1 / 1.5 / 2 / 3 | Higher timeframes get louder votes |
| Major bias / Strong | 20% / 50% | Verdict thresholds |
| Dashboard size | Middle | Tiny / Middle / Large |

All defaults are starting points, not optimized values — adjust them to your market and timeframe structure.

## 4 · Visual Elements

| Element | Meaning |
|---|---|
| Histogram columns (pane) | Chart-TF PPO − Signal; solid color = accelerating, faded = fading |
| Blue / orange lines (pane) | Chart-TF PPO / Signal |
| Pane background color | Current phase (green = bull family, red = bear family, orange = weakening, gray = chop) |
| ▲ / ▼ on the price chart | Timing markers — phase-gated momentum inflections |
| TF grid table | Phase per timeframe + ● dot in the L / S / H column |
| MAJOR row | Weighted consensus verdict + net % |
| Timing row | Timing status ("wait" / "TIMING NOW") |
| ⚠ row | Warns when chart TF ≥ Phase TF (view a lower TF, e.g. 1H) |

## 5 · Who This Is For / NOT For

**For:** traders studying trend-pullback structure who execute manually and use indicators as context filters; anyone who wants a one-glance answer to "is this market trending, correcting, weakening, or going nowhere?"

**NOT for:** scalpers far below the phase TF (higher-TF data updates too slowly to matter); anyone expecting a fully automatic buy/sell system (this is decision support, not a bot); extended sideways markets (it will mostly show CHOP — which is the correct reading: no trend phase exists).

## 6 · How to Use (Study Playbook)

1. Open the chart one or more steps **below the Phase TF** (e.g. 1H chart with a 4H phase TF).
2. Use the background color and phase label as context: trend-following ideas align with ESTABLISHED phases, continuation setups form during PULLBACK / RALLY phases, and WEAKENING or CHOP suggest standing aside.
3. Check the **MAJOR** row — study how often lower and higher timeframes agree before strong moves, and how disagreement resolves.
4. The ▲/▼ triangles mark where a counter-trend swing's momentum fades *while the higher timeframe still points with the trend* — the classic pullback-entry concept. Observe how these behave on your market before acting on any of them.
5. Momentum-inflection signals are, by nature, short-horizon events — they describe the next swing, not the next month. Re-evaluate whenever the phase changes.
6. Alerts: alert dialog → Condition = "MACD Phase" → choose "Phase changed", "Major bias changed", "Long timing" or "Short timing" → recommended trigger **Once per bar close**.
7. WEAKENING is best studied as a position-management state (momentum thinning), not a reversal signal.

## 7 · Common Mistakes

- ❌ Treating ESTABLISHED phases as entry signals — by the time everything is aligned, much of the move has often happened; the pullback phases are where continuation logic actually applies.
- ❌ Taking every triangle in both directions on every market — different markets have different structural drifts; study each side's behavior on your instrument first.
- ❌ Expecting momentum-inflection signals to define long swings — their information decays quickly.
- ❌ Viewing on a chart TF larger than the Phase TF (the ⚠ row will warn you).
- ❌ Reading MAJOR % as a probability — it is a weighted vote score (a structured prior), not a measured probability.
- ❌ Changing several inputs at once — you lose track of what actually changed the behavior.

## 8 · For Educational Purposes Only

This indicator is published **for educational purposes only**. It is a tool for studying how momentum, trend phase, and multi-timeframe structure interact — it is **not** a trading system, does not generate financial advice, and makes **no claim of profitability**. No performance figures are stated or implied; past behavior of any signal, on any market, does not guarantee future results. Before risking real capital on any concept illustrated here, do your own testing on your own market, timeframe, and cost structure, and consult a licensed financial professional where appropriate. You alone are responsible for your trading decisions.

## 9 · Disclosure Block

- **Pine version:** v6
- **Repaint:** NO on closed bars — every HTF value uses only fully closed bars (`security(expr[1], lookahead_on)` idiom); historical bars are never redrawn. Note: current-bar table values and signals update until the bar closes — use alerts set to "Once per bar close".
- **Chart type:** standard candles only (no Heikin Ashi / Renko / Range — synthetic prices distort PPO).

- **Originality:** fully original code — the phase state machine, leg-peak memory, and weighted MTF consensus were written from scratch, not adapted from any open-source script.

- **This indicator is create for educational purposes only — not investment advice or recommendation or professional advice, you are on your own risk **

---

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Thiranat

//@version=6
indicator("MACD Trend Phase MTF by [Itto Ryu]", "MACD Phase", overlay = false)

// ─── Inputs ──────────────────────────────────────────────────────────
grpTF = "Timeframes"
tfSlow = input.timeframe("D",   "Regime TF (slow)", group = grpTF, tooltip = "Contributes regime only (zero-line side).")
tfMid  = input.timeframe("240", "Phase TF (mid)",   group = grpTF, tooltip = "Defines the committed trend phase (background + timing gate). View the chart on a TF below this one (e.g. 1H).")

grpM = "MACD engine (PPO-normalized)"
fastLen = input.int(12, "Fast length",   minval = 1, group = grpM, tooltip = "Fast EMA length of the PPO engine (applies to every TF).")
slowLen = input.int(26, "Slow length",   minval = 1, group = grpM, tooltip = "Slow EMA length of the PPO engine (applies to every TF).")
sigLen  = input.int(9,  "Signal length", minval = 1, group = grpM, tooltip = "Signal EMA length of the PPO engine (applies to every TF).")

grpP = "Phase logic"
chopTh      = input.float(0.10, "Chop threshold (|PPO| %)", minval = 0.0, step = 0.05, group = grpP, tooltip = "|PPO| below this = Transition/Chop; phases suppressed.")
confirmBars = input.int(2, "Phase confirm bars", minval = 1, group = grpP, tooltip = "New raw phase must persist this many chart bars before the committed phase changes (anti-flicker).")

grpG = "MTF grid (table)"
tfT1 = input.timeframe("30",  "Grid TF 1", group = grpG, tooltip = "First row of the dashboard grid.")
tfT2 = input.timeframe("60",  "Grid TF 2", group = grpG, tooltip = "Second row of the dashboard grid.")
tfT3 = input.timeframe("240", "Grid TF 3", group = grpG, tooltip = "Third row of the dashboard grid.")
tfT4 = input.timeframe("D",   "Grid TF 4", group = grpG, tooltip = "Fourth row of the dashboard grid.")
wT1  = input.float(1.0, "Weight TF 1", minval = 0.0, step = 0.5, group = grpG, tooltip = "Vote weight of Grid TF 1 in the MAJOR consensus.")
wT2  = input.float(1.5, "Weight TF 2", minval = 0.0, step = 0.5, group = grpG, tooltip = "Vote weight of Grid TF 2 in the MAJOR consensus.")
wT3  = input.float(2.0, "Weight TF 3", minval = 0.0, step = 0.5, group = grpG, tooltip = "Vote weight of Grid TF 3 in the MAJOR consensus.")
wT4  = input.float(3.0, "Weight TF 4", minval = 0.0, step = 0.5, group = grpG, tooltip = "Vote weight of Grid TF 4 in the MAJOR consensus.")
biasTh   = input.int(20, "Major bias threshold (%)",  minval = 0, maxval = 100, group = grpG, tooltip = "Net weighted score beyond ±this = LONG/SHORT bias; inside = HOLD.")
strongTh = input.int(50, "Strong bias threshold (%)", minval = 0, maxval = 100, group = grpG, tooltip = "Net score beyond ±this drops the LEAN prefix (strong consensus).")

grpD = "Display"
showTable  = input.bool(true, "Show MTF table", group = grpD)
tblSize    = input.string("Middle", "Dashboard size", options = ["Tiny", "Middle", "Large"], group = grpD)
showTiming = input.bool(true, "Show timing signals on price chart", group = grpD)

txtSize = tblSize == "Large" ? size.normal : tblSize == "Middle" ? size.small : size.tiny

// ─── PPO engine (shared) ─────────────────────────────────────────────
f_ppo() =>
    fast = ta.ema(close, fastLen)
    slow = ta.ema(close, slowLen)
    (fast - slow) / slow * 100

// Per-TF full state: PPO, signal, leg-peak memory (for Weakening).
// Returns last CLOSED bar values ([1] + lookahead_on = confirmed, no repaint).
f_tfState() =>
    ppo   = f_ppo()
    sig   = ta.ema(ppo, sigLen)
    impUp = ppo > sig
    var float curMax      = na
    var float lastPeak    = na
    var float priorPeak   = na
    var float curMin      = na
    var float lastTrough  = na
    var float priorTrough = na
    if impUp
        curMax := impUp[1] ? math.max(nz(curMax, ppo), ppo) : ppo
    else
        curMin := not impUp[1] ? math.min(nz(curMin, ppo), ppo) : ppo
    if not impUp and impUp[1]
        priorPeak := lastPeak
        lastPeak  := curMax
    if impUp and not impUp[1]
        priorTrough := lastTrough
        lastTrough  := curMin
    lowerPk = not na(priorPeak) and lastPeak < priorPeak ? 1.0 : 0.0
    higherTr = not na(priorTrough) and lastTrough > priorTrough ? 1.0 : 0.0
    [ppo[1], sig[1], lowerPk[1], higherTr[1]]

sPpo = request.security(syminfo.tickerid, tfSlow, f_ppo()[1], lookahead = barmerge.lookahead_on)
[mPpo, mSig, mLowerPk, mHigherTr] = request.security(syminfo.tickerid, tfMid, f_tfState(), lookahead = barmerge.lookahead_on)
[p1Ppo, p1Sig, p1Lp, p1Ht] = request.security(syminfo.tickerid, tfT1, f_tfState(), lookahead = barmerge.lookahead_on)
[p2Ppo, p2Sig, p2Lp, p2Ht] = request.security(syminfo.tickerid, tfT2, f_tfState(), lookahead = barmerge.lookahead_on)
[p3Ppo, p3Sig, p3Lp, p3Ht] = request.security(syminfo.tickerid, tfT3, f_tfState(), lookahead = barmerge.lookahead_on)
[p4Ppo, p4Sig, p4Lp, p4Ht] = request.security(syminfo.tickerid, tfT4, f_tfState(), lookahead = barmerge.lookahead_on)

// Chart TF (timing layer)
ppoC  = f_ppo()
sigC  = ta.ema(ppoC, sigLen)
histC = ppoC - sigC

// ─── Phase state machine ─────────────────────────────────────────────
// 0 chop · 1 emerging bull · 2 established bull · 3 bull pullback · 4 weakening bull · negatives = bear mirror
slowBull = sPpo > 0

f_phase(float ppo, float sig, float lp, float ht) =>
    int ph = 0
    if not na(ppo) and not na(sig) and not na(sPpo) and math.abs(ppo) >= chopTh
        bull  = ppo > 0
        impUp = ppo > sig
        if bull
            ph := impUp ? (slowBull ? 2 : 1) : (nz(lp) > 0.5 ? 4 : 3)
        else
            ph := not impUp ? (not slowBull ? -2 : -1) : (nz(ht) > 0.5 ? -4 : -3)
    ph

rawPhase = f_phase(mPpo, mSig, mLowerPk, mHigherTr)
ph1 = f_phase(p1Ppo, p1Sig, p1Lp, p1Ht)
ph2 = f_phase(p2Ppo, p2Sig, p2Lp, p2Ht)
ph3 = f_phase(p3Ppo, p3Sig, p3Lp, p3Ht)
ph4 = f_phase(p4Ppo, p4Sig, p4Lp, p4Ht)

// Hysteresis: commit only after the same raw phase persists confirmBars chart bars
var int phase   = 0
var int cand    = 0
var int candCnt = 0
if rawPhase == phase
    candCnt := 0
else
    if rawPhase == cand
        candCnt += 1
    else
        cand    := rawPhase
        candCnt := 1
    if candCnt >= confirmBars
        phase   := rawPhase
        candCnt := 0

// ─── Major bias: TF-weighted consensus across the grid ───────────────
// Phase score: established ±1.0, pullback/rally ±0.75, emerging ±0.5, weakening ±0.25, chop 0
f_score(int p) =>
    s = switch math.abs(p)
        2 => 1.0
        3 => 0.75
        1 => 0.5
        4 => 0.25
        => 0.0
    p < 0 ? -s : s

// Action per TF: 1 = Long, -1 = Short, 0 = Hold (weakening + chop)
f_action(int p) =>
    p == 0 or p == 4 or p == -4 ? 0 : p > 0 ? 1 : -1

wSum   = wT1 + wT2 + wT3 + wT4
netPct = wSum > 0 ? (f_score(ph1) * wT1 + f_score(ph2) * wT2 + f_score(ph3) * wT3 + f_score(ph4) * wT4) / wSum * 100 : 0.0
int majorBias = netPct >= biasTh ? 1 : netPct <= -biasTh ? -1 : 0

// ─── Timing layer: chart-TF histogram inflection inside a pullback phase ──
histTurnUp = histC > histC[1] and histC[1] < histC[2]
histTurnDn = histC < histC[1] and histC[1] > histC[2]
longGo  = phase == 3  and histTurnUp
shortGo = phase == -3 and histTurnDn

// ─── Display ─────────────────────────────────────────────────────────
f_phaseShort(int p) =>
    switch p
        2  => "EST BULL"
        3  => "BULL PB"
        4  => "WEAK BULL"
        1  => "EMRG BULL"
        -1 => "EMRG BEAR"
        -2 => "EST BEAR"
        -3 => "BEAR RALLY"
        -4 => "WEAK BEAR"
        => "CHOP"

f_phaseColor(int p) =>
    switch p
        2  => #26a69a
        3  => #9ccc65
        4  => #ffb74d
        1  => #4dd0e1
        -1 => #ce93d8
        -2 => #ef5350
        -3 => #f48fb1
        -4 => #ff8a65
        => color.gray

f_tfLabel(string tf) =>
    float m = str.tonumber(tf)
    na(m) ? tf : m % 60 == 0 ? str.tostring(m / 60, "#") + "H" : str.tostring(m, "#") + "m"

histColor = histC >= 0 ? (histC > histC[1] ? color.new(#26a69a, 0) : color.new(#26a69a, 55)) : (histC < histC[1] ? color.new(#ef5350, 0) : color.new(#ef5350, 55))
plot(histC, "Histogram (chart TF)", style = plot.style_columns, color = histColor)
plot(ppoC, "PPO (chart TF)",    color = color.new(#2962ff, 0))
plot(sigC, "Signal (chart TF)", color = color.new(#ff6d00, 0))
hline(0, "Zero", color = color.new(color.gray, 50))

bgcolor(color.new(f_phaseColor(phase), 87), title = "Phase background")

plotshape(showTiming and longGo,  "Long timing",  shape.triangleup,   location.belowbar, color = color.new(#26a69a, 0), size = size.small, force_overlay = true)
plotshape(showTiming and shortGo, "Short timing", shape.triangledown, location.abovebar, color = color.new(#ef5350, 0), size = size.small, force_overlay = true)

cDim = color.silver
f_gridRow(table tb, int row, string tf, int p) =>
    act = f_action(p)
    table.cell(tb, 0, row, f_tfLabel(tf), text_color = cDim, text_size = txtSize)
    table.cell(tb, 1, row, f_phaseShort(p), text_color = f_phaseColor(p), text_size = txtSize)
    table.cell(tb, 2, row, act == 1  ? "●" : "", text_color = #26a69a, text_size = txtSize)
    table.cell(tb, 3, row, act == -1 ? "●" : "", text_color = #ef5350, text_size = txtSize)
    table.cell(tb, 4, row, act == 0  ? "●" : "", text_color = cDim, text_size = txtSize)

var table t = table.new(position.top_right, 5, 8, bgcolor = color.new(#131722, 15), border_width = 1, border_color = color.new(color.gray, 75))
if showTable and barstate.islast
    table.cell(t, 0, 0, "TF",    text_color = color.white, text_size = txtSize)
    table.cell(t, 1, 0, "PHASE", text_color = color.white, text_size = txtSize)
    table.cell(t, 2, 0, "L", text_color = #26a69a, text_size = txtSize)
    table.cell(t, 3, 0, "S", text_color = #ef5350, text_size = txtSize)
    table.cell(t, 4, 0, "H", text_color = cDim, text_size = txtSize)
    f_gridRow(t, 1, tfT1, ph1)
    f_gridRow(t, 2, tfT2, ph2)
    f_gridRow(t, 3, tfT3, ph3)
    f_gridRow(t, 4, tfT4, ph4)
    majorColor = majorBias == 1 ? #26a69a : majorBias == -1 ? #ef5350 : color.gray
    majorTxt = (majorBias == 1 ? (netPct >= strongTh ? "BULL " : "LEAN BULL ") : majorBias == -1 ? (netPct <= -strongTh ? "BEAR " : "LEAN BEAR ") : "MIXED ") + str.tostring(netPct, "#") + "%"
    table.cell(t, 0, 5, "MAJOR", text_color = color.white, text_size = txtSize)
    table.cell(t, 1, 5, majorTxt, text_color = #131722, bgcolor = majorColor, text_size = txtSize)
    table.cell(t, 2, 5, majorBias == 1  ? "●" : "", text_color = #26a69a, text_size = txtSize)
    table.cell(t, 3, 5, majorBias == -1 ? "●" : "", text_color = #ef5350, text_size = txtSize)
    table.cell(t, 4, 5, majorBias == 0  ? "●" : "", text_color = cDim, text_size = txtSize)
    timingTxt = phase == 3 ? (longGo ? "▲ LONG TIMING NOW" : "wait chart hist turn ▲") : phase == -3 ? (shortGo ? "▼ SHORT TIMING NOW" : "wait chart hist turn ▼") : "—"
    table.cell(t, 0, 6, "Timing", text_color = cDim, text_size = txtSize)
    table.cell(t, 1, 6, timingTxt, text_color = longGo ? #26a69a : shortGo ? #ef5350 : cDim, text_size = txtSize)
    if timeframe.in_seconds() >= timeframe.in_seconds(tfMid)
        table.cell(t, 0, 7, "⚠", text_color = #ffb74d, text_size = txtSize)
        table.cell(t, 1, 7, "chart TF ≥ phase TF — view lower TF", text_color = #ffb74d, text_size = txtSize)

// ─── Alerts ──────────────────────────────────────────────────────────
alertcondition(phase != phase[1], "Phase changed", "MACD Trend Phase changed")
alertcondition(majorBias != majorBias[1], "Major bias changed", "MACD Phase MTF: major weighted bias flipped")
alertcondition(longGo,  "Long timing",  "Bull Pullback phase + chart histogram turned up")
alertcondition(shortGo, "Short timing", "Bear Rally phase + chart histogram turned down")
````
