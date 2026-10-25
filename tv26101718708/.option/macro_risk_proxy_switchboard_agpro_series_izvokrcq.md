# Macro Risk Proxy Switchboard [AGPro Series]

- url: https://www.tradingview.com/script/izvokrcQ-Macro-Risk-Proxy-Switchboard-AGPro-Series/
- type: indicator
- pine_id: PUB;87b3cac553b4443fbe8f327d7e3568ce
- version: 4.0

## Description

Macro Risk Proxy Switchboard [AGPro Series]

🧠 Core Idea

Are macro risk proxies supporting risk appetite, warning of defense, or sending a mixed signal?


📌 Overview / What it does

Macro Risk Proxy Switchboard [AGPro Series] is a macro context tool that compares multiple external risk proxies and converts them into a clean risk-on / risk-off switchboard.

The script uses configurable proxy symbols such as dollar pressure, yield pressure, volatility pressure, and credit appetite. It normalizes their recent movement, evaluates agreement, detects shock or divergence behavior, and displays the current macro regime directly on the chart.

It produces a macro risk rail, compact alignment labels, right-side regime tags, and a structured AG Pro panel. It does not predict price direction, automate decisions, or claim that macro proxies must control the chart.


🎯 Purpose & Design Philosophy

This script was built to solve a common context problem: traders often watch several macro proxies, but the information is scattered across different charts.

Macro Risk Proxy Switchboard compresses that context into one visual layer. It helps traders understand whether external risk conditions are supportive, defensive, mixed, or shocked.

The mindset is simple: price action matters first, but macro pressure can change the quality of breakouts, pullbacks, risk appetite, and continuation attempts.


⚡ Why This Script Is Different

Most tools focus only on the charted symbol.

This script does NOT treat macro data as a prediction engine.

Instead, it reads a configurable basket of risk proxies and asks whether those proxies agree, diverge, or create an external pressure warning.

The result is not a buy or sell signal. It is a compact macro context layer designed to improve situational awareness.


⚙️ Methodology

1. Proxy Selection

The script reads four configurable proxies: dollar pressure, yield pressure, volatility pressure, and credit appetite.

2. Proxy Normalization

Each proxy is measured by recent momentum and normalized against its own historical behavior so the readings can be compared.

3. Composite Evaluation

The script combines proxy pressure into a composite risk score and measures how many proxies agree with the current regime.

4. Visual Output

The output is displayed through a macro risk rail, event labels, right-side regime tags, and a clean AG Pro panel.


🗺️ How to Read the Chart

The macro rail represents the current external risk context.

Labels show important macro events such as risk-on alignment, risk-off alignment, proxy shock, or macro divergence.

Colors separate supportive, defensive, neutral, and shock-style behavior.

The panel shows macro regime, risk direction, composite pressure, agreement count, dominant proxy, individual proxy pressure, credit pressure, quality score, and next context.


🚦 Signals & States

• RISK-ON ALIGN → macro proxies are broadly supportive of risk appetite

• RISK-OFF ALIGN → macro proxies are broadly defensive or risk restrictive

• MIXED PROXIES → proxy agreement is weak or divided

• PROXY SHOCK → at least one proxy shows unusually strong pressure

• NEUTRAL BOARD → no clear macro tilt is active


🔔 Alerts Logic

Alerts trigger when the script detects risk-on alignment, risk-off alignment, proxy shock, or macro proxy divergence.

These alerts are attention markers only. They highlight a change in macro context, not a trading instruction.


🧩 Confluence Logic

The strongest macro context appears when multiple proxies point in the same direction and the composite score is strong.

When price structure, market trend, and macro proxy alignment agree, the context becomes more coherent.

When price action and macro pressure disagree, the chart should be interpreted with more caution.


📊 When to Use

• Crypto risk-on / risk-off evaluation

• Equity index context

• Breakout quality review

• Pullback environment analysis

• Volatility expansion periods

• Comparing price behavior against external macro pressure


⚠️ When NOT to Use

• When proxy symbols are unavailable on the selected TradingView data plan

• During market holidays where proxy data may be stale

• On very low-liquidity symbols where local behavior dominates

• When using macro context as a standalone trade trigger

