<!-- tradingview-pine-id: PUB;c2c920bc891641f1a4fd98374f7a0a9f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Market Commitment & Failure Engine

Source: https://www.tradingview.com/script/E4JOyZuX-Adaptive-Market-Commitment-Failure-Engine/

## Description

OVERVIEW

Adaptive Market Commitment & Failure Engine is a state-based market analysis framework designed to evaluate whether directional price behavior is developing into persistent commitment or beginning to lose internal efficiency.

Instead of treating individual momentum, volatility, volume, or displacement readings as standalone signals, the engine evaluates how multiple forms of market evidence interact through a structured lifecycle.

The central analytical question is:

Is directional movement being supported by persistent market commitment, or is the move beginning to consume effort without producing proportional structural progress?

CORE METHODOLOGY

The engine organizes market behavior through the following analytical sequence:

Impulse Initiation → Commitment Build → Evidence Agreement → Sustained State → Stress → Release / Failure → Residual Memory

Its assessment is built around four primary evidence dimensions:

Effort
Evaluates normalized range expansion, body participation, directional pressure, wick behavior, and relative participation where volume data is available.

Result
Evaluates displacement efficiency, closing behavior, follow-through, and structural progress produced by the observed effort.

Commitment
Measures persistent agreement between effort and result across multiple analytical horizons. Commitment is treated as a developing market state rather than a single-bar measurement.

Stress
Identifies deterioration inside an existing commitment episode when effort remains meaningful while result, follow-through, or structural progress begins to weaken.

Stress is an OHLCV-derived behavioral classification and should not be interpreted as direct order-flow absorption.

COMMITMENT LIFECYCLE

Directional episodes progress through a confirmed state framework:

DORMANT → EMERGING → CONFIRMED → ESTABLISHED → MATURE → STRESSED → RELEASED / FAILED

Developing evidence and confirmed states are intentionally separated.

State transitions are evaluated on confirmed bars, while separate entry, persistence, and release conditions help reduce rapid state switching around classification boundaries.

Released does not automatically mean reversal.

Failed and Released represent different lifecycle outcomes and should be interpreted within surrounding market structure.

EFFORT–RESULT CONTEXT

The engine also interprets the relationship between observed effort and resulting price progress.

Typical environments can include:

High Effort + Strong Result — committed expansion
High Effort + Weak Result — stress or reduced efficiency
Low Effort + Strong Result — efficient or thin expansion
Low Effort + Weak Result — limited commitment

These classifications describe observed market behavior. They are not trade signals or forecasts.

COMMITMENT CORRIDORS

The primary visual structure is the Commitment Corridor.

Corridors represent spatial areas associated with qualified commitment episodes and can evolve through stages such as:

Created → Developing → Reinforced → Mature → Tested → Weakened → Failed → Decayed

Visual intensity reflects the current relevance of the underlying episode, while older or weakened structures are progressively subdued to maintain chart readability.

STRUCTURAL MEMORY

Qualified commitment episodes can leave residual structural memory after their active lifecycle ends.

When price later interacts with these areas, the engine can evaluate whether the surviving structure remains relevant, becomes reinforced, weakens, or eventually loses significance.

The number of retained structures is intentionally bounded to prevent unlimited historical objects from accumulating on the chart.

DASHBOARD

The dashboard provides a compact summary of the engine's current assessment:

STATE — current lifecycle classification
DIRECTION — directional orientation of the active evidence
COMMITMENT — persistence and agreement of directional evidence
EFFORT — current behavioral effort classification
RESULT — efficiency of resulting price progress
MATURITY — development stage of the current episode
STRESS — internal deterioration assessment
MEMORY — number of retained active structural memories

HOW TO USE

The engine is designed primarily as a contextual analysis tool.

It can be used to study:

Whether a directional move is still developing or has achieved persistent commitment
Whether an established episode is strengthening, maturing, or deteriorating
Whether observed effort is producing proportional price progress
How previously resolved commitment episodes remain relevant when price revisits their locations

The classifications are most useful when interpreted together with broader price structure and the user's own analytical framework.

CONFIRMATION AND LIMITATIONS

Lifecycle transitions are evaluated using confirmed-bar information.

The engine operates from chart-derived price and available volume data. It does not have access to exchange order books, hidden liquidity, institutional positioning, or other information unavailable in the chart data feed.

Volume characteristics can also differ between instruments and data providers.

