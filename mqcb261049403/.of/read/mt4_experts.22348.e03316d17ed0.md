Calculation: Prior-window high = highest high over a lookback of 3–99 chart bars, starting 3 bars before the current bar
Calculation: Prior-window low = lowest low over a lookback of 3–99 chart bars, starting 3 bars before the current bar
Long: absolute(current Bid − close two bars ago) > configurable point distance AND (high two bars ago < Prior-window high OR high three bars ago < Prior-window high OR high four bars ago < Prior-window high) AND open one bar ago > Prior-window high AND low two bars ago < high one bar ago
Short: absolute(current Ask − close two bars ago) > configurable point distance AND (low two bars ago > Prior-window low OR low three bars ago > Prior-window low OR low four bars ago > Prior-window low) AND open one bar ago < Prior-window low AND low one bar ago < high two bars ago
Exit: Long, price ≤ stop-loss level OR price ≥ take-profit level
Exit: Short, price ≥ stop-loss level OR price ≤ take-profit level