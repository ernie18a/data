# Liquidity Sweeps [Quantum Algo]

- url: https://www.tradingview.com/script/EYSbkVeb-Liquidity-Sweeps-Quantum-Algo/
- type: indicator
- pine_id: PUB;0cc68b12a3934db585102d9954343015
- version: 2.0

## Description

Liquidity Sweeps [Quantum Algo] is an open-source liquidity sweep indicator that maps resting
liquidity at swing highs and swing lows, then flags the exact moment that liquidity is swept and
rejected — the classic stop-hunt behaviour traders watch for in Smart Money Concepts (SMC).

[b]WHAT IS A LIQUIDITY SWEEP?
[/b]A liquidity sweep (also called a liquidity grab or stop hunt) happens when price briefly spikes
beyond an obvious swing high or swing low — where stop-loss and breakout orders rest — and then
closes back inside the prior range. The wick takes the liquidity; the close shows the breakout
failed. Liquidity sitting above swing highs is buy-side liquidity (BSL); liquidity sitting below
swing lows is sell-side liquidity (SSL).

A bearish liquidity sweep occurs when buy-side liquidity above a swing high is swept and price
closes back below it. A bullish liquidity sweep occurs when sell-side liquidity below a swing low
is swept and price closes back above it.

[b]HOW THE INDICATOR WORKS
[/b]- It detects confirmed swing highs and swing lows using a configurable pivot strength, and draws a
  liquidity level at each one. Buy-side levels sit above price; sell-side levels sit below.
- Each level extends to the right until it is interacted with.
- When a candle wicks through a level but closes back inside, the indicator marks a liquidity
  sweep with a label and an optional highlight on the sweeping wick.
- An optional volume filter confirms only sweeps where the sweeping candle trades above its
  average volume, filtering out low-conviction wicks.
- If price instead closes fully through a level, that is treated as a clean break (a plain
  liquidity grab / breakout), not a sweep, and the level is retired without a signal.

[b]WHAT IT SHOWS
[/b]- Mapped buy-side (BSL) and sell-side (SSL) liquidity levels.
- Bullish and bearish liquidity sweep markers, the moment a level is swept and rejected.
- Optional wick highlighting on the sweep candle.
- A dashboard showing bullish/bearish sweep counts, the last sweep direction, and the nearest
  un-swept buy-side and sell-side levels with their percentage distance from price.

[b]HOW TO USE IT
[/b]Liquidity sweeps are most useful as a timing and context tool, not a standalone buy/sell system.
A common workflow:
- Mark the obvious highs and lows where liquidity is likely resting.
- Wait for a sweep into one of those pools (a wick through, close back inside), ideally with the
  volume filter confirming participation.
- Look for confirmation in your own process — a market-structure shift, an order block, a
  fair-value-gap fill, or higher-timeframe trend alignment — before acting.
- A bearish sweep above resistance can precede a move down; a bullish sweep below support can
  precede a move up. Always define risk beyond the swept extreme.

[b]SETTINGS
[/b]- Pivot Strength: how many bars define a swing; higher values keep only major liquidity pools.
- Max Levels per Side: how many recent levels to keep mapped.
- Volume Confirmation: toggle, average length, and multiplier to qualify a sweep.
- Treat Clean Breaks as Grabs: retire levels that are broken through rather than swept.
- Line width, style, and transparency for clear level visibility.
- Full colour controls and a movable dashboard.

[b]ALERTS
[/b]Three named alert conditions are included: Bullish Liquidity Sweep, Bearish Liquidity Sweep, and
Any Liquidity Sweep.
[i]
DISCLAIMER
For educational purposes only. This is a technical analysis tool, not financial advice, and it does
not predict price. Trading involves risk and you can lose your capital. No indicator is profitable
on its own — always do your own research and use proper risk management.[/i]

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════════════════════════
// Liquidity Sweeps [Quantum Algo]
//
// Maps resting liquidity at confirmed swing highs (buy-side) and swing lows (sell-side), then flags
// liquidity sweeps — the stop-hunt pattern where price spikes through a level on a wick but closes
// back inside, signalling liquidity was taken and the move rejected.
//
//   • Bearish sweep  -> buy-side liquidity above is swept, price closes back below.
//   • Bullish sweep  -> sell-side liquidity below is swept, price closes back above.
//
// An optional volume filter confirms only sweeps backed by above-average participation. Clean breaks
// (price closing fully through a level) are treated as ordinary grabs rather than sweeps.
// ════════════════════════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Liquidity Sweeps [Quantum Algo]", "Liquidity Sweeps [Quantum Algo]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ────────────────────────────────────────────────────────────────────────────────────────────────
// INPUTS
// ────────────────────────────────────────────────────────────────────────────────────────────────
gDet = "Liquidity Detection"
pivotLen   = input.int(8, "Liquidity Pivot Strength", minval = 1, group = gDet, tooltip = "Bars required on each side to confirm a swing that holds resting liquidity. Higher = fewer, more significant pools.")
maxPools   = input.int(15, "Max Levels per Side", minval = 1, maxval = 60, group = gDet, tooltip = "How many of the most recent buy-side and sell-side levels to keep mapped.")
showLevels = input.bool(true, "Show Liquidity Levels", group = gDet)
keepSwept  = input.bool(true, "Keep Swept Levels (faded)", group = gDet, tooltip = "Leave a faded marker after a level has been swept instead of deleting it.")