Commitment, Effort, Result, Stress, Maturity, and Memory are analytical classifications derived from observed market behavior. They are not probabilities, order-flow measurements, guarantees, trading signals, or forecasts of future performance.

No single state should be interpreted as an instruction to enter or exit a position.

ORIGINALITY

Adaptive Market Commitment & Failure Engine is an independently developed state-based framework designed around the lifecycle of directional market commitment.

Its primary purpose is not simply to measure momentum, effort, or price response independently. Instead, it evaluates whether directional evidence develops into a persistent episode, how that episode matures or comes under stress, how it resolves, and what structural context can remain afterward.

The combination of confirmed lifecycle classification, multi-horizon evidence agreement, commitment corridors, episode maturity, stress assessment, and bounded residual structural memory forms the core analytical framework of the indicator.

Release Notes — v1.0

Initial release

Introduces:

Multi-horizon commitment assessment
Effort and result classification
Confirmed commitment lifecycle
Emerging, Confirmed, Established, Mature, Stressed, Released and Failed states
Commitment Corridor visualization
Episode maturity tracking
Internal stress assessment
Residual structural memory
Controlled memory decay and retirement
Compact market-state dashboard
Confirmed-bar lifecycle transitions
Configurable lifecycle and visual controls

---

## Source Code

````pine
//@version=6
indicator("Adaptive Market Commitment & Failure Engine", shorttitle="Commitment Engine", overlay=true, max_boxes_count=100, max_labels_count=100)

// v1.0 RC7 FINAL PRESENTATION QA
// Normalized scores are analytical evidence, not probabilities.

atrLen=input.int(14,"ATR Length",minval=5,group="Core")
volLen=input.int(20,"Volume Baseline",minval=5,group="Core")
fastLen=input.int(5,"Fast Evidence",minval=2,group="Core")
structLen=input.int(13,"Structural Evidence",minval=5,group="Core")
slowLen=input.int(34,"Slow Evidence",minval=10,group="Core")
swingLen=input.int(10,"Structural Lookback",minval=3,group="Core")

emergeTh=input.float(.42,"Emerging Threshold",step=.01,group="Lifecycle")
confirmTh=input.float(.52,"Confirmed Threshold",step=.01,group="Lifecycle")
establishTh=input.float(.60,"Established Threshold",step=.01,group="Lifecycle")
holdTh=input.float(.44,"Hold Threshold",step=.01,group="Lifecycle")
releaseTh=input.float(.34,"Release Threshold",step=.01,group="Lifecycle")
stressTh=input.float(.58,"Stress Threshold",step=.01,group="Lifecycle")
confirmBars=input.int(2,"Persistence Bars",minval=1,maxval=6,group="Lifecycle")
establishAge=input.int(5,"Minimum Confirmed Age",minval=2,maxval=15,group="Lifecycle")
releaseBars=input.int(3,"Release Persistence Bars",minval=2,maxval=8,group="Lifecycle")

showCorridors=input.bool(true,"Show Commitment Corridors",group="Memory")
maxMem=input.int(7,"Maximum Memories",minval=2,maxval=15,group="Memory")
corridorATR=input.float(.55,"Corridor Width (ATR)",step=.05,group="Memory")
decayRate=input.float(.004,"Memory Decay / Bar",step=.0005,group="Memory")
testDamage=input.float(.08,"Test Damage",step=.01,group="Memory")
reinforceAmt=input.float(.04,"Reinforcement",step=.01,group="Memory")

showBars=input.bool(true,"Commitment Candle Tint",group="Visuals")
showEvents=input.bool(true,"Major Lifecycle Labels",group="Visuals")
showConfirmed=input.bool(false,"Show Confirmed Markers",group="Visuals")
eventCooldown=input.int(8,"Event Cooldown Bars",minval=1,maxval=50,group="Visuals")
showReleaseLabels=input.bool(true,"Show Significant Release Labels",group="Visuals")
releaseMinAge=input.int(6,"Release Label Minimum Episode Age",minval=2,maxval=50,group="Visuals")
showDash=input.bool(true,"Dashboard",group="Visuals")
advanced=input.bool(false,"Numerical Evidence",group="Visuals")

clamp(float x)=>math.max(0.,math.min(1.,x))
safe(float a,float b)=>b==0.?0.:a/b
norm(float x)=>
    z=math.max(x,0.)
    z2=z*z
    clamp(z*(27.+z2)/(27.+9.*z2))
