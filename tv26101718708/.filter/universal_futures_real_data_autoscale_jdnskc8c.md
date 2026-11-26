# Universal Futures Real Data Auto-Scale

- url: https://www.tradingview.com/script/jdNskc8c/
- type: indicator
- pine_id: PUB;9328f47e92ef4abcb83ad81d64fa343d
- version: 7.0

## Description

This indicator displays the volume of each candle clearly and directly. It is a simple tool for analyzing market flow and buying/selling pressure without complications.

## Source Code

````pine
// © RaydelCL - FUTURES DATA: PRO AUTO-SCALE + GLOBAL ENGLISH
//@version=6
indicator('FUTURES DATA: AUTO-SCALE + INSTITUTIONAL', overlay = false, max_labels_count = 500)

//---------------- Parameters ----------------
lookbackPeriod = input.int(14, title="MA Lookback Period", minval=1, group="Core Configuration", tooltip="Period used for the Volume Moving Average and Standard Deviation calculations.")
sensitivity    = input.float(2.0, title="Institutional Sensitivity", minval=0.1, step=0.1, group="Core Configuration", tooltip="Standard Deviation multiplier. 2.0 captures 95.4% of data; lower values increase frequency of highlights.")

// Nuevas opciones de visualización
showContracts = input.bool(true, title="Show Contracts (C)", group="Display Settings")
showDelta     = input.bool(true, title="Show Delta (Δ)", group="Display Settings")
showCash      = input.bool(true, title="Show Cash Value ($)", group="Display Settings")

//---------------- Statistical Engine ----------------
volMean = ta.sma(volume, lookbackPeriod)
volStd  = ta.stdev(volume, lookbackPeriod)

// Institutional Anomaly Detection
isInstitutional = volume > (volMean + (volStd * sensitivity))

//---------------- Futures & Capital Calculations ----------------
contractValue = syminfo.pointvalue
volContracts  = volume
volCash       = volume * close * contractValue

// ---------------- Intrabar Precision Delta ----------------
float candleRange = high - low
float deltaDirection = (candleRange == 0) ? 0 : ((close - low) - (high - close)) / candleRange
float delta = volume * deltaDirection

//---------------- Dynamic Number Formatting ----------------
f_formatVol(_v) =>
    float _absV = math.abs(_v)
    string _res = _absV >= 1000000000000 ? str.tostring(_absV / 1000000000000, '#.##') + 'T' : 
                  _absV >= 1000000000   ? str.tostring(_absV / 1000000000, '#.##') + 'B' : 
                  _absV >= 1000000      ? str.tostring(_absV / 1000000, '#.##') + 'M' : 
                  _absV >= 1000         ? str.tostring(_absV / 1000, '#.##') + 'K' : 
                  str.tostring(_absV, '#.##')
    _v < 0 ? "-" + _res : _res

// Label Text Construction (Conditional logic based on inputs)
volText = (showContracts ? 'C\n' + str.tostring(volContracts) : '') + 
          (showDelta     ? (showContracts ? '\n\n' : '') + 'Δ\n' + f_formatVol(delta) : '') + 
          (showCash      ? (showContracts or showDelta ? '\n\n' : '') + '$\n' + f_formatVol(volCash) : '')

//---------------- Aesthetic Styling ----------------
colorBarra = isInstitutional ? color.new(#2e7d32, 20) : color.new(#2962ff, 0)
colorTexto = isInstitutional ? color.new(#a5d6a7, 0)  : color.white

//---------------- Data Visualization ----------------
plot(volContracts, title = 'Volume Contracts', style = plot.style_columns, color = colorBarra)

plot(volMean, 
     title      = "Volume Average (MA)", 
     color      = color.new(#ffeb3b, 0), 
     linewidth  = 2, 
     trackprice = true) 

// Only draw the label if at least one option is enabled
if (showContracts or showDelta or showCash) and (barstate.isconfirmed or barstate.isrealtime)
    label.new(
         x         = bar_index, 
         y         = volContracts / 2, 
         text      = volText, 
         color     = color.new(color.black, 100), 
         textcolor = colorTexto, 
         style     = label.style_none, 
         size      = size.small, 
         yloc      = yloc.price
     )
````
