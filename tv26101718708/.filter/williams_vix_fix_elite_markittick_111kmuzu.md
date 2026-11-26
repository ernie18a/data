# Williams VIX Fix Elite [MarkitTick]

- url: https://www.tradingview.com/script/111KmuzU-Williams-VIX-Fix-Elite-MarkitTick/
- type: indicator
- pine_id: PUB;6060921f3d0b4b319328b52aa54e8bc0
- version: 1.0

## Description

💡 The Williams VIX Fix Elite is a comprehensive, overlay-based technical analysis system designed to bring the powerful volatility-tracking properties of the traditional Williams VIX Fix directly onto the main price chart. By synthesizing statistical volatility extremes with an array of multi-timeframe trend filters, volume confirmation parameters, and dynamic risk management plotting, this tool transcends basic observation. It provides traders with a complete, structured methodology for identifying high-probability exhaustion zones and potential market reversals while strictly managing risk.

[b]✨ Originality and Utility[/b]

Standard volatility indicators are almost exclusively relegated to separate oscillator panes at the bottom of the chart. This traditional placement forces the user to constantly shift their visual focus, often leading to a disconnect between volatility metrics and actual price action. This indicator resolves that friction by mapping volatility exhaustion directly onto the candlesticks themselves through an intuitive color-coded heatmap. 

Furthermore, the utility of this script lies in its holistic approach to signal generation. Rather than providing isolated volatility alerts, it acts as a confluence engine. It mandates that a volatility spike must be corroborated by higher timeframe trend alignment, adequate localized volume, directional momentum, and specific standard deviation thresholds before generating an actionable signal. This transforms a simple oscillator concept into a robust, chart-integrated trading framework complete with dynamically calculated risk-to-reward parameters, rendering it highly useful for both discretionary analysis and automated alert integrations.

[b]🔬 Methodology and Concepts[/b]

[b]● The Volatility Engine[/b]
[b]• Williams VIX Fix (WVF)[/b]
At its core, the script calculates the Williams VIX Fix. It does this by measuring the percentage drawdown of the current bar's low from the highest closing price over a user-defined lookback period. This mathematical approach creates a synthetic volatility index that mirrors the behavioral characteristics of the CBOE VIX, where high values indicate market fear and potential bottoms.

[b]• Statistical Bounds[/b]
To determine when the WVF has reached a statistically significant extreme, the script applies Bollinger Bands to the WVF data. It calculates a Simple Moving Average (SMA) of the WVF and plots standard deviation bands around it. A "Spike" is registered when the WVF value breaches the upper Bollinger Band or a percentile-based historical high threshold.

[b]● Confluence Filtering[/b]
[b]• Higher Timeframe (HTF) Alignment[/b]
The script extracts moving average data from a user-selected higher timeframe. It assesses whether the higher timeframe's closing price and dual-period EMAs exhibit a bullish or bearish hierarchy, ensuring signals are not taken against the macro-directional flow.

[b]• Volatility and Volume Validation[/b]
A signal is only considered valid if the localized volatility, measured by the Average True Range (ATR), exceeds its historical average multiplied by a strict threshold. Additionally, the localized volume must exceed its moving average, confirming that the reversal is backed by market participation.

[b]• Signal Execution and Risk Logic[/b]
When all conditions align (a volatility spike followed by a directional reversal candle, validated by all filters), the script locks in the signal upon the bar's close. It immediately calculates a Stop Loss utilizing an ATR multiplier and projects three Take Profit levels mathematically derived from user-defined Risk-to-Reward (R:R) ratios. 

[b]🎨 Visual Guide[/b]

[b]● Chart Overlay Elements[/b]
[b]• Candlestick Heatmap[/b]
The indicator repaints the standard chart candles to reflect the immediate signal bias. A confirmed Long signal colors the candlestick body, borders, and wicks in a distinct bullish hue (default teal). Conversely, a confirmed Short signal paints the candle in a bearish hue (default red). Neutral periods retain a standard gray tone.