sgn(float x)=>x>0?1:x<0?-1:0
fmt(float x)=>str.tostring(x,"#.00")

atr=ta.atr(atrLen)
a=math.max(atr,syminfo.mintick)
rng=math.max(high-low,syminfo.mintick)
body=close-open
bodyEff=math.abs(body)/rng
clBull=(close-low)/rng
clBear=(high-close)/rng
wu=high-math.max(open,close)
wd=math.min(open,close)-low
wickBias=clamp(.5+.5*safe(wd-wu,rng))

vb=ta.ema(volume,volLen)
hasVol=not na(volume) and not na(vb) and vb>0
rv=hasVol?volume/vb:1.

dirRaw=body/a
dir=sgn(ta.ema(dirRaw,fastLen))

// EFFORT
eRange=norm((ta.tr(true)/a)/1.25)
eVol=hasVol?norm(rv/1.35):.50
eBody=clamp(bodyEff)
pBull=clamp(.55*clBull+.25*clamp(.5+body/(2*rng))+.20*wickBias)
pBear=clamp(.55*clBear+.25*clamp(.5-body/(2*rng))+.20*(1-wickBias))
ePressure=dir>=0?pBull:pBear
effort=clamp(.30*eRange+.25*eVol+.20*eBody+.25*ePressure)

// RESULT
rDisp=norm((math.abs(close-close[1])/a)/.85)
rClose=dir>=0?clBull:clBear
m0=close-close[1]
m1=close[1]-close[2]
agree=sgn(m0)==sgn(m1) and sgn(m0)==dir?1.:0.
twoProg=dir>0?(close-close[2])/a:dir<0?(close[2]-close)/a:0.
rFollow=clamp(.45*agree+.55*norm(twoProg/1.25))
prevHH=ta.highest(high[1],swingLen)
prevLL=ta.lowest(low[1],swingLen)
upProg=math.max(close-prevHH,0.)/a
dnProg=math.max(prevLL-close,0.)/a
rStruct=dir>0?norm(upProg/.60):dir<0?norm(dnProg/.60):0.
lh=ta.highest(high,swingLen)
ll=ta.lowest(low,swingLen)
lp=(close-ll)/math.max(lh-ll,syminfo.mintick)
rStruct:=math.max(rStruct,dir>0?clamp((lp-.5)*1.4):dir<0?clamp((.5-lp)*1.4):0.)
result=clamp(.30*rDisp+.20*rClose+.25*rFollow+.25*rStruct)

// COMMITMENT: persistent multi-horizon agreement
base=clamp(math.sqrt(math.max(effort*result,0.)))
signed=base*float(dir)
cf=ta.ema(signed,fastLen)
cm=ta.ema(signed,structLen)
cs=ta.ema(signed,slowLen)
fs=sgn(cf)!=0 and sgn(cf)==sgn(cm)
ss=sgn(cm)!=0 and sgn(cm)==sgn(cs)
ha=fs and ss?1.:fs?.72:.42
mag=clamp(.45*math.abs(cf)+.35*math.abs(cm)+.20*math.abs(cs))
pers=clamp(.55*math.abs(cm)+.45*math.abs(cs))
// Commitment keeps magnitude central while agreement/persistence act as
// quality modifiers. This avoids suppressing persistent directional episodes.
commit=clamp(mag*(.72+.28*ha)+.18*pers)
cdir=sgn(.50*cf+.35*cm+.15*cs)

// STRESS: effort persists while result deteriorates
ep=ta.ema(effort,structLen)
rp=ta.ema(result,structLen)
rs=rp-rp[3]
aw=cdir>0?clamp(wu/rng):cdir<0?clamp(wd/rng):0.
stress=clamp(.45*clamp(ep-rp)+.30*clamp(-rs*4)+.25*aw)

// State IDs
DORMANT=0
EMERGING=1
CONFIRMED=2
ESTABLISHED=3
MATURE=4
STRESSED=5
RELEASED=6
FAILED=7

sname(int s)=>s==DORMANT?"DORMANT":s==EMERGING?"EMERGING":s==CONFIRMED?"CONFIRMED":s==ESTABLISHED?"ESTABLISHED":s==MATURE?"MATURE":s==STRESSED?"STRESSED":s==RELEASED?"RELEASED":"FAILED"
dname(int d)=>d>0?"UPPER":d<0?"LOWER":"NEUTRAL"
qname(float x)=>x>=.72?"STRONG":x>=.52?"MODERATE":"LIGHT"
ename(float x)=>x>=.68?"ELEVATED":x<=.40?"LIGHT":"NORMAL"
rname(float x)=>x>=.68?"EFFICIENT":x<=.40?"WEAK":"MIXED"
xname(float x)=>x>=stressTh?"HIGH":x>=stressTh*.65?"BUILDING":"LOW"
mname(int x)=>x>=34?"AGED":x>=21?"MATURE":x>=8?"DEVELOPING":"EARLY"