gLine = "Level Lines"
lineWidth = input.int(3, "Line Width", minval = 1, maxval = 4, group = gLine)
lineStyle = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = gLine)
lineTrans = input.int(10, "Line Transparency", minval = 0, maxval = 90, group = gLine, tooltip = "Lower = more solid/visible. 0 is fully opaque.")

gSig = "Sweep Logic"
useVol    = input.bool(true,  "Require Volume Confirmation", group = gSig, tooltip = "Only confirm a sweep when the sweeping candle trades above-average volume — filters out low-conviction wicks.")
volLen    = input.int(20, "Volume Average Length", minval = 1, group = gSig)
volMult   = input.float(1.5, "Volume Multiplier", minval = 0.1, step = 0.1, group = gSig, tooltip = "Sweep volume must exceed (average volume x this) to qualify when the filter is on.")
ignoreBrk = input.bool(true,  "Treat Clean Breaks as Grabs", group = gSig, tooltip = "If price closes fully through a level (breakout, not a wick sweep), retire the level quietly instead of flagging a sweep.")

gSty = "Style"
bullCol = input.color(#00e5ff, "Bullish Sweep", group = gSty, inline = "rc")
bearCol = input.color(#ff5470, "Bearish Sweep", group = gSty, inline = "rc")
accCol  = input.color(#f0b429, "Accent",        group = gSty)
showLbl = input.bool(true, "Show Sweep Labels",   group = gSty)
showBox = input.bool(true, "Highlight Sweep Wick", group = gSty)

gDash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group = gDash)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Bottom Left"], group = gDash)

// ────────────────────────────────────────────────────────────────────────────────────────────────
// TYPE
// ────────────────────────────────────────────────────────────────────────────────────────────────
type Pool
    float price
    int   bornBar
    bool  buySide   // true = buy-side liquidity (above, at swing highs) | false = sell-side (below, at swing lows)
    bool  swept
    line  ln
    label tag

// ────────────────────────────────────────────────────────────────────────────────────────────────
// STATE
// ────────────────────────────────────────────────────────────────────────────────────────────────
var array<Pool> bsl = array.new<Pool>()   // buy-side liquidity (above price)
var array<Pool> ssl = array.new<Pool>()   // sell-side liquidity (below price)

var int    bullSweeps = 0
var int    bearSweeps = 0
var string lastDir    = "—"

var string lnStyle = switch lineStyle
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    => line.style_solid

var string posSel = switch dashPos
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table dash = table.new(posSel, 2, 7, bgcolor = #0a0e1a, frame_color = #1c2333, frame_width = 1, border_color = #1c2333, border_width = 1)

// ────────────────────────────────────────────────────────────────────────────────────────────────
// METHODS
// ────────────────────────────────────────────────────────────────────────────────────────────────
method stretch(Pool this) =>
    if not na(this.ln)
        this.ln.set_x2(bar_index)

method retire(Pool this, color fadeCol) =>
    if not na(this.ln)
        this.ln.set_color(fadeCol)
        this.ln.set_style(line.style_dotted)
        this.ln.set_x2(bar_index)

// ────────────────────────────────────────────────────────────────────────────────────────────────
// CORE
// ────────────────────────────────────────────────────────────────────────────────────────────────
float volAvg = ta.sma(volume, volLen)
bool  volOk  = not useVol or (volume > nz(volAvg) * volMult)

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low,  pivotLen, pivotLen)

// New buy-side liquidity at a confirmed swing high
if not na(ph)
    int   b  = bar_index - pivotLen
    line  ln = showLevels ? line.new(b, ph, bar_index, ph, color = color.new(bearCol, lineTrans), style = lnStyle, width = lineWidth) : na
    bsl.unshift(Pool.new(ph, b, true, false, ln, na))
    if bsl.size() > maxPools
        Pool gone = bsl.pop()
        if not na(gone.ln)
            gone.ln.delete()
        if not na(gone.tag)
            gone.tag.delete()

// New sell-side liquidity at a confirmed swing low
if not na(pl)
    int   b  = bar_index - pivotLen
    line  ln = showLevels ? line.new(b, pl, bar_index, pl, color = color.new(bullCol, lineTrans), style = lnStyle, width = lineWidth) : na
    ssl.unshift(Pool.new(pl, b, false, false, ln, na))
    if ssl.size() > maxPools
        Pool gone = ssl.pop()
        if not na(gone.ln)
            gone.ln.delete()
        if not na(gone.tag)
            gone.tag.delete()

bool sweepBull = false
bool sweepBear = false

// Evaluate buy-side liquidity (a bearish sweep = wick above, close back below)
if bsl.size() > 0
    for i = bsl.size() - 1 to 0
        if i < bsl.size()
            Pool p = bsl.get(i)
            if not p.swept
                p.stretch()
                if high > p.price
                    bool rejected = close < p.price
                    if rejected and volOk
                        p.swept := true
                        bearSweeps += 1
                        lastDir    := "Bearish"
                        sweepBear  := true
                        if showLbl
                            p.tag := label.new(bar_index, high, "Sweep", style = label.style_label_down, color = color.new(bearCol, 0), textcolor = #0a0e1a, size = size.small)
                        if showBox
                            box.new(bar_index, high, bar_index + 1, p.price, border_color = na, bgcolor = color.new(bearCol, 78))
                        if keepSwept
                            p.retire(color.new(bearCol, 78))
                        else
                            if not na(p.ln)
                                p.ln.delete()
                            bsl.remove(i)
                    else if (not rejected) and ignoreBrk
                        p.swept := true
                        if keepSwept
                            p.retire(color.new(#5a6173, 70))
                        else
                            if not na(p.ln)
                                p.ln.delete()
                            bsl.remove(i)

// Evaluate sell-side liquidity (a bullish sweep = wick below, close back above)
if ssl.size() > 0
    for i = ssl.size() - 1 to 0
        if i < ssl.size()
            Pool p = ssl.get(i)
            if not p.swept
                p.stretch()
                if low < p.price
                    bool rejected = close > p.price
                    if rejected and volOk
                        p.swept := true
                        bullSweeps += 1
                        lastDir    := "Bullish"
                        sweepBull  := true
                        if showLbl
                            p.tag := label.new(bar_index, low, "Sweep", style = label.style_label_up, color = color.new(bullCol, 0), textcolor = #0a0e1a, size = size.small)
                        if showBox
                            box.new(bar_index, p.price, bar_index + 1, low, border_color = na, bgcolor = color.new(bullCol, 78))
                        if keepSwept
                            p.retire(color.new(bullCol, 78))
                        else
                            if not na(p.ln)
                                p.ln.delete()
                            ssl.remove(i)
                    else if (not rejected) and ignoreBrk
                        p.swept := true
                        if keepSwept
                            p.retire(color.new(#5a6173, 70))
                        else
                            if not na(p.ln)
                                p.ln.delete()
                            ssl.remove(i)

// ────────────────────────────────────────────────────────────────────────────────────────────────
// ALERTS
// ────────────────────────────────────────────────────────────────────────────────────────────────
alertcondition(sweepBull, "Bullish Liquidity Sweep", "Bullish liquidity sweep — sell-side swept and reclaimed.")
alertcondition(sweepBear, "Bearish Liquidity Sweep", "Bearish liquidity sweep — buy-side swept and rejected.")
alertcondition(sweepBull or sweepBear, "Any Liquidity Sweep", "Liquidity sweep detected.")

// ────────────────────────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ────────────────────────────────────────────────────────────────────────────────────────────────
if showDash and barstate.islast
    float nearBsl = na
    for p in bsl
        if not p.swept and p.price > close
            nearBsl := na(nearBsl) ? p.price : math.min(nearBsl, p.price)
    float nearSsl = na
    for p in ssl
        if not p.swept and p.price < close
            nearSsl := na(nearSsl) ? p.price : math.max(nearSsl, p.price)

    color hCol = #8a90a0
    color dCol = #e6e9f0

    dash.cell(0, 0, "LIQUIDITY SWEEPS  ·  QUANTUM ALGO", text_color = #0a0e1a, bgcolor = accCol, text_size = size.small, text_halign = text.align_center)
    dash.merge_cells(0, 0, 1, 0)

    dash.cell(0, 1, "Bullish Sweeps", text_color = hCol, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 1, str.tostring(bullSweeps), text_color = bullCol, text_size = size.small, text_halign = text.align_right)

    dash.cell(0, 2, "Bearish Sweeps", text_color = hCol, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 2, str.tostring(bearSweeps), text_color = bearCol, text_size = size.small, text_halign = text.align_right)

    dash.cell(0, 3, "Last Sweep", text_color = hCol, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 3, lastDir, text_color = lastDir == "Bullish" ? bullCol : lastDir == "Bearish" ? bearCol : dCol, text_size = size.small, text_halign = text.align_right)

    dash.cell(0, 4, "Nearest BSL  ↑", text_color = hCol, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 4, na(nearBsl) ? "—" : str.tostring(nearBsl, format.mintick) + "  (" + str.tostring((nearBsl / close - 1) * 100, "#.##") + "%)", text_color = bearCol, text_size = size.small, text_halign = text.align_right)

    dash.cell(0, 5, "Nearest SSL  ↓", text_color = hCol, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 5, na(nearSsl) ? "—" : str.tostring(nearSsl, format.mintick) + "  (" + str.tostring((nearSsl / close - 1) * 100, "#.##") + "%)", text_color = bullCol, text_size = size.small, text_halign = text.align_right)

    dash.cell(0, 6, "Volume Filter", text_color = hCol, text_size = size.small, text_halign = text.align_left)
    dash.cell(1, 6, useVol ? "On  x" + str.tostring(volMult, "#.#") : "Off", text_color = dCol, text_size = size.small, text_halign = text.align_right)
````
