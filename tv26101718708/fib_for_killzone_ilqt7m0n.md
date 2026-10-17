# Fib for Killzone

- url: https://www.tradingview.com/script/iLQT7m0n-Fib-for-Killzone/
- type: indicator
- pine_id: PUB;38792713e4e947e385ddc0b1f4bc6dbb
- version: 4.0

## Description

Fib for Killzone to find the direction for next session trading

## Source Code

````pine
//@version=5
indicator("Fib for Killzone", overlay=true, max_lines_count=500, max_labels_count=500)

// ==============================================================================
// 1. INPUTS (CÀI ĐẶT THÔNG SỐ)
// ==============================================================================
grp_sessions = "Cài đặt Phiên giờ"
tz_input     = input.string("America/New_York", "Múi giờ (Chuẩn EST)", group=grp_sessions)

// Cài đặt London
show_ldn     = input.bool(true, "✅ Bật phiên London", group=grp_sessions)
ldn_1h       = input.session("0200-0600", "London: Khung giờ đo Đỉnh/Đáy", group=grp_sessions, tooltip="Đo và chờ đóng nến khung giờ này")
ldn_kz       = input.session("0200-0500", "London Killzone (Tô màu nền)", group=grp_sessions)

// Cài đặt New York
show_ny      = input.bool(true, "✅ Bật phiên New York", group=grp_sessions)
ny_1h        = input.session("1300-1700", "New York: Khung giờ đo Đỉnh/Đáy", group=grp_sessions, tooltip="Đo và chờ đóng nến khung giờ này")
ny_kz        = input.session("1300-1600", "New York Killzone (Tô màu nền)", group=grp_sessions)

grp_fibs     = "Cài đặt Fibonacci Levels"
reverse_fib  = input.bool(false, "🔄 Đảo ngược Fibonacci (Reverse)", group=grp_fibs, tooltip="Bật để lật ngược chiều vẽ Fib (0 ở đỉnh, 1 ở đáy)")
extend_lines = input.int(5, "Kéo dài đường Fib ra (số nến)", group=grp_fibs)

// --- TÍNH NĂNG MÀU SẮC MỚI ---
use_global_col = input.bool(false, "🎨 Dùng 1 màu chung cho tất cả Fib", group=grp_fibs)
global_col     = input.color(color.gray, "Màu chung (nếu bật ở trên)", group=grp_fibs)

// Khai báo các mức Fib
show_m1   = input.bool(true, "", inline="m1", group=grp_fibs), fib_m1   = input.float(-1.0, "", inline="m1", group=grp_fibs), col_m1   = input.color(color.gray, "", inline="m1", group=grp_fibs)
show_m05  = input.bool(true, "", inline="m05", group=grp_fibs), fib_m05  = input.float(-0.5, "", inline="m05", group=grp_fibs), col_m05  = input.color(color.gray, "", inline="m05", group=grp_fibs)
show_0    = input.bool(true, "", inline="0", group=grp_fibs), fib_0    = input.float(0.0, "", inline="0", group=grp_fibs), col_0    = input.color(color.gray, "", inline="0", group=grp_fibs)
show_05   = input.bool(true, "", inline="05", group=grp_fibs), fib_05   = input.float(0.5, "", inline="05", group=grp_fibs), col_05   = input.color(color.gray, "", inline="05", group=grp_fibs)
show_1    = input.bool(true, "", inline="1", group=grp_fibs), fib_1    = input.float(1.0, "", inline="1", group=grp_fibs), col_1    = input.color(color.gray, "", inline="1", group=grp_fibs)
show_1618 = input.bool(true, "", inline="1618", group=grp_fibs), fib_1618 = input.float(1.618, "", inline="1618", group=grp_fibs), col_1618 = input.color(color.gray, "", inline="1618", group=grp_fibs)
show_2    = input.bool(true, "", inline="2", group=grp_fibs), fib_2    = input.float(2.0, "", inline="2", group=grp_fibs), col_2    = input.color(color.gray, "", inline="2", group=grp_fibs)
show_25   = input.bool(true, "", inline="25", group=grp_fibs), fib_25   = input.float(2.5, "", inline="25", group=grp_fibs), col_25   = input.color(color.gray, "", inline="25", group=grp_fibs)
show_3    = input.bool(true, "", inline="3", group=grp_fibs), fib_3    = input.float(3.0, "", inline="3", group=grp_fibs), col_3    = input.color(color.gray, "", inline="3", group=grp_fibs)
show_4    = input.bool(true, "", inline="4", group=grp_fibs), fib_4    = input.float(4.0, "", inline="4", group=grp_fibs), col_4    = input.color(color.gray, "", inline="4", group=grp_fibs)
show_5    = input.bool(true, "", inline="5", group=grp_fibs), fib_5    = input.float(5.0, "", inline="5", group=grp_fibs), col_5    = input.color(color.gray, "", inline="5", group=grp_fibs)
show_6    = input.bool(true, "", inline="6", group=grp_fibs), fib_6    = input.float(6.0, "", inline="6", group=grp_fibs), col_6    = input.color(color.gray, "", inline="6", group=grp_fibs)
show_7    = input.bool(true, "", inline="7", group=grp_fibs), fib_7    = input.float(7.0, "", inline="7", group=grp_fibs), col_7    = input.color(color.gray, "", inline="7", group=grp_fibs)

