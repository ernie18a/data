# BTC Systemic Sell Pressure Engine multi-factor 

- url: https://www.tradingview.com/script/0tEn6Rv3-BTC-Systemic-Sell-Pressure-Engine-multi-factor/
- type: indicator
- pine_id: PUB;5ea1c99b126541c19cbf7b9f7fa6527a
- version: 2.0

## Description

BTC Systemic Sell Pressure Engine V5.5 Final

BTC Systemic Sell Pressure Engine is a synthetic Bitcoin risk-monitoring indicator designed to detect when sell pressure may be building across price action, volume, structure, flow proxies, macro proxies, and market-stress conditions.

This script does not read private wallets, private exchange books, official ETF flow data, or private on-chain databases. Instead, it builds a multi-factor risk model from data available on TradingView and optional external sources connected by the user.

The goal is not to predict every top or bottom. The goal is to help traders recognize when Bitcoin is moving from normal conditions into possible distribution, warning, critical risk, or cascade-risk environments.

WHAT THE INDICATOR ANALYZES

1. Volume and Dollar Volume
The engine checks whether chart volume and estimated dollar volume are unusually high compared with recent history. Abnormal participation can reveal aggressive activity.

2. Synthetic Delta and CVD
The script builds a synthetic delta model using candle position and volume. It also builds a synthetic CVD to detect when buying or selling pressure is not confirming price movement.

3. Distribution and Absorption
The indicator searches for hidden selling behavior, including:
- high effort with weak price progress
- upper-wick rejection
- failed breakouts
- liquidity sweeps above recent highs
- absorption near local highs

4. Structure and Liquidity Vacuum
The engine checks for important structural damage, including:
- support breaks
- bearish EMA conditions
- failed retests
- large bearish candles
- ATR expansion
- compression breakdowns

5. VWAP and OBV Pressure
The script monitors session VWAP loss and OBV divergence. If price holds high while OBV or synthetic CVD weakens, the dashboard can show early hidden weakness.

6. Higher-Timeframe Stress
The indicator checks multiple higher timeframes using non-repainting request.security() calls with lookahead_off. This helps separate small intraday noise from larger structural risk.

7. ETF Basket Proxy
The script uses a Bitcoin ETF proxy basket:
- IBIT
- FBTC
- GBTC
- BITB
- ARKB

This is not official ETF flow data. It is a price/volume proxy designed to detect weakness or divergence in institutional Bitcoin-related markets.

8. Macro Stress Proxy
The macro module uses:
- VIX
- DXY
- NDX

This helps identify risk-off environments where Bitcoin may become more vulnerable to sell pressure.

9. Stablecoin and Miner Stress
The script can monitor stablecoin dominance and Bitcoin-sensitive equities/miners such as MARA, RIOT, CLSK, and MSTR.

10. Market Stress
The market-stress module checks:
- BTC multi-exchange price spread
- BTC dominance weakness
- total crypto market-cap pressure

11. Optional External Data
Users can connect external exchange netflow or open-interest sources through TradingView source inputs. These are optional and disabled by default.

12. Panic / Kill-Switch Mode
Manual risk amplifier for confirmed off-chart events such as exchange failure, custody risk, ETF stress, macro panic, banking stress, or other serious market events.

DASHBOARD STATES

NORMAL
No major sell-pressure event is currently detected.

WATCH
Early warning only. This should not be used alone as a trade signal.

WARNING
Sell-pressure conditions are elevated. The trader should watch structure, VWAP, CVD, OBV, and higher-timeframe confirmation.

CRITICAL
High-risk environment. This means pressure is serious, but the strongest signal still requires cascade confirmation.

CASCADE
Strongest risk state. This appears only when the engine detects extreme sell-pressure conditions with structure and volatility confirmation.

PHASE SYSTEM

NO PHASE
No major sell-pressure structure detected.

PHASE 1 DISTRIBUTION
Possible hidden selling, absorption, ETF weakness, or sweep-trap behavior.

PHASE 2 BREAKDOWN
Support failure or compression breakdown.

PHASE 3 LIQUIDATION
Cascade-style sell-pressure environment with structural failure and volatility expansion.

PHASE 4 RESET WATCH
Previous risk was high, but price has started recovering above important references.

BEST CONFIRMATION

The strongest warning condition is:

CASCADE + Grade A/A+ + Phase 3 Liquidation

Do not use WATCH alone as a trading signal. WATCH is only an early warning.

TIMEFRAME GUIDE

3m / 15m
Useful for short-term pressure warning and intraday monitoring.

4H
Useful for early serious warning.

1D
Useful for stronger confirmation.

1W
Useful for macro confirmation.

HOW TO USE

1. Watch the dashboard first.
The dashboard tells you whether the current state is NORMAL, WATCH, WARNING, CRITICAL, or CASCADE.

2. Confirm with structure.
The most important confirmation is not only score. Watch:
- Structure score
- Support / Vacuum
- HTF Bears
- OBV Div / CVD Bear
- VWAP Pressure
- Distribution Zones

3. Use Distribution Zones carefully.
A Distribution Zone marks an area where the engine detected possible hidden selling, absorption, failed breakout, or liquidity sweep. It is not automatically a short signal. It becomes more important if price rejects from it and the dashboard risk increases.

4. Use Cascade Targets only after cascade confirmation.
Cascade targets are ATR-based downside risk projections. They are not guaranteed predictions. They are volatility-based risk levels that appear only after cascade pressure is detected.

5. Use the HELP label.
The chart includes a HELP label. Hover over it to read what the indicator does, how to read the score, and how to interpret current conditions.

ALERTS

The script includes alert conditions for:
- Watch
- Warning
- Critical
- Cascade
- Institutional Trap
- Liquidity Sweep Distribution
- Compression Breakdown
- Exchange Dislocation Critical
- Risk Invalidated

The script also includes dynamic JSON alerts for automation and webhook use.

LIMITATIONS

This indicator does not have direct access to:
- private wallet labels
- private exchange order books
- official ETF creation/redemption files
- private institutional flow
- private Chainalysis data
- real exchange netflow unless connected by the user through an external source

All calculations are based on TradingView-available data, proxy markets, and optional user-connected sources.

IMPORTANT

This is a risk-monitoring and confirmation tool. It is not financial advice. It should be used with price structure, risk management, position sizing, and independent analysis.

Open-source script

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IlSeparatio369.

//@version=6
indicator("BTC Systemic Sell Pressure Engine V5.5 Final", "BTC Sell Pressure V5.5", overlay = true, max_labels_count = 500, max_lines_count = 400, max_boxes_count = 180, max_bars_back = 1500, dynamic_requests = true)

//──────────────────────────────────────────────────────────────────────────────
// BTC SYSTEMIC SELL PRESSURE ENGINE V5.5 FINAL
//──────────────────────────────────────────────────────────────────────────────
// This indicator is a synthetic Bitcoin sell-pressure risk monitor.
//
// Important limitation:
// Pine Script cannot directly read private whale wallets, private exchange books,
// official ETF flow files, private Chainalysis databases, or true exchange netflow
// unless those data streams are available as TradingView symbols or external sources.
//
// What this indicator does:
// 1. Detects abnormal volume and abnormal dollar volume.
// 2. Builds synthetic sell-side delta and synthetic CVD.
// 3. Detects hidden distribution, absorption, failed breakouts, and upside liquidity sweeps.
// 4. Detects liquidity-vacuum breakdowns and support failures.
// 5. Tracks session VWAP loss and OBV/CVD divergence.
// 6. Uses an ETF basket proxy: IBIT, FBTC, GBTC, BITB, ARKB.
// 7. Uses macro stress proxies: VIX, DXY, NDX.
// 8. Uses stablecoin dominance and miner-equity stress.
// 9. Detects multi-exchange BTC price dislocation.
// 10. Detects BTC dominance weakness and total crypto market-cap stress.
// 11. Accepts optional external exchange-flow and open-interest inputs.
// 12. Includes manual panic / kill-switch mode for confirmed off-chart crisis events.
// 13. Adds hover tooltips to chart labels so open-source users understand every signal.
//
// How to use:
// 3m / 15m = short-term pressure warning.
// 4H = early serious warning.
// 1D = confirmation.
// 1W = macro confirmation.
//
// Strongest warning:
// CASCADE + Grade A/A+ + Phase 3 Liquidation.
//
// Do not use WATCH alone as a trade signal. This is a risk-monitoring and confirmation tool.

//──────────────────────────────────────────────────────────────────────────────
// GROUPS
//──────────────────────────────────────────────────────────────────────────────
groupCore      = "1. Core Engine"
groupDelta     = "2. Synthetic Delta / CVD"
groupAbsorb    = "3. Distribution / Sweep Traps"
groupVacuum    = "4. Structure / Liquidity Vacuum"
groupVWAP      = "5. VWAP / Flow Divergence"
groupHTF       = "6. Higher-Timeframe Stress"
groupETF       = "7. ETF Basket / Institutional Proxy"
groupMacro     = "8. Macro / Stablecoin / Miner Stress"
groupMarket    = "9. Multi-Exchange / Market-Cap Stress"
groupExternal  = "10. Optional External Sources"
groupNarrative = "11. Panic / Kill-Switch"
groupVisual    = "12. Visuals"
groupAlert     = "13. Alerts"

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
volLen = input.int(50, "Volume Baseline Length", minval = 5, maxval = 500, group = groupCore, tooltip = "Calculates normal chart volume. Higher values reduce false alarms. Lower values react faster but can be noisy.")
dollarLen = input.int(50, "Dollar Volume Baseline Length", minval = 5, maxval = 500, group = groupCore, tooltip = "Calculates normal notional volume using close multiplied by chart volume. Abnormal dollar volume can reveal large participation.")
atrLen = input.int(14, "ATR Length", minval = 1, maxval = 200, group = groupCore, tooltip = "ATR length used for volatility, candle-size, and liquidity-vacuum detection.")
zWarn = input.float(1.50, "Z-Score Warning", minval = 0.10, step = 0.10, group = groupCore, tooltip = "Readings above this z-score are unusually high versus recent history.")
zCritical = input.float(2.75, "Z-Score Critical", minval = 0.20, step = 0.10, group = groupCore, tooltip = "Readings above this z-score are statistically extreme versus recent history.")
useAdaptive = input.bool(true, "Use Adaptive Volatility Thresholds", group = groupCore, tooltip = "When enabled, warning thresholds adjust lower during volatility expansion and higher during quiet regimes.")
sensitivity = input.string("Normal", "Sensitivity", options = ["Conservative", "Normal", "Aggressive"], group = groupCore, tooltip = "Aggressive triggers earlier. Conservative requires stronger confirmation.")
scoreSmoothLen = input.int(3, "Score Smoothing", minval = 1, maxval = 20, group = groupCore, tooltip = "Smooths the final systemic score to reduce flicker.")
riskMemoryLen = input.int(8, "Risk Memory Length", minval = 1, maxval = 100, group = groupCore, tooltip = "Keeps recent pressure active instead of resetting too fast after one calm candle.")
riskMemoryWeight = input.float(0.25, "Risk Memory Weight", minval = 0.0, maxval = 0.75, step = 0.05, group = groupCore, tooltip = "How much remembered risk contributes to the final score.")
autoRegimeWeighting = input.bool(true, "Auto Regime Weighting", group = groupCore, tooltip = "Increases risk weighting during high-volatility downtrends and lowers it during calm compression regimes.")

