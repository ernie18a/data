<!-- tradingview-pine-id: PUB;1e8cb808a73e4b26b18f6d414a207745 -->
<!-- tradingviewscripts-format: 1 -->
# ATH Market Position Suite 3.0

Source: https://www.tradingview.com/script/Ihtbd7Jv/

## Description

Publication title

ATH Market Position Suite 3.0

Short description

ATH Market Position Suite 3.0 visualizes where an asset trades within multiple historical price ranges. It combines configurable percentage levels, multi-horizon range analysis, drawdowns, relative performance, a descriptive Market Position Score, market-zone classification, a dashboard, and customizable alerts.

English description
Overview

ATH Market Position Suite 3.0 is a historical price-position analysis tool designed to show where an asset currently trades within several relevant market ranges.

Instead of interpreting the current price in isolation, the indicator compares it with:

its available all-time high and low,
its 52-week range,
its 3-year range,
its 5-year range,
a configurable manual range,
and the performance of a selected benchmark.

The active reference range is divided into horizontal percentage levels from 0% to 100%. A dashboard then summarizes the asset’s current position, drawdowns, relative performance, historical range status, and composite Market Position Score.

The indicator is intended for long-term investors, swing traders, position traders, portfolio analysis, and market-cycle observation.

It does not generate automatic buy or sell signals.

Core concept

Each market-position value describes where the current price is located between a defined lower and upper boundary.

A position near 100% means the asset is trading close to the upper boundary of the selected range.

A position near 0% means the asset is trading close to the lower boundary.

For example, in the 52-week mode:

the 52-week low represents 0%,
the 52-week high represents 100%,
and the current price is placed proportionally between those values.

In the default All-Time High mode, the available all-time high represents 100%, while zero price represents 0%.

In the ATH-ATL Range mode, the available all-time low represents 0% and the available all-time high represents 100%.

Reference modes
All-Time High

Uses the highest price available to the script as the 100% reference.

The lower boundary is zero.

This mode is useful for evaluating how much of the asset’s maximum historical price has been retained.

ATH-ATL Range

Uses the full available historical range:

available all-time low = 0%
available all-time high = 100%

This mode shows the current price position within the asset’s full available trading history.

52-Week Range

Uses the highest and lowest daily prices from approximately 252 trading days.

This mode is useful for evaluating the current position within the most recent annual range.

3-Year Range

Uses the highest and lowest daily prices from approximately 756 trading days.

This provides a medium-term historical perspective.

5-Year Range

Uses the highest and lowest daily prices from approximately 1,260 trading days.

This mode is intended for longer-term market-cycle analysis.

Manual Range

Allows the user to define both the upper and lower boundaries manually.

This can be useful for analyzing:

a previous market cycle,
a major historical swing,
a custom valuation range,
a fixed reference high,
or a specific technical price structure.
Percentage levels

The active reference range can be divided into regular percentage intervals.

Available intervals include:

1%
2%
4%
5%
10%
20%
25%
50%

A separate Favorite Levels mode displays a selected set of important levels:

100%
95%
90%
80%
75%
70%
60%
50%
40%
30%
25%
20%
10%
5%
0%

Major levels are displayed with increased visual emphasis.

Labels can optionally show both the percentage value and the corresponding price.

Market zones

The indicator divides the active range into descriptive market zones:

90-100%: near the upper boundary
70-90%: upper market range
50-70%: middle-upper range
30-50%: lower-middle range
0-30%: lower market range

The zone colors are fully configurable.

These zones describe historical price location only. They do not determine whether an asset is fundamentally overvalued or undervalued.

Multi-horizon analysis

The dashboard compares the asset across several historical horizons:

52 weeks
3 years
5 years
available all-time range

For each horizon, the indicator displays:

current range position,
drawdown from the corresponding high,
and a descriptive range status.

This helps reveal whether the asset is positioned similarly across short-, medium-, and long-term history.

For example, an asset may trade near its 52-week high while still remaining far below its 5-year high.

Drawdown analysis

Drawdown is calculated as the percentage distance between the current price and the relevant historical high.

A value of:

0% means the price is at the reference high,
-10% means the price is 10% below the reference high,
-40% means the price is 40% below the reference high.

The dashboard includes drawdowns for:

52 weeks,
3 years,
5 years,
the available all-time high,
and the selected primary reference range.
Market Position Score

The Market Position Score is a descriptive composite value from 0 to 100.

Its base calculation combines:

35% weighting for the 52-week position,
25% weighting for the 3-year position,
20% weighting for the 5-year position,
20% weighting for the available all-time range position.

An optional and limited adjustment is then applied based on relative performance versus the selected benchmark.

The adjustment is capped by the user-defined maximum, preventing benchmark performance from dominating the score.

A higher score means the asset is positioned closer to the upper portions of its historical ranges.

A lower score means the asset is positioned closer to the lower portions.

The Market Position Score is:

not a probability,
not a valuation model,
not a forecast,
not a momentum signal,
and not a recommendation to buy or sell.

It is a compact summary of historical price location and relative performance.

Relative performance

The indicator compares the asset’s percentage return with the return of a selected benchmark over a configurable number of trading days.

The default benchmark is:

AMEX:SPY

The relative-performance value is calculated as:

asset return minus benchmark return

A positive value means the asset outperformed the benchmark during the selected period.

A negative value means the asset underperformed.

Users should select a benchmark that is appropriate for the asset being analyzed.

Examples may include:

a broad-market ETF,
a regional equity index,
a sector ETF,
or another relevant comparison instrument.

Relative performance is not the same as absolute performance. An asset can decline while still outperforming a benchmark that declined more sharply.

Dashboard

The dashboard provides a compact summary of the current market structure.

It includes:

symbol and chart timeframe,
52-week position and drawdown,
3-year position and drawdown,
5-year position and drawdown,
available all-time position and drawdown,
Market Position Score,
active primary reference range,
current price,
available all-time high,
available all-time low,
relative performance versus the selected benchmark,
recovery from the available all-time low,
distance from the 50% midpoint,
and descriptive market-status labels.

The dashboard position and text size can be configured.

