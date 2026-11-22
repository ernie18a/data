# Perpetual Basis Drift Map [AGPro Series]

- url: https://www.tradingview.com/script/nhDTQvJc-Perpetual-Basis-Drift-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;9e1a8680b7e04182addbd9386f1c0909
- version: 5.0

## Description

Perpetual Basis Drift Map [AGPro Series]

🧠 Core Idea

Is the perpetual market quietly drifting away from spot, or is the basis relationship compressing back toward neutral?


📌 Overview / What it does

Perpetual Basis Drift Map is a crypto derivatives context tool designed to monitor how the active perpetual or futures market behaves against a matching spot reference.

The script compares the active chart price with an automatically selected spot reference, measures basis percentage, basis drift, normalized basis z-score, drift velocity, persistence, and trend context. It converts that relationship into an open three-rail basis drift meter, state labels, right-side tags, alerts, and an AG Pro dashboard.

It does not read official funding payments, automate trades, predict future price direction, or promise that basis must mean-revert. It is a structured visual map for interpreting perpetual premium, perpetual discount, basis expansion, basis compression, reset, and spot-reference mismatch conditions.


🎯 Purpose & Design Philosophy

This script was built to separate basis drift from generic funding or premium talk.

Funding pressure can be noisy, and a raw premium number is often not enough. Traders need to know whether the relationship between perp/futures and spot is widening, compressing, persisting, or simply resetting.

The design goal is to make basis behavior visible as a chart story, not just a number in a panel.


⚡ Why This Script Is Different

Most tools show a spread or premium value and leave the interpretation to the user.

This script does NOT treat basis as a simple buy or sell signal, does NOT claim that premium must reverse, and does NOT hide reference mismatch risk.

Instead, it maps the basis relationship into states: Positive Drift, Negative Drift, Basis Expansion, Basis Compression, Reset, and Check Spot Ref, while the chart labels use Premium Drift, Discount Drift, Spread Expansion, and Basis Compression for faster visual reading. It uses spot-reference comparison, baseline drift, z-score, velocity, persistence, and trend context together.


⚙️ Methodology

1. Context Detection
The script builds a spot reference from the active chart base currency, selected exchange, and selected quote.

2. Reference Mapping
It compares the active market against the spot reference and calculates basis percentage.

3. Reaction Evaluation
The model evaluates basis drift from baseline, normalized basis z-score, drift velocity, persistence, and trend context.

4. Visual Output
The result is shown as a compact open basis drift meter, centered meter label, right-side tags, event labels, and dashboard panel.


🗺️ How to Read the Chart

The basis drift meter separates the current read into three visible layers: state rail, basis value rail, and pressure score rail. It is intentionally open-ended rather than a closed corridor, so the visual story feels different from zone-first tools.

Labels mark state changes such as Premium Drift, Discount Drift, Spread Expansion, and Basis Compression. Optional compact pulse markers add additional context when premium, discount, expansion, or compression pressure appears without turning the script into a signal engine.

Colors communicate context:
• Teal = positive/perp-premium drift pressure
• Pink = negative/perp-discount drift pressure
• Yellow = spread expansion or reference warning
• Indigo = compression/reset regime

The panel summarizes state, score, basis, basis z-score, velocity, persistence, direction, quality, spot reference, trend, and meter values.


🚦 Signals & States

• Positive Drift → perpetual/futures market is drifting above the spot reference

• Negative Drift → perpetual/futures market is drifting below the spot reference

• Basis Expansion → basis deviation and drift velocity are widening

• Basis Compression → basis deviation is compressing back toward neutral

• Reset → no active drift state is strong enough to dominate the read

• Check Spot Ref → selected spot reference appears mismatched or unavailable


🔔 Alerts Logic

Alerts trigger when the script transitions into selected basis states.

Positive Basis Drift alerts mark meaningful upward perp-versus-spot drift.

Negative Basis Drift alerts mark meaningful downward perp-versus-spot drift.

Basis Expansion alerts mark widening basis deviation and drift velocity.

Basis Compression alerts mark movement back toward a neutral basis relationship.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest context appears when multiple components align:

Basis percentage + normalized basis z-score + drift velocity + persistence + trend context.

When basis widens and persists, the relationship may deserve closer attention. When basis compresses, the market may be returning toward a more neutral perp-versus-spot condition.


📊 When to Use

• Crypto perpetual and futures charts

• Markets where spot reference comparison is meaningful

• Perp/spot monitoring on BTC, ETH, and liquid crypto pairs

• Basis expansion, basis compression, and drift-context analysis

