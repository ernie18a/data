# Funding Carry Stress Map [AGPro Series]

- url: https://www.tradingview.com/script/vrygZZmC-Funding-Carry-Stress-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;b286a71bec9f497499b4aae7689601f6
- version: 4.0

## Description

Funding Carry Stress Map [AGPro Series]

🧠 Core Idea

Is the market carrying a hidden derivatives premium or discount that is becoming crowded enough to matter?


📌 Overview / What it does

Funding Carry Stress Map is a crypto derivatives context tool designed to estimate when perpetual-style premium, carry pressure, basis drift, and volatility-adjusted crowding are becoming structurally relevant on the chart.

The script compares the active chart symbol against a user-selected spot reference, builds a smoothed carry baseline, measures premium/discount deviation, evaluates persistence, and converts the result into a visual carry stress framework. It produces a projected carry stress corridor, state labels, right-side tags, alerts, and a compact AG Pro dashboard.

It does not read official exchange funding payments, automate trades, predict future price direction, or promise that elevated carry stress must reverse. It is a structured analytical layer for reading derivatives pressure, premium imbalance, discount imbalance, carry squeeze risk, and cooling behavior.


🎯 Purpose & Design Philosophy

This script was built to fill a gap in the public AGProLabs lineup: most chart tools focus on trend, volume, support/resistance, momentum, or volatility. Crypto traders also need a clean way to think about derivatives-side pressure without turning the chart into a noisy data terminal.

The design goal is to make carry stress visible as a chart story. Instead of showing only a raw spread number, the script asks whether premium/discount is large, unusual, persistent, and supported by enough volatility context to deserve attention.

It is built for traders who want to monitor crowded long carry, crowded short carry, squeeze risk, and stress cooling while still making their own decisions from broader market context.


⚡ Why This Script Is Different

Most tools either show generic premium/basis values or treat funding-related pressure as a simple bullish/bearish signal.

This script does NOT claim to know the next candle, does NOT treat carry pressure as an automatic reversal signal, and does NOT depend on official funding-rate feeds that may not be available on every chart.

Instead, it converts spot-vs-active-symbol premium behavior into a structured carry stress map: premium size, normalized basis deviation, persistence, volatility rank, price reaction, and cooling behavior are combined into one visual decision-support framework.


⚙️ Methodology

1. Context Detection
The script reads the active chart price and a spot reference. By default, it automatically builds that reference from the chart base currency, selected exchange, and selected quote.

2. Reference Mapping
The premium series is smoothed into a carry baseline. The script then measures how far current premium/discount has moved away from that baseline.

3. Reaction Evaluation
The model evaluates basis z-score, absolute premium percentage, persistence across a recent window, volatility rank, and whether price is starting to reject the crowded side.

4. Visual Output
The result is displayed as a carry stress corridor, event labels, right-side tags, and a dashboard panel showing state, stress score, premium, basis z-score, persistence, volatility rank, and current interpretation.


🗺️ How to Read the Chart

The carry stress corridor represents the active price area where derivatives-side pressure is being monitored.

Labels mark important state transitions such as premium stress, discount stress, carry squeeze risk, and carry cooling.

Colors communicate state:
• Pink = positive carry / long-crowding stress
• Teal = negative carry / short-crowding stress
• Yellow = squeeze-risk reaction
• Indigo = cooling or neutralization

The panel summarizes the current condition so the user can quickly read whether carry pressure is low, watch-level, elevated, or extreme.


🚦 Signals & States

• Premium Stress → positive premium/carry pressure is active and persistent enough to monitor

• Discount Stress → negative premium/discount pressure is active and persistent enough to monitor

• Carry Squeeze Risk → elevated carry pressure is present while price begins reacting against the crowded side

• Carry Cooling → previously meaningful carry stress has faded below the model’s cooling zone

• Reset → no active carry imbalance is strong enough to dominate the current read


🔔 Alerts Logic

Alerts trigger when the internal state changes into one of the selected alert conditions.

Premium Stress alerts mark a transition into meaningful positive carry pressure.

Discount Stress alerts mark a transition into meaningful negative carry pressure.

