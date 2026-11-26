# Bostian/Elder Accumulation Distribution

- url: https://www.tradingview.com/script/JFEuVltb/
- type: indicator
- pine_id: PUB;0889775d8ec4466db5703da7c0cc3f49
- version: 1.0

## Description

//@version=6
indicator(title="Bostian/Elder Accumulation Distribution", shorttitle="Bostian A/D", format=format.volume, overlay=false, timeframe="", timeframe_gaps=true)

// 1. Volumen-Überprüfung (Sicherheitsabfrage)
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

// 2. Berechnung nach David Bostian: (Close - Open) / (High - Low) * Volumen
// Die Abfrage verhindert eine Division durch Null bei Doji-Kerzen (high == low)
ad_value = high == low ? 0 : ((close - open) / (high - low)) * volume

// 3. Fortlaufende Kumulierung der täglichen Werte
ad = ta.cum(ad_value)

// 4. Grafische Ausgabe
plot(ad, title = "Bostian A/D Line", color=#999915, linewidth=2)

## Source Code

````pine
//@version=6
indicator(title="Bostian/Elder Accumulation Distribution", shorttitle="Bostian A/D", format=format.volume, overlay=false, timeframe="", timeframe_gaps=true)

// 1. Volumen-Überprüfung (Sicherheitsabfrage)
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

// 2. Berechnung nach David Bostian: (Close - Open) / (High - Low) * Volumen
// Die Abfrage verhindert eine Division durch Null bei Doji-Kerzen (high == low)
ad_value = high == low ? 0 : ((close - open) / (high - low)) * volume

// 3. Fortlaufende Kumulierung der täglichen Werte
ad = ta.cum(ad_value)

// 4. Grafische Ausgabe
plot(ad, title = "Bostian A/D Line", color=#999915, linewidth=2)
````
