Calculation: session VWAP = VWAP(typical price, anchored at first chart bar of chart session)
Calculation: entry window = time of day (exchange time zone) >= entry window start AND time of day <= entry window end
Calculation: implied volatility index up = close of implied volatility index > Twin Range Filter(close of implied volatility index, fast period, fast multiplier, slow period, slow multiplier), with slow period > fast period, on T1 bars using the still-forming T1 bar
Calculation: TFC score = sum over k = 3 to 8 of sign(close - open of still-forming Tk bar), counting only Tk not shorter than chart timeframe
Calculation: inside bar = high <= high[1] AND low >= low[1]
Calculation: chart inside-bar high = IF chart inside-bar pending[1] THEN chart inside-bar high[1] ELSE high[1]
Calculation: chart inside-bar low = IF chart inside-bar pending[1] THEN chart inside-bar low[1] ELSE low[1]
Calculation: chart inside-bar pending = (chart inside-bar pending[1] OR inside bar[1]) AND high <= chart inside-bar high AND low >= chart inside-bar low
Calculation: chart inside-bar break up = (chart inside-bar pending[1] OR inside bar[1]) AND close > chart inside-bar high
Calculation: chart inside-bar break down = (chart inside-bar pending[1] OR inside bar[1]) AND close < chart inside-bar low
Calculation: T2 inside-bar pending = last completed T2 bar is an inside bar AND every earlier chart bar of still-forming T2 bar closed within high-low range of last completed T2 bar, with T2 longer than chart timeframe
Calculation: T2 inside-bar break up = T2 inside-bar pending AND close > high of last completed T2 bar
Calculation: T2 inside-bar break down = T2 inside-bar pending AND close < low of last completed T2 bar
Calculation: inside-bar break up = chart inside-bar break up OR T2 inside-bar break up
Calculation: inside-bar break down = chart inside-bar break down OR T2 inside-bar break down
Calculation: key-level cross = close, high, or low crosses above or below any of: high or low of last completed T9 bar; high or low of chart bars since latest session start time in Asia window (hours from Asia start hour through Asia end hour, wrapping midnight) once that window has ended; high or low of chart bars since latest session start time in London window (hours from London start hour up to London end hour) once that window has ended; open of the chart bar at the latest session start time
Calculation: key-level sweep = key-level cross on the current chart bar or on any of the previous N chart bars
Long: entry window AND close < session VWAP AND NOT implied volatility index up AND TFC score >= 0 AND inside-bar break up
Long: entry window AND close > session VWAP AND TFC score > 0 AND inside-bar break up
Short: entry window AND close < session VWAP AND implied volatility index up AND inside-bar break down
Short: entry window AND close > session VWAP AND key-level sweep AND TFC score <= 0 AND inside-bar break down