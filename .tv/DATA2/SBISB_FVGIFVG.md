<!-- tradingview-pine-id: PUB;70826e2bb4f7405e980b300e38e05efa -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SB/ISB · FVG/IFVG

Source: https://www.tradingview.com/script/2EGpJHMX/

## Description

This script is a specialized indicator designed for **ICT (Inner Circle Trader)** and **Smart Money Concepts (SMC)**. Its primary focus is on automatically identifying, drawing, and managing **Fair Value Gaps (FVG)** and **Suspension Blocks (SB)**, as well as their **Inverted** counterparts.

Here is a detailed breakdown of what this indicator does and its main features:

**1. FVG & IFVG (Fair Value Gaps & Inversions)**

* **FVG (Fair Value Gap):** The script scans for traditional 3-bar imbalances. If it finds a Bullish FVG (default teal) or a Bearish FVG (default red), it draws a box projecting the zone forward.
* **IFVG (Inverted Fair Value Gap):** In ICT theory, when a Fair Value Gap fails to hold the price and gets decisively broken (price closes through it), it changes polarity. This script automatically detects when an FVG is violated, deletes the old FVG box, and creates a new **IFVG** box (default orange). A violated support FVG becomes a resistance IFVG, and vice versa.

**2. SB & ISB (Suspension Blocks & Inversions)**

* **SB (Suspension Block):** This is a specific price action pattern where a candle's body is completely "suspended" or isolated by gaps from the preceding and succeeding candles. The script calculates the tolerance and draws a box around this suspended body, projecting it as a zone of support or resistance.
* **Mean Threshold (Middle Line):** For every Suspension Block, the indicator automatically draws a line directly through the middle (50% level) of the block, which is a highly sensitive algorithmic level in SMC.
* **ISB (Inverted Suspension Block):** Just like the FVGs, if a Suspension Block is violated (price closes completely through it), the indicator flips it into an **ISB** (default orange). The old label changes from "+ suspension" to "+ISB", indicating the zone has flipped its polarity.

**3. Dynamic Chart Management (Mitigation)**
To prevent your chart from looking like a messy coloring book, the script has strict dynamic management rules:

* **Zone Deletion:** Once a zone (FVG, IFVG, SB, or ISB) is fully mitigated or invalidated by price action according to the script's rules, it stops drawing the box.
* **History Limits:** You can define exactly how many active FVGs, IFVGs, SBs, and ISBs you want to keep on the screen at a time (e.g., maximum 5 FVGs and 3 ISBs). Older zones are automatically deleted as new ones form.

**4. Customization & Visuals**

* **Labels:** Automatically tags the blocks on your chart (e.g., "+ suspension" or "-ISB") so you know exactly what zone you are looking at.
* **Tolerances:** You can adjust the "Tolerance %" for how strict the script should be when identifying the gaps for Suspension Blocks.
* **Aesthetics:** Full control over colors, box transparencies, and the style of the middle line (Solid, Dashed, Dotted).

**In summary:** This is a dynamic supply/demand and imbalance tracker. Instead of manually drawing FVGs and Order Blocks and adjusting them when they break, this indicator automates the entire lifecycle of these zones—drawing them when they form, inverting them when they fail, and deleting them when they are no longer relevant to the current price action.

---

## Source Code

````pine
//@version=6
indicator("SB/ISB · FVG/IFVG",overlay=true,max_bars_back=500,max_boxes_count=500,max_lines_count=500,max_labels_count=500)
W=color.new(color.white,100),bc=input.color(color.new(color.teal,0),"Bull",inline="f",group="FVG"),rc=input.color(color.new(color.red,0),"Bear",inline="f",group="FVG"),ft=input.int(80,"T",0,100,inline="f",group="FVG"),mf=input.int(5,"M",1,100,inline="f",group="FVG"),fsi=input.bool(true,"IFVG",inline="g",group="IFVG"),fic=input.color(color.new(color.orange,0),"C",inline="g",group="IFVG"),fit=input.int(85,"T",0,100,inline="g",group="IFVG"),fmi=input.int(5,"M",1,100,inline="g",group="IFVG")
g="SB / ISB",son=input.bool(true,"Show SB",inline="a",group=g),slb=input.bool(true,"Labels",inline="a",group=g),sbc=input.color(color.new(color.blue,0),"Bull",inline="a",group=g),src=input.color(color.new(color.red,0),"Bear",inline="a",group=g),sbt=input.int(85,"Transp",0,100,inline="b",group=g),tol=input.float(0.0,"Tol VI%",0.0,0.5,0.05,inline="b",group=g)/100,mss=input.int(5,"Max SB",1,50,inline="b",group=g),swn=input.int(2,"Janela VI",2,10,inline="b",group=g),ion=input.bool(true,"Show ISB",inline="c",group=g),sic=input.color(color.new(color.orange,0),"Color",inline="c",group=g),sit=input.int(85,"Transp",0,100,inline="c",group=g),sim=input.int(3,"Max ISB",1,50,inline="c",group=g),smw=input.bool(true,"Linha do Meio",inline="d",group=g),smn=input.string("----","",inline="d",options=["⎯⎯⎯","----","····"],group=g),sms=smn=="⎯⎯⎯"?line.style_solid:smn=="····"?line.style_dotted:line.style_dashed
var box[]fb=array.new_box(),var float[]fT=array.new_float(),var float[]fB=array.new_float(),var bool[]fU=array.new_bool(),var box[]ib=array.new_box(),var float[]iT=array.new_float(),var float[]iB=array.new_float(),var bool[]iD=array.new_bool(),var int[]fI=array.new_int(),var box[]sx=array.new_box(),var line[]sl=array.new_line(),var bool[]si=array.new_bool(),var label[]sa=array.new_label(),var box[]ix=array.new_box(),var line[]il=array.new_line(),var bool[]ii=array.new_bool(),var label[]ia=array.new_label(),var bool[]id=array.new_bool(),var int ls=na
ct(i)=>math.max(open[i],close[i])
cb(i)=>math.min(open[i],close[i])
fr(i)=>box.delete(array.get(fb,i)),array.remove(fb,i),array.remove(fT,i),array.remove(fB,i),array.remove(fI,i),array.remove(fU,i)
ir(i)=>box.delete(array.get(ib,i)),array.remove(ib,i),array.remove(iT,i),array.remove(iB,i),array.remove(iD,i)
bu=barstate.isconfirmed or barstate.ishistory?low>high[2]?1:high<low[2]?-1:0:0
if bu!=0
    tp=bu>0?low:low[2],bt=bu>0?high[2]:high
    while array.size(fb)>=mf
        fr(0)
    array.push(fb,box.new(bar_index-2,tp,bar_index,bt,bgcolor=color.new(bu>0?bc:rc,ft),border_color=W,border_width=0)),array.push(fT,tp),array.push(fB,bt),array.push(fI,int(time[2])),array.push(fU,bu>0)