closeLowZone = input.float(0.25, "Bear Close Near Low Zone", minval = 0.05, maxval = 0.50, step = 0.05, group = groupDelta, tooltip = "A bearish candle closing inside this lower part of its range receives stronger sell-pressure weight.")
bodyATRMin = input.float(0.65, "Minimum Bear Body ATR", minval = 0.05, step = 0.05, group = groupDelta, tooltip = "Bearish candle body must exceed this ATR multiple to count as aggressive selling.")
deltaLen = input.int(34, "Synthetic Delta Baseline", minval = 5, maxval = 300, group = groupDelta, tooltip = "Baseline length for synthetic sell-delta anomaly detection.")
deltaWeight = input.float(1.20, "Red Candle Delta Amplifier", minval = 0.50, maxval = 3.00, step = 0.05, group = groupDelta, tooltip = "Amplifies synthetic sell delta on bearish candles.")
cvdLen = input.int(55, "Synthetic CVD Trend Length", minval = 5, maxval = 300, group = groupDelta, tooltip = "Tracks persistent synthetic buy/sell pressure. Falling CVD while price holds is possible distribution.")

weakProgressATR = input.float(0.35, "Weak Progress ATR Limit", minval = 0.05, step = 0.05, group = groupAbsorb, tooltip = "If price progress is small relative to ATR while effort is high, possible absorption/distribution is detected.")
upperWickMin = input.float(0.35, "Upper Wick Distribution Ratio", minval = 0.05, maxval = 0.90, step = 0.05, group = groupAbsorb, tooltip = "Large upper wick relative to the candle range adds hidden-distribution pressure.")
nearHighLen = input.int(100, "Near-High Lookback", minval = 10, maxval = 500, group = groupAbsorb, tooltip = "Absorption near a local high receives stronger distribution weight.")
sweepLen = input.int(40, "Liquidity Sweep Lookback", minval = 5, maxval = 300, group = groupAbsorb, tooltip = "Detects failed upside sweeps above recent highs.")
showZones = input.bool(true, "Show Distribution Zones", group = groupAbsorb, tooltip = "Draws automatic boxes when high-effort hidden distribution is detected.")
zoneExtend = input.int(80, "Zone Extend Bars", minval = 5, maxval = 500, group = groupAbsorb, tooltip = "How far distribution zones extend into the future.")
zoneLife = input.int(250, "Zone Maximum Life Bars", minval = 20, maxval = 1000, group = groupAbsorb, tooltip = "Deletes old distribution zones after this many bars.")

supportLen = input.int(50, "Support Break Lookback", minval = 5, maxval = 500, group = groupVacuum, tooltip = "Price closing below the prior lowest low from this lookback confirms structural support failure.")
fastEmaLen = input.int(21, "Fast EMA", minval = 2, maxval = 200, group = groupVacuum, tooltip = "Fast trend reference.")
slowEmaLen = input.int(200, "Slow EMA", minval = 20, maxval = 600, group = groupVacuum, tooltip = "Slow macro trend reference.")
rangeATRMin = input.float(1.40, "Large Range ATR Multiple", minval = 0.50, step = 0.05, group = groupVacuum, tooltip = "Candle range above this ATR multiple indicates abnormal volatility.")
atrExpansionMin = input.float(1.25, "ATR Expansion Ratio", minval = 0.50, step = 0.05, group = groupVacuum, tooltip = "ATR above this multiple of its own baseline confirms volatility expansion.")
breakRetestBars = input.int(10, "Break Retest Window", minval = 1, maxval = 100, group = groupVacuum, tooltip = "Bars after a breakdown where failed retest can increase risk.")
bbLen = input.int(50, "Compression Length", minval = 10, maxval = 300, group = groupVacuum, tooltip = "Length used for volatility compression-to-expansion detection.")
bbMult = input.float(2.0, "Compression Band Multiplier", minval = 0.5, maxval = 5.0, step = 0.1, group = groupVacuum, tooltip = "Bollinger-style multiplier for compression width analysis.")

enableVWAP = input.bool(true, "Enable Session VWAP Pressure", group = groupVWAP, tooltip = "Adds risk when price loses session VWAP under abnormal sell pressure.")
obvLen = input.int(80, "OBV Divergence Lookback", minval = 10, maxval = 500, group = groupVWAP, tooltip = "Detects when price holds near highs while OBV fails to confirm.")
showVWAP = input.bool(true, "Show Session VWAP", group = groupVWAP, tooltip = "Plots session VWAP used by the pressure engine.")

htf1 = input.timeframe("240", "HTF 1", group = groupHTF, tooltip = "First higher timeframe confirmation. 240 = 4H.")
htf2 = input.timeframe("D", "HTF 2", group = groupHTF, tooltip = "Second higher timeframe confirmation.")
htf3 = input.timeframe("W", "HTF 3", group = groupHTF, tooltip = "Third macro higher timeframe confirmation.")
htfEmaLen = input.int(100, "HTF EMA Length", minval = 10, maxval = 500, group = groupHTF, tooltip = "HTF close below this EMA increases systemic pressure.")

enableETF = input.bool(true, "Enable ETF Basket Proxy", group = groupETF, tooltip = "Uses a basket of Bitcoin ETFs as institutional distribution proxy. This is not official ETF flow data.")
etfTf = input.timeframe("D", "ETF Timeframe", group = groupETF, tooltip = "Daily is recommended because ETFs trade in regular sessions.")
etfSymbol1 = input.symbol("NASDAQ:IBIT", "ETF 1", group = groupETF, tooltip = "Default: BlackRock IBIT.")
etfSymbol2 = input.symbol("AMEX:FBTC", "ETF 2", group = groupETF, tooltip = "Default: Fidelity FBTC.")
etfSymbol3 = input.symbol("AMEX:GBTC", "ETF 3", group = groupETF, tooltip = "Default: Grayscale GBTC.")
etfSymbol4 = input.symbol("AMEX:BITB", "ETF 4", group = groupETF, tooltip = "Default: Bitwise BITB.")
etfSymbol5 = input.symbol("AMEX:ARKB", "ETF 5", group = groupETF, tooltip = "Default: ARK 21Shares ARKB.")
etfVolLen = input.int(20, "ETF Volume Baseline", minval = 5, maxval = 200, group = groupETF, tooltip = "Baseline length for ETF volume anomaly.")
etfDropPct = input.float(2.00, "ETF Basket Bear Drop %", minval = 0.10, step = 0.10, group = groupETF, tooltip = "ETF basket drop larger than this percentage increases institutional pressure.")
etfDivergence = input.bool(true, "Detect ETF/BTC Divergence", group = groupETF, tooltip = "Adds risk when the ETF basket shows bearish distribution while BTC still appears stable.")

enableMacro = input.bool(true, "Enable Macro Stress Proxy", group = groupMacro, tooltip = "Uses VIX, DXY, and NDX as macro stress proxies.")
macroTf = input.timeframe("D", "Macro Timeframe", group = groupMacro, tooltip = "Daily is recommended for macro proxies.")
vixSymbol = input.symbol("TVC:VIX", "VIX Symbol", group = groupMacro, tooltip = "VIX rising while BTC weakens adds macro risk.")
dxySymbol = input.symbol("TVC:DXY", "DXY Symbol", group = groupMacro, tooltip = "Dollar strength while BTC weakens adds liquidity risk.")
ndxSymbol = input.symbol("NASDAQ:NDX", "NDX Symbol", group = groupMacro, tooltip = "Nasdaq weakness while BTC weakens adds risk-off pressure.")
enableStable = input.bool(true, "Enable Stablecoin Dominance Proxy", group = groupMacro, tooltip = "Uses stablecoin dominance as a flight-to-safety proxy when available.")
stableSymbol = input.symbol("CRYPTOCAP:USDT.D", "Stablecoin Dominance Symbol", group = groupMacro, tooltip = "Default uses USDT dominance when available on TradingView.")
stableLen = input.int(20, "Stablecoin Dominance Baseline", minval = 5, maxval = 200, group = groupMacro, tooltip = "Rising stablecoin dominance can indicate crypto risk-off behavior.")
enableMiners = input.bool(true, "Enable Miner / Crypto Equity Stress", group = groupMacro, tooltip = "Uses miner and crypto-equity weakness as a stress proxy.")
miner1 = input.symbol("NASDAQ:MARA", "Miner Proxy 1", group = groupMacro, tooltip = "Default: MARA.")
miner2 = input.symbol("NASDAQ:RIOT", "Miner Proxy 2", group = groupMacro, tooltip = "Default: RIOT.")
miner3 = input.symbol("NASDAQ:CLSK", "Miner Proxy 3", group = groupMacro, tooltip = "Default: CLSK.")
miner4 = input.symbol("NASDAQ:MSTR", "Crypto Equity Proxy", group = groupMacro, tooltip = "Default: MSTR as Bitcoin-sensitive equity proxy.")

