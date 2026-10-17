# Candle Intent Map [AGPro Series]

- url: https://www.tradingview.com/script/UHJTlwF9-Candle-Intent-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;8ba27e32c63b45c7bbc5c9cb7c55e31c
- version: 4.0

## Description

Candle Intent Map [AGPro Series]

🧠 Core Idea

Does this candle show initiative, absorption, rejection, indecision, or a real shift in intent?


📌 Overview / What it does

Candle Intent Map [AGPro Series] is a candle behavior and market reaction tool designed to read the internal message of price candles beyond simple bullish or bearish color.

The script evaluates body pressure, wick reaction, close location, volume context, short follow-through, and recent intent changes to classify whether the market is showing initiative, absorption, rejection, indecision, or an intent shift.

It produces compact labels, a visible intent pressure zone, right-side context tags, and a clean AG Pro panel. It does not predict price, automate decisions, or promise that a candle pattern will continue.


🎯 Purpose & Design Philosophy

This script was built because many candlestick tools stop at basic pattern recognition.

A candle is not only a shape. It is a relationship between body commitment, wick reaction, volume participation, close location, and what happens immediately after that candle forms.

Candle Intent Map helps traders who want to read candle quality, initiative pressure, reaction zones, and follow-through context without turning the chart into a crowded pattern scanner.


⚡ Why This Script Is Different

Most candle tools focus on named formations such as engulfing candles, pin bars, doji candles, or simple color changes.

This script does NOT treat every candle pattern as an automatic signal.

Instead, it studies whether the candle has enough internal pressure, reaction quality, volume context, and follow-through to deserve attention.

The goal is not to label more candles. The goal is to label the candles that tell a clearer market story.


⚙️ Methodology

1. Context Detection

The script measures body-to-range ratio, upper wick pressure, lower wick pressure, close location, and relative volume participation.

2. Intent Classification

Candles are classified into initiative, absorption, rejection, indecision, or intent shift conditions based on body pressure, wick behavior, and directional commitment.

3. Reaction Evaluation

The script builds a reaction-quality score using body strength, wick reaction, close placement, volume context, and short follow-through behavior.

4. Visual Output

The strongest current candle intent context is mapped as a visible intent zone, compact event labels, right-side state tags, and a structured AG Pro panel.


🗺️ How to Read the Chart

Zones represent the most recent candle intent pressure area.

Labels show important candle intent events such as bullish intent, bearish intent, absorption, rejection, indecision, or intent shift.

Colors separate constructive pressure, defensive pressure, neutral reaction, and absorption-style behavior.

The panel summarizes current intent, direction, body pressure, wick reaction, follow-through, quality score, and next context.


🚦 Signals & States

• BULL INTENT → bullish body pressure with meaningful close location and participation

• BEAR INTENT → bearish body pressure with meaningful close location and participation

• ABSORPTION → strong reaction behavior with compressed body and meaningful volume

• LOWER REJECT → lower wick reaction suggesting downside rejection

• UPPER REJECT → upper wick reaction suggesting upside rejection

• INDECISION → low body commitment with balanced wick behavior

• INTENT SHIFT → recent candle intent changes direction with enough pressure to matter


🔔 Alerts Logic

Alerts trigger when the script detects bullish candle intent, bearish candle intent, candle absorption, or candle intent shift.

These alerts are attention markers only. They highlight a candle context that may deserve review, not a trade instruction.


🧩 Confluence Logic

The strongest context appears when candle body pressure, wick reaction, close location, volume participation, and follow-through point in the same direction.

When these components align, the candle intent quality score becomes stronger.


📊 When to Use

• During active trend continuation phases

• Around reaction zones and pullback areas

• Near support, resistance, VWAP, or liquidity references

• When evaluating whether a candle has real participation behind it

• When comparing initiative candles against absorption or rejection candles


⚠️ When NOT to Use

• Extremely illiquid markets

