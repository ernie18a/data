//+---------------------------------------------------------------------------------+
//|                                                         calc.mq4                |
//|                                Copyright © 2008, Borys Chekmasov                |
//|                                     http://uatrader.blogspot.com                |
//+---------------------------------------------------------------------------------+
// The indicator should be used for calculation of orders.                          |
// Create in the chart three lines named as OPEN, STOP, PROFIT, and                 |
// arrange them, respectively, at the levels, at which you are going                |
// to open (OPEN) an order, place a StopLoss (STOP) and a TakeProfit (PROFIT).      |
// If there are no such lines in the chart, the indicator will create them          |
// automatically near the current market price. Set in the indicator's proiperties  |
// the lot size you are going to open with (calc_lots) and commission (comission)   |
// for Futures and CFD, if your trade is calculated for these securities            |
// (for Futures - commission in dollars per lot, for CFD - per share in percents).  |
// If in CFD on stock one lot is equal to 100 shares, not to only one, then set     |
// the parameter stock_in_lot for 100. For securities, for which profits are        |
// calculated in euro or pounds (FDAX, FTSE), the forex pairs of EURUSD or          |
// respectively, GPBUSD should be displayed in the Market Watch window,             |
// then the rates will be automatically taken from the corresponding forex pairs.   |
// Similarly, for cross-currencies XXXYYY, there must be opened the corresponding   |
// basic pairs USDYYY (for example, for GPBJPY, there must be USDJPY opened in the  | 
// Market Watch window). After you have placed SL and TP lines at desired levels,   |
// the indicator will automatically display in the upper left corner of the chart   |
// the sizes in dollars of profits for TP, of losses for SL, and of the supporting  |
// margin for the specified amount of lots. It will also draw in the chart          |
// a line, upon reaching which by the price Stop Out will take place. To calculate  |
// new values, it will be sufficient just to drag the lines in the chart.           |
// The values are updated at every tick, so for low-liquidity symbols               |
// or within breaks between sessions, click with the right button on the chart      |
// and select the item "Update" to obtain new values.                               |
//+---------------------------------------------------------------------------------+
#property copyright "Copyright © 2008, Borys Chekmasov"
#property link      "http://uatrader.blogspot.com"

#property indicator_chart_window

extern double calc_lots= 0.1; //кол-во лотов
extern double comission = 10; //комиссия
extern double stock_in_lot=1; //количество акций в одном лоте


double eurusd_k= 1.3005; //значение курса EURUSD если символ все же отключен в обзоре рынка
double gpbusd_k = 1.546; //значение курса GPBUSD если символ все же отключен в обзоре рынка
double usdjpy_k= 0.00958;//значение курса 1/USDJPY если символ все же отключен в обзоре рынка

double stopout_level; //уровень стопаута
double proff,preproff,preloss,kurs;
double loss,start_margin,calc_margin,stopout_lvl2,stopout_lvl,marginsum,marginsum2,stopout_lvl3,stopout_lvl4;
double tikk_v;//стоимость тика
double tikk_s;//размер тика
int tikk_m;//режим расчета профита
double tikk_l;//стоимость лота

string comnts;

int leverage_lev;//плечо
//+------------------------------------------------------------------+
//| инициализация                                                    |
//+------------------------------------------------------------------+

int init()
  {

   tikk_v = MarketInfo (Symbol(),MODE_TICKVALUE);
   tikk_s = MarketInfo (Symbol(),MODE_TICKSIZE);
   tikk_m = (int)MarketInfo (Symbol(),MODE_PROFITCALCMODE);
   tikk_l = MarketInfo (Symbol(),MODE_LOTSIZE);
   stopout_level= AccountStopoutLevel();
   leverage_lev = AccountLeverage();
   start_margin = calc_lots*MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   calc_margin=calc_lots*MarketInfo(Symbol(),MODE_MARGINMAINTENANCE);
   if(calc_margin<=0)
     {
      calc_margin=calc_lots*tikk_l/leverage_lev;
     }
   comnts=" ";
   if(MarketInfo("EURUSD",MODE_BID)>0) eurusd_k = MarketInfo("EURUSD",MODE_BID);
   if(MarketInfo("GPBUSD",MODE_BID)>0) gpbusd_k = MarketInfo("GPBUSD",MODE_BID);
   if(MarketInfo("USDJPY",MODE_BID)>0) usdjpy_k = 1/MarketInfo("USDJPY",MODE_BID);
// инструменты со стоимостью пункта в отличных от доллара валютах (WHC):
   kurs=1;
// Создание линий для вычислений
   if(ObjectFind("OPEN")== -1) ObjectCreate("OPEN",OBJ_HLINE,0,0,Open[0]);
   if(ObjectFind("STOP")== -1) ObjectCreate("STOP",OBJ_HLINE,0,0,Open[3]);
   if(ObjectFind("PROFIT")==-1)
      if(Bars>9)
         ObjectCreate("PROFIT",OBJ_HLINE,0,0,Open[9]);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll();
   Comment(" ");
//ObjectDelete("STOPOUT");
  }
