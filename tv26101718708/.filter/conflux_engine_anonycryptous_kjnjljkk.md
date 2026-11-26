# Conflux Engine | Anonycryptous

- url: https://www.tradingview.com/script/KJnJLJkk-Conflux-Engine-Anonycryptous/
- type: indicator
- pine_id: PUB;7fdce56398dd411e9f237d6ce5439c7b
- version: 1.0

## Description

Conflux Engine | Anonycryptous
Description & user manual

Why this indicator is different?
Most signal indicators work the same way. One condition triggers. One signal fires. The trader either takes it or does not.
The problem is that a single condition — a crossover, a level break, a momentum read — is almost never enough to define a genuinely high-quality trade. Markets are too complex and too noisy for that.
Conflux Engine works differently.
It does not fire on one condition. It requires multiple independent market forces to align simultaneously before a signal appears. Structure has to agree. Volume has to confirm. Momentum has to support. Volatility has to be in the right zone. Session positioning has to be favorable. And optionally, the higher timeframe trend and the ribbon have to be aligned too.
Only when enough of these forces agree — and agree clearly — does the indicator produce a signal.
This is what confluence means in practice. Not one thing being right. Multiple independent things being right at the same time.
The result is fewer signals. But the signals that do appear carry more weight than anything a single-condition system can produce.

Important notice
Conflux Engine generates trading signals based on a multi-factor scoring engine.
These signals are not financial advice.
They do not predict the future.
They do not guarantee profitability.
They are a systematic read of current market conditions across multiple dimensions.
All trading decisions are made entirely by the user.
Always manage your own risk. Always apply your own judgment.

1. Overview
Conflux Engine is a scoring-based signal indicator for traders who want structured, high-conviction entries rather than frequent, noisy ones.
Six independent pillars evaluate the market continuously. Each pillar scores independently. The scores combine into a total out of 100. When the total exceeds the signal threshold — and the dominant direction leads the opposite direction by a minimum gap — a signal fires.
Additional hard gates can be enabled: an ADX noise filter to block signals during choppy markets, a VWMA filter to ensure macro trend alignment, a Supertrend filter for dynamic trend confirmation, and an Ultra Ribbon filter using 15 Hull Moving Averages for the fastest momentum read.
The result is an indicator that is selective by design. It is not built to fire constantly. It is built to fire well.

2. The six pillars
2.1 Structure
Evaluates market structure using swing pivot highs and lows. A higher high combined with a higher low defines a bullish structure. A lower high combined with a lower low defines a bearish structure.
This pillar answers the most fundamental question in trading: is the market making progress in a direction, or is it deteriorating?
Weight: up to 16 points.

2.2 Volume
Uses OBV slope via linear regression to determine whether volume is accumulating in the direction of price or diverging from it.
Rising OBV slope on a bullish signal means participation supports the move. Falling OBV slope on a bullish signal is a warning. This pillar separates moves with institutional backing from moves without it.
Weight: up to 16 points.

2.3 Momentum
Evaluates three independent momentum reads: KAMA position (a Kaufman adaptive moving average that adjusts its speed to market conditions), RSI relative to the 50 midline with slope direction, and Williams %R for price positioning within the recent range.
Two of three aligned scores partial points. All three aligned scores full points.
Weight: up to 16 points.

2.4 Liquidity
Detects sweep events — moments where price wicks beyond a recent swing high or low and closes back inside. These events mark liquidity grabs and often precede directional moves.
A confirmed bull sweep sets up a long bias context. A confirmed bear sweep sets up a short bias context. The context remains active for a configurable number of bars, decaying over time.
Weight: up to 16 points.

2.5 Volatility
Measures ATR relative to its own moving average to identify the volatility sweet spot. Signals during dead, flat markets carry less meaning. Signals during chaotically explosive moves are harder to execute cleanly. This pillar rewards the in-between: active, directional, manageable volatility.
Weight: up to 16 points.

2.6 Session
Evaluates price positioning within the current day's developing range. Price in the lower portion of the range (discount) favors long bias. Price in the upper portion (premium) favors short bias.
This pillar can be toggled independently from the session time filter — you can use session scoring without restricting signals to specific hours, or vice versa.
Weight: up to 20 points.

3. Hard gates
Beyond the six scoring pillars, Conflux Engine includes four optional hard gates. These do not add points. They block signals entirely when their condition is not met.

3.1 ADX noise filter
Blocks signals when ADX is below a configurable threshold. ADX measures trend strength. A low ADX means the market is ranging and directionless — exactly the environment where momentum signals fail most often. Default threshold: 35. Adjustable up to 100 for maximum selectivity.

3.2 VWMA filter
Price must be above the Volume Weighted Moving Average for long signals, and below it for short signals. The VWMA is slower than a standard EMA and reflects the average price weighted by volume — a more meaningful macro reference than a simple average. Default length: 200.

3.3 Supertrend filter
The Supertrend must confirm the signal direction. This is a dynamic trend line based on ATR bands that flips cleanly between bull and bear states. It acts as an additional structural confirmation that the trend environment supports the entry.

