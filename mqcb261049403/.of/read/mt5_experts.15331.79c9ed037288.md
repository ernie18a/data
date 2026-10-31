Calculation: Double-smoothed average = Jurik moving average of a Jurik moving average of a selectable OHLC-derived price, with independently selectable length and phase for each smoothing; calculate on the chart timeframe or on a selectable higher or lower timeframe, using the last completed bar or the still-forming bar as selected. Let A[0], A[1], and A[2] denote its selected bar and the two preceding bars.
Calculation: Change = A[0] - A[1].
Calculation: Deviation = population standard deviation of the last lookback number of consecutive changes, including Change. Round Change and each deviation multiplied by its independently selectable threshold coefficient to the selected price precision plus two decimal places before comparing them.
Long: A[0] > A[1].
Short: A[0] < A[1].
Long: rounded Change > rounded first coefficient times Deviation AND rounded Change <= rounded second coefficient times Deviation.
Long: rounded Change > rounded second coefficient times Deviation.
Short: rounded Change < negative rounded first coefficient times Deviation AND rounded Change >= negative rounded second coefficient times Deviation.
Short: rounded Change < negative rounded second coefficient times Deviation.
Long: A[2] > A[1] AND A[0] > A[1].
Short: A[2] < A[1] AND A[0] < A[1].
Exit: long, A[0] < A[1].
Exit: short, A[0] > A[1].
Exit: long, rounded Change < negative rounded first coefficient times Deviation AND rounded Change >= negative rounded second coefficient times Deviation.
Exit: long, rounded Change < negative rounded second coefficient times Deviation.
Exit: short, rounded Change > rounded first coefficient times Deviation AND rounded Change <= rounded second coefficient times Deviation.
Exit: short, rounded Change > rounded second coefficient times Deviation.
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance.