//+------------------------------------------------------------------+
//|                                                        ms-candle |
//|                                       mosaic.system.fx@gmail.com |
//|                               https://www.mql5.com/ru/code/23561 |
//+------------------------------------------------------------------+
/*
Индикатор определяет направление бара, опираясь не только на цены Open/Close. 
Также определяются гэпы и разрывы в котировках.

Сравнение цен Open и Close очень часто не дает правильной оценки направления свечи. 
На них можно опираться, если тело свечи больше 2/3 её размера, в других случаях нужен 
иной подход в оценке. В индикаторе реализован эмпирический авторский подход к этой задаче.

В процессе расчета индикатора выполняется оценка некоторых статистических характеристик 
ряда котировок. Их результаты описаны структурой TCandlesStats. Вычисляются граничные 
размеры минимальной и максимальной свечи, а также ориентировочный размер "средней" или 
"нормальной" свечи. Оценка проводится как по высоте свечи, так и по высоте её тела.
Результаты расчета выводятся в лог терминала. Расчет выполняется на фиксированном размере 
окна данных и повторяется при  прохождении не менее 1/3 от его размера.
Это обеспечивает актуальность результатов на момент расчета.

Оценка разрыва в котировках (большой гэп) использует размер максимальной свечи из статистической оценки. 
Более верным было бы использовать канал девиации цены, и выход цены Open за его пределы.
Однако корректное определение этого канала значительно более сложная задача.

При расчете индикатора для каждого бара рассчитывается структура TCandleInfo. 
Смысл полей в ней понятен по комментариям. Расчет реализован в виде макроса. 

На чарте показывается информация о направлении баров и гэпах в котировках.

Отображение направления можно отключить. 
Можно включить отображение только скорректированного направления свечей.
Гэпы можно фильтровать по их размеру. Разрывы в котировках показываются всегда. 

Значок по значению Low - свеча вниз (красный), по Hi - вверх (желтый).  
Двойная стрелка - гэп. Ножницы - разрыв в котировках (большой гэп). 
Расположение значков гэпа - финальное (по моменту времени) направление движения цены на нем.

Изменения в версиях:

1.01 поправлен алгоритм оценки направлений, изменена структура TCandleInfo.
1.02 поправлено отображение направления свечей на 0 баре.
1.03 поправлена функция GetSomeStats для корректного расчета на любом баре shift
1.04 добавлена принудительная очистка ВСЕХ буферов рисования. В MT5 информация о гэпах рисовалась на каждом баре)))
1.05 добавлена возможность показывать гэпы размером рассчитанным автоматически
1.06 В алгоритм оценки направлений введена нормализация по размеру макс свечи, расширена структура TCandleInfo. 
     (Алгоритм приведен в соответствие с тем, что используется в индикаторе ms-Candle-Index).
     Оценка стат характеристик выполняется для всей истории при прохождении не менее 1/3 от размера
     окна данных, что позволяет получить актуальные результаты на глубокой истории. 
1.07 Откорректировано описание. Мелкие правки.
*/

#property copyright "mosaic.system.fx@gmail.com"
#property link      "https://www.mql5.com/ru/code/23561"
#property version   "1.07"
#property description "Candle info: direction, gap, ..."
#property description "https://www.mql5.com/ru/code/23561"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//--- plot upB
#property indicator_label1  "upB"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot dnB
#property indicator_label2  "dnB"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot gapB
#property indicator_label3  "gapB"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot gapBig
#property indicator_label4  "gapBig"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

input bool inpAutoMinGapToShow = false;//-- Auto calc min Gap size to show
input int  inpGapSizeToShow = 5;       // Show Gap greater that, in pips
input bool inpShowCandleDir = true;    //-- Show candle direction
input bool inpShowCorrectedDir = true; //-- Show only corrected candle direction
input bool inpShowZeroDir = false;     //-- Show only Zero direction candle

const bool inpAddExpNorm=false;        //-- CI additional normalization

//--- indicator buffers
double         upBBuffer[];
double         dnBBuffer[];
double         gapBuffer[];
double         gapBigBuffer[];

double gap_min_to_show;

//--- Arrow codes
#define arrDef 119
#define arrGap 244
#define arrGapBig 34
//---Koeff of "normal" candle
#define Candle_Normal_K 0.6
//---Size of the data window to calculate some statistics 
#define Window_Len 1440
const int Window_Len_1_3=Window_Len/3;
#define Rates_Total_Min 48 // Minimal count of rates to calc indeicator

