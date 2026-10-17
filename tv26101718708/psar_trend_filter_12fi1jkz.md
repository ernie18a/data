# PSAR Trend Filter

- url: https://www.tradingview.com/script/12Fi1jkz-PSAR-Trend-Filter/
- type: indicator
- pine_id: PUB;f648e918aa434f48a2a2c488d1020283
- version: 1.0

## Description

PSAR Trend Filter is an event-based trend filtering indicator built around Parabolic SAR reversals.
It helps separate ordinary PSAR direction changes from events that also meet the selected trend direction, movement strength, and confirmation requirements.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 CORE CONCEPT
PSAR Trend Filter is not designed as a simple combination of several independent indicators.
The script uses a structured validation sequence for one specific event:
Parabolic SAR identifies a possible direction change.
EMA checks whether the event agrees with the broader price direction.
ADX evaluates the strength of the current directional movement.
Optional candle confirmation checks the direction of the signal candle.
Cooldown limits signals that occur too close to one another.
Bar-close confirmation controls signal stability in real time.
Parabolic SAR is the only source of the initial event.
EMA, ADX, and the additional filters do not generate independent signals. Their role is to approve or reject a new crossover between price and PSAR.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THESE COMPONENTS ARE COMBINED
Each component has a separate function within one unified validation process.
🔹 PARABOLIC SAR — EVENT TIMING
An UP candidate appears when the closing price crosses above the PSAR value.
A DOWN candidate appears when the closing price crosses below the PSAR value.
An UP or DOWN label cannot appear without a new crossover between price and PSAR.
PSAR determines the timing of the event, but on its own it may change direction frequently during sideways or irregular market conditions.
🔹 EMA — DIRECTIONAL CONTEXT
EMA is used as a broader directional filter.
An UP event is allowed only when the closing price is above the EMA.
A DOWN event is allowed only when the closing price is below the EMA.
EMA does not generate a signal independently. It checks whether the new PSAR reversal agrees with the current directional context.
🔹 ADX — MOVEMENT STRENGTH
ADX evaluates the strength of directional movement without identifying whether that movement is bullish or bearish.
A PSAR event is accepted only when the ADX value is equal to or greater than the minimum level selected by the user.
The same length is used for the Directional Index calculation and ADX smoothing.
The purpose of this filter is to reject PSAR events that occur when measured directional strength is below the selected threshold.
🔹 CANDLE CONFIRMATION
When candle confirmation is enabled:
• UP requires a bullish candle, where the closing price is above the opening price.
• DOWN requires a bearish candle, where the closing price is below the opening price.
This is an additional check performed directly on the bar where the event occurs.
Candle confirmation is disabled by default.
🔹 COOLDOWN — SIGNAL FREQUENCY CONTROL
Cooldown prevents new accepted signals from appearing for a selected number of complete bars after the previous accepted signal.
A signal rejected by the cooldown condition is not postponed or restored later.
The next signal opportunity requires a new crossover between price and PSAR.
🔹 BAR-CLOSE CONFIRMATION
By default, UP and DOWN signals are confirmed only after the current bar closes.
This reduces the possibility of a label appearing while the bar is forming and disappearing before the bar closes.
When bar-close confirmation is disabled, UP or DOWN conditions may change during the formation of the current bar.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 UP SIGNAL LOGIC
An UP label appears only when all enabled conditions are satisfied on the same bar:
• The closing price crosses above Parabolic SAR.
• The closing price is above the EMA when the EMA filter is enabled.
• ADX is equal to or greater than the selected minimum when the ADX filter is enabled.
• The candle is bullish when candle confirmation is enabled.
• The cooldown requirement is satisfied.
• The bar is closed when bar-close confirmation is enabled.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📉 DOWN SIGNAL LOGIC
A DOWN label appears only when all enabled conditions are satisfied on the same bar:
• The closing price crosses below Parabolic SAR.
• The closing price is below the EMA when the EMA filter is enabled.
• ADX is equal to or greater than the selected minimum when the ADX filter is enabled.
• The candle is bearish when candle confirmation is enabled.
• The cooldown requirement is satisfied.
• The bar is closed when bar-close confirmation is enabled.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ EVENT-BASED ARCHITECTURE
All enabled filters must approve the event directly on the bar where price crosses PSAR.
For example, when an UP crossover occurs while ADX is below the selected minimum, the signal is rejected.
If ADX rises above the threshold on a later bar, the script does not generate a delayed UP signal. A new crossover between price and PSAR is required before another signal can be evaluated.
The indicator does not maintain a pending signal after a rejected reversal.
Each PSAR event is evaluated only at the moment it occurs.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💎 ORIGINALITY AND PRACTICAL PURPOSE
Parabolic SAR, EMA, and ADX are established technical analysis concepts.
The originality of PSAR Trend Filter is not based on claiming that the standard formulas behind these indicators are new.
The distinction lies in how the components are organized and how they work together within one event-based validation architecture.
The components are not treated as several equal or independent signals:
• PSAR is the only event trigger.
• EMA checks directional alignment.
• ADX checks movement strength.
• Candle confirmation checks agreement on the signal bar.
• Cooldown controls the spacing between accepted events.
• Bar-close confirmation determines whether the signal must wait for the bar to finish.
This structure creates a clear distinction between:
• the underlying Parabolic SAR state;
• a new PSAR reversal;
• a filtered UP or DOWN event.
The chart continuously displays the current PSAR state, while UP and DOWN labels and their corresponding alerts appear only after the complete enabled validation sequence is satisfied.
The signal architecture and implementation were developed specifically for this script.
No code from other published TradingView Community scripts was reused.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👁 HOW TO READ THE CHART
🟢 Green PSAR dots
The closing price is above the current Parabolic SAR value.
🔴 Red PSAR dots
The closing price is below the current Parabolic SAR value.
🟢 Green fill
Represents the current underlying upward PSAR state.
🔴 Red fill
Represents the current underlying downward PSAR state.
〰 Gray line
The EMA used by the directional filter.
⬆ UP label
An upward PSAR crossover approved by all enabled filters.
⬇ DOWN label
A downward PSAR crossover approved by all enabled filters.
Important:
The PSAR dots and colored fill represent the underlying PSAR state.
They do not mean that the EMA, ADX, candle confirmation, cooldown, and bar-close conditions have all been satisfied.
Only the UP and DOWN labels represent filtered events.
UP and DOWN describe the direction of an approved event. They are not automatic instructions to open or close a position.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠 DEFAULT SETTINGS
Parabolic SAR
• PSAR Start: 0.02
• PSAR Increment: 0.02
• PSAR Maximum: 0.20
Signal filters
• Confirm Signals On Bar Close: enabled
• EMA Trend Filter: enabled
• EMA Length: 50
• ADX Strength Filter: enabled
• ADX Length: 14
• Minimum ADX: 15
• Candle Confirmation: disabled
• Cooldown Between Signals: enabled
• Cooldown Bars: 1
Visual settings
• UP/DOWN labels: enabled
• PSAR trend fill: enabled
• EMA display: enabled
If the selected PSAR Maximum value is lower than PSAR Start, the script uses PSAR Start as the effective maximum value.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 HOW TO USE THE INDICATOR
Start with the default settings and compare the UP and DOWN labels with ordinary changes in the color and position of the PSAR dots.
This makes it possible to observe which PSAR reversals were rejected by the additional filters.
EMA Length
• A higher EMA length creates a slower directional filter.
• A lower EMA length makes the filter more responsive to recent price changes.
Minimum ADX
• A higher threshold requires stronger measured directional movement.
• A lower threshold allows more PSAR reversal events to pass the strength filter.
Candle Confirmation
Enable this setting when the direction of the signal candle should agree with the direction of the event.
Cooldown Bars
Increase this value to create more distance between accepted signals.
Disabling individual filters
Each filter can be disabled separately to evaluate its influence on the number and location of signals.
Settings should be evaluated for the selected symbol, timeframe, and market conditions.
A single parameter combination should not be considered universal for every market.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS
The script provides two separate alert conditions:
• PSAR Filtered UP
• PSAR Filtered DOWN
To keep alert behavior consistent with confirmed labels on the chart:
• keep Confirm Signals On Bar Close enabled;
• select Once Per Bar Close when creating the alert.
The alert message includes:
• event direction;
• exchange;
• symbol;
• timeframe;
• closing price.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏳ REALTIME BEHAVIOR
When bar-close confirmation is enabled, UP and DOWN labels are accepted only after the current bar has closed.
While the realtime bar is still forming, the following values may continue to update:
• the current PSAR value;
• the EMA value;
• the color of the PSAR dots;
• the colored PSAR fill.
These elements use current-bar market data.
When Confirm Signals On Bar Close is disabled, an UP or DOWN condition may appear and disappear before the current bar closes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡 FUTURE DATA AND REPAINTING CONSIDERATIONS
The script does not use:
• future data;
• higher-timeframe lookahead;
• negative plot offsets;
• backward placement of signals on earlier bars;
• retrospective relocation of UP or DOWN labels.
When bar-close confirmation is enabled, filtered UP and DOWN events are accepted only on confirmed bars.
For more stable realtime behavior, keep Confirm Signals On Bar Close enabled and use Once Per Bar Close alerts.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS
• Parabolic SAR is sensitive to changes in direction and may reverse frequently during sideways or irregular price movement.
• EMA and ADX are calculated from historical and current price data and therefore introduce lag.
• ADX measures strength but does not determine bullish or bearish direction.
• A signal rejected by one of the filters is not postponed to a later bar.
• Every new signal requires a new crossover between price and PSAR.
• The indicator does not calculate position size.
• The indicator does not determine acceptable risk.
• The indicator does not set stop-loss or take-profit levels.
• The indicator does not estimate expected returns.
• This script is an indicator, not an automated backtesting strategy.
• Results may vary depending on the symbol, timeframe, volatility, and market regime.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚖️ IMPORTANT
PSAR Trend Filter is an analytical tool.
It does not guarantee:
• the accuracy of every signal;
• profitability;
• the absence of losing trades;
• any specific future market result.
The user remains responsible for signal interpretation, risk management, and all trading decisions.

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © MarketStructureLab

