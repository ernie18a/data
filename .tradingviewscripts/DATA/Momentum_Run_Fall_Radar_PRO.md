<!-- tradingview-pine-id: PUB;806e00660ade4dfa86de9edc63acb4e1 -->
<!-- tradingviewscripts-format: 1 -->
# Momentum Run & Fall Radar PRO

Source: https://www.tradingview.com/script/cglFsQMG/

## Description

════════════════════════════════════════════
MOMENTUM RUN & FALL RADAR PRO
Version 2.1 – Responsive Dashboard
Beschreibung, Handhabung und Interpretation
DE-DE / EN-US
════════════════════════════════════════════

============================================================
DE-DE
============================================================

INHALTSVERZEICHNIS

01. Überblick
02. Neuerungen in Version 2.1
03. Verwendete Faktoren
04. EMA-Farben und Trendstruktur
05. Bull Score und Bear Score
06. Bullische Signalstufen
07. Bärische Signalstufen
08. „Fehlt Bull“ und „Fehlt Bear“
09. RSI
10. MACD
11. DMI / ADX
12. Relatives Volumen
13. Relative Stärke
14. Multi-Timeframe-Analyse
15. Widerstand und Support
16. ATR
17. RSI-Divergenzen
18. Retest
19. Dashboard-Modi: Desktop, Mobile und Minimal
20. Dashboard-Einstellungen
21. Empfohlene Verwendung und Zeitrahmen
22. Typischer bullischer Ablauf
23. Confirmed Mode und laufende Kerzen
24. Alarme
25. Statuszeile und kompakte Darstellung
26. Wichtiger Hinweis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
01. ÜBERBLICK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Der Momentum Run & Fall Radar PRO ist ein kombinierter technischer
Analyseindikator zur frühzeitigen Erkennung von Momentum-Aufbau,
Trendwechseln, Breakouts, Breakdowns und zunehmender Trendstärke.

Anstatt einzelne Indikatoren getrennt voneinander zu betrachten,
führt der Radar mehrere technische Faktoren zu einem Bull Score und
Bear Score von jeweils 0 bis 100 Punkten zusammen.

Damit lässt sich schneller erkennen, ob sich ein Aufwärts- oder
Abwärtstrend vorbereitet, ob ein Breakout oder Breakdown näher rückt,
ob eine Bewegung bereits bestätigt wurde oder ob bestehendes Momentum
an Stärke verliert.

Der Indikator eignet sich besonders für volatile Aktien und
Momentum-Titel, kann aber grundsätzlich auch für andere liquide
Aktien, ETFs und Märkte eingesetzt werden.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
02. NEUERUNGEN IN VERSION 2.1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Version 2.1 verbessert vor allem die Darstellung auf unterschiedlichen
Geräten.

Neu hinzugekommen sind:

• Desktop-Dashboard für große Bildschirme
• Mobile-Dashboard für Smartphone und Tablet
• Minimal-Dashboard für möglichst viel freien Chartbereich
• frei wählbare Dashboard-Position
• einstellbare Dashboard-Textgröße
• Dashboard-Sprache DE oder EN
• kompakter Indikatorname „Radar PRO“ in der Statuszeile
• Input-Werte werden nicht mehr in der Statuszeile angezeigt
• EMA-, Support-, Widerstands- und BB-Werte werden aus der
  Statuszeile ausgeblendet
• vollständige Erklärung der Relative-Stärke-Auswertung

Die grundlegende Analyse- und Scorelogik bleibt erhalten. Die
Hauptänderungen betreffen Bedienbarkeit und Darstellung.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
03. VERWENDETE FAKTOREN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Der Radar berücksichtigt unter anderem:

• EMA 9
• EMA 21
• EMA 50
• EMA 200
• EMA-Trend und EMA-Steigung
• frische EMA-Crossovers
• RSI 14 und RSI-Richtung
• MACD 12/26/9 und Histogramm-Entwicklung
• DMI / ADX
• relatives Handelsvolumen
• ATR
• 20-Kerzen-Breakouts und Breakdowns
• Support- und Widerstandsbereiche
• Bollinger-Band-Squeeze
• RSI-Divergenzen
• Breakout-Retests
• Relative Stärke gegenüber einer Benchmark
• Multi-Timeframe-Analyse über 4H, 1D und 1W

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
04. EMA-FARBEN UND TRENDSTRUKTUR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Türkis  = EMA 9
Gelb    = EMA 21
Orange  = EMA 50
Lila    = EMA 200

Eine vollständig bullische Trendstruktur sieht beispielsweise so aus:

Kurs > EMA 9 > EMA 21 > EMA 50 > EMA 200

Eine vollständig bärische Struktur entsprechend umgekehrt.

Für die Früherkennung ist besonders interessant, wenn EMA 9 und EMA 21
nach oben drehen und EMA 9 die EMA 21 von unten kreuzt.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
05. BULL SCORE UND BEAR SCORE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Bull Score = technische Stärke einer möglichen Aufwärtsbewegung.
Bear Score = technischer Abwärtsdruck.

Orientierung:

• 0–44   = kein klares Signal
• 45–54  = WATCH / Beobachtungsphase
• 55–64  = EARLY BULL bzw. EARLY BEAR
• 65–74  = BULL SETUP bzw. BEAR WARNING
• 75–84  = starke Bewegung / RUN- oder FALL-Bereich
• 85–100 = sehr starke technische Bestätigung

Wichtiger als ein einzelner Wert ist häufig die Entwicklung.

Beispiel:

45 → 54 → 61 → 69 → 77

Das zeigt, dass immer mehr technische Faktoren gleichzeitig bullisch
werden.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
06. BULLISCHE SIGNALSTUFEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WATCH
Erste positive Faktoren sind vorhanden.

EARLY BULL
Frühes bullisches Signal. Mehrere Faktoren beginnen sich positiv
auszurichten.

BULL SETUP
Der bullische Aufbau ist weiter fortgeschritten.

BREAKOUT
Ein relevanter Widerstand wurde überschritten.

RUN
Bestätigter bullischer Ausbruch mit ausreichend hohem Score,
Breakout und erhöhtem Handelsvolumen.

STRONG RUN
Sehr starke technische Bestätigung mit hohem Score, starkem Volumen
und ausgeprägter Trendstärke.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
07. BÄRISCHE SIGNALSTUFEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CAUTION / WATCH
Erste Verschlechterungen werden sichtbar.

EARLY BEAR
Frühe Anzeichen zunehmenden Abwärtsmomentums.

BEAR WARNING
Mehrere negative Faktoren bestätigen sich gleichzeitig.

BREAKDOWN
Eine wichtige Unterstützung wurde gebrochen.

FALL
Bestätigte Abwärtsbewegung.

STRONG FALL
Sehr starke technische Abwärtsbewegung.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
08. „FEHLT BULL“ UND „FEHLT BEAR“
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

„Fehlt Bull“ zeigt, welche Kernbedingungen für eine vollständigere
bullische Bestätigung noch fehlen.

Abkürzungen:

• EMA  = bullische EMA-Struktur fehlt
• RSI  = RSI-Bestätigung fehlt
• MACD = MACD-Bestätigung fehlt
• ADX  = DMI / Trendstärke fehlt
• VOL  = ausreichendes bullisches Volumen fehlt
• BO   = bestätigter Breakout fehlt
• MTF  = Multi-Timeframe-Bestätigung fehlt
• RS   = Relative Stärke fehlt

Beispiel:

Fehlt Bull: VOL BO

Dann sind viele Bedingungen bereits erfüllt; hauptsächlich fehlen
Volumen und Breakout.

„Fehlt Bear“ funktioniert entsprechend.

BD = bestätigter Breakdown fehlt.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
09. RSI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• unter 45 = eher bärisch
• 45–55    = neutral
• über 55  = bullisch
• 60–70    = starkes Momentum
• über 70  = starkes bzw. überkauftes Momentum

↑ = RSI verbessert sich
↓ = RSI schwächt sich ab

Ein RSI über 70 bedeutet nicht automatisch, dass der Kurs fallen muss.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
10. MACD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BULLISH / BULL
Der MACD unterstützt die Aufwärtsbewegung.

BEARISH / BEAR
Negative Momentumstruktur.

Besonders interessant sind Übergänge zwischen BEAR und BULL.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
11. DMI / ADX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

+DI vorne = bullische Richtung
-DI vorne = bärische Richtung

ADX:

• unter 15 = schwacher Trend
• 15–20    = Trend beginnt
• 20–25    = zunehmend relevant
• über 25  = starker Trend
• über 30  = sehr starker Trend

Besonders interessant für einen frühen Aufwärtstrend:

+DI vorne + steigender ADX durch 20–25.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
12. RELATIVES VOLUMEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1,00x  = durchschnittliches Volumen
1,20x  = erhöhtes Interesse
1,50x  = starkes Volumen
2,00x+ = sehr starke Aktivität

Ein Breakout mit hohem Volumen ist normalerweise stärker bestätigt
als ein Breakout bei schwachem Volumen.

Bei einer noch laufenden Kerze kann der Wert zunächst niedrig sein.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
13. RELATIVE STÄRKE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Die Relative Stärke vergleicht die Kursentwicklung mit einer
Benchmark.

Standardmäßig:

NASDAQ:QQQ

Mögliche Anzeigen:

STARK BULL / STRONG BULL
Die Aktie entwickelt sich stärker als die Benchmark und die relative
Stärke nimmt weiter zu.

BULL
Die Aktie entwickelt sich besser als die Benchmark.

BEAR
Die Aktie entwickelt sich schwächer.

STARK BEAR / STRONG BEAR
Die relative Schwäche nimmt weiter zu.

AUS / N/A
Die Auswertung ist deaktiviert oder nicht verfügbar.

Beispiel:

Aktie +3 %, Benchmark +5 %
→ relative Schwäche

Aktie +3 %, Benchmark 0 % oder negativ
→ relative Stärke

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
14. MULTI-TIMEFRAME-ANALYSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Standard:

240 = 4 Stunden
D   = Tageschart
W   = Wochenchart

Desktop:

240 BULL | D BULL | W NEUTRAL

Mobile:

4H↑ D↑ W–

↑ = bullisch
↓ = bärisch
– = neutral

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
15. WIDERSTAND UND SUPPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Widerstand = technisch relevanter Bereich oberhalb des Kurses.
Support = technisch relevanter Bereich unterhalb des Kurses.

Ein Kurs direkt unter dem Widerstand ist noch kein Breakout.

Stärkere Bestätigung entsteht durch:

• Überschreiten des Widerstands
• Kerzenschluss möglichst darüber
• zunehmendes Volumen
• bullische Momentumfaktoren

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
16. ATR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ATR misst die aktuelle Schwankungsbreite.

Der Radar verwendet ATR zusätzlich als Breakout-Puffer, damit ein
minimales Überschreiten eines Widerstands nicht sofort als bestätigter
Breakout gewertet wird.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
17. RSI-DIVERGENZEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BULLISH
Kurs bildet ein schwächeres Tief, während RSI relative Stärke zeigt.

BEARISH
Kurs bildet ein höheres Hoch, während RSI dieses Hoch nicht bestätigt.