i=0
while i<array.size(fb)
    u=array.get(fU,i),tp=array.get(fT,i),bt=array.get(fB,i),bx=array.get(fb,i)
    if u?math.min(open,close)<bt:math.max(open,close)>tp
        t0=array.get(fI,i)
        box.delete(bx),array.remove(fb,i),array.remove(fT,i),array.remove(fB,i),array.remove(fI,i),array.remove(fU,i)
        if fsi
            while array.size(ib)>=fmi
                ir(0)
            array.push(ib,box.new(t0,tp,int(time),bt,bgcolor=color.new(fic,fit),border_color=W,border_width=0,xloc=xloc.bar_time)),array.push(iT,tp),array.push(iB,bt),array.push(iD,false)
    else
        box.set_right(bx,bar_index),i+=1
if fsi
    i=0
    while i<array.size(ib)
        if not array.get(iD,i)
            box.set_right(array.get(ib,i),int(time))
            if math.min(open,close)>array.get(iT,i)or math.max(open,close)<array.get(iB,i)
                array.set(iD,i,true)
        i+=1
ss=ct(1)-cb(1),vr=false,vl=false
for k=2 to swn
    if cb(k)>ct(1)-ss*tol
        vr:=true
    if ct(k)<cb(1)+ss*tol
        vl:=true
bsb=vl and cb(0)>ct(1)-ss*tol and close[1]>=open[1],brb=vr and ct(0)<cb(1)+ss*tol and close[1]<open[1]
if son and(bsb or brb)
    if na(ls)or ls!=bar_index[1]
        ls:=bar_index[1]
        st=ct(1),sb=cb(1),md=(st+sb)/2,cl=bsb?sbc:src
        b=box.new(bar_index-1,st,bar_index,sb,bgcolor=color.new(cl,sbt),border_color=W),m=line.new(bar_index-1,md,bar_index,md,color=smw?color.new(cl,0):color.new(cl,100),style=sms,width=1),lb=slb?label.new(bar_index,md+(st-md)*0.5,bsb?"+ suspension":"- suspension",color=W,textcolor=color.new(cl,0),style=label.style_label_left,size=size.tiny):na
        array.push(sx,b),array.push(sl,m),array.push(si,bsb),array.push(sa,lb)
        if array.size(sx)>mss
            ob=array.shift(sx),om=array.shift(sl),ol=array.shift(sa),array.shift(si)
            box.delete(ob),line.delete(om)
            if not na(ol)
                label.delete(ol)
if son and array.size(sx)>0
    i=0
    while i<array.size(sx)
        b=array.get(sx,i),m=array.get(sl,i),bl=array.get(si,i),lb=array.get(sa,i),bt=box.get_top(b),bb=box.get_bottom(b)
        box.set_right(b,bar_index),line.set_x2(m,bar_index)
        if not na(lb)
            label.set_x(lb,bar_index)
        if bl?close<bb:close>bt
            if ion
                box.set_bgcolor(b,color.new(sic,sit)),box.set_border_color(b,W),line.set_color(m,smw?color.new(sic,0):color.new(sic,100)),line.set_style(m,sms)
                if not na(lb)
                    label.delete(lb)
                im=(bt+bb)/2,nl=slb?label.new(bar_index,im+(bt-im)*0.5,bl?"+ISB":"-ISB",color=W,textcolor=color.new(sic,0),style=label.style_label_left,size=size.tiny):na
                array.push(ix,b),array.push(il,m),array.push(ii,bl),array.push(ia,nl),array.push(id,false)
                if array.size(ix)>sim
                    ob=array.shift(ix),om=array.shift(il),ol=array.shift(ia)
                    array.shift(ii),array.shift(id)
                    box.delete(ob),line.delete(om)
                    if not na(ol)
                        label.delete(ol)
            else
                box.delete(b),line.delete(m)
                if not na(lb)
                    label.delete(lb)
            array.remove(sx,i),array.remove(sl,i),array.remove(si,i),array.remove(sa,i)
        else
            i+=1
if ion and array.size(ix)>0
    j=0
    while j<array.size(ix)
        if not array.get(id,j)
            b2=array.get(ix,j),m2=array.get(il,j),l2=array.get(ia,j),it=box.get_top(b2),ib2=box.get_bottom(b2)
            box.set_right(b2,bar_index),line.set_x2(m2,bar_index)
            if not na(l2)
                label.set_x(l2,bar_index)
            if close>it or close<ib2
                array.set(id,j,true)
        j+=1
````
