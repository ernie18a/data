# Stablecoin Liquidity Pulse Map [AGPro Series]

- url: https://www.tradingview.com/script/lwAkmKDg-Stablecoin-Liquidity-Pulse-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;714792b49ebf4873a002cd5fffc1c462
- version: 4.0

## Description

Stablecoin Liquidity Pulse Map [AGPro Series]

🧠 Core Idea

Is stablecoin liquidity expanding into the market, parking defensively on the sidelines, or drying up before risk appetite weakens?


📌 Overview / What it does

Stablecoin Liquidity Pulse Map [AGPro Series] is a crypto market-context tool that maps stablecoin liquidity flow, stablecoin dominance pressure, and risk-appetite behavior into a clean visual pulse framework.

The script reads USDT and USDC market-cap sources, optionally includes DAI, compares stablecoin flow against broader crypto market-cap context, and converts those inputs into liquidity pulse states.

It produces a right-side liquidity pulse ribbon, pulse tracks, selective event labels, optional compact markers, and an AG Pro dashboard panel. It does not predict price, automate trades, or claim that stablecoin growth must immediately create a bullish market.


🎯 Purpose & Design Philosophy

Stablecoins are one of the most important liquidity layers in crypto.

When stablecoin supply expands, capital may be entering or preparing to rotate. When stablecoin dominance rises while price weakens, capital may be parking defensively. When stablecoin flow contracts, risk liquidity can become thinner.

This script was built to turn that macro liquidity layer into a practical chart-reading tool without pretending that liquidity alone is a complete trading system.


⚡ Why This Script Is Different

Most tools focus on price, trend, volatility, or exchange-specific derivatives data.

This script does NOT focus on funding, open interest, basis, leverage reset, liquidation levels, or ordinary trend signals.

Instead, it studies the stablecoin liquidity layer behind the market. It asks whether stablecoin flow, dominance pressure, and price behavior are aligned with expansion, defensive parking, dry liquidity, or early rotation.


⚙️ Methodology

1. Stablecoin Flow Detection

The script reads USDT and USDC market-cap data, with optional DAI inclusion.

2. Dominance Pressure Mapping

It compares stablecoin value against total crypto market-cap context when available.

3. Risk-Appetite Evaluation

It evaluates whether price is behaving constructively or defensively relative to a baseline.

4. Pulse Classification

The script combines flow, velocity, dominance pressure, parking risk, dry-liquidity behavior, and rotation context into a single liquidity pulse state.


🗺️ How to Read the Chart

The right-side pulse ribbon is the main visual object.

The center ribbon shows the active liquidity pulse state.

The upper ribbon tracks stablecoin flow and expansion pressure.

The lower ribbon helps identify parking or dry-liquidity pressure.

The vertical needle shows where the current pulse sits inside the active liquidity range.

Event labels identify important state changes such as Liquidity Inflow, Risk-Off Parking, Dry Liquidity, or Rotation Ready.

The panel summarizes state, pulse, stable flow, velocity, dominance, dominance change, direction, grade, risk parking, dry score, and data-source availability.


🚦 Signals & States

• Liquidity Expansion → stablecoin flow is improving while dominance pressure is not defensive

• Risk-Off Parking → stablecoin dominance pressure is rising while market appetite weakens

• Dry Liquidity → stablecoin flow is contracting and liquidity conditions may be thinner

• Rotation Ready → stablecoin flow improves while market behavior begins to recover

• Neutral Pulse → no strong stablecoin liquidity state is active

• Data Missing → selected stablecoin sources are unavailable


🔔 Alerts Logic

Alerts can be enabled for Liquidity Expansion, Risk-Off Parking, Dry Liquidity, and Rotation Ready.

Each alert triggers when the selected state becomes active. Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest reads happen when stablecoin flow, velocity, dominance behavior, and price context align.

For example, rising stablecoin flow with falling defensive dominance pressure can support a constructive liquidity read.

Rising stablecoin dominance while price weakens can suggest defensive parking rather than active risk appetite.


📊 When to Use

• Crypto market-cycle analysis

• BTC and ETH context checks

• Stablecoin liquidity monitoring

• Risk-on / risk-off environment review

• Macro crypto liquidity dashboards

• 1D and 1W chart analysis


⚠️ When NOT to Use

