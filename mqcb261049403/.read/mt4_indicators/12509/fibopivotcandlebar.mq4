//+------------------------------------------------------------------+
//|                                           FiboPivotCandleBar.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015 - By 3RJ ~ Roy Philips-Jacobs ~ 15/01/2015"
#property link      "https://forge.mql5.io"
#property link      "http://www.gol2you.com ~ Forex Videos"
#property version   "3.00"
#property strict
#property indicator_chart_window
//--
#property description "This indicator is a composite of several forex indicators, Fibonacci, Pivot Point,"
#property description "ZigZag, MACD and Moving Average which are combined in this indicator."
#property description "This indicator gives advice to buy and sell with the direction of the arrow."
/* Update_01 (22/03/2015): Reduce false signals, simplifying the formula, 
   and replace the formula of the Stochastic indicator with MACD indicator.
   //--
   Update_02 (26/04/2015): Fix code for Price Retracement FiboCandleBar.
   //--
   Update_03 (18/05/2015): 
   ~ Added Alerts (Messages, Email dan Sound) to the indicator.
   ~ Improve the performance of the Indicator.
   //--
   Update_04 (16/06/2015):
   ~ Add Color Option, so that the user can change the color bar and font colors
   //--
   //--
   Update_05 (30/07/2015):
   ~ Make minor changes to the Pivot formula.
   ~ Remove unused variables.
   //--
   Update_06 (16/09/2015):
   ~ Add a formula to improve the accuracy of the signal.
   //--
   //--
   Update_07 (01/04/2017):
   ~ Fix syntax, according the latest updates MQL4.
   ~ Simplify the writing program.
   ~ Added Font model option.
   //--
*/
//--
enum fonts
  {
    Arial_Black,
    Bodoni_MT_Black
  };
//---
//--
input string FiboPivotCandleBar="Copyright © 2015 By 2RJ ~ Roberto Rosano Philips-Jacobs";
extern bool      SoundAlerts = true;
extern bool      MsgAlerts   = true;
extern bool      eMailAlerts = false;
extern string SoundAlertFile = "alert2.wav";
input fonts      Fonts_Model = Bodoni_MT_Black;   // Choose Fonts Model
extern color      FontColors = clrSnow;; // colors for font
extern color           BarUp = clrSnow; // color for Bar_Up and Bull Candle
extern color         BarDown = clrRed; // color for Bar_Down and Bear Candle
extern color       LineGraph = clrYellow; // color for Line Graph (if Price Close == Price Open)
extern color        EmptyBar = clrLightSlateGray; // If the bar has not been passed by the price movement
//--
//--
ENUM_BASE_CORNER corner=CORNER_RIGHT_LOWER;
int distance_x=157;
int distance_y=45;
int prztick=170;
int digit;
int arrpvt=20;
int font_size=8;
int font_size_OHLC=7;
color font_color;
string font_ohlc;
string font_face="Arial";
//--
double PvtO,PvtL,PvtH,PvtC,PvtO1,PvtL1,PvtH1,PvtC1;
double Pvt,PR1,PS1,PR2,PS2,PR3,PS3,PR4,PS4,PR5,PS5,PR6,PS6;
//-
double ema02m[];
double sma20m[];
double maon10[];
double maon62[];
//-
double pivot[];
double fibolvl[]={0.0,23.6,38.2,50.0,61.8};
string label[]={"S7","S6","S5","S4","S3","S2","SS1","S1","L20","L40","L60","L80","R1","SR1","R2","R3","R4","R5","R6","R7"};
             //  0    1    2    3    4     5    6     7     8     9    10    11   12    13   14   15   16   17   18   19
//--
ENUM_TIMEFRAMES
    prhh=PERIOD_M30,
    prh1=PERIOD_H1,
    prdp,
    prfb;
//--
int cral;
int pral;
int crmnt;
int prmnt;
//--
long chart_id;
string CopyRight;
string alBase,alSubj,alMsg;
//--
//--- bars minimum for calculation
#define DATA_LIMIT  200
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicators
   CopyRight="Copyright © 2015 By 2RJ ~ Roberto Rosano Philips-Jacobs";
   chart_id=ChartID();
//---
   //-- Checking the Digits Point
   if(Digits==3||Digits==5)
      {digit=Digits;}
   else {digit=Digits+1;}
   //--
   font_ohlc=FontsModel(Fonts_Model);
   font_color=FontColors;
