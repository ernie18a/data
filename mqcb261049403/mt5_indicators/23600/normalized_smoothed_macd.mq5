//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Normalized MACD"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2
#property indicator_label1  "Normalized MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
#property indicator_label2  "Normalized MACD signal line"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrDodgerBlue,clrSandyBrown
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
double val[],valc[],sig[],sigc[],macd[],emaf[],emas[],sigu[],sigd[];
double ª_alphaf,ª_alphas,ª_alphasig,ª_alphasm; int ª_normPeriodm1;

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
   SetIndexBuffer(7,sigu,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,sigd,INDICATOR_CALCULATIONS);
         ª_alphaf   = 2.0/(1.0+MathMax(inpFastPeriod,1));
         ª_alphas   = 2.0/(1.0+MathMax(inpSlowPeriod,1));
         ª_alphasig = 2.0/(1.0+MathMax(inpMacdSignal,1));
         ª_alphasm  = 2.0/(1.0+MathMax(inpSmoothPeriod,1));
         ª_normPeriodm1 = inpNormPeriod>1 ? inpNormPeriod-1 : 1;
   
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
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         if (i>0)
         {
            emaf[i] = emaf[i-1]+ª_alphaf*(_price-emaf[i-1]);
            emas[i] = emas[i-1]+ª_alphas*(_price-emas[i-1]);
         }
         else emaf[i] = emas[i] = _price;
              macd[i] = emaf[i]-emas[i];
         
         //
         //---
         //
         
         if (prev_i!=i)
         {
            int _start = i-inpNormPeriod+1; if (_start<0) _start = 0;;
               prev_max = macd[ArrayMaximum(macd,_start,ª_normPeriodm1)];            
               prev_min = macd[ArrayMinimum(macd,_start,ª_normPeriodm1)];            
               prev_i   = i;
         }      
         double max  = (macd[i]>prev_max) ? macd[i] : prev_max;
         double min  = (macd[i]<prev_min) ? macd[i] : prev_min;
         double nval = (min!=max) ? 2.0*(macd[i]-min)/(max-min)-1.0 : 0;
         if (i>0)
         {
            val[i]  =  val[i-1] + ª_alphasm*(nval-val[i-1]);
            sigu[i] = (val[i]>0) ? sigu[i-1]+ª_alphasig*(val[i]-sigu[i-1]) : sigu[i-1]; 
            sigd[i] = (val[i]<0) ? sigd[i-1]+ª_alphasig*(val[i]-sigd[i-1]) : sigd[i-1]; 
            sig[i]  = (val[i]>0) ? sigu[i-1] : sigd[i];
         }            
         else sigu[i] = sigd[i] = sig[i] = val[i] = 0;
         sigc[i] = valc[i] = (val[i]>sigu[i]) ? 1 : (val[i]<sigd[i]) ? 2 : 0;
   }          
   return(i);
}