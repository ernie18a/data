# KING PULLBACK DQPRO V6

- url: https://www.tradingview.com/script/lwvmhHDw/
- type: indicator
- pine_id: PUB;a7244d790e814dfd8caa31ae20350124
- version: 1.0

## Description

bản cập nhật xác định xu hướng và kết hợp nhiều công cụ hỗ trợ khác nhau, giúp nhận định xu hướng rõ ràng hơn.

## Source Code

````pine
//@version=6
indicator("KING PULLBACK PRO V9.3 - V41 STRICT DARK ZONE MEMORY", overlay=true, scale=scale.right, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

//====================================================//
// KING PULLBACK PRO V9.3 - V8 sửa thứ tự mây nhạt/đậm và co giãn mây đậm.
// Không phải mã nguồn gốc. Không dùng tên cũ.
//====================================================//

//===================== GROUPS =====================//
gDisplay = "HIỂN THỊ"
gSignal  = "TÍN HIỆU & LABEL"
gAlert   = "CẤU HÌNH CẢNH BÁO"
gLabel   = "LABEL HIỂN THỊ"
gTP      = "TP & STP"
gLimit   = "GIỚI HẠN LỆNH"
gKing    = "CƠ BẢN"
gKingCoef= "HỆ SỐ KING (MÃ HÓA ẨN)"
gStats   = "THỐNG KÊ"
gRSI     = "RSI FILTERS"
gRSITrend= "BỘ LỌC RSI XU HƯỚNG"
gRSIExt  = "BỘ LỌC RSI CỰC TRỊ"
gRSIHis  = "BỘ LỌC RSI LỊCH SỬ XU HƯỚNG"
gBB      = "CHỈ BÁO 2: BBNDS CORE"
gPull    = "PULLBACK SETUP"
gMid     = "MÂY PHỤ PULLBACK–MID"
gStyle   = "ĐỊNH DẠNG / MÀU SẮC"
gSession = "BỘ LỌC THỜI GIAN"
gCloud   = "CẤU HÌNH MÂY"

//===================== HIỂN THỊ =====================//
showMainTrend      = input.bool(true,  "Hiển thị Xu hướng chính", group=gDisplay)
showTrendLabel     = input.bool(true,  "Hiển thị nhãn xu hướng", group=gDisplay)
showNoiseFilter    = input.bool(true,  "Bật lọc nhiễu xu hướng", group=gDisplay)
showMediumTrend    = input.bool(false, "Hiển thị xu hướng trung hạn", group=gDisplay)
showKingCloud      = input.bool(true,  "Hiển thị Mây KING", group=gDisplay)
showPullbackLine   = input.bool(false, "Hiển thị Pullback line", group=gDisplay)
showSignal         = input.bool(true,  "Hiển thị tín hiệu Entry/TP/STP", group=gDisplay)
showMtfTable       = input.bool(false, "Hiển thị Bảng xu hướng đa khung", group=gDisplay)
showBackground     = input.bool(true,  "Hiển thị nền phiên/dải dọc", group=gDisplay)
forceSameChart     = input.bool(true,  "Ép overlay cùng chart", group=gDisplay)

//===================== TÍN HIỆU & LABEL =====================//
enablePreviewLabel = input.bool(true,  "Bật Label Preview khi nến chưa đóng", group=gSignal)
previewMinutes     = input.int(10, "Báo trước Preview trong N phút cuối nến", minval=1, maxval=60, group=gSignal)
previewBuyColor    = input.color(color.new(color.green, 20), "Màu Preview BUY", group=gSignal)
previewSellColor   = input.color(color.new(color.red, 20),   "Màu Preview SELL", group=gSignal)
confirmBuyColor    = input.color(color.blue, "Màu Confirm BUY", group=gSignal)
confirmSellColor   = input.color(color.red,  "Màu Confirm SELL", group=gSignal)
previewSuffix      = input.string("(preview)", "Hậu tố chữ Preview", group=gSignal)
labelSizeOpt       = input.string("small", "Cỡ chữ label", options=["tiny", "small", "normal", "large"], group=gSignal)

//===================== ALERTS =====================//
alertReverse       = input.bool(true, "1. Bật cảnh báo đảo chiều xu hướng", group=gAlert)
alertPreview       = input.bool(true, "2. Bật cảnh báo PREVIEW Realtime", group=gAlert)
alertEntryConfirm  = input.bool(true, "3. Bật cảnh báo ENTRY HOÀN CHỈNH", group=gAlert)
alertWithPrice     = input.bool(true, "Bao gồm chi tiết giá Entry/STP/TP trong alert", group=gAlert)
alertRealtimeOnly  = input.bool(true, "Chỉ cảnh báo khi realtime", group=gAlert)

//===================== LABEL HIỂN THỊ =====================//
showEntryText = input.bool(true, "Entry", group=gLabel)
showStpText   = input.bool(true, "STP", group=gLabel)
showTp1Text   = input.bool(true, "TP1", group=gLabel)
showTp2Text   = input.bool(true, "TP2", group=gLabel)
showTp3Text   = input.bool(true, "TP3", group=gLabel)
showPlotLevels= input.bool(true, "Hiển thị đường Entry/STP/TP bằng plot chuẩn", group=gLabel)
showFullSignalLabel = input.bool(true, "Hiển thị label chi tiết Entry/STP/TP", group=gLabel)
priceDisplayMode = input.string("Auto", "Định dạng giá Entry/STP/TP", options=["Auto", "Mintick", "Decimal 1", "Decimal 2", "Grain .2"], group=gLabel)

//===================== TP & STP =====================//
stpPlusPullLine = input.float(0.0, "Tỉ lệ +STP Pullback line, %", group=gTP, step=0.1)
stpPlusMid      = input.float(0.0, "Tỉ lệ +STP Pullback về MID, %", group=gTP, step=0.1)
tp1RR           = input.float(0.3, "TP1 R:R", group=gTP, step=0.1)
tp2RR           = input.float(0.6, "TP2 R:R", group=gTP, step=0.1)
tp3RR           = input.float(1.0, "TP3 R:R", group=gTP, step=0.1)
useFixedStp     = input.bool(false, "Bật STP theo khoảng giá cố định", group=gTP)
fixedStp        = input.float(1.0, "Khoảng cách STP cố định", group=gTP, step=0.1)
stpAtrMult      = input.float(1.0, "Hệ số ATR bổ sung STP", group=gTP, step=0.1)
useAgriFixedStp = input.bool(true, "Tự động STP 5 giá cho Ngô/Lúa mì/Đậu tương", group=gTP)
agriFixedStp    = input.float(5.0, "STP nông sản cố định (giá)", group=gTP, step=0.25)
useTickLevelMode = input.bool(false, "Tính Entry/SL/TP theo tick sản phẩm", group=gTP)
entryOffsetTicks = input.int(0, "Entry lệch thêm bao nhiêu tick", group=gTP, minval=-500, maxval=500)
slTicks          = input.int(25, "SL/STP số tick", group=gTP, minval=1, maxval=5000)
tp1Ticks         = input.int(8, "TP1 số tick", group=gTP, minval=1, maxval=5000)
tp2Ticks         = input.int(15, "TP2 số tick", group=gTP, minval=1, maxval=5000)
tp3Ticks         = input.int(25, "TP3 số tick", group=gTP, minval=1, maxval=5000)

//===================== GIỚI HẠN =====================//
maxOrdersInTrend = input.int(100, "Số lệnh tối đa trong xu hướng", group=gLimit, minval=1)
oneOrderInNBars  = input.int(5, "Chỉ tối đa 1 lệnh trong N nến", group=gLimit, minval=1)

//===================== CƠ BẢN =====================//
kingPeriod       = input.int(10, "KING PERIOD", group=gKing, minval=1)
src              = input.source(close, "Nguồn", group=gKing)
changeKingFactor = input.bool(true, "THAY ĐỔI CÁCH TÍNH HỆ SỐ KING", group=gKing)
maType           = input.string("EMA", "Loại trung bình", options=["EMA", "SMA", "WMA", "RMA"], group=gKing)

//===================== HỆ SỐ KING (MÃ HÓA ẨN) =====================//
mainFactor       = input.int(18, "Xu hướng chính", group=gKingCoef, minval=1)
mediumFactor     = input.int(15, "Trung hạn", group=gKingCoef, minval=1)
stpPullFactor    = input.int(12, "STP cho Pullback line", group=gKingCoef, minval=1)
pullLineFactor   = input.int(6,  "Pullback Line", group=gKingCoef, minval=1)
stpMidFactor     = input.int(18, "STP cho Pullback Trung Hạn", group=gKingCoef, minval=1)

//===================== THỐNG KÊ =====================//
enableWinLoseStats = input.bool(true, "Bật thống kê Win/Lose", group=gStats)
boldByNetProfit    = input.bool(true, "Nền đậm theo Lãi ròng", group=gStats)
statCorner          = input.string("Bottom Right", "Vị trí thống kê", options=["Bottom Right", "Bottom Left", "Top Right", "Top Left"], group=gStats)

//===================== RSI FILTERS =====================//
rsiLen       = input.int(14, "Chiều dài RSI", group=gRSI, minval=1)
rsiMaxRange  = input.float(20, "Biên độ RSI TỐI ĐA", group=gRSI, step=0.5)
useRsiTrend  = input.bool(true, "Bật lọc RSI xu hướng", group=gRSITrend)
buyRsiMin    = input.float(45, "Chỉ MUA khi RSI >", group=gRSITrend, step=0.5)
sellRsiMax   = input.float(55, "Chỉ BÁN khi RSI <", group=gRSITrend, step=0.5)
useRsiExtreme = input.bool(true, "Bật lọc RSI cực trị", group=gRSIExt)
blockBuyRsi   = input.float(68, "Ngưỡng RSI tối đa chặn MUA nếu ≥", group=gRSIExt, step=0.5)
blockSellRsi  = input.float(32, "Ngưỡng RSI tối thiểu chặn BÁN nếu ≤", group=gRSIExt, step=0.5)
useRsiHistory   = input.bool(true, "Bật lọc RSI đã từng vượt ngưỡng", group=gRSIHis)
historyBuyBlock = input.float(85, "Xu hướng TĂNG: Chặn BUY nếu RSI từng ≥", group=gRSIHis, step=0.5)
historySellBlock= input.float(15, "Xu hướng GIẢM: Chặn BÁN nếu RSI từng ≤", group=gRSIHis, step=0.5)
rsiHistoryLookback = input.int(10, "Số nến nhìn lại RSI lịch sử", group=gRSIHis, minval=2)

//===================== BBNDS CORE =====================//
bbndsLength     = input.int(50, "BBNDS Length", group=gBB, minval=1)
bbndsSmoothing  = input.int(5, "BBNDS Smoothing", group=gBB, minval=1)
showBbnds       = input.bool(false, "Hiển thị BBNDS", group=gBB)

//===================== PULLBACK SETUP =====================//
acceptWeakCandle = input.bool(true, "Chấp nhận nến yếu Doji/Hammer", group=gPull)
closeTolerance   = input.float(0.2, "Dung sai đóng trong mây %", group=gPull, step=0.1)
allowPullbackMid = input.bool(true, "Cho phép Pullback về Mid", group=gPull)
minBodyRatio     = input.float(0.20, "Thân nến tối thiểu xác nhận", group=gPull, step=0.05)

//===================== MÂY PHỤ =====================//
showMidCloud       = input.bool(false, "Hiển thị mây phụ giữa Pullback–Mid", group=gMid)
midCloudUpColor    = input.color(color.new(color.blue, 78), "Màu mây phụ Up", group=gMid)
midCloudDownColor  = input.color(color.new(color.red, 78), "Màu mây phụ Down", group=gMid)
midCloudSideColor  = input.color(color.new(color.yellow, 86), "Màu mây phụ Sideway", group=gMid)

//===================== MÂY CHÍNH =====================//
cloudGap           = input.float(0.006, "Khoảng cách mây với nến", group=gCloud, step=0.001)
cloudLightWidth    = input.float(0.75, "Độ dày mây nhạt", group=gCloud, step=0.05)
cloudDarkWidth     = input.float(0.48, "Độ dày mây đậm", group=gCloud, step=0.05)
cloudVolExpand     = input.float(1.45, "Độ co giãn mây theo biến động", group=gCloud, step=0.05)
cloudBaseSmooth    = input.int(13, "Độ mượt nền mây", group=gCloud, minval=1)
cloudAtrSmooth     = input.int(10, "Độ mượt ATR mây", group=gCloud, minval=1)
cloudDynMin        = input.float(0.80, "Co giãn mây tối thiểu", group=gCloud, step=0.05)
cloudDynMax        = input.float(3.50, "Co giãn mây tối đa", group=gCloud, step=0.05)
cloudEdgeSmooth    = input.int(4, "Làm mềm mép mây", group=gCloud, minval=1)
cloudDetachGap     = input.float(0.006, "Khoảng tách mây khỏi nến", group=gCloud, step=0.001)
cloudCandleExpand   = input.float(1.55, "Co giãn mây nhạt theo thân nến", group=gCloud, step=0.05)
cloudRangeLookback = input.int(20, "Số nến đo biên độ mây", group=gCloud, minval=2)
cloudSoftAnchorLen = input.int(1, "Nền mây tránh bám nến", group=gCloud, minval=1)

//===================== V27 PULLBACK CLOUD CONTROLS - SETTINGS MASTER =====================//
cloudDistanceTicks = input.int(1, "V25 - Khoảng cách mây tới nến (tick)", group=gCloud, minval=0, maxval=200)
cloudLightWidthV22 = input.float(2.60, "V25 - Độ rộng mây nhạt", group=gCloud, minval=0.20, maxval=8.00, step=0.10)
cloudDarkWidthV22  = input.float(0.50, "V25 - Độ rộng mây đậm", group=gCloud, minval=0.05, maxval=3.00, step=0.05)
cloudPullSensV22   = input.float(3.00, "V25 - Độ nhạy Pullback", group=gCloud, minval=0.50, maxval=6.00, step=0.10)
cloudSmoothV22     = input.int(1, "V25 - Độ mượt mây nhạt", group=gCloud, minval=1, maxval=30)
cloudDarkSmoothV22 = input.int(5, "V25 - Độ mượt mây đậm", group=gCloud, minval=1, maxval=40)
cloudTrendBlendV22 = input.float(0.22, "V25 - Pha Trend Cloud", group=gCloud, minval=0.00, maxval=1.00, step=0.05)
cloudAdaptiveV22   = input.bool(true, "V25 - Adaptive theo lực xu hướng", group=gCloud)
cloudFollowCandleV22 = input.bool(true, "V25 - Mây nhạt răng cưa theo nến", group=gCloud)
cloudTouchModeV26 = input.bool(true, "V26 - Mây nhạt chạm pullback nến", group=gCloud)
cloudTouchDepthV26 = input.float(0.45, "V26 - Độ ăn vào râu nến", group=gCloud, minval=0.00, maxval=1.50, step=0.05)
cloudTouchGapMultV26 = input.float(0.12, "V26 - Giữ khoảng hở khi chạm", group=gCloud, minval=0.00, maxval=1.00, step=0.05)
useDarkCloudSidewayV27 = input.bool(true, "V27 - SIDEWAY khi nến chạm mây đậm", group=gCloud)
darkCloudSidewayBarsV27 = input.int(1, "V27 - Số nến chạm mây đậm xác nhận", group=gCloud, minval=1, maxval=5)
darkCloudCloseInsideV27 = input.bool(false, "V27 - Chỉ tính khi đóng cửa vào mây đậm", group=gCloud)
darkCloudHoldBarsV27 = input.int(2, "V27 - Giữ SIDEWAY sau chạm mây đậm", group=gCloud, minval=0, maxval=10)
strictDarkOnlySidewayV28 = input.bool(true, "V28 - Chỉ SIDEWAY khi chạm mây đậm", group=gCloud)
usePriorDarkCloudV29 = input.bool(true, "V29 - Dùng mây đậm của nến trước", group=gCloud)
priorDarkBreakReverseV29 = input.bool(true, "V29 - Xuyên mây đậm trước thì đổi xu hướng", group=gCloud)
priorDarkBreakCloseV29 = input.bool(true, "V29 - Đổi xu hướng khi đóng cửa xuyên mây đậm", group=gCloud)
cloudLightAvgBarsV30 = input.int(2, "V30 - Mây nhạt lấy TB nến trước", group=gCloud, minval=1, maxval=10)
cloudDarkAvgBarsV30 = input.int(5, "V30 - Mây đậm lấy TB nến trước", group=gCloud, minval=1, maxval=20)
cloudUsePriorAvgV30 = input.bool(true, "V30 - Chỉ dùng TB của nến đã đóng", group=gCloud)
cloudLightFlexV31 = input.bool(true, "V31 - Mây nhạt TB linh hoạt 2-3 nến", group=gCloud)
cloudVolThresholdV31 = input.float(1.15, "V31 - Ngưỡng biến động dùng TB 3 nến", group=gCloud, minval=0.50, maxval=3.00, step=0.05)
cloudDarkFlatV31 = input.bool(true, "V31 - Mây đậm dạng thanh ngang 5 nến", group=gCloud)
cloudDarkFlatBarsV31 = input.int(5, "V31 - Số nến giữ thanh ngang mây đậm", group=gCloud, minval=2, maxval=20)
cloudLinkLightDarkV32 = input.bool(true, "V32 - Mây nhạt/đậm liền mạch không tách", group=gCloud)
cloudLinkBufferTicksV32 = input.int(0, "V32 - Khe hở giữa mây nhạt và mây đậm (tick)", group=gCloud, minval=0, maxval=20)
priorDarkBreakBufferTicksV29 = input.int(0, "V29 - Buffer xuyên mây đậm (tick)", group=gCloud, minval=0, maxval=200)
useDarkMemoryV33 = input.bool(true, "V33 - Nhớ vùng mây đậm trước khi mỏng", group=gCloud)
darkThinRatioV33 = input.float(0.45, "V33 - Ngưỡng mây đậm mỏng dạng sợi", group=gCloud, minval=0.10, maxval=0.90, step=0.05)
darkMemoryBarsV33 = input.int(8, "V33 - Số nến giữ vùng mây đậm cũ", group=gCloud, minval=1, maxval=50)
darkMemoryUseForBreakV33 = input.bool(true, "V33 - Dùng vùng cũ để xét đổi xu hướng", group=gCloud)
darkMemoryRequireTrendConfirmV33 = input.bool(true, "V33 - Xuyên vùng cũ cần đủ lực xu hướng", group=gCloud)
darkMemoryShowZoneV33 = input.bool(false, "V33 - Hiển thị vùng nhớ mây đậm", group=gCloud)
useDarkZoneV34 = input.bool(true, "V34 - Mây đậm vùng ngang 10-15 nến", group=gCloud)
darkZoneFastBarsV34 = input.int(10, "V34 - Mây đậm nhanh (nến)", group=gCloud, minval=5, maxval=20)
darkZoneSlowBarsV34 = input.int(15, "V34 - Mây đậm chậm (nến)", group=gCloud, minval=8, maxval=30)
darkZoneVolThresholdV34 = input.float(1.20, "V34 - Biến động cao dùng 15 nến", group=gCloud, minval=0.50, maxval=3.00, step=0.05)
darkZoneFlatHoldV34 = input.int(5, "V34 - Giữ thanh ngang mây đậm", group=gCloud, minval=1, maxval=20)
darkZoneMedianBlendV34 = input.float(0.35, "V34 - Pha vùng trung vị 10-15", group=gCloud, minval=0.00, maxval=1.00, step=0.05)
useDarkMemoryV35 = input.bool(true, "V35 - Chạm vùng nhớ => SIDEWAY", group=gCloud)
darkMemoryBreakReverseV35 = input.bool(true, "V35 - Vượt vùng nhớ => đổi xu hướng", group=gCloud)
darkMemoryBreakCloseV35 = input.bool(true, "V35 - Đổi xu hướng khi đóng cửa vượt vùng nhớ", group=gCloud)
darkMemoryBreakConfirmV35 = input.bool(true, "V35 - Vượt vùng nhớ cần EMA/MACD/RSI/DI xác nhận", group=gCloud)
darkMemoryTouchHoldV35 = input.int(2, "V35 - Giữ SIDEWAY sau khi chạm vùng nhớ", group=gCloud, minval=0, maxval=10)
darkMemoryBreakBufferTicksV35 = input.int(0, "V35 - Buffer vượt vùng nhớ (tick)", group=gCloud, minval=0, maxval=200)
useNearestDarkMemoryV36 = input.bool(true, "V36 - Dùng vùng nhớ gần nhất liên tục", group=gCloud)
darkMemoryTouchForceSidewayV36 = input.bool(true, "V36 - Chạm vùng nhớ gần nhất bắt buộc SIDEWAY", group=gCloud)
darkMemoryBreakForceTrendV36 = input.bool(true, "V36 - Giá vượt vùng nhớ gần nhất đổi xu hướng", group=gCloud)
darkMemoryBreakSoftConfirmV36 = input.bool(true, "V36 - Xác nhận lực mềm khi vượt vùng nhớ", group=gCloud)
darkMemoryKeepDuringSidewayV36 = input.int(80, "V36 - Giữ vùng nhớ khi SIDEWAY (nến)", group=gCloud, minval=5, maxval=300)
useBidirectionalDarkBreakV37 = input.bool(true, "V37 - Vượt vùng nhớ cả 2 chiều", group=gCloud)
darkMemoryAnyZoneBreakV37 = input.bool(true, "V37 - Xét mọi vùng nhớ UP/DOWN còn hiệu lực", group=gCloud)
useDirectMemoryBreakV38 = input.bool(true, "V38 - Vượt vùng nhớ đổi xu hướng trực tiếp", group=gCloud)
darkMemoryBreakUseWickV38 = input.bool(true, "V38 - Tính cả râu nến vượt vùng nhớ", group=gCloud)
darkMemoryBreakNeedCloseV38 = input.bool(false, "V38 - Bắt buộc đóng cửa vượt vùng nhớ", group=gCloud)
useFixedDarkMemoryV39 = input.bool(true, "V39 - Cố định vùng nhớ tại nến chạm", group=gCloud)
darkMemoryBreakNeedCloseV39 = input.bool(true, "V39 - Đổi xu hướng khi đóng cửa vượt vùng nhớ cố định", group=gCloud)
darkMemoryResetOnNewTrendV39 = input.bool(true, "V39 - Xóa vùng nhớ sau khi đổi xu hướng", group=gCloud)

showTrendStartTag  = input.bool(true, "Hiển thị hậu tố Xu hướng ở đầu mây", group=gCloud)
showSidewayTag     = input.bool(true, "Hiển thị nhãn SIDEWAY đầu vùng vàng", group=gCloud)
sidewayAtr         = input.float(0.08, "Ngưỡng Sideway ATR", group=gCloud, step=0.01)
adxLen             = input.int(14, "ADX Length", group=gCloud)
adxMin             = input.float(12, "ADX tối thiểu xác nhận xu hướng", group=gCloud, step=0.5)
adxSidewayMax      = input.float(10, "ADX tối đa cho Sideway", group=gCloud, step=0.5)
diSpreadMin        = input.float(5, "Độ lệch DI tối thiểu", group=gCloud, step=0.5)
trendSmoothBars    = input.int(3, "Số nến xác nhận chuyển xu hướng", group=gCloud, minval=1)
useTrendMemory     = input.bool(true, "Bật Trend Memory", group=gCloud)

//===================== BỘ LỌC THỜI GIAN =====================//
useSessionFilter = input.bool(false, "Bật lọc thời gian", group=gSession)
sessionInput     = input.session("0000-2359", "Khung thời gian giao dịch", group=gSession)

//===================== MÀU SẮC =====================//
colCloudUpDark     = input.color(color.new(color.blue, 25), "Màu mây Up đậm", group=gStyle)
colCloudUpLight    = input.color(color.new(color.blue, 75), "Màu mây Up nhạt", group=gStyle)
colCloudDownDark   = input.color(color.new(color.red, 25), "Màu mây Down đậm", group=gStyle)
colCloudDownLight  = input.color(color.new(color.red, 78), "Màu mây Down nhạt", group=gStyle)
colCloudSideway    = input.color(color.new(color.yellow, 65), "Màu mây SIDEWAY", group=gStyle)
colPullLine        = input.color(color.gray, "Màu Pullback line", group=gStyle)

//===================== FUNCTIONS =====================//
f_ma(_src, _len) =>
    maType == "EMA" ? ta.ema(_src, _len) : maType == "SMA" ? ta.sma(_src, _len) : maType == "WMA" ? ta.wma(_src, _len) : ta.rma(_src, _len)

f_size(_s) =>
    _s == "tiny" ? size.tiny : _s == "small" ? size.small : _s == "normal" ? size.normal : size.large

f_pos(_s) =>
    _s == "Bottom Left" ? position.bottom_left : _s == "Top Right" ? position.top_right : _s == "Top Left" ? position.top_left : position.bottom_right

f_is_grain_symbol() =>
    str.contains(syminfo.ticker, "ZC") or str.contains(syminfo.ticker, "ZW") or str.contains(syminfo.ticker, "ZS") or str.contains(syminfo.ticker, "KE") or str.contains(syminfo.ticker, "MWE") or str.contains(syminfo.root, "ZC") or str.contains(syminfo.root, "ZW") or str.contains(syminfo.root, "ZS") or str.contains(syminfo.root, "KE") or str.contains(syminfo.root, "MWE")

f_grain_price_text(_price) =>
    _p = math.round_to_mintick(_price)
    _whole = math.floor(_p)
    _frac = _p - _whole
    _eighth = int(math.round(_frac / 0.125))
    _wholeAdj = _eighth >= 8 ? _whole + 1 : _whole
    _eighthAdj = _eighth >= 8 ? 0 : _eighth
    str.tostring(_wholeAdj, "#") + "." + str.tostring(_eighthAdj)

f_price(_price) =>
    _p = math.round_to_mintick(_price)
    priceDisplayMode == "Mintick" ? str.tostring(_p, format.mintick) : priceDisplayMode == "Decimal 1" ? str.tostring(_p, "#.0") : priceDisplayMode == "Decimal 2" ? str.tostring(_p, "#.00") : priceDisplayMode == "Grain .2" ? f_grain_price_text(_p) : f_is_grain_symbol() ? f_grain_price_text(_p) : str.tostring(_p, format.mintick)

f_text(_side, _entry, _stp, _tp1, _tp2, _tp3, _isPreview) =>
    txt = _side + (_isPreview ? " " + previewSuffix : "")
    txt += showEntryText ? "\nEntry: " + f_price(_entry) : ""
    txt += showStpText   ? "\nSTP: "   + f_price(_stp) : ""
    txt += showTp1Text   ? "\nTP1: "   + f_price(_tp1) : ""
    txt += showTp2Text   ? "\nTP2: "   + f_price(_tp2) : ""
    txt += showTp3Text   ? "\nTP3: "   + f_price(_tp3) : ""
    txt

//===================== CORE =====================//
atr = ta.atr(kingPeriod)
atrAvg = ta.sma(atr, kingPeriod)
volRatio = atrAvg > 0 ? atr / atrAvg : 1.0
candleBody = math.abs(close - open)
candleRange = high - low
candlePower = candleRange > 0 ? candleBody / candleRange : 0.0
dynWidth = math.max(0.55, 1.0 + (volRatio - 1.0) * cloudVolExpand + candlePower * 0.25)

// V25: changeKingFactor không còn bị treo.
// Bật = dùng các hệ số KING người dùng cài đặt. Tắt = tự tính theo KING PERIOD để trở về cấu trúc mặc định.
mainFactorLive = changeKingFactor ? mainFactor : math.max(2, kingPeriod * 2)
mediumFactorLive = changeKingFactor ? mediumFactor : math.max(2, int(math.round(kingPeriod * 1.5)))
stpPullFactorLive = changeKingFactor ? stpPullFactor : math.max(2, int(math.round(kingPeriod * 1.2)))
pullLineFactorLive = changeKingFactor ? pullLineFactor : math.max(2, int(math.round(kingPeriod * 0.6)))
stpMidFactorLive = changeKingFactor ? stpMidFactor : math.max(2, kingPeriod * 2)

basis = f_ma(src, kingPeriod)
mainSlow = f_ma(src, mainFactorLive)
mediumLine = f_ma(src, mediumFactorLive)
pullLine = f_ma(src, pullLineFactorLive)
stpPullLine = f_ma(src, stpPullFactorLive)
stpMidLine = f_ma(src, stpMidFactorLive)

[diplus, diminus, adx] = ta.dmi(adxLen, adxLen)
plusDI = diplus
minusDI = diminus
rsi = ta.rsi(close, rsiLen)
inSession = not useSessionFilter or not na(time(timeframe.period, sessionInput))

emaDistance = math.abs(basis - mainSlow)
emaSlope = basis - basis[1]
mainSlope = mainSlow - mainSlow[1]

// V25: showNoiseFilter điều khiển trực tiếp độ chặt của Trend/Sideway.
noiseTrendMult = showNoiseFilter ? 1.00 : 0.55
noiseSidewayMult = showNoiseFilter ? 1.00 : 0.35

//===================== KING CLOUD ENGINE V26 - PULLBACK TOUCH CLOUD =====================//
// Mục tiêu V26:
// - Không chỉ tạo khoảng cách giữa nến và mây, mà đưa mây nhạt vào đúng vùng râu/thân pullback để nến có thể chạm mây.
// - Settings vẫn điều khiển trực tiếp: Distance, Light Width, Dark Width, Smooth, Sensitivity, Trend Blend.
// - Giữ nguyên tên biến upLightTop/upLightBot/downLightTop/downLightBot/upDarkBot/downDarkTop
//   để Signal Engine BUY/SELL cũ vẫn hoạt động đầy đủ.

cloudRange = math.max(high - low, syminfo.mintick)
cloudAvgRange = ta.rma(cloudRange, cloudRangeLookback)
cloudBody = math.abs(close - open)
cloudBodyRatio = cloudRange > 0 ? cloudBody / cloudRange : 0.0
cloudRangeRatio = cloudAvgRange > 0 ? cloudRange / cloudAvgRange : 1.0

cloudAtrRaw = ta.atr(kingPeriod)
cloudAtr = ta.rma(cloudAtrRaw, math.max(2, cloudAtrSmooth))
cloudAtrAvg = ta.rma(cloudAtr, 50)
cloudAtrRatio = cloudAtrAvg > 0 ? cloudAtr / cloudAtrAvg : 1.0

//===================== SMART FORCE CORE: MA10/20/50 + MACD + RSI + PHÂN KỲ =====================//
cloudMa10 = f_ma(src, 10)
cloudMa20 = f_ma(src, 20)
cloudMa50 = f_ma(src, 50)
cloudMaBaseRaw = cloudMa10 * 0.48 + cloudMa20 * 0.34 + cloudMa50 * 0.18
cloudMaBase = ta.rma(cloudMaBaseRaw, math.max(3, cloudBaseSmooth))
cloudMaSlope = cloudMaBase - cloudMaBase[1]
cloudMaSpread = math.abs(cloudMa10 - cloudMa50)
cloudMaSpreadNorm = cloudAtr > 0 ? cloudMaSpread / cloudAtr : 0.0

[cloudMacdLine, cloudMacdSignal, cloudMacdHist] = ta.macd(src, 12, 26, 9)
cloudMacdHistSmooth = ta.rma(cloudMacdHist, 3)
cloudMacdBull = cloudMacdLine > cloudMacdSignal and cloudMacdHistSmooth >= cloudMacdHistSmooth[1]
cloudMacdBear = cloudMacdLine < cloudMacdSignal and cloudMacdHistSmooth <= cloudMacdHistSmooth[1]
cloudRsi = ta.rsi(src, rsiLen)
cloudRsiSmooth = ta.rma(cloudRsi, 3)

cloudDivPivotLen = 5
cloudDivMemoryBars = 18
cloudPricePivotLow = ta.pivotlow(low, cloudDivPivotLen, cloudDivPivotLen)
cloudPricePivotHigh = ta.pivothigh(high, cloudDivPivotLen, cloudDivPivotLen)
cloudRsiPivotLow = ta.pivotlow(cloudRsi, cloudDivPivotLen, cloudDivPivotLen)
cloudRsiPivotHigh = ta.pivothigh(cloudRsi, cloudDivPivotLen, cloudDivPivotLen)
cloudPrevPricePivotLow = ta.valuewhen(not na(cloudPricePivotLow), cloudPricePivotLow, 1)
cloudPrevPricePivotHigh = ta.valuewhen(not na(cloudPricePivotHigh), cloudPricePivotHigh, 1)
cloudPrevRsiPivotLow = ta.valuewhen(not na(cloudRsiPivotLow), cloudRsiPivotLow, 1)
cloudPrevRsiPivotHigh = ta.valuewhen(not na(cloudRsiPivotHigh), cloudRsiPivotHigh, 1)
cloudBullDivRaw = not na(cloudPricePivotLow) and not na(cloudRsiPivotLow) and not na(cloudPrevPricePivotLow) and not na(cloudPrevRsiPivotLow) and cloudPricePivotLow < cloudPrevPricePivotLow and cloudRsiPivotLow > cloudPrevRsiPivotLow
cloudBearDivRaw = not na(cloudPricePivotHigh) and not na(cloudRsiPivotHigh) and not na(cloudPrevPricePivotHigh) and not na(cloudPrevRsiPivotHigh) and cloudPricePivotHigh > cloudPrevPricePivotHigh and cloudRsiPivotHigh < cloudPrevRsiPivotHigh
cloudBullDiv = ta.barssince(cloudBullDivRaw) <= cloudDivMemoryBars
cloudBearDiv = ta.barssince(cloudBearDivRaw) <= cloudDivMemoryBars

cloudMaBullScore = cloudMa10 > cloudMa20 and cloudMa20 > cloudMa50 ? 2.0 : cloudMa10 > cloudMa20 and close > cloudMa50 ? 1.25 : close > cloudMa20 ? 0.55 : 0.0
cloudMaBearScore = cloudMa10 < cloudMa20 and cloudMa20 < cloudMa50 ? 2.0 : cloudMa10 < cloudMa20 and close < cloudMa50 ? 1.25 : close < cloudMa20 ? 0.55 : 0.0
cloudMacdBullScore = cloudMacdBull ? 1.0 : 0.0
cloudMacdBearScore = cloudMacdBear ? 1.0 : 0.0
cloudRsiBullScore = cloudRsiSmooth > 55 ? 1.0 : cloudRsiSmooth > 50 ? 0.55 : 0.0
cloudRsiBearScore = cloudRsiSmooth < 45 ? 1.0 : cloudRsiSmooth < 50 ? 0.55 : 0.0
cloudDivBullScore = cloudBullDiv ? 0.75 : 0.0
cloudDivBearScore = cloudBearDiv ? 0.75 : 0.0
cloudBullScoreRaw = cloudMaBullScore + cloudMacdBullScore + cloudRsiBullScore + cloudDivBullScore
cloudBearScoreRaw = cloudMaBearScore + cloudMacdBearScore + cloudRsiBearScore + cloudDivBearScore
cloudSmartScore = ta.rma(cloudBullScoreRaw - cloudBearScoreRaw, 4)
cloudTrendStrength = ta.rma(math.min(1.80, math.abs(cloudSmartScore) / 3.6 + math.min(0.80, cloudMaSpreadNorm / 4.0)), 4)

//===================== V25 SETTINGS MASTER: TOÀN BỘ MENU NỐI TRỰC TIẾP VÀO GIAO DIỆN MÂY =====================//
// Mục tiêu V25:
// - Mọi thanh chỉnh trong nhóm CẤU HÌNH MÂY đều có tác dụng trực tiếp lên hình dáng mây.
// - Khoảng cách, độ rộng, độ mượt, độ bám nến, độ co giãn, sideway đều tách rõ chức năng.
// - Mây nhạt vẫn là vùng Pullback Entry; mây đậm là lõi xu hướng gọn hơn.

// 1) KHOẢNG CÁCH MÂY TỚI NẾN: nối trực tiếp 3 input khoảng cách.
// cloudDistanceTicks: chỉnh theo tick, thấy dịch ngay.
// cloudGap + cloudDetachGap: giữ menu cũ nhưng quy đổi trực tiếp theo ATR để vẫn có tác dụng rõ.
cloudDistanceTickPart = cloudDistanceTicks * syminfo.mintick
cloudGapPart = cloudAtr * math.max(0.0, cloudGap) * 35.0
cloudDetachPart = cloudAtr * math.max(0.0, cloudDetachGap) * 22.0
entryGapBase = math.max(0.0, cloudDistanceTickPart + cloudGapPart + cloudDetachPart)

// 2) ĐỘ MƯỢT: nối cả menu cũ và menu mới.
// cloudEdgeSmooth/cloudBaseSmooth tạo mượt nền; cloudSmoothV22 quyết định răng cưa mây nhạt.
lightSmoothLive = cloudFollowCandleV22 ? math.max(1, cloudSmoothV22) : math.max(1, math.round((cloudSmoothV22 + cloudEdgeSmooth) / 2.0))
baseSmoothLive = math.max(1, math.round((cloudBaseSmooth + cloudEdgeSmooth + cloudSmoothV22) / 3.0))
darkSmoothLive = math.max(1, math.round((cloudDarkSmoothV22 + cloudEdgeSmooth) / 2.0))

// 3) CO GIÃN ĐỘNG: cloudDynMin/cloudDynMax thực sự khóa biên độ co giãn.
rangeInfluence = cloudRangeRatio * cloudVolExpand * 0.42
bodyInfluence = cloudBodyRatio * cloudCandleExpand * 0.36
atrInfluence = cloudAtrRatio * 0.18
trendInfluence = cloudTrendStrength * 0.26
expandRawLive = 0.60 + rangeInfluence + bodyInfluence + atrInfluence + trendInfluence
expandLive = math.max(cloudDynMin, math.min(cloudDynMax, expandRawLive))

// 4) ADAPTIVE: trend mạnh thì áp sát hơn; trend yếu thì mây nhạt rộng hơn.
adaptiveTight = cloudAdaptiveV22 ? math.max(0.45, 1.0 - math.min(0.42, cloudTrendStrength * 0.22)) : 1.0
adaptiveWide = cloudAdaptiveV22 ? 1.0 + math.min(0.85, math.max(0.0, 1.0 - cloudTrendStrength) * 0.45) : 1.0
entryGap = entryGapBase * adaptiveTight

// 5) PULLBACK SENSITIVITY: càng cao thì mây nhạt càng ăn vào râu nến và răng cưa theo nến.
pullSens = cloudPullSensV22 / 3.0
wickOverlap = cloudAtr * math.max(0.0, 0.015 + 0.055 * pullSens + 0.025 * cloudBodyRatio)

// V26 PULLBACK TOUCH MODE:
// V25 mới tạo được khoảng cách nến-mây nhưng nhiều nhịp hồi chưa chạm mây.
// V26 giảm tác dụng của khoảng cách khi bật chế độ chạm pullback và cho mép mây nhạt ăn vào vùng râu nến.
entryGapTouch = cloudTouchModeV26 ? entryGap * cloudTouchGapMultV26 : entryGap
pullbackWickDepth = cloudRange * (0.06 + 0.10 * pullSens + cloudTouchDepthV26 * 0.18)
touchOverlap = cloudTouchModeV26 ? math.max(wickOverlap, pullbackWickDepth) : wickOverlap

//===================== PULLBACK ANCHOR: NẾN ĐIỀU KHIỂN CHÍNH, MA/TREND CHỈ LÀ NỀN =====================//
// Xu hướng tăng: mép trên mây nhạt được kéo lên vùng đáy/râu nến để BUY pullback có thể chạm mây.
// Xu hướng giảm: mép dưới mây nhạt được kéo xuống vùng đỉnh/râu nến để SELL pullback có thể chạm mây.
upCandleAnchor = low + touchOverlap - entryGapTouch
downCandleAnchor = high - touchOverlap + entryGapTouch

upTrendAnchor = ta.ema(ta.lowest(low, math.max(1, cloudSoftAnchorLen)), math.max(1, baseSmoothLive))
downTrendAnchor = ta.ema(ta.highest(high, math.max(1, cloudSoftAnchorLen)), math.max(1, baseSmoothLive))
upMaPullAnchor = math.min(math.min(basis, pullLine), math.min(cloudMa10, cloudMa20))
downMaPullAnchor = math.max(math.max(basis, pullLine), math.max(cloudMa10, cloudMa20))

// Pha giao diện: cloudTrendBlendV22 tăng thì mây giống Trend Cloud hơn; giảm thì ôm nến/pullback hơn.
candleWeight = cloudFollowCandleV22 ? math.max(0.50, 0.90 - cloudTrendBlendV22 * 0.28) : math.max(0.35, 0.70 - cloudTrendBlendV22 * 0.20)
trendWeight = cloudTrendBlendV22 * 0.35
maWeight = math.max(0.0, 1.0 - candleWeight - trendWeight)

upNearRaw = upCandleAnchor * candleWeight + upMaPullAnchor * maWeight + upTrendAnchor * trendWeight
downNearRaw = downCandleAnchor * candleWeight + downMaPullAnchor * maWeight + downTrendAnchor * trendWeight

// Clamp trực tiếp theo Distance/Pullback Sensitivity để mây không bị MA kéo xa khỏi vùng nến.
// V26 dùng entryGapTouch + touchOverlap để mây nhạt thật sự nằm trong vùng pullback, không chỉ nằm cách nến.
clampExtra = cloudAtr * (0.06 + 0.12 * pullSens + 0.035 * expandLive)
upClampLow = low - entryGapTouch - clampExtra
upClampHigh = low + touchOverlap + clampExtra * 0.35
downClampLow = high - touchOverlap - clampExtra * 0.35
downClampHigh = high + entryGapTouch + clampExtra
upNearClamped = math.max(upClampLow, math.min(upClampHigh, upNearRaw))
downNearClamped = math.max(downClampLow, math.min(downClampHigh, downNearRaw))

upNearSoft = ta.rma(upNearClamped, lightSmoothLive)
downNearSoft = ta.rma(downNearClamped, lightSmoothLive)

//===================== ĐỘ DÀY MÂY: MỌI THANH WIDTH/EXPAND ĐIỀU KHIỂN TRỰC TIẾP =====================//
// Mây nhạt: chịu cloudLightWidth, V25 Light Width, cloudVolExpand, cloudCandleExpand, cloudDynMin/Max.
lightWidthAtrRaw = cloudAtr * cloudLightWidth * cloudLightWidthV22 * expandLive * adaptiveWide
lightWidthCandleRaw = cloudRange * (0.45 + 0.18 * pullSens + cloudTouchDepthV26 * 0.22) * cloudLightWidth * math.max(0.45, cloudLightWidthV22 / 2.60)
lightWidthRaw = cloudTouchModeV26 ? math.max(lightWidthAtrRaw, lightWidthCandleRaw) : lightWidthAtrRaw
lightWidth = math.max(syminfo.mintick, lightWidthRaw)

// Mây đậm: chịu cloudDarkWidth, V25 Dark Width, TrendStrength và DarkSmooth; mặc định gọn hơn mây nhạt.
darkWidthRaw = cloudAtr * cloudDarkWidth * cloudDarkWidthV22 * (0.34 + cloudTrendStrength * 0.16 + cloudAtrRatio * 0.05)
darkWidth = math.max(syminfo.mintick, darkWidthRaw)

//===================== V31 FLEX PULLBACK AVERAGE CLOUD =====================//
// Yêu cầu V31:
// - Mây nhạt lấy trung bình linh hoạt 2 hoặc 3 cây nến trước theo mức biến động.
// - Biến động mạnh/nhiễu cao: dùng 3 nến trước để mây nhạt ổn định hơn.
// - Biến động bình thường: dùng 2 nến trước để mây nhạt vẫn bám pullback.
// - Mây đậm lấy trung bình 5 nến trước và có thể giữ dạng THANH NGANG theo từng cụm 5 nến.

// Biến động tương đối để chọn mây nhạt 2 hoặc 3 nến.
cloudVolFlexV31 = ta.rma(cloudRangeRatio, 3)
cloudUseLight3V31 = cloudLightFlexV31 and cloudVolFlexV31 >= cloudVolThresholdV31

// V34: Mây đậm dùng vùng ngang ổn định 10-15 nến.
// Biến động cao/nhiễu lớn => dùng 15 nến để vùng đậm ít nhảy hơn.
// Biến động bình thường => dùng 10 nến để vùng đậm vẫn kịp phản ứng.
darkFastBarsV34 = math.max(1, darkZoneFastBarsV34)
darkSlowBarsV34 = math.max(darkFastBarsV34 + 1, darkZoneSlowBarsV34)
darkUseSlowV34 = useDarkZoneV34 and cloudVolFlexV31 >= darkZoneVolThresholdV34

//===================== UP CLOUD =====================//
// Xu hướng tăng: mây nhạt ngay dưới pullback của nến; mây đậm liền bên dưới.
upLightTopRawV31 = ta.rma(upNearSoft, lightSmoothLive)
upLightBotRawV31 = ta.rma(upLightTopRawV31 - lightWidth, math.max(1, lightSmoothLive + 1))
upLightTopAvg2V31 = cloudUsePriorAvgV30 ? ta.sma(upLightTopRawV31[1], 2) : ta.sma(upLightTopRawV31, 2)
upLightBotAvg2V31 = cloudUsePriorAvgV30 ? ta.sma(upLightBotRawV31[1], 2) : ta.sma(upLightBotRawV31, 2)
upLightTopAvg3V31 = cloudUsePriorAvgV30 ? ta.sma(upLightTopRawV31[1], 3) : ta.sma(upLightTopRawV31, 3)
upLightBotAvg3V31 = cloudUsePriorAvgV30 ? ta.sma(upLightBotRawV31[1], 3) : ta.sma(upLightBotRawV31, 3)
upLightTopFlexV31 = cloudUseLight3V31 ? upLightTopAvg3V31 : upLightTopAvg2V31
upLightBotFlexV31 = cloudUseLight3V31 ? upLightBotAvg3V31 : upLightBotAvg2V31
upLightTop = nz(upLightTopFlexV31, upLightTopRawV31)
upLightBot = nz(upLightBotFlexV31, upLightBotRawV31)

upDarkTopBaseV31 = upLightBot
upDarkBotRawV31 = ta.rma(upDarkTopBaseV31 - darkWidth, darkSmoothLive)
upDarkTopFastV34 = cloudUsePriorAvgV30 ? ta.sma(upDarkTopBaseV31[1], darkFastBarsV34) : ta.sma(upDarkTopBaseV31, darkFastBarsV34)
upDarkBotFastV34 = cloudUsePriorAvgV30 ? ta.sma(upDarkBotRawV31[1], darkFastBarsV34) : ta.sma(upDarkBotRawV31, darkFastBarsV34)
upDarkTopSlowV34 = cloudUsePriorAvgV30 ? ta.sma(upDarkTopBaseV31[1], darkSlowBarsV34) : ta.sma(upDarkTopBaseV31, darkSlowBarsV34)
upDarkBotSlowV34 = cloudUsePriorAvgV30 ? ta.sma(upDarkBotRawV31[1], darkSlowBarsV34) : ta.sma(upDarkBotRawV31, darkSlowBarsV34)
upDarkMidFastV34 = cloudUsePriorAvgV30 ? (ta.highest(upDarkTopBaseV31[1], darkFastBarsV34) + ta.lowest(upDarkBotRawV31[1], darkFastBarsV34)) / 2.0 : (ta.highest(upDarkTopBaseV31, darkFastBarsV34) + ta.lowest(upDarkBotRawV31, darkFastBarsV34)) / 2.0
upDarkMidSlowV34 = cloudUsePriorAvgV30 ? (ta.highest(upDarkTopBaseV31[1], darkSlowBarsV34) + ta.lowest(upDarkBotRawV31[1], darkSlowBarsV34)) / 2.0 : (ta.highest(upDarkTopBaseV31, darkSlowBarsV34) + ta.lowest(upDarkBotRawV31, darkSlowBarsV34)) / 2.0
upDarkTopAvgBaseV34 = darkUseSlowV34 ? upDarkTopSlowV34 : upDarkTopFastV34
upDarkBotAvgBaseV34 = darkUseSlowV34 ? upDarkBotSlowV34 : upDarkBotFastV34
upDarkMidBaseV34 = darkUseSlowV34 ? upDarkMidSlowV34 : upDarkMidFastV34
upDarkHeightBaseV34 = math.max(syminfo.mintick, upDarkTopAvgBaseV34 - upDarkBotAvgBaseV34)
upDarkTopAvgV31 = useDarkZoneV34 ? (upDarkTopAvgBaseV34 * (1.0 - darkZoneMedianBlendV34) + (upDarkMidBaseV34 + upDarkHeightBaseV34 / 2.0) * darkZoneMedianBlendV34) : (cloudUsePriorAvgV30 ? ta.sma(upDarkTopBaseV31[1], 5) : ta.sma(upDarkTopBaseV31, 5))
upDarkBotAvgV31 = useDarkZoneV34 ? (upDarkBotAvgBaseV34 * (1.0 - darkZoneMedianBlendV34) + (upDarkMidBaseV34 - upDarkHeightBaseV34 / 2.0) * darkZoneMedianBlendV34) : (cloudUsePriorAvgV30 ? ta.sma(upDarkBotRawV31[1], 5) : ta.sma(upDarkBotRawV31, 5))

var float upDarkTopFlatV31 = na
var float upDarkBotFlatV31 = na
var int upDarkFlatStartV31 = na
upDarkFlatHoldLiveV34 = useDarkZoneV34 ? darkZoneFlatHoldV34 : cloudDarkFlatBarsV31
upDarkNeedResetV31 = na(upDarkFlatStartV31) or bar_index - upDarkFlatStartV31 >= upDarkFlatHoldLiveV34
if upDarkNeedResetV31 and not na(upDarkTopAvgV31) and not na(upDarkBotAvgV31)
    upDarkTopFlatV31 := upDarkTopAvgV31
    upDarkBotFlatV31 := upDarkBotAvgV31
    upDarkFlatStartV31 := bar_index

// V32: Khóa liền mạch mây nhạt/đậm.
// Mây nhạt kết thúc ở đâu thì mây đậm bắt đầu ngay ở đó.
// Nếu chị muốn có khe hở rất nhỏ, chỉnh V32 - Khe hở tick > 0.
upLinkGapV32 = cloudLinkBufferTicksV32 * syminfo.mintick
upDarkTopLooseV31 = cloudDarkFlatV31 ? nz(upDarkTopFlatV31, upDarkTopBaseV31) : nz(upDarkTopAvgV31, upDarkTopBaseV31)
upDarkBotLooseV31 = cloudDarkFlatV31 ? nz(upDarkBotFlatV31, upDarkBotRawV31) : nz(upDarkBotAvgV31, upDarkBotRawV31)
upDarkTop = cloudLinkLightDarkV32 ? upLightBot - upLinkGapV32 : upDarkTopLooseV31
upDarkBotCandidateV32 = cloudLinkLightDarkV32 ? upDarkBotLooseV31 : upDarkBotLooseV31
upDarkBot = math.min(upDarkTop - syminfo.mintick, upDarkBotCandidateV32)

//===================== DOWN CLOUD =====================//
// Xu hướng giảm: mây nhạt ngay trên pullback của nến; mây đậm liền bên trên.
downLightBotRawV31 = ta.rma(downNearSoft, lightSmoothLive)
downLightTopRawV31 = ta.rma(downLightBotRawV31 + lightWidth, math.max(1, lightSmoothLive + 1))
downLightBotAvg2V31 = cloudUsePriorAvgV30 ? ta.sma(downLightBotRawV31[1], 2) : ta.sma(downLightBotRawV31, 2)
downLightTopAvg2V31 = cloudUsePriorAvgV30 ? ta.sma(downLightTopRawV31[1], 2) : ta.sma(downLightTopRawV31, 2)
downLightBotAvg3V31 = cloudUsePriorAvgV30 ? ta.sma(downLightBotRawV31[1], 3) : ta.sma(downLightBotRawV31, 3)
downLightTopAvg3V31 = cloudUsePriorAvgV30 ? ta.sma(downLightTopRawV31[1], 3) : ta.sma(downLightTopRawV31, 3)
downLightBotFlexV31 = cloudUseLight3V31 ? downLightBotAvg3V31 : downLightBotAvg2V31
downLightTopFlexV31 = cloudUseLight3V31 ? downLightTopAvg3V31 : downLightTopAvg2V31
downLightBot = nz(downLightBotFlexV31, downLightBotRawV31)
downLightTop = nz(downLightTopFlexV31, downLightTopRawV31)

downDarkBotBaseV31 = downLightTop
downDarkTopRawV31 = ta.rma(downDarkBotBaseV31 + darkWidth, darkSmoothLive)
downDarkBotFastV34 = cloudUsePriorAvgV30 ? ta.sma(downDarkBotBaseV31[1], darkFastBarsV34) : ta.sma(downDarkBotBaseV31, darkFastBarsV34)
downDarkTopFastV34 = cloudUsePriorAvgV30 ? ta.sma(downDarkTopRawV31[1], darkFastBarsV34) : ta.sma(downDarkTopRawV31, darkFastBarsV34)
downDarkBotSlowV34 = cloudUsePriorAvgV30 ? ta.sma(downDarkBotBaseV31[1], darkSlowBarsV34) : ta.sma(downDarkBotBaseV31, darkSlowBarsV34)
downDarkTopSlowV34 = cloudUsePriorAvgV30 ? ta.sma(downDarkTopRawV31[1], darkSlowBarsV34) : ta.sma(downDarkTopRawV31, darkSlowBarsV34)
downDarkMidFastV34 = cloudUsePriorAvgV30 ? (ta.highest(downDarkTopRawV31[1], darkFastBarsV34) + ta.lowest(downDarkBotBaseV31[1], darkFastBarsV34)) / 2.0 : (ta.highest(downDarkTopRawV31, darkFastBarsV34) + ta.lowest(downDarkBotBaseV31, darkFastBarsV34)) / 2.0
downDarkMidSlowV34 = cloudUsePriorAvgV30 ? (ta.highest(downDarkTopRawV31[1], darkSlowBarsV34) + ta.lowest(downDarkBotBaseV31[1], darkSlowBarsV34)) / 2.0 : (ta.highest(downDarkTopRawV31, darkSlowBarsV34) + ta.lowest(downDarkBotBaseV31, darkSlowBarsV34)) / 2.0
downDarkBotAvgBaseV34 = darkUseSlowV34 ? downDarkBotSlowV34 : downDarkBotFastV34
downDarkTopAvgBaseV34 = darkUseSlowV34 ? downDarkTopSlowV34 : downDarkTopFastV34
downDarkMidBaseV34 = darkUseSlowV34 ? downDarkMidSlowV34 : downDarkMidFastV34
downDarkHeightBaseV34 = math.max(syminfo.mintick, downDarkTopAvgBaseV34 - downDarkBotAvgBaseV34)
downDarkBotAvgV31 = useDarkZoneV34 ? (downDarkBotAvgBaseV34 * (1.0 - darkZoneMedianBlendV34) + (downDarkMidBaseV34 - downDarkHeightBaseV34 / 2.0) * darkZoneMedianBlendV34) : (cloudUsePriorAvgV30 ? ta.sma(downDarkBotBaseV31[1], 5) : ta.sma(downDarkBotBaseV31, 5))
downDarkTopAvgV31 = useDarkZoneV34 ? (downDarkTopAvgBaseV34 * (1.0 - darkZoneMedianBlendV34) + (downDarkMidBaseV34 + downDarkHeightBaseV34 / 2.0) * darkZoneMedianBlendV34) : (cloudUsePriorAvgV30 ? ta.sma(downDarkTopRawV31[1], 5) : ta.sma(downDarkTopRawV31, 5))

var float downDarkBotFlatV31 = na
var float downDarkTopFlatV31 = na
var int downDarkFlatStartV31 = na
downDarkFlatHoldLiveV34 = useDarkZoneV34 ? darkZoneFlatHoldV34 : cloudDarkFlatBarsV31
downDarkNeedResetV31 = na(downDarkFlatStartV31) or bar_index - downDarkFlatStartV31 >= downDarkFlatHoldLiveV34
if downDarkNeedResetV31 and not na(downDarkBotAvgV31) and not na(downDarkTopAvgV31)
    downDarkBotFlatV31 := downDarkBotAvgV31
    downDarkTopFlatV31 := downDarkTopAvgV31
    downDarkFlatStartV31 := bar_index

// V32: Khóa liền mạch mây nhạt/đậm cho xu hướng giảm.
// Mây nhạt kết thúc ở đâu thì mây đậm bắt đầu ngay ở đó.
downLinkGapV32 = cloudLinkBufferTicksV32 * syminfo.mintick
downDarkBotLooseV31 = cloudDarkFlatV31 ? nz(downDarkBotFlatV31, downDarkBotBaseV31) : nz(downDarkBotAvgV31, downDarkBotBaseV31)
downDarkTopLooseV31 = cloudDarkFlatV31 ? nz(downDarkTopFlatV31, downDarkTopRawV31) : nz(downDarkTopAvgV31, downDarkTopRawV31)
downDarkBot = cloudLinkLightDarkV32 ? downLightTop + downLinkGapV32 : downDarkBotLooseV31
downDarkTopCandidateV32 = cloudLinkLightDarkV32 ? downDarkTopLooseV31 : downDarkTopLooseV31
downDarkTop = math.max(downDarkBot + syminfo.mintick, downDarkTopCandidateV32)

//===================== V41 DARK THICK ZONE 10-15 - FREEZE DISPLAY =====================//
// Yêu cầu V41:
// 1) Mây xanh đậm: đáy vùng đậm được đóng băng theo bình quân 10-15 nến trước.
// 2) Mây đỏ đậm: vùng đậm được giữ dày và ổn định theo bình quân 10-15 nến trước.
// 3) Vùng đậm này là vùng nhớ gần nhất để xét SIDEWAY / đảo xu hướng.

v41UseSlowDark = cloudVolFlexV31 >= darkZoneVolThresholdV34
v41UpDarkTopAvg = v41UseSlowDark ? upDarkTopSlowV34 : upDarkTopFastV34
v41UpDarkBotAvg = v41UseSlowDark ? upDarkBotSlowV34 : upDarkBotFastV34
v41DownDarkTopAvg = v41UseSlowDark ? downDarkTopSlowV34 : downDarkTopFastV34
v41DownDarkBotAvg = v41UseSlowDark ? downDarkBotSlowV34 : downDarkBotFastV34

var float v41UpDarkTopFreeze = na
var float v41UpDarkBotFreeze = na
var int v41UpDarkFreezeBar = na
var float v41DownDarkTopFreeze = na
var float v41DownDarkBotFreeze = na
var int v41DownDarkFreezeBar = na

v41HoldBars = math.max(1, darkZoneFlatHoldV34)
v41NeedUpdateUp = na(v41UpDarkFreezeBar) or bar_index - v41UpDarkFreezeBar >= v41HoldBars
v41NeedUpdateDown = na(v41DownDarkFreezeBar) or bar_index - v41DownDarkFreezeBar >= v41HoldBars

if useDarkZoneV34 and v41NeedUpdateUp and not na(v41UpDarkTopAvg) and not na(v41UpDarkBotAvg)
    v41UpDarkTopFreeze := v41UpDarkTopAvg
    v41UpDarkBotFreeze := v41UpDarkBotAvg
    v41UpDarkFreezeBar := bar_index

if useDarkZoneV34 and v41NeedUpdateDown and not na(v41DownDarkTopAvg) and not na(v41DownDarkBotAvg)
    v41DownDarkTopFreeze := v41DownDarkTopAvg
    v41DownDarkBotFreeze := v41DownDarkBotAvg
    v41DownDarkFreezeBar := bar_index

// Đưa vùng đóng băng vào mây đậm hiển thị.
// UP: ưu tiên giữ đáy mây xanh đậm bình quân 10-15 nến trước; mép trên vẫn cố gắng liền với mây nhạt.
// DOWN: ưu tiên giữ đỉnh mây đỏ đậm bình quân 10-15 nến trước; mép dưới vẫn cố gắng liền với mây nhạt.
v41MinDarkHeight = math.max(syminfo.mintick, darkWidth * 0.80)

if useDarkZoneV34 and not na(v41UpDarkBotFreeze)
    upDarkBot := v41UpDarkBotFreeze
    upDarkTop := math.max(upLightBot - upLinkGapV32, upDarkBot + v41MinDarkHeight)

if useDarkZoneV34 and not na(v41DownDarkTopFreeze)
    downDarkTop := v41DownDarkTopFreeze
    downDarkBot := math.min(downLightTop + downLinkGapV32, downDarkTop - v41MinDarkHeight)


//===================== V34 DARK CLOUD MEMORY 10-15 =====================//
// Khi mây đậm co mỏng dạng sợi, vẫn giữ lại vùng mây đậm 10-15 nến trước khi mỏng.
// Nến sau chạm vùng cũ: nếu xuyên qua đủ điều kiện => đổi xu hướng; nếu chưa đủ => SIDEWAY.
upDarkHeightV33 = math.max(syminfo.mintick, upDarkTop - upDarkBot)
downDarkHeightV33 = math.max(syminfo.mintick, downDarkTop - downDarkBot)
upDarkHeightAvgV33 = ta.sma(upDarkHeightV33, math.max(3, cloudDarkFlatBarsV31))
downDarkHeightAvgV33 = ta.sma(downDarkHeightV33, math.max(3, cloudDarkFlatBarsV31))
upDarkThinV33 = useDarkMemoryV33 and not na(upDarkHeightAvgV33[1]) and upDarkHeightV33 <= upDarkHeightAvgV33[1] * darkThinRatioV33
downDarkThinV33 = useDarkMemoryV33 and not na(downDarkHeightAvgV33[1]) and downDarkHeightV33 <= downDarkHeightAvgV33[1] * darkThinRatioV33

var float upDarkLastThickTopV33 = na
var float upDarkLastThickBotV33 = na
var float downDarkLastThickTopV33 = na
var float downDarkLastThickBotV33 = na
var float upDarkMemoryTopV33 = na
var float upDarkMemoryBotV33 = na
var int upDarkMemoryStartV33 = na
var float downDarkMemoryTopV33 = na
var float downDarkMemoryBotV33 = na
var int downDarkMemoryStartV33 = na

if not upDarkThinV33 and not na(upDarkTop) and not na(upDarkBot)
    upDarkLastThickTopV33 := upDarkTop
    upDarkLastThickBotV33 := upDarkBot

if not downDarkThinV33 and not na(downDarkTop) and not na(downDarkBot)
    downDarkLastThickTopV33 := downDarkTop
    downDarkLastThickBotV33 := downDarkBot

if upDarkThinV33 and not upDarkThinV33[1] and not na(upDarkLastThickTopV33) and not na(upDarkLastThickBotV33)
    upDarkMemoryTopV33 := upDarkLastThickTopV33
    upDarkMemoryBotV33 := upDarkLastThickBotV33
    upDarkMemoryStartV33 := bar_index

if downDarkThinV33 and not downDarkThinV33[1] and not na(downDarkLastThickTopV33) and not na(downDarkLastThickBotV33)
    downDarkMemoryTopV33 := downDarkLastThickTopV33
    downDarkMemoryBotV33 := downDarkLastThickBotV33
    downDarkMemoryStartV33 := bar_index

upDarkMemoryActiveV33 = useDarkMemoryV33 and not na(upDarkMemoryStartV33) and bar_index - upDarkMemoryStartV33 <= darkMemoryBarsV33 and not na(upDarkMemoryTopV33) and not na(upDarkMemoryBotV33)
downDarkMemoryActiveV33 = useDarkMemoryV33 and not na(downDarkMemoryStartV33) and bar_index - downDarkMemoryStartV33 <= darkMemoryBarsV33 and not na(downDarkMemoryTopV33) and not na(downDarkMemoryBotV33)

//===================== SIDEWAY CLOUD =====================//
// Vùng SIDEWAY cũng bị điều khiển bởi menu: sidewayAtr, cloudBaseSmooth, cloudLightWidth, cloudDynMin/Max.
cloudSideBase = ta.rma(hl2 * (1.0 - math.min(0.70, cloudTrendBlendV22 * 0.45)) + cloudMaBase * math.min(0.70, cloudTrendBlendV22 * 0.45), baseSmoothLive)
sideHalfWidthRaw = cloudAtr * math.max(0.10, sidewayAtr * 3.5 + cloudLightWidth * 0.22 + (1.0 - math.min(1.0, cloudTrendStrength)) * 0.24) * math.max(cloudDynMin, math.min(cloudDynMax, expandLive * 0.65))
sideHalfWidth = ta.rma(sideHalfWidthRaw, darkSmoothLive)
sideTop = ta.rma(cloudSideBase + sideHalfWidth, darkSmoothLive)
sideBot = ta.rma(cloudSideBase - sideHalfWidth, darkSmoothLive)

//===================== TREND ENGINE =====================//
// TREND ENGINE V19 - VÙNG GIÁ ĐẢO XU HƯỚNG ĐỘNG.
// Chỉ sửa vùng giá đảo xu hướng, không thêm plot/line/đường kẻ phụ.
// Nguyên tắc:
// - Đủ tick đảo chiều từ đỉnh/đáy gần nhất => chuyển SIDEWAY ngay.
// - Sau đó 2-3 nến tiếp theo phải tiếp tục tạo giá mới.
// - Đồng thời giá phải đi thêm 25% số tick quy định => mới hình thành xu hướng mới.
// - Nếu không tiếp tục tạo giá mới hoặc hồi lại vùng vừa đi qua => trả về xu hướng cũ.

rsiBull = rsi > 52
rsiBear = rsi < 48
rsiNeutral = rsi >= 49 and rsi <= 51

// Nhận diện nhóm mã để quy đổi vùng đảo chiều theo tick.
trendTicker = syminfo.ticker
trendRoot = syminfo.root
trendIsFiveTickAgri = str.contains(trendTicker, "ZC") or str.contains(trendTicker, "ZW") or str.contains(trendTicker, "ZS") or str.contains(trendTicker, "KE") or str.contains(trendTicker, "MWE") or str.contains(trendRoot, "ZC") or str.contains(trendRoot, "ZW") or str.contains(trendRoot, "ZS") or str.contains(trendRoot, "KE") or str.contains(trendRoot, "MWE")
trendIsTenTickAgri = str.contains(trendTicker, "ZM") or str.contains(trendTicker, "ZO") or str.contains(trendTicker, "LE") or str.contains(trendTicker, "HE") or str.contains(trendTicker, "GF") or str.contains(trendRoot, "ZM") or str.contains(trendRoot, "ZO") or str.contains(trendRoot, "LE") or str.contains(trendRoot, "HE") or str.contains(trendRoot, "GF")
trendIsSoyOil = str.contains(trendTicker, "BO") or str.contains(trendTicker, "ZL") or str.contains(trendRoot, "BO") or str.contains(trendRoot, "ZL")

// Ngưỡng đảo chiều chính theo từng nhóm sản phẩm.
// Nhóm 5 tick = 1 giá: 20-40 tick => lấy mốc 40 tick.
// Nhóm 10 tick = 1 giá: 40-60 tick => lấy mốc 60 tick.
// Dầu đậu tương: 80-100 tick => lấy mốc 100 tick.
reversalBaseTicks = trendIsSoyOil ? 100.0 : trendIsTenTickAgri ? 60.0 : trendIsFiveTickAgri ? 40.0 : 50.0
reversalExtraTicks = reversalBaseTicks * 0.25
reversalBaseMove = reversalBaseTicks * syminfo.mintick
reversalExtraMove = reversalExtraTicks * syminfo.mintick
reversalTotalMove = reversalBaseMove + reversalExtraMove

// Đỉnh/đáy gần nhất dùng pivot động, tránh lấy vùng quá xa làm chậm đảo chiều.
pivotLen = 3
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
fallbackSwingHigh = ta.highest(high, 10)[1]
fallbackSwingLow = ta.lowest(low, 10)[1]

var float recentSwingHigh = na
var float recentSwingLow = na

if not na(ph)
    recentSwingHigh := ph

if not na(pl)
    recentSwingLow := pl

recentSwingHigh := nz(recentSwingHigh, fallbackSwingHigh)
recentSwingLow := nz(recentSwingLow, fallbackSwingLow)

// Mức giá cảnh báo đảo chiều và mức giá xác nhận xu hướng mới.
upReversalBasePrice = recentSwingLow + reversalBaseMove
upReversalConfirmPrice = recentSwingLow + reversalTotalMove
downReversalBasePrice = recentSwingHigh - reversalBaseMove
downReversalConfirmPrice = recentSwingHigh - reversalTotalMove

// Đạt vùng cảnh báo đảo chiều: chuyển SIDEWAY ngay, chưa đổi sang xu hướng mới.
upReachBase = not na(recentSwingLow) and high >= upReversalBasePrice
downReachBase = not na(recentSwingHigh) and low <= downReversalBasePrice

// Sức mạnh nền để tránh đảo chiều ngược lực quá yếu.
trendBullBase = close > basis and close > mainSlow and basis >= basis[1] and plusDI >= minusDI and rsi > 50
trendBearBase = close < basis and close < mainSlow and basis <= basis[1] and minusDI >= plusDI and rsi < 50

trendBullStrong =
     close > basis and
     close > pullLine and
     basis > mainSlow and
     emaSlope > 0 and
     plusDI > minusDI and
     adx >= math.max(6, adxMin * 0.70 * noiseTrendMult) and
     rsi > 50

trendBearStrong =
     close < basis and
     close < pullLine and
     basis < mainSlow and
     emaSlope < 0 and
     minusDI > plusDI and
     adx >= math.max(6, adxMin * 0.70 * noiseTrendMult) and
     rsi < 50

//===================== V27 DARK CLOUD SIDEWAY MEMORY =====================//
// Đưa trendState lên trước SIDEWAY để có thể xét trạng thái xu hướng trước đó khi nến chạm mây đậm.
var int trendState = 0

// Sideway khối lượng thấp: chỉ chuyển SIDEWAY khi thật sự yếu lực và đi ngang.
volAvgTrend = ta.sma(nz(volume), 20)
volumeLowTrend = not na(volume) and volAvgTrend > 0 and volume < volAvgTrend * 0.85
rangeAvgTrend = ta.sma(high - low, 20)
rangeLowTrend = rangeAvgTrend > 0 and (high - low) < rangeAvgTrend * 0.85
sidewayLowVolumeRaw =
     adx < adxSidewayMax * noiseSidewayMult * noiseSidewayMult and
     math.abs(plusDI - minusDI) < math.max(3, diSpreadMin * 0.60) and
     emaDistance <= atr * math.max(sidewayAtr, 0.12) and
     volumeLowTrend and
     rangeLowTrend and
     not trendBullStrong and
     not trendBearStrong

// V25 giảm SIDEWAY: trendSmoothBars/adxSidewayMax/diSpreadMin/sidewayAtr đều nối trực tiếp.
sidewaySmartWeak = math.abs(cloudSmartScore) < math.max(0.18, sidewayAtr * 3.4) and cloudTrendStrength < math.max(0.22, sidewayAtr * 3.8)
sidewayMaFlat = math.abs(cloudMaSlope) <= cloudAtr * math.max(0.012, sidewayAtr * 0.36) and math.abs(cloudMa10 - cloudMa20) <= cloudAtr * math.max(0.18, sidewayAtr * 3.4) and math.abs(cloudMa20 - cloudMa50) <= cloudAtr * math.max(0.28, sidewayAtr * 5.2)
sidewayMacdWeak = math.abs(cloudMacdHistSmooth) <= cloudAtr * math.max(0.012, sidewayAtr * 0.42)

//===================== V35 DARK MEMORY TOUCH/BREAK TREND =====================//
// Nguyên tắc V35:
// - Chạm vùng nhớ mây đậm: chuyển SIDEWAY.
// - Giá đóng cửa/vượt hẳn qua vùng nhớ + đủ xác nhận: đổi xu hướng.
// - BUY/SELL vẫn dùng mây nhạt; vùng nhớ mây đậm chỉ điều khiển trạng thái xu hướng.
[macdV35Line, macdV35Signal, macdV35Hist] = ta.macd(src, 12, 26, 9)
macdBullConfirmV35 = macdV35Line > macdV35Signal and macdV35Hist >= macdV35Hist[1]
macdBearConfirmV35 = macdV35Line < macdV35Signal and macdV35Hist <= macdV35Hist[1]
emaBullConfirmV35 = cloudMa10 > cloudMa20 and close > cloudMa20
emaBearConfirmV35 = cloudMa10 < cloudMa20 and close < cloudMa20
diBullConfirmV35 = plusDI >= minusDI
diBearConfirmV35 = minusDI >= plusDI
rsiBullConfirmV35 = rsi > 50
rsiBearConfirmV35 = rsi < 50

// V36: xác nhận lực mềm. Trước đây V35 yêu cầu EMA + MACD + DI + RSI cùng lúc,
// nên nhiều đoạn giá đã vượt vùng nhớ nhưng chưa đổi xu hướng. V36 chỉ cần giá vượt vùng nhớ
// và có tối thiểu 2/4 yếu tố xác nhận, hoặc tắt xác nhận thì đổi ngay theo vùng nhớ.
bullConfirmScoreV36 = (emaBullConfirmV35 ? 1 : 0) + (macdBullConfirmV35 ? 1 : 0) + (diBullConfirmV35 ? 1 : 0) + (rsiBullConfirmV35 ? 1 : 0)
bearConfirmScoreV36 = (emaBearConfirmV35 ? 1 : 0) + (macdBearConfirmV35 ? 1 : 0) + (diBearConfirmV35 ? 1 : 0) + (rsiBearConfirmV35 ? 1 : 0)
darkBreakBullConfirmV35 = not darkMemoryBreakConfirmV35 or (darkMemoryBreakSoftConfirmV36 ? bullConfirmScoreV36 >= 2 : (emaBullConfirmV35 and macdBullConfirmV35 and diBullConfirmV35 and rsiBullConfirmV35))
darkBreakBearConfirmV35 = not darkMemoryBreakConfirmV35 or (darkMemoryBreakSoftConfirmV36 ? bearConfirmScoreV36 >= 2 : (emaBearConfirmV35 and macdBearConfirmV35 and diBearConfirmV35 and rsiBearConfirmV35))
sidewayBarsOk = ta.barssince(not sidewayLowVolumeRaw) >= math.max(1, trendSmoothBars) - 1

// V36: bộ nhớ vùng mây đậm gần nhất theo xu hướng thật.
// Mục tiêu: khi đã SIDEWAY sau đường vàng, code vẫn nhớ được xu hướng trước đó là UP/DOWN
// để tới đường đỏ có thể đổi xu hướng theo vùng nhớ gần nhất.
var float upDarkNearestTopV36 = na
var float upDarkNearestBotV36 = na
var int upDarkNearestBarV36 = na
var float downDarkNearestTopV36 = na
var float downDarkNearestBotV36 = na
var int downDarkNearestBarV36 = na
var int lastDirectionalTrendV36 = 0

if trendState[1] == 1 and not na(upDarkTop[1]) and not na(upDarkBot[1])
    upDarkNearestTopV36 := upDarkTop[1]
    upDarkNearestBotV36 := upDarkBot[1]
    upDarkNearestBarV36 := bar_index - 1
    lastDirectionalTrendV36 := 1

if trendState[1] == -1 and not na(downDarkTop[1]) and not na(downDarkBot[1])
    downDarkNearestTopV36 := downDarkTop[1]
    downDarkNearestBotV36 := downDarkBot[1]
    downDarkNearestBarV36 := bar_index - 1
    lastDirectionalTrendV36 := -1

// Nếu đang SIDEWAY, vẫn giữ cả 2 vùng nhớ UP/DOWN trong N nến để xét chạm/vượt vùng nhớ.
// V37 sửa lỗi: không chỉ xét theo lastDirectionalTrendV36. Giá có thể vượt vùng nhớ theo CẢ 2 CHIỀU.
upNearestActiveV36 = useNearestDarkMemoryV36 and not na(upDarkNearestBarV36) and bar_index - upDarkNearestBarV36 <= darkMemoryKeepDuringSidewayV36 and not na(upDarkNearestTopV36) and not na(upDarkNearestBotV36)
downNearestActiveV36 = useNearestDarkMemoryV36 and not na(downDarkNearestBarV36) and bar_index - downDarkNearestBarV36 <= darkMemoryKeepDuringSidewayV36 and not na(downDarkNearestTopV36) and not na(downDarkNearestBotV36)

//===================== V29 SIDEWAY / ĐẢO CHIỀU THEO MÂY ĐẬM CỦA NẾN TRƯỚC =====================//
// Logic mới theo yêu cầu:
// - Lấy mây đậm của CÂY NẾN TRƯỚC làm mốc cố định để tránh repaint/nhảy mây trong cây hiện tại.
// - Nếu nến hiện tại chỉ CHẠM mây đậm trước => SIDEWAY.
// - Nếu nến hiện tại XUYÊN QUA HẲN mây đậm trước => đủ điều kiện đổi xu hướng.
//   Uptrend: xuyên xuống dưới upDarkBot[1] => xu hướng giảm.
//   Downtrend: xuyên lên trên downDarkTop[1] => xu hướng tăng.
swBodyTop = math.max(open, close)
swBodyBot = math.min(open, close)
priorTrendForDarkTouch = lastDirectionalTrendV36 != 0 ? lastDirectionalTrendV36 : nz(trendState[1], trendState)
// V37: trong SIDEWAY vẫn xét cả 2 chiều, không khóa theo xu hướng cũ duy nhất.
priorTrendForDarkTouchV37 = useBidirectionalDarkBreakV37 and trendState == 0 ? 0 : priorTrendForDarkTouch
darkBreakBufferV29 = (useDarkMemoryV35 ? darkMemoryBreakBufferTicksV35 : priorDarkBreakBufferTicksV29) * syminfo.mintick

// Mốc mây đậm dùng để xét:
// - Bình thường dùng mây đậm của nến trước theo V29.
// - Nếu V33 đang có vùng nhớ trước khi mây mỏng, dùng vùng nhớ đó để xét chạm/xuyên.
upDarkBaseTopRef = usePriorDarkCloudV29 ? upDarkTop[1] : upDarkTop
upDarkBaseBotRef = usePriorDarkCloudV29 ? upDarkBot[1] : upDarkBot
downDarkBaseTopRef = usePriorDarkCloudV29 ? downDarkTop[1] : downDarkTop
downDarkBaseBotRef = usePriorDarkCloudV29 ? downDarkBot[1] : downDarkBot
upDarkUseNearestRefV36 = upNearestActiveV36 and (priorTrendForDarkTouch == 1 or darkMemoryAnyZoneBreakV37)
downDarkUseNearestRefV36 = downNearestActiveV36 and (priorTrendForDarkTouch == -1 or darkMemoryAnyZoneBreakV37)
upDarkUseMemoryRefV33 = not upDarkUseNearestRefV36 and (useDarkMemoryV35 or darkMemoryUseForBreakV33) and upDarkMemoryActiveV33 and (priorTrendForDarkTouch == 1 or darkMemoryAnyZoneBreakV37)
downDarkUseMemoryRefV33 = not downDarkUseNearestRefV36 and (useDarkMemoryV35 or darkMemoryUseForBreakV33) and downDarkMemoryActiveV33 and (priorTrendForDarkTouch == -1 or darkMemoryAnyZoneBreakV37)
upDarkTopRef = upDarkUseNearestRefV36 ? upDarkNearestTopV36 : upDarkUseMemoryRefV33 ? upDarkMemoryTopV33 : upDarkBaseTopRef
upDarkBotRef = upDarkUseNearestRefV36 ? upDarkNearestBotV36 : upDarkUseMemoryRefV33 ? upDarkMemoryBotV33 : upDarkBaseBotRef
downDarkTopRef = downDarkUseNearestRefV36 ? downDarkNearestTopV36 : downDarkUseMemoryRefV33 ? downDarkMemoryTopV33 : downDarkBaseTopRef
downDarkBotRef = downDarkUseNearestRefV36 ? downDarkNearestBotV36 : downDarkUseMemoryRefV33 ? downDarkMemoryBotV33 : downDarkBaseBotRef

// Chạm mây đậm của xu hướng cũ.
upDarkWickTouch = not na(upDarkTopRef) and not na(upDarkBotRef) and low <= upDarkTopRef and high >= upDarkBotRef
downDarkWickTouch = not na(downDarkTopRef) and not na(downDarkBotRef) and high >= downDarkBotRef and low <= downDarkTopRef
upDarkBodyTouch = not na(upDarkTopRef) and not na(upDarkBotRef) and swBodyBot <= upDarkTopRef and swBodyTop >= upDarkBotRef
downDarkBodyTouch = not na(downDarkTopRef) and not na(downDarkBotRef) and swBodyTop >= downDarkBotRef and swBodyBot <= downDarkTopRef
upDarkCloseInside = not na(upDarkTopRef) and not na(upDarkBotRef) and close <= upDarkTopRef and close >= upDarkBotRef
downDarkCloseInside = not na(downDarkTopRef) and not na(downDarkBotRef) and close >= downDarkBotRef and close <= downDarkTopRef

// Xuyên hẳn qua mây đậm của nến trước.
// Nếu priorDarkBreakCloseV29 = true: yêu cầu đóng cửa xuyên hẳn để tránh false break bằng râu nến.
// Nếu false: chỉ cần râu nến xuyên qua, nhưng vẫn yêu cầu thân/đóng cửa đi cùng hướng một phần.
// V37: giá vượt vùng nhớ cả 2 chiều.
// - Phá xuống đáy vùng nhớ UP => DOWN.
// - Phá lên đỉnh vùng nhớ DOWN => UP.
// Không phụ thuộc việc trước đó đang UP hay DOWN nếu đang SIDEWAY và còn vùng nhớ hợp lệ.
allowDownBreakFromUpMemoryV37 = useBidirectionalDarkBreakV37 ? (not na(upDarkBotRef) and (priorTrendForDarkTouch == 1 or trendState == 0 or darkMemoryAnyZoneBreakV37)) : (priorTrendForDarkTouch == 1 and not na(upDarkBotRef))
allowUpBreakFromDownMemoryV37 = useBidirectionalDarkBreakV37 ? (not na(downDarkTopRef) and (priorTrendForDarkTouch == -1 or trendState == 0 or darkMemoryAnyZoneBreakV37)) : (priorTrendForDarkTouch == -1 and not na(downDarkTopRef))
upDarkBreakPriceV33 = (darkMemoryBreakForceTrendV36 or darkMemoryBreakReverseV35 or priorDarkBreakReverseV29) and allowDownBreakFromUpMemoryV37 and ((darkMemoryBreakCloseV35 or priorDarkBreakCloseV29) ? close < upDarkBotRef - darkBreakBufferV29 : (low < upDarkBotRef - darkBreakBufferV29 and close < upDarkTopRef))
downDarkBreakPriceV33 = (darkMemoryBreakForceTrendV36 or darkMemoryBreakReverseV35 or priorDarkBreakReverseV29) and allowUpBreakFromDownMemoryV37 and ((darkMemoryBreakCloseV35 or priorDarkBreakCloseV29) ? close > downDarkTopRef + darkBreakBufferV29 : (high > downDarkTopRef + darkBreakBufferV29 and close > downDarkBotRef))

// V38 sửa triệt để lỗi trong vùng khoanh tròn:
// - Khi giá đã SIDEWAY sau khi chạm vùng nhớ, vẫn xét phá vùng nhớ gần nhất cả 2 chiều.
// - Nếu bật V38, giá vượt đáy vùng nhớ UP => DOWN; giá vượt đỉnh vùng nhớ DOWN => UP.
// - Không còn bị khóa bởi EMA/MACD/RSI/DI quá chặt. Các xác nhận chỉ nên dùng cho entry, không dùng để cản đổi màu trend khi đã phá vùng nhớ.
if useDirectMemoryBreakV38
    upBreakByCloseV38 = allowDownBreakFromUpMemoryV37 and not na(upDarkBotRef) and close < upDarkBotRef - darkBreakBufferV29
    upBreakByWickV38 = allowDownBreakFromUpMemoryV37 and not na(upDarkBotRef) and low < upDarkBotRef - darkBreakBufferV29 and close < upDarkTopRef
    downBreakByCloseV38 = allowUpBreakFromDownMemoryV37 and not na(downDarkTopRef) and close > downDarkTopRef + darkBreakBufferV29
    downBreakByWickV38 = allowUpBreakFromDownMemoryV37 and not na(downDarkTopRef) and high > downDarkTopRef + darkBreakBufferV29 and close > downDarkBotRef
    upDarkBreakPriceV33 := darkMemoryBreakNeedCloseV38 ? upBreakByCloseV38 : (upBreakByCloseV38 or (darkMemoryBreakUseWickV38 and upBreakByWickV38))
    downDarkBreakPriceV33 := darkMemoryBreakNeedCloseV38 ? downBreakByCloseV38 : (downBreakByCloseV38 or (darkMemoryBreakUseWickV38 and downBreakByWickV38))

upDarkBreakPowerOkV33 = useDirectMemoryBreakV38 ? true : darkBreakBearConfirmV35 and (darkMemoryBreakForceTrendV36 or not darkMemoryRequireTrendConfirmV33 or (trendBearBase and minusDI >= plusDI and close < basis and rsi < 50))
downDarkBreakPowerOkV33 = useDirectMemoryBreakV38 ? true : darkBreakBullConfirmV35 and (darkMemoryBreakForceTrendV36 or not darkMemoryRequireTrendConfirmV33 or (trendBullBase and plusDI >= minusDI and close > basis and rsi > 50))
upDarkBreakThroughV29 = upDarkBreakPriceV33 and upDarkBreakPowerOkV33
downDarkBreakThroughV29 = downDarkBreakPriceV33 and downDarkBreakPowerOkV33

// Chỉ chạm thì SIDEWAY; đã xuyên hẳn thì KHÔNG sideway nữa mà chuyển cho nhánh đổi xu hướng xử lý.
upDarkTouchRaw = (priorTrendForDarkTouch == 1 or (useBidirectionalDarkBreakV37 and trendState == 0 and not na(upDarkTopRef))) and not upDarkBreakThroughV29 and (darkCloudCloseInsideV27 ? upDarkCloseInside : (upDarkWickTouch or upDarkBodyTouch))
downDarkTouchRaw = (priorTrendForDarkTouch == -1 or (useBidirectionalDarkBreakV37 and trendState == 0 and not na(downDarkTopRef))) and not downDarkBreakThroughV29 and (darkCloudCloseInsideV27 ? downDarkCloseInside : (downDarkWickTouch or downDarkBodyTouch))
darkCloudTouchRaw = (useDarkCloudSidewayV27 or darkMemoryTouchForceSidewayV36) and (upDarkTouchRaw or downDarkTouchRaw)
darkTouchBarsOk = ta.barssince(not darkCloudTouchRaw) >= darkCloudSidewayBarsV27 - 1
darkCloudTouchConfirm = darkCloudTouchRaw and darkTouchBarsOk
darkCloudTouchMemory = ta.barssince(darkCloudTouchConfirm) <= (useDarkMemoryV35 ? darkMemoryTouchHoldV35 : darkCloudHoldBarsV27)

sidewayWeakRaw = sidewayLowVolumeRaw and sidewayBarsOk and sidewaySmartWeak and sidewayMaFlat and sidewayMacdWeak and adx < adxSidewayMax * noiseSidewayMult
sidewayRaw = (strictDarkOnlySidewayV28 and (useDarkCloudSidewayV27 or darkMemoryTouchForceSidewayV36)) ? darkCloudTouchMemory : (sidewayWeakRaw or darkCloudTouchMemory)

//===================== V41 STRICT DARK ZONE MEMORY =====================//
// Logic chị chốt:
// - Đang XU HƯỚNG TĂNG: nếu nến chạm vùng mây XANH ĐẬM gần nhất => SIDEWAY.
//   Nếu giá đóng cửa vượt xuống dưới vùng mây XANH ĐẬM gần nhất => đảo sang XU HƯỚNG GIẢM.
// - Đang XU HƯỚNG GIẢM: nếu nến chạm vùng mây ĐỎ ĐẬM gần nhất => SIDEWAY.
//   Nếu giá đóng cửa vượt lên trên vùng mây ĐỎ ĐẬM gần nhất => đảo sang XU HƯỚNG TĂNG.
// - Vùng xét là vùng mây đậm DÀY đã được bình quân/đóng băng 10-15 nến, không lấy mây mỏng dạng sợi.

var float fixedDarkMemTopV39 = na
var float fixedDarkMemBotV39 = na
var int fixedDarkMemDirV39 = 0     // 1 = vùng nhớ xanh đậm của uptrend; -1 = vùng nhớ đỏ đậm của downtrend
var int fixedDarkMemStartV39 = na

// Vùng đậm gần nhất theo 2 chiều, luôn giữ lại vùng dày đã đóng băng gần nhất.
v41UpZoneTopNow = nz(v41UpDarkTopFreeze, upDarkTop)
v41UpZoneBotNow = nz(v41UpDarkBotFreeze, upDarkBot)
v41DownZoneTopNow = nz(v41DownDarkTopFreeze, downDarkTop)
v41DownZoneBotNow = nz(v41DownDarkBotFreeze, downDarkBot)

var float v41NearestUpTop = na
var float v41NearestUpBot = na
var int v41NearestUpBar = na
var float v41NearestDownTop = na
var float v41NearestDownBot = na
var int v41NearestDownBar = na

// Cập nhật vùng gần nhất theo xu hướng đang chạy hoặc xu hướng vừa chạy trước SIDEWAY.
v41PrevTrend = nz(trendState[1], trendState)

if v41PrevTrend == 1 and not na(v41UpZoneTopNow) and not na(v41UpZoneBotNow)
    v41NearestUpTop := v41UpZoneTopNow
    v41NearestUpBot := v41UpZoneBotNow
    v41NearestUpBar := bar_index

if v41PrevTrend == -1 and not na(v41DownZoneTopNow) and not na(v41DownZoneBotNow)
    v41NearestDownTop := v41DownZoneTopNow
    v41NearestDownBot := v41DownZoneBotNow
    v41NearestDownBar := bar_index

// Khi đang SIDEWAY, vẫn dùng vùng gần nhất đã lưu của xu hướng trước đó.
v41HasUpMemory = not na(v41NearestUpTop) and not na(v41NearestUpBot)
v41HasDownMemory = not na(v41NearestDownTop) and not na(v41NearestDownBot)

darkBreakBufferV41 = darkMemoryBreakBufferTicksV35 * syminfo.mintick

v41ContextDir = trendState != 0 ? trendState : (fixedDarkMemDirV39 != 0 ? fixedDarkMemDirV39 : v41PrevTrend)

v41TouchUpMemory = v41ContextDir == 1 and v41HasUpMemory and low <= v41NearestUpTop and high >= v41NearestUpBot
v41TouchDownMemory = v41ContextDir == -1 and v41HasDownMemory and high >= v41NearestDownBot and low <= v41NearestDownTop

// Vượt vùng nhớ: dùng CLOSE để tránh râu nến quét giả.
// UP memory bị đóng cửa phá xuống đáy xanh đậm => đảo GIẢM.
// DOWN memory bị đóng cửa phá lên đỉnh đỏ đậm => đảo TĂNG.
v41BreakToDown = v41ContextDir == 1 and v41HasUpMemory and close < v41NearestUpBot - darkBreakBufferV41
v41BreakToUp = v41ContextDir == -1 and v41HasDownMemory and close > v41NearestDownTop + darkBreakBufferV41

// Giữ tên biến V39 để toàn bộ phần Trend Engine phía dưới không bị vỡ cấu trúc.
v39MemActive = v41HasUpMemory or v41HasDownMemory
v39TouchFixedMemory = (v41TouchUpMemory and not v41BreakToDown) or (v41TouchDownMemory and not v41BreakToUp)
v39BreakToDown = v41BreakToDown
v39BreakToUp = v41BreakToUp
v39OnlyTouchSideway = v39TouchFixedMemory and not v39BreakToDown and not v39BreakToUp

// Ghi lại vùng đang được dùng để nếu cần hiển thị/debug sau này.
if v41BreakToDown or v41TouchUpMemory
    fixedDarkMemTopV39 := v41NearestUpTop
    fixedDarkMemBotV39 := v41NearestUpBot
    fixedDarkMemDirV39 := 1
    fixedDarkMemStartV39 := bar_index
else if v41BreakToUp or v41TouchDownMemory
    fixedDarkMemTopV39 := v41NearestDownTop
    fixedDarkMemBotV39 := v41NearestDownBot
    fixedDarkMemDirV39 := -1
    fixedDarkMemStartV39 := bar_index

// Chỉ chạm vùng nhớ gần nhất => SIDEWAY. Nếu đã vượt thì để nhánh đổi xu hướng xử lý trước.
sidewayRaw := v39OnlyTouchSideway ? true : sidewayRaw

var int pendingTrendDir = 0
var int pendingTrendBar = na
var int pendingNewPriceCount = 0
var int priorTrendBeforePending = 0
var float pendingStartClose = na
var float pendingBreakHigh = na
var float pendingBreakLow = na
var float pendingTargetPrice = na

// Tạo vùng đảo chiều mới.
// Đủ tick đảo chiều => SIDEWAY ngay để không còn giữ xu hướng cũ quá lâu.
startPendingUp = inSession and trendState != 1 and pendingTrendDir == 0 and upReachBase and trendBullBase and not sidewayRaw
startPendingDown = inSession and trendState != -1 and pendingTrendDir == 0 and downReachBase and trendBearBase and not sidewayRaw

if startPendingUp
    priorTrendBeforePending := nz(trendState[1], trendState)
    trendState := strictDarkOnlySidewayV28 and (useDarkCloudSidewayV27 or darkMemoryTouchForceSidewayV36) ? nz(trendState[1], trendState) : 0
    pendingTrendDir := 1
    pendingTrendBar := bar_index
    pendingNewPriceCount := 0
    pendingStartClose := close
    pendingBreakHigh := high
    pendingBreakLow := low
    pendingTargetPrice := upReversalConfirmPrice

else if startPendingDown
    priorTrendBeforePending := nz(trendState[1], trendState)
    trendState := strictDarkOnlySidewayV28 and (useDarkCloudSidewayV27 or darkMemoryTouchForceSidewayV36) ? nz(trendState[1], trendState) : 0
    pendingTrendDir := -1
    pendingTrendBar := bar_index
    pendingNewPriceCount := 0
    pendingStartClose := close
    pendingBreakHigh := high
    pendingBreakLow := low
    pendingTargetPrice := downReversalConfirmPrice

newUpConfirmed = false
newDownConfirmed = false
pendingExpired = false

// Sau khi vào vùng cảnh báo, 2-3 nến tiếp theo phải tạo giá mới và đi thêm 25% tick.
if pendingTrendDir == 1 and bar_index > pendingTrendBar
    barsAfterPending = bar_index - pendingTrendBar
    upCreatesNewPrice = high > pendingBreakHigh
    upHitsExtraTarget = high >= pendingTargetPrice and pendingNewPriceCount >= 1 and close > pendingStartClose and trendBullBase
    upFailsBack = close < pendingStartClose or close < basis

    if upCreatesNewPrice
        pendingNewPriceCount += 1
        pendingBreakHigh := high

    if upHitsExtraTarget and pendingNewPriceCount >= 2 and barsAfterPending <= 3
        newUpConfirmed := true
        pendingTrendDir := 0
    else if upFailsBack or barsAfterPending > 3
        pendingExpired := true
        pendingTrendDir := 0

if pendingTrendDir == -1 and bar_index > pendingTrendBar
    barsAfterPending = bar_index - pendingTrendBar
    downCreatesNewPrice = low < pendingBreakLow
    downHitsExtraTarget = low <= pendingTargetPrice and pendingNewPriceCount >= 1 and close < pendingStartClose and trendBearBase
    downFailsBack = close > pendingStartClose or close > basis

    if downCreatesNewPrice
        pendingNewPriceCount += 1
        pendingBreakLow := low

    if downHitsExtraTarget and pendingNewPriceCount >= 2 and barsAfterPending <= 3
        newDownConfirmed := true
        pendingTrendDir := 0
    else if downFailsBack or barsAfterPending > 3
        pendingExpired := true
        pendingTrendDir := 0

// Cập nhật xu hướng:
// - Đủ tick đảo chiều: SIDEWAY ngay.
// - 2-3 nến tạo giá mới + thêm 25% tick: đổi xu hướng mới.
// - Không đủ điều kiện: quay lại xu hướng cũ, trừ khi thị trường yếu lực thật sự thì giữ SIDEWAY.
if useTrendMemory
    if v39BreakToUp and not v39BreakToDown
        // V39: giá phá lên vùng nhớ DOWN đã khóa => đổi sang UP
        trendState := 1
        if darkMemoryResetOnNewTrendV39
            fixedDarkMemTopV39 := na
            fixedDarkMemBotV39 := na
            fixedDarkMemDirV39 := 0
            fixedDarkMemStartV39 := na
    else if v39BreakToDown and not v39BreakToUp
        // V39: giá phá xuống vùng nhớ UP đã khóa => đổi sang DOWN
        trendState := -1
        if darkMemoryResetOnNewTrendV39
            fixedDarkMemTopV39 := na
            fixedDarkMemBotV39 := na
            fixedDarkMemDirV39 := 0
            fixedDarkMemStartV39 := na
    else if downDarkBreakThroughV29 and not upDarkBreakThroughV29
        // Downtrend cũ bị giá vượt lên trên vùng nhớ => đổi sang UP
        trendState := 1
    else if upDarkBreakThroughV29 and not downDarkBreakThroughV29
        // Uptrend cũ bị giá phá xuống dưới vùng nhớ => đổi sang DOWN
        trendState := -1
    else if newUpConfirmed and not newDownConfirmed
        trendState := 1
    else if newDownConfirmed and not newUpConfirmed
        trendState := -1
    else if pendingExpired
        trendState := sidewayRaw ? 0 : priorTrendBeforePending
    else if pendingTrendDir != 0
        trendState := strictDarkOnlySidewayV28 and (useDarkCloudSidewayV27 or darkMemoryTouchForceSidewayV36) ? nz(trendState[1], trendState) : 0
    else if sidewayRaw
        trendState := 0
    else if trendState == 0
        if trendBullStrong and (upReachBase or cloudSmartScore > 0.55)
            trendState := 1
        else if trendBearStrong and (downReachBase or cloudSmartScore < -0.55)
            trendState := -1
        else if trendBullBase and cloudSmartScore > 0.85 and adx >= math.max(7, adxMin * 0.55)
            trendState := 1
        else if trendBearBase and cloudSmartScore < -0.85 and adx >= math.max(7, adxMin * 0.55)
            trendState := -1
        else
            trendState := nz(trendState[1], 0)
    else
        trendState := nz(trendState[1], 0)
else
    trendState := v39BreakToUp ? 1 : v39BreakToDown ? -1 : downDarkBreakThroughV29 ? 1 : upDarkBreakThroughV29 ? -1 : newUpConfirmed ? 1 : newDownConfirmed ? -1 : sidewayRaw ? 0 : nz(trendState[1], 0)

// V36: sau khi cập nhật trendState, ghi lại xu hướng thật mới để các nến sau không bị kẹt SIDEWAY cũ.
if trendState == 1
    lastDirectionalTrendV36 := 1
else if trendState == -1
    lastDirectionalTrendV36 := -1

// Sau khi giá vượt vùng nhớ và xác nhận xu hướng mới, khóa/xóa vùng nhớ cũ để tránh lặp SIDEWAY sai vùng.
if useDarkMemoryV35 and upDarkBreakThroughV29
    upDarkMemoryStartV33 := na
    upDarkMemoryTopV33 := na
    upDarkMemoryBotV33 := na

if useDarkMemoryV35 and downDarkBreakThroughV29
    downDarkMemoryStartV33 := na
    downDarkMemoryTopV33 := na
    downDarkMemoryBotV33 := na

trendUp = trendState == 1
trendDown = trendState == -1
sideway = trendState == 0
trendText = trendUp ? "XU HƯỚNG TĂNG" : trendDown ? "XU HƯỚNG GIẢM" : "SIDEWAY"

//===================== CLOUD PLOTS =====================//
pUpLT = plot(showKingCloud and trendUp ? upLightTop : na, "KING Up Light Top", display=display.none, force_overlay=true)
pUpLB = plot(showKingCloud and trendUp ? upLightBot : na, "KING Up Light Bot", display=display.none, force_overlay=true)
pUpDT = plot(showKingCloud and trendUp ? upDarkTop : na, "KING Up Dark Top", display=display.none, force_overlay=true)
pUpDB = plot(showKingCloud and trendUp ? upDarkBot : na, "KING Up Dark Bot", display=display.none, force_overlay=true)
pDnLT = plot(showKingCloud and trendDown ? downLightTop : na, "KING Down Light Top", display=display.none, force_overlay=true)
pDnLB = plot(showKingCloud and trendDown ? downLightBot : na, "KING Down Light Bot", display=display.none, force_overlay=true)
pDnDT = plot(showKingCloud and trendDown ? downDarkTop : na, "KING Down Dark Top", display=display.none, force_overlay=true)
pDnDB = plot(showKingCloud and trendDown ? downDarkBot : na, "KING Down Dark Bot", display=display.none, force_overlay=true)
pSideT = plot(showKingCloud and sideway ? sideTop : na, "KING Side Top", display=display.none, force_overlay=true)
pSideB = plot(showKingCloud and sideway ? sideBot : na, "KING Side Bot", display=display.none, force_overlay=true)
fill(pUpLT, pUpLB, color=colCloudUpLight)
fill(pUpDT, pUpDB, color=colCloudUpDark)
fill(pDnLT, pDnLB, color=colCloudDownLight)
fill(pDnDT, pDnDB, color=colCloudDownDark)
fill(pSideT, pSideB, color=colCloudSideway)

pUpMemT33 = plot(showKingCloud and darkMemoryShowZoneV33 and upDarkMemoryActiveV33 ? upDarkMemoryTopV33 : na, "V33 Up Dark Memory Top", display=display.none, force_overlay=true)
pUpMemB33 = plot(showKingCloud and darkMemoryShowZoneV33 and upDarkMemoryActiveV33 ? upDarkMemoryBotV33 : na, "V33 Up Dark Memory Bot", display=display.none, force_overlay=true)
pDnMemT33 = plot(showKingCloud and darkMemoryShowZoneV33 and downDarkMemoryActiveV33 ? downDarkMemoryTopV33 : na, "V33 Down Dark Memory Top", display=display.none, force_overlay=true)
pDnMemB33 = plot(showKingCloud and darkMemoryShowZoneV33 and downDarkMemoryActiveV33 ? downDarkMemoryBotV33 : na, "V33 Down Dark Memory Bot", display=display.none, force_overlay=true)
fill(pUpMemT33, pUpMemB33, color=color.new(colCloudUpDark, 20))
fill(pDnMemT33, pDnMemB33, color=color.new(colCloudDownDark, 20))

// V25: mây phụ Pullback–Mid được nối lại với menu MÂY PHỤ.
pMid = plot(showMidCloud ? mediumLine : na, "KING Medium Cloud", display=display.none, force_overlay=true)
pPull = plot(showMidCloud ? pullLine : na, "KING Pullback Cloud", display=display.none, force_overlay=true)
fill(pPull, pMid, color=showMidCloud ? (trendUp ? midCloudUpColor : trendDown ? midCloudDownColor : midCloudSideColor) : na)
plot(showPullbackLine ? pullLine : na, "Pullback Line", color=colPullLine, linewidth=2, force_overlay=true)
plot(showMediumTrend ? mediumLine : na, "Medium Trend", color=color.new(color.gray, 65), linewidth=1, force_overlay=true)
bgcolor(showBackground and forceSameChart and (bar_index % 96 < 48) ? color.new(color.blue, 94) : na)

//===================== BBNDS =====================//
bbBasis = ta.sma(close, bbndsLength)
bbDev = ta.stdev(close, bbndsLength)
bbUpper = ta.ema(bbBasis + bbDev * 2.0, bbndsSmoothing)
bbLower = ta.ema(bbBasis - bbDev * 2.0, bbndsSmoothing)
plot(showBbnds ? bbUpper : na, "BBNDS Upper", color=color.new(color.gray, 70), force_overlay=true)
plot(showBbnds ? bbLower : na, "BBNDS Lower", color=color.new(color.gray, 70), force_overlay=true)

//===================== RSI FILTERS =====================//
rsiTrendBuyOk = not useRsiTrend or rsi > buyRsiMin
rsiTrendSellOk = not useRsiTrend or rsi < sellRsiMax
rsiExtremeBuyOk = not useRsiExtreme or rsi < blockBuyRsi
rsiExtremeSellOk = not useRsiExtreme or rsi > blockSellRsi
rsiHighestValue = ta.highest(rsi, rsiHistoryLookback)
rsiLowestValue  = ta.lowest(rsi, rsiHistoryLookback)
rsiRangeLive = rsiHighestValue - rsiLowestValue
rsiRangeOk = rsiMaxRange <= 0 ? true : rsiRangeLive <= rsiMaxRange
rsiHistoryBuyOk = not useRsiHistory or rsiHighestValue < historyBuyBlock
rsiHistorySellOk = not useRsiHistory or rsiLowestValue > historySellBlock
buyFilter = rsiTrendBuyOk and rsiExtremeBuyOk and rsiHistoryBuyOk and rsiRangeOk
sellFilter = rsiTrendSellOk and rsiExtremeSellOk and rsiHistorySellOk and rsiRangeOk

//===================== MULTI TIMEFRAME =====================//
fTrend(tf) =>
    f = request.security(syminfo.tickerid, tf, ta.ema(close, kingPeriod))
    s = request.security(syminfo.tickerid, tf, ta.ema(close, mainFactorLive))
    p = request.security(syminfo.tickerid, tf, ta.ema(close, pullLineFactorLive))
    c = request.security(syminfo.tickerid, tf, close)
    r = request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLen))
    f > s and c > p and r > 50 ? 1 : f < s and c < p and r < 50 ? -1 : 0

