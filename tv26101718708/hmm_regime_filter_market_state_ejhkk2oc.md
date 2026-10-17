# HMM Regime Filter | Market State

- url: https://www.tradingview.com/script/EJHKK2OC-HMM-Regime-Filter-Market-State/
- type: indicator
- pine_id: PUB;5b4d57501a544fd39f258461df02eaee
- version: 1.0

## Description

The HMM Regime Filter is a genuine Hidden Markov Model running live in Pine. Instead of trying to predict the next candle, it answers a more useful question: what state is the market in right now? It treats the market as always occupying one of three hidden regimes, Trend Up, Range, or Trend Down, and every bar it updates the probability of each one using Bayesian forward filtering. The result is a flowing probability ribbon that shows you, at a glance, not just which regime is most likely but how confident the model is about it.

This is built to be a context layer, not a trigger. Most tools tell you to buy or sell. This one tells you which kind of market you are in, so you know which of your other tools to trust. Trend-following logic tends to work when the model reads Trend Up or Trend Down. Mean-reversion and fade logic tend to work when it reads Range. Knowing the regime first is often the difference between a setup that works and the same setup in the wrong environment.

How it works under the hood. Each bar the filter combines two things: the probability of staying in or moving between regimes (the transition model), and how well current price behavior matches each regime (the evidence, modeled with Gaussian emissions that scale to the instrument automatically). The transition model is deliberately structured so that trends decay through Range rather than flipping directly from up to down, which matches how real markets usually turn.

Built for stability, not flicker. A raw regime model on a fast chart will strobe between states on every noisy bar. This one handles that three ways. Stickiness sets how strongly the model prefers to stay in its current regime, so it demands consistent evidence before switching. A confirmation rule means a new regime has to lead for several consecutive bars before it becomes official. And a dominance threshold means that when no regime is clearly ahead, the indicator reports uncertain rather than forcing a coin-flip winner. The dashboard shows how long the current regime has held, so the stability is visible at a glance.
What you see on the chart:

A glowing probability ribbon where the three regime streams flow and trade dominance. Each stream brightens as its probability rises and dims when it falls, so a decisive trend floods the pane with one color while an uncertain market sits muted and even.
Price bars colored by the confirmed regime, so the state carries onto your main chart.
A state chip at the right edge showing the current regime, its probability, and how many bars it has held.

A dashboard with live probabilities for all three states, the held-for count, and the stickiness setting.

[b]Settings worth knowing:[/b]

Stickiness is the main stability dial. Higher values produce calmer, more persistent regimes.
Confirmation bars sets how many bars a new regime must lead before it counts.
Dominance threshold sets how confident the model must be before it commits, versus showing uncertain.

Observation smoothing calms the input on noisy timeframes.

A note on timeframes. Regimes are a higher-timeframe idea. The filter is usable anywhere, but it often reads best when computed on or tuned for 15 minute or hourly structure and then used as background context while you execute on a faster chart.

Honest disclaimer. Regimes are descriptive, not predictive. This tells you the state you are most likely in, not what price will do next, and it is not a guarantee of any outcome. Calmer settings look more trustworthy but report changes a little later. That lag is the honest cost of stability, not a flaw to be tuned away. The model updates on confirmed bar closes and does not repaint. Use it as one input in your own process, alongside your own risk management.

[b]User Guide[/b]
Getting started
Add the indicator to any chart and it opens in its own pane below price. Give it a moment, since the model uses a scaling window to calibrate to the instrument, so the first stretch of bars is warm-up and the regime reads uncertain until it has enough history. The tallest, brightest stream in the ribbon is the most likely regime, and the chip at the right edge names the confirmed regime, its probability, and how long it has held. Your price bars are colored by the confirmed regime by default, so the state shows on your main chart. Treat it as context: before taking a setup, glance at the regime to know what kind of market you are in.

