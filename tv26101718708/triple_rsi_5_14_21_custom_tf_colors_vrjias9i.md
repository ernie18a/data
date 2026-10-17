# Triple RSI (5, 14, 21) - Custom TF & Colors

- url: https://www.tradingview.com/script/vRjIAs9I/
- type: indicator
- pine_id: PUB;c7514ae9871e43678ad7def181dd5b8d
- version: 1.0

## Description

Triple RSI to rozszerzona wersja klasycznego wskaźnika Relative Strength Index, która łączy trzy różne okresy RSI w jednym panelu oraz umożliwia analizę z wybranego interwału (timeframe).

Wskaźnik składa się z:

RSI 5 – szybkie momentum (wejścia)
RSI 14 – balans rynku (potwierdzenie)
RSI 21 – kierunek trendu (filtr)

Dodatkowo możesz obliczać RSI z innego interwału niż aktualny wykres, co znacząco poprawia filtrację sygnałów.

⚙️ Funkcje:
3 linie RSI w jednym oknie
Możliwość wyboru interwału (timeframe)
Możliwość zmiany kolorów każdej linii
Klasyczne poziomy:
70 → wykupienie
30 → wyprzedanie
50 → równowaga
📈 Jak działa:

Wskaźnik analizuje relację pomiędzy trzema RSI:

🔼 Sygnał wzrostowy (BUY bias):
RSI 5 > RSI 14 > RSI 21
wszystkie linie skierowane w górę
🔽 Sygnał spadkowy (SELL bias):
RSI 5 < RSI 14 < RSI 21
wszystkie linie skierowane w dół
⚠️ Konsolidacja:
linie przecinają się często
RSI poruszają się w zakresie 45–55
→ brak przewagi rynkowej
⏱️ Timeframe (kluczowa funkcja):

Wskaźnik pozwala analizować RSI z wyższego interwału niż wykres.

Przykład:

wykres: M5
RSI: M15

Dzięki temu:

filtrujesz szum z niższego TF
zwiększasz jakość wejść
🎯 Zastosowanie:
Scalping (M5 z filtrem M15)
Day trading (M15 / M30)
Filtr do strategii:
EMA
SuperTrend
Price Action
💡 Wskazówki:
Najlepsze sygnały powstają, gdy wszystkie RSI są ustawione kierunkowo (5 > 14 > 21)
Unikaj handlu w konsolidacji
Łącz wskaźnik z trendem z wyższego interwału
🎨 Personalizacja:

W ustawieniach możesz:

zmieniać kolory każdej linii
ustawić własny interwał RSI
dopasować wskaźnik do swojego stylu tradingu
⚠️ Uwaga:

Wskaźnik nie stanowi gotowej strategii inwestycyjnej. Zaleca się stosowanie go wraz z analizą trendu oraz odpowiednim zarządzaniem ryzykiem.

## Source Code

````pine
//@version=5
indicator("Triple RSI (5, 14, 21) - Custom TF & Colors", overlay=false)

// Parametry RSI
rsiFastLength = input.int(5, title="RSI Fast (5)")
rsiMidLength  = input.int(14, title="RSI Mid (14)")
rsiSlowLength = input.int(21, title="RSI Slow (21)")
src = input.source(close, title="Source")

// Timeframe (interwał)
tf = input.timeframe("", title="RSI Timeframe (leave empty = current)")

// Kolory
colorFast = input.color(color.orange, title="RSI 5 Color")
colorMid  = input.color(color.yellow, title="RSI 14 Color")
colorSlow = input.color(color.white, title="RSI 21 Color")

// Funkcja RSI
f_rsi(_src, _len) =>
    ta.rsi(_src, _len)

// Pobieranie RSI z wybranego TF
rsiFast = request.security(syminfo.tickerid, tf == "" ? timeframe.period : tf, f_rsi(src, rsiFastLength))
rsiMid  = request.security(syminfo.tickerid, tf == "" ? timeframe.period : tf, f_rsi(src, rsiMidLength))
rsiSlow = request.security(syminfo.tickerid, tf == "" ? timeframe.period : tf, f_rsi(src, rsiSlowLength))

// Poziomy
hline(70, "Overbought", color=color.red)
hline(30, "Oversold", color=color.green)
hline(50, "Midline", color=color.gray)

// Linie
plot(rsiFast, title="RSI 5", color=colorFast, linewidth=2)
plot(rsiMid,  title="RSI 14", color=colorMid, linewidth=2)
plot(rsiSlow, title="RSI 21", color=colorSlow, linewidth=2)
````
