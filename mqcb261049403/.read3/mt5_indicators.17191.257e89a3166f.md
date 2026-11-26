Calculation: Elliot oscillator = MA(selected price source, fast lookback, selected method) - MA(selected price source, slow lookback, selected method)
Calculation: Upper level = initialize to zero; when Elliot oscillator > 0, update as EMA(Elliot oscillator, slow lookback + ceiling(fast lookback / 2)) using the previous upper level; otherwise carry forward the previous upper level
Calculation: Lower level = initialize to zero; when Elliot oscillator < 0, update as EMA(Elliot oscillator, slow lookback + ceiling(fast lookback / 2)) using the previous lower level; otherwise carry forward the previous lower level
Calculation: Middle level = (Upper level + Lower level) / 2
Long: selected signal mode uses outer levels AND Elliot oscillator > Upper level
Long: selected signal mode uses the middle level AND Elliot oscillator > Middle level
Long: selected signal mode uses slope AND Elliot oscillator > Elliot oscillator[1]
Short: selected signal mode uses outer levels AND Elliot oscillator < Lower level
Short: selected signal mode uses the middle level AND Elliot oscillator < Middle level
Short: selected signal mode uses slope AND Elliot oscillator < Elliot oscillator[1]