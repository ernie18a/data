# Crypto Dominance Rotation Map [AGPro Series]

- url: https://www.tradingview.com/script/jZaBrU9i-Crypto-Dominance-Rotation-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;d39972265e0a43b5bfe6f046239aed44
- version: 4.0

## Description

Crypto Dominance Rotation Map [AGPro Series]

🧠 Core Idea

Is crypto capital rotating toward Bitcoin, Ethereum, altcoins, or defensive stablecoin exposure?


📌 Overview / What it does

Crypto Dominance Rotation Map is a crypto market regime tool built to read capital rotation through Bitcoin dominance, Ethereum dominance, broad altcoin participation, and stablecoin defensive pressure.

The script produces a four-lane rotation map, a 0-100 Risk Participation Score, curated regime labels, right-side lane tags, alert conditions, and an AG Pro panel that summarizes the active crypto capital-flow state.

It does not predict price direction, automate trades, or claim that dominance rotation will always lead to a specific outcome. It is designed as a structured market context and visualization tool.


🎯 Purpose & Design Philosophy

This script was built to fill the gap between single-symbol price indicators and broader crypto market context.

Many crypto traders watch BTC dominance, ETH dominance, altcoin market capitalization, and stablecoin dominance separately. This script brings those references into one readable rotation map so the trader can understand the current capital-flow environment faster.

The mindset is context-first: identify where attention and capital may be concentrating before interpreting individual chart setups.


⚡ Why This Script Is Different

Most tools focus on the active chart symbol or on a basket of crypto assets.

This script does NOT try to call buys or sells on one coin.

Instead, it maps dominance rotation across Bitcoin, Ethereum, altcoins, and stablecoin defense so the trader can read the broader crypto regime behind the chart.


⚙️ Methodology

1. Dominance Mapping
The script reads Bitcoin dominance, Ethereum dominance, altcoin market-cap participation, and stablecoin dominance.

2. Rotation Scoring
Each reference is converted into a normalized 0-100 lane score using configurable momentum and smoothing.

3. Regime Classification
The model classifies the active state as BTC Lead, ETH Lead, Alt Risk-On, Defensive, Rotation Watch, or Neutral.

4. Visual Output
The script plots four rotation lanes, a Risk Participation Score, event labels, right-side tags, and a compact panel.


🗺️ How to Read the Chart

BTC Lane shows whether Bitcoin dominance is gaining leadership.

ETH Lane shows whether Ethereum dominance is improving versus the broader crypto market.

Altcoin Lane shows whether broad non-Bitcoin participation is improving.

Stable Lane shows whether stablecoin dominance is rising, which may reflect defensive positioning.

The Risk Participation Score summarizes whether crypto rotation is constructive, defensive, or undecided.


🚦 Signals & States

• BTC LEAD → Bitcoin dominance is the active leadership lane.

• ETH LEAD → Ethereum dominance is leading rotation.

• ALT RISK-ON → altcoin participation is constructive and broad risk appetite is stronger.

• DEFENSIVE → stablecoin dominance pressure is elevated.

• ROTATION WATCH → no clean leader yet, but participation is improving.

• NEUTRAL → no strong capital-flow leader is confirmed.


🔔 Alerts Logic

Alerts trigger when the active rotation state changes into a major regime.

Available alert states:
• BTC Dominance Leadership
• ETH Dominance Leadership
• Altcoin Risk-On Rotation
• Defensive Stablecoin Rotation

Alerts are attention markers only. They are not trade instructions.


🧩 Confluence Logic

Context becomes stronger when the active rotation state aligns with the trader’s chart setup.

For example, an altcoin breakout may carry stronger context when the map shows Alt Risk-On. A defensive state may encourage more caution around aggressive long setups.


📊 When to Use

• Crypto market regime review
• Altcoin season / Bitcoin dominance monitoring
• Risk-on and risk-off context checks
• Higher-timeframe crypto market preparation
• Comparing individual setups with broader market rotation


⚠️ When NOT to Use

• Very low-liquidity crypto assets
• Symbols that do not respond to broader crypto conditions
• Extremely short-term scalping where dominance data is too slow
• Periods where dominance symbols are unavailable or delayed


