# DR/IDR + S&D

- url: https://www.tradingview.com/script/NXM54EJY/
- type: indicator
- pine_id: PUB;d3aa1acc3c8a419b8f24a064f33062d5
- version: 1.0

## Description

English Description

DR/IDR + S&D is a multi-purpose market structure indicator designed for Forex traders.
It automatically plots DR / IDR (Daily Range / Initial Daily Range) zones while also detecting momentum-based Supply & Demand areas.

This indicator is especially useful for:

London / New York session trading,
intraday scalping,
liquidity sweeps,
breakout and mean reversion strategies.
Features

✔ Automatic DR / IDR boxes
✔ RDR / ADR / ODR session support
✔ Custom timezone settings
✔ Momentum-based Supply & Demand detection
✔ Automatic mitigation cleanup for used zones
✔ Zone size filtering system
✔ Maximum active zone limit for performance optimization
✔ DR midpoint (0.5) level plotting

DR / IDR Logic
DR (Daily Range) → Full session high-low range
IDR (Initial Daily Range) → Candle body based initial session range

Users can switch between DR and IDR visualization.

Supply & Demand Logic

The indicator analyzes strong momentum moves to automatically identify:

demand zones after aggressive bullish expansions,
supply zones after aggressive bearish expansions.

Once price mitigates a zone, the area becomes inactive automatically.

Best Usage
1m / 3m / 5m charts
Major Forex pairs
Session-based trading strategies
Liquidity + market structure concepts
Note

This indicator is non-repainting.
All zone calculations are confirmed only after candle close (barstate.isconfirmed).

⚠️ This indicator is designed solely as a technical analysis tool and does not constitute financial or investment advice.
All trading decisions and associated risks remain the sole responsibility of the user.

Türkçe Açıklama

DR/IDR + S&D, Forex piyasaları için geliştirilmiş çok amaçlı bir piyasa yapısı indikatörüdür.
Bu araç; DR / IDR (Daily Range / Initial Daily Range) bölgelerini otomatik olarak oluştururken aynı zamanda momentum bazlı Supply & Demand (Arz / Talep) alanlarını da tespit eder.

İndikatör özellikle:

London / New York session işlemleri,
intraday scalping,
liquidity sweep,
breakout ve mean reversion stratejileri
için optimize edilmiştir.
Özellikler

✔ Otomatik DR / IDR kutuları
✔ RDR / ADR / ODR session desteği
✔ Özelleştirilebilir timezone ayarı
✔ Momentum bazlı Supply & Demand zone tespiti
✔ Mitigated (çalışmış) bölgelerin otomatik temizlenmesi
✔ Zone genişliği filtreleme sistemi
✔ Performans optimizasyonu için maksimum aktif zone limiti
✔ DR midpoint (0.5) seviyesi çizimi

DR / IDR Mantığı
DR (Daily Range) → Session boyunca oluşan tam high-low aralığı
IDR (Initial Daily Range) → Session içerisindeki candle body bazlı başlangıç aralığı

Kullanıcı isterse DR veya IDR görünümünü seçebilir.

Supply & Demand Mantığı

İndikatör güçlü momentum hareketlerini analiz ederek:

hızlı yükselişlerden sonra oluşan demand bölgelerini,
hızlı düşüşlerden sonra oluşan supply bölgelerini
otomatik olarak işaretler.

Fiyat ilgili bölgeyi mitigate ettiğinde (tekrar test ettiğinde), zone pasif hale getirilir.

En İyi Kullanım
1m / 3m / 5m grafikler
Forex majör pariteleri
Session bazlı işlem stratejileri
Liquidity + market structure kombinasyonları
Not

Bu indikatör repaint yapmaz.
Zone oluşumları yalnızca candle kapanışı onaylandıktan sonra oluşturulur (barstate.isconfirmed).

⚠️ Bu indikatör yalnızca teknik analiz amacıyla geliştirilmiş yardımcı bir araçtır.
Herhangi bir yatırım tavsiyesi içermez. İşlem kararları ve oluşabilecek riskler tamamen kullanıcı sorumluluğundadır.

## Source Code

