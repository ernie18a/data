# VWAP Zone CVD Table [v6]

- url: https://www.tradingview.com/script/pWPG8PUC-VWAP-Zone-CVD-Table-v6/
- type: indicator
- pine_id: PUB;b98ae5a2bf374851975f66b03bdf3223
- version: 1.0

## Description

VWAP Zone CVD Table [v6]
Overview
The VWAP Zone CVD Table [v6] is a professional-grade institutional analysis tool designed to bridge the gap between price action and order flow. By combining Volume Weighted Average Price (VWAP) Standard Deviation bands with real-time Cumulative Volume Delta (CVD), this indicator identifies where institutional supply and demand are actively fighting for control.

Unlike standard VWAP indicators that only show price levels, this script analyzes the net buying and selling pressure (CVD %) specifically within each volatility-adjusted zone, providing a high-conviction view of market sentiment at key technical levels.

🚀 Key Features
Multi-Zone VWAP Architecture: Features a central VWAP line and two customizable Standard Deviation (SD) bands (SD1 and SD2).
Volatility-Adjusted "Zones": Each band is wrapped in an ATR-based zone, creating a "catchment area" for price action rather than a single thin line, reflecting more realistic market behavior.
Real-Time CVD Table: A sleek, non-intrusive dashboard that displays:
Zone Sentiment: Bullish, Bearish, or Neutral based on cumulative delta.
Volume Intensity: Percentage of net buying/selling power within that specific band.
Active Tracking: A live tracking column (◉) that highlights exactly which zone price is currently occupying.
Multi-Timeframe (MTF) Support: Flexible anchor settings (Session, Week, Month) and an "Auto" CVD timeframe selector that optimizes data granularity based on your chart.
Volume Filtering: Includes a minimum volume threshold to filter out "noise" and focus only on high-conviction institutional moves.
💡 How to Use
Identify Institutional Value: The central VWAP zone represents the "fair value." Use the SD1 and SD2 bands to identify overextended (Premium) or undervalued (Discount) zones.
Confirm Rejections: When price enters the SD2 Upper Zone, look at the CVD Table. If the signal is "Bearish %", it confirms that sellers are aggressively defending that level, increasing the probability of a mean-reversion trade.
Trend Continuation: In a strong trend, price often bounces off the VWAP or SD1 Lower Zone. A "Bullish %" signal in these zones during a pullback provides a high-probability entry for trend continuation.
Spot Absorption: If price is stuck in a zone but the CVD % is extremely high (e.g., 75% Bullish) yet price isn't moving up, it indicates Absorption—a sign that a major breakout or reversal is imminent.
🎨 Visual Elements
Dynamic Fills: Volatility-adjusted zones are shaded for easy visual identification of supply/demand areas.
Color-Coded Sentiment: The table and zones use professional color palettes (Cyan for Bullish, Crimson for Bearish, Slate for Neutral).
Clean UI: Designed to work as an overlay without cluttering your price action analysis.
🛠 Settings & Customization
Anchor Period: Toggle between Session, Weekly, or Monthly VWAP.
Zone Widths: Fully adjustable ATR multipliers to fit different asset classes (Forex, Crypto, or Stocks).
Neutral Threshold: Customize what percentage of delta constitutes a "Bullish" vs "Neutral" signal (Default: 55%).
Table Position: Move the dashboard to any corner of your chart to suit your layout.
Disclaimer: Trading involves significant risk. This tool is designed for educational and analytical purposes and should be used in conjunction with a complete trading plan.[image]https://www.tradingview.com/x/2wB5ph8a/[/image]

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// █▀ █▀▀ █▀▀ ▀█▀ █ █▀█ █▄░█   █░█ █░█░█ ▄▀█ █▀█   ▀█ █▀█ █▄░█ █▀▀   █▀▀ █░█ █▀▄
// ▄█ ██▄ █▄▄ ░█░ █ █▄█ █░▀█   ▀▄▀ ▀▄▀▄▀ █▀█ █▀▀   █▄ █▄█ █░▀█ ██▄   █▄▄ ▀▄▀ █▄▀
// ═══════════════════════════════════════════════════════════════
//
// Title:       VWAP Zone CVD Table [v6]
// Short Title: VWAP·CVD·TBL
// Description: This professional-grade indicator combines Volume Weighted Average Price (VWAP) 
//              Standard Deviation bands with Cumulative Volume Delta (CVD) analysis. 
//              It identifies institutional supply and demand zones by calculating the net 
//              buying/selling pressure (CVD %) specifically within each VWAP and SD band.
//
// HOW TO USE:
// 1. VWAP Zones: The central VWAP and its SD1/SD2 bands act as dynamic support and resistance.
// 2. CVD Table: Monitor the table to see real-time volume delta percentages for price levels 
//    currently being traded.
// 3. Signals:
//    - Bullish %: High buying pressure in a zone.
//    - Bearish %: High selling pressure in a zone.
//    - Neutral: Balanced volume delta.
// 4. Active Indicator: The "Active" column shows which specific band price is currently 
//    occupying.
//
// Author:      Pine Script Expert
// Version:     6.0
// ═══════════════════════════════════════════════════════════════

