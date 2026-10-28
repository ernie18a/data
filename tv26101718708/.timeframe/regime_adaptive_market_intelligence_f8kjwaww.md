# Regime - Adaptive Market Intelligence

- url: https://www.tradingview.com/script/f8kjwaWw-Regime-Adaptive-Market-Intelligence/
- type: indicator
- pine_id: PUB;8eac46c613204000930600be04fdbf20
- version: 1.0

## Description

I built Regime to make market context easier to read without covering the chart in signals. It describes the current market regime, shows the last confirmed higher timeframe regime, and keeps trend strength, momentum and relative volatility together in a compact dashboard.

This is a market analysis indicator, not a trading strategy. It does not generate buy/sell signals, entries, stop losses, take-profit targets or performance scores. The initial defaults were designed around BTC and ETH spot charts on 1H and 4H.

[b]What you see[/b]

The upper strip in the indicator pane shows the chart timeframe regime:
- Bull, in teal: confirmed upward trend conditions.
- Bear, in muted red: confirmed downward trend conditions.
- Range, in gold: confirmed low-direction consolidation conditions.
- Transition, in gray: no confirmed trend or range, or the previous state's holding conditions no longer apply.

The thinner strip shows confirmed higher timeframe history. Automatic selection uses 4H on a 1H chart and 1D on a 4H chart. Manual choices are 4H, 1D and 1W; the selected higher timeframe must be greater than the chart timeframe. The two strips are independent: higher timeframe context does not block a local regime change.

The lower columns show relative ATR% intensity. Violet marks the confirmed High volatility state; gray is used for Normal and Low. Column height is the percentile rank of ATR%, not a price forecast. High volatility is separate from the four directional regimes.

Small labels mark confirmed changes into Bull, Bear or Range at the actual confirmation candle. Only the latest three labels are retained by default; the count is configurable from 1 to 20. Changes into Transition remain visible in the timeline without another candle label.

[b]How the regime is calculated[/b]

The classifier combines EMA 20, EMA 50, ATR 14 and ADX from DMI 14/14. EMA separation is divided by ATR, and the five-bar change in EMA 50 is also divided by ATR. This expresses direction and slope relative to recent price movement instead of fixed price distances.

With the default settings, a Bull candidate requires ADX of at least 22, normalized EMA separation of at least 0.25, and normalized EMA 50 slope of at least 0.10. A Bear candidate uses the same ADX requirement with separation at or below -0.25 and slope at or below -0.10. A Range candidate requires ADX at or below 18, absolute separation at or below 0.20, and absolute slope at or below 0.10.

Trend candidates require two consecutive qualifying candles, and Range requires three by default. These confirmation counts are configurable. Until a new state confirms, an existing Bull state may persist with ADX of at least 18 and positive separation and slope; Bear uses negative separation and slope. Range may persist while ADX is below 22, absolute separation is below 0.35, and absolute slope is below 0.20. If no state can be confirmed or retained, the result is Transition.

The separate entry, holding and exit conditions are intended to reduce rapid switching. They also introduce delay: the script is describing a confirmed condition, not identifying an exact turning point. The thresholds are design defaults, not statistically proven optimal parameters.

[b]Volatility and momentum[/b]

ATR% is ATR 14 divided by closing price and multiplied by 100. The default volatility reference is 30 calendar days converted to chart bars, with a minimum of 20 and a maximum of 1,200 bars. Thresholds use prior-bar ATR% history. High uses the 85th percentile for entry and the 70th percentile for retention. Low uses the 20th percentile for entry and the 30th percentile for retention. Normal applies between those conditions. A new volatility state requires two consecutive candidates. Column intensity uses the current confirmed ATR% percentile rank.

Momentum is a dashboard description from RSI 14: Positive at 55 or above, Negative at 45 or below, and Neutral between. RSI does not determine the directional regime.

[b]Reading the dashboard[/b]

