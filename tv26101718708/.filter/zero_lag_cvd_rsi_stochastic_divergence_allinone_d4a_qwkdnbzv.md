# Zero Lag CVD, RSI & Stochastic Divergence (All-in-One) [D4A]

- url: https://www.tradingview.com/script/qwkdNbZv-Zero-Lag-CVD-RSI-Stochastic-Divergence-All-in-One-D4A/
- type: indicator
- pine_id: PUB;88a575aa1a2a4c55b4c3748a776ba228
- version: 3.0

## Description

[b]Zero Lag CVD, RSI, Stochastic Divergence[/b]

[b]Overview[/b]

Zero-Lag Divergence indicator is designed to identify bullish and bearish divergences as they happen, without relying on traditional pivot confirmation delays. By comparing price action with output of CVD, RSI and Stochastic across two independent detection periods, the indicator helps traders spot potential trend exhaustion and reversal opportunities earlier than conventional divergence tools.

[b]How is this indicator different from other similar tools?[/b]

- Provides real-time non-repainting divergence signals for CVD, RSI and Stochastic in one convenient script
- Provides instant and separate divergence signals for one of the three oscillators (CVD, RSI, Stochastic), combination of two oscillators or combination of all three (Agreement Mode), thus marking double or triple confirmation of discrepancy between the price, momentum and volume, signalling potentially important reversal zone.
- To maximize probability of validity of the signal, the user can configure overbought and oversold conditions for both momentum oscillators (RSI & Stochastic) to filter only the strongest signals.
- To keep chart clutter under control the tool combines divergence labels into one common label in Agreement Mode
- The indicator tracks divergence simultaneously using two different and configurable periods (short- and long-term divergence) thus allowing to track shorter and longer periods for possible divergences while using only one timeframe
- Displays all signals directly on the chart - no need for additional panel below or above the chart
- All three oscillators can be independently configured, eg. signal length, smoothing, overbought and oversold levels.

Bullish Divergence Logic
Occurs when price forms a lower low while oscillator forms a higher low, suggesting weakening bearish momentum (volume) and the possibility of an upward reversal.

Bearish Divergence Logic
Occurs when price forms a higher high while oscillator forms a lower high, indicating weakening bullish momentum (volume) and the potential for a downward move.

Why Zero-Lag?

Most divergence indicators require future candle confirmation before displaying a signal. This indicator prioritizes immediacy by highlighting potential divergences as they form, allowing traders to react sooner to developing momentum shifts.

While this approach can generate earlier opportunities, it may also create false signals and market noise. For best results, consider combining divergence signals with trend analysis, support and resistance levels, volume studies, or additional confirmation tools.

Notes

* Signals are non-repainting once generated.
* Earlier detection may result in more frequent signals compared to traditional pivot-confirmed divergence indicators.
* Suitable for stocks, forex, cryptocurrencies, indices, and other liquid markets.
* Can be used on any timeframe, from intraday trading to higher-timeframe swing analysis.

[b]SETTINGS[/b]

- Zero-Lag Divergence - enable the display of signals

- Mode - select for which oscillator should divergence signals be plotted:
 CVD - Cumulative Volume Delta
 RSI - Relative Strength Index
 Stochastic - Momentum oscillator
 Agreement - two or three indicators agree at the same time (same candle)

- Minimum Agreement - how many indicators should agree at the same time: Any Two or Any Three

- Cumulative Volume Delta Length

- RSI Length, OB (overbought) level , OS (oversold) level. OB and OS levels can be used to select more extreme zones to find divergence (stronger signals).

- Stochastic: %K and Smoothing settings, as well as OB and OS settings (work similar to RSI logic)

- Show Labels - show labels on the chart

- Bullish Label - can be set and color coded for different indicators

- Bearish Label - can be set and color coded for different indicators

- All Oscillators Agree - displays label when all three oscillators generate divergence signals at the same time

- RSI + Stochastic - displays label when both RSI and Stochastic agree at the same time

- CVD + Stochastic - displays label when both CVD and Stochastic agree at the same time

- CVD + RSI - displays label when both CVD and RSI agree at the same time

- RSI Divergence Label only if RSI >=OB or RSI <= OS - display the label only when RSI divergence signals are detected at user-defined overbought or oversold levels

- Stochastic Divergence Label only if Stochastic >=OB or Stochastic <= OS - display the label only when Stochastic divergence signals are detected at user-defined overbought or oversold levels

