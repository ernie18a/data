//+------------------------------------------------------------------+
//|                                                  ms-candle-index |
//|                                       mosaic.system.fx@gmail.com |
//|                               https://www.mql5.com/ru/code/24222 |
//+------------------------------------------------------------------+
/*
Индикатор определяет индекс направления бара по ценам и ГЭПам/разрывам в них.
Является логическим продолжением индикатора ms-Candle https://www.mql5.com/ru/code/23561.

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
Смысл полей в ней понятен по комментариям. Расчет реализован в виде макросов.

В окне индикатора показывается информация о силе направлении баров - индексе направления.
Положительный показатель указывает на движение цены вверх, отрицательный - вниз. 
Показатель безразмерный, нормализованный относительно стат оценки максимального размера свечи. 
Включение дополнительной нормализации (параметр CI additional normalization = true) позволяет
привести значения индекса к интервалу -1..1. Чем больше индекс тем ярче выражено движение цены. 
Значения по модулю большие 1(0.6321 в режиме доп.нормализации) говорят о сильном импульсе в движении
цены. 

Визуально каждый бар описывается двумя состояниями столбца гистограммы:
1. По знаку индекса свечи - внешний цвет (красный/зеленый)
2. По относительному со значением на предыдущем баре изменению индекса без учета знака текущего 
бара (светло-зеленый/светло красный).

Так для свечи вверх (индекс в "+" зоне) столбец будет зелёным. Если при этом относительный 
индекс растет, то внутренний столбец будет раскрашен в светло-зеленый цвет, если падает - светло-красный.
Для свечи вниз принцип аналогичен. Если относительное изменение индекса равно 0, то внутренний столбец
не рисуется и цвет индекса становится полным - зеленый или красный.

Значение индекса свечи можно сгладить небольшим набором MA.
Автор использованной библиотеки - Nikolay Kositsin, оригинальная версия доступна по ссылке
https://www.mql5.com/ru/articles/180. Для использования в MQL4 в нее были внесены 2 изменения.
Измененную библиотеку SmoothAlgorithms45.mqh следует положить в папку Include терминала.
Работает в MT4 и в MT5.
Желтая линия - это МА от значения CI, синяя - MA от изменения CI (1 производной).

В чем отличие от индикатора ms-Candle? Какой в него заложен смысл?
В определённых ситуациях, в определенный момент ВАЖНО "увидеть" что направление движения уже
начало изменяться, но не только факт его смены. 

Для использования в MT5 смените расширение на mq5.

Изменения в версиях:

1.00 В алгоритм оценки направлений введена нормализация, расширена структура TCandleInfo.
1.01 Добавлен входной параметр для скрытия гистограммы
1.02 Дополнительная нормализация выполняется по квадрату коэффициентов направления, что позволяет 
     более плотно заполнять интервал -1..1 не теряя пропорции CI к стат оценке окна котировок.
     Добавлены уровни. Их оценку предлагаю обсудить.
1.03 Откорректировано описание. Изменены уровни, в каждом режиме (нормализация вкл/выкл) свои. 
     Логически соответствуют друг другу. Добавлена простая инфо панель.
*/

#property copyright "mosaic.system.fx@gmail.com"
#property link      "https://www.mql5.com/ru/code/24222"
#property version   "1.03"
#property description "Candle index"
#property description "https://www.mql5.com/ru/code/24222"
#property strict
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   7

//--- plot CI
#property indicator_label1  "cI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot dnDir
#property indicator_label2  "dn"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  6
//--- plot upDir
#property indicator_label3  "up"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  6
//--- plot dnDir may be
#property indicator_label4  "dnm"
#property indicator_type4   DRAW_HISTOGRAM
#property indicator_color4  clrCoral
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot upDir may be
#property indicator_label5  "upm"
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrYellowGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- plot MACI
#property indicator_label6  "MAcI"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrYellow
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2
//--- plot MA diff CI
#property indicator_label7  "MAdcI"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlue
#property indicator_style7  STYLE_SOLID
#property indicator_width7  2