// ==============================================================================
// 2. KHỞI TẠO MẢNG DỮ LIỆU
// ==============================================================================
var float[] fib_levels = array.new_float()
var color[] fib_colors = array.new_color()
var bool[] fib_shows   = array.new_bool()

if barstate.isfirst
    array.push(fib_shows, show_m1), array.push(fib_levels, fib_m1), array.push(fib_colors, col_m1)
    array.push(fib_shows, show_m05), array.push(fib_levels, fib_m05), array.push(fib_colors, col_m05)
    array.push(fib_shows, show_0), array.push(fib_levels, fib_0), array.push(fib_colors, col_0)
    array.push(fib_shows, show_05), array.push(fib_levels, fib_05), array.push(fib_colors, col_05)
    array.push(fib_shows, show_1), array.push(fib_levels, fib_1), array.push(fib_colors, col_1)
    array.push(fib_shows, show_1618), array.push(fib_levels, fib_1618), array.push(fib_colors, col_1618)
    array.push(fib_shows, show_2), array.push(fib_levels, fib_2), array.push(fib_colors, col_2)
    array.push(fib_shows, show_25), array.push(fib_levels, fib_25), array.push(fib_colors, col_25)
    array.push(fib_shows, show_3), array.push(fib_levels, fib_3), array.push(fib_colors, col_3)
    array.push(fib_shows, show_4), array.push(fib_levels, fib_4), array.push(fib_colors, col_4)
    array.push(fib_shows, show_5), array.push(fib_levels, fib_5), array.push(fib_colors, col_5)
    array.push(fib_shows, show_6), array.push(fib_levels, fib_6), array.push(fib_colors, col_6)
    array.push(fib_shows, show_7), array.push(fib_levels, fib_7), array.push(fib_colors, col_7)

// ==============================================================================
// 3. XÁC ĐỊNH THỜI GIAN BACKGROUND & THỜI GIAN ĐO FIB
// ==============================================================================
in_ldn_1h = not na(time(timeframe.period, ldn_1h, tz_input))
in_ny_1h  = not na(time(timeframe.period, ny_1h, tz_input))

in_ldn_kz = not na(time(timeframe.period, ldn_kz, tz_input))
in_ny_kz  = not na(time(timeframe.period, ny_kz, tz_input))

bgcolor((show_ldn and in_ldn_kz) ? color.new(color.blue, 95) : na, title="London KZ BG")
bgcolor((show_ny and in_ny_kz) ? color.new(color.red, 95) : na, title="NY KZ BG")

// ==============================================================================
// 4. LOGIC CHỜ ĐÓNG NẾN VÀ VẼ FIB
// ==============================================================================
type SessionTracker
    float hi
    float lo
    line[] lines
    label[] labels

var ldn_tracker = SessionTracker.new(na, na, array.new_line(), array.new_label())
var ny_tracker  = SessionTracker.new(na, na, array.new_line(), array.new_label())

method processSession(SessionTracker s, bool in_1h, float[] levels, color[] colors, bool[] shows, int ext, bool rev, bool use_gb_col, color gb_col) =>
    // Xác định lúc Bắt đầu và lúc Kết thúc (Đóng nến) của khung giờ đo
    is_start = in_1h and not in_1h[1]
    is_end   = not in_1h and in_1h[1] 

    if is_start
        s.hi := high
        s.lo := low

    if in_1h
        s.hi := math.max(s.hi, high)
        s.lo := math.min(s.lo, low)

    if is_end
        // Nến 1H vừa đóng xong. Bắt đầu khóa Đỉnh/Đáy và vẽ Fib
        array.clear(s.lines)
        array.clear(s.labels)
        
        // Tính khoảng giá (Range) và ép kiểu float rõ ràng
        float diff = s.hi - s.lo

        for i = 0 to array.size(levels) - 1
            if array.get(shows, i)
                float lvl = array.get(levels, i)
                float price = na
                
                // Thuật toán đảo chiều: Tách bạch if/else để tránh lỗi compiler
                if rev
                    price := s.hi - (diff * lvl)
                else
                    price := s.lo + (diff * lvl)
                
// Thuật toán chọn màu: Nếu bật dùng màu chung thì lấy màu chung, ngược lại lấy màu riêng
                color final_color = use_gb_col ? gb_col : array.get(colors, i)
                
                ln = line.new(bar_index, price, bar_index + ext, price, color=final_color, style=line.style_dashed)
                lb = label.new(bar_index + ext, price, "" + str.tostring(lvl), color=color.new(color.white, 100), textcolor=final_color, style=label.style_label_left, size=size.small)

                array.push(s.lines, ln)
                array.push(s.labels, lb)

// Gọi hàm xử lý
if show_ldn
    ldn_tracker.processSession(in_ldn_1h, fib_levels, fib_colors, fib_shows, extend_lines, reverse_fib, use_global_col, global_col)

if show_ny
    ny_tracker.processSession(in_ny_1h, fib_levels, fib_colors, fib_shows, extend_lines, reverse_fib, use_global_col, global_col)
````
