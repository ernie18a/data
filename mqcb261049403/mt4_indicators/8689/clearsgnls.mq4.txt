//2009.01.30
//+---------------------------------------------------+
//|	clearSGNLs.mq4												|
//+---------------------------------------------------+
#property copyright "Copyright © 2009, Kurl.FX"
//+---------------------------------------------------+
//|	script 														|
//+---------------------------------------------------+
int start()
  {
   int obj_total=ObjectsTotal();
   string name,chk;
   for(int i=0;i<obj_total;i++)
     {
      name=ObjectName(obj_total-1-i);
      chk=StringSubstr(name,0,4);
      if(chk=="SGNL") ObjectDelete(name);
     }
   return(0);
  }
//+---------------------------------------------------+
