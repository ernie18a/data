# Sumarna17 Control Plan Trading

- url: https://www.tradingview.com/script/EH5eawdv/
- type: indicator
- pine_id: PUB;702818be24694593879e2c501b5ff981
- version: 1.0

## Description

Sumarna17 Trade Plan Control System 
 Adalah indikator TradingView yang dirancang untuk membantu trader membuat keputusan entry dengan lebih disiplin, terukur, dan terencana. Indikator ini menggabungkan sistem Trade Plan, Risk Reward Manager, Lot Calculator, Checklist Validasi, Smart Execution Panel, Running Trade Management, dan Review Journal dalam satu alat lengkap.
 
Dengan fitur Pre Entry, Running Trade, dan Review Mode, trader bisa mengecek kelayakan setup sebelum entry, mengelola posisi saat trade berjalan, hingga mengevaluasi hasil setelah trade selesai. Cocok untuk trader yang ingin mengurangi entry asal-asalan, menjaga risk management, menghindari overlot, dan membangun kebiasaan trading yang lebih profesional.
 
Fitur utama:
 
- Smart Trade Plan System
 
- RR dan Lot Calculator
 
- Validasi Entry, SL, dan TP
 
- Checklist disiplin sebelum entry
 
- Smart Execution Panel
 
- TP1, TP2, TP3 Scale Out
 
- Break Even, Lock Profit, dan Trailing Helper
 
- Prop Firm Guard
 
- Running Trade Management
 
- Review Journal untuk evaluasi trade
 
Indikator ini cocok untuk trader XAUUSD, Forex, BTCUSD, US100, dan market lainnya yang ingin trading lebih rapi, disiplin, dan tidak emosional.
 
Catatan Pengembangan:
Indikator ini masih terus dikembangkan dan belum sempurna. Setiap fitur dibuat untuk membantu trader lebih disiplin, bukan untuk menjamin profit. Gunakan indikator ini sebagai alat bantu analisis, bukan sebagai pengganti pemahaman market, manajemen risiko, dan kontrol emosi.

Trade with plan, manage with discipline, review with honesty.

## Source Code