indicator(title="VWAP Zone CVD Table [v6]", shorttitle="VWAP·CVD·TBL", overlay=true, max_lines_count=500, max_labels_count=100)

// ═══════════════════════════════════════════════════════════════
// ─── INPUTS ───
// ═══════════════════════════════════════════════════════════════

// --- VWAP Settings ---
grpVWAP     = "VWAP Configuration"
vwapAnchor  = input.string("Session", "Anchor Period", options=["Session","Week","Month"], group=grpVWAP, tooltip="Select the period for VWAP calculation reset.")
showVWAP    = input.bool(true,  "Show VWAP Line",      group=grpVWAP, tooltip="Toggle the central VWAP line.")
showVBand   = input.bool(true,  "Show VWAP ATR Band",  group=grpVWAP, tooltip="Toggle the ATR-based 'Zone' around the VWAP line.")
vBandMult   = input.float(1.0,  "VWAP ATR Multiplier", step=0.1, group=grpVWAP, tooltip="Width of the VWAP zone based on ATR.")
colVWAP     = input.color(color.rgb(0, 229, 255), "VWAP Colour", group=grpVWAP)
vLineTransp = input.int(40, "VWAP Line Opacity", minval=0, maxval=99, group=grpVWAP)
vGrayTransp = input.int(60, "VWAP Gray Opacity", minval=0, maxval=99, group=grpVWAP)
vFillTransp = input.int(92, "VWAP Fill Opacity", minval=0, maxval=99, group=grpVWAP)
showVFill   = input.bool(true, "Show VWAP Band Fill", group=grpVWAP)

// --- SD1 Settings ---
grpSD1       = "Standard Deviation Zone 1"
showSD1      = input.bool(true,  "Show SD1 Lines",          group=grpSD1, tooltip="Toggle the first Standard Deviation lines.")
showSD1Band  = input.bool(true,  "Show SD1 ATR Band",       group=grpSD1, tooltip="Toggle the ATR-based 'Zone' around SD1.")
sd1SDMult    = input.float(1.0,  "SD1 Std Dev Multiplier",  step=0.5, minval=0.5, group=grpSD1, tooltip="Multiplier for the first Standard Deviation.")
sd1ATRMult   = input.float(1.0,  "SD1 ATR Multiplier",      step=0.1, group=grpSD1, tooltip="Width of the SD1 zone.")
colSD1       = input.color(color.rgb(0, 200, 220), "SD1 Colour",        group=grpSD1)
s1LineTransp = input.int(50, "SD1 Line Opacity", minval=0, maxval=99, group=grpSD1)
s1FillTransp = input.int(93, "SD1 Fill Opacity", minval=0, maxval=99, group=grpSD1)
showSD1Fill  = input.bool(true, "Show SD1 Band Fill", group=grpSD1)