//+------------------------------------------------------------------+
//| Calculate some statistics of candles                             |
//+------------------------------------------------------------------+
struct TCandlesStats {
  int       window_len; // calculated on window len
  datetime  window_start; // time of start window
  double    height_low; // size of small candle
  double    height_mid; // size of middle ("normal")candle
  double    height_big; // size of big candle
  double    body_low;   // size of small body candle
  double    body_mid;   // size of middle body candle
  double    body_big;   // size of big body candle
};
TCandlesStats CS;

struct TCandleInfo {
  char      dir;        // candle up>0 or dn<0. Maybe 0!
  double    dir_index;  // direction index
  bool      zero;       // Candle has zero size Hi=Lo 
  bool      normal;     // "normal" candle, body size > 0.6 body heigth
  char      body_dir;   // body dir: 1 - up, -1 - down, 0 - body zero
  double    body;       // body size
  double    height;     // size of candle

  double    shadow_up;  // up shadow of candle
  double    shadow_dn;  // dn shadow of candle
  
  double    k_up,k_dn;  // koeff of up/dn direction of candle
  double    k_body_h;   // koeff of body size to heigth of candle
  double    k_shadow_h; // koeff of both shadow to heigth of candle
  
  char      gap_dir;    // gap direction: 1 - up, -1 - down, 0 - gap zero
  char      gap_move;   // price direction after gap: 1 - up, -1 - down
  bool      gap_big;    // gap is big
  double    gap_size;   // gap size
  
  double    op,hi,lo,cl,cl1; // prices, cl1 - prev close
};
TCandleInfo ci;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,upBBuffer);
   SetIndexBuffer(1,dnBBuffer);
   SetIndexBuffer(2,gapBuffer);
   SetIndexBuffer(3,gapBigBuffer);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
#ifdef __MQL5__
   PlotIndexSetInteger(0,PLOT_ARROW,arrDef);
   PlotIndexSetInteger(1,PLOT_ARROW,arrDef);
   PlotIndexSetInteger(2,PLOT_ARROW,arrGap);
   PlotIndexSetInteger(3,PLOT_ARROW,arrGapBig);
   if(inpShowCandleDir) {
     PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_ARROW);
     PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_ARROW);
   } else {
     PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
     PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
   }
#else
   SetIndexArrow(0, arrDef);
   SetIndexArrow(1, arrDef);
   SetIndexArrow(2, arrGap);
   SetIndexArrow(3, arrGapBig);
   if(inpShowCandleDir) {
     SetIndexStyle(0,DRAW_ARROW);
     SetIndexStyle(1,DRAW_ARROW);
   } else {
     SetIndexStyle(0,DRAW_NONE);
     SetIndexStyle(1,DRAW_NONE);
   }
#endif    
   ArraySetAsSeries(upBBuffer,true);
   ArraySetAsSeries(dnBBuffer,true);
   ArraySetAsSeries(gapBuffer,true);
   ArraySetAsSeries(gapBigBuffer,true);
   //
   if(!inpAutoMinGapToShow) gap_min_to_show=_Point*inpGapSizeToShow;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Macro for calc direction -1,0,1                                  |
//+------------------------------------------------------------------+
#define MathDirDI(v,delta) (((v)>=delta)?1:(((v)<=-delta)?-1:0))

//+------------------------------------------------------------------+
//| Macro for calc Candle info                                       |
//+------------------------------------------------------------------+
#define defCandleFill(open,high,low,close,i, info) \
{ \
  ZeroMemory(info); \
  info.op=open[i]; \
  info.hi=high[i]; \
  info.lo=low[i]; \
  info.cl=close[i]; \
  info.cl1=close[i+1]; \
}

