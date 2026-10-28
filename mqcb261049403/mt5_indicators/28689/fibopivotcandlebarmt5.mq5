//+------------------------------------------------------------------+
//|                                        FiboPivotCandleBarMT5.mq5 |
//|                           Copyright 2017, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 2017/01/12"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "2.00"
#property strict
//---
#property description "FiboPivotCandleBar MetaTrader 5 is a composite of several forex indicators, Fibonacci,"
#property description "Pivot Point, ZigZag, MACD and Moving Average which are combined in this indicator."
#property description "This indicator gives advice to buy and sell with the direction of the arrow."
#property description "version: 2.0 ~ Last update: 2020/04/15 @ 12:00 PM WIT (Western Indonesian Time)"
/*
Update version 2.00
* Remove programs that are not so important
  which slows down the execution of the indicator.
* Increase the number of Pivot Points Resistance and Support from only 7 to S8 and R8.
* Simplify and improve the structure of the program.
*/
//--
#include <MovingAverages.mqh>
//--
#property indicator_chart_window
#property indicator_buffers  2
#property indicator_plots    2
#property indicator_type1    DRAW_NONE
//---
enum fonts
  {
    Arial_Black,
    Bodoni_MT_Black
  };
//--
enum YN
 {
   No,  // No
   Yes  // Yes
 };
//--
//---
input YN          MsgAlerts = Yes;               // Activate Alert (Yes) or (No)
input YN        eMailAlerts = No;                // Send Email Alert (Yes) or (No)
input YN      UseSendnotify = No;                // Send Notification (Yes) or (No)
input fonts     Fonts_Model = Bodoni_MT_Black;   // Choose Fonts Model
input color      FontColors = clrSnow;;          // colors for font
input color           BarUp = clrSnow;           // color for Bar_Up and Bull Candle
input color         BarDown = clrRed;            // color for Bar_Down and Bear Candle
input color       LineGraph = clrYellow;         // color for Line Graph (if Price Close == Price Open)
input color        EmptyBar = clrLightSlateGray; // If the bar has not been passed by the price movement
//--
ENUM_BASE_CORNER corner=CORNER_RIGHT_LOWER;
int distance_x=157;
int distance_y=47;
int digit;
int csec,psec;
int prctick;
int prcpxl=170;
int arrpvt=22;
int font_size=8;
int font_size_OHLC=7;
color font_color;
string font_ohlc;
string font_face="Arial";
//--
double Pvt,
       PvtO,
       PvtL,
       PvtH,
       PvtC,
       PvtO1,
       PvtL1,
       PvtH1,
       PvtC1;
//--
double pivot[];
double fibolvl[]={0.0,23.6,38.2,50.0,61.8};
string label[]={"S8","S7","S6","S5","S4","S3","S2","SS1","S1","L20","L40","L60","L80","R1","SR1","R2","R3","R4","R5","R6","R7","R8"};
             //  0    1    2    3    4     5    6     7     8     9    10    11   12    13   14   15   16   17   18   19   20   21
//-- buffers indi
double Price_Up[],
       Price_Dn[];
//-- zigzag param
int depth=12;  // Depth
int devia=5;   // Deviation
int backs=3;   // Backstep
int level=3;   // recounting's depth of extremums
int zh,zl;
int barh=5;
int bars=110;
int HiLo=108;
//-- zigzag buffers
double 
   ExtZz[],
   ExtHi[],
   ExtLo[];
//-- ma buffers
double 
   EMA5e02[],
   SMA5s20[],
   MAONs10[],
   MAONs62[];
//-- macd buffers       
double 
   MACDM[],
   MACDS[];
//--    
ENUM_TIMEFRAMES
    prhh=PERIOD_M30,
    prh1=PERIOD_H1,
    prdp,
    prfb;
//--
int cral,
    pral,
    crmnt,
    prmnt;
//--
bool ArrUp,
     ArrDn;
//--
int h_iMa2,
    h_iMa20,
    h_Macd;
//--
long chart_id;
string short_name;
string alBase,alSubj,alMsg;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Price_Up,INDICATOR_DATA);
   PlotIndexSetString(0,PLOT_LABEL,"Price_Up");
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
   SetIndexBuffer(1,Price_Dn,INDICATOR_DATA);
   PlotIndexSetString(1,PLOT_LABEL,"Price_Dn");
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
   //--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---
   //-- Checking the Digits Point
   if(Digits()==3||Digits()==5)
      digit=Digits();
   else digit=Digits()+1;
   csec=0;
   psec=-1;
   //--
   chart_id=ChartID();
   font_ohlc=FontsModel(Fonts_Model);
   font_color=FontColors;
//---
   prctick=int(prcpxl/20*arrpvt);
   //--
   short_name="FiboPivotCandleBar";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+"_("+Symbol()+")");
   IndicatorSetInteger(INDICATOR_DIGITS,digit);
   //--
   if(Period()==PERIOD_MN1) {prdp=PERIOD_MN1; prfb=PERIOD_D1;}
   if(Period()==PERIOD_W1)  {prdp=PERIOD_W1; prfb=PERIOD_H4;}
   if(Period()<=PERIOD_D1)  {prdp=PERIOD_D1; prfb=PERIOD_H1;}
   //--
   h_iMa2=iMA(Symbol(),PERIOD_M15,2,0,MODE_EMA,PRICE_MEDIAN);
   if(h_iMa2==INVALID_HANDLE)
     {
       //--- tell about the failure and output the error code
       PrintFormat("Failed to create handle of the iMA PERIOD_M15 indicator period 2 for the symbol %s/%s, error code %d",
                   Symbol(),
                   EnumToString(Period()),
                   GetLastError());
       //--- the indicator is stopped early
       return(INIT_FAILED);
     }
   h_iMa20=iMA(Symbol(),PERIOD_M15,20,0,MODE_SMA,PRICE_MEDIAN);
   if(h_iMa20==INVALID_HANDLE)
     {
       //--- tell about the failure and output the error code
       PrintFormat("Failed to create handle of the iMA PERIOD_M15 indicator period 20 for the symbol %s/%s, error code %d",
                   Symbol(),
                   EnumToString(Period()),
                   GetLastError());
       //--- the indicator is stopped early
       return(INIT_FAILED);
     }
   //--
   h_Macd=iMACD(Symbol(),prh1,12,26,9,PRICE_CLOSE);
   if(h_Macd==INVALID_HANDLE)
     {
       //--- tell about the failure and output the error code
       PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                   Symbol(),
                   EnumToString(Period()),
                   GetLastError());
       //--- the indicator is stopped early
       return(INIT_FAILED);
     }
   //---
   return(INIT_SUCCEEDED);
