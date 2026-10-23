//+------------------------------------------------------------------+
//|                           BarTimerCLineRoundedVerticalDn_HTF.mq5 |
//|                               Copyright © 2008, Art Royal s.r.o. |
//|                                           Author: Vasyl Gumenyak |  
//|                                           http://www.jiport.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2008, Art Royal s.r.o."
//---- ссылка на сайт автора
#property link      "http://www.jiport.com/"
//---- номер версии индикатора
#property version   "1.0"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- в индикаторе нет индикаторных буферов
#property indicator_buffers 0 
//---- в индикаторе нет графических построений
#property indicator_plots  0 
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0                                       // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание классов графических объектов       |
//+----------------------------------------------+ 
#include <CustomGUI\CustomGUI.mqh>
//+----------------------------------------------+
//---- объявление переменных класса CLineRoundedVerticalDn из файла CustomGUI.mqh
CLineRoundedVerticalDn BarTimer;
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string Ind_Sirname="BarTimerCLineRoundedVerticalDn_HTF_";  // Название для объектов индикатора
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;//Период графика
input int FontSize=20;        //размер шрифта
input color FontColor=clrBlack;    //цвет текста
input color UpScaleColor=clrLime;    //цвет шкалы для растущей свечи
input color DnScaleColor=clrMediumOrchid;    //цвет шкалы для падающей свечи
input int XDistance=80;// x расстояние от опорного левого верхнего угла
input int YDistance=150;// y расстояние от опорного левого верхнего угла
input int XSize=40;// ширина
input int YSize=200;// высота
input uchar Alpha=100;    //прозрачность индикатора
input color BgColor=clrLavender;    //цвет заднего фона
input color BorderColor=clrBlue;    //цвет рамки индикатора
input int Border=4;  //толщина рамки индикатора
input bool SoundSignal=true;// разрешение на подачу звукового сигнала при смене бара
input string Sound="Alert";  // название звукового файла для сигнала
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- размеры шкалы индикатора
   BarTimer.XSizeInd(XSize);
   BarTimer.YSizeInd(YSize);
//--- цвет шрифта численного значения
   BarTimer.ValueColor(FontColor);
//--- размер шрифта численного значения
   BarTimer.FontSize(FontSize);
//--- прозрачность
   BarTimer.Alpha(Alpha);
//--- толщина рамки
   BarTimer.Border(Border);
//--- цвет заднего фона
   BarTimer.BgColor(BgColor);
//--- цвет бордюра
   BarTimer.BorderColor(BorderColor);
//--- создание индикатора
   BarTimer.Create(Ind_Sirname,XDistance,YDistance);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   BarTimer.Delete();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- 
   int sec=0;
   double pc=0.0,iOpen[1],iClose[1];
   datetime iTime[1];
   static datetime iTime_prev=NULL;
//--- копируем вновь появившиеся данные в массивы
   if(CopyTime(Symbol(),TimeFrame,0,1,iTime)<=0) return(RESET);
   if(CopyOpen(Symbol(),TimeFrame,0,1,iOpen)<=0) return(RESET);
   if(CopyClose(Symbol(),TimeFrame,0,1,iClose)<=0) return(RESET);
   //--- 
   sec=int(TimeCurrent()-iTime[0]);// время в секундах от начала бара
   pc=100.0*sec/(PeriodSeconds(TimeFrame));// время от начала бара в процентах
   BarTimer.NewValue(pc,100,1);
   //--- подача звукового сигнала
   if(SoundSignal && iTime_prev && iTime[0]!=iTime_prev) PlaySound(Sound);   
   iTime_prev=iTime[0];
   //--- изменение окраски шкалы
   if(iOpen[0]-iClose[0]>0) BarTimer.ScaleColor(DnScaleColor);
   else BarTimer.ScaleColor(UpScaleColor);
   
 
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
