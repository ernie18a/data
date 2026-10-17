# Trend Strength Meter [AGPro Series]

- url: https://www.tradingview.com/script/NaPOtfLf-Trend-Strength-Meter-AGPro-Series/
- type: indicator
- pine_id: PUB;0e84ce47cf63445d84534a9c3826e84b
- version: 4.0

## Description

Trend Strength Meter [AGPro Series]

⚡ OVERVIEW

Trend Strength Meter is a multi-factor composite oscillator that quantifies how strong a directional trend actually is, on a single 0-to-100 score. It merges five independent trend dimensions (ADX, slope angle, momentum ROC, moving-average alignment, and pullback depth) into one weighted reading, then classifies the market into three clear states: Strong Trend (80+), Mild Trend (50-80), and Weak / Range (<50). The goal is to give a trader the answer to one of the most common daily questions in technical analysis: "Is the trend strong enough to act on right now, or is it fading?"

The indicator is built for discretionary and systematic traders who want a single, normalized number instead of reading half a dozen separate trend tools. It is scale-invariant (ATR-normalized) and works across timeframes and instruments.


🎯 UNIQUE EDGE

Trend-strength tools usually give a single-factor reading (for example, ADX alone) which can be misleading. ADX can be high during range contractions, slopes can spike during noise, MA stacks can be aligned while price sits deep in pullback. This indicator fuses all five dimensions so that no single factor can dominate the score without confirmation from the others.

Three design choices set it apart:

1. Weighted multi-factor composite. Every factor is independently normalized to 0-100, then combined with user-adjustable weights that auto-normalize. A Strong reading therefore requires broad agreement across independent trend dimensions, not just one signal firing.

2. Dominant Factor readout. The information panel shows which of the five factors is contributing most to the current score, so the trader understands why the score is where it is. A score of 84 driven by ADX and a score of 84 driven by Alignment are structurally different markets, and the readout makes that visible.

3. Historical context built in. The panel exposes Historical Max Score over a configurable lookback window, and Strong-Trend Duration (how many bars the score has held above the Strong threshold). Both of these help gauge trend maturity and exhaustion risk.


📊 METHODOLOGY

The composite score is built from five independently scored factors, each normalized to 0-100:

• Factor 1 — ADX. Directional movement strength from the standard DMI/ADX system, linearly mapped so that ADX = 60 maps to a score of 100.

• Factor 2 — Slope Angle. The slope of an EMA over its length window, normalized by ATR to be scale-invariant, then converted to a 0-100 score via an arctangent curve. High slope in either direction yields a high score.

• Factor 3 — Momentum ROC. Rate of Change normalized by ATR and converted to a bounded 0-100 value. Captures impulse magnitude independent of price scale.

• Factor 4 — MA Alignment. Stacked EMA alignment across Fast / Mid / Slow timeframes, plus price position relative to the fast MA. Full bullish or bearish stack yields 100; partial stacks are scored proportionally (70, 40, or 15).

• Factor 5 — Pullback Depth. Distance from the nearest recent extreme (highest high or lowest low over lookback) measured in ATR units. Shallow pullback = strong trend = high score.

Each factor is multiplied by its weight, summed, and divided by total weight to produce the final 0-100 score. All five weights are independently adjustable and auto-normalize, so changing one weight does not force manual rebalancing of the others.

Directional bias (Bull / Bear / Range) is determined by the combination of DMI crossover state and close-vs-mid-MA position. State color shifts between strong bull green, strong bear magenta, neutral yellow, and weak gray based on score plus direction.


🔥 VISUAL SYSTEM

Six coordinated visual elements deliver the information without clutter:

• Score histogram on the sub-panel, colored per bar by that bar's own score level (green for Strong, yellow for Mild, gray for Weak / Range). Each historical bar shows its true state at the time, not the current state.

• Horizontal reference lines at the Strong (green) and Mild (yellow) thresholds on the sub-panel.

• Historical Max step line in indigo accent, showing the highest score reached within the lookback window, so past trend peaks are immediately visible.

• Mini Gauge on the right edge of the sub-panel. A compact vertical meter split into two halves: left half shows the fixed 0-100 zone reference (Weak / Mild / Strong), right half fills up to the current score, with a bold needle line marking the exact level.

