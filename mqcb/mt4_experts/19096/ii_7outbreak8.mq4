//+------------------------------------------------------------------+
//|                                     II (Outbreak) Expert Advisor |
//|                                     Copyright 2017, S.Aukscionis |
//+------------------------------------------------------------------+
#property     copyright   "2017, S.Aukscionis"
#property     version     "9.1" 
#property     description "II (Outbreak)" 
#property     strict
//---
extern double Commission=4;//Comission per round lot    
extern int    SpreadThreshold=6;//Maximum spread to open orders (in points)
extern int    MagicNumber=11;//Magic number
extern bool   WarningAlerts=true;//Display warning alerts
int           slip=3;//Slippage in points  
int           TrailStop=20;//Trailing stop in points
int           TrailStart;//Trailing stop start point (initialized in init depending on comission)
double        TotalEquityRisk=0.5;//Equity drawdown for closing all open positions
double        MaximumRisk=0.1;//Maximum position volume risk
int           PyramidingStep;//Distance between sequential orders (initialized in init depending on average spread)
double        lots;//Position volume
string        EAName="II";//Expert advisor name
int           cnt;//Count for total orders
int           BuyPyramidLevel;//Current buy pyramiding level
int           SellPyramidLevel;//Current sell pyramiding level
double        price;//Variable for storing OrderSend parameter values
double        stoploss;//Variable for storing OrderSend parameter values
bool          StaticStopEnabled;// Static stop loss for base order
//---
long          tickvolume[1];//Array for storing tick volumes
int           time;//Time variable
double        mass;//Mass variable
double        amplitude;//Amplitude variable
double        volatilitybuffer;//Volatility variable
double        timingbuffer[3];//Array for storing timing indicator values
bool          Volatility;//Volatility signal variable
bool          Sell;//Sell signal variable
bool          Buy;//Buy signal variable
//---
string        CurrentSymbol;//Multicurrency variable
int           CurrentVolatilityLevel;//Multicurrency variable
int           CurrentSpread;//Multicurrency variable
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   TrailStart=TrailStop+(int)Commission+SpreadThreshold;
   PyramidingStep=MathMax(10,SpreadThreshold+1);
   Volatility=false;
   Sell=false;
   Buy=false;
   StaticStopEnabled=true;
   return(0);
  }
//+------------------------------------------------------------------+
//|  Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   return;
  }
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(CountOrders(Symbol())!=0)
     {
      if(!StaticStopEnabled && AccountBalance()-AccountEquity()>TotalEquityRisk/100.0*AccountBalance())
         CloseAll(CurrentSymbol);
      TrailPyramid(TrailStart,TrailStop,CurrentSymbol,CurrentVolatilityLevel,CurrentSpread);
     }
   if(CountOrders(Symbol())==0)
     {
      if((DayOfWeek()==5 && Hour()==23) || 
         ((DayOfYear()==358||DayOfYear()==359||DayOfYear()==365||DayOfYear()==366)&&Hour()>=16)) return;
      BuyPyramidLevel=0; SellPyramidLevel=0; StaticStopEnabled=true;
      CurrentSymbol="";
      OrderSendBlock(Symbol(),800,SpreadThreshold);//800
     }
   return;
  }
//+------------------------------------------------------------------+
//| Send primary orders                                              |
//+------------------------------------------------------------------+
void OrderSendBlock(string currentsymbol,int currentvolatilitylevel,int currentspread)
  {
   if(iStdDev(currentsymbol,PERIOD_M1,10,0,MODE_SMA,PRICE_CLOSE,0)>0.002)
     { if(WarningAlerts && Seconds()%50==0) Print("Volatility conditions are not met, no further opening of trades"); return; }
   if(CurrentSymbol=="" || CurrentSymbol==currentsymbol)
     {
      Lots(currentsymbol); Timing(currentsymbol); CalculateVolatility(currentsymbol,currentvolatilitylevel);
      if(AccountMargin()<lots*SymbolInfoDouble(currentsymbol,SYMBOL_TRADE_CONTRACT_SIZE)/AccountLeverage()*(1+MaximumRisk*190))
        {
         if(Buy && Volatility && MarketInfo(currentsymbol,MODE_SPREAD)<=currentspread)
           {
            price=MarketInfo(currentsymbol,MODE_ASK);
            stoploss=MarketInfo(currentsymbol,MODE_BID)-TrailStop*2*MarketInfo(currentsymbol,MODE_POINT);
            if(OrderSend(currentsymbol,OP_BUY,lots,price,0,stoploss,0,EAName,MagicNumber,0,Blue))
              {CurrentSymbol=currentsymbol; CurrentVolatilityLevel=currentvolatilitylevel; CurrentSpread=currentspread; return;}
           }
         if(Sell && Volatility && MarketInfo(currentsymbol,MODE_SPREAD)<=currentspread)
           {
            price=MarketInfo(currentsymbol,MODE_BID);
            stoploss=MarketInfo(currentsymbol,MODE_ASK)+TrailStop*2*MarketInfo(currentsymbol,MODE_POINT);
            if(OrderSend(currentsymbol,OP_SELL,lots,price,0,stoploss,0,EAName,MagicNumber,0,Red))
              {CurrentSymbol=currentsymbol; CurrentVolatilityLevel=currentvolatilitylevel; CurrentSpread=currentspread; return;}
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Close all open orders                                            |
//+------------------------------------------------------------------+
void CloseAll(string currentsymbol)
  {
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=currentsymbol || OrderMagicNumber()!=MagicNumber) continue;
      if(OrderType()==OP_BUY)
      if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slip,clrNONE)){}
      if(OrderType()==OP_SELL)
      if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slip,clrNONE)){}
     }
  }