- Market State: latest confirmed regime on the chart timeframe.
- HTF State: regime from the previous completed higher timeframe candle.
- Trend Strength: ADX mapped to a 0-100 scale using (ADX - 10) / 30, then clamped. ADX of 10 or less displays 0; ADX of 40 or more displays 100. This is not a probability, accuracy score or confidence percentage.
- Volatility: Low, Normal or High relative to recent ATR% history.
- Momentum: Positive, Negative or Neutral from RSI.
- Regime Duration: consecutive chart bars in the current confirmed state, including Transition.
- HTF Alignment: Aligned when both timeframes are Bull or both are Bear; Not aligned when their trend directions oppose; Mixed when either is Range or Transition; N/A when data is insufficient.

For example, Chart Bear with HTF Bull means bearish conditions have confirmed locally while the higher timeframe still carries bullish context. It is a description of different horizons, not an instruction to trade. The dashboard always describes the latest confirmed data; it does not follow the historical candle under the cursor.

[b]Confirmation and repainting behavior[/b]

Local displayed values and transition labels update on confirmed chart candles. While a candle is open, the local display carries the preceding confirmed result. Higher timeframe data comes from the previous completed higher timeframe candle, using an expression offset of one HTF bar together with lookahead_on. It becomes available at the start of the next HTF period, without using an unfinished HTF candle or future information. Labels are not backdated to earlier turning points.

Source review and five matched-bar reload checks found no regime-state discrepancy: BTC/ETH 1H and 4H historical samples, plus one ETH one-minute candle observed through close and reload. This is sample-based verification, not an exhaustive guarantee. That live minute check did not include a new regime transition or a higher timeframe boundary. Exchange data corrections, different settings, or a different history starting point can change recalculated results.

[b]How to use it[/b]

Add the indicator to a standard time-based candlestick chart. Start with BTCUSDT or ETHUSDT on 1H or 4H and leave Higher timeframe on Automatic. Read the chart regime first, compare it with the HTF strip, then use the dashboard and volatility columns to understand the context. Choose Dark or Light in Appearance to match your chart. The dashboard, HTF history, volatility columns and transition markers can each be hidden independently.

The code accepts intraday and daily time-based charts. On a daily chart, choose a greater manual HTF such as 1W. Allow sufficient history for the classifier and rolling volatility reference. N/A or missing early plots indicate insufficient data. Other symbols and intervals are not validated target markets for these defaults. The script does not create alert conditions.

[b]Why i combined these components[/b]

The individual indicators are standard. The contribution here is the explicit four-state classifier with ATR-normalized direction and slope, separate entry/holding rules, consecutive-bar confirmation, and an independent confirmed HTF history. RSI momentum and relative volatility remain context rather than extra directional votes. The display makes agreement and disagreement between horizons visible without adding trade instructions.

[b]License[/b]

Copyright 2026 builtbyuba / domuba. Released under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International. Noncommercial use, modification and sharing are permitted with attribution, a license reference and a notice of changes. Shared adaptations must use the same license. Resale, paid access and other commercial exploitation require separate permission. Reuse in TradingView publications must also follow TradingView's script publishing rules.

Provided as-is for market analysis. No profitability claims or trading recommendations.


[b]Chart examples[/b]

ETHUSDT spot, 4H with confirmed daily context. These historical examples illustrate the interface and different market regimes, not trading performance.

https://www.tradingview.com/x/xc4bu8eV/

ETHUSDT spot, 1H with confirmed 4H context. A local regime may change while the last confirmed higher timeframe state remains different. The dashboard describes the latest confirmed data at the time of capture.

https://www.tradingview.com/x/tdj6ARMN/

## Source Code

````pine
// © 2026 domuba / builtbyuba · REGIME v1.0.0
// SPDX-License-Identifier: CC-BY-NC-SA-4.0
// Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.
// Experimental thresholds. Regime analysis only; no trade signals.
//@version=6
indicator('REGIME — Adaptive Market Intelligence', 'REGIME', overlay = false, max_bars_back = 1500, max_labels_count = 100)

