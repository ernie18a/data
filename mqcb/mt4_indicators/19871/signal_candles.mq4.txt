//+------------------------------------------------------------------+
//|                                               Signal Candles.mq4 |
//|                              Copyright 2018, Besarion Turmanauli |
//|                             https://www.mql5.com/en/users/dos.ge |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Besarion Turmanauli"
#property link      "https://www.mql5.com/en/users/dos.ge"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_style1 1
#property indicator_style2 1
#property indicator_width1 2
#property indicator_width2 2
#define ISN "Signal Candles"
int initial_limit=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum candleDirections
  {
   cd1 = 1, //Short
   cd2 = 2, //Long
   cd3 = 3, //Neutral
   cd4 = 4  //No Restrictions
  };

extern string str0="GENERAL CRITERIA";// 
extern double minimum_candle_size_hl_points=100.0;//Minimum Candle Size in Points ( High - Low )
extern double minimum_body_to_candle_ratio=0.0;//Minimum Candle Body to Candle Size Ratio
extern string str1="SELL ENTRY CRITERIA";// 
extern candleDirections s_candle_direction=cd1; //Candle Direction
extern double s_minimum_upper_tail_ratio= 0.6; //Minimum Upper Tail to Candle Size Ratio 
extern double s_minimum_lower_tail_ratio= 0.0; //Minimum Lower Tail to Candle Size Ratio 
extern string str2="BUY ENTRY CRITERIA";// 
extern candleDirections b_candle_direction=cd2; //Candle Direction
extern double b_minimum_upper_tail_ratio= 0.0; //Minimum Upper Tail to Candle Size Ratio 
extern double b_minimum_lower_tail_ratio= 0.6; //Minimum Lower Tail to Candle Size Ratio 

extern bool Alerts= false;//Enable Alerts
extern bool Email = false;//Enable Email Notification
extern bool Push=false;//Enable Push Notification

double ShortSignal[],LongSignal[]; //declaration of buffer arrays
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   IndicatorShortName(ISN);
   IndicatorBuffers(2);
   SetIndexBuffer(0,ShortSignal);
   SetIndexArrow(0,242);
   SetIndexBuffer(1,LongSignal);
   SetIndexArrow(1,241);

   SetIndexLabel(0,"Short Signal");
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexEmptyValue(0,0.0);

   SetIndexLabel(1,"Long Signal");
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexEmptyValue(1,0.0);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,// Bar index
   Counted_bars;                // Number of counted bars

   Counted_bars=IndicatorCounted(); // Number of counted bars
   i=Bars-Counted_bars-1;           // Index of the first uncounted
   if(initial_limit==0){initial_limit=i;}

   while(i>0)
     {//start iteration

      //getting initial values
      double open=Open[i];
      double high=High[i];
      double low=Low[i];
      double close=Close[i];
      double candle_size=NormalizeDouble((high-low)/MarketInfo(Symbol(),MODE_POINT),1);
      //end getting initial values

      if(candle_size>0)
        {//checking if candle size > 0

         double body_size=NormalizeDouble(MathAbs(open-close)/MarketInfo(Symbol(),MODE_POINT),1);

         double upper_tail_size = NormalizeDouble((high-MathMax(open,close))/MarketInfo(Symbol(),MODE_POINT),1);
         double lower_tail_size = NormalizeDouble((MathMin(open,close)-low)/MarketInfo(Symbol(),MODE_POINT),1);

         double body_size_ratio=body_size/candle_size;
         double upper_tail_ratio = upper_tail_size/candle_size;
         double lower_tail_ratio = lower_tail_size/candle_size;

         int candle_direction=1;
         if(close>open)candle_direction=2;
         if(close==open)candle_direction=3;

         if(body_size_ratio>=minimum_body_to_candle_ratio && 
            candle_size>=minimum_candle_size_hl_points
            )
           {//general criteria check
            //sell signal  
            if((s_candle_direction==4 || s_candle_direction==candle_direction) && 
               lower_tail_ratio>=s_minimum_lower_tail_ratio &&
               upper_tail_ratio>=s_minimum_upper_tail_ratio)
              {//sell criteria check
               ShortSignal[i]=high;
               if(i<initial_limit && i==1)SellSignal();
              }//end sell criteria check

            //buy signal
            if((b_candle_direction==4 || b_candle_direction==candle_direction) && 
               lower_tail_ratio>=b_minimum_lower_tail_ratio&&
               upper_tail_ratio>=b_minimum_upper_tail_ratio)
              {//buy criteria check
               LongSignal[i]=low;
               if(i<initial_limit && i==1)BuySignal();
              }//end buy criteria check

           }//end general criteria check

        }//end checking if candle size > 0

      i--;
     }//end iteration

   return (0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  //send sell signal
//+------------------------------------------------------------------+
void SellSignal()
  {
   if(Alerts)Alert(ISN+": SELL SIGNAL ON "+Symbol());
   if(Email)SendMail(ISN": SELL SIGNAL ON "+Symbol(),"Signal Sent From "+ISN+" Indicator.");
   if(Push)SendNotification(ISN+": SELL SIGNAL ON "+Symbol());
  }//end of sell signal
//+------------------------------------------------------------------+
//|  //send buy signal
//+------------------------------------------------------------------+
void BuySignal()
  {
   if(Alerts)Alert(ISN+": BUY SIGNAL ON "+Symbol());
   if(Email)SendMail(ISN+": BUY SIGNAL ON "+Symbol(),"Signal Sent From "+ISN+" Indicator.");
   if(Push)SendNotification(ISN+": BUY SIGNAL ON "+Symbol());
  }//end of buy signal
