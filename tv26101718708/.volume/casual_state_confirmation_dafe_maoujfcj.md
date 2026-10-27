# Casual State Confirmation [DAFE]

- url: https://www.tradingview.com/script/mAOuJfCj-Casual-State-Confirmation-DAFE/
- type: indicator
- pine_id: PUB;377bbdcaa24e4003baee96193d375a21
- version: 1.0

## Description

[b]Casual State Confirmation [DAFE][/b] 

This is a market-state classification and signal-generation system. Designed for professional proprietary firms and systematic retail traders, this overlay indicator operates on a profound technical thesis: [b]"Confirm the state casually, trade with anticipation.

Most modern trading systems fail because they rely on lag-heavy digital filters, suffer from the "curse of dimensionality" when processing historical charts, or ignore institutional order flow context. [b]⟡ CSC[/b] solves these structural challenges by fusing five cutting-edge quantitative methodologies into a single, cohesive, self-learning visual script:

[list]
[*]   [b]A Shift-Invariant Stationary Wavelet Transform (SWT) Engine[/b] running 5 selectable Mother Wavelet families with unsmoothed detail bands to capture immediate high-frequency energy shocks.
[*]   [b]A 13-Feature Non-Euclidean Lorentzian k-Nearest Neighbors (k-NN) Classifier[/b] with a strict, delayed-outcome training loop that dynamically updates a localized memory database.
[*]   [b]A LogicWeights Reinforcement Learning (RL) Processor[/b] that constantly optimizes pattern weight parameters based on realized win/loss trade outcomes.
[*]   [b]A Native Microstructure Footprint & Market Structure Levels (MSL) Engine[/b] to verify institutional liquidity zones, Value Areas (VA), and POC locations.
[*]   [b]An Advanced Rotational Market State (RCM) Conviction Engine[/b] that continuously calculates structural trend integrity and damage.
[/list]

[b]DEEP MATHEMATICAL ARCHITECTURE[/b]

[b]A. Shift-Invariant Stationary Wavelet Transform (SWT)[/b]
Traditional digital moving averages (EMA, SMA, HMA) introduce significant phase lag. [b]⟡ CSC[/b] bypasses this limitation using a discrete [b]Stationary Wavelet Transform (SWT)[/b], which decomposes price into a series of time-localized frequency sub-bands:

[pine]f(t) = a_J(t) + \sum_{j=1}^{J} d_j(t)[/pine]

Where [b]a_J[/b] represents the low-frequency approximation of the trend, and [b]d_j[/b] represents the high-frequency detail bands at scale [b]j[/b]. 
   [b]Smoothing Splitting[/b]: To preserve high-frequency market shocks, an Exponential Moving Average (EMA) is applied [b]only[/b] to the approximation bands ([b]a_1–a_4[/b]). The detail bands ([b]d_1–d_4[/b]) remain completely unsmoothed. This mathematical partition ensures that while trend tracking is smoothed, raw energy and volatility spikes are captured with zero time delay.
   [b]Regime Classification via Hurst Exponent (H)[/b]: The script extracts log-scale variations across multiple wavelet steps to estimate the Hurst Exponent. If [b]H > 0.55[/b], the market state is classified as [b]Trending[/b] (persistent). If [b]H < 0.45[/b], it is classified as [b]Mean Reverting[/b] (anti-persistent). Otherwise, it is flagged as [b]Random[/b] (Gaussian noise).

[b]B. 13-Feature Non-Euclidean Lorentzian k-NN Classification[/b]
Standard machine learning models often suffer from high-dimensional distortion. [b]⟡ CSC[/b] projects 13 distinct features (ranging from Hurst exponents and wavelet energy to order flow absorption and RCM integrity) into a non-Euclidean space. Rather than relying on simple Euclidean distances, it uses a [b]Lorentzian Cauchy-like Distance Metric[/b]:

[pine]d_{Lorentz}(x, y) = \sum_{i=1}^{N} \ln(1 + |x_i - y_i|^2)[/pine]

By using a logarithmic distance curve, the Lorentzian metric limits the influence of outlier data, preserving cluster relationships in high-dimensional spaces. 
   [b]Training Loop Protection (Outcome Delay)[/b]: To prevent lookahead bias, the k-NN engine implements a delayed-outcome training loop (lorentz_delay). The system waits for a user-defined bar window to pass before evaluating whether a historical pattern resolved as a win ([b]+1.0[/b]) or a loss ([b]-1.0[/b]). Only once this outcome is locked is the pattern committed to the database.

[b]C. LogicWeights Reinforcement Learning (RL) Engine[/b]
Rather than treating all pattern categories equally, [b]⟡ CSC[/b] deploys an adaptive reinforcement learning layer (`LW`). The system categorizes the 21 detectable patterns into four distinct buckets: [b]Original[/b], [b]Candle[/b], [b]Structure[/b], and [b]VSA[/b].
When an execution signal is generated, its category weight is adjusted based on subsequent price action:
   [b]Success (T1 Target Hit)[/b]: The category weight is increased by a learning step of [b]+0.04[/b].
   [b]Failure (Stop Loss Hit)[/b]: The category weight is reduced by [b]-0.04[/b].

This feedback loop ensures that the engine automatically prioritizes pattern types that are currently outperforming under active market conditions.

[b]INPUTS[/b]

[b]🌊 Wavelet Engine Parameters[/b]
   [b]Family[/b] (Default: db4): Selects the Mother Wavelet filter coefficients used to compute the SWT.
       [b]Haar:[/b] Step-like square wavelet. Highly responsive to sudden structural shocks, though prone to jagged bands.
       [b]db2 / db4:[/b] Orthogonal Daubechies wavelets. Balances time-domain precision and frequency-domain smoothing to preserve trend structures.
       [b]sym4:[/b] Near-symmetric Symlet wavelet designed to limit phase distortion and asymmetry.
       [b]coif2:[/b] Coiflet wavelet featuring vanishing moments for both scaling and wavelet functions. Highly localized approximation of micro-trends.
   [b]Approximation Smoothing[/b] (Default: 3): Applies an EMA filter to smooth approximation bands. Increasing this filters out short-term noise; decreasing it makes wavelet alignment signals more responsive to near-term momentum shifts.
   [b]Show Wavelet Bands[/b] (Default: true): Renders multi-scale volatility bands calculated directly from SWT detail-band energy coefficients on the chart.
   [b]Highlight Energy Surges[/b] (Default: false): Highlights the chart background when the combined square of the detail coefficients exceeds its historical average.

[b]🌌 Lorentzian Parameters[/b]
   [b]Enable Lorentzian[/b] (Default: true): Toggles the 13-feature non-Euclidean k-NN classification engine.
   [b]K Neighbors[/b] (Default: 5): Sets the number of historical nearest neighbors ([b]K[/b]) used to construct the prediction vector. Lower values (3-5) respond to localized anomalies; higher values (7-9) demand a broader historical consensus.
   [b]Gamma (match strictness)[/b] (Default: 1.0): The scale parameter ([b]\gamma[/b]) for the Cauchy-like distance kernel. Larger values accept broader historical matches; smaller values enforce strict similarity requirements.
   [b]Pattern Memory[/b] (Default: 180): Defines the maximum size of the historical feature database.
   [b]Outcome Delay (bars)[/b] (Default: 8): Enforces a strict temporal window before evaluating trade outcomes to prevent lookahead bias.
   [b]Min Confidence for Signal Boost[/b] (Default: 0.35): The minimum neighbor similarity percentage required to validate a k-NN signal boost.

[b]🎯 Patterns & Signal Quality Parameters[/b]
   [b]Original 8 Patterns[/b] (Default: true): Toggles the original 8 core patterns (Momentum, Flags, Reversals, Double Tops/Bottoms, Breakouts, Wavelet alignment, and Energy surges).
   [b]Candle Patterns (6)[/b] (Default: true): Toggles candlestick patterns (Hammer/Shooting Star Absorptions, Exhaustion Wicks, Pin Bars, Engulfing bars, Marubozus, and Dojis).
   [b]Structure Patterns (4)[/b] (Default: true): Toggles structural patterns (BOS, CHoCH, Liquidity Sweeps, and Order Block Reclaims).
   [b]VSA Patterns (3)[/b] (Default: true): Toggles Volume Spread Analysis patterns (No Demand, No Supply, Buying/Selling Climaxes, and Stopping Volume).
   [b]Minimum Signal Score (of 8)[/b] (Default: 6): Sets the minimum confirmation score required to validate an entry signal. The score is calculated across an 8-point validation matrix.
   [b]Signal Cooldown (bars)[/b] (Default: 12): Establishes a minimum bar interval between consecutive signals to prevent rapid, overlapping trades.
   [b]Require Structural Proximity[/b] (Default: true): When enabled, signals are blocked unless the entry price is trading near a key MSL level (POC, VAH, VAL, Siege Corridors, or major swing points).
   [b]Require RCM Integrity ≥ 50%[/b] (Default: true): Blocks signals if the RCM Engines structural integrity falls below 50%, filtering out signals during choppy, low-confidence trend transitions.

[b]🏗 Footprint Parameters[/b]
   [b]Use Native Footprint (Premium)[/b] (Default: true): Requests real-time, tick-level footprint data to calculate exact buying and selling volume distributions at each price level. If unavailable, the system automatically falls back to sub-timeframe volume distributions.
   [b]Ticks per Row[/b] (Default: 100): Set this to match the tick structure of your instrument.
   [b]Value Area %[/b] (Default: 70): Sets the statistical boundary of the Value Area.
   [b]Fallback TF1 / Fallback TF2[/b] (Default: 1 / 3): The primary and secondary sub-timeframes used to estimate sub-candle volume distributions when native footprint data is unavailable.

[b]🧭 MSL Structure Parameters[/b]
   [b]Enable MSL[/b] (Default: `true`): Toggles the Market Structure Levels engine.
   [b]Pivot Length[/b] (Default: 5): The lookback period used to identify swing highs and lows for structural calculations.
   [b]Plot POC/VAH/VAL[/b] (Default: `true`): Renders the POC, VAH, and VAL lines directly on the chart.

[b]🛡 RCM Parameters[/b]
   [b]Enable RCM[/b] (Default: `true`): Toggles the Rotational Market State Engine.
   [b]Wavelet → Impulse Injection[/b] (Default: 1.2): Adjusts the sensitivity of wavelet energy surges injected into the RCM engine.
   [b]Delta → Structure Injection[/b] (Default: 1.1): Adjusts the sensitivity of footprint delta imbalances injected into the RCM engine.
   [b]Siege → Compression Injection[/b] (Default: 1.0): Adjusts the sensitivity of MSL siege proximity metrics injected into the RCM engine.

[b]⚡ Risk Parameters[/b]
   [b]ATR Stop Multiplier[/b] (Default: 0.75): The multiplier applied to ATR to determine the initial stop-loss distance.
   [b]R:R Target 1 / R:R Target 2[/b] (Default: 1.0 / 2.0): The target prices for take-profit orders, calculated as a multiple of the initial risk distance.
   [b]Show Trade Lines[/b] (Default: `true`): Renders entry, stop-loss, and take-profit trade lines on the chart.

[b]DASHBOARD & CHART VISUALS[/b]

To help you monitor complex market environments, the system features a real-time Head-Up Display (HUD) and dynamic chart indicators:

[b]A. On-Chart Visuals[/b]
   [b]Neon Trade Lines[/b]: Renders entry ([b]Purple[/b]), stop-loss ([b]Crimson[/b]), and take-profit targets ([b]Neon Green[/b]) trade lines.

[image]https://www.tradingview.com/x/UJVc1a9u/[/image]

   [b]Pattern Boxes & Labels[/b]: Displays dashed boxes around pattern-triggering candles, accompanied by text badges showing the pattern name, category, and score.

