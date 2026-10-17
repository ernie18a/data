# Market Structure Break BOS Classifier 

- url: https://www.tradingview.com/script/HZaETXqr-Market-Structure-Break-BOS-Classifier/
- type: indicator
- pine_id: PUB;d74f0cb1b33b448fb4b4efc4343d7a59
- version: 2.0

## Description

Market Structure Break — BOS Classifier
A clean, no-noise market structure indicator that goes beyond simply marking a BOS. Every break is classified by context so you immediately know whether to act on it or skip it.

🔵 What Makes This Different
Most BOS indicators fire the same label regardless of market context. This one answers the question that actually matters — was that break meaningful, or was it just noise inside a range?
Every Break of Structure is classified into one of three types:

📊 Signal Types
✔ Valid BOS (Green/Red — solid line)
Price closes above the previous swing high (bullish) or below the previous swing low (bearish) while outside a consolidation zone. This is a clean, high-confidence structural break. Fires on the exact candle of the break — no lag.
⚠ Range BOS (Yellow — dashed line)
Same close-cross condition, but price was inside a consolidation zone when it happened. These breaks are more likely to be fakeouts. Treat with caution — wait for a retest or additional confirmation before entry.
〰 iBOS — Internal BOS (Lime/Red — dashed line)
The short-term zigzag trend flips direction but the higher-level market structure has not changed. This is a minor internal move within the prevailing trend. Useful for spotting early reversals, but not a tradeable structure break on its own.

🟠 Consolidation / Range Detection
The indicator automatically detects when price is forming a lower high AND higher low relative to the prior swing — the classic compression signature. When active:

Background is highlighted in orange
A dashed boundary box shows the exact range with top and bottom levels
Any BOS fired during this phase is automatically tagged as a Range BOS


⚙️ How It Works Internally

Zigzag engine builds swing highs (h0, h1) and swing lows (l0, l1)
Valid/Range BOS → fires when close crosses h1 or l1 on the break candle (leading — no confirmation lag)
iBOS → fires when trend variable flips but market variable does not
Consolidation → h0 < h1 AND l0 > l1 simultaneously


🛠 Settings
SettingDescriptionZigZag LengthControls swing sensitivity. Higher = fewer, larger swingsFib FactorMinimum move required to confirm a structural break (0–1)Show Consolidation ZoneToggle the range box and background highlightShow Valid BOSToggle clean outside-range BOS signalsShow Range BOSToggle inside-range BOS signalsShow iBOSToggle internal minor structure flipsText SizeTiny / Small / Normal / Large / Huge

🔔 Alerts Available

✔ Valid BOS Bullish — clean break above swing high outside range
✔ Valid BOS Bearish — clean break below swing low outside range
⚠ Range BOS Bullish — break above swing high from inside consolidation
⚠ Range BOS Bearish — break below swing low from inside consolidation
iBOS Bullish — internal flip inside bearish structure
iBOS Bearish — internal flip inside bullish structure
Consolidation Start — market entered a range zone


📌 Recommended Usage

Use on your HTF bias timeframe (1H, 4H) to identify the market state
A Valid BOS in the direction of your bias = structure is with you
A Range BOS = wait for the retest of the broken level before committing
An iBOS inside a trending market = potential early entry signal in the direction of the trend, not against it
When the Consolidation zone is active, reduce position size or wait for a clean Valid BOS breakout before trading


⚠️ Disclaimer
This indicator is for educational and analytical purposes only. It does not constitute financial advice. Past performance of any signal is not indicative of future results. Always use proper risk management.

Based on original MSB-OB structure by © EmreKb. Extended with consolidation detection, BOS classification, and leading signal logic.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// BOS + ZigZag only, Pine Script v6.

