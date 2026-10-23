//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Bollinger bands stops - JMA based with multiple stops"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_label1  "Bollinger bands stops up stop line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  3
#property indicator_label2  "Bollinger bands stops down stop line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_width2  3
#property indicator_label3  "Bollinger bands stops up first stop line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_label4  "Bollinger bands stops down first stop line"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_label5  "Bollinger bands stops up second stop line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_label6  "Bollinger bands stops down second stop line"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSandyBrown
#property indicator_label7  "Bollinger bands stops up trend start"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrDodgerBlue
#property indicator_width7  2
#property indicator_label8  "Bollinger bands stops down trend start"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrSandyBrown
#property indicator_width8  2

//
//--- input parameters
//

input double             inpJmaPeriod = 30;          // JMA period
input double             inpJmaPhase  =  0;          // JMA phase
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input double             inpDevPeriod = 20;          // Deviation period (<=1 for same as average period)
input double             inpDeviation = 2;           // Deviation multiplier
input string             __º__01_00   = "";          // .
input string             __º__01_01   = "";          // Risk settings
input string             __º__01_02   = "";          // .
input double             inpRisk      = 0.75;        // Risk multiplier
input double             inpRisk2     = 1.5;         // Risk 2 multiplier
input double             inpRisk3     = 2.5;         // Risk 3 multiplier

//
//--- indicator buffers
//

double lineup[],linedn[],lineup2[],linedn2[],lineup3[],linedn3[],arrowup[],arrowdn[];
double _risk1,_risk2,_risk3,_devPeriod; 

//
//--- custom structures
//

struct sStops
{
   double upline;
   double downline;
   double upline2;
   double downline2;
   double upline3;
   double downline3;
   int    trend;
   bool   trendChange;
};

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,lineup ,INDICATOR_DATA);
   SetIndexBuffer(1,linedn ,INDICATOR_DATA);
   SetIndexBuffer(2,lineup2,INDICATOR_DATA);
   SetIndexBuffer(3,linedn2,INDICATOR_DATA);
   SetIndexBuffer(4,lineup3,INDICATOR_DATA);
   SetIndexBuffer(5,linedn3,INDICATOR_DATA);
   SetIndexBuffer(6,arrowup,INDICATOR_DATA); PlotIndexGetInteger(6,PLOT_ARROW,159);
   SetIndexBuffer(7,arrowdn,INDICATOR_DATA); PlotIndexGetInteger(7,PLOT_ARROW,159);
         double _risks[3];
                _risks[0] = inpRisk;
                _risks[1] = inpRisk2;
                _risks[2] = inpRisk3; ArraySort(_risks);
                                                _risk1 = _risks[0];
                                                _risk2 = _risks[1];
                                                _risk3 = _risks[2];
         _devPeriod = inpDevPeriod>1 ? inpDevPeriod : inpJmaPeriod;
   return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   sStops _result;
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      double _avg   = iSmooth(_price,inpJmaPeriod,inpJmaPhase,i);
      double _dev   = iEmaDeviation(_price,_devPeriod,i);
            _result = iStops(_price,_avg,_dev,inpDeviation,_risk1,_risk2,_risk3,i);
               lineup[i]  = _result.upline3;
               linedn[i]  = _result.downline3;
               lineup2[i] = _result.upline;
               linedn2[i] = _result.downline;
               lineup3[i] = _result.upline2;
               linedn3[i] = _result.downline2;
               arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
               arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;
   }          
   return(i);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _edevInstances 1