• When ignoring the chart’s own structure, liquidity, and volatility


🎛️ Key Inputs

• Dollar Pressure Proxy → default DXY-style risk pressure input

• Yield Pressure Proxy → default 10-year yield-style pressure input

• Volatility Proxy → default VIX-style defensive pressure input

• Credit Appetite Proxy → default HYG-style risk appetite input

• Proxy Momentum Length → controls how recent proxy movement is measured

• Proxy Rank Length → controls normalization stability

• Agreement Threshold → controls how strict risk-on/risk-off classification is

• Visual settings → control panel, rail, labels, and readability


🖥️ Interface & Visual Design

The interface is designed as a switchboard, not a traditional oscillator.

The panel carries the macro logic, while the chart displays only the most important regime rail and event labels.

This keeps the chart clean while still giving the viewer a premium first-glance macro context.


🧪 Practical Usage Workflow

1. Read the panel macro regime

2. Check risk direction and composite score

3. Review agreement count and dominant proxy

4. Compare macro rail with current price structure

5. Treat divergence or proxy shock as context requiring extra caution


🔍 Interpretation Guidelines

A risk-on reading does not guarantee upside.

A risk-off reading does not guarantee downside.

A proxy shock means external pressure is elevated and should be reviewed.

A mixed board means macro proxies are not giving a clean message.

The best use is to combine this switchboard with price action, structure, volatility, liquidity, and timeframe context.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed buy or sell signals.

It does not claim that macro proxies always lead price.


⚠️ Limitations & Transparency

Proxy symbols may behave differently across asset classes.

Some symbols may have delayed or unavailable data depending on the user’s TradingView access.

Macro relationships can change over time.

Short-term price action can diverge from macro context for long periods.

Users should always interpret the switchboard within broader market conditions.


🧠 Market Context Notes

Macro context is most useful when it helps explain the quality of risk appetite.

Dollar pressure, yield pressure, volatility pressure, and credit appetite can all influence how traders interpret continuation, rejection, and acceptance behavior.

The script is built to simplify that context, not to replace the chart.


🧾 Use Case Examples

When price attempts a breakout while the switchboard shows risk-on alignment, the trader can evaluate whether external conditions support the move.

When price is holding support but the switchboard prints proxy shock, the trader can watch for defensive pressure.

When price trends strongly while macro proxies remain mixed, the trader can treat the move as less confirmed by external context.


🧱 System Philosophy

Macro Risk Proxy Switchboard follows the AGPro Series philosophy: clean decision-support tools that turn complex market context into readable, premium visual structure.

The script focuses on interpretation quality, not prediction claims.


🔐 Non-Promise Statement

No proxy basket can know the future.

No macro signal guarantees price direction.

This tool provides structured context only.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly.

All decisions remain the responsibility of the user.

This script does not provide financial advice or guaranteed trading outcomes.


📚 Educational Note

Use this script as an educational and analytical companion for studying macro pressure, risk appetite, defensive conditions, and cross-market context.

## Source Code

````pine
// --------------------------------------------------
// Macro Risk Proxy Switchboard [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Macro Risk Proxy Switchboard is a macro risk proxy dashboard and chart map
// that studies whether external risk proxies are supporting or resisting the
// current market environment. It compares configurable proxies such as dollar
// pressure, yields, volatility, and credit appetite to build a clean risk-on /
// risk-off switchboard for context, not prediction.
// Version 1.3 moves the live rail into forward chart space and adds dynamically
// staggered, connector-owned quality and regime badges.
// --------------------------------------------------

//@version=6
indicator("Macro Risk Proxy Switchboard [AGPro Series]",
     shorttitle = "AG Pro MRP",
     overlay = true,
     max_labels_count = 140,
     max_boxes_count = 10,
     max_lines_count = 50,
     dynamic_requests = true)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_PROXY = "Macro Proxies"
string proxyTf = input.timeframe("", "Proxy Timeframe", group = G_PROXY,
     tooltip = "Timeframe used for proxy calculations. Leave empty to use the chart timeframe.")
string dollarProxy = input.symbol("TVC:DXY", "Dollar Pressure Proxy", group = G_PROXY,
     tooltip = "Default risk-off proxy. A rising dollar often represents tighter global risk appetite.")