[b]What the pane shows[/b]
The probability ribbon is three stacked streams that always sum to the full height of the pane, teal for Trend Up at the bottom, the Range color in the middle, pink for Trend Down at the top, with each stream's thickness being that regime's probability. Brightness equals confidence: each stream lights up as its probability rises and fades as it falls, so a one-sided market produces one bright flooded color while a genuinely undecided market shows three muted, roughly equal streams. The seams between streams are lit, the dark background and faint 25/50/75 grid lines make the streams pop, and the floating state chip shows the current regime, its probability, and the number of bars it has held.

[b]Reading the dashboard (top right of the pane)[/b]
Regime is the current confirmed state. Held for is how many bars it has been official, where a large number means a stable regime and a number that keeps resetting means choppy or transitional conditions. P(up), P(range), and P(down) are the live probabilities, and these are the true model numbers rather than the visually smoothed ribbon, so they are the ones to trust. Stickiness shows your main stability setting for reference.

[b]Every setting explained[/b]
Model group. Observation smoothing is the smoothing applied to the normalized return before it reaches the model; higher calms noisy fast timeframes, lower feeds it faster information. Scaling window is the lookback that calibrates the model to the instrument, which is what makes the same settings behave consistently across symbols; longer is steadier and slower to adapt. Regime separation is how far apart the up and down state means sit, in standard deviations; larger makes it more demanding about what counts as a trend so it sits in Range more, smaller makes it call trends more readily.

Stability group. Stickiness is the probability of staying in the current regime each bar and the single most important dial; higher needs more consistent evidence to switch, which kills flicker. Confirmation bars is how many consecutive bars a new regime must lead before it becomes official; the ribbon probabilities still update live, this only governs when the official state, bar coloring, and chip change. Dominance threshold is how far ahead the leader must be before the model commits; if nothing clears it the state reads uncertain. Raise to be more conservative, lower to commit sooner.

Display group. Toggles for the ribbon, the dark background, the regime pane tint, price bar coloring, and the dashboard, plus the three regime colors. Ribbon smoothing is purely visual so the streams flow like liquid, and it does not change the regime logic or the dashboard numbers.

[b]Tuning recipes[/b]
Calm context layer (recommended): stickiness 0.97 to 0.985, confirmation bars 3 to 5, dominance around 0.50. Stable regimes that change only when the market genuinely shifts. More responsive read: stickiness 0.92 to 0.95, confirmation bars 2 to 3, lower observation smoothing, which catches turns earlier at the cost of more false flips. If it still flickers, raise stickiness first, then confirmation bars, then observation smoothing, and consider that the timeframe itself may be too fast. If it spends too much time in Range or uncertain, lower regime separation and lower the dominance threshold.

[b]Using it with other tools[/b]
The highest-value use is as a gate on your other signals. In Trend Up or Trend Down, favor trend-following logic like pullbacks, breakouts, and momentum continuation. In Range, favor mean-reversion logic like fading the edges, and be skeptical of breakouts. In uncertain, consider standing aside or sizing down, since the model is telling you it cannot read the market cleanly. If you run other engines, only trust a trend tool when the regime agrees, and lean on mean-reversion tools when it reads Range.

[b]Alerts[/b]
Three alerts fire on confirmed regime changes (Trend Up, Trend Down, Range). Because they key off the confirmed regime rather than raw probabilities, they are far less noisy and inherit your stickiness and confirmation settings, so calmer settings produce fewer, more meaningful alerts.

[b]How to evaluate it[/b]
Scroll back and check whether the colored regimes line up with what you would call trends and ranges by eye. Watch the Held for counter, since healthy regimes persist for a meaningful number of bars and constant resets mean your settings are too reactive for the timeframe. Best test: apply it as a filter to a strategy you already use. The question is not whether the regime predicts price, it is whether your existing setups perform better when you only take them in the matching regime.

