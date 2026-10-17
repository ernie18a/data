# AetherEdge - Adaptive Trend Bandit

- url: https://www.tradingview.com/script/9tSQp67Y/
- type: indicator
- pine_id: PUB;b90374bc7af44009a30157dd94d0e5ae
- version: 1.0

## Description

🖊️ Overview

AE-ATB is an adaptive SuperTrend whose ATR multiplier is chosen by a learning bandit. A fixed-multiplier SuperTrend is too tight in calm markets and too loose in volatile ones. AE-ATB first discovers volatility regimes with online k-means, then a contextual bandit (UCB) learns which ATR multiplier has actually paid in each regime. It does not just switch the multiplier with volatility — it learns the best one from reward.

🔶 Key Features

Streaming k-means sorts relative volatility into calm / normal / volatile regimes (not hard-coded thresholds)
A contextual multi-armed bandit (UCB) learns the best ATR multiplier per regime from realized return
A time-varying adaptive SuperTrend that tightens or widens by regime automatically
Direction-colored line and fill, with BUY/SELL signals on trend flips
A gold HUD showing trend, volatility regime, selected multiplier, learned best multiplier, arm value, and pull count
Deterministic exploration (UCB) — identical across reloads, no repaint

🧠 Technical Architecture

k-means (unsupervised): relative volatility = ATR / SMA(ATR) is the feature; three centroids update by competitive learning (only the winning centroid moves, c += lr·(x − c)). Centroid order ranks calm/normal/volatile.
UCB bandit (RL): candidate ATR multipliers (base, base+step, …) are the arms and the volatility cluster is the context. Each (context, arm) value Q is an incremental mean; selection is UCB1: argmax(Q + c·√(ln(total pulls)/pulls)), prioritizing untried arms while balancing exploration and exploitation. Reward = held direction × realized return (ATR units), so multipliers that kept us on the right side of the move score higher.
Adaptive SuperTrend: standard bands = hl2 ± (selected multiplier × ATR), updated each bar with the selected multiplier; direction flips on a break of the active band.
Honest scope: online k-means plus a UCB contextual bandit. SuperTrend is a public concept; this is not a neural network and not a crystal ball.

⚙️ Recommended Settings & Tuning Guide

Key parameters: ATR length, volatility baseline length, multiplier base/step/count, ucbC (exploration), warmup.
Raise ucbC → more exploration (tries more multipliers); lower → more exploitation (sticks to the learned best)
Match the multiplier range (base … base + step×(count−1)) to the instrument's volatility character
Crypto starting points (tune on your chart):
BTC / ETH (1H–4H): defaults are the baseline (base 1.5, step 0.5, 5 arms)
SOL / XRP and high-vol alts: base 2.0 / step 0.5 for a wider range to avoid wick stop-outs
Scalping (5–15m): shorter ATR length, slightly tighter multiplier range
Swing (daily): wider multiplier range, longer warmup so each regime is learned
Right after a new regime appears, behavior is unsettled until each multiplier has been tried once (UCB exploration)

💡 How to Use in Practice

Trend-following: ride the line color and BUY/SELL; a larger multiplier means a roomier trail, a smaller one a tighter trail
Reading the regime: in VOLATILE the multiplier widens to avoid fakeout stop-outs; in CALM it tightens to get on board sooner — automatic adaptation
Best-multiplier panel: shows the learned best multiplier for the current regime, useful as a manual-trail reference
Multi-timeframe: higher-timeframe AE-ATB for the trend, lower for timing
Combinations: pair with AE-QUORUM's directional probability or AE-VECTOR's target band, and let AE-ATB's trail run the winner

⚠️ Important Notes

Learning period: no signals fire until warmup bars; the bandit needs time to learn each regime's multiplier
Learning reset: changing inputs, symbol, or timeframe re-learns the centroids and arm values
Multiplier moves while exploring: early on the multiplier shifts and the adaptive SuperTrend can jump or whipsaw (it settles as pulls accumulate)
Trend-following's nature: in ranges it can suffer repeated stop-outs — use the regime read and position sizing together

