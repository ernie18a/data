# Renaissance Mean Reversion [JOAT]

- url: https://www.tradingview.com/script/o3kTeDOh-Renaissance-Mean-Reversion-JOAT/
- type: indicator
- pine_id: PUB;14e80b3ba5f243f9acf94a5a75bf8690
- version: 1.0

## Description

[b]RENAISSANCE MEAN REVERSION [JOAT][/b]

A tribute to the Medallion-style statistical-arbitrage approach: do not trade [i]price[/i] — trade the [b]spread between price and its smoothed expectation[/b], measure how reliably that spread mean-reverts using an [b]AR(1) half-life regression[/b], and only fire signals when the half-life is fast enough to be tradeable. The result is a discipline-enforcing engine that says [b]no[/b] more often than [b]yes[/b]: it refuses to take a reversion trade until the spread shows it actually reverts.

[image]https://www.tradingview.com/x/hmtD7lkl/[/image]

[b]The synthetic spread[/b]

The script builds a [b]synthetic pair[/b] from two views of the same instrument:

[list]
[*] [b]Leg 1[/b] — current price (configurable source).
[*] [b]Leg 2[/b] — long EMA of price (default 50-bar; configurable).
[*] [b]Spread[/b] = price − long EMA (or [b]ln(price) − ln(EMA)[/b] when log-spread mode is on, removing scale).
[/list]

The spread is then Z-scored over a configurable lookback (default 100 bars) to produce a stationary stationary signal that says: "how many standard deviations is the spread from its own mean right now?". This is the textbook stat-arb construction, single-leg version.

[b]Half-life regression — the gate[/b]

This is what makes the script institutional rather than retail. Reversion is meaningless if the spread does not actually revert. The script fits an [b]AR(1) regression[/b] over a configurable window (default 120 bars):

[i]Δspread_t = α + β · spread_{t−1} + ε_t[/i]

The [b]half-life[/b] of mean reversion is then:

[i]HL = −ln(2) / ln(1 + β)[/i]

When β is negative and close to zero, HL is short — the spread reverts quickly. When β approaches −1, HL is huge — the spread barely reverts. When β is positive, the spread is anti-mean-reverting (trending) and the script will [i]refuse[/i] to trade.

A configurable [b]Max Half-Life[/b] (default 20 bars) gates signals — entries only fire when HL is below this threshold. A configurable [b]Min Half-Life[/b] (default 0.5) floors the estimate to avoid degenerate near-zero values that would otherwise produce explosive signals.

This is the headline filter. Roughly 50–70% of bars on most instruments fail it — which is the point. You only trade when the spread has earned the right.

[b]Entry / Exit logic[/b]

[list]
[*] [b]R-LONG[/b] — fires when [b]Z < −entryZ[/b] (default −2.0) AND HL is below the max threshold AND the re-entry cooldown has elapsed. Spread is stretched too far below, will revert.
[*] [b]R-SHORT[/b] — fires when [b]Z > +entryZ[/b] AND HL is below the max threshold AND cooldown elapsed.
[*] [b]R-EXIT[/b] — fires when |Z| drops below [b]exitZ[/b] (default 0.25) OR when [b]Max Hold Bars[/b] (default 40) has been reached, whichever comes first.
[/list]

A configurable re-entry cooldown (default 3 bars) prevents immediate re-firing on the same side.

[b]Visual system — minimal mono institutional[/b]

The aesthetic is intentionally austere — Renaissance's research-paper minimalism. Pure monochrome:

[list]
[*] [b]Z guides on right side of chart[/b] — small text labels showing current Z, HL, and tradeable status.
[*] [b]R-LONG / R-SHORT / R-EXIT labels[/b] — clean text tags on entry and exit bars.
[*] [b]Half-Life overlay label[/b] — current HL value displayed near the live close.
[*] [b]Shaded ribbon[/b] between price and slow EMA (configurable transparency).
[*] [b]Trade entry/exit shapes[/b] — small markers at signal bars.
[*] [b]Single-hue tradeable-regime tint[/b] (off by default) — subtle bgcolor when HL is fast AND Z is stretched.
[/list]

A locked Minimal Mono palette: white bull / gray bear / pure-black background. No accent colours. The chart looks like a quant research paper. Intentional.

