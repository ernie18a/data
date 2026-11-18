Calculation: Bullish SMT = (chart low < lowest chart low over the preceding P1 chart bars AND other-index low > lowest other-index low over the preceding P1 chart bars) OR (other-index low < lowest other-index low over the preceding P1 chart bars AND chart low > lowest chart low over the preceding P1 chart bars)
Calculation: Bearish SMT = (chart high > highest chart high over the preceding P1 chart bars AND other-index high < highest other-index high over the preceding P1 chart bars) OR (other-index high > highest other-index high over the preceding P1 chart bars AND chart high < highest chart high over the preceding P1 chart bars)
Calculation: Bullish T1 SMT = (chart low on T1 < lowest chart low on T1 over the preceding P2 T1 bars AND other-index low on T1 > lowest other-index low on T1 over the preceding P2 T1 bars) OR (other-index low on T1 < lowest other-index low on T1 over the preceding P2 T1 bars AND chart low on T1 > lowest chart low on T1 over the preceding P2 T1 bars)
Calculation: Bearish T1 SMT = (chart high on T1 > highest chart high on T1 over the preceding P2 T1 bars AND other-index high on T1 < highest other-index high on T1 over the preceding P2 T1 bars) OR (other-index high on T1 > highest other-index high on T1 over the preceding P2 T1 bars AND chart high on T1 < highest chart high on T1 over the preceding P2 T1 bars)
Calculation: Bullish IFVG = chart low two bars ago - chart high four bars ago >= P3 AND chart low one bar ago <= chart low two bars ago AND chart low one bar ago >= chart high four bars ago AND chart close >= chart high four bars ago
Calculation: Bearish IFVG = chart low four bars ago - chart high two bars ago >= P3 AND chart high one bar ago >= chart high two bars ago AND chart high one bar ago <= chart low four bars ago AND chart close <= chart low four bars ago
Calculation: Bullish setup = Bullish SMT AND Bullish IFVG
Calculation: Bearish setup = Bearish SMT AND Bearish IFVG
Long: Bullish setup AND (NOT P4 OR Bullish T1 SMT)
Short: Bearish setup AND (NOT P4 OR Bearish T1 SMT)
Long: Bullish T1 SMT AND NOT Bullish setup
Short: Bearish T1 SMT AND NOT Bearish setup