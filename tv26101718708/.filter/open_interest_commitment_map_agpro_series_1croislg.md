# Open Interest Commitment Map [AGPro Series]

- url: https://www.tradingview.com/script/1CROiSLg-Open-Interest-Commitment-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;bc7f8569b5c2482bbffb9c8256f77466
- version: 4.0

## Description

Open Interest Commitment Map [AGPro Series]

🧠 Core Idea

Is open interest expansion actually committing with price, or is participation building without conviction?


📌 Overview / What it does

Open Interest Commitment Map is a crypto derivatives context tool designed to evaluate whether open interest expansion, contraction, price movement, volatility, and persistence are aligning into a meaningful market participation state.

The script attempts to read open interest data through configurable OI symbol builders, including Perp Contract OI, Chart Ticker + _OI, Dot-P + _OI, and Manual mode. When supported open interest data is available, it measures OI change, normalizes that change, compares it with price movement, and classifies the result into commitment states. If official open interest data is unavailable, it can fall back to a transparent Volume Proxy mode so the user knows exactly what data mode is being used.

It produces a projected commitment zone, state labels, right-side tags, alerts, and an AG Pro dashboard. It does not predict price direction, automate entries, or claim that open interest expansion must continue.


🎯 Purpose & Design Philosophy

This script was built because open interest is often discussed as if it has one simple meaning. In reality, rising open interest can support a trend, pressure a crowded side, reflect absorption, or become irrelevant without price confirmation.

The goal is to turn open interest into a readable commitment map rather than a raw number. The script asks whether participation is expanding, whether price is accepting that expansion, whether the behavior persists, and whether the current state deserves attention.

It is designed for crypto futures and perpetual traders who want to evaluate derivatives participation without relying on a simplistic “OI up equals bullish” or “OI down equals bearish” interpretation.


⚡ Why This Script Is Different

Most tools show open interest as a separate line or histogram.

This script does NOT treat open interest as a standalone signal, does NOT assume rising OI is automatically bullish, and does NOT hide data limitations when official OI is unavailable.

Instead, it maps OI behavior into structured states: Long Build, Short Build, OI Unwind, Absorption, Reset, or Data Missing. It combines OI change, normalized OI deviation, price movement in ATR units, trend acceptance, persistence, and volume rank into one visual commitment framework.


⚙️ Methodology

1. Context Detection
The script builds or reads the open interest source and checks whether official OI data is available.

2. Reference Mapping
Open interest change is measured over a configurable lookback and normalized against a longer historical window.

3. Reaction Evaluation
The model compares OI expansion or contraction with price movement, trend position, volatility, and persistence.

4. Visual Output
The final state is displayed through a projected commitment zone, state tags, event labels, and a compact AG Pro panel.


🗺️ How to Read the Chart

The commitment zone represents the active area where price and participation behavior are being monitored.

Labels mark key state transitions such as Long Build, Short Build, OI Unwind, and OI Absorption.

Colors communicate context:
• Teal = Long Build
• Pink = Short Build
• Yellow = OI Unwind
• Indigo = Absorption or neutral commitment context
• Light/neutral = Reset or Data Missing

The panel shows state, score, OI change, OI z-score, persistence, volume rank, direction, quality, data mode, OI source, and distance from the OI baseline.


🚦 Signals & States

• Long Build → open interest expands while price shows constructive acceptance

• Short Build → open interest expands while price shows bearish acceptance

• OI Unwind → open interest contracts meaningfully while price moves

• OI Absorption → open interest expands but price movement remains compressed

• Reset → no strong commitment state is active

• Data Missing → no usable open interest or proxy data is available


🔔 Alerts Logic

Alerts trigger when the script transitions into a selected commitment state.

Long Build alerts mark expanding participation with constructive price acceptance.

Short Build alerts mark expanding participation with bearish price acceptance.

OI Unwind alerts mark meaningful open interest contraction while price is moving.

OI Absorption alerts mark expanding open interest with limited price movement.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest read appears when multiple conditions align:

Open interest change + OI z-score + price movement + trend acceptance + persistence + volume rank.

