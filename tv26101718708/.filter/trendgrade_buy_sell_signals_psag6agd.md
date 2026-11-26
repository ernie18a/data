# TrendGrade Buy  Sell Signals

- url: https://www.tradingview.com/script/PsaG6aGD/
- type: indicator
- pine_id: PUB;84451c04c34a4e928a6a92a2956e7ddb
- version: 1.0

## Description

TrendGrade — Buy & Sell Signals (MTF Confirmed)
What it does
TrendGrade is a signal-grading system built on top of a Supertrend trigger. Instead of treating every Supertrend flip as an equal trade opportunity, it classifies each buy signal by quality using trend-strength analysis (XTL), higher-timeframe confirmation, and a transparent rule-based priority score. It is designed primarily for intraday swing timeframes (e.g., 2H) with 4H confirmation and an optional Daily veto.
How it works
1. Base trigger — Supertrend
The entry engine is the classic ATR-based Supertrend (default ATR 14, multiplier 2.0). A buy setup appears when the trend flips from bearish to bullish; a sell setup appears on the opposite flip.
2. Signal grading — XTL (eXpert Trend Locator)
XTL is based on Tom Joseph's statistical concept for separating directional moves from random market noise, implemented here via a Double-CCI-style calculation with a selectable moving-average engine (28 MA types, default VWMA-26 on HLC3) and a fixed threshold (default 37).
XTL above the threshold = BULL environment
XTL below the negative threshold = BEAR environment
Otherwise = NEUTRAL
Optional bar coloring paints candles by XTL state (bull / neutral / bear).
3. Multi-timeframe confirmation (anti-repaint)
4H confirmation: close above the 4H EMA-21, EMA slope flat or rising, plus an optional RSI(14) momentum check (RSI > 50 or rising).
Daily veto (optional): if the Daily close is below its EMA-21 AND the EMA slope is down (strong downtrend), all buy signals are blocked. Blocked signals are still shown on the chart as an orange × for transparency.
By default only closed higher-timeframe bars are used (`lookahead_off` + confirmed-bar indexing), so MTF confirmation does not repaint. This can be disabled for faster (but mutable) live-bar confirmation.
4. Signal classes
STRONG BUY — Supertrend flip + XTL BULL + 4H confirmation (lime label)
BUY — Supertrend flip without full confirmation (green label)
SELL — Supertrend flip down, only fired if a valid buy occurred first (simple position tracking, so sells are not orphaned)
Filtered/blocked raw signals are plotted as gray circles or orange × marks so you can always see what was suppressed and why.
5. Optional EMA-89 filter
Buy signals can additionally be required to close above EMA-89 (with an adjustable % tolerance). Off by default.
6. Priority score (0–100)
Each signal gets a transparent, rule-based score from RSI, MFI, relative volume, EMA ribbon alignment (5/8/13/34/55/89/200), Parabolic SAR position and CMF. This is a simple checklist score — it is NOT a statistical probability.
7. Alerts & webhook automation
Standard `alertcondition()` alerts for Strong Buy / Buy / Sell / trend change.
A structured JSON alert (via `alert()`) designed for webhook automation (e.g., Make.com / n8n): symbol, timeframe, price, ATR-based Target-1/Target-2, Supertrend stop, R:R ratio, priority score, XTL state, 4H/Daily MTF status, RSI/MFI/CMF, relative volume, EMA support/resistance map, and flags such as "volume spike" (relative volume ≥ 3×) and "strong money inflow" (CMF ≥ 0.15).
Optional early intrabar alert: fires before bar close once a configurable percentage of the bar has elapsed (default 60%), clearly tagged `early_mode=1`. Early alerts can be invalidated before the bar closes (repaint risk is explicitly flagged); the confirmed bar-close alert is always sent separately.
Settings overview
Supertrend: ATR period, multiplier, source, ATR method
XTL: length, MA type (28 options), source, threshold, traditional/modern CCI formula
MTF: confirmation timeframe (default 4H), veto timeframe (default 1D), EMA length, slope lookback, momentum check, closed-bar mode
EMA-89 filter, EMA ribbon display, Parabolic SAR display
Targets: ATR multiples for Target-1 / Target-2 (used in alert messages)
Oscillators/volume lengths and attention thresholds (used in alert messages)
Early-signal toggle and minimum bar progress
Repainting notes
Confirmed signals are evaluated on bar close.
MTF data uses `lookahead_off` and, by default, the last closed higher-timeframe bar, so confirmation status does not change retroactively (at the cost of up to one higher-timeframe bar of delay).
The optional early intrabar alert is intentionally repainting by nature and is clearly labeled as a pre-warning; the final confirmation is always sent at bar close.
Credits
XTL (eXpert Trend Locator) concept by Tom Joseph — a statistical market evaluation distinguishing directional trends from random noise.
XTL implementation adapted from the public "Double CCI" approach on TradingView.
Supertrend logic based on the widely used ATR-based community implementation.
Moving-average library includes public implementations credited in-code to @everget (JMA), @DonovanWall (FRAMA, COVWMA), @allanster (VAMA), @RedKTrader (RSS_WMA), @Duyck (ADX MA) and @glaz (RSI EMA).
Disclaimer
This indicator is for educational and informational purposes only. It is not financial advice and past signal behavior does not guarantee future results. Always do your own research and manage risk appropriately.

## Source Code

````pine
//@version=6
// TrendGrade — Buy & Sell Signals (+ MTF Onayı: 4H ana onay + Günlük veto)
// Credits:
//  - XTL (eXpert Trend Locator) concept by Tom Joseph — a statistical market evaluation
//    that distinguishes directional moves (trends) from random market noise.
//  - Supertrend logic based on the widely used ATR-based community implementation.
indicator('TrendGrade — Buy & Sell Signals', overlay = true, format = format.price, precision = 2)