• Price badge floating above the last candle, showing "TSM [score] [state]" so the reading is visible without needing to look at the panel.

• Information panel on the price chart with seven rows: Score, State, Direction, Dominant Factor, Historical Max, and Strong Bars duration.


🧭 SIGNALS AND ALERTS

Three built-in alerts:

• Strong Bull Entry — Score crosses above the Strong threshold while directional bias is Bull.
• Strong Bear Entry — Score crosses above the Strong threshold while directional bias is Bear.
• Trend Fade — Score drops below the Mild threshold, indicating the trend is weakening.

All alerts fire once per bar close, so there is no intra-bar repainting.


🧮 KEY INPUTS

Core Settings
• ADX Length, Slope MA Length, Momentum ROC Length, MA Alignment Fast / Mid / Slow, Pullback ATR Length
• Score Smoothing (EMA applied to score for optional overlay line)
• Strong Threshold (default 80), Mild Threshold (default 50), Historical Lookback (default 100 bars)

Factor Weights (auto-normalized)
• ADX 30, Slope 20, Momentum 20, Alignment 20, Pullback 10

Visual
• Badge toggle, Background tint toggle, Reference lines toggle, Mini Gauge toggle, Historical Max line toggle, Smoothed Score line toggle, Label size, Badge ATR offset

Panel
• Show / hide, Position (6 anchors), Theme (Dark / Light), Font size


📈 HOW TO USE

1. Add the indicator to any chart and any timeframe. Defaults are calibrated for 4H / Daily; for lower timeframes consider reducing the ADX and ROC lengths.

2. Use the 0-100 score as a regime filter. Many trend-following setups perform better when the score is above 50, and breakout / continuation setups perform best when the score is crossing above 80 with a clear Bull or Bear direction.

3. Watch the Dominant Factor. A score of 85 driven primarily by Momentum may fade fast; the same score driven by Alignment tends to be more structural.

4. Use Historical Max and Strong Bars to gauge maturity. A Strong-Bars reading of 30+ on a daily chart often signals late-cycle conditions where continuation risk increases and fresh entries need tighter risk management.

5. Combine with structure tools (support / resistance, order blocks, market-structure tools) for entries. This indicator is designed to answer "how strong is the trend," not "where do I enter."


⚠️ LIMITATIONS AND TRANSPARENCY

• This is an indicator, not a trading strategy. It does not produce buy / sell recommendations and it does not backtest trade outcomes.
• The score is a lagging composite built from historical price data. It does not predict future price movement.
• During sharp regime transitions (news events, gap opens), the score can change rapidly from one bar to the next. This is by design, not a bug.
• Factor weights are user-adjustable. Defaults are a reasonable starting point but may need tuning per instrument / timeframe.
• The Pullback factor assumes trending behavior. In tight consolidations it can read misleadingly high, which is why the Dominant Factor readout exists as a cross-check.
• No-repaint: all calculations are based on confirmed (closed) bar data; alerts fire on bar close only.


📌 RISK DISCLOSURE

Trading carries substantial risk. This indicator is an analytical tool for research and study purposes and does not constitute financial advice, a trading signal, or a recommendation to buy or sell any instrument. Past behavior of any indicator is not indicative of future results. Users are solely responsible for their trading decisions and should conduct their own due diligence and risk management.

## Source Code

````pine
// -------------------------------------------------
// Trend Strength Meter [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// Trend Strength Meter is a multi-factor trend strength dashboard that
// quantifies directional conviction on a single 0-100 score. It combines ADX,
// slope pressure, momentum ROC, moving-average alignment, and pullback depth
// into one weighted composite so the chart can answer whether trend pressure is
// strong, mild, or weak right now without becoming a generic oscillator. Version
// 1.8 clarifies the right-edge factor ladder, regime actions, and confirmed alerts.
// -------------------------------------------------

//@version=6
indicator("Trend Strength Meter [AGPro Series]",
     shorttitle = "AG Pro TSM",
     overlay = false,
     max_labels_count = 140,
     max_lines_count = 60,
     max_boxes_count = 120,
     max_bars_back = 500)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color weakColor     = color.rgb(100, 116, 139)
