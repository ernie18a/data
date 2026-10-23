//+------------------------------------------------------------------+
//|                                         Spectrometr_Separate.mq5 | 
///|                                  Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 8 
//---- only eight graphical plots are used
#property indicator_plots   8
//+-----------------------------------+
//|  Indicators drawing parameters    |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- the following colors are used for the indicators
#property indicator_color1 clrRed
#property indicator_color2 clrOrange
#property indicator_color3 clrYellow
#property indicator_color4 clrLime
#property indicator_color5 clrBlue
#property indicator_color6 clrDodgerBlue
#property indicator_color7 clrDarkViolet
#property indicator_color8 clrDimGray
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_style4  STYLE_SOLID
#property indicator_style5  STYLE_SOLID
#property indicator_style6  STYLE_SOLID
#property indicator_style7  STYLE_SOLID
#property indicator_style8  STYLE_SOLID

//---- displaying the indicator label
#property indicator_label1  "Wave 1";
#property indicator_label2  "Wave 2";
#property indicator_label3  "Wave 3";
#property indicator_label4  "Wave 4";
#property indicator_label5  "Wave 5";
#property indicator_label6  "Wave 6";
#property indicator_label7  "Wave 7";
#property indicator_label8  "Wave 8";
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input ENUM_TIMEFRAMES iPeriod=PERIOD_H4;   // indicator time frame
input int       iStartFrom=0;
input string    AddToObjName="1";
input color     HandlerColor=clrGray;
input color     TextColor=clrBlueViolet;
//+-----------------------------------+

//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
//----
int LastLeftBar;
int LastRightBar;
//----
string ObjNPref;
string ShortName;
//----
int Wind;
int nPeriod;
int nStartFrom;
double A[],B[],R[],F[];
//+------------------------------------------------------------------+
//|  One indicator initialization                                    |
//+------------------------------------------------------------------+
void IndicatorInit(int Number,double &IndArray[],int DrawBegin,double EmptyValue,int Shift)
  {
//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(Number,IndArray,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(Number,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,DrawBegin);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,EmptyValue);
//---- indexing buffer elements as time series   
   ArraySetAsSeries(IndArray,true);
//----
  }
//+------------------------------------------------------------------+
//|  shifting the starting point of the indicator drawing            |
//+------------------------------------------------------------------+
void IndicatorsDrawBegin(int DrawBegin)
  {
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,DrawBegin);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,DrawBegin);
//----
  }
//+------------------------------------------------------------------+   
//| Spectrometr_Separate indicator initialization function           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initializations of variable for indicator short name
   ShortName="Spectrometr"+"_"+AddToObjName;

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);

//---- Initialization of variables  
   ObjNPref=ShortName+"_";

//---- Initialization of variables of the start of data calculation
   nStartFrom=iStartFrom;
   min_rates_total=nStartFrom+nPeriod-1;
   Wind=ChartWindowFind(0,ShortName);
   nPeriod=PeriodSeconds(iPeriod)/60;
   