[b]Troubleshooting[/b]
Stuck on uncertain usually means warm-up or too high a dominance threshold. Flicker is fixed by raising stickiness, then confirmation bars, then observation smoothing, or moving up a timeframe. Feeling slow to call a turn is the stability tradeoff, and there is no setting that is both instant and stable. If the ribbon and dashboard differ slightly, the ribbon is visually smoothed and the dashboard shows the true probabilities, so trust the dashboard.

[b]Honest notes[/b]
Regimes are descriptive, not predictive. The model updates on confirmed bar closes and does not repaint, which also means the live forming bar does not move the probabilities until it closes. It uses sensibly scaled fixed emission parameters rather than fully learning its transition matrix online, a deliberate choice for stability. No indicator guarantees an outcome; use it as one input alongside your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheRealDrip2Rip

//@version=6
// =============================================================================
//  HMM REGIME FILTER  |  3-State Market State (Trend Up / Range / Trend Down)
//
//  A genuine Hidden Markov Model. It assumes the market is always in one of
//  three hidden states and infers, every bar, the probability of each by
//  Bayesian forward filtering:
//      prior_j = sum_i  posterior_prev[i] * A[i][j]      (transition)
//      post_j  ∝ prior_j * Gaussian(obs | mean_j, std_j) (evidence)
//  The transition matrix A is the key to stability. Its diagonal (the
//  "stickiness") is the probability of STAYING in the current state, so a high
//  value forces the model to demand consistent evidence before it switches.
//  That, plus a confirmation rule and a dominance threshold, is what keeps it
//  from flickering bar to bar on fast timeframes.
//
//  HONEST NOTE: regimes are DESCRIPTIVE, not predictive. This tells you what
//  state you are most likely in, not what happens next. Use it as a context
//  layer (when to trust a trend tool vs a mean-reversion tool), not a trigger.
//  Calmer settings look more trustworthy but report changes later; that lag is
//  the honest cost of stability, not a bug.
// =============================================================================

indicator("HMM Regime Filter | Market State", overlay = false, precision = 0, max_labels_count = 20)

// ~~ INPUTS ===================================================================
obsLen    = input.int(4, "Observation smoothing", minval=1, group="Model",
     tooltip="EMA length on the normalized return fed to the model. Higher = calmer on noisy timeframes.")
statLen   = input.int(150, "Scaling window", minval=20, group="Model",
     tooltip="Window used to scale the model to the instrument (makes it volatility-adaptive).")
muK       = input.float(1.0, "Regime separation", minval=0.3, maxval=2.5, step=0.1, group="Model",
     tooltip="How far apart the up/down state means sit, in standard deviations of the observation.")

stick     = input.float(0.97, "Stickiness (stay probability)", minval=0.80, maxval=0.999, step=0.001, group="Stability",
     tooltip="Diagonal of the transition matrix. Higher = regimes persist and the ribbon stops flickering.")
confirmBars = input.int(3, "Confirmation bars", minval=1, maxval=20, group="Stability",
     tooltip="A new regime must lead for this many consecutive bars before it becomes official.")
domThresh = input.float(0.50, "Dominance threshold", minval=0.34, maxval=0.90, step=0.01, group="Stability",
     tooltip="The leading probability must exceed this to count as confident; otherwise the bar is 'uncertain'.")

showRibbon = input.bool(true,  "Probability ribbon", group="Display")
dispLen    = input.int(3, "Ribbon smoothing", minval=1, maxval=10, group="Display",
     tooltip="Visual smoothing of the ribbon only. Does not change the regime logic.")
darkBg     = input.bool(true,  "Dark pane background", group="Display")
tintPane   = input.bool(true,  "Tint pane by regime", group="Display")
colorBars  = input.bool(true,  "Color price bars by regime", group="Display")
showTable  = input.bool(true,  "Show dashboard", group="Display")
upC  = input.color(color.rgb(47, 230, 194), "Trend up", group="Display")
rgC  = input.color(color.rgb(150, 140, 185), "Range", group="Display")
dnC  = input.color(color.rgb(236, 72, 153), "Trend down", group="Display")

