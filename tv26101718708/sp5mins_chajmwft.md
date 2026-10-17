# SP-5Mins

- url: https://www.tradingview.com/script/CHajMwFT-SP-5Mins/
- type: indicator
- pine_id: PUB;57887bab581e4abbae0839ee338d69fe
- version: 1.0

## Description

Looks at the first 5 mins and predicts buy/sell signal.

## Source Code

````pine
// @version=6
// ─────────────────────────────────────────────────────────────────────────────
// 9:30 AM First Candle Strategy — by Scarface Trades (Pine Script v6)
// ─────────────────────────────────────────────────────────────────────────────
// HOW IT WORKS:
//   1. Marks the 9:30–9:34 AM ET opening range high & low (first 5-min candle)
//   2. Waits for a confirmed breakout close ABOVE the OR High (bullish) or
//      BELOW the OR Low (bearish)
//   3. Monitors for a retest of the broken level
//   4. Rates the confirmation candle AT the retest:
//        STRONG  — Full body candle, negligible opposing wick
//        NORMAL  — Hammer/shooting star: wick tests the level, buyers/sellers win
//        WEAK    — Closes in right direction but opposing wick shows struggle
//   5. If candle is ambiguous (down-close but above level), waits ONE more candle
//      to close above prior candle high (INTC example from the video)
// ─────────────────────────────────────────────────────────────────────────────
indicator("Five Minute Candle Strategy", overlay=true, max_labels_count=500, max_lines_count=20)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpOR    = "Opening Range"
grpSig   = "Signal Filters"
grpViz   = "Visuals"

showORLines     = input.bool(true,  "Show Opening Range Lines",           group=grpViz)
showLabels      = input.bool(true,  "Show Signal Labels on Chart",        group=grpViz)
showBgColor     = input.bool(true,  "Highlight Signal Bar Background",    group=grpViz)
retestBuffer    = input.float(0.15, "Retest Buffer (%)",                  group=grpOR,  minval=0.0, maxval=1.0, step=0.05,
     tooltip="How close price must come to the OR level to count as a retest (% of price). 0.15 = within 0.15%")

// Candle scoring thresholds
strongWickMax   = input.float(0.20, "Max Wick Ratio for STRONG signal",   group=grpSig, minval=0.0, maxval=0.5, step=0.05,
     tooltip="Upper wick (for bulls) or lower wick (for bears) as % of candle body. Below this = STRONG. e.g. 0.20 = wick ≤ 20% of body")
weakWickMin     = input.float(0.75, "Min Wick Ratio for WEAK signal",     group=grpSig, minval=0.3, maxval=2.0, step=0.05,
     tooltip="Upper wick (for bulls) or lower wick (for bears) as % of body. Above this = WEAK. Between strong/weak = NORMAL.")
filterWeakSigs  = input.bool(false, "Hide WEAK signals (skip low quality)", group=grpSig,
     tooltip="If enabled, Weak Buy / Weak Sell labels and alerts are suppressed. Good/strong only.")

// ══════════════════════════════════════════════════════════════════════════════
// TIME HELPERS
// ══════════════════════════════════════════════════════════════════════════════
tz = "America/New_York"

// Returns true on every 1-min bar within 9:30–9:34 ET (the 5 opening bars)
inOpeningRange  = not na(time("1", "0930-0935", tz))

// Market is open (9:30–16:00 ET)
marketOpen      = not na(time("1", "0930-1600", tz))

// First bar of the new day AT exactly 9:30
isSessionOpen   = (hour(time, tz) == 9  and minute(time, tz) == 30)

// ══════════════════════════════════════════════════════════════════════════════
// OPENING RANGE STATE
// ══════════════════════════════════════════════════════════════════════════════
var float orHigh         = na
var float orLow          = na
var bool  orLocked       = false   // true after 9:34 bar closes

var bool  brokeUp        = false   // close above orHigh has occurred today
var bool  brokeDown      = false   // close below orLow has occurred today

var bool  inRetestUpZone = false   // price has pulled back to orHigh from above
var bool  inRetestDnZone = false   // price has pulled back to orLow from below

var bool  signalFiredUp  = false   // prevents multiple signals per retest
var bool  signalFiredDn  = false

// Pending second-candle confirmation (INTC scenario)
var bool  pendingBull    = false   // waiting for next candle to close > prevHigh
var float pendingBullRef = na      // high of the ambiguous candle to beat
var bool  pendingBear    = false
var float pendingBearRef = na