indicator(
     "PSAR Trend Filter",
     shorttitle = "PSAR Trend Filter",
     overlay = true
)

//---------------------------------------------------------
// INPUT GROUPS
//---------------------------------------------------------
const string calcGroup   = "Calculation"
const string filterGroup = "Signal Filters"
const string visualGroup = "Visuals"

//---------------------------------------------------------
// CALCULATION INPUTS
//---------------------------------------------------------
start = input.float(
     0.02,
     title = "PSAR Start",
     minval = 0.001,
     maxval = 1.0,
     step = 0.001,
     tooltip = "Initial acceleration factor used by Parabolic SAR.",
     group = calcGroup,
     display = display.none
)

increment = input.float(
     0.02,
     title = "PSAR Increment",
     minval = 0.001,
     maxval = 1.0,
     step = 0.001,
     tooltip = "Amount added to the PSAR acceleration factor as the trend develops.",
     group = calcGroup,
     display = display.none
)

maximum = input.float(
     0.20,
     title = "PSAR Maximum",
     minval = 0.001,
     maxval = 1.0,
     step = 0.01,
     tooltip = "Maximum PSAR acceleration factor. If this value is below PSAR Start, the script uses PSAR Start as the effective maximum.",
     group = calcGroup,
     display = display.none
)

//---------------------------------------------------------
// FILTER INPUTS
//---------------------------------------------------------
confirmOnClose = input.bool(
     true,
     title = "Confirm Signals On Bar Close",
     tooltip = "When enabled, UP and DOWN signals appear only after the current bar closes. When disabled, signals may appear and disappear while the bar is forming.",
     group = filterGroup
)