// ~~ OBSERVATION ==============================================================
atrv  = ta.atr(14)
ret   = atrv > 0 ? (close - close[1]) / atrv : 0.0
obs   = ta.ema(ret, obsLen)
sigma = ta.stdev(obs, statLen)
ready = not na(obs) and not na(sigma) and sigma > 0

gpdf(float x, float m, float s) => s <= 0 ? 0.0 : math.exp(-0.5 * math.pow((x - m) / s, 2)) / s

// ~~ FORWARD FILTER ===========================================================
// states: 0 = Trend Up, 1 = Range, 2 = Trend Down
var array<float> al = array.new<float>(3, 1.0/3.0)
if ready and barstate.isconfirmed
    a0 = array.get(al, 0)
    a1 = array.get(al, 1)
    a2 = array.get(al, 2)
    off = 1.0 - stick
    // transition A[i][j]: trends prefer to decay through Range, not flip directly
    pr0 = a0*stick + a1*(off*0.5) + a2*(off*0.25)
    pr1 = a0*(off*0.75) + a1*stick + a2*(off*0.75)
    pr2 = a0*(off*0.25) + a1*(off*0.5) + a2*stick
    mU = muK * sigma
    e0 = gpdf(obs,  mU, sigma)
    e1 = gpdf(obs, 0.0, sigma * 0.8)
    e2 = gpdf(obs, -mU, sigma)
    u0 = pr0 * e0
    u1 = pr1 * e1
    u2 = pr2 * e2
    tot = u0 + u1 + u2
    if tot > 0
        array.set(al, 0, u0/tot)
        array.set(al, 1, u1/tot)
        array.set(al, 2, u2/tot)

p0 = array.get(al, 0)
p1 = array.get(al, 1)
p2 = array.get(al, 2)
raw = p0 >= p1 and p0 >= p2 ? 0 : p1 >= p2 ? 1 : 2
pmax = array.get(al, raw)
cand = pmax >= domThresh ? raw : -1

// ~~ CONFIRMATION (official regime + time held) ===============================
var int candPrev = -1
var int streak   = 0
var int official = -1
var int tIn      = 0
if barstate.isconfirmed
    streak := (cand == candPrev and cand != -1) ? streak + 1 : (cand == -1 ? 0 : 1)
    candPrev := cand
    changed = false
    if cand != -1 and cand != official and streak >= confirmBars
        official := cand
        changed := true
    tIn := changed ? 0 : tIn + 1

regCol(int s) => s == 0 ? upC : s == 2 ? dnC : s == 1 ? rgC : color.gray
regTxt(int s) => s == 0 ? "TREND UP" : s == 2 ? "TREND DOWN" : s == 1 ? "RANGE" : "uncertain"

// ~~ RIBBON (premium) =========================================================
// raw probabilities (used by the dashboard)
up100 = p0 * 100.0
rg100 = p1 * 100.0
dn100 = p2 * 100.0

// display-only smoothing for a liquid look (does NOT affect regime logic)
sp0 = ta.ema(p0, dispLen)
sp1 = ta.ema(p1, dispLen)
sp2 = ta.ema(p2, dispLen)
sden = sp0 + sp1 + sp2
q0 = sden > 0 ? sp0 / sden : p0
q1 = sden > 0 ? sp1 / sden : p1
q2 = sden > 0 ? sp2 / sden : p2
c1 = q0 * 100.0
c2 = (q0 + q1) * 100.0

// deep dark pane so the streams glow, with a faint regime wash on top
bgcolor(darkBg ? color.new(color.rgb(10, 12, 18), 0) : na, title="Pane")
bgcolor(tintPane and official >= 0 ? color.new(regCol(official), 88) : na, title="Regime tint")
hline(25, "q1",  color=color.new(color.gray, 88))
hline(50, "mid", color=color.new(color.gray, 82))
hline(75, "q3",  color=color.new(color.gray, 88))

