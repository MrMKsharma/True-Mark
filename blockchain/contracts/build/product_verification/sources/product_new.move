module product_verification::product_new {
    use std::string;
    use std::signer;
    use std::vector;

    // Error codes
    const E_PRODUCT_NOT_FOUND: u64 = 1;

    struct Product has store {
        name: string::String,
        manufacturer: string::String,
        is_authentic: bool,
    }

    struct ProductStore has key {
        products: vector<Product>
    }

    // Initialize the product store
    public entry fun initialize(account: &signer) {
        let account_addr = signer::address_of(account);
        if (!exists<ProductStore>(account_addr)) {
            move_to(account, ProductStore {
                products: vector::empty()
            });
        }
    }

    // Add a new product
    public entry fun add_product(
        account: &signer,
        name: vector<u8>,
        manufacturer: vector<u8>
    ) acquires ProductStore {
        let account_addr = signer::address_of(account);
        
        // Initialize if not exists
        if (!exists<ProductStore>(account_addr)) {
            initialize(account);
        };

        let store = borrow_global_mut<ProductStore>(account_addr);
        
        let product = Product {
            name: string::utf8(name),
            manufacturer: string::utf8(manufacturer),
            is_authentic: true,
        };

        vector::push_back(&mut store.products, product);
    }

    // Get product by index
    #[view]
    public fun get_product(
        account_addr: address,
        product_id: u64
    ): (string::String, string::String, bool) acquires ProductStore {
        let store = borrow_global<ProductStore>(account_addr);
        assert!(product_id < vector::length(&store.products), E_PRODUCT_NOT_FOUND);
        
        let product = vector::borrow(&store.products, product_id);
        (
            *&product.name,
            *&product.manufacturer,
            product.is_authentic
        )
    }

    // Get total number of products
    #[view]
    public fun get_product_count(account_addr: address): u64 acquires ProductStore {
        if (!exists<ProductStore>(account_addr)) {
            return 0
        };
        let store = borrow_global<ProductStore>(account_addr);
        vector::length(&store.products)
    }
}
