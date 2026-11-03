Long: current chart bar's low > the 9-period EMA of typical price on the still-forming chart bar
Short: current chart bar's high < the 9-period SMA of open price on the still-forming chart bar
Exit: Long, on the still-forming daily bar, the 55-period smoothed moving average of typical price > close AND on the last completed daily bar, the same moving average < close
Exit: Short, on the still-forming daily bar, the 55-period smoothed moving average of typical price < close AND on the last completed daily bar, the same moving average > close
Exit: Long, price >= entry price + take-profit distance OR price <= trailing stop
Exit: Short, price <= entry price - take-profit distance OR price >= trailing stop