useEMAFilter = input.bool(
     true,
     title = "Use EMA Trend Filter",
     tooltip = "UP signals require price above the EMA. DOWN signals require price below the EMA.",
     group = filterGroup
)

emaLength = input.int(
     50,
     title = "EMA Length",
     minval = 1,
     tooltip = "Lookback period used to calculate the EMA trend filter.",
     group = filterGroup,
     active = useEMAFilter,
     display = display.none
)

useADXFilter = input.bool(
     true,
     title = "Use ADX Strength Filter",
     tooltip = "Signals are allowed only when ADX is equal to or above the selected minimum value.",
     group = filterGroup
)

adxLength = input.int(
     14,
     title = "ADX Length",
     minval = 1,
     tooltip = "Period used for both the Directional Index calculation and ADX smoothing.",
     group = filterGroup,
     active = useADXFilter,
     display = display.none
)

adxMin = input.float(
     15.0,
     title = "Minimum ADX",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     tooltip = "Minimum ADX value required for an UP or DOWN signal.",
     group = filterGroup,
     active = useADXFilter,
     display = display.none
)

useCandleFilter = input.bool(
     false,
     title = "Use Candle Confirmation",
     tooltip = "UP requires a bullish candle. DOWN requires a bearish candle.",
     group = filterGroup
)

useCooldown = input.bool(
     true,
     title = "Use Cooldown Between Signals",
     tooltip = "Suppresses new signals for the selected number of complete bars after the previous accepted signal. Suppressed signals are not delayed or restored later.",
     group = filterGroup
)

cooldownBars = input.int(
     1,
     title = "Cooldown Bars",
     minval = 0,
     maxval = 1000,
     tooltip = "Number of complete bars required between accepted signals.",
     group = filterGroup,
     active = useCooldown,
     display = display.none
)

//---------------------------------------------------------
// VISUAL INPUTS
//---------------------------------------------------------
psarWidth = input.int(
     2,
     title = "PSAR Point Width",
     minval = 1,
     maxval = 4,
     group = visualGroup,
     display = display.none
)

showSignals = input.bool(
     true,
     title = "Show UP/DOWN Signals",
     tooltip = "Displays UP and DOWN labels only when all enabled filters approve the PSAR direction change.",
     group = visualGroup
)