• Very low liquidity altcoins as the only decision source

• Symbols where stablecoin market-cap data does not load

• Extremely noisy intraday charts

• Situations requiring exact exchange order flow

• Any workflow that expects a standalone buy/sell signal


🎛️ Key Inputs

• USDT Market Cap Symbol → primary stablecoin source

• USDC Market Cap Symbol → secondary stablecoin source

• Include DAI Source → optional additional stablecoin component

• Total Crypto Market Cap Symbol → used for dominance pressure

• Liquidity Flow Length → controls stablecoin flow measurement

• Pulse Baseline Length → controls slower liquidity and trend context

• Inflow / Outflow Thresholds → control state sensitivity

• Dominance Pressure Threshold → controls risk-off parking sensitivity

• Visual settings → control ribbon, event labels, tracks, markers, panel, and font sizes


🖥️ Interface & Visual Design

The design is intentionally different from derivatives-focused maps.

It avoids large projected zones, liquidation paths, reset ladders, and basis meters.

The right-side pulse ribbon keeps the visual focused on liquidity context rather than exact price levels. Colors remain visible on both dark and white chart backgrounds, and the panel follows the AG Pro merged-header format.


🧪 Practical Usage Workflow

1. Read the panel state first.

2. Confirm USDT and USDC sources are active.

3. Check stable flow and dominance change.

4. Review the right-side pulse ribbon.

5. Compare the state with price structure and broader market trend.

6. Use alerts as attention markers, not trade instructions.


🔍 Interpretation Guidelines

Liquidity Expansion does not guarantee upside.

Risk-Off Parking does not guarantee downside.

Dry Liquidity does not guarantee immediate volatility.

Rotation Ready means conditions are improving, not that a rotation must occur.

Use the script as a market-context layer alongside structure, trend, volatility, and disciplined risk management.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an automated trading system.

It is not an exact order-flow tool.

It does not guarantee market direction.


⚠️ Limitations & Transparency

Stablecoin market-cap symbols depend on TradingView data availability.

Total crypto market-cap data may not be available in every environment.

Stablecoin supply changes can lag market behavior.

Different timeframes can produce different interpretations.

Extreme events, exchange stress, depegs, or abnormal data conditions can affect readings.


🧠 Market Context Notes

Stablecoin liquidity is not automatically bullish or bearish.

The meaning depends on context. Stablecoins can represent incoming buying power, defensive parking, cash rotation, or liquidity withdrawal.

This script focuses on interpreting that context more clearly.


🧾 Use Case Examples

When stablecoin flow rises and defensive dominance pressure is low, the script may show Liquidity Expansion.

When stablecoin dominance rises while price weakens, it may show Risk-Off Parking.

When stablecoin flow contracts and market appetite is weak, it may show Dry Liquidity.

When stablecoin flow improves with early market recovery, it may show Rotation Ready.


🧱 System Philosophy

AGProLabs scripts are built as structured decision-support tools.

The goal is to make hidden market context easier to read, not to replace judgment with certainty.


🔐 Non-Promise Statement

No liquidity model can remove uncertainty.

No state should be treated as certainty.

No visual element should replace trader judgment.


📉 Risk Disclosure

Trading involves risk.

Crypto markets can be highly volatile and liquidity conditions can change quickly.

This script is for educational and analytical purposes only.

Nothing in this script should be interpreted as financial advice, investment advice, or a guaranteed trading outcome.

Users remain fully responsible for their own decisions.


📚 Educational Note

Use this script to study how stablecoin supply, stablecoin dominance, and risk appetite interact across crypto market cycles.

## Source Code

````pine
// --------------------------------------------------
// Stablecoin Liquidity Pulse Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Stablecoin Liquidity Pulse Map tracks stablecoin liquidity pressure,
// stablecoin dominance behavior, defensive parking, dry liquidity, rotation
// context, and risk-appetite recovery through a chart-first, fully labeled
// liquidity pulse system. It scores the pulse 0-100, gives a clear next action, and proves
// how often each liquidity state was confirmed by the chart symbol's
// follow-through. It is an analytical visualization map for crypto market
// context, not a prediction engine, automated strategy, or financial advice.
// --------------------------------------------------

