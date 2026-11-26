# Hybrid Regression & Dual PVT Flow

- url: https://www.tradingview.com/script/NmILQ6wB/
- type: indicator
- pine_id: PUB;c45c46cfb64641ea9db72c2208586222
- version: 1.0

## Description

🇺🇸 ENGLISH DESCRIPTION TEXT
Overview
Hybrid Regression & Dual PVT Flow is an institutional-grade hybrid analysis system designed to uncover the footprints of market whales. It bridges the gap between pure price geometry and volume-weighted momentum, preventing retail traders from falling into "bull/bear traps" by exposing hidden institutional accumulation and distribution phases.

Key Technical Pillars:

Linear Regression Core: Computes a noise-filtered baseline representing the true mathematical equilibrium of price. The curve turns green during a bullish slope and red during a bearish slope.

Dynamic Fibonacci Volatility Envelope: Employs an ATR-driven deviation mechanism instead of traditional standard deviations. It projects key institutional overbought (Resistance) and oversold (Support) thresholds based on the 2.618 Fibonacci ratio.

Volume Anomaly Engine: Scans for extreme institutional anomalies where candle volume exceeds 1.5x of its 20-period moving average. These high-activity institutional bars are highlighted in Yellow on your chart.

Dual-Layer Multi-Timeframe PVT Dashboard:

Micro PVT Status: Tracks real-time smart money participation directly on your active trading timeframe (e.g., 5m, 15m, 1h).

Macro PVT Status: Permanently anchors a Daily (1D) Price Volume Trend core against its 10-period EMA, providing an unshakeable perspective of the "Big Picture" regardless of your active asset chart.

How to Read the Intelligence Dashboard:

BULLISH / BEARISH CONVERGENCE: Absolute alignment between the macro trend line and multi-timeframe capital flows. Indicates high-probability trend continuation.

HIDDEN BEARISH DIVERGENCE (Distribution Trap): Price regression slope is upward, but both macro and micro PVT metrics are flashing negative. Highly indicative of institutional selling into retail FOMO.

STRONG ACCUMULATION DIVERGENCE (Whale Accumulation): Price regression slope is sliding downward, but dual-layer PVT inflows are accelerating heavily. Signals structural retail liquidation being absorbed by institutional market makers right before a major reversal.

🇹🇷 TÜRKÇE AÇIKLAMA METNİ
Özet Giriş
Hybrid Regression & Dual PVT Flow, piyasada sıklıkla karşılaşılan "fiyat yükselirken kurumsal oyuncuların arka kapıdan mal çıkması" (dağıtım) veya "fiyat düşerken balinaların dipten gizlice mal toplaması" (akümülasyon) durumlarını yakalamak için tasarlanmış hibrit bir takip sistemidir. Matematiksel gücünü Doğrusal Regresyon Eğrisi ve Çift Katmanlı Price Volume Trend (PVT) momentum motorunun sentezinden alır.

Ana Özellikler:

Doğrusal Regresyon Hattı (Linear Regression Trend): Piyasanın ana dengesini ve makro yönünü gürültüden arındırılmış bir eğri olarak sunar. Eğim yukarıysa yeşil (Boğa), aşağıysa kırmızı (Ayı) olarak grafiğe işlenir.

Dinamik Fibonacci Volatilite Bantları: Klasik Bollinger bantları yerine, ATR (Average True Range) tabanlı dinamik volatilite sınırları kullanır. Üst kırılımlar kurumsal aşırı alım/direnç, alt bantlar ise kurumsal güvenli alım/destek bölgelerini işaret eder.

Hacim Anomalisi Mum Boyama: Son 20 mumun ortalama hacmini %150 aşan ani balina aktivitelerinde, mumlar otomatik olarak Sarı renge boyanarak dikkat çeker.

Çift Katmanlı PVT ve Trend Matris Paneli: * Mikro PVT: Bulunduğunuz anlık aktif grafik zaman dilimindeki (5dk, 15dk, 1sa vb.) para akışı yönünü ölçer.

Makro PVT: Grafiğiniz ne olursa olsun, arka planda Günlük (1D) kurumsal para akışının 10 günlük ortalamasını denetler.

Panel Strateji Notları Nasıl Okunur?

TAM UYUM (BOĞA / AYI): Trend yönü ile tüm vadelerdeki para akışları aynı yöndedir. Güvenli katılım bölgesidir.