- Show Lines - draw lines between divergence points.

- Short Period - define the 1st period for which divergence is detected

- Long Period - define the 2nd period for which divergence is detected

- Distance Multiplier & ATR - used to position the labels at specific distance from divergence point

What is CVD?
CVD measures the cumulative difference between buying and selling volume. A rising CVD indicates more buying pressure, while a falling CVD indicates more selling pressure. Divergence occurs when the price action contradicts the CVD's direction, suggesting a potential shift in momentum or trend reversal. 

What is RSI?
The relative strength index (RSI) is a momentum indicator used to measures the speed and magnitude of a asset's recent price changes to detect overbought or oversold conditions.

What is Stochastic?
Trading View definition: Stochastic Oscillator (STOCH) is a range bound momentum oscillator. The Stochastic indicator is designed to display the location of the close compared to the high/low range over a user defined number of periods. Typically, the Stochastic Oscillator is used for three things; Identifying overbought and oversold levels, spotting divergences and also identifying bull and bear set ups or signals.

-----------------
Disclaimer

The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dub4art

//@version=6
indicator('Zero-Lag Divergence', shorttitle = 'ZeroDT', max_labels_count = 100, overlay = true)

var gRSIF = "Zero-Lag Divergence"
showDivergence = input.bool(true, 'Zero-Lag Divergence    ',inline = 'sym0', group = gRSIF)
d_mode = input.string('Agreement' , title = 'Mode' , options =['CVD', 'RSI', 'Stochastic', 'Agreement'], inline = 'sym0', group=gRSIF)
agreeFilter = input.string('Two or Three', 'Minimum Agreement', options = ['Any Two', 'Two or Three', 'All Three'], group = gRSIF)
showPeriodTag = input.bool(true, 'Show Short/Long Period Tag (S/L) on Agreement Labels', group = gRSIF)

cumulation_length = input(23, '    Cumulative Volume Delta (CVD):   Length',group = gRSIF)
rsiLength = input(14, '    RSI:    Length   ', inline = 'rsid01', group = gRSIF)
rsiOB = input(60, 'OB', inline = 'rsid01', group = gRSIF)
rsiOS = input(40, 'OS', inline = 'rsid01', group = gRSIF)

periodK = input.int(18, title="    Stochastic:    %K Length", minval=1, inline = 'sto1', group = gRSIF)
smoothK = input.int(3, title="Smoothing", minval=1, inline = 'sto1', group = gRSIF)
stoOB = input(80, '        OB', inline = 'sto2', group = gRSIF)
stoOS = input(20, 'OS', inline = 'sto2', group = gRSIF)