Divergenzen sind Frühwarnsignale.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
18. RETEST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Typischer Ablauf:

Widerstand
→ Breakout
→ Rücklauf
→ alter Widerstand hält als Support
→ RETEST

Ein erfolgreicher Retest kann einen vorherigen Breakout zusätzlich
bestätigen.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
19. DASHBOARD-MODI: DESKTOP, MOBILE UND MINIMAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DESKTOP

Vollständige Anzeige mit:

• Status
• Bull / Bear Score
• EMA 9 / 21 / 50 / 200
• RSI
• MACD
• DMI / ADX
• Volumen
• BB Squeeze
• MTF
• Relative Stärke
• Widerstand / Support
• ATR
• Divergenz
• Fehlt Bull / Bear

Empfohlen für PC und Notebook.

MOBILE

Kompakte Anzeige mit:

• Gesamtstatus
• Bull / Bear Score
• EMA-Trend
• RSI
• MACD
• DMI / ADX
• Volumen
• kompaktes MTF
• Relative Stärke
• Widerstand / Support
• Fehlt Bull / Bear

Empfohlen für Smartphone und kleinere Tablets.

MINIMAL

Zeigt nur:

• Gesamtstatus
• Bull / Bear
• RSI / ADX
• MACD / Volumen
• MTF / Relative Stärke
• wichtigste fehlende Bedingungen

Empfohlen bei sehr wenig Bildschirmfläche.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
20. DASHBOARD-EINSTELLUNGEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Unter „13. Dashboard“:

Dashboard anzeigen
Ein / Aus

Dashboard-Modus
• Desktop
• Mobile
• Minimal

Dashboard-Sprache
• DE
• EN

Dashboard-Position
• Top Right
• Middle Right
• Bottom Right
• Top Left
• Middle Left
• Bottom Left

Dashboard-Textgröße
• Auto
• Tiny
• Small
• Normal

Empfehlung:

Desktop:
Desktop + Auto/Small

Smartphone:
Mobile + Auto

Sehr kleines Display:
Minimal + Auto/Tiny

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
21. EMPFOHLENE VERWENDUNG UND ZEITRAHMEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1H
Hauptanzeige für frühe Momentum-Signale.

4H
Trendbestätigung.

1D
Mittelfristige Bestätigung.

1W
Langfristige Einordnung.

15 Minuten
Kann für genaueres Timing genutzt werden, nachdem 1H/4H bereits ein
brauchbares Setup zeigen.

1 und 5 Minuten
Enthalten deutlich mehr Marktrauschen.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
22. TYPISCHER BULLISCHER ABLAUF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WATCH
↓
EARLY BULL
↓
Bull Score steigt
↓
EMA 9 / EMA 21 drehen nach oben
↓
RSI steigt über 55
↓
MACD wird bullisch
↓
+DI übernimmt
↓
ADX steigt
↓
BULL SETUP
↓
Fehlt Bull wird kürzer
↓
z. B. nur noch VOL BO
↓
Widerstand wird gebrochen
↓
Volumen steigt
↓
BREAKOUT
↓
RUN
↓
STRONG RUN

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
23. CONFIRMED MODE UND LAUFENDE KERZEN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Standardmäßig werden neue Signal-Labels erst bei Kerzenschluss
bestätigt.

Dashboardwerte können sich während der laufenden Kerze trotzdem
verändern.

Für wichtige Entscheidungen sollte deshalb der Kerzenschluss
berücksichtigt werden.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
24. ALARME
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Verfügbare Alarmbedingungen:

• Early Bull
• Bull Setup
• RUN
• STRONG RUN
• Early Bear
• Bear Warning
• FALL
• STRONG FALL
• Bull Retest
• Bear Retest
• Bullische RSI-Divergenz
• Bärische RSI-Divergenz

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
25. STATUSZEILE UND KOMPAKTE DARSTELLUNG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Version 2.1 blendet die langen Input- und Plotwerte aus der
TradingView-Statuszeile aus.

Statt:

9 21 50 200 3 5 14 55 ...

wird primär der kurze Name angezeigt:

Radar PRO

Die Einstellungen bleiben im Indikator-Menü vollständig verfügbar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
26. WICHTIGER HINWEIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Der Momentum Run & Fall Radar PRO ist ein Werkzeug zur technischen
Marktanalyse und kann zukünftige Kursbewegungen nicht sicher
vorhersagen.

Der Indikator stellt keine Anlageberatung und keine automatische
Kauf- oder Verkaufsempfehlung dar.

Zusätzlich berücksichtigt werden sollten unter anderem:

• persönliches Risikoprofil
• Positionsgröße
• fundamentale Unternehmensdaten
• Nachrichten und Ereignisse
• Quartalszahlen
• Liquidität
• allgemeine Marktsituation

============================================================
EN-US
============================================================

TABLE OF CONTENTS

01. Overview
02. What’s New in Version 2.1
03. Included Factors
04. EMA Colors and Trend Structure
05. Bull Score and Bear Score
06. Bullish Signal Stages
07. Bearish Signal Stages
08. Missing Bull and Missing Bear
09. RSI
10. MACD
11. DMI / ADX
12. Relative Volume
13. Relative Strength
14. Multi-Timeframe Analysis
15. Resistance and Support
16. ATR
17. RSI Divergence
18. Retest
19. Dashboard Modes: Desktop, Mobile and Minimal
20. Dashboard Settings
21. Recommended Use and Timeframes
22. Typical Bullish Development
23. Confirmed Mode and Open Candles
24. Alerts
25. Status Line and Compact Display
26. Important Notice

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
01. OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Momentum Run & Fall Radar PRO is a multi-factor technical analysis
indicator designed to identify early momentum development, trend
changes, breakouts, breakdowns and increasing trend strength.

It combines multiple technical factors into a Bull Score and Bear
Score ranging from 0 to 100.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
02. WHAT’S NEW IN VERSION 2.1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

New features:

• Desktop dashboard
• Mobile dashboard
• Minimal dashboard
• selectable dashboard position
• adjustable text size
• DE / EN dashboard language
• compact “Radar PRO” status-line title
• input values hidden from the status line
• EMA, support, resistance and Bollinger values hidden from the
  status line
• expanded Relative Strength documentation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
03. INCLUDED FACTORS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• EMA 9 / 21 / 50 / 200
• EMA trend and slope
• recent EMA crossovers
• RSI 14
• MACD 12/26/9
• DMI / ADX
• relative volume
• ATR
• 20-bar breakouts and breakdowns
• support and resistance
• Bollinger Band squeeze
• RSI divergences
• breakout retests
• Relative Strength versus a benchmark
• 4H / 1D / 1W Multi-Timeframe analysis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
04. EMA COLORS AND TREND STRUCTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Cyan   = EMA 9
Yellow = EMA 21
Orange = EMA 50
Purple = EMA 200

Bullish structure:

Price > EMA 9 > EMA 21 > EMA 50 > EMA 200

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
05. BULL SCORE AND BEAR SCORE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• 0–44   = no clear signal
• 45–54  = WATCH
• 55–64  = EARLY BULL / EARLY BEAR
• 65–74  = BULL SETUP / BEAR WARNING
• 75–84  = RUN / FALL territory
• 85–100 = very strong confirmation

The direction of the score is often more important than one isolated
reading.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
06. BULLISH SIGNAL STAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WATCH
Early positive conditions.

EARLY BULL
Early bullish momentum is developing.

BULL SETUP
The bullish structure is becoming more established.

BREAKOUT
Price moves above relevant resistance.

RUN
Confirmed bullish move with score, breakout and volume confirmation.

STRONG RUN
Very strong bullish confirmation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
07. BEARISH SIGNAL STAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CAUTION / WATCH
Early deterioration.

EARLY BEAR
Early downside momentum.

BEAR WARNING
Several bearish factors align.

BREAKDOWN
Support is broken.

FALL
Confirmed bearish move.

STRONG FALL
Very strong bearish trend.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
08. MISSING BULL AND MISSING BEAR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EMA  = EMA structure missing
RSI  = RSI confirmation missing
MACD = MACD confirmation missing
ADX  = DMI / trend strength missing
VOL  = sufficient volume missing
BO   = breakout missing
MTF  = multi-timeframe confirmation missing
RS   = Relative Strength missing

Example:

Missing Bull: VOL BO

Most bullish core conditions are already in place; volume and a
confirmed breakout remain missing.

BD = breakdown missing.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
09. RSI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• below 45 = bearish
• 45–55    = neutral
• above 55 = bullish
• 60–70    = strong momentum
• above 70 = strong / overbought momentum

↑ = strengthening
↓ = weakening

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
10. MACD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BULL / BULLISH = positive momentum structure.
BEAR / BEARISH = negative momentum structure.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
11. DMI / ADX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

+DI leading = bullish direction
-DI leading = bearish direction

ADX:

• below 15 = weak trend
• 15–20    = trend beginning
• 20–25    = increasingly relevant
• above 25 = strong trend
• above 30 = very strong trend

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
12. RELATIVE VOLUME
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1.00x  = average volume
1.20x  = increased activity
1.50x  = strong volume
2.00x+ = very strong participation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
13. RELATIVE STRENGTH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Default benchmark:

NASDAQ:QQQ

STRONG BULL
The instrument is outperforming the benchmark and relative strength
is improving.

BULL
Outperforming the benchmark.

BEAR
Underperforming the benchmark.

STRONG BEAR
Relative weakness is increasing.

OFF / N/A
Relative Strength analysis is disabled or unavailable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
14. MULTI-TIMEFRAME ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Default:

240 = 4-hour
D   = Daily
W   = Weekly

Desktop:

240 BULL | D BULL | W NEUTRAL

Mobile:

4H↑ D↑ W–

↑ = bullish
↓ = bearish
– = neutral

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
15. RESISTANCE AND SUPPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Resistance is a technically relevant level above price.
Support is a technically relevant level below price.

A stronger breakout is usually supported by a candle close above
resistance and increasing volume.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
16. ATR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ATR measures current trading range and volatility.

The radar uses ATR as an additional breakout buffer to reduce minor
false breakouts.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
17. RSI DIVERGENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BULLISH
Price forms a weaker low while RSI improves.

BEARISH
Price forms a higher high while RSI fails to confirm it.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
18. RETEST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Resistance
→ Breakout
→ Pullback
→ Previous resistance holds as support
→ RETEST

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
19. DASHBOARD MODES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DESKTOP
Full analysis for PCs and notebooks.

MOBILE
Compact analysis for smartphones and smaller tablets.

MINIMAL
Core information only for maximum chart space.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
20. DASHBOARD SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Dashboard Mode:
• Desktop
• Mobile
• Minimal

Language:
• DE
• EN

Position:
• Top Right
• Middle Right
• Bottom Right
• Top Left
• Middle Left
• Bottom Left

Text Size:
• Auto
• Tiny
• Small
• Normal

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
21. RECOMMENDED USE AND TIMEFRAMES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1H
Main timeframe for early momentum detection.

4H
Trend confirmation.

1D
Medium-term confirmation.

1W
Long-term context.

15 minutes
More precise timing after a valid higher-timeframe setup.

