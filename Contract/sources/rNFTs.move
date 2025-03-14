#[allow(duplicate_alias, unused_function)]
module 0x0::main {

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
use std::u64;

// ===== Constants =====
const VERSION: u8 = 1;
// Grid sizes
const GRID_16X16: u64 = 256;
const GRID_32X32: u64 = 1024;
    
// Errors
const ECOUNT_OVERFLOW: u64 = 0;
const EEMPTY_COLOR_VECTOR: u64 = 1;
const EINVALID_RANDOM_INDEX: u64 = 2;
    
// Constants for Base64 encoding
const MAX_U64: u64 = 18446744073709551615;
const KEYS: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// ===== Core Structs =====

public struct WalletArt has key {
    id: UID,
    number: u64,
    size: u64,
    data_url: String,
    owner: address,
    version: u8,
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
* Optimized entry point for users to create a new NFT - FREE MINT VERSION
* Gas consumption reduced through streamlined operations
* @param registry - The registry object
* @param random - The random object (0x8)
* @param ctx - Transaction context
*/
#[allow(lint(public_random))]
public entry fun new(
    registry: &mut WalletArtRegistry,
    random: &Random,
    ctx: &mut TxContext
) {
    // Check for registry overflow first, before doing any expensive operations
    let count = registry.count;
    assert!(count < MAX_U64 - 1, ECOUNT_OVERFLOW);

    // Generate NFT with optimized operations
    let mut rg = random.new_generator(ctx);
    let sender_address = tx_context::sender(ctx);
    
    // Generate colors from address (optimized function)
    let colors = generate_colors_from_address(sender_address);
    
    // Create data URL with base64 encoded SVG (optimized)
    let mut data_url = b"data:image/svg+xml;base64,".to_string();
    
    // Use 16x16 grid size for reduced gas costs
    let grid_size = GRID_16X16;
    
    // Generate optimized SVG
    let svg = generate_svg_8(&colors, &mut rg, grid_size);
    data_url.append(hyper_encode(svg));

    // Create and transfer NFT in a streamlined manner
    let nft = WalletArt {
        id: object::new(ctx),
        number: count + 1,
        size: grid_size,
        data_url,
        owner: sender_address,
        version: VERSION,
        soulbound: true,
    };
    
    // Update registry count
    registry.count = count + 1;
    
    // Transfer NFT to sender
    transfer::transfer(nft, sender_address);
}

/**
* Devnet-compatible minting function that doesn't require a random object
* Uses deterministic "random" values for testing purposes only
* @param registry - The registry object
* @param ctx - Transaction context
*/
public entry fun new_devnet(
    registry: &mut WalletArtRegistry,
    ctx: &mut TxContext
) {
    // Check for registry overflow first, before doing any expensive operations
    let count = registry.count;
    assert!(count < MAX_U64 - 1, ECOUNT_OVERFLOW);

    // Get sender address
    let sender_address = tx_context::sender(ctx);
    
    // Generate colors from address (optimized function)
    let colors = generate_colors_from_address(sender_address);
    
    // Create data URL with base64 encoded SVG (optimized)
    let mut data_url = b"data:image/svg+xml;base64,".to_string();
    
    // Use 16x16 grid size for reduced gas costs
    let grid_size = GRID_16X16;
    
    // Generate SVG with deterministic pattern instead of random
    let svg = generate_svg_deterministic(&colors, grid_size);
    data_url.append(hyper_encode(svg));

    // Create and transfer NFT in a streamlined manner
    let nft = WalletArt {
        id: object::new(ctx),
        number: count + 1,
        size: grid_size,
        data_url,
        owner: sender_address,
        version: VERSION,
        soulbound: true,
    };
    
    // Update registry count
    registry.count = count + 1;
    
    // Transfer NFT to sender
    transfer::transfer(nft, sender_address);
}

/**
* Ultra-optimized devnet minting function with minimal gas consumption
* Uses 32x32 grid as requested, with other optimizations
* @param registry - The registry object
* @param ctx - Transaction context
*/
public entry fun new_devnet_minimal(
    registry: &mut WalletArtRegistry,
    ctx: &mut TxContext
) {
    // Check for registry overflow first
    let count = registry.count;
    assert!(count < MAX_U64 - 1, ECOUNT_OVERFLOW);

    // Get sender address
    let sender_address = tx_context::sender(ctx);
    
    // Generate limited colors from address (max 4)
    let colors = generate_minimal_colors(sender_address);
    
    // Create data URL with base64 encoded SVG (ultra-optimized)
    let mut data_url = b"data:image/svg+xml;base64,".to_string();
    
    // Use 32x32 grid size as requested
    let grid_size = GRID_32X32;
    
    // Generate minimal SVG
    let svg = generate_svg_minimal(&colors, grid_size);
    data_url.append(hyper_encode(svg));

    // Create and transfer NFT
    let nft = WalletArt {
        id: object::new(ctx),
        number: count + 1,
        size: grid_size,
        data_url,
        owner: sender_address,
        version: VERSION,
        soulbound: true,
    };
    
    // Update registry count
    registry.count = count + 1;
    
    // Transfer NFT to sender
    transfer::transfer(nft, sender_address);
}

/**
* Ultra-optimized minting function - rewrites the entire generation logic to minimize gas
* @param registry - The registry object
* @param ctx - Transaction context
*/
public entry fun new_ultra_optimized(
    registry: &mut WalletArtRegistry,
    ctx: &mut TxContext
) {
    // Check for registry overflow first
    let count = registry.count;
    assert!(count < MAX_U64 - 1, ECOUNT_OVERFLOW);

    // Get sender address
    let sender_address = tx_context::sender(ctx);
    
    // Generate SVG directly from address bytes without intermediate color generation
    // This removes an entire step of processing and memory allocation
    let mut data_url = b"data:image/svg+xml;base64,".to_string();
    
    // Use 16x16 grid size for better gas efficiency
    let grid_size = GRID_16X16;
    
    // Generate SVG directly from address
    let svg = ultra_optimized_svg_from_address(sender_address, grid_size);
    
    // Encode the SVG bytes to base64 in a gas-efficient manner
    data_url.append(hyper_encode(svg));

    // Create and transfer NFT
    let nft = WalletArt {
        id: object::new(ctx),
        number: count + 1,
        size: grid_size,
        data_url,
        owner: sender_address,
        version: VERSION,
        soulbound: true,
    };
    
    // Update registry count
    registry.count = count + 1;
    
    // Transfer NFT to sender
    transfer::transfer(nft, sender_address);
}

/**
* Hyper-optimized minting function with minimal gas consumption
* @param registry - The registry object
* @param ctx - Transaction context
*/
public entry fun mint_optimized(
    registry: &mut WalletArtRegistry,
    ctx: &mut TxContext
) {
    // Check for registry overflow first
    let count = registry.count;
    assert!(count < MAX_U64 - 1, ECOUNT_OVERFLOW);

    // Get sender address
    let sender_address = tx_context::sender(ctx);
    
    // Generate SVG directly from address bytes with minimal operations
    let mut data_url = b"data:image/svg+xml;base64,".to_string();
    
    // Use 16x16 grid size for better gas efficiency
    let grid_size = GRID_16X16;
    
    // Generate SVG directly from address with revolutionary algorithm
    let svg = hyper_optimized_svg(sender_address, grid_size);
    
    // Encode the SVG bytes to base64 in a hyper-efficient manner
    data_url.append(hyper_encode(svg));

    // Create and transfer NFT
    let nft = WalletArt {
        id: object::new(ctx),
        number: count + 1,
        size: grid_size,
        data_url,
        owner: sender_address,
        version: VERSION,
        soulbound: true,
    };
    
    // Update registry count
    registry.count = count + 1;
    
    // Transfer NFT to sender
    transfer::transfer(nft, sender_address);
}

/**
* Deterministic SVG generation for devnet testing
* Creates a pixel art pattern using the provided colors without requiring randomness
* @param colors - Vector of color strings in hex format
* @param grid_size - The size of the grid (must be a perfect square)
* @return vector<u8> - The generated SVG as bytes
*/
fun generate_svg_deterministic(colors: &vector<String>, grid_size: u64): vector<u8> {
    let mut svg = vector::empty<u8>();
    let gs = u64::sqrt(grid_size);
    let gs_str = gs.to_string();
    
    // Pre-compute the SVG header once
    vector::append(&mut svg, b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ");
    vector::append(&mut svg, *string::as_bytes(&gs_str));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&gs_str));
    vector::append(&mut svg, b"' style='width:100vw;height:100vh;image-rendering:pixelated'>");
    
    // Pre-compute common strings
    let rect_start = b"<rect x='";
    let y_attr = b"' y='";
    let fill_attr = b"' fill='";
    let rect_end = b"' width='1' height='1'/>";
    
    let color_count = vector::length(colors);
    
    // Generate all rectangles without grouping by row to reduce tag overhead
    let mut y = 0;
    while (y < gs) {
        let y_str = y.to_string();
        
        let mut x = 0;
        while (x < gs) {
            // Use a deterministic pattern based on coordinates
            let color_index = ((x + y) % color_count) as u64;
            let color = vector::borrow(colors, color_index);
            
            // Combine operations to reduce the number of vector appends
            vector::append(&mut svg, rect_start);
            vector::append(&mut svg, *string::as_bytes(&x.to_string()));
            vector::append(&mut svg, y_attr);
            vector::append(&mut svg, *string::as_bytes(&y_str));
            vector::append(&mut svg, fill_attr);
            vector::append(&mut svg, *string::as_bytes(color));
            vector::append(&mut svg, rect_end);
            
            x = x + 1;
        };
        
        y = y + 1;
    };
    
    vector::append(&mut svg, b"</svg>");
    svg
}

/**
* Ultra-optimized SVG generation directly from address
* Removes the need for intermediate color generation and storage
* @param addr - User's wallet address
* @param grid_size - The size of the grid
* @return vector<u8> - The generated SVG as bytes
*/
fun ultra_optimized_svg_from_address(addr: address, grid_size: u64): vector<u8> {
    // Convert address to bytes for direct use
    let addr_bytes = bcs::to_bytes(&addr);
    let addr_len = vector::length(&addr_bytes);
    
    // Calculate grid dimensions
    let side = u64::sqrt(grid_size);
    
    // Pre-compute all static strings to reduce allocations
    let svg_start = b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ";
    let svg_mid = b"' style='width:100vw;height:100vh'>";
    let rect_x = b"<rect x='";
    let rect_y = b"' y='";
    let rect_fill = b"' fill='#";
    let rect_end = b"' width='1' height='1'/>";
    let svg_end = b"</svg>";
    
    // Initialize SVG buffer with capacity estimate to avoid reallocations
    let mut svg = vector::empty<u8>();
    
    // Add SVG header
    vector::append(&mut svg, svg_start);
    vector::append(&mut svg, *string::as_bytes(&side.to_string()));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&side.to_string()));
    vector::append(&mut svg, svg_mid);
    
    // Calculate maximum colors needed (4 is enough for visual variety)
    let color_bytes_needed = 3; // 3 bytes = 6 hex chars for one color
    let max_colors = 4;
    
    // Extract color bytes directly from address
    // This is much more efficient than string operations
    let mut color_bytes = vector::empty<vector<u8>>();
    let mut i = 0;
    while (i + color_bytes_needed <= addr_len && vector::length(&color_bytes) < max_colors) {
        let mut color = vector::empty<u8>();
        let mut j = 0;
        while (j < color_bytes_needed) {
            vector::push_back(&mut color, *vector::borrow(&addr_bytes, i + j));
            j = j + 1;
        };
        vector::push_back(&mut color_bytes, color);
        i = i + color_bytes_needed;
    };
    
    // Ensure we have at least one color
    if (vector::is_empty(&color_bytes)) {
        let default_color = vector[255, 87, 51]; // #FF5733
        vector::push_back(&mut color_bytes, default_color);
    };
    
    // Number of colors we actually have
    let color_count = vector::length(&color_bytes);
    
    // Cache all y coordinate strings to avoid repeated conversions
    let mut y_strings = vector::empty<String>();
    let mut y_pos = 0;
    while (y_pos < side) {
        vector::push_back(&mut y_strings, y_pos.to_string());
        y_pos = y_pos + 1;
    };
    
    // Generate the pixel art pattern
    // Use deterministic algorithm based on coordinates and address bytes
    let mut y = 0;
    while (y < side) {
        let y_str = vector::borrow(&y_strings, y);
        
        let mut x = 0;
        while (x < side) {
            // Determine color using a fast, deterministic formula
            // XOR operation is gas-efficient and creates interesting patterns
            let color_index = ((x ^ y) + (x * y % 29)) % color_count;
            let color_vec = vector::borrow(&color_bytes, color_index);
            
            // Add rectangle element
            vector::append(&mut svg, rect_x);
            vector::append(&mut svg, *string::as_bytes(&x.to_string()));
            vector::append(&mut svg, rect_y);
            vector::append(&mut svg, *string::as_bytes(y_str));
            vector::append(&mut svg, rect_fill);
            vector::append(&mut svg, *string::as_bytes(&string::utf8(hex::encode(*color_vec))));
            vector::append(&mut svg, rect_end);
            
            x = x + 1;
        };
        
        y = y + 1;
    };
    
    // Close SVG
    vector::append(&mut svg, svg_end);
    
    svg
}