Carry Squeeze Risk alerts mark a transition where crowded carry pressure and adverse price reaction align.

Carry Cooling alerts mark a transition where carry stress has materially faded.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest context appears when multiple components align:

When premium size + basis z-score + persistence + volatility rank align, the carry stress score becomes more meaningful.

When that elevated score also appears with price rejection against the crowded side, the context shifts from simple premium/discount monitoring into potential squeeze-risk awareness.


📊 When to Use

• Crypto perpetual and futures markets where a spot reference can be selected

• Perpetual charts compared against their closest spot market

• High-interest crypto pairs where basis and carry pressure can influence behavior

• Volatile sessions where crowded positioning may matter more than usual

• Market regimes where traders want to monitor long-crowd or short-crowd pressure


⚠️ When NOT to Use

• Illiquid symbols with unreliable spot or futures pricing

• Charts where the selected spot reference is not comparable to the active symbol

• Markets with very noisy or fragmented data

• Extreme news events where spread behavior can become unstable

• Non-crypto symbols unless the user deliberately selects a meaningful reference


🎛️ Key Inputs

• Auto Spot Reference → automatically builds the spot reference from the chart base currency, selected exchange, and selected quote

• Carry Baseline Length → controls how quickly the premium baseline adapts

• Stress Normalization Lookback → controls how far back the script looks to judge unusual basis behavior

• Persistence Window → measures whether carry pressure persists across several bars

• Premium Stress Threshold % → defines the minimum premium/discount level required for active stress

• Reference Mismatch Guard % → prevents mismatched symbols from being interpreted as real carry stress

• Basis Z-Score Threshold → defines how unusual the spread must be before stress can activate

• Visual Settings → control corridor projection, labels, right-side tags, bar colors, and font sizes


🖥️ Interface & Visual Design

The interface is designed around a premium first-glance chart story.

The corridor gives the chart an active visual anchor. The centered label explains the current stress read without forcing the user to inspect every panel row. Right-side tags keep the current state visible near the active price area.

The panel uses the AG Pro layout standard with a blue merged header row, adjustable location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Apply the script to a perpetual or futures chart.

2. Keep Auto Spot Reference enabled, or manually select the closest matching spot market.

3. Read the panel state and stress score.

4. Check whether the corridor is neutral, premium-stressed, discount-stressed, or showing squeeze risk.

5. Evaluate price reaction around the corridor together with broader market structure, volatility, and risk rules.


🔍 Interpretation Guidelines

Treat carry stress as a context layer.

Premium stress can mean long-side carry is becoming crowded, but it does not automatically mean price must fall.

Discount stress can mean short-side carry is becoming crowded, but it does not automatically mean price must rise.

Carry squeeze risk is stronger when elevated stress and adverse price reaction appear together, but it still requires confirmation from broader market context.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto trading system.

This script is not a guaranteed signal engine.

This script does not read official funding payment data directly.

This script does not claim that premium or discount must immediately mean-revert.


⚠️ Limitations & Transparency

The script estimates carry stress from active-symbol versus spot-reference behavior. It is a proxy framework, not an official exchange funding-rate feed.

Results can vary by exchange, symbol mapping, liquidity, timeframe, and data quality.

The selected reference must match the active market. Auto Spot Reference is enabled by default to help keep ETH charts on an ETH reference, BTC charts on a BTC reference, and similar mappings aligned.

Fast market moves, low liquidity, stale references, or mismatched symbol selections can affect the accuracy of the stress interpretation.

Market conditions change, and the same stress score may behave differently across different volatility regimes.


🧠 Market Context Notes

In crypto markets, derivatives pressure can matter because perpetual traders may become crowded on one side when premium, basis, and volatility remain elevated.

This does not create certainty. It creates context.

The value of the script is strongest when the user combines carry stress with structure, liquidity, trend quality, volatility, and disciplined risk management.


🧾 Use Case Examples

When price trades above the spot reference with persistent premium and the panel shifts into Premium Stress, the user may monitor whether long-side carry is becoming crowded.

When price trades below the spot reference with persistent discount and the panel shifts into Discount Stress, the user may monitor whether short-side pressure is becoming crowded.

