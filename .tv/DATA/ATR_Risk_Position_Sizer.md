<!-- tradingview-pine-id: PUB;5385a731d47e4bb18c43ff4bcd3699c7 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Risk & Position Sizer

Source: https://www.tradingview.com/script/sJMxF85z-Futures-ATR-Risk-Position-Sizer/

## Description

ATR Risk & Position Sizer

What it does

This tool answers one question before every trade: "Given how much I'm willing to lose and how volatile this market is right now, how many contracts can I actually take?"

Instead of using a fixed stop distance, the stop is derived from the Average True Range (ATR) of the instrument, so position size automatically shrinks when volatility rises and grows when it falls — the dollar risk stays constant, the contract count adapts.

The asset is auto-detected from the chart you're viewing. You only choose whether you're trading the Mini or Micro version of it.

How the calculation works

[*]Stop distance = ATR(length) × Multiplier
- ATR length defaults to 14 (configurable).
- The multiplier (default 1.5) controls how wide the stop is relative to current volatility — this is what makes the risk "dynamic": as ATR expands or contracts, so does the stop, and so does the resulting position size.
[*]Tick rounding — a stop can only be placed at a valid price increment (tick), so the raw ATR-based distance is rounded down to the nearest whole tick for the detected instrument before anything else is calculated. For example, on ES (tick = 0.25), a raw distance of 10.4 points becomes 10.25 points (41 ticks) — never a value that couldn't actually be set as a stop order.
[*]Risk per contract = Stop Distance (points) × Dollar value per point (for the selected Mini/Micro size).
[*]Contracts allowed = floor(Max Risk $ ÷ Risk per contract), then optionally rounded down to the nearest even number (see below).
[*]Max Risk (displayed) is recalculated from the final, rounded contract count — so it reflects your actual exposure, which will always be at or under your configured max risk, never over it.

Auto-detection

The script reads the chart's root symbol (works with both continuous contracts like ES1! and dated contracts like ESZ2025) and matches it — along with its known Micro ticker — against a built-in list of instruments. If the symbol isn't recognized, the table is replaced with a clear red "Unsupported Asset" warning instead of showing incorrect numbers.

If the asset is recognized but the size you selected (Mini/Micro) doesn't actually exist for that instrument (e.g. there's no Micro Platinum), you'll get an orange warning instead of silently wrong output.

Supported instruments and their specs:

Asset | Root / Micro ticker(s) | Tick Size | Mini $/pt | Micro $/pt

[*]E-mini S&P 500  |  ES / MES  |  0.25  |  $50  |  $5
[*]E-mini Nasdaq 100  |  NQ / MNQ  |  0.25  |  $20  |  $2
[*]E-mini Dow  |  YM / MYM  |  1.0  |  $5  |  $0.50
[*]E-mini Russell 2000  |  RTY / M2K  |  0.10  |  $50  |  $5
[*]Gold  |  GC / MGC (also XAUUSD, GOLD)  |  0.10  |  $100  |  $10
[*]Silver  |  SI / SIL (also XAGUSD)  |  0.005  |  $5,000  |  $1,000
[*]Platinum  |  PL  |  0.10  |  $50  |  N/A
[*]Copper  |  HG / MHG  |  0.0005  |  $25,000  |  $2,500
[*]Crude Oil  |  CL / MCL  |  0.01  |  $1,000  |  $100
[*]Natural Gas  |  NG / MNG  |  0.001  |  $10,000  |  $1,000
[*]Heating Oil  |  HO  |  0.0001  |  $42,000  |  N/A
[*]RBOB Gasoline  |  RB  |  0.0001  |  $42,000  |  N/A
[*]US Dollar Index  |  DX  |  0.005  |  $1,000  |  N/A
[*]Euro FX  |  6E / M6E  |  0.00005  |  $125,000  |  $12,500
[*]British Pound  |  6B / M6B  |  0.0001  |  $62,500  |  $6,250
[*]Australian Dollar  |  6A / M6A  |  0.0001  |  $100,000  |  $10,000
[*]30-Yr T-Bond  |  ZB  |  1/32 (0.03125)  |  $1,000  |  N/A
[*]10-Yr T-Note  |  ZN  |  1/64 (0.015625)  |  $1,000  |  N/A
[*]Wheat  |  ZW  |  0.25  |  $50  |  N/A
[*]Soybeans  |  ZS  |  0.25  |  $50  |  N/A
[*]Corn  |  ZC  |  0.25  |  $50  |  N/A
[*]Cotton  |  CT  |  0.01  |  $500  |  N/A
[*]Sugar  |  SB  |  0.01  |  $1,120  |  N/A
[*]Coffee  |  KC  |  0.05  |  $375  |  N/A
[*]Cocoa  |  CC  |  1.0  |  $10  |  N/A