//---
  } //-end OnInit()
//-------//
//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
//---
    ObjectsDeleteAll(chart_id,-1,-1);
    //--
    if(h_iMa2!=INVALID_HANDLE) 
       IndicatorRelease(h_iMa2);
    if(h_iMa20!=INVALID_HANDLE) 
       IndicatorRelease(h_iMa20);
    if(h_Macd!=INVALID_HANDLE) 
       IndicatorRelease(h_Macd); 
//--- clear the chart after deleting the indicator 
    Comment(""); 
   //--
   return;
//---
  } //-end OnDeinit()
//---------//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
//--- Set Last error value to Zero
   ResetLastError();
   int limit;
   cral=0;
//--- check for rates total
   if(rates_total<bars)
      return(0);
   limit=rates_total-prev_calculated+5;
   if(prev_calculated==0) limit=bars;
   if(prev_calculated>0) limit++;
   if(limit>bars) limit=bars;
   //--
   ArrayResize(EMA5e02,limit);
   ArrayResize(SMA5s20,limit);
   ArrayResize(MAONs10,limit);
   ArrayResize(MAONs62,limit);
   ArrayResize(MACDM,limit);
   ArrayResize(MACDS,limit);
   ArrayResize(Price_Up,limit);
   ArrayResize(Price_Dn,limit);
   ArraySetAsSeries(Price_Up,true);
   ArraySetAsSeries(Price_Dn,true);
   ArraySetAsSeries(EMA5e02,true);
   ArraySetAsSeries(SMA5s20,true);
   ArraySetAsSeries(MAONs10,true);
   ArraySetAsSeries(MAONs62,true);
   ArraySetAsSeries(MACDM,true);
   ArraySetAsSeries(MACDS,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   //---
   int ob=0,
       ot=0,
       tb=0,
       tt=0,
       bb=0,
       bt=0,
       cb=0,
       ct=0,
       hb=0,
       ht=0,
       lb=0,
       lt=0;
   //--
   int pso=0;
   int psh=0;
   int psl=0;
   int psc=0;
   int stax=0;
   int cprz=5;
   int dlvl=5;
   int fstp=4;
   int pstep=0;
   int pvtup=0,
       pvtdn=0;
   //--
   double himax=0,
          lomin=0;
   //--
   color opsclr=0;
   color clrmove=0;
   color colordir=0;
   color fbarup=BarUp;
   color fbardn=BarDown;
   color fbarnt=LineGraph;
   color color_fbar=EmptyBar;
   //--
   string stdir;
   //--
   bool opsup=false,
        opsdn=false,
        opsnt=false;
   //--
   double dfl=61.8;
   double barlvl[],przlvl[];
   //--
   ArrayResize(barlvl,dlvl);
   ArrayResize(przlvl,dlvl);
   ArrayResize(pivot,arrpvt);
   ArraySetAsSeries(barlvl,false);
   ArraySetAsSeries(przlvl,false);
   ArraySetAsSeries(pivot,false);
   //---
   //--
   PvtO=iOpen(Symbol(),prdp,0);  
   PvtH=iHigh(Symbol(),prdp,0); 
   PvtL=iLow(Symbol(),prdp,0);
   PvtC=iClose(Symbol(),prdp,0);
   PvtO1=iOpen(Symbol(),prdp,1);
   PvtH1=iHigh(Symbol(),prdp,1);
   PvtL1=iLow(Symbol(),prdp,1);
   PvtC1=iClose(Symbol(),prdp,1);
   //--
   Pvt=(PvtH1+PvtL1+PvtC1)/3;
   //--
   double sup1=((Pvt*2)-PvtH1);          // support_1
   double res1=((Pvt*2)-PvtL1);          // resistance_1
   double disr=res1-sup1;                // distance R1 - S1
   double disl=disr*0.20;                // distance line
   //-
   pivot[21]=(Pvt*7)+(PvtH1)-(PvtL1*7);  // resistance_8
   pivot[20]=(Pvt*6)+(PvtH1)-(PvtL1*6);  // resistance_7
   pivot[19]=(Pvt*5)+(PvtH1)-(PvtL1*5);  // resistance_6
   pivot[18]=(Pvt*4)+(PvtH1)-(PvtL1*4);  // resistance_5
   pivot[17]=(Pvt*3)+(PvtH1)-(PvtL1*3);  // resistance_4
   pivot[16]=(Pvt*2)+(PvtH1)-(PvtL1*2);  // resistance_3
   pivot[15]=(Pvt+PvtH1-PvtL1);          // resistance_2
   pivot[14]=res1+(disl*0.618);          // strong_resistance_1
   pivot[13]=res1;                       // resistance_1
   pivot[12]=(sup1+(disr*0.8));          // point_80
   pivot[11]=(sup1+(disr*0.6));          // point_60
   pivot[10] =(sup1+(disr*0.4));          // point_40
   pivot[9] =(sup1+(disr*0.2));          // point_20
   pivot[8] =sup1;                       // support_1
   pivot[7]=sup1-(disl*0.618);           // strong_suppot_1
   pivot[6]=(Pvt-PvtH1+PvtL1);           // support_2
   pivot[5]=(Pvt*2)-((PvtH1*2)-(PvtL1)); // support_3
   pivot[4]=(Pvt*3)-((PvtH1*3)-(PvtL1)); // support_4
   pivot[3]=(Pvt*4)-((PvtH1*4)-(PvtL1)); // support_5
   pivot[2]=(Pvt*5)-((PvtH1*5)-(PvtL1)); // support_6
   pivot[1]=(Pvt*6)-((PvtH1*6)-(PvtL1)); // support_7
   pivot[0]=(Pvt*7)-((PvtH1*7)-(PvtL1)); // support_8
   //---
   csec=Seconds();
   if(csec!=psec) IndicatorsCondition(limit);
   psec=csec;
   //--
   int zzM1=ZigZagDir(prhh);
   int zzH1=ZigZagDir(prh1);
   int ma5mv=MA5Trend(limit);
   //--
   double mcdm0=MACDM[0];
   double mcdm1=MACDM[1];
   double mcds0=MACDS[0];
   double mcds1=MACDS[1];
   double macd0=mcdm0-mcds0;
   double macd1=mcdm1-mcds1;
   //--
   if(((zzH1==1)&&(zzM1==1))||((macd0>macd1)&&(mcdm0>mcdm1))) {ArrUp=true; ArrDn=false;}
   if(((zzH1==-1)&&(zzM1==-1))||((macd0<macd1)&&(mcdm0<mcdm1))) {ArrDn=true; ArrUp=false;}
   if(((ArrUp==true)&&(zzH1==2))||((mcdm0<mcdm1)&&(macd0<macd1))) {ArrDn=true; ArrUp=false;}
   if(((ArrDn==true)&&(zzH1==-2))||((mcdm0>mcdm1)&&(macd0>macd1))) {ArrUp=true; ArrDn=false;}
   if((mcdm0>=mcdm1)&&(mcdm0>mcds0)&&(mcds0>mcds1)) {ArrUp=true; ArrDn=false;}
   if((mcdm0<=mcdm1)&&(mcdm0<mcds0)&&(mcds0<mcds1)) {ArrDn=true; ArrUp=false;}
   if(ma5mv==1) {ArrUp=true; ArrDn=false;}
   if(ma5mv==-1) {ArrDn=true; ArrUp=false;}
   //--
   double fpCls0=(iHigh(Symbol(),prh1,0)+iLow(Symbol(),prh1,0)+iClose(Symbol(),prh1,0)+iClose(Symbol(),prh1,0))/4;
   double fpCls1=(iHigh(Symbol(),prh1,1)+iLow(Symbol(),prh1,1)+iClose(Symbol(),prh1,1)+iClose(Symbol(),prh1,1))/4;
   double hlcc0=fpCls0-SMA5s20[0];
   double hlcc1=fpCls1-SMA5s20[1];
   //--
   //- prepare the braking movement
   //--
   if((ArrUp==true)&&(hlcc0>hlcc1))
     {opsup=true; opsdn=false; opsnt=false; stax=24; stdir="BUY"; opsclr=fbarup; 
      Price_Up[0]=NormalizeDouble(iLow(Symbol(),Period(),0),Digits()); Price_Dn[0]=0.0;}
   if((ArrDn==true)&&(hlcc0<hlcc1))
     {opsdn=true; opsup=false; opsnt=false; stax=21; stdir="SELL"; opsclr=fbardn; 
      Price_Dn[0]=NormalizeDouble(iHigh(Symbol(),Period(),0),Digits()); Price_Up[0]=0.0;}
   if((!opsup)&&(!opsdn))
     {opsnt=true; opsup=false; opsdn=false; opsclr=fbarnt; Price_Up[0]=0.0; Price_Dn[0]=0.0;}
   //-
   //-- prepare the Fibo Highest and Lowest Price
   int inH=iHighest(Symbol(),prfb,MODE_HIGH,HiLo,0);
   int inL=iLowest(Symbol(),prfb,MODE_LOW,HiLo,0);
   if(inH!=-1) himax=iHigh(Symbol(),prfb,inH);
   if(inL!=-1) lomin=iLow(Symbol(),prfb,inL);
   if((PvtH<=pivot[12])&&(PvtL>=pivot[7])) {himax=pivot[12]; lomin=pivot[7];}
   double dayHi=PvtH;
   double dayLo=PvtL;
   //--
   for(int g=0; g<dlvl; g++) 
     {
       //--
       barlvl[g]=prctick/dfl*fibolvl[g];
       przlvl[g]=lomin+(((himax-lomin)/dfl)*fibolvl[g]);
       //--
     }   
   //--
   PvtO=iOpen(Symbol(),prdp,0);  
   PvtH=iHigh(Symbol(),prdp,0); 
   PvtL=iLow(Symbol(),prdp,0);
   PvtC=iClose(Symbol(),prdp,0);
   //-
   double sumfbar=int(barlvl[4]-barlvl[0]);
   int fbajs=int(prctick-sumfbar);
   //--
   double przHL=przlvl[4]-przlvl[0];
   pso=int(NotZeroDiv((PvtO-przlvl[0]),przHL)*prctick)+fbajs;
   psh=int(NotZeroDiv((PvtH-przlvl[0]),przHL)*prctick)+fbajs;
   psl=int(NotZeroDiv((PvtL-przlvl[0]),przHL)*prctick)+fbajs;
   psc=int(NotZeroDiv((PvtC-przlvl[0]),przHL)*prctick)+fbajs;
   //--
   int fbbar=psh-psl+1;
   int fcbar=fabs(psc-pso)+1;
   int fcbhi=psh-psc+1;
   int fcblo=fabs(psl-psc)+1;
   //--
   for(int b=0; b<arrpvt-1; b++)
     {
       //--
       if((PvtO>=pivot[b])&&(PvtO<pivot[b+1])) {ob=b; ot=b+1;}
       if((PvtH>=pivot[b])&&(PvtH<pivot[b+1])) {tb=b; tt=b+1;}
       if((PvtL>=pivot[b])&&(PvtL<pivot[b+1])) {bb=b; bt=b+1;}
       if((PvtC>=pivot[b])&&(PvtC<pivot[b+1])) {cb=b; ct=b+1;}
       //--
       ht=tt; lb=bb;
     }
   //--
   if(ht-lb<5) {ht=lb+5;}
   pstep=ht-lb;
   int pvtlvl=prctick/pstep;
   //--
   double barop=(NotZeroDiv((PvtO-pivot[ob]),(pivot[ot]-pivot[ob]))*pvtlvl)+((ob-lb)*pvtlvl);
   double barhi=(NotZeroDiv((PvtH-pivot[tb]),(pivot[tt]-pivot[tb]))*pvtlvl)+((tb-lb)*pvtlvl);
   double barlo=(NotZeroDiv((PvtL-pivot[bb]),(pivot[bt]-pivot[bb]))*pvtlvl)+((bb-lb)*pvtlvl);
   double barcl=(NotZeroDiv((PvtC-pivot[cb]),(pivot[ct]-pivot[cb]))*pvtlvl)+((cb-lb)*pvtlvl);
   //--
   int pvop=int(barop)+1;
   int pvhi=int(barhi)+1;
   int pvlo=int(barlo);
   int pvcl=int(barcl);
   int pvbar=pvhi-pvlo;
   int pvthi=fabs(pvhi-pvcl);
   int pvtlo=fabs(pvcl-pvlo);
   pvtup=fabs(pvcl-pvop);
   pvtdn=fabs(pvop-pvcl);
   if(PvtC>PvtO) {clrmove=fbarup;}
   if(PvtC<PvtO) {clrmove=fbardn;}
   if(PvtC==PvtO) {clrmove=fbarnt;}
   //---
   string bar45=CharToString(45);
   string barcnd=CharToString(151)+CharToString(151)+CharToString(151);
   //--
   for(int d=0; d<arrpvt-1; d++) 
     {
       ObjectDelete(chart_id,"PivotLevel_"+string(d));
       ObjectDelete(chart_id,"PivotLableLevel_"+string(d));
     }
   for(int n=0; n<dlvl; n++)
     {
       //--
       ObjectDelete(chart_id,"FiboBarLevel_"+string(n));
       ObjectDelete(chart_id,"FiboBar_"+string(n));
       //--
     }
   //--
   for(int s=0; s<=prctick+1; s++) 
     {
       ObjectDelete(chart_id,"PivotBar"+string(s));
       ObjectDelete(chart_id,"CloseBar"+string(s));
       ObjectDelete(chart_id,"PivotBarNt"+string(s));
       ObjectDelete(chart_id,"FiboBar"+string(s));
       ObjectDelete(chart_id,"FiboBar_cu"+string(s));
       ObjectDelete(chart_id,"FiboBar_cd"+string(s));
       ObjectDelete(chart_id,"FiboBarUph"+string(s));
       ObjectDelete(chart_id,"FiboBarDnl"+string(s));
       ObjectDelete(chart_id,"FiboBar_clu"+string(s));
       ObjectDelete(chart_id,"FiboBar_cld"+string(s));
       ObjectDelete(chart_id,"FiboBar"+string(s));
       ObjectDelete(chart_id,"FiboBar_nt"+string(s));
       ObjectDelete(chart_id,"FiboBar_cln"+string(s));
       ObjectDelete(chart_id,"CloseBarUp"+string(s));
       ObjectDelete(chart_id,"CloseBarDn"+string(s));
       ObjectDelete(chart_id,"CloseBarNt"+string(s));
     }
   //--
   //-- Draw Fibo Pivot Candle Bar
   for(int r=0; r<=pstep; r++)
     {
       //-- Create Pivot Bar Levels
       string plevel=bar45+DoubleToString(pivot[lb+r],digit);
       CreateSetLable(chart_id,"PivotLevel_"+string(r),font_face,font_size,font_color,plevel,
                      corner,distance_x-109,distance_y+r*pvtlvl,true);
       //--
       string llevel=label[lb+r]+bar45; 
       int disc=StringLen(llevel)>3?0:5;
       CreateSetLable(chart_id,"PivotLableLevel_"+string(r),font_face,font_size,font_color,llevel,
                      corner,distance_x-52-disc,distance_y+r*pvtlvl,true);     
     }               
   //--
   for(int pv=0; pv<prctick; pv++)
     {
       //--
       CreateSetLable(chart_id,"PivotBarNt"+string(pv),font_face,font_size,color_fbar,bar45,
                      corner,distance_x-89,distance_y+1+pv,true);
                      
       CreateSetLable(chart_id,"FiboBar"+string(pv),font_face,font_size,color_fbar,bar45,
                      corner,distance_x+12,distance_y+1+fbajs+pv,true);
       //--
     }
   //--
   for(int i=0; i<pvbar; i++)
     {
       //--
       CreateSetLable(chart_id,"PivotBar"+string(i),font_face,font_size,clrmove,bar45,
                      corner,distance_x-89,distance_y+pvlo+i,true);
       //--
     }
   //--
   for(int n=0; n<dlvl; n++)
     {
       //--
       string fibbar=bar45+DoubleToString(przlvl[n],digit);
       CreateSetLable(chart_id,"FiboBar_"+string(n),font_face,font_size,font_color,fibbar,
                      corner,distance_x-7,distance_y+fbajs+(int)barlvl[n],true);
       //--
       string fiblevel=DoubleToString(fibolvl[n],1)+bar45;
       CreateSetLable(chart_id,"FiboBarLevel_"+string(n),font_face,font_size,font_color,fiblevel,
                      corner,distance_x+51,distance_y+fbajs+(int)barlvl[n],true);
     }
   //--
   if(PvtC>PvtO)
     {
       //--
       for(int v=0; v<pvtup; v++)
         {
           //--    
           CreateSetLable(chart_id,"CloseBar"+string(v),font_face,font_size,clrmove,barcnd,
                          corner,distance_x-75,distance_y+pvop+v,true);
          //--
        }        
      for(int l=0; l<=psh-psl; l++)
        {
          //--
          CreateSetLable(chart_id,"FiboBar_cu"+string(l),font_face,font_size,clrmove,bar45,
                         corner,distance_x+12,distance_y+fbajs+psl+l,true);
          //--
        }       
      //-
      for(int fl=0; fl<psc-pso+1; fl++)
        {
          //--
          CreateSetLable(chart_id,"FiboBar_clu"+string(fl),font_face,font_size,fbarup,barcnd,
                         corner,distance_x+26,distance_y+fbajs+pso+fl,true);
          //--
        }                 
      //--        
     }
   //--
   if(PvtC<PvtO)
     {
       //--
       for(int v=0; v<pvtdn; v++)
         {
           //--
           CreateSetLable(chart_id,"CloseBar"+string(v),font_face,font_size,clrmove,barcnd,
                          corner,distance_x-75,distance_y+pvcl+v,true);
          //--
         }
       for(int l=0; l<=psh-psl; l++)
         {
           //--
           CreateSetLable(chart_id,"FiboBar_cd"+string(l),font_face,font_size,clrmove,bar45,
                          corner,distance_x+12,distance_y+fbajs+psl+l-1,true);
           //--
         }
       //-
       for(int fl=0; fl<pso-psc; fl++)
         {
           //--
           CreateSetLable(chart_id,"FiboBar_cld"+string(fl),font_face,font_size,fbardn,barcnd,
                          corner,distance_x+26,distance_y+fbajs+psc+fl-1,true);
           //--
         }              
       //--     
     }
   //--
   if(PvtC==PvtO)
     {
       //--
       for(int v=0; v<2; v++)
         {
           //--
           CreateSetLable(chart_id,"CloseBar"+string(v),font_face,font_size,clrmove,barcnd,
                          corner,distance_x-75,distance_y+pvop+v,true);              
           //--
         }
       //--
       for(int l=0; l<=psh-psl; l++)
         {
            //--
            CreateSetLable(chart_id,"FiboBar_nt"+string(l),font_face,font_size,fbarnt,bar45,
                           corner,distance_x+12,distance_y+fbajs+psl+l,true);
            //--
         }
       //-
       for(int fl=0; fl<2; fl++)
         {
           //--
           CreateSetLable(chart_id,"FiboBar_cln"+string(fl),font_face,font_size,fbarnt,barcnd,
                          corner,distance_x+26,distance_y+fbajs+pso+fl,true);
           //--
         }
       //--        
     }
   //---
   //--
   for(int db=0; db<prctick; db++)
     {
       ObjectDelete(chart_id,"FiboBarUph"+string(db));
       ObjectDelete(chart_id,"FiboBarDnl"+string(db));
     }
   //--
   if(ArrUp==true)
     {
       //--
       if((PvtL==dayLo)&&(PvtC>dayLo) && (PvtC<PvtO))
         {
           //--
           cral=-2;
           for(int bd=0; bd<fcblo; bd++)
             {
               CreateSetLable(chart_id,"FiboBarDnl"+string(bd),font_face,font_size,fbarup,bar45,
                              corner,distance_x+12,distance_y+fbajs+psl+bd-1,true);
             }
           //--
         }
       //--
       if(opsup==true) cral=1;
       //--
     }
   //--
   if(ArrDn==true)
     {
       //--
       if((PvtH==dayHi)&&(PvtC<dayHi) && (PvtC>PvtO))
         {
           //--
           cral=2;
           for(int bu=0; bu<fcbhi; bu++)
             {
               CreateSetLable(chart_id,"FiboBarUph"+string(bu),font_face,font_size,fbardn,bar45,
                              corner,distance_x+12,distance_y+fbajs+psc+bu+1,true);
             }
           //--
         }
       //--
       if(opsdn==true) cral=-1;
       //--
     }
   //---
   ObjectDelete(chart_id,"FiboDir");
   ObjectDelete(chart_id,"PivotDir");
   ObjectDelete(chart_id,"PivotStr");
   //--
   if(ArrUp==true)
     {     
       //--
       if((ArrUp==true)&&(opsup==true)) colordir=fbarup;
       else colordir=fbarnt;
       CreateSetLable(chart_id,"PivotDir","Wingdings",20,colordir,CharToString(217),
                      corner,distance_x-80,distance_y-17,true);
       CreateSetLable(chart_id,"FiboDir","Wingdings",20,colordir,CharToString(217),
                      corner,distance_x+23,distance_y-17,true);
       if(opsup==true)
         {               
           CreateSetLable(chart_id,"PivotStr",font_ohlc,12,opsclr,stdir,
                      corner,distance_x-stax,distance_y-22,true);
         }
       else
         {
           CreateSetLable(chart_id,"PivotStr",font_ohlc,11,fbarnt,"WAIT",
                      corner,distance_x-18,distance_y-22,true);
         }
       //--
     }
   //--
   else if(ArrDn==true)
     {
       //--
       if((ArrDn==true)&&(opsdn==true)) colordir=fbardn;
       else colordir=fbarnt;
       CreateSetLable(chart_id,"PivotDir","Wingdings",20,colordir,CharToString(218),
                      corner,distance_x-80,distance_y-17,true);
       CreateSetLable(chart_id,"FiboDir","Wingdings",20,colordir,CharToString(218),
                      corner,distance_x+23,distance_y-17,true);
       if(opsdn==true)
         {              
           CreateSetLable(chart_id,"PivotStr",font_ohlc,12,opsclr,stdir,
                      corner,distance_x-stax,distance_y-22,true);
         }
       else
         {
           CreateSetLable(chart_id,"PivotStr",font_ohlc,11,fbarnt,"WAIT",
                      corner,distance_x-18,distance_y-22,true);
         }
       //--
     }
   //--
   else
     {
       //--
       colordir=fbarnt;
       CreateSetLable(chart_id,"PivotDir","Wingdings",20,colordir,CharToString(108),
                      corner,distance_x-82,distance_y-17,true);
       CreateSetLable(chart_id,"FiboDir","Wingdings",20,colordir,CharToString(108),
                      corner,distance_x+20,distance_y-17,true);
                      
       CreateSetLable(chart_id,"PivotStr",font_ohlc,11,fbarnt,"WAIT",
                      corner,distance_x-18,distance_y-22,true);
       //--
     }
   //--
   pos_alerts(cral);
   ChartRedraw(0);
   //---
//--- return value of prev_calculated for next call
   return(rates_total);
//---
  } //-end OnCalculate()