trendM15 = fTrend("15")
trendH1  = fTrend("60")
trendH4  = fTrend("240")
trendD1  = fTrend("D")
trendW1  = fTrend("W")
trendName(v) => v == 1 ? "UPTREND" : v == -1 ? "DOWNTREND" : "SIDEWAY"
trendBg(v) => v == 1 ? color.green : v == -1 ? color.red : color.yellow
trendTc(v) => v == 0 ? color.black : color.white

var table mtfTb = table.new(position.top_right, 2, 6, border_width=1)
if showMtfTable and barstate.islast
    table.cell(mtfTb, 0, 0, "Khung", bgcolor=color.black, text_color=color.white)
    table.cell(mtfTb, 1, 0, "Xu hướng KING", bgcolor=color.black, text_color=color.white)
    table.cell(mtfTb, 0, 1, "M15")
    table.cell(mtfTb, 1, 1, trendName(trendM15), bgcolor=trendBg(trendM15), text_color=trendTc(trendM15))
    table.cell(mtfTb, 0, 2, "H1")
    table.cell(mtfTb, 1, 2, trendName(trendH1), bgcolor=trendBg(trendH1), text_color=trendTc(trendH1))
    table.cell(mtfTb, 0, 3, "H4")
    table.cell(mtfTb, 1, 3, trendName(trendH4), bgcolor=trendBg(trendH4), text_color=trendTc(trendH4))
    table.cell(mtfTb, 0, 4, "D1")
    table.cell(mtfTb, 1, 4, trendName(trendD1), bgcolor=trendBg(trendD1), text_color=trendTc(trendD1))
    table.cell(mtfTb, 0, 5, "W1")
    table.cell(mtfTb, 1, 5, trendName(trendW1), bgcolor=trendBg(trendW1), text_color=trendTc(trendW1))