[b]• Dynamic Trade Levels[/b]
Upon signal confirmation, the script automatically plots horizontal lines detailing the trade parameters:
[list]
[*] [b]Stop Loss Line:[/b] A solid, thick line plotted below (for longs) or above (for shorts) the entry price, acting as the primary risk invalidation level.
[*] [b]Entry Line:[/b] A dashed line marking the exact closing price of the signal candle.
[*] [b]Take Profit Lines:[/b] Three sequential dashed lines representing TP1, TP2, and TP3, mapping out the reward targets.
[/list]
The space between the Stop Loss and Entry is highlighted with a semi-transparent risk linefill, while the space extending toward the Take Profit targets is highlighted with a reward linefill, visually contrasting the risk against the potential payout.

[b]● The Interactive Dashboard[/b]
A dedicated data panel is rendered on the chart (default top-right) providing real-time telemetry of the script's internal calculations.
[list]
[*] [b]WVF Value & Spike Level:[/b] Displays the raw volatility index number alongside a visual progress bar indicating how close the current value is to the historical threshold.
[*] [b]HTF & Trend Bias:[/b] Textually confirms the current macro and localized trend alignment (Bullish/Bearish).
[*] [b]Volume & ATR:[/b] Confirms whether current volume is above or below average and displays the exact ATR value.
[*] [b]R:R Ratio:[/b] A visual gauge of the current signal's risk-to-reward structure.
[*] [b]Cooldown Status:[/b] Displays the remaining bars before a new signal can be generated, preventing over-signaling during congested price action.
[/list]

[b]📖 How to Use[/b]

[b]● Execution Protocol[/b]
[b]• Step 1: Signal Identification[/b]
Wait for a colored signal candle to print on the chart. A teal candle signifies a Long opportunity, while a red candle signifies a Short opportunity. Always wait for the candle to fully close, as signals are only validated upon bar confirmation to ensure accuracy.

[b]• Step 2: Dashboard Verification[/b]
Consult the on-chart dashboard. Ensure that the "Spike Level" gauge was heavily filled prior to the signal, and visually confirm that the "HTF Bias" and "Trend Bias" align with your intended trade direction. Verify that the "Volume" metric indicates "Above Avg" for optimal setup quality.

[b]• Step 3: Risk Assessment[/b]
Observe the plotted trade levels. The visual linefills will immediately show you the required risk (the distance from the dashed Entry line to the solid Stop Loss line). Assess whether this required risk fits within your personal account parameters. If the ATR has expanded too aggressively, the stop loss may be too wide, and the setup should be skipped.

[b]• Step 4: Trade Management[/b]
If the trade is entered, utilize the plotted TP1, TP2, and TP3 lines as scaling-out points. The script also includes automated JSON alert outputs designed for third-party execution platforms, allowing users to fully automate the Long, Short, and Take Profit hit actions.

[b]⚙️ Inputs and Settings[/b]

[b]● Core Settings[/b]
[b]• WVF Lookback:[/b] Defines the historical period used to find the highest close for the volatility drawdown calculation.
[b]• BB Length & BB Mult:[/b] Controls the Simple Moving Average length and the standard deviation multiplier applied to the WVF. Lowering the multiplier increases sensitivity to volatility spikes.
[b]• Percentile HH Lookback & High % Threshold:[/b] An alternative absolute-threshold filter based on a percentage of the highest historical WVF values.

[b]● Filters[/b]
[b]• HTF Resolution:[/b] Select the specific higher timeframe used for the macro trend validation.
[b]• ATR Length & Min Mult:[/b] Defines the lookback for the Average True Range and the multiplier required to validate adequate localized volatility.
[b]• Min Spike Above BB %:[/b] A Z-score threshold ensuring the volatility spike is mathematically severe before triggering a signal.
[b]• Volume Avg Length & Min Mult:[/b] Dictates the volume moving average parameters required for trade confirmation.
[b]• Cooldown Bars:[/b] The mandatory resting period (in bars) between valid signals to eliminate redundant alerts.