3.4 Ultra Ribbon filter
The fastest gate. Built from 15 Hull Moving Averages spanning a range of lengths. When the fastest HMA is above the slowest HMA, the ribbon is bullish. When below, bearish. Because Hull MAs minimize lag, this gate reacts to trend changes earlier than most moving average systems.
The ribbon also serves as a trailing stop option in the backtest — the slowest HMA tracks trend without being too reactive.

4. Signal scoring
Every bar, both a bullish and bearish score are computed from the six pillars. The scores are added together.
A signal fires when:
- The dominant score meets or exceeds the signal threshold (default 70)
- The dominant score exceeds the opposite score by at least the directional lead (default 20)
- All enabled hard gates are cleared
This two-condition check — threshold plus gap — prevents marginal signals from appearing when the market is ambiguous. Both bull and bear can score reasonably high during mixed conditions. The gap requirement ensures the dominant direction is meaningfully ahead.
Pillar weights are individually adjustable. The system allows traders to prioritize the factors most relevant to their trading style and instrument.
The Extreme Threshold (default 90) flags signals where the confluence score is exceptionally high. These are the highest-conviction setups in the system.

5. The Ultra Ribbon
The Ultra Ribbon is a 15-layer Hull Moving Average ribbon that sits on the chart as both a visual trend tool and a momentum gate. Three themes are available:
Classic — green and red. Clear, functional, no ambiguity.
Phantom — cyan and pink with purple exhaustion. A darker, stylized read of the same data. (the default)
Custom — full color control for bull, bear, and exhaustion states.
The ribbon color adapts dynamically. When the spread between the fastest and slowest HMA is wide relative to its historical average, the ribbon fades toward the exhaustion color — a visual signal that the trend may be overextended. When the spread is moderate, the ribbon shows its full trend color.
Candle coloring follows the ribbon's bull/bear state continuously, giving an immediate read of trend direction on every bar.
The dashboard accent color and signal indicators follow the active theme, giving the entire indicator a unified visual identity across chart and panel.

6. Multi-timeframe filter
When enabled, the MTF filter evaluates the trend on a higher timeframe using a 50-period EMA. If the higher timeframe trend agrees with the signal direction, a weight bonus is added to the total score. If it disagrees, no bonus is added — but the signal is not blocked unless the score falls below threshold as a result.
This behavior is intentional. The HTF filter adds weight to aligned signals without making every counter-trend setup impossible. It rewards confluence with the bigger picture without enforcing hard alignment.
Default timeframe: 240 (4-hour).
Default weight bonus: 20 points.

7. Backtest and performance tracking
Confluence Engine includes a built-in performance tracker that logs every signal, applies configurable stop and target multipliers based on the current regime, and tracks wins, losses, and win rate across the visible history.
Stop loss modes:
- ATR — a fixed multiple of ATR from the entry price. Simple and consistent.
- Pivot — stop placed at the most recent swing low (for longs) or swing high (for shorts). Respects structure.
- Supertrend — stop placed at the dynamic Supertrend level at the time of entry. Tighter and adaptive.
- Trailing (h15) — stop follows the slowest HMA of the Ultra Ribbon. Trends with the market and gives winners more room.
Target multipliers are adjustable for each regime: Scalp, Intraday, and Swing. The regime is determined by the current ADX value.
Recent log shows the last three trade results in R multiples. This gives a quick read on recent system performance without requiring a separate journaling tool.
Note: the backtest uses bar close logic and approximated fill prices. It is a directional performance reference, not a precise simulation. Session filtering does not retroactively apply to historical trades — enabling session filtering after a test period will affect forward signals but not past performance data.

8. Dashboard reference
The dashboard updates on every bar and shows:
- Header: indicator name and current timeframe
- Pillar rows 1–6: score per pillar, colored by direction
- HTF Trend: higher timeframe alignment and weight (when MTF enabled)
- Signal: LONG / SHORT / WAIT with direction color
- Win Rate: percentage of tracked signals that hit target
- Recent Log: last three results in R multiples
- Score: total confluence score out of 100
- Session: OPEN or FILTERED
The dashboard header and accent colors follow the active ribbon theme. 
Tiny, Small, and Normal size options are available.

9. Settings reference
General Settings
- Signal Threshold: minimum score to trigger a signal (50–95, default 70)
- Extreme Threshold: score above which extreme confluence is flagged (80–100, default 90)
- Directional Lead: minimum gap between bull and bear score (default 20)

Multi-Timeframe Trend
- Enable MTF Filter
- HTF Timeframe (default 240)
- HTF Weight (default 20)

Quality Filters (Noise Reduction)
- Enable ADX Noise Filter
- Min ADX Value (0–100, default 35)

Trend Confirmation
- Enable VWMA Filter + length
- Enable Supertrend Filter + ATR length + multiplier
- Show/hide Supertrend and VWMA lines

Pillar Weights
- Individual weight for each of the six pillars

Session Filtering
- Filter Entries by Session (time gate)
- Enable Session Pillar Scoring (premium/discount scoring)
- Trading Session input

Trade Suggestions (ATR Multipliers)
- SL and TP multipliers for Scalp, Intraday, and Swing regimes

Ultra Ribbon
- Enable Ribbon Filter
- Show Ribbon on Chart
- Base Length and Length Step
- Theme: Classic / Phantom / Custom
- Custom color inputs (bull, bear, elite)