When elevated carry stress appears and price starts rejecting the crowded side, the Carry Squeeze Risk state can help highlight a context worth closer attention.


🧱 System Philosophy

Funding Carry Stress Map follows the AGProLabs principle of building decision-support maps rather than prediction tools.

The script is designed to make hidden context easier to see, not to replace judgment.

Its purpose is to organize information into a cleaner visual workflow: read the state, inspect the corridor, evaluate reaction, and confirm with broader context.


🔐 Non-Promise Statement

No script can guarantee market direction.

No carry stress model can remove uncertainty.

This tool helps organize context; it does not create certainty.


📉 Risk Disclosure

Trading involves risk.

Crypto derivatives can be highly volatile and may involve leverage, liquidation risk, exchange risk, funding-cost changes, and rapid market movement.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use the script as a learning layer for understanding how premium, discount, persistence, volatility, and price reaction can combine into a more complete derivatives-pressure read.

## Source Code

````pine
// --------------------------------------------------
// Funding Carry Stress Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Funding Carry Stress Map is a crypto derivatives context indicator that
// estimates when perpetual-versus-spot premium, carry pressure, basis
// persistence, and volatility-adjusted crowding are becoming structurally
// meaningful. In Auto mode it pairs a perpetual chart with its spot reference
// (or a spot chart with its perpetual) so the premium reflects a real
// perp-minus-spot basis. It maps a carry stress corridor, classifies long-side
// and short-side crowding, highlights cooling and reset behavior, and reports a
// stop-aware Carry Reaction Rate plus a clear action read inside an AG Pro panel.
// Version 1.3 introduces a forward carry ribbon with an owned basis spine.
// --------------------------------------------------

