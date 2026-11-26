# Daily Trading Dashboard

- url: https://www.tradingview.com/script/IKc9kPHS-Daily-Trading-Dashboard/
- type: indicator
- pine_id: PUB;0e6c18b3d5574e408ea0de9503ea5600
- version: 2.0

## Description

Daily Trading Dashboard (Multi-Timeframe Market Regime Matrix)

Overview.
The Daily Trading Dashboard (DTD) is a compact, high-performance tactical HUD built entirely in Pine Script v6. It condenses multiple complex layers — dollar liquidity profiling, volatility regime analysis, statistical trend maturity (Z-Score), intraday conviction velocity, and higher-timeframe momentum — into a single clean table overlay.Instead of stacking several indicator panes that consume resources and clutter your screen, DTD executes everything in one optimized stream, giving you institutional-grade market regime awareness at a glance.

Core Components & Logic.

Real-Time Dollar Liquidity Engine (D-Liq):
Dynamically measures daily liquidity depth:
Dollar Liquidity = SMA(Volume, Lookback) × Close / 1,000,000,000
The cell turns green when liquidity exceeds your custom billion-dollar threshold, helping you avoid thin, dangerous instruments.

Customizable Normal Distribution Regime (Z-Score)
Calculates statistical position relative to a user-selectable moving average (SMA/EMA):
Z-Score = (Close − MA) / StDev
Instantly labels the trend maturity with clear risk zones:
OVERSOLD (≤ -3) → HOSTILE → WEAK → NEUTRAL → STRONG → OVERBOUGHT (≥ 3)

Quantified Average Daily Range Delta Velocity (D-qADR% & ΔqADR%):
The proprietary heart of the script.  qADR% = SMA((High/Low − 1) × 100, Lookback) — historical expected daily range percentage.  
ΔqADR% measures how much of that expected range has already been covered in the current session.
When ΔqADR% reaches or exceeds +100% / -100%, it signals powerful institutional conviction and potential exhaustion.

Macro Timeframe Synergy:
Pulls Weekly ROC(50) and Weekly RSI(14) via request.security so you can instantly see higher-timeframe alignment without changing charts.

Parabolic Exhaustion Banner:
When both Daily RSI and Weekly RSI exceed your chosen threshold (default 80), the dashboard expands with a bold, high-visibility “PARABOLIC” warning banner — your cue to tighten trailing stops or prepare for mean reversion.

Visual & Operational Features.

Matrix Background States:
Entire rows shift between soft green (price above chosen MA) and soft red (price below MA).

Daily Conviction Circles: 
Tiny circles plotted above/below bars on the daily timeframe show exact ΔqADR% conviction levels (deep green = strong bullish, deep red = strong bearish).

Optional Bar Coloring: Toggle “Color Bars by Daily ΔqADR Conviction” to paint solid green/red candles once the 100% historical range threshold is reached.

Clean Pine v6 Architecture: Uses strict typing, tuple functions, single security call, and conditional table.clear() to ensure maximum performance and zero visual jitter.

Alert Conditions (Built-in):
D-ΔqADR% ≥ +100% → “Very Strong Bull conviction on Daily”  
D-ΔqADR% ≤ -100% → “Very Strong Bear conviction on Daily”  
BECAME Parabolic → Both Daily & Weekly RSI cross above your threshold  
NO LONGER Parabolic → Exit from parabolic state

## Source Code

````pine
//@version=6
indicator("Daily Trading Dashboard", shorttitle="DTD", overlay=true, max_bars_back=252)

// === INPUTS ===
maTypeInput   = input.string('SMA', 'MA Type for BG Color', options=['SMA','EMA','WMA','VWMA','HMA'], group='MA Settings')
maLength      = input.int(20, 'MA Length for BG Color', minval=1, group='MA Settings')

rsiLength     = input.int(14, 'RSI Length', minval=1, group='RSI Settings')
rsiCutoff     = input.int(50, 'RSI Color Cutoff (>= Green)', minval=0, maxval=100, group='RSI Settings')
parabolicCut  = input.int(80, 'Parabolic RSI Cutoff', minval=0, maxval=100, group='RSI Settings', tooltip="When Daily and Weekly RSI are above this, table highlights Parabolic Color")
parabolicCol  = input.color(color.new(color.red, 60), "Parabolic Highlight Color", group='RSI Settings')

liquidityLookback = input.int(30, 'Liquidity Lookback (Days)', minval=1, maxval=252, group='Liquidity')
liqCutoffB    = input.float(0.1, 'Liquidity Cutoff (Billions, >= Green)', minval=0.0, step=0.1, group='Liquidity')

show_qADR     = input.bool(true, 'Show D-qADR%?', group='qADR Settings')
adrLookback   = input.int(20, 'qADR Lookback (Days)', minval=1, maxval=20, group='qADR Settings')
qadrCutoff    = input.float(4.0, 'D-qADR% Bottom Cutoff (>= Green)', minval=0.0, maxval=100.0, step=0.1, group='qADR Settings')
qadrTopCutoff = input.float(10.0, 'D-qADR% Top Cutoff (<= Green)', minval=0.0, maxval=100.0, step=0.1, group='qADR Settings')
qadrSigFigs   = input.int(2, 'D-qADR% Significant Figures', minval=1, maxval=5, group='qADR Settings')