#define _edevInstancesSize 2
#define _edevRingSize 6
double workEmaDeviation[_edevRingSize][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period, int i, int instance=0)
{
   int _indC = (i  )%_edevRingSize;
   int _inst = instance*_edevInstancesSize;
   
   if (i>0 && period>1)
   {
      int    _indP  = (i-1)%_edevRingSize;
      double _alpha = (2.0/(2.0+(period-1.0)/2.0));
         workEmaDeviation[_indC][_inst+_ema0] = workEmaDeviation[_indP][_inst+_ema0]+_alpha*(price      -workEmaDeviation[_indP][_inst+_ema0]);
         workEmaDeviation[_indC][_inst+_ema1] = workEmaDeviation[_indP][_inst+_ema1]+_alpha*(price*price-workEmaDeviation[_indP][_inst+_ema1]);
   }         
   else for (int k=0; k<_edevInstancesSize; k++) workEmaDeviation[_indC][_inst+k] = price;
   return(MathSqrt(period*(workEmaDeviation[_indC][_inst+_ema1]-workEmaDeviation[_indC][_inst+_ema0]*workEmaDeviation[_indC][_inst+_ema0])/(period>2 ? period-1.0 : 1)));

   //
   //---
   //

   #undef _ema0
   #undef _ema1
}
//
//---
//
#define _smoothInstances     1
#define _smoothInstancesSize 10
#define _smoothRingSize      15
double workSmooth[_smoothRingSize][_smoothInstances*_smoothInstancesSize];
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9
//
//---
//
double iSmooth(double price, double length, double phase, int i, int instance=0)
{
   int _indP = (i-1)%_smoothRingSize;
   int _indC = (i  )%_smoothRingSize;
   int _inst = instance*_smoothInstancesSize;

   if(i==0 || length<=1) { int k=0; for(; k<volty; k++) workSmooth[_indC][_inst+k]=price; for(; k<_smoothInstancesSize; k++) workSmooth[_indC][_inst+k]=0; return(price); }

   //
   //
   //

      double len1 = MathLog(MathSqrt(0.5*(length-1.0)))/M_LN2+2.0; if(len1<0) len1=0;
      double pow1 = len1-2.0; if(pow1<0.5) pow1=0.5;
      double del1 = price - workSmooth[_indP][_inst+bsmax], absDel1 = (del1>0 ? del1 :-del1);
      double del2 = price - workSmooth[_indP][_inst+bsmin], absDel2 = (del2>0 ? del2 :-del2);
      int   _indF = (i>10 ? i-10 : 0)%_smoothRingSize;

         workSmooth[_indC][_inst+volty]  = (absDel1 > absDel2) ? absDel1 : (absDel1 < absDel2) ? absDel2 : 0;
         workSmooth[_indC][_inst+vsum]   = workSmooth[_indP][_inst+vsum]+(workSmooth[_indC][_inst+volty]-workSmooth[_indF][_inst+volty])*0.1;
         workSmooth[_indC][_inst+avolty] = workSmooth[_indP][_inst+avolty]+(2.0/((length<7.5?30:4.0*length)+1.0))*(workSmooth[_indC][_inst+vsum]-workSmooth[_indP][_inst+avolty]);
      
      double dVolty    = (workSmooth[_indC][_inst+avolty]>0) ? workSmooth[_indC][_inst+volty]/workSmooth[_indC][_inst+avolty]: 0;
      double dVoltyTmp = MathPow(len1,1.0/pow1);
         if (dVolty > dVoltyTmp) dVolty = dVoltyTmp;
         if (dVolty < 1.0)       dVolty = 1.0;

      double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         workSmooth[_indC][_inst+bsmax] = (del1 > 0) ? price : price - Kv*del1;
         workSmooth[_indC][_inst+bsmin] = (del2 < 0) ? price : price - Kv*del2;

      //
      //
      //

      double corr  = (phase>100.0 ? 100.0 : phase<-100.0 ? -100.0 : phase)/100.0 + 1.5;
      double beta  = 0.45*(length-1.0)/(0.45*(length-1.0)+2.0);
      double alpha = MathPow(beta,pow2);

          workSmooth[_indC][_inst+0] = price + alpha*(workSmooth[_indP][_inst+0]-price);
          workSmooth[_indC][_inst+1] = (price - workSmooth[_indC][_inst+0])*(1-beta) + beta*workSmooth[_indP][_inst+1];
          workSmooth[_indC][_inst+2] = (workSmooth[_indC][_inst+0] + corr*workSmooth[_indC][_inst+1]);
          workSmooth[_indC][_inst+3] = (workSmooth[_indC][_inst+2] - workSmooth[_indP][_inst+4])*((1-alpha)*(1-alpha)) + (alpha*alpha)*workSmooth[_indP][_inst+3];
          workSmooth[_indC][_inst+4] = (workSmooth[_indP][_inst+4] + workSmooth[_indC][_inst+3]);
   return(workSmooth[_indC][_inst+4]);

   #undef bsmax
   #undef bsmin
   #undef volty
   #undef vsum
   #undef avolty
}    
//
//---
//
#define _stopsInstances 1
#define _stopsInstancesSize 9
#define _stopsRingSize 6
double workStops[_stopsRingSize][_stopsInstances*_stopsInstancesSize];
#define _stopsAmin  0
#define _stopsAmax  1 
#define _stopsBmin  2
#define _stopsBmax  3 
#define _stopsCmin  4
#define _stopsCmax  5 
#define _stopsDmin  6
#define _stopsDmax  7 
#define _stopsTrend 8

//
//---
//

