Calculation: Indicator and signal = On a configurable higher, lower, or chart timeframe, calculate RSI and CCI with the same lookback and applied price. At each update, index bars backward from the forming bar as j=0. For each recalculated bar j, set d0=CCI[j]-RSI[j]. For k=1,2,3, set dk=CCI[max(0,j-k)]-RSI[j+k]-sum(d0 through d(k-1)) when redrawing is enabled; otherwise set dk=CCI[j]-RSI[j+k]-sum(d0 through d(k-1)). The indicator is max(d0,d1,d2,d3)+min(d0,d1,d2,d3). The signal is the simple moving average of the indicator over a configurable smoothing lookback ending at j. With redrawing enabled, recalculate the latest four preceding bars and the forming bar in chronological order on each update; otherwise recalculate only newly formed bars and the forming bar. Use the resulting values as they existed at decision time. Evaluate either the last completed timeframe bar on each new timeframe bar or the still-forming timeframe bar on each update, according to the configurable signal-bar selection. Previous values are from preceding bars of that timeframe in the same calculation snapshot.
Long: Selected mode is zero-crossing AND signal > 0 AND previous signal <= 0
Short: Selected mode is zero-crossing AND signal < 0 AND previous signal >= 0
Exit: short, selected mode is zero-crossing AND signal > 0
Exit: long, selected mode is zero-crossing AND signal < 0
Long: Selected mode is turning-point AND signal > previous signal AND previous signal <= signal two bars ago
Short: Selected mode is turning-point AND signal < previous signal AND previous signal >= signal two bars ago
Exit: short, selected mode is turning-point AND signal > previous signal
Exit: long, selected mode is turning-point AND signal < previous signal
Long: Selected mode is line-crossing AND signal < indicator AND previous signal >= previous indicator
Short: Selected mode is line-crossing AND signal > indicator AND previous signal <= previous indicator
Exit: short, selected mode is line-crossing AND signal < indicator
Exit: long, selected mode is line-crossing AND signal > indicator
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance