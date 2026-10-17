# Sigma Bands with Prime Bands TP

- url: https://www.tradingview.com/script/eYXd1nle/
- type: indicator
- pine_id: PUB;91ef3214f64a4697b3e5bbd0b492c701
- version: 1.0

## Description

Sigma Bands with Prime Bands TP
📊 Indicator Description
This is a comprehensive trading indicator that combines Sigma Bands (Bollinger Bands style) with Prime Bands (ChartPrime methodology) to provide both entry signals and take profit signals.

🎯 Core Logic
📈 Entry Signals (Sigma Bands)
BUY Signal: When EMA crosses ABOVE the Mean Band (SMA)

SELL Signal: When EMA crosses BELOW the Mean Band (SMA)

🎯 Take Profit Signals (Prime Bands)
BUY TP: When EMA crosses BELOW the Prime Upper Band (from above to below)

SELL TP: When EMA crosses ABOVE the Prime Lower Band (from below to above)

⚙️ Input Parameters
Sigma Settings
Parameter	Description	Default
SMA Length	Length for the Mean Band calculation	50
EMA Length	Length for EMA calculation (entry signals)	20
EMA Source	Price source for EMA (Close, HL2, OHLC4, HLC3)	Close
Price Source	Price source for bands (Close, HL2, OHLC4, etc.)	Close
Prime Bands Settings
Parameter	Description	Default
Prime Length	Look-back length for Prime Bands	50
Standard Deviation	Band width multiplier (1-3)	3
Upper Band Color	Color for the upper band	#48d81c
Lower Band Color	Color for the lower band	#d8611c
Display Options
Parameter	Description
Show +1σ / -1σ	Toggle visibility of 1st standard deviation bands
Show +2σ / -2σ	Toggle visibility of 2nd standard deviation bands
Show +3σ / -3σ	Toggle visibility of 3rd standard deviation bands
Show Mean Band	Toggle Mean Band visibility
Show EMA Line	Toggle EMA line visibility
Show Prime Bands	Toggle Prime Bands visibility
Show Prime Signals	Toggle Prime crossover signals
Show Buy/Sell Signals	Toggle entry signals
Show Take Profit Signals	Toggle TP signals
Show Info Table	Toggle information table
Table Position	Table location (Top Right, Top Left, Bottom Right, Bottom Left)
📊 Visual Elements
Sigma Bands
Mean Band: Gray line (SMA)

±1σ: Semi-transparent green/red lines

±2σ: Less transparent green/red lines

±3σ: Solid green/pink lines

Prime Bands
Upper Band: Green line (user-selectable color)

Middle Band: Semi-transparent gray line

Lower Band: Red line (user-selectable color)

Signals
Signal	Label	Color	Location
BUY	BUY	Green	Below bar
SELL	SELL	Red	Above bar
BUY TP	TP▲	Lime	Above bar
SELL TP	TP▼	Pink	Below bar
EMA ↑ Lower	↑L	Red	Below bar
EMA ↓ Upper	↓U	Green	Above bar
🔔 Alerts
Entry Alerts
🔵 BUY: EMA crosses ABOVE Mean Band

🔴 SELL: EMA crosses BELOW Mean Band

Prime Bands Alerts
🟢 EMA Crosses Above Lower Band

🔴 EMA Crosses Below Upper Band

Take Profit Alerts
✅ BUY TP: EMA crosses BELOW Upper Prime Band

✅ SELL TP: EMA crosses ABOVE Lower Prime Band

📋 Information Table
The indicator displays a comprehensive table showing:

All band values (Prime Upper/Lower, Sigma 1-3σ, Mean)

EMA value

Current price

Position status (BUY/SELL/NONE)

TP Status (WAITING/TP ✓)

🎯 Trading Strategy Logic
Bullish Scenario
text
1. EMA crosses ABOVE Mean Band
   ↓
2. BUY Signal generated
   ↓
3. Position opened
   ↓
4. EMA rises to Upper Prime Band
   ↓
5. EMA crosses BELOW Upper Prime Band
   ↓
6. BUY TP triggered (Take Profit)
Bearish Scenario
text
1. EMA crosses BELOW Mean Band
   ↓
2. SELL Signal generated
   ↓
3. Position opened
   ↓