/**
* Hyper-optimized Base64 encoding function with minimal operations
* @param input - The input bytes to encode
* @return - The Base64 encoded string
*/
fun hyper_encode(input: vector<u8>): String {
    let base64_chars = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let input_len = vector::length(&input);
    
    // Pre-allocate exact capacity to avoid reallocations
    let _output_len = 4 * ((input_len + 2) / 3);
    let mut output = vector::empty<u8>();
    
    let mut i = 0;
    while (i + 3 <= input_len) {
        // Process 3 bytes at a time with bitwise operations
        let b1 = *vector::borrow(&input, i);
        let b2 = *vector::borrow(&input, i + 1);
        let b3 = *vector::borrow(&input, i + 2);
        
        // Combine bytes into a single value for faster processing
        let n = ((b1 as u64) << 16) | ((b2 as u64) << 8) | (b3 as u64);
        
        // Extract 6-bit segments using bitwise operations
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 18) & 0x3F) as u64));
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 12) & 0x3F) as u64));
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 6) & 0x3F) as u64));
        vector::push_back(&mut output, *vector::borrow(&base64_chars, (n & 0x3F) as u64));
        
        i = i + 3;
    };
    
    // Handle remaining bytes
    if (i + 2 == input_len) {
        // 2 bytes remaining
        let b1 = *vector::borrow(&input, i);
        let b2 = *vector::borrow(&input, i + 1);
        
        // Combine bytes into a single value
        let n = ((b1 as u64) << 16) | ((b2 as u64) << 8);
        
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 18) & 0x3F) as u64));
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 12) & 0x3F) as u64));
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 6) & 0x3F) as u64));
        vector::push_back(&mut output, 61u8); // '=' character (ASCII 61)
    } else if (i + 1 == input_len) {
        // 1 byte remaining
        let b1 = *vector::borrow(&input, i);
        
        // Process single byte
        let n = (b1 as u64) << 16;
        
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 18) & 0x3F) as u64));
        vector::push_back(&mut output, *vector::borrow(&base64_chars, ((n >> 12) & 0x3F) as u64));
        vector::push_back(&mut output, 61u8); // '=' character (ASCII 61)
        vector::push_back(&mut output, 61u8); // '=' character (ASCII 61)
    };
    
    string::utf8(output)
}