• Sessions where derivatives premium or discount behavior matters


⚠️ When NOT to Use

• Symbols with poor spot-reference alignment

• Illiquid markets with unreliable pricing

• Spot-only charts if the user expects a derivatives basis story

• Extreme news events where spread behavior can become unstable

• Markets where the active symbol and selected reference are not comparable


🎛️ Key Inputs

• Auto Spot Reference → automatically builds a matching spot reference

• Basis Baseline Length → controls how quickly the normal basis relationship adapts

• Basis Normalization Lookback → controls how unusual basis drift must be

• Drift Velocity Lookback → measures whether basis is widening or tightening

• Persistence Window → measures whether basis behavior continues across bars

• Reference Mismatch Guard % → prevents mismatched references from being interpreted as real basis drift

• Visual Settings → control meter projection, labels, right-side tags, and font sizes


🖥️ Interface & Visual Design

The interface is designed around a premium chart-first story.

The basis drift meter provides the main visual anchor. Centered meter text explains the state without relying on weak transparent labels or a large corridor box. Right-side tags keep the current state, basis, and score visible near the active price area.

The panel follows the AG Pro standard with a merged blue header row, adjustable location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Apply the script to a crypto perpetual or futures chart.

2. Keep Auto Spot Reference enabled for the first pass.

3. Confirm the Spot Ref row matches the active market base currency.

4. Read State, Score, Basis, Basis Z, and Velocity.

5. Inspect whether basis is drifting, expanding, compressing, or resetting.

6. Confirm the read with broader market structure, liquidity, volatility, and risk management.


🔍 Interpretation Guidelines

Positive basis drift can show perp premium building, but it does not automatically mean price must fall.

Negative basis drift can show perp discount building, but it does not automatically mean price must rise.

Basis expansion is a context marker, not a trade instruction.

Basis compression can indicate normalization, but normalization does not guarantee direction.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto trading system.

This script is not a guaranteed signal engine.

This script does not read official funding payments directly.

This script does not claim that basis drift must immediately reverse.


⚠️ Limitations & Transparency

The script estimates basis from active-symbol versus spot-reference price behavior.

Reference quality matters. If the selected reference is wrong or unavailable, the script shows Check Spot Ref rather than presenting the spread as valid basis drift.

Different exchanges, contract types, liquidity conditions, and timeframes can produce different basis behavior.

Very low basis values can be visually clean but may not produce a dramatic story.


🧠 Market Context Notes

Perpetual basis can help traders understand whether derivatives pricing is leaning above or below spot.

The value of this tool is strongest when combined with structure, volatility, liquidity, open interest, and disciplined risk management.

Basis tells context. It does not create certainty.


🧾 Use Case Examples

When a perpetual chart trades persistently above spot and basis velocity expands, the script may classify Positive Drift or Basis Expansion.

When a perpetual chart trades persistently below spot and basis velocity expands downward, the script may classify Negative Drift.

When basis returns toward its baseline, Basis Compression can help show normalization.


🧱 System Philosophy

Perpetual Basis Drift Map follows the AGProLabs principle of building decision-support maps rather than prediction tools.

The script is designed to make hidden derivatives context easier to see, not to replace judgment.


🔐 Non-Promise Statement

No basis model can guarantee future price direction.

No drift score removes uncertainty.

This tool helps organize context; it does not create certainty.


📉 Risk Disclosure

Trading involves risk.

Crypto derivatives can be highly volatile and may involve leverage, liquidation risk, exchange risk, funding-cost changes, and rapid market movement.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use the script as a learning layer for understanding how perpetual premium, perpetual discount, basis drift, basis velocity, and spot-reference behavior can combine into a cleaner derivatives-context read.

## Source Code

````pine
// --------------------------------------------------
// Perpetual Basis Drift Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.6
//
// Perpetual Basis Drift Map is a crypto derivatives context indicator built to
// track how the active perpetual or futures market drifts against a matching
// spot reference. It maps positive basis drift, negative basis drift, basis
// expansion, compression, reset, and reference mismatch conditions through an
// open three-rail basis meter, readable state labels, right-side tags, and a
// compact AG Pro panel. Version 1.5 strengthens basis integrity, confirmed-close
// state handling, and visual separation without changing the core use case.
// --------------------------------------------------

