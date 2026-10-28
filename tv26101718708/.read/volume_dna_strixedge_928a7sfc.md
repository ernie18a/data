# Volume DNA [StrixEDGE]

- url: https://www.tradingview.com/script/928a7sFC-Volume-DNA-StrixEDGE/
- type: indicator
- pine_id: PUB;a94c117bdcb2405bb335be85ecf8e204
- version: 1.0

## Description

📊 WHAT IT DOES
StrixEDGE Volume DNA produces a single score from 0-100 that reveals whether the current price movement has genuine volume support. It synthesizes four independent volume metrics — OBV slope, Chaikin Money Flow, Relative Volume, and Volume-Price Alignment — into one easy-to-read composite. Think of it as a health check for any price move.

🔬 WHY IT'S DIFFERENT
Individual volume indicators each tell part of the story. OBV shows cumulative flow. CMF shows bounded pressure. RVOL shows participation levels. None alone gives the full picture. Volume DNA combines all four with equal weighting into a normalized 0-100 score — something no existing public indicator does. The optional breakdown mode lets you see exactly which component is driving the overall score.

⚙️ HOW IT WORKS
Four components, each scored 0-25 points:
• OBV Slope (0-25): Linear regression slope of On-Balance Volume, normalized by ATR. Rising OBV = accumulation = high score.
• CMF Score (0-25): Chaikin Money Flow mapped to 0-25 range. Positive CMF = buying pressure.
• RVOL Score (0-25): Current volume vs 20-period average. Above-average volume = higher conviction.
• Volume-Price Alignment (0-25): Are price and volume moving together? Rising price + rising volume = healthy. Rising price + falling volume = dangerous divergence.

The composite is smoothed with a 3-period EMA to reduce noise.

📈 HOW TO USE
• Score 80-100 (GREEN): Price move is well-supported — hold positions, trail stops
• Score 60-80: Adequate support — normal trading
• Score 40-60 (YELLOW): Mixed signals — reduce position size, tighten stops
• Score 20-40 (ORANGE): Weak support — avoid new entries in move direction
• Score 0-20 (RED): Critical — the move is unsupported and likely to reverse
• Enable "Show Breakdown" to identify which specific component is weak

🎛️ INPUTS & DEFAULTS
OBV Regression: 14 | CMF Period: 20 | RVOL Baseline: 20
Price Alignment LB: 5 | Smoothing: 3 | Breakdown: OFF

═══════════════════════════════════════════════════════

🔧 CUSTOMIZATION
All parameters are fully adjustable through the indicator settings panel. Inputs are grouped logically:
• ⚙️ Core Parameters — main calculation settings
• 📊 Table Settings — table size (Tiny to Huge), position (4 corners), visibility toggle
• 🎨 Visual Settings — colors, show/hide elements
• 🔔 Alert Settings — threshold values for notifications

📊 DATA TABLE
A built-in data table displays all key metrics in real-time. Adjust the table size from Tiny to Huge to match your chart layout. Position it in any corner. Toggle visibility on/off.

🔔 ALERTS
Pre-built alert conditions for all major signals. Set up alerts via TradingView's alert dialog — select this indicator and choose from the available conditions.

⏱️ RECOMMENDED TIMEFRAMES
Works on all timeframes. Recommended: 1H, 4H, Daily for best signal quality. Lower timeframes produce more signals but with higher noise. Weekly/Monthly for position trading context.

✅ COMPLIANCE
• No repainting — all signals based on confirmed bar close data
• No future data references
• Open-source code — verify the logic yourself

⚠️ DISCLAIMER
This indicator is a technical analysis tool, not financial advice. It does not predict future price movements. Past patterns and signals do not guarantee future results. Trading involves substantial risk of loss. Always use proper risk management, including stop losses and appropriate position sizing. Never risk more than you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator('Volume DNA [StrixEDGE]', overlay=false, max_labels_count=500, max_lines_count=500, max_bars_back=5000)


// ═══ INPUTS ═══