//===================== SIGNAL ENGINE =====================//
// Bản bổ sung Entry theo điểm nến giao cắt/chạm mây như hình đánh dấu:
// - Giữ nguyên toàn bộ code khác, chỉ mở rộng điều kiện MUA/BÁN.
// - Trong xu hướng tăng: nến chạm/giao cắt mây nhạt hoặc hồi về mây rồi bật lên => cho MUA theo xu hướng.
// - Trong xu hướng giảm: nến chạm/giao cắt mây nhạt hoặc hồi lên mây rồi rơi xuống => cho BÁN theo xu hướng.
// - Các nến chạm mây liên tiếp sau lệnh đầu bị chặn, trừ khi có nến xác nhận thuận xu hướng rõ ràng.
weakCandle = candleRange > 0 ? candleBody / candleRange < minBodyRatio : false
weakOk = acceptWeakCandle or not weakCandle
tol = closeTolerance / 100.0

bodyTop = math.max(open, close)
bodyBot = math.min(open, close)

// Pullback gốc: giữ nguyên logic cũ.
pullbackBuyZone = trendUp and weakOk and (low <= basis or (allowPullbackMid and low <= mediumLine) or low <= upLightTop) and close >= upLightBot * (1 - tol)
pullbackSellZone = trendDown and weakOk and (high >= basis or (allowPullbackMid and high >= mediumLine) or high >= downLightBot) and close <= downLightTop * (1 + tol)