````pine
//@version=6
indicator("Sumarna17 Control Plan Trading", shorttitle="Sumarna17 Trade Plan Control System", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// =====================================================================
// SUMARNA17 TRADE PLAN CONTROL SYSTEM
// Versi rapi: RR Manager, Trade Plan, Risk Control, Checklist,
// Discipline, Market Context, Trade Management, Smart Execution Panel.
// =====================================================================


// =====================================================================
// 01. MAIN SETTINGS
// =====================================================================
groupMain = "01. MAIN SETTINGS"
tradeDirection = input.string("BUY", "Arah Trade", options=["BUY", "SELL"], group=groupMain)
visualMode = input.string("Full", "Mode Tampilan", options=["Ultra Clean", "Full", "Journal"], group=groupMain)
workMode = input.string("Pre Entry", "Mode Kerja", options=["Pre Entry", "Running Trade", "Review"], group=groupMain)
dashboardView = input.string("Full Detail", "Compact Dashboard Pro", options=["Full Detail", "Compact", "Execution Only", "Journal Only"], group=groupMain)
setupProfile = input.string("Manual", "Setup Profile Preset", options=["Manual", "Scalping", "Intraday", "Swing", "Prop Firm Safe", "Aggressive"], group=groupMain)

showDashboard = input.bool(true, "Tampilkan Dashboard", group=groupMain)
showFloatingHUD = input.bool(true, "Tampilkan Floating HUD", group=groupMain)
showReviewTable = input.bool(true, "Tampilkan Tabel Auto Review", group=groupMain)
showPriceLabels = input.bool(true, "Tampilkan Label Harga", group=groupMain)
showTradeBox = input.bool(true, "Tampilkan Box Risk Reward", group=groupMain)
showInfoLabel = input.bool(true, "Tampilkan Label Info", group=groupMain)

dashboardPosition = input.string("Kanan Atas", "Posisi Dashboard", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupMain)
hudPosition = input.string("Kiri Atas", "Posisi Floating HUD", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupMain)
reviewTablePosition = input.string("Kanan Bawah", "Posisi Tabel Auto Review", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupMain)

infoLabelPosition = input.string("Atas Candle", "Posisi Label Info", options=["Atas Candle", "Bawah Candle"], group=groupMain)
infoLabelOffsetATR = input.float(1.0, "Jarak Label Info ATR", minval=0.1, step=0.1, group=groupMain)

tableSize = input.string("Kecil", "Ukuran Teks", options=["Mini", "Kecil", "Normal", "Besar"], group=groupMain)
cleanScreenshotMode = input.bool(false, "Clean Screenshot Mode", group=groupMain)
antiOverthinkingMode = input.bool(false, "Anti Overthinking Mode", group=groupMain)
smartPanelOnlyMode = input.bool(false, "Smart Panel Only Mode", group=groupMain)


// =====================================================================
// 02. MANUAL TRADE PLAN
// =====================================================================
groupPrice = "02. MANUAL TRADE PLAN"
entryPrice = input.float(0.0, "Harga Entry", step=0.001, group=groupPrice)
stopLossPrice = input.float(0.0, "Harga Stop Loss", step=0.001, group=groupPrice)
takeProfitPrice = input.float(0.0, "Harga Take Profit Manual", step=0.001, group=groupPrice)


// =====================================================================
// 03. JOURNAL, BIAS, SND, DISCIPLINE
// =====================================================================
groupJournal = "03A. JURNAL"
showJournal = input.bool(true, "Tampilkan Jurnal", group=groupJournal)
journalPair = input.string("XAUUSD", "Pair / Komoditas", group=groupJournal)
journalSession = input.string("London", "Sesi Trading Utama", options=["Asia", "London", "New York", "London+New York"], group=groupJournal)
journalResult = input.string("NONE", "Hasil Eksekusi Sebelumnya", options=["NONE", "WIN", "LOSS", "BE"], group=groupJournal)

groupWorkflow = "03B. WORKFLOW"
sessionBias = input.string("Netral", "Bias Sesi Manual", options=["Netral", "Bullish", "Bearish", "Sideways", "No Trade"], group=groupWorkflow)
entryType = input.string("Manual", "Jenis Entry", options=["Manual", "Pullback", "Breakout", "Rejection", "Liquidity Sweep", "CHoCH Retest", "SnD Retest", "Continuation", "Liquidity Inducement", "SnD Refinement", "SnD Equilibrium", "SnD Fresh", "SnD Mitigation", "SnD HTF", "SnD MTF", "SnD LTF", "SnD Strong", "SnD Extreme", "Market Structure"], group=groupWorkflow)
tradeMistake = input.string("NONE", "Mistake Tracker", options=["NONE", "Entry terlalu cepat", "Tidak tunggu konfirmasi", "SL terlalu dekat", "Melawan trend", "Overlot", "Revenge", "News", "FOMO", "Tidak sesuai plan"], group=groupWorkflow)

groupBias = "03C. HTF / MTF / LTF BIAS"
htfBias = input.string("Netral", "HTF Bias", options=["Netral", "Bullish", "Bearish", "Sideways", "No Trade"], group=groupBias)
mtfBias = input.string("Netral", "MTF Bias", options=["Netral", "Bullish", "Bearish", "Sideways", "No Trade"], group=groupBias)
ltfTrigger = input.string("Belum Valid", "LTF Trigger", options=["Valid", "Belum Valid"], group=groupBias)
useMTFAlignmentFilter = input.bool(true, "Aktifkan Filter HTF/MTF/LTF Alignment", group=groupBias)

groupSnD = "03D. SND ZONE QUALITY"
sndFreshZone = input.bool(false, "SnD Fresh Zone", group=groupSnD)
sndHasInducement = input.bool(false, "Ada Liquidity Inducement", group=groupSnD)
sndLiquiditySweep = input.bool(false, "Ada Liquidity Sweep", group=groupSnD)
sndEquilibriumValid = input.bool(false, "Equilibrium Valid", group=groupSnD)
sndRefinementClear = input.bool(false, "Refinement Jelas", group=groupSnD)
sndMitigationClean = input.bool(false, "Mitigation Belum Penuh", group=groupSnD)
sndAlignedHTF = input.bool(false, "Selaras HTF", group=groupSnD)
sndReactionValid = input.bool(false, "Reaction Candle Valid", group=groupSnD)

groupDiscipline = "03E. DISCIPLINE & STOP MODE"
enableStopTradingMode = input.bool(true, "Aktifkan Stop Trading Mode", group=groupDiscipline)
stopIfQualityBad = input.bool(true, "Stop Jika Quality Buruk", group=groupDiscipline)
stopIfBiasNoTrade = input.bool(true, "Stop Jika Bias No Trade", group=groupDiscipline)
stopIfMistakeDanger = input.bool(true, "Stop Jika Mistake Berbahaya", group=groupDiscipline)
showAutoReviewText = input.bool(true, "Tampilkan Auto Review Text", group=groupDiscipline)


// =====================================================================
// 04. EXECUTION CONTROL, MANAGEMENT, MARKET CONTEXT
// =====================================================================
groupExec = "04A. EXECUTION CONTROL"
enableEntryReadiness = input.bool(true, "Aktifkan Entry Readiness", group=groupExec)
enableRiskHeat = input.bool(true, "Aktifkan Risk Heat Level", group=groupExec)
enableAutoReduceLot = input.bool(true, "Aktifkan Auto Reduce Lot Suggestion", group=groupExec)
planLocked = input.bool(false, "Trade Plan Locked", group=groupExec)
maxPlanDriftPips = input.float(300.0, "Maks Drift Plan Locked Pip/Point", minval=0.1, step=0.1, group=groupExec)
showExecutionControlTable = input.bool(true, "Tampilkan Tabel Execution Control", group=groupExec)
executionControlPosition = input.string("Kiri Bawah", "Posisi Tabel Execution Control", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupExec)

groupMgmt = "04B. TRADE MANAGEMENT"
enableTradeManagement = input.bool(true, "Aktifkan Trade Management", group=groupMgmt)
tradeStateManual = input.string("Waiting Entry", "Trade State Manual", options=["Waiting Entry", "Entry Triggered", "Running", "TP1 Hit", "TP2 Hit", "TP3 Hit", "BE", "Closed", "SL Hit"], group=groupMgmt)
exitQuality = input.string("NONE", "Exit Quality Review", options=["NONE", "Exit sesuai plan", "Close terlalu cepat", "Tidak ambil TP", "Geser SL tanpa alasan", "Profit jadi loss", "Entry benar exit salah"], group=groupMgmt)
lessonTag = input.string("NONE", "Lesson Tag", options=["NONE", "Sabar tunggu setup", "Jangan entry saat news", "Jangan overlot", "Jangan FOMO", "Ikuti plan", "Tunggu LTF trigger", "Validasi HTF dulu"], group=groupMgmt)
showTradeManagementTable = input.bool(true, "Tampilkan Tabel Trade Management", group=groupMgmt)
tradeManagementPosition = input.string("Tengah Bawah", "Posisi Tabel Trade Management", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupMgmt)
enableInvalidationWarning = input.bool(true, "Aktifkan Invalidation Warning", group=groupMgmt)
invalidCurrentRR = input.float(-0.7, "Invalid Jika Current RR di Bawah", step=0.1, group=groupMgmt)
invalidEntryNearTPPercent = input.float(70.0, "Invalid Jika Harga Sudah % Menuju TP Sebelum Entry", minval=1, maxval=100, step=1, group=groupMgmt)

groupMarket = "04C. MARKET CONTEXT"
enableMarketContext = input.bool(true, "Aktifkan Market Context", group=groupMarket)
marketCondition = input.string("Trending", "Market Condition", options=["Trending", "Ranging", "Choppy", "News Risk", "Manipulation Phase", "Distribution", "Accumulation"], group=groupMarket)
entryModelPreset = input.string("SnD Rejection", "Entry Model Preset", options=["SnD Rejection", "SnD Mitigation", "Liquidity Sweep + CHoCH", "Inducement + SnD", "Continuation Pullback", "Breakout Retest", "Counter Trend Scalp", "Manual"], group=groupMarket)
enableBestEntryZone = input.bool(false, "Aktifkan Best Entry Zone Manual", group=groupMarket)
bestEntryZoneTop = input.float(0.0, "Best Entry Zone Atas", step=0.001, group=groupMarket)
bestEntryZoneBottom = input.float(0.0, "Best Entry Zone Bawah", step=0.001, group=groupMarket)
showBestEntryZone = input.bool(true, "Tampilkan Box Best Entry Zone", group=groupMarket)
showCommandCenter = input.bool(true, "Tampilkan Smart Command Center", group=groupMarket)
commandCenterPosition = input.string("Tengah Atas", "Posisi Smart Command Center", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupMarket)

groupLiquidity = "04D. LIQUIDITY CONTEXT"
liqEqualHighLow = input.bool(false, "Equal High / Equal Low", group=groupLiquidity)
liqBuySide = input.bool(false, "Buy Side Liquidity", group=groupLiquidity)
liqSellSide = input.bool(false, "Sell Side Liquidity", group=groupLiquidity)
liqGrab = input.bool(false, "Liquidity Grab", group=groupLiquidity)
liqStopHunt = input.bool(false, "Stop Hunt", group=groupLiquidity)
liqInternal = input.bool(false, "Internal Liquidity", group=groupLiquidity)
liqExternal = input.bool(false, "External Liquidity", group=groupLiquidity)

groupViolation = "04E. RULE VIOLATION TRACKER"
enableRuleViolationTracker = input.bool(true, "Aktifkan Rule Violation Tracker", group=groupViolation)
rvEntryNoTrigger = input.bool(false, "Entry tanpa trigger", group=groupViolation)
rvEntryNews = input.bool(false, "Entry saat news", group=groupViolation)
rvOverlot = input.bool(false, "Overlot", group=groupViolation)
rvNoSL = input.bool(false, "Tidak pasang SL", group=groupViolation)
rvMoveSLRandom = input.bool(false, "Geser SL sembarang", group=groupViolation)
rvCloseNotPlan = input.bool(false, "Close tidak sesuai plan", group=groupViolation)
rvRevengeEntry = input.bool(false, "Revenge entry", group=groupViolation)
maxRuleViolationAllowed = input.int(1, "Maks Rule Violation Sebelum Stop", minval=0, maxval=7, group=groupViolation)

groupSmart = "04F. SMART EXECUTION PANEL"
enableSmartExecutionPanel = input.bool(true, "Aktifkan Smart Execution Panel", group=groupSmart)
smartExecutionPosition = input.string("Kanan Tengah", "Posisi Smart Execution Panel", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupSmart)
smartExecutionSize = input.string("Compact", "Mode Panel", options=["Compact", "Detail"], group=groupSmart)
enableEntryPermissionSystem = input.bool(true, "Aktifkan Entry Permission System", group=groupSmart)
enableAutoConflictDetector = input.bool(true, "Aktifkan Auto Conflict Detector", group=groupSmart)
enableDisciplineLock = input.bool(true, "Aktifkan Discipline Lock", group=groupSmart)
showScreenshotJournalSummary = input.bool(false, "Tampilkan Screenshot Journal Summary", group=groupSmart)
journalSummaryPosition = input.string("Kiri Tengah", "Posisi Screenshot Journal Summary", options=["Kanan Atas", "Kanan Tengah", "Kanan Bawah", "Kiri Atas", "Kiri Tengah", "Kiri Bawah", "Tengah Atas", "Tengah", "Tengah Bawah"], group=groupSmart)


// =====================================================================
// 05. ASSET PRESET + LOT CALCULATOR
// =====================================================================
groupLot = "05. ASSET PRESET + LOT CALCULATOR"
assetPreset = input.string("XAUUSD", "Preset Aset", options=["XAUUSD", "BTCUSD", "US100", "USDJPY", "Forex 5 Digit", "Forex 3 Digit", "Forex Major", "Manual"], group=groupLot)
accountBalance = input.float(10000.0, "Saldo Akun", minval=0, step=1, group=groupLot)
riskMode = input.string("Percent", "Mode Risk", options=["Percent", "Fixed Money"], group=groupLot)
riskPercent = input.float(1.0, "Risk %", minval=0.01, step=0.01, group=groupLot)
fixedRiskMoney = input.float(100.0, "Fixed Risk Money", minval=0.01, step=1, group=groupLot)
currencyName = input.string("USD", "Mata Uang", options=["USD", "IDR", "EUR", "Custom"], group=groupLot)
customCurrencyName = input.string("USD", "Custom Mata Uang", group=groupLot)
manualPipSize = input.float(0.01, "Manual Pip Size", minval=0.00001, step=0.00001, group=groupLot)
manualPipValuePerLot = input.float(1.0, "Manual Pip Value / Lot", minval=0.0001, step=0.01, group=groupLot)
maxLotAllowed = input.float(100.0, "Maksimal Lot", minval=0.01, step=0.01, group=groupLot)


// =====================================================================
// 06. TP AUTO RR, SCALE OUT, MANAGED SL
// =====================================================================
groupRR = "06A. TP AUTO RR"
useAutoTP = input.bool(false, "Aktifkan TP Otomatis RR", group=groupRR)
rrTargetMode = input.string("Manual", "Target Model RR", options=["1:2", "1:3", "1:4", "1:5", "Manual"], group=groupRR)
mainRR = input.float(2.0, "RR TP Utama Manual", minval=0.1, step=0.1, group=groupRR)
minRRAllowed = input.float(1.5, "Minimal RR Layak", minval=0.1, step=0.1, group=groupRR)
showAutoTPReference = input.bool(true, "Tampilkan Referensi TP Auto Saat Mode Manual", group=groupRR)

groupScale = "06B. SCALE OUT SYSTEM"
enableScaleOut = input.bool(true, "Aktifkan Scale Out TP1 TP2 TP3", group=groupScale)
tp1RR = input.float(1.0, "TP1 RR", minval=0.1, step=0.1, group=groupScale)
tp1ClosePercent = input.float(40.0, "Close % TP1", minval=0, maxval=100, step=1, group=groupScale)
tp2RR = input.float(2.0, "TP2 RR", minval=0.1, step=0.1, group=groupScale)
tp2ClosePercent = input.float(30.0, "Close % TP2", minval=0, maxval=100, step=1, group=groupScale)
tp3RR = input.float(3.0, "TP3 RR", minval=0.1, step=0.1, group=groupScale)
tp3ClosePercent = input.float(30.0, "Close % TP3 / Runner", minval=0, maxval=100, step=1, group=groupScale)
showScaleOutLines = input.bool(true, "Tampilkan Garis Scale Out", group=groupScale)
showScaleOutProgress = input.bool(true, "Tampilkan Progress Scale Out", group=groupScale)

groupSL = "06C. MANAGED SL"
enableManagedSL = input.bool(true, "Aktifkan Managed SL", group=groupSL)
beMode = input.string("After TP1", "Mode Break Even", options=["After TP1", "Manual RR", "Off"], group=groupSL)
manualBE_RR = input.float(1.0, "Manual BE Trigger RR", minval=0.1, step=0.1, group=groupSL)
beOffsetPips = input.float(0.0, "BE Offset Pip/Point", minval=0, step=0.1, group=groupSL)
lockAfterTP2_RR = input.float(1.0, "Lock Profit Setelah TP2 RR", minval=0, step=0.1, group=groupSL)
lockAfterTP3_RR = input.float(2.0, "Lock Profit Setelah TP3 RR", minval=0, step=0.1, group=groupSL)
enableTrailing = input.bool(true, "Aktifkan Trailing Helper", group=groupSL)
trailingMode = input.string("Smart", "Mode Trailing", options=["Smart", "ATR", "RR Step", "Manual Point", "Off"], group=groupSL)
atrLen = input.int(14, "ATR Length", minval=1, group=groupSL)
atrMult = input.float(1.5, "ATR Multiplier", minval=0.1, step=0.1, group=groupSL)
rrStepTrail = input.float(0.5, "RR Step Trail", minval=0.1, step=0.1, group=groupSL)
manualTrailPoint = input.float(10.0, "Manual Trail Point", minval=0.0001, step=0.1, group=groupSL)


// =====================================================================
// 07. PROP GUARD + VALIDATION + VISUAL
// =====================================================================
groupProp = "07A. PROP FIRM GUARD PRO"
enablePropGuard = input.bool(true, "Aktifkan Prop Firm Guard", group=groupProp)
maxDailyLossPercent = input.float(5.0, "Max Daily Loss %", minval=0.1, step=0.1, group=groupProp)
maxTotalLossPercent = input.float(10.0, "Max Total Loss %", minval=0.1, step=0.1, group=groupProp)
dailyLossUsedMoney = input.float(0.0, "Loss Harian Terpakai", minval=0.0, step=1, group=groupProp)
totalDrawdownUsedMoney = input.float(0.0, "Drawdown Total Terpakai", minval=0.0, step=1, group=groupProp)
dailyProfitTargetMoney = input.float(0.0, "Target Profit Harian", minval=0.0, step=1, group=groupProp)
maxTradesPerDay = input.int(5, "Batas Trade Harian", minval=1, maxval=100, group=groupProp)
tradesTakenToday = input.int(0, "Jumlah Trade Hari Ini", minval=0, maxval=100, group=groupProp)
consecutiveLosses = input.int(0, "Loss Beruntun", minval=0, maxval=20, group=groupProp)
maxConsecutiveLosses = input.int(2, "Batas Loss Beruntun", minval=1, maxval=20, group=groupProp)

groupVal = "07B. VALIDATION"
enableDirectionValidation = input.bool(true, "Validasi Arah BUY/SELL", group=groupVal)
enableRRValidation = input.bool(true, "Validasi Minimal RR", group=groupVal)
maxRiskPercentAllowed = input.float(2.0, "Maks Risk % per Trade", minval=0.01, step=0.01, group=groupVal)
minSLPipsAllowed = input.float(1.0, "Min SL Pip/Point", minval=0, step=0.1, group=groupVal)
maxSLPipsAllowed = input.float(1000.0, "Maks SL Pip/Point", minval=0.1, step=0.1, group=groupVal)
warnEntryDistance = input.bool(true, "Warning Entry Jauh dari Harga Sekarang", group=groupVal)
maxEntryDistancePips = input.float(500.0, "Maks Jarak Entry dari Harga Sekarang", minval=0.1, step=0.1, group=groupVal)

groupVisual = "07C. VISUAL STYLE"
lineBarsLeft = input.int(50, "Panjang Garis Kiri", minval=1, maxval=1000, group=groupVisual)
lineBarsRight = input.int(100, "Panjang Garis Kanan", minval=1, maxval=1000, group=groupVisual)
lineWidth = input.int(2, "Ketebalan Garis", minval=1, maxval=5, group=groupVisual)
riskBoxTransparency = input.int(86, "Transparansi Risk Box", minval=0, maxval=100, group=groupVisual)
rewardBoxTransparency = input.int(88, "Transparansi Reward Box", minval=0, maxval=100, group=groupVisual)


// =====================================================================
// 08. CATATAN, KEPUTUSAN, CHECKLIST
// =====================================================================
groupNote = "08A. CATATAN & ALASAN TRADE"
showTradeNotes = input.bool(true, "Tampilkan Catatan di Dashboard", group=groupNote)
tradeReason = input.text_area("", "Alasan Entry", group=groupNote)
tradeNote = input.text_area("", "Catatan Trade", group=groupNote)

groupDecision = "08B. SISTEM KEPUTUSAN"
decisionMode = input.string("Flexible", "Mode Keputusan", options=["Strict", "Flexible"], group=groupDecision)
bestSetupOnly = input.bool(false, "Hanya Setup Terbaik", group=groupDecision)
manualMinProbability = input.int(70, "Probabilitas Dasar (%)", minval=0, maxval=100, group=groupDecision)
useRRFatalFilter = input.bool(true, "Blokir Jika RR Tidak Valid", group=groupDecision)
useDirectionFatalFilter = input.bool(true, "Blokir Jika Susunan Entry/SL/TP Salah", group=groupDecision)
useDailyLossAutoBlock = input.bool(true, "Auto Blokir Jika Loss Harian >= 2", group=groupDecision)

groupC1 = "08C. STRATEGI FILTER"
c1 = input.bool(false, "1. Berada Pada Jam Sesi Aktif Anda", group=groupC1)
c2 = input.bool(false, "2. Bersih/Bebas Dari Rilis News High Impact", group=groupC1)
c3 = input.bool(false, "3. Arah Searah Struktur Tren Utama", group=groupC1)
c4 = input.bool(false, "4. Harga Berada di Area Premium / Discount Valid", group=groupC1)
c5 = input.bool(false, "5. Berada di POI Fresh", group=groupC1)

groupC2 = "08D. TRIGGERS & KONFIRMASI ENTRY"
c6 = input.bool(false, "6. Terjadi Extreme Liquidity Sweep", group=groupC2)
c7 = input.bool(false, "7. Struktur CHoCH Valid Terbentuk", group=groupC2)
c8 = input.bool(false, "8. Terbentuk Zona Supply / Demand Baru", group=groupC2)
c9 = input.bool(false, "9. Zona SnD Sesuai Rule Equilibrium", group=groupC2)

groupC3 = "08E. RISK MANAGEMENT CHECKLIST"
c10 = input.bool(false, "10. Ukuran Lot Sudah Sesuai Risiko", group=groupC3)
c11 = input.bool(false, "11. Jarak SL dan TP Masuk Akal", group=groupC3)
c12 = input.bool(false, "12. Belum Menyentuh Batas 2x SL Harian", group=groupC3)

groupC4 = "08F. PSYCHOLOGY & MINDSET CHECKLIST"
c13 = input.bool(false, "13. Psikologis Tenang dan Fokus", group=groupC4)
c14 = input.bool(false, "14. No Revenge Trading", group=groupC4)
c15 = input.bool(false, "15. Ikhlas Menerima Hasil Trade", group=groupC4)


// =====================================================================
// HELPER FUNCTIONS
// =====================================================================
f_table_size() =>
    tableSize == "Mini" ? size.tiny : tableSize == "Kecil" ? size.small : tableSize == "Normal" ? size.normal : size.large

f_pos(pos) =>
    pos == "Kanan Atas" ? position.top_right :
     pos == "Kanan Tengah" ? position.middle_right :
     pos == "Kanan Bawah" ? position.bottom_right :
     pos == "Kiri Atas" ? position.top_left :
     pos == "Kiri Tengah" ? position.middle_left :
     pos == "Kiri Bawah" ? position.bottom_left :
     pos == "Tengah Atas" ? position.top_center :
     pos == "Tengah" ? position.middle_center :
     position.bottom_center

f_num(x) =>
    na(x) ? "-" : str.tostring(x, "#.##")

f_price(x) =>
    na(x) ? "-" : str.tostring(x, format.mintick)

f_ccy() =>
    currencyName == "Custom" ? customCurrencyName : currencyName

f_bg() =>
    color.new(color.black, 20)

f_ok(ok) =>
    ok ? color.green : color.red

f_status_bg(txt) =>
    txt == "ENTRY DIIZINKAN" ? color.green : txt == "TUNGGU SETUP" ? color.orange : color.red

f_review_pos() =>
    sameWithDash = reviewTablePosition == dashboardPosition
    sameWithHud = reviewTablePosition == hudPosition
    autoMove = sameWithDash or sameWithHud
    autoMove ? position.bottom_left : f_pos(reviewTablePosition)


// =====================================================================
// CORE CALCULATION
// =====================================================================
txtSize = f_table_size()
isBuy = tradeDirection == "BUY"
ccy = f_ccy()
atr = ta.atr(atrLen)

rrTarget = rrTargetMode == "1:2" ? 2.0 : rrTargetMode == "1:3" ? 3.0 : rrTargetMode == "1:4" ? 4.0 : rrTargetMode == "1:5" ? 5.0 : mainRR

profileMinRR = setupProfile == "Scalping" ? 1.2 : setupProfile == "Intraday" ? 1.5 : setupProfile == "Swing" ? 2.0 : setupProfile == "Prop Firm Safe" ? 2.0 : setupProfile == "Aggressive" ? 1.0 : minRRAllowed
profileMaxRisk = setupProfile == "Scalping" ? 1.0 : setupProfile == "Intraday" ? 1.5 : setupProfile == "Swing" ? 2.0 : setupProfile == "Prop Firm Safe" ? 1.0 : setupProfile == "Aggressive" ? maxRiskPercentAllowed : maxRiskPercentAllowed
effectiveMinRRAllowed = setupProfile == "Manual" ? minRRAllowed : profileMinRR
effectiveMaxRiskAllowed = setupProfile == "Manual" ? maxRiskPercentAllowed : profileMaxRisk

pipSize = manualPipSize
pipValuePerLot = manualPipValuePerLot
contractSize = 1.0

if assetPreset == "XAUUSD"
    pipSize := 0.01
    pipValuePerLot := 1.0
else if assetPreset == "USDJPY"
    pipSize := 0.01
    contractSize := 100000.0
else if assetPreset == "US100"
    contractSize := 1.0
else if assetPreset == "Forex 5 Digit"
    pipSize := 0.0001
    pipValuePerLot := 10.0
else if assetPreset == "Forex 3 Digit"
    pipSize := 0.01
    pipValuePerLot := 10.0
else if assetPreset == "Forex Major"
    pipSize := 0.0001
    pipValuePerLot := 10.0

validEntrySL = entryPrice > 0 and stopLossPrice > 0
slDistance = validEntrySL ? math.abs(entryPrice - stopLossPrice) : na
autoTP = validEntrySL ? (isBuy ? entryPrice + slDistance * rrTarget : entryPrice - slDistance * rrTarget) : na
activeTP = useAutoTP and validEntrySL ? autoTP : takeProfitPrice
validTP = activeTP > 0
validFull = validEntrySL and validTP
tpDistance = validFull ? math.abs(activeTP - entryPrice) : na
actualRR = validFull and slDistance > 0 ? tpDistance / slDistance : na
rrDisplay = na(actualRR) ? "-" : "1:" + str.tostring(actualRR, "#.##")

validBuyStructure = validFull and stopLossPrice < entryPrice and activeTP > entryPrice
validSellStructure = validFull and stopLossPrice > entryPrice and activeTP < entryPrice
validDirection = enableDirectionValidation ? (isBuy ? validBuyStructure : validSellStructure) : true
validRR = enableRRValidation ? (not na(actualRR) and actualRR >= effectiveMinRRAllowed) : true

slPips = validEntrySL and pipSize > 0 ? slDistance / pipSize : na
tpPips = validFull and pipSize > 0 ? tpDistance / pipSize : na
entryDistancePips = validEntrySL and pipSize > 0 ? math.abs(close - entryPrice) / pipSize : na
entryDistanceOk = not warnEntryDistance or not validEntrySL or (not na(entryDistancePips) and entryDistancePips <= maxEntryDistancePips)

riskAmount = riskMode == "Percent" ? accountBalance * riskPercent / 100.0 : fixedRiskMoney
effectiveRiskPercent = accountBalance > 0 ? riskAmount / accountBalance * 100.0 : na

float recommendedLot = na
float estimatedLoss = na
float estimatedProfit = na
float valuePerLotSL = na
float valuePerLotTP = na

if validEntrySL and slDistance > 0
    if assetPreset == "BTCUSD"
        valuePerLotSL := slDistance
        valuePerLotTP := validFull ? tpDistance : na
        recommendedLot := math.round((riskAmount / slDistance) * 100) / 100
        estimatedLoss := slDistance * recommendedLot
        estimatedProfit := validFull ? tpDistance * recommendedLot : na
    else if assetPreset == "USDJPY"
        valuePerLotSL := stopLossPrice > 0 ? (slDistance * contractSize) / stopLossPrice : na
        valuePerLotTP := validFull and activeTP > 0 ? (tpDistance * contractSize) / activeTP : na
        if not na(valuePerLotSL) and valuePerLotSL > 0
            recommendedLot := math.round((riskAmount / valuePerLotSL) * 100) / 100
            estimatedLoss := valuePerLotSL * recommendedLot
            estimatedProfit := validFull and not na(valuePerLotTP) ? valuePerLotTP * recommendedLot : na
    else if assetPreset == "US100"
        valuePerLotSL := slDistance * contractSize
        valuePerLotTP := validFull ? tpDistance * contractSize : na
        if valuePerLotSL > 0
            recommendedLot := math.floor((riskAmount / valuePerLotSL) * 100) / 100
            estimatedLoss := valuePerLotSL * recommendedLot
            estimatedProfit := validFull ? valuePerLotTP * recommendedLot : na
    else
        valuePerLotSL := not na(slPips) ? slPips * pipValuePerLot : na
        valuePerLotTP := not na(tpPips) ? tpPips * pipValuePerLot : na
        if not na(valuePerLotSL) and valuePerLotSL > 0
            recommendedLot := math.round((riskAmount / valuePerLotSL) * 100) / 100
            estimatedLoss := valuePerLotSL * recommendedLot
            estimatedProfit := validFull and not na(valuePerLotTP) ? valuePerLotTP * recommendedLot : na

lotOk = not na(recommendedLot) and recommendedLot <= maxLotAllowed
riskOk = not na(effectiveRiskPercent) and effectiveRiskPercent <= effectiveMaxRiskAllowed
slMinOk = not validEntrySL or (not na(slPips) and slPips >= minSLPipsAllowed)
slMaxOk = not validEntrySL or (not na(slPips) and slPips <= maxSLPipsAllowed)


// =====================================================================
// SCALE OUT + MANAGED SL
// =====================================================================
tp1 = validEntrySL ? (isBuy ? entryPrice + slDistance * tp1RR : entryPrice - slDistance * tp1RR) : na
tp2 = validEntrySL ? (isBuy ? entryPrice + slDistance * tp2RR : entryPrice - slDistance * tp2RR) : na
tp3 = validEntrySL ? (isBuy ? entryPrice + slDistance * tp3RR : entryPrice - slDistance * tp3RR) : na

tp1Hit = enableScaleOut and validEntrySL and (isBuy ? high >= tp1 : low <= tp1)
tp2Hit = enableScaleOut and validEntrySL and (isBuy ? high >= tp2 : low <= tp2)
tp3Hit = enableScaleOut and validEntrySL and (isBuy ? high >= tp3 : low <= tp3)
tpMainHit = validFull and (isBuy ? high >= activeTP : low <= activeTP)
slHit = validEntrySL and (isBuy ? low <= stopLossPrice : high >= stopLossPrice)

currentRR = validEntrySL and slDistance > 0 ? (isBuy ? (close - entryPrice) / slDistance : (entryPrice - close) / slDistance) : na

tpCloseTotal = tp1ClosePercent + tp2ClosePercent + tp3ClosePercent
tpPercentOk = not enableScaleOut or math.abs(tpCloseTotal - 100.0) <= 0.01

tp1Money = not na(valuePerLotSL) and not na(recommendedLot) ? valuePerLotSL * recommendedLot * tp1RR * (tp1ClosePercent / 100.0) : na
tp2Money = not na(valuePerLotSL) and not na(recommendedLot) ? valuePerLotSL * recommendedLot * tp2RR * (tp2ClosePercent / 100.0) : na
tp3Money = not na(valuePerLotSL) and not na(recommendedLot) ? valuePerLotSL * recommendedLot * tp3RR * (tp3ClosePercent / 100.0) : na
totalPlanProfit = nz(tp1Money) + nz(tp2Money) + nz(tp3Money)

remainingPosition = 100.0
remainingPosition -= tp1Hit ? tp1ClosePercent : 0
remainingPosition -= tp2Hit ? tp2ClosePercent : 0
remainingPosition -= tp3Hit ? tp3ClosePercent : 0
remainingPosition := math.max(0, remainingPosition)

scaleProgress = tp3Hit ? 100 : tp2Hit ? tp1ClosePercent + tp2ClosePercent : tp1Hit ? tp1ClosePercent : 0

beOffsetPrice = beOffsetPips * pipSize
beManualTriggerPrice = validEntrySL ? (isBuy ? entryPrice + slDistance * manualBE_RR : entryPrice - slDistance * manualBE_RR) : na
beManualHit = validEntrySL and (isBuy ? high >= beManualTriggerPrice : low <= beManualTriggerPrice)
beTriggerHit = enableManagedSL and (beMode == "After TP1" ? tp1Hit : beMode == "Manual RR" ? beManualHit : false)

bePrice = validEntrySL ? (isBuy ? entryPrice + beOffsetPrice : entryPrice - beOffsetPrice) : na
lockTP2 = validEntrySL ? (isBuy ? entryPrice + slDistance * lockAfterTP2_RR : entryPrice - slDistance * lockAfterTP2_RR) : na
lockTP3 = validEntrySL ? (isBuy ? entryPrice + slDistance * lockAfterTP3_RR : entryPrice - slDistance * lockAfterTP3_RR) : na

managedSL = stopLossPrice
managedText = "ORIGINAL SL"

if beTriggerHit
    managedSL := bePrice
    managedText := "MOVE TO BE"
if enableManagedSL and tp2Hit
    managedSL := lockTP2
    managedText := "LOCK PROFIT TP2"
if enableManagedSL and tp3Hit
    managedSL := lockTP3
    managedText := "LOCK PROFIT TP3"

trailATR = validEntrySL ? (isBuy ? close - atr * atrMult : close + atr * atrMult) : na
trailRRStepDist = validEntrySL and not na(currentRR) ? math.floor(math.max(currentRR, 0) / rrStepTrail) * rrStepTrail * slDistance : na
trailRRStep = validEntrySL and not na(trailRRStepDist) ? (isBuy ? entryPrice + trailRRStepDist - slDistance : entryPrice - trailRRStepDist + slDistance) : na
trailManual = validEntrySL ? (isBuy ? close - manualTrailPoint : close + manualTrailPoint) : na
trailSmart = validEntrySL ? (isBuy ? math.max(nz(trailATR, stopLossPrice), nz(trailRRStep, stopLossPrice), managedSL) : math.min(nz(trailATR, stopLossPrice), nz(trailRRStep, stopLossPrice), managedSL)) : na

trailPrice = trailingMode == "Smart" ? trailSmart : trailingMode == "ATR" ? trailATR : trailingMode == "RR Step" ? trailRRStep : trailingMode == "Manual Point" ? trailManual : na
trailActive = enableTrailing and trailingMode != "Off" and not na(trailPrice)


// =====================================================================
// PROP GUARD + CHECKLIST SCORING
// =====================================================================
dailyLimit = accountBalance * maxDailyLossPercent / 100.0
totalLimit = accountBalance * maxTotalLossPercent / 100.0
dailyAfter = dailyLossUsedMoney + riskAmount
totalAfter = totalDrawdownUsedMoney + riskAmount

dailyGuardOk = not enablePropGuard or dailyAfter <= dailyLimit
totalGuardOk = not enablePropGuard or totalAfter <= totalLimit
tradeCountOk = not enablePropGuard or tradesTakenToday < maxTradesPerDay
lossStreakOk = not enablePropGuard or consecutiveLosses < maxConsecutiveLosses
propGuardOk = dailyGuardOk and totalGuardOk and tradeCountOk and lossStreakOk
profitTargetProgress = dailyProfitTargetMoney > 0 ? totalPlanProfit / dailyProfitTargetMoney * 100.0 : na

biasAligned = sessionBias == "Netral" or (sessionBias == "Bullish" and isBuy) or (sessionBias == "Bearish" and not isBuy)
biasSideways = sessionBias == "Sideways"
biasNoTrade = sessionBias == "No Trade"
biasOk = biasAligned and not biasNoTrade
biasText = sessionBias + (biasAligned ? " | Selaras" : biasSideways ? " | Sideways" : biasNoTrade ? " | Stop" : " | Tidak Selaras")

htfAligned = htfBias == "Netral" or (htfBias == "Bullish" and isBuy) or (htfBias == "Bearish" and not isBuy)
mtfAligned = mtfBias == "Netral" or (mtfBias == "Bullish" and isBuy) or (mtfBias == "Bearish" and not isBuy)
htfNoTrade = htfBias == "No Trade"
mtfNoTrade = mtfBias == "No Trade"
ltfValid = ltfTrigger == "Valid"
mtfAlignmentOk = not useMTFAlignmentFilter or (htfAligned and mtfAligned and ltfValid and not htfNoTrade and not mtfNoTrade)
mtfAlignmentText = mtfAlignmentOk ? "VALID" : "TIDAK VALID"

sndScoreRaw = 0
sndScoreRaw += sndFreshZone ? 15 : 0
sndScoreRaw += sndHasInducement ? 10 : 0
sndScoreRaw += sndLiquiditySweep ? 15 : 0
sndScoreRaw += sndEquilibriumValid ? 10 : 0
sndScoreRaw += sndRefinementClear ? 10 : 0
sndScoreRaw += sndMitigationClean ? 10 : 0
sndScoreRaw += sndAlignedHTF ? 15 : 0
sndScoreRaw += sndReactionValid ? 15 : 0
sndQuality = sndScoreRaw >= 80 ? "STRONG" : sndScoreRaw >= 55 ? "MEDIUM" : "WEAK"
sndQualityOk = sndScoreRaw >= 55

m1 = c1 ? 0 : 5
m2 = c2 ? 0 : 15
m3 = c3 ? 0 : 10
m4 = c4 ? 0 : 5
m5 = c5 ? 0 : 5
m6 = c6 ? 0 : 5
m7 = c7 ? 0 : 10
m8 = c8 ? 0 : 5
m9 = c9 ? 0 : 5
m10 = c10 ? 0 : 10
m11 = c11 ? 0 : 5
m12 = c12 ? 0 : 10
m13 = c13 ? 0 : 5
m14 = c14 ? 0 : 10
m15 = c15 ? 0 : 5

totalMinus = m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8 + m9 + m10 + m11 + m12 + m13 + m14 + m15
qualityPercent = math.max(0, 100 - totalMinus)
triggerScore = math.max(0, 100 - (m6 + m7 + m8 + m9))
riskScore = math.max(0, 100 - (m10 + m11 + m12))
mindsetScore = math.max(0, 100 - (m13 + m14 + m15))

minProbability = decisionMode == "Strict" ? math.max(manualMinProbability, 80) : math.max(manualMinProbability, 70)
maxMinusAllowed = decisionMode == "Strict" ? 10 : 25
probabilityOk = qualityPercent >= minProbability
minusOk = totalMinus <= maxMinusAllowed
dailyLossBlocked = useDailyLossAutoBlock and consecutiveLosses >= 2

fatalNews = not c2
fatalLot = not c10
fatalDailyStop = not c12 or dailyLossBlocked
fatalRevenge = not c14
fatalRR = useRRFatalFilter and validFull and not validRR
fatalDirection = useDirectionFatalFilter and validFull and not validDirection
fatalBias = biasNoTrade or htfNoTrade or mtfNoTrade

fatalCount = 0
fatalCount += fatalNews ? 1 : 0
fatalCount += fatalLot ? 1 : 0
fatalCount += fatalDailyStop ? 1 : 0
fatalCount += fatalRevenge ? 1 : 0
fatalCount += fatalRR ? 1 : 0
fatalCount += fatalDirection ? 1 : 0
fatalCount += fatalBias ? 1 : 0
fatalCount += useMTFAlignmentFilter and not mtfAlignmentOk ? 1 : 0

warningCount = 0
warningCount += not c1 ? 1 : 0
warningCount += not c3 ? 1 : 0
warningCount += not c4 ? 1 : 0
warningCount += not c5 ? 1 : 0
warningCount += not c6 ? 1 : 0
warningCount += not c7 ? 1 : 0
warningCount += not c8 ? 1 : 0
warningCount += not c9 ? 1 : 0
warningCount += not c11 ? 1 : 0
warningCount += not c13 ? 1 : 0
warningCount += not c15 ? 1 : 0
warningCount += not biasOk or biasSideways ? 1 : 0
warningCount += not sndQualityOk ? 1 : 0

bestSetupPass = fatalCount == 0 and qualityPercent >= 85 and totalMinus <= 10 and triggerScore >= 75 and riskScore >= 75 and mindsetScore >= 75 and (not validFull or validRR) and (not validFull or validDirection)

grade = qualityPercent >= 90 ? "A+" : qualityPercent >= 80 ? "A" : qualityPercent >= 70 ? "B" : qualityPercent >= 60 ? "C" : "D"
confidence = fatalCount > 0 ? "RENDAH" : qualityPercent >= 90 and triggerScore >= 80 and riskScore >= 80 and mindsetScore >= 80 ? "ELIT" : qualityPercent >= 80 and triggerScore >= 70 and riskScore >= 70 ? "TINGGI" : qualityPercent >= 70 ? "SEDANG" : "RENDAH"

finalStatus = "ENTRY DIBLOKIR"
actionText = "BLOKIR"

if fatalCount > 0
    finalStatus := "ENTRY DIBLOKIR"
    actionText := "FATAL BERBAHAYA"
else if bestSetupOnly and not bestSetupPass
    finalStatus := "ENTRY DIBLOKIR"
    actionText := "BUKAN SETUP TERBAIK"
else if not probabilityOk
    finalStatus := "ENTRY DIBLOKIR"
    actionText := "PROBABILITAS RENDAH"
else if not minusOk
    finalStatus := "ENTRY DIBLOKIR"
    actionText := "POIN MINUS TERLALU BANYAK"
else if bestSetupOnly and bestSetupPass
    finalStatus := "ENTRY DIIZINKAN"
    actionText := "SETUP ELIT EKSEKUSI"
else if probabilityOk and minusOk and totalMinus <= 10 and warningCount <= 2
    finalStatus := "ENTRY DIIZINKAN"
    actionText := "KONDISI BAGUS AMBIL POSISI"
else if probabilityOk and minusOk
    finalStatus := "TUNGGU SETUP"
    actionText := "WAITING KONFIRMASI"

mainReason = "KONDISI SIAP DAN VALID"
if fatalBias
    mainReason := "BIAS SESI / HTF / MTF ADALAH NO TRADE"
else if useMTFAlignmentFilter and not mtfAlignmentOk
    mainReason := "HTF/MTF/LTF ALIGNMENT BELUM VALID"
else if fatalNews
    mainReason := "TERDETEKSI NEWS HIGH IMPACT"
else if fatalDailyStop
    mainReason := dailyLossBlocked ? "JUMLAH LOSS HARIAN SUDAH MENCAPAI BATAS" : "BATAS TOLERANSI LOSS HARIAN TERCAPAI"
else if fatalLot
    mainReason := "UKURAN LOT TIDAK SESUAI MANAJEMEN RISIKO"
else if fatalRevenge
    mainReason := "REVENGE TRADING TERDETEKSI"
else if fatalDirection
    mainReason := isBuy ? "STRUKTUR BUY SALAH: SL HARUS DI BAWAH ENTRY DAN TP DI ATAS ENTRY" : "STRUKTUR SELL SALAH: SL HARUS DI ATAS ENTRY DAN TP DI BAWAH ENTRY"
else if fatalRR
    mainReason := "RASIO RR AKTUAL DI BAWAH BATAS MINIMAL"
else if not probabilityOk
    mainReason := "PROBABILITAS DI BAWAH BATAS"
else if not minusOk
    mainReason := "STRUKTUR SETUP TERLALU LEMAH"
else if not sndQualityOk
    mainReason := "SND ZONE QUALITY MASIH LEMAH"


// =====================================================================
// TRADE QUALITY, EXECUTION, MARKET CONTEXT
// =====================================================================
tradeValidBase = validFull and validDirection and validRR and lotOk and riskOk and slMinOk and slMaxOk and entryDistanceOk and tpPercentOk and propGuardOk
tradeValidFinal = tradeValidBase and finalStatus == "ENTRY DIIZINKAN"

warning = "AMAN"
if not validFull
    warning := "PLAN BELUM LENGKAP"
else if not validDirection
    warning := isBuy ? "BUY SALAH: SL < ENTRY < TP" : "SELL SALAH: TP < ENTRY < SL"
else if not validRR
    warning := "RR DI BAWAH MINIMAL"
else if not lotOk
    warning := "LOT MELEBIHI BATAS"
else if not riskOk
    warning := "RISK TERLALU BESAR"
else if not slMinOk
    warning := "SL TERLALU DEKAT"
else if not slMaxOk
    warning := "SL TERLALU JAUH"
else if not entryDistanceOk
    warning := "ENTRY JAUH DARI HARGA SEKARANG"
else if not tpPercentOk
    warning := "TOTAL TP CLOSE HARUS 100%"
else if not propGuardOk
    warning := "PROP GUARD BLOCK"
else if finalStatus != "ENTRY DIIZINKAN"
    warning := mainReason

dangerMistake = tradeMistake == "Revenge" or tradeMistake == "Overlot" or tradeMistake == "News" or tradeMistake == "FOMO" or tradeMistake == "Tidak sesuai plan"
workflowRiskStop = not propGuardOk or biasNoTrade or htfNoTrade or mtfNoTrade

tradeQualityScore = qualityPercent
tradeQualityScore -= not validRR ? 15 : 0
tradeQualityScore -= not validDirection ? 15 : 0
tradeQualityScore -= not riskOk ? 15 : 0
tradeQualityScore -= not lotOk ? 10 : 0
tradeQualityScore -= not propGuardOk ? 20 : 0
tradeQualityScore -= not biasOk ? 10 : 0
tradeQualityScore -= not mtfAlignmentOk ? 15 : 0
tradeQualityScore += sndQuality == "STRONG" ? 10 : sndQuality == "MEDIUM" ? 3 : -10
tradeQualityScore -= tradeMistake != "NONE" ? 5 : 0
tradeQualityScore := math.max(0, math.min(100, tradeQualityScore))

disciplineScore = 100
disciplineScore -= not c13 ? 10 : 0
disciplineScore -= not c14 ? 15 : 0
disciplineScore -= tradeMistake == "Revenge" ? 25 : 0
disciplineScore -= tradeMistake == "FOMO" ? 15 : 0
disciplineScore -= tradeMistake == "Overlot" ? 25 : 0
disciplineScore -= tradeMistake == "News" ? 20 : 0
disciplineScore -= not riskOk ? 15 : 0
disciplineScore -= not lotOk ? 15 : 0
disciplineScore -= not biasOk ? 10 : 0
disciplineScore -= not propGuardOk ? 20 : 0
disciplineScore := math.max(0, disciplineScore)

stopTradingNow = enableStopTradingMode and (workflowRiskStop or (stopIfQualityBad and tradeQualityScore < 50) or (stopIfBiasNoTrade and fatalBias) or (stopIfMistakeDanger and dangerMistake))

qualityMeter = stopTradingNow ? "STOP HARI INI" : tradeQualityScore >= 90 and tradeValidFinal ? "ELITE" : tradeQualityScore >= 80 ? "BAGUS" : tradeQualityScore >= 65 ? "CUKUP" : "BURUK"
qualityBg = qualityMeter == "ELITE" or qualityMeter == "BAGUS" ? color.green : qualityMeter == "CUKUP" ? color.orange : color.red

planDriftPips = validEntrySL and pipSize > 0 ? math.abs(close - entryPrice) / pipSize : na
planStillIdeal = not planLocked or not validEntrySL or (not na(planDriftPips) and planDriftPips <= maxPlanDriftPips)

riskHeatScore = 0
riskHeatScore += not riskOk ? 25 : 0
riskHeatScore += not lotOk ? 20 : 0
riskHeatScore += not dailyGuardOk ? 30 : 0
riskHeatScore += not totalGuardOk ? 30 : 0
riskHeatScore += not tradeCountOk ? 20 : 0
riskHeatScore += not lossStreakOk ? 25 : 0
riskHeatScore += consecutiveLosses >= maxConsecutiveLosses - 1 ? 15 : 0
riskHeatScore += tradesTakenToday >= maxTradesPerDay - 1 ? 10 : 0
riskHeatScore += not planStillIdeal ? 15 : 0

riskHeat = riskHeatScore >= 60 ? "DANGER" : riskHeatScore >= 35 ? "HIGH" : riskHeatScore >= 15 ? "NORMAL" : "LOW"
riskHeatBg = riskHeat == "LOW" ? color.green : riskHeat == "NORMAL" ? color.orange : color.red

safeRiskMoney = accountBalance * effectiveMaxRiskAllowed / 100.0
safeLotByMaxRisk = not na(valuePerLotSL) and valuePerLotSL > 0 ? math.floor((safeRiskMoney / valuePerLotSL) * 100) / 100 : na
autoReduceLotText = not enableAutoReduceLot ? "OFF" : not validEntrySL ? "-" : not na(safeLotByMaxRisk) and not na(recommendedLot) and recommendedLot > safeLotByMaxRisk ? "Turunkan lot ke " + f_num(safeLotByMaxRisk) : "Lot aman"

sndValidCount = 0
sndValidCount += sndFreshZone ? 1 : 0
sndValidCount += sndHasInducement ? 1 : 0
sndValidCount += sndLiquiditySweep ? 1 : 0
sndValidCount += sndEquilibriumValid ? 1 : 0
sndValidCount += sndRefinementClear ? 1 : 0
sndValidCount += sndMitigationClean ? 1 : 0
sndValidCount += sndAlignedHTF ? 1 : 0
sndValidCount += sndReactionValid ? 1 : 0
sndChecklistText = str.tostring(sndValidCount) + "/8 Valid"

entryReadiness = "WAIT"
readinessReason = "Menunggu konfirmasi setup."

if enableEntryReadiness
    if stopTradingNow or not propGuardOk or riskHeat == "DANGER" or fatalBias
        entryReadiness := "BLOCK"
        readinessReason := "Risk/prop guard/bias berbahaya."
    else if not validFull
        entryReadiness := "WAIT"
        readinessReason := "Plan entry, SL, TP belum lengkap."
    else if not validDirection or not validRR or not riskOk or not lotOk
        entryReadiness := "BLOCK"
        readinessReason := "Struktur, RR, risk, atau lot tidak valid."
    else if not mtfAlignmentOk or not ltfValid
        entryReadiness := "WAIT"
        readinessReason := "HTF/MTF/LTF belum valid."
    else if sndQuality == "WEAK"
        entryReadiness := "WAIT"
        readinessReason := "SnD quality masih lemah."
    else if not planStillIdeal
        entryReadiness := "WAIT"
        readinessReason := "Plan locked sudah drift dari entry."
    else if tradeValidFinal and tradeQualityScore >= 65
        entryReadiness := "READY"
        readinessReason := "Setup siap dieksekusi sesuai plan."

readinessBg = entryReadiness == "READY" ? color.green : entryReadiness == "WAIT" ? color.orange : color.red

setupConfidenceBadge = entryReadiness == "READY" and tradeQualityScore >= 90 and disciplineScore >= 85 and sndQuality == "STRONG" and mtfAlignmentOk ? "A+" :
     entryReadiness == "READY" and tradeQualityScore >= 80 ? "A" :
     entryReadiness != "BLOCK" and tradeQualityScore >= 65 ? "B" :
     entryReadiness != "BLOCK" and tradeQualityScore >= 50 ? "C" : "NO TRADE"

autoTradeState = "Waiting Entry"
if slHit
    autoTradeState := "SL Hit"
else if tp3Hit
    autoTradeState := "TP3 Hit"
else if tp2Hit
    autoTradeState := "TP2 Hit"
else if tp1Hit
    autoTradeState := "TP1 Hit"
else if validEntrySL and (isBuy ? high >= entryPrice : low <= entryPrice)
    autoTradeState := "Running"

stateForLogic = tradeStateManual == "Waiting Entry" ? autoTradeState : tradeStateManual

beAssistant = "WAIT"
if stateForLogic == "TP1 Hit" or tp1Hit
    beAssistant := "MOVE SL TO BE"
if stateForLogic == "TP2 Hit" or tp2Hit
    beAssistant := "LOCK PROFIT"
if stateForLogic == "TP3 Hit" or tp3Hit
    beAssistant := "TRAIL RUNNER"
if stateForLogic == "SL Hit" or slHit
    beAssistant := "REVIEW LOSS"

entryToTPProgressBeforeEntry = validFull and tpDistance > 0 ? math.abs(close - entryPrice) / tpDistance * 100.0 : na
priceTooFarBeforeEntry = validFull and stateForLogic == "Waiting Entry" and not na(entryToTPProgressBeforeEntry) and entryToTPProgressBeforeEntry >= invalidEntryNearTPPercent
currentRRInvalid = enableInvalidationWarning and not na(currentRR) and currentRR <= invalidCurrentRR
planInvalid = enableInvalidationWarning and (not planStillIdeal or priceTooFarBeforeEntry or currentRRInvalid)
planValidityText = planInvalid ? "PLAN INVALID" : "PLAN VALID"

marketConditionScore = marketCondition == "Trending" ? 20 : marketCondition == "Manipulation Phase" ? 15 : marketCondition == "Accumulation" ? 12 : marketCondition == "Distribution" ? 12 : marketCondition == "Ranging" ? 8 : marketCondition == "Choppy" ? -15 : marketCondition == "News Risk" ? -25 : 0

liqScore = 0
liqScore += liqEqualHighLow ? 8 : 0
liqScore += liqBuySide ? 7 : 0
liqScore += liqSellSide ? 7 : 0
liqScore += liqGrab ? 15 : 0
liqScore += liqStopHunt ? 10 : 0
liqScore += liqInternal ? 6 : 0
liqScore += liqExternal ? 8 : 0

environmentScore = 50 + marketConditionScore
environmentScore += mtfAlignmentOk ? 15 : -15
environmentScore += sndQuality == "STRONG" ? 15 : sndQuality == "MEDIUM" ? 5 : -10
environmentScore += liqScore > 20 ? 10 : liqScore > 10 ? 5 : 0
environmentScore += riskHeat == "LOW" ? 10 : riskHeat == "NORMAL" ? 0 : riskHeat == "HIGH" ? -10 : -25
environmentScore += c2 ? 5 : -10
environmentScore := math.max(0, math.min(100, environmentScore))

environmentGrade = environmentScore >= 85 ? "EXCELLENT" : environmentScore >= 70 ? "GOOD" : environmentScore >= 55 ? "FAIR" : "BAD"

liquidityContextText = liqGrab and liqSellSide ? "SELL SIDE GRAB" : liqGrab and liqBuySide ? "BUY SIDE GRAB" : liqStopHunt ? "STOP HUNT" : liqExternal ? "EXTERNAL LIQUIDITY" : liqInternal ? "INTERNAL LIQUIDITY" : liqEqualHighLow ? "EQH/EQL" : "NO LIQ CONTEXT"

zoneTop = math.max(bestEntryZoneTop, bestEntryZoneBottom)
zoneBottom = math.min(bestEntryZoneTop, bestEntryZoneBottom)
zoneValid = enableBestEntryZone and bestEntryZoneTop > 0 and bestEntryZoneBottom > 0 and zoneTop > zoneBottom
priceInBestZone = zoneValid and close <= zoneTop and close >= zoneBottom
bestZoneStatus = not enableBestEntryZone ? "OFF" : not zoneValid ? "ISI ZONA" : priceInBestZone ? "IN ZONE" : "OUT ZONE"

entryModelOk = entryModelPreset == "Manual" ? true :
     entryModelPreset == "SnD Rejection" ? sndReactionValid and sndQualityOk :
     entryModelPreset == "SnD Mitigation" ? sndMitigationClean and sndQualityOk :
     entryModelPreset == "Liquidity Sweep + CHoCH" ? sndLiquiditySweep and c7 :
     entryModelPreset == "Inducement + SnD" ? sndHasInducement and sndQualityOk :
     entryModelPreset == "Continuation Pullback" ? c3 and mtfAlignmentOk :
     entryModelPreset == "Breakout Retest" ? c7 and ltfValid :
     entryModelPreset == "Counter Trend Scalp" ? riskHeat != "DANGER" and validRR :
     true

marketContextBlock = enableMarketContext and (marketCondition == "Choppy" or marketCondition == "News Risk" or environmentScore < 45 or (enableBestEntryZone and zoneValid and not priceInBestZone) or not entryModelOk)

ruleViolationCount = 0
ruleViolationCount += rvEntryNoTrigger ? 1 : 0
ruleViolationCount += rvEntryNews ? 1 : 0
ruleViolationCount += rvOverlot ? 1 : 0
ruleViolationCount += rvNoSL ? 1 : 0
ruleViolationCount += rvMoveSLRandom ? 1 : 0
ruleViolationCount += rvCloseNotPlan ? 1 : 0
ruleViolationCount += rvRevengeEntry ? 1 : 0
ruleViolationStop = enableRuleViolationTracker and ruleViolationCount > maxRuleViolationAllowed

noTradeReasonShort = "AMAN"
if ruleViolationStop
    noTradeReasonShort := "Rule violation melewati batas"
else if marketCondition == "News Risk"
    noTradeReasonShort := "News risk"
else if marketCondition == "Choppy"
    noTradeReasonShort := "Market choppy"
else if not entryModelOk
    noTradeReasonShort := "Entry model belum valid"
else if enableBestEntryZone and zoneValid and not priceInBestZone
    noTradeReasonShort := "Harga belum masuk zona"
else if environmentScore < 45
    noTradeReasonShort := "Environment buruk"
else if riskHeat == "DANGER"
    noTradeReasonShort := "Risk danger"
else if not mtfAlignmentOk
    noTradeReasonShort := "MTF belum valid"
else if sndQuality == "WEAK"
    noTradeReasonShort := "SnD lemah"
else if entryReadiness == "BLOCK"
    noTradeReasonShort := readinessReason

entryPermission = "WAIT"
if enableEntryPermissionSystem
    if ruleViolationStop or marketContextBlock or stopTradingNow or entryReadiness == "BLOCK" or riskHeat == "DANGER" or not propGuardOk
        entryPermission := "BLOCKED"
    else if tradeValidFinal and entryReadiness == "READY" and mtfAlignmentOk and sndQuality != "WEAK" and riskHeat != "HIGH"
        entryPermission := "ALLOWED"
    else
        entryPermission := "WAIT"
else
    entryPermission := entryReadiness == "READY" ? "ALLOWED" : entryReadiness == "BLOCK" ? "BLOCKED" : "WAIT"

permissionIcon = entryPermission == "ALLOWED" ? "ALLOWED" : entryPermission == "WAIT" ? "WAIT" : "BLOCKED"
permissionBg = entryPermission == "ALLOWED" ? color.green : entryPermission == "WAIT" ? color.orange : color.red

conflictText = "NO CONFLICT"
conflictCount = 0
if enableAutoConflictDetector
    if sndQuality == "STRONG" and not mtfAlignmentOk
        conflictText := "SnD kuat tapi MTF belum valid"
        conflictCount += 1
    if validRR and riskHeat == "DANGER"
        conflictText := "RR bagus tapi risk heat danger"
        conflictCount += 1
    if entryModelOk and enableBestEntryZone and zoneValid and not priceInBestZone
        conflictText := "Model valid tapi harga belum masuk zona"
        conflictCount += 1
    if riskOk and fatalBias
        conflictText := "Risk aman tapi bias no trade"
        conflictCount += 1
    if sndQualityOk and marketCondition == "Choppy"
        conflictText := "SnD valid tapi market choppy"
        conflictCount += 1
    if tradeValidFinal and ruleViolationStop
        conflictText := "Setup valid tapi rule violation stop"
        conflictCount += 1

focusReason = "Setup menunggu konfirmasi"
if ruleViolationStop
    focusReason := "Rule violation melewati batas"
else if riskHeat == "DANGER"
    focusReason := "Risk heat danger"
else if not propGuardOk
    focusReason := "Prop guard block"
else if fatalBias
    focusReason := "Bias no trade"
else if marketCondition == "News Risk"
    focusReason := "News risk aktif"
else if marketCondition == "Choppy"
    focusReason := "Market choppy"
else if enableBestEntryZone and zoneValid and not priceInBestZone
    focusReason := "Harga belum masuk zona entry"
else if not mtfAlignmentOk
    focusReason := "MTF alignment belum valid"
else if sndQuality == "WEAK"
    focusReason := "SnD quality lemah"
else if not validRR
    focusReason := "RR belum valid"
else if not riskOk or not lotOk
    focusReason := "Risk atau lot belum aman"
else if not entryModelOk
    focusReason := "Entry model belum valid"
else if entryPermission == "ALLOWED"
    focusReason := "Semua filter utama valid"

recommendedStyle = "Wait Confirmation"
if entryPermission == "BLOCKED"
    recommendedStyle := "Avoid Trade"
else if stateForLogic == "Running" or stateForLogic == "TP1 Hit" or stateForLogic == "TP2 Hit" or stateForLogic == "TP3 Hit"
    recommendedStyle := "Manage Only"
else if sndLiquiditySweep and c7 and mtfAlignmentOk
    recommendedStyle := "Wait Sweep + CHoCH"
else if sndMitigationClean and sndQualityOk
    recommendedStyle := "Wait Retest"
else if sndReactionValid and sndQuality == "STRONG" and entryPermission == "ALLOWED"
    recommendedStyle := "Confirmation Entry"
else if marketCondition == "Trending" and c3 and validRR and entryPermission != "BLOCKED"
    recommendedStyle := "Aggressive Entry"
else if enableBestEntryZone and zoneValid and not priceInBestZone
    recommendedStyle := "Wait Best Zone"

violationSeverity = "NONE"
if rvOverlot or rvNoSL or rvRevengeEntry or rvEntryNews
    violationSeverity := "FATAL"
else if rvEntryNoTrigger or rvMoveSLRandom
    violationSeverity := "MEDIUM"
else if rvCloseNotPlan or ruleViolationCount > 0
    violationSeverity := "MINOR"

disciplineLock = enableDisciplineLock and (violationSeverity == "FATAL" or ruleViolationStop or disciplineScore < 50 or tradeMistake == "Revenge" or tradeMistake == "Overlot")
disciplineLockText = disciplineLock ? "ON" : "OFF"

dailyTradingCommand = "WAIT CONFIRMATION"
if stopTradingNow or entryReadiness == "BLOCK" or riskHeat == "DANGER"
    dailyTradingCommand := "STOP TRADING TODAY"
else if stateForLogic == "Running" or stateForLogic == "TP1 Hit" or stateForLogic == "TP2 Hit" or stateForLogic == "TP3 Hit" or stateForLogic == "BE"
    dailyTradingCommand := "MANAGE RUNNING TRADE"
else if entryReadiness == "READY"
    dailyTradingCommand := "TRADE ALLOWED"
else if workMode == "Review" or stateForLogic == "Closed" or stateForLogic == "SL Hit"
    dailyTradingCommand := "REVIEW ONLY"

commandCenterCommand = dailyTradingCommand
if ruleViolationStop or marketContextBlock
    commandCenterCommand := "BLOCK"
else if antiOverthinkingMode
    commandCenterCommand := entryReadiness == "READY" ? "TRADE" : entryReadiness == "BLOCK" ? "BLOCK" : "WAIT"

smartMainCommand = disciplineLock ? "REVIEW" : entryPermission == "ALLOWED" ? "TRADE" : entryPermission == "BLOCKED" ? "BLOCK" : stateForLogic == "Running" or stateForLogic == "TP1 Hit" or stateForLogic == "TP2 Hit" or stateForLogic == "TP3 Hit" or stateForLogic == "BE" ? "MANAGE" : "WAIT"
smartMainAction = smartMainCommand == "TRADE" ? "Eksekusi sesuai plan" : smartMainCommand == "BLOCK" ? "Jangan entry" : smartMainCommand == "MANAGE" ? beAssistant : smartMainCommand == "REVIEW" ? "Review only" : recommendedStyle
smartPanelVerdict = smartMainCommand + " | " + setupConfidenceBadge + " | Risk " + riskHeat + " | Env " + environmentGrade

autoReviewShort = entryReadiness == "BLOCK" ? "BLOCK. " + readinessReason :
     entryReadiness == "READY" ? "READY. Eksekusi sesuai plan." :
     stopTradingNow ? "STOP TRADING. Cek risk, bias, mistake, prop guard." :
     tradeValidFinal and qualityMeter == "ELITE" ? "SETUP ELITE. Eksekusi sesuai plan." :
     tradeValidFinal ? "SETUP VALID. Ikuti risk & jangan overtrade." :
     not mtfAlignmentOk ? "WAIT. MTF/LTF belum valid." :
     sndQuality == "WEAK" ? "WAIT. SnD masih lemah." :
     "WAIT. Cek checklist, RR, bias."


// =====================================================================
// VISUAL OBJECTS
// =====================================================================
var line entryLine = na
var line slLine = na
var line tpLine = na
var line autoTPLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var line managedLine = na
var line trailLine = na

var label entryLabel = na
var label slLabel = na
var label tpLabel = na
var label autoTPLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na
var label managedLabel = na
var label trailLabel = na
var label infoLabel = na

var box riskBox = na
var box rewardBox = na
var box bestZoneBox = na

if barstate.islast
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tpLine)
    line.delete(autoTPLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(managedLine)
    line.delete(trailLine)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tpLabel)
    label.delete(autoTPLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    label.delete(managedLabel)
    label.delete(trailLabel)
    label.delete(infoLabel)

    box.delete(riskBox)
    box.delete(rewardBox)
    box.delete(bestZoneBox)

    leftX = bar_index - lineBarsLeft
    rightX = bar_index + lineBarsRight
    cleanMode = visualMode == "Ultra Clean" or cleanScreenshotMode

    if showBestEntryZone and zoneValid and not cleanMode
        bestZoneBox := box.new(leftX, zoneTop, rightX, zoneBottom, xloc=xloc.bar_index, bgcolor=color.new(color.blue, 88), border_color=color.new(color.blue, 45))

    if validEntrySL
        entryLine := line.new(leftX, entryPrice, rightX, entryPrice, xloc=xloc.bar_index, color=color.blue, width=lineWidth, style=line.style_dashed)
        slLine := line.new(leftX, stopLossPrice, rightX, stopLossPrice, xloc=xloc.bar_index, color=color.red, width=lineWidth)
        if showPriceLabels
            entryLabel := label.new(rightX, entryPrice, "ENTRY " + f_price(entryPrice), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.blue, textcolor=color.white, size=size.small)
            slLabel := label.new(rightX, stopLossPrice, "SL " + f_price(stopLossPrice), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.red, textcolor=color.white, size=size.small)

    if validFull
        tpLine := line.new(leftX, activeTP, rightX, activeTP, xloc=xloc.bar_index, color=color.green, width=lineWidth)
        if showPriceLabels
            tpLabel := label.new(rightX, activeTP, "TP " + (useAutoTP ? "AUTO" : "MANUAL") + " " + f_price(activeTP), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.green, textcolor=color.white, size=size.small)

        if showTradeBox and not cleanMode
            riskTop = isBuy ? entryPrice : stopLossPrice
            riskBottom = isBuy ? stopLossPrice : entryPrice
            rewardTop = isBuy ? activeTP : entryPrice
            rewardBottom = isBuy ? entryPrice : activeTP
            riskBox := box.new(leftX, riskTop, rightX, riskBottom, xloc=xloc.bar_index, bgcolor=color.new(color.red, riskBoxTransparency), border_color=color.new(color.red, 60))
            rewardBox := box.new(leftX, rewardTop, rightX, rewardBottom, xloc=xloc.bar_index, bgcolor=color.new(color.green, rewardBoxTransparency), border_color=color.new(color.green, 60))

    if showAutoTPReference and validEntrySL and not useAutoTP and not cleanMode
        autoTPLine := line.new(leftX, autoTP, rightX, autoTP, xloc=xloc.bar_index, color=color.new(color.green, 45), width=1, style=line.style_dotted)
        if showPriceLabels
            autoTPLabel := label.new(rightX, autoTP, "REF AUTO TP " + f_price(autoTP), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.green, 45), textcolor=color.white, size=size.tiny)

    if enableScaleOut and showScaleOutLines and validEntrySL and not cleanMode
        tp1Line := line.new(leftX, tp1, rightX, tp1, xloc=xloc.bar_index, color=color.aqua, width=1, style=line.style_dashed)
        tp2Line := line.new(leftX, tp2, rightX, tp2, xloc=xloc.bar_index, color=color.purple, width=1, style=line.style_dashed)
        tp3Line := line.new(leftX, tp3, rightX, tp3, xloc=xloc.bar_index, color=color.lime, width=1, style=line.style_dashed)
        if showPriceLabels
            tp1Label := label.new(rightX, tp1, "TP1 " + f_num(tp1RR) + "R | " + f_num(tp1ClosePercent) + "%", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.aqua, textcolor=color.black, size=size.tiny)
            tp2Label := label.new(rightX, tp2, "TP2 " + f_num(tp2RR) + "R | " + f_num(tp2ClosePercent) + "%", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.purple, textcolor=color.white, size=size.tiny)
            tp3Label := label.new(rightX, tp3, "TP3 " + f_num(tp3RR) + "R | " + f_num(tp3ClosePercent) + "%", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.lime, textcolor=color.black, size=size.tiny)

    if enableManagedSL and validEntrySL
        managedLine := line.new(leftX, managedSL, rightX, managedSL, xloc=xloc.bar_index, color=color.yellow, width=1, style=line.style_dotted)
        if showPriceLabels and not cleanMode
            managedLabel := label.new(rightX, managedSL, "MANAGED SL: " + managedText + " " + f_price(managedSL), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.yellow, textcolor=color.black, size=size.tiny)

    if trailActive and not cleanMode
        trailLine := line.new(leftX, trailPrice, rightX, trailPrice, xloc=xloc.bar_index, color=color.white, width=1, style=line.style_dotted)
        if showPriceLabels
            trailLabel := label.new(rightX, trailPrice, "TRAIL " + trailingMode + " " + f_price(trailPrice), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.white, textcolor=color.black, size=size.tiny)

    if showInfoLabel and not smartPanelOnlyMode
        infoText = "Sumarna17 Kontrol Plan Trading\n"
        infoText += "Pair: " + (showJournal ? journalPair : syminfo.ticker) + " | " + tradeDirection + " | " + workMode + "\n"
        infoText += "Smart: " + smartPanelVerdict + "\n"
        infoText += "Permission: " + permissionIcon + " | Lock: " + disciplineLockText + "\n"
        infoText += "Focus: " + focusReason + "\n"
        infoText += "Command: " + dailyTradingCommand + " | State: " + stateForLogic + "\n"
        infoText += "Quality: " + qualityMeter + " | Discipline: " + str.tostring(disciplineScore) + "%\n"
        infoText += "Risk Heat: " + riskHeat + " | Env: " + str.tostring(environmentScore) + "% " + environmentGrade + "\n"
        infoText += "Liquidity: " + liquidityContextText + " | Zone: " + bestZoneStatus + "\n"
        infoText += "MTF: " + mtfAlignmentText + " | SnD: " + sndQuality + " " + str.tostring(sndScoreRaw) + "%\n"
        infoText += "Entry: " + f_price(entryPrice) + " | SL: " + f_price(stopLossPrice) + " | TP: " + f_price(activeTP) + "\n"
        infoText += "RR: " + rrDisplay + " | Lot: " + f_num(recommendedLot) + " | Risk: " + f_num(riskAmount) + " " + ccy + "\n"
        infoText += "Status: " + finalStatus + " | " + actionText
        infoY = infoLabelPosition == "Atas Candle" ? high + atr * infoLabelOffsetATR : low - atr * infoLabelOffsetATR
        infoStyle = infoLabelPosition == "Atas Candle" ? label.style_label_down : label.style_label_up
        infoLabel := label.new(bar_index, infoY, infoText, xloc=xloc.bar_index, yloc=yloc.price, style=infoStyle, color=tradeValidFinal ? color.green : finalStatus == "TUNGGU SETUP" ? color.orange : color.red, textcolor=color.white, size=size.small)


