# Thai Stock Timing & Summary Dashboard

- url: https://www.tradingview.com/script/q0zJqrfG-Thai-Stock-Timing-Summary-Dashboard/
- type: indicator
- pine_id: PUB;6a4c854e9b0544a9a910ba3a395a576a
- version: 1.0

## Description

Timing Thailand
Thai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary DashboardThai Stock Timing & Summary Dashboard

## Source Code

````pine
//@version=6
indicator("Thai Stock Timing & Summary Dashboard", overlay=true, max_labels_count=50, max_bars_back=5000)

// ===== INPUTS =====
g_main = "ตั้งค่าทั่วไป"
opt_day = "วิเคราะห์รายวัน (Day of Week)"
opt_time = "วิเคราะห์รายชั่วโมง (Time of Day)"
mode = input.string(opt_day, "โหมดการวิเคราะห์", options=[opt_day, opt_time], group=g_main)
lookback = input.int(500, "จำนวนแท่งเทียนย้อนหลัง", minval=20, maxval=5000, group=g_main, tooltip="รายวัน: แนะนำ 252 (1 ปี) \nรายชั่วโมง: แนะนำ 1000-3000")
vol_len = input.int(20, "Period ค่าเฉลี่ย Vol & Volat", minval=5, group=g_main)

// ===== SERIES CALCULATIONS =====
// ถ้าเป็นรายชั่วโมง ให้คิด %Chg จาก (Close-Open) เพื่อดูแรงซื้อในชั่วโมงนั้นๆ
// ถ้าเป็นรายวัน ให้คิด %Chg จากราคาปิดวันก่อนหน้า
is_time_mode = mode == opt_time
pct_chg = is_time_mode ? (open != 0 ? ((close - open) / open) * 100 : 0.0) : (nz(close[1]) != 0 ? ((close - nz(close[1])) / nz(close[1])) * 100 : 0.0)

sma_vol = ta.sma(volume, vol_len)
rel_vol = sma_vol > 0 ? volume / sma_vol : 0.0

atr_val = ta.atr(vol_len)
rel_volat = atr_val > 0 ? ta.tr / atr_val : 0.0

// ----------------------------------------------------
// 🟢 Helper Functions (Global Scope) 🟢
// ----------------------------------------------------
c_text_green = color.rgb(76, 175, 80)
c_text_red   = color.rgb(255, 82, 82)
c_text_neut  = color.rgb(220, 220, 220)

f_color(val, is_pct_chg) =>
    if is_pct_chg
        val > 0.1 ? c_text_green : val < -0.1 ? c_text_red : c_text_neut
    else
        val > 1.05 ? c_text_green : val < 0.95 ? c_text_red : c_text_neut

f_winrate_color(val) =>
    val >= 55.0 ? c_text_green : val <= 45.0 ? c_text_red : c_text_neut