enableMarketStress = input.bool(true, "Enable Multi-Exchange / Market Stress", group = groupMarket, tooltip = "Adds BTC exchange-price dislocation, BTC dominance stress, and total crypto market-cap drawdown velocity.")
btcEx1 = input.symbol("COINBASE:BTCUSD", "BTC Reference 1", group = groupMarket, tooltip = "BTC reference market for dislocation checks.")
btcEx2 = input.symbol("BITSTAMP:BTCUSD", "BTC Reference 2", group = groupMarket, tooltip = "BTC reference market for dislocation checks.")
btcEx3 = input.symbol("BINANCE:BTCUSDT", "BTC Reference 3", group = groupMarket, tooltip = "BTC reference market for dislocation checks.")
spreadWarnPct = input.float(0.25, "Exchange Spread Warning %", minval = 0.01, maxval = 5.0, step = 0.01, group = groupMarket, tooltip = "BTC exchange spread above this percentage adds stress points.")
spreadCriticalPct = input.float(0.75, "Exchange Spread Critical %", minval = 0.05, maxval = 10.0, step = 0.05, group = groupMarket, tooltip = "BTC exchange spread above this percentage adds critical dislocation points.")
btcDomSymbol = input.symbol("CRYPTOCAP:BTC.D", "BTC Dominance Symbol", group = groupMarket, tooltip = "BTC dominance weakness can show rotation away from BTC leadership.")
totalCapSymbol = input.symbol("CRYPTOCAP:TOTAL", "Total Crypto Market Cap", group = groupMarket, tooltip = "Total crypto market-cap drawdown velocity acts as broad liquidity stress.")
marketLen = input.int(30, "Market Stress Baseline", minval = 5, maxval = 200, group = groupMarket, tooltip = "Baseline for BTC dominance and total crypto market-cap stress.")

enableFlow = input.bool(false, "Enable External Exchange Netflow Source", group = groupExternal, tooltip = "Enable only if you connect a real exchange inflow/netflow plot from another indicator or data vendor.")
flowSrc = input.source(close, "External Exchange Netflow Source", group = groupExternal, tooltip = "Positive spikes are treated as sell pressure by default.")
flowMode = input.string("Positive = Sell Pressure", "Flow Direction Mode", options = ["Positive = Sell Pressure", "Negative = Sell Pressure"], group = groupExternal, tooltip = "Use this if your source reports sell pressure as negative instead of positive.")
flowLen = input.int(50, "Flow Baseline Length", minval = 5, maxval = 500, group = groupExternal, tooltip = "Baseline length for external exchange-flow anomaly.")
flowRiseBars = input.int(3, "Flow Rising Bars", minval = 1, maxval = 20, group = groupExternal, tooltip = "External flow rising for this many bars increases sell-pressure probability.")
enableOI = input.bool(false, "Enable External Open Interest Source", group = groupExternal, tooltip = "Enable only if you connect open-interest or leverage-risk source.")
oiSrc = input.source(close, "External Open Interest Source", group = groupExternal, tooltip = "High open interest while price breaks support increases liquidation-cascade risk.")
oiLen = input.int(50, "OI Baseline Length", minval = 5, maxval = 500, group = groupExternal, tooltip = "Baseline length for external open-interest anomaly.")

panicMode = input.string("Off", "Manual Panic Narrative Mode", options = ["Off", "Watch", "Active", "Critical"], group = groupNarrative, tooltip = "Manual off-chart amplifier. Use only during confirmed macro, exchange, custody, ETF, quantum-risk, or banking-stress headlines.")
panicWeight = input.float(8.0, "Panic Narrative Max Points", minval = 0.0, maxval = 25.0, step = 0.5, group = groupNarrative, tooltip = "Maximum score added when panic narrative is set to Critical.")
killSwitch = input.bool(false, "Kill-Switch Extreme Risk Mode", group = groupNarrative, tooltip = "Manual override for extreme external events. Adds emergency pressure to score and dashboard.")

watchLevel = input.float(35.0, "Watch Score", minval = 1.0, maxval = 100.0, group = groupVisual, tooltip = "Above this score the dashboard enters WATCH mode.")
warningLevel = input.float(55.0, "Warning Score", minval = 1.0, maxval = 100.0, group = groupVisual, tooltip = "Above this score the dashboard enters WARNING mode.")
criticalLevel = input.float(75.0, "Critical Score", minval = 1.0, maxval = 100.0, group = groupVisual, tooltip = "Above this score the dashboard enters CRITICAL mode.")
cascadeLevel = input.float(88.0, "Cascade Score", minval = 1.0, maxval = 100.0, group = groupVisual, tooltip = "Above this score, with breakdown confirmation, the dashboard enters CASCADE mode.")
hysteresisGap = input.float(6.0, "State Hysteresis Gap", minval = 0.0, maxval = 25.0, step = 0.5, group = groupVisual, tooltip = "Prevents state flicker by requiring score to fall below the previous state's threshold by this gap before downgrading.")
labelCooldown = input.int(20, "Signal Label Cooldown Bars", minval = 0, maxval = 500, group = groupVisual, tooltip = "Minimum bars between event labels. Helps avoid label spam.")
showDashboard = input.bool(true, "Show Dashboard", group = groupVisual, tooltip = "Shows live systemic sell-pressure dashboard.")
showBg = input.bool(true, "Show Risk Background", group = groupVisual, tooltip = "Colors background by risk state.")
showEMAs = input.bool(true, "Show EMAs", group = groupVisual, tooltip = "Plots fast and slow EMAs.")
showSupport = input.bool(true, "Show Support Level", group = groupVisual, tooltip = "Plots prior support break level.")
showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Shows warning labels with hover explanations when risk state upgrades.")
colorBars = input.bool(true, "Color Bars By Risk", group = groupVisual, tooltip = "Colors candles according to current risk state.")
showTargets = input.bool(true, "Show Cascade Targets", group = groupVisual, tooltip = "Projects downside ATR-based targets after a cascade signal.")
keepHistoricalCascadeTargets = input.bool(false, "Keep Old Cascade Targets", group = groupVisual, tooltip = "When OFF, cascade targets disappear when Cascade is no longer active. When ON, old cascade targets remain as historical reference levels.")
showUserHelp = input.bool(true, "Show Main HELP Label", group = groupVisual, tooltip = "Shows one compact HELP label on the chart. Hover over it to understand what the indicator does and how to use it.")
helpOffsetBars = input.int(25, "HELP Label Offset Bars", minval = 1, maxval = 150, group = groupVisual, tooltip = "Moves the HELP label to the right of the current candle.")
maxSignalTooltips = input.int(80, "Maximum Signal Tooltip Labels", minval = 10, maxval = 300, group = groupVisual, tooltip = "Limits how many historical tooltip labels remain on the chart.")

enableJsonAlerts = input.bool(true, "Enable Dynamic JSON Alerts", group = groupAlert, tooltip = "Sends webhook-ready JSON alerts when risk state upgrades.")
alertsOnClose = input.bool(true, "Trigger Alerts On Bar Close Only", group = groupAlert, tooltip = "When enabled, dynamic alerts trigger only after confirmed candle close.")

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_safe(float x) =>
    na(x) ? 0.0 : x

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, f_safe(x)))

f_z(float src, int len) =>
    mean = ta.sma(src, len)
    dev = ta.stdev(src, len)
    dev > 0.0 ? (src - mean) / dev : 0.0

f_zpts(float z, float warn, float crit, float pts) =>
    crit <= warn ? 0.0 : pts * f_clamp((z - warn) / (crit - warn), 0.0, 1.0)

f_boolpts(bool cond, float pts) =>
    cond ? pts : 0.0

f_ret(float o, float c) =>
    o > 0.0 and not na(o) and not na(c) ? 100.0 * (c - o) / o : 0.0

f_valid(float c) =>
    not na(c)

f_stateText(int s) =>
    s == 4 ? "CASCADE" : s == 3 ? "CRITICAL" : s == 2 ? "WARNING" : s == 1 ? "WATCH" : "NORMAL"

f_phaseText(int p) =>
    p == 4 ? "PHASE 4 RESET WATCH" : p == 3 ? "PHASE 3 LIQUIDATION" : p == 2 ? "PHASE 2 BREAKDOWN" : p == 1 ? "PHASE 1 DISTRIBUTION" : "NO PHASE"

f_grade(float score, bool cascade, int htfCount, bool supportBroken) =>
    cascade and htfCount >= 2 ? "A+" : score >= 80 and supportBroken ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_stateColor(int s) =>
    s == 4 ? color.new(color.maroon, 0) : s == 3 ? color.new(color.red, 0) : s == 2 ? color.new(color.orange, 0) : s == 1 ? color.new(color.yellow, 0) : color.new(color.green, 0)

f_yesNo(bool x) =>
    x ? "YES" : "NO"

f_finalInstruction(int s) =>
    s >= 4 ? "DEFENSE" : s >= 3 ? "HIGH RISK" : s >= 2 ? "CAUTION" : s >= 1 ? "WATCH" : "NORMAL"

var label[] signalTooltipLabels = array.new_label()

f_trimSignalLabels() =>
    while array.size(signalTooltipLabels) > maxSignalTooltips
        oldLabel = array.shift(signalTooltipLabels)
        label.delete(oldLabel)
    0

//──────────────────────────────────────────────────────────────────────────────
// PRICE / VOLUME CORE
//──────────────────────────────────────────────────────────────────────────────
atr = ta.atr(atrLen)
atrBase = ta.sma(atr, atrLen * 3)
atrRatio = atrBase > 0.0 ? atr / atrBase : 0.0

