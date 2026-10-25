//Version  January 7, 2007 Final
//+------------------------------------------------------------------+
//|                                                   T3Series().mqh |
//|                                T3 code: Copyright © 1998, Tilson |
//|             MQL4T3Series: Copyright © 2006,     Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
  /*

  +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS <<< Функция T3Series() >>> SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

  +-----------------------------------------+ <<< Назначение >>> +----------------------------------------------------+

  Функция  T3Series()  предназначена  для использования алгоритма Тильсона при написании любых индикаторов теханализа и
  экспертов,  для замены расчёта классического усреднения на этот алгоритм. Файл следует положить в папку (директорию):
  MetaTrader\experts\include\  Следует  учесть,  что  если  nT3_bar  больше,  чем  nT3_MaxBar-3*nT3_Period,  то функция
  T3Series()  возвращает значение равное нулю! на этом баре! И, следовательно, такое значение не может присутствовать в
  знаменателе  какой-либо  дроби  в  расчёте  индикатора!  Эта  версия функции T3Series() поддерживает экспертов при её
  использовании   в  пользовательских  индикаторах,  к  которым  обращается  эксперт.  Эта  версия  функции  T3Series()
  поддерживает экспертов при её использовании в коде индикатора, который полностью помещён в код эксперта с сохранением
  всех  операторов  цикла!  При написании индикаторов и экспертов с использованием функции T3Series(), не рекомендуется
  переменным  давать  имена начинающиеся с nT3_... или dT3_... Функция T3Series() может быть использована во внутреннем
  коде  других  пользовательских  функций,  но  при  этом  следует  учитывать  тот факт, что в каждом обращении к такой
  пользовательской функции у каждого обращения к T3Series() должен быть свой уникальный номер (nT3_number). 

  +-------------------------------------+ <<< Входные параметры >>> +-------------------------------------------------+

  nT3_number    - порядковый номер обращения к функции T3Series(). (0, 1, 2, 3 и т.д....)
  nT3_din       - параметр,  позволяющий изменять параметры  nT3_Period на каждом баре. 0 - запрет изменения параметров, 
                  любое другое значение - разрешение.
  nT3_MaxBar    - Максимальное  значение, которое  может принимать  номер  рассчитываемого  бара(nT3_bar). Обычно равно 
                  Bars-1-period;  Где "period" -  это  количество  баров,  на  которых  исходная величина dT3_series не 
                  рассчитывается; 
  nT3_limit     - Количество  ещё  не  подсчитанных баров плюс один или  номер последнего  непосчитанного бара,  Обычно 
                  равно Bars-IndicatorCounted()-1;  
  nT3_Curvature - параметр изменяющийся в пределах 0 ... +100, влияет на качество переходного процесса; 
  nT3_Period    - глубина сглаживания
  dT3_series    - Входной  параметр, по которому производится расчёт функции T3Series();
  nT3_bar       - номер рассчитываемого  бара, параметр должен  изменяться оператором цикла от максимального значения к
                  нулевому.   Причём его максимальное значение всегда должно равняться значению параметра nT3_limit!!!

  +------------------------------------+ <<< Выходные параметры >>> +-------------------------------------------------+

  T3Series()    - значение функции T3.  При значениях  nT3_bar больше чем  nT3_MaxBar-nT3_Length  функция  T3MASeries() 
                  всегда возвращает ноль!!!
  nT3_reset     - параметр, возвращающий  по  ссылке  значение,  отличенное  от 0,  если  произошла  ошибка  в  расчёте 
                  функции, 0,  если  расчёт  прошёл  нормально.    Этот параметр  может  быть  только переменной, но не 
                  значением!!!

  +-----------------------------------+ <<< Инициализация функции >>> +-----------------------------------------------+

  Перед  обращениями  к функции T3Series(), когда количество уже подсчитанных баров равно 0, (а ещё лучше это сделать в
  блоке  инициализации  пользовательского  индикатора  или  эксперта),  следует  ввести  и  инициализировать внутренние
  переменные   функции,   для   этого   необходимо  обратиться  к  функции  T3Series()  через  вспомогательную  функцию
  T3SeriesResize()   со   следующими   параметрами:   T3SeriesResize(MaxT3_number+1);   необходимо   сделать   параметр
  nT3_number(MaxT3_number)  равным  количеству  обращений  к  функции  T3Series(),  то  есть  на  единицу  больше,  чем
  максимальный nT3_number. 

  +--------------------------------------+ <<< Индикация ошибок >>> +-------------------------------------------------+
  
  При отладке индикаторов и экспертов их коды могут содержать ошибки, для выяснения причин которых следует смотреть лог
  файл.  Все  ошибки  функция  T3Series()  пишет в лог файл в папке \MetaTrader\EXPERTS\LOGS\. Если, перед обращением к
  функции  T3Series()  в  коде,  который предшествовал функции, возникла MQL4 ошибка, то функция запишет в лог файл код
  ошибки  и  содержание ошибки. Если при выполнении функции T3Series() в алгоритме T3Series() произошла MQL4 ошибка, то
  функция  также запишет в лог файл код ошибки и содержание ошибки. При неправильном задании номера обращения к функции
  T3Series()  nT3_number или неверном определении размера буферных переменных nJT3Resize_Size в лог файл будет записаны
  сообщения  о  неверном  определении этих параметров. Также в лог файл пишется информация при неправильном определении
  параметра  nT3_limit. Если при выполнении функции инициализации init() произошёл сбой при изменении размеров буферных
  переменных  функции  T3Series(),  то  функция  T3SeriesResize()  запишет  в лог файл информацию о неудачном изменении
  размеров  буферных  переменных.  Если  при  обращении к функции T3Series() через внешний оператор цикла была нарушена
  правильная  последовательность  изменения  параметра  nT3_bar, то в лог файл будет записана и эта информация. Следует
  учесть,  что  некоторые  ошибки  программного кода будут порождать дальнейшие ошибки в его исполнении и поэтому, если
  функция  T3Series() пишет в лог файл сразу несколько ошибок, то устранять их следует в порядке времени возникновения.
  В  правильно  написанном  индикаторе  функция  T3Series() может делать записи в лог файл только при нарушениях работы
  операционной системы. Исключение составляет запись изменения размеров буферных переменных при перезагрузке индикатора
  или эксперта, которая происходит при каждом вызове функции init(). 
  
  +---------------------------------+ <<< Пример обращения к функции >>> +--------------------------------------------+


//----+ определение функций T3Series()
#include <T3Series.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- определение стиля исполнения графика
SetIndexStyle (0,DRAW_LINE); 
//---- 1 индикаторный буфер использован для счёта (без этого пересчёта функция T3Series() свой расчёт производить не будет!!!)
SetIndexBuffer(0,Ind_Buffer);
//----+ Изменение размеров буферных переменных функции T3Series, nT3_number=1(Одно обращение к функции T3Series)
if(T3SeriesResize(1)==0)return(-1);
return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator function                                        |
//+------------------------------------------------------------------+
int start()
{
//----+ Введение целых переменных и получение уже подсчитанных баров
int reset,bar,MaxBar,limit,counted_bars=IndicatorCounted(); 
//---- проверка на возможные ошибки
if (counted_bars<0)return(-1);
//---- последний подсчитанный бар должен быть пересчитан
if (counted_bars>0) counted_bars--;
//---- определение номера самого старого бара, начиная с которого будет произедён пересчёт новых баров
int limit=Bars-counted_bars-1;
MaxBar=Bars-1;
//----+ 
for(bar=limit;bar>=0;bar--)
 (
  double Series=Close[bar];
  //----+ Обращение к функции T3Series()за номером 0 для расчёта буфера Ind_Buffer[], 
  //параметры nT3_Curvature и nT3_Length не меняются на каждом баре (nT3_din=0)
  double Resalt=T3Series(0,0,MaxBar,limit,Curvature,Length,Series,bar,reset);
  if (reset!=0)return(-1);
  Ind_Buffer[bar]=Resalt;
 }
return(0);
}
//----+ 
  */
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++ <<< T3Series()>>> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++|
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

//----++ <<< Введение и инициализация переменных >>> +SSSSSSSSSSSSSSSSSSSSSSSSSS+
double dT3_e1[1],dT3_e2[1],dT3_e3[1],dT3_e4[1],dT3_e5[1],dT3_e6[1];
double dT3_E1[1],dT3_E2[1],dT3_E3[1],dT3_E4[1],dT3_E5[1],dT3_E6[1];
double dT3_c1[1],dT3_c2[1],dT3_c3[1],dT3_c4[1],dT3_w1[1],dT3_w2[1];
double dT3_n[1],dT3_b2[1],dT3_b3[1],dT3_T3;
int    nT3_Error,nT3_num,nT3_size,nT3_Resize;
datetime nT3_TIME[1],nT3_Tnew,nT3_Old;
//----++ <<< Объявление функции T3Series() >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
double T3Series
 (
  int nT3_number,    int nT3_din,     int    nT3_MaxBar,      int nT3_limit,
  int nT3_Curvature, int nT3_Period,  double dT3_series,       int nT3_bar,    int& nT3_reset
 )
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
{
nT3_num=nT3_number;

nT3_reset=1;
//=====+ <<< Проверки на ошибки >>> ==============================================================================+
if (nT3_bar==nT3_limit)
 {
  //----++ проверка на инициализацию функции T3Series()
  if(nT3_Resize<1)
   {
    Print("T3Series number ="+(string)nT3_num+
         ". Не было сделано изменение размеров буферных переменных функцией T3SeriesResize()");
    if(nT3_Resize==0)
       Print("T3Series number ="+(string)nT3_num+
                ". Следует дописать обращение к функции T3SeriesResize() в блок инициализации");
         
    return(0.0);
   }
  //----++ проверка на ошибку в исполнении программного кода, предшествовавшего функции T3Series()
  nT3_Error=GetLastError();
  if(nT3_Error>4000)
    {
      Print("T3Series number ="+(string)nT3_num+
            ". В коде, предшествующем обращению к функции T3Series() number = "
                                                                 +(string)nT3_num+" ошибка!!!");
      Print("T3Series() number ="+(string)nT3_num+ ". ",T3_ErrDescr(nT3_Error));  
    }

  //----++ проверка на ошибку в задании переменных nT3_number и nT3Resize_Size
  nT3_size=ArraySize(dT3_e1);
  if (nT3_size< nT3_num) 
   {
    Print("T3Series number ="+(string)nT3_num+
              ". Ошибка!!! Неправильно задано значение переменной nT3_number="
                                                        +(string)nT3_num+" функции T3Series()");
    Print("T3Series number ="+(string)nT3_num+
            ". Или неправильно задано значение  переменной nT3Resize_Size="
                                                 +(string)nT3_size+" функции T3SeriesResize()");
    return(0.0);
   }
 }
//----++ +--------------------------------------------------------------------------------------------------------+

if (nT3_bar>nT3_MaxBar){nT3_reset=0;return(0.0);}
if((nT3_bar==nT3_MaxBar)||(nT3_din!=0))
  {
   //----++ <<< Расчёт коэффициентов  >>> +SSSSSSSSSSSSSSSSSSSSSSSSSS+
   double dT3_b=nT3_Curvature/100.0;
   dT3_b2[nT3_num]=dT3_b*dT3_b;
   dT3_b3[nT3_num]=dT3_b2[nT3_num]*dT3_b;
   dT3_c1[nT3_num]=-dT3_b3[nT3_num];
   dT3_c2[nT3_num]=(3*(dT3_b2[nT3_num]+dT3_b3[nT3_num]));
   dT3_c3[nT3_num]=-3*(2*dT3_b2[nT3_num]+dT3_b+dT3_b3[nT3_num]);
   dT3_c4[nT3_num]=(1+3*dT3_b+dT3_b3[nT3_num]+3*dT3_b2[nT3_num]);
   if (nT3_Period<1) nT3_Period=1;
   dT3_n [nT3_num] = 1 + 0.5*(nT3_Period-1);
   dT3_w1[nT3_num] = 2 / (dT3_n[nT3_num] + 1);
   dT3_w2[nT3_num] = 1 - dT3_w1[nT3_num];
   //----++SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
  }
if (nT3_Period<1)nT3_Period=1;

//----++ проверка на ошибку в последовательности изменения переменной nT3_bar
if((nT3_limit>=nT3_MaxBar)&&(nT3_bar==0)&&(nT3_din==0))
      if((nT3_MaxBar>nT3_Period*3)&&(nT3_TIME[nT3_num]==0))
                        Print("T3Series number ="+(string)nT3_num+
                        ". Ошибка!!! Нарушена правильная последовательность изменения параметра nT3_bar внешним оператором цикла!!!"); 

if((nT3_bar==nT3_limit)&&(nT3_limit<nT3_MaxBar))          
  {
   //----+ <<< Восстановление значений переменных >>> +SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
   nT3_Tnew=Time[nT3_limit+1];
   nT3_Old=nT3_TIME[nT3_num];
   //--+ проверка на ошибки
   if(nT3_Tnew==nT3_Old)
    {
     dT3_e1[nT3_num]=dT3_E1[nT3_num]; dT3_e2[nT3_num]=dT3_E2[nT3_num]; 
     dT3_e3[nT3_num]=dT3_E3[nT3_num]; dT3_e4[nT3_num]=dT3_E4[nT3_num]; 
     dT3_e5[nT3_num]=dT3_E5[nT3_num]; dT3_e6[nT3_num]=dT3_E6[nT3_num];
    }

   if(nT3_Tnew!=nT3_Old)
    {
     nT3_reset=-1;
     //--+ индикация ошибки в расчёте входного параметра T3_limit функции T3Series()
     if (nT3_Tnew>nT3_Old)
       {
        Print("T3Series number ="+(string)nT3_num+
                   ". Ошибка!!! Параметр nT3_limit функции T3Series() меньше чем необходимо");
       }
     else 
       { 
        int nT3_LimitERROR=nT3_limit+1-iBarShift(NULL,0,nT3_Old,TRUE);
        Print("T3Series number ="+(string)nT3_num+
            ". Ошибка!!! Параметр nT3_limit функции T3Series() больше чем необходимо на "
                                                                          +(string)nT3_LimitERROR+"");
       }
     //--+ 
     return(0);
   }
  //----+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
  }
//+--- Сохранение значений переменных +SSSSSSSSSSSS+
if((nT3_bar==1)&&(nT3_limit!=1))
  {
   nT3_TIME[nT3_num]=Time[2];
   dT3_E1[nT3_num]=dT3_e1[nT3_num]; 
   dT3_E2[nT3_num]=dT3_e2[nT3_num]; 
   dT3_E3[nT3_num]=dT3_e3[nT3_num]; 
   dT3_E4[nT3_num]=dT3_e4[nT3_num]; 
   dT3_E5[nT3_num]=dT3_e5[nT3_num]; 
   dT3_E6[nT3_num]=dT3_e6[nT3_num];
  }
//+---+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+

//---- <<< вычисление dT3_T3 >>> --------------------------------------------------------------------+
dT3_e1[nT3_num] = dT3_w1[nT3_num]*dT3_series      + dT3_w2[nT3_num]*dT3_e1[nT3_num];
dT3_e2[nT3_num] = dT3_w1[nT3_num]*dT3_e1[nT3_num] + dT3_w2[nT3_num]*dT3_e2[nT3_num];
dT3_e3[nT3_num] = dT3_w1[nT3_num]*dT3_e2[nT3_num] + dT3_w2[nT3_num]*dT3_e3[nT3_num];
dT3_e4[nT3_num] = dT3_w1[nT3_num]*dT3_e3[nT3_num] + dT3_w2[nT3_num]*dT3_e4[nT3_num];
dT3_e5[nT3_num] = dT3_w1[nT3_num]*dT3_e4[nT3_num] + dT3_w2[nT3_num]*dT3_e5[nT3_num];
dT3_e6[nT3_num] = dT3_w1[nT3_num]*dT3_e5[nT3_num] + dT3_w2[nT3_num]*dT3_e6[nT3_num];
//----  
dT3_T3 = dT3_c1[nT3_num]*dT3_e6[nT3_num] 
                      + dT3_c2[nT3_num]*dT3_e5[nT3_num] 
                                     + dT3_c3[nT3_num]*dT3_e4[nT3_num] 
                                                   + dT3_c4[nT3_num]*dT3_e3[nT3_num];
//---- ----------------------------------------------------------------------------------------------+

//----++ проверка на ошибку в исполнении программного кода функции T3Series()
nT3_Error=GetLastError();
if(nT3_Error>4000)
  {
    Print("T3Series number ="+(string)nT3_num+". При исполнении функции T3Series() произошла ошибка!!!");
    Print("T3Series number ="+(string)nT3_num+ ". ",T3_ErrDescr(nT3_Error));  
    return(0.0);
  }
nT3_reset=0;
if (nT3_bar<nT3_MaxBar-nT3_Period*3)return(dT3_T3);else return(0.0);
//---- завершение вычислений значения функции T3_Series 
}
//---- ---------------------------------------------------------------------------------------------------------+


