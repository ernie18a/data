# Crypto Beta Leadership Ladder [AGPro Series]

- url: https://www.tradingview.com/script/kfpeHX7r-Crypto-Beta-Leadership-Ladder-AGPro-Series/
- type: indicator
- pine_id: PUB;cfab9b87397d45c5a94d53943d056ad4
- version: 4.0

## Description

Crypto Beta Leadership Ladder [AGPro Series]

🧠 Core Idea

When crypto risk appetite changes, who is actually leading the move: BTC, ETH, broad alt beta, or the active chart itself?


📌 Overview / What it does

Crypto Beta Leadership Ladder [AGPro Series] is a market leadership and relative beta map for crypto traders.

The script compares BTC, ETH, broad altcoin market-cap behavior, high-beta altcoin breadth, BTC dominance, ETH dominance, and the active chart into a single leadership framework.

It produces a right-side leadership ladder, a live leadership path, selective transition labels, optional compact markers, and an AG Pro dashboard panel. It does not predict price, automate trades, or tell users what to buy or sell.


🎯 Purpose & Design Philosophy

This script was built to solve a common crypto-market problem: price may move, but leadership often rotates underneath the move.

Sometimes BTC is leading defensively. Sometimes ETH begins to participate. Sometimes broad alt beta expands. Sometimes the active chart is outperforming the market. These are different market conditions, and they should not be interpreted the same way.

The goal is to help traders read crypto leadership quality instead of reacting only to candle direction.


⚡ Why This Script Is Different

Most tools focus on one symbol, one moving average, one dominance chart, or one relative-strength line.

This script does NOT draw liquidation zones, funding stress maps, stablecoin liquidity pulses, basis corridors, or open-interest commitment zones.

Instead, it builds a leadership ladder from multiple crypto-market proxies and ranks BTC, ETH, alt beta, and chart beta as a live market hierarchy.


⚙️ Methodology

1. Context Detection

The script reads BTC, ETH, TOTAL2, TOTAL3, BTC dominance, and ETH dominance sources.

2. Relative Beta Mapping

It compares performance, dominance change, chart beta versus BTC, and altcoin breadth versus BTC.

3. Leadership Ranking

BTC, ETH, ALT, and CHART scores are ranked into a leadership stack. The gap between the first and second rank controls whether leadership is clear or split.

4. Visual Output

The script displays a right-side rank ladder, a leadership path, selective event labels, optional rank markers, and a compact dashboard.


🗺️ How to Read the Chart

The top ladder rail shows the current leadership rank.

The middle rail shows the second rank and whether leadership is close or split.

The lower rail shows the third rank and the active beta spread context.

The leadership path moves with the market and changes color by active leadership state.

Event labels highlight major transitions such as BTC Shield Lead, ETH Leadership, Alt Beta Lead, Chart Beta Expansion, or Split Leadership.

The panel summarizes leader, score, edge, BTC relative change, ETH relative change, alt beta, chart beta, dominance shift, persistence, state, and grade.


🚦 Signals & States

• BTC Leadership → BTC is leading defensively versus the broader crypto market

• ETH Leadership → ETH participation is stronger than BTC and broad alt context

• Alt Beta Lead → high-beta altcoin breadth is leading the crypto market

• Chart Beta Expansion → the active chart is outperforming BTC with expanding beta

• Split Leadership → leadership is mixed and no single group has clear control

• Balanced Leadership → leadership is present but not strong enough to be dominant

• Data Missing → one or more reference sources are unavailable


🔔 Alerts Logic

Alerts can be enabled for BTC Leadership, ETH Leadership, Alt Beta Leadership, Chart Beta Expansion, and Split Leadership.

Alerts trigger when the relevant state becomes active and the leadership state changes.

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

The ladder becomes more meaningful when rank edge, dominance shift, chart trend, and persistence align.

For example, an Alt Beta Lead state with positive chart beta and falling BTC dominance suggests a stronger risk-on leadership environment than a single isolated altcoin move.


📊 When to Use

• Crypto market rotation analysis

• BTC versus altcoin leadership checks