Alerts

The script provides alert conditions for:

primary position crossing the selected alert level upward,
primary position crossing the selected alert level downward,
Market Position Score crossing the selected score level upward,
Market Position Score crossing the selected score level downward,
entering the 90-100% zone,
leaving the 90-100% zone,
entering the lower range below 30%,
relative performance crossing above zero,
relative performance crossing below zero,
a new available all-time high,
and a new available all-time low.

After adding the indicator to a chart, alerts must be created manually through TradingView’s alert dialog.

Suggested use cases

The indicator may be used for:

long-term market-position analysis,
correction-depth measurement,
historical range comparison,
portfolio monitoring,
market-cycle observation,
benchmark comparison,
identifying differences between short- and long-term price position,
and monitoring predefined percentage thresholds.

It is best used together with additional context such as:

trend structure,
volatility,
volume,
market fundamentals,
risk management,
and the characteristics of the analyzed asset.
Interpretation examples

A high 52-week position combined with a low 5-year position may indicate that the asset is strong over the most recent year but remains below a longer-term historical high.

A high position across all horizons shows that the asset is trading close to the upper areas of both recent and long-term ranges.

A low position across all horizons shows that the asset is trading near the lower areas of its historical ranges.

Positive relative performance indicates strength versus the selected benchmark, but does not necessarily mean that the asset itself produced a positive return.

Important limitations

The available all-time high and all-time low depend on the historical data TradingView provides to the script.

They may therefore differ from the absolute historical high or low when:

the chart contains limited history,
the symbol has changed exchange or data provider,
earlier price history is unavailable,
the instrument has been adjusted,
or the data feed differs from another source.

The 52-week, 3-year, and 5-year ranges use daily data and approximate trading-year lengths of:

252 trading days,
756 trading days,
1,260 trading days.

These values are practical approximations and do not represent exact calendar periods for every market.

Assets with insufficient history may display n/a for some calculations.

On logarithmic charts, percentage levels may not appear equally spaced. A linear price scale provides a more direct visual representation of the calculated price intervals.

The indicator does not use future data or intentional lookahead logic.

Recommended chart setup

For a clear presentation:

use a standard candlestick or bar chart,
keep additional indicators to a minimum,
choose a reference mode appropriate for the analysis,
select a relevant benchmark,
and adjust the number of visible levels according to the chart timeframe.

For long-term analysis, the Favorite Levels mode often provides a cleaner chart.

Disclaimer

This indicator is provided for informational and analytical purposes only.

It does not constitute financial, investment, trading, tax, or legal advice.

Historical price position does not predict future performance. A low historical position does not automatically indicate value, and a high historical position does not automatically indicate excessive valuation.

All trading and investment decisions remain the sole responsibility of the user.

Version 3.0

New features include:

multi-horizon market-position analysis,
52-week, 3-year, 5-year, and all-time range comparison,
composite Market Position Score,
configurable benchmark comparison,
relative-performance analysis,
expanded drawdown statistics,
market-status classification,
improved dashboard,
manual range mode,
configurable percentage levels,
Favorite Levels mode,
market-zone visualization,
and extended alert conditions.
Deutsche Beschreibung
Überblick

ATH Market Position Suite 3.0 zeigt, an welcher Stelle sich der aktuelle Kurs innerhalb verschiedener historischer Preisspannen befindet.

Der Indikator analysiert:

das verfügbare Allzeithoch und Allzeittief,
die 52-Wochen-Spanne,
die 3-Jahres-Spanne,
die 5-Jahres-Spanne,
einen frei definierbaren manuellen Bereich,
sowie die relative Wertentwicklung gegenüber einem ausgewählten Vergleichswert.

Der aktive Referenzbereich wird in horizontale Prozentstufen von 0% bis 100% unterteilt. Ein Dashboard fasst Marktposition, Drawdowns, relative Performance, historischen Bereichsstatus und den zusammengesetzten Market Position Score zusammen.

Der Indikator richtet sich an langfristige Investoren, Swing-Trader, Positions-Trader und Nutzer, die Marktzyklen oder Portfolios beobachten möchten.

Er erzeugt keine automatischen Kauf- oder Verkaufssignale.

Grundprinzip

Jeder Marktpositionswert beschreibt, wo der aktuelle Kurs zwischen einer unteren und einer oberen Grenze liegt.

Eine Position nahe 100% bedeutet, dass der Kurs in der Nähe der oberen Grenze handelt.

Eine Position nahe 0% bedeutet, dass der Kurs in der Nähe der unteren Grenze liegt.

Im 52-Wochen-Modus entspricht beispielsweise:

das 52-Wochen-Tief dem 0%-Level,
das 52-Wochen-Hoch dem 100%-Level,
und der aktuelle Kurs wird proportional dazwischen eingeordnet.

Im Standardmodus All-Time High entspricht das verfügbare Allzeithoch 100%, während der Nullpreis als 0% verwendet wird.

Im Modus ATH-ATL Range entspricht das verfügbare Allzeittief 0% und das verfügbare Allzeithoch 100%.

Referenzmodi
All-Time High

Das höchste dem Script verfügbare Hoch wird als 100%-Referenz verwendet.

Die untere Grenze liegt bei null.

ATH-ATL Range

Verwendet den vollständigen verfügbaren historischen Preisbereich:

verfügbares Allzeittief = 0%
verfügbares Allzeithoch = 100%
52-Week Range

Verwendet das höchste und niedrigste Tageshoch beziehungsweise Tagestief aus ungefähr 252 Handelstagen.

3-Year Range

Verwendet ungefähr 756 Handelstage und bietet eine mittelfristige historische Einordnung.

5-Year Range

Verwendet ungefähr 1.260 Handelstage und dient der langfristigen Marktzyklusbetrachtung.

Manual Range

Der Nutzer kann obere und untere Referenzgrenze selbst festlegen.

Dieser Modus eignet sich unter anderem für frühere Marktzyklen, markante Hoch- und Tiefpunkte oder individuelle Analysebereiche.

Prozent-Level

Der aktive Referenzbereich kann in regelmäßige Prozentabstände unterteilt werden.

