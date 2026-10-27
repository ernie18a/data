# Liquidity Entry Signals [MarkitTick]

- url: https://www.tradingview.com/script/ksaH55U2-Liquidity-Entry-Signals-MarkitTick/
- type: indicator
- pine_id: PUB;dfde5b292ff34ba9aaee431d7ab90b5d
- version: 1.0

## Description

💡 A comprehensive, multi-faceted approach to identifying potential market reversals based on classic liquidity sweep mechanics. By scanning for instances where price briefly breaches a significant structural high or low before immediately rejecting and closing back within the range, this tool highlights areas where trap-based price dynamics may be in play. It is designed to offer a complete trading framework rather than just a simple signal, integrating dynamic stop-loss and take-profit plotting, real-time advanced dashboard analytics, and comprehensive alert payloads. This indicator assists in bridging the gap between raw price action analysis and structured trade management.

[b]● ✨ Originality and Utility[/b]

Many basic technical indicators simply look for higher highs or lower lows without assessing the quality of the rejection. This script elevates that concept by requiring strict closing conditions to validate a sweep. What truly sets it apart is its integration of multiple intelligent filters. Rather than relying on price action alone, users can mandate that sweeps align with the prevailing trend, occur during periods of sufficient volatility, and are backed by relative volume strength. 

Additionally, the built-in risk management visualizations automatically calculate position risk parameters right on the chart. By projecting stop-loss and take-profit levels based on current volatility, it transforms a static signal into an actionable trade plan. The inclusion of dynamic JSON payload generation for alerts also makes this an incredibly versatile tool for those looking to automate their execution through third-party platforms.

[b]● 🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/YuM3fjrp/[/image]
The core logic of this script is built around the concept of a liquidity sweep, verified through price action closes, and filtered through statistical market conditions.

[list]
[*] Bullish Sweep: The script continuously calculates the lowest low over a user-defined lookback window. A valid bullish signal occurs when the current bar's lowest price penetrates this recent low, but the closing price decisively reclaims it by closing higher than the structural low and higher than its own open.
[*] Bearish Sweep: Conversely, the script identifies the highest high over the recent lookback period. If the current bar's high breaches this level, but the close falls below the recent high and below its own open, a short signal is triggered.
[*] Trend Filtration: The indicator uses a Simple Moving Average (SMA) on both the current chart and a selected higher timeframe to establish a directional bias. Signals that conflict with these moving average baselines are suppressed to prevent counter-trend trading.
[*] Volatility and Volume Analysis: The script evaluates the Average True Range (ATR) as a percentage of the current closing price to ensure sufficient market movement is present. It also compares the current volume to a standard moving average of volume, filtering out setups that lack participation.
[/list]

[b]● 🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/mxQpVBO5/[/image]
The script draws extensive visual overlays to assist in real-time decision-making and trade management.

[b]• Signal Labels[/b]
When a valid sweep occurs, an "LS" label is plotted. Green labels positioned below the candle indicate bullish setups, while red labels above indicate bearish setups.

[b]• Trade Execution Lines[/b]
Upon a signal, the indicator projects trade management lines directly on the chart for the next 50 bars.
[list]
[*] Entry Line: A dashed blue line marking the closing price of the signal bar.
[*] Stop Loss (SL): A solid red line placed away from the entry, calculated based on the ATR multiplied by the user's risk factor.
[*] Take Profit (TP): Three dashed teal lines representing Take Profit 1, 2, and 3. These are calculated using specific Risk-to-Reward multiples of the stop-loss distance.
[/list]

[b]• Risk and Reward Zones[/b]
Semi-transparent colored fills visually separate the trade zones. A red fill highlights the risk zone between the entry and the stop loss, while a teal fill highlights the reward zone extending from the entry to the final take-profit level.

[b]• Advanced Dashboard[/b]
A multi-row informational table appears in the selected corner of the chart. This dashboard provides a real-time status check of the prevailing trend bias, the number of bars since the last signal, exact entry/SL/TP price levels, current ATR, and visual progress bars for volatility and signal cooldown periods.