// Reset all state on new session open
if isSessionOpen
    orHigh         := na
    orLow          := na
    orLocked       := false
    brokeUp        := false
    brokeDown      := false
    inRetestUpZone := false
    inRetestDnZone := false
    signalFiredUp  := false
    signalFiredDn  := false
    pendingBull    := false
    pendingBullRef := na
    pendingBear    := false
    pendingBearRef := na

// Build OR high/low from the five 9:30–9:34 1-min bars
if inOpeningRange
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow,  low)

// Lock the range once 9:34 bar has closed (9:35 first bar)
if not orLocked and not na(orHigh) and not inOpeningRange and marketOpen
    orLocked := true

// Draw OR lines once locked
var line lineH = na
var line lineL = na
if orLocked and showORLines and na(lineH)
    lineH := line.new(bar_index, orHigh, bar_index + 500, orHigh,
         color=color.new(color.blue, 10), width=2, style=line.style_dashed)
    lineL := line.new(bar_index, orLow,  bar_index + 500, orLow,
         color=color.new(color.red,  10), width=2, style=line.style_dashed)

// ══════════════════════════════════════════════════════════════════════════════
// CANDLE CLASSIFICATION
// ══════════════════════════════════════════════════════════════════════════════
//
// The video defines these candle types:
//
// BULLISH (ranked best to worst):
//   1. STRONG  — Full body green, opens at low, closes at high.
//                Upper wick is negligible (≤ strongWickMax × body)
//   2. NORMAL  — "Hammer": Big lower wick (sellers tried, failed), closes near high.
//                Defined by: lower wick is large, upper wick is small-moderate
//   3. WEAK    — Green but upper wick is large (sellers partially won back ground)
//
// BEARISH (mirror image):
//   1. STRONG  — Full body red, opens at high, closes at low.
//                Lower wick is negligible
//   2. NORMAL  — "Shooting Star": Big upper wick (buyers tried, failed), closes near low.
//   3. WEAK    — Red but lower wick is large (buyers partially recovered)
//
// Returns: 3 = Strong, 2 = Normal, 1 = Weak, 0 = Invalid (wrong direction candle)

// Bullish score — called on a green (close > open) candle
bullCandleScore() =>
    bodySize  = close - open                          // size of the body
    upperWick = high  - close                         // wick AGAINST bulls
    lowerWick = open  - low                           // wick WITH bulls (sellers tried, failed)
    score = 0
    if close > open and bodySize > 0
        upperRatio = upperWick / bodySize             // key ratio: resistance against move
        if upperRatio <= strongWickMax
            score := 3   // STRONG: full body, tiny upper wick
        else if upperRatio < weakWickMin
            score := 2   // NORMAL: moderate upper wick (hammer acceptable here too)
        else
            score := 1   // WEAK: large upper wick, sellers pushed hard
    score

// Bearish score — called on a red (close < open) candle
bearCandleScore() =>
    bodySize  = open  - close                         // size of body
    lowerWick = close - low                           // wick AGAINST bears
    upperWick = high  - open                          // wick WITH bears (buyers tried, failed)
    score = 0
    if close < open and bodySize > 0
        lowerRatio = lowerWick / bodySize             // key ratio: resistance against move
        if lowerRatio <= strongWickMax
            score := 3   // STRONG: full body, tiny lower wick
        else if lowerRatio < weakWickMin
            score := 2   // NORMAL: moderate lower wick (shooting star)
        else
            score := 1   // WEAK: large lower wick, buyers pushed hard
    score

// ══════════════════════════════════════════════════════════════════════════════
// BREAKOUT DETECTION
// ══════════════════════════════════════════════════════════════════════════════
if orLocked and marketOpen and barstate.isconfirmed
    // Breakout up: candle closes above OR high
    if not brokeUp and close > orHigh
        brokeUp        := true
        signalFiredUp  := false
        inRetestUpZone := false

    // Breakout down: candle closes below OR low
    if not brokeDown and close < orLow
        brokeDown      := true
        signalFiredDn  := false
        inRetestDnZone := false

// ══════════════════════════════════════════════════════════════════════════════
// RETEST DETECTION
// ══════════════════════════════════════════════════════════════════════════════
bufUp = orHigh * (retestBuffer / 100)
bufDn = orLow  * (retestBuffer / 100)