/**
* Revolutionary SVG generation with direct byte-to-color mapping
* @param addr - The address to generate SVG from
* @param grid_size - The size of the grid
* @return - The SVG as a vector of bytes
*/
fun hyper_optimized_svg(addr: address, grid_size: u64): vector<u8> {
    // Convert address to bytes for direct use
    let addr_bytes = bcs::to_bytes(&addr);
    let addr_len = vector::length(&addr_bytes);
    
    // Calculate grid dimensions
    let side = u64::sqrt(grid_size);
    
    // Pre-allocate SVG vector with estimated capacity
    let mut svg = vector::empty<u8>();
    
    // Add SVG header with styling to match the reference contract
    vector::append(&mut svg, b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ");
    vector::append(&mut svg, *string::as_bytes(&side.to_string()));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&side.to_string()));
    vector::append(&mut svg, b"' style='width: 100vw; height: 100vh; image-rendering: pixelated; shape-rendering: crispEdges;' preserveAspectRatio='xMidYMid meet'>");
    
    // Add style element for consistent rendering
    vector::append(&mut svg, b"<style>rect { width: 1px; height: 1px; }</style>");
    
    // Generate pixels with direct RGB calculation from bytes
    // Group by rows for better organization and potentially better compression
    let mut y = 0;
    while (y < side) {
        // Add group transform for each row
        vector::append(&mut svg, b"<g transform='translate(0, ");
        vector::append(&mut svg, *string::as_bytes(&y.to_string()));
        vector::append(&mut svg, b")'>");
        
        let mut x = 0;
        while (x < side) {
            // Calculate pixel index
            let i = y * side + x;
            
            // Get byte from address with wrapping
            let color_byte = *vector::borrow(&addr_bytes, i % addr_len);
            
            // Generate hex color from byte
            // Take 3 bytes at a time to create a full hex color
            let r = ((color_byte >> 5) & 0x07) * 36; // 3 bits -> 0-7 range * 36 = 0-252
            let g = ((color_byte >> 2) & 0x07) * 36; // 3 bits -> 0-7 range * 36 = 0-252
            let b = (color_byte & 0x03) * 85;        // 2 bits -> 0-3 range * 85 = 0-255
            
            // Convert RGB to hex color format
            let mut hex_color = b"#".to_string();
            
            // Convert RGB components to hex
            let hex_r = string::utf8(hex::encode(vector[r as u8]));
            let hex_g = string::utf8(hex::encode(vector[g as u8]));
            let hex_b = string::utf8(hex::encode(vector[b as u8]));
            
            // Ensure each component is two characters
            if (string::length(&hex_r) == 1) {
                string::append(&mut hex_color, b"0".to_string());
            };
            string::append(&mut hex_color, hex_r);
            
            if (string::length(&hex_g) == 1) {
                string::append(&mut hex_color, b"0".to_string());
            };
            string::append(&mut hex_color, hex_g);
            
            if (string::length(&hex_b) == 1) {
                string::append(&mut hex_color, b"0".to_string());
            };
            string::append(&mut hex_color, hex_b);
            
            // Add rect element with hex color
            vector::append(&mut svg, b"<rect x='");
            vector::append(&mut svg, *string::as_bytes(&x.to_string()));
            vector::append(&mut svg, b"' fill='");
            vector::append(&mut svg, *string::as_bytes(&hex_color));
            vector::append(&mut svg, b"'/>");
            
            x = x + 1;
        };
        
        // Close the row group
        vector::append(&mut svg, b"</g>");
        
        y = y + 1;
    };
    
    // Close SVG
    vector::append(&mut svg, b"</svg>");
    svg
}