// brightness of each stream scales with its probability (the dominant one glows)
tUp = math.max(8,  math.round(82 - 54 * q0))
tRg = math.max(12, math.round(84 - 50 * q1))
tDn = math.max(8,  math.round(82 - 54 * q2))

b0 = plot(showRibbon ? 0.0   : na, "b0", color=na, editable=false)
bU = plot(showRibbon ? c1    : na, "bU", color=na, editable=false)
bR = plot(showRibbon ? c2    : na, "bR", color=na, editable=false)
bT = plot(showRibbon ? 100.0 : na, "bT", color=na, editable=false)
fill(b0, bU, color=showRibbon ? color.new(upC, tUp) : na, title="P(up)")
fill(bU, bR, color=showRibbon ? color.new(rgC, tRg) : na, title="P(range)")
fill(bR, bT, color=showRibbon ? color.new(dnC, tDn) : na, title="P(down)")

// luminous seams between the streams (wide glow + thin bright core)
plot(showRibbon ? c1 : na, "seam up glow", color=color.new(upC, 72), linewidth=6, editable=false)
plot(showRibbon ? c1 : na, "seam up",      color=color.new(upC, 18), linewidth=1, editable=false)
plot(showRibbon ? c2 : na, "seam dn glow", color=color.new(dnC, 72), linewidth=6, editable=false)
plot(showRibbon ? c2 : na, "seam dn",      color=color.new(dnC, 18), linewidth=1, editable=false)

barcolor(colorBars and official >= 0 ? regCol(official) : na)

// ~~ STATE CHIP ===============================================================
var label hud = na
if barstate.islast
    label.delete(hud)
    poff = official == 0 ? p0 : official == 1 ? p1 : official == 2 ? p2 : pmax
    chip = "  " + regTxt(official) + (official >= 0 ? "   " + str.tostring(poff * 100, '#') + "%   held " + str.tostring(tIn) + "b  " : "  ")
    hud := label.new(bar_index + 2, 50, chip, style=label.style_label_left, color=color.new(color.rgb(13, 16, 23), 6), textcolor=regCol(official), size=size.normal)

// ~~ DASHBOARD ================================================================
var table dash = table.new(position.top_right, 2, 7, frame_color=color.new(color.gray,50), frame_width=1)
if showTable and barstate.islast
    table.cell(dash, 0, 0, "HMM Regime Filter", text_color=color.white, bgcolor=color.new(color.rgb(60,50,90), 10), text_size=size.small)
    table.cell(dash, 1, 0, "3-state", text_color=color.white, bgcolor=color.new(color.rgb(60,50,90), 10), text_size=size.small)
    table.cell(dash, 0, 1, "Regime", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 1, regTxt(official), text_color=regCol(official), text_size=size.tiny)
    table.cell(dash, 0, 2, "Held for", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 2, official >= 0 ? str.tostring(tIn) + " bars" : "-", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 0, 3, "P(up)", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(up100, '#') + "%", text_color=upC, text_size=size.tiny)
    table.cell(dash, 0, 4, "P(range)", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 4, str.tostring(rg100, '#') + "%", text_color=rgC, text_size=size.tiny)
    table.cell(dash, 0, 5, "P(down)", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(dn100, '#') + "%", text_color=dnC, text_size=size.tiny)
    table.cell(dash, 0, 6, "Stickiness", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(stick, '#.###'), text_color=color.white, text_size=size.tiny)

// ~~ ALERTS ===================================================================
turnedUp    = official == 0 and official[1] != 0
turnedDown  = official == 2 and official[1] != 2
turnedRange = official == 1 and official[1] != 1
alertcondition(turnedUp,    "Regime: Trend Up",   "HMM Regime Filter: confirmed TREND UP.")
alertcondition(turnedDown,  "Regime: Trend Down", "HMM Regime Filter: confirmed TREND DOWN.")
alertcondition(turnedRange, "Regime: Range",      "HMM Regime Filter: confirmed RANGE.")
````
