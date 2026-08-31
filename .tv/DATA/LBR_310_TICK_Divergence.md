<!-- tradingview-pine-id: PUB;9c86387a301f420bbdeb43ed9642d040 -->
<!-- tradingviewscripts-format: 1 -->
# LBR 3/10 + TICK Divergence

Source: https://www.tradingview.com/script/s3jUDndY-LBR-3-10-TICK-Divergence/

## Description

On-chart detector for Linda Raschke's "blindfold" setup: a signal prints only when price, the LBR 3/10 oscillator, and the NYSE TICK all diverge at the same two swing pivots. Built for intraday index trading.

█ OVERVIEW

Linda Bradford Raschke has described one intraday setup she rated highly enough to say she would take it blindfolded: price makes a new swing low, but both her 3/10 oscillator AND the NYSE TICK refuse to confirm it. Momentum is drying up on your symbol, and the selling pressure across the entire exchange is drying up with it.

This script detects that three-way alignment mechanically and marks it directly on the price chart with a label, a divergence trendline, and a tooltip showing the exact readings behind every signal. Nothing prints unless all three legs agree at the same two pivots.

█ WHY THIS IS DIFFERENT

TradingView has many divergence engines, including multi-oscillator "agreement" tools, and it has several TICK divergence scripts. What it does not have is a script that requires the specific LBR combination — price + 3/10 fast line + NYSE TICK — to diverge at the same two confirmed swing pivots before anything prints. Generic tools check each oscillator against price independently; this one treats the three-way agreement as a single gated signal, because that is the setup as Raschke teaches it. One condition missing = no signal.

It is also built for accountability: every label carries a tooltip with the precise price, oscillator, and TICK values at both pivots, so you can audit any signal after the fact instead of trusting an arrow.

█ HOW IT WORKS

A bullish signal requires all of the following at two confirmed swing lows (bearish is the mirror at swing highs):

1 — Price: lower low. The second swing low is below the first.

2 — 3/10 oscillator: higher low. The fast line (SMA 3 − SMA 10 of close) is higher at the
   second pivot than the first. Sellers made new price lows without new momentum lows.

3 — NYSE TICK: higher low. The TICK low at the second pivot is above the TICK low at the
   first. Program selling across the exchange could not match its earlier intensity — breadth
   is failing even as price ticks lower.

Additional gates:

 • Swing spacing window. The two pivots must be a minimum and maximum number of bars apart
   (configurable). Too close is noise; too far and the pattern is stale.
 • Zero-side filter (optional, on by default). Both oscillator readings must be below zero
   for bullish signals and above zero for bearish ones — the divergence forms in genuinely
   depressed (or elevated) momentum territory, not mid-range chop.
 • Confirmed pivots only. Swings are detected with asymmetric pivot strength: a larger
   left side to define a real swing, a small right side for fast confirmation. Once a signal
   prints, it does not repaint.

TICK data is requested on the chart's timeframe with no lookahead. The TICK requirement can be toggled off, which turns the script into a clean price + 3/10 double-divergence detector for symbols where TICK doesn't apply.

█ HOW TO USE IT

Where: designed for short intraday timeframes on the US index complex — ES, MES, SPX, SPY, QQQ — during regular NYSE hours. TICK is flat overnight and meaningless outside US equities; disable the TICK leg anywhere else.

The Raschke approach. This is a countertrend scalp against an exhausting move, not a trend entry. The label marks the condition; the entry comes from price. A typical plan for the bullish version:

 • Enter on a break above the high of the signal pivot's confirmation area, or the first strong
   close back in the direction of the signal.
 • Initial stop goes beyond the divergence extreme — if price takes out the second swing low
   decisively, the setup failed.
 • First target is the middle of the prior swing or the nearest reference average. Divergence
   trades fade an extended move; take profits actively rather than hoping for a reversal into
   a full trend.

The Grimes perspective. Adam Grimes, who uses the same 3/10, emphasizes that momentum divergence is only worth fading when the move it is fading is overextended. This script deliberately keeps the engine minimal, so bring that judgment yourself: the best signals appear after a sustained directional push into an extreme — late in a morning sell-off, at a measured-move completion, after several consecutive momentum lows — not in the middle of a quiet range. A divergence that forms mid-range chop is a statistic; one that forms at an extension is a trade.

