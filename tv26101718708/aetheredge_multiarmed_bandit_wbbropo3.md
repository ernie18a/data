# AetherEdge - Multi-Armed Bandit

- url: https://www.tradingview.com/script/WbBroPO3/
- type: indicator
- pine_id: PUB;0185a291c5b4478e921d5aa1d9301c6e
- version: 1.0

## Description

🖊️ Overview

AE-MAB is a self-evolving signal allocator that treats a panel of sub-signals as the "arms" of a bandit and learns which to trust now. Each classic signal — trend, momentum, breakout, mean-reversion, MACD — carries a Bayesian Beta(α,β) posterior over its directional hit-rate, updated online with forgetting from realized hits/misses (the reward). Allocation weights come from Thompson Sampling (sampling each posterior) or UCB (mean + confidence bound), both balancing exploration of uncertain arms against exploitation of proven ones. The final signal is the credibility-weighted vote of the arms.

🔶 Key Features

Multi-armed bandit engine — runs 5 sub-signals as arms and dynamically weights toward whichever is working now.
Reward & Bayesian learning — each arm's directional hit/miss is the reward, updating a Beta(α,β) posterior online with forgetting.
Exploration & exploitation — switch between Thompson Sampling (sample the posteriors, occasionally trying uncertain arms) and UCB (mean + confidence bound).
Self-evolving beliefs — a forgetting factor weights recent performance; as the market shifts, the trusted arm quietly changes.
Credibility panel — lists each arm's direction, credibility bar (Beta posterior mean), and allocation weight, with the current lead signal glowing.
Credibility-weighted allocation — a continuous allocation (−1 to +1) of arm directions weighted by credibility is the final signal, reflected in the price background and markers.
Live statistics panel — final signal, conviction, lead arm, allocation value, bandit P&L, and forgetting factor.
Deterministic, non-repainting design — Thompson's RNG is seed-fixed (no intrabar flicker); learning on confirmed bars only, no look-ahead.

🧠 Technical Architecture