//@version=6
indicator("Perpetual Basis Drift Map [AGPro Series]",
     shorttitle = "AG Pro PBD",
     overlay = true,
     max_boxes_count = 10,
     max_lines_count = 80,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_BASIS = "Basis Drift Engine"
string G_PRICE = "Price Context"
string G_VISUAL = "Visual Design"
string G_PANEL = "Panel"
string G_ALERTS = "Alerts"

bool useAutoSpotReference = input.bool(true, "Auto Spot Reference", group = G_BASIS,
     tooltip = "Automatically builds a spot reference from the chart base currency, selected exchange, and selected quote. This keeps ETH perpetual charts on an ETH spot reference and BTC perpetual charts on a BTC spot reference.")
string referenceExchange = input.string("BINANCE", "Reference Exchange", options = ["BINANCE", "BYBIT", "OKX", "COINBASE", "KRAKEN"], group = G_BASIS,
     tooltip = "Exchange prefix used when Auto Spot Reference is enabled.")
string referenceQuote = input.string("USDT", "Reference Quote", options = ["USDT", "USD", "USDC", "BTC", "ETH"], group = G_BASIS,
     tooltip = "Quote currency used when Auto Spot Reference is enabled.")
bool enforceQuoteMatch = input.bool(true, "Require Matching Quote", group = G_BASIS,
     tooltip = "Requires the automatic spot reference quote currency to match the chart quote currency. This prevents quote-currency differences from being interpreted as perpetual basis.")
string manualSpotReferenceSymbol = input.symbol("BINANCE:BTCUSDT", "Manual Spot Reference Symbol", group = G_BASIS,
     tooltip = "Manual reference symbol used only when Auto Spot Reference is disabled.")
int basisBaselineLength = input.int(34, "Basis Baseline Length", minval = 5, maxval = 300, group = G_BASIS,
     tooltip = "EMA length used to define the normal basis relationship between the active market and the spot reference.")
int basisNormLookback = input.int(120, "Basis Normalization Lookback", minval = 30, maxval = 500, group = G_BASIS,
     tooltip = "Lookback used to normalize basis drift into a z-score.")
int driftLookback = input.int(8, "Drift Velocity Lookback", minval = 1, maxval = 80, group = G_BASIS,
     tooltip = "Number of bars used to measure whether basis is drifting wider or tighter.")
int persistenceBars = input.int(10, "Persistence Window", minval = 3, maxval = 80, group = G_BASIS,
     tooltip = "Number of bars used to evaluate whether basis drift is persistent rather than isolated.")
float basisThreshold = input.float(0.020, "Minimum Basis Threshold %", minval = 0.001, maxval = 5.0, step = 0.001, group = G_BASIS,
     tooltip = "Minimum absolute basis percentage required before basis direction becomes meaningful.")
float zThreshold = input.float(0.65, "Basis Drift Z Threshold", minval = 0.10, maxval = 5.0, step = 0.05, group = G_BASIS,
     tooltip = "Minimum normalized basis deviation required before drift states can become active.")
float referenceMismatchLimit = input.float(20.0, "Reference Mismatch Guard %", minval = 2.0, maxval = 80.0, step = 1.0, group = G_BASIS,
     tooltip = "If the active symbol differs too much from the selected spot reference, the script shows a reference warning instead of treating the spread as real basis drift.")
float compressionZMax = input.float(0.55, "Compression Z Max", minval = 0.05, maxval = 2.5, step = 0.05, group = G_BASIS,
     tooltip = "Maximum normalized basis deviation allowed before the script stops treating the market as basis compression.")
int reversionWindow = input.int(20, "Reversion Proof Window (bars)", minval = 4, maxval = 200, group = G_BASIS,
     tooltip = "Number of bars an active drift or expansion has to reset toward neutral within, for the Reversion Rate proof. It only measures historical mean-reversion and is not a forecast.")
float reversionWidenMargin = input.float(0.60, "Reversion Widen Margin (Z)", minval = 0.10, maxval = 3.0, step = 0.05, group = G_BASIS,
     tooltip = "How much further, in normalized basis units, drift must extend past its starting level to count as a continuation instead of a reset. Larger values make the Reversion Rate proof more lenient. It only measures historical behavior and is not a forecast.")

int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 200, group = G_PRICE,
     tooltip = "ATR length used for drift meter width, price movement normalization, and label spacing.")
int trendFastLength = input.int(21, "Fast Trend Length", minval = 2, maxval = 300, group = G_PRICE,
     tooltip = "Fast EMA used to read near-term price acceptance around basis drift.")
int trendSlowLength = input.int(55, "Slow Trend Length", minval = 3, maxval = 500, group = G_PRICE,
     tooltip = "Slow EMA used to read broader trend context around basis drift.")
