# [DAOL] Compression Release Strategy

- url: https://www.tradingview.com/script/YpX17vOI-DAOL-Compression-Release-Strategy/
- type: strategy
- pine_id: PUB;fd101239884d4f16bb15d7b92acdc58c
- version: 1.0

## Description

⏺️ What is it?

[DAOL] Compression Release Strategy tests directional price movement after a period of low relative volatility.

It combines Bollinger BandWidth, a frozen high–low range, consecutive breakout confirmation, and ATR-based risk levels.

🔹 Compression — BandWidth below a historical percentile
🔹 Frozen Range — price boundaries captured when compression is confirmed
🔹 Release — two consecutive closes beyond the same boundary
🔹 Risk Management — fixed stop, R-based target, and a range-return exit

This is an experimental backtesting strategy. It does not guarantee profitability or a particular win rate.

⏺️ กลยุทธ์นี้คืออะไร?

[DAOL] Compression Release Strategy เป็นกลยุทธ์สำหรับทดสอบการเคลื่อนที่ตามทิศทาง หลังราคามีความผันผวนต่ำเมื่อเทียบกับประวัติ

ผสม Bollinger BandWidth กรอบราคาที่ตรึงไว้ การยืนยัน Breakout ต่อเนื่อง และระดับความเสี่ยงที่อ้างอิง ATR

🔹 Compression — ความกว้าง BB ต่ำกว่าเกณฑ์จากประวัติ
🔹 Frozen Range — กรอบราคาที่ตรึงเมื่อยืนยันการบีบตัว
🔹 Release — ราคาปิดนอกขอบเดียวกันสองแท่งต่อเนื่อง
🔹 Risk Management — Stop คงที่ เป้าหมายแบบ R และการออกเมื่อกลับข้ามขอบกรอบ

เป็นกลยุทธ์ทดลองสำหรับ Backtest ไม่รับประกันกำไรหรือ Win Rate

⏺️ How does it work?

Calculate Bollinger Bands using 20 bars and 2 standard deviations.

Compare current BandWidth with the 20th percentile of the preceding 100 BandWidth observations, excluding the current observation.

Require BandWidth to remain below that threshold for 3 consecutive closed bars.

Freeze the highest high and lowest low of the latest 10 bars, including the confirmation bar.

Wait for a close outside the frozen range.

Require the immediately following bar to close beyond the same boundary.

Reject the entry if the confirming close is more than 0.5 frozen ATR beyond that boundary.

ATR 14 is captured when the range is frozen.

⏺️ ทำงานอย่างไร?

คำนวณ Bollinger Bands จาก 20 แท่ง และส่วนเบี่ยงเบนมาตรฐาน 2 เท่า

เทียบ BandWidth ปัจจุบันกับเปอร์เซ็นไทล์ที่ 20 ของค่า BandWidth 100 แท่งก่อนหน้า โดยไม่รวมค่าปัจจุบัน

ต้องต่ำกว่าเกณฑ์ต่อเนื่อง 3 แท่งปิด

ตรึงราคาสูงสุด–ต่ำสุดของ 10 แท่งล่าสุด รวมแท่งที่ยืนยันการบีบตัว

รอราคาปิดหลุดกรอบ

แท่งถัดมาต้องปิดนอกขอบเดิมในทิศทางเดียวกัน

ไม่เข้าเมื่อราคาปิดยืนยันห่างขอบเกิน 0.5 ATR ที่ตรึงไว้

ใช้ ATR 14 ณ แท่งที่ตรึงกรอบ และไม่เริ่มเข้าเทรดในแท่งที่สร้างกรอบ

⏺️ Entry and setup expiry

🔹 Long — two consecutive closes above the frozen upper boundary
🔹 Short — two consecutive closes below the frozen lower boundary
🔹 Entry — a limit order at the confirming close, valid for the next chart bar only
🔹 Setup lifetime — 10 bars after the range is armed by default

Both breakout closes must occur within the setup lifetime. Failed confirmation, excessive entry distance, or expiry consumes the setup.

