# Turtle Soup Failed Breakout [MarkitTick]

- url: https://www.tradingview.com/script/LME1uK6a-Turtle-Soup-Failed-Breakout-MarkitTick/
- type: indicator
- pine_id: PUB;5b207e3c9a7b487fa3de64bca406194a
- version: 1.0

## Description

💡 Most breakout traders act on the moment price moves past a well-known high or low. This indicator looks for the opposite: a push beyond a 20-bar extreme that fails to hold and closes back inside the range. That is the Turtle Soup pattern, and its +1 variant, which waits one extra bar for confirmation. The script finds both setups, filters them if you choose, and draws a full trade plan on the chart for every confirmed signal: entry, a volatility-based stop, three targets measured in multiples of risk, live tracking of each level, a dashboard and webhook-ready alerts. It is meant for traders who want failed breakouts spotted by clear rules, not by eye.

[b]✨ Originality and Utility[/b]
A standard price channel (the highest high and lowest low of recent bars) only shows where the range is. What price does at those edges is left to the trader. This script turns the edge into a test: it records when price breaks the edge, checks whether the break was rejected, and makes sure the extreme being broken is not too recent. Only then does it produce a signal.

What it adds over a plain channel or a basic breakout script:
[list]
[*]Two pattern variants in one tool. Turtle Soup (pierce and reclaim on the same bar) and Turtle Soup +1 (close beyond the level, then reclaim on the next bar) can run alone or together.
[*]An age requirement on the extreme. The prior high or low must be at least a set number of bars old. A break of an extreme made two bars ago is ordinary noise, while a break of an older extreme is a real test of a level other traders are watching.
[*]A complete trade plan for every signal: entry at the confirmed close, a stop placed beyond the failed extreme with an ATR buffer, and three targets in multiples of that risk.
[*]Level tracking after entry: each target and the stop are checked bar by bar, their labels update when reached, and the dashboard shows the trade status.
[*]Two optional filters, a higher-timeframe trend filter and an ADX strength filter. Both read only completed data.
[*]Structured JSON webhook messages for entries, closes of the opposite side, and each target.
[/list]

[b]● Why these components belong together[/b]
Each part answers one question the pattern raises. The channel defines the level being tested. The age rule decides whether that level matters. The same-bar or next-bar reclaim decides whether the breakout actually failed. The ATR buffer sizes the stop to current volatility, so the invalidation point is not a fixed price distance. The R-multiple targets express reward in units of that same risk, which keeps trades comparable across symbols and timeframes. The higher-timeframe and ADX filters are optional context: one asks whether the reversal agrees with the bigger trend, the other whether the market has enough directional energy. None of these parts is decoration, and each changes which signals appear or how they are managed.

[b]🔬 Methodology and Concepts[/b]

[b]• The reference channel[/b]
On every bar the script takes the highest high and the lowest low of the previous Channel Len bars (20 by default). The current bar is not included, so it is always compared with a range that was already complete before it opened. The script also measures how many bars ago each extreme was set, counted back from the current bar. If Smoothing is enabled, the channel is passed through the chosen moving average (SMA, EMA, RMA, WMA or HMA) before any signal is evaluated. The age of the extreme is still measured from the raw, unsmoothed high or low.

[b]• Turtle Soup (same-bar failure)[/b]
A long setup forms when the bar's low trades below the channel low but the bar closes back above it, and the prior low is at least Min Extreme Age bars old (4 by default). A short setup is the mirror image: the high trades above the channel high, the close finishes back below it, and the prior high meets the same age rule.

[b]• Turtle Soup +1 (next-bar failure)[/b]
A long setup forms when the previous bar traded below its channel low and closed below it, a real close outside the range, and the current bar then closes back above that same level. The age rule is applied to the previous bar's extreme. A short setup mirrors this at the channel high. The variant catches breakouts that looked accepted for one bar before being rejected.

[b]• Signal confirmation[/b]
A signal becomes final only when its bar closes. If the long and short conditions ever qualify on the same bar, neither signal fires. The Setup input picks Turtle Soup, Turtle Soup +1, or Both. When both variants qualify on the same bar in Both mode, the signal is labelled Turtle Soup and the stop uses the wider two-bar extreme.

[b]• Stop placement[/b]
For a long, the stop sits below the signal bar's low (or the lower of the two bars for the +1 variant) by SL Buffer ATR multiplied by the Average True Range (0.25 ATR over 14 bars by default). For a short, the stop sits above the matching high by the same buffer. The stop therefore sits just beyond the price that invalidates the failed-breakout idea.

[b]• Targets[/b]
Entry is the close of the signal bar. Risk is the distance from entry to stop. TP1, TP2 and TP3 are placed at 1, 2 and 3 times that risk in the trade's direction by default. If two targets are set to the same multiple, they are merged into one level and its label names both.

[b]• Trade tracking[/b]
Tracking starts on the bar after the signal. Each bar, the script checks whether price reached the stop or any target. The stop is checked first, so if one bar touches both the stop and a target, the stop is counted. This is the conservative reading of an ambiguous bar. The stop stays at its original price after TP1 or TP2 is reached. A trade is finished when the stop is hit or TP3 is reached. A new signal in either direction replaces the current plan, whether the previous trade was still open or not.

