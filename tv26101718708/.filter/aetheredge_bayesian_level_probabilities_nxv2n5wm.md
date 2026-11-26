# AetherEdge - Bayesian Level Probabilities

- url: https://www.tradingview.com/script/nxv2N5Wm/
- type: indicator
- pine_id: PUB;95ecd1a5da2145d7876d8456c0a80790
- version: 1.0

## Description

🖊️ Overview

AE-BLP presents the probability of statistical events — prior-day high/low taps, gap fills — with Bayesian estimation (credible intervals) and conditioning on context. Most statistical tools quote a raw historical frequency ("the prior high is tapped 70% of the time"), which hides two things: the uncertainty around that number, and how it changes with context. AE-BLP models each event as a Beta-Bernoulli posterior and conditions it on context (prior-period direction, gap direction) to show P(event | context) with a credible interval.

🔶 Key Features

Plots the prior completed period's high (PDH), low (PDL), and close (fixed during the current period — no repaint)
Bayesian probabilities — posterior mean + credible interval (80/90/95% selectable); a decay weights recent periods more
Conditional probabilities — bucketed by context known at the period's open, giving P(event | context)
Three events: PDH tap, PDL tap, gap fill
A signal to fade an unfilled gap toward the prior close when the fill probability clears a threshold
A gold HUD with context, each probability [credible interval], the favored level, and the period count; probability labels on the levels too
Levels come from the last closed period and outcomes resolve at period close — no repaint

🧠 Technical Architecture

Levels: request.security pulls the prior completed period's H/L/C/O (lookahead_off, fixed during the current period).
Event tracking: within the current period it flags "high reached the prior high," "low reached the prior low," and "price returned to the prior close," and observes the finalized outcomes when the period rolls over.
Bayesian (Beta-Bernoulli): each (event × context) is a Beta(α, β) posterior; α/β update per observation (with a decay discounting the past). Posterior mean = α/(α+β); the credible interval is a normal approximation using the posterior variance αβ/((α+β)²(α+β+1)). The prior is Beta(priorStrength, priorStrength).
Conditioning: the bucket is chosen from context known at the period's open — prior-period direction (bullish/bearish) for the high/low taps, gap direction (up/down) for the gap fill — so you read an un-blended P(event | context).
Honest scope: Beta-Bernoulli posteriors with a normal-approximation credible interval. Not deep learning, and not a guarantee of probability.

⚙️ Recommended Settings & Tuning Guide

