//+------------------------------------------------------------------+
//|                                               ModifiedStdDev.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                       http://www.stanilevych.com |
//+------------------------------------------------------------------+
#property copyright   "2017, stanilevych.com"
#property link        "http://www.stanilevych.com"
#property description "Modified Standard Deviation"
#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1 2                //Width of line)
#property indicator_color1 Red,Green,Yellow //Color of line
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum MessageType
  {
   PushMessage,
   AlertMessage,
   LogMessage
  };
//--- input parametrs
input int            InpStdDevPeriod=20;   // Period
input int            InpStdDevShift=0;     // Shift
input ENUM_MA_METHOD InpMAMethod=MODE_SMA; // Method
input int            InpDigits=5;          // Accuracy
input MessageType    InpMessageType=AlertMessage; //Type of messages
//---- buffers
double               ExtStdDevBuffer[];
double               ExtMABuffer[];
double               ColorBuffer[];
//--- global variables
int                  ExtStdDevPeriod,ExtStdDevShift;
int rates=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input values
   if(InpStdDevPeriod<=1)
     {
      ExtStdDevPeriod=20;
      printf("Incorrect value for input variable InpStdDevPeriod=%d. Indicator will use value=%d for calculations.",InpStdDevPeriod,ExtStdDevPeriod);
     }
   else ExtStdDevPeriod=InpStdDevPeriod;
   if(InpStdDevShift<0)
     {
      ExtStdDevShift=0;
      printf("Incorrect value for input variable InpStdDevShift=%d. Indicator will use value=%d for calculations.",InpStdDevShift,ExtStdDevShift);
     }
   else ExtStdDevShift=InpStdDevShift;
//--- set indicator short name
   IndicatorSetString(INDICATOR_SHORTNAME,"StdDev("+string(ExtStdDevPeriod)+")");
//---- define indicator buffers as indexes
   SetIndexBuffer(0,ExtStdDevBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,ExtMABuffer,INDICATOR_CALCULATIONS);
//--- set index label
   PlotIndexSetString(0,PLOT_LABEL,"StdDev("+string(ExtStdDevPeriod)+")");
//--- set index shift
   PlotIndexSetInteger(0,PLOT_SHIFT,ExtStdDevShift);

   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Red);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Yellow);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Green);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
//--- variables of indicator
   if(rates==0) rates=rates_total;
   int pos;
//--- set draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,ExtStdDevPeriod-1+begin);
//--- check for rates count
   if(rates_total<ExtStdDevPeriod)
      return(0);
//--- starting work
   pos=prev_calculated-1;
//--- correct position for first iteration
   if(pos<ExtStdDevPeriod)
     {
      pos=ExtStdDevPeriod-1;
      ArrayInitialize(ExtStdDevBuffer,0.0);
      ArrayInitialize(ColorBuffer,0.0);
      ArrayInitialize(ExtMABuffer,0.0);
     }
//--- main cycle
   switch(InpMAMethod)
     {
      case  MODE_EMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==InpStdDevPeriod-1)
               ExtMABuffer[i]=SimpleMA(i,InpStdDevPeriod,price);
            else
               ExtMABuffer[i]=ExponentialMA(i,InpStdDevPeriod,ExtMABuffer[i-1],price);
            //--- Calculate StdDev
            ExtStdDevBuffer[i]=StdDevFunc(price,ExtMABuffer,i);
            SetColor(i);
           }
         break;
      case MODE_SMMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            if(i==InpStdDevPeriod-1)
               ExtMABuffer[i]=SimpleMA(i,InpStdDevPeriod,price);
            else
               ExtMABuffer[i]=SmoothedMA(i,InpStdDevPeriod,ExtMABuffer[i-1],price);
            //--- Calculate StdDev
            ExtStdDevBuffer[i]=StdDevFunc(price,ExtMABuffer,i);
            SetColor(i);
           }
         break;
      case MODE_LWMA :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            ExtMABuffer[i]=LinearWeightedMA(i,InpStdDevPeriod,price);
            ExtStdDevBuffer[i]=StdDevFunc(price,ExtMABuffer,i);
            SetColor(i);
           }
         break;
      default   :
         for(int i=pos;i<rates_total && !IsStopped();i++)
           {
            ExtMABuffer[i]=SimpleMA(i,InpStdDevPeriod,price);
            //--- Calculate StdDev
            ExtStdDevBuffer[i]=StdDevFunc(price,ExtMABuffer,i);
            if(rates!=rates_total)
              {
               Signal(i);
               rates=rates_total;
              }
            SetColor(i);
           }
     }
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total-1);
  }
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDevFunc(const double &price[],const double &MAprice[],int position)
  {
   double dTmp=0.0;
   for(int i=0;i<ExtStdDevPeriod;i++) dTmp+=MathPow(price[position-i]-MAprice[position],2);
   dTmp=NormalizeDouble(MathSqrt(dTmp/ExtStdDevPeriod),InpDigits);
   return(dTmp);
  }
//+------------------------------------------------------------------+
void SetColor(int i)
  {
//if(ArraySize(ExtStdDevBuffer)<=1) return;
   if(ExtStdDevBuffer[i]<ExtStdDevBuffer[i-1])ColorBuffer[i]=0;
   else if(ExtStdDevBuffer[i]>ExtStdDevBuffer[i-1]) ColorBuffer[i]=2;
   else ColorBuffer[i]=1;
  }
//+------------------------------------------------------------------+
void Signal(int i)
  {
   string message="";
   if(ColorBuffer[i-1]==0 && ColorBuffer[i-2]>0)
     {
      message="Начало падения.";
     }
   else if(ColorBuffer[i-1]==2 && ColorBuffer[i-2]<2)
     {
      message="Начало роста.";
     }
   if(message!="")
     {
      if(InpMessageType==AlertMessage) Alert(message);
      if(InpMessageType==PushMessage) SendNotification(message);
      if(InpMessageType==LogMessage) Print(message);
     }
  }
//+------------------------------------------------------------------+
