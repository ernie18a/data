<!-- tradingview-pine-id: PUB;d9ac79a662874784b06c45f02d4c7f63 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# KERNEL BANDS [vault]

Source: https://www.tradingview.com/script/eZm67TZ4-KERNEL-BANDS-vault/

## Description

KERNEL BANDS [vault]

A non-parametric kernel regression centreline wrapped in adaptive residual sigma bands, with a full trade management layer on top: filtered entries, an exit engine that reports results in pips, a reversal radar, a dead-zone shield, session and momentum context, and a multi-timeframe screener. Everything is confirmed on bar close and nothing repaints.

A moving average assumes price came from a fixed-form equation (linear in lag, weighted in lag, and so on). Kernel regression makes no such assumption. It lets the local density of the data decide where the centreline sits, which gives a smoother and more honest picture of where price actually is, without the corner cutting EMAs and HMAs do around pivots. The bands around it are not arbitrary ATR multiples but a statistical measure of how far price normally strays from the kernel before reverting.

1. The kernel

Every moving average is a kernel, just a rectangular one (or, for HMA, a chained weighted one). Kernel regression generalises the idea: you pick the shape of the weight curve based on how much you want each historical bar to matter. Three kernels ship:

- Gaussian: the textbook bell curve, K(u) = exp(-u² / 2h²). Heavy tails, smooth everywhere. The most stable default.
- Epanechnikov: compact-support parabola, K(u) = max(0, 1 - u²/h²). Mathematically optimal in the mean-squared-error sense, lightest tails, slightly more responsive at the leading edge.
- Tricube: LOWESS-style, K(u) = max(0, (1 - |u/h|³)³). Very smooth shoulders, great on noisy intraday data where you want a confident centreline rather than a chasing one.

All three feed the same Nadaraya-Watson estimator, ŷ = Σ K(i) · close / Σ K(i), computed one-sided over the lookback window so it never looks into the future. The kernel choice sets the personality of the line, the bandwidth h sets its memory.

2. Adaptive bandwidth (ATR-scaled)

A static bandwidth breaks in changing regimes. When realised volatility expands a fixed h lags badly, when it contracts the same h starts amplifying noise. Here h is scaled live by normalised ATR:

h_eff = h_base × (1 + ATR / close × factor)

so the kernel widens when the market is loud and tightens when it is quiet, and the line behaves the same across gold, indices, crypto and FX without per-symbol tuning.

A Bandwidth Regime Shift alert fires when h moves by more than a user-set fraction in a single bar. It is your early warning that the volatility surface just changed: it typically fires before either directional signal and tells you whatever play you had on a minute ago may need to be re-evaluated. The dashboard shows the % jump that triggered it.

3. Residual sigma bands

The bands are the rolling standard deviation of the residual (close - kernel MA), EMA-smoothed, then scaled by the sigma multiplier. This answers a real question: how much do we usually deviate from the kernel before reverting? When the answer is small, the bands hug the line and a breakout is statistically meaningful. When it is large, band breaks are normal and should be downweighted.

Band Floor is an addition to the original concept. The half-width can never be thinner than a chosen fraction of ATR (0.6 by default). Without it, volatility compressions produced razor-thin bands and hair-trigger state flips on every wick. With it, a quiet market still needs a real move to change state.

4. State engine

A confirmed close above the upper band latches the state to Bullish, a confirmed close below the lower band latches it to Bearish. State only flips on the opposite band, there is no neutral repainting in between. Confirmation Closes sets how many consecutive closes beyond the band are required (default 2), which is the single biggest difference between a clean chart and a noisy one.

The band colour, the fill, the dashboard Signal row and the MTF screener all read from this one state.

5. Signal engine (what changed versus a plain band cross)

A state flip is not an entry any more. A flip arms the signal, and the entry prints only once every condition lines up within the entry wait window (default 6 bars). If the state reverts before that happens, the armed signal is dropped silently and nothing is printed. The dashboard shows the armed side in gold so you always know a setup is pending.

Conditions an entry must pass:

- Kernel slope must agree: buy only while the kernel is rising, sell only while it is falling. This kills counter-trend spikes, the classic "one violent wick through the lower band in an uptrend" trap.
- Entry candle must agree: a buy needs a green close, a sell needs a red close.
- Max extension beyond band: if the flip candle closed too far past the band (default 1.5× the band half-width) the engine waits for a calmer candle instead of chasing the blow-off.
- Skip blow-off candles: no entry on a bar (or the bar before it) whose range exceeds a multiple of ATR.
- Min bars between entries: a cooldown so two entries cannot stack on top of each other.
- Dead-zone shield: no entries while the market is flagged as chop (section 7).
- Session filter (optional, off by default): restrict entries to London / New York windows if you want it.

Re-entries: after an exit, if the state is unchanged and price crosses back through the kernel MA in the direction of momentum, a fresh entry arms. Trends are ridden in segments, each one banked.

Entry labels carry the side and the exact close price so you can enter at the same level.

6. Exit engine

Every entry is closed by the indicator with an Exit label in the colour of the side it closes (cyan closes a long, magenta closes a short). The label shows the exit price and the result in pips. Pip size is auto-detected (mintick × 10, so 0.1 on gold) and can be overridden.

An exit fires on whichever comes first:

- Flip: the state confirms the opposite way.
- Reversal: a reversal candle prints at a band extension while the trade is in profit.
- Giveback: after the trade has reached a minimum peak, it has given back a set percentage of that peak (default 50%).
- Structure: close breaks the lowest low (long) or highest high (short) of the last N bars while in profit.

The dashboard shows live Position, Open P&L and peak P&L, and the exit alert reports entry, exit, result, peak, trigger and bars held. Your journal writes itself.

7. Dead-zone shield

Flat, low-volume chop is where band systems buy the top and sell the bottom of the range. The shield scores four conditions every bar: flat kernel slope, clustered state flips (weighted double, because a burst of flips is the strongest chop tell there is), tight range and weak volume. Above the trigger score the chart is tinted, entries are suppressed and the dashboard reads DEAD ZONE with the bar count. The first genuine breakout escaping the zone still arms an entry.