1-minute and 5-minute charts
Contain significantly more market noise.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
22. TYPICAL BULLISH DEVELOPMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WATCH
↓
EARLY BULL
↓
Bull Score rises
↓
EMA 9 / EMA 21 turn higher
↓
RSI > 55
↓
MACD turns bullish
↓
+DI takes control
↓
ADX rises
↓
BULL SETUP
↓
Missing Bull list becomes shorter
↓
Breakout
↓
RUN
↓
STRONG RUN

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
23. CONFIRMED MODE AND OPEN CANDLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Signal labels are confirmed at candle close by default.

Dashboard values may still change while the current candle is open.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
24. ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Available alert conditions include:

• Early Bull
• Bull Setup
• RUN
• STRONG RUN
• Early Bear
• Bear Warning
• FALL
• STRONG FALL
• Bull Retest
• Bear Retest
• Bullish RSI Divergence
• Bearish RSI Divergence

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
25. STATUS LINE AND COMPACT DISPLAY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Version 2.1 removes long input and plot values from the TradingView
status line.

The compact title is:

Radar PRO

All inputs remain available in the indicator settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
26. IMPORTANT NOTICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Momentum Run & Fall Radar PRO is a technical market analysis tool and
cannot reliably predict future price movements.

It does not constitute investment advice or an automatic buy or sell
recommendation.

---

## Source Code

````pine
//@version=6
indicator(
     "Momentum Run & Fall Radar PRO",
     shorttitle="Radar PRO",
     overlay=true,
     max_labels_count=500,
     max_lines_count=100,
     max_bars_back=1500
)

// ============================================================================
// MOMENTUM RUN & FALL RADAR PRO
// Version 2.2.1 - Responsive Dashboard + Breakout Target Engine (Grafik-Fix)
// ============================================================================

// 1. EMA / TREND
groupEMA = "1. EMA / Trend"
ema9Len   = input.int(9,   "EMA 9",   minval=1, group=groupEMA, display=display.none)
ema21Len  = input.int(21,  "EMA 21",  minval=1, group=groupEMA, display=display.none)
ema50Len  = input.int(50,  "EMA 50",  minval=1, group=groupEMA, display=display.none)
ema200Len = input.int(200, "EMA 200", minval=1, group=groupEMA, display=display.none)
slopeLookback = input.int(3, "EMA-Steigung – Vergleichskerzen", minval=1, maxval=20, group=groupEMA, display=display.none)
freshCrossBars = input.int(5, "EMA-Crossover gilt als frisch für", minval=1, maxval=20, group=groupEMA, display=display.none)
showEMAs = input.bool(true, "EMA-Linien anzeigen", group=groupEMA, display=display.none)

// 2. RSI
groupRSI = "2. RSI / Momentum"
rsiLen = input.int(14, "RSI Länge", minval=2, group=groupRSI, display=display.none)
rsiBullLevel = input.float(55.0, "Bullisch ab RSI", step=0.5, group=groupRSI, display=display.none)
rsiBearLevel = input.float(45.0, "Bärisch unter RSI", step=0.5, group=groupRSI, display=display.none)
rsiSlopeLookback = input.int(3, "RSI-Beschleunigung über Kerzen", minval=1, maxval=20, group=groupRSI, display=display.none)

// 3. MACD
groupMACD = "3. MACD"
macdFast = input.int(12, "MACD Fast", minval=1, group=groupMACD, display=display.none)
macdSlow = input.int(26, "MACD Slow", minval=2, group=groupMACD, display=display.none)
macdSignalLen = input.int(9, "MACD Signal", minval=1, group=groupMACD, display=display.none)

// 4. DMI / ADX
groupADX = "4. DMI / ADX"
dmiLen = input.int(14, "DMI Länge", minval=2, group=groupADX, display=display.none)
adxSmooth = input.int(14, "ADX Glättung", minval=2, group=groupADX, display=display.none)
adxMin = input.float(20.0, "Trend interessant ab ADX", step=0.5, group=groupADX, display=display.none)
strongAdx = input.float(25.0, "Starker Trend ab ADX", step=0.5, group=groupADX, display=display.none)

// 5. VOLUMEN
groupVOL = "5. Volumen"
volLen = input.int(20, "Volumen-Durchschnitt", minval=2, group=groupVOL, display=display.none)
elevatedVolRatio = input.float(1.20, "Erhöhtes Volumen", minval=1.0, step=0.05, group=groupVOL, display=display.none)
runVolRatio = input.float(1.50, "RUN/FALL Volumen", minval=1.0, step=0.05, group=groupVOL, display=display.none)
strongVolRatio = input.float(2.00, "STRONG RUN/FALL Volumen", minval=1.0, step=0.05, group=groupVOL, display=display.none)

// 6. ATR / BREAKOUT
groupBO = "6. ATR / Breakout / Marktstruktur"
atrLen = input.int(14, "ATR Länge", minval=2, group=groupBO, display=display.none)
breakoutLen = input.int(20, "Breakout-Zeitraum", minval=5, group=groupBO, display=display.none)
breakoutAtrBuffer = input.float(0.10, "Breakout-Bestätigung in ATR", minval=0.0, step=0.05, group=groupBO, display=display.none)
srLookback = input.int(50, "Support/Widerstand Lookback", minval=10, group=groupBO, display=display.none)
showStructure = input.bool(true, "Support / Widerstand anzeigen", group=groupBO, display=display.none)

// 7. BOLLINGER / VOLATILITÄT
groupBB = "7. Bollinger / Volatilität"
bbLen = input.int(20, "BB Länge", minval=2, group=groupBB, display=display.none)
bbMult = input.float(2.0, "BB Standardabweichung", minval=0.5, step=0.1, group=groupBB, display=display.none)
squeezeLookback = input.int(50, "Squeeze Vergleichszeitraum", minval=10, group=groupBB, display=display.none)
squeezeFactor = input.float(0.75, "Squeeze Faktor", minval=0.3, maxval=1.0, step=0.05, group=groupBB, display=display.none)
squeezeRecentBars = input.int(3, "Squeeze gilt nach für Kerzen", minval=1, maxval=20, group=groupBB, display=display.none)
showBB = input.bool(false, "Bollinger-Bänder anzeigen", group=groupBB, display=display.none)

// 8. MULTI-TIMEFRAME
groupMTF = "8. Multi-Timeframe"
useMTF = input.bool(true, "Multi-Timeframe-Analyse verwenden", group=groupMTF, display=display.none)
tfFast = input.timeframe("240", "Kurzfristig", group=groupMTF, display=display.none)
tfMain = input.timeframe("D", "Hauptzeitraum", group=groupMTF, display=display.none)
tfSlow = input.timeframe("W", "Langfristig", group=groupMTF, display=display.none)

// 9. RELATIVE STÄRKE
groupRS = "9. Relative Stärke"
useRelativeStrength = input.bool(true, "Relative Stärke berücksichtigen", group=groupRS, display=display.none)
benchmarkSymbol = input.symbol("NASDAQ:QQQ", "Benchmark", group=groupRS, display=display.none)
rsLen = input.int(20, "RS Durchschnitt", minval=2, group=groupRS, display=display.none)
rsSlopeLookback = input.int(3, "RS Beschleunigung", minval=1, maxval=20, group=groupRS, display=display.none)

// 10. DIVERGENZEN
groupDIV = "10. RSI-Divergenzen"
showDivergence = input.bool(true, "RSI-Divergenzen anzeigen", group=groupDIV, display=display.none)
pivotLen = input.int(5, "Pivot-Stärke", minval=2, maxval=20, group=groupDIV, display=display.none)
divergenceRecentBars = input.int(20, "Divergenz gilt als aktuell für", minval=5, maxval=100, group=groupDIV, display=display.none)

// 11. RETEST
groupRETEST = "11. Breakout-Retest"
showRetests = input.bool(true, "Retest-Signale anzeigen", group=groupRETEST, display=display.none)
retestWindow = input.int(10, "Retest-Fenster nach Breakout", minval=1, maxval=50, group=groupRETEST, display=display.none)
retestToleranceATR = input.float(0.25, "Retest-Toleranz ATR", minval=0.05, step=0.05, group=groupRETEST, display=display.none)

// 12. SCORE / SIGNALSTUFEN
groupSCORE = "12. Score / Signalstufen"
watchThreshold = input.float(45, "WATCH ab Score", minval=0, maxval=100, group=groupSCORE, display=display.none)
earlyThreshold = input.float(55, "EARLY SET/WARN ab Score", minval=0, maxval=100, group=groupSCORE, display=display.none)
setupThreshold = input.float(65, "SETUP/WARNING ab Score", minval=0, maxval=100, group=groupSCORE, display=display.none)
runThreshold = input.float(75, "RUN/FALL ab Score", minval=0, maxval=100, group=groupSCORE, display=display.none)
strongThreshold = input.float(85, "STRONG RUN/FALL ab Score", minval=0, maxval=100, group=groupSCORE, display=display.none)
signalOnCloseOnly = input.bool(true, "Signale nur bei Kerzenschluss bestätigen", group=groupSCORE, display=display.none)
signalCooldown = input.int(5, "Signal-Cooldown Kerzen", minval=0, maxval=50, group=groupSCORE, display=display.none)
showStateLabels = input.bool(true, "Signal-Labels anzeigen", group=groupSCORE, display=display.none)
showBackground = input.bool(false, "Score-Hintergrund anzeigen", group=groupSCORE, display=display.none)

// 13. DASHBOARD – RESPONSIVE
groupDASH = "13. Dashboard"
showDashboard = input.bool(true, "Dashboard anzeigen", group=groupDASH, display=display.none)
dashboardMode = input.string("Desktop", "Dashboard-Modus", options=["Desktop", "Mobile", "Minimal"], group=groupDASH, display=display.none)
dashboardLanguage = input.string("DE", "Dashboard-Sprache", options=["DE", "EN"], group=groupDASH, display=display.none)
dashboardPositionInput = input.string("Top Right", "Dashboard-Position", options=["Top Right","Middle Right","Bottom Right","Top Left","Middle Left","Bottom Left"], group=groupDASH, display=display.none)
dashboardTextInput = input.string("Auto", "Dashboard-Textgröße", options=["Auto","Tiny","Small","Normal"], group=groupDASH, display=display.none)

// 14. BREAKOUT TARGET ENGINE
groupTARGET = "14. Breakout Targets"
showTargets = input.bool(true, "Breakout-Ziele im Dashboard anzeigen", group=groupTARGET, display=display.none)
showTargetLines = input.bool(true, "Aktive Ziel-Linien im Chart anzeigen", group=groupTARGET, display=display.none)
targetPreviewBeforeBreakout = input.bool(true, "Zielvorschau vor Breakout anzeigen", group=groupTARGET, display=display.none)
targetRangeLookback = input.int(20, "Range für Zielprojektion", minval=5, maxval=250, group=groupTARGET, display=display.none)
targetT1Factor = input.float(0.50, "T1 Faktor – konservativ", minval=0.10, maxval=3.0, step=0.05, group=groupTARGET, display=display.none)
targetT2Factor = input.float(1.00, "T2 Faktor – Standardziel", minval=0.10, maxval=5.0, step=0.05, group=groupTARGET, display=display.none)
targetT3Factor = input.float(1.618, "T3 Faktor – aggressiv", minval=0.10, maxval=8.0, step=0.001, group=groupTARGET, display=display.none)
targetMinRangeATR = input.float(2.0, "Mindest-Range in ATR", minval=0.5, maxval=10.0, step=0.25, group=groupTARGET, display=display.none)
targetInvalidATR = input.float(0.50, "Invalidierung hinter BO/BD in ATR", minval=0.10, maxval=5.0, step=0.10, group=groupTARGET, display=display.none)
targetHistoryLookback = input.int(250, "Historische Zielsuche – Kerzen", minval=50, maxval=1000, group=groupTARGET, display=display.none)


