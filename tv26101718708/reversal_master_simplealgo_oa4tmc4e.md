# Reversal Master [SimpleAlgo]

- url: https://www.tradingview.com/script/Oa4tmc4E-Reversal-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;6302021bf8bf4839890fedf9c98776df
- version: 1.0

## Description

⭐ [b]OVERVIEW[/b]

Reversal Master shows you when a move has stretched too far, and when the pressure behind it starts to let go. It does this with three simple layers that work together on one chart:

[list]
[*][b]Reversal bands:[/b] three tiers above and below price that show how far price has stretched from normal.
[*][b]Reversal signals:[/b] a ▲ or ▼ when momentum leaves an extreme, marked Strong when price reached the outer bands during the move.
[*][b]Trend candles:[/b] candles colored by the angle of the trend, so you can see at a glance whether the market is climbing, falling, or flat.
[/list]

Everything is written in plain language. No jargon on the chart, and every label has a tooltip explaining what it means.

⚙️ [b]HOW IT WORKS[/b]

[list=1]
[*][b]Bands.[/b] The center is an exponential average of the typical price (high, low and close). The distance to each band is measured in a volatility unit that blends the standard deviation of price with the average true range, lightly smoothed so the bands do not jump. The first band sits at the chosen distance, the second 0.75 units further, the third 1.5 units further. The further price travels into the tiers, the more stretched it is.
[*][b]Momentum.[/b] The signal engine uses the Relative Volatility Index: volatility (standard deviation over the momentum length) is split into up-close and down-close bars and each side is smoothed. The result runs from 0 to 100. Above the high level (default 80), upside pressure is stretched. Below the low level (default 20), downside pressure is stretched.
[*][b]Ready.[/b] When momentum enters an extreme, a small Ready tag appears. From that bar on, the script tracks how far price reaches into the bands.
[*][b]Signal.[/b] When momentum leaves the extreme again, a ▼ (from the high side) or ▲ (from the low side) prints. If price reached at least the second band tier while momentum was extreme, the signal is marked Strong. Signals and Ready tags print only on closed bars and never move afterwards.
[*][b]Trend candles.[/b] The slope of a linear regression line over the trend angle length is measured in ATR units and converted to an angle in degrees. Steeper up shades candles toward the up color, steeper down toward the down color, and flat markets fade to grey. Down-candles inside a trend use a darker shade of the same color, so the trend reads at a glance without hiding candle direction.
[/list]

🎯 [b]HOW TO USE IT[/b]

[list]
[*][b]Read the stretch first.[/b] Price in the outer tiers means the move is extended. That is context, not a signal on its own.
[*][b]Ready means watch.[/b] Momentum is at an extreme. Nothing has turned yet.
[*][b]The signal is the turn.[/b] Momentum has let go of its extreme. Strong signals came after a bigger stretch and are the ones most traders will focus on.
[*][b]Use the candles for the bigger picture.[/b] Counter-trend signals against a steep candle color deserve more caution than signals when the candles have already faded to grey.
[*][b]Tune it to your market.[/b] Shorter momentum settings react faster and print more often. A larger band distance makes Strong rarer.
[/list]

This marks stretched conditions and changes in pressure. It does not predict where price will go next, and it is not a buy or sell recommendation. Use it with your own analysis and risk management.

🔔 [b]ALERTS[/b]

[list]
[*]Buy-side reversal and Sell-side reversal (on bar close; Strong noted in the message).
[*]Ready: buy side and Ready: sell side.
[/list]

🛠️ [b]SETTINGS[/b]

[list]
[*][b]Signals:[/b] reversal signals, Ready tags, momentum length and smoothing, extreme levels, spacing between signals and between Ready tags.
[*][b]Reversal bands:[/b] show or hide, length, distance.
[*][b]Trend candles:[/b] show or hide, angle length.
[*][b]Look:[/b] up, down and flat colors.
[/list]

📝 [b]NOTES[/b]

[list]
[*]Works on any market and timeframe. Defaults were chosen for intraday and swing charts; very short timeframes may want a longer momentum smoothing.
[*]Bands and candle colors update on the current bar as it forms, like any moving average. Signals and Ready tags are decided on bar close only and do not repaint.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Reversal Master [SimpleAlgo]", "Reversal Master", overlay = true, max_labels_count = 500)