//@version=6
indicator("Stablecoin Liquidity Pulse Map [AGPro Series]",
     shorttitle = "AG Pro SLP",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 160,
     max_boxes_count = 4)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_DATA = "Liquidity Data"
string G_ENGINE = "Pulse Engine"
string G_VISUAL = "Visual Design"
string G_PANEL = "Panel"
string G_ALERTS = "Alerts"

string usdtSymbol = input.symbol("CRYPTOCAP:USDT", "USDT Market Cap Symbol", group = G_DATA,
     tooltip = "Primary stablecoin market-cap source used in the liquidity pulse calculation.")
string usdcSymbol = input.symbol("CRYPTOCAP:USDC", "USDC Market Cap Symbol", group = G_DATA,
     tooltip = "Secondary stablecoin market-cap source used in the liquidity pulse calculation.")
bool includeDai = input.bool(false, "Include DAI Source", group = G_DATA,
     tooltip = "Adds the DAI market-cap source when available. Default is off to keep the core map focused on USDT and USDC.")
string daiSymbol = input.symbol("CRYPTOCAP:DAI", "DAI Market Cap Symbol", group = G_DATA,
     tooltip = "Optional DAI market-cap source.")
string totalMarketSymbol = input.symbol("CRYPTOCAP:TOTAL", "Total Crypto Market Cap Symbol", group = G_DATA,
     tooltip = "Used to estimate stablecoin dominance pressure. If unavailable, the script still uses stablecoin flow and price context.")

int flowLen = input.int(21, "Liquidity Flow Length", minval = 5, maxval = 120, group = G_ENGINE,
     tooltip = "Measures stablecoin market-cap change across a rolling window.")
int baselineLen = input.int(55, "Pulse Baseline Length", minval = 10, maxval = 220, group = G_ENGINE,
     tooltip = "Controls the slower baseline used for liquidity and trend context.")
int atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = G_ENGINE,
     tooltip = "Measures chart volatility for spacing and visual scaling.")
float inflowThreshold = input.float(0.75, "Inflow Threshold %", minval = 0.05, maxval = 10.0, step = 0.05, group = G_ENGINE,
     tooltip = "Stablecoin market-cap growth required before liquidity inflow becomes meaningful.")
float outflowThreshold = input.float(0.45, "Outflow Threshold %", minval = 0.05, maxval = 10.0, step = 0.05, group = G_ENGINE,
     tooltip = "Stablecoin market-cap contraction required before dry-liquidity conditions become meaningful.")
float dominanceThreshold = input.float(0.25, "Dominance Pressure Threshold", minval = 0.02, maxval = 5.0, step = 0.01, group = G_ENGINE,
     tooltip = "Stablecoin dominance increase required before risk-off parking becomes relevant.")
int persistenceBars = input.int(8, "Persistence Bars", minval = 3, maxval = 40, group = G_ENGINE,
     tooltip = "Measures whether liquidity conditions are persistent instead of one-bar noise.")
int proofWindowBars = input.int(12, "Signal Proof Window", minval = 4, maxval = 80, group = G_ENGINE,
     tooltip = "Bars over which each liquidity-state signal is checked against the chart symbol's follow-through move. Feeds the Signal Hit proof.")
float proofMoveAtr = input.float(0.6, "Signal Proof Move ATR", minval = 0.10, maxval = 3.0, step = 0.05, group = G_ENGINE,
     tooltip = "Favorable or adverse move (in ATR) used to resolve whether a liquidity-state signal was confirmed by price. Risk-on states expect price up; risk-off states expect price down.")

bool showPulseRibbon = input.bool(true, "Show Liquidity Pulse Ribbon", group = G_VISUAL,
     tooltip = "Shows a fully labeled right-side State, Pulse, Flow, and Pressure ribbon.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows selective event labels for major liquidity-flow changes.")
bool showPulseTracks = input.bool(true, "Show Pulse Tracks", group = G_VISUAL,
     tooltip = "Shows liquidity pulse and parking-pressure tracks on price.")
bool showPulseMarkers = input.bool(false, "Show Compact Pulse Markers", group = G_VISUAL,
     tooltip = "Optional compact markers for liquidity events. Default is off for a cleaner publication screenshot.")
bool showBarColors = input.bool(false, "Color Bars by Pulse State", group = G_VISUAL,
     tooltip = "Optionally colors candles by liquidity state.")