// --- SD2 Settings ---
grpSD2       = "Standard Deviation Zone 2"
showSD2      = input.bool(true,  "Show SD2 Lines",          group=grpSD2, tooltip="Toggle the second Standard Deviation lines.")
showSD2Band  = input.bool(true,  "Show SD2 ATR Band",       group=grpSD2, tooltip="Toggle the ATR-based 'Zone' around SD2.")
sd2SDMult    = input.float(2.0,  "SD2 Std Dev Multiplier",  step=0.5, minval=0.5, group=grpSD2, tooltip="Multiplier for the second Standard Deviation.")
sd2ATRMult   = input.float(0.75, "SD2 ATR Multiplier",      step=0.1, group=grpSD2, tooltip="Width of the SD2 zone.")
colSD2       = input.color(color.rgb(0, 170, 200), "SD2 Colour",        group=grpSD2)
s2LineTransp = input.int(55, "SD2 Line Opacity", minval=0, maxval=99, group=grpSD2)
s2FillTransp = input.int(94, "SD2 Fill Opacity", minval=0, maxval=99, group=grpSD2)
showSD2Fill  = input.bool(true, "Show SD2 Band Fill", group=grpSD2)

// --- ATR Settings ---
grpATR    = "Volatility (ATR)"
atrPeriod = input.int(14, "ATR Period", minval=1, group=grpATR, tooltip="Period used for ATR-based zone widths.")

// --- CVD Settings ---
grpCVD     = "Cumulative Volume Delta (CVD)"
cvdReset   = input.bool(true, "Reset CVD Each Session", group=grpCVD, tooltip="Reset the CVD calculations at the start of each trading day.")
cvdTF      = input.string("5", "CVD Timeframe", options=["Auto","1","2","3","5","10","15","30","60"], group=grpCVD, tooltip="Timeframe used for Delta calculation. 'Auto' selects based on chart timeframe.")
minVol     = input.int(0, "Minimum Volume Threshold", minval=0, group=grpCVD, tooltip="Ignore bars with volume below this value in CVD calculations.")
neutThresh = input.float(55.0, "Neutral Threshold %", minval=50.0, maxval=75.0, step=1.0, group=grpCVD, tooltip="Percentage threshold for Bullish/Bearish classification. Below this is Neutral.")

// --- Table Settings ---
grpTable  = "Interface (Table)"
tblPos    = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpTable)
tblSize   = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large"], group=grpTable)

// ═══════════════════════════════════════════════════════════════
// ─── CALCULATIONS ───
// ═══════════════════════════════════════════════════════════════

// --- VWAP Logic ---
isNewAnchor() =>
    switch vwapAnchor
        "Session" => timeframe.change("D")
        "Week"    => timeframe.change("W")
        "Month"   => timeframe.change("M")
        =>           timeframe.change("D")

var float cumVP  = 0.0
var float cumVPH = 0.0
var float cumVPL = 0.0
var float cumV   = 0.0
var float cumVP2 = 0.0

if isNewAnchor() or barstate.isfirst
    cumVP  := 0.0
    cumVPH := 0.0
    cumVPL := 0.0
    cumV   := 0.0
    cumVP2 := 0.0

hlc3Val  = (high + low + close) / 3
cumVP   += hlc3Val * volume
cumVPH  += high    * volume
cumVPL  += low     * volume
cumV    += volume
cumVP2  += hlc3Val * hlc3Val * volume

vwapMid  = cumVP  / cumV
vwapHigh = cumVPH / cumV
vwapLow  = cumVPL / cumV

variance = math.max(cumVP2 / cumV - vwapMid * vwapMid, 0.0)
vwapStd  = math.sqrt(variance)

sd1U = vwapMid + sd1SDMult * vwapStd
sd1L = vwapMid - sd1SDMult * vwapStd
sd2U = vwapMid + sd2SDMult * vwapStd
sd2L = vwapMid - sd2SDMult * vwapStd

// --- ATR Zones ---
atrVal = ta.atr(atrPeriod)

vBandU    = vwapMid + vBandMult  * atrVal
vBandL    = vwapMid - vBandMult  * atrVal

sd1BandUU = sd1U + sd1ATRMult * atrVal
sd1BandUL = sd1U - sd1ATRMult * atrVal
sd1BandLU = sd1L + sd1ATRMult * atrVal
sd1BandLL = sd1L - sd1ATRMult * atrVal

