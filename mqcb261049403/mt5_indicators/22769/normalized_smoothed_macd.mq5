//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Normalized MACD"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "Normalized MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
#property indicator_label2  "Normalized MACD signal line"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDodgerBlue,clrSandyBrown
#property indicator_style2  STYLE_DOT
//
//--- input parameters
//
input int                inpFastPeriod   = 12;           // MACD fast period
input int                inpSlowPeriod   = 26;           // MACD slow period
input int                inpMacdSignal   = 9;            // Signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;  // Price
input int                inpSmoothPeriod = 5;            // Smoothing period
input int                inpNormPeriod   = 20;           // Normalization period
//
//--- indicator buffers
//
double val[],valc[],sig[],sigc[],macd[],emaf[],emas[];
double ª_alphaf,ª_alphas,ª_alphasig,ª_alphasm; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,sig ,INDICATOR_DATA);
   SetIndexBuffer(3,sigc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,macd,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,emaf,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,emas,INDICATOR_CALCULATIONS);
         ª_alphaf   = 2.0/(1.0+MathMax(inpFastPeriod,1));
         ª_alphas   = 2.0/(1.0+MathMax(inpSlowPeriod,1));
         ª_alphasig = 2.0/(1.0+MathMax(inpMacdSignal,1));
         ª_alphasm  = 2.0/(1.0+MathMax(inpSmoothPeriod,1));
   
   //---
            
   IndicatorSetString(INDICATOR_SHORTNAME,"Normalized MACD ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpMacdSignal+")");
   return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
//
//---
//

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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         emaf[i] = (i>0) ? emaf[i-1]+ª_alphaf*(_price-emaf[i-1]) : _price;
         emas[i] = (i>0) ? emas[i-1]+ª_alphas*(_price-emas[i-1]) : _price;
         macd[i] = emaf[i]-emas[i];
         
         //
         //---
         //
         
         int _start = (i>inpNormPeriod) ? i-inpNormPeriod+1 : 0;
            double _max = macd[ArrayMaximum(macd,_start,inpNormPeriod)];            
            double _min = macd[ArrayMinimum(macd,_start,inpNormPeriod)];            
            double _nval = (_min!=_max) ? 2.0*(macd[i]-_min)/(_max-_min)-1.0 : 0;
         val[i]  = (i>0) ? val[i-1] + ª_alphasm*(_nval-val[i-1]) : 0;
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 0 : 1 : 0;
         sig[i]  = (i>0) ? sig[i-1] + ª_alphasig*(val[i]-sig[i-1]) : 0;
         sigc[i] = (val[i]>sig[i]) ? 0 : 1;
   }          
   return(rates_total);
}