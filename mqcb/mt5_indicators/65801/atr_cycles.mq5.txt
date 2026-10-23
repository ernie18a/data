//+------------------------------------------------------------------+
//|                                                   ATR_Cycles.mq5 |
//|                 Original: Stage3_VCycles, http://Stage3forex.com |
//| This converted from mod: Ale, http://www.mql4.com/ru/users/ale00 |									
//+------------------------------------------------------------------+
#property copyright "© 2023, Ryan Lawrence Johnson"
#property link      "https://www.mql5.com/en/users/rjo/seller"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 8

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 clrBlack
#property indicator_width1 5

#property indicator_type2 DRAW_LINE
#property indicator_color2 clrSlateGray
#property indicator_width2 1

#property indicator_type3 DRAW_HISTOGRAM
#property indicator_color3 clrMediumTurquoise
#property indicator_width3 4

#property indicator_type4 DRAW_LINE
#property indicator_color4 clrMediumTurquoise
#property indicator_width4 4

#property indicator_type5 DRAW_HISTOGRAM
#property indicator_color5 clrTeal
#property indicator_width5 2

#property indicator_type6 DRAW_LINE
#property indicator_color6 clrTeal
#property indicator_width6 4

#property indicator_type7 DRAW_HISTOGRAM
#property indicator_color7 clrMediumTurquoise
#property indicator_width7 2

#property indicator_type8 DRAW_HISTOGRAM
#property indicator_color8 clrTeal
#property indicator_width8 3

input int Period_Fast = 6;
input int Period_Mid = 18;
input int Period_Slow = 55;
input int Bar_Size = 5;

int handle_iATR_Slow;
int handle_iATR_Mid;
int handle_iATR_Fast;

double buff_Slow_Histo[];
double buff_Slow_Line[];
double buff_Mid_Histo[];
double buff_Mid_Line[];
double buff_Fast_Histo[];
double buff_Fast_Line[];
double buff_Incr[];
double buff_Decr[];

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iATR_Slow != INVALID_HANDLE) IndicatorRelease(handle_iATR_Slow);
   if(handle_iATR_Fast != INVALID_HANDLE) IndicatorRelease(handle_iATR_Fast);
   if(handle_iATR_Mid != INVALID_HANDLE) IndicatorRelease(handle_iATR_Mid);   
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, buff_Slow_Histo, INDICATOR_DATA);
	PlotIndexSetString(0, PLOT_LABEL, "ATR Slow");  

	SetIndexBuffer(1, buff_Slow_Line, INDICATOR_DATA);
	PlotIndexSetString(1, PLOT_LABEL, "ATR Slow");

	SetIndexBuffer(2, buff_Fast_Histo, INDICATOR_DATA);
	PlotIndexSetString(2, PLOT_LABEL, "ATR Fast");

	SetIndexBuffer(3, buff_Fast_Line, INDICATOR_DATA);
	PlotIndexSetString(3, PLOT_LABEL, "ATR Fast");

	SetIndexBuffer(4, buff_Mid_Histo, INDICATOR_DATA);
	PlotIndexSetString(4, PLOT_LABEL, "ATR Mid");
	
	SetIndexBuffer(5, buff_Mid_Line, INDICATOR_DATA);
	PlotIndexSetString(5, PLOT_LABEL, "ATR Mid");

	SetIndexBuffer(6, buff_Incr, INDICATOR_DATA);
	PlotIndexSetString(6, PLOT_LABEL, "ATR Incr");
	
	SetIndexBuffer(7, buff_Decr, INDICATOR_DATA);
	PlotIndexSetString(7, PLOT_LABEL, "ATR Decr");
	
	handle_iATR_Slow = iATR(NULL, 0, Period_Slow);
	handle_iATR_Fast = iATR(NULL, 0, Period_Fast);
	handle_iATR_Mid = iATR(NULL, 0, Period_Mid);	
	
	IndicatorSetString(INDICATOR_SHORTNAME, "ATR " + (string)Period_Fast + " " + (string)Period_Mid + " " + (string)Period_Slow);   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
	//if(IsStopped() == true)
	 //return(0);

   //--- checking the number of bars
   //if (rates_total < Period_Slow - 1)
    //return(0);

	ArraySetAsSeries(buff_Slow_Histo, true);
	ArraySetAsSeries(buff_Slow_Line, true);	
	ArraySetAsSeries(buff_Fast_Histo, true);
	ArraySetAsSeries(buff_Fast_Line, true);
	ArraySetAsSeries(buff_Mid_Histo, true);			
	ArraySetAsSeries(buff_Mid_Line, true);
	ArraySetAsSeries(buff_Incr, true);
	ArraySetAsSeries(buff_Decr, true);

   int copyBars;
   int limit;
   int bar;
   
   //--- calculation of the starting bar index
   if (prev_calculated == 0) // check for the first call of OnCalculate function
    {                      
       limit = rates_total - Period_Slow - 1;  // starting index for the calculation of all of the bars
       copyBars = rates_total - Period_Slow - 1;
    }
   else
    {
     limit = rates_total - prev_calculated; // starting index for the calculation of new bars
     copyBars = rates_total - prev_calculated;
    }
   
   //if(IsStopped() == true)
    //return(0);
   
	if(CopyBuffer(handle_iATR_Slow, 0, 0, copyBars, buff_Slow_Histo) <= 0
	   || CopyBuffer(handle_iATR_Fast, 0, 0, copyBars, buff_Fast_Histo) <= 0
	   || CopyBuffer(handle_iATR_Mid, 0, 0, copyBars, buff_Mid_Histo) <= 0)
	    return(0);
   
   //--- main loop
   for(bar = limit; bar >= 0; bar--)
    {
		//buff_Slow_Histo[bar] = 
		//buff_Mid_Histo[bar] =
		//buff_Fast_Histo[bar] = 
		buff_Slow_Line[bar] = buff_Slow_Histo[bar];
		buff_Mid_Line[bar] = buff_Mid_Histo[bar];
		buff_Fast_Line[bar] = buff_Fast_Histo[bar];
		buff_Decr[bar] = EMPTY_VALUE; buff_Incr[bar] = EMPTY_VALUE;
		
		if(buff_Mid_Line[bar] > buff_Mid_Line[bar+1]
			&& buff_Fast_Line[bar] > buff_Fast_Line[bar+1])
			 {
			  buff_Incr[bar] = Bar_Size * _Point;
			 }
		else if(buff_Mid_Line[bar] < buff_Mid_Line[bar+1]
			&& buff_Fast_Line[bar] < buff_Fast_Line[bar+1])
			 {
			  buff_Decr[bar] = Bar_Size * _Point;
			 }
    }   
//--- return value of prev_calculated for next call
   return(rates_total - Period_Slow);
  }
//+------------------------------------------------------------------+
