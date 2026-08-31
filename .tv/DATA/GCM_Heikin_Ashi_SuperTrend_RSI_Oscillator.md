<!-- tradingview-pine-id: PUB;f77aee38a9a0475091410b86572a9b81 -->
<!-- tradingviewscripts-format: 1 -->
# GCM Heikin Ashi SuperTrend RSI Oscillator

Source: https://www.tradingview.com/script/GPGrzBNU-GCM-Heikin-Ashi-SuperTrend-RSI-Oscillator/

## Description

Description

Title: GCM Heikin Ashi SuperTrend RSI Oscillator (GCM HASTRO)

"Unmask market noise to decode institutional flow and master market momentum—where smart money meets multi-timeframe precision, empowering you to trade with institutional clarity and engineer your edge through real-time multi-dimensional confluence."
                                          -uniGram
Overview:
Welcome to GCM HASTRO (GCM Heikin Ashi SuperTrend RSI Oscillator), a flagship institutional-grade indicator engineered by uniGram. Designed for professional traders and algorithmic operators across equities, index derivatives, and crypto markets, GCM HASTRO bridges the gap between mathematical momentum smoothing and smart-money fund flow tracking. It eradicates noise and filters out choppy market conditions using a multi-layered confluence framework.

Core Architecture & Key Engines

1. HARSI (Heikin Ashi Smoothed RSI) Engine:
Unlike standard oscillators that suffer from erratic whipsaws, GCM HASTRO calculates a smoothed Heikin Ashi transformation over a configurable RSI length. This forms clean, institutional-grade momentum waves mapped across designated Overbought (75 to 85) and Oversold (15 to 25) ribbon zones.

2. Banker Fund Flow (Institutional Accumulation Model):
Integrated smart-money logic tracks institutional buying and selling pressure. It classifies market states into precise operational flags:
o ENTRY: High-probability institutional accumulation initiation.
o W.REB (Weak Rebound): Minor counter-trend retracements within a broader trend.
o INCR / DECR: Gradual increase or decrease of institutional momentum.
o EXIT: Institutional distribution or capital withdrawal.

This engine can dynamically color your chart candles to highlight true institutional participation as Banker Fund Flow changes dynamically as follows 

• 🟡 Banker Entry (Yellow): Marks the exact ignition point of institutional accumulation. Highlighted explicitly on both the sub-chart and main chart candles to signal heavy smart-money entry.
[image]https://www.tradingview.com/x/cY4s5cK8/[/image]

• 🟢 Banker Increase (Green): Indicates strengthening buyer momentum and continuous, stable institutional capital inflow.
[image]https://www.tradingview.com/x/zywOsQN7/[/image]

• ⚪ Banker Decrease (White/Gray): Signifies a cooling off or gradual slowdown of institutional buying momentum within the wave structure.
[image]https://www.tradingview.com/x/VWPkGiop/[/image]

• 🔴 Banker Exit (Red): Represents institutional capital withdrawal, profit-booking, or active distribution/selling pressure.
[image]https://www.tradingview.com/x/71iu15OY/[/image]

• 🔵 Weak Rebound (Blue): Highlights a minor counter-trend bounce or temporary retracement inside a broader corrective phase.
[image]https://www.tradingview.com/x/OM6V5mtT/[/image]

3. Top-Down 5-Timeframe Matrix Dashboard:
The built-in mini matrix dashboard displays real-time synchronization across 5 structural timeframes (Micro, LTF, CTF, HTF, Macro). It simultaneously tracks Trend direction (BULL / BEAR), Fund Flow status, and RSI slope dynamics, giving you a top-down macro view directly on your sub-chart.
[image]https://www.tradingview.com/x/BPRl8lln/[/image]

4. Divergence Theory Engine:
Automatically scans the underlying Normal RSI line for Regular Bullish/Bearish and Hidden Bullish/Bearish divergences, plotting precise dashed confirmation lines and visual warning tags across both sub and main charts.
[image]https://www.tradingview.com/x/uD0v9ePp/[/image]

5. HA Super Trend & Confluence Filters:
Includes a customized wick-ratio filtered Super Trend line and advanced execution filters (Volume RVOL checks, ATR volatility scaling, Minimum Wave Size thresholds, and Median 50-line cross gates) to filter out low-quality signals.
[image]https://www.tradingview.com/x/vxf26Yc9/[/image]

Execution Framework: How to Trade with GCM HASTRO
To maximize edge and minimize false breakouts, trade execution should follow a disciplined, top-down confirmation sequence:

• Step 1: Matrix Alignment Check
Before taking any trade, look at the Mini Matrix Dashboard. Ensure that your Higher Timeframe (HTF) and Macro trend filters are aligned with your intended trade direction (BULL for long, BEAR for short).

• Step 2: Fund Flow Confirmation
Verify that the Banker Fund Flow status is supportive (e.g., showing an ENTRY or INCR state for longs, or EXIT / DECR for shorts). Never trade against institutional fund flow.

• Step 3: Signal Trigger
o Long Entry: Triggered when a neon cyan upward triangle prints, or when HARSI cleanly breaks out of the Oversold / OB-lower boundary backed by valid volume and ATR conditions.
o Short Entry: Triggered when a neon crimson downward triangle prints, or when HARSI crosses under the Overbought / OS-upper boundary.

Trade & Risk Management
• Stop-Loss Placement: Utilize the HA Super Trend line or the most recent swing structure boundary (Support/Resistance or ATR-based distance) as your invalidation point.
• Position Sizing: Never risk more than 1% to 2% of your total trading capital on a single execution. Ensure lot sizes match your volatility parameters, especially when trading Nifty F&O or crypto derivatives.
• Profit Targets: Scale out of positions progressively as price reaches key psychological levels or when counter-trend divergence signals appear on the dashboard.

Disclaimer
GCM HASTRO is designed strictly for analytical, educational, and informational purposes. It does not constitute formal financial advice. Financial markets, index derivatives, and cryptocurrencies carry substantial risk of capital loss. Always perform your own due diligence and manage risk responsibly before deploying capital into live markets.

HAPPY TRADING
-------------------------------------------------------------
Kannada Version (ಕನ್ನಡ ಆವೃತ್ತಿ)
ವಿವರಣೆ