// ─────────────────────────── SUPERTREND AYARLARI ───────────────────────────
grpST        = 'Supertrend'
Periods      = input.int(14, title = 'ATR Period', group = grpST)
src          = input.source(hl2, title = 'Source', group = grpST)
Multiplier   = input.float(2.0, title = 'ATR Multiplier', step = 0.1, group = grpST)
changeATR    = input.bool(true, title = 'Change ATR Calculation Method ?', group = grpST)
showsignals  = input.bool(true, title = 'Show Buy/Sell Signals ?', group = grpST)
highlighting = input.bool(true, title = 'Highlighter On/Off ?', group = grpST)

// ─────────────────────────── EMA89 EŞİĞİ ───────────────────────────
grpEMA         = 'EMA89 Eşiği'
useEma89Filter = input.bool(true, title = 'EMA89 eşiğini AL sinyaline uygula ?', group = grpEMA)
ema89Len       = input.int(89, title = 'EMA uzunluğu', minval = 1, group = grpEMA)
ema89TolPct    = input.float(0.0, title = 'Eşik toleransı (%)', step = 0.1, group = grpEMA,
     tooltip = 'Fiyatın EMA89 üzerinde olması gereken minimum yüzde mesafe. 0 = kapanış > EMA89 yeterli.')
showEma89      = input.bool(true, title = 'EMA89 çizgisini göster', group = grpEMA)

// ─────────────────────────── EMA DİZİLİMİ (5/8/13/34/55/89/200) ───────────────────────────
grpDZ      = 'EMA Dizilimi'
showEmaSet = input.bool(false, title = 'Dizilim EMA çizgilerini göster (5/8/13/34/55/200)', group = grpDZ)

// ─────────────────────────── PARABOLİK SAR ───────────────────────────
grpSAR   = 'Parabolik SAR'
sarStart = input.float(0.02, title = 'Start (AF)', step = 0.01, group = grpSAR)
sarInc   = input.float(0.02, title = 'Increment', step = 0.01, group = grpSAR)
sarMax   = input.float(0.2,  title = 'Max', step = 0.01, group = grpSAR)
showSar  = input.bool(false, title = 'SAR noktalarını göster', group = grpSAR)

// ─────────────────────────── HEDEF / STOP ───────────────────────────
grpTS     = 'Hedef & Stop (mesaj için)'
t1AtrMult = input.float(1.0, title = 'Hedef-1 = Fiyat + ATR ×', step = 0.1, group = grpTS)
t2AtrMult = input.float(2.0, title = 'Hedef-2 = Fiyat + ATR ×', step = 0.1, group = grpTS)

// ─────────────────────────── OSİLATÖR / HACİM AYARLARI ───────────────────────────
grpOS  = 'Osilatörler & Hacim (mesaj için)'
rsiLen = input.int(14, title = 'RSI uzunluğu', group = grpOS)
mfiLen = input.int(14, title = 'MFI uzunluğu', group = grpOS)
cmfLen = input.int(20, title = 'CMF uzunluğu', group = grpOS)
volLen = input.int(20, title = 'Hacim ortalaması (SMA)', group = grpOS)

// Dikkat çekici ibare eşikleri
volXDikkat = input.float(3.0, title = 'Hacim dikkat eşiği (x kat)', step = 0.5, group = grpOS,
     tooltip = 'Göreceli hacim bu katın üzerindeyse mesaja HACİM PATLAMASI ibaresi eklenir.')
cmfDikkat  = input.float(0.15, title = 'Güçlü para girişi CMF eşiği', step = 0.05, group = grpOS,
     tooltip = 'CMF bu değerin üzerindeyse mesaja GÜÇLÜ PARA GİRİŞİ ibaresi eklenir.')

// ─────────────────────────── UZMAN TREND BULUCU (XTL) — EWO & XTL indikatöründen birebir ───────────────────────────
grpXTL      = 'Uzman Trend Bulucu (XTL)'
useXTL      = input.bool(true, 'XTL eşiğini sinyal gücü için kullan ?', group = grpXTL,
     tooltip = 'Açıkken: XTL BULL barlarında gelen AL sinyali GÜÇLÜ AL olarak, diğer durumlarda NORMAL AL olarak etiketlenir.')
showXTL     = input.bool(true, '↪ XTL Mum Rengini Kullan ↩ ', group = grpXTL)
period_xtl  = input.int(35, 'Uzunluk', minval = 2, inline = 'xtl', group = grpXTL)
MA_Type2    = input.string('ALMA', 'Tip', inline = 'xtl', group = grpXTL, options = ['SMA', 'ALMA', 'EMA', 'WMA', 'DWMA', 'VWMA', 'New-WMA', 'VAMA', 'DVWMA', 'COVWMA', 'FRAMA', 'HMA', 'LSMA', 'Wilder', 'JMA', 'RSS_WMA', 'KAMA', 'ADX MA', 'RSI EMA', 'Zero Lag', 'Tillson T3', 'VIDYA', 'CTI', 'TSF', 'RMA', 'DEMA', 'TEMA', 'SWMA'])
src_xtl     = input.string('HLC3', 'Kaynak', inline = 'xtl', group = grpXTL, options = ['TR', 'VWAP', 'Close', 'Open', 'HL2', 'HLC3', 'OHLC4', 'HLCC4', 'High', 'Low', 'vwap(Close)', 'vwap(Open)', 'vwap(High)', 'vwap(Low)', 'AVG(vwap(H,L))', 'AVG(vwap(O,C))', 'OBV', 'AccDist', 'PVT', 'Volume'])
fixed_Value = input.int(37, 'Eşik Seviyesi', minval = 10, group = grpXTL, inline = 'xtl2')
uTrad       = input.bool(false, 'Geleneksel CCI formülünü kullan', group = grpXTL, inline = 'xtl2')
detect_bull = input.bool(false, '◁ Uyarı: Yükseliş Trendi', inline = 'alert_xtl', group = grpXTL)
detect_bear = input.bool(false, '◁ Uyarı: Düşüş Trendi', inline = 'alert_xtl', group = grpXTL)