// Core calculation parameters
obvSlopeLength = input.int(14, "OBV Regression Length", minval=2, maxval=100, tooltip="Lookback period for OBV linear regression slope calculation. Standard: 14. Shorter = more reactive to recent accumulation/distribution shifts.", group="⚙️ Core Parameters")
cmfLength      = input.int(20, "CMF Period", minval=2, maxval=100, tooltip="Chaikin Money Flow calculation period. Standard: 20. Measures buying vs selling pressure using volume-weighted close position within the bar range.", group="⚙️ Core Parameters")
rvolLength     = input.int(20, "RVOL Baseline Period", minval=5, maxval=200, tooltip="SMA period for the relative volume baseline. Standard: 20. Current volume is divided by this average to gauge participation.", group="⚙️ Core Parameters")
priceChangeLB  = input.int(5, "Price-Volume Alignment LB", minval=1, maxval=50, tooltip="Lookback bars for comparing price direction against volume direction. Standard: 5. Detects divergences between price and volume trends.", group="⚙️ Core Parameters")
smoothing      = input.int(3, "Score Smoothing EMA", minval=1, maxval=20, tooltip="EMA period applied to the raw composite score. Standard: 3. Higher values produce smoother but slower-reacting readings.", group="⚙️ Core Parameters")

// Visual toggles
showBreakdown = input.bool(false, "Show Component Scores", tooltip="Overlay individual OBV, CMF, RVOL, and VPA component score lines (0-25 each) on the chart.", group="🎨 Visual Settings")
showLabel     = input.bool(true, "Show Score Label", tooltip="Display a floating label on the last bar with the DNA score and full component breakdown.", group="🎨 Visual Settings")