color gaugeBlue     = color.rgb(59, 130, 246)
color darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
string ttAdx = "Length for ADX / DMI computation. Lower values react faster, while higher values create a smoother strength baseline."
string ttSlope = "Length of the moving average whose ATR-normalized slope measures directional pressure."
string ttRoc = "Rate-of-change lookback used to measure momentum strength."
string ttFast = "Fast moving average used in the alignment stack."
string ttMid = "Mid moving average used in the alignment stack and directional bias filter."
string ttSlow = "Slow moving average used in the broader alignment stack."
string ttPull = "ATR length used to normalize pullback depth from recent high or low."
string ttSmooth = "EMA length applied to the final score line. Raw score remains visible through the histogram."
string ttWeight = "Relative factor weight. All weights are auto-normalized, so they do not need to sum to 100."
string ttStrong = "Score at or above this value is classified as strong trend pressure."
string ttMild = "Score at or above this value, but below Strong, is classified as mild trend pressure."
string ttHist = "Bars used to compute the historical max score reference."
string ttProofWindow = "Number of bars a fresh strong-trend reading has to follow through within, for the Follow Rate proof. It only measures historical follow-through and is not a forecast."
string ttBadge = "Shows a compact trend badge pinned above the latest price using force overlay."
string ttTint = "Paints a faint background color in the sub-panel when the score is in a strong trend regime."
string ttBand = "Draws horizontal Strong and Mild reference lines in the sub-panel."
string ttGauge = "Shows a compact right-edge score gauge with a current-score fill and needle."
string ttMax = "Draws a historical max reference line within the selected lookback window."
string ttSmoothLine = "Overlays the smoothed score line on top of the raw score histogram."
string ttFactors = "Shows compact right-side factor tags for the current dominant components."
string ttFactorStrip = "Shows a fixed-slot right-edge factor ladder for ADX, slope, momentum, alignment, and pullback. Each filled badge follows the shared Label Font Size setting."
string ttLabel = "Font size for chart labels, score badge, and factor tags."
string ttOffset = "Vertical price-badge offset in ATR units so the badge avoids candles."
string ttPanelShow = "Shows or hides the AG Pro information panel."
string ttPanelPos = "Moves the AG Pro panel to the preferred chart location."
string ttPanelTheme = "Switches the panel between AGPro dark, slate, and clean light themes."
string ttPanelFont = "Controls panel text size. Normal is the default publication setting."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string grpCore = "Core Settings"
string grpFac = "Factor Weights"
string grpVis = "Visual Design"
string grpPanel = "Panel"
string grpAlert = "Alerts"

adxLen = input.int(14, "ADX Length", minval = 2, group = grpCore, tooltip = ttAdx)
slopeLen = input.int(20, "Slope MA Length", minval = 5, group = grpCore, tooltip = ttSlope)
rocLen = input.int(14, "Momentum ROC Length", minval = 2, group = grpCore, tooltip = ttRoc)
alignFast = input.int(20, "MA Alignment Fast", minval = 2, group = grpCore, tooltip = ttFast)
alignMid = input.int(50, "MA Alignment Mid", minval = 5, group = grpCore, tooltip = ttMid)
alignSlow = input.int(200, "MA Alignment Slow", minval = 10, group = grpCore, tooltip = ttSlow)
pullLen = input.int(20, "Pullback ATR Length", minval = 5, group = grpCore, tooltip = ttPull)
smoothLen = input.int(4, "Score Smoothing", minval = 1, maxval = 20, group = grpCore, tooltip = ttSmooth)
thStrong = input.int(80, "Strong Threshold", minval = 60, maxval = 95, group = grpCore, tooltip = ttStrong)
thMild = input.int(50, "Mild Threshold", minval = 30, maxval = 70, group = grpCore, tooltip = ttMild)
histPer = input.int(100, "Historical Lookback", minval = 20, group = grpCore, tooltip = ttHist)
trendProofWindow = input.int(20, "Trend Proof Window (bars)", minval = 4, maxval = 200, group = grpCore, tooltip = ttProofWindow)

