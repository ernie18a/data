# Daily Trade Plan Generator [AGPro Series]

- url: https://www.tradingview.com/script/gD4fbEGn-Daily-Trade-Plan-Generator-AGPro-Series/
- type: indicator
- pine_id: PUB;aae88576cd534c0798abbf830ee19c24
- version: 4.0

## Description

Daily Trade Plan Generator [AGPro Series]

Daily Trade Plan Generator — complete morning briefing tool that generates a structured, rules-based trade plan for every new trading day. Combines key levels, multi-timeframe bias, projected volatility range, and adaptive Plan A/B/C playbooks into one premium dashboard.

🔷 OVERVIEW

Most traders start their day scattered — flipping through charts, trying to remember yesterday's highs and lows, guessing where the market might move. Daily Trade Plan Generator replaces that chaos with a single structured briefing. Every new trading day (either at UTC midnight for crypto or at a configurable exchange session open), the script automatically generates a complete plan: where the key levels are, which direction has the stronger multi-timeframe bias, how wide the day is likely to trade, and what the Plan A, Plan B, and Plan C playbooks look like. It is the first tool to open every morning — and it is self-updating, so you never have to reset it.

This is not a signal generator and not a strategy. It is a briefing tool, designed for traders who want to start every session with the same structured preparation a professional desk would do — without spending 30 minutes on it manually.

🎯 UNIQUE EDGE

What separates this script from generic level indicators and daily-high-low plotters:

• All-in-one daily briefing — levels, bias, volatility, and Plan A/B/C in one dashboard, not four separate indicators cluttering the chart.
• Multi-timeframe bias score (0 to 100) blending 1H, 4H, Daily, and Weekly EMA structure with three configurable weighting modes (Fast, Balanced, Conservative) so the bias matches your trading style.
• Asset-class-aware round numbers — the script auto-detects price magnitude and picks sensible round-number intervals (1000 for BTC-scale assets, 0.01 for forex majors, and so on) without manual setup.
• Projected daily range as a visual zone — ATR-based expected high and low rendered either as a semi-transparent rectangle, dashed lines, or both, giving you an immediate read on where price is likely to operate.
• Plan A / Plan B / Plan C structure (user-configurable 1 to 3) — deliberate "Plan" terminology to avoid confusion with pivot S/R notation. Plan language uses historical-pattern framing with no forecasting claims.
• Two refresh anchors plus a "both visible" option — crypto traders get UTC midnight, equities/futures traders get configurable session open, swing traders can see both markers.
• Timeframe-adaptive behavior — on weekly and higher timeframes, PDH/PDL automatically hide (since "previous day" is not meaningful there), and Plan A/B references shift to PWH/PWL for consistency.
• Smart label collision avoidance — PROJ HI/LO, PDH/PDL, and PWH/PWL labels intelligently reposition when too close together, keeping every chart readable at any scale.
• Volatility regime classification (Low / Normal / High) with a context-aware risk note that adapts to market conditions.

🧩 METHODOLOGY

LEVELS. Previous Day High/Low and Previous Week High/Low are pulled via higher-timeframe requests and rendered as persistent lines extending from today's session open to the right. The nearest round number is drawn as a single dotted line on the chart; the full list of nearby round numbers is shown in the dashboard panel to keep the chart clean.

BIAS SCORE. For each timeframe (1H, 4H, 1D, 1W), three components are evaluated: fast EMA versus slow EMA relationship, close versus fast EMA position, and fast EMA slope direction. Each component contributes plus or minus one, averaged to a per-timeframe score between -1 and +1. The four timeframe scores are then combined using the selected weighting mode and normalized to a 0-100 scale. Scores above 65 are labeled Bull, below 35 Bear, and in between Neutral.

VOLATILITY. Daily ATR over the configurable length (default 14) determines the expected range. The range is centered on today's session open and expanded by the Range Multiplier input. ATR as a percentage of open price classifies the regime: below 1% is Low, above 4% is High, in between is Normal.

PLANS. The script composes Plan A (primary, aligned with bias), optionally Plan B (alternative, opposite-side rejection path), and optionally Plan C (range / mean-reversion, activated when volatility is low or bias is neutral). Plan references adapt automatically to chart timeframe — intraday and daily charts use PDH/PDL, weekly and higher charts use PWH/PWL. The language is deliberately conditional and references historical patterns rather than predicting future prices.

🔔 SIGNALS & ALERTS

The script includes five built-in alert conditions:

• New Daily Plan Generated — fires when the daily refresh anchor triggers.
• Price Broke PDH — crossover above Previous Day High.
• Price Broke PDL — crossunder below Previous Day Low.
• Price Exceeded Projected High — crossover above ATR-projected high (volatility expansion).
• Price Exceeded Projected Low — crossunder below ATR-projected low (volatility expansion).

Each alert includes the ticker and relevant price in the message payload, ready to route into any alert handler.

⚙️ KEY INPUTS

• Daily Refresh Anchor — UTC Midnight, Exchange Session, or Both Visible.
• Exchange Session Open Hour — 0 to 23, used when Exchange or Both is selected.
• Key Levels toggles — PDH/PDL, PWH/PWL, Round Numbers individually toggleable.
• Round Numbers in panel — 1 to 5 levels above and below the current price.
• Bias Calculation Mode — Fast (HTF-weighted), Balanced, or Conservative (MTF-weighted).
• EMA Fast / Slow periods — defaults 20 and 50.
• ATR Length and Range Multiplier — control the width of the projected daily range.
• Expected Range Visualization — Zone (Box), Dashed Lines, or Both.
• Number of Plans — A, A+B, or A+B+C.
• Panel Location — six corner/middle positions.
• Panel and Label font sizes — Tiny through Huge, default Normal.
• Panel Theme — Dark or Light, adapts to chart background.

🛠️ HOW TO USE

1. Add the script to your chart at the start of each trading day (or leave it on permanently — it refreshes automatically).
2. Read the dashboard panel top to bottom: LEVELS tell you where the battle lines are, BIAS tells you the dominant direction, VOLATILITY tells you how much room the market has, PLANS give you conditional playbooks for the day.
3. Check the "Risk Note" line — it adapts to the volatility regime and bias. Low volatility suggests patience, high volatility suggests reducing size, neutral bias suggests waiting for a clean break.
4. Use the plotted levels as structural references for your own entries and exits. The projected range box highlights where mean-reversion trades are statistically more likely to work.
5. Set alerts on PDH/PDL breaks and projected-range expansion events to get notified when your Plan A or Plan B is being tested.
6. Adjust the bias mode to match your style: intraday scalpers benefit from Fast (HTF-weighted), position traders often prefer Conservative (MTF-weighted).