G_MODEL = 'Higher Timeframe Context'
G_STATE = 'Regime Rules · Experimental'
G_VOL = 'Volatility'
G_VIEW = 'Appearance'
htfChoice = input.string('Automatic', 'Higher timeframe', options = ['Automatic', '4H', '1D', '1W'], group = G_MODEL, display = display.none)
confirmTrend = input.int(2, 'Trend confirmation bars', minval = 1, maxval = 5, group = G_STATE, display = display.none)
confirmRange = input.int(3, 'Range confirmation bars', minval = 1, maxval = 5, group = G_STATE, display = display.none)
adxEnter = input.float(22, 'ADX: trend entry', group = G_STATE, display = display.none)
adxExit = input.float(18, 'ADX: trend exit', group = G_STATE, display = display.none)
volDays = input.int(30, 'ATR% reference days', minval = 7, maxval = 50, group = G_VOL, display = display.none)
showInfo = input.bool(true, 'Show dashboard', group = G_VIEW, display = display.none)
showHTF = input.bool(true, 'Show higher timeframe history', group = G_VIEW, display = display.none)
showVol = input.bool(true, 'Show volatility intensity', group = G_VIEW, display = display.none)
showMarkers = input.bool(true, 'Show regime transitions', group = G_VIEW, display = display.none)
markerCount = input.int(3, 'Visible transition count', minval = 1, maxval = 20, group = G_VIEW, display = display.none)
theme = input.string('Dark', 'Theme', options = ['Dark', 'Light'], group = G_VIEW, display = display.none)

bool dark = theme == 'Dark'
color surface = dark ? #161B22 : #F6F8FA
color border = dark ? #30363D : #D0D7DE
color ink = dark ? #E6EDF3 : #1F2328
color muted = dark ? #8B949E : #59636E
color bull = dark ? #35B69F : #167F6E
color bear = dark ? #D66A78 : #AC4252
color rangeInk = dark ? #C9A86A : #87651F
color highVol = dark ? #8895D8 : #5867AD
string htf = htfChoice == '4H' ? '240' : htfChoice == '1D' ? '1D' : htfChoice == '1W' ? '1W' : timeframe.in_seconds() < 14400 ? '240' : '1D'
if not timeframe.isintraday and not timeframe.isdaily
    runtime.error('Use a time-based chart. Recommended: 1H or 4H.')
if adxExit >= adxEnter
    runtime.error('ADX exit must be lower than ADX entry.')
if timeframe.in_seconds(htf) <= timeframe.in_seconds()
    runtime.error('The higher timeframe must exceed the chart timeframe.')

// +1 bull, -1 bear, 2 range, 0 transition, na insufficient data.
regime() =>
    float fast = ta.ema(close, 20)
    float slow = ta.ema(close, 50)
    float atr = ta.atr(14)
    [plus, minus, adx] = ta.dmi(14, 14)
    float gap = atr > 0 ? (fast - slow) / atr : na
    float slope = atr > 0 ? (slow - slow[5]) / atr : na
    bool ready = not na(gap) and not na(slope) and not na(adx) and bar_index >= 150
    bool up = adx >= adxEnter and gap >= 0.25 and slope >= 0.1
    bool down = adx >= adxEnter and gap <= -0.25 and slope <= -0.1
    bool flat = adx <= adxExit and math.abs(gap) <= 0.2 and math.abs(slope) <= 0.1
    int candidate = up ? 1 : down ? -1 : flat ? 2 : 0
    var int state = na
    var int pending = 0
    var int count = 0
    var int duration = 0
    if ready
        count := candidate != 0 and candidate == pending ? count + 1 : candidate != 0 ? 1 : 0
        pending := candidate
        int needed = candidate == 2 ? confirmRange : confirmTrend
        bool holdUp = adx >= adxExit and gap > 0 and slope > 0
        bool holdDown = adx >= adxExit and gap < 0 and slope < 0
        bool holdRange = adx < adxEnter and math.abs(gap) < 0.35 and math.abs(slope) < 0.2
        int prior = state
        if candidate != 0 and count >= needed
            state := candidate
        else if na(state) or not (state == 1 and holdUp or state == -1 and holdDown or state == 2 and holdRange)
            state := 0
        duration := not na(prior) and prior == state ? duration + 1 : 1
    [state, duration]