• Very noisy low-timeframe environments

• News-driven candles with abnormal spreads

• Symbols with unreliable volume data

• Situations where broader market context is ignored


🎛️ Key Inputs

• Volume Context Length → controls the relative volume comparison window

• Follow-Through Length → controls how short-term continuation is measured

• Initiative Body Ratio → changes how strict the initiative candle filter is

• Reaction Wick Ratio → changes how strict wick-based rejection and absorption filters are

• Visible Zone Bars → controls how much of the recent chart the intent zone covers

• Label and Panel Font Size → controls visual readability


🖥️ Interface & Visual Design

The interface is designed to stay clean, readable, and publication-friendly.

The chart focuses on one main intent zone, compact event labels, right-side context tags, and a structured panel.

The visual hierarchy is intentional: zone first, current state second, historical intent events third.


🧪 Practical Usage Workflow

1. Read the panel to understand the current candle intent state

2. Check the intent zone and its position relative to price

3. Review recent labels to understand whether initiative, absorption, or rejection has dominated

4. Compare the quality score with current follow-through

5. Interpret the output inside broader market context


🔍 Interpretation Guidelines

A strong intent label does not mean price must continue.

A rejection label does not mean reversal is guaranteed.

An absorption label means the candle structure showed reaction and participation, but confirmation still depends on the following market behavior.

The best interpretation comes from combining candle intent with structure, liquidity, volatility, and timeframe context.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed buy or sell signals.

It does not replace risk management or independent analysis.


⚠️ Limitations & Transparency

Candlestick interpretation changes across timeframes.

Volume quality may differ between markets and exchanges.

Fast volatility expansion can make recent candle intent less stable.

Low-liquidity conditions may create misleading wick or body readings.

Users should always interpret outputs within broader market context.


🧠 Market Context Notes

Candle intent is most useful when combined with structure, liquidity, trend quality, volatility, and acceptance behavior.

One candle rarely tells the whole story. The value comes from understanding whether candle pressure is supported or rejected by what comes next.


🧾 Use Case Examples

When price reaches a known support area and the script prints a lower rejection label with improving quality, the trader can study whether downside pressure is being rejected.

When a strong body candle prints with high quality and follow-through, the trader can evaluate whether initiative pressure is entering the market.

When absorption appears inside a range, the trader can watch whether trapped pressure develops or fades.


🧱 System Philosophy

Candle Intent Map is part of the AGPro Series approach: clean visual tools that focus on market context, reaction quality, and decision support rather than prediction claims.

The script is designed to make candle behavior easier to read while keeping the trader responsible for interpretation.


🔐 Non-Promise Statement

No script can know the future.

No candle label guarantees continuation or reversal.

This tool provides structured visual context only.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly.

All decisions remain the responsibility of the user.

This script does not provide financial advice or guaranteed trading outcomes.


📚 Educational Note

Use this script as an educational and analytical companion for studying candle behavior, reaction quality, and short-term intent context.

## Source Code

````pine
// --------------------------------------------------
// Candle Intent Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Candle Intent Map is a candle intent and reaction-quality map that studies
// whether the current candle structure shows initiative, absorption, rejection,
// indecision, or an intent shift. It combines body pressure, wick behavior,
// close location, volume context, short follow-through, and a self-measured
// intent hit rate so traders can read candle intent without relying on a basic
// engulfing candle or single pin-bar marker.
// --------------------------------------------------

//@version=6
indicator("Candle Intent Map [AGPro Series]",
     shorttitle = "AG Pro CIM",
     overlay = true,
     max_labels_count = 140,
     max_boxes_count = 12,
     max_lines_count = 40)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
string G_CORE = "Core Logic"
int volumeLength = input.int(50, "Volume Context Length", minval = 20, maxval = 240, group = G_CORE,
     tooltip = "Defines the volume window used to evaluate whether a candle has meaningful participation.")
