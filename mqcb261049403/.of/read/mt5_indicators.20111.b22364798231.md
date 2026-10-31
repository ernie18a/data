Calculation: Smoothed oscillator = a selectable moving average of stochastic signal line × RSI / Momentum; use 100 as the input to the moving average when Momentum is zero. Momentum is 100 × current selected price / selected price one lookback ago; RSI and Momentum may use independently selected price sources.
Calculation: Higher-timeframe oscillator state = compare the smoothed oscillator on the higher timeframe's still-forming bar with its previous completed bar; sample this state on the first chart bar of each higher-timeframe bar and hold it until the next higher-timeframe bar.
Long: Chart-timeframe smoothed oscillator > its previous-bar value.
Short: Chart-timeframe smoothed oscillator < its previous-bar value.
Long: Higher-timeframe oscillator state is rising.
Short: Higher-timeframe oscillator state is falling.
Long: Higher-timeframe oscillator state is rising AND its state on the previous chart bar was flat.
Short: Higher-timeframe oscillator state is flat AND its state on the previous chart bar was rising.