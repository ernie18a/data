//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Stochastic of filtered price"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Stochastic of filtered price"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input int                inpStoPeriod  = 32;          // Stochastic period
input int                inpStoSlowing =  3;          // Stochastic slowing
input int                inpFilPeriod  =  0;          // Filter period (0 for same as stochastic period)
input double             inpFilSize    =  2;          // Filter size
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 

//
//--- buffers declarations
//

double val[],valc[];
int  ª_filPeriod; 

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
         //---
         //
         
         ª_filPeriod = (inpFilPeriod>0) ? inpFilPeriod : inpStoPeriod;
         IndicatorSetInteger(INDICATOR_LEVELS,2);
            IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0);
            IndicatorSetDouble(INDICATOR_LEVELVALUE,1,100);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic of filtered price ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)ª_filPeriod+","+(string)inpFilSize+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//  Custom indicator iteration function
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
             _price = iFilter(_price,inpFilSize,ª_filPeriod,i,rates_total);
         val[i]  = iStoch(_price,_price,_price,inpStoPeriod,inpStoSlowing,i);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return (i);
}

//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iStoch(double price, double priceHigh, double priceLow, int period, int slowing, int i,int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1
   #define _functionRingSize 32
   
      class cStochasticWork
      {
         public :
            int    originalPeriod;
            int    period;
            int    slowing;
            int    slowingSize;
            double maxArray[];
            double minArray[];
            double diffh[];
            double diffl[];
            double sumh[];
            double suml[];
         
            cStochasticWork() { originalPeriod=-1; return; }
           ~cStochasticWork() { ArrayFree(maxArray); ArrayFree(minArray); ArrayFree(diffh); ArrayFree(diffl); ArrayFree(sumh); ArrayFree(suml); return; }
      };
      static cStochasticWork  m_work[_functionInstances];
         if (m_work[¤].originalPeriod!=period)
         {
            m_work[¤].originalPeriod =  period;
            m_work[¤].period         = (period>0) ? period : 1;
            m_work[¤].slowing        = (slowing>0) ? slowing : 1;
            m_work[¤].slowingSize    = m_work[¤].slowing+_functionRingSize;
                  ArrayResize(m_work[¤].maxArray,m_work[¤].period);      ArrayInitialize(m_work[¤].maxArray,priceHigh);
                  ArrayResize(m_work[¤].minArray,m_work[¤].period);      ArrayInitialize(m_work[¤].minArray,priceLow);
                  ArrayResize(m_work[¤].diffh   ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].diffh   ,0);
                  ArrayResize(m_work[¤].diffl   ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].diffl   ,0);
                  ArrayResize(m_work[¤].sumh    ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].sumh    ,0);
                  ArrayResize(m_work[¤].suml    ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].suml    ,0);
         }
      
      //
      //---
      //
      
      int _pos = (i) % m_work[¤].period;
                       m_work[¤].minArray[_pos]=priceLow;
                       m_work[¤].maxArray[_pos]=priceHigh;
         double min =  m_work[¤].minArray[ArrayMinimum(m_work[¤].minArray)];
         double max =  m_work[¤].maxArray[ArrayMaximum(m_work[¤].maxArray)];
               _pos = (i) % m_work[¤].slowingSize;
                       m_work[¤].diffh[_pos] = max  -min;
                       m_work[¤].diffl[_pos] = price-min;

                       //
                       //---
                       //
                         
                       if (i>m_work[¤].slowing)
                       {
                           int _posp = (i-1                ) % m_work[¤].slowingSize;
                           int _posf = (i-m_work[¤].slowing) % m_work[¤].slowingSize;
                              m_work[¤].sumh[_pos] = m_work[¤].sumh[_posp]+m_work[¤].diffh[_pos]-m_work[¤].diffh[_posf];
                              m_work[¤].suml[_pos] = m_work[¤].suml[_posp]+m_work[¤].diffl[_pos]-m_work[¤].diffl[_posf];
                       }
                       else
                       {
                           m_work[¤].sumh[_pos] = m_work[¤].diffh[_pos];
                           m_work[¤].suml[_pos] = m_work[¤].diffl[_pos];
                           for (int k=1, _posp=_pos-1; k<m_work[¤].slowing; k++, _posp--)
                           {
                              if (_posp<0) _posp += m_work[¤].slowingSize; 
                                 m_work[¤].sumh[_pos] += m_work[¤].diffh[_posp];
                                 m_work[¤].suml[_pos] += m_work[¤].diffl[_posp];
                           }
                       }
      return((m_work[¤].sumh[_pos]!=0.0)? 100.0*m_work[¤].suml[_pos]/m_work[¤].sumh[_pos]:0);
      
      //
      //---
      //
      
   #undef ¤ #undef _functionInstances #undef _functionRingSize
}

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
