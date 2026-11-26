Calculation: FormedFirst(window) = high if the first completed T1 bar within the window whose high >= the window's highest chart-bar high is not after the first completed T1 bar within the window whose low <= the window's lowest chart-bar low, else low
Calculation: Midpoint(window) = (highest high + lowest low) / 2 over the chart bars within the window
Long: after IB window AND FormedFirst(IB window) = low AND close of last chart bar in IB window >= Midpoint(IB window)
Short: after IB window AND FormedFirst(IB window) = high AND close of last chart bar in IB window < Midpoint(IB window)
Long: after ORB window AND FormedFirst(ORB window) = low AND close of last chart bar in ORB window >= Midpoint(ORB window)
Short: after ORB window AND FormedFirst(ORB window) = high AND close of last chart bar in ORB window < Midpoint(ORB window)