// Nhận diện nến CHẠM/GIAO CẮT mây nhạt.
// Dùng cả râu nến và thân nến để bắt đúng các điểm chị khoanh vàng/xanh.
buyBodyTouchLightCloud  = trendUp and bodyBot <= upLightTop and bodyTop >= upLightBot and close >= upDarkBot
sellBodyTouchLightCloud = trendDown and bodyTop >= downLightBot and bodyBot <= downLightTop and close <= downDarkTop

buyWickTouchLightCloud  = trendUp and low <= upLightTop and high >= upLightBot and close >= upDarkBot
sellWickTouchLightCloud = trendDown and high >= downLightBot and low <= downLightTop and close <= downDarkTop

// Giao cắt mép mây nhạt: tách ta.cross ra biến riêng để Pine tính đều trên mọi cây nến.
buyCrossLowUpLight = ta.cross(low, upLightTop)
buyCrossCloseUpLight = ta.cross(close, upLightTop)
sellCrossHighDownLight = ta.cross(high, downLightBot)
sellCrossCloseDownLight = ta.cross(close, downLightBot)
buyCrossLightCloud = trendUp and (buyCrossLowUpLight or buyCrossCloseUpLight or (low <= upLightTop and close > upLightTop)) and close >= upLightBot
sellCrossLightCloud = trendDown and (sellCrossHighDownLight or sellCrossCloseDownLight or (high >= downLightBot and close < downLightBot)) and close <= downLightTop