"N/A" means that instrument currently has no Micro-sized version on the exchange — the script will flag this rather than show a value.

Inputs

[*]Max Risk Amount ($) – the dollar amount you're willing to risk on the trade.
[*]ATR Length – lookback period for ATR (default 14).
[*]ATR Multiplier – multiplies ATR to set the stop distance (default 1.5).
[*]Force Even Number of Contracts – when enabled (default), an odd contract count is rounded down to the nearest even number; disable to allow any whole number.
[*]Contract Type – Mini or Micro. Pick whichever you actually trade; the asset detection is independent of this.
[*]Table Position / Text Size – purely cosmetic.

Reading the table

[*]Header – detected asset, contract size, ATR multiplier in use, and your configured risk amount.
[*]Contracts Allowed – the final, tick-valid, (optionally) even-rounded contract count.
[*]Stop Loss Distance – the tick-rounded stop distance, shown in both points and whole ticks.
[*]Max Risk ($) – your actual dollar risk at that contract count — always at or below your configured max risk.

Notes & disclaimer

[*]Contract specifications (tick size, point value) reflect standard CME/ICE specs at the time of publishing. Exchanges occasionally revise these — please verify against your broker/exchange before relying on this for live sizing.
[*]This indicator does not generate entry or exit signals. It is a risk-management and position-sizing calculator only.
[*]Nothing in this script constitutes financial advice. Futures trading involves substantial risk of loss and is not suitable for all investors. Past volatility is not indicative of future volatility.

---

## Source Code

````pine
//@version=6
indicator("ATR Risk & Position Sizer", overlay=true)

// ============================================================
// INPUTS
// ============================================================
grpRisk = "Risk Settings"
riskAmount = input.float(500, "Max Risk Amount ($)", minval=1, step=50, group=grpRisk)
atrLength  = input.int(14, "ATR Length", minval=1, group=grpRisk)
atrMult    = input.float(1.5, "ATR Multiplier (Stop Distance)", minval=0.1, step=0.1, group=grpRisk,
     tooltip="Stop Loss Distance = ATR x this multiplier. This is what makes the stop (and position size) dynamic with volatility.")
baseSize   = input.int(2, "Base Size (Contract Increment)", minval=1, group=grpRisk,
     tooltip="Allowed contracts will always be a multiple of this number, rounded down to stay within your configured risk. Set to 1 to allow any whole number, 2 for even numbers only, etc.")

grpContract = "Contract Settings"
contractSel = input.string("Mini", "Contract Type", options=["Mini", "Micro"], group=grpContract,
     tooltip="The traded asset is auto-detected from the chart. This only controls which contract size (Mini/Micro) is used for the dollar-per-point value.")

grpTable = "Table Settings"
tablePos  = input.string("Top Right", "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpTable)
textSize  = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=grpTable)

// ============================================================
// ASSET AUTO-DETECTION
// ============================================================
// Root symbol is used so both dated contracts (ESZ2025) and continuous
// contracts (ES1!) resolve the same way. Falls back to the ticker if root is empty.
t = syminfo.root != "" ? syminfo.root : syminfo.ticker