ಶೀರ್ಷಿಕೆ: GCM Heikin Ashi SuperTrend RSI Oscillator (GCM HASTRO)
"ಮಾರುಕಟ್ಟೆಯ ಗೊಂದಲಗಳನ್ನು ನಿವಾರಿಸಿ ಇನ್‌ಸ್ಟಿಟ್ಯೂಶನಲ್ ಫ್ಲೋ ಅನ್ನು ಡಿಕೋಡ್ ಮಾಡಿ ಮತ್ತು ಮಾರುಕಟ್ಟೆ ಮೊಮೆಂಟಮ್ ಅನ್ನು ಕರಗತ ಮಾಡಿಕೊಳ್ಳಿ. ಇಲ್ಲಿ 'ಸ್ಮಾರ್ಟ್ ಮನಿ'ಯು ಬಹು-ಸಮಯದ ನಿಖರತೆಯನ್ನು ಭೇಟಿಯಾಗುತ್ತದೆ, ಇದು ನಿಮಗೆ ಸಾಂಸ್ಥಿಕ ಸ್ಪಷ್ಟತೆಯೊಂದಿಗೆ ಟ್ರೇಡ್ ಮಾಡಲು ಮತ್ತು ರಿಯಲ್-ಟೈಮ್ ಬಹು-ಆಯಾಮದ ಕಾನ್‌ಫ್ಲುಯೆನ್ಸ್ ಮೂಲಕ ನಿಮ್ಮ ಎಡ್ಜ್ ಅನ್ನು ಎಂಜಿನಿಯರ್ ಮಾಡಲು ಅಧಿಕಾರ ನೀಡುತ್ತದೆ."
                                          -uniGram
ಅವಲೋಕನ:
GCM HASTRO (GCM Heikin Ashi SuperTrend RSI Oscillator) ಗೆ ಸ್ವಾಗತ. ಇದು uniGram ಅವರ ಮೂಲಕ ಸಿದ್ಧಪಡಿಸಲಾದ ಒಂದು ಅತ್ಯುನ್ನತ ಮಟ್ಟದ (Institutional-Grade) ಮಲ್ಟಿಪಲ್ ಟೈಮ್‌ಫ್ರೇಮ್ ಇಂಡಿಕೇಟರ್ ಆಗಿದೆ. ಷೇರು ಮಾರುಕಟ್ಟೆ, ಇಂಡೆಕ್ಸ್ ಡೆರಿವೇಟಿವ್ಸ್ (Nifty F&O) ಮತ್ತು ಕ್ರಿಪ್ಟೋ ಟ್ರೇಡರ್‌ಗಳಿಗಾಗಿ ವಿನ್ಯಾಸಗೊಳಿಸಲಾದ ಈ ಸ್ಕ್ರಿಪ್ಟ್, ಮಾರುಕಟ್ಟೆಯ ಗೊಂದಲಗಳನ್ನು (Market Noise) ನಿವಾರಿಸಿ ನಿಖರವಾದ ಟ್ರೇಡಿಂಗ್ ನಿರ್ಧಾರಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.

ಪ್ರಮುಖ ತಂತ್ರಜ್ಞಾನ ಮತ್ತು ಎಂಜಿನ್‌ಗಳು (Core Architecture & Key Engines)
1. HARSI (Heikin Ashi Smoothed RSI) ಎಂಜಿನ್:
ಸಾಮಾನ್ಯ RSI ನಂತೆ ಪದೇ ಪದೇ ತಪ್ಪು ಸಿಗ್ನಲ್ ಕೊಡುವುದನ್ನು ತಪ್ಪಿಸಲು, ಇದು Heikin Ashi ಸ್ಮೂತಿಂಗ್ ತಂತ್ರಜ್ಞಾನವನ್ನು ಬಳಸಿ ಕ್ಲೀನ್ ಆದ ಮೊಮೆಂಟಮ್ ವೇವ್‌ಗಳನ್ನು ಸೃಷ್ಟಿಸುತ್ತದೆ. ಇದು Overbought (75 ರಿಂದ 85) ಮತ್ತು Oversold (15 ರಿಂದ 25) ಝೋನ್‌ಗಳನ್ನು ಸ್ಪಷ್ಟವಾಗಿ ತೋರಿಸುತ್ತದೆ.

2. ಬ್ಯಾಂಕರ್ ಫಂಡ್ ಫ್ಲೋ (Banker Fund Flow - Institutional Accumulation Model):
ದೊಡ್ಡ ದೊಡ್ಡ ಇನ್‌ಸ್ಟಿಟ್ಯೂಶನ್‌ಗಳು ಮತ್ತು ಸ್ಮಾರ್ಟ್ ಮನಿ ಎಲ್ಲಿ ಬಂಡವಾಳ ಹೂಡುತ್ತಿದೆ ಎಂಬುದನ್ನು ಇದು ಟ್ರ್ಯಾಕ್ ಮಾಡುತ್ತದೆ. ಇದು ಮಾರುಕಟ್ಟೆಯ ಪರಿಸ್ಥಿತಿಯನ್ನು ಈ ಕೆಳಗಿನಂತೆ ವಿಂಗಡಿಸುತ್ತದೆ:
o ENTRY: ದೊಡ್ಡ ಸಂಸ್ಥೆಗಳು ಮಾರುಕಟ್ಟೆಗೆ ಪ್ರವೇಶಿಸುತ್ತಿರುವ ಹಂತ.
o W.REB (Weak Rebound): ಮುಖ್ಯ ಟ್ರೆಂಡ್ ನಡುವೆ ಆಗುವ ಸಣ್ಣ ರಿಟ್ರೇಸ್‌ಮೆಂಟ್.
o INCR / DECR: ಇನ್‌ಸ್ಟಿಟ್ಯೂಶನಲ್ ಮೊಮೆಂಟಮ್ ಹೆಚ್ಚಾಗುತ್ತಿರುವುದು ಅಥವಾ ಕಡಿಮೆಯಾಗುತ್ತಿರುವುದು.
o EXIT: ಬಂಡವಾಳ ಹೊರಹೋಗುತ್ತಿರುವ ಹಂತ.

ಬ್ಯಾಂಕರ್ ಫಂಡ್ ಫ್ಲೋ ಬಣ್ಣಗಳ ವಿವರಣೆ (Banker Fund Flow Legend)
• 🟡 ಬ್ಯಾಂಕರ್ ಎಂಟ್ರಿ (Banker Entry - ಹಳದಿ): ದೊಡ್ಡ ಸಂಸ್ಥೆಗಳು (Smart Money) ಮಾರುಕಟ್ಟೆಗೆ ಬಲವಾಗಿ ಪ್ರವೇಶಿಸುತ್ತಿರುವ ನಿಖರವಾದ ಕ್ಷಣವನ್ನು ಇದು ತೋರಿಸುತ್ತದೆ (ಚಾರ್ಟ್‌ನಲ್ಲಿ ಹಳದಿ ಬಣ್ಣದ ಕ್ಯಾಂಡಲ್‌ಗಳ ಮೂಲಕ ಇದು ಸ್ಪಷ್ಟವಾಗಿ ಗೋಚರಿಸುತ್ತದೆ).
[image]https://www.tradingview.com/x/cY4s5cK8/[/image]

