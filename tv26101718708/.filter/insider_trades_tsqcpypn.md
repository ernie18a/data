# Insider Trades

- url: https://www.tradingview.com/script/TsqcPyPn-Insider-Trades/
- type: indicator
- pine_id: PUB;cc2883421c654534ba8e20304b77d963
- version: 1.0

## Description

Insider Trades — Smart Money Activity Indicator

Insider Trades is a price-action based indicator designed to highlight high-impact institutional activity on the chart using insider trades combined with volume and price confirmation.

It helps traders quickly identify areas where smart money may be accumulating or distributing positions, improving decision-making and trade timing.

Key Features
 - Insider Buy /  Insider Sell Signals : Clearly marks significant deals directly on the chart for easy tracking.
- Strong Insider Buy Highlight : High-conviction buying is emphasized with larger green labels, based on:
         Large deal size
         Volume spike
         Positive price movement
- Volume Spike Confirmation : Filters signals using abnormal volume to focus on meaningful activity.
- Deal Price Levels : Optional horizontal lines show transaction prices, helping identify potential support and resistance zones. 
- Smart Filtering :  Reduces noise and highlights only relevant institutional activity.

## Source Code

````pine
//@version=6
indicator("Insider Trades", overlay = true,
     max_labels_count = 100, max_lines_count = 50)

// ── INPUTS ─────────────────────────────────────────────

// General
scripCode = input.string("", "BSE Scrip Code")

// Volume
showVol     = input.bool(true,  "Show volume spikes", group="Volume")
volLen      = input.int(20,     "MA Length", group="Volume", minval=5)
volMult     = input.float(2.0,  "Spike Multiplier", group="Volume")
priceMinPct = input.float(1.0,  "Min Price Move %", group="Volume")

// Insider Filter
minQty      = input.int(100000, "Min Deal Qty", group="Insider Filter")
requireVol  = input.bool(true, "Require Volume Spike", group="Insider Filter")
requireMove = input.bool(false, "Require Price Move", group="Insider Filter")
strongMult  = input.float(2.5, "Strong Buy Multiplier", group="Insider Filter")

// Display
showPxLine = input.bool(true, "Show price line", group="Deals")

// ── PREDEFINED HISTORICAL DEALS ───────────────────────

// Deal 1
d1_on = input.bool(true, "Deal 1", group="Deals")
d1_dt = input.time(timestamp("2021-01-01 00:00 +0530"), "Date 1", group="Deals")
d1_ty = input.string("Buy", "Type 1", options=["Buy","Sell","Both"], group="Deals")
d1_qt = input.int(200000, "Qty 1", group="Deals")
d1_px = input.float(0, "Price 1", group="Deals")

// Deal 2
d2_on = input.bool(true, "Deal 2", group="Deals")
d2_dt = input.time(timestamp("2021-06-01 00:00 +0530"), "Date 2", group="Deals")
d2_ty = input.string("Buy", "Type 2", options=["Buy","Sell","Both"], group="Deals")
d2_qt = input.int(150000, "Qty 2", group="Deals")
d2_px = input.float(0, "Price 2", group="Deals")

// Deal 3
d3_on = input.bool(true, "Deal 3", group="Deals")
d3_dt = input.time(timestamp("2022-01-01 00:00 +0530"), "Date 3", group="Deals")
d3_ty = input.string("Sell", "Type 3", options=["Buy","Sell","Both"], group="Deals")
d3_qt = input.int(120000, "Qty 3", group="Deals")
d3_px = input.float(0, "Price 3", group="Deals")

// ── ARRAYS ───────────────────────────────────────────
var deals_on = array.new_bool()
var deals_dt = array.new_int()
var deals_ty = array.new_string()
var deals_qt = array.new_int()
var deals_px = array.new_float()

if barstate.isfirst
    array.push(deals_on, d1_on), array.push(deals_dt, d1_dt), array.push(deals_ty, d1_ty), array.push(deals_qt, d1_qt), array.push(deals_px, d1_px)
    array.push(deals_on, d2_on), array.push(deals_dt, d2_dt), array.push(deals_ty, d2_ty), array.push(deals_qt, d2_qt), array.push(deals_px, d2_px)
    array.push(deals_on, d3_on), array.push(deals_dt, d3_dt), array.push(deals_ty, d3_ty), array.push(deals_qt, d3_qt), array.push(deals_px, d3_px)

// ── COLORS ───────────────────────────────────────────
BUY_C  = color.green
SELL_C = color.red
BOTH_C = color.orange
VOL_BG = color.new(color.orange, 85)

// ── VOLUME SPIKE ─────────────────────────────────────
volMA     = ta.sma(volume, volLen)
volRatio  = volume / volMA
priceMove = math.abs(close - open) / open * 100

isSpike = volRatio >= volMult and priceMove >= priceMinPct

bgcolor(showVol and isSpike ? VOL_BG : na)

// ── FORMAT FUNCTION ──────────────────────────────────
fmtQ(n) =>
    val = float(n)
    result = str.tostring(val)

    if val >= 10000000
        result := str.tostring(val / 10000000.0, "#.##") + "Cr"
    else if val >= 100000
        result := str.tostring(val / 100000.0, "#.##") + "L"
    else if val >= 1000
        result := str.tostring(val / 1000.0, "#.##") + "K"

    result

// ── INSIDER DETECTION ────────────────────────────────
for i = 0 to array.size(deals_on) - 1
    on  = array.get(deals_on, i)
    dt  = array.get(deals_dt, i)
    typ = array.get(deals_ty, i)
    qty = array.get(deals_qt, i)
    px  = array.get(deals_px, i)

    isBig   = qty >= minQty
    volOK   = not requireVol or isSpike
    priceOK = not requireMove or priceMove >= priceMinPct

    isInsider = on and isBig and volOK and priceOK

    if isInsider and dt != 0
        if year(dt) == year(time) and month(dt) == month(time) and dayofmonth(dt) == dayofmonth(time)

            isBuy = typ == "Buy"

            // 🔥 STRONG BUY CONDITION
            isStrongBuy = isBuy and qty >= minQty * strongMult and isSpike and close > open

            col = typ == "Both" ? BOTH_C : isBuy ? BUY_C : SELL_C

            txt = isBuy ? "INSIDER BUY" : "INSIDER SELL"
            txt += "\n" + fmtQ(qty)

            labelSize = size.normal
            labelColor = col

            if isStrongBuy
                txt := "🔥 STRONG BUY\n" + fmtQ(qty)
                labelSize := size.large
                labelColor := color.green

            label.new(
                bar_index,
                isBuy ? low : high,
                txt,
                style = isBuy ? label.style_label_up : label.style_label_down,
                color = labelColor,
                textcolor = color.white,
                size = labelSize
            )

            // Price line
            if showPxLine and px > 0
                lineWidth = isStrongBuy ? 3 : 2
                lineColor = isStrongBuy ? color.green : col

                line.new(
                    bar_index - 3, px,
                    bar_index + 3, px,
                    color=lineColor,
                    width=lineWidth
                )

// ── TABLE ───────────────────────────────────────────
if barstate.islast
    t = table.new(position.top_right, 2, 3)

    table.cell(t, 0, 0, "Ticker")
    table.cell(t, 1, 0, syminfo.ticker)

    table.cell(t, 0, 1, "Scrip")
    table.cell(t, 1, 1, scripCode == "" ? "Set Code" : scripCode)

    table.cell(t, 0, 2, "Mode")
    table.cell(t, 1, 2, "Insider + Strong Buy")
````