Backtest & UI
- Enable Performance Tracking
- Start Year
- Show Active Trade Lines
- Show Recent Trade Log
- Stop Loss Mode: ATR / Pivot / Supertrend / Trailing (h15)

UI Settings
- Show Dashboard
- Dashboard Position
- Dashboard Size: Tiny / Small / Normal

10. How to use
10.1 Initial setup
1. Load the indicator on your preferred chart and timeframe.
2. Select a ribbon theme that matches your visual preference.
3. Set the signal threshold based on your desired selectivity. Start at 70.
4. Set the directional lead. 15–20 is a balanced starting point.
5. Enable the hard gates relevant to your style. For intraday trading, ADX + Supertrend is a strong combination. For swing trading, VWMA + MTF adds macro context.
6. Configure the session scoring if you trade specific sessions. NY traders: set session to 1330–2000 UTC (or your local equivalent).
7. Set your backtest start year and stop mode preference.

10.2 Reading a signal
When a signal appears:
- Check the dashboard. Which pillars are active? A signal with Structure + Volume + Momentum all scoring is stronger than one carried primarily by Session and Volatility.
- Check the score. A signal at 72 with a 20-point gap is valid but tight. A signal at 88 with a 30-point gap is a high-conviction setup.
- Check the ribbon. Is it cleanly bullish or bearish? Is it near exhaustion color? Signals during ribbon exhaustion carry more risk.
- Check the hard gates. They cleared — but were they close? A signal that barely cleared ADX 35 is different from one with ADX at 55.

10.3 Managing entries
Confluence Engine does not tell you the exact entry price. It tells you when conditions align. Your entry technique — pullback, breakout, limit at structure — remains your decision.
Use the stop mode that fits your trade: ATR for consistency, Pivot for structure-respect, Supertrend for dynamic adaptation, Trailing h15 for trend trades you want to hold.

10.4 Interpreting win rate
The built-in win rate is a useful reference, not a guarantee of future performance. A 65% win rate over 50 signals on a specific asset and timeframe tells you the system has been profitable in that environment. It does not guarantee the next signal wins.
Win rate should always be evaluated alongside average RR. A 60% win rate at 2R average beats a 70% win rate at 0.8R average. Use the recent log and the trade lines together to assess both dimensions.

10.5 Optimizing settings
If you see too many signals: raise the threshold, raise the directional lead, raise the ADX minimum, or enable additional hard gates.
If you see too few signals: lower the threshold slightly, reduce the directional lead, or disable one or two hard gates.
Do not optimize purely for win rate without considering signal frequency. A system that fires once per week at 80% win rate is different in practice from one that fires daily at 65%. Both can be profitable. Choose what fits your trading style.

11. Timeframe guide
1m–5m — Ultra Ribbon filter on, ADX threshold 30–40, Supertrend on, session scoring on. Focus on fast momentum signals during active sessions.
15m–30m — Full filter stack recommended. Threshold 70–75. Strong balance of frequency and quality.
1H–4H — VWMA and MTF filter add significant value. Threshold 75–80. Fewer signals, higher conviction.
Daily — Disable session scoring. Enable VWMA and MTF only. Use as swing context, not scalp tool.

12. What this indicator does not do
- Does not predict price direction with certainty
- Does not guarantee profitability
- Does not replace your own risk management
- Does not account for news events, gaps, or liquidity voids
- Does not track open positions in real time
- Does not connect to any broker or execution system
- Does not replace the Risk Management Engine for position sizing and account compliance

For position sizing, drawdown compliance, and trade logging, pair with Risk Management Engine | Anonycryptous.
For complete session analysis and market context, pair with Environment | Anonycryptous.
Together, the three tools cover strategy context, signal generation, and risk execution — a complete framework for structured trading.

13. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document constitutes financial advice or any form of recommendation.
All trading decisions are made entirely by the user. The indicator provides signal analysis based on configurable parameters — the relevance of any output depends on how those parameters are set and the market conditions in which the indicator is used.
Trading financial instruments involves substantial risk of loss. Past performance of the backtest function is not indicative of future results. You may lose all of your invested capital.
Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator or any content in this manual.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Conflux Engine | Anonycryptous", "Conflux Engine", overlay = true, max_labels_count = 500, max_lines_count = 500)

// --------------------------------------------------------------------------------------------------------------------
// --- Inputs: General & Scoring ---
// --------------------------------------------------------------------------------------------------------------------
gp_gen = "General Settings"
thresholdInput  = input.int(70, "Signal Threshold", minval = 50, maxval = 95, group = gp_gen, tooltip = "Minimum total score required to trigger a signal.")
extremeThres    = input.int(90, "Extreme Threshold", minval = 80, maxval = 100, group = gp_gen, tooltip = "Score above which an 'Extreme Confluence' alert is triggered.")
scoreGapInput   = input.int(20, "Directional Lead", minval = 0, group = gp_gen, tooltip = "Minimum difference required between the dominant score and the opposite score.")