sd2BandUU = sd2U + sd2ATRMult * atrVal
sd2BandUL = sd2U - sd2ATRMult * atrVal
sd2BandLU = sd2L + sd2ATRMult * atrVal
sd2BandLL = sd2L - sd2ATRMult * atrVal

// --- CVD Timeframe Selection ---
autoTF = timeframe.isintraday ? 
     (timeframe.multiplier <= 1 ? "5" : 
      timeframe.multiplier <= 5 ? "15" : 
      timeframe.multiplier <= 15 ? "60" : 
      timeframe.multiplier <= 60 ? "240" : "D") : "D"

finalTF = cvdTF == "Auto" ? autoTF : cvdTF

// --- CVD Data Fetch ---
[rawDelta, rawVol, newDayCVD] = request.security(syminfo.tickerid, finalTF,
     [volume * ((close - low) - (high - close)) / math.max(high - low, 0.0001),
      volume,
      timeframe.change("D")], 
     lookahead=barmerge.lookahead_off)

delta = nz(rawDelta, 0.0)
volTF = nz(rawVol,   0.0)

// ═══════════════════════════════════════════════════════════════
// ─── ZONE ANALYSIS (CVD %) ───
// ═══════════════════════════════════════════════════════════════

inBand(upper, lower) => close >= lower and close <= upper and volume >= minVol

var float vBuyVol    = 0.0
var float vSellVol   = 0.0
var float s1uBuyVol  = 0.0
var float s1uSellVol = 0.0
var float s1lBuyVol  = 0.0
var float s1lSellVol = 0.0
var float s2uBuyVol  = 0.0
var float s2uSellVol = 0.0
var float s2lBuyVol  = 0.0
var float s2lSellVol = 0.0

// Reset Accumulators
if cvdReset and (isNewAnchor() or newDayCVD)
    vBuyVol := 0.0, vSellVol := 0.0
    s1uBuyVol := 0.0, s1uSellVol := 0.0
    s1lBuyVol := 0.0, s1lSellVol := 0.0
    s2uBuyVol := 0.0, s2uSellVol := 0.0
    s2lBuyVol := 0.0, s2lSellVol := 0.0

// Accumulate Delta based on Price Zone
if inBand(vBandU, vBandL)
    if delta > 0
        vBuyVol  += volTF
    else if delta < 0
        vSellVol += volTF

if inBand(sd1BandUU, sd1BandUL)
    if delta > 0
        s1uBuyVol  += volTF
    else if delta < 0
        s1uSellVol += volTF

if inBand(sd1BandLU, sd1BandLL)
    if delta > 0
        s1lBuyVol  += volTF
    else if delta < 0
        s1lSellVol += volTF

if inBand(sd2BandUU, sd2BandUL)
    if delta > 0
        s2uBuyVol  += volTF
    else if delta < 0
        s2uSellVol += volTF

if inBand(sd2BandLU, sd2BandLL)
    if delta > 0
        s2lBuyVol  += volTF
    else if delta < 0
        s2lSellVol += volTF

// Percentage Calculation Helper
calcPct(buyV, sellV) =>
    total = buyV + sellV
    total > 0 ? (buyV / total) * 100.0 : 50.0

vPct   = calcPct(vBuyVol,   vSellVol)
s1uPct = calcPct(s1uBuyVol, s1uSellVol)
s1lPct = calcPct(s1lBuyVol, s1lSellVol)
s2uPct = calcPct(s2uBuyVol, s2uSellVol)
s2lPct = calcPct(s2lBuyVol, s2lSellVol)

// ═══════════════════════════════════════════════════════════════
// ─── VISUALS & TABLE ───
// ═══════════════════════════════════════════════════════════════

// --- Signal Logic ---
signal(pct) =>
    if pct >= neutThresh
        ["Bullish  " + str.tostring(math.round(pct)) + "%", color.rgb(0, 229, 255)]
    else if pct <= (100 - neutThresh)
        ["Bearish  " + str.tostring(math.round(100 - pct)) + "%", color.rgb(255, 23, 68)]
    else
        ["Neutral", color.rgb(120, 144, 156)]