🚨 Disclaimer

This indicator is for educational and informational purposes only and is not financial advice or a recommendation to buy or sell. No method guarantees future profits; past performance does not indicate future results, and trading carries the risk of loss. All trading decisions are your own — use proper backtesting and disciplined risk management.

## Source Code

````pine
// ============================================================================
//  AetherEdge - Adaptive Trend Bandit  (AE-ATB)  |  AetherEdge Series
//  Adaptive SuperTrend whose ATR multiplier is chosen by a learning bandit
//
//  A classic SuperTrend uses one fixed ATR multiplier, which is too tight in
//  calm regimes and too loose in volatile ones. AE-ATB makes the multiplier
//  adaptive through two genuinely-implemented learning layers:
//
//    * Unsupervised : STREAMING K-MEANS clusters relative volatility into
//      regimes online (competitive-learning centroid updates), so "calm",
//      "normal" and "volatile" are discovered from the data, not hard-coded.
//
//    * RL : a CONTEXTUAL MULTI-ARMED BANDIT (UCB1) treats each candidate ATR
//      multiplier as an arm and each volatility cluster as the context. It
//      learns, from realized trend-following reward, which multiplier performs
//      best in each regime -- exploration is deterministic (UCB), so it is
//      reproducible and never repaints.
//
//  The result is a SuperTrend that tightens or widens per regime based on what
//  has actually paid. Honest scope: online k-means + a UCB contextual bandit --
//  not a neural net, not a guarantee. Signals gate on barstate.isconfirmed.
// ============================================================================

//@version=6
indicator("AetherEdge - Adaptive Trend Bandit", "AE-ATB", overlay = true, max_labels_count = 200)

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
grpST = "SuperTrend"
atrLen   = input.int(10, "ATR length", minval = 1, group = grpST)

grpK = "Volatility clustering (streaming k-means, 3 regimes)"
volMaLen = input.int(50, "Volatility baseline length", minval = 2, group = grpK, tooltip = "Relative volatility = ATR / SMA(ATR). Clustered online into calm / normal / volatile regimes.")
kLR      = input.float(0.02, "Centroid learning rate", minval = 0.001, maxval = 0.5, step = 0.005, group = grpK)

grpB = "Bandit (ATR multiplier selection, UCB)"
multBase = input.float(1.5, "Smallest multiplier", minval = 0.5, step = 0.1, group = grpB)
multStep = input.float(0.5, "Multiplier step", minval = 0.1, step = 0.1, group = grpB)
nArms    = input.int(5, "Candidate multipliers", minval = 2, maxval = 8, group = grpB, tooltip = "Arms = base, base+step, base+2*step, ...")
ucbC     = input.float(1.0, "UCB exploration constant", minval = 0.0, step = 0.1, group = grpB)
warmup   = input.int(120, "Warmup bars", minval = 20, group = grpB)

grpV = "Visual"
showFill   = input.bool(true, "Shade trend", group = grpV)
showMarkers= input.bool(true, "Show flip signals", group = grpV)

grpUI = "Dashboard"
showHUD = input.bool(true, "Show HUD", group = grpUI)
hudSize = input.string("normal", "HUD size", options = ["tiny","small","normal","large"], group = grpUI)

// ----------------------------------------------------------------------------
//  HELPERS
// ----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_mult(int a) => multBase + a * multStep

// UCB1 arm selection within a context (cluster). Unplayed arms get priority.
f_ucb(array<float> q, array<int> cnt, int c, int n, float cst) =>
    int total = 0
    for a = 0 to n - 1
        total += array.get(cnt, c * n + a)
    int best = 0
    float bestV = -1e18
    for a = 0 to n - 1
        idx = c * n + a
        cn  = array.get(cnt, idx)
        v   = cn < 1 ? 1e12 : array.get(q, idx) + cst * math.sqrt(math.log(total + 1) / cn)
        if v > bestV
            bestV := v
            best := a
    best