string yieldProxy = input.symbol("TVC:US10Y", "Yield Pressure Proxy", group = G_PROXY,
     tooltip = "Default yield proxy. Rising yields may pressure risk assets depending on macro context.")
string volProxy = input.symbol("TVC:VIX", "Volatility Proxy", group = G_PROXY,
     tooltip = "Default volatility proxy. Rising volatility often signals defensive behavior.")
string creditProxy = input.symbol("AMEX:HYG", "Credit Appetite Proxy", group = G_PROXY,
     tooltip = "Default credit appetite proxy. Rising credit appetite can support risk-on context.")

string G_CORE = "Core Logic"
int momentumLength = input.int(12, "Proxy Momentum Length", minval = 3, maxval = 80, group = G_CORE,
     tooltip = "Measures recent percentage change in each macro proxy.")
int rankLength = input.int(80, "Proxy Rank Length", minval = 30, maxval = 260, group = G_CORE,
     tooltip = "Normalizes proxy movement into a comparable pressure score.")
float agreementThreshold = input.float(18.0, "Agreement Threshold", minval = 5.0, maxval = 45.0, step = 1.0, group = G_CORE,
     tooltip = "Minimum composite pressure required to classify a risk-on or risk-off regime.")
float shockThreshold = input.float(62.0, "Proxy Shock Threshold", minval = 40.0, maxval = 90.0, step = 1.0, group = G_CORE,
     tooltip = "Minimum single-proxy pressure needed to mark a macro shock label.")

string G_VISUAL = "Visual Design"
bool showRiskRail = input.bool(true, "Show Risk Rail", group = G_VISUAL,
     tooltip = "Displays a recent macro risk rail on the chart.")
bool showRailFill = input.bool(false, "Show Rail Fill", group = G_VISUAL,
     tooltip = "Adds a light fill between the macro risk rails. Disabled by default for a cleaner publication chart.")
bool showBackgroundTint = input.bool(false, "Color Background by Regime", group = G_VISUAL,
     tooltip = "Optionally applies a very light chart background tint by macro regime. Disabled by default to avoid overpowering candles.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact macro alignment, divergence, and shock labels.")
bool showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows the current macro regime and composite risk score at the right side of the chart.")
int railBars = input.int(76, "Visible Risk Rail Bars", minval = 30, maxval = 220, group = G_VISUAL,
     tooltip = "Controls how many recent bars are covered by the visible macro risk rail.")
int projectionBars = input.int(24, "Rail Projection Bars", minval = 8, maxval = 90, group = G_VISUAL,
     tooltip = "Controls how far the macro risk rail is projected to the right.")
int boardHistoryBars = input.int(0, "Rail History Bars", minval = 0, maxval = 120, group = G_VISUAL,
     tooltip = "Controls how far the live switchboard reaches into historical candles. Zero keeps the board entirely in forward chart space for a cleaner default view.")
int labelCooldownBars = input.int(30, "Event Label Cooldown", minval = 8, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum number of bars between event labels. Higher values reduce label density.")
int maxEventLabels = input.int(8, "Maximum Event Labels", minval = 4, maxval = 30, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
float labelOffsetAtr = input.float(0.82, "Label Offset ATR", minval = 0.20, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Distance between event labels and candles, measured in ATR.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

string G_PANEL = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro information panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls where the AG Pro panel is placed.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = G_PANEL,
     tooltip = "Controls the panel color theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls the font size of the panel.")

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

// --------------------------------------------------
// Helpers
// --------------------------------------------------
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

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value))

f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

f_dir_text(int direction) =>
    direction > 0 ? "Risk On" : direction < 0 ? "Risk Off" : "Neutral"

// Luminance-aware contrast text (AGPro standard: luminance 145)
f_text_on(color bgColor) =>
    float r = color.r(bgColor)
    float g = color.g(bgColor)
    float b = color.b(bgColor)
    float yiq = (r * 299.0 + g * 587.0 + b * 114.0) / 1000.0
    yiq > 145.0 ? color.rgb(15, 23, 42) : headerText

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

