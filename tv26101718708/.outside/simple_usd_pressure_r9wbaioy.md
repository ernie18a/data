# Simple USD Pressure

- url: https://www.tradingview.com/script/R9WBaIOY-Simple-USD-Pressure/
- type: indicator
- pine_id: PUB;ad77368d11b64a448cc48c3300928937
- version: 1.0

## Description

Simple USD Pressure

Simple USD Pressure is a market pressure and directional regime indicator designed to measure broad U.S. Dollar strength and weakness by analyzing multiple USD-related instruments simultaneously.

Rather than relying on a single source such as DXY alone, this indicator evaluates the directional alignment of major USD currency pairs and can optionally incorporate additional confirming instruments including DXY, Gold, US10Y yields, and SPX risk sentiment to build a broader view of USD behavior.

The goal is to provide a cleaner view of underlying dollar pressure and identify shifts in overall market conditions that may influence Forex pairs, indices, commodities, and risk assets.

Features:

• Multi-pair USD pressure analysis
• Uses major USD pairs including:

EURUSD
GBPUSD
AUDUSD
NZDUSD
USDJPY
USDCHF
USDCAD

• Optional confirmation instruments:

DXY
Gold
US10Y
SPX

• Composite USD scoring system
• Customizable calculation timeframe
• Optional "Wait Until Bar Close" confirmation logic
• Adjustable trend thresholds
• Market regime detection:

USD Strong
USD Weak
USD Mixed

• Visual background highlighting
• Regime transition markers
• Summary table including:

Bull pair votes
Bear pair votes
USD pressure score
Confirmation score
Composite score
Current regime

Alerts Included:

• USD Strong Shift
• USD Weak Shift
• USD Mixed Shift
• Active USD Strong
• Active USD Weak
• Active USD Mixed

Potential use cases:

• Gauge broad USD strength or weakness
• Add directional bias to Forex trades
• Confirm risk-on or risk-off environments
• Identify changes in market conditions
• Use as a higher-level market filter
• Add confluence to existing systems

Interpretation:

USD Strong

Broad alignment suggests stronger dollar participation across selected instruments

USD Weak

Broad alignment suggests weaker dollar participation across selected instruments

USD Mixed

Signals are relatively balanced and directional pressure may be less defined

About TrendGenY Indicators
[i]
TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Simple USD Pressure", shorttitle="USD Pressure", overlay=false, precision=2)

//====================================================
// Inputs
//====================================================
grpCore = "Core"
calcTF       = input.timeframe("", "Calculation Timeframe (blank = chart TF)", group=grpCore)
lookbackBars = input.int(1, "Direction Lookback Bars", minval=1, group=grpCore)
smoothLen    = input.int(3, "Smoothing Length", minval=1, group=grpCore)
waitClose    = input.bool(true, "Wait Until Bar Close", group=grpCore)

grpPairs = "USD Major Pairs"
brokerFX = input.string("OANDA", "FX Feed", options=["OANDA", "FOREXCOM", "FX_IDC", "SAXO", "FX"], group=grpPairs)
useEURUSD = input.bool(true, "Include EURUSD", group=grpPairs)
useGBPUSD = input.bool(true, "Include GBPUSD", group=grpPairs)
useAUDUSD = input.bool(true, "Include AUDUSD", group=grpPairs)
useNZDUSD = input.bool(true, "Include NZDUSD", group=grpPairs)
useUSDJPY = input.bool(true, "Include USDJPY", group=grpPairs)
useUSDCHF = input.bool(true, "Include USDCHF", group=grpPairs)
useUSDCAD = input.bool(true, "Include USDCAD", group=grpPairs)

grpConfirm = "Optional Confirming Instruments"
useDXY   = input.bool(true, "Include DXY Confirm", group=grpConfirm)
useGold  = input.bool(true, "Include Gold Confirm", group=grpConfirm)
useUS10Y = input.bool(false, "Include US10Y Confirm", group=grpConfirm)
useSPX   = input.bool(false, "Include SPX Risk Confirm", group=grpConfirm)

dxySymbol   = input.string("TVC:DXY", "DXY Symbol", group=grpConfirm)
goldSymbol  = input.string("OANDA:XAUUSD", "Gold Symbol", group=grpConfirm)
us10ySymbol = input.string("TVC:US10Y", "US10Y Symbol", group=grpConfirm)
spxSymbol   = input.string("TVC:SPX", "SPX Symbol", group=grpConfirm)

grpDisplay = "Display"
showPressureLine  = input.bool(true, "Show USD Pressure", group=grpDisplay)
showConfirmLine   = input.bool(true, "Show Confirm Score", group=grpDisplay)
showCompositeLine = input.bool(true, "Show Composite Score", group=grpDisplay)
showBackground    = input.bool(true, "Show Background", group=grpDisplay)
showTable         = input.bool(true, "Show Summary Table", group=grpDisplay)
showMarkers       = input.bool(true, "Show Regime Change Markers", group=grpDisplay)

