Calculation: Volatility trend state = on each source-timeframe bar, initialize direction to neutral and both thresholds to close; step = point × truncate(0.5 × sensitivity × (highest(ATR(ATR lookback), volatility lookback) + lowest(ATR(ATR lookback), volatility lookback)) / point); A = (low for high/low basis, otherwise close) + 2 × step; B = (high for high/low basis, otherwise close) − 2 × step; if close > prior A, set direction up, then if close < prior B, set direction down; when direction is up set B = max(B, prior B), otherwise set A = min(A, prior A); carry direction and thresholds forward; neutral is displayed as down.
Long: Volatility trend state on chart bars changes from down to up.
Short: Volatility trend state on chart bars changes from up to down.
Long: Volatility trend state on bars of T1 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T1 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T2 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T2 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T3 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T3 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T4 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T4 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T5 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T5 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T6 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T6 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T7 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T7 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T8 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T8 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T9 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T9 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.
Long: Volatility trend state on bars of T10 at the selected offset is up; offset zero selects the forming bar, offset one the latest completed bar.
Short: Volatility trend state on bars of T10 at the selected offset is down; offset zero selects the forming bar, offset one the latest completed bar.