• ETH participation monitoring

• Altcoin beta expansion environments

• Market regime comparison across timeframes


⚠️ When NOT to Use

• Symbols with poor liquidity

• Very low timeframes with noisy dominance behavior

• Markets where reference symbols are unavailable

• During extreme news shocks without broader context


🎛️ Key Inputs

• Leadership Momentum Length → controls the main comparison window

• Leadership Baseline Length → controls slower leadership context

• Leadership Edge Threshold → controls how strong rank separation must be

• Beta Expansion Threshold → controls chart outperformance sensitivity

• Ladder Projection Bars → controls right-side ladder length

• Label Font Size / Panel Font Size → controls visual readability


🖥️ Interface & Visual Design

The interface is designed as a leadership stack rather than a zone map.

The ladder avoids white or pale-gray primary visuals so it remains visible on both dark and light chart backgrounds.

The panel uses the AG Pro blue header with a single merged title row and a compact information hierarchy.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check which asset group leads the ladder.

3. Compare edge and persistence.

4. Read the leadership path color.

5. Use event labels as attention markers, not trade signals.


🔍 Interpretation Guidelines

Clear leadership means one group is controlling relative market behavior.

Split leadership means the market may be rotating, pausing, or lacking conviction.

Chart Beta Expansion means the active symbol is outperforming BTC, but it still requires broader confirmation.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a financial-advice tool.

It is not an automated trading system.

It does not guarantee that leadership will continue.

It does not replace risk management or broader market analysis.


⚠️ Limitations & Transparency

Reference-symbol availability may vary by exchange, region, and TradingView data feed.

Dominance data may behave differently from exchange-traded pairs on lower timeframes.

Leadership can rotate quickly during volatile crypto sessions.

Different timeframes may show different leadership states.


🧠 Market Context Notes

BTC leadership often reflects defensive crypto behavior.

ETH leadership can suggest higher participation in major smart-contract assets.

Alt beta leadership can suggest broader risk appetite, but it may also be more volatile.

Split leadership often appears during transitions, pauses, or uncertain market regimes.


🧾 Use Case Examples

When BTC leads while BTC dominance rises, the market may be defensive even if price is moving.

When alt beta leads while BTC dominance falls, broader risk appetite may be improving.

When the active chart expands versus BTC while rank edge improves, that symbol may deserve closer attention.


🧱 System Philosophy

Crypto markets are not led by one chart all the time.

This script treats leadership as a rotating hierarchy and visualizes that hierarchy directly on the chart.


🔐 Non-Promise Statement

No script can guarantee future price behavior.

This tool maps leadership context; it does not provide certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions.

This script is provided for educational and analytical purposes only and does not constitute financial advice.


📚 Educational Note

Use the ladder to study how crypto leadership rotates between BTC, ETH, alt beta, and the active chart across different market regimes.

## Source Code

````pine
// --------------------------------------------------
// Crypto Beta Leadership Ladder [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Crypto Beta Leadership Ladder maps crypto market beta leadership across BTC,
// ETH, broad altcoin beta, and the active chart. It builds a compact leadership
// ladder, relative beta path, ranked segment tags, selective transition labels,
// and an AG Pro panel for reading whether crypto risk appetite is defensive,
// ETH-led, alt-beta-led, chart-led, or split across leaders.
// v1.3 adds confirmed transition discipline, decouples chart annotations from
// alert routing, and centers the live ladder identity inside its ranked field.
// --------------------------------------------------

//@version=6
indicator("Crypto Beta Leadership Ladder [AGPro Series]",
     shorttitle = "AG Pro CBL",
     overlay = true,
     max_lines_count = 80,
     max_labels_count = 90,
     max_boxes_count = 8)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_DATA = "Market Data"
G_ENGINE = "Leadership Engine"
G_VISUAL = "Visual Design"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

btcSymbol = input.symbol("BINANCE:BTCUSDT", "BTC Benchmark Symbol", group = G_DATA,
     tooltip = "BTC benchmark used to measure defensive leadership and relative crypto beta.")