grpThresh = "Thresholds"
trendThresh = input.float(0.50, "Trend Threshold", minval=0.0, maxval=1.0, step=0.05, group=grpThresh, tooltip="0.50 means at least half of net possible alignment toward one side")

grpCol = "Colors"
upColor      = input.color(color.lime, "USD Strong Color", group=grpCol)
downColor    = input.color(color.red, "USD Weak Color", group=grpCol)
neutralColor = input.color(color.orange, "Neutral Color", group=grpCol)
pressColor   = input.color(color.aqua, "Pressure Line", group=grpCol)
confirmColor = input.color(color.fuchsia, "Confirm Line", group=grpCol)
comboColor   = input.color(color.white, "Composite Line", group=grpCol)

grpTable = "Table"
tblPosIn  = input.string("Top Right", "Table Location", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grpTable)
tblSizeIn = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpTable)

//====================================================
// Helpers
//====================================================
tfToUse = calcTF == "" ? timeframe.period : calcTF
lookaheadMode = waitClose ? barmerge.lookahead_off : barmerge.lookahead_on

tblPos =
     tblPosIn == "Top Left" ? position.top_left :
     tblPosIn == "Top Center" ? position.top_center :
     tblPosIn == "Top Right" ? position.top_right :
     tblPosIn == "Middle Left" ? position.middle_left :
     tblPosIn == "Middle Center" ? position.middle_center :
     tblPosIn == "Middle Right" ? position.middle_right :
     tblPosIn == "Bottom Left" ? position.bottom_left :
     tblPosIn == "Bottom Center" ? position.bottom_center :
     position.bottom_right

tblSize =
     tblSizeIn == "Tiny" ? size.tiny :
     tblSizeIn == "Small" ? size.small :
     tblSizeIn == "Normal" ? size.normal :
     size.large

getSecClose(sym) =>
    request.security(sym, tfToUse, close, barmerge.gaps_off, lookaheadMode)

dirScore(sym, usdBullWhenUp) =>
    c = getSecClose(sym)
    chg = c - c[lookbackBars]
    chg > 0 ? (usdBullWhenUp ? 1.0 : -1.0) : chg < 0 ? (usdBullWhenUp ? -1.0 : 1.0) : 0.0

dirText(v) =>
    v > 0 ? "Bull" : v < 0 ? "Bear" : "Flat"

//====================================================
// Pair Scores
//====================================================
eurusdScore = useEURUSD ? dirScore(brokerFX + ":EURUSD", false) : na
gbpusdScore = useGBPUSD ? dirScore(brokerFX + ":GBPUSD", false) : na
audusdScore = useAUDUSD ? dirScore(brokerFX + ":AUDUSD", false) : na
nzdusdScore = useNZDUSD ? dirScore(brokerFX + ":NZDUSD", false) : na
usdjpyScore = useUSDJPY ? dirScore(brokerFX + ":USDJPY", true) : na
usdchfScore = useUSDCHF ? dirScore(brokerFX + ":USDCHF", true) : na
usdcadScore = useUSDCAD ? dirScore(brokerFX + ":USDCAD", true) : na

pairBullVotes = (useEURUSD and eurusdScore == 1.0 ? 1 : 0) + (useGBPUSD and gbpusdScore == 1.0 ? 1 : 0) + (useAUDUSD and audusdScore == 1.0 ? 1 : 0) + (useNZDUSD and nzdusdScore == 1.0 ? 1 : 0) + (useUSDJPY and usdjpyScore == 1.0 ? 1 : 0) + (useUSDCHF and usdchfScore == 1.0 ? 1 : 0) + (useUSDCAD and usdcadScore == 1.0 ? 1 : 0)

pairBearVotes = (useEURUSD and eurusdScore == -1.0 ? 1 : 0) + (useGBPUSD and gbpusdScore == -1.0 ? 1 : 0) + (useAUDUSD and audusdScore == -1.0 ? 1 : 0) + (useNZDUSD and nzdusdScore == -1.0 ? 1 : 0) + (useUSDJPY and usdjpyScore == -1.0 ? 1 : 0) + (useUSDCHF and usdchfScore == -1.0 ? 1 : 0) + (useUSDCAD and usdcadScore == -1.0 ? 1 : 0)

pairTotal = (useEURUSD ? 1 : 0) + (useGBPUSD ? 1 : 0) + (useAUDUSD ? 1 : 0) + (useNZDUSD ? 1 : 0) + (useUSDJPY ? 1 : 0) + (useUSDCHF ? 1 : 0) + (useUSDCAD ? 1 : 0)

usdPressureRaw = pairTotal > 0 ? (pairBullVotes - pairBearVotes) / pairTotal : 0.0
usdPressure = ta.ema(usdPressureRaw, smoothLen)

//====================================================
// Confirming Instruments
//====================================================
dxyScore = useDXY ? dirScore(dxySymbol, true) : na
goldScore = useGold ? dirScore(goldSymbol, false) : na
us10yScore = useUS10Y ? dirScore(us10ySymbol, true) : na
spxScore = useSPX ? dirScore(spxSymbol, false) : na

