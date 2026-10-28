//+------------------------------------------------------------------+
//|                                                       Spectr.mq5 | 
///|                                  Copyright © 2009, Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
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
input ENUM_TIMEFRAMES iPeriod=PERIOD_H4;               // indicator time frame
input uint  iStartFrom=0;                              // Bar index for the calculation start
input uint  VV = 1;                                    // Wave height
input uint  pm = 20;                                   // Smoothing period to the calculation of moving average
input ENUM_MA_METHOD       ma_method=MODE_SMA;         // type of averaging
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;  // type of price

//+-----------------------------------+

//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_;
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
int nPeriod;
int nStartFrom;
double A[],B[],R[],F[];
//---- Declaration of integer variables for the indicator handles
int MA_Handle;
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
//| Spectr indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initializations of variable for indicator short name
   string ShortName="Spectr";

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
   
//---- getting the iMA indicator handle
   MA_Handle=iMA(Symbol(),PERIOD_CURRENT,pm,0,ma_method,applied_price);
   if(MA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iMA indicator");
      return;
     }

//---- Initialization of variables of the start of data calculation
   nPeriod=PeriodSeconds(iPeriod)/60;
   nStartFrom=int(iStartFrom);
   min_rates_=nStartFrom+nPeriod;
   min_rates_total=int(pm+min_rates_);
   
   

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
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total+begin) return(RESET);

//---- declaration of local variables 
   double Arr[],MA[];
   int N,bar,to_copy;   
//----     
   to_copy=min_rates_;
//--- copy newly appeared data in the array
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(price,true);
   ArraySetAsSeries(MA,true);
//---- 

   fLinearRegressionAll2(nStartFrom,nStartFrom+nPeriod-1,Arr,price);
//---- 
   fFurie(Arr,A,B,R,F);

   N=MathMax(ArraySize(Arr),2);
   IndicatorsDrawBegin(rates_total-N+1);
//---- main indicator calculation loop
   for(int i=0; i<N && !IsStopped(); i++)
     {
      bar=i+int(iStartFrom);
      ExtMapBuffer1[bar]=MA[bar]+(A[0]*MathSin(1*6.28*i/(N-1))+B[0]*MathCos(1*6.28*i/(N-1)))*VV;
      ExtMapBuffer2[bar]=MA[bar]+(A[1]*MathSin(2*6.28*i/(N-1))+B[1]*MathCos(2*6.28*i/(N-1)))*VV;
      ExtMapBuffer3[bar]=MA[bar]+(A[2]*MathSin(3*6.28*i/(N-1))+B[2]*MathCos(3*6.28*i/(N-1)))*VV;
      ExtMapBuffer4[bar]=MA[bar]+(A[3]*MathSin(4*6.28*i/(N-1))+B[3]*MathCos(4*6.28*i/(N-1)))*VV;
      ExtMapBuffer5[bar]=MA[bar]+(A[4]*MathSin(5*6.28*i/(N-1))+B[4]*MathCos(5*6.28*i/(N-1)))*VV;
      ExtMapBuffer6[bar]=MA[bar]+(A[5]*MathSin(6*6.28*i/(N-1))+B[5]*MathCos(6*6.28*i/(N-1)))*VV;
      ExtMapBuffer7[bar]=MA[bar]+(A[6]*MathSin(7*6.28*i/(N-1))+B[6]*MathCos(7*6.28*i/(N-1)))*VV;
      ExtMapBuffer8[bar]=MA[bar]+(A[7]*MathSin(8*6.28*i/(N-1))+B[7]*MathCos(8*6.28*i/(N-1)))*VV;
     }

   for(bar=0; bar<int(iStartFrom) && !IsStopped(); bar++)
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
   return(rates_total);
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