barRangeRaw = high - low
barRange = math.max(barRangeRaw, syminfo.mintick)
body = math.abs(close - open)
bodyATR = atr > 0.0 ? body / atr : 0.0
closePosition = f_clamp((close - low) / barRange, 0.0, 1.0)

redCandle = close < open
greenCandle = close > open
closeNearLow = closePosition <= closeLowZone

volZ = f_z(volume, volLen)
dollarVolume = close * volume
dollarZ = f_z(dollarVolume, dollarLen)

coreScore = f_clamp(f_zpts(volZ, zWarn, zCritical, 6.0) + f_zpts(dollarZ, zWarn, zCritical, 7.0) + f_boolpts(redCandle and bodyATR >= bodyATRMin, 4.0) + f_boolpts(redCandle and closeNearLow and volZ >= zWarn, 5.0), 0.0, 22.0)

//──────────────────────────────────────────────────────────────────────────────
// SYNTHETIC DELTA / CVD
//──────────────────────────────────────────────────────────────────────────────
sellShareBase = 1.0 - closePosition
buyShareBase = closePosition
sellShare = redCandle ? sellShareBase * deltaWeight : sellShareBase
buyShare = greenCandle ? buyShareBase * 1.05 : buyShareBase

syntheticSellVol = volume * sellShare
syntheticBuyVol = volume * buyShare
syntheticDelta = syntheticBuyVol - syntheticSellVol
negativeDelta = math.max(-syntheticDelta, 0.0)
negativeDeltaZ = f_z(negativeDelta, deltaLen)

syntheticCVD = ta.cum(syntheticDelta)
cvdEma = ta.ema(syntheticCVD, cvdLen)
cvdBear = syntheticCVD < cvdEma

cvdHighestClosePrev = ta.highest(close, cvdLen)[1]
cvdHighestCVDPrev = ta.highest(syntheticCVD, cvdLen)[1]
cvdLowerHigh = not na(cvdHighestClosePrev) and not na(cvdHighestCVDPrev) and close >= cvdHighestClosePrev * 0.98 and syntheticCVD < cvdHighestCVDPrev

deltaImpulse = negativeDeltaZ >= zWarn and redCandle and closeNearLow
deltaCritical = negativeDeltaZ >= zCritical and redCandle
deltaScore = f_clamp(f_zpts(negativeDeltaZ, zWarn, zCritical, 8.0) + f_boolpts(deltaImpulse, 4.0) + f_boolpts(deltaCritical, 3.0) + f_boolpts(cvdBear, 2.0) + f_boolpts(cvdLowerHigh, 3.0), 0.0, 20.0)

//──────────────────────────────────────────────────────────────────────────────
// DISTRIBUTION / SWEEP TRAPS
//──────────────────────────────────────────────────────────────────────────────
priceProgress = math.abs(close - close[1])
progressATR = atr > 0.0 ? priceProgress / atr : 0.0

upperWick = high - math.max(open, close)
upperWickRatio = barRange > 0.0 ? upperWick / barRange : 0.0

highestNearHigh = ta.highest(high, nearHighLen)
highestNearHighPrev = highestNearHigh[1]

nearLocalHigh = not na(highestNearHigh) and close >= highestNearHigh * 0.97
highEffort = volZ >= zWarn or dollarZ >= zWarn or negativeDeltaZ >= zWarn
weakProgress = progressATR <= weakProgressATR
wickDistribution = upperWickRatio >= upperWickMin and closePosition < 0.65
failedBreakout = not na(highestNearHighPrev) and high >= highestNearHighPrev and close < high - barRange * 0.50

priorSweepHigh = ta.highest(high, sweepLen)[1]
liquiditySweepUp = not na(priorSweepHigh) and high > priorSweepHigh and close < priorSweepHigh and closePosition < 0.55
sweepDistribution = liquiditySweepUp and highEffort

absorption = highEffort and weakProgress and (redCandle or closePosition < 0.55)
distributionNearHigh = absorption and nearLocalHigh
rejectionDistribution = highEffort and wickDistribution
stealthDistribution = highEffort and failedBreakout

absorbScore = f_clamp(f_boolpts(absorption, 4.0) + f_boolpts(distributionNearHigh, 5.0) + f_boolpts(rejectionDistribution, 4.0) + f_boolpts(stealthDistribution, 4.0) + f_boolpts(sweepDistribution, 5.0), 0.0, 22.0)

//──────────────────────────────────────────────────────────────────────────────
// DISTRIBUTION ZONE
//──────────────────────────────────────────────────────────────────────────────
var box distBox = na
var float zoneTop = na
var float zoneBottom = na
var int zoneBorn = na
var label zoneHelp = na

newZoneSignal = showZones and (distributionNearHigh or stealthDistribution or rejectionDistribution or sweepDistribution) and barstate.isconfirmed