[b]• Optional filters[/b]
Higher-timeframe filter: longs need the last completed higher-timeframe close to be above its EMA (50 periods on the 240-minute timeframe by default), and shorts need it below. Only fully closed higher-timeframe values are used, so the filter does not change after the fact. If the selected timeframe is lower than the chart's, the filter is skipped and the dashboard says so. On non-standard chart types the filter reads the standard version of the symbol.
ADX filter: a signal needs the previous bar's ADX to be at or above ADX Min (20 by default, with a 14-bar DI and ADX length).

[b]🎨 Visual Guide[/b]

[b]• Channel lines[/b]
Two stepped lines mark the reference channel. The upper line (semi-transparent red by default) is the prior channel high, the level a bearish setup must fail at. The lower line (semi-transparent green by default) is the prior channel low, the level a bullish setup must fail at. They can be hidden with Channel Lines.

[b]• Signal markers[/b]
A green BULL label under the bar marks a confirmed long setup. A red BEAR label above the bar marks a confirmed short setup. Only confirmed signals are marked.

[b]• Trade levels[/b]
For the latest signal, five horizontal levels are drawn from the signal bar:
[list]
[*]Stop: a thick solid red line with a red label showing SL and its price.
[*]Entry: a dashed blue line with a blue label showing Entry and its price.
[*]TP1, TP2, TP3: dashed green lines that become more opaque from TP1 to TP3, each with a green label showing its price.
[/list]
While the trade is open, the levels extend ten bars past the newest bar. Once the trade closes, they stop ten bars after the closing bar, so a finished plan stays readable without stretching across the chart. Only the most recent plan is shown.

[b]• Hit labels[/b]
When price reaches a target or the stop, that level's label changes to show HIT together with the percentage move from entry to that level. A glance at the labels shows how far the trade got.

[b]• Dashboard[/b]
A two-column panel (top right by default) shows the symbol and timeframe in its header, then:
[list]
[*]Lock: whether Lock Signal is active.
[*]Mode and Setup: the selected mode and the variant behind the latest signal.
[*]Signal: BULL in green or BEAR in red for the latest trade.
[*]Status: Open, TP1 Hit, TP2 Hit, TP3 Hit, Stopped, or Stopped after a given target.
[*]Entry, Stop, TP1, TP2, TP3: the exact prices.
[*]Risk: the entry-to-stop distance in price and as a percentage of entry.
[*]Targets Hit: a ten-block progress bar showing how many of the three targets were reached.
[*]Channel High, Channel Low and Channel Len: the current range and its lookback.
[*]Channel Pos: a progress bar showing where the current close sits inside the channel, from 0% at the low to 100% at the high.
[*]ATR and Bars Since: current volatility and the number of bars since the latest signal.
[*]HTF Filter, ADX Filter and Smoothing rows appear only when those features are enabled.
[/list]
Progress bars are green at 66% and above, amber from 33% to 65%, and red below 33%.

[b]📖 How to Use[/b]
[list=1]
[*]Choose the setup. Turtle Soup reacts faster. Turtle Soup +1 waits for one extra bar of evidence that the breakout failed. Both shows everything.
[*]Read the context. A BULL marker at the channel low means price broke below an older low and could not stay there. A BEAR marker at the channel high means the same failure above an older high.
[*]Use the drawn plan as a reference. The stop shows where the failed-breakout idea is invalidated, and the targets show where the reward reaches one, two and three times the risk.
[*]Follow the levels. HIT labels and the Status row show whether the trade reached its targets or was stopped. After TP1 the stop does not move, so any trailing or breakeven management is your own decision.
[*]Add filters when the market needs them. The higher-timeframe filter keeps only reversals that agree with the bigger trend. The ADX filter removes signals in very quiet conditions. Compare results on your own symbol with and without each filter.
[*]Use Lock Signal when you want the current plan held. While it is on, a new signal on the most recent bar does not replace the drawn levels. Historical bars are not affected, and the chart recalculates on reload.
[/list]

[b]• Alerts[/b]
For webhook automation, create an alert with the "Any alert() function call" condition. On a confirmed long it sends a JSON message with the action, ticker, timeframe, direction, entry, stop, three targets, setup name and the channel level that failed, plus a separate close message for any short position. A confirmed short sends the mirror pair. Each target sends its own message when price reaches it. Target alerts fire when price touches the level during the bar, while entry alerts wait for the bar to close. There are also simple named alerts: BUY Signal, SELL Signal, Close Long Signal, Close Short Signal, TP1 Hit, TP2 Hit and TP3 Hit. The script has no stop-loss alert.

[b]• Repainting behaviour[/b]
Signals are final only at bar close, the channel is built from bars that are already complete, and the higher-timeframe filter reads only completed higher-timeframe values. A signal that has printed is not removed or moved later. The dashboard and the target tracking on the forming bar update live, as any real-time display does.

[b]⚙️ Inputs and Settings[/b]

[b]• Core[/b]
[list]
[*]Setup: Turtle Soup, Turtle Soup +1, or Both.
[*]Channel Len: number of prior bars used for the high and low channel. Longer values test more significant levels and give fewer signals.
[*]Min Extreme Age: how old the prior extreme must be. Higher values ignore breaks of very recent extremes.
[/list]

