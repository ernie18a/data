# MTF ATR SL Level

- url: https://www.tradingview.com/script/GmDNAcC5/
- type: indicator
- pine_id: PUB;ab008586179a402c8712e3504eeb5711
- version: 1.0

## Description

This Pine Script (Version 6) is a technical indicator for TradingView called "MTF ATR Level".

In short: The indicator calculates the Average True Range (ATR) – meaning the average volatility (price fluctuation range) – from a higher timeframe (e.g., the daily chart) and projects these values as dynamic resistance and support bands directly onto your current chart (e.g., a 5-minute or 1-hour chart).

Here is the exact functionality broken down in detail:

1. Core Functions & Settings
Multi-Timeframe (MTF) Logic: The script uses the request.security() function to fetch data from another timeframe (set to Daily/'D' by default). This allows you to immediately see where the important volatility boundaries of the higher-level daily chart lie on smaller intraday charts.

Flexible ATR Filter: You can choose how the ATR should be smoothed in the settings menu. Three mathematical methods are available:

RMA (Welles Wilder's Moving Average – the standard for ATR)

SMA (Simple Moving Average)

EMA (Exponential Moving Average)

Adjustable Multipliers: You can use the inputs (Upper/Lower ATR Multiplier) to determine how many ATR units the lines should be shifted away from yesterday's closing price (e.g., 1.0 ATR, 1.5 ATR, etc.).

2. How the Lines are Calculated
The script calculates two crucial levels:

Upper Level (Upper Line): Yesterday's close of the higher timeframe + (ATR * Multiplier)

Lower Level (Lower Line): Yesterday's close of the higher timeframe - (ATR * Multiplier)

Dieses Pine Script (Version 6) ist ein technischer Indikator für TradingView namens "MTF ATR Level".

Kurz gesagt: Der Indikator berechnet die Average True Range (ATR) – also die durchschnittliche Volatilität (Schwankungsbreite) – aus einer höheren Zeiteinheit (z. B. dem Tageschart) und projiziert diese Werte als dynamische Widerstands- und Unterstützungsbänder direkt auf deinen aktuellen Chart (z. B. einen 5-Minuten- oder 1-Stunden-Chart).

Hier ist die genaue Funktionsweise im Detail aufgeschlüsselt:



1. Die Kernfunktionen & Einstellungen

Multi-Timeframe (MTF) Logik: Das Script nutzt die Funktion request.security(), um Daten aus einer anderen Zeiteinheit abzurufen (standardmäßig auf Tag/'D' eingestellt). Dadurch siehst du auf den kleineren Intraday-Charts sofort, wo die wichtigen Volatilitätsgrenzen des übergeordneten Tagescharts liegen.

Flexibler ATR-Filter: Du kannst im Einstellungsmenü wählen, wie die ATR geglättet werden soll. Es stehen drei mathematische Methoden zur Verfügung:

RMA (Moving Average von Welles Wilder – der Standard für ATR)

SMA (Einfacher gleitender Durchschnitt)

EMA (Exponentieller gleitender Durchschnitt)

Einstellbare Multiplikatoren: Du kannst über die Inputs (Upper/Lower ATR Multiplier) bestimmen, wie viele ATR-Einheiten die Linien vom gestrigen Schlusskurs entfernt sein sollen (z. B. 1,0 ATR, 1,5 ATR usw.).

2. Wie die Linien berechnet werden

Das Script berechnet zwei entscheidende Niveaus:

Upper Level (Obere Linie): Gestriger Schlusskurs des höheren Timeframes + (ATR * Multiplikator)

Lower Level (Untere Linie): Gestriger Schlusskurs des höheren Timeframes - (ATR * Multiplikator)

## Source Code

````pine
//@version=6
indicator("MTF ATR Level", overlay=true, max_lines_count=50, max_labels_count=50)

atrPeriod       = input.int(12, "ATR Period", group="ATR Settings")
atrMethod       = input.string("RMA", "ATR Smoothing", options=["RMA", "SMA", "EMA"], group="ATR Settings")
timeFrame       = input.timeframe('D', "Timeframe", group="ATR Settings")

upperMultiplier = input.float(1.0, "Upper ATR Multiplier", step=0.1, group="Levels")
lowerMultiplier = input.float(1.0, "Lower ATR Multiplier", step=0.1, group="Levels")

levelOffset     = input.int(5, "Level Offset (bars)", group="Display")
showDistLabel   = input.bool(true, "Show Distance Label", group="Display")

f_atr(_period, _method) =>
    _tr = ta.tr(true)
    switch _method
        "SMA" => ta.sma(_tr, _period)
        "EMA" => ta.ema(_tr, _period)
        => ta.rma(_tr, _period)

[mtf_atr, mtf_close] = request.security(
     syminfo.tickerid, timeFrame,
     [f_atr(atrPeriod, atrMethod)[1], close[1]],
     lookahead=barmerge.lookahead_off
 )

upperLevel = mtf_close + (upperMultiplier * mtf_atr)
lowerLevel = mtf_close - (lowerMultiplier * mtf_atr)

priceAboveUpper = close >= upperLevel
priceBelowLower = close <= lowerLevel

upperColor = priceAboveUpper ? color.new(color.red, 0)   : color.new(color.red, 20)
lowerColor = priceBelowLower ? color.new(color.green, 0) : color.new(color.green, 20)

var line  upperLine  = na
var line  lowerLine  = na
var label upperLabel = na
var label lowerLabel = na

if barstate.islast
    line.delete(upperLine)
    line.delete(lowerLine)
    label.delete(upperLabel)
    label.delete(lowerLabel)

    x1 = bar_index
    x2 = bar_index + levelOffset

    upperLine := line.new(x1, upperLevel, x2, upperLevel, color=upperColor, width=2)
    lowerLine := line.new(x1, lowerLevel, x2, lowerLevel, color=lowerColor, width=2)

    if showDistLabel
        upperDistAtr = (upperLevel - close) / mtf_atr
        lowerDistAtr = (close - lowerLevel) / mtf_atr
        upperLabel := label.new(x2, upperLevel, str.tostring(upperLevel, format.mintick) + "  (" + str.tostring(upperDistAtr, "#.##") + " ATR)", style=label.style_label_left, color=color.new(upperColor, 70), textcolor=upperColor, size=size.normal)
        lowerLabel := label.new(x2, lowerLevel, str.tostring(lowerLevel, format.mintick) + "  (" + str.tostring(lowerDistAtr, "#.##") + " ATR)", style=label.style_label_left, color=color.new(lowerColor, 70), textcolor=lowerColor, size=size.normal)
````
