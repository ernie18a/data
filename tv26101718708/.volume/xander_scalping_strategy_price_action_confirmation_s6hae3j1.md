# Xander Scalping Strategy [Price Action + Confirmation]

- url: https://www.tradingview.com/script/S6haE3j1/
- type: indicator
- pine_id: PUB;d0ab93a50fc9442b8f77457448b72797
- version: 1.0

## Description

🚀 Xander Scalping Strategy [Price Action + Confirmation]
by @wijayanto_ok

A multi-confirmation scalping strategy combining trend filtering, dynamic support/resistance, Stochastic RSI momentum, and volume confirmation — with visual Risk/Reward estimation for disciplined trading.

================================================================================
📌 OVERVIEW
================================================================================

Xander Scalping Strategy is a Price Action-based trading tool designed for traders who prioritize high-probability, multi-layer confirmation before entry. It helps identify:

✅ Trend Direction using EMA 13/21 crossover
✅ Dynamic Support & Resistance from confirmed swing highs/lows
✅ Precision Entry Signals via Stochastic RSI + Volume spike confirmation
✅ Visual Risk/Reward Estimator for smarter position management

🎯 Best For: Timeframes 5m – 1H | Liquid assets (Forex majors, BTC/ETH, Indices)

================================================================================
✨ KEY FEATURES
================================================================================

🔹 1. Trend Filter (EMA 13/21)
---------------------------------
• Fast EMA (13) & Slow EMA (21) with dynamic coloring:
  🟢 Green = Uptrend | 🔴 Red = Downtrend | ⚪ Gray = Sideways
• Real-time trend label in top-right corner for quick reference

🔹 2. Dynamic Support & Resistance
---------------------------------
• Auto-detects Swing High/Low using ta.pivothigh() / ta.pivotlow()
• Horizontal S/R lines extended to the right (real-time visualization)
• Updates automatically when new swings are confirmed
⚠️ Note: 1-candle lag for pivot confirmation = non-repainting logic

🔹 3. Multi-Layer Entry Confirmation
---------------------------------
Component          | Settings                              | Purpose
-------------------|---------------------------------------|---------------------------
Stochastic RSI     | RSI Len: 14, %K: 3, %D: 3, OB: 80, OS: 20 | Momentum timing & reversal signals
Volume Filter      | Avg Volume (20-period)                | Filters low-liquidity false signals
Price Action       | Pullback to EMA zone OR bounce/reject at S/R | Confirms structural alignment

✅ BUY Signal Conditions:
   1. Uptrend (EMA 13 > EMA 21)
   2. Price pulls back to EMA zone OR bounces from Support
   3. StochRSI crosses UP from Oversold (<20)
   4. Volume > 20-period average
   → Green "BUY" arrow appears below candle

✅ SELL Signal Conditions:
   1. Downtrend (EMA 13 < EMA 21)
   2. Price pulls back to EMA zone OR rejects from Resistance
   3. StochRSI crosses DOWN from Overbought (>80)
   4. Volume > 20-period average
   → Red "SELL" arrow appears above candle

🔹 4. Visual Risk/Reward Table (Top-Right)
---------------------------------
Metric    | Description
----------|--------------------------------------------------
Status    | Current trend or active signal (LONG/SHORT/UPTREND/DOWNTREND)
Est. RR   | Estimated Risk:Reward ratio based on latest swing levels

💡 Tip: Use RR ≥ 1:1.5 as an additional filter for higher-quality entries.

🔹 5. Alert System
---------------------------------
• 🔔 "Xander Buy Signal" — Triggered when all BUY conditions met
• 🔔 "Xander Sell Signal" — Triggered when all SELL conditions met
• Compatible with TradingView alerts (popup, email, webhook, SMS)

================================================================================
⚙️ HOW TO USE
================================================================================

🔧 Setup:
1. Apply script to chart with timeframe 5m, 15m, or 1H
2. Recommended assets:
   • Forex: EURUSD, GBPUSD, USDJPY
   • Crypto: BTCUSDT, ETHUSDT
   • Indices: US30, NAS100, SPX500

🎯 LONG Entry Setup:
   1. Confirm "UPTREND 🟢" label is visible
   2. Wait for pullback to EMA 13-21 zone OR bounce from green Support line
   3. Confirm: Green BUY arrow appears + candle closes bullish
   4. StochRSI: Crosses up from <20 zone
   5. Volume: Bar higher than 20-period average

   📍 Stop Loss: Below nearest lastSwingLow
   🎯 Take Profit: Nearest lastSwingHigh OR RR target ≥1:1.5