//-------//
//----------------------------------------------------------------------//

void IndicatorsCondition(int barCount)
  {
//---
    //- Fill Indicators Arrays From Buffers
    //Print("bar to copied = "+string(barCount));
    CopyBuffer(h_iMa2,0,0,barCount,EMA5e02);
    //--
    CopyBuffer(h_iMa20,0,0,barCount,SMA5s20);
    //--
    CopyBuffer(h_Macd,0,0,barCount,MACDM);
    //--
    CopyBuffer(h_Macd,1,0,barCount,MACDS);
   //--
   return;
//---
  } //-end IndicatorsCondition()
//---------//
 
int ZigZagDir(ENUM_TIMEFRAMES ztf)
  {
//---
    //--
    int i,lmt,counterZ,whatlookfor=0;
    int back,pos,lasthighpos=0,lastlowpos=0,zz=0;
    double extremum;
    double curlow=0.0,curhigh=0.0,lasthigh=0.0,lastlow=0.0;
//---
    ArrayResize(ExtZz,bars);
    ArrayResize(ExtHi,bars);
    ArrayResize(ExtLo,bars);
    ArraySetAsSeries(ExtZz,true);
    ArraySetAsSeries(ExtHi,true);
    ArraySetAsSeries(ExtLo,true);
    //---
    lmt=Initialize();
    //--
    i=counterZ=zh=zl=0;
    while(counterZ<level && i<bars)
      {
        if(ExtZz[i]!=0.0)
           counterZ++;
        i++;
      }
    //---
    if(counterZ==0)
       lmt=Initialize();
//--- first counting position       
    else
      {
       //---
       lmt=i-1;
       //---
       if(ExtLo[i]!=0.0) 
         {
          //---
          curlow=ExtLo[i];
          //---
          whatlookfor=1;
         }
       else
         {
          //---
          curhigh=ExtHi[i];
          //---
          whatlookfor=-1;
         }
       //---
       for(i=lmt-1; i>=0; i--)  
         {
           ExtZz[i]=0.0;  
           ExtLo[i]=0.0;
           ExtHi[i]=0.0;
         }
      }
//---- main loop
    //--
    for(i=lmt; i>=0; i--)
      {
        //---
        extremum=iLow(Symbol(),ztf,iLowest(Symbol(),ztf,MODE_LOW,depth,i));
        //---
        if(extremum==lastlow)
          extremum=0.0;
        else 
         { 
           //---
           lastlow=extremum; 
           //---
           if(iLow(Symbol(),ztf,i)-extremum>devia*Point())
             extremum=0.0;
           else
             {
               //---
               for(back=1; back<=backs; back++)
                 {
                   pos=i+back;
                   if(ExtLo[pos]!=0 && ExtLo[pos]>extremum)
                     ExtLo[pos]=0.0; 
                 }
             }
         } 
        //---
        if(iLow(Symbol(),ztf,i)==extremum)
          {
            ExtLo[i]=extremum;
            zl=i;
          }
        else
          ExtLo[i]=0.0;
        //---
        extremum=iHigh(Symbol(),ztf,iHighest(Symbol(),ztf,MODE_HIGH,depth,i));
        //--- this highest has been found previously
        if(extremum==lasthigh)
          extremum=0.0;
        else 
          {
            //---
            lasthigh=extremum;
            //---
            if(extremum-iHigh(Symbol(),ztf,i)>devia*Point())
              extremum=0.0;
            else
              {
                //---
                for(back=1; back<=backs; back++)
                  {
                    pos=i+back;
                    if(ExtHi[pos]!=0 && ExtHi[pos]<extremum)
                      ExtHi[pos]=0.0; 
                  } 
              }
          }
        //--- found extremum is current high
        if(iHigh(Symbol(),ztf,i)==extremum)
          {
            ExtHi[i]=extremum;
            zh=i;
          }
        else
          ExtHi[i]=0.0;
      }
//--- main loop end
//--- final cutting 
    if(whatlookfor==0)
      {
        lastlow=0.0;
        lasthigh=0.0;  
      }
    else
      {
        lastlow=curlow;
        lasthigh=curhigh;
      }
    for(i=lmt; i>=0; i--)
      {
        switch(whatlookfor)
          {
            case 0: // look for peak or lawn 
            if(lastlow==0.0 && lasthigh==0.0)
              {
               if(ExtHi[i]!=0.0)
                 {
                  lasthigh=iHigh(Symbol(),ztf,i); 
                  lasthighpos=i;
                  whatlookfor=-1;
                  ExtZz[i]=lasthigh;
                  zh=lasthighpos;
                 }
               if(ExtLo[i]!=0.0)
                 {
                  lastlow=iLow(Symbol(),ztf,i);
                  lastlowpos=i;
                  whatlookfor=1;
                  ExtZz[i]=lastlow;
                  zl=lastlowpos;
                 }
              }
            break;
            //---
            case 1: // look for peak
            if(ExtLo[i]!=0.0 && ExtLo[i]<lastlow && ExtHi[i]==0.0)
              {
               ExtZz[lastlowpos]=0.0;
               lastlowpos=i;
               lastlow=ExtLo[i];
               ExtZz[i]=lastlow;
               zl=lastlowpos;
              }
            if(ExtHi[i]!=0.0 && ExtLo[i]==0.0)
              {
               lasthigh=ExtHi[i];
               lasthighpos=i;
               ExtZz[i]=lasthigh;
               whatlookfor=-1;
               zh=lasthighpos;
              }   
            break;
            //---             
            case -1: // look for lawn
            if(ExtHi[i]!=0.0 && ExtHi[i]>lasthigh && ExtLo[i]==0.0)
              {
               ExtZz[lasthighpos]=0.0;
               lasthighpos=i;
               lasthigh=ExtHi[i];
               ExtZz[i]=lasthigh;
               zh=lasthighpos;
              }
            if(ExtLo[i]!=0.0 && ExtHi[i]==0.0)
              {
               lastlow=ExtLo[i];
               lastlowpos=i;
               ExtZz[i]=lastlow;
               whatlookfor=1;
               zl=lastlowpos;
              }   
            break;               
          }
      }
    //--
    //---
    if(ztf==PERIOD_H1)
      {
        if((zl<zh)&&(zl>0)&&(zl<4)) zz=1;
        if((zh<zl)&&(zh>0)&&(zh<4)) zz=-1;
        if((zl<zh)&&(zl>4)) zz=2;
        if((zh<zl)&&(zh>4)) zz=-2;
      }
    if(ztf==PERIOD_M30)
      {
        if(zl<zh) zz=1;
        if(zh<zl) zz=-1;
      }
    //--
    return(zz);
//---
  } //-end ZigZagDir()