f_proxy_close(string symbolName) =>
    string tf = proxyTf == "" ? timeframe.period : proxyTf
    request.security(symbolName, tf, close, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol = true)

f_pressure(float proxyClose, bool riskOnWhenUp) =>
    float refClose = nz(proxyClose[momentumLength], proxyClose)
    float rocValue = refClose != 0.0 ? (proxyClose / refClose - 1.0) * 100.0 : 0.0
    float base = ta.sma(rocValue, rankLength)
    float dev = ta.stdev(rocValue, rankLength)
    float z = dev > 0.0 ? (rocValue - base) / dev : 0.0
    float raw = f_clamp(z * 25.0, -100.0, 100.0)
    riskOnWhenUp ? raw : -raw

f_set_line(line lineRef, int x1, float y1, int x2, float y2, color col, lineStyle, int widthValue) =>
    line.set_xy1(lineRef, x1, y1)
    line.set_xy2(lineRef, x2, y2)
    line.set_color(lineRef, col)
    line.set_style(lineRef, lineStyle)
    line.set_width(lineRef, widthValue)

f_set_tag(label tag, int x, float y, string labelText, color bg, labelStyle, string textSize) =>
    label.set_x(tag, x)
    label.set_y(tag, y)
    label.set_text(tag, labelText)
    label.set_color(tag, color.new(bg, 3))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, labelStyle)
    label.set_size(tag, f_size(textSize))

f_keep_label(array<label> store, label newLabel, int limit) =>
    array.push(store, newLabel)
    if array.size(store) > limit
        label oldLabel = array.shift(store)
        label.delete(oldLabel)

// Event label with vertical anti-collision so labels never stack on
// compressed or lower-timeframe views.
f_event_label(array<label> store, int x, float y, string txt, color bg, bool upward, string sizeInput, int limit, float gap) =>
    float adjY = y
    int guard = 0
    bool moved = true
    while moved and guard < 14
        moved := false
        if array.size(store) > 0
            for i = 0 to array.size(store) - 1
                label ex = array.get(store, i)
                if math.abs(label.get_x(ex) - x) <= 10 and math.abs(label.get_y(ex) - adjY) < gap
                    adjY := upward ? adjY + gap : adjY - gap
                    moved := true
                    break
        guard += 1
    label newLabel = label.new(x, adjY, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, textcolor = f_text_on(bg), color = color.new(bg, 4), size = f_size(sizeInput), textalign = text.align_center)
    f_keep_label(store, newLabel, limit)

f_panel_row(table panelRef, int row, string leftText, string rightText, color rightColor, string themeName, string sizeInput) =>
    color rowBg = f_row_bg(themeName, row)
    table.cell(panelRef, 0, row, leftText, bgcolor = rowBg, text_color = f_panel_label(themeName), text_size = f_size(sizeInput), text_halign = text.align_left)
    table.cell(panelRef, 1, row, rightText, bgcolor = rowBg, text_color = rightColor, text_size = f_size(sizeInput), text_halign = text.align_right)

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
float atrRaw = ta.atr(14)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)

float dollarClose = f_proxy_close(dollarProxy)
float yieldClose = f_proxy_close(yieldProxy)
float volClose = f_proxy_close(volProxy)
float creditClose = f_proxy_close(creditProxy)

float dollarPressure = f_pressure(dollarClose, false)
float yieldPressure = f_pressure(yieldClose, false)
float volPressure = f_pressure(volClose, false)
float creditPressure = f_pressure(creditClose, true)

float compositePressure = (dollarPressure + yieldPressure + volPressure + creditPressure) / 4.0
int riskDir = compositePressure > agreementThreshold ? 1 : compositePressure < -agreementThreshold ? -1 : 0
float pressureAbs = math.abs(compositePressure)
int agreementCount = (dollarPressure > 0 ? 1 : 0) + (yieldPressure > 0 ? 1 : 0) + (volPressure > 0 ? 1 : 0) + (creditPressure > 0 ? 1 : 0)
int offAgreementCount = (dollarPressure < 0 ? 1 : 0) + (yieldPressure < 0 ? 1 : 0) + (volPressure < 0 ? 1 : 0) + (creditPressure < 0 ? 1 : 0)
float alignmentScore = riskDir > 0 ? agreementCount * 25.0 : riskDir < 0 ? offAgreementCount * 25.0 : 50.0
float qualityScore = f_clamp(pressureAbs * 0.65 + alignmentScore * 0.35, 0.0, 100.0)

