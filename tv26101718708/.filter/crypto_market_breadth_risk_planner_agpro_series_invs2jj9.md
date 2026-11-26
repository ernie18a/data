# Crypto Market Breadth Risk Planner [AGPro Series]

- url: https://www.tradingview.com/script/Invs2JJ9-Crypto-Market-Breadth-Risk-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;958ac238313d4ac0ae679404b031b010
- version: 5.0

## Description

Crypto Market Breadth Risk Planner [AGPro Series]


🧠 Core Idea

Is the crypto market showing broad risk-on participation, weakening rotation, or a risk-off breadth environment?


📌 Overview / What it does

Crypto Market Breadth Risk Planner [AGPro Series] is a chart-first market breadth tool built to evaluate whether a selected crypto basket is participating broadly or weakening internally.

Instead of reading only the active chart symbol, the script reviews a configurable basket of major crypto pairs. It measures how many symbols are trading above their trend baseline, how many have positive momentum, how many have rising trend structure, and how much volatility stress is present across the basket.

The script produces a 0-100 Breadth Risk Score, a colored breadth risk corridor on the active chart, event labels, right-side tags, alerts, and a compact AG Pro panel. It does not predict price direction, automate execution, or claim that breadth alone is enough to trade.


🎯 Purpose & Design Philosophy

This script was built because single-chart analysis can look strong while the broader crypto market is quietly weakening, or look weak while breadth is beginning to rotate back into strength.

The purpose is to help traders read market participation before treating an individual setup as clean. Strong setups usually have a better context when the broader basket is aligned, while weaker breadth can warn that a chart may be more exposed to false follow-through.

The design supports traders who want broader market context without opening ten charts manually. It turns cross-market participation into a simple decision-support layer that can be read directly on the current chart.


⚡ Why This Script Is Different

Most crypto tools focus on the active symbol, a single benchmark, a simple correlation reading, or a raw relative-strength line.

This script does NOT act as a benchmark correlation meter, a relative-strength rotation map, a volume spike detector, or a generic trend dashboard.

Instead, it evaluates breadth across a user-defined crypto basket and converts that participation into a risk-readiness framework. The goal is not to say which coin to buy or sell. The goal is to show whether the broader crypto environment is supportive, mixed, stressed, or risk-off.


⚙️ Methodology

1. Context Detection
The script requests data from a configurable crypto basket and evaluates each symbol on the selected breadth timeframe.

2. Reference Mapping
Each symbol is compared against its own trend baseline, momentum reading, trend slope, and ATR-based volatility stress condition.

3. Reaction Evaluation
The script combines trend participation, momentum participation, slope confirmation, and volatility stress into a single Breadth Risk Score.

4. Visual Output
The final output includes a colored breadth risk corridor, centered corridor text, event labels, right-side tags, optional bar coloring, alerts, and an AG Pro panel.


🗺️ How to Read the Chart

Zones:
The breadth risk corridor is a visual context zone around price. Its color reflects the current breadth regime rather than a direct support or resistance level.

Labels:
Labels mark important breadth state transitions such as Risk-On, Rotation Watch, Risk-Off, Stress Review, and Cooling.

Colors:
Teal represents broad constructive participation.
Pink represents risk-off breadth or weak participation.
Gold represents stress or caution.
Indigo represents improving rotation or transitional breadth.

Panel:
The panel summarizes breadth participation, Breadth Risk Score, momentum, stress, regime, and action state.


🚦 Signals & States

• Risk-On Ready → Broad participation and momentum are strong enough to support risk-on review.
• Rotation Watch → Breadth is improving, but not yet strong enough for full risk-on classification.
• Stress Review → Volatility stress is elevated while breadth quality remains weak.
• Risk-Off → Basket participation is weak or deteriorating.
• Cooling → Stress is easing while breadth quality begins to improve.
• Wait Breadth → No strong breadth regime is currently active.


🔔 Alerts Logic

Alerts can trigger when the basket shifts into Risk-On, Rotation Watch, Risk-Off, Stress Review, or Cooling.

Alerts are attention markers only. They highlight changes in the breadth model. They are not trade instructions, automated entries, or guaranteed market calls.


🧩 Confluence Logic

The context becomes stronger when multiple breadth layers align together.

For example, a high Breadth Risk Score with many symbols above their trend baselines, positive momentum participation, rising trend slopes, and low stress suggests a cleaner risk-on environment than a rally led by only one or two symbols.

Likewise, weak participation combined with elevated stress can warn that individual bullish setups may need stricter review.


📊 When to Use

• Crypto market context review
• BTC, ETH, altcoin, and sector-style crypto watchlists
• 1H, 4H, and 1D market participation analysis
• Before treating individual setups as risk-on
• When the trader wants to know whether the broader crypto basket supports the active chart


⚠️ When NOT to Use