int ribbonBars = input.int(30, "Ribbon Projection Bars", minval = 10, maxval = 100, group = G_VISUAL,
     tooltip = "Controls how far the right-side pulse ribbon extends.")
int labelCooldownBars = input.int(28, "Event Label Cooldown", minval = 5, maxval = 100, group = G_VISUAL,
     tooltip = "Controls spacing between event labels.")
int maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 30, group = G_VISUAL,
     tooltip = "Limits event-label count to preserve a premium chart while keeping the liquidity story visible.")
float labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, centered ribbon label, and right-side tag font size.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls dashboard panel location.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard panel theme while keeping the standard AG Pro blue header row.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

bool alertExpansion = input.bool(true, "Alert: Liquidity Expansion", group = G_ALERTS,
     tooltip = "Triggers when stablecoin liquidity expansion aligns with improving risk-appetite context.")
bool alertParking = input.bool(true, "Alert: Risk-Off Parking", group = G_ALERTS,
     tooltip = "Triggers when stablecoin dominance pressure suggests defensive parking behavior.")
bool alertDry = input.bool(true, "Alert: Dry Liquidity", group = G_ALERTS,
     tooltip = "Triggers when stablecoin liquidity contraction becomes meaningful.")
bool alertRotation = input.bool(true, "Alert: Rotation Ready", group = G_ALERTS,
     tooltip = "Triggers when stablecoin flow improves while risk appetite begins to recover.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = color.rgb(15, 23, 42)
color panelBorder = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)
color parkingColor = color.rgb(56, 189, 248)
color dryColor = color.rgb(248, 113, 113)
color rotationColor = color.rgb(45, 212, 191)
color darkText = color.rgb(15, 23, 42)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float low, float high) =>
    math.min(math.max(nz(value, low), low), high)

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, value == 0.0 ? "#.##" : "#.###") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

f_panel_bg(string themeInput) =>
    themeInput == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeInput) =>
    themeInput == "Light" ? color.rgb(148, 163, 184) : color.rgb(86, 103, 130)

f_panel_label(string themeInput) =>
    themeInput == "Light" ? color.rgb(71, 85, 105) : color.rgb(190, 202, 220)

f_panel_value(string themeInput) =>
    themeInput == "Light" ? darkText : color.rgb(245, 247, 250)

f_row_bg(string themeInput, int row) =>
    bool evenRow = row % 2 == 0
    if themeInput == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_text_on(color bgCol) =>
    float r = color.r(bgCol)
    float g = color.g(bgCol)
    float b = color.b(bgCol)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_state_color(string stateName) =>
    switch stateName
        "Liquidity Expansion" => bullColor
        "Risk-Off Parking" => parkingColor
        "Dry Liquidity" => dryColor
        "Rotation Ready" => rotationColor
        "Data Missing" => neutralColor
        => accentColor

f_panel_state_color(color baseColor, string themeInput) =>
    if themeInput == "Light"
        baseColor
    else if baseColor == accentColor
        color.rgb(165, 180, 252)
    else if baseColor == neutralColor
        color.rgb(251, 191, 36)
    else if baseColor == parkingColor
        color.rgb(125, 211, 252)
    else if baseColor == rotationColor
        color.rgb(94, 234, 212)
    else
        baseColor

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput, alignValue) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignValue)

f_set_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeInput, string sizeInput) =>
    color rowBg = f_row_bg(themeInput, row)
    f_panel_cell(panelRef, 0, row, leftText, f_panel_label(themeInput), rowBg, sizeInput, text.align_left)
    f_panel_cell(panelRef, 1, row, rightText, f_panel_state_color(rightColor, themeInput), rowBg, sizeInput, text.align_right)

f_set_label(label labelRef, int x, float y, string txt, color bgCol, labelStyle, string sizeInput) =>
    label.set_x(labelRef, x)
    label.set_y(labelRef, y)
    label.set_text(labelRef, txt)
    label.set_color(labelRef, bgCol)
    label.set_textcolor(labelRef, f_text_on(bgCol))
    label.set_style(labelRef, labelStyle)
    label.set_size(labelRef, f_size(sizeInput))

