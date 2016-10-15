//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict
//#include  <Convert.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

extern string separator2 = "*** Indicator Settings ***";
extern string separator1 = "*** OSMA Settings ***";
extern int    signal=9;
extern bool   drawDivergenceLines=false;
extern bool   displayAlert=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   double            ClassicalBullishDivergence,ReverseBullishDivergence,ClassicalBearishDivergence,ReverseBearishDivergence;

   void Update(int tf=PERIOD_M1)
     {

      ClassicalBullishDivergence=iCustom(Symbol(),tf,"OSMA_Divergence_V2_2.01",separator1,12,26,signal,separator2,drawDivergenceLines,1,0);

      ReverseBullishDivergence=iCustom(NULL,tf,"OSMA_Divergence_V2_2.01",separator1,8,32,signal,separator2,drawDivergenceLines,1,0);

      ClassicalBearishDivergence=iCustom(NULL,tf,"OSMA_Divergence_V2_2.01",separator1,12,26,signal,separator2,drawDivergenceLines,1,1);

      ReverseBearishDivergence=iCustom(NULL,tf,"OSMA_Divergence_V2_2.01",separator1,8,32,signal,separator2,drawDivergenceLines,1,2);

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      Update(tf);

      if((ClassicalBullishDivergence>0 && ReverseBullishDivergence>0) && cmd==OP_BUY)
         return true;
      else if((ClassicalBearishDivergence<0 && ReverseBearishDivergence<0) && cmd==OP_SELL)
         return true;

      return false;

     }
  };
//+------------------------------------------------------------------+
