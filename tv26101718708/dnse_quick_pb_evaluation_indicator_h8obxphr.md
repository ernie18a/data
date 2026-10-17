# DNSE Quick P/B Evaluation Indicator 

- url: https://www.tradingview.com/script/H8oBxphR/
- type: indicator
- pine_id: PUB;73dc3eb6a69d46a98be92c86a5cc5a83
- version: 1.0

## Description

Chỉ báo Quick P/B Evaluation được thiết kế nhằm hỗ trợ nhà đầu tư nhanh chóng đánh giá liệu một cổ phiếu đang được giao dịch ở mức premium hay discount so với định giá lịch sử của nó thông qua chỉ số Price-to-Book (P/B). Thay vì chỉ nhìn vào P/B một cách riêng lẻ, công cụ này áp dụng các phương pháp chuẩn hóa thống kê và làm mượt dữ liệu để xây dựng một khung định giá động, thích ứng với hành vi lịch sử của từng cổ phiếu.

⚙️ Các tính năng & thành phần chính:
(1) Làm mượt P/B
Sử dụng Median Filter kết hợp EMA để loại bỏ nhiễu và các giá trị ngoại lai thường gặp trong dữ liệu tài chính.

(2) Dải định giá động
Tự động xây dựng:
Mean P/B (mốc trung bình 12 tháng)
+1 Độ lệch chuẩn (vùng định giá cao)
-1 Độ lệch chuẩn (vùng định giá thấp)

(3) Góc nhìn đa khung thời gian
Theo dõi:
- P/B 3 tháng (tâm lý ngắn hạn)
- P/B 6 tháng (xu hướng trung hạn)
- P/B 12 tháng (mốc tham chiếu dài hạn)

(4) Bảng định giá tích hợp
Hiển thị tổng quan gồm: định giá hiện tại, các mốc lịch sử và phân loại nhanh: Undervalued / Fair / Overvalued

🧠 Cách sử dụng:
Vùng định giá thấp (P/B < -1SD)
→ Có thể là vùng tích lũy tiềm năng, đặc biệt khi được hỗ trợ bởi yếu tố cơ bản

Vùng giá trị hợp lý
→ Vùng trung tính, phù hợp để nắm giữ hoặc theo xu hướng

Vùng định giá cao (P/B > +1SD)
→ Vùng cần thận trọng; cân nhắc chốt lời hoặc đánh giá lại

💡 Nên sử dụng kết hợp với: ROE, triển vọng tăng trưởng và định giá tương đối theo ngành

⚠️ Hạn chế:
Phù hợp nhất với: Các doanh nghiệp tài chính (ngân hàng, bảo hiểm, chứng khoán) và các doanh nghiệp có tài sản lớn như bất động sản, hạ tầng, tiện ích

Không nên sử dụng cho: Các doanh nghiệp asset-light hoặc dựa nhiều vào tài sản vô hình (ví dụ: công nghệ, thương hiệu), các công ty tăng trưởng cao nơi giá trị phụ thuộc vào lợi nhuận tương lai, và các doanh nghiệp có giá trị sổ sách bị bóp méo hoặc không đáng tin cậy

-------------------------------------------------------------

The Quick P/B Evaluation indicator is designed to help traders and investors quickly assess whether a stock is trading at a premium or discount relative to its historical valuation using the Price-to-Book (P/B) ratio. Instead of looking at raw P/B in isolation, this tool applies statistical normalization and smoothing techniques to create a dynamic valuation framework that adapts to each stock’s historical behavior.

⚙️ Key Features & Components:
(1) Smoothed P/B Calculation
Uses median filtering + EMA smoothing to eliminate noise and outliers commonly seen in financial data.

(2) Dynamic Valuation Bands
Automatically constructs Mean P/B (12M baseline)
+1 Standard Deviation (Overvaluation zone)
-1 Standard Deviation (Undervaluation zone)

(3) Multi-Timeframe Context
Tracks:
- 3M P/B (short-term sentiment)
- 6M P/B (mid-term trend)
- 12M P/B (long-term anchor)

(4) Integrated Valuation Table
A structured dashboard showing: Current valuation, Historical benchmarks and Instant classification: Undervalued / Fair / Overvalued

🧠 How to Use:
Undervalued Zone (P/B < -1SD)
→ Potential accumulation zone, especially if supported by fundamentals

Fair Value Zone
→ Neutral range, useful for trend-following or holding positions

Overvalued Zone (P/B > +1SD)
→ Caution zone; consider profit-taking or re-evaluation

💡 Best used in combination with: ROE, Growth outlook and Sector-relative valuation

⚠️ Limitations:
Most effective for: Financial sector companies (banks, insurance, securities) and asset-heavy businesses such as real estate, infrastructure, and utilities

Should Not Be used for: Asset-light or intangible-driven businesses (e.g. tech, brand-heavy companies), high-growth companies where value is driven more by future earnings than current assets, and firms with distorted or unreliable book values

## Source Code

````pine
//@version=6
//***RECOMMENDATION: The P/B Metric should be applied for Financials (Banks, Insurance, Securities) & Asset-heavy Businesses
//***KHUYẾN CÁO: Chỉ số P/B nên được sử dụng cho các doanh nghiệp tài chính (Ngân hàng, Bảo hiểm, Chứng khoán) và doanh nghiệp có tài sản lớn

