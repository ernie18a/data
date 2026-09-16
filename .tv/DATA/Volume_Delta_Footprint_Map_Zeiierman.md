<!-- tradingview-pine-id: PUB;8d6a2e08227c43f78ef5cbec0a074563 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Delta Footprint Map (Zeiierman)

Source: https://www.tradingview.com/script/7vcb6M4J-Volume-Delta-Footprint-Map-Zeiierman/

## Description

█ Overview
Volume Delta Footprint Map (Zeiierman) is a lower-timeframe volume delta mapping indicator that visualizes where buying and selling pressure develops across both price and time.

The indicator uses lower-timeframe data to estimate the buying and selling activity occurring inside each chart candle. This activity is then mapped across the price levels where it occurred, creating a detailed view of how volume delta develops around price.

The result is a dynamic footprint-style map built directly around price.
[image]https://www.tradingview.com/x/nYoAZkVg/[/image]
Positive Delta stripes highlight areas where estimated buying activity dominated, while Negative Delta stripes highlight areas where estimated selling activity dominated. Stronger concentrations appear with greater visual intensity, allowing important areas of directional participation to stand out immediately.
[image]https://www.tradingview.com/x/Y3KOdJMp/[/image]
█ How It Works
⚪ Lower-Timeframe Delta
The indicator analyzes lower-timeframe candles inside each chart candle to estimate directional volume delta.

Bullish candles contribute positive volume, while bearish candles contribute negative volume.
[pine]delta = direction × volume[/pine]
⚪ Price Stripe Mapping
The calculation range is divided into horizontal Price Stripes. Each lower-timeframe candle distributes its delta across the price levels it traded through, creating the footprint-style map around price.

⚪ Delta Persistence
Delta is carried forward using exponential decay, allowing strong buying or selling pressure to remain visible while older activity gradually fades.

⚪ Stripe Strength
Each stripe is ranked by its relative delta magnitude and directional dominance.
[pine]strength = relativeDelta × 0.70 + deltaDominance × 0.30[/pine]
Stronger concentrations appear more prominently, while weaker activity can be filtered using Minimum Stripe Strength.

⚪ Price Interaction
When enabled, sections of a stripe disappear once price trades through that level, making untouched delta areas easier to identify.
█ How to Use

⚪ Identify Buying Pressure
Strong Positive Delta stripes highlight price areas where lower-timeframe buying activity became dominant.

When several strong positive stripes develop around the same area, it can indicate concentrated bullish participation.

Monitor these areas for continuation, support, absorption, or renewed buying interest if price returns.
[image]https://www.tradingview.com/x/AYQOISk7/[/image]
⚪ Identify Selling Pressure
Strong Negative Delta stripes highlight areas where lower-timeframe selling activity became dominant.

Clusters of negative delta can reveal areas where sellers became particularly active and may help identify rejection, resistance, bearish continuation, or renewed selling pressure.
[image]https://www.tradingview.com/x/jivifMZ6/[/image]
⚪ Find Delta Concentrations
The strongest stripes are often more important than isolated weak readings.

A dense area containing several high-intensity stripes shows that directional activity repeatedly concentrated around a similar price region.

These areas can help traders identify where meaningful participation entered the market.
[image]https://www.tradingview.com/x/SBwA0nMf/[/image]
⚪ Find Trapped Buyers and Sellers

• Strong Positive Delta near a high followed by rejection can indicate buyers being absorbed by sellers. If price moves lower, those buyers may be forced to close their positions.

• Strong Negative Delta near a low followed by rejection can indicate sellers being absorbed by buyers. If price moves higher, those sellers may be forced to close their positions.

These areas can become especially important when the Delta concentration forms near key highs, lows, support, resistance, or liquidity zones.
[image]https://www.tradingview.com/x/4f7sVG2n/[/image]
⚪ Find Buyers and Sellers in Control