[b]• Filters[/b]
[list]
[*]HTF Filter, HTF TF, HTF EMA Len: turn the trend filter on, pick its timeframe (not lower than the chart's) and set its EMA length.
[*]ADX Filter, ADX Min, ADX Len: turn the strength filter on and set its threshold and length.
[*]Smoothing and Smooth Len: smooth the channel with a moving average before signals are checked. Smoothing makes the levels less jagged but also slower to follow new extremes.
[/list]

[b]• Trade Tools[/b]
[list]
[*]Lock Signal: holds the current plan on the latest bar.
[*]ATR Len and SL Buffer ATR: set the volatility measure and how far beyond the failed extreme the stop sits.
[*]TP1 R, TP2 R, TP3 R: the targets as multiples of risk.
[/list]

[b]• Visuals, Dashboard, Alerts and Colors[/b]
[list]
[*]Signal Markers and Channel Lines toggle the BULL and BEAR labels and the channel.
[*]Show Dashboard and Position control the panel.
[*]The action fields set the text sent as the action in each webhook message (defaults: long, short, closelong, closeshort, tp1, tp2, tp3), so the messages can match the receiving system.
[*]Every color on the chart and dashboard can be changed in the Colors group.
[/list]

[b]● Credits[/b]
The Turtle Soup pattern and its +1 variant were described by Laurence Connors and Linda Bradford Raschke in Street Smarts as a counter to the classic channel-breakout approach associated with the Turtle traders. This script is an original implementation of that published concept. Unlike the original rules, which enter with a stop order at the level during the bar, this version waits for a confirmed close before signalling.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]• Order statistics and range extremes[/b]
The channel high and low are the maximum and minimum of a fixed window of prices, which are order statistics of that sample. In a random-walk market, new extremes of a window appear regularly by chance alone. The Turtle Soup idea rests on the observation that some of these new extremes are not followed through. When price returns inside the window straight away, it suggests the extreme was produced by a short burst of orders rather than a lasting shift in value.

[b]• Stop clustering and liquidity[/b]
Traders often place stop orders just beyond visible highs and lows, and breakout traders place entry orders there. When price reaches these levels, the resting orders fill at once, which can stretch the move briefly. If no new participants arrive, the move fades once that liquidity is used up, and price returns into the range. The age rule targets levels that have been in place long enough for such orders to build up.

[b]• Mean reversion at the edges of a range[/b]
Range trading assumes price tends to return toward the middle of a balance area after testing its edges. The failed breakout is a sign that the balance area is still in place. Mean-reversion edges are usually strongest when there is no strong trend, which is why the optional higher-timeframe filter can be used to keep only reversals that agree with the bigger direction.

[b]• Volatility normalisation with ATR[/b]
Average True Range, introduced by J. Welles Wilder, measures typical bar size including gaps. Placing the stop a fraction of ATR beyond the failed extreme scales the buffer to current conditions: wider in volatile markets, tighter in calm ones. This lowers the chance that ordinary noise triggers the stop while keeping the invalidation point close to the structure.

[b]• Directional strength with ADX[/b]
The Average Directional Index, also developed by Wilder, measures how strongly price is trending regardless of direction. Using the previous bar's ADX as a minimum requirement keeps signals only when the market has enough directional movement for a reversal to travel. It is a measure of energy, not of direction.

[b]• Risk expressed as R-multiples[/b]
Measuring targets in multiples of the initial risk comes from position-sizing and expectancy frameworks, where each trade's outcome is expressed in units of what was risked. This makes results comparable across instruments with very different prices, and makes the ratio of reward to risk explicit for every signal.

[b]• Multi-timeframe confirmation[/b]
Checking a lower-timeframe signal against a higher-timeframe trend is a filtering idea: the higher timeframe changes more slowly and carries less noise, so it serves as a background condition. Reading only completed higher-timeframe values keeps that background fixed once seen, which matters for a fair review of past signals.

[b]● Limitations[/b]
Failed breakouts are one reading of price at a range edge, not a forecast. In strong trends, new extremes often keep extending, and counter-trend setups can produce a series of stops. The stop-first rule for ambiguous bars and the fixed stop after TP1 are deliberate simplifications. Results depend heavily on the symbol, the timeframe and the settings, and should be studied on your own data before any use.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Turtle Soup Failed Breakout [MarkitTick]", overlay = true, max_labels_count = 500, max_lines_count = 50)