buyTouchCloudAny = buyBodyTouchLightCloud or buyWickTouchLightCloud or buyCrossLightCloud
sellTouchCloudAny = sellBodyTouchLightCloud or sellWickTouchLightCloud or sellCrossLightCloud

// Cụm chạm mây: chỉ cây đầu tiên trong cụm được vào lệnh ngay.
buyTouchFresh = buyTouchCloudAny and not buyTouchCloudAny[1]
sellTouchFresh = sellTouchCloudAny and not sellTouchCloudAny[1]
buyTouchConsecutive = buyTouchCloudAny and buyTouchCloudAny[1]
sellTouchConsecutive = sellTouchCloudAny and sellTouchCloudAny[1]

// Đo lực/khối lượng hiện tại.
volAvg20 = ta.sma(nz(volume), 20)
volumeStrongNow = not na(volume) and volAvg20 > 0 and volume > volAvg20 * 1.20

// Lực chống xu hướng: chặn lệnh ở cây đó.
buyOppositePressureStrong = volumeStrongNow and close < open and candlePower >= 0.42
sellOppositePressureStrong = volumeStrongNow and close > open and candlePower >= 0.42

// Nến thuận xu hướng rõ ràng.
buyTrendVolumeOk = close > open and candlePower >= 0.28 and close >= low + candleRange * 0.55 and (not volumeStrongNow or close > close[1] or volume >= volume[1])
sellTrendVolumeOk = close < open and candlePower >= 0.28 and close <= high - candleRange * 0.55 and (not volumeStrongNow or close < close[1] or volume >= volume[1])

