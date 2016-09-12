//+------------------------------------------------------------------+
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "kenorb"
#property version   "1.00"
#property strict

extern int       RISK=2;

#include  <Convert.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ADX
  {

public:

   double            value1,x1,x2;
   double            value2;

   void Update(int period)
     {

      int i;
      int Counter,i1,value11;

      double TCount,Range,AvgRange,M1,M2;

     

      x1=67+RISK;
      x2=33-RISK;
      value11=period;

      //******************************************************************************
      Range=0.0;
      AvgRange=0.0;
      for(Counter=0; Counter<=period; Counter++)
         AvgRange=AvgRange+MathAbs(High[Counter]-Low[Counter]);

      Range=AvgRange/(period+1);
      TCount=0;
      Counter=0;
      while(Counter<period && TCount<1)
        {
         if(MathAbs(Open[Counter]-Close[Counter+1])>=Range*2.0) TCount++;
         Counter++;
        }
      if(TCount>=1) {M1=Counter;} else {M1=-1;}
      Counter=0;
      TCount=0;
      while(Counter<(period-3) && TCount<1)
        {
         if(MathAbs(Close[Counter+3]-Close[Counter])>=Range*4.6) TCount++;
         Counter++;
        }
      if(TCount>=1) {M2=Counter;} else {M2=-1;}
      if(M1>-1) {value11=MathFloor(period/3);} else {value11=period;}
      if(M2>-1) {value11=MathFloor(period/2);} else {value11=period;}


      //****************************************************************************************

      value1=100-MathAbs(iWPR(NULL,0,value11,0));
      value2=100-MathAbs(iWPR(NULL,0,value11,1));



     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      if(value1>x1 && value2<x1 && cmd==OP_BUY)
         return true;


      if(value1<x2 && value2>x2 && cmd==OP_SELL)
         return true;


      return false;

     }

  };
//+------------------------------------------------------------------+
