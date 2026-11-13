Calculation: Osc = (close - rolling VWAP) / rolling population standard deviation of close; rolling VWAP = sum(typical price * volume) / sum(volume) over a VWAP lookback, typical price = (high+low+close)/3; the standard deviation uses a separate volatility lookback; both windows end at the current bar
Calculation: Signal = simple moving average of Osc over a smoothing period shorter than both lookbacks
Calculation: impulse level = positive threshold; exhaustion level = positive threshold greater than the impulse level
Long: (Osc >= impulse level AND Osc < exhaustion level) OR (Osc <= -exhaustion level AND Signal > previous bar's Signal)
Short: (Osc <= -impulse level AND Osc > -exhaustion level) OR (Osc >= exhaustion level AND Signal < previous bar's Signal)