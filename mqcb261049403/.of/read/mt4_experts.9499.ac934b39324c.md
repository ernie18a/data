Calculation: Indicator bars = bars at each indicator's independently selected chart, higher, or lower timeframe; use the still-forming bar for shift 0 and completed bars for positive shifts. Each moving average and MACD may also have a configured nonnegative bar shift; its previous value is one indicator bar earlier.
Calculation: Moving averages = independently configured moving averages of selected OHLC-derived prices, with fast, middle, and slow lookbacks ordered shortest to longest.
Calculation: Entry directional state = for each enabled indicator, the current directional result or, if last-signal mode is enabled, its most recent nonzero directional result. The moving-average, RSI, and MACD entry selections fall through to their last mode: respectively any of the three moving-average crosses, RSI zone, and MACD signal-line zero cross. For simultaneous opposite moving-average crosses, short takes precedence.
Calculation: Closing directional result = the current result of each enabled closing indicator, using its independently selected timeframe. The closing selections fall through to their last mode: respectively any of the three moving-average crosses, RSI zone, and MACD signal-line zero cross. For simultaneous opposite moving-average crosses, short takes precedence.
Long: Fast moving average crosses above middle moving average OR middle moving average crosses above slow moving average OR fast moving average crosses above slow moving average.
Short: Fast moving average crosses below middle moving average OR middle moving average crosses below slow moving average OR fast moving average crosses below slow moving average.
Long: MACD main line > its previous value AND MACD signal line > its previous value AND MACD main line > MACD signal line.
Short: MACD main line < its previous value AND MACD signal line < its previous value AND MACD main line < MACD signal line.
Long: MACD main line crosses above MACD signal line AND current MACD main line < zero AND previous MACD main line < zero.
Short: MACD main line crosses below MACD signal line AND current MACD main line > zero AND previous MACD main line > zero.
Long: MACD signal line > zero AND previous MACD signal line < zero.
Short: MACD signal line < zero AND previous MACD signal line > zero.
Long: RSI > previous RSI AND current chart-bar open > previous chart-bar open.
Short: RSI < previous RSI AND current chart-bar open < previous chart-bar open.
Long: RSI > previous RSI AND RSI >= buy-zone threshold AND RSI <= overbought threshold.
Short: RSI < previous RSI AND RSI <= sell-zone threshold AND RSI >= oversold threshold.
Long: Forming-bar parabolic SAR < previous chart-bar close.
Short: Forming-bar parabolic SAR >= previous chart-bar close.
Long: Forming-bar stochastic main line > signal line AND stochastic zone filter is disabled.
Short: Forming-bar stochastic main line < signal line AND (stochastic zone filter is disabled OR stochastic main line < lower threshold).
Long: Previous chart-bar low <= last completed indicator-bar outer lower Bollinger band AND previous chart-bar close > last completed indicator-bar middle lower Bollinger band AND at least one RSI in a configured lookback of completed bars on the independently selected RSI timeframe < oversold threshold.
Short: Previous chart-bar high >= last completed indicator-bar outer upper Bollinger band AND previous chart-bar close < last completed indicator-bar middle upper Bollinger band AND at least one RSI in a configured lookback of completed chart bars > overbought threshold.
Exit: long, automatic closing is enabled AND at least one closing indicator is enabled AND every enabled closing indicator's closing directional result is short.
Exit: short, automatic closing is enabled AND at least one closing indicator is enabled AND every enabled closing indicator's closing directional result is long.
Exit: long, price <= entry price minus stop-loss distance OR price >= entry price plus take-profit distance.
Exit: short, price >= entry price plus stop-loss distance OR price <= entry price minus take-profit distance.