A new setup requires compression to end and a fresh three-bar compression sequence to form. The strategy holds one position at a time and does not add to positions.

⏺️ การเข้าและอายุ Setup

🔹 Long — ปิดเหนือขอบบนที่ตรึงสองแท่งต่อเนื่อง
🔹 Short — ปิดใต้ขอบล่างที่ตรึงสองแท่งต่อเนื่อง
🔹 Entry — ส่ง Limit ที่ราคาปิดแท่งยืนยัน โดยมีอายุถึงสิ้นแท่งถัดไป
🔹 อายุ Setup — ค่าเริ่มต้น 10 แท่งหลังตรึงกรอบ

แท่ง Breakout และแท่งยืนยันต้องอยู่ภายในอายุ Setup หากยืนยันไม่สำเร็จ ราคาไกลเกินเกณฑ์ หรือหมดเวลา จะยกเลิก Setup นั้น

ต้องรอให้การบีบตัวสิ้นสุดแล้วเกิดการบีบตัวต่อเนื่องสามแท่งรอบใหม่ก่อนสร้าง Setup อีกครั้ง ถือครั้งละหนึ่งสถานะ ไม่เพิ่มไม้

เครื่องหมาย L/S แสดงการส่งคำสั่ง ไม่ได้ยืนยันว่าคำสั่งถูกจับคู่แล้ว หากราคาไม่กลับมาถึง Limit อาจไม่มีเทรดเกิดขึ้น

⏺️ Stop, target and exits

🔹 Long stop — 0.5 frozen ATR below the upper breakout boundary
🔹 Short stop — 0.5 frozen ATR above the lower breakout boundary
🔹 Target — 2R by default, calculated from the confirming close and fixed stop
🔹 Range-return exit — request a market close when price closes back to or across the breakout boundary

Stop and target prices are rounded to valid ticks and remain fixed.

Limit fills can differ from the confirming close, so actual entry reward-to-risk can differ from the planned ratio. Gaps and slippage can produce losses beyond the planned stop distance.

⏺️ Stop เป้าหมาย และการออก

🔹 Stop ของ Long — ต่ำกว่าขอบบนที่หลุด 0.5 ATR ที่ตรึงไว้
🔹 Stop ของ Short — สูงกว่าขอบล่างที่หลุด 0.5 ATR ที่ตรึงไว้
🔹 Target — ค่าเริ่มต้น 2R คำนวณจากราคาปิดยืนยันและ Stop
🔹 Range-return exit — ขอปิดด้วย Market Order เมื่อราคาปิดกลับถึงหรือข้ามขอบที่หลุด

ระดับ Stop/Target ปัดตาม Tick และคงที่ตลอดเทรด

ราคา Fill อาจต่างจากราคาปิดยืนยัน ทำให้ Reward-to-Risk จริงต่างจากที่วางแผนไว้ ส่วน Gap และ Slippage อาจทำให้ขาดทุนเกินระยะ Stop

Stop ทำงานทันที จึงยังเข้าและออกภายในแท่งเดียวกันได้ ไม่มี Trailing Stop, Time Exit หรือการปิดสิ้นวันอัตโนมัติ และอาจถือข้ามคืน

⏺️ Chart display and timeframes

🔹 Blue lines — frozen range boundaries
🔹 Red line — fixed stop
🔹 Green line — fixed target
🔹 L / S markers — entry-order submission bars
🔹 Dashboard — current strategy state and chart timeframe

The strategy does not restrict standard-chart timeframes. All calculations use bar counts, not fixed elapsed time.

For example, a 10-bar setup covers approximately 50 chart minutes on a 5-minute chart, but 10 trading days on a daily chart.

Timeframe compatibility does not imply validated performance on every timeframe. Use standard OHLC or candlestick charts.

⏺️ การแสดงผลและ Timeframe

🔹 เส้นน้ำเงิน — ขอบกรอบที่ตรึงไว้
🔹 เส้นแดง — Stop คงที่
🔹 เส้นเขียว — Target คงที่
🔹 เครื่องหมาย L / S — แท่งที่ส่งคำสั่งเข้า
🔹 Dashboard — สถานะกลยุทธ์และ Timeframe ของกราฟ

