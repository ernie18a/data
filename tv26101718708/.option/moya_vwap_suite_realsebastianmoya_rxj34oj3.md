# MOYA VWAP Suite [RealSebastianMoya]

- url: https://www.tradingview.com/script/rxj34Oj3-MOYA-VWAP-Suite-RealSebastianMoya/
- type: indicator
- pine_id: PUB;0c40fe9795364567a6a39e6d771734f6
- version: 1.0

## Description

Hello traders!

Introducing: "MOYA VWAP Suite"

This script brings together every meaningful way institutional and retail traders use VWAP into a single, fully configurable tool — five independent session-based VWAPs, classic period-extreme anchored VWAPs (Daily/Weekly/Monthly, High and Low), a custom anchor for swing points or exact dates, standard deviation bands, and real futures volume normalization for Forex/CFD charts.

[image]https://www.tradingview.com/x/ZCeljY1d/[/image]

Rather than forcing you to choose one "flavor" of VWAP, this script lets every type run simultaneously, each with independent styling — so you can build the exact multi-timeframe VWAP stack you actually trade with.

♦ Why VWAP Matters

VWAP (Volume Weighted Average Price) isn't just another moving average — it's the price institutions benchmark their own execution against. Large funds can't fill a position in one trade without moving the market against themselves, so they split large orders across the session and measure their own performance relative to VWAP: filling below it on a buy program is considered good execution, filling above it is considered poor execution.

Because of this, VWAP behaves like a real support/resistance level with actual participants defending it — not just a lagging technical indicator.

♦ Features

Standard VWAP — 5 Configurable Slots Each slot can be set to any of 29 session lengths (Tokyo, London, New York, 1H through 12H, Daily through 7 Days, Weekly through 5 Weeks, Monthly through 7 Months, Quarterly, Yearly), with independent color, width, and line style (Solid, StepLine, Circles, Cross, Dashed).

VWAP Close Levels When a session ends, mark a fixed horizontal line at the price where that session's VWAP closed — a persistent reference level, independently styled per slot.

Period-Extreme Anchored VWAP (Daily / Weekly / Monthly) A VWAP that continuously re-anchors itself live, every time a new high or low forms within the current day, week, or month. Choose to anchor from the High, the Low, or both simultaneously, with independent colors for each.

Custom Anchored VWAP Anchor from an automatically detected swing high/low (with adjustable sensitivity) or from an exact date and time you set yourself — for anchoring to a specific event, range start, or impulse move.

Standard Deviation Bands Two configurable bands calculated around any VWAP in the script (any of the 5 slots, any of the six period-extreme anchors, or the custom anchor), with independent multiplier, line colors, width, and fill color per band — matching TradingView's native VWAP band styling.

Real Futures Volume Normalization Forex and CFD brokers report synthetic tick volume, not real traded volume. This script can automatically detect the related futures contract for your current symbol (XAUUSD → Gold futures, EURUSD → Euro futures, BTCUSD → Bitcoin futures, and more) and rescale the volume weighting every VWAP uses, so the calculation reflects real market participation instead of your broker's tick count.

Live Information Panel Shows the current value of every active VWAP, plus which volume source is feeding the calculation and whether it's receiving live data — all in one glance, positioned in any corner of the chart.

♦ Who This Is For

This script is built for traders who read the market through volume-weighted price levels rather than pure price action — those who already think in terms of:

fair value and execution benchmarks
multi-timeframe confluence (does the daily VWAP sit inside last week's anchored range?)
mean reversion toward a statistically "fair" price versus continuation away from it
how real, regulated market volume compares to what a CFD broker reports

If you're used to trading around VWAP on futures or equities and want that same read available across Forex, indices, crypto, and any other chart — including with real futures-based volume weighting — this is built for that specific use case.

♦ How It's Used — Example Approaches

Intraday mean reversion: Run Slot 1 on Daily VWAP as your session baseline. Price extended away from it without matching volume growth often reverts back toward the line — especially when it's also sitting inside the Band #1 deviation range.

Multi-timeframe bias: Run Slot 1 (Daily), Slot 2 (Weekly), and Slot 3 (Monthly) together. When price is above all three, that's confluence for a bullish bias; when the daily VWAP crosses back below the weekly, that's an early signal the shorter-term trend may be losing strength.

Reacting to a specific move: Use the Custom Anchor to mark the VWAP starting from a major swing low or a specific news candle — this shows you the volume-weighted average price of everyone who has traded since that exact point, which is often more relevant than a session-based VWAP when you're tracking a specific move.

Trading real institutional levels on Forex/CFD: Enable External Futures Volume with Auto Detect on a symbol like XAUUSD — the VWAP and its bands now reflect real Gold futures volume instead of your broker's synthetic tick count, which matters most exactly when the two diverge.

(Configuration walkthroughs and chart examples for each of these scenarios below.)

♦ Credits

Original inspiration drawn from the standard institutional VWAP concept and Auction Market Theory. Extended and combined by RealSebastianMoya / MOYA Organization into a unified multi-mode VWAP engine with real futures volume normalization — an original build, not a modification of a third-party script.

Licensed under Mozilla Public License 2.0.
Open-source script

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RealSebastianMoya
//@version=6
indicator("MOYA VWAP Suite [RealSebastianMoya]", shorttitle="MOYA VWAP Suite [RealSebastianMoya]", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=1000)

// ============================================================
// INPUTS — EXTERNAL FUTURES VOLUME (con auto-detección)
// ============================================================
grpExtVol         = "External Futures Volume"
useExternalVol    = input.bool(false, "Use External Futures Volume", tooltip="Replaces this chart's native volume with real futures volume — útil en gráficos CFD/Forex (EURUSD, XAUUSD, etc.) donde el volumen del bróker es sintético. Afecta el peso de TODOS los VWAP de este indicador.", group=grpExtVol)
autoDetectFutures = input.bool(true,  "🔄 Auto Detect Futures Ticker", tooltip="Detecta automáticamente el futuro relacionado según el símbolo del gráfico actual (ej: XAUUSD → GC1!, NAS100 → NQ1!). Si no hay match, cae al ticker manual de abajo.", group=grpExtVol)
externalVolSymbol = input.symbol("CME:6E1!", "Manual Futures Symbol (fallback / si Auto está OFF)", group=grpExtVol)
showTickerPanel   = input.bool(true, "Show Vol. Source in Panel", group=grpExtVol)

// ============================================================
// INPUTS — VWAP GENERAL
// ============================================================
grpVwapGen        = "VWAP — General"
showVwapMaster    = input.bool(true, '● Master Toggle (ALL VWAPs ON/OFF)', group=grpVwapGen)
vwapSrcType       = input.string("HLC3", "Source", options=["Close","HL2","HLC3","OHLC4","HLCC4"], group=grpVwapGen)
vwapInPanel       = input.bool(true, "Show VWAP Values in Panel", group=grpVwapGen)
vwapCloseExtBars  = input.int(50, "Close Level Extension (bars)", minval=1, maxval=500, group=grpVwapGen)

// ============================================================
// INPUTS — VWAP SLOTS ESTÁNDAR (5 slots configurables, cualquier temporalidad)
// ============================================================
grpVwapS1 = "VWAP Slot 1"
vwapS1_show       = input.bool(true,  "Show", group=grpVwapS1)
vwapS1_type       = input.string("Daily", "Session Type", options=['Tokyo','London','New York',
     '1 Hour','4 Hours','6 Hours','8 Hours','12 Hours',
     'Daily','2 Days','3 Days','4 Days','5 Days','6 Days','7 Days',
     'Weekly','2 Weeks','3 Weeks','4 Weeks','5 Weeks',
     'Monthly','2 Months','3 Months','4 Months','5 Months','6 Months','7 Months',
     'Quarterly','Yearly'], group=grpVwapS1)
vwapS1_color      = input.color(color.new(color.teal, 0), "Line Color", inline='s1', group=grpVwapS1)
vwapS1_width      = input.int(2, "Width", minval=1, maxval=5, inline='s1', group=grpVwapS1)
vwapS1_style      = input.string("Solid", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpVwapS1)
vwapS1_showClose  = input.bool(false, "Show Close Level", group=grpVwapS1)
vwapS1_closeColor = input.color(color.new(color.teal, 0), "Close Color", inline='s1c', group=grpVwapS1)
vwapS1_closeWidth = input.int(1, "Close Width", minval=1, maxval=5, inline='s1c', group=grpVwapS1)

grpVwapS2 = "VWAP Slot 2"
vwapS2_show       = input.bool(true,  "Show", group=grpVwapS2)
vwapS2_type       = input.string("Weekly", "Session Type", options=['Tokyo','London','New York',
     '1 Hour','4 Hours','6 Hours','8 Hours','12 Hours',
     'Daily','2 Days','3 Days','4 Days','5 Days','6 Days','7 Days',
     'Weekly','2 Weeks','3 Weeks','4 Weeks','5 Weeks',
     'Monthly','2 Months','3 Months','4 Months','5 Months','6 Months','7 Months',
     'Quarterly','Yearly'], group=grpVwapS2)
vwapS2_color      = input.color(color.new(color.orange, 0), "Line Color", inline='s2', group=grpVwapS2)
vwapS2_width      = input.int(2, "Width", minval=1, maxval=5, inline='s2', group=grpVwapS2)
vwapS2_style      = input.string("Dashed", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpVwapS2)
vwapS2_showClose  = input.bool(false, "Show Close Level", group=grpVwapS2)
vwapS2_closeColor = input.color(color.new(color.orange, 0), "Close Color", inline='s2c', group=grpVwapS2)
vwapS2_closeWidth = input.int(1, "Close Width", minval=1, maxval=5, inline='s2c', group=grpVwapS2)

grpVwapS3 = "VWAP Slot 3"
vwapS3_show       = input.bool(true,  "Show", group=grpVwapS3)
vwapS3_type       = input.string("Monthly", "Session Type", options=['Tokyo','London','New York',
     '1 Hour','4 Hours','6 Hours','8 Hours','12 Hours',
     'Daily','2 Days','3 Days','4 Days','5 Days','6 Days','7 Days',
     'Weekly','2 Weeks','3 Weeks','4 Weeks','5 Weeks',
     'Monthly','2 Months','3 Months','4 Months','5 Months','6 Months','7 Months',
     'Quarterly','Yearly'], group=grpVwapS3)
vwapS3_color      = input.color(color.new(color.purple, 0), "Line Color", inline='s3', group=grpVwapS3)
vwapS3_width      = input.int(2, "Width", minval=1, maxval=5, inline='s3', group=grpVwapS3)
vwapS3_style      = input.string("Dashed", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpVwapS3)
vwapS3_showClose  = input.bool(false, "Show Close Level", group=grpVwapS3)
vwapS3_closeColor = input.color(color.new(color.purple, 0), "Close Color", inline='s3c', group=grpVwapS3)
vwapS3_closeWidth = input.int(1, "Close Width", minval=1, maxval=5, inline='s3c', group=grpVwapS3)

grpVwapS4 = "VWAP Slot 4"
vwapS4_show       = input.bool(false, "Show", group=grpVwapS4)
vwapS4_type       = input.string("4 Hours", "Session Type", options=['Tokyo','London','New York',
     '1 Hour','4 Hours','6 Hours','8 Hours','12 Hours',
     'Daily','2 Days','3 Days','4 Days','5 Days','6 Days','7 Days',
     'Weekly','2 Weeks','3 Weeks','4 Weeks','5 Weeks',
     'Monthly','2 Months','3 Months','4 Months','5 Months','6 Months','7 Months',
     'Quarterly','Yearly'], group=grpVwapS4)
vwapS4_color      = input.color(color.new(color.blue, 0), "Line Color", inline='s4', group=grpVwapS4)
vwapS4_width      = input.int(1, "Width", minval=1, maxval=5, inline='s4', group=grpVwapS4)
vwapS4_style      = input.string("Solid", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpVwapS4)
vwapS4_showClose  = input.bool(false, "Show Close Level", group=grpVwapS4)
vwapS4_closeColor = input.color(color.new(color.blue, 0), "Close Color", inline='s4c', group=grpVwapS4)
vwapS4_closeWidth = input.int(1, "Close Width", minval=1, maxval=5, inline='s4c', group=grpVwapS4)

grpVwapS5 = "VWAP Slot 5"
vwapS5_show       = input.bool(false, "Show", group=grpVwapS5)
vwapS5_type       = input.string("1 Hour", "Session Type", options=['Tokyo','London','New York',
     '1 Hour','4 Hours','6 Hours','8 Hours','12 Hours',
     'Daily','2 Days','3 Days','4 Days','5 Days','6 Days','7 Days',
     'Weekly','2 Weeks','3 Weeks','4 Weeks','5 Weeks',
     'Monthly','2 Months','3 Months','4 Months','5 Months','6 Months','7 Months',
     'Quarterly','Yearly'], group=grpVwapS5)
vwapS5_color      = input.color(color.new(color.gray, 0), "Line Color", inline='s5', group=grpVwapS5)
vwapS5_width      = input.int(1, "Width", minval=1, maxval=5, inline='s5', group=grpVwapS5)
vwapS5_style      = input.string("Solid", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpVwapS5)
vwapS5_showClose  = input.bool(false, "Show Close Level", group=grpVwapS5)
vwapS5_closeColor = input.color(color.new(color.gray, 0), "Close Color", inline='s5c', group=grpVwapS5)
vwapS5_closeWidth = input.int(1, "Close Width", minval=1, maxval=5, inline='s5c', group=grpVwapS5)

// ============================================================
// INPUTS — VWAP ANCLADO A EXTREMOS DE PERÍODO (estilo clásico, D/W/M)
// Se re-ancla EN VIVO cada vez que se forma un nuevo high/low
// dentro del período — por eso "se mueve con el gráfico".
// ============================================================
grpAncDWM        = "VWAP Anchored — Period Extremes (D/W/M)"
ancDWM_show      = input.bool(true, "● Show Period-Extreme Anchored VWAPs", group=grpAncDWM)
ancDWM_mode      = input.string("Ambos", "Anclar desde", options=["High","Low","Ambos"], group=grpAncDWM, tooltip="High: solo ancla desde el máximo del período. Low: solo desde el mínimo. Ambos: muestra las dos líneas.")
ancDWM_inPanel   = input.bool(false, "Show in Panel", group=grpAncDWM)

grpAncD = "Anchored — Daily"
ancD_show   = input.bool(true,  "Show Daily Anchored", group=grpAncD)
ancD_colorH = input.color(color.rgb(255,220,50,0), "Color High", inline='ad', group=grpAncD)
ancD_colorL = input.color(color.rgb(50,220,255,0), "Color Low",  inline='ad', group=grpAncD)
ancD_width  = input.int(1, "Width", minval=1, maxval=5, inline='ad', group=grpAncD)
ancD_style  = input.string("Dashed", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpAncD)

grpAncW = "Anchored — Weekly"
ancW_show   = input.bool(true,  "Show Weekly Anchored", group=grpAncW)
ancW_colorH = input.color(color.rgb(255,140,0,0), "Color High", inline='aw', group=grpAncW)
ancW_colorL = input.color(color.rgb(0,180,255,0), "Color Low",  inline='aw', group=grpAncW)
ancW_width  = input.int(1, "Width", minval=1, maxval=5, inline='aw', group=grpAncW)
ancW_style  = input.string("Dashed", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpAncW)

grpAncM = "Anchored — Monthly"
ancM_show   = input.bool(false, "Show Monthly Anchored", group=grpAncM)
ancM_colorH = input.color(color.rgb(200,80,255,0), "Color High", inline='am', group=grpAncM)
ancM_colorL = input.color(color.rgb(80,255,200,0), "Color Low",  inline='am', group=grpAncM)
ancM_width  = input.int(1, "Width", minval=1, maxval=5, inline='am', group=grpAncM)
ancM_style  = input.string("Dashed", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpAncM)

// ============================================================
// INPUTS — VWAP ANCLADO PERSONALIZADO (Swing automático o fecha manual)
// ============================================================
grpAncC        = "VWAP Anchored — Custom (Swing / Manual Date)"
ancC_show      = input.bool(false, "Show Custom Anchored VWAP", group=grpAncC)
ancC_mode      = input.string("Auto Swing High", "Anchor Mode", options=["Auto Swing High","Auto Swing Low","Manual Date"], group=grpAncC)
ancC_swingLen  = input.int(10, "Swing Sensitivity (bars each side)", minval=1, maxval=200, group=grpAncC, tooltip="Cuántas velas a cada lado definen un swing high/low. El anclaje se confirma con un retraso de este número de barras (comportamiento normal de cualquier pivot).")
ancC_manualTime= input.time(timestamp("2026-01-01T00:00:00"), "Manual Anchor Date/Time (si Anchor Mode = Manual Date)", group=grpAncC)
ancC_color     = input.color(color.new(color.fuchsia, 0), "Color", inline='ac', group=grpAncC)
ancC_width     = input.int(2, "Width", minval=1, maxval=5, inline='ac', group=grpAncC)
ancC_style     = input.string("Solid", "Style", options=['Solid','StepLine','Circles','Cross','Dashed'], group=grpAncC)

// ============================================================
// INPUTS — VWAP DEVIATION BANDS
// ============================================================
grpBands       = "VWAP Deviation Bands"
bandsShow      = input.bool(true, "● Show Deviation Bands", group=grpBands)
bandsSource    = input.string("Slot 1", "Bands Source", options=["Slot 1","Slot 2","Slot 3","Slot 4","Slot 5","Daily High Anchor","Daily Low Anchor","Weekly High Anchor","Weekly Low Anchor","Monthly High Anchor","Monthly Low Anchor","Custom Anchor"], group=grpBands, tooltip="A cuál VWAP se le calculan las bandas de desviación estándar.")
band1Show      = input.bool(true, "Show Band #1", group=grpBands)
band1Mult      = input.float(1.0, "Band #1 Multiplier (Std Dev)", step=0.1, group=grpBands)
band1UpColor   = input.color(color.new(color.blue, 0), "Band #1 Upper Color", inline='b1', group=grpBands)
band1DnColor   = input.color(color.new(color.blue, 0), "Band #1 Lower Color", inline='b1', group=grpBands)
band1Width     = input.int(1, "Band #1 Width", minval=1, maxval=5, group=grpBands)
band1FillColor = input.color(color.new(color.blue, 90), "Band #1 Fill", group=grpBands)
band2Show      = input.bool(true, "Show Band #2", group=grpBands)
band2Mult      = input.float(2.0, "Band #2 Multiplier (Std Dev)", step=0.1, group=grpBands)
band2UpColor   = input.color(color.new(color.purple, 0), "Band #2 Upper Color", inline='b2', group=grpBands)
band2DnColor   = input.color(color.new(color.purple, 0), "Band #2 Lower Color", inline='b2', group=grpBands)
band2Width     = input.int(1, "Band #2 Width", minval=1, maxval=5, group=grpBands)
band2FillColor = input.color(color.new(color.purple, 90), "Band #2 Fill", group=grpBands)

// ============================================================
// INPUTS — LIVE PANEL
// ============================================================
grpPanel       = "Live Panel"
showPanel      = input.bool(true,         'Show Panel', group=grpPanel)
panelPos       = input.string('Top Right','Position', options=['Top Right','Top Left','Bottom Right','Bottom Left'], group=grpPanel)
panelBgColor   = input.color(color.new(#0b0f17,10), 'Panel Background',  group=grpPanel)
panelTextColor = input.color(color.white,            'Text Color',  group=grpPanel)

// ============================================================
// GLOBAL VARIABLES
// ============================================================
var int dayCount   = 0
var int weekCount  = 0
var int monthCount = 0
var table infoPanel = na

// Acumuladores del anclaje a extremos de período (D/W/M × High/Low)
var float dAncH_SV = 0.0
var float dAncH_V  = 0.0
var float dAncH_px = 0.0
var float dAncL_SV = 0.0
var float dAncL_V  = 0.0
var float dAncL_px = 9999999.0

var float wAncH_SV = 0.0
var float wAncH_V  = 0.0
var float wAncH_px = 0.0
var float wAncL_SV = 0.0
var float wAncL_V  = 0.0
var float wAncL_px = 9999999.0

var float mAncH_SV = 0.0
var float mAncH_V  = 0.0
var float mAncH_px = 0.0
var float mAncL_SV = 0.0
var float mAncL_V  = 0.0
var float mAncL_px = 9999999.0

// ============================================================
// DATA — auto-detección de futuros
// ============================================================
getAutoFuturesTicker() =>
    t = syminfo.ticker
    switch t
        "XAUUSD" => "COMEX:GC1!"
        "XAGUSD" => "COMEX:SI1!"
        "EURUSD" => "CME:6E1!"
        "GBPUSD" => "CME:6B1!"
        "USDJPY" => "CME:6J1!"
        "AUDUSD" => "CME:6A1!"
        "USDCAD" => "CME:6C1!"
        "USDCHF" => "CME:6S1!"
        "NZDUSD" => "CME:6N1!"
        "USOIL"  => "NYMEX:CL1!"
        "NATGAS" => "NYMEX:NG1!"
        "BTCUSD" => "CME:BTC1!"
        "ETHUSD" => "CME:ETH1!"
        => na

autoMatch          = getAutoFuturesTicker()
autoMatchFound     = not na(autoMatch)
resolvedExtSymbol  = useExternalVol ? (autoDetectFutures and autoMatchFound ? autoMatch : externalVolSymbol) : na
usingAutoNow       = useExternalVol and autoDetectFutures and autoMatchFound

externalVolume  = request.security(resolvedExtSymbol, timeframe.period, volume, ignore_invalid_symbol=true)
nativeBarVolume = volume
volScaleFactor  = (useExternalVol and nativeBarVolume > 0 and not na(externalVolume)) ? externalVolume / nativeBarVolume : 1.0
effVolume       = volume * volScaleFactor

// ============================================================
// PERIOD DETECTION — using timeframe.change() (correct)
// ============================================================
newDaily     = timeframe.change("D")
newWeekly    = timeframe.change("W")
newMonthly   = timeframe.change("M")
newQuarterly = timeframe.change("3M")
newYearly    = timeframe.change("12M")

utcHour = hour(time(timeframe.period,'0000-2400','GMT'),'GMT')

newTokyo   = utcHour != utcHour[1]+1 and utcHour != utcHour[1]
newLondon  = utcHour >= 7  and utcHour[1] < 7
newNewYork = utcHour >= 13 and utcHour[1] < 13

new1h  = utcHour != utcHour[1]
new4h  = utcHour % 4  == 0 and utcHour[1] % 4  != 0
new6h  = utcHour % 6  == 0 and utcHour[1] % 6  != 0
new8h  = utcHour % 8  == 0 and utcHour[1] % 8  != 0
new12h = utcHour % 12 == 0 and utcHour[1] % 12 != 0

if newDaily
    dayCount += 1
if newWeekly
    weekCount += 1
if newMonthly
    monthCount += 1

new2D = newDaily   and dayCount   % 2 == 0
new3D = newDaily   and dayCount   % 3 == 0
new4D = newDaily   and dayCount   % 4 == 0
new5D = newDaily   and dayCount   % 5 == 0
new6D = newDaily   and dayCount   % 6 == 0
new7D = newDaily   and dayCount   % 7 == 0
new2W = newWeekly  and weekCount  % 2 == 0
new3W = newWeekly  and weekCount  % 3 == 0
new4W = newWeekly  and weekCount  % 4 == 0
new5W = newWeekly  and weekCount  % 5 == 0
new2M = newMonthly and monthCount % 2 == 0
new3M = newMonthly and monthCount % 3 == 0
new4M = newMonthly and monthCount % 4 == 0
new5M = newMonthly and monthCount % 5 == 0
new6M = newMonthly and monthCount % 6 == 0
new7M = newMonthly and monthCount % 7 == 0

// ============================================================
// VWAP — FUNCIONES COMPARTIDAS
// ============================================================
getPeriodBool(s) =>
    switch s
        'Tokyo'     => newTokyo
        'London'    => newLondon
        'New York'  => newNewYork
        '1 Hour'    => new1h
        '4 Hours'   => new4h
        '6 Hours'   => new6h
        '8 Hours'   => new8h
        '12 Hours'  => new12h
        'Daily'     => newDaily
        '2 Days'    => new2D
        '3 Days'    => new3D
        '4 Days'    => new4D
        '5 Days'    => new5D
        '6 Days'    => new6D
        '7 Days'    => new7D
        'Weekly'    => newWeekly
        '2 Weeks'   => new2W
        '3 Weeks'   => new3W
        '4 Weeks'   => new4W
        '5 Weeks'   => new5W
        'Monthly'   => newMonthly
        '2 Months'  => new2M
        '3 Months'  => new3M
        '4 Months'  => new4M
        '5 Months'  => new5M
        '6 Months'  => new6M
        '7 Months'  => new7M
        'Quarterly' => newQuarterly
        'Yearly'    => newYearly
        => newDaily

getVwapSrc() =>
    switch vwapSrcType
        "Close" => close
        "HL2"   => hl2
        "HLC3"  => hlc3
        "OHLC4" => math.avg(open, high, low, close)
        "HLCC4" => math.avg(high, low, close, close)
        => hlc3

getPlotStyle(s) =>
    switch s
        'Solid'    => plot.style_line
        'StepLine' => plot.style_stepline
        'Circles'  => plot.style_circles
        'Cross'    => plot.style_cross
        'Dashed'   => plot.style_line
        => plot.style_line

// VWAP + desviación estándar ponderada por volumen, acumuladores independientes por sitio de llamada
vwapCalcFull(src, isNewPeriod) =>
    var float sSV  = na
    var float sV   = na
    var float sS2V = na
    sSV  := isNewPeriod or na(sSV)  ? src*effVolume            : src*effVolume + sSV[1]
    sV   := isNewPeriod or na(sV)   ? effVolume                 : effVolume + sV[1]
    sS2V := isNewPeriod or na(sS2V) ? src*src*effVolume         : src*src*effVolume + sS2V[1]
    vw   = sV > 0 ? sSV / sV : na
    varc = sV > 0 ? (sS2V/sV - vw*vw) : na
    sd   = (not na(varc) and varc > 0) ? math.sqrt(varc) : 0.0
    [vw, sd]

vwapSrcVal = getVwapSrc()

// ─── VWAP Estándar — 5 slots flexibles ───
isNewS1 = getPeriodBool(vwapS1_type)
isNewS2 = getPeriodBool(vwapS2_type)
isNewS3 = getPeriodBool(vwapS3_type)
isNewS4 = getPeriodBool(vwapS4_type)
isNewS5 = getPeriodBool(vwapS5_type)

[vwap1, sd1] = vwapCalcFull(vwapSrcVal, isNewS1)
[vwap2, sd2] = vwapCalcFull(vwapSrcVal, isNewS2)
[vwap3, sd3] = vwapCalcFull(vwapSrcVal, isNewS3)
[vwap4, sd4] = vwapCalcFull(vwapSrcVal, isNewS4)
[vwap5, sd5] = vwapCalcFull(vwapSrcVal, isNewS5)

// ─── VWAP Anclado a extremos de período (D/W/M, estilo clásico, en vivo) ───
// Reset al inicio de cada período
if newDaily
    dAncH_SV := 0.0
    dAncH_V  := 0.0
    dAncH_px := high
    dAncL_SV := 0.0
    dAncL_V  := 0.0
    dAncL_px := low
if newWeekly
    wAncH_SV := 0.0
    wAncH_V  := 0.0
    wAncH_px := high
    wAncL_SV := 0.0
    wAncL_V  := 0.0
    wAncL_px := low
if newMonthly
    mAncH_SV := 0.0
    mAncH_V  := 0.0
    mAncH_px := high
    mAncL_SV := 0.0
    mAncL_V  := 0.0
    mAncL_px := low

// Re-anclar en vivo si se forma un nuevo extremo dentro del período
if high > dAncH_px
    dAncH_SV := 0.0
    dAncH_V  := 0.0
    dAncH_px := high
if low < dAncL_px
    dAncL_SV := 0.0
    dAncL_V  := 0.0
    dAncL_px := low
if high > wAncH_px
    wAncH_SV := 0.0
    wAncH_V  := 0.0
    wAncH_px := high
if low < wAncL_px
    wAncL_SV := 0.0
    wAncL_V  := 0.0
    wAncL_px := low
if high > mAncH_px
    mAncH_SV := 0.0
    mAncH_V  := 0.0
    mAncH_px := high
if low < mAncL_px
    mAncL_SV := 0.0
    mAncL_V  := 0.0
    mAncL_px := low

// Acumular cada barra
dAncH_SV += vwapSrcVal * effVolume
dAncH_V  += effVolume
dAncL_SV += vwapSrcVal * effVolume
dAncL_V  += effVolume
wAncH_SV += vwapSrcVal * effVolume
wAncH_V  += effVolume
wAncL_SV += vwapSrcVal * effVolume
wAncL_V  += effVolume
mAncH_SV += vwapSrcVal * effVolume
mAncH_V  += effVolume
mAncL_SV += vwapSrcVal * effVolume
mAncL_V  += effVolume

float vDH = dAncH_V > 0 ? dAncH_SV / dAncH_V : na
float vDL = dAncL_V > 0 ? dAncL_SV / dAncL_V : na
float vWH = wAncH_V > 0 ? wAncH_SV / wAncH_V : na
float vWL = wAncL_V > 0 ? wAncL_SV / wAncL_V : na
float vMH = mAncH_V > 0 ? mAncH_SV / mAncH_V : na
float vML = mAncL_V > 0 ? mAncL_SV / mAncL_V : na

bool ancDWM_active = showVwapMaster and ancDWM_show
bool doH = ancDWM_mode == 'High' or ancDWM_mode == 'Ambos'
bool doL = ancDWM_mode == 'Low'  or ancDWM_mode == 'Ambos'

bool aDH_on = ancDWM_active and ancD_show and doH
bool aDL_on = ancDWM_active and ancD_show and doL
bool aWH_on = ancDWM_active and ancW_show and doH
bool aWL_on = ancDWM_active and ancW_show and doL
bool aMH_on = ancDWM_active and ancM_show and doH
bool aML_on = ancDWM_active and ancM_show and doL

// ─── VWAP Anclado personalizado (Swing / Manual Date) ───
isNewAncC = switch ancC_mode
    "Auto Swing High" => not na(ta.pivothigh(ancC_swingLen, ancC_swingLen))
    "Auto Swing Low"  => not na(ta.pivotlow(ancC_swingLen, ancC_swingLen))
    "Manual Date"      => (time >= ancC_manualTime and time[1] < ancC_manualTime)
    => false

[vwapAncC, sdAncC] = vwapCalcFull(vwapSrcVal, isNewAncC)
bool onAncC = showVwapMaster and ancC_show

// ============================================================
// PLOTS — VWAP ESTÁNDAR (5 slots)
// ============================================================
bool onS1  = showVwapMaster and vwapS1_show
bool onS2  = showVwapMaster and vwapS2_show
bool onS3  = showVwapMaster and vwapS3_show
bool onS4  = showVwapMaster and vwapS4_show
bool onS5  = showVwapMaster and vwapS5_show

plot(onS1  ? vwap1   : na, "VWAP Slot 1",    color=vwapS1_color, linewidth=vwapS1_width, style=getPlotStyle(vwapS1_style))
plot(onS2  ? vwap2   : na, "VWAP Slot 2",    color=vwapS2_color, linewidth=vwapS2_width, style=getPlotStyle(vwapS2_style))
plot(onS3  ? vwap3   : na, "VWAP Slot 3",    color=vwapS3_color, linewidth=vwapS3_width, style=getPlotStyle(vwapS3_style))
plot(onS4  ? vwap4   : na, "VWAP Slot 4",    color=vwapS4_color, linewidth=vwapS4_width, style=getPlotStyle(vwapS4_style))
plot(onS5  ? vwap5   : na, "VWAP Slot 5",    color=vwapS5_color, linewidth=vwapS5_width, style=getPlotStyle(vwapS5_style))

// VWAP Closes — nivel horizontal fijo al cerrar cada sesión de cada slot
if showVwapMaster and vwapS1_showClose and isNewS1 and not na(vwap1[1])
    line.new(bar_index-1, vwap1[1], bar_index-1+vwapCloseExtBars, vwap1[1], color=vwapS1_closeColor, width=vwapS1_closeWidth, style=line.style_solid)
if showVwapMaster and vwapS2_showClose and isNewS2 and not na(vwap2[1])
    line.new(bar_index-1, vwap2[1], bar_index-1+vwapCloseExtBars, vwap2[1], color=vwapS2_closeColor, width=vwapS2_closeWidth, style=line.style_solid)
if showVwapMaster and vwapS3_showClose and isNewS3 and not na(vwap3[1])
    line.new(bar_index-1, vwap3[1], bar_index-1+vwapCloseExtBars, vwap3[1], color=vwapS3_closeColor, width=vwapS3_closeWidth, style=line.style_solid)
if showVwapMaster and vwapS4_showClose and isNewS4 and not na(vwap4[1])
    line.new(bar_index-1, vwap4[1], bar_index-1+vwapCloseExtBars, vwap4[1], color=vwapS4_closeColor, width=vwapS4_closeWidth, style=line.style_solid)
if showVwapMaster and vwapS5_showClose and isNewS5 and not na(vwap5[1])
    line.new(bar_index-1, vwap5[1], bar_index-1+vwapCloseExtBars, vwap5[1], color=vwapS5_closeColor, width=vwapS5_closeWidth, style=line.style_solid)

// ============================================================
// PLOTS — VWAP ANCLADO A EXTREMOS DE PERÍODO (D/W/M)
// ============================================================
plot(aDH_on ? vDH : na, "VWAP DH", color=ancD_colorH, linewidth=ancD_width, style=getPlotStyle(ancD_style))
plot(aDL_on ? vDL : na, "VWAP DL", color=ancD_colorL, linewidth=ancD_width, style=getPlotStyle(ancD_style))
plot(aWH_on ? vWH : na, "VWAP WH", color=ancW_colorH, linewidth=ancW_width, style=getPlotStyle(ancW_style))
plot(aWL_on ? vWL : na, "VWAP WL", color=ancW_colorL, linewidth=ancW_width, style=getPlotStyle(ancW_style))
plot(aMH_on ? vMH : na, "VWAP MH", color=ancM_colorH, linewidth=ancM_width, style=getPlotStyle(ancM_style))
plot(aML_on ? vML : na, "VWAP ML", color=ancM_colorL, linewidth=ancM_width, style=getPlotStyle(ancM_style))

// ============================================================
// PLOT — VWAP ANCLADO PERSONALIZADO
// ============================================================
plot(onAncC ? vwapAncC : na, "VWAP Custom Anchored", color=ancC_color, linewidth=ancC_width, style=getPlotStyle(ancC_style))

// ============================================================
// BANDAS DE DESVIACIÓN ESTÁNDAR
// ============================================================
getBandSourceVals() =>
    switch bandsSource
        "Slot 1"                => [vwap1, sd1]
        "Slot 2"                => [vwap2, sd2]
        "Slot 3"                => [vwap3, sd3]
        "Slot 4"                => [vwap4, sd4]
        "Slot 5"                => [vwap5, sd5]
        "Daily High Anchor"     => [vDH, na]
        "Daily Low Anchor"      => [vDL, na]
        "Weekly High Anchor"    => [vWH, na]
        "Weekly Low Anchor"     => [vWL, na]
        "Monthly High Anchor"   => [vMH, na]
        "Monthly Low Anchor"    => [vML, na]
        "Custom Anchor"         => [vwapAncC, sdAncC]
        => [vwap1, sd1]

[bandBaseVwap, bandBaseSd] = getBandSourceVals()
bandsActive = showVwapMaster and bandsShow and not na(bandBaseSd)

up1 = bandBaseVwap + nz(bandBaseSd) * band1Mult
dn1 = bandBaseVwap - nz(bandBaseSd) * band1Mult
up2 = bandBaseVwap + nz(bandBaseSd) * band2Mult
dn2 = bandBaseVwap - nz(bandBaseSd) * band2Mult

pUp1 = plot(bandsActive and band1Show ? up1 : na, "Band #1 Upper", color=band1UpColor, linewidth=band1Width)
pDn1 = plot(bandsActive and band1Show ? dn1 : na, "Band #1 Lower", color=band1DnColor, linewidth=band1Width)
fill(pUp1, pDn1, color=(bandsActive and band1Show) ? band1FillColor : na, title="Band #1 Fill")

pUp2 = plot(bandsActive and band2Show ? up2 : na, "Band #2 Upper", color=band2UpColor, linewidth=band2Width)
pDn2 = plot(bandsActive and band2Show ? dn2 : na, "Band #2 Lower", color=band2DnColor, linewidth=band2Width)
fill(pUp2, pDn2, color=(bandsActive and band2Show) ? band2FillColor : na, title="Band #2 Fill")

// ============================================================
// LIVE PANEL
// ============================================================
getPanelPos(p) =>
    switch p
        'Top Right'    => position.top_right
        'Top Left'     => position.top_left
        'Bottom Right' => position.bottom_right
        'Bottom Left'  => position.bottom_left
        => position.top_right

if showPanel and barstate.islast
    if not na(infoPanel)
        table.delete(infoPanel)

    vwapPanelActive = vwapInPanel and showVwapMaster
    slotRows  = vwapPanelActive ? ((onS1?1:0)+(onS2?1:0)+(onS3?1:0)+(onS4?1:0)+(onS5?1:0)) : 0
    ancDWMRows = (ancDWM_inPanel and ancDWM_active) ? ((aDH_on?1:0)+(aDL_on?1:0)+(aWH_on?1:0)+(aWL_on?1:0)+(aMH_on?1:0)+(aML_on?1:0)) : 0
    ancCRow    = (vwapPanelActive and onAncC) ? 1 : 0

    nRows = 1 + (showTickerPanel ? 1 : 0) + slotRows + ancDWMRows + ancCRow
    nRows := math.max(nRows, 2)

    infoPanel := table.new(getPanelPos(panelPos), 2, nRows, bgcolor=panelBgColor, border_width=1, border_color=color.gray)
    table.cell(infoPanel, 0, 0, "MOYA VWAP Suite", text_color=panelTextColor, bgcolor=color.rgb(244,63,94,0), text_size=size.small)
    table.cell(infoPanel, 1, 0, vwapSrcType,        text_color=panelTextColor, bgcolor=color.rgb(244,63,94,0), text_size=size.small)

    int rowPtr = 1

    if showTickerPanel
        string srcText  = "Native"
        color  srcColor = panelTextColor
        if useExternalVol
            hasData = not na(externalVolume)
            modeTag = usingAutoNow ? " (auto)" : " (manual)"
            srcText  := (na(resolvedExtSymbol) ? "NO MATCH" : resolvedExtSymbol) + modeTag
            srcColor := hasData ? color.rgb(0,191,165) : color.rgb(244,63,94)
        table.cell(infoPanel, 0, rowPtr, "Vol. Source",  text_color=panelTextColor, text_size=size.small)
        table.cell(infoPanel, 1, rowPtr, srcText,        text_color=srcColor,       text_size=size.small)
        rowPtr += 1

    if vwapPanelActive
        if onS1
            table.cell(infoPanel, 0, rowPtr, "VWAP " + vwapS1_type, text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vwap1, format.mintick), text_color=vwapS1_color, text_size=size.small)
            rowPtr += 1
        if onS2
            table.cell(infoPanel, 0, rowPtr, "VWAP " + vwapS2_type, text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vwap2, format.mintick), text_color=vwapS2_color, text_size=size.small)
            rowPtr += 1
        if onS3
            table.cell(infoPanel, 0, rowPtr, "VWAP " + vwapS3_type, text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vwap3, format.mintick), text_color=vwapS3_color, text_size=size.small)
            rowPtr += 1
        if onS4
            table.cell(infoPanel, 0, rowPtr, "VWAP " + vwapS4_type, text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vwap4, format.mintick), text_color=vwapS4_color, text_size=size.small)
            rowPtr += 1
        if onS5
            table.cell(infoPanel, 0, rowPtr, "VWAP " + vwapS5_type, text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vwap5, format.mintick), text_color=vwapS5_color, text_size=size.small)
            rowPtr += 1

    if ancDWM_inPanel and ancDWM_active
        if aDH_on
            table.cell(infoPanel, 0, rowPtr, "VWAP DH", text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vDH, format.mintick), text_color=ancD_colorH, text_size=size.small)
            rowPtr += 1
        if aDL_on
            table.cell(infoPanel, 0, rowPtr, "VWAP DL", text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vDL, format.mintick), text_color=ancD_colorL, text_size=size.small)
            rowPtr += 1
        if aWH_on
            table.cell(infoPanel, 0, rowPtr, "VWAP WH", text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vWH, format.mintick), text_color=ancW_colorH, text_size=size.small)
            rowPtr += 1
        if aWL_on
            table.cell(infoPanel, 0, rowPtr, "VWAP WL", text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vWL, format.mintick), text_color=ancW_colorL, text_size=size.small)
            rowPtr += 1
        if aMH_on
            table.cell(infoPanel, 0, rowPtr, "VWAP MH", text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vMH, format.mintick), text_color=ancM_colorH, text_size=size.small)
            rowPtr += 1
        if aML_on
            table.cell(infoPanel, 0, rowPtr, "VWAP ML", text_color=panelTextColor, text_size=size.small)
            table.cell(infoPanel, 1, rowPtr, str.tostring(vML, format.mintick), text_color=ancM_colorL, text_size=size.small)
            rowPtr += 1

    if vwapPanelActive and onAncC
        table.cell(infoPanel, 0, rowPtr, "VWAP Custom Anc.", text_color=panelTextColor, text_size=size.small)
        table.cell(infoPanel, 1, rowPtr, str.tostring(vwapAncC, format.mintick), text_color=ancC_color, text_size=size.small)
        rowPtr += 1
````