#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT
//---
#include <SmoothAlgorithms45.mqh>

//---Input parameters
input bool inpAddExpNorm=true;             // --CI additional normalization
input Smooth_Method inpMAMethod=MODE_JJMA; // --MA Method
input int inpAvgPeriod=9;                  // MA Period
input int inpMAPhase=15;                   // MA Phase
input bool inpShowHistog=true;             // --Show histogramm?
input bool inpShowPanel=true;              // --Show info panel?

//--- indicator buffers
double         CIB[];
double         DNB[];
double         DNMB[];
double         UPB[];
double         UPMB[];
double         MACIB[];
double         MADCIB[];

//--- MA class
CXMA XMA,XMAD;

//---Koeff of "normal" candle
#define Candle_Normal_K 0.6
//---Size of the data window to calculate some statistics 
#define Window_Len 1440
const int Window_Len_1_3=Window_Len/3;
#define Rates_Total_Min 48 // Minimal count of rates to calc indicator
//---Levels const
#define levExpNr1 0.6321 // =1. without additional normalization
//---Graph object mask
string obj_mask;

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
TCandleInfo CI;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CIB);
   SetIndexBuffer(1,DNB);
   SetIndexBuffer(2,UPB);
   SetIndexBuffer(3,DNMB);
   SetIndexBuffer(4,UPMB);
   SetIndexBuffer(5,MACIB);
   SetIndexBuffer(6,MADCIB);

#ifdef __MQL5__
   if(inpShowHistog) {
     PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
     PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
     PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
     PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   } else {
     PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
     PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
     PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
     PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
   }
#else
   if(inpShowHistog) {
     SetIndexStyle(1,DRAW_HISTOGRAM);
     SetIndexStyle(2,DRAW_HISTOGRAM);
     SetIndexStyle(3,DRAW_HISTOGRAM);
     SetIndexStyle(4,DRAW_HISTOGRAM);
   } else {
     SetIndexStyle(1,DRAW_NONE);
     SetIndexStyle(2,DRAW_NONE);
     SetIndexStyle(3,DRAW_NONE);
     SetIndexStyle(4,DRAW_NONE);
   }
#endif    
 
   ArraySetAsSeries(CIB,true);
   ArraySetAsSeries(DNB,true);
   ArraySetAsSeries(DNMB,true);
   ArraySetAsSeries(UPB,true);
   ArraySetAsSeries(UPMB,true);
   ArraySetAsSeries(MACIB,true);
   ArraySetAsSeries(MADCIB,true);
   //---
   XMA.XMALengthCheck("inpAvgPeriod", inpAvgPeriod);
   XMA.XMAPhaseCheck("inpPhase", inpMAPhase, inpMAMethod);
   XMAD.XMALengthCheck("inpAvgPeriod", inpAvgPeriod);
   XMAD.XMAPhaseCheck("inpPhase", inpMAPhase, inpMAMethod);
   ZeroMemory(CS);
   ZeroMemory(CI);
   //---
   if(inpAddExpNorm) {
     const double Levels[]={-0.9270,-0.6321,-0.2212,-0.1358,0,0.1358,0.2212,0.6321,0.9270};
     SetIndicatorLevels(Levels);
   } else {
     const double Levels[]={-1.618,-1,-0.618,-0.5,-0.382,0,0.382,0.5,0.618,1,1.618};
     SetIndicatorLevels(Levels);
   }
   //---
   obj_mask=EnumToString(((ENUM_TIMEFRAMES)_Period));
   StringReplace(obj_mask,"PERIOD_","");
   obj_mask="CI_"+_Symbol+"_"+obj_mask;
