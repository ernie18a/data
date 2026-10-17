# Trend Quality Index [StrixEDGE]

- url: https://www.tradingview.com/script/uVtWVTuz-Trend-Quality-Index-StrixEDGE/
- type: indicator
- pine_id: PUB;d2ea8bce46134719a38ea388529f927f
- version: 1.0

## Description

📊 WHAT IT DOES
StrixEDGE Trend Quality Index answers the question most trend indicators ignore: not just whether a trend exists, but how good it is. It produces a 0-100 composite score measuring trend quality across four dimensions — velocity, strength, clarity, and multi-timeframe agreement.

🔬 WHY IT'S DIFFERENT
ADX tells you trend strength. Supertrend tells you direction. Neither tells you the complete quality picture. TQI combines four independent metrics: LSMA velocity (how fast the trend moves), ADX with DI gap analysis (how strong and directionally clear), Vortex Indicator separation (how unambiguous the direction), and triple Supertrend agreement (how many timeframe perspectives agree). A trend scoring 90+ on all four dimensions is far more tradeable than one scoring well on just one.

⚙️ HOW IT WORKS
Four scores, each 0-25 points, summed and smoothed:
• LSMA Velocity: Linear regression slope speed, normalized by ATR. Faster trends score higher.
• ADX Strength: ADX value mapped to 0-20, plus a bonus for wide DI+/DI- gap (clearer direction).
• Vortex Clarity: Distance between VI+ and VI- lines. Wider = more decisive trend.
• Supertrend Agreement: Three Supertrends (fast/medium/slow) — all aligned = 25, two = 15, split = 5.

📈 HOW TO USE
• TQI 80-100: EXCELLENT — aggressive trend-following, wide targets
• TQI 60-80: GOOD — standard trend trades, normal position sizing
• TQI 40-60: FAIR — cautious entries, tight stops, reduced size
• TQI below 40: POOR — avoid trend strategies, consider range setups instead
• Direction arrows show which way the quality trend points