🎛️ Key Inputs

• BTC Dominance Symbol → Bitcoin dominance reference.

• ETH Dominance Symbol → Ethereum dominance reference.

• Altcoin Market Cap Symbol → broad altcoin participation proxy.

• Stablecoin Dominance Symbol → defensive crypto positioning proxy.

• Rotation Momentum Length → how far back rotation pressure is measured.

• Rotation Smoothing → how smooth or reactive the lane map becomes.

• Risk-On / Defensive Thresholds → state classification sensitivity.


🖥️ Interface & Visual Design

The interface is designed around a four-lane map. Each lane has a clear role: BTC, ETH, ALT, and STABLE.

Event labels highlight regime changes without turning the chart into a signal board.

The panel summarizes state, risk score, lane values, dominance readings, next context, and timeframe.


🧪 Practical Usage Workflow

1. Read the panel state.
2. Check which lane is leading.
3. Compare the Risk Participation Score with the active chart idea.
4. Use labels and alerts as context markers.
5. Confirm with price structure, volume, and your own risk plan.


🔍 Interpretation Guidelines

The script should be interpreted as market context.

BTC leadership may indicate capital concentration in Bitcoin. Alt Risk-On may suggest broader participation. Defensive stablecoin rotation may indicate caution.

No state is automatically bullish or bearish for every asset.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed signals.


⚠️ Limitations & Transparency

Dominance symbols may update differently from exchange-traded instruments.

Timeframe selection can materially change the rotation read.

Crypto market conditions can shift quickly during volatility events.

The script depends on the availability and quality of the selected reference symbols.


🧠 Market Context Notes

Dominance rotation is often more useful as a background regime filter than as a direct entry signal.

The strongest use case is comparing an individual crypto setup against the broader flow of capital across Bitcoin, Ethereum, altcoins, and defensive stable exposure.


🧾 Use Case Examples

When an altcoin setup appears while the map shows Alt Risk-On, the broader participation context may be more supportive.

When Bitcoin dominance leads while altcoin participation weakens, altcoin setups may require more selectivity.

When stablecoin dominance becomes defensive, aggressive risk-on interpretations should be handled more carefully.


🔐 Non-Promise Statement

No script can provide certainty.

This tool provides structured context, not guaranteed outcomes.


📉 Risk Disclosure

Trading involves risk.

Users remain responsible for their own decisions.

This script does not provide financial advice.


📚 Educational Note

Use this script to study how crypto capital rotation changes across market regimes and how that context interacts with individual chart setups.

## Source Code

````pine
// --------------------------------------------------
// Crypto Dominance Rotation Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Crypto Dominance Rotation Map studies whether crypto capital is rotating
// toward Bitcoin dominance, Ethereum leadership, altcoin participation, or
// stablecoin defensive exposure. It converts dominance and market-cap changes
// into a four-lane rotation map, a risk participation score, transition event
// labels, alerts, and an AG Pro panel for crypto market regime review. Version
// 1.3 aligns momentum with the selected calculation timeframe and confirms
// regime leadership before committing transitions.
// --------------------------------------------------

//@version=6
indicator("Crypto Dominance Rotation Map [AGPro Series]",
     shorttitle = "AG Pro CDR",
     overlay = false,
     max_labels_count = 30,
     max_lines_count = 4,
     max_boxes_count = 2,
     dynamic_requests = true)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_SYMBOLS = "Dominance Symbols"
string G_ENGINE  = "Rotation Engine"
string G_VISUAL  = "Visual Design"
string G_PANEL   = "Panel"
string G_ALERTS  = "Alerts"

string btcDomSymbol = input.symbol("CRYPTOCAP:BTC.D", "BTC Dominance Symbol", group = G_SYMBOLS,
     tooltip = "Bitcoin dominance reference used to detect capital rotation toward Bitcoin leadership.")
string ethDomSymbol = input.symbol("CRYPTOCAP:ETH.D", "ETH Dominance Symbol", group = G_SYMBOLS,
     tooltip = "Ethereum dominance reference used to detect whether Ethereum is gaining leadership inside crypto rotation.")