showPSARFill = input.bool(
     true,
     title = "Show PSAR Trend Fill",
     tooltip = "Displays the base PSAR state: green when price is above PSAR and red when price is below PSAR.",
     group = visualGroup
)

showEMA = input.bool(
     true,
     title = "Show EMA Filter",
     tooltip = "Displays the EMA used by the trend filter.",
     group = visualGroup,
     active = useEMAFilter
)

//---------------------------------------------------------
// CORE CALCULATIONS
//---------------------------------------------------------
effectiveMaximum = math.max(maximum, start)

psar = ta.sar(start, increment, effectiveMaximum)
psarDirection = close > psar ? 1 : -1

rawBuySignal  = ta.crossover(close, psar)
rawSellSignal = ta.crossunder(close, psar)

emaValue = ta.ema(close, emaLength)

// The same period is used for DI calculation and ADX smoothing.
[_, _, adxValue] = ta.dmi(adxLength, adxLength)

//---------------------------------------------------------
// SIGNAL FILTERS
//---------------------------------------------------------
trendLongOk  = not useEMAFilter or close > emaValue
trendShortOk = not useEMAFilter or close < emaValue

strengthOk =
     not useADXFilter or
     (not na(adxValue) and adxValue >= adxMin)

candleLongOk  = not useCandleFilter or close > open
candleShortOk = not useCandleFilter or close < open

barConfirmed = not confirmOnClose or barstate.isconfirmed

//---------------------------------------------------------
// COOLDOWN
//---------------------------------------------------------
var int lastSignalBar = na

cooldownOk =
     not useCooldown or
     na(lastSignalBar) or
     bar_index - lastSignalBar > cooldownBars

//---------------------------------------------------------
// FINAL FILTERED SIGNALS
//---------------------------------------------------------
buySignal =
     rawBuySignal and
     trendLongOk and
     strengthOk and
     candleLongOk and
     cooldownOk and
     barConfirmed

sellSignal =
     rawSellSignal and
     trendShortOk and
     strengthOk and
     candleShortOk and
     cooldownOk and
     barConfirmed

if buySignal or sellSignal
    lastSignalBar := bar_index

//---------------------------------------------------------
// COLORS
//---------------------------------------------------------
bullColor = color.rgb(0, 184, 148)
bearColor = color.rgb(214, 48, 49)
emaColor  = color.rgb(120, 120, 120)

bullFillColor = color.new(bullColor, 88)
bearFillColor = color.new(bearColor, 88)

color psarColor =
     psarDirection == 1 ? bullColor : bearColor

color stateFillColor =
     showPSARFill
     ? psarDirection == 1
         ? bullFillColor
         : bearFillColor
     : na

//---------------------------------------------------------
// PSAR AND EMA PLOTS
//---------------------------------------------------------
psarPlot = plot(
     psar,
     title = "PSAR",
     style = plot.style_circles,
     linewidth = psarWidth,
     color = psarColor
)

plot(
     showEMA and useEMAFilter ? emaValue : na,
     title = "EMA Filter",
     color = emaColor,
     linewidth = 2
)

//---------------------------------------------------------
// PSAR STATE FILL
//---------------------------------------------------------
midPricePlot = plot(
     ohlc4,
     title = "Mid Price",
     display = display.none,
     editable = false
)

fill(
     midPricePlot,
     psarPlot,
     title = "PSAR Trend Fill",
     color = stateFillColor
)

//---------------------------------------------------------
// FILTERED SIGNAL LABELS
//---------------------------------------------------------
float upSignalLevel =
     showSignals and buySignal ? psar : na

float downSignalLevel =
     showSignals and sellSignal ? psar : na

plotshape(
     upSignalLevel,
     title = "Filtered UP Signal",
     location = location.absolute,
     style = shape.labelup,
     size = size.tiny,
     color = bullColor,
     text = "UP",
     textcolor = color.white,
     display = display.pane
)

plotshape(
     downSignalLevel,
     title = "Filtered DOWN Signal",
     location = location.absolute,
     style = shape.labeldown,
     size = size.tiny,
     color = bearColor,
     text = "DOWN",
     textcolor = color.white,
     display = display.pane
)

//---------------------------------------------------------
// ALERTS
//---------------------------------------------------------
alertcondition(
     buySignal,
     title = "PSAR Filtered UP",
     message = "MarketStructureLab PSAR Trend Filter: UP | {{exchange}}:{{ticker}} | Timeframe: {{interval}} | Close: {{close}}"
)

alertcondition(
     sellSignal,
     title = "PSAR Filtered DOWN",
     message = "MarketStructureLab PSAR Trend Filter: DOWN | {{exchange}}:{{ticker}} | Timeframe: {{interval}} | Close: {{close}}"
)
````