// ============================================================================
// HILFSFUNKTIONEN
// ============================================================================

f_fmt1(_v) => na(_v) ? "n/a" : str.tostring(_v, "#.0")
f_fmt2(_v) => na(_v) ? "n/a" : str.tostring(_v, "#.00")
f_deen(_de, _en) => dashboardLanguage == "DE" ? _de : _en

f_mtfText(_state) => _state == 1 ? "BULL" : _state == -1 ? "BEAR" : "NEUTRAL"
f_mtfArrow(_state) => _state == 1 ? "↑" : _state == -1 ? "↓" : "–"
f_tfLabel(_tf) => _tf == "240" ? "4H" : _tf == "60" ? "1H" : _tf == "D" ? "D" : _tf == "W" ? "W" : _tf
f_bullStateText(_state) => _state == 6 ? "STRONG RUN" : _state == 5 ? "RUN" : _state == 4 ? "BREAKOUT" : _state == 3 ? "SETUP" : _state == 2 ? "EARLY SET" : _state == 1 ? "WATCH" : "NEUTRAL"
f_bearStateText(_state) => _state == 6 ? "STRONG FALL" : _state == 5 ? "FALL" : _state == 4 ? "BREAKDOWN" : _state == 3 ? "WARNING" : _state == 2 ? "EARLY WARN" : _state == 1 ? "CAUTION" : "NEUTRAL"
f_bullColor(_state) => _state >= 6 ? color.lime : _state >= 5 ? color.green : _state >= 3 ? color.new(color.green, 20) : _state >= 2 ? color.teal : color.gray
f_bearColor(_state) => _state >= 6 ? color.red : _state >= 5 ? color.maroon : _state >= 3 ? color.orange : _state >= 2 ? color.new(color.orange, 10) : color.gray
f_dashboardPosition(_p) => _p == "Middle Right" ? position.middle_right : _p == "Bottom Right" ? position.bottom_right : _p == "Top Left" ? position.top_left : _p == "Middle Left" ? position.middle_left : _p == "Bottom Left" ? position.bottom_left : position.top_right
f_dashboardSize(_mode, _setting) => _setting == "Tiny" ? size.tiny : _setting == "Small" ? size.small : _setting == "Normal" ? size.normal : _mode == "Desktop" ? size.small : size.tiny
f_remainingPct(_dir, _target) => na(_target) or close == 0 ? na : _dir == 1 ? math.max(0.0, (_target - close) / close * 100.0) : math.max(0.0, (close - _target) / close * 100.0)
f_targetDirText(_dir, _preview) => _dir == 1 ? (_preview ? f_deen("BULL VORSCHAU", "BULL PREVIEW") : f_deen("BULL AKTIV", "BULL ACTIVE")) : (_preview ? f_deen("BEAR VORSCHAU", "BEAR PREVIEW") : f_deen("BEAR AKTIV", "BEAR ACTIVE"))


// ============================================================================
// BERECHNUNGEN
// ============================================================================

// EMA
ema9 = ta.ema(close, ema9Len)
ema21 = ta.ema(close, ema21Len)
ema50 = ta.ema(close, ema50Len)
ema200 = ta.ema(close, ema200Len)

ema9Rising = ema9 > ema9[slopeLookback]
ema21Rising = ema21 > ema21[slopeLookback]
ema9Falling = ema9 < ema9[slopeLookback]
ema21Falling = ema21 < ema21[slopeLookback]

bullCross = ta.crossover(ema9, ema21)
bearCross = ta.crossunder(ema9, ema21)
barsSinceBullCross = ta.barssince(bullCross)
barsSinceBearCross = ta.barssince(bearCross)
freshBullCross = not na(barsSinceBullCross) and barsSinceBullCross <= freshCrossBars
freshBearCross = not na(barsSinceBearCross) and barsSinceBearCross <= freshCrossBars

// RSI
rsi = ta.rsi(close, rsiLen)
rsiRising = rsi > rsi[rsiSlopeLookback]
rsiFalling = rsi < rsi[rsiSlopeLookback]

// MACD
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignalLen)
macdHistRising = macdHist > macdHist[1]
macdHistFalling = macdHist < macdHist[1]

// DMI / ADX
[plusDI, minusDI, adx] = ta.dmi(dmiLen, adxSmooth)
adxRising = adx > adx[1]

// ATR
atr = ta.atr(atrLen)
atrPct = close != 0 ? atr / close * 100 : na

// Volumen
volAverage = ta.sma(volume, volLen)
volumeAvailable = not na(volAverage) and volAverage > 0
volRatio = volumeAvailable ? volume / volAverage : na
bullVolDirection = close > open and close > close[1]
bearVolDirection = close < open and close < close[1]

// Bollinger
bbBasis = ta.sma(close, bbLen)
bbDeviation = bbMult * ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDeviation
bbLower = bbBasis - bbDeviation
bbWidth = bbBasis != 0 ? (bbUpper - bbLower) / bbBasis : na
bbWidthAverage = ta.sma(bbWidth, squeezeLookback)
bbSqueeze = not na(bbWidthAverage) and bbWidth < bbWidthAverage * squeezeFactor
barsSinceSqueeze = ta.barssince(bbSqueeze)
squeezeRecent = not na(barsSinceSqueeze) and barsSinceSqueeze <= squeezeRecentBars
bbExpansion = bbWidth > bbWidth[1]

// Breakout / Breakdown
breakoutHigh = ta.highest(high, breakoutLen)[1]
breakoutLow = ta.lowest(low, breakoutLen)[1]
bullBreakoutRaw = not na(breakoutHigh) and close > breakoutHigh
bearBreakoutRaw = not na(breakoutLow) and close < breakoutLow
bullBreakout = not na(breakoutHigh) and not na(atr) and close > breakoutHigh + atr * breakoutAtrBuffer
bearBreakout = not na(breakoutLow) and not na(atr) and close < breakoutLow - atr * breakoutAtrBuffer
distResistanceATR = not na(atr) and atr > 0 and not na(breakoutHigh) ? (breakoutHigh - close) / atr : na
distSupportATR = not na(atr) and atr > 0 and not na(breakoutLow) ? (close - breakoutLow) / atr : na

// Support / Widerstand
resistance = ta.highest(high, srLookback)[1]
support = ta.lowest(low, srLookback)[1]

// Zielprojektion – Range. Historische Ziele werden erst beim bestätigten BO/BD gesucht.
targetRangeHigh = ta.highest(high, targetRangeLookback)[1]
targetRangeLow = ta.lowest(low, targetRangeLookback)[1]
targetRangeRaw = not na(targetRangeHigh) and not na(targetRangeLow) ? targetRangeHigh - targetRangeLow : na
targetRangeFloor = not na(atr) ? atr * targetMinRangeATR : na
projectedTargetRange = not na(targetRangeRaw) and not na(targetRangeFloor) ? math.max(targetRangeRaw, targetRangeFloor) : targetRangeRaw
float projectedHistResistance = na
float projectedHistSupport = na

// MTF
f_mtfState() =>
    _ema9 = ta.ema(close, ema9Len)
    _ema21 = ta.ema(close, ema21Len)
    _rsi = ta.rsi(close, rsiLen)
    _bull = close > _ema21 and _ema9 > _ema21 and _rsi > 50
    _bear = close < _ema21 and _ema9 < _ema21 and _rsi < 50
    _bull ? 1 : _bear ? -1 : 0

mtfFast = request.security(syminfo.tickerid, tfFast, f_mtfState(), barmerge.gaps_off, barmerge.lookahead_off)
mtfMain = request.security(syminfo.tickerid, tfMain, f_mtfState(), barmerge.gaps_off, barmerge.lookahead_off)
mtfSlow = request.security(syminfo.tickerid, tfSlow, f_mtfState(), barmerge.gaps_off, barmerge.lookahead_off)

bullMtfCount = (mtfFast == 1 ? 1.0 : 0.0) + (mtfMain == 1 ? 1.0 : 0.0) + (mtfSlow == 1 ? 1.0 : 0.0)
bearMtfCount = (mtfFast == -1 ? 1.0 : 0.0) + (mtfMain == -1 ? 1.0 : 0.0) + (mtfSlow == -1 ? 1.0 : 0.0)
bullMtfScore = useMTF ? bullMtfCount / 3.0 * 10.0 : 0.0
bearMtfScore = useMTF ? bearMtfCount / 3.0 * 10.0 : 0.0

