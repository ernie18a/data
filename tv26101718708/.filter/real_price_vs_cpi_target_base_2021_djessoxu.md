# Real Price vs CPI Target (base 2021)

- url: https://www.tradingview.com/script/djesSoxU-Real-Price-vs-CPI-Target-base-2021/
- type: indicator
- pine_id: PUB;779ef30e731f4694b7f841d29673654c
- version: 1.0

## Description

An overlay indicator that shows how an asset performs against US CPI inflation from a user-defined base date.
Three lines are plotted on the price chart:

Nominal Price (gray) — the actual quoted price
Real Price (orange) — current price in base-period purchasing power
CPI Target (blue) — what the price would be today if it had kept pace with inflation

The shaded area between nominal price and CPI target turns green when the asset beats inflation and red when it lags, giving an immediate visual read on real performance.

A summary table reports base price, CPI target, cumulative inflation, nominal return, real return, and the exact Fisher ratio between nominal price and CPI target.

Default CPI source: FRED:CPIAUCSL. Can be swapped for any monthly CPI series (e.g. ECONOMICS:ESCPI for Spain, ECONOMICS:ROCPI for Romania). Useful for comparing nominal vs inflation-adjusted highs, evaluating real returns across the 2021–2026 inflation cycle, and inflation-aware asset allocation.

## Source Code

````pine
//@version=5
indicator("Real Price vs CPI Target (base 2021)", shorttitle="Real vs CPI Target", overlay=true)

// ============================================================
// INPUTS
// ============================================================
baseYear     = input.int(2021, "Base year for adjustment", minval=1950, maxval=2030)
baseMonth    = input.int(1,    "Base month (1-12)",        minval=1,    maxval=12)
cpiSymbol    = input.symbol("FRED:CPIAUCSL", "CPI source (FRED:CPIAUCSL recommended)")
showNominal  = input.bool(true,  "Show nominal price (gray)")
showReal     = input.bool(true,  "Show real CPI-adjusted price (orange)")
showTarget   = input.bool(true,  "Show inflation-adjusted target (blue)")
fillGap      = input.bool(true,  "Shade area between nominal price and CPI target")
lineWidth    = input.int(2, "Main line width", minval=1, maxval=5)

// ============================================================
// CPI DATA - monthly, no lookahead to prevent repainting
// ============================================================
cpiNow = request.security(cpiSymbol, "M", close, ignore_invalid_symbol=true, lookahead=barmerge.lookahead_off)

// ============================================================
// CAPTURE BASE VALUES: CPI and asset price at reference date
// ============================================================
baseTimestamp = timestamp("GMT-5", baseYear, baseMonth, 1, 0, 0)

var float cpiBase   = na
var float priceBase = na

if na(cpiBase) and not na(cpiNow) and time >= baseTimestamp
    cpiBase := cpiNow
    priceBase := close

// ============================================================
// CALCULATIONS
// ============================================================
realPrice = not na(cpiBase) and not na(cpiNow) and cpiNow > 0 ? close * (cpiBase / cpiNow) : na
cpiTarget = not na(cpiBase) and not na(priceBase) and not na(cpiNow) and cpiBase > 0 ? priceBase * (cpiNow / cpiBase) : na

// ============================================================
// PLOTS
// ============================================================
pNominal = plot(showNominal ? close     : na, title="Nominal price",        color=color.new(color.gray, 50),   linewidth=1)
pReal    = plot(showReal    ? realPrice : na, title="Real price (CPI-adj)", color=color.new(color.orange, 0),  linewidth=lineWidth)
pTarget  = plot(showTarget  ? cpiTarget : na, title="Inflation-adj target", color=color.new(color.blue, 0),    linewidth=lineWidth, style=plot.style_line)

fillColor = not na(cpiTarget) and not na(close) ? (close >= cpiTarget ? color.new(color.green, 85) : color.new(color.red, 85)) : na
fill(pNominal, pTarget, color=fillGap ? fillColor : na, title="Outperformance vs CPI")

// ============================================================
// SUMMARY TABLE
// ============================================================
var table info = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    inflCum      = not na(cpiBase) and not na(cpiNow)     ? (cpiNow / cpiBase - 1) * 100 : na
    nominalRet   = not na(priceBase) and not na(close)    ? (close / priceBase - 1) * 100 : na
    realRet      = not na(nominalRet) and not na(inflCum) ? nominalRet - inflCum         : na
    diffVsTarget = not na(close) and not na(cpiTarget) and cpiTarget > 0 ? (close / cpiTarget - 1) * 100 : na

    table.cell(info, 0, 0, "Base:",              text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 0, str.tostring(baseMonth) + "/" + str.tostring(baseYear), text_color=color.white, text_size=size.small)
    table.cell(info, 0, 1, "Base price:",        text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 1, str.tostring(priceBase, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(info, 0, 2, "CPI target now:",    text_color=color.blue,   text_size=size.small)
    table.cell(info, 1, 2, str.tostring(cpiTarget, "#.##"), text_color=color.blue, text_size=size.small)
    table.cell(info, 0, 3, "Cumulative infl.:",  text_color=color.yellow, text_size=size.small)
    table.cell(info, 1, 3, str.tostring(inflCum, "#.##") + " %", text_color=color.yellow, text_size=size.small)
    table.cell(info, 0, 4, "Nominal return:",    text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 4, str.tostring(nominalRet, "#.##") + " %", text_color=color.white, text_size=size.small)
    table.cell(info, 0, 5, "Real return:",       text_color=realRet >= 0 ? color.lime : color.red, text_size=size.small)
    table.cell(info, 1, 5, str.tostring(realRet, "#.##") + " %", text_color=realRet >= 0 ? color.lime : color.red, text_size=size.small)
    table.cell(info, 0, 6, "Nominal vs Target:", text_color=diffVsTarget >= 0 ? color.lime : color.red, text_size=size.small)
    table.cell(info, 1, 6, str.tostring(diffVsTarget, "#.##") + " %", text_color=diffVsTarget >= 0 ? color.lime : color.red, text_size=size.small)
````
