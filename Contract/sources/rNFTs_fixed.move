module rnfts::main {

use std::string::{Self, String};
use sui::bcs;
use sui::hex;
use sui::random::{Self, Random, RandomGenerator};
use sui::display;
use sui::package;
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
use std::{debug};
use std::vector;

// ======== Constants ========

const VERSION: u64 = 1;

// Grid size
const GRID_32X32: u64 = 1024; // 32x32

// Error codes
const EINVALID_GRID_SIZE: u64 = 1;
const ENOT_OWNER: u64 = 3;
const EUNAUTHORIZED: u64 = 4;
const EEMPTY_COLOR_VECTOR: u64 = 5;
const EINVALID_RANDOM_INDEX: u64 = 6;
const ECOUNT_OVERFLOW: u64 = 7;

// Maximum value for u64
const MAX_U64: u64 = 18446744073709551615;

// Base64 encoding
const KEYS: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

// ======== Core Structs ========

public struct WalletArt has key {
    id: UID,
    number: u64,
    size: u64,
    data_url: String,
    owner: address,
    version: u64,
    soulbound: bool,
}

public struct WalletArtRegistry has key {
    id: UID,
    count: u64
}

public struct MAIN has drop {}

// ======== Module Initialization ========
fun init(witness: MAIN, ctx: &mut TxContext) {
    let publisher = package::claim(witness, ctx);

    // Initialize display
    let mut display = display::new<WalletArt>(&publisher, ctx);
    display::add(&mut display, b"name".to_string(), b"rNFT #{number}".to_string());
    display::add(&mut display, b"description".to_string(), b"A regenerative {size}-pixel NFT, compiled from color codes within your Sui wallet address.".to_string());
    display::add(&mut display, b"number".to_string(), b"{number}".to_string());
    display::add(&mut display, b"image_url".to_string(), b"{data_url}".to_string());
    display::update_version(&mut display);

    // Initialize registry
    let registry = WalletArtRegistry {
        id: object::new(ctx),
        count: 0
    };

    // Transfer capabilities
    transfer::public_transfer(publisher, tx_context::sender(ctx));
    transfer::public_transfer(display, tx_context::sender(ctx));

    // Share registry
    transfer::share_object(registry);
}

// ======== Core Functions ========
/**
* Public entry point for users to create a new NFT - FREE MINT VERSION
* @param registry - The registry object
* @param random - The random object (0x8)
* @param ctx - Transaction context
*/
public entry fun new(
    registry: &mut WalletArtRegistry,
    random: &Random,
    ctx: &mut TxContext
) {
    // Debug: entered function
    debug::print(&b"Entered new() function.");

    assert!(registry.count < MAX_U64, ECOUNT_OVERFLOW);
    debug::print(&b"Current registry count: ");
    debug::print(&registry.count.to_string());

    // Generate NFT
    let mut rg = random.new_generator(ctx);
    debug::print(&b"Random generator created.");

    let sender_address = tx_context::sender(ctx);
    debug::print(&b"Sender address (raw): ");
    debug::print(&hex::encode(bcs::to_bytes(&sender_address)));

    let colors = generate_colors_from_address(sender_address);
    debug::print(&b"Number of colors generated: ");
    debug::print(&vector::length(&colors).to_string());

    let mut data_url = b"data:image/svg+xml;base64,".to_string();

    // Always use 32x32 grid size
    let grid_size = GRID_32X32;
    debug::print(&b"Generating SVG for 32x32 grid");
    let svg = generate_svg_8(&colors, &mut rg, grid_size);
    data_url.append(encode_8(svg));
    debug::print(&b"SVG generated and encoded.");

    let nft = WalletArt {
        id: object::new(ctx),
        number: registry.count + 1,
        size: grid_size,
        data_url,
        owner: sender_address,
        version: VERSION,
        soulbound: true,
    };
    debug::print(&b"NFT created with number: ");
    debug::print(&(registry.count + 1).to_string());

    registry.count = registry.count + 1;
    debug::print(&b"Registry count updated to: ");
    debug::print(&registry.count.to_string());

    transfer::transfer(nft, sender_address);
    debug::print(&b"NFT transferred to the sender.");
}

// ======== View Functions ========

public fun get_registry_count(registry: &WalletArtRegistry): u64 {
    registry.count
}

public fun get_nft_size(nft: &WalletArt): u64 {
    nft.size
}

public fun get_nft_owner(nft: &WalletArt): address {
    nft.owner
}

public fun get_nft_number(nft: &WalletArt): u64 {
    nft.number
}

public fun get_nft_data_url(nft: &WalletArt): &String {
    &nft.data_url
}

// ===== Helper Functions =====
/**
* Encodes a byte vector into a base64 string
* Used for encoding SVG data
* @param bytes - the bytes to encode
* @return String - The base64 encoded string
*/
fun encode_8(mut bytes: vector<u8>): String {
    let keys = &KEYS;
    let mut res = vector[];
    vector::reverse(&mut bytes);

    while (vector::length(&bytes) > 0) {
        let b1 = vector::pop_back(&mut bytes);
        let b2 = if (vector::length(&bytes) > 0) vector::pop_back(&mut bytes) else 0;
        let b3 = if (vector::length(&bytes) > 0) vector::pop_back(&mut bytes) else 0;

        let c1 = b1 >> 2;
        let c2 = ((b1 & 3) << 4) | (b2 >> 4);
        let c3 = if (b2 == 0) 64 else ((b2 & 15) << 2) | (b3 >> 6);
        let c4 = if (b3 == 0) 64 else b3 & 63;

        vector::append(&mut res, vector[
            *vector::borrow(keys, c1 as u64),
            *vector::borrow(keys, c2 as u64),
            *vector::borrow(keys, c3 as u64),
            *vector::borrow(keys, c4 as u64)
        ]);
    };

    string::utf8(res)
}

/**
* Generates an SVG image for grid sizes up to 512 pixels
* Creates a pixel art pattern using the provided colors
* @param colors - Vector of color strings in hex format
* @param rg - Random number generator for pattern creation
* @param grid_size - The size of the grid (must be a perfect square)
* @return vector<u8> - The generated SVG as bytes
*/
fun generate_svg_8(colors: &vector<String>, rg: &mut RandomGenerator, grid_size: u64): vector<u8> {
    let mut svg = vector::empty<u8>();
    let gs = u64::sqrt(grid_size);

    vector::append(&mut svg, b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ");
    vector::append(&mut svg, *string::as_bytes(&gs.to_string()));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&gs.to_string()));
    vector::append(&mut svg, b"' style='width: 100vw; height: 100vh; image-rendering: pixelated; shape-rendering: crispEdges;' preserveAspectRatio='xMidYMid meet'>");

    vector::append(&mut svg, b"<style>rect { width: 1px; height: 1px; }</style>");

    let mut y = 0;
    while (y < gs) {
        vector::append(&mut svg, b"<g transform='translate(0, ");
        vector::append(&mut svg, *string::as_bytes(&y.to_string()));
        vector::append(&mut svg, b")'>");

        let mut x = 0;
        while (x < gs) {
            let color = select_random_element(rg, colors);

            vector::append(&mut svg, b"<rect x='");
            vector::append(&mut svg, *string::as_bytes(&x.to_string()));
            vector::append(&mut svg, b"' fill='");
            vector::append(&mut svg, *string::as_bytes(color));
            vector::append(&mut svg, b"'/>");

            x = x + 1;
        };

        vector::append(&mut svg, b"</g>");
        y = y + 1;
    };

    vector::append(&mut svg, b"</svg>");
    svg
}