ethSymbol = input.symbol("BINANCE:ETHUSDT", "ETH Benchmark Symbol", group = G_DATA,
     tooltip = "ETH benchmark used to measure large-cap crypto participation.")
total2Symbol = input.symbol("CRYPTOCAP:TOTAL2", "Alt Market Cap Symbol", group = G_DATA,
     tooltip = "Altcoin market-cap source excluding BTC. Used for broad alt participation.")
total3Symbol = input.symbol("CRYPTOCAP:TOTAL3", "High Beta Alt Symbol", group = G_DATA,
     tooltip = "Altcoin market-cap source excluding BTC and ETH. Used as a high-beta breadth proxy.")
btcDomSymbol = input.symbol("CRYPTOCAP:BTC.D", "BTC Dominance Symbol", group = G_DATA,
     tooltip = "BTC dominance source. Rising dominance often reflects defensive leadership.")
ethDomSymbol = input.symbol("CRYPTOCAP:ETH.D", "ETH Dominance Symbol", group = G_DATA,
     tooltip = "ETH dominance source. Used to identify ETH-led participation.")

momentumLen = input.int(21, "Leadership Momentum Length", minval = 5, maxval = 120, group = G_ENGINE,
     tooltip = "Measures relative performance and dominance shifts across the leadership window.")
baselineLen = input.int(55, "Leadership Baseline Length", minval = 20, maxval = 240, group = G_ENGINE,
     tooltip = "Controls the slower baseline used for leadership persistence and trend context.")
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 80, group = G_ENGINE,
     tooltip = "Measures chart volatility for spacing and visual scaling.")
leadThreshold = input.float(1.20, "Leadership Edge Threshold", minval = 0.10, maxval = 10.0, step = 0.05, group = G_ENGINE,
     tooltip = "Minimum rank-score distance required before a leader is considered clear.")
betaThreshold = input.float(1.00, "Chart Beta Threshold", minval = 0.10, maxval = 10.0, step = 0.05, group = G_ENGINE,
     tooltip = "Relative chart beta needed before the active symbol is treated as expanding versus BTC.")
persistenceBars = input.int(8, "Persistence Bars", minval = 3, maxval = 50, group = G_ENGINE,
     tooltip = "Measures whether leadership remains persistent instead of appearing as one-bar noise.")
confirmedTransitionsOnly = input.bool(true, "Confirm Transitions on Bar Close", group = G_ENGINE,
     tooltip = "When enabled, leadership events and alerts are emitted only after the chart bar closes. Live ladder values continue to update intrabar.")

showLeadershipLadder = input.bool(true, "Show Leadership Ladder", group = G_VISUAL,
     tooltip = "Shows the right-side rank ladder for BTC, ETH, alt beta, and chart beta.")
showLadderBackdrop = input.bool(true, "Show Ladder Backdrop", group = G_VISUAL,
     tooltip = "Adds a compact framed backdrop behind the rank ladder so the structure reads as a single premium map.")
showLeadershipPath = input.bool(true, "Show Leadership Path", group = G_VISUAL,
     tooltip = "Shows the live leadership path on price for first-glance context.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows selective event labels for major leadership transitions.")
showRankMarkers = input.bool(false, "Show Compact Rank Markers", group = G_VISUAL,
     tooltip = "Optional compact markers for leadership events. Default is off for a clean publication screenshot.")
showBarColors = input.bool(false, "Color Bars by Leadership", group = G_VISUAL,
     tooltip = "Optionally colors candles by leadership state.")
