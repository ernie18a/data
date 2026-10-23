//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Deviation filtered price"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrMediumSeaGreen
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod = 14;           // Period
input double             inpFilter = 2.5;          // Filter size
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price

//
//--- indicator buffers
//
double val[],valc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Deviation filtered price ("+(string)inpPeriod+","+(string)inpFilter+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

//------------------------------------------------------------------
// Custom indicator iteration function
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         val[i]  = iFilter(_price,inpFilter,inpPeriod,i,rates_total);
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iFilter(double value, double filter, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1
      struct sFilterArrayStruct
         {
            double value;
            double change;
            double power;
            double summc;
            double summp;
         };
      static sFilterArrayStruct m_array[][_functionInstances];
      static int m_arraySize = 0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<bars) return(0);
                     m_arraySize = _res;
             }

      //
      //---
      //
   
      m_array[i][¤].value  = value;  double _change = (i>0) ? m_array[i][¤].value-m_array[i-1][¤].value : 0;
      m_array[i][¤].change = (_change>0) ? _change : - _change;
         if (i>period)
         {
            #define _power(_val) ((_val)*(_val))
              m_array[i][¤].summc =  m_array[i-1][¤].summc +m_array[i][¤].change-m_array[i-period][¤].change;
              m_array[i][¤].power = _power(m_array[i][¤].change-m_array[i][¤].summc/(double)period);
              m_array[i][¤].summp =  m_array[i-1][¤].summp+m_array[i][¤].power-m_array[i-period][¤].power;
         }              
         else
         {
            m_array[i][¤].summc  = 
            m_array[i][¤].summp = 0; 
            for(int k=0; k<period && i>=k; k++) m_array[i][¤].summc += m_array[i-k][¤].change; 
                                                m_array[i][¤].power  = _power(m_array[i][¤].change-m_array[i][¤].summc/(double)period);
            for(int k=0; k<period && i>=k; k++) m_array[i][¤].summp += m_array[i-k][¤].power; 
         }            
         if (i>0 && filter>0 && m_array[i][¤].change<filter*MathSqrt(m_array[i][¤].summp/(double)period)) m_array[i][¤].value=m_array[i-1][¤].value;
   return (m_array[i][¤].value);

   //
   //---
   //
            
   #undef ¤ #undef _power #undef _functionInstances
}
//------------------------------------------------------------------