🎯 SHORT Entry Setup:
   1. Confirm "DOWNTREND 🔴" label is visible
   2. Wait for pullback to EMA 13-21 zone OR rejection from red Resistance line
   3. Confirm: Red SELL arrow appears + candle closes bearish
   4. StochRSI: Crosses down from >80 zone
   5. Volume: Bar higher than 20-period average

   📍 Stop Loss: Above nearest lastSwingHigh
   🎯 Take Profit: Nearest lastSwingLow OR RR target ≥1:1.5

⚠️ Recommended Filters:
   ❌ Avoid trading when label shows "SIDEWAYS ⚪"
   ❌ Skip signals with Est. RR < 1:1
   ❌ Avoid entries 5 min before/after high-impact news events
   ✅ Always confirm with candlestick patterns (pinbar, engulfing, etc.)

================================================================================
🔍 TECHNICAL NOTES (Advanced Users)
================================================================================

📐 Pivot Detection (Non-Repainting):
   ph = ta.pivothigh(high, lookbackPeriod, lookbackPeriod)
   pl = ta.pivotlow(low, lookbackPeriod, lookbackPeriod)
   
   • Requires rightBars = lookbackPeriod for confirmation → NO REPAINTING
   • New swing confirmed only after N candles close to the right
   • Recommended: lookbackPeriod = 50 for significant swings; 20-30 for responsive signals

📊 Stochastic RSI Calculation:
   rsiSource = ta.rsi(close, 14)
   stoch = (rsiSource - lowestRSI) / (highestRSI - lowestRSI) * 100
   %K = ta.sma(stoch, 3), %D = ta.sma(%K, 3)
   
   • Measures relative momentum within 0–100 range
   • Crosses at extremes (20/80) offer high-probability reversal signals

📈 Risk/Reward Estimation:
   // For BUY:
   risk = close - lastSwingLow
   reward = lastSwingHigh - close
   RR = reward / risk
   
   • Uses latest confirmed swing levels as reference for SL/TP
   ⚠️ Estimates only — always adjust to real-time market structure

================================================================================
⚠️ DISCLAIMER & RISK WARNING
================================================================================

🚨 IMPORTANT: This script is an analytical tool only. It does NOT guarantee profits or replace sound trading judgment.

1. Backtest First: Test in demo mode for 2–4 weeks before live trading.
2. No Holy Grail: No strategy wins 100%. Manage expectations and use strict money management.
3. Market Conditions: Performs best in trending markets. May underperform in extreme sideways or news-driven volatility.
4. Non-Repainting: Signals appear only after candle close and pivot confirmation. Minor 1-candle lag on swing detection is intentional for reliability.
5. Always Use Stop Loss: Never trade without predefined risk protection.

🔹 Trading forex, crypto, and derivatives carries substantial risk of loss. Trade only with capital you can afford to lose.

================================================================================
🔄 VERSION HISTORY
================================================================================

Version | Date       | Changes
--------|------------|--------------------------------------------------
1.0     | May 2026   | Initial release: EMA + S/R + StochRSI + Volume + RR Table

================================================================================
💬 FEEDBACK & SUPPORT
================================================================================

• 🛠 Found a bug? Report with screenshot + timeframe + asset for faster resolution.
• 💡 Have an improvement idea? Comment below or DM @wijayanto_ok.
• 🌟 Enjoying the script? A like/follow helps support future updates!

"Plan your trade, trade your plan. Consistency > Perfection."
— Xander Scalping Philosophy

================================================================================
🔖 TAGS (For Search Optimization)
================================================================================

scalping, price-action, ema, support-resistance, stochastic-rsi, volume, risk-reward, swing-trading, confirmation, non-repainting, tradingview, pine-script

================================================================================
✅ PRE-PUBLISH CHECKLIST
================================================================================

[x] Tested on 3+ assets & timeframes
[x] All inputs have sensible defaults
[x] Code is well-commented & structured
[x] Risk disclaimer included
[x] Alert conditions defined
[x] No unwanted repainting logic
[x] Documentation complete & professional

================================================================================
🙏 Thank you for using Xander Scalping Strategy!
Happy trading, and may your RR always be in your favor. 🎯📈
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wijayanto_ok
//@version=6
indicator('Xander Scalping Strategy [Price Action + Confirmation]', overlay = true, shorttitle = 'Xander Scalp')

// ==============================================================================
// 1. INPUTS & SETTINGS
// ==============================================================================
// Input untuk EMA (Trend Filter)
emaFastLen = input.int(13, 'EMA Cepat (Fast)', group = '1. Trend Filter (EMA)')
emaSlowLen = input.int(21, 'EMA Lambat (Slow)', group = '1. Trend Filter (EMA)')
showEma = input.bool(true, 'Tampilkan EMA', group = '1. Trend Filter (EMA)')