int followLength = input.int(5, "Follow-Through Length", minval = 2, maxval = 20, group = G_CORE,
     tooltip = "Measures short-term continuation after recent candle intent events.")
int proofWindowBars = input.int(5, "Intent Proof Window", minval = 2, maxval = 60, group = G_CORE,
     tooltip = "After a directional intent event (initiative or rejection), the map waits this many bars and checks whether price continued in the intent direction. Feeds the Intent Hit Rate readout in the panel.")
float bodyStrong = input.float(0.56, "Initiative Body Ratio", minval = 0.35, maxval = 0.85, step = 0.01, group = G_CORE,
     tooltip = "Minimum body-to-range ratio required for initiative intent.")
float wickStrong = input.float(0.46, "Reaction Wick Ratio", minval = 0.25, maxval = 0.80, step = 0.01, group = G_CORE,
     tooltip = "Minimum wick-to-range ratio required for rejection or absorption behavior.")
float quietBody = input.float(0.24, "Indecision Body Ratio", minval = 0.08, maxval = 0.42, step = 0.01, group = G_CORE,
     tooltip = "Maximum body-to-range ratio used to classify low-commitment indecision candles.")

string G_VISUAL = "Visual Design"
bool showIntentZone = input.bool(true, "Show Intent Zone", group = G_VISUAL,
     tooltip = "Displays the most recent candle intent pressure zone.")
bool showZoneFill = input.bool(true, "Show Intent Zone Fill", group = G_VISUAL,
     tooltip = "Adds a subtle fill to the active intent zone so the active candle structure remains visible without overpowering price.")
bool showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows compact initiative, absorption, rejection, indecision, and shift labels.")
bool showRightTags = input.bool(true, "Show Zone Context Badge", group = G_VISUAL,
     tooltip = "Shows one compact state-and-direction badge attached to the right edge of the active intent zone.")
bool showBarColors = input.bool(false, "Color Bars by Intent", group = G_VISUAL,
     tooltip = "Optionally colors bars by the active candle intent state.")
int visibleZoneBars = input.int(72, "Visible Zone Bars", minval = 24, maxval = 180, group = G_VISUAL,
     tooltip = "Controls how many recent bars are covered by the visible candle intent zone.")
int projectionBars = input.int(20, "Zone Projection Bars", minval = 8, maxval = 70, group = G_VISUAL,
     tooltip = "Controls how far the candle intent zone is projected to the right.")
float minZoneHeightAtr = input.float(0.72, "Minimum Zone Height ATR", minval = 0.02, maxval = 1.40, step = 0.01, group = G_VISUAL,
     tooltip = "Keeps very thin candle intent zones visible on higher timeframes by applying a minimum visual height.")
int labelCooldownBars = input.int(28, "Event Label Cooldown", minval = 6, maxval = 120, group = G_VISUAL,
     tooltip = "Minimum number of bars between event labels. Higher values reduce label density.")
int maxEventLabels = input.int(4, "Maximum Event Labels", minval = 3, maxval = 20, group = G_VISUAL,
     tooltip = "Maximum number of historical event labels kept on the chart.")
float labelOffsetAtr = input.float(0.78, "Label Offset ATR", minval = 0.20, maxval = 4.0, step = 0.05, group = G_VISUAL,
     tooltip = "Distance between event labels and candles, measured in ATR.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label, zone badge, and right-side tag font size.")

string G_PANEL = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro information panel.")
string panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_PANEL,
     tooltip = "Controls where the AG Pro panel is placed.")
string panelThemeInput = input.string("Dark", "Panel Theme", options = ["Dark", "Light", "Slate"], group = G_PANEL,
     tooltip = "Controls the panel color theme.")
string panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL,
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
color darkText = color.rgb(17, 24, 39)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_size(string sizeName) =>
    sizeName == "Tiny" ? size.tiny :
     sizeName == "Small" ? size.small :
     sizeName == "Large" ? size.large :
     sizeName == "Huge" ? size.huge : size.normal

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