[image]https://www.tradingview.com/x/wypxbwxP/[/image]

   [b]Signal Arrows[/b]: Displays [b]L[/b] (Long) or [b]S[/b] (Short) shapes indicating validated entry zones.

[image]https://www.tradingview.com/x/0uKu6pxe/[/image]

[b]B. Real-Time HUD Table Columns Explained[/b]
   [b]CORE Section[/b]:
       [b]Regime[/b]: Displays the active market state (Trending, Mean Reverting, or Random), along with the exact Hurst exponent value ([b]H[/b]).
       [b]Wavelet[/b]: Shows wavelet alignment (Bullish, Bearish, or Flat) and active scale.
       [b]Energy[/b]: Highlights active wavelet energy surges.
   [b]LORENTZIAN Section[/b]:
       [b]Prediction[/b]: Shows the k-NN models directional bias (Bullish, Bearish, or Neutral) and its numerical score.
       [b]Confidence[/b]: Displays a loading-bar visual of neighbor similarity.
   [b]RCM Section[/b]:
       [b]State[/b]: Displays active trend states (Bullish, Bearish, or Neutral) and highlights structural damage.
       [b]Integrity[/b]: Displays a trend strength bar indicator.
       [b]Impulse / Exhaust[/b]: Compares buy/sell volume conviction and exhaustion levels.
   [b]SIGNAL Section[/b]:
       [b]Pattern / Category / Score[/b]: Shows active pattern details and its validation status.
       [b]RL Weights[/b]: Displays active category weights ([b]O[/b]: Original, [b]C[/b]: Candle, [b]S[/b]: Structure, [b]V[/b]: VSA) updated by the reinforcement learning engine.
   [b]ACTIVE TRADE Section[/b]:
       Displays details of the active trade, including name, category, direction, and live unrealized profit/loss.
   [b]PERFORMANCE Section[/b]:
       [b]T1 / T2 Win Rate[/b]: Tracks performance at both Target 1 and Target 2, alongside a detailed breakdown of wins and losses by pattern category.
   [b]NARRATION Section[/b]:
       Provides live commentary on structural conditions, warning you of trend transitions or consolidation phases.
   [b]STRUCTURE Section[/b]:
       Displays current POC, VAH, and VAL values, indicating whether price is trading inside the Value Area or near structural siege zones.

[image]https://www.tradingview.com/x/R8mc153G/[/image]

[b]OPTIMIZATION FOR VARIOUS TIMEFRAMES & SECTORS[/b]

[b]A. 5-Minute Timeframe (Scalping & Order Flow Focus)[/b]
Designed to capture rapid, intraday price action and short-term liquidity pools:
   [b]Wavelet settings[/b]: Family = Haar (highest response rate to sudden price breaks), Approximation Smoothing = 2.
   [b]Lorentzian settings[/b]: K Neighbors = 3 (highly sensitive to localized historical patterns), Gamma = 0.8 (demands strict similarity matching), Outcome Delay = 5 (speeds up learning feedback).
   [b]Signal settings[/b]: Minimum Signal Score = 5 (increases trade frequency), Require Structural Proximity = true (ensures trades occur at high-probability location zones).
   [b]Asset pairings[/b]: Highly effective for high-volume stock index futures (NQ, ES), blue-chip equities (TSLA, NVDA), and liquid currency pairs (EUR/USD, GBP/USD).

[b]B. 10-Minute Timeframe (Intraday Day Trading)[/b]
Optimized to capture midday trends while filtering out noise and false breakouts:
   [b]Wavelet settings[/b]: Family = db2 or db4, Approximation Smoothing = 4.
   [b]Lorentzian settings[/b]: K Neighbors = 5, Gamma = 1.1, Outcome Delay = 8.
   [b]Signal settings[/b]: Minimum Signal Score = 6, Require RCM Integrity ≥ 50% = true (filters out choppy consolidation ranges).
   [b]Asset pairings[/b]: Recommended for major commodity futures (Gold, Crude Oil) and high-market-cap cryptocurrency assets (BTC/USD, ETH/USD).

[b]C. 1-Hour Timeframe (Swing Trading & Structural Position Trading)[/b]
Designed for capturing major macroeconomic trends and holding swing positions over days or weeks:
   [b]Wavelet settings[/b]: Family = sym4 or coif2 (reduces phase distortion), Approximation Smoothing = 6.
   [b]Lorentzian settings[/b]: K Neighbors = 7 or 9 (demands broad historical consensus), Gamma = 1.5, Outcome Delay = 12 or 15.
   [b]Signal settings[/b]: Minimum Signal Score = 7 (demands high confluence), Require Structural Proximity = true (requires price to be near major daily or weekly key levels).
   [b]Asset pairings[/b]: Ideal for spot forex pairs, commodity CFDs, global treasury bonds, and mid-cap equity portfolios.

[b]* These are generalized suggestions. The main suggestion would be to play with the inputs until you find something you are comfortable with.[/b]

[b]WEBHOOK & LIVE EXECUTION INTEGRATION BLUEPRINT[/b]

Because [b]⟡ CSC[/b] is an overlay [b]indicator[/b] rather than a strategy, it utilizes specialized Pine Script [b]`alertcondition`[/b] triggers. To bridge these signals to external brokers, prop accounts, or trade routers (such as PineConnector, 3Commas, or Capitalise.ai), you must use TradingViews dynamic placeholder tokens to pass real-time order data through your webhooks.

[b]A. Available Indicator Alert Triggers[/b]
The script features four automated alert conditions that you can select in the TradingView alert creation menu:
[list=1]
[*][b]CSC Long Signal[/b] (Triggered on validated long patterns meeting all score and filter gates).
[*][b]CSC Short Signal[/b] (Triggered on validated short patterns meeting all score and filter gates).
[*][b]RCM Damage[/b] (Alerts you when structural integrity is compromised).
[*][b]Energy Surge[/b] (Alerts you when wavelet energy expands, signaling an upcoming volatility breakout).
[/list]

[b]B. Dynamic JSON Webhook Templates[/b]
By using TradingView’s [b]Placeholder Tokens[/b] in the Alert Message box, you can pass dynamic execution data to your routing gateway:

[b]Template 1: PineConnector (MetaTrader 4 / MetaTrader 5 Bridge)[/b]
To route trades to MT4/MT5, configure your alert message exactly as follows:

[pine]{"license":"YOUR_PINECONNECTOR_ID", "action":"{{strategy.order.action}}", "symbol":"{{ticker}}", "risk":"1", "sl":"{{plot_0}}", "tp":"{{plot_1}}"}[/pine]

(Note: Replace (sl) and (tp) values with your preferred risk parameters or your brokers specific layout).

[b]Template 2: 3Commas Multi-Bot Trigger[/b]
To execute signals on spot or futures crypto exchange accounts, enter the following JSON format in your Alert Message box:

[pine]{
  "message_type": "bot",
  "bot_id": "12345678",
  "email_token": "your-unique-email-token-1234",
  "delay_seconds": 0,
  "pair": "{{exchange}}:{{ticker}}",
  "action": "trigger_signal"
}[/pine]


[b]Template 3: Universal Webhook JSON (For custom programmatic servers)[/b]
If you route signals to a custom API or private trading bot server, use this format to pass comprehensive market-state data:

[pine]{
  "strategy": "CSC_DAFE",
  "ticker": "{{ticker}}",
  "exchange": "{{exchange}}",
  "close": {{close}},
  "time": "{{timenow}}",
  "volume": {{volume}},
  "interval": "{{interval}}",
  "message": "{{alertstring}}"
}
[/pine]

[b]C. Setting Up Your Webhook in TradingView[/b]
[list=1]
[*]Open the [b]⟡ CSC[/b] indicator settings on your chart and calibrate your inputs.
[*]Click the [b]Alert[/b] icon on your TradingView menu.
[*]Set the [b]Condition[/b] to [b]Casual State Confirmation [DAFE][/b].
[*]Select the desired signal condition (e.g., [b]CSC Long Signal[/b] or [b]CSC Short Signal[/b]).
[*]Set the [b]Trigger Option[/b] to [b]Once Per Bar Close[/b] (highly recommended to preserve k-NN and machine learning logic).
[*]In the [b]Alert Actions[/b] tab, check [b]Webhook URL[/b] and paste your gateway’s API link.
[*]In the [b]Message[/b] box, paste one of the JSON templates shown above.
[*]Click [b]Create[/b].
[/list]

[b]PLATFORM COMPLIANCE & RISK DISCLAIMERS[/b]

   [b]No Guarantee of Financial Returns[/b]: This software tool is designed for educational and informational purposes only. It is not financial or investment advice. Systematic trading carries high risks of capital loss.
   [b]Hypothetical Backtesting Limitations[/b]: All performance statistics displayed in the HUD table are calculated in real time using historical data and are completely simulated. Simulated results have inherent limitations and do not represent live market transactions, brokerage fees, or execution slippage.
   [b]User Operational Responsibility[/b]: The user is solely responsible for determining position sizing, risk limits, and broker connections. [b]⟡ CSC[/b] is not a financial advisor. Always test Webhook JSON integrations in simulated paper-trading environments before risking live capital.