// ─────────────────────────── MTF ONAYI (4H ANA ONAY + GÜNLÜK VETO) ───────────────────────────
// Mantık (2H işlem periyodu için):
//   • 4H POZİTİF  → kapanış 4H EMA21 üzerinde + EMA21 eğimi yatay/yukarı (+ opsiyonel momentum)
//   • GÜNLÜK VETO → günlük kapanış EMA21 altında VE EMA21 eğimi aşağı ise (güçlü düşüş) sinyal engellenir
//   • GÜÇLÜ AL    → mevcut XTL şartına ek olarak 4H onayı da gerekir; 4H onaysızsa sinyal NORMAL AL'a düşer
grpMTF        = 'MTF Onayı (4H onay + Günlük veto)'
useMTF4h      = input.bool(true, 'GÜÇLÜ AL için 4H onayı iste ?', group = grpMTF,
     tooltip = 'Açıkken: XTL BULL olsa bile 4H onayı yoksa sinyal GÜÇLÜ AL yerine NORMAL AL olarak etiketlenir.')
useDailyVeto  = input.bool(true, 'Günlük güçlü düşüşte TÜM AL sinyallerini engelle (veto) ?', group = grpMTF,
     tooltip = 'Günlük kapanış EMA altında VE EMA eğimi aşağı ise AL sinyali üretilmez. Engellenen sinyal turuncu × ile gösterilir.')
tf4h          = input.timeframe('240', 'Ana onay periyodu', group = grpMTF, inline = 'mtf1')
tfD           = input.timeframe('D', 'Veto periyodu', group = grpMTF, inline = 'mtf1')
mtfEmaLen     = input.int(21, 'Üst periyot EMA uzunluğu', minval = 1, group = grpMTF, inline = 'mtf2')
mtfSlopeBars  = input.int(3, 'Eğim bakış barı', minval = 1, group = grpMTF, inline = 'mtf2',
     tooltip = 'EMA eğimi, EMA’nın bu kadar bar önceki değerine göre ölçülür.')
mtfMomentum   = input.bool(true, '4H momentum (RSI) kontrolü ?', group = grpMTF,
     tooltip = '4H onayı için RSI(14) > 50 VEYA RSI yükseliyor olmalı.')
mtfUseClosed  = input.bool(true, 'Sadece KAPANMIŞ üst periyot barını kullan (repaint önleme)', group = grpMTF,
     tooltip = 'Açıkken üst periyodun bir önceki (kesinleşmiş) barı kullanılır; sinyal sonradan değişmez ama onay 1 üst-bar gecikebilir.')

// ─────────────────────────── ERKEN SİNYAL (İNTRABAR) ───────────────────────────
grpER       = 'Erken Sinyal (bar kapanışını beklemeden)'
useEarly    = input.bool(false, 'Erken uyarı gönder ?', group = grpER,
     tooltip = 'Açıkken: sinyal koşulu bar içinde oluşur ve bar ilerlemesi eşiği geçilirse early_mode=1 işaretli bir ÖN UYARI gönderilir. Bar kapanışındaki asıl onay mesajı (early_mode=0) her durumda ayrıca gönderilir. Erken sinyal bar kapanana kadar GEÇERSİZ kalabilir (repaint riski).')
earlyMinPct = input.float(60, 'Minimum bar ilerlemesi (%)', minval = 0, maxval = 95, step = 5, group = grpER,
     tooltip = 'Erken uyarının gönderilebilmesi için barın en az yüzde kaçının tamamlanmış olması gerekir. Örn. 2 saatlik barda 60 = ilk 72 dakika beklenir. Yüksek değer = daha az yanlış erken sinyal.')

// ─────────────────────────── SUPERTREND HESABI (orijinal) ───────────────────────────
atr2 = ta.sma(ta.tr, Periods)
atr  = changeATR ? ta.atr(Periods) : atr2

up  = src - Multiplier * atr
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up

dn  = src + Multiplier * atr
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn

trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend

// ─────────────────────────── EMA'LAR ───────────────────────────
ema5   = ta.ema(close, 5)
ema8   = ta.ema(close, 8)
ema13  = ta.ema(close, 13)
ema34  = ta.ema(close, 34)
ema55  = ta.ema(close, 55)
ema89  = ta.ema(close, ema89Len)
ema200 = ta.ema(close, 200)

emaBull = ema5 > ema8 and ema8 > ema13 and ema13 > ema34 and ema34 > ema55 and ema55 > ema89 and ema89 > ema200
emaBear = ema5 < ema8 and ema8 < ema13 and ema13 < ema34 and ema34 < ema55 and ema55 < ema89 and ema89 < ema200
emaDizilim = emaBull ? 'BULL' : emaBear ? 'BEAR' : 'KARIŞIK'

// EMA konum analizi: fiyatın ALTINDA kalan EMA'lar = dinamik DESTEK, ÜSTÜNDE kalanlar = dinamik DİRENÇ
addKonum(_txt, _name) =>
    _txt == '' ? _name : _txt + '/' + _name

emaDestekTxt = ''
emaDirencTxt = ''
if close > ema5
    emaDestekTxt := addKonum(emaDestekTxt, '5')
else
    emaDirencTxt := addKonum(emaDirencTxt, '5')
if close > ema8
    emaDestekTxt := addKonum(emaDestekTxt, '8')
else
    emaDirencTxt := addKonum(emaDirencTxt, '8')
if close > ema13
    emaDestekTxt := addKonum(emaDestekTxt, '13')
else
    emaDirencTxt := addKonum(emaDirencTxt, '13')
if close > ema34
    emaDestekTxt := addKonum(emaDestekTxt, '34')
else
    emaDirencTxt := addKonum(emaDirencTxt, '34')
if close > ema55
    emaDestekTxt := addKonum(emaDestekTxt, '55')
else
    emaDirencTxt := addKonum(emaDirencTxt, '55')