gp_mtf = "Multi-Timeframe Trend"
useMTF          = input.bool(true, "Enable MTF Filter", group = gp_mtf)
htfRes          = input.timeframe("240", "HTF Timeframe", group = gp_mtf, tooltip = "Higher timeframe for trend filtering.")
htfWeight       = input.int(20, "HTF Weight", group = gp_mtf, tooltip = "Points added if trend on HTF is aligned.")

gp_noise = "Quality Filters (Noise Reduction)"
useNoiseFilter  = input.bool(true, "Enable ADX Noise Filter", group = gp_noise, tooltip = "Prevents signals in low-momentum choppy markets.")
noiseThreshold  = input.int(35, "Min ADX Value", minval = 0, maxval = 100, group = gp_noise, tooltip = "Signals only fire when ADX is above this value. Min: 0 (no filter), Max: 100. Recommended: 25–50 for intraday, 40–70 for high-quality only.")

gp_trend = "Trend Confirmation"
useVWMA         = input.bool(true,  "Enable VWMA Filter",       group = gp_trend, tooltip = "Price must be above VWMA for longs, below for shorts.")
vwmaLen         = input.int(200,    "VWMA Length",               group = gp_trend, minval = 1)
useSupertrend   = input.bool(true,  "Enable Supertrend Filter",  group = gp_trend, tooltip = "Supertrend must agree with signal direction.")
stAtrLen        = input.int(10,     "Supertrend ATR Length",     group = gp_trend, minval = 1)
stMult          = input.float(3.5,  "Supertrend Multiplier",     group = gp_trend, minval = 0.1, step = 0.1)
showST          = input.bool(false,  "Show Supertrend Line",      group = gp_trend)
showVWMA        = input.bool(true,  "Show VWMA Line",            group = gp_trend)

gp_wght = "Pillar Weights (Max Points)"
wStruct = input.int(16, "1. Structure Weight", group = gp_wght)
wVolume = input.int(16, "2. Volume Weight", group = gp_wght)
wMom    = input.int(16, "3. Momentum Weight", group = gp_wght)
wLiq    = input.int(16, "4. Liquidity Weight", group = gp_wght)
wVol    = input.int(16, "5. Volatility Weight", group = gp_wght)
wSess   = input.int(20, "6. Session Weight", group = gp_wght)

gp_sess = "Session Filtering"
useSessFilter   = input.bool(false, "Filter Entries by Session", group = gp_sess, tooltip = "Blocks signals outside the defined session hours.")
useSessScore    = input.bool(true,  "Enable Session Pillar Scoring", group = gp_sess, tooltip = "When off, the Session pillar scores 0 regardless of price position. Min score contribution: 0, Max: wSess points.")
sessInput       = input.session("1330-2000:23456", "Trading Session (UTC)", group = gp_sess, tooltip = "Signals only trigger during these hours. Default is NY Session.")

gp_targets = "Trade Suggestions (ATR Multipliers)"
sc_sl = input.float(1.0, "Scalp SL", inline = "sc", group = gp_targets)
sc_tp = input.float(1.5, "Scalp TP", inline = "sc", group = gp_targets)
in_sl = input.float(1.5, "Intraday SL", inline = "in", group = gp_targets)
in_tp = input.float(3.0, "Intraday TP", inline = "in", group = gp_targets)
sw_sl = input.float(2.5, "Swing SL", inline = "sw", group = gp_targets)
sw_tp = input.float(5.0, "Swing TP", inline = "sw", group = gp_targets)

gp_ribbon = "Ultra Ribbon"
useRibbon     = input.bool(true,  "Enable Ribbon Filter",  group = gp_ribbon, tooltip = "h1 > h15 = bull gate, h1 < h15 = bear gate. Fastest momentum confirmation.")
showRibbon    = input.bool(true,  "Show Ribbon on Chart",  group = gp_ribbon)
ribbonBase    = input.int(20,     "Base Length",           group = gp_ribbon, minval = 2)
ribbonStep    = input.int(19,      "Length Step",           group = gp_ribbon, minval = 1)
ribbonTheme   = input.string("Phantom", "Theme", options = ["Classic", "Phantom", "Custom"], group = gp_ribbon, tooltip = "Classic = green/red. Phantom = cyan/pink/purple. Custom = your own colors. Also sets dashboard accent color.")
rBullCustom   = input.color(color.rgb(0, 255, 0),    "Custom Bull",  group = gp_ribbon)
rBearCustom   = input.color(color.rgb(255, 0, 0),    "Custom Bear",  group = gp_ribbon)
rEliteCustom  = input.color(color.rgb(187, 134, 252),"Custom Elite", group = gp_ribbon)

gp_backtest = "Backtest & UI"
useBacktest = input.bool(true, "Enable Performance Tracking", group = gp_backtest)
startYear   = input.int(2023, "Start Year", group = gp_backtest)
showLines   = input.bool(true, "Show Active Trade Lines", group = gp_backtest)
showLog     = input.bool(true, "Show Recent Trade Log", group = gp_backtest)
slMode      = input.string("Trailing (h15)", "Stop Loss Mode", options = ["ATR", "Pivot", "Supertrend", "Trailing (h15)"], group = gp_backtest, tooltip = "ATR = fixed ATR multiple. Pivot = last swing high/low. Supertrend = dynamic ST level. Trailing = follows ribbon h15 HMA.")