/**
* Optimized SVG generation function that reduces gas consumption
* Creates a pixel art pattern using the provided colors with fewer string operations
* @param colors - Vector of color strings in hex format
* @param rg - Random number generator for pattern creation
* @param grid_size - The size of the grid (must be a perfect square)
* @return vector<u8> - The generated SVG as bytes
*/
fun generate_svg_8(colors: &vector<String>, rg: &mut RandomGenerator, grid_size: u64): vector<u8> {
    let mut svg = vector::empty<u8>();
    let gs = u64::sqrt(grid_size);
    let gs_str = gs.to_string();
    
    // Pre-compute the SVG header once
    vector::append(&mut svg, b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ");
    vector::append(&mut svg, *string::as_bytes(&gs_str));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&gs_str));
    vector::append(&mut svg, b"' style='width:100vw;height:100vh;image-rendering:pixelated'>");
    
    // Use a more efficient rect definition that doesn't require a separate style tag
    // Each rect will have its width and height defined inline
    
    // Pre-compute common strings
    let rect_start = b"<rect x='";
    let y_attr = b"' y='";
    let fill_attr = b"' fill='";
    let rect_end = b"' width='1' height='1'/>";
    
    // Generate all rectangles without grouping by row to reduce tag overhead
    let mut y = 0;
    while (y < gs) {
        let y_str = y.to_string();
        
        let mut x = 0;
        while (x < gs) {
            let color = select_random_element(rg, colors);
            
            // Combine operations to reduce the number of vector appends
            vector::append(&mut svg, rect_start);
            vector::append(&mut svg, *string::as_bytes(&x.to_string()));
            vector::append(&mut svg, y_attr);
            vector::append(&mut svg, *string::as_bytes(&y_str));
            vector::append(&mut svg, fill_attr);
            vector::append(&mut svg, *string::as_bytes(color));
            vector::append(&mut svg, rect_end);
            
            x = x + 1;
        };
        
        y = y + 1;
    };
    
    vector::append(&mut svg, b"</svg>");
    svg
}

