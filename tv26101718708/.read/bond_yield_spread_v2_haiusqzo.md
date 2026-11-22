# Bond Yield Spread V2

- url: https://www.tradingview.com/script/haiuSQZo-Bond-Yield-Spread-V2/
- type: indicator
- pine_id: PUB;82f5a6520c7443d38eeb541267a649ae
- version: 1.0

## Description

Bonds Yield Spread with Selection possible 
First Version was coded by  © dennis8462

## Source Code

````pine
//@version=6
indicator("Bond Yield Spread ", format=format.percent, overlay=true, scale=scale.none, dynamic_requests=true)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────

groupMaturities = "Bond Maturities"

show01Y = input.bool(false, title="01Y", inline="01Y", group=groupMaturities)
color01Y = input.color(color.red, title="", inline="01Y", group=groupMaturities)

show02Y = input.bool(false, title="02Y", inline="02Y", group=groupMaturities)
color02Y = input.color(color.rgb(255, 105, 180), title="", inline="02Y", group=groupMaturities)

show03Y = input.bool(false, title="03Y", inline="03Y", group=groupMaturities)
color03Y = input.color(color.rgb(128, 255, 255), title="", inline="03Y", group=groupMaturities)

show05Y = input.bool(false, title="05Y", inline="05Y", group=groupMaturities)
color05Y = input.color(color.orange, title="", inline="05Y", group=groupMaturities)

show07Y = input.bool(false, title="07Y", inline="07Y", group=groupMaturities)
color07Y = input.color(color.rgb(180, 75, 0), title="", inline="07Y", group=groupMaturities)

show10Y = input.bool(true, title="10Y", inline="10Y", group=groupMaturities)
color10Y = input.color(color.green, title="", inline="10Y", group=groupMaturities)

show20Y = input.bool(false, title="20Y", inline="20Y", group=groupMaturities)
color20Y = input.color(color.gray, title="", inline="20Y", group=groupMaturities)

show30Y = input.bool(false, title="30Y", inline="30Y", group=groupMaturities)
color30Y = input.color(color.rgb(70, 70, 70), title="", inline="30Y", group=groupMaturities)

//──────────────────────────────────────────────────────────────────────────────
// Currency → Bond symbol mapping
//──────────────────────────────────────────────────────────────────────────────

mapCurrencyToBondLabel(currency, maturity) =>
    label = switch currency
        "EUR" => "EU" + maturity
        "USD" => "US" + maturity
        "AUD" => "AU" + maturity
        "GBP" => "GB" + maturity
        "NZD" => "NZ" + maturity
        "CAD" => "CA" + maturity
        "CHF" => "CH" + maturity
        "JPY" => "JP" + maturity
        "ZAR" => "ZA" + maturity
        "MXN" => "MX" + maturity
        "CNH" => "CN" + maturity
        "TRY" => "TR" + maturity
        "SEK" => "SE" + maturity
        "HKD" => "HK" + maturity
        "NOK" => "NO" + maturity
        "HUF" => "HU" + maturity
        "INR" => "IN" + maturity
        "SGD" => "SG" + maturity
        "BRL" => "BR" + maturity
        "RUB" => "RU" + maturity
        "PLN" => "PL" + maturity
        "KRW" => "KR" + maturity
        "IDR" => "ID" + maturity
        "THB" => "TH" + maturity
        "MYR" => "MY" + maturity
        "PHP" => "PH" + maturity
        "CZK" => "CZ" + maturity
        "ILS" => "IL" + maturity
        "TWD" => "TW" + maturity
        "SAR" => "SA" + maturity
        "AED" => "AE" + maturity
        => ""
    label

//──────────────────────────────────────────────────────────────────────────────
// Bond yield functions
//──────────────────────────────────────────────────────────────────────────────

getBondYield(currency, maturity) =>
    bond = mapCurrencyToBondLabel(currency, maturity)
    request.security("TVC:" + bond, timeframe.period, close, ignore_invalid_symbol=true)