// Greedy best arm in a context (for display).
f_bestArm(array<float> q, int c, int n) =>
    int best = 0
    float bv = -1e18
    for a = 0 to n - 1
        qv = array.get(q, c * n + a)
        if qv > bv
            bv := qv
            best := a
    best

// ----------------------------------------------------------------------------
//  STREAMING K-MEANS  (relative volatility -> 3 regimes)
// ----------------------------------------------------------------------------
atr     = ta.atr(atrLen)
atrSafe = math.max(nz(atr, nz(ta.tr, close * 0.001)), 1e-8)
volFeat = atrSafe / math.max(ta.sma(atrSafe, volMaLen), 1e-8)      // relative volatility (~1 baseline)

var array<float> cent = array.new_float(3, na)
if na(array.get(cent, 0))
    array.set(cent, 0, 0.6)
    array.set(cent, 1, 1.0)
    array.set(cent, 2, 1.5)

// Assign to nearest centroid.
int cl = 0
float bestD = 1e18
for j = 0 to 2
    d = math.abs(volFeat - array.get(cent, j))
    if d < bestD
        bestD := d
        cl := j

// Online (competitive-learning) update of the winning centroid.
if barstate.isconfirmed
    array.set(cent, cl, array.get(cent, cl) + kLR * (volFeat - array.get(cent, cl)))

// Rank the current cluster by centroid value (0 = calm, 1 = normal, 2 = volatile).
int volRank = 0
for j = 0 to 2
    if array.get(cent, j) < array.get(cent, cl)
        volRank += 1

// ----------------------------------------------------------------------------
//  CONTEXTUAL BANDIT  (UCB selects the ATR multiplier per regime)
// ----------------------------------------------------------------------------
var array<float> qTab = array.new_float(3 * nArms, 0.0)
var array<int>   cTab = array.new_int(3 * nArms, 0)
var int cPrev = na
var int aPrev = na

armSel  = f_ucb(qTab, cTab, cl, nArms, ucbC)
multSel = f_mult(armSel)

// ----------------------------------------------------------------------------
//  ADAPTIVE SUPERTREND  (time-varying multiplier = bandit's choice)
// ----------------------------------------------------------------------------
hl2v = (high + low) / 2.0
upperBasic = hl2v + multSel * atrSafe
lowerBasic = hl2v - multSel * atrSafe

var float upper = na
var float lower = na
var int   dir   = 1

upper := na(upper[1]) ? upperBasic : (upperBasic < upper[1] or close[1] > upper[1]) ? upperBasic : upper[1]
lower := na(lower[1]) ? lowerBasic : (lowerBasic > lower[1] or close[1] < lower[1]) ? lowerBasic : lower[1]
dir   := na(dir[1]) ? 1 : (dir[1] == 1 and close < lower[1]) ? -1 : (dir[1] == -1 and close > upper[1]) ? 1 : dir[1]

stLine = dir == 1 ? lower : upper
flip   = dir != dir[1]
flipUp = flip and dir == 1
flipDn = flip and dir == -1

// ----------------------------------------------------------------------------
//  BANDIT REWARD UPDATE  (realized trend-following payoff of the prior arm)
// ----------------------------------------------------------------------------
ret = nz((close - close[1]) / atrSafe)

if barstate.isconfirmed and not na(cPrev) and not na(aPrev)
    r = f_clamp(nz(dir[1]) * ret, -5.0, 5.0)          // reward = direction held * realized move
    idx = cPrev * nArms + aPrev
    nC  = array.get(cTab, idx) + 1
    array.set(cTab, idx, nC)
    array.set(qTab, idx, array.get(qTab, idx) + (r - array.get(qTab, idx)) / nC)   // incremental mean

if barstate.isconfirmed
    cPrev := cl
    aPrev := armSel

warmOK = bar_index > warmup