if orLocked and marketOpen
    // For longs: price dips back down to within buffer of orHigh
    if brokeUp and not signalFiredUp
        if low <= orHigh + bufUp and high >= orHigh - bufUp
            inRetestUpZone := true

    // For shorts: price rallies back up to within buffer of orLow
    if brokeDown and not signalFiredDn
        if high >= orLow - bufDn and low <= orLow + bufDn
            inRetestDnZone := true

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL GENERATION (on confirmed bar close)
// ══════════════════════════════════════════════════════════════════════════════
strongBuySignal  = false
buySignal        = false
weakBuySignal    = false
strongSellSignal = false
sellSignal       = false
weakSellSignal   = false
nextCandleBull   = false   // second-candle confirmation fired
nextCandleBear   = false

if orLocked and marketOpen and barstate.isconfirmed

    // ── BULL SIGNAL ──────────────────────────────────────────────────────────
    if brokeUp and inRetestUpZone and not signalFiredUp
        bScore = bullCandleScore()

        if bScore == 3
            strongBuySignal  := true
            signalFiredUp    := true
            inRetestUpZone   := false

        else if bScore == 2
            buySignal        := true
            signalFiredUp    := true
            inRetestUpZone   := false

        else if bScore == 1
            if not filterWeakSigs
                weakBuySignal    := true
            signalFiredUp    := true
            inRetestUpZone   := false

        // Ambiguous: down-close candle BUT still holding above OR high
        // → set pending, wait for next candle to close above this candle's high
        else if close < open and close >= orHigh
            pendingBull    := true
            pendingBullRef := high   // next candle must close above this

    // ── PENDING BULL: next candle closes above prior high → confirm entry ────
    if pendingBull and not signalFiredUp
        if close > open and close > pendingBullRef
            buySignal      := true
            signalFiredUp  := true
            pendingBull    := false
            pendingBullRef := na
            nextCandleBull := true
        else if close < pendingBullRef  // failed, invalidate
            pendingBull    := false
            pendingBullRef := na

    // ── BEAR SIGNAL ──────────────────────────────────────────────────────────
    if brokeDown and inRetestDnZone and not signalFiredDn
        sScore = bearCandleScore()

        if sScore == 3
            strongSellSignal := true
            signalFiredDn    := true
            inRetestDnZone   := false

        else if sScore == 2
            sellSignal       := true
            signalFiredDn    := true
            inRetestDnZone   := false

        else if sScore == 1
            if not filterWeakSigs
                weakSellSignal   := true
            signalFiredDn    := true
            inRetestDnZone   := false

        // Ambiguous: up-close candle BUT still below OR low
        else if close > open and close <= orLow
            pendingBear    := true
            pendingBearRef := low

    // ── PENDING BEAR: next candle closes below prior low → confirm entry ─────
    if pendingBear and not signalFiredDn
        if close < open and close < pendingBearRef
            sellSignal     := true
            signalFiredDn  := true
            pendingBear    := false
            pendingBearRef := na
            nextCandleBear := true
        else if close > pendingBearRef
            pendingBear    := false
            pendingBearRef := na