// Nến bật theo xu hướng sau khi chạm/giao cắt mây.
buyReboundFromCloud = trendUp and buyTouchCloudAny and close > open and close > upLightTop and close > close[1] and not buyOppositePressureStrong
sellReboundFromCloud = trendDown and sellTouchCloudAny and close < open and close < downLightBot and close < close[1] and not sellOppositePressureStrong

// Nến hồi thuận xu hướng sau cây/cụm chạm mây trước đó: bắt các vòng tròn xanh.
buyFollowAfterTouch = trendUp and ta.barssince(buyTouchCloudAny) <= 3 and not buyTouchCloudAny and buyTrendVolumeOk and close > basis and not buyOppositePressureStrong
sellFollowAfterTouch = trendDown and ta.barssince(sellTouchCloudAny) <= 3 and not sellTouchCloudAny and sellTrendVolumeOk and close < basis and not sellOppositePressureStrong

// Lọc nến xác nhận: thân nến rõ, đóng cửa ở vùng mạnh của cây nến.
buyCandleConfirm = close > open and candlePower >= 0.35 and close >= low + candleRange * 0.60
sellCandleConfirm = close < open and candlePower >= 0.35 and close <= high - candleRange * 0.60

// Lọc sức mạnh xu hướng: giảm độ quá chặt để không bỏ sót nến chạm mây hợp lệ.
buyTrendPower = plusDI > minusDI and adx >= math.max(6, adxMin * 0.70 * noiseTrendMult)
sellTrendPower = minusDI > plusDI and adx >= math.max(6, adxMin * 0.70 * noiseTrendMult)

