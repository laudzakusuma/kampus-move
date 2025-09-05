module token_marketplace::kampus_marketplace {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::balance::{Self, Balance};
    use sui::table::{Self, Table};
    use std::string::String;
    
    // === STRUCTS ===
    
    // Kampus Token
    public struct KAMPUS_TOKEN has drop {}
    
    // Item di marketplace
    public struct MarketItem has key, store {
        id: UID,
        name: String,
        description: String,
        price: u64,
        seller: address,
        available: bool,
    }
    
    // Marketplace state
    public struct Marketplace has key {
        id: UID,
        treasury_cap: TreasuryCap<KAMPUS_TOKEN>,
        items: Table<ID, MarketItem>,
        total_items: u64,
        platform_fee: u64, // Basis points (100 = 1%)
        admin: address,
    }
    
    // Transaction events
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
    
    // === INIT ===
    fun init(witness: KAMPUS_TOKEN, ctx: &mut TxContext) {
        // Create token
        let (treasury_cap, metadata) = coin::create_currency<KAMPUS_TOKEN>(
            witness,
            9,
            b"KMPTKN",
            b"Kampus Marketplace Token",
            b"Token untuk marketplace kampus",
            option::none(),
            ctx
        );
        
        // Create marketplace
        let marketplace = Marketplace {
            id: object::new(ctx),
            treasury_cap,
            items: table::new<ID, MarketItem>(ctx),
            total_items: 0,
            platform_fee: 250, // 2.5%
            admin: tx_context::sender(ctx),
        };
        
        transfer::share_object(marketplace);
        transfer::public_freeze_object(metadata);
    }
    
    // === TOKEN FUNCTIONS ===
    
    // Mint initial tokens untuk user (simplified)
    public fun mint_initial_tokens(
        marketplace: &mut Marketplace,
        amount: u64,
        ctx: &mut TxContext
    ) {
        let tokens = coin::mint(&mut marketplace.treasury_cap, amount, ctx);
        transfer::public_transfer(tokens, tx_context::sender(ctx));
    }
    
    // === MARKETPLACE FUNCTIONS ===
    
    // List item di marketplace
    public fun list_item(
        marketplace: &mut Marketplace,
        name: String,
        description: String,
        price: u64,
        ctx: &mut TxContext
    ) {
        let item_id = object::new(ctx);
        let item_id_copy = object::uid_to_inner(&item_id);
        
        let item = MarketItem {
            id: item_id,
            name,
            description,
            price,
            seller: tx_context::sender(ctx),
            available: true,
        };
        
        // Add to marketplace
        table::add(&mut marketplace.items, item_id_copy, item);
        marketplace.total_items = marketplace.total_items + 1;
        
        // Emit event
        sui::event::emit(ItemListed {
            item_id: item_id_copy,
            seller: tx_context::sender(ctx),
            price,
        });
    }
    
    // Buy item dari marketplace
    public fun buy_item(
        marketplace: &mut Marketplace,
        item_id: ID,
        payment: Coin<KAMPUS_TOKEN>,
        ctx: &mut TxContext
    ) {
        // Get item
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item = table::borrow_mut(&mut marketplace.items, item_id);
        
        // Check availability dan price
        assert!(item.available, 1);
        assert!(coin::value(&payment) >= item.price, 2);
        
        // Calculate platform fee
        let platform_fee_amount = (item.price * marketplace.platform_fee) / 10000;
        let seller_amount = item.price - platform_fee_amount;
        
        // Split payment
        let platform_fee_coin = coin::split(&mut payment, platform_fee_amount, ctx);
        let seller_payment = coin::split(&mut payment, seller_amount, ctx);
        
        // Transfer payments
        transfer::public_transfer(seller_payment, item.seller);
        transfer::public_transfer(platform_fee_coin, marketplace.admin);
        
        // Return change jika ada
        if (coin::value(&payment) > 0) {
            transfer::public_transfer(payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(payment);
        };
        
        // Mark as sold
        item.available = false;
        
        // Emit event
        sui::event::emit(ItemSold {
            item_id,
            buyer: tx_context::sender(ctx),
            seller: item.seller,
            price: item.price,
        });
    }
    
    // Update item price
    public fun update_item_price(
        marketplace: &mut Marketplace,
        item_id: ID,
        new_price: u64,
        ctx: &TxContext
    ) {
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item = table::borrow_mut(&mut marketplace.items, item_id);
        
        // Only seller can update
        assert!(item.seller == tx_context::sender(ctx), 3);
        assert!(item.available, 1);
        
        item.price = new_price;
    }
    
    // Remove item from marketplace
    public fun remove_item(
        marketplace: &mut Marketplace,
        item_id: ID,
        ctx: &TxContext
    ) {
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item = table::borrow(&marketplace.items, item_id);
        
        // Only seller can remove
        assert!(item.seller == tx_context::sender(ctx), 3);
        
        // Remove from table
        table::remove(&mut marketplace.items, item_id);
        marketplace.total_items = marketplace.total_items - 1;
    }
    
    // === VIEW FUNCTIONS ===
    
    // Get marketplace stats
    public fun get_marketplace_stats(marketplace: &Marketplace): (u64, u64, address) {
        (marketplace.total_items, marketplace.platform_fee, marketplace.admin)
    }
    
    // Check if item exists
    public fun item_exists(marketplace: &Marketplace, item_id: ID): bool {
        table::contains(&marketplace.items, item_id)
    }
    
    // Get item info (view only)
    public fun get_item_info(marketplace: &Marketplace, item_id: ID): (String, String, u64, address, bool) {
        assert!(table::contains(&marketplace.items, item_id), 0);
        let item = table::borrow(&marketplace.items, item_id);
        (item.name, item.description, item.price, item.seller, item.available)
    }
}