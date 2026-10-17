# Liquidity BTC Spot v6 - Terminator Egzekutor PRO - RAF07

- url: https://www.tradingview.com/script/e5Ll3xYd/
- type: indicator
- pine_id: PUB;feb2af827f8e4f5cb41d14dfe4bfb219
- version: 3.0

## Description

Płynność Spot v6 - Terminator Egzekutor PRO

Wskaźnik służy do wykrywania stref, w których gracze instytucjonalni (Smart Money) kumulują swoje pozycje, wybijając stop lossy inwestorów detalicznych.

[b]1. Struktura Wskaźnika[/b] – Algorytm został podzielony na 5 niezależnych modułów matematycznych:
Detektor Płynności Swingów: Odpowiada za szukanie kluczowych szczytów i dołków na podstawie parametru swingLength. Generuje linie wsparcia i oporu, na których leżą zlecenia obronne rynku. 

Silnik Wolumenu Delta i Smart Money: Oblicza tzw. Volume Delta (stosunek siły kupujących do sprzedających wewnątrz pojedynczej świecy). Następnie filtruje go średnią wolumenu, aby wykryć tzw. Volume Spike (nagły, potężny zastrzyk gotówki instytucjonalnej).

Skkaner Konsolidacji (Anomalie Cenowe): Monitoruje zmienność za pomocą wskaźnika ATR. Jeśli rynek się kurczy (tworzy flagę lub klin), system zlicza sumę wolumenu delty z tego okresu, sprawdzając, czy instytucje potajemnie skupują (Akumulacja), czy wyprzedają (Dystrybucja) aktywa.

Stoch RSI & RSI: Odpowiadają za filtr momentum. Szukają momentów skrajnego wyprzedania rynku (poniżej poziomu 42 dla klasycznego RSI oraz poniżej 20 dla Stochastic RSI), aby wejść w pozycję po jak najlepszej cenie.

Projekcja Fibonacci TP: Moduł matematyczny, który po zidentyfikowaniu dołka automatycznie wylicza poziomy docelowe (Take Profit) w oparciu o matematyczne rozszerzenia Fibonacciego.

[b]2. Elementy Graficzne na Wykresie[/b] – 
Pomarańczowe Linie Poziome (BSL - Buy Side Liquidity): Reprezentują płynność nad szczytami. Są to miejsca, gdzie shortujący mają swoje Stop Lossy, a kupujący zlecenia Buy Stop. Gdy cena dotknie tej linii, linia znika (płynność została zebrana).

Niebieskie Linie Poziome (SSL - Sell Side Liquidity): Reprezentują płynność pod dołkami. Miejsca akumulacji zleceń Stop Loss pozycji Long. Podobnie jak BSL, linia ulega usunięciu (kasowaniu) w momencie jej przebicia.

Kolorowanie Tła i Świec (3 Tryby Wizualne):
🟢 Zielone tło/świece: Potwierdzona struktura bycza. Cena porusza się w trendzie wzrostowym (powyżej EMA 50), a wolumen Delty w konsolidacji jest dodatni (Smart Money kupuje).

🔴 Czerwone tło/świece: Potwierdzona struktura niedźwiedzia. Cena znajduje się w trendzie spadkowym (poniżej EMA 50), a Delta potwierdza przewagę sprzedających.

🟡 Żółte tło/świece (ANOMALIA / PUŁAPKA): Najważniejszy element skanera. Oznacza rozbieżność. Na przykład: cena technicznie spada, ale ukryty wolumen wewnątrz świec rośnie na korzyść kupujących. To sygnał, że rynek szykuje fałszywe wybicie (Trap).

Przerywane i ciągłe linie z prawej strony (TP1, TP2, TP3): Poziomy realizacji zysków wyliczane automatycznie. Gdy cena osiągnie dany poziom, wskaźnik dezaktywuje go i usuwa z wykresu (komunikat o uderzeniu w TP).

[b]3. Logika Sygnałowa[/b] – 
Głównym celem tego wskaźnika jest wygenerowanie tzw. Sygnału Ostatecznego (System Sealed). Aby system uznał sygnał za pewny (High Probability Pump), muszą zostać spełnione jednocześnie 4 rygorystyczne warunki: 
a) Polowanie na płynność - Cena musi spaść w rejon ostatniego potwierdzonego dołka (niebieska linia lastConfirmedLow) z uwzględnieniem bufora bezpieczeństwa (alertBuffer).