When expansion appears without price progress, the context can shift from directional commitment to absorption. When contraction appears with price movement, the context can shift toward unwind behavior.


📊 When to Use

• Crypto perpetual and futures markets

• Symbols where TradingView provides open interest data through `_OI`

• High-participation sessions where trader positioning may matter

• Breakout, breakdown, compression, and post-liquidation environments

• Situations where the user wants to distinguish commitment from noise


⚠️ When NOT to Use

• Symbols with no reliable open interest data when proxy mode is not desired

• Illiquid markets with unstable volume or fragmented data

• Very low timeframe noise without broader context

• Spot-only markets where open interest is not relevant

• Major news events where positioning can change faster than the model can stabilize


🎛️ Key Inputs

• OI Symbol Mode → controls whether the script uses Perp Contract OI, Chart Ticker + _OI, Dot-P + _OI, or Manual OI source selection

• Manual Open Interest Symbol → allows manual OI source selection if needed

• Allow Volume Proxy Fallback → uses transparent proxy mode when official OI is unavailable

• OI Baseline Length → controls the smoothing baseline for participation data

• OI Change Lookback → controls the change window for OI expansion or contraction

• OI Normalization Lookback → controls how unusual the OI change must be

• OI Commitment Z Threshold → defines the minimum normalized expansion required for commitment

• Visual Settings → control zone projection, event labels, right-side tags, and font sizes


🖥️ Interface & Visual Design

The interface is built around a clean commitment zone and a compact AG Pro panel.

The chart should feel active but not crowded. The projected zone gives the screenshot a visible story, right-side tags show the live state, and event labels highlight meaningful historical transitions.

The panel follows the AG Pro standard with a merged blue header row, adjustable location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Apply the script to a crypto perpetual or futures chart.

2. Start with OI Symbol Mode set to Perp Contract OI.

3. Confirm the Data Mode row says Open Interest when official OI data is available.

4. If Data Mode says Volume Proxy, try Chart Ticker + _OI, Dot-P + _OI, or Manual mode before using the screenshot for publication.

5. Read the State and Score rows.

6. Inspect whether price and OI are building, unwinding, absorbing, or resetting.

7. Confirm the context with broader market structure, liquidity, volatility, and risk management.


🔍 Interpretation Guidelines

Rising open interest is not automatically bullish.

Falling open interest is not automatically bearish.

Open interest expansion becomes more meaningful when price movement and persistence support the same story.

Absorption can be important because participation is increasing without clean price progress.

Unwind can be important because positioning is contracting while price is moving.


🚫 What This Script Is NOT

This script is not a prediction engine.

This script is not financial advice.

This script is not an auto trading system.

This script is not a guaranteed signal engine.

This script does not guarantee official open interest data exists on every symbol.

This script does not claim that open interest expansion must continue or reverse.


⚠️ Limitations & Transparency

Official open interest availability depends on the symbol, exchange, and TradingView data support.

If official OI data is not available and proxy fallback is enabled, the panel clearly shows Volume Proxy mode.

Volume Proxy is not the same as official open interest. It can still help visualize participation pressure, but it should be interpreted more cautiously.

Different exchanges, contract types, timeframes, and liquidity conditions can produce different open interest behavior.


🧠 Market Context Notes

Open interest can help traders think about participation, but it needs context.

Expansion with price acceptance may indicate commitment.

Expansion without progress may indicate absorption.

Contraction with movement may indicate unwind.

No single state removes uncertainty.


🧾 Use Case Examples

When OI expands and price accepts higher while trend context supports the move, the script may classify Long Build.

When OI expands and price accepts lower while trend context supports the move, the script may classify Short Build.

When OI expands but price remains compressed, OI Absorption can warn that participation is building without clean directional progress.

When OI contracts while price moves, OI Unwind can help identify positioning reduction.


🧱 System Philosophy

Open Interest Commitment Map follows the AGProLabs design principle of building decision-support maps rather than prediction tools.

The script is designed to organize participation context into a readable workflow: read the panel, inspect the zone, check the state, evaluate reaction, and confirm with broader structure.


🔐 Non-Promise Statement

No open interest model can guarantee future price direction.

No commitment score creates certainty.