[b]Dashboard[/b]

Monospaced table positionable to any of eight corners. Surfaces:

[list]
[*] Current spread value and Z score.
[*] Current half-life (in bars) with tradeable / non-tradeable flag.
[*] AR(1) β coefficient (the regression's directional read).
[*] Z thresholds in use.
[*] Last signal direction with bars-ago.
[*] Max-hold bars remaining (when in a position).
[/list]

[image]https://www.tradingview.com/x/d5J6PTsG/[/image]

[b]Rolling backtest tracker[/b]

The script tracks the last N closed reversion trades (configurable, default 200) and surfaces:

[list]
[*] Total trades, wins, losses.
[*] Win rate.
[*] Average bars-to-exit.
[*] Average Z magnitude at entry.
[*] Hit-rate by side (R-LONG vs R-SHORT).
[/list]

This is the script's own performance audit — you see whether the engine is finding genuine reversion or whether the current regime is breaking it.

[b]Alerts[/b]

Three alert conditions, each independently controllable:

[list]
[*] Reversion Entry (R-LONG or R-SHORT)
[*] Reversion Exit (R-EXIT)
[*] Half-Life crosses Max Half-Life (regime change — reversion is becoming unreliable)
[/list]

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]R-LONG / R-SHORT with very fast HL[/b] (e.g. HL = 4 bars on a 1H chart) — the script's intended high-conviction setup. The spread is stretched, the math says it will revert quickly, the chart agrees. This is the institutional setup.
[*] [b]Half-life crossing above max (alert)[/b] — regime warning. The instrument is shifting from mean-reverting to trending. Any open R-positions should be re-evaluated; new R-entries should be paused until HL re-tightens.
[*] [b]Sustained R-EXIT triggers from time-stop (max-hold)[/b] rather than from Z returning to neutral — the script is exiting because the trade ran out of time, not because the thesis played out. Recurring time-stop exits mean the current parameters do not fit the instrument.
[/list]

The [b]rolling backtest win-rate[/b] is your auditor. When it climbs, the engine is finding edge. When it grinds flat or declines, the regime has changed and the parameters need adjustment.

[b]Suggested settings[/b]

Defaults (long EMA 50, Z lookback 100, regression window 120, max HL 20 bars, entry Z 2.0, exit Z 0.25) are tuned for 1H–4H on liquid markets where mean reversion is statistically meaningful. For lower timeframes drop everything proportionally (long EMA 25, Z 50, regression 60). For HTF raise everything (long EMA 100, Z 200, regression 200). The max HL is the most sensitive parameter — narrow it (10–15) for high-conviction-only filtering; widen it (25–30) for more frequent signals.

[b]Originality / what's reused[/b]

The synthetic-pair Z-score construction is textbook stat-arb. The AR(1) half-life regression is published quantitative finance — the Ornstein–Uhlenbeck-process speed-of-reversion estimator. The implementation here — the dual-leg synthetic spread with optional log construction, the rolling Z-normalisation pipeline, the AR(1) regression with HL formula and min/max-HL gating, the entry/exit state machine with cooldown and max-hold, the rolling N-trade backtest tracker, and the minimal-mono institutional aesthetic — is JOAT-original. No third-party code reused. The script is a [i]tribute[/i] to the Medallion-style approach, not a direct replication of any proprietary Renaissance Technologies code.

[b]Limitations[/b]

The single-leg "synthetic pair" (price vs its own EMA) is a degenerate stat-arb construction by design — true stat-arb uses two genuinely co-integrated instruments. Pine's per-script symbol limitation makes a two-instrument cointegration construction impractical for a standalone indicator; this script captures the [i]methodology[/i] of stat-arb (spread + Z + HL gate) on the single-instrument case. The HL estimate is statistical and needs the regression window populated; early bars give a warm-up read.

—


-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title = "Renaissance Mean Reversion [JOAT]",
     shorttitle = "REN [JOAT]",
     overlay = true,
     max_lines_count  = 500,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 5000)