[b]● Trade Tools & Alerts[/b]
[b]• SL ATR Mult:[/b] The multiplier applied to the current ATR to calculate the Stop Loss distance from the entry price.
[b]• TP1, TP2, TP3 R-Multiple:[/b] Dictates the reward distance for target lines relative to the calculated Stop Loss risk.
[b]• Alert Actions:[/b] String inputs allowing the user to customize the JSON payload commands sent to automated webhook services.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]● Behavioral Finance and Volatility Asymmetry[/b]
The underlying architecture of this indicator is deeply rooted in the academic principles of behavioral finance, specifically the asymmetry of market participant reactions. Financial markets typically exhibit a "stealth" characteristic during uptrends (low volatility, steady buying) and a "panic" characteristic during downtrends (high volatility, aggressive selling). The Williams VIX Fix capitalizes on this behavioral asymmetry by focusing exclusively on drawdowns from peak closes. By quantifying this localized panic, the script provides a mathematical representation of capitulation—a state where sell-side liquidity is exhausted, and rational market equilibrium is poised to return.

[b]● Gaussian Distribution and Standard Deviation Anomalies[/b]
To objectively define an "exhaustion point," the script relies on the statistical concept of normal distribution. By applying a Simple Moving Average to the raw volatility data, it establishes a baseline mean of market stress. The inclusion of Standard Deviation bands (Bollinger Bands) allows the system to measure dispersion from this mean. When the volatility index breaches the upper band, it represents an anomaly—an event occurring outside the expected standard deviation threshold. Statistically, extreme deviations from the mean are unsustainable, implying an imminent reversion. This indicator isolates these rare deviations to time market entries.

[b]● The Role of True Range in Risk Normalization[/b]
Risk management within the script is governed by the Average True Range (ATR), a concept introduced by J. Welles Wilder. The True Range accounts for absolute price movement, including gap openings, providing a more comprehensive measure of market kinetic energy than standard percentage changes. By tying the Stop Loss and Take Profit levels dynamically to the ATR, the script automatically normalizes risk across different market environments. In a highly volatile state, the ATR expands, naturally widening the stop loss to avoid premature invalidation from market noise. In a compressed state, the ATR contracts, tightening the risk parameters. This dynamic adaptation ensures that the statistical risk profile of each trade setup remains proportional to the current localized market geometry.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Williams VIX Fix Elite [MarkitTick]", overlay=true, max_lines_count=50, max_labels_count=50, max_bars_back=500)

// ── INPUTS ─────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_wvfLen        = input.int(22, "WVF Lookback", minval=1, group=GRP_CORE)
i_bbLen         = input.int(20, "BB Length", minval=1, group=GRP_CORE)
i_bbMult        = input.float(2.0, "BB Mult", minval=0.1, step=0.1, group=GRP_CORE)
i_hhLen         = input.int(50, "Percentile HH Lookback", minval=1, group=GRP_CORE)
i_phPct         = input.float(0.85, "High % Threshold", minval=0.1, maxval=1.0, step=0.01, group=GRP_CORE)

var string GRP_FILT = "🕯️ Filters"
i_useHtf        = input.bool(false, "Use HTF Confirmation", group=GRP_FILT)
i_htfRes        = input.timeframe("240", "HTF Resolution", group=GRP_FILT)
i_useVolFilt    = input.bool(false, "Use Volatility Filter", group=GRP_FILT)
i_atrLen        = input.int(14, "ATR Length", minval=1, group=GRP_FILT)
i_atrMult       = input.float(1.0, "ATR Min Mult", minval=0.1, step=0.1, group=GRP_FILT)
i_useSpikeFilt  = input.bool(false, "Use Spike Strength Filter", group=GRP_FILT)
i_spikeMinPct   = input.float(5.0, "Min Spike Above BB %", minval=0.0, step=0.5, group=GRP_FILT)
i_useVolConfFilt = input.bool(false, "Use Volume Confirmation", group=GRP_FILT)
i_volConfLen    = input.int(20, "Volume Avg Length", minval=1, group=GRP_FILT)
i_volConfMult   = input.float(1.0, "Volume Min Mult", minval=0.1, step=0.1, group=GRP_FILT)
i_useTrendFilt  = input.bool(false, "Use Macro Trend Filter", group=GRP_FILT)
i_trendLen      = input.int(100, "Trend SMA Length", minval=1, group=GRP_FILT)
i_useCooldown   = input.bool(false, "Use Signal Cooldown", group=GRP_FILT)
i_cooldownBars  = input.int(5, "Min Bars Between Signals", minval=0, group=GRP_FILT)