#define defCandleInfoNr(height_big,height_low, info) \
{ \
  info.body=info.cl-info.op; \
  info.body_dir=MathDirDI(info.body,FLT_EPSILON); \
  info.body=info.body*info.body_dir; \
  \
  info.height=info.hi-info.lo; \
  info.zero=(info.height<=FLT_EPSILON); \
  info.normal=false; \
  \
  info.gap_size=info.op-info.cl1; \
  info.gap_dir=info.gap_move=MathDirDI(info.gap_size,FLT_EPSILON); \
  info.gap_size=info.gap_size*info.gap_dir; \
  \
  info.gap_big=info.gap_size>height_big; \
  \
  info.k_up=info.k_dn=0.; \
  if(info.gap_dir!=0) { \
    if(info.cl<info.cl1 && info.gap_dir>0) info.gap_move=-1; \
    else if(info.cl>info.cl1 && info.gap_dir<0) info.gap_move=1; \
    if(!info.gap_big) { \
      \ // If the gap is small, remember it for further calculation of the direction
      info.k_up=(info.gap_dir>0)?info.gap_size:0.; \
      info.k_dn=(info.gap_dir<0)?info.gap_size:0.; \
    } \
  } \
  \
  if(info.zero) { \
    info.k_body_h=info.k_shadow_h=info.shadow_up=info.shadow_dn=0; \
  } else { \
    info.k_body_h=info.body/info.height; \
    info.k_shadow_h=1.-info.k_body_h; \
    info.normal=(info.k_body_h>=Candle_Normal_K) && (info.height>height_low); \
    if(info.body_dir>0) { \
      \ // Candle dir up
      info.shadow_up=info.hi-info.cl; \
      info.shadow_dn=info.op-info.lo; \
      info.k_up=(info.k_up+info.shadow_dn+info.body)/height_big; \
      info.k_dn=(info.k_dn+info.shadow_up)/height_big; \ 
    } else if(info.body_dir<0) { \
      \ // Candle dir down
      info.shadow_up=info.hi-info.op; \
      info.shadow_dn=info.cl-info.lo; \
      info.k_up=(info.k_up+info.shadow_dn)/height_big; \ 
      info.k_dn=(info.k_dn+info.shadow_up+info.body)/height_big; \
    } else { \
      \ // Candle body zero
      info.shadow_up=info.hi-info.cl; \
      info.shadow_dn=info.op-info.lo; \
      info.k_up=(info.k_up+info.shadow_dn)/height_big; \
      info.k_dn=(info.k_dn+info.shadow_up)/height_big; \
    } \
  } \
  if(inpAddExpNorm) { \
    info.k_up=1.-MathExp(-(info.k_up*info.k_up)); \
    info.k_dn=1.-MathExp(-(info.k_dn*info.k_dn)); \
  } \
  info.dir_index=info.k_up-info.k_dn; \
  info.dir=MathDirDI(info.dir_index,FLT_EPSILON); \
  if(info.dir==0) { \
    info.dir=info.body_dir; \
    info.dir_index=info.dir*((info.dir>0)?info.k_up:(info.dir<0)?info.k_dn:0); \
  } \
  if(info.dir==0) { \
    info.dir=info.gap_dir; \
    info.dir_index=info.dir*((info.dir>0)?info.k_up:(info.dir<0)?info.k_dn:0); \
  } \
}

//+------------------------------------------------------------------+
//|  Macro for calc Percentil on sorted array                        |
//+------------------------------------------------------------------+
static double _percPos_; // temp var
#define MathPercentil(arr,period,perc) \
(\
  ((period<2 || perc<=0.))\
    ?\
    (arr[0])\
    :\
    (\
      (perc>=1.0)\
      ?\
      (arr[period-1])\
      :\
      (\
        arr[(int)(_percPos_=(perc*(period-1)))]*(1.-(_percPos_-int(_percPos_)))\
        +arr[(int)(_percPos_)+1]*(_percPos_-int(_percPos_))\
      )\
    )\
)

