# Cross Exchange Premium Drift Map [AGPro Series]

- url: https://www.tradingview.com/script/uTQAkmGl-Cross-Exchange-Premium-Drift-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;0461d7e0a6204eb0a8d3c358a33d351a
- version: 4.0

## Description

Cross Exchange Premium Drift Map [AGPro Series]

🧠 Core Idea

Is the active crypto venue drifting away from the exchange basket, or is the market staying aligned across venues?


📌 Overview / What it does

Cross Exchange Premium Drift Map [AGPro Series] is a crypto market structure tool designed to compare the active chart against a configurable basket of exchange reference symbols.

Instead of reading only the local chart, the script builds a venue basket from multiple exchange feeds and measures whether the active venue is trading at a premium, discount, or neutral alignment versus that basket.

It produces a premium drift path, a dispersion path, a right-side venue premium stack, event labels, strongest/weakest venue context, and a compact panel. It does not predict price direction, automate trading, or claim that a premium will close immediately.


🎯 Purpose & Design Philosophy

This script was built to fill a specific gap in crypto analysis: many traders look at one exchange chart and assume that chart represents the whole market.

Crypto is fragmented across venues. Premiums, discounts, and venue dispersion can appear before important shifts in liquidity, risk appetite, or execution quality.

The purpose of this tool is to make that fragmentation visible in a structured, readable, and non-predictive way.


⚡ Why This Script Is Different

Most tools focus on the active chart alone, or compare futures against spot using a basis model.

This script does NOT operate as a funding, carry, open interest, or perp-versus-spot basis indicator.

Instead, it compares the active venue against a configurable cross-exchange reference basket, then maps premium drift, venue dispersion, strongest venue, weakest venue, and alignment quality into a dedicated visual workflow.


⚙️ Methodology

1. Venue Basket Construction

The script requests multiple user-defined exchange symbols and builds an average reference basket from available venue prices.

2. Premium Drift Detection

The active chart is compared against the venue basket to calculate premium or discount.

3. Dispersion Evaluation

The script measures how far individual venues are spread around the basket.

4. State Classification

Premium, discount, spread expansion, spread compression, and exchange alignment are converted into readable states.

5. Visual Output

The chart displays premium paths, event labels, a right-side venue stack, and a panel summary.


🗺️ How to Read the Chart

The premium drift path shows how the active chart behaves relative to the venue basket.

The dispersion path shows whether exchange prices are widening away from each other or compressing toward alignment.

The right-side venue stack shows the current premium/discount context, basket drift, dispersion, strongest venue, and weakest venue.

Labels mark meaningful changes such as Venue Premium, Venue Discount, Spread Expansion, and Exchange Alignment.

The panel summarizes state, score, premium, drift z-score, velocity, dispersion, direction, grade, and venue count.


🚦 Signals & States

• Venue Premium → the active chart trades meaningfully above the exchange basket

• Venue Discount → the active chart trades meaningfully below the exchange basket

• Spread Expansion → venue dispersion is widening

• Spread Compression → venue prices are moving closer together

• Exchange Alignment → venues are compressed and the active chart is near the basket

• Check Venue Set → selected symbols may not represent the same asset or may be mismatched


🔔 Alerts Logic

Alerts trigger when the script detects a fresh state transition into a meaningful venue condition.

Venue Premium alerts mark active-chart premium pressure versus the basket.

Venue Discount alerts mark active-chart discount pressure versus the basket.

Spread Expansion alerts mark widening cross-exchange dispersion.

Exchange Alignment alerts mark compression toward venue agreement.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest readings occur when premium drift, drift z-score, velocity, dispersion, and persistence align.

When these conditions align, the venue message becomes more meaningful, but it still remains context rather than a prediction.


📊 When to Use

• Crypto spot charts with active multi-exchange liquidity

• BTC, ETH, and major liquid altcoin pairs

• Periods where venue premium, discount, or spread quality matters

• Market structure review before interpreting local price action

• Cross-exchange monitoring during volatile sessions


⚠️ When NOT to Use

• Illiquid symbols with unreliable venue references

• Symbols where the basket does not match the active chart asset

• Extremely noisy low-timeframe conditions

• Markets where one or more venue feeds are missing or stale

• Situations where the user expects guaranteed arbitrage signals


🎛️ Key Inputs

• Venue Symbols → define the exchange reference basket

• Venue Labels → control the short exchange names shown in the visual stack

• Premium Threshold → controls when active-chart premium or discount becomes relevant

• Dispersion Threshold → controls when cross-exchange spread widening matters

• Premium Baseline Length → controls the drift baseline

• Premium Z-Score Length → controls normalization

• Visual Settings → control panel, labels, paths, and venue stack display


🖥️ Interface & Visual Design

The interface is built for quick market reading.

The panel provides compact state information.

The premium stack shows the current venue relationship without using pale or white primary visuals, preserving readability on both dark and light chart backgrounds.

Labels are designed to be visible, premium, and not buried inside candles.


