# Stanley Druckenmiller Macro ROC Matrix

- url: https://www.tradingview.com/script/6EzCKd7p-Stanley-Druckenmiller-Macro-ROC-Matrix/
- type: indicator
- pine_id: PUB;592118232e4449e2b24451ac6295f8a6
- version: 2.0

## Description

Stanley Druckenmiller famously says that the d2ROC indicator helps him get into trends early on, this is an attempt to recreate the same indicator.

## Source Code

````pine
//@version=6
indicator("Druckenmiller Macro ROC Matrix v6", overlay=false, max_labels_count=500)

//=========================
// 1. Inputs
//=========================
src        = input.source(close, "Source")
smoothLen  = input.int(3,  "Smoothing Window (0 = Off)", minval=0) 
useEMA     = input.bool(true, "Use EMA Smoothing Framework")

//=========================
// 2. Chart Calculations (Local TF)
//=========================
cRocRaw  = 100.0 * (src / nz(src[1]) - 1.0)
cRocCurr = smoothLen > 0 ? (useEMA ? ta.ema(cRocRaw, smoothLen) : ta.sma(cRocRaw, smoothLen)) : cRocRaw
cRocLast = nz(cRocCurr[1])
cD1Curr  = cRocCurr - cRocLast
cD1Last  = nz(cD1Curr[1])
cD2Curr  = cD1Curr - cD1Last

plot(cRocCurr, "ROC Trend Line", color=color.blue, linewidth=1)
plot(cD1Curr,  "dROC Velocity",   color=color.purple, linewidth=2)
plot(cD2Curr,  "d2ROC Accel",     color=color.teal, linewidth=3)
hline(0, "Zero Baseline", color=color.gray, linestyle=hline.style_dotted)

//=========================
// 3. Screener/Monthly Calculations
//=========================
// Using a simple tuple call to security for maximum compatibility
mRocRaw  = 100.0 * (src / nz(src[1]) - 1.0)
mRocCurr = smoothLen > 0 ? (useEMA ? ta.ema(mRocRaw, smoothLen) : ta.sma(mRocRaw, smoothLen)) : mRocRaw

// Request Monthly Values
mRocC = request.security(syminfo.tickerid, "1M", mRocCurr, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mRocL = request.security(syminfo.tickerid, "1M", mRocCurr[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Calculate Derivatives based on Monthly Data
mD1C = mRocC - mRocL
mD1L = request.security(syminfo.tickerid, "1M", (mRocCurr - mRocCurr[1])[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mD2C = mD1C - mD1L
mD2L = request.security(syminfo.tickerid, "1M", (mRocCurr - 2*mRocCurr[1] + mRocCurr[2])[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Screener Hooks
plot(mRocC, "Screener_ROC",   display=display.none)
plot(mD1C,  "Screener_dROC",  display=display.none)
plot(mD2C,  "Screener_d2ROC", display=display.none)

//=========================
// 4. Dashboard Table
//=========================
var table t = table.new(position.top_right, 3, 5, frame_color=color.gray, frame_width=1, border_color=color.gray, border_width=1)

// Coloring Function (Inline for safety)
f_col(val) => val >= 0 ? color.green : color.red

if barstate.islast
    // Headers
    table.cell(t, 0, 0, "Macro Metric", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, "Last Month",  bgcolor=color.black, text_color=color.white)
    table.cell(t, 2, 0, "Current Month", bgcolor=color.black, text_color=color.white)

    // Data Rows
    table.cell(t, 0, 1, "ROC (%)",     bgcolor=color.new(color.gray, 90))
    table.cell(t, 1, 1, str.tostring(mRocL, "#.##"), text_color=f_col(mRocL))
    table.cell(t, 2, 1, str.tostring(mRocC, "#.##"), text_color=f_col(mRocC))
    
    table.cell(t, 0, 2, "dROC (Vel)",  bgcolor=color.new(color.gray, 90))
    table.cell(t, 1, 2, str.tostring(mD1L, "#.##"), text_color=f_col(mD1L))
    table.cell(t, 2, 2, str.tostring(mD1C, "#.##"), text_color=f_col(mD1C))
    
    table.cell(t, 0, 3, "d2ROC (Acc)", bgcolor=color.new(color.gray, 90))
    table.cell(t, 1, 3, str.tostring(mD2L, "#.##"), text_color=f_col(mD2L))
    table.cell(t, 2, 3, str.tostring(mD2C, "#.##"), text_color=f_col(mD2C))

    // Regime Logic
    regimeTxt = (mD1C > 0 and mD2C > 0) ? "Aggressive Expansion" : 
                 (mD1C > 0 and mD2C <= 0) ? "Expansion Exhaustion" : 
                 (mD1C <= 0 and mD2C <= 0) ? "Aggressive Contraction" : "Structural Accumulation"
    
    table.cell(t, 0, 4, "Regime Bias", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 4, "—", text_color=color.white, bgcolor=color.black)
    table.cell(t, 2, 4, regimeTxt, text_color=color.white, bgcolor=color.black)
````