Even if you never fade anything, the signals have a second use, straight from Grimes: a bearish triple divergence printing while you hold longs is an objective warning that the leg you are riding has lost its sponsorship.

█ FEATURES / INPUTS

 • 3/10 Oscillator: fast and slow SMA lengths; zero-side filter toggle.
 • Swing Detection: pivot strength left/right (right side controls confirmation lag);
   min/max bars between the two swings.
 • TICK Confirmation: toggle the TICK requirement; TICK symbol input (swap for your
   data feed's TICK).
 • Display: divergence trendlines on price on/off; bullish and bearish colors.
 • Tooltips on every label showing price, oscillator, and TICK values at both pivots.
 • Two alert conditions — bullish and bearish triple divergence — with ticker and interval
   placeholders, firing only on confirmed, non-repainting signals.

█ LIMITATIONS

 • Signals confirm a few bars after the actual swing — the cost of using confirmed pivots
   instead of repainting ones. The label is placed back at the true pivot bar.
 • The TICK leg only works on US equities and index products during regular trading hours,
   on intraday timeframes.
 • This is a countertrend tool. In a strong one-way trend, price can print divergence after
   divergence while grinding on. The zero-side filter and spacing window suppress some of this,
   but no divergence tool should be traded against a runaway market — Raschke's own warning.
 • The script identifies the condition; it is not an entry system. Trigger, stop, and target
   decisions are yours.

█ THANKS

Credit to Linda Bradford Raschke (LBRGroup, Street Smarts) for the 3/10 oscillator and the triple-divergence setup, and to Adam Grimes (The Art and Science of Technical Analysis) for the momentum-divergence framework referenced above. Educational tool, not financial advice.

---

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// LBR 3/10 + TICK Triple Divergence  —  Linda Raschke "blindfold" setup
//
// Fires when ALL THREE align (confirmed at swing pivots):
//   1. Price makes a lower low  (bull) or higher high (bear)
//   2. 3/10 oscillator fast line diverges (higher low / lower high)
//   3. NYSE TICK diverges (higher low / lower high)
//
// Designed for 2-min ES, MES, SPX, SPY. Add to chart, leave overlay on.
// ─────────────────────────────────────────────────────────────────────────────
indicator("LBR 3/10 + TICK Divergence", "LBR Div", overlay = true,
     max_labels_count = 500, max_lines_count = 500)

// ════ INPUTS ════
grpOsc          = "3/10 Oscillator"
fastLen         = input.int(3,  "Fast SMA length",  minval = 1, group = grpOsc)
slowLen         = input.int(10, "Slow SMA length",  minval = 2, group = grpOsc)
zeroSideFilter  = input.bool(true, "Require osc on correct side of zero (bull < 0, bear > 0)", group = grpOsc)

grpPiv          = "Swing Detection"
leftBars        = input.int(5, "Pivot strength — left bars",  minval = 1, group = grpPiv)
rightBars       = input.int(2, "Pivot strength — right bars (confirmation lag)", minval = 1, group = grpPiv)
minSpacing      = input.int(5,  "Min bars between the two swings", minval = 1,  group = grpPiv)
maxSpacing      = input.int(60, "Max bars between the two swings", minval = 5,  group = grpPiv)

grpTick         = "TICK Confirmation"
useTick         = input.bool(true, "Require TICK divergence", group = grpTick)
tickSym         = input.symbol("USI:TICK", "TICK symbol", group = grpTick)

grpVis          = "Display"
showLines       = input.bool(true, "Draw divergence trendlines on price", group = grpVis)
bullColor       = input.color(color.new(color.lime, 0), "Bullish color", group = grpVis)
bearColor       = input.color(color.new(color.red,  0), "Bearish color", group = grpVis)

// ════ CORE SERIES ════
// LBR 3/10: fast line = SMA(3) − SMA(10) of close
osc = ta.sma(close, fastLen) - ta.sma(close, slowLen)

// NYSE TICK lows/highs pulled on the chart's timeframe (no lookahead)
tickLow  = request.security(tickSym, timeframe.period, low,  barmerge.gaps_off, barmerge.lookahead_off)
tickHigh = request.security(tickSym, timeframe.period, high, barmerge.gaps_off, barmerge.lookahead_off)

// ════ SWING PIVOTS ════
pl = ta.pivotlow(low,  leftBars, rightBars)
ph = ta.pivothigh(high, leftBars, rightBars)

// ── State: previous swing low ──
var float prevPL       = na
var float prevOscAtPL  = na
var float prevTickAtPL = na
var int   prevPLBar    = na
// ── State: previous swing high ──
var float prevPH       = na
var float prevOscAtPH  = na
var float prevTickAtPH = na
var int   prevPHBar    = na

bullSignal = false
bearSignal = false

// ════ BULLISH: price LL + osc HL + TICK HL ════
if not na(pl)
    pivBar   = bar_index - rightBars
    oscAtPL  = osc[rightBars]
    tickAtPL = tickLow[rightBars]
    spacing  = na(prevPLBar) ? na : pivBar - prevPLBar
    if not na(prevPL) and not na(spacing) and spacing >= minSpacing and spacing <= maxSpacing
        priceLL = pl < prevPL
        oscHL   = oscAtPL > prevOscAtPL
        zeroOK  = not zeroSideFilter or (oscAtPL < 0 and prevOscAtPL < 0)
        tickOK  = not useTick or (not na(tickAtPL) and not na(prevTickAtPL) and tickAtPL > prevTickAtPL)
        if priceLL and oscHL and zeroOK and tickOK
            bullSignal := true
            if showLines
                line.new(prevPLBar, prevPL, pivBar, pl, color = bullColor, width = 2)
            label.new(pivBar, pl, "LBR ▲",
                 style = label.style_label_up, color = color.new(bullColor, 15),
                 textcolor = color.black, size = size.small,
                 tooltip = "Price LL: " + str.tostring(prevPL) + " → " + str.tostring(pl) +
                           "\n3/10 osc HL: " + str.tostring(prevOscAtPL, "#.##") + " → " + str.tostring(oscAtPL, "#.##") +
                           (useTick ? "\nTICK HL: " + str.tostring(prevTickAtPL, "#") + " → " + str.tostring(tickAtPL, "#") : ""))
    // store this swing as the new reference
    prevPL       := pl
    prevOscAtPL  := oscAtPL
    prevTickAtPL := tickAtPL
    prevPLBar    := pivBar

// ════ BEARISH: price HH + osc LH + TICK LH ════
if not na(ph)
    pivBar   = bar_index - rightBars
    oscAtPH  = osc[rightBars]
    tickAtPH = tickHigh[rightBars]
    spacing  = na(prevPHBar) ? na : pivBar - prevPHBar
    if not na(prevPH) and not na(spacing) and spacing >= minSpacing and spacing <= maxSpacing
        priceHH = ph > prevPH
        oscLH   = oscAtPH < prevOscAtPH
        zeroOK  = not zeroSideFilter or (oscAtPH > 0 and prevOscAtPH > 0)
        tickOK  = not useTick or (not na(tickAtPH) and not na(prevTickAtPH) and tickAtPH < prevTickAtPH)
        if priceHH and oscLH and zeroOK and tickOK
            bearSignal := true
            if showLines
                line.new(prevPHBar, prevPH, pivBar, ph, color = bearColor, width = 2)
            label.new(pivBar, ph, "LBR ▼",
                 style = label.style_label_down, color = color.new(bearColor, 15),
                 textcolor = color.white, size = size.small,
                 tooltip = "Price HH: " + str.tostring(prevPH) + " → " + str.tostring(ph) +
                           "\n3/10 osc LH: " + str.tostring(prevOscAtPH, "#.##") + " → " + str.tostring(oscAtPH, "#.##") +
                           (useTick ? "\nTICK LH: " + str.tostring(prevTickAtPH, "#") + " → " + str.tostring(tickAtPH, "#") : ""))
    prevPH       := ph
    prevOscAtPH  := oscAtPH
    prevTickAtPH := tickAtPH
    prevPHBar    := pivBar

// ════ ALERTS ════
alertcondition(bullSignal, "LBR Bullish Triple Divergence",
     "LBR setup ▲ {{ticker}} {{interval}}: price LL + 3/10 HL + TICK HL")
alertcondition(bearSignal, "LBR Bearish Triple Divergence",
     "LBR setup ▼ {{ticker}} {{interval}}: price HH + 3/10 LH + TICK LH")
````