ไม่จำกัด Timeframe ของกราฟมาตรฐาน แต่สูตรทั้งหมดนับตาม จำนวนแท่ง ไม่ใช่ระยะเวลาคงที่

ตัวอย่าง Setup 10 แท่งครอบคลุมประมาณ 50 นาทีของแท่งกราฟ 5 นาที แต่ครอบคลุม 10 วันซื้อขายบนกราฟรายวัน เช่นเดียวกับ Limit ที่มีอายุหนึ่งแท่ง ซึ่งเปลี่ยนระยะเวลาตาม Timeframe

การรองรับ Timeframe ไม่ได้ยืนยันว่าผลดีทุกช่วงเวลา ใช้กราฟ OHLC หรือแท่งเทียนมาตรฐาน และต้องมีประวัติเพียงพอสำหรับการคำนวณ

⏺️ Settings and backtesting properties

User inputs:

🔹 Contracts — default 1
🔹 Target — default 2R
🔹 Setup lifetime — default 10 bars
🔹 Test start / end dates

Fixed calculation settings:

🔹 Bollinger Bands — 20 / 2
🔹 Historical percentile — 20th percentile of the preceding 100 observations
🔹 Compression confirmation — 3 closed bars
🔹 Frozen range — 10 bars
🔹 ATR — 14

Supplied Properties defaults:

🔹 Account currency — THB
🔹 Initial capital — THB 1,000,000
🔹 Commission — THB 50 per contract per fill
🔹 Slippage — 1 tick
🔹 Long / Short margin — 100% of notional value
🔹 Pyramiding, every-tick recalculation, after-fill recalculation and bar-close fills — disabled

These are test placeholders, not actual TFEX fees or margin requirements.

⏺️ ค่าตั้งและการทดสอบ

Input ที่ปรับได้:

🔹 จำนวนสัญญา — ค่าเริ่มต้น 1
🔹 Target — ค่าเริ่มต้น 2R
🔹 อายุ Setup — ค่าเริ่มต้น 10 แท่ง
🔹 วันเริ่มและสิ้นสุดการทดสอบ

ค่าคำนวณที่คงไว้:

🔹 Bollinger Bands — 20 / 2
🔹 เกณฑ์ประวัติ — เปอร์เซ็นไทล์ที่ 20 จาก 100 ค่าก่อนหน้า
🔹 ยืนยันการบีบตัว — 3 แท่งปิด
🔹 กรอบที่ตรึง — 10 แท่ง
🔹 ATR — 14

ค่าตัวอย่างใน Properties:

🔹 สกุลเงินบัญชี — THB
🔹 เงินทุนเริ่มต้น — 1,000,000 บาท
🔹 Commission — 50 บาทต่อสัญญาต่อครั้งที่จับคู่
🔹 Slippage — 1 Tick
🔹 Margin Long / Short — 100% ของมูลค่าสัญญา
🔹 ปิดการเพิ่มไม้ การคำนวณทุก Tick การคำนวณหลัง Fill และการจับคู่ที่แท่งปิด

ต้องปรับค่าต้นทุนและ Margin ให้เหมาะกับบัญชีจริงก่อนอ่านผล โดย Margin 100% อาจทำให้ไม่เกิดเทรดหากเงินทุนไม่เพียงพอ จำนวนสัญญาใช้ค่าจาก Input “Contracts”

⏺️ Development and references

This Pine Script v6 implementation was written for this project without copying Community script source.

The underlying Squeeze and ATR concepts are established methods. The implementation combines them with a frozen-range event model, setup expiry, consecutive breakout confirmation, a maximum entry-distance filter, and a range-return exit.

No claim is made that these underlying concepts are new, that no similar Community script exists, or that the strategy achieves a particular win rate.

References:

TradingView — Bollinger BandWidth
https://www.tradingview.com/support/solutions/43000501972-bollinger-bandwidth-bbw/

TradingView — Average True Range
https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/