Zur Auswahl stehen:

1%
2%
4%
5%
10%
20%
25%
50%

Der Modus Favorite Levels zeigt eine reduzierte Auswahl wichtiger Stufen:

100%, 95%, 90%, 80%, 75%, 70%, 60%, 50%, 40%, 30%, 25%, 20%, 10%, 5% und 0%.

Wichtige Level werden optisch hervorgehoben. Optional können die Labels den Prozentwert und den zugehörigen Preis anzeigen.

Marktposition und Zonen

Der aktive Preisbereich wird in beschreibende Zonen gegliedert:

90-100%: Nähe zur oberen Grenze
70-90%: oberer Marktbereich
50-70%: mittlerer bis oberer Marktbereich
30-50%: unterer bis mittlerer Marktbereich
0-30%: unterer Marktbereich

Diese Zonen zeigen ausschließlich die historische Kursposition. Sie sagen nicht aus, ob ein Vermögenswert fundamental über- oder unterbewertet ist.

Multi-Horizon-Analyse

Das Dashboard vergleicht die Marktposition über mehrere Zeiträume:

52 Wochen
3 Jahre
5 Jahre
verfügbare Gesamthistorie

Für jeden Zeitraum werden Marktposition, Drawdown und ein beschreibender Status dargestellt.

Dadurch lassen sich Unterschiede zwischen kurzfristiger und langfristiger Kursposition erkennen.

Market Position Score

Der Market Position Score ist ein beschreibender Gesamtwert zwischen 0 und 100.

Die Grundberechnung verwendet:

35% Gewichtung für die 52-Wochen-Position,
25% Gewichtung für die 3-Jahres-Position,
20% Gewichtung für die 5-Jahres-Position,
20% Gewichtung für die Position innerhalb der verfügbaren Gesamthistorie.

Anschließend kann eine begrenzte Anpassung auf Basis der relativen Performance gegenüber dem gewählten Benchmark erfolgen.

Ein hoher Score bedeutet, dass sich der Kurs überwiegend in den oberen Bereichen seiner historischen Spannen befindet.

Ein niedriger Score bedeutet, dass er sich überwiegend in den unteren Bereichen befindet.

Der Score ist keine Wahrscheinlichkeit, keine Prognose, kein Bewertungsmodell und kein Handelssignal.

Relative Performance

Die relative Performance vergleicht die prozentuale Wertentwicklung des Assets mit der Wertentwicklung eines frei wählbaren Benchmarks.

Standardmäßig wird AMEX:SPY verwendet.

Ein positiver Wert bedeutet, dass das Asset den Benchmark im ausgewählten Zeitraum übertroffen hat.

Ein negativer Wert bedeutet eine relative Underperformance.

Der Benchmark sollte passend zum analysierten Asset gewählt werden.

Dashboard

Das Dashboard zeigt unter anderem:

Symbol und Chart-Zeiteinheit,
Marktposition und Drawdown über 52 Wochen,
Marktposition und Drawdown über 3 Jahre,
Marktposition und Drawdown über 5 Jahre,
Position und Drawdown innerhalb der verfügbaren Gesamthistorie,
Market Position Score,
aktiven Referenzmodus,
aktuellen Kurs,
verfügbares Allzeithoch und Allzeittief,
relative Performance,
Erholung vom verfügbaren Allzeittief,
und Abstand zum 50%-Mittelpunkt.

Position und Textgröße des Dashboards können angepasst werden.

Alarme

Der Indikator stellt Alarmbedingungen bereit für:

Aufwärts- und Abwärtskreuzung eines frei wählbaren Positionslevels,
Aufwärts- und Abwärtskreuzung eines Scorelevels,
Eintritt in die 90-100%-Zone,
Verlassen der 90-100%-Zone,
Eintritt in den Bereich unter 30%,
Wechsel der relativen Performance über oder unter null,
neues verfügbares Allzeithoch,
und neues verfügbares Allzeittief.

Die Alarme müssen nach dem Hinzufügen des Indikators über den TradingView-Alarmdialog angelegt werden.

Einschränkungen

Das verfügbare Allzeithoch und Allzeittief hängen von den historischen Daten ab, die TradingView dem Script bereitstellt.

Bei begrenzter Historie, unterschiedlichen Datenanbietern oder angepassten Kursreihen können die Werte von anderen Quellen abweichen.

Die Zeiträume von einem, drei und fünf Jahren beruhen auf ungefähren Handelstageswerten von 252, 756 und 1.260 Tagen.

Bei unzureichender Historie können einzelne Werte als n/a erscheinen.

Auf logarithmischen Charts wirken die Level optisch nicht gleichmäßig. Für eine direkte Darstellung der berechneten Preisabstände eignet sich eine lineare Preisskala besser.

Haftungsausschluss

Dieser Indikator dient ausschließlich Informations- und Analysezwecken.

Er stellt keine Finanz-, Anlage-, Handels-, Steuer- oder Rechtsberatung dar.

Eine niedrige historische Marktposition bedeutet nicht automatisch, dass ein Asset günstig ist. Eine hohe Marktposition bedeutet nicht automatisch, dass ein Asset überbewertet ist.

Historische Kurspositionen erlauben keine verlässliche Vorhersage zukünftiger Ergebnisse.

Alle Handels- und Investitionsentscheidungen erfolgen eigenverantwortlich.

---

## Source Code

````pine
//@version=6
indicator(
     title = "ATH Market Position Suite 3.0",
     shorttitle = "ATH Position 3.0",
     overlay = true,
     max_lines_count = 100,
     max_labels_count = 100
)

//=====================================================================
// 1. REFERENCE SETTINGS
//=====================================================================

string GROUP_REFERENCE = "1. Reference Range"

string referenceMode = input.string(
     defval = "All-Time High",
     title = "Primary reference mode",
     options = [
         "All-Time High",
         "ATH-ATL Range",
         "52-Week Range",
         "3-Year Range",
         "5-Year Range",
         "Manual Range"
     ],
     group = GROUP_REFERENCE
)