bool GetSomeStats( 
               int shift,
               int window_len,
               const datetime &time[],
               const double &open[],
               const double &high[],
               const double &low[],
               const double &close[],
               const long &tick_volume[],
               const long &volume[],
               const int &spread[],
               
               TCandlesStats &cs
               )
{
   //---input data arrays must be set flag "series" to true
   static double dACH[],dACB[]; // only 1 mem alloc for arrays
   static int window_len_max;
   if(shift<0) shift=0;
   window_len_max=ArraySize(close);
   //---shift is right border of Arr, calc left_border on window_len input
   if(shift+window_len>window_len_max) window_len=window_len_max-shift;
   ZeroMemory(cs);   // cs=0
   if(window_len<Rates_Total_Min) return(false);
   //---start calc
   cs.window_start=time[shift];
   //---Memory alloc to arrays
   if(ArrayResize(dACH,window_len,window_len)!=window_len) return(false);
   if(ArrayResize(dACB,window_len,window_len)!=window_len) return(false);
   //---fill arrays
   cs.window_len=window_len;
   for(int j=cs.window_len-1,i=shift+cs.window_len-1;i>=shift;i--,j--) {
     dACH[j]=high[i]-low[i];
     dACB[j]=MathAbs(open[i]-close[i]);
   }
   ArraySort(dACH);
   ArraySort(dACB);
   // body
   cs.body_low=NormalizeDouble(MathPercentil(dACB,cs.window_len,0.1),_Digits);
   window_len=(int)_percPos_; // use window_len to calc index of median value beetwen low and big
   cs.body_big=NormalizeDouble(MathPercentil(dACB,cs.window_len,0.9),_Digits);
   window_len+=int((_percPos_-window_len)*Candle_Normal_K); 
   cs.body_mid=NormalizeDouble(dACB[window_len],_Digits);
   // height
   cs.height_low=NormalizeDouble(MathPercentil(dACH,cs.window_len,0.1),_Digits);
   window_len=(int)_percPos_; // use window_len to calc index of median value beetwen low and big
   cs.height_big=NormalizeDouble(MathPercentil(dACH,cs.window_len,0.9),_Digits);
   window_len+=int((_percPos_-window_len)*Candle_Normal_K);
   cs.height_mid=NormalizeDouble(dACH[window_len],_Digits);
   return(true);
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
   if(rates_total<Rates_Total_Min) {
     Print("Not enough rates for calc.");
     return(0);
   }
//--- start calculation
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   //---
   static int to_calc; // shift start to calc
   static int end_corr_data; // max shift on corrected calculated values of CI in array CIB
   //--- Macros for compact code calc
   #define defNeedRecalcStat(shift,cs) (((time[shift]-cs.window_start)/PeriodSeconds())>Window_Len_1_3)
   #define defCSfromCeiling(cs) { \
     double fake_delta_price=NormalizeDouble(2.*_Point*MathPow(MathLog(PeriodSeconds(_Period)/10.),2.),_Digits); \
     cs.height_big=fake_delta_price*8; cs.height_mid=fake_delta_price*5; cs.height_low=fake_delta_price; \
     }
   #define defCalcStat(shift,cs) if(!GetSomeStats(shift,Window_Len,time,open,high,low,close,tick_volume,volume,spread, cs)) defCSfromCeiling(CS);
  
   //--- set start pos for calc
   if(prev_calculated==0) {
     // full recalc
     end_corr_data=rates_total-2;
     to_calc=end_corr_data;
     defCalcStat(rates_total-Window_Len-1,CS);
     if(inpAutoMinGapToShow) gap_min_to_show=CS.height_low;
   } else {
     // next calc
     to_calc=rates_total-prev_calculated;
     // check for need calc stats
     if(defNeedRecalcStat(0,CS)) {
       defCalcStat(0,CS);
       if(inpAutoMinGapToShow) gap_min_to_show=CS.height_low;
     }
   }
   //--- additional vars
   static datetime time_open=0;
   static bool IsNewBar=false;
   //--- check new bar
   IsNewBar=(time_open!=time[0]);
   if(IsNewBar) time_open=time[0];

//--- main cycle start
   for(int i=to_calc;i>=0 && !IsStopped();i--) {
     // clear buffers
     dnBBuffer[i]=upBBuffer[i]=gapBuffer[i]=gapBigBuffer[i]=EMPTY_VALUE; // clear buffers
     // calculate stats on full recalc and after 1/3 of the time since the last calculation
     if(prev_calculated==0 && defNeedRecalcStat(i,CS)) {
       defCalcStat(i,CS);
       if(inpAutoMinGapToShow) gap_min_to_show=CS.height_low;
     }
     // Fill prices to struct ci
     defCandleFill(open,high,low,close,i, ci);
     // Calc candle info and normalized dir (index)
     defCandleInfoNr(CS.height_big,CS.height_low, ci);
     // fill buffers
     if((inpShowCorrectedDir && ci.dir!=ci.body_dir) // show only corrected dir
         || 
        !inpShowCorrectedDir                         // show all
         || 
        (inpShowZeroDir && ci.dir==0)                // show only zero dir
       ) {
        if(!inpShowZeroDir && ci.dir>0)       upBBuffer[i]=ci.hi;
        else if(!inpShowZeroDir && ci.dir<0)  dnBBuffer[i]=ci.lo;
        else if(ci.dir==0) {
          upBBuffer[i]=ci.hi;
          dnBBuffer[i]=ci.lo;
        }
     }
     if(ci.gap_dir!=0 && ci.gap_size>gap_min_to_show) {
       if(ci.gap_move>0) {
         gapBuffer[i]=ci.hi+CS.height_low;
         if(ci.gap_big) gapBigBuffer[i]=gapBuffer[i]+CS.height_low;
       } else {
         gapBuffer[i]=ci.lo-CS.height_low;
         if(ci.gap_big) gapBigBuffer[i]=gapBuffer[i]-CS.height_low;
       }
     }
   }
//--- main cycle end   
   //--- Log result on last calc statistic on New Bar
   if(prev_calculated==0 || (IsNewBar && time_open==CS.window_start)) {
     Print("Last Statistic calculated on ",CS.window_start, " with window len=",CS.window_len);
     Print("Candles Height's Low=",CS.height_low," Mid=",CS.height_mid," Big=",CS.height_big);
     Print("Candles Body's Low=",CS.body_low," Mid=",CS.body_mid," Big=",CS.body_big);
     Print("Show gaps greater that=",gap_min_to_show);
   }   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
