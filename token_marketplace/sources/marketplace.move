module token_marketplace::kampus_marketplace {
    // --- Imports ---
    // Cleaned up to remove redundant aliases provided by default by the compiler.
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::table::{Self, Table};
    use std::string::String;
    use sui::event;
    // Many common modules like 'transfer', 'option', 'tx_context', and 'object'
    // are automatically in scope and don't need to be imported explicitly.

    // --- Structs ---

    // One-time witness for the init function. The name must be the
    // uppercase version of the module name.
    public struct KAMPUS_MARKETPLACE has drop {}

    // Item in the marketplace.
    // 'drop' is removed because the 'UID' field doesn't have 'drop'.
    // We will handle deletion manually in the `remove_item` function.
    public struct MarketItem has key, store {
        id: UID,
        name: String,
        description: String,
        price: u64,
        seller: address,
        available: bool,
    }

    // Marketplace state object.
    public struct Marketplace has key {
        id: UID,
        treasury_cap: TreasuryCap<KAMPUS_MARKETPLACE>,
        items: Table<ID, MarketItem>,
        total_items: u64,
        platform_fee: u64, // Basis points (e.g., 250 = 2.5%)
        admin: address,
    }

    // --- Events ---

    public struct ItemListed has copy, drop {
        item_id: ID,
        seller: address,
        price: u64,
    }

    public struct ItemSold has copy, drop {
        item_id: ID,
        buyer: address,
        seller: address,
        price: u64,
    }

    // --- Functions ---

    // The 'init' function is called once when the module is published.
    fun init(witness: KAMPUS_MARKETPLACE, ctx: &mut TxContext) {
        // Create the KAMPUS_MARKETPLACE currency.
        let (treasury_cap, metadata) = coin::create_currency<KAMPUS_MARKETPLACE>(
            witness,
            9, // Decimals
            b"KMPTKN",
            b"Kampus Marketplace Token",
            b"Token for the Kampus marketplace",
            option::none(),
            ctx
        );

        // Create the Marketplace object.
        let marketplace = Marketplace {
            id: object::new(ctx),
            treasury_cap,
            items: table::new<ID, MarketItem>(ctx),
            total_items: 0,
            platform_fee: 250, // 2.5%
            admin: tx_context::sender(ctx),
        };

        // Share the marketplace so others can interact with it.
        transfer::share_object(marketplace);
        // Freeze the metadata so it cannot be changed.
        transfer::public_freeze_object(metadata);
    }

    // Mints new tokens. Returns the Coin object to the caller.
    public fun mint_tokens(
        marketplace: &mut Marketplace,
        amount: u64,
        ctx: &mut TxContext
    ): Coin<KAMPUS_MARKETPLACE> {
        coin::mint(&mut marketplace.treasury_cap, amount, ctx)
    }

    // Lists a new item for sale.
    public fun list_item(
        marketplace: &mut Marketplace,
        name: String,
        description: String,
        price: u64,
        ctx: &mut TxContext
    ) {
        let item_uid = object::new(ctx);
        let item_id = object::uid_to_inner(&item_uid);

        let item = MarketItem {
            id: item_uid,
            name,
            description,
            price,
            seller: tx_context::sender(ctx),
            available: true,
        };

        table::add(&mut marketplace.items, item_id, item);
        marketplace.total_items = marketplace.total_items + 1;

        event::emit(ItemListed {
            item_id,
            seller: tx_context::sender(ctx),
            price,
        });
    }

    // Buys an item from the marketplace.
    // Returns the leftover Coin object (change) to make the function composable.
    public fun buy_item(
        marketplace: &mut Marketplace,
        item_id: ID,
        mut payment: Coin<KAMPUS_MARKETPLACE>,
        ctx: &mut TxContext
    ): Coin<KAMPUS_MARKETPLACE> {
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item = table::borrow_mut(&mut marketplace.items, item_id);

        assert!(item.available, 1);
        assert!(coin::value(&payment) >= item.price, 2);

        // Calculate fees
        let platform_fee_amount = (item.price * marketplace.platform_fee) / 10000;
        let seller_amount = item.price - platform_fee_amount;

        // Distribute payment
        let platform_fee_coin = coin::split(&mut payment, platform_fee_amount, ctx);
        transfer::public_transfer(platform_fee_coin, marketplace.admin);

        // The remaining value in 'payment' is now the seller's portion
        let seller_payment = coin::split(&mut payment, seller_amount, ctx);
        transfer::public_transfer(seller_payment, item.seller);

        item.available = false;

        event::emit(ItemSold {
            item_id,
            buyer: tx_context::sender(ctx),
            seller: item.seller,
            price: item.price,
        });
        payment
    }
    
    public fun remove_item(
        marketplace: &mut Marketplace,
        item_id: ID,
        ctx: &TxContext
    ) {
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item_info = table::borrow(&marketplace.items, item_id);
        assert!(item_info.seller == tx_context::sender(ctx), 3);

        let item: MarketItem = table::remove(&mut marketplace.items, item_id);
        
        let MarketItem {id, name: _, description: _, price: _, seller: _, available: _} = item;
		object::delete(id);

        marketplace.total_items = marketplace.total_items - 1;
    }

    public fun get_item_info(marketplace: &Marketplace, item_id: ID): (String, String, u64, address, bool) {
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item = table::borrow(&marketplace.items, item_id);
        (item.name, item.description, item.price, item.seller, item.available)
    }
}