[b]● 📖 How to Use[/b]
[image]https://www.tradingview.com/x/OKr2QDYx/[/image]
Traders can utilize this script as a complete top-down methodology for analyzing market structure. First, observe the dashboard to confirm that the current market environment aligns with your desired filters (e.g., ensuring the higher timeframe trend is supportive and volume thresholds are met). 

When a valid "LS" label appears on the chart, immediately note the projected Entry, Stop Loss, and Take Profit lines. The dashed blue line serves as your reference for a potential entry point. You can calculate your position sizing based on the fixed distance between this blue Entry line and the solid red Stop Loss line. 

The three Take Profit levels allow for a tiered approach to trade management, enabling partial profit-taking as the price advances in your favor. Advanced users can configure the custom string inputs to send highly detailed webhook payloads directly to execution platforms, passing the exact dynamically calculated price levels directly to their broker.

[b]● ⚙️ Inputs and Settings[/b]

The script is highly customizable through categorized input groups, allowing adaptation to any asset class or timeframe.

[b]• SMC Settings[/b]
[list]
[*] Sweep Lookback: Defines the number of historical bars used to calculate the structural high and low points.
[/list]

[b]• Smart Filters[/b]
[list]
[*] Trend Filter: Enables an SMA condition to dictate the allowed signal direction.
[*] Volatility Filter: Requires the ATR to be a minimum percentage of the asset's price before a signal can fire.
[*] Volume Filter: Demands that the current bar's volume exceeds a defined multiple of the volume moving average.
[*] HTF Timeframe: Selects the specific higher timeframe used for long-term trend alignment.
[*] Signal Cooldown: Prevents consecutive signals within a specified number of bars to reduce chart noise during extended consolidations.
[/list]

[b]• Trade Tools[/b]
[list]
[*] SL ATR Mult: Determines the distance of the Stop Loss based on the current ATR, adjusting risk based on market volatility.
[*] TP1 / TP2 / TP3 RR: Sets the specific Risk-to-Reward multiples for the three profit targets.
[/list]

[b]• Alerts[/b]
[list]
[*] Action Strings: Customizable fields to inject specific commands into the JSON alert payloads for entries, exits, and partial take-profits.
[/list]

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

From a market microstructure perspective, liquidity sweeps represent a temporary imbalance in supply and demand. In auction market theory, price frequently probes beyond established boundaries to test for the presence of resting orders. When price penetrates a historical extreme but fails to sustain value there—evidenced by the immediate reversal and closing within the prior range—it indicates an absorption of liquidity by counter-trend market participants. This exhaustion of directional momentum is a well-documented phenomenon in order flow analysis.

To normalize these price extensions, the indicator applies the Average True Range (ATR). Developed by J. Welles Wilder, the ATR provides a robust statistical measure of absolute price volatility, capturing gaps and limit moves that standard standard-deviation metrics might underrepresent. By tying the Stop Loss logic directly to the ATR, the indicator adapts to heteroskedasticity, which is the changing variance of asset returns over time. This ensures that risk parameters dynamically widen during highly volatile periods to prevent premature stop-outs, and contract during quiet phases to optimize capital efficiency. 

