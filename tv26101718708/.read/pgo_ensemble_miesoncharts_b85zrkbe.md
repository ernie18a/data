# PGO Ensemble [MiesOnCharts]

- url: https://www.tradingview.com/script/B85ZRKbe-PGO-Ensemble-MiesOnCharts/
- type: indicator
- pine_id: PUB;145d2fa6aab9428989b06d48b6fe7fd9
- version: 1.0

## Description

An ensemble of Pretty Good Oscillators, one for every length in a range. Each one measures how far price sits from its own moving average, in units of its own average true range, and each holds a long or short state. The plotted score is the margin of the vote across them, running from -1 when every member is short to +1 when every member is long.

Built with daily bars in mind. The inputs adjust for other timeframes.

[b]What PGO measures[/b]

Displacement from a moving average, divided by ATR over the same length. A reading of 2 means price sits two typical bars away from its own mean. Dividing by range is what makes it portable: the same number means the same thing on any symbol at any price.

[b]Why an ensemble[/b]

Any single length is an arbitrary pick, and the best one is only obvious afterwards. Short lengths react fast and whipsaw. Long lengths are steady and late.

The reason this works on PGO in particular is the ATR division. Raw distance from a mean cannot be pooled across lengths, because a long average sits further from price by construction and would dominate any average of the two. Dividing by range over the same length puts every member in identical units, so a short member disagreeing with a long one is real information rather than an artefact of scale.

[b]Members hold a state, not a reading[/b]

Each member latches long when it clears the upper threshold and stays long until it breaks the lower one. The vote counts positions rather than values, so a brief dip does not flip a member back.

The two thresholds are asymmetric on purpose. Price spends more time stretched above its mean than below in most markets, and a symmetric pair produces a permanent long bias.

A member that has never crossed either threshold contributes nothing. Early in a chart's history the score is muted for that reason, which is correct. Those members have no opinion yet.

[b]Signals[/b]

Score at or above the trend threshold turns the state to uptrend and everything green. At or below the mirror of it, downtrend and red. In between, the previous state holds, so a brief loss of agreement does not end a regime.

Triangles mark each flip in the pane and on the price chart, the candles carry the regime colour, and both flips have alerts.

[b]Inputs[/b]

[list]
[*] Source and MA Type: the price series, and the average each member measures displacement from. VWMA falls back to the simple average on symbols that carry no volume.
[*] Min Length, Max Length and Length Step: the range and spacing of the ensemble. A wider span mixes more timescales and gives a smoother score. Every member costs the same regardless of its length, so range is cheap here.
[*] Long Threshold and Short Threshold: how far a member must be displaced before it latches.
[*] Trend Threshold: how much of the ensemble must agree before the regime flips. Higher is more selective and later.
[*] Flat When Split: whether an undecided ensemble holds the last regime or drops to flat.
[*] Display toggles for the fill, the chart candles and the flip arrows.
[/list]

[b]How to use it[/b]

[list]
[*] Read the colour as a regime filter rather than an entry.
[*] Watch the score when it sits away from its extremes. A trend running with only half the ensemble behind it is resting on the short members alone.
[*] Displacement is not direction. A member can be latched long while price falls, because it is still stretched above its mean.
[/list]

[b]Limits[/b]

[list]
[*] It is reactive. It describes displacement that has already happened and will lag turns.
[*] Nearby lengths give similar answers, so a narrow range delivers less of the averaging benefit than a wide one.
[*] Latching cuts both ways. It holds a member through noise, and it also holds it too long when a move genuinely ends.
[*] The asymmetric thresholds assume the usual upward drift. On a market without one they should be evened out.
[*] No setting is right everywhere. Test on your own market and timeframe.
[/list]

[b]Credits[/b]

The Pretty Good Oscillator is Mark Johnson's. The TradingView implementation is Alex Orekhov's (everget). This script was inspired by QuantLapse's PGO variant, which is where the latching state and the asymmetric thresholds come from. The ensemble, the vote across it and the reconstruction of the members are the additions here.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice, nor a recommendation to buy or sell any asset.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MiesOnCharts

//   __  __ _
//  |  \/  (_) ___  ___
//  | |\/| | |/ _ \/ __|
//  | |  | | |  __/\__ \
//  |_|  |_|_|\___||___/

//@version=6
// ============================================================
//  PGO ENSEMBLE
//  An ensemble of Pretty Good Oscillators, one per length, each
//  latching its own long or short state and voting. The score is
//  the margin of that vote.
//
//  PGO = (src - MA(L)) / ATR(L). Dividing by ATR over the same
//  length puts every member in the same units, so a short member
//  disagreeing with a long one is real information rather than an
//  artefact of scale. That is the reason the ensemble is worth
//  building on this oscillator.
//
//  Credits: PGO is Mark Johnson's, and Alex Orekhov (everget)
//  wrote the TradingView version. Inspired by QuantLapse's
//  PGO variant.
// ============================================================
indicator("PGO Ensemble [MiesOnCharts]", shorttitle = "PGOE - Mies", overlay = false, max_bars_back = 300)

