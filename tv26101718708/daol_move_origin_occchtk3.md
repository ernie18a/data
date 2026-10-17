# [DAOL] Move Origin

- url: https://www.tradingview.com/script/ocCChtk3-DAOL-Move-Origin/
- type: indicator
- pine_id: PUB;da26c0fc4a1a4c08b8634a883289ae42
- version: 1.0

## Description

⏺️ What is it?

[DAOL] Move Origin separates each close-to-close price change into two components:

🔹 Gap — current open minus previous close
🔹 Body — current close minus current open

It aggregates these components over a rolling window to show whether they support or offset one another.

Unlike annualized volatility, this indicator examines the components of price change rather than estimating yearly volatility.

⏺️ Indicator นี้คืออะไร?

[DAOL] Move Origin แยกการเปลี่ยนราคาปิดออกเป็นสองส่วน เพื่อดูว่า ราคาขยับจากการเปิดกระโดด หรือจากการเคลื่อนที่ระหว่างเปิดถึงปิด

🔹 Gap — ราคาเปิดปัจจุบันลบราคาปิดแท่งก่อน
🔹 Body — ราคาปิดปัจจุบันลบราคาเปิดปัจจุบัน

จากนั้นรวมย้อนหลังตามช่วงที่เลือก เพื่ออ่านว่าทั้งสองส่วนสนับสนุนหรือหักล้างกัน

ตัวนี้ไม่ได้คำนวณความผันผวนรายปี แต่ใช้วิเคราะห์องค์ประกอบของการเปลี่ยนราคา

⏺️ Why use Move Origin?

🔹 Distinguishes opening-price changes from open-to-close movement
🔹 Reveals opposing components hidden within the net price change
🔹 Normalizes component values using ATR
🔹 Shows the share of absolute component movement attributable to gaps
🔹 Provides confirmed-state alerts

Example: price opens 8 points above the previous close, then falls 5 points before closing. The net change is +3 points, consisting of a +8-point Gap and a −5-point Body.

⏺️ ทำไมต้องใช้?

🔹 แยกการเปลี่ยนราคาเปิดออกจากการเคลื่อนที่ระหว่างเปิดถึงปิด
🔹 เห็นการหักล้างที่อาจซ่อนอยู่ในราคาสุทธิ
🔹 ปรับขนาดองค์ประกอบด้วย ATR
🔹 ดูสัดส่วนระยะ Gap เทียบกับระยะของทั้งสองส่วน
🔹 มี Alert เมื่อสถานะยืนยันเปลี่ยน

ตัวอย่าง: เปิดสูงกว่าปิดแท่งก่อน 8 จุด แล้วลงระหว่างแท่ง 5 จุด ราคาจึงขึ้นสุทธิ 3 จุด โดยมี Gap +8 และ Body −5

⏺️ How does it work?

For every valid bar:

Gap + Body = Current Close − Previous Close

The indicator sums Gap and Body over 20 bars by default, then divides both sums by the same prior-bar ATR.

🔹 Gap Net / ATR — cumulative signed Gap component
🔹 Body Net / ATR — cumulative signed Body component
🔹 Total Net / ATR — their sum

These values are expressed in ATR units, not percentage returns. They are not bounded between −100 and +100.

⏺️ ทำงานอย่างไร?

สำหรับแต่ละแท่งที่มีข้อมูลครบ:

Gap + Body = ราคาปิดปัจจุบัน − ราคาปิดแท่งก่อน

ระบบรวม Gap และ Body ย้อนหลัง 20 แท่งตามค่าเริ่มต้น แล้วหารทั้งสองส่วนด้วย ATR ของแท่งก่อนหน้าตัวเดียวกัน

🔹 Gap Net / ATR — Gap สุทธิสะสม
🔹 Body Net / ATR — Body สุทธิสะสม
🔹 Total Net / ATR — ผลรวมของทั้งสองส่วน

ค่าแสดงเป็นหน่วย ATR ไม่ใช่เปอร์เซ็นต์ผลตอบแทน และไม่ได้จำกัดช่วงไว้ที่ −100 ถึง +100

⏺️ How to read the lines and colors

Lines:

🔹 Blue — Gap Net / ATR
🔹 Orange — Body Net / ATR
🔹 Total line — combined net movement, colored by the confirmed state

Confirmed states:

🔹 Green — both components are positive and meet the magnitude threshold
🔹 Red — both components are negative and meet the threshold
🔹 Gold — the components have opposite signs and both meet the threshold
🔹 Gray — one or both components are below the threshold, or initial confirmation is pending

The default magnitude threshold is 0.25 ATR for each component.

⏺️ อ่านเส้นและสีอย่างไร?

เส้นกราฟ:

🔹 น้ำเงิน — Gap Net / ATR
🔹 ส้ม — Body Net / ATR
🔹 เส้น Total — การเปลี่ยนราคาสุทธิรวม โดยใช้สีของสถานะยืนยัน

สถานะ:

🔹 เขียว — ทั้งสองส่วนเป็นบวกและผ่านเกณฑ์ขนาด
🔹 แดง — ทั้งสองส่วนเป็นลบและผ่านเกณฑ์ขนาด
🔹 ทอง — ทั้งสองส่วนสวนทิศทางกันและผ่านเกณฑ์ขนาด
🔹 เทา — ส่วนหนึ่งหรือทั้งสองส่วนต่ำกว่าเกณฑ์ หรือยังรอยืนยันสถานะแรก

ค่าเริ่มต้นกำหนดให้แต่ละส่วนมีขนาดอย่างน้อย 0.25 ATR

สีทองไม่ใช่สัญญาณกลับตัว และสีเทาไม่ได้ยืนยันว่าราคาไม่มีแนวโน้ม โดยเฉพาะกราฟ Intraday ที่ Gap อาจเล็กมากแม้ Body เดินหน้าชัดเจน

⏺️ Gap Share

Gap Share = Sum of absolute Gaps / (Sum of absolute Gaps + Sum of absolute Bodies) × 100

A value of 70% means gaps account for 70% of the measured absolute component movement in that window.

It does not mean gaps contributed 70% of the net return. Opposing movements can cancel in the net calculation.

When both absolute sums are zero, Gap Share is undefined and displayed as “--”.

⏺️ Gap Share คืออะไร?

Gap Share = ผลรวม |Gap| / (ผลรวม |Gap| + ผลรวม |Body|) × 100

ค่า 70% หมายถึง Gap มีสัดส่วน 70% ของระยะเคลื่อนไหวองค์ประกอบแบบค่าสัมบูรณ์ในช่วงนั้น

ไม่ได้หมายความว่า Gap สร้างผลตอบแทนสุทธิ 70% เพราะการเคลื่อนที่สวนกันอาจหักล้างในค่าสุทธิ

หากทั้งสองส่วนไม่มีการเคลื่อนไหว Gap Share จะไม่สามารถคำนวณได้และแสดง “--”

⏺️ Dashboard and default settings

The dashboard displays the confirmed state, latest raw state, Gap Net / ATR, Body Net / ATR, Total Net / ATR and Gap Share.

Default settings:

🔹 Window — 20 bars
🔹 ATR Length — 14
🔹 Minimum Component Magnitude — 0.25 ATR
🔹 Confirmation — 2 consecutive closed bars

Metrics update on closed bars. Confirmed-state colors may retain the preceding state while a new state is being confirmed.

The window requires complete price data. Missing inputs or a nonpositive ATR make the calculation unavailable.

⏺️ Dashboard และค่าเริ่มต้น

Dashboard แสดงสถานะยืนยัน สถานะล่าสุดก่อนยืนยัน Gap Net / ATR, Body Net / ATR, Total Net / ATR และ Gap Share

ค่าเริ่มต้น:

🔹 Window — 20 แท่ง
🔹 ATR Length — 14
🔹 Minimum Component Magnitude — 0.25 ATR
🔹 Confirmation — 2 แท่งปิดต่อเนื่อง

ค่าตัวเลขอัปเดตเมื่อแท่งปิด ส่วนสีอาจยังคงสถานะเดิมระหว่างรอยืนยันสถานะใหม่

ต้องมีข้อมูลราคาครบในช่วงคำนวณ หากข้อมูลขาดหรือ ATR ไม่เป็นบวก ระบบจะไม่แสดงค่าคำนวณ

⏺️ Alerts

🔹 Components up
🔹 Components down
🔹 Components opposed
🔹 Small or mixed
🔹 Any confirmed change

The first confirmed state initializes silently. Subsequent confirmed-state changes trigger alerts.

Use “Once Per Bar Close” and recreate alerts after changing inputs or code.