ladderProjectionBars = input.int(34, "Ladder Projection Bars", minval = 10, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how far the right-side leadership ladder extends.")
rowGapAtr = input.float(0.85, "Ladder Row Gap ATR", minval = 0.30, maxval = 3.0, step = 0.02, group = G_VISUAL,
     tooltip = "ATR-based vertical spacing between ladder rows.")
labelCooldownBars = input.int(36, "Event Label Cooldown", minval = 5, maxval = 160, group = G_VISUAL,
     tooltip = "Controls spacing between event labels.")
maxEventLabels = input.int(6, "Maximum Event Labels", minval = 1, maxval = 20, group = G_VISUAL,
     tooltip = "Limits event-label count to preserve a premium chart.")
eventScoreFloor = input.int(55, "Event Score Floor", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum leader score needed before transition labels are printed.")
labelOffsetAtr = input.float(1.10, "Label Offset ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "Moves event labels away from candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard panel location.")
panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard panel theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard panel font size.")

alertBtcLead = input.bool(true, "Alert: BTC Leadership", group = G_ALERTS,
     tooltip = "Triggers when BTC defensive leadership becomes the dominant rank state.")
alertEthLead = input.bool(true, "Alert: ETH Leadership", group = G_ALERTS,
     tooltip = "Triggers when ETH leadership becomes the dominant rank state.")
alertAltLead = input.bool(true, "Alert: Alt Beta Leadership", group = G_ALERTS,
     tooltip = "Triggers when broad alt beta becomes the dominant rank state.")
alertChartBeta = input.bool(true, "Alert: Chart Beta Expansion", group = G_ALERTS,
     tooltip = "Triggers when the active chart begins expanding versus BTC.")
alertSplit = input.bool(true, "Alert: Split Leadership", group = G_ALERTS,
     tooltip = "Triggers when leadership is mixed and no clean leader controls the ladder.")

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

// Segment colors mapped to the AG Pro core palette
btcColor = neutralColor
ethColor = accentColor
altColor = bullColor
chartColor = bearColor
splitColor = panelLabelCol

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float low, float high) =>
    math.min(math.max(value, low), high)

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.###") + "%"

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(int(math.round(value)))

f_bg(string themeInput) =>
    themeInput == "Light" ? color.rgb(248, 250, 252) : panelBg

f_label_col(string themeInput) =>
    themeInput == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_value_col(string themeInput) =>
    themeInput == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_chg(float src, int len) =>
    not na(src) and not na(src[len]) and src[len] != 0.0 ? (src - src[len]) / src[len] * 100.0 : na

f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float luminance = (0.299 * r + 0.587 * g + 0.114 * b)
    luminance > 155.0 ? color.rgb(15, 23, 42) : color.white

f_rank_color(string rankName) =>
    rankName == "BTC" ? btcColor :
     rankName == "ETH" ? ethColor :
     rankName == "ALT" ? altColor : chartColor

f_state_color(string stateName) =>
    stateName == "BTC Leadership" ? btcColor :
     stateName == "ETH Leadership" ? ethColor :
     stateName == "Alt Beta Lead" ? altColor :
     stateName == "Chart Beta Expansion" ? chartColor :
     stateName == "Split Leadership" ? splitColor :
     stateName == "Data Missing" ? neutralColor : accentColor

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput))

f_event_label(array<label> labelArray, int x, float y, string txt, color bgCol, bool upward, string sizeInput, int maxCount) =>
    label newLabel = label.new(x = x, y = y, text = txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, color = bgCol, textcolor = f_text_on(bgCol), size = f_size(sizeInput), textalign = text.align_center)
    array.push(labelArray, newLabel)
    if array.size(labelArray) > maxCount
        label oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

f_rank_name(float btcScore, float ethScore, float altScore, float chartScore, int rankNo) =>
    float top1 = math.max(math.max(btcScore, ethScore), math.max(altScore, chartScore))
    string n1 = top1 == altScore ? "ALT" : top1 == ethScore ? "ETH" : top1 == chartScore ? "CHART" : "BTC"
    float b2 = n1 == "BTC" ? -100000.0 : btcScore
    float e2 = n1 == "ETH" ? -100000.0 : ethScore
    float a2 = n1 == "ALT" ? -100000.0 : altScore
    float c2 = n1 == "CHART" ? -100000.0 : chartScore
    float top2 = math.max(math.max(b2, e2), math.max(a2, c2))
    string n2 = top2 == a2 ? "ALT" : top2 == e2 ? "ETH" : top2 == c2 ? "CHART" : "BTC"
    float b3 = n1 == "BTC" or n2 == "BTC" ? -100000.0 : btcScore
    float e3 = n1 == "ETH" or n2 == "ETH" ? -100000.0 : ethScore
    float a3 = n1 == "ALT" or n2 == "ALT" ? -100000.0 : altScore
    float c3 = n1 == "CHART" or n2 == "CHART" ? -100000.0 : chartScore
    float top3 = math.max(math.max(b3, e3), math.max(a3, c3))
    string n3 = top3 == a3 ? "ALT" : top3 == e3 ? "ETH" : top3 == c3 ? "CHART" : "BTC"
    rankNo == 1 ? n1 : rankNo == 2 ? n2 : n3