confirmedHTF() =>
    [state, duration] = regime()
    state[1]

[selectedRaw, selectedDurationRaw] = regime()
int selectedHTF = request.security(syminfo.tickerid, htf, confirmedHTF(), lookahead = barmerge.lookahead_on)
int selected = barstate.isconfirmed ? selectedRaw : selectedRaw[1]
int selectedDuration = barstate.isconfirmed ? selectedDurationRaw : selectedDurationRaw[1]

stateColor(int s) =>
    na(s) ? color.new(muted, 85) : s == 1 ? bull : s == -1 ? bear : s == 2 ? rangeInk : color.new(muted, 60)
stateName(int s) =>
    na(s) ? 'N/A' : s == 1 ? 'Bull' : s == -1 ? 'Bear' : s == 2 ? 'Range' : 'Transition'
shortName(int s) =>
    na(s) ? 'N/A' : s == 1 ? 'Bull' : s == -1 ? 'Bear' : s == 2 ? 'Range' : 'Trans'

// Local regime and confirmed HTF context remain separate.
plot(3.0, 'Chart regime', color = na(selected) ? na : stateColor(selected), linewidth = 8, style = plot.style_linebr, display = display.pane)
plot(showHTF ? 2.0 : na, 'HTF regime', color = na(selectedHTF) ? na : stateColor(selectedHTF), linewidth = 4, style = plot.style_linebr, display = display.pane)
plot(selected, 'Chart state (1/-1/2/0)', display = display.data_window)
plot(selectedHTF, 'HTF state (1/-1/2/0)', display = display.data_window)

float atrPercent = 100 * ta.atr(14) / close
int volBars = int(math.max(20, math.min(1200, math.round(volDays * 86400 / timeframe.in_seconds()))))
float thresholdHigh = ta.percentile_nearest_rank(atrPercent[1], volBars, 85)
float thresholdExit = ta.percentile_nearest_rank(atrPercent[1], volBars, 70)
float thresholdLow = ta.percentile_nearest_rank(atrPercent[1], volBars, 20)
float thresholdLowExit = ta.percentile_nearest_rank(atrPercent[1], volBars, 30)
float volRank = ta.percentrank(atrPercent, volBars)
var int volState = na
var int volCandidate = 0
var int volCount = 0
if barstate.isconfirmed and not na(thresholdHigh)
    int next = atrPercent >= thresholdHigh ? 1 : atrPercent <= thresholdLow ? -1 : volState == 1 and atrPercent >= thresholdExit ? 1 : volState == -1 and atrPercent <= thresholdLowExit ? -1 : 0
    volCount := next == volCandidate ? volCount + 1 : 1
    volCandidate := next
    if volCount >= 2
        volState := next
float frozenVolRank = barstate.isconfirmed ? volRank : volRank[1]
plot(not showVol or na(volState) ? na : 0.65 + math.max(0, math.min(1, frozenVolRank / 100)) * 0.65, 'ATR% · relative intensity', color = volState == 1 ? highVol : color.new(muted, 30), style = plot.style_columns, histbase = 0.65, display = display.pane)
hline(0, 'Pane bottom', color = color.new(muted, 100), display = display.none)
hline(4.2, 'Pane top', color = color.new(muted, 100), display = display.none)

var array<label> markers = array.new<label>()
if showMarkers and barstate.isconfirmed and not na(selectedRaw) and not na(selectedRaw[1]) and selectedRaw != 0 and selectedRaw != selectedRaw[1]
    string markerText = shortName(selectedRaw[1]) + ' → ' + shortName(selectedRaw)
    label mark = label.new(bar_index, na, markerText, yloc = selectedRaw == 1 ? yloc.belowbar : yloc.abovebar, style = selectedRaw == 1 ? label.style_label_up : label.style_label_down, color = color(na), textcolor = stateColor(selectedRaw), size = size.small, tooltip = 'EMA 20/50 + ADX 14/14\nConfirmed at bar close.', force_overlay = true)
    markers.push(mark)
    while markers.size() > markerCount
        label.delete(markers.shift())