// Relative Stärke
benchmarkClose = request.security(benchmarkSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
rsAvailable = useRelativeStrength and not na(benchmarkClose) and benchmarkClose != 0
rsRatio = rsAvailable ? close / benchmarkClose : na
rsEMA = ta.ema(rsRatio, rsLen)
rsBull = rsAvailable and rsRatio > rsEMA
rsBear = rsAvailable and rsRatio < rsEMA
rsRising = rsAvailable and rsRatio > rsRatio[rsSlopeLookback]
rsFalling = rsAvailable and rsRatio < rsRatio[rsSlopeLookback]

// Divergenzen
pricePivotLow = ta.pivotlow(low, pivotLen, pivotLen)
pricePivotHigh = ta.pivothigh(high, pivotLen, pivotLen)

var float previousPivotLowPrice = na
var float previousPivotLowRSI = na
var float previousPivotHighPrice = na
var float previousPivotHighRSI = na

bool bullDivergence = false
bool bearDivergence = false

if not na(pricePivotLow)
    currentPivotLowPrice = pricePivotLow
    currentPivotLowRSI = rsi[pivotLen]
    bullDivergence := not na(previousPivotLowPrice) and currentPivotLowPrice < previousPivotLowPrice and currentPivotLowRSI > previousPivotLowRSI
    previousPivotLowPrice := currentPivotLowPrice
    previousPivotLowRSI := currentPivotLowRSI

if not na(pricePivotHigh)
    currentPivotHighPrice = pricePivotHigh
    currentPivotHighRSI = rsi[pivotLen]
    bearDivergence := not na(previousPivotHighPrice) and currentPivotHighPrice > previousPivotHighPrice and currentPivotHighRSI < previousPivotHighRSI
    previousPivotHighPrice := currentPivotHighPrice
    previousPivotHighRSI := currentPivotHighRSI

var int lastBullDivBar = na
var int lastBearDivBar = na
if bullDivergence
    lastBullDivBar := bar_index - pivotLen
if bearDivergence
    lastBearDivBar := bar_index - pivotLen

recentBullDivergence = not na(lastBullDivBar) and bar_index - lastBullDivBar <= divergenceRecentBars
recentBearDivergence = not na(lastBearDivBar) and bar_index - lastBearDivBar <= divergenceRecentBars

// Scores
bullTrendScore = (close > ema21 ? 3.0 : 0.0) + (ema9 > ema21 ? 4.0 : 0.0) + (ema21 > ema50 ? 4.0 : 0.0) + (ema50 > ema200 ? 4.0 : 0.0) + (ema9Rising and ema21Rising ? 3.0 : 0.0) + (freshBullCross ? 2.0 : 0.0)

bearTrendScore = (close < ema21 ? 3.0 : 0.0) + (ema9 < ema21 ? 4.0 : 0.0) + (ema21 < ema50 ? 4.0 : 0.0) + (ema50 < ema200 ? 4.0 : 0.0) + (ema9Falling and ema21Falling ? 3.0 : 0.0) + (freshBearCross ? 2.0 : 0.0)

bullRsiScore = (rsi >= rsiBullLevel ? 6.0 : 0.0) + (rsiRising ? 4.0 : 0.0)
bearRsiScore = (rsi <= rsiBearLevel ? 6.0 : 0.0) + (rsiFalling ? 4.0 : 0.0)

bullMacdScore = (macdLine > macdSignal ? 4.0 : 0.0) + (macdHist > 0 ? 3.0 : 0.0) + (macdHistRising ? 3.0 : 0.0)
bearMacdScore = (macdLine < macdSignal ? 4.0 : 0.0) + (macdHist < 0 ? 3.0 : 0.0) + (macdHistFalling ? 3.0 : 0.0)

bullDmiScore = (plusDI > minusDI ? 4.0 : 0.0) + (plusDI > minusDI and adx >= adxMin ? 3.0 : 0.0) + (plusDI > minusDI and adxRising ? 3.0 : 0.0)
bearDmiScore = (minusDI > plusDI ? 4.0 : 0.0) + (minusDI > plusDI and adx >= adxMin ? 3.0 : 0.0) + (minusDI > plusDI and adxRising ? 3.0 : 0.0)

bullVolScore = not volumeAvailable ? 0.0 : bullVolDirection ? (volRatio >= strongVolRatio ? 15.0 : volRatio >= runVolRatio ? 12.0 : volRatio >= elevatedVolRatio ? 8.0 : 3.0) : 0.0

bearVolScore = not volumeAvailable ? 0.0 : bearVolDirection ? (volRatio >= strongVolRatio ? 15.0 : volRatio >= runVolRatio ? 12.0 : volRatio >= elevatedVolRatio ? 8.0 : 3.0) : 0.0

bullStructureScore = bullBreakout ? 15.0 : bullBreakoutRaw ? 12.0 : not na(distResistanceATR) and distResistanceATR <= 0.25 ? 9.0 : not na(distResistanceATR) and distResistanceATR <= 0.50 ? 6.0 : not na(distResistanceATR) and distResistanceATR <= 1.00 ? 3.0 : 0.0

bearStructureScore = bearBreakout ? 15.0 : bearBreakoutRaw ? 12.0 : not na(distSupportATR) and distSupportATR <= 0.25 ? 9.0 : not na(distSupportATR) and distSupportATR <= 0.50 ? 6.0 : not na(distSupportATR) and distSupportATR <= 1.00 ? 3.0 : 0.0

bullVolatilityScore = squeezeRecent and bbExpansion and close > bbBasis ? 5.0 : bbSqueeze ? 3.0 : bbExpansion and close > bbBasis ? 2.0 : 0.0

bearVolatilityScore = squeezeRecent and bbExpansion and close < bbBasis ? 5.0 : bbSqueeze ? 3.0 : bbExpansion and close < bbBasis ? 2.0 : 0.0

bullRsScore = not rsAvailable ? 0.0 : (rsBull ? 3.0 : 0.0) + (rsRising ? 2.0 : 0.0)
bearRsScore = not rsAvailable ? 0.0 : (rsBear ? 3.0 : 0.0) + (rsFalling ? 2.0 : 0.0)

activeMaximum = 70.0 + (volumeAvailable ? 15.0 : 0.0) + (useMTF ? 10.0 : 0.0) + (rsAvailable ? 5.0 : 0.0)

bullRawScore = bullTrendScore + bullRsiScore + bullMacdScore + bullDmiScore + bullVolScore + bullStructureScore + bullVolatilityScore + bullMtfScore + bullRsScore
bearRawScore = bearTrendScore + bearRsiScore + bearMacdScore + bearDmiScore + bearVolScore + bearStructureScore + bearVolatilityScore + bearMtfScore + bearRsScore

bullScore = activeMaximum > 0 ? math.min(100.0, bullRawScore / activeMaximum * 100.0) : 0.0
bearScore = activeMaximum > 0 ? math.min(100.0, bearRawScore / activeMaximum * 100.0) : 0.0

// RUN / FALL
bullRunCondition = bullScore >= runThreshold and bullBreakout and volumeAvailable and volRatio >= runVolRatio and bullVolDirection
bearRunCondition = bearScore >= runThreshold and bearBreakout and volumeAvailable and volRatio >= runVolRatio and bearVolDirection

bullStrongCondition = bullScore >= strongThreshold and bullBreakout and volumeAvailable and volRatio >= strongVolRatio and plusDI > minusDI and adx >= strongAdx
bearStrongCondition = bearScore >= strongThreshold and bearBreakout and volumeAvailable and volRatio >= strongVolRatio and minusDI > plusDI and adx >= strongAdx

int bullState = bullStrongCondition ? 6 : bullRunCondition ? 5 : bullBreakoutRaw and bullScore >= setupThreshold ? 4 : bullScore >= setupThreshold ? 3 : bullScore >= earlyThreshold ? 2 : bullScore >= watchThreshold ? 1 : 0

int bearState = bearStrongCondition ? 6 : bearRunCondition ? 5 : bearBreakoutRaw and bearScore >= setupThreshold ? 4 : bearScore >= setupThreshold ? 3 : bearScore >= earlyThreshold ? 2 : bearScore >= watchThreshold ? 1 : 0

string overallStatus = bullStrongCondition ? "STRONG RUN" : bearStrongCondition ? "STRONG FALL" : bullRunCondition ? "RUN" : bearRunCondition ? "FALL" : bullState >= 4 and bullScore > bearScore ? "BREAKOUT" : bearState >= 4 and bearScore > bullScore ? "BREAKDOWN" : bullState >= 3 and bullScore > bearScore + 5 ? "BULL SETUP" : bearState >= 3 and bearScore > bullScore + 5 ? "BEAR WARNING" : bullState >= 2 and bullScore > bearScore + 5 ? "EARLY BULL" : bearState >= 2 and bearScore > bullScore + 5 ? "EARLY BEAR" : "NEUTRAL"

color overallColor = bullStrongCondition ? color.lime : bearStrongCondition ? color.red : bullRunCondition ? color.green : bearRunCondition ? color.maroon : bullScore >= setupThreshold and bullScore > bearScore ? color.teal : bearScore >= setupThreshold and bearScore > bullScore ? color.orange : color.gray

// Retest
bullBreakoutEvent = bullBreakout and not bullBreakout[1]
bearBreakoutEvent = bearBreakout and not bearBreakout[1]

var int lastBullBreakoutBar = na
var float lastBullBreakoutLevel = na
var int lastBearBreakoutBar = na
var float lastBearBreakoutLevel = na

// Aktive Breakout-Target-Projektion wird beim bestätigten BO/BD eingefroren.
var int activeTargetDirection = 0
var int activeTargetStartBar = na
var float activeTargetBase = na
var float activeTargetRange = na
var float activeTargetATR = na
var float activeTargetHistLevel = na
var bool activeTargetInvalidated = false

// Nur die aktuellste aktive Zielprojektion wird als Linienobjekt dargestellt.
// Dadurch entstehen keine historischen Treppen-/Sprunglinien mehr im Chart.
var line targetLineT1 = na
var line targetLineT2 = na
var line targetLineT3 = na

if bullBreakoutEvent
    lastBullBreakoutBar := bar_index
    lastBullBreakoutLevel := breakoutHigh
    activeTargetDirection := 1
    activeTargetStartBar := bar_index
    activeTargetBase := breakoutHigh
    activeTargetRange := projectedTargetRange
    activeTargetATR := atr
    float bullHistCandidate = na
    for i = 1 to targetHistoryLookback
        if i > breakoutLen and not na(high[i]) and high[i] > breakoutHigh
            bullHistCandidate := na(bullHistCandidate) ? high[i] : math.min(bullHistCandidate, high[i])
    activeTargetHistLevel := bullHistCandidate
    activeTargetInvalidated := false

if bearBreakoutEvent
    lastBearBreakoutBar := bar_index
    lastBearBreakoutLevel := breakoutLow
    activeTargetDirection := -1
    activeTargetStartBar := bar_index
    activeTargetBase := breakoutLow
    activeTargetRange := projectedTargetRange
    activeTargetATR := atr
    float bearHistCandidate = na
    for i = 1 to targetHistoryLookback
        if i > breakoutLen and not na(low[i]) and low[i] < breakoutLow
            bearHistCandidate := na(bearHistCandidate) ? low[i] : math.max(bearHistCandidate, low[i])
    activeTargetHistLevel := bearHistCandidate
    activeTargetInvalidated := false

if activeTargetDirection == 1 and not activeTargetInvalidated and not na(activeTargetBase) and not na(activeTargetATR) and close < activeTargetBase - activeTargetATR * targetInvalidATR
    activeTargetInvalidated := true

if activeTargetDirection == -1 and not activeTargetInvalidated and not na(activeTargetBase) and not na(activeTargetATR) and close > activeTargetBase + activeTargetATR * targetInvalidATR
    activeTargetInvalidated := true

bullRetest = not na(lastBullBreakoutBar) and not na(lastBullBreakoutLevel) and bar_index > lastBullBreakoutBar and bar_index - lastBullBreakoutBar <= retestWindow and low <= lastBullBreakoutLevel + atr * retestToleranceATR and close >= lastBullBreakoutLevel
bearRetest = not na(lastBearBreakoutBar) and not na(lastBearBreakoutLevel) and bar_index > lastBearBreakoutBar and bar_index - lastBearBreakoutBar <= retestWindow and high >= lastBearBreakoutLevel - atr * retestToleranceATR and close <= lastBearBreakoutLevel

bullRetestHeld = bullRetest and close > open
bearRetestHeld = bearRetest and close < open
bullRetestSignal = bullRetestHeld and not bullRetestHeld[1]
bearRetestSignal = bearRetestHeld and not bearRetestHeld[1]

// ============================================================================
// BREAKOUT TARGET ENGINE
// ============================================================================

previewTargetDirection = bullScore >= bearScore ? 1 : -1
targetIsPreview = activeTargetDirection == 0
targetDisplayDirection = activeTargetDirection != 0 ? activeTargetDirection : previewTargetDirection
targetDisplayBase = activeTargetDirection != 0 ? activeTargetBase : targetDisplayDirection == 1 ? breakoutHigh : breakoutLow
targetDisplayRange = activeTargetDirection != 0 ? activeTargetRange : projectedTargetRange
targetDisplayATR = activeTargetDirection != 0 ? activeTargetATR : atr
targetDisplayHist = activeTargetDirection != 0 ? activeTargetHistLevel : targetDisplayDirection == 1 ? projectedHistResistance : projectedHistSupport
targetPreviewAllowed = targetPreviewBeforeBreakout or activeTargetDirection != 0
targetValuesAvailable = showTargets and targetPreviewAllowed and not na(targetDisplayBase) and not na(targetDisplayRange)

targetT1 = targetValuesAvailable ? targetDisplayDirection == 1 ? targetDisplayBase + targetDisplayRange * targetT1Factor : targetDisplayBase - targetDisplayRange * targetT1Factor : na
targetT2 = targetValuesAvailable ? targetDisplayDirection == 1 ? targetDisplayBase + targetDisplayRange * targetT2Factor : targetDisplayBase - targetDisplayRange * targetT2Factor : na
targetT3 = targetValuesAvailable ? targetDisplayDirection == 1 ? targetDisplayBase + targetDisplayRange * targetT3Factor : targetDisplayBase - targetDisplayRange * targetT3Factor : na
targetATR2 = targetValuesAvailable and not na(targetDisplayATR) ? targetDisplayDirection == 1 ? targetDisplayBase + targetDisplayATR * 2.0 : targetDisplayBase - targetDisplayATR * 2.0 : na

targetT1Reached = activeTargetDirection != 0 and not activeTargetInvalidated and (activeTargetDirection == 1 ? high >= targetT1 : low <= targetT1)
targetT2Reached = activeTargetDirection != 0 and not activeTargetInvalidated and (activeTargetDirection == 1 ? high >= targetT2 : low <= targetT2)
targetT3Reached = activeTargetDirection != 0 and not activeTargetInvalidated and (activeTargetDirection == 1 ? high >= targetT3 : low <= targetT3)

targetBullStrong = bullScore >= strongThreshold and plusDI > minusDI and adx >= strongAdx and volumeAvailable and volRatio >= strongVolRatio and bullMtfCount >= 2 and (not rsAvailable or rsBull)
targetBullStandard = bullScore >= runThreshold and plusDI > minusDI and adx >= adxMin and volumeAvailable and volRatio >= runVolRatio
targetBullConservative = bullScore >= setupThreshold and plusDI > minusDI
targetBearStrong = bearScore >= strongThreshold and minusDI > plusDI and adx >= strongAdx and volumeAvailable and volRatio >= strongVolRatio and bearMtfCount >= 2 and (not rsAvailable or rsBear)
targetBearStandard = bearScore >= runThreshold and minusDI > plusDI and adx >= adxMin and volumeAvailable and volRatio >= runVolRatio
targetBearConservative = bearScore >= setupThreshold and minusDI > plusDI

string targetFocus = activeTargetInvalidated ? f_deen("INVALID", "INVALID") : targetDisplayDirection == 1 ? (targetBullStrong ? "T3 AGGR." : targetBullStandard ? "T2 STANDARD" : targetBullConservative ? "T1 CONS." : f_deen("BEOBACHTEN", "WATCH")) : (targetBearStrong ? "T3 AGGR." : targetBearStandard ? "T2 STANDARD" : targetBearConservative ? "T1 CONS." : f_deen("BEOBACHTEN", "WATCH"))
string targetStatus = activeTargetInvalidated ? f_deen("INVALIDIERT", "INVALIDATED") : targetIsPreview ? f_deen("VORSCHAU", "PREVIEW") : targetT3Reached ? f_deen("T3 ERREICHT", "T3 REACHED") : targetT2Reached ? f_deen("T2 ERREICHT", "T2 REACHED") : targetT1Reached ? f_deen("T1 ERREICHT", "T1 REACHED") : f_deen("AKTIV", "ACTIVE")

targetRemainingT1 = f_remainingPct(targetDisplayDirection, targetT1)
targetRemainingT2 = f_remainingPct(targetDisplayDirection, targetT2)
targetRemainingT3 = f_remainingPct(targetDisplayDirection, targetT3)

string targetDirText = f_targetDirText(targetDisplayDirection, targetIsPreview)
string targetT1Text = na(targetT1) ? "n/a" : f_fmt2(targetT1) + " | " + f_fmt1(targetRemainingT1) + "%"
string targetT2Text = na(targetT2) ? "n/a" : f_fmt2(targetT2) + " | " + f_fmt1(targetRemainingT2) + "%"
string targetT3Text = na(targetT3) ? "n/a" : f_fmt2(targetT3) + " | " + f_fmt1(targetRemainingT3) + "%"
string targetHistText = na(targetDisplayHist) ? "n/a" : f_fmt2(targetDisplayHist)

// ============================================================================
// TARGET-LINIEN – NUR AKTUELLE PROJEKTION
// ============================================================================

// plot()-Serien würden alle historischen Zielwechsel miteinander darstellen.
// Deshalb werden T1/T2/T3 als löschbare line-Objekte gezeichnet.
// Bei einem neuen Breakout/Breakdown wird die alte Projektion entfernt.
newTargetProjection = bullBreakoutEvent or bearBreakoutEvent

if newTargetProjection
    if not na(targetLineT1)
        line.delete(targetLineT1)
    if not na(targetLineT2)
        line.delete(targetLineT2)
    if not na(targetLineT3)
        line.delete(targetLineT3)

    targetLineT1 := na
    targetLineT2 := na
    targetLineT3 := na

    if showTargets and showTargetLines and not activeTargetInvalidated and not na(activeTargetStartBar) and not na(targetT1) and not na(targetT2) and not na(targetT3)
        targetLineT1 := line.new(activeTargetStartBar, targetT1, activeTargetStartBar + 1, targetT1, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.yellow, 20), style=line.style_dashed, width=1)
        targetLineT2 := line.new(activeTargetStartBar, targetT2, activeTargetStartBar + 1, targetT2, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.lime, 15), style=line.style_solid, width=2)
        targetLineT3 := line.new(activeTargetStartBar, targetT3, activeTargetStartBar + 1, targetT3, xloc=xloc.bar_index, extend=extend.right, color=color.new(color.aqua, 15), style=line.style_dotted, width=1)