gp_ui = "UI Settings"
showDashboard   = input.bool(true, "Show Dashboard", group = gp_ui)
dashPosition    = input.string("Bottom Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = gp_ui)
dashSize        = input.string("Small", "Dashboard Size", options = ["Tiny", "Small", "Normal"], group = gp_ui)

// --- Theme Colors — resolved from ribbon preset ---
color tBull  = na
color tBear  = na
color tElite = na

if ribbonTheme == "Classic"
    tBull  := color.rgb(0, 255, 0)
    tBear  := color.rgb(255, 0, 0)
    tElite := color.rgb(187, 134, 252)
else if ribbonTheme == "Phantom"
    tBull  := color.rgb(6, 182, 212)
    tBear  := color.rgb(236, 72, 153)
    tElite := color.rgb(187, 134, 252)
else
    tBull  := rBullCustom
    tBear  := rBearCustom
    tElite := rEliteCustom

colorBULL    = tBull
colorBEAR    = tBear
colorNEUTRAL = color.rgb(139, 148, 158)

// --------------------------------------------------------------------------------------------------------------------
// --- Global Functions & MTF ---
// --------------------------------------------------------------------------------------------------------------------
kamaF(s, l) =>
    float diff = math.abs(ta.change(s, l))
    float vola = ta.cum(math.abs(ta.change(s)))
    float er = vola != 0 ? diff / vola : 0.0
    float sc = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0, 2.0)
    var float k = na
    k := nz(k[1], s) + sc * (s - nz(k[1], s))
    k

updateDash(table _t, int _r, string _l, float _b, float _e, color _cB, color _cR, color _cN) =>
    float sc = math.max(_b, _e)
    color cl = _b > _e ? _cB : _e > _b ? _cR : _cN
    table.cell(_t, 0, _r, _l, text_color = color.white, text_halign = text.align_left, text_size = size.small)
    table.cell(_t, 1, _r, str.tostring(math.round(sc)), bgcolor = color.new(cl, 70), text_color = color.white, text_size = size.small)

// MTF Data
float htfTrend = request.security(syminfo.tickerid, htfRes, ta.ema(close, 50))
bool htfBull = close > htfTrend
bool htfBear = close < htfTrend

// VWMA & Supertrend
vwmaVal        = ta.vwma(close, vwmaLen)
[stVal, stDir] = ta.supertrend(stMult, stAtrLen)
stBull         = stDir < 0
stBear         = stDir > 0
vwmaBull       = close > vwmaVal
vwmaBear       = close < vwmaVal

// Ultra Ribbon — 15 HMAs
rh(len) => ta.hma(close, len)
float rh1  = rh(ribbonBase)
float rh2  = rh(ribbonBase + ribbonStep)
float rh3  = rh(ribbonBase + ribbonStep * 2)
float rh4  = rh(ribbonBase + ribbonStep * 3)
float rh5  = rh(ribbonBase + ribbonStep * 4)
float rh6  = rh(ribbonBase + ribbonStep * 5)
float rh7  = rh(ribbonBase + ribbonStep * 6)
float rh8  = rh(ribbonBase + ribbonStep * 7)
float rh9  = rh(ribbonBase + ribbonStep * 8)
float rh10 = rh(ribbonBase + ribbonStep * 9)
float rh11 = rh(ribbonBase + ribbonStep * 10)
float rh12 = rh(ribbonBase + ribbonStep * 11)
float rh13 = rh(ribbonBase + ribbonStep * 12)
float rh14 = rh(ribbonBase + ribbonStep * 13)
float rh15 = rh(ribbonBase + ribbonStep * 14)

ribbonBull = rh1 > rh15
ribbonBear = rh1 < rh15

// Ribbon color
rSpread    = rh1 - rh15
rAbsSpread = math.abs(rSpread)
rAvgSpread = ta.ema(rAbsSpread, 200)
rFactor    = math.max(-1, math.min(1, nz(rSpread / (rAvgSpread * 1.5 + 1e-9), 0)))
rCol       = color.from_gradient(rFactor, -1, 1, colorBEAR, colorBULL)

// --------------------------------------------------------------------------------------------------------------------
// --- Core Engine Logic ---
// --------------------------------------------------------------------------------------------------------------------

// 0. Regime & Filters
[diP, diM, adx] = ta.dmi(14, 14)
atr = ta.atr(14)
atrRel = atr / ta.sma(atr, 100)
string rStr = adx < 20 ? "SCALP" : adx < 35 ? "INTRADAY" : "SWING"
bool inSession = not useSessFilter or not na(time(timeframe.period, sessInput, "UTC"))

// 1. Structure
ph = ta.pivothigh(high, 10, 10), pl = ta.pivotlow(low, 10, 10)
var float lPH = na, var float lPL = na
var bool iHH = false, var bool iHL = false, var bool iLH = false, var bool iLL = false
if not na(ph)
    iHH := ph > nz(lPH, 0), iLH := ph < nz(lPH, 999999), lPH := ph
if not na(pl)
    iHL := pl > nz(lPL, 0), iLL := pl < nz(lPL, 999999), lPL := pl
float bStr = (iHH or iHL) and close > lPL ? float(wStruct) : 0.0
float eStr = (iLL or iLH) and close < lPH ? float(wStruct) : 0.0