[vTxt,   vCol]   = signal(vPct)
[s1uTxt, s1uCol] = signal(s1uPct)
[s1lTxt, s1lCol] = signal(s1lPct)
[s2uTxt, s2uCol] = signal(s2uPct)
[s2lTxt, s2lCol] = signal(s2lPct)

vActive   = inBand(vBandU,    vBandL)
s1uActive = inBand(sd1BandUU, sd1BandUL)
s1lActive = inBand(sd1BandLU, sd1BandLL)
s2uActive = inBand(sd2BandUU, sd2BandUL)
s2lActive = inBand(sd2BandLU, sd2BandLL)

// --- Table UI ---
tPos = switch tblPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

tSz = switch tblSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.small

var table tbl = table.new(tPos, 3, 7, bgcolor=color.rgb(10, 10, 20, 15), border_color=color.rgb(60, 60, 80), border_width=1, frame_color=color.rgb(60, 60, 80), frame_width=1)

if barstate.islast
    table.cell(tbl, 0, 0, "Zone",   text_color=color.rgb(180,180,180), text_size=tSz, bgcolor=color.rgb(20,20,35))
    table.cell(tbl, 1, 0, "Signal", text_color=color.rgb(180,180,180), text_size=tSz, bgcolor=color.rgb(20,20,35))
    table.cell(tbl, 2, 0, "Active", text_color=color.rgb(180,180,180), text_size=tSz, bgcolor=color.rgb(20,20,35))

    table.cell(tbl, 0, 1, "VWAP",                              text_color=color.white, text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 1, 1, vTxt,                                text_color=vCol,        text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 2, 1, vActive   ? "◉" : "○",               text_color=vActive   ? vCol   : color.rgb(80,80,80), text_size=tSz, bgcolor=color.rgb(15,15,30))

    table.cell(tbl, 0, 2, str.tostring(sd1SDMult) + "σ Upper", text_color=color.white, text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 1, 2, s1uTxt,                              text_color=s1uCol,      text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 2, 2, s1uActive ? "◉" : "○",               text_color=s1uActive ? s1uCol : color.rgb(80,80,80), text_size=tSz, bgcolor=color.rgb(15,15,30))

    table.cell(tbl, 0, 3, str.tostring(sd1SDMult) + "σ Lower", text_color=color.white, text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 1, 3, s1lTxt,                              text_color=s1lCol,      text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 2, 3, s1lActive ? "◉" : "○",               text_color=s1lActive ? s1lCol : color.rgb(80,80,80), text_size=tSz, bgcolor=color.rgb(15,15,30))

    table.cell(tbl, 0, 4, str.tostring(sd2SDMult) + "σ Upper", text_color=color.white, text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 1, 4, s2uTxt,                              text_color=s2uCol,      text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 2, 4, s2uActive ? "◉" : "○",               text_color=s2uActive ? s2uCol : color.rgb(80,80,80), text_size=tSz, bgcolor=color.rgb(15,15,30))

    table.cell(tbl, 0, 5, str.tostring(sd2SDMult) + "σ Lower", text_color=color.white, text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 1, 5, s2lTxt,                              text_color=s2lCol,      text_size=tSz, bgcolor=color.rgb(15,15,30))
    table.cell(tbl, 2, 5, s2lActive ? "◉" : "○",               text_color=s2lActive ? s2lCol : color.rgb(80,80,80), text_size=tSz, bgcolor=color.rgb(15,15,30))

    table.cell(tbl, 0, 6, "CVD: " + finalTF + "m TF",          text_color=color.rgb(80,80,80), text_size=size.tiny, bgcolor=color.rgb(10,10,20))
    table.cell(tbl, 1, 6, "",                                  text_color=color.rgb(80,80,80), text_size=size.tiny, bgcolor=color.rgb(10,10,20))
    table.cell(tbl, 2, 6, "",                                  text_color=color.rgb(80,80,80), text_size=size.tiny, bgcolor=color.rgb(10,10,20))

// --- Colour Management ---
cV    = color.new(colVWAP, vLineTransp)
cV2   = color.new(colVWAP, vFillTransp)
cS1   = color.new(colSD1,  s1LineTransp)
cS1f  = color.new(colSD1,  s1FillTransp)
cS2   = color.new(colSD2,  s2LineTransp)
cS2f  = color.new(colSD2,  s2FillTransp)
cGrey = color.new(color.rgb(120, 144, 156), vGrayTransp)