//---------//

int Initialize()
  {
//---
    ArrayInitialize(ExtZz,0.0);
    ArrayInitialize(ExtHi,0.0);
    ArrayInitialize(ExtLo,0.0);
   //--- first counting position
   return(bars-depth);
//---
  } //-end Initialize()
//---------//

int MA5Trend(int bar)
  {
    //---
    int m5t=0;
    //--
    ArrayResize(EMA5e02,bar);
    ArrayResize(SMA5s20,bar);
    ArrayResize(MAONs10,bar);
    ArrayResize(MAONs62,bar);
    ArraySetAsSeries(EMA5e02,true);
    ArraySetAsSeries(SMA5s20,true);
    ArraySetAsSeries(MAONs10,true);
    ArraySetAsSeries(MAONs62,true);
    //--
    SimpleMAOnBuffer(bar,0,0,10,SMA5s20,MAONs10);
    SimpleMAOnBuffer(bar,0,0,62,SMA5s20,MAONs62);
    //--
    double ma10620=MAONs10[0]-MAONs62[0];
    double ma10621=MAONs10[1]-MAONs62[1];
    double ma20100=SMA5s20[0]-MAONs10[0];
    double ma20101=SMA5s20[1]-MAONs10[1];
    //--
    bool ma5xupn=(EMA5e02[0]>EMA5e02[1])&&(SMA5s20[0]>SMA5s20[1])&&(ma10620>=ma10621)&&((MAONs10[2]<MAONs62[2])&&(MAONs10[0]>MAONs62[0]));
    bool ma5xupc=(EMA5e02[0]>EMA5e02[1])&&(SMA5s20[0]>SMA5s20[1])&&(ma10620>=ma10621)&&(MAONs10[0]>MAONs62[0])&&(MAONs10[0]>MAONs10[1]);
    bool ma5xupb=(EMA5e02[0]>EMA5e02[1])&&(SMA5s20[0]>SMA5s20[1])&&(ma20100>ma20101)&&(MAONs62[0]>MAONs62[1])&&(SMA5s20[0]>MAONs10[0]);
    bool ma5xdnn=(EMA5e02[0]<EMA5e02[1])&&(SMA5s20[0]<SMA5s20[1])&&(ma10620<=ma10621)&&((MAONs10[2]>MAONs62[2])&&(MAONs10[0]<MAONs62[0]));
    bool ma5xdnc=(EMA5e02[0]<EMA5e02[1])&&(SMA5s20[0]<SMA5s20[1])&&(ma10620<=ma10621)&&(MAONs10[0]<MAONs62[0])&&(MAONs10[0]<MAONs10[1]);
    bool ma5xdna=(EMA5e02[0]<EMA5e02[1])&&(SMA5s20[0]<SMA5s20[1])&&(ma20100<ma20101)&&(MAONs62[0]<MAONs62[1])&&(SMA5s20[0]<MAONs10[0]);
    //--
    if(ma5xupn||ma5xupc||ma5xupb) {m5t=1;}
    if(ma5xdnn||ma5xdnc||ma5xdna) {m5t=-1;}
    //--
    return(m5t);
//----
  } //-end MA5Trend()