sStops iStops(double value, double average, double deviation, double bands, double risk, double risk2, double risk3, int i, int instance=0)
{
   int _indC = (i  )%_stopsRingSize;
   int _indP = (i-1)%_stopsRingSize;
   int _inst = instance*_stopsInstancesSize;
   
   //
   //---
   //
   
   workStops[_indC][_inst+_stopsAmax]  = average+bands*deviation;
   workStops[_indC][_inst+_stopsAmin]  = average-bands*deviation;
   workStops[_indC][_inst+_stopsBmax]  = average+risk*deviation;
   workStops[_indC][_inst+_stopsBmin]  = average-risk*deviation;
   workStops[_indC][_inst+_stopsCmax]  = average+risk2*deviation;
   workStops[_indC][_inst+_stopsCmin]  = average-risk2*deviation;
   workStops[_indC][_inst+_stopsDmax]  = average+risk3*deviation;
   workStops[_indC][_inst+_stopsDmin]  = average-risk3*deviation;
	workStops[_indC][_inst+_stopsTrend] = (i>0) ? (value>workStops[_indP][_inst+_stopsAmax]) ? 1 : (value<workStops[_indP][_inst+_stopsAmin]) ? -1 : workStops[_indP][_inst+_stopsTrend] : 0;
      if (i>0)
      {
         if (workStops[_indC][_inst+_stopsTrend]==-1)
         {
            if (workStops[_indC][_inst+_stopsAmax]>workStops[_indP][_inst+_stopsAmax]) workStops[_indC][_inst+_stopsAmax] = workStops[_indP][_inst+_stopsAmax];
            if (workStops[_indC][_inst+_stopsBmax]>workStops[_indP][_inst+_stopsBmax]) workStops[_indC][_inst+_stopsBmax] = workStops[_indP][_inst+_stopsBmax];
            if (workStops[_indC][_inst+_stopsCmax]>workStops[_indP][_inst+_stopsCmax]) workStops[_indC][_inst+_stopsCmax] = workStops[_indP][_inst+_stopsCmax];
            if (workStops[_indC][_inst+_stopsDmax]>workStops[_indP][_inst+_stopsDmax]) workStops[_indC][_inst+_stopsDmax] = workStops[_indP][_inst+_stopsDmax];
         }         
         if (workStops[_indC][_inst+_stopsTrend]==1)
         {
            if (workStops[_indC][_inst+_stopsAmin]<workStops[_indP][_inst+_stopsAmin]) workStops[_indC][_inst+_stopsAmin] = workStops[_indP][_inst+_stopsAmin];
            if (workStops[_indC][_inst+_stopsBmin]<workStops[_indP][_inst+_stopsBmin]) workStops[_indC][_inst+_stopsBmin] = workStops[_indP][_inst+_stopsBmin];
            if (workStops[_indC][_inst+_stopsCmin]<workStops[_indP][_inst+_stopsCmin]) workStops[_indC][_inst+_stopsCmin] = workStops[_indP][_inst+_stopsCmin];
            if (workStops[_indC][_inst+_stopsDmin]<workStops[_indP][_inst+_stopsDmin]) workStops[_indC][_inst+_stopsDmin] = workStops[_indP][_inst+_stopsDmin];
         }         
      }                  
   
      //
      //---
      //
      
      sStops _result;
	          _result.trend       = (int)workStops[_indC][_inst+_stopsTrend];
             _result.trendChange = (i>0) ? ( workStops[_indC][_inst+_stopsTrend]!=workStops[_indP][_inst+_stopsTrend]) : false;
             _result.upline      =         ( workStops[_indC][_inst+_stopsTrend]== 1) ? workStops[_indC][_inst+_stopsBmin] : EMPTY_VALUE;
             _result.downline    =         ( workStops[_indC][_inst+_stopsTrend]==-1) ? workStops[_indC][_inst+_stopsBmax] : EMPTY_VALUE;
             _result.upline2     =         ( workStops[_indC][_inst+_stopsTrend]== 1) ? workStops[_indC][_inst+_stopsCmin] : EMPTY_VALUE;
             _result.downline2   =         ( workStops[_indC][_inst+_stopsTrend]==-1) ? workStops[_indC][_inst+_stopsCmax] : EMPTY_VALUE;
             _result.upline3     =         ( workStops[_indC][_inst+_stopsTrend]== 1) ? workStops[_indC][_inst+_stopsDmin] : EMPTY_VALUE;
             _result.downline3   =         ( workStops[_indC][_inst+_stopsTrend]==-1) ? workStops[_indC][_inst+_stopsDmax] : EMPTY_VALUE;
      return(_result);   

   //
   //
   //
   
   #undef _stopsAmax
   #undef _stopsAmin
   #undef _stopsBmax
   #undef _stopsBmin
   #undef _stopsCmax
   #undef _stopsCmin
   #undef _stopsDmax
   #undef _stopsDmin
   #undef _stopsTrend
};

//
//---
//

double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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