This tool helps structure interpretation; it does not replace judgment.


📉 Risk Disclosure

Trading involves risk.

Crypto derivatives can be highly volatile and may involve leverage, liquidation risk, exchange risk, and rapid market movement.

This script is for educational and analytical purposes only.

It does not provide financial advice or guaranteed trading outcomes.

Users remain responsible for their own decisions.


📚 Educational Note

Use the script as a learning layer for understanding how participation, price movement, volatility, persistence, and open interest behavior can combine into a more complete derivatives-context read.

## Source Code

````pine
// --------------------------------------------------
// Open Interest Commitment Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Open Interest Commitment Map is a crypto derivatives context indicator built
// to map whether open interest expansion, contraction, price movement, volatility,
// and persistence are aligning into a meaningful commitment state. It highlights
// long build, short build, unwind, absorption, and reset conditions with a clean
// projected commitment zone, compact state labels, right-side tags, a stop-aware
// Commitment Follow Rate, and an AG Pro panel. Version 1.5 compacts the panel
// without changing the commitment engine, proof statistic, or alert behavior.
// --------------------------------------------------

//@version=6
indicator("Open Interest Commitment Map [AGPro Series]",
     shorttitle = "AG Pro OIC",
     overlay = true,
     max_boxes_count = 35,
     max_lines_count = 80,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_OI = "Open Interest Engine"
G_PRICE = "Price Commitment"
G_VISUAL = "Visual Design"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

oiSymbolMode = input.string("Perp Contract OI", "OI Symbol Mode", options = ["Perp Contract OI", "Chart Ticker + _OI", "Dot-P + _OI", "Manual"], group = G_OI,
     tooltip = "Controls how the open interest source is built. Perp Contract OI builds symbols such as BINANCE:ETHUSDTPERP_OI. If your exchange uses another format, try Chart Ticker + _OI, Dot-P + _OI, or Manual.")
oiReferenceExchange = input.string("BINANCE", "OI Reference Exchange", options = ["BINANCE", "BYBIT", "OKX", "BITGET", "KRAKEN"], group = G_OI,
     tooltip = "Exchange prefix used by automatic OI symbol builders.")
oiReferenceQuote = input.string("USDT", "OI Reference Quote", options = ["USDT", "USD", "USDC", "BTC", "ETH"], group = G_OI,
     tooltip = "Quote currency used by automatic OI symbol builders.")
manualOiSymbol = input.symbol("BINANCE:ETHUSDTPERP_OI", "Manual Open Interest Symbol", group = G_OI,
     tooltip = "Manual open interest symbol used only when OI Symbol Mode is set to Manual.")
allowVolumeProxy = input.bool(true, "Allow Volume Proxy Fallback", group = G_OI,
     tooltip = "If official open interest data is unavailable, the script can use a transparent volume-proxy mode. The panel clearly labels this as Volume Proxy.")
oiBaselineLength = input.int(34, "OI Baseline Length", minval = 5, maxval = 300, group = G_OI,
     tooltip = "EMA length used to define the baseline for open interest or proxy participation.")
oiChangeLookback = input.int(8, "OI Change Lookback", minval = 1, maxval = 80, group = G_OI,
     tooltip = "Number of bars used to measure open interest expansion or contraction.")
oiNormLookback = input.int(120, "OI Normalization Lookback", minval = 30, maxval = 500, group = G_OI,
     tooltip = "Lookback used to normalize open interest change into a commitment z-score.")
oiZThreshold = input.float(0.95, "OI Commitment Z Threshold", minval = 0.10, maxval = 5.0, step = 0.05, group = G_OI,
     tooltip = "Minimum normalized open interest expansion required before commitment can become active.")
unwindZThreshold = input.float(0.75, "Unwind Z Threshold", minval = 0.10, maxval = 5.0, step = 0.05, group = G_OI,
     tooltip = "Minimum normalized open interest contraction required before the script can classify unwind behavior.")
persistenceBars = input.int(9, "Persistence Window", minval = 3, maxval = 80, group = G_OI,
     tooltip = "Number of bars used to evaluate whether commitment behavior persists rather than appearing as a single isolated burst.")

atrLength = input.int(14, "ATR Length", minval = 2, maxval = 200, group = G_PRICE,
     tooltip = "ATR length used for price movement normalization, label spacing, and commitment zone width.")
trendFastLength = input.int(21, "Fast Trend Length", minval = 2, maxval = 300, group = G_PRICE,
     tooltip = "Fast EMA used to evaluate near-term price acceptance.")
trendSlowLength = input.int(55, "Slow Trend Length", minval = 3, maxval = 500, group = G_PRICE,
     tooltip = "Slow EMA used to evaluate broader trend commitment.")
priceMoveLookback = input.int(8, "Price Move Lookback", minval = 1, maxval = 80, group = G_PRICE,
     tooltip = "Number of bars used to compare price movement with open interest change.")
absorptionAtrMax = input.float(0.45, "Absorption Price Move Max ATR", minval = 0.05, maxval = 3.0, step = 0.05, group = G_PRICE,
     tooltip = "Maximum price movement in ATR units allowed while open interest expands before the script can classify absorption.")
minCommitmentScore = input.int(55, "Minimum Commitment Score", minval = 1, maxval = 100, group = G_PRICE,
     tooltip = "Minimum score required before long build, short build, unwind, or absorption states become active.")
followWindow = input.int(30, "Follow-Through Window", minval = 8, maxval = 200, group = G_PRICE,
     tooltip = "Bars allowed for a long/short build to follow through in its committed direction (counts) or reverse to the opposite stop (counts as a miss) before the sample times out uncounted. Used by the Commitment Follow Rate.")
followTargetAtr = input.float(1.0, "Follow Target ATR", minval = 0.2, maxval = 6.0, step = 0.1, group = G_PRICE,
     tooltip = "ATR distance price must travel in the committed direction to count as follow-through.")
followStopAtr = input.float(1.0, "Follow Stop ATR", minval = 0.2, maxval = 6.0, step = 0.1, group = G_PRICE,
     tooltip = "ATR distance price can travel against the committed direction before the sample counts as a miss.")

showCommitmentZone = input.bool(true, "Show Commitment Zone", group = G_VISUAL,
     tooltip = "Shows the projected commitment zone around the current open interest context.")
showCenterLabel = input.bool(true, "Show Centered Zone Label", group = G_VISUAL,
     tooltip = "Shows a compact centered label inside the commitment zone.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows long build, short build, unwind, absorption, and reset labels.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for state, OI change, and commitment score.")
showBarColors = input.bool(false, "Color Bars By Commitment State", group = G_VISUAL,
     tooltip = "Lightly colors bars by commitment state. Disabled by default to keep the chart clean.")
projectionBars = input.int(58, "Zone Projection Bars", minval = 10, maxval = 260, group = G_VISUAL,
     tooltip = "Controls how far the commitment zone and right-side tags are projected to the right.")
zoneLabelAnchor = input.float(0.58, "Zone Label Anchor", minval = 0.20, maxval = 0.90, step = 0.05, group = G_VISUAL,
     tooltip = "Controls the horizontal position of the centered commitment label inside the projected part of the zone. Higher values move the badge farther from the latest candles.")
rightTagSpacingAtr = input.float(0.46, "Right Tag Spacing ATR", minval = 0.05, maxval = 2.0, step = 0.05, group = G_VISUAL,
     tooltip = "Adds extra vertical spacing between right-side tags so state, OI, and score labels remain readable.")
labelCooldownBars = input.int(34, "Event Label Cooldown", minval = 5, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum number of bars between repeated event labels.")
maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 40, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
labelOffsetAtr = input.float(0.72, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based distance used to keep event labels away from candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, zone label, and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro open interest commitment panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls where the AG Pro dashboard panel appears on the chart.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Controls the panel color theme for dark or light chart layouts.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

alertLongBuild = input.bool(true, "Alert: Long Build", group = G_ALERTS,
     tooltip = "Enables alerts when open interest expands with constructive price acceptance.")
alertShortBuild = input.bool(true, "Alert: Short Build", group = G_ALERTS,
     tooltip = "Enables alerts when open interest expands with bearish price acceptance.")
alertUnwind = input.bool(true, "Alert: OI Unwind", group = G_ALERTS,
     tooltip = "Enables alerts when open interest contracts meaningfully while price moves.")
alertAbsorption = input.bool(true, "Alert: OI Absorption", group = G_ALERTS,
     tooltip = "Enables alerts when open interest expands but price movement remains compressed.")

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
resetColor = color.rgb(79, 70, 229)
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
     sizeName == "Large" ? size.large : size.normal

f_pos(string posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Middle Right" ? position.middle_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Bottom Right" ? position.bottom_right :
     posName == "Bottom Left" ? position.bottom_left : position.top_right

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
    stateName == "Long Build" ? bullColor :
     stateName == "Short Build" ? bearColor :
     stateName == "OI Unwind" ? neutralColor :
     stateName == "Absorption" ? accentColor :
     stateName == "Data Missing" ? neutralColor :
     stateName == "Reset" ? resetColor : neutralColor

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
// Core Calculations
// --------------------------------------------------
perpContractOiSymbol = oiReferenceExchange + ":" + syminfo.basecurrency + oiReferenceQuote + "PERP_OI"
chartTickerOiSymbol = syminfo.tickerid + "_OI"
dotPerpOiSymbol = oiReferenceExchange + ":" + syminfo.basecurrency + oiReferenceQuote + ".P_OI"
activeOiSymbol = oiSymbolMode == "Manual" ? manualOiSymbol :
     oiSymbolMode == "Chart Ticker + _OI" ? chartTickerOiSymbol :
     oiSymbolMode == "Dot-P + _OI" ? dotPerpOiSymbol : perpContractOiSymbol
oiCloseRaw = request.security(activeOiSymbol, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
oiAvailable = not na(oiCloseRaw)
proxyLength = math.max(int(math.round(oiBaselineLength / 2.0)), 2)
proxySource = ta.ema(volume, proxyLength)
oiSeries = oiAvailable ? oiCloseRaw : allowVolumeProxy ? proxySource : na
dataReady = not na(oiSeries)
oiFeedText = not dataReady ? "Unavailable" : not oiAvailable ? "Volume Proxy" :
     oiSymbolMode == "Manual" ? "Manual OI" :
     oiSymbolMode == "Chart Ticker + _OI" ? "Chart OI" :
     oiSymbolMode == "Dot-P + _OI" ? oiReferenceExchange + " | Dot-P OI" : oiReferenceExchange + " | Perp OI"

atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
fast = ta.ema(close, trendFastLength)
slow = ta.ema(close, trendSlowLength)
trendUp = fast > slow and close > slow
trendDown = fast < slow and close < slow

oiPrev = nz(oiSeries[oiChangeLookback], oiSeries)
oiChangePct = dataReady and oiPrev != 0.0 ? (oiSeries / oiPrev - 1.0) * 100.0 : na
oiChangeBase = ta.ema(oiChangePct, oiBaselineLength)
oiChangeDevRaw = ta.stdev(oiChangePct, oiNormLookback)
oiChangeDev = math.max(nz(oiChangeDevRaw, 0.0), 0.0001)
oiZ = dataReady ? (oiChangePct - nz(oiChangeBase, oiChangePct)) / oiChangeDev : na
oiBase = ta.ema(oiSeries, oiBaselineLength)
oiDistancePct = dataReady and oiBase != 0.0 ? (oiSeries / oiBase - 1.0) * 100.0 : na

priceMoveAtr = (close - nz(close[priceMoveLookback], close)) / safeAtr
absPriceMoveAtr = math.abs(priceMoveAtr)
volRank = nz(ta.percentrank(volume, oiNormLookback), 50.0)
oiExpansion = dataReady and oiZ > oiZThreshold and oiChangePct > 0.0
oiContraction = dataReady and oiZ < -unwindZThreshold and oiChangePct < 0.0
longBuildRaw = oiExpansion and priceMoveAtr > 0.25 and trendUp
shortBuildRaw = oiExpansion and priceMoveAtr < -0.25 and trendDown
absorptionRaw = oiExpansion and absPriceMoveAtr <= absorptionAtrMax
unwindRaw = oiContraction and absPriceMoveAtr > 0.20

longPersistence = math.sum(longBuildRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
shortPersistence = math.sum(shortBuildRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
absorptionPersistence = math.sum(absorptionRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
unwindPersistence = math.sum(unwindRaw ? 1.0 : 0.0, persistenceBars) / persistenceBars * 100.0
activePersistence = math.max(math.max(longPersistence, shortPersistence), math.max(absorptionPersistence, unwindPersistence))

oiZScore = f_clamp(math.abs(nz(oiZ, 0.0)) / 2.8 * 100.0, 0.0, 100.0)
oiChangeScore = f_clamp(math.abs(nz(oiChangePct, 0.0)) / 5.0 * 100.0, 0.0, 100.0)
priceScore = f_clamp(absPriceMoveAtr / 2.5 * 100.0, 0.0, 100.0)
persistenceScore = f_clamp(activePersistence, 0.0, 100.0)
commitmentScore = f_clamp(oiZScore * 0.34 + oiChangeScore * 0.22 + priceScore * 0.18 + persistenceScore * 0.18 + volRank * 0.08, 0.0, 100.0)

longBuild = longBuildRaw and commitmentScore >= minCommitmentScore
shortBuild = shortBuildRaw and commitmentScore >= minCommitmentScore
absorption = absorptionRaw and commitmentScore >= minCommitmentScore
unwind = unwindRaw and commitmentScore >= minCommitmentScore

stateText = not dataReady ? "Data Missing" :
     longBuild ? "Long Build" :
     shortBuild ? "Short Build" :
     unwind ? "OI Unwind" :
     absorption ? "Absorption" : "Reset"
stateColor = f_state_color(stateText)

directionText = not dataReady ? "No OI Data" :
     longBuild ? "Expansion Up" :
     shortBuild ? "Expansion Down" :
     unwind ? "Position Unwind" :
     absorption ? "OI Absorption" : "No Commitment"

qualityText = not dataReady ? "Unavailable" :
     commitmentScore >= 78.0 ? "Extreme" :
     commitmentScore >= 64.0 ? "Elevated" :
     commitmentScore >= 45.0 ? "Watch" : "Low"

// --------------------------------------------------
// Commitment Follow Rate (stop-aware, confirmed-bar gated, resolve-then-open)
// Of past long/short builds, how many followed through by the target in the
// committed direction before reversing to the opposite stop.
// --------------------------------------------------
var int followWins = 0
var int followTotal = 0
var bool followPending = false
var int followDir = 0
var float followTarget = na
var float followStop = na
var int followStartBar = na

newLong = longBuild and not longBuild[1]
newShort = shortBuild and not shortBuild[1]

if barstate.isconfirmed
    if followPending
        bool hitTarget = followDir == 1 ? high >= followTarget : low <= followTarget
        bool hitStop = followDir == 1 ? low <= followStop : high >= followStop
        if hitTarget
            followWins += 1
            followTotal += 1
            followPending := false
        else if hitStop
            followTotal += 1
            followPending := false
        else if not na(followStartBar) and bar_index - followStartBar >= followWindow
            followPending := false
    if not followPending and (newLong or newShort)
        followDir := newLong ? 1 : -1
        followTarget := newLong ? close + safeAtr * followTargetAtr : close - safeAtr * followTargetAtr
        followStop := newLong ? close - safeAtr * followStopAtr : close + safeAtr * followStopAtr
        followStartBar := bar_index
        followPending := true

int followPct = followTotal > 0 ? int(math.round(followWins / followTotal * 100.0)) : na
bool followBuilding = followTotal < 6
string followText = followBuilding ? "Building (" + str.tostring(followTotal) + ")" : str.tostring(followPct) + "% (" + str.tostring(followTotal) + ")"
color followColor = followBuilding ? neutralColor : followPct >= 52 ? bullColor : followPct >= 44 ? neutralColor : bearColor

actionText = not dataReady ? "Check OI source" :
     longBuild ? "Long commitment" :
     shortBuild ? "Short commitment" :
     unwind ? "Positions unwinding" :
     absorption ? "Absorption caution" : "No commitment"
color actionColor = not dataReady ? neutralColor : longBuild ? bullColor : shortBuild ? bearColor : unwind ? neutralColor : absorption ? accentColor : panelValueCol

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
var box commitmentBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 88), border_color = accentColor, border_width = 3)
var line upperRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var line lowerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = accentColor, style = line.style_solid, width = 3)
var label centerLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = inkLight, size = size.normal, textalign = text.align_center)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = inkLight, size = size.normal)
var label oiTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = inkLight, size = size.normal)
var label scoreTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = inkDark, size = size.normal)
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var string previousState = "Reset"

visualScore = dataReady ? commitmentScore : 20.0
zoneWidth = safeAtr * (0.72 + visualScore / 100.0 * 1.65)
zoneTop = close + zoneWidth
zoneBottom = close - zoneWidth
zoneMid = (zoneTop + zoneBottom) * 0.50
rightX = bar_index + projectionBars
leftX = math.max(bar_index - math.min(oiNormLookback, 180), bar_index - 180)
labelX = int(math.round(bar_index + projectionBars * zoneLabelAnchor))
tagSpacing = math.max(safeAtr * rightTagSpacingAtr, syminfo.mintick * 20.0)
stateTagY = zoneTop + tagSpacing
oiTagY = zoneTop - tagSpacing * 0.35
scoreTagY = zoneBottom - tagSpacing

if barstate.islast
    if showCommitmentZone
        box.set_left(commitmentBox, leftX)
        box.set_right(commitmentBox, rightX)
        box.set_top(commitmentBox, zoneTop)
        box.set_bottom(commitmentBox, zoneBottom)
        box.set_bgcolor(commitmentBox, color.new(stateColor, stateText == "Reset" ? 94 : 88))
        box.set_border_color(commitmentBox, color.new(stateColor, 0))
        box.set_border_width(commitmentBox, 3)
        line.set_xy1(upperRail, leftX, zoneTop)
        line.set_xy2(upperRail, rightX, zoneTop)
        line.set_color(upperRail, color.new(stateColor, 0))
        line.set_width(upperRail, 3)
        line.set_xy1(lowerRail, leftX, zoneBottom)
        line.set_xy2(lowerRail, rightX, zoneBottom)
        line.set_color(lowerRail, color.new(stateColor, 0))
        line.set_width(lowerRail, 3)
        if showCenterLabel
            centerText = dataReady ? "OI Commitment | " + qualityText + " | " + f_score(commitmentScore) : "Open Interest Data Missing"
            f_set_label(centerLabel, labelX, zoneMid, centerText, color.new(stateColor, 0), label.style_label_center, labelSizeInput)
        else
            label.set_text(centerLabel, "")
    else
        box.set_bgcolor(commitmentBox, color.new(color.white, 100))
        box.set_border_color(commitmentBox, color.new(color.white, 100))
        line.set_color(upperRail, color.new(color.white, 100))
        line.set_color(lowerRail, color.new(color.white, 100))
        label.set_text(centerLabel, "")

    if showRightTags
        oiText = dataReady ? "OI " + f_pct(oiChangePct) : "No OI Data"
        scoreTagText = dataReady ? "Score " + f_score(commitmentScore) : "Check OI Source"
        f_set_label(stateTag, rightX, stateTagY, stateText, stateColor, label.style_label_left, labelSizeInput)
        f_set_label(oiTag, rightX, oiTagY, oiText, accentColor, label.style_label_left, labelSizeInput)
        f_set_label(scoreTag, rightX, scoreTagY, scoreTagText, neutralColor, label.style_label_left, labelSizeInput)
        // De-collision: the three right tags share x, so separate them vertically when too close.
        array<label> rtags = array.new_label()
        array.push(rtags, stateTag)
        array.push(rtags, oiTag)
        array.push(rtags, scoreTag)
        array<float> rty = array.new_float()
        for ri = 0 to 2
            array.push(rty, label.get_y(array.get(rtags, ri)))
        for a = 0 to 1
            int mi = a
            for b = a + 1 to 2
                if array.get(rty, b) < array.get(rty, mi)
                    mi := b
            if mi != a
                float ty = array.get(rty, a)
                array.set(rty, a, array.get(rty, mi))
                array.set(rty, mi, ty)
                label tl = array.get(rtags, a)
                array.set(rtags, a, array.get(rtags, mi))
                array.set(rtags, mi, tl)
        float rGap = math.max(safeAtr * 0.7, syminfo.mintick * 24.0)
        for a = 1 to 2
            float py = array.get(rty, a - 1)
            float cy = array.get(rty, a)
            if cy - py < rGap
                float ny = py + rGap
                array.set(rty, a, ny)
                label.set_y(array.get(rtags, a), ny)
    else
        label.set_text(stateTag, "")
        label.set_text(oiTag, "")
        label.set_text(scoreTag, "")

canLabel = showEventLabels and dataReady and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
newState = stateText != previousState
longEvent = alertLongBuild and longBuild and canLabel and newState
shortEvent = alertShortBuild and shortBuild and canLabel and newState
unwindEvent = alertUnwind and unwind and canLabel and newState
absorptionEvent = alertAbsorption and absorption and canLabel and newState

if longEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Long Build", bullColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if shortEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Short Build", bearColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if unwindEvent
    bool upLabel = priceMoveAtr < 0.0
    float unwindY = upLabel ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, bar_index, unwindY, "OI Unwind", neutralColor, upLabel, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if absorptionEvent
    bool absorptionUp = close >= open
    float absorptionY = absorptionUp ? low - safeAtr * labelOffsetAtr : high + safeAtr * labelOffsetAtr
    f_event_label(eventLabels, bar_index, absorptionY, "OI Absorption", accentColor, absorptionUp, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

previousState := stateText

barcolor(showBarColors ? color.new(stateColor, 72) : na)
plot(showCommitmentZone ? fast : na, "Commitment Reaction Rail", color = color.new(stateColor, 0), linewidth = 2)
plot(showCommitmentZone ? slow : na, "Commitment Baseline Rail", color = color.new(accentColor, 35), linewidth = 2)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = table.new(f_pos(panelPositionInput), 2, 11, bgcolor = f_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)

if barstate.islast
    if showPanel
        color panelBodyBg = f_bg(panelThemeInput)
        color panelLabel = f_label_col(panelThemeInput)
        color panelValue = f_value_col(panelThemeInput)
        table.set_position(panel, f_pos(panelPositionInput))
        table.clear(panel, 0, 0, 1, 10)
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro OI Commitment Map", headerText, headerBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 1, "State", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 1, stateText, stateColor, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 2, "Score / Quality", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 2, dataReady ? f_score(commitmentScore) + " | " + qualityText : "n/a", panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 3, "OI Change", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 3, dataReady ? f_pct(oiChangePct) : "n/a", panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 4, "OI Z / Distance", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 4, dataReady ? str.tostring(oiZ, "#.##") + " | " + f_pct(oiDistancePct) : "n/a", panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 5, "Follow Rate", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 5, followText, followColor, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 6, "Direction", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 6, directionText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 7, "Persist / Vol", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 7, dataReady ? f_score(activePersistence) + " | " + f_score(volRank) : "n/a", panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 8, "OI Feed", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 8, oiFeedText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 9, "Price ATR", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 9, str.tostring(priceMoveAtr, "#.##"), panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 10, "Action", panelLabel, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 10, actionText, actionColor, panelBodyBg, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, 10)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertLongBuild and longBuild and stateText != stateText[1], "Long Build", "Open interest commitment is expanding with constructive price acceptance on {{ticker}}.")
alertcondition(alertShortBuild and shortBuild and stateText != stateText[1], "Short Build", "Open interest commitment is expanding with bearish price acceptance on {{ticker}}.")
alertcondition(alertUnwind and unwind and stateText != stateText[1], "OI Unwind", "Open interest is contracting meaningfully while price moves on {{ticker}}.")
alertcondition(alertAbsorption and absorption and stateText != stateText[1], "OI Absorption", "Open interest is expanding while price movement remains compressed on {{ticker}}.")
````