//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
// T3SeriesResize - Это дополнительная функция для изменения размеров буферных переменных         | 
// функции T3Series. Пример обращения: T3SeriesResize(5); где 5 - это количество обращений к      | 
// T3Series()в тексте индикатора. Это обращение к функции  T3SeriesResize следует поместить       |
// в блок инициализации пользовательского индикатора или эксперта                                 |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int T3SeriesResize(int nT3Resize_Size)
 {
//----+
  if(nT3Resize_Size<1)
   {
    Print("T3SeriesResize: Ошибка!!! Параметр nT3Resize_Size не может быть меньше единицы!!!");
    nT3_Resize=-1;  
    return(0);
   }
  //----+    
  int nT3Resize_reset,nT3Resize_cycle=0;
  //--+
  while(nT3Resize_cycle==0)
   {
    //----++ <<< изменение размеров буферных переменных >>>  +SSSSSSSSSSSSSS+
    if(ArrayResize(dT3_e1,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_e2,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_e3,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_e4,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_e5,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_e6,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_E1,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_E2,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_E3,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_E4,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_E5,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_E6,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_n,   nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_c1,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_c2,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_c3,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_c4,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_w1,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_w2,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_b2,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(dT3_b3,  nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    if(ArrayResize(nT3_TIME,nT3Resize_Size)==0){nT3Resize_reset=-1;break;}
    //----++SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
    nT3Resize_cycle=1;
   }
  //--+
  if(nT3Resize_reset==-1)
   {
    Print("T3SeriesResize: Ошибка!!! Не удалось изменить размеры буферных переменных функции T3Series().");
    int nT3Resize_Error=GetLastError();
    if(nT3Resize_Error>4000)Print("T3SeriesResize(): ",T3_ErrDescr(nT3Resize_Error));       
    nT3_Resize=-2;
    return(0);
   }
  else  
   {
    Print("T3SeriesResize: T3Series Size = "+(string)nT3Resize_Size+"");
    nT3_Resize=nT3Resize_Size;
    return(nT3Resize_Size);
   }  
//----+
 }
//--+ --------------------------------------------------------------------------------------------+
/*
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
T3SeriesAlert - Это дополнительная функция для индикации ошибки в задании внешних переменных      |
функции T3Series.                                                                                 |
  -------------------------- входные параметры  --------------------------                        |
T3SeriesAlert_Number                                                                              |
T3SeriesAlert_ExternVar значение внешней переменной для параметра nT3_Length                      |
T3SeriesAlert_name имя внешней переменной или nT3_Phase, если T3SeriesAlert_Number=1              |
  -------------------------- Пример использования  -----------------------                        |
  int init()                                                                                      |
//----                                                                                            |
Здесь какая-то иницмализация переменных и буферов                                                 |
                                                                                                  |
//---- установка алертов на недопустимые значения внешних переменных                              |                                                                                                                  
T3SeriesAlert(0,"Length1",Length1);                                                               |
T3SeriesAlert(0,"Length2",Length2);                                                               |
//---- завершение инициализации                                                                   |
return(0);                                                                                        |
}                                                                                                 |
//SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
*/
void T3SeriesAlert
 (
  int T3SeriesAlert_Number, string T3SeriesAlert_name, int T3SeriesAlert_ExternVar
 )
 {
  //---- установка алертов на недопустимые значения входных параметров ==========================+ 
  if(T3SeriesAlert_Number==0)if(T3SeriesAlert_ExternVar<1)
          {Alert("Параметр "+T3SeriesAlert_name+" должен быть не менее 1" 
   
     + " Вы ввели недопустимое " +(string)T3SeriesAlert_ExternVar+ " будет использовано  1"  );}
   /*  
  if(T3SeriesAlert_Number==1)
   {
    if(T3SeriesAlert_ExternVar<-100)
          {Alert("Параметр "+T3SeriesAlert_name+" должен быть от -100 до +100" 
          + " Вы ввели недопустимое "+T3SeriesAlert_ExternVar+  " будет использовано -100");}
    if(T3SeriesAlert_ExternVar> 100)
          {Alert("Параметр "+T3SeriesAlert_name+" должен быть от -100 до +100" 
          + " Вы ввели недопустимое "+T3SeriesAlert_ExternVar+  " будет использовано  100");}
   }
   */
 }
//--+ -------------------------------------------------------------------------------------------+


// перевод сделан Николаем Косициным 01.12.2006  
//+------------------------------------------------------------------+
//|                                        T3_ErrDescr_RUS(MQL4).mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
string T3_ErrDescr(int error_code)
 {
  string error_string;
//----
  switch(error_code)
    {
     //---- MQL4 ошибки 
     case 4000: error_string="Код ошибки = "+(string)error_code+". нет ошибки";                                                  break;
     case 4001: error_string="Код ошибки = "+(string)error_code+". Неправильный указатель функции";                              break;
     case 4002: error_string="Код ошибки = "+(string)error_code+". индекс массива не соответствует его размеру";                 break;
     case 4003: error_string="Код ошибки = "+(string)error_code+". Нет памяти для стека функций";                                break;
     case 4004: error_string="Код ошибки = "+(string)error_code+". Переполнение стека после рекурсивного вызова";                break;
     case 4005: error_string="Код ошибки = "+(string)error_code+". На стеке нет памяти для передачи параметров";                 break;
     case 4006: error_string="Код ошибки = "+(string)error_code+". Нет памяти для строкового параметра";                         break;
     case 4007: error_string="Код ошибки = "+(string)error_code+". Нет памяти для временной строки";                             break;
     case 4008: error_string="Код ошибки = "+(string)error_code+". Неинициализированная строка";                                 break;
     case 4009: error_string="Код ошибки = "+(string)error_code+". Неинициализированная строка в массиве";                       break;
     case 4010: error_string="Код ошибки = "+(string)error_code+". Нет памяти для строкового массива";                           break;
     case 4011: error_string="Код ошибки = "+(string)error_code+". Слишком длинная строка";                                      break;
     case 4012: error_string="Код ошибки = "+(string)error_code+". Остаток от деления на ноль";                                  break;
     case 4013: error_string="Код ошибки = "+(string)error_code+". Деление на ноль";                                             break;
     case 4014: error_string="Код ошибки = "+(string)error_code+". Неизвестная команда";                                         break;
     case 4015: error_string="Код ошибки = "+(string)error_code+". Неправильный переход (never generated error)";                break;
     case 4016: error_string="Код ошибки = "+(string)error_code+". Неинициализированный массив";                                 break;
     case 4017: error_string="Код ошибки = "+(string)error_code+". Вызовы DLL не разрешены";                                     break;
     case 4018: error_string="Код ошибки = "+(string)error_code+". Невозможно загрузить библиотеку";                             break;
     case 4019: error_string="Код ошибки = "+(string)error_code+". Невозможно вызвать функцию";                                  break;
     case 4020: error_string="Код ошибки = "+(string)error_code+". Вызовы внешних библиотечных функций не разрешены";            break;
     case 4021: error_string="Код ошибки = "+(string)error_code+". Недостаточно памяти для строки, возвращаемой из функции";     break;
     case 4022: error_string="Код ошибки = "+(string)error_code+". Система занята (never generated error)";                      break;
     case 4050: error_string="Код ошибки = "+(string)error_code+". Неправильное количество параметров функции";                  break;
     case 4051: error_string="Код ошибки = "+(string)error_code+". Недопустимое значение параметра функции";                     break;
     case 4052: error_string="Код ошибки = "+(string)error_code+". Внутренняя ошибка строковой функции";                         break;
     case 4053: error_string="Код ошибки = "+(string)error_code+". Ошибка массива";                                              break;
     case 4054: error_string="Код ошибки = "+(string)error_code+". Неправильное использование массива-таймсерии";                break;
     case 4055: error_string="Код ошибки = "+(string)error_code+". Ошибка пользовательского индикатора";                         break;
     case 4056: error_string="Код ошибки = "+(string)error_code+". Массивы несовместимы";                                        break;
     case 4057: error_string="Код ошибки = "+(string)error_code+". Ошибка обработки глобальныех переменных";                     break;
     case 4058: error_string="Код ошибки = "+(string)error_code+". Глобальная переменная не обнаружена";                         break;
     case 4059: error_string="Код ошибки = "+(string)error_code+". Функция не разрешена в тестовом режиме";                      break;
     case 4060: error_string="Код ошибки = "+(string)error_code+". Функция не подтверждена";                                     break;
     case 4061: error_string="Код ошибки = "+(string)error_code+". Ошибка отправки почты";                                       break;
     case 4062: error_string="Код ошибки = "+(string)error_code+". Ожидается параметр типа string";                              break;
     case 4063: error_string="Код ошибки = "+(string)error_code+". Ожидается параметр типа integer";                             break;
     case 4064: error_string="Код ошибки = "+(string)error_code+". Ожидается параметр типа double";                              break;
     case 4065: error_string="Код ошибки = "+(string)error_code+". В качестве параметра ожидается массив";                       break;
     case 4066: error_string="Код ошибки = "+(string)error_code+". Запрошенные исторические данные в состоянии обновления";      break;
     case 4067: error_string="Код ошибки = "+(string)error_code+". Ошибка при выполнении торговой операции";                     break;
     case 4099: error_string="Код ошибки = "+(string)error_code+". Конец файла";                                                 break;
     case 4100: error_string="Код ошибки = "+(string)error_code+". Ошибка при работе с файлом";                                  break;
     case 4101: error_string="Код ошибки = "+(string)error_code+". Неправильное имя файла";                                      break;
     case 4102: error_string="Код ошибки = "+(string)error_code+". Слишком много открытых файлов";                               break;
     case 4103: error_string="Код ошибки = "+(string)error_code+". Невозможно открыть файл";                                     break;
     case 4104: error_string="Код ошибки = "+(string)error_code+". Несовместимый режим доступа к файлу";                         break;
     case 4105: error_string="Код ошибки = "+(string)error_code+". Ни один ордер не выбран";                                     break;
     case 4106: error_string="Код ошибки = "+(string)error_code+". Неизвестный символ";                                          break;
     case 4107: error_string="Код ошибки = "+(string)error_code+". Неправильный параметр цены для торговой функции";             break;
     case 4108: error_string="Код ошибки = "+(string)error_code+". Неверный номер тикета";                                       break;
     case 4109: error_string="Код ошибки = "+(string)error_code+". Торговля не разрешена";                                       break;
     case 4110: error_string="Код ошибки = "+(string)error_code+". Длинные позиции не разрешены";                                break;
     case 4111: error_string="Код ошибки = "+(string)error_code+". Короткие позиции не разрешены";                               break;
     case 4200: error_string="Код ошибки = "+(string)error_code+". Объект уже существует";                                       break;
     case 4201: error_string="Код ошибки = "+(string)error_code+". Запрошено неизвестное свойство объекта";                      break;
     case 4202: error_string="Код ошибки = "+(string)error_code+". Объект не существует";                                        break;
     case 4203: error_string="Код ошибки = "+(string)error_code+". Неизвестный тип объекта";                                     break;
     case 4204: error_string="Код ошибки = "+(string)error_code+". Нет имени объекта";                                           break;
     case 4205: error_string="Код ошибки = "+(string)error_code+". Ошибка координат объекта";                                    break;
     case 4206: error_string="Код ошибки = "+(string)error_code+". Не найдено указанное подокно";                                break;
     case 4207: error_string="Код ошибки = "+(string)error_code+". Ошибка при работе с объектом";                                break;
     default:   error_string="Код ошибки = "+(string)error_code+". неизвестная ошибка";
    }
//----
  return(error_string);
 }
//+------------------------------------------------------------------+

