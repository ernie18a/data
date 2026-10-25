#property copyright "Copyright © 2022, Il Anokhin"
#property description "Higher Timeframe Indicator"
#property link "https://www.mql5.com/en/users/ilanokhin"
#property strict

//-------------------------------------------------------------------------
// Indicator settings
//-------------------------------------------------------------------------

#property  indicator_chart_window
#property  indicator_buffers 6
#property  indicator_color1 Red
#property  indicator_color2 LimeGreen
#property  indicator_color3 Red
#property  indicator_color4 Red
#property  indicator_color5 LimeGreen
#property  indicator_color6 LimeGreen
#property  indicator_width1 2
#property  indicator_width2 2
#property  indicator_style3 2
#property  indicator_style4 2
#property  indicator_style5 2
#property  indicator_style6 2

//-------------------------------------------------------------------------
// Input parameters
//-------------------------------------------------------------------------

input ENUM_TIMEFRAMES TF = PERIOD_D1;              //Higher Timeframe

//-------------------------------------------------------------------------
// Variables
//-------------------------------------------------------------------------

int i, k;

double _open[], _close[], red_high[], red_low[], green_high[], green_low[];

//-------------------------------------------------------------------------
// 1. Initialization
//-------------------------------------------------------------------------

void OnInit()
   {
   
   IndicatorBuffers(6);

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexStyle(5,DRAW_HISTOGRAM);

   SetIndexBuffer(0,_open);
   SetIndexBuffer(1,_close);
   SetIndexBuffer(2,red_high);
   SetIndexBuffer(3,red_low);
   SetIndexBuffer(4,green_high);
   SetIndexBuffer(5,green_low);
   
   Comment("Copyright © 2022, Il Anokhin");
      
   }
   
//-------------------------------------------------------------------------
// 2. Deinitialization
//-------------------------------------------------------------------------

void OnDeinit(const int reason) {Comment("");}

//-------------------------------------------------------------------------
// 3. Main function
//-------------------------------------------------------------------------

int OnCalculate (const int rates_total, const int prev_calculated, const datetime& time[], const double& open[], const double& high[],
                 const double& low[], const double& close[], const long& tick_volume[], const long& volume[], const int& spread[])
   {
            
   int lim;
   
   lim=rates_total-100;
      
//--- 3.1. Main loop ------------------------------------------------------
        
   for(i=0;i<lim && TF>=Period();i++) 
      {
           
      k=iBarShift(Symbol(),TF,iTime(Symbol(),0,i));
      
      
      _open[i]=iOpen(Symbol(),TF,k);
      
      _close[i]=iClose(Symbol(),TF,k);
      
      if(_close[i]>_open[i]) {green_high[i]=iHigh(Symbol(),TF,k); green_low[i]=iLow(Symbol(),TF,k);}

      if(_close[i]<=_open[i]) {red_high[i]=iHigh(Symbol(),TF,k); red_low[i]=iLow(Symbol(),TF,k);}
                            
      }

//--- 3.2. End of main function -------------------------------------------         
                         
   return(rates_total);
      
   }
      
//-------------------------------------------------------------------------