//---
   return(INIT_SUCCEEDED);
}
//---
void OnDeinit(const int reason)
{
  ObjectsDeleteAll(0,obj_mask);
}
//---
void SetIndicatorLevels(const double &aLev[])
{
  int count_lev=ArraySize(aLev);
  if(count_lev<=0) return; // empty aLev
  IndicatorSetInteger(INDICATOR_LEVELS,count_lev);
  for(int i=0;i<count_lev;i++) {
    IndicatorSetDouble(INDICATOR_LEVELVALUE,i,aLev[i]);
  }
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

#define defCandleInfoNr(height_big,height_low, addnorm, info) \
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
  if(addnorm) { \
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
   static int end_corr_data_ma; // max shift on corrected calculated MA values in array MACIB,MADCIB

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
     end_corr_data_ma=end_corr_data-XMA.GetStartBars(inpMAMethod,inpAvgPeriod,inpMAPhase);
     to_calc=end_corr_data;
     defCalcStat(rates_total-Window_Len-1,CS);
     MACIB[to_calc+1]=CIB[to_calc+1]=0;
   } else {
     // next calc
     to_calc=rates_total-prev_calculated;
     // check for need calc stats
     if(defNeedRecalcStat(0,CS)) defCalcStat(0,CS);
   }
   //--- additional vars
   static int diff_pd;
   static double pcib;
   static datetime time_open=0;
   static bool IsNewBar=false;
   //--- check new bar
   IsNewBar=(time_open!=time[0]);
   if(IsNewBar) time_open=time[0];

//--- main cycle start
   pcib=(to_calc<end_corr_data)?CIB[to_calc+1]:0; // restore prev dir index
   for(int i=to_calc;i>=0 && !IsStopped();i--) {
     // clear buffers
     UPB[i]=UPMB[i]=DNB[i]=DNMB[i]=MACIB[i]=MADCIB[i]=EMPTY_VALUE;
     // calculate stats on full recalc and after 1/3 of the time since the last calculation
     if(prev_calculated==0 && defNeedRecalcStat(i,CS)) defCalcStat(i,CS);
     // Fill prices to struct CI
     defCandleFill(open,high,low,close,i, CI);
     // Calc candle info and normalized dir (index)
     defCandleInfoNr(CS.height_big,CS.height_low, inpAddExpNorm, CI);
     CIB[i]=CI.dir_index;
     // calc difference of curr and prev dir index
     diff_pd=MathDirDI(CI.dir_index-pcib,FLT_EPSILON);
     // fill it to chance buffers
     if(diff_pd>0) UPMB[i]=CI.dir_index;
     else if(diff_pd<0) DNMB[i]=CI.dir_index;
     // fill dir index to buffers
     if(CI.dir>0) UPB[i]=CI.dir_index;
     else if(CI.dir<0) DNB[i]=CI.dir_index;
     // calc MA on dir index
     MACIB[i]=XMA.XMASeries(end_corr_data,prev_calculated,rates_total,
                                    inpMAMethod,inpMAPhase,inpAvgPeriod,CI.dir_index,i,true);
     MADCIB[i]=XMAD.XMASeries(end_corr_data,prev_calculated,rates_total,
                                    inpMAMethod,inpMAPhase,inpAvgPeriod,CI.dir_index-pcib,i,true);
     // save prev dir index
     pcib=CI.dir_index;
   }
//--- main cycle end   
   //--- Log result on last calc statistic on New Bar
   if(prev_calculated==0 || (IsNewBar && time_open==CS.window_start)) {
     Print("Last Statistic calculated on ",CS.window_start, " with window len=",CS.window_len);
     Print("Candles Height's Low=",CS.height_low," Mid=",CS.height_mid," Big=",CS.height_big);
     Print("Candles Body's Low=",CS.body_low," Mid=",CS.body_mid," Big=",CS.body_big);
   }
   if(inpShowPanel) {
     // time of last tick
     static MqlTick tick;
     bool tick_last_good=SymbolInfoTick(_Symbol,tick) && tick.time>0;
     EasyPanel(CS,CI,IsNewBar,time_open,tick.time);
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|  Easy info panel                                                 |
//+------------------------------------------------------------------+
#define FontDefault "Tahoma"
string EasyPanel(const TCandlesStats &cs, const TCandleInfo &ci, const bool newbar=false, 
                 const datetime time0=0, const datetime time_last_tick=0)
{
  //---
  static bool IsCreated=false; // flag for creating panel
  const int p_x=137;
  const int p_y=2;
  const int p_w=133;
  const int p_h=113;
  static int p_w1=119;
  //---names for dynamic objects
  static string nm_panel="";
  static string nm_dhb="";
  static string nm_dhm="";
  static string nm_dhl="";
  static string nm_dbb="";
  static string nm_dbm="";
  static string nm_dbl="";
  static string nm_dhc="";
  static string nm_dbc="";
  static string nm_s4="";
  static string nm_s41="";
  static string nm_bar_tm="";
  //---
  static int h_prev=0,b_prev=0; // prev call heigth, body of candle
  static char dir_prev=0;       // dir on prev call
  //---
  const color cb1=clrLightGray;
  const color cb2=clrSnow;
  //---
  const color ct1=clrBlue;
  const color ct2=clrBrown;
  const color cs1=clrRed;
  const color cs2=clrGreen;
  const color cs3=clrMediumOrchid;
  //---
  ResetLastError();
  //---
  long chart_id=ChartID(); // Chart Id
  int win_id=ChartWindowFind(); // Win Id
  //---Some calc dynamic data for draw panel on current candle
  color ch=(ci.height<cs.height_mid)?cs3:(ci.height<cs.height_big)?cs2:cs1;
  color cb=(ci.body<cs.body_mid)?cs3:(ci.body<cs.body_big)?cs2:cs1;
  // Color on candle direction
  color cdir=(ci.dir>0)?indicator_color3:(ci.dir<0)?indicator_color2:cs3;
  int h=int(ci.height/_Point); // current heigth
  int b=int(ci.body/_Point); // current body of candle
  
  //---Draw panel
  if(IsCreated) {
    //---update panel
    if(newbar) {
      // Update stats data on each newbar
      ObjectSetString(chart_id,nm_dhb,OBJPROP_TEXT,string(int(cs.height_big/_Point)));
      ObjectSetString(chart_id,nm_dhm,OBJPROP_TEXT,string(int(cs.height_mid/_Point)));
      ObjectSetString(chart_id,nm_dhl,OBJPROP_TEXT,string(int(cs.height_low/_Point)));
      ObjectSetString(chart_id,nm_dbb,OBJPROP_TEXT,string(int(cs.body_big/_Point)));
      ObjectSetString(chart_id,nm_dbm,OBJPROP_TEXT,string(int(cs.body_mid/_Point)));
      ObjectSetString(chart_id,nm_dbl,OBJPROP_TEXT,string(int(cs.body_low/_Point)));
    }
    //---update data for curr bar
    if(h!=h_prev) {
      h_prev=h;
      ObjectSetString(chart_id,nm_dhc,OBJPROP_TEXT,string(h_prev)); 
      ObjectSetInteger(chart_id,nm_dhc,OBJPROP_COLOR,ch); 
    }
    if(b!=b_prev) {
      b_prev=b;
      ObjectSetString(chart_id,nm_dbc,OBJPROP_TEXT,string(b_prev)); 
      ObjectSetInteger(chart_id,nm_dbc,OBJPROP_COLOR,cb); 
    }
    if(dir_prev!=ci.dir) {
      dir_prev=ci.dir;
      ObjectSetInteger(chart_id,nm_s4,OBJPROP_COLOR,cdir); 
      ObjectSetInteger(chart_id,nm_s41,OBJPROP_COLOR,cdir); 
    }
    // time bar
    ObjectSetInteger(chart_id,nm_bar_tm,OBJPROP_BGCOLOR,cdir);
    char position_in_bar=(char)(100.*((time_last_tick-time0))/PeriodSeconds());  
    if(position_in_bar>=0) {
      ObjectSetInteger(chart_id,nm_bar_tm,OBJPROP_XSIZE,p_w1*position_in_bar/100);
    }
  } else {
    //---create panel
    nm_panel=obj_mask+"pi";
    RectLabelCreate(chart_id,nm_panel,win_id,
                  p_x,p_y,p_w,p_h,cb1,1,CORNER_RIGHT_UPPER);
    //---Title and string names, static objects
    LabelCreate(chart_id,nm_panel+"t_t0",win_id,
                  p_x-14,p_y+5,CORNER_RIGHT_UPPER,"Candles info, pips:",ct1,FontDefault,10);
    LabelCreate(chart_id,nm_panel+"t_t1",win_id,
                  p_x-40,p_y+20,CORNER_RIGHT_UPPER,"heigth's",ct2,FontDefault,8);
    LabelCreate(chart_id,nm_panel+"t_t2",win_id,
                  p_x-85,p_y+20,CORNER_RIGHT_UPPER,"body's",ct2,FontDefault,8);
                  
    LabelCreate(chart_id,nm_panel+"t_s1",win_id,
                  p_x-10,p_y+35,CORNER_RIGHT_UPPER,"Big",cs1);
    LabelCreate(chart_id,nm_panel+"t_s2",win_id,
                  p_x-10,p_y+50,CORNER_RIGHT_UPPER,"Mid",cs2);
    LabelCreate(chart_id,nm_panel+"t_s3",win_id,
                  p_x-10,p_y+65,CORNER_RIGHT_UPPER,"Low",cs3);
    
    //---Objects for update
    nm_bar_tm=nm_panel+"r_bt";
    nm_dhb=nm_panel+"t_dhb";
    nm_dhm=nm_panel+"t_dhm";
    nm_dhl=nm_panel+"t_dhl";
    nm_dbb=nm_panel+"t_dbb";
    nm_dbm=nm_panel+"t_dbm";
    nm_dbl=nm_panel+"t_dbl";
    nm_s4=nm_panel+"t_s4";
    nm_s41=nm_panel+"t_s41";
    //---heigth's
    LabelCreate(chart_id,nm_dhb,win_id,
                  p_x-40,p_y+35,CORNER_RIGHT_UPPER,string(int(cs.height_big/_Point)),cs1);
    LabelCreate(chart_id,nm_dhm,win_id,
                  p_x-40,p_y+50,CORNER_RIGHT_UPPER,string(int(cs.height_mid/_Point)),cs2);
    LabelCreate(chart_id,nm_dhl,win_id,
                  p_x-40,p_y+65,CORNER_RIGHT_UPPER,string(int(cs.height_low/_Point)),cs3);
    //---body's
    LabelCreate(chart_id,nm_dbb,win_id,
                  p_x-85,p_y+35,CORNER_RIGHT_UPPER,string(int(cs.body_big/_Point)),cs1);
    LabelCreate(chart_id,nm_dbm,win_id,
                  p_x-85,p_y+50,CORNER_RIGHT_UPPER,string(int(cs.body_mid/_Point)),cs2);
    LabelCreate(chart_id,nm_dbl,win_id,
                  p_x-85,p_y+65,CORNER_RIGHT_UPPER,string(int(cs.body_low/_Point)),cs3);
    //---Current bar info background
    RectLabelCreate(chart_id,nm_panel+"cb_r1",win_id,
                  p_x-5,p_y+82,p_w-10,25,cb2,1,CORNER_RIGHT_UPPER);
    //---Curr bar time 
    p_w1=p_w-14;
    RectLabelCreate(chart_id,nm_bar_tm,win_id,
                  p_x-7,p_y+82+20,p_w1,3,cdir,1,CORNER_RIGHT_UPPER);
                  
    LabelCreate(chart_id,nm_s4,win_id,
                  p_x-10,p_y+85,CORNER_RIGHT_UPPER,"CUR",cdir);
    LabelCreate(chart_id,nm_s41,win_id,
                  p_x-9,p_y+85,CORNER_RIGHT_UPPER,"CUR",cdir); // as bold
                             
    nm_dhc=nm_panel+"t_dhc";
    nm_dbc=nm_panel+"t_dbc";
    LabelCreate(chart_id,nm_dhc,win_id,
                  p_x-40,p_y+85,CORNER_RIGHT_UPPER,string(int(ci.height/_Point)),ch);
    LabelCreate(chart_id,nm_dbc,win_id,
                  p_x-85,p_y+85,CORNER_RIGHT_UPPER,string(int(ci.body/_Point)),cb);
    //---Ready
    IsCreated=true;
  }
  return(nm_panel);
}

//+------------------------------------------------------------------+ 
//| Создает текстовую метку                                          | 
//+------------------------------------------------------------------+ 
bool LabelCreate(
                 const long              chart_ID=0,               // ID графика
                 const string            name="label",             // имя метки 
                 const int               sub_window=0,             // номер подокна
                 const int               x=0,                      // координата по оси X 
                 const int               y=0,                      // координата по оси Y 
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                 const string            text="name",             // текст 
                 const color             clr=clrRed,               // цвет 
                 const string            font=FontDefault,         // шрифт 
                 const int               font_size=10,             // размер шрифта 
                 const double            angle=0.0,                // наклон текста 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // способ привязки 
                 const bool              back=false,               // на заднем плане 
                 const bool              selection=false,          // выделить для перемещений 
                 const bool              selectable=false,         // выделяемый для перемещений
                 const bool              hidden=true,              // скрыт в списке объектов 
                 const long              z_order=0)                // приоритет на нажатие мышью 
{ 
//--- сбросим значение ошибки 
  ResetLastError(); 
  //--- создадим текстовую метку 
  if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) {
    Print(__FUNCTION__,": text label not created! Err code= ",GetLastError()); 
    return(false); 
  }
  //--- установим координаты метки 
  ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
  ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
  //--- установим угол графика, относительно которого будут определяться координаты точки 
  ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
  //--- установим текст 
  ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
  //--- установим шрифт текста 
  ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
  //--- установим размер шрифта 
  ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
  //--- установим угол наклона текста 
  ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
  //--- установим способ привязки 
  ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
  //--- установим цвет 
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
  //--- отобразим на переднем (false) или заднем (true) плане 
  ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
  //--- включим (true) или отключим (false) режим перемещения метки мышью 
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selectable); 
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
  //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
  ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
  //--- установим приоритет на получение события нажатия мыши на графике 
  ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
  //--- успешное выполнение 
  return(true); 
} 