• 🟢 ಬ್ಯಾಂಕರ್ ಇನ್‌ಕ್ರೀಸ್ (Banker Increase - ಹಸಿರು): ಖರೀದಿದಾರರ ವೇಗ (Buyer Momentum) ಹೆಚ್ಚಾಗುತ್ತಿರುವುದನ್ನು ಮತ್ತು ನಿರಂತರವಾಗಿ ಇನ್‌ಸ್ಟಿಟ್ಯೂಶನಲ್ ಬಂಡವಾಳ ಹರಿಯುತ್ತಿರುವುದನ್ನು ಸೂಚಿಸುತ್ತದೆ.
[image]https://www.tradingview.com/x/zywOsQN7/[/image]

• ⚪ ಬ್ಯಾಂಕರ್ ಡಿಕ್ರೀಸ್ (Banker Decrease - ಬಿಳಿ/ಬೂದು): ಇನ್‌ಸ್ಟಿಟ್ಯೂಶನಲ್ ಬೈಯಿಂಗ್ ಮೊಮೆಂಟಮ್ ನಿಧಾನವಾಗುತ್ತಿರುವುದನ್ನು ಅಥವಾ ತಣ್ಣಗಾಗುತ್ತಿರುವುದನ್ನು ತೋರಿಸುತ್ತದೆ.
[image]https://www.tradingview.com/x/VWPkGiop/[/image]

• 🔴 ಬ್ಯಾಂಕರ್ ಎಕ್ಸಿಟ್ (Banker Exit - ಕೆಂಪು): ಬಂಡವಾಳ ಹೊರಹೋಗುತ್ತಿರುವುದನ್ನು (Capital Outflow) ಅಥವಾ ಇನ್‌ಸ್ಟಿಟ್ಯೂಷನ್‌ಗಳು ಪ್ರಾಫಿಟ್ ಬುಕ್ ಮಾಡಿ ಹೊರನಡೆಯುತ್ತಿರುವುದನ್ನು ಸೂಚಿಸುತ್ತದೆ.
[image]https://www.tradingview.com/x/71iu15OY/[/image]

• 🔵 ವೀಕ್ ರಿಬೌಂಡ್ (Weak Rebound - ನೀಲಿ): ಮುಖ್ಯ ಟ್ರೆಂಡ್ ನಡುವೆ ತಾತ್ಕಾಲಿಕವಾಗಿ ಅಥವಾ ದುರ್ಬಲವಾಗಿ ಆಗುವ ಸಣ್ಣ ರಿಟ್ರೇಸ್‌ಮೆಂಟ್ ಅಥವಾ ಬೌನ್ಸ್‌ ಅನ್ನು ಸೂಚಿಸುತ್ತದೆ.
[image]https://www.tradingview.com/x/OM6V5mtT/[/image]
	
3. ಟಾಪ್-ಡೌನ್ 5-ಟೈಮ್‌ಫ್ರೇಮ್ ಮ್ಯಾಟ್ರಿಕ್ಸ್ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್:
ಚಾರ್ಟ್‌ನಲ್ಲೇ ನೇರವಾಗಿ 5 ವಿಭಿನ್ನ ಟೈಮ್‌ಫ್ರೇಮ್ಗಳ (Micro, LTF, CTF, HTF, Macro) ರಿಯಲ್-ಟೈಮ್ ಸ್ಥಿತಿಯನ್ನು ಇದು ತೋರಿಸುತ್ತದೆ. ಟ್ರೆಂಡ್ (BULL ಅಥವಾ BEAR), ಫಂಡ್ ಫ್ಲೋ ಮತ್ತು RSI ಸ್ಲೋಪ್ ಹೇಗಿದೆ ಎಂಬುದನ್ನು ಒಂದೇ ನೋಟದಲ್ಲಿ ತಿಳಿಯಬಹುದು.
[image]https://www.tradingview.com/x/BPRl8lln/[/image]

4. ಡೈವರ್ಜೆನ್ಸ್ ಥಿಯರಿ (Divergence Theory):
Normal RSI ಲೈನ್‌ನಲ್ಲಿ ಮೂಡುವ Regular ಮತ್ತು Hidden ಡೈವರ್ಜೆನ್ಸ್‌ಗಳನ್ನು ಇದು ಆಟೋಮ್ಯಾಟಿಕ್ ಆಗಿ ಗುರುತಿಸಿ ಚಾರ್ಟ್ ಮೇಲೆ ಲೈನ್ ಮತ್ತು ಲೇಬಲ್‌ಗಳ ಮೂಲಕ ಎಚ್ಚರಿಕೆ ನೀಡುತ್ತದೆ.
[image]https://www.tradingview.com/x/uD0v9ePp/[/image]

5. HA ಸೂಪರ್ ಟ್ರೆಂಡ್ ಮತ್ತು ಫಿಲ್ಟರ್‌ಗಳು:
ವೈವಿಲ್ಯಮಯ ವಿಕ್ರೇಷನ್ ಫಿಲ್ಟರ್‌ಗಳು, ವಾಲೂಮ್ (RVOL) ಮತ್ತು ATR ಚೆಕ್‌ಗಳೊಂದಿಗೆ ಮಾರುಕಟ್ಟೆಯಲ್ಲಿ ನಕಲಿ ಬ್ರೇಕ್‌ಔಟ್‌ಗಳನ್ನು (False Breakouts) ಇದು ತಡೆಯುತ್ತದೆ.
[image]https://www.tradingview.com/x/vxf26Yc9/[/image]

ಟ್ರೇಡಿಂಗ್ ಮಾಡುವ ವಿಧಾನ (Execution Framework: How to Trade)
ಅತ್ಯುತ್ತಮ ಫಲಿತಾಂಶಕ್ಕಾಗಿ ಈ ಕೆಳಗಿನ ಹಂತಗಳನ್ನು ಅನುಸರಿಸಿ ಟ್ರೇಡ್ ಮಾಡಿ:
• ಹಂತ 1: ಮ್ಯಾಟ್ರಿಕ್ಸ್ ಮೈದಾನ ಪರಿಶೀಲನೆ (Matrix Alignment)
ಯಾವುದೇ ಟ್ರೇಡ್ ಮಾಡುವ ಮೊದಲು ಮಿನಿ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ನೋಡಿ. ನಿಮ್ಮ ಉನ್ನತ ಟೈಮ್‌ಫ್ರೇಮ್ (HTF) ಮತ್ತು ಮ್ಯಾಕ್ರೋ ಟ್ರೆಂಡ್ ನೀವು ಮಾಡುವ ಟ್ರೇಡ್ ದಿಕ್ಕಿನಲ್ಲೇ ಇವೆಯಾ ಎಂದು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.

