# Online shop in TLA+ and PlusCal

This specification is a project in TLA+ toolbox.

## Model

Model is based on 4 constants:
```
Products  <- {0, 1, 2}        \* Set of ids of different products
MaxPrice  <- 2                \* Max price of a product
Customers <- {"Alice", "Bob"} \* Set of customers
MaxMoney  <- 5                \* Man money in account of any customer
```

And 2 invariants:
```
RevenueEqualsBoughtInvariant
LawOfMoneyPreservation 
```

The constants may seems small (e.g. money at accounts) but it is necessary since the model checks all the possible options of pricing and account states.
The way I do it is explained in the module.

## Module

Core of the way module works is the way it assigns prices to products and customer account states.

These declarations (of TLA+ functions - nothing to do with common language functions, more of key-value pair set definition) define sets of all possible pricing for a product and all possible account states of all customers from a model.
```
ProductPrices == [Products -> 1..MaxPrice]
Accounts == [Customers -> 1..MaxMoney]
```

### Algorithm

The algorithm has few "global" variables it uses to represent the global state of the shop.
Then there is a process `CustomerVisitShop` for each customer that deals with all possible combinations of products a customer can be interested in buying.

A customer then tries to buy all of these items and may fail if others buy them or the customer does not have enough money.

A customer has to first reserve the product -> analogy of putting it in a basket and that disallows other customers to buy that product.
If the customer fails to pay for the product it has to release the reservation so that others can buy it.

Finally, there are a few asserts that verify that the model is intact.


## TODO

This specification does not cover mobile phone authentification, but it would be simply added to the TryBuy label and failed in case it does not go though.
I've omitted this because I am not very proficient at PlusCal and adding it inline would hurt readability badly.

## Impressions

Language seems powerful and the IDE - TLA+ Toolbox worked fine most of the time which was welcome.
On the other hand I can not imagine very usable practical use-case since most of the time it felt like I wanted to only write it so that the verification passes.

On the other hand, once it was written and I was thinking of new invariants to add I really enjoyed cooperating with the ErrorTrace since it displayed the series of all the steps to the Error nicely and that was pretty exciting.
I see good potential in verifications of invariants and the creation of new invariants and assertions.