show_qADR_Pct = input.bool(true, 'Show D-ΔqADR%?', group='ΔqADR% Settings')
show_delta_signals = input.bool(true, title='Display Delta qADR Signals', group='ΔqADR% Settings')
colorBarsByDelta   = input.bool(false, title='Color Bars by Daily ΔqADR Conviction?', group='ΔqADR% Settings')

showWeeklyROC = input.bool(true, title='Show W-ROC(50)?', group='Weekly Settings')
showWeeklyRSI = input.bool(false, title='Show W-RSI(14)?', group='Weekly Settings')

// === Z-SCORE INPUTS ===
showZScore    = input.bool(true, 'Show Z-Score?', group='Z-Score Settings')
zMaType       = input.string('EMA', 'Z-Score MA Type', options=['SMA','EMA'], group='Z-Score Settings')
zLength       = input.int(50, 'Z-Score MA Period', minval=5, maxval=300, group='Z-Score Settings')

tablePosInput = input.string('Middle Right', 'Table Position', options=['Top Right','Middle Right','Bottom Right'], group='Display Settings')
var string pos = switch tablePosInput
    'Top Right'     => position.top_right
    'Middle Right'  => position.middle_right
    'Bottom Right'  => position.bottom_right
    => position.middle_right

// === DAILY CALCULATIONS FUNCTION ===
f_daily_metrics(simple int rsiLen, simple int liqLook, simple int adrLook, simple string maType, simple int maLen, simple string zMaTyp, simple int zLen) =>
    d_rsi  = ta.rsi(close, rsiLen)
    d_avgV = ta.sma(volume, liqLook)
    d_liq  = (d_avgV * close) / 1000000000
    
    d_qadr_raw = ta.sma((high / low - 1) * 100, adrLook)
    
    d_ma = switch maType
        'SMA'  => ta.sma(close, maLen)
        'EMA'  => ta.ema(close, maLen)
        'WMA'  => ta.wma(close, maLen)
        'VWMA' => ta.vwma(close, maLen)
        'HMA'  => ta.hma(close, maLen)
    
    z_ma = zMaTyp == 'EMA' ? ta.ema(close, zLen) : ta.sma(close, zLen)
    z_stdev = ta.stdev(close, zLen)
    d_zscore = (close - z_ma) / z_stdev
    
    [d_rsi, d_liq, d_qadr_raw, d_ma, d_zscore, close, open]