— Dskyz, Trade with insight. Trade with anticipation. (Don't follow the trend, be the trend)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DskyzInvestments — Dskyz (DAFE) Trading Systems
//@version=6
indicator("Casual State Confirmation [DAFE]", shorttitle="⟡ CSC", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=2000)
// ═══════════════════════════════════════════════════════════════════════════════
//
//     ██████╗███████╗ ██████╗
//    ██╔════╝██╔════╝██╔════╝
//    ██║     ███████╗██║     
//    ██║     ╚════██║██║     
//    ╚██████╗███████║╚██████╗
//     ╚═════╝╚══════╝ ╚═════╝
//
//    CASUAL STATE CONFIRMATION [DAFE]
//    ─────────────────────────────────────────────────
//    True cascaded SWT with 5 wavelet families (details intentionally unsmoothed)
//    13-feature Lorentzian k-NN with delayed-outcome learning on confirmed bars only
//    21 patterns across 4 categories with LogicWeights RL reinforcement learning
//    Native footprint + multi-TF MSL + full RCM conviction engine
//    Intrabar / tick-aware signal generation while preserving training integrity
//    "Confirm the state casually, trade with anticipation"
// ═══════════════════════════════════════════════════════════════════════════════
import DskyzInvestments/MarketStructureLib/1   as msl
import DskyzInvestments/DafeRCMLib/1           as rcm
import DskyzInvestments/DafeVisLib/1           as viz
// ═══════════════════════════════════════════════════════════════════════════════
//                                  INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
// ── 🌊 WAVELET ENGINE ─────────────────────────────────────────────────────────
string G_WAV = "🌊 Wavelet Engine"
string wavelet_type   = input.string("db4", "Family", options=["Haar", "db2", "db4", "sym4", "coif2"], group=G_WAV, tooltip= "Determines the Mother Wavelet filter coefficients used to compute the Stationary Wavelet Transform (SWT).\n\n" + "Wavelet analysis decomposes non-stationary price data into distinct scales of time and frequency without the phase-lag penalty of standard digital filters.\n\n" + "• Haar: Built on discontinuous step-like square functions. This is the most responsive wavelet, ideal for catching sharp trend breaks and immediate structural shocks, though it is prone to producing jagged bands.\n\n" + "• Daubechies 2 (db2) / Daubechies 4 (db4): Orthogonal wavelets with 2 and 4 vanishing moments, respectively. These filters strike an optimal balance between time-domain accuracy and frequency-domain smoothing, preserving trend structure while cleanly isolating localized noise.\n\n" + "• Symlet 4 (sym4): A near-symmetric variation of the Daubechies family designed to limit phase distortion and asymmetry, preserving signal wave-structures.\n\n" + "• Coiflet 2 (coif2): Designed with vanishing moments for both scaling and wavelet functions, offering highly localized approximations of noise and micro-trends.")
int    wavelet_smooth = input.int(3, "Approximation Smoothing", minval=1, maxval=12, group=G_WAV, tooltip= "Applies an Exponential Moving Average (EMA) to smooth the SWT approximation bands (a1–a4).\n\n" + "Importantly, this setting does *not* smooth the detail bands (d1–d4). This math design ensures that while trend tracking is smoothed, raw energy and volatility surges remain unsmoothed, preventing the delay of high-frequency market shocks.\n\n" + "Increase this parameter to filter out noise in trend direction; decrease it to make wavelet alignment signals highly responsive to near-term momentum shifts.")
bool   show_wavelets  = input.bool(true, "Show Wavelet Bands", group=G_WAV, tooltip= "Renders the dynamic wavelet bands on the chart.\n\n" + "These bands behave similarly to volatility bands but are calculated directly from SWT detail-band energy coefficients rather than standard deviation, providing a more precise visualization of multi-scale price compression.")
bool   show_energy_bg = input.bool(false, "Highlight Energy Surges", group=G_WAV, tooltip= "Enables background highlighting during wavelet energy surges.\n\n" + "An energy surge is triggered when the combined square of the detail coefficients ($d_1^2 + d_2^2 + d_3^2 + d_4^2$) exceeds its historical average. This highlights structural breakouts and institutional expansion phases.")
// ── 🌌 LORENTZIAN ─────────────────────────────────────────────────────────────
string G_LOR = "🌌 Lorentzian"
bool   use_lorentzian = input.bool(true, "Enable Lorentzian", group=G_LOR, tooltip= "Activates the 13-feature Lorentzian k-Nearest Neighbors (k-NN) classification engine.\n\n" + "This engine maps multi-resolution features into a non-Euclidean Lorentzian space, which uses a Cauchy-like distance metric to reduce the curse of dimensionality and improve pattern classification in high-dimensional spaces.")
int    lorentz_k      = input.int(5, "K Neighbors", minval=3, maxval=9, group=G_LOR, tooltip= "Sets the number of historical nearest neighbors ($K$) used to construct the classification vector.\n\n" + "Lower values (3-5) allow the engine to respond to localized anomalies and near-term structural shifts, while higher values (7-9) smooth out predictions, demanding a broader historical consensus.")
float  lorentz_gamma  = input.float(1.0, "Gamma (match strictness)", minval=0.3, maxval=3.0, group=G_LOR, tooltip= "The scale parameter ($\gamma$) for the Lorentzian Cauchy-like kernel.\n\n" + "Adjusting gamma controls the system's sensitivity to structural distances; larger values accept broader, less similar historical matches, while smaller values enforce strict similarity requirements.")
int    lorentz_memory = input.int(180, "Pattern Memory", minval=50, maxval=400, group=G_LOR, tooltip= "Defines the maximum size of the historical feature database used to evaluate current market patterns.\n\n" + "A larger memory size provides a broader catalog of market patterns but increases computational load, while smaller memory sizes prioritize recent market behavior.")
int    lorentz_delay  = input.int(8, "Outcome Delay (bars)", minval=5, maxval=20, group=G_LOR, tooltip= "Enforces a strict delayed-outcome training loop.\n\n" + "The k-NN engine waits for this specified bar window to pass before evaluating whether an entry resolved as a win or loss. This prevents lookahead bias and ensures the engine learns from realized trend outcomes.")
float  lorentz_min_conf = input.float(0.35, "Min Confidence for Signal Boost", minval=0.0, maxval=0.9, group=G_LOR, tooltip= "The minimum neighbor similarity percentage required to validate a k-NN signal boost.\n\n" + "If the average distance between neighbors falls below this threshold, the classification is flagged as weak, preventing low-confidence setups from triggering signals.")
// ── 🎯 PATTERNS & SIGNAL QUALITY ──────────────────────────────────────────────
string G_PAT = "🎯 Patterns & Signal Quality"
bool   enable_original   = input.bool(true, "Original 8 Patterns", group=G_PAT, tooltip= "Toggles the original 8 core patterns (Momentum, Flags, Reversals, Double Tops/Bottoms, Breakouts, Wavelet alignment, and Energy surges).\n\n" + "Disable this parameter if you prefer to isolate execution signals to candlestick structures, volume spread analysis, or liquidity sweeps.")
bool   enable_candle     = input.bool(true, "Candle Patterns (6)", group=G_PAT, tooltip= "Toggles candlestick patterns (Hammer/Shooting Star Absorptions, Exhaustion Wicks, Pin Bars, Engulfing bars, Marubozus, and Dojis).\n\n" + "Disabling this ignores candlestick-specific volume and wick geometries, focusing the engine entirely on structural and mathematical features.")
bool   enable_structure  = input.bool(true, "Structure Patterns (4)", group=G_PAT, tooltip= "Toggles structural patterns (Breaks of Structure (BOS), Changes of Character (CHoCH), Liquidity Sweeps, and Order Block Reclaims).\n\n" + "Keep this enabled to align signals with high-probability market structure levels.")
bool   enable_vsa        = input.bool(true, "VSA Patterns (3)", group=G_PAT, tooltip= "Toggles Volume Spread Analysis (VSA) patterns (No Demand, No Supply, Buying/Selling Climaxes, and Stopping Volume).\n\n" + "VSA matches volume expansions and contractions with spread range to identify institutional accumulation and distribution phases.")
int    min_score         = input.int(6, "Minimum Signal Score (of 8)", minval=3, maxval=8, group=G_PAT, tooltip= "Sets the minimum confirmation score required to validate an entry signal.\n\n" + "The score is calculated across an 8-point matrix (evaluating trend alignment, momentum direction, volume expansion, k-NN prediction, RCM trend direction, MSL proximity, footprint delta, and MACD alignment).\n\n" + "A setting of 6 or 7 filters out weak signals, while a setting of 3 or 4 allows for more aggressive execution in highly active markets.")
int    signal_cooldown   = input.int(12, "Signal Cooldown (bars)", minval=3, maxval=60, group=G_PAT, tooltip= "The minimum number of bars that must pass before the system can generate another signal.\n\n" + "This temporal filter prevents the execution of rapid, overlapping trades during high-volatility, range-bound environments.")
bool   require_structure = input.bool(true, "Require Structural Proximity", group=G_PAT, tooltip= "When enabled, signals are blocked unless the entry price is trading near a key MSL level (POC, VAH, VAL, Siege Corridors, or major swing points) [1].\n\n" + "Enforcing structural proximity helps ensure trades are executed at high-probability location zones [1].")
bool   require_rcm_ok    = input.bool(true, "Require RCM Integrity ≥ 50%", group=G_PAT, tooltip= "Blocks signals if the RCM Engine's structural integrity falls below 50%.\n\n" + "Low integrity indicates a trend transition or choppy, rotational market state. Enabling this filter helps protect capital from whipsaws during low-confidence market phases.")
// ── 🏗 FOOTPRINT ──────────────────────────────────────────────────────────────
string G_FP = "🏗 Footprint"
bool   use_footprint = input.bool(true, "Use Native Footprint (Premium)", group=G_FP, tooltip= "When active, the system requests real-time, tick-level footprint data to calculate exact buying and selling volume distributions at each price level [1].\n\n" + "If disabled or unavailable, the system falls back to estimated footprint values calculated from sub-timeframe volume distributions.")
int    fp_ticks      = input.int(100, "Ticks per Row", minval=1, group=G_FP, tooltip= "Defines the vertical price aggregation size (in minimum price ticks) for each footprint profile row.\n\n" + "Adjust this parameter based on the asset's tick scale to ensure volume profiles remain readable and well-distributed.")
int    fp_va_pct     = input.int(70, "Value Area %", minval=50, maxval=95, group=G_FP, tooltip= "The percentage of total footprint volume to include in the Value Area (VA) calculation.\n\n" + "The Value Area represents the price range where the bulk of trading activity took place. A default of 70% aligns with standard statistical value area models [1].")
string fp_estTF1     = input.timeframe("1", "Fallback TF1", group=G_FP, tooltip= "The primary sub-timeframe used to estimate sub-candle volume distributions when native footprint data is unavailable.\n\n" + "Shorter timeframes (e.g., 1-minute or tick charts) provide more precise volume distribution estimates.")
string fp_estTF2     = input.timeframe("3", "Fallback TF2", group=G_FP, tooltip= "The secondary sub-timeframe used to estimate sub-candle volume distributions when native footprint data is unavailable.\n\n" + "This is paired with Fallback TF1 to provide a more stable, multi-resolution volume estimate.")
// ── 🧭 MSL STRUCTURE ──────────────────────────────────────────────────────────
string G_MSL = "🧭 MSL Structure"
bool   use_msl        = input.bool(true, "Enable MSL", group=G_MSL, tooltip= "Enables the Market Structure Levels (MSL) engine to identify high-volume levels, Value Areas, and key support/resistance corridors [1].")
int    msl_pivot_len  = input.int(5, "Pivot Length", minval=2, maxval=15, group=G_MSL, tooltip= "The lookback period used to identify swing highs and lows for structural level calculations.\n\n" + "Shorter lengths detect near-term structural points, while longer periods focus the engine on major, high-timeframe swing levels.")
bool   msl_show_levels = input.bool(true, "Plot POC/VAH/VAL", group=G_MSL, tooltip= "Renders the Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL) levels directly on the chart [1].")
// ── 🛡 RCM CONVICTION ─────────────────────────────────────────────────────────
string G_RCM = "🛡 RCM"
bool   use_rcm       = input.bool(true, "Enable RCM", group=G_RCM, tooltip= "Enables the Rotational Market State Engine (RCM) to calculate net bullish or bearish momentum, consolidations, and structural trend damage.")
float  rcm_inj_wav   = input.float(1.2, "Wavelet → Impulse Injection", minval=0.0, maxval=3.0, group=G_RCM, tooltip= "Adjusts the sensitivity of wavelet energy surges injected into the RCM engine.\n\n" + "Higher values cause wavelet expansion surges to have a larger impact on the RCM impulse calculations.")
float  rcm_inj_del   = input.float(1.1, "Delta → Structure Injection", minval=0.0, maxval=3.0, group=G_RCM, tooltip= "Adjusts the sensitivity of footprint delta imbalances injected into the RCM engine.\n\n" + "Higher values cause order flow imbalances to have a larger impact on the RCM trend calculations.")
float  rcm_inj_sie   = input.float(1.0, "Siege → Compression Injection", minval=0.0, maxval=3.0, group=G_RCM, tooltip= "Adjusts the sensitivity of MSL siege proximity metrics injected into the RCM engine.\n\n" + "Higher values cause proximity to key support/resistance zones to have a larger impact on the RCM compression calculations.")
// ── ⚡ RISK ────────────────────────────────────────────────────────────────────
string G_RSK = "⚡ Risk"
float  atr_stop   = input.float(0.75, "ATR Stop Multiplier", minval=0.1, maxval=3.0, step=0.1, group=G_RSK, tooltip= "The multiplier applied to ATR to determine the initial stop-loss distance.\n\n" + "For example, a setting of 0.75 sets the stop-loss distance to 0.75 times the ATR.")
float  rr1        = input.float(1.0, "R:R Target 1", minval=0.5, maxval=3.0, step=0.1, group=G_RSK, tooltip= "The target price for the first take-profit order, calculated as a multiple of the initial risk distance.")
float  rr2        = input.float(2.0, "R:R Target 2", minval=1.0, maxval=5.0, step=0.1, group=G_RSK, tooltip= "The target price for the second take-profit order, calculated as a multiple of the initial risk distance.")
bool   show_trades = input.bool(true, "Show Trade Lines", group=G_RSK, tooltip= "Renders entry, stop-loss, and take-profit trade lines directly on the chart.")
// ── 🎨 DISPLAY ────────────────────────────────────────────────────────────────
string G_VIS = "🎨 Display"
bool   show_signals   = input.bool(true, "Show Signal Arrows", group=G_VIS, tooltip= "Renders buy and sell signal arrows on the chart.")
bool   show_patterns  = input.bool(true, "Show Detected Pattern Labels", group=G_VIS, tooltip= "Renders labels above or below the signal bars to show the names of the detected patterns.")
bool   show_dashboard = input.bool(true, "Show Dashboard", group=G_VIS, tooltip= "Toggles the display of the system dashboard HUD on the chart.")
string theme_name     = input.string("DAFE Signature", "Theme", options=["DAFE Signature", "Cyber Neon", "Ocean Depths"], group=G_VIS, tooltip= "Selects the color palette used for chart drawings and dashboard elements.")
string dash_pos       = input.string("TopRight", "Dashboard Position", options=["TopRight", "TopLeft", "BottomRight", "BottomLeft"], group=G_VIS, tooltip= "Determines the corner of the chart where the system dashboard will be displayed.")
int    pat_box_history = input.int(12, "Pattern Box History", minval=4, maxval=30, group=G_VIS, tooltip= "The maximum number of recent patterns retained on the chart.\n\n" + "Old patterns are automatically removed to keep the chart clean and readable.")
// ═══════════════════════════════════════════════════════════════════════════════
//                             THEME & CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

color bullColor = theme_name == "Cyber Neon"     ? #00FFAA : theme_name == "Ocean Depths"   ? #00FF99 : #00FF88
color bearColor = theme_name == "Cyber Neon"     ? #FF0055 : theme_name == "Ocean Depths"   ? #FF6666 : #FF0066
color neuColor  = theme_name == "Cyber Neon"     ? #8866AA : theme_name == "Ocean Depths"   ? #558888 : #8899AA
color accent    = theme_name == "Cyber Neon"     ? #FF00FF : theme_name == "Ocean Depths"   ? #00FFCC : #AA00FF
color accent2   = theme_name == "Cyber Neon"     ? #00DDFF : theme_name == "Ocean Depths"   ? #00CED1 : #00CCFF
color txtHi     = #FFFFFF
color txtLo     = theme_name == "Cyber Neon"     ? #8866AA : theme_name == "Ocean Depths"   ? #558888 : #667788
color dashBg     = color.new(#0A0A14, 5)
color dashBgCell = color.new(#0A0A14, 12)
color dashBorder = color.new(accent, 65)
color hdrBg      = color.new(#0D001A, 5)
color wavColor   = accent2
const float EPS = 1e-10
// ═══════════════════════════════════════════════════════════════════════════════
//                        CORE TA — GLOBAL SCOPE
// ═══════════════════════════════════════════════════════════════════════════════
float atr14 = ta.atr(14)
float atr20 = ta.atr(20)
float rsi14 = ta.rsi(close, 14)
[macdLine, sigLine, histLine] = ta.macd(close, 12, 26, 9)
float vol_sma20 = ta.sma(volume, 20)
float vol_sma50 = ta.sma(volume, 50)
float sma_20  = ta.sma(close, 20)
float sma_50  = ta.sma(close, 50)
float sma_200 = ta.sma(close, 200)
float high_10 = ta.highest(high, 10)
float low_10  = ta.lowest(low, 10)
float high_20 = ta.highest(high, 20)
float low_20  = ta.lowest(low, 20)
float high_40 = ta.highest(high, 40)
float low_40  = ta.lowest(low, 40)
float range_20 = high_20 - low_20
float range_40 = high_40 - low_40
float ph = ta.pivothigh(high, msl_pivot_len, msl_pivot_len)
float pl = ta.pivotlow(low,   msl_pivot_len, msl_pivot_len)
var float swingHi = na
var float swingLo = na
var float swingHiPrev = na
var float swingLoPrev = na
if not na(ph)
    swingHiPrev := swingHi
    swingHi := ph
if not na(pl)
    swingLoPrev := swingLo
    swingLo := pl
float atr_ratio = atr20 > 0 ? atr14 / atr20 : 1.0
float dvs = math.max(0.5, math.min(2.0, atr_ratio))
float bar_body  = math.abs(close - open)
float bar_range = high - low
float upper_wick = high - math.max(close, open)
float lower_wick = math.min(close, open) - low
float body_pct   = bar_range > 0 ? bar_body / bar_range : 0
// ═══════════════════════════════════════════════════════════════════════════════
//        TRUE DWT — 5 FAMILIES, DETAILS UNSMOOTHED 
// ═══════════════════════════════════════════════════════════════════════════════
type WaveletFilters
    array<float> lo
    array<float> hi
get_filters(string family) =>
    array<float> lo = array.new<float>()
    array<float> hi = array.new<float>()
    if family == "Haar"
        array.push(lo, 0.7071067811865476)
        array.push(lo, 0.7071067811865476)
        array.push(hi, 0.7071067811865476)
        array.push(hi, -0.7071067811865476)
    else if family == "db2"
        array.push(lo, 0.4829629131445341)
        array.push(lo, 0.8365163037378079)
        array.push(lo, 0.2241438680420134)
        array.push(lo, -0.1294095225512604)
        array.push(hi, -0.1294095225512604)
        array.push(hi, -0.2241438680420134)
        array.push(hi, 0.8365163037378079)
        array.push(hi, -0.4829629131445341)
    else if family == "db4"
        array.push(lo, 0.4829629131445341)
        array.push(lo, 0.8365163037378079)
        array.push(lo, 0.2241438680420134)
        array.push(lo, -0.1294095225512604)
        array.push(lo, -0.100106438739552)
        array.push(lo, 0.0322448695850297)
        array.push(lo, 0.0673725547222824)
        array.push(lo, -0.021635608011925)
        array.push(hi, 0.021635608011925)
        array.push(hi, 0.0673725547222824)
        array.push(hi, -0.0322448695850297)
        array.push(hi, -0.100106438739552)
        array.push(hi, -0.1294095225512604)
        array.push(hi, 0.2241438680420134)
        array.push(hi, 0.8365163037378079)
        array.push(hi, -0.4829629131445341)
    else if family == "sym4"
        array.push(lo, -0.0757657147893407)
        array.push(lo, -0.0296355276459541)
        array.push(lo, 0.497618667632457)
        array.push(lo, 0.803738751805916)
        array.push(lo, 0.297857795605542)
        array.push(lo, -0.0992195435769354)
        array.push(lo, -0.0126039672622612)
        array.push(lo, 0.0322231006040713)
        array.push(hi, -0.0322231006040713)
        array.push(hi, -0.0126039672622612)
        array.push(hi, 0.0992195435769354)
        array.push(hi, 0.297857795605542)
        array.push(hi, -0.803738751805916)
        array.push(hi, 0.497618667632457)
        array.push(hi, 0.0296355276459541)
        array.push(hi, -0.0757657147893407)
    else
        array.push(lo, -0.0727326195128539)
        array.push(lo, 0.337897670951159)
        array.push(lo, 0.852572041642390)
        array.push(lo, 0.384864846864203)
        array.push(lo, -0.0727326195128539)
        array.push(lo, -0.0156557281354645)
        array.push(hi, 0.0156557281354645)
        array.push(hi, -0.0727326195128539)
        array.push(hi, -0.384864846864203)
        array.push(hi, 0.852572041642390)
        array.push(hi, -0.337897670951159)
        array.push(hi, -0.0727326195128539)
    WaveletFilters.new(lo, hi)
WaveletFilters wf = get_filters(wavelet_type)
swt(float src, int level) =>
    int step = int(math.pow(2, level - 1))
    float a = 0.0
    float d = 0.0
    int len = array.size(wf.lo)
    for i = 0 to len - 1
        a += array.get(wf.lo, i) * nz(src[i * step])
        d += array.get(wf.hi, i) * nz(src[i * step])
    [a, d]
[a1r, d1r] = swt(close, 1)
[a2r, d2r] = swt(a1r,   2)
[a3r, d3r] = swt(a2r,   3)
[a4r, d4r] = swt(a3r,   4)
float a1 = ta.ema(a1r, wavelet_smooth)
float a2 = ta.ema(a2r, wavelet_smooth * 2)
float a3 = ta.ema(a3r, wavelet_smooth * 3)
float a4 = ta.ema(a4r, wavelet_smooth * 4)
float d1 = d1r
float d2 = d2r
float d3 = d3r
float d4 = d4r
float e1 = math.pow(d1 / math.max(atr14, EPS), 2)
float e2 = math.pow(d2 / math.max(atr14, EPS), 2)
float e3 = math.pow(d3 / math.max(atr14, EPS), 2)
float e4 = math.pow(d4 / math.max(atr14, EPS), 2)
float total_e = e1 + e2 + e3 + e4
float e_sma20 = ta.sma(total_e, 20)
int dom_scale = e1 > e2 and e1 > e3 and e1 > e4 ? 1 : e2 > e3 and e2 > e4 ? 2 : e3 > e4 ? 3 : 4
int wav_align = (a1 > a2 and a2 > a3 and a3 > a4) ? 1 : (a1 < a2 and a2 < a3 and a3 < a4) ? -1 : 0
float wav_strength = (a1 - a1[1]) / atr14 + 2 * (a2 - a2[2]) / atr14 + 4 * (a3 - a3[4]) / atr14 + 8 * (a4 - a4[8]) / atr14
bool energy_surge = total_e > e_sma20 * 1.55
float d8  = math.abs(a2 - a2[8])
float d16 = math.abs(a2 - a2[16])
float d32 = math.abs(a2 - a2[32])
float d64 = math.abs(a2 - a2[64])
float ls8  = math.log(8)
float ls16 = math.log(16)
float ls32 = math.log(32)
float ls64 = math.log(64)
float ld8  = d8  > 0 ? math.log(d8)  : math.log(EPS)
float ld16 = d16 > 0 ? math.log(d16) : math.log(EPS)
float ld32 = d32 > 0 ? math.log(d32) : math.log(EPS)
float ld64 = d64 > 0 ? math.log(d64) : math.log(EPS)
float sum_x  = ls8 + ls16 + ls32 + ls64
float sum_y  = ld8 + ld16 + ld32 + ld64
float sum_xx = ls8*ls8 + ls16*ls16 + ls32*ls32 + ls64*ls64
float sum_xy = ls8*ld8 + ls16*ld16 + ls32*ld32 + ls64*ld64
float denom  = 4 * sum_xx - sum_x * sum_x
float hurst  = denom != 0 ? math.max(0.0, math.min(1.0, (4 * sum_xy - sum_x * sum_y) / denom)) : 0.5
string regime = hurst > 0.55 ? "Trending" : hurst < 0.45 ? "Mean Revert" : "Random"
// ═══════════════════════════════════════════════════════════════════════════════
//                         FOOTPRINT + FALLBACK
// ═══════════════════════════════════════════════════════════════════════════════
f_est_delta() =>
    float bp = (close - low) / math.max(high - low, EPS)
    float bv = volume * bp
    float sv = volume * (1.0 - bp)
    bv - sv
float est_tf1 = request.security(syminfo.tickerid, fp_estTF1, f_est_delta(), lookahead=barmerge.lookahead_off)
float est_tf2 = request.security(syminfo.tickerid, fp_estTF2, f_est_delta(), lookahead=barmerge.lookahead_off)
float estDelta = nz(est_tf1) * 0.6 + nz(est_tf2) * 0.4
footprint reqFP = use_footprint ? request.footprint(fp_ticks, fp_va_pct) : na
bool hasFP = use_footprint and not na(reqFP)
var float fp_delta = 0.0
var float fp_pocMid = na
var float fp_vahUpper = na
var float fp_valLower = na
var float fp_buyV = 0.0
var float fp_sellV = 0.0
var float fp_absorb = 0.0
if hasFP
    fp_buyV  := reqFP.buy_volume()
    fp_sellV := reqFP.sell_volume()
    fp_delta := reqFP.delta()
    volume_row vahRow = reqFP.vah()
    volume_row valRow = reqFP.val()
    volume_row pocRow = reqFP.poc()
    fp_vahUpper := vahRow.up_price()
    fp_valLower := valRow.down_price()
    fp_pocMid := (pocRow.up_price() + pocRow.down_price()) / 2.0
    float totalV = fp_buyV + fp_sellV
    float dr = totalV > 0 ? fp_delta / totalV : 0.0
    bool deltaOpposes = (close > open and fp_delta < 0) or (close < open and fp_delta > 0)
    fp_absorb := deltaOpposes ? math.abs(dr) : 0.0
float netDelta = hasFP ? fp_delta : estDelta
float netVol   = hasFP ? (fp_buyV + fp_sellV) : volume
float deltaRatio = netVol > 0 ? netDelta / netVol : 0.0
float dr_avg = ta.sma(math.abs(deltaRatio), 20)
bool delta_spike = math.abs(deltaRatio) > dr_avg * 1.5 and math.abs(deltaRatio) > 0.2
float poc_dist = not na(fp_pocMid) and atr14 > 0 ? (close - fp_pocMid) / atr14 : 0.0
float va_pos   = not na(fp_vahUpper) and not na(fp_valLower) and (fp_vahUpper - fp_valLower) > 0 ? (close - fp_valLower) / (fp_vahUpper - fp_valLower) - 0.5 : 0.0
// ═══════════════════════════════════════════════════════════════════════════════
//                             MSL INTEGRATION
// ═══════════════════════════════════════════════════════════════════════════════
var float prev_poc = na
msl.MarketContext mctx = msl.get_market_context(open, high, low, close, volume, hasFP ? reqFP : na, vol_sma20, prev_poc, atr14)
var array<float> sh_p = array.new_float()
var array<int>   sh_b = array.new_int()
var array<float> sl_p = array.new_float()
var array<int>   sl_b = array.new_int()
[msl_sh_p, msl_sh_b] = msl.detect_swing_high(msl_pivot_len)
[msl_sl_p, msl_sl_b] = msl.detect_swing_low(msl_pivot_len)
if not na(msl_sh_p)
    array.unshift(sh_p, msl_sh_p)
    array.unshift(sh_b, msl_sh_b)
    if array.size(sh_p) > 12
        array.pop(sh_p)
        array.pop(sh_b)
if not na(msl_sl_p)
    array.unshift(sl_p, msl_sl_p)
    array.unshift(sl_b, msl_sl_b)
    if array.size(sl_p) > 12
        array.pop(sl_p)
        array.pop(sl_b)
var array<float> lb_h = array.new_float()
var array<float> lb_l = array.new_float()
var array<float> lb_c = array.new_float()
var array<float> lb_v = array.new_float()
array.unshift(lb_h, high)
array.unshift(lb_l, low)
array.unshift(lb_c, close)
array.unshift(lb_v, volume)
if array.size(lb_h) > 60
    array.pop(lb_h)
    array.pop(lb_l)
    array.pop(lb_c)
    array.pop(lb_v)
[poc_v, vah_v, val_v] = msl.calc_unified_poc_va(lb_h, lb_l, lb_c, lb_v, 24, hasFP ? reqFP : na)
prev_poc := hasFP and not na(fp_pocMid) ? fp_pocMid : nz(poc_v, prev_poc)
var msl.MultiTFStructure structure = msl.create_structure()
if use_msl
    structure.tf1 := msl.update_structure(structure.tf1, poc_v, vah_v, val_v, sh_p, sh_b, sl_p, sl_b, timeframe.period, atr14, mctx)
bool at_siege_res = use_msl ? msl.check_siege_proximity(close, structure.tf1.res_corridor, atr14) : false
bool at_siege_sup = use_msl ? msl.check_siege_proximity(close, structure.tf1.sup_corridor, atr14) : false
bool at_poc = use_msl and not na(poc_v) and math.abs(close - poc_v) <= atr14 * 1.0
bool at_vah = use_msl and not na(vah_v) and math.abs(close - vah_v) <= atr14 * 0.7
bool at_val = use_msl and not na(val_v) and math.abs(close - val_v) <= atr14 * 0.7
bool at_swing_hi = not na(swingHi) and math.abs(close - swingHi) <= atr14 * 1.0
bool at_swing_lo = not na(swingLo) and math.abs(close - swingLo) <= atr14 * 1.0
bool at_structure = at_siege_res or at_siege_sup or at_poc or at_vah or at_val or at_swing_hi or at_swing_lo
bool near_siege = at_siege_res or at_siege_sup
float msl_bias = at_siege_res ? -0.6 : at_siege_sup ? 0.6 : at_vah ? -0.4 : at_val ? 0.4 : not na(poc_v) and close > poc_v ?  0.2 : not na(poc_v) and close < poc_v ? -0.2 : 0.0
float siege_prox = near_siege ? 1.0 : 0.0
// ═══════════════════════════════════════════════════════════════════════════════
//                                  RCM
// ═══════════════════════════════════════════════════════════════════════════════
var rcm.RCMState  rcm_st  = rcm.RCMState.new()
var rcm.RCMConfig rcm_cfg = rcm.default_config()
if use_rcm
    rcm_st := rcm.update(rcm_st, rcm_cfg)
    if energy_surge and wav_align != 0
        float s = math.min(2.5, total_e / math.max(e_sma20, EPS) - 1.0) * rcm_inj_wav
        rcm.ExternalEvidence ev = rcm.ExternalEvidence.new(bullEvidence = wav_align > 0 ? s : 0.0, bearEvidence = wav_align < 0 ? s : 0.0, source = "wavelet")
        rcm_st := rcm.inject(rcm_st, ev)
    if delta_spike
        float s = math.min(2.5, math.abs(deltaRatio) * 2.0) * rcm_inj_del
        rcm.ExternalEvidence ev = rcm.ExternalEvidence.new(bullEvidence = deltaRatio > 0 ? s : 0.0, bearEvidence = deltaRatio < 0 ? s : 0.0, source = "footprint")
        rcm_st := rcm.inject(rcm_st, ev)
    if use_msl and near_siege and math.abs(msl_bias) > 0.1
        float s = siege_prox * rcm_inj_sie
        rcm.ExternalEvidence ev = rcm.ExternalEvidence.new(bullEvidence = msl_bias > 0 ? s : 0.0, bearEvidence = msl_bias < 0 ? s : 0.0, source = "msl_siege")
        rcm_st := rcm.inject(rcm_st, ev)
rcm.RCMPermissions rcm_perms = use_rcm ? rcm.get_permissions(rcm_st) : rcm.RCMPermissions.new()
bool  rcm_allow_long = rcm_perms.allowLong
bool  rcm_allow_short = rcm_perms.allowShort
int    rcm_code      = use_rcm ? rcm_st.state : 0
string rcm_regime    = rcm.get_regime(rcm_st)
float  rcm_integrity = use_rcm ? rcm_st.integrity : 1.0
int    rcm_sub_code  = use_rcm ? rcm_st.substate : 0
string rcm_substate  = rcm.substate_text(rcm_st)
bool rcm_bull_dmg = use_rcm ? rcm_st.bullDamaged : false
bool rcm_bear_dmg = use_rcm ? rcm_st.bearDamaged : false
bool rcm_damaged  = rcm_bull_dmg or rcm_bear_dmg
float rcm_imp_bu = use_rcm ? rcm_st.bullImpulse      : 0.0
float rcm_imp_be = use_rcm ? rcm_st.bearImpulse      : 0.0
float rcm_str_bu = use_rcm ? rcm_st.bullStructure    : 0.0
float rcm_str_be = use_rcm ? rcm_st.bearStructure    : 0.0
float rcm_exh_bu = use_rcm ? rcm_st.bullExhaustion   : 0.0
float rcm_exh_be = use_rcm ? rcm_st.bearExhaustion   : 0.0
float rcm_con_bu = use_rcm ? rcm_st.bullContinuation : 0.0
float rcm_con_be = use_rcm ? rcm_st.bearContinuation : 0.0
float rcm_cmp_bu = use_rcm ? rcm_st.bullCompression  : 0.0
float rcm_cmp_be = use_rcm ? rcm_st.bearCompression  : 0.0
float rcm_conviction = rcm_integrity * (rcm_damaged ? 0.5 : 1.0)
// ═══════════════════════════════════════════════════════════════════════════════
//     LORENTZIAN — 13 FEATURES, DELAYED OUTCOMES 
// ═══════════════════════════════════════════════════════════════════════════════
type Feature
    float rsi_n
    float vol_n
    float slope
    float hurst
    float volty
    float w_energy
    float w_align
    float macd_n
    float d_ratio
    float poc_d
    float va_p
    float absorb
    float rcm_int
    int   bi
type Mem
    array<Feature> feats
    array<float>   outc
    array<float>   entries  
    array<int>     bars    
type Neigh
    array<float> sims
    array<int> idxs
    int cap
var Mem mem = Mem.new(array.new<Feature>(), array.new<float>(), array.new<float>(), array.new<int>())
var Neigh nb = Neigh.new(array.new<float>(), array.new<int>(), lorentz_k)
adaptive_gamma() =>
    float volty = atr14 / math.max(close, EPS)
    float ef = total_e > e_sma20 ? 1.25 : 0.75
    float rf = regime == "Trending" ? 1.6 : regime == "Mean Revert" ? 0.65 : 1.0
    float rcmf = use_rcm ? (0.7 + rcm_conviction * 0.7) : 1.0
    lorentz_gamma * ef * rf * rcmf * (1.0 + volty * 2.2)
kern(Feature f1, Feature f2, float g) =>
    float sg = math.max(g, 0.001)
    float ds =
         math.pow(f1.rsi_n    - f2.rsi_n,    2) +
         math.pow(f1.vol_n    - f2.vol_n,    2) +
         math.pow(f1.slope    - f2.slope,    2) +
         math.pow(f1.hurst    - f2.hurst,    2) +
         math.pow(f1.volty    - f2.volty,    2) +
         math.pow(f1.w_energy - f2.w_energy, 2) * 0.5 +
         math.pow(f1.w_align  - f2.w_align,  2) * 0.5 +
         math.pow(f1.macd_n   - f2.macd_n,   2) +
         math.pow(f1.d_ratio  - f2.d_ratio,  2) * 1.5 +
         math.pow(f1.poc_d    - f2.poc_d,    2) +
         math.pow(f1.va_p     - f2.va_p,     2) * 0.8 +
         math.pow(f1.absorb   - f2.absorb,   2) * 1.2 +
         math.pow(f1.rcm_int  - f2.rcm_int,  2) * 0.7
    1.0 / (1.0 + ds / (sg * sg))
mk_feat() =>
    Feature f = Feature.new()
    f.rsi_n    := (rsi14 - 50) / 50
    f.vol_n    := vol_sma20 > 0 ? math.log(volume / vol_sma20 + 1) : 0
    f.slope    := wav_strength
    f.hurst    := (hurst - 0.5) * 2
    f.volty    := atr14 / math.max(close, EPS)
    f.w_energy := e_sma20 > 0 ? total_e / e_sma20 - 1 : 0
    f.w_align  := float(wav_align)
    f.macd_n   := atr14 > 0 ? macdLine / atr14 : 0
    f.d_ratio  := deltaRatio
    f.poc_d    := math.max(-3.0, math.min(3.0, poc_dist))
    f.va_p     := va_pos
    f.absorb   := fp_absorb
    f.rcm_int  := use_rcm ? rcm_integrity - 0.5 : 0.0
    f.bi       := bar_index
    f
ins(float s, int i) =>
    int n = array.size(nb.sims)
    if n < nb.cap
        bool done = false
        if n > 0
            for k = 0 to n - 1
                if s > array.get(nb.sims, k)
                    array.insert(nb.sims, k, s)
                    array.insert(nb.idxs, k, i)
                    done := true
                    break
        if not done
            array.push(nb.sims, s)
            array.push(nb.idxs, i)
    else if n > 0 and s > array.get(nb.sims, n - 1)
        array.pop(nb.sims)
        array.pop(nb.idxs)
        bool done = false
        if n > 1
            for k = 0 to n - 2
                if s > array.get(nb.sims, k)
                    array.insert(nb.sims, k, s)
                    array.insert(nb.idxs, k, i)
                    done := true
                    break
        if not done
            array.push(nb.sims, s)
            array.push(nb.idxs, i)
knn(Feature cf) =>
    array.clear(nb.sims)
    array.clear(nb.idxs)
    float g = adaptive_gamma()
    int ms = array.size(mem.feats)
    int look = math.min(ms, lorentz_memory)
    for i = ms - look to ms - 1
        if i >= 0 and i < ms
            Feature st = array.get(mem.feats, i)
            if i < array.size(mem.outc)
                float oc = array.get(mem.outc, i)
                if not na(oc)
                    float s = kern(cf, st, g)
                    if s > 0.28
                        ins(s, i)
predict() =>
    float pred = 0.0
    float conf = 0.0
    if use_lorentzian
        Feature cf = mk_feat()
        knn(cf)
        int nn = array.size(nb.idxs)
        if nn > 0
            float ws = 0.0
            float wt = 0.0
            for i = 0 to nn - 1
                int idx = array.get(nb.idxs, i)
                float sim = array.get(nb.sims, i)
                if idx < array.size(mem.outc)
                    float oc = array.get(mem.outc, idx)
                    ws += oc * sim
                    wt += sim
            pred := wt > 0 ? ws / wt : 0
            conf := nn > 0 ? array.avg(nb.sims) : 0
    [pred, conf]
store() =>
    if use_lorentzian and barstate.isconfirmed
        int sz = array.size(mem.bars)
        if sz > 0
            for i = sz - 1 to 0
                int pb = array.get(mem.bars, i)
                if bar_index - pb >= lorentz_delay and na(array.get(mem.outc, i))
                    float ep = array.get(mem.entries, i)
                    float fr = ep > 0 ? (close - ep) / ep : 0.0
                    float oc = fr > 0.002 ? 1.0 : fr < -0.002 ? -1.0 : 0.0
                    array.set(mem.outc, i, oc)
        Feature cf = mk_feat()
        array.push(mem.feats, cf)
        array.push(mem.outc, na)        
        array.push(mem.entries, close)    
        array.push(mem.bars, bar_index)   
        while array.size(mem.feats) > lorentz_memory
            array.shift(mem.feats)
            array.shift(mem.outc)
            array.shift(mem.entries)
            array.shift(mem.bars)
store()
[lor_pred, lor_conf] = predict()
int lor_mem_size = use_lorentzian ? array.size(mem.feats) : 0
// ═══════════════════════════════════════════════════════════════════════════════
//                      LOGIC WEIGHTS RL
// ═══════════════════════════════════════════════════════════════════════════════
type LW
    float w_orig
    float w_cdl
    float w_str
    float w_vsa
var LW lw = LW.new(1.0, 1.0, 1.0, 1.0)
// ═══════════════════════════════════════════════════════════════════════════════
//                8-POINT SIGNAL VALIDATION
// ═══════════════════════════════════════════════════════════════════════════════
validate(bool isBull, bool isCont) =>
    int s = 0
    if isCont
        if isBull ? close > sma_50 : close < sma_50
            s += 1
    else
        if isBull ? rsi14 < 40 : rsi14 > 60
            s += 1
    if isBull ? wav_strength > 0 : wav_strength < 0
        s += 1
    if volume > vol_sma20
        s += 1
    if use_lorentzian and lor_conf > lorentz_min_conf
        if isBull ? lor_pred > 0 : lor_pred < 0
            s += 1
    if use_rcm
        if (isBull and rcm_allow_long) or (not isBull and rcm_allow_short)
            s += 1
    if use_msl and at_structure
        s += 1
    if hasFP or true
        if isBull ? deltaRatio > 0.1 : deltaRatio < -0.1
            s += 1
    if isBull ? macdLine > sigLine : macdLine < sigLine
        s += 1
    s
int bull_cont = validate(true,  true)
int bear_cont = validate(false, true)
int bull_rev  = validate(true,  false)
int bear_rev  = validate(false, false)
// ═══════════════════════════════════════════════════════════════════════════════
//                              21 PATTERNS
// ═══════════════════════════════════════════════════════════════════════════════
float dvs_atr = atr14 * dvs
detect_orig() =>
    string n = "None"
    bool b = false
    int sc = 0
    if enable_original
        if close > close[1] and close[1] > close[2] and volume > vol_sma20
            n := "Bull Momentum"
            b := true
            sc := bull_cont
        else if close < close[1] and close[1] < close[2] and volume > vol_sma20
            n := "Bear Momentum"
            sc := bear_cont
        else if range_20 < range_40 * 0.7
            if close > sma_20 and close > open
                n := "Bull Flag"
                b := true
                sc := bull_cont
            else if close < sma_20 and close < open
                n := "Bear Flag"
                sc := bear_cont
        else if low <= low_20 and close > close[1]
            n := "Bull Reversal"
            b := true
            sc := bull_rev
        else if high >= high_20 and close < close[1]
            n := "Bear Reversal"
            sc := bear_rev
        else if math.abs(low - low[10]) < atr14 * 0.5 and close > close[5]
            n := "Double Bottom"
            b := true
            sc := bull_rev
        else if math.abs(high - high[10]) < atr14 * 0.5 and close < close[5]
            n := "Double Top"
            sc := bear_rev
        else if close > high_20[1] and volume > vol_sma20 * 1.2
            n := "Bull Breakout"
            b := true
            sc := bull_cont
        else if close < low_20[1] and volume > vol_sma20 * 1.2
            n := "Bear Breakdown"
            sc := bear_cont
        else if wav_align > 0 and close > a2
            n := "Wavelet Bull"
            b := true
            sc := bull_cont
        else if wav_align < 0 and close < a2
            n := "Wavelet Bear"
            sc := bear_cont
        else if total_e > e_sma20 * 1.5 and close > open
            n := "Energy Surge Bull"
            b := true
            sc := bull_cont
        else if total_e > e_sma20 * 1.5 and close < open
            n := "Energy Surge Bear"
            sc := bear_cont
    [n, b, sc]
detect_cdl() =>
    string n = "None"
    bool b = false
    int sc = 0
    if enable_candle
        bool ab_bull = body_pct < 0.35 and lower_wick > bar_body * 2 and volume > vol_sma20 * 1.3 and close > open
        bool ab_bear = body_pct < 0.35 and upper_wick > bar_body * 2 and volume > vol_sma20 * 1.3 and close < open
        if ab_bull
            n := "Absorption ↑"
            b := true
            sc := bull_rev
        else if ab_bear
            n := "Absorption ↓"
            sc := bear_rev
        else if upper_wick > bar_body * 3 and high >= high_20 and close < (high + low) / 2
            n := "Exhaustion Wick ↓"
            sc := bear_rev
        else if lower_wick > bar_body * 3 and low <= low_20 and close > (high + low) / 2
            n := "Exhaustion Wick ↑"
            b := true
            sc := bull_rev
        else if lower_wick > bar_body * 2 and upper_wick < bar_body * 0.5 and close > open
            n := "Pin Bar ↑"
            b := true
            sc := bull_rev
        else if upper_wick > bar_body * 2 and lower_wick < bar_body * 0.5 and close < open
            n := "Pin Bar ↓"
            sc := bear_rev
        else if close > open and close[1] < open[1] and close > open[1] and open < close[1] and bar_body > math.abs(close[1] - open[1])
            n := "Bull Engulf"
            b := true
            sc := bull_rev
        else if close < open and close[1] > open[1] and close < open[1] and open > close[1] and bar_body > math.abs(close[1] - open[1])
            n := "Bear Engulf"
            sc := bear_rev
        else if body_pct > 0.85 and bar_range > dvs_atr * 1.2 and close > open
            n := "Marubozu ↑"
            b := true
            sc := bull_cont
        else if body_pct > 0.85 and bar_range > dvs_atr * 1.2 and close < open
            n := "Marubozu ↓"
            sc := bear_cont
        else if body_pct < 0.15 and at_structure
            if close > close[5]
                n := "Doji@Res"
                sc := bear_rev
            else
                n := "Doji@Sup"
                b := true
                sc := bull_rev
    [n, b, sc]
detect_str() =>
    string n = "None"
    bool b = false
    int sc = 0
    if enable_structure
        bool bos_bu = not na(swingHi) and close > swingHi and close > close[1] and volume > vol_sma20
        bool bos_be = not na(swingLo) and close < swingLo and close < close[1] and volume > vol_sma20
        if bos_bu
            n := "BOS ↑"
            b := true
            sc := bull_cont
        else if bos_be
            n := "BOS ↓"
            sc := bear_cont
        else if not na(swingLo) and not na(swingHiPrev) and close < swingLo and swingHi < swingHiPrev
            n := "CHoCH ↓"
            sc := bear_rev
        else if not na(swingHi) and not na(swingLoPrev) and close > swingHi and swingLo > swingLoPrev
            n := "CHoCH ↑"
            b := true
            sc := bull_rev
        else if not na(swingHi) and high > swingHi and close < swingHi and close < open
            n := "Liq Sweep ↓"
            sc := bear_rev
        else if not na(swingLo) and low < swingLo and close > swingLo and close > open
            n := "Liq Sweep ↑"
            b := true
            sc := bull_rev
        else if use_msl and (at_val or at_siege_sup) and close > open and lower_wick > bar_body
            n := "OB Reclaim ↑"
            b := true
            sc := bull_rev
        else if use_msl and (at_vah or at_siege_res) and close < open and upper_wick > bar_body
            n := "OB Reclaim ↓"
            sc := bear_rev
    [n, b, sc]
detect_vsa() =>
    string n = "None"
    bool b = false
    int sc = 0
    if enable_vsa
        bool narrow = bar_range < dvs_atr * 0.7
        bool decl_v = volume < vol_sma20 * 0.7
        if narrow and decl_v and close > open and close < sma_20
            n := "No Demand"
            sc := bear_cont
        else if narrow and decl_v and close < open and close > sma_20
            n := "No Supply"
            b := true
            sc := bull_cont
        else if volume > vol_sma50 * 2.5 and close < (high + low) / 2 and high >= high_20
            n := "Buying Climax"
            sc := bear_rev
        else if volume > vol_sma50 * 2.5 and close > (high + low) / 2 and low <= low_20
            n := "Selling Climax"
            b := true
            sc := bull_rev
        else if volume > vol_sma20 * 1.8 and bar_range > dvs_atr * 1.5 and close < open and low <= low_10 and close > low + bar_range * 0.5
            n := "Stopping Vol ↑"
            b := true
            sc := bull_rev
        else if volume > vol_sma20 * 1.8 and bar_range > dvs_atr * 1.5 and close > open and high >= high_10 and close < high - bar_range * 0.5
            n := "Stopping Vol ↓"
            sc := bear_rev
    [n, b, sc]
[p_orig_n, p_orig_b, p_orig_s] = detect_orig()
[p_cdl_n,  p_cdl_b,  p_cdl_s]  = detect_cdl()
[p_str_n,  p_str_b,  p_str_s]  = detect_str()
[p_vsa_n,  p_vsa_b,  p_vsa_s]  = detect_vsa()
float w_orig = p_orig_n != "None" ? p_orig_s * lw.w_orig : 0
float w_cdl  = p_cdl_n  != "None" ? p_cdl_s  * lw.w_cdl  : 0
float w_str  = p_str_n  != "None" ? p_str_s  * lw.w_str  : 0
float w_vsa  = p_vsa_n  != "None" ? p_vsa_s  * lw.w_vsa  : 0
string pat_name = "None"
string pat_cat  = "None"
bool   pat_bull = false
int    pat_score = 0
float  best_w = math.max(math.max(w_orig, w_cdl), math.max(w_str, w_vsa))
if best_w > 0
    if w_orig == best_w
        pat_name := p_orig_n
        pat_cat  := "Original"
        pat_bull := p_orig_b
        pat_score := p_orig_s
    else if w_cdl == best_w
        pat_name := p_cdl_n
        pat_cat  := "Candle"
        pat_bull := p_cdl_b
        pat_score := p_cdl_s
    else if w_str == best_w
        pat_name := p_str_n
        pat_cat  := "Structure"
        pat_bull := p_str_b
        pat_score := p_str_s
    else
        pat_name := p_vsa_n
        pat_cat  := "VSA"
        pat_bull := p_vsa_b
        pat_score := p_vsa_s
// ═══════════════════════════════════════════════════════════════════════════════
//                SIGNAL GENERATION
// ═══════════════════════════════════════════════════════════════════════════════
var int last_sig_bar = -9999
bool quality_pass = pat_score >= min_score
bool cooldown_pass = bar_index - last_sig_bar >= signal_cooldown
bool structure_pass = not require_structure or at_structure
bool rcm_pass = not require_rcm_ok or (not use_rcm) or rcm_integrity >= 0.5
bool direction_pass = pat_bull ? rcm_allow_long : rcm_allow_short
bool generate = pat_name != "None" and quality_pass and cooldown_pass and structure_pass and rcm_pass and direction_pass and (barstate.isrealtime or barstate.isconfirmed)
if generate
    last_sig_bar := bar_index
float stop_dist = atr14 * atr_stop
float entry_p   = close
float stop_p    = pat_bull ? entry_p - stop_dist : entry_p + stop_dist
float t1_p      = pat_bull ? entry_p + stop_dist * rr1 : entry_p - stop_dist * rr1
float t2_p      = pat_bull ? entry_p + stop_dist * rr2 : entry_p - stop_dist * rr2
float size_cue = use_rcm ? math.max(0.25, math.min(1.5, rcm_conviction * 1.5)) : 1.0
// ═══════════════════════════════════════════════════════════════════════════════
//       TRADE LIFECYCLE ★ PERFORMANCE TRACKING ★ VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
var line  ln_e = na
var line  ln_s = na
var line  ln_t1 = na
var line  ln_t2 = na
var label lb_p = na
var label lb_info = na
var int   trade_start_bar = na
var float act_e = na
var float act_s = na
var float act_t1 = na
var float act_t2 = na
var bool  act_long = false
var string act_name = ""
var string act_cat = ""
var int t1_wins    = 0
var int t1_losses  = 0
var int t2_wins    = 0
var int t2_losses  = 0
var int totalTrades = 0
var bool t1_already = false 
type TradeResult
    string cat
    bool   won
    int    barIdx
var array<TradeResult> tradeHistory = array.new<TradeResult>()
if not na(act_e)
    bool resolved = false
    if act_long
        if not t1_already and high >= act_t1
            t1_already := true
            t1_wins += 1
        if high >= act_t2
            t2_wins += 1
            if not t1_already 
                t1_wins += 1
                t1_already := true
            resolved := true
        else if low <= act_s
            if not t1_already
                t1_losses += 1
            t2_losses += 1
            resolved := true
    else
        if not t1_already and low <= act_t1
            t1_already := true
            t1_wins += 1
        if low <= act_t2
            t2_wins += 1
            if not t1_already
                t1_wins += 1
                t1_already := true
            resolved := true
        else if high >= act_s
            if not t1_already
                t1_losses += 1
            t2_losses += 1
            resolved := true
    if resolved
        totalTrades += 1
        bool isWin = act_long ? high >= act_t1 : low <= act_t1  // T1 hit = win for RL
        float dw = isWin ? 0.04 : -0.04
        if act_cat == "Original"
            lw.w_orig := math.max(0.5, math.min(2.2, lw.w_orig + dw))
        else if act_cat == "Candle"
            lw.w_cdl := math.max(0.5, math.min(2.2, lw.w_cdl + dw))
        else if act_cat == "Structure"
            lw.w_str := math.max(0.5, math.min(2.2, lw.w_str + dw))
        else if act_cat == "VSA"
            lw.w_vsa := math.max(0.5, math.min(2.2, lw.w_vsa + dw))
        array.push(tradeHistory, TradeResult.new(act_cat, isWin, bar_index))
        if array.size(tradeHistory) > 50
            array.shift(tradeHistory)
        line.delete(ln_e)
        line.delete(ln_s)
        line.delete(ln_t1)
        line.delete(ln_t2)
        label.delete(lb_p)
        label.delete(lb_info)
        act_e := na
        t1_already := false
if generate and show_trades
    line.delete(ln_e)
    line.delete(ln_s)
    line.delete(ln_t1)
    line.delete(ln_t2)
    label.delete(lb_p)
    label.delete(lb_info)
    trade_start_bar := bar_index
    int ext = bar_index + 45
    ln_e  := line.new(bar_index, entry_p, ext, entry_p, color=accent, width=3)
    ln_s  := line.new(bar_index, stop_p,  ext, stop_p,  color=bearColor, width=2, style=line.style_dashed)
    ln_t1 := line.new(bar_index, t1_p,    ext, t1_p,    color=bullColor, width=2, style=line.style_dashed)
    ln_t2 := line.new(bar_index, t2_p,    ext, t2_p,    color=bullColor, width=2, style=line.style_dotted)
    string ltxt = pat_name + "\n" + pat_cat + "\nScore " + str.tostring(pat_score) + "/8"
    lb_p := label.new(bar_index + 3, pat_bull ? low - atr14 * 1.4 : high + atr14 * 1.4, ltxt, color = pat_bull ? bullColor : bearColor, textcolor = viz.smart_text(pat_bull ? bullColor : bearColor), style = pat_bull ? label.style_label_up : label.style_label_down, size = size.small, text_font_family = font.family_monospace)
    string infoTxt = "RCM " + rcm_regime + " (" + str.tostring(rcm_integrity*100,"#") + "%) | Size " + str.tostring(size_cue,"#.##") + "x"
    lb_info := label.new(bar_index + 10, pat_bull ? low - atr14 * 2.2 : high + atr14 * 2.2, infoTxt, color = color.new(neuColor, 75), textcolor = viz.smart_text(neuColor), style = label.style_label_center, size = size.tiny, text_font_family = font.family_monospace)
    act_e := entry_p
    act_s := stop_p
    act_t1 := t1_p
    act_t2 := t2_p
    act_long := pat_bull
    act_name := pat_name
    act_cat  := pat_cat
// ═══════════════════════════════════════════════════════════════════════════════
//          CHART RENDERS
// ═══════════════════════════════════════════════════════════════════════════════
float wav_e_fast = math.sqrt(e1 + e2) * 0.5  
float wav_e_full = math.sqrt(total_e) * 0.5  
float wav_inner = atr14 * math.max(0.3, math.min(2.5, wav_e_fast))
float wav_outer = atr14 * math.max(0.5, math.min(4.0, wav_e_full))
float wav_mid = ta.ema(close, wavelet_smooth * 3)
float wav_upper_inner = wav_mid + wav_inner
float wav_lower_inner = wav_mid - wav_inner
float wav_upper_outer = wav_mid + wav_outer
float wav_lower_outer = wav_mid - wav_outer
p_mid  = plot(show_wavelets ? wav_mid : na, "Wavelet Mid", color=color.new(wavColor, 50), linewidth=2)
p_ui   = plot(show_wavelets ? wav_upper_inner : na, "Wav Inner ↑", color=color.new(wavColor, 70), linewidth=1)
p_li   = plot(show_wavelets ? wav_lower_inner : na, "Wav Inner ↓", color=color.new(wavColor, 70), linewidth=1)
p_uo   = plot(show_wavelets ? wav_upper_outer : na, "Wav Outer ↑", color=color.new(wavColor, 85), linewidth=1, style=plot.style_circles)
p_lo   = plot(show_wavelets ? wav_lower_outer : na, "Wav Outer ↓", color=color.new(wavColor, 85), linewidth=1, style=plot.style_circles)
color wav_fill_inner = wav_align > 0 ? color.new(bullColor, 80) : wav_align < 0 ? color.new(bearColor, 80) : color.new(neuColor, 85)
color wav_fill_outer = wav_align > 0 ? color.new(bullColor, 90) : wav_align < 0 ? color.new(bearColor, 90) : color.new(neuColor, 92)
fill(p_ui, p_li, color=wav_fill_inner)
fill(p_uo, p_ui, color=wav_fill_outer)
fill(p_lo, p_li, color=wav_fill_outer)
bgcolor(use_rcm and rcm_damaged ? color.new(color.orange, 92) : na, title="RCM Damage")
bgcolor(show_energy_bg and energy_surge ? color.new(accent, 93) : na, title="Energy Surge")
var box[]   patBoxes  = array.new_box()
var label[] patLabels = array.new_label()
var int last_pattern_bar = -9999
if show_patterns and pat_name != "None" and pat_score >= min_score and bar_index - last_pattern_bar >= 6
    last_pattern_bar := bar_index
    color biasColor = pat_bull ? bullColor : bearColor
    float bTop = high + syminfo.mintick * 3
    float bBot = low  - syminfo.mintick * 3
    box bb = box.new(bar_index - 1, bTop, bar_index + 1, bBot, bgcolor=color.new(biasColor, 82), border_color=color.new(biasColor, 40), border_width=2, border_style=line.style_dashed)
    array.push(patBoxes, bb)
    string dirChar = pat_bull ? "▲" : "▼"
    string badgeTxt = dirChar + " " + pat_name
    float  lblY = pat_bull ? bBot : bTop
    label bl = label.new(bar_index, lblY, badgeTxt, color=color.new(color.black, 100), textcolor=biasColor, style=pat_bull ? label.style_label_upper_left : label.style_label_lower_left, size=size.tiny, text_font_family=font.family_monospace, tooltip=pat_cat + " | Score " + str.tostring(pat_score) + "/8 | " + regime)
    array.push(patLabels, bl)
    while array.size(patBoxes) > pat_box_history
        box.delete(array.shift(patBoxes))
    while array.size(patLabels) > pat_box_history
        label.delete(array.shift(patLabels))
plotshape(generate and show_signals and pat_bull, title="Long", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small, text="L")
plotshape(generate and show_signals and not pat_bull, title="Short", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="S")
// ═══════════════════════════════════════════════════════════════════════════════
//    DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var string dash_position = dash_pos == "TopRight" ? position.top_right : dash_pos == "TopLeft"  ? position.top_left : dash_pos == "BottomRight" ? position.bottom_right : position.bottom_left
var table dash = show_dashboard ? table.new(dash_position, 3, 32, bgcolor=dashBg, border_width=1, border_color=dashBorder) : na
if show_dashboard and barstate.islast
    int r = 0
    table.cell(dash, 0, r, "⟡ CASUAL STATE CONFIRMATION [DAFE]", text_color=accent, text_size=size.normal, bgcolor=hdrBg, text_halign=text.align_center)
    table.merge_cells(dash, 0, r, 2, r)
    r += 1
    table.cell(dash, 0, r, " CORE ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
    table.merge_cells(dash, 0, r, 2, r)
    r += 1
    table.cell(dash, 0, r, "Regime", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, regime, text_color=regime=="Trending"?bullColor:regime=="Mean Revert"?bearColor:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, "H="+str.tostring(hurst,"#.##"), text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Wavelet", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, wav_align>0?"↑ Bull":wav_align<0?"↓ Bear":"→ Flat", text_color=wav_align>0?bullColor:wav_align<0?bearColor:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, wavelet_type+" S"+str.tostring(dom_scale), text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Energy", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, energy_surge?"⚡ Surge":"Low", text_color=energy_surge?bullColor:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, str.tostring(total_e/math.max(e_sma20,EPS),"#.##")+"x", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, " LORENTZIAN ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
    table.merge_cells(dash, 0, r, 2, r)
    r += 1
    string lor_dir = lor_pred > 0.1 ? "↑ Bull" : lor_pred < -0.1 ? "↓ Bear" : "→ Neutral"
    color  lor_dir_c = lor_pred > 0.1 ? bullColor : lor_pred < -0.1 ? bearColor : neuColor
    table.cell(dash, 0, r, "Prediction", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, lor_dir+" ("+str.tostring(lor_pred, "#.##")+")", text_color=lor_dir_c, text_size=size.tiny, bgcolor=dashBgCell)
    int nn_count = array.size(nb.idxs)
    table.cell(dash, 2, r, str.tostring(nn_count)+"/"+str.tostring(lorentz_k)+" neighbors", text_color=nn_count>=lorentz_k?bullColor:nn_count>0?neuColor:txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Confidence", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    float lor_pct = lor_conf * 100
    table.cell(dash, 1, r, str.tostring(lor_pct,"#.#")+"% "+viz.draw_bar(lor_pct, 8), text_color=lor_conf > lorentz_min_conf ? (lor_pred > 0 ? bullColor : bearColor) : txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    string lor_status = lor_conf > lorentz_min_conf ? "Active" : lor_conf > 0 ? "Weak" : "Cold"
    table.cell(dash, 2, r, lor_status, text_color=lor_conf > lorentz_min_conf ? bullColor : txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, " RCM ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
    table.merge_cells(dash, 0, r, 2, r)
    r += 1
    table.cell(dash, 0, r, "State", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, rcm_regime+(rcm_damaged?" ⚠":""), text_color=rcm_code==1?bullColor:rcm_code==-1?bearColor:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, rcm_substate, text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Integrity", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, str.tostring(rcm_integrity*100,"#")+"% "+viz.draw_bar(rcm_integrity*100,8), text_color=rcm_integrity>0.6?bullColor:rcm_integrity<0.4?bearColor:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Impulse", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, "B:"+str.tostring(rcm_imp_bu,"#.#")+" S:"+str.tostring(rcm_imp_be,"#.#"), text_color=rcm_imp_bu>rcm_imp_be?bullColor:rcm_imp_be>rcm_imp_bu?bearColor:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, "Str B:"+str.tostring(rcm_str_bu,"#.#")+" S:"+str.tostring(rcm_str_be,"#.#"), text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Exhaust", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, "B:"+str.tostring(rcm_exh_bu,"#.#")+" S:"+str.tostring(rcm_exh_be,"#.#"),  text_color=rcm_exh_bu>1.5 or rcm_exh_be>1.5?color.orange:neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, "Cont B:"+str.tostring(rcm_con_bu,"#.#")+" S:"+str.tostring(rcm_con_be,"#.#"), text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, " SIGNAL ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
    table.merge_cells(dash, 0, r, 2, r)
    r += 1
    table.cell(dash, 0, r, "Pattern", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, pat_name!="None"?pat_name:"Scanning...", text_color=pat_name!="None"?(pat_bull?bullColor:bearColor):neuColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, pat_cat, text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "Score", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, str.tostring(pat_score)+"/8 "+viz.draw_bar(pat_score*12.5,8), text_color=pat_score>=min_score?bullColor:bearColor, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, pat_score>=min_score?"✓ PASS":"✗ FAIL", text_color=pat_score>=min_score?bullColor:bearColor, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    table.cell(dash, 0, r, "RL Weights", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, "O:"+str.tostring(lw.w_orig,"#.##")+" C:"+str.tostring(lw.w_cdl,"#.##"), text_color=accent, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, "S:"+str.tostring(lw.w_str,"#.##")+" V:"+str.tostring(lw.w_vsa,"#.##"), text_color=accent, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    if not na(act_e)
        table.cell(dash, 0, r, " ACTIVE TRADE ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
        table.merge_cells(dash, 0, r, 2, r)
        r += 1
        float pnl = act_long ? (close-act_e)/act_e*100 : (act_e-close)/act_e*100
        table.cell(dash, 0, r, act_name, text_color=act_long?bullColor:bearColor, text_size=size.small, bgcolor=dashBgCell)
        table.cell(dash, 1, r, (act_long?"↑ LONG ":"↓ SHORT ")+str.tostring(pnl,"#.##")+"%", text_color=pnl>0?bullColor:bearColor, text_size=size.small, bgcolor=dashBgCell)
        table.cell(dash, 2, r, act_cat, text_color=txtLo, text_size=size.small, bgcolor=dashBgCell)
        r += 1
    table.cell(dash, 0, r, " PERFORMANCE ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
    table.merge_cells(dash, 0, r, 2, r)
    r += 1
    int t1_total = t1_wins + t1_losses
    float t1_rate = t1_total > 0 ? t1_wins * 100.0 / t1_total : 0.0
    table.cell(dash, 0, r, "T1 ("+str.tostring(rr1,"#.#")+"R)", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, t1_total > 0 ? str.tostring(t1_rate,"#.#")+"% "+viz.draw_bar(t1_rate,8) : "—", text_color=t1_total>0?(t1_rate>55?bullColor:t1_rate<45?bearColor:neuColor):txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, str.tostring(t1_wins)+"W/"+str.tostring(t1_losses)+"L", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    int t2_total = t2_wins + t2_losses
    float t2_rate = t2_total > 0 ? t2_wins * 100.0 / t2_total : 0.0
    table.cell(dash, 0, r, "T2 ("+str.tostring(rr2,"#.#")+"R)", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, t2_total > 0 ? str.tostring(t2_rate,"#.#")+"% "+viz.draw_bar(t2_rate,8) : "—", text_color=t2_total>0?(t2_rate>55?bullColor:t2_rate<45?bearColor:neuColor):txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    table.cell(dash, 2, r, str.tostring(t2_wins)+"W/"+str.tostring(t2_losses)+"L ("+str.tostring(totalTrades)+")", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    r += 1
    if array.size(tradeHistory) > 0
        int _oW = 0, int _oT = 0, int _cW = 0, int _cT = 0, int _sW = 0, int _sT = 0, int _vW = 0, int _vT = 0
        for _ti = 0 to array.size(tradeHistory) - 1
            TradeResult _tr = array.get(tradeHistory, _ti)
            if _tr.cat == "Original"
                _oT += 1
                if _tr.won
                    _oW += 1
            else if _tr.cat == "Candle"
                _cT += 1
                if _tr.won
                    _cW += 1
            else if _tr.cat == "Structure"
                _sT += 1
                if _tr.won
                    _sW += 1
            else if _tr.cat == "VSA"
                _vT += 1
                if _tr.won
                    _vW += 1
        string catPerf = ""
        if _oT > 0
            catPerf += "O:" + str.tostring(_oW) + "/" + str.tostring(_oT) + " "
        if _cT > 0
            catPerf += "C:" + str.tostring(_cW) + "/" + str.tostring(_cT) + " "
        if _sT > 0
            catPerf += "S:" + str.tostring(_sW) + "/" + str.tostring(_sT) + " "
        if _vT > 0
            catPerf += "V:" + str.tostring(_vW) + "/" + str.tostring(_vT)
        if str.length(catPerf) > 0
            table.cell(dash, 0, r, "By Category", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
            table.cell(dash, 1, r, catPerf, text_color=accent, text_size=size.tiny, bgcolor=dashBgCell)
            r += 1
    string narration = rcm_integrity > 0.75 and not rcm_damaged ? "High conviction — favor aligned patterns" : rcm_damaged ? "⚠ Structural damage — reduce size, wait for repair" : rcm_integrity < 0.4 ? "Low integrity — tighten filters or sit out" : energy_surge and wav_align != 0 ? "Energy surge with wavelet alignment — watch for breakout" : near_siege ? "Siege proximity — anticipate reversal or break" : "Scanning for multi-category alignment"
    table.cell(dash, 0, r, "Narration", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
    table.cell(dash, 1, r, narration, text_color=rcm_integrity>0.75?bullColor:rcm_damaged?color.orange:txtLo, text_size=size.tiny, bgcolor=dashBgCell)
    table.merge_cells(dash, 1, r, 2, r)
    r += 1
    if use_msl and msl_show_levels
        table.cell(dash, 0, r, " STRUCTURE ", text_color=accent, text_size=size.small, bgcolor=color.new(accent, 88), text_halign=text.align_center)
        table.merge_cells(dash, 0, r, 2, r)
        r += 1
        table.cell(dash, 0, r, "POC", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
        table.cell(dash, 1, r, not na(poc_v)?str.tostring(poc_v,"#.##"):"—", text_color=at_poc?bullColor:txtLo, text_size=size.tiny, bgcolor=dashBgCell)
        table.cell(dash, 2, r, at_poc?"AT POC":"", text_color=bullColor, text_size=size.tiny, bgcolor=dashBgCell)
        r += 1
        table.cell(dash, 0, r, "VA", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
        table.cell(dash, 1, r, (not na(vah_v)?str.tostring(vah_v,"#.##"):"—")+" / "+(not na(val_v)?str.tostring(val_v,"#.##"):"—"), text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell)
        table.cell(dash, 2, r, at_vah?"AT VAH":at_val?"AT VAL":"", text_color=at_vah or at_val?bullColor:txtLo, text_size=size.tiny, bgcolor=dashBgCell)
        r += 1
        string siegeTxt = at_siege_res ? "AT RESISTANCE" : at_siege_sup ? "AT SUPPORT" : "Clear"
        color  siegeCol = at_siege_res ? bearColor : at_siege_sup ? bullColor : neuColor
        table.cell(dash, 0, r, "Siege", text_color=txtLo, text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_left)
        table.cell(dash, 1, r, siegeTxt, text_color=siegeCol, text_size=size.tiny, bgcolor=dashBgCell)
        r += 1
    table.cell(dash, 0, 31, "⟡ DskyzInvestments — Dskyz (DAFE) Trading Systems", text_color=color.new(accent, 50), text_size=size.tiny, bgcolor=dashBgCell, text_halign=text.align_center)
    table.merge_cells(dash, 0, 31, 2, 31)
// ═══════════════════════════════════════════════════════════════════════════════
//                                ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(generate and pat_bull, title="CSC Long Signal", message="⟡ CSC LONG on {{ticker}} — {{close}} | Quality signal, score ≥ min")
alertcondition(generate and not pat_bull, title="CSC Short Signal", message="⟡ CSC SHORT on {{ticker}} — {{close}} | Quality signal, score ≥ min")
alertcondition(use_rcm and rcm_damaged and not rcm_damaged[1], title="RCM Damage", message="⟡ CSC: structural integrity compromised on {{ticker}}")
alertcondition(energy_surge and not energy_surge[1], title="Energy Surge", message="⟡ CSC: wavelet energy surge detected on {{ticker}}")
````