/**
* Optimized random color selection function with reduced gas consumption
* @param random - Random number generator
* @param colors - Vector of available colors
* @return &String - Reference to the selected color
*/
fun select_random_element(random: &mut RandomGenerator, colors: &vector<String>): &String {
    let length = vector::length(colors);
    assert!(length > 0, EEMPTY_COLOR_VECTOR);
    
    // Generate random index directly without extra checks to save gas
    let random_index = if (length == 1) {
        0
    } else {
        random::generate_u64_in_range(random, 0, length - 1)
    };
    
    // The random::generate_u64_in_range function should already ensure the index is valid,
    // but we'll keep a simplified assertion for safety
    assert!(random_index < length, EINVALID_RANDOM_INDEX);
    
    vector::borrow(colors, random_index)
}

/**
* Optimized function to generate colors from wallet address with reduced gas consumption
* @param addr - User's wallet address
* @return vector<String> - Vector of color strings in hex format
*/
fun generate_colors_from_address(addr: address): vector<String> {
    let mut colors = vector::empty<String>();
    let addr_bytes = bcs::to_bytes(&addr);
    let addr_hex_bytes = hex::encode(addr_bytes);
    let addr_hex = string::utf8(addr_hex_bytes);
    
    // Debug the address hex
    debug::print(&b"Address hex: ");
    debug::print(&addr_hex);
    
    let addr_len = string::length(&addr_hex);
    let mut i = 0;
    
    // Limit the number of colors to generate (8 is more than enough for variety)
    // This reduces gas consumption by avoiding unnecessary color generation
    let max_colors = 8;
    let mut color_count = 0;
    
    // Generate colors by taking 6 characters at a time from the address
    while (i + 6 <= addr_len && color_count < max_colors) {
        let hex_segment = string::substring(&addr_hex, i, i + 6);
        let mut color = b"#".to_string();
        color.append(hex_segment);
        vector::push_back(&mut colors, color);
        i = i + 6;
        color_count = color_count + 1;
    };
    
    // If we have less than 3 colors, add some defaults
    // Pre-compute default colors to reduce string operations
    if (vector::length(&colors) < 3) {
        vector::push_back(&mut colors, b"#FF5733".to_string());
    };
    
    colors
}

