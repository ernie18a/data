# FOMC Events 2019-2026

- url: https://www.tradingview.com/script/WfuWVKWT-FOMC-Events-2019-2026/
- type: indicator
- pine_id: PUB;c5d13f8dc0ad471ead6ee091c9a57943
- version: 1.0

## Description

Look for market inflection points induced by the FOMC

## Source Code

````pine
//@version=5
indicator("FOMC Sitzungen 2019-2026", overlay=true)

// Hilfsfunktion: prüft ob aktueller Bar einem Datum entspricht
isDate(yr, mn, dy) =>
    year == yr and month == mn and dayofmonth == dy

// Alle FOMC-Entscheidungstage 2019 - 2026
isFOMC =
  // 2019
  isDate(2019, 1, 30)  or isDate(2019, 3, 20)  or isDate(2019, 5, 1)  or isDate(2019, 6, 19) or
  isDate(2019, 7, 31)  or isDate(2019, 9, 18)  or isDate(2019, 10, 30) or isDate(2019, 12, 11) or
  // 2020 (inkl. zwei Notfallsitzungen im März)
  isDate(2020, 1, 29)  or isDate(2020, 3, 3)   or isDate(2020, 3, 15) or isDate(2020, 4, 29) or
  isDate(2020, 6, 10)  or isDate(2020, 7, 29)  or isDate(2020, 9, 16) or isDate(2020, 11, 5) or
  isDate(2020, 12, 16) or
  // 2021
  isDate(2021, 1, 27)  or isDate(2021, 3, 17)  or isDate(2021, 4, 28) or isDate(2021, 6, 16) or
  isDate(2021, 7, 28)  or isDate(2021, 9, 22)  or isDate(2021, 11, 3) or isDate(2021, 12, 15) or
  // 2022
  isDate(2022, 1, 26)  or isDate(2022, 3, 16)  or isDate(2022, 5, 4)  or isDate(2022, 6, 15) or
  isDate(2022, 7, 27)  or isDate(2022, 9, 21)  or isDate(2022, 11, 2) or isDate(2022, 12, 14) or
  // 2023
  isDate(2023, 2, 1)   or isDate(2023, 3, 22)  or isDate(2023, 5, 3)  or isDate(2023, 6, 14) or
  isDate(2023, 7, 26)  or isDate(2023, 9, 20)  or isDate(2023, 11, 1) or isDate(2023, 12, 13) or
  // 2024
  isDate(2024, 1, 31)  or isDate(2024, 3, 20)  or isDate(2024, 5, 1)  or isDate(2024, 6, 12) or
  isDate(2024, 7, 31)  or isDate(2024, 9, 18)  or isDate(2024, 11, 7) or isDate(2024, 12, 18) or
  // 2025
  isDate(2025, 1, 29)  or isDate(2025, 3, 19)  or isDate(2025, 5, 7)  or isDate(2025, 6, 18) or
  isDate(2025, 7, 30)  or isDate(2025, 9, 17)  or isDate(2025, 10, 29) or isDate(2025, 12, 10) or
  // 2026
  isDate(2026, 1, 28)  or isDate(2026, 3, 18)  or isDate(2026, 4, 29) or isDate(2026, 6, 17) or
  isDate(2026, 7, 29)  or isDate(2026, 9, 16)  or isDate(2026, 10, 28) or isDate(2026, 12, 9)

// Einstellungen (kannst du im Indikator-Menü anpassen)
markerColor = input.color(color.new(color.blue, 0), "Farbe")
showLine    = input.bool(false, "Vertikale Linie anzeigen")
showLabel   = input.bool(false, "Beschriftung 'FOMC' anzeigen")

// Punkt im Chart zeichnen (ohne Label)
plotshape(isFOMC and not showLabel, title="FOMC", style=shape.circle, location=location.abovebar,
          color=markerColor, size=size.small)

// Punkt mit Label "FOMC" (alternativ)
plotshape(isFOMC and showLabel, title="FOMC mit Label", style=shape.labeldown, location=location.abovebar,
          color=markerColor, size=size.small, text="FOMC", textcolor=color.white)

// Optional: vertikale Linie über den ganzen Chart
bgcolor(showLine and isFOMC ? color.new(markerColor, 85) : na, title="FOMC Linie")

// Alarm einrichten (optional)
alertcondition(isFOMC, title="FOMC Sitzung", message="Heute ist FOMC-Entscheidungstag!")
````
