# Buy/Sell Pressure Meter [AGPro Series]

- url: https://www.tradingview.com/script/ykdiIuhe-Buy-Sell-Pressure-Meter-AGPro-Series/
- type: indicator
- pine_id: PUB;bd1618a9dadb4cbd8e154fddd2f7e451
- version: 4.0

## Description

Buy/Sell Pressure Meter [AGPro Series]

🔹 Overview

Buy/Sell Pressure Meter is a volume-flow analytics tool that quantifies the tug-of-war between buyers and sellers on every bar and on a rolling basis. Unlike traditional volume delta indicators that only plot raw bar-level buy minus sell, this tool layers four complementary lenses into a single oscillator: rolling pressure trend, imbalance streak tracking, intraday pressure shift count, and session-accumulated dominance. A subtle price-pane background tint gives a Bookmap-light read on intraday participation that works across crypto, futures, and liquid equities — without requiring tick-level order flow data.

🔹 Unique Edge

Most volume-delta scripts answer the question "which side was bigger on this bar?" This one answers a different, more useful question for intraday traders: "who has been in control, and how stable is that control?"

• Rolling Pressure Trend — a moving average of buy and sell pressure separately (dual histogram), so you see structural bias, not just bar-to-bar noise.
• Imbalance Streak Tracking — counts consecutive same-side dominant bars and labels only the final length of each significant streak at the moment the streak breaks. No per-bar label spam, one clean marker per event.
• Intraday Pressure Shift Count — how many times the rolling dominant side has flipped since session open. High shift count = rotational day. Low shift count = trending day.
• Session-Accumulated Net Delta — cumulative bull vs bear contribution since the day began, independent of the rolling window.
• Price-Pane Bookmap-Light Tint — a very high-transparency background tint paints the main chart pane when one side is rolling-dominant, so you see control visually without leaving the price chart.

These five lenses together are deliberately designed not to overlap with raw volume-delta or cumulative-volume-delta indicators. They describe the character of participation, not just its magnitude.

🔹 Methodology

Because standard chart data does not include true tick-level order flow, this script uses a widely-accepted proxy: up-bar volume is attributed to buy pressure, down-bar volume to sell pressure, and doji volume is split evenly. This is explicitly a simulated bias — not real bid/ask flow — and the script labels it as such in the panel.

From that proxy:

1. Current-bar bull pressure percentage = buyPressure / (buyPressure + sellPressure) × 100.
2. Rolling pressure = SMA of buy and sell pressure over the user-defined window (default 20 bars).
3. A bar is classified bull-dominant when its bull pressure percent exceeds the dominance threshold (default 55%), and bear-dominant at the mirror level.
4. Streaks count consecutive bars of the same classification and reset when a neutral or opposite bar prints. Peak length is captured at the moment of reset and optionally labelled on chart.
5. Pressure shifts compare the current rolling dominant side against the last confirmed non-neutral dominant side; a change increments the intraday shift counter (only on intraday timeframes).
6. Session delta is the cumulative net delta since the last daily rollover.

🔹 Signals & States

• Dual histogram — buy pressure (teal, upward) and sell pressure (pink, downward) plotted as rolling averages.
• Net delta center line — accent-colored line showing rolling buy minus sell.
• Price-pane background tint — subtle teal or pink when one side is rolling-dominant, gives a Bookmap-light feel without obscuring candles.
• Oscillator-pane echo tint — even more subtle tint mirroring the dominant side in the indicator pane.
• Shift markers — triangles on the pane when the dominant side flips.
• Streak peak labels — plotted only at streak termination, showing final length (e.g. "Bull 7").
• Alerts — pressure shift to bull, pressure shift to bear, bull imbalance streak, bear imbalance streak.

🔹 Key Inputs

Calculation:
• Rolling Pressure Length — default 20. Higher = smoother, slower reaction.
• Minimum Streak To Highlight — default 3. Used for alerts.
• Dominance Threshold — default 55%. Share of total pressure needed to classify a bar as dominant.

Visuals:
• Tint Price Pane On Dominance — toggles the Bookmap-light effect on the main chart.
• Show Streak Peak Labels + Minimum Streak Length To Label (default 5) — controls chart cleanliness.
• Show Pressure Shift Events — triangle markers on shifts.
• Background Tint Transparency — default 94, adjustable 80-99.

