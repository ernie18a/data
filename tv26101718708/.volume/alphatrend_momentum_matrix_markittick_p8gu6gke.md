# AlphaTrend Momentum Matrix [MarkitTick]

- url: https://www.tradingview.com/script/P8Gu6Gke-AlphaTrend-Momentum-Matrix-MarkitTick/
- type: indicator
- pine_id: PUB;4e053c2e9e42489e94cfb6afc0355998
- version: 3.0

## Description

💡 The AlphaTrend Momentum Matrix is an advanced, comprehensive trend-following architecture designed to dynamically track market momentum, manage dynamic trade states, and seamlessly bridge the gap between technical charting and automated execution. Far from a simple overlay, this script acts as a multi-layered analytical suite. It evaluates primary trend direction using volatility and volume-weighted money flow, filters out market noise with a custom state-matrix, and projects actionable higher-timeframe data onto the active chart. Furthermore, it incorporates an internal mathematical framework capable of dynamically calculating strict risk-to-reward targets and dispatching meticulously formatted JSON payloads for external webhook execution. 

[b]✨ Originality and Utility[/b]

[b]● The Momentum Matrix Advantage[/b]
While traditional trend indicators rigidly lock onto moving averages or standard price bands, the AlphaTrend Momentum Matrix thrives on market dynamism. Its true utility lies in its multifaceted approach to trend validation. It introduces an exclusive "ATR Breakout Override" system—a custom logic module that forces a trend recalibration if an explosive price movement severely disrupts the standard deviation envelope, regardless of standard trailing conditions. This ensures the indicator remains highly responsive to sudden, high-impact market events without waiting for lagging conditions to catch up.

[b]● Automated Payload and State Management[/b]
A standout feature of this tool is its embedded Trade State system. It does not merely paint a signal on the chart; it internalizes the exact entry price, computes a precise stop-loss based on the active AlphaTrend baseline, and mathematically projects a 1:2 risk-to-reward Take Profit target. This localized tracking seamlessly interfaces with the built-in Alert Engine, dynamically injecting these critical metrics into formatted JSON templates ready for third-party automated execution systems. 

[b]🔬 Methodology and Concepts[/b]

[b]● AlphaTrend Core Engine[/b]
The primary directional engine relies on the interplay between the Average True Range (ATR) and the Money Flow Index (MFI). A trailing upper band (Support) and lower band (Resistance) are calculated using a user-defined ATR coefficient. The script interrogates the 14-period MFI; if the MFI reads above 50, indicating positive money flow momentum, the algorithm biases toward the Support band, updating it only when the price makes higher lows. Conversely, an MFI below 50 shifts the bias to the Resistance band.

[b]● Breakout Override Protocol[/b]
To counteract the inherent lag of volume-weighted smoothing, the indicator employs a momentum breakout scanner. By measuring the absolute distance between the previous two closing prices and comparing it against the prior ATR multiplied by a sensitivity factor, the script can definitively detect volatility shocks. If a shock occurs concurrently with a directional price cross over the active AlphaTrend line, the system immediately forces a directional shift, bypassing the standard MFI requirements.

[b]● Signal Filtering and Matrix Constraints[/b]
Raw signal crossovers are notoriously noisy during consolidation. To mitigate whipsaw trades, this script implements a continuous loop counter (the K and O matrices). It tracks the consecutive bars since the last primary buy or sell condition. A signal is only declared "valid" if it successfully breaks the historical sequence of the opposing trend counter, ensuring that localized micro-fluctuations do not trigger premature trade entries. 

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]● Volatility and the Average True Range[/b]
Developed by J. Welles Wilder Jr. in 1978, the Average True Range is a foundational pillar of this indicator. The ATR scientifically quantifies absolute market volatility by decomposing the entire range of an asset's periodic price action, factoring in gaps and limit moves. By applying a multiplier to the ATR, this script establishes a statistically significant standard deviation envelope, distinguishing between normal market "breathing" and definitive structural shifts.