TradingView — Pine Script Strategies
https://www.tradingview.com/pine-script-docs/concepts/strategies/

⏺️ การพัฒนาและอ้างอิง

เขียนด้วย Pine Script v6 สำหรับโครงการนี้ โดยไม่คัดลอกโค้ดจากสคริปต์ Community

Squeeze และ ATR เป็นหลักการที่มีอยู่แล้ว ส่วนการต่อยอดคือการตรึงกรอบ กำหนดอายุ Setup ยืนยัน Breakout ต่อเนื่อง จำกัดระยะไล่ราคา และออกเมื่อกลับข้ามขอบกรอบ

ไม่อ้างว่าแนวคิดพื้นฐานทั้งหมดใหม่ ไม่มีสคริปต์ใกล้เคียงใน Community หรือให้ Win Rate ตามเปอร์เซ็นต์ที่กำหนด

⏺️ Limitations and disclaimer

🔹 Low volatility does not guarantee a subsequent directional expansion.
🔹 Breakouts can reverse despite two-bar confirmation.
🔹 Limit orders can miss trades, and gap fills can invalidate planned reward-to-risk.
🔹 Results depend on timeframe, trading costs, data quality and contract-roll effects.
🔹 Orders or positions at the end of available history may remain unresolved.
🔹 Numerical logic checks have been completed; TradingView compilation and market-data backtesting remain pending.
🔹 This is a testing candidate. Complete validation before public publication.
🔹 For educational and informational purposes only. No investment advice or return guarantee is provided.

⏺️ ข้อจำกัดและคำชี้แจง

🔹 ความผันผวนต่ำไม่ได้รับประกันว่าจะเกิดการขยายตัวตามทิศทาง
🔹 Breakout อาจกลับตัวได้ แม้ยืนยันสองแท่งแล้ว
🔹 Limit อาจไม่ถูกจับคู่ และ Gap อาจทำให้ความเสี่ยงต่างจากแผน
🔹 ผลขึ้นกับ Timeframe ต้นทุน คุณภาพข้อมูล และรอยต่อสัญญา
🔹 คำสั่งหรือสถานะที่ปลายประวัติอาจยังไม่จบ หากไม่มี Tick ถัดไป
🔹 ตรวจตรรกะพื้นฐานแล้ว แต่ยังไม่ได้ Compile ใน TradingView หรือ Backtest ข้อมูลตลาดจริง
🔹 เป็นฉบับสำหรับทดสอบ ต้องตรวจสอบก่อนเผยแพร่ Public
🔹 ใช้เพื่อการศึกษา ไม่ใช่คำแนะนำการลงทุนหรือการรับประกันผลตอบแทน

## Source Code

````pine
//@version=6
// Revision 1.1: all standard-chart timeframes, bar-based calculation unchanged.
// Original experimental implementation. No Community code copied.
// BBWidth: https://www.tradingview.com/support/solutions/43000501972-bollinger-bandwidth-bbw/
// ATR: https://www.tradingview.com/support/solutions/43000501823-average-true-range-atr/
// Orders: https://www.tradingview.com/pine-script-docs/concepts/strategies/
strategy("[DAOL] Compression Release Strategy", overlay=true,pyramiding=0,
 initial_capital=1000000,currency=currency.THB,
 commission_type=strategy.commission.cash_per_contract,commission_value=50,
 slippage=1,margin_long=100,margin_short=100,calc_on_every_tick=false,
 calc_on_order_fills=false,process_orders_on_close=false,backtest_fill_limits_assumption=1,max_bars_back=500)
int qty=input.int(1,"Contracts",minval=1)
float targetR=input.float(2,"Target R",minval=0.5,step=0.1)
int lifetime=input.int(10,"Setup lifetime",minval=2,maxval=50)
int start=input.time(timestamp("01 Jan 2020 00:00 +0700"),"Test start")
int finish=input.time(timestamp("31 Dec 2099 00:00 +0700"),"Test end")
if barstate.isfirst
    if not chart.is_standard
        runtime.error("Use standard OHLC/candlestick charts.")
    if start>=finish
        runtime.error("Start must precede end.")