🧪 Practical Usage Workflow

1. Confirm that the venue symbols match the active chart asset.

2. Read the panel state and score.

3. Check whether the active chart is premium, discount, aligned, or mismatched.

4. Inspect the strongest and weakest venue labels.

5. Use the premium and dispersion paths to understand whether the relationship is widening or normalizing.


🔍 Interpretation Guidelines

A venue premium does not automatically mean price must fall.

A venue discount does not automatically mean price must rise.

Spread expansion means exchange prices are becoming less aligned.

Exchange alignment means the active venue is closer to the basket.

The script should be read as market context, not as a buy or sell system.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an arbitrage execution tool.

It is not an auto-trading system.

It does not guarantee that premiums, discounts, or spreads will normalize.


⚠️ Limitations & Transparency

Cross-exchange readings depend on symbol quality, venue availability, quote currency differences, and TradingView data access.

USD and USDT references may behave slightly differently.

Low-liquidity assets can produce unstable readings.

Timeframe differences and exchange data behavior can affect how states appear.


🧠 Market Context Notes

Crypto markets are fragmented.

The same asset can trade differently across exchanges because of liquidity, regional flow, quote currency differences, venue-specific demand, and execution conditions.

This script attempts to make that fragmentation easier to see.


🧾 Use Case Examples

When the active chart trades above the basket while dispersion expands, the market may be showing venue-specific premium pressure.

When the active chart trades below the basket while dispersion expands, the market may be showing local venue weakness.

When premium and dispersion compress together, the market may be returning toward exchange alignment.


🧱 System Philosophy

Cross Exchange Premium Drift Map follows the AGProLabs design principle of building decision-support maps rather than prediction tools.

The goal is to improve context, visual structure, and trader awareness.


🔐 Non-Promise Statement

No signal in this script guarantees a future price move.

No premium or discount reading guarantees convergence.

All outputs require broader market interpretation.


📉 Risk Disclosure

Trading involves risk.

Users are fully responsible for their own decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

This tool is designed for educational and analytical use. It helps traders study cross-exchange price behavior, venue alignment, and premium drift as part of a broader market structure workflow.

## Source Code

````pine
// --------------------------------------------------
// Cross Exchange Premium Drift Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.5
//
// Cross Exchange Premium Drift Map is a crypto market structure indicator built
// to compare the active chart against a configurable basket of exchange venues.
// It maps venue premium, venue discount, dispersion, spread velocity, venue
// alignment, and reference-set warnings so traders can see when one market is
// drifting away from the broader venue group.
// v1.5 refines event hierarchy so simultaneous premium and spread transitions
// produce one evidence-rich badge instead of overlapping chart annotations.
// --------------------------------------------------

//@version=6
indicator("Cross Exchange Premium Drift Map [AGPro Series]",
     shorttitle = "AG Pro XPD",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 120,
     max_boxes_count = 5)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_VENUE = "Cross Exchange Venue Basket"
string venueModeInput = input.string("Auto Match Chart", "Venue Mapping Mode", options = ["Auto Match Chart", "Manual"], group = G_VENUE,
     tooltip = "Auto Match Chart builds the venue basket from the active chart base asset. Select Manual to use the five custom venue symbols below.")
string primaryLabel = input.string("Chart", "Primary Venue Label", group = G_VENUE,
     tooltip = "Short label for the active chart venue. The active chart is compared against the reference venue basket.")
string venue1Symbol = input.symbol("BINANCE:ETHUSDT", "Venue 1 Symbol", group = G_VENUE,
     tooltip = "First reference venue. Use a symbol that tracks the same asset as the active chart.")
string venue1Label = input.string("BIN", "Venue 1 Label", group = G_VENUE,
     tooltip = "Short label shown for this venue in the premium ladder.")
string venue2Symbol = input.symbol("COINBASE:ETHUSD", "Venue 2 Symbol", group = G_VENUE,
     tooltip = "Second reference venue. USD and USDT symbols can be mixed, but large differences may trigger a venue-set warning.")
string venue2Label = input.string("CB", "Venue 2 Label", group = G_VENUE,
     tooltip = "Short label shown for this venue in the premium ladder.")
string venue3Symbol = input.symbol("KRAKEN:ETHUSD", "Venue 3 Symbol", group = G_VENUE,
     tooltip = "Third reference venue. Use a reliable venue with the same base asset.")
string venue3Label = input.string("KRK", "Venue 3 Label", group = G_VENUE,
     tooltip = "Short label shown for this venue in the premium ladder.")
string venue4Symbol = input.symbol("BYBIT:ETHUSDT", "Venue 4 Symbol", group = G_VENUE,
     tooltip = "Fourth reference venue. Use a matching spot or perpetual venue depending on the comparison you want.")
string venue4Label = input.string("BYB", "Venue 4 Label", group = G_VENUE,
     tooltip = "Short label shown for this venue in the premium ladder.")