f_event_label(array<label> labelArray, int x, float y, string txt, color bgCol, bool upward, string sizeInput, int maxCount) =>
    label newLabel = label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, color = color.new(bgCol, 5), textcolor = f_text_on(bgCol), size = f_size(sizeInput))
    array.push(labelArray, newLabel)
    if array.size(labelArray) > maxCount
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

// --------------------------------------------------
// Data Engine
// --------------------------------------------------
float usdtCap = request.security(usdtSymbol, timeframe.period, close, ignore_invalid_symbol = true)
float usdcCap = request.security(usdcSymbol, timeframe.period, close, ignore_invalid_symbol = true)
float daiCapRaw = request.security(daiSymbol, timeframe.period, close, ignore_invalid_symbol = true)
float totalCap = request.security(totalMarketSymbol, timeframe.period, close, ignore_invalid_symbol = true)

bool dataReady = not na(usdtCap) or not na(usdcCap) or (includeDai and not na(daiCapRaw))
float stableCap = dataReady ? nz(usdtCap, 0.0) + nz(usdcCap, 0.0) + (includeDai ? nz(daiCapRaw, 0.0) : 0.0) : na
float stableBase = not na(stableCap[flowLen]) and stableCap[flowLen] > 0.0 ? stableCap[flowLen] : na
float stableChange = not na(stableBase) ? (stableCap - stableBase) / stableBase * 100.0 : na
float stableFast = ta.ema(stableCap, math.max(3, int(math.round(flowLen * 0.50))))
float stableSlow = ta.ema(stableCap, baselineLen)
float stableVelocity = not na(stableFast) and not na(stableSlow) and stableSlow > 0.0 ? (stableFast - stableSlow) / stableSlow * 100.0 : na

float stableDominance = dataReady and not na(totalCap) and totalCap > 0.0 ? stableCap / totalCap * 100.0 : na
float dominanceBase = not na(stableDominance[flowLen]) ? stableDominance[flowLen] : na
float dominanceChange = not na(dominanceBase) ? stableDominance - dominanceBase : na

float safeAtr = math.max(nz(ta.atr(atrLen), high - low), syminfo.mintick)
float priceBase = ta.ema(close, baselineLen)
float priceDistance = safeAtr > 0.0 ? (close - priceBase) / safeAtr : 0.0
float priceMomentum = safeAtr > 0.0 ? (ta.ema(close, math.max(3, int(math.round(flowLen * 0.50)))) - priceBase) / safeAtr : 0.0

float inflowScore = not na(stableChange) ? f_clamp((stableChange + outflowThreshold) / (inflowThreshold + outflowThreshold) * 100.0, 0.0, 100.0) : 50.0
float velocityScore = not na(stableVelocity) ? f_clamp((stableVelocity + 1.25) / 2.50 * 100.0, 0.0, 100.0) : 50.0
float dominanceStress = not na(dominanceChange) ? f_clamp((dominanceChange + dominanceThreshold) / (dominanceThreshold * 2.0) * 100.0, 0.0, 100.0) : 50.0
float appetiteScore = f_clamp((priceDistance + priceMomentum + 4.0) / 8.0 * 100.0, 0.0, 100.0)
float rotationScore = f_clamp((inflowScore * 0.38) + ((100.0 - dominanceStress) * 0.32) + (appetiteScore * 0.30), 0.0, 100.0)
float parkingScore = f_clamp((dominanceStress * 0.50) + ((100.0 - appetiteScore) * 0.34) + (math.max(0.0, 50.0 - inflowScore) * 0.16), 0.0, 100.0)
float dryScore = f_clamp(((100.0 - inflowScore) * 0.55) + ((100.0 - velocityScore) * 0.25) + ((100.0 - appetiteScore) * 0.20), 0.0, 100.0)
float liquidityPulse = f_clamp((inflowScore * 0.36) + (velocityScore * 0.24) + ((100.0 - dominanceStress) * 0.20) + (appetiteScore * 0.20), 0.0, 100.0)

bool expansionRaw = dataReady and stableChange >= inflowThreshold and dominanceStress <= 54.0 and liquidityPulse >= 58.0
bool parkingRaw = dataReady and dominanceChange >= dominanceThreshold and parkingScore >= 58.0
bool dryRaw = dataReady and stableChange <= -outflowThreshold and dryScore >= 56.0
bool rotationRaw = dataReady and stableChange > 0.0 and rotationScore >= 60.0 and not expansionRaw

