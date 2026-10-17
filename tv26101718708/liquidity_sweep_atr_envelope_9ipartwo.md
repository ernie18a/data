# Liquidity Sweep & ATR Envelope

- url: https://www.tradingview.com/script/9iPARtWO-Liquidity-Sweep-ATR-Envelope/
- type: indicator
- pine_id: PUB;c91e79b844324051bd5084cd3be7fa58
- version: 1.0

## Description

⚡ Liquidity Sweep & ATR Envelope

The market hunts stops. This tool shows you where it just happened — and whether price actually rejected the grab or kept right on going. 🎯

Liquidity sweeps caught at volatility extremes, confirmed by a real reclaim, fully resolved on the bar they fire. No repaint. No HTF trickery.

🔍 THE MECHANICS

📐 The envelope — an ATR band around a 20-period basis. It's the visual anchor on the chart AND the qualification threshold at once: the same measurement does both jobs, so there's no separate cosmetic ATR filter bolted on top.

🎯 Pivot + envelope, both required — a signal needs the wick to breach a confirmed pivot level AND clear the band plus a clearance buffer. Levels are one-shot: any wick through a tracked pivot consumes it, signal or not. Re-arms on the next confirmed pivot.

↩️ Reclaim, not just recovery — the close has to snap back past the swept level by at least half the wick's own penetration depth (adjustable, 0 to disable). A candle that barely creeps back over the line doesn't count as a rejection — the snap-back has to beat the sweep.

Levels are one-shot: any wick through a tracked pivot consumes it — signal or not — and the tool re-arms on the next confirmed swing. What you see is exactly what happened.

🛡️ Non-repaint by construction — pivots confirm after their right-side bars, and every signal, marker, zone, and alert is gated to bar close. A triangle that printed yesterday printed on that bar and never moved. What you backtest is what you trade. ✅

🎨 On the chart:
🌊 Hero ATR envelope with event-driven band glow — bands light up when price presses them or on a fresh sweep.
📦 Gradient sweep zones from swept level to wick extreme — historical signals legible at a glance.
👣 Swept-history footprints so you can read where liquidity already got taken.
🎛️ 8 themes (Suite, Ocean, Royal, Ember, Mono, Frost + full Custom), optional bar tint, trigger-threshold line, compact status table.
🔔 Clean JSON alerts (direction / level / trigger) — wire it straight into your automation.

⏱️ Timeframe notes — single-timeframe and scale-free. Every threshold is measured in ATR or as an intra-bar ratio, so it ports across instruments and timeframes with zero rescaling. Defaults are tuned on H1 and carry to M15 unchanged — comparable signal frequency and reclaim quality on both. On H4 and above the setup is rarer by nature; drop Pivot Left/Right to 3 if you want more events there. Read every signal as liquidity-location context, not a standalone entry — pair it with your structure read (or Confluence Context, regime/confluence indicator on my profile) for direction. 🧭

📈 How to use it — the tool tells you where the market just swept liquidity and rejected. Stack it with structure. 

Built to one standard: still useful after it's been on your chart for a while.

## Source Code

````pine
// =============================================================================
// Liquidity Sweep & ATR Envelope
// SlatinaTrades suite  |  Keywords: Liquidity Sweep, ATR, Grab, Reversal
// -----------------------------------------------------------------------------
// Single-timeframe only. No request.security(), no HTF pulls.
// Stateless same-bar confirmation: a signal is fully resolved on the bar it fires.
// Non-repaint by construction (pivots confirm after pivotRight bars; all
// sweep/reclaim detection and visual latching gated on barstate.isconfirmed).
//
// Levels are ONE-SHOT: any wick through a tracked pivot consumes it, signal or
// not. Re-arms on the next confirmed pivot.
//
// Direction codes (alert payload):  1 = Bullish sweep rejection, -1 = Bearish.
//
// v3.1 — event-driven band glow, gradient envelope zones.
// v3.2 — reclaim displacement guard (the snap-back must beat the sweep).
// =============================================================================
//@version=6
indicator("Liquidity Sweep & ATR Envelope", "Liq Sweep + ATR Env", overlay = true, max_lines_count = 500, max_boxes_count = 100)

// =============================================================================
// 1. INPUTS
// =============================================================================
// --- Logic: Pivot -----------------------------------------------------------
pivotLeft   = input.int(5,  "Pivot Left",  minval = 1, group = "⚙️ Logic — Pivot")
pivotRight  = input.int(5,  "Pivot Right", minval = 1, group = "⚙️ Logic — Pivot")