indicator("Quick P/B Evaluation", overlay = false)

//USER SETTINGS
minSpacing  = input.float(0.3, "Min Label Spacing (P/B units)")
labelOffset = input.int(3, "Label Offset (bars)")

// Optional smoothing (less aggressive than EPS case)
med_len     = input.int(5, "Median Filter Length")
ema_len     = input.int(10, "EMA Smoothing Length")

// Format values into 2 DP
f_fmt(x) =>
    na(x) ? "N/A" : str.tostring(x, "#.00")

// =========================
// 1. Calculate BVPS
// =========================
bvps_raw = request.financial(syminfo.tickerid, "BOOK_VALUE_PER_SHARE", "FQ")
bvps = na(bvps_raw) ? bvps_raw[1] : bvps_raw

// =========================
// 2. Formulate the P/B
// =========================
pb_raw   = not na(bvps) and bvps != 0 ? close / bvps : na
pb_med   = ta.median(pb_raw, med_len)
pb       = ta.ema(pb_med, ema_len)

// =========================
// 3. Setting Time Intervals
// =========================
pb_3m  = ta.sma(pb, 60)
pb_6m  = ta.sma(pb, 120)
pb_12m = ta.sma(pb, 240)

// =========================
// 4. Defining the P/B Valuation Bands 
// =========================
pb_mean  = pb_12m
pb_std   = ta.stdev(pb, 240)
pb_upper = pb_mean + pb_std
pb_lower = pb_mean - pb_std

// =========================
// 5. Plotting the P/B
// =========================
plot(pb,        "Current P/B", color=color.blue, linewidth=2)
plot(pb_mean,   "Mean P/B", color=color.orange, linewidth=2)

plot(pb_upper,  "+1 SD",
     color=color.new(color.red, 55),
     linewidth=1,
     style=plot.style_circles)

plot(pb_lower,  "-1 SD",
     color=color.new(color.green, 55),
     linewidth=1,
     style=plot.style_circles)

// =========================
// 6. Labels
// =========================
float y1 = pb
float y2 = pb_mean
float y3 = pb_upper
float y4 = pb_lower

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
        "P/B " + f_fmt(pb),
        style=label.style_label_left,
        color=color.blue, textcolor=color.white)

    l2 := label.new(bar_index + labelOffset, y2,
        "Mean " + f_fmt(pb_mean),
        style=label.style_label_left,
        color=color.orange, textcolor=color.white)

    l3 := label.new(bar_index + labelOffset, y3,
        "+1SD " + f_fmt(pb_upper),
        style=label.style_label_left,
        color=color.red, textcolor=color.white)

    l4 := label.new(bar_index + labelOffset, y4,
        "-1SD " + f_fmt(pb_lower),
        style=label.style_label_left,
        color=color.green, textcolor=color.white)

// =========================
// 7. Evaluation Logic
// =========================
string valuation = "N/A"

if not na(pb)
    if pb < pb_lower
        valuation := "Undervalued"
    else if pb > pb_upper
        valuation := "Overvalued"
    else
        valuation := "Fair"

// =========================
// 8. Table
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

    table.cell(t, 0, 1, "Current P/B", bgcolor=rowColor(1), text_color=textColor)
    table.cell(t, 1, 1, f_fmt(pb), bgcolor=rowColor(1), text_color=textColor)

    table.cell(t, 0, 2, "Mean P/B", bgcolor=rowColor(2), text_color=textColor)
    table.cell(t, 1, 2, f_fmt(pb_mean), bgcolor=rowColor(2), text_color=textColor)

    table.cell(t, 0, 3, "+1 SD", bgcolor=rowColor(3), text_color=textColor)
    table.cell(t, 1, 3, f_fmt(pb_upper), bgcolor=rowColor(3), text_color=textColor)

    table.cell(t, 0, 4, "-1 SD", bgcolor=rowColor(4), text_color=textColor)
    table.cell(t, 1, 4, f_fmt(pb_lower), bgcolor=rowColor(4), text_color=textColor)

    table.cell(t, 0, 5, "3M P/B", bgcolor=rowColor(5), text_color=textColor)
    table.cell(t, 1, 5, f_fmt(pb_3m), bgcolor=rowColor(5), text_color=textColor)

    table.cell(t, 0, 6, "6M P/B", bgcolor=rowColor(6), text_color=textColor)
    table.cell(t, 1, 6, f_fmt(pb_6m), bgcolor=rowColor(6), text_color=textColor)

    table.cell(t, 0, 7, "12M P/B", bgcolor=rowColor(7), text_color=textColor)
    table.cell(t, 1, 7, f_fmt(pb_12m), bgcolor=rowColor(7), text_color=textColor)

    color evalColor = valuation == "Undervalued" ? goodColor :
                      valuation == "Overvalued" ? badColor : fairColor

    table.cell(t, 0, 8, "Evaluation", bgcolor=rowColor(8), text_color=textColor)
    table.cell(t, 1, 8, valuation, bgcolor=evalColor, text_color=color.white)
````
