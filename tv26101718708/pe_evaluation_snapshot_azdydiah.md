# P/E Evaluation Snapshot 

- url: https://www.tradingview.com/script/azdydiAh/
- type: indicator
- pine_id: PUB;8c9d0c31595f42aa84232d7ab140d0fb
- version: 1.0

## Description

The Quick P/E Evaluation indicator is designed to help investors quickly assess whether a stock is trading at a premium or discount relative to its historical valuation using the Price-to-Earnings (P/E) ratio. Instead of relying on raw P/E values, this tool applies statistical normalization and smoothing techniques to create a dynamic valuation framework that adapts to each stock’s historical behavior.

⚙️ Key Features & Components:
(1) Smoothed P/E Calculation
Uses a Median Filter combined with EMA smoothing to reduce noise and eliminate extreme fluctuations caused by unstable earnings.

(2) Dynamic Valuation Bands
Automatically constructs:
Mean P/E (12-month baseline)
+1 Standard Deviation (overvaluation zone)
-1 Standard Deviation (undervaluation zone)

(3) Multi-Timeframe Perspective
Tracks:
- 3M P/E (short-term sentiment)
- 6M P/E (mid-term trend)
- 12M P/E (long-term anchor)

(4) Integrated Valuation Table
Displays a structured overview including current valuation, historical benchmarks, and instant classification: Undervalued / Fair / Overvalued

🧠 How to Use:
Undervalued Zone (P/E < -1SD)
→ Potential accumulation zone, especially when earnings quality is stable

Fair Value Zone
→ Neutral range, suitable for holding or trend-following strategies

Overvalued Zone (P/E > +1SD)
→ Caution zone; consider profit-taking or reassessing expectations

💡 Best used in combination with: Earnings growth, margin trends, and sector-relative valuation

⚠️ Limitations:
Most effective for: FMCG, manufacturing & production, consumer goods, and non-financial businesses with relatively stable earnings

Should NOT be used for: Financial companies (banks, insurance, securities), companies with highly volatile or negative earnings, and early-stage growth businesses where profits are not yet stable

----------------------------------------------------------------

Chỉ báo Quick P/E Evaluation được thiết kế nhằm giúp nhà đầu tư nhanh chóng đánh giá liệu một cổ phiếu đang được giao dịch ở mức premium hay discount so với định giá lịch sử của nó thông qua chỉ số Price-to-Earnings (P/E). Thay vì chỉ dựa vào P/E thô, công cụ này áp dụng các phương pháp chuẩn hóa thống kê và làm mượt dữ liệu để xây dựng một khung định giá động, thích ứng với hành vi lịch sử của từng cổ phiếu.

⚙️ Các tính năng & thành phần chính:
(1) Làm mượt P/E
Sử dụng Median Filter kết hợp EMA để giảm nhiễu và loại bỏ các biến động cực đoan do lợi nhuận không ổn định gây ra.

(2) Dải định giá động
Tự động xây dựng:
Mean P/E (mốc trung bình 12 tháng)
+1 Độ lệch chuẩn (vùng định giá cao)
-1 Độ lệch chuẩn (vùng định giá thấp)

(3) Góc nhìn đa khung thời gian
Theo dõi:
- P/E 3 tháng (tâm lý ngắn hạn)
- P/E 6 tháng (xu hướng trung hạn)
- P/E 12 tháng (mốc tham chiếu dài hạn)

(4) Bảng định giá tích hợp
Hiển thị tổng quan gồm: định giá hiện tại, các mốc lịch sử và phân loại nhanh: Undervalued / Fair / Overvalued

🧠 Cách sử dụng:
Vùng định giá thấp (P/E < -1SD)
→ Có thể là vùng tích lũy tiềm năng, đặc biệt khi chất lượng lợi nhuận ổn định

Vùng giá trị hợp lý
→ Vùng trung tính, phù hợp để nắm giữ hoặc theo xu hướng