//+------------------------------------------------------------------+
//| Trail current orders and send sequential orders                  |
//+------------------------------------------------------------------+
void TrailPyramid(int start,int stop,string currentsymbol,int currentvolatilitylevel,int currentspread)
  {
   int profit;
   double stoptrade,stopcal;
   if(stop==0) return;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES) || OrderSymbol()!=currentsymbol
         || OrderMagicNumber()!=MagicNumber) continue;
      if(OrderType()==OP_BUY)
        {
         profit=(int)NormalizeDouble((MarketInfo(currentsymbol,MODE_BID)-OrderOpenPrice())/MarketInfo(currentsymbol,MODE_POINT),0);
         if(profit<start) continue;
         stoptrade=OrderStopLoss();
         stopcal=MarketInfo(currentsymbol,MODE_BID)-(stop*MarketInfo(currentsymbol,MODE_POINT));
         if(stoptrade==0 || (stoptrade!=0 && /*stopcal>stoptrade*/stopcal-stoptrade>=MarketInfo(currentsymbol,MODE_POINT)))
           {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,0,0)){}
            if(profit<BuyPyramidLevel+PyramidingStep) continue;
            if(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)!=0 && OrdersTotal()==AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)) continue;
            if(AccountMargin()<OrderLots()*SymbolInfoDouble(currentsymbol,SYMBOL_TRADE_CONTRACT_SIZE)/AccountLeverage()*(1+MaximumRisk*190))
              {
               Timing(currentsymbol); CalculateVolatility(currentsymbol,currentvolatilitylevel);
               if(Buy && Volatility && MarketInfo(currentsymbol,MODE_SPREAD)<=currentspread)
                 {
                  Lots(currentsymbol); price=MarketInfo(currentsymbol,MODE_ASK);
                  if(OrderSend(currentsymbol,OP_BUY,lots,price,0,0,0,EAName,MagicNumber,0,Blue))
                    {BuyPyramidLevel=profit; StaticStopEnabled=false;}
                 }
              }
           }
        }
      if(OrderType()==OP_SELL)
        {
         profit=(int)NormalizeDouble((OrderOpenPrice()-MarketInfo(currentsymbol,MODE_ASK))/MarketInfo(currentsymbol,MODE_POINT),0);
         if(profit<start) continue;
         stoptrade=OrderStopLoss();
         stopcal=MarketInfo(currentsymbol,MODE_ASK)+(stop*MarketInfo(currentsymbol,MODE_POINT));
         if(stoptrade==0 || (stoptrade!=0 && /*stopcal<stoptrade*/stoptrade-stopcal>=MarketInfo(currentsymbol,MODE_POINT)))
           {
            if(OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,0,0)){}
            if(profit<SellPyramidLevel+PyramidingStep) continue;
            if(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)!=0 && OrdersTotal()==AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)) continue;
            if(AccountMargin()<OrderLots()*SymbolInfoDouble(currentsymbol,SYMBOL_TRADE_CONTRACT_SIZE)/AccountLeverage()*(1+MaximumRisk*190))
              {
               Timing(currentsymbol); CalculateVolatility(currentsymbol,currentvolatilitylevel);
               if(Sell && Volatility && MarketInfo(currentsymbol,MODE_SPREAD)<=currentspread)
                 {
                  Lots(currentsymbol); price=MarketInfo(currentsymbol,MODE_BID);
                  if(OrderSend(currentsymbol,OP_SELL,lots,price,0,0,0,EAName,MagicNumber,0,Red))
                    {SellPyramidLevel=profit; StaticStopEnabled=false;}
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Count orders for particular symbol                               |
//+------------------------------------------------------------------+
int CountOrders(string currentsymbol)
  {
   int count=0;
   for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==currentsymbol && OrderType()<=OP_SELLSTOP && OrderMagicNumber()==MagicNumber)
            count++;
     }
   return(count);
  }
//+------------------------------------------------------------------+
//| Calculate position volume                                        |
//+------------------------------------------------------------------+
void Lots(string currentsymbol)
  {
   int LotsDigits=(int)-MathLog10(MarketInfo(currentsymbol,MODE_MINLOT));
   lots=NormalizeDouble(AccountBalance()*MaximumRisk/(500000.0/AccountLeverage()),LotsDigits);
   if(lots>MarketInfo(currentsymbol,MODE_MAXLOT))
      lots=MarketInfo(currentsymbol,MODE_MAXLOT);
   if(lots<MarketInfo(currentsymbol,MODE_MINLOT))
      lots=MarketInfo(currentsymbol,MODE_MINLOT);
  }
