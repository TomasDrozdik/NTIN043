----------------------------- MODULE OnlineShop -----------------------------
EXTENDS
    Naturals,
    Integers,
    Sequences,
    TLC,
    FiniteSets

CONSTANTS
    Customers,
    Products,
    MaxPrice,
    MaxMoney
    
ASSUME
    Cardinality(Customers) > 0 /\
    Cardinality(Products) >= 0 /\
    MaxPrice > 0 /\
    MaxMoney > 0
    
RECURSIVE SeqFromSet(_)
SeqFromSet(S) == 
  IF S = {} THEN << >> 
  ELSE LET x == CHOOSE x \in S : TRUE
       IN  << x >> \o SeqFromSet(S \ {x})

RECURSIVE SumMappedValues(_, _)
SumMappedValues(map, values) ==
    IF values = {} THEN 0
    ELSE LET x == CHOOSE x \in values : TRUE
         IN map[x] + SumMappedValues(map, values \ {x}) 

ProductPrices == [Products -> 1..MaxPrice]

Accounts == [Customers -> 1..MaxMoney]
    
(* --algorithm OnlineShop
    variables
        accounts \in Accounts,      \* customer -> balance
        products \in ProductPrices, \* product -> price
        reservations = {},          \* reserved products
        bought = {},                \* bought products
        revenue = 0,                \* revenue from products
        \* Helpers for invariants
        total_money = revenue + SumMappedValues(accounts, Customers);
        
    process CustomerVisitShop \in Customers
    variables
        products_to_buy_set \in SUBSET DOMAIN products,
        \* I need to iterate these products_to_buy, there is with clause but
        \* that does not support nested labels, thus I'll convert this set to seq. 
        products_to_buy = SeqFromSet(products_to_buy_set),
        product = 0;
        products_to_buy_idx = 1,
        products_bought = {};
        
    begin
    PickProductLoop:
        while products_to_buy_idx <= Len(products_to_buy) do
            product := products_to_buy[products_to_buy_idx];
    AwaitAvailable:
            await product \notin reservations \/ product \in bought;
            reservations := reservations \union {product};
            if product \in bought then
                goto ReleaseReservationPickNext;
            end if;
    TryBuy:
            if products[product] (* product price *) <= accounts[self] then
                accounts[self] := accounts[self] - products[product];
                revenue := revenue + products[product];
                bought := bought \union {product}; \* global
                products_bought := products_bought \union {product}; \* local
                reservations := reservations \ {product};
            end if;
    ReleaseReservationPickNext:
            reservations := reservations \ {product};
            products_to_buy_idx := products_to_buy_idx + 1;
        end while;
    FinalAsserts:
        \* Assert that you only bought the products you wanted to buy.
        assert products_bought \subseteq products_to_buy_set;
        
        \* Assert that the products you bought are not reserved anymore.
        \* Does not hold since another person can try to reserve it but
        \* immediately fails since it it already bought, I couldn't move
        \* the reservations below the condition because that would move it to another Label and that would break atomicity
        \* assert products_bought \intersect reservations = {};
        
        \* Assert that the products customer wanted to buy but didn't were
        \* bought by someone else else you didn't have enough money.
        assert {x \in products_to_buy_set \ products_bought : accounts[self] >= products[x]} \subseteq bought;
    end process;
    
    \* End -> after all processes finish -> assert reserved = {}
end algorithm *)
\* BEGIN TRANSLATION (chksum(pcal) = "2237bbbb" /\ chksum(tla) = "8efc3ec7")
VARIABLES accounts, products, reservations, bought, revenue, total_money, pc, 
          products_to_buy_set, products_to_buy, product, products_to_buy_idx, 
          products_bought

vars == << accounts, products, reservations, bought, revenue, total_money, pc, 
           products_to_buy_set, products_to_buy, product, products_to_buy_idx, 
           products_bought >>

ProcSet == (Customers)

Init == (* Global variables *)
        /\ accounts \in Accounts
        /\ products \in ProductPrices
        /\ reservations = {}
        /\ bought = {}
        /\ revenue = 0
        /\ total_money = revenue + SumMappedValues(accounts, Customers)
        (* Process CustomerVisitShop *)
        /\ products_to_buy_set \in [Customers -> SUBSET DOMAIN products]
        /\ products_to_buy = [self \in Customers |-> SeqFromSet(products_to_buy_set[self])]
        /\ product = [self \in Customers |-> 0]
        /\ products_to_buy_idx = [self \in Customers |-> 1]
        /\ products_bought = [self \in Customers |-> {}]
        /\ pc = [self \in ProcSet |-> "PickProductLoop"]