f_dir_text(int direction) =>
    direction > 0 ? "Bullish" : direction < 0 ? "Bearish" : "Neutral"

f_text_on(color bgColor) =>
    float bright = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_panel_bg(string themeName) =>
    themeName == "Light" ? color.rgb(248, 250, 252) : themeName == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_label(string themeName) =>
    themeName == "Light" ? color.rgb(71, 85, 105) : themeName == "Slate" ? color.rgb(203, 213, 225) : panelLabelCol

f_panel_value(string themeName) =>
    themeName == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string themeName, int row) =>
    bool evenRow = row % 2 == 0
    if themeName == "Light"
        evenRow ? color.rgb(226, 232, 240) : color.rgb(248, 250, 252)
    else if themeName == "Slate"
        evenRow ? color.rgb(51, 65, 85) : color.rgb(30, 41, 59)
    else
        evenRow ? color.rgb(29, 49, 82) : color.rgb(6, 12, 24)

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

f_event_label(array<label> store, int x, float y, string txt, color bg, bool upward, string sizeInput, int limit) =>
    label newLabel = label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = upward ? label.style_label_up : label.style_label_down, textcolor = f_text_on(bg), color = color.new(bg, 4), size = f_size(sizeInput), textalign = text.align_center)
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
float safeRange = math.max(high - low, syminfo.mintick)
float body = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float bodyRatio = body / safeRange
float upperWickRatio = upperWick / safeRange
float lowerWickRatio = lowerWick / safeRange
float closePosition = (close - low) / safeRange
int bodyDirection = close > open ? 1 : close < open ? -1 : 0
float volumeBase = ta.sma(nz(volume, 1.0), volumeLength)
float volumeRank = volumeBase > 0.0 ? f_clamp(nz(volume, 1.0) / volumeBase * 50.0, 0.0, 100.0) : 50.0
float followReturn = close - close[followLength]
float followScore = atr > 0.0 ? f_clamp(math.abs(followReturn) / atr * 18.0, 0.0, 20.0) : 0.0

bool bullInitiative = bodyDirection > 0 and bodyRatio >= bodyStrong and closePosition > 0.68 and volumeRank > 38.0
bool bearInitiative = bodyDirection < 0 and bodyRatio >= bodyStrong and closePosition < 0.32 and volumeRank > 38.0
bool bullRejection = lowerWickRatio >= wickStrong and closePosition > 0.58
bool bearRejection = upperWickRatio >= wickStrong and closePosition < 0.42
bool absorption = volumeRank > 58.0 and bodyRatio <= 0.42 and (upperWickRatio >= wickStrong or lowerWickRatio >= wickStrong)
bool indecision = bodyRatio <= quietBody and upperWickRatio > 0.22 and lowerWickRatio > 0.22

int rawIntentDir = bullInitiative or bullRejection ? 1 : bearInitiative or bearRejection ? -1 : bodyDirection
var int intentDir = 0
var int previousIntentDir = 0
var int intentBar = na
var float intentQualityMemory = na
var string intentMemory = "Wait Intent"

bool intentShift = rawIntentDir != 0 and previousIntentDir != 0 and rawIntentDir != previousIntentDir and volumeRank > 42.0 and bodyRatio > quietBody
bool eventCandidate = bullInitiative or bearInitiative or bullRejection or bearRejection or absorption or indecision or intentShift
bool confirmedEvent = barstate.isconfirmed and eventCandidate