float maxProxyShock = math.max(math.max(math.abs(dollarPressure), math.abs(yieldPressure)), math.max(math.abs(volPressure), math.abs(creditPressure)))
bool macroShock = maxProxyShock >= shockThreshold
bool divergence = riskDir != 0 and (riskDir > 0 ? offAgreementCount >= 2 : agreementCount >= 2)

string stateText = macroShock ? "Proxy Shock" : divergence ? "Mixed Proxies" : riskDir > 0 ? "Risk-On Align" : riskDir < 0 ? "Risk-Off Align" : "Neutral Board"
color stateColor = macroShock ? neutralColor : riskDir > 0 ? bullColor : riskDir < 0 ? bearColor : accentColor
string nextContext = macroShock ? "Watch shock fade" : divergence ? "Wait agreement" : riskDir > 0 ? "Risk bid active" : riskDir < 0 ? "Defense active" : "Wait macro tilt"
string dominantProxy = math.abs(dollarPressure) >= math.abs(yieldPressure) and math.abs(dollarPressure) >= math.abs(volPressure) and math.abs(dollarPressure) >= math.abs(creditPressure) ? "Dollar" : math.abs(yieldPressure) >= math.abs(volPressure) and math.abs(yieldPressure) >= math.abs(creditPressure) ? "Yield" : math.abs(volPressure) >= math.abs(creditPressure) ? "Volatility" : "Credit"
string pressureRead = "D " + f_score(dollarPressure) + " / Y " + f_score(yieldPressure) + " / V " + f_score(volPressure)
string agreementRead = str.tostring(riskDir >= 0 ? agreementCount : offAgreementCount) + " / 4"

// --------------------------------------------------
// Risk Rail
// --------------------------------------------------
float visibleHigh = ta.highest(high, railBars)
float visibleLow = ta.lowest(low, railBars)
float priceSpan = math.max(visibleHigh - visibleLow, atr)
float railMid = close + (riskDir >= 0 ? priceSpan * 0.12 : -priceSpan * 0.12)
float railHalf = math.max(atr * 0.34, priceSpan * 0.026)
float railTop = railMid + railHalf
float railBottom = railMid - railHalf
int rightX = bar_index + projectionBars
int leftX = math.max(bar_index - boardHistoryBars, 0)
int railEndX = math.max(leftX + 4, rightX - 4)
int labelX = int(math.round((leftX + railEndX) * 0.5))
float fontLaneMult = labelSizeInput == "Large" ? 1.25 : labelSizeInput == "Small" ? 0.88 : labelSizeInput == "Tiny" ? 0.78 : 1.0
float tagLaneStep = math.max(atr * 0.82, railHalf * 2.4) * fontLaneMult
float qualityTagY = railTop + tagLaneStep
float stateTagY = railBottom - tagLaneStep

color hiddenColor = color.new(color.black, 100)
var box riskBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = hiddenColor, border_color = hiddenColor, border_width = 1)
var line upperRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line lowerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line centerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_dotted, width = 2)
var line qualityLead = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line stateLead = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var label railLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = f_text_on(accentColor), size = size.normal)
var label stateTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = size.normal)
var label qualityTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = size.normal)