/**
* Generate minimal colors (max 4) from address to reduce gas costs
* @param addr - The address to generate colors from
* @return vector<String> - Vector of color strings in hex format
*/
fun generate_minimal_colors(addr: address): vector<String> {
    let mut colors = vector::empty<String>();
    let addr_bytes = bcs::to_bytes(&addr);
    let addr_len = vector::length(&addr_bytes);
    
    // Extract just 4 colors maximum
    let max_colors = 4;
    let mut i = 0;
    let mut color_count = 0;
    
    while (i + 2 < addr_len && color_count < max_colors) {
        let mut color = string::utf8(b"#");
        
        // Use just 3 bytes (6 hex chars) for each color
        let byte1 = *vector::borrow(&addr_bytes, i);
        let byte2 = *vector::borrow(&addr_bytes, i + 1);
        let byte3 = *vector::borrow(&addr_bytes, i + 2);
        
        // Convert bytes directly to hex without string operations
        let hex = hex::encode(vector[byte1, byte2, byte3]);
        string::append(&mut color, string::utf8(hex));
        vector::push_back(&mut colors, color);
        
        i = i + 3;
        color_count = color_count + 1;
    };
    
    // Ensure we have at least one color
    if (vector::is_empty(&colors)) {
        vector::push_back(&mut colors, b"#000000".to_string());
    };
    
    colors
}