// 2. Volume
obvV = ta.cum(math.sign(ta.change(close)) * volume)
obvS = ta.linreg(obvV, 20, 0) - ta.linreg(obvV, 20, 1)
float bVol = obvS > 0 ? float(wVolume) : 0.0
float eVol = obvS < 0 ? float(wVolume) : 0.0

// 3. Momentum
kVal = kamaF(close, 21), rsiV = ta.rsi(close, 14), wprV = ta.wpr(14)
float bMomR = (close > kVal ? 1.0 : 0.0) + (rsiV > 50 ? 1.0 : 0.0) + (wprV > -40 ? 1.0 : 0.0)
float eMomR = (close < kVal ? 1.0 : 0.0) + (rsiV < 50 ? 1.0 : 0.0) + (wprV < -60 ? 1.0 : 0.0)
float bMom = (bMomR / 3.0) * wMom, float eMom = (eMomR / 3.0) * wMom

// 4. Liquidity
float bSwp = low < lPL and close > lPL ? float(wLiq) : 0.0
float eSwp = high > lPH and close < lPH ? float(wLiq) : 0.0

// 5. Volatility
float vSco = (atrRel > 0.8 and atrRel < 1.6) ? float(wVol) : 0.0
float bVlt = bMom > eMom and bMomR >= 2.0 ? vSco : 0.0, float eVlt = eMom > bMom and eMomR >= 2.0 ? vSco : 0.0

// 6. Session
var float sH = na, var float sL = na
if not na(ta.change(time("D")))
    sH := high, sL := low
else
    sH := math.max(high, nz(sH, high)), sL := math.min(low, nz(sL, low))
sM = (sH + sL) / 2.0, sR = sH - sL
dM = sR > 0 ? (close - sM) / sR * 100.0 : 0.0
float bSes = useSessScore and dM < 0 ? math.min(float(wSess), math.abs(dM) * (wSess / 50.0)) : 0.0
float eSes = useSessScore and dM > 0 ? math.min(float(wSess), math.abs(dM) * (wSess / 50.0)) : 0.0

// 7. MTF Pillar
float bMTF = useMTF and htfBull ? float(htfWeight) : 0.0
float eMTF = useMTF and htfBear ? float(htfWeight) : 0.0

// Total Scoring
float bull = bStr + bVol + bMom + bSwp + bVlt + bSes + bMTF
float bear = eStr + eVol + eMom + eSwp + eVlt + eSes + eMTF
bool noiseFilter  = not useNoiseFilter or adx >= noiseThreshold
bool vwmaGateBull = not useVWMA or vwmaBull
bool vwmaGateBear = not useVWMA or vwmaBear
bool stGateBull   = not useSupertrend or stBull
bool stGateBear   = not useSupertrend or stBear
bool ribGateBull  = not useRibbon or ribbonBull
bool ribGateBear  = not useRibbon or ribbonBear
bool isL  = bull >= thresholdInput and (bull - bear) >= scoreGapInput and inSession and noiseFilter and vwmaGateBull and stGateBull and ribGateBull
bool isS  = bear >= thresholdInput and (bear - bull) >= scoreGapInput and inSession and noiseFilter and vwmaGateBear and stGateBear and ribGateBear
bool isLE = isL and bull >= extremeThres
bool isSE = isS and bear >= extremeThres

// --------------------------------------------------------------------------------------------------------------------
// --- Performance & Trade Log ---
// --------------------------------------------------------------------------------------------------------------------
var int tTrades = 0, var int tWins = 0, var int tLoss = 0
var float activePrice = na, var float activeSL = na, var float activeTP = na, var int activeDir = 0
var line slLine = na, var line tpLine = na
var string[] tradeLog = array.new_string(0)

if useBacktest and time >= timestamp(startYear, 1, 1, 0, 0) and activeDir == 0
    if isL and not isL[1]
        activeDir := 1, activePrice := close
        multSL = rStr == "SCALP" ? sc_sl : rStr == "INTRADAY" ? in_sl : sw_sl
        multTP = rStr == "SCALP" ? sc_tp : rStr == "INTRADAY" ? in_tp : sw_tp
        activeSL := slMode == "Pivot" ? nz(lPL, close - atr * multSL) : slMode == "Supertrend" ? stVal : slMode == "Trailing (h15)" ? rh15 : close - (atr * multSL)
        activeTP := close + (atr * multTP), tTrades += 1
        if showLines
            slLine := line.new(bar_index, activeSL, bar_index + 10, activeSL, color = color.new(colorBEAR, 50), style = line.style_solid)
            tpLine := line.new(bar_index, activeTP, bar_index + 10, activeTP, color = color.new(colorBULL, 50), style = line.style_solid)
    else if isS and not isS[1]
        activeDir := -1, activePrice := close
        multSL = rStr == "SCALP" ? sc_sl : rStr == "INTRADAY" ? in_sl : sw_sl
        multTP = rStr == "SCALP" ? sc_tp : rStr == "INTRADAY" ? in_tp : sw_tp
        activeSL := slMode == "Pivot" ? nz(lPH, close + atr * multSL) : slMode == "Supertrend" ? stVal : slMode == "Trailing (h15)" ? rh15 : close + (atr * multSL)
        activeTP := close - (atr * multTP), tTrades += 1
        if showLines
            slLine := line.new(bar_index, activeSL, bar_index + 10, activeSL, color = color.new(colorBEAR, 50), style = line.style_solid)
            tpLine := line.new(bar_index, activeTP, bar_index + 10, activeTP, color = color.new(colorBULL, 50), style = line.style_solid)