Key parameters: statistics period (periodTF), prior strength, evidence decay, credible interval, min gap, gap-fill probability threshold.
Set periodTF higher than the chart (e.g., D on a 15m chart = prior day's high/low)
Lower decay → faster adaptation to recent regime changes; 1.0 → weights all history equally
Raise prior strength → more conservative when data is scarce (pulls toward 0.5)
Crypto starting points (tune on your chart):
BTC / ETH (5m–1H chart, periodTF = D): defaults are the baseline (decay 0.99, 90% CI)
SOL / XRP and high-vol alts: decay 0.97 to track regime shifts
In 24-hour markets gaps are rare, so gap-fill statistics accumulate mainly around weekend opens
For stable long-run statistics use decay 1.0; to favor recent behavior ~0.95
No signals until the period count reaches the minimum (for a trustworthy posterior)

💡 How to Use in Practice

Daily roadmap: P(tap PDH) and P(tap PDL) show which level price is more likely to reach today
Reading the interval: a narrow interval = confident with ample data; wide = uncertain with few samples
Gap fade: after a gap, if P(fill | direction) is high, target the move back toward the prior close (the signal assists)
Context matters: tap probabilities differ after a bullish vs bearish prior day — read alongside the HUD context
Tapped display: if a level is already tapped/filled it shows status instead of a probability — focus on the remaining level
Combinations: pair with AE-OBQ's high-quality zones or AE-AMF's big-picture momentum, and factor BLP's probabilities into how likely a level is to be reached

⚠️ Important Notes

Learning period: no signals until enough periods accumulate; the posterior needs several periods to spin up
Learning reset: changing inputs, symbol, or period settings rebuilds the posteriors
Normal-approximation limits: when probabilities are near 0/1 or observations are very few, the credible interval is approximate (treat as a guide)
Probability, not a guarantee: even high-probability events can fail to occur — this is a first-order statistical tendency, so use stops and position sizing

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Bayesian Level Probabilities  (AE-BLP)  |  AetherEdge Series
//  Conditional probabilities for statistical levels, estimated the Bayesian way
//
//  Statistical-level tools usually quote a raw historical frequency ("the prior
//  high gets tapped 70% of the time"). That hides two things: how much
//  uncertainty is around that number, and how it changes with context. AE-BLP
//  fixes both:
//
//    * Bayesian : each event (prior-period high tapped, prior-period low tapped,
//      gap filled) is modeled as a BETA-BERNOULLI posterior. You get the
//      posterior mean AND a credible interval, with a decay so recent periods
//      weigh more -- a probability that honestly shows its confidence.
//
//    * Conditional : every probability is bucketed by CONTEXT known at the
//      period's open -- the prior period's direction (for the high/low taps) and
//      the gap direction (for the gap fill) -- so you read P(event | context),
//      not a blended average.
//
//  Honest scope: Beta-Bernoulli posteriors with a normal-approximation credible
//  interval -- not a neural net, not a guarantee. No-repaint: prior levels come
//  from the last CLOSED period; outcomes resolve at period close; signals gate
//  on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - Bayesian Level Probabilities", "AE-BLP", overlay = true, max_labels_count = 100)

// ----------------------------------------------------------------------------
//  THEME / PALETTE  (AetherEdge gold-frame HUD)
// ----------------------------------------------------------------------------
cGold    = #d4af37
cBg0     = #080b0a
cBg1     = #0f1614
cTxt     = #eef2f0
cBull    = #26a69a
cBear    = #ef5350
cWait    = #8d99a6

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
grpP = "Statistics period"
periodTF = input.timeframe("D", "Period (set higher than chart)", group = grpP, tooltip = "Levels reference the previous completed period (e.g., yesterday on an intraday chart).")
atrLen   = input.int(14, "ATR length", minval = 1, group = grpP)
gapMin   = input.float(0.05, "Min gap (ATR) to count", minval = 0.0, step = 0.05, group = grpP)

grpB = "Bayesian estimation"
priorStrength = input.float(1.0, "Prior strength (pseudo-counts)", minval = 0.1, step = 0.5, group = grpB, tooltip = "Beta(prior, prior). 1 = uniform prior.")
decay   = input.float(0.99, "Evidence memory (decay)", minval = 0.8, maxval = 1.0, step = 0.01, group = grpB, tooltip = "Lower = recent periods dominate. 1.0 = never forgets.")
ciPct   = input.string("90%", "Credible interval", options = ["80%","90%","95%"], group = grpB)
minObs  = input.int(15, "Min periods before signals", minval = 3, group = grpB)

grpS = "Signals (gap fade)"
probThr = input.float(0.60, "Min gap-fill probability", minval = 0.5, maxval = 0.95, step = 0.01, group = grpS)

grpV = "Visual"
showLevels = input.bool(true, "Plot levels", group = grpV)
showLabels = input.bool(true, "Label probabilities", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("small", "Table size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_pct(float x) => str.tostring(math.round(x * 100))
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

zCI = ciPct == "80%" ? 1.282 : ciPct == "95%" ? 1.960 : 1.645

// Beta-Bernoulli posterior: mean and a normal-approximation credible interval.
f_post(float a, float b, float z) =>
    n = a + b
    m = a / math.max(n, 1e-8)
    v = (a * b) / (math.max(n, 1e-8) * math.max(n, 1e-8) * (n + 1.0))
    sd = math.sqrt(math.max(v, 0.0))
    [m, f_clamp(m - z * sd, 0.0, 1.0), f_clamp(m + z * sd, 0.0, 1.0), n]

// ----------------------------------------------------------------------------
//  PERIOD LEVELS  (prior completed period -> no repaint)
// ----------------------------------------------------------------------------
[priorH, priorL, priorC, priorO] = request.security(syminfo.tickerid, periodTF, [high[1], low[1], close[1], open[1]], lookahead = barmerge.lookahead_off)

atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)
newP    = time(periodTF) != time(periodTF)[1]

// ----------------------------------------------------------------------------
//  STATE  (Beta counts: index = event*2 + ctx ; events 0=PDH,1=PDL,2=GAP)
// ----------------------------------------------------------------------------
float a0 = math.max(priorStrength, 0.1)
var array<float> alpha = array.new_float(6, na)
var array<float> beta  = array.new_float(6, na)
if na(array.get(alpha, 0))
    for k = 0 to 5
        array.set(alpha, k, a0)
        array.set(beta, k, a0)

var bool  active   = false
var float pOpen    = na
var int   ctxDir   = 0          // prior-period direction bucket for THIS period (0=down,1=up)
var int   ctxGap   = -1         // gap direction bucket (0=down,1=up,-1=none)
var bool  tHi      = false
var bool  tLo      = false
var bool  gFill    = false
var bool  signaled = false

f_betaUpdate(int idx, bool success) =>
    a = a0 + decay * (array.get(alpha, idx) - a0) + (success ? 1.0 : 0.0)
    b = a0 + decay * (array.get(beta, idx) - a0) + (success ? 0.0 : 1.0)
    array.set(alpha, idx, a)
    array.set(beta, idx, b)

// On a new period: resolve the just-completed period, then re-arm for the new one.
if barstate.isconfirmed and newP
    if active
        f_betaUpdate(0 * 2 + ctxDir, tHi)
        f_betaUpdate(1 * 2 + ctxDir, tLo)
        if ctxGap != -1
            f_betaUpdate(2 * 2 + ctxGap, gFill)
    // re-arm for the new period (prior* now reflect the period that just closed)
    pOpen  := open
    ctxDir := (priorC - priorO) >= 0 ? 1 : 0
    gd = open - priorC
    ctxGap := math.abs(gd) > gapMin * atrSafe ? (gd > 0 ? 1 : 0) : -1
    tHi := false
    tLo := false
    gFill := false
    signaled := false
    active := true

// Within the period: accumulate event outcomes vs the prior level.
if barstate.isconfirmed and active
    if high >= priorH
        tHi := true
    if low <= priorL
        tLo := true
    if ctxGap == 1 and low <= priorC
        gFill := true
    if ctxGap == 0 and high >= priorC
        gFill := true

// ----------------------------------------------------------------------------
//  CURRENT-PERIOD CONDITIONAL PROBABILITIES
// ----------------------------------------------------------------------------
[mHi, loHi, hiHi, nHi] = f_post(array.get(alpha, 0 * 2 + ctxDir), array.get(beta, 0 * 2 + ctxDir), zCI)
[mLo, loLo, hiLo, nLo] = f_post(array.get(alpha, 1 * 2 + ctxDir), array.get(beta, 1 * 2 + ctxDir), zCI)
gi = ctxGap == -1 ? 0 : ctxGap
[mGap, loGap, hiGap, nGap] = f_post(array.get(alpha, 2 * 2 + gi), array.get(beta, 2 * 2 + gi), zCI)

totalObs = (array.get(alpha, 0) + array.get(beta, 0) - 2 * a0) + (array.get(alpha, 2) + array.get(beta, 2) - 2 * a0) + (array.get(alpha, 3) + array.get(beta, 3) - 2 * a0)

// ----------------------------------------------------------------------------
//  SIGNALS  (fade an unfilled gap toward the prior close when fill is likely)
// ----------------------------------------------------------------------------
warmOK = totalObs >= minObs
longSig  = barstate.isconfirmed and warmOK and active and ctxGap == 0 and not gFill and not signaled and mGap > probThr   // gap down -> expect fill up
shortSig = barstate.isconfirmed and warmOK and active and ctxGap == 1 and not gFill and not signaled and mGap > probThr   // gap up   -> expect fill down
if longSig or shortSig
    signaled := true

// ----------------------------------------------------------------------------
//  VISUALS
// ----------------------------------------------------------------------------
plot(showLevels ? priorH : na, "Prior high", color = color.new(cBear, 30), linewidth = 1, style = plot.style_stepline)
plot(showLevels ? priorL : na, "Prior low",  color = color.new(cBull, 30), linewidth = 1, style = plot.style_stepline)
plot(showLevels ? priorC : na, "Prior close",color = color.new(cGold, 40), linewidth = 1, style = plot.style_stepline)

plotshape(longSig,  title = "Long",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "FILL", textcolor = cBull)
plotshape(shortSig, title = "Short", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "FILL", textcolor = cBear)

var label lblH = na
var label lblL = na
var label lblC = na
if showLabels and barstate.islast
    if na(lblH)
        lblH := label.new(bar_index + 3, priorH, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cBear, 20), textcolor = cBg0, size = size.small)
        lblL := label.new(bar_index + 3, priorL, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cBull, 20), textcolor = cBg0, size = size.small)
        lblC := label.new(bar_index + 3, priorC, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cGold, 20), textcolor = cBg0, size = size.small)
    label.set_xy(lblH, bar_index + 3, priorH)
    label.set_text(lblH, "PDH " + (tHi ? "tapped" : f_pct(mHi) + "%"))
    label.set_xy(lblL, bar_index + 3, priorL)
    label.set_text(lblL, "PDL " + (tLo ? "tapped" : f_pct(mLo) + "%"))
    label.set_xy(lblC, bar_index + 3, priorC)
    label.set_text(lblC, ctxGap == -1 ? "PC" : "Gap fill " + (gFill ? "done" : f_pct(mGap) + "%"))

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
ctxTxt = (ctxDir == 1 ? "prior UP" : "prior DN") + (ctxGap == 1 ? ", gap up" : ctxGap == 0 ? ", gap dn" : "")

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-BLP", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "BAYES LEVELS", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Context",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, ctxTxt,     text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 2, "P tap PDH",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, tHi ? "tapped" : f_pct(mHi) + "% [" + f_pct(loHi) + "-" + f_pct(hiHi) + "]", text_color = tHi ? cBull : cTxt, text_size = ts)
    table.cell(hud, 0, 3, "P tap PDL",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, tLo ? "tapped" : f_pct(mLo) + "% [" + f_pct(loLo) + "-" + f_pct(hiLo) + "]", text_color = tLo ? cBull : cTxt, text_size = ts)
    table.cell(hud, 0, 4, "P gap fill",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, ctxGap == -1 ? "no gap" : (gFill ? "filled" : f_pct(mGap) + "% [" + f_pct(loGap) + "-" + f_pct(hiGap) + "]"), text_color = ctxGap == -1 ? cWait : gFill ? cBull : cTxt, text_size = ts)
    table.cell(hud, 0, 5, "PDH n",    text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(math.round(nHi)), text_color = cWait, text_size = ts)
    table.cell(hud, 0, 6, "Favored",  text_color = cTxt, text_size = ts)
    fav = (not tHi and mHi >= mLo) ? "PDH " + f_pct(mHi) + "%" : (not tLo ? "PDL " + f_pct(mLo) + "%" : "-")
    table.cell(hud, 1, 6, fav, text_color = cGold, text_size = ts)
    table.cell(hud, 0, 7, "Periods",  text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(math.round(totalObs)), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Model",    text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(longSig,  "AE-BLP Gap-fill Long",  "AE-BLP gap-down fill (up) likely")
alertcondition(shortSig, "AE-BLP Gap-fill Short", "AE-BLP gap-up fill (down) likely")

if longSig
    alert("AE-BLP LONG | gap-fill " + f_pct(mGap) + "% toward " + str.tostring(priorC, format.mintick), alert.freq_once_per_bar_close)
if shortSig
    alert("AE-BLP SHORT | gap-fill " + f_pct(mGap) + "% toward " + str.tostring(priorC, format.mintick), alert.freq_once_per_bar_close)
````
