Calculation: Signed money flow = normalize the smoothed volume-weighted sum of candle body pressure and close location within the candle range; calculate on the selected money-flow timeframe (chart timeframe or a configurable higher/lower timeframe), using the latest value available with lookahead off.
Calculation: Volume balance = smooth the difference between volume on up candles and volume on down candles, normalized by smoothed volume.
Calculation: Price impulse = normalize a smoothed price change over the main lookback.
Calculation: Trend deviation = normalize the difference between price and its smoothed baseline.
Calculation: Prime oscillator = smooth a weighted blend of price impulse, trend deviation, RSI, CCI, MFI, and signed money flow.
Calculation: MVP oscillator = smooth a weighted blend of volume balance, signed money flow, price impulse, and MFI.
Calculation: Active oscillator = the selected Prime or MVP oscillator; its signal line is a smoothed version of it, using a shorter lookback.
Calculation: Bullish strength = count of conditions: oscillator above zero; oscillator above signal; oscillator rising over a short lookback; signed money flow positive; volume balance positive; close above the fast EMA and fast EMA above the slower EMA; close above the long-term EMA. Bearish strength counts the mirrored conditions. The EMA lookbacks are fast, slower, and long-term in that order.
Calculation: Confirmed oscillator pivot high/low = a local oscillator high/low confirmed only after the configured right-side bars close; compare its value and the corresponding price high/low with those at the previous confirmed pivot of the same kind.
Long: oscillator crosses above signal AND oscillator below the configured oversold level AND signed money flow rises.
Long: oscillator crosses above signal AND bullish strength meets the configured confirmation threshold.
Long: MVP mode AND oscillator below the configured oversold level AND oscillator rises over a short lookback.
Long: confirmed oscillator pivot low below the configured oversold level.
Long: confirmed oscillator pivot low AND corresponding price low is below the previous pivot price low AND oscillator pivot low is above the previous oscillator pivot low.
Long: oscillator above signal OR bullish strength is at least bearish strength OR signed money flow positive OR volume balance positive OR bullish strength meets the configured confirmation threshold OR oscillator above signal AND oscillator above zero.
Short: oscillator crosses below signal AND oscillator above the configured overbought level AND signed money flow falls.
Short: oscillator crosses below signal AND bearish strength meets the configured confirmation threshold.
Short: MVP mode AND oscillator above the configured overbought level AND oscillator falls over a short lookback.
Short: confirmed oscillator pivot high above the configured overbought level.
Short: confirmed oscillator pivot high AND corresponding price high is above the previous pivot price high AND oscillator pivot high is below the previous oscillator pivot high.
Short: oscillator below signal OR bearish strength greater than bullish strength OR signed money flow negative OR volume balance negative OR bearish strength meets the configured confirmation threshold OR oscillator below signal AND oscillator below zero.