⏺️ การแจ้งเตือน

🔹 Components up — ทั้งสองส่วนขึ้น
🔹 Components down — ทั้งสองส่วนลง
🔹 Components opposed — ทั้งสองส่วนสวนกัน
🔹 Small or mixed — องค์ประกอบเล็กหรือไม่ผ่านเกณฑ์
🔹 Any confirmed change — ทุกการเปลี่ยนสถานะยืนยัน

สถานะแรกใช้เริ่มต้นระบบโดยไม่แจ้งเตือน จากนั้นแจ้งเมื่อสถานะยืนยันเปลี่ยน

ตั้ง “Once Per Bar Close” และสร้าง Alert ใหม่หลังเปลี่ยน Input หรือโค้ด

⏺️ Development and references

This Pine Script v6 implementation was written for this project without copying Community script source.

The close-to-open and open-to-close decomposition is an established concept. A related reference is Statistical Analysis of the Overnight and Daytime Return by F. Wang, K. Yamasaki, S. Havlin and H. E. Stanley (2009).

This indicator adapts the decomposition to chart-bar price differences and adds common-ATR normalization, absolute Gap Share, component alignment and closed-bar confirmation. It does not reproduce the paper’s statistical analysis or claim its findings apply to TFEX.

References:

https://arxiv.org/abs/0903.0993

https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/

⏺️ การพัฒนาและอ้างอิง

เขียนด้วย Pine Script v6 สำหรับโครงการนี้ โดยไม่คัดลอกโค้ดจากสคริปต์ Community

การแยก Close-to-Open และ Open-to-Close เป็นแนวคิดที่มีอยู่แล้ว อ้างอิงงาน Statistical Analysis of the Overnight and Daytime Return ของ F. Wang, K. Yamasaki, S. Havlin และ H. E. Stanley (2009)

ส่วนที่ต่อยอดคือการใช้ผลต่างราคาของแท่งกราฟ ปรับด้วย ATR ร่วมกัน เพิ่ม Gap Share การเปรียบเทียบทิศทางองค์ประกอบ และการยืนยันจากแท่งปิด

ไม่ได้จำลองการวิเคราะห์ทางสถิติทั้งหมดของงานวิจัย ไม่อ้างผลวิจัยนั้นเป็นหลักฐานประสิทธิภาพบน TFEX และไม่อ้างว่าไม่มีงานใกล้เคียงใน Community

⏺️ Limitations and disclaimer

🔹 On intraday charts, Gap refers to adjacent chart bars, not necessarily overnight movement.
🔹 Body measures open-to-close change, not the complete intrabar price path.
🔹 The indicator does not measure order flow, actual buying/selling pressure or institutional activity.
🔹 Futures rolls, price adjustments, missing bars and data errors can distort components.
🔹 All windows use bar counts; changing timeframe changes the period being measured.
🔹 Numerical identities have been checked; TradingView compilation and market-data validation remain pending.
🔹 For educational and informational purposes only. No investment advice, win probability or return guarantee is provided.

⏺️ ข้อจำกัดและคำชี้แจง

🔹 บนกราฟ Intraday คำว่า Gap หมายถึงราคาเปิดเทียบปิดแท่งก่อน ไม่จำเป็นต้องเป็น Gap ข้ามคืน
🔹 Body วัดการเปลี่ยนจากเปิดถึงปิด ไม่ใช่เส้นทางราคาทั้งหมดภายในแท่ง
🔹 ไม่วัด Order Flow แรงซื้อ–ขายจริง หรือกิจกรรมของสถาบัน
🔹 รอยต่อสัญญา การปรับราคา ข้อมูลขาดช่วง และข้อมูลผิดพลาดอาจทำให้องค์ประกอบคลาดเคลื่อน
🔹 สูตรนับตามจำนวนแท่ง เมื่อเปลี่ยน Timeframe ช่วงเวลาที่วิเคราะห์จะเปลี่ยนตาม
🔹 ตรวจเอกลักษณ์สูตรแล้ว แต่ยังไม่ได้ Compile ใน TradingView หรือทดสอบข้อมูลตลาดจริง
🔹 ใช้เพื่อการศึกษา ไม่ใช่คำแนะนำการลงทุน เปอร์เซ็นต์โอกาสชนะ หรือการรับประกันผลตอบแทน

## Source Code