//---- initialize indicator buffers
   IndicatorInit(0,ExtMapBuffer1,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(1,ExtMapBuffer2,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(2,ExtMapBuffer3,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(3,ExtMapBuffer4,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(4,ExtMapBuffer5,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(5,ExtMapBuffer6,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(6,ExtMapBuffer7,min_rates_total,EMPTY_VALUE,0);
   IndicatorInit(7,ExtMapBuffer8,min_rates_total,EMPTY_VALUE,0);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   ObjDeleteByPrefix(ObjNPref);
//----
  }
//+------------------------------------------------------------------+ 
//| Spectrometr_Separate iteration function                          | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[]     // price array for calculation of the indicator
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total+begin) return(RESET);

//---- declaration of local variables 
   datetime Time0[1],TimeL[1],TimeR[1];
   string ObjName;
   double Arr[];
   int N,bar,Per60;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(price,true);

   if(CopyTime(Symbol(),PERIOD_CURRENT,0,1,Time0)<=0) return(RESET);

   ObjName=ObjNPref+"Null line";
   LastLeftBar=nStartFrom+nPeriod-1;
   LastRightBar=nStartFrom;

   if(CopyTime(Symbol(),PERIOD_CURRENT,LastLeftBar,1,TimeL)<=0) return(RESET);
   if(CopyTime(Symbol(),PERIOD_CURRENT,LastRightBar,1,TimeR)<=0) return(RESET);

   SetTline(0,ObjName,Wind,TimeR[0],0,TimeL[0],0,HandlerColor,STYLE_SOLID,1,true);
//---- 

   fLinearRegressionAll2(nStartFrom,nStartFrom+nPeriod-1,Arr,price);
//---- 
   fFurie(Arr,A,B,R,F);

   N=MathMax(ArraySize(Arr),2);
   IndicatorsDrawBegin(rates_total-N+1);
//---- main indicator calculation loop
   for(int i=0; i<N && !IsStopped(); i++)
     {
      bar=i+iStartFrom;
      ExtMapBuffer1[bar]=A[0]*MathSin(1*6.28*i/(N-1))+B[0]*MathCos(1*6.28*i/(N-1));
      ExtMapBuffer2[bar]=A[1]*MathSin(2*6.28*i/(N-1))+B[1]*MathCos(2*6.28*i/(N-1));
      ExtMapBuffer3[bar]=A[2]*MathSin(3*6.28*i/(N-1))+B[2]*MathCos(3*6.28*i/(N-1));
      ExtMapBuffer4[bar]=A[3]*MathSin(4*6.28*i/(N-1))+B[3]*MathCos(4*6.28*i/(N-1));
      ExtMapBuffer5[bar]=A[4]*MathSin(5*6.28*i/(N-1))+B[4]*MathCos(5*6.28*i/(N-1));
      ExtMapBuffer6[bar]=A[5]*MathSin(6*6.28*i/(N-1))+B[5]*MathCos(6*6.28*i/(N-1));
      ExtMapBuffer7[bar]=A[6]*MathSin(7*6.28*i/(N-1))+B[6]*MathCos(7*6.28*i/(N-1));
      ExtMapBuffer8[bar]=A[7]*MathSin(8*6.28*i/(N-1))+B[7]*MathCos(8*6.28*i/(N-1));
     }

   for(bar=0; bar<iStartFrom && !IsStopped(); bar++)
     {
      ExtMapBuffer1[bar]=EMPTY_VALUE;
      ExtMapBuffer2[bar]=EMPTY_VALUE;
      ExtMapBuffer3[bar]=EMPTY_VALUE;
      ExtMapBuffer4[bar]=EMPTY_VALUE;
      ExtMapBuffer5[bar]=EMPTY_VALUE;
      ExtMapBuffer6[bar]=EMPTY_VALUE;
      ExtMapBuffer7[bar]=EMPTY_VALUE;
      ExtMapBuffer8[bar]=EMPTY_VALUE;
     }
//---- 
   Per60=PeriodSeconds();
   datetime timeX1=Time0[0]+Per60*3;
   color Color1=color(PlotIndexGetInteger(1,PLOT_LINE_COLOR,0));

   datetime timeX2=Time0[0]+Per60*5;
   color Color2=color(PlotIndexGetInteger(2,PLOT_LINE_COLOR,0));

   datetime timeX3=Time0[0]+Per60*7;
   color Color3=color(PlotIndexGetInteger(3,PLOT_LINE_COLOR,0));

   datetime timeX4=Time0[0]+Per60*9;
   color Color4=color(PlotIndexGetInteger(4,PLOT_LINE_COLOR,0));

   datetime timeX5=Time0[0]+Per60*11;
   color Color5=color(PlotIndexGetInteger(5,PLOT_LINE_COLOR,0));

   datetime timeX6=Time0[0]+Per60*13;
   color Color6=color(PlotIndexGetInteger(6,PLOT_LINE_COLOR,0));

   datetime timeX7=Time0[0]+Per60*15;
   color Color7=color(PlotIndexGetInteger(7,PLOT_LINE_COLOR,0));

   datetime timeX8=Time0[0]+Per60*17;
   color Color8=color(PlotIndexGetInteger(8,PLOT_LINE_COLOR,0));

   SetTline(0,ObjNPref+"1",Wind,timeX1,R[1],timeX1,-R[1],Color1,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"2",Wind,timeX2,R[2],timeX2,-R[2],Color2,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"3",Wind,timeX3,R[3],timeX3,-R[3],Color3,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"4",Wind,timeX4,R[4],timeX4,-R[4],Color4,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"5",Wind,timeX5,R[5],timeX5,-R[5],Color5,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"6",Wind,timeX6,R[6],timeX6,-R[6],Color6,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"7",Wind,timeX7,R[7],timeX7,-R[7],Color7,STYLE_SOLID,8,false);
   SetTline(0,ObjNPref+"8",Wind,timeX8,R[8],timeX8,-R[8],Color8,STYLE_SOLID,8,false);
//----         
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 double   price1,        // price level 1
 datetime time2,         // price level time 2
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 bool     back           // background display
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,back);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 double   price1,        // price level 1
 datetime time2,         // price level time 2
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 bool     back           // background display
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,back);
   else
     {
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_BACK,back);
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjDeleteByPrefix(string aPrefix)
  {
//----
   for(int i=ObjectsTotal(0,Wind)-1; i>=0; i--)
      if(StringFind(ObjectName(0,i,Wind,-1),aPrefix,0)==0) ObjectDelete(0,ObjectName(0,i,Wind,-1));
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fMyArcTan(double aS,double aC)
  {
//----
   if(!aS) return(0);

   if(!aC)
     {
      if(aS>0) return(MathArctan(1)*2);
      else if(aS<0) return(MathArctan(1)*6);
     }
   else
     {
      if(aS>0)
        {
         if(aC>0) return(MathArctan(aS/aC));
         else return(MathArctan(aS/aC)+MathArctan(1)*4);
        }
      else
        {
         if(aC>0) return(MathArctan(aS/aC)+MathArctan(1)*8);
         else return(MathArctan(aS/aC)+MathArctan(1)*4);
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fFurie(double &aArr[],double &aA[],double &aB[],double &aR[],double &aF[])
  {
//----
   int tN=ArraySize(aArr);
   int tM=MathMax(tN/2,1);

   ArrayResize(aA,tM);
   ArrayResize(aB,tM);
   ArrayResize(aR,tM);
   ArrayResize(aF,tM);

   for(int ti=1;ti<tM;ti++)
     {
      aA[ti]=0;
      aB[ti]=0;
      for(int tj=0;tj<tN;tj++)
        {
         aA[ti]+=aArr[tj]*MathSin(ti*6.28*tj/tN);
         aB[ti]+=aArr[tj]*MathCos(ti*6.28*tj/tN);
        }
      aA[ti]=2*aA[ti]/tN;
      aB[ti]=2*aB[ti]/tN;
      aR[ti]=MathSqrt(MathPow(aA[ti],2)+MathPow(aB[ti],2));
      aF[ti]=fMyArcTan(aB[ti],aA[ti]);
     }
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fLinearRegressionAll2(
                          int i0,
                          int i1,
                          double  &aArr[],
                          const double  &Price[]
                          )
  {
//---- 
   int aPeriod,rRetError;
   double aVal_0,aVal_1,aB,aMaxDev,aStdError,aRSquared;
   double x,y,y1,y2,sumy,sumx,sumxy,sumx2,sumy2,sumx22,sumy22,div1,div2;

   rRetError=0;
   aPeriod=i1-i0+1;
   sumy=0.0;
   sumx=0.0;
   sumxy=0.0;
   sumx2=0.0;
   sumy2=0.0;
   aB=0.0;
   aVal_0=0.0;
   aVal_1=0.0;

   for(int i=0; i<aPeriod; i++)
     {
      y=Price[i0+i];
      x=i;
      sumy+=y;
      sumxy+=y*i;
      sumx+=x;
      sumx2+=MathPow(x,2);
      sumy2+=MathPow(y,2);
     }

   sumx22=MathPow(sumx,2);
   sumy22=MathPow(sumy,2);
   div1=sumx2*aPeriod-sumx22;
   div2=MathSqrt((aPeriod*sumx2-sumx22)*(aPeriod*sumy2-sumy22));

//---- regression line
   if(div1)
     {
      aB=(sumxy*aPeriod-sumx*sumy)/div1;
      aVal_0=(sumy-sumx*aB)/aPeriod;
      aVal_1=aVal_0+aB*(aPeriod-1);
      rRetError+=-1;
     }
   else rRetError+=-1;

//--- stderr & maxdev
   aMaxDev=0;aStdError=0;

   for(int i=0;i<aPeriod;i++)
     {
      y1=Price[i0+i];
      y2=aVal_0+aB*i;
      aMaxDev=MathMax(MathAbs(y1-y2),aMaxDev);
      aStdError+=MathPow(y1-y2,2);
     }

   aStdError=MathSqrt(aStdError/aPeriod);

//--- rsquared ---
   if(div2!=0) aRSquared=MathPow((aPeriod*sumxy-sumx*sumy)/div2,2);
   else rRetError+=-2;

   ArrayResize(aArr,aPeriod);

   for(int i=0; i<aPeriod; i++)
     {
      y=Price[i0+i];
      x=aVal_0+i*(aVal_1-aVal_0)/aPeriod;
      aArr[i]=y-x;
     }
//----
   return(rRetError);
  }
//+------------------------------------------------------------------+