grpM = "Model"
grpT = "Thresholds"
grpD = "Display"

src     = input.source(close, "Source", group = grpM)
maType  = input.string("SMA", "MA Type", ["SMA", "EMA", "WMA", "VWMA"], group = grpM,
     tooltip = "The average each member measures displacement from. VWMA needs real volume, and falls back to the simple average on symbols that do not carry it.")
minLen  = input.int(6,  "Min Length", minval = 2, maxval = 200, group = grpM,
     tooltip = "Shortest member. These react first and are what pulls the score off an extreme early in a turn.")
maxLen  = input.int(30, "Max Length", minval = 3, maxval = 200, group = grpM,
     tooltip = "Longest member. Widening this cuts flips and adds lag. Every member costs the same regardless of length, so range is cheap here.")
lenStep = input.int(2,  "Length Step", minval = 1, group = grpM,
     tooltip = "Spacing between members. Smaller gives a finer score at a small runtime cost.")

upThr = input.float(1.35, "Long Threshold", step = 0.05, group = grpT,
     tooltip = "ATR units above the mean a member must reach to latch long. Set higher than the mirror of the short threshold on purpose, since price sits stretched above its mean more often than below.")
dnThr = input.float(-1.0, "Short Threshold", step = 0.05, group = grpT,
     tooltip = "ATR units below the mean a member must reach to latch short. Once latched a member holds that state until the opposite threshold is taken.")

scoreThr  = input.float(0.6, "Trend Threshold", minval = 0.05, maxval = 1.0, step = 0.05, group = grpT,
     tooltip = "How much of the ensemble must agree before the regime flips. A style dial for flip count and lag rather than a tuning knob.")
flatSplit = input.bool(false, "Flat When Split", group = grpT,
     tooltip = "Off holds the last regime while the ensemble is undecided. On drops to flat, which roughly doubles turnover.")

showFill  = input.bool(true,  "Fill To Zero",        group = grpD)
paintBars = input.bool(true,  "Paint Chart Candles", group = grpD,
     tooltip = "Draws the regime onto the price chart as coloured candles, so one script gives you the oscillator and the bar colouring together.")
showMarks = input.bool(true,  "Flip Arrows On Chart", group = grpD)

colUp   = color.rgb(0, 255, 21)
colDn   = color.rgb(255, 0, 0)
colFlat = color.rgb(120, 123, 134)

// --- Ensemble size --------------------------------------------
nRaw = (maxLen - minLen) / lenStep + 1                     // integer division is intended here
n    = nRaw < 1 ? 1 : nRaw
int winCap = math.max(minLen, maxLen)                      // covers a max set below the min

// --- Shared series ---------------------------------------------
tr  = ta.tr(true)
vol = nz(volume)
hasVol = vol > 0

// --- Per member state ------------------------------------------
var array<float> sumArr  = array.new<float>(n, 0.0)        // rolling sum of source
var array<float> wnumArr = array.new<float>(n, 0.0)        // weighted numerator for WMA
var array<float> emaArr  = array.new<float>(n, 0.0)        // EMA value
var array<float> pvArr   = array.new<float>(n, 0.0)        // rolling sum of price times volume
var array<float> vArr    = array.new<float>(n, 0.0)        // rolling sum of volume
var array<float> atrArr  = array.new<float>(n, 0.0)        // Wilder average true range
var array<float> trSeed  = array.new<float>(n, 0.0)        // seed accumulator, used until each member fills
var array<int>   stArr   = array.new<int>(n, 0)            // latched long or short state per member

// --- The loop -------------------------------------------------
float votes  = 0.0
float pgoSum = 0.0
int   upCnt  = 0
int   dnCnt  = 0