````pine
//@version=6
// Original implementation for this project; no Community source copied.
// Concept: close-to-open / open-to-close decomposition, adapted to chart bars.
// https://arxiv.org/abs/0903.0993
// https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/
// Price differences used, not the paper's daily-return statistical estimator.
indicator("[DAOL] Move Origin", shorttitle="DAOL Origin", overlay=false, max_bars_back=1000)
int length=input.int(20,"Window bars",minval=2,maxval=250)
int atrLength=input.int(14,"ATR length",minval=2,maxval=250)
float threshold=input.float(0.25,"Minimum component magnitude (ATR)",minval=0.01,step=0.05)
int confirmBars=input.int(2,"Consecutive closed bars",minval=1,maxval=10)
bool showPanel=input.bool(true,"Show dashboard")
bool shade=input.bool(false,"Shade confirmed state")
if barstate.isfirst and not chart.is_standard
    runtime.error("Use standard OHLC/candlestick charts.")
// Do not replace missing inputs with zero: an invalid bar invalidates the window.
bool validBar=not na(open) and not na(close) and not na(close[1])
float gap=validBar ? open-close[1] : 0.0
float body=validBar ? close-open : 0.0
float validCount=math.sum(validBar ? 1.0 : 0.0,length)
float gapNet=math.sum(gap,length)
float bodyNet=math.sum(body,length)
float gapAbs=math.sum(math.abs(gap),length)
float bodyAbs=math.sum(math.abs(body),length)
float priorATR=ta.atr(atrLength)[1]
bool ready=bar_index>=length and validCount==length and not na(priorATR) and priorATR>0
float gapATR=ready ? gapNet/priorATR : na
float bodyATR=ready ? bodyNet/priorATR : na
float totalATR=ready ? (gapNet+bodyNet)/priorATR : na
float path=gapAbs+bodyAbs
// Share undefined when no movement; dashboard says --, not a spurious0%.
float gapShare=ready and path>0 ? 100*gapAbs/path : na
int raw=0
if ready
    if gapATR>=threshold and bodyATR>=threshold
        raw:=1
    else if gapATR<=-threshold and bodyATR<=-threshold
        raw:=-1
    else if (gapATR>=threshold and bodyATR<=-threshold) or (gapATR<=-threshold and bodyATR>=threshold)
        raw:=2
var int candidate=0
var int streak=0
var int confirmed=0
var bool initialized=false
var float closedGap=na
var float closedBody=na
var float closedTotal=na
var float closedShare=na
var int closedRaw=0
var bool closedReady=false
bool changed=false
if barstate.isconfirmed
    closedGap:=gapATR
    closedBody:=bodyATR
    closedTotal:=totalATR
    closedShare:=gapShare
    closedRaw:=raw
    closedReady:=ready
    if not ready
        streak:=0
        initialized:=false
        confirmed:=0
    else
        if streak==0 or candidate!=raw
            candidate:=raw
            streak:=1
        else
            streak:=math.min(streak+1,confirmBars)
        if streak>=confirmBars
            if not initialized
                confirmed:=candidate
                initialized:=true
            else if confirmed!=candidate
                confirmed:=candidate
                changed:=true
f_state(int s)=>
    s==1 ? "Gap + Body up" : s==-1 ? "Gap + Body down" : s==2 ? "Gap / Body opposed" : "Small / mixed components"
f_value(float x)=>
    na(x) ? "--" : str.tostring(x,"#.00")
color stateColor=confirmed==1 ? color.lime : confirmed==-1 ? color.red : confirmed==2 ? color.rgb(212,175,55) : color.gray
plot(closedGap,"Gap net / prior ATR",color=color.blue,linewidth=2)
plot(closedBody,"Body net / prior ATR",color=color.orange,linewidth=2)
plot(closedTotal,"Total net / prior ATR",color=stateColor,linewidth=2)
plot(closedShare,"Gap share (%)",display=display.data_window)
hline(0,"Zero",color=color.gray)
bgcolor(shade and initialized ? color.new(stateColor,90) : na)
var table panel=table.new(position.top_right,2,7,border_width=1)
if barstate.islast and showPanel
    table.cell(panel,0,0,"DAOL Move Origin",bgcolor=color.rgb(19,62,103),text_color=color.white)
    table.cell(panel,1,0,"CLOSED BAR",bgcolor=color.rgb(19,62,103),text_color=color.white)
    table.cell(panel,0,1,"Confirmed state")
    table.cell(panel,1,1,initialized ? f_state(confirmed) : "Building / confirming")
    table.cell(panel,0,2,"Latest raw state")
    table.cell(panel,1,2,closedReady ? f_state(closedRaw) : "Data unavailable")
    table.cell(panel,0,3,"Gap net / ATR")
    table.cell(panel,1,3,f_value(closedGap))
    table.cell(panel,0,4,"Body net / ATR")
    table.cell(panel,1,4,f_value(closedBody))
    table.cell(panel,0,5,"Total net / ATR")
    table.cell(panel,1,5,f_value(closedTotal))
    table.cell(panel,0,6,"Absolute Gap share")
    table.cell(panel,1,6,na(closedShare) ? "--" : f_value(closedShare)+"%")