//+------------------------------------------------------------------+
//| основной цикл                                                    |
//+------------------------------------------------------------------+
int start()
  {

//вычисление значений калькулятора
   preproff= kurs*MathAbs(ObjectGet("OPEN",OBJPROP_PRICE1)-ObjectGet("PROFIT",OBJPROP_PRICE1));
   preloss = kurs*MathAbs(ObjectGet("OPEN", OBJPROP_PRICE1)-ObjectGet("STOP", OBJPROP_PRICE1));
   marginsum=((100-stopout_level)/100)*MathAbs(AccountBalance()-calc_margin);
   switch(tikk_m)
     {
      case 0: // Forex
         if(StringSubstr(Symbol(),3,3)=="USD") //пары XXXUSD
           {
            proff=preproff*calc_lots*tikk_l;
            loss=preloss*calc_lots*tikk_l;
            stopout_lvl=ObjectGet("OPEN",OBJPROP_PRICE1)+marginsum/(calc_lots*tikk_l);
            stopout_lvl2=ObjectGet("OPEN",OBJPROP_PRICE1)-marginsum/(calc_lots*tikk_l);
            if(start_margin<=0)start_margin=calc_lots*tikk_l/leverage_lev;
           }
         if(StringSubstr(Symbol(),0,3)=="USD") // пары USDXXX
           {
            proff= preproff*calc_lots*tikk_l/ObjectGet("PROFIT",OBJPROP_PRICE1);
            loss = preloss*calc_lots*tikk_l/ObjectGet("STOP",OBJPROP_PRICE1);
            marginsum=((100-stopout_level)/100)*MathAbs(AccountBalance()-calc_margin/Bid);
            marginsum2=((100-stopout_level)/100)*MathAbs(AccountBalance()-calc_margin/Bid);
            stopout_lvl=ObjectGet("OPEN",OBJPROP_PRICE1)+marginsum/(calc_lots*tikk_l/Bid);
            stopout_lvl2=ObjectGet("OPEN",OBJPROP_PRICE1)-marginsum/(calc_lots*tikk_l/Bid);

            if(start_margin==0)start_margin=(calc_margin)/Bid;
           }

         if(StringFind(Symbol(),"USD",0)==-1) // кроскурсы
           {
            if(MarketInfo("USD"+StringSubstr(Symbol(),3,3),MODE_BID)>0)
              {
               double tmpinfo=MarketInfo("USD"+StringSubstr(Symbol(),3,3),MODE_BID);
               marginsum=((100-stopout_level)/100)*MathAbs(AccountBalance()-calc_margin/tmpinfo);

               proff= preproff*calc_lots*tikk_l/tmpinfo;
               loss = preloss*calc_lots*tikk_l/tmpinfo;
               stopout_lvl=ObjectGet("OPEN",OBJPROP_PRICE1)+marginsum/(calc_lots*tikk_l/tmpinfo);
               stopout_lvl2=ObjectGet("OPEN",OBJPROP_PRICE1)-marginsum/(calc_lots*tikk_l/tmpinfo);
               if(start_margin<=0)start_margin=(calc_lots*tikk_l/leverage_lev)/tmpinfo;
              }
            else
              {
               if(MarketInfo(StringSubstr(Symbol(),0,3)+"USD",MODE_BID)>0)
                 {
                  double tmpinfo2=MarketInfo(StringSubstr(Symbol(),0,3)+"USD",MODE_BID);
                  marginsum=((100-stopout_level)/100)*MathAbs(AccountBalance()-calc_margin*tmpinfo2);
                  proff= preproff*calc_lots*tikk_l*tmpinfo2;
                  loss = preloss*calc_lots*tikk_l*tmpinfo2;
                  stopout_lvl=ObjectGet("OPEN",OBJPROP_PRICE1)+marginsum/(calc_lots*tikk_l*tmpinfo2);
                  stopout_lvl2=ObjectGet("OPEN",OBJPROP_PRICE1)-marginsum/(calc_lots*tikk_l*tmpinfo2);

                  if(start_margin<=0)start_margin=(calc_lots*tikk_l/leverage_lev)*tmpinfo2;
                 }
               else
                 {
                  //////
                  double xxx=1;
                  if(StringSubstr(Symbol(), 3, 3)=="CAD") xxx=1.019;
                  if(StringSubstr(Symbol(), 3, 3)=="JPY") xxx=105;
                  if(StringSubstr(Symbol(), 3, 3)=="CHF") xxx=1.05;
                  if(StringSubstr(Symbol(), 3, 3)=="AUD") xxx=1/0.933;
                  if(StringSubstr(Symbol(), 3, 3)=="NZD") xxx=1/0.7820;
                  if(StringSubstr(Symbol(), 3, 3)=="GPB") xxx=1/1.9850;
                  if(StringSubstr(Symbol(), 3, 3)=="EUR") xxx=1/1.55;
                  marginsum=((100-stopout_level)/100)*MathAbs(AccountBalance()-calc_margin/xxx);
                  proff= preproff*calc_lots*tikk_v/tikk_s;
                  loss = preloss*calc_lots*tikk_v/tikk_s;
                  stopout_lvl=ObjectGet("OPEN",OBJPROP_PRICE1)+marginsum/(calc_lots*tikk_v/(tikk_s/xxx));
                  stopout_lvl2=ObjectGet("OPEN",OBJPROP_PRICE1)-marginsum/(calc_lots*tikk_v/(tikk_s/xxx));
                  ///// 
                 }
              }

           }
         break;
      case 1: //CFD стоки
        {
         double temp3=ObjectGet("OPEN",OBJPROP_PRICE1);

         proff = preproff*calc_lots*stock_in_lot - (comission/100)*calc_lots*temp3;
         loss  = preloss*calc_lots*stock_in_lot  + (comission/100)*calc_lots*temp3;
         stopout_lvl=temp3+(marginsum-(comission/100)*calc_lots*temp3)/(calc_lots*stock_in_lot);
         stopout_lvl2=temp3 -(marginsum-(comission/100)*calc_lots*temp3)/(calc_lots*stock_in_lot);
        }
      break;
      default: // фьючи
         proff=(preproff*calc_lots*tikk_v/tikk_s) -(calc_lots*comission);
         loss =(preloss*calc_lots*tikk_v/tikk_s)+(calc_lots*comission);
         stopout_lvl=ObjectGet("OPEN",OBJPROP_PRICE1)+(marginsum/kurs-calc_lots*comission)/(calc_lots*tikk_v/tikk_s);
         stopout_lvl2=ObjectGet("OPEN",OBJPROP_PRICE1) -(marginsum/kurs-calc_lots*comission)/(calc_lots*tikk_v/tikk_s);

         marginsum=marginsum/kurs;

         break;
     }
//установка линии стопаута
   if(ObjectGet("OPEN",OBJPROP_PRICE1)>ObjectGet("PROFIT",OBJPROP_PRICE1))
     {
      if(ObjectFind("STOPOUT")==-1) ObjectCreate("STOPOUT",OBJ_HLINE,0,0,stopout_lvl);
      ObjectSet("STOPOUT",OBJPROP_PRICE1,stopout_lvl);
     }
   else
     {
      if(ObjectFind("STOPOUT")==-1) ObjectCreate("STOPOUT",OBJ_HLINE,0,0,stopout_lvl2);
      ObjectSet("STOPOUT",OBJPROP_PRICE1,stopout_lvl2);
     }

// пояснительные текста на линии
   ObjectSetText("STOPOUT","Уровень стопаута -"+DoubleToStr(marginsum,2)+"USD",10,"Times New Roman",Green);

   ObjectSetText("OPEN","                            Open "+DoubleToStr(calc_lots,2)+" лотов",10,"Times New Roman",Green);
   ObjectSetText("STOP","Stop "+DoubleToStr(loss,2),10,"Times New Roman",Green);
   ObjectSetText("PROFIT","Profit "+DoubleToStr(proff,2),10,"Times New Roman",Green);

//вывод в левый верхний угол значений калькулятора   
   comnts="Для "+DoubleToStr(calc_lots,2)+" лотов Профит: "+DoubleToStr(proff,2)+" ("+DoubleToStr(proff*100/AccountEquity(),2)+"%) "+" Лосс: "+DoubleToStr(loss,2)+" ("+DoubleToStr(loss*100/AccountEquity(),2)+"%) ";
   if(start_margin>0) comnts= comnts+"Стартовая маржа: "+DoubleToStr(start_margin,2)+" USD";
   if(leverage_lev>0) comnts= comnts+" Плечо: "+DoubleToStr(leverage_lev,2);
   Comment(comnts);

   return(0);
  }
//+------------------------------------------------------------------+