• Strong Negative Delta near a local swing high followed by continued downside can indicate sellers taking control and pushing price lower.

• Strong Positive Delta near a local swing low followed by continued upside can indicate buyers taking control and pushing price higher.

When price continues to move away from these areas, the Delta concentration can help confirm which side is controlling the move.
[image]https://www.tradingview.com/x/IOtGOoJQ/[/image]
█ Settings

[*]Automatic Lower Timeframe: Automatically selects an appropriate lower timeframe based on the active chart timeframe.
[*]Manual Lower Timeframe: Selects the lower timeframe used for delta calculations when automatic selection is disabled.
[*]Lookback Bars: Controls how many historical chart candles are included in the Delta Map.
[*]Price Stripes: Sets the number of horizontal price levels used to construct the map. More stripes provide greater price resolution.
[*]Delta Persistence: Controls how long accumulated buying or selling pressure remains active before gradually decaying.
[*]Minimum Stripe Strength: Filters weaker delta concentrations. Higher values display only stronger directional activity.
[*]Intensity Steps: Controls how many visual strength levels are used between weak and strong Delta stripes.
[*]Create Gap When Price Touches Stripe: Removes sections of a stripe where price has already traded through its corresponding price level.

█ Important

Volume Delta Footprint Map estimates directional volume from lower-timeframe candle behavior and available volume data.

It does not require TradingView’s Footprint data and does not represent exchange-level bid and ask transactions.

Instead, it provides a universal footprint-style visualization designed to reveal where directional volume pressure developed, how strong that pressure was, and how its influence evolved across price and time.

-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
//@version=6
indicator("Volume Delta Footprint Map (Zeiierman)", overlay=true, behind_chart=false, max_boxes_count=500, max_bars_back=5000, dynamic_requests=true)