// ═══════════════════════════════ Inputs ═══════════════════════════════
grpS = "Signals"
showSig   = input.bool(true, "Reversal signals", group = grpS, tooltip = "Momentum leaves an extreme after a stretch. Marked Strong when price reached the outer bands during that stretch.")
showReady = input.bool(true, "Ready alerts", group = grpS, tooltip = "Momentum has entered an extreme. A reversal signal may follow when it leaves.")
volLen    = input.int(10, "Momentum length", minval = 2, maxval = 100, group = grpS)
volSmooth = input.int(14, "Momentum smoothing", minval = 1, maxval = 100, group = grpS)
hiLvl     = input.int(80, "Extreme high", minval = 51, maxval = 99, group = grpS)
loLvl     = input.int(20, "Extreme low", minval = 1, maxval = 49, group = grpS)
minGap    = input.int(5, "Min bars between same-direction signals", minval = 0, maxval = 200, group = grpS)
readyGap  = input.int(8, "Min bars between Ready tags", minval = 0, maxval = 200, group = grpS)

grpB = "Reversal bands"
showBands = input.bool(true, "Show bands", group = grpB)
bandLen   = input.int(34, "Band length", minval = 5, maxval = 300, group = grpB)
bandMult  = input.float(2.0, "Band distance", minval = 0.5, maxval = 10.0, step = 0.1, group = grpB, tooltip = "Distance of the first band from the center, in volatility units. The second and third bands sit further out.")

grpC = "Trend candles"
showCandles = input.bool(true, "Color candles by trend angle", group = grpC)
angLen      = input.int(34, "Trend angle length", minval = 5, maxval = 300, group = grpC)

