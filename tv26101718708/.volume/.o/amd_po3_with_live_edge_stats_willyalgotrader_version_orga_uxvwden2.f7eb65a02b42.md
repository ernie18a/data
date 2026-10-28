Calculation: Compression = percentile rank of the recent Donchian-window width within its longer rolling history.
Calculation: Accumulation range = highest and lowest confirmed pivot values within the recent Donchian window; use the window high or low if that side has no confirmed pivot.
Calculation: Sweep extreme = highest high beyond the range high, or lowest low beyond the range low, from the initial breach through the bar that closes back inside.
Calculation: Distribution target = extend from the sweep extreme through the opposite accumulation boundary by the configured Fibonacci extension.
Calculation: Stop = beyond the sweep extreme by an ATR-based buffer, using ATR from before the range began.
Calculation: HTF bias = last completed higher-timeframe close compared with its EMA.
Long: On a confirmed bar, after a compressed range of at least the minimum width has matured, price breaches below its lower boundary and closes back inside within the allowed bars; apply enabled sweep-window, sweep-depth, liquidity, HTF-bias, and confluence filters.
Short: On a confirmed bar, after a compressed range of at least the minimum width has matured, price breaches above its upper boundary and closes back inside within the allowed bars; apply enabled sweep-window, sweep-depth, liquidity, HTF-bias, and confluence filters.
Exit: long, after the entry bar, low <= stop OR high >= target OR the distribution timeout is exceeded.
Exit: short, after the entry bar, high >= stop OR low <= target OR the distribution timeout is exceeded.