<!-- tradingview-pine-id: PUB;0eb2c330c8de4d33acee75b8f3f70c67 -->
<!-- tradingviewscripts-format: 1 -->
# PE Ratio (Area)

Source: https://www.tradingview.com/script/eufnhkl5-PE-Ratio-Area-Green-Red/

## Description

Price to Earning Ration ( PE )

PE > 0  ==>  Green
PE < 0  ==>  Red

Price Line and Color can be adjusted

---

## Source Code

````pine
//@version=6
indicator('PE Ratio (Area)', overlay = false)

// --- ตัวเลือก: ถ้า PE < 0 ให้แสดงเป็น 0 ---
clampNegative = input.bool(false, 'Non Negative PE')

// --- ดึง EPS แบบ TTM แล้วคำนวณ PE ---
eps_ttm = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_DILUTED', 'TTM')
pe_raw = eps_ttm != 0 ? close / eps_ttm : na

// --- ถ้าเปิดตัวเลือก: PE ติดลบ -> 0, ที่เหลือเหมือนเดิม ---
pe = clampNegative and not na(pe_raw) and pe_raw < 0 ? 0 : pe_raw

// --- สี: PE < 0 = แดง, PE >= 0 = เขียว ---
peColor = pe >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

// --- วาด area ---
plot(pe, title = 'PE', style = plot.style_area, color = peColor, linewidth = 1)
hline(0, 'Zero', color = color.gray, linestyle = hline.style_dashed)

// --- แสดงตัวเลข PE ล่าสุดที่ปลายกราฟ ---
if barstate.islast and not na(pe)
    label.new(x = bar_index, y = pe, text = 'PE ' + str.tostring(pe, '#.##'), color = peColor, style = label.style_label_left, textcolor = color.white, size = size.normal)
````