• ಹಂತ 2: ಫಂಡ್ ಫ್ಲೋ ಕನ್ಫರ್ಮೇಷನ್
ಬ್ಯಾಂಕರ್ ಫಂಡ್ ಫ್ಲೋ ಸ್ಟೇಟಸ್ ನಿಮಗೆ ಸಪೋರ್ಟ್ ಮಾಡುತ್ತಿದೆಯಾ ನೋಡಿ (ಉದಾಹರಣೆಗೆ ಲಾಂಗ್ ಟ್ರೇಡ್‌ಗೆ ENTRY ಅಥವಾ INCR ಇರಬೇಕು). ಫಂಡ್ ಫ್ಲೋ ವಿರುದ್ಧವಾಗಿ ಎಂದಿಗೂ ಟ್ರೇಡ್ ಮಾಡಬೇಡಿ.

• ಹಂತ 3: ಸಿಗ್ನಲ್ ಟ್ರಿಗರ್
o ಬೈ (Long Entry): ನಿಯಾನ್ ಕಿಯನ್ ಬಣ್ಣದ ಮೇಲ್ಮುಖ ತ್ರಿಕೋನ (Triangle) ಮೂಡಿದಾಗ ಅಥವಾ HARSI ಓವರ್‌ಸೋಲ್ಡ್ ಝೋನ್‌ನಿಂದ ಮೇಲಕ್ಕೆ ಬ್ರೇಕ್ಔಟ್ ಆದಾಗ.
o ಸೆಲ್ (Short Entry): ನಿಯಾನ್ ಕ್ರಿಮ್ಸನ್ ಬಣ್ಣದ ಕೆಳಮುಖ ತ್ರಿಕೋನ ಮೂಡಿದಾಗ ಅಥವಾ HARSI ಓವರ್‌ಬಾಟ್ ಝೋನ್‌ನಿಂದ ಕೆಳಕ್ಕೆ ಕ್ರಾಸ್ ಆದಾಗ.

ರಿಸ್ಕ್ ಮ್ಯಾನೇಜ್‌ಮೆಂಟ್ (Trade & Risk Management)
• ಸ್ಟಾಪ್-ಲಾಸ್ (Stop-Loss): HA ಸೂಪರ್ ಟ್ರೆಂಡ್ ಲೈನ್ ಅಥವಾ ಹತ್ತಿರದ ಸ್ವಿಂಗ್ ಸಪೋರ್ಟ್/ರೆಸಿಸ್ಟ್ ಹಾಗೂ ATR ಅಳತೆಯನ್ನು ಸ್ಟಾಪ್‌ಲಾಸ್ ಆಗಿ ಬಳಸಿ.
• ಪೊಸಿಷನ್ ಸೈಜಿಂಗ್: ನಿಮ್ಮ ಒಟ್ಟು ಕ್ಯಾಪಿಟಲ್‌ನ ಶೇಕಡಾ 1 ರಿಂದ 2 ರಷ್ಟು ಹಣವನ್ನು ಮಾತ್ರ ಒಂದೇ ಟ್ರೇಡ್‌ನಲ್ಲಿ ರಿಸ್ಕ್ ಮಾಡಿ. ವಿಶೇಷವಾಗಿ ನಿಫ್ಟಿ ಡೆರಿವೇಟಿವ್ಸ್ ಅಥವಾ ಕ್ರಿಪ್ಟೋ ಟ್ರೇಡ್ ಮಾಡುವಾಗ ಇದು ಅತ್ಯಗತ್ಯ.
• ಪ್ರಾಫಿಟ್ ಬುಕಿಂಗ್: ಬೆಲೆಯು ಪ್ರಮುಖ ಸಪೋರ್ಟ್/ರೆಸಿಸ್ಟೆನ್ಸ್ ತಲುಪಿದಾಗ ಹಂತ ಹಂತವಾಗಿ ಪ್ರಾಫಿಟ್ ಬುಕ್ ಮಾಡಿ.

ಹಕ್ಕುತ್ಯಾಗ (Disclaimer)
GCM HASTRO ಸ್ಕ್ರಿಪ್ಟ್ ಕೇವಲ ವಿಶ್ಲೇಷಣೆ, ಶೈಕ್ಷಣಿಕ ಮತ್ತು ಮಾಹಿತಿ ಉದ್ದೇಶಗಳಿಗಾಗಿ ಮಾತ್ರ ರೂಪಿಸಲಾಗಿದೆ. ಇದು ಯಾವುದೇ ಅಧಿಕೃತ ಹಣಕಾಸು ಸಲಹೆಯಲ್ಲ. ಹಣಕಾಸು ಮಾರುಕಟ್ಟೆಗಳು, ಡೆರಿವೇಟಿವ್ಸ್ ಮತ್ತು ಕ್ರಿಪ್ಟೋ ಟ್ರೇಡಿಂಗ್‌ನಲ್ಲಿ ಬಂಡವಾಳ ನಷ್ಟವಾಗುವ ದೊಡ್ಡ ಅಪಾಯವಿರುತ್ತದೆ. ರಿಯಲ್ ಮಾರ್ಕೆಟ್‌ನಲ್ಲಿ ಹಣ ಹೂಡಿಕೆ ಮಾಡುವ ಮುನ್ನ ನಿಮ್ಮ ಸ್ವಂತ ಜ್ಞಾನ ಮತ್ತು ವಿಶ್ಲೇಷಣೆಯನ್ನು ಬಳಸಿ ರಿಸ್ಕ್ ನಿರ್ವಹಣೆ ಮಾಡಿ.

HAPPY TRADING

---

## Source Code

````pine
//@version=6
indicator("GCM Heikin Ashi SuperTrend RSI Oscillator", shorttitle="GCM HASTRO", overlay=false, format=format.price, precision=2, max_labels_count=500, max_lines_count=500)

// =============================================================================
// --- INPUTS: HARSI SETTINGS ---
// =============================================================================
string g_harsi = "HARSI Settings"
int i_lenHARSI  = input.int(10, "HARSI Length", group=g_harsi, minval=1)
int i_smoothing = input.int(5, "HARSI Open Smoothing", group=g_harsi, minval=1, maxval=100)

// --- Calculation Constants for Zones ---
float obLower  = 75.0
float obUpper  = 85.0
float osLower  = 15.0
float osUpper  = 25.0