[diPlus, diMinus, adxRaw] = ta.dmi(14, 14)
float adx = barstate.isconfirmed ? adxRaw : adxRaw[1]
float rsiRaw = ta.rsi(close, 14)
float rsi = barstate.isconfirmed ? rsiRaw : rsiRaw[1]
float strength = math.max(0, math.min(100, 100 * (adx - 10) / 30))
string alignment = na(selectedHTF) or na(selected) ? 'N/A' : selected == 0 or selectedHTF == 0 or selected == 2 or selectedHTF == 2 ? 'Mixed' : selected == selectedHTF ? 'Aligned' : 'Not aligned'
string htfName = htf == '240' ? '4H' : htf == '1D' ? '1D' : '1W'
var table dashboard = table.new(position.top_right, 2, 9, bgcolor = surface, frame_color = border, frame_width = 1, border_color = color.new(border, 60), border_width = 1, force_overlay = true)
// Legend labels align with the actual lane prices; no table row mismatch.
var label localName = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_center, color = surface, textcolor = ink, size = size.small)
var label htfLabel = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_center, color = surface, textcolor = muted, size = size.small)
var label volLabel = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_center, color = surface, textcolor = muted, size = size.tiny)
if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 1, 0)
    table.merge_cells(dashboard, 0, 8, 1, 8)

row(int n, string name, string value, color valueColor) =>
    table.cell(dashboard, 0, n, ' ' + name + ' ', text_color = muted, text_size = size.small, text_halign = text.align_left)
    table.cell(dashboard, 1, n, ' ' + value + ' ', text_color = valueColor, text_size = size.small, text_halign = text.align_right)

if barstate.islast
    if showInfo
        table.cell(dashboard, 0, 0, ' REGIME / MARKET INTELLIGENCE ', text_color = ink, text_size = size.small, text_halign = text.align_left)
        row(1, 'Market State · ' + (timeframe.period == '60' ? '1H' : timeframe.period == '240' ? '4H' : timeframe.period), stateName(selected), stateColor(selected))
        row(2, 'HTF State · ' + htfName, stateName(selectedHTF), stateColor(selectedHTF))
        row(3, 'Trend Strength', na(adx) ? 'N/A' : str.tostring(strength, '#') + ' / 100', ink)
        row(4, 'Volatility', na(volState) ? 'N/A' : volState == 1 ? 'High' : volState == -1 ? 'Low' : 'Normal', volState == 1 ? highVol : ink)
        row(5, 'Momentum', na(rsi) ? 'N/A' : rsi >= 55 ? 'Positive' : rsi <= 45 ? 'Negative' : 'Neutral', ink)
        row(6, 'Regime Duration', na(selected) ? 'N/A' : str.tostring(selectedDuration) + ' bars', ink)
        row(7, 'HTF Alignment', alignment, ink)
        table.cell(dashboard, 0, 8, ' V1.0 · CLOSED BARS ', text_color = muted, text_size = size.tiny)
    else
        table.clear(dashboard, 0, 0, 1, 8)
    int legendTime = chart.left_visible_bar_time + int((chart.right_visible_bar_time - chart.left_visible_bar_time) * 0.08)
    label.set_xy(localName, legendTime, 3.0)
    label.set_text(localName, 'Chart')
    label.set_xy(htfLabel, legendTime, 2.0)
    label.set_text(htfLabel, showHTF ? htfName : '')
    label.set_color(htfLabel, showHTF ? surface : color(na))
    label.set_xy(volLabel, legendTime, 0.8)
    label.set_text(volLabel, showVol ? 'Volatility' : '')
    label.set_color(volLabel, showVol ? surface : color(na))
````
