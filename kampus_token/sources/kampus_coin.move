module kampus_token::kampus_coin {
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::url;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::option;
    
    // === STRUCTS ===
    
    // One Time Witness untuk inisialisasi token
    public struct KAMPUS_COIN has drop {}
    
    // === INIT FUNCTION ===
    fun init(witness: KAMPUS_COIN, ctx: &mut TxContext) {
        // Metadata token
        let (_treasury_cap, _metadata) = coin::create_currency<KAMPUS_COIN>(
            witness,
            9,                                          // Decimals
            b"KAMPUS",                                  // Symbol
            b"Kampus Token",                            // Name  
            b"Token untuk sistem kampus blockchain",    // Description
            option::some(url::new_unsafe_from_bytes(b"https://kampus.io/icon.png")), // Icon URL
            ctx
        );
        
        // Transfer treasury ke deployer untuk kontrol minting
        transfer::public_transfer(_treasury_cap, tx_context::sender(ctx));
        
        // Freeze metadata (tidak bisa diubah lagi)
        transfer::public_freeze_object(_metadata);
    }
    
    // === MINTING FUNCTIONS ===
    
    // Mint token baru (hanya pemilik treasury)
    public fun mint(
        treasury_cap: &mut TreasuryCap<KAMPUS_COIN>,
        amount: u64,
        _recipient: address,
        ctx: &mut TxContext
    ) {
        // Mint coin
        let _coin = coin::mint(treasury_cap, amount, ctx);
        
        // Transfer ke recipient
        transfer::public_transfer(_coin, _recipient);
    }
    
    // Burn token (destroy coin)
    public fun burn(treasury_cap: &mut TreasuryCap<KAMPUS_COIN>, coin: Coin<KAMPUS_COIN>) {
        coin::burn(treasury_cap, coin);
    }
}