//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Szymon Palczyński"
#property link      "https://www.mql5.com/en/users/stiopa"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 3

#property indicator_label1  "Down Buffer"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_width1  2

#property indicator_label2  "Up Buffer"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrBlue
#property indicator_width2  2

#property indicator_type3   DRAW_NONE
//--- External Variable
input  int                intPeriod    = 6;            // MA Period
input  ENUM_MA_METHOD     intMethod    = MODE_SMMA;    // MA Method
input  ENUM_APPLIED_PRICE intAppliedTo = PRICE_MEDIAN; // MA Applied to
input bool alert=True;//Alert  
input bool push=False;//Push Notifications
input bool mail=False;//Email

double TempBuffer[];
double DownBuffer[];
double UpBuffer[];

bool   UpTrendAlert=false, DownTrendAlert=false,test;
string _intMethod[5] = {"Simple","Exponential","Smoothed","Linear Weighted"};
string _intAppliedTo[8] = {"Close price","Open price","High price","Low price","Median price","Typical price","Weighted price"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(intPeriod<3){
   Alert("This value means the incorrect set of input parameters. Must be intPeriod>=3");
   return(INIT_PARAMETERS_INCORRECT);
   }
   int DrawBeginIndex = intPeriod*2;
//--- indicator buffers mapping
   SetIndexBuffer(0,DownBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,TempBuffer,INDICATOR_DATA);
   SetIndexDrawBegin(0,DrawBeginIndex);
   SetIndexDrawBegin(1,DrawBeginIndex);
   SetIndexDrawBegin(2,DrawBeginIndex);
//--- set indicator digits
   IndicatorDigits(_Digits);
   Comment("MA HISTOGRAM ("+(string)intPeriod+","+_intMethod[intMethod]+","+_intAppliedTo[intAppliedTo]+")");

//---
   return(INIT_SUCCEEDED);
  }
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

//--- check to have enough bars
   int limit = rates_total - intPeriod;
   if(rates_total <= limit)
      return(0);

//--- before the first run of OnCalculate
   limit = limit - prev_calculated;

   if(rates_total - prev_calculated == 0)
      limit = 1;  // after the first run of the OnCalculate
   else
      limit++;                                      // on the first tick of a new bar

//--- loop over bars to draw histogram
   for(int i=limit; i >= 0; i--)
     {
      //--- calculate sum
      double sum = 0.0;

      for(int j=0; j<intPeriod; j++)
         sum += iMA(_Symbol,PERIOD_CURRENT,intPeriod,0,intMethod,intAppliedTo,i+j);

      //--- fill buffer to draw histogram
      TempBuffer[i] = sum / intPeriod;
      DownBuffer[i] = TempBuffer[i+1];

      DownBuffer[i]  = TempBuffer[i] - (TempBuffer[i] - DownBuffer[i])*2;
      UpBuffer[i] = TempBuffer[i] + (TempBuffer[i] - DownBuffer[i])*2;

      string Message;
      if(DownBuffer[0]<UpBuffer[0] && DownBuffer[1]>UpBuffer[1] && i==0 && !UpTrendAlert)
        {
         Message = StringConcatenate("MA HISTOGRAM  --> Change of trend. Up Trend. Symbol: "+Symbol()+" Price "+DoubleToStr(Open[0],Digits));
         if(alert)
            Alert(Message);
         if(push)
            SendNotification(Message);
         if(mail)
            SendMail("MA HISTOGRAM",Message);
         UpTrendAlert = true;
         DownTrendAlert = false;
        }
      if(DownBuffer[0]>UpBuffer[0] && DownBuffer[1]<UpBuffer[1] && i==0 && !DownTrendAlert)
        {
         Message = StringConcatenate("MA HISTOGRAM  --> Change of trend. Down Trend. Symbol: "+Symbol()+" Price "+DoubleToStr(Open[0],Digits));
         if(alert)
            Alert(Message);
         if(push)
            SendNotification(Message);
         if(mail)
            SendMail("MA HISTOGRAM",Message);
         UpTrendAlert = false;
         DownTrendAlert = true;
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