//@version=6
indicator("SB BOS + ZigZag", "SB", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━━━━
// PAIR PROFILE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━
profile = input.string(
     "EUR/USD",
     "Trading Pair Profile",
     options=["EUR/USD", "GBP/USD", "USD/JPY", "EUR/JPY", "Custom"],
     group="Pair Presets")

customDepth     = input.int(106, "Custom Depth", minval=2, maxval=500, group="Pair Presets")
customDeviation = input.float(1.0, "Custom Deviation", minval=0.0, step=0.1, group="Pair Presets")
customBackstep  = input.int(2, "Custom Backstep", minval=0, maxval=50, group="Pair Presets")

depth =
     profile == "EUR/USD" ? 106 :
     profile == "GBP/USD" ? 106 :
     profile == "USD/JPY" ? 120 :
     profile == "EUR/JPY" ? 120 :
     customDepth

deviation =
     profile == "EUR/USD" ? 1.0 :
     profile == "GBP/USD" ? 1.5 :
     profile == "USD/JPY" ? 1.5 :
     profile == "EUR/JPY" ? 1.8 :
     customDeviation

backstep =
     profile == "EUR/USD" ? 2 :
     profile == "GBP/USD" ? 2 :
     profile == "USD/JPY" ? 2 :
     profile == "EUR/JPY" ? 2 :
     customBackstep

//━━━━━━━━━━━━━━━━━━━━━━
// VISUAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━
settingsGroup = "Visual Settings"

lineThickness = input.int(2, "Line Thickness", minval=1, maxval=5, group=settingsGroup)
breakoutThickness = input.int(4, "Line Thickness breakout", minval=1, maxval=5, group=settingsGroup)
bullColor = input.color(#00E676, "Bull Color", group=settingsGroup)
bearColor = input.color(#FF5252, "Bear Color", group=settingsGroup)

zigzagGroup = "ZigZag Settings"
showZigzag = input.bool(true, "Show Zigzag?", group=zigzagGroup)
repaintLevels = input.bool(false, "Repaint Levels", group=zigzagGroup)

breakGroup = "Breakout Colors"
bullBreakColor = input.color(#4CAF50, "Color for bullish break", group=breakGroup)
bearBreakColor = input.color(#F23645, "Color for bearish break", group=breakGroup)

panelGroup = "Active Settings Panel"
showSettingsPanel = input.bool(true, "Show Active Settings Panel", group=panelGroup)

//━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE SETTINGS PANEL
//━━━━━━━━━━━━━━━━━━━━━━
var table settingsPanel = table.new(position.bottom_right, 2, 4, border_width=1)

if barstate.islast and showSettingsPanel
    table.cell(settingsPanel, 0, 0, "Profile", text_color=color.white, bgcolor=color.black)
    table.cell(settingsPanel, 1, 0, profile, text_color=color.white, bgcolor=color.black)

    table.cell(settingsPanel, 0, 1, "Depth", text_color=color.white, bgcolor=color.black)
    table.cell(settingsPanel, 1, 1, str.tostring(depth), text_color=color.white, bgcolor=color.black)

    table.cell(settingsPanel, 0, 2, "Deviation", text_color=color.white, bgcolor=color.black)
    table.cell(settingsPanel, 1, 2, str.tostring(deviation), text_color=color.white, bgcolor=color.black)

    table.cell(settingsPanel, 0, 3, "Backstep", text_color=color.white, bgcolor=color.black)
    table.cell(settingsPanel, 1, 3, str.tostring(backstep), text_color=color.white, bgcolor=color.black)

//━━━━━━━━━━━━━━━━━━━━━━
// SWING DETECTION
//━━━━━━━━━━━━━━━━━━━━━━
rightBars = repaintLevels ? 1 : depth
pivotHigh = ta.pivothigh(high, depth, rightBars)
pivotLow = ta.pivotlow(low, depth, rightBars)
atrValue = ta.atr(14)

// ZigZag state. Type: 1 high, -1 low.
var float zzLastPrice = na
var int zzLastIndex = na
var int zzLastType = 0
var line zzLastLine = na

//━━━━━━━━━━━━━━━━━━━━━━
// STRUCTURE MEMORY FOR YOUR BOS LOGIC
//━━━━━━━━━━━━━━━━━━━━━━
var float lastAcceptedHigh = na
var int lastAcceptedHighIndex = na
var float lastAcceptedLow = na
var int lastAcceptedLowIndex = na

var float bearishBosLevel = na
var int bearishBosLevelIndex = na

var float bullishBosLevel = na
var int bullishBosLevelIndex = na

var int lastBrokenBearishLevelIndex = na
var int lastBrokenBullishLevelIndex = na

//━━━━━━━━━━━━━━━━━━━━━━
// PIVOT HIGH
//━━━━━━━━━━━━━━━━━━━━━━
if not na(pivotHigh)
    int pivotIndex = bar_index - rightBars

    bool deviationOk = na(zzLastPrice) or deviation == 0 or math.abs(pivotHigh - zzLastPrice) >= atrValue * deviation
    bool backstepOk = na(zzLastIndex) or math.abs(pivotIndex - zzLastIndex) > backstep

    if zzLastType == 0
        zzLastPrice := pivotHigh
        zzLastIndex := pivotIndex
        zzLastType := 1

        lastAcceptedHigh := pivotHigh
        lastAcceptedHighIndex := pivotIndex

    else if zzLastType != 1 and deviationOk and backstepOk
        if showZigzag
            zzLastLine := line.new(zzLastIndex, zzLastPrice, pivotIndex, pivotHigh, xloc=xloc.bar_index, color=bullColor, width=lineThickness)

        bool madeHH = not na(lastAcceptedHigh) and pivotHigh > lastAcceptedHigh

        lastAcceptedHigh := pivotHigh
        lastAcceptedHighIndex := pivotIndex

        if madeHH and not na(lastAcceptedLow)
            bearishBosLevel := lastAcceptedLow
            bearishBosLevelIndex := lastAcceptedLowIndex

        zzLastPrice := pivotHigh
        zzLastIndex := pivotIndex
        zzLastType := 1

    else if zzLastType == 1 and pivotHigh > zzLastPrice
        if showZigzag and not na(zzLastLine)
            line.set_x2(zzLastLine, pivotIndex)
            line.set_y2(zzLastLine, pivotHigh)
            line.set_color(zzLastLine, bullColor)
            line.set_width(zzLastLine, lineThickness)

        bool madeHH = na(lastAcceptedHigh) or pivotHigh > lastAcceptedHigh

        lastAcceptedHigh := pivotHigh
        lastAcceptedHighIndex := pivotIndex

        if madeHH and not na(lastAcceptedLow)
            bearishBosLevel := lastAcceptedLow
            bearishBosLevelIndex := lastAcceptedLowIndex

        zzLastPrice := pivotHigh
        zzLastIndex := pivotIndex

//━━━━━━━━━━━━━━━━━━━━━━
// PIVOT LOW
//━━━━━━━━━━━━━━━━━━━━━━
if not na(pivotLow)
    int pivotIndex = bar_index - rightBars

    bool deviationOk = na(zzLastPrice) or deviation == 0 or math.abs(pivotLow - zzLastPrice) >= atrValue * deviation
    bool backstepOk = na(zzLastIndex) or math.abs(pivotIndex - zzLastIndex) > backstep

    if zzLastType == 0
        zzLastPrice := pivotLow
        zzLastIndex := pivotIndex
        zzLastType := -1

        lastAcceptedLow := pivotLow
        lastAcceptedLowIndex := pivotIndex

    else if zzLastType != -1 and deviationOk and backstepOk
        if showZigzag
            zzLastLine := line.new(zzLastIndex, zzLastPrice, pivotIndex, pivotLow, xloc=xloc.bar_index, color=bearColor, width=lineThickness)

        bool madeLL = not na(lastAcceptedLow) and pivotLow < lastAcceptedLow

        lastAcceptedLow := pivotLow
        lastAcceptedLowIndex := pivotIndex

        if madeLL and not na(lastAcceptedHigh)
            bullishBosLevel := lastAcceptedHigh
            bullishBosLevelIndex := lastAcceptedHighIndex

        zzLastPrice := pivotLow
        zzLastIndex := pivotIndex
        zzLastType := -1

    else if zzLastType == -1 and pivotLow < zzLastPrice
        if showZigzag and not na(zzLastLine)
            line.set_x2(zzLastLine, pivotIndex)
            line.set_y2(zzLastLine, pivotLow)
            line.set_color(zzLastLine, bearColor)
            line.set_width(zzLastLine, lineThickness)

        bool madeLL = na(lastAcceptedLow) or pivotLow < lastAcceptedLow

        lastAcceptedLow := pivotLow
        lastAcceptedLowIndex := pivotIndex

        if madeLL and not na(lastAcceptedHigh)
            bullishBosLevel := lastAcceptedHigh
            bullishBosLevelIndex := lastAcceptedHighIndex

        zzLastPrice := pivotLow
        zzLastIndex := pivotIndex

//━━━━━━━━━━━━━━━━━━━━━━
// BOS ONLY — UPDATED LOGIC
//━━━━━━━━━━━━━━━━━━━━━━
// Bearish BOS: close < latest HL that created latest HH.
// Bullish BOS: close > latest LH that created latest LL.

bearishLevelNotBroken = na(lastBrokenBearishLevelIndex) or lastBrokenBearishLevelIndex != bearishBosLevelIndex
bullishLevelNotBroken = na(lastBrokenBullishLevelIndex) or lastBrokenBullishLevelIndex != bullishBosLevelIndex

bearishBos = not na(bearishBosLevel) and close < bearishBosLevel and bearishLevelNotBroken
bullishBos = not na(bullishBosLevel) and close > bullishBosLevel and bullishLevelNotBroken

if bullishBos
    line.new(bullishBosLevelIndex, bullishBosLevel, bar_index, bullishBosLevel, xloc=xloc.bar_index, color=bullBreakColor, width=breakoutThickness)
    label.new(int(math.avg(bullishBosLevelIndex, bar_index)), bullishBosLevel, "BOS", xloc=xloc.bar_index, color=color.new(color.black, 100), style=label.style_label_down, textcolor=bullBreakColor, size=size.small)
    lastBrokenBullishLevelIndex := bullishBosLevelIndex

if bearishBos
    line.new(bearishBosLevelIndex, bearishBosLevel, bar_index, bearishBosLevel, xloc=xloc.bar_index, color=bearBreakColor, width=breakoutThickness)
    label.new(int(math.avg(bearishBosLevelIndex, bar_index)), bearishBosLevel, "BOS", xloc=xloc.bar_index, color=color.new(color.black, 100), style=label.style_label_up, textcolor=bearBreakColor, size=size.small)
    lastBrokenBearishLevelIndex := bearishBosLevelIndex

//━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullishBos, "Bullish BOS", "Bullish BOS: close broke above latest LH that created latest LL.")
alertcondition(bearishBos, "Bearish BOS", "Bearish BOS: close broke below latest HL that created latest HH.")
````