float manualReferenceHigh = input.float(
     defval = 100.0,
     title = "Manual reference high",
     minval = 0.00000001,
     step = 0.01,
     group = GROUP_REFERENCE
)

float manualReferenceLow = input.float(
     defval = 0.0,
     title = "Manual reference low",
     minval = 0.0,
     step = 0.01,
     group = GROUP_REFERENCE
)

bool useClosingPrice = input.bool(
     defval = true,
     title = "Use closing price for calculations",
     tooltip = "When disabled, the indicator uses HLC3.",
     group = GROUP_REFERENCE
)

//=====================================================================
// 2. LEVEL SETTINGS
//=====================================================================

string GROUP_LEVELS = "2. Percentage Levels"

bool showLevels = input.bool(
     defval = true,
     title = "Show percentage levels",
     group = GROUP_LEVELS
)

string levelMode = input.string(
     defval = "Regular Intervals",
     title = "Level selection",
     options = [
         "Regular Intervals",
         "Favorite Levels"
     ],
     group = GROUP_LEVELS
)

int levelStep = input.int(
     defval = 5,
     title = "Regular interval in percent",
     options = [1, 2, 4, 5, 10, 20, 25, 50],
     group = GROUP_LEVELS
)

bool showLabels = input.bool(
     defval = true,
     title = "Show level labels",
     group = GROUP_LEVELS
)

bool showMinorLabels = input.bool(
     defval = false,
     title = "Show labels on minor levels",
     group = GROUP_LEVELS
)

bool showPricesInLabels = input.bool(
     defval = true,
     title = "Show prices in labels",
     group = GROUP_LEVELS
)

int labelOffset = input.int(
     defval = 5,
     title = "Label offset to the right",
     minval = 0,
     maxval = 500,
     group = GROUP_LEVELS
)

//=====================================================================
// 3. STYLE SETTINGS
//=====================================================================

string GROUP_STYLE = "3. Visual Style"

color standardLevelColor = input.color(
     defval = color.rgb(83, 123, 170),
     title = "Standard level color",
     group = GROUP_STYLE
)

color topLevelColor = input.color(
     defval = color.rgb(205, 65, 65),
     title = "100% level color",
     group = GROUP_STYLE
)

color majorLevelColor = input.color(
     defval = color.rgb(218, 157, 55),
     title = "Major level color",
     group = GROUP_STYLE
)

color bottomLevelColor = input.color(
     defval = color.rgb(105, 115, 125),
     title = "0% level color",
     group = GROUP_STYLE
)

int baseLineWidth = input.int(
     defval = 1,
     title = "Standard line width",
     minval = 1,
     maxval = 4,
     group = GROUP_STYLE
)

string selectedLineStyle = input.string(
     defval = "Solid",
     title = "Line style",
     options = [
         "Solid",
         "Dashed",
         "Dotted"
     ],
     group = GROUP_STYLE
)

//=====================================================================
// 4. ZONE SETTINGS
//=====================================================================

string GROUP_ZONES = "4. Market Zones"

bool showZones = input.bool(
     defval = true,
     title = "Show colored market zones",
     group = GROUP_ZONES
)

bool showBackground = input.bool(
     defval = false,
     title = "Color the chart background",
     group = GROUP_ZONES
)

color zone90Color = input.color(
     defval = color.new(color.red, 87),
     title = "90-100% zone",
     group = GROUP_ZONES
)

color zone70Color = input.color(
     defval = color.new(color.orange, 89),
     title = "70-90% zone",
     group = GROUP_ZONES
)

color zone50Color = input.color(
     defval = color.new(color.yellow, 91),
     title = "50-70% zone",
     group = GROUP_ZONES
)

color zone30Color = input.color(
     defval = color.new(color.green, 92),
     title = "30-50% zone",
     group = GROUP_ZONES
)

color zone0Color = input.color(
     defval = color.new(color.blue, 93),
     title = "0-30% zone",
     group = GROUP_ZONES
)

//=====================================================================
// 5. RELATIVE PERFORMANCE
//=====================================================================

string GROUP_RELATIVE = "5. Relative Performance"

string benchmarkSymbol = input.symbol(
     defval = "AMEX:SPY",
     title = "Benchmark symbol",
     group = GROUP_RELATIVE
)

int relativeLookback = input.int(
     defval = 63,
     title = "Lookback in trading days",
     minval = 5,
     maxval = 504,
     group = GROUP_RELATIVE
)

float relativeScoreLimit = input.float(
     defval = 10.0,
     title = "Maximum score adjustment",
     minval = 0.0,
     maxval = 25.0,
     step = 1.0,
     group = GROUP_RELATIVE
)

//=====================================================================
// 6. DASHBOARD SETTINGS
//=====================================================================

string GROUP_DASHBOARD = "6. Dashboard"

bool showDashboard = input.bool(
     defval = true,
     title = "Show dashboard",
     group = GROUP_DASHBOARD
)

string dashboardLocation = input.string(
     defval = "Top Right",
     title = "Dashboard position",
     options = [
         "Top Left",
         "Top Right",
         "Bottom Left",
         "Bottom Right"
     ],
     group = GROUP_DASHBOARD
)