if activeDir != 0
    if showLines
        line.set_x2(slLine, bar_index), line.set_x2(tpLine, bar_index)
    bool win = activeDir == 1 ? high >= activeTP : low <= activeTP
    bool loss = activeDir == 1 ? low <= activeSL : high >= activeSL
    if win or loss
        float rResult = win ? (activeDir == 1 ? (activeTP - activePrice) / (activePrice - activeSL) : (activePrice - activeTP) / (activeSL - activePrice)) : -1.0
        array.push(tradeLog, (win ? "+" : "") + str.tostring(rResult, "#.##") + "R")
        if array.size(tradeLog) > 3
            array.remove(tradeLog, 0)
        if win
            tWins += 1, label.new(bar_index, activeTP, "WIN", color = colorBULL, textcolor = color.white, style = label.style_label_down, size = size.small)
        else
            tLoss += 1, label.new(bar_index, activeSL, "LOSS", color = colorBEAR, textcolor = color.white, style = label.style_label_up, size = size.small)
        activeDir := 0

winRate = tTrades > 0 ? (float(tWins) / float(tTrades)) * 100 : 0.0

// --------------------------------------------------------------------------------------------------------------------
// --- Visuals & Dashboard ---
// --------------------------------------------------------------------------------------------------------------------
if isL and not isL[1]
    label.new(bar_index, low, "BUY", color = colorBULL, textcolor = color.white, style = label.style_label_up, size = size.small)
if isS and not isS[1]
    label.new(bar_index, high, "SELL", color = colorBEAR, textcolor = color.white, style = label.style_label_down, size = size.small)
bgcolor(isLE ? color.new(colorBULL, 80) : isSE ? color.new(colorBEAR, 80) : isL ? color.new(colorBULL, 90) : isS ? color.new(colorBEAR, 90) : na)
bgcolor(useSessFilter and not inSession ? color.new(colorNEUTRAL, 95) : na)
barcolor(ribbonBull ? colorBULL : ribbonBear ? colorBEAR : na)