b) Skrajne wyprzedanie - Wskaźnik RSI musi znajdować się poniżej wartości 42 (rynek jest lokalnie tani).

c) Uderzenie Smart Money - Musi nastąpić gwałtowny skok wolumenu zakupowego (isDeltaSpike). Wolumen świecy musi przekroczyć średnią z 20 okresów pomnożoną przez parametr volMultiplier (domyślnie o 40% wyższy niż standardowy obrót).

d) Zgoda z kierunkiem kapitału - Średnia krocząca strumienia pieniędzy (rawMoneyFlow) musi potwierdzać napływ środków na rynek.

Interpretacja rynkowa 
Jeśli na wykresie widzisz testowanie niebieskiej linii wsparcia, tło zmienia się na zielono lub żółto, a wolumen gwałtownie rośnie przy niskim RSI – oznacza to, że Terminator Egzekutor zidentyfikował obronę dołka przez fundusze instytucjonalne. Automatycznie wyrysowane linie TP1 (0.618 Fibo), TP2 (1.000 Fibo) oraz TP3 (1.618 Fibo) pokazują matematyczny zasięg ruchu korekcyjnego po udanej obronie płynności.


[b]4. Dokładny opis ikonografii:[/b]
Rakieta i zielona tarcza z tickiem (isSystemSealed): Powstaje, gdy cena dotyka strefy płynności pod dołkiem (isNearSSL), wskaźnik RSI jest skrajnie wyprzedany (poniżej 42), wolumen Delta notuje ogromny skok zakupowy (isDeltaSpike), a struktura przepływu pieniędzy (isConfirmedByStructure) zatwierdza wejście kapitału Smart Money.

Błyskawica (isSFP): Klasyczne Swing Failure Pattern. Skrypt sprawdza, czy aktualny dołek świecy jest niższy od poprzedniego (low < low[1]), ale cena zamyka się powyżej dołka oraz powyżej ceny otwarcia (close > low[1] and close > open). To oznacza błyskawiczne odrzucenie ceny i zebranie płynności.

Ogień (isStochDive): Aktywuje się, gdy wskaźnik Stochastic RSI przecina się w kierunku wzrostowym (htfCross) w strefie skrajnego wyprzedania, czyli poniżej poziomu 20 (htfK < 20). Wskazuje to na potężne nagromadzenie energii do odbicia.

Krzyżyk (isExhaustion): Pojawia się, gdy rynek po serii spadkowych świec zaczyna drastycznie zmniejszać rozmiar swoich korpusów (isBodyShrinking), co matematycznie oznacza, że sprzedający tracą siłę (wyczerpanie), a cena ostatecznie zamyka się powyżej otwarcia i maksimów.

Flaga na szczycie po wzrostach - sygnał do sprzedaży

## Source Code

````pine
//@version=6
indicator("Liquidity Spot v6 - Terminator Egsecutor PRO", overlay=true, max_lines_count=100, max_labels_count=50)

// --- PARAMETRY WEJŚCIOWE ---
int swingLength     = input.int(5, title="Czułość Szczytów/Dołków (Swing Length)", minval=1)
float alertBuffer   = input.float(1.5, title="Wczesny alert % przed strefą", minval=0.1, maxval=5.0) / 100
int volLength       = input.int(20, title="Okres Średniej Wolumenu", minval=5)
float volMultiplier = input.float(1.4, title="Mnożnik Wolumenu Smart Money", minval=1.0, maxval=5.0)

// Kolorystyka
color bslColor      = input.color(color.orange, title="Płynność nad Szczytami (BSL)")
color sslColor      = input.color(color.blue, title="Płynność pod Dołkami (SSL)")

// Inicjalizacja Tabeli w zakresie globalnym
var table reportTable = table.new(position.top_right, 5, 2, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)

// Inicjalizacja linii Take Profit Fibo
var line fiboTP1 = na
var line fiboTP2 = na
var line fiboTP3 = na
var label labelTP1 = na
var label labelTP2 = na
var label labelTP3 = na

var bool tp1Active = false
var bool tp2Active = false
var bool tp3Active = false
````
