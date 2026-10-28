//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "m_oscillator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1 2
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver

//
//
//

input int                 inpPeriod    =  14;          // Period 
input int                 inpPeriod1   =   5;          // Smoothing period 1
input int                 inpPeriod2   =   3;          // Smoothing period 2
input int                 inpPeriod3   =   3;          // Signal period
input ENUM_APPLIED_PRICE  inpPrice     =  PRICE_CLOSE; // Price
input double              inpLevelUp   =  10;          // Upper level
input double              inpLevelDn   = -10;          // Lower level
enum enColorOn
{
   coloron_slopeChange, // Change color on slope change
   coloron_levelsCross, // Change color on levels cross
   coloron_signalCross, // Change color on signal line cross
   coloron_zeroCross    // Change color on zero line cross
};
input enColorOn           inpColorOn = coloron_signalCross; // Color change mode

double val[],valc[],signal[],_alpha1,_alpha2,_alpha3,_step;

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
         SetIndexBuffer(2,signal);
            _alpha1 = 2.0/(1.0+(inpPeriod1>1 ? inpPeriod1 : 1));
            _alpha2 = 2.0/(1.0+(inpPeriod2>1 ? inpPeriod2 : 1));
            _alpha3 = 2.0/(1.0+(inpPeriod3>1 ? inpPeriod3 : 1));
            _step   = 14/(double)(inpPeriod>1 ? inpPeriod : 1);
         IndicatorSetInteger(INDICATOR_LEVELS,2);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpLevelUp);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpLevelDn);
   //
   //---
   //

   IndicatorSetString(INDICATOR_SHORTNAME,"M-Oscillator (extended)("+(string)inpPeriod+")("+(string)inpPeriod1+","+(string)inpPeriod2+","+(string)inpPeriod3+")");
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


int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   struct sMoscStruct
   {
      double price;
      double summ;
      double ema;
   };
   static sMoscStruct m_array[];
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
                         m_array[i].summ = 0;
                         for (int k=0; k<inpPeriod && i>=k; k++) m_array[i].summ += (m_array[i].price>m_array[i-k].price) ? +_step : (m_array[i].price<m_array[i-k].price) ? -_step : 0;
                         if (i>0)
                         {
                           m_array[i].ema = m_array[i-1].ema+_alpha1*(m_array[i].summ-m_array[i-1].ema);
                           val[i]         = val[i-1]        +_alpha2*(m_array[i].ema -val[i-1]);
                           signal[i]      = signal[i-1]     +_alpha3*(val[i]         -signal[i-1]);
                           switch (inpColorOn) 
                           {
                              case coloron_slopeChange : valc[i] = (val[i]>val[i-1])   ? 1 : (val[i]<val[i-1])   ? 2 : 0 ; break;
                              case coloron_levelsCross : valc[i] = (val[i]>inpLevelUp) ? 1 : (val[i]<inpLevelDn) ? 2 : 0 ; break;
                              case coloron_signalCross : valc[i] = (val[i]>signal[i])  ? 1 : (val[i]<signal[i])  ? 2 : 0 ; break;
                              case coloron_zeroCross :   valc[i] = (val[i]>0)          ? 1 : (val[i]<0)          ? 2 : 0 ; break;
                           }                              
                        }
                        else val[i]= signal[i] = valc[i] = 0;
   }               
   return(i);        
}