string venue5Symbol = input.symbol("OKX:ETHUSDT", "Venue 5 Symbol", group = G_VENUE,
     tooltip = "Fifth reference venue. Use a matching symbol so the basket stays coherent.")
string venue5Label = input.string("OKX", "Venue 5 Label", group = G_VENUE,
     tooltip = "Short label shown for this venue in the premium ladder.")
int minVenueCount = input.int(3, "Minimum Active Venues", minval = 2, maxval = 5, group = G_VENUE,
     tooltip = "Minimum number of valid venue symbols required before the script reads the basket as usable.")
float mismatchLimit = input.float(6.0, "Symbol Set Warning Limit %", minval = 1.0, maxval = 50.0, step = 0.25, group = G_VENUE,
     tooltip = "If the active chart trades too far from the venue basket, the script warns that selected symbols may not represent the same asset.")

string G_ENGINE = "Premium Drift Engine"
float premiumThreshold = input.float(0.025, "Premium Threshold %", minval = 0.005, maxval = 5.0, step = 0.005, group = G_ENGINE,
     tooltip = "Minimum active-chart premium or discount versus the venue basket before directional premium states become relevant.")
float dispersionThreshold = input.float(0.015, "Dispersion Threshold %", minval = 0.005, maxval = 5.0, step = 0.005, group = G_ENGINE,
     tooltip = "Minimum average venue dispersion around the basket before cross-exchange spread pressure is considered meaningful.")
int baselineLen = input.int(34, "Premium Baseline Length", minval = 5, maxval = 300, group = G_ENGINE,
     tooltip = "Smoothing length used to build the premium drift baseline.")
int zLen = input.int(120, "Premium Z-Score Length", minval = 20, maxval = 500, group = G_ENGINE,
     tooltip = "Lookback used to normalize premium drift into a z-score.")
int velocityLen = input.int(5, "Premium Velocity Length", minval = 1, maxval = 50, group = G_ENGINE,
     tooltip = "Lookback used to measure how quickly premium or discount pressure is changing.")
int persistenceLen = input.int(9, "Persistence Length", minval = 2, maxval = 50, group = G_ENGINE,
     tooltip = "Lookback used to measure whether premium, discount, or dispersion pressure is persistent.")
float scoreSensitivity = input.float(1.0, "Score Sensitivity", minval = 0.25, maxval = 3.0, step = 0.05, group = G_ENGINE,
     tooltip = "Higher values make the score react faster to premium, velocity, and dispersion.")

string G_VISUAL = "Visual Design"
bool showVenueStack = input.bool(true, "Show Venue Ladder", group = G_VISUAL,
     tooltip = "Shows the right-side venue premium ladder: every venue and the active chart ranked by premium versus the basket.")
bool showCenterBadge = input.bool(true, "Show Ladder Badge", group = G_VISUAL,
     tooltip = "Shows the X-Premium grade and score badge above the ladder.")
bool showDriftPaths = input.bool(false, "Show Premium Drift Paths", group = G_VISUAL,
     tooltip = "Plots active premium and venue dispersion as chart-relative paths.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact event labels when meaningful venue premium, discount, expansion, or alignment states appear.")
bool showCompactMarkers = input.bool(false, "Show Compact Venue Markers", group = G_VISUAL,
     tooltip = "Adds small compact venue markers without changing the main state logic.")