// Bei Invalidierung oder ausgeschalteter Zielanzeige aktuelle Linien entfernen.
if activeTargetInvalidated or not showTargets or not showTargetLines
    if not na(targetLineT1)
        line.delete(targetLineT1)
        targetLineT1 := na
    if not na(targetLineT2)
        line.delete(targetLineT2)
        targetLineT2 := na
    if not na(targetLineT3)
        line.delete(targetLineT3)
        targetLineT3 := na

// Signal-Cooldown
signalReady = not signalOnCloseOnly or barstate.isconfirmed
var int lastBullSignalBar = na
var int lastBearSignalBar = na

bullCooldownReady = na(lastBullSignalBar) or bar_index - lastBullSignalBar >= signalCooldown
bearCooldownReady = na(lastBearSignalBar) or bar_index - lastBearSignalBar >= signalCooldown

bullStateUpgrade = bullState > nz(bullState[1], 0)
bearStateUpgrade = bearState > nz(bearState[1], 0)

bullStateSignal = signalReady and bullStateUpgrade and bullState >= 2 and bullCooldownReady
bearStateSignal = signalReady and bearStateUpgrade and bearState >= 2 and bearCooldownReady

if showStateLabels and bullStateSignal
    string confirmationText = signalOnCloseOnly ? "CONF " : barstate.isconfirmed ? "CONF " : "LIVE "
    label.new(
         bar_index,
         low - atr * 0.25,
         confirmationText + f_bullStateText(bullState) + "\n" + f_fmt1(bullScore),
         style=label.style_label_up,
         textcolor=color.white,
         color=f_bullColor(bullState),
         size=size.small
     )
    lastBullSignalBar := bar_index

if showStateLabels and bearStateSignal
    string confirmationText = signalOnCloseOnly ? "CONF " : barstate.isconfirmed ? "CONF " : "LIVE "
    label.new(
         bar_index,
         high + atr * 0.25,
         confirmationText + f_bearStateText(bearState) + "\n" + f_fmt1(bearScore),
         style=label.style_label_down,
         textcolor=color.white,
         color=f_bearColor(bearState),
         size=size.small
     )
    lastBearSignalBar := bar_index

// PLOTS – Statuszeile bereinigt
plot(showEMAs ? ema9 : na, title="EMA 9", color=color.aqua, linewidth=1, display=display.all - display.status_line)
plot(showEMAs ? ema21 : na, title="EMA 21", color=color.yellow, linewidth=2, display=display.all - display.status_line)
plot(showEMAs ? ema50 : na, title="EMA 50", color=color.orange, linewidth=2, display=display.all - display.status_line)
plot(showEMAs ? ema200 : na, title="EMA 200", color=color.purple, linewidth=3, display=display.all - display.status_line)

plot(showStructure ? resistance : na, title="Widerstand", color=color.new(color.red, 65), linewidth=1, style=plot.style_linebr, display=display.all - display.status_line)
plot(showStructure ? support : na, title="Support", color=color.new(color.green, 65), linewidth=1, style=plot.style_linebr, display=display.all - display.status_line)

plot(showBB ? bbUpper : na, title="BB Oben", color=color.new(color.gray, 60), display=display.all - display.status_line)
plot(showBB ? bbBasis : na, title="BB Mitte", color=color.new(color.gray, 75), display=display.all - display.status_line)
plot(showBB ? bbLower : na, title="BB Unten", color=color.new(color.gray, 60), display=display.all - display.status_line)

// T1/T2/T3 werden oben als line-Objekte gezeichnet.
// Dadurch bleibt nur die aktuellste Projektion sichtbar und der Chart bleibt sauber.

plotshape(showDivergence and bullDivergence, title="Bullische RSI Divergenz", style=shape.triangleup, location=location.belowbar, offset=-pivotLen, color=color.lime, size=size.tiny, text="DIV")
plotshape(showDivergence and bearDivergence, title="Bärische RSI Divergenz", style=shape.triangledown, location=location.abovebar, offset=-pivotLen, color=color.red, size=size.tiny, text="DIV")

plotshape(showRetests and bullRetestSignal, title="Bullischer Retest gehalten", style=shape.diamond, location=location.belowbar, color=color.lime, size=size.small, text="RETEST")
plotshape(showRetests and bearRetestSignal, title="Bärischer Retest gehalten", style=shape.diamond, location=location.abovebar, color=color.red, size=size.small, text="RETEST")

scoreDifference = bullScore - bearScore
color backgroundColor = scoreDifference >= 30 ? color.new(color.lime, 88) : scoreDifference >= 15 ? color.new(color.green, 93) : scoreDifference <= -30 ? color.new(color.red, 88) : scoreDifference <= -15 ? color.new(color.orange, 93) : na
bgcolor(showBackground ? backgroundColor : na)

// Dashboard-Core
bullTrendCore = close > ema21 and ema9 > ema21 and ema21 > ema50
bearTrendCore = close < ema21 and ema9 < ema21 and ema21 < ema50