string dashboardSize = input.string(
     defval = "Small",
     title = "Dashboard text size",
     options = [
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     group = GROUP_DASHBOARD
)

//=====================================================================
// 7. ALERT SETTINGS
//=====================================================================

string GROUP_ALERTS = "7. Alerts"

float positionAlertLevel = input.float(
     defval = 80.0,
     title = "Position alert level",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     group = GROUP_ALERTS
)

float scoreAlertLevel = input.float(
     defval = 75.0,
     title = "Score alert level",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = GROUP_ALERTS
)

//=====================================================================
// 8. HELPER FUNCTIONS
//=====================================================================

f_clamp(float value, float minimum, float maximum) =>
    float result = value

    if result < minimum
        result := minimum

    if result > maximum
        result := maximum

    result

f_position(float price, float rangeLow, float rangeHigh) =>
    float result = na
    float rangeSize = rangeHigh - rangeLow

    if not na(price) and not na(rangeLow) and not na(rangeHigh)
        if rangeSize > 0.0
            result := 100.0 * (price - rangeLow) / rangeSize

    result

f_drawdown(float price, float referenceHigh) =>
    float result = na

    if not na(price) and not na(referenceHigh)
        if referenceHigh > 0.0
            result := 100.0 * (price / referenceHigh - 1.0)

    result

f_gainFromLow(float price, float referenceLow) =>
    float result = na

    if not na(price) and not na(referenceLow)
        if referenceLow > 0.0
            result := 100.0 * (price / referenceLow - 1.0)

    result

f_formatPercent(float value) =>
    string result = "n/a"

    if not na(value)
        result := str.tostring(value, "#.##") + "%"

    result

f_formatSignedPercent(float value) =>
    string result = "n/a"

    if not na(value)
        string prefix = ""

        if value > 0.0
            prefix := "+"

        result := prefix + str.tostring(value, "#.##") + "%"

    result

f_formatPrice(float value) =>
    string result = "n/a"

    if not na(value)
        result := str.tostring(value, format.mintick)

    result

f_isMajorLevel(float percentage) =>
    bool result = false

    if percentage == 100.0
        result := true
    else if percentage == 90.0
        result := true
    else if percentage == 75.0
        result := true
    else if percentage == 50.0
        result := true
    else if percentage == 25.0
        result := true
    else if percentage == 10.0
        result := true
    else if percentage == 0.0
        result := true

    result

f_getPositionColor(float positionValue) =>
    color result = color.gray

    if not na(positionValue)
        if positionValue >= 95.0
            result := color.rgb(145, 45, 55)
        else if positionValue >= 90.0
            result := color.rgb(205, 65, 65)
        else if positionValue >= 70.0
            result := color.rgb(225, 145, 45)
        else if positionValue >= 50.0
            result := color.rgb(205, 180, 60)
        else if positionValue >= 30.0
            result := color.rgb(55, 155, 100)
        else if positionValue >= 10.0
            result := color.rgb(65, 125, 190)
        else
            result := color.rgb(80, 85, 95)

    result

f_getCycleStatus(float positionValue) =>
    string result = "Insufficient data"

    if not na(positionValue)
        if positionValue >= 95.0
            result := "Extreme strength"
        else if positionValue >= 90.0
            result := "Near historical high"
        else if positionValue >= 70.0
            result := "Upper market range"
        else if positionValue >= 50.0
            result := "Middle market range"
        else if positionValue >= 30.0
            result := "Lower market range"
        else if positionValue >= 10.0
            result := "Deep drawdown range"
        else
            result := "Capitulation range"

    result

f_getScoreStatus(float scoreValue) =>
    string result = "Insufficient data"

    if not na(scoreValue)
        if scoreValue >= 80.0
            result := "Historically elevated"
        else if scoreValue >= 60.0
            result := "Upper historical range"
        else if scoreValue >= 40.0
            result := "Balanced range"
        else if scoreValue >= 20.0
            result := "Lower historical range"
        else
            result := "Historically depressed"

    result

f_getRelativeStatus(float relativeValue) =>
    string result = "n/a"

    if not na(relativeValue)
        if relativeValue > 5.0
            result := "Strong outperformance"
        else if relativeValue > 0.0
            result := "Moderate outperformance"
        else if relativeValue < -5.0
            result := "Strong underperformance"
        else if relativeValue < 0.0
            result := "Moderate underperformance"
        else
            result := "In line"

    result

f_progressBar(float value) =>
    string result = ""
    float safeValue = 0.0

    if not na(value)
        safeValue := f_clamp(value, 0.0, 100.0)

    int activeBlocks = int(math.round(safeValue / 10.0))

    for blockNumber = 1 to 10
        if blockNumber <= activeBlocks
            result += "|"
        else
            result += "."

    result

//=====================================================================
// 9. STYLE VALUES
//=====================================================================

lineStyle = line.style_solid

if selectedLineStyle == "Dashed"
    lineStyle := line.style_dashed
else if selectedLineStyle == "Dotted"
    lineStyle := line.style_dotted

tablePosition = position.top_right

if dashboardLocation == "Top Left"
    tablePosition := position.top_left
else if dashboardLocation == "Bottom Left"
    tablePosition := position.bottom_left
else if dashboardLocation == "Bottom Right"
    tablePosition := position.bottom_right

tableTextSize = size.small

if dashboardSize == "Tiny"
    tableTextSize := size.tiny
else if dashboardSize == "Normal"
    tableTextSize := size.normal
else if dashboardSize == "Large"
    tableTextSize := size.large

//=====================================================================
// 10. PRICE AND ALL-TIME VALUES
//=====================================================================

float calculationPrice = close

if not useClosingPrice
    calculationPrice := hlc3

var float allTimeHigh = na
var float allTimeLow = na

if na(allTimeHigh)
    allTimeHigh := high
else
    allTimeHigh := math.max(allTimeHigh, high)

if na(allTimeLow)
    allTimeLow := low
else
    allTimeLow := math.min(allTimeLow, low)

bool newAllTimeHigh = false
bool newAllTimeLow = false

if not na(allTimeHigh[1])
    newAllTimeHigh := high > allTimeHigh[1]

if not na(allTimeLow[1])
    newAllTimeLow := low < allTimeLow[1]

//=====================================================================
// 11. DAILY RANGE DATA
//=====================================================================

float dailyClose = request.security(
     syminfo.tickerid,
     "D",
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float high52Week = request.security(
     syminfo.tickerid,
     "D",
     ta.highest(high, 252),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float low52Week = request.security(
     syminfo.tickerid,
     "D",
     ta.lowest(low, 252),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float high3Year = request.security(
     syminfo.tickerid,
     "D",
     ta.highest(high, 756),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float low3Year = request.security(
     syminfo.tickerid,
     "D",
     ta.lowest(low, 756),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float high5Year = request.security(
     syminfo.tickerid,
     "D",
     ta.highest(high, 1260),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float low5Year = request.security(
     syminfo.tickerid,
     "D",
     ta.lowest(low, 1260),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//=====================================================================
// 12. RELATIVE PERFORMANCE
//=====================================================================

float assetReturn = request.security(
     syminfo.tickerid,
     "D",
     close / close[relativeLookback] - 1.0,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float benchmarkReturn = request.security(
     benchmarkSymbol,
     "D",
     close / close[relativeLookback] - 1.0,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float relativePerformance = na

if not na(assetReturn) and not na(benchmarkReturn)
    relativePerformance := 100.0 * (assetReturn - benchmarkReturn)

//=====================================================================
// 13. MULTI-HORIZON POSITIONS
//=====================================================================

float position52Week = f_position(dailyClose, low52Week, high52Week)
float position3Year = f_position(dailyClose, low3Year, high3Year)
float position5Year = f_position(dailyClose, low5Year, high5Year)
float positionAllTime = f_position(calculationPrice, allTimeLow, allTimeHigh)

float drawdown52Week = f_drawdown(dailyClose, high52Week)
float drawdown3Year = f_drawdown(dailyClose, high3Year)
float drawdown5Year = f_drawdown(dailyClose, high5Year)
float drawdownAllTime = f_drawdown(calculationPrice, allTimeHigh)

float recoveryFromATL = f_gainFromLow(calculationPrice, allTimeLow)

//=====================================================================
// 14. PRIMARY REFERENCE RANGE
//=====================================================================

float referenceHigh = allTimeHigh
float referenceLow = 0.0

if referenceMode == "ATH-ATL Range"
    referenceHigh := allTimeHigh
    referenceLow := allTimeLow
else if referenceMode == "52-Week Range"
    referenceHigh := high52Week
    referenceLow := low52Week
else if referenceMode == "3-Year Range"
    referenceHigh := high3Year
    referenceLow := low3Year
else if referenceMode == "5-Year Range"
    referenceHigh := high5Year
    referenceLow := low5Year
else if referenceMode == "Manual Range"
    referenceHigh := manualReferenceHigh
    referenceLow := manualReferenceLow

float referenceRange = referenceHigh - referenceLow

bool validReferenceRange = false

if not na(referenceHigh) and not na(referenceLow)
    validReferenceRange := referenceRange > 0.0

float primaryPosition = f_position(
     calculationPrice,
     referenceLow,
     referenceHigh
)

float primaryDrawdown = f_drawdown(
     calculationPrice,
     referenceHigh
)

float distanceFromMidpoint = na

if validReferenceRange
    float midpointPrice = referenceLow + referenceRange * 0.50
    distanceFromMidpoint := 100.0 * (calculationPrice - midpointPrice) / referenceRange

//=====================================================================
// 15. MARKET POSITION SCORE
//=====================================================================

float basePositionScore = na

if not na(position52Week) and not na(position3Year)
    if not na(position5Year) and not na(positionAllTime)
        basePositionScore :=
             position52Week * 0.35 +
             position3Year * 0.25 +
             position5Year * 0.20 +
             positionAllTime * 0.20

float relativeAdjustment = 0.0

if not na(relativePerformance)
    relativeAdjustment := f_clamp(
         relativePerformance / 2.0,
         -relativeScoreLimit,
         relativeScoreLimit
    )

float marketPositionScore = na

if not na(basePositionScore)
    marketPositionScore := f_clamp(
         basePositionScore + relativeAdjustment,
         0.0,
         100.0
    )

//=====================================================================
// 16. LEVEL ARRAY
//=====================================================================

var array<float> levelPercentages = array.new<float>()

if barstate.isfirst
    if levelMode == "Favorite Levels"
        array.push(levelPercentages, 100.0)
        array.push(levelPercentages, 95.0)
        array.push(levelPercentages, 90.0)
        array.push(levelPercentages, 80.0)
        array.push(levelPercentages, 75.0)
        array.push(levelPercentages, 70.0)
        array.push(levelPercentages, 60.0)
        array.push(levelPercentages, 50.0)
        array.push(levelPercentages, 40.0)
        array.push(levelPercentages, 30.0)
        array.push(levelPercentages, 25.0)
        array.push(levelPercentages, 20.0)
        array.push(levelPercentages, 10.0)
        array.push(levelPercentages, 5.0)
        array.push(levelPercentages, 0.0)
    else
        int numberOfLevels = int(100 / levelStep)

        for index = 0 to numberOfLevels
            float percentage = 100.0 - index * levelStep
            array.push(levelPercentages, percentage)

//=====================================================================
// 17. LINE AND LABEL ARRAYS
//=====================================================================

var array<line> levelLines = array.new<line>()
var array<label> levelLabels = array.new<label>()

if barstate.isfirst
    int levelCount = array.size(levelPercentages)

    for index = 0 to levelCount - 1
        line createdLine = line.new(
             x1 = bar_index,
             y1 = close,
             x2 = bar_index + 1,
             y2 = close,
             xloc = xloc.bar_index,
             extend = extend.both,
             color = color.new(standardLevelColor, 100),
             width = baseLineWidth
        )

        label createdLabel = label.new(
             x = bar_index,
             y = close,
             text = "",
             xloc = xloc.bar_index,
             style = label.style_label_left,
             color = color.new(standardLevelColor, 100),
             textcolor = color.new(color.white, 100),
             size = size.small
        )

        array.push(levelLines, createdLine)
        array.push(levelLabels, createdLabel)

//=====================================================================
// 18. UPDATE LEVELS
//=====================================================================

if barstate.islast
    int levelCount = array.size(levelPercentages)

    for index = 0 to levelCount - 1
        float percentage = array.get(levelPercentages, index)
        line currentLine = array.get(levelLines, index)
        label currentLabel = array.get(levelLabels, index)

        float levelPrice = na

        if validReferenceRange
            levelPrice := referenceLow + referenceRange * percentage / 100.0

        bool majorLevel = f_isMajorLevel(percentage)

        color currentColor = standardLevelColor

        if percentage == 100.0
            currentColor := topLevelColor
        else if percentage == 0.0
            currentColor := bottomLevelColor
        else if majorLevel
            currentColor := majorLevelColor

        int currentWidth = baseLineWidth

        if percentage == 100.0 or percentage == 50.0
            currentWidth := math.min(baseLineWidth + 2, 5)
        else if majorLevel
            currentWidth := math.min(baseLineWidth + 1, 5)

        bool visibleLabel = false

        if showLevels and showLabels and validReferenceRange
            if showMinorLabels or majorLevel
                visibleLabel := true

        if showLevels and validReferenceRange
            line.set_xy1(currentLine, bar_index, levelPrice)
            line.set_xy2(currentLine, bar_index + 1, levelPrice)
            line.set_color(currentLine, currentColor)
            line.set_width(currentLine, currentWidth)
            line.set_style(currentLine, lineStyle)
        else
            line.set_color(currentLine, color.new(currentColor, 100))

        string percentageText = str.tostring(percentage, "#.##") + "%"
        string labelText = percentageText

        if showPricesInLabels
            labelText := percentageText + " | " + f_formatPrice(levelPrice)

        label.set_xy(
             currentLabel,
             bar_index + labelOffset,
             nz(levelPrice, close)
        )

        if visibleLabel
            label.set_text(currentLabel, labelText)
            label.set_color(currentLabel, currentColor)
            label.set_textcolor(currentLabel, color.white)
        else
            label.set_text(currentLabel, "")
            label.set_color(currentLabel, color.new(currentColor, 100))
            label.set_textcolor(currentLabel, color.new(color.white, 100))

//=====================================================================
// 19. MARKET ZONES
//=====================================================================

float zoneLevel100 = na
float zoneLevel90 = na
float zoneLevel70 = na
float zoneLevel50 = na
float zoneLevel30 = na
float zoneLevel0 = na

if validReferenceRange
    zoneLevel100 := referenceHigh
    zoneLevel90 := referenceLow + referenceRange * 0.90
    zoneLevel70 := referenceLow + referenceRange * 0.70
    zoneLevel50 := referenceLow + referenceRange * 0.50
    zoneLevel30 := referenceLow + referenceRange * 0.30
    zoneLevel0 := referenceLow

plotZone100 = plot(
     showZones ? zoneLevel100 : na,
     title = "100% zone boundary",
     color = color.new(color.white, 100),
     display = display.none
)

plotZone90 = plot(
     showZones ? zoneLevel90 : na,
     title = "90% zone boundary",
     color = color.new(color.white, 100),
     display = display.none
)

plotZone70 = plot(
     showZones ? zoneLevel70 : na,
     title = "70% zone boundary",
     color = color.new(color.white, 100),
     display = display.none
)

plotZone50 = plot(
     showZones ? zoneLevel50 : na,
     title = "50% zone boundary",
     color = color.new(color.white, 100),
     display = display.none
)

plotZone30 = plot(
     showZones ? zoneLevel30 : na,
     title = "30% zone boundary",
     color = color.new(color.white, 100),
     display = display.none
)

plotZone0 = plot(
     showZones ? zoneLevel0 : na,
     title = "0% zone boundary",
     color = color.new(color.white, 100),
     display = display.none
)

fill(plotZone100, plotZone90, color = showZones ? zone90Color : na, title = "90-100% zone")
fill(plotZone90, plotZone70, color = showZones ? zone70Color : na, title = "70-90% zone")
fill(plotZone70, plotZone50, color = showZones ? zone50Color : na, title = "50-70% zone")
fill(plotZone50, plotZone30, color = showZones ? zone30Color : na, title = "30-50% zone")
fill(plotZone30, plotZone0, color = showZones ? zone0Color : na, title = "0-30% zone")

color chartBackgroundColor = color.new(
     f_getPositionColor(primaryPosition),
     94
)

bgcolor(
     showBackground ? chartBackgroundColor : na,
     title = "Market position background"
)

//=====================================================================
// 20. DATA WINDOW
//=====================================================================

plot(primaryPosition, "Primary position (%)", display = display.data_window)
plot(position52Week, "52-week position (%)", display = display.data_window)
plot(position3Year, "3-year position (%)", display = display.data_window)
plot(position5Year, "5-year position (%)", display = display.data_window)
plot(positionAllTime, "All-time range position (%)", display = display.data_window)
plot(marketPositionScore, "Market Position Score", display = display.data_window)
plot(drawdownAllTime, "All-time drawdown (%)", display = display.data_window)
plot(relativePerformance, "Relative performance (%)", display = display.data_window)

//=====================================================================
// 21. DASHBOARD
//=====================================================================

var table dashboard = table.new(
     position = tablePosition,
     columns = 4,
     rows = 12,
     frame_color = color.new(color.gray, 35),
     frame_width = 1,
     border_color = color.new(color.gray, 70),
     border_width = 1
)

if barstate.islast
    color transparent = color.new(color.black, 100)
    color headerBackground = color.rgb(38, 46, 58)
    color labelBackground = color.rgb(54, 64, 78)
    color valueBackground = color.rgb(38, 45, 56)
    color normalText = color.white
    color hiddenText = color.new(color.white, 100)

    color activeHeader = showDashboard ? headerBackground : transparent
    color activeLabel = showDashboard ? labelBackground : transparent
    color activeValue = showDashboard ? valueBackground : transparent
    color activeText = showDashboard ? normalText : hiddenText

    color primaryColor = f_getPositionColor(primaryPosition)
    color scoreColor = f_getPositionColor(marketPositionScore)
    color relativeColor = color.gray

    if not na(relativePerformance)
        if relativePerformance >= 0.0
            relativeColor := color.rgb(50, 150, 95)
        else
            relativeColor := color.rgb(190, 70, 75)

    table.cell(dashboard, 0, 0, showDashboard ? "ATH MARKET POSITION" : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 0, showDashboard ? syminfo.ticker : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 0, showDashboard ? timeframe.period : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 0, showDashboard ? "v3.0" : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 1, showDashboard ? "Horizon" : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 1, showDashboard ? "Position" : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 1, showDashboard ? "Drawdown" : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 1, showDashboard ? "Status" : "", bgcolor = activeHeader, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 2, showDashboard ? "52 Weeks" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 2, showDashboard ? f_formatPercent(position52Week) : "", bgcolor = showDashboard ? color.new(f_getPositionColor(position52Week), 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 2, showDashboard ? f_formatSignedPercent(drawdown52Week) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 2, showDashboard ? f_getCycleStatus(position52Week) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 3, showDashboard ? "3 Years" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 3, showDashboard ? f_formatPercent(position3Year) : "", bgcolor = showDashboard ? color.new(f_getPositionColor(position3Year), 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 3, showDashboard ? f_formatSignedPercent(drawdown3Year) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 3, showDashboard ? f_getCycleStatus(position3Year) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 4, showDashboard ? "5 Years" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 4, showDashboard ? f_formatPercent(position5Year) : "", bgcolor = showDashboard ? color.new(f_getPositionColor(position5Year), 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 4, showDashboard ? f_formatSignedPercent(drawdown5Year) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 4, showDashboard ? f_getCycleStatus(position5Year) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 5, showDashboard ? "All Time" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 5, showDashboard ? f_formatPercent(positionAllTime) : "", bgcolor = showDashboard ? color.new(f_getPositionColor(positionAllTime), 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 5, showDashboard ? f_formatSignedPercent(drawdownAllTime) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 5, showDashboard ? f_getCycleStatus(positionAllTime) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 6, showDashboard ? "Position Score" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 6, showDashboard ? f_formatPercent(marketPositionScore) : "", bgcolor = showDashboard ? color.new(scoreColor, 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 6, showDashboard ? f_progressBar(marketPositionScore) : "", bgcolor = showDashboard ? color.new(scoreColor, 30) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 6, showDashboard ? f_getScoreStatus(marketPositionScore) : "", bgcolor = showDashboard ? color.new(scoreColor, 30) : transparent, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 7, showDashboard ? "Primary Range" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 7, showDashboard ? f_formatPercent(primaryPosition) : "", bgcolor = showDashboard ? color.new(primaryColor, 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 7, showDashboard ? referenceMode : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 7, showDashboard ? f_getCycleStatus(primaryPosition) : "", bgcolor = showDashboard ? color.new(primaryColor, 30) : transparent, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 8, showDashboard ? "Current Price" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 8, showDashboard ? f_formatPrice(calculationPrice) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 8, showDashboard ? "Primary DD" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 8, showDashboard ? f_formatSignedPercent(primaryDrawdown) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 9, showDashboard ? "Available ATH" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 9, showDashboard ? f_formatPrice(allTimeHigh) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 9, showDashboard ? "Available ATL" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 9, showDashboard ? f_formatPrice(allTimeLow) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 10, showDashboard ? "vs Benchmark" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 10, showDashboard ? f_formatSignedPercent(relativePerformance) : "", bgcolor = showDashboard ? color.new(relativeColor, 15) : transparent, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 10, showDashboard ? benchmarkSymbol : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 10, showDashboard ? f_getRelativeStatus(relativePerformance) : "", bgcolor = showDashboard ? color.new(relativeColor, 30) : transparent, text_color = activeText, text_size = tableTextSize)

    table.cell(dashboard, 0, 11, showDashboard ? "Recovery from ATL" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 1, 11, showDashboard ? f_formatSignedPercent(recoveryFromATL) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 2, 11, showDashboard ? "Distance to 50%" : "", bgcolor = activeLabel, text_color = activeText, text_size = tableTextSize)
    table.cell(dashboard, 3, 11, showDashboard ? f_formatSignedPercent(distanceFromMidpoint) : "", bgcolor = activeValue, text_color = activeText, text_size = tableTextSize)

//=====================================================================
// 22. ALERT CONDITIONS
//=====================================================================

bool positionCrossUp = ta.crossover(primaryPosition, positionAlertLevel)
bool positionCrossDown = ta.crossunder(primaryPosition, positionAlertLevel)

bool scoreCrossUp = ta.crossover(marketPositionScore, scoreAlertLevel)
bool scoreCrossDown = ta.crossunder(marketPositionScore, scoreAlertLevel)

bool entersNearAthZone = ta.crossover(primaryPosition, 90.0)
bool leavesNearAthZone = ta.crossunder(primaryPosition, 90.0)
bool entersLowerRange = ta.crossunder(primaryPosition, 30.0)

bool relativeTurnsPositive = ta.crossover(relativePerformance, 0.0)
bool relativeTurnsNegative = ta.crossunder(relativePerformance, 0.0)

alertcondition(
     positionCrossUp,
     title = "Primary position crosses upward",
     message = "ATH Market Position Suite: Primary position crossed the configured alert level upward."
)

alertcondition(
     positionCrossDown,
     title = "Primary position crosses downward",
     message = "ATH Market Position Suite: Primary position crossed the configured alert level downward."
)

alertcondition(
     scoreCrossUp,
     title = "Position Score crosses upward",
     message = "ATH Market Position Suite: Market Position Score crossed the configured level upward."
)

alertcondition(
     scoreCrossDown,
     title = "Position Score crosses downward",
     message = "ATH Market Position Suite: Market Position Score crossed the configured level downward."
)

alertcondition(
     entersNearAthZone,
     title = "Enters near-ATH zone",
     message = "ATH Market Position Suite: Primary position entered the 90-100% zone."
)

alertcondition(
     leavesNearAthZone,
     title = "Leaves near-ATH zone",
     message = "ATH Market Position Suite: Primary position fell below the 90% level."
)

alertcondition(
     entersLowerRange,
     title = "Enters lower market range",
     message = "ATH Market Position Suite: Primary position fell below the 30% level."
)

alertcondition(
     relativeTurnsPositive,
     title = "Relative performance turns positive",
     message = "ATH Market Position Suite: Relative performance crossed above zero."
)

alertcondition(
     relativeTurnsNegative,
     title = "Relative performance turns negative",
     message = "ATH Market Position Suite: Relative performance crossed below zero."
)

alertcondition(
     newAllTimeHigh,
     title = "New available all-time high",
     message = "ATH Market Position Suite: A new all-time high was detected."
)

alertcondition(
     newAllTimeLow,
     title = "New available all-time low",
     message = "ATH Market Position Suite: A new all-time low was detected."
)
````
