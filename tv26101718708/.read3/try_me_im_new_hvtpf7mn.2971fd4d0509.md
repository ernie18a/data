Long: open < close AND open >= open[1] AND volume >= parameter
Exit: long, NOT (open < close AND open >= open[1] AND volume >= parameter) AND close < close[1]