GİZLİ AYI UYUMSUZLUĞU (Dağıtım Tuzağı): Regresyon eğrisi yukarı bakarken, hem günlük hem anlık para akışları negatif yönlüdür. Balinaların küçük yatırımcıya mal devrettiği tepe tuzaklarını gösterir.

GİZLİ BOĞA UYUMSUZLUĞU (Mal Toplama): Grafik aşağı akarken, hem günlük hem anlık PVT'nin güçlü yönlü yukarı gitmesidir. Balinaların dipten toplama yaptığını ve sert bir yükselişin yakın olduğunu gösterir.

## Source Code

````pine
//@version=6
indicator("Hybrid Regression & Dual PVT Flow", overlay=true)

// --- Inputs ---
regLength     = input.int(55, title="Regression Period (Length)", minval=5)
atrLength     = input.int(21, title="Volatility (ATR) Period")
atrMultiplier = input.float(2.618, title="Dynamic Deviation Multiplier (Fibonacci)", step=0.1)
volLength     = input.int(20, title="Volume Average Period")
volMultiplier = input.float(1.5, title="Volume Anomaly Multiplier", step=0.1)

// --- Layer 1: Linear Regression Curve ---
regCurve = ta.linreg(close, regLength, 0)

// --- Layer 2: Dynamic Volatility Bands ---
dynamicRange = ta.atr(atrLength) * atrMultiplier
upperBand = regCurve + dynamicRange
lowerBand = regCurve - dynamicRange

// --- Volume Anomaly Calculation ---
avgVolume = ta.sma(volume, volLength)
bool volumeAnomaly = volume > (avgVolume * volMultiplier)

// --- Trend and Price Dynamics ---
bool isTrendBullish = regCurve > regCurve[1]
bool isPriceFalling = close < close[1]

// Micro Timeframe Percentage Change
float mikroPctChange = ta.change(close) / (close[1] != 0 ? close[1] : 1) * 100

// =========================================================================
// --- DUAL-LAYER PVT CALCULATION ENGINE ---
// =========================================================================
// 1. MICRO LAYER: Active chart timeframe PVT status
pvtMikro = ta.pvt
pvtMikroSignal = ta.ema(pvtMikro, 10)
bool isMikroPvtRising = pvtMikro > pvtMikroSignal

// 2. MACRO LAYER: Daily (1D) timeframe PVT status
pvtGunluk = request.security(syminfo.tickerid, "D", ta.pvt)
pvtGunlukSignal = request.security(syminfo.tickerid, "D", ta.ema(ta.pvt, 10))
bool isMakroPvtRising = pvtGunluk > pvtGunlukSignal

// Daily Cumulative PVT Net Change
dClose = request.security(syminfo.tickerid, "D", close)
float dPctChange = (ta.change(dClose) / (nz(dClose[1]) != 0 ? dClose[1] : 1)) * 100
float dPvtChange = pvtGunluk - nz(pvtGunluk[1])

// Numeric Formatting Function (K, M, B)
formatNumber(float num) =>
    absNum = math.abs(num)
    signStr = num < 0 ? "-" : ""
    if absNum >= 1000000000
        signStr + str.tostring(absNum / 1000000000, "#.##") + "B"
    else if absNum >= 1000000
        signStr + str.tostring(absNum / 1000000, "#.##") + "M"
    else if absNum >= 1000
        signStr + str.tostring(absNum / 1000, "#.#") + "K"
    else
        signStr + str.tostring(absNum, "#")

// --- Plotting ---
plotColor = isTrendBullish ? color.green : color.red
plot(regCurve, color=color.new(plotColor, 0), linewidth=3, title="Regression Trend Line")

pUpper = plot(upperBand, color=color.new(color.red, 50), linewidth=1, title="Upper Institutional Resistance")
pLower = plot(lowerBand, color=color.new(color.green, 50), linewidth=1, title="Lower Institutional Support")
fill(pUpper, pLower, color=color.new(color.purple, 96), title="Market Safe Zone Range")

// --- Bar Coloring based on Volume Anomaly ---
barcolor(volumeAnomaly ? color.new(color.yellow, 50) : na, title="Volume Anomaly Bar Color")

// =========================================================================
// --- SMART PVT & TREND MATRIX DASHBOARD ---
// =========================================================================
var table infoTable = table.new(position = position.top_right, columns = 2, rows = 6, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.gray)