Vùng định giá cao (P/E > +1SD)
→ Vùng cần thận trọng; cân nhắc chốt lời hoặc đánh giá lại kỳ vọng

💡 Nên sử dụng kết hợp với: Tăng trưởng lợi nhuận, xu hướng biên lợi nhuận và định giá tương đối theo ngành

⚠️ Hạn chế:
Phù hợp nhất với: FMCG, sản xuất & chế biến, hàng tiêu dùng và các doanh nghiệp phi tài chính có lợi nhuận tương đối ổn định

Không nên sử dụng cho: Các doanh nghiệp tài chính (ngân hàng, bảo hiểm, chứng khoán), các công ty có lợi nhuận biến động mạnh hoặc âm, và các doanh nghiệp tăng trưởng giai đoạn đầu khi lợi nhuận chưa ổn định

## Source Code

````pine
//@version=6
//***RECOMMENDATION: The P/E Metric should be applied for FMCG, Manufacturing & Production, Utilities Businesses (Non-Financials)
//***KHUYẾN CÁO: Chỉ số P/E nên được sử dụng cho các doanh nghiệp thuộc ngành FMCG, sản xuất & chế biến, và tiện ích (Nhóm Phi Tài Chính)

indicator("Quick P/E Evaluation", overlay = false)

//USER SETTINGS
minSpacing  = input.float(0.3, "Min Label Spacing (P/E units)")
labelOffset = input.int(3, "Label Offset (bars)")

// Smoothen the EPS to avoid extreme values plot on the chart 
eps_floor   = input.float(500, "EPS Floor Filter")
med_len     = input.int(5, "Median Filter Length")
ema_len     = input.int(10, "EMA Smoothing Length")

// Format values into 2 DP
f_fmt(x) =>
    na(x) ? "N/A" : str.tostring(x, "#.00")

// =========================
// 1. Calculate EPS
// =========================
eps_q = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE", "FQ")
eps_ttm_raw = nz(eps_q) + nz(eps_q[1]) + nz(eps_q[2]) + nz(eps_q[3])
eps_ttm = na(eps_ttm_raw) ? eps_ttm_raw[1] : eps_ttm_raw

// =========================
// 2. Formulate the P/E
// =========================
eps_safe = math.abs(eps_ttm) < eps_floor ? na : eps_ttm
pe_raw   = not na(eps_safe) ? close / eps_safe : na
pe_clean = not na(eps_safe) and eps_safe > 0 ? pe_raw : na
pe_med   = ta.median(pe_clean, med_len)
pe       = ta.ema(pe_med, ema_len)

// =========================
// 3. Setting Time Intervals
// =========================
pe_3m  = ta.sma(pe, 60)
pe_6m  = ta.sma(pe, 120)
pe_12m = ta.sma(pe, 240)

// =========================
// 4. Defining the P/E Valuation Bands 
// =========================
pe_mean  = pe_12m
pe_std   = ta.stdev(pe, 240)
pe_upper = pe_mean + pe_std
pe_lower = pe_mean - pe_std

// =========================
// 5. Plotting the P/E onto a separated pannel 
// =========================
plot(pe,        "Current P/E", color=color.blue, linewidth=2)
plot(pe_mean,   "Mean P/E", color=color.orange, linewidth=2)

plot(pe_upper,  "+1 SD",
     color=color.new(color.red, 55),
     linewidth=1,
     style=plot.style_circles)

plot(pe_lower,  "-1 SD",
     color=color.new(color.green, 55),
     linewidth=1,
     style=plot.style_circles)

// =========================
// 6. Creating Label Tags for each P/E values
// =========================
float y1 = pe
float y2 = pe_mean
float y3 = pe_upper
float y4 = pe_lower

if math.abs(y1 - y2) < minSpacing
    y2 := y1 + minSpacing
if math.abs(y2 - y3) < minSpacing
    y3 := y2 + minSpacing
if math.abs(y3 - y4) < minSpacing
    y4 := y3 + minSpacing