var state=DORMANT
var stateDir=0
var age=0
var pc=0
var wc=0
var peak=0.
var confirmedAge=0
var episodeEstablished=false
var int startBar = na
var float origin = na
var float originATR = na

var memBoxes=array.new_box()
var memDirs=array.new_int()
var memStrength=array.new_float()
var memFailed=array.new_bool()

addMemory(int d,int left,float o,float width,float strength)=>
    if showCorridors and d!=0 and not na(o)
        top=d>0?o+width*.35:o+width
        bot=d>0?o-width:o-width*.35
        col=d>0?color.teal:color.fuchsia
        bx=box.new(left,top,bar_index,bot,xloc=xloc.bar_index,extend=extend.right,border_color=color.new(col,45),bgcolor=color.new(col,90))
        array.push(memBoxes,bx),array.push(memDirs,d),array.push(memStrength,clamp(strength)),array.push(memFailed,false)
        if array.size(memBoxes)>maxMem
            box.delete(array.shift(memBoxes)),array.shift(memDirs),array.shift(memStrength),array.shift(memFailed)

// Interactive memory: decay, test damage, reinforcement, failure
if barstate.isconfirmed and array.size(memBoxes)>0
    for i=array.size(memBoxes)-1 to 0
        bx=array.get(memBoxes,i)
        md=array.get(memDirs,i)
        ms=array.get(memStrength,i)
        mf=array.get(memFailed,i)
        top=box.get_top(bx),bot=box.get_bottom(bx)
        touched=high>=bot and low<=top
        supportive=md>0?close>top:close<bot
        violated=md>0?close<bot:close>top
        ms*=math.exp(-decayRate)
        if touched
            ms-=testDamage
        if touched and supportive
            ms+=reinforceAmt
        if violated
            ms-=testDamage*2,mf:=true
        ms:=clamp(ms)
        array.set(memStrength,i,ms),array.set(memFailed,i,mf)
        col=md>0?color.teal:color.fuchsia
        alpha=int(math.round(94-ms*30))
        // Historical memories stay subordinate to the current hero episode.
        histAlpha=ms>=.60?82:ms>=.35?88:94
        box.set_bgcolor(bx,color.new(mf?color.gray:col,histAlpha))
        box.set_border_color(bx,color.new(mf?color.gray:col,mf?90:ms>=.60?58:76))
        if ms<.08
            box.delete(bx),array.remove(memBoxes,i),array.remove(memDirs,i),array.remove(memStrength,i),array.remove(memFailed,i)

prevState=state
prevDir=stateDir
prevEpisodeAge=age
prevEpisodePeak=peak
prevEpisodeEstablished=episodeEstablished
if barstate.isconfirmed
    same=cdir!=0 and (stateDir==0 or cdir==stateDir)
    pc:=commit>=emergeTh and cdir!=0?(same?pc+1:1):0

    // Weakness must persist. A temporary soft bar does not terminate an episode.
    wc:=commit<holdTh?wc+1:math.max(wc-1,0)

    if state==DORMANT or state==RELEASED or state==FAILED
        age:=0
        confirmedAge:=0
        episodeEstablished:=false
        if commit>=emergeTh and cdir!=0
            state:=EMERGING
            stateDir:=cdir
            startBar:=bar_index
            origin:=close
            originATR:=a
            peak:=commit
    else
        age+=1
        peak:=math.max(peak,commit)

        if state==CONFIRMED or state==ESTABLISHED or state==MATURE or state==STRESSED
            confirmedAge+=1

        contradiction=cdir!=0 and cdir!=stateDir and commit>=confirmTh

        // Failure requires a meaningful opposite commitment, not a single contrary candle.
        if contradiction and pc>=confirmBars
            state:=FAILED

        // Release requires sustained weakness and is intentionally harder than Hold.
        else if wc>=releaseBars and commit<releaseTh
            state:=RELEASED

        // Stress is only valid after an established episode exists.
        else if episodeEstablished and stress>=stressTh
            state:=STRESSED

        // Maturity combines age with surviving commitment.
        else if episodeEstablished and confirmedAge>=21 and commit>=holdTh
            state:=MATURE

        // Establishment can arise from strong commitment OR confirmed structural persistence.
        else if cdir==stateDir and (
             (commit>=establishTh and pc>=confirmBars+1) or
             (state==CONFIRMED and confirmedAge>=establishAge and commit>=holdTh and rStruct>=.22))
            state:=ESTABLISHED
            episodeEstablished:=true

        else if commit>=confirmTh and pc>=confirmBars and cdir==stateDir
            state:=CONFIRMED

        // Once confirmed, modest softness returns to CONFIRMED rather than EMERGING.
        else if (state==CONFIRMED or state==ESTABLISHED or state==MATURE or state==STRESSED) and commit>=holdTh and cdir==stateDir
            state:=episodeEstablished?ESTABLISHED:CONFIRMED

        else if commit>=emergeTh and cdir==stateDir
            state:=EMERGING