// ══════════════════════════════════════════════════════════════════════════════
// VISUALS
// ══════════════════════════════════════════════════════════════════════════════
colSB  = color.new(#00c853, 0)    // Strong Buy  — deep green
colB   = color.new(#43a047, 0)    // Buy         — medium green
colWB  = color.new(#a5d6a7, 0)    // Weak Buy    — light green
colSS  = color.new(#b71c1c, 0)    // Strong Sell — deep red
colS   = color.new(#e53935, 0)    // Sell        — medium red
colWS  = color.new(#ef9a9a, 0)    // Weak Sell   — light red

// Labels
if showLabels
    if strongBuySignal
        label.new(bar_index, low,  nextCandleBull ? "▲ STRONG BUY\n(2-bar confirm)" : "▲ STRONG BUY",
             style=label.style_label_up,   color=colSB,  textcolor=color.white, size=size.normal)
    if buySignal
        label.new(bar_index, low,  nextCandleBull ? "▲ BUY\n(2-bar confirm)" : "▲ BUY",
             style=label.style_label_up,   color=colB,   textcolor=color.white, size=size.normal)
    if weakBuySignal
        label.new(bar_index, low,  "▲ WEAK BUY\n(reduce size)",
             style=label.style_label_up,   color=colWB,  textcolor=color.black, size=size.small)
    if strongSellSignal
        label.new(bar_index, high, nextCandleBear ? "▼ STRONG SELL\n(2-bar confirm)" : "▼ STRONG SELL",
             style=label.style_label_down, color=colSS,  textcolor=color.white, size=size.normal)
    if sellSignal
        label.new(bar_index, high, nextCandleBear ? "▼ SELL\n(2-bar confirm)" : "▼ SELL",
             style=label.style_label_down, color=colS,   textcolor=color.white, size=size.normal)
    if weakSellSignal
        label.new(bar_index, high, "▼ WEAK SELL\n(reduce size)",
             style=label.style_label_down, color=colWS,  textcolor=color.black, size=size.small)

// Pending confirmation markers (triangle outline = waiting for next candle)
plotshape(pendingBull  and not signalFiredUp ? low  : na, "Pending Bull", shape.triangleup,   location.belowbar, color.new(colB, 40),  size=size.small)
plotshape(pendingBear  and not signalFiredDn ? high : na, "Pending Bear", shape.triangledown, location.abovebar, color.new(colS, 40),  size=size.small)

// Bar background highlight
bgcolor(strongBuySignal  ? color.new(colSB, 80) : na, title="Strong Buy BG")
bgcolor(buySignal        ? color.new(colB,  80) : na, title="Buy BG")
bgcolor(weakBuySignal    ? color.new(colWB, 80) : na, title="Weak Buy BG")
bgcolor(strongSellSignal ? color.new(colSS, 80) : na, title="Strong Sell BG")
bgcolor(sellSignal       ? color.new(colS,  80) : na, title="Sell BG")
bgcolor(weakSellSignal   ? color.new(colWS, 80) : na, title="Weak Sell BG")

// OR zone shading (light fill between OR high and low)
orHighPlot = plot(orLocked ? orHigh : na, "OR High", color.new(color.blue, 100))
orLowPlot  = plot(orLocked ? orLow  : na, "OR Low",  color.new(color.red,  100))
fill(orHighPlot, orLowPlot, color=color.new(color.gray, 92), title="OR Zone Fill")

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(strongBuySignal,
     title="⬆ Strong Buy — 9:30 Strategy",
     message="STRONG BUY fired.\n\nFull-body bullish candle confirmed the OR High retest.\nEntry: Next bar open (above confirmation candle)\nStop: Below retest candle low\nTarget: High of Day (aim for 2R minimum)")

alertcondition(buySignal,
     title="⬆ Buy — 9:30 Strategy",
     message="BUY fired.\n\nBullish hammer/confirmation candle at OR High retest.\nEntry: Next bar open\nStop: Below retest candle low\nTarget: High of Day (aim for 2R minimum)\nNote: If '2-bar confirm' — stop goes below the first ambiguous candle.")

alertcondition(weakBuySignal,
     title="⬆ Weak Buy — 9:30 Strategy (Caution)",
     message="WEAK BUY fired.\n\nGreen candle at OR High retest BUT large upper wick — sellers fought back.\nConsider reducing position size or skipping entirely.\nEntry: Next bar open | Stop: Below retest candle low")

alertcondition(strongSellSignal,
     title="⬇ Strong Sell — 9:30 Strategy",
     message="STRONG SELL fired.\n\nFull-body bearish candle confirmed the OR Low retest.\nEntry: Next bar open (below confirmation candle)\nStop: Above retest candle high\nTarget: Low of Day (aim for 2R minimum)")

alertcondition(sellSignal,
     title="⬇ Sell — 9:30 Strategy",
     message="SELL fired.\n\nBearish shooting star/confirmation candle at OR Low retest.\nEntry: Next bar open\nStop: Above retest candle high\nTarget: Low of Day (aim for 2R minimum)")

alertcondition(weakSellSignal,
     title="⬇ Weak Sell — 9:30 Strategy (Caution)",
     message="WEAK SELL fired.\n\nRed candle at OR Low retest BUT large lower wick — buyers fought back.\nConsider reducing position size or skipping entirely.\nEntry: Next bar open | Stop: Above retest candle high")

// Composite
alertcondition(strongBuySignal or buySignal,
     title="⬆ Any Quality Buy — 9:30 Strategy",
     message="A Strong or Normal BUY signal fired on the 9:30 AM strategy.")

alertcondition(strongSellSignal or sellSignal,
     title="⬇ Any Quality Sell — 9:30 Strategy",
     message="A Strong or Normal SELL signal fired on the 9:30 AM strategy.")

alertcondition(strongBuySignal or buySignal or weakBuySignal or strongSellSignal or sellSignal or weakSellSignal,
     title="Any Signal — 9:30 Strategy",
     message="A signal fired on the 9:30 AM First Candle Strategy.")
````