//@version=6
indicator("Funding Carry Stress Map [AGPro Series]",
     shorttitle = "AG Pro FCS",
     overlay = true,
     max_boxes_count = 35,
     max_lines_count = 80,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_CARRY = "Carry Stress Engine"
G_VISUAL = "Visual Design"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

useAutoSpotReference = input.bool(true, "Auto Perp/Spot Reference", group = G_CARRY,
     tooltip = "Automatically pairs the chart with the opposite contract type for a real basis: a spot chart is compared against its perpetual, a perpetual chart against its spot. The reference is built from the chart base currency, the selected exchange, and the selected quote currency.")
referenceExchange = input.string("BINANCE", "Reference Exchange", options = ["BINANCE", "BYBIT", "OKX", "COINBASE", "KRAKEN"], group = G_CARRY,
     tooltip = "Exchange prefix used when Auto Perp/Spot Reference is enabled.")
referenceQuote = input.string("USDT", "Reference Quote", options = ["USDT", "USD", "USDC", "BTC", "ETH"], group = G_CARRY,
     tooltip = "Quote currency used when Auto Perp/Spot Reference is enabled.")
manualSpotReferenceSymbol = input.symbol("BINANCE:BTCUSDT", "Manual Reference Symbol", group = G_CARRY,
     tooltip = "Manual reference symbol used only when Auto Perp/Spot Reference is disabled. For a real carry reading, pair a perpetual chart with a spot reference or vice versa.")
carryLookback = input.int(34, "Carry Baseline Length", minval = 5, maxval = 300, group = G_CARRY,
     tooltip = "EMA length used to smooth the premium/basis spread between the chart symbol and the reference symbol.")
stressLookback = input.int(120, "Stress Normalization Lookback", minval = 30, maxval = 500, group = G_CARRY,
     tooltip = "Lookback used to normalize carry premium into a stress z-score. Higher values make the model slower and more regime-aware.")
persistenceBars = input.int(10, "Persistence Window", minval = 3, maxval = 80, group = G_CARRY,
     tooltip = "Number of bars used to evaluate whether premium or discount pressure is persisting rather than appearing as one isolated bar.")
volatilityLength = input.int(14, "Volatility Length", minval = 2, maxval = 200, group = G_CARRY,
     tooltip = "ATR length used for volatility adjustment, label spacing, corridor width, and risk-context scoring.")
premiumThreshold = input.float(0.18, "Premium Stress Threshold %", minval = 0.01, maxval = 5.0, step = 0.01, group = G_CARRY,
     tooltip = "Minimum absolute premium/discount percentage required before carry pressure can become active.")
referenceMismatchLimit = input.float(20.0, "Reference Mismatch Guard %", minval = 2.0, maxval = 80.0, step = 1.0, group = G_CARRY,
     tooltip = "If the active symbol differs too much from the selected reference, the script shows a reference warning instead of treating the spread as real carry stress.")
zThreshold = input.float(1.05, "Basis Z-Score Threshold", minval = 0.10, maxval = 5.0, step = 0.05, group = G_CARRY,
     tooltip = "Minimum normalized basis deviation required before the script treats carry pressure as statistically meaningful.")
coolingThreshold = input.float(0.45, "Cooling Threshold", minval = 0.05, maxval = 2.5, step = 0.05, group = G_CARRY,
     tooltip = "Stress score level below which a previously active carry pressure state can be treated as cooling.")
stressSmoothing = input.int(5, "Stress Smoothing", minval = 1, maxval = 50, group = G_CARRY,
     tooltip = "EMA smoothing applied to the final carry stress score to reduce noisy state flips.")
reactionWindow = input.int(30, "Reaction Proof Window", minval = 8, maxval = 200, group = G_CARRY,
     tooltip = "Bars allowed for a crowded carry state to either react against the crowd (counts) or extend with the crowd (counts as a miss) before the sample times out uncounted. Used by the Carry Reaction Rate.")
reactionTargetAtr = input.float(1.0, "Reaction Target ATR", minval = 0.2, maxval = 6.0, step = 0.1, group = G_CARRY,
     tooltip = "ATR distance price must move against the crowded side to count as a reaction in the Carry Reaction Rate proof.")
continueStopAtr = input.float(1.4, "Crowd Continuation ATR", minval = 0.2, maxval = 8.0, step = 0.1, group = G_CARRY,
     tooltip = "ATR distance price can extend with the crowd before the sample counts as a miss in the Carry Reaction Rate proof.")

showStressCorridor = input.bool(true, "Show Carry Stress Corridor", group = G_VISUAL,
     tooltip = "Shows the active carry stress corridor projected around price when premium/discount pressure becomes meaningful.")
showCenterLabel = input.bool(true, "Show Centered Corridor Badge", group = G_VISUAL,
     tooltip = "Shows a compact centered badge inside the active carry stress corridor. The badge sits on a solid color so its text stays readable over the transparent corridor.")
rightTagDetail = input.string("Compact", "Right Tag Detail", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact keeps the owned basis tag short. Full adds the normalized basis z-score.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact long-carry, short-carry, squeeze-risk, and cooling transition labels.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows one compact basis tag owned by the dotted carry spine.")
showBarColors = input.bool(false, "Color Bars By Carry State", group = G_VISUAL,
     tooltip = "Lightly colors bars by carry stress state. Disabled by default to keep the chart clean.")
contextBars = input.int(18, "Ribbon Context Bars", minval = 6, maxval = 80, group = G_VISUAL,
     tooltip = "Number of recent bars included to the left of the current bar so the carry ribbon stays focused on the active context.")
projectionBars = input.int(48, "Ribbon Projection Bars", minval = 10, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how far the active carry ribbon and owned basis tag project to the right.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL,
     tooltip = "Shortens the ribbon projection on daily, weekly, and monthly charts while preserving the configured intraday length.")
labelCooldownBars = input.int(52, "Event Label Cooldown", minval = 5, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum number of bars between repeated event labels. Higher values reduce label density.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 3, maxval = 20, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
labelOffsetAtr = input.float(0.84, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based offset that keeps event labels above or below candles instead of buried inside price bars.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls chart label, corridor badge, and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro carry stress dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL,
     tooltip = "Controls where the AG Pro dashboard panel appears on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Controls the panel color theme for dark or light chart layouts.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

alertPremiumStress = input.bool(true, "Alert: Premium Stress", group = G_ALERTS,
     tooltip = "Enables alerts when positive premium/carry stress becomes meaningfully active.")
alertDiscountStress = input.bool(true, "Alert: Discount Stress", group = G_ALERTS,
     tooltip = "Enables alerts when negative premium/discount stress becomes meaningfully active.")
alertSqueezeRisk = input.bool(true, "Alert: Carry Squeeze Risk", group = G_ALERTS,
     tooltip = "Enables alerts when elevated carry pressure persists while price starts rejecting the crowded side.")
alertCooling = input.bool(true, "Alert: Carry Cooling", group = G_ALERTS,
     tooltip = "Enables alerts when a previously active carry stress state cools materially.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
inkDark = color.rgb(15, 23, 42)
inkLight = color.rgb(245, 247, 250)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
// Luminance-aware text color: dark ink on light fills, light ink on dark fills.
f_text_on(color bg) =>
    float r = color.r(bg)
    float g = color.g(bg)
    float b = color.b(bg)
    float lum = 0.299 * r + 0.587 * g + 0.114 * b
    lum > 145 ? inkDark : inkLight

f_clamp(float value, float minValue, float maxValue) =>
    float safeValue = na(value) ? minValue : value
    math.max(minValue, math.min(maxValue, safeValue))

f_size(string sizeName) =>
    sizeName == "Tiny" ? size.tiny :
     sizeName == "Small" ? size.small :
     sizeName == "Large" ? size.large :
     sizeName == "Huge" ? size.huge : size.normal

f_pos(string posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Top Center" ? position.top_center :
     posName == "Top Right" ? position.top_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Center" ? position.middle_center :
     posName == "Middle Right" ? position.middle_right :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center : position.bottom_right

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.###") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_bg(string themeName) =>
    themeName == "Light" ? panelBgLight :
     themeName == "Slate" ? panelBgSlate : panelBg

f_label_col(string themeName) =>
    themeName == "Light" ? panelLabelLight : panelLabelCol

f_value_col(string themeName) =>
    themeName == "Light" ? panelValueLight : panelValueCol

f_state_color(string stateName) =>
    stateName == "Check Spot Ref" ? neutralColor :
     stateName == "Long Crowd" ? bearColor :
     stateName == "Short Crowd" ? bullColor :
     stateName == "Squeeze Risk" ? neutralColor :
     stateName == "Carry Cooling" ? accentColor :
     stateName == "Reset" ? panelValueCol : neutralColor

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput))

f_set_label(label lbl, int x, float y, string txt, color bg, styleValue, string sizeInput) =>
    label.set_x(lbl, x)
    label.set_y(lbl, y)
    label.set_text(lbl, txt)
    label.set_color(lbl, bg)
    label.set_textcolor(lbl, f_text_on(bg))
    label.set_style(lbl, styleValue)
    label.set_size(lbl, f_size(sizeInput))

f_keep_label(array<label> labelStore, label newLabel, int limit) =>
    array.push(labelStore, newLabel)
    if array.size(labelStore) > limit
        label oldLabel = array.shift(labelStore)
        label.delete(oldLabel)

f_event_label(array<label> labelStore, int x, float y, string txt, color bg, bool up, string sizeInput, int limit) =>
    label newLabel = label.new(x, y, txt,
         xloc = xloc.bar_index,
         style = up ? label.style_label_up : label.style_label_down,
         textcolor = f_text_on(bg),
         color = bg,
         size = f_size(sizeInput))
    f_keep_label(labelStore, newLabel, limit)
    newLabel

// --------------------------------------------------
// Reference resolution (perp-vs-spot pairing)
// --------------------------------------------------
isPerp = str.contains(syminfo.ticker, ".P") or str.contains(syminfo.ticker, "PERP")
spotSym = referenceExchange + ":" + syminfo.basecurrency + referenceQuote
// Auto mode pairs the chart with the opposite contract type so the premium is a real basis.
autoSpotReferenceSymbol = isPerp ? spotSym : spotSym + ".P"
activeReference = useAutoSpotReference ? autoSpotReferenceSymbol : manualSpotReferenceSymbol
shortReference = str.replace_all(activeReference, referenceExchange + ":", "")

refCloseRaw = request.security(activeReference, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol = true)
noBasis = na(refCloseRaw)
refClose = nz(refCloseRaw, close)
safeRef = math.max(refClose, syminfo.mintick)

// Sign-consistent perp-minus-spot premium. In Auto mode the sign is normalized so a
// positive value always means the perpetual trades above spot (long-crowded contango).
premiumPct = useAutoSpotReference ? (isPerp ? (close / safeRef - 1.0) : (safeRef / close - 1.0)) * 100.0 : (close / safeRef - 1.0) * 100.0

refMismatch = not noBasis and math.abs(premiumPct) > referenceMismatchLimit
refWarning = noBasis or refMismatch

premiumBase = ta.ema(premiumPct, carryLookback)
premiumSpread = premiumPct - nz(premiumBase, premiumPct)
premiumDevRaw = ta.stdev(premiumPct, stressLookback)
premiumDev = math.max(nz(premiumDevRaw, 0.0), 0.0001)
basisZ = premiumSpread / premiumDev

atr = ta.atr(volatilityLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
volatilityPct = safeAtr / math.max(close, syminfo.mintick) * 100.0
volRank = nz(ta.percentrank(safeAtr, stressLookback), 50.0)

positiveCarry = not refWarning and premiumPct > premiumThreshold and basisZ > zThreshold
negativeCarry = not refWarning and premiumPct < -premiumThreshold and basisZ < -zThreshold
positivePersistence = math.sum(positiveCarry ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
negativePersistence = math.sum(negativeCarry ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
activePersistence = math.max(positivePersistence, negativePersistence)

basisScore = f_clamp(math.abs(basisZ) / 2.8 * 100.0, 0.0, 100.0)
premiumScore = f_clamp(math.abs(premiumPct) / math.max(premiumThreshold * 4.0, 0.01) * 100.0, 0.0, 100.0)
persistenceScore = f_clamp(activePersistence, 0.0, 100.0)
volatilityScore = f_clamp(volRank, 0.0, 100.0)
rawStress = premiumScore * 0.30 + basisScore * 0.34 + persistenceScore * 0.24 + volatilityScore * 0.12
carryStress = ta.ema(rawStress, stressSmoothing)

emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)
priceRejectLong = positiveCarry and close < emaFast and close < open
priceRejectShort = negativeCarry and close > emaFast and close > open
squeezeRisk = not refWarning and (priceRejectLong or priceRejectShort) and activePersistence >= 45.0 and carryStress >= 56.0

longCrowd = not refWarning and positiveCarry and carryStress >= 50.0
shortCrowd = not refWarning and negativeCarry and carryStress >= 50.0
cooling = not refWarning and carryStress <= coolingThreshold * 100.0 and math.abs(basisZ) < zThreshold and activePersistence < 35.0

stateText = refWarning ? "Check Spot Ref" :
     squeezeRisk ? "Squeeze Risk" :
     longCrowd ? "Long Crowd" :
     shortCrowd ? "Short Crowd" :
     cooling ? "Carry Cooling" : "Reset"
stateColor = f_state_color(stateText)

directionText = refWarning ? "Match Reference" :
     longCrowd ? "Positive Carry" :
     shortCrowd ? "Negative Carry" :
     squeezeRisk ? "Crowded Reaction" :
     cooling ? "Stress Cooling" : "No Active Carry"

qualityText = refWarning ? "Ref Warning" :
     carryStress >= 76.0 ? "Extreme" :
     carryStress >= 62.0 ? "Elevated" :
     carryStress >= 45.0 ? "Watch" : "Low"

// --------------------------------------------------
// Carry Reaction Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past crowded carry states, how many reacted against the crowd by the
// reaction target before extending with the crowd to the continuation stop.
// --------------------------------------------------
var int crowdWins = 0
var int crowdTotal = 0
var bool crowdPending = false
var int crowdDir = 0
var float crowdTarget = na
var float crowdStop = na
var int crowdStartBar = na

if barstate.isconfirmed
    if crowdPending
        bool reacted = crowdDir == 1 ? low <= crowdTarget : high >= crowdTarget
        bool extended = crowdDir == 1 ? high >= crowdStop : low <= crowdStop
        if reacted
            crowdWins += 1
            crowdTotal += 1
            crowdPending := false
        else if extended
            crowdTotal += 1
            crowdPending := false
        else if not na(crowdStartBar) and bar_index - crowdStartBar >= reactionWindow
            crowdPending := false
    bool newLong = longCrowd and not longCrowd[1]
    bool newShort = shortCrowd and not shortCrowd[1]
    if not crowdPending and (newLong or newShort)
        crowdDir := newLong ? 1 : -1
        crowdTarget := newLong ? close - safeAtr * reactionTargetAtr : close + safeAtr * reactionTargetAtr
        crowdStop := newLong ? close + safeAtr * continueStopAtr : close - safeAtr * continueStopAtr
        crowdStartBar := bar_index
        crowdPending := true

int reactionPct = crowdTotal > 0 ? int(math.round(crowdWins / crowdTotal * 100.0)) : na
bool reactionBuilding = crowdTotal < 6
string reactionText = reactionBuilding ? "Building (" + str.tostring(crowdTotal) + ")" : str.tostring(reactionPct) + "% (" + str.tostring(crowdTotal) + ")"
color reactionColor = reactionBuilding ? neutralColor : reactionPct >= 60 ? bullColor : reactionPct >= 45 ? neutralColor : bearColor

actionText = refWarning ? "Check reference" :
     squeezeRisk ? "Crowded reaction" :
     longCrowd ? "Watch for fade" :
     shortCrowd ? "Watch for bounce" :
     cooling ? "Stress easing" : "No active carry"

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box corridorBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 88), border_color = accentColor, border_width = 2)
var line basisSpine = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_dotted, width = 2)
var label centerLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = inkLight, size = size.normal, textalign = text.align_center)
var label basisTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = inkLight, size = size.normal)
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var string previousState = "Reset"

visualStress = refWarning ? 22.0 : carryStress
// Minimum ribbon half-width preserves a readable state field even when stress is low.
stressWidth = safeAtr * (0.95 + visualStress / 100.0 * 1.45)
corridorTop = close + stressWidth
corridorBottom = close - stressWidth
corridorMid = (corridorTop + corridorBottom) * 0.50
effectiveProjection = adaptiveProjection ? timeframe.ismonthly ? math.min(projectionBars, 6) : timeframe.isweekly ? math.min(projectionBars, 14) : timeframe.isdaily ? math.min(projectionBars, 24) : projectionBars : projectionBars
effectiveContext = adaptiveProjection ? timeframe.ismonthly ? math.min(contextBars, 3) : timeframe.isweekly ? math.min(contextBars, 6) : timeframe.isdaily ? math.min(contextBars, 12) : contextBars : contextBars
rightX = bar_index + effectiveProjection
leftX = math.max(bar_index - effectiveContext, 0)
labelX = int(math.round((leftX + rightX) * 0.50))

if barstate.islast
    if showStressCorridor
        box.set_left(corridorBox, leftX)
        box.set_right(corridorBox, rightX)
        box.set_top(corridorBox, corridorTop)
        box.set_bottom(corridorBox, corridorBottom)
        box.set_bgcolor(corridorBox, color.new(stateColor, stateText == "Reset" ? 94 : 88))
        box.set_border_color(corridorBox, color.new(stateColor, 0))
        box.set_border_width(corridorBox, 2)
        line.set_xy1(basisSpine, leftX, corridorMid)
        line.set_xy2(basisSpine, rightX, corridorMid)
        line.set_color(basisSpine, color.new(stateColor, 20))
        line.set_width(basisSpine, 2)
        if showCenterLabel
            centerText = refWarning ? "CHECK SPOT REFERENCE" : str.upper(stateText) + " | S" + f_score(carryStress) + " | " + str.upper(qualityText)
            f_set_label(centerLabel, labelX, corridorMid, centerText, color.new(stateColor, 0), label.style_label_center, labelSizeInput)
        else
            label.set_text(centerLabel, "")
    else
        box.set_bgcolor(corridorBox, color.new(color.white, 100))
        box.set_border_color(corridorBox, color.new(color.white, 100))
        line.set_color(basisSpine, color.new(color.white, 100))
        label.set_text(centerLabel, "")

    if showRightTags and showStressCorridor
        basisText = refWarning ? "REFERENCE MISMATCH" : rightTagDetail == "Full" ? "BASIS " + f_pct(premiumPct) + " | Z " + str.tostring(basisZ, "#.##") : "BASIS " + f_pct(premiumPct)
        f_set_label(basisTag, rightX, corridorMid, basisText, accentColor, label.style_label_left, labelSizeInput)
    else
        label.set_text(basisTag, "")

canLabel = showEventLabels and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
newState = stateText != previousState
premiumEvent = alertPremiumStress and longCrowd and canLabel and newState
discountEvent = alertDiscountStress and shortCrowd and canLabel and newState
squeezeEvent = alertSqueezeRisk and squeezeRisk and canLabel and newState
coolEvent = alertCooling and cooling and previousState != "Reset" and canLabel and newState

if premiumEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "LONG CARRY", bearColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if discountEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "SHORT CARRY", bullColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if squeezeEvent
    bool upLabel = priceRejectShort
    float squeezeY = upLabel ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, bar_index, squeezeY, "SQUEEZE RISK", neutralColor, upLabel, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if coolEvent
    bool coolUp = close >= open
    float coolY = coolUp ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, bar_index, coolY, "CARRY COOLING", accentColor, coolUp, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

previousState := stateText

barcolor(showBarColors ? color.new(stateColor, 72) : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = table.new(position.top_right, 4, 8, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    table.set_position(panel, f_pos(panelPositionInput))
    table.clear(panel, 0, 0, 3, 7)
    if showPanel
        color panelBodyBg = f_bg(panelThemeInput)
        color panelLabel = f_label_col(panelThemeInput)
        color panelValue = f_value_col(panelThemeInput)
        color frameColor = panelThemeInput == "Light" ? color.rgb(203, 213, 225) : panelBorder
        table.set_frame_color(panel, frameColor)
        table.set_border_color(panel, frameColor)
        table.merge_cells(panel, 0, 0, 3, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Funding Carry Stress", headerText, headerBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 1, "State", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 1, stateText, stateColor, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 1, "Stress", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 1, refWarning ? "n/a" : f_score(carryStress), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 2, "Premium", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 2, refWarning ? "Ref Mismatch" : f_pct(premiumPct), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 2, "Basis Z", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 2, refWarning ? "n/a" : str.tostring(basisZ, "#.##"), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 3, "Persistence", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 3, refWarning ? "n/a" : f_score(activePersistence), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 3, "Vol Rank", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 3, f_score(volRank), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 4, "Direction", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 4, directionText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 4, "Quality", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 4, qualityText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 5, "Pair", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 5, noBasis ? "No Pair Found" : shortReference, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 5, "Volatility", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 5, f_pct(volatilityPct), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 6, "Reaction", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 6, reactionText, reactionColor, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 6, "Width", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 6, refWarning ? "n/a" : str.tostring(stressWidth / safeAtr, "#.##") + " ATR", panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 7, "Action", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 7, actionText, stateColor, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 2, 7, "Mode", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 3, 7, useAutoSpotReference ? "Auto Pair" : "Manual Pair", panelValue, panelBodyBg, panelFontSizeInput)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertPremiumStress and longCrowd and stateText != stateText[1], "Premium Stress", "Positive carry premium stress is active on {{ticker}}.")
alertcondition(alertDiscountStress and shortCrowd and stateText != stateText[1], "Discount Stress", "Negative carry discount stress is active on {{ticker}}.")
alertcondition(alertSqueezeRisk and squeezeRisk and stateText != stateText[1], "Carry Squeeze Risk", "Carry pressure is elevated while price is reacting against the crowded side on {{ticker}}.")
alertcondition(alertCooling and cooling and stateText != stateText[1], "Carry Cooling", "Carry stress is cooling on {{ticker}}.")
````