var string GRP_TRADE = "📐 Trade Tools"
i_useTradeLvls  = input.bool(true, "Show Trade Levels", group=GRP_TRADE)
i_slAtrMult     = input.float(1.5, "SL ATR Mult", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp1R          = input.float(1.0, "TP1 R-Multiple", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp2R          = input.float(2.0, "TP2 R-Multiple", minval=0.1, step=0.1, group=GRP_TRADE)
i_tp3R          = input.float(3.0, "TP3 R-Multiple", minval=0.1, step=0.1, group=GRP_TRADE)

var string GRP_VIS = "🎨 Visuals"
i_showCandles   = input.bool(true, "Color Chart Candles", group=GRP_VIS)

var string GRP_DASH = "📊 Dashboard"
i_showDash      = input.bool(true, "Show Dashboard", group=GRP_DASH)
i_dashPos       = input.string("top_right", "Dashboard Position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=GRP_DASH)

var string GRP_WH = "🔔 Alerts"
i_actionLong        = input.string("long", "↑ Long Action", group=GRP_WH)
i_actionShort        = input.string("short", "↓ Short Action", group=GRP_WH)
i_actionCloseLong    = input.string("closelong", "✕ Close Long Action", group=GRP_WH)
i_actionCloseShort   = input.string("closeshort", "✕ Close Short Action", group=GRP_WH)

var string GRP_COL = "🌈 Colors"
c_bullCandle    = input.color(#26a69a, "Bull Candle Body", group=GRP_COL)
c_bearCandle    = input.color(#ef5350, "Bear Candle Body", group=GRP_COL)
c_neutCandle    = input.color(#787b86, "Neutral Candle Body", group=GRP_COL)
c_signalBar     = input.color(#ffeb3b, "Signal Highlight", group=GRP_COL)
c_slLine        = input.color(#ef5350, "SL Line", group=GRP_COL)
c_entryLine     = input.color(#2196f3, "Entry Line", group=GRP_COL)
c_tp1Line       = input.color(#26a69a, "TP1 Line", group=GRP_COL)
c_tp2Line       = input.color(#26a69a, "TP2 Line", group=GRP_COL)
c_tp3Line       = input.color(#26a69a, "TP3 Line", group=GRP_COL)
c_dashBg        = input.color(#0a0f1a, "Dashboard BG", group=GRP_COL)
c_dashHeaderBg  = input.color(#14b5cb, "Dashboard Header BG", group=GRP_COL)
c_dashLabelTxt  = input.color(#ffffff, "Dashboard Label Text", group=GRP_COL)
c_dashValBg     = input.color(#0d1117, "Dashboard Value BG", group=GRP_COL)

// ── CORE LOGIC ─────────────────────────────────────────────────
highestClose = ta.highest(close, i_wvfLen)
wvf = ((highestClose - low) / highestClose) * 100

basis = ta.sma(wvf, i_bbLen)
float _mt741a = ta.stdev(wvf, i_bbLen)
dev = i_bbMult * _mt741a
upperBB = basis + dev
lowerBB = basis - dev

rangeHigh = ta.highest(wvf, i_hhLen)[1] * i_phPct

atrVal = ta.atr(i_atrLen)
atrAvg = ta.sma(atrVal, i_atrLen)
volOk = i_useVolFilt ? atrVal >= atrAvg * i_atrMult : true

htfClosePrev1 = request.security(syminfo.tickerid, i_htfRes, close[1], lookahead=barmerge.lookahead_on)
htfEmaPrev = request.security(syminfo.tickerid, i_htfRes, ta.sma(close, 21)[1], lookahead=barmerge.lookahead_on)
htfEmaPrev2 = request.security(syminfo.tickerid, i_htfRes, ta.sma(close, 21)[2], lookahead=barmerge.lookahead_on)
htfBullBias = htfClosePrev1 > htfEmaPrev and htfEmaPrev > htfEmaPrev2
htfBearBias = htfClosePrev1 < htfEmaPrev and htfEmaPrev < htfEmaPrev2
htfOkLong = i_useHtf ? htfBullBias : true
htfOkShort = i_useHtf ? htfBearBias : true

wvfSpike = wvf >= upperBB or wvf >= rangeHigh
float _mt741f = ta.stdev(wvf, i_bbLen)
wvfZScore = _mt741f != 0 ? (wvf - basis) / _mt741f : 0.0
spikeStrengthOk = i_useSpikeFilt ? wvfZScore >= i_bbMult + (i_spikeMinPct / 10) : true

avgVolume = ta.sma(volume, i_volConfLen)
volConfOk = i_useVolConfFilt ? volume >= avgVolume * i_volConfMult and volume > volume[1] : true

trendEma = ta.sma(close, i_trendLen)
trendEmaPrev = trendEma[5]
trendUpOk = i_useTrendFilt ? close > trendEma and trendEma > trendEmaPrev : true
trendDownOk = i_useTrendFilt ? close < trendEma and trendEma < trendEmaPrev : true

var int lastSpikeBar = na
if wvfSpike and barstate.isconfirmed
    lastSpikeBar := bar_index
wvfRecentSpike = not na(lastSpikeBar) and (bar_index - lastSpikeBar) <= 5

reversalUp = close > open and close > close[1]
reversalDown = close < open and close < close[1]
wvfExhaustion = wvfSpike[1] or wvfSpike
longTrigger = wvfExhaustion and reversalUp
shortTrigger = ta.crossunder(wvf, basis) and wvfRecentSpike and reversalDown

var int barsSinceLongSignal = na
var int barsSinceShortSignal = na
cooldownOkLong = i_useCooldown ? na(barsSinceLongSignal) or (bar_index - barsSinceLongSignal) >= i_cooldownBars : true
cooldownOkShort = i_useCooldown ? na(barsSinceShortSignal) or (bar_index - barsSinceShortSignal) >= i_cooldownBars : true

longSignal = longTrigger and spikeStrengthOk and volOk and volConfOk and htfOkLong and trendUpOk and cooldownOkLong
shortSignal = shortTrigger and volOk and volConfOk and htfOkShort and trendDownOk and cooldownOkShort

if longSignal and barstate.isconfirmed
    barsSinceLongSignal := bar_index
if shortSignal and barstate.isconfirmed
    barsSinceShortSignal := bar_index

biasColor = longSignal and barstate.isconfirmed ? c_bullCandle : shortSignal and barstate.isconfirmed ? c_bearCandle : c_neutCandle

entryPrice = close[1]
float _mt741c = atrVal * i_slAtrMult
slDist = _mt741c
slPriceLong = entryPrice - slDist
tp1PriceLong = entryPrice + slDist * i_tp1R
tp2PriceLong = entryPrice + slDist * i_tp2R
tp3PriceLong = entryPrice + slDist * i_tp3R
slPriceShort = entryPrice + slDist
tp1PriceShort = entryPrice - slDist * i_tp1R
tp2PriceShort = entryPrice - slDist * i_tp2R
tp3PriceShort = entryPrice - slDist * i_tp3R

var int lvlStartBar = na
var bool lvlIsLong = bool(na)
var float lvlEntryPrice = na
var float lvlSlPrice = na
var float lvlTp1Price = na
var float lvlTp2Price = na
var float lvlTp3Price = na

if longSignal and barstate.isconfirmed
    lvlStartBar := bar_index
    lvlIsLong := true
    lvlEntryPrice := entryPrice
    lvlSlPrice := slPriceLong
    lvlTp1Price := tp1PriceLong
    lvlTp2Price := tp2PriceLong
    lvlTp3Price := tp3PriceLong
if shortSignal and barstate.isconfirmed
    lvlStartBar := bar_index
    lvlIsLong := false
    lvlEntryPrice := entryPrice
    lvlSlPrice := slPriceShort
    lvlTp1Price := tp1PriceShort
    lvlTp2Price := tp2PriceShort
    lvlTp3Price := tp3PriceShort

// ── ALERTS ─────────────────────────────────────────────────────
string _longInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp":"{5}"',
 i_actionLong, syminfo.tickerid, timeframe.period,
 str.tostring(lvlEntryPrice, format.mintick),
 str.tostring(lvlSlPrice, format.mintick),
 str.tostring(lvlTp1Price, format.mintick))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp":"{5}"',
 i_actionShort, syminfo.tickerid, timeframe.period,
 str.tostring(lvlEntryPrice, format.mintick),
 str.tostring(lvlSlPrice, format.mintick),
 str.tostring(lvlTp1Price, format.mintick))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}"',
 i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
 '"action":"{0}","ticker":"{1}","tf":"{2}"',
 i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

if longSignal and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if shortSignal and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if longSignal and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)

alertcondition(longSignal and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal and barstate.isconfirmed, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(longSignal and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")

tp1Hit = not na(lvlStartBar) and (lvlIsLong ? high >= lvlTp1Price : low <= lvlTp1Price)
tp2Hit = not na(lvlStartBar) and (lvlIsLong ? high >= lvlTp2Price : low <= lvlTp2Price)
tp3Hit = not na(lvlStartBar) and (lvlIsLong ? high >= lvlTp3Price : low <= lvlTp3Price)

string _tp1Inner = str.format(
 '"action":"tp1hit","ticker":"{0}","tf":"{1}","tp":"{2}"',
 syminfo.tickerid, timeframe.period,
 str.tostring(lvlTp1Price, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"

string _tp2Inner = str.format(
 '"action":"tp2hit","ticker":"{0}","tf":"{1}","tp":"{2}"',
 syminfo.tickerid, timeframe.period,
 str.tostring(lvlTp2Price, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"

string _tp3Inner = str.format(
 '"action":"tp3hit","ticker":"{0}","tf":"{1}","tp":"{2}"',
 syminfo.tickerid, timeframe.period,
 str.tostring(lvlTp3Price, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"

if tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)

alertcondition(tp1Hit, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(tp2Hit, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(tp3Hit, "TP3 Hit", "MarkitTick — TP3 Hit")

// ── VISUALS ────────────────────────────────────────────────────
plotcandle(open, high, low, close,
 title       = "Heatmap Candles",
 color       = i_showCandles ? biasColor : na,
 wickcolor   = i_showCandles ? biasColor : na,
 bordercolor = i_showCandles ? biasColor : na)

var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)

if i_useTradeLvls and (longSignal or shortSignal) and barstate.isconfirmed
    f_deleteLevels()
    slLine := line.new(bar_index, lvlSlPrice, bar_index, lvlSlPrice, color=c_slLine, style=line.style_solid, width=2)
    entryLine := line.new(bar_index, lvlEntryPrice, bar_index, lvlEntryPrice, color=c_entryLine, style=line.style_dashed, width=1)
    tp1Line := line.new(bar_index, lvlTp1Price, bar_index, lvlTp1Price, color=color.new(c_tp1Line, 40), style=line.style_dashed, width=1)
    tp2Line := line.new(bar_index, lvlTp2Price, bar_index, lvlTp2Price, color=color.new(c_tp2Line, 20), style=line.style_dashed, width=1)
    tp3Line := line.new(bar_index, lvlTp3Price, bar_index, lvlTp3Price, color=color.new(c_tp3Line, 0), style=line.style_dashed, width=1)
    slLbl := label.new(bar_index, lvlSlPrice, "✕ SL " + str.tostring(lvlSlPrice, format.mintick), style=label.style_label_left, color=c_slLine, textcolor=#ffffff, size=size.small)
    entryLbl := label.new(bar_index, lvlEntryPrice, "▶ Entry " + str.tostring(lvlEntryPrice, format.mintick), style=label.style_label_left, color=c_entryLine, textcolor=#ffffff, size=size.small)
    tp1Lbl := label.new(bar_index, lvlTp1Price, "◆ TP1 " + str.tostring(lvlTp1Price, format.mintick), style=label.style_label_left, color=c_tp1Line, textcolor=#ffffff, size=size.small)
    tp2Lbl := label.new(bar_index, lvlTp2Price, "✦ TP2 " + str.tostring(lvlTp2Price, format.mintick), style=label.style_label_left, color=c_tp2Line, textcolor=#ffffff, size=size.small)
    tp3Lbl := label.new(bar_index, lvlTp3Price, "◆ TP3 " + str.tostring(lvlTp3Price, format.mintick), style=label.style_label_left, color=c_tp3Line, textcolor=#ffffff, size=size.small)
    riskFill := linefill.new(slLine, entryLine, color.new(c_slLine, 80))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(c_tp3Line, 85))

if not na(slLine) and not na(lvlStartBar) and bar_index <= lvlStartBar + 50
    int lvlExtBar = lvlStartBar + 50
    line.set_x2(slLine, lvlExtBar)
    line.set_x2(entryLine, lvlExtBar)
    line.set_x2(tp1Line, lvlExtBar)
    line.set_x2(tp2Line, lvlExtBar)
    line.set_x2(tp3Line, lvlExtBar)
    label.set_x(slLbl, lvlExtBar)
    label.set_x(entryLbl, lvlExtBar)
    label.set_x(tp1Lbl, lvlExtBar)
    label.set_x(tp2Lbl, lvlExtBar)
    label.set_x(tp3Lbl, lvlExtBar)

// ── DASHBOARD ──────────────────────────────────────────────────
f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

var string dashPosition = switch i_dashPos
    "top_right"    => position.top_right
    "top_left"     => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left"  => position.bottom_left

var table dash = table.new(dashPosition, 2, 12, bgcolor=c_dashBg)

if i_showDash
    table.cell(dash, 0, 0, "MT-WVF", text_color=#ffffff, bgcolor=c_dashHeaderBg, text_size=size.normal)
    table.cell(dash, 1, 0, "", bgcolor=c_dashHeaderBg)

    table.cell(dash, 0, 1, "WVF Value", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(wvf, format.mintick), text_color=#ffffff, bgcolor=c_dashValBg, text_size=size.small)

    wvfPct = math.min(wvf / rangeHigh, 1.0)
    table.cell(dash, 0, 2, "Spike Level", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 2, f_bar(wvf, rangeHigh), text_color=f_barColor(wvfPct), bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 3, "BB Basis", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(basis, format.mintick), text_color=#ffffff, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 4, "HTF Bias", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 4, htfBullBias ? "Bullish" : "Bearish", text_color=htfBullBias ? c_bullCandle : c_bearCandle, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 5, "Trend Bias", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    trendTxt = close > trendEma ? "Bullish" : "Bearish"
    trendClr = close > trendEma ? c_bullCandle : c_bearCandle
    table.cell(dash, 1, 5, trendTxt, text_color=trendClr, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 6, "Volume", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    volTxt = volume >= avgVolume ? "Above Avg" : "Below Avg"
    volClr = volume >= avgVolume ? c_bullCandle : c_bearCandle
    table.cell(dash, 1, 6, volTxt, text_color=volClr, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 7, "ATR", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(atrVal, format.mintick), text_color=#ffffff, bgcolor=c_dashValBg, text_size=size.small)

    rrRatio = slDist != 0 ? (tp3PriceLong - entryPrice) / slDist : 0.0
    rrPct = math.min(rrRatio / 5.0, 1.0)
    table.cell(dash, 0, 8, "R:R Ratio", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    table.cell(dash, 1, 8, f_bar(rrRatio, 5.0), text_color=f_barColor(rrPct), bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 9, "Cooldown L", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    cooldownLongTxt = not i_useCooldown ? "Disabled" : na(barsSinceLongSignal) ? "Ready" : (bar_index - barsSinceLongSignal) >= i_cooldownBars ? "Ready" : str.tostring(i_cooldownBars - (bar_index - barsSinceLongSignal)) + " bars left"
    table.cell(dash, 1, 9, cooldownLongTxt, text_color=#ffffff, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 10, "Cooldown S", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    cooldownShortTxt = not i_useCooldown ? "Disabled" : na(barsSinceShortSignal) ? "Ready" : (bar_index - barsSinceShortSignal) >= i_cooldownBars ? "Ready" : str.tostring(i_cooldownBars - (bar_index - barsSinceShortSignal)) + " bars left"
    table.cell(dash, 1, 10, cooldownShortTxt, text_color=#ffffff, bgcolor=c_dashValBg, text_size=size.small)

    table.cell(dash, 0, 11, "Signal", text_color=c_dashLabelTxt, bgcolor=c_dashBg, text_size=size.small)
    signalTxt = longSignal and barstate.isconfirmed ? "LONG" : shortSignal and barstate.isconfirmed ? "SHORT" : "NONE"
    signalClr = longSignal and barstate.isconfirmed ? c_bullCandle : shortSignal and barstate.isconfirmed ? c_bearCandle : c_neutCandle
    table.cell(dash, 1, 11, signalTxt, text_color=signalClr, bgcolor=c_dashValBg, text_size=size.small)
````