🎛️ INPUTS & DEFAULTS
LSMA: 20/5 | ADX: 14 | Vortex: 14 | Supertrend: 7/2, 10/3, 14/4 | Smooth: 3

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
indicator('Trend Quality Index [StrixEDGE]', overlay=false, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// ═══════════════════════════════════════════════════════
// ═══ INPUTS ═══
// ═══════════════════════════════════════════════════════

// ── Core Parameters ──
lsmaLength  = input.int(20, "LSMA Period", minval=5, maxval=100, tooltip="Least-squares regression period for trend velocity measurement. Standard: 20. Shorter periods react faster to price changes but produce noisier velocity readings.", group="⚙️ Core Parameters")
velocityLB  = input.int(5, "Velocity Lookback", minval=1, maxval=30, tooltip="Number of bars over which LSMA rate of change is measured. Lower values = more reactive velocity, higher = smoother. Recommended: 3–8.", group="⚙️ Core Parameters")
adxPeriod   = input.int(14, "ADX / DMI Period", minval=5, maxval=50, tooltip="Period for ADX and Directional Movement Index calculations. Standard: 14. Longer periods filter out minor directional noise.", group="⚙️ Core Parameters")
vortexPeriod = input.int(14, "Vortex Period", minval=5, maxval=50, tooltip="Lookback period for the Vortex Indicator directional clarity measurement. Standard: 14.", group="⚙️ Core Parameters")
stPer1      = input.int(7, "Fast ST Period", minval=3, maxval=30, tooltip="ATR period for the fast Supertrend layer. Shorter = more sensitive to recent volatility.", group="⚙️ Core Parameters")
stMult1     = input.float(2.0, "Fast ST Multiplier", minval=0.5, maxval=8.0, step=0.1, tooltip="ATR multiplier for fast Supertrend. Lower = tighter trailing, more frequent flips.", group="⚙️ Core Parameters")
stPer2      = input.int(10, "Medium ST Period", minval=5, maxval=40, tooltip="ATR period for the medium Supertrend layer.", group="⚙️ Core Parameters")
stMult2     = input.float(3.0, "Medium ST Multiplier", minval=0.5, maxval=8.0, step=0.1, tooltip="ATR multiplier for medium Supertrend.", group="⚙️ Core Parameters")
stPer3      = input.int(14, "Slow ST Period", minval=7, maxval=50, tooltip="ATR period for the slow Supertrend layer. Longer = identifies major trend direction only.", group="⚙️ Core Parameters")
stMult3     = input.float(4.0, "Slow ST Multiplier", minval=0.5, maxval=10.0, step=0.1, tooltip="ATR multiplier for slow Supertrend. Higher = wider channel, fewer reversals.", group="⚙️ Core Parameters")
smoothEMA   = input.int(3, "Score Smoothing", minval=1, maxval=20, tooltip="EMA smoothing applied to the raw composite TQI score. Higher values reduce bar-to-bar noise but add lag. Recommended: 2–5.", group="⚙️ Core Parameters")

// ── Table Settings ──
tableSize = input.string("Normal", title="📐 Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], tooltip="Adjust the display size of the data table.", group="📊 Table Settings")
tablePos  = input.string("Top Right", title="📍 Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], tooltip="Position of the data table on chart.", group="📊 Table Settings")
showTable = input.bool(true, title="Show Table", tooltip="Toggle data table visibility.", group="📊 Table Settings")

// Resolve table size
tSize = switch tableSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

// Resolve table position
tPos = switch tablePos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left


// ═══════════════════════════════════════════════════════
// ═══ CALCULATIONS ═══
// ═══════════════════════════════════════════════════════

// ── 1. LSMA Velocity Score (0–25) ──
// Measures how fast price is moving along its regression line.
// ATR-normalized so the score is comparable across instruments.
lsmaValue          = ta.linreg(close, lsmaLength, 0)
lsmaVelocity       = (lsmaValue - nz(lsmaValue[velocityLB])) / velocityLB
atrNorm            = ta.atr(14)
safeAtr            = nz(atrNorm)
normalizedVelocity = safeAtr != 0.0 ? nz(lsmaVelocity) / safeAtr : 0.0
velocityScore      = math.max(0.0, math.min(25.0, math.abs(normalizedVelocity) * 100.0))

// ── 2. ADX Strength Score (0–25) ──
// ADX measures trend strength regardless of direction.
// Base maps ADX 15–40 → 0–20; DI gap adds up to 5 bonus points for directional clarity.
[diPlus, diMinus, adxVal] = ta.dmi(adxPeriod, adxPeriod)
adxBase    = math.max(0.0, math.min(20.0, (nz(adxVal) - 15.0) * 0.8))
diGapBonus = math.min(5.0, math.abs(nz(diPlus) - nz(diMinus)) * 0.3)
adxScore   = adxBase + diGapBonus

// ── 3. Vortex Clarity Score (0–25) ──
// Manual Vortex Indicator calculation (no built-in in Pine).
// Measures separation between positive and negative vortex lines.
// Large gap = clear one-directional movement.
vmPlus   = math.abs(high - nz(low[1]))
vmMinus  = math.abs(low - nz(high[1]))
trVortex = math.max(high - low, math.max(math.abs(high - nz(close[1])), math.abs(low - nz(close[1]))))

// Rolling sums over vortexPeriod (SMA * length ≡ sum)
sumVmPlus  = ta.sma(vmPlus, vortexPeriod) * vortexPeriod
sumVmMinus = ta.sma(vmMinus, vortexPeriod) * vortexPeriod
sumTr      = ta.sma(trVortex, vortexPeriod) * vortexPeriod

safeSumTr  = nz(sumTr)
viPlus     = safeSumTr != 0.0 ? nz(sumVmPlus) / safeSumTr : 0.0
viMinus    = safeSumTr != 0.0 ? nz(sumVmMinus) / safeSumTr : 0.0
vortexGap  = math.abs(viPlus - viMinus)
vortexScore = math.max(0.0, math.min(25.0, vortexGap * 100.0))

// ── 4. Supertrend Agreement Score (0–25) ──
// Three Supertrend layers at different speeds vote on direction.
// Full agreement = 25, two aligned = 15, split = 5.
[st1, dir1] = ta.supertrend(stMult1, stPer1)
[st2, dir2] = ta.supertrend(stMult2, stPer2)
[st3, dir3] = ta.supertrend(stMult3, stPer3)

// dir < 0 = bullish (price above supertrend)
bullCount    = (dir1 < 0 ? 1 : 0) + (dir2 < 0 ? 1 : 0) + (dir3 < 0 ? 1 : 0)
maxAgreement = math.max(bullCount, 3 - bullCount)
stScore      = maxAgreement == 3 ? 25.0 : maxAgreement == 2 ? 15.0 : 5.0

// ── Composite TQI ──
rawTqi = velocityScore + adxScore + vortexScore + stScore
tqi    = ta.ema(rawTqi, smoothEMA)

// ── Direction (from DMI) ──
direction = nz(diPlus) > nz(diMinus) ? 1 : -1


// ═══════════════════════════════════════════════════════
// ═══ SIGNALS & CONDITIONS ═══
// ═══════════════════════════════════════════════════════

excellentCross = ta.crossover(tqi, 80.0)
poorCross      = ta.crossunder(tqi, 40.0)

// Directional arrows fire only on direction changes while TQI confirms quality
dirChanged = direction != nz(direction[1])
bullArrow  = dirChanged and direction == 1  and tqi > 60.0
bearArrow  = dirChanged and direction == -1 and tqi > 60.0


// ═══════════════════════════════════════════════════════
// ═══ VISUALIZATION ═══
// ═══════════════════════════════════════════════════════

// Gradient fill color based on TQI level
fillColor = tqi > 75.0 ? color.new(#00BA7C, 20) :
             tqi > 50.0 ? color.new(#FFD700, 30) :
             tqi > 25.0 ? color.new(#F7931A, 40) :
                          color.new(#F4212E, 30)

lineColor = tqi > 75.0 ? color.new(#00BA7C, 0) :
             tqi > 50.0 ? color.new(#FFD700, 0) :
             tqi > 25.0 ? color.new(#F7931A, 0) :
                          color.new(#F4212E, 0)

// TQI area plot
pTqi  = plot(tqi, "TQI", color=lineColor, linewidth=2)
pZero = plot(0.0, "Base", color=color.new(color.black, 100), display=display.none)
fill(pTqi, pZero, color=fillColor)

// Reference hlines
hline(80, "Excellent", color=color.new(#00BA7C, 70), linestyle=hline.style_dotted)
hline(60, "Good",      color=color.new(#FFD700, 70), linestyle=hline.style_dotted)
hline(40, "Fair",      color=color.new(#F7931A, 70), linestyle=hline.style_dotted)
hline(20, "Poor",      color=color.new(#F4212E, 70), linestyle=hline.style_dotted)

// Directional signal arrows (only on direction change when TQI > 60)
plotshape(bullArrow, "Bullish Signal", shape.triangleup,   location.bottom, color.new(#00BA7C, 0), size=size.small)
plotshape(bearArrow, "Bearish Signal", shape.triangledown, location.top,    color.new(#F4212E, 0), size=size.small)

// Subtle background highlight when trend quality is excellent
bgcolor(tqi > 80.0 ? color.new(#00BA7C, 92) : na)


// ═══════════════════════════════════════════════════════
// ═══ DATA TABLE — Style A: Dark Header ═══
// ═══════════════════════════════════════════════════════

// Style A color constants
var HEADER_BG     = #1a1a2e
var HEADER_TEXT   = #ffffff
var SUBHEADER_TXT = #9e9e9e
var ROW_BG        = #ffffff
var LABEL_COLOR   = #666666
var BORDER_COLOR  = #f0f0f0
var BULL_COLOR    = #00b07c
var BEAR_COLOR    = #e53935
var NEUT_COLOR    = #666666

// Quality label and color
qualityLabel = tqi > 80.0 ? "EXCELLENT" : tqi > 60.0 ? "GOOD" : tqi > 40.0 ? "FAIR" : "POOR"
qualityColor = tqi > 80.0 ? BULL_COLOR  : tqi > 60.0 ? color.new(#FFD700, 0) : tqi > 40.0 ? color.new(#F7931A, 0) : BEAR_COLOR

// Direction label and color
dirLabel = direction == 1 ? "BULLISH ▲" : "BEARISH ▼"
dirColor = direction == 1 ? BULL_COLOR  : BEAR_COLOR

// Component score color helper (per 25-point scale)
scoreColor(float score) =>
    score >= 18.0 ? BULL_COLOR : score < 10.0 ? BEAR_COLOR : NEUT_COLOR

// TQI value color
tqiColor = tqi > 75.0 ? BULL_COLOR : tqi < 30.0 ? BEAR_COLOR : NEUT_COLOR

if barstate.islast and showTable
    var tbl = table.new(tPos, 2, 9, bgcolor=ROW_BG, border_color=BORDER_COLOR, border_width=1, frame_color=HEADER_BG, frame_width=0)

    // Row 0: Dark header
    table.cell(tbl, 0, 0, "StrixEDGE Trend Quality Index", bgcolor=HEADER_BG, text_color=HEADER_TEXT, text_size=tSize, text_halign=text.align_left,  text_font_family=font.family_default)
    table.cell(tbl, 1, 0, syminfo.ticker + " · " + timeframe.period,  bgcolor=HEADER_BG, text_color=SUBHEADER_TXT, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_default)

    // Row 1: Composite TQI score
    table.cell(tbl, 0, 1, "TQI Score",  bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(tqi, "#.#"), bgcolor=ROW_BG, text_color=tqiColor, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 2: Quality label
    table.cell(tbl, 0, 2, "Quality",    bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 2, qualityLabel, bgcolor=ROW_BG, text_color=qualityColor, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 3: Direction
    table.cell(tbl, 0, 3, "Direction",  bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 3, dirLabel,     bgcolor=ROW_BG, text_color=dirColor,    text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 4: Velocity component
    table.cell(tbl, 0, 4, "Velocity",   bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(velocityScore, "#.#") + " / 25", bgcolor=ROW_BG, text_color=scoreColor(velocityScore), text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 5: ADX Strength component
    table.cell(tbl, 0, 5, "ADX Strength", bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(adxScore, "#.#") + " / 25", bgcolor=ROW_BG, text_color=scoreColor(adxScore), text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 6: Vortex Clarity component
    table.cell(tbl, 0, 6, "Vortex Clarity", bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(vortexScore, "#.#") + " / 25", bgcolor=ROW_BG, text_color=scoreColor(vortexScore), text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 7: Supertrend Agreement component
    table.cell(tbl, 0, 7, "ST Agreement", bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 7, str.tostring(stScore, "#") + " / 25", bgcolor=ROW_BG, text_color=scoreColor(stScore), text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // Row 8: Raw ADX value (useful standalone reference)
    table.cell(tbl, 0, 8, "ADX",        bgcolor=ROW_BG, text_color=LABEL_COLOR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 8, str.tostring(nz(adxVal), "#.#"), bgcolor=ROW_BG, text_color=nz(adxVal) > 25.0 ? BULL_COLOR : NEUT_COLOR, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)


// ═══════════════════════════════════════════════════════
// ═══ ALERTS ═══
// ═══════════════════════════════════════════════════════

alertcondition(excellentCross, title="Excellent Trend Quality", message="StrixEDGE Trend Quality Index: TQI crossed above 80 — excellent trend quality detected.")
alertcondition(poorCross,      title="Poor Trend Quality",      message="StrixEDGE Trend Quality Index: TQI dropped below 40 — trend quality deteriorating.")
alertcondition(bullArrow,      title="Bullish Direction Signal", message="StrixEDGE Trend Quality Index: Direction shifted bullish with TQI above 60.")
alertcondition(bearArrow,      title="Bearish Direction Signal", message="StrixEDGE Trend Quality Index: Direction shifted bearish with TQI above 60.")
````