// ── INPUTS ──────────────────────────────────────────────────
var string GRP_CORE  = "⚙️ Core"
var string GRP_FILT  = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS   = "🎨 Visuals"
var string GRP_DASH  = "📊 Dashboard"
var string GRP_WH    = "🔔 Alerts"
var string GRP_COL   = "🌈 Colors"
i_mode             = input.string("Both", "Setup", options = ["Turtle Soup", "Turtle Soup +1", "Both"], group = GRP_CORE, tooltip = "Turtle Soup: pierce and reclaim on one bar · +1: close beyond, reclaim next bar")
i_len              = input.int(20, "Channel Len", minval = 2, group = GRP_CORE, tooltip = "Bars in the prior high/low channel")
i_minAge           = input.int(4, "Min Extreme Age", minval = 1, group = GRP_CORE, tooltip = "Prior extreme must be at least this many bars old")
i_htfOn            = input.bool(false, "HTF Filter", group = GRP_FILT, tooltip = "Long needs HTF close above HTF EMA · short below")
i_htfTf            = input.timeframe("240", "HTF TF", group = GRP_FILT, tooltip = "Not lower than the chart timeframe")
i_htfLen           = input.int(50, "HTF EMA Len", minval = 1, group = GRP_FILT, tooltip = "EMA length on the HTF")
i_adxOn            = input.bool(false, "ADX Filter", group = GRP_FILT, tooltip = "Signal needs previous bar ADX at or above the minimum")
i_adxThr           = input.float(20.0, "ADX Min", minval = 0, step = 0.5, group = GRP_FILT, tooltip = "ADX threshold")
i_adxLen           = input.int(14, "ADX Len", minval = 1, group = GRP_FILT, tooltip = "DI and ADX smoothing length")
i_smooth           = input.string("None", "Smoothing", options = ["None", "SMA", "EMA", "RMA", "WMA", "HMA"], group = GRP_FILT, tooltip = "Smooths the channel before signals are derived")
i_smLen            = input.int(3, "Smooth Len", minval = 2, group = GRP_FILT, tooltip = "Smoothing length")
i_lockSignal       = input.bool(false, "🔒 Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_atrLen           = input.int(14, "ATR Len", minval = 1, group = GRP_TRADE, tooltip = "ATR length for the stop buffer")
i_slBuf            = input.float(0.25, "SL Buffer ATR", minval = 0, step = 0.05, group = GRP_TRADE, tooltip = "Stop sits this many ATR beyond the failed extreme")
i_r1               = input.float(1.0, "TP1 R", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "TP1 in multiples of risk")
i_r2               = input.float(2.0, "TP2 R", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "TP2 in multiples of risk")
i_r3               = input.float(3.0, "TP3 R", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "TP3 in multiples of risk")
i_showMk           = input.bool(true, "Signal Markers", group = GRP_VIS, tooltip = "BULL / BEAR labels on signal bars")
i_showCh           = input.bool(true, "Channel Lines", group = GRP_VIS, tooltip = "Prior high/low channel")
i_showDash         = input.bool(true, "Show Dashboard", group = GRP_DASH, tooltip = "Show the dashboard")
i_dashPos          = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH, tooltip = "Dashboard position")
i_actionLong       = input.string("long", "↑ Long Action", group = GRP_WH, tooltip = "Webhook action for a long entry")
i_actionShort      = input.string("short", "↓ Short Action", group = GRP_WH, tooltip = "Webhook action for a short entry")
i_actionCloseLong  = input.string("closelong", "✕ Close Long Action", group = GRP_WH, tooltip = "Webhook action to close a long")
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH, tooltip = "Webhook action to close a short")
i_actionTp1        = input.string("tp1", "◆ TP1 Action", group = GRP_WH, tooltip = "Webhook action when TP1 is hit")
i_actionTp2        = input.string("tp2", "✦ TP2 Action", group = GRP_WH, tooltip = "Webhook action when TP2 is hit")
i_actionTp3        = input.string("tp3", "◆ TP3 Action", group = GRP_WH, tooltip = "Webhook action when TP3 is hit")
C_SUP              = input.color(#26a69a, "Bull", group = GRP_COL, tooltip = "Bullish state and BULL marker")
C_RES              = input.color(#ef5350, "Bear", group = GRP_COL, tooltip = "Bearish state and BEAR marker")
C_CH_HI            = input.color(color.new(#ef5350, 40), "Channel High", group = GRP_COL, tooltip = "Channel high line")
C_CH_LO            = input.color(color.new(#26a69a, 40), "Channel Low", group = GRP_COL, tooltip = "Channel low line")
C_SL               = input.color(#ef5350, "SL", group = GRP_COL, tooltip = "Stop line and label")
C_ENTRY            = input.color(#2196f3, "Entry", group = GRP_COL, tooltip = "Entry line and label")
C_TP               = input.color(#26a69a, "TP", group = GRP_COL, tooltip = "Target lines and labels")
C_LBL_TXT          = input.color(#ffffff, "Label Text", group = GRP_COL, tooltip = "Text on markers and level labels")
C_DASH_HDR         = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL, tooltip = "Dashboard header fill")
C_DASH_BG          = input.color(color.new(#0a0f1a, 10), "Dash BG", group = GRP_COL, tooltip = "Dashboard background")
C_DASH_TXT         = input.color(#ffffff, "Dash Text", group = GRP_COL, tooltip = "Dashboard text")
C_BAR_HI           = input.color(#26a69a, "Bar High", group = GRP_COL, tooltip = "Progress bar at 66% and above")
C_BAR_MID          = input.color(#f9a825, "Bar Mid", group = GRP_COL, tooltip = "Progress bar from 33% to 65%")
C_BAR_LO           = input.color(#ef5350, "Bar Low", group = GRP_COL, tooltip = "Progress bar under 33%")

// ── CORE LOGIC ──────────────────────────────────────────────
f_smooth(float src, simple int len, string m) =>
    float _sma = ta.sma(src, len)
    float _ema = ta.ema(src, len)
    float _rma = ta.rma(src, len)
    float _wma = ta.wma(src, len)
    float _hma = ta.hma(src, len)
    switch m
        "SMA" => _sma
        "EMA" => _ema
        "RMA" => _rma
        "WMA" => _wma
        "HMA" => _hma
        => src
f_tfFmt(string tf) =>
    switch
        str.endswith(tf, "T") => tf
        str.endswith(tf, "S") => str.tostring(timeframe.in_seconds(tf)) + "s"
        str.endswith(tf, "M") => str.tostring(math.round(timeframe.in_seconds(tf) / 2628003)) + "M"
        str.endswith(tf, "W") => str.tostring(math.round(timeframe.in_seconds(tf) / 604800)) + "W"
        str.endswith(tf, "D") => str.tostring(math.round(timeframe.in_seconds(tf) / 86400)) + "D"
        timeframe.in_seconds(tf) % 3600 == 0 => str.tostring(math.round(timeframe.in_seconds(tf) / 3600)) + "H"
        => str.tostring(math.round(timeframe.in_seconds(tf) / 60)) + "m"
f_num(float v) =>
    string _o = "—"
    if not na(v)
        float _a = math.abs(v)
        string _sg = v < 0 ? "-" : ""
        float _k = math.round(_a / 1000, 1)
        float _m = math.round(_a / 1000000, 1)
        _o := math.round(_a, 2) < 1000 ? str.tostring(math.round(v, 2)) : _k < 1000 ? _sg + str.tostring(_k, "#.#") + "K" : _m < 1000 ? _sg + str.tostring(_m, "#.#") + "M" : _sg + str.tostring(math.round(_a / 1000000000, 1), "#.#") + "B"
    _o
f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)
f_pctTxt(float lvl, float entry, bool isLong) =>
    float _p = (isLong ? lvl - entry : entry - lvl) / entry * 100
    (_p >= 0 ? "+" : "") + str.tostring(_p, "#.00") + "%"
f_bar(float val, float maxVal) =>
    float _v = math.max(val, 0)
    int filled = math.round(math.min(_v / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(_v / maxVal * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? C_BAR_HI : pct >= 0.33 ? C_BAR_MID : C_BAR_LO
f_n1(bool m12, bool m23) =>
    "TP1" + (m12 ? " · TP2" + (m23 ? " · TP3" : "") : "")
f_n2(bool m23) =>
    "TP2" + (m23 ? " · TP3" : "")
float _rawLo = ta.lowest(low, i_len)[1]
float _rawHi = ta.highest(high, i_len)[1]
int   _loAge = 1 - ta.lowestbars(low, i_len)[1]
int   _hiAge = 1 - ta.highestbars(high, i_len)[1]
float chLo   = f_smooth(_rawLo, i_smLen, i_smooth)
float chHi   = f_smooth(_rawHi, i_smLen, i_smooth)
float _atrV  = ta.atr(i_atrLen)
float _low2  = math.min(low, low[1])
float _high2 = math.max(high, high[1])
bool   _htfValid = timeframe.in_seconds(i_htfTf) >= timeframe.in_seconds(timeframe.period)
string _htfReq   = _htfValid ? i_htfTf : timeframe.period
string _htfSym   = chart.is_standard ? syminfo.tickerid : ticker.standard(syminfo.tickerid)
[_htfC, _htfE]   = request.security(_htfSym, _htfReq, [close[1], ta.ema(close, i_htfLen)[1]], lookahead = barmerge.lookahead_on)
bool _htfAct     = i_htfOn and _htfValid
bool _htfBull    = not na(_htfC) and not na(_htfE) and _htfC > _htfE
bool _htfBear    = not na(_htfC) and not na(_htfE) and _htfC < _htfE
bool _htfLongOk  = not _htfAct or _htfBull
bool _htfShortOk = not _htfAct or _htfBear
[_diP, _diM, _adx] = ta.dmi(i_adxLen, i_adxLen)
float _adxPrev   = _adx[1]
bool  _adxOk     = not i_adxOn or (not na(_adxPrev) and _adxPrev >= i_adxThr)
bool _useTs   = i_mode != "Turtle Soup +1"
bool _usePo   = i_mode != "Turtle Soup"
bool _chOk    = not na(chLo) and not na(chHi)
bool _tsLong  = _useTs and _chOk and not na(_loAge) and _loAge >= i_minAge and low < chLo and close > chLo
bool _tsShort = _useTs and _chOk and not na(_hiAge) and _hiAge >= i_minAge and high > chHi and close < chHi
bool _poLong  = _usePo and not na(chLo[1]) and not na(_loAge[1]) and _loAge[1] >= i_minAge and low[1] < chLo[1] and close[1] < chLo[1] and close > chLo[1]
bool _poShort = _usePo and not na(chHi[1]) and not na(_hiAge[1]) and _hiAge[1] >= i_minAge and high[1] > chHi[1] and close[1] > chHi[1] and close < chHi[1]
bool _longRaw  = (_tsLong or _poLong) and _htfLongOk and _adxOk and not na(_atrV)
bool _shortRaw = (_tsShort or _poShort) and _htfShortOk and _adxOk and not na(_atrV)
bool longSignal  = _longRaw and not _shortRaw and barstate.isconfirmed
bool shortSignal = _shortRaw and not _longRaw and barstate.isconfirmed
float _lStop = (_poLong ? _low2 : low) - _atrV * i_slBuf
float _sStop = (_poShort ? _high2 : high) + _atrV * i_slBuf
var bool   isLong     = false
var float  entryPrice = float(na)
var float  slPrice    = float(na)
var float  tp1Price   = float(na)
var float  tp2Price   = float(na)
var float  tp3Price   = float(na)
var string _setup     = "—"
var int    _sigBar    = int(na)
var int    _closeBar  = int(na)
var bool   _m12       = false
var bool   _m23       = false
var bool   tp1Hit     = false
var bool   tp2Hit     = false
var bool   tp3Hit     = false
var bool   slHit      = false
var line   slLine     = na
var line   entryLine  = na
var line   tp1Line    = na
var line   tp2Line    = na
var line   tp3Line    = na
var label  slLbl      = na
var label  entryLbl   = na
var label  tp1Lbl     = na
var label  tp2Lbl     = na
var label  tp3Lbl     = na
f_deleteLevels() =>
    line.delete(slLine), line.delete(entryLine)
    line.delete(tp1Line), line.delete(tp2Line), line.delete(tp3Line)
    label.delete(slLbl), label.delete(entryLbl)
    label.delete(tp1Lbl), label.delete(tp2Lbl), label.delete(tp3Lbl)
bool _locked   = i_lockSignal and barstate.islast
bool _newLong  = longSignal and not _locked
bool _newShort = shortSignal and not _locked
if _newLong or _newShort
    f_deleteLevels()
    tp1Hit     := false
    tp2Hit     := false
    tp3Hit     := false
    slHit      := false
    _closeBar  := na
    isLong     := _newLong
    entryPrice := close
    slPrice    := _newLong ? _lStop : _sStop
    float _r    = math.abs(entryPrice - slPrice)
    tp1Price   := _newLong ? entryPrice + _r * i_r1 : entryPrice - _r * i_r1
    tp2Price   := _newLong ? entryPrice + _r * i_r2 : entryPrice - _r * i_r2
    tp3Price   := _newLong ? entryPrice + _r * i_r3 : entryPrice - _r * i_r3
    _setup     := _newLong ? (_tsLong ? "Turtle Soup" : "Turtle Soup +1") : (_tsShort ? "Turtle Soup" : "Turtle Soup +1")
    _sigBar    := bar_index
    _m12       := tp2Price == tp1Price
    _m23       := tp3Price == tp2Price
    int _x2     = bar_index + 10
    slLine     := line.new(bar_index, slPrice, _x2, slPrice, color = C_SL, style = line.style_solid, width = 2)
    entryLine  := line.new(bar_index, entryPrice, _x2, entryPrice, color = C_ENTRY, style = line.style_dashed, width = 1)
    tp1Line    := line.new(bar_index, tp1Price, _x2, tp1Price, color = color.new(C_TP, 40), style = line.style_dashed, width = 1)
    tp2Line    := line.new(bar_index, tp2Price, _x2, tp2Price, color = color.new(C_TP, 20), style = line.style_dashed, width = 1)
    tp3Line    := line.new(bar_index, tp3Price, _x2, tp3Price, color = color.new(C_TP, 0), style = line.style_dashed, width = 1)
    slLbl      := label.new(_x2, slPrice, "✕ SL " + str.tostring(slPrice, format.mintick), style = label.style_label_left, color = C_SL, textcolor = C_LBL_TXT, size = size.small)
    entryLbl   := label.new(_x2, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = C_ENTRY, textcolor = C_LBL_TXT, size = size.small)
    tp1Lbl     := label.new(_x2, tp1Price, "◆ " + f_n1(_m12, _m23) + " " + str.tostring(tp1Price, format.mintick), style = label.style_label_left, color = C_TP, textcolor = C_LBL_TXT, size = size.small)
    tp2Lbl     := _m12 ? na : label.new(_x2, tp2Price, "✦ " + f_n2(_m23) + " " + str.tostring(tp2Price, format.mintick), style = label.style_label_left, color = C_TP, textcolor = C_LBL_TXT, size = size.small)
    tp3Lbl     := _m23 ? na : label.new(_x2, tp3Price, "◆ TP3 " + str.tostring(tp3Price, format.mintick), style = label.style_label_left, color = C_TP, textcolor = C_LBL_TXT, size = size.small)
bool _live       = not na(entryPrice) and bar_index > _sigBar
bool _tp1Cross   = isLong ? high >= tp1Price : low <= tp1Price
bool _tp2Cross   = isLong ? high >= tp2Price : low <= tp2Price
bool _tp3Cross   = isLong ? high >= tp3Price : low <= tp3Price
bool _slCross    = isLong ? low <= slPrice : high >= slPrice
bool _slEvt      = _live and not slHit and not tp3Hit and _slCross
if _slEvt
    slHit := true
    label.set_text(slLbl, "SL ✓ HIT " + f_pctTxt(slPrice, entryPrice, isLong))
bool _tp1Evt = _live and not slHit and not tp1Hit and _tp1Cross
if _tp1Evt
    tp1Hit := true
    label.set_text(tp1Lbl, f_n1(_m12, _m23) + " ✓ HIT " + f_pctTxt(tp1Price, entryPrice, isLong))
bool _tp2Evt = _live and not slHit and not tp2Hit and _tp2Cross
if _tp2Evt
    tp2Hit := true
    if not na(tp2Lbl)
        label.set_text(tp2Lbl, f_n2(_m23) + " ✓ HIT " + f_pctTxt(tp2Price, entryPrice, isLong))
bool _tp3Evt = _live and not slHit and not tp3Hit and _tp3Cross
if _tp3Evt
    tp3Hit := true
    if not na(tp3Lbl)
        label.set_text(tp3Lbl, "TP3 ✓ HIT " + f_pctTxt(tp3Price, entryPrice, isLong))
bool _finalTpHit  = tp3Hit
bool _tradeClosed = slHit or _finalTpHit
if not na(slLine) and _tradeClosed and na(_closeBar)
    _closeBar := bar_index
bool _extUpdate = _tradeClosed ? _closeBar == bar_index : barstate.islast
if not na(slLine) and _extUpdate
    int _extX = _tradeClosed ? _closeBar + 10 : last_bar_index + 10
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    if not na(tp2Lbl)
        label.set_x(tp2Lbl, _extX)
    if not na(tp3Lbl)
        label.set_x(tp3Lbl, _extX)

// ── ALERTS ──────────────────────────────────────────────────
if _newLong and barstate.isconfirmed
    string _longInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","setup":"{8}","level":"{9}"', i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick), _setup, str.tostring(_tsLong ? chLo : chLo[1], format.mintick))
    alert("{" + _longInner + "}", alert.freq_once_per_bar_close)
    string _csInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short"', i_actionCloseShort, syminfo.tickerid, timeframe.period)
    alert("{" + _csInner + "}", alert.freq_once_per_bar_close)
if _newShort and barstate.isconfirmed
    string _shortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","setup":"{8}","level":"{9}"', i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick), _setup, str.tostring(_tsShort ? chHi : chHi[1], format.mintick))
    alert("{" + _shortInner + "}", alert.freq_once_per_bar_close)
    string _clInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long"', i_actionCloseLong, syminfo.tickerid, timeframe.period)
    alert("{" + _clInner + "}", alert.freq_once_per_bar_close)
if _tp1Evt
    string _t1Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","tp":"{5}"', i_actionTp1, syminfo.tickerid, timeframe.period, isLong ? "long" : "short", str.tostring(entryPrice, format.mintick), str.tostring(tp1Price, format.mintick))
    alert("{" + _t1Inner + "}", alert.freq_once_per_bar)
if _tp2Evt
    string _t2Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","tp":"{5}"', i_actionTp2, syminfo.tickerid, timeframe.period, isLong ? "long" : "short", str.tostring(entryPrice, format.mintick), str.tostring(tp2Price, format.mintick))
    alert("{" + _t2Inner + "}", alert.freq_once_per_bar)
if _tp3Evt
    string _t3Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","tp":"{5}"', i_actionTp3, syminfo.tickerid, timeframe.period, isLong ? "long" : "short", str.tostring(entryPrice, format.mintick), str.tostring(tp3Price, format.mintick))
    alert("{" + _t3Inner + "}", alert.freq_once_per_bar)
alertcondition(_newLong and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(_newShort and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(_newShort and barstate.isconfirmed, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(_newLong and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")
alertcondition(_tp1Evt, "TP1 Hit", "MarkitTick — TP1 Reached")
alertcondition(_tp2Evt, "TP2 Hit", "MarkitTick — TP2 Reached")
alertcondition(_tp3Evt, "TP3 Hit", "MarkitTick — TP3 Reached")

// ── VISUALS ─────────────────────────────────────────────────
plot(chHi, "Channel High", color = i_showCh ? C_CH_HI : na, style = plot.style_stepline)
plot(chLo, "Channel Low", color = i_showCh ? C_CH_LO : na, style = plot.style_stepline)
if i_showMk and _newLong
    label.new(bar_index, low, "BULL", yloc = yloc.belowbar, color = C_SUP, style = label.style_label_up, textcolor = C_LBL_TXT, size = size.small)
if i_showMk and _newShort
    label.new(bar_index, high, "BEAR", yloc = yloc.abovebar, color = C_RES, style = label.style_label_down, textcolor = C_LBL_TXT, size = size.small)

// ── DASHBOARD ───────────────────────────────────────────────
string _posC = switch i_dashPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right
var table _tb = i_showDash ? table.new(_posC, 2, 22, bgcolor = C_DASH_BG, frame_color = color.new(#3a2a6d, 40), frame_width = 1, border_color = color.new(#2a3040, 40), border_width = 1) : na
float  _risk     = na(entryPrice) ? na : math.abs(entryPrice - slPrice)
float  _riskPct  = na(_risk) ? na : _risk / entryPrice * 100
int    _tpCnt    = (tp1Hit ? 1 : 0) + (tp2Hit ? 1 : 0) + (tp3Hit ? 1 : 0)
float  _chRange  = chHi - chLo
float  _chPos    = na(_chRange) or _chRange <= 0 ? na : math.max(0.0, math.min(1.0, (close - chLo) / _chRange))
float  _barsSig  = na(_sigBar) ? na : bar_index - _sigBar
string _dirTxt   = na(entryPrice) ? "—" : isLong ? "BULL" : "BEAR"
color  _dirCol   = na(entryPrice) ? C_DASH_TXT : isLong ? C_SUP : C_RES
string _status   = na(entryPrice) ? "—" : slHit ? (_tpCnt > 0 ? "Stopped after TP" + str.tostring(_tpCnt) : "Stopped") : tp3Hit ? "TP3 Hit" : tp2Hit ? "TP2 Hit" : tp1Hit ? "TP1 Hit" : "Open"
color  _statCol  = na(entryPrice) ? C_DASH_TXT : slHit ? C_RES : _tpCnt > 0 ? C_SUP : C_DASH_TXT
string _htfTxt   = not _htfValid ? "Skipped · below chart TF" : (_htfBull ? "Bull" : _htfBear ? "Bear" : "—") + " · " + f_tfFmt(i_htfTf)
color  _htfCol   = not _htfValid ? C_DASH_TXT : _htfBull ? C_SUP : _htfBear ? C_RES : C_DASH_TXT
f_row(table t, int r, string lbl, string val, color vc) =>
    color _bg = r % 2 == 1 ? C_DASH_BG : color.new(C_DASH_BG, 40)
    table.cell(t, 0, r, "  " + lbl, text_color = color.new(C_DASH_TXT, 25), text_halign = text.align_left, text_size = size.small, bgcolor = _bg)
    table.cell(t, 1, r, val + "  ", text_color = vc, text_halign = text.align_right, text_size = size.small, bgcolor = _bg)
if barstate.islast and i_showDash
    table.cell(_tb, 0, 0, "TSFB", text_color = C_DASH_TXT, text_halign = text.align_left, text_size = size.small, bgcolor = C_DASH_HDR)
    table.cell(_tb, 1, 0, syminfo.ticker + "  ·  " + f_tfFmt(timeframe.period), text_color = C_DASH_TXT, text_halign = text.align_right, text_size = size.small, bgcolor = C_DASH_HDR)
    int r = 1
    f_row(_tb, r, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? C_RES : C_DASH_TXT)
    r += 1
    f_row(_tb, r, "Mode", i_mode, C_DASH_TXT)
    r += 1
    f_row(_tb, r, "Signal", _dirTxt, _dirCol)
    r += 1
    f_row(_tb, r, "Setup", _setup, C_DASH_TXT)
    r += 1
    f_row(_tb, r, "Status", _status, _statCol)
    r += 1
    f_row(_tb, r, "Entry", f_px(entryPrice), C_DASH_TXT)
    r += 1
    f_row(_tb, r, "Stop", f_px(slPrice), C_RES)
    r += 1
    f_row(_tb, r, "TP1", f_px(tp1Price), C_SUP)
    r += 1
    f_row(_tb, r, "TP2", f_px(tp2Price), C_SUP)
    r += 1
    f_row(_tb, r, "TP3", f_px(tp3Price), C_SUP)
    r += 1
    f_row(_tb, r, "Risk", na(_risk) ? "—" : f_px(_risk) + " · " + str.tostring(_riskPct, "#.00") + "%", C_DASH_TXT)
    r += 1
    f_row(_tb, r, "Targets Hit", na(entryPrice) ? "—" : f_bar(_tpCnt, 3), na(entryPrice) ? C_DASH_TXT : f_barColor(_tpCnt / 3))
    r += 1
    f_row(_tb, r, "Channel High", f_px(chHi), C_RES)
    r += 1
    f_row(_tb, r, "Channel Low", f_px(chLo), C_SUP)
    r += 1
    f_row(_tb, r, "Channel Pos", na(_chPos) ? "—" : f_bar(_chPos, 1), na(_chPos) ? C_DASH_TXT : f_barColor(_chPos))
    r += 1
    f_row(_tb, r, "Channel Len", str.tostring(i_len), C_DASH_TXT)
    r += 1
    f_row(_tb, r, "ATR", f_px(_atrV), C_DASH_TXT)
    r += 1
    f_row(_tb, r, "Bars Since", f_num(_barsSig), C_DASH_TXT)
    r += 1
    if i_htfOn
        f_row(_tb, r, "HTF Filter", _htfTxt, _htfCol)
        r += 1
    if i_adxOn
        f_row(_tb, r, "ADX Filter", na(_adxPrev) ? "—" : f_bar(_adxPrev, 100), na(_adxPrev) ? C_DASH_TXT : f_barColor(_adxPrev / 100))
        r += 1
    if i_smooth != "None"
        f_row(_tb, r, "Smoothing", i_smooth + " · " + str.tostring(i_smLen), C_DASH_TXT)
````
