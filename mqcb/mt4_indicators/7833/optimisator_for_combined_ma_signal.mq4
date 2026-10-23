/*
My mt4 is not typing russion letters,
@#$%@$^^&%@$#%^$% =--> ???? прогнкуаиторШНУЫЧмсми<--=, sorry.
NOTE: Don't put much days on lower timeframes, or it will be freezed
long time put say 20 days for H1, 5 days for M5 or 120 days for D1.
This is most simplest version because is not using many-many
resources and calculations and it's using only the current chart. 
Ones optimised it can be coppied optimised parameters put by data
given by optimised screen report in standard indicator, optimise
(Combined MA Signal) for example D1, H4 and H1 (or H4, H1 and M30).
Lower timeframes are too much trades and too risky, as you will see.
(P)print file will be saved in experts/files/name
USE MANUAL:
-after optimising common variables are also active
-does not have to be restarted indicator to work
-if not restarted with optimise = False , will optimise again after
 MT4 restart or TimeFrame/Chart change
-default filter is used 1 Point, but can be any desired value by you.
-after optimising Comment is working but drawing No.
***TO DO:
It need some small corrections after optimise drawings to work,
it's working only comment text now if you want to continue to use
it as is.
Also needs corections in "add filter" for not giving hedge signals
when flex-ranged market
*/
//==============================================================
//==============================================================
#property  show_inputs 
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1 Gray
#property  indicator_color2 LightSeaGreen
#property  indicator_width1 3
#property  indicator_width2 2

extern string after_optimised = "it is not optimising until restart of MT or indicator";
extern string part_after_optimising = "turn OPTIMISE_parameters = FALSE, input by report";
extern int signal=0;
extern bool slow=0;
extern bool tp=0;
extern bool alert_open=0;
extern bool alert_close=0;
extern bool print_signals_to_file=1;
extern string common_parameters = "below are COMMON parameters";
extern int days_search=30;
extern bool print_report=1;
extern int safety_lots_percent=300;
extern double max_average_trades_daily=5.0;
extern string optimising_parameters = "below are ONLY for optimising";
extern bool OPTIMISE_parameters=0;
extern bool print_to_file=1;
extern int signals_search=30;
extern bool no_risk=1;
extern bool no_slow=0;
extern bool no_range=0;

static double range,bars,df;
static int smp,str,rf,safe,dl;
double MainBuffer[],SignalBuffer[],dat[8],lot,lots,dif,spread,
 eq,marg,max,min,val,mlot,plot,slot,alot,cls,rp,pro,f,lpr,total,_YD;
int zy[7],wave[4],date[3],lat[2],i,count,limit,counted_bars,counter,se,timep,
 move,per,cal,days,bar,tlc,time,cpp,slows,split,corner=1,window,sizefont=9;