// ═══════════════════════════════════════════════════════════════
// ─── PLOTS ───
// ═══════════════════════════════════════════════════════════════

// --- VWAP Plots ---
plot(showVWAP ? vwapMid  : na, "VWAP",      color=cV,    linewidth=2)
plot(showVWAP ? vwapHigh : na, "VWAP High", color=cGrey, linewidth=1)
plot(showVWAP ? vwapLow  : na, "VWAP Low",  color=cGrey, linewidth=1)

pVU = plot(showVBand ? vBandU : na, "VWAP Band U", color=cV, linewidth=1)
pVL = plot(showVBand ? vBandL : na, "VWAP Band L", color=cV, linewidth=1)
fill(pVU, pVL, color=showVFill ? cV2 : na, title="VWAP Fill")

// --- SD1 Plots ---
plot(showSD1 ? sd1U : na, "SD1 Upper", color=cS1, linewidth=2)
plot(showSD1 ? sd1L : na, "SD1 Lower", color=cS1, linewidth=2)
pS1UU = plot(showSD1Band ? sd1BandUU : na, "SD1U Top", color=cS1, linewidth=1)
pS1UL = plot(showSD1Band ? sd1BandUL : na, "SD1U Bot", color=cS1, linewidth=1)
fill(pS1UU, pS1UL, color=showSD1Fill ? cS1f : na, title="SD1 Upper Fill")
pS1LU = plot(showSD1Band ? sd1BandLU : na, "SD1L Top", color=cS1, linewidth=1)
pS1LL = plot(showSD1Band ? sd1BandLL : na, "SD1L Bot", color=cS1, linewidth=1)
fill(pS1LU, pS1LL, color=showSD1Fill ? cS1f : na, title="SD1 Lower Fill")

// --- SD2 Plots ---
plot(showSD2 ? sd2U : na, "SD2 Upper", color=cS2, linewidth=2)
plot(showSD2 ? sd2L : na, "SD2 Lower", color=cS2, linewidth=2)
pS2UU = plot(showSD2Band ? sd2BandUU : na, "SD2U Top", color=cS2, linewidth=1)
pS2UL = plot(showSD2Band ? sd2BandUL : na, "SD2U Bot", color=cS2, linewidth=1)
fill(pS2UU, pS2UL, color=showSD2Fill ? cS2f : na, title="SD2 Upper Fill")
pS2LU = plot(showSD2Band ? sd2BandLU : na, "SD2L Top", color=cS2, linewidth=1)
pS2LL = plot(showSD2Band ? sd2BandLL : na, "SD2L Bot", color=cS2, linewidth=1)
fill(pS2LU, pS2LL, color=showSD2Fill ? cS2f : na, title="SD2 Lower Fill")

// ═══════════════════════════════════════════════════════════════
// ─── ALERTS ───
// ═══════════════════════════════════════════════════════════════
alertcondition(inBand(vBandU, vBandL)       and vPct   >= neutThresh,       "VWAP Zone Bullish",  "Bullish pressure in VWAP zone")
alertcondition(inBand(vBandU, vBandL)       and vPct   <= (100-neutThresh), "VWAP Zone Bearish",  "Bearish pressure in VWAP zone")
alertcondition(inBand(sd1BandUU, sd1BandUL) and s1uPct <= (100-neutThresh), "SD1 Upper Bearish",  "Selling at SD1 upper — potential rejection")
alertcondition(inBand(sd1BandLU, sd1BandLL) and s1lPct >= neutThresh,       "SD1 Lower Bullish",  "Buying at SD1 lower — potential support")
alertcondition(inBand(sd2BandUU, sd2BandUL) and s2uPct <= (100-neutThresh), "SD2 Upper Bearish",  "Selling at SD2 upper — extreme rejection")
alertcondition(inBand(sd2BandLU, sd2BandLL) and s2lPct >= neutThresh,       "SD2 Lower Bullish",  "Buying at SD2 lower — extreme support")
````
