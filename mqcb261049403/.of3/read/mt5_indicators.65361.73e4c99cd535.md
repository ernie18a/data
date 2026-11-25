Calculation: Opening-range high = maximum high of chart bars during the configured opening session each day
Calculation: Opening-range low = minimum low of chart bars during the configured opening session each day
Long: current bar is outside the opening session AND opening-range high > 0 AND low[2] < opening-range high AND close[2] > opening-range high AND low[1] > opening-range high AND close[1] > opening-range high AND close[0] > low[1] AND low[0] > opening-range high
Short: current bar is outside the opening session AND opening-range high > 0 AND high[2] > opening-range low AND close[2] < opening-range low AND high[1] < opening-range low AND close[1] < opening-range low AND close[0] < high[1] AND high[0] < opening-range low
Long: a confirmed breakout is pending AND close[1] > opening-range high AND low[0] <= opening-range high AND close[0] >= opening-range high
Short: a confirmed breakout is pending AND close[1] < opening-range low AND high[0] >= opening-range low AND close[0] <= opening-range low
Exit: long, a confirmed breakout is pending AND close[1] > opening-range high AND close[0] < opening-range high
Exit: short, a confirmed breakout is pending AND close[1] < opening-range low AND close[0] > opening-range low