//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  clrRed
#property indicator_color2  clrBlue
#property indicator_width1  2
#property indicator_width2  2
#property strict

//
//
//

extern int                FractalPeriod          = 5;                // Fractal period: 5 for built in fractal
extern ENUM_APPLIED_PRICE PriceHigh              = PRICE_HIGH;       // Price high
extern ENUM_APPLIED_PRICE PriceLow               = PRICE_LOW;        // Price low
extern double             UpperArrowDisplacement = 0.2;              // Upper arrow displacement
extern double             LowerArrowDisplacement = 0.2;              // Lower arrow displacement

double v1[],v2[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   if (MathMod(FractalPeriod,2)==0) FractalPeriod = FractalPeriod+1;
   SetIndexBuffer(0,v1);  SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159); 
   SetIndexBuffer(1,v2);  SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159); 
   
   IndicatorShortName("Fractals - adjustable price");
   return(INIT_SUCCEEDED);
}

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
   int limit=MathMin(MathMax(rates_total-prev_calculated,FractalPeriod),rates_total-1);
     
   //
   //
   //
   //
   //
     
   int half = FractalPeriod/2;    
   for(int i=limit; i>=half && !_StopFlag; i--) 
   {
      bool   found     = true;
      double compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i);
         for (int k=1; k<=half; k++)
            {
               if ((i+k)<rates_total && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i+k)> compareTo) { found=false; break; }
               if ((i-k)>=0          && iMA(NULL,0,1,0,MODE_SMA,PriceHigh,i-k)>=compareTo) { found=false; break; }
            }
         if (found) 
               v1[i] = high[i]+iATR(NULL,0,20,i)*UpperArrowDisplacement;
         else  v1[i] = EMPTY_VALUE;

         //
         //
         //
      
         found     = true;
         compareTo = iMA(NULL,0,1,0,MODE_SMA,PriceLow,i);
         for (int k=1; k<=half; k++)
            {
               if ((i+k)<rates_total && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i+k)< compareTo) { found=false; break; }
               if ((i-k)>=0          && iMA(NULL,0,1,0,MODE_SMA,PriceLow,i-k)<=compareTo) { found=false; break; }
            }
          if (found)
               v2[i] = low[i]-iATR(NULL,0,20,i)*LowerArrowDisplacement;
          else v2[i] = EMPTY_VALUE;
         
   }
   return(rates_total);
}