//+------------------------------------------------------------------+
//|                                            AlphaTrendSpotter.mq4 |
//|                                     Copyright 2015, Andy Ismail. |
//|                                        http://www.fbsbroker.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, andyismail.net"
#property link      "fbsbroker.com"
#property version   "1.10"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Black
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Orange
#property indicator_levelwidth 4
//--- input parameters

input int         MaPeriod1=5;   // Daily Periode
int               MaPeriod11=1;  // Weekly Periode
int               MaPeriod2=MaPeriod1; // High Price Periode
int               MaPeriod3=MaPeriod1; // Low Price Periode 

int TrendPower=2;
string tpower="D";

//Buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   if(TrendPower>1){tpower="W";}
   IndicatorDigits(Digits);
   IndicatorShortName("ATS (" + IntegerToString(MaPeriod1)+","+IntegerToString(MaPeriod11)+","+tpower+")");
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(1,Buffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(2,Buffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,4);
   SetIndexBuffer(3,Buffer4);
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
   int    countedBars=prev_calculated;
  double ma10, ma20, ma30;
   double ma1, ma2, ma3;
   double ma1w, ma2w, ma3w;
   double sar0, sar, sarw;
//----
   if(Bars<MaPeriod3)return(0);
   
   for(int i=Bars-countedBars-1; i>=0; i--){
      Buffer1[i]=0;
      
      ma10 = iMA(NULL,0,3,0,MODE_EMA,PRICE_CLOSE,i-1);
      ma20 = iMA(NULL,0,MaPeriod2,0,MODE_EMA,PRICE_HIGH,i);
      ma30 = iMA(NULL,0,MaPeriod3,0,MODE_EMA,PRICE_LOW,i);
   
      ma1 = iMA(NULL,1440,3,0,MODE_EMA,PRICE_OPEN,i-1);
      ma2 = iMA(NULL,1440,MaPeriod2,0,MODE_EMA,PRICE_HIGH,i);
      ma3 = iMA(NULL,1440,MaPeriod3,0,MODE_EMA,PRICE_LOW,i);
      
       ma1w = iMA(NULL,10080,MaPeriod11,0,MODE_EMA,PRICE_CLOSE,i-1);
      ma2w = iMA(NULL,10080,MaPeriod11,0,MODE_EMA,PRICE_HIGH,i);
      ma3w = iMA(NULL,10080,MaPeriod11,0,MODE_EMA,PRICE_LOW,i);
      
      sar0 = iSAR(NULL,0,0.02,0.2,i);
      sar = iSAR(NULL,1440,0.02,0.2,i);
      sarw = iSAR(NULL,10080,0.02,0.2,i);
    
    if (TrendPower==2){ 
      if(ma10>ma20 && ma10>ma30 && ma10>sar0 && ma1>ma2 && ma1>ma3 && ma1w>=ma2w && ma1>sar && ma1w>sarw){
         Buffer1[i]+=1;
      }else if( ma10<ma20 && ma10<ma30 && ma10<sar0 &&  ma1<ma2 && ma1<ma3 && ma1w<=ma3w && ma1<sar && ma1w<sarw){
         Buffer1[i]-=1;
      }      
         }
      if(Buffer1[i]>0){
         Buffer2[i]=2;
         Buffer3[i]=EMPTY_VALUE;
         Buffer4[i]=EMPTY_VALUE;
      }else if(Buffer1[i]<0){
         Buffer2[i]=EMPTY_VALUE;
         Buffer3[i]=2;
         Buffer4[i]=EMPTY_VALUE;
      }else{
         Buffer2[i]=EMPTY_VALUE;
         Buffer3[i]=EMPTY_VALUE;
         Buffer4[i]=1;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
