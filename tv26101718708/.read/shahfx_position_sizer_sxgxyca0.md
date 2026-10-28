# ShahFX Position Sizer

- url: https://www.tradingview.com/script/SxGXYcA0-ShahFX-Position-Sizer/
- type: indicator
- pine_id: PUB;67b156f1e1bb41d883d22a4a234b4476
- version: 1.0

## Description

Description:

A risk-management tool that calculates the exact lot size needed for a trade based on your account size, risk tolerance, and current market volatility (ATR).

How it works

The script measures Average True Range (ATR) on a timeframe you choose — independent of your chart's timeframe — using a selectable smoothing method (RMA, SMA, EMA, or WMA). ATR is then multiplied by your Stop Loss and Take Profit multipliers to define your trade's stop distance in pips. Combined with your account size and risk amount, the script solves for the lot size that keeps your dollar risk exactly where you want it.

Features

Market Type selector — auto-detects pip size for Forex (including JPY pairs), Metals, Indices, and Crypto, or set a custom pip size manually
Configurable ATR — length, smoothing type, and calculation timeframe are all adjustable
SL/TP multipliers — define stop and target distance as a multiple of ATR
Flexible risk input — risk a fixed dollar amount or a percentage of account size
Custom contract size — supports standard, mini, and micro lots, or any custom unit size
Clean output only — no lines or markers drawn on the chart; results appear in a single configurable table (position, color, and text size adjustable)

Output table shows

ATR (in pips)
Stop Loss distance (in pips)
Take Profit distance (in pips)
Risk amount ($)
Required lot size
Position size (units)

How to use

Open Settings → Inputs
Select your market type and set ATR parameters to match your strategy
Enter your account size and desired risk (fixed $ or %)
Set your contract size per lot
The table updates in real time with the lot size to enter

Disclaimer

This script assumes account currency matches the pair's quote currency. For cross-currency pairs (e.g., a USD account trading EUR/GBP), lot sizing will be approximate without a currency conversion adjustment. This tool is for informational and educational purposes only and does not constitute financial advice. Always verify calculations against your broker's actual pip value and margin requirements before trading.

## Source Code

````pine
// © Parham | ATR Position Sizer
//@version=6
indicator("ATR Position Sizer", overlay=true)

// ── Market Selection ────────────────────────────────────
grpMkt = "Market Selection"
marketType = input.string("Forex Pairs", "Market Type", options=["Forex Pairs", "Metals (XAU/XAG)", "Indices", "Crypto", "Custom"], group=grpMkt)
customPip  = input.float(0.0001, "Custom Pip Size (used if Market Type = Custom)", group=grpMkt, minval=0.00000001)

// ── ATR Settings ────────────────────────────────────────
grpAtr = "ATR Settings"
atrLength    = input.int(20, "ATR Length", group=grpAtr, minval=1)
atrSmoothing = input.string("EMA", "ATR Smoothing", options=["RMA", "SMA", "EMA", "WMA"], group=grpAtr)
atrTF        = input.timeframe("5", "Timeframe for ATR", group=grpAtr)
tpMult       = input.float(1.0, "TP Multiplier", group=grpAtr, minval=0.1, step=0.1)
slMult       = input.float(1.5, "SL Multiplier", group=grpAtr, minval=0.1, step=0.1)

// ── Account & Risk ──────────────────────────────────────
grpAcc = "Account & Risk"
accountSize   = input.float(5000, "Account Size ($)", group=grpAcc, minval=0)
riskType      = input.string("Fixed $", "Risk Type", options=["Fixed $", "Percent (%)"], group=grpAcc)
riskFixed     = input.float(250, "Risk Amount ($)", group=grpAcc, minval=0)
riskPercent   = input.float(2.0, "Risk (%)", group=grpAcc, minval=0.01, step=0.1)
contractSize  = input.int(100000, "Contract Size per Lot (units)", group=grpAcc, minval=1, tooltip="Standard=100000, Mini=10000, Micro=1000")

// ── Table Settings ──────────────────────────────────────
grpTbl = "Table Settings"
tblPosition = input.string("Bottom Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpTbl)
txtColor    = input.color(color.white, "Text Color", group=grpTbl)
bgColor     = input.color(color.new(color.green, 0), "Table Background Color", group=grpTbl)
txtSize     = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=grpTbl)

// ── ATR Calculation (smoothing selectable, on chosen TF) ─
ma(src, len, kind) =>
    switch kind
        "RMA" => ta.rma(src, len)
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)

atrValue = request.security(syminfo.tickerid, atrTF, ma(ta.tr(true), atrLength, atrSmoothing))

// ── Pip Size by Market Type ─────────────────────────────
pipSize = marketType == "Forex Pairs" ? (str.contains(syminfo.ticker, "JPY") ? 0.01 : 0.0001)
     : marketType == "Metals (XAU/XAG)" ? 0.01
     : marketType == "Indices" ? 1.0
     : marketType == "Crypto" ? syminfo.mintick
     : customPip

// ── Distances ────────────────────────────────────────────
slDistance = atrValue * slMult
tpDistance = atrValue * tpMult
slPips     = slDistance / pipSize
tpPips     = tpDistance / pipSize

// ── Risk & Lot Size ──────────────────────────────────────
riskAmount = riskType == "Fixed $" ? riskFixed : accountSize * (riskPercent / 100)
lotSize    = slDistance > 0 ? riskAmount / (slDistance * contractSize) : na
units      = lotSize * contractSize

// ── Table Position / Size mapping ────────────────────────
tblPos = tblPosition == "Top Right" ? position.top_right
     : tblPosition == "Top Left" ? position.top_left
     : tblPosition == "Bottom Left" ? position.bottom_left
     : position.bottom_right

tSize = txtSize == "Small" ? size.small : txtSize == "Large" ? size.large : size.normal

var table infoTable = table.new(tblPos, 2, 7, border_width=1)

f_cell(_col, _row, _txt, _hdr=false) =>
    table.cell(infoTable, _col, _row, _txt, bgcolor=_hdr ? color.new(color.black, 0) : bgColor, text_color=txtColor, text_size=tSize)

if barstate.islast
    f_cell(0, 0, "ATR Position Sizer", true)
    f_cell(1, 0, "", true)
    f_cell(0, 1, "ATR (" + str.tostring(atrLength) + ")")
    f_cell(1, 1, str.tostring(atrValue, format.mintick))
    f_cell(0, 2, "SL Distance")
    f_cell(1, 2, str.tostring(slPips, "#.#") + " pips")
    f_cell(0, 3, "TP Distance")
    f_cell(1, 3, str.tostring(tpPips, "#.#") + " pips")
    f_cell(0, 4, "Risk Amount")
    f_cell(1, 4, "$" + str.tostring(riskAmount, "#.##"))
    f_cell(0, 5, "Lot Size")
    f_cell(1, 5, str.tostring(lotSize, "#.##"))
    f_cell(0, 6, "Units")
    f_cell(1, 6, str.tostring(units, "#,###"))
````