if barstate.islast
    table.cell(infoTable, 0, 0, "PVT & TREND MATRIX", bgcolor=color.purple, text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, "STATUS / VALUE [% CHG]", bgcolor=color.purple, text_color=color.white, text_size=size.small)
    
    // Row 1: Regression Slope
    table.cell(infoTable, 0, 1, "Regression Slope (Macro):", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, isTrendBullish ? "UPWARD (Bullish)" : "DOWNWARD (Bearish)", bgcolor=isTrendBullish ? color.green : color.red, text_color=color.white, text_size=size.small)
    
    // Row 2: Micro PVT Flow
    string mikroYuzdeStr = " [" + (mikroPctChange >= 0 ? "+" : "") + str.tostring(mikroPctChange, "#.##") + "%]"
    table.cell(infoTable, 0, 2, "Active Chart Flow (Micro PVT):", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, (isMikroPvtRising ? "POSITIVE" : "NEGATIVE") + mikroYuzdeStr, bgcolor=isMikroPvtRising ? color.teal : color.orange, text_color=color.white, text_size=size.small)
    
    // Row 3: Macro PVT Flow
    table.cell(infoTable, 0, 3, "Big Picture Flow (Daily PVT):", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, isMakroPvtRising ? "STRONG (Buyers)" : "WEAK (Sellers)", bgcolor=isMakroPvtRising ? color.green : color.maroon, text_color=color.white, text_size=size.small)

    // Row 4: Today's Net Change
    string gunlukYuzdeStr = " [" + (dPctChange >= 0 ? "+" : "") + str.tostring(dPctChange, "#.##") + "%]"
    color pvtRengi = dPvtChange >= 0 ? color.teal : color.orange
    table.cell(infoTable, 0, 4, "Today's Net PVT Change:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, formatNumber(dPvtChange) + gunlukYuzdeStr, bgcolor=pvtRengi, text_color=color.white, text_size=size.small)
    
    // Row 5: AI Strategic Intelligence Narrative
    string piyasaYorumu = ""
    color yorumRengi = color.gray
    
    if isTrendBullish
        if isMakroPvtRising and isMikroPvtRising
            if isPriceFalling
                piyasaYorumu := "Macro trend and daily volume are strong, but micro-pullback detected. Potential buying opportunity."
                yorumRengi := color.olive
            else
                piyasaYorumu := "BULLISH CONVERGENCE: Strong uptrend fully backed by institutional volume on both timeframes."
                yorumRengi := color.green
        else if isMakroPvtRising and (not isMikroPvtRising)
            piyasaYorumu := "MICRO PULLBACK: Daily structure is solid, but short-term profit-taking is active. Watch supports."
            yorumRengi := color.olive
        else if (not isMakroPvtRising) and isMikroPvtRising
            piyasaYorumu := "SHORT-TERM RALLY / TRAP: Micro buying active but macro flow is weak. Distribution might be ongoing."
            yorumRengi := color.orange
        else if (not isMakroPvtRising) and (not isMikroPvtRising)
            piyasaYorumu := "WARNING (HIDDEN DISTRIBUTION): Upward regression slope but negative volume flows. Potential FOMO trap!"
            yorumRengi := color.maroon
            
    else // Bearish Core Trend
        if (not isMakroPvtRising) and (not isMikroPvtRising)
            piyasaYorumu := "BEARISH CONVERGENCE: Downward trend confirmed by aggressive institutional outflows across all layers."
            yorumRengi := color.red
        else if (not isMakroPvtRising) and isMikroPvtRising
            piyasaYorumu := "MICRO REBOUND: Big picture is bearish, but current timeframe is undergoing a temporary minor rebound."
            yorumRengi := color.orange
        else if isMakroPvtRising and isMikroPvtRising
            piyasaYorumu := "STRONG ACCUMULATION DIVERGENCE: Downward slope but strong dual-layer inflows. Bottom reversal is imminent."
            yorumRengi := color.teal
        else if isMakroPvtRising and (not isMikroPvtRising)
            piyasaYorumu := "INSTITUTIONAL ACCUMULATION: Whales are buying daily, but suppressing price on micro scales."
            yorumRengi := color.navy
        
    table.cell(infoTable, 0, 5, "Strategic Flow Narrative:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 5, piyasaYorumu, bgcolor=yorumRengi, text_color=color.white, text_size=size.small)
````
