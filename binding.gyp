{
  "targets": [{
    "target_name": "cursor",
    "sources": [ "src/cursor.cc" ],
    "include_dirs": [
      "<!@(node -p \"require('node-addon-api').include\")"
    ],
    "dependencies": [
      "<!(node -p \"require('node-addon-api').gyp\")"
    ],
    "defines": [ "NAPI_DISABLE_CPP_EXCEPTIONS" ],
    "conditions": [
      ['OS=="win"', {
        "cflags!": [ "-fno-exceptions" ],
        "cflags_cc!": [ "-fno-exceptions" ],
        "msvs_settings": {
          "VCCLCompilerTool": {
            "ExceptionHandling": 1
          }
        }
      }],
      ['OS=="mac"', {
        "sources": [ "cursor.mm" ],
        "link_settings": {
          "libraries": [
            "-framework Cocoa"
          ]
        },
        "xcode_settings": {
          "OTHER_CPLUSPLUSFLAGS": ["-std=c++14", "-stdlib=libc++"],
          "OTHER_LDFLAGS": ["-framework Cocoa"],
          "MACOSX_DEPLOYMENT_TARGET": "10.13"
        }
      }]
    ]
  }]
}