int minDriftScore = input.int(36, "Minimum Drift Score", minval = 1, maxval = 100, group = G_PRICE,
     tooltip = "Minimum score required before positive drift, negative drift, expansion, or compression states become active.")

bool showDriftZone = input.bool(true, "Show Basis Drift Meter", group = G_VISUAL,
     tooltip = "Shows an open three-rail basis meter that separates state, basis value, and pressure score without using a closed corridor box.")
bool showPriceTracks = input.bool(true, "Show Price Context Tracks", group = G_VISUAL,
     tooltip = "Shows the fast and slow price-context tracks independently of the active basis drift meter.")
bool showCenterLabel = input.bool(true, "Show Centered Meter Label", group = G_VISUAL,
     tooltip = "Shows a compact centered label on the basis drift meter.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows positive drift, negative drift, expansion, compression, reset, and reference labels.")
bool showPulseMarkers = input.bool(false, "Show Basis Pulse Markers", group = G_VISUAL,
     tooltip = "Shows compact pulse markers when basis pressure, expansion, or compression regimes become active. This adds visual context without turning the script into a signal system.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for state, basis value, and drift score on the meter rails.")
bool showBarColors = input.bool(false, "Color Bars By Basis State", group = G_VISUAL,
     tooltip = "Lightly colors bars by basis drift state. Disabled by default to keep the chart clean.")
int projectionBars = input.int(44, "Meter Projection Bars", minval = 10, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far the basis meter and right-side tags are projected to the right.")
int meterHistoryBars = input.int(38, "Meter History Bars", minval = 8, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how many recent bars the open basis meter covers. Shorter values keep it visually distinct from broad corridor-style zones.")
int labelCooldownBars = input.int(32, "Event Label Cooldown", minval = 5, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum number of bars between repeated event labels.")
int maxEventLabels = input.int(9, "Maximum Event Labels", minval = 4, maxval = 40, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
float labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based distance used to keep event labels away from candles.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, meter label, and right-side tag font size.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro basis drift panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls where the AG Pro dashboard panel appears on the chart.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls the panel color theme while keeping the standard AG Pro blue header row.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

bool alertPositiveDrift = input.bool(true, "Alert: Positive Basis Drift", group = G_ALERTS,
     tooltip = "Enables alerts when perpetual basis drifts meaningfully above the spot reference.")
bool alertNegativeDrift = input.bool(true, "Alert: Negative Basis Drift", group = G_ALERTS,
     tooltip = "Enables alerts when perpetual basis drifts meaningfully below the spot reference.")
bool alertExpansion = input.bool(true, "Alert: Basis Expansion", group = G_ALERTS,
     tooltip = "Enables alerts when basis deviation and drift velocity expand together.")
bool alertCompression = input.bool(true, "Alert: Basis Compression", group = G_ALERTS,
     tooltip = "Enables alerts when basis deviation compresses back toward neutral.")

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
color resetColor = color.rgb(79, 70, 229)
color darkText = color.rgb(15, 23, 42)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    float safeValue = na(value) ? minValue : value
    math.max(minValue, math.min(maxValue, safeValue))

f_size(string sizeName) =>
    switch sizeName
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string posName) =>
    switch posName
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
    na(value) ? "n/a" : str.tostring(value, "#.####") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_action_text(string s) =>
    s == "Check Spot Ref" ? "Match Reference" :
     s == "Spot - No Basis" ? "Load Perp Symbol" :
     s == "Positive Drift" ? "Track Premium Drift" :
     s == "Negative Drift" ? "Track Discount Drift" :
     s == "Basis Expansion" ? "Watch Expansion" :
     s == "Basis Compression" ? "Watch Reset" :
     "Wait Drift"

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string themeName) =>
    themeName == "Light" ? color.rgb(148, 163, 184) : color.rgb(86, 103, 130)

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : color.rgb(190, 202, 220)

f_panel_value(string themeName) =>
    themeName == "Light" ? darkText : color.rgb(245, 247, 250)

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_panel_state_color(color baseColor, string themeName) =>
    if themeName == "Light"
        baseColor
    else if baseColor == resetColor
        color.rgb(167, 139, 250)
    else if baseColor == accentColor
        color.rgb(165, 180, 252)
    else if baseColor == neutralColor
        color.rgb(251, 191, 36)
    else
        baseColor

f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_state_color(string stateName) =>
    switch stateName
        "Positive Drift" => bullColor
        "Negative Drift" => bearColor
        "Basis Expansion" => neutralColor
        "Basis Compression" => accentColor
        "Check Spot Ref" => neutralColor
        "Spot - No Basis" => accentColor
        "Reset" => resetColor
        => neutralColor

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput, alignValue) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignValue)