Panel:
• Panel Location, Theme (Dark / Light), Font Size, Label Font Size — all default to Normal and fully configurable.

🔹 How To Use

This is an analytical tool, not a standalone trading system. Typical use cases:

• Confirmation — when price breaks a structure level while the rolling net delta is strongly in the break direction and a streak is in progress, the break has participation behind it.
• Exhaustion — a long bull streak peak followed by a rolling shift to bear, or vice versa, often marks the end of the current impulse.
• Regime read — a day with many intraday pressure shifts is rotational; a day with 0-1 shifts is directional. Adjust your playbook accordingly.
• Companion to S/R, supply/demand, and volume profile tools — use the streak peak and shift events as a participation filter when price interacts with a zone.

Best results on liquid instruments with meaningful bar-to-bar volume variation. Low-volume illiquid tickers produce noisier readings.

🔹 Limitations & Transparency

• The buy vs sell attribution is a proxy derived from bar direction and bar volume. It is not real order flow, Level 2, or tick data. Bookmap, CVD from exchange feeds, and footprint tools access information that bar-level scripts structurally cannot replicate.
• On instruments or timeframes where many bars close near their open (doji-heavy regimes), proxy-based attribution becomes less informative.
• The intraday shift counter is only meaningful on intraday timeframes; on daily-and-above timeframes the panel explicitly shows this as n/a.
• The script is non-repainting on closed bars. Intrabar values update in real time and may change until the bar confirms.
• Pressure shifts and streaks describe past and current state. They are not predictions of future price.

🔹 Risk Disclosure

