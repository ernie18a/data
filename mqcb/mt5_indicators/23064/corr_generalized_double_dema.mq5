//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "Corrected average zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'230,230,230'
#property indicator_label2  "Corrected average middle"
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrGray
#property indicator_label3  "Corrected average original"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_label4  "Corrected average "
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  3

//
//---
//

enum chgColor
{
   chg_onSlope,  // change color on slope change
   chg_onLevel,  // Change color on outer levels cross
   chg_onMiddle, // Change color on middle level cross
   chg_onOrig    // Change color on average value cross
};
input int                inpPeriod           = 25;             // Double GDEMA period
input double             inpVolumeFactor     = 0.7;            // Volume factor
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE;    // Price
input int                inpCorrectionPeriod =  0;             // "Correction" period (<0 no correction,0 or 1 same as average)
input chgColor           inpColorOn          = chg_onLevel;    // Color change on :
input int                inpFlPeriod         = 25;             // Floating levels period
input double             inpFlUp             = 90;             // Upper level %
input double             inpFlDown           = 10;             // Lower level %

//
//---
//

double val[],valc[],mid[],fup[],fdn[],avg[],avgc[];
int  ª_corrPeriod,ª_colorOn; 

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,fup ,INDICATOR_DATA);
         SetIndexBuffer(1,fdn ,INDICATOR_DATA);
         SetIndexBuffer(2,mid ,INDICATOR_DATA);
         SetIndexBuffer(3,avg ,INDICATOR_DATA);
         SetIndexBuffer(4,avgc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,val ,INDICATOR_DATA);
         SetIndexBuffer(6,valc,INDICATOR_COLOR_INDEX);
         
         ª_corrPeriod = (inpCorrectionPeriod>0) ? inpCorrectionPeriod : (inpCorrectionPeriod<0) ? 0 : inpPeriod ;
         ª_colorOn    = (inpFlPeriod>1 && ª_corrPeriod>1) ? inpColorOn : (inpColorOn!=chg_onOrig) ? inpColorOn : chg_onSlope;
   //
   //---
   //      
   IndicatorSetString(INDICATOR_SHORTNAME,"\"Corrected\" double GDEMA ("+(string)inpPeriod+","+(string)inpCorrectionPeriod+")");
   return(0);
}

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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
          avg[i] = iGdema2(_price,inpPeriod,inpVolumeFactor,i);
          val[i] = iCorrMa(_price,avg[i],ª_corrPeriod,i,rates_total);

            int    start = (i-inpFlPeriod+1); if (start<0) start=0;
            double min   =  val[ArrayMinimum(val,start,inpFlPeriod)];
            double range = (val[ArrayMaximum(val,start,inpFlPeriod)]-min)/100.0;
                  fup[i] = min+inpFlUp  *range;
                  fdn[i] = min+inpFlDown*range;
                  mid[i] = (fup[i]+fdn[i])/2.0;

            //
            //---
            //
                              
            avgc[i] = (avg[i]>val[i]) ? 1 : (avg[i]<val[i]) ? 2 : 0;
            switch (ª_colorOn)
            {
               case chg_onOrig   : valc[i] = avgc[i]; break;
               case chg_onLevel  : valc[i] = (val[i]>fup[i]) ? 1 : (val[i]<fdn[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               case chg_onMiddle : valc[i] = (val[i]>mid[i]) ? 1 : (val[i]<mid[i])  ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1] : 0 : 0; break;
               default :           valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
            }                  
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//
//

double iCorrMa(double price, double average, int period, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1
      struct sCorrMaStruct
      {
         double corrected;
         double price;
         double price2;
         double summ;
         double summ2;
      };
      static sCorrMaStruct m_array[][_functionInstances];
      static int m_arraySize=0;
             if (m_arraySize<bars)
             {
                 int _res = ArrayResize(m_array,bars+500);
                 if (_res<=bars) return(0);
                     m_arraySize = _res;
             }
      //
      //---
      //
      
      m_array[i][¤].price  = price;
      m_array[i][¤].price2 = price*price;
      if (i>period)
            {
               m_array[i][¤].summ  = m_array[i-1][¤].summ +price               -m_array[i-period][¤].price;
               m_array[i][¤].summ2 = m_array[i-1][¤].summ2+m_array[i][¤].price2-m_array[i-period][¤].price2;
            }
      else  {
               m_array[i][¤].summ  = m_array[i][¤].price;
               m_array[i][¤].summ2 = m_array[i][¤].price2; 
               for(int k=1; k<period && i>=k; k++) 
               {
                  m_array[i][¤].summ  += m_array[i-k][¤].price; 
                  m_array[i][¤].summ2 += m_array[i-k][¤].price2; 
               }                  
            }         

         //
         //---
         //
      
         double v1 = (m_array[i][¤].summ2-m_array[i][¤].summ*m_array[i][¤].summ/(double)period)/(double)period;
         double v2 = (i>0) ? (m_array[i-1][¤].corrected-average)*(m_array[i-1][¤].corrected-average) : 0;
         double c  = (v2<v1 || v2==0) ? 0 : 1.0-v1/v2;
         
          m_array[i][¤].corrected = (i>0) ? m_array[i-1][¤].corrected + c*(average-m_array[i-1][¤].corrected) : average;
   return(m_array[i][¤].corrected);
   
   //
   //---
   //
   
   #undef ¤ #undef _functionInstances
}

//
//---
//

double iGdema2(double price, double period, double volumeFactor, int i, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1      
   #define _functionArraySize 5
   #define _functionArrayRingSize 32
   
      //
      //---
      //
      
         struct sT3CoeffStruct
            {
               double OriginalPeriod;
               double OriginalVolume;
               double Volume;
               double CalcPeriod;
               double VolumePlus;
               double Alpha;
            };
         static sT3CoeffStruct m_coeff[_functionInstances];
         static double         m_array[_functionArrayRingSize][_functionInstances][_functionArraySize];
         if (m_coeff[¤].OriginalPeriod!=period || m_coeff[¤].OriginalVolume!=volumeFactor)
            {
               m_coeff[¤].OriginalPeriod =  period;
               m_coeff[¤].OriginalVolume =  volumeFactor;
               m_coeff[¤].Volume         = (volumeFactor>0) ? (volumeFactor>1) ? 1 : volumeFactor : DBL_MIN;
               m_coeff[¤].VolumePlus     =  m_coeff[¤].Volume+1;
               m_coeff[¤].CalcPeriod     = (period > 1 ? period : 1);
               m_coeff[¤].Alpha          = 2.0/(1.0+m_coeff[¤].CalcPeriod);
            }
   
      //
      //---
      //
   
      int _indC = (i)%_functionArrayRingSize;
      if(i>0 && m_coeff[¤].CalcPeriod>1)
      {
         int _indP = _indC-1; if (_indP<0) _indP +=_functionArrayRingSize;
            #define _gdema(_ind1,_ind2) (m_array[_indC][¤][_ind1]*m_coeff[¤].VolumePlus-m_array[_indC][¤][_ind2]*m_coeff[¤].Volume)
         
            //
            //---
            //
         
            m_array[_indC][¤][0] = m_array[_indP][¤][0]+m_coeff[¤].Alpha*(price               -m_array[_indP][¤][0]);
            m_array[_indC][¤][1] = m_array[_indP][¤][1]+m_coeff[¤].Alpha*(m_array[_indC][¤][0]-m_array[_indP][¤][1]);
            m_array[_indC][¤][2] = m_array[_indP][¤][2]+m_coeff[¤].Alpha*(_gdema(0,1)         -m_array[_indP][¤][2]);
            m_array[_indC][¤][3] = m_array[_indP][¤][3]+m_coeff[¤].Alpha*(m_array[_indC][¤][2]-m_array[_indP][¤][3]);
            m_array[_indC][¤][4] = _gdema(2,3);
      }
      else for(int k=0; k<_functionArraySize; k++) m_array[_indC][¤][k] = price;
   return(m_array[_indC][¤][4]);
   
   //
   //---
   //

   #undef ¤ #undef _gdema #undef _functionInstances #undef _functionArraySize #undef _functionArrayRingSize
}
//+------------------------------------------------------------------+