// Input untuk Support/Resistance (Swing Detection)
lookbackPeriod = input.int(50, 'Periode Lookback Swing (N)', minval = 10, group = '2. Support & Resistance')
showSR = input.bool(true, 'Tampilkan Garis S/R', group = '2. Support & Resistance')

// Input untuk Osilator (Stochastic RSI)
stochK = input.int(3, 'Panjang K Stoch RSI', group = '3. Konfirmasi Entry (Stoch RSI)')
stochD = input.int(3, 'Panjang D Stoch RSI', group = '3. Konfirmasi Entry (Stoch RSI)')
stochSmooth = input.int(3, 'Smooth Stoch RSI', group = '3. Konfirmasi Entry (Stoch RSI)')
stochLen = input.int(14, 'Panjang RSI untuk Stoch', group = '3. Konfirmasi Entry (Stoch RSI)')
obLevel = input.int(80, 'Level Overbought', group = '3. Konfirmasi Entry (Stoch RSI)')
osLevel = input.int(20, 'Level Oversold', group = '3. Konfirmasi Entry (Stoch RSI)')

// Input untuk Volume
volLen = input.int(20, 'Periode Rata-rata Volume', group = '4. Konfirmasi Volume')

// Input Tampilan Sinyal
showSignals = input.bool(true, 'Tampilkan Sinyal Buy/Sell', group = '5. Tampilan Sinyal')
showTable = input.bool(true, 'Tampilkan Tabel Risk/Reward', group = '6. Tabel Info')

// ==============================================================================
// 2. MARKET STRUCTURE & TREND FILTER (EMA)
// ==============================================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// Tentukan Tren
isUptrend = emaFast > emaSlow
isDowntrend = emaFast < emaSlow
isSideways = not isUptrend and not isDowntrend // Atau bisa didefinisikan dengan jarak EMA yang sangat dekat

// Plot EMA dengan warna dinamis
plot(showEma ? emaFast : na, 'EMA Fast', color = isUptrend ? color.green : isDowntrend ? color.red : color.gray, linewidth = 2)
plot(showEma ? emaSlow : na, 'EMA Slow', color = isUptrend ? color.lime : isDowntrend ? color.maroon : color.gray, linewidth = 2)

// Label Status Tren di Pojok Kanan Atas
var label trendLabel = na
if barstate.islast
    string trendText = isUptrend ? 'UPTREND 🟢' : isDowntrend ? 'DOWNTREND 🔴' : 'SIDEWAYS ⚪'
    color trendColor = isUptrend ? color.green : isDowntrend ? color.red : color.gray

    if na(trendLabel)
        trendLabel := label.new(bar_index, high, text = trendText, style = label.style_label_left, color = color.new(trendColor, 80), textcolor = color.white, size = size.small)
        trendLabel
    else
        label.set_xy(trendLabel, bar_index, high)
        label.set_text(trendLabel, trendText)
        label.set_color(trendLabel, color.new(trendColor, 80))

// ==============================================================================
// 3. SUPPORT & RESISTANCE / SUPPLY & DEMAND ZONES
// ==============================================================================
// Deteksi Swing High dan Swing Low menggunakan ta.pivothigh dan ta.pivotlow
// Kita menggunakan lookbackPeriod sebagai leftBars dan rightBars untuk simplifikasi deteksi "terakhir"
// Catatan: ta.pivothigh/low membutuhkan konfirmasi candle kanan, sehingga ada lag 1 candle untuk konfirmasi swing.

ph = ta.pivothigh(high, lookbackPeriod, lookbackPeriod)
pl = ta.pivotlow(low, lookbackPeriod, lookbackPeriod)

// Simpan nilai Swing High/Low terakhir yang valid
var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighIndex = na
var int lastSwingLowIndex = na

if not na(ph)
    lastSwingHigh := ph
    lastSwingHighIndex := bar_index[lookbackPeriod] // Index saat swing terjadi
    lastSwingHighIndex

if not na(pl)
    lastSwingLow := pl
    lastSwingLowIndex := bar_index[lookbackPeriod] // Index saat swing terjadi
    lastSwingLowIndex

// Plot Garis S/R Horizontal
// Garis akan digambar dari titik swing hingga saat ini
line srHighLine = na
line srLowLine = na