//---
   //--
   IndicatorShortName("FiboPivotCandleBar ("+_Symbol+")");
   IndicatorDigits(digit);
   //--
   if(_Period==PERIOD_MN1) {prdp=PERIOD_MN1; prfb=PERIOD_D1;}
   if(_Period==PERIOD_W1) {prdp=PERIOD_W1; prfb=PERIOD_H4;}
   if(_Period<=PERIOD_D1) {prdp=PERIOD_D1; prfb=PERIOD_H1;}
   //--
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll();
   GlobalVariablesDeleteAll();   
//----
   return;
  }  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
  {
//--- Set Last error value to Zero
   ResetLastError();
   RefreshRates();
   if(FiboPivotCandleBar!=CopyRight) return(0);
   int limit,HiLo=108;
//--- check for rates total
   if(rates_total<=DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0) limit++;
   //--
   //--
   cral=0;
   int pstep=0;
   int cprz=5;
   int dlvl=5;
   int fstp=4;
   int bhl=19;
   int zzh1=0;
   int zzl1=0;
   int zhm1=0;
   int zlm1=0;
   int stax=0;
   //-
   color opsclr=0;
   color clrmove=0;
   color colordir=0;
   color fbarup=BarUp;
   color fbardn=BarDown;
   color fbarnt=LineGraph;
   color color_fbar=EmptyBar;
   //--
   bool ArrUp=false;
   bool ArrDn=false;
   bool opsup=false;
   bool opsdn=false;
   bool opsnt=false;
   //--
   string stdir;
   //--
   double himax=0;
   double lomin=0;
   double dfl=61.8;
   double barlvl[],przlvl[];
   //--
   ArrayResize(barlvl,dlvl);
   ArrayResize(fibolvl,dlvl);
   ArrayResize(przlvl,dlvl);
   ArrayResize(pivot,arrpvt);
   ArrayResize(label,arrpvt);
   //- Set the arrays as a series
   ArraySetAsSeries(barlvl,false);
   ArraySetAsSeries(przlvl,false);
   ArraySetAsSeries(fibolvl,false);
   ArraySetAsSeries(pivot,false);
   ArraySetAsSeries(label,false);
   //-
   RefreshRates();
   //--
   PvtO=iOpen(_Symbol,prdp,0);   
   PvtL=iLow(_Symbol,prdp,0);
   PvtH=iHigh(_Symbol,prdp,0);
   PvtC=Close[0];
   PvtL1=iLow(_Symbol,prdp,1);
   PvtH1=iHigh(_Symbol,prdp,1);
   PvtC1=iClose(_Symbol,prdp,1);
   PvtO1=iOpen(_Symbol,prdp,1);
   //--
   Pvt=(PvtH1+PvtL1+PvtC1)/3;
   //-
   double sup1=((Pvt*2)-PvtH1);          // support_1
   double res1=((Pvt*2)-PvtL1);          // resistance_1
   double disr=res1-sup1;                // distance R1 - S1
   double disl=disr*0.20;                // distance line
   //-
   pivot[19]=(Pvt*6)+(PvtH1)-(PvtL1*6);  // resistance_7
   pivot[18]=(Pvt*5)+(PvtH1)-(PvtL1*5);  // resistance_6
   pivot[17]=(Pvt*4)+(PvtH1)-(PvtL1*4);  // resistance_5
   pivot[16]=(Pvt*3)+(PvtH1)-(PvtL1*3);  // resistance_4
   pivot[15]=(Pvt*2)+(PvtH1)-(PvtL1*2);  // resistance_3
   pivot[14]=(Pvt+PvtH1-PvtL1);          // resistance_2
   pivot[13]=res1+(disl*0.618);          // strong_resistance_1
   pivot[12]=res1;                       // resistance_1
   pivot[11]=(sup1+(disr*0.8));          // point_80
   pivot[10]=(sup1+(disr*0.6));          // point_60
   pivot[9] =(sup1+(disr*0.4));          // point_40
   pivot[8] =(sup1+(disr*0.2));          // point_20
   pivot[7] =sup1;                       // support_1
   pivot[6]=sup1-(disl*0.618);           // strong_suppot_1
   pivot[5]=(Pvt-PvtH1+PvtL1);           // support_2
   pivot[4]=(Pvt*2)-((PvtH1*2)-(PvtL1)); // support_3
   pivot[3]=(Pvt*3)-((PvtH1*3)-(PvtL1)); // support_4
   pivot[2]=(Pvt*4)-((PvtH1*4)-(PvtL1)); // support_5
   pivot[1]=(Pvt*5)-((PvtH1*5)-(PvtL1)); // support_6
   pivot[0]=(Pvt*6)-((PvtH1*6)-(PvtL1)); // support_7
   //---
   //--
   //- prediction the price movements
   ArrayResize(ema02m,limit);
   ArrayResize(sma20m,limit);
   ArrayResize(maon10,limit);
   ArrayResize(maon62,limit);
   ArraySetAsSeries(ema02m,true);
   ArraySetAsSeries(sma20m,true);
   ArraySetAsSeries(maon10,true);
   ArraySetAsSeries(maon62,true);
   for(int j=99; j>=0; j--)
     {ema02m[j]=iMA(_Symbol,cprz,2,0,1,4,j);}
   for(int k=99; k>=0; k--)
     {sma20m[k]=iMA(_Symbol,cprz,20,0,0,4,k);}
   for(int q=99; q>=0; q--)
     {maon10[q]=iMAOnArray(sma20m,0,10,0,0,q);}
   for(int m=99; m>=0; m--)
     {maon62[m]=iMAOnArray(sma20m,0,62,0,0,m);}
   double ma10620=maon10[0]-maon62[0];
   double ma10621=maon10[1]-maon62[1];
   double ma20100=sma20m[0]-maon10[0];
   double ma20101=sma20m[1]-maon10[1];
   //-
   bool ma5xupn=(ema02m[0]>ema02m[1])&&(sma20m[0]>sma20m[1])&&(ma10620>=ma10621)&&((maon10[2]<maon62[2])&&(maon10[0]>maon62[0]));
   bool ma5xupc=(ema02m[0]>ema02m[1])&&(sma20m[0]>sma20m[1])&&(ma10620>=ma10621)&&(maon10[0]>maon62[0])&&(maon10[0]>maon10[1]);
   bool ma5xupb=(ema02m[0]>ema02m[1])&&(sma20m[0]>sma20m[1])&&(ma20100>ma20101)&&(maon62[0]>maon62[1])&&(sma20m[0]>maon10[0]);
   bool ma5xdnn=(ema02m[0]<ema02m[1])&&(sma20m[0]<sma20m[1])&&(ma10620<=ma10621)&&((maon10[2]>maon62[2])&&(maon10[0]<maon62[0]));
   bool ma5xdnc=(ema02m[0]<ema02m[1])&&(sma20m[0]<sma20m[1])&&(ma10620<=ma10621)&&(maon10[0]<maon62[0])&&(maon10[0]<maon10[1]);
   bool ma5xdna=(ema02m[0]<ema02m[1])&&(sma20m[0]<sma20m[1])&&(ma20100<ma20101)&&(maon62[0]<maon62[1])&&(sma20m[0]<maon10[0]);
   //-
   for(int zz=99; zz>=0; zz--) //- for(zz)
     {
       //--
       if(iHigh(_Symbol,prh1,zz)==iCustom(_Symbol,prh1,"ZigZag",1,zz))
         {zzh1=zz;}
       if(iLow(_Symbol,prh1,zz)==iCustom(_Symbol,prh1,"ZigZag",2,zz))
         {zzl1=zz;}
       //-
       if(iHigh(_Symbol,prhh,zz)==iCustom(_Symbol,prhh,"ZigZag",1,zz))
         {zhm1=zz;}
       if(iLow(_Symbol,prhh,zz)==iCustom(_Symbol,prhh,"ZigZag",2,zz))
         {zlm1=zz;}
       //--
     } //-end for(zz)
   //-
   RefreshRates();
   //-
   double macd0=iMACD(_Symbol,prh1,12,26,9,0,0,0)-iMACD(_Symbol,prh1,12,26,9,0,1,0);
   double macd1=iMACD(_Symbol,prh1,12,26,9,0,0,1)-iMACD(_Symbol,prh1,12,26,9,0,1,1);
   double mcdm0=iMACD(_Symbol,prh1,12,26,9,0,0,0);
   double mcdm1=iMACD(_Symbol,prh1,12,26,9,0,0,1);
   double mcds0=iMACD(_Symbol,prh1,12,26,9,0,1,0);
   double mcds1=iMACD(_Symbol,prh1,12,26,9,0,1,1);
   //-
   if((((zzl1<zzh1)&&(zzl1>0)&&(zzl1<4)&&(zlm1<zhm1)))||((macd0>macd1)&&(mcdm0>mcdm1))) 
     {ArrUp=true;}
   if((((zzl1>zzh1)&&(zzh1>0)&&(zzh1<4)&&(zlm1>zhm1)))||((macd0<macd1)&&(mcdm0<mcdm1))) 
     {ArrDn=true;}
   if(((ArrUp==true)&&(zzl1>4))||((mcdm0<mcdm1)&&(macd0<macd1))) {ArrDn=true; ArrUp=false;}
   if(((ArrDn==true)&&(zzh1>4))||((mcdm0>mcdm1)&&(macd0>macd1))) {ArrUp=true; ArrDn=false;}
   if((mcdm0>=mcdm1)&&(mcdm0>mcds0)&&(mcds0>mcds1)) {ArrUp=true; ArrDn=false;}
   if((mcdm0<=mcdm1)&&(mcdm0<mcds0)&&(mcds0<mcds1)) {ArrDn=true; ArrUp=false;}
   if(ma5xupn||ma5xupc||ma5xupb) {ArrUp=true; ArrDn=false;}
   if(ma5xdnn||ma5xdnc||ma5xdna) {ArrDn=true; ArrUp=false;}
   //-
   double fpCls0=(iHigh(_Symbol,prh1,0)+iLow(_Symbol,prh1,0)+iClose(_Symbol,prh1,0)+iClose(_Symbol,prh1,0))/4;
   double fpCls1=(iHigh(_Symbol,prh1,1)+iLow(_Symbol,prh1,1)+iClose(_Symbol,prh1,1)+iClose(_Symbol,prh1,1))/4;
   double hlcc0=fpCls0-iMA(_Symbol,prh1,20,0,0,4,0);
   double hlcc1=fpCls1-iMA(_Symbol,prh1,20,0,0,4,1);
   //-
   //- prepare the braking movement
   //-
   if((ArrUp==true)&&(hlcc0>hlcc1))
     {opsup=true; stax=18; stdir="BUY"; opsclr=fbarup;}
   if((ArrDn==true)&&(hlcc0<hlcc1))
     {opsdn=true; opsup=false; stax=22; stdir="SELL"; opsclr=fbardn;}
   if((!opsup)&&(!opsdn))
     {opsnt=true; opsup=false; opsdn=false; opsclr=fbarnt;}
   //-
   //-- prepare the Fibo Highest and Lowest Price
   int inH=iHighest(_Symbol,prfb,MODE_HIGH,HiLo,0);
   int inL=iLowest(_Symbol,prfb,MODE_LOW,HiLo,0);
   if(inH!=-1) himax=iHigh(_Symbol,prfb,inH);
   if(inL!=-1) lomin=iLow(_Symbol,prfb,inL);
   if((PvtH<=pivot[12])&&(PvtL>=pivot[7])) {himax=pivot[12]; lomin=pivot[7];}
   //double dayHi=MarketInfo(_Symbol,MODE_HIGH);
   //double dayLo=MarketInfo(_Symbol,MODE_LOW);
   double dayHi=PvtH;
   double dayLo=PvtL;
   //-
   for(int g=0; g<dlvl; g++) 
     {
       //--
       barlvl[g]=prztick/dfl*fibolvl[g];
       przlvl[g]=lomin+(((himax-lomin)/dfl)*fibolvl[g]);
       //--
     }   
   //--
   RefreshRates();
   PvtC=Close[0];
   //-
   int pso=0;
   int psh=0;
   int psl=0;
   int pst=0;
   int fbar0=int(barlvl[1]-barlvl[0]);
   int fbar1=int(barlvl[2]-barlvl[1]);
   int fbar2=int(barlvl[3]-barlvl[2]);
   int fbar3=int(barlvl[4]-barlvl[3]);
   int fbajs=prztick-(fbar0+fbar1+fbar2+fbar3);
   //-
   if((PvtO>=przlvl[0])&&(PvtO<=przlvl[1]))
     {double fpo10=(PvtO-przlvl[0])/(przlvl[1]-przlvl[0]); pso=int((fpo10*fbar0)+fbajs);}
   if((PvtO>=przlvl[1])&&(PvtO<=przlvl[2]))
     {double fpo21=(PvtO-przlvl[1])/(przlvl[2]-przlvl[1]); pso=int(fbar0+(fpo21*fbar1)+fbajs);}
   if((PvtO>=przlvl[2])&&(PvtO<=przlvl[3]))
     {double fpo32=(PvtO-przlvl[2])/(przlvl[3]-przlvl[2]); pso=int(fbar0+fbar1+(fpo32*fbar2)+fbajs);}
   if((PvtO>=przlvl[3])&&(PvtO<=przlvl[4]))
     {double fpo43=(PvtO-przlvl[3])/(przlvl[4]-przlvl[3]); pso=int(fbar0+fbar1+fbar2+(fpo43*fbar3)+fbajs);}
   //-
   if((PvtH>=przlvl[0])&&(PvtH<=przlvl[1]))
     {double fph10=(PvtH-przlvl[0])/(przlvl[1]-przlvl[0]); psh=int((fph10*fbar0)+fbajs);}
   if((PvtH>=przlvl[1])&&(PvtH<=przlvl[2]))
     {double fph21=(PvtH-przlvl[1])/(przlvl[2]-przlvl[1]); psh=int(fbar0+(fph21*fbar1)+fbajs);}
   if((PvtH>=przlvl[2])&&(PvtH<=przlvl[3]))
     {double fph32=(PvtH-przlvl[2])/(przlvl[3]-przlvl[2]); psh=int(fbar0+fbar1+(fph32*fbar2)+fbajs);}
   if((PvtH>=przlvl[3])&&(PvtH<=przlvl[4]))
     {double fph43=(PvtH-przlvl[3])/(przlvl[4]-przlvl[3]); psh=int(fbar0+fbar1+fbar2+(fph43*fbar3)+fbajs);}
   //-
   if((PvtL>=przlvl[0])&&(PvtL<=przlvl[1]))
     {double fpl10=(PvtL-przlvl[0])/(przlvl[1]-przlvl[0]); psl=int((fpl10*fbar0)+fbajs);}
   if((PvtL>=przlvl[1])&&(PvtL<=przlvl[2]))
     {double fpl21=(PvtL-przlvl[1])/(przlvl[2]-przlvl[1]); psl=int(fbar0+(fpl21*fbar1)+fbajs);}
   if((PvtL>=przlvl[2])&&(PvtL<=przlvl[3]))
     {double fpl32=(PvtL-przlvl[2])/(przlvl[3]-przlvl[2]); psl=int(fbar0+fbar1+(fpl32*fbar2)+fbajs);}
   if((PvtL>=przlvl[3])&&(PvtL<=przlvl[4]))
     {double fpl43=(PvtL-przlvl[3])/(przlvl[4]-przlvl[3]); psl=int(fbar0+fbar1+fbar2+(fpl43*fbar3)+fbajs);}
   //-   
   if((PvtC>=przlvl[0])&&(PvtC<=przlvl[1]))
     {double fpb10=(PvtC-przlvl[0])/(przlvl[1]-przlvl[0]); pst=int((fpb10*fbar0)+fbajs);}
   if((PvtC>=przlvl[1])&&(PvtC<=przlvl[2]))
     {double fpb21=(PvtC-przlvl[1])/(przlvl[2]-przlvl[1]); pst=int(fbar0+(fpb21*fbar1)+fbajs);}
   if((PvtC>=przlvl[2])&&(PvtC<=przlvl[3]))
     {double fpb32=(PvtC-przlvl[2])/(przlvl[3]-przlvl[2]); pst=int(fbar0+fbar1+(fpb32*fbar2)+fbajs);}
   if((PvtC>=przlvl[3])&&(PvtC<=przlvl[4]))
     {double fpb43=(PvtC-przlvl[3])/(przlvl[4]-przlvl[3]); pst=int(fbar0+fbar1+fbar2+(fpb43*fbar3)+fbajs);}
   int fbbar=psh-psl;
   //-
   bool pvths=false;
   int hb=0,ht=0,lb=0,lt=0;
   int ob=0,ot=0;
   int tb=0,tt=0;
   int bb=0,bt=0;
   int cb=0,ct=0;
   //--
   for(int b=0; b<=bhl; b++)
     {
       //--
       if((PvtO>=pivot[b])&&(PvtO<pivot[b+1])) {ob=b; ot=b+1;}
       if((PvtH>=pivot[b])&&(PvtH<pivot[b+1])) {tb=b; tt=b+1;}
       if((PvtL>=pivot[b])&&(PvtL<pivot[b+1])) {bb=b; bt=b+1;}
       if((PvtC>=pivot[b])&&(PvtC<pivot[b+1])) {cb=b; ct=b+1;}
       if((PvtH<=pivot[12])&&(PvtL>=pivot[7])) 
         {pvths=true; hb=11; ht=12; lb=7; lt=8;}
       else {pvths=false; hb=tb; ht=tt; lb=bb; lt=bt;}
       //--
     }
   //--
   if(ht-lb<5) {ht=lb+5;}
   pstep=ht-lb;
   int pvtlvl=prztick/pstep;
   //--
   double barop=((PvtO-pivot[ob])/(pivot[ot]-pivot[ob])*pvtlvl)+((ob-lb)*pvtlvl);
   double barhi=((PvtH-pivot[tb])/(pivot[tt]-pivot[tb])*pvtlvl)+((tb-lb)*pvtlvl);
   double barcl=((PvtC-pivot[cb])/(pivot[ct]-pivot[cb])*pvtlvl)+((cb-lb)*pvtlvl);
   double barlo=((PvtL-pivot[bb])/(pivot[bt]-pivot[bb])*pvtlvl);
   if(pvths==true) {barlo=((PvtL-pivot[bb])/(pivot[bt]-pivot[bb])*pvtlvl)+((bb-lb)*pvtlvl);}
   int candclu=0,
       candcld=0;
   int candlo=(int)barlo;
   int candhi=(int)barhi+2;
   int candop=(int)barop+1;
   int candcl=(int)barcl;
   int candbar=candhi-candlo;
   if(PvtC>PvtO) {candclu=candcl-candop+1; clrmove=fbarup;}
   if(PvtC<PvtO) {candcld=candop-candcl; clrmove=fbardn;}
   if(PvtC==PvtO) {clrmove=fbarnt;}
   //--
   for(int d=0; d<=bhl; d++) 
     {
       ObjectDelete(chart_id,"PivotLevel_"+string(d));
       ObjectDelete(chart_id,"PivotLableLevel_"+string(d));
     }
   //--
   for(int s=0; s<=prztick; s++) 
     {
       ObjectDelete(chart_id,"PivotBar"+string(s));
       ObjectDelete(chart_id,"CloseBar"+string(s));
       ObjectDelete(chart_id,"PivotBarNt"+string(s));
     }
   //--
   ObjectDelete(chart_id,"PivotDir");
   //--
   for(int r=0; r<=pstep; r++)
     {
       //-- Create Pivot Bar Levels
       string plevel=CharToString(45)+DoubleToString(pivot[lb+r],digit);
       CreateSetLable(chart_id,"PivotLevel_"+string(r),font_face,font_size,font_color,plevel,
                      corner,distance_x-109,distance_y+r*pvtlvl,true);
       //--
       string llevel=label[lb+r]+CharToString(45); 
       int disc=StringLen(llevel)>3?0:5;
       CreateSetLable(chart_id,"PivotLableLevel_"+string(r),font_face,font_size,font_color,llevel,
                      corner,distance_x-53-disc,distance_y+r*pvtlvl,true);         
       //--
       if(r==pstep)
         {
           //--
           for(int pv=0; pv<prztick; pv++)
             {
               //--
               CreateSetLable(chart_id,"PivotBarNt"+string(pv),font_face,font_size,color_fbar,CharToString(45),
                              corner,distance_x-90,distance_y-1+pv,true);
               //--
             }
           //--
           for(int i=0; i<candbar; i++)
              {
                //--
                CreateSetLable(chart_id,"PivotBar"+string(i),font_face,font_size,clrmove,CharToString(45),
                               corner,distance_x-90,distance_y+candlo+1+i,true);
                //--
              }
           //--
           if(PvtC>PvtO)
             {
               for(int v=0; v<candclu; v++)
                 {
                   //--
                   string clsbaru=CharToString(151)+CharToString(151)+CharToString(151);
                   CreateSetLable(chart_id,"CloseBar"+string(v),font_face,font_size,clrmove,clsbaru,
                                  corner,distance_x-76,distance_y+candop+1+v,true);
                   //--
                 }
             }
           //--
           if(PvtC<PvtO)
             {
               for(int v=0; v<candcld; v++)
                 {
                   //--
                   string clsbard=CharToString(151)+CharToString(151)+CharToString(151);
                   CreateSetLable(chart_id,"CloseBar"+string(v),font_face,font_size,clrmove,clsbard,
                                  corner,distance_x-76,distance_y+candcl+1+v,true);
                   //--
                 }
             }
           //--
           if(PvtC==PvtO)
             {
               for(int v=0; v<2; v++)
                 {
                   //--
                   string clsbar=CharToString(151)+CharToString(151)+CharToString(151);     
                   CreateSetLable(chart_id,"CloseBar"+string(v),font_face,font_size,clrmove,clsbar,
                                  corner,distance_x-76,distance_y+candop+1+v,true);              
                   //--
                 }
             }
           //--
         }
       //--
     }
   //--
   for(int n=0; n<dlvl; n++)
     {
       //--
       ObjectDelete(chart_id,"FiboBarLevel_"+string(n));
       ObjectDelete(chart_id,"FiboBar_"+string(n));
       //--
     }
   //--
   for(int db=0; db<prztick; db++)
     {
       ObjectDelete(chart_id,"FiboBar"+string(db));
       ObjectDelete(chart_id,"FiboBar_cu"+string(db));
       ObjectDelete(chart_id,"FiboBar_cd"+string(db));
       ObjectDelete(chart_id,"FiboBar_nt"+string(db));
       ObjectDelete(chart_id,"FiboBarUph"+string(db));
       ObjectDelete(chart_id,"FiboBarDnl"+string(db));
       ObjectDelete(chart_id,"FiboBar_cln"+string(db));
       ObjectDelete(chart_id,"FiboBar_clu"+string(db));
       ObjectDelete(chart_id,"FiboBar_cld"+string(db));
     }
   //--
   ObjectDelete(chart_id,"FiboDir");
   ObjectDelete(chart_id,"PivotDir");
   ObjectDelete(chart_id,"PivotStr");
   //---
   for(int n=0; n<dlvl; n++)
     {
       //--
       string fibbar=CharToString(45)+DoubleToString(przlvl[n],digit);
       CreateSetLable(chart_id,"FiboBar_"+string(n),font_face,font_size,font_color,fibbar,
                      corner,distance_x-7,distance_y+fbajs+(int)barlvl[n]-1,true);
       //--
       string fiblevel=DoubleToString(fibolvl[n],1)+CharToString(45);
       CreateSetLable(chart_id,"FiboBarLevel_"+string(n),font_face,font_size,font_color,fiblevel,
                      corner,distance_x+51,distance_y+fbajs+(int)barlvl[n]-1,true);
       //--
       //--
       if(n==fstp)
         {
           //--
           for(int fb=0; fb<prztick; fb++)
             {
               //--
               CreateSetLable(chart_id,"FiboBar"+string(fb),font_face,font_size,color_fbar,CharToString(45),
                              corner,distance_x+12,distance_y+fbajs+fb-1,true);
               //--
             }
           //--
           if(PvtC<PvtO)
             {
               //--
               for(int l=0; l<=psh-psl; l++)
                 {
                   //--
                   CreateSetLable(chart_id,"FiboBar_cd"+string(l),font_face,font_size,clrmove,CharToString(45),
                                  corner,distance_x+12,distance_y+fbajs+psl+l-1,true);
                   //--
                 }
               //-
               for(int fl=0; fl<pso-pst+1; fl++)
                 {
                   //--
                   string fibcld=CharToString(151)+CharToString(151)+CharToString(151);
                   CreateSetLable(chart_id,"FiboBar_cld"+string(fl),font_face,font_size,fbardn,fibcld,
                                  corner,distance_x+26,distance_y+fbajs+pst+fl-1,true);
                   //--
                 }              
               //--
             }
           //--
           if(PvtC>PvtO)
             {
               //--
               for(int l=0; l<=psh-psl; l++)
                 {
                   //--
                   CreateSetLable(chart_id,"FiboBar_cu"+string(l),font_face,font_size,clrmove,CharToString(45),
                                  corner,distance_x+12,distance_y+fbajs+psl+l-1,true);
                   //--
                 }       
               //-
               for(int fl=0; fl<pst-pso+1; fl++)
                 {
                   //--
                   string fibclu=CharToString(151)+CharToString(151)+CharToString(151);
                   CreateSetLable(chart_id,"FiboBar_clu"+string(fl),font_face,font_size,fbarup,fibclu,
                                  corner,distance_x+26,distance_y+fbajs+pso+fl-1,true);
                   //--
                 }                 
               //--
             }
           //--
           if(PvtC==PvtO)
             {
               //--
               for(int l=0; l<=psh-psl; l++)
                 {
                   //--
                   CreateSetLable(chart_id,"FiboBar_nt"+string(l),font_face,font_size,fbarnt,CharToString(45),
                                  corner,distance_x+12,distance_y+fbajs+psl+l-1,true);
                   //--
                 }
               //-
               for(int fl=0; fl<2; fl++)
                 {
                   //--
                   string fibcln=CharToString(151)+CharToString(151)+CharToString(151);
                   CreateSetLable(chart_id,"FiboBar_cln"+string(fl),font_face,font_size,fbarnt,fibcln,
                                  corner,distance_x+26,distance_y+fbajs+pso+fl-1,true);
                   //--
                 }
               //--
             }
           //--
           if(ArrUp==true)
             {
               //--
               if((PvtL==dayLo)&&(PvtC>dayLo))
                 {
                   //--
                   cral=-2;
                   for(int bd=0; bd<pst-psl; bd++)
                     {
                       CreateSetLable(chart_id,"FiboBarDnl"+string(bd),font_face,font_size,fbarup,CharToString(45),
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
               if((PvtH==dayHi)&&(PvtC<dayHi))
                 {
                   //--
                   cral=2;
                   for(int bu=0; bu<psh-pst; bu++)
                     {
                       CreateSetLable(chart_id,"FiboBarUph"+string(bu),font_face,font_size,fbardn,CharToString(45),
                                      corner,distance_x+12,distance_y+1+fbajs+pst+bu-1,true);
                     }
                   //--
                 }
               //--
               if(opsdn==true) cral=-1;
               //--
             }
           //--
         }
       //--
     }
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
   WindowRedraw();
   Sleep(500);
   RefreshRates();
   //---
//---
   return(0);
  } //--Done!
//+------------------------------------------------------------------+

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

void CreateSetLable(long   chartid,
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
    //--
    if(ObjectCreate(chartid,_name,OBJ_LABEL,0,0,0,0,0)) // create the obj_lable
      { 
        ObjectSetInteger(chartid,_name,OBJPROP_FONTSIZE,_font_size); 
        ObjectSetString(chartid,_name,OBJPROP_FONT,_font_model);
        ObjectSetString(chartid,_name,OBJPROP_TEXT,_obj_text);
        ObjectSetInteger(chartid,_name,OBJPROP_COLOR,_color);
        ObjectSetInteger(chartid,_name,OBJPROP_CORNER,_corner);
        ObjectSetInteger(chartid,_name,OBJPROP_XDISTANCE,_xdist);
        ObjectSetInteger(chartid,_name,OBJPROP_YDISTANCE,_ydist);
        ObjectSetInteger(chartid,_name,OBJPROP_HIDDEN,_hidden);
      } 
    else 
      {Print("Failed to create the object OBJ_LABEL ",_name,", Error code = ", GetLastError());}
    //--
  }   
//---------//

void doAlerts(string msgText,string eMailSub)
  {
    //--
    if(MsgAlerts) Alert(msgText);
    if(SoundAlerts) PlaySound(SoundAlertFile);
    if(eMailAlerts) SendMail(eMailSub,msgText);
    //--
  }
//---/

//---/
string strTF(int period)
  {
   switch(period)
     {
       //--
       case PERIOD_M1: return("M1");
       case PERIOD_M5: return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1: return("H1");
       case PERIOD_H4: return("H4");
       case PERIOD_D1: return("D1");
       case PERIOD_W1: return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return((string)period);
  }  
//---/

void pos_alerts(int alert)
   {
     //--
     crmnt=(int)Minute();
     if(crmnt!=prmnt)
       {
         //--
         if((cral!=pral)&&(alert==2))
            {     
              alBase=StringConcatenate("FiboPivotCandleBar: ",_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
              alSubj=StringConcatenate(alBase,". The Price Began to Down,");
              alMsg=StringConcatenate(alSubj," Action: Wait and See.!!");
              prmnt=crmnt;
              pral=cral;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cral!=pral)&&(alert==1))
            {     
              alBase=StringConcatenate("FiboPivotCandleBar: ",_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
              alSubj=StringConcatenate(alBase,". The Price Goes Up,");
              alMsg=StringConcatenate(alSubj," Action: Open BUY.!!");
              prmnt=crmnt;
              pral=cral;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cral!=pral)&&(alert==-2))
            {     
              alBase=StringConcatenate("FiboPivotCandleBar: ",_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
              alSubj=StringConcatenate(alBase,". The Price Began to Up,");
              alMsg=StringConcatenate(alSubj," Action: Wait and See.!!");
              prmnt=crmnt;
              pral=cral;
              doAlerts(alMsg,alSubj);
            }
         //--
         if((cral!=pral)&&(alert==-1))
            {     
              alBase=StringConcatenate("FiboPivotCandleBar: ",_Symbol,", TF: ",strTF(_Period)," @ ",TimeToStr(TimeLocal()));
              alSubj=StringConcatenate(alBase,". The Price Goes Down,");
              alMsg=StringConcatenate(alSubj," Action: Open SELL.!!");
              prmnt=crmnt;
              pral=cral;
              doAlerts(alMsg,alSubj);
            }
         //--
       }
     //--
     return;
     //--
   //----
   } //-end pos_alerts()
//---/
//+------------------------------------------------------------------+