Furthermore, the reliance on moving averages for trend and volume filtration applies fundamental time-series smoothing. This inherently mitigates the noise of high-frequency price fluctuations, ensuring that the localized microstructure event (the sweep) is aligned with the macro directional drift of the broader dataset.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Liquidity Entry Signals [MarkitTick]", overlay=true, max_labels_count=500, max_lines_count=500)
// ── INPUTS ────────────────────────────────────────────────
string GRP_LIQ = "⚙️ SMC"
string GRP_FLT = "🎯 Smart Filters"
string GRP_TRD = "📐 Trade Tools"
string GRP_WH  = "🔔 Alerts"
string _mt741a = "📊 Dashboard"
string GRP_COL = "🌈 Colors"
i_showLiq = input.bool(true, "Liq Sweeps",     group=GRP_LIQ)
i_liqLen  = input.int(10,    "Sweep Lookback", minval=3, maxval=50, group=GRP_LIQ)
i_useTrendFilter = input.bool(false, "Trend Filter (EMA Bias)", group=GRP_FLT)
i_trendLen       = input.int(50, "Trend EMA Len", minval=5, group=GRP_FLT)
i_useVolFilter   = input.bool(false, "Volatility Filter (ATR)", group=GRP_FLT)
i_volAtrLen      = input.int(14, "Vol ATR Len", minval=1, group=GRP_FLT)
i_volMinPct      = input.float(0.0, "Vol Min % of Price", minval=0.0, step=0.05, group=GRP_FLT)
i_useVolumeFilter = input.bool(false, "Volume Filter", group=GRP_FLT)
i_volumeMALen     = input.int(20, "Volume MA Len", minval=1, group=GRP_FLT)
i_volumeMinMult   = input.float(1.0, "Volume Min x MA", minval=0.1, step=0.1, group=GRP_FLT)
i_useCooldown    = input.bool(true, "Signal Cooldown", group=GRP_FLT)
i_cooldownBars   = input.int(5, "Min Bars Between Signals", minval=1, group=GRP_FLT)
i_useHtfFilter   = input.bool(false, "HTF Trend Alignment", group=GRP_FLT)
i_htfTimeframe   = input.timeframe("240", "HTF Timeframe", group=GRP_FLT)
i_htfEmaLen      = input.int(50, "HTF EMA Len", minval=5, group=GRP_FLT)
i_atrLen  = input.int(14,   "ATR Len",  minval=1, group=GRP_TRD)
i_slMult  = input.float(0.50, "SL ATR Mult", minval=0.1, step=0.1, group=GRP_TRD)
i_tp1RR   = input.float(1.0, "TP1 RR", minval=0.1, step=0.1, group=GRP_TRD)
i_tp2RR   = input.float(2.0, "TP2 RR", minval=0.1, step=0.1, group=GRP_TRD)
i_tp3RR   = input.float(3.0, "TP3 RR", minval=0.1, step=0.1, group=GRP_TRD)
i_actionLong       = input.string("long",        "↑ Long Action",        group=GRP_WH)
i_actionShort      = input.string("short",       "↓ Short Action",       group=GRP_WH)
i_actionCloseLong  = input.string("closelong",   "✕ Close Long Action",  group=GRP_WH)
i_actionCloseShort = input.string("closeshort",  "✕ Close Short Action", group=GRP_WH)
i_actionTP1        = input.string("tp1hit",      "◆ TP1 Hit Action",     group=GRP_WH)
i_actionTP2        = input.string("tp2hit",      "✦ TP2 Hit Action",     group=GRP_WH)
i_actionTP3        = input.string("tp3hit",      "◆ TP3 Hit Action",     group=GRP_WH)
i_dashPos     = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=_mt741a)
i_cLiqB   = input.color(color.rgb(0, 200, 100), "Liq Sweep Bull", group=GRP_COL)
i_cLiqS   = input.color(color.rgb(220, 50, 80), "Liq Sweep Bear", group=GRP_COL)
i_cSL     = input.color(#ef5350, "SL Color", group=GRP_COL)
i_cEntry  = input.color(#2196f3, "Entry Color", group=GRP_COL)
i_cTP1    = input.color(color.new(#26a69a, 40), "TP1 Color", group=GRP_COL)
i_cTP2    = input.color(color.new(#26a69a, 20), "TP2 Color", group=GRP_COL)
i_cTP3    = input.color(color.new(#26a69a, 0),  "TP3 Color", group=GRP_COL)
i_cRisk   = input.color(color.new(#ef5350, 80), "Risk Zone Fill", group=GRP_COL)
i_cReward = input.color(color.new(#26a69a, 85), "Reward Zone Fill", group=GRP_COL)
i_cDashBg     = input.color(color.new(#0a0f1a, 10), "Dash BG", group=GRP_COL)
i_cDashHead   = input.color(color.new(#14b5cb, 20), "Dash Header BG", group=GRP_COL)
i_cDashLabel  = input.color(color.new(#ffffff, 30), "Dash Label Text", group=GRP_COL)
i_cDashValue  = input.color(color.new(#ffffff, 0),  "Dash Value Text", group=GRP_COL)
// ── CORE LOGIC ───────────────────────────────────────────
float _recentHigh = ta.highest(high[1], i_liqLen)
float _recentLow  = ta.lowest(low[1],   i_liqLen)
bool  _bslSweep   = high > _recentHigh and close < _recentHigh and close < open
bool  _mt741b   = low  < _recentLow  and close > _recentLow  and close > open

float _trendEma   = ta.sma(close, i_trendLen)
bool  _trendUp    = close[1] > _trendEma[1]
bool  _trendDn    = close[1] < _trendEma[1]
bool  _trendOkShort = not i_useTrendFilter or _trendDn
bool  _trendOkLong  = not i_useTrendFilter or _trendUp

float _htfClose   = request.security(syminfo.tickerid, i_htfTimeframe, close[1], lookahead=barmerge.lookahead_on)
float _htfEma     = request.security(syminfo.tickerid, i_htfTimeframe, ta.sma(close, i_htfEmaLen)[1], lookahead=barmerge.lookahead_on)
bool  _htfTrendUp = _htfClose > _htfEma
bool  _htfTrendDn = _htfClose < _htfEma
bool  _htfOkShort = not i_useHtfFilter or _htfTrendDn
bool  _htfOkLong  = not i_useHtfFilter or _htfTrendUp

float _volAtr     = ta.atr(i_volAtrLen)
bool  _volOk      = not i_useVolFilter or (_volAtr / close * 100 >= i_volMinPct)

float _volumeMA   = ta.sma(volume, i_volumeMALen)
bool  _volumeOk   = not i_useVolumeFilter or (volume >= _volumeMA * i_volumeMinMult)

var int _lastSignalBar = na
bool  _cooldownOk = not i_useCooldown or na(_lastSignalBar) or (bar_index - _lastSignalBar >= i_cooldownBars)

float _atr = ta.atr(i_atrLen)
// ── VISUALS ───────────────────────────────────────────
var line   slLine = na
var line   entryLine = na
var line   tp1Line = na
var line   tp2Line = na
var line   tp3Line = na
var label  slLbl = na
var label  entryLbl = na
var label  tp1Lbl = na
var label  tp2Lbl = na
var label  tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na
var label  lsLbl = na
var float  _lastEntry = na
var float  _lastSL = na
var float  _lastTP1 = na
var float  _lastTP2 = na
var float  _lastTP3 = na
var bool   _lastWasLong = bool(na)

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
    label.delete(lsLbl)

bool _newShort = i_showLiq and _bslSweep and _trendOkShort and _htfOkShort and _volOk and _volumeOk and _cooldownOk and barstate.isconfirmed
bool _newLong  = i_showLiq and _mt741b and _trendOkLong  and _htfOkLong  and _volOk and _volumeOk and _cooldownOk and barstate.isconfirmed
if _newShort
    _lastSignalBar := bar_index
    f_deleteLevels()
    lsLbl := label.new(bar_index, high, "LS", style=label.style_label_down, color=i_cLiqS, textcolor=color.white, size=size.small)
    float entryPrice = close
    float slPrice  = high + _atr * i_slMult
    float riskDist = slPrice - entryPrice
    float tp1Price = entryPrice - riskDist * i_tp1RR
    float tp2Price = entryPrice - riskDist * i_tp2RR
    float tp3Price = entryPrice - riskDist * i_tp3RR
    slLine    := line.new(bar_index, slPrice,    bar_index, slPrice,    color=i_cSL,    style=line.style_solid,  width=2)
    entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=i_cEntry, style=line.style_dashed, width=1)
    tp1Line   := line.new(bar_index, tp1Price,   bar_index, tp1Price,   color=i_cTP1,   style=line.style_dashed, width=1)
    tp2Line   := line.new(bar_index, tp2Price,   bar_index, tp2Price,   color=i_cTP2,   style=line.style_dashed, width=1)
    tp3Line   := line.new(bar_index, tp3Price,   bar_index, tp3Price,   color=i_cTP3,   style=line.style_dashed, width=1)
    slLbl     := label.new(bar_index, slPrice,    "✕ SL "    + str.tostring(slPrice,    format.mintick), style=label.style_label_left, color=i_cSL,    textcolor=color.white, size=size.small)
    entryLbl  := label.new(bar_index, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=i_cEntry, textcolor=color.white, size=size.small)
    tp1Lbl    := label.new(bar_index, tp1Price,   "◆ TP1 "   + str.tostring(tp1Price,   format.mintick), style=label.style_label_left, color=i_cTP1,   textcolor=color.white, size=size.small)
    tp2Lbl    := label.new(bar_index, tp2Price,   "✦ TP2 "   + str.tostring(tp2Price,   format.mintick), style=label.style_label_left, color=i_cTP2,   textcolor=color.white, size=size.small)
    tp3Lbl    := label.new(bar_index, tp3Price,   "◆ TP3 "   + str.tostring(tp3Price,   format.mintick), style=label.style_label_left, color=i_cTP3,   textcolor=color.white, size=size.small)
    riskFill   := linefill.new(slLine, entryLine, i_cRisk)
    rewardFill := linefill.new(entryLine, tp3Line, i_cReward)
    _lastEntry := entryPrice
    _lastSL    := slPrice
    _lastTP1   := tp1Price
    _lastTP2   := tp2Price
    _lastTP3   := tp3Price
    _lastWasLong := false

if _newLong
    _lastSignalBar := bar_index
    f_deleteLevels()
    lsLbl := label.new(bar_index, low, "LS", style=label.style_label_up, color=i_cLiqB, textcolor=color.white, size=size.small)
    float entryPrice = close
    float slPrice  = low - _atr * i_slMult
    float riskDist = entryPrice - slPrice
    float tp1Price = entryPrice + riskDist * i_tp1RR
    float tp2Price = entryPrice + riskDist * i_tp2RR
    float tp3Price = entryPrice + riskDist * i_tp3RR
    slLine    := line.new(bar_index, slPrice,    bar_index, slPrice,    color=i_cSL,    style=line.style_solid,  width=2)
    entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=i_cEntry, style=line.style_dashed, width=1)
    tp1Line   := line.new(bar_index, tp1Price,   bar_index, tp1Price,   color=i_cTP1,   style=line.style_dashed, width=1)
    tp2Line   := line.new(bar_index, tp2Price,   bar_index, tp2Price,   color=i_cTP2,   style=line.style_dashed, width=1)
    tp3Line   := line.new(bar_index, tp3Price,   bar_index, tp3Price,   color=i_cTP3,   style=line.style_dashed, width=1)
    slLbl     := label.new(bar_index, slPrice,    "✕ SL "    + str.tostring(slPrice,    format.mintick), style=label.style_label_left, color=i_cSL,    textcolor=color.white, size=size.small)
    entryLbl  := label.new(bar_index, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=i_cEntry, textcolor=color.white, size=size.small)
    tp1Lbl    := label.new(bar_index, tp1Price,   "◆ TP1 "   + str.tostring(tp1Price,   format.mintick), style=label.style_label_left, color=i_cTP1,   textcolor=color.white, size=size.small)
    tp2Lbl    := label.new(bar_index, tp2Price,   "✦ TP2 "   + str.tostring(tp2Price,   format.mintick), style=label.style_label_left, color=i_cTP2,   textcolor=color.white, size=size.small)
    tp3Lbl    := label.new(bar_index, tp3Price,   "◆ TP3 "   + str.tostring(tp3Price,   format.mintick), style=label.style_label_left, color=i_cTP3,   textcolor=color.white, size=size.small)
    riskFill   := linefill.new(entryLine, slLine, i_cRisk)
    rewardFill := linefill.new(tp3Line, entryLine, i_cReward)
    _lastEntry := entryPrice
    _lastSL    := slPrice
    _lastTP1   := tp1Price
    _lastTP2   := tp2Price
    _lastTP3   := tp3Price
    _lastWasLong := true

if not na(slLine) and not na(_lastSignalBar) and bar_index <= _lastSignalBar + 50
    int _extX = _lastSignalBar + 50
    line.set_x2(slLine,    _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line,   _extX)
    line.set_x2(tp2Line,   _extX)
    line.set_x2(tp3Line,   _extX)
    label.set_x(slLbl,     _extX)
    label.set_x(entryLbl,  _extX)
    label.set_x(tp1Lbl,    _extX)
    label.set_x(tp2Lbl,    _extX)
    label.set_x(tp3Lbl,    _extX)

// ── DASHBOARD ───────────────────────────────────────────────────
f_dashPos(string p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right

f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

f_onOff(bool used, bool ok) =>
    used ? (ok ? "✔ Pass" : "✘ Block") : "– Off"

f_onOffColor(bool used, bool ok) =>
    used ? (ok ? color.new(#26a69a, 0) : color.new(#ef5350, 0)) : i_cDashLabel

var table dash = table.new(f_dashPos(i_dashPos), 2, 16, bgcolor=i_cDashBg, border_width=1)
float _mt741c     = math.min((bar_index - nz(_lastSignalBar, bar_index)) / (i_cooldownBars * 2.0), 1.0)
float _rr1       = i_tp1RR / i_slMult
float _rr2       = i_tp2RR / i_slMult
float _rr3       = i_tp3RR / i_slMult
float _riskPct   = na(_lastEntry) or na(_lastSL) ? na : math.abs(_lastEntry - _lastSL) / _lastEntry * 100
float _rewardPct = na(_lastEntry) or na(_lastTP3) ? na : math.abs(_lastTP3 - _lastEntry) / _lastEntry * 100
float _volRatio  = _volAtr / close * 100
string _dirTxt   = na(_lastSignalBar) ? "—" : (_lastEntry > nz(_lastSL, _lastEntry) ? "▲ LONG" : "▼ SHORT")
color  _dirClr   = na(_lastSignalBar) ? i_cDashValue : (_lastEntry > nz(_lastSL, _lastEntry) ? color.new(#26a69a, 0) : color.new(#ef5350, 0))
color  _cellBg   = color.new(#0d1117, 0)

table.cell(dash, 0, 0,  "MarkitTick SMC", text_color=color.white, bgcolor=i_cDashHead, text_size=size.small)
table.cell(dash, 1, 0,  "", text_color=color.white, bgcolor=i_cDashHead, text_size=size.small)

table.cell(dash, 0, 1,  "Bias",         text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 1,  _htfTrendUp ? "Bull" : _htfTrendDn ? "Bear" : "Neutral", text_color=_htfTrendUp ? color.new(#26a69a,0) : _htfTrendDn ? color.new(#ef5350,0) : i_cDashValue, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 2,  "Direction",    text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 2,  _dirTxt, text_color=_dirClr, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 3,  "Last Signal",  text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 3,  na(_lastSignalBar) ? "—" : str.tostring(bar_index - _lastSignalBar) + " bars ago", text_color=i_cDashValue, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 4,  "Cooldown",     text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 4,  f_bar(bar_index - nz(_lastSignalBar, bar_index), i_cooldownBars * 2.0), text_color=f_barColor(_mt741c), bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 5,  "Entry",        text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 5,  na(_lastEntry) ? "—" : str.tostring(_lastEntry, format.mintick), text_color=i_cDashValue, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 6,  "Stop Loss",    text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 6,  na(_lastSL) ? "—" : str.tostring(_lastSL, format.mintick), text_color=i_cSL, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 7,  "TP1 / TP2 / TP3", text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 7,  na(_lastTP1) ? "—" : str.tostring(_lastTP1, format.mintick) + " / " + str.tostring(_lastTP2, format.mintick) + " / " + str.tostring(_lastTP3, format.mintick), text_color=i_cTP3, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 8,  "Risk %",       text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 8,  na(_riskPct) ? "—" : str.tostring(_riskPct, "#.##") + "%", text_color=i_cSL, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 9,  "Reward %",     text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 9,  na(_rewardPct) ? "—" : str.tostring(_rewardPct, "#.##") + "%", text_color=i_cTP3, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 10, "R:R (1/2/3)",  text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 10, str.tostring(_rr1, "#.##") + " / " + str.tostring(_rr2, "#.##") + " / " + str.tostring(_rr3, "#.##"), text_color=i_cDashValue, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 11, "ATR",          text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 11, str.tostring(_atr, format.mintick), text_color=i_cDashValue, bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 12, "Volatility",   text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 12, f_bar(math.min(_volRatio, 5.0), 5.0), text_color=f_barColor(math.min(_volRatio, 5.0) / 5.0), bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 13, "Trend / HTF",  text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 13, f_onOff(i_useTrendFilter, _trendOkLong or _trendOkShort) + "  /  " + f_onOff(i_useHtfFilter, _htfOkLong or _htfOkShort), text_color=f_onOffColor(i_useTrendFilter, _trendOkLong or _trendOkShort), bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 14, "Vol / Volume", text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 14, f_onOff(i_useVolFilter, _volOk) + "  /  " + f_onOff(i_useVolumeFilter, _volumeOk), text_color=f_onOffColor(i_useVolFilter, _volOk), bgcolor=_cellBg, text_size=size.small)

table.cell(dash, 0, 15, "Volume x MA",  text_color=i_cDashLabel, bgcolor=i_cDashBg, text_size=size.small)
table.cell(dash, 1, 15, str.tostring(volume / _volumeMA, "#.##") + "x", text_color=i_cDashValue, bgcolor=_cellBg, text_size=size.small)

// ── ALERTS ───────────────────────────────────────────────────
string _longInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"',
     i_actionLong, syminfo.tickerid, timeframe.period,
     str.tostring(_lastEntry, format.mintick),
     str.tostring(_lastSL,    format.mintick),
     str.tostring(_lastTP1,   format.mintick),
     str.tostring(_lastTP2,   format.mintick),
     str.tostring(_lastTP3,   format.mintick))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}"',
     i_actionShort, syminfo.tickerid, timeframe.period,
     str.tostring(_lastEntry, format.mintick),
     str.tostring(_lastSL,    format.mintick),
     str.tostring(_lastTP1,   format.mintick),
     str.tostring(_lastTP2,   format.mintick),
     str.tostring(_lastTP3,   format.mintick))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long"',
     i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short"',
     i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

if _newLong and barstate.isconfirmed
    alert(longPayload, alert.freq_once_per_bar_close)
if _newShort and barstate.isconfirmed
    alert(shortPayload, alert.freq_once_per_bar_close)
if _newShort and barstate.isconfirmed
    alert(closeLongPayload, alert.freq_once_per_bar_close)
if _newLong and barstate.isconfirmed
    alert(closeShortPayload, alert.freq_once_per_bar_close)

alertcondition(_newLong  and barstate.isconfirmed, "BUY Signal",         "MarkitTick — BUY Signal Fired")
alertcondition(_newShort and barstate.isconfirmed, "SELL Signal",        "MarkitTick — SELL Signal Fired")
alertcondition(_newShort and barstate.isconfirmed, "Close Long Signal",  "MarkitTick — Close Long")
alertcondition(_newLong  and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")

bool _tp1Hit = not na(_lastSignalBar) and (_lastWasLong ? high >= _lastTP1 : low <= _lastTP1)
bool _tp2Hit = not na(_lastSignalBar) and (_lastWasLong ? high >= _lastTP2 : low <= _lastTP2)
bool _tp3Hit = not na(_lastSignalBar) and (_lastWasLong ? high >= _lastTP3 : low <= _lastTP3)

string _tp1Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","tp":"{4}"',
     i_actionTP1, syminfo.tickerid, timeframe.period,
     _lastWasLong ? "long" : "short",
     str.tostring(_lastTP1, format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"

string _tp2Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","tp":"{4}"',
     i_actionTP2, syminfo.tickerid, timeframe.period,
     _lastWasLong ? "long" : "short",
     str.tostring(_lastTP2, format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"

string _tp3Inner = str.format(
     '"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","tp":"{4}"',
     i_actionTP3, syminfo.tickerid, timeframe.period,
     _lastWasLong ? "long" : "short",
     str.tostring(_lastTP3, format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"

if _tp1Hit
    alert(tp1Payload, alert.freq_once_per_bar)
if _tp2Hit
    alert(tp2Payload, alert.freq_once_per_bar)
if _tp3Hit
    alert(tp3Payload, alert.freq_once_per_bar)

alertcondition(_tp1Hit, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(_tp2Hit, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(_tp3Hit, "TP3 Hit", "MarkitTick — TP3 Hit")
````