/**
* Randomly selects a color from the provided color vector
* @param random - Random number generator
* @param colors - Vector of available colors
* @return &String - Reference to the selected color
*/
fun select_random_element(random: &mut RandomGenerator, colors: &vector<String>): &String {
    let length = vector::length(colors);

    assert!(length > 0, EEMPTY_COLOR_VECTOR);

    let random_index = random::generate_u64_in_range(random, 0, length - 1);

    if (random_index >= length) {
        debug::print(&random_index);
    };

    assert!(random_index < length, EINVALID_RANDOM_INDEX);

    vector::borrow(colors, random_index)
}

/**
* Generates a vector of colors based on the user's wallet address
* @param addr - User's wallet address
* @return vector<String> - Vector of color strings in hex format
*/
fun generate_colors_from_address(addr: address): vector<String> {
    let mut colors = vector::empty<String>();
    let addr_bytes = bcs::to_bytes(&addr);
    let addr_hex = hex::encode(addr_bytes);
    
    // Debug the address hex
    debug::print(&b"Address hex: ");
    debug::print(&addr_hex);
    
    let addr_len = string::length(&addr_hex);
    let mut i = 0;
    
    // Generate colors by taking 6 characters at a time from the address
    while (i + 6 <= addr_len) {
        let mut color = b"#".to_string();
        let hex_segment = string::sub_string(&addr_hex, i, i + 6);
        color.append(hex_segment);
        vector::push_back(&mut colors, color);
        i = i + 6;
    };
    
    // If we have less than 3 colors, add some defaults
    if (vector::length(&colors) < 3) {
        vector::push_back(&mut colors, b"#FF5733".to_string());
        vector::push_back(&mut colors, b"#33FF57".to_string());
        vector::push_back(&mut colors, b"#3357FF".to_string());
    };
    
    colors
}

}