detectAsset(_t) =>
    float _tick  = na
    float _mini  = na
    float _micro = na
    string _name = ""
    bool _found  = false

    if str.contains(_t, "MES") or str.contains(_t, "ES")
        _name := "ES"
        _tick := 0.25
        _mini := 50.0
        _micro := 5.0
        _found := true
    else if str.contains(_t, "MNQ") or str.contains(_t, "NQ")
        _name := "NQ"
        _tick := 0.25
        _mini := 20.0
        _micro := 2.0
        _found := true
    else if str.contains(_t, "MYM") or str.contains(_t, "YM")
        _name := "YM"
        _tick := 1.0
        _mini := 5.0
        _micro := 0.5
        _found := true
    else if str.contains(_t, "M2K") or str.contains(_t, "RTY")
        _name := "RTY"
        _tick := 0.10
        _mini := 50.0
        _micro := 5.0
        _found := true
    else if str.contains(_t, "MGC") or str.contains(_t, "GC") or str.contains(_t, "XAUUSD") or str.contains(_t, "GOLD")
        _name := "GC"
        _tick := 0.10
        _mini := 100.0
        _micro := 10.0
        _found := true
    else if str.contains(_t, "SIL") or str.contains(_t, "SI") or str.contains(_t, "XAGUSD")
        _name := "SI"
        _tick := 0.005
        _mini := 5000.0
        _micro := 1000.0
        _found := true
    else if str.contains(_t, "PL")
        _name := "PL"
        _tick := 0.10
        _mini := 50.0
        _micro := na
        _found := true
    else if str.contains(_t, "MHG") or str.contains(_t, "HG")
        _name := "HG"
        _tick := 0.0005
        _mini := 25000.0
        _micro := 2500.0
        _found := true
    else if str.contains(_t, "MCL") or str.contains(_t, "CL")
        _name := "CL"
        _tick := 0.01
        _mini := 1000.0
        _micro := 100.0
        _found := true
    else if str.contains(_t, "MNG") or str.contains(_t, "NG")
        _name := "NG"
        _tick := 0.001
        _mini := 10000.0
        _micro := 1000.0
        _found := true
    else if str.contains(_t, "HO")
        _name := "HO"
        _tick := 0.0001
        _mini := 42000.0
        _micro := na
        _found := true
    else if str.contains(_t, "RB")
        _name := "RB"
        _tick := 0.0001
        _mini := 42000.0
        _micro := na
        _found := true
    else if str.contains(_t, "DX")
        _name := "DX"
        _tick := 0.005
        _mini := 1000.0
        _micro := na
        _found := true
    else if str.contains(_t, "M6E") or str.contains(_t, "6E")
        _name := "6E"
        _tick := 0.00005
        _mini := 125000.0
        _micro := 12500.0
        _found := true
    else if str.contains(_t, "M6B") or str.contains(_t, "6B")
        _name := "6B"
        _tick := 0.0001
        _mini := 62500.0
        _micro := 6250.0
        _found := true
    else if str.contains(_t, "M6A") or str.contains(_t, "6A")
        _name := "6A"
        _tick := 0.0001
        _mini := 100000.0
        _micro := 10000.0
        _found := true
    else if str.contains(_t, "ZB")
        _name := "ZB"
        _tick := 0.03125
        _mini := 1000.0
        _micro := na
        _found := true
    else if str.contains(_t, "ZN")
        _name := "ZN"
        _tick := 0.015625
        _mini := 1000.0
        _micro := na
        _found := true
    else if str.contains(_t, "ZW")
        _name := "ZW"
        _tick := 0.25
        _mini := 50.0
        _micro := na
        _found := true
    else if str.contains(_t, "ZS")
        _name := "ZS"
        _tick := 0.25
        _mini := 50.0
        _micro := na
        _found := true
    else if str.contains(_t, "ZC")
        _name := "ZC"
        _tick := 0.25
        _mini := 50.0
        _micro := na
        _found := true
    else if str.contains(_t, "CT")
        _name := "CT"
        _tick := 0.01
        _mini := 500.0
        _micro := na
        _found := true
    else if str.contains(_t, "SB")
        _name := "SB"
        _tick := 0.01
        _mini := 1120.0
        _micro := na
        _found := true
    else if str.contains(_t, "KC")
        _name := "KC"
        _tick := 0.05
        _mini := 375.0
        _micro := na
        _found := true
    else if str.contains(_t, "CC")
        _name := "CC"
        _tick := 1.0
        _mini := 10.0
        _micro := na
        _found := true

    [_found, _name, _tick, _mini, _micro]

[assetFound, assetName, tickSize, miniPointValue, microPointValue] = detectAsset(t)

pointValue    = contractSel == "Mini" ? miniPointValue : microPointValue
sizeAvailable = not na(pointValue)

// ============================================================
// ATR-BASED STOP DISTANCE & SIZING
// ============================================================
atrVal          = ta.atr(atrLength)
stopDistanceRaw = atrVal * atrMult