• Markets where selected symbols have unreliable data
• Very small or illiquid crypto pairs with distorted candles
• Situations where the basket does not match the user's trading universe
• Low-timeframe scalping where external-symbol breadth may be too slow
• News-driven events where correlation and breadth can change abruptly


🎛️ Key Inputs

• Crypto Basket Symbols → define the assets used in the breadth model
• Breadth Timeframe → controls whether the basket is evaluated on chart timeframe, 1H, 4H, or 1D
• Trend Baseline Length → controls the EMA reference used for participation
• Momentum Length → controls the ROC window used for positive or negative participation
• ATR Stress Threshold → controls when basket volatility begins to count as stress
• Minimum Risk-On Score → controls how selective the risk-on state should be
• Visual Settings → control corridor, labels, right-side tags, panel location, theme, and font size


🖥️ Interface & Visual Design

The interface is designed to make broad crypto participation readable without turning the chart into a large dashboard.

The corridor gives a fast visual state directly on the chart. The panel provides the structured readout. Labels mark only important transitions, while cooldown and memory controls keep historical events from overwhelming the chart.

The visual intent is premium, clean, and publication-friendly.


🧪 Practical Usage Workflow

1. Read the panel to identify the current breadth regime.
2. Check the Breadth Risk Score and participation percentage.
3. Review whether momentum and stress support or conflict with the active chart setup.
4. Use the corridor color as a market-context layer, not as a direct entry zone.
5. Combine breadth context with price structure, volatility, liquidity, and personal risk rules.


🔍 Interpretation Guidelines

A strong score means the selected crypto basket is broadly aligned according to the script's rules.

A Rotation Watch state means breadth is improving, but the market has not fully confirmed broad risk-on participation.

A Stress Review state means volatility pressure is elevated while breadth remains weak or mixed.

A Risk-Off state means the selected basket is not supporting broad participation under the current settings.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an automated trading system.

This script does not place orders.

This script does not guarantee market direction, continuation, reversal, or profitability.


⚠️ Limitations & Transparency

This script depends on the selected symbols, selected timeframe, and TradingView data availability.

Different baskets can produce different breadth readings. A BTC-heavy basket may behave differently from an altcoin-heavy basket. External symbol data may also load differently depending on market, exchange, and TradingView availability.

The script should be interpreted as market context, not as a standalone execution model.


🧠 Market Context Notes

Crypto often moves through participation waves. Sometimes BTC leads while altcoins lag. Sometimes the whole market rotates together. Sometimes volatility rises while breadth deteriorates, creating a more fragile environment.

This script is designed to make that internal participation easier to observe directly from the active chart.


🧾 Use Case Examples

Example 1:
BTC is breaking higher, but the panel shows weak breadth and high stress. The trader may decide that the move needs extra confirmation before treating it as broad risk-on.

Example 2:
ETH is consolidating, but the basket shifts into Rotation Watch with improving momentum. The trader can monitor whether the active chart begins to align with the broader rotation.

Example 3:
The basket prints Risk-Off while an individual altcoin setup looks technically clean. The script warns that the broader market backdrop is not supportive under the current model.


🧱 System Philosophy

AGPro Series tools are built as decision-support frameworks, not signal vending machines.

This script follows that philosophy by turning broad market participation into a structured context layer: define the basket, score the breadth, map the state, and show the next action clearly.


🔐 Non-Promise Statement

This script does not promise certainty.

It does not promise that a risk-on breadth state will produce gains, or that a risk-off state will produce losses. It only organizes participation context so the user can evaluate the broader market with more clarity.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly, and breadth models can fail or become less useful during sudden volatility, exchange-specific moves, or news-driven repricing. Users remain responsible for their own decisions, execution, and risk management.

This script is for educational and analytical purposes only. It does not provide financial advice.


📚 Educational Note

Use this tool to study how crypto breadth changes before, during, and after major market moves.

Its strongest value comes from comparing the active chart with the broader basket context rather than reading any single label in isolation.

## Source Code

````pine
// --------------------------------------------------
// Crypto Market Breadth Risk Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Crypto Market Breadth Risk Planner studies whether a selected crypto basket
// is showing broad participation, weakening rotation, risk-off behavior, or
// stress. It converts cross-market trend alignment, momentum participation,
// and volatility stress into a 0-100 Breadth Risk Score. Version 1.3 adds a
// confirmation-anchored proof layer (Follow, Hold, React, Flip rates) that
// measures how reliably each classified breadth regime persisted before it
// changed, without altering the core breadth model.
// --------------------------------------------------

//@version=6
indicator("Crypto Market Breadth Risk Planner [AGPro Series]",
     shorttitle = "AG Pro CBR",
     overlay = true,
     max_boxes_count = 30,
     max_lines_count = 80,
     max_labels_count = 180)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_BASKET = "Crypto Basket"