wAdx = input.float(30.0, "ADX Weight", minval = 0, maxval = 100, step = 5, group = grpFac, tooltip = ttWeight)
wSlope = input.float(20.0, "Slope Angle Weight", minval = 0, maxval = 100, step = 5, group = grpFac, tooltip = ttWeight)
wRoc = input.float(20.0, "Momentum Weight", minval = 0, maxval = 100, step = 5, group = grpFac, tooltip = ttWeight)
wAlign = input.float(20.0, "MA Alignment Weight", minval = 0, maxval = 100, step = 5, group = grpFac, tooltip = ttWeight)
wPull = input.float(10.0, "Pullback Weight", minval = 0, maxval = 100, step = 5, group = grpFac, tooltip = ttWeight)

showBadge = input.bool(true, "Show Trend Badge on Price", group = grpVis, tooltip = ttBadge)
showTint = input.bool(true, "Background Tint on Strong Trend", group = grpVis, tooltip = ttTint)
showBand = input.bool(true, "Strong / Mild Reference Lines", group = grpVis, tooltip = ttBand)
showGauge = input.bool(true, "Show Right-Edge Gauge", group = grpVis, tooltip = ttGauge)
showMaxLine = input.bool(true, "Show Historical Max Line", group = grpVis, tooltip = ttMax)
showSmooth = input.bool(true, "Show Smoothed Score Line", group = grpVis, tooltip = ttSmoothLine)
showFactorTags = input.bool(false, "Show Dominant Factor Tag", group = grpVis, tooltip = ttFactors)
showFactorStrip = input.bool(true, "Show Factor Contribution Strip", group = grpVis, tooltip = ttFactorStrip)
labelSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpVis, tooltip = ttLabel)
offsetATR = input.float(1.65, "Badge Offset ATR", minval = 0.0, step = 0.1, group = grpVis, tooltip = ttOffset)

showPanel = input.bool(true, "Show Info Panel", group = grpPanel, tooltip = ttPanelShow)
panelPos = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpPanel, tooltip = ttPanelPos)
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPanel, tooltip = ttPanelTheme)
panelFont = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPanel, tooltip = ttPanelFont)