//---------//

bool CreateSetLable(long   chartid,
                    string _name, 
                    string _font_model,
                    int    _font_size,
                    color  _color,
                    string _obj_text,
                    int    _corner,
                    int    _xdist,
                    int    _ydist,
                    bool   _hidden)  
  { 
//--- 
    //--
    if(ObjectCreate(chart_id,_name,OBJ_LABEL,0,0,0,0,0))
      {
        //--
        ObjectSetString(chartid,_name,OBJPROP_TEXT,_obj_text);
        ObjectSetString(chartid,_name,OBJPROP_FONT,_font_model); 
        ObjectSetInteger(chartid,_name,OBJPROP_FONTSIZE,_font_size);
        ObjectSetInteger(chartid,_name,OBJPROP_COLOR,_color);
        ObjectSetInteger(chartid,_name,OBJPROP_CORNER,_corner);
        ObjectSetInteger(chartid,_name,OBJPROP_XDISTANCE,_xdist);
        ObjectSetInteger(chartid,_name,OBJPROP_YDISTANCE,_ydist);
        ObjectSetInteger(chartid,_name,OBJPROP_HIDDEN,_hidden);
      }
    else return(false);
    //--- successful execution 
    return(true);
    //--
  } //-end CreateSetLable()
//---------//

string FontsModel(int mode)
  { 
   string str_font;
   switch(mode) 
     { 
      case 0: str_font="Arial Black"; break;
      case 1: str_font="Bodoni MT Black"; break; 
     }
   //--
   return(str_font);
//----
  } //-end FontsModel()