4. EMA falls to Lower Prime Band
   ↓
5. EMA crosses ABOVE Lower Prime Band
   ↓
6. SELL TP triggered (Take Profit)
🛠️ How to Use
Add the indicator to your chart in TradingView

Adjust parameters based on your trading style:

For shorter timeframes: Reduce SMA/EMA length

For longer timeframes: Increase SMA/EMA length

Adjust Prime Band deviation for sensitivity

Monitor signals on the chart

Set alerts for automatic notifications

Use the info table to track current values

⚠️ Important Notes
The indicator does not repaint - signals are reliable

Works on all timeframes - optimize parameters for each

Best used with trend confirmation - combine with other indicators

Always use proper risk management - set stop losses accordingly

📈 Recommended Settings by Timeframe
Timeframe	SMA Length	EMA Length	Prime Length
1m-5m	20	10	20
15m-1h	50	20	50
4h-Daily	100	50	100
Weekly+	200	100	200
🎨 Color Legend
Color	Meaning
🟢 Green	Bullish / Upper bands
🔴 Red	Bearish / Lower bands
🟠 Orange	EMA line
⚪ Gray	Mean band / Middle bands
🟡 Yellow	Highlighted values
🟣 Pink	3σ lower band
🟢 Lime	Take Profit signals
Developed by: AlgoAlpha & ChartPrime Integration
Version: 1.0
Platform: TradingView Pine Script v6

This indicator is for educational and informational purposes only. Always conduct your own research before making trading decisions.

## Source Code