// ----------------------------------------------------------------------------
//  PLOTS
// ----------------------------------------------------------------------------
stCol = dir == 1 ? cBull : cBear
upPlot = plot(dir == 1 ? stLine : na, "Up trend", color = cBull, linewidth = 2, style = plot.style_linebr)
dnPlot = plot(dir == -1 ? stLine : na, "Down trend", color = cBear, linewidth = 2, style = plot.style_linebr)
cPlot  = plot(showFill ? close : na, "", color = na, display = display.none)
fill(cPlot, upPlot, color = showFill and dir == 1 ? color.new(cBull, 88) : na, title = "Up fill")
fill(cPlot, dnPlot, color = showFill and dir == -1 ? color.new(cBear, 88) : na, title = "Down fill")

plotshape(showMarkers and warmOK and flipUp and barstate.isconfirmed, title = "Buy",  style = shape.triangleup,   location = location.belowbar, color = cBull, size = size.small, text = "BUY",  textcolor = cBull)
plotshape(showMarkers and warmOK and flipDn and barstate.isconfirmed, title = "Sell", style = shape.triangledown, location = location.abovebar, color = cBear, size = size.small, text = "SELL", textcolor = cBear)

// ----------------------------------------------------------------------------
//  HUD DASHBOARD  (gold frame)
// ----------------------------------------------------------------------------
f_txtSize() => hudSize == "tiny" ? size.tiny : hudSize == "small" ? size.small : hudSize == "large" ? size.large : size.normal

regTxt  = volRank == 0 ? "CALM" : volRank == 1 ? "NORMAL" : "VOLATILE"
bestArm = f_bestArm(qTab, cl, nArms)
pulls   = array.get(cTab, cl * nArms + armSel)
qNow    = array.get(qTab, cl * nArms + armSel)

var table hud = table.new(position.top_right, 2, 9, bgcolor = cBg1, frame_color = cGold, frame_width = 2, border_color = color.new(cGold, 60), border_width = 1)

if showHUD and barstate.islast
    ts = f_txtSize()
    table.cell(hud, 0, 0, "AE-ATB", text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 0, "k-MEANS + BANDIT", text_color = cWait, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 0, 1, "Trend",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 1, dir == 1 ? "UP" : "DOWN", text_color = stCol, text_size = ts)
    table.cell(hud, 0, 2, "Vol regime",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 2, regTxt + " (" + str.tostring(volFeat, "#.##") + ")", text_color = volRank == 2 ? cBear : volRank == 0 ? cBull : cTxt, text_size = ts)
    table.cell(hud, 0, 3, "Multiplier",text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 3, str.tostring(multSel, "#.#"), text_color = cGold, text_size = ts)
    table.cell(hud, 0, 4, "Best mult", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 4, str.tostring(f_mult(bestArm), "#.#"), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 5, "Arm value", text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 5, str.tostring(qNow, "#.###"), text_color = qNow >= 0 ? cBull : cBear, text_size = ts)
    table.cell(hud, 0, 6, "Pulls",     text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 6, str.tostring(pulls), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 7, "ATR",       text_color = cTxt, text_size = ts)
    table.cell(hud, 1, 7, str.tostring(atrSafe, format.mintick), text_color = cTxt, text_size = ts)
    table.cell(hud, 0, 8, "Model",     text_color = cGold, bgcolor = cBg0, text_size = ts)
    table.cell(hud, 1, 8, warmOK ? "live" : "learning", text_color = warmOK ? cBull : cWait, bgcolor = cBg0, text_size = ts)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(flipUp and barstate.isconfirmed, "AE-ATB Buy",  "AE-ATB trend flipped up")
alertcondition(flipDn and barstate.isconfirmed, "AE-ATB Sell", "AE-ATB trend flipped down")

if warmOK and flipUp
    alert("AE-ATB BUY | mult " + str.tostring(multSel, "#.#") + " | regime " + regTxt, alert.freq_once_per_bar_close)
if warmOK and flipDn
    alert("AE-ATB SELL | mult " + str.tostring(multSel, "#.#") + " | regime " + regTxt, alert.freq_once_per_bar_close)
````