[basis,u,l]=ta.bb(close,20,2)
float bbw=basis!=0 ? 100*(u-l)/math.abs(basis) : na
float threshold=ta.percentile_linear_interpolation(bbw[1],100,20)
float atr=ta.atr(14)
float rh=ta.highest(high,10)
float rl=ta.lowest(low,10)
bool ready=bar_index>=120 and not na(threshold) and not na(atr) and atr>0
bool squeeze=ready and bbw<threshold
// On tick charts the realtime close timestamp can be unknown until bar closes.
// Decisions are confirmed-bar only; fall back to bar opening time if unavailable.
bool window=time>=start and (na(time_close) ? time<finish : time_close<finish)
var int streak=0
var bool fresh=true
var bool active=false
var int armedBar=na
var float top=na
var float bottom=na
var float frozenATR=na
var int direction=0
var int breakoutBar=na
var int submitted=na
var bool pending=false
var int heldDirection=0
var float stop=na
var float target=na
var string status="Building history"
bool buy=false
bool sell=false
bool closed=strategy.closedtrades>nz(strategy.closedtrades[1])
bool expiryBar=not na(submitted) and bar_index==submitted+1
if barstate.isconfirmed
    if not squeeze
        streak:=0
        fresh:=true
    else
        streak:=math.min(3,streak+1)
    if expiryBar
        pending:=false
        if strategy.position_size==0
            strategy.cancel_all()
            status:=closed ? "Trade completed" : "Unfilled limit expired"
    if not window
        active:=false
        streak:=0
        if strategy.position_size==0
            strategy.cancel_all()
        else
            strategy.close_all(comment="Test end")
        status:="Outside test window"
    else if strategy.position_size!=0
        active:=false
        bool returned=heldDirection==1 ? close<=top : close>=bottom
        if returned
            strategy.close_all(comment="Range return")
            status:="Range return exit requested"
        else
            status:="Holding release"
    else if not pending and not expiryBar and not closed and ready
        if active
            if bar_index-armedBar>lifetime
                active:=false
                direction:=0
                status:="Setup expired"
            else if direction==0
                if close>top or close<bottom
                    direction:=close>top ? 1 : -1
                    breakoutBar:=bar_index
                    status:="First breakout close"
            else if bar_index==breakoutBar+1
                float edge=direction==1 ? top : bottom
                float distance=direction*(close-edge)
                if distance>0 and distance<=0.5*frozenATR
                    stop:=direction==1 ? math.floor((edge-0.5*frozenATR)/syminfo.mintick)*syminfo.mintick : math.ceil((edge+0.5*frozenATR)/syminfo.mintick)*syminfo.mintick
                    float risk=direction*(close-stop)
                    float rawTarget=close+direction*risk*targetR
                    target:=direction==1 ? math.ceil(rawTarget/syminfo.mintick)*syminfo.mintick : math.floor(rawTarget/syminfo.mintick)*syminfo.mintick
                    heldDirection:=direction
                    submitted:=bar_index
                    pending:=true
                    if direction==1
                        strategy.entry("Long",strategy.long,qty=qty,limit=math.round_to_mintick(close),alert_message="Compression Long limit")
                        strategy.exit("Long bracket","Long",stop=stop,limit=target,comment_loss="Stop",comment_profit="Target")
                        buy:=true
                    else
                        strategy.entry("Short",strategy.short,qty=qty,limit=math.round_to_mintick(close),alert_message="Compression Short limit")
                        strategy.exit("Short bracket","Short",stop=stop,limit=target,comment_loss="Stop",comment_profit="Target")
                        sell:=true
                    status:="Limit submitted / valid next bar"
                else
                    status:="Canceled: no confirmation or chasing"
                active:=false
                direction:=0
        else if squeeze and streak>=3 and fresh and rh>rl
            top:=rh
            bottom:=rl
            frozenATR:=atr
            armedBar:=bar_index
            active:=true
            direction:=0
            fresh:=false
            status:="Frozen compression range"