Each bar, the 5 arms emit a directional view (+1/0/−1): trend (EMA cross), momentum (RSI), breakout (Donchian), mean-reversion (z-score, contrarian), MACD. On each confirmed bar, posteriors first decay toward the prior Beta(1,1), then the previous bar's view is checked against the realized return — a hit adds α+=1, a miss β+=1 (one-bar lag, no look-ahead). This is the reward-driven self-evolution.
Scores are: in UCB mode mean + c·std (mean = α/(α+β), std = the Beta distribution's width); in Thompson mode a sample from a Gaussian approximation of the Beta posterior clip(mean + σ·z, 0,1) (z from a deterministic LCG + Box-Muller standard normal). Positive scores are normalized into weights w_a, giving the credibility-weighted allocation alloc = Σ w_a·dir_a ∈ [−1,1]. The lead arm is the highest-scoring one. Allocation beyond the deadband calls Long/Short; inside it, Flat.

🎯 Three design choices stand out. First, the Beta posterior's width (uncertainty) directly drives exploration — arms with little evidence are occasionally sampled high under Thompson and get a higher confidence bound under UCB, so they get tried. Second, forgetting adapts to non-stationary markets, naturally lowering the weight of arms that stop working. Third, a deterministic RNG plus confirmed-bar updates keep historical signals non-repainting.

⚙️ Recommended Settings & Tuning Guide

As a crypto starting point — BTC/ETH (1D, 4H): Strategy = Thompson, adaptation λ = 0.97, deadband 0.15; the lead signal rotates smoothly with regime. High-volatility names (SOL, XRP): lower λ toward 0.95 for faster adaptation, and raise the deadband to 0.20 to avoid trading on weak consensus. For more deterministic behavior, switch to UCB (c ≈ 1.0).
Per parameter: Strategy (Thompson/UCB) sets the quality of exploration — Thompson is stochastic and diverse, UCB deterministic and steady. Adaptation λ sets learning memory (0.99 = stable/long, 0.95 = nimble). UCB c sets exploration strength. Deadband sets the consensus strength required to fire. Sub-signal lengths are tuned to your timeframe.

💡 How to Use in Practice

The core read is final signal × conviction. When allocation swings strongly one way (high conviction) and several arms in the credibility panel agree, that's cross-regime consensus — a tailwind for trend-following. The moment the lead arm changes (e.g., from Trend to MeanRev) signals the type of edge that's working has shifted. The credibility bars show at a glance which logic (trend vs contrarian) currently dominates the market. When conviction is low and arms disagree, no logic is working well — an unstable phase where standing aside is wise.
For multi-timeframe work, read the higher-timeframe lead arm for the macro-effective logic and execute on lower-timeframe signals. Bandit P&L offers a sense of the allocator's in-sample traction.

⚠️ Important Notes

Signals are hidden until the warmup period (default 100 bars) completes. Reloading the indicator rebuilds the posteriors from scratch — learning state is not persisted. Thompson sampling uses a Gaussian approximation of the Beta, not exact Beta draws (the approximation is coarse with little early evidence). The panel's "Bandit P&L" is an in-sample metric that excludes trading cost and slippage. The arms are fixed classic rules — the bandit selects among them, it does not invent new signals. Updates occur on confirmed bars only.

🚨 Disclaimer

This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Past performance is not indicative of future results. All trading involves risk. Use it alongside your own thorough testing and sound risk management; all trading decisions remain solely your own responsibility.

## Source Code

````pine
//@version=6
// ============================================================================
//  AetherEdge - Multi-Armed Bandit   ( AE-MAB )
// ----------------------------------------------------------------------------
//  A self-evolving signal allocator. It runs a panel of classic sub-signals -
//  trend, momentum, breakout, mean-reversion, MACD - as the "arms" of a
//  multi-armed bandit, and learns which arm to trust NOW. Each arm carries a
//  Bayesian Beta(alpha, beta) posterior over its directional hit-rate, updated
//  online with exponential forgetting from realized hits/misses (the reward).
//  Allocation weights come from either Thompson Sampling (sample each posterior)
//  or UCB (mean + confidence bound) - both balance EXPLORATION of uncertain arms
//  against EXPLOITATION of proven ones. The final signal is the credibility-
//  weighted vote of the arms. Beliefs self-evolve; the RNG is seed-deterministic
//  and updates occur on confirmed bars only (no look-ahead, no repaint).
// ============================================================================
indicator("AetherEdge - Multi-Armed Bandit", "AE-MAB", overlay = true, max_labels_count = 50)

// ----------------------------------------------------------------------------
//  INPUTS
// ----------------------------------------------------------------------------
//  --- Bandit ---
var string gB = "Bandit"
mode    = input.string("Thompson", "Strategy", options = ["Thompson", "UCB"], group = gB, tooltip = "Thompson = sample each Beta posterior (stochastic explore/exploit). UCB = mean + confidence bound (deterministic).")
lambda  = input.float(0.97, "Adaptation (lambda)", minval = 0.85, maxval = 0.999, step = 0.001, group = gB, tooltip = "Forgetting factor of the Beta posteriors. Lower = adapts faster to which signal works now.")
ucbC    = input.float(1.0,  "UCB Exploration (c)", minval = 0.0, maxval = 3.0, step = 0.1, group = gB)
deadband = input.float(0.15, "Signal Deadband", minval = 0.0, maxval = 0.9, step = 0.05, group = gB, tooltip = "Weighted allocation must exceed this to call Long/Short.")
seed    = input.int(1337, "Random Seed", minval = 1, group = gB, tooltip = "Deterministic Thompson sampling. Same seed = reproducible.")

//  --- Sub-signals (arms) ---
var string gA = "Sub-Signals"
fastLen = input.int(10, "Trend Fast EMA", minval = 2, group = gA)
slowLen = input.int(30, "Trend Slow EMA", minval = 3, group = gA)
rsiLen  = input.int(14, "Momentum RSI", minval = 2, group = gA)
brkLen  = input.int(20, "Breakout Length", minval = 2, group = gA)
mrLen   = input.int(20, "Mean-Reversion Length", minval = 3, group = gA)

//  --- Display ---
var string gD = "Display"
warmup    = input.int(100, "Warmup Bars", minval = 20, group = gD)
longCol   = input.color(#26ffe6, "Long", group = gD)
shortCol  = input.color(#ff2e88, "Short", group = gD)
flatCol   = input.color(#8892b0, "Flat", group = gD)
accent    = input.color(#aeffff, "Lead Accent", group = gD)
showTint  = input.bool(true,  "Background Tint", group = gD)
showBars  = input.bool(false, "Color Bars by Signal", group = gD)
showFlips = input.bool(true,  "Signal-Flip Markers", group = gD)
showCred  = input.bool(true,  "Credibility Panel", group = gD)
credPos   = input.string("Bottom Right", "Credibility Position", options = ["Bottom Right", "Bottom Left", "Top Right", "Top Left", "Middle Right"], group = gD)
showDash  = input.bool(true,  "Dashboard", group = gD)
dashPos   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gD)

// ----------------------------------------------------------------------------
//  CONSTANTS & HELPERS
// ----------------------------------------------------------------------------
N   = 5
EPS = 1e-12
TWO_PI = 2.0 * math.pi

f_pos(string s) =>
    s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

f_clip(float x, float lo, float hi) => math.max(math.min(x, hi), lo)

f_bar(float p) =>
    int n = int(math.round(f_clip(p, 0.0, 1.0) * 10.0))
    string s = ""
    for i = 0 to 9
        s := s + (i < n ? "█" : "░")
    s

// ----------------------------------------------------------------------------
//  ARM DIRECTIONS  (each sub-signal's view this bar : +1 / 0 / -1)
// ----------------------------------------------------------------------------
ret  = math.log(close / close[1])
emaF = ta.ema(close, fastLen)
emaS = ta.ema(close, slowLen)
d0 = emaF > emaS ? 1.0 : emaF < emaS ? -1.0 : 0.0
rsiV = ta.rsi(close, rsiLen)
d1 = rsiV > 55 ? 1.0 : rsiV < 45 ? -1.0 : 0.0
hh = ta.highest(high, brkLen)[1]
ll = ta.lowest(low, brkLen)[1]
d2 = close > hh ? 1.0 : close < ll ? -1.0 : 0.0
zsc = (close - ta.sma(close, mrLen)) / (ta.stdev(close, mrLen) + EPS)
d3 = zsc > 1.0 ? -1.0 : zsc < -1.0 ? 1.0 : 0.0
[macdL, sigL, histL] = ta.macd(close, 12, 26, 9)
d4 = macdL > sigL ? 1.0 : macdL < sigL ? -1.0 : 0.0

ready = bar_index > warmup

// ----------------------------------------------------------------------------
//  PERSISTENT STATE  (Beta posteriors + bookkeeping)
// ----------------------------------------------------------------------------
var array<float>  aA = array.new<float>(N, 1.0)   // Beta alpha
var array<float>  bA = array.new<float>(N, 1.0)   // Beta beta
var array<float>  dirPrev = array.new<float>(N, 0.0)
var array<float>  scoreA = array.new<float>(N, 0.0)
var array<float>  weightA = array.new<float>(N, 0.0)
var array<string> nameA = array.from("Trend", "Mom", "Break", "MeanRev", "MACD")
var float allocation = na
var float allocPrev = 0.0
var float cumRew = 0.0
var int   leadIdx = 0
var int   rng = seed

// ----------------------------------------------------------------------------
//  BANDIT ENGINE  (reward update + allocation ; confirmed bars only)
// ----------------------------------------------------------------------------
if barstate.isconfirmed and ready
    array<float> dirs = array.from(d0, d1, d2, d3, d4)
    // 1) reward: discount toward prior, then credit the PREVIOUS bar's bets
    for a = 0 to N - 1
        array.set(aA, a, (1.0 - lambda) * 1.0 + lambda * array.get(aA, a))
        array.set(bA, a, (1.0 - lambda) * 1.0 + lambda * array.get(bA, a))
        float dp = array.get(dirPrev, a)
        if dp != 0.0
            if math.sign(dp) == math.sign(ret)
                array.set(aA, a, array.get(aA, a) + 1.0)
            else
                array.set(bA, a, array.get(bA, a) + 1.0)
    cumRew := cumRew + allocPrev * ret
    // 2) scores via Thompson sampling or UCB
    for a = 0 to N - 1
        float al = array.get(aA, a)
        float be = array.get(bA, a)
        float mean = al / (al + be)
        float varB = al * be / ((al + be) * (al + be) * (al + be + 1.0))
        float sc = 0.0
        if mode == "UCB"
            sc := mean + ucbC * math.sqrt(varB)
        else
            rng := (rng * 1103515245 + 12345) % 2147483647
            float u1 = math.max(rng / 2147483647.0, 1e-9)
            rng := (rng * 1103515245 + 12345) % 2147483647
            float u2 = rng / 2147483647.0
            float z = math.sqrt(-2.0 * math.log(u1)) * math.cos(TWO_PI * u2)
            sc := f_clip(mean + math.sqrt(varB) * z, 0.001, 0.999)
        array.set(scoreA, a, sc)
    // 3) normalize positive scores into weights
    float ssum = EPS
    for a = 0 to N - 1
        ssum += math.max(array.get(scoreA, a), 0.0)
    for a = 0 to N - 1
        array.set(weightA, a, math.max(array.get(scoreA, a), 0.0) / ssum)
    // 4) credibility-weighted allocation
    float alloc = 0.0
    for a = 0 to N - 1
        alloc += array.get(weightA, a) * array.get(dirs, a)
    allocation := alloc
    // 5) lead arm
    float bestS = -1.0
    int li = 0
    for a = 0 to N - 1
        if array.get(scoreA, a) > bestS
            bestS := array.get(scoreA, a)
            li := a
    leadIdx := li
    // 6) remember this bar's bets for next reward
    for a = 0 to N - 1
        array.set(dirPrev, a, array.get(dirs, a))
    allocPrev := alloc

// ----------------------------------------------------------------------------
//  DERIVED + ON-PRICE VISUALS
// ----------------------------------------------------------------------------
active = ready and not na(allocation)
int dirFinal = na(allocation) ? 0 : allocation > deadband ? 1 : allocation < -deadband ? -1 : 0
color dirCol = dirFinal > 0 ? longCol : dirFinal < 0 ? shortCol : flatCol
float conviction = math.abs(nz(allocation))

int tintT = 93 - int(conviction * 8.0)
bgcolor(showTint and active ? color.new(dirCol, tintT) : na)
barcolor(showBars and active ? color.new(dirCol, 30) : na)

isLong = active and dirFinal == 1
isShort = active and dirFinal == -1
plotshape(showFlips and isLong and not isLong[1],  "Go Long",  shape.triangleup,   location.belowbar, color = longCol,  size = size.tiny)
plotshape(showFlips and isShort and not isShort[1], "Go Short", shape.triangledown, location.abovebar, color = shortCol, size = size.tiny)

// ----------------------------------------------------------------------------
//  CREDIBILITY PANEL + DASHBOARD
// ----------------------------------------------------------------------------
var table cred = table.new(position = f_pos(credPos), columns = 4, rows = N + 1, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(longCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)
var table dash = table.new(position = f_pos(dashPos), columns = 2, rows = 8, bgcolor = color.new(#0b0e16, 15), frame_color = color.new(longCol, 60), frame_width = 1, border_color = color.new(#1a1f2e, 40), border_width = 1)

if barstate.islast and active
    array<float> dirsNow = array.from(d0, d1, d2, d3, d4)
    // ----- credibility panel -----
    if showCred
        color hdrBg = #0b0e16
        table.cell(cred, 0, 0, "Arm",         text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_left)
        table.cell(cred, 1, 0, "Dir",         text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_center)
        table.cell(cred, 2, 0, "Credibility", text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_left)
        table.cell(cred, 3, 0, "W%",          text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.small, text_halign = text.align_right)
        for a = 0 to N - 1
            float al = array.get(aA, a)
            float be = array.get(bA, a)
            float mean = al / (al + be)
            float dn = array.get(dirsNow, a)
            color dc = dn > 0 ? longCol : dn < 0 ? shortCol : flatCol
            string dg = dn > 0 ? "▲" : dn < 0 ? "▼" : "◆"
            bool isLead = a == leadIdx
            color rb = isLead ? color.new(accent, 82) : color.new(#11151f, 10)
            table.cell(cred, 0, a + 1, array.get(nameA, a), text_color = isLead ? accent : #e6f1ff, bgcolor = rb, text_size = size.small, text_halign = text.align_left)
            table.cell(cred, 1, a + 1, dg, text_color = dc, bgcolor = rb, text_size = size.small, text_halign = text.align_center)
            table.cell(cred, 2, a + 1, f_bar(mean) + " " + str.tostring(mean * 100, "#") + "%", text_color = color.from_gradient(mean, 0.4, 0.7, flatCol, longCol), bgcolor = rb, text_size = size.tiny, text_halign = text.align_left)
            table.cell(cred, 3, a + 1, str.tostring(array.get(weightA, a) * 100, "#") + "%", text_color = isLead ? accent : #e6f1ff, bgcolor = rb, text_size = size.small, text_halign = text.align_right)

    // ----- dashboard -----
    if showDash
        color rowBg = color.new(#11151f, 10)
        color hdrBg = #0b0e16
        string sig = dirFinal > 0 ? "▲ LONG" : dirFinal < 0 ? "▼ SHORT" : "◆ FLAT"
        float pnl = (math.exp(cumRew) - 1.0) * 100.0
        float leadCred = array.get(aA, leadIdx) / (array.get(aA, leadIdx) + array.get(bA, leadIdx))
        table.cell(dash, 0, 0, "AE · MAB",   text_color = #e6f1ff, bgcolor = hdrBg, text_size = size.normal, text_halign = text.align_left)
        table.cell(dash, 1, 0, sig,          text_color = dirCol,  bgcolor = hdrBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 1, "Conviction", text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 1, str.tostring(conviction * 100, "#") + "%", text_color = color.from_gradient(conviction, 0.0, 1.0, flatCol, dirCol), bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 2, "Lead Arm",   text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 2, array.get(nameA, leadIdx) + " " + str.tostring(leadCred * 100, "#") + "%", text_color = accent, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 3, "Allocation", text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 3, (allocation >= 0 ? "+" : "") + str.tostring(allocation, "#.##"), text_color = dirCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 4, "Bandit P&L", text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 4, (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.#") + "%", text_color = pnl >= 0 ? longCol : shortCol, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 5, "Strategy",   text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 5, mode,         text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_right)
        table.cell(dash, 0, 6, "Adapt λ",    text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 6, str.tostring(lambda, "#.###"), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)
        table.cell(dash, 0, 7, "Arms",       text_color = flatCol, bgcolor = rowBg, text_size = size.small,  text_halign = text.align_left)
        table.cell(dash, 1, 7, str.tostring(N), text_color = #e6f1ff, bgcolor = rowBg, text_size = size.small, text_halign = text.align_right)

// ----------------------------------------------------------------------------
//  ALERTS
// ----------------------------------------------------------------------------
alertcondition(isLong and not isLong[1],   "Bandit Long",  "AE-MAB: allocation turned LONG")
alertcondition(isShort and not isShort[1], "Bandit Short", "AE-MAB: allocation turned SHORT")
````