string altCapSymbol = input.symbol("CRYPTOCAP:TOTAL2", "Altcoin Market Cap Symbol", group = G_SYMBOLS,
     tooltip = "Altcoin market-cap proxy used to judge broad non-Bitcoin participation.")
string stableDomSymbol = input.symbol("CRYPTOCAP:USDT.D", "Stablecoin Dominance Symbol", group = G_SYMBOLS,
     tooltip = "Stablecoin dominance proxy used to detect defensive crypto positioning and risk-off pressure.")
string calcTfInput = input.timeframe("", "Calculation Timeframe", group = G_SYMBOLS,
     tooltip = "Leave blank to use the chart timeframe. Select a higher timeframe to anchor rotation state to broader crypto context.")

int momentumLen = input.int(14, "Rotation Momentum Length", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Lookback used to measure percentage change in each dominance or market-cap reference.")
int smoothLen = input.int(5, "Rotation Smoothing", minval = 1, maxval = 80, group = G_ENGINE,
     tooltip = "EMA smoothing applied to each rotation lane so the map reads as a regime tool instead of one-bar noise.")
float scoreCap = input.float(3.0, "Score Normalization Cap %", minval = 0.25, maxval = 15.0, step = 0.25, group = G_ENGINE,
     tooltip = "Absolute percent-change level mapped to full 0-100 lane pressure. Lower values make the model more sensitive.")
int riskOnThreshold = input.int(64, "Risk-On Threshold", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Minimum participation score required before altcoin or Ethereum leadership can be treated as constructive risk-on rotation.")
int defensiveThreshold = input.int(62, "Defensive Threshold", minval = 1, maxval = 100, group = G_ENGINE,
     tooltip = "Stablecoin pressure level where the map begins to treat capital rotation as defensive.")
int leaderGap = input.int(7, "Minimum Leader Gap", minval = 0, maxval = 40, group = G_ENGINE,
     tooltip = "Minimum score advantage required before a lane is treated as the active capital-flow leader.")
int regimeConfirmBars = input.int(2, "Regime Confirm Bars", minval = 1, maxval = 10, group = G_ENGINE,
     tooltip = "Number of completed calculation-timeframe bars a candidate state must persist before leadership is committed.")
int regimeHoldWindow = input.int(10, "Regime Hold Window (bars)", minval = 2, maxval = 200, group = G_ENGINE,
     tooltip = "Number of bars a newly declared leadership regime must persist for, to count as held in the Regime Hold proof. It only measures historical regime persistence and is not a forecast.")

bool showLaneFills = input.bool(true, "Show Rotation Lane Fills", group = G_VISUAL,
     tooltip = "Displays soft filled lanes for BTC, ETH, altcoin, and defensive stablecoin rotation pressure.")
bool showRegimeRibbon = input.bool(true, "Show Active Regime Ribbon", group = G_VISUAL,
     tooltip = "Displays a right-side regime ribbon that highlights the current crypto rotation state.")
bool showStateBackdrop = input.bool(false, "Show Regime Backdrop", group = G_VISUAL,
     tooltip = "Adds a subtle pane background color that follows the active crypto rotation regime. Disabled by default for a cleaner publication view.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Prints structured transition labels when the dominant crypto rotation state changes.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact last-bar tags for BTC, ETH, altcoin, stablecoin, and risk participation lanes.")
int minimumEventQuality = input.int(60, "Minimum Event Quality", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum lane or participation score required before a confirmed historical regime event is retained.")
int labelCooldownBars = input.int(36, "Event Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL,
     tooltip = "Minimum spacing between event labels so the map remains readable and premium.")
int rightTagOffset = input.int(5, "Right Tag Offset", minval = 1, maxval = 40, group = G_VISUAL,
     tooltip = "Horizontal distance used to place right-side tags away from the last bar.")
int maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the rotation pane.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Text size used by event labels, ribbon badge, and right-side tags.")

bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro crypto rotation panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls where the panel appears on the chart.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Switches the panel between a dark AGPro surface and a clean light surface.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Text size used inside the panel.")

bool alertBtcLead = input.bool(true, "Alert: BTC Leadership", group = G_ALERTS,
     tooltip = "Enables alerts when Bitcoin dominance becomes the active rotation leader.")
bool alertEthLead = input.bool(true, "Alert: ETH Leadership", group = G_ALERTS,
     tooltip = "Enables alerts when Ethereum dominance becomes the active rotation leader.")
bool alertAltRiskOn = input.bool(true, "Alert: Altcoin Risk-On", group = G_ALERTS,
     tooltip = "Enables alerts when altcoin participation becomes the active constructive rotation state.")
bool alertDefensive = input.bool(true, "Alert: Defensive Rotation", group = G_ALERTS,
     tooltip = "Enables alerts when stablecoin dominance pressure marks a defensive crypto rotation state.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
color headerBg = color.rgb(37, 99, 235)
color headerText = color.rgb(245, 247, 250)
color panelBg = color.rgb(15, 23, 42)
color panelBorder = color.rgb(86, 103, 130)
color panelLabelCol = color.rgb(190, 202, 220)
color panelValueCol = color.rgb(245, 247, 250)
color bullColor = color.rgb(34, 197, 166)
color bearColor = color.rgb(244, 114, 182)
color neutralColor = color.rgb(245, 189, 92)
color accentColor = color.rgb(129, 140, 248)
color btcColor = color.rgb(96, 165, 250)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_size(string sizeName) =>
    sizeName == "Tiny" ? size.tiny :
     sizeName == "Small" ? size.small :
     sizeName == "Large" ? size.large : size.normal

f_panel_pos(string posName) =>
    posName == "Top Left" ? position.top_left :
     posName == "Top Center" ? position.top_center :
     posName == "Middle Right" ? position.middle_right :
     posName == "Middle Left" ? position.middle_left :
     posName == "Middle Center" ? position.middle_center :
     posName == "Bottom Right" ? position.bottom_right :
     posName == "Bottom Left" ? position.bottom_left :
     posName == "Bottom Center" ? position.bottom_center : position.top_right

f_pct_change(float src, int len) =>
    not na(src) and not na(src[len]) and src[len] != 0.0 ? 100.0 * (src / src[len] - 1.0) : 0.0

f_lane_score(float pulse, float cap) =>
    f_clamp(50.0 + f_clamp(pulse, -cap, cap) / cap * 50.0, 0.0, 100.0)

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_max4(float a, float b, float c, float d) =>
    math.max(math.max(a, b), math.max(c, d))

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
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, bgcolor = rowBg, text_color = f_panel_label(themeName), text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, bgcolor = rowBg, text_color = rightColor, text_size = f_size(sizeInput), text_halign = text.align_right)

f_keep_label(array<label> store, label newLabel, int limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

f_set_tag(label tag, int x, float y, string txt, color bg, string sizeInput) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, txt)
    label.set_color(tag, color.new(bg, 3))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, label.style_label_left)
    label.set_size(tag, f_size(sizeInput))

// --------------------------------------------------
// Data
// --------------------------------------------------
string calcTf = calcTfInput == "" ? timeframe.period : calcTfInput

[btcDom, btcPulse] = request.security(btcDomSymbol, calcTf, [close, ta.ema(f_pct_change(close, momentumLen), smoothLen)], barmerge.gaps_off, barmerge.lookahead_off)
[ethDom, ethPulse] = request.security(ethDomSymbol, calcTf, [close, ta.ema(f_pct_change(close, momentumLen), smoothLen)], barmerge.gaps_off, barmerge.lookahead_off)
[altCap, altPulse] = request.security(altCapSymbol, calcTf, [close, ta.ema(f_pct_change(close, momentumLen), smoothLen)], barmerge.gaps_off, barmerge.lookahead_off)
[stableDom, stablePulse] = request.security(stableDomSymbol, calcTf, [close, ta.ema(f_pct_change(close, momentumLen), smoothLen)], barmerge.gaps_off, barmerge.lookahead_off)

float btcScore = f_lane_score(btcPulse, scoreCap)
float ethScore = f_lane_score(ethPulse, scoreCap)
float altScore = f_lane_score(altPulse, scoreCap)
float stableScore = f_lane_score(stablePulse, scoreCap)

float riskParticipation = f_clamp(altScore * 0.45 + ethScore * 0.25 + (100.0 - stableScore) * 0.20 + (100.0 - btcScore) * 0.10, 0.0, 100.0)
float maxLane = f_max4(btcScore, ethScore, altScore, stableScore)

bool btcLead = btcScore == maxLane and btcScore >= 50.0 + leaderGap and btcScore >= ethScore + leaderGap and btcScore >= altScore + leaderGap
bool ethLead = ethScore == maxLane and ethScore >= 50.0 + leaderGap and ethScore >= btcScore + leaderGap and ethScore >= altScore + leaderGap
bool altRiskOn = altScore == maxLane and riskParticipation >= riskOnThreshold and altScore >= btcScore + leaderGap and altScore >= stableScore + leaderGap
bool defensiveFlow = stableScore >= defensiveThreshold and stableScore >= btcScore and stableScore >= ethScore and stableScore >= altScore - leaderGap
bool rotationWatch = not btcLead and not ethLead and not altRiskOn and not defensiveFlow and riskParticipation >= 50.0

int rawState = defensiveFlow ? 4 : altRiskOn ? 3 : ethLead ? 2 : btcLead ? 1 : rotationWatch ? 5 : 0
bool rotationStep = calcTf == timeframe.period ? barstate.isconfirmed : timeframe.change(calcTf) and barstate.isconfirmed
var int state = 0
var int candidateState = 0
var int candidateBars = 0

if rotationStep
    if rawState == state
        candidateState := rawState
        candidateBars := 0
    else
        if rawState == candidateState
            candidateBars += 1
        else
            candidateState := rawState
            candidateBars := 1
        if candidateBars >= regimeConfirmBars
            state := candidateState
            candidateBars := 0
string stateText = state == 4 ? "Defensive" : state == 3 ? "Alt Risk-On" : state == 2 ? "ETH Lead" : state == 1 ? "BTC Lead" : state == 5 ? "Rotation Watch" : "Neutral"
color stateColor = state == 4 ? bearColor : state == 3 ? bullColor : state == 2 ? accentColor : state == 1 ? btcColor : state == 5 ? neutralColor : color.rgb(148, 163, 184)
string nextContext = state == 4 ? "Watch defensive" : state == 3 ? "Watch alt rotation" : state == 2 ? "Watch ETH lead" : state == 1 ? "Watch BTC lead" : state == 5 ? "Watch rotation" : "Wait for leader"
string leaderText = state == 4 ? "Stable" : state == 3 ? "Altcoin" : state == 2 ? "Ethereum" : state == 1 ? "Bitcoin" : state == 5 ? "Mixed" : "None"

// --------------------------------------------------
// Visual Map
// --------------------------------------------------
float btcLane = 82.0 + (btcScore - 50.0) * 0.16
float ethLane = 58.0 + (ethScore - 50.0) * 0.16
float altLane = 34.0 + (altScore - 50.0) * 0.16
float stableLane = 10.0 + (stableScore - 50.0) * 0.16
float riskLine = riskParticipation

hline(82, "BTC Lane", color = color.new(btcColor, 70))
hline(58, "ETH Lane", color = color.new(accentColor, 70))
hline(34, "Altcoin Lane", color = color.new(bullColor, 70))
hline(10, "Stable Lane", color = color.new(bearColor, 70))
hline(50, "Risk Balance", color = color.new(panelLabelCol, 76))

btcBase = plot(showLaneFills ? 82 : na, "BTC Base", color = color.new(btcColor, 100))
ethBase = plot(showLaneFills ? 58 : na, "ETH Base", color = color.new(accentColor, 100))
altBase = plot(showLaneFills ? 34 : na, "ALT Base", color = color.new(bullColor, 100))
stableBase = plot(showLaneFills ? 10 : na, "STABLE Base", color = color.new(bearColor, 100))

btcPlot = plot(btcLane, "BTC", color = btcColor, linewidth = 2)
ethPlot = plot(ethLane, "ETH", color = accentColor, linewidth = 2)
altPlot = plot(altLane, "ALT", color = bullColor, linewidth = 3)
stablePlot = plot(stableLane, "STABLE", color = bearColor, linewidth = 2)
riskPlot = plot(riskLine, "RISK", color = stateColor, linewidth = 4)

fill(btcBase, btcPlot, color = color.new(btcColor, 91))
fill(ethBase, ethPlot, color = color.new(accentColor, 91))
fill(altBase, altPlot, color = color.new(bullColor, 90))
fill(stableBase, stablePlot, color = color.new(bearColor, 91))

bgcolor(showStateBackdrop ? color.new(stateColor, 94) : na)

// --------------------------------------------------
// Regime hold-rate proof (Confirm Rate)
// --------------------------------------------------
// When a leadership regime (BTC Lead, ETH Lead, Alt Risk-On, Defensive) is
// newly declared, does it persist for at least the hold window before changing,
// or flip away early? Counted once per leadership transition. An early flip to a
// different state is treated as not-held (conservative), and resolution at the
// hold window prevents the rate from drifting just by waiting.
bool stateChanged = rotationStep and state != state[1]
var int  rgTotal = 0
var int  rgHeld   = 0
var bool rgPend    = false
var int  rgState    = 0
var int  rgLeft      = 0

if rotationStep
    if rgPend
        if state != rgState
            rgTotal += 1
            rgPend := false
        else
            rgLeft -= 1
            if rgLeft <= 0
                rgTotal += 1
                rgHeld += 1
                rgPend := false
    if stateChanged and state >= 1 and state <= 4 and not rgPend
        rgState := state
        rgLeft := regimeHoldWindow
        rgPend := true

float rgRate = rgTotal > 0 ? rgHeld / rgTotal * 100.0 : na
string regimeHoldRead = rgTotal > 0 ? str.tostring(math.round(rgRate)) + "% | " + str.tostring(rgHeld) + "/" + str.tostring(rgTotal) : "Building"

// --------------------------------------------------
// Labels and Tags
// --------------------------------------------------
var int lastEventBar = na
var array<label> eventLabels = array.new<label>()
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
float eventQuality = state == 4 ? stableScore : state == 3 ? riskParticipation : state == 2 ? ethScore : state == 1 ? btcScore : riskParticipation
float eventY = (state == 4 ? stableLane : state == 3 ? altLane : state == 2 ? ethLane : state == 1 ? btcLane : riskLine) + 5.5
string eventText = (state == 4 ? "DEFENSIVE" : state == 3 ? "ALT RISK-ON" : state == 2 ? "ETH LEAD" : state == 1 ? "BTC LEAD" : state == 5 ? "ROTATION WATCH" : "NEUTRAL") + " | Q " + f_score(eventQuality)

if showEventLabels and stateChanged and state != 0 and eventQuality >= minimumEventQuality and canPrintEvent
    label newEvent = label.new(bar_index, eventY, eventText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(stateColor), color = color.new(stateColor, 4), size = f_size(labelSizeInput), textalign = text.align_center)
    f_keep_label(eventLabels, newEvent, maxEventLabels)
    lastEventBar := bar_index

var box regimeRibbon = box.new(bar_index, 0.0, bar_index + 1, 100.0, xloc = xloc.bar_index, bgcolor = color.new(accentColor, 100), border_color = color.new(accentColor, 100), border_width = 1)
var label ribbonLabel = label.new(bar_index, 50.0, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = color.white, size = size.normal)
var label btcTag = label.new(bar_index, 82.0, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
var label ethTag = label.new(bar_index, 58.0, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
var label altTag = label.new(bar_index, 34.0, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
var label stableTag = label.new(bar_index, 10.0, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)
var label riskTag = label.new(bar_index, 50.0, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left)

if barstate.islast
    int ribbonLeft = bar_index + math.max(1, rightTagOffset - 2)
    int ribbonRight = bar_index + rightTagOffset + 12
    if showRegimeRibbon
        box.set_left(regimeRibbon, ribbonLeft)
        box.set_right(regimeRibbon, ribbonRight)
        box.set_top(regimeRibbon, 100.0)
        box.set_bottom(regimeRibbon, 88.0)
        box.set_bgcolor(regimeRibbon, color.new(stateColor, 84))
        box.set_border_color(regimeRibbon, color.new(stateColor, 28))
        box.set_border_width(regimeRibbon, 1)
        label.set_x(ribbonLabel, int(math.round((ribbonLeft + ribbonRight) * 0.5)))
        label.set_y(ribbonLabel, 94.0)
        label.set_text(ribbonLabel, str.upper(stateText) + " | RISK " + f_score(riskParticipation))
        label.set_color(ribbonLabel, color.new(stateColor, 3))
        label.set_textcolor(ribbonLabel, f_text_on(stateColor))
        label.set_style(ribbonLabel, label.style_label_center)
        label.set_size(ribbonLabel, f_size(labelSizeInput))
    else
        box.set_bgcolor(regimeRibbon, color.new(stateColor, 100))
        box.set_border_color(regimeRibbon, color.new(stateColor, 100))
        label.set_text(ribbonLabel, "")
        label.set_color(ribbonLabel, color.new(stateColor, 100))

    if showRightTags
        int tagX = bar_index + rightTagOffset
        int riskTagX = tagX + 4
        f_set_tag(btcTag, tagX, btcLane, "BTC " + f_score(btcScore), btcColor, labelSizeInput)
        f_set_tag(ethTag, tagX, ethLane, "ETH " + f_score(ethScore), accentColor, labelSizeInput)
        f_set_tag(altTag, tagX, altLane, "ALT " + f_score(altScore), bullColor, labelSizeInput)
        f_set_tag(stableTag, tagX, stableLane, "STABLE " + f_score(stableScore), bearColor, labelSizeInput)
        f_set_tag(riskTag, riskTagX, riskLine, "RISK " + f_score(riskParticipation), stateColor, labelSizeInput)
    else
        label.set_text(btcTag, "")
        label.set_text(ethTag, "")
        label.set_text(altTag, "")
        label.set_text(stableTag, "")
        label.set_text(riskTag, "")

// --------------------------------------------------
// Panel
// --------------------------------------------------
color regimeHoldCol = na(rgRate) ? f_panel_value(panelThemeInput) : rgRate >= 60.0 ? bullColor : rgRate >= 45.0 ? neutralColor : bearColor

var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 8, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 7)
        table.cell(panel, 0, 0, "", bgcolor = headerBg)
        table.cell(panel, 1, 0, "", bgcolor = headerBg)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Crypto Dominance Rotation Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "State", stateText + " / " + f_score(riskParticipation), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Regime Hold", regimeHoldRead, regimeHoldCol, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Leader", leaderText, stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "BTC / ETH", f_score(btcScore) + " / " + f_score(ethScore), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Alt / Stable", f_score(altScore) + " / " + f_score(stableScore), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "BTC.D / ETH.D", f_fmt(btcDom) + " / " + f_fmt(ethDom), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Action / Frame", nextContext + " | " + calcTf, stateColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelPosMemory := ""
            panelThemeMemory := ""

plot(rgRate, title = "Regime Hold Rate", color = accentColor, display = display.data_window)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
bool btcLeadEvent = stateChanged and state == 1
bool ethLeadEvent = stateChanged and state == 2
bool altRiskOnEvent = stateChanged and state == 3
bool defensiveEvent = stateChanged and state == 4

alertcondition(alertBtcLead and btcLeadEvent, "BTC Dominance Leadership", "Crypto Dominance Rotation Map: Bitcoin dominance became the active rotation leader.")
alertcondition(alertEthLead and ethLeadEvent, "ETH Dominance Leadership", "Crypto Dominance Rotation Map: Ethereum dominance became the active rotation leader.")
alertcondition(alertAltRiskOn and altRiskOnEvent, "Altcoin Risk-On Rotation", "Crypto Dominance Rotation Map: Altcoin participation became the active risk-on rotation state.")
alertcondition(alertDefensive and defensiveEvent, "Defensive Stablecoin Rotation", "Crypto Dominance Rotation Map: Stablecoin dominance pressure marked a defensive crypto rotation state.")
````