float intentQuality = f_clamp(bodyRatio * 32.0 + math.max(upperWickRatio, lowerWickRatio) * 24.0 + volumeRank * 0.32 + closePosition * (rawIntentDir > 0 ? 16.0 : 0.0) + (1.0 - closePosition) * (rawIntentDir < 0 ? 16.0 : 0.0) + followScore, 0.0, 100.0)
float bodyPressure = f_clamp(bodyRatio * 100.0, 0.0, 100.0)
float wickReaction = f_clamp(math.max(upperWickRatio, lowerWickRatio) * 100.0, 0.0, 100.0)
float followThrough = rawIntentDir == 0 ? 0.0 : rawIntentDir > 0 ? f_clamp((close - ta.lowest(low, followLength)) / atr * 18.0, 0.0, 100.0) : f_clamp((ta.highest(high, followLength) - close) / atr * 18.0, 0.0, 100.0)

if confirmedEvent
    previousIntentDir := intentDir != 0 ? intentDir : previousIntentDir
    intentDir := rawIntentDir
    intentBar := bar_index
    intentQualityMemory := intentQuality
    intentMemory := intentShift ? "Intent Shift" : absorption ? "Absorption" : bullInitiative or bearInitiative ? "Initiative" : bullRejection or bearRejection ? "Rejection" : indecision ? "Indecision" : "Intent Watch"

string stateText = intentMemory
color stateColor = intentMemory == "Initiative" ? (intentDir >= 0 ? bullColor : bearColor) : intentMemory == "Intent Shift" ? neutralColor : intentMemory == "Absorption" ? accentColor : intentMemory == "Indecision" ? neutralColor : intentDir >= 0 ? bullColor : bearColor
string nextContext = intentMemory == "Initiative" ? "Track follow-through" : intentMemory == "Absorption" ? "Watch trapped side" : intentMemory == "Rejection" ? "Monitor reaction" : intentMemory == "Intent Shift" ? "Confirm shift" : intentMemory == "Indecision" ? "Wait commitment" : "Wait intent"

// --------------------------------------------------
// Intent Hit Rate (Proof Pass)
// --------------------------------------------------
// After a directional intent event (initiative or rejection), wait proofWindowBars
// and check whether price continued in the intent direction. Builds an honest,
// self-measured follow-through rate for the intent read.
bool directionalIntent = bullInitiative or bearInitiative or bullRejection or bearRejection

var int intentProofHits = 0
var int intentProofTotal = 0
var bool intentProofPending = false
var int intentProofStart = na
var float intentProofEntry = na
var int intentProofDir = 0

if barstate.isconfirmed
    if directionalIntent and rawIntentDir != 0 and not intentProofPending
        intentProofPending := true
        intentProofStart := bar_index
        intentProofEntry := close
        intentProofDir := rawIntentDir
    if intentProofPending and not na(intentProofStart) and bar_index - intentProofStart >= proofWindowBars
        bool intentHit = intentProofDir > 0 ? close > intentProofEntry : close < intentProofEntry
        intentProofTotal += 1
        if intentHit
            intentProofHits += 1
        intentProofPending := false

float intentProofRate = intentProofTotal > 0 ? intentProofHits / intentProofTotal * 100.0 : na
string intentRateText = intentProofTotal > 0 ? str.tostring(int(math.round(intentProofRate))) + "% (" + str.tostring(intentProofHits) + "/" + str.tostring(intentProofTotal) + ")" : "Building"
color intentRateColor = intentProofTotal == 0 ? neutralColor : intentProofRate >= 60.0 ? bullColor : intentProofRate >= 45.0 ? neutralColor : bearColor

// --------------------------------------------------
// Intent Zone
// --------------------------------------------------
float zoneTopNow = absorption or bearRejection ? high : math.max(open, close)
float zoneBottomNow = absorption or bullRejection ? low : math.min(open, close)
var float zoneTop = na
var float zoneBottom = na
var int zoneStart = na
var color zoneColor = accentColor

if confirmedEvent
    zoneTop := math.max(zoneTopNow, zoneBottomNow + syminfo.mintick)
    zoneBottom := math.min(zoneBottomNow, zoneTopNow - syminfo.mintick)
    zoneStart := bar_index
    zoneColor := stateColor

