//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Bandpass filter"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1 2

//
//
//

input int                 inpPeriod    = 50;           // Period
input double              inpDelta     = 0.5;          // Delta
input ENUM_APPLIED_PRICE  inpPrice     = PRICE_MEDIAN; // Price

double val[],valc[];
double g_alpha,g_alphal,g_beta;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,val);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
               
            double gamma     = 1.0 / MathCos(4.0*M_PI*inpDelta/inpPeriod);
                   g_beta    = MathCos(2.0*M_PI/inpPeriod);
                   g_alpha   = gamma -MathSqrt(gamma*gamma-1.0);
   
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"Bandpass filter ("+(string)inpPeriod+","+(string)inpDelta+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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

struct sBandPassStruct
{
   double price;
   double bandpass;
};
sBandPassStruct m_array[];

//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int m_arraySize = -1;
          if (m_arraySize<rates_total)
          {
              m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0);
          }

   //
   //---
   //
                                    
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,m_array[i].price,i);
         m_array[i].bandpass = (i>1) ? 0.5*(1.0-g_alpha)*(m_array[i].price-m_array[i-2].price)+g_beta*(1.0+g_alpha)*m_array[i-1].bandpass-g_alpha*m_array[i-2].bandpass : m_array[i].price;
         val[i]  = m_array[i].bandpass;
         valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : 0;
   }               
   return(i);        
}