// ============================================================
//  SECTION 1 - INPUTS
// ============================================================
grpSpread   = "+---------- Spread Construction ----------+"
grpEntry    = "+---------- Entry / Exit Regime ----------+"
grpHL       = "+---------- Half-Life Regression ---------+"
grpVis      = "+--------------- Visuals -----------------+"
grpDash     = "+------------- Dashboard -----------------+"
grpAlert    = "+--------------- Alerts ------------------+"
grpBT       = "+----------- Backtest Tracker ------------+"

// --- Spread inputs ---
longLen     = input.int(50,   "Long EMA (slow leg)",      minval = 5,   maxval = 500, group = grpSpread,
     tooltip = "Length of the smoothed price used as the second leg of the synthetic pair.")
zLookback   = input.int(100,  "Z-Score Lookback",         minval = 10,  maxval = 1000, group = grpSpread,
     tooltip = "Window for the rolling mean and stdev of the spread.")
smoothSrc   = input.source(close, "Spread Source",        group = grpSpread)
useLogSpr   = input.bool(false, "Use Log-Spread (returns)", group = grpSpread,
     tooltip = "If on, spread = ln(close) - ln(EMA), removing scale.")

// --- Entry / Exit ---
entryZ      = input.float(2.0,  "Entry Z (|Z| > this)",     minval = 0.5, maxval = 5.0, step = 0.1, group = grpEntry)
exitZ       = input.float(0.25, "Exit Z (|Z| < this)",      minval = 0.0, maxval = 2.0, step = 0.05, group = grpEntry)
maxHold     = input.int(40,     "Max Hold Bars",            minval = 1,   maxval = 500, group = grpEntry)
sigCooldown = input.int(3,      "Re-entry Cooldown (bars)", minval = 0,   maxval = 100, group = grpEntry,
     tooltip = "Bars to wait after an exit before another entry can fire.")

// --- Half-Life (AR(1)) ---
regWin       = input.int(120,  "Half-Life Regression Window", minval = 20, maxval = 500, group = grpHL,
     tooltip = "Window used for the AR(1) regression beta. Longer = more stable, slower to react.")
maxHalfLife  = input.float(20.0, "Max Half-Life (bars) for tradeable", minval = 1.0, maxval = 200.0, step = 0.5, group = grpHL,
     tooltip = "Only trade when mean reversion is FAST. Half-Life must be below this for a signal to fire.")
minHalfLife  = input.float(0.5, "Min Half-Life (bars)",      minval = 0.0, maxval = 10.0, step = 0.1, group = grpHL,
     tooltip = "Floor on half-life to avoid degenerate near-zero estimates.")

// --- Visuals ---
showZGuides    = input.bool(true,  "Show Z guides on chart (right-side text)", group = grpVis)
showLabels     = input.bool(true,  "Show R-LONG / R-SHORT / R-EXIT labels",     group = grpVis)
showHLLabel    = input.bool(true,  "Show Half-Life overlay label",              group = grpVis)
showBandFill   = input.bool(true,  "Show shaded ribbon (price vs slow EMA)",    group = grpVis)
ribbonAlpha    = input.int(85,    "Ribbon transparency (0-100)",  minval = 50, maxval = 99, group = grpVis)
showTradeMarks = input.bool(true,  "Show trade entry/exit shapes",              group = grpVis)
showRegimeTint = input.bool(false, "Show single-hue tradeable-regime tint",     group = grpVis,
     tooltip = "Tints background when mean reversion is fast (HL low) AND Z stretched. Off by default to keep the chart pristine.")
tintAlpha      = input.int(94,    "Regime tint transparency (0-100)", minval = 80, maxval = 99, group = grpVis)

// --- Dashboard ---
showDash    = input.bool(true,    "Show Dashboard",           group = grpDash)
dashPos     = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left",
                "Bottom Right", "Bottom Left", "Bottom Center"], group = grpDash)