float expansionPersistence = math.sum(expansionRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float parkingPersistence = math.sum(parkingRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float dryPersistence = math.sum(dryRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float rotationPersistence = math.sum(rotationRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0

bool liquidityExpansion = expansionRaw and expansionPersistence >= 25.0
bool riskOffParking = parkingRaw and parkingPersistence >= 25.0
bool dryLiquidity = dryRaw and dryPersistence >= 25.0
bool rotationReady = rotationRaw and rotationPersistence >= 25.0

string stateText = not dataReady ? "Data Missing" :
     liquidityExpansion ? "Liquidity Expansion" :
     riskOffParking ? "Risk-Off Parking" :
     dryLiquidity ? "Dry Liquidity" :
     rotationReady ? "Rotation Ready" : "Neutral Pulse"
color stateColor = f_state_color(stateText)
string directionText = not dataReady ? "Check data" :
     liquidityExpansion ? "Liquidity expanding" :
     riskOffParking ? "Defensive parking" :
     dryLiquidity ? "Liquidity drying" :
     rotationReady ? "Rotation improving" : "Balanced pulse"
string gradeText = not dataReady ? "Missing" :
     liquidityPulse >= 76.0 ? "Strong" :
     liquidityPulse >= 58.0 ? "Constructive" :
     parkingScore >= 62.0 ? "Defensive" :
     dryScore >= 60.0 ? "Thin" : "Neutral"
string nextActionText = not dataReady ? "Check data sources" :
     stateText == "Liquidity Expansion" ? "Risk-on - favor strength" :
     stateText == "Rotation Ready" ? "Rotation building - prepare" :
     stateText == "Risk-Off Parking" ? "Defensive - protect capital" :
     stateText == "Dry Liquidity" ? "Thin tape - reduce size" :
     "Wait - no liquidity edge"

// --------------------------------------------------
// Signal hit-rate proof (Confirm Rate)
// --------------------------------------------------
int biasDir = (stateText == "Liquidity Expansion" or stateText == "Rotation Ready") ? 1 :
     (stateText == "Risk-Off Parking" or stateText == "Dry Liquidity") ? -1 : 0
bool enteredTracked = barstate.isconfirmed and dataReady and biasDir != 0 and stateText != stateText[1]

var int   sigTotal  = 0
var int   sigHit    = 0
var int   pendDir   = 0
var float pendEntry = na
var int   pendLeft  = 0

if barstate.isconfirmed
    if pendLeft > 0
        favMove = pendDir == 1 ? close - pendEntry : pendEntry - close
        target = safeAtr * proofMoveAtr
        if favMove >= target
            sigTotal += 1
            sigHit += 1
            pendDir := 0
            pendLeft := 0
        else if favMove <= -target
            sigTotal += 1
            pendDir := 0
            pendLeft := 0
        else if pendLeft == 1
            sigTotal += 1
            if favMove > 0.0
                sigHit += 1
            pendDir := 0
            pendLeft := 0
        else
            pendLeft -= 1
    if enteredTracked and pendLeft == 0
        pendDir := biasDir
        pendEntry := close
        pendLeft := proofWindowBars

float signalHitRate = sigTotal > 0 ? sigHit / sigTotal * 100.0 : na

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
color hiddenColor = color.new(color.black, 100)
var line stateBeam = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var line pulseBeam = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 4)
var line flowBeam = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = bullColor, style = line.style_dotted, width = 2)
var line pressureBeam = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = neutralColor, style = line.style_solid, width = 2)
var label centerLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal, textalign = text.align_center)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)
var label flowTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bullColor, textcolor = headerText, size = size.normal)
var label pressureTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = neutralColor, textcolor = darkText, size = size.normal)
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var string previousState = "Neutral Pulse"

float visualPulse = dataReady ? math.max(liquidityPulse, math.max(parkingScore, dryScore)) : 40.0
float span = safeAtr * (1.05 + visualPulse / 100.0 * 0.50)
float midY = close
float upperY = close + span * 1.30
float lowerY = close - span * 1.30
float pressureY = lowerY - span * 0.62
int rightX = bar_index + ribbonBars
int startX = bar_index + 3
int labelX = int(math.round((startX + rightX) * 0.50))
color flowColor = stableChange >= 0.0 ? bullColor : bearColor
color pressureColor = parkingScore >= dryScore ? parkingColor : dryColor