````pine
//@version=6
indicator('DR/IDR + S&D', overlay=true, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ==========================================
// ----> DR / IDR INPUTS & LOGIC <----
// ==========================================
var GRP1 = "DR/IDR Time Settings"
TIMEZONE        = input.string('America/New_York', "Timezone", group=GRP1)
regularTime     = input.session('0930-1030', 'RDR Time', group=GRP1)
regularExtend   = input.session('1030-1600', 'RDR Lines Time', group=GRP1)
afterTime       = input.session('1930-2030', 'ADR Time', group=GRP1)
afterExtend     = input.session('2030-0200', 'ADR Lines Time', group=GRP1)
overnightTime   = input.session('0300-0400', 'ODR Time', group=GRP1)
overnightExtend = input.session('0400-0830', 'ODR Lines Time', group=GRP1)

var GRP2 = "DR/IDR General"
showRegular     = input.bool(true, 'Show Regular', group=GRP2)
showAfter       = input.bool(true, 'Show After', group=GRP2)
showOvernight   = input.bool(true, 'Show Overnight', group=GRP2)
boxType         = input.string('IDR', 'Box DR or IDR ?', options=['DR','IDR'], group=GRP2)
backgroundColor = input.color(color.new(color.white, 57), 'DR Box Color', group=GRP2)

// ==========================================
// ----> BACKTESTBOT S&D INPUTS <----
// ==========================================
var GRP3 = "S&D Logic (BacktestBot)"
ds_min_pc_change = input.float(0.25, 'Min % Change for Zone', minval=0, step=0.05, group=GRP3, tooltip="Bu oran 5m grafiklerde %0.15-%0.30 arası idealdir.")
ds_max_pc_zone   = input.float(0.6, 'Max % Zone Height', minval=0, group=GRP3)
ds_max_zones     = input.int(10, 'Max Active Zones to Display', minval=1, group=GRP3)
demand_bg_col    = input.color(color.new(color.fuchsia, 80), 'Demand Color', group=GRP3)
supply_bg_col    = input.color(color.new(color.yellow, 80), 'Supply Color', group=GRP3)

// ----> S&D Variables & Arrays <----
var demand_boxes = array.new_box()
var supply_boxes = array.new_box()
var demand_prices = array.new_float()
var supply_prices = array.new_float()

// ----> DR/IDR Variables <----
var float rdrHigh = na, var float rdrLow = na
var float ridrHigh = na, var float ridrLow = na
var int startTime = na
var box drBox = na

// ==========================================
// ----> FUNCTIONS <----
// ==========================================
f_inSession(_sess) => not na(time(timeframe.period, _sess, TIMEZONE))

// ==========================================
// ----> CORE CALCULATION <----
// ==========================================
inSess = (f_inSession(regularTime) and showRegular) or (f_inSession(afterTime) and showAfter) or (f_inSession(overnightTime) and showOvernight)

// DR / IDR Calculation
if inSess
    if not inSess[1]
        rdrHigh := high, rdrLow := low
        ridrHigh := math.max(open, close), ridrLow := math.min(open, close)
        startTime := time
        drBox := box.new(startTime, na, time, na, xloc=xloc.bar_time, bgcolor=backgroundColor, border_style=line.style_dotted)
    else
        rdrHigh := math.max(high, rdrHigh)
        rdrLow := math.min(low, rdrLow)
        ridrHigh := math.max(open, close, ridrHigh)
        ridrLow := math.min(open, close, ridrLow)
        box.set_right(drBox, time)
        if boxType == 'DR'
            box.set_top(drBox, rdrHigh), box.set_bottom(drBox, rdrLow)
        else
            box.set_top(drBox, ridrHigh), box.set_bottom(drBox, ridrLow)

// ----> S&D DETECTION (Momentum Based) <----
bear_run = ta.barssince(open < close)
bull_run = ta.barssince(open > close)

// Momentum Check
pc_change_bull = bull_run >= 1 ? (math.abs(close - open[bull_run-1]) / open[bull_run-1]) * 100 : 0
pc_change_bear = bear_run >= 1 ? (math.abs(close - open[bear_run-1]) / open[bear_run-1]) * 100 : 0

// Demand Zone Detection
if pc_change_bull >= ds_min_pc_change and barstate.isconfirmed
    float top = open[bull_run]
    float bot = low[bull_run]
    // Zone size check
    if (top - bot) / bot * 100 <= ds_max_pc_zone
        newBox = box.new(time[bull_run], top, time + 86400000, bot, xloc=xloc.bar_time, bgcolor=demand_bg_col, border_color=color.new(demand_bg_col, 50))
        array.unshift(demand_boxes, newBox)
        array.unshift(demand_prices, bot)

// Supply Zone Detection
if pc_change_bear >= ds_min_pc_change and barstate.isconfirmed
    float bot = open[bear_run]
    float top = high[bear_run]
    if (top - bot) / bot * 100 <= ds_max_pc_zone
        newBox = box.new(time[bear_run], top, time + 86400000, bot, xloc=xloc.bar_time, bgcolor=supply_bg_col, border_color=color.new(supply_bg_col, 50))
        array.unshift(supply_boxes, newBox)
        array.unshift(supply_prices, top)

// ----> MITIGATION & CLEANUP <----
// Demand Kutularını Kontrol Et (Fiyat altına inerse veya dokunursa)
if array.size(demand_boxes) > 0
    for i = array.size(demand_boxes) - 1 to 0
        b = array.get(demand_boxes, i)
        p = array.get(demand_prices, i)
        if low <= p // Mitigated
            box.set_bgcolor(b, color.new(color.gray, 90))
            box.set_border_style(b, line.style_dotted)
            box.set_right(b, time)
            array.remove(demand_boxes, i)
            array.remove(demand_prices, i)
        else
            box.set_right(b, time + 2000000) // Kutuyu uzat

// Supply Kutularını Kontrol Et
if array.size(supply_boxes) > 0
    for i = array.size(supply_boxes) - 1 to 0
        b = array.get(supply_boxes, i)
        p = array.get(supply_prices, i)
        if high >= p // Mitigated
            box.set_bgcolor(b, color.new(color.gray, 90))
            box.set_border_style(b, line.style_dotted)
            box.set_right(b, time)
            array.remove(supply_boxes, i)
            array.remove(supply_prices, i)
        else
            box.set_right(b, time + 2000000)

// Maksimum kutu sayısı kontrolü (Performans için)
while array.size(demand_boxes) > ds_max_zones
    box.delete(array.pop(demand_boxes))
    array.pop(demand_prices)

while array.size(supply_boxes) > ds_max_zones
    box.delete(array.pop(supply_boxes))
    array.pop(supply_prices)

// ----> DR/IDR 0.5 ve Seviye Çizgileri <----
if not na(rdrHigh) and (inSess or f_inSession(regularExtend))
    line.new(startTime, math.avg(rdrHigh, rdrLow), time, math.avg(rdrHigh, rdrLow), xloc=xloc.bar_time, color=color.new(color.gray, 50), style=line.style_dashed, width=1)
````