if close > ema89
    emaDestekTxt := addKonum(emaDestekTxt, '89')
else
    emaDirencTxt := addKonum(emaDirencTxt, '89')
if close > ema200
    emaDestekTxt := addKonum(emaDestekTxt, '200')
else
    emaDirencTxt := addKonum(emaDirencTxt, '200')

emaDestek = emaDestekTxt == '' ? 'YOK' : 'EMA ' + emaDestekTxt
emaDirenc = emaDirencTxt == '' ? 'YOK' : 'EMA ' + emaDirencTxt

// EMA89 eşiği: kapanış, EMA89'un (tolerans kadar) üzerinde mi?
ema89Ok = close > ema89 * (1 + ema89TolPct / 100)

// ─────────────────────────── PARABOLİK SAR ───────────────────────────
sarVal  = ta.sar(sarStart, sarInc, sarMax)
sarBull = close > sarVal
sarText = sarBull ? 'BULL (SAR fiyatın altında)' : 'BEAR (SAR fiyatın üstünde)'

// ─────────────────────────── OSİLATÖRLER & HACİM ───────────────────────────
rsiVal = ta.rsi(close, rsiLen)
mfiVal = ta.mfi(hlc3, mfiLen)

// CMF (Chaikin Money Flow)
adVal  = high == low ? 0.0 : (2 * close - low - high) / (high - low) * volume
cmfVal = math.sum(adVal, cmfLen) / math.sum(volume, cmfLen)

volSma   = ta.sma(volume, volLen)
volRatio = volSma > 0 ? volume / volSma : 0.0
volStars = volRatio >= 3 ? '🚀⭐⭐⭐' : volRatio >= 2 ? '⭐⭐' : volRatio >= 1.2 ? '⭐' : ''

// ─────────────────────────── MTF HESAPLARI ───────────────────────────
// Üst periyottan tek çağrıda tüm gerekli seriler çekilir.
// _idx = 1 → kapanmış (kesinleşmiş) üst periyot barı (repaint önleme)
// _idx = 0 → canlı üst periyot barı (daha hızlı ama bar kapanana kadar değişebilir)
f_htf(_idx, _emaLen, _slopeBars) =>
    _e     = ta.ema(close, _emaLen)
    _slope = _e - _e[_slopeBars]
    _r     = ta.rsi(close, 14)
    [close[_idx], _e[_idx], _slope[_idx], _r[_idx], _r[_idx + 1]]

mtfIdx = mtfUseClosed ? 1 : 0
[c4, e4, s4, r4, r4prev] = request.security(syminfo.tickerid, tf4h, f_htf(mtfIdx, mtfEmaLen, mtfSlopeBars), lookahead = barmerge.lookahead_off)
[cD, eD, sD, rD, rDprev] = request.security(syminfo.tickerid, tfD,  f_htf(mtfIdx, mtfEmaLen, mtfSlopeBars), lookahead = barmerge.lookahead_off)

// 4H ANA ONAY: kapanış EMA üzerinde + eğim yatay/yukarı + (opsiyonel) momentum güçleniyor
mtf4hTrendOk = c4 > e4 and s4 >= 0
mtf4hMomOk   = not mtfMomentum or r4 > 50 or r4 > r4prev
mtf4hOk      = mtf4hTrendOk and mtf4hMomOk
mtf4hDurum   = mtf4hOk ? 'POZITIF' : mtf4hTrendOk ? 'MOMENTUM_ZAYIF' : 'NEGATIF'

// GÜNLÜK DURUM: pozitif / nötr / negatif (negatif = güçlü düşüş → veto)
dailyPos    = cD > eD and sD >= 0
dailyNeg    = cD < eD and sD < 0
gunlukDurum = dailyPos ? 'POZITIF' : dailyNeg ? 'NEGATIF' : 'NOTR'

dailyVetoActive = useDailyVeto and dailyNeg

// ============================================================
// === UZMAN TREND BULUCU (XTL) ================================
// === EWO & XTL indikatöründen birebir entegre edildi =========
// ============================================================

// Kaynak tipini seçme fonksiyonu
get_src(Type) =>
    switch Type
        "VWAP" => ta.vwap
        "Close" => close
        "Open" => open
        "HL2" => hl2
        "HLC3" => hlc3
        "OHLC4" => ohlc4
        "HLCC4" => hlcc4
        "Volume" => _roc = 100 * (close - close[3]) / close[3], (volume / ta.tr) * math.abs(_roc)
        "High" => high
        "Low" => low
        "vwap(Close)" => ta.vwap(close)
        "vwap(Open)" => ta.vwap(open)
        "vwap(High)" => ta.vwap(high)
        "vwap(Low)" => ta.vwap(low)
        "AVG(vwap(H,L))" => math.avg(ta.vwap(high), ta.vwap(low))
        "AVG(vwap(O,C))" => math.avg(ta.vwap(open), ta.vwap(close))
        "OBV" => ta.obv // Denge Hacmi (On Balance Volume)
        "AccDist" => ta.accdist // Toplama Dağıtım (Accumulation Distribution)
        "PVT" => ta.pvt // Fiyat Hacim Trendi (Price Volume Trend)
        "TR" => ta.tr

// Kaufman Uyarlanabilir Hareketli Ortalama - Hızlı ve Yavaş Uçlar
kama(x, t)=>
    fastK = 0.666  // KAMA Hızlı Uç
    slowK = 0.0645 // KAMA Yavaş Uç
    dist   = math.abs(x[0] - x[1])
    signal_x = math.abs(x - x[t])
    noise  = math.sum(dist, t)
    effr   = noise!=0 ? signal_x/noise : 1
    sc     = math.pow(effr*(fastK - slowK) + slowK,2)
    KAma   = x
    KAma   := nz(KAma[1]) + sc*(x - nz(KAma[1]))