Two alerts, deliberately not session-filtered: Dead Zone Entered (with the score and which conditions tripped it) and Dead Zone Cleared (with how long it lasted). The second one is the one to set: it tells you when to be back at the screen.

8. Reversal radar

Reversal candles (doji, pin bar, engulfing) that print at a band extension are marked with a ⚠ Rev label: red at the upper band, cyan at the lower. The dashboard tracks the most recent one as TOP FORMING / BOTTOM FORMING with its age. Kernel momentum is read live as Rising, Rising & Fading, Falling or Falling & Fading, with directional alerts when it turns. Together they are your early tell that a move is exhausting, and the Reversal exit uses the same signal.

9. Divergence engine

A pure slope-comparison divergence runs in parallel: the kernel slope over a window against the price slope over the same window. Bullish divergence is registered when price is falling while the kernel turns up, bearish is the mirror. Both slopes have separate minimum thresholds (as a fraction of ATR × window) so flat regions never trigger noise divergences, and a cooldown spaces them out. Labels print ▲ Div / ▼ Div at the wick they fire from, and the dashboard shows the active divergence with its bar age.

10. MTF screener

A compact board that shows the kernel state on 5m / 15m / 1h / 4h. The top row is pinned to whatever symbol your chart is on and follows you when you switch, so your active trade is always on the board. Up to five more symbols can be added in settings. Each cell is an arrow in the state colour, brighter when the flip is fresh (within a user-set number of bars) so you can tell at a glance whether a setup is new or already ran. The Σ column counts aligned timeframes and prints A+▲ or A+▼ when all four agree.

The screener requests nothing on your behalf: only symbols you type in are ever requested, so alerts save on every data plan.

11. Three visual modes

The same kernel and sigma feed every mode:

- Bands: classic upper / lower envelope with toggleable fill. Best for mean-reversion and band-touch analysis.
- Single Line: kernel centreline with a gradient fill between the line and price. Best for pure trend-following.
- Trail: only the trailing band is drawn, in the active state colour, with an optional sin-modulated pulse alpha that gives a subtle breathing effect. Best for visual conviction in directional moves.

State candles and bar colouring are independent toggles, and the kernel line can be drawn on top of Bands or Trail if you want it visible everywhere. A full Colors group covers bull, bear, neutral, text, accent and dashboard background / frame.

12. Dashboard

A monospaced table, positionable to any of nine anchors, with a subtle vertical gradient. Rows: Signal, Kernel MA, Upper Band, Lower Band, Band Width σ, Bandwidth h (with adaptive tag), Kernel, Divergence, Regime, Session, Position (including armed setups), Open P&L with peak, Market (Trending / Dead Zone), Momentum and Reversal.

13. Alerts

Seventeen named alert conditions, every one evaluated on bar close: BUY, SELL, EXIT LONG, EXIT SHORT, Bullish Breakout, Bearish Breakdown, Bullish Divergence, Bearish Divergence, Bandwidth Regime Shift, Reversal at Top, Reversal at Bottom, Dead Zone Entered, Dead Zone Cleared, Momentum Shift Bullish, Momentum Shift Bearish, Momentum Shift (any), Kernel State Flip.

On top of that the script sends dynamic messages through alert(): entries carry entry price, TP / SL geometry, live momentum and session, exits carry entry, exit, result in pips, peak, trigger and bars held, dead-zone events carry the score and the reason. Attach a webhook to "Any alert() function call" and a bot reading the payload has the same confluence a human reads on the dashboard.

Each named condition has to be selected individually in the alert dialog. "Any alert() function call" delivers the dynamic messages, not the named conditions. That is a TradingView rule, not a setting in this indicator.

How to use it

Trend-following: Single Line or Trail mode, Tricube kernel, adaptive bandwidth on, Confirmation Closes 2, kernel slope confirmation on. Take entries in the direction of the higher-timeframe rows on the screener and let the exit engine manage the trade.

Mean-reversion: Bands mode, Gaussian or Epanechnikov, fade band touches that coincide with a ⚠ Rev label, a divergence label and a low Band Width σ reading. Use the Regime Shift alert as a heads-up that a reversion play just got riskier.

Scalping 1m-5m: keep Band Floor at 0.6 or above and Confirmation Closes at 2, otherwise the band flips on every wick. If you get too few entries, loosen Entry Candle Must Agree first, then Max Extension to 2.0.

Suggested settings

Defaults are tuned for 5m-1H on liquid futures, gold and crypto: Lookback 30, Base Bandwidth 8, Sigma Multiplier 1.0, Band Floor 0.6, Confirmation Closes 2. For 1m-3m drop Lookback to ~20 and Bandwidth to ~6. For daily and above raise Lookback to 50 and Bandwidth to 12. The kernel and bandwidth jointly control how much the line trusts the recent past, the sigma multiplier and band floor separately control how much movement you are willing to call normal.

Limitations

The kernel is recomputed each bar over the lookback window, so very long lookbacks on very low timeframes can feel heavy. State transitions, entries, exits and reversal labels are all confirmed on bar close, so a band touch that gets reabsorbed within the bar will not fire. This is deliberate and is what prevents intra-bar repainting. The MTF screener reads higher-timeframe values that in real time come from the still-open bar, so a cell can flicker until that bar closes. Divergence is non-repainting but carries the natural lag of comparing slopes over a window.

What was improved over the original concept and why

- Band floor: the original residual sigma alone produced paper-thin bands in compressions and a flip on every wick. A floor tied to ATR fixed that without touching the statistical meaning of the band in normal conditions.
- Confirmation closes: one close beyond the band is a wick, two is a decision.
- Arm-then-fire entries: entries were firing on the flip bar no matter what that bar looked like. Now the flip arms the setup and the entry waits (up to a few bars) for kernel slope, candle colour and extension to agree, and is dropped if the state reverts.
- Kernel slope agreement: the single biggest source of bad trades was a sell printed during a spike down while the kernel was still rising. Requiring slope agreement removes the whole class.
- Blow-off check on two bars: a spike often spans the flip bar and the one before it.
- Dead-zone weighting: a cluster of flips is the strongest chop signal there is, so it counts double and the shield activates on a burst of flips alone instead of needing a second condition.
- Session filter off by default: gold and indices produce clean moves outside London / NY too, and the filter was skipping them. It is still there if you want it.
- Kernel MA plotted in every mode and alertable via the standard Crossing / Greater Than rules, plus a toggle to draw it on top of Bands or Trail.
- Screener requests only what you type in, so alerts save on any data plan.

