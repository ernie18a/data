# Magyar Napok FIX (H-P)

- url: https://www.tradingview.com/script/1RWDnOLS-Magyar-Napok-FIX-H-P/
- type: indicator
- pine_id: PUB;419fdac56ccd4915b47c27e6e0631267
- version: 1.0

## Description

🇭🇺 Hungarian Day Labels FIX (Mon–Fri)

This indicator automatically displays the days of the week (Monday–Friday) in Hungarian directly on your chart, precisely at each real day change.

🔧 Features:
✔️ Accurate day detection (based on actual day change, not session/timeframe dependent)
✔️ Displays only weekdays (Monday to Friday)
✔️ Clean, minimal design (text only, no background)
✔️ Fully customizable:
Text color
Size (small / normal / large)
Position (top or bottom of the chart)
🧠 How it works:

The script monitors changes in the built-in dayofweek variable, ensuring that each new day is labeled exactly when the calendar day changes — independent of timeframe or session settings.

🎯 Use cases:
Time-based market analysis (e.g. London / New York sessions)
Quick visual separation of trading days
Useful for SMC / ICT traders tracking daily structure
⚙️ How to use:
Copy the script into the TradingView Pine Editor
Click “Add to Chart”
Adjust color, size, and position in settings
----------------------------------------------------------------------------------------------------------------
🇭🇺 Magyar Napok FIX (H-P) – Pine Script indikátor

Ez az indikátor automatikusan kiírja a hét napjait magyarul a charton (Hétfő–Péntek), pontosan a napváltásoknál.

🔧 Funkciók:
✔️ Automatikus napfelismerés (nem session alapú, hanem valódi napváltás)
✔️ Csak munkanapokat jelenít meg (Hétfő–Péntek)
✔️ Tiszta, minimalista megjelenés (nincs háttér, csak szöveg)
✔️ Testreszabható:
Szöveg színe
Méret (kicsi / normál / nagy)
Elhelyezés (chart tetején vagy alján)
🧠 Hogyan működik?

Az indikátor a dayofweek változását figyeli, így pontosan akkor írja ki az új napot, amikor ténylegesen vált a nap — nem a timeframe-től vagy session-től függően.

🎯 Mire jó?
Időalapú elemzéshez (pl. NY Open, London session)
Backtest során napok gyors azonosítására
SMC / ICT stratégiáknál nap szerinti struktúra megértéséhez
⚙️ Használat:
Másold be a kódot TradingView Pine Editor-ba
Kattints az Add to Chart gombra
Állítsd be a színt, méretet és pozíciót igény szerint

## Source Code

````pine
//@version=5
indicator("Magyar Napok FIX (H-P)", overlay=true)

// ==== BEÁLLÍTÁSOK ====
szin = input.color(color.white, "Szöveg színe")
pozicio = input.string("Felül", "Elhelyezés", options=["Felül", "Alul"])
meret = input.string("normál", "Méret", options=["kicsi", "normál", "nagy"])

// ==== MÉRET ====
label_size = meret == "kicsi" ? size.small : meret == "nagy" ? size.large : size.normal

// ==== NAPOK ====
nap = dayofweek

nap_szoveg =
     nap == dayofweek.monday    ? "Hétfő" :
     nap == dayofweek.tuesday   ? "Kedd" :
     nap == dayofweek.wednesday ? "Szerda" :
     nap == dayofweek.thursday  ? "Csütörtök" :
     nap == dayofweek.friday    ? "Péntek" :
                                 ""

// ==== VALÓDI NAPVÁLTÁS ====
// nem time("D"), hanem nap változás
uj_nap = nap != nap[1]

// ==== POZÍCIÓ (fix) ====
offset = (high - low) * 0.5
y_poz = pozicio == "Felül" ? high + offset : low - offset

// ==== LABEL ====
if uj_nap and nap_szoveg != ""
    label.new(bar_index, y_poz, nap_szoveg, style=label.style_none, textcolor=szin, size=label_size)
````