if barstate.islast
    if showPulseRibbon
        line.set_xy1(stateBeam, startX + 2, upperY)
        line.set_xy2(stateBeam, rightX, upperY)
        line.set_color(stateBeam, color.new(stateColor, 0))
        line.set_width(stateBeam, 3)
        line.set_xy1(pulseBeam, startX, midY)
        line.set_xy2(pulseBeam, rightX, midY)
        line.set_color(pulseBeam, color.new(stateColor, 0))
        line.set_width(pulseBeam, 4)
        line.set_xy1(flowBeam, startX + 4, lowerY)
        line.set_xy2(flowBeam, rightX, lowerY)
        line.set_color(flowBeam, color.new(flowColor, 0))
        line.set_width(flowBeam, 2)
        line.set_style(flowBeam, line.style_dotted)
        line.set_xy1(pressureBeam, startX + 8, pressureY)
        line.set_xy2(pressureBeam, rightX, pressureY)
        line.set_color(pressureBeam, color.new(pressureColor, 12))
        line.set_width(pressureBeam, 2)

        string centerText = dataReady ? "Liquidity Pulse\n" + f_score(liquidityPulse) + " / 100 - " + gradeText : "Liquidity Data Missing"
        f_set_label(centerLabel, labelX, midY, centerText, color.new(stateColor, 0), label.style_label_center, labelSizeInput)
        f_set_label(stateTag, rightX, upperY, stateText, color.new(stateColor, 0), label.style_label_left, labelSizeInput)
        f_set_label(flowTag, rightX, lowerY, "Flow " + f_pct(stableChange), color.new(flowColor, 0), label.style_label_left, labelSizeInput)
        f_set_label(pressureTag, rightX, pressureY, "Pressure P" + f_score(parkingScore) + " / D" + f_score(dryScore), color.new(pressureColor, 0), label.style_label_left, labelSizeInput)
    else
        line.set_color(stateBeam, hiddenColor)
        line.set_color(pulseBeam, hiddenColor)
        line.set_color(flowBeam, hiddenColor)
        line.set_color(pressureBeam, hiddenColor)
        label.set_text(centerLabel, "")
        label.set_text(stateTag, "")
        label.set_text(flowTag, "")
        label.set_text(pressureTag, "")
        label.set_color(centerLabel, hiddenColor)
        label.set_color(stateTag, hiddenColor)
        label.set_color(flowTag, hiddenColor)
        label.set_color(pressureTag, hiddenColor)

// --------------------------------------------------
// Event Labels and Plots
// --------------------------------------------------
bool canLabel = showEventLabels and dataReady and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
bool newState = stateText != previousState
bool expansionEvent = alertExpansion and liquidityExpansion and canLabel and newState
bool parkingEvent = alertParking and riskOffParking and canLabel and newState
bool dryEvent = alertDry and dryLiquidity and canLabel and newState
bool rotationEvent = alertRotation and rotationReady and canLabel and newState
int pulseCooldown = math.max(10, int(math.round(labelCooldownBars * 0.65)))
bool pulseReady = showPulseMarkers and dataReady and (bar_index % pulseCooldown == 0 or newState)

if expansionEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Liquidity Inflow\nPulse " + f_score(liquidityPulse), bullColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if parkingEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Risk-Off Parking\nScore " + f_score(parkingScore), parkingColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if dryEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Dry Liquidity\nScore " + f_score(dryScore), dryColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if rotationEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Rotation Ready\nPulse " + f_score(liquidityPulse), rotationColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

previousState := stateText

barcolor(showBarColors ? color.new(stateColor, 72) : na)