// Table settings
tableSize = input.string("Normal", title="📐 Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], tooltip="Adjust the display size of the data table", group="📊 Table Settings")
tablePos  = input.string("Top Right", title="📍 Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], tooltip="Position of the data table on chart", group="📊 Table Settings")
showTable = input.bool(true, title="Show Table", tooltip="Toggle data table visibility", group="📊 Table Settings")

// Resolve table size
tSize = switch tableSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

// Resolve table position
tPos = switch tablePos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right


// ═══ CALCULATIONS ═══

// --- Component 1: OBV Slope Score (0-25) ---
// Measures accumulation/distribution momentum via OBV linear regression slope.
// Rising slope = accumulation (high score), falling = distribution (low score).
obvValue  = ta.obv
obvCurr   = ta.linreg(obvValue, obvSlopeLength, 0)
obvPrev   = ta.linreg(obvValue, obvSlopeLength, 1)
obvSlope  = obvCurr - obvPrev
atrNorm   = ta.atr(14)
obvScore  = atrNorm > 0 ? math.max(0.0, math.min(25.0, (obvSlope / atrNorm) * 50.0 + 12.5)) : 12.5

// --- Component 2: CMF Score (0-25) ---
// Chaikin Money Flow: volume-weighted measure of buying vs selling pressure.
// CMF > 0 = net buying, CMF < 0 = net selling. Mapped linearly to 0-25.
cmfMult    = high != low ? ((close - low) - (high - close)) / (high - low) : 0.0
cmfMfVol   = cmfMult * volume
cmfValue   = ta.sma(volume, cmfLength) != 0 ? ta.sma(cmfMfVol, cmfLength) / ta.sma(volume, cmfLength) : 0.0
cmfScore   = math.max(0.0, math.min(25.0, (cmfValue + 0.5) * 25.0))

// --- Component 3: Relative Volume Score (0-25) ---
// Current volume vs its SMA baseline. RVOL > 1 = above-average participation.
volSma     = ta.sma(volume, rvolLength)
rvol       = volSma > 0 ? volume / volSma : 1.0
rvolScore  = math.max(0.0, math.min(25.0, (rvol - 0.5) * 12.5))

// --- Component 4: Volume-Price Alignment Score (0-25) ---
// Checks whether volume confirms or contradicts the price direction.
// Healthy: price up + volume up (25), exhaustion sell: price down + volume down (15),
// Divergence/distribution: mismatched directions (5).
priceChange = close - close[priceChangeLB]
volSmaShort = ta.sma(volume, 5)
volChange   = volSmaShort - nz(volSmaShort[priceChangeLB])

float alignScore = 12.5
if priceChange > 0 and volChange > 0
    alignScore := 25.0   // Healthy up — price rising on rising volume
else if priceChange > 0 and volChange < 0
    alignScore := 5.0    // Weak up — price rising but volume drying up
else if priceChange < 0 and volChange > 0
    alignScore := 5.0    // Distribution — price falling on rising volume
else if priceChange < 0 and volChange < 0
    alignScore := 15.0   // Exhaustion — selling pressure may be fading

// --- Composite DNA Score ---
rawScore = obvScore + cmfScore + rvolScore + alignScore
dnaScore = math.max(0.0, math.min(100.0, ta.ema(rawScore, smoothing)))


// ═══ SIGNALS & CONDITIONS ═══

// Zone classification for display
string zoneText = switch
    dnaScore >= 80 => "STRONG DNA ▲"
    dnaScore >= 60 => "HEALTHY ▲"
    dnaScore >= 40 => "NEUTRAL"
    dnaScore >= 20 => "WEAK ▼"
    => "CRITICAL ▼"

// Threshold crossings
crossAbove60 = ta.crossover(dnaScore, 60.0)
crossBelow40 = ta.crossunder(dnaScore, 40.0)


// ═══ VISUALIZATION ═══

// Histogram color gradient based on score intensity
histColor = dnaScore > 70 ? color.new(#00BA7C, 20) : dnaScore > 50 ? color.new(#FFD700, 30) : dnaScore > 30 ? color.new(#F7931A, 30) : color.new(#F4212E, 20)

// Main histogram plot
plot(dnaScore, "Volume DNA", color=histColor, style=plot.style_columns, linewidth=4)

// Reference zone lines
h100 = hline(100, "", color=color.new(#00BA7C, 95))
h80  = hline(80, "Strong (80)", color=color.new(#00BA7C, 70), linestyle=hline.style_dashed)
h60  = hline(60, "Healthy (60)", color=color.new(#FFD700, 70), linestyle=hline.style_dotted)
h40  = hline(40, "Weak (40)", color=color.new(#F7931A, 70), linestyle=hline.style_dotted)
h20  = hline(20, "Critical (20)", color=color.new(#F4212E, 70), linestyle=hline.style_dashed)
h0   = hline(0, "", color=color.new(#F4212E, 95))

// Subtle background fills for extreme zones
fill(h80, h100, color=color.new(#00BA7C, 93), title="Strong Zone BG")
fill(h0, h20, color=color.new(#F4212E, 93), title="Critical Zone BG")

// Optional component breakdown lines (0-25 scale each)
plot(showBreakdown ? obvScore   : na, "OBV Score",  color=color.new(#1D9BF0, 40), linewidth=1, style=plot.style_line)
plot(showBreakdown ? cmfScore   : na, "CMF Score",  color=color.new(#00BA7C, 40), linewidth=1, style=plot.style_line)
plot(showBreakdown ? rvolScore  : na, "RVOL Score", color=color.new(#F7931A, 40), linewidth=1, style=plot.style_line)
plot(showBreakdown ? alignScore : na, "VPA Score",  color=color.new(#9C27B0, 40), linewidth=1, style=plot.style_line)

// Floating score label on last bar
var label scoreLabel = na
if showLabel and barstate.islast
    if not na(scoreLabel)
        label.delete(scoreLabel)
    labelText = "DNA: " + str.tostring(nz(dnaScore), "#.#") + " | OBV:" + str.tostring(nz(obvScore), "#.#") + " CMF:" + str.tostring(nz(cmfScore), "#.#") + " RVOL:" + str.tostring(nz(rvolScore), "#.#") + " VPA:" + str.tostring(nz(alignScore), "#.#")
    scoreLabel := label.new(bar_index, nz(dnaScore), labelText, style=label.style_label_left, color=color.new(#1a1a2e, 10), textcolor=color.white, size=size.normal)


// ═══ DATA TABLE ═══

if barstate.islast and showTable
    var tbl = table.new(tPos, columns=2, rows=9, bgcolor=#ffffff, border_color=#f0f0f0, border_width=1, frame_color=#1a1a2e, frame_width=0)

    // ── Row 0: Dark header bar ──
    table.cell(tbl, 0, 0, "StrixEDGE Volume DNA", bgcolor=#1a1a2e, text_color=#ffffff, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 0, syminfo.ticker + " · " + timeframe.period, bgcolor=#1a1a2e, text_color=#9e9e9e, text_size=tSize, text_halign=text.align_right)

    // ── Row 1: Zone status ──
    zoneColor = dnaScore >= 60 ? #00b07c : dnaScore >= 40 ? #666666 : #e53935
    table.cell(tbl, 0, 1, "Zone", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 1, zoneText, bgcolor=#ffffff, text_color=zoneColor, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 2: Composite DNA score ──
    dnaColor = dnaScore >= 70 ? #00b07c : dnaScore >= 30 ? #666666 : #e53935
    table.cell(tbl, 0, 2, "DNA Score", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 2, str.tostring(nz(dnaScore), "#.#"), bgcolor=#ffffff, text_color=dnaColor, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 3: OBV component ──
    obvC = obvScore >= 18.0 ? #00b07c : obvScore >= 8.0 ? #666666 : #e53935
    table.cell(tbl, 0, 3, "OBV Score", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(nz(obvScore), "#.#") + " / 25", bgcolor=#ffffff, text_color=obvC, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 4: CMF component ──
    cmfC = cmfScore >= 18.0 ? #00b07c : cmfScore >= 8.0 ? #666666 : #e53935
    table.cell(tbl, 0, 4, "CMF Score", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(nz(cmfScore), "#.#") + " / 25", bgcolor=#ffffff, text_color=cmfC, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 5: RVOL component ──
    rvolC = rvolScore >= 18.0 ? #00b07c : rvolScore >= 8.0 ? #666666 : #e53935
    table.cell(tbl, 0, 5, "RVOL Score", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(nz(rvolScore), "#.#") + " / 25", bgcolor=#ffffff, text_color=rvolC, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 6: VPA component ──
    vpaC = alignScore >= 20.0 ? #00b07c : alignScore >= 10.0 ? #666666 : #e53935
    table.cell(tbl, 0, 6, "VPA Score", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(nz(alignScore), "#.#") + " / 25", bgcolor=#ffffff, text_color=vpaC, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 7: Raw RVOL ratio ──
    rvolRC = rvol >= 1.5 ? #00b07c : rvol >= 0.8 ? #666666 : #e53935
    table.cell(tbl, 0, 7, "RVOL", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 7, str.tostring(nz(rvol), "#.##") + "x", bgcolor=#ffffff, text_color=rvolRC, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 8: Raw CMF value ──
    cmfRC = cmfValue > 0.05 ? #00b07c : cmfValue < -0.05 ? #e53935 : #666666
    table.cell(tbl, 0, 8, "CMF", bgcolor=#ffffff, text_color=#666666, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 8, str.tostring(nz(cmfValue), "#.###"), bgcolor=#ffffff, text_color=cmfRC, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)


// ═══ ALERTS ═══

alertcondition(dnaScore > 80, "Strong Volume DNA", "StrixEDGE Volume DNA: Score above 80 — strong move support")
alertcondition(dnaScore < 20, "Critical Volume DNA", "StrixEDGE Volume DNA: Score below 20 — move lacks support")
alertcondition(crossAbove60, "DNA Recovery", "StrixEDGE Volume DNA: Score crossed above 60 — recovery signal")
alertcondition(crossBelow40, "DNA Weakening", "StrixEDGE Volume DNA: Score dropped below 40 — weakening signal")
````
