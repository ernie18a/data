Calculation: Reversal signal state = 1 when close two bars ago < prior close AND current close > prior close AND fast stochastic < slow stochastic AND fast stochastic > the level; −1 when close two bars ago > prior close AND current close < prior close AND fast stochastic > slow stochastic AND fast stochastic < the level; otherwise retain the prior state, initially 0. The slow stochastic is smoothed over a longer lookback than the fast stochastic.
Calculation: Support/resistance signal state = −1 when current high <= previous completed higher-timeframe bar's low in line mode, or <= its high in from-line mode; +1 when current low >= that bar's high in line mode, or >= its low in from-line mode; otherwise retain the prior state, initially 0. Use a higher timeframe; compare against its last completed bar.
Long: Reversal signal state = 1
Short: Reversal signal state = −1
Long: Support/resistance signal state = 1
Short: Support/resistance signal state = −1
Long: Reversal signal state = 1 AND support/resistance signal state = 1, with reverse mode off; OR reversal signal state = −1 AND support/resistance signal state = −1, with reverse mode on
Short: Reversal signal state = −1 AND support/resistance signal state = −1, with reverse mode off; OR reversal signal state = 1 AND support/resistance signal state = 1, with reverse mode on
Exit: long, NOT (reversal signal state = 1 AND support/resistance signal state = 1 OR reversal signal state = −1 AND support/resistance signal state = −1)
Exit: short, NOT (reversal signal state = 1 AND support/resistance signal state = 1 OR reversal signal state = −1 AND support/resistance signal state = −1)