---

## Source Code

````pine
//@version=6
indicator("KERNEL BANDS [vault]", shorttitle="KB [vault]", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════════════════
grpK = "Kernel Regression"
src        = input.source(close, "Source", group=grpK)
lookback   = input.int(30, "Lookback Window", minval=5, maxval=500, group=grpK, tooltip="Bars feeding the kernel. 15m-1H: 30 | 5m and below: ~20 | Daily+: 50")
hBase      = input.float(8.0, "Base Bandwidth (h)", minval=0.5, step=0.5, group=grpK, tooltip="Memory of the line. Higher = smoother and slower.")
kernelType = input.string("Gaussian", "Kernel", options=["Gaussian", "Epanechnikov", "Tricube"], group=grpK)

grpA = "Adaptive Bandwidth"
adaptOn   = input.bool(true, "ATR-Scaled Bandwidth", group=grpA, tooltip="h_eff = h_base * (1 + ATR / close * factor)")
atrLen    = input.int(14, "ATR Length", minval=1, group=grpA)
atrFactor = input.float(150.0, "Scale Factor", minval=0.0, step=10.0, group=grpA)
jumpFrac  = input.float(0.10, "Regime Shift Threshold", minval=0.01, step=0.01, group=grpA, tooltip="Fraction h must move in one bar to flag a regime shift")

grpB = "Residual Sigma Bands"
sigLen    = input.int(20, "Sigma Length", minval=2, group=grpB)
sigSmooth = input.int(3, "Sigma EMA Smoothing", minval=1, group=grpB)
sigMult   = input.float(1.0, "Sigma Multiplier", minval=0.1, step=0.1, group=grpB)
bandFloor = input.float(0.6, "Band Floor (x ATR)", minval=0.0, step=0.1, group=grpB, tooltip="Half-width can never be thinner than this. Kills hair-trigger flips when volatility compresses.")

grpS = "Signal Engine"
confirmBars = input.int(2, "Confirmation Closes", minval=1, maxval=5, group=grpS, tooltip="Consecutive closes beyond the band needed to flip state")
minHold     = input.int(4, "Min Bars Between Entries", minval=0, group=grpS)
blowOffMult = input.float(3.0, "Skip Blow-Off Candles (x ATR)", minval=0.0, step=0.5, group=grpS, tooltip="No entry on a candle whose range exceeds this many ATR")
kernConfirm = input.bool(true, "Kernel Slope Must Agree", group=grpS, tooltip="Buy only while the kernel is rising, sell only while it is falling. Blocks counter-trend spikes.")
candleConf  = input.bool(true, "Entry Candle Must Agree", group=grpS, tooltip="Buy on a green close, sell on a red close")
maxExt      = input.float(1.5, "Max Extension Beyond Band (x half-width)", minval=0.0, step=0.25, group=grpS, tooltip="If the flip candle closed further than this beyond the band, wait for a calmer candle instead of chasing")
armWindow   = input.int(6, "Entry Wait Window (bars)", minval=0, group=grpS, tooltip="After a flip the entry stays armed for this many bars until all conditions line up. Cancelled if the state reverts.")
showSignals = input.bool(true, "Buy / Sell Entry Labels", group=grpS)
showExits   = input.bool(true, "Exit Labels", group=grpS)
pipSize     = input.float(0.0, "Pip Size (0 = auto)", minval=0.0, step=0.01, group=grpS, tooltip="0 = mintick x 10 (0.1 on gold)")
givebackPct = input.float(50.0, "Profit Giveback Exit (%)", minval=5.0, maxval=95.0, step=5.0, group=grpS)
minPeakPips = input.float(15.0, "Giveback Active After (pips)", minval=0.0, group=grpS)
structLen   = input.int(5, "Structure Break Lookback", minval=2, group=grpS, tooltip="Exit when close breaks the lowest low (long) / highest high (short) of the last N bars")

grpZ = "Dead-Zone Shield"
dzOn     = input.bool(true, "Enable Dead-Zone Shield", group=grpZ)
dzThresh = input.int(2, "Trigger Score (of 5)", minval=1, maxval=5, group=grpZ, tooltip="Clustered flips = 2 points, flat kernel slope / tight range / weak volume = 1 point each")
dzTint   = input.bool(true, "Tint Chart In Dead Zone", group=grpZ)

grpR = "Reversal Radar"
revOn       = input.bool(true, "Enable Reversal Radar", group=grpR)
revCooldown = input.int(3, "Cooldown (bars)", minval=0, group=grpR)
showRevLbl  = input.bool(true, "Rev Labels", group=grpR)

grpSes = "Session Filter"
sessOn   = input.bool(false, "Entries Only In London / NY", group=grpSes, tooltip="Off by default: gold and indices move outside these windows too")
londonS  = input.session("0800-1700", "London (UTC)", group=grpSes)
nyS      = input.session("1330-2200", "New York (UTC)", group=grpSes)

grpD = "Divergence"
divOn       = input.bool(true, "Enable Divergence", group=grpD)
divLook     = input.int(10, "Slope Window", minval=2, group=grpD)
divPriceMin = input.float(0.30, "Min Price Slope (x ATR x window)", minval=0.0, step=0.05, group=grpD)
divKernMin  = input.float(0.05, "Min Kernel Slope (x ATR x window)", minval=0.0, step=0.01, group=grpD)
divCooldown = input.int(10, "Cooldown (bars)", minval=0, group=grpD)
showDivLbl  = input.bool(true, "Divergence Labels", group=grpD)

grpV = "Visuals"
vMode        = input.string("Bands", "Visual Mode", options=["Bands", "Single Line", "Trail"], group=grpV)
showFill     = input.bool(true, "Band / Gradient Fill", group=grpV)
showKmaExtra = input.bool(false, "Show Kernel MA Line in Bands / Trail", group=grpV)
pulseOn      = input.bool(true, "Trail Pulse", group=grpV)
stateCandles = input.bool(false, "State Candles", group=grpV)
barColorOn   = input.bool(false, "Bar Colouring", group=grpV)
lblSize      = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpV)