showLabel = input.bool(true, 'Show Labels', inline = 'lbl1', group = gRSIF)
lbl_col = input.color(color.new(color.white,0), "", inline = 'lbl1', group = gRSIF)
bullDivTxt = input.string('B', 'Bullish Label', inline = 'rsid3', group = gRSIF)
bullLabel_cvd = input.color(color.new(color.teal,30), 'CVD', inline = 'rsid3', group = gRSIF)
bullLabel_rsi = input.color(color.green, 'RSI', inline = 'rsid3', group = gRSIF)
bullLabel_sto = input.color(color.blue, 'Stochastic', inline = 'rsid3', group = gRSIF)
bearDivTxt = input.string('B', 'Bearish Label', inline = 'rsid4', group = gRSIF)
bearLabel_cvd = input.color(color.new(#E71A64,30), 'CVD', inline = 'rsid4', group = gRSIF)
bearLabel_rsi = input.color(color.red, 'RSI', inline = 'rsid4', group = gRSIF)
bearLabel_sto = input.color(color.orange, 'Stochastic', inline = 'rsid4', group = gRSIF)

// Agreement mode settings
showALL     = input.bool(true, 'All Oscillators Agree',  inline = 'ag0', group = gRSIF)
bullAgree_ALL     = input.color(color.new(color.green, 50),   '', inline = 'ag0', group = gRSIF)
bearAgree_ALL     = input.color(color.new(color.red,50),   '', inline = 'ag0', group = gRSIF)
allDivTxt = input.string('ALL', '   Divergence Text', inline = 'ag0', group = gRSIF)
showRSISto  = input.bool(true, 'RSI + Stochastic',   inline = 'ag1', group = gRSIF)
bullAgree_RSISto  = input.color(color.new(#316457, 50),  '', inline = 'ag1', group = gRSIF)
bearAgree_RSISto  = input.color(color.new(color.maroon,   50),  '', inline = 'ag1', group = gRSIF)
rsistoDivTxt = input.string('RSISto', '   Divergence Text', inline = 'ag1', group = gRSIF)
showCVDSto  = input.bool(true, 'CVD + Stochastic',   inline = 'ag2', group = gRSIF)
bullAgree_CVDSto  = input.color(color.new(#316457,  50),  '', inline = 'ag2', group = gRSIF)
bearAgree_CVDSto  = input.color(color.new(color.maroon,50),  '', inline = 'ag2', group = gRSIF)
cvdstoDivTxt = input.string('CVDSto', '   Divergence Text', inline = 'ag2', group = gRSIF)
showCVDRSI  = input.bool(true, 'CVD + RSI',          inline = 'ag3', group = gRSIF)
bullAgree_CVDRSI  = input.color(color.new(#316457,    50),  '', inline = 'ag3', group = gRSIF)
bearAgree_CVDRSI  = input.color(color.new(color.maroon,    50),  '', inline = 'ag3', group = gRSIF)
cvdrsiDivTxt = input.string('CVDRSI', '   Divergence Text', inline = 'ag3', group = gRSIF)

showCVD = input.bool(true, 'CVD Numerical Value', group = gRSIF)
showOBOS = input.bool(true, 'RSI Divergence Label Only if RSI >= OB or RSI <= OS', group = gRSIF)
showOBOS_sto = input.bool(true, 'Stochastic Divergence Label Only if Stochastic >= OB or Stochastic <= OS', group = gRSIF)
showLines = input.bool(false, 'Show Lines', group = gRSIF)
div_short = input.bool(true, '', inline = 'rsid1', group = gRSIF)
div_len1 = input(15, 'Short Period', inline = 'rsid1', group = gRSIF)
color1 = input.color(color.purple, '    Line', inline = 'rsid1', group = gRSIF)
div_long = input.bool(true, '', inline = 'rsid2', group = gRSIF)
div_len2 = input(40, 'Long Period', inline = 'rsid2', group = gRSIF)
color2 = input.color(color.blue, '    Line', inline = 'rsid2', group = gRSIF)
multi = input.float(0.3, 'Distance Multiplier', minval=0, maxval=1, step=0.01, inline = 'disp3', group = gRSIF)
atr_v = input.int(100, '    ATR', inline = 'disp3', group = gRSIF, tooltip = "Used to calculate label distance\n\nYou may play around with Distance Multiplier to find the best value for the asset you are trading")

atr_ok = nz(atr_v) * syminfo.mintick

// ── Oscillators ──────────────────────────────────────────────────────────────
upper_wick = close > open ? high - close : high - open
lower_wick = close > open ? open - low : close - low
spread = high - low
body_length = spread - (upper_wick + lower_wick)
percent_upper_wick = upper_wick / spread
percent_lower_wick = lower_wick / spread
percent_body_length = body_length / spread
buying_volume  = close > open ? (percent_body_length + (percent_upper_wick + percent_lower_wick) / 2) * volume : (percent_upper_wick + percent_lower_wick) / 2 * volume
selling_volume = close < open ? (percent_body_length + (percent_upper_wick + percent_lower_wick) / 2) * volume : (percent_upper_wick + percent_lower_wick) / 2 * volume
cumulative_buying_volume  = ta.ema(buying_volume,  cumulation_length)
cumulative_selling_volume = ta.ema(selling_volume, cumulation_length)
cumulative_volume_delta   = cumulative_buying_volume - cumulative_selling_volume

osc_cvd = cumulative_volume_delta
osc_rsi = ta.rsi(close, rsiLength)
rsi_ob = osc_rsi >= rsiOB and showOBOS
rsi_os = osc_rsi <= rsiOS and showOBOS
rsi_nob = osc_rsi > 0 and not showOBOS
osc_sto = ta.sma(ta.stoch(close, high, low, periodK), smoothK)
sto_ob = osc_sto >= stoOB and showOBOS_sto
sto_nob = osc_sto > 0 and not showOBOS_sto
sto_os = osc_sto <= stoOS and showOBOS_sto

// Active oscillator for single-mode operation
osc = d_mode == 'Stochastic' ? osc_sto : d_mode == 'RSI' ? osc_rsi : d_mode == 'CVD' ? osc_cvd : osc_sto

// ── Helpers ───────────────────────────────────────────────────────────────────
f_highest(src, length, startIndex) =>
    float maxValue = src[startIndex]
    int _indx = 0
    for i = startIndex to length by 1
        if src[i] > maxValue
            maxValue := src[i]
            _indx := i
    [maxValue, _indx]

f_lowest(src, length, startIndex) =>
    float minValue = src[startIndex]
    int _indx = 0
    for i = startIndex to length by 1
        if src[i] < minValue
            minValue := src[i]
            _indx := i
    [minValue, _indx]

// Returns [bearishDiv, bullishDiv] for any oscillator over a given lookback
f_divSignals(oscSrc, length) =>
    bullishCandle_ = close > open
    bearishCandle_ = close < open
    [hp, _]  = f_highest(high,   length, 2)
    isTop_   = bearishCandle_ and bullishCandle_[1] and hp <= high[1]
    [lp, _]  = f_lowest(low,    length, 2)
    isBot_   = bullishCandle_ and bearishCandle_[1] and lp >= low[1]
    [hosc, _] = f_highest(oscSrc, length, 2)
    bear_    = isTop_ and (hosc > oscSrc[1])
    [losc, _] = f_lowest(oscSrc,  length, 2)
    bull_    = isBot_ and (losc  < oscSrc[1])
    [bear_, bull_]

bullishCandle = close > open
bearishCandle = close < open

// ── Divergence detection (short + long, all three oscillators) ────────────────
[bearDiv_rsi_s,  bullDiv_rsi_s]  = f_divSignals(osc_rsi, div_len1)
[bearDiv_sto_s,  bullDiv_sto_s]  = f_divSignals(osc_sto, div_len1)
[bearDiv_cvd_s,  bullDiv_cvd_s]  = f_divSignals(osc_cvd, div_len1)

[bearDiv_rsi_l,  bullDiv_rsi_l]  = f_divSignals(osc_rsi, div_len2)
[bearDiv_sto_l,  bullDiv_sto_l]  = f_divSignals(osc_sto, div_len2)
[bearDiv_cvd_l,  bullDiv_cvd_l]  = f_divSignals(osc_cvd, div_len2)

// OB/OS gate applied per oscillator
bearDiv_rsi_s_gated = bearDiv_rsi_s and (not showOBOS     or rsi_ob)
bullDiv_rsi_s_gated = bullDiv_rsi_s and (not showOBOS     or rsi_os)
bearDiv_sto_s_gated = bearDiv_sto_s and (not showOBOS_sto or sto_ob)
bullDiv_sto_s_gated = bullDiv_sto_s and (not showOBOS_sto or sto_os)
bearDiv_rsi_l_gated = bearDiv_rsi_l and (not showOBOS     or rsi_ob)
bullDiv_rsi_l_gated = bullDiv_rsi_l and (not showOBOS     or rsi_os)
bearDiv_sto_l_gated = bearDiv_sto_l and (not showOBOS_sto or sto_ob)
bullDiv_sto_l_gated = bullDiv_sto_l and (not showOBOS_sto or sto_os)

// CVD has no OB/OS gate – use as-is
bearDiv_cvd_s_gated = bearDiv_cvd_s
bullDiv_cvd_s_gated = bullDiv_cvd_s
bearDiv_cvd_l_gated = bearDiv_cvd_l
bullDiv_cvd_l_gated = bullDiv_cvd_l

// ── Single-oscillator mode helpers (preserves original behaviour) ─────────────
[highestPrice,  highestPriceIndx]  = f_highest(high, div_len1, 2)
isTop  = bearishCandle and bullishCandle[1] and highestPrice  <= high[1]
[lowestPrice,   lowestPriceIndx]   = f_lowest(low,  div_len1, 2)
isBottom  = bullishCandle and bearishCandle[1] and lowestPrice  >= low[1]

[highestPrice2, highestPriceindx2] = f_highest(high, div_len2, 2)
isTop2 = bearishCandle and bullishCandle[1] and highestPrice2 <= high[1]
[lowestPrice2,  lowestPriceindx2]  = f_lowest(low,  div_len2, 2)
isBottom2 = bullishCandle and bearishCandle[1] and lowestPrice2 >= low[1]

bearishDiv  = false
[highestOSC,  highestOSCindx]  = f_highest(osc, div_len1, 2)
if isTop
    bearishDiv := highestOSC > osc[1]

bullishDiv  = false
[lowestOSC,   lowestOSCindx]   = f_lowest(osc, div_len1, 2)
if isBottom
    bullishDiv := lowestOSC < osc[1]

bearishDiv2 = false
[highestOSC2, highestOSCindx2] = f_highest(osc, div_len2, 2)
if isTop2
    bearishDiv2 := highestOSC2 > osc[1]

bullishDiv2 = false
[lowestOSC2,  lowestOSCindx2]  = f_lowest(osc, div_len2, 2)
if isBottom2
    bullishDiv2 := lowestOSC2 < osc[1]

// ── Label drawing helper ──────────────────────────────────────────────────────
f_drawLabel(isBear, yPrice, labelTxt, labelColor, labelStyle) =>
    if showLabel
        label.new(bar_index, yPrice, text = labelTxt, textcolor = lbl_col, style = labelStyle, color = labelColor, size = size.small)

// ── Single-oscillator label logic (short period) ──────────────────────────────
if isTop and bearishDiv and showDivergence and div_short
    if showLines
        line.new(bar_index - highestOSCindx, high[highestOSCindx], bar_index, high, xloc = xloc.bar_index, style = line.style_dashed, color = color1)
    if showLabel
        if d_mode == 'RSI' and rsi_ob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'RSI' and rsi_nob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'Stochastic' and sto_ob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'Stochastic' and sto_nob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'CVD'
            label.new(bar_index, high + atr_ok * multi, text = showCVD ? str.tostring(osc_cvd, "#") : bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_cvd, size = showCVD ? size.small : size.tiny, tooltip = str.tostring(osc_cvd, "#"))

if isBottom and bullishDiv and showDivergence and div_short
    if showLines
        line.new(bar_index - lowestOSCindx, low[lowestOSCindx], bar_index, low, xloc = xloc.bar_index, style = line.style_dashed, color = color1)
    if showLabel
        if d_mode == 'RSI' and rsi_os
            label.new(bar_index, low  - atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bullLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'RSI' and rsi_nob
            label.new(bar_index, low  - atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bullLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'Stochastic' and sto_os
            label.new(bar_index, low - atr_ok * multi, text = bullDivTxt, textcolor = lbl_col, style = label.style_label_up, color = bullLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'Stochastic' and sto_nob
            label.new(bar_index, low - atr_ok * multi, text = bullDivTxt, textcolor = lbl_col, style = label.style_label_up, color = bullLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'CVD'
            label.new(bar_index, low - atr_ok * multi, text = showCVD ? str.tostring(osc_cvd, "#") : bullDivTxt, textcolor = lbl_col, style = label.style_label_up, color = bullLabel_cvd, size = showCVD ? size.small : size.tiny, tooltip = str.tostring(osc_cvd, "#"))


// ── Single-oscillator label logic (long period) ───────────────────────────────
if isTop2 and bearishDiv2 and showDivergence and div_long
    if showLines
        line.new(bar_index - highestOSCindx2, high[highestOSCindx2], bar_index, high, xloc = xloc.bar_index, style = line.style_dashed, color = color2)
    if showLabel
        if d_mode == 'RSI' and rsi_ob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'RSI' and rsi_nob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'Stochastic' and sto_ob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'Stochastic' and sto_nob
            label.new(bar_index, high + atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'CVD'
            label.new(bar_index, high + atr_ok * multi, text = showCVD ? str.tostring(osc_cvd, "#") : bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bearLabel_cvd, size = showCVD ? size.small : size.tiny, tooltip = str.tostring(osc_cvd, "#"))

if isBottom2 and bullishDiv2 and showDivergence and div_long
    if showLines
        line.new(bar_index - lowestOSCindx2, low[lowestOSCindx2], bar_index, low, xloc = xloc.bar_index, style = line.style_dashed, color = color2)
    if showLabel
        if d_mode == 'RSI' and rsi_os
            label.new(bar_index, low  - atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bullLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'RSI' and rsi_nob
            label.new(bar_index, low  - atr_ok * multi, text = bearDivTxt, textcolor = lbl_col, style = label.style_label_down, color = bullLabel_rsi, size = size.tiny, tooltip = str.tostring(osc_rsi, "#"))
        if d_mode == 'Stochastic' and sto_os
            label.new(bar_index, low - atr_ok * multi, text = bullDivTxt, textcolor = lbl_col, style = label.style_label_up, color = bullLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'Stochastic' and sto_nob
            label.new(bar_index, low - atr_ok * multi, text = bullDivTxt, textcolor = lbl_col, style = label.style_label_up, color = bullLabel_sto, size = size.tiny, tooltip = str.tostring(osc_sto, "#"))
        if d_mode == 'CVD'
            label.new(bar_index, low - atr_ok * multi, text = showCVD ? str.tostring(osc_cvd, "#") : bullDivTxt, textcolor = lbl_col, style = label.style_label_up, color = bullLabel_cvd, size = showCVD ? size.small : size.tiny, tooltip = str.tostring(osc_cvd, "#"))


// ── Agreement mode ────────────────────────────────────────────────────────────
f_agreementLabels(bearRSI, bullRSI, bearSTO, bullSTO, bearCVD, bullCVD, periodLabel, lineColor) =>
    yHigh  = high + atr_ok * multi
    yLow   = low - atr_ok * multi

    allBear = bearCVD and bearRSI and bearSTO
    allBull = bullCVD and bullRSI and bullSTO

    // All Three
    if showALL and allBear and (agreeFilter == 'All Three' or agreeFilter == 'Two or Three')
        if showLines
            line.new(bar_index - 1, high[1], bar_index, high, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
        f_drawLabel(true,  yHigh + atr_ok * multi * 0.5, allDivTxt + periodLabel, bearAgree_ALL, label.style_label_down)
    if showALL and allBull and (agreeFilter == 'All Three' or agreeFilter == 'Two or Three')
        if showLines
            line.new(bar_index - 1, low[1], bar_index, low, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
        f_drawLabel(false, yLow - atr_ok * multi * 0.5,  allDivTxt + periodLabel, bullAgree_ALL, label.style_label_up)

    // Pairs — only when All Three has NOT already fired (avoid duplicate labels)
    if not allBear and not allBull and (agreeFilter == 'Any Two' or agreeFilter == 'Two or Three')
        if showRSISto and bearRSI and bearSTO
            if showLines
                line.new(bar_index - 1, high[1], bar_index, high, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
            f_drawLabel(true,  yHigh, rsistoDivTxt + periodLabel, bearAgree_RSISto, label.style_label_down)
        if showRSISto and bullRSI and bullSTO
            if showLines
                line.new(bar_index - 1, low[1], bar_index, low, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
            f_drawLabel(false, yLow,  rsistoDivTxt + periodLabel, bullAgree_RSISto, label.style_label_up)
        if showCVDSto and bearCVD and bearSTO
            if showLines
                line.new(bar_index - 1, high[1], bar_index, high, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
            f_drawLabel(true,  yHigh, cvdstoDivTxt + periodLabel, bearAgree_CVDSto, label.style_label_down)
        if showCVDSto and bullCVD and bullSTO
            if showLines
                line.new(bar_index - 1, low[1], bar_index, low, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
            f_drawLabel(false, yLow, cvdstoDivTxt + periodLabel, bullAgree_CVDSto, label.style_label_up)
        if showCVDRSI and bearCVD and bearRSI
            if showLines
                line.new(bar_index - 1, high[1], bar_index, high, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
            f_drawLabel(true,  yHigh, cvdrsiDivTxt + periodLabel, bearAgree_CVDRSI, label.style_label_down)
        if showCVDRSI and bullCVD and bullRSI
            if showLines
                line.new(bar_index - 1, low[1], bar_index, low, xloc = xloc.bar_index, style = line.style_dashed, color = lineColor)
            f_drawLabel(false, yLow, cvdrsiDivTxt + periodLabel, bullAgree_CVDRSI, label.style_label_up)

if d_mode == 'Agreement' and showDivergence
    if div_short
        f_agreementLabels(bearDiv_rsi_s_gated, bullDiv_rsi_s_gated, bearDiv_sto_s_gated, bullDiv_sto_s_gated, bearDiv_cvd_s_gated, bullDiv_cvd_s_gated,showPeriodTag ? ' S' : '', color1)
    if div_long
        f_agreementLabels(bearDiv_rsi_l_gated, bullDiv_rsi_l_gated, bearDiv_sto_l_gated, bullDiv_sto_l_gated, bearDiv_cvd_l_gated, bullDiv_cvd_l_gated,showPeriodTag ? ' L' : '', color2)
````
