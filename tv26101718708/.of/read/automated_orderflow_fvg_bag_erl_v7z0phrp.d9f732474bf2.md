Calculation: Bullish gap = current low > high two bars earlier; its upper bound is the current low and its lower bound is the high two bars earlier. Bearish gap = current high < low two bars earlier; its upper bound is the low two bars earlier and its lower bound is the current high. Retain the latest gap of each direction, including after it fails, and replace it when a new gap of that direction forms.
Calculation: Local bias starts neutral. A new bullish gap sets it bullish; a new bearish gap sets it bearish. After updating gaps, a close below the latest bullish gap's lower bound on a later bar sets it bearish; a close above the latest bearish gap's upper bound on a later bar sets it bullish. Apply these updates in that order.
Calculation: Higher-timeframe bias starts neutral. On the first chart bar of each higher-timeframe bar, use the last completed higher-timeframe bar: a bullish gap sets the bias bullish and a bearish gap sets it bearish; otherwise retain the prior bias. Final bias is the higher-timeframe bias when non-neutral, otherwise the local bias.
Calculation: A confirmed swing high or low is a pivot high or low with equal numbers of bars on either side; retain the latest confirmed swing of each kind.
Long: close >= open
Long: current bullish gap
Long: after the latest bullish gap formed, low <= its upper bound AND close > its lower bound AND this is the first such bar since that gap formed
Long: after the latest bearish gap formed, close > its upper bound
Long: on the first chart bar of a higher-timeframe bar, the last completed higher-timeframe bar has a bullish gap
Long: final bias is bullish
Long: final bias is bullish AND a bullish gap exists AND the latest confirmed swing high > the latest bullish gap's upper bound
Short: close < open
Short: current bearish gap
Short: after the latest bearish gap formed, high >= its lower bound AND close < its upper bound AND this is the first such bar since that gap formed
Short: after the latest bullish gap formed, close < its lower bound
Short: on the first chart bar of a higher-timeframe bar, the last completed higher-timeframe bar has a bearish gap
Short: final bias is bearish
Short: final bias is bearish AND a bearish gap exists AND the latest confirmed swing low < the latest bearish gap's lower bound