// ~~ Tooltips {
t1="Automatically selects an appropriate lower timeframe based on the active chart timeframe. Lower timeframe data is used to estimate volume delta inside each chart bar."
t2="Selects the lower timeframe used for the delta calculation when Automatic lower timeframe is disabled."
t3="Number of historical chart bars analyzed by the map. Higher values display a longer history of volume delta activity."
t4="Number of horizontal price levels used to distribute and display volume delta. More stripes provide finer price resolution."
t5="Controls how long accumulated delta remains active across the map. Higher values allow strong buying or selling pressure to persist for more bars."
t6="Minimum normalized delta strength required for a stripe to appear. Higher values filter weaker activity and display only stronger delta concentrations."
t7="Number of visual strength levels used to separate weak and strong delta. Higher values create finer changes in stripe intensity."
t8="Creates gaps in a delta stripe when price trades through its price level. Disable this to allow stripes to remain visible through price interaction."
t9="Color used for positive volume delta where estimated buying activity dominates selling activity."
t10="Color used for negative volume delta where estimated selling activity dominates buying activity."
t11="Controls the vertical thickness of each horizontal delta stripe relative to its price row."
t12="Controls the transparency of the weakest visible delta stripes. Higher values make weak activity less visible."
t13="Controls the transparency of the strongest visible delta stripes. Lower values make strong activity more prominent."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Groups {
gDat="1. LTF Data"
gMap="2. Map Structure"
gDel="3. Delta Behavior"
gSty="4. Colors & Style"
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
auto=input.bool(true,"Automatic lower timeframe",group=gDat,tooltip=t1)
tfIn=input.timeframe("1","Manual lower timeframe",group=gDat,tooltip=t2)

lb=input.int(120,"Lookback bars",minval=20,maxval=500,group=gMap,tooltip=t3)
rows=input.int(26,"Price stripes",minval=8,maxval=50,group=gMap,tooltip=t4)

life=input.int(12,"Delta persistence",minval=1,maxval=100,group=gDel,tooltip=t5)
minS=input.float(0.12,"Minimum stripe strength",minval=0.0,maxval=1.0,step=0.01,group=gDel,tooltip=t6)
steps=input.int(7,"Intensity steps",minval=2,maxval=20,group=gDel,tooltip=t7)
hide=input.bool(true,"Create gap when price touches stripe",group=gDel,tooltip=t8)

pos=input.color(color.rgb(0,220,165),"Positive delta",inline="col",group=gSty,tooltip=t9)
neg=input.color(color.rgb(255,70,78),"Negative delta",inline="col",group=gSty,tooltip=t10)
thick=input.float(0.18,"Stripe thickness",minval=0.03,maxval=0.80,step=0.01,group=gSty,tooltip=t11)
weakT=input.int(88,"Weak transparency",minval=50,maxval=99,inline="tr",group=gSty,tooltip=t12)
strongT=input.int(8,"Strong transparency",minval=0,maxval=50,inline="tr",group=gSty,tooltip=t13)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Helpers {
fit(x,lo,hi)=>math.max(lo,math.min(hi,x))
rowAt(p,lo,st,n)=>int(math.max(0,math.min(n-1,math.floor((p-lo)/st))))

autoTf()=>
    s=timeframe.in_seconds(timeframe.period)
    na(s)?"1":s<=60?timeframe.period:s<=900?"1":s<=3600?"5":s<=14400?"15":s<=86400?"60":s<=604800?"240":"D"
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ LTF Data {
tf=auto?autoTf():tfIn
[aO,aH,aL,aC,aV,aP]=request.security_lower_tf(syminfo.tickerid,tf,[open,high,low,close,nz(volume,0.0),close[1]],ignore_invalid_timeframe=true,calc_bars_count=lb+20)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ State {
var bx=array.new<box>()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Delta Map {
if barstate.islast

    // ~~ Clear {
    while bx.size()>0
        box.delete(bx.pop())
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    // ~~ Range {
    eff=math.min(lb,bar_index+1)
    cols=int(math.ceil(eff*1.0/1))
    old=bar_index-eff+1
    tick=math.max(syminfo.mintick,0.00000001)

    lo=low
    hi=high
    atrSum=0.0
    atrCnt=0

    for off=0 to eff-1
        lo:=math.min(lo,low[off])
        hi:=math.max(hi,high[off])
        av=nz(ta.atr(14)[off],high[off]-low[off])
        atrSum+=av
        atrCnt+=1

    atrAvg=atrCnt>0?atrSum/atrCnt:nz(ta.atr(14),high-low)
    padding=atrAvg*0.35

    lo-=padding
    hi+=padding

    rng=math.max(hi-lo,tick*rows)
    st=math.max(rng/rows,tick)
    hi:=lo+st*rows
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    // ~~ Storage {
    cells=cols*rows
    rd=array.new_float(cells,0.0)
    ra=array.new_float(cells,0.0)
    sd=array.new_float(cells,0.0)
    sa=array.new_float(cells,0.0)
    cm=array.new_float(cols,0.0)
    tm=array.new_bool(cells,false)

    ltfN=0
    fbN=0
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    // ~~ Raw Delta {
    for off=0 to eff-1
        cfr=int(math.floor(off*1.0/1))
        col=cols-1-cfr

        if col>=0 and col<cols
            oo=aO[off]
            hh=aH[off]
            ll=aL[off]
            cc=aC[off]
            vv=aV[off]
            pp=aP[off]

            n=na(cc)?0:cc.size()

            if n>0
                ltfN+=n

                for i=0 to n-1
                    o=oo.get(i)
                    h=hh.get(i)
                    l=ll.get(i)
                    c=cc.get(i)
                    v=vv.get(i)
                    pc=pp.get(i)

                    dir=c>o?1:c<o?-1:not na(pc) and c>pc?1:not na(pc) and c<pc?-1:0
                    w=v>0?v:1.0
                    d=dir*w

                    r0=rowAt(l,lo,st,rows)
                    r1=rowAt(h,lo,st,rows)
                    span=math.max(r1-r0+1,1)
                    part=1.0/span

                    for r=r0 to r1
                        id=col*rows+r
                        rd.set(id,rd.get(id)+d*part)
                        ra.set(id,ra.get(id)+w*part)

            else
                fbN+=1

                o=open[off]
                h=high[off]
                l=low[off]
                c=close[off]
                v=nz(volume[off],0.0)
                pc=close[off+1]

                dir=c>o?1:c<o?-1:not na(pc) and c>pc?1:not na(pc) and c<pc?-1:0
                w=v>0?v:1.0
                d=dir*w

                r0=rowAt(l,lo,st,rows)
                r1=rowAt(h,lo,st,rows)
                span=math.max(r1-r0+1,1)
                part=1.0/span

                for r=r0 to r1
                    id=col*rows+r
                    rd.set(id,rd.get(id)+d*part)
                    ra.set(id,ra.get(id)+w*part)
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    // ~~ Touch Map {
    if hide
        for off=0 to eff-1
            cfr=int(math.floor(off*1.0/1))
            col=cols-1-cfr

            if col>=0 and col<cols
                r0=rowAt(low[off],lo,st,rows)
                r1=rowAt(high[off],lo,st,rows)

                for r=r0 to r1
                    tm.set(col*rows+r,true)
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    // ~~ Persistence {
    decay=math.exp(math.log(0.5)/life)

    for r=0 to rows-1
        ds=0.0
        ac=0.0

        for col=0 to cols-1
            id=col*rows+r
            ds:=ds*decay+rd.get(id)
            ac:=ac*decay+ra.get(id)

            sd.set(id,ds)
            sa.set(id,ac)

            m=math.abs(ds)
            cm.set(col,math.max(cm.get(col),m))
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

    // ~~ Stripes {
    stripeH=st*thick

    for r=0 to rows-1
        lvl=lo+(r+0.5)*st
        run=-1
        sign=0
        bucket=-1

        for col=0 to cols-1
            id=col*rows+r
            d=sd.get(id)
            a=sa.get(id)
            mx=cm.get(col)

            mag=mx>0?math.abs(d)/mx:0.0
            dom=a>0?math.abs(d)/a:0.0
            strength=fit(mag*0.70+dom*0.30,0.0,1.0)

            touched=hide and tm.get(id)
            visible=a>0 and strength>=minS and not touched

            signNow=visible?(d>=0?1:-1):0
            bucketNow=visible?int(math.round(strength*(steps-1))):-1
            same=run>=0 and visible and signNow==sign and bucketNow==bucket

            if run>=0 and not same
                if bx.size()<490
                    left=old+run*1
                    right=math.min(old+col*1,bar_index+1)
                    qs=steps>1?bucket*1.0/(steps-1):1.0
                    tr=int(math.round(fit(weakT-(weakT-strongT)*qs,strongT,weakT)))
                    base=sign>0?pos:neg
                    bx.push(box.new(left=left,top=lvl+stripeH*0.5,right=right,bottom=lvl-stripeH*0.5,xloc=xloc.bar_index,bgcolor=color.new(base,tr),border_color=color.new(base,100)))

                run:=-1
                sign:=0
                bucket:=-1

            if visible and run<0
                run:=col
                sign:=signNow
                bucket:=bucketNow

        if run>=0 and bx.size()<490
            left=old+run*1
            right=math.min(old+cols*1,bar_index+1)
            qs=steps>1?bucket*1.0/(steps-1):1.0
            tr=int(math.round(fit(weakT-(weakT-strongT)*qs,strongT,weakT)))
            base=sign>0?pos:neg
            bx.push(box.new(left=left,top=lvl+stripeH*0.5,right=right,bottom=lvl-stripeH*0.5,xloc=xloc.bar_index,bgcolor=color.new(base,tr),border_color=color.new(base,100)))
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
