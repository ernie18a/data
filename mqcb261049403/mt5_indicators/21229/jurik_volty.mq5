//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Jurik volty"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Jurik volty"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
#property indicator_label2  "Jurik volty signal"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrLimeGreen,clrOrange
//
// input parameters
//
input int                inpPeriod    = 14;          // Volty period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

double  val[],valc[],sig[],sigc[];
struct sVoltyAnswer
{
   double volty;
   double voltySignal;
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,sig,INDICATOR_DATA);
   SetIndexBuffer(3,sigc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Jurik volty ("+(string)inpPeriod+")");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
//
//---
//
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      sVoltyAnswer _answer = iVolty(price,inpPeriod,i,rates_total);
      val[i]  = _answer.volty;
      sig[i]  = _answer.voltySignal;
      valc[i] = (val[i]>sig[i]) ? 1 : (val[i]<sig[i]) ? 2 : 0;
      sigc[i] = valc[i];
     }
   return(i);
  }
//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
double wrk[][5];
#define bsmax  0
#define bsmin  1
#define voltya 2
#define vsum   3
#define avolty 4
#define avgLen 65
//
//---
//
sVoltyAnswer iVolty(double price, double length, int r, int bars)
{
   if (ArrayRange(wrk,0) != bars) ArrayResize(wrk,bars);
   sVoltyAnswer _answer;
                _answer.volty = 0;
                _answer.voltySignal = 0;
                
   
   if (r==0) { for(int k=0; k<5; k++) wrk[0][k]=0; return(_answer); }

   //
   //
   //
   //
   //
   
      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = (r>0) ? price - wrk[r-1][bsmax] : 0;
      double del2 = (r>0) ? price - wrk[r-1][bsmin] : 0;
	
         wrk[r][voltya] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][voltya] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][voltya] = MathAbs(del2); 
         wrk[r][vsum] =	(r>9) ? wrk[r-1][vsum] + 0.1*(wrk[r][voltya]-wrk[r-10][voltya]) : wrk[r][voltya];
   
         double avg = wrk[r][vsum];  int k=1; for (; k<avgLen && (r-k)>=0 ; k++) avg += wrk[r-k][vsum];
                                                                                 avg /= k;
         wrk[r][avolty] = avg;                                           
               double dVolty = (wrk[r][avolty] > 0) ? wrk[r][voltya]/wrk[r][avolty] : 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //---
      //

   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));		
	
         if (del1 > 0) wrk[r][bsmax] = price; else wrk[r][bsmax] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin] = price; else wrk[r][bsmin] = price - Kv*del2;

   //
   //---
   //

          _answer.voltySignal = wrk[r][avolty];
          _answer.volty       = wrk[r][vsum];
   return(_answer);                
}  
//
//---
//
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