alertcondition(changed and confirmed==1,"DAOL: Components up","[DAOL] Move Origin: Gap and Body confirmed up. {{ticker}} {{interval}}")
alertcondition(changed and confirmed==-1,"DAOL: Components down","[DAOL] Move Origin: Gap and Body confirmed down. {{ticker}} {{interval}}")
alertcondition(changed and confirmed==2,"DAOL: Components opposed","[DAOL] Move Origin: Gap and Body confirmed opposed. {{ticker}} {{interval}}")
alertcondition(changed and confirmed==0,"DAOL: Small or mixed","[DAOL] Move Origin: components small or mixed. {{ticker}} {{interval}}")
alertcondition(changed,"DAOL: Any confirmed change","[DAOL] Move Origin: confirmed state changed. {{ticker}} {{interval}}")
// GUIDE: gap=O-Cprev, body=C-O, gap+body=C-Cprev exactly per valid bar.
// N valid bars require N+1 closes. Sum price differences then normalize BOTH
// by same prior-bar ATR14; gapATR+bodyATR=totalATR. Units ATR, not returns.
// Gap share=sum(abs(gaps))/(sum(abs(gaps))+sum(abs(bodies)) *100.
// Uses absolute COMPONENT movement, not net contribution; no division by net.
// Zero total movement => share undefined. Invalid window/ATR => plots unavailable.
// Price constant but high-low range positive => net plots0, share--, neutral.
// ATR0 => unavailable, not neutral. No hidden missing-value imputation.
// Both components must exceed threshold magnitude for green/red/gold state.
// Zero-gap intraday feeds can stay gray despite directional Body movement.
// Gray is context, not proof of no trend. Gold is opposing components, not reversal.
// Lines show each close's metrics; color is confirmed state and may lag metrics.
// First confirmed state initializes silently; consecutive2 closes default.
// Alerts: Once Per Bar Close; recreate after changing inputs/code.
// No Volume, order flow, institution identification or buy/sell recommendation.
// Chart-bar gap is not necessarily overnight gap; Body is open-to-close change,
// not full intrabar path. On daily chart decomposition resembles overnight/daytime.
// On intraday chart it decomposes adjacent bars, without session labeling.
// Raw price differences handle nonpositive prices; not logarithmic paper returns.
// Splits/adjustments, futures rolls, missing bars and bad ticks can dominate gaps.
// All standard-chart TFs, bar-based windows; no assumption of equal elapsed time.
// Use real contract months for TFEX; no S50/GO performance claim.
// Established decomposition; extension is normalized component context, absolute
// share, classification and confirmation. No worldwide novelty claim.
// Study attribution: F. Wang, K. Yamasaki, S. Havlin, H. E. Stanley,
// Statistical analysis of the overnight and daytime return (2009), link above.
// Numerical identities checked; TV compilation/market validation pending.
// Private tests first; English-first self-contained publication and limitations.
// ไทย: เส้นน้ำเงินGap เส้นส้มBody เส้นTotalใช้สีสถานะยืนยัน ไม่ใช่โอกาสชนะ
// Gap/Body รวมย้อนหลัง20แท่งหารATRแท่งก่อนหน้า ใช้ราคาปิดเท่านั้น
// Gap Shareเป็นสัดส่วนระยะค่าสัมบูรณ์ ไม่ใช่สัดส่วนกำไรสุทธิ
// ตัวนี้ไม่ annualize และไม่วัดแรงซื้อขายจริง ต้องตรวจข้อมูลก่อนเผยแพร่
````
