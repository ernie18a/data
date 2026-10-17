# Structural Inefficiency Radar [JOAT]

- url: https://www.tradingview.com/script/ZHtDZV7k-Structural-Inefficiency-Radar-JOAT/
- type: indicator
- pine_id: PUB;33784a9b4afd499b9a2c4c376620366b
- version: 1.0

## Description

[b]Structural Inefficiency Radar [JOAT][/b]

[b]Introduction[/b]

Structural Inefficiency Radar measures regression fair value, residual z-score, path asymmetry, volatility clustering, and repair/extension force.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/VywSSYiA/[/image]

[b]Core Concepts[/b]

[b]1. Regression Fair Value[/b]

A linear regression spine represents statistical fair value.

[b]2. Residual Z-Score[/b]

Distance from fair value is normalized by residual standard deviation.

[b]3. Path Asymmetry[/b]

Upward and downward path movement are compared to detect directional distortion.

[b]4. Repair and Extension Force[/b]

Deviation, slope, asymmetry, and clustering determine whether price is extending or repairing.

[pine]
z = (close - fairValue) / residualDeviation
[/pine]

[b]Features[/b]

[list]
[*]Fair-value spine
[*]Inner and outer inefficiency bands
[*]Residual z-score
[*]Repair and extension scoring
[*]E+ and E- labels plus repair markers
[/list]

[b]Input Parameters[/b]

[list]
[*]Regression and residual windows
[*]Deviation gate
[*]Repair quality gate
[*]Cooldown
[*]Bands, candles, and HUD toggles
[/list]


[b]How to Use This Script[/b]

Use the spine and bands to frame structural stretch. Extension labels indicate directional inefficiency; gold markers indicate fair-value repair.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

SIR is original in combining regression residuals, path asymmetry, clustering, repair force, and extension force.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structural Inefficiency Radar [JOAT]", shorttitle="SIR [JOAT]", overlay=true, max_bars_back=900, max_lines_count=120, max_labels_count=80)

// Structural Inefficiency Radar [JOAT]
// Regression residuals, path asymmetry, and volatility-normalized displacement are combined into an inefficiency map.
// Clean visual goal: one fair-value spine, deviation bands, and sparse repair/extension events.

