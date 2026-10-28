# RSI & Choppiness Index (CI) Pro Dashboard + Alerts by ubao

- url: https://www.tradingview.com/script/sDEKFKqZ/
- type: indicator
- pine_id: PUB;dc3fb3fd048e4095a086810234703447
- version: 1.0

## Description

Hello, this is ubao.

I am sharing the [RSI & CI Multi-Timeframe Dashboard], an essential filtering indicator designed to help you avoid getting caught in short-term noise (whipsaws) and instantly identify whether the market is currently "Trending" or "Choppy".

To save valuable chart space, it is compactly displayed in the corner of your screen, allowing you to cross-check momentum (RSI) and market conditions (CI) across multiple timeframes at a single glance.

🔥 Core Features

Multi-Timeframe (MTF) Support: Intuitively check indicator values for the 5m, 15m, 1H, 4H, Daily, and Weekly timeframes all within one clean table.

Choppiness Index (CI) Integration: Diagnoses the 'state of the market' rather than just the direction.

🟢 Trending Market (CI < 38.2): Strong directional movement has begun. (Favorable for breakouts and trend following)

🟠 Choppy Market (CI > 61.8): Directionless, whipsaw conditions. (Consider range trading or staying flat)

Conditional "Neon Sign" UI: The dashboard maintains a calm, unobtrusive color during neutral conditions. It only lights up with custom alert colors when overbought/oversold levels are reached or strong trends emerge, providing excellent visibility without distraction.

Built-in Real-time Alerts: Get instant alerts for RSI OB/OS and CI Trend/Choppy states based on the timeframe of your currently active chart.

💡 Practical Trading Tips

When considering a breakout trade, if the higher timeframe (e.g., 1H, 4H) CI indicates a 'Choppy Market' (Orange), the probability of a fakeout is high. Consider reducing your position size or waiting for a better setup.

The most powerful trend-following entry often occurs when the CI shifts into a 'Trending Market' (Green) while momentum aligns. Using this dashboard as a filter alongside Price Action or VPA (Volume Price Analysis) will significantly help protect your win rate.

⚙️ Fully Customizable
You can freely modify all of the following in the indicator settings:

Indicator Inputs: Lengths, RSI OB/OS levels, and CI Fibonacci thresholds.

UI Layout: Table position, cell width, and row height.

Colors: Full control over background, text, and conditional alert colors for every state.

I hope this tool helps you stay on the right side of the market.
Trade Safe!

## Source Code

````pine
//@version=5
indicator("RSI & CI Dashboard + Alerts", shorttitle="RSI & CI Pro", overlay=true)

// --- [Inputs: Logic Settings] ---
group_logic = "⚙️ 지표 및 수치 설정 (Logic)"
rsi_len    = input.int(14, "RSI 길이", group=group_logic)
rsi_ob     = input.int(70, "RSI 과매수 기준", group=group_logic)
rsi_os     = input.int(30, "RSI 과매도 기준", group=group_logic)

ci_len     = input.int(14, "CI 길이", group=group_logic)
ci_trend   = input.float(38.2, "CI 추세 기준 (이하)", step=0.1, group=group_logic)
ci_chop    = input.float(61.8, "CI 횡보 기준 (이상)", step=0.1, group=group_logic)

// --- [Inputs: Colors] ---
group_color = "🎨 색상 설정 (Colors)"
c_text      = input.color(color.white, "텍스트 색상", group=group_color)
c_header    = input.color(color.rgb(40, 40, 40), "라벨(TF/RSI/CI) 배경색", group=group_color)
c_neutral   = input.color(color.rgb(50, 50, 50), "중립/평상시 배경색", group=group_color) // ⬅️ 추가된 중립장 색상 옵션!
c_rsi_alert = input.color(color.red, "RSI 알람 색상", group=group_color)
c_ci_trend  = input.color(color.new(color.green, 40), "CI 추세장 색상", group=group_color)
c_ci_chop   = input.color(color.new(color.orange, 40), "CI 횡보장 색상", group=group_color)

