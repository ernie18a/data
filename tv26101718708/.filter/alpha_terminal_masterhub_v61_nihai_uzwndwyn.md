# Alpha Terminal - MasterHub V6.1 (Nihai)

- url: https://www.tradingview.com/script/uzwndwYN/
- type: indicator
- pine_id: PUB;3dd12498da9f4a88a8c8a0dbef4140a0
- version: 1.0

## Description

komplike bir indikatör , hissenin bos , fvg ve choch durumlarını gösteren hissedeki hacmi mum barlarını renklendirerek belirten ve hissenin özetini bir tabloda çıkaran indikatördür. Aynı zamanda ayarlar kısmında Ema 20-50-100-144, Tison, Tenkan sen ve Kijun Sen , Bolinger bantları filtrelenebilir şeklinde kullanıma açılıyor.

This is a complex indicator that shows the BOS, FVG, and CHCH status of a stock, indicates the volume by coloring the candlesticks, and provides a summary of the stock in a table. It also allows filtering based on EMA 20-50-100-144, Tison, Tenkan Sen, Kijun Sen, and Bollinger Bands in the settings.

## Source Code

````pine
//@version=6
indicator("Alpha Terminal - MasterHub V6.1 (Nihai)", overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ==========================================
// PIN SCRIPT INPUTS (Girdiler & Filtreler)
// ==========================================
var string G_SMC   = "SMC / Price Action Ayarları"
var string G_VOL   = "Volume Delta (Hacim Dağılım) Ayarları"
var string G_FISH  = "Fisher Transform Ayarları"
var string G_FIB   = "Auto Fib Retracement Ayarları"
var string G_MA    = "Hareketli Ortalamalar (EMA & Tillson)"
var string G_ICHI  = "Ichimoku Elementleri"
var string G_BB    = "Bollinger Bands"
var string G_TAB   = "Alpha Terminal Panel Ayarları"

// SMC Girişleri
leftBars    = input.int(3, "Sol Bar Sayısı (Pivot)", minval=1, group=G_SMC)
rightBars   = input.int(3, "Sağ Bar Sayısı (Pivot)", minval=1, group=G_SMC)
lineLength  = input.int(20, "Kırılım Çizgi Uzunluğu (Bar)", minval=1, group=G_SMC)
showFVG     = input.bool(true, "Fair Value Gap (FVG) Göster", group=G_SMC)
fvgColorBg  = input.color(color.new(#00a01a, 92), "FVG Kutu Rengi", group=G_SMC)

// Volume Delta Girişleri
useVolCandles = input.bool(true, "Mum Renklerini Hacim Deltasına Göster", group=G_VOL)
bullVolColor  = input.color(#00ffaa, "Aşırı Alıcılı Mum Rengi", group=G_VOL)
bearVolColor  = input.color(#ff0055, "Aşırı Satıcılı Mum Rengi", group=G_VOL)

// Fisher Transform Girişleri
fishLength  = input.int(10, "Fisher Uzunluğu", minval=1, group=G_FISH)

// Auto Fib Filtre Girişleri - Varsayılan Kapalı
showFib       = input.bool(false, "Fib Seviyelerini Göster", group=G_FIB)
threshold_mult= input.float(3.0, "Fib Sapma (Deviation)", minval=0, group=G_FIB)
fibDepth      = input.int(10, "Fib Hesaplama Derinliği (Depth)", minval=2, group=G_FIB)
extendRight   = input.bool(true, "Fib Çizgilerini Sağa Uzat", group=G_FIB)

// Filtre Aktivasyonları - Başlangıçta Hepsi Kapalı
useEma20   = input.bool(false, "EMA 20 Aktif", group=G_MA)
useEma50   = input.bool(false, "EMA 50 Aktif", group=G_MA)
useEma100  = input.bool(false, "EMA 100 Aktif", group=G_MA)
useEma144  = input.bool(false, "EMA 144 Aktif", group=G_MA)
useTillson = input.bool(false, "Tillson T3 Aktif", group=G_MA)
useTenkan  = input.bool(false, "Tenkan-sen Aktif", group=G_ICHI)
useKijun   = input.bool(false, "Kijun-sen Aktif", group=G_ICHI)
useBbLower = input.bool(false, "BB Alt Bant Aktif", group=G_BB)
useBbBasis = input.bool(false, "BB Orta Bant Aktif", group=G_BB)
useAvwap   = input.bool(false, "Anchored VWAP Aktif", group=G_BB)

// Metrik Uzunlukları
t3Length   = input.int(14, "Tillson T3 Uzunluğu", group=G_MA)
t3Volume   = input.float(0.7, "Tillson Hacim Faktörü (a)", group=G_MA)
bbLength   = input.int(20, "Bollinger Uzunluğu", group=G_BB)
bbMult     = input.float(2.0, "Bollinger Standart Sapma", group=G_BB)
tablePos   = input.string("Top Right", "Panel Konumu", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=G_TAB)

import TradingView/ZigZag/7 as zigzag

// ==========================================
// GLOBAL FONKSİYONLAR
// ==========================================
f_t3(_src, _len, _vFact) =>
    e1 = ta.ema(_src, _len)
    e2 = ta.ema(e1, _len)
    e3 = ta.ema(e2, _len)
    e4 = ta.ema(e3, _len)
    e5 = ta.ema(e4, _len)
    e6 = ta.ema(e5, _len)
    c1 = -_vFact * _vFact * _vFact
    c2 = 3 * _vFact * _vFact + 3 * _vFact * _vFact * _vFact
    c3 = -6 * _vFact * _vFact - 3 * _vFact - 3 * _vFact * _vFact * _vFact
    c4 = 1 + 3 * _vFact + 3 * _vFact * _vFact + _vFact * _vFact * _vFact
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

f_ichi(_len) => math.avg(ta.highest(high, _len), ta.lowest(low, _len))

f_set_cell(_table, _r, _title, _val, _vColor, _cellBg) =>
    table.cell(_table, 0, _r, _title, bgcolor=_cellBg, text_color=color.gray, text_size=size.small, text_halign="left", text_valign="center")
    table.cell(_table, 1, _r, _val, bgcolor=_cellBg, text_color=_vColor, text_size=size.small, text_halign="center", text_valign="center")

_crossing_level(series float sr, series float r) =>
    (r > sr and r < sr[1]) or (r < sr and r > sr[1])

// ==========================================
// 1. MATEMATİKSEL İNDİKATÖR HESAPLAMALARI
// ==========================================
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema144 = ta.ema(close, 144)

tillsonVal = f_t3(close, t3Length, t3Volume)
tenkanSen  = f_ichi(9)
kijunSen   = f_ichi(26)

[bbBasis, bbUpper, bbLower] = ta.bb(close, bbLength, bbMult)
kc_basis = ta.ema(close, 20)
kc_atr = ta.atr(20)
kcUpper = kc_basis + kc_atr * 1.5
kcLower = kc_basis - kc_atr * 1.5

isNewWeek = ta.change(time("W")) != 0
avwapVal = ta.vwap(close, isNewWeek)

// VOLUME DELTA HESAPLAMALARI
candleRange = high - low
buyVolumeWeight  = candleRange == 0 ? 0.5 : (close - low) / candleRange
sellVolumeWeight = 1.0 - buyVolumeWeight

// FISHER TRANSFORM HESAPLAMALARI
high_ = ta.highest(high, fishLength)
low_  = ta.lowest(low, fishLength)
value = 0.0
value := na(high_ - low_) or (high_ - low_ == 0) ? 0.0 : 0.33 * 2 * ((close - low_) / (high_ - low_) - 0.5) + 0.67 * nz(value[1])
value := value > 0.99 ? 0.999 : value < -0.99 ? -0.999 : value
fish = 0.0
fish := 0.5 * math.log((1 + value) / (1 - value)) + 0.5 * nz(fish[1])
trigger = fish[1]
fishSignal = fish > trigger ? "BULLISH" : "BEARISH"

// Mumları Dinamik Boyama
color candleColor = close >= open ? color.green : color.red
if useVolCandles
    candleColor := buyVolumeWeight > 0.65 ? bullVolColor : buyVolumeWeight < 0.35 ? bearVolColor : (close >= open ? color.rgb(4, 54, 83) : color.maroon)

barcolor(candleColor)

// ==========================================
// METRİK ÇİZGİLERİNİN GRAFİĞE BASILMASI (Seçime Bağlı)
// ==========================================
plot(useEma20 ? ema20 : na, "EMA 20", color=color.blue, linewidth=2)
plot(useEma50 ? ema50 : na, "EMA 50", color=color.orange, linewidth=2)
plot(useEma100 ? ema100 : na, "EMA 100", color=color.purple, linewidth=2)
plot(useEma144 ? ema144 : na, "EMA 144", color=color.maroon, linewidth=2)
plot(useTillson ? tillsonVal : na, "Tillson T3", color=color.blue, linewidth=2)
plot(useTenkan ? tenkanSen : na, "Tenkan-sen", color=color.red, linewidth=2)
plot(useKijun ? kijunSen : na, "Kijun-sen", color=color.teal,linewidth=2)
plot(useBbBasis ? bbBasis : na, "BB Orta Bant", color=color.gray, style=plot.style_line)
plot(useBbLower ? bbLower : na, "BB Alt Bant", color=color.red, style=plot.style_line)
plot(useAvwap ? avwapVal : na, "Anchored VWAP (W)", color=color.yellow, linewidth=2)

/// ==========================================
// 2. ÇİZGİ DESTEKLİ GELİŞTİRİLMİŞ SMC MANTIĞI
// ==========================================
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float top_target = na
var float bot_target = na
var int market_trend = 1 

if not na(ph)
    top_target := ph
if not na(pl)
    bot_target := pl

f_draw_smc_line(_y, _text, _color) =>
    line.new(x1=bar_index, y1=_y, x2=bar_index + lineLength, y2=_y, xloc=xloc.bar_index, color=_color, width=1, style=line.style_dashed)

if not na(top_target) and ta.crossover(close, top_target)
    if market_trend == -1
        label.new(bar_index, high, "CHoCH (Bull)", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.small)
        f_draw_smc_line(top_target, "CHoCH", color.green)
        market_trend := 1
    else
        label.new(bar_index, high, "BOS (Bull)", color=color.teal, textcolor=color.black, style=label.style_label_down, size=size.small)
        f_draw_smc_line(top_target, "BOS", color.teal)
    top_target := na 

if not na(bot_target) and ta.crossunder(close, bot_target)
    if market_trend == 1
        label.new(bar_index, low, "CHoCH (Bear)", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)
        f_draw_smc_line(bot_target, "CHoCH", color.red)
        market_trend := -1
    else
        label.new(bar_index, low, "BOS (Bear)", color=color.maroon, textcolor=color.white, style=label.style_label_up, size=size.small)
        f_draw_smc_line(bot_target, "BOS", color.maroon)
    bot_target := na 

if showFVG and bar_index > 2
    if low[0] > high[2] and close[1] > high[2]
        box.new(left=bar_index[2], top=low[0], right=bar_index, bottom=high[2], bgcolor=fvgColorBg, border_color=color.new(color.teal, 50))
    if high[0] < low[2] and close[1] < low[2]
        box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high[0], bgcolor=color.new(color.red, 92), border_color=color.new(color.red, 50))

// ==========================================
// 3. DINAMIK & SADELEŞTİRİLMİŞ AUTO FIB RETRACEMENT
// ==========================================
var zigzag.Settings zigSettings = zigzag.Settings.new(threshold_mult, fibDepth, color(na), false, false, false, false, "Absolute", true)
var zigzag.ZigZag fibZigZag = zigzag.newInstance(zigSettings)
var zigzag.Pivot lastFibP = na
var float fibStartPrice = na
var float fibHeight = na

var line[] activeFibLines = array.new_line()
var label[] activeFibLabels = array.new_label()

zigSettings.devThreshold := ta.atr(10) / close * 100 * threshold_mult

if fibZigZag.update()
    lastFibP := fibZigZag.lastPivot()
    if not na(lastFibP)
        fibStartPrice := lastFibP.end.price
        endPrice = lastFibP.start.price
        fibHeight := (fibStartPrice > endPrice ? -1 : 1) * math.abs(fibStartPrice - endPrice)
        
        if showFib and array.size(activeFibLines) > 0
            for i = 0 to array.size(activeFibLines) - 1
                line.delete(array.get(activeFibLines, i))
            array.clear(activeFibLines)
        if showFib and array.size(activeFibLabels) > 0
            for i = 0 to array.size(activeFibLabels) - 1
                label.delete(array.get(activeFibLabels, i))
            array.clear(activeFibLabels)

        if showFib
            levelsArray = array.new_float()
            colorsArray = array.new_color()
            
            array.push(levelsArray, 0.0),   array.push(colorsArray, color.gray)
            array.push(levelsArray, 0.236), array.push(colorsArray, color.red)
            array.push(levelsArray, 0.382), array.push(colorsArray, color.orange)
            array.push(levelsArray, 0.5),   array.push(colorsArray, color.green)
            array.push(levelsArray, 0.618), array.push(colorsArray, color.teal)
            array.push(levelsArray, 0.786), array.push(colorsArray, color.blue)
            array.push(levelsArray, 1.0),   array.push(colorsArray, color.gray)
            
            extMode = extendRight ? extend.right : extend.none
            
            for i = 0 to array.size(levelsArray) - 1
                val = array.get(levelsArray, i)
                col = array.get(colorsArray, i)
                targetPrice = fibStartPrice + fibHeight * val
                
                lId = line.new(x1=lastFibP.start.time, y1=targetPrice, x2=time, y2=targetPrice, xloc=xloc.bar_time, color=col, width=1, extend=extMode)
                array.push(activeFibLines, lId)
                
                lblX = extendRight ? time : lastFibP.end.time
                lblId = label.new(x=lblX, y=targetPrice, xloc=xloc.bar_time, text=str.tostring(val * 100) + "% (" + str.tostring(targetPrice, format.mintick) + ")", textcolor=col, style=label.style_label_left, color=#00000000)
                array.push(activeFibLabels, lblId)

// ==========================================
// 4. TABLO METRİKLERİNİN HESAPLANMASI
// ==========================================
rsiVal = ta.rsi(close, 14)
avgVol = ta.sma(volume, 20)
rvolVal = na(avgVol) or avgVol == 0 ? 1.0 : volume / avgVol

[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
macdSignal = macdLine > signalLine ? "BULLISH" : "BEARISH"

mfiVal = ta.mfi(close, 14)
smartMoney = mfiVal > 50 ? "GİRİŞ" : "ÇIKIŞ"

isSqueezed = (bbUpper < kcUpper) and (bbLower > kcLower)
squeezeStatus = isSqueezed ? "SIKIŞMA VAR" : "NORMAL"

vwapStatus = close > avwapVal ? "ÜSTÜNDE" : "ALTINDA"

// Algoritmik Puanlama Dengesi (11 Satıra Göre Dağıtıldı)
int score = 0
if rsiVal > 50 and rsiVal < 70
    score += 15
if macdSignal == "BULLISH"
    score += 15
if fishSignal == "BULLISH"
    score += 15 // Fisher Kesişim Puanı
if buyVolumeWeight > 0.52
    score += 10 // Hacim Alıcı Baskı Puanı
if smartMoney == "GİRİŞ"
    score += 15
if vwapStatus == "ÜSTÜNDE"
    score += 20
if rvolVal > 1.2
    score += 10
if isSqueezed
    score += 10

// ==========================================
// 5. ALPHA TERMINAL DASHBOARD V6.1 (11 Satırlı Güçlendirilmiş Matris)
// ==========================================
var table_pos_enum = tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Right" ? position.bottom_right : tablePos == "Top Left" ? position.top_left : position.bottom_left
var table terminalTable = table.new(table_pos_enum, 2, 11, bgcolor=color.new(color.black, 0), border_color=color.gray, border_width=1)

if barstate.islast
    color headerBg = color.rgb(15, 15, 15)
    color cellBg   = color.rgb(25, 25, 25)
    
    table.cell(terminalTable, 0, 0, "ALPHA TERMINAL", bgcolor=color.rgb(220, 20, 60), text_color=color.white, text_size=size.small, text_halign="center", text_valign="center")
    table.cell(terminalTable, 1, 0, "METRİK DEĞERİ", bgcolor=headerBg, text_color=color.white, text_size=size.small, text_halign="center", text_valign="center")
    
    f_set_cell(terminalTable, 1, "RSI (14)", str.tostring(rsiVal, "#.##"), rsiVal > 70 ? color.red : rsiVal < 30 ? color.green : color.orange, cellBg)
    f_set_cell(terminalTable, 2, "RVOL (Hacim Katı)", str.tostring(rvolVal, "#.##"), rvolVal > 1.5 ? color.green : color.white, cellBg)
    f_set_cell(terminalTable, 3, "MACD Sinyal", macdSignal, macdSignal == "BULLISH" ? color.green : color.red, cellBg)
    f_set_cell(terminalTable, 4, "Fisher Transform", fishSignal, fishSignal == "BULLISH" ? color.green : color.red, cellBg)
    f_set_cell(terminalTable, 5, "Hacim Dağılımı (Alış/Satış)", str.tostring(buyVolumeWeight * 100, "#") + "% / " + str.tostring(sellVolumeWeight * 100, "#") + "%", buyVolumeWeight > 0.5 ? color.green : color.red, cellBg)
    f_set_cell(terminalTable, 6, "Kurumsal Para", smartMoney, smartMoney == "GİRİŞ" ? color.green : color.red, cellBg)
    f_set_cell(terminalTable, 7, "Toplam Hacim", str.tostring(volume, "#,###"), color.blue, cellBg)
    f_set_cell(terminalTable, 8, "Sıkışma (Squeeze)", squeezeStatus, isSqueezed ? color.blue : color.gray, cellBg)
    f_set_cell(terminalTable, 9, "VWAP Konumu", vwapStatus, vwapStatus == "ÜSTÜNDE" ? color.green : color.red, cellBg)
    
    color scoreColor = score >= 70 ? color.green : score >= 45 ? color.orange : color.red
    f_set_cell(terminalTable, 10, "Alpha Terminal Skoru", str.tostring(score) + " / 100", scoreColor, cellBg)
````