int stackForwardBars = input.int(30, "Ladder Forward Bars", minval = 10, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how far to the right the venue ladder is placed.")
float rowGapAtr = input.float(0.72, "Ladder Row Gap ATR", minval = 0.30, maxval = 3.0, step = 0.02, group = G_VISUAL,
     tooltip = "ATR-based vertical spacing between venue ladder rows.")
int maxEventLabels = input.int(5, "Maximum Event Labels", minval = 1, maxval = 20, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
float labelOffsetAtr = input.float(1.05, "Event Label ATR Offset", minval = 0.2, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label distance used to keep event labels away from candles.")
int eventScoreFloor = input.int(60, "Event Label Score Floor", minval = 10, maxval = 90, group = G_VISUAL,
     tooltip = "Minimum score required before event labels are printed. This prevents low-signal labels from crowding the chart.")
int eventCooldownBars = input.int(48, "Event Label Cooldown Bars", minval = 3, maxval = 200, group = G_VISUAL,
     tooltip = "Minimum spacing before the same event family can print another label.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL,
     tooltip = "Controls event label, ladder, and badge font size.")

string G_PANEL = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls dashboard panel location.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard panel theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

string G_ALERTS = "Alerts"
bool alertPremium = input.bool(true, "Alert: Venue Premium", group = G_ALERTS,
     tooltip = "Enables alerts when the active chart venue trades at a meaningful premium versus the basket.")
bool alertDiscount = input.bool(true, "Alert: Venue Discount", group = G_ALERTS,
     tooltip = "Enables alerts when the active chart venue trades at a meaningful discount versus the basket.")
bool alertExpansion = input.bool(true, "Alert: Spread Expansion", group = G_ALERTS,
     tooltip = "Enables alerts when cross-exchange dispersion expands meaningfully.")
bool alertAlignment = input.bool(true, "Alert: Exchange Alignment", group = G_ALERTS,
     tooltip = "Enables alerts when venue prices compress toward alignment.")

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
color rowChip = color.rgb(30, 41, 59)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     sizeInput == "Huge" ? size.huge : size.normal

f_panel_position(string posInput) =>
    posInput == "Top Left" ? position.top_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Middle Center" ? position.middle_center :
     posInput == "Bottom Right" ? position.bottom_right :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Bottom Center" ? position.bottom_center : position.top_right

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.###")

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.###") + "%"

f_pct_signed(float value) =>
    na(value) ? "n/a" : (value >= 0.0 ? "+" : "") + str.tostring(value, "#.###") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_valid(float value) =>
    not na(value) and value > 0.0

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq >= 150.0 ? color.rgb(15, 23, 42) : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else
        evenRow ? color.rgb(20, 31, 52) : panelBg

f_keep_label(array<label> labelArray, label newLabel, int maxCount) =>
    array.push(labelArray, newLabel)
    if array.size(labelArray) > maxCount
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

f_event_label(array<label> labelArray, array<int> bars, float baseY, bool upward, string txt, color bgCol, string sizeInput, int maxCount, int win, float stepAtr, float atrv) =>
    int lvl = 0
    if array.size(bars) > 0
        for i = 0 to array.size(bars) - 1
            if bar_index - array.get(bars, i) <= win
                lvl += 1
    float y = upward ? baseY - lvl * stepAtr * atrv : baseY + lvl * stepAtr * atrv
    label newLabel = label.new(bar_index, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, color = color.new(bgCol, 4), textcolor = f_text_on(bgCol), size = f_size(sizeInput), textalign = text.align_center)
    f_keep_label(labelArray, newLabel, maxCount)
    array.push(bars, bar_index)
    if array.size(bars) > 16
        array.shift(bars)

f_marker_label(array<label> labelArray, int x, float y, string txt, color bgCol, string sizeInput, int maxCount) =>
    label newLabel = label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bgCol, 4), textcolor = f_text_on(bgCol), size = f_size(sizeInput))
    f_keep_label(labelArray, newLabel, maxCount)

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, text_color = f_panel_label(themeName), bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_size(sizeInput), text_halign = text.align_right)

// --------------------------------------------------
// Venue Data
// --------------------------------------------------
bool autoVenueMode = venueModeInput == "Auto Match Chart"
string chartBaseAsset = syminfo.basecurrency
string chartQuoteAsset = syminfo.currency
bool stableQuote = chartQuoteAsset == "USDT" or chartQuoteAsset == "USDC" or chartQuoteAsset == "BUSD" or chartQuoteAsset == "FDUSD" or chartQuoteAsset == "USD"
string liquidQuote = stableQuote ? "USDT" : chartQuoteAsset
string usdQuote = stableQuote ? "USD" : chartQuoteAsset
bool autoMapReady = str.length(chartBaseAsset) > 0 and str.length(chartQuoteAsset) > 0

string venue1Request = autoVenueMode ? "BINANCE:" + chartBaseAsset + liquidQuote : venue1Symbol
string venue2Request = autoVenueMode ? "COINBASE:" + chartBaseAsset + usdQuote : venue2Symbol
string venue3Request = autoVenueMode ? "KRAKEN:" + chartBaseAsset + usdQuote : venue3Symbol
string venue4Request = autoVenueMode ? "BYBIT:" + chartBaseAsset + liquidQuote : venue4Symbol
string venue5Request = autoVenueMode ? "OKX:" + chartBaseAsset + liquidQuote : venue5Symbol

