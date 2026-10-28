//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_DOT
#property indicator_label3  "T3"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//---
//

enum enT3Type
{
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
};
enum enLevel
{
   level_1, // First level : GDEMA
   level_2, // Second level : GDEMA of GDEMA
   level_3  // Third level : T3   
};
input int                inpPeriod         = 9;           // T3 period
input double             inpVolumeFactor   = 0.3;         // T3 volume factor
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price
input enT3Type           inpType           = t3_tillson;  // T3 type
input enLevel            inpLevel          = level_3;     // Level to display :

//
//---
//

double val[],valc[],levelUp[],levelDn[];
bool ª_isOriginal; int ª_level;

//------------------------------------------------------------------
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,levelUp,INDICATOR_DATA); 
         SetIndexBuffer(1,levelDn,INDICATOR_DATA);
         SetIndexBuffer(2,val    ,INDICATOR_DATA);
         SetIndexBuffer(3,valc   ,INDICATOR_COLOR_INDEX);
            PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
            PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   //
   //---
   //         
         ª_isOriginal = (inpType==t3_tillson);
         ª_level      = (inpLevel*2);
   //         
   //----
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stripped T3 levels ("+(string)inpPeriod+")");
}

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
      val[i]     = iT3(_price,inpPeriod,inpVolumeFactor,ª_isOriginal,ª_level,i,false,0);
      levelUp[i] = iT3(val[i],inpPeriod,inpVolumeFactor,ª_isOriginal,ª_level,i,(i>0 ? !(val[i]>levelDn[i-1]) : false),1);
      levelDn[i] = iT3(val[i],inpPeriod,inpVolumeFactor,ª_isOriginal,ª_level,i,(i>0 ? !(val[i]<levelUp[i-1]) : false),2);
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iT3(double price, double period, double volume, bool original, int level, int i, bool copy, int _instance=0)
{
   //
   //---
   //
   
      #define _functionInstances 3
      #define _functionInstancesArraySize 7
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

         if(_originalPeriod!=period)
         {
            _originalPeriod = period;
                  _volume   = (volume>0 && volume<1) ? volume : 0.7;
                  _volumepl = _volume+1.0;
                  _alpha    = (original) ? 2.0/(1.0+(period>1?period:1)) : 2.0/(2.0+((period>1?period:1)-1.0)/2.0);
         }

      #ifdef  _functionInstances
                int _winst = _instance*_functionInstancesArraySize;
      #else #define _winst _instance
      #endif
   
   //
   //--
   //
   
      int _indC = (i  )%_functionArrayRingSize;
      int _indP = (i-1)%_functionArrayRingSize;
      if(!copy && i>0 && period>1.0)
      {
         #define _gdema(_ind1,_ind2) (_workArray[_indC][_winst+_ind1]*_volumepl-_workArray[_indC][_winst+_ind2]*_volume)
         
            //
            //---
            //
         
            _workArray[_indC][_winst  ] = _workArray[_indP][_winst  ]+_alpha*(price                      -_workArray[_indP][_winst  ]);
            _workArray[_indC][_winst+1] = _workArray[_indP][_winst+1]+_alpha*(_workArray[_indC][_winst  ]-_workArray[_indP][_winst+1]);
            _workArray[_indC][_winst+2] = _workArray[_indP][_winst+2]+_alpha*(_gdema(0,1)                -_workArray[_indP][_winst+2]);
            _workArray[_indC][_winst+3] = _workArray[_indP][_winst+3]+_alpha*(_workArray[_indC][_winst+2]-_workArray[_indP][_winst+3]);
            _workArray[_indC][_winst+4] = _workArray[_indP][_winst+4]+_alpha*(_gdema(2,3)                -_workArray[_indP][_winst+4]);
            _workArray[_indC][_winst+5] = _workArray[_indP][_winst+5]+_alpha*(_workArray[_indC][_winst+4]-_workArray[_indP][_winst+5]);
            _workArray[_indC][_winst+6] = _gdema(level,level+1);
      }
      else for(int k=0; k<_functionInstancesArraySize; k++) _workArray[_indC][k+_winst] = (i>0) ? _workArray[_indP][k+_winst] : price;
   return(_workArray[_indC][_winst+6]);
   
   //
   //---
   //

   #undef _originalPeriod #undef _volume #undef _volumepl #undef _alpha
   #undef _functionInstances #undef _functionArrayRingSize #undef _functionInstancesArraySize #undef _winst 
}
//------------------------------------------------------------------