int rightX = bar_index + projectionBars
int leftX = not na(zoneStart) ? math.max(zoneStart, bar_index - visibleZoneBars) : math.max(bar_index - visibleZoneBars, 0)
float zoneMid = not na(zoneTop) and not na(zoneBottom) ? (zoneTop + zoneBottom) * 0.5 : close
float zoneHeight = not na(zoneTop) and not na(zoneBottom) ? zoneTop - zoneBottom : na
float minZoneHeight = math.max(syminfo.mintick, atr * minZoneHeightAtr)
float visualZoneTop = not na(zoneHeight) and zoneHeight < minZoneHeight ? zoneMid + minZoneHeight * 0.5 : zoneTop
float visualZoneBottom = not na(zoneHeight) and zoneHeight < minZoneHeight ? zoneMid - minZoneHeight * 0.5 : zoneBottom
int labelX = int(math.round((leftX + rightX) * 0.5))

color hiddenColor = color.new(color.black, 100)
var box intentHalo = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = hiddenColor, border_color = hiddenColor, border_width = 1)
var box intentBox = box.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, bgcolor = hiddenColor, border_color = hiddenColor, border_width = 1)
var line upperRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line midRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_dotted, width = 2)
var line lowerRail = line.new(bar_index, close, bar_index + 1, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line leftRail = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var line rightRail = line.new(bar_index, close, bar_index, close, xloc = xloc.bar_index, color = hiddenColor, style = line.style_solid, width = 2)
var label zoneLabel = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal)
var label contextTag = label.new(bar_index, close, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = headerText, size = size.normal)