// Stops can only be placed at valid tick increments, so round DOWN to the
// nearest tick multiple for this asset before using the distance anywhere.
stopTicks    = na(tickSize) ? na : math.floor(stopDistanceRaw / tickSize)
stopDistance = na(tickSize) ? stopDistanceRaw : stopTicks * tickSize

riskPerContract = sizeAvailable ? stopDistance * pointValue : na
rawContracts    = sizeAvailable and riskPerContract > 0 ? math.floor(riskAmount / riskPerContract) : na

float finalContracts = na
if not na(rawContracts)
    finalContracts := math.floor(rawContracts / baseSize) * baseSize
    finalContracts := finalContracts < 0 ? 0 : finalContracts

contractMultiple = baseSize > 0 ? finalContracts / baseSize : na

maxRiskCalc = not na(finalContracts) ? finalContracts * riskPerContract : na

// ============================================================
// TABLE
// ============================================================
getPosition(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

getSize(s) =>
    switch s
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

var table infoTable = na

if barstate.islast
    if not na(infoTable)
        table.delete(infoTable)

    txtSize = getSize(textSize)

    if not assetFound
        // ---- Unrecognized asset error ----
        infoTable := table.new(getPosition(tablePos), 1, 2,
             bgcolor=color.new(color.black, 10), border_width=1, border_color=color.red)
        table.cell(infoTable, 0, 0, "Unsupported Asset", text_color=color.white, bgcolor=color.new(color.red, 40), text_size=txtSize)
        table.cell(infoTable, 0, 1, "Ticker '" + t + "' not recognized.\nSupported: ES NQ YM RTY GC SI PL HG\nCL NG HO RB DX 6E 6B 6A ZB ZN\nZW ZS ZC CT SB KC CC",
             text_color=color.red, text_size=txtSize)
    else if not sizeAvailable
        // ---- Contract size not available for this asset ----
        infoTable := table.new(getPosition(tablePos), 1, 2,
             bgcolor=color.new(color.black, 10), border_width=1, border_color=color.orange)
        table.cell(infoTable, 0, 0, assetName + " Detected", text_color=color.white, bgcolor=color.new(color.orange, 40), text_size=txtSize)
        table.cell(infoTable, 0, 1, contractSel + " contract not available for " + assetName + ".\nPlease switch Contract Type to the size that trades.",
             text_color=color.orange, text_size=txtSize)
    else
        // ---- Normal display ----
        infoTable := table.new(getPosition(tablePos), 2, 4,
             bgcolor=color.new(color.black, 10), border_width=1,
             border_color=color.gray, frame_color=color.gray, frame_width=1)

        // Header: asset, size, ATR multiplier, defined risk amount
        headerTxt = assetName + " (" + contractSel + ") | ATR " + str.tostring(atrMult, "#.##") + "x | Risk $" + str.tostring(riskAmount, "#.##") + " | Size " + str.tostring(baseSize, "#")
        table.cell(infoTable, 0, 0, headerTxt, text_color=color.white, bgcolor=color.new(color.blue, 55), text_size=txtSize)
        table.merge_cells(infoTable, 0, 0, 1, 0)

        // Row 1: Contracts allowed
        table.cell(infoTable, 0, 1, "Contracts Allowed", text_color=color.white, text_halign=text.align_left, text_size=txtSize)
        contractsTxt = baseSize > 1 ? str.tostring(finalContracts, "#") + " (" + str.tostring(contractMultiple, "#") + "x)" : str.tostring(finalContracts, "#")
        table.cell(infoTable, 1, 1, contractsTxt,
             text_color = finalContracts > 0 ? color.yellow : color.red, text_size=txtSize)

        // Row 2: Stop loss distance
        table.cell(infoTable, 0, 2, "Stop Loss Distance", text_color=color.white, text_halign=text.align_left, text_size=txtSize)
        table.cell(infoTable, 1, 2, str.tostring(stopDistance, "#.##") + " pts / " + str.tostring(stopTicks, "#") + " ticks",
             text_color=color.white, text_size=txtSize)

        // Row 3: Max risk (actual, after rounding)
        table.cell(infoTable, 0, 3, "Max Risk ($)", text_color=color.white, text_halign=text.align_left, text_size=txtSize)
        table.cell(infoTable, 1, 3, "$" + str.tostring(maxRiskCalc, "#.##"),
             text_color = maxRiskCalc <= riskAmount ? color.lime : color.red, text_size=txtSize)
````