f_rank_score(float btcScore, float ethScore, float altScore, float chartScore, int rankNo) =>
    float top1 = math.max(math.max(btcScore, ethScore), math.max(altScore, chartScore))
    string n1 = top1 == altScore ? "ALT" : top1 == ethScore ? "ETH" : top1 == chartScore ? "CHART" : "BTC"
    float b2 = n1 == "BTC" ? -100000.0 : btcScore
    float e2 = n1 == "ETH" ? -100000.0 : ethScore
    float a2 = n1 == "ALT" ? -100000.0 : altScore
    float c2 = n1 == "CHART" ? -100000.0 : chartScore
    float top2 = math.max(math.max(b2, e2), math.max(a2, c2))
    string n2 = top2 == a2 ? "ALT" : top2 == e2 ? "ETH" : top2 == c2 ? "CHART" : "BTC"
    float bb3 = n1 == "BTC" or n2 == "BTC" ? -100000.0 : btcScore
    float ee3 = n1 == "ETH" or n2 == "ETH" ? -100000.0 : ethScore
    float aa3 = n1 == "ALT" or n2 == "ALT" ? -100000.0 : altScore
    float cc3 = n1 == "CHART" or n2 == "CHART" ? -100000.0 : chartScore
    float top3 = math.max(math.max(bb3, ee3), math.max(aa3, cc3))
    rankNo == 1 ? top1 : rankNo == 2 ? top2 : top3

// --------------------------------------------------
// Market Data and Engine
// --------------------------------------------------
btcClose = request.security(btcSymbol, timeframe.period, close, ignore_invalid_symbol = true)
ethClose = request.security(ethSymbol, timeframe.period, close, ignore_invalid_symbol = true)
total2Close = request.security(total2Symbol, timeframe.period, close, ignore_invalid_symbol = true)
total3Close = request.security(total3Symbol, timeframe.period, close, ignore_invalid_symbol = true)
btcDom = request.security(btcDomSymbol, timeframe.period, close, ignore_invalid_symbol = true)
ethDom = request.security(ethDomSymbol, timeframe.period, close, ignore_invalid_symbol = true)

chartChange = f_chg(close, momentumLen)
btcChange = f_chg(btcClose, momentumLen)
ethChange = f_chg(ethClose, momentumLen)
total2Change = f_chg(total2Close, momentumLen)
total3Change = f_chg(total3Close, momentumLen)
btcDomChange = f_chg(btcDom, momentumLen)
ethDomChange = f_chg(ethDom, momentumLen)

dataReady = not na(btcChange) and not na(ethChange) and not na(total2Change) and not na(total3Change) and not na(btcDomChange)
safeAtr = math.max(ta.atr(atrLen), syminfo.mintick * 20.0)
trendFast = ta.ema(close, math.max(5, int(math.round(momentumLen * 0.45))))
trendSlow = ta.ema(close, baselineLen)
trendUp = trendFast > trendSlow
trendDown = trendFast < trendSlow

btcScoreRaw = dataReady ? btcChange + btcDomChange * 1.80 - total3Change * 0.25 : na
ethScoreRaw = dataReady ? ethChange - btcChange * 0.35 + nz(ethDomChange, 0.0) * 1.45 : na
altScoreRaw = dataReady ? total3Change - btcChange * 0.55 - btcDomChange * 1.65 : na
chartScoreRaw = dataReady ? chartChange - btcChange + (trendUp ? 0.60 : trendDown ? -0.60 : 0.0) : na