string gModel = "Inefficiency Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int regLen = input.int(120, "Fair-value regression", minval=40, maxval=360, group=gModel)
int statLen = input.int(80, "Residual statistics", minval=30, maxval=260, group=gModel)
float devGate = input.float(2.05, "Deviation gate", minval=1.0, maxval=4.0, step=0.05, group=gSignal)
float repairGate = input.float(58.0, "Repair quality gate", minval=40, maxval=90, step=1, group=gSignal)
int cooldown = input.int(12, "Signal cooldown", minval=1, maxval=100, group=gSignal)
bool showBands = input.bool(true, "Show inefficiency bands", group=gVisual)
bool paintBars = input.bool(true, "Paint candles", group=gVisual)
bool showDashboard = input.bool(true, "Show quant HUD", group=gVisual)
string hudLoc = input.string("Top Right", "HUD position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)

color C_BULL = #00ffd5
color C_BEAR = #ff2af4
color C_GOLD = #ffb300
color C_BLUE = #4f7cff
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b
hudPos = hudLoc == "Top Left" ? position.top_left : hudLoc == "Bottom Right" ? position.bottom_right : hudLoc == "Bottom Left" ? position.bottom_left : position.top_right

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

safeDiv(float n, float d) =>
    d == 0.0 ? 0.0 : n / d

float atr = ta.atr(14)
float fairValue = ta.linreg(close, regLen, 0)
float fairPrev = ta.linreg(close, regLen, 1)
float residual = close - fairValue
float residDev = ta.stdev(residual, statLen)
float z = safeDiv(residual, math.max(residDev, syminfo.mintick))
float slope = safeDiv(fairValue - fairPrev, math.max(atr, syminfo.mintick))
float pathUp = ta.sma(close > close[1] ? math.abs(close - close[1]) : 0.0, statLen)
float pathDn = ta.sma(close < close[1] ? math.abs(close - close[1]) : 0.0, statLen)
float asymmetry = safeDiv(pathUp - pathDn, math.max(pathUp + pathDn, syminfo.mintick))
float volCluster = safeDiv(ta.stdev(atr, statLen), math.max(ta.sma(atr, statLen), syminfo.mintick))
float repairForce = clamp(50 - z * 16 - slope * 10 + asymmetry * 18, 0, 100)
float extensionForce = clamp(50 + z * 16 + slope * 10 + asymmetry * 18, 0, 100)
float inefficiency = clamp(math.abs(z) * 24 + volCluster * 30 + math.abs(asymmetry) * 28, 0, 100)

float bandWidth = math.max(residDev, atr * 0.35)
float upper1 = fairValue + bandWidth * 1.0
float lower1 = fairValue - bandWidth * 1.0
float upper2 = fairValue + bandWidth * devGate
float lower2 = fairValue - bandWidth * devGate
int regime = z > 0.35 and extensionForce > repairForce ? 1 : z < -0.35 and repairForce > extensionForce ? -1 : 0
color theme = regime == 1 ? C_BULL : regime == -1 ? C_BEAR : C_BLUE

bool upperExtension = barstate.isconfirmed and z > devGate and extensionForce > repairGate and slope > 0
bool lowerExtension = barstate.isconfirmed and z < -devGate and repairForce > repairGate and slope < 0
bool upperRepair = barstate.isconfirmed and z[1] > devGate and close < upper1 and repairForce > repairGate
bool lowerRepair = barstate.isconfirmed and z[1] < -devGate and close > lower1 and extensionForce > repairGate
var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool extUpEvent = cooled and upperExtension and not upperExtension[1]
bool extDnEvent = cooled and lowerExtension and not lowerExtension[1]
bool repairUpEvent = cooled and lowerRepair and not lowerRepair[1]
bool repairDnEvent = cooled and upperRepair and not upperRepair[1]
if extUpEvent or extDnEvent or repairUpEvent or repairDnEvent
    lastSignal := bar_index

pFair = plot(showBands ? fairValue : na, "SIR fair-value spine", color=color.new(theme, 5), linewidth=2)
pU1 = plot(showBands ? upper1 : na, "SIR inner upper", color=color.new(theme, 82))
pL1 = plot(showBands ? lower1 : na, "SIR inner lower", color=color.new(theme, 82))
pU2 = plot(showBands ? upper2 : na, "SIR outer upper", color=color.new(theme, 68))
pL2 = plot(showBands ? lower2 : na, "SIR outer lower", color=color.new(theme, 68))
fill(pU2, pL2, color=color.new(theme, 94), title="SIR outer inefficiency field")
fill(pU1, pL1, color=color.new(theme, 89), title="SIR inner fair-value field")
plotshape(extUpEvent, "SIR upper extension", shape.labelup, location.belowbar, color=color.new(C_BULL, 0), text="E+", textcolor=C_BG, size=size.tiny)
plotshape(extDnEvent, "SIR lower extension", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 0), text="E-", textcolor=C_TEXT, size=size.tiny)
plotshape(repairUpEvent, "SIR lower repair", shape.circle, location.belowbar, color=color.new(C_GOLD, 0), size=size.tiny)
plotshape(repairDnEvent, "SIR upper repair", shape.circle, location.abovebar, color=color.new(C_GOLD, 0), size=size.tiny)
barcolor(paintBars ? upperExtension ? color.new(C_BULL, 62) : lowerExtension ? color.new(C_BEAR, 62) : upperRepair or lowerRepair ? color.new(C_GOLD, 72) : na : na)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 7, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "STRUCTURE", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "SIR", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "State", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, upperExtension ? "Upper Ext" : lowerExtension ? "Lower Ext" : upperRepair or lowerRepair ? "Repair" : "Fair", text_color=upperRepair or lowerRepair ? C_GOLD : theme, text_size=size.small)
    table.cell(hud, 0, 2, "Residual Z", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(z, "#.00"), text_color=z >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 3, "Ineff", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(inefficiency, "#.0"), text_color=inefficiency >= 65 ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 4, "Slope", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(slope, "#.00"), text_color=slope >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 5, "Repair", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(repairForce, "#.0"), text_color=repairForce >= repairGate ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 6, "Extend", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(extensionForce, "#.0"), text_color=extensionForce >= repairGate ? C_GOLD : C_MUTED, text_size=size.small)

alertcondition(extUpEvent, "SIR Upper Extension [JOAT]", "Structural Inefficiency Radar upper extension")
alertcondition(extDnEvent, "SIR Lower Extension [JOAT]", "Structural Inefficiency Radar lower extension")
alertcondition(repairUpEvent or repairDnEvent, "SIR Fair-Value Repair [JOAT]", "Structural Inefficiency Radar fair-value repair")
````