f_set_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    f_panel_cell(panelRef, 0, row, leftText, f_panel_label(themeName), rowBg, sizeInput, text.align_left)
    f_panel_cell(panelRef, 1, row, rightText, f_panel_state_color(rightColor, themeName), rowBg, sizeInput, text.align_right)

f_set_label(label lbl, int x, float y, string txt, color bg, labelStyle, string sizeInput) =>
    label.set_x(lbl, x)
    label.set_y(lbl, y)
    label.set_text(lbl, txt)
    label.set_color(lbl, bg)
    label.set_textcolor(lbl, f_text_on(bg))
    label.set_style(lbl, labelStyle)
    label.set_size(lbl, f_size(sizeInput))

f_keep_label(array<label> labelStore, label newLabel, int limit) =>
    array.push(labelStore, newLabel)
    if array.size(labelStore) > limit
        label oldLabel = array.shift(labelStore)
        label.delete(oldLabel)

f_event_label(array<label> labelStore, int x, float y, string txt, color bg, bool up, string sizeInput, int limit) =>
    label newLabel = label.new(x, y, txt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = up ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(bg),
         color = color.new(bg, 5),
         size = f_size(sizeInput))
    f_keep_label(labelStore, newLabel, limit)
    newLabel

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
string autoSpotReferenceSymbol = referenceExchange + ":" + syminfo.basecurrency + referenceQuote
string activeSpotReference = useAutoSpotReference ? autoSpotReferenceSymbol : manualSpotReferenceSymbol
float spotCloseRaw = request.security(activeSpotReference, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
bool spotAvailable = not na(spotCloseRaw)
float spotClose = nz(spotCloseRaw, close)
float safeSpot = math.max(spotClose, syminfo.mintick)

float basisPct = (close / safeSpot - 1.0) * 100.0
bool chartQuoteKnown = str.length(syminfo.currency) > 0
bool quoteMismatch = enforceQuoteMatch and useAutoSpotReference and chartQuoteKnown and referenceQuote != syminfo.currency
bool refMismatch = quoteMismatch or math.abs(basisPct) > referenceMismatchLimit or not spotAvailable
bool validBasisRead = not refMismatch
float basisBase = ta.ema(basisPct, basisBaselineLength)
float basisDrift = basisPct - nz(basisBase, basisPct)
float basisDevRaw = ta.stdev(basisPct, basisNormLookback)
float basisDev = math.max(nz(basisDevRaw, 0.0), 0.0001)
float basisZ = basisDrift / basisDev
float maxAbsBasis = ta.highest(math.abs(basisPct), basisNormLookback)
bool spotSelf = validBasisRead and nz(maxAbsBasis, 0.0) < 0.01
float basisVelocity = basisPct - nz(basisPct[driftLookback], basisPct)
float basisVelocityAbs = math.abs(basisVelocity)

float atr = ta.atr(atrLength)
float safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
float fast = ta.ema(close, trendFastLength)
float slow = ta.ema(close, trendSlowLength)
bool trendUp = fast > slow and close > slow
bool trendDown = fast < slow and close < slow

bool positiveRaw = validBasisRead and basisPct > basisThreshold and basisZ > zThreshold and basisVelocity > 0.0
bool negativeRaw = validBasisRead and basisPct < -basisThreshold and basisZ < -zThreshold and basisVelocity < 0.0
bool wideningBasis = validBasisRead and basisZ * basisVelocity > 0.0
bool expansionRaw = validBasisRead and math.abs(basisZ) > zThreshold and basisVelocityAbs > basisThreshold and wideningBasis
bool compressionRaw = validBasisRead and math.abs(basisZ) <= compressionZMax and basisVelocityAbs <= basisThreshold * 1.5

float positivePersistence = math.sum(positiveRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float negativePersistence = math.sum(negativeRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float expansionPersistence = math.sum(expansionRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float compressionPersistence = math.sum(compressionRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
float activePersistence = math.max(math.max(positivePersistence, negativePersistence), math.max(expansionPersistence, compressionPersistence))

float basisScore = f_clamp(math.abs(basisPct) / math.max(basisThreshold * 7.0, 0.001) * 100.0, 0.0, 100.0)
float zScore = f_clamp(math.abs(basisZ) / 2.8 * 100.0, 0.0, 100.0)
float velocityScore = f_clamp(basisVelocityAbs / math.max(basisThreshold * 5.0, 0.001) * 100.0, 0.0, 100.0)
float trendScore = trendUp or trendDown ? 64.0 : 38.0
float persistenceScore = f_clamp(activePersistence, 0.0, 100.0)
float driftScore = validBasisRead ? f_clamp(basisScore * 0.24 + zScore * 0.24 + velocityScore * 0.20 + persistenceScore * 0.24 + trendScore * 0.08, 0.0, 100.0) : 0.0

bool positiveDrift = positiveRaw and driftScore >= minDriftScore
bool negativeDrift = negativeRaw and driftScore >= minDriftScore
bool basisExpansion = expansionRaw and driftScore >= minDriftScore and not positiveDrift and not negativeDrift
bool basisCompression = compressionRaw and driftScore >= minDriftScore * 0.45 and not spotSelf

string stateText = refMismatch ? "Check Spot Ref" :
     spotSelf ? "Spot - No Basis" :
     positiveDrift ? "Positive Drift" :
     negativeDrift ? "Negative Drift" :
     basisExpansion ? "Basis Expansion" :
     basisCompression ? "Basis Compression" : "Reset"
color stateColor = f_state_color(stateText)

string directionText = refMismatch ? "Match spot ref" :
     spotSelf ? "No perp basis" :
     positiveDrift ? "Perp premium" :
     negativeDrift ? "Perp discount" :
     basisExpansion ? "Basis widening" :
     basisCompression ? "Basis compressing" : "No active drift"

string qualityText = refMismatch ? "Ref warning" :
     spotSelf ? "Spot" :
     basisCompression ? "Compressed" :
     driftScore >= 78.0 ? "Extreme" :
     driftScore >= 64.0 ? "Elevated" :
     driftScore >= 45.0 ? "Watch" : "Low"

string actionImperative = f_action_text(stateText)

// --------------------------------------------------
// Reversion-rate proof (Confirm Rate)
// --------------------------------------------------
// When an active drift or expansion regime begins, does basis reset back toward
// neutral (|z| <= compression max) before it widens to a meaningfully larger
// extreme (continuation)? Counted once per drift episode. Widening first, or a
// window expiry with no reset, is treated as not-reverted (conservative).
bool driftActive = positiveDrift or negativeDrift or basisExpansion
bool driftActivePrev = bar_index > 0 ? driftActive[1] : false
bool driftFired = driftActive and not driftActivePrev

var int   brTotal = 0
var int   brWon    = 0
var bool  brPend    = false
var int   brLeft     = 0
var float brAnchorZ   = na

if barstate.isconfirmed
    if brPend and not na(brAnchorZ)
        bool widened = math.abs(basisZ) >= brAnchorZ + reversionWidenMargin
        bool reverted = math.abs(basisZ) <= compressionZMax
        if widened
            brTotal += 1
            brPend := false
        else if reverted
            brTotal += 1
            brWon += 1
            brPend := false
        else
            brLeft -= 1
            if brLeft <= 0
                brTotal += 1
                brPend := false
    if driftFired and validBasisRead and not spotSelf and not brPend
        brPend := true
        brAnchorZ := math.abs(basisZ)
        brLeft := reversionWindow

float brRate = brTotal > 0 ? brWon / brTotal * 100.0 : na
string reversionRead = brTotal > 0 ? str.tostring(math.round(brRate)) + "% (" + str.tostring(brTotal) + ")" : "Building"
color reversionColor = na(brRate) ? panelValueCol : brRate >= 60.0 ? bullColor : brRate >= 45.0 ? neutralColor : bearColor

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
color hiddenColor = color.new(color.black, 100)
var line premiumRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var line basisRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var line pressureRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = neutralColor, style = line.style_solid, width = 3)
var line leftBracket = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 2)
var line rightBracket = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 2)
var line driftNeedle = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 2)
var label centerLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = headerText, size = f_size(labelSizeInput), textalign = text.align_center)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = accentColor, textcolor = headerText, size = f_size(labelSizeInput))
var label basisTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = accentColor, textcolor = headerText, size = f_size(labelSizeInput))
var label scoreTag = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = neutralColor, textcolor = darkText, size = f_size(labelSizeInput))
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var string previousState = "Reset"