btcScore = dataReady ? f_clamp(50.0 + btcScoreRaw * 4.0, 0.0, 100.0) : na
ethScore = dataReady ? f_clamp(50.0 + ethScoreRaw * 4.0, 0.0, 100.0) : na
altScore = dataReady ? f_clamp(50.0 + altScoreRaw * 4.0, 0.0, 100.0) : na
chartScore = dataReady ? f_clamp(50.0 + chartScoreRaw * 4.0, 0.0, 100.0) : na

rank1Name = dataReady ? f_rank_name(btcScore, ethScore, altScore, chartScore, 1) : "n/a"
rank2Name = dataReady ? f_rank_name(btcScore, ethScore, altScore, chartScore, 2) : "n/a"
rank3Name = dataReady ? f_rank_name(btcScore, ethScore, altScore, chartScore, 3) : "n/a"
rank1Score = dataReady ? f_rank_score(btcScore, ethScore, altScore, chartScore, 1) : na
rank2Score = dataReady ? f_rank_score(btcScore, ethScore, altScore, chartScore, 2) : na
rank3Score = dataReady ? f_rank_score(btcScore, ethScore, altScore, chartScore, 3) : na
edge = dataReady ? rank1Score - rank2Score : na

btcLead = dataReady and rank1Name == "BTC" and edge >= leadThreshold * 2.0
ethLead = dataReady and rank1Name == "ETH" and edge >= leadThreshold * 2.0
altLead = dataReady and rank1Name == "ALT" and edge >= leadThreshold * 2.0
chartBetaLead = dataReady and rank1Name == "CHART" and chartScoreRaw >= betaThreshold
splitLeadership = dataReady and edge < leadThreshold * 2.0

stateText = not dataReady ? "Data Missing" :
     splitLeadership ? "Split Leadership" :
     btcLead ? "BTC Leadership" :
     ethLead ? "ETH Leadership" :
     altLead ? "Alt Beta Lead" :
     chartBetaLead ? "Chart Beta Expansion" : "Balanced Leadership"

directionText = not dataReady ? "Check Sources" :
     btcLead ? "Defensive BTC Lead" :
     ethLead ? "ETH Participation" :
     altLead ? "Alt Risk-On Lead" :
     chartBetaLead ? "Chart Outperforming" :
     splitLeadership ? "Mixed Rotation" : "Balanced Rotation"

gradeText = not dataReady ? "No Data" :
     edge >= 18.0 ? "Dominant" :
     edge >= 10.0 ? "Strong" :
     edge >= 5.0 ? "Developing" :
     splitLeadership ? "Split" : "Thin"

stateColor = f_state_color(stateText)
stateTextColor = f_text_on(stateColor)
leaderScore = dataReady ? f_clamp(rank1Score, 0.0, 100.0) : na
persistenceScore = dataReady ? f_clamp(ta.sma(stateText == stateText[1] ? 100.0 : 0.0, persistenceBars), 0.0, 100.0) : na
betaSpread = dataReady ? chartChange - btcChange : na
altSpread = dataReady ? total3Change - btcChange : na

// --------------------------------------------------
// Leadership Ladder (framed, ranked segments)
// --------------------------------------------------
var box ladderBox = na
var label ladderBadge = na
var array<label> ladderRows = array.new<label>()
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na

pathRaw = dataReady ? hlc3 + safeAtr * f_clamp((leaderScore - 50.0) / 42.0, -1.2, 1.2) : na
path = ta.ema(pathRaw, math.max(3, int(math.round(momentumLen * 0.35))))
pathBase = ta.ema(path, math.max(5, int(math.round(baselineLen * 0.35))))