// --- Logic: Envelope --------------------------------------------------------
basisLen    = input.int(20, "Basis length", minval = 1,   group = "⚙️ Logic — Envelope")
atrLen      = input.int(14, "ATR length",   minval = 1,   group = "⚙️ Logic — Envelope")
atrMult     = input.float(2.0, "Envelope multiplier", minval = 0.1, step = 0.1, group = "⚙️ Logic — Envelope",
     tooltip = "Visual anchor (the hero band). Do not narrow this to tune signal frequency — it degrades the hero element.")

// --- Logic: Sweep Quality ---------------------------------------------------
clearanceMult = input.float(0.15, "Clearance multiplier", minval = 0.0, step = 0.05, group = "⚙️ Logic — Sweep Quality",
     tooltip = "Extra ATR the wick must clear beyond the band. A noise filter on top of the band, not a second envelope.")
closeRatio    = input.float(0.60, "Close-position ratio", minval = 0.50, maxval = 1.0, step = 0.05, group = "⚙️ Logic — Sweep Quality",
     tooltip = "Where the close must sit within the sweep bar's own range. Hard-floored at 0.50 to guarantee bull/bear mutual exclusion.")
reclaimStrength = input.float(0.5, "Reclaim strength", minval = 0.0, step = 0.1, group = "⚙️ Logic — Sweep Quality",
     tooltip = "How hard the close must snap back past the swept level, as a multiple of the wick's penetration depth. 0.5 = reclaim at least half the poke, 1.0 = fully reverse it. Set to 0 to disable (recovery above the level is enough).")

// --- Appearance -------------------------------------------------------------
themeChoice = input.string("Suite", "Theme",
     options = ["Suite", "Classic", "Ocean", "Royal", "Ember", "Mono", "Frost", "Custom"], group = "🎨 Appearance")
dimChoice   = input.string("Subtle", "Dim strength",
     options = ["Off", "Subtle", "Strong"], group = "🎨 Appearance",
     tooltip = "Global transparency shift on swept-history footprints.")

