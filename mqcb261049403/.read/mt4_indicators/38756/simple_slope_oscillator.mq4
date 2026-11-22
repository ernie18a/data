//+------------------------------------------------------------------+
//|                                      Simple_Slope_Oscillator.mq4 |
//|                                +smoothing and normalized overlay |
//+------------------------------------------------------------------+
#property description "Code by Max Michael 2022"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Gold
#property indicator_level1  0.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_SOLID
#property strict
// inputs
extern int              period = 55;
extern int              smooth = 3;
input ENUM_MA_METHOD    method = MODE_SMA;
input ENUM_APPLIED_PRICE price = PRICE_CLOSE;
extern string   overlay_symbol = ""; //default=none
extern int             MaxBars = 1000;
double pipvalue1, pipvalue2;

double SS[],SS2[];

int init()
{
   IndicatorShortName("Simple_Slope_Osc ("+string(period)+","+string(smooth)+")");
   IndicatorDigits(Digits);
   SetIndexBuffer(0,SS);  SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,SS2); SetIndexStyle(1,DRAW_LINE);
   if(smooth<1) smooth=1;
   int digs1 = MarketInfo(_Symbol,MODE_DIGITS);
   double p1 = MarketInfo(_Symbol,MODE_POINT);
   pipvalue1 = p1*MathPow(10,digs1%2);
   if (digs1<=2) pipvalue1=0.4;
   // obtain pipvalues to normalize slope values of symbol   
   int digs2 = MarketInfo(overlay_symbol,MODE_DIGITS);
   double p2 = MarketInfo(overlay_symbol,MODE_POINT);
   pipvalue2 = p2*MathPow(10,digs2%2);
   if (digs2<=2) pipvalue2=0.4; //0.4 is for Gold overlay 
   return(0);
}

int deinit() { return(0); }

int start()
{
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
   int limit = Bars-counted_bars-1;
   if (limit > MaxBars) limit=MaxBars;

   for(int i=limit; i>=0 && !IsStopped(); i--)
   {
      double MA1 = iMA(_Symbol,0,smooth,0,method,price,i);
      double MA2 = iMA(_Symbol,0,smooth,0,method,price,i+period);
      SS[i] =((MA1-MA2)/period) / pipvalue1;

      if(overlay_symbol!="")
      {
         double MA3 = iMA(overlay_symbol,0,smooth,0,method,price,i);
         double MA4 = iMA(overlay_symbol,0,smooth,0,method,price,i+period);
         SS2[i] =((MA3-MA4)/period) / pipvalue2;
      }
   }
   return(0);
}