//---------//

int Hours(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(hour)));
//---
  } //-end Hours()
//---------//

int Minutes(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(min)));
//---
  } //-end Minutes()
//---------//

int Seconds(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(sec)));
//---
  } //-end Seconds()
//---------//

enum TimeReturn
  {
//---
    year        = 0,   // Year 
    mon         = 1,   // Month 
    day         = 2,   // Day 
    hour        = 3,   // Hour 
    min         = 4,   // Minutes 
    sec         = 5,   // Seconds 
    day_of_week = 6,   // Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
    day_of_year = 7    // Day number of the year (January 1st is assigned the number value of zero) 
//---
  };
//---------//

int MqlReturnDateTime(datetime reqtime,
                      const int mode) 
  {
//---
    MqlDateTime mqltm;
    TimeToStruct(reqtime,mqltm);
    int valdate=0;
    //--
    switch(mode)
      {
        case 0: valdate=mqltm.year; break;        // Return Year 
        case 1: valdate=mqltm.mon;  break;        // Return Month 
        case 2: valdate=mqltm.day;  break;        // Return Day 
        case 3: valdate=mqltm.hour; break;        // Return Hour 
        case 4: valdate=mqltm.min;  break;        // Return Minutes 
        case 5: valdate=mqltm.sec;  break;        // Return Seconds 
        case 6: valdate=mqltm.day_of_week; break; // Return Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
        case 7: valdate=mqltm.day_of_year; break; // Return Day number of the year (January 1st is assigned the number value of zero) 
      }
    return(valdate);
//---
  } //-end MqlReturnDateTime()