// =====================================================================
// TABLES
// =====================================================================
var string lastDashPos = na
var table dash = table.new(f_pos(dashboardPosition), 2, 34, border_width=1)

if na(lastDashPos) or lastDashPos != dashboardPosition
    table.delete(dash)
    dash := table.new(f_pos(dashboardPosition), 2, 34, border_width=1)
    lastDashPos := dashboardPosition

if barstate.islast and showDashboard and not smartPanelOnlyMode
    table.clear(dash, 0, 0, 1, 33)
    table.cell(dash, 0, 0, "Sumarna17 Kontrol Plan Trading", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(dash, 1, 0, tradeValidFinal ? "TRADE VALID" : "WARNING", text_color=color.white, bgcolor=tradeValidFinal ? color.green : color.red, text_size=txtSize)

    if antiOverthinkingMode
        table.cell(dash, 0, 1, "VERDICT", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 1, smartPanelVerdict, text_color=color.white, bgcolor=permissionBg, text_size=txtSize)
        table.cell(dash, 0, 2, "ACTION", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 2, smartMainAction, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 3, "RR / LOT", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 3, rrDisplay + " | " + f_num(recommendedLot), text_color=color.white, bgcolor=f_ok(validRR and lotOk), text_size=txtSize)
    else if dashboardView == "Compact"
        table.cell(dash, 0, 1, "MODE / PAIR", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 1, workMode + " | " + (showJournal ? journalPair : syminfo.ticker), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 2, "QUALITY", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 2, qualityMeter + " | " + str.tostring(tradeQualityScore) + "%", text_color=color.white, bgcolor=qualityBg, text_size=txtSize)
        table.cell(dash, 0, 3, "ENTRY/SL/TP", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 3, f_price(entryPrice) + " / " + f_price(stopLossPrice) + " / " + f_price(activeTP), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 4, "RR / LOT", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 4, rrDisplay + " | " + f_num(recommendedLot), text_color=color.white, bgcolor=f_ok(validRR and lotOk), text_size=txtSize)
        table.cell(dash, 0, 5, "STATUS", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 5, finalStatus, text_color=color.white, bgcolor=f_status_bg(finalStatus), text_size=txtSize)
        table.cell(dash, 0, 6, "REASON", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 6, mainReason, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    else if dashboardView == "Execution Only"
        table.cell(dash, 0, 1, "COMMAND", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 1, dailyTradingCommand, text_color=color.white, bgcolor=dailyTradingCommand == "TRADE ALLOWED" ? color.green : dailyTradingCommand == "STOP TRADING TODAY" ? color.red : color.orange, text_size=txtSize)
        table.cell(dash, 0, 2, "ENTRY", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 2, f_price(entryPrice), text_color=color.white, bgcolor=color.blue, text_size=txtSize)
        table.cell(dash, 0, 3, "SL / MANAGED", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 3, f_price(stopLossPrice) + " / " + f_price(managedSL), text_color=color.black, bgcolor=color.yellow, text_size=txtSize)
        table.cell(dash, 0, 4, "TP / RR", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 4, f_price(activeTP) + " / " + rrDisplay, text_color=color.white, bgcolor=f_ok(validRR), text_size=txtSize)
        table.cell(dash, 0, 5, "LOT / RISK", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 5, f_num(recommendedLot) + " / " + f_num(riskAmount) + " " + ccy, text_color=color.white, bgcolor=f_ok(lotOk and riskOk), text_size=txtSize)
    else if dashboardView == "Journal Only" or visualMode == "Journal"
        table.cell(dash, 0, 1, "PAIR / SESI", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 1, (showJournal ? journalPair : syminfo.ticker) + " / " + journalSession, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 2, "HASIL", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 2, journalResult, text_color=color.white, bgcolor=journalResult == "WIN" ? color.green : journalResult == "LOSS" ? color.red : journalResult == "BE" ? color.orange : color.gray, text_size=txtSize)
        table.cell(dash, 0, 3, "BIAS / ENTRY", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 3, biasText + " | " + entryType, text_color=color.white, bgcolor=biasOk ? color.green : color.orange, text_size=txtSize)
        table.cell(dash, 0, 4, "MISTAKE", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 4, tradeMistake, text_color=color.white, bgcolor=tradeMistake == "NONE" ? color.green : color.red, text_size=txtSize)
        table.cell(dash, 0, 5, "LESSON", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 5, lessonTag, text_color=color.white, bgcolor=lessonTag == "NONE" ? color.gray : color.blue, text_size=txtSize)
        table.cell(dash, 0, 6, "ALASAN ENTRY", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 6, tradeReason == "" ? "-" : tradeReason, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 7, "CATATAN", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 7, tradeNote == "" ? "-" : tradeNote, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    else
        table.cell(dash, 0, 1, "PAIR / MODE", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 1, (showJournal ? journalPair : syminfo.ticker) + " | " + workMode, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 2, "Direction", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 2, tradeDirection, text_color=color.white, bgcolor=isBuy ? color.green : color.red, text_size=txtSize)
        table.cell(dash, 0, 3, "Entry/SL/TP", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 3, f_price(entryPrice) + " / " + f_price(stopLossPrice) + " / " + f_price(activeTP), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 4, "RR", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 4, rrDisplay + " / Min 1:" + f_num(effectiveMinRRAllowed), text_color=color.white, bgcolor=f_ok(validRR), text_size=txtSize)
        table.cell(dash, 0, 5, "Risk", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 5, f_num(riskAmount) + " " + ccy + " (" + f_num(effectiveRiskPercent) + "%)", text_color=color.white, bgcolor=f_ok(riskOk), text_size=txtSize)
        table.cell(dash, 0, 6, "Lot", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 6, f_num(recommendedLot), text_color=color.white, bgcolor=f_ok(lotOk), text_size=txtSize)
        table.cell(dash, 0, 7, "SL/TP Pips", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 7, f_num(slPips) + " / " + f_num(tpPips), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 8, "Est P/L", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 8, "-" + f_num(estimatedLoss) + " / +" + f_num(estimatedProfit), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 9, "TP Progress", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 9, f_num(scaleProgress) + "% | Rem " + f_num(remainingPosition) + "%", text_color=color.white, bgcolor=scaleProgress >= 100 ? color.green : scaleProgress > 0 ? color.orange : color.gray, text_size=txtSize)
        table.cell(dash, 0, 10, "Current RR", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 10, f_num(currentRR), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 11, "Managed SL", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 11, managedText + " | " + f_price(managedSL), text_color=color.black, bgcolor=color.yellow, text_size=txtSize)
        table.cell(dash, 0, 12, "Trail", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 12, f_price(trailPrice), text_color=color.black, bgcolor=color.white, text_size=txtSize)
        table.cell(dash, 0, 13, "Prop Guard", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 13, propGuardOk ? "AMAN" : "BLOCK", text_color=color.white, bgcolor=f_ok(propGuardOk), text_size=txtSize)
        table.cell(dash, 0, 14, "Daily Loss", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 14, f_num(dailyAfter) + " / " + f_num(dailyLimit), text_color=color.white, bgcolor=f_ok(dailyGuardOk), text_size=txtSize)
        table.cell(dash, 0, 15, "Total Loss", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 15, f_num(totalAfter) + " / " + f_num(totalLimit), text_color=color.white, bgcolor=f_ok(totalGuardOk), text_size=txtSize)
        table.cell(dash, 0, 16, "Quality", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 16, qualityMeter + " | " + str.tostring(tradeQualityScore) + "%", text_color=color.white, bgcolor=qualityBg, text_size=txtSize)
        table.cell(dash, 0, 17, "Discipline", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 17, str.tostring(disciplineScore) + "%", text_color=color.white, bgcolor=disciplineScore >= 80 ? color.green : disciplineScore >= 60 ? color.orange : color.red, text_size=txtSize)
        table.cell(dash, 0, 18, "MTF / SnD", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 18, mtfAlignmentText + " | " + sndQuality + " " + str.tostring(sndScoreRaw) + "%", text_color=color.white, bgcolor=mtfAlignmentOk and sndQualityOk ? color.green : color.orange, text_size=txtSize)
        table.cell(dash, 0, 19, "Final Status", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 19, finalStatus, text_color=color.white, bgcolor=f_status_bg(finalStatus), text_size=txtSize)
        table.cell(dash, 0, 20, "Action", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 20, actionText, text_color=color.white, bgcolor=f_status_bg(finalStatus), text_size=txtSize)
        table.cell(dash, 0, 21, "Reason", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 21, mainReason, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 0, 22, "Command", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(dash, 1, 22, smartPanelVerdict, text_color=color.white, bgcolor=permissionBg, text_size=txtSize)
        if showTradeNotes
            table.cell(dash, 0, 23, "Alasan", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
            table.cell(dash, 1, 23, tradeReason == "" ? "-" : tradeReason, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
            table.cell(dash, 0, 24, "Catatan", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
            table.cell(dash, 1, 24, tradeNote == "" ? "-" : tradeNote, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)


// SMART EXECUTION TABLE
var string lastSmartPos = na
var table smartTable = table.new(f_pos(smartExecutionPosition), 2, 10, border_width=1)

if na(lastSmartPos) or lastSmartPos != smartExecutionPosition
    table.delete(smartTable)
    smartTable := table.new(f_pos(smartExecutionPosition), 2, 10, border_width=1)
    lastSmartPos := smartExecutionPosition

if barstate.islast and enableSmartExecutionPanel
    table.clear(smartTable, 0, 0, 1, 9)
    table.cell(smartTable, 0, 0, "SMART EXEC", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(smartTable, 1, 0, smartMainCommand, text_color=color.white, bgcolor=smartMainCommand == "TRADE" ? color.green : smartMainCommand == "BLOCK" or smartMainCommand == "REVIEW" ? color.red : smartMainCommand == "MANAGE" ? color.blue : color.orange, text_size=txtSize)
    table.cell(smartTable, 0, 1, "Permission", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(smartTable, 1, 1, permissionIcon, text_color=color.white, bgcolor=permissionBg, text_size=txtSize)
    table.cell(smartTable, 0, 2, "Setup", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(smartTable, 1, 2, setupConfidenceBadge + " | " + recommendedStyle, text_color=color.white, bgcolor=readinessBg, text_size=txtSize)
    table.cell(smartTable, 0, 3, "Risk / Market", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(smartTable, 1, 3, riskHeat + " | " + environmentGrade, text_color=color.white, bgcolor=riskHeat == "DANGER" ? color.red : environmentScore >= 70 ? color.green : color.orange, text_size=txtSize)
    table.cell(smartTable, 0, 4, "Focus", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(smartTable, 1, 4, focusReason, text_color=color.white, bgcolor=entryPermission == "ALLOWED" ? color.green : entryPermission == "BLOCKED" ? color.red : color.orange, text_size=txtSize)
    table.cell(smartTable, 0, 5, "Conflict", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(smartTable, 1, 5, conflictCount == 0 ? "NO CONFLICT" : conflictText, text_color=color.white, bgcolor=conflictCount == 0 ? color.green : color.orange, text_size=txtSize)
    table.cell(smartTable, 0, 6, "Action", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(smartTable, 1, 6, smartMainAction, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    if smartExecutionSize == "Detail"
        table.cell(smartTable, 0, 7, "Discipline Lock", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(smartTable, 1, 7, disciplineLockText + " | " + violationSeverity, text_color=color.white, bgcolor=disciplineLock ? color.red : color.green, text_size=txtSize)
        table.cell(smartTable, 0, 8, "Session", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(smartTable, 1, 8, journalSession, text_color=color.white, bgcolor=journalSession == "London+New York" ? color.green : color.orange, text_size=txtSize)
        table.cell(smartTable, 0, 9, "Verdict", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
        table.cell(smartTable, 1, 9, smartPanelVerdict, text_color=color.white, bgcolor=permissionBg, text_size=txtSize)


// COMMAND CENTER TABLE
var string lastCmdPos = na
var table cmdTable = table.new(f_pos(commandCenterPosition), 2, 8, border_width=1)

if na(lastCmdPos) or lastCmdPos != commandCenterPosition
    table.delete(cmdTable)
    cmdTable := table.new(f_pos(commandCenterPosition), 2, 8, border_width=1)
    lastCmdPos := commandCenterPosition

if barstate.islast and showCommandCenter and not smartPanelOnlyMode
    table.clear(cmdTable, 0, 0, 1, 7)
    table.cell(cmdTable, 0, 0, "COMMAND", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(cmdTable, 1, 0, commandCenterCommand, text_color=color.white, bgcolor=commandCenterCommand == "TRADE" or commandCenterCommand == "TRADE ALLOWED" ? color.green : commandCenterCommand == "BLOCK" or commandCenterCommand == "STOP TRADING TODAY" ? color.red : color.orange, text_size=txtSize)
    table.cell(cmdTable, 0, 1, "Reason", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 1, noTradeReasonShort, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 0, 2, "Risk", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 2, riskHeat, text_color=color.white, bgcolor=riskHeatBg, text_size=txtSize)
    table.cell(cmdTable, 0, 3, "Setup", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 3, setupConfidenceBadge + " | " + entryReadiness, text_color=color.white, bgcolor=readinessBg, text_size=txtSize)
    table.cell(cmdTable, 0, 4, "Environment", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 4, environmentGrade + " | " + str.tostring(environmentScore) + "%", text_color=color.white, bgcolor=environmentScore >= 70 ? color.green : environmentScore >= 55 ? color.orange : color.red, text_size=txtSize)
    table.cell(cmdTable, 0, 5, "Liquidity", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 5, liquidityContextText, text_color=color.white, bgcolor=liqScore > 15 ? color.green : color.gray, text_size=txtSize)
    table.cell(cmdTable, 0, 6, "Zone/Model", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 6, bestZoneStatus + " | " + (entryModelOk ? "Model OK" : "Model WAIT"), text_color=color.white, bgcolor=(not enableBestEntryZone or priceInBestZone) and entryModelOk ? color.green : color.orange, text_size=txtSize)
    table.cell(cmdTable, 0, 7, "Action", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(cmdTable, 1, 7, smartMainAction, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)


// TRADE MANAGEMENT TABLE
var string lastMgmtPos = na
var table mgmtTable = table.new(f_pos(tradeManagementPosition), 2, 10, border_width=1)

if na(lastMgmtPos) or lastMgmtPos != tradeManagementPosition
    table.delete(mgmtTable)
    mgmtTable := table.new(f_pos(tradeManagementPosition), 2, 10, border_width=1)
    lastMgmtPos := tradeManagementPosition

if barstate.islast and showTradeManagementTable and not smartPanelOnlyMode
    table.clear(mgmtTable, 0, 0, 1, 9)
    table.cell(mgmtTable, 0, 0, "TRADE MGMT", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(mgmtTable, 1, 0, dailyTradingCommand, text_color=color.white, bgcolor=dailyTradingCommand == "TRADE ALLOWED" ? color.green : dailyTradingCommand == "STOP TRADING TODAY" ? color.red : color.orange, text_size=txtSize)
    table.cell(mgmtTable, 0, 1, "State", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 1, stateForLogic, text_color=color.white, bgcolor=stateForLogic == "SL Hit" ? color.red : stateForLogic == "Closed" ? color.gray : color.green, text_size=txtSize)
    table.cell(mgmtTable, 0, 2, "Action", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 2, smartMainAction, text_color=color.white, bgcolor=smartMainAction == "Jangan entry" ? color.red : color.orange, text_size=txtSize)
    table.cell(mgmtTable, 0, 3, "Current RR", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 3, f_num(currentRR), text_color=color.white, bgcolor=not na(currentRR) and currentRR >= 0 ? color.green : color.red, text_size=txtSize)
    table.cell(mgmtTable, 0, 4, "BE / Lock", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 4, beAssistant + " | " + managedText, text_color=color.black, bgcolor=color.yellow, text_size=txtSize)
    table.cell(mgmtTable, 0, 5, "Partial Close", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 5, "TP1 " + f_num(tp1ClosePercent) + "% | TP2 " + f_num(tp2ClosePercent) + "% | TP3 " + f_num(tp3ClosePercent) + "%", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 0, 6, "Partial Profit", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 6, "+" + f_num(tp1Money) + " / +" + f_num(tp2Money) + " / +" + f_num(tp3Money) + " " + ccy, text_color=color.white, bgcolor=color.green, text_size=txtSize)
    table.cell(mgmtTable, 0, 7, "Plan Valid", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 7, planValidityText, text_color=color.white, bgcolor=planInvalid ? color.red : color.green, text_size=txtSize)
    table.cell(mgmtTable, 0, 8, "Exit Review", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 8, exitQuality, text_color=color.white, bgcolor=exitQuality == "NONE" or exitQuality == "Exit sesuai plan" ? color.green : color.orange, text_size=txtSize)
    table.cell(mgmtTable, 0, 9, "Lesson", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(mgmtTable, 1, 9, lessonTag, text_color=color.white, bgcolor=lessonTag == "NONE" ? color.gray : color.blue, text_size=txtSize)


// EXECUTION CONTROL TABLE
var string lastExecPos = na
var table execTable = table.new(f_pos(executionControlPosition), 2, 9, border_width=1)

if na(lastExecPos) or lastExecPos != executionControlPosition
    table.delete(execTable)
    execTable := table.new(f_pos(executionControlPosition), 2, 9, border_width=1)
    lastExecPos := executionControlPosition

if barstate.islast and showExecutionControlTable and not smartPanelOnlyMode
    table.clear(execTable, 0, 0, 1, 8)
    table.cell(execTable, 0, 0, "EXEC CTRL", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(execTable, 1, 0, entryReadiness + " | " + setupConfidenceBadge, text_color=color.white, bgcolor=readinessBg, text_size=txtSize)
    table.cell(execTable, 0, 1, "Reason", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 1, focusReason, text_color=color.white, bgcolor=readinessBg, text_size=txtSize)
    table.cell(execTable, 0, 2, "Risk Heat", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 2, riskHeat + " | Score " + str.tostring(riskHeatScore), text_color=color.white, bgcolor=riskHeatBg, text_size=txtSize)
    table.cell(execTable, 0, 3, "Lot Suggest", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 3, autoReduceLotText, text_color=color.white, bgcolor=autoReduceLotText == "Lot aman" ? color.green : color.orange, text_size=txtSize)
    table.cell(execTable, 0, 4, "Plan Lock", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 4, planLocked ? (planStillIdeal ? "LOCKED OK" : "DRIFT") : "OFF", text_color=color.white, bgcolor=not planLocked or planStillIdeal ? color.green : color.red, text_size=txtSize)
    table.cell(execTable, 0, 5, "Plan Drift", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 5, f_num(planDriftPips) + " pip/point", text_color=color.white, bgcolor=planStillIdeal ? color.green : color.red, text_size=txtSize)
    table.cell(execTable, 0, 6, "SnD Detail", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 6, sndChecklistText, text_color=color.white, bgcolor=sndValidCount >= 6 ? color.green : sndValidCount >= 4 ? color.orange : color.red, text_size=txtSize)
    table.cell(execTable, 0, 7, "Readiness", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 7, readinessReason, text_color=color.white, bgcolor=readinessBg, text_size=txtSize)
    table.cell(execTable, 0, 8, "Screenshot", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(execTable, 1, 8, cleanScreenshotMode ? "CLEAN ON" : "NORMAL", text_color=color.white, bgcolor=cleanScreenshotMode ? color.green : color.gray, text_size=txtSize)


// AUTO REVIEW TABLE
var string lastReviewPos = na
var table reviewTable = table.new(f_review_pos(), 2, 4, border_width=1)

if na(lastReviewPos) or lastReviewPos != reviewTablePosition
    table.delete(reviewTable)
    reviewTable := table.new(f_review_pos(), 2, 4, border_width=1)
    lastReviewPos := reviewTablePosition

if barstate.islast and showReviewTable and not smartPanelOnlyMode
    table.clear(reviewTable, 0, 0, 1, 3)
    table.cell(reviewTable, 0, 0, "AUTO REVIEW", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(reviewTable, 1, 0, qualityMeter, text_color=color.white, bgcolor=qualityBg, text_size=txtSize)
    table.cell(reviewTable, 0, 1, "Quality", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(reviewTable, 1, 1, str.tostring(tradeQualityScore) + "% | D:" + str.tostring(disciplineScore) + "%", text_color=color.white, bgcolor=qualityBg, text_size=txtSize)
    table.cell(reviewTable, 0, 2, "Action", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(reviewTable, 1, 2, actionText, text_color=color.white, bgcolor=f_status_bg(finalStatus), text_size=txtSize)
    table.cell(reviewTable, 0, 3, "Review", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(reviewTable, 1, 3, showAutoReviewText ? autoReviewShort : "-", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)


// FLOATING HUD
var string lastHudPos = na
var table hud = table.new(f_pos(hudPosition), 2, 11, border_width=1)

if na(lastHudPos) or lastHudPos != hudPosition
    table.delete(hud)
    hud := table.new(f_pos(hudPosition), 2, 11, border_width=1)
    lastHudPos := hudPosition

if barstate.islast and showFloatingHUD and not cleanScreenshotMode and not antiOverthinkingMode and not smartPanelOnlyMode
    table.clear(hud, 0, 0, 1, 10)
    table.cell(hud, 0, 0, "RR", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(hud, 1, 0, rrDisplay, text_color=color.white, bgcolor=f_ok(validRR), text_size=txtSize)
    table.cell(hud, 0, 1, "LOT", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 1, f_num(recommendedLot), text_color=color.white, bgcolor=f_ok(lotOk), text_size=txtSize)
    table.cell(hud, 0, 2, "RISK", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 2, f_num(riskAmount) + " " + ccy, text_color=color.white, bgcolor=f_ok(riskOk), text_size=txtSize)
    table.cell(hud, 0, 3, "NOW R", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 3, f_num(currentRR), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 0, 4, "QUALITY", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 4, entryReadiness + " | " + qualityMeter, text_color=color.white, bgcolor=readinessBg, text_size=txtSize)
    table.cell(hud, 0, 5, "MODE", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 5, workMode, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 0, 6, "BIAS", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 6, biasText + " | " + mtfAlignmentText, text_color=color.white, bgcolor=biasOk and mtfAlignmentOk ? color.green : color.orange, text_size=txtSize)
    table.cell(hud, 0, 7, "MISTAKE", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 7, tradeMistake, text_color=color.white, bgcolor=tradeMistake == "NONE" ? color.green : color.red, text_size=txtSize)
    table.cell(hud, 0, 8, "ACTION", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 8, actionText, text_color=color.white, bgcolor=f_status_bg(finalStatus), text_size=txtSize)
    table.cell(hud, 0, 9, "HASIL", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 9, journalResult, text_color=color.white, bgcolor=journalResult == "WIN" ? color.green : journalResult == "LOSS" ? color.red : journalResult == "BE" ? color.orange : color.gray, text_size=txtSize)
    table.cell(hud, 0, 10, "STATUS", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(hud, 1, 10, tradeValidFinal ? "VALID" : "WARN", text_color=color.white, bgcolor=f_ok(tradeValidFinal), text_size=txtSize)


// JOURNAL SUMMARY TABLE
var string lastJournalSummaryPos = na
var table journalSummaryTable = table.new(f_pos(journalSummaryPosition), 2, 9, border_width=1)

if na(lastJournalSummaryPos) or lastJournalSummaryPos != journalSummaryPosition
    table.delete(journalSummaryTable)
    journalSummaryTable := table.new(f_pos(journalSummaryPosition), 2, 9, border_width=1)
    lastJournalSummaryPos := journalSummaryPosition

if barstate.islast and showScreenshotJournalSummary
    table.clear(journalSummaryTable, 0, 0, 1, 8)
    table.cell(journalSummaryTable, 0, 0, "JOURNAL SUMMARY", text_color=color.white, bgcolor=color.black, text_size=txtSize)
    table.cell(journalSummaryTable, 1, 0, journalPair + " | " + tradeDirection, text_color=color.white, bgcolor=isBuy ? color.green : color.red, text_size=txtSize)
    table.cell(journalSummaryTable, 0, 1, "Setup", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 1, entryModelPreset + " | " + entryType, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 0, 2, "Entry / SL / TP", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 2, f_price(entryPrice) + " / " + f_price(stopLossPrice) + " / " + f_price(activeTP), text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 0, 3, "RR / Lot", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 3, rrDisplay + " | " + f_num(recommendedLot), text_color=color.white, bgcolor=f_ok(validRR and lotOk), text_size=txtSize)
    table.cell(journalSummaryTable, 0, 4, "Result", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 4, journalResult, text_color=color.white, bgcolor=journalResult == "WIN" ? color.green : journalResult == "LOSS" ? color.red : journalResult == "BE" ? color.orange : color.gray, text_size=txtSize)
    table.cell(journalSummaryTable, 0, 5, "Quality", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 5, setupConfidenceBadge + " | " + qualityMeter, text_color=color.white, bgcolor=qualityBg, text_size=txtSize)
    table.cell(journalSummaryTable, 0, 6, "Lesson", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 6, lessonTag, text_color=color.white, bgcolor=lessonTag == "NONE" ? color.gray : color.blue, text_size=txtSize)
    table.cell(journalSummaryTable, 0, 7, "Exit Review", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 7, exitQuality, text_color=color.white, bgcolor=exitQuality == "Exit sesuai plan" ? color.green : color.orange, text_size=txtSize)
    table.cell(journalSummaryTable, 0, 8, "Note", text_color=color.white, bgcolor=f_bg(), text_size=txtSize)
    table.cell(journalSummaryTable, 1, 8, tradeNote == "" ? "-" : tradeNote, text_color=color.white, bgcolor=f_bg(), text_size=txtSize)


// =====================================================================
// ALERTS
// =====================================================================
alertcondition(tradeValidFinal and not tradeValidFinal[1], title="Sumarna17 Trade Valid", message="Sumarna17 Trade Plan Control System: Trade valid.")
alertcondition(not tradeValidFinal and tradeValidFinal[1], title="Sumarna17 Warning", message="Sumarna17 Trade Plan Control System: Trade warning.")

alertcondition(tp1Hit and not tp1Hit[1], title="Sumarna17 TP1 Hit", message="TP1 tercapai. Pertimbangkan partial close dan BE.")
alertcondition(tp2Hit and not tp2Hit[1], title="Sumarna17 TP2 Hit", message="TP2 tercapai. Pertimbangkan lock profit.")
alertcondition(tp3Hit and not tp3Hit[1], title="Sumarna17 TP3 Hit", message="TP3 tercapai.")
alertcondition(beTriggerHit and not beTriggerHit[1], title="Sumarna17 Move SL to BE", message="Trigger BE aktif.")
alertcondition(tpMainHit and not tpMainHit[1], title="Sumarna17 Main TP Hit", message="TP utama tercapai.")
alertcondition(slHit and not slHit[1], title="Sumarna17 SL Hit", message="Stop Loss tersentuh.")
alertcondition(not propGuardOk and propGuardOk[1], title="Sumarna17 Prop Guard Block", message="Prop Firm Guard memblokir trade.")

alertcondition(finalStatus == "ENTRY DIIZINKAN" and finalStatus[1] != "ENTRY DIIZINKAN", title="Sumarna17 ENTRY DIIZINKAN", message="ENTRY DIIZINKAN. Cek dashboard untuk detail setup.")
alertcondition(finalStatus == "TUNGGU SETUP" and finalStatus[1] != "TUNGGU SETUP", title="Sumarna17 TUNGGU SETUP", message="TUNGGU SETUP. Masih perlu konfirmasi tambahan.")
alertcondition(finalStatus == "ENTRY DIBLOKIR" and finalStatus[1] != "ENTRY DIBLOKIR", title="Sumarna17 ENTRY DIBLOKIR", message="ENTRY DIBLOKIR. Ada fatal filter atau validasi gagal.")
alertcondition(qualityMeter == "ELITE" and qualityMeter[1] != "ELITE", title="Sumarna17 Quality Elite", message="Trade Quality ELITE.")
alertcondition(qualityMeter == "STOP HARI INI" and qualityMeter[1] != "STOP HARI INI", title="Sumarna17 Stop Trading Hari Ini", message="STOP TRADING HARI INI.")
alertcondition(disciplineScore >= 90 and disciplineScore[1] < 90, title="Sumarna17 Discipline Excellent", message="Discipline Score sangat baik.")
alertcondition(sndQuality == "STRONG" and sndQuality[1] != "STRONG", title="Sumarna17 SnD Strong", message="SnD Zone Quality STRONG.")
alertcondition(mtfAlignmentOk and not mtfAlignmentOk[1], title="Sumarna17 MTF Alignment Valid", message="HTF/MTF/LTF Alignment valid.")
alertcondition(entryReadiness == "READY" and entryReadiness[1] != "READY", title="Sumarna17 READY", message="Entry Readiness READY.")
alertcondition(entryReadiness == "BLOCK" and entryReadiness[1] != "BLOCK", title="Sumarna17 BLOCK", message="Entry Readiness BLOCK.")
alertcondition(riskHeat == "DANGER" and riskHeat[1] != "DANGER", title="Sumarna17 Risk Heat Danger", message="Risk Heat DANGER.")
alertcondition(setupConfidenceBadge == "A+" and setupConfidenceBadge[1] != "A+", title="Sumarna17 A+ Setup", message="Setup Confidence A+.")
alertcondition(dailyTradingCommand == "TRADE ALLOWED" and dailyTradingCommand[1] != "TRADE ALLOWED", title="Sumarna17 Trade Allowed", message="TRADE ALLOWED.")
alertcondition(dailyTradingCommand == "MANAGE RUNNING TRADE" and dailyTradingCommand[1] != "MANAGE RUNNING TRADE", title="Sumarna17 Manage Running Trade", message="MANAGE RUNNING TRADE.")
alertcondition(dailyTradingCommand == "STOP TRADING TODAY" and dailyTradingCommand[1] != "STOP TRADING TODAY", title="Sumarna17 Stop Trading Today", message="STOP TRADING TODAY.")
alertcondition(planInvalid and not planInvalid[1], title="Sumarna17 Plan Invalid", message="PLAN INVALID.")
alertcondition(commandCenterCommand == "TRADE" and commandCenterCommand[1] != "TRADE", title="Sumarna17 Command Trade", message="COMMAND TRADE.")
alertcondition(commandCenterCommand == "BLOCK" and commandCenterCommand[1] != "BLOCK", title="Sumarna17 Command Block", message="COMMAND BLOCK.")
alertcondition(environmentGrade == "EXCELLENT" and environmentGrade[1] != "EXCELLENT", title="Sumarna17 Environment Excellent", message="Environment EXCELLENT.")
alertcondition(priceInBestZone and not priceInBestZone[1], title="Sumarna17 Price In Best Zone", message="Harga masuk Best Entry Zone.")
alertcondition(ruleViolationStop and not ruleViolationStop[1], title="Sumarna17 Rule Violation Stop", message="Rule Violation melewati batas.")
alertcondition(smartMainCommand == "TRADE" and smartMainCommand[1] != "TRADE", title="Sumarna17 Smart TRADE", message="Smart Execution Command TRADE.")
alertcondition(smartMainCommand == "BLOCK" and smartMainCommand[1] != "BLOCK", title="Sumarna17 Smart BLOCK", message="Smart Execution Command BLOCK.")
alertcondition(smartMainCommand == "MANAGE" and smartMainCommand[1] != "MANAGE", title="Sumarna17 Smart MANAGE", message="Smart Execution Command MANAGE.")
alertcondition(disciplineLock and not disciplineLock[1], title="Sumarna17 Discipline Lock", message="Discipline Lock ON.")
alertcondition(conflictCount > 0 and conflictCount[1] == 0, title="Sumarna17 Conflict Detected", message="Auto Conflict Detected.")
alertcondition(entryPermission == "ALLOWED" and entryPermission[1] != "ALLOWED", title="Sumarna17 Entry Permission Allowed", message="Entry Permission ALLOWED.")
````