bullCustom    = input.color(#26A69A, "Bull color (Custom)",    group = "🎨 Appearance")
bearCustom    = input.color(#F06292, "Bear color (Custom)",    group = "🎨 Appearance")
neutralCustom = input.color(#787B86, "Neutral color (Custom)", group = "🎨 Appearance")
accentCustom  = input.color(#FFB74D, "Accent color (Custom)",  group = "🎨 Appearance")

showEnv     = input.bool(true, "Show envelope",       group = "🎨 Appearance")
glowEnv     = input.bool(true, "Band glow",           group = "🎨 Appearance",
     tooltip = "Three-layer halo on the bands. Lights up when price presses a band or on a confirmed sweep (signal bar + 2), at one consistent intensity; quiet otherwise.")
showMarkers = input.bool(true, "Show sweep markers",  group = "🎨 Appearance")
markerText  = input.string("Bull / Bear", "Marker text",
     options = ["None", "Bull / Bear", "Sweep"], group = "🎨 Appearance",
     tooltip = "Word tag beside each triangle. Bull/Bear reads direction at a glance; Sweep is direction-neutral; None keeps just the triangle. Follows 'Show sweep markers'.")
showLevels  = input.bool(true, "Show pivot levels",   group = "🎨 Appearance")
showHistory = input.bool(true, "Show swept history",  group = "🎨 Appearance")
showZones   = input.bool(true, "Show sweep zones",    group = "🎨 Appearance",
     tooltip = "Shaded box from the swept level to the wick extreme on each signal. Makes historical signals legible at a glance.")
showThresh  = input.bool(false, "Show trigger threshold", group = "🎨 Appearance",
     tooltip = "Faint dotted line at band + clearance — the actual distance a wick must clear to qualify. Off by default to keep the chart clean.")
colorBars   = input.bool(false, "Tint signal bars",   group = "🎨 Appearance",
     tooltip = "Colors the sweep-rejection bar itself in signal color.")
showWatermark = input.bool(true, "Watermark", group = "🎨 Appearance",
     tooltip = "SlatinaTrades brand mark, bottom-right. On by default so published screenshots carry the source; turn off for a bare chart.")

// --- Table ------------------------------------------------------------------
showTable      = input.bool(false, "Show table", group = "📊 Table")
tablePosChoice = input.string("Top Right", "Table position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "📊 Table")

// =============================================================================
// 2. THEME RESOLUTION  (every derived color computed from these four)
// =============================================================================
col_bull = switch themeChoice
    "Suite"   => #26A69A
    "Classic" => #26A69A
    "Ocean"   => #00B8D4
    "Royal"   => #42BDA8
    "Ember"   => #9CCC65
    "Mono"    => #E0E0E0
    "Frost"   => #4DD0E1
    "Custom"  => bullCustom
    => #26A69A

col_bear = switch themeChoice
    "Suite"   => #F06292
    "Classic" => #EF5350
    "Ocean"   => #FF7043
    "Royal"   => #E85D75
    "Ember"   => #FF5252
    "Mono"    => #616161
    "Frost"   => #F06292
    "Custom"  => bearCustom
    => #F06292

col_neutral = switch themeChoice
    "Suite"   => #787B86
    "Classic" => #787B86
    "Ocean"   => #546E7A
    "Royal"   => #6C7293
    "Ember"   => #8D8D8D
    "Mono"    => #9E9E9E
    "Frost"   => #78909C
    "Custom"  => neutralCustom
    => #787B86

col_accent = switch themeChoice
    "Suite"   => #FFB74D
    "Classic" => #FFB74D
    "Ocean"   => #FFD54F
    "Royal"   => #B39DDB
    "Ember"   => #FF8F00
    "Mono"    => #00E5FF
    "Frost"   => #FFF176
    "Custom"  => accentCustom
    => #FFB74D

// --- transparency ladder ----------------------------------------------------
basisTransp  = 20
bandTransp   = 30
markerTransp = 5
gradTransp   = 86   // gradient zone strength at the band edge (fades to 100 at basis)
zoneBgTransp = 82
zoneBrTransp = 45
tintTransp   = 55   // side tint on active pivot lines
dimOffset       = dimChoice == "Off" ? 0 : dimChoice == "Strong" ? 30 : 15
footprintTransp = int(math.min(95, 67 + dimOffset))   // Off 67 · Subtle 82 · Strong 97→95

// --- watermark 
var table wmTable = na
if showWatermark and barstate.islast
    if na(wmTable)
        wmTable := table.new(position.bottom_right, 1, 1)
    table.cell(wmTable, 0, 0, "SlatinaTrades",
         text_color = color.new(col_neutral, 35),
         text_size  = size.normal)

// =============================================================================
// 3. ENVELOPE  (one volatility measure drives the visual band AND the threshold)
// =============================================================================
basis     = ta.sma(close, basisLen)
atrVal    = ta.atr(atrLen)
upperBand = basis + atrMult * atrVal
lowerBand = basis - atrMult * atrVal

// =============================================================================
// 4. PIVOTS  (non-repaint: confirm pivotRight bars after they form)
// =============================================================================
phVal = ta.pivothigh(pivotLeft, pivotRight)
plVal = ta.pivotlow(pivotLeft, pivotRight)

var float trackedPH = na   // most recent unswept pivot high
var float trackedPL = na   // most recent unswept pivot low
var line  phLine    = na   // active high level line
var line  plLine    = na   // active low  level line
var array<line> fpLines = array.new<line>()   // latched swept-history footprints
var array<box>  zBoxes  = array.new<box>()    // latched sweep zone boxes
var int lastDir = 0    // 1 bull, -1 bear, 0 none (table readout only)
var int lastBar = na   // bar_index of last signal (table readout only)

// =============================================================================
// 5. SWEEP LOGIC  (evaluated per bar; state mutation gated to confirmed bars)
// =============================================================================
rng        = high - low
validRange = rng > 0

plBreach = not na(trackedPL) and low  < trackedPL      // pivot low  wicked through
phBreach = not na(trackedPH) and high > trackedPH      // pivot high wicked through

bullEnv  = low  < (lowerBand - clearanceMult * atrVal) // wick also clears lower band + clearance
bearEnv  = high > (upperBand + clearanceMult * atrVal)

// Displacement guard: close must reclaim past the swept level by ≥
// reclaimStrength × penetration depth. 0 disables.
bullDisp = close - trackedPL >= reclaimStrength * (trackedPL - low)
bearDisp = trackedPH - close >= reclaimStrength * (high - trackedPH)

// reclaim = level recovery AND candle quality AND displacement, all required
bullReclaim = not na(trackedPL) and close > trackedPL and close > lowerBand and validRange and (close - low) / rng >= closeRatio and bullDisp
bearReclaim = not na(trackedPH) and close < trackedPH and close < upperBand and validRange and (high - close) / rng >= closeRatio and bearDisp

bullSig = plBreach and bullEnv and bullReclaim
bearSig = phBreach and bearEnv and bearReclaim
bearSig := bearSig and not bullSig   // mutual exclusion; closes the closeRatio = 0.50 edge case

// --- alert payload -----------------------------------------------------------
// Captured BEFORE section 6 resets the level on breach — moving it below reads na.
sigDir   = bullSig and barstate.isconfirmed ?  1.0 : bearSig and barstate.isconfirmed ? -1.0 : na
sigLevel = bullSig and barstate.isconfirmed ? trackedPL : bearSig and barstate.isconfirmed ? trackedPH : na
sigTrig  = bullSig and barstate.isconfirmed ? low       : bearSig and barstate.isconfirmed ? high      : na

// =============================================================================
// 6. STATE + DRAWING  (confirmed bars only → non-repaint)
// -----------------------------------------------------------------------------
// One-shot rule lives here: any breach releases the level (signal or not).
// A qualifying sweep latches footprint + zone first; a failed poke leaves nothing.
// =============================================================================
fpBull = color.new(color.from_gradient(0.5, 0, 1, col_bull, col_neutral), footprintTransp)
fpBear = color.new(color.from_gradient(0.5, 0, 1, col_bear, col_neutral), footprintTransp)

if barstate.isconfirmed
    // --- pivot-low breach (bullish sweep side) ------------------------------
    if plBreach
        lvl = trackedPL
        if bullSig
            lastDir := 1
            lastBar := bar_index
            if showZones
                array.push(zBoxes, box.new(left = bar_index - 1, top = lvl, right = bar_index + 1, bottom = low, xloc = xloc.bar_index, border_color = color.new(col_bull, zoneBrTransp), border_width = 1, bgcolor = color.new(col_bull, zoneBgTransp)))
        if bullSig and showLevels and showHistory and not na(plLine)
            line.set_color(plLine, fpBull)
            line.set_extend(plLine, extend.none)
            line.set_x2(plLine, bar_index)
            array.push(fpLines, plLine)
            conn = line.new(x1 = bar_index, y1 = lvl, x2 = bar_index, y2 = low, xloc = xloc.bar_index, extend = extend.none, color = fpBull, style = line.style_dotted, width = 1)
            array.push(fpLines, conn)
        else if not na(plLine)
            line.delete(plLine)
        plLine    := na
        trackedPL := na

    // --- pivot-high breach (bearish sweep side) -----------------------------
    if phBreach
        lvl = trackedPH
        if bearSig
            lastDir := -1
            lastBar := bar_index
            if showZones
                array.push(zBoxes, box.new(left = bar_index - 1, top = high, right = bar_index + 1, bottom = lvl, xloc = xloc.bar_index, border_color = color.new(col_bear, zoneBrTransp), border_width = 1, bgcolor = color.new(col_bear, zoneBgTransp)))
        if bearSig and showLevels and showHistory and not na(phLine)
            line.set_color(phLine, fpBear)
            line.set_extend(phLine, extend.none)
            line.set_x2(phLine, bar_index)
            array.push(fpLines, phLine)
            conn = line.new(x1 = bar_index, y1 = lvl, x2 = bar_index, y2 = high, xloc = xloc.bar_index, extend = extend.none, color = fpBear, style = line.style_dotted, width = 1)
            array.push(fpLines, conn)
        else if not na(phLine)
            line.delete(phLine)
        phLine    := na
        trackedPH := na

    // --- track newly confirmed pivots ----------------------------------------
    // One level per side, always the most recent — newer swings carry newer stops.
    if not na(plVal)
        if not na(plLine)
            line.delete(plLine)
            plLine := na
        trackedPL := plVal
        if showLevels
            plLine := line.new(x1 = bar_index - pivotRight, y1 = plVal, x2 = bar_index, y2 = plVal, xloc = xloc.bar_index, extend = extend.right, color = color.new(color.from_gradient(0.35, 0, 1, col_neutral, col_bull), tintTransp), style = line.style_dotted, width = 1)

    if not na(phVal)
        if not na(phLine)
            line.delete(phLine)
            phLine := na
        trackedPH := phVal
        if showLevels
            phLine := line.new(x1 = bar_index - pivotRight, y1 = phVal, x2 = bar_index, y2 = phVal, xloc = xloc.bar_index, extend = extend.right, color = color.new(color.from_gradient(0.35, 0, 1, col_neutral, col_bear), tintTransp), style = line.style_dotted, width = 1)

    // --- cap footprint objects (delete oldest past the cap) ------------------
    // 2 lines per signal (level + connector), so 100 lines ≈ 50 signals of
    // visible history; 60 boxes covers the same window with headroom.
    while array.size(fpLines) > 100
        line.delete(array.shift(fpLines))
    while array.size(zBoxes) > 60
        box.delete(array.shift(zBoxes))

// =============================================================================
// 7. PLOTS
// =============================================================================
// Envelope (hero element). Band edges light up in signal color on a close beyond
// them — a live "outside the envelope" read. Color-only, no repaint.
upPress = close > upperBand
dnPress = close < lowerBand
upCol   = upPress ? color.new(col_bear, 10) : color.new(col_neutral, bandTransp)
dnCol   = dnPress ? color.new(col_bull, 10) : color.new(col_neutral, bandTransp)

// Band glow — three-layer halo, event-driven. Fires on band pressure or the
// signal bar + 2 after a confirmed sweep; one shared intensity (60/82/93).
bsBull    = ta.barssince(bullSig and barstate.isconfirmed)
bsBear    = ta.barssince(bearSig and barstate.isconfirmed)
bullPulse = not na(bsBull) and bsBull <= 2
bearPulse = not na(bsBear) and bsBear <= 2

loCore = (bullPulse or dnPress) ? 60 : 100
loMid  = (bullPulse or dnPress) ? 82 : 100
loOut  = (bullPulse or dnPress) ? 93 : 100
upCore = (bearPulse or upPress) ? 60 : 100
upMid  = (bearPulse or upPress) ? 82 : 100
upOut  = (bearPulse or upPress) ? 93 : 100

// glow renders under the band lines (plot order = z-order)
plot(showEnv and glowEnv ? upperBand : na, "Upper glow outer", color.new(col_bear, upOut), 14, display = display.pane)
plot(showEnv and glowEnv ? upperBand : na, "Upper glow mid",   color.new(col_bear, upMid),  8, display = display.pane)
plot(showEnv and glowEnv ? upperBand : na, "Upper glow core",  color.new(col_bear, upCore), 4, display = display.pane)
plot(showEnv and glowEnv ? lowerBand : na, "Lower glow outer", color.new(col_bull, loOut), 14, display = display.pane)
plot(showEnv and glowEnv ? lowerBand : na, "Lower glow mid",   color.new(col_bull, loMid),  8, display = display.pane)
plot(showEnv and glowEnv ? lowerBand : na, "Lower glow core",  color.new(col_bull, loCore), 4, display = display.pane)

pB = plot(showEnv ? basis     : na, "Basis",      color = color.new(col_neutral, basisTransp), linewidth = 1)
pU = plot(showEnv ? upperBand : na, "Upper Band", color = upCol, linewidth = 2)
pL = plot(showEnv ? lowerBand : na, "Lower Band", color = dnCol, linewidth = 2)

// Gradient zones: strongest at each band edge, fading to nothing at the basis —
// walls with an airy center, candles unobstructed.
fill(pB, pU, top_value = upperBand, bottom_value = basis,
     top_color = color.new(col_bear, gradTransp), bottom_color = color.new(col_bear, 100),
     title = "Upper Zone")
fill(pB, pL, top_value = basis, bottom_value = lowerBand,
     top_color = color.new(col_bull, 100), bottom_color = color.new(col_bull, gradTransp),
     title = "Lower Zone")

// Trigger threshold (default off): the line a wick must clear (band ± clearance × ATR).
trigUp = upperBand + clearanceMult * atrVal
trigDn = lowerBand - clearanceMult * atrVal
plot(showEnv and showThresh ? trigUp : na, "Trigger Threshold Upper", color = color.new(col_bear, 60), linewidth = 1, style = plot.style_circles)
plot(showEnv and showThresh ? trigDn : na, "Trigger Threshold Lower", color = color.new(col_bull, 60), linewidth = 1, style = plot.style_circles)

// Optional signal-bar tint (default off)
barcolor(colorBars and barstate.isconfirmed ? (bullSig ? col_bull : bearSig ? col_bear : na) : na, title = "Signal Bar Tint")

// Signal markers (one per event). Text rides inside the plotshape so it stays
// locked to the triangle at any zoom. size.tiny clears auto-fit clipping;
// 'text' must be const, so each mode is a separate call.
bullMark = bullSig and barstate.isconfirmed and showMarkers
bearMark = bearSig and barstate.isconfirmed and showMarkers
bullCol  = color.new(col_bull, markerTransp)
bearCol  = color.new(col_bear, markerTransp)

plotshape(bullMark and markerText == "None",        "Bullish Sweep",        shape.triangleup,   location.belowbar, color = bullCol, size = size.tiny)
plotshape(bearMark and markerText == "None",        "Bearish Sweep",        shape.triangledown, location.abovebar, color = bearCol, size = size.tiny)

plotshape(bullMark and markerText == "Bull / Bear", "Bullish Sweep · BULL", shape.triangleup,   location.belowbar, color = bullCol, text = "BULL", textcolor = color.new(col_bull, 0), size = size.tiny)
plotshape(bearMark and markerText == "Bull / Bear", "Bearish Sweep · BEAR", shape.triangledown, location.abovebar, color = bearCol, text = "BEAR", textcolor = color.new(col_bear, 0), size = size.tiny)

plotshape(bullMark and markerText == "Sweep",       "Bullish Sweep · SWEEP",shape.triangleup,   location.belowbar, color = bullCol, text = "SWEEP", textcolor = color.new(col_bull, 0), size = size.tiny)
plotshape(bearMark and markerText == "Sweep",       "Bearish Sweep · SWEEP",shape.triangledown, location.abovebar, color = bearCol, text = "SWEEP", textcolor = color.new(col_bear, 0), size = size.tiny)

// =============================================================================
// 8. ALERTS  (hidden payload plots + alertcondition)
// =============================================================================
plot(sigDir,   "alert_dir",     display = display.none)
plot(sigLevel, "alert_level",   display = display.none)
plot(sigTrig,  "alert_trigger", display = display.none)

alertcondition(bullSig and barstate.isconfirmed, "Bullish Sweep Rejection",
     '{"type":"liq_sweep","dir":{{plot("alert_dir")}},"level":{{plot("alert_level")}},"trigger":{{plot("alert_trigger")}}}')
alertcondition(bearSig and barstate.isconfirmed, "Bearish Sweep Rejection",
     '{"type":"liq_sweep","dir":{{plot("alert_dir")}},"level":{{plot("alert_level")}},"trigger":{{plot("alert_trigger")}}}')

// =============================================================================
// 9. STATUS TABLE  (default OFF; reference readout only)
// =============================================================================
tablePos = switch tablePosChoice
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table infoTable = na
if showTable and barstate.islast
    if na(infoTable)
        infoTable := table.new(tablePos, 2, 4, border_width = 1, border_color = color.new(col_neutral, 60))
    bgCol   = color.new(col_neutral, 88)
    labCol  = color.new(col_neutral, 0)
    valCol  = color.new(col_accent, 0)
    sigAge  = na(lastBar) ? "" : " · " + str.tostring(bar_index - lastBar) + " bars ago"
    sigTxt  = lastDir == 1 ? "▲ Bull" + sigAge : lastDir == -1 ? "▼ Bear" + sigAge : "—"
    sigCol  = lastDir == 1 ? color.new(col_bull, 0) : lastDir == -1 ? color.new(col_bear, 0) : valCol
    table.cell(infoTable, 0, 0, "Pivot High", text_color = labCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 1, 0, na(trackedPH) ? "—" : str.tostring(trackedPH, format.mintick), text_color = valCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 0, 1, "Pivot Low",  text_color = labCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 1, 1, na(trackedPL) ? "—" : str.tostring(trackedPL, format.mintick), text_color = valCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 0, 2, "ATR(" + str.tostring(atrLen) + ")", text_color = labCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 1, 2, str.tostring(atrVal, format.mintick), text_color = valCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 0, 3, "Last signal", text_color = labCol, bgcolor = bgCol, text_size = size.small)
    table.cell(infoTable, 1, 3, sigTxt, text_color = sigCol, bgcolor = bgCol, text_size = size.small)
````
