//+------------------------------------------------------------------+
//|                                           ScaleFibonacciArcs.mq5 |
//|                                  Copyright 2016, André S. Enger. |
//|                                          andre_enger@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Andre S. Enger."
#property link      "andre_enger@hotmail.com"
#property version   "1.01"
#property description "Script to set correct scale on Fibonacci arcs attached to chart."
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   for(int i=ObjectsTotal(0,-1,OBJ_FIBOARC)-1; i>=0; i--)
     {
      string name=ObjectName(0,i,-1,OBJ_FIBOARC);
      double p0=ObjectGetDouble(0,name,OBJPROP_PRICE,0);
      double p1=ObjectGetDouble(0,name,OBJPROP_PRICE,1);
      long t0=ObjectGetInteger(0,name,OBJPROP_TIME,0);
      long t1=ObjectGetInteger(0,name,OBJPROP_TIME,1);
      double scale=MathAbs(p0-p1)/MathAbs(t0-t1);
      scale*=PeriodSeconds()/Point();
      ObjectSetDouble(0,name,OBJPROP_SCALE,scale);
     }
  }
//+------------------------------------------------------------------+
