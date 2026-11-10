Calculation: ZigZag candidates = For each bar, mark its high or low as a candidate if it equals the highest high or lowest low over the lookback ending at that bar and that rolling extreme differs from the previously observed rolling extreme of the same kind. When a new candidate is found, remove less extreme candidates of the same kind within the preceding backstep bars.
Calculation: ZigZag direction = Process candidates chronologically. Initially, a high candidate sets the direction to up and a low candidate sets it to down; if both occur, process the high first. While the direction is down, a lower low candidate with no high candidate replaces the last low and keeps the direction down; a high candidate with no low candidate changes it to up. While the direction is up, a higher high candidate with no low candidate replaces the last high and keeps the direction up; a low candidate with no high candidate changes it to down. Replaced candidates are removed from the ZigZag.
Long: close > open
Short: close < open
Long: ZigZag direction changes to up OR an up-direction high is replaced by a higher high
Short: ZigZag direction changes to down OR a down-direction low is replaced by a lower low
Long: current-bar tracking is enabled AND close > open AND volume >= volume threshold
Short: current-bar tracking is enabled AND close < open AND volume >= volume threshold