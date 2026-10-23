//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Generalized DEMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Generalized DEMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrDarkOrange
#property indicator_width1  2

//
//---
//

input int                inpPeriod = 14;          // DEMA period
input double             inpVolume = 0.7;         // DEMA volume factor
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[];

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   //            
   //----
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Generalized DEMA ("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
//


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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]  = iGdema(_price,inpPeriod,inpVolume,i);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0 ;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom functions
//------------------------------------------------------------------
//
//---
//

double iGdema(double price, double period, double volumeFactor, int i, int _instance=0)
{
   //
   //---
   //
   
      #define _functionInstancesArraySize 3
      #define _functionInstancesCoeffSize 4
      #define _functionArrayRingSize 16
      #ifdef  _functionInstances
            static double _workArray[_functionArrayRingSize][_functionInstancesArraySize*_functionInstances];
            static double _workCoeff[_functionInstances    ][_functionInstancesCoeffSize];
      #else static double _workArray[_functionArrayRingSize][_functionInstancesArraySize];
            static double _workCoeff[1                     ][_functionInstancesCoeffSize];
      #endif
            
      //
      //---
      //            
      
      #define _originalPeriod _workCoeff[_instance][0]
      #define _alpha          _workCoeff[_instance][1]
      #define _volume         _workCoeff[_instance][2]
      #define _volumepl       _workCoeff[_instance][3]

         if(_originalPeriod!=period || volumeFactor!=_volume)
         {
            _originalPeriod = period;
                  _volume   = (volumeFactor>0) ? (volumeFactor>1) ? 1 : volumeFactor : 0.01;
                  _volumepl = _volume+1;
                  _alpha    = 2.0/(1.0+(period>1?period:1));
         }

      #ifdef  _functionInstances
                int _winst = _instance*_functionInstancesArraySize;
      #else #define _winst _instance
      #endif
   
   //
   //--
   //
   
      int _indC = (i)%_functionArrayRingSize;
      if(i>0 && period>1.0)
      {
         int _indP = (i-1)%_functionArrayRingSize;
            #define _gdema(_ind1,_ind2) (_workArray[_indC][_winst+_ind1]*_volumepl-_workArray[_indC][_winst+_ind2]*_volume)
         
            //
            //---
            //
         
            _workArray[_indC][_winst+1] = _workArray[_indP][_winst+1]+_alpha*(price                      -_workArray[_indP][_winst+1]);
            _workArray[_indC][_winst+2] = _workArray[_indP][_winst+2]+_alpha*(_workArray[_indC][_winst+1]-_workArray[_indP][_winst+2]);
            _workArray[_indC][_winst  ] = _gdema(1,2);
      }
      else for(int k=0; k<_functionInstancesArraySize; k++) _workArray[_indC][_winst+k] = price;
   return(_workArray[_indC][_winst]);
   
   //
   //---
   //

   #undef _originalPeriod #undef _volume #undef _volumepl #undef _alpha
   #undef _functionInstances #undef _functionArrayRingSize #undef _functionInstancesArraySize #undef _winst 
}
//------------------------------------------------------------------