getBondYieldSpread(baseCurrency, quoteCurrency, maturity) =>
    firstBondYield = getBondYield(baseCurrency, maturity)
    secondBondYield = getBondYield(quoteCurrency, maturity)
    firstBondYield - secondBondYield

makeBondLabel(baseCurrency, quoteCurrency, maturity) =>
    baseCurrencyLabel = mapCurrencyToBondLabel(baseCurrency, maturity)
    quoteCurrencyLabel = mapCurrencyToBondLabel(quoteCurrency, maturity)
    maturity + "  " + baseCurrencyLabel + " - " + quoteCurrencyLabel

//──────────────────────────────────────────────────────────────────────────────
// Main chart currencies
//──────────────────────────────────────────────────────────────────────────────

baseCurrency = syminfo.basecurrency
quoteCurrency = syminfo.currency

//──────────────────────────────────────────────────────────────────────────────
// Spreads
//──────────────────────────────────────────────────────────────────────────────

spread01Y = getBondYieldSpread(baseCurrency, quoteCurrency, "01Y")
spread02Y = getBondYieldSpread(baseCurrency, quoteCurrency, "02Y")
spread03Y = getBondYieldSpread(baseCurrency, quoteCurrency, "03Y")
spread05Y = getBondYieldSpread(baseCurrency, quoteCurrency, "05Y")
spread07Y = getBondYieldSpread(baseCurrency, quoteCurrency, "07Y")
spread10Y = getBondYieldSpread(baseCurrency, quoteCurrency, "10Y")
spread20Y = getBondYieldSpread(baseCurrency, quoteCurrency, "20Y")
spread30Y = getBondYieldSpread(baseCurrency, quoteCurrency, "30Y")

//──────────────────────────────────────────────────────────────────────────────
// Plots
//──────────────────────────────────────────────────────────────────────────────

plot(show01Y ? spread01Y : na, title="01Y Spread", color=color01Y, linewidth=1)
plot(show02Y ? spread02Y : na, title="02Y Spread", color=color02Y, linewidth=1)
plot(show03Y ? spread03Y : na, title="03Y Spread", color=color03Y, linewidth=1)
plot(show05Y ? spread05Y : na, title="05Y Spread", color=color05Y, linewidth=1)
plot(show07Y ? spread07Y : na, title="07Y Spread", color=color07Y, linewidth=1)
plot(show10Y ? spread10Y : na, title="10Y Spread", color=color10Y, linewidth=1)
plot(show20Y ? spread20Y : na, title="20Y Spread", color=color20Y, linewidth=1)
plot(show30Y ? spread30Y : na, title="30Y Spread", color=color30Y, linewidth=1)

//──────────────────────────────────────────────────────────────────────────────
// Labels table
// Remplissage depuis le bas pour garder les étiquettes le plus bas possible.
//──────────────────────────────────────────────────────────────────────────────

var table t = table.new(position.bottom_right, 1, 8, border_width=1)

if barstate.islast
    for i = 0 to 7
        table.cell(t, 0, i, "", bgcolor=color.new(color.black, 100), text_color=color.new(color.white, 100))

    int row = 7

    if show30Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "30Y"), bgcolor=color30Y, text_color=color.white)
        row := row - 1

    if show20Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "20Y"), bgcolor=color20Y, text_color=color.white)
        row := row - 1

    if show10Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "10Y"), bgcolor=color10Y, text_color=color.black)
        row := row - 1

    if show07Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "07Y"), bgcolor=color07Y, text_color=color.white)
        row := row - 1

    if show05Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "05Y"), bgcolor=color05Y, text_color=color.black)
        row := row - 1

    if show03Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "03Y"), bgcolor=color03Y, text_color=color.black)
        row := row - 1

    if show02Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "02Y"), bgcolor=color02Y, text_color=color.black)
        row := row - 1

    if show01Y
        table.cell(t, 0, row, makeBondLabel(baseCurrency, quoteCurrency, "01Y"), bgcolor=color01Y, text_color=color.white)
        row := row - 1
````