// Lọc RSI: cho phép rộng hơn để bắt các điểm hồi về mây rồi đi tiếp.
buyRsiQuality = rsi > buyRsiMin and rsi < blockBuyRsi
sellRsiQuality = rsi < sellRsiMax and rsi > blockSellRsi

// Lọc vị trí giá: không đuổi giá quá xa mây/pullback line để TP ngắn dễ đạt hơn.
buyLocationOk = close > basis and close - (allowPullbackMid ? math.min(stpPullLine, stpMidLine) : stpPullLine) <= atr * 2.8
sellLocationOk = close < basis and (allowPullbackMid ? math.max(stpPullLine, stpMidLine) : stpPullLine) - close <= atr * 2.8

// Lọc đa khung mềm: ưu tiên cùng H1/H4, nhưng vẫn cho lệnh nếu xu hướng hiện tại rõ và không có khối lượng chống xu hướng.
buyMtfOk = trendH1 == 1 or trendH4 == 1 or (trendUp and trendM15 != -1)
sellMtfOk = trendH1 == -1 or trendH4 == -1 or (trendDown and trendM15 != 1)

// Entry chạm/giao cắt mây: cây đầu cụm vào ngay; cây liên tiếp chỉ vào nếu chính cây đó bật thuận xu hướng rõ.
buyTouchEntry = trendUp and (buyTouchFresh or (buyTouchConsecutive and buyReboundFromCloud)) and buyFilter and buyTrendPower and buyRsiQuality and buyMtfOk and not buyOppositePressureStrong and inSession
sellTouchEntry = trendDown and (sellTouchFresh or (sellTouchConsecutive and sellReboundFromCloud)) and sellFilter and sellTrendPower and sellRsiQuality and sellMtfOk and not sellOppositePressureStrong and inSession

// Entry nến hồi thuận xu hướng sau điểm chạm mây.
buyFollowTrendEntry = buyFollowAfterTouch and buyFilter and buyTrendPower and buyRsiQuality and buyMtfOk and inSession
sellFollowTrendEntry = sellFollowAfterTouch and sellFilter and sellTrendPower and sellRsiQuality and sellMtfOk and inSession

previewTimeOk = barstate.isrealtime and (time_close - timenow <= previewMinutes * 60000)
buyPreview = enablePreviewLabel and previewTimeOk and ((pullbackBuyZone and buyFilter and buyTrendPower and buyRsiQuality and buyLocationOk and buyMtfOk and not buyTouchConsecutive and not buyOppositePressureStrong) or buyTouchEntry or buyFollowTrendEntry) and not barstate.isconfirmed
sellPreview = enablePreviewLabel and previewTimeOk and ((pullbackSellZone and sellFilter and sellTrendPower and sellRsiQuality and sellLocationOk and sellMtfOk and not sellTouchConsecutive and not sellOppositePressureStrong) or sellTouchEntry or sellFollowTrendEntry) and not barstate.isconfirmed

buySignalRawNormal = trendUp and pullbackBuyZone and buyCandleConfirm and buyFilter and buyTrendPower and buyRsiQuality and buyLocationOk and buyMtfOk and not buyTouchConsecutive and not buyOppositePressureStrong and inSession
sellSignalRawNormal = trendDown and pullbackSellZone and sellCandleConfirm and sellFilter and sellTrendPower and sellRsiQuality and sellLocationOk and sellMtfOk and not sellTouchConsecutive and not sellOppositePressureStrong and inSession

buySignalRaw = buySignalRawNormal or buyTouchEntry or buyFollowTrendEntry
sellSignalRaw = sellSignalRawNormal or sellTouchEntry or sellFollowTrendEntry

var int lastSignalBar = na
var int trendOrderCount = 0
trendChanged = trendState != trendState[1]
if trendChanged
    trendOrderCount := 0
canSignalByBars = na(lastSignalBar) or bar_index - lastSignalBar > oneOrderInNBars
canSignalByTrend = trendOrderCount < maxOrdersInTrend

// Entry chạm/giao cắt mây và entry hồi thuận xu hướng được ưu tiên vào ngay, không bị chặn bởi oneOrderInNBars.
buyImmediateEntry = buyTouchEntry or buyFollowTrendEntry
sellImmediateEntry = sellTouchEntry or sellFollowTrendEntry
buySignal = showSignal and ((buySignalRawNormal and canSignalByBars) or buyImmediateEntry) and canSignalByTrend and barstate.isconfirmed
sellSignal = showSignal and ((sellSignalRawNormal and canSignalByBars) or sellImmediateEntry) and canSignalByTrend and barstate.isconfirmed
if buySignal or sellSignal
    lastSignalBar := bar_index
    trendOrderCount += 1