alertStrongUp = input.bool(true, "Alert on Strong Bull Entry", group = grpAlert, tooltip = "Triggers on a confirmed bar when score crosses above Strong threshold while directional bias is bullish.")
alertStrongDn = input.bool(true, "Alert on Strong Bear Entry", group = grpAlert, tooltip = "Triggers on a confirmed bar when score crosses above Strong threshold while directional bias is bearish.")
alertTrendFade = input.bool(true, "Alert on Trend Fade", group = grpAlert, tooltip = "Triggers on a confirmed bar when score crosses below the Mild threshold.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string value) =>
    value == "Tiny" ? size.tiny : value == "Small" ? size.small : value == "Large" ? size.large : value == "Huge" ? size.huge : size.normal

f_pos(string value) =>
    value == "Top Left" ? position.top_left :
     value == "Top Center" ? position.top_center :
     value == "Top Right" ? position.top_right :
     value == "Middle Left" ? position.middle_left :
     value == "Middle Center" ? position.middle_center :
     value == "Middle Right" ? position.middle_right :
     value == "Bottom Left" ? position.bottom_left :
     value == "Bottom Center" ? position.bottom_center : position.bottom_right

f_text_on(color bgColor) =>
    float yiq = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_bg(string theme) =>
    theme == "Clean Light" ? color.rgb(241, 245, 249) : theme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : theme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    bool evenRow = row % 2 == 0
    theme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : theme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_state_color(float currentScore, bool bull, bool bear) =>
    currentScore >= thStrong ? bull ? bullColor : bear ? bearColor : neutralColor : currentScore >= thMild ? neutralColor : weakColor

f_grade(float currentScore) =>
    currentScore >= 88 ? "A+" : currentScore >= 80 ? "A" : currentScore >= 65 ? "B" : currentScore >= 50 ? "C" : "D"

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    color rowBg = f_row_bg(theme, row)
    table.cell(panelRef, 0, row, leftText, bgcolor = rowBg, text_color = f_label(theme), text_size = f_size(fontSize), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, bgcolor = rowBg, text_color = rightColor, text_size = f_size(fontSize), text_halign = text.align_right)

f_set_factor_box(box boxRef, int leftX, int rightX, float topY, float bottomY, color boxColor) =>
    box.set_lefttop(boxRef, leftX, topY)
    box.set_rightbottom(boxRef, rightX, bottomY)
    box.set_bgcolor(boxRef, color.new(boxColor, 16))
    box.set_border_color(boxRef, color.new(boxColor, 0))
    box.set_border_width(boxRef, 1)

// -------------------------------------------------
// Factor Calculations
// -------------------------------------------------
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxScore = f_clamp(adx * 100.0 / 60.0, 0.0, 100.0)

slopeMa = ta.ema(close, slopeLen)
atrRef = ta.atr(slopeLen)
slopeNorm = atrRef > 0 ? (slopeMa - slopeMa[slopeLen]) / (atrRef * slopeLen) : 0.0
slopeScore = f_clamp(math.atan(math.abs(slopeNorm) * 5.0) / (math.pi / 2.0) * 100.0, 0.0, 100.0)

rocRaw = ta.roc(close, rocLen)
rocNorm = atrRef > 0 ? math.abs(rocRaw) * close / (atrRef * 100.0) : 0.0
rocScore = f_clamp(rocNorm * 20.0, 0.0, 100.0)

maFast = ta.ema(close, alignFast)
maMid = ta.ema(close, alignMid)
maSlow = ta.ema(close, alignSlow)
bullStack = maFast > maMid and maMid > maSlow and close > maFast
bearStack = maFast < maMid and maMid < maSlow and close < maFast

alignScore = 0.0
if bullStack or bearStack
    alignScore := 100.0
else if (maFast > maMid and maMid > maSlow) or (maFast < maMid and maMid < maSlow)
    alignScore := 70.0
else if (maFast > maMid) or (maFast < maMid)
    alignScore := 40.0
else
    alignScore := 15.0

pullAtr = ta.atr(pullLen)
recentHigh = ta.highest(high, pullLen)
recentLow = ta.lowest(low, pullLen)
pullDepthUp = pullAtr > 0 ? (recentHigh - close) / pullAtr : 0.0
pullDepthDown = pullAtr > 0 ? (close - recentLow) / pullAtr : 0.0
pullScore = f_clamp(100.0 - math.min(pullDepthUp, pullDepthDown) * 25.0, 0.0, 100.0)

wSum = wAdx + wSlope + wRoc + wAlign + wPull
wSumSafe = wSum > 0 ? wSum : 1.0
rawScore = (adxScore * wAdx + slopeScore * wSlope + rocScore * wRoc + alignScore * wAlign + pullScore * wPull) / wSumSafe
score = math.round(rawScore * 10.0) / 10.0
scoreSmoothRaw = ta.ema(score, math.max(smoothLen, 1))
scoreSmooth = smoothLen > 1 ? scoreSmoothRaw : score
histMax = ta.highest(score, histPer)

isBull = diPlus > diMinus and close > maMid
isBear = diMinus > diPlus and close < maMid
direction = isBull ? "Bull" : isBear ? "Bear" : "Range"
stateStrong = score >= thStrong
stateMild = score >= thMild and score < thStrong

stateText = "Weak / Range"
if stateStrong
    stateText := isBull ? "Strong Bull" : isBear ? "Strong Bear" : "Strong"
else if stateMild
    stateText := isBull ? "Mild Bull" : isBear ? "Mild Bear" : "Mild"

string actionText = "Wait for alignment"
if stateStrong
    actionText := isBull ? "Track strong bull" : isBear ? "Track strong bear" : "Review mixed strength"
else if stateMild
    actionText := isBull ? "Watch bull build" : isBear ? "Watch bear build" : "Wait for direction"

histColor = f_state_color(score, isBull, isBear)
badgeColor = histColor
dirCol = direction == "Bull" ? bullColor : direction == "Bear" ? bearColor : weakColor

contribAdx = adxScore * wAdx / wSumSafe
contribSlope = slopeScore * wSlope / wSumSafe
contribRoc = rocScore * wRoc / wSumSafe
contribAlign = alignScore * wAlign / wSumSafe
contribPull = pullScore * wPull / wSumSafe
maxContrib = math.max(contribAdx, math.max(contribSlope, math.max(contribRoc, math.max(contribAlign, contribPull))))

dominant = "Pullback"
domScore = pullScore
if maxContrib == contribAdx
    dominant := "ADX"
    domScore := adxScore
else if maxContrib == contribSlope
    dominant := "Slope"
    domScore := slopeScore
else if maxContrib == contribRoc
    dominant := "Momentum"
    domScore := rocScore
else if maxContrib == contribAlign
    dominant := "Alignment"
    domScore := alignScore

var int strongDur = 0
strongDur := stateStrong ? nz(strongDur[1]) + 1 : 0

// -------------------------------------------------
// Strong-trend follow-rate proof (Confirm Rate)
// -------------------------------------------------
// When the score first crosses into the strong zone with a directional bias,
// does price follow through 0.75 ATR in that direction before the strength
// fades below the mild threshold or the window expires? Counted once per fresh
// strong reading. A fade before follow-through, or a window expiry, is treated
// as not-followed (conservative).
float tsMargin = math.max(nz(pullAtr), syminfo.mintick) * 0.75
var int   tsTotal = 0
var int   tsWon    = 0
var bool  tsPend    = false
var int   tsDir      = 0
var float tsAnchor    = na
var int   tsLeft       = 0
bool tsFire = score >= thStrong and (bar_index > 0 ? score[1] < thStrong : false) and (isBull or isBear)

if barstate.isconfirmed
    if tsPend and not na(tsAnchor)
        bool tsFollowed = tsDir > 0 ? close >= tsAnchor + tsMargin : close <= tsAnchor - tsMargin
        bool tsFaded = score < thMild
        if tsFollowed
            tsTotal += 1
            tsWon += 1
            tsPend := false
        else if tsFaded
            tsTotal += 1
            tsPend := false
        else
            tsLeft -= 1
            if tsLeft <= 0
                tsTotal += 1
                tsPend := false
    if tsFire and not tsPend
        tsDir := isBull ? 1 : -1
        tsAnchor := close
        tsLeft := trendProofWindow
        tsPend := true

float tsRate = tsTotal > 0 ? tsWon / tsTotal * 100.0 : na
string followRateRead = tsTotal > 0 ? str.tostring(math.round(tsRate)) + "% (" + str.tostring(tsTotal) + ")" : "Building"
color followRateCol = na(tsRate) ? f_value(panelTheme) : tsRate >= 60.0 ? bullColor : tsRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Sub-Panel Visuals
// -------------------------------------------------
plot(score, "Score", color = histColor, style = plot.style_columns, linewidth = 2)
plot(showSmooth ? scoreSmooth : na, "Score Line", color = color.new(headerText, 18), linewidth = 2, style = plot.style_line)
plot(showMaxLine ? histMax : na, "Historical Max", color = color.new(accentColor, 20), linewidth = 2, style = plot.style_stepline)

hline(showBand ? thStrong : na, "Strong Threshold", color = color.new(bullColor, 40), linestyle = hline.style_dashed)
hline(showBand ? thMild : na, "Mild Threshold", color = color.new(neutralColor, 40), linestyle = hline.style_dashed)
hline(0, "Zero", color = color.new(panelBorder, 50), linestyle = hline.style_dotted)
hline(100, "Top", color = color.new(panelBorder, 70), linestyle = hline.style_dotted)
bgcolor(showTint and stateStrong ? color.new(histColor, 92) : na, title = "Strong Trend Tint")

// -------------------------------------------------
// Right-Edge Gauge and Factor Tags
// -------------------------------------------------
var box gaugeBack = na
var box gaugeFill = na
var line gaugeNeedle = na
var label gaugeTag = na
var label factorTag = na
var box factorAdxBox = na
var box factorSlopeBox = na
var box factorMomBox = na
var box factorAlignBox = na
var box factorPullBox = na
var label factorStripTitle = na
var label factorAdxTag = na
var label factorSlopeTag = na
var label factorMomTag = na
var label factorAlignTag = na
var label factorPullTag = na

if barstate.islast
    box.delete(gaugeBack)
    box.delete(gaugeFill)
    line.delete(gaugeNeedle)
    label.delete(gaugeTag)
    label.delete(factorTag)
    box.delete(factorAdxBox)
    box.delete(factorSlopeBox)
    box.delete(factorMomBox)
    box.delete(factorAlignBox)
    box.delete(factorPullBox)
    label.delete(factorStripTitle)
    label.delete(factorAdxTag)
    label.delete(factorSlopeTag)
    label.delete(factorMomTag)
    label.delete(factorAlignTag)
    label.delete(factorPullTag)

    if showGauge
        int gX1 = bar_index + 5
        int gX2 = bar_index + 8
        float fillTop = math.max(score, 0.5)
        gaugeBack := box.new(gX1, 100, gX2, 0, bgcolor = color.new(panelBorder, 86), border_color = color.new(panelBorder, 45), border_width = 1)
        gaugeFill := box.new(gX1, fillTop, gX2, 0, bgcolor = color.new(histColor, 14), border_color = color.new(histColor, 0), border_width = 1)
        gaugeNeedle := line.new(gX1 - 1, score, gX2 + 1, score, color = histColor, width = 3)
        gaugeTag := label.new(gX2 + 2, score, "TSM " + str.tostring(score, "#") + " " + f_grade(score), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(gaugeBlue, 0), textcolor = f_text_on(gaugeBlue), size = f_size(labelSize))

    if showFactorTags
        string factorText = "DOM " + dominant + "\n" + str.tostring(math.round(domScore)) + " / 100"
        factorTag := label.new(bar_index + 16, math.max(scoreSmooth, thMild), factorText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_size(labelSize), textalign = text.align_center)

    if showFactorStrip
        int stripX = bar_index + 20
        int stripMax = 12
        float rowHeight = 5.0
        float rowGap = 13.0
        float startTop = 94.0
        float maxFactor = math.max(math.max(adxScore, slopeScore), math.max(math.max(rocScore, alignScore), pullScore))
        float safeMaxFactor = math.max(maxFactor, 1.0)
        int adxRight = stripX + math.max(1, int(math.round(adxScore / safeMaxFactor * stripMax)))
        int slopeRight = stripX + math.max(1, int(math.round(slopeScore / safeMaxFactor * stripMax)))
        int momRight = stripX + math.max(1, int(math.round(rocScore / safeMaxFactor * stripMax)))
        int alignRight = stripX + math.max(1, int(math.round(alignScore / safeMaxFactor * stripMax)))
        int pullRight = stripX + math.max(1, int(math.round(pullScore / safeMaxFactor * stripMax)))
        factorStripTitle := label.new(stripX, startTop + 5.0, "FACTOR LADDER", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(panelBorder, 0), textcolor = f_text_on(panelBorder), size = f_size(labelSize))
        factorAdxBox := box.new(stripX, startTop, adxRight, startTop - rowHeight, xloc = xloc.bar_index, bgcolor = color.new(gaugeBlue, 16), border_color = color.new(gaugeBlue, 0), border_width = 1)
        factorSlopeBox := box.new(stripX, startTop - rowGap, slopeRight, startTop - rowGap - rowHeight, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 16), border_color = color.new(accentColor, 0), border_width = 1)
        factorMomBox := box.new(stripX, startTop - rowGap * 2.0, momRight, startTop - rowGap * 2.0 - rowHeight, xloc = xloc.bar_index, bgcolor = color.new(neutralColor, 16), border_color = color.new(neutralColor, 0), border_width = 1)
        factorAlignBox := box.new(stripX, startTop - rowGap * 3.0, alignRight, startTop - rowGap * 3.0 - rowHeight, xloc = xloc.bar_index, bgcolor = color.new(bullColor, 16), border_color = color.new(bullColor, 0), border_width = 1)
        factorPullBox := box.new(stripX, startTop - rowGap * 4.0, pullRight, startTop - rowGap * 4.0 - rowHeight, xloc = xloc.bar_index, bgcolor = color.new(weakColor, 16), border_color = color.new(weakColor, 0), border_width = 1)
        factorAdxTag := label.new(stripX + stripMax + 3, startTop - rowHeight * 0.5, "ADX " + str.tostring(math.round(adxScore)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(gaugeBlue, 0), textcolor = f_text_on(gaugeBlue), size = f_size(labelSize))
        factorSlopeTag := label.new(stripX + stripMax + 3, startTop - rowGap - rowHeight * 0.5, "SLP " + str.tostring(math.round(slopeScore)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_size(labelSize))
        factorMomTag := label.new(stripX + stripMax + 3, startTop - rowGap * 2.0 - rowHeight * 0.5, "MOM " + str.tostring(math.round(rocScore)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_size(labelSize))
        factorAlignTag := label.new(stripX + stripMax + 3, startTop - rowGap * 3.0 - rowHeight * 0.5, "ALN " + str.tostring(math.round(alignScore)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullColor, 0), textcolor = f_text_on(bullColor), size = f_size(labelSize))
        factorPullTag := label.new(stripX + stripMax + 3, startTop - rowGap * 4.0 - rowHeight * 0.5, "PUL " + str.tostring(math.round(pullScore)), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(weakColor, 0), textcolor = f_text_on(weakColor), size = f_size(labelSize))

// -------------------------------------------------
// Price Badge
// -------------------------------------------------
var label badgeLbl = na
if barstate.islast
    label.delete(badgeLbl)
    if showBadge
        badgeText = str.tostring(score, "#") + "  " + stateText
        badgeY = high + pullAtr * offsetATR
        badgeLbl := label.new(bar_index, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(badgeColor, 0), textcolor = f_text_on(badgeColor), size = f_size(labelSize), textalign = text.align_center, force_overlay = true)

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = table.new(f_pos(panelPos), 2, 9, bgcolor = f_bg(panelTheme), border_color = f_border(panelTheme), border_width = 1, frame_color = f_border(panelTheme), frame_width = 1, force_overlay = true)

if barstate.islast
    table.set_position(infoPanel, f_pos(panelPos))
    table.clear(infoPanel, 0, 0, 1, 8)
    if showPanel
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Trend Strength Meter", bgcolor = headerBg, text_color = headerText, text_size = f_size(panelFont), text_halign = text.align_center)
        f_panel_row(infoPanel, 1, "Score", str.tostring(score, "#.#") + " / 100 " + f_grade(score), badgeColor, panelTheme, panelFont)
        f_panel_row(infoPanel, 2, "Follow Rate", followRateRead, followRateCol, panelTheme, panelFont)
        f_panel_row(infoPanel, 3, "State", stateText, badgeColor, panelTheme, panelFont)
        f_panel_row(infoPanel, 4, "Direction", direction, dirCol, panelTheme, panelFont)
        f_panel_row(infoPanel, 5, "Dominant", dominant + " " + str.tostring(math.round(domScore)), accentColor, panelTheme, panelFont)
        f_panel_row(infoPanel, 6, "Hist. Max", str.tostring(histMax, "#.#"), f_value(panelTheme), panelTheme, panelFont)
        f_panel_row(infoPanel, 7, "Strong Run", str.tostring(strongDur) + " bars", f_value(panelTheme), panelTheme, panelFont)
        f_panel_row(infoPanel, 8, "Action", actionText, badgeColor, panelTheme, panelFont)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
strongCross = ta.crossover(score, float(thStrong))
strongFade = ta.crossunder(score, float(thMild))

alertcondition(barstate.isconfirmed and alertStrongUp and strongCross and isBull, "Strong Bull Trend", "Trend Strength Meter: confirmed strong bullish trend pressure detected.")
alertcondition(barstate.isconfirmed and alertStrongDn and strongCross and isBear, "Strong Bear Trend", "Trend Strength Meter: confirmed strong bearish trend pressure detected.")
alertcondition(barstate.isconfirmed and alertTrendFade and strongFade, "Trend Strength Fade", "Trend Strength Meter: confirmed trend-strength fade below the Mild threshold.")

plot(tsRate, title = "Strong-Trend Follow Rate", color = bullColor, display = display.data_window)
````
