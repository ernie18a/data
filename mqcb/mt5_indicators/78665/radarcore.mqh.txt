//+------------------------------------------------------------------+
//| RadarCore.mqh                                                    |
//| Copyright 2026, Serhii Semenov                                   |
//| https://www.mql5.com/en/users/ssemenov                           |
//+------------------------------------------------------------------+
#ifndef __RADAR_CORE_MQH__
#define __RADAR_CORE_MQH__

//+------------------------------------------------------------------+
//| Margin level in percent: equity / margin * 100                   |
//+------------------------------------------------------------------+
double LevelPercent(const double equity,const double margin)
  {
   if(margin<=0.0)
      return(0.0);
   return(equity/margin*100.0);
  }

//+------------------------------------------------------------------+
//| Equity at which the account reaches the given level              |
//+------------------------------------------------------------------+
double TargetEquity(const double level_or_money,const double margin,const bool money_mode)
  {
   if(money_mode)
      return(level_or_money);
   return(level_or_money/100.0*margin);
  }

//+------------------------------------------------------------------+
//| Level expressed in percent (converts money mode)                 |
//+------------------------------------------------------------------+
double LevelTargetPercent(const double level_or_money,const double margin,const bool money_mode)
  {
   if(!money_mode)
      return(level_or_money);
   if(margin<=0.0)
      return(0.0);
   return(level_or_money/margin*100.0);
  }

//+------------------------------------------------------------------+
//| Distance from equity to the target level in money                |
//+------------------------------------------------------------------+
double MoneyToTarget(const double equity,const double margin,const double level_or_money,const bool money_mode)
  {
   return(equity-TargetEquity(level_or_money,margin,money_mode));
  }

//+------------------------------------------------------------------+
//| Distance to the target level in percent of equity                |
//+------------------------------------------------------------------+
double PercentToTarget(const double equity,const double margin,const double level_or_money,const bool money_mode)
  {
   if(equity<=0.0)
      return(0.0);
   return(MoneyToTarget(equity,margin,level_or_money,money_mode)/equity*100.0);
  }

//+------------------------------------------------------------------+
//| Converts money into points using the book point value            |
//+------------------------------------------------------------------+
double PointsForMoney(const double money,const double money_per_point)
  {
   if(money_per_point<=0.0)
      return(0.0);
   return(money/money_per_point);
  }

//+------------------------------------------------------------------+
//| Equity after the given loss                                      |
//+------------------------------------------------------------------+
double EquityAfterLoss(const double equity,const double loss)
  {
   return(equity-loss);
  }

//+------------------------------------------------------------------+
//| Margin level after the given loss                                |
//+------------------------------------------------------------------+
double LevelAfterLoss(const double equity,const double margin,const double loss)
  {
   return(LevelPercent(equity-loss,margin));
  }

//+------------------------------------------------------------------+
//| Point value from tick value and tick size                        |
//+------------------------------------------------------------------+
double PointValueFromTick(const double tick_value,const double tick_size,const double point)
  {
   if(tick_size<=0.0)
      return(0.0);
   return(tick_value*point/tick_size);
  }

//+------------------------------------------------------------------+
//| Value of one point for the volume                                |
//+------------------------------------------------------------------+
double ValuePerPoint(const string symbol,const double volume)
  {
   if(volume<=0.0)
      return(0.0);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0.0)
      return(0.0);
   double tick_value=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double tick_size =SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   return(PointValueFromTick(tick_value,tick_size,point)*volume);
  }

//+------------------------------------------------------------------+
//| Points in a price move of the given percent                      |
//+------------------------------------------------------------------+
double PointsForPriceMove(const double price,const double percent,const double point)
  {
   if(point<=0.0 || percent<=0.0 || price<=0.0)
      return(0.0);
   return(price*percent/100.0/point);
  }

//+------------------------------------------------------------------+
//| Adds signed exposure: buy +1, sell -1                            |
//+------------------------------------------------------------------+
double AddExposure(const double current,const double direction,const double value)
  {
   return(current+direction*value);
  }

//+------------------------------------------------------------------+
//| Nets point value exposure per symbol over all positions          |
//+------------------------------------------------------------------+
int CollectExposure(string &symbols[],double &exposures[],double &prices[],double &points[])
  {
   int n=0;
   ArrayResize(symbols,0);
   ArrayResize(exposures,0);
   ArrayResize(prices,0);
   ArrayResize(points,0);
   int total=PositionsTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      string symbol=PositionGetString(POSITION_SYMBOL);
      double volume=PositionGetDouble(POSITION_VOLUME);
      double dir=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)?1.0:-1.0;
      double value=ValuePerPoint(symbol,volume);
      int idx=-1;
      for(int j=0;j<n;j++)
         if(symbols[j]==symbol)
           {
            idx=j;
            break;
           }
      if(idx<0)
        {
         n++;
         ArrayResize(symbols,n);
         ArrayResize(exposures,n);
         ArrayResize(prices,n);
         ArrayResize(points,n);
         idx=n-1;
         symbols[idx]=symbol;
         exposures[idx]=0.0;
         prices[idx]=PositionGetDouble(POSITION_PRICE_CURRENT);
         points[idx]=SymbolInfoDouble(symbol,SYMBOL_POINT);
        }
      exposures[idx]=AddExposure(exposures[idx],dir,value);
     }
   return(n);
  }

//+------------------------------------------------------------------+
//| Loss of the netted book for the given moves in points            |
//+------------------------------------------------------------------+
double HedgeAwareLoss(const double &exposures[],const double &move_points[])
  {
   int n=ArraySize(exposures);
   if(n<=0 || ArraySize(move_points)<n)
      return(0.0);
   double loss=0.0;
   for(int i=0;i<n;i++)
      loss+=MathAbs(exposures[i])*move_points[i];
   return(loss);
  }

//+------------------------------------------------------------------+
//| Loss of the netted book per one point move                       |
//+------------------------------------------------------------------+
double BookLossPerPoint()
  {
   string symbols[];
   double exposures[];
   double prices[];
   double points[];
   int n=CollectExposure(symbols,exposures,prices,points);
   double unit[];
   ArrayResize(unit,n);
   for(int i=0;i<n;i++)
      unit[i]=1.0;
   return(HedgeAwareLoss(exposures,unit));
  }

//+------------------------------------------------------------------+
//| Loss of the netted book for an adverse price move                |
//+------------------------------------------------------------------+
double LossForPriceMovePercent(const double percent)
  {
   if(percent<=0.0)
      return(0.0);
   string symbols[];
   double exposures[];
   double prices[];
   double points[];
   int n=CollectExposure(symbols,exposures,prices,points);
   double moves[];
   ArrayResize(moves,n);
   for(int i=0;i<n;i++)
      moves[i]=PointsForPriceMove(prices[i],percent,points[i]);
   return(HedgeAwareLoss(exposures,moves));
  }

//+------------------------------------------------------------------+
//| Formats a money value with the account currency                  |
//+------------------------------------------------------------------+
string FormatMoney(const double value,const string currency)
  {
   return(StringFormat("%.2f %s",value,currency));
  }

//+------------------------------------------------------------------+
//| Formats points or n/a when not defined                           |
//+------------------------------------------------------------------+
string FormatPoints(const double points,const bool available)
  {
   if(!available)
      return("n/a");
   return(StringFormat("%.0f pts",points));
  }

#endif