// === REQUEST DATA ===
[z_rsiValue, z_liquidityB, z_qADR_Pct_raw, z_maCutoff, zscoreValue, d_close, d_open] = request.security(syminfo.tickerid, 'D', f_daily_metrics(rsiLength, liquidityLookback, adrLookback, maTypeInput, maLength, zMaType, zLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[weeklyROC50, weeklyRSIValue] = request.security(syminfo.tickerid, 'W', [ta.roc(close, 50), ta.rsi(close, 14)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// === PARABOLIC DETECTION ===
is_parabolic = (z_rsiValue > parabolicCut) and (weeklyRSIValue > parabolicCut)

// === POST-REQUEST CALCULATIONS ===
qADR_Pct = na(z_qADR_Pct_raw) ? na : math.round(z_qADR_Pct_raw * math.pow(10, qadrSigFigs)) / math.pow(10, qadrSigFigs)

qADR_Val = (z_qADR_Pct_raw / 100.0) * d_close
moveFromOpen = d_close - d_open
delta = qADR_Val != 0 ? (moveFromOpen / qADR_Val) * 100 : 0.0 
isUp = moveFromOpen >= 0
sign = isUp ? "+" : "−"

z_term = na(zscoreValue) ? "N/A" : 
         zscoreValue <= -3 ? "OVERSOLD" :
         zscoreValue < -1  ? "HOSTILE" :
         zscoreValue < 0   ? "WEAK" :
         zscoreValue < 1   ? "NEUTRAL" :
         zscoreValue < 3   ? "STRONG" : "OVERBOUGHT"

z_display = na(zscoreValue) ? "N/A" : str.tostring(zscoreValue, "#.##")

standardWidgetColor = (d_close >= z_maCutoff ? color.new(color.green, 80) : color.new(color.red, 80))

// === COLORS ===
color_rsi  = z_rsiValue >= rsiCutoff ? color.rgb(0,100,0) : color.rgb(100,0,0)
color_liq  = z_liquidityB >= liqCutoffB ? color.rgb(0,100,0) : color.rgb(100,0,0)

color_qadr = color.gray
if not na(qADR_Pct)
    if qADR_Pct < qadrCutoff
        color_qadr := color.rgb(200,0,0)
    else if qADR_Pct >= qadrCutoff and qADR_Pct <= qadrTopCutoff
        color_qadr := color.rgb(0, 100, 0)
    else if qADR_Pct > qadrTopCutoff and qADR_Pct <= 20.0
        color_qadr := color.rgb(200,0,0)
    else if qADR_Pct > 20.0
        color_qadr := color.rgb(150,0,0)

color_wroc = na(weeklyROC50) ? color.gray : weeklyROC50 > 1 ? color.rgb(0,100,0) : weeklyROC50 < -1 ? color.rgb(100,0,0) : color.gray
color_wrsi = weeklyRSIValue >= rsiCutoff ? color.rgb(0,100,0) : color.rgb(100,0,0)

color_z = na(zscoreValue) ? color.gray :
          zscoreValue <= -3 ? color.rgb(0, 150, 0) :
          zscoreValue < -1  ? color.rgb(150, 0, 0) :
          zscoreValue < 0   ? color.rgb(200, 0, 0) :
          zscoreValue >= 3  ? color.rgb(100, 0, 0) :
          zscoreValue >= 1  ? color.rgb(0, 100, 0) :
          color.gray

// === TABLE ===
maxRows = 8 
var table rs_table = table.new(pos, columns=1, rows=maxRows, border_width=1, border_color=color.gray)

if barstate.islast
    int row = 0
    table.clear(rs_table, 0, 0, 0, maxRows - 1)
    
    if is_parabolic
        table.cell(rs_table, 0, row, "PARABOLIC", bgcolor=parabolicCol, text_color=color.black, text_size=size.large, text_halign=text.align_center)
        row += 1
    
    table.cell(rs_table, 0, row, "D-RSI: " + str.tostring(math.round(z_rsiValue)), bgcolor=standardWidgetColor, text_color=color_rsi)
    row += 1

    liqText = na(z_liquidityB) ? "N/A" : str.tostring(z_liquidityB, "#.##")
    table.cell(rs_table, 0, row, "D-Liq: " + liqText + " B", bgcolor=standardWidgetColor, text_color=color_liq)
    row += 1

    if show_qADR
        qadrText = na(qADR_Pct) ? "N/A" : str.tostring(qADR_Pct, "#.##") + "%"
        table.cell(rs_table, 0, row, "D-qADR%: " + qadrText, bgcolor=standardWidgetColor, text_color=color_qadr)
        row += 1

    if show_qADR_Pct
        deltaText = str.tostring(math.abs(math.round(delta)), '#') + "%"
        table.cell(rs_table, 0, row, "D-ΔqADR%: " + sign + deltaText, bgcolor=standardWidgetColor, text_color=isUp ? color.rgb(0,100,0) : color.rgb(100,0,0))
        row += 1

    if showWeeklyROC
        wrocText = na(weeklyROC50) ? "N/A" : str.tostring(weeklyROC50, "#") + "%"
        table.cell(rs_table, 0, row, "W-ROC(50): " + wrocText, bgcolor=standardWidgetColor, text_color=color_wroc)
        row += 1

    if showWeeklyRSI
        table.cell(rs_table, 0, row, "W-RSI: " + str.tostring(math.round(weeklyRSIValue)), bgcolor=standardWidgetColor, text_color=color_wrsi)
        row += 1

    if showZScore
        z_row_text = "Z': " + z_term + " (" + z_display + ")"
        table.cell(rs_table, 0, row, z_row_text, bgcolor=standardWidgetColor, text_color=color_z)


// === BAR COLORING & SIGNALS ===
color conviction_color = colorBarsByDelta and delta >= 100 ? color.rgb(0, 250, 0) : colorBarsByDelta and delta <= -100 ? color.rgb(150, 0, 0) : na
barcolor(conviction_color)

isDaily = timeframe.isdaily
plotshape(show_delta_signals and isDaily and delta >= 100, location=location.abovebar, size=size.tiny, style=shape.circle, color=color.rgb(0,255,0))
plotshape(show_delta_signals and isDaily and delta >= 50 and delta < 100, location=location.abovebar, size=size.tiny, style=shape.circle, color=color.green)
plotshape(show_delta_signals and isDaily and delta > 0 and delta < 50,    location=location.abovebar, size=size.tiny, style=shape.circle, color=color.new(color.green,50))
plotshape(show_delta_signals and isDaily and delta > -50 and delta <= 0,   location=location.abovebar, size=size.tiny, style=shape.circle, color=color.new(color.red,50))
plotshape(show_delta_signals and isDaily and delta > -100 and delta <= -50, location=location.abovebar, size=size.tiny, style=shape.circle, color=color.new(color.red,25))
plotshape(show_delta_signals and isDaily and delta <= -100, location=location.abovebar, size=size.tiny, style=shape.circle, color=color.rgb(255,0,0))

// === ALERTS ===
alertcondition(delta >= 100, title="D-ΔqADR >= +100%", message="Very Strong Bull conviction on Daily")
alertcondition(delta <= -100, title="D-ΔqADR <= -100%", message="Very Strong Regular Bear conviction on Daily")

became_parabolic = is_parabolic and not is_parabolic[1]
lost_parabolic   = not is_parabolic and is_parabolic[1]

alertcondition(became_parabolic,title="BECAME Parabolic",message="{{ticker}} has entered a Parabolic state.")
alertcondition(lost_parabolic,title="NO LONGER Parabolic",message="{{ticker}} is no longer in a Parabolic state.")
````