grpT = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group=grpT)
dashPos  = input.string("Bottom Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpT)
dashSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpT)

grpM = "MTF Screener"
scrOn     = input.bool(true, "Show MTF Screener", group=grpM, tooltip="Top row always follows the current chart. Add your own symbols below (only ones you hold real-time data for).")
scrPos    = input.string("Bottom Center", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpM)
scrSize   = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpM)
freshBars = input.int(6, "Fresh If Flipped Within (bars)", minval=1, group=grpM)
sym1 = input.symbol("", "Symbol 1", group=grpM)
sym2 = input.symbol("", "Symbol 2", group=grpM)
sym3 = input.symbol("", "Symbol 3", group=grpM)
sym4 = input.symbol("", "Symbol 4", group=grpM)
sym5 = input.symbol("", "Symbol 5", group=grpM)

grpC = "Colors"
cBull      = input.color(#00e5ff, "Bull", group=grpC)
cBear      = input.color(#ff2d6f, "Bear", group=grpC)
cNeut      = input.color(#8a8f9a, "Neutral", group=grpC)
cText      = input.color(#e6e8ee, "Text", group=grpC)
cGold      = input.color(#ffc857, "Accent", group=grpC)
cDashBg    = input.color(#0b0e14, "Dashboard Background", group=grpC)
cDashFrame = input.color(#242c3a, "Dashboard Frame", group=grpC)

// ═══════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════
f_kernel(float u, float h, string kt) =>
    float w = 0.0
    if kt == "Gaussian"
        w := math.exp(-(u * u) / (2.0 * h * h))
    else if kt == "Epanechnikov"
        w := math.max(0.0, 1.0 - (u * u) / (h * h))
    else
        float r = math.abs(u / h)
        w := math.max(0.0, math.pow(1.0 - math.pow(r, 3.0), 3.0))
    w

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

f_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_pips(float p) =>
    (p >= 0 ? "+" : "") + str.tostring(p, "#.#") + " pips"

// ═══════════════════════════════════════════════════════════════════════════
//  ENGINE  (kernel + sigma bands + latched state)  -  reused by the screener
// ═══════════════════════════════════════════════════════════════════════════
f_engine() =>
    float atr_ = ta.atr(atrLen)
    float h    = adaptOn ? hBase * (1.0 + nz(atr_ / close) * atrFactor) : hBase
    float num  = 0.0
    float den  = 0.0
    for i = 0 to lookback - 1
        float w = f_kernel(i, h, kernelType)
        num += w * nz(src[i], src)
        den += w
    float k     = den > 0.0 ? num / den : src
    float sigRw = ta.stdev(src - k, sigLen)
    float sig   = ta.ema(sigRw, sigSmooth)
    float half  = math.max(sig * sigMult, atr_ * bandFloor)
    float up    = k + half
    float lo    = k - half
    bool bullHit = math.sum(close > up ? 1 : 0, confirmBars) == confirmBars
    bool bearHit = math.sum(close < lo ? 1 : 0, confirmBars) == confirmBars
    int bsB = ta.barssince(bullHit)
    int bsS = ta.barssince(bearHit)
    int st  = na(bsB) and na(bsS) ? 0 : na(bsS) ? 1 : na(bsB) ? -1 : bsB < bsS ? 1 : -1
    int age = ta.barssince(st != st[1])
    [k, up, lo, sig, h, atr_, st, age]

[kma, upper, lower, sigma, hEff, atrV, state, stateAge] = f_engine()

bullFlip = state == 1  and state[1] != 1
bearFlip = state == -1 and state[1] != -1
stateCol = state == 1 ? cBull : state == -1 ? cBear : cNeut

// ═══════════════════════════════════════════════════════════════════════════
//  REGIME SHIFT
// ═══════════════════════════════════════════════════════════════════════════
hChg        = nz(hEff[1]) > 0.0 ? (hEff - hEff[1]) / hEff[1] : 0.0
regimeShift = math.abs(hChg) > jumpFrac
var float lastJump = 0.0
if regimeShift
    lastJump := hChg

// ═══════════════════════════════════════════════════════════════════════════
//  MOMENTUM  (Rising / Rising & Fading / Falling / Falling & Fading)
// ═══════════════════════════════════════════════════════════════════════════
kSl     = kma - kma[1]
momUp   = kSl > 0
fading  = math.abs(kSl) < math.abs(kSl[3])
momTxt  = (momUp ? "▲ RISING" : "▼ FALLING") + (fading ? " & FADING" : "")
momCol  = momUp ? cBull : cBear
momBull = momUp and not momUp[1]
momBear = not momUp and momUp[1]

// ═══════════════════════════════════════════════════════════════════════════
//  DEAD-ZONE SHIELD
// ═══════════════════════════════════════════════════════════════════════════
flatSlope  = math.abs(kma - kma[10]) < atrV * 0.6
rng20      = ta.highest(high, 20) - ta.lowest(low, 20)
tightRange = rng20 < atrV * 3.5
flipCount  = math.sum(state != state[1] ? 1 : 0, 30)
clustered  = flipCount >= 3
volSma     = ta.sma(nz(volume), 20)
weakVol    = volSma > 0 and nz(volume) < volSma * 0.8
dzScore    = (flatSlope ? 1 : 0) + (tightRange ? 1 : 0) + (clustered ? 2 : 0) + (weakVol ? 1 : 0)
deadZone   = dzOn and dzScore >= dzThresh
dzEntered  = deadZone and not deadZone[1]
dzCleared  = not deadZone and deadZone[1]
var int dzStart = 0
if dzEntered
    dzStart := bar_index
dzBars = bar_index - dzStart
dzWhy  = (flatSlope ? "flat slope, " : "") + (clustered ? "clustered flips, " : "") + (tightRange ? "tight range, " : "") + (weakVol ? "weak volume, " : "")

bgcolor(dzTint and deadZone ? color.new(cGold, 93) : na, title="Dead Zone Tint")

// ═══════════════════════════════════════════════════════════════════════════
//  SESSION
// ═══════════════════════════════════════════════════════════════════════════
inLondon = not na(time(timeframe.period, londonS, "UTC"))
inNY     = not na(time(timeframe.period, nyS, "UTC"))
sessOk   = not sessOn or inLondon or inNY
sessTxt  = inLondon and inNY ? "NY-LONDON OVERLAP ★" : inNY ? "New York" : inLondon ? "London" : "Asia / off-hours"
sessCol  = inLondon and inNY ? cGold : (inNY or inLondon) ? cBull : cNeut

// ═══════════════════════════════════════════════════════════════════════════
//  REVERSAL RADAR  (doji / pin / engulfing at a band extension)
// ═══════════════════════════════════════════════════════════════════════════
body   = math.abs(close - open)
rngC   = high - low
uWick  = high - math.max(open, close)
lWick  = math.min(open, close) - low
body1  = math.abs(close[1] - open[1])
doji   = rngC > 0 and body <= 0.15 * rngC
pinTop = rngC > 0 and uWick >= 2.0 * body and uWick >= 0.55 * rngC
pinBot = rngC > 0 and lWick >= 2.0 * body and lWick >= 0.55 * rngC
engBear = close < open and open >= close[1] and close <= open[1] and body > body1
engBull = close > open and open <= close[1] and close >= open[1] and body > body1
atTop  = high >= upper
atBot  = low  <= lower

var int lastRevBar  = -100000
var int lastRevType = 0
revReady = bar_index - lastRevBar > revCooldown
revTop = revOn and revReady and atTop and (doji or pinTop or engBear)
revBot = revOn and revReady and atBot and (doji or pinBot or engBull)
if revTop
    lastRevBar  := bar_index
    lastRevType := -1
else if revBot
    lastRevBar  := bar_index
    lastRevType := 1
revAge    = bar_index - lastRevBar
revActive = lastRevType != 0 and revAge <= 5
revTxt    = revActive ? (lastRevType == -1 ? "▼ TOP FORMING (" : "▲ BOTTOM FORMING (") + str.tostring(revAge) + ")" : "-"
revCol    = revActive ? (lastRevType == -1 ? cBear : cBull) : cNeut

// ═══════════════════════════════════════════════════════════════════════════
//  DIVERGENCE
// ═══════════════════════════════════════════════════════════════════════════
kSlope  = kma - kma[divLook]
pSlope  = src - src[divLook]
minPx   = atrV * divLook * divPriceMin
minKern = atrV * divLook * divKernMin
var int lastDivBar  = -100000
var int lastDivType = 0
divReady = bar_index - lastDivBar > divCooldown
bullDiv  = divOn and divReady and pSlope < -minPx and kSlope >  minKern
bearDiv  = divOn and divReady and pSlope >  minPx and kSlope < -minKern
if bullDiv
    lastDivBar  := bar_index
    lastDivType := 1
else if bearDiv
    lastDivBar  := bar_index
    lastDivType := -1
divAge    = bar_index - lastDivBar
divActive = lastDivType != 0 and divAge <= divCooldown
divTxt    = divActive ? (lastDivType == 1 ? "▲ bull (" : "▼ bear (") + str.tostring(divAge) + ")" : "-"
divCol    = divActive ? (lastDivType == 1 ? cBull : cBear) : cNeut

// ═══════════════════════════════════════════════════════════════════════════
//  SIGNAL + EXIT ENGINE
// ═══════════════════════════════════════════════════════════════════════════
pip = pipSize > 0 ? pipSize : syminfo.mintick * 10.0

var int   pos          = 0
var float entryPx      = na
var float peakPips     = 0.0
var int   lastEntryBar = -100000
var int   barsHeld     = 0

xUp = ta.crossover(close, kma)
xDn = ta.crossunder(close, kma)
lowestPrev  = ta.lowest(low, structLen)[1]
highestPrev = ta.highest(high, structLen)[1]

openPips = pos == 1 ? (close - entryPx) / pip : pos == -1 ? (entryPx - close) / pip : 0.0
if pos != 0
    peakPips := math.max(peakPips, openPips)
    barsHeld += 1

// ---- exits
string exitReason = ""
if pos == 1
    if bearFlip
        exitReason := "Flip"
    else if revTop and openPips > 0
        exitReason := "Reversal"
    else if peakPips >= minPeakPips and openPips <= peakPips * (1.0 - givebackPct / 100.0)
        exitReason := "Giveback"
    else if close < lowestPrev and openPips > 0
        exitReason := "Structure"
else if pos == -1
    if bullFlip
        exitReason := "Flip"
    else if revBot and openPips > 0
        exitReason := "Reversal"
    else if peakPips >= minPeakPips and openPips <= peakPips * (1.0 - givebackPct / 100.0)
        exitReason := "Giveback"
    else if close > highestPrev and openPips > 0
        exitReason := "Structure"

exitLong  = pos == 1  and exitReason != ""
exitShort = pos == -1 and exitReason != ""

if (exitLong or exitShort) and barstate.isconfirmed
    float resPips = openPips
    if showExits
        if exitLong
            label.new(bar_index, low,  "Exit\n" + str.tostring(close, format.mintick) + "\n" + f_pips(resPips), style=label.style_label_up,   color=cBull, textcolor=#0b0e14, size=f_size(lblSize))
        else
            label.new(bar_index, high, "Exit\n" + str.tostring(close, format.mintick) + "\n" + f_pips(resPips), style=label.style_label_down, color=cBear, textcolor=#ffffff, size=f_size(lblSize))
    alert("NKB [vault] " + (exitLong ? "CLOSE LONG" : "CLOSE SHORT") + " " + syminfo.ticker + " " + timeframe.period + " | entry " + str.tostring(entryPx, format.mintick) + " | exit " + str.tostring(close, format.mintick) + " | " + f_pips(resPips) + " | peak " + f_pips(peakPips) + " | trigger " + exitReason + " | bars " + str.tostring(barsHeld), alert.freq_once_per_bar_close)
    pos      := 0
    entryPx  := na
    peakPips := 0.0
    barsHeld := 0

// ---- entries (arm on trigger, fire when conditions line up)
var int armed    = 0
var int armedBar = 0

blowOff = math.max(rngC, rngC[1]) > atrV * blowOffMult
holdOk  = bar_index - lastEntryBar >= minHold
half    = upper - kma

longTrig  = state == 1  and pos != 1  and (bullFlip or dzCleared or (pos == 0 and xUp and momUp))
shortTrig = state == -1 and pos != -1 and (bearFlip or dzCleared or (pos == 0 and xDn and not momUp))

if longTrig
    armed    := 1
    armedBar := bar_index
else if shortTrig
    armed    := -1
    armedBar := bar_index

if (armed == 1 and state != 1) or (armed == -1 and state != -1) or (armed != 0 and bar_index - armedBar > armWindow)
    armed := 0

entryOk = sessOk and not deadZone and not blowOff and holdOk
extOkL  = half <= 0 or (close - upper) <= maxExt * half
extOkS  = half <= 0 or (lower - close) <= maxExt * half
kernOkL = not kernConfirm or momUp
kernOkS = not kernConfirm or not momUp
cndOkL  = not candleConf or close > open
cndOkS  = not candleConf or close < open

buySig  = armed == 1  and pos != 1  and entryOk and extOkL and kernOkL and cndOkL
sellSig = armed == -1 and pos != -1 and entryOk and extOkS and kernOkS and cndOkS

if (buySig or sellSig) and barstate.isconfirmed
    pos          := buySig ? 1 : -1
    entryPx      := close
    peakPips     := 0.0
    barsHeld     := 0
    lastEntryBar := bar_index
    armed        := 0
    if showSignals
        if buySig
            label.new(bar_index, low,  "Buy\n" + str.tostring(close, format.mintick) + "\nEntry", style=label.style_label_up,   color=cBull, textcolor=#0b0e14, size=f_size(lblSize))
        else
            label.new(bar_index, high, "Sell\n" + str.tostring(close, format.mintick) + "\nEntry", style=label.style_label_down, color=cBear, textcolor=#ffffff, size=f_size(lblSize))
    alert("NKB [vault] " + (buySig ? "BUY" : "SELL") + " " + syminfo.ticker + " " + timeframe.period + " @ " + str.tostring(close, format.mintick) + " | TP " + str.tostring(buySig ? close + 2.0 * sigma : close - 2.0 * sigma, format.mintick) + " | SL " + str.tostring(buySig ? lower : upper, format.mintick) + " | momentum " + momTxt + " | session " + sessTxt, alert.freq_once_per_bar_close)

posTxt = pos == 1 ? "▲ LONG @ " + str.tostring(entryPx, format.mintick) : pos == -1 ? "▼ SHORT @ " + str.tostring(entryPx, format.mintick) : armed == 1 ? "- FLAT (armed ▲)" : armed == -1 ? "- FLAT (armed ▼)" : "- FLAT"
posCol = pos == 1 ? cBull : pos == -1 ? cBear : armed != 0 ? cGold : cNeut
pnlTxt = pos != 0 ? f_pips(openPips) + "  (peak " + f_pips(peakPips) + ")" : "-"
pnlCol = pos == 0 ? cNeut : openPips >= 0 ? cBull : cBear

// ═══════════════════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════════════════
isBands = vMode == "Bands"
isLine  = vMode == "Single Line"
isTrail = vMode == "Trail"

pUp = plot(isBands ? upper : na, "Upper Band", color=stateCol, linewidth=1)
pLo = plot(isBands ? lower : na, "Lower Band", color=stateCol, linewidth=1)
fill(pUp, pLo, color=showFill and isBands ? color.new(stateCol, 82) : na, title="Band Fill")

pKma = plot(isLine or showKmaExtra ? kma : na, "Kernel MA", color=stateCol, linewidth=isLine ? 2 : 1)
pPx  = plot(isLine ? close : na, "Price Anchor", display=display.none, editable=false)
gTop    = math.max(kma, close)
gBot    = math.min(kma, close)
gOn     = showFill and isLine
gTopCol = gOn ? (close >= kma ? color.new(stateCol, 95) : color.new(stateCol, 55)) : na
gBotCol = gOn ? (close >= kma ? color.new(stateCol, 55) : color.new(stateCol, 95)) : na
fill(pKma, pPx, gTop, gBot, gTopCol, gBotCol, title="Gradient Fill")

pulseT    = pulseOn ? 20.0 + 30.0 * (0.5 + 0.5 * math.sin(bar_index * 0.35)) : 25.0
trailBull = isTrail and state == 1  ? lower : na
trailBear = isTrail and state == -1 ? upper : na
plot(trailBull, "Trail (bull)", color=color.new(cBull, int(pulseT)), linewidth=2, style=plot.style_linebr)
plot(trailBear, "Trail (bear)", color=color.new(cBear, int(pulseT)), linewidth=2, style=plot.style_linebr)

plotcandle(open, high, low, close, "State Candles", color=stateCandles ? stateCol : na, wickcolor=stateCandles ? stateCol : na, bordercolor=stateCandles ? stateCol : na)
barcolor(barColorOn ? stateCol : na, title="Bar Colouring")

// ═══════════════════════════════════════════════════════════════════════════
//  REV + DIV LABELS
// ═══════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed
    if showRevLbl and revTop
        label.new(bar_index, high, "⚠ Rev", style=label.style_label_down, color=color.new(cBear, 30), textcolor=#ffffff, size=size.tiny)
    if showRevLbl and revBot
        label.new(bar_index, low,  "⚠ Rev", style=label.style_label_up,   color=color.new(cBull, 30), textcolor=#0b0e14, size=size.tiny)
    if showDivLbl and bullDiv
        label.new(bar_index, low,  "▲ Div", style=label.style_label_up,   color=color.new(cBull, 35), textcolor=#0b0e14, size=size.tiny)
    if showDivLbl and bearDiv
        label.new(bar_index, high, "▼ Div", style=label.style_label_down, color=color.new(cBear, 35), textcolor=#ffffff, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(f_pos(dashPos), 2, 16, bgcolor=cDashBg, frame_color=cDashFrame, frame_width=1, border_color=cDashFrame, border_width=1)

f_row(int r, string k, string v, color vc) =>
    int tr = 4 + r * 2
    table.cell(dash, 0, r, k, text_color=cText, text_size=f_size(dashSize), text_halign=text.align_left,  bgcolor=color.new(cDashBg, tr), text_font_family=font.family_monospace)
    table.cell(dash, 1, r, v, text_color=vc,    text_size=f_size(dashSize), text_halign=text.align_right, bgcolor=color.new(cDashBg, tr), text_font_family=font.family_monospace)

if showDash and barstate.islast
    sigTxt = state == 1 ? "▲ BULLISH" : state == -1 ? "▼ BEARISH" : "- NEUTRAL"
    regTxt = regimeShift ? "⚡ SHIFT " + (lastJump >= 0 ? "+" : "") + str.tostring(lastJump * 100.0, "#.#") + "%" : "stable"
    mktTxt = deadZone ? "⚠ DEAD ZONE (" + str.tostring(dzBars) + ")" : "TRENDING"
    table.cell(dash, 0, 0, "NEURAL KERNEL BANDS", text_color=cText, text_size=f_size(dashSize), text_halign=text.align_left,  bgcolor=color.new(cDashBg, 0), text_font_family=font.family_monospace)
    table.cell(dash, 1, 0, "VALUE",               text_color=cText, text_size=f_size(dashSize), text_halign=text.align_right, bgcolor=color.new(cDashBg, 0), text_font_family=font.family_monospace)
    f_row(1,  "Signal",       sigTxt, stateCol)
    f_row(2,  "Kernel MA",    str.tostring(kma,   format.mintick), stateCol)
    f_row(3,  "Upper Band",   str.tostring(upper, format.mintick), cBull)
    f_row(4,  "Lower Band",   str.tostring(lower, format.mintick), cBear)
    f_row(5,  "Band Width σ", str.tostring(sigma, "#.##"), cText)
    f_row(6,  "Bandwidth h",  str.tostring(hEff,  "#.##") + (adaptOn ? "  (adaptive)" : ""), cText)
    f_row(7,  "Kernel",       kernelType, cNeut)
    f_row(8,  "Divergence",   divTxt, divCol)
    f_row(9,  "Regime",       regTxt, regimeShift ? cGold : cNeut)
    f_row(10, "Session",      sessTxt, sessCol)
    f_row(11, "Position",     posTxt, posCol)
    f_row(12, "Open P&L",     pnlTxt, pnlCol)
    f_row(13, "Market",       mktTxt, deadZone ? cGold : cBull)
    f_row(14, "Momentum",     momTxt, momCol)
    f_row(15, "Reversal",     revTxt, revCol)

// ═══════════════════════════════════════════════════════════════════════════
//  MTF SCREENER  (5m / 15m / 1h / 4h alignment, current chart pinned on top)
// ═══════════════════════════════════════════════════════════════════════════
f_cell(simple string sym, simple string tf) =>
    [_k, _u, _l, _s, _h, _a, st, age] = request.security(sym, tf, f_engine())
    [st, age]

cur = syminfo.tickerid
[c1s, c1a] = f_cell(cur, "5")
[c2s, c2a] = f_cell(cur, "15")
[c3s, c3a] = f_cell(cur, "60")
[c4s, c4a] = f_cell(cur, "240")

u1 = sym1 == "" ? cur : sym1
u2 = sym2 == "" ? cur : sym2
u3 = sym3 == "" ? cur : sym3
u4 = sym4 == "" ? cur : sym4
u5 = sym5 == "" ? cur : sym5
[s11, a11] = f_cell(u1, "5")
[s12, a12] = f_cell(u1, "15")
[s13, a13] = f_cell(u1, "60")
[s14, a14] = f_cell(u1, "240")
[s21, a21] = f_cell(u2, "5")
[s22, a22] = f_cell(u2, "15")
[s23, a23] = f_cell(u2, "60")
[s24, a24] = f_cell(u2, "240")
[s31, a31] = f_cell(u3, "5")
[s32, a32] = f_cell(u3, "15")
[s33, a33] = f_cell(u3, "60")
[s34, a34] = f_cell(u3, "240")
[s41, a41] = f_cell(u4, "5")
[s42, a42] = f_cell(u4, "15")
[s43, a43] = f_cell(u4, "60")
[s44, a44] = f_cell(u4, "240")
[s51, a51] = f_cell(u5, "5")
[s52, a52] = f_cell(u5, "15")
[s53, a53] = f_cell(u5, "60")
[s54, a54] = f_cell(u5, "240")

var table scr = table.new(f_pos(scrPos), 6, 7, bgcolor=cDashBg, frame_color=cDashFrame, frame_width=1, border_color=cDashFrame, border_width=1)

f_scell(int r, int c, int st, int age) =>
    bool fresh = age <= freshBars
    color base = st == 1 ? cBull : st == -1 ? cBear : cNeut
    table.cell(scr, c, r, st == 1 ? "▲" : st == -1 ? "▼" : "-", text_color=fresh ? #ffffff : color.new(base, 15), text_size=f_size(scrSize), bgcolor=color.new(base, fresh ? 40 : 82), text_font_family=font.family_monospace)

f_srow(int r, string name, bool pinned, int a, int b, int c, int d, int aa, int ab, int ac, int ad) =>
    int cnt = (a == 1 ? 1 : 0) + (b == 1 ? 1 : 0) + (c == 1 ? 1 : 0) + (d == 1 ? 1 : 0)
    table.cell(scr, 0, r, (pinned ? "▸" : " ") + name, text_color=pinned ? cGold : cText, text_size=f_size(scrSize), text_halign=text.align_left, bgcolor=pinned ? color.new(cGold, 80) : color.new(cDashBg, 6), text_font_family=font.family_monospace)
    f_scell(r, 1, a, aa)
    f_scell(r, 2, b, ab)
    f_scell(r, 3, c, ac)
    f_scell(r, 4, d, ad)
    string vTxt = cnt == 4 ? "A+▲" : cnt == 0 ? "A+▼" : str.tostring(cnt) + "▲"
    color  vCol = cnt == 4 ? cBull : cnt == 0 ? cBear : cnt >= 2 ? color.new(cBull, 40) : color.new(cBear, 40)
    table.cell(scr, 5, r, vTxt, text_color=#ffffff, text_size=f_size(scrSize), bgcolor=color.new(vCol, 50), text_font_family=font.family_monospace)

if scrOn and barstate.islast
    table.cell(scr, 0, 0, "NKB·MTF", text_color=cText, text_size=f_size(scrSize), text_halign=text.align_left, text_font_family=font.family_monospace)
    table.cell(scr, 1, 0, "5m",  text_color=cGold, text_size=f_size(scrSize), text_font_family=font.family_monospace)
    table.cell(scr, 2, 0, "15m", text_color=cNeut, text_size=f_size(scrSize), text_font_family=font.family_monospace)
    table.cell(scr, 3, 0, "1h",  text_color=cNeut, text_size=f_size(scrSize), text_font_family=font.family_monospace)
    table.cell(scr, 4, 0, "4h",  text_color=cNeut, text_size=f_size(scrSize), text_font_family=font.family_monospace)
    table.cell(scr, 5, 0, "Σ",   text_color=cText, text_size=f_size(scrSize), text_font_family=font.family_monospace)
    f_srow(1, syminfo.ticker, true, c1s, c2s, c3s, c4s, c1a, c2a, c3a, c4a)
    int r = 2
    if sym1 != ""
        f_srow(r, str.replace(sym1, syminfo.prefix + ":", "", 0), false, s11, s12, s13, s14, a11, a12, a13, a14)
        r += 1
    if sym2 != ""
        f_srow(r, str.replace(sym2, syminfo.prefix + ":", "", 0), false, s21, s22, s23, s24, a21, a22, a23, a24)
        r += 1
    if sym3 != ""
        f_srow(r, str.replace(sym3, syminfo.prefix + ":", "", 0), false, s31, s32, s33, s34, a31, a32, a33, a34)
        r += 1
    if sym4 != ""
        f_srow(r, str.replace(sym4, syminfo.prefix + ":", "", 0), false, s41, s42, s43, s44, a41, a42, a43, a44)
        r += 1
    if sym5 != ""
        f_srow(r, str.replace(sym5, syminfo.prefix + ":", "", 0), false, s51, s52, s53, s54, a51, a52, a53, a54)

// ═══════════════════════════════════════════════════════════════════════════
//  ALERT CONDITIONS  (all on bar close, non-repainting)
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(buySig,      "NKB - BUY",                     "NKB [vault]: BUY {{ticker}} {{interval}} @ {{close}}")
alertcondition(sellSig,     "NKB - SELL",                    "NKB [vault]: SELL {{ticker}} {{interval}} @ {{close}}")
alertcondition(exitLong,    "NKB - EXIT LONG",               "NKB [vault]: CLOSE LONG {{ticker}} {{interval}} @ {{close}}")
alertcondition(exitShort,   "NKB - EXIT SHORT",              "NKB [vault]: CLOSE SHORT {{ticker}} {{interval}} @ {{close}}")
alertcondition(bullFlip,    "NKB - Bullish Breakout",        "NKB [vault]: bullish breakout {{ticker}} {{interval}}")
alertcondition(bearFlip,    "NKB - Bearish Breakdown",       "NKB [vault]: bearish breakdown {{ticker}} {{interval}}")
alertcondition(bullDiv,     "NKB - Bullish Divergence",      "NKB [vault]: bullish divergence {{ticker}} {{interval}}")
alertcondition(bearDiv,     "NKB - Bearish Divergence",      "NKB [vault]: bearish divergence {{ticker}} {{interval}}")
alertcondition(regimeShift, "NKB - Bandwidth Regime Shift",  "NKB [vault]: bandwidth regime shift {{ticker}} {{interval}}")
alertcondition(revTop,      "NKB - Reversal at Top",         "NKB [vault]: reversal candle at top {{ticker}} {{interval}}")
alertcondition(revBot,      "NKB - Reversal at Bottom",      "NKB [vault]: reversal candle at bottom {{ticker}} {{interval}}")
alertcondition(dzEntered,   "NKB - Dead Zone Entered",       "NKB [vault]: dead zone entered {{ticker}} {{interval}}")
alertcondition(dzCleared,   "NKB - Dead Zone Cleared",       "NKB [vault]: dead zone cleared {{ticker}} {{interval}}")
alertcondition(momBull,     "NKB - Momentum Shift BULLISH",  "NKB [vault]: momentum turned up {{ticker}} {{interval}}")
alertcondition(momBear,     "NKB - Momentum Shift BEARISH",  "NKB [vault]: momentum turned down {{ticker}} {{interval}}")
alertcondition(momBull or momBear, "NKB - Momentum Shift (any)", "NKB [vault]: momentum shift {{ticker}} {{interval}}")
alertcondition(bullFlip or bearFlip, "NKB - Kernel State Flip", "NKB [vault]: kernel state flipped {{ticker}} {{interval}}")

if dzEntered
    alert("NKB [vault] DEAD ZONE ENTERED " + syminfo.ticker + " " + timeframe.period + " | score " + str.tostring(dzScore) + "/5 | " + dzWhy, alert.freq_once_per_bar_close)
if dzCleared
    alert("NKB [vault] DEAD ZONE CLEARED " + syminfo.ticker + " " + timeframe.period + " | lasted " + str.tostring(dzBars) + " bars", alert.freq_once_per_bar_close)
````
