//+---------------------------------------------------------------------+
//|                                         ColorXMA_Ishimoku_StDev.mq5 | 
//|                                           Copyright © 2010, ellizii | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Äëÿ ðàáîòû  èíäèêàòîðà  ñëåäóåò  ïîëîæèòü ôàéë SmoothAlgorithms.mqh |
//| â ïàïêó (äèðåêòîðèþ): êàòàëîã_äàííûõ_òåðìèíàëà\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, ellizii"
#property link ""
#property description "Ishimoku XMA StDev"
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå

//---- îòðèñîâêà èíäèêàòîðà â îñíîâíîì îêíå
#property indicator_chart_window
//---- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî øåñòü áóôåðîâ
#property indicator_buffers 6
//---- èñïîëüçîâàíî âñåãî ïÿòü ãðàôè÷åñêèõ ïîñòðîåíèé
#property indicator_plots   5
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ëèíèè èíäèêàòîðà         |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà â âèäå ëèíèè
#property indicator_type1   DRAW_COLOR_LINE
//---- â êà÷åñòâå öâåòîâ òðåõöâåòíîé ëèíèè èñïîëüçîâàíû
#property indicator_color1  clrMagenta,clrGray,clrBlue
//---- ëèíèÿ èíäèêàòîðà - íåïðåðûâíàÿ êðèâàÿ
#property indicator_style1  STYLE_SOLID
//---- òîëùèíà ëèíèè èíäèêàòîðà ðàâíà 2
#property indicator_width1  2
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  "XMA_Ishimoku"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//---- â êà÷åñòâå öâåòà ìåäâåæüåãî èíäèêàòîðà èñïîëüçîâàí êðàñíûé öâåò
#property indicator_color2  clrRed
//---- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 2
#property indicator_width2  2
//---- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label2  "Dn_Signal 1"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà       |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 3 â âèäå ñèìâîëà
#property indicator_type3   DRAW_ARROW
//---- â êà÷åñòâå öâåòà áû÷üåãî èíäèêàòîðà èñïîëüçîâàí ñàëàòîâûé öâåò
#property indicator_color3  clrLime
//---- òîëùèíà ëèíèè èíäèêàòîðà 3 ðàâíà 2
#property indicator_width3  2
//---- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label3  "Up_Signal 1"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 4 â âèäå ñèìâîëà
#property indicator_type4   DRAW_ARROW
//---- â êà÷åñòâå öâåòà ìåäâåæüåãî èíäèêàòîðà èñïîëüçîâàí êðàñíûé öâåò
#property indicator_color4  clrRed
//---- òîëùèíà ëèíèè èíäèêàòîðà 4 ðàâíà 4
#property indicator_width4  4
//---- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label4  "Dn_Signal 2"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà        |
//+----------------------------------------------+
//---- îòðèñîâêà èíäèêàòîðà 5 â âèäå ñèìâîëà
#property indicator_type5   DRAW_ARROW
//---- â êà÷åñòâå öâåòà áû÷üåãî èíäèêàòîðà èñïîëüçîâàí ñàëàòîâûé öâåò
#property indicator_color5  clrLime
//---- òîëùèíà ëèíèè èíäèêàòîðà 5 ðàâíà 4
#property indicator_width5  4
//---- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label5  "Up_Signal 2"
//+----------------------------------------------+
//|  Îïèñàíèå êëàññîâ óñðåäíåíèé                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//---- îáúÿâëåíèå ïåðåìåííûõ êëàññîâ CXMA èç ôàéëà SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//| Îáúÿâëåíèå ïåðå÷èñëåíèé                      |
//+----------------------------------------------+
enum MODE_PRICE //òèï êîíñòàíòû
  {
   OPEN = 0,     //ïî öåíàì îòêðûòèÿ
   LOW,          //ïî ìèíèìóìàì
   HIGH,         //ïî ìàêñèìóìàì
   CLOSE         //Ïî öåíàì çàêðûòèÿ
  };