float pulseTrack = priceBase + safeAtr * ((liquidityPulse - 50.0) / 50.0)
float parkingTrack = priceBase - safeAtr * ((parkingScore - 50.0) / 70.0)
plot(showPulseTracks ? pulseTrack : na, "Liquidity Pulse Track", color = color.new(stateColor, 0), linewidth = 2)
plot(showPulseTracks ? parkingTrack : na, "Parking Pressure Track", color = color.new(accentColor, 20), linewidth = 2)
plotshape(pulseReady and liquidityExpansion, "Liquidity Inflow Pulse", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny, text = "I", textcolor = darkText)
plotshape(pulseReady and riskOffParking, "Risk-Off Parking Pulse", style = shape.triangledown, location = location.abovebar, color = color.new(parkingColor, 0), size = size.tiny, text = "P", textcolor = darkText)
plotshape(pulseReady and dryLiquidity, "Dry Liquidity Pulse", style = shape.square, location = location.abovebar, color = color.new(dryColor, 0), size = size.tiny, text = "D", textcolor = headerText)
plotshape(pulseReady and rotationReady, "Rotation Ready Pulse", style = shape.triangleup, location = location.belowbar, color = color.new(rotationColor, 0), size = size.tiny, text = "R", textcolor = darkText)

// --------------------------------------------------
// Data Window
// --------------------------------------------------
plot(liquidityPulse, "Liquidity Pulse Score", color = stateColor, display = display.data_window)
plot(signalHitRate, "Signal Hit Rate", color = accentColor, display = display.data_window)
plot(stableChange, "Stablecoin Flow Change", color = bullColor, display = display.data_window)
plot(stableVelocity, "Stablecoin Velocity", color = accentColor, display = display.data_window)
plot(dominanceChange, "Stablecoin Dominance Change", color = neutralColor, display = display.data_window)
plot(parkingScore, "Risk-Off Parking Score", color = parkingColor, display = display.data_window)
plot(dryScore, "Dry Liquidity Score", color = dryColor, display = display.data_window)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if na(panel) or panelLocationCache != panelPositionInput or panelThemeCache != panelThemeInput
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPositionInput), 2, 8, bgcolor = f_panel_bg(panelThemeInput), frame_color = f_panel_border(panelThemeInput), frame_width = 1, border_color = f_panel_border(panelThemeInput), border_width = 1)
    panelLocationCache := panelPositionInput
    panelThemeCache := panelThemeInput

string pulseRead = f_score(liquidityPulse) + " / " + gradeText
string flowRead = f_pct(stableChange) + " / Vel " + f_pct(stableVelocity)
string dominanceRead = f_pct(stableDominance) + " / Chg " + f_pct(dominanceChange)
string pressureRead = "Park " + f_score(parkingScore) + " / Dry " + f_score(dryScore)
string sourceRead = (na(usdtCap) ? "USDT n/a" : "USDT active") + " | " + (na(usdcCap) ? "USDC n/a" : "USDC active")
string signalHitText = sigTotal > 0 ? f_score(signalHitRate) + "% (" + str.tostring(sigTotal) + ")" : "Building"
color signalHitColor = na(signalHitRate) ? f_panel_value(panelThemeInput) : signalHitRate >= 55.0 ? bullColor : signalHitRate >= 45.0 ? neutralColor : bearColor

if barstate.islast and not na(panel)
    table.clear(panel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Stablecoin Liquidity Pulse Map", headerText, headerBg, panelFontSizeInput, text.align_center)
        f_set_row(panel, 1, "State", stateText + " / " + pulseRead, stateColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 2, "Next Action", nextActionText, stateColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 3, "Stable Flow", flowRead, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 4, "Dominance", dominanceRead, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 5, "Pressure", pressureRead, parkingScore >= dryScore ? parkingColor : dryColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 6, "Signal Hit", signalHitText, signalHitColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 7, "Sources", sourceRead, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertExpansion and liquidityExpansion and stateText != stateText[1], "Stablecoin Liquidity Expansion", "Stablecoin liquidity expansion is active on {{ticker}}.")
alertcondition(alertParking and riskOffParking and stateText != stateText[1], "Stablecoin Risk-Off Parking", "Stablecoin dominance pressure suggests defensive parking on {{ticker}}.")
alertcondition(alertDry and dryLiquidity and stateText != stateText[1], "Stablecoin Dry Liquidity", "Stablecoin liquidity contraction is active on {{ticker}}.")
alertcondition(alertRotation and rotationReady and stateText != stateText[1], "Stablecoin Rotation Ready", "Stablecoin liquidity flow is improving with rotation context on {{ticker}}.")
````
