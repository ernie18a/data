//----------------------------------------------------------------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//----------------------------------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Dollar index"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
//
//---
//
input int    inpBarsToCalculate = 500; // Bars to calculate
input string inpSymbolsPrefix   = "";  // Symbols prefix
input string inpSymbolsSuffix   = "";  // Symbols suffix

double io[],ih[],il[],ic[],icolor[];
string symbols[] = {"EURUSD","USDJPY","GBPUSD","USDCAD","USDSEK","USDCHF"};
double pows[]    = {-0.576  ,0.136   ,-0.119  ,0.091   ,0.042   ,0.036   };
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,io);
   SetIndexBuffer(1,ih);
   SetIndexBuffer(2,il);
   SetIndexBuffer(3,ic);
   SetIndexBuffer(4,icolor,INDICATOR_COLOR_INDEX);
         for (int i=0; i<6; i++) symbols[i] = inpSymbolsPrefix+symbols[i]+inpSymbolsSuffix;
         return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
  {
  }
//
//--
//
int OnCalculate (const int rates_total, const int prev_calculated, const datetime& time[], 
                 const double& open[], 
                 const double& high[], 
                 const double& low[], 
                 const double& close[], 
                 const long& tick_volume[], 
                 const long& volume[], 
                 const int& spread[] )
{ 
   int _bars = (int)MathMax(inpBarsToCalculate,ChartGetInteger(0,CHART_VISIBLE_BARS));
   int i=(int)MathMax(prev_calculated-_bars+1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (i<rates_total-_bars) { io[i] = ih[i] = il[i] = ic[i] = EMPTY_VALUE; icolor[i] = 0; continue; }
      double dxyClose = 50.14348112;
      double dxyOpen  = 50.14348112;
      double dxyHigh  = 50.14348112;
      double dxyLow   = 50.14348112;
      for (int k=0; k<6; k++)
      {
         MqlRates _rates[]; 
              int _ratesCopied = CopyRates(symbols[k],0,time[i],1,_rates);
              if (_ratesCopied == 1)
              {
                  dxyClose *= MathPow(_rates[0].close,pows[k]);
                  dxyOpen  *= MathPow(_rates[0].open ,pows[k]);
                  dxyHigh  *= MathPow(_rates[0].high ,pows[k]);
                  dxyLow   *= MathPow(_rates[0].low  ,pows[k]);
               }                  
      }               
      ic[i] = dxyClose;
      io[i] = dxyOpen;
      ih[i] = dxyHigh;
      il[i] = dxyLow;
      icolor[i] = (ic[i]>io[i]) ? 1 : (ic[i]<io[i]) ? 2 : 0;
   }
   return(rates_total);
}
