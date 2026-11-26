# K08 Risk ON / Risk OFF VNINDEX

- url: https://www.tradingview.com/script/Ln15oWHF-K08-Risk-ON-Risk-OFF-VNINDEX/
- type: indicator
- pine_id: PUB;026afecb766843f8a8155d4d4a5412d3
- version: 1.0

## Description

Advanced RORO Market Scanner is a multi-timeframe market regime indicator that measures Risk-On/Risk-Off conditions using weighted momentum (63, 126, 189, and 252-day ROC) relative to its EMA equilibrium. By combining Daily and Weekly RORO signals, it classifies market environments into Strong Risk-On, Weak Risk-On, Short-Term Risk-Off, and Strong Risk-Off, helping traders align portfolio exposure with overall market trends.

## Source Code

````pine
//@version=6
indicator("Advanced RORO Market Scanner", overlay=false)

// 1. INPUTS CẤU HÌNH
tickerInput = input.string("INDEX:VN30", title="Thị trường cơ sở")
dailyLevel  = input.int(49, title="Độ mượt Daily (EMA)", minval=1)
weeklyLevel = input.int(21, title="Độ mượt Weekly (EMA)", minval=1)

// Hàm tính RORO tổng hợp
f_calc_roro(_close, _level) =>
    roc63  = (_close - _close[63]) / _close[63] * 100
    roc126 = (_close - _close[126]) / _close[126] * 100
    roc189 = (_close - _close[189]) / _close[189] * 100
    roc252 = (_close - _close[252]) / _close[252] * 100
    strength = (roc63 * 0.4 + roc126 * 0.2 + roc189 * 0.2 + roc252 * 0.2) * 100
    equal = ta.ema(strength, _level)
    roro = strength - equal
    roro

// 2. LẤY DỮ LIỆU ĐA KHUNG THỜI GIAN (DAILY & WEEKLY)
c1_daily  = request.security(tickerInput, "D", close)
c1_weekly = request.security(tickerInput, "W", close)

roro_daily  = f_calc_roro(c1_daily, dailyLevel)
roro_weekly = request.security(tickerInput, "W", f_calc_roro(close, weeklyLevel))

// 3. ĐÁNH GIÁ TRẠNG THÁI NÂNG CẤP & GÁN MÀU
roroColor   = color.gray
marketState = "NEUTRAL"

if roro_daily > 0 and roro_weekly > 0
    roroColor := color.green
    marketState := "STRONG RISK ON"
else if roro_daily > 0 and roro_weekly <= 0
    roroColor := color.blue
    marketState := "WEAK RISK ON (BULL TRAP?)"
else if roro_daily <= 0 and roro_weekly > 0
    roroColor := color.orange
    marketState := "SHORT-TERM RISK OFF"
else
    roroColor := color.red
    marketState := "STRONG RISK OFF"

// 4. PLOTTING
plot(roro_daily, title="Daily RORO", color=roroColor, style=plot.style_histogram, linewidth=3)
plot(0, title="Zero Line", color=color.gray, linewidth=1)

// 5. BẢNG ĐIỀU KHIỂN THÔNG TIN (DASHBOARD)
var table roroTable = table.new(position = position.top_right, columns = 2, rows = 3, border_width = 1)
if barstate.islast
    // Header
    table.cell(roroTable, 0, 0, text="Hệ Thống Cảnh Báo", text_color=color.white, bgcolor=color.black)
    table.cell(roroTable, 1, 0, text="Trạng Thái", text_color=color.white, bgcolor=color.black)
    
    // Khung Daily & Weekly
    table.cell(roroTable, 0, 1, text="Khung Ngày / Tuần", text_color=color.white, bgcolor=color.gray)
    table.cell(roroTable, 1, 1, text=(roro_daily > 0 ? "D:XANH" : "D:ĐỎ") + " | " + (roro_weekly > 0 ? "W:XANH" : "W:ĐỎ"), text_color=color.white, bgcolor=color.gray)
    
    // Kết luận chiến lược
    table.cell(roroTable, 0, 2, text="CHIẾN LƯỢC CHUNG", text_color=color.white, bgcolor=roroColor)
    table.cell(roroTable, 1, 2, text=marketState, text_color=color.white, bgcolor=roroColor)

// 6. CÀI ĐẶT CHUÔNG CẢNH BÁO (ALERT)
alertcondition(ta.crossover(roro_daily, 0), title="Cảnh báo: Bắt đầu RISK ON", message="Thị trường chung chuyển sang trạng thái RISK ON, tìm kiếm điểm mua!")
alertcondition(ta.crossunder(roro_daily, 0), title="Cảnh báo: Bắt đầu RISK OFF", message="Thị trường chung chuyển sang trạng thái RISK OFF, hạ tỷ trọng cổ phiếu!")
````