// VWMA & Supertrend plots
plot(showVWMA ? vwmaVal : na, "VWMA", color = color.new(#bb86fc, 26), linewidth = 1)
plot(showST   ? stVal   : na, "Supertrend", color = stBull ? color.new(#089981, 0) : color.new(#f23645, 0), linewidth = 2)

// Ultra Ribbon plots
rp1  = plot(showRibbon ? rh1  : na, "RH1",  color.new(rCol, 10), 1)
rp2  = plot(showRibbon ? rh2  : na, "RH2",  color.new(rCol, 16), 1)
rp3  = plot(showRibbon ? rh3  : na, "RH3",  color.new(rCol, 22), 1)
rp4  = plot(showRibbon ? rh4  : na, "RH4",  color.new(rCol, 28), 1)
rp5  = plot(showRibbon ? rh5  : na, "RH5",  color.new(rCol, 34), 1)
rp6  = plot(showRibbon ? rh6  : na, "RH6",  color.new(rCol, 40), 1)
rp7  = plot(showRibbon ? rh7  : na, "RH7",  color.new(rCol, 46), 1)
rp8  = plot(showRibbon ? rh8  : na, "RH8",  color.new(rCol, 52), 1)
rp9  = plot(showRibbon ? rh9  : na, "RH9",  color.new(rCol, 58), 1)
rp10 = plot(showRibbon ? rh10 : na, "RH10", color.new(rCol, 64), 1)
rp11 = plot(showRibbon ? rh11 : na, "RH11", color.new(rCol, 70), 1)
rp12 = plot(showRibbon ? rh12 : na, "RH12", color.new(rCol, 74), 1)
rp13 = plot(showRibbon ? rh13 : na, "RH13", color.new(rCol, 78), 1)
rp14 = plot(showRibbon ? rh14 : na, "RH14", color.new(rCol, 82), 1)
rp15 = plot(showRibbon ? rh15 : na, "RH15", color.new(rCol, 86), 1)

fill(rp1,  rp2,  color = color.new(rCol, 90), title = "RF1")
fill(rp2,  rp3,  color = color.new(rCol, 91), title = "RF2")
fill(rp3,  rp4,  color = color.new(rCol, 92), title = "RF3")
fill(rp4,  rp5,  color = color.new(rCol, 92), title = "RF4")
fill(rp5,  rp6,  color = color.new(rCol, 93), title = "RF5")
fill(rp6,  rp7,  color = color.new(rCol, 93), title = "RF6")
fill(rp7,  rp8,  color = color.new(rCol, 93), title = "RF7")
fill(rp8,  rp9,  color = color.new(rCol, 94), title = "RF8")
fill(rp9,  rp10, color = color.new(rCol, 94), title = "RF9")
fill(rp10, rp11, color = color.new(rCol, 94), title = "RF10")
fill(rp11, rp12, color = color.new(rCol, 95), title = "RF11")
fill(rp12, rp13, color = color.new(rCol, 95), title = "RF12")
fill(rp13, rp14, color = color.new(rCol, 95), title = "RF13")
fill(rp14, rp15, color = color.new(rCol, 96), title = "RF14")

var table d = table.new(dashPosition == "Top Right" ? position.top_right : dashPosition == "Bottom Right" ? position.bottom_right : position.bottom_left, 2, 16,
  bgcolor      = color.new(color.rgb(13, 17, 23),  10),
  border_color = color.new(color.rgb(48, 54, 61),  20), border_width = 1,
  frame_color  = color.new(color.rgb(48, 54, 61),  40), frame_width  = 1)

if barstate.islast and showDashboard
    dSz      = dashSize == "Tiny" ? size.tiny : dashSize == "Small" ? size.small : size.normal
    cPanel   = color.new(color.rgb(22, 27, 34),   0)
    cMuted   = color.new(color.rgb(139, 148, 158), 0)
    cWhite   = color.new(color.rgb(255, 255, 255), 0)
    cElite   = color.new(tElite, 0)
    cBull    = color.new(colorBULL, 0)
    cBear    = color.new(colorBEAR, 0)
    cNeut    = color.new(colorNEUTRAL, 0)

    signalStr   = isL ? "▲ LONG" : isS ? "▼ SHORT" : "— WAIT"
    signalColor = isL ? cBull : isS ? cBear : cMuted
    totalScore  = math.round(math.max(bull, bear))
    scoreColor  = bull > bear ? cBull : cBear

    // Row 0 — Header
    table.cell(d, 0, 0, "CONFLUX ENGINE", text_color = cElite,  text_size = dSz, bgcolor = cPanel)
    table.cell(d, 1, 0, timeframe.period,     text_color = cMuted,  text_size = dSz, bgcolor = cPanel)

    // Rows 1–7 — Pillars via updateDash (rows intact)
    updateDash(d, 1, "1. Structure", bStr, eStr, colorBULL, colorBEAR, colorNEUTRAL)
    updateDash(d, 2, "2. Volume",    bVol, eVol, colorBULL, colorBEAR, colorNEUTRAL)
    updateDash(d, 3, "3. Momentum",  bMom, eMom, colorBULL, colorBEAR, colorNEUTRAL)
    updateDash(d, 4, "4. Liquidity", bSwp, eSwp, colorBULL, colorBEAR, colorNEUTRAL)
    updateDash(d, 5, "5. Volatility",bVlt, eVlt, colorBULL, colorBEAR, colorNEUTRAL)
    updateDash(d, 6, "6. Session",   bSes, eSes, colorBULL, colorBEAR, colorNEUTRAL)
    if useMTF
        updateDash(d, 7, "7. HTF Trend (" + htfRes + ")", bMTF, eMTF, colorBULL, colorBEAR, colorNEUTRAL)

    // Row 8 — Signal
    table.cell(d, 0, 8, "Signal",      text_color = cMuted,      text_size = dSz, bgcolor = cPanel)
    table.cell(d, 1, 8, signalStr,     text_color = signalColor,  text_size = dSz, bgcolor = cPanel)

    // Row 9 — Performance
    table.cell(d, 0, 9,  "Win Rate",   text_color = cMuted, text_size = dSz, bgcolor = cPanel)
    table.cell(d, 1, 9,  str.tostring(winRate, "#.#") + "%", bgcolor = winRate > 50 ? color.new(colorBULL, 70) : color.new(colorBEAR, 70), text_color = cWhite, text_size = dSz)

    // Row 10 — Recent log
    if showLog and array.size(tradeLog) > 0
        table.cell(d, 0, 10, "Recent Log", text_color = cMuted, text_halign = text.align_left, text_size = dSz, bgcolor = cPanel)
        string logStr = ""
        for i = 0 to array.size(tradeLog) - 1
            logStr += array.get(tradeLog, i) + (i < array.size(tradeLog) - 1 ? " | " : "")
        table.cell(d, 1, 10, logStr, text_color = cWhite, text_size = dSz, bgcolor = cPanel)

    // Row 11 — Total score
    table.cell(d, 0, 11, "Score",      text_color = cMuted,     text_size = dSz, bgcolor = cPanel)
    table.cell(d, 1, 11, str.tostring(totalScore) + " / 100", bgcolor = scoreColor, text_color = cWhite, text_size = dSz)

    // Row 12 — Session status
    table.cell(d, 0, 12, "Session",    text_color = cMuted,     text_size = dSz, bgcolor = cPanel)
    table.cell(d, 1, 12, inSession ? "OPEN" : "FILTERED", bgcolor = inSession ? color.new(colorBULL, 80) : color.new(colorBEAR, 80), text_color = cWhite, text_size = dSz)

    // Row 15 — Brand
    table.cell(d, 0, 15, "Anonycryptous", text_color = cElite,  text_size = dSz, bgcolor = cPanel)
    table.cell(d, 1, 15, "V1.0",          text_color = cMuted,  text_size = dSz, bgcolor = cPanel)
````