string way[3],mov[3],sym,name,k,le,font="Arial";
datetime tm;
//+------------------------------------------------------------------+
int init()
  {
   way[0]="LONG OPEN"; way[1]=" empty "; way[2]="SHORT OPEN";
   mov[0]="SHORT CLOSE"; mov[1]=" empty "; mov[2]="LONG CLOSE";
   IndicatorDigits(Digits+2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexDrawBegin(0,0);
   SetIndexBuffer(0,MainBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,0);
   SetIndexBuffer(1,SignalBuffer);
   SetIndexLabel(1,"Signal");
   SetIndexStyle(2,DRAW_NONE);
   name="Indi";
   IndicatorShortName(name);
   string file=StringConcatenate(name,Period(),Symbol(),".txt");
   int fp=FileOpen(file,FILE_CSV|FILE_WRITE,';');
   FileClose(fp);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit() {return(0);}
//+------------------------------------------------------------------+
int start() {
 sym=Symbol();
 per=Period();
 lots=0.0;
 lot=0.0;
 spread=MarketInfo(sym,13);
 eq=AccountBalance();
 marg=AccountFreeMargin();
 val=MarketInfo(sym,16);
 mlot=MarketInfo(sym,32);
 min=MarketInfo(sym,23);
 max=MarketInfo(sym,25);
 date[2]=MarketInfo(sym,5);

 counted_bars=IndicatorCounted();
 if(counted_bars>0) counted_bars--;
 limit=Bars-counted_bars;
 if(wave[2]<1) adv();
 ind();
 
 textalerts(); 

 if(!(marg!=0.0) || !(val>0.0) || !(mlot>0.0)) return(0);
 vlts();
 Comment(mov[wave[0]]," ",DoubleToStr(dat[0],Digits)," (",TimeToStr(date[0],TIME_DATE|TIME_MINUTES),")\n\n",way[wave[1]]," ",DoubleToStr(dat[1],Digits)," (",TimeToStr(date[1],TIME_DATE|TIME_MINUTES),")\n\nLots  ",DoubleToStr(lots,wave[3])," (max ",DoubleToStr(marg/mlot,2),")\n\nStop loss  ",DoubleToStr(dat[7]+spread,0),"\n\nTrailing stop  ",DoubleToStr(bars/Point/2,0));
 return(0); }
//+------------------------------------------------------------------+
int adv()
  {
   timep=GetTickCount();
   findDay(); if( days<1 ) return(0); total=0.0; slows=0;
   if(max_average_trades_daily<1) move=40320/60/per+1; else move=max_average_trades_daily;
   bars=0; for(i=0; i<bar; i++) bars+=High[i]-Low[i]; df=Point*2;
   if(i>0 && bars>0.0) { bars/=1.0*i; range=bars/Point*4; if(range<=spread*7)range=spread*7+1; }
   safe=100+safety_lots_percent;
   if(OPTIMISE_parameters)
   {
    for(se=1;se>=(0+no_range);se--)
    {
     for(split=0;split<=(1-no_slow);split++)
     {
      for(str=signals_search;str>0;str--)
      {
       if(str<1)break;
       df=Point; //df=(bars+1)/(str+ss)/2.0; if(df<Point)
       ind();
       data();
       if(zy[6]>1 && plot>0.0)
       {
        if(no_risk)
        { 
         if(move>zy[6]*1.0/days)
         {
          if(zy[3]/MathAbs(zy[4]-1.0)>total)
           {smp=str;total=zy[3]/MathAbs(zy[4]-1.0);rf=split;dat[7]=dat[4]/zy[6]/Point;zy[0]=MathAbs(dat[3])+dat[7];dl=se;}
         }
        }
        else if(plot>total)
        {
         if(move>zy[6]*1.0/days)
          {smp=str;total=plot;rf=split;dat[7]=dat[4]/zy[6]/Point;zy[0]=MathAbs(dat[3])+dat[7];dl=se;}
        }
       }
      }
     }
    }
   }

   date[0]=date[2]; date[1]=date[0];
   wave[2]=1; wave[0]=1; wave[1]=1; lat[0]=1; lat[1]=1; ind();
   //df=(bars+1)/(smp+rf)/2.0; if(df<Point)
   df=Point;
   data(); dif=1.0; wave[3]=0; while(dif>min+0.00000001)
    {  dif*=0.1; wave[3]++; }
   if(print_report)text();
   Comment("Optimizing time was: ",((timep+1)-GetTickCount())*0.001," seconds");
   return(0);
  }

int callcount(int dcp) {
   cpp=0;cls=Open[i];//(High[i]+Low[i])/2
  if(zy[1]==0 && dcp>0){
   if(cls-dat[5]==0.0)cls-=Point; zy[6]++;
   if(wave[2]<1){dat[4]+=MathMax(dat[5]+spread*Point-lpr,Point); lpr=High[i];}
   cpp=-spread-2*df/Point-slows+(cls-dat[5])/Point;
   if(cpp!=0) balance();}
  else if(zy[1]==2 && dcp<2){
   if(dat[5]-cls==0.0)cls+=Point; zy[6]++;
   if(wave[2]<1){dat[4]+=MathMax(lpr-dat[5]-spread*Point,Point); lpr=Low[i];}
   cpp=-spread-2*df/Point-slows+(dat[5]-cls)/Point;
   if(cpp!=0) balance();}
  if(print_to_file&&wave[2]>0&&zy[1]!=dcp)pfile(dcp);
  zy[1]=dcp; dat[5]=cls; if(cpp>-1)zy[3]+=cpp; else zy[4]+=cpp; 
  if(cpp!=0) { zy[5]=cpp; if(cpp<0) {
    tlc++; dat[2]+=cpp; dat[3]=MathMin(dat[3],dat[2]); }
   else if(cpp>spread/2) dat[2]=0; }
 return(0);}

bool balance() {
 if(eq>0.0 && mlot>0.0 && val>0.0)
  {
   rp=MathMax((eq+plot-(eq+plot)/mlot*spread*val)/mlot,min);
   pro=MathMax(rp*val*range/100.0*safe+eq+plot,1.0);
   if(max_average_trades_daily==0)
   f=MathMin(rp,MathMax(rp/pro*(eq+plot),min));
   else f=MathMin(max,MathMin(rp,MathMax(rp/pro*(eq+plot),min)));
   if(plot==0){slot=f;alot=rp;} plot+=cpp*f*val;
  }
 return(0);}

void Text(string _LN, string _LT, string _LI, int _LC, int _Sp, color _LCl) {
     _YD+=sizefont+sizefont/3.0;
//     window = WindowFind(name);
     double _XD=sizefont*_Sp;
	  if(ObjectFind(_LN)<0)
	   ObjectCreate(_LN, OBJ_LABEL, window, 0, 0);
	  ObjectSet( _LN, OBJPROP_CORNER, _LC);
	  ObjectSet(_LN, OBJPROP_XDISTANCE, _XD);
	  ObjectSet( _LN, OBJPROP_YDISTANCE, _YD);
	  ObjectSetText (_LN, _LT, sizefont, font, _LCl);
	  _XD=sizefont;
	  if(ObjectFind(_LN+1)<0)
	   ObjectCreate(_LN+1, OBJ_LABEL, window, 0, 0);
	  ObjectSet( _LN+1, OBJPROP_CORNER, _LC);
	  ObjectSet(_LN+1, OBJPROP_XDISTANCE, _XD);
	  ObjectSet( _LN+1, OBJPROP_YDISTANCE, _YD);
	  ObjectSetText (_LN+1, _LI, sizefont, font, _LCl);
  return;}

void text() {
   cls=plot+eq;if(cls>1000.0){cls/=1000;k=" K";if(cls>1000.0){cls/=1000;k=" M";if(cls>1000.0){cls/=1000;k=" B";}}}
   dif=MathMax(f/max,1.0);if(dif>1000.0){dif/=1000;le=" K";if(dif>1000.0){dif/=1000;le=" M";if(dif>1000.0){dif/=1000;le=" B";}}}
   Text("re","signal "+str+", slow "+split+", tp "+se,"<REPORT>",corner,sizefont-1, LightSeaGreen);
   Text("tts",StringConcatenate(zy[6]," (-",tlc,"), safety ",safety_lots_percent,"%"),"<Trades>",corner,sizefont-1, LightSeaGreen);   
   Text("pts",StringConcatenate((zy[3]+zy[4])," (",zy[3]," - ",DoubleToStr(MathAbs(1.0*zy[4]),0),")"),"<Points>",corner,sizefont-1, LightSeaGreen);
   Text("as",StringConcatenate(DoubleToStr(MathMin(f,max),wave[3]),"Lots x ",DoubleToStr(dif,1),le),"<LastSize>",corner,sizefont-1, LightSeaGreen);
   Text("ppl",StringConcatenate(DoubleToStr(cls,1),k),"<Stop>",corner,sizefont-1, LightSeaGreen);
   Text("plt",StringConcatenate(DoubleToStr(eq,0),", size ",DoubleToStr(slot,wave[3])," of ",DoubleToStr(alot,wave[3])),"<Begin>",corner,sizefont-1, LightSeaGreen);
   Text("rd",StringConcatenate("(D",DoubleToStr(days,0),") ",TimeToStr(Time[bar],TIME_DATE|TIME_MINUTES)),"<Period>",corner,sizefont-1, LightSeaGreen);
  return;}
//=============================================== Main Program / start part
bool vlts()
  {
   lot=(marg-marg/mlot*spread*val)/mlot;//
   dif = lot*marg/(range * lot * val / 100.0 * safe + marg);
   lots=MathMax( MathMin( MathMin(dif,lot) , max ), min );
  }
  
bool ind() {
//df=(bars+1)/(str+split)/2.0; if(df<Point)
 df=Point;
 if(!OPTIMISE_parameters) {str=signal; split=slow*1;se=tp*1;}
 else {if(wave[2]<1) limit=bar; else {str=smp;split=rf;range=zy[0];se=dl;}}
 for(i=limit;i>=0;i--)
  {
   MainBuffer[i]=0.0;
   SignalBuffer[i]=0.0;
   count=str;
   while(count>=1)
    {
     if(count<1)break;
     dif=
       iMA(NULL,0,(count*2),0,3,0,i)
      -iMA(NULL,0,(count*3),0,3,4,i)
      +iMA(NULL,0,(count*2),0,3,4,i)
      -iMA(NULL,0,(count*3),0,3,1,i);
     if(count>=str/2)MainBuffer[i]+=dif;
     if(dif!=0.0)dif/=(count+1)/2;
     if(count+1<=str)SignalBuffer[i]+=dif;
     count--;
    }
  }
  return(0);}
  
int findDay() {
   if ( days_search < 1) cal=1;
   else cal=days_search;
   tm=(Time[0]-cal*60*60*24);
   bar=iBarShift(NULL,0,tm);
   time=Time[bar];
   if(GetLastError()==4066) bar=Bars/2;
   if(Time[0]-Time[bar]>(cal+3)*60*60*24) bar=Bars/2;
   days=Time[0]-Time[bar];
   if(days>1)days/=60*60*24;
 return(0);}
//=============================================== Main Program / end part
bool data() {
   for(i=1;i<7;i++){dat[i]=0.0;zy[i]=0;} zy[1]=1;
   plot=0.0; slot=0.0; alot=0.0; cpp=0; tlc=0; marg=AccountBalance();
   for(i=bar; i>=0; i--) { 
    if (zy[1]>0 && (MainBuffer[i]-MainBuffer[i+1]>0.0 || MainBuffer[i]>0.0) && SignalBuffer[i]-SignalBuffer[i+1]>df && (SignalBuffer[i]>0.0 || split<1)) callcount(0);
    else {
     if (zy[1]<2 && (MainBuffer[i]-MainBuffer[i+1]<0.0 || MainBuffer[i]<0.0) && SignalBuffer[i]-SignalBuffer[i+1]<-df && (SignalBuffer[i]<0.0 || split<1)) callcount(2);
     else {
      if(zy[1]==2 && SignalBuffer[i]-SignalBuffer[i+1]>df && (SignalBuffer[i]>0.0 || se>0)) callcount(1);
      else if(zy[1]==0 && SignalBuffer[i]-SignalBuffer[i+1]<-df && (SignalBuffer[i]<0.0 || se>0)) callcount(1); } }
    if(i==0) callcount(1);
    if(wave[2]<1){if(zy[1]==0) lpr=MathMin(Low[i],lpr); if(zy[1]==2) lpr=MathMax(High[i],lpr);}
   }
  return(0);}
//=============================================== Main Program / start part
bool textalerts() {
 if (wave[1]>0 && (MainBuffer[0]-MainBuffer[1]>0.0 || MainBuffer[0]>0.0) && SignalBuffer[0]-SignalBuffer[1]>df && (SignalBuffer[0]>0.0 || split<1) && Bid-(High[0]+Low[0])/2>df) {wave[1]=0;wave[0]=0;}
 else {
  if (wave[1]<2 && (MainBuffer[0]-MainBuffer[1]<0.0 || MainBuffer[0]<0.0) && SignalBuffer[0]-SignalBuffer[1]<-df && (SignalBuffer[0]<0.0 || split<1) && (High[0]+Low[0])/2-Bid>df) {wave[1]=2;wave[0]=2;}
  else {
   if(wave[1]==2 && wave[0]==2 && SignalBuffer[0]-SignalBuffer[1]>df && (SignalBuffer[0]>0.0 || se>0) && Bid-(High[0]+Low[0])/2>df) {wave[0]=0;lat[1]=1;wave[1]=1;}
   else if(wave[1]==0 && wave[0]==0 && SignalBuffer[0]-SignalBuffer[1]<-df && (SignalBuffer[0]<0.0 || se>0) && (High[0]+Low[0])/2-Bid>df) {wave[0]=2;lat[1]=1;wave[1]=1;} } }

 if(wave[0]!=1 && lat[0]!=wave[0]) {
   dat[0]=MarketInfo(sym,9+(lat[1]>0)); lat[0]=wave[0]; date[0]=date[2];
   string file=StringConcatenate(name,Period(),sym,".txt");
   if(print_signals_to_file){i=FileOpen(file,FILE_CSV|FILE_READ|FILE_WRITE,';');
    if(i>0){FileSeek(i,0,SEEK_END);FileWrite(i,sym,mov[wave[0]],TimeToStr(date[0],TIME_DATE|TIME_MINUTES),DoubleToStr(dat[0],Digits));FileClose(i);}}
   if(alert_close) Alert(sym," ",mov[wave[0]]," M",per); }
 if(lat[1]!=wave[1] && wave[1]!=1) {
   dat[1]=MarketInfo(sym,10-(wave[1]>0)); lat[1]=wave[1]; date[1]=date[2];
   if(print_signals_to_file){i=FileOpen(file,FILE_CSV|FILE_READ|FILE_WRITE,';');
    if(i>0){FileSeek(i,0,SEEK_END);FileWrite(i,sym,way[wave[1]],TimeToStr(date[1],TIME_DATE|TIME_MINUTES),DoubleToStr(dat[1],Digits));FileClose(i);}}
   if(alert_open) Alert(sym," ",way[wave[1]]," M",per); }
  return(0);}
//=============================================== Main Program / end part
bool pfile(int new) {
 string file=StringConcatenate(name,Period(),sym,".txt"),
  stn;
 if(new==1)stn="Close";
 else if(new==0)stn="Buy";
 else if(new==2)stn="Sell";
 int fp=FileOpen(file,FILE_CSV|FILE_READ|FILE_WRITE,';');
 if(fp>0){FileSeek(fp,0,SEEK_END);FileWrite(fp,sym,stn,TimeToStr(Time[i],TIME_DATE|TIME_MINUTES),"arround",DoubleToStr(cls+spread*((zy[1]==2&&new==1)||new==0)*Point,Digits),"lots",DoubleToStr(f,2),"+/-points",cpp,"+/-PL",DoubleToStr(cpp*f*val,1),"Total",DoubleToStr(plot,2));FileClose(fp);}
 return(0);}

//==============================================================
//==============================================================