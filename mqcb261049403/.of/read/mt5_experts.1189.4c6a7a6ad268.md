Calculation: UltraRSI bullish line = smooth count of RSI smoothers whose value rises from the prior bar; use a set of smoothers with progressively longer lookbacks.
Calculation: UltraRSI bearish line = smooth count of RSI smoothers whose value falls from the prior bar; use the same progressively longer lookbacks.
Calculation: JBrain bullish marker = JMA(close) movement over two bars exceeds an ATR-based threshold, stochastic is above its upper threshold, and the last JBrain marker was bearish or none exists.
Calculation: JBrain bearish marker = JMA(close) movement over two bars exceeds an ATR-based threshold, stochastic is below its lower threshold, and the last JBrain marker was bullish or none exists.
Long: (a bullish JBrain marker occurs AND UltraRSI bullish line > bearish line) OR (UltraRSI bullish line crosses above bearish line AND the latest JBrain marker is bullish)
Short: (a bearish JBrain marker occurs AND UltraRSI bearish line > bullish line) OR (UltraRSI bearish line crosses above bullish line AND the latest JBrain marker is bearish)
Exit: long, latest JBrain marker is bearish AND UltraRSI bearish line > bullish line
Exit: short, latest JBrain marker is bullish AND UltraRSI bullish line > bearish line