if barstate.islast
    if showRiskRail
        box.set_left(riskBox, leftX)
        box.set_right(riskBox, railEndX)
        box.set_top(riskBox, railTop)
        box.set_bottom(riskBox, railBottom)
        box.set_bgcolor(riskBox, showRailFill ? color.new(stateColor, 90) : hiddenColor)
        box.set_border_color(riskBox, showRailFill ? color.new(stateColor, 40) : hiddenColor)
        box.set_border_width(riskBox, 1)
        f_set_line(upperRail, leftX, railTop, railEndX, railTop, color.new(stateColor, 0), line.style_solid, 2)
        f_set_line(lowerRail, leftX, railBottom, railEndX, railBottom, color.new(stateColor, 0), line.style_solid, 2)
        f_set_line(centerRail, leftX, railMid, railEndX, railMid, color.new(accentColor, 0), line.style_dotted, 2)
        f_set_tag(railLabel, labelX, railMid, "MACRO\nSWITCHBOARD", stateColor, label.style_label_center, labelSizeInput)
    else
        box.set_bgcolor(riskBox, hiddenColor)
        box.set_border_color(riskBox, hiddenColor)
        f_set_line(upperRail, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(lowerRail, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(centerRail, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(qualityLead, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(stateLead, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        label.set_text(railLabel, "")
        label.set_color(railLabel, hiddenColor)

    if showRightTags and showRiskRail
        f_set_line(qualityLead, railEndX, railTop, rightX - 1, qualityTagY, color.new(stateColor, 18), line.style_solid, 2)
        f_set_line(stateLead, railEndX, railBottom, rightX - 1, stateTagY, color.new(stateColor, 18), line.style_solid, 2)
        f_set_tag(qualityTag, rightX, qualityTagY, "QUALITY " + f_score(qualityScore), stateColor, label.style_label_left, labelSizeInput)
        f_set_tag(stateTag, rightX, stateTagY, stateText, stateColor, label.style_label_left, labelSizeInput)
    else
        f_set_line(qualityLead, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(stateLead, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        label.set_text(stateTag, "")
        label.set_text(qualityTag, "")
        label.set_color(stateTag, hiddenColor)
        label.set_color(qualityTag, hiddenColor)

bgcolor(showBackgroundTint ? (riskDir > 0 ? color.new(bullColor, 96) : riskDir < 0 ? color.new(bearColor, 96) : na) : na)

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventBar = na
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
bool alignmentEvent = riskDir != 0 and riskDir != riskDir[1]
bool shockEvent = macroShock and not macroShock[1]
bool divergenceEvent = divergence and not divergence[1]
bool eventCandidate = alignmentEvent or shockEvent or divergenceEvent
string eventText = shockEvent ? "Proxy Shock\nQ " + f_score(qualityScore) : divergenceEvent ? "Macro Divergence\nQ " + f_score(qualityScore) : riskDir > 0 ? "Risk-On Align\nQ " + f_score(qualityScore) : "Risk-Off Align\nQ " + f_score(qualityScore)
color eventColor = shockEvent ? neutralColor : divergenceEvent ? accentColor : stateColor
float eventY = riskDir < 0 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
bool eventUp = riskDir >= 0

if showEventLabels and eventCandidate and canPrintEvent
    f_event_label(eventLabels, bar_index, eventY, eventText, eventColor, eventUp, labelSizeInput, maxEventLabels, atr * 0.7)
    lastEventBar := bar_index

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = na
var string panelPosMemory = ""
var string panelThemeMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput or panelThemeMemory != panelThemeInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panel_pos(panelPositionInput), 2, 7, bgcolor = f_panel_bg(panelThemeInput), frame_color = panelBorder, frame_width = 1, border_color = panelBorder, border_width = 1)
    panelPosMemory := panelPositionInput
    panelThemeMemory := panelThemeInput

if barstate.islast
    if showPanel and not na(panel)
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Macro Risk Proxy Switchboard", text_color = f_text_on(headerBg), bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Macro Regime", stateText + " / Q " + f_score(qualityScore), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Risk Direction", f_dir_text(riskDir) + " / " + f_fmt(compositePressure), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Agreement", agreementRead + " / " + dominantProxy, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Proxy Board", pressureRead, f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Credit", f_score(creditPressure) + " / Shock " + f_score(maxProxyShock), macroShock ? neutralColor : f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Action", nextContext, stateColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelPosMemory := ""
            panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alignmentEvent and riskDir > 0, "Macro Risk-On Alignment", "Macro proxy switchboard detected risk-on alignment.")
alertcondition(alignmentEvent and riskDir < 0, "Macro Risk-Off Alignment", "Macro proxy switchboard detected risk-off alignment.")
alertcondition(shockEvent, "Macro Proxy Shock", "One or more macro proxies reached shock pressure.")
alertcondition(divergenceEvent, "Macro Proxy Divergence", "Macro proxies are diverging while composite pressure remains active.")
````