// None of ta.sma, ta.ema, ta.wma, ta.vwma or ta.atr accepts a loop
// counter, so every member is rebuilt from running state held one slot
// per member. Each updates in constant time, which makes this a cheap
// ensemble: a long member costs exactly what a short one does.
for k = 0 to n - 1
    L    = minLen + k * lenStep
    full = bar_index >= L

    // Rolling sum. The pre-update value is also what the WMA numerator
    // needs, so it is read before the sum steps forward.
    sPrev = array.get(sumArr, k)
    sNew  = sPrev + src - (full ? src[L] : 0.0)

    // WMA numerator steps by L*src minus the previous window sum. That
    // identity is exact, so no weights are ever re-summed.
    wNew = array.get(wnumArr, k) + L * src - sPrev
    array.set(wnumArr, k, wNew)
    array.set(sumArr, k, sNew)

    // EMA, seeded from its own running mean so it starts on the same
    // footing as the other members rather than on a single bar. This
    // is not ta.ema's seeding convention, so members are not bit
    // identical to it during warm-up. They converge well before the
    // ready gate.
    ae = 2.0 / (L + 1)
    float emaK = 0.0
    if bar_index < L - 1
        emaK := sNew / (bar_index + 1)
    else if bar_index == L - 1
        emaK := sNew / L
    else
        emaK := ae * src + (1.0 - ae) * array.get(emaArr, k)
    array.set(emaArr, k, emaK)

    // VWMA sums.
    pvNew = array.get(pvArr, k) + src * vol - (full ? src[L] * nz(volume[L]) : 0.0)
    vNew  = array.get(vArr, k) + vol - (full ? nz(volume[L]) : 0.0)
    array.set(pvArr, k, pvNew)
    array.set(vArr, k, vNew)

    // Wilder ATR at this member's length, seeded from the mean of its
    // own first L true ranges exactly as ta.atr does. ta.tr prints a
    // real value on bar 0, unlike ta.change, so the seed window is
    // bars 0 to L-1. The RSI ensemble's bar_index <= L bound would
    // average L+1 ranges over L here and leave every ATR low, which
    // would inflate every reading in the script.
    if bar_index < L
        array.set(trSeed, k, array.get(trSeed, k) + tr)
        if bar_index == L - 1
            array.set(atrArr, k, array.get(trSeed, k) / L)
    else
        aw = 1.0 / L
        array.set(atrArr, k, aw * tr + (1.0 - aw) * array.get(atrArr, k))

    smaK = sNew / L
    maK = switch maType
        "EMA"  => emaK
        "WMA"  => wNew / (L * (L + 1.0) / 2.0)
        "VWMA" => hasVol and vNew > 0 ? pvNew / vNew : smaK
        => smaK

    atrK = array.get(atrArr, k)
    pgoK = atrK > 0 ? (src - maK) / atrK : 0.0
    pgoSum += pgoK

    // Latch. A member holds its state until the opposite threshold is
    // taken, and contributes nothing until it has crossed one of them.
    st = array.get(stArr, k)
    if pgoK > upThr
        st := 1
    else if pgoK < dnThr
        st := -1
    array.set(stArr, k, st)

    votes += st
    upCnt += st == 1 ? 1 : 0
    dnCnt += st == -1 ? 1 : 0

score   = votes / n
consPGO = pgoSum / n

// Every member is exact once it has filled its own window, and the
// Wilder recursion needs a stretch beyond that to settle.
ready = bar_index >= winCap * 2

// --- Regime ---------------------------------------------------
var int dir = 0
dir := ready ? (score >= scoreThr ? 1 : score <= -scoreThr ? -1 : (flatSplit ? 0 : dir)) : dir
isUp   = dir == 1
regCol = dir == 0 ? colFlat : isUp ? colUp : colDn

// --- Rendering ------------------------------------------------
ps = plot(ready ? score : na, "Score", color = regCol, linewidth = 2)
pz = plot(ready ? 0.0 : na, "Zero", color = color.new(colFlat, 100), display = display.none)
fill(ps, pz, color = showFill ? color.new(regCol, 88) : na, title = "Score Fill")

hline(0, "Zero", color = color.new(colFlat, 40))
hline(scoreThr,  "Long Threshold",  color = color.new(colUp, 60), linestyle = hline.style_dashed)
hline(-scoreThr, "Short Threshold", color = color.new(colDn, 60), linestyle = hline.style_dashed)

flipUp = ready and dir == 1  and dir[1] != 1
flipDn = ready and dir == -1 and dir[1] != -1
plotshape(flipUp ? score : na, "Long",  shape.triangleup,   location.absolute, colUp, size = size.tiny)
plotshape(flipDn ? score : na, "Short", shape.triangledown, location.absolute, colDn, size = size.tiny)

// Chart side rendering. One script gives the pane and the bar colours.
barCol = ready and dir != 0 ? regCol : colFlat
plotcandle(paintBars ? open : na, high, low, close, "Regime Candles",
     color = barCol, wickcolor = barCol, bordercolor = barCol, force_overlay = true)
plotshape(showMarks and flipUp, "Long Arrow",  shape.triangleup,   location.belowbar,
     color = colUp, size = size.tiny, force_overlay = true)
plotshape(showMarks and flipDn, "Short Arrow", shape.triangledown, location.abovebar,
     color = colDn, size = size.tiny, force_overlay = true)

plot(consPGO, "Consensus PGO value", color = color.blue, display = display.data_window)
plot(upCnt,   "Members Long",        color = color.blue, display = display.data_window)
plot(dnCnt,   "Members Short",       color = color.blue, display = display.data_window)

// --- Alerts ---------------------------------------------------
alertcondition(flipUp, "PGO Ensemble Up",   "The PGO ensemble agrees on an uptrend")
alertcondition(flipDn, "PGO Ensemble Down", "The PGO ensemble agrees on a downtrend")
````