/**
* Ultra-minimal SVG generation for lowest gas consumption
* Creates a simple 8x8 pixel art with minimal SVG structure
* @param colors - Vector of color strings in hex format
* @param grid_size - The size of the grid (must be a perfect square)
* @return vector<u8> - The generated SVG as bytes
*/
fun generate_svg_minimal(colors: &vector<String>, grid_size: u64): vector<u8> {
    let mut svg = vector::empty<u8>();
    let gs = u64::sqrt(grid_size);
    
    // Minimal SVG header with no unnecessary attributes
    vector::append(&mut svg, b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ");
    vector::append(&mut svg, *string::as_bytes(&gs.to_string()));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&gs.to_string()));
    vector::append(&mut svg, b"'>");
    
    // Pre-compute common strings
    let rect_start = b"<rect x='";
    let y_attr = b"' y='";
    let fill_attr = b"' fill='";
    let rect_end = b"' width='1' height='1'/>";
    
    let color_count = vector::length(colors);
    
    // Generate a pattern with minimal complexity
    let mut y = 0;
    while (y < gs) {
        let y_str = y.to_string();
        
        let mut x = 0;
        while (x < gs) {
            // Simple pattern based on coordinates
            let pattern_value = (x ^ y) % color_count;
            let color = vector::borrow(colors, pattern_value as u64);
            
            // Combine operations to reduce vector appends
            vector::append(&mut svg, rect_start);
            vector::append(&mut svg, *string::as_bytes(&x.to_string()));
            vector::append(&mut svg, y_attr);
            vector::append(&mut svg, *string::as_bytes(&y_str));
            vector::append(&mut svg, fill_attr);
            vector::append(&mut svg, *string::as_bytes(color));
            vector::append(&mut svg, rect_end);
            
            x = x + 1;
        };
        
        y = y + 1;
    };
    
    vector::append(&mut svg, b"</svg>");
    svg
}