//+------------------------------------------------------------------+
//|  Calculate volatility                                            |
//+------------------------------------------------------------------+
void CalculateVolatility(string currentsymbol,int currentvolatilitylevel)
  {
   time=(int)(TimeCurrent()-iTime(currentsymbol,PERIOD_M1,0));
   if(time!=0)
     {
      amplitude=(MathAbs(iHigh(currentsymbol,PERIOD_M1,1)-iLow(currentsymbol,PERIOD_M1,0))
                 +MathAbs(iHigh(currentsymbol,PERIOD_M1,0)-iLow(currentsymbol,PERIOD_M1,1))
                 +MathAbs(iClose(currentsymbol,PERIOD_M1,1)-iClose(currentsymbol,PERIOD_M1,0)))/MarketInfo(currentsymbol,MODE_POINT);
      CopyTickVolume(currentsymbol,PERIOD_M1,TimeCurrent(),iTime(currentsymbol,PERIOD_M1,0),tickvolume);
      mass=(double)(tickvolume[0]/time);
      volatilitybuffer=amplitude*mass;
      if(volatilitybuffer>currentvolatilitylevel) Volatility=true; else Volatility=false;
     }
  }
//+------------------------------------------------------------------+
//| Calculate trend formation and timing                             |
//+------------------------------------------------------------------+
void Timing(string currentsymbol)
  {
   int  j=0,i=0;
   double tval=0,dmov=0,amov=0,cpiv=0,ppiv=0,dpiv=0;
   double dtemp1=0, dtemp2=0, dtemp3=0, dtemp4=0, dtemp5=0, dtemp6=0, dtemp7=0, dtemp8=0;
   double atemp1=0, atemp2=0, atemp3=0, atemp4=0, atemp5=0, atemp6=0, atemp7=0, atemp8=0;
   for(int tnc=119;tnc>=0;tnc--)
     {
      if(j==0)
        {
         j=1; i=0;
         cpiv=100.0*((iHigh(currentsymbol,PERIOD_M1,tnc)+iLow(currentsymbol,PERIOD_M1,tnc)
                     +iClose(currentsymbol,PERIOD_M1,tnc))/3.0);
        }
      else
        {
         if(j<7) j++; ppiv=cpiv;
         cpiv=100.0*((iHigh(currentsymbol,PERIOD_M1,tnc)+iLow(currentsymbol,PERIOD_M1,tnc)
                     +iClose(currentsymbol,PERIOD_M1,tnc))/3.0);
         dpiv=cpiv-ppiv;
         dtemp1=2.0/3.0*dtemp1+1.0/3.0*dpiv; dtemp2=1.0/3.0*dtemp1+2.0/3.0*dtemp2;
         dtemp3=1.5*dtemp1-dtemp2/2.0; dtemp4=2.0/3.0*dtemp4+1.0/3.0*dtemp3;
         dtemp5=1.0/3.0*dtemp4+2.0/3.0*dtemp5; dtemp6=1.5*dtemp4-dtemp5/2.0;
         dtemp7=2.0/3.0*dtemp7+1.0/3.0*dtemp6; dtemp8=1.0/3.0*dtemp7+2.0/3.0*dtemp8;
         dmov=1.5*dtemp7-dtemp8/2.0;
         atemp1=2.0/3.0*atemp1+1.0/3.0*MathAbs(dpiv); atemp2=1.0/3.0*atemp1+2.0/3.0*atemp2;
         atemp3=1.5*atemp1-atemp2/2.0; atemp4=2.0/3.0*atemp4+1.0/3.0*atemp3;
         atemp5=1.0/3.0*atemp4+2.0/3.0*atemp5; atemp6=1.5*atemp4-atemp5/2.0;
         atemp7=2.0/3.0*atemp7+1.0/3.0*atemp6; atemp8=1.0/3.0*atemp7+2.0/3.0*atemp8;
         amov=1.5*atemp7-atemp8/2.0;
         if(j<=6 && cpiv!=ppiv) i++; if(j==6 && i==0) j=0;
        }
      if(j>6 && amov>0.0000000001)
        {
         tval=50.0*(dmov/amov+1.0);
         if(tval>100.0) tval=100.0;
         if(tval<0.0) tval=0.0;
        }
      else tval=50.0;
      if(tnc<=2) timingbuffer[tnc]=tval;
     }
   if(timingbuffer[1]<=timingbuffer[2] && timingbuffer[0]>timingbuffer[1]) Buy=true; else Buy=false;
   if(timingbuffer[1]>=timingbuffer[2] && timingbuffer[0]<timingbuffer[1]) Sell=true; else Sell=false;
  }
//+----------------------------------------------------------------------------------