newlyEstablished=barstate.isconfirmed and state==ESTABLISHED and prevState!=ESTABLISHED and not episodeEstablished[1]
if newlyEstablished and not na(startBar)
    addMemory(stateDir,startBar,origin,nz(originATR,a)*corridorATR,math.max(peak,.48))

ended=barstate.isconfirmed and (state==RELEASED or state==FAILED) and prevState!=state
if ended and not na(startBar)
    // Every resolved confirmed episode leaves a bounded residual footprint.
    if not episodeEstablished
        addMemory(stateDir,startBar,origin,nz(originATR,a)*corridorATR,math.max(peak,.32))
    startBar:=na
    origin:=na
    originATR:=na
    confirmedAge:=0

// Current episode corridor
var box active = na
activeState=state==CONFIRMED or state==ESTABLISHED or state==MATURE or state==STRESSED
if showCorridors and activeState and not na(startBar)
    w=nz(originATR,a)*corridorATR
    top=stateDir>0?origin+w*.35:origin+w
    bot=stateDir>0?origin-w:origin-w*.35
    col=stateDir>0?color.teal:color.fuchsia
    vcol=state==STRESSED?color.orange:col
    heroAlpha=state==STRESSED?76:state==MATURE?79:state==ESTABLISHED?81:84
    if na(active)
        active:=box.new(startBar,top,bar_index,bot,xloc=xloc.bar_index,extend=extend.right,
          border_color=color.new(vcol,5),bgcolor=color.new(vcol,heroAlpha))
    else
        box.set_left(active,startBar)
        box.set_right(active,bar_index)
        box.set_top(active,top)
        box.set_bottom(active,bot)
        box.set_border_color(active,color.new(vcol,5))
        box.set_bgcolor(active,color.new(vcol,heroAlpha))
else
    if not na(active)
        box.delete(active),active:=na

barcolor(showBars and activeState?(stateDir>0?color.new(color.teal,45):color.new(color.fuchsia,45)):na)

var int lastConfirmedEvent = na
var int lastEstablishedEvent = na
var int lastStressEvent = na
var int lastReleaseEvent = na
var int lastFailureEvent = na

cooldownOK(int lastBar) => na(lastBar) or bar_index-lastBar>=eventCooldown

newEmerging=barstate.isconfirmed and state==EMERGING and prevState!=EMERGING
rawConfirmed=barstate.isconfirmed and state==CONFIRMED and prevState!=CONFIRMED
rawEstablished=barstate.isconfirmed and state==ESTABLISHED and prevState!=ESTABLISHED
rawStress=barstate.isconfirmed and state==STRESSED and prevState!=STRESSED
rawRelease=barstate.isconfirmed and state==RELEASED and prevState!=RELEASED
rawFailure=barstate.isconfirmed and state==FAILED and prevState!=FAILED

newConfirmed=rawConfirmed and cooldownOK(lastConfirmedEvent)
newEstablished=rawEstablished and cooldownOK(lastEstablishedEvent)
newStress=rawStress and cooldownOK(lastStressEvent)
newRelease=rawRelease and cooldownOK(lastReleaseEvent)
newFailure=rawFailure and cooldownOK(lastFailureEvent)

if newConfirmed
    lastConfirmedEvent:=bar_index
if newEstablished
    lastEstablishedEvent:=bar_index
if newStress
    lastStressEvent:=bar_index
if newRelease
    lastReleaseEvent:=bar_index