/**
* Generate colors directly from address bytes without hex conversion
* @param addr - The address to generate colors from
* @return - A vector of colors
*/
#[allow(unused_function, unused_variable)]
fun generate_colors_from_address_bytes(addr: address): vector<String> {
    let addr_bytes = bcs::to_bytes(&addr);
    let mut colors = vector::empty<String>();
    let mut i = 0;
    
    // Take 3 bytes at a time to create RGB colors
    while (i + 3 <= vector::length(&addr_bytes) && vector::length(&colors) < 4) {
        let r = *vector::borrow(&addr_bytes, i);
        let g = *vector::borrow(&addr_bytes, i + 1);
        let b = *vector::borrow(&addr_bytes, i + 2);
        
        // Format color as hex
        let mut color = vector::empty<u8>();
        vector::push_back(&mut color, 35u8); // '#' character (ASCII 35)
        
        // Convert each byte to hex and append
        let hex_chars = b"0123456789abcdef";
        
        vector::push_back(&mut color, *vector::borrow(&hex_chars, ((r >> 4) as u64)));
        vector::push_back(&mut color, *vector::borrow(&hex_chars, ((r & 0xF) as u64)));
        vector::push_back(&mut color, *vector::borrow(&hex_chars, ((g >> 4) as u64)));
        vector::push_back(&mut color, *vector::borrow(&hex_chars, ((g & 0xF) as u64)));
        vector::push_back(&mut color, *vector::borrow(&hex_chars, ((b >> 4) as u64)));
        vector::push_back(&mut color, *vector::borrow(&hex_chars, ((b & 0xF) as u64)));
        
        vector::push_back(&mut colors, string::utf8(color));
        i = i + 3;
    };
    
    // Fallback to default colors if needed
    if (vector::is_empty(&colors)) {
        vector::push_back(&mut colors, string::utf8(b"#FF5733"));
    };
    
    colors
}

/**
* Generate an optimized SVG using path elements instead of individual rects
* @param colors - The colors to use for the SVG
* @param grid_size - The size of the grid
* @return - The SVG as a vector of bytes
*/
#[allow(unused_function)]
fun generate_optimized_svg(colors: &vector<String>, grid_size: u64): vector<u8> {
    let side = u64::sqrt(grid_size);
    let color_count = vector::length(colors);
    
    // Start SVG with header
    let mut svg = vector::empty<u8>();
    vector::append(&mut svg, b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 ");
    vector::append(&mut svg, *string::as_bytes(&side.to_string()));
    vector::append(&mut svg, b" ");
    vector::append(&mut svg, *string::as_bytes(&side.to_string()));
    vector::append(&mut svg, b"'>");
    
    // Create paths for each color to reduce the number of elements
    let mut color_index = 0;
    while (color_index < color_count) {
        let color = vector::borrow(colors, color_index);
        
        // Start path element
        vector::append(&mut svg, b"<path fill='");
        vector::append(&mut svg, *string::as_bytes(color));
        vector::append(&mut svg, b"' d='");
        
        // Add path data for this color
        let mut y = 0;
        while (y < side) {
            let mut x = 0;
            while (x < side) {
                // Only add pixels that match this color
                let pixel_color_index = ((x * 31) + (y * 17)) % color_count;
                if (pixel_color_index == color_index) {
                    vector::append(&mut svg, b"M");
                    vector::append(&mut svg, *string::as_bytes(&x.to_string()));
                    vector::append(&mut svg, b",");
                    vector::append(&mut svg, *string::as_bytes(&y.to_string()));
                    vector::append(&mut svg, b"h1v1h-1z");
                };
                x = x + 1;
            };
            y = y + 1;
        };
        
        // Close path element
        vector::append(&mut svg, b"'/>");
        color_index = color_index + 1;
    };
    
    // Close SVG
    vector::append(&mut svg, b"</svg>");
    svg
}

/**
* Base64 encoding function for SVG data URIs (unused but kept for reference)
*/
#[allow(unused_function)]
#[allow(implicit_const_copy)]
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

// ======== Test Functions ========
#[test_only]
/// Initialize the module for testing
public fun test_init(ctx: &mut TxContext) {
    init(MAIN {}, ctx)
}

#[test_only]
/// Set the registry count for testing purposes
public fun test_set_registry_count(registry: &mut WalletArtRegistry, count: u64) {
    registry.count = count;
}

#[test_only]
/// Test function to check for registry overflow without expensive operations
public fun test_check_registry_overflow(registry: &WalletArtRegistry) {
    assert!(registry.count < MAX_U64 - 1, ECOUNT_OVERFLOW);
}
}