Calculation: Fear gauge = (highest close over the fear lookback − current low) / highest close × 100
Calculation: Adaptive fear threshold = selected percentile of recent fear-gauge values
Calculation: Downward momentum = (current close − close at the momentum lookback) / ATR
Calculation: Upward stretch pressure = 1 − exp(− accumulated excess stretch below the long-term moving average / scale); accumulate while price is sufficiently below the average and decay otherwise
Calculation: Upward momentum = (current close − close at the momentum lookback) / ATR
Calculation: Greed gauge = (current high − lowest close over the fear lookback) / lowest close × 100
Calculation: Adaptive greed threshold = selected percentile of recent greed-gauge values
Calculation: Downward stretch pressure = 1 − exp(− accumulated excess stretch above the long-term moving average / scale); accumulate while price is sufficiently above the average and decay otherwise
Long: current fear gauge ≥ current adaptive fear threshold OR prior bar's fear gauge ≥ its adaptive fear threshold OR fear gauge two bars ago ≥ its adaptive fear threshold; AND the lowest downward momentum over the recent momentum window ≤ negative minimum momentum; AND current downward momentum > prior bar's downward momentum; AND upward stretch pressure ≥ minimum pressure; AND current bar is complete; AND bars since the last long or short signal ≥ cooldown
Short: when top detection is enabled, current greed gauge ≥ current adaptive greed threshold; AND the highest upward momentum over the recent momentum window ≥ minimum momentum; AND current upward momentum < prior bar's upward momentum; AND downward stretch pressure ≥ minimum pressure; AND current bar is complete; AND bars since the last long or short signal ≥ cooldown