//---
enum Applied_price_ //òèï êîíñòàíòû
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
//---
/*enum Smooth_Method - ïåðå÷èñëåíèå îáúÿâëåíî â ôàéëå SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+
input uint Up_period=3; // Ïåðèîä, èñïîëüçóåìûé äëÿ âû÷èñëåíèÿ íàèâûñøåãî çíà÷åíèÿ öåíû
input uint Dn_period=3; // Ïåðèîä, èñïîëüçóåììûé äëÿ âû÷èñëåíèÿ íàèíèçøåãî çíà÷åíèÿ öåíû
//---- 
input MODE_PRICE Up_mode=HIGH;  // Òàéìñåðèÿ äëÿ ïîèñêà ìàêñèìóìîâ 
input MODE_PRICE Dn_mode=LOW;   // Òàéìñåðèÿ äëÿ ïîèñêà ìèíèìóìîâ 
//---- 
input Smooth_Method XMA_Method=MODE_SMA; // Ìåòîä óñðåäíåíèÿ
input int XLength=8; // Ãëóáèíà ñãëàæèâàíèÿ                    
input int XPhase=15; // Ïàðàìåòð óñðåäíåíèÿ
                     // äëÿ JJMA èçìåíÿþùèéñÿ â ïðåäåëàõ -100 ... +100, âëèÿåò íà êà÷åñòâî ïåðåõîäíîãî ïðîöåññà
// äëÿ VIDIA ýòî ïåðèîä CMO, äëÿ AMA ýòî ïåðèîä ìåäëåííîé ñêîëüçÿùåé
//---- 
input double dK1=1.5;  // Êîýôôèöèåíò 1 äëÿ êâàäðàòè÷íîãî ôèëüòðà
input double dK2=2.5;  // Êîýôôèöèåíò 2 äëÿ êâàäðàòè÷íîãî ôèëüòðà
input uint std_period=9; // Ïåðèîä êâàäðàòè÷íîãî ôèëüòðà
input int Shift=0; // Ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ
input int PriceShift=0; // Ñäâèã èíäèêàòîðà ïî âåðòèêàëè â ïóíêòàõ
//+----------------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
//---- äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double ExtLineBuffer[],ColorExtLineBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];
//---- îáúÿâëåíèå ïåðåìåííîé çíà÷åíèÿ âåðòèêàëüíîãî ñäâèãà ñêîëüçÿùåé
double dPriceShift;
double dXMa[];
//---- îáúÿâëåíèå öåëûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int StartBars,StartBars1;
//+------------------------------------------------------------------+   
//| Ishimoku XMA indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   StartBars1=int(MathMax(Up_period,Dn_period));
   StartBars=StartBars1+GetStartBars(XMA_Method,XLength,XPhase)+int(std_period);
//---- ðàñïðåäåëåíèå ïàìÿòè ïîä ìàññèâû ïåðåìåííûõ  
   ArrayResize(dXMa,std_period);
//---- óñòàíîâêà àëåðòîâ íà íåäîïóñòèìûå çíà÷åíèÿ âíåøíèõ ïåðåìåííûõ
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
//---- èíèöèàëèçàöèÿ ñäâèãà ïî âåðòèêàëè
   dPriceShift=_Point*PriceShift;
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà ExtLineBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 2 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ExtLineBuffer,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(ColorExtLineBuffer,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà BearsBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(2,BearsBuffer1,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 2 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- âûáîð ñèìâîëà äëÿ îòðèñîâêè
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BearsBuffer1,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà BullsBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(3,BullsBuffer1,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 3 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- âûáîð ñèìâîëà äëÿ îòðèñîâêè
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BullsBuffer1,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà BearsBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(4,BearsBuffer2,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 2 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//---- âûáîð ñèìâîëà äëÿ îòðèñîâêè
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BearsBuffer2,true);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà BullsBuffer â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(5,BullsBuffer2,INDICATOR_DATA);
//---- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 3 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//---- âûáîð ñèìâîëà äëÿ îòðèñîâêè
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- çàïðåò íà îòðèñîâêó èíäèêàòîðîì ïóñòûõ çíà÷åíèé
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BullsBuffer2,true);
//---- èíèöèàëèçàöèè ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"Ishimoku XMA(",XLength,", ",XPhase,", ",Smooth,")");
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- çàâåðøåíèå èíèöèàëèçàöèè
  }
//+------------------------------------------------------------------+
//| Ïîèñê ìàêñèìóìîâ                                                 |
//+------------------------------------------------------------------+
int FindMaximum(const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                MODE_PRICE Mode,
                uint index,
                uint period)
  {
//----
   int max=0;
   int Mode_=int(Mode);
//---
   switch(Mode_)
     {
      case OPEN: max=ArrayMaximum(Open,index,period); break;
      case LOW: max=ArrayMaximum(Low,index,period); break;
      case HIGH: max=ArrayMaximum(High,index,period); break;
      case CLOSE: max=ArrayMaximum(Close,index,period); break;
     }
//----
   return(max);
  }
//+------------------------------------------------------------------+
//| Ïîèñê ìèíèìóìîâ                                                  |
//+------------------------------------------------------------------+
int FindMinimum(const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                MODE_PRICE Mode,
                uint index,
                uint period)
  {
//----
   int min=0;
   int Mode_=int(Mode);
//---
   switch(Mode_)
     {
      case OPEN: min=ArrayMinimum(Open,index,period); break;
      case LOW: min=ArrayMinimum(Low,index,period); break;
      case HIGH: min=ArrayMinimum(High,index,period); break;
      case CLOSE: min=ArrayMinimum(Close,index,period); break;
     }
//----
   return(min);
  }
//+------------------------------------------------------------------+ 
//| Ishimoku XMA iteration function                                  | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                const int prev_calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(rates_total<StartBars) return(0);
//---- îáúÿâëåíèå ïåðåìåííûõ ñ ïëàâàþùåé òî÷êîé  
   double ish_Up,ish_Dn,xma;
   double SMAdif,Sum,StDev,dstd,BEARS1,BULLS1,BEARS2,BULLS2,Filter1,Filter2;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ
   int limit,maxbar,clr;
//---
   maxbar=rates_total-1-StartBars1;
//---- ðàñ÷åò ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
      limit=maxbar; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
   else limit=rates_total-prev_calculated;  // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà òîëüêî íîâûõ áàðîâ
//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ish_Up=high[FindMaximum(open,high,low,close,Up_mode,bar,Up_period)];
      ish_Dn=low[FindMinimum(open,high,low,close,Dn_mode,bar,Dn_period)];
      ExtLineBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,(ish_Up+ish_Dn)/2,bar,true)+PriceShift;
     }
//---- ïåðåñ÷åò ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
      limit--;
//---- îñíîâíîé öèêë ðàñêðàñêè ñèãíàëüíîé ëèíèè
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=1;
      if(ExtLineBuffer[bar+1]<ExtLineBuffer[bar]) clr=2;
      if(ExtLineBuffer[bar+1]>ExtLineBuffer[bar]) clr=0;
      ColorExtLineBuffer[bar]=clr;
     }
//---- ïåðåñ÷åò ñòàðòîâîãî íîìåðà first äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0) // ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
      limit=rates_total-1-StartBars;
//---- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà ñòàíäàðòíûõ îòêëîíåíèé
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- çàãðóæàåì ïðèðàùåíèÿ èíäèêàòîðà â ìàññèâ äëÿ ïðîìåæóòî÷íûõ âû÷èñëåíèé
      for(int iii=0; iii<int(std_period); iii++) dXMa[iii]=ExtLineBuffer[bar+iii]-ExtLineBuffer[bar+iii+1];
      //---- íàõîäèì ïðîñòîå ñðåäíåå ïðèðàùåíèé èíäèêàòîðà
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dXMa[iii];
      SMAdif=Sum/std_period;
      //---- íàõîäèì ñóììó êâàäðàòîâ ðàçíîñòåé ïðèðàùåíèé è ñðåäíåãî
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dXMa[iii]-SMAdif,2);
      //---- îïðåäåëÿåì èòîãîâîå çíà÷åíèå ñðåäíåêâàäðàòè÷íîãî îòêëîíåíèÿ StDev îò ïðèðàùåíèÿ èíäèêàòîðà
      StDev=MathSqrt(Sum/std_period);
      //---- èíèöèàëèçàöèÿ ïåðåìåííûõ
      dstd=NormalizeDouble(dXMa[0],_Digits+2);
      Filter1=NormalizeDouble(dK1*StDev,_Digits+2);
      Filter2=NormalizeDouble(dK2*StDev,_Digits+2);
      BEARS1=EMPTY_VALUE;
      BULLS1=EMPTY_VALUE;
      BEARS2=EMPTY_VALUE;
      BULLS2=EMPTY_VALUE;
      xma=ExtLineBuffer[bar];
      //---- âû÷èñëåíèå èíäèêàòîðíûõ çíà÷åíèé
      if(dstd<-Filter1 && dstd>=-Filter2) BEARS1=xma; //åñòü íèñõîäÿùèé òðåíä
      if(dstd<-Filter2) BEARS2=xma; //åñòü íèñõîäÿùèé òðåíä
      if(dstd>+Filter1 && dstd<=+Filter2) BULLS1=xma; //åñòü âîñõîäÿùèé òðåíä
      if(dstd>+Filter2) BULLS2=xma; //åñòü âîñõîäÿùèé òðåíä
      //---- èíèöèàëèçàöèÿ ÿ÷ååê èíäèêàòîðíûõ áóôåðîâ ïîëó÷åííûìè çíà÷åíèÿìè 
      BullsBuffer1[bar]=BULLS1;
      BearsBuffer1[bar]=BEARS1;
      BullsBuffer2[bar]=BULLS2;
      BearsBuffer2[bar]=BEARS2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