// --- Group: Normal RSI Line Settings ---
string g_nrsi = "Normal RSI Line Settings"
bool i_showRsiLine = input.bool(false, "Show Normal RSI Line", group=g_nrsi)
int i_rsiLen = input.int(14, "Normal RSI Length", group=g_nrsi, minval=1)
color i_rsiColor = input.color(#ff9800, "Normal RSI Color", group=g_nrsi)

// --- Group: Institutional Fund Flow Settings ---
string g_banker = "Institutional Fund Flow Settings"
bool i_enableBankerColors = input.bool(true, "Enable Institutional Accumulation Mode", group=g_banker, tooltip="Toggles custom fund flow candlestick coloring on/off.")

// --- Group: HA Super Trend Line ---
string g_hast = "HA Super Trend Settings"
bool i_showHAST = input.bool(true, "Show HA Super Trend Line", group=g_hast)
float i_haStWickRatio = input.float(0.25, "Max Wick Ratio for Strong Momentum", minval=0.0, maxval=1.0, step=0.05, group=g_hast, tooltip="Ratio of wick to body size to qualify as no/small wick for trend switching.")
float i_haStOffset = input.float(2.0, "Line Spacing Offset", minval=0.01, maxval=10.0, step=0.1, group=g_hast, tooltip="Adjusts the distance of the trend line from the candles.")
color i_haStBullCol = input.color(#00FF00, "HA ST Bullish Color", group=g_hast, inline="hast_col")
color i_haStBearCol = input.color(#FF0000, "HA ST Bearish Color", group=g_hast, inline="hast_col")

// --- Group: Divergence Theory (Normal RSI) ---
string GROUP_DIV = "Divergence Theory (Normal RSI)"
int leftBars = input.int(5, "Pivot Left Bars", minval=1, group=GROUP_DIV, tooltip="Used for identifying divergence peaks/troughs.")
int rightBars = input.int(5, "Pivot Right Bars", minval=1, group=GROUP_DIV, tooltip="Used for identifying divergence peaks/troughs.")
bool i_showDiv = input.bool(true, "Show Divergence Lines & Labels?", group=GROUP_DIV)
string div_label_size_str = input.string("Tiny", "Div Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GROUP_DIV)
color colDivBull = input.color(#05520b, "Bullish Label Color", group=GROUP_DIV) 
color colDivBear = input.color(#5d060d, "Bearish Label Color", group=GROUP_DIV) 
color colLineBull = input.color(#00E676, "Bullish Line Color (Highlighted)", group=GROUP_DIV)
color colLineBear = input.color(#FF1744, "Bearish Line Color (Highlighted)", group=GROUP_DIV)
color colDivText = input.color(color.white, "Div Text Color", group=GROUP_DIV)

// --- Group: Advanced Confluence & Breakout Filters (PREMIUM) ---
string g_filters = "Advanced Confluence & Breakout Filters"
bool i_enableBreakouts = input.bool(true, "Include OB/OS Breakout Signals", group=g_filters, tooltip="Triggers signals when HARSI breaks out of Overbought/Oversold ribbon boundaries.")
bool i_filterBuffer = input.bool(false, "Filter by Oscillator Buffer Zone", group=g_filters, tooltip="Buy only when HARSI is in Lower/OS zone, Sell only in Upper/OB zone.")
float i_minWaveSize = input.float(3.0, "Minimum HARSI Wave Size", minval=0.1, group=g_filters, tooltip="Filters out small choppy waves in sub-chart.")
bool i_filterRvol = input.bool(false, "Require Above Average Volume (Vol > SMA)", group=g_filters)
bool i_filterAtr = input.bool(false, "Require Volatile Candle (Range > ATR)", group=g_filters)
float i_atrMult = input.float(0.5, "ATR Factor Multiplier", minval=0.1, step=0.1, group=g_filters)
bool i_filterZero = input.bool(false, "Require Mid-Line (50) Cross for Signals", group=g_filters)
bool i_filterFundFlow = input.bool(true, "Require Fund Flow Alignment for Signals", group=g_filters, tooltip="Filters out signals unless backed by supportive Fund Flow states (Hybrid Confluence).")

// --- Group: Dashboard Settings (TOP-DOWN MTF UI) ---
string g_dash = "Dashboard Settings"
bool i_showDash = input.bool(true, "Show Mini Matrix Dashboard", group=g_dash)
string i_dashSize = input.string("Tiny", "Dashboard Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_dash)
string i_tfMicro = input.timeframe("5", "Micro TF", group=g_dash)
string i_tfLTF   = input.timeframe("15", "Lower TF (LTF)", group=g_dash)
string i_tfHTF   = input.timeframe("60", "Higher TF (HTF)", group=g_dash)
string i_tfMacro = input.timeframe("240", "Macro TF (HHTF)", group=g_dash)

// =============================================================================
// --- INSTITUTIONAL UNIFORM COLOR PALETTE ---
// =============================================================================
color inst_green  = color.rgb(34, 197, 94)   
color inst_red    = color.rgb(239, 68, 68)   
color inst_cyan   = color.rgb(56, 189, 248)  
color inst_slate  = color.rgb(148, 163, 184) 
color inst_neutral= color.rgb(203, 213, 225) 

// =============================================================================
// --- INPUTS: INSTITUTIONAL STYLE SETTINGS ---
// =============================================================================
string g_style = "Institutional Style Settings"

string g_signals = "Signal Settings"
color buySignalColor = input.color(#00F2FE, "Buy Neon Cyan Color", group=g_signals, inline="signal_colors")
color sellSignalColor = input.color(#FF007A, "Sell Neon Crimson Color", group=g_signals, inline="signal_colors")
string signal_size_str = input.string("Normal", "Signal Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=g_signals)

// =============================================================================
// --- FUNCTIONS: HARSI CALCULATION ---
// =============================================================================
f_rsiHeikinAshi(_length, _smoothing) =>
    float _closeRSI = ta.rsi(close, _length)
    float _openRSI  = nz(_closeRSI[1], _closeRSI)
    float _highRSI_raw  = ta.rsi(high, _length)
    float _lowRSI_raw   = ta.rsi(low, _length)
    float _highRSI  = math.max(_highRSI_raw, _lowRSI_raw)
    float _lowRSI   = math.min(_highRSI_raw, _lowRSI_raw)
    float _closeVal    = (_openRSI + _highRSI + _lowRSI + _closeRSI) / 4
    
    var float _open = na
    _open  := na(_open[_smoothing]) ? (_openRSI + _closeRSI) / 2 : ((_open[1] * _smoothing) + _closeVal[1]) / (_smoothing + 1)
    
    float _high     = math.max(_highRSI, math.max(_open, _closeVal))
    float _low      = math.min(_lowRSI,  math.min(_open, _closeVal))
    [_open, _high, _low, _closeVal]

// =============================================================================
// --- FUNCTIONS: BANKER FUND FLOW LOGIC ---
// =============================================================================
find_recent_value(values, length) =>
    recent_value = float(na)
    if length >= 1
        for i = 0 to length by 1
            if na(recent_value) or not na(values[i])
                recent_value := values[i]
                recent_value
    recent_value

calculate_weighted_simple_average(src, length, weight) =>
    sum_float = 0.0
    moving_average = 0.0
    output = 0.0
    sum_float := nz(sum_float[1]) - nz(src[length]) + src
    moving_average := na(src[length]) ? na : sum_float / length
    output := na(output[1]) ? moving_average : (src * weight + output[1] * (length - weight)) / length
    output

calculate_banker_fund_flow(_close, _low, _high, _open) =>
    typical_price = (2 * _close + _high + _low + _open) / 5
    lowest_low = ta.lowest(_low, 34)
    highest_high = ta.highest(_high, 34)
    fund_flow_trend = (3 * calculate_weighted_simple_average((_close - ta.lowest(_low, 27)) / (ta.highest(_high, 27) - ta.lowest(_low, 27)) * 100, 5, 1) - 2 * calculate_weighted_simple_average(calculate_weighted_simple_average((_close - ta.lowest(_low, 27)) / (ta.highest(_high, 27) - ta.lowest(_low, 27)) * 100, 5, 1), 3, 1) - 50) * 1.032 + 50
    bull_bear_line = ta.ema((typical_price - lowest_low) / (highest_high - lowest_low) * 100, 13)
    banker_entry_signal = ta.crossover(fund_flow_trend, bull_bear_line) and bull_bear_line < 25
    [fund_flow_trend, bull_bear_line, banker_entry_signal]

f_get_ff_status(fft, bbl, bes) =>
    string ffText = "NEUT"
    color ffCol = inst_slate
    if bes
        ffText := "ENTRY"
        ffCol := inst_green
    else if fft < bbl and fft > find_recent_value(fft * 0.95, 1)
        ffText := "W.REB"
        ffCol := inst_cyan
    else if fft < bbl
        ffText := "EXIT"
        ffCol := inst_red
    else if fft < find_recent_value(fft * 0.95, 1)
        ffText := "DECR"
        ffCol := inst_red
    else if fft > bbl
        ffText := "INCR"
        ffCol := inst_green
    [ffText, ffCol]

f_slope_color(curr, prev) =>
    curr > prev ? inst_green : curr < prev ? inst_red : inst_neutral

// =============================================================================
// --- SCRIPT LOGIC ---
// =============================================================================
[osc_open, osc_high, osc_low, osc_close] = f_rsiHeikinAshi(i_lenHARSI, i_smoothing)

float normalRsiVal = ta.rsi(close, i_rsiLen)

[fund_flow_trend, bull_bear_line, banker_entry_signal] = calculate_banker_fund_flow(close, low, high, open)

[fundFlowText, fundFlowColor] = f_get_ff_status(fund_flow_trend, bull_bear_line, banker_entry_signal)

// =============================================================================
// --- MTF DATA ENGINE (5 TIMEFRAMES) - OPTIMIZED ---
// =============================================================================
f_mtf_bundle() =>
    [o, ignore_h, ignore_l, c] = f_rsiHeikinAshi(i_lenHARSI, i_smoothing)
    [fft, bbl, bes] = calculate_banker_fund_flow(close, low, high, open)
    float rsi_curr = ta.rsi(close, i_rsiLen)
    float rsi_prev = rsi_curr[1]
    [o, c, fft, bbl, bes, rsi_curr, rsi_prev]

f_mtf_fetch(tf) =>
    [o, c, fft, bbl, bes, rsi_val, rsi_val_prev] = request.security(syminfo.tickerid, tf, f_mtf_bundle(), barmerge.gaps_off, barmerge.lookahead_off)
    [txt, col] = f_get_ff_status(fft, bbl, bes)
    [c >= o, txt, col, rsi_val, rsi_val_prev]

[micro_isUp, micro_ffText, micro_ffCol, micro_rsiVal, micro_rsiValPrev] = f_mtf_fetch(i_tfMicro)
[ltf_isUp, ltf_ffText, ltf_ffCol, ltf_rsiVal, ltf_rsiValPrev] = f_mtf_fetch(i_tfLTF)
[htf_isUp, htf_ffText, htf_ffCol, htf_rsiVal, htf_rsiValPrev] = f_mtf_fetch(i_tfHTF)
[macro_isUp, macro_ffText, macro_ffCol, macro_rsiVal, macro_rsiValPrev] = f_mtf_fetch(i_tfMacro)

// Update logic mappings to use new 5-char max strings
bool isFundFlowBullish = (fundFlowText == "ENTRY" or fundFlowText == "INCR" or fundFlowText == "W.REB")
bool isFundFlowBearish = (fundFlowText == "EXIT" or fundFlowText == "DECR")

color default_ha_color = osc_close >= osc_open ? color.new(#059669, 15) : color.new(#DC2626, 15)

color banker_ha_color = if not i_enableBankerColors
    default_ha_color
else if banker_entry_signal
    color.yellow
else if fund_flow_trend < bull_bear_line and fund_flow_trend > find_recent_value(fund_flow_trend * 0.95, 1)
    color.blue
else if fund_flow_trend < bull_bear_line
    color.red
else if fund_flow_trend < find_recent_value(fund_flow_trend * 0.95, 1)
    color.white
else if fund_flow_trend > bull_bear_line
    color.green
else
    color.gray

float harsiWaveSize = math.abs(osc_close - osc_open)
bool isWaveSizeValid = harsiWaveSize >= i_minWaveSize

bool isBuyZoneValid = not i_filterBuffer or (osc_close <= osUpper or osc_close < 50)
bool isSellZoneValid = not i_filterBuffer or (osc_close >= obLower or osc_close > 50)

float volSma = ta.sma(volume, 20)
bool isVolumeAboveAvg = volume > volSma

float atrVal = ta.atr(14)
float currentBarRange = high - low
bool isAtrValid = currentBarRange >= (atrVal * i_atrMult)

bool isHaUp = osc_close >= osc_open
bool baseBuy = not isHaUp[1] and isHaUp
bool baseSell = isHaUp[1] and not isHaUp

bool crossUp_osLower = ta.crossover(osc_close, osLower)
bool crossUp_obLower = ta.crossover(osc_close, obLower)
bool bullBreakout = crossUp_osLower or crossUp_obLower

bool crossDn_obUpper = ta.crossunder(osc_close, obUpper)
bool crossDn_osUpper = ta.crossunder(osc_close, osUpper)
bool bearBreakout = crossDn_obUpper or crossDn_osUpper

bool rawBuy = baseBuy or (i_enableBreakouts and bullBreakout)
bool rawSell = baseSell or (i_enableBreakouts and bearBreakout)

bool volCondition = i_filterRvol ? isVolumeAboveAvg : true
bool atrCondition = i_filterAtr ? isAtrValid : true
bool zeroCondition = i_filterZero ? (osc_close > 50) : true
bool sellZeroCondition = i_filterZero ? (osc_close < 50) : true
bool fundFlowBuyCond = not i_filterFundFlow or isFundFlowBullish
bool fundFlowSellCond = not i_filterFundFlow or isFundFlowBearish

bool buySignal = rawBuy and isWaveSizeValid and isBuyZoneValid and volCondition and atrCondition and zeroCondition and fundFlowBuyCond
bool sellSignal = rawSell and isWaveSizeValid and isSellZoneValid and volCondition and atrCondition and sellZeroCondition and fundFlowSellCond

// =============================================================================
// --- WAVE SCALES & RIBBON ZONES ---
// =============================================================================
hline_ob_upper   = hline(85.0, title="OB Upper", color=color.new(#EF4444, 50), linestyle=hline.style_dashed, linewidth=1)
hline_ob_lower   = hline(75.0, title="OB Lower", color=color.new(#EF4444, 50), linestyle=hline.style_dashed, linewidth=1)
hline_chop_upper = hline(55.0, title="Choppy Upper", color=color.new(#94A3B8, 50), linestyle=hline.style_dashed, linewidth=1)
hline_mid        = hline(50.0, title="Median (50)", color=color.new(#64748B, 50), linestyle=hline.style_dashed, linewidth=1)
hline_chop_lower = hline(45.0, title="Choppy Lower", color=color.new(#94A3B8, 50), linestyle=hline.style_dashed, linewidth=1)
hline_os_upper   = hline(25.0, title="OS Upper", color=color.new(#10B981, 50), linestyle=hline.style_dashed, linewidth=1)
hline_os_lower   = hline(15.0, title="OS Lower", color=color.new(#10B981, 50), linestyle=hline.style_dashed, linewidth=1)

fill(hline_ob_upper, hline_ob_lower, color=color.new(#EF4444, 90), title="OB Ribbon Fill")
fill(hline_os_upper, hline_os_lower, color=color.new(#10B981, 90), title="OS Ribbon Fill")
fill(hline_ob_lower, hline_os_upper, color=color.new(#2196F3, 90), title="Channel Fill (25 to 75)")
fill(hline_chop_upper, hline_chop_lower, color=color.new(#94A3B8, 90), title="Choppy Ribbon Fill (45 to 55)")

bool isBankerEntry = banker_entry_signal
float plot_open  = isBankerEntry ? (osc_close < 50 ? 0.0 : 50.0) : osc_open
float plot_high  = isBankerEntry ? (osc_close < 50 ? 50.0 : 100.0) : osc_high
float plot_low   = isBankerEntry ? (osc_close < 50 ? 0.0 : 50.0) : osc_low
float plot_close = isBankerEntry ? (osc_close < 50 ? 50.0 : 100.0) : osc_close

plotcandle(plot_open, plot_high, plot_low, plot_close, "HARSI Wave Candles", color=banker_ha_color, wickcolor=banker_ha_color, bordercolor=banker_ha_color)

plot(i_showRsiLine ? normalRsiVal : na, title="Normal RSI Line", color=color.new(i_rsiColor, 20), linewidth=1, style=plot.style_line)

// =============================================================================
// --- HA SUPER TREND LINE LOGIC ---
// =============================================================================
float haBody = math.abs(osc_close - osc_open)
float haLowerWick = math.min(osc_open, osc_close) - osc_low
float haUpperWick = osc_high - math.max(osc_open, osc_close)

bool isBullNoWick = (osc_close >= osc_open) and (haLowerWick <= (haBody * i_haStWickRatio) or haBody == 0)
bool isBearNoWick = (osc_close < osc_open) and (haUpperWick <= (haBody * i_haStWickRatio) or haBody == 0)
bool isIndefinite  = not isBullNoWick and not isBearNoWick

var int hastTrend = 1
if isBullNoWick
    hastTrend := 1
else if isBearNoWick
    hastTrend := -1

float bullLineVal = osc_low - i_haStOffset
float bearLineVal = osc_high + i_haStOffset
float middleLineVal = (osc_open + osc_close) / 2

float haStLine = na
color haStColor = na

if isIndefinite
    haStLine := middleLineVal
    haStColor := color.new(#94A3B8, 0)
else if hastTrend == 1
    haStLine := bullLineVal
    haStColor := i_haStBullCol
else
    haStLine := bearLineVal
    haStColor := i_haStBearCol

plot(i_showHAST ? haStLine : na, title="HA Super Trend Line", color=haStColor, linewidth=2, style=plot.style_line)

string signal_size = switch signal_size_str
    "Tiny"      => size.tiny
    "Small"     => size.small
    "Large"     => size.large
    "Huge"      => size.huge
    => size.normal

string div_label_size = switch div_label_size_str
    "Tiny"      => size.tiny
    "Small"     => size.small
    "Large"     => size.large
    "Huge"      => size.huge
    => size.normal

// =============================================================================
// --- DIVERGENCE THEORY LOGIC (ON NORMAL RSI LINE) ---
// =============================================================================
float phRsi = ta.pivothigh(normalRsiVal, leftBars, rightBars)
float plRsi = ta.pivotlow(normalRsiVal, leftBars, rightBars)

var float lastPhRsi = na, var int lastPhIdx = na, var float prevPhRsi = na, var int prevPhIdx = na
var float lastPlRsi = na, var int lastPlIdx = na, var float prevPlRsi = na, var int prevPlIdx = na
var float lastPhPrice = na, var float prevPhPrice = na
var float lastPlPrice = na, var float prevPlPrice = na

bool isRegBear = false
bool isHidBear = false
bool isRegBull = false
bool isHidBull = false

if not na(phRsi)
    prevPhRsi := lastPhRsi, prevPhIdx := lastPhIdx, prevPhPrice := lastPhPrice
    lastPhRsi := phRsi, lastPhIdx := bar_index - rightBars, lastPhPrice := high[rightBars]
    
    if not na(prevPhRsi)
        bool rsiDown = lastPhRsi < prevPhRsi
        bool rsiUp = lastPhRsi > prevPhRsi
        bool priceUp = lastPhPrice > prevPhPrice
        bool priceDown = lastPhPrice < prevPhPrice
        
        isRegBear := priceUp and rsiDown
        isHidBear := priceDown and rsiUp

        if (isRegBear or isHidBear) and i_showDiv
            string bearDivText = isRegBear ? "RB Div" : "HB Div"
            label.new(x=lastPhIdx, y=lastPhRsi + 2.5, text=bearDivText, textcolor=colDivText, color=colDivBear, style=label.style_label_down, size=div_label_size)
            line.new(prevPhIdx, prevPhRsi, lastPhIdx, lastPhRsi, color=colLineBear, width=1, style=line.style_dashed)
            line.new(prevPhIdx, prevPhPrice, lastPhIdx, lastPhPrice, color=colLineBear, width=1, style=line.style_dashed, force_overlay=true)
            label.new(x=lastPhIdx, y=na, text=bearDivText, textcolor=colDivText, color=colDivBear, style=label.style_label_down, size=div_label_size, yloc=yloc.abovebar, force_overlay=true)

if not na(plRsi)
    prevPlRsi := lastPlRsi, prevPlIdx := lastPlIdx, prevPlPrice := lastPlPrice
    lastPlRsi := plRsi, lastPlIdx := bar_index - rightBars, lastPlPrice := low[rightBars]

    if not na(prevPlRsi)
        bool rsiUp = lastPlRsi > prevPlRsi
        bool rsiDown = lastPlRsi < prevPlRsi
        bool priceDown = lastPlPrice < prevPlPrice
        bool priceUp = lastPlPrice > prevPlPrice
        
        isRegBull := priceDown and rsiUp
        isHidBull := rsiUp and rsiDown

        if (isRegBull or isHidBull) and i_showDiv
            string bullDivText = isRegBull ? "RB Div" : "HB Div"
            label.new(x=lastPlIdx, y=lastPlRsi - 2.5, text=bullDivText, textcolor=colDivText, color=colDivBull, style=label.style_label_up, size=div_label_size)
            line.new(prevPlIdx, prevPlRsi, lastPlIdx, lastPlRsi, color=colLineBull, width=1, style=line.style_dashed)
            line.new(prevPlIdx, prevPlPrice, lastPlIdx, lastPlPrice, color=colLineBull, width=1, style=line.style_dashed, force_overlay=true)
            label.new(x=lastPlIdx, y=na, text=bullDivText, textcolor=colDivText, color=colDivBull, style=label.style_label_up, size=div_label_size, yloc=yloc.belowbar, force_overlay=true)

// =============================================================================
// --- NEON SIGNAL PLOTTING ON MAIN CHART ---
// =============================================================================
if buySignal 
    label.new(x=bar_index[1], y=na, text="▲", style=label.style_none, textcolor=buySignalColor, yloc=yloc.belowbar, size=signal_size, force_overlay=true)
    
if sellSignal 
    label.new(x=bar_index[1], y=na, text="▼", style=label.style_none, textcolor=sellSignalColor, yloc=yloc.abovebar, size=signal_size, force_overlay=true)


// =============================================================================
// --- MINI DASHBOARD (5 TIMEFRAMES) ---
// =============================================================================
string dash_size_val = switch i_dashSize
    "Tiny"      => size.tiny
    "Small"     => size.small
    "Large"     => size.large
    "Huge"      => size.huge
    => size.normal

var table dash = table.new(position = position.bottom_right, columns = 6, rows = 5, bgcolor = color.new(#090D16, 5), frame_color = color.new(#334155, 30), frame_width = 1, border_width = 1, border_color = color.new(#1E293B, 40))

// Helper Function to convert plain string Timeframes into clean readable strings (e.g., '15' to '15m', '60' to '1H')
f_format_tf(tf_str) =>
    string t = tf_str == "" ? timeframe.period : tf_str
    float val = str.tonumber(t)
    string res = t
    if not na(val)
        int mins = int(val)
        if mins < 60
            res := str.tostring(mins) + "m"
        else if mins < 1440 and mins % 60 == 0
            res := str.tostring(mins / 60) + "H"
        else
            res := str.tostring(mins) + "m"
    res

if i_showDash and barstate.islast
    // Header Row
    table.cell(dash, 0, 0, "MATRIX", text_color=inst_cyan, bgcolor=color.new(#1E293B, 40), text_halign=text.align_left, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 1, 0, "Micro", text_color=color.white, bgcolor=color.new(#1E293B, 40), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 2, 0, "LTF", text_color=color.white, bgcolor=color.new(#1E293B, 40), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 3, 0, "CTF", text_color=color.white, bgcolor=color.new(#1E293B, 40), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 4, 0, "HTF", text_color=color.white, bgcolor=color.new(#1E293B, 40), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 5, 0, "Macro", text_color=color.white, bgcolor=color.new(#1E293B, 40), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    
    // Timeframe Periods Row (Uniform Weight & Style)
    table.cell(dash, 0, 1, "Period", text_color=inst_slate, text_halign=text.align_left, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 1, 1, f_format_tf(i_tfMicro), text_color=micro_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 2, 1, f_format_tf(i_tfLTF), text_color=ltf_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 3, 1, f_format_tf(""), text_color=isHaUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 4, 1, f_format_tf(i_tfHTF), text_color=htf_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 5, 1, f_format_tf(i_tfMacro), text_color=macro_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)

    // Trend Row
    table.cell(dash, 0, 2, "Trend", text_color=inst_slate, text_halign=text.align_left, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 1, 2, micro_isUp ? "BULL" : "BEAR", text_color=micro_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 2, 2, ltf_isUp ? "BULL" : "BEAR", text_color=ltf_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 3, 2, isHaUp ? "BULL" : "BEAR", text_color=isHaUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 4, 2, htf_isUp ? "BULL" : "BEAR", text_color=htf_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 5, 2, macro_isUp ? "BULL" : "BEAR", text_color=macro_isUp ? inst_green : inst_red, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)

    // Banker Fund Flow Row
    table.cell(dash, 0, 3, "Fund Flow", text_color=inst_slate, text_halign=text.align_left, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 1, 3, micro_ffText, text_color=micro_ffCol, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 2, 3, ltf_ffText, text_color=ltf_ffCol, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 3, 3, fundFlowText, text_color=fundFlowColor, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 4, 3, htf_ffText, text_color=htf_ffCol, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 5, 3, macro_ffText, text_color=macro_ffCol, text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)

    // RSI Value Row
    table.cell(dash, 0, 4, "RSI Val", text_color=inst_slate, text_halign=text.align_left, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 1, 4, str.tostring(micro_rsiVal, "#.#"), text_color=f_slope_color(micro_rsiVal, micro_rsiValPrev), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 2, 4, str.tostring(ltf_rsiVal, "#.#"), text_color=f_slope_color(ltf_rsiVal, ltf_rsiValPrev), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 3, 4, str.tostring(normalRsiVal, "#.#"), text_color=f_slope_color(normalRsiVal, normalRsiVal[1]), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 4, 4, str.tostring(htf_rsiVal, "#.#"), text_color=f_slope_color(htf_rsiVal, htf_rsiValPrev), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)
    table.cell(dash, 5, 4, str.tostring(macro_rsiVal, "#.#"), text_color=f_slope_color(macro_rsiVal, macro_rsiValPrev), text_halign=text.align_center, text_size=dash_size_val, text_formatting=text.format_bold)

// =============================================================================
// --- CUSTOM ALERTS ---
// =============================================================================
alertcondition(buySignal, title="🟢 Institutional Buy Signal", message="GCM HASTRO: Neon Buy Triangle Detected on {{ticker}}")
alertcondition(sellSignal, title="🔴 Institutional Sell Signal", message="GCM HASTRO: Neon Sell Triangle Detected on {{ticker}}")
alertcondition(isRegBull or isHidBull, title="🐂 Bullish Divergence", message="GCM HASTRO: Bullish Divergence formed on {{ticker}}")
alertcondition(isRegBear or isHidBear, title="🐻 Bearish Divergence", message="GCM HASTRO: Bearish Divergence formed on {{ticker}}")
````