if newFailure
    lastFailureEvent:=bar_index

// Confirmed is deliberately secondary. Major transitions carry the visual story.
if showConfirmed and newConfirmed
    col=stateDir>0?color.teal:color.fuchsia
    y=stateDir>0?low-a*.16:high+a*.16
    label.new(bar_index,y,"C",style=stateDir>0?label.style_label_up:label.style_label_down,
      color=color.new(col,38),textcolor=color.white,size=size.tiny)

// RELEASED remains an internal lifecycle event, but only meaningful resolved
// episodes receive a chart label. This reduces visual noise without changing logic.
significantRelease=newRelease and showReleaseLabels and
     (prevEpisodeEstablished or prevEpisodeAge>=releaseMinAge or prevEpisodePeak>=confirmTh)

majorEvent=newEstablished or newStress or significantRelease or newFailure
if showEvents and majorEvent
    txt=newEstablished?"ESTABLISHED":newStress?"STRESS":significantRelease?"RELEASED":"FAILED"
    col=newStress?color.orange:newFailure?color.gray:stateDir>0?color.teal:color.fuchsia
    y=stateDir>0?low-a*.30:high+a*.30
    label.new(bar_index,y,txt,style=stateDir>0?label.style_label_up:label.style_label_down,
      color=color.new(col,18),textcolor=color.white,size=size.tiny)

// Compact dashboard
var table t=table.new(position.top_right,2,9,border_width=1)
if barstate.islast
    if showDash
        bg=color.new(color.black,22),head=color.new(color.black,10)
        ac=state==STRESSED?color.orange:stateDir>0?color.teal:stateDir<0?color.fuchsia:color.gray
        table.cell(t,0,0,"COMMITMENT ENGINE",text_color=color.white,bgcolor=head),table.cell(t,1,0,"RC7",text_color=color.silver,bgcolor=head)
        table.cell(t,0,1,"STATE",text_color=color.silver,bgcolor=bg),table.cell(t,1,1,sname(state),text_color=ac,bgcolor=bg)
        table.cell(t,0,2,"DIRECTION",text_color=color.silver,bgcolor=bg),table.cell(t,1,2,dname(stateDir),text_color=ac,bgcolor=bg)
        table.cell(t,0,3,"COMMITMENT",text_color=color.silver,bgcolor=bg),table.cell(t,1,3,advanced?qname(commit)+" "+fmt(commit):qname(commit),text_color=color.white,bgcolor=bg)
        table.cell(t,0,4,"EFFORT",text_color=color.silver,bgcolor=bg),table.cell(t,1,4,advanced?ename(effort)+" "+fmt(effort):ename(effort),text_color=color.white,bgcolor=bg)
        table.cell(t,0,5,"RESULT",text_color=color.silver,bgcolor=bg),table.cell(t,1,5,advanced?rname(result)+" "+fmt(result):rname(result),text_color=color.white,bgcolor=bg)
        table.cell(t,0,6,"MATURITY",text_color=color.silver,bgcolor=bg),table.cell(t,1,6,mname(age),text_color=color.white,bgcolor=bg)
        table.cell(t,0,7,"STRESS",text_color=color.silver,bgcolor=bg),table.cell(t,1,7,advanced?xname(stress)+" "+fmt(stress):xname(stress),text_color=state==STRESSED?color.orange:color.white,bgcolor=bg)
        table.cell(t,0,8,"MEMORY",text_color=color.silver,bgcolor=bg),table.cell(t,1,8,str.tostring(array.size(memBoxes))+" ACTIVE",text_color=color.white,bgcolor=bg)
    else
        table.clear(t,0,0,1,8)

alertcondition(newEmerging,"Commitment Emerging","A directional commitment episode is emerging.")
alertcondition(newConfirmed,"Commitment Confirmed","Directional commitment reached confirmed state.")
alertcondition(newEstablished,"Commitment Established","Directional commitment reached established state.")
alertcondition(newStress,"Commitment Stress Developing","Stress is developing inside an established commitment episode.")
alertcondition(newRelease,"Commitment Released","The active commitment episode released.")
alertcondition(newFailure,"Commitment Failed","The active commitment episode failed.")

if newConfirmed or newEstablished or newStress or newRelease or newFailure
    alert("Commitment Engine | "+sname(state)+" | "+dname(stateDir)+" | C="+fmt(commit)+" S="+fmt(stress),alert.freq_once_per_bar_close)
````