G_ENGINE = "Breadth Engine"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_PROOF = "Proof"
G_ALERTS = "Alerts"

symbol1 = input.symbol("BINANCE:BTCUSDT", "Symbol 1", group = G_BASKET,
     tooltip = "First symbol used in the crypto breadth basket.")
symbol2 = input.symbol("BINANCE:ETHUSDT", "Symbol 2", group = G_BASKET,
     tooltip = "Second symbol used in the crypto breadth basket.")
symbol3 = input.symbol("BINANCE:BNBUSDT", "Symbol 3", group = G_BASKET,
     tooltip = "Third symbol used in the crypto breadth basket.")
symbol4 = input.symbol("BINANCE:SOLUSDT", "Symbol 4", group = G_BASKET,
     tooltip = "Fourth symbol used in the crypto breadth basket.")
symbol5 = input.symbol("BINANCE:XRPUSDT", "Symbol 5", group = G_BASKET,
     tooltip = "Fifth symbol used in the crypto breadth basket.")
symbol6 = input.symbol("BINANCE:ADAUSDT", "Symbol 6", group = G_BASKET,
     tooltip = "Sixth symbol used in the crypto breadth basket.")
symbol7 = input.symbol("BINANCE:DOGEUSDT", "Symbol 7", group = G_BASKET,
     tooltip = "Seventh symbol used in the crypto breadth basket.")
symbol8 = input.symbol("BINANCE:AVAXUSDT", "Symbol 8", group = G_BASKET,
     tooltip = "Eighth symbol used in the crypto breadth basket.")
symbol9 = input.symbol("BINANCE:LINKUSDT", "Symbol 9", group = G_BASKET,
     tooltip = "Ninth symbol used in the crypto breadth basket.")
symbol10 = input.symbol("BINANCE:LTCUSDT", "Symbol 10", group = G_BASKET,
     tooltip = "Tenth symbol used in the crypto breadth basket.")

breadthTimeframeInput = input.string("Chart", "Breadth Timeframe", options = ["Chart", "1H", "4H", "1D"], group = G_ENGINE,
     tooltip = "Timeframe used to evaluate all basket symbols. Chart uses the current chart timeframe.")
trendLength = input.int(55, "Trend Baseline Length", minval = 5, maxval = 300, group = G_ENGINE,
     tooltip = "EMA length used to decide whether each basket symbol is trading above or below its trend baseline.")
momentumLength = input.int(14, "Momentum Length", minval = 2, maxval = 100, group = G_ENGINE,
     tooltip = "ROC length used to evaluate whether each basket symbol has positive or negative participation momentum.")
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "ATR length used for basket volatility stress and chart corridor sizing.")
stressThreshold = input.float(5.0, "ATR Stress Threshold %", minval = 0.5, maxval = 30.0, step = 0.25, group = G_ENGINE,
     tooltip = "Average ATR percent level where the basket begins to contribute meaningful stress to the risk model.")
