Calculation: Short-term Xtrender = RSI of the difference between ALMA of the selected price source with a shorter lookback and ALMA of that source with a longer lookback, minus 50
Calculation: Long-term Xtrender = RSI of ALMA of the selected price source, minus 50
Calculation: Signal line = ALMA of the short-term Xtrender
Long: Signal line > its prior-bar value AND its prior-bar value < its value two bars ago OR signal line > its prior-bar value OR long-term Xtrender > its prior-bar value OR short-term Xtrender > 0 OR long-term Xtrender > 0
Short: Signal line < its prior-bar value AND its prior-bar value > its value two bars ago OR signal line < its prior-bar value OR long-term Xtrender < its prior-bar value OR short-term Xtrender <= 0 OR long-term Xtrender <= 0
Long: Long-term Xtrender > 0 on a dashboard timeframe, using that timeframe’s current bar, which may be higher or lower than the chart timeframe
Short: Long-term Xtrender <= 0 on a dashboard timeframe, using that timeframe’s current bar, which may be higher or lower than the chart timeframe