float visualScore = refMismatch ? 22.0 : driftScore
float ladderSpan = safeAtr * (0.72 + visualScore / 100.0 * 0.90)
float zoneTop = close + ladderSpan
float zoneBottom = close - ladderSpan
float zoneMid = close
int rightX = bar_index + projectionBars
int leftX = bar_index - meterHistoryBars
int labelX = int(math.round(leftX + (rightX - leftX) * 0.60))
int railStep = math.max(3, int(math.round(meterHistoryBars * 0.16)))
int middleRailStartX = leftX + railStep
int pressureRailStartX = leftX + railStep * 2

if barstate.islast
    if showDriftZone
        line.set_xy1(premiumRail, leftX, zoneTop)
        line.set_xy2(premiumRail, rightX, zoneTop)
        line.set_color(premiumRail, color.new(stateColor, 0))
        line.set_width(premiumRail, 3)
        line.set_style(premiumRail, line.style_solid)

        line.set_xy1(basisRail, middleRailStartX, zoneMid)
        line.set_xy2(basisRail, rightX, zoneMid)
        line.set_color(basisRail, color.new(accentColor, 0))
        line.set_width(basisRail, 2)
        line.set_style(basisRail, line.style_dotted)

        line.set_xy1(pressureRail, pressureRailStartX, zoneBottom)
        line.set_xy2(pressureRail, rightX, zoneBottom)
        line.set_color(pressureRail, color.new(neutralColor, 0))
        line.set_width(pressureRail, 3)
        line.set_style(pressureRail, line.style_solid)

        line.set_xy1(leftBracket, leftX, zoneBottom)
        line.set_xy2(leftBracket, leftX, zoneTop)
        line.set_color(leftBracket, hiddenColor)

        line.set_xy1(rightBracket, rightX, zoneBottom)
        line.set_xy2(rightBracket, rightX, zoneTop)
        line.set_color(rightBracket, hiddenColor)

        line.set_xy1(driftNeedle, bar_index, zoneBottom)
        line.set_xy2(driftNeedle, bar_index, zoneTop)
        line.set_color(driftNeedle, validBasisRead ? color.new(stateColor, 0) : hiddenColor)
        line.set_width(driftNeedle, 2)

        if showCenterLabel
            string centerText = refMismatch ? "Check Spot Reference" : spotSelf ? "Spot Symbol - Load a Perp Chart" : "Basis Meter | " + qualityText + " | " + f_score(driftScore)
            f_set_label(centerLabel, labelX, zoneMid, centerText, color.new(stateColor, 0), label.style_label_center, labelSizeInput)
        else
            label.set_text(centerLabel, "")
    else
        line.set_color(premiumRail, hiddenColor)
        line.set_color(basisRail, hiddenColor)
        line.set_color(pressureRail, hiddenColor)
        line.set_color(leftBracket, hiddenColor)
        line.set_color(rightBracket, hiddenColor)
        line.set_color(driftNeedle, hiddenColor)
        label.set_text(centerLabel, "")

    if showRightTags
        string basisText = refMismatch ? "Ref Mismatch" : "Basis " + f_pct(basisPct)
        string scoreText = refMismatch ? "Set Matching Spot" : spotSelf ? "Spot" : "Score " + f_score(driftScore)
        f_set_label(stateTag, rightX, zoneTop, stateText, stateColor, label.style_label_left, labelSizeInput)
        f_set_label(basisTag, rightX, zoneMid, basisText, accentColor, label.style_label_left, labelSizeInput)
        f_set_label(scoreTag, rightX, zoneBottom, scoreText, neutralColor, label.style_label_left, labelSizeInput)
    else
        label.set_text(stateTag, "")
        label.set_text(basisTag, "")
        label.set_text(scoreTag, "")

