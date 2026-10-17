# Chande Momentum Oscillator [smoothed] - RAF07

- url: https://www.tradingview.com/script/jDAOIuGN/
- type: indicator
- pine_id: PUB;95472ce7f0814652868c5f31d39eb40a
- version: 1.0

## Description

It shows timeframe of accumulation and capitulation for BTC

## Source Code

````pine
//@version=6
indicator("Chande Momentum Oscillator [smoothed] - Custom Cycle", shorttitle="CMO_Smooth", overlay=false)

// 1. Ustawienia wejściowe (Inputy)
cmoLength  = input.int(14, title="CMO Length", minval=1)
smoothType = input.string("WMA", title="Smoothing MA Type", options=["SMA", "EMA", "WMA"])
smoothLen  = input.int(9, title="Smoothing Length", minval=1)

// Ustawienia poziomów sygnałowych (dopasowane do wykresu macro BTC)
accLevel   = input.float(-30.0, title="Accumulation Level")
capLevel   = input.float(-55.0, title="Capitulation Level")

// 2. Kalkulacja bazowego Chande Momentum Oscillator (CMO)
moms = ta.change(close)
sumUp = ta.rma(moms > 0 ? moms : 0.0, cmoLength) * cmoLength
sumDown = ta.rma(moms < 0 ? -moms : 0.0, cmoLength) * cmoLength

rawCMO = 100.0 * (sumUp - sumDown) / (sumUp + sumDown)

// 3. Wygładzenie wskaźnika (Smoothed)
var float smoothedCMO = na
if smoothType == "SMA"
    smoothedCMO := ta.sma(rawCMO, smoothLen)
else if smoothType == "EMA"
    smoothedCMO := ta.ema(rawCMO, smoothLen)
else if smoothType == "WMA"
    smoothedCMO := ta.wma(rawCMO, smoothLen)

// 4. Kolorystyka linii oscylatora (Charakterystyczny morski odcień z wykresu)
plotColor = color.new(#31c4cd, 0)
plot(smoothedCMO, title="Smoothed CMO", color=plotColor, linewidth=2)

// 5. Definiowanie stref i linii poziomych
hAcc = hline(accLevel, title="Accumulation", color=color.green, linestyle=hline.style_dashed)
hCap = hline(capLevel, title="Capitulation", color=color.red, linestyle=hline.style_solid, linewidth=2)

// Wypełnienie tła strefy kapitulacji
fill(hAcc, hCap, color=color.new(color.red, 92), title="Capitulation Zone Background")

// 6. Wyświetlanie etykiet tekstowych po lewej stronie (Rozwiązanie problemu ce10272)
var label lblAcc = na
var label lblCap = na

if barstate.islast
    // Etykieta dla poziomu Akumulacji
    lblAcc := label.new(x=bar_index - 15, y=accLevel, text="Accumulation",
       color=color.new(color.green, 20), textcolor=color.white, style=label.style_label_right, size=size.small)
    // Etykieta dla poziomu Kapitulacji
    lblCap := label.new(x=bar_index - 15, y=capLevel, text="Capitulation",
       color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_right, size=size.small)

    // Czyszczenie starych etykiet przy odświeżaniu wykresu live
    label.delete(lblAcc[1])
    label.delete(lblCap[1])
````