// --- [Inputs: Size & Position] ---
group_ui    = "📏 UI 및 크기 설정 (Layout)"
t_pos       = input.string("Top Right", "표 위치", options=["Top Right", "Bottom Right", "Top Center", "Bottom Center"], group=group_ui)
head_w      = input.float(3.0, "라벨 칸 너비", minval=1.0, maxval=10.0, step=0.1, group=group_ui)
cell_w      = input.float(4.0, "데이터 칸 너비", minval=1.0, maxval=10.0, step=0.1, group=group_ui)
cell_h      = input.float(3.0, "세로 높이", minval=1.0, maxval=10.0, step=0.1, group=group_ui)

// --- [Logic Functions] ---
calc_ci(len) =>
    100 * math.log10(math.sum(ta.tr, len) / (ta.highest(high, len) - ta.lowest(low, len))) / math.log10(len)

get_rsi(tf) => request.security(syminfo.tickerid, tf, ta.rsi(close, rsi_len))
get_ci(tf)  => request.security(syminfo.tickerid, tf, calc_ci(ci_len))

// 💡 알람 조건에 맞지 않으면 사용자가 지정한 c_neutral(중립장 색상)을 표시합니다.
f_color_rsi(val) => (val >= rsi_ob or val <= rsi_os) ? c_rsi_alert : c_neutral
f_color_ci(val)  => val < ci_trend ? c_ci_trend : val > ci_chop ? c_ci_chop : c_neutral
format_num(val)  => str.format("{0,number,0.0}", val)

// --- [Data Retrieval (MTF Table)] ---
tf_labels = array.from("5m", "15m", "1h", "4h", "D", "W")
tf_rsi    = array.from(get_rsi("5"), get_rsi("15"), get_rsi("60"), get_rsi("240"), get_rsi("1D"), get_rsi("1W"))
tf_ci     = array.from(get_ci("5"), get_ci("15"), get_ci("60"), get_ci("240"), get_ci("1D"), get_ci("1W"))

// --- [Draw Table] ---
var pos = t_pos == "Top Right" ? position.top_right : t_pos == "Bottom Right" ? position.bottom_right : t_pos == "Top Center" ? position.top_center : position.bottom_center
var tbl = table.new(pos, columns=array.size(tf_labels)+1, rows=3, bgcolor=color.new(color.black, 100), border_width=1, border_color=color.rgb(50,50,50))

if barstate.islast
    table.cell(tbl, 0, 0, "TF", text_color=c_text, bgcolor=c_header, width=head_w, height=cell_h)
    table.cell(tbl, 0, 1, "RSI", text_color=c_text, bgcolor=c_header, width=head_w, height=cell_h)
    table.cell(tbl, 0, 2, "CI", text_color=c_text, bgcolor=c_header, width=head_w, height=cell_h)
    
    for i=0 to array.size(tf_labels)-1
        r_val = array.get(tf_rsi, i)
        c_val = array.get(tf_ci, i)
        
        table.cell(tbl, i+1, 0, array.get(tf_labels, i), text_color=c_text, bgcolor=c_header, width=cell_w, height=cell_h)
        table.cell(tbl, i+1, 1, format_num(r_val), text_color=c_text, bgcolor=f_color_rsi(r_val), width=cell_w, height=cell_h)
        table.cell(tbl, i+1, 2, format_num(c_val), text_color=c_text, bgcolor=f_color_ci(c_val), width=cell_w, height=cell_h)

// =====================================================================
// 🚨 [알림(Alert) 기능] 🚨
// =====================================================================
cur_rsi = ta.rsi(close, rsi_len)
cur_ci  = calc_ci(ci_len)

alertcondition(cur_rsi >= rsi_ob, title="🚨 [RSI] 과매수 도달", message="RSI가 설정된 과매수 수치를 넘었습니다. (익절/숏 관점 고려)")
alertcondition(cur_rsi <= rsi_os, title="🚨 [RSI] 과매도 도달", message="RSI가 설정된 과매도 수치 아래로 내려갔습니다. (익절/롱 관점 고려)")
alertcondition(cur_ci < ci_trend, title="🟢 [CI] 추세장 진입", message="CI가 설정된 추세 수치 아래로 내려갔습니다. 강한 방향성 시작!")
alertcondition(cur_ci > ci_chop, title="🟠 [CI] 횡보장 진입", message="CI가 설정된 횡보 수치를 넘었습니다. 박스권 휩소 주의!")
````