// @everget'in Jurik Hareketli Ortalaması
jma(_x, length, power, phase) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5
    beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    alpha = math.pow(beta, power)
    Jma = 0.0
    e0 = 0.0
    e0 := (1 - alpha) * _x + alpha * nz(e0[1])
    e1 = 0.0
    e1 := (_x - e0) * (1 - beta) + beta * nz(e1[1])
    e2 = 0.0
    e2 := (e0 + phaseRatio * e1 - nz(Jma[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    Jma := e2 + nz(Jma[1])

// @Duyck'in ADX Ağırlıklı Hareketli Ortalaması
adx_weighted_ma(_src, _period) =>
    [_diplus, _diminus, _adx] = ta.dmi(17, 14)
    _vol_sum  = 0.0
    _adx_sum  = 0.0
    for i = 0 to _period
        _vol_sum  := _src[i] * _adx[i] + _vol_sum
        _adx_sum  := _adx[i] + _adx_sum 
    _volwma   = _vol_sum / _adx_sum

// COVWMA - @DonovanWall'un Varyasyon Katsayısı Ağırlıklı Hareketli Ortalaması
covwma(a, b) =>
    cov    = ta.stdev(a, b) / ta.sma(a, b)
    cw     = a*cov
    covwma = math.sum(cw, b) / math.sum(cov, b)

// FRAMA - @DonovanWall'un Fraktal Uyarlanabilir Hareketli Ortalaması
frama(a, b) =>
    frama = 0.0
    w = -4.6 // "Katsayı (FRAMA ise)"
    fr_n3 = (ta.highest(high, b) - ta.lowest(low, b))/b
    hd2   = ta.highest(high, b/2)
    ld2   = ta.lowest(low, b/2)
    fr_n2 = (hd2 - ld2)/(b/2)
    fr_n1 = (hd2[b/2] - ld2[b/2])/(b/2)
    dim   = (fr_n1 > 0) and (fr_n2 > 0) and (fr_n3 > 0) ? (math.log(fr_n1 + fr_n2) - math.log(fr_n3))/math.log(2) : 0
    alpha = math.exp(w*(dim - 1))
    sc    = (alpha < 0.01 ? 0.01 : (alpha > 1 ? 1 : alpha))
    frama := ta.cum(1)<=2*b ? a : (a*sc) + nz(frama[1])*(1 - sc)

cti(sm, _x, cd) =>
    di = (sm - 1.0) / 2.0 + 1.0
    c1 = 2 / (di + 1.0)
    c2 = 1 - c1
    c3 = 3.0 * (cd * cd + cd * cd * cd)
    c4 = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
    c5 = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd
    i1 = 0.0
    i2 = 0.0
    i3 = 0.0
    i4 = 0.0
    i5 = 0.0
    i6 = 0.0
    i1 := c1 * _x + c2 * nz(i1[1])
    i2 := c1 * i1 + c2 * nz(i2[1])
    i3 := c1 * i2 + c2 * nz(i3[1])
    i4 := c1 * i3 + c2 * nz(i4[1])
    i5 := c1 * i4 + c2 * nz(i5[1])
    i6 := c1 * i5 + c2 * nz(i6[1])
    bfr = -cd * cd * cd * i6 + c3 * i5 + c4 * i4 + c5 * i3

T3ma(_x, Len) =>
    a = 0.618
    e1 = ta.ema(_x, Len)
    e2 = ta.ema(e1, Len)
    e3 = ta.ema(e2, Len)
    e4 = ta.ema(e3, Len)
    e5 = ta.ema(e4, Len)
    e6 = ta.ema(e5, Len)
    C1 = -a * a * a
    C2 = 3 * a * a + 3 * a * a * a
    C3 = -6 * a * a - 3 * a - 3 * a * a * a
    C4 = 1 + 3 * a + a * a * a + 3 * a * a
    C1 * e6 + C2 * e5 + C3 * e4 + C4 * e3
    
VIDYA(_x, Len) =>
    mom     = ta.change(_x)
    upSum   = math.sum(math.max(mom, 0), Len)
    downSum = math.sum(-math.min(mom, 0), Len)
    out     = (upSum - downSum) / (upSum + downSum)
    cmo     = math.abs(out)
    alpha   = 2 / (Len + 1)
    vidya   = 0.0
    vidya   := _x * alpha * cmo + nz(vidya[1]) * (1 - alpha * cmo)

// ZLEMA: Sıfır Gecikme (Zero Lag)
zema(_src, _len) =>
    alpha = (_len - 1) / 2
    zlema0 = _src + _src - _src[alpha]
    zlemaF = ta.ema(zlema0, _len)

// @glaz'ın RSI Uyarlanabilir EMA'sı
rsi_ema(_x, period) =>
    RsiPeriod = 14
    ema = 0.0
    RSvoltl = math.abs(ta.rsi(close, RsiPeriod)-50)+1.0
    multi   = (5.0+100.0/RsiPeriod) / (0.06+0.92*RSvoltl+0.02*math.pow(RSvoltl,2))
    pdsx    = multi*period
    alpha   = 2.0 /(1.0+pdsx)
    ema     := nz(ema[1])+alpha*(ta.sma(close, period)-nz(ema[1]))

tsf(source, length) =>
    lrc  = ta.linreg(source, length, 0)
    lrc1 = ta.linreg(source, length, 1)
    lrs  = lrc - lrc1
    TSF  = ta.linreg(source, length, 0) + lrs

// VAMA - @allanster'ın Hacim Ayarlı Hareketli Ortalaması
vama(_src,_len,_fct,_rul,_nvb) =>                             // vama(kaynak,uzunluk,faktör,kural,örneklem)
    tvb = 0, tvb := _nvb == 0 ? nz(tvb[1]) + 1 : _nvb         // örneklemde kullanılan toplam hacim çubuğu
    tvs = _nvb == 0 ? ta.cum(volume) : math.sum(volume, _nvb) // örneklemdeki toplam hacim
    v2i = volume / ((tvs / tvb) * _fct)                       // hacmin hacim artışlarına oranı
    wtd = _src*v2i                                            // ağırlıklı fiyatlar
    nmb = 1                                                   // geriye toplanan çubuk sayısını başlat
    wtdSumB = 0.0                                             // geriye toplanan ağırlıklı fiyatları başlat
    v2iSumB = 0.0                                             // geriye toplanan v2i oranlarını başlat
    for i = 1 to _len * 10                                    // uç durum zaman aşımı hatalarını azaltmak için yapay sınır
        strict = _rul ? false : i == _len                     // katı kural
        wtdSumB := wtdSumB + nz(wtd[i-1])
        v2iSumB := v2iSumB + nz(v2i[i-1])
        if v2iSumB >= _len or strict
            break
        nmb := nmb + 1
    vama = (wtdSumB - (v2iSumB - _len) * _src[nmb]) / _len    // hacim ayarlı hareketli ortalama

// Yeni WMA (New WMA)
NWMA(_src, _n1) =>
    fast   = int(_n1 / 2)
    lambda = _n1 / fast
    alpha  = lambda * (_n1 - 1) / (_n1 - lambda)
    ma1    = ta.wma(_src, _n1)
    ma2    = ta.wma(ma1, fast)
    nwma   = (1 + alpha) * ma1 - alpha * ma2

// @RedKTrader'ın RSS_WMA'sı
f_LazyLine(_data, _length) =>
    w1 = 0,     w2 = 0,     w3 = 0
    L1 = 0.0,   L2 = 0.0,   L3 = 0.0
    w = _length / 3

    if _length > 2
        w2 := math.round(w)
        w1 := math.round((_length - w2) / 2)
        w3 := int((_length - w2) / 2)

        L1 := ta.wma(_data, w1)
        L2 := ta.wma(L1, w2)
        L3 := ta.wma(L2, w3)
        
    else
        L3 := _data

// MA Tipi
ma(MAType, MASource, MAPeriod) =>
    switch MAType
        "SMA" => ta.sma(MASource, MAPeriod)
        "LSMA" => ta.linreg(MASource, MAPeriod, 0)
        "EMA" => ta.ema(MASource, MAPeriod)
        "WMA" => ta.wma(MASource, MAPeriod)
        "RMA" => ta.rma(MASource, MAPeriod)
        "HMA" => ta.hma(MASource, MAPeriod)
        "DEMA" => e = ta.ema(MASource, MAPeriod), 2 * e - ta.ema(e, MAPeriod)
        "TEMA" => e = ta.ema(MASource, MAPeriod), 3 * (e - ta.ema(e, MAPeriod)) + ta.ema(ta.ema(e, MAPeriod), MAPeriod)
        "VWMA" => ta.vwma(MASource, MAPeriod)
        "ALMA" => ta.alma(MASource, MAPeriod, .85, 6)
        "SWMA" => ta.swma(MASource)
        "KAMA" => kama(MASource, MAPeriod)
        "Wilder" => wild = MASource, wild := nz(wild[1]) + (MASource - nz(wild[1])) / MAPeriod
        "JMA" => jma(MASource, MAPeriod, 2, 50)
        "DWMA" => ta.wma(ta.wma(MASource, MAPeriod), MAPeriod) // Çift Ağırlıklı Hareketli Ortalama
        "DVWMA" => ta.vwma(ta.vwma(MASource, MAPeriod), MAPeriod) // Çift Hacim Ağırlıklı Hareketli Ortalama
        "ADX MA" => adx_weighted_ma(MASource, MAPeriod)
        "COVWMA" => covwma(MASource, MAPeriod)
        "FRAMA" => frama(MASource, MAPeriod)
        "Tillson T3" => T3ma(MASource, MAPeriod)
        "VIDYA" => VIDYA(MASource, MAPeriod)
        "Zero Lag" => zema(MASource, MAPeriod)
        "CTI" => cti(MAPeriod, MASource, 0)
        "RSI EMA" => rsi_ema(MASource, MAPeriod)
        "TSF" => tsf(MASource, MAPeriod)
        "VAMA" => vama(MASource, MAPeriod, 0.67, true, 0)
        "New-WMA" => NWMA(MASource, MAPeriod)
        "RSS_WMA" => f_LazyLine(MASource, MAPeriod)

//______________________________________________________________________________
// Uzman Trend Bulucu - XTL
//______________________________________________________________________________
// "Double CCI" temel alınmıştır | https://www.tradingview.com/script/4vIRtqeP/
red_orange = #FF4000
sky_blue   = #00BFFF
white      = #FFFFFF

media  = ma(MA_Type2, get_src(src_xtl), period_xtl)
cciNT  = (get_src(src_xtl) - media) / (0.015 * ta.dev(get_src(src_xtl), period_xtl))
cciT   = (get_src(src_xtl) - media) / (0.015 * ta.dev(math.abs(get_src(src_xtl) - media), period_xtl))
values = uTrad ? cciT : cciNT

// TrendGrade sinyal mantığına bağlantı (DEĞİŞMEDİ)
xtlBull = values > fixed_Value
xtlBear = values < -fixed_Value
xtlDurum = xtlBull ? 'BULL' : xtlBear ? 'BEAR' : 'NEUTRAL'

var color color_XTL = na
if (values < -fixed_Value) 
    color_XTL := red_orange // Ayı (Düşüş)
if (-fixed_Value <= values and values <= fixed_Value)
    color_XTL := white // Nötr
if (values > fixed_Value)
    color_XTL := sky_blue // Boğa (Yükseliş)

// XTL eşik kesişim uyarıları (birebir)
cond_bull_xtl = detect_bull and ta.crossover(values, fixed_Value)
cond_bear_xtl = detect_bear and ta.crossunder(values, -fixed_Value)

if cond_bull_xtl
    alert('Sembol = (' + syminfo.tickerid + ') \n Zaman Dilimi = (' + timeframe.period + ') \n Güncel Fiyat (' + str.tostring(close) + ') \n Yükseliş Trendi [XTL].', alert.freq_once_per_bar_close)
if cond_bear_xtl
    alert('Sembol = (' + syminfo.tickerid + ') \n Zaman Dilimi = (' + timeframe.period + ') \n Güncel Fiyat (' + str.tostring(close) + ') \n Düşüş Trendi [XTL].', alert.freq_once_per_bar_close)

barcolor(showXTL ? color_XTL : na, title = 'XTL mum rengi')

// ─────────────────────────── SİNYALLER ───────────────────────────
rawBuy = trend == 1 and trend[1] == -1

// EMA89 eşiğini geçen ham sinyal (MTF vetosu uygulanmadan önce)
preBuy = rawBuy and (not useEma89Filter or ema89Ok)

// GÜNLÜK VETO: günlük güçlü düşüşteyse AL sinyali tamamen engellenir
buySignal = preBuy and not dailyVetoActive
rawSell   = trend == -1 and trend[1] == 1

// GÜÇLÜ AL: XTL BULL + (opsiyonel) 4H MTF onayı. 4H onayı yoksa sinyal NORMAL AL'a düşer.
strongBuy = buySignal and useXTL and xtlBull and (not useMTF4h or mtf4hOk)
normalBuy = buySignal and not strongBuy
sinyalGucu = strongBuy ? 'GÜÇLÜ' : 'NORMAL'

// AL sinyali verilmeden SAT sinyali tetiklenmez (pozisyon takibi)
var bool inPosition = false
sellSignal = rawSell and inPosition
if buySignal
    inPosition := true
if sellSignal
    inPosition := false

// ─────────────────────────── HEDEF / STOP / SKOR ───────────────────────────
stopPrice = up                       // Supertrend alt bandı stop olarak kullanılır
target1   = close + atr * t1AtrMult
target2   = close + atr * t2AtrMult
riskAmt   = close - stopPrice
rrOrani   = riskAmt > 0 ? (target1 - close) / riskAmt : 0.0
beklenti  = (target2 - close) / close * 100

// Basit öncelik skoru (0-100) — şeffaf kural tabanlı, istatistiksel olasılık DEĞİLDİR
score = 0.0
score += rsiVal > 50 and rsiVal < 70 ? 20 : rsiVal >= 70 ? 8 : 5
score += mfiVal > 50 ? 20 : 8
score += volRatio >= 2 ? 20 : volRatio >= 1.5 ? 15 : volRatio >= 1 ? 10 : 4
score += emaBull ? 20 : emaBear ? 0 : 10
score += sarBull ? 10 : 0
score += cmfVal > 0 ? 10 : 0
priority   = math.round(math.min(score, 100))
kaliteMetni = priority >= 80 ? 'YÜKSEK' : priority >= 60 ? 'ORTA' : 'DÜŞÜK'

// ─────────────────────────── GÖRSELLER ───────────────────────────
upPlot = plot(trend == 1 ? up : na, title = 'Up Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.green, 0))
plotshape(buySignal ? up : na, title = 'UpTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.green, 0))
// Normal AL etiketi
plotshape(normalBuy and showsignals ? up : na, title = 'Buy', text = 'Buy', location = location.absolute, style = shape.labelup, size = size.tiny, color = color.new(color.green, 0), textcolor = color.new(color.white, 0))
// GÜÇLÜ AL etiketi (XTL BULL + 4H MTF onaylı) — daha büyük ve lime renkli
plotshape(strongBuy and showsignals ? up : na, title = 'Güçlü Buy (XTL BULL + 4H MTF)', text = 'GÜÇLÜ\nAL', location = location.absolute, style = shape.labelup, size = size.small, color = color.new(color.lime, 0), textcolor = color.new(color.black, 0))
// EMA89 eşiğine takılan ham sinyali gri daire ile göster (bilgi amaçlı)
plotshape(rawBuy and not preBuy and showsignals ? up : na, title = 'Buy (EMA89 filtresine takıldı)', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.gray, 30))
// Günlük veto ile engellenen sinyali turuncu × ile göster (bilgi amaçlı)
plotshape(preBuy and dailyVetoActive and showsignals ? up : na, title = 'Buy (Günlük VETO ile engellendi)', location = location.absolute, style = shape.xcross, size = size.tiny, color = color.new(color.orange, 0))

dnPlot = plot(trend == 1 ? na : dn, title = 'Down Trend', style = plot.style_linebr, linewidth = 2, color = color.new(color.red, 0))
plotshape(sellSignal ? dn : na, title = 'DownTrend Begins', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.red, 0))
plotshape(sellSignal and showsignals ? dn : na, title = 'Sell', text = 'Sell', location = location.absolute, style = shape.labeldown, size = size.tiny, color = color.new(color.red, 0), textcolor = color.new(color.white, 0))
// Öncesinde geçerli AL sinyali olmadığı için bastırılan SAT sinyali (bilgi amaçlı)
plotshape(rawSell and not sellSignal and showsignals ? dn : na, title = 'Sell (AL sinyali yoktu, bastırıldı)', location = location.absolute, style = shape.circle, size = size.tiny, color = color.new(color.gray, 30))

mPlot = plot(ohlc4, title = '', style = plot.style_circles, linewidth = 1, display = display.none)
longFillColor  = highlighting ? trend == 1 ? color.new(color.green, 85) : na : na
shortFillColor = highlighting ? trend == -1 ? color.new(color.red, 85) : na : na
fill(mPlot, upPlot, title = 'UpTrend Highligter', color = longFillColor)
fill(mPlot, dnPlot, title = 'DownTrend Highligter', color = shortFillColor)

plot(showEma89 ? ema89 : na, title = 'EMA 89', color = color.new(color.orange, 0), linewidth = 2)
plot(showEmaSet ? ema5 : na, title = 'EMA 5', color = color.new(color.aqua, 40))
plot(showEmaSet ? ema8 : na, title = 'EMA 8', color = color.new(color.teal, 40))
plot(showEmaSet ? ema13 : na, title = 'EMA 13', color = color.new(color.blue, 40))
plot(showEmaSet ? ema34 : na, title = 'EMA 34', color = color.new(color.purple, 40))
plot(showEmaSet ? ema55 : na, title = 'EMA 55', color = color.new(color.fuchsia, 40))
plot(showEmaSet ? ema200 : na, title = 'EMA 200', color = color.new(color.gray, 20), linewidth = 2)
plot(showSar ? sarVal : na, title = 'Parabolik SAR', style = plot.style_circles, color = color.new(color.yellow, 0))

// ─────────────────────────── SAYI FORMATLAMA ───────────────────────────
f2(x) => str.tostring(x, '#.##')
fP(x) => str.tostring(x, format.mintick)

// ─────────────────────────── DİKKAT ÇEKİCİ İBARELER ───────────────────────────
// Göreceli hacim eşiğin (varsayılan x3) üzerindeyse: HACİM PATLAMASI
hacimPatlama = volRatio >= volXDikkat
// CMF eşiğin (varsayılan 0.15) üzerindeyse: GÜÇLÜ PARA GİRİŞİ
paraGirisiG  = cmfVal >= cmfDikkat

hacimIbare = hacimPatlama ? '🚀🔥 HACİM PATLAMASI x' + f2(volRatio) + ' 🔥🚀' : ''
paraIbare  = paraGirisiG  ? '💰💎 GÜÇLÜ PARA GİRİŞİ 💎💰' : ''

// ─────────────────────────── MAKE.COM İÇİN JSON ALARM (SADECE AL) ───────────────────────────
// Bar ilerlemesi (%) — sadece gerçek zamanlı barda anlamlıdır
barProgress = timeframe.isintraday and time_close > time ? math.min(100.0, math.max(0.0, (timenow - time) / (time_close - time) * 100)) : 100.0

buildJson(_early, _progress) =>
    '{'
     + '"signal":"' + (strongBuy ? 'STRONG_BUY' : 'BUY') + '",'
     + '"sinyal_gucu":"' + sinyalGucu + '",'
     + '"early_mode":"' + (_early ? '1' : '0') + '",'
     + '"bar_progress_pct":"' + f2(_progress) + '",'
     + '"xtl_durum":"' + xtlDurum + '",'
     + '"xtl_deger":"' + f2(values) + '",'
     + '"mtf_4h":"' + mtf4hDurum + '",'
     + '"mtf_4h_ema":"' + fP(e4) + '",'
     + '"mtf_4h_rsi":"' + f2(r4) + '",'
     + '"mtf_gunluk":"' + gunlukDurum + '",'
     + '"mtf_gunluk_ema":"' + fP(eD) + '",'
     + '"symbol":"' + syminfo.ticker + '",'
     + '"exchange":"' + syminfo.prefix + '",'
     + '"timeframe":"' + timeframe.period + '",'
     + '"price":"' + fP(close) + '",'
     + '"target1":"' + fP(target1) + '",'
     + '"target2":"' + fP(target2) + '",'
     + '"stop_price":"' + fP(stopPrice) + '",'
     + '"beklenti_pct":"' + f2(beklenti) + '",'
     + '"rr_orani":"' + f2(rrOrani) + '",'
     + '"priority":"' + str.tostring(priority) + '",'
     + '"kalite":"' + kaliteMetni + '",'
     + '"volume_ratio":"' + f2(volRatio) + '",'
     + '"volume_stars":"' + volStars + '",'
     + '"hacim_dikkat":"' + (hacimPatlama ? '1' : '0') + '",'
     + '"hacim_ibare":"' + hacimIbare + '",'
     + '"para_girisi_dikkat":"' + (paraGirisiG ? '1' : '0') + '",'
     + '"para_girisi_ibare":"' + paraIbare + '",'
     + '"mfi":"' + f2(mfiVal) + '",'
     + '"rsi":"' + f2(rsiVal) + '",'
     + '"cmf":"' + str.tostring(cmfVal, '#.###') + '",'
     + '"ema_dizilim":"' + emaDizilim + '",'
     + '"ema_destek":"' + emaDestek + '",'
     + '"ema_direnc":"' + emaDirenc + '",'
     + '"psar":"' + sarText + '",'
     + '"psar_deger":"' + fP(sarVal) + '",'
     + '"time":"' + str.format_time(time, 'yyyy-MM-dd HH:mm', syminfo.timezone) + '"'
     + '}'

// 1) ERKEN UYARI: bar kapanmadan, ilerleme eşiği geçildiyse (bar başına en fazla 1 kez)
if useEarly and buySignal and barstate.isrealtime and not barstate.isconfirmed and barProgress >= earlyMinPct
    alert(buildJson(true, barProgress), alert.freq_once_per_bar)

// 2) ASIL ONAY: bar kapanışında (her durumda gönderilir)
if buySignal and barstate.isconfirmed
    alert(buildJson(false, 100.0), alert.freq_once_per_bar_close)

// ─────────────────────────── KLASİK ALERTCONDITION'LAR ───────────────────────────
alertcondition(strongBuy, title = 'GÜÇLÜ AL (SuperTrend + EMA89 + XTL BULL + 4H MTF)', message = 'GÜÇLÜ AL: SuperTrend Buy + XTL BULL + 4H MTF onaylı!')
alertcondition(normalBuy, title = 'Normal AL (SuperTrend + EMA89, XTL/MTF onaysız)', message = 'SuperTrend Buy (XTL/MTF onaysız)!')
alertcondition(buySignal, title = 'SuperTrend Buy (EMA89 filtreli + günlük veto - tümü)', message = 'SuperTrend Buy!')
alertcondition(sellSignal, title = 'SuperTrend Sell', message = 'SuperTrend Sell!')
changeCond = trend != trend[1]
alertcondition(changeCond, title = 'SuperTrend Direction Change', message = 'SuperTrend has changed direction!')
````