// ===== STATS COLLECTION =====
if barstate.islast
    // เช็คความถูกต้องของ Timeframe
    bool tf_error = false
    string tf_msg = ""
    
    if not is_time_mode and not timeframe.isdaily
        tf_error := true
        tf_msg := "⚠️ กรุณาเปลี่ยนเป็น Timeframe 1 วัน (1D) \nเพื่อดูสถิติ 'รายวัน'"
    else if is_time_mode and timeframe.isdaily
        tf_error := true
        tf_msg := "⚠️ กรุณาเปลี่ยนเป็น Timeframe 15m, 30m หรือ 1H \nเพื่อดูสถิติ 'รายชั่วโมง'"

    if tf_error
        var table err_tbl = table.new(position.top_right, 1, 1, border_width=1, frame_color=color.rgb(255, 82, 82))
        table.cell(err_tbl, 0, 0, tf_msg, bgcolor=color.rgb(30, 20, 20), text_color=color.white, text_size=size.normal)
    else
        int max_bars = math.min(lookback, bar_index)
        
        if max_bars > 0
            int[]   counts     = array.new_int(6, 0)
            int[]   pos_counts = array.new_int(6, 0)
            float[] sum_chg    = array.new_float(6, 0.0)
            float[] sum_vol    = array.new_float(6, 0.0)
            float[] sum_volat  = array.new_float(6, 0.0)
            
            // วนลูปเก็บสถิติย้อนหลัง
            for i = 0 to max_bars - 1
                int idx = 0
                
                if not is_time_mode
                    // โหมดรายวัน
                    int dw = dayofweek[i]
                    if dw == dayofweek.monday
                        idx := 1
                    else if dw == dayofweek.tuesday
                        idx := 2
                    else if dw == dayofweek.wednesday
                        idx := 3
                    else if dw == dayofweek.thursday
                        idx := 4
                    else if dw == dayofweek.friday
                        idx := 5
                else
                    // โหมดรายชั่วโมง (ยึดเวลาไทย Asia/Bangkok)
                    int h = hour(time[i], "Asia/Bangkok")
                    if h == 10
                        idx := 1 // เปิดตลาดเช้า
                    else if h == 11 or h == 12
                        idx := 2 // สาย-ก่อนพักเที่ยง
                    else if h == 14
                        idx := 3 // เปิดตลาดบ่าย (14:30)
                    else if h == 15
                        idx := 4 // บ่ายแก่
                    else if h == 16
                        idx := 5 // ก่อนปิดตลาด (16:00-16:30)
                
                if idx > 0
                    array.set(counts, idx, array.get(counts, idx) + 1)
                    if pct_chg[i] > 0
                        array.set(pos_counts, idx, array.get(pos_counts, idx) + 1)
                    
                    array.set(sum_chg, idx, array.get(sum_chg, idx) + pct_chg[i])
                    array.set(sum_vol, idx, array.get(sum_vol, idx) + rel_vol[i])
                    array.set(sum_volat, idx, array.get(sum_volat, idx) + rel_volat[i])
        
            // ===== UI DRAWING (TABLE) =====
            var table tbl = table.new(position.top_right, 6, 7, border_width=1, border_color=color.rgb(50, 55, 65), frame_color=color.rgb(50, 55, 65), frame_width=1)
            
            c_bg_header = color.rgb(30, 34, 45)
            c_text      = color.white
            c_mon       = color.rgb(243, 195, 0, 85)
            c_tue       = color.rgb(238, 99, 150, 85)
            c_wed       = color.rgb(44, 160, 44, 85)
            c_thu       = color.rgb(255, 127, 14, 85)
            c_fri       = color.rgb(31, 119, 180, 85)
            
            string h_title = is_time_mode ? "ช่วงเวลา (ไทย)" : "วันทำการ"
            table.cell(tbl, 0, 0, h_title, bgcolor=c_bg_header, text_color=c_text, text_size=size.normal, text_halign=text.align_center)
            table.cell(tbl, 1, 0, "จำนวนแท่ง", bgcolor=c_bg_header, text_color=c_text, text_size=size.normal, text_halign=text.align_center)
            table.cell(tbl, 2, 0, "โอกาสแท่งเขียว", bgcolor=c_bg_header, text_color=c_text, text_size=size.normal, text_halign=text.align_center)
            table.cell(tbl, 3, 0, "%Chg เฉลี่ย", bgcolor=c_bg_header, text_color=c_text, text_size=size.normal, text_halign=text.align_center)
            table.cell(tbl, 4, 0, "Relative Vol.", bgcolor=c_bg_header, text_color=c_text, text_size=size.normal, text_halign=text.align_center)
            table.cell(tbl, 5, 0, "Relative Volat.", bgcolor=c_bg_header, text_color=c_text, text_size=size.normal, text_halign=text.align_center)
        
            string[] names_day  = array.from("", "จันทร์", "อังคาร", "พุธ", "พฤหัสฯ", "ศุกร์")
            string[] names_time = array.from("", "10:00 - 11:00", "11:00 - 12:30", "14:30 - 15:00", "15:00 - 16:00", "16:00 - 16:30")
            string[] act_names  = is_time_mode ? names_time : names_day
            color[]  day_bgs    = array.from(color.black, c_mon, c_tue, c_wed, c_thu, c_fri)
            
            // Variables for Summary
            float best_wr  = 0.0
            int   best_idx = 0
            
            for r = 1 to 5
                int total = array.get(counts, r)
                
                if total > 0
                    float wr = (array.get(pos_counts, r) / total) * 100
                    float avg_chg = array.get(sum_chg, r) / total
                    float avg_vol = array.get(sum_vol, r) / total
                    float avg_volat = array.get(sum_volat, r) / total
                    
                    // หาค่าที่ดีที่สุดสำหรับทำสรุปผล (เน้น Win Rate สูง และ %Chg เป็นบวก)
                    if wr > best_wr and avg_chg > 0
                        best_wr := wr
                        best_idx := r
                        
                    bg_col = array.get(day_bgs, r)
                    
                    table.cell(tbl, 0, r, array.get(act_names, r), bgcolor=bg_col, text_color=c_text, text_size=size.normal)
                    table.cell(tbl, 1, r, str.tostring(total), bgcolor=bg_col, text_color=c_text_neut, text_size=size.normal)
                    table.cell(tbl, 2, r, str.tostring(wr, "#.0") + "%", bgcolor=bg_col, text_color=f_winrate_color(wr), text_size=size.normal)
                    table.cell(tbl, 3, r, (avg_chg > 0 ? "+" : "") + str.tostring(avg_chg, "#.00") + "%", bgcolor=bg_col, text_color=f_color(avg_chg, true), text_size=size.normal)
                    table.cell(tbl, 4, r, str.tostring(avg_vol, "#.00") + "x", bgcolor=bg_col, text_color=f_color(avg_vol, false), text_size=size.normal)
                    table.cell(tbl, 5, r, str.tostring(avg_volat, "#.00") + "x", bgcolor=bg_col, text_color=f_color(avg_volat, false), text_size=size.normal)
                else
                    table.cell(tbl, 0, r, array.get(act_names, r), bgcolor=array.get(day_bgs, r), text_color=c_text, text_size=size.normal)
                    table.cell(tbl, 1, r, "-", bgcolor=array.get(day_bgs, r), text_color=color.gray, text_size=size.normal)

            // ===== AI SUMMARY GENERATOR =====
            table.merge_cells(tbl, 0, 6, 5, 6) // รวมช่องแถวสุดท้ายให้ยาวทะลุ
            string summary_text = ""
            color  summary_col  = color.rgb(20, 24, 34)
            color  summary_txt  = color.rgb(240, 200, 80) // สีทอง
            
            if best_idx > 0 and best_wr >= 50.0
                string target = array.get(act_names, best_idx)
                string term   = is_time_mode ? "ช่วงเวลา" : "วัน"
                summary_text := "🎯 สรุป: หุ้นตัวนี้เหมาะจะเข้าเทรดใน " + term + " '" + target + "' \nเนื่องจากมีโอกาสปิดแท่งเขียวสูงสุด (" + str.tostring(best_wr, "#.0") + "%) และมีแนวโน้มวิ่งเชิงบวกชัดเจน"
            else
                summary_text := "⚠️ สรุป: สถิติหุ้นตัวนี้อยู่ในเกณฑ์แกว่งตัวผันผวน/ซึมลง (Win Rate < 50% ทุกช่วง)\nแนะนำให้เทรดด้วยความระมัดระวัง หรือรอจังหวะที่เทรนด์หลักชัดเจนขึ้น"
                summary_txt  := color.rgb(200, 200, 200) // สีเทา
                
            table.cell(tbl, 0, 6, summary_text, bgcolor=summary_col, text_color=summary_txt, text_size=size.normal, text_halign=text.align_left)
````