var label l1 = na
var label l2 = na
var label l3 = na
var label l4 = na

if barstate.islast
    label.delete(l1)
    label.delete(l2)
    label.delete(l3)
    label.delete(l4)

    l1 := label.new(bar_index + labelOffset, y1,
        "P/E " + f_fmt(pe),
        style=label.style_label_left,
        color=color.blue, textcolor=color.white)

    l2 := label.new(bar_index + labelOffset, y2,
        "Mean " + f_fmt(pe_mean),
        style=label.style_label_left,
        color=color.orange, textcolor=color.white)

    l3 := label.new(bar_index + labelOffset, y3,
        "+1SD " + f_fmt(pe_upper),
        style=label.style_label_left,
        color=color.red, textcolor=color.white)

    l4 := label.new(bar_index + labelOffset, y4,
        "-1SD " + f_fmt(pe_lower),
        style=label.style_label_left,
        color=color.green, textcolor=color.white)

// =========================
// 7. Evaluation Logic 
// =========================
string valuation = "N/A"

if not na(pe)
    if pe < pe_lower
        valuation := "Undervalued"
    else if pe > pe_upper
        valuation := "Overvalued"
    else
        valuation := "Fair"

// =========================
// 8. Setting the Summary Table 
// =========================
bgHeader = color.rgb(200,200,200)
bgRow    = color.white
bgAltRow = color.rgb(235,235,235)

textColor = color.black

goodColor = color.rgb(0,160,110)
badColor  = color.rgb(190,70,70)
fairColor = color.rgb(200,150,40)

rowColor(i) =>
    i % 2 == 0 ? bgRow : bgAltRow

var table t = table.new(position.top_right, 2, 9, border_width = 1)

if barstate.islast
    table.clear(t, 0, 0)

    table.cell(t, 0, 0, "Metric", bgcolor=bgHeader, text_color=textColor)
    table.cell(t, 1, 0, "Value",  bgcolor=bgHeader, text_color=textColor)

    table.cell(t, 0, 1, "Current P/E", bgcolor=rowColor(1), text_color=textColor)
    table.cell(t, 1, 1, f_fmt(pe), bgcolor=rowColor(1), text_color=textColor)

    table.cell(t, 0, 2, "Mean P/E", bgcolor=rowColor(2), text_color=textColor)
    table.cell(t, 1, 2, f_fmt(pe_mean), bgcolor=rowColor(2), text_color=textColor)

    table.cell(t, 0, 3, "+1 SD", bgcolor=rowColor(3), text_color=textColor)
    table.cell(t, 1, 3, f_fmt(pe_upper), bgcolor=rowColor(3), text_color=textColor)

    table.cell(t, 0, 4, "-1 SD", bgcolor=rowColor(4), text_color=textColor)
    table.cell(t, 1, 4, f_fmt(pe_lower), bgcolor=rowColor(4), text_color=textColor)

    table.cell(t, 0, 5, "3M P/E", bgcolor=rowColor(5), text_color=textColor)
    table.cell(t, 1, 5, f_fmt(pe_3m), bgcolor=rowColor(5), text_color=textColor)

    table.cell(t, 0, 6, "6M P/E", bgcolor=rowColor(6), text_color=textColor)
    table.cell(t, 1, 6, f_fmt(pe_6m), bgcolor=rowColor(6), text_color=textColor)

    table.cell(t, 0, 7, "12M P/E", bgcolor=rowColor(7), text_color=textColor)
    table.cell(t, 1, 7, f_fmt(pe_12m), bgcolor=rowColor(7), text_color=textColor)

    color evalColor = valuation == "Undervalued" ? goodColor :
                      valuation == "Overvalued" ? badColor : fairColor

    table.cell(t, 0, 8, "Evaluation", bgcolor=rowColor(8), text_color=textColor)
    table.cell(t, 1, 8, valuation, bgcolor=evalColor, text_color=color.white)
````
