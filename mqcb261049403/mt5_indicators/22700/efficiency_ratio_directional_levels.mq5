//------------------------------------------------------------------
 #property copyright   "© mladen, 2018"
 #property link        "mladenfx@gmail.com"
 #property description "Kaufman efficiency ratio"
 #property description "Directional efficiency ratio"
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Level down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Efficiency ratio"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrOrangeRed
#property indicator_width3  2
//
//--- input parameters
//
input int                inpPeriod          = 32;          // ER period
input ENUM_APPLIED_PRICE inpPrice           = PRICE_CLOSE; // Price 
input int                inpSmoothingPeriod = 5;           // Smoothing period
input double             inpLevelPeriod     = 10;          // Levels period
//
//--- buffers and global variables declarations
//
double val[],valc[],lup[],ldn[],ª_alpha,ª_alphal;

//------------------------------------------------------------------
// Custom indicator initialization function                         
//------------------------------------------------------------------
int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,lup,INDICATOR_DATA);
         SetIndexBuffer(1,ldn,INDICATOR_DATA);
         SetIndexBuffer(2,val,INDICATOR_DATA);
         SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   ª_alpha  = 2.0/(1.0+(inpSmoothingPeriod>1? inpSmoothingPeriod :1));
   ª_alphal = 2.0/(1.0+(inpLevelPeriod>1?inpLevelPeriod:1));
   //---
   IndicatorSetString(INDICATOR_SHORTNAME,"Efficiency ratio ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function                              
//------------------------------------------------------------------
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
   //
   //---
   //
   
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _efr    = iEr(getPrice(inpPrice,open,close,high,low,i),inpPeriod,i,rates_total);
             val[i]  = (i>0) ? val[i-1]+ª_alpha*(_efr-val[i-1]) : _efr;
             lup[i]  = (i>0) ? (val[i]<ldn[i-1]) ? lup[i-1] : lup[i-1]+ª_alphal*(val[i]-lup[i-1]) : val[i];
             ldn[i]  = (i>0) ? (val[i]>lup[i-1]) ? ldn[i-1] : ldn[i-1]+ª_alphal*(val[i]-ldn[i-1]) : val[i];
             valc[i] = (val[i]>lup[i]) ? 1 :(val[i]<ldn[i]) ? 2 : 0;
   }
   return (i);
}

//------------------------------------------------------------------
// Custom functions                                                 
//------------------------------------------------------------------
//
//---
//

#define _checkArrayReserve 500
#define _checkArraySize(_arrayName,_ratesTotal) { static bool _arrayError=false; static int _arrayResizedTo=0; if (_arrayResizedTo<_ratesTotal) { int _res = (_ratesTotal+_checkArrayReserve); _res -= ArrayResize(_arrayName,_ratesTotal+_checkArrayReserve); if (_res) _arrayError=true; else { _arrayResizedTo=_ratesTotal+_checkArrayReserve; }}}

//
//---
//

#define _erInstancesSize 3 
#define _erDirectional
double _erArray[][_erInstancesSize];

double iEr(double value, int period, int i, int bars, int instance=0)
{
   _checkArraySize(_erArray,bars);
   #define _values instance
   #define _diff   instance+1
   #define _noise  instance+2

      //
      //---
      //
      
      instance *= _erInstancesSize;
         _erArray[i][_values] = value;
         _erArray[i][_diff]   = (i>0)? (_erArray[i][_values]>_erArray[i-1][_values]) ? _erArray[i][_values]-_erArray[i-1][_values] : _erArray[i-1][_values]-_erArray[i][_values] : 0;
         if (i<=period)
             { _erArray[i][_noise] = _erArray[i][_diff]; for(int k=1; k<period && (i-k)>=0; k++) _erArray[i][_noise] += _erArray[i-k][_diff]; }
         else  _erArray[i][_noise] = _erArray[i-1][_noise]-_erArray[i-period][_diff]+_erArray[i][_diff];

         //
         //---
         //
      
      #ifdef _erDirectional
            double _efr = (_erArray[i][_noise]!=0 && i>period) ? (_erArray[i][_values]-_erArray[i-period][_values])/_erArray[i][_noise] : 0;
      #else 
            double _efr = (_erArray[i][_noise]!=0 && i>period) ? (_erArray[i][_values]>_erArray[i-period][_values] ? _erArray[i][_values]-_erArray[i-period][_values] : _erArray[i-period][_values]-_erArray[i][_values])/_erArray[i][_noise] : 0;
      #endif              
      return(_efr);   
   
   //
   //---
   //
   
   #undef _values
   #undef _diff
   #undef _noise
   #undef _erDirectional
}

//
//----
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
//+------------------------------------------------------------------+