⚠️ LIMITATIONS & TRANSPARENCY

• This is a briefing tool, not a strategy or signal generator. It does not open, close, or manage trades.
• All levels and plans are derived from historical data (previous day/week highs and lows, ATR, EMA structure). Past structure does not guarantee future behavior.
• Projected ranges are statistical estimates based on ATR — actual daily ranges can and do exceed them, especially during news events or regime shifts.
• The multi-timeframe bias score is a momentum/trend structure measurement, not a prediction. Markets can reverse at any time regardless of bias.
• Plan language uses historical-pattern framing deliberately. No plan is a forecast; it is a conditional reference for discretionary decision-making.
• On weekly and higher timeframes, PDH/PDL are hidden by design because "previous day" is not a meaningful unit for weekly-horizon decisions. Plan A and Plan B use PWH/PWL as reference in those cases.
• The script does not repaint on closed higher-timeframe bars. The daily open, PDH, PDL, PWH, PWL are locked once the respective higher-timeframe bar closes.
• Round-number auto-detection uses price magnitude; for unusual instruments (very high or very low priced), review the levels manually.

🛡️ RISK DISCLOSURE

Trading involves substantial risk of loss. This script is a technical analysis tool provided for informational and educational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to trade any instrument. Past performance of any pattern, level, or methodology shown is not indicative of future results. Always conduct your own analysis, manage your position size according to your risk tolerance, and consider consulting a qualified financial professional before making trading decisions. The author and AGProLabs assume no liability for any trading outcomes resulting from the use of this tool.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Daily Trade Plan Generator [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Morning briefing planner that turns each new session into a structured trade decision map.
// It combines daily bias, plan quality, no-trade context, invalidation distance, and target
// room into a clean visual workflow for traders who want a rules-based daily plan instead
// of another generic signal. This release preserves the original visual hierarchy while
// stabilizing the daily baseline, confirmed events, label sizing, and duplicate ownership.
// ─────────────────────────────────────────────────

//@version=6
indicator("Daily Trade Plan Generator [AGPro Series]",
     shorttitle = "AG Pro DTP",
     overlay    = true,
     max_lines_count   = 150,
     max_labels_count  = 150,
     max_boxes_count   = 100)

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

// ─────────────────────────────────────────────────
// INPUTS — Session & Refresh
// ─────────────────────────────────────────────────
grpSession = "Session & Refresh"
refreshMode = input.string("UTC Midnight", "Daily Refresh Anchor",
     options = ["UTC Midnight", "Exchange Session", "Both Visible"],
     group   = grpSession,
     tooltip = "UTC Midnight: new plan at 00:00 UTC (crypto standard, 24/7).\nExchange Session: new plan at configurable exchange open hour.\nBoth Visible: show both refresh markers on chart.")
sessionHour = input.int(9, "Exchange Session Open (Hour, 0-23)",
     minval = 0, maxval = 23,
     group   = grpSession,
     tooltip = "Used when Refresh Anchor is 'Exchange Session' or 'Both Visible'. Default 09:00 exchange local time.")
showRefreshLabel = input.bool(true, "Show 'Plan Updated' Label",
     group   = grpSession,
     tooltip = "Displays a label on the chart each time a new daily plan is generated.")

// ─────────────────────────────────────────────────
// INPUTS — Key Levels
// ─────────────────────────────────────────────────
grpLevels = "Key Levels"
showPDH = input.bool(true, "Show PDH / PDL (Previous Day High/Low)", group = grpLevels)
showPWH = input.bool(true, "Show PWH / PWL (Previous Week High/Low)", group = grpLevels)
showRound = input.bool(true, "Show Nearest Round Number (chart) + Round Number List (panel)",
     group   = grpLevels,
     tooltip = "Auto-detects asset class and picks sensible round-number intervals (e.g., 1000 for BTC, 0.01 for forex majors). The nearest round number is drawn as a dotted line on the chart; the full list is shown in the dashboard panel for reference without cluttering the chart.")
roundCount = input.int(2, "Round Numbers in Panel (above/below each side)",
     minval = 1, maxval = 5,
     group   = grpLevels,
     tooltip = "Number of round-number levels to list in the panel above and below the current price.")
levelExtendBars = input.int(40, "Level Extension (bars to the right)",
     minval = 10, maxval = 500,
     group   = grpLevels,
     tooltip = "How far to the right the level lines and range zone extend. Lower values give a tighter daily-plan feel on higher timeframes (1D/4H); higher values give longer reference on intraday timeframes (5m/15m/1H).")

// ─────────────────────────────────────────────────
// INPUTS — Trend Bias (Multi-TF)
// ─────────────────────────────────────────────────
grpBias = "Trend Bias"
biasMode = input.string("Balanced", "Bias Calculation Mode",
     options = ["Fast (HTF-weighted)", "Balanced", "Conservative (MTF-weighted)"],
     group   = grpBias,
     tooltip = "Fast: weights higher timeframes more.\nBalanced: equal weight across 1H/4H/1D/1W.\nConservative: weights mid timeframes more, smoother signal.")
emaFast = input.int(20, "EMA Fast Period", minval = 5, group = grpBias)
emaSlow = input.int(50, "EMA Slow Period", minval = 10, group = grpBias)

// ─────────────────────────────────────────────────
// INPUTS — Volatility / Expected Daily Range
// ─────────────────────────────────────────────────
grpVol = "Volatility & Range"
atrLen = input.int(14, "ATR Length (daily)", minval = 5, group = grpVol)
rangeMode = input.string("Zone (Box)", "Expected Range Visualization",
     options = ["Zone (Box)", "Dashed Lines", "Both"],
     group   = grpVol,
     tooltip = "Zone: semi-transparent rectangle from projected low to projected high.\nDashed Lines: two horizontal dashed lines.\nBoth: zone + dashed lines overlay.")
rangeExpansion = input.float(1.0, "Range Multiplier (× ATR)",
     minval = 0.5, maxval = 2.0, step = 0.1,
     group   = grpVol,
     tooltip = "Projected daily range = open ± (ATR × multiplier). Default 1.0 matches historical average daily range.")

// ─────────────────────────────────────────────────
// INPUTS — Plans (A / B / C)
// ─────────────────────────────────────────────────
grpScen = "Plans"
scenarioCount = input.int(1, "Number of Plans (A / A+B / A+B+C)",
     minval = 1, maxval = 3,
     group   = grpScen,
     tooltip = "A: Primary plan only (aligned with bias).\nA + B: Primary + Alternative (rejection/pullback).\nA + B + C: Primary + Alternative + Range (mean-reversion).")

// ─────────────────────────────────────────────────
// INPUTS — Plan Engine
// ─────────────────────────────────────────────────
grpPlan = "Plan Engine"
showPlanMap = input.bool(true, "Show Session Plan Box",
     group   = grpPlan,
     tooltip = "Draws the active daily planning area between the session risk line and the projected target reference.")
showNoTradeZone = input.bool(true, "Show No-Trade Zone",
     group   = grpPlan,
     tooltip = "Draws a compact open-range zone where the plan should be treated as inactive until price leaves the neutral area.")
showPlanStateLabel = input.bool(true, "Show Plan Quality Label",
     group   = grpPlan,
     tooltip = "Shows the current plan state, quality score, and next-action context on the chart.")
planSensitivity = input.string("Balanced", "Plan Sensitivity",
     options = ["Aggressive", "Balanced", "Conservative"],
     group   = grpPlan,
     tooltip = "Aggressive narrows the no-trade zone and accepts faster activation. Conservative widens the no-trade zone and requires cleaner confirmation.")
confirmationMode = input.string("Close", "Confirmation Mode",
     options = ["Close", "Body Direction"],
     group   = grpPlan,
     tooltip = "Close: confirms the plan when price is on the correct side of the session open. Body Direction: also requires the current candle body to close in the plan direction.")
minPlanQuality = input.int(60, "Minimum Active Plan Quality",
     minval = 40, maxval = 90,
     group   = grpPlan,
     tooltip = "Minimum 0-100 plan quality required before the daily plan can be marked as Active.")
noTradeAtrPct = input.float(0.16, "No-Trade Zone Width (ATR fraction)",
     minval = 0.05, maxval = 0.35, step = 0.01,
     group   = grpPlan,
     tooltip = "Half-width of the no-trade zone around the session open, expressed as a fraction of daily ATR.")
riskLineAtrPct = input.float(0.42, "Risk Line Distance (ATR fraction)",
     minval = 0.20, maxval = 0.80, step = 0.01,
     group   = grpPlan,
     tooltip = "Distance from the session open to the invalidation reference used by the daily plan engine.")

// ─────────────────────────────────────────────────
// INPUTS — Panel
// ─────────────────────────────────────────────────
grpPanel = "Panel"
showPanel = input.bool(true, "Show Dashboard Panel", group = grpPanel)
panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group   = grpPanel)
panelTextSize = input.string("Normal", "Panel Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = grpPanel)
panelTheme = input.string("Dark", "Panel Theme",
     options = ["Dark", "Light"],
     group   = grpPanel)

// ─────────────────────────────────────────────────
// INPUTS — Labels
// ─────────────────────────────────────────────────
grpLbl = "Labels"
showLabels = input.bool(true, "Show Level Labels on Chart", group = grpLbl)
labelTextSize = input.string("Normal", "Label Font Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group   = grpLbl)
labelOffset = input.int(5, "Label Horizontal Offset (bars)",
     minval = 1, maxval = 30,
     group   = grpLbl,
     tooltip = "Pushes labels to the right of the last bar to avoid overlap with candles.")

// ─────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────
f_toSize(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large  : size.huge

f_panelPos(s) =>
    s == "Top Right"     ? position.top_right     :
     s == "Top Left"      ? position.top_left      :
     s == "Middle Right"  ? position.middle_right  :
     s == "Middle Left"   ? position.middle_left   :
     s == "Bottom Right"  ? position.bottom_right  : position.bottom_left

// Theme-aware panel colors
actualPanelBg     = panelTheme == "Dark" ? panelBg       : color.rgb(248, 250, 252)
actualPanelBorder = panelTheme == "Dark" ? panelBorder   : color.rgb(203, 213, 225)
actualLabelCol    = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
actualValueCol    = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)

// Auto-detect round-number interval based on current price magnitude
f_roundInterval(price) =>
    mag = math.log10(math.abs(price))
    mag >= 4.5  ? 1000.0  :
     mag >= 3.5 ? 100.0   :
     mag >= 2.5 ? 10.0    :
     mag >= 1.5 ? 1.0     :
     mag >= 0.5 ? 0.1     :
     mag >= -0.5 ? 0.01   : 0.001

// Format numbers cleanly
f_fmt(v) =>
    a = math.abs(v)
    a >= 1000 ? str.tostring(v, "#,###.##") :
     a >= 1    ? str.tostring(v, "#.####")   :
     str.tostring(v, "#.########")

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

// ─────────────────────────────────────────────────
// SESSION / REFRESH DETECTION
// ─────────────────────────────────────────────────
// Use time-based UTC day tracking (chart-timezone-independent)
var int  currentUtcDay = na
thisUtcDay  = dayofmonth(time, "UTC")
utcNewDay   = not na(currentUtcDay) and thisUtcDay != currentUtcDay
if utcNewDay or na(currentUtcDay)
    currentUtcDay := thisUtcDay

hourChange     = ta.change(hour)
sessionNewDay  = hour == sessionHour and hourChange != 0
isRefresh      = refreshMode == "UTC Midnight"    ? utcNewDay :
                 refreshMode == "Exchange Session" ? sessionNewDay :
                 utcNewDay or sessionNewDay
confirmedRefresh = isRefresh and barstate.isconfirmed

// Track start-of-session bar (for drawing zones that begin at today's open)
var int   todayStartBar = na
var float todayOpen     = na
if isRefresh
    todayStartBar := bar_index
    todayOpen     := open
if na(todayStartBar)
    todayStartBar := bar_index
    todayOpen     := open

// ─────────────────────────────────────────────────
// KEY LEVELS — request previous day/week H/L
// ─────────────────────────────────────────────────
// KEY LEVELS — request previous day/week H/L
// Auto-hide PDH/PDL on weekly+ charts (not meaningful for weekly traders)
// ─────────────────────────────────────────────────
isIntradayOrDaily = timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("D")
showPDH_effective = showPDH and isIntradayOrDaily

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)

// ─────────────────────────────────────────────────
// TREND BIAS — multi-TF EMA cross strength (0-100)
// ─────────────────────────────────────────────────
f_biasScoreTF(simple string tf) =>
    ef = request.security(syminfo.tickerid, tf, ta.ema(close, emaFast), lookahead = barmerge.lookahead_off)
    es = request.security(syminfo.tickerid, tf, ta.ema(close, emaSlow), lookahead = barmerge.lookahead_off)
    cl = request.security(syminfo.tickerid, tf, close,                  lookahead = barmerge.lookahead_off)
    // Component A: fast vs slow
    compA = ef > es ? 1.0 : -1.0
    // Component B: close vs fast (momentum strength)
    compB = cl > ef ? 1.0 : -1.0
    // Component C: slope of fast EMA (local history, safe)
    compC = ef > ef[1] ? 1.0 : -1.0
    (compA + compB + compC) / 3.0  // -1 .. +1

b1H = f_biasScoreTF("60")
b4H = f_biasScoreTF("240")
b1D = f_biasScoreTF("D")
b1W = f_biasScoreTF("W")

// Weighting schemes — Pine v6 requires if/else for tuple returns
[w1H, w4H, w1D, w1W] = if biasMode == "Fast (HTF-weighted)"
    [0.10, 0.20, 0.35, 0.35]
else if biasMode == "Conservative (MTF-weighted)"
    [0.15, 0.40, 0.35, 0.10]
else
    [0.25, 0.25, 0.25, 0.25]  // Balanced

rawBias = b1H * w1H + b4H * w4H + b1D * w1D + b1W * w1W   // -1..+1
biasScore = math.round((rawBias + 1) * 50)                 // 0..100
biasLabel = biasScore >= 65 ? "BULL" : biasScore <= 35 ? "BEAR" : "NEUTRAL"
biasCol   = biasScore >= 65 ? bullColor : biasScore <= 35 ? bearColor : neutralColor

// ─────────────────────────────────────────────────
// VOLATILITY — ATR-based projected range
// ─────────────────────────────────────────────────
atrD = math.max(nz(request.security(syminfo.tickerid, "D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)), syminfo.mintick)
atrChart = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)
// Visible-scale proxy: a 200-bar high-low range tracks how "tall" a fixed-pixel
// label is in price terms, so label spacing can adapt to zoomed-out HTF views.
rangeProxy = ta.highest(high, 200) - ta.lowest(low, 200)
projRange = atrD * rangeExpansion
projHigh  = todayOpen + projRange / 2
projLow   = todayOpen - projRange / 2
atrPct    = todayOpen != 0 ? (projRange / todayOpen) * 100 : 0.0

// Volatility regime
volRegime = atrPct < 1.0 ? "LOW" : atrPct > 4.0 ? "HIGH" : "NORMAL"
volCol    = volRegime == "LOW" ? neutralColor : volRegime == "HIGH" ? bearColor : bullColor

// ─────────────────────────────────────────────────
// DAILY PLAN ENGINE — quality, state, risk, target
// ─────────────────────────────────────────────────
refHi      = showPDH_effective ? pdh : pwh
refLo      = showPDH_effective ? pdl : pwl
refHiLabel = showPDH_effective ? "PDH" : "PWH"
refLoLabel = showPDH_effective ? "PDL" : "PWL"

planDir = biasLabel == "BULL" ? 1 : biasLabel == "BEAR" ? -1 : 0
sensZoneMult = planSensitivity == "Aggressive" ? 0.75 : planSensitivity == "Conservative" ? 1.25 : 1.0
sensRiskMult = planSensitivity == "Aggressive" ? 0.90 : planSensitivity == "Conservative" ? 1.10 : 1.0

noTradeHalf = atrD * noTradeAtrPct * sensZoneMult
noTradeHigh = todayOpen + noTradeHalf
noTradeLow  = todayOpen - noTradeHalf
riskDistance = atrD * riskLineAtrPct * sensRiskMult
planRiskLine = planDir == 1 ? todayOpen - riskDistance : planDir == -1 ? todayOpen + riskDistance : todayOpen
planTarget   = planDir == 1 ? projHigh : planDir == -1 ? projLow : todayOpen

targetRoomRaw = planDir == 1 ? planTarget - close : planDir == -1 ? close - planTarget : 0.0
riskRoomRaw   = planDir == 1 ? close - planRiskLine : planDir == -1 ? planRiskLine - close : 0.0
targetRoomSafe = math.max(targetRoomRaw, 0.0)
targetRoomAtr  = atrD != 0 ? targetRoomSafe / atrD : 0.0

closeConfirms = planDir == 1 ? close > todayOpen : planDir == -1 ? close < todayOpen : false
bodyConfirms  = planDir == 1 ? close > open and close > todayOpen : planDir == -1 ? close < open and close < todayOpen : false
planConfirmed = confirmationMode == "Close" ? closeConfirms : bodyConfirms

openScore = planDir == 0 ? 50.0 : planConfirmed ? 100.0 : 35.0
biasConfirmScore = planDir == 0 ? 40.0 : f_clamp(55.0 + math.abs(biasScore - 50.0) * 1.5, 0.0, 100.0)
volScore = volRegime == "NORMAL" ? 100.0 : volRegime == "LOW" ? 68.0 : 58.0
riskRatio = riskDistance != 0 ? riskRoomRaw / riskDistance : 0.0
riskScore = riskRatio <= 0.0 ? 0.0 : riskRatio < 0.25 ? 45.0 : riskRatio > 2.40 ? 65.0 : 100.0
targetScore = atrD != 0 ? f_clamp(targetRoomSafe / (atrD * 0.35) * 100.0, 0.0, 100.0) : 0.0

planQualityRaw = openScore * 0.20 + biasConfirmScore * 0.25 + volScore * 0.15 + riskScore * 0.20 + targetScore * 0.20
planQuality = int(math.round(f_clamp(planQualityRaw, 0.0, 100.0)))

insideNoTrade = close >= noTradeLow and close <= noTradeHigh
targetBlocked = planDir != 0 and targetRoomSafe <= atrD * 0.08
planInvalidated = planDir == 1 ? close < planRiskLine : planDir == -1 ? close > planRiskLine : false
planReady = planDir != 0 and planQuality >= minPlanQuality and not insideNoTrade and not targetBlocked and not planInvalidated

planStateCode = planInvalidated ? 4 : planDir == 0 ? 0 : targetBlocked ? 2 : insideNoTrade ? 1 : planReady ? 3 : 5
planState = planStateCode == 4 ? "INVALIDATED" :
     planStateCode == 3 ? "ACTIVE" :
     planStateCode == 2 ? "BLOCKED" :
     planStateCode == 1 ? "NO-TRADE" :
     planStateCode == 5 ? "REVIEW" : "NEUTRAL"
planCol = planStateCode == 3 ? bullColor :
     planStateCode == 4 ? bearColor :
     planStateCode == 2 ? neutralColor :
     planStateCode == 1 ? accentColor :
     planStateCode == 5 ? neutralColor : actualLabelCol
actionText = planStateCode == 3 ? "Monitor plan" :
     planStateCode == 4 ? "Reset plan" :
     planStateCode == 2 ? "Target room limited" :
     planStateCode == 1 ? "Wait outside zone" :
     planStateCode == 5 ? "Review confirmation" :
     "Wait for bias"

// ─────────────────────────────────────────────────
// PLAN ACTIVATION PROOF — stop-aware, confirmed-bar gated
// When a daily plan turns Active, does price follow through in the plan
// direction (1.5 ATR) before reversing against it (1.0 ATR)?
// ─────────────────────────────────────────────────
var float dtpProofTarget = na
var float dtpProofStop   = na
var int   dtpProofDir    = 0
var bool  dtpProofOpen   = false
var int   dtpProofAge    = na
var int   dtpProofWins   = 0
var int   dtpProofLosses = 0

planActivated = planStateCode == 3 and planStateCode[1] != 3
if barstate.isconfirmed
    if planActivated and not dtpProofOpen and planDir != 0
        dtpProofDir    := planDir
        dtpProofTarget := planDir == 1 ? close + atrChart * 1.5 : close - atrChart * 1.5
        dtpProofStop   := planDir == 1 ? close - atrChart * 1.0 : close + atrChart * 1.0
        dtpProofAge    := 0
        dtpProofOpen   := true
    if dtpProofOpen and not na(dtpProofTarget) and not na(dtpProofStop)
        bool dtpHitStop   = dtpProofDir == 1 ? close <= dtpProofStop : close >= dtpProofStop
        bool dtpHitTarget = dtpProofDir == 1 ? close >= dtpProofTarget : close <= dtpProofTarget
        if dtpHitStop
            dtpProofLosses += 1
            dtpProofOpen := false
        else if dtpHitTarget
            dtpProofWins += 1
            dtpProofOpen := false
        else
            dtpProofAge := nz(dtpProofAge) + 1
            if dtpProofAge > 25
                dtpProofOpen := false

int    dtpProofTotal = dtpProofWins + dtpProofLosses
float  dtpProofRate  = dtpProofTotal == 0 ? 0.0 : 100.0 * dtpProofWins / dtpProofTotal
string dtpProofText  = dtpProofTotal < 6 ? "Building (" + str.tostring(dtpProofTotal) + ")" : str.tostring(math.round(dtpProofRate)) + "% (" + str.tostring(dtpProofTotal) + ")"
color  dtpProofCol   = dtpProofTotal < 6 ? actualLabelCol : dtpProofRate >= 55 ? bullColor : dtpProofRate >= 45 ? neutralColor : bearColor

// ─────────────────────────────────────────────────
// DRAW — Persistent objects (re-drawn on each refresh)
// ─────────────────────────────────────────────────
var line lnPDH = na
var line lnPDL = na
var line lnPWH = na
var line lnPWL = na
var label lbPDH = na
var label lbPDL = na
var label lbPWH = na
var label lbPWL = na

var box  rangeBox = na
var line lnProjH  = na
var line lnProjL  = na
var label lbProjH = na
var label lbProjL = na

var box  planBox      = na
var box  noTradeBox   = na
var line lnPlanRisk   = na
var line lnPlanTarget = na
var label lbPlanRisk  = na
var label lbPlanTgt   = na
var label lbPlanState = na
var label lbPlanBadge = na
var label lbNoTradeBadge = na

var label lbRefresh = na

var array<line>  roundLines  = array.new<line>()
var array<label> roundLabels = array.new<label>()
var array<float> placedYs    = array.new<float>()

// Scenario storage
var label lbScen1 = na
var label lbScen2 = na
var label lbScen3 = na

f_deleteLine(line l) =>
    if not na(l)
        line.delete(l)
f_deleteLabel(label l) =>
    if not na(l)
        label.delete(l)
f_deleteBox(box b) =>
    if not na(b)
        box.delete(b)

// Right-edge label de-collision: returns a y near baseY that does not sit within
// "spacing" of any already-placed right-edge label (expanding up/down search).
f_avoid(float baseY, float spacing) =>
    float result = baseY
    int sz = array.size(placedYs)
    if sz > 0
        bool clash = true
        int guard = 0
        while clash and guard < 40
            clash := false
            for i = 0 to sz - 1
                if math.abs(result - array.get(placedYs, i)) < spacing
                    clash := true
                    break
            if clash
                guard += 1
                int k = int((guard + 1) / 2)
                result := baseY + (guard % 2 == 1 ? spacing * k : -spacing * k)
    result

// Redraw on every refresh or on last bar (to keep levels live)
if (confirmedRefresh or barstate.islast)
    // Drawing anchors
    startBar = todayStartBar
    endBar   = bar_index + levelExtendBars
    lblSize  = f_toSize(labelTextSize)
    // Minimum vertical spacing for label collision detection — scales with the
    // visible price range so zoomed-out HTF charts get a larger gap.
    minSpacing = math.max(atrD * 0.35, rangeProxy * 0.028)
    mergeTolerance = math.max(syminfo.mintick * 2.0, atrD * 0.005)
    mergePwhWithPdh = showPDH_effective and showPWH and math.abs(pwh - pdh) <= mergeTolerance
    mergePwhWithPdl = showPDH_effective and showPWH and math.abs(pwh - pdl) <= mergeTolerance
    mergePwlWithPdh = showPDH_effective and showPWH and math.abs(pwl - pdh) <= mergeTolerance
    mergePwlWithPdl = showPDH_effective and showPWH and math.abs(pwl - pdl) <= mergeTolerance
    drawPWH = showPWH and not mergePwhWithPdh and not mergePwhWithPdl
    drawPWL = showPWH and not mergePwlWithPdh and not mergePwlWithPdl
    pdhTag = mergePwhWithPdh ? "PDH / PWH" : mergePwlWithPdh ? "PDH / PWL" : "PDH"
    pdlTag = mergePwhWithPdl ? "PDL / PWH" : mergePwlWithPdl ? "PDL / PWL" : "PDL"
    targetOwnsProjHigh = showPlanMap and planDir == 1
    targetOwnsProjLow  = showPlanMap and planDir == -1
    targetBadgeOwnsProjHigh = targetOwnsProjHigh and showLabels and showPlanStateLabel
    targetBadgeOwnsProjLow  = targetOwnsProjLow and showLabels and showPlanStateLabel
    array.clear(placedYs)

    // Clear previous
    f_deleteLine(lnPDH), f_deleteLine(lnPDL), f_deleteLine(lnPWH), f_deleteLine(lnPWL)
    f_deleteLabel(lbPDH), f_deleteLabel(lbPDL), f_deleteLabel(lbPWH), f_deleteLabel(lbPWL)
    f_deleteBox(rangeBox)
    f_deleteLine(lnProjH), f_deleteLine(lnProjL)
    f_deleteLabel(lbProjH), f_deleteLabel(lbProjL)
    f_deleteBox(planBox), f_deleteBox(noTradeBox)
    f_deleteLabel(lbPlanBadge), f_deleteLabel(lbNoTradeBadge)
    f_deleteLine(lnPlanRisk), f_deleteLine(lnPlanTarget)
    f_deleteLabel(lbPlanRisk), f_deleteLabel(lbPlanTgt), f_deleteLabel(lbPlanState)
    f_deleteLabel(lbScen1), f_deleteLabel(lbScen2), f_deleteLabel(lbScen3)

    // Clear round-number arrays
    if array.size(roundLines) > 0
        for i = 0 to array.size(roundLines) - 1
            line.delete(array.get(roundLines, i))
        array.clear(roundLines)
    if array.size(roundLabels) > 0
        for i = 0 to array.size(roundLabels) - 1
            label.delete(array.get(roundLabels, i))
        array.clear(roundLabels)

    // PDH / PDL — lines start from today's session open, labels on the right
    // (hidden automatically on weekly+ charts since "previous day" is not meaningful there)
    if showPDH_effective
        lnPDH := line.new(startBar, pdh, endBar, pdh, color = neutralColor, width = 2, style = line.style_solid)
        lnPDL := line.new(startBar, pdl, endBar, pdl, color = accentColor,  width = 2, style = line.style_solid)
        if showLabels
            pdhY = f_avoid(pdh, minSpacing)
            lbPDH := label.new(endBar + labelOffset, pdhY, pdhTag + "  " + f_fmt(pdh),
                 style = label.style_label_left, color = neutralColor,
                 textcolor = f_text_on(neutralColor), size = lblSize)
            array.push(placedYs, pdhY)
            pdlY = f_avoid(pdl, minSpacing)
            lbPDL := label.new(endBar + labelOffset, pdlY, pdlTag + "  " + f_fmt(pdl),
                 style = label.style_label_left, color = accentColor,
                 textcolor = f_text_on(accentColor), size = lblSize)
            array.push(placedYs, pdlY)

    // PWH / PWL
    if showPWH
        if drawPWH
            lnPWH := line.new(startBar, pwh, endBar, pwh, color = neutralColor, width = 1, style = line.style_dashed)
        if drawPWL
            lnPWL := line.new(startBar, pwl, endBar, pwl, color = accentColor, width = 1, style = line.style_dashed)
        if showLabels and drawPWH
            pwhY = f_avoid(pwh, minSpacing)
            lbPWH := label.new(endBar + labelOffset, pwhY, "PWH  " + f_fmt(pwh),
                 style = label.style_label_left, color = neutralColor,
                 textcolor = f_text_on(neutralColor), size = lblSize)
            array.push(placedYs, pwhY)
        if showLabels and drawPWL
            pwlY = f_avoid(pwl, minSpacing)
            lbPWL := label.new(endBar + labelOffset, pwlY, "PWL  " + f_fmt(pwl),
                 style = label.style_label_left, color = accentColor,
                 textcolor = f_text_on(accentColor), size = lblSize)
            array.push(placedYs, pwlY)

    // Round numbers — only the nearest one is drawn on the chart (dotted),
    // the full nearby list is shown in the dashboard panel to keep the chart clean.
    if showRound
        interval = f_roundInterval(close)
        nearest  = math.round(close / interval) * interval
        // Collision check: skip the chart line if nearest round coincides with PDH/PDL/PWH/PWL/Proj
        tooClose = false
        if showPDH_effective and (math.abs(nearest - pdh) < minSpacing or math.abs(nearest - pdl) < minSpacing)
            tooClose := true
        if showPWH and ((drawPWH and math.abs(nearest - pwh) < minSpacing) or (drawPWL and math.abs(nearest - pwl) < minSpacing))
            tooClose := true
        if math.abs(nearest - projHigh) < minSpacing or math.abs(nearest - projLow) < minSpacing
            tooClose := true
        if not tooClose
            ln = line.new(startBar, nearest, endBar, nearest,
                 color = color.new(actualLabelCol, 40), width = 1, style = line.style_dotted)
            array.push(roundLines, ln)
            if showLabels
                roundY = f_avoid(nearest, minSpacing)
                lb = label.new(endBar + labelOffset, roundY, "R  " + f_fmt(nearest),
                     style = label.style_label_left, color = actualLabelCol,
                     textcolor = f_text_on(actualLabelCol), size = lblSize)
                array.push(roundLabels, lb)
                array.push(placedYs, roundY)

    // Expected daily range — anchored to today's session start
    // PROJ HI/LO labels always shown (so zone is self-explanatory) regardless of rangeMode
    if rangeMode == "Zone (Box)" or rangeMode == "Both"
        rangeBox := box.new(startBar, projHigh, endBar, projLow,
             border_color = color.new(accentColor, 40),
             bgcolor      = color.new(accentColor, 92),
             border_width = 1)
    if rangeMode == "Dashed Lines" or rangeMode == "Both"
        if not targetOwnsProjHigh
            lnProjH := line.new(startBar, projHigh, endBar, projHigh,
                 color = color.new(accentColor, 20), width = 1, style = line.style_dashed)
        if not targetOwnsProjLow
            lnProjL := line.new(startBar, projLow, endBar, projLow,
                 color = color.new(accentColor, 20), width = 1, style = line.style_dashed)
    // PROJ HI and PROJ LO labels — ALWAYS visible so the projected range is always labeled
    if showLabels and (rangeMode == "Zone (Box)" or rangeMode == "Dashed Lines" or rangeMode == "Both")
        if not targetBadgeOwnsProjHigh
            projHY = f_avoid(projHigh, minSpacing)
            lbProjH := label.new(endBar + labelOffset, projHY, "PROJ HI  " + f_fmt(projHigh),
                 style = label.style_label_left, color = accentColor,
                 textcolor = f_text_on(accentColor), size = lblSize)
            array.push(placedYs, projHY)
        if not targetBadgeOwnsProjLow
            projLY = f_avoid(projLow, minSpacing)
            lbProjL := label.new(endBar + labelOffset, projLY, "PROJ LO  " + f_fmt(projLow),
                 style = label.style_label_left, color = accentColor,
                 textcolor = f_text_on(accentColor), size = lblSize)
            array.push(placedYs, projLY)

    // Session plan map — decision layer that keeps the script chart-first.
    if showPlanMap and planDir != 0
        planTop = math.max(planTarget, planRiskLine)
        planBottom = math.min(planTarget, planRiskLine)
        planText = showNoTradeZone ? "SESSION" : "SESSION PLAN"
        planBox := box.new(startBar, planTop, endBar, planBottom,
             border_color = color.new(planCol, 45),
             bgcolor      = color.new(planCol, 94),
             border_width = 1)
        planBadgeX = int(math.round((startBar + endBar) / 2.0))
        planBadgeY = (planTop + planBottom) / 2.0
        lbPlanBadge := label.new(planBadgeX, planBadgeY, planText,
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_label_center, color = planCol,
             textcolor = f_text_on(planCol), size = lblSize)
        lnPlanRisk := line.new(startBar, planRiskLine, endBar, planRiskLine,
             color = color.new(bearColor, 10), width = 2, style = line.style_dashed)
        lnPlanTarget := line.new(startBar, planTarget, endBar, planTarget,
             color = color.new(bullColor, 15), width = 2, style = line.style_solid)
        if showLabels and showPlanStateLabel
            planLabelX = endBar + labelOffset
            riskY = f_avoid(planRiskLine, minSpacing)
            lbPlanRisk := label.new(planLabelX, riskY,
                 "RISK  " + f_fmt(planRiskLine),
                 style = label.style_label_left, color = bearColor,
                 textcolor = f_text_on(bearColor), size = lblSize)
            array.push(placedYs, riskY)
            targetY = f_avoid(planTarget, minSpacing)
            targetBadgeText = planDir == 1 ? "TARGET / PROJ HI  " : "TARGET / PROJ LO  "
            lbPlanTgt := label.new(planLabelX, targetY,
                 targetBadgeText + f_fmt(planTarget),
                 style = label.style_label_left, color = bullColor,
                 textcolor = f_text_on(bullColor), size = lblSize)
            array.push(placedYs, targetY)

    if showNoTradeZone
        noTradeRight = startBar + math.max(3, math.round((endBar - startBar) * 0.40))
        noTradeBox := box.new(startBar, noTradeHigh, noTradeRight, noTradeLow,
             border_color = color.new(accentColor, 55),
             bgcolor      = color.new(accentColor, 90),
             border_width = 1)
        noTradeBadgeX = int(math.round((startBar + noTradeRight) / 2.0))
        noTradeBadgeY = (noTradeHigh + noTradeLow) / 2.0
        lbNoTradeBadge := label.new(noTradeBadgeX, noTradeBadgeY, "WAIT",
             xloc = xloc.bar_index, yloc = yloc.price,
             style = label.style_label_center, color = accentColor,
             textcolor = f_text_on(accentColor), size = lblSize)

    if showLabels and showPlanStateLabel
        stateY = planDir == -1 ? low - atrD * 0.35 : high + atrD * 0.35
        stateText = planState + "  Q" + str.tostring(planQuality) + "\n" + actionText
        lbPlanState := label.new(bar_index + labelOffset, stateY, stateText,
             style = label.style_label_left,
             color = planCol,
             textcolor = f_text_on(planCol),
             size = lblSize)

    // Refresh marker
    if confirmedRefresh and showRefreshLabel
        f_deleteLabel(lbRefresh)
        lbRefresh := label.new(bar_index, high, "Plan Updated",
             style     = label.style_label_down,
             color     = headerBg,
             textcolor = f_text_on(headerBg),
             size      = lblSize,
             yloc      = yloc.abovebar)

// ─────────────────────────────────────────────────
// SCENARIOS — moderation-safe language
// ─────────────────────────────────────────────────
// Scenario 1 (Primary) — follows bias
// Scenario 2 (Alternative) — opposite side
// Scenario 3 (Range)      — mean-reversion
if barstate.islast
    lblSize2 = f_toSize(labelTextSize)
    // Anchor scenarios near today's session start (left side of plan area) to avoid
    // collision with right-side PROJ HI/LO/PDH/PDL labels.
    scenX = todayStartBar + math.max(1, math.round((bar_index - todayStartBar) * 0.25))
    // Smart stacking: push scenario labels ABOVE the highest visible level and BELOW the lowest,
    // so they never collide with PDH/PDL/PWH/PWL/Proj labels on the right.
    scenRoundInt  = f_roundInterval(close)
    scenNearestR  = math.round(close / scenRoundInt) * scenRoundInt
    refHiForStack = showPDH_effective ? pdh : pwh
    refLoForStack = showPDH_effective ? pdl : pwl
    highestLvl = math.max(math.max(projHigh, refHiForStack), math.max(pwh, scenNearestR + roundCount * scenRoundInt))
    lowestLvl  = math.min(math.min(projLow,  refLoForStack), math.min(pwl, scenNearestR - roundCount * scenRoundInt))
    scenYTop    = highestLvl + (atrD * 0.35)
    scenYBottom = lowestLvl  - (atrD * 0.35)
    scenYMid    = (projHigh + projLow) / 2

    // Plan A: Primary (aligned with bias) — placed above the highest level
    s1Text = ""
    s1Col  = biasCol
    if biasLabel == "BULL"
        s1Text := "PLAN A: break " + refHiLabel + " -> target ref " + f_fmt(projHigh)
    else if biasLabel == "BEAR"
        s1Text := "PLAN A: break " + refLoLabel + " -> target ref " + f_fmt(projLow)
    else
        s1Text := "PLAN A: range watch " + f_fmt(projLow) + " / " + f_fmt(projHigh)
    if scenarioCount >= 1
        lbScen1 := label.new(scenX, scenYTop, s1Text,
             style = label.style_label_lower_left, color = s1Col,
             textcolor = f_text_on(s1Col), size = lblSize2)

    // Plan B: Alternative — placed below the lowest level
    if scenarioCount >= 2
        s2Text = biasLabel == "BULL" ?
             "PLAN B: reject " + refHiLabel + " -> review pullback" :
             biasLabel == "BEAR" ?
             "PLAN B: reject " + refLoLabel + " -> review relief" :
             "PLAN B: break range -> review extension"
        s2Col = biasLabel == "BULL" ? bearColor : biasLabel == "BEAR" ? bullColor : accentColor
        lbScen2 := label.new(scenX, scenYBottom, s2Text,
             style = label.style_label_upper_left, color = s2Col,
             textcolor = f_text_on(s2Col), size = lblSize2)

    // Plan C: Range — placed at midpoint (only when user opts in)
    if scenarioCount >= 3
        s3Text = "PLAN C: range plan if volatility stays " + volRegime
        lbScen3 := label.new(scenX, scenYMid, s3Text,
             style = label.style_label_left, color = neutralColor,
             textcolor = f_text_on(neutralColor), size = lblSize2)

// ─────────────────────────────────────────────────
// DASHBOARD PANEL
// ─────────────────────────────────────────────────
var table tbl = na

if barstate.islast
    if not showPanel and not na(tbl)
        table.delete(tbl)
        tbl := na

    if showPanel
        if not na(tbl)
            table.delete(tbl)
        tbl := table.new(f_panelPos(panelLocation), 2, 8,
             bgcolor      = actualPanelBg,
             border_color = actualPanelBorder,
             border_width = 1,
             frame_color  = actualPanelBorder,
             frame_width  = 1)

        pSize = f_toSize(panelTextSize)

        // Row 0: Merged header (blue background, script name only — no version)
        table.cell(tbl, 0, 0, "AG Pro Daily Trade Plan Generator",
             text_color = headerText, bgcolor = headerBg, text_size = pSize, text_halign = text.align_center)
        table.merge_cells(tbl, 0, 0, 1, 0)

        dailyBiasText = biasLabel + "  " + str.tostring(biasScore) + "/100"
        qualityText = str.tostring(planQuality) + "/100  " + planState
        riskLineText = planDir == 0 ? "Session open  " + f_fmt(todayOpen) : f_fmt(planRiskLine)
        targetRoomText = planDir == 0 ? "No directional room" : f_fmt(targetRoomSafe) + "  (" + str.tostring(targetRoomAtr * 100.0, "#") + "% ATR)"

        table.cell(tbl, 0, 1, "Daily Bias", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 1, dailyBiasText, text_color = biasCol, bgcolor = color.new(biasCol, 88), text_size = pSize, text_halign = text.align_right)

        table.cell(tbl, 0, 2, "Plan Quality", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 2, qualityText, text_color = planCol, bgcolor = color.new(planCol, 86), text_size = pSize, text_halign = text.align_right)

        table.cell(tbl, 0, 3, "Risk Line", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 3, riskLineText, text_color = bearColor, bgcolor = actualPanelBg, text_size = pSize, text_halign = text.align_right)

        table.cell(tbl, 0, 4, "Target Room", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 4, targetRoomText, text_color = targetRoomSafe > 0 ? bullColor : neutralColor, bgcolor = actualPanelBg, text_size = pSize, text_halign = text.align_right)

        table.cell(tbl, 0, 5, "Volatility", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 5, volRegime + "  " + str.tostring(atrPct, "#.##") + "%", text_color = volCol, bgcolor = color.new(volCol, 88), text_size = pSize, text_halign = text.align_right)

        table.cell(tbl, 0, 6, "Action", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 6, actionText, text_color = actualValueCol, bgcolor = actualPanelBg, text_size = pSize, text_halign = text.align_right)

        table.cell(tbl, 0, 7, "Proof", text_color = actualLabelCol, bgcolor = actualPanelBg, text_size = pSize)
        table.cell(tbl, 1, 7, dtpProofText, text_color = dtpProofCol, bgcolor = actualPanelBg, text_size = pSize, text_halign = text.align_right)

// ─────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────
planReadyAlert = barstate.isconfirmed and planStateCode == 3 and planStateCode[1] != 3
planStateShiftAlert = barstate.isconfirmed and not na(planStateCode[1]) and planStateCode != planStateCode[1]
planInvalidatedAlert = barstate.isconfirmed and planStateCode == 4 and planStateCode[1] != 4
bullFollowThrough = ta.crossover(close, planTarget)
bearFollowThrough = ta.crossunder(close, planTarget)
majorFollowThroughAlert = barstate.isconfirmed and ((planDir == 1 and bullFollowThrough) or (planDir == -1 and bearFollowThrough))
pdhBreak = ta.crossover(close, pdh)
pdlBreak = ta.crossunder(close, pdl)
projectedHighBreak = ta.crossover(close, projHigh)
projectedLowBreak = ta.crossunder(close, projLow)
pdhBreakAlert = barstate.isconfirmed and pdhBreak
pdlBreakAlert = barstate.isconfirmed and pdlBreak
projectedHighBreakAlert = barstate.isconfirmed and projectedHighBreak
projectedLowBreakAlert = barstate.isconfirmed and projectedLowBreak

alertcondition(confirmedRefresh, title = "New Daily Plan Generated",
     message = "{{ticker}} — New daily trade plan generated. Bias: review panel. Expected range updated.")

alertcondition(planReadyAlert,
     title = "Daily Plan Became Active",
     message = "{{ticker}} — Daily plan became Active. Review plan quality, risk line, and target room.")

alertcondition(planStateShiftAlert,
     title = "Daily Plan State Shift",
     message = "{{ticker}} — Daily plan state changed. Review the panel and chart plan zone.")

alertcondition(planInvalidatedAlert,
     title = "Daily Plan Invalidated",
     message = "{{ticker}} — Daily plan invalidation reference was crossed. Reset the plan context.")

alertcondition(majorFollowThroughAlert,
     title = "Daily Plan Follow-Through Event",
     message = "{{ticker}} — Price reached the active plan follow-through reference. Reassess target room.")

alertcondition(pdhBreakAlert,
     title = "Price Broke PDH",
     message = "{{ticker}} — Price broke above Previous Day High ({{close}}). Primary scenario may be active.")
alertcondition(pdlBreakAlert,
     title = "Price Broke PDL",
     message = "{{ticker}} — Price broke below Previous Day Low ({{close}}). Bearish scenario may be active.")

alertcondition(projectedHighBreakAlert,
     title = "Price Exceeded Projected High",
     message = "{{ticker}} — Price exceeded projected daily high ({{close}}). Volatility expansion.")
alertcondition(projectedLowBreakAlert,
     title = "Price Exceeded Projected Low",
     message = "{{ticker}} — Price exceeded projected daily low ({{close}}). Volatility expansion.")
````
