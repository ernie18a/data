//------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  6
#property indicator_plots    3
#property indicator_label1   "Uper DC"
#property indicator_type1    DRAW_FILLING
#property indicator_color1   C'200,225,200'
#property indicator_label2   "Lower DC"
#property indicator_type2    DRAW_FILLING
#property indicator_color2   clrBisque
#property indicator_label3   "OBV"
#property indicator_type3    DRAW_COLOR_LINE
#property indicator_color3   clrSilver,clrMediumSeaGreen,clrLimeGreen,clrDarkOrange,clrOrange
#property indicator_width3   2

//
//
//

input ENUM_APPLIED_VOLUME inpVolumeType = VOLUME_TICK; // Volumes
input uint                inpDcPeriod   = 50;          // Donchian channel period

//
//
//

double val[],valc[],dcuph[],dcupl[],dcdnh[],dcdnl[];

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,dcuph,INDICATOR_DATA);
   SetIndexBuffer(1,dcupl,INDICATOR_DATA);
   SetIndexBuffer(2,dcdnh,INDICATOR_DATA);
   SetIndexBuffer(3,dcdnl,INDICATOR_DATA);
   SetIndexBuffer(4,val  ,INDICATOR_DATA);
   SetIndexBuffer(5,valc ,INDICATOR_COLOR_INDEX);
   
      //
      //
      //

   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);               
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);               
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("OBV (%i)",inpDcPeriod));            
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      for (int i=_limit; i<rates_total && !_StopFlag; i++)
         {
            double _volume = (inpVolumeType==VOLUME_TICK) ? (double)tick_volume[i] : volume[i];
            val[i] = (i>0) ? (close[i]>close[i-1]) ? val[i-1]+_volume :  (close[i]<close[i-1]) ? val[i-1]-_volume : val[i-1] : 0;
               
               //
               //
               //
       
               if (inpDcPeriod>0)
               {
                  int _start = int(i-inpDcPeriod); if (_start<0) _start=0;
                     double _max = val[ArrayMaximum(val,_start,inpDcPeriod)];
                     double _min = val[ArrayMinimum(val,_start,inpDcPeriod)];
                     
                        dcuph[i] = _max; dcupl[i] = _max-(_max-_min)/5.0;
                        dcdnl[i] = _min; dcdnh[i] = _min+(_max-_min)/5.0;

                        //
                        //
                        //
                        
                        valc[i] = (val[i]>dcuph[i]) ? 2 : (val[i]>dcupl[i]) ? 1 : (val[i]<dcdnl[i]) ? 4: (val[i]<dcdnh[i]) ? 3 : 0;
               }
               else { dcuph[i] = dcupl[i] = dcdnh[i] = dcdnl[i] = EMPTY_VALUE; valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 3 : 0; }
         }

   //
   //
   //

   return(rates_total);
}