float v1 = request.security(venue1Request, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float v2 = request.security(venue2Request, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float v3 = request.security(venue3Request, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float v4 = request.security(venue4Request, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float v5 = request.security(venue5Request, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

bool v1Ok = f_valid(v1)
bool v2Ok = f_valid(v2)
bool v3Ok = f_valid(v3)
bool v4Ok = f_valid(v4)
bool v5Ok = f_valid(v5)

int venueCount = (v1Ok ? 1 : 0) + (v2Ok ? 1 : 0) + (v3Ok ? 1 : 0) + (v4Ok ? 1 : 0) + (v5Ok ? 1 : 0)
float venueSum = (v1Ok ? v1 : 0.0) + (v2Ok ? v2 : 0.0) + (v3Ok ? v3 : 0.0) + (v4Ok ? v4 : 0.0) + (v5Ok ? v5 : 0.0)
float basketPrice = venueCount > 0 ? venueSum / venueCount : na
float rawPremium = f_valid(basketPrice) ? (close / basketPrice - 1.0) * 100.0 : na

float v1Premium = v1Ok and f_valid(basketPrice) ? (v1 / basketPrice - 1.0) * 100.0 : na
float v2Premium = v2Ok and f_valid(basketPrice) ? (v2 / basketPrice - 1.0) * 100.0 : na
float v3Premium = v3Ok and f_valid(basketPrice) ? (v3 / basketPrice - 1.0) * 100.0 : na
float v4Premium = v4Ok and f_valid(basketPrice) ? (v4 / basketPrice - 1.0) * 100.0 : na
float v5Premium = v5Ok and f_valid(basketPrice) ? (v5 / basketPrice - 1.0) * 100.0 : na

float dispSum = (v1Ok ? math.abs(v1Premium) : 0.0) + (v2Ok ? math.abs(v2Premium) : 0.0) + (v3Ok ? math.abs(v3Premium) : 0.0) + (v4Ok ? math.abs(v4Premium) : 0.0) + (v5Ok ? math.abs(v5Premium) : 0.0)
float dispersion = venueCount > 0 ? dispSum / venueCount : na

bool dataReady = venueCount >= minVenueCount and not na(rawPremium)
bool symbolMismatch = dataReady and math.abs(rawPremium) > mismatchLimit
bool readReady = dataReady and not symbolMismatch

float premiumBase = ta.ema(rawPremium, baselineLen)
float premiumDrift = readReady ? rawPremium - premiumBase : na
float premiumDev = math.max(nz(ta.stdev(rawPremium, zLen), 0.0), 0.0001)
float premiumZ = readReady ? premiumDrift / premiumDev : na
float premiumVelocity = readReady ? rawPremium - nz(rawPremium[velocityLen], rawPremium) : na
float persistentRaw = readReady and (math.abs(rawPremium) >= premiumThreshold or dispersion >= dispersionThreshold) ? 100.0 : 0.0
float persistence = ta.sma(persistentRaw, persistenceLen)

float premiumScore = readReady ? f_clamp(math.abs(rawPremium) / premiumThreshold * 28.0 * scoreSensitivity, 0.0, 32.0) : na
float zScorePart = readReady ? f_clamp(math.abs(premiumZ) / 2.0 * 24.0 * scoreSensitivity, 0.0, 24.0) : na
float dispScore = readReady ? f_clamp(dispersion / dispersionThreshold * 24.0 * scoreSensitivity, 0.0, 24.0) : na
float velocityScore = readReady ? f_clamp(math.abs(premiumVelocity) / premiumThreshold * 14.0 * scoreSensitivity, 0.0, 14.0) : na
float persistenceScore = readReady ? f_clamp(persistence / 100.0 * 16.0, 0.0, 16.0) : na
float driftScore = readReady ? f_clamp(premiumScore + zScorePart + dispScore + velocityScore + persistenceScore, 0.0, 100.0) : na

float v1Max = v1Ok ? v1Premium : -100000.0
float v2Max = v2Ok ? v2Premium : -100000.0
float v3Max = v3Ok ? v3Premium : -100000.0
float v4Max = v4Ok ? v4Premium : -100000.0
float v5Max = v5Ok ? v5Premium : -100000.0
float maxPremium = math.max(v1Max, math.max(v2Max, math.max(v3Max, math.max(v4Max, v5Max))))
string maxVenue = maxPremium == v1Max ? venue1Label : maxPremium == v2Max ? venue2Label : maxPremium == v3Max ? venue3Label : maxPremium == v4Max ? venue4Label : venue5Label

float v1Min = v1Ok ? v1Premium : 100000.0
float v2Min = v2Ok ? v2Premium : 100000.0
float v3Min = v3Ok ? v3Premium : 100000.0
float v4Min = v4Ok ? v4Premium : 100000.0
float v5Min = v5Ok ? v5Premium : 100000.0
float minPremium = math.min(v1Min, math.min(v2Min, math.min(v3Min, math.min(v4Min, v5Min))))
string minVenue = minPremium == v1Min ? venue1Label : minPremium == v2Min ? venue2Label : minPremium == v3Min ? venue3Label : minPremium == v4Min ? venue4Label : venue5Label

// --------------------------------------------------
// States
// --------------------------------------------------
bool venuePremium = readReady and rawPremium > premiumThreshold * 1.15 and premiumZ > 0.55 and driftScore >= 52.0
bool venueDiscount = readReady and rawPremium < -premiumThreshold * 1.15 and premiumZ < -0.55 and driftScore >= 52.0
bool spreadExpansion = readReady and dispersion > dispersionThreshold * 1.35 and math.abs(premiumVelocity) > premiumThreshold * 0.55 and driftScore >= 55.0
bool spreadCompression = readReady and dispersion < dispersionThreshold * 0.75 and math.abs(rawPremium) < premiumThreshold and math.abs(premiumVelocity) < premiumThreshold * 0.35 and driftScore >= 25.0
bool exchangeAlignment = readReady and spreadCompression and math.abs(premiumZ) < 0.75 and driftScore >= 35.0

string stateText = not dataReady ? "No Venue Data" : symbolMismatch ? "Check Venue Set" : venuePremium ? "Venue Premium" : venueDiscount ? "Venue Discount" : spreadExpansion ? "Spread Expansion" : exchangeAlignment ? "Exchange Alignment" : spreadCompression ? "Spread Compression" : "Neutral Drift"
string directionText = not dataReady ? "Waiting Venues" : symbolMismatch ? "Match Symbols" : venuePremium ? "Chart Premium" : venueDiscount ? "Chart Discount" : spreadExpansion ? "Spread Widening" : exchangeAlignment ? "Venue Alignment" : spreadCompression ? "Spread Normalizing" : "Balanced Venues"
string gradeText = not dataReady ? "No Data" : symbolMismatch ? "Symbol Warning" : driftScore >= 70.0 ? "Strong" : driftScore >= 50.0 ? "Developing" : driftScore >= 35.0 ? "Watch" : "Low"
string readText = readReady and driftScore >= 50.0 ? "Attention Marker" : readReady ? "Context Marker" : "Reference Check"
color stateColor = symbolMismatch ? neutralColor : venuePremium ? neutralColor : venueDiscount ? bearColor : spreadExpansion ? accentColor : exchangeAlignment ? bullColor : spreadCompression ? bullColor : panelLabelCol
string actionText = symbolMismatch ? "Check venue symbols" : venuePremium ? "Review premium drift" : venueDiscount ? "Review discount drift" : spreadExpansion ? "Review venue spread" : exchangeAlignment ? "Alignment check" : spreadCompression ? "Compression watch" : "Monitor venue basket"

float safeAtr = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)
float premTol = premiumThreshold * 0.25

float driftPath = readReady ? close + safeAtr * f_clamp(rawPremium / math.max(premiumThreshold * 4.0, 0.0001), -1.2, 1.2) : na
float dispPath = readReady ? close - safeAtr * f_clamp(dispersion / math.max(dispersionThreshold * 4.0, 0.0001), 0.0, 1.0) : na
plot(showDriftPaths ? driftPath : na, "Chart Venue Premium Path", color = stateColor, linewidth = 2)
plot(showDriftPaths ? dispPath : na, "Exchange Dispersion Path", color = color.new(accentColor, 15), linewidth = 2)

// --------------------------------------------------
// Venue Premium Ladder
// --------------------------------------------------
var array<label> ladderRows = array.new<label>()
var label ladderBadge = na
var array<label> eventLabels = array.new<label>()
var array<label> markerLabels = array.new<label>()
var array<int> recentUpBars = array.new_int()
var array<int> recentDownBars = array.new_int()
var int lastPremiumEventBar = na
var int lastDiscountEventBar = na
var int lastExpansionEventBar = na
var int lastAlignmentEventBar = na

if barstate.islast
    if array.size(ladderRows) > 0
        for i = 0 to array.size(ladderRows) - 1
            label.delete(array.get(ladderRows, i))
        array.clear(ladderRows)

    int ladX = bar_index + stackForwardBars

    if showVenueStack and dataReady and not symbolMismatch
        array<float> ladP = array.new_float()
        array<string> ladL = array.new_string()
        array<bool> ladC = array.new_bool()
        array.push(ladP, rawPremium)
        array.push(ladL, primaryLabel)
        array.push(ladC, true)
        if v1Ok
            array.push(ladP, v1Premium)
            array.push(ladL, venue1Label)
            array.push(ladC, false)
        if v2Ok
            array.push(ladP, v2Premium)
            array.push(ladL, venue2Label)
            array.push(ladC, false)
        if v3Ok
            array.push(ladP, v3Premium)
            array.push(ladL, venue3Label)
            array.push(ladC, false)
        if v4Ok
            array.push(ladP, v4Premium)
            array.push(ladL, venue4Label)
            array.push(ladC, false)
        if v5Ok
            array.push(ladP, v5Premium)
            array.push(ladL, venue5Label)
            array.push(ladC, false)

        int nLad = array.size(ladP)
        // selection sort descending by premium
        for i = 0 to nLad - 2
            int mx = i
            for j = i + 1 to nLad - 1
                if array.get(ladP, j) > array.get(ladP, mx)
                    mx := j
            if mx != i
                float tp = array.get(ladP, i)
                array.set(ladP, i, array.get(ladP, mx))
                array.set(ladP, mx, tp)
                string tl = array.get(ladL, i)
                array.set(ladL, i, array.get(ladL, mx))
                array.set(ladL, mx, tl)
                bool tc = array.get(ladC, i)
                array.set(ladC, i, array.get(ladC, mx))
                array.set(ladC, mx, tc)

        float rowStep = safeAtr * rowGapAtr
        float startY = close + rowStep * (nLad - 1) / 2.0
        for i = 0 to nLad - 1
            float pY = startY - i * rowStep
            float pr = array.get(ladP, i)
            string lb = array.get(ladL, i)
            bool isC = array.get(ladC, i)
            color chip = isC ? accentColor : pr > premTol ? bullColor : pr < -premTol ? bearColor : neutralColor
            string chartRowName = lb == "Chart" ? lb : lb + " (chart)"
            string rowTxt = (isC ? chartRowName : lb) + "  " + f_pct_signed(pr)
            label rl = label.new(ladX, pY, rowTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(chip, isC ? 0 : 6), textcolor = f_text_on(chip), size = f_size(labelSizeInput))
            array.push(ladderRows, rl)

        if showCenterBadge
            string badgeText = "X-Premium  " + gradeText + " / " + f_score(driftScore)
            float badgeY = startY + rowStep
            if na(ladderBadge)
                ladderBadge := label.new(ladX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 0), textcolor = f_text_on(stateColor), size = f_size(labelSizeInput))
            else
                label.set_xy(ladderBadge, ladX, badgeY)
                label.set_text(ladderBadge, badgeText)
                label.set_color(ladderBadge, color.new(stateColor, 0))
                label.set_textcolor(ladderBadge, f_text_on(stateColor))
                label.set_style(ladderBadge, label.style_label_left)
                label.set_size(ladderBadge, f_size(labelSizeInput))
        else
            if not na(ladderBadge)
                label.set_text(ladderBadge, "")
                label.set_color(ladderBadge, color.new(color.black, 100))
                label.set_textcolor(ladderBadge, color.new(color.black, 100))
    else if showVenueStack and symbolMismatch
        string warnText = "SYMBOL WARNING\nPremium suppressed"
        if na(ladderBadge)
            ladderBadge := label.new(ladX, close, warnText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_size(labelSizeInput))
        else
            label.set_xy(ladderBadge, ladX, close)
            label.set_text(ladderBadge, warnText)
            label.set_color(ladderBadge, color.new(neutralColor, 0))
            label.set_textcolor(ladderBadge, f_text_on(neutralColor))
            label.set_style(ladderBadge, label.style_label_left)
            label.set_size(ladderBadge, f_size(labelSizeInput))
    else if showVenueStack and not dataReady
        string dataText = autoVenueMode and not autoMapReady ? "AUTO MAP UNAVAILABLE\nUse Manual venue mode" : "VENUE DATA\n" + str.tostring(venueCount) + " / " + str.tostring(minVenueCount) + " references active"
        if na(ladderBadge)
            ladderBadge := label.new(ladX, close, dataText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 0), textcolor = f_text_on(neutralColor), size = f_size(labelSizeInput))
        else
            label.set_xy(ladderBadge, ladX, close)
            label.set_text(ladderBadge, dataText)
            label.set_color(ladderBadge, color.new(neutralColor, 0))
            label.set_textcolor(ladderBadge, f_text_on(neutralColor))
            label.set_style(ladderBadge, label.style_label_left)
            label.set_size(ladderBadge, f_size(labelSizeInput))
    else
        if not na(ladderBadge)
            label.set_text(ladderBadge, "")
            label.set_color(ladderBadge, color.new(color.black, 100))
            label.set_textcolor(ladderBadge, color.new(color.black, 100))

bool majorVenueShift = readReady and (math.abs(rawPremium) >= premiumThreshold * 1.55 or math.abs(premiumZ) >= 1.15)
bool majorSpreadShift = readReady and (dispersion >= dispersionThreshold * 1.65 or math.abs(premiumVelocity) >= premiumThreshold * 0.85)
bool majorEventReady = readReady and driftScore >= eventScoreFloor and (majorVenueShift or majorSpreadShift or driftScore >= 72.0)

if showEventLabels and majorEventReady and barstate.isconfirmed
    bool canPremiumEvent = na(lastPremiumEventBar) or bar_index - lastPremiumEventBar >= eventCooldownBars
    bool canDiscountEvent = na(lastDiscountEventBar) or bar_index - lastDiscountEventBar >= eventCooldownBars
    bool canExpansionEvent = na(lastExpansionEventBar) or bar_index - lastExpansionEventBar >= eventCooldownBars
    bool canAlignmentEvent = na(lastAlignmentEventBar) or bar_index - lastAlignmentEventBar >= eventCooldownBars
    bool premiumTrigger = venuePremium and not venuePremium[1] and canPremiumEvent
    bool discountTrigger = venueDiscount and not venueDiscount[1] and canDiscountEvent
    bool expansionTrigger = spreadExpansion and not spreadExpansion[1] and canExpansionEvent
    bool alignmentTrigger = exchangeAlignment and not exchangeAlignment[1] and canAlignmentEvent
    bool premiumExpansionTrigger = premiumTrigger and expansionTrigger
    bool discountExpansionTrigger = discountTrigger and expansionTrigger
    if premiumExpansionTrigger
        f_event_label(eventLabels, recentUpBars, low - safeAtr * labelOffsetAtr, true, "Premium + Spread\nScore " + f_score(driftScore), accentColor, labelSizeInput, maxEventLabels, 6, 1.15, safeAtr)
        lastPremiumEventBar := bar_index
        lastExpansionEventBar := bar_index
    else if discountExpansionTrigger
        f_event_label(eventLabels, recentDownBars, high + safeAtr * labelOffsetAtr, false, "Discount + Spread\nScore " + f_score(driftScore), accentColor, labelSizeInput, maxEventLabels, 6, 1.15, safeAtr)
        lastDiscountEventBar := bar_index
        lastExpansionEventBar := bar_index
    else if expansionTrigger
        f_event_label(eventLabels, recentDownBars, high + safeAtr * labelOffsetAtr, false, "Spread Expansion\nScore " + f_score(driftScore), accentColor, labelSizeInput, maxEventLabels, 6, 1.15, safeAtr)
        lastExpansionEventBar := bar_index
    else if premiumTrigger
        f_event_label(eventLabels, recentUpBars, low - safeAtr * labelOffsetAtr, true, "Venue Premium\nScore " + f_score(driftScore), neutralColor, labelSizeInput, maxEventLabels, 6, 0.95, safeAtr)
        lastPremiumEventBar := bar_index
    else if discountTrigger
        f_event_label(eventLabels, recentDownBars, high + safeAtr * labelOffsetAtr, false, "Venue Discount\nScore " + f_score(driftScore), bearColor, labelSizeInput, maxEventLabels, 6, 0.95, safeAtr)
        lastDiscountEventBar := bar_index
    else if alignmentTrigger
        f_event_label(eventLabels, recentUpBars, low - safeAtr * labelOffsetAtr * 0.85, true, "Exchange Alignment\nScore " + f_score(driftScore), bullColor, labelSizeInput, maxEventLabels, 6, 0.95, safeAtr)
        lastAlignmentEventBar := bar_index

if showCompactMarkers and readReady and barstate.isconfirmed
    bool premiumPulse = math.abs(rawPremium) > premiumThreshold and ta.change(math.sign(rawPremium)) != 0
    bool dispersionPulse = dispersion > dispersionThreshold and dispersion > nz(dispersion[1], dispersion)
    if premiumPulse
        f_marker_label(markerLabels, bar_index, rawPremium > 0 ? low - safeAtr * 0.45 : high + safeAtr * 0.45, rawPremium > 0 ? "P+" : "D-", rawPremium > 0 ? neutralColor : bearColor, labelSizeInput, 18)
    if dispersionPulse
        f_marker_label(markerLabels, bar_index, close, "X", accentColor, labelSizeInput, 18)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if showPanel and (na(panel) or panelLocationCache != panelPositionInput or panelThemeCache != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_position(panelPositionInput), 2, 7, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelLocationCache := panelPositionInput
    panelThemeCache := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        string modeText = autoVenueMode ? "AUTO" : "MANUAL"
        string panelState = not dataReady ? "Venue Data / Reference Check" : symbolMismatch ? "Check Venue Set / Symbol Warning" : stateText + " / " + f_score(driftScore)
        string panelPremium = not dataReady ? "Waiting for venue set" : symbolMismatch ? "Suppressed / Z n/a" : f_pct(rawPremium) + " / Z " + f_fmt(premiumZ)
        string panelSpread = not dataReady ? str.tostring(venueCount) + " / " + str.tostring(minVenueCount) + " references active" : symbolMismatch ? "Suppressed until match" : "Vel " + f_pct(premiumVelocity) + " / Disp " + f_pct(dispersion)
        string panelVenues = str.tostring(venueCount) + " active / " + modeText
        string panelLeaders = not dataReady ? "Insufficient reference set" : symbolMismatch ? "Suppressed until match" : maxVenue + " " + f_pct(maxPremium) + " / " + minVenue + " " + f_pct(minPremium)
        string panelAction = not dataReady ? (autoVenueMode ? "Use Manual mode if needed" : "Add matching venue symbols") : symbolMismatch ? "Match chart asset across venues" : actionText + " / " + gradeText
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Cross Exchange Premium Drift Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "State", panelState, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Premium", panelPremium, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Spread", panelSpread, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Venues", panelVenues, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Leaders", panelLeaders, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", panelAction, stateColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelLocationCache := ""
            panelThemeCache := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(barstate.isconfirmed and alertPremium and venuePremium and stateText != stateText[1], "Venue Premium Drift", "Active chart venue is trading at a meaningful premium versus the exchange basket on {{ticker}}.")
alertcondition(barstate.isconfirmed and alertDiscount and venueDiscount and stateText != stateText[1], "Venue Discount Drift", "Active chart venue is trading at a meaningful discount versus the exchange basket on {{ticker}}.")
alertcondition(barstate.isconfirmed and alertExpansion and spreadExpansion and stateText != stateText[1], "Cross Exchange Spread Expansion", "Cross-exchange dispersion is expanding on {{ticker}}.")
alertcondition(barstate.isconfirmed and alertAlignment and exchangeAlignment and stateText != stateText[1], "Cross Exchange Alignment", "Exchange venue prices are compressing toward alignment on {{ticker}}.")
````