This script is provided as an analytical tool for educational and research purposes. It does not constitute financial advice, a trading signal, or a recommendation to buy or sell any asset. Past performance of any pattern, streak, or shift event does not guarantee future results. Users are solely responsible for their own trading decisions and risk management. Always combine any indicator with broader market context, position sizing discipline, and your own due diligence.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Buy/Sell Pressure Meter [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Buy/Sell Pressure Meter estimates buy vs sell pressure by distributing volume
// from candle-body direction and range. It tracks rolling pressure
// trend, imbalance streaks, intraday pressure shift count, and a self-measured
// shift follow-through rate - giving traders a Bookmap-light read on which side
// is currently in control. Designed as a companion to volume delta and volume
// profile tools for intraday decision support on crypto, futures and equities.
// ─────────────────────────────────────────────────

//@version=6
indicator("Buy/Sell Pressure Meter [AGPro Series]",
     shorttitle = "AG Pro BSP",
     overlay    = false,
     max_bars_back     = 500,
     max_labels_count  = 100,
     max_lines_count   = 50,
     max_boxes_count   = 50)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
headerBg      = color.rgb(37, 99, 235)      // #2563EB
headerText    = color.rgb(245, 247, 250)    // #F5F7FA
panelBg       = color.rgb(15, 23, 42)       // #0F172A
panelBorder   = color.rgb(51, 65, 85)       // #334155
panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
bullColor     = color.rgb(34, 197, 166)     // #22C5A6
bearColor     = color.rgb(244, 114, 182)    // #F472B6
neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
accentColor   = color.rgb(129, 140, 248)    // #818CF8
darkText      = color.rgb(17, 24, 39)       // #111827

// ─────────────────────────────────────────────────
// Inputs — Calculation
// ─────────────────────────────────────────────────
grpCalc = "⚙ Calculation"
trendLen       = input.int(20, "Rolling Pressure Length", minval = 2, maxval = 200, group = grpCalc, tooltip = "Lookback window used to compute the rolling average of buy pressure and sell pressure. Higher values smooth the histogram; lower values react faster.")
streakMinBars  = input.int(3, "Minimum Streak To Highlight", minval = 2, maxval = 20, group = grpCalc, tooltip = "Minimum number of consecutive same-side bars required before the streak is counted as a significant imbalance event.")
dominanceThr   = input.float(55.0, "Dominance Threshold (%)", minval = 50.0, maxval = 90.0, step = 0.5, group = grpCalc, tooltip = "Pressure ratio threshold (in percent of total) above which one side is considered dominant for bar-background tint and panel state.")
proofWindowBars = input.int(8, "Shift Proof Window", minval = 2, maxval = 60, group = grpCalc, tooltip = "After a rolling-dominance shift, the meter waits this many bars and checks whether price actually moved in the new dominant direction. Feeds the Pressure Hit Rate readout in the panel.")

// ─────────────────────────────────────────────────
// Inputs — Visuals
// ─────────────────────────────────────────────────
grpVis = "🎨 Visuals"
showHist       = input.bool(true,  "Show Dual Histogram", group = grpVis)
showNetLine    = input.bool(true,  "Show Net Delta Center Line", group = grpVis)
showPriceTint  = input.bool(true,  "Tint Price Pane On Dominance", group = grpVis, tooltip = "Tints the main price pane background when one side is rolling-dominant. Gives a Bookmap-light feel. Uses very high transparency so candles stay fully readable.")
showOscTint    = input.bool(false, "Tint Oscillator Pane On Dominance", group = grpVis, tooltip = "Adds an optional low-opacity dominance wash behind the oscillator. Disabled by default so the pressure histogram keeps first-glance priority.")
showStreakLbl  = input.bool(true,  "Show Streak Peak Labels", group = grpVis, tooltip = "Plots a single label at the end of each significant streak showing the final streak length. Labels only fire when the streak breaks, not on every bar - keeps the chart clean.")
minStreakForLabel = input.int(5, "Minimum Streak Length To Label", minval = 2, maxval = 50, group = grpVis, tooltip = "Only streaks that reach at least this length are labelled on chart. Higher values = fewer labels = cleaner chart. Recommended 5-8 for intraday, 3-4 for higher timeframes.")
maxStreakLabels = input.int(6, "Maximum Streak Labels", minval = 2, maxval = 20, group = grpVis, tooltip = "Caps retained historical streak badges. The oldest badge is deleted atomically when the limit is exceeded.")
showEvents     = input.bool(false, "Show Pressure Shift Markers", group = grpVis, tooltip = "Optionally plots compact secondary markers when rolling dominance flips. Disabled by default to prevent duplication with streak badges and the panel state.")
tintAlpha      = input.int(97, "Background Tint Transparency", minval = 80, maxval = 99, group = grpVis, tooltip = "Higher = more transparent. Default 97 preserves the regime context without overpowering price or pressure structure.")

// ─────────────────────────────────────────────────
// Inputs — Panel
// ─────────────────────────────────────────────────
grpPanel = "📊 Info Panel"
showPanel      = input.bool(true, "Show Info Panel", group = grpPanel)
panelLocation  = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel)
panelTheme     = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel)
panelFontSize  = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel)
labelFontSize  = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel)

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
f_sizeFromStr(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Large"  ? size.large  : size.normal

f_posFromStr(s) =>
    s == "Top Right"     ? position.top_right    :
     s == "Top Left"      ? position.top_left     :
     s == "Middle Right"  ? position.middle_right :
     s == "Middle Left"   ? position.middle_left  :
     s == "Bottom Right"  ? position.bottom_right : position.bottom_left

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_track_label(array<label> labels, label newLabel, int maxCount) =>
    array.push(labels, newLabel)
    while array.size(labels) > maxCount
        label.delete(array.shift(labels))

// Resolve theme
var color tHeaderBg     = na
var color tHeaderText   = na
var color tPanelBg      = na
var color tPanelBorder  = na
var color tLabelCol     = na
var color tValueCol     = na

if panelTheme == "Light"
    tHeaderBg    := headerBg
    tHeaderText  := color.white
    tPanelBg     := color.rgb(248, 250, 252)
    tPanelBorder := color.rgb(203, 213, 225)
    tLabelCol    := color.rgb(71, 85, 105)
    tValueCol    := color.rgb(15, 23, 42)
else
    tHeaderBg    := headerBg
    tHeaderText  := headerText
    tPanelBg     := panelBg
    tPanelBorder := panelBorder
    tLabelCol    := panelLabelCol
    tValueCol    := panelValueCol

// Panel-safe state colors (darker variants in Light theme for contrast)
psBull = panelTheme == "Light" ? color.rgb(13, 148, 136)  : bullColor
psBear = panelTheme == "Light" ? color.rgb(219, 39, 119)  : bearColor
psNeut = panelTheme == "Light" ? color.rgb(180, 83, 9)    : neutralColor
psAcc  = panelTheme == "Light" ? color.rgb(79, 70, 229)   : accentColor

// ─────────────────────────────────────────────────
// Core Calculations — Buy/Sell Pressure Proxy
// ─────────────────────────────────────────────────
// Candle-body direction is normalized by full bar range, then used to split
// volume between buy and sell pressure. This remains a proxy, not true order flow.
barRange  = math.max(high - low, syminfo.mintick)
bodyBias  = math.max(-1.0, math.min(1.0, (close - open) / barRange))
buyShare  = 0.5 + bodyBias * 0.5
buyPress  = volume * buyShare
sellPress = volume * (1.0 - buyShare)
netDelta  = buyPress - sellPress
totalPress = buyPress + sellPress

// Rolling averages
rollBuy   = ta.sma(buyPress,  trendLen)
rollSell  = ta.sma(sellPress, trendLen)
rollNet   = rollBuy - rollSell
rollTotal = rollBuy + rollSell

// Current bar pressure percentage (bull share)
bullPct  = totalPress > 0  ? buyPress  / totalPress  * 100.0 : 50.0
bullPctR = rollTotal > 0   ? rollBuy   / rollTotal   * 100.0 : 50.0

// Buy:Sell ratio (rolling)
buySellRatio = rollSell > 0 ? rollBuy / rollSell : na

// Dominance state
isBullBar = bullPct >= dominanceThr
isBearBar = bullPct <= (100.0 - dominanceThr)
isBullRoll = bullPctR >= dominanceThr
isBearRoll = bullPctR <= (100.0 - dominanceThr)

// Streak counter (same-side consecutive bars)
var int bullStreak = 0
var int bearStreak = 0
var int prevBullStreak = 0   // snapshot of previous bar's bull streak (for peak detection)
var int prevBearStreak = 0

prevBullStreak := bullStreak
prevBearStreak := bearStreak

if isBullBar
    bullStreak += 1
    bearStreak := 0
else if isBearBar
    bearStreak += 1
    bullStreak := 0
else
    bullStreak := 0
    bearStreak := 0

// Streak just broke — capture its peak length
bullStreakBroke = prevBullStreak > 0 and bullStreak == 0
bearStreakBroke = prevBearStreak > 0 and bearStreak == 0
bullPeakLen     = bullStreakBroke ? prevBullStreak : 0
bearPeakLen     = bearStreakBroke ? prevBearStreak : 0

currStreakSide = bullStreak > 0 ? "Bull" : bearStreak > 0 ? "Bear" : "Neutral"
currStreakVal  = math.max(bullStreak, bearStreak)

// Daily pressure shift count — how many times dominant side flipped today
isNewDay = ta.change(time("D")) != 0
var int dailyShifts  = 0
var int lastDomSide  = 0   // last non-neutral dominant side: 1 bull, -1 bear
curDomSide = isBullRoll ? 1 : isBearRoll ? -1 : 0

// Detect shift vs previous *non-neutral* state
shiftOccurred = curDomSide != 0 and lastDomSide != 0 and curDomSide != lastDomSide
shiftUp       = shiftOccurred and curDomSide ==  1
shiftDown     = shiftOccurred and curDomSide == -1

if isNewDay
    dailyShifts := 0
else if shiftOccurred
    dailyShifts += 1

if curDomSide != 0
    lastDomSide := curDomSide

// Session dominant side (accumulated delta today)
var float sessionDelta = 0.0
if isNewDay
    sessionDelta := netDelta
else
    sessionDelta += netDelta
sessionSide = sessionDelta > 0 ? "Bull" : sessionDelta < 0 ? "Bear" : "Flat"

// ─────────────────────────────────────────────────
// Pressure Hit Rate (Proof Pass)
// ─────────────────────────────────────────────────
// After a rolling-dominance shift, wait proofWindowBars and check whether price
// actually moved in the new dominant direction. Builds an honest, self-measured
// follow-through rate for the pressure read.
var int presProofHits = 0
var int presProofTotal = 0
var bool presProofPending = false
var int presProofStart = na
var float presProofEntry = na
var int presProofDir = 0

if barstate.isconfirmed
    if shiftOccurred and not presProofPending
        presProofPending := true
        presProofStart := bar_index
        presProofEntry := close
        presProofDir := curDomSide
    if presProofPending and not na(presProofStart) and bar_index - presProofStart >= proofWindowBars
        bool presHit = presProofDir > 0 ? close > presProofEntry : close < presProofEntry
        presProofTotal += 1
        if presHit
            presProofHits += 1
        presProofPending := false

float presProofRate = presProofTotal > 0 ? presProofHits / presProofTotal * 100.0 : na
string presRateText = presProofTotal > 0 ? str.tostring(int(math.round(presProofRate))) + "% (" + str.tostring(presProofHits) + "/" + str.tostring(presProofTotal) + ")" : "Building"
color presRateColor = presProofTotal == 0 ? psNeut : presProofRate >= 60.0 ? psBull : presProofRate >= 45.0 ? psNeut : psBear

// ─────────────────────────────────────────────────
// Plots — Dual Histogram + Net Line
// ─────────────────────────────────────────────────
plot(showHist ? rollBuy  : na, "Buy Pressure (Rolling)",  color = color.new(bullColor, 15), style = plot.style_columns)
plot(showHist ? -rollSell : na, "Sell Pressure (Rolling)", color = color.new(bearColor, 15), style = plot.style_columns)
plot(showNetLine ? rollNet : na, "Net Delta", color = accentColor, linewidth = 2)
hline(0, "Zero Line", color = color.new(panelLabelCol, 40), linestyle = hline.style_dotted)

// ─────────────────────────────────────────────────
// Background Tint — price pane (Bookmap-light) + subtle oscillator echo
// ─────────────────────────────────────────────────
bgCol = isBullRoll ? color.new(bullColor, tintAlpha) : isBearRoll ? color.new(bearColor, tintAlpha) : na
// Price pane tint (force_overlay paints the main chart background)
bgcolor(showPriceTint ? bgCol : na, title = "Price Pane Dominance Tint", force_overlay = true)
// Oscillator pane echo — very subtle, always on when dominance is active
oscTintCol = isBullRoll ? color.new(bullColor, math.min(98, tintAlpha + 3)) : isBearRoll ? color.new(bearColor, math.min(98, tintAlpha + 3)) : na
bgcolor(showOscTint ? oscTintCol : na, title = "Oscillator Pane Dominance Tint")

// ─────────────────────────────────────────────────
// Pressure Shift Event Markers
// ─────────────────────────────────────────────────
plotshape(showEvents and shiftUp,   "Shift To Bull", shape.triangleup,   location.bottom, bullColor, size = size.small)
plotshape(showEvents and shiftDown, "Shift To Bear", shape.triangledown, location.top,    bearColor, size = size.small)

// ─────────────────────────────────────────────────
// Streak Peak Labels — premium state-color chip, anchored above/below histogram peak
// Background = filled state color; text color resolved for contrast on any theme
// ─────────────────────────────────────────────────
var array<label> streakLabels = array.new<label>()

if barstate.isconfirmed and showStreakLbl
    if bullPeakLen >= minStreakForLabel
        // Anchor above the bull histogram peak of the broken streak
        bullAnchorY = rollBuy[1] * 1.08
        label bullLabel = label.new(bar_index - 1, bullAnchorY,
             text         = "BULL STREAK | " + str.tostring(bullPeakLen) + "B",
             color        = color.new(bullColor, 12),
             style        = label.style_label_down,
             textcolor    = f_text_on(bullColor),
             size         = f_sizeFromStr(labelFontSize),
             yloc         = yloc.price,
             textalign    = text.align_center)
        f_track_label(streakLabels, bullLabel, maxStreakLabels)
    if bearPeakLen >= minStreakForLabel
        // Anchor below the bear histogram peak (negative values, mirror)
        bearAnchorY = -rollSell[1] * 1.08
        label bearLabel = label.new(bar_index - 1, bearAnchorY,
             text         = "BEAR STREAK | " + str.tostring(bearPeakLen) + "B",
             color        = color.new(bearColor, 12),
             style        = label.style_label_up,
             textcolor    = f_text_on(bearColor),
             size         = f_sizeFromStr(labelFontSize),
             yloc         = yloc.price,
             textalign    = text.align_center)
        f_track_label(streakLabels, bearLabel, maxStreakLabels)

// ─────────────────────────────────────────────────
// Info Panel — single merged blue header row, then metrics
// ─────────────────────────────────────────────────
var table infoPanel = na

if barstate.islast and showPanel
    if na(infoPanel)
        infoPanel := table.new(f_posFromStr(panelLocation), 2, 10,
             bgcolor        = tPanelBg,
             border_color   = tPanelBorder,
             border_width   = 1,
             frame_color    = tPanelBorder,
             frame_width    = 1)

    table.set_position(infoPanel, f_posFromStr(panelLocation))

    // Row 0 — merged header (single blue cell, script name only, no version)
    table.cell(infoPanel, 0, 0, "AG Pro Buy/Sell Pressure Meter",
         bgcolor   = tHeaderBg,
         text_color = tHeaderText,
         text_size  = f_sizeFromStr(panelFontSize),
         text_halign = text.align_center)
    table.cell(infoPanel, 1, 0, "",
         bgcolor   = tHeaderBg,
         text_size  = f_sizeFromStr(panelFontSize))
    table.merge_cells(infoPanel, 0, 0, 1, 0)

    // State color for dominant side
    domCol   = isBullRoll ? psBull : isBearRoll ? psBear : psNeut
    domText  = isBullRoll ? "BULL DOMINANT" : isBearRoll ? "BEAR DOMINANT" : "BALANCED"
    streakCol = currStreakSide == "Bull" ? psBull : currStreakSide == "Bear" ? psBear : psNeut

    // Row 1 — current bar pressure
    table.cell(infoPanel, 0, 1, "Current Bar Pressure",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 1, str.tostring(bullPct, "#.#") + "% bull",
         text_color = tValueCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 2 — rolling buy:sell ratio
    ratioTxt = na(buySellRatio) ? "n/a" : str.tostring(buySellRatio, "#.##") + " : 1"
    table.cell(infoPanel, 0, 2, "Rolling " + str.tostring(trendLen) + "b Buy:Sell",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 2, ratioTxt,
         text_color = tValueCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 3 — current streak
    barWord = currStreakVal == 1 ? "bar" : "bars"
    streakTxt = currStreakVal > 0 ? currStreakSide + " streak: " + str.tostring(currStreakVal) + " " + barWord : "no streak"
    table.cell(infoPanel, 0, 3, "Current Streak",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 3, streakTxt,
         text_color = streakCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 4 — intraday pressure shifts (only meaningful on intraday TFs)
    isIntradayTF = timeframe.isintraday or timeframe.isseconds
    shiftsTxt = isIntradayTF ? str.tostring(dailyShifts) : "n/a (daily+)"
    shiftsLbl = isIntradayTF ? "Intraday Pressure Shifts" : "Pressure Shifts (Today)"
    table.cell(infoPanel, 0, 4, shiftsLbl,
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 4, shiftsTxt,
         text_color = isIntradayTF ? tValueCol : tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 5 — dominant side this session
    table.cell(infoPanel, 0, 5, "Session Dominant Side",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 5, sessionSide,
         text_color = sessionSide == "Bull" ? psBull : sessionSide == "Bear" ? psBear : psNeut,
         text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 6 — current state
    table.cell(infoPanel, 0, 6, "State (Rolling)",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 6, domText,
         text_color = domCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 7 — shift follow-through rate (proof)
    table.cell(infoPanel, 0, 7, "Pressure Hit Rate",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 7, presRateText,
         text_color = presRateColor, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 8 — methodology note
    table.cell(infoPanel, 0, 8, "Methodology",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 8, "Candle-body volume proxy",
         text_color = psAcc, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

    // Row 9 — not a strategy reminder
    table.cell(infoPanel, 0, 9, "Type",
         text_color = tLabelCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_left)
    table.cell(infoPanel, 1, 9, "Analytical tool - not a strategy",
         text_color = tValueCol, text_size = f_sizeFromStr(panelFontSize), text_halign = text.align_right)

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
alertcondition(shiftUp,                     "Pressure Shift To Bull",  "BSPM: Rolling pressure flipped to BULL dominance.")
alertcondition(shiftDown,                   "Pressure Shift To Bear",  "BSPM: Rolling pressure flipped to BEAR dominance.")
alertcondition(bullStreak == streakMinBars, "Bull Imbalance Streak",   "BSPM: Bull streak reached the minimum imbalance threshold.")
alertcondition(bearStreak == streakMinBars, "Bear Imbalance Streak",   "BSPM: Bear streak reached the minimum imbalance threshold.")
````