//---------//
//+------------------------------------------------------------------+
//|                      Switch Time Frames                          |   
//+------------------------------------------------------------------+  
ENUM_TIMEFRAMES TF(int tf)
  {
//----
    switch(tf)
     {
      case 0:     return(PERIOD_CURRENT);
      case 1:     return(PERIOD_M1);
      case 5:     return(PERIOD_M5);
      case 15:    return(PERIOD_M15);
      case 30:    return(PERIOD_M30);
      case 60:    return(PERIOD_H1);
      case 240:   return(PERIOD_H4);
      case 1440:  return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      default:    return(PERIOD_CURRENT);
     }
//----
  } //-end ENUM_TIMEFRAMES()
//---------//

void doAlerts(string msgText,string eMailSub)
  {
//---
    //--
    Print(msgText);
    //--
    if(MsgAlerts) Alert(msgText);
    //--
    if(eMailAlerts==Yes) 
      SendMail(eMailSub,msgText);
    //--
    if(UseSendnotify==Yes) 
      SendNotification(msgText);
    //--
    return;
    //--
//---
  } //-end doAlerts()
//---------//

string strTF(ENUM_TIMEFRAMES tf)
  {
//---
   switch(tf)
     {
        case PERIOD_M1:  return("M1");
        case PERIOD_M5:  return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1:  return("H1");
        case PERIOD_H4:  return("H4");
        case PERIOD_D1:  return("D1");
        case PERIOD_W1:  return("W1");
        case PERIOD_MN1: return("MN");
     }
   //--
   return(EnumToString(tf));
//---
  } //-end strTF()