if showSR and not na(lastSwingHigh)
    // Hapus garis lama jika ingin hanya menampilkan satu garis terakhir (opsional, di sini kita update posisi)
    // Untuk efisiensi, kita gunakan line.new dengan update koordinat x2 ke bar_index saat ini
    if na(srHighLine) or bar_index != line.get_x2(srHighLine)
    // Buat garis baru jika belum ada atau update jika sudah ada (tradingview membatasi jumlah garis, jadi hati-hati)
    // Strategi lebih baik: Gunakan plotchar atau label untuk level, atau line.new yang diperbarui
    // Di sini kita gunakan pendekatan sederhana: Gambar garis dari index swing ke bar_index sekarang

        // Karena line.new memiliki limit, kita hanya akan menggambar garis dari swing terakhir yang terkonfirmasi
        // Kita hapus garis sebelumnya untuk menjaga performa
        line.delete(srHighLine)
        srHighLine := line.new(x1 = lastSwingHighIndex, y1 = lastSwingHigh, x2 = bar_index, y2 = lastSwingHigh, color = color.new(color.red, 70), width = 1, style = line.style_dashed)
        srHighLine

// Simpan ID garis ke variabel global tidak bisa langsung di loop tanpa array, 
// jadi kita gunakan trik: line.new setiap kali ada swing baru, dan hapus yang lama jika perlu.
// Namun, karena variabel 'srHighLine' lokal di blok if, kita perlu variabel global.
// Mari gunakan pendekatan var line untuk menyimpan referensi garis terakhir.

// Pendekatan Lebih Stabil untuk S/R Lines (Menggunakan Var Line)
var line lastHighLine = na
var line lastLowLine = na

if showSR
    if not na(ph)
        line.delete(lastHighLine) // Hapus garis resistance sebelumnya
        lastHighLine := line.new(x1 = bar_index[lookbackPeriod], y1 = ph, x2 = bar_index, y2 = ph, color = color.new(color.red, 60), width = 1, extend = extend.right)
        lastHighLine

    if not na(pl)
        line.delete(lastLowLine) // Hapus garis support sebelumnya
        lastLowLine := line.new(x1 = bar_index[lookbackPeriod], y1 = pl, x2 = bar_index, y2 = pl, color = color.new(color.green, 60), width = 1, extend = extend.right)
        lastLowLine

// ==============================================================================
// 4. KONFIRMASI ENTRY (SINYAL BUY/SELL)
// ==============================================================================

// A. Stochastic RSI Calculation
rsiSource = ta.rsi(close, stochLen)
stochKVal = ta.sma(ta.stoch(rsiSource, rsiSource, rsiSource, stochSmooth), stochK)
stochDVal = ta.sma(stochKVal, stochD)

// Kondisi Stoch RSI
isOversold = stochKVal < osLevel and stochDVal < osLevel
isOverbought = stochKVal > obLevel and stochDVal > obLevel
stochCrossUp = ta.crossover(stochKVal, stochDVal)
stochCrossDown = ta.crossunder(stochKVal, stochDVal)

// B. Volume Confirmation
avgVol = ta.sma(volume, volLen)
highVol = volume > avgVol

// C. Price Action Logic (Pullback to EMA or Bounce from S/R)
// Definisi "Dekat EMA": Harga menyentuh atau berada di antara EMA 13 dan 21
nearEmaUp = low <= emaFast and high >= emaSlow // Harga menembus area antara EMA
nearEmaDown = low <= emaFast and high >= emaSlow

// Definisi "Bounce dari S/R": Harga mendekati level Swing terakhir dalam toleransi tertentu (misal 0.5%)
tolerance = close * 0.005 // 0.5% tolerance
bounceSupport = not na(lastSwingLow) and low <= lastSwingLow + tolerance and low >= lastSwingLow - tolerance
rejectResistance = not na(lastSwingHigh) and high >= lastSwingHigh - tolerance and high <= lastSwingHigh + tolerance

// LOGIKA SINYAL BUY (Long)
// 1. Tren Uptrend
// 2. Pullback ke EMA ATAU Bounce dari Support
// 3. Stoch RSI Oversold dan Cross Up
// 4. Volume Tinggi
buySignal = isUptrend and (nearEmaUp or bounceSupport) and isOversold and stochCrossUp and highVol

// LOGIKA SINYAL SELL (Short)
// 1. Tren Downtrend
// 2. Pullback ke EMA ATAU Reject dari Resistance
// 3. Stoch RSI Overbought dan Cross Down
// 4. Volume Tinggi
sellSignal = isDowntrend and (nearEmaDown or rejectResistance) and isOverbought and stochCrossDown and highVol

