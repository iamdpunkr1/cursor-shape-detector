#include <node_api.h>
#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonCrypto.h>

// Global cache to store reference cursor hashes
typedef struct {
    NSString *handHash;
    NSString *resizeUpDownHash;
    NSString *operationNotAllowedHash;
    NSString *iBeamHash1;
    NSString *iBeamHash2;
    NSString *resizeLeftRightHash;
    NSString *crosshairHash;
    NSString *arrowHash;
    NSString *resizeUpHash;
    NSString *resizeDownHash;
    NSString *disappearingItemHash;
    NSString *contextualMenuHash;
    NSString *dragCopyHash;
    NSString *dragLinkHash;
    NSString *openHandHash;
    NSString *closeHandHash;
    NSString *moveHash;
    NSString *progressHash;
} ReferenceHashes;

static ReferenceHashes *gReferenceHashes = NULL;

// Helper function to generate SHA-256 hash from NSData
NSString* getSha256Hash(NSData* data) {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
    
    NSMutableString *hashString = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02x", hash[i]];
    }
    
    return [hashString copy];
}

// Initialize the reference cursor hashes once
void initReferenceHashes() {
    if (gReferenceHashes != NULL) return;
    
    @autoreleasepool {
        gReferenceHashes = (ReferenceHashes*)malloc(sizeof(ReferenceHashes));
        
        gReferenceHashes->handHash = [getSha256Hash([[NSCursor pointingHandCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->resizeUpDownHash = [getSha256Hash([[NSCursor resizeUpDownCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->operationNotAllowedHash = [getSha256Hash([[NSCursor operationNotAllowedCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->iBeamHash1 = [@"492dca0bb6751a30607ac728803af992ba69365052b7df2dff1c0dfe463e653c" retain];
        gReferenceHashes->iBeamHash2 = [@"eacff49396993c212e99bc954b69846c85e1a72bd10a7a0e04992030d09047ce" retain];
        gReferenceHashes->resizeLeftRightHash = [getSha256Hash([[NSCursor resizeLeftRightCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->crosshairHash = [getSha256Hash([[NSCursor crosshairCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->arrowHash = [getSha256Hash([[NSCursor arrowCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->resizeUpHash = [getSha256Hash([[NSCursor resizeUpCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->resizeDownHash = [getSha256Hash([[NSCursor resizeDownCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->disappearingItemHash = [getSha256Hash([[NSCursor disappearingItemCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->contextualMenuHash = [getSha256Hash([[NSCursor contextualMenuCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->dragCopyHash = [getSha256Hash([[NSCursor dragCopyCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->dragLinkHash = [getSha256Hash([[NSCursor dragLinkCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->openHandHash = [getSha256Hash([[NSCursor openHandCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->closeHandHash = [getSha256Hash([[NSCursor closedHandCursor].image TIFFRepresentation]) retain];
        gReferenceHashes->moveHash = [@"8c9e96e288ec201059e47ec4b7d4a39ead821f68ff031294dae946b2bf918974" retain];
        gReferenceHashes->progressHash = [@"fddb3203aaaf89827f81fe9ea7eae1744df6b91cdc3f10ac3109be2d132ee617" retain];
    }
}

// Clean up the reference hashes on module unload
void cleanupReferenceHashes() {
    if (gReferenceHashes == NULL) return;
    
    [gReferenceHashes->handHash release];
    [gReferenceHashes->resizeUpDownHash release];
    [gReferenceHashes->operationNotAllowedHash release];
    [gReferenceHashes->iBeamHash1 release];
    [gReferenceHashes->iBeamHash2 release];
    [gReferenceHashes->resizeLeftRightHash release];
    [gReferenceHashes->crosshairHash release];
    [gReferenceHashes->arrowHash release];
    [gReferenceHashes->resizeUpHash release];
    [gReferenceHashes->resizeDownHash release];
    [gReferenceHashes->disappearingItemHash release];
    [gReferenceHashes->contextualMenuHash release];
    [gReferenceHashes->dragCopyHash release];
    [gReferenceHashes->dragLinkHash release];
    [gReferenceHashes->openHandHash release];
    [gReferenceHashes->closeHandHash release];
    [gReferenceHashes->moveHash release];
    [gReferenceHashes->progressHash release];
    
    free(gReferenceHashes);
    gReferenceHashes = NULL;
}

napi_value GetCursorShape(napi_env env, napi_callback_info info) {
    @autoreleasepool {
        if (gReferenceHashes == NULL) {
            initReferenceHashes();
        }
        
        NSCursor *currentCursor = [NSCursor currentSystemCursor];
        NSString *cursorType = @"arrow";
        
        // Get cursor properties
        NSPoint hotSpot = currentCursor.hotSpot;
        NSSize size = currentCursor.image.size;
        
        // Only compute hash if we need it for identification
        NSString *hash = nil;
        
        // First try to identify by size and hotspot coordinates (faster)
        if (hotSpot.x == 9 && hotSpot.y == 9 && size.width == 20 && size.height == 20) {
            // Might be move cursor, compute hash
            if (hash == nil) hash = getSha256Hash([currentCursor.image TIFFRepresentation]);
            if ([gReferenceHashes->moveHash isEqualToString:hash]) {
                cursorType = @"move";
            }
        } else if (size.width == 28 && size.height == 40 && hotSpot.x == 5 && hotSpot.y == 5) {
            // Might be progress cursor, compute hash
            if (hash == nil) hash = getSha256Hash([currentCursor.image TIFFRepresentation]);
            if ([gReferenceHashes->progressHash isEqualToString:hash]) {
                cursorType = @"progress";
            }
        } else {
            // For other cursors, compute hash and compare
            if (hash == nil) hash = getSha256Hash([currentCursor.image TIFFRepresentation]);
            
            // Match cursor types using hash comparison
            if ([gReferenceHashes->handHash isEqualToString:hash]) {
                cursorType = @"hand";
            } else if ([gReferenceHashes->resizeUpDownHash isEqualToString:hash]) {
                cursorType = @"resize-row";
            } else if ([gReferenceHashes->operationNotAllowedHash isEqualToString:hash]) {
                cursorType = @"not-allowed";
            } else if ([gReferenceHashes->iBeamHash1 isEqualToString:hash] || [gReferenceHashes->iBeamHash2 isEqualToString:hash]) {
                cursorType = @"ibeam";
            } else if ([gReferenceHashes->resizeLeftRightHash isEqualToString:hash]) {
                cursorType = @"resize-col";
            } else if ([gReferenceHashes->crosshairHash isEqualToString:hash]) {
                cursorType = @"crosshair";
            } else if ([gReferenceHashes->arrowHash isEqualToString:hash]) {
                cursorType = @"default";
            } else if ([gReferenceHashes->resizeUpHash isEqualToString:hash]) {
                cursorType = @"resize-up";
            } else if ([gReferenceHashes->resizeDownHash isEqualToString:hash]) {
                cursorType = @"resize-down";
            } else if ([gReferenceHashes->disappearingItemHash isEqualToString:hash]) {
                cursorType = @"disappearing-item";
            } else if ([gReferenceHashes->contextualMenuHash isEqualToString:hash]) {
                cursorType = @"context-menu";
            } else if ([gReferenceHashes->dragCopyHash isEqualToString:hash]) {
                cursorType = @"copy";
            } else if ([gReferenceHashes->dragLinkHash isEqualToString:hash]) {
                cursorType = @"alias";
            } else if ([gReferenceHashes->openHandHash isEqualToString:hash]) {
                cursorType = @"grab";
            } else if ([gReferenceHashes->closeHandHash isEqualToString:hash]) {
                cursorType = @"grabbing";
            }
        }
        
        napi_value result;
        napi_create_string_utf8(env, [cursorType UTF8String], NAPI_AUTO_LENGTH, &result);
        return result;
    }
}

// Module cleanup hook
static napi_value ModuleCleanup(napi_env env, napi_callback_info info) {
    cleanupReferenceHashes();
    return NULL;
}

napi_value Init(napi_env env, napi_value exports) {
    // Initialize reference hashes on module load
    initReferenceHashes();
    
    // Create and export getCursorType function
    napi_value fn;
    napi_create_function(env, nullptr, 0, GetCursorShape, nullptr, &fn);
    napi_set_named_property(env, exports, "getCursorShape", fn);
    
    // Register cleanup function
    napi_value cleanup_fn;
    napi_create_function(env, "cleanup", NAPI_AUTO_LENGTH, ModuleCleanup, nullptr, &cleanup_fn);
    napi_set_named_property(env, exports, "cleanup", cleanup_fn);
    
    return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)