//===================== ENTRY / STP / TP =====================//
// STP cố định 5 giá cho nhóm nông sản có giá trị 1 giá = 50$ như Ngô/Lúa mì/Đậu tương.
// Tự nhận diện các mã phổ biến: ZC, ZW, ZS, KE, MWE.
isAgriSymbol = str.contains(syminfo.ticker, "ZC") or str.contains(syminfo.ticker, "ZW") or str.contains(syminfo.ticker, "ZS") or str.contains(syminfo.ticker, "KE") or str.contains(syminfo.ticker, "MWE") or str.contains(syminfo.root, "ZC") or str.contains(syminfo.root, "ZW") or str.contains(syminfo.root, "ZS") or str.contains(syminfo.root, "KE") or str.contains(syminfo.root, "MWE")
agriStpActive = useAgriFixedStp and isAgriSymbol

// Chế độ tick dùng syminfo.mintick của TradingView, nên mỗi sản phẩm tự nhận đúng bước giá tối thiểu.
// Ví dụ: nếu sản phẩm có 5 tick = 1 giá, nhập SL 25 tick nghĩa là SL = 5 giá.
// Nếu sản phẩm có 10 tick = 1 giá, nhập SL 50 tick nghĩa là SL = 5 giá.
tvTick = syminfo.mintick

rawBuyEntry = math.min(open, close)
buyEntry = useTickLevelMode ? math.round_to_mintick(rawBuyEntry + entryOffsetTicks * tvTick) : rawBuyEntry
buyStpBase = allowPullbackMid ? math.min(stpPullLine, stpMidLine) : stpPullLine
buyStpRaw = agriStpActive ? buyEntry - agriFixedStp : useFixedStp ? buyEntry - fixedStp : math.min(math.min(buyStpBase, upDarkBot), low - atr * stpAtrMult) * (1 - (stpPlusPullLine + stpPlusMid) / 100)
buyStp = useTickLevelMode ? math.round_to_mintick(buyEntry - slTicks * tvTick) : math.round_to_mintick(buyStpRaw)
buyRisk = math.max(tvTick, buyEntry - buyStp)
buyTp1 = useTickLevelMode ? math.round_to_mintick(buyEntry + tp1Ticks * tvTick) : math.round_to_mintick(buyEntry + buyRisk * tp1RR)
buyTp2 = useTickLevelMode ? math.round_to_mintick(buyEntry + tp2Ticks * tvTick) : math.round_to_mintick(buyEntry + buyRisk * tp2RR)
buyTp3 = useTickLevelMode ? math.round_to_mintick(buyEntry + tp3Ticks * tvTick) : math.round_to_mintick(buyEntry + buyRisk * tp3RR)

rawSellEntry = math.max(open, close)
sellEntry = useTickLevelMode ? math.round_to_mintick(rawSellEntry - entryOffsetTicks * tvTick) : rawSellEntry
sellStpBase = allowPullbackMid ? math.max(stpPullLine, stpMidLine) : stpPullLine
sellStpRaw = agriStpActive ? sellEntry + agriFixedStp : useFixedStp ? sellEntry + fixedStp : math.max(math.max(sellStpBase, downDarkTop), high + atr * stpAtrMult) * (1 + (stpPlusPullLine + stpPlusMid) / 100)
sellStp = useTickLevelMode ? math.round_to_mintick(sellEntry + slTicks * tvTick) : math.round_to_mintick(sellStpRaw)
sellRisk = math.max(tvTick, sellStp - sellEntry)
sellTp1 = useTickLevelMode ? math.round_to_mintick(sellEntry - tp1Ticks * tvTick) : math.round_to_mintick(sellEntry - sellRisk * tp1RR)
sellTp2 = useTickLevelMode ? math.round_to_mintick(sellEntry - tp2Ticks * tvTick) : math.round_to_mintick(sellEntry - sellRisk * tp2RR)
sellTp3 = useTickLevelMode ? math.round_to_mintick(sellEntry - tp3Ticks * tvTick) : math.round_to_mintick(sellEntry - sellRisk * tp3RR)

//===================== HIỂN THỊ ENTRY / STP / TP GỐC - KHÔNG THÊM ĐƯỜNG KẺ PHỤ =====================//
activeBuy = buySignal or buyPreview
activeSell = sellSignal or sellPreview
entryPlot = showPlotLevels ? (activeBuy ? buyEntry : activeSell ? sellEntry : na) : na
stpPlot = showPlotLevels ? (activeBuy ? buyStp : activeSell ? sellStp : na) : na
tp1Plot = showPlotLevels ? (activeBuy ? buyTp1 : activeSell ? sellTp1 : na) : na
tp2Plot = showPlotLevels ? (activeBuy ? buyTp2 : activeSell ? sellTp2 : na) : na
tp3Plot = showPlotLevels ? (activeBuy ? buyTp3 : activeSell ? sellTp3 : na) : na
plot(entryPlot, "KING Entry", color=color.white, linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(stpPlot, "KING STP", color=color.red, linewidth=2, style=plot.style_linebr, force_overlay=true)
plot(tp1Plot, "KING TP1", color=color.green, linewidth=1, style=plot.style_linebr, force_overlay=true)
plot(tp2Plot, "KING TP2", color=color.green, linewidth=1, style=plot.style_linebr, force_overlay=true)
plot(tp3Plot, "KING TP3", color=color.green, linewidth=1, style=plot.style_linebr, force_overlay=true)

plotshape(buySignal, title="KING BUY",
     text="",style=shape.labelup, location=location.belowbar, color=confirmBuyColor, textcolor=color.white, size=size.small, force_overlay=true)
plotshape(sellSignal, title="KING SELL",
     text="",style=shape.labeldown, location=location.abovebar, color=confirmSellColor, textcolor=color.white, size=size.small, force_overlay=true)
plotshape(buyPreview, title="KING BUY PREVIEW", text="", style=shape.labelup, location=location.belowbar, color=previewBuyColor, textcolor=color.white, size=size.tiny, force_overlay=true)
plotshape(sellPreview, title="KING SELL PREVIEW", text="", style=shape.labeldown, location=location.abovebar, color=previewSellColor, textcolor=color.white, size=size.tiny, force_overlay=true)

if showFullSignalLabel and (buySignal or sellSignal)
    txt = buySignal ? f_text("MUA", buyEntry, buyStp, buyTp1, buyTp2, buyTp3, false) : f_text("BÁN", sellEntry, sellStp, sellTp1, sellTp2, sellTp3, false)
    y = buySignal ? low - atr : high + atr
    label.new(time, y, txt, xloc=xloc.bar_time, style=buySignal ? label.style_label_up : label.style_label_down, color=buySignal ? confirmBuyColor : confirmSellColor, textcolor=color.white, size=f_size(labelSizeOpt), force_overlay=true)

if showFullSignalLabel and (buyPreview or sellPreview) and barstate.islast
    txtp = buyPreview ? f_text("MUA", buyEntry, buyStp, buyTp1, buyTp2, buyTp3, true) : f_text("BÁN", sellEntry, sellStp, sellTp1, sellTp2, sellTp3, true)
    yp = buyPreview ? low - atr : high + atr
    label.new(time, yp, txtp, xloc=xloc.bar_time, style=buyPreview ? label.style_label_up : label.style_label_down, color=buyPreview ? previewBuyColor : previewSellColor, textcolor=color.white, size=f_size(labelSizeOpt), force_overlay=true)

//===================== TREND START TAGS =====================//
trendStartUp = trendState == 1 and trendState[1] != 1
trendStartDown = trendState == -1 and trendState[1] != -1
sidewayStart = sideway and not sideway[1]

if showTrendStartTag and trendStartUp
    label.new(time, upLightTop, "Xu hướng tăng", xloc=xloc.bar_time, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=f_size(labelSizeOpt), force_overlay=true)

if showTrendStartTag and trendStartDown
    label.new(time, downLightBot, "Xu hướng giảm", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.red, 0), textcolor=color.white, size=f_size(labelSizeOpt), force_overlay=true)

if showSidewayTag and sidewayStart
    label.new(time, sideTop, "SIDEWAY", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.yellow, 0), textcolor=color.black, size=f_size(labelSizeOpt), force_overlay=true)

//===================== TREND LABEL =====================//
var label trendLabel = na
if showMainTrend and showTrendLabel and barstate.islast
    label.delete(trendLabel)
    trendLabel := label.new(time, trendUp ? low - atr * 1.8 : trendDown ? high + atr * 1.8 : close, trendText, xloc=xloc.bar_time, style=trendUp ? label.style_label_up : trendDown ? label.style_label_down : label.style_label_left, color=trendUp ? color.green : trendDown ? color.red : color.orange, textcolor=color.white, size=f_size(labelSizeOpt), force_overlay=true)

//===================== WIN/LOSE STATS =====================//
// THỐNG KÊ 500 LỆNH GẦN NHẤT THEO TIMELINE GIÁ:
// - Chỉ lưu và thống kê tối đa 500 lệnh gần nhất.
// - Khi có lệnh mới vượt quá 500, lệnh cũ nhất sẽ bị loại khỏi thống kê.
// - Nếu lệnh cũ đã WIN/LOSE thì tự trừ khỏi bộ đếm để số liệu luôn đúng trong 500 lệnh gần nhất.
// - WIN được tính khi giá chạm TP1 trước STP.
// - LOSE được tính khi giá chạm STP trước TP1.
// - Chỉ hiển thị: Tổng, Đã đóng, Đang mở, Lệnh thắng, Lệnh thua, Thắng - Thua.

maxStatsTrades = input.int(500, "Số lệnh gần nhất để thống kê", group=gStats, minval=1, maxval=500)

var array<int> statDirArr = array.new_int()
var array<int> statBarArr = array.new_int()
var array<float> statStpArr = array.new_float()
var array<float> statTp1Arr = array.new_float()
var array<int> statStatusArr = array.new_int()   // 0 = OPEN, 1 = WIN TP1, -1 = LOSE STP

var int winTrades = 0
var int lostTrades = 0

// Hàm loại lệnh cũ nhất khi vượt quá giới hạn 500 lệnh gần nhất.
f_trim_old_stat_trade() =>
    if array.size(statDirArr) > maxStatsTrades
        _oldStatus = array.shift(statStatusArr)
        array.shift(statDirArr)
        array.shift(statBarArr)
        array.shift(statStpArr)
        array.shift(statTp1Arr)
        _oldStatus
    else
        0

// Ghi nhận từng lệnh theo đúng timeline tín hiệu.
if buySignal
    array.push(statDirArr, 1)
    array.push(statBarArr, bar_index)
    array.push(statStpArr, buyStp)
    array.push(statTp1Arr, buyTp1)
    array.push(statStatusArr, 0)
    removedBuyStatus = f_trim_old_stat_trade()
    if removedBuyStatus == 1
        winTrades := math.max(0, winTrades - 1)
    else if removedBuyStatus == -1
        lostTrades := math.max(0, lostTrades - 1)

if sellSignal
    array.push(statDirArr, -1)
    array.push(statBarArr, bar_index)
    array.push(statStpArr, sellStp)
    array.push(statTp1Arr, sellTp1)
    array.push(statStatusArr, 0)
    removedSellStatus = f_trim_old_stat_trade()
    if removedSellStatus == 1
        winTrades := math.max(0, winTrades - 1)
    else if removedSellStatus == -1
        lostTrades := math.max(0, lostTrades - 1)

// Cập nhật kết quả cho tất cả lệnh còn đang mở trong 500 lệnh gần nhất.
// Đánh giá từ cây nến sau cây phát tín hiệu để tránh lấy high/low trước thời điểm có lệnh.
if array.size(statDirArr) > 0
    for i = 0 to array.size(statDirArr) - 1
        if array.get(statStatusArr, i) == 0 and bar_index > array.get(statBarArr, i)
            _dir = array.get(statDirArr, i)
            _stp = array.get(statStpArr, i)
            _tp1 = array.get(statTp1Arr, i)

            if _dir == 1
                _hitTp1 = high >= _tp1
                _hitStp = low <= _stp

                // Nếu cùng 1 nến vừa chạm TP1 vừa chạm STP thì dùng vị trí OPEN để ước lượng mốc nào gần bị chạm trước.
                if _hitTp1 and _hitStp
                    _tpFirst = math.abs(open - _tp1) <= math.abs(open - _stp)
                    if _tpFirst
                        winTrades += 1
                        array.set(statStatusArr, i, 1)
                    else
                        lostTrades += 1
                        array.set(statStatusArr, i, -1)
                else if _hitTp1
                    winTrades += 1
                    array.set(statStatusArr, i, 1)
                else if _hitStp
                    lostTrades += 1
                    array.set(statStatusArr, i, -1)

            if _dir == -1
                _hitTp1 = low <= _tp1
                _hitStp = high >= _stp

                // Nếu cùng 1 nến vừa chạm TP1 vừa chạm STP thì dùng vị trí OPEN để ước lượng mốc nào gần bị chạm trước.
                if _hitTp1 and _hitStp
                    _tpFirst = math.abs(open - _tp1) <= math.abs(open - _stp)
                    if _tpFirst
                        winTrades += 1
                        array.set(statStatusArr, i, 1)
                    else
                        lostTrades += 1
                        array.set(statStatusArr, i, -1)
                else if _hitTp1
                    winTrades += 1
                    array.set(statStatusArr, i, 1)
                else if _hitStp
                    lostTrades += 1
                    array.set(statStatusArr, i, -1)

totalTrades = array.size(statDirArr)
closedTrades = winTrades + lostTrades
openTrades = totalTrades - closedTrades
winMinusLose = winTrades - lostTrades

var table statTb = table.new(f_pos(statCorner), 2, 6, border_width=1)
if enableWinLoseStats and barstate.islast
    bgDiff = boldByNetProfit ? (winMinusLose >= 0 ? color.new(color.green, 80) : color.new(color.red, 80)) : na
    table.cell(statTb, 0, 0, "TỔNG LỆNH", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(statTb, 1, 0, str.tostring(totalTrades), bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(statTb, 0, 1, "ĐÃ ĐÓNG")
    table.cell(statTb, 1, 1, str.tostring(closedTrades))
    table.cell(statTb, 0, 2, "ĐANG MỞ")
    table.cell(statTb, 1, 2, str.tostring(openTrades))
    table.cell(statTb, 0, 3, "LỆNH THẮNG", text_color=color.green)
    table.cell(statTb, 1, 3, str.tostring(winTrades), text_color=color.green)
    table.cell(statTb, 0, 4, "LỆNH THUA", text_color=color.red)
    table.cell(statTb, 1, 4, str.tostring(lostTrades), text_color=color.red)
    table.cell(statTb, 0, 5, "THẮNG - THUA", bgcolor=bgDiff)
    table.cell(statTb, 1, 5, str.tostring(winMinusLose), bgcolor=bgDiff)

//===================== ALERTS =====================//
realtimeOk = not alertRealtimeOnly or barstate.isrealtime
trendReverseUp = trendUp and trendDown[1]
trendReverseDown = trendDown and trendUp[1]
// V25: alertWithPrice được nối bằng alert() động để có thể kèm Entry/STP/TP.
if alertWithPrice and realtimeOk and alertPreview and buyPreview
    alert("KING MUA PREVIEW | Entry: " + f_price(buyEntry) + " | STP: " + f_price(buyStp) + " | TP1: " + f_price(buyTp1) + " | TP2: " + f_price(buyTp2) + " | TP3: " + f_price(buyTp3), alert.freq_once_per_bar)
if alertWithPrice and realtimeOk and alertPreview and sellPreview
    alert("KING BÁN PREVIEW | Entry: " + f_price(sellEntry) + " | STP: " + f_price(sellStp) + " | TP1: " + f_price(sellTp1) + " | TP2: " + f_price(sellTp2) + " | TP3: " + f_price(sellTp3), alert.freq_once_per_bar)
if alertWithPrice and alertEntryConfirm and buySignal
    alert("KING MUA ENTRY CONFIRM | Entry: " + f_price(buyEntry) + " | STP: " + f_price(buyStp) + " | TP1: " + f_price(buyTp1) + " | TP2: " + f_price(buyTp2) + " | TP3: " + f_price(buyTp3), alert.freq_once_per_bar_close)
if alertWithPrice and alertEntryConfirm and sellSignal
    alert("KING BÁN ENTRY CONFIRM | Entry: " + f_price(sellEntry) + " | STP: " + f_price(sellStp) + " | TP1: " + f_price(sellTp1) + " | TP2: " + f_price(sellTp2) + " | TP3: " + f_price(sellTp3), alert.freq_once_per_bar_close)

alertcondition(alertPreview and realtimeOk and buyPreview, "MUA PREVIEW", "KING MUA PREVIEW")
alertcondition(alertPreview and realtimeOk and sellPreview, "BÁN PREVIEW", "KING BÁN PREVIEW")
alertcondition(alertEntryConfirm and buySignal, "MUA ENTRY HOÀN CHỈNH", "KING MUA ENTRY CONFIRM")
alertcondition(alertEntryConfirm and sellSignal, "BÁN ENTRY HOÀN CHỈNH", "KING BÁN ENTRY CONFIRM")
alertcondition(alertReverse and trendReverseUp, "ĐẢO CHIỀU TĂNG", "KING ĐẢO CHIỀU SANG TĂNG")
alertcondition(alertReverse and trendReverseDown, "ĐẢO CHIỀU GIẢM", "KING ĐẢO CHIỀU SANG GIẢM")
````