fullBullTrend = ema9 > ema21 and ema21 > ema50 and ema50 > ema200
fullBearTrend = ema9 < ema21 and ema21 < ema50 and ema50 < ema200

string emaTrendText = fullBullTrend ? "BULL" : fullBearTrend ? "BEAR" : f_deen("GEMISCHT", "MIXED")

color emaTrendColor = fullBullTrend ? color.lime : fullBearTrend ? color.red : color.orange

bullRsiCore = rsi >= rsiBullLevel
bearRsiCore = rsi <= rsiBearLevel
bullMacdCore = macdLine > macdSignal and macdHist > 0
bearMacdCore = macdLine < macdSignal and macdHist < 0
bullDmiCore = plusDI > minusDI and adx >= adxMin
bearDmiCore = minusDI > plusDI and adx >= adxMin
bullVolCore = volumeAvailable and bullVolDirection and volRatio >= runVolRatio
bearVolCore = volumeAvailable and bearVolDirection and volRatio >= runVolRatio
bullMtfCore = not useMTF or bullMtfCount >= 2
bearMtfCore = not useMTF or bearMtfCount >= 2
bullRsCore = not rsAvailable or rsBull
bearRsCore = not rsAvailable or rsBear

string missingBull = (not bullTrendCore ? "EMA " : "") + (not bullRsiCore ? "RSI " : "") + (not bullMacdCore ? "MACD " : "") + (not bullDmiCore ? "ADX " : "") + (not bullVolCore ? "VOL " : "") + (not bullBreakout ? "BO " : "") + (not bullMtfCore ? "MTF " : "") + (not bullRsCore ? "RS " : "")

string missingBear = (not bearTrendCore ? "EMA " : "") + (not bearRsiCore ? "RSI " : "") + (not bearMacdCore ? "MACD " : "") + (not bearDmiCore ? "ADX " : "") + (not bearVolCore ? "VOL " : "") + (not bearBreakout ? "BD " : "") + (not bearMtfCore ? "MTF " : "") + (not bearRsCore ? "RS " : "")

string divergenceText = recentBullDivergence and (not recentBearDivergence or nz(lastBullDivBar, -1) > nz(lastBearDivBar, -1)) ? "BULLISH" : recentBearDivergence ? "BEARISH" : f_deen("KEINE", "NONE")

color divergenceColor = divergenceText == "BULLISH" ? color.lime : divergenceText == "BEARISH" ? color.red : color.gray

string rsText = not rsAvailable ? f_deen("AUS / N/A", "OFF / N/A") : rsBull and rsRising ? f_deen("STARK BULL", "STRONG BULL") : rsBull ? "BULL" : rsBear and rsFalling ? f_deen("STARK BEAR", "STRONG BEAR") : rsBear ? "BEAR" : "NEUTRAL"

color rsTextColor = rsBull ? color.lime : rsBear ? color.red : color.gray

dashPos = f_dashboardPosition(dashboardPositionInput)
dashSize = f_dashboardSize(dashboardMode, dashboardTextInput)

string mtfDesktopText = tfFast + " " + f_mtfText(mtfFast) + " | " + tfMain + " " + f_mtfText(mtfMain) + " | " + tfSlow + " " + f_mtfText(mtfSlow)

string mtfMobileText = f_tfLabel(tfFast) + f_mtfArrow(mtfFast) + " " + f_tfLabel(tfMain) + f_mtfArrow(mtfMain) + " " + f_tfLabel(tfSlow) + f_mtfArrow(mtfSlow)

string rsiDirection = rsiRising ? " ↑" : rsiFalling ? " ↓" : ""
string adxDirection = adxRising ? " ↑" : " ↓"
string missingBullDisplay = missingBull == "" ? f_deen("NICHTS", "NONE") : missingBull
string missingBearDisplay = missingBear == "" ? f_deen("NICHTS", "NONE") : missingBear

var table dashboard = table.new(position.top_right, 2, 31, border_width=1)

if barstate.islast
    table.set_position(dashboard, dashPos)
    table.clear(dashboard, 0, 0, 1, 30)

    if showDashboard

        if dashboardMode == "Desktop"

            table.cell(dashboard, 0, 0, "RUN/FALL RADAR PRO", bgcolor=color.rgb(45,48,55), text_color=color.white, text_size=dashSize)
            table.cell(dashboard, 1, 0, overallStatus, bgcolor=overallColor, text_color=color.white, text_size=dashSize)

            table.cell(dashboard, 0, 1, f_deen("Status","Status"), text_size=dashSize)
            table.cell(dashboard, 1, 1, signalOnCloseOnly ? f_deen("BESTÄTIGT","CONFIRMED") : "LIVE", text_size=dashSize)

            table.cell(dashboard, 0, 2, "Bull Score", text_size=dashSize)
            table.cell(dashboard, 1, 2, f_fmt1(bullScore)+"/100", text_color=bullScore >= runThreshold ? color.lime : bullScore >= setupThreshold ? color.green : bullScore >= earlyThreshold ? color.teal : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 3, "Bear Score", text_size=dashSize)
            table.cell(dashboard, 1, 3, f_fmt1(bearScore)+"/100", text_color=bearScore >= runThreshold ? color.red : bearScore >= setupThreshold ? color.orange : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 4, "EMA 9", text_size=dashSize)
            table.cell(dashboard, 1, 4, f_fmt2(ema9), text_color=color.aqua, text_size=dashSize)

            table.cell(dashboard, 0, 5, "EMA 21", text_size=dashSize)
            table.cell(dashboard, 1, 5, f_fmt2(ema21), text_color=color.yellow, text_size=dashSize)

            table.cell(dashboard, 0, 6, "EMA 50", text_size=dashSize)
            table.cell(dashboard, 1, 6, f_fmt2(ema50), text_color=color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 7, "EMA 200", text_size=dashSize)
            table.cell(dashboard, 1, 7, f_fmt2(ema200), text_color=color.purple, text_size=dashSize)

            table.cell(dashboard, 0, 8, "RSI", text_size=dashSize)
            table.cell(dashboard, 1, 8, f_fmt1(rsi)+rsiDirection, text_color=rsi >= rsiBullLevel ? color.lime : rsi <= rsiBearLevel ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 9, "MACD", text_size=dashSize)
            table.cell(dashboard, 1, 9, bullMacdCore ? "BULLISH" : bearMacdCore ? "BEARISH" : f_deen("GEMISCHT","MIXED"), text_color=bullMacdCore ? color.lime : bearMacdCore ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 10, "DMI / ADX", text_size=dashSize)
            table.cell(dashboard, 1, 10, (plusDI > minusDI ? "+DI" : "-DI")+" | "+f_fmt1(adx)+adxDirection, text_color=plusDI > minusDI ? color.lime : color.red, text_size=dashSize)

            table.cell(dashboard, 0, 11, f_deen("Volumen","Volume"), text_size=dashSize)
            table.cell(dashboard, 1, 11, f_fmt2(volRatio)+"x", text_color=not volumeAvailable ? color.gray : volRatio >= strongVolRatio ? color.lime : volRatio >= runVolRatio ? color.green : volRatio >= elevatedVolRatio ? color.orange : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 12, "BB Squeeze", text_size=dashSize)
            table.cell(dashboard, 1, 12, bbSqueeze ? f_deen("JA","YES") : squeezeRecent ? f_deen("GERADE BEENDET","JUST ENDED") : f_deen("NEIN","NO"), text_color=bbSqueeze or squeezeRecent ? color.yellow : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 13, "MTF", text_size=dashSize)
            table.cell(dashboard, 1, 13, mtfDesktopText, text_color=bullMtfCount >= 2 ? color.lime : bearMtfCount >= 2 ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 14, f_deen("Relative Stärke","Relative Strength"), text_size=dashSize)
            table.cell(dashboard, 1, 14, rsText, text_color=rsTextColor, text_size=dashSize)

            table.cell(dashboard, 0, 15, f_deen("Widerstand","Resistance"), text_size=dashSize)
            table.cell(dashboard, 1, 15, f_fmt2(resistance), text_size=dashSize)

            table.cell(dashboard, 0, 16, "Support", text_size=dashSize)
            table.cell(dashboard, 1, 16, f_fmt2(support), text_size=dashSize)

            table.cell(dashboard, 0, 17, "ATR", text_size=dashSize)
            table.cell(dashboard, 1, 17, f_fmt2(atr)+" | "+f_fmt1(atrPct)+"%", text_size=dashSize)

            table.cell(dashboard, 0, 18, f_deen("RSI Divergenz","RSI Divergence"), text_size=dashSize)
            table.cell(dashboard, 1, 18, divergenceText, text_color=divergenceColor, text_size=dashSize)

            table.cell(dashboard, 0, 19, f_deen("Fehlt Bull","Missing Bull"), text_size=dashSize)
            table.cell(dashboard, 1, 19, missingBullDisplay, text_color=missingBull == "" ? color.lime : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 20, f_deen("Fehlt Bear","Missing Bear"), text_size=dashSize)
            table.cell(dashboard, 1, 20, missingBearDisplay, text_color=missingBear == "" ? color.red : color.orange, text_size=dashSize)

            if showTargets
                table.cell(dashboard, 0, 21, f_deen("Zielrichtung","Target Direction"), text_size=dashSize)
                table.cell(dashboard, 1, 21, targetDirText, text_color=targetDisplayDirection == 1 ? color.lime : color.red, text_size=dashSize)

                table.cell(dashboard, 0, 22, targetDisplayDirection == 1 ? "BO Level" : "BD Level", text_size=dashSize)
                table.cell(dashboard, 1, 22, f_fmt2(targetDisplayBase), text_size=dashSize)

                table.cell(dashboard, 0, 23, "T1 CONS.", text_size=dashSize)
                table.cell(dashboard, 1, 23, targetT1Text, text_color=color.yellow, text_size=dashSize)

                table.cell(dashboard, 0, 24, "T2 STANDARD", text_size=dashSize)
                table.cell(dashboard, 1, 24, targetT2Text, text_color=color.lime, text_size=dashSize)

                table.cell(dashboard, 0, 25, "T3 AGGR.", text_size=dashSize)
                table.cell(dashboard, 1, 25, targetT3Text, text_color=color.aqua, text_size=dashSize)

                table.cell(dashboard, 0, 26, "ATR x2", text_size=dashSize)
                table.cell(dashboard, 1, 26, f_fmt2(targetATR2), text_size=dashSize)

                table.cell(dashboard, 0, 27, f_deen("Hist. W/S","Hist. R/S"), text_size=dashSize)
                table.cell(dashboard, 1, 27, targetHistText, text_size=dashSize)

                table.cell(dashboard, 0, 28, f_deen("Ziel-Fokus","Target Focus"), text_size=dashSize)
                table.cell(dashboard, 1, 28, targetFocus, text_color=targetFocus == "T3 AGGR." ? color.aqua : targetFocus == "T2 STANDARD" ? color.lime : targetFocus == "T1 CONS." ? color.yellow : color.orange, text_size=dashSize)

                table.cell(dashboard, 0, 29, f_deen("Zielstatus","Target Status"), text_size=dashSize)
                table.cell(dashboard, 1, 29, targetStatus, text_color=activeTargetInvalidated ? color.red : color.white, text_size=dashSize)

                table.cell(dashboard, 0, 30, f_deen("Rest T2","Remaining T2"), text_size=dashSize)
                table.cell(dashboard, 1, 30, f_fmt1(targetRemainingT2)+"%", text_color=targetDisplayDirection == 1 ? color.lime : color.red, text_size=dashSize)

        else if dashboardMode == "Mobile"

            table.cell(dashboard, 0, 0, "RADAR PRO", bgcolor=color.rgb(45,48,55), text_color=color.white, text_size=dashSize)
            table.cell(dashboard, 1, 0, overallStatus, bgcolor=overallColor, text_color=color.white, text_size=dashSize)

            table.cell(dashboard, 0, 1, "Bull / Bear", text_size=dashSize)
            table.cell(dashboard, 1, 1, f_fmt1(bullScore)+" / "+f_fmt1(bearScore), text_color=bullScore > bearScore ? color.lime : bearScore > bullScore ? color.red : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 2, "EMA", text_size=dashSize)
            table.cell(dashboard, 1, 2, emaTrendText, text_color=emaTrendColor, text_size=dashSize)

            table.cell(dashboard, 0, 3, "RSI", text_size=dashSize)
            table.cell(dashboard, 1, 3, f_fmt1(rsi)+rsiDirection, text_color=rsi >= rsiBullLevel ? color.lime : rsi <= rsiBearLevel ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 4, "MACD", text_size=dashSize)
            table.cell(dashboard, 1, 4, bullMacdCore ? "BULL" : bearMacdCore ? "BEAR" : "MIX", text_color=bullMacdCore ? color.lime : bearMacdCore ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 5, "DMI/ADX", text_size=dashSize)
            table.cell(dashboard, 1, 5, (plusDI > minusDI ? "+DI " : "-DI ")+f_fmt1(adx)+adxDirection, text_color=plusDI > minusDI ? color.lime : color.red, text_size=dashSize)

            table.cell(dashboard, 0, 6, f_deen("Vol.","Vol."), text_size=dashSize)
            table.cell(dashboard, 1, 6, f_fmt2(volRatio)+"x", text_color=not volumeAvailable ? color.gray : volRatio >= strongVolRatio ? color.lime : volRatio >= runVolRatio ? color.green : volRatio >= elevatedVolRatio ? color.orange : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 7, "MTF", text_size=dashSize)
            table.cell(dashboard, 1, 7, mtfMobileText, text_color=bullMtfCount >= 2 ? color.lime : bearMtfCount >= 2 ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 8, f_deen("Rel. Stärke","Rel. Strength"), text_size=dashSize)
            table.cell(dashboard, 1, 8, rsText, text_color=rsTextColor, text_size=dashSize)

            table.cell(dashboard, 0, 9, f_deen("W / S","R / S"), text_size=dashSize)
            table.cell(dashboard, 1, 9, f_fmt2(resistance)+" / "+f_fmt2(support), text_size=dashSize)

            table.cell(dashboard, 0, 10, f_deen("Fehlt Bull","Missing Bull"), text_size=dashSize)
            table.cell(dashboard, 1, 10, missingBullDisplay, text_color=missingBull == "" ? color.lime : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 11, f_deen("Fehlt Bear","Missing Bear"), text_size=dashSize)
            table.cell(dashboard, 1, 11, missingBearDisplay, text_color=missingBear == "" ? color.red : color.orange, text_size=dashSize)

            if showTargets
                table.cell(dashboard, 0, 12, f_deen("Ziel","Target"), text_size=dashSize)
                table.cell(dashboard, 1, 12, targetFocus+" | "+targetStatus, text_color=targetDisplayDirection == 1 ? color.lime : color.red, text_size=dashSize)

                table.cell(dashboard, 0, 13, "T1 / T2", text_size=dashSize)
                table.cell(dashboard, 1, 13, f_fmt2(targetT1)+" / "+f_fmt2(targetT2), text_size=dashSize)

                table.cell(dashboard, 0, 14, f_deen("T3 / Rest T2","T3 / Rem. T2"), text_size=dashSize)
                table.cell(dashboard, 1, 14, f_fmt2(targetT3)+" / "+f_fmt1(targetRemainingT2)+"%", text_size=dashSize)

                table.cell(dashboard, 0, 15, f_deen("Hist. W/S","Hist. R/S"), text_size=dashSize)
                table.cell(dashboard, 1, 15, targetHistText, text_size=dashSize)

        else

            table.cell(dashboard, 0, 0, "RADAR PRO", bgcolor=color.rgb(45,48,55), text_color=color.white, text_size=dashSize)
            table.cell(dashboard, 1, 0, overallStatus, bgcolor=overallColor, text_color=color.white, text_size=dashSize)

            table.cell(dashboard, 0, 1, "B / B", text_size=dashSize)
            table.cell(dashboard, 1, 1, f_fmt1(bullScore)+" / "+f_fmt1(bearScore), text_color=bullScore > bearScore ? color.lime : bearScore > bullScore ? color.red : color.white, text_size=dashSize)

            table.cell(dashboard, 0, 2, "RSI / ADX", text_size=dashSize)
            table.cell(dashboard, 1, 2, f_fmt1(rsi)+rsiDirection+" / "+f_fmt1(adx)+adxDirection, text_size=dashSize)

            table.cell(dashboard, 0, 3, "MACD / VOL", text_size=dashSize)
            table.cell(dashboard, 1, 3, (bullMacdCore ? "B" : bearMacdCore ? "S" : "N")+" / "+f_fmt2(volRatio)+"x", text_size=dashSize)

            table.cell(dashboard, 0, 4, "MTF / RS", text_size=dashSize)
            table.cell(dashboard, 1, 4, mtfMobileText+" | "+(rsBull ? "RS↑" : rsBear ? "RS↓" : "RS–"), text_color=bullMtfCount >= 2 and rsBull ? color.lime : bearMtfCount >= 2 and rsBear ? color.red : color.orange, text_size=dashSize)

            table.cell(dashboard, 0, 5, f_deen("Fehlt","Missing"), text_size=dashSize)
            table.cell(dashboard, 1, 5, bullScore >= bearScore ? missingBullDisplay : missingBearDisplay, text_color=color.orange, text_size=dashSize)


            if showTargets
                table.cell(dashboard, 0, 6, f_deen("Ziele","Targets"), text_size=dashSize)
                table.cell(dashboard, 1, 6, "T1 "+f_fmt2(targetT1)+" | T2 "+f_fmt2(targetT2)+" | T3 "+f_fmt2(targetT3), text_size=dashSize)

