Calculation: Analysis RSI = RSI of close calculated on the selected analysis timeframe; on historical chart bars use the last completed analysis bar when that timeframe is higher, or the last intrabar when it is lower.
Calculation: Stochastic close = SMA of the stochastic oscillator applied to analysis RSI on chart bars.
Calculation: Stochastic high and stochastic low = SMAs of stochastic oscillators applied respectively to RSI of chart-bar high and RSI of chart-bar low.
Calculation: Stochastic open = previous stochastic close, or current stochastic close if the previous value is unavailable.
Calculation: Plotted low = minimum of stochastic low and stochastic high if that minimum is below stochastic close; otherwise stochastic open.
Calculation: Plotted high = maximum of stochastic high and stochastic low if stochastic high is above stochastic close; otherwise stochastic open.
Calculation: Direction = 100 if plotted high is above its previous value; otherwise 0 if plotted low is below its previous value; otherwise 0 if plotted high is below its previous value; otherwise 100 if plotted low is above its previous value; otherwise 50.
Calculation: Higher-timeframe RSI = RSI of close on the higher timeframe, using the last completed higher-timeframe bar on historical chart bars.
Calculation: Uptrend = close SMA is greater than every one of its values in a preceding lookback; downtrend = close SMA is less than every one of its values in that lookback.
Calculation: Long trailing stop = maximum of current close reduced by a trailing percentage and the previous long trailing stop; initialize the previous stop to zero when no long position existed.
Calculation: Short trailing stop = minimum of current close increased by a trailing percentage and the previous short trailing stop; initialize the previous stop to a sufficiently large value when no short position existed.
Long: Volume exceeds its SMA AND stochastic close exceeds its EMA.
Short: Volume exceeds its SMA AND stochastic close is below its EMA.
Long: Within the selected trading session AND, if volume bias is enabled, volume exceeds its SMA AND stochastic close exceeds its EMA AND any selected long-entry condition below is true; if inversion is enabled, use the corresponding short-entry condition instead.
Short: Within the selected trading session AND, if volume bias is enabled, volume exceeds its SMA AND stochastic close is below its EMA AND any selected short-entry condition below is true; if inversion is enabled, use the corresponding long-entry condition instead.
Long: Stochastic close two bars ago is below an upper threshold AND stochastic close has risen on each of the last two bars AND direction equals 100 on each of the last three bars.
Short: Stochastic close two bars ago is above a lower threshold AND stochastic close has fallen on each of the last two bars AND direction equals 0 on each of the last three bars.
Long: Stochastic close crosses above an upper threshold AND its EMA is below a second, lower upper threshold.
Short: Stochastic close crosses below a lower threshold AND its EMA is above a second, higher lower threshold.
Long: Direction EMA is below a midpoint threshold AND direction equals 100.
Short: Direction EMA is above the midpoint threshold AND direction equals 0.
Long: Stochastic close EMA and stochastic close on each of the preceding two bars are below a lower threshold AND previous direction equals 0 AND current direction equals 100.
Short: Stochastic close EMA and stochastic close on each of the preceding two bars are above an upper threshold AND previous direction equals 100 AND current direction equals 0.
Long: Stochastic close two bars ago is below a lower threshold AND previous direction equals 0 AND current direction equals 100.
Short: Stochastic close two bars ago is above an upper threshold AND previous direction equals 100 AND current direction equals 0.
Long: Stochastic close two bars ago is below an upper threshold AND direction two bars ago equals 0 AND direction on each of the last two bars equals 100.
Short: Stochastic close two bars ago is above a lower threshold AND direction two bars ago equals 100 AND direction on each of the last two bars equals 0.
Long: Previous direction equals 0 AND current direction equals 100.
Short: Previous direction equals 100 AND current direction equals 0.
Long: Direction two bars ago equals 0 AND direction on each of the last two bars equals 100.
Short: Direction two bars ago equals 100 AND direction on each of the last two bars equals 0.
Long: At least one stochastic close from one through three bars ago is at or above a long pivot threshold AND current stochastic close is above its previous value AND at least one stochastic close from the current bar through two bars ago is at or above a long entry threshold.
Short: At least one stochastic close from one through three bars ago is at or below a short pivot threshold AND current stochastic close is below its previous value AND at least one stochastic close from the current bar through two bars ago is at or below a short entry threshold.
Long: Stochastic close three bars ago is at or above a long pivot threshold AND current stochastic close is above its previous value AND at least one stochastic close from the current bar through two bars ago is at or above a long entry threshold.
Short: Stochastic close three bars ago is at or below a short pivot threshold AND current stochastic close is below its previous value AND at least one stochastic close from the current bar through two bars ago is at or below a short entry threshold.
Long: Stochastic close crossed above the numeric trail EMA length parameter two bars ago AND current stochastic close is at or above a long entry threshold AND above its value two bars ago.
Short: Stochastic close crossed below the numeric trail EMA length parameter two bars ago AND current stochastic close is at or below a short entry threshold AND below its value two bars ago.
Long: Lowest close over a shorter lookback is below lowest close over a longer lookback AND analysis RSI is above its lowest value over the longer lookback.
Short: Highest close over a shorter lookback is above highest close over a longer lookback AND analysis RSI is below its highest value over the longer lookback.
Long: Analysis RSI is below a lower threshold.
Short: Analysis RSI is above an upper threshold.
Long: Uptrend AND analysis RSI is below a midpoint threshold.
Short: Downtrend AND analysis RSI is above a midpoint threshold.
Long: Uptrend AND analysis RSI is below a midpoint threshold AND analysis RSI crosses above that threshold.
Short: Downtrend AND analysis RSI is above a midpoint threshold AND analysis RSI crosses below that threshold.
Long: Analysis RSI crosses above its SMA.
Short: Analysis RSI crosses below its SMA.
Long: Higher-timeframe RSI is above a midpoint threshold AND analysis RSI crosses above that threshold.
Short: Higher-timeframe RSI is below a midpoint threshold AND analysis RSI crosses below that threshold.
Exit: long OR short, time-based stop enabled AND position was flat a specified number of bars ago.
Exit: long, momentum stop enabled AND direction equals 0 on each of the last two bars.
Exit: short, momentum stop enabled AND direction equals 100 on each of the last two bars.
Exit: long, trailing stop enabled AND low reaches the active long trailing stop.
Exit: short, trailing stop enabled AND high reaches the active short trailing stop.
Exit: long OR short, end-of-day closing enabled AND bar time is within the configured closing interval in its specified fixed-offset timezone.
Exit: long, money strategy enabled AND a prior close was within the configured proximity of the entry-price-based stop or target AND low reaches the stop OR high reaches the target while the resulting order is active.
Exit: short, money strategy enabled AND a prior close was within the configured proximity of the entry-price-based stop or target AND high reaches the stop OR low reaches the target while the resulting order is active.