````pine
//@version=6
indicator('Sigma Bands with Prime Bands TP', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════
// INPUT PARAMETERS - Sigma Bands
// ═══════════════════════════════════════════════════════════════
smaLength = input.int(50, title = 'SMA Length', minval = 2, group = 'Sigma Settings')
emaLength = input.int(20, title = 'EMA Length', minval = 1, group = 'Sigma Settings')
emaSource = input.string('Close', title = 'EMA Source', options = ['Close', 'HL2', 'OHLC4', 'HLC3'], group = 'Sigma Settings')
priceSource = input.string('Close', title = 'Price Source', options = ['Close', 'HLCC / 4', 'HLC / 3', 'OHLC / 4', 'HL2', 'HLC3', 'OHLC4'], group = 'Sigma Settings')

// ═══════════════════════════════════════════════════════════════
// INPUT PARAMETERS - Prime Bands (ChartPrime)
// ═══════════════════════════════════════════════════════════════
lengthPB = input.int(50, title = 'Prime Length', group = 'Prime Bands Settings')
sdPB = input.int(3, title = 'Standart Deviation', minval = 1, maxval = 3, group = 'Prime Bands Settings')

// Prime Bands Renkleri
color_plus = input.color(#48d81c, "Upper Band Color", group = 'Prime Bands Appearance')
color_minus = input.color(#d8611c, "Lower Band Color", group = 'Prime Bands Appearance')

// ═══════════════════════════════════════════════════════════════
// GÖSTERGELER
// ═══════════════════════════════════════════════════════════════
showS1 = input.bool(false, title = 'Show +1σ / -1σ', group = 'Display')
showS2 = input.bool(false, title = 'Show +2σ / -2σ', group = 'Display')
showS3 = input.bool(false, title = 'Show +3σ / -3σ', group = 'Display')
showMean = input.bool(true, title = 'Show Mean Band', group = 'Display')
showEMA = input.bool(true, title = 'Show EMA Line', group = 'Display')
showPrimeBands = input.bool(true, title = 'Show Prime Bands', group = 'Display')
showPrimeSignals = input.bool(true, title = 'Show Prime Signals', group = 'Display')

showSignals = input.bool(true, title = 'Show Buy/Sell Signals', group = 'Signals')
showTP = input.bool(true, title = 'Show Take Profit Signals', group = 'Signals')

showTable = input.bool(true, title = 'Show Info Table', group = 'Style')
tablePos = input.string('Top Right', title = 'Table Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group = 'Style')

// ═══════════════════════════════════════════════════════════════
// PRICE SOURCE
// ═══════════════════════════════════════════════════════════════
price = switch priceSource
    'Close' => close
    'HLCC / 4' => (high + low + close + close) / 4
    'HLC / 3' => (high + low + close) / 3
    'OHLC / 4' => (open + high + low + close) / 4
    'HL2' => (high + low) / 2
    'HLC3' => (high + low + close) / 3
    'OHLC4' => (open + high + low + close) / 4

// ═══════════════════════════════════════════════════════════════
// EMA Hesaplama
// ═══════════════════════════════════════════════════════════════
emaPrice = switch emaSource
    'Close' => close
    'HL2' => (high + low) / 2
    'OHLC4' => (open + high + low + close) / 4
    'HLC3' => (high + low + close) / 3

emaLine = ta.ema(emaPrice, emaLength)

// ═══════════════════════════════════════════════════════════════
// SIGMA BANDS
// ═══════════════════════════════════════════════════════════════
meanLine = ta.sma(price, smaLength)
stdDev = ta.stdev(price, smaLength)

sigma1Upper = meanLine + stdDev
sigma1Lower = meanLine - stdDev
sigma2Upper = meanLine + 2 * stdDev
sigma2Lower = meanLine - 2 * stdDev
sigma3Upper = meanLine + 3 * stdDev
sigma3Lower = meanLine - 3 * stdDev

// ═══════════════════════════════════════════════════════════════
// PRIME BANDS (ChartPrime)
// ═══════════════════════════════════════════════════════════════
method check_size(array<float> array, val, size)=>
    array.push(array, val)
    if array.size(array) >= size
        array.shift(array)

prime_bands(length)=>
    var upper = array.new<float>()
    var lower = array.new<float>()
    var color = color(na)

    float Hg    = ta.highest(length)
    float Lw    = ta.lowest(length)
    float base  = math.avg(Hg, Lw)
    float atr   = ta.atr(200)
    float up_b  = base + atr * sdPB
    float low_b = base - atr * sdPB

    upper.check_size(up_b, length)
    lower.check_size(low_b, length)

    float up_band  = ta.sma(upper.max(), 15)
    float low_band = ta.sma(lower.min(), 15)
    float mid_band = math.avg(up_band, low_band)

    [up_band, mid_band, low_band]

[up_band, mid_band, low_band] = prime_bands(lengthPB)

// ═══════════════════════════════════════════════════════════════
// PRIME BANDS EMA KESİŞİM SİNYALLERİ (TP İÇİN) - DÜZELTİLDİ
// ═══════════════════════════════════════════════════════════════
// 🔥 BUY TP: EMA, Prime Üst bandını AŞAĞI keser (yukarıdan aşağıya)
emaCrossBelowUpper = ta.crossunder(emaLine, up_band)
// 🔥 SELL TP: EMA, Prime Alt bandını YUKARI keser (aşağıdan yukarıya)
emaCrossAboveLower = ta.crossover(emaLine, low_band)

// ═══════════════════════════════════════════════════════════════
// ANA SİNYALLER - EMA orta bandı kesince
// ═══════════════════════════════════════════════════════════════
buySignal = ta.crossover(emaLine, meanLine)
sellSignal = ta.crossunder(emaLine, meanLine)

// ═══════════════════════════════════════════════════════════════
// POZİSYON YÖNETİMİ
// ═══════════════════════════════════════════════════════════════
var bool inBuyPosition = false
var bool inSellPosition = false
var bool buyTPSent = false
var bool sellTPSent = false

// BUY Sinyali
if buySignal
    inBuyPosition := true
    inSellPosition := false
    buyTPSent := false
    sellTPSent := false

// SELL Sinyali
if sellSignal
    inSellPosition := true
    inBuyPosition := false
    sellTPSent := false
    buyTPSent := false

// ═══════════════════════════════════════════════════════════════
// TP KONTROLÜ - DÜZELTİLDİ
// ═══════════════════════════════════════════════════════════════
// 🔥 BUY TP: EMA, Prime Üst bandını AŞAĞI keser (yukarıdan aşağıya)
if inBuyPosition and not buyTPSent
    if emaCrossBelowUpper
        buyTPSent := true
        inBuyPosition := false

// 🔥 SELL TP: EMA, Prime Alt bandını YUKARI keser (aşağıdan yukarıya)
if inSellPosition and not sellTPSent
    if emaCrossAboveLower
        sellTPSent := true
        inSellPosition := false

// TP Sinyalleri
buyTPSignal = buyTPSent and not buyTPSent[1]
sellTPSignal = sellTPSent and not sellTPSent[1]

// ═══════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════
// Sigma Bands
plot(showMean ? meanLine : na, color = color.new(color.gray, 0), title = 'Mean Band', linewidth = 2)
plot(showEMA ? emaLine : na, color = color.new(color.orange, 0), title = 'EMA', linewidth = 2)

plot(showS1 ? sigma1Upper : na, color = color.new(color.green, 30), title = '+1σ', linewidth = 1)
plot(showS1 ? sigma1Lower : na, color = color.new(color.red, 30), title = '-1σ', linewidth = 1)

plot(showS2 ? sigma2Upper : na, color = color.new(color.green, 10), title = '+2σ', linewidth = 1)
plot(showS2 ? sigma2Lower : na, color = color.new(#DC143C, 10), title = '-2σ', linewidth = 1)

plot(showS3 ? sigma3Upper : na, color = color.new(color.lime, 0), title = '+3σ', linewidth = 2)
plot(showS3 ? sigma3Lower : na, color = color.new(#FF1493, 0), title = '-3σ', linewidth = 2)

// Prime Bands
plot(showPrimeBands ? up_band : na, color = color.new(color_plus, 0), title = 'Prime Upper', linewidth = 2)
plot(showPrimeBands ? mid_band : na, color = color.new(color.gray, 70), title = 'Prime Middle', linewidth = 1)
plot(showPrimeBands ? low_band : na, color = color.new(color_minus, 0), title = 'Prime Lower', linewidth = 2)

// Prime Bands EMA Kesişim Sinyalleri
plotshape(showPrimeSignals and emaCrossAboveLower, title="EMA Cross Above Lower", location=location.belowbar,
    color=color.new(color_minus, 0), style=shape.labelup, text="↑L", textcolor=color.white, size=size.small)

plotshape(showPrimeSignals and emaCrossBelowUpper, title="EMA Cross Below Upper", location=location.abovebar,
    color=color.new(color_plus, 0), style=shape.labeldown, text="↓U", textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// SİNYAL GÖSTERGELERİ
// ═══════════════════════════════════════════════════════════════
// EMA - Mean kesişim sinyalleri
plotshape(showSignals and buySignal, title='Buy Signal', location=location.belowbar,
    color=color.new(color.green, 0), style=shape.labelup, text='BUY', textcolor=color.white, size=size.small)

plotshape(showSignals and sellSignal, title='Sell Signal', location=location.abovebar,
    color=color.new(color.red, 0), style=shape.labeldown, text='SELL', textcolor=color.white, size=size.small)

// Take Profit sinyalleri
plotshape(showTP and buyTPSignal, title='Buy TP Signal', location=location.abovebar,
    color=color.new(color.lime, 0), style=shape.labelup, text='TP▲', textcolor=color.white, size=size.small)

plotshape(showTP and sellTPSignal, title='Sell TP Signal', location=location.belowbar,
    color=color.new(#FF1493, 0), style=shape.labeldown, text='TP▼', textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════
// BİLGİ TABLOSU
// ═══════════════════════════════════════════════════════════════
tablePosition = switch tablePos
    'Top Right' => position.top_right
    'Top Left' => position.top_left
    'Bottom Right' => position.bottom_right
    'Bottom Left' => position.bottom_left

var table infoTable = table.new(tablePosition, 2, 15, bgcolor = color.new(color.black, 10), frame_color = color.new(color.gray, 50), frame_width = 1)

if showTable
    table.cell(infoTable, 0, 0, 'Band', text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 0, 'Value', text_color = color.white, text_size = size.small)

    // Prime Upper
    table.cell(infoTable, 0, 1, 'Prime ↑', text_color = color_plus, text_size = size.small)
    table.cell(infoTable, 1, 1, str.tostring(up_band, format.mintick), text_color = color_plus, text_size = size.small)
    
    table.cell(infoTable, 0, 2, '+3σ', text_color = color.lime, text_size = size.small)
    table.cell(infoTable, 1, 2, str.tostring(sigma3Upper, format.mintick), text_color = color.lime, text_size = size.small)

    table.cell(infoTable, 0, 3, '+2σ', text_color = color.green, text_size = size.small)
    table.cell(infoTable, 1, 3, str.tostring(sigma2Upper, format.mintick), text_color = color.green, text_size = size.small)

    table.cell(infoTable, 0, 4, '+1σ', text_color = color.teal, text_size = size.small)
    table.cell(infoTable, 1, 4, str.tostring(sigma1Upper, format.mintick), text_color = color.teal, text_size = size.small)

    table.cell(infoTable, 0, 5, 'Mean', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 5, str.tostring(meanLine, format.mintick), text_color = color.gray, text_size = size.small)
    
    table.cell(infoTable, 0, 6, 'Prime Mid', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 6, str.tostring(mid_band, format.mintick), text_color = color.gray, text_size = size.small)

    table.cell(infoTable, 0, 7, '-1σ', text_color = color.red, text_size = size.small)
    table.cell(infoTable, 1, 7, str.tostring(sigma1Lower, format.mintick), text_color = color.red, text_size = size.small)

    table.cell(infoTable, 0, 8, '-2σ', text_color = color.new(#DC143C, 0), text_size = size.small)
    table.cell(infoTable, 1, 8, str.tostring(sigma2Lower, format.mintick), text_color = color.new(#DC143C, 0), text_size = size.small)

    table.cell(infoTable, 0, 9, '-3σ', text_color = color.new(#FF1493, 0), text_size = size.small)
    table.cell(infoTable, 1, 9, str.tostring(sigma3Lower, format.mintick), text_color = color.new(#FF1493, 0), text_size = size.small)
    
    table.cell(infoTable, 0, 10, 'Prime ↓', text_color = color_minus, text_size = size.small)
    table.cell(infoTable, 1, 10, str.tostring(low_band, format.mintick), text_color = color_minus, text_size = size.small)
    
    table.cell(infoTable, 0, 11, 'EMA', text_color = color.orange, text_size = size.small)
    table.cell(infoTable, 1, 11, str.tostring(emaLine, format.mintick), text_color = color.orange, text_size = size.small)
    
    table.cell(infoTable, 0, 12, 'Price', text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 12, str.tostring(close, format.mintick), text_color = color.white, text_size = size.small)
    
    // Pozisyon durumu
    posStatus = inBuyPosition ? "BUY" : inSellPosition ? "SELL" : "NONE"
    posColor = inBuyPosition ? color.green : inSellPosition ? color.red : color.gray
    table.cell(infoTable, 0, 13, 'Position', text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 13, posStatus, text_color = posColor, text_size = size.small)
    
    // TP Durumu
    tpStatus = buyTPSent ? "BUY TP ✓" : sellTPSent ? "SELL TP ✓" : "WAITING"
    tpColor = buyTPSent ? color.lime : sellTPSent ? color.fuchsia : color.gray
    table.cell(infoTable, 0, 14, 'TP Status', text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 14, tpStatus, text_color = tpColor, text_size = size.small)

// ═══════════════════════════════════════════════════════════════
// ALARMLAR
// ═══════════════════════════════════════════════════════════════
// Ana Sinyaller
alertcondition(buySignal, title='🔵 BUY - EMA Crosses Above Mean', message='🔵 BUY: EMA crossed ABOVE Mean Band!')
alertcondition(sellSignal, title='🔴 SELL - EMA Crosses Below Mean', message='🔴 SELL: EMA crossed BELOW Mean Band!')

// Prime Bands EMA Kesişimleri
alertcondition(emaCrossAboveLower, title='🟢 EMA Crosses Above Lower Band', message='🟢 EMA crossed ABOVE Lower Prime Band!')
alertcondition(emaCrossBelowUpper, title='🔴 EMA Crosses Below Upper Band', message='🔴 EMA crossed BELOW Upper Prime Band!')

// TP Sinyalleri
alertcondition(buyTPSignal, title='✅ BUY TP - EMA Crossed Below Upper Band', message='✅ BUY TP: EMA crossed BELOW Upper Prime Band!')
alertcondition(sellTPSignal, title='✅ SELL TP - EMA Crossed Above Lower Band', message='✅ SELL TP: EMA crossed ABOVE Lower Prime Band!')
````