PickProductLoop(self) == /\ pc[self] = "PickProductLoop"
                         /\ IF products_to_buy_idx[self] <= Len(products_to_buy[self])
                               THEN /\ product' = [product EXCEPT ![self] = products_to_buy[self][products_to_buy_idx[self]]]
                                    /\ pc' = [pc EXCEPT ![self] = "AwaitAvailable"]
                               ELSE /\ pc' = [pc EXCEPT ![self] = "FinalAsserts"]
                                    /\ UNCHANGED product
                         /\ UNCHANGED << accounts, products, reservations, 
                                         bought, revenue, total_money, 
                                         products_to_buy_set, products_to_buy, 
                                         products_to_buy_idx, products_bought >>

AwaitAvailable(self) == /\ pc[self] = "AwaitAvailable"
                        /\ product[self] \notin reservations \/ product[self] \in bought
                        /\ reservations' = (reservations \union {product[self]})
                        /\ IF product[self] \in bought
                              THEN /\ pc' = [pc EXCEPT ![self] = "ReleaseReservationPickNext"]
                              ELSE /\ pc' = [pc EXCEPT ![self] = "TryBuy"]
                        /\ UNCHANGED << accounts, products, bought, revenue, 
                                        total_money, products_to_buy_set, 
                                        products_to_buy, product, 
                                        products_to_buy_idx, products_bought >>

TryBuy(self) == /\ pc[self] = "TryBuy"
                /\ IF products[product[self]]                     <= accounts[self]
                      THEN /\ accounts' = [accounts EXCEPT ![self] = accounts[self] - products[product[self]]]
                           /\ revenue' = revenue + products[product[self]]
                           /\ bought' = (bought \union {product[self]})
                           /\ products_bought' = [products_bought EXCEPT ![self] = products_bought[self] \union {product[self]}]
                           /\ reservations' = reservations \ {product[self]}
                      ELSE /\ TRUE
                           /\ UNCHANGED << accounts, reservations, bought, 
                                           revenue, products_bought >>
                /\ pc' = [pc EXCEPT ![self] = "ReleaseReservationPickNext"]
                /\ UNCHANGED << products, total_money, products_to_buy_set, 
                                products_to_buy, product, products_to_buy_idx >>

ReleaseReservationPickNext(self) == /\ pc[self] = "ReleaseReservationPickNext"
                                    /\ reservations' = reservations \ {product[self]}
                                    /\ products_to_buy_idx' = [products_to_buy_idx EXCEPT ![self] = products_to_buy_idx[self] + 1]
                                    /\ pc' = [pc EXCEPT ![self] = "PickProductLoop"]
                                    /\ UNCHANGED << accounts, products, bought, 
                                                    revenue, total_money, 
                                                    products_to_buy_set, 
                                                    products_to_buy, product, 
                                                    products_bought >>

FinalAsserts(self) == /\ pc[self] = "FinalAsserts"
                      /\ Assert(products_bought[self] \subseteq products_to_buy_set[self], 
                                "Failure of assertion at line 81, column 9.")
                      /\ Assert({x \in products_to_buy_set[self] \ products_bought[self] : accounts[self] >= products[x]} \subseteq bought, 
                                "Failure of assertion at line 91, column 9.")
                      /\ pc' = [pc EXCEPT ![self] = "Done"]
                      /\ UNCHANGED << accounts, products, reservations, bought, 
                                      revenue, total_money, 
                                      products_to_buy_set, products_to_buy, 
                                      product, products_to_buy_idx, 
                                      products_bought >>

CustomerVisitShop(self) == PickProductLoop(self) \/ AwaitAvailable(self)
                              \/ TryBuy(self)
                              \/ ReleaseReservationPickNext(self)
                              \/ FinalAsserts(self)

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == (\E self \in Customers: CustomerVisitShop(self))
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 


\* Global Invariants

RevenueEqualsBoughtInvariant == SumMappedValues(products, bought) = revenue

LawOfMoneyPreservation == SumMappedValues(accounts, Customers) + revenue = total_money

=============================================================================
\* Modification History
\* Last modified Sun Jan 16 18:56:21 CET 2022 by drozt
\* Created Sat Jan 15 12:31:03 CET 2022 by drozt
