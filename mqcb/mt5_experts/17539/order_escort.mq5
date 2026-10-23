//+------------------------------------------------------------------+
//|                                                 order_escort.mq5 |
//|                                                         Aternion |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Aternion"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum traling_type                   // перечисление именованных констант 
  {
   linear,
   parabolic,
   exponential
  };
                                    // параметры мишени
input double target_bar=35;         // смещение относительно текущей координаты, в барах 
input double delta_points=80;       // изменение цены относительно текущей, в пипсах

input traling_type type=linear;     // кривая сопровождения
input double exponent=0.5;           // показатель степени для степенной функции
input double e=2.718;               // основание экспоненциальной кривой
input bool tp_escort=true;          // перемещать тейкпрофит позиции
input int close_bar=15;             // закрытие позиции через n-ное количество баров




datetime date1=TimeCurrent();
int bar_counter=0;

double k0=(delta_points/(target_bar));                                //определение коэффициентов для кривых сопровождения
double k1=( delta_points/ MathPow( (target_bar),exponent) );
double k2=( delta_points/ MathPow( e ,(target_bar)) );




double sl_null,tp_null; ulong ticket;

double traling=0;

bool flag_oder=true;

int OnInit() { return(0); }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   int i;

   double sl1=0,tp1=0;

   if(isNewBar())       //перерассчет производится только после появление нового бара
     {
      bar_counter++;

      switch(type)      // рассчитывается абсолютное смещение стоприказов, учитывая определенные ранее коэффициенты
        {
         case linear:
            traling=k0*(bar_counter);
            break;
         case parabolic:
            traling=k1*MathPow((bar_counter),exponent);
            break;
         case exponential:
            traling=k2*MathPow(e,(bar_counter));
            break;
        }

     }

   MqlTradeRequest request;
   MqlTradeResult  result;

   int total=PositionsTotal();

   for(i=total-1; i>=0; i--)
     {

      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);

      double sl=PositionGetDouble(POSITION_SL);
      double tp=PositionGetDouble(POSITION_TP);

      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);

      double volume=PositionGetDouble(POSITION_VOLUME);

      ENUM_POSITION_TYPE typ=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(flag_oder && position_symbol==Symbol())            // запоминаем параметры позиции по текущему символу
        {   sl_null=sl;    tp_null=tp;  ticket=position_ticket;      flag_oder=false;    }

      if(sl!=0)
        {

         if(typ==POSITION_TYPE_BUY)                         //вычислются текущие значения стоплосса и тейкпрофита
           {
            sl1=sl_null+traling*Point();
            if(tp>0.00000001 && tp_escort) tp1=tp_null+traling*Point();
           }
         if(typ==POSITION_TYPE_SELL)
           {
            sl1=sl_null-traling*Point();
            if(tp>0.00000001 && tp_escort) tp1=tp_null-traling*Point();
           }

         ZeroMemory(request);
         ZeroMemory(result);

         request.action  =TRADE_ACTION_SLTP;
         request.position=position_ticket;
         request.symbol=position_symbol;

         request.sl=sl1;
         request.tp=tp1;


         request.magic=magic;

         if(MathAbs(PositionGetDouble(POSITION_SL)-request.sl)>5*Point()) //стопприказы смещаются только при изменении их числовых значений более чем на 5 пипсов.
           { if(OrderSend(request,result)) continue;      }

        }

      if(bar_counter==close_bar)                                          // закрытие позиции через n-ное количество баров
        {

         ZeroMemory(request);
         ZeroMemory(result);

         request.action=TRADE_ACTION_DEAL;
         request.position=PositionGetTicket(i);
         request.symbol=PositionGetString(POSITION_SYMBOL);
         request.volume=PositionGetDouble(POSITION_VOLUME);
         request.deviation=50;
         request.magic=OrderGetInteger(ORDER_MAGIC);

         if(typ==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         if(OrderSend(request,result)) continue;

        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()                              //функция определения появления нового бара
  {

   static datetime last_time=0;

   datetime lastbar_time=SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

   if(last_time==0)
     {
      last_time=lastbar_time;
      return(false);
     }

   if(last_time!=lastbar_time)
     {

      last_time=lastbar_time;
      return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