if newZoneSignal
    if not na(distBox)
        box.delete(distBox)
    if not na(zoneHelp)
        label.delete(zoneHelp)
    zoneTop := high
    zoneBottom := low
    zoneBorn := bar_index
    distBox := box.new(bar_index, zoneTop, bar_index + zoneExtend, zoneBottom, xloc = xloc.bar_index, bgcolor = color.new(color.red, 88), border_color = color.new(color.red, 35))
    zoneTip = "Distribution Zone\n\nThis box marks an area where the engine detected possible hidden selling, absorption, failed breakout, or upside liquidity sweep.\n\nZone top: " + str.tostring(zoneTop, format.mintick) + "\nZone bottom: " + str.tostring(zoneBottom, format.mintick) + "\n\nIf price rejects from this zone again, sell-pressure risk can increase. If price closes above the zone top, this zone is invalidated."
    zoneHelp := label.new(bar_index, zoneTop, "DIST ZONE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.tiny, tooltip = zoneTip)

if showZones and not na(distBox)
    box.set_right(distBox, bar_index + zoneExtend)
    box.set_top(distBox, zoneTop)
    box.set_bottom(distBox, zoneBottom)
    if not na(zoneHelp)
        label.set_x(zoneHelp, bar_index)
        label.set_y(zoneHelp, zoneTop)
    expired = not na(zoneBorn) and bar_index - zoneBorn > zoneLife
    invalidatedZone = not na(zoneTop) and close > zoneTop
    if expired or invalidatedZone
        box.delete(distBox)
        if not na(zoneHelp)
            label.delete(zoneHelp)
        distBox := na
        zoneHelp := na
        zoneTop := na
        zoneBottom := na
        zoneBorn := na

//──────────────────────────────────────────────────────────────────────────────
// STRUCTURE / LIQUIDITY VACUUM
//──────────────────────────────────────────────────────────────────────────────
fastEma = ta.ema(close, fastEmaLen)
slowEma = ta.ema(close, slowEmaLen)

priorSupport = ta.lowest(low, supportLen)[1]
supportBreak = not na(priorSupport) and close < priorSupport

fastBear = close < fastEma
slowBear = close < slowEma
emaBearStack = fastEma < slowEma

rangeATR = atr > 0.0 ? barRange / atr : 0.0
largeRange = rangeATR >= rangeATRMin
atrExpansion = atrRatio >= atrExpansionMin

liquidityVacuum = redCandle and closeNearLow and largeRange and atrExpansion
cascadeSetup = supportBreak and liquidityVacuum and (volZ >= zWarn or dollarZ >= zWarn or negativeDeltaZ >= zWarn)

barsSinceBreak = ta.barssince(supportBreak)
failedRetest = barsSinceBreak > 0 and barsSinceBreak <= breakRetestBars and high >= priorSupport and close < priorSupport and redCandle

bbBasis = ta.sma(close, bbLen)
bbDev = ta.stdev(close, bbLen)
bbUpper = bbBasis + bbDev * bbMult
bbLower = bbBasis - bbDev * bbMult
bbWidth = bbBasis != 0.0 ? (bbUpper - bbLower) / bbBasis : 0.0
bbWidthLowestPrev = ta.lowest(bbWidth, bbLen)[1]
compression = not na(bbWidthLowestPrev) and bbWidth <= bbWidthLowestPrev * 1.10
compressionBreakdown = compression[1] and supportBreak and redCandle and atrExpansion

structureScore = f_clamp(f_boolpts(supportBreak, 8.0) + f_boolpts(fastBear, 3.0) + f_boolpts(slowBear, 3.0) + f_boolpts(emaBearStack, 2.0) + f_boolpts(liquidityVacuum, 7.0) + f_boolpts(cascadeSetup, 7.0) + f_boolpts(failedRetest, 4.0) + f_boolpts(compressionBreakdown, 5.0), 0.0, 39.0)

//──────────────────────────────────────────────────────────────────────────────
// SESSION VWAP / OBV DIVERGENCE
//──────────────────────────────────────────────────────────────────────────────
newDay = ta.change(time("D")) != 0
var float cumPV = na
var float cumVol = na

if newDay or na(cumPV) or na(cumVol)
    cumPV := hlc3 * volume
    cumVol := volume
else
    cumPV += hlc3 * volume
    cumVol += volume

sessionVWAP = cumVol > 0.0 ? cumPV / cumVol : hlc3

vwapCrossUnder = ta.crossunder(close, sessionVWAP)
vwapLost = enableVWAP and vwapCrossUnder
belowVWAP = enableVWAP and close < sessionVWAP
vwapPressure = belowVWAP and redCandle and (volZ >= zWarn or negativeDeltaZ >= zWarn)

obvStep = close > close[1] ? volume : close < close[1] ? -volume : 0.0
obv = ta.cum(obvStep)

obvHighestClosePrev = ta.highest(close, obvLen)[1]
obvHighestPrev = ta.highest(obv, obvLen)[1]
obvDivergence = not na(obvHighestClosePrev) and not na(obvHighestPrev) and close >= obvHighestClosePrev * 0.98 and obv < obvHighestPrev

flowDivergenceScore = f_clamp(f_boolpts(vwapLost, 3.0) + f_boolpts(vwapPressure, 5.0) + f_boolpts(obvDivergence, 5.0) + f_boolpts(obvDivergence and cvdBear, 3.0), 0.0, 16.0)

//──────────────────────────────────────────────────────────────────────────────
// HIGHER-TIMEFRAME STRESS
//──────────────────────────────────────────────────────────────────────────────
[htf1Close, htf1Ema] = request.security(syminfo.tickerid, htf1, [close, ta.ema(close, htfEmaLen)], barmerge.gaps_off, barmerge.lookahead_off)
[htf2Close, htf2Ema] = request.security(syminfo.tickerid, htf2, [close, ta.ema(close, htfEmaLen)], barmerge.gaps_off, barmerge.lookahead_off)
[htf3Close, htf3Ema] = request.security(syminfo.tickerid, htf3, [close, ta.ema(close, htfEmaLen)], barmerge.gaps_off, barmerge.lookahead_off)

htf1Bear = htf1Close < htf1Ema
htf2Bear = htf2Close < htf2Ema
htf3Bear = htf3Close < htf3Ema
htfBearCount = (htf1Bear ? 1 : 0) + (htf2Bear ? 1 : 0) + (htf3Bear ? 1 : 0)
htfScore = f_clamp(htfBearCount * 4.0, 0.0, 12.0)

//──────────────────────────────────────────────────────────────────────────────
// ETF BASKET
//──────────────────────────────────────────────────────────────────────────────
[e1o, e1c, e1v] = request.security(etfSymbol1, etfTf, [open, close, volume], barmerge.gaps_off, barmerge.lookahead_off, true)
[e2o, e2c, e2v] = request.security(etfSymbol2, etfTf, [open, close, volume], barmerge.gaps_off, barmerge.lookahead_off, true)
[e3o, e3c, e3v] = request.security(etfSymbol3, etfTf, [open, close, volume], barmerge.gaps_off, barmerge.lookahead_off, true)
[e4o, e4c, e4v] = request.security(etfSymbol4, etfTf, [open, close, volume], barmerge.gaps_off, barmerge.lookahead_off, true)
[e5o, e5c, e5v] = request.security(etfSymbol5, etfTf, [open, close, volume], barmerge.gaps_off, barmerge.lookahead_off, true)

r1 = f_ret(e1o, e1c)
r2 = f_ret(e2o, e2c)
r3 = f_ret(e3o, e3c)
r4 = f_ret(e4o, e4c)
r5 = f_ret(e5o, e5c)

c1 = f_valid(e1c) ? 1.0 : 0.0
c2 = f_valid(e2c) ? 1.0 : 0.0
c3 = f_valid(e3c) ? 1.0 : 0.0
c4 = f_valid(e4c) ? 1.0 : 0.0
c5 = f_valid(e5c) ? 1.0 : 0.0

etfCount = c1 + c2 + c3 + c4 + c5
etfRetAvg = etfCount > 0.0 ? (r1 + r2 + r3 + r4 + r5) / etfCount : 0.0

v1zRaw = f_z(e1v, etfVolLen)
v2zRaw = f_z(e2v, etfVolLen)
v3zRaw = f_z(e3v, etfVolLen)
v4zRaw = f_z(e4v, etfVolLen)
v5zRaw = f_z(e5v, etfVolLen)

v1z = f_valid(e1v) ? v1zRaw : 0.0
v2z = f_valid(e2v) ? v2zRaw : 0.0
v3z = f_valid(e3v) ? v3zRaw : 0.0
v4z = f_valid(e4v) ? v4zRaw : 0.0
v5z = f_valid(e5v) ? v5zRaw : 0.0

etfVolZAvg = etfCount > 0.0 ? (v1z + v2z + v3z + v4z + v5z) / etfCount : 0.0
etfBasketValid = enableETF and etfCount > 0.0
etfBasketRed = etfBasketValid and etfRetAvg < 0.0
etfBasketHeavyDrop = etfBasketValid and etfRetAvg <= -etfDropPct
etfBasketDistribution = etfBasketValid and etfBasketRed and etfVolZAvg >= zWarn
etfBearDivergence = etfDivergence and etfBasketDistribution and close >= close[1]

etfScore = f_clamp((etfBasketValid ? f_zpts(etfVolZAvg, zWarn, zCritical, 5.0) : 0.0) + f_boolpts(etfBasketDistribution, 5.0) + f_boolpts(etfBasketHeavyDrop, 4.0) + f_boolpts(etfBearDivergence, 5.0), 0.0, 19.0)

//──────────────────────────────────────────────────────────────────────────────
// MACRO / STABLECOIN / MINERS
//──────────────────────────────────────────────────────────────────────────────
vixClose = request.security(vixSymbol, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
dxyClose = request.security(dxySymbol, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
ndxClose = request.security(ndxSymbol, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)

vixRet = f_valid(vixClose) and f_valid(vixClose[1]) and vixClose[1] > 0.0 ? 100.0 * (vixClose - vixClose[1]) / vixClose[1] : 0.0
dxyRet = f_valid(dxyClose) and f_valid(dxyClose[1]) and dxyClose[1] > 0.0 ? 100.0 * (dxyClose - dxyClose[1]) / dxyClose[1] : 0.0
ndxRet = f_valid(ndxClose) and f_valid(ndxClose[1]) and ndxClose[1] > 0.0 ? 100.0 * (ndxClose - ndxClose[1]) / ndxClose[1] : 0.0

macroStress = enableMacro and ((vixRet > 3.0 ? 1 : 0) + (dxyRet > 0.35 ? 1 : 0) + (ndxRet < -1.25 ? 1 : 0) >= 2)
macroScore = enableMacro ? f_clamp(f_boolpts(vixRet > 3.0, 3.0) + f_boolpts(dxyRet > 0.35, 3.0) + f_boolpts(ndxRet < -1.25, 3.0) + f_boolpts(macroStress and redCandle, 3.0), 0.0, 12.0) : 0.0

stableClose = request.security(stableSymbol, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
stableZRaw = f_z(stableClose, stableLen)
stableRisingRaw = ta.rising(stableClose, 3)

stableZ = enableStable and f_valid(stableClose) ? stableZRaw : 0.0
stableRising = enableStable and f_valid(stableClose) and stableRisingRaw
stableRisk = enableStable and stableZ >= zWarn and stableRising
stableScore = enableStable ? f_clamp(f_zpts(stableZ, zWarn, zCritical, 5.0) + f_boolpts(stableRisk and redCandle, 4.0), 0.0, 9.0) : 0.0

m1c = request.security(miner1, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
m2c = request.security(miner2, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
m3c = request.security(miner3, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
m4c = request.security(miner4, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)

m1r = f_valid(m1c) and f_valid(m1c[1]) and m1c[1] > 0.0 ? 100.0 * (m1c - m1c[1]) / m1c[1] : 0.0
m2r = f_valid(m2c) and f_valid(m2c[1]) and m2c[1] > 0.0 ? 100.0 * (m2c - m2c[1]) / m2c[1] : 0.0
m3r = f_valid(m3c) and f_valid(m3c[1]) and m3c[1] > 0.0 ? 100.0 * (m3c - m3c[1]) / m3c[1] : 0.0
m4r = f_valid(m4c) and f_valid(m4c[1]) and m4c[1] > 0.0 ? 100.0 * (m4c - m4c[1]) / m4c[1] : 0.0

minerCount = (f_valid(m1c) ? 1.0 : 0.0) + (f_valid(m2c) ? 1.0 : 0.0) + (f_valid(m3c) ? 1.0 : 0.0) + (f_valid(m4c) ? 1.0 : 0.0)
minerRetAvg = minerCount > 0.0 ? (m1r + m2r + m3r + m4r) / minerCount : 0.0
minerStress = enableMiners and minerCount > 0.0 and minerRetAvg < -3.0
minerScore = enableMiners ? f_clamp(f_boolpts(minerRetAvg < -2.0, 3.0) + f_boolpts(minerStress, 5.0) + f_boolpts(minerStress and close < fastEma, 3.0), 0.0, 11.0) : 0.0

//──────────────────────────────────────────────────────────────────────────────
// MULTI-EXCHANGE / MARKET-CAP STRESS
//──────────────────────────────────────────────────────────────────────────────
ex1 = request.security(btcEx1, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, true)
ex2 = request.security(btcEx2, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, true)
ex3 = request.security(btcEx3, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off, true)

ex1v = f_valid(ex1)
ex2v = f_valid(ex2)
ex3v = f_valid(ex3)

exMax = math.max(ex1v ? ex1 : 0.0, math.max(ex2v ? ex2 : 0.0, ex3v ? ex3 : 0.0))
exMinRaw = math.min(ex1v ? ex1 : 100000000000.0, math.min(ex2v ? ex2 : 100000000000.0, ex3v ? ex3 : 100000000000.0))
exMin = exMinRaw == 100000000000.0 ? na : exMinRaw
exMid = not na(exMin) and exMax > 0.0 ? (exMax + exMin) * 0.5 : na
exchangeSpreadPct = not na(exMid) and exMid > 0.0 ? 100.0 * (exMax - exMin) / exMid : 0.0

exchangeDislocation = enableMarketStress and exchangeSpreadPct >= spreadWarnPct
exchangeCritical = enableMarketStress and exchangeSpreadPct >= spreadCriticalPct
exchangeScore = enableMarketStress ? f_clamp(f_boolpts(exchangeDislocation, 4.0) + f_boolpts(exchangeCritical, 5.0), 0.0, 9.0) : 0.0

btcDom = request.security(btcDomSymbol, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)
totalCap = request.security(totalCapSymbol, macroTf, close, barmerge.gaps_off, barmerge.lookahead_off, true)

btcDomZRaw = f_z(-btcDom, marketLen)
btcDomFallingRaw = ta.falling(btcDom, 3)

btcDomZ = enableMarketStress and f_valid(btcDom) ? btcDomZRaw : 0.0
btcDomFalling = enableMarketStress and f_valid(btcDom) and btcDomFallingRaw
btcDomStress = btcDomZ >= zWarn and btcDomFalling

totalCapRet = f_valid(totalCap) and f_valid(totalCap[1]) and totalCap[1] > 0.0 ? 100.0 * (totalCap - totalCap[1]) / totalCap[1] : 0.0
totalCapStress = enableMarketStress and totalCapRet < -2.0
marketCapCrash = enableMarketStress and totalCapRet < -5.0

dominanceCapScore = enableMarketStress ? f_clamp(f_zpts(btcDomZ, zWarn, zCritical, 4.0) + f_boolpts(btcDomStress and redCandle, 3.0) + f_boolpts(totalCapStress, 4.0) + f_boolpts(marketCapCrash, 4.0), 0.0, 15.0) : 0.0
marketStressScore = f_clamp(exchangeScore + dominanceCapScore, 0.0, 20.0)

//──────────────────────────────────────────────────────────────────────────────
// OPTIONAL EXTERNAL SOURCES
//──────────────────────────────────────────────────────────────────────────────
flowEffective = flowMode == "Negative = Sell Pressure" ? -flowSrc : flowSrc
flowZRaw = f_z(flowEffective, flowLen)
flowRisingRaw = ta.rising(flowEffective, flowRiseBars)

flowZ = enableFlow ? flowZRaw : 0.0
flowRising = enableFlow and flowRisingRaw
flowPressure = enableFlow and flowZ >= zWarn
flowCritical = enableFlow and flowZ >= zCritical
flowScore = f_clamp(f_zpts(flowZ, zWarn, zCritical, 7.0) + f_boolpts(flowRising, 3.0) + f_boolpts(flowPressure and redCandle, 3.0) + f_boolpts(flowCritical, 3.0), 0.0, 16.0)

oiZRaw = f_z(oiSrc, oiLen)
oiZ = enableOI ? oiZRaw : 0.0
oiElevated = enableOI and oiZ >= zWarn
oiCritical = enableOI and oiZ >= zCritical
oiBearCascade = oiElevated and supportBreak and redCandle
oiScore = f_clamp(f_zpts(oiZ, zWarn, zCritical, 5.0) + f_boolpts(oiBearCascade, 5.0) + f_boolpts(oiCritical and close < fastEma, 3.0), 0.0, 13.0)

//──────────────────────────────────────────────────────────────────────────────
// PANIC / KILL-SWITCH
//──────────────────────────────────────────────────────────────────────────────
panicScore = panicMode == "Critical" ? panicWeight : panicMode == "Active" ? panicWeight * 0.66 : panicMode == "Watch" ? panicWeight * 0.33 : 0.0
killScore = killSwitch ? 12.0 : 0.0

//──────────────────────────────────────────────────────────────────────────────
// CONFLUENCE / FINAL SCORE
//──────────────────────────────────────────────────────────────────────────────
btcLooksStable = close >= fastEma or close >= close[1]
institutionWeak = etfBasketDistribution or macroStress or minerStress or totalCapStress
institutionalTrap = btcLooksStable and institutionWeak and (absorption or distributionNearHigh or sweepDistribution)

confluenceA = supportBreak and (etfBasketDistribution or flowPressure or oiBearCascade)
confluenceB = htfBearCount >= 2 and (liquidityVacuum or cascadeSetup)
confluenceC = absorption and nearLocalHigh and negativeDeltaZ >= zWarn
confluenceD = etfBearDivergence and close < fastEma
confluenceE = institutionalTrap
confluenceF = macroStress and stableRisk and redCandle
confluenceG = vwapPressure and obvDivergence
confluenceH = compressionBreakdown and htfBearCount >= 1
confluenceI = exchangeCritical and redCandle
confluenceJ = totalCapStress and btcDomStress

confluenceBonus = f_boolpts(confluenceA, 5.0) + f_boolpts(confluenceB, 5.0) + f_boolpts(confluenceC, 4.0) + f_boolpts(confluenceD, 3.0) + f_boolpts(confluenceE, 5.0) + f_boolpts(confluenceF, 4.0) + f_boolpts(confluenceG, 4.0) + f_boolpts(confluenceH, 4.0) + f_boolpts(confluenceI, 4.0) + f_boolpts(confluenceJ, 4.0)

regimeBear = slowBear and htfBearCount >= 1
regimeHighVol = atrRatio >= 1.20
regimeCompression = compression and not regimeHighVol
regimeMultiplier = autoRegimeWeighting ? regimeBear and regimeHighVol ? 1.08 : regimeBear ? 1.04 : regimeCompression ? 0.96 : 1.00 : 1.00

rawScore = coreScore + deltaScore + absorbScore + structureScore + flowDivergenceScore + htfScore + etfScore + macroScore + stableScore + minerScore + marketStressScore + flowScore + oiScore + panicScore + killScore
scoreBeforeMemory = f_clamp((rawScore + confluenceBonus) * regimeMultiplier, 0.0, 100.0)
memoryScore = ta.ema(scoreBeforeMemory, riskMemoryLen)
scoreMixed = scoreBeforeMemory * (1.0 - riskMemoryWeight) + memoryScore * riskMemoryWeight
scoreBeforeSmooth = f_clamp(scoreMixed, 0.0, 100.0)
totalScoreEma = ta.ema(scoreBeforeSmooth, scoreSmoothLen)
totalScore = scoreSmoothLen <= 1 ? scoreBeforeSmooth : totalScoreEma

sensitivityShift = sensitivity == "Conservative" ? 5.0 : sensitivity == "Aggressive" ? -5.0 : 0.0
volShift = useAdaptive ? f_clamp((atrRatio - 1.0) * 8.0, -4.0, 8.0) : 0.0

watchT = f_clamp(watchLevel + sensitivityShift - volShift, 5.0, 95.0)
warningT = f_clamp(warningLevel + sensitivityShift - volShift, 10.0, 98.0)
criticalT = f_clamp(criticalLevel + sensitivityShift - volShift, 15.0, 99.0)
cascadeT = f_clamp(cascadeLevel + sensitivityShift - volShift, 20.0, 100.0)

phase = totalScore < watchT ? 0 : (cascadeSetup or (liquidityVacuum and supportBreak)) ? 3 : (supportBreak or compressionBreakdown) ? 2 : (absorption or distributionNearHigh or institutionalTrap or sweepDistribution) ? 1 : totalScore >= warningT and not supportBreak ? 1 : 0
resetWatch = totalScore >= criticalT and close > fastEma and close > sessionVWAP and not supportBreak
phaseFinal = resetWatch ? 4 : phase

cascadeConfirmedRaw = totalScore >= cascadeT and cascadeSetup and htfBearCount >= 1
rawState = cascadeConfirmedRaw ? 4 : totalScore >= criticalT ? 3 : totalScore >= warningT ? 2 : totalScore >= watchT ? 1 : 0

var int state = 0
prevPersistentState = nz(state[1], 0)
exitThreshold = prevPersistentState == 4 ? cascadeT - hysteresisGap : prevPersistentState == 3 ? criticalT - hysteresisGap : prevPersistentState == 2 ? warningT - hysteresisGap : prevPersistentState == 1 ? watchT - hysteresisGap : 0.0

if rawState > prevPersistentState
    state := rawState
else
    state := totalScore < exitThreshold ? rawState : prevPersistentState

cascadeConfirmed = state == 4
prevState = nz(state[1], 0)
stateUpgraded = state > prevState

watchSignalRaw = state == 1 and prevState < 1
warningSignalRaw = state == 2 and prevState < 2
criticalSignalRaw = state == 3 and prevState < 3
cascadeSignalRaw = state == 4 and prevState < 4

signalGrade = f_grade(totalScore, cascadeConfirmed, htfBearCount, supportBreak)
riskInvalidated = prevState >= 2 and close > fastEma and close > sessionVWAP and totalScore < warningT and not supportBreak

var int lastLabelBar = na
cooldownOk = labelCooldown == 0 or na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldown

watchSignal = watchSignalRaw and cooldownOk
warningSignal = warningSignalRaw and cooldownOk
criticalSignal = criticalSignalRaw and cooldownOk
cascadeSignal = cascadeSignalRaw and cooldownOk

if showLabels and cooldownOk and (watchSignalRaw or warningSignalRaw or criticalSignalRaw or cascadeSignalRaw) and barstate.isconfirmed
    lastLabelBar := bar_index

//──────────────────────────────────────────────────────────────────────────────
// EDUCATIONAL SIGNAL TOOLTIP LABELS
//──────────────────────────────────────────────────────────────────────────────
if showLabels and watchSignal and barstate.isconfirmed
    tipWatch = "WATCH Signal\n\nMeaning:\nThe sell-pressure score moved above the WATCH threshold.\n\nThis is an early warning only. It does not mean a confirmed sell event.\n\nCurrent score: " + str.tostring(totalScore, "#.##") + " / 100\nPhase: " + f_phaseText(phaseFinal) + "\nInstruction: " + f_finalInstruction(state)
    lb = label.new(bar_index, high + atr * 0.65, "WATCH", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(color.yellow, 0), textcolor = color.black, size = size.tiny, tooltip = tipWatch)
    array.push(signalTooltipLabels, lb)
    f_trimSignalLabels()

if showLabels and warningSignal and barstate.isconfirmed
    tipWarning = "SELL WARNING\n\nMeaning:\nThe engine detected elevated sell-pressure conditions.\n\nUse this as caution, not automatic short entry.\n\nConfirmation to watch:\n- Structure score rising\n- Support / Vacuum = YES / YES\n- HTF Bears 2/3 or 3/3\n- OBV Div / CVD Bear = YES / YES\n\nCurrent score: " + str.tostring(totalScore, "#.##") + " / 100\nGrade: " + signalGrade + "\nPhase: " + f_phaseText(phaseFinal)
    lb = label.new(bar_index, high + atr * 0.95, "SELL\nWARN", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white, size = size.small, tooltip = tipWarning)
    array.push(signalTooltipLabels, lb)
    f_trimSignalLabels()

if showLabels and criticalSignal and barstate.isconfirmed
    tipCritical = "CRITICAL Risk Signal\n\nMeaning:\nThe sell-pressure score reached the critical zone.\n\nThis means risk is high, but the strongest confirmation still requires cascade/structure confirmation.\n\nCurrent score: " + str.tostring(totalScore, "#.##") + " / 100\nGrade: " + signalGrade + "\nPhase: " + f_phaseText(phaseFinal) + "\nSupport Break: " + f_yesNo(supportBreak) + "\nLiquidity Vacuum: " + f_yesNo(liquidityVacuum)
    lb = label.new(bar_index, high + atr * 1.15, "CRITICAL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.normal, tooltip = tipCritical)
    array.push(signalTooltipLabels, lb)
    f_trimSignalLabels()

if showLabels and cascadeSignal and barstate.isconfirmed
    tipCascade = "CASCADE Signal\n\nMeaning:\nThe engine detected a confirmed cascade-risk condition.\n\nThis is the strongest warning type.\n\nBest confirmation:\nCASCADE + Grade A/A+ + Phase 3 Liquidation.\n\nCurrent score: " + str.tostring(totalScore, "#.##") + " / 100\nGrade: " + signalGrade + "\nPhase: " + f_phaseText(phaseFinal) + "\nHTF Bears: " + str.tostring(htfBearCount) + " / 3\nSupport Break: " + f_yesNo(supportBreak) + "\nLiquidity Vacuum: " + f_yesNo(liquidityVacuum)
    lb = label.new(bar_index, high + atr * 1.35, "CASCADE", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(color.maroon, 0), textcolor = color.white, size = size.large, tooltip = tipCascade)
    array.push(signalTooltipLabels, lb)
    f_trimSignalLabels()

if showLabels and riskInvalidated and barstate.isconfirmed
    tipInvalid = "Risk Invalidated\n\nMeaning:\nPrevious sell-pressure risk weakened because price recovered above important references.\n\nThis does not guarantee a new bull trend. It only means the previous sell-risk setup has weakened.\n\nCurrent score: " + str.tostring(totalScore, "#.##") + " / 100\nPrice above Fast EMA: " + f_yesNo(close > fastEma) + "\nPrice above Session VWAP: " + f_yesNo(close > sessionVWAP) + "\nSupport Break: " + f_yesNo(supportBreak)
    lb = label.new(bar_index, low - atr * 0.75, "RISK\nINVALID", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(color.green, 0), textcolor = color.white, size = size.small, tooltip = tipInvalid)
    array.push(signalTooltipLabels, lb)
    f_trimSignalLabels()

//──────────────────────────────────────────────────────────────────────────────
// CASCADE TARGETS
//──────────────────────────────────────────────────────────────────────────────
var line t1Line = na
var line t2Line = na
var line t3Line = na
var line t4Line = na
var label t1Lab = na
var label t2Lab = na
var label t3Lab = na
var label t4Lab = na

target1 = close - atr * 3.0
target2 = close - atr * 6.0
target3 = close - atr * 10.0
target4 = close - atr * 16.0

if showTargets and cascadeSignalRaw and cascadeConfirmed
    if not na(t1Line)
        line.delete(t1Line)
    if not na(t2Line)
        line.delete(t2Line)
    if not na(t3Line)
        line.delete(t3Line)
    if not na(t4Line)
        line.delete(t4Line)
    if not na(t1Lab)
        label.delete(t1Lab)
    if not na(t2Lab)
        label.delete(t2Lab)
    if not na(t3Lab)
        label.delete(t3Lab)
    if not na(t4Lab)
        label.delete(t4Lab)

    t1Line := line.new(bar_index, target1, bar_index + 120, target1, xloc = xloc.bar_index, color = color.new(color.red, 0), style = line.style_dashed, width = 1)
    t2Line := line.new(bar_index, target2, bar_index + 120, target2, xloc = xloc.bar_index, color = color.new(color.maroon, 0), style = line.style_dashed, width = 1)
    t3Line := line.new(bar_index, target3, bar_index + 120, target3, xloc = xloc.bar_index, color = color.new(color.black, 0), style = line.style_dashed, width = 2)
    t4Line := line.new(bar_index, target4, bar_index + 120, target4, xloc = xloc.bar_index, color = color.new(color.purple, 0), style = line.style_dotted, width = 2)

    t1Lab := label.new(bar_index + 120, target1, "Cascade T1", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.red, 0), textcolor = color.white, tooltip = "Cascade Target 1\n\nFirst volatility-based downside risk target after a cascade signal.\nFormula: close - 3 ATR.\n\nThis is not a guaranteed prediction. It is a risk projection used only after cascade pressure appears.")
    t2Lab := label.new(bar_index + 120, target2, "Cascade T2", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.maroon, 0), textcolor = color.white, tooltip = "Cascade Target 2\n\nSecond volatility-based downside risk target after a cascade signal.\nFormula: close - 6 ATR.\n\nUsed for deeper liquidation-risk awareness.")
    t3Lab := label.new(bar_index + 120, target3, "Cascade T3", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 0), textcolor = color.white, tooltip = "Cascade Target 3\n\nThird volatility-based downside risk target after a cascade signal.\nFormula: close - 10 ATR.\n\nRepresents severe sell-pressure projection.")
    t4Lab := label.new(bar_index + 120, target4, "Cascade T4 Extreme", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.purple, 0), textcolor = color.white, tooltip = "Cascade Target 4 Extreme\n\nExtreme volatility-based downside target.\nFormula: close - 16 ATR.\n\nUse only during major liquidation environments.")

targetsShouldStay = showTargets and (cascadeConfirmed or keepHistoricalCascadeTargets)

if targetsShouldStay and not na(t1Line)
    line.set_x2(t1Line, bar_index + 120)
    line.set_x2(t2Line, bar_index + 120)
    line.set_x2(t3Line, bar_index + 120)
    line.set_x2(t4Line, bar_index + 120)

    label.set_x(t1Lab, bar_index + 120)
    label.set_x(t2Lab, bar_index + 120)
    label.set_x(t3Lab, bar_index + 120)
    label.set_x(t4Lab, bar_index + 120)

    targetPrefix = cascadeConfirmed ? "Cascade" : "Old Cascade"
    label.set_text(t1Lab, targetPrefix + " T1")
    label.set_text(t2Lab, targetPrefix + " T2")
    label.set_text(t3Lab, targetPrefix + " T3")
    label.set_text(t4Lab, targetPrefix + " T4")

if not targetsShouldStay and not na(t1Line)
    line.delete(t1Line)
    line.delete(t2Line)
    line.delete(t3Line)
    line.delete(t4Line)
    label.delete(t1Lab)
    label.delete(t2Lab)
    label.delete(t3Lab)
    label.delete(t4Lab)

    t1Line := na
    t2Line := na
    t3Line := na
    t4Line := na
    t1Lab := na
    t2Lab := na
    t3Lab := na
    t4Lab := na

//──────────────────────────────────────────────────────────────────────────────
// VISUALS
//──────────────────────────────────────────────────────────────────────────────
stateCol = f_stateColor(state)
riskBg = state == 4 ? color.new(color.maroon, 82) : state == 3 ? color.new(color.red, 86) : state == 2 ? color.new(color.orange, 88) : state == 1 ? color.new(color.yellow, 91) : na
bgcolor(showBg ? riskBg : na)

barCol = state == 4 ? color.maroon : state == 3 ? color.red : state == 2 ? color.orange : state == 1 ? color.yellow : na
barcolor(colorBars ? barCol : na)

plot(showEMAs ? fastEma : na, "Fast EMA", color = color.new(color.aqua, 0), linewidth = 1)
plot(showEMAs ? slowEma : na, "Slow EMA", color = close < slowEma ? color.new(color.red, 0) : color.new(color.teal, 0), linewidth = 2)
plot(showSupport ? priorSupport : na, "Prior Support", color = supportBreak ? color.new(color.red, 0) : color.new(color.gray, 40), linewidth = 1, style = plot.style_linebr)
plot(showVWAP and enableVWAP ? sessionVWAP : na, "Session VWAP", color = belowVWAP ? color.new(color.red, 0) : color.new(color.blue, 0), linewidth = 1)
plot(totalScore, "Systemic Sell Pressure Score", color = stateCol, linewidth = 2, display = display.none)

//──────────────────────────────────────────────────────────────────────────────
// MAIN OPEN-SOURCE HELP LABEL
//──────────────────────────────────────────────────────────────────────────────
var label mainHelpLabel = na

if showUserHelp and barstate.islast
    helpText =
      "BTC Sell Pressure V5.5 Final\n\n" +
      "Purpose:\n" +
      "This indicator is a synthetic Bitcoin sell-pressure monitor. It does not read private whale wallets directly. It watches market behavior that often appears when large selling pressure is building.\n\n" +
      "Main modules:\n" +
      "1. Core volume and dollar-volume anomaly.\n" +
      "2. Synthetic Delta and CVD pressure.\n" +
      "3. Hidden distribution, absorption, failed breakouts, and sweep traps.\n" +
      "4. Support breaks and liquidity-vacuum breakdowns.\n" +
      "5. Session VWAP loss and OBV divergence.\n" +
      "6. ETF basket proxy: IBIT, FBTC, GBTC, BITB, ARKB.\n" +
      "7. Macro proxy: VIX, DXY, NDX.\n" +
      "8. Stablecoin dominance and miner stress.\n" +
      "9. BTC exchange spread, BTC dominance, and total crypto market-cap stress.\n\n" +
      "Current state:\n" +
      "State: " + f_stateText(state) + "\n" +
      "Phase: " + f_phaseText(phaseFinal) + "\n" +
      "Grade: " + signalGrade + "\n" +
      "Score: " + str.tostring(totalScore, "#.##") + " / 100\n" +
      "Final instruction: " + f_finalInstruction(state) + "\n\n" +
      "Score guide:\n" +
      "0-34 = Normal\n" +
      "35-54 = Watch\n" +
      "55-74 = Warning\n" +
      "75-87 = Critical\n" +
      "88+ = Cascade risk\n\n" +
      "Strongest warning:\n" +
      "CASCADE + Grade A/A+ + Phase 3 Liquidation.\n\n" +
      "Recommended use:\n" +
      "3m / 15m = short-term pressure warning.\n" +
      "4H = early serious warning.\n" +
      "1D = confirmation.\n" +
      "1W = macro confirmation.\n\n" +
      "Do not trade WATCH alone. Use this as a risk dashboard and confirmation tool."

    helpX = bar_index + helpOffsetBars
    helpY = high + atr * 2.5

    if na(mainHelpLabel)
        mainHelpLabel := label.new(helpX, helpY, "HELP", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.blue, 0), textcolor = color.white, size = size.small, tooltip = helpText)
    else
        label.set_x(mainHelpLabel, helpX)
        label.set_y(mainHelpLabel, helpY)
        label.set_text(mainHelpLabel, "HELP")
        label.set_tooltip(mainHelpLabel, helpText)
        label.set_color(mainHelpLabel, color.new(color.blue, 0))
        label.set_textcolor(mainHelpLabel, color.white)

if not showUserHelp and not na(mainHelpLabel)
    label.delete(mainHelpLabel)
    mainHelpLabel := na

//──────────────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 29, border_width = 1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "BTC Sell Pressure V5.5", bgcolor = color.new(color.black, 0), text_color = color.white)
    table.cell(dash, 1, 0, f_stateText(state) + " " + signalGrade, bgcolor = stateCol, text_color = color.white)
    table.cell(dash, 0, 1, "Phase", bgcolor = color.new(color.black, 75), text_color = color.white)
    table.cell(dash, 1, 1, f_phaseText(phaseFinal), bgcolor = phaseFinal == 4 ? color.new(color.green, 20) : phaseFinal == 3 ? color.new(color.maroon, 0) : phaseFinal == 2 ? color.new(color.red, 30) : phaseFinal == 1 ? color.new(color.orange, 35) : color.new(color.black, 75), text_color = color.white)
    table.cell(dash, 0, 2, "Total Score", bgcolor = color.new(color.black, 75), text_color = color.white)
    table.cell(dash, 1, 2, str.tostring(totalScore, "#.##") + " / 100", bgcolor = color.new(stateCol, 70), text_color = color.white)
    table.cell(dash, 0, 3, "Thresholds W/W/C/X", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 3, str.tostring(watchT, "#") + "/" + str.tostring(warningT, "#") + "/" + str.tostring(criticalT, "#") + "/" + str.tostring(cascadeT, "#"), bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 4, "Core", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 4, str.tostring(coreScore, "#.##") + " / 22", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 5, "Delta / CVD", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 5, str.tostring(deltaScore, "#.##") + " / 20", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 6, "Distribution", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 6, str.tostring(absorbScore, "#.##") + " / 22", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 7, "Structure", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 7, str.tostring(structureScore, "#.##") + " / 39", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 8, "VWAP/OBV", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 8, str.tostring(flowDivergenceScore, "#.##") + " / 16", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 9, "HTF Bears", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 9, str.tostring(htfBearCount) + " / 3", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 10, "ETF Basket", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 10, enableETF ? str.tostring(etfScore, "#.##") + " / 19" : "OFF", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 11, "ETF Avg %", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 11, str.tostring(etfRetAvg, "#.##") + "%", bgcolor = etfRetAvg < 0 ? color.new(color.red, 80) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 12, "Macro", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 12, enableMacro ? str.tostring(macroScore, "#.##") + " / 12" : "OFF", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 13, "Stablecoin", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 13, enableStable ? str.tostring(stableScore, "#.##") + " / 9" : "OFF", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 14, "Miners", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 14, enableMiners ? str.tostring(minerScore, "#.##") + " / 11" : "OFF", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 15, "Market Stress", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 15, enableMarketStress ? str.tostring(marketStressScore, "#.##") + " / 20" : "OFF", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 16, "Exchange Spread", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 16, str.tostring(exchangeSpreadPct, "#.###") + "%", bgcolor = exchangeCritical ? color.new(color.red, 25) : exchangeDislocation ? color.new(color.orange, 40) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 17, "BTC.D / TOTAL", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 17, f_yesNo(btcDomStress) + " / " + str.tostring(totalCapRet, "#.##") + "%", bgcolor = btcDomStress or totalCapStress ? color.new(color.red, 35) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 18, "Ext Flow / OI", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 18, str.tostring(flowScore, "#.##") + " / " + str.tostring(oiScore, "#.##"), bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 19, "Institution Trap", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 19, f_yesNo(institutionalTrap), bgcolor = institutionalTrap ? color.new(color.red, 35) : color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 20, "Sweep Up", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 20, f_yesNo(sweepDistribution), bgcolor = sweepDistribution ? color.new(color.orange, 25) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 21, "VWAP Pressure", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 21, f_yesNo(vwapPressure), bgcolor = vwapPressure ? color.new(color.red, 30) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 22, "OBV Div / CVD Bear", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 22, f_yesNo(obvDivergence) + " / " + f_yesNo(cvdBear), bgcolor = obvDivergence or cvdBear ? color.new(color.red, 35) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 23, "Compression Break", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 23, f_yesNo(compressionBreakdown), bgcolor = compressionBreakdown ? color.new(color.red, 25) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 24, "Panic / Kill", bgcolor = color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 1, 24, panicMode + (killSwitch ? " + KILL" : ""), bgcolor = killSwitch or panicMode != "Off" ? color.new(color.red, 55) : color.new(color.black, 86), text_color = color.white)
    table.cell(dash, 0, 25, "Support / Vacuum", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 25, f_yesNo(supportBreak) + " / " + f_yesNo(liquidityVacuum), bgcolor = supportBreak or liquidityVacuum ? color.new(color.red, 25) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 26, "Invalidation", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 26, f_yesNo(riskInvalidated), bgcolor = riskInvalidated ? color.new(color.green, 20) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 27, "Cascade", bgcolor = color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 1, 27, f_yesNo(cascadeConfirmed), bgcolor = cascadeConfirmed ? color.new(color.maroon, 0) : color.new(color.black, 90), text_color = color.white)
    table.cell(dash, 0, 28, "Final Instruction", bgcolor = color.new(color.black, 0), text_color = color.white)
    table.cell(dash, 1, 28, f_finalInstruction(state), bgcolor = stateCol, text_color = color.white)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertcondition(watchSignalRaw, title = "BTC Sell Pressure Watch", message = "BTC Sell Pressure V5.5: WATCH state triggered.")
alertcondition(warningSignalRaw, title = "BTC Sell Pressure Warning", message = "BTC Sell Pressure V5.5: WARNING state triggered.")
alertcondition(criticalSignalRaw, title = "BTC Sell Pressure Critical", message = "BTC Sell Pressure V5.5: CRITICAL state triggered.")
alertcondition(cascadeSignalRaw, title = "BTC Sell Pressure Cascade", message = "BTC Sell Pressure V5.5: CASCADE risk triggered.")
alertcondition(institutionalTrap, title = "BTC Institutional Trap", message = "BTC Sell Pressure V5.5: Institutional trap condition detected.")
alertcondition(sweepDistribution, title = "BTC Liquidity Sweep Distribution", message = "BTC Sell Pressure V5.5: Failed upside sweep with distribution pressure detected.")
alertcondition(compressionBreakdown, title = "BTC Compression Breakdown", message = "BTC Sell Pressure V5.5: Compression-to-breakdown condition detected.")
alertcondition(exchangeCritical, title = "BTC Exchange Dislocation Critical", message = "BTC Sell Pressure V5.5: Critical BTC exchange-price dislocation detected.")
alertcondition(riskInvalidated, title = "BTC Sell Risk Invalidated", message = "BTC Sell Pressure V5.5: Risk invalidation condition detected.")

canAlert = alertsOnClose ? barstate.isconfirmed : true

if enableJsonAlerts and canAlert and stateUpgraded
    msg = '{"indicator":"BTC Sell Pressure V5.5","symbol":"' + syminfo.ticker + '","state":"' + f_stateText(state) + '","phase":"' + f_phaseText(phaseFinal) + '","grade":"' + signalGrade + '","score":' + str.tostring(totalScore, "#.##") + ',"core":' + str.tostring(coreScore, "#.##") + ',"delta_cvd":' + str.tostring(deltaScore, "#.##") + ',"distribution":' + str.tostring(absorbScore, "#.##") + ',"structure":' + str.tostring(structureScore, "#.##") + ',"vwap_obv":' + str.tostring(flowDivergenceScore, "#.##") + ',"htf_bears":' + str.tostring(htfBearCount) + ',"etf":' + str.tostring(etfScore, "#.##") + ',"macro":' + str.tostring(macroScore, "#.##") + ',"stablecoin":' + str.tostring(stableScore, "#.##") + ',"miners":' + str.tostring(minerScore, "#.##") + ',"market_stress":' + str.tostring(marketStressScore, "#.##") + ',"exchange_spread_pct":' + str.tostring(exchangeSpreadPct, "#.###") + ',"btc_dominance_stress":' + str.tostring(btcDomStress) + ',"total_cap_return":' + str.tostring(totalCapRet, "#.##") + ',"flow":' + str.tostring(flowScore, "#.##") + ',"oi":' + str.tostring(oiScore, "#.##") + ',"institutional_trap":' + str.tostring(institutionalTrap) + ',"sweep_distribution":' + str.tostring(sweepDistribution) + ',"compression_breakdown":' + str.tostring(compressionBreakdown) + ',"vwap_pressure":' + str.tostring(vwapPressure) + ',"obv_divergence":' + str.tostring(obvDivergence) + ',"panic":"' + panicMode + '","kill_switch":' + str.tostring(killSwitch) + ',"support_break":' + str.tostring(supportBreak) + ',"liquidity_vacuum":' + str.tostring(liquidityVacuum) + ',"risk_invalidated":' + str.tostring(riskInvalidated) + ',"cascade":' + str.tostring(cascadeConfirmed) + '}'
    alert(msg, alert.freq_once_per_bar_close)
````
