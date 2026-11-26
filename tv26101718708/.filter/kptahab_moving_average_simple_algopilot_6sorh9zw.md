# [Kpt-Ahab] Moving Average Simple AlgoPilot

- url: https://www.tradingview.com/script/6sorh9ZW/
- type: strategy
- pine_id: PUB;22946883d6794e2fb100f05c6974e8f8
- version: 2.0

## Description

[b]Important Notice and Risk Warning[/b]

[b]The published settings were selected exclusively based on historical data for the asset and timeframe shown.

The displayed result may be random or over-optimized and cannot automatically be transferred to other assets, timeframes, or future market conditions. Even with the presented settings, the strategy may cause significant losses at any time, including the complete loss of the allocated strategy capital.

This script is intended exclusively for analysis and testing purposes. It does not constitute investment advice or a trading recommendation.[/b]

[b]Description[/b]

This script uses reused and adapted code components from **[Kpt-Ahab] Auto RiskManagement & Backtest System 2.1b** and the **[url=https://de.tradingview.com/script/00U4donK/][Kpt-Ahab] Moving Average Alarm Output[/url]**.

These components have been combined into a standalone strategy that integrates moving-average signals with position management, risk management, and backtesting functions.

[b]How It Works[/b]

The strategy uses two freely configurable moving averages. **SMA, EMA, WMA, VWMA, or HMA** can be selected independently for the short and long moving averages.

A long signal is generated when the short moving average crosses above the long moving average. A short signal is generated when the short moving average crosses below the long moving average.

The moving averages are displayed directly on the chart. An additional colored area visualizes the position of the price relative to the long moving average. Its intensity changes according to the distance between the two moving averages.

[b]Position and Risk Management[/b]

The script supports, among other features:

[i]* Long and short positions
* Fixed or trailing stop-loss levels
* Multiple partial profit targets
* A final profit target
* Breakeven after the first profit target
* Optional additional entries
* Drawdown and losing-trade limits
* Internal or external trading signals
* Different position-sizing methods[/i]

Additional entries and simulated leverage may significantly increase the risk of loss.
[b]
Backtest Limitations[/b]

Strategy Tester results are based exclusively on historical market data. Real-world results may differ significantly due to commissions, spreads, slippage, liquidity, price gaps, and execution delays.

Past performance is not a reliable indication of future results.

[b]Signals During an Open Position[/b]

https://www.tradingview.com/x/NhpoFESM/

The **Open Position Signals** setting determines how new signals are handled while a position is already open:

[i]* **Wait-End-Deal:** All new moving-average signals are ignored until the current position has been closed by a profit target, stop-loss, or another protective function.
* **Wait-Reversal:** An opposing moving-average signal may close the currently open position.[/i]

With **Wait-Reversal**, a sell signal closes a long position, while a buy signal closes a short position. The opposing signal does not automatically open a new position during the same step.

Price-based additional entries remain independent of this setting and may still be executed when enabled.

[b]Stop-Loss, Trailing Stop, Breakeven, and Liquidation Line[/b]

https://www.tradingview.com/x/84bFwPqf/

The strategy supports both a fixed stop-loss and a trailing stop. The selected percentage represents the direct price distance from the average entry price and is not automatically adjusted by the simulated leverage.

In **FIXED %** mode, the stop is calculated from the current average entry price. If the average entry price changes due to an additional entry, the stop is recalculated accordingly.

In **TRAILING** mode, the stop only moves in a direction that is favorable to the position. If the average entry price changes due to an additional entry, the existing trailing stop is adjusted accordingly.

The stop may optionally be moved to the average entry price after the first profit target has been reached. A stop mode must be enabled for this breakeven function to operate.

The displayed liquidation line is only an internal estimate based on the simulated position and account values. It may differ significantly from the actual liquidation calculation used by a broker or exchange.

[b]Using External Indicators[/b]

An external numerical signal source may be used instead of the integrated moving-average signals.

The external indicator must provide a selectable plot series containing the following values:

[b]* **+1:** Long or buy signal
* **−1:** Short or sell signal[/b]

All other values, including `na`, produce no new signal.

The external indicator must output the required numerical values through a selectable plot. This plot can then be selected under **External Source**.

How an external signal is processed while a position is already open also depends on the selected **Open Position Signals** setting.








[b]Wichtiger Hinweis und Risikowarnung

Die veröffentlichten Einstellungen wurden ausschließlich anhand historischer Daten für das dargestellte Asset und den verwendeten Zeitrahmen gewählt.

Das Ergebnis kann zufällig oder überoptimiert sein und lässt sich nicht automatisch auf andere Assets, Zeitrahmen oder zukünftige Marktphasen übertragen. Auch mit den dargestellten Einstellungen kann die Strategie jederzeit erhebliche Verluste verursachen und das eingesetzte Strategiekapital vollständig verlieren.

Dieses Skript dient ausschließlich zu Analyse- und Testzwecken und stellt keine Anlageberatung oder Handelsempfehlung dar.[/b]
[b]
Beschreibung[/b]

Dieses Skript verwendet wiederverwendete und angepasste Codebestandteile aus **[Kpt-Ahab] Auto RiskManagement & Backtest System 2.1b** und dem **[url=https://de.tradingview.com/script/00U4donK/][Kpt-Ahab] Moving Average Alarm Output[/url]**.

Die Komponenten wurden zu einer eigenständigen Strategie verbunden, die Moving-Average-Signale mit Positions-, Risiko- und Backtestfunktionen kombiniert.

[b]Funktionsweise[/b]

Die Strategie verwendet zwei frei konfigurierbare gleitende Durchschnitte. Für den kurzen und den langen Moving Average können jeweils **SMA, EMA, WMA, VWMA oder HMA** ausgewählt werden.

Ein Long-Signal entsteht, wenn der kurze Moving Average den langen Moving Average von unten nach oben kreuzt. Ein Short-Signal entsteht bei einer Kreuzung von oben nach unten.

Die Moving Averages werden direkt im Chart dargestellt. Eine zusätzliche farbliche Fläche visualisiert die Position des Kurses relativ zum langen Moving Average. Die Intensität der Darstellung verändert sich abhängig vom Abstand zwischen den beiden Moving Averages.

[b]Positions- und Risikomanagement[/b]

Das Skript unterstützt unter anderem:

[i]* Long- und Short-Positionen
* feste oder nachlaufende Stop-Loss-Marken
* mehrere Teilgewinnziele
* ein abschließendes Gewinnziel
* Breakeven nach dem ersten Gewinnziel
* optionale zusätzliche Einstiege
* Drawdown- und Verlustserienbegrenzungen
* interne oder externe Handelssignale
* unterschiedliche Methoden zur Bestimmung der Positionsgröße[/i]

Zusätzliche Einstiege und ein simulierter Hebel können das Verlustrisiko deutlich erhöhen.

[b]Einschränkungen des Backtests[/b]

Die Ergebnisse des Strategietesters basieren ausschließlich auf historischen Kursdaten. Reale Ergebnisse können durch Gebühren, Spread, Slippage, Liquidität, Kurslücken und Ausführungsverzögerungen erheblich abweichen.

Vergangene Ergebnisse sind kein verlässlicher Hinweis auf zukünftige Ergebnisse.

[b]Signale während einer offenen Position[/b]

https://www.tradingview.com/x/NhpoFESM/

Über **Open Position Signals** wird festgelegt, wie neue Signale während einer bereits geöffneten Position behandelt werden:

[i]* **Wait-End-Deal:** Alle neuen Moving-Average-Signale werden ignoriert, bis die aktuelle Position durch ein Gewinnziel, einen Stop-Loss oder eine andere Schutzfunktion beendet wurde.
* **Wait-Reversal:** Ein entgegengesetztes Moving-Average-Signal kann die aktuell geöffnete Position schließen.[/i]

Bei **Wait-Reversal** schließt ein Verkaufssignal eine Long-Position und ein Kaufsignal eine Short-Position. Das entgegengesetzte Signal eröffnet dabei nicht automatisch im selben Schritt eine neue Position.

Preisbasierte zusätzliche Einstiege bleiben von dieser Auswahl unabhängig und können weiterhin ausgeführt werden, sofern sie aktiviert sind.

[b]Stop-Loss, Trailing-Stop, Breakeven und Liquidationslinie[/b]

https://www.tradingview.com/x/84bFwPqf/

Die Strategie unterstützt einen festen Stop-Loss sowie einen nachlaufenden Trailing-Stop. Der eingestellte Prozentwert beschreibt den direkten Kursabstand zum durchschnittlichen Einstiegspreis und wird nicht automatisch durch den simulierten Hebel verändert.

Im Modus **FIXED %** wird der Stop anhand des aktuellen durchschnittlichen Einstiegspreises berechnet. Verändert sich dieser durch einen zusätzlichen Einstieg, wird auch der Stop neu berechnet.

Im Modus **TRAILING** wird der Stop nur in eine für die Position günstigere Richtung nachgezogen. Verändert sich der durchschnittliche Einstiegspreis durch einen zusätzlichen Einstieg, wird der bestehende Trailing-Stop entsprechend angepasst.

Optional kann der Stop nach dem Erreichen des ersten Gewinnziels auf den durchschnittlichen Einstiegspreis verschoben werden. Für diese Breakeven-Funktion muss ein Stop-Modus aktiviert sein.

Die angezeigte Liquidationslinie ist lediglich eine interne Schätzung auf Basis der simulierten Positions- und Kontowerte. Sie kann deutlich von der tatsächlichen Liquidationsberechnung eines Brokers oder einer Börse abweichen.

[b]Verwendung externer Indikatoren[/b]

Anstelle der integrierten Moving-Average-Signale kann eine externe numerische Signalquelle verwendet werden.

Der externe Indikator muss eine auswählbare Plot-Serie mit den folgenden Werten bereitstellen:

[i]* **+1:** Long- beziehungsweise Kaufsignal
* **−1:** Short- beziehungsweise Verkaufssignal[/i]

Bei allen anderen Werten oder bei `na` wird kein neues Signal ausgelöst.

Der externe Indikator muss die benötigten Zahlenwerte direkt über einen auswählbaren Plot ausgeben. Dieser Plot kann anschließend unter **External Source** ausgewählt werden.

Wie ein externes Signal während einer bereits geöffneten Position verarbeitet wird, hängt zusätzlich von der gewählten Einstellung unter **Open Position Signals** ab.

## Source Code

````pine
// © Kpt-Ahab
// [Kpt-Ahab] Moving Average Simple AlgoPilot v2.1

//@version=6

// ---------------------------------------------------
// Strategy Declaration
// ---------------------------------------------------

strategy(
     title = "[Kpt-Ahab] Moving Average Simple AlgoPilot v2.1",
     overlay = true,
     initial_capital = 10000,
     commission_value = 0.1,
     slippage = 0,
     pyramiding = 3,
     margin_long = 0,
     margin_short = 0,
     max_lines_count = 500,
     currency = currency.USD
)

// ---------------------------------------------------
// Input Groups
// ---------------------------------------------------

const string group_time = "Time Filter"
const string group_strategy = "Strategy Settings"
const string group_ma = "Moving Averages"
const string group_opening = "Opening"
const string group_take_profit = "Take Profit"
const string group_strategy_close = "Strategy Close"
const string group_signal_source = "Signal Source"
const string group_colors = "Colors"
const string group_table = "Table"

// ---------------------------------------------------
// Time Filter Inputs
// ---------------------------------------------------

src_timezone = input.string(
     "Exchange",
     "Time Zone Source -> Destination",
     group = group_time,
     inline = "Timezone",
     options = ['Exchange', 'UTC', 'America/Los_Angeles', 'America/Phoenix', 'America/Vancouver', 'America/El_Salvador', 'America/Bogota', 'America/Chicago', 'America/New_York', 'America/Toronto', 'America/Argentina/Buenos_Aires', 'America/Sao_Paulo', 'Etc/UTC', 'Europe/London', 'Europe/Berlin', 'Europe/Madrid', 'Europe/Paris', 'Europe/Warsaw', 'Europe/Athens', 'Europe/Moscow', 'Asia/Tehran', 'Asia/Dubai', 'Asia/Ashkhabad', 'Asia/Kolkata', 'Asia/Almaty', 'Asia/Bangkok', 'Asia/Hong_Kong', 'Asia/Shanghai', 'Asia/Singapore', 'Asia/Taipei', 'Asia/Seoul', 'Asia/Tokyo', 'Australia/ACT', 'Australia/Adelaide', 'Australia/Brisbane', 'Australia/Sydney', 'Pacific/Auckland', 'Pacific/Fakaofo', 'Pacific/Chatham', 'Pacific/Honolulu']
)

dst_timezone = input.string(
     "Exchange",
     "->",
     group = group_time,
     inline = "Timezone",
     options = ['Exchange', 'UTC', 'America/Los_Angeles', 'America/Phoenix', 'America/Vancouver', 'America/El_Salvador', 'America/Bogota', 'America/Chicago', 'America/New_York', 'America/Toronto', 'America/Argentina/Buenos_Aires', 'America/Sao_Paulo', 'Etc/UTC', 'Europe/London', 'Europe/Berlin', 'Europe/Madrid', 'Europe/Paris', 'Europe/Warsaw', 'Europe/Athens', 'Europe/Moscow', 'Asia/Tehran', 'Asia/Dubai', 'Asia/Ashkhabad', 'Asia/Kolkata', 'Asia/Almaty', 'Asia/Bangkok', 'Asia/Hong_Kong', 'Asia/Shanghai', 'Asia/Singapore', 'Asia/Taipei', 'Asia/Seoul', 'Asia/Tokyo', 'Australia/ACT', 'Australia/Adelaide', 'Australia/Brisbane', 'Australia/Sydney', 'Pacific/Auckland', 'Pacific/Fakaofo', 'Pacific/Chatham', 'Pacific/Honolulu'],
     tooltip = "The source is the timezone used as a reference for the time settings. The destination is the timezone to convert into."
)

usefromDate = input.bool(true, "Start From", group = group_time, inline = "From Date")
fromDate = input.time(timestamp("03 Nov 2024 02:00"), "", group = group_time, inline = "From Date")

usetoDate = input.bool(false, "End At", group = group_time, inline = "To Date")
toDate = input.time(timestamp("03 Jul 2039 00:00"), "", group = group_time, inline = "To Date")

// ---------------------------------------------------
// Intraday Session Inputs
// ---------------------------------------------------

use_intraday_session = input.bool(
     false,
     "Use Intraday Market Session",
     group = group_time
)
market_session = input.session(
     "0930-1600",
     "Market Session",
     group = group_time,
     active = use_intraday_session,
     tooltip = "The session is interpreted using the Time Zone Source setting."
)
monday = input.bool(
     true,
     "Mon",
     group = group_time,
     inline = "session_days"
)
tuesday = input.bool(
     true,
     "Tue",
     group = group_time,
     inline = "session_days"
)
wednesday = input.bool(
     true,
     "Wed",
     group = group_time,
     inline = "session_days"
)
thursday = input.bool(
     true,
     "Thu",
     group = group_time,
     inline = "session_days"
)
friday = input.bool(
     true,
     "Fri",
     group = group_time,
     inline = "session_days"
)
saturday = input.bool(
     false,
     "Sat",
     group = group_time,
     inline = "session_days"
)
sunday = input.bool(
     false,
     "Sun",
     group = group_time,
     inline = "session_days"
)

// ---------------------------------------------------
// Opening Inputs
// ---------------------------------------------------

QTYMethod = input.string(
     "EQUITY",
     "Order Size",
     options = ["EQUITY", "SIZE", "CONTRACTS"],
     group = group_opening
)

setdecimal = input.int(
     4,
     "Decimal Places",
     minval = 1,
     maxval = 10,
     step = 1,
     group = group_opening
)

setLeverage = input.int(
     5,
     "Leverage",
     minval = 1,
     maxval = 125,
     step = 1,
     group = group_opening
)

riskPerc = input.float(
     2,
     "Equity %",
     minval = 0.01,
     maxval = 100,
     step = 0.1,
     group = group_opening
)

riskSize = input.int(
     1000,
     "Size",
     minval = 1,
     group = group_opening
)

riskCntr = input.float(
     10,
     "Contracts",
     minval = 0,
     group = group_opening
)

enable_loss_repurchase = input.bool(
     false,
     "Repurchase at Loss",
     group = group_opening
)

PosRepur = input.float(
     5.0,
     "Loss Price %",
     minval = 0.1,
     step = 0.5,
     group = group_opening,
     active = enable_loss_repurchase,
     tooltip = "Adverse price distance from the current average entry that triggers a price-based repurchase. Leverage does not change this distance."
)

FacPos = input.float(
     100.0,
     "Quantity Increase %",
     minval = 0.0,
     step = 1.0,
     group = group_opening,
     active = enable_loss_repurchase
)

// ---------------------------------------------------
// Strategy Settings Inputs
// ---------------------------------------------------

bullDeal = input.bool(
     true,
     "Long",
     group = group_strategy,
     inline = "deal"
)

bearDeal = input.bool(
     true,
     "Short",
     group = group_strategy,
     inline = "deal"
)

open_position_signal_mode = input.string(
     "Wait-End-Deal",
     "Open Position Signals",
     options = [
          "Wait-End-Deal",
          "Wait-Reversal"
     ],
     group = group_strategy,
     tooltip = "Wait-End-Deal ignores all indicator signals while a position is open. Wait-Reversal closes a long on a Sell signal and a short on a Buy signal. Price-based loss repurchases remain independent."
)

stop_mode = input.string(
     "FIXED %",
     "Stop Mode",
     options = ["None", "FIXED %", "TRAILING"],
     group = group_strategy,
     inline = "stop",
     tooltip = "FIXED % remains at the selected direct price distance from the current average entry after every repurchase. TRAILING uses the same direct price distance and preserves its adjusted value after average-entry changes."
)

stop_percent = input.float(
     3.8,
     "Stop %",
     minval = 0.1,
     maxval = 99.9,
     step = 0.1,
     group = group_strategy,
     inline = "stop",
     tooltip = "Direct price distance from the current average entry. A value of 17 places the stop 17% below a long entry or 17% above a short entry. Leverage does not change this distance."
)

// ---------------------------------------------------
// Moving Average Inputs
// ---------------------------------------------------

short_ma_type = input.string(
     "SMA",
     "Short MA",
     options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "None"],
     group = group_ma,
     inline = "short"
)

short_ma_length = input.int(
     29,
     "Length",
     minval = 1,
     group = group_ma,
     inline = "short"
)

long_ma_type = input.string(
     "SMA",
     "Long MA",
     options = ["SMA", "EMA", "WMA", "VWMA", "HMA", "None"],
     group = group_ma,
     inline = "long"
)

long_ma_length = input.int(
     55,
     "Length",
     minval = 1,
     group = group_ma,
     inline = "long"
)

// ---------------------------------------------------
// Take Profit Inputs
// ---------------------------------------------------

profit_percent = input.float(
     10.0,
     "Profit %",
     minval = 0.1,
     step = 1.0,
     group = group_take_profit,
     tooltip = "Final target based on direct price distance. A value of 20 places a long target 20% above the current average entry. Short targets use an inverse price ratio so values of 100% or more remain above zero. Leverage does not change the target."
)

ontake1 = input.bool(
     true,
     "TP1",
     group = group_take_profit,
     inline = "take1"
)

qtake1 = input.int(
     70,
     "Close %",
     minval = 1,
     maxval = 100,
     step = 5,
     group = group_take_profit,
     inline = "take1"
)

tp1Perc = input.float(
     5.0,
     "Target %",
     minval = 0.1,
     group = group_take_profit,
     inline = "take1",
     tooltip = "Direct long price distance. Short targets use the positive inverse-price equivalent."
)

ontake2 = input.bool(
     false,
     "TP2",
     group = group_take_profit,
     inline = "take2"
)

qtake2 = input.int(
     60,
     "Close %",
     minval = 1,
     maxval = 100,
     step = 5,
     group = group_take_profit,
     inline = "take2"
)

tp2Perc = input.float(
     12.0,
     "Target %",
     minval = 0.1,
     group = group_take_profit,
     inline = "take2",
     tooltip = "Direct long price distance. Short targets use the positive inverse-price equivalent."
)

ontpBE = input.bool(
     false,
     "Breakeven after TP1",
     group = group_take_profit
)

// ---------------------------------------------------
// Strategy Close Inputs
// ---------------------------------------------------

setmaxLosingStreak = input.bool(
     false,
     "Maximum Losing Trades",
     group = group_strategy_close,
     inline = "losses"
)

maxLosingStreak = input.int(
     15,
     "Limit",
     minval = 1,
     group = group_strategy_close,
     inline = "losses"
)

setMaxDrawdown = input.bool(
     true,
     "Max Drawdown",
     group = group_strategy_close,
     inline = "drawdown"
)

maxPercDd = input.int(
     10,
     "Max Drawdown %",
     minval = 1,
     maxval = 100,
     group = group_strategy_close,
     inline = "drawdown"
)

// ---------------------------------------------------
// Signal Source Inputs
// ---------------------------------------------------

activ_ext = input.bool(
     false,
     "Use External Signal Source",
     group = group_signal_source,
     tooltip = "Off uses the integrated moving-average crossover signals. On uses the external numeric source: +1 Buy and -1 Sell."
)

ext_source_ = input.source(
     close,
     "External Source",
     group = group_signal_source
)

show_plotshape = input.bool(
     true,
     "Show Active Signals on Chart",
     group = group_signal_source
)

// ---------------------------------------------------
// Color Inputs
// ---------------------------------------------------

ColorScheme = input.string(
     "White ⇅ Pink",
     "Color Scheme",
     options = ["Purple ⇅ Blue", "Yellow ⇅ DarkGreen", "White ⇅ Pink"],
     group = group_colors,
     inline = "scheme"
)

ma_color_intensity = input.int(
     5,
     "MA Color Intensity",
     minval = 0,
     group = group_colors,
     inline = "scheme"
)

// ---------------------------------------------------
// Table Inputs
// ---------------------------------------------------

show_liquidation_lines = input.bool(
     true,
     "Show Liquidation Line",
     group = group_table,
     inline = "liquidation"
)

max_percentage = input.int(
     50,
     "Hide Beyond Entry %",
     minval = 0,
     maxval = 100,
     group = group_table,
     inline = "liquidation",
     tooltip = "Set to 0 to show all liquidation lines."
)

show_PF_table = input.string(
     "Small",
     "Portfolio Table",
     options = ["Large", "Normal", "Small", "Tiny"],
     group = group_table,
     inline = "portfolio"
)

PF_table_location = input.string(
     "Bottom Left",
     "Position",
     options = ["Bottom Left", "Bottom Right"],
     group = group_table,
     inline = "portfolio"
)

// ---------------------------------------------------
// Moving Average Calculation
// ---------------------------------------------------

short_hma = ta.wma(
     2.0 * ta.wma(close, math.round(short_ma_length / 2.0)) - ta.wma(close, short_ma_length),
     math.round(math.sqrt(short_ma_length))
)

long_hma = ta.wma(
     2.0 * ta.wma(close, math.round(long_ma_length / 2.0)) - ta.wma(close, long_ma_length),
     math.round(math.sqrt(long_ma_length))
)

short_ma = switch short_ma_type
    "SMA"  => ta.sma(close, short_ma_length)
    "EMA"  => ta.ema(close, short_ma_length)
    "WMA"  => ta.wma(close, short_ma_length)
    "VWMA" => ta.vwma(close, short_ma_length)
    "HMA"  => short_hma
    => na

long_ma = switch long_ma_type
    "SMA"  => ta.sma(close, long_ma_length)
    "EMA"  => ta.ema(close, long_ma_length)
    "WMA"  => ta.wma(close, long_ma_length)
    "VWMA" => ta.vwma(close, long_ma_length)
    "HMA"  => long_hma
    => na

// ---------------------------------------------------
// Moving Average Signal Conditions
// ---------------------------------------------------

signal_buy = ta.crossover(short_ma, long_ma)
signal_sell = ta.crossunder(short_ma, long_ma)

// ---------------------------------------------------
// Strategy Signal Source
// ---------------------------------------------------

external_signal = nz(ext_source_)

signal_buy_in = external_signal == 1.0
signal_sell_in = external_signal == -1.0

signal_buy_out = activ_ext ? signal_buy_in : signal_buy
signal_sell_out = activ_ext ? signal_sell_in : signal_sell

var int signalout = 0

if signal_buy
    signalout := 1

if signal_sell
    signalout := -1

plot(
     signalout,
     title = "Signal Output",
     display = display.none
)

// ---------------------------------------------------
// Active Signal Markers
// ---------------------------------------------------

plotshape(
     show_plotshape and signal_buy_out,
     title = "Buy Signal",
     color = #48ff00,
     style = shape.triangleup,
     location = location.belowbar,
     size = size.tiny,
     editable = false
)

plotshape(
     show_plotshape and signal_sell_out,
     title = "Sell Signal",
     color = #ff0000,
     style = shape.triangledown,
     location = location.abovebar,
     size = size.tiny,
     editable = false
)

// ---------------------------------------------------
// Strategy Alerts
// ---------------------------------------------------

if signal_buy_out
    alert("Simple AlgoPilot buy signal.", alert.freq_once_per_bar_close)

if signal_sell_out
    alert("Simple AlgoPilot sell signal.", alert.freq_once_per_bar_close)

// ---------------------------------------------------
// Risk Display Colors
// ---------------------------------------------------

bool Scheme2 = ColorScheme == "Purple ⇅ Blue"
bool Scheme4 = ColorScheme == "White ⇅ Pink"

color Col1 = na
color Col2 = na
color Col3 = na
color Col4 = na
color Col6 = na

if Scheme4
    Col1 := color.rgb(224, 224, 224, 60)
    Col2 := color.rgb(234, 0, 255, 30)
    Col3 := color.rgb(224, 224, 224, 80)
    Col4 := color.rgb(234, 0, 255, 70)
    Col6 := color.rgb(0, 0, 0, 40)
else if Scheme2
    Col1 := color.rgb(0, 64, 146, 40)
    Col2 := color.rgb(104, 0, 194, 50)
    Col3 := color.rgb(0, 64, 146, 80)
    Col4 := color.rgb(104, 0, 194, 80)
    Col6 := color.rgb(0, 0, 0, 40)
else
    Col1 := color.rgb(3, 101, 3, 48)
    Col2 := color.rgb(255, 235, 59, 48)
    Col3 := color.rgb(109, 164, 0, 80)
    Col4 := color.rgb(255, 235, 59, 80)
    Col6 := color.rgb(76, 50, 40)

// ---------------------------------------------------
// Moving Average Visuals
// ---------------------------------------------------

ma_reference_plot = plot(
     close,
     title = "MA Reference",
     color = color.new(color.gray, 100),
     linewidth = 1,
     editable = false
)

ma_distance = math.abs(short_ma - long_ma)
ma_log_distance = math.log(ma_distance + 1.0)
ma_transparency = int(math.min(100.0, math.max(0.0, 90.0 - ma_log_distance * ma_color_intensity)))

ma_bull_color = color.new(Col1, ma_transparency)
ma_bear_color = color.new(Col2, ma_transparency)

plot(
     short_ma,
     title = "Short MA",
     color = Col1,
     linewidth = 1
)

long_ma_plot = plot(
     long_ma,
     title = "Long MA",
     color = Col2,
     linewidth = 1
)

price_above_long_ma = close > long_ma
price_below_long_ma = close < long_ma

fill(
     long_ma_plot,
     ma_reference_plot,
     price_above_long_ma ? long_ma : close,
     price_above_long_ma ? close : na,
     top_color = ma_bull_color,
     bottom_color = color(na)
)

fill(
     long_ma_plot,
     ma_reference_plot,
     price_below_long_ma ? long_ma : close,
     price_below_long_ma ? close : na,
     top_color = ma_bear_color,
     bottom_color = color(na)
)

// ---------------------------------------------------
// Strategy Signal Mapping
// ---------------------------------------------------

bull = signal_buy_out and bullDeal
bear = signal_sell_out and bearDeal

// ---------------------------------------------------
// Time Zone Conversion
// ---------------------------------------------------

ex_timezone(simple string tz) =>
    switch tz
        'Exchange' => syminfo.timezone
        => tz

string session_timezone =
     ex_timezone(src_timezone)
if_in_date_range(simple bool usefromDate, simple int fromDate, simple bool usetoDate, simple int toDate, simple string src_timezone = 'Exchange', simple string dst_timezone = 'Exchange', int t = time_close) =>
    var src_tz     = ex_timezone(src_timezone)
    var dst_tz     = ex_timezone(dst_timezone)
    var fromDateTz = timestamp(src_tz, year(fromDate, dst_tz), month(fromDate, dst_tz), dayofmonth(fromDate, dst_tz), hour(fromDate, dst_tz), minute(fromDate, dst_tz), second(fromDate, dst_tz))
    var toDateTz   = timestamp(src_tz, year(toDate, dst_tz), month(toDate, dst_tz), dayofmonth(toDate, dst_tz), hour(toDate, dst_tz), minute(toDate, dst_tz), second(toDate, dst_tz))
    (usefromDate ? t >= fromDateTz : true) and (usetoDate ? t < toDateTz : true)
f_session_minutes(string session_value, bool start_value) =>
    int offset = start_value ? 0 : 5
    int session_hour = int(str.tonumber(
         str.substring(session_value, offset, offset + 2)))
    int session_minute = int(str.tonumber(
         str.substring(session_value, offset + 2, offset + 4)))
    session_hour * 60 + session_minute

// ---------------------------------------------------
// Intraday Session
// ---------------------------------------------------

string market_session_days =
     (sunday ? "1" : "") +
     (monday ? "2" : "") +
     (tuesday ? "3" : "") +
     (wednesday ? "4" : "") +
     (thursday ? "5" : "") +
     (friday ? "6" : "") +
     (saturday ? "7" : "")
bool has_session_days =
     str.length(market_session_days) > 0
string market_session_string =
     market_session + ":" +
     (has_session_days ? market_session_days : "1234567")
bool in_market_session =
     use_intraday_session and
     has_session_days and
     not na(time(
          timeframe.period,
          market_session_string,
          session_timezone))
int session_start_minutes =
     f_session_minutes(market_session, true)
int session_end_minutes =
     f_session_minutes(market_session, false)
int local_bar_minutes =
     hour(time, session_timezone) * 60 +
     minute(time, session_timezone)
bool overnight_session =
     session_end_minutes <= session_start_minutes
int session_end_day_offset =
     overnight_session and
     local_bar_minutes >= session_start_minutes ?
     1 :
     0
int session_end_hour =
     int(math.floor(session_end_minutes / 60.0))
int session_end_minute =
     session_end_minutes % 60
int session_end_time = timestamp(
     session_timezone,
     year(time, session_timezone),
     month(time, session_timezone),
     dayofmonth(time, session_timezone) + session_end_day_offset,
     session_end_hour,
     session_end_minute)
bool session_entry_approval =
     not use_intraday_session or
     (
          has_session_days and
          in_market_session and
          time_close < session_end_time
     )
bool session_close_bar =
     use_intraday_session and
     has_session_days and
     in_market_session and
     time_close >= session_end_time
bool dateFilterApproval = if_in_date_range(
     usefromDate,
     fromDate,
     usetoDate,
     toDate,
     src_timezone,
     dst_timezone)
bool timeFilterApproval =
     dateFilterApproval and
     session_entry_approval

// ---------------------------------------------------
// Order Size
// ---------------------------------------------------

eqty = switch QTYMethod
    'EQUITY'    => riskPerc / close
    'SIZE'      => riskSize / close
    'CONTRACTS' => riskCntr

// ---------------------------------------------------
// Price Conversion Helpers
// ---------------------------------------------------

favorable_long_price(base_price, price_percent) =>
    base_price * (1.0 + price_percent / 100.0)

favorable_short_price(base_price, price_percent) =>
    base_price / (1.0 + price_percent / 100.0)

repurchase_long_trigger_price(base_price, price_percent) =>
    base_price * (1.0 - price_percent / 100.0)

repurchase_short_trigger_price(base_price, price_percent) =>
    base_price * (1.0 + price_percent / 100.0)

long_stop_price(base_price, price_percent) =>
    base_price * (1.0 - price_percent / 100.0)

short_stop_price(base_price, price_percent) =>
    base_price * (1.0 + price_percent / 100.0)

// ---------------------------------------------------
// Trade State
// ---------------------------------------------------

multiplier   = 1 + (FacPos / 100)
entry        = strategy.position_avg_price
sizePos      = strategy.position_size
Factor       = strategy.position_size * multiplier - strategy.position_size
inLong       = sizePos > 0
inShort      = sizePos < 0
inTrade      = inLong or inShort
inPos        = (inLong and not inShort[1]) or (inShort and not inLong[1])
newLong      = inLong and not inLong[1]
newShort     = inShort and not inShort[1]
var ID       = 'TradeID'
var float slPrice = na
var float tpPrice = na
var float trailingStopLong = na
var float trailingStopShort = na

// ---------------------------------------------------
// Session Close State
// ---------------------------------------------------

bool session_close_request =
     use_intraday_session and
     inTrade and
     (
          session_close_bar or
          not in_market_session
     )

// ---------------------------------------------------
// Risk Approval
// ---------------------------------------------------

condmaxdrawdown = setMaxDrawdown ? maxPercDd : 100
strategy.risk.max_drawdown(value=condmaxdrawdown, type=strategy.percent_of_equity)

okToTradeLossStreak = setmaxLosingStreak ? strategy.losstrades < maxLosingStreak : true

// ---------------------------------------------------
// Entry and Open Position Signals
// ---------------------------------------------------

entry_allowed =
     timeFilterApproval and
     okToTradeLossStreak and
     not inTrade

goLong =
     bull and
     entry_allowed

goShort =
     bear and
     entry_allowed

allow_reversal_close =
     open_position_signal_mode == "Wait-Reversal"

close_long_request =
     inLong and
     allow_reversal_close and
     signal_sell_out

close_short_request =
     inShort and
     allow_reversal_close and
     signal_buy_out

// ---------------------------------------------------
// Final Profit Target
// ---------------------------------------------------

if inLong
    tpPrice := favorable_long_price(entry, profit_percent)
else if inShort
    tpPrice := favorable_short_price(entry, profit_percent)
else
    tpPrice := na

// ---------------------------------------------------
// Stop Loss
// ---------------------------------------------------

stop_enabled = stop_mode != "None"

if not inTrade
    slPrice := na
    trailingStopLong := na
    trailingStopShort := na

else if stop_mode == "FIXED %"
    trailingStopLong := na
    trailingStopShort := na

    slPrice :=
         inLong ? long_stop_price(entry, stop_percent) :
         inShort ? short_stop_price(entry, stop_percent) :
         na

else if stop_mode == "TRAILING"
    if inLong
        previous_long_stop =
             newLong ?
                  long_stop_price(entry, stop_percent) :
                  nz(trailingStopLong[1], long_stop_price(entry, stop_percent))

        if inLong[1] and not na(entry[1]) and entry[1] != 0.0 and entry != entry[1]
            previous_long_stop *= entry / entry[1]

        trailing_candidate_long =
             long_stop_price(close, stop_percent)

        trailingStopLong :=
             math.max(previous_long_stop, trailing_candidate_long)

        trailingStopShort := na
        slPrice := trailingStopLong

    else if inShort
        previous_short_stop =
             newShort ?
                  short_stop_price(entry, stop_percent) :
                  nz(trailingStopShort[1], short_stop_price(entry, stop_percent))

        if inShort[1] and not na(entry[1]) and entry[1] != 0.0 and entry != entry[1]
            previous_short_stop *= entry / entry[1]

        trailing_candidate_short =
             short_stop_price(close, stop_percent)

        trailingStopShort :=
             math.min(previous_short_stop, trailing_candidate_short)

        trailingStopLong := na
        slPrice := trailingStopShort

else
    slPrice := na
    trailingStopLong := na
    trailingStopShort := na

// ---------------------------------------------------
// Partial Profit Targets
// ---------------------------------------------------

entryPrice = strategy.position_avg_price

calculateTP(levelPerc) =>
    if strategy.position_size > 0
        favorable_long_price(entryPrice, levelPerc)
    else if strategy.position_size < 0
        favorable_short_price(entryPrice, levelPerc)
    else
        na

CheckLevel(lvl) =>
    var float level = na
    if (inLong and high >= lvl) or (inShort and low <= lvl)
        level := entry
    if not inTrade
        level := na
    level

take1 = calculateTP(tp1Perc), checkTake1 = CheckLevel(take1)
take2 = calculateTP(tp2Perc), checkTake2 = CheckLevel(take2)

// ---------------------------------------------------
// Breakeven Stop
// ---------------------------------------------------

var bool conditionTriggeredlong  = false
var bool conditionTriggeredshort = false

if inLong and high[1] > take1
    conditionTriggeredlong := true

if conditionTriggeredlong and ontpBE and stop_enabled and (na(slPrice) or slPrice < entryPrice)
    slPrice := entryPrice

    if stop_mode == "TRAILING"
        trailingStopLong := slPrice

if inShort and low[1] < take1
    conditionTriggeredshort := true

if conditionTriggeredshort and ontpBE and stop_enabled and (na(slPrice) or slPrice > entryPrice)
    slPrice := entryPrice

    if stop_mode == "TRAILING"
        trailingStopShort := slPrice

if not inTrade or newLong or newShort
    conditionTriggeredlong := false
    conditionTriggeredshort := false

// ---------------------------------------------------
// Strategy Entries
// ---------------------------------------------------

decimal = math.pow(10, setdecimal)

eqty(qty) => QTYMethod == 'EQUITY' ? math.floor(qty / 100 * (strategy.initial_capital * setLeverage) * decimal) / decimal : QTYMethod == 'SIZE' ? math.floor(qty / syminfo.pointvalue * decimal) / decimal : qty

if goLong
    ID := "Long"
    strategy.entry(
         ID,
         strategy.long,
         qty = math.floor((eqty(eqty) + Factor) * decimal) / decimal,
         comment = ID,
         alert_message = ID + "Entry"
    )

if goShort
    ID := "Short"
    strategy.entry(
         ID,
         strategy.short,
         qty = math.floor((eqty(eqty) - Factor) * decimal) / decimal,
         comment = ID,
         alert_message = ID + "Entry"
    )

long_repurchase_level =
     inLong ? repurchase_long_trigger_price(entry, PosRepur) : na

short_repurchase_level =
     inShort ? repurchase_short_trigger_price(entry, PosRepur) : na

if inLong and
     timeFilterApproval and
     not session_close_request and
     enable_loss_repurchase and
     not close_long_request and
     close < long_repurchase_level
    strategy.entry(
         ID,
         strategy.long,
         qty = math.floor((eqty(eqty) + Factor) * decimal) / decimal,
         comment = "Long+",
         alert_message = ID + "Entry"
    )
if inShort and
     timeFilterApproval and
     not session_close_request and
     enable_loss_repurchase and
     not close_short_request and
     close > short_repurchase_level
    strategy.entry(
         ID,
         strategy.short,
         qty = math.floor((eqty(eqty) - Factor) * decimal) / decimal,
         comment = "Short+",
         alert_message = ID + "Entry"
    )

// ---------------------------------------------------
// Signal-Based Position Closing
// ---------------------------------------------------

if close_long_request and not session_close_request
    strategy.close(
         "Long",
         comment = "Reversal Close Long",
         alert_message = "Reversal Close Long"
    )

if close_short_request and not session_close_request
    strategy.close(
         "Short",
         comment = "Reversal Close Short",
         alert_message = "Reversal Close Short"
    )

// ---------------------------------------------------
// Protective Orders
// ---------------------------------------------------

active_positions = strategy.opentrades

qty(percent) => math.floor(math.abs(strategy.position_size * percent / 100) / active_positions * decimal) / decimal
if inTrade and not session_close_request
    strategy.exit(
         "End_1",
         ontake1 ? ID : "na",
         qty = qty(qtake1),
         limit = take1,
         stop = stop_enabled ? slPrice : na,
         comment_profit = "TP 1",
         comment_loss = "SL 1",
         alert_message = ID + " SL/TP 1 Trigger"
    )

    strategy.exit(
         "End_2",
         ontake2 ? ID : "na",
         qty = qty(qtake2),
         limit = take2,
         stop = stop_enabled ? slPrice : na,
         comment_profit = "TP 2",
         comment_loss = "SL 2",
         alert_message = ID + " SL/TP 2 Trigger"
    )

    strategy.exit(
         "End_6",
         ID,
         limit = tpPrice,
         stop = stop_enabled ? slPrice : na,
         comment_profit = "CLOSE",
         comment_loss = "Close",
         alert_message = ID + " SL/TP X Trigger"
    )

// ---------------------------------------------------
// Session Position Closing
// ---------------------------------------------------

if session_close_request
    strategy.cancel_all()
    strategy.close_all(
         comment = "Session Close",
         alert_message = "Session Close",
         immediately = true
    )
else if stop_enabled and
     not na(slPrice) and
     (
          inLong and close < slPrice or
          inShort and close > slPrice
     )
    strategy.close_all(
         comment = "SL"
    )
    
// ---------------------------------------------------
// Drawdown Tracking
// ---------------------------------------------------

var float initialCapital = strategy.initial_capital

var float peakCapital = initialCapital

var float maxDrawdownPercent = 0.0

if (strategy.equity > peakCapital)
    peakCapital := strategy.equity
else
    float currentDrawdown = 100 * (peakCapital - strategy.equity) / peakCapital
    if (currentDrawdown > maxDrawdownPercent)
        maxDrawdownPercent := currentDrawdown

// ---------------------------------------------------
// Position Visuals
// ---------------------------------------------------

plotColy = inLong ? Col3 : inShort ? Col4 : na
tpcolor = Col1
tp = plot(inPos ? tpPrice : na, 'Take7', color=Col1, style=plot.style_linebr, editable=false)
sl = plot(inPos and stop_enabled ? slPrice : na, 'Stop', color=Col2, style=plot.style_linebr, editable=false)
en = plot(stop_enabled ? (inLong and slPrice > entry or inShort and slPrice < entry ? slPrice : entry) : inPos ? close : na, 'Price', color=stop_enabled ? Col6 : na, style=plot.style_linebr)

fill(tp, en, tpPrice, entry, top_color=color(na), bottom_color=stop_enabled ? Col3 : plotColy, editable=false)
fill(sl, en, entry, slPrice, top_color=stop_enabled ? Col4 : plotColy, bottom_color=color(na), editable=false)

plotchar(inPos and not inPos[1] ? tpPrice : na, 'Take Start', color=Col1, char='', location=location.absolute, size=size.tiny, editable=false)
plotchar(inPos and not inPos[1] and stop_enabled ? slPrice : na, 'Stop Start', color=Col2, char='', location=location.absolute, size=size.tiny, editable=false)

plot(inPos and ontake1 and na(checkTake1[1]) ? take1 : na, 'TP 1', color=tpcolor, style=plot.style_cross, editable=false)
plot(inPos and ontake2 and na(checkTake2[1]) ? take2 : na, 'TP 2', color=tpcolor, style=plot.style_cross, editable=false)

plot(inPos and ontake1 and not na(checkTake1[1]) ? take1 : na, 'TP 1 Reached', color=color.rgb(246, 4, 226, 100), style=plot.style_cross, editable=false)
plot(inPos and ontake2 and not na(checkTake2[1]) ? take2 : na, 'TP 2 Reached', color=color.rgb(246, 4, 226, 100), style=plot.style_cross, editable=false)

// ---------------------------------------------------
// Portfolio Metrics
// ---------------------------------------------------

table_net_profit = strategy.netprofit
table_realised_balance = strategy.initial_capital + strategy.netprofit
table_open_profit = strategy.openprofit
table_equity = strategy.equity
table_position_size = math.abs(strategy.position_size)
table_avg_price = nz(strategy.position_avg_price)

// ---------------------------------------------------
// Liquidation Lines
// ---------------------------------------------------

liq_price_long = table_avg_price - (table_realised_balance / table_position_size)
liq_price_long := liq_price_long < 0 ? 0 : liq_price_long
liq_price_short = table_avg_price + (table_realised_balance / table_position_size)

max_distance = table_avg_price * (max_percentage / 100)

if (show_liquidation_lines)
    if (max_percentage == 0)
        if (strategy.position_size > 0)
            line.new(bar_index, liq_price_long, bar_index + 1, liq_price_long, color=#ffff00, width=2, style=line.style_dotted)

        if (strategy.position_size < 0)
            line.new(bar_index, liq_price_short, bar_index + 1, liq_price_short, color=#ffff00, width=2, style=line.style_dotted)
    else
        if (strategy.position_size > 0 and math.abs(liq_price_long - table_avg_price) <= max_distance)
            line.new(bar_index, liq_price_long, bar_index + 1, liq_price_long, color=#ffff00, width=2, style=line.style_dotted)

        if (strategy.position_size < 0 and math.abs(liq_price_short - table_avg_price) <= max_distance)
            line.new(bar_index, liq_price_short, bar_index + 1, liq_price_short, color=#ffff00, width=2, style=line.style_dotted)

// ---------------------------------------------------
// Portfolio Table
// ---------------------------------------------------

ftext_color(_bgcolor) =>

    var float luminance = 0.299 * color.r(_bgcolor) + 0.587 * color.g(_bgcolor) + 0.114 * color.b(_bgcolor)
    luminance > 128 ? color.rgb(0, 0, 0) : color.rgb(255, 255, 255)

bool PF_table_size_tiny = show_PF_table == 'Tiny'
bool PF_table_size_small = show_PF_table == 'Small'
bool PF_table_size_normal = show_PF_table == 'Normal'
bool PF_table_size_large = show_PF_table == 'Large'
string PF_table_loc = PF_table_location == "Bottom Left" ? position.bottom_left : position.bottom_right

var table portfolio_table = table.new(PF_table_loc, 4, 14, border_width = 1)
ftable(_table_id, _column, _row, _text, _bgcolor) =>
    table.cell(_table_id, _column, _row, _text, 0, 0, ftext_color(_bgcolor), text.align_right, text.align_center, PF_table_size_tiny ? size.tiny : PF_table_size_small ? size.small : PF_table_size_normal ? size.normal : PF_table_size_large ? size.large : na, _bgcolor)
ftable(portfolio_table, 0, 0, 'Equity: ', Col1)
ftable(portfolio_table, 1, 0, str.tostring(table_equity, '#.##') + ' ' + syminfo.currency, table_equity >= 0 ? color.green : color.red)

ftable(portfolio_table, 0, 1, "Unrealized Profit: ", Col1)
ftable(portfolio_table, 1, 1, str.tostring(table_open_profit, '#.##') + ' ' + syminfo.currency, table_open_profit >= 0 ? color.green : color.red)

ftable(portfolio_table, 0, 2, "Strategy Profit: ", Col1)
ftable(portfolio_table, 1, 2, str.tostring(table_net_profit, '#.##') + ' ' + syminfo.currency, table_net_profit >= 0 ? color.green : color.red)

ftable(portfolio_table, 0, 3, 'Leverage: ', Col1)
ftable(portfolio_table, 1, 3, str.tostring(setLeverage), Col4)

ftable(portfolio_table, 0, 4, "Winning Trades: ", Col1)
ftable(portfolio_table, 1, 4, str.tostring(strategy.wintrades),Col4)

ftable(portfolio_table, 0, 5, "Losing Trades: ", Col1)
ftable(portfolio_table, 1, 5, str.tostring(strategy.losstrades),Col4)

ftable(portfolio_table, 0, 6, 'Max Drawdown:', Col1)
ftable(portfolio_table, 1, 6, str.tostring(maxDrawdownPercent, '#.#') + ' %',Col4)

ftable(portfolio_table, 0, 7, "Hit Rate: ", Col1)
ftable(portfolio_table, 1, 7, str.tostring(strategy.wintrades / strategy.closedtrades * 100, '#.#') + ' %',Col4)

ftable(portfolio_table, 0, 8, 'Entry:', Col1)
if inPos
    ftable(portfolio_table, 1, 8, str.tostring(table_avg_price, '#.####') + ' ' + syminfo.currency, color.rgb(0, 255, 242, 17))
else
    ftable(portfolio_table, 1, 8, '0', color.black)

ftable(portfolio_table, 0, 9, "Liquidation Price: ", Col1)
if inPos
    if (strategy.position_size > 0)
        ftable(portfolio_table, 1, 9, str.tostring(liq_price_long, '#.####') + ' ' + syminfo.currency, color.rgb(255, 242, 0))
    if (strategy.position_size < 0)
        ftable(portfolio_table, 1, 9, str.tostring(liq_price_short, '#.####') + ' ' + syminfo.currency, color.rgb(255, 242, 0))
else
    ftable(portfolio_table, 1, 9, '0', color.black)

if inPos and inLong
    ftable(portfolio_table, 0, 10, '', color.rgb(0, 255, 47))
    ftable(portfolio_table, 1, 10, 'IN LONG POSITION', color.rgb(0, 255, 47))
else if inPos and inShort
    ftable(portfolio_table, 0, 10, '', color.rgb(255, 0, 204))
    ftable(portfolio_table, 1, 10, 'IN SHORT POSITION', color.rgb(255, 0, 204))
else
    ftable(portfolio_table, 0, 10, '', color.rgb(0, 0, 0))
    ftable(portfolio_table, 1, 10, '', color.rgb(0, 0, 0))
````
