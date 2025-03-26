#include <napi.h>
#include <windows.h>

Napi::Value GetCursorShape(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    
    CURSORINFO ci = { sizeof(CURSORINFO) };
    if (!GetCursorInfo(&ci) || ci.flags != CURSOR_SHOWING) {
        return Napi::String::New(env, "default");
    }
    
    HCURSOR cursor = ci.hCursor;

    // Match the cursor and return the corresponding name
    if (cursor == LoadCursor(NULL, IDC_ARROW)) return Napi::String::New(env, "default");
    if (cursor == LoadCursor(NULL, IDC_IBEAM)) return Napi::String::New(env, "text");
    if (cursor == LoadCursor(NULL, IDC_WAIT)) return Napi::String::New(env, "wait");
    if (cursor == LoadCursor(NULL, IDC_CROSS)) return Napi::String::New(env, "crosshair");
    if (cursor == LoadCursor(NULL, IDC_UPARROW)) return Napi::String::New(env, "default");
    if (cursor == LoadCursor(NULL, IDC_SIZE)) return Napi::String::New(env, "default");
    if (cursor == LoadCursor(NULL, IDC_ICON)) return Napi::String::New(env, "default");
    if (cursor == LoadCursor(NULL, IDC_SIZENWSE)) return Napi::String::New(env, "nwse-resize");
    if (cursor == LoadCursor(NULL, IDC_SIZENESW)) return Napi::String::New(env, "nesw-resize");
    if (cursor == LoadCursor(NULL, IDC_SIZEWE)) return Napi::String::New(env, "ew-resize");
    if (cursor == LoadCursor(NULL, IDC_SIZENS)) return Napi::String::New(env, "ns-resize");
    if (cursor == LoadCursor(NULL, IDC_SIZEALL)) return Napi::String::New(env, "move");
    if (cursor == LoadCursor(NULL, IDC_NO)) return Napi::String::New(env, "not-allowed");
    if (cursor == LoadCursor(NULL, IDC_HAND)) return Napi::String::New(env, "pointer");
    if (cursor == LoadCursor(NULL, IDC_APPSTARTING)) return Napi::String::New(env, "progress");
    if (cursor == LoadCursor(NULL, IDC_HELP)) return Napi::String::New(env, "help");

    return Napi::String::New(env, "default");
}

// New cleanup function
Napi::Value Cleanup(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    // Currently no resources to clean up, so just return true
    // You can add cleanup logic here if needed in the future
    return Napi::Boolean::New(env, true);
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
    exports.Set("getCursorShape", Napi::Function::New(env, GetCursorShape));
    exports.Set("cleanup", Napi::Function::New(env, Cleanup));
    return exports; 
}

NODE_API_MODULE(cursor, Init)