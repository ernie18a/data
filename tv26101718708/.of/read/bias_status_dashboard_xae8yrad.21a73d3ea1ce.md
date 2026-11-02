Calculation: Trend direction = +1 when the short-lookback moving average of close > the medium-lookback moving average > the long-lookback moving average; -1 when both inequalities reverse; otherwise 0. The moving average type is EMA, SMA, or VWMA.
Calculation: VWAP direction = +1 when close > session VWAP of (high + low + close) / 3 + ATR × a neutral-band parameter; -1 when close < session VWAP - ATR × that parameter; otherwise 0.
Calculation: Momentum direction = sign of the number of bullish conditions minus the number of bearish conditions, where the bullish conditions are RSI >= an upper threshold and stochastic RSI K > D AND K > a midpoint, and the bearish conditions are RSI <= a lower threshold and stochastic RSI K < D AND K < the midpoint. K is the SMA-smoothed stochastic of RSI; D is an SMA of K.
Calculation: Structure direction = +1 when close > the latest confirmed pivot high; otherwise -1 when close < the latest confirmed pivot low; otherwise retain the previous direction, initially 0. A pivot uses equal numbers of bars on each side for confirmation.
Calculation: Session sweep direction = initially 0; optionally reset to 0 at the start of the reference session. With the reference-session option, outside that session set it to -1 when high > that session's accumulated high and to +1 when low < its accumulated low. With the active-session option, during the union of the configured sessions set it to -1 when high > the previous bar's accumulated active-session high and to +1 when low < the previous bar's accumulated active-session low; reset the accumulated high and low when that union becomes active. Retain the direction otherwise; if both sweeps occur on a bar, +1 takes precedence.
Calculation: Timeframe direction = +1 when at least a threshold number of the bullish trend, RSI, and stochastic RSI conditions are true AND their count exceeds the count of their bearish counterparts; -1 when the corresponding bearish count reaches the threshold AND exceeds the bullish count; otherwise 0. Calculate these conditions on each configured timeframe using the same parameter relationships as on the chart. For a higher timeframe, historical bars use the last completed bar and realtime bars use the bar still forming; for a lower timeframe, use the last available intrabar.
Calculation: Multi-timeframe direction = +1 when the count of timeframe directions equal to +1 >= an agreement threshold AND exceeds the count equal to -1; -1 when the count equal to -1 >= the threshold AND exceeds the count equal to +1; otherwise 0.
Calculation: Hybrid direction = +1 when the sum of enabled trend, VWAP, momentum, structure, multi-timeframe, and session sweep directions >= a positive score threshold; -1 when the sum <= the negative of that threshold; otherwise 0. Strength = the absolute value of that sum divided by the number of enabled components, or 0 if none are enabled.
Calculation: Selected direction = the hybrid direction or one selected component direction; a manual option can instead select +1, -1, or 0.
Long: Trend direction = +1.
Short: Trend direction = -1.
Long: VWAP direction = +1.
Short: VWAP direction = -1.
Long: RSI >= the upper threshold.
Short: RSI <= the lower threshold.
Long: Stochastic RSI K > D AND K > the midpoint.
Short: Stochastic RSI K < D AND K < the midpoint.
Long: Momentum direction = +1.
Short: Momentum direction = -1.
Long: Structure direction = +1.
Short: Structure direction = -1.
Long: Session sweep direction = +1.
Short: Session sweep direction = -1.
Long: Any configured timeframe direction = +1.
Short: Any configured timeframe direction = -1.
Long: Multi-timeframe direction = +1.
Short: Multi-timeframe direction = -1.
Long: Selected direction = +1 AND strength >= the strength threshold.
Short: Selected direction = -1 AND strength >= the strength threshold.
Long: Selected direction = +1.
Short: Selected direction = -1.