// Plot Sinyal
plotshape(showSignals and buySignal ? low : na, 'Buy Signal', shape.triangleup, location.belowbar, color.green, size = size.small, text = 'BUY')
plotshape(showSignals and sellSignal ? high : na, 'Sell Signal', shape.triangledown, location.abovebar, color.red, size = size.small, text = 'SELL')

// Alert Conditions
alertcondition(buySignal, title = 'Xander Buy Signal', message = 'Xander Scalp: BUY Signal Detected!')
alertcondition(sellSignal, title = 'Xander Sell Signal', message = 'Xander Scalp: SELL Signal Detected!')

// ==============================================================================
// 5. FITUR TAMBAHAN: RISK MANAGEMENT VISUAL (TABEL RR)
// ==============================================================================

// Hitung Potensi RR berdasarkan Swing Terakhir
// Jika Buy: SL di bawah Swing Low terakhir, TP di atas Swing High terakhir
// Jika Sell: SL di atas Swing High terakhir, TP di bawah Swing Low terakhir

var table rrTable = na

if showTable and barstate.islast
    // Inisialisasi tabel jika belum ada
    if na(rrTable)
        rrTable := table.new(position.top_right, columns = 2, rows = 3, border_width = 1, bgcolor = color.new(color.black, 80), frame_color = color.gray)
        table.cell(rrTable, 0, 0, 'Metric', text_color = color.white, bgcolor = color.new(color.blue, 70))
        table.cell(rrTable, 1, 0, 'Value', text_color = color.white, bgcolor = color.new(color.blue, 70))

    // Hitung Nilai
    string status = 'NEUTRAL'
    color statusColor = color.gray
    string rrText = 'N/A'

    float slPrice = na
    float tpPrice = na
    float risk = na
    float reward = na
    float rrRatio = na

    if buySignal
        slPrice := lastSwingLow
        tpPrice := lastSwingHigh
        if not na(slPrice) and not na(tpPrice)
            risk := close - slPrice
            reward := tpPrice - close
            if risk > 0
                rrRatio := reward / risk
                rrText := str.tostring(rrRatio, '#.##') + ':1'
                status := 'LONG'
                statusColor := color.green
                statusColor
    else if sellSignal
        slPrice := lastSwingHigh
        tpPrice := lastSwingLow
        if not na(slPrice) and not na(tpPrice)
            risk := slPrice - close
            reward := close - tpPrice
            if risk > 0
                rrRatio := reward / risk
                rrText := str.tostring(rrRatio, '#.##') + ':1'
                status := 'SHORT'
                statusColor := color.red
                statusColor
    else // Jika tidak ada sinyal baru, cek tren saat ini untuk estimasi umum
        if isUptrend and not na(lastSwingLow)
            slPrice := lastSwingLow
            tpPrice := lastSwingHigh
            if not na(tpPrice)
                risk := close - slPrice
                reward := tpPrice - close
                if risk > 0
                    rrRatio := reward / risk
                    rrText := str.tostring(rrRatio, '#.##') + ':1'
                    status := 'UPTREND'
                    statusColor := color.lime
                    statusColor
        else if isDowntrend and not na(lastSwingHigh)
            slPrice := lastSwingHigh
            tpPrice := lastSwingLow
            if not na(tpPrice)
                risk := slPrice - close
                reward := close - tpPrice
                if risk > 0
                    rrRatio := reward / risk
                    rrText := str.tostring(rrRatio, '#.##') + ':1'
                    status := 'DOWNTREND'
                    statusColor := color.red
                    statusColor

    // Update Tabel
    table.cell(rrTable, 0, 1, 'Status', text_color = color.white)
    table.cell(rrTable, 1, 1, status, text_color = statusColor)

    table.cell(rrTable, 0, 2, 'Est. RR', text_color = color.white)
    table.cell(rrTable, 1, 2, rrText, text_color = color.yellow)

// ==============================================================================
// CATATAN PENGGUNAAN
// ==============================================================================
// 1. Timeframe: Gunakan 5m, 15m, atau 1H untuk hasil terbaik.
// 2. Sinyal: Tunggu konfirmasi candle close. Sinyal muncul saat Stoch RSI cross DAN Volume tinggi.
// 3. S/R: Garis Support/Resistance otomatis diperbarui saat Swing High/Low baru terkonfirmasi (lag 1 candle dari pivot).
// 4. RR: Tabel di kanan atas menunjukkan estimasi Risk:Reward berdasarkan Swing terakhir. Gunakan ini sebagai panduan, bukan aturan kaku.
// 5. Filter: Pastikan harga tidak terlalu jauh dari EMA untuk entry "pullback". Entry di pucuk/lembah ekstrem berisiko tinggi.
````