if barstate.islast
    if array.size(ladderRows) > 0
        for i = 0 to array.size(ladderRows) - 1
            label.delete(array.get(ladderRows, i))
        array.clear(ladderRows)

    if showLeadershipLadder and dataReady
        array<string> segN = array.from("BTC", "ETH", "ALT", "CHART")
        array<float> segS = array.from(btcScore, ethScore, altScore, chartScore)
        for i = 0 to 2
            int mx = i
            for j = i + 1 to 3
                if array.get(segS, j) > array.get(segS, mx)
                    mx := j
            if mx != i
                float ts = array.get(segS, i)
                array.set(segS, i, array.get(segS, mx))
                array.set(segS, mx, ts)
                string tn = array.get(segN, i)
                array.set(segN, i, array.get(segN, mx))
                array.set(segN, mx, tn)

        int nSeg = 4
        float rowStep = safeAtr * rowGapAtr
        float startY = close + rowStep * (nSeg - 1) / 2.0
        int leftX = bar_index + 4
        int endX = bar_index + ladderProjectionBars
        int centerX = int(math.round((leftX + endX) * 0.50))
        float badgeY = startY + rowStep * 0.95

        if showLadderBackdrop
            float boxTop = badgeY + rowStep * 0.55
            float boxBot = startY - rowStep * (nSeg - 1) - rowStep * 0.55
            if na(ladderBox)
                ladderBox := box.new(bar_index + 2, boxTop, endX, boxBot, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 92), border_color = color.new(stateColor, 35), border_width = 1)
            else
                box.set_lefttop(ladderBox, bar_index + 2, boxTop)
                box.set_rightbottom(ladderBox, endX, boxBot)
                box.set_bgcolor(ladderBox, color.new(stateColor, 92))
                box.set_border_color(ladderBox, color.new(stateColor, 35))
        else
            if not na(ladderBox)
                box.delete(ladderBox)
                ladderBox := na

        string badgeText = "Leadership  " + gradeText + " / " + f_score(leaderScore)
        if na(ladderBadge)
            ladderBadge := label.new(centerX, badgeY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = stateTextColor, size = f_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(ladderBadge, centerX, badgeY)
            label.set_text(ladderBadge, badgeText)
            label.set_color(ladderBadge, color.new(stateColor, 0))
            label.set_textcolor(ladderBadge, stateTextColor)
            label.set_size(ladderBadge, f_size(labelSizeInput))
            label.set_style(ladderBadge, label.style_label_center)

        for i = 0 to nSeg - 1
            float rY = startY - i * rowStep
            string nm = array.get(segN, i)
            float sc = array.get(segS, i)
            color rc = f_rank_color(nm)
            string rowTxt = "#" + str.tostring(i + 1) + "  " + nm + "   " + f_score(sc)
            label rl = label.new(leftX, rY, rowTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(rc, i == 0 ? 0 : 12), textcolor = f_text_on(rc), size = f_size(labelSizeInput))
            array.push(ladderRows, rl)
    else
        if not na(ladderBox)
            box.delete(ladderBox)
            ladderBox := na
        if not na(ladderBadge)
            label.set_text(ladderBadge, "")
            label.set_color(ladderBadge, color.new(color.black, 100))
            label.set_textcolor(ladderBadge, color.new(color.black, 100))

plot(showLeadershipPath and dataReady ? path : na, "Leadership Path", color = color.new(stateColor, 0), linewidth = 2)
plot(showLeadershipPath and dataReady ? pathBase : na, "Leadership Baseline", color = color.new(accentColor, 25), linewidth = 2)

transitionConfirmed = not confirmedTransitionsOnly or barstate.isconfirmed
newState = dataReady and bar_index > 0 and stateText != stateText[1]
confirmedStateChange = transitionConfirmed and newState
canLabel = showEventLabels and confirmedStateChange and leaderScore >= eventScoreFloor and (na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars)
btcEvent = btcLead and canLabel
ethEvent = ethLead and canLabel
altEvent = altLead and canLabel
chartEvent = chartBetaLead and canLabel
splitEvent = splitLeadership and canLabel

if btcEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "BTC Shield Lead\nQ " + f_score(leaderScore), btcColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if ethEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "ETH Leadership\nQ " + f_score(leaderScore), ethColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if altEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Alt Beta Lead\nQ " + f_score(leaderScore), altColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if chartEvent
    f_event_label(eventLabels, bar_index, low - safeAtr * labelOffsetAtr, "Chart Beta Expansion\nQ " + f_score(leaderScore), chartColor, true, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index
if splitEvent
    f_event_label(eventLabels, bar_index, high + safeAtr * labelOffsetAtr, "Split Leadership\nQ " + f_score(leaderScore), splitColor, false, labelSizeInput, maxEventLabels)
    lastLabelBar := bar_index

markerReady = showRankMarkers and dataReady and transitionConfirmed and (bar_index % math.max(8, int(math.round(labelCooldownBars * 0.60))) == 0 or confirmedStateChange)
plotshape(markerReady and btcLead, "BTC Leadership Marker", style = shape.circle, location = location.abovebar, color = color.new(btcColor, 0), size = size.tiny, text = "B", textcolor = color.rgb(15, 23, 42))
plotshape(markerReady and ethLead, "ETH Leadership Marker", style = shape.diamond, location = location.belowbar, color = color.new(ethColor, 0), size = size.tiny, text = "E", textcolor = color.rgb(15, 23, 42))
plotshape(markerReady and altLead, "Alt Beta Marker", style = shape.triangleup, location = location.belowbar, color = color.new(altColor, 0), size = size.tiny, text = "A", textcolor = color.rgb(15, 23, 42))
plotshape(markerReady and splitLeadership, "Split Leadership Marker", style = shape.square, location = location.abovebar, color = color.new(splitColor, 0), size = size.tiny, text = "S", textcolor = color.white)
barcolor(showBarColors ? color.new(stateColor, 74) : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPositionInput), 4, 8, bgcolor = f_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if showPanel and not na(panel)
    color panelBodyBg = f_bg(panelThemeInput)
    color panelLabel = f_label_col(panelThemeInput)
    color panelValue = f_value_col(panelThemeInput)
    table.clear(panel, 0, 0, 3, 7)
    table.merge_cells(panel, 0, 0, 3, 0)
    f_panel_cell(panel, 0, 0, "AG Pro Crypto Beta Leadership Ladder", headerText, headerBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 1, "State", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 1, stateText, stateColor, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 1, "Score", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 1, f_score(leaderScore), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 2, "Leader", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 2, rank1Name, panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 2, "Edge", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 2, f_score(edge), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 3, "BTC Mom", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 3, f_pct(btcChange), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 3, "ETH Mom", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 3, f_pct(ethChange), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 4, "Alt Beta", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 4, f_pct(altSpread), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 4, "Chart Beta", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 4, f_pct(betaSpread), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 5, "Direction", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 5, directionText, panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 5, "Grade", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 5, gradeText, panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 6, "BTC.D", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 6, f_pct(btcDomChange), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 6, "Persist", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 6, f_score(persistenceScore), panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 0, 7, "Read", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 1, 7, "Attention Marker", panelValue, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 2, 7, "Not", panelLabel, panelBodyBg, panelFontSizeInput)
    f_panel_cell(panel, 3, 7, "Prediction", panelValue, panelBodyBg, panelFontSizeInput)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""
    panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertBtcLead and btcLead and confirmedStateChange, "BTC Leadership Active", "BTC defensive leadership is active on {{ticker}} after the selected transition confirmation.")
alertcondition(alertEthLead and ethLead and confirmedStateChange, "ETH Leadership Active", "ETH leadership is active on {{ticker}} after the selected transition confirmation.")
alertcondition(alertAltLead and altLead and confirmedStateChange, "Alt Beta Leadership Active", "Alt beta leadership is active on {{ticker}} after the selected transition confirmation.")
alertcondition(alertChartBeta and chartBetaLead and confirmedStateChange, "Chart Beta Expansion Active", "The active chart is expanding versus BTC on {{ticker}} after the selected transition confirmation.")
alertcondition(alertSplit and splitLeadership and confirmedStateChange, "Split Leadership Active", "Crypto leadership is split on {{ticker}} after the selected transition confirmation.")
````