confirmBullVotes = (useDXY and dxyScore == 1.0 ? 1 : 0) + (useGold and goldScore == 1.0 ? 1 : 0) + (useUS10Y and us10yScore == 1.0 ? 1 : 0) + (useSPX and spxScore == 1.0 ? 1 : 0)

confirmBearVotes = (useDXY and dxyScore == -1.0 ? 1 : 0) + (useGold and goldScore == -1.0 ? 1 : 0) + (useUS10Y and us10yScore == -1.0 ? 1 : 0) + (useSPX and spxScore == -1.0 ? 1 : 0)

confirmTotal = (useDXY ? 1 : 0) + (useGold ? 1 : 0) + (useUS10Y ? 1 : 0) + (useSPX ? 1 : 0)

confirmScoreRaw = confirmTotal > 0 ? (confirmBullVotes - confirmBearVotes) / confirmTotal : 0.0
confirmScore = ta.ema(confirmScoreRaw, smoothLen)

//====================================================
// Composite
//====================================================
compositeRaw = confirmTotal > 0 ? (usdPressureRaw * 0.7 + confirmScoreRaw * 0.3) : usdPressureRaw
composite = ta.ema(compositeRaw, smoothLen)

//====================================================
// Regime
//====================================================
isUsdStrong = composite >= trendThresh
isUsdWeak   = composite <= -trendThresh
isNeutral   = not isUsdStrong and not isUsdWeak

regimeText = isUsdStrong ? "USD Strong" : isUsdWeak ? "USD Weak" : "USD Mixed"
regimeColor = isUsdStrong ? upColor : isUsdWeak ? downColor : neutralColor
state = isUsdStrong ? 1 : isUsdWeak ? -1 : 0
stateChanged = state != nz(state[1])

//====================================================
// Plots
//====================================================
hline(0, "Zero", color=color.gray)
hline(trendThresh, "USD Strong Threshold", color=color.new(color.lime, 60))
hline(-trendThresh, "USD Weak Threshold", color=color.new(color.red, 60))

plot(showPressureLine ? usdPressure : na, "USD Pressure", color=pressColor, linewidth=2)
plot(showConfirmLine ? confirmScore : na, "Confirm Score", color=confirmColor, linewidth=2)
plot(showCompositeLine ? composite : na, "Composite", color=comboColor, linewidth=3)

bgcolor(showBackground ? color.new(regimeColor, 88) : na)

//====================================================
// Markers
//====================================================
plotshape(showMarkers and stateChanged and isUsdStrong, title="USD Strong", style=shape.triangleup, location=location.bottom, size=size.tiny, color=upColor, text="USD+")
plotshape(showMarkers and stateChanged and isUsdWeak, title="USD Weak", style=shape.triangledown, location=location.top, size=size.tiny, color=downColor, text="USD-")
plotshape(showMarkers and stateChanged and isNeutral, title="USD Mixed", style=shape.circle, location=location.bottom, size=size.tiny, color=neutralColor, text="Mix")

//====================================================
// Table
//====================================================
var table t = table.new(tblPos, 2, 8)

if barstate.islast and showTable
    table.cell(t, 0, 0, "Metric", text_color=color.white, bgcolor=color.black, text_size=tblSize)
    table.cell(t, 1, 0, "Value", text_color=color.white, bgcolor=color.black, text_size=tblSize)

    table.cell(t, 0, 1, "Bull Pair Votes", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 1, str.tostring(pairBullVotes), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 2, "Bear Pair Votes", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 2, str.tostring(pairBearVotes), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 3, "USD Pressure", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 3, str.tostring(usdPressure, "#.00"), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 4, "Confirm Score", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 4, str.tostring(confirmScore, "#.00"), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 5, "Composite", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 5, str.tostring(composite, "#.00"), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

    table.cell(t, 0, 6, "Regime", text_color=color.white, bgcolor=regimeColor, text_size=tblSize)
    table.cell(t, 1, 6, regimeText, text_color=color.white, bgcolor=regimeColor, text_size=tblSize)

    table.cell(t, 0, 7, "Pair Count", text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)
    table.cell(t, 1, 7, str.tostring(pairTotal), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=tblSize)

//====================================================
// Alerts
//====================================================
alertcondition(stateChanged and isUsdStrong, title="USD Strong", message="USD Pressure shifted to USD Strong on {{ticker}} {{interval}}")
alertcondition(stateChanged and isUsdWeak, title="USD Weak", message="USD Pressure shifted to USD Weak on {{ticker}} {{interval}}")
alertcondition(stateChanged and isNeutral, title="USD Mixed", message="USD Pressure shifted to USD Mixed on {{ticker}} {{interval}}")
alertcondition(isUsdStrong, title="USD Strong (Active)", message="USD Pressure is currently USD Strong on {{ticker}} {{interval}}")
alertcondition(isUsdWeak, title="USD Weak (Active)", message="USD Pressure is currently USD Weak on {{ticker}} {{interval}}")
alertcondition(isNeutral, title="USD Mixed (Active)", message="USD Pressure is currently USD Mixed on {{ticker}} {{interval}}")
````