bool canLabel = barstate.isconfirmed and showEventLabels and validBasisRead and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
bool newState = stateText != previousState
bool positiveEvent = alertPositiveDrift and positiveDrift and canLabel and newState
bool negativeEvent = alertNegativeDrift and negativeDrift and canLabel and newState
bool expansionEvent = alertExpansion and basisExpansion and canLabel and newState
bool compressionEvent = alertCompression and basisCompression and canLabel and newState
int basisPulseCooldown = math.max(8, int(math.round(labelCooldownBars * 0.50)))
bool pulseReady = barstate.isconfirmed and showPulseMarkers and validBasisRead and (bar_index % basisPulseCooldown == 0 or newState)
bool premiumPulse = pulseReady and positiveDrift
bool discountPulse = pulseReady and negativeDrift
bool expansionPulse = pulseReady and basisExpansion and not positiveDrift and not negativeDrift
bool compressionPulse = pulseReady and basisCompression and not basisExpansion and not positiveDrift and not negativeDrift

if positiveEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Premium Drift\nScore " + f_score(driftScore), bullColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if negativeEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Discount Drift\nScore " + f_score(driftScore), bearColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if expansionEvent
    bool upExpansion = basisVelocity >= 0.0
    float expansionY = upExpansion ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, bar_index, expansionY, "Spread Expansion\nScore " + f_score(driftScore), neutralColor, upExpansion, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if compressionEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Basis Compression\nScore " + f_score(driftScore), accentColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