[b]● Volume-Weighted Momentum via Money Flow Index[/b]
The MFI, created by Gene Quigley and Colin Dysart, represents an evolution of the Relative Strength Index (RSI). From an academic standpoint, the MFI incorporates volume into its momentum calculation, producing a more robust metric of buying and selling pressure. It uses the Typical Price (High + Low + Close / 3) multiplied by volume to calculate raw money flow. The 50-level threshold serves as the equilibrium point; sustaining above this level empirically signifies net accumulation, providing the mathematical justification for the indicator's bullish bias.

[b]● Algorithmic State Machines[/b]
The signal filtering mechanism and the internal Trade State tracker are practical applications of Finite State Machines (FSM) commonly used in quantitative algorithmic design. The script holds memory of its current operational state (Long, Short, Neutral) and refuses state transitions unless specifically validated mathematical conditions (boolean logic gates) are met, significantly reducing error rates inherent in purely reactive, memory-less indicators.

[b]● Repainting and Lookahead Warning[/b]
This script utilizes the request component to pull Higher Timeframe (HTF) context into the primary chart. Crucially, it employs the [i]barmerge.lookahead_on[/i] parameter. While this creates a visually perfect, non-lagging representation of higher timeframe trends when analyzing historical data, it introduces lookahead bias. Traders must understand that historical HTF visuals and signals may appear with perfect precision on past bars, but real-time execution will lack this future data context, potentially resulting in different localized behavior in live markets.

[b]🎨 Visual Guide[/b]

