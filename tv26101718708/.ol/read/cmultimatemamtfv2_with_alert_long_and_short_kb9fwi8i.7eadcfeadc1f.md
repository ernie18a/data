Calculation: basis = simple moving average of close over a lookback
Calculation: selected MA = selected SMA, EMA, WMA, Hull MA, VWMA, RMA, TEMA, or Tilson T3 of close over a lookback, calculated on the selected resolution (chart resolution or configured resolution) and mapped to chart bars
Long: selected MA >= its value several chart bars earlier OR open < selected MA AND close > selected MA OR selected MA is rising AND close > basis
Short: selected MA is falling AND close < basis OR open > selected MA AND close < selected MA
Exit: long, open > selected MA AND close < selected MA
Exit: short, open < selected MA AND close > selected MA