grpD = "Look"
colUp  = input.color(#3DDC97, "Up",   inline = "c", group = grpD)
colDn  = input.color(#F2607A, "Down", inline = "c", group = grpD)
colMid = input.color(#6B7280, "Flat", inline = "c", group = grpD)

// ═══════════════════════════════ Momentum: Relative Volatility Index ═══════════════════════════════
// Standard RVI: volatility (standard deviation) split into up-close and down-close days, then smoothed.
// Above the high level = upside pressure stretched. Below the low level = downside pressure stretched.
float sd  = ta.stdev(close, volLen)
float chg = ta.change(close)
float upV = ta.ema(chg > 0 ? sd : 0.0, volSmooth)
float dnV = ta.ema(chg <= 0 ? sd : 0.0, volSmooth)
float rvi = upV + dnV > 0 ? 100 * upV / (upV + dnV) : 50.0

// ═══════════════════════════════ Reversal bands ═══════════════════════════════
// Center: EMA of typical price. Volatility unit: blend of standard deviation and ATR, lightly smoothed.
// Three tiers on each side mark how far price has stretched from normal.
float basis = ta.ema(hlc3, bandLen)
float unit  = ta.ema(math.avg(ta.stdev(close, bandLen), ta.atr(bandLen)), 5)
float u1 = basis + unit * bandMult
float u2 = basis + unit * (bandMult + 0.75)
float u3 = basis + unit * (bandMult + 1.5)
float l1 = basis - unit * bandMult
float l2 = basis - unit * (bandMult + 0.75)
float l3 = basis - unit * (bandMult + 1.5)

pU1 = plot(showBands ? u1 : na, "Upper 1", color = color.new(colDn, 80))
pU2 = plot(showBands ? u2 : na, "Upper 2", color = color.new(colDn, 65))
pU3 = plot(showBands ? u3 : na, "Upper 3", color = color.new(colDn, 40))
pL1 = plot(showBands ? l1 : na, "Lower 1", color = color.new(colUp, 80))
pL2 = plot(showBands ? l2 : na, "Lower 2", color = color.new(colUp, 65))
pL3 = plot(showBands ? l3 : na, "Lower 3", color = color.new(colUp, 40))
fill(pU1, pU2, color = color.new(colDn, 93), title = "Upper zone 1")
fill(pU2, pU3, color = color.new(colDn, 86), title = "Upper zone 2")
fill(pL1, pL2, color = color.new(colUp, 93), title = "Lower zone 1")
fill(pL2, pL3, color = color.new(colUp, 86), title = "Lower zone 2")

// ═══════════════════════════════ Trend candles ═══════════════════════════════
// Trend angle: slope of a linear regression line, measured in ATR units across the window,
// converted to an angle in degrees. Steeper up = stronger mint, steeper down = stronger coral, flat = grey.
float slope = ta.linreg(close, angLen, 0) - ta.linreg(close, angLen, 1)
float atrA  = ta.atr(angLen)
float steep = ta.ema(atrA > 0 ? slope / atrA * angLen : 0.0, 5)
float deg   = math.atan(steep) * 180 / math.pi
color angCol = deg >= 0 ? color.from_gradient(deg, 0, 60, colMid, colUp) : color.from_gradient(deg, -60, 0, colDn, colMid)
color candleC = close >= open ? angCol : color.from_gradient(0.45, 0.0, 1.0, angCol, #0F1117)
barcolor(showCandles ? candleC : na, title = "Trend candles")

// ═══════════════════════════════ Setups and signals (confirmed bars only) ═══════════════════════════════
bool enterHi = ta.crossover(rvi, hiLvl)
bool leaveHi = ta.crossunder(rvi, hiLvl)
bool enterLo = ta.crossunder(rvi, loLvl)
bool leaveLo = ta.crossover(rvi, loLvl)
float atr30  = ta.atr(30)

var bool readyDn = false, var int tierDn = 0, var int lastDnBar = -100000
var bool readyUp = false, var int tierUp = 0, var int lastUpBar = -100000
var int lastReadyBar = -100000, var int lastSigBar = -100000
bool sigUpNow = false, bool sigDnNow = false, bool readyUpNow = false, bool readyDnNow = false

if barstate.isconfirmed and not na(atr30)
    // Track how far price stretched while momentum is extreme
    if readyDn
        tierDn := math.max(tierDn, high > u3 ? 3 : high > u2 ? 2 : high > u1 ? 1 : 0)
    if readyUp
        tierUp := math.max(tierUp, low < l3 ? 3 : low < l2 ? 2 : low < l1 ? 1 : 0)

    // Momentum enters an extreme: setup starts
    if enterHi
        readyDn := true, tierDn := high > u3 ? 3 : high > u2 ? 2 : high > u1 ? 1 : 0, readyDnNow := true
        if showReady and bar_index - lastReadyBar >= readyGap
            lastReadyBar := bar_index
            label.new(bar_index, high + atr30 * (bar_index - lastSigBar <= 3 ? 1.3 : 0.15), "Ready ▼", style = label.style_label_down, color = color.new(colDn, 100), textcolor = color.new(colDn, 20), size = size.small, tooltip = "Upside momentum is stretched. A sell-side reversal signal may follow.")
    if enterLo
        readyUp := true, tierUp := low < l3 ? 3 : low < l2 ? 2 : low < l1 ? 1 : 0, readyUpNow := true
        if showReady and bar_index - lastReadyBar >= readyGap
            lastReadyBar := bar_index
            label.new(bar_index, low - atr30 * (bar_index - lastSigBar <= 3 ? 1.3 : 0.15), "Ready ▲", style = label.style_label_up, color = color.new(colUp, 100), textcolor = color.new(colUp, 20), size = size.small, tooltip = "Downside momentum is stretched. A buy-side reversal signal may follow.")

    // Momentum leaves the extreme: reversal signal
    if leaveHi and readyDn
        if showSig and bar_index - lastDnBar >= minGap
            bool strong = tierDn >= 2
            label.new(bar_index, high + atr30 * 0.8, strong ? "▼ Strong" : "▼", style = label.style_label_down, color = colDn, textcolor = #0F1117, size = size.normal, tooltip = "Upside momentum has left its extreme." + (strong ? "\nPrice stretched into the outer bands during the move." : "\nPrice did not reach the outer bands."))
            lastDnBar := bar_index, lastSigBar := bar_index, sigDnNow := true
            alert("Reversal Master: sell-side reversal" + (strong ? " (strong)" : ""), alert.freq_once_per_bar_close)
        readyDn := false
    if leaveLo and readyUp
        if showSig and bar_index - lastUpBar >= minGap
            bool strong = tierUp >= 2
            label.new(bar_index, low - atr30 * 0.8, strong ? "▲ Strong" : "▲", style = label.style_label_up, color = colUp, textcolor = #0F1117, size = size.normal, tooltip = "Downside momentum has left its extreme." + (strong ? "\nPrice stretched into the outer bands during the move." : "\nPrice did not reach the outer bands."))
            lastUpBar := bar_index, lastSigBar := bar_index, sigUpNow := true
            alert("Reversal Master: buy-side reversal" + (strong ? " (strong)" : ""), alert.freq_once_per_bar_close)
        readyUp := false

// ═══════════════════════════════ Alerts ═══════════════════════════════
alertcondition(sigUpNow,   "Buy-side reversal",  "Reversal Master: buy-side reversal")
alertcondition(sigDnNow,   "Sell-side reversal", "Reversal Master: sell-side reversal")
alertcondition(readyUpNow, "Ready: buy side",    "Reversal Master: downside momentum stretched")
alertcondition(readyDnNow, "Ready: sell side",   "Reversal Master: upside momentum stretched")
````