[b]● The AlphaTrend Trailing Line[/b]
[list]
[*] [b]Up Trend (Bullish):[/b] A bold, solid step-line tracking below the price, rendered in a distinctive golden-yellow (#F0D080).
[*] [b]Down Trend (Bearish):[/b] A bold, solid step-line tracking above the price, colored in a deep crimson (#7A2010).
[/list]

[b]● The Cloud Fill[/b]
[list]
[*] [b]Dynamic Channel:[/b] A semi-transparent shaded area connecting the active AlphaTrend line to a central Cloud Reference Line (a smoothing of the typical price). This cloud visually represents the buffer zone of the current trend. 
[*] [b]Color Coding:[/b] The cloud dynamically changes color to match the dominant trend (Gold for bullish, Crimson for bearish), allowing for rapid peripheral analysis of market conditions.
[/list]

[b]● Price Action Overrides[/b]
[list]
[*] [b]Colored Candles:[/b] The bodies and wicks of the actual price candles are uniformly colored to reflect the AlphaTrend matrix state, instantly identifying periods of alignment or divergence.
[/list]

[b]● Execution Elements[/b]
[list]
[*] [b]Signal Labels:[/b] Distinct "BUY" and "SELL" textual shapes appear precisely on the chart at the moment the state matrix validates a trend shift.
[*] [b]HTF Stepline:[/b] When enabled, a secondary, smoothed step-line appears to show the overarching macro trend, colored accordingly to dictate the broader market regime.
[/list]

[b]📖 How to Use[/b]

[b]● Trend Riding and Context[/b]
The most effective way to utilize this tool is to align the primary chart timeframe with the HTF AlphaTrend line. If the HTF line is Gold, you should strictly look for "BUY" signals generated by the primary indicator to trade in the direction of the macro trend, ignoring temporary bearish signals as minor pullbacks.

[b]● Momentum Breakout Confirmation[/b]
When you observe a sudden color change accompanied by an unusually large price bar, this is often the Breakout Override triggering. These scenarios represent high-momentum events. Instead of waiting for a retest, aggressive traders may use these specific signals to capture immediate volatility expansions, placing their stop-loss strictly on the opposite side of the newly formed AlphaTrend line.

[b]● Automating Your Strategy[/b]
For quantitative traders, the indicator handles the heavy lifting of trade logic. Ensure you configure the exact JSON payload strings required by your third-party execution platform (like 3Commas, PineConnector, etc.) in the settings. The indicator will autonomously calculate your risk/reward parameters upon every valid signal and fire a perfectly formatted JSON alert.

[b]⚙️ Inputs and Settings[/b]

[b]• ⚙️ Core Calculations[/b]
[list]
[*] [b]ATR Multiplier:[/b] Defines the sensitivity of the trailing line. Lower values (e.g., 0.5) track price closely for scalping; higher values (e.g., 2.0) provide wide breathing room for swing trades.
[*] [b]ATR & MFI Lookback Period:[/b] The standard window (default 14) for calculating both volatility and volume momentum.
[*] [b]Display Signals:[/b] Toggles the visibility of the "BUY" and "SELL" chart labels.
[/list]

[b]• 🛡️ Breakout Override[/b]
[list]
[*] [b]Enable ATR Breakout Override:[/b] Turns the momentum-shock detection system on or off.
[*] [b]Breakout Sensitivity:[/b] Determines how large a price jump must be (relative to the ATR) to force a trend change. Lower values trigger more aggressively.
[/list]

[b]• 🕐 Higher Timeframe[/b]
[list]
[*] [b]Show HTF AlphaTrend:[/b] Projects the higher timeframe data onto the current chart.
[*] [b]HTF Timeframe:[/b] The specific macro timeframe to monitor (e.g., Daily "D" when trading on the 1-Hour chart).
[/list]

[b]• ☁️ Cloud Fill[/b]
[list]
[*] [b]Show Cloud Fill:[/b] Toggles the visual buffer zone on the chart.
[*] [b]Cloud Reference Length:[/b] Adjusts the smoothing period of the central reference line.
[*] [b]Color Candles:[/b] Enables or disables the overriding of standard chart candle colors based on trend direction.
[/list]

[b]• 🔌 Webhook Execution Config[/b]
[list]
[*] [b]Payload Actions:[/b] Four distinct text fields where you can define the exact syntax your external bot requires for entering longs, entering shorts, closing longs, and closing shorts. These values are automatically injected into the dynamic JSON alert string.
[/list]

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// © MarkitTick
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/

//@version=6
indicator("AlphaTrend Momentum Matrix [MarkitTick]", overlay=true, format=format.price, precision=2)

// ── GROUPS ────────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Calculations"
var string GRP_VIS  = "🎨 Display Configuration"
var string GRP_CF   = "☁️ Cloud Fill"
var string GRP_BO   = "🛡️ Breakout Override"
var string GRP_WH   = "🔌 Webhook Execution Config"
var string GRP_HTF  = "🕐 Higher Timeframe"
var string GRP_DASH = "📊 Dashboard Settings"

// ── CORE ──────────────────────────────────────────────────────────
float coeff        = input.float(1.0,  "ATR Multiplier (Coefficient)", step=0.1, group=GRP_CORE)
int   AP           = input.int  (14,   "ATR & MFI Lookback Period",    minval=1, group=GRP_CORE)
bool  showsignalsk = input.bool (true, "Display Entry/Exit Signals",             group=GRP_CORE)

// ── BREAKOUT OVERRIDE ─────────────────────────────────────────────
bool  overrideEnabled     = input.bool (true, "Enable ATR Breakout Override",          group=GRP_BO)
float overrideSensitivity = input.float(2.0,  "ATR Breakout Sensitivity (Multiplier)", step=0.1, group=GRP_BO)

// ── HTF ───────────────────────────────────────────────────────────
bool   i_htf_show = input.bool     (false, "Show HTF AlphaTrend", group=GRP_HTF)
string i_htf_tf   = input.timeframe("D",   "HTF Timeframe",       group=GRP_HTF)

// ── CLOUD ─────────────────────────────────────────────────────────
bool  i_cf_show    = input.bool(true, "Show Cloud Fill",        group=GRP_CF)
int   i_cf_len     = input.int (8,    "Cloud Reference Length", minval=1, maxval=50, group=GRP_CF)
int   i_cf_transp  = input.int (65,   "Cloud Transparency",     minval=0, maxval=95, group=GRP_CF)
bool  i_cf_candles = input.bool(true, "Color Candles",          group=GRP_CF)
int   i_cf_ctransp = input.int (20,   "Candle Transparency",    minval=0, maxval=95, group=GRP_CF)

// ── VISUALS ───────────────────────────────────────────────────────
color i_vis_ua = input.color(#F0D080, "Bull Color",    group=GRP_VIS, inline="col")
color i_vis_da = input.color(#7A2010, "Bear Color",    group=GRP_VIS, inline="col")
color i_vis_cn = input.color(#8C7B6B, "Neutral Color", group=GRP_VIS, inline="col")

// ── DASHBOARD INPUTS ──────────────────────────────────────────────
color i_dashBg  = input.color(color.rgb(15, 15, 20, 10),   "Background", group=GRP_DASH)
color i_dashTxt = input.color(color.rgb(220, 220, 220, 0), "Text Core",  group=GRP_DASH)
color i_dashTp  = input.color(color.rgb(0, 255, 100),      "TP Text",    group=GRP_DASH)
color i_dashSl  = input.color(color.rgb(255, 60, 60),      "SL Text",    group=GRP_DASH)

// ── WEBHOOK ───────────────────────────────────────────────────────
string i_wh_long       = input.string("long",       "Long Action Payload",  group=GRP_WH)
string i_wh_short      = input.string("short",      "Short Action Payload", group=GRP_WH)
string i_wh_closelong  = input.string("closelong",  "Close Long Payload",   group=GRP_WH)
string i_wh_closeshort = input.string("closeshort", "Close Short Payload",  group=GRP_WH)

var string JSON_TEMPLATE = '"action": "{0}", "ticker": "{1}", "tf": "{2}", "entry": "{3}", "tp": "{4}", "sl": "{5}"'

// ── UDT ───────────────────────────────────────────────────────────
type TradeState
    bool  isLong  = false
    bool  isShort = false
    float entry   = 0.0
    float sl      = 0.0
    float tp      = 0.0
    bool  active  = false

method calcRiskTargets(TradeState this, float _close, float _atLine) =>
    float _risk = math.max(math.abs(_close - _atLine), syminfo.mintick * 10)
    if this.isLong
        this.entry := _close
        this.sl    := _atLine
        this.tp    := _close + (_risk * 2.0)
    if this.isShort
        this.entry := _close
        this.sl    := _atLine
        this.tp    := _close - (_risk * 2.0)

// ── ALPHATREND CALCULATION ────────────────────────────────────────
// Confirmed-bar inputs only — no live-tick pollution
float ATR    = ta.sma(ta.tr[1], AP)
float upT    = low[1]  - ATR * coeff
float downT  = high[1] + ATR * coeff
float mfiVal = ta.mfi(hlc3[1], AP)

float AlphaTrend = 0.0
AlphaTrend := mfiVal >= 50 ? (upT < nz(AlphaTrend[1]) ? nz(AlphaTrend[1]) : upT) : (downT > nz(AlphaTrend[1]) ? nz(AlphaTrend[1]) : downT)

// ── DIRECTION & TREND AGE ─────────────────────────────────────────
var int direction = 1
if AlphaTrend[1] > AlphaTrend[3]
    direction := 1
else if AlphaTrend[1] < AlphaTrend[3]
    direction := -1

var int trendAge = 0
trendAge := direction != nz(direction[1]) ? 1 : nz(trendAge) + 1

// ── BREAKOUT OVERRIDE ─────────────────────────────────────────────
bool isCrossUp   = close[1] > AlphaTrend[1] and close[2] <= nz(AlphaTrend[2])
bool isCrossDn   = close[1] < AlphaTrend[1] and close[2] >= nz(AlphaTrend[2])
bool _boMomentum = overrideEnabled and (math.abs(close[1] - close[2]) > ATR[1] * overrideSensitivity)

if _boMomentum and isCrossUp
    direction := 1
else if _boMomentum and isCrossDn
    direction := -1

// ── SIGNAL SYSTEM ─────────────────────────────────────────────────
// AlphaTrend[1] = confirmed prior bar; AlphaTrend[3] confirmed 3-bars ago
bool isTrendCrossUp = AlphaTrend[1] > AlphaTrend[3] and nz(AlphaTrend[2]) <= nz(AlphaTrend[4])
bool isTrendCrossDn = AlphaTrend[1] < AlphaTrend[3] and nz(AlphaTrend[2]) >= nz(AlphaTrend[4])

bool buySignalk  = isTrendCrossUp or (_boMomentum and isCrossUp)
bool sellSignalk = isTrendCrossDn or (_boMomentum and isCrossDn)

var int K1 = 0
var int K2 = 0
var int O1 = 0
var int O2 = 0

// All four counters operate on confirmed [1]-offset signals — symmetric lag, no asymmetry defect
O1 := buySignalk[1]  ? 0 : O1 + 1
O2 := sellSignalk[1] ? 0 : O2 + 1
K1 := buySignalk[1]  ? 0 : K1 + 1  // [1] — matches O1/O2 lag; eliminates 1-bar asymmetry
K2 := sellSignalk[1] ? 0 : K2 + 1  // [1] — matches O1/O2 lag; eliminates 1-bar asymmetry

bool validLong  = buySignalk  and O1 > K2
bool validShort = sellSignalk and O2 > K1

// ── HTF REQUEST ───────────────────────────────────────────────────
float htfAT         = request.security(syminfo.tickerid, i_htf_tf, AlphaTrend[1], lookahead=barmerge.lookahead_on)
int   htfDir        = request.security(syminfo.tickerid, i_htf_tf, direction[1],  lookahead=barmerge.lookahead_on)
bool  htfValidLong  = request.security(syminfo.tickerid, i_htf_tf, validLong[1],  lookahead=barmerge.lookahead_on)
bool  htfValidShort = request.security(syminfo.tickerid, i_htf_tf, validShort[1], lookahead=barmerge.lookahead_on)

bool _htfNewBar = ta.change(time(i_htf_tf))[1] != 0  // [1] — confirmed bar boundary; prevents intra-bar HTF shape repainting

// ── VISUALS ───────────────────────────────────────────────────────
color _dirCol = direction == 1 ? i_vis_ua : direction == -1 ? i_vis_da : i_vis_cn

plot_up   = plot(not i_htf_show and direction ==  1 ? AlphaTrend : na, "Up Trend",   color=i_vis_ua, linewidth=3, style=plot.style_linebr, display=display.pane)
plot_down = plot(not i_htf_show and direction == -1 ? AlphaTrend : na, "Down Trend", color=i_vis_da, linewidth=3, style=plot.style_linebr, display=display.pane)

float _cloudRef = ta.sma(hlc3[1], i_cf_len)  // [1] — confirmed bars only; eliminates intra-bar cloud boundary repainting
float _cloudMid = (AlphaTrend + _cloudRef) / 2.0

plot_tl  = plot(AlphaTrend, "TL Anchor", color=color.new(chart.fg_color, 100), display=display.none)
plot_mid = plot(_cloudMid,  "Cloud Mid", color=color.new(chart.fg_color, 100), display=display.none)
plot_ref = plot(_cloudRef,  "Cloud Ref", color=color.new(chart.fg_color, 100), display=display.none)

bool _showCloud = i_cf_show and not i_htf_show
int  _tOuter    = math.min(i_cf_transp + 25, 95)

fill(plot_tl,  plot_mid, AlphaTrend, _cloudMid, _showCloud ? color.new(_dirCol, i_cf_transp) : na, _showCloud ? color.new(_dirCol, _tOuter)     : na)
fill(plot_mid, plot_ref, _cloudMid,  _cloudRef,  _showCloud ? color.new(_dirCol, _tOuter)     : na, color(na))

bool  _showCandles = i_cf_candles
color _candleCol   = _showCandles ? color.new(_dirCol, i_cf_ctransp) : na

barcolor(_candleCol)
plotcandle(
     _showCandles ? open  : na,
     _showCandles ? high  : na,
     _showCandles ? low   : na,
     _showCandles ? close : na,
     color       = _candleCol,
     bordercolor = _candleCol,
     wickcolor   = _candleCol,
     display     = display.pane)

color _htfCol = htfDir == 1 ? i_vis_ua : htfDir == -1 ? i_vis_da : i_vis_cn
plot(i_htf_show ? htfAT : na, "HTF AlphaTrend", color=_htfCol, linewidth=2, style=plot.style_stepline, display=display.pane)

plotshape(
     not i_htf_show and validLong  and showsignalsk ? AlphaTrend[2] * 0.9999 : na,
     title="BUY",  text="BUY",  location=location.absolute,
     style=shape.labelup,   size=size.tiny,
     color=color.new(i_vis_ua, 20), textcolor=color.white, display=display.pane)

plotshape(
     not i_htf_show and validShort and showsignalsk ? AlphaTrend[2] * 1.0001 : na,
     title="SELL", text="SELL", location=location.absolute,
     style=shape.labeldown, size=size.tiny,
     color=color.new(i_vis_da, 20), textcolor=color.white, display=display.pane)

plotshape(
     i_htf_show and htfValidLong  and showsignalsk and _htfNewBar ? htfAT * 0.9999 : na,
     title="HTF BUY",  text="BUY",  location=location.absolute,
     style=shape.labelup,   size=size.tiny,
     color=color.new(i_vis_ua, 20), textcolor=color.white, display=display.pane)

plotshape(
     i_htf_show and htfValidShort and showsignalsk and _htfNewBar ? htfAT * 1.0001 : na,
     title="HTF SELL", text="SELL", location=location.absolute,
     style=shape.labeldown, size=size.tiny,
     color=color.new(i_vis_da, 20), textcolor=color.white, display=display.pane)

// ── TRADE STATE ───────────────────────────────────────────────────
var TradeState tradeData = TradeState.new()

// bar_index >= 4 guard: AlphaTrend[4] requires 4 confirmed bars; prevents na[1] → spurious bar-0 signal
bool _risingLong  = bar_index >= 4 and validLong  and not validLong[1]
bool _risingShort = bar_index >= 4 and validShort and not validShort[1]

tradeData.isLong  := validLong
tradeData.isShort := validShort
tradeData.active  := _risingLong or _risingShort

if tradeData.active
    tradeData.calcRiskTargets(close[1], AlphaTrend[1])

bool _slHitLong  = (K1 < K2) and (close[1] < AlphaTrend[1])
bool _slHitShort = (K2 < K1) and (close[1] > AlphaTrend[1])

var bool isClosed = true
if _risingLong or _risingShort
    isClosed := false

// ── DASHBOARD HELPER ──────────────────────────────────────────────
f_momBar(float score) =>
    int    n = math.min(math.round(score / 3.0 * 10.0), 10)
    string s = ""
    for i = 1 to 10
        s += i <= n ? "█" : "░"
    s

f_momColor(float score) =>
    score >= 2.5 ? color.rgb(0,   255, 120) : score >= 1.5 ? color.rgb(80,  255, 0) : score >= 0.8 ? color.rgb(200, 200, 0) : color.rgb(110, 110, 110)

float atrSma = ta.sma(ATR, 50)

// ── DARK-MODE ANALYTICS DASHBOARD ─────────────────────────────────
// Runs every bar — table.cell overwrites cells in-place (self-cleaning, no barstate.islast)
var table dash = table.new(position.top_right, 2, 10, bgcolor=i_dashBg, border_width=1, border_color=color.rgb(45, 45, 55))

float atDist   = math.abs(close[1] - AlphaTrend[1])
float momScore = ATR > 0.0 ? atDist / ATR : 0.0

string volState = ATR > atrSma ? "📈 Expansion" : "📉 Contraction"
color  volCol   = ATR > atrSma ? color.rgb(180, 120, 255) : color.rgb(100, 200, 255)

string mfiState = mfiVal >= 80 ? "⚠️ Overbought" : mfiVal <= 20 ? "⚠️ Oversold" : "⚖️ Normal"
color  mfiCol   = mfiVal >= 80 ? color.rgb(255, 80, 80) : mfiVal <= 20 ? color.rgb(0, 255, 120) : i_dashTxt

color hdrBg = color.rgb(30, 30, 45, 10)
color altBg = color.rgb(20, 20, 25, 10)

table.cell(dash, 0, 0, "Metrics", text_color=color.white, text_size=size.small, bgcolor=hdrBg, text_halign=text.align_left)
table.cell(dash, 1, 0, "Analytics",  text_color=color.white, text_size=size.small, bgcolor=hdrBg, text_halign=text.align_right)

table.cell(dash, 0, 1, "Trend State", text_color=i_dashTxt, text_size=size.small, bgcolor=altBg, text_halign=text.align_left)
table.cell(dash, 1, 1, direction == 1 ? "▲  BULLISH" : "▼  BEARISH", text_color = direction == 1 ? i_vis_ua : i_vis_da, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)

table.cell(dash, 0, 2, "Entry Trigger", text_color=i_dashTxt, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 2, str.tostring(tradeData.entry, format.mintick), text_color=color.white, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 3, "Target (TP)", text_color=i_dashTxt, text_size=size.small, bgcolor=altBg, text_halign=text.align_left)
table.cell(dash, 1, 3, str.tostring(tradeData.tp, format.mintick), text_color=i_dashTp, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)

table.cell(dash, 0, 4, "Stop Loss (SL)", text_color=i_dashTxt, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 4, str.tostring(tradeData.sl, format.mintick), text_color=i_dashSl, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 5, "⚡ Momentum", text_color=i_dashTxt, text_size=size.small, bgcolor=altBg, text_halign=text.align_left)
table.cell(dash, 1, 5, f_momBar(momScore), text_color=f_momColor(momScore), text_size=size.small, bgcolor=altBg, text_halign=text.align_right)

table.cell(dash, 0, 6, "🌊 Money Flow", text_color=i_dashTxt, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 6, mfiState, text_color=mfiCol, text_size=size.small, text_halign=text.align_right)

table.cell(dash, 0, 7, "📊 Volatility", text_color=i_dashTxt, text_size=size.small, bgcolor=altBg, text_halign=text.align_left)
table.cell(dash, 1, 7, volState, text_color=volCol, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)

table.cell(dash, 0, 8, "⏳ Trend Age", text_color=i_dashTxt, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 8, str.tostring(trendAge) + " Bars", text_color=color.rgb(200, 200, 200), text_size=size.small, text_halign=text.align_right)

string htfLabel = htfDir == 1 ? "▲ BULLISH (" + i_htf_tf + ")" : htfDir == -1 ? "▼ BEARISH (" + i_htf_tf + ")" : "○ NEUTRAL (" + i_htf_tf + ")"
color  htfColor = htfDir == 1 ? i_vis_ua : htfDir == -1 ? i_vis_da : i_vis_cn
table.cell(dash, 0, 9, "HTF Context", text_color=i_dashTxt, text_size=size.small, bgcolor=altBg, text_halign=text.align_left)
table.cell(dash, 1, 9, i_htf_show ? htfLabel : "Disabled", text_color=htfColor, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)

// ── ALERT ENGINE ──────────────────────────────────────────────────
if barstate.isconfirmed
    if _risingLong
        string _innerJson = str.format(JSON_TEMPLATE, i_wh_long, syminfo.tickerid, timeframe.period, str.tostring(tradeData.entry, format.mintick), str.tostring(tradeData.tp, format.mintick), str.tostring(tradeData.sl, format.mintick))
        alert("{" + _innerJson + "}", alert.freq_once_per_bar_close)
    else if _risingShort
        string _innerJson = str.format(JSON_TEMPLATE, i_wh_short, syminfo.tickerid, timeframe.period, str.tostring(tradeData.entry, format.mintick), str.tostring(tradeData.tp, format.mintick), str.tostring(tradeData.sl, format.mintick))
        alert("{" + _innerJson + "}", alert.freq_once_per_bar_close)
    else if not isClosed
        if _slHitLong
            string _innerJson = str.format(JSON_TEMPLATE, i_wh_closelong, syminfo.tickerid, timeframe.period, str.tostring(close[1], format.mintick), "0", "0")
            alert("{" + _innerJson + "}", alert.freq_once_per_bar_close)
            isClosed := true
        else if _slHitShort
            string _innerJson = str.format(JSON_TEMPLATE, i_wh_closeshort, syminfo.tickerid, timeframe.period, str.tostring(close[1], format.mintick), "0", "0")
            alert("{" + _innerJson + "}", alert.freq_once_per_bar_close)
            isClosed := true
````