minRiskOnScore = input.int(68, "Minimum Risk-On Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum 0-100 score required before the basket can be classified as Risk-On.")
minRotationScore = input.int(54, "Minimum Rotation Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum 0-100 score required before the basket can be treated as a constructive rotation watch.")
riskOffScore = input.int(38, "Risk-Off Score", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Score at or below this level classifies the basket as Risk-Off.")

showBreadthCorridor = input.bool(true, "Show Breadth Risk Corridor", group = G_VISUAL,
     tooltip = "Shows a forward risk corridor around price, colored by the active breadth regime.")
showCorridorText = input.bool(true, "Show Centered Corridor Text", group = G_VISUAL,
     tooltip = "Shows centered text inside the breadth risk corridor.")
showBreadthMean = input.bool(true, "Show Corridor Midline", group = G_VISUAL,
     tooltip = "Shows the midpoint used to frame the visual breadth risk corridor.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows risk-on, rotation, risk-off, stress, and cooling labels on the chart.")
showRiskOnLabels = input.bool(true, "Show Risk-On Labels", group = G_VISUAL,
     tooltip = "Shows labels when the basket shifts into a broad risk-on condition.")
showRotationLabels = input.bool(true, "Show Rotation Labels", group = G_VISUAL,
     tooltip = "Shows labels when breadth improves enough for constructive rotation review.")
showRiskOffLabels = input.bool(true, "Show Risk-Off Labels", group = G_VISUAL,
     tooltip = "Shows labels when breadth deteriorates into a risk-off condition.")
showStressLabels = input.bool(true, "Show Stress Labels", group = G_VISUAL,
     tooltip = "Shows labels when volatility stress rises while breadth quality is weak.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for workflow, breadth, score, and basket stress.")
rightTagOffsetBars = input.int(18, "Right Tag Offset Bars", minval = 4, maxval = 60, group = G_VISUAL,
     tooltip = "Horizontal offset for the right-side workflow tags. Increase it if tags overlap the corridor or price scale.")
showBarColors = input.bool(false, "Color Bars By Regime", group = G_VISUAL,
     tooltip = "Colors chart bars lightly according to the active breadth risk regime.")
projectionBars = input.int(76, "Projection Bars", minval = 5, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for the projected corridor and right-side tags.")
corridorAtr = input.float(0.55, "Corridor Height ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR height used to draw the visual breadth risk corridor around the local price mean.")
labelCooldownBars = input.int(24, "Label Cooldown Bars", minval = 1, maxval = 120, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
eventMemoryBars = input.int(120, "Event Label Memory Bars", minval = 20, maxval = 1000, group = G_VISUAL,
     tooltip = "Maximum age of historical event labels. Older breadth events are removed so the chart remains focused.")
labelOffsetAtr = input.float(0.92, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

showProof = input.bool(true, "Show Proof Layer", group = G_PROOF,
     tooltip = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates measured across classified breadth regimes on the current symbol and timeframe. Each time a regime is recorded, the proof checks how long that classification persisted: React, Follow, and Hold mean the regime survived the reaction window, half the horizon, and the full horizon unchanged, while Flip means it changed within the horizon. These are historical persistence rates, not predictions.")
proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 5, maxval = 240, group = G_PROOF,
     tooltip = "Number of bars each recorded breadth regime is tracked to measure how long the classification persisted before it changed.")
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 60, group = G_PROOF,
     tooltip = "Number of bars a regime must persist unchanged to count as an early React.")

alertRiskOn = input.bool(true, "Alert: Risk-On", group = G_ALERTS,
     tooltip = "Enables alerts when the basket shifts into broad risk-on participation.")
alertRotation = input.bool(true, "Alert: Rotation Watch", group = G_ALERTS,
     tooltip = "Enables alerts when breadth improves into constructive rotation watch.")
alertRiskOff = input.bool(true, "Alert: Risk-Off", group = G_ALERTS,
     tooltip = "Enables alerts when the basket deteriorates into risk-off conditions.")
alertStress = input.bool(true, "Alert: Stress Review", group = G_ALERTS,
     tooltip = "Enables alerts when volatility stress rises while breadth quality is weak.")
alertCooling = input.bool(false, "Alert: Stress Cooling", group = G_ALERTS,
     tooltip = "Enables alerts when stress begins cooling after a stressed breadth regime.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(19, 29, 48) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_action_text(string state) =>
    switch state
        "Risk-On Breadth" => "REVIEW RISK-ON"
        "Rotation Watch" => "TRACK ROTATION"
        "Stress Review" => "CHECK STRESS"
        "Risk-Off Breadth" => "RISK-OFF REVIEW"
        "Cooling" => "CHECK COOLING"
        => "WAIT BREADTH"

f_state_short(string state) =>
    switch state
        "Risk-On Breadth" => "RISK-ON"
        "Rotation Watch" => "ROTATION"
        "Stress Review" => "STRESS"
        "Risk-Off Breadth" => "RISK-OFF"
        "Cooling" => "COOLING"
        => "MIXED"

f_set_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, bool altRow, string fontSize) =>
    rowBg = f_panel_bg(isLight, altRow)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(isLight), bgcolor = rowBg, text_size = f_size(fontSize))
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(fontSize), text_halign = text.align_right)

f_price(float value) =>
    str.tostring(value, format.mintick)

f_tf(string tfInput) =>
    switch tfInput
        "1H" => "60"
        "4H" => "240"
        "1D" => "D"
        => timeframe.period

f_symbol_data(string sym, string tf) =>
    request.security(sym, tf, [close, ta.ema(close, trendLength), ta.ema(close, trendLength)[1], ta.roc(close, momentumLength), ta.atr(atrLength) / math.max(close, 0.0000001) * 100.0], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

f_valid(float c, float e, float ep, float r, float a) =>
    not na(c) and not na(e) and not na(ep) and not na(r) and not na(a)

f_vote(bool condition, bool valid) =>
    valid ? (condition ? 1.0 : 0.0) : 0.0

// --------------------------------------------------
// Basket calculations
// --------------------------------------------------
breadthTf = f_tf(breadthTimeframeInput)
[c1, e1, ep1, r1, a1] = f_symbol_data(symbol1, breadthTf)
[c2, e2, ep2, r2, a2] = f_symbol_data(symbol2, breadthTf)
[c3, e3, ep3, r3, a3] = f_symbol_data(symbol3, breadthTf)
[c4, e4, ep4, r4, a4] = f_symbol_data(symbol4, breadthTf)
[c5, e5, ep5, r5, a5] = f_symbol_data(symbol5, breadthTf)
[c6, e6, ep6, r6, a6] = f_symbol_data(symbol6, breadthTf)
[c7, e7, ep7, r7, a7] = f_symbol_data(symbol7, breadthTf)
[c8, e8, ep8, r8, a8] = f_symbol_data(symbol8, breadthTf)
[c9, e9, ep9, r9, a9] = f_symbol_data(symbol9, breadthTf)
[c10, e10, ep10, r10, a10] = f_symbol_data(symbol10, breadthTf)

v1 = f_valid(c1, e1, ep1, r1, a1)
v2 = f_valid(c2, e2, ep2, r2, a2)
v3 = f_valid(c3, e3, ep3, r3, a3)
v4 = f_valid(c4, e4, ep4, r4, a4)
v5 = f_valid(c5, e5, ep5, r5, a5)
v6 = f_valid(c6, e6, ep6, r6, a6)
v7 = f_valid(c7, e7, ep7, r7, a7)
v8 = f_valid(c8, e8, ep8, r8, a8)
v9 = f_valid(c9, e9, ep9, r9, a9)
v10 = f_valid(c10, e10, ep10, r10, a10)

validCount = (v1 ? 1.0 : 0.0) + (v2 ? 1.0 : 0.0) + (v3 ? 1.0 : 0.0) + (v4 ? 1.0 : 0.0) + (v5 ? 1.0 : 0.0) + (v6 ? 1.0 : 0.0) + (v7 ? 1.0 : 0.0) + (v8 ? 1.0 : 0.0) + (v9 ? 1.0 : 0.0) + (v10 ? 1.0 : 0.0)
validSafe = math.max(validCount, 1.0)

trendVotes = f_vote(c1 > e1, v1) + f_vote(c2 > e2, v2) + f_vote(c3 > e3, v3) + f_vote(c4 > e4, v4) + f_vote(c5 > e5, v5) + f_vote(c6 > e6, v6) + f_vote(c7 > e7, v7) + f_vote(c8 > e8, v8) + f_vote(c9 > e9, v9) + f_vote(c10 > e10, v10)
slopeVotes = f_vote(e1 > ep1, v1) + f_vote(e2 > ep2, v2) + f_vote(e3 > ep3, v3) + f_vote(e4 > ep4, v4) + f_vote(e5 > ep5, v5) + f_vote(e6 > ep6, v6) + f_vote(e7 > ep7, v7) + f_vote(e8 > ep8, v8) + f_vote(e9 > ep9, v9) + f_vote(e10 > ep10, v10)
momentumVotes = f_vote(r1 > 0.0, v1) + f_vote(r2 > 0.0, v2) + f_vote(r3 > 0.0, v3) + f_vote(r4 > 0.0, v4) + f_vote(r5 > 0.0, v5) + f_vote(r6 > 0.0, v6) + f_vote(r7 > 0.0, v7) + f_vote(r8 > 0.0, v8) + f_vote(r9 > 0.0, v9) + f_vote(r10 > 0.0, v10)
stressVotes = f_vote(a1 >= stressThreshold, v1) + f_vote(a2 >= stressThreshold, v2) + f_vote(a3 >= stressThreshold, v3) + f_vote(a4 >= stressThreshold, v4) + f_vote(a5 >= stressThreshold, v5) + f_vote(a6 >= stressThreshold, v6) + f_vote(a7 >= stressThreshold, v7) + f_vote(a8 >= stressThreshold, v8) + f_vote(a9 >= stressThreshold, v9) + f_vote(a10 >= stressThreshold, v10)

breadthPct = trendVotes / validSafe * 100.0
slopePct = slopeVotes / validSafe * 100.0
momentumPct = momentumVotes / validSafe * 100.0
stressPct = stressVotes / validSafe * 100.0
avgAtrPct = ((v1 ? a1 : 0.0) + (v2 ? a2 : 0.0) + (v3 ? a3 : 0.0) + (v4 ? a4 : 0.0) + (v5 ? a5 : 0.0) + (v6 ? a6 : 0.0) + (v7 ? a7 : 0.0) + (v8 ? a8 : 0.0) + (v9 ? a9 : 0.0) + (v10 ? a10 : 0.0)) / validSafe

breadthScoreRaw = breadthPct * 0.38 + momentumPct * 0.28 + slopePct * 0.20 + (100.0 - stressPct) * 0.14
breadthScore = f_score(breadthScoreRaw)
grade = f_grade(breadthScore)

breadthRising = breadthScore > breadthScore[1] and momentumPct >= momentumPct[1]
stressCooling = stressPct < stressPct[1] and breadthScore > breadthScore[1]
riskOn = breadthScore >= minRiskOnScore and breadthPct >= 60.0 and momentumPct >= 55.0
riskOff = breadthScore <= riskOffScore or (breadthPct <= 35.0 and momentumPct <= 40.0)
stressReview = not riskOn and stressPct >= 55.0 and breadthScore < minRotationScore
rotationWatch = not riskOn and not riskOff and not stressReview and breadthScore >= minRotationScore and breadthRising

regimeState = "Mixed Breadth"
if riskOn
    regimeState := "Risk-On Breadth"
else if rotationWatch
    regimeState := "Rotation Watch"
else if stressReview
    regimeState := "Stress Review"
else if riskOff
    regimeState := "Risk-Off Breadth"

actionState = "WAIT BREADTH"
if riskOn
    actionState := "REVIEW RISK-ON"
else if rotationWatch
    actionState := "TRACK ROTATION"
else if stressReview
    actionState := "CHECK STRESS"
else if riskOff
    actionState := "RISK-OFF REVIEW"
else if stressCooling
    actionState := "CHECK COOLING"

stateColor = riskOn ? bullColor : riskOff ? bearColor : stressReview ? neutralColor : rotationWatch ? accentColor : color.rgb(100, 116, 139)
actionColor = riskOn ? bullColor : riskOff ? bearColor : stressReview ? neutralColor : rotationWatch ? accentColor : stressCooling ? accentColor : color.rgb(100, 116, 139)

riskOnEvent = riskOn and not riskOn[1]
rotationEvent = rotationWatch and not rotationWatch[1]
riskOffEvent = riskOff and not riskOff[1]
stressEvent = stressReview and not stressReview[1]
coolingEvent = stressCooling and not stressCooling[1]

// --------------------------------------------------
// Confirmation-anchored proof (regime persistence, Hold = regime survived full horizon unchanged)
// --------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var string pRegime = ""
var int pStart = na

int proofWarmup = trendLength + atrLength + momentumLength + 5
int proofHalfHorizon = math.max(int(proofHorizonBars / 2), reactBars)
if barstate.isconfirmed and bar_index > proofWarmup
    if pEvalActive
        bool regimeChanged = regimeState != pRegime
        int heldBars = bar_index - pStart
        if regimeChanged or heldBars >= proofHorizonBars
            int survivedBars = regimeChanged ? heldBars : proofHorizonBars
            proofTotal := proofTotal + 1
            if survivedBars >= reactBars
                proofReact := proofReact + 1
            if survivedBars >= proofHalfHorizon
                proofFollow := proofFollow + 1
            if not regimeChanged
                proofHold := proofHold + 1
            else
                proofFlip := proofFlip + 1
            pEvalActive := false
    if not pEvalActive
        pEvalActive := true
        pRegime := regimeState
        pStart := bar_index

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// --------------------------------------------------
// Drawings
// --------------------------------------------------
atr = ta.atr(atrLength)
priceMean = ta.ema(close, 34)
corridorTop = priceMean + atr * corridorAtr
corridorBottom = priceMean - atr * corridorAtr
rightEdge = bar_index + projectionBars
darkText = color.rgb(17, 24, 39)
corridorTextColor = stateColor == neutralColor ? darkText : headerText
corridorText = showCorridorText ? f_state_short(regimeState) + " CORRIDOR\nSCORE " + str.tostring(breadthScore) + "/100" : ""

var box riskBox = na
var line midLine = na
var label corridorBadge = na

if showBreadthCorridor
    if na(riskBox)
        riskBox := box.new(bar_index, corridorTop, rightEdge, corridorBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 86), border_color = color.new(stateColor, 22), border_width = 1)
    else
        box.set_lefttop(riskBox, bar_index, corridorTop)
        box.set_rightbottom(riskBox, rightEdge, corridorBottom)
        box.set_bgcolor(riskBox, color.new(stateColor, 86))
        box.set_border_color(riskBox, color.new(stateColor, 22))
    if showCorridorText
        corridorBadgeX = int(math.round((bar_index + rightEdge) * 0.5))
        if na(corridorBadge)
            corridorBadge := label.new(corridorBadgeX, priceMean, corridorText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = corridorTextColor, size = f_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(corridorBadge, corridorBadgeX, priceMean)
            label.set_text(corridorBadge, corridorText)
            label.set_color(corridorBadge, color.new(stateColor, 0))
            label.set_textcolor(corridorBadge, corridorTextColor)
            label.set_size(corridorBadge, f_size(labelSizeInput))
    else if not na(corridorBadge)
        label.delete(corridorBadge)
        corridorBadge := na
else
    if not na(riskBox)
        box.delete(riskBox)
        riskBox := na
    if not na(corridorBadge)
        label.delete(corridorBadge)
        corridorBadge := na

if showBreadthCorridor and showBreadthMean
    if na(midLine)
        midLine := line.new(bar_index, priceMean, rightEdge, priceMean, xloc = xloc.bar_index, extend = extend.none, color = color.new(stateColor, 0), width = 1)
    else
        line.set_xy1(midLine, bar_index, priceMean)
        line.set_xy2(midLine, rightEdge, priceMean)
        line.set_color(midLine, color.new(stateColor, 0))
else
    if not na(midLine)
        line.delete(midLine)
        midLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
labelOffset = atr * labelOffsetAtr
var int lastLabelBar = na
var array<label> eventLabels = array.new<label>()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if array.size(eventLabels) > 0
    cleanupIdx = array.size(eventLabels) - 1
    while cleanupIdx >= 0
        oldLabel = array.get(eventLabels, cleanupIdx)
        oldX = label.get_x(oldLabel)
        if bar_index - oldX > eventMemoryBars
            label.delete(oldLabel)
            array.remove(eventLabels, cleanupIdx)
        cleanupIdx -= 1

canLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars

if showEventLabels and showRiskOnLabels and riskOnEvent and canLabel
    label newLabel = label.new(bar_index, low - labelOffset, "REVIEW RISK-ON\nSCORE " + str.tostring(breadthScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = bullColor, textcolor = headerText, size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showRotationLabels and rotationEvent and canLabel
    label newLabel = label.new(bar_index, low - labelOffset, "TRACK ROTATION\nSCORE " + str.tostring(breadthScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = accentColor, textcolor = headerText, size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showRiskOffLabels and riskOffEvent and canLabel
    label newLabel = label.new(bar_index, high + labelOffset, "RISK-OFF REVIEW\nSCORE " + str.tostring(breadthScore), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = bearColor, textcolor = headerText, size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showStressLabels and stressEvent and canLabel
    label newLabel = label.new(bar_index, high + labelOffset, "CHECK STRESS\nSTRESS " + str.tostring(stressPct, "0") + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = neutralColor, textcolor = darkText, size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showStressLabels and coolingEvent and canLabel
    label newLabel = label.new(bar_index, low - labelOffset, "CHECK COOLING\nSTRESS " + str.tostring(stressPct, "0") + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = neutralColor, textcolor = darkText, size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label breadthTag = na
var label scoreTag = na
var label stressTag = na
var label workflowTag = na
var line tagConnector = na

f_update_tag(label tag, float y, string txt, color bg, color txtCol) =>
    label result = tag
    if na(result)
        result := label.new(rightEdge, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = txtCol, size = labelSize)
    else
        label.set_x(result, rightEdge)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, txtCol)
        label.set_size(result, labelSize)
    result

if barstate.islast
    if not na(workflowTag)
        label.delete(workflowTag)
        workflowTag := na
    if not na(breadthTag)
        label.delete(breadthTag)
        breadthTag := na
    if not na(scoreTag)
        label.delete(scoreTag)
        scoreTag := na
    if not na(stressTag)
        label.delete(stressTag)
        stressTag := na
    if not na(tagConnector)
        line.delete(tagConnector)
        tagConnector := na

    if showRightTags and showBreadthCorridor
        tagX = rightEdge + math.max(rightTagOffsetBars, 6)
        tagGap = math.max(atr * corridorAtr * 0.95, close * 0.0030)
        float tagBaseY = priceMean + tagGap * 1.5
        workflowTag := label.new(tagX, tagBaseY, actionState, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = actionColor, textcolor = actionColor == neutralColor ? darkText : headerText, size = labelSize)
        breadthTag := label.new(tagX, tagBaseY - tagGap, "BREADTH " + str.tostring(breadthPct, "0") + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = stateColor, textcolor = stateColor == neutralColor ? darkText : headerText, size = labelSize)
        scoreTag := label.new(tagX, tagBaseY - tagGap * 2.0, "SCORE " + str.tostring(breadthScore) + "/100 " + grade, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = accentColor, textcolor = headerText, size = labelSize)
        stressTag := label.new(tagX, tagBaseY - tagGap * 3.0, "STRESS " + str.tostring(stressPct, "0") + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = neutralColor, textcolor = darkText, size = labelSize)
        tagConnector := line.new(rightEdge, priceMean, tagX, tagBaseY - tagGap, xloc = xloc.bar_index, color = color.new(actionColor, 42), width = 1)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelPos = f_panel_position(panelPositionInput)
panelIsLight = panelTheme == "Light"
panelFrame = f_panel_border(panelIsLight)
participationText = str.tostring(breadthPct, "0") + "% / " + str.tostring(validCount, "0") + " SYMBOLS"
momentumText = str.tostring(momentumPct, "0") + "% / SLOPE " + str.tostring(slopePct, "0") + "%"
stressText = str.tostring(stressPct, "0") + "% / ATR " + str.tostring(avgAtrPct, "0.00") + "%"
scoreText = str.tostring(breadthScore) + "/100 " + grade

string proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
string followTextPanel = proofTotal > 0 ? f_pct(followRate) : "-"
string holdTextPanel = proofTotal > 0 ? f_pct(holdRate) : "-"
string reactTextPanel = proofTotal > 0 ? f_pct(reactRate) : "-"
string flipTextPanel = proofTotal > 0 ? f_pct(flipRate) : "-"
color followColPanel = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelIsLight)
color holdColPanel = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelIsLight)
color reactColPanel = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelIsLight)
color flipColPanel = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelIsLight)

int panelRowCount = showProof ? 12 : 7
var table panel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastProofMode = false

panelNeedsReset = showPanel and (na(panel) or panelPositionInput != lastPanelLocation or panelTheme != lastPanelTheme or panelFontSizeInput != lastPanelSize or showProof != lastProofMode)
if panelNeedsReset
    if not na(panel)
        table.delete(panel)
    panel := table.new(panelPos, 2, panelRowCount, bgcolor = f_panel_bg(panelIsLight, false), frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    table.cell(panel, 0, 0, "AG Pro Crypto Market Breadth Risk Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLocation := panelPositionInput
    lastPanelTheme := panelTheme
    lastPanelSize := panelFontSizeInput
    lastProofMode := showProof

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, panelPos)
    table.set_frame_color(panel, panelFrame)
    table.set_border_color(panel, panelFrame)
    table.clear(panel, 0, 0, 1, panelRowCount - 1)
    table.merge_cells(panel, 0, 0, 1, 0)
    table.cell(panel, 0, 0, "AG Pro Crypto Market Breadth Risk Planner", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
    f_set_row(panel, 1, "Workflow", actionState, actionColor, panelIsLight, false, panelFontSizeInput)
    f_set_row(panel, 2, "Breadth Score", scoreText, stateColor == neutralColor ? neutralColor : stateColor, panelIsLight, true, panelFontSizeInput)
    f_set_row(panel, 3, "Participation", participationText, breadthPct >= 60.0 ? bullColor : breadthPct >= 40.0 ? neutralColor : bearColor, panelIsLight, false, panelFontSizeInput)
    f_set_row(panel, 4, "Momentum / Slope", momentumText, momentumPct >= 55.0 ? bullColor : momentumPct >= 40.0 ? neutralColor : bearColor, panelIsLight, true, panelFontSizeInput)
    f_set_row(panel, 5, "Stress Load", stressText, stressPct >= 55.0 ? neutralColor : bullColor, panelIsLight, false, panelFontSizeInput)
    f_set_row(panel, 6, "Regime", f_state_short(regimeState), stateColor, panelIsLight, true, panelFontSizeInput)
    if showProof
        rowBgProof = f_panel_bg(panelIsLight, false)
        table.cell(panel, 0, 7, "Proof @ Confirm", text_color = accentColor, bgcolor = rowBgProof, text_size = f_size(panelFontSizeInput))
        table.cell(panel, 1, 7, proofSampleText, text_color = f_panel_label(panelIsLight), bgcolor = rowBgProof, text_size = f_size(panelFontSizeInput), text_halign = text.align_right)
        f_set_row(panel, 8, "Follow Rate", followTextPanel, followColPanel, panelIsLight, true, panelFontSizeInput)
        f_set_row(panel, 9, "Hold Rate", holdTextPanel, holdColPanel, panelIsLight, false, panelFontSizeInput)
        f_set_row(panel, 10, "React Rate", reactTextPanel, reactColPanel, panelIsLight, true, panelFontSizeInput)
        f_set_row(panel, 11, "Flip Rate", flipTextPanel, flipColPanel, panelIsLight, false, panelFontSizeInput)

barStateColor = riskOn ? color.new(bullColor, 72) : riskOff ? color.new(bearColor, 72) : stressReview ? color.new(neutralColor, 76) : rotationWatch ? color.new(accentColor, 76) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Hidden Exports
// --------------------------------------------------
plot(followRate, "CBR Follow Rate", display = display.none)
plot(holdRate, "CBR Hold Rate", display = display.none)
plot(reactRate, "CBR React Rate", display = display.none)
plot(flipRate, "CBR Flip Rate", display = display.none)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertRiskOn and riskOnEvent, "CBR | Review Risk-On", "Crypto Market Breadth Risk Planner: REVIEW RISK-ON attention marker. Basket participation and momentum improved broadly.")
alertcondition(alertRotation and rotationEvent, "CBR | Track Rotation", "Crypto Market Breadth Risk Planner: TRACK ROTATION attention marker. Breadth is improving into a rotation review context.")
alertcondition(alertRiskOff and riskOffEvent, "CBR | Risk-Off Review", "Crypto Market Breadth Risk Planner: RISK-OFF REVIEW attention marker. Basket breadth and momentum weakened.")
alertcondition(alertStress and stressEvent, "CBR | Check Stress", "Crypto Market Breadth Risk Planner: CHECK STRESS attention marker. Basket volatility stress is elevated while breadth quality is weak.")
alertcondition(alertCooling and coolingEvent, "CBR | Check Cooling", "Crypto Market Breadth Risk Planner: CHECK COOLING attention marker. Basket stress is cooling while breadth quality improves.")
````