//+------------------------------------------------------------------+ 
//| Создает прямоугольную метку                                      | 
//+------------------------------------------------------------------+ 
bool RectLabelCreate(
                     const long             chart_ID=0,               // ID графика 
                     const string           name="rect",              // имя метки 
                     const int              sub_window=0,             // номер подокна 
                     const int              x=0,                      // координата по оси X 
                     const int              y=0,                      // координата по оси Y 
                     const int              width=50,                 // ширина 
                     const int              height=18,                // высота 
                     const color            back_clr=C'236,233,216',  // цвет фона 
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // тип границы 
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                     const color            clr=clrRed,               // цвет плоской границы (Flat) 
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // стиль плоской границы 
                     const int              line_width=1,             // толщина плоской границы 
                     const bool             back=false,               // на заднем плане 
                     const bool             selection=false,          // выделить для перемещений 
                     const bool             selectable=false,         // выделяемый для перемещений
                     const bool             hidden=true,              // скрыт в списке объектов 
                     const long             z_order=0)                // приоритет на нажатие мышью 
{ 
  //--- сбросим значение ошибки 
  ResetLastError(); 
  //--- создадим прямоугольную метку 
  if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0)) { 
    Print(__FUNCSIG__, ": Rect label not created! Err code=",GetLastError()); 
    return(false); 
  } 
  //--- установим координаты метки 
  ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
  ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
  //--- установим размеры метки 
  ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
  ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
  //--- установим цвет фона 
  ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
  //--- установим тип границы 
  ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border); 
  //--- установим угол графика, относительно которого будут определяться координаты точки 
  ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
  //--- установим цвет плоской рамки (в режиме Flat) 
  ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
  //--- установим стиль линии плоской рамки 
  ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
  //--- установим толщину плоской границы 
  ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width); 
  //--- отобразим на переднем (false) или заднем (true) плане 
  ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
  //--- включим (true) или отключим (false) режим перемещения метки мышью 
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selectable); 
  ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
  //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
  ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
  //--- установим приоритет на получение события нажатия мыши на графике 
  ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
  //--- успешное выполнение 
  return(true); 
} 