// Datenfenster
plot(bullScore, title="Bull Score", display=display.data_window)
plot(bearScore, title="Bear Score", display=display.data_window)
plot(rsi, title="RSI", display=display.data_window)
plot(adx, title="ADX", display=display.data_window)
plot(plusDI, title="+DI", display=display.data_window)
plot(minusDI, title="-DI", display=display.data_window)
plot(macdHist, title="MACD Histogramm", display=display.data_window)
plot(volRatio, title="Relatives Volumen", display=display.data_window)
plot(targetT1, title="Target T1", display=display.data_window)
plot(targetT2, title="Target T2", display=display.data_window)
plot(targetT3, title="Target T3", display=display.data_window)
plot(targetDisplayHist, title="Historisches Ziel", display=display.data_window)

// Alarme
bullEarlyAlert = signalReady and bullScore >= earlyThreshold and bullScore[1] < earlyThreshold
bullSetupAlert = signalReady and bullScore >= setupThreshold and bullScore[1] < setupThreshold
bullRunAlert = signalReady and bullRunCondition and not bullRunCondition[1]
bullStrongAlert = signalReady and bullStrongCondition and not bullStrongCondition[1]

bearEarlyAlert = signalReady and bearScore >= earlyThreshold and bearScore[1] < earlyThreshold
bearSetupAlert = signalReady and bearScore >= setupThreshold and bearScore[1] < setupThreshold
bearRunAlert = signalReady and bearRunCondition and not bearRunCondition[1]
bearStrongAlert = signalReady and bearStrongCondition and not bearStrongCondition[1]

targetT1Alert = activeTargetDirection != 0 and not activeTargetInvalidated and targetT1Reached and not targetT1Reached[1]
targetT2Alert = activeTargetDirection != 0 and not activeTargetInvalidated and targetT2Reached and not targetT2Reached[1]
targetT3Alert = activeTargetDirection != 0 and not activeTargetInvalidated and targetT3Reached and not targetT3Reached[1]
targetInvalidAlert = activeTargetInvalidated and not activeTargetInvalidated[1]

alertcondition(bullEarlyAlert, title="PRO – Early Bull", message="Momentum Run & Fall Radar PRO: EARLY BULL erkannt.")
alertcondition(bullSetupAlert, title="PRO – Bull Setup", message="Momentum Run & Fall Radar PRO: BULL SETUP erkannt.")
alertcondition(bullRunAlert, title="PRO – RUN", message="Momentum Run & Fall Radar PRO: bestätigtes RUN-Signal.")
alertcondition(bullStrongAlert, title="PRO – STRONG RUN", message="Momentum Run & Fall Radar PRO: STRONG RUN erkannt.")

alertcondition(bearEarlyAlert, title="PRO – Early Bear", message="Momentum Run & Fall Radar PRO: EARLY BEAR erkannt.")
alertcondition(bearSetupAlert, title="PRO – Bear Warning", message="Momentum Run & Fall Radar PRO: BEAR WARNING erkannt.")
alertcondition(bearRunAlert, title="PRO – FALL", message="Momentum Run & Fall Radar PRO: bestätigtes FALL-Signal.")
alertcondition(bearStrongAlert, title="PRO – STRONG FALL", message="Momentum Run & Fall Radar PRO: STRONG FALL erkannt.")

alertcondition(bullRetestSignal, title="PRO – Bull Retest gehalten", message="Momentum Run & Fall Radar PRO: bullischer Breakout-Retest wurde gehalten.")
alertcondition(bearRetestSignal, title="PRO – Bear Retest gehalten", message="Momentum Run & Fall Radar PRO: bärischer Breakdown-Retest wurde bestätigt.")
alertcondition(bullDivergence, title="PRO – Bullische RSI Divergenz", message="Momentum Run & Fall Radar PRO: bullische RSI-Divergenz erkannt.")
alertcondition(bearDivergence, title="PRO – Bärische RSI Divergenz", message="Momentum Run & Fall Radar PRO: bärische RSI-Divergenz erkannt.")


alertcondition(targetT1Alert, title="PRO – Target T1 erreicht", message="Momentum Run & Fall Radar PRO: T1 wurde erreicht.")
alertcondition(targetT2Alert, title="PRO – Target T2 erreicht", message="Momentum Run & Fall Radar PRO: T2 wurde erreicht.")
alertcondition(targetT3Alert, title="PRO – Target T3 erreicht", message="Momentum Run & Fall Radar PRO: T3 wurde erreicht.")
alertcondition(targetInvalidAlert, title="PRO – Breakout Target invalidiert", message="Momentum Run & Fall Radar PRO: Die aktive Breakout-/Breakdown-Zielprojektion wurde invalidiert.")
````