//---------//

void pos_alerts(int alert)
  {
//---
    //--
    crmnt=Minutes();
    if(crmnt!=prmnt)
      {
        //--
        if((cral!=pral)&&(alert==2))
           {     
             alBase=short_name+": "+Symbol()+", TF: "+strTF(Period())+" @ "+TimeToString(TimeLocal());
             alSubj=alBase+". The Price Began to Down,";
             alMsg=alSubj+" Action: Wait and See.!!";
             prmnt=crmnt;
             pral=cral;
             doAlerts(alMsg,alSubj);
           }
        //--
        if((cral!=pral)&&(alert==1))
          {     
            alBase=short_name+": "+Symbol()+", TF: "+strTF(Period())+" @ "+TimeToString(TimeLocal());
            alSubj=alBase+". The Price Goes Up,";
            alMsg=alSubj+" Action: Open BUY.!!";
            prmnt=crmnt;
            pral=cral;
             doAlerts(alMsg,alSubj);
          }
        //--
        if((cral!=pral)&&(alert==-2))
          {     
            alBase=short_name+": "+Symbol()+", TF: "+strTF(Period())+" @ "+TimeToString(TimeLocal());
            alSubj=alBase+". The Price Began to Up,";
            alMsg=alSubj+" Action: Wait and See.!!";
            prmnt=crmnt;
            pral=cral;
            doAlerts(alMsg,alSubj);
          }
        //--
        if((cral!=pral)&&(alert==-1))
          {     
            alBase=short_name+": "+Symbol()+", TF: "+strTF(Period())+" @ "+TimeToString(TimeLocal());
            alSubj=alBase+". The Price Goes Down,";
            alMsg=alSubj+" Action: Open SELL.!!";
            prmnt=crmnt;
            pral=cral;
            doAlerts(alMsg,alSubj);
          }
       //--
      }
    //--
    return;
//---
   } //-end pos_alerts()
//--------//

double NotZeroDiv(double val1,double val2)
  {
//----
   double resval=0;
   
   if(val1==0 || val2==0) resval=0.00;
   else
   resval=val1/val2;
   //--
   return(resval);
//----
  } //-end NotZeroDiv()
//---------//
//+------------------------------------------------------------------+