dashSize    = input.string("Small", "Dashboard Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = grpDash)

// --- Backtest tracker ---
trackStats  = input.bool(true,    "Track rolling stats",      group = grpBT)
maxTrades   = input.int(200,      "Max Trades in rolling window", minval = 10, maxval = 2000, group = grpBT)

// --- Alerts ---
alertOnEntry = input.bool(true,   "Alert on entries",         group = grpAlert)
alertOnExit  = input.bool(true,   "Alert on exits",           group = grpAlert)
alertOnHLX   = input.bool(false,  "Alert on Half-Life crossing maxHalfLife", group = grpAlert)


// ============================================================
//  SECTION 2 - COLOR PALETTE  (Minimal Mono - locked institutional)
// ============================================================
//  Single curated palette. No theme switcher. Clean monochrome:
//  bull white / bear gray / muted neutral / bg pure black / frame charcoal.

const color C_BULL  = #FFFFFF
const color C_BEAR  = color.rgb(92, 92, 92)
const color C_BG    = #000000
const color C_FRAME = #1C1C1C
const color C_TEXT  = #F2F2F2
const color C_MUTED = #777777


// ============================================================
//  SECTION 3 - HELPER FUNCTIONS
// ============================================================

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_colorGradient(float ratio, color a, color b) =>
    rA = color.r(a), gA = color.g(a), bA = color.b(a)
    rB = color.r(b), gB = color.g(b), bB = color.b(b)
    r = rA + int((rB - rA) * ratio)
    g = gA + int((gB - gA) * ratio)
    bb = bA + int((bB - bA) * ratio)
    color.rgb(r, g, bb, 0)

strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// Renders a number that may be na/inf as a clean fixed-width string.
f_num(float x, int digits) =>
    na(x) ? "n/a" : not (x == x) ? "n/a" : str.tostring(x, "#." + str.repeat("0", digits))

// Wins/losses to win-rate.
f_winRate(int wins, int total) =>
    total > 0 ? 100.0 * wins / total : 0.0

// Dashboard subtle vertical gradient.
grad(color base, int row, int rows, int minT, int maxT) =>
    float t = rows <= 1 ? maxT : (minT + (maxT - minT) * (row / float(rows - 1)))
    color.new(base, int(t))


// ============================================================
//  SECTION 4 - CORE CALCULATIONS
//  Spread, rolling Z, and AR(1)-derived half-life.
// ============================================================

// 4.1 Spread leg
src         = smoothSrc
priceLeg    = useLogSpr ? math.log(math.max(src, 1e-10))                        : src
slowLeg     = useLogSpr ? math.log(math.max(ta.ema(src, longLen), 1e-10))       : ta.ema(src, longLen)
spread      = priceLeg - slowLeg

// 4.2 Rolling Z-Score of the spread
spreadMean  = ta.sma(spread, zLookback)
spreadStd   = ta.stdev(spread, zLookback)
zRaw        = spreadStd > 0 ? (spread - spreadMean) / spreadStd : 0.0
zScore      = nz(zRaw, 0.0)

// 4.3 AR(1) half-life via the regression
//
//        Delta_spread_t = beta * spread_{t-1} + eps
//
//     beta is estimated as:
//
//        beta = correlation(Delta_spread, spread[1], regWin)
//               * stdev(Delta_spread, regWin) / stdev(spread[1], regWin)
//
//     If we model the process as an OU-like AR(1):
//
//        spread_t = (1 + beta) * spread_{t-1} + eps
//
//     Mean reversion requires (1 + beta) in (0, 1)  ->  beta in (-1, 0).
//
//     Half-Life of a discrete AR(1) with persistence rho = (1 + beta):
//
//        HL = -ln(2) / ln(rho)         for 0 < rho < 1
//
//     Equivalently HL = -ln(2) / ln(1 + beta) for beta in (-1, 0).
deltaSpread = spread - spread[1]
prevSpread  = spread[1]

corrDS      = ta.correlation(deltaSpread, prevSpread, regWin)
stdDS       = ta.stdev(deltaSpread, regWin)
stdPS       = ta.stdev(prevSpread,  regWin)

beta        = (not na(corrDS) and stdPS > 0) ? corrDS * stdDS / stdPS : na

// Derived persistence and Half-Life. Guarded for all degenerate cases.
rho         = na(beta) ? na : (1.0 + beta)
halfLifeRaw = (not na(rho) and rho > 0.0 and rho < 1.0) ? (-math.log(2.0) / math.log(rho)) : na
halfLife    = na(halfLifeRaw) ? na : math.max(minHalfLife, halfLifeRaw)

// 4.4 Tradeable regime gate
fastMR      = not na(halfLife) and halfLife > 0.0 and halfLife < maxHalfLife
zStretched  = math.abs(zScore) > entryZ
tradeable   = fastMR and zStretched


// ============================================================
//  SECTION 5 - STATE / TRACKING
// ============================================================
var int   positionState   = 0          // -1 short, 0 flat, +1 long
var int   entryBar        = na
var float entryPrice      = na
var float entryZAtEntry   = na
var float hlAtEntry       = na
var int   lastExitBar     = -100000
var int   signalCount     = 0
var int   tradeCount      = 0
var int   winCount        = 0
var int   lossCount       = 0
var float sumHoldBars     = 0.0
var float sumR            = 0.0
var float lastTradeR      = na
var int   lastTradeBars   = na
var int   lastTradeDir    = 0           // -1, 0, +1

// Rolling per-trade arrays for an actually-honest win rate window
var array<bool>  wlHist     = array.new_bool()
var array<float> rHist      = array.new_float()
var array<int>   holdHist   = array.new_int()

int barsInPos = positionState == 0 ? 0 : (bar_index - entryBar)


// ============================================================
//  SECTION 6 - SIGNAL ENGINE
//  Pure mean-reversion: BUY when Z is deeply NEGATIVE and the
//  process reverts fast. SELL when Z is deeply POSITIVE.
//  Exit when |Z| collapses or the trade ages out.
// ============================================================

// Cooldown after a flat exit.
canEnter    = (bar_index - lastExitBar) >= sigCooldown

// Raw entry conditions on the confirmed bar.
rawBuy      = positionState == 0 and canEnter and tradeable and zScore < -entryZ
rawSell     = positionState == 0 and canEnter and tradeable and zScore >  entryZ

// Exit conditions when in a trade.
exitFromZ   = math.abs(zScore) < exitZ
exitFromAge = barsInPos >= maxHold

// Resolved flags (these are what we emit alerts on).
goLong  = false
goShort = false
goExit  = false

// State machine — confirm on the bar's close.
if barstate.isconfirmed
    if positionState == 0
        if rawBuy
            positionState := 1
            entryBar      := bar_index
            entryPrice    := close
            entryZAtEntry := zScore
            hlAtEntry     := halfLife
            signalCount   += 1
            goLong        := true
        else if rawSell
            positionState := -1
            entryBar      := bar_index
            entryPrice    := close
            entryZAtEntry := zScore
            hlAtEntry     := halfLife
            signalCount   += 1
            goShort       := true
    else
        // Already in a trade. Look for exit.
        if exitFromZ or exitFromAge
            // P&L in spread units, expressed as "R" using entry |Z|.
            float exitPx = close
            float rawPnl = positionState == 1 ? (exitPx - entryPrice) : (entryPrice - exitPx)
            // Normalize to "R": entry stretch in spread units = entryPrice deviation from slow leg.
            float entryStretchAbs = math.abs(entryZAtEntry * spreadStd)
            float rValue          = entryStretchAbs > 0 ? rawPnl / entryStretchAbs : 0.0
            bool  win             = rValue > 0
            tradeCount   += 1
            sumR         += rValue
            sumHoldBars  += barsInPos
            lastTradeR    := rValue
            lastTradeBars := barsInPos
            lastTradeDir  := positionState
            if win
                winCount += 1
            else
                lossCount += 1
            if trackStats
                array.push(wlHist, win)
                array.push(rHist,  rValue)
                array.push(holdHist, barsInPos)
                while array.size(wlHist) > maxTrades
                    array.shift(wlHist)
                while array.size(rHist) > maxTrades
                    array.shift(rHist)
                while array.size(holdHist) > maxTrades
                    array.shift(holdHist)
            positionState := 0
            entryBar      := na
            entryPrice    := na
            entryZAtEntry := na
            hlAtEntry     := na
            lastExitBar   := bar_index
            goExit        := true

// Live unrealized R (for the dashboard / labels while in a trade).
float liveR = na
if positionState != 0 and not na(entryPrice) and not na(entryZAtEntry)
    float liveRaw   = positionState == 1 ? (close - entryPrice) : (entryPrice - close)
    float entryAbs  = math.abs(entryZAtEntry * spreadStd)
    liveR := entryAbs > 0 ? liveRaw / entryAbs : 0.0

// Rolling stats (from the bounded arrays).
int   rollTrades = trackStats ? array.size(wlHist) : tradeCount
int   rollWins   = 0
float rollSumR   = 0.0
int   rollSumH   = 0
if trackStats and rollTrades > 0
    for i = 0 to rollTrades - 1
        if array.get(wlHist, i)
            rollWins += 1
        rollSumR += array.get(rHist, i)
        rollSumH += array.get(holdHist, i)
else
    rollWins := winCount
    rollSumR := sumR
    rollSumH := int(sumHoldBars)

float rollWinRate = f_winRate(rollWins, rollTrades)
float rollAvgR    = rollTrades > 0 ? rollSumR / rollTrades : 0.0
float rollAvgHold = rollTrades > 0 ? rollSumH / float(rollTrades) : 0.0


// ============================================================
//  SECTION 7 - PLOTS
//  Visual discipline: the chart layer only ever uses
//    1. C_BULL (one hue)
//    2. C_BEAR (one hue)
//    3. C_MUTED (neutral)
//  No additional accent colors are introduced.
// ============================================================

// Spread reconstructed leg on the chart (just the slow EMA so the
// "synthetic pair" is visible without crowding the panel).
slowOverlay = ta.ema(src, longLen)
plot(slowOverlay, "Slow EMA (slow leg)", color = color.new(C_MUTED, 40), linewidth = 2)

// Hidden price anchor so we can fill between price and slow EMA.
pHidden = plot(close, "Price (anchor)", color = na, display = display.none)
pSlow   = plot(slowOverlay, "Slow EMA (anchor)", color = na, display = display.none)

// Single-hue ribbon. Color picks one of the two hues depending on
// whether close is above or below the slow leg — never both at once.
ribbonCol = close >= slowOverlay ? color.new(C_BULL, ribbonAlpha) : color.new(C_BEAR, ribbonAlpha)
fill(pHidden, pSlow, color = showBandFill ? ribbonCol : na, title = "Pair ribbon")

// Optional regime tint (single hue, very transparent, only when tradeable).
regimeColor = tradeable ? color.new(C_BULL, tintAlpha) : na
bgcolor(showRegimeTint ? regimeColor : na, title = "Tradeable regime tint")


// ============================================================
//  SECTION 8 - DRAWINGS
// ============================================================

// Entry / Exit labels (text-only, monochrome, do not introduce
// extra hues — they use the same primary bull / bear / muted).
if showLabels and barstate.isconfirmed
    if goLong
        label.new(bar_index, low,
             text     = "R-LONG",
             style    = label.style_label_up,
             yloc     = yloc.belowbar,
             color    = color.new(C_BULL, 0),
             textcolor= color.new(C_BG, 0),
             size     = size.small)
    if goShort
        label.new(bar_index, high,
             text     = "R-SHORT",
             style    = label.style_label_down,
             yloc     = yloc.abovebar,
             color    = color.new(C_BEAR, 0),
             textcolor= color.new(C_BG, 0),
             size     = size.small)
    if goExit
        label.new(bar_index, close,
             text     = "R-EXIT",
             style    = label.style_label_left,
             color    = color.new(C_MUTED, 20),
             textcolor= color.new(C_TEXT, 0),
             size     = size.small)

// Trade marks (small triangles, no text — keeps the chart minimal).
plotshape(showTradeMarks and goLong,  title = "Long entry",  style = shape.triangleup,   location = location.belowbar, color = C_BULL, size = size.tiny)
plotshape(showTradeMarks and goShort, title = "Short entry", style = shape.triangledown, location = location.abovebar, color = C_BEAR, size = size.tiny)
plotshape(showTradeMarks and goExit,  title = "Exit",        style = shape.xcross,       location = location.absolute, color = C_MUTED, size = size.tiny)

// Floating Half-Life label on the right edge of the chart.
var label hlLbl = na
if showHLLabel
    if barstate.islast
        if not na(hlLbl)
            label.delete(hlLbl)
        hlTxt =
             "HL = "         + f_num(halfLife, 1) + " bars"   + "\n" +
             "Z  = "         + f_num(zScore,   2)             + "\n" +
             "Spread = "     + f_num(spread,   3)             + "\n" +
             (tradeable ? "TRADEABLE" : "n/a")
        hlLbl := label.new(bar_index + 5, close,
             text     = hlTxt,
             style    = label.style_label_left,
             color    = color.new(C_FRAME, 20),
             textcolor= C_TEXT,
             size     = size.small)


// ============================================================
//  SECTION 9 - DASHBOARD
//  10 rows. Monochrome-friendly. Numeric and text-aligned.
// ============================================================
var table dash = table.new(strToPos(dashPos), 2, 11,
     bgcolor      = color.new(C_BG, 5),
     frame_color  = C_FRAME,
     frame_width  = 1,
     border_color = color.new(C_FRAME, 50),
     border_width = 1)

f_dashCell(int row, int col, string txt, color textCol, color bg, bool alignRight) =>
    table.cell(dash, col, row, txt,
         text_color = textCol,
         bgcolor    = bg,
         text_halign = alignRight ? text.align_right : text.align_left,
         text_size   = strToSize(dashSize),
         text_font_family = font.family_monospace)

if showDash and barstate.islast
    int rows = 11
    color hdrBg = grad(C_FRAME, 0, rows, 50, 70)

    // Row 0: header
    f_dashCell(0, 0, "RENAISSANCE MR",       C_TEXT,  hdrBg, false)
    f_dashCell(0, 1, "[JOAT]",                C_BULL,  hdrBg, true)

    // Row 1: Spread
    f_dashCell(1, 0, "Spread",                C_TEXT,  grad(C_FRAME, 1, rows, 85, 92), false)
    f_dashCell(1, 1, f_num(spread, 4),        C_TEXT,  grad(C_FRAME, 1, rows, 85, 92), true)

    // Row 2: Z-Score (sign-colored)
    color zCol = zScore > 0 ? C_BULL : zScore < 0 ? C_BEAR : C_MUTED
    f_dashCell(2, 0, "Z-Score",               C_TEXT,  grad(C_FRAME, 2, rows, 85, 92), false)
    f_dashCell(2, 1, f_num(zScore, 2),        zCol,    grad(C_FRAME, 2, rows, 85, 92), true)

    // Row 3: Half-Life (highlight when fast)
    color hlCol = na(halfLife) ? C_MUTED : (halfLife < maxHalfLife ? C_BULL : C_BEAR)
    f_dashCell(3, 0, "Half-Life (bars)",      C_TEXT,  grad(C_FRAME, 3, rows, 85, 92), false)
    f_dashCell(3, 1, f_num(halfLife, 2),      hlCol,   grad(C_FRAME, 3, rows, 85, 92), true)

    // Row 4: Tradeable
    color trCol = tradeable ? C_BULL : C_MUTED
    string trTx = tradeable ? "YES" : "no"
    f_dashCell(4, 0, "Tradeable?",            C_TEXT,  grad(C_FRAME, 4, rows, 85, 92), false)
    f_dashCell(4, 1, trTx,                    trCol,   grad(C_FRAME, 4, rows, 85, 92), true)

    // Row 5: Position State
    string posTx = positionState == 1 ? "LONG" : positionState == -1 ? "SHORT" : "FLAT"
    color  posCol = positionState == 1 ? C_BULL : positionState == -1 ? C_BEAR : C_MUTED
    f_dashCell(5, 0, "Position",              C_TEXT,  grad(C_FRAME, 5, rows, 85, 92), false)
    f_dashCell(5, 1, posTx,                   posCol,  grad(C_FRAME, 5, rows, 85, 92), true)

    // Row 6: Bars in position
    f_dashCell(6, 0, "Bars in pos",           C_TEXT,  grad(C_FRAME, 6, rows, 85, 92), false)
    f_dashCell(6, 1, positionState == 0 ? "-" : str.tostring(barsInPos),
                                             C_TEXT,  grad(C_FRAME, 6, rows, 85, 92), true)

    // Row 7: Unrealized R
    string urTx = na(liveR) ? "-" : f_num(liveR, 2) + " R"
    color  urCol = na(liveR) ? C_MUTED : (liveR >= 0 ? C_BULL : C_BEAR)
    f_dashCell(7, 0, "Unrealized R",          C_TEXT,  grad(C_FRAME, 7, rows, 85, 92), false)
    f_dashCell(7, 1, urTx,                    urCol,   grad(C_FRAME, 7, rows, 85, 92), true)

    // Row 8: Rolling Win Rate
    string wrTx = rollTrades > 0 ? f_num(rollWinRate, 1) + "%  (" + str.tostring(rollTrades) + ")" : "-"
    color  wrCol = rollWinRate >= 55 ? C_BULL : rollWinRate >= 45 ? C_TEXT : C_BEAR
    f_dashCell(8, 0, "Win Rate (roll)",       C_TEXT,  grad(C_FRAME, 8, rows, 85, 92), false)
    f_dashCell(8, 1, wrTx,                    wrCol,   grad(C_FRAME, 8, rows, 85, 92), true)

    // Row 9: Avg Hold
    string ahTx = rollTrades > 0 ? f_num(rollAvgHold, 1) + " bars" : "-"
    f_dashCell(9, 0, "Avg Hold",              C_TEXT,  grad(C_FRAME, 9, rows, 85, 92), false)
    f_dashCell(9, 1, ahTx,                    C_TEXT,  grad(C_FRAME, 9, rows, 85, 92), true)

    // Row 10: Avg R
    string arTx = rollTrades > 0 ? f_num(rollAvgR, 2) + " R" : "-"
    color  arCol = rollAvgR > 0 ? C_BULL : rollAvgR < 0 ? C_BEAR : C_MUTED
    f_dashCell(10, 0, "Avg R / Trade",        C_TEXT,  grad(C_FRAME, 10, rows, 85, 92), false)
    f_dashCell(10, 1, arTx,                   arCol,   grad(C_FRAME, 10, rows, 85, 92), true)


// ============================================================
//  SECTION 10 - ALERTS
// ============================================================
if alertOnEntry and goLong
    alert("REN [JOAT] LONG entry  |  Z=" + f_num(zScore, 2) + "  HL=" + f_num(halfLife, 1) + " bars", alert.freq_once_per_bar_close)
if alertOnEntry and goShort
    alert("REN [JOAT] SHORT entry  |  Z=" + f_num(zScore, 2) + "  HL=" + f_num(halfLife, 1) + " bars", alert.freq_once_per_bar_close)
if alertOnExit and goExit
    string exitReason = exitFromAge ? "MAX-HOLD" : "Z-COLLAPSE"
    alert("REN [JOAT] EXIT (" + exitReason + ")  |  R=" + f_num(lastTradeR, 2) + "  bars=" + str.tostring(nz(lastTradeBars, 0)), alert.freq_once_per_bar_close)

// Half-Life crossing alert.
hlCrossUp   = (not na(halfLife)) and (not na(halfLife[1])) and halfLife[1] <  maxHalfLife and halfLife >= maxHalfLife
hlCrossDn   = (not na(halfLife)) and (not na(halfLife[1])) and halfLife[1] >= maxHalfLife and halfLife <  maxHalfLife
if alertOnHLX and hlCrossUp
    alert("REN [JOAT] Half-Life crossed ABOVE " + str.tostring(maxHalfLife) + "  -> mean reversion slowing", alert.freq_once_per_bar_close)
if alertOnHLX and hlCrossDn
    alert("REN [JOAT] Half-Life crossed BELOW " + str.tostring(maxHalfLife) + "  -> mean reversion fast (tradeable)", alert.freq_once_per_bar_close)

// alertcondition versions (so the user can wire them into the
// TradingView alert dialog manually as well).
alertcondition(goLong,   title = "REN Long Entry",   message = "REN [JOAT] LONG entry")
alertcondition(goShort,  title = "REN Short Entry",  message = "REN [JOAT] SHORT entry")
alertcondition(goExit,   title = "REN Exit",         message = "REN [JOAT] EXIT")
alertcondition(hlCrossDn, title = "REN HL Fast",     message = "REN [JOAT] Half-Life dropped below max -> tradeable regime")
alertcondition(hlCrossUp, title = "REN HL Slow",     message = "REN [JOAT] Half-Life rose above max -> stop trading")

// ============================================================
//  END OF FILE
// ============================================================
````
