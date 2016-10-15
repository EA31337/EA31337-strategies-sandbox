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

extern int    H_level            = 70;
extern int    L_level            = 30;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   int               SignalOrderBuy,SignalOrderSell;

   void Update(int tf=PERIOD_M1,int cmd=NULL)
     {

      SignalOrderBuy=0;
      SignalOrderSell=0;

      if(cmd==OP_SELL) 
        {

         if(iRSI(NULL,Period(),14,PRICE_CLOSE,0)>H_level)
            SignalOrderSell++;;

         if(iMACD(Symbol(),Period(),14,26,9,PRICE_CLOSE,MODE_MAIN,0)<iMACD(Symbol(),0,14,26,9,PRICE_CLOSE,MODE_MAIN,1))
            SignalOrderSell++;;

         if(iCustom(Symbol(),Period(),"Turbo_JRSX",14,MODE_MAIN,0)>H_level)
            SignalOrderSell++;;

         if(iCustom(Symbol(),Period(),"Turbo_JVEL",14,MODE_MAIN,0)>0.10)
            SignalOrderSell++;;

         if(iStochastic(Symbol(),Period(),5,3,9,MODE_SMA,0,MODE_MAIN,0)>H_level && iStochastic(Symbol(),0,5,3,3,MODE_SMA,0,MODE_SIGNAL,1)>H_level)
            SignalOrderSell++;;

        }
      if(cmd==OP_BUY)
        {
         if(iMACD(Symbol(),Period(),14,26,9,PRICE_CLOSE,MODE_MAIN,0)>iMACD(Symbol(),0,14,26,9,PRICE_CLOSE,MODE_MAIN,1))
            SignalOrderBuy++;;
         if(iStochastic(Symbol(),Period(),5,3,9,MODE_SMA,0,MODE_MAIN,0)<L_level && iStochastic(Symbol(),0,5,3,3,MODE_SMA,0,MODE_SIGNAL,1)<L_level)
            SignalOrderBuy++;;

         if(iRSI(NULL,Period(),14,PRICE_CLOSE,0)<L_level)
            SignalOrderBuy++;;

         if(iCustom(Symbol(),Period(),"Turbo_JRSX",14,MODE_MAIN,0)<L_level)
            SignalOrderBuy++;;

         if(iCustom(Symbol(),Period(),"Turbo_JVEL",14,MODE_MAIN,0)<-0.10)
            SignalOrderBuy++;;
        }

     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {
 

      if(SignalOrderBuy>=3 && cmd==OP_BUY)
         return true;
      else if(SignalOrderSell>=3 && cmd==OP_SELL)
                               return true;

      return false;

     }
  };
//+------------------------------------------------------------------+