if barstate.islast
    if showIntentZone and not na(zoneTop) and not na(zoneBottom)
        float haloPadding = math.max(atr * 0.10, (visualZoneTop - visualZoneBottom) * 0.22)
        float haloTop = visualZoneTop + haloPadding
        float haloBottom = visualZoneBottom - haloPadding
        box.set_left(intentHalo, leftX)
        box.set_right(intentHalo, rightX)
        box.set_top(intentHalo, haloTop)
        box.set_bottom(intentHalo, haloBottom)
        box.set_bgcolor(intentHalo, showZoneFill ? color.new(zoneColor, 92) : hiddenColor)
        box.set_border_color(intentHalo, color.new(zoneColor, 62))
        box.set_border_width(intentHalo, 1)
        box.set_left(intentBox, leftX)
        box.set_right(intentBox, rightX)
        box.set_top(intentBox, visualZoneTop)
        box.set_bottom(intentBox, visualZoneBottom)
        box.set_bgcolor(intentBox, showZoneFill ? color.new(zoneColor, 68) : hiddenColor)
        box.set_border_color(intentBox, color.new(zoneColor, 0))
        box.set_border_width(intentBox, 3)
        f_set_line(upperRail, leftX, visualZoneTop, rightX, visualZoneTop, color.new(zoneColor, 0), line.style_solid, 4)
        f_set_line(midRail, leftX, zoneMid, rightX, zoneMid, color.new(zoneColor, 10), line.style_dotted, 2)
        f_set_line(lowerRail, leftX, visualZoneBottom, rightX, visualZoneBottom, color.new(zoneColor, 0), line.style_solid, 4)
        f_set_line(leftRail, leftX, visualZoneTop, leftX, visualZoneBottom, color.new(zoneColor, 0), line.style_solid, 3)
        f_set_line(rightRail, rightX, visualZoneTop, rightX, visualZoneBottom, color.new(zoneColor, 0), line.style_solid, 3)
        f_set_tag(zoneLabel, labelX, zoneMid, "Intent Zone\nQ " + f_score(intentQualityMemory), zoneColor, label.style_label_center, labelSizeInput)
    else
        box.set_bgcolor(intentHalo, hiddenColor)
        box.set_border_color(intentHalo, hiddenColor)
        box.set_bgcolor(intentBox, hiddenColor)
        box.set_border_color(intentBox, hiddenColor)
        f_set_line(upperRail, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(midRail, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        f_set_line(lowerRail, bar_index, close, bar_index + 1, close, hiddenColor, line.style_solid, 1)
        label.set_text(zoneLabel, "")
        label.set_color(zoneLabel, hiddenColor)
        f_set_line(leftRail, bar_index, close, bar_index, close, hiddenColor, line.style_solid, 1)
        f_set_line(rightRail, bar_index, close, bar_index, close, hiddenColor, line.style_solid, 1)

    if showRightTags and showIntentZone and not na(zoneTop) and not na(zoneBottom)
        // One zone-owned badge replaces the detached state and quality tags.
        // It is attached to the zone edge and vertically centered on the zone.
        string contextText = f_dir_text(intentDir) + " | " + stateText
        f_set_tag(contextTag, rightX, zoneMid, contextText, zoneColor, label.style_label_left, labelSizeInput)
    else
        label.set_text(contextTag, "")
        label.set_color(contextTag, hiddenColor)

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastEventBar = na
bool canPrintEvent = na(lastEventBar) or bar_index - lastEventBar >= labelCooldownBars
string eventText = intentShift ? "Intent Shift\nQ " + f_score(intentQuality) : absorption ? "Absorption\nQ " + f_score(intentQuality) : bullInitiative ? "Bull Intent\nQ " + f_score(intentQuality) : bearInitiative ? "Bear Intent\nQ " + f_score(intentQuality) : bullRejection ? "Lower Reject\nQ " + f_score(intentQuality) : bearRejection ? "Upper Reject\nQ " + f_score(intentQuality) : "Indecision\nQ " + f_score(intentQuality)
color eventColor = intentShift ? neutralColor : absorption ? accentColor : rawIntentDir >= 0 ? bullColor : bearColor
float eventY = rawIntentDir < 0 ? high + atr * labelOffsetAtr : low - atr * labelOffsetAtr
bool eventUp = rawIntentDir >= 0

if showEventLabels and confirmedEvent and canPrintEvent
    f_event_label(eventLabels, bar_index, eventY, eventText, eventColor, eventUp, labelSizeInput, maxEventLabels)
    lastEventBar := bar_index

barcolor(showBarColors ? (intentMemory == "Initiative" ? color.new(zoneColor, 72) : intentMemory == "Intent Shift" ? color.new(neutralColor, 70) : na) : na)

// --------------------------------------------------
// Panel
// --------------------------------------------------
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
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Candle Intent Map", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSizeInput), text_halign = text.align_center)
        f_panel_row(panel, 1, "Current Intent", stateText + " / " + f_score(intentQualityMemory), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Direction", f_dir_text(intentDir), stateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Body / Wick", f_score(bodyPressure) + " / " + f_score(wickReaction), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Volume", f_score(volumeRank) + " / Follow " + f_score(followThrough), f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Zone", not na(zoneTop) and not na(zoneBottom) ? "Active / " + f_score(intentQualityMemory) : "Waiting", f_panel_value(panelThemeInput), panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Intent Hit Rate", intentRateText, intentRateColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Action", nextContext, stateColor, panelThemeInput, panelFontSizeInput)
    else
        if not na(panel)
            table.delete(panel)
            panel := na
            panelPosMemory := ""
            panelThemeMemory := ""

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(barstate.isconfirmed and bullInitiative, "Bullish Candle Intent", "A confirmed bullish initiative candle intent event was detected.")
alertcondition(barstate.isconfirmed and bearInitiative, "Bearish Candle Intent", "A confirmed bearish initiative candle intent event was detected.")
alertcondition(barstate.isconfirmed and absorption, "Candle Absorption", "A confirmed candle absorption context was detected.")
alertcondition(barstate.isconfirmed and intentShift, "Candle Intent Shift", "A confirmed candle intent shift was detected.")
````