if barstate.isconfirmed
    previousState := stateText

barcolor(showBarColors ? color.new(stateColor, 72) : na)
plotshape(premiumPulse, "Premium Basis Pulse", style = shape.diamond, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny, text = "P", textcolor = headerText)
plotshape(discountPulse, "Discount Basis Pulse", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny, text = "D", textcolor = headerText)
plotshape(expansionPulse, "Basis Expansion Pulse", style = shape.circle, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny, text = "E", textcolor = darkText)
plotshape(compressionPulse, "Basis Compression Pulse", style = shape.square, location = location.belowbar, color = color.new(accentColor, 0), size = size.tiny, text = "C", textcolor = headerText)
plot(showPriceTracks and validBasisRead ? fast : na, "Basis Reaction Track", color = color.new(stateColor, 0), linewidth = 2)
plot(showPriceTracks and validBasisRead ? slow : na, "Basis Baseline Track", color = color.new(accentColor, 35), linewidth = 2)

// --------------------------------------------------
// Data Window
// --------------------------------------------------
plot(driftScore, "Basis Drift Score", color = stateColor, display = display.data_window)
plot(basisPct, "Basis Percent", color = accentColor, display = display.data_window)
plot(basisZ, "Basis Z Score", color = neutralColor, display = display.data_window)
plot(basisVelocity, "Basis Velocity", color = bullColor, display = display.data_window)
plot(activePersistence, "Basis Persistence", color = bearColor, display = display.data_window)
plot(brRate, "Basis Reversion Rate", color = bullColor, display = display.data_window)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if na(panel) or panelLocationCache != panelPositionInput or panelThemeCache != panelThemeInput
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPositionInput), 2, 7, bgcolor = f_panel_bg(panelThemeInput), frame_color = f_panel_border(panelThemeInput), frame_width = 1, border_color = f_panel_border(panelThemeInput), border_width = 1)
    panelLocationCache := panelPositionInput
    panelThemeCache := panelThemeInput

string scoreRead = spotSelf ? "Spot reference" : validBasisRead ? f_score(driftScore) + " / " + qualityText : "n/a / Ref warning"
string basisRead = refMismatch ? "Ref mismatch" : f_pct(basisPct) + " / Z " + str.tostring(basisZ, "#.##")
string velocityRead = validBasisRead ? f_pct(basisVelocity) + " / P " + f_score(activePersistence) : "n/a"
string referenceRead = quoteMismatch ? activeSpotReference + " / Quote mismatch" : activeSpotReference

if barstate.islast and not na(panel)
    table.clear(panel, 0, 0, 1, 6)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Perpetual Basis Drift Map", headerText, headerBg, panelFontSizeInput, text.align_center)
        f_set_row(panel, 1, "State", stateText + " / " + scoreRead, stateColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 2, "Reversion Rate", reversionRead, reversionColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 3, "Basis", basisRead, validBasisRead ? f_panel_value(panelThemeInput) : neutralColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 4, "Velocity", velocityRead, validBasisRead ? f_panel_value(panelThemeInput) : neutralColor, panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 5, "Spot Reference", referenceRead, refMismatch ? neutralColor : f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_set_row(panel, 6, "Action", actionImperative, stateColor, panelThemeInput, panelFontSizeInput)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(barstate.isconfirmed and alertPositiveDrift and positiveDrift and stateText != stateText[1], "Positive Basis Drift", "Perpetual basis is drifting meaningfully above the spot reference on confirmed close for {{ticker}}.")
alertcondition(barstate.isconfirmed and alertNegativeDrift and negativeDrift and stateText != stateText[1], "Negative Basis Drift", "Perpetual basis is drifting meaningfully below the spot reference on confirmed close for {{ticker}}.")
alertcondition(barstate.isconfirmed and alertExpansion and basisExpansion and stateText != stateText[1], "Basis Expansion", "Perpetual basis deviation and velocity are widening together on confirmed close for {{ticker}}.")
alertcondition(barstate.isconfirmed and alertCompression and basisCompression and stateText != stateText[1], "Basis Compression", "Perpetual basis is compressing back toward neutral on confirmed close for {{ticker}}.")
````