plot(active or pending or strategy.position_size!=0 ? top : na,"Frozen high",color=color.blue,style=plot.style_linebr)
plot(active or pending or strategy.position_size!=0 ? bottom : na,"Frozen low",color=color.blue,style=plot.style_linebr)
plot(pending or strategy.position_size!=0 ? stop : na,"Fixed edge stop",color=color.red,style=plot.style_linebr)
plot(pending or strategy.position_size!=0 ? target : na,"Fixed target",color=color.green,style=plot.style_linebr)
plot(bbw,"BBWidth",display=display.data_window)
plot(threshold,"Prior100 percentile20",display=display.data_window)
plotshape(buy,title="Long submitted",style=shape.triangleup,location=location.belowbar,color=color.lime,text="L")
plotshape(sell,title="Short submitted",style=shape.triangledown,location=location.abovebar,color=color.red,text="S")
var table panel=table.new(position.top_right,1,3)
if barstate.islast
    table.cell(panel,0,0,"DAOL Compression Release",bgcolor=color.rgb(19,62,103),text_color=color.white)
    table.cell(panel,0,1,status)
    table.cell(panel,0,2,"Chart timeframe: " + timeframe.period + " / Calculation: bars")
// GUIDE: BB20/2 below percentile20 of PREVIOUS100 BBW for3 consecutive closes.
// Freeze high/low of10 bars including arm bar and ATR14 at arm. No arm-bar entry.
// First outside close followed by next close outside same edge; max0.5 frozenATR
// beyond edge. Both closes must occur within10 bars AFTER arm (deadline included).
// Failed confirmation/expiry consumes range. Need squeeze to end and fresh3-bar
// squeeze before another setup. No accumulation of setups while positioned.
// One limit entry at confirmation close, valid next complete bar only. May miss
// trades. Bracket Stop beyond frozen edge0.5ATR; Target2R from signal close.
// Fixed ABSOLUTE levels: better fill may improve R/R, gap through Stop may enter
// and immediately stop. Signals are submissions, not fills; no guaranteed R/R.
// Closed-bar return across breakout edge requests next-tick market exit while
// bracket remains live. No trailing, averaging, minimum holding or session exit.
// May hold overnight; intrabar stop/target, same-bar entry/exit possible.
// Any timeframe on standard charts: seconds/minutes/hours/days/weeks/months,
// and standard tick charts where available. No artificial chart types supported.
// All lengths remain BAR counts: BB20, reference100, range10, setup10, ATR14.
// Limit validity one bar can mean seconds, days or weeks depending on chart.
// Dates exclude bars closing at/after end; large bars may span date boundaries.
// Enough history required (at least121 bars); higher TFs may lack sample coverage.
// Timeframe compatibility is not performance validation. No HTF/future data.
// THB account/capital1m/commission50THB per contract per fill/slippage1tick/
// margin100% are TEST placeholders: set real Properties and verify pointvalue,
// currency (especially GO).100% margin can block trades for insufficient capital.
// Keep Every tick/After fill/Fill on close OFF. Qty input controls contracts.
// Last dataset bar may leave orders/trades unresolved. Dates do not load history.
// No profit or >60% win-rate claim. Numerical logic only; TV compile/backtest pending.
// Squeeze is established: extension is frozen setup, deadline, confirmation,
// max chase and range-return exit. No claim of worldwide uniqueness.
// Private tests first; English-first self-contained description, honest costs,
// sample size and limitations before public release; moderation not guaranteed.
// https://www.tradingview.com/support/solutions/43000590599/
// Educational simulation only, not investment advice/live order routing.
// ไทย: บีบตัว3แท่ง ตรึงกรอบ10แท่ง รอปิดหลุด2แท่ง แล้วLimitราคาแท่งยืนยัน
// Stopหลังขอบ0.5ATR เป้า2R คำสั่งอายุ1แท่ง อาจไม่ได้เข้า ราคากลับเข้ากรอบขอปิด
// ไม่บังคับถือขั้นต่ำ ตั้งต้นทุน/Marginตามจริง ยังไม่ยืนยันผลกำไรหรือWin Rate
````
