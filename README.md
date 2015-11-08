# fairyip
mac qq 显ip 老代码
```
cd mac_project/fairyip3
gcc -c -arch i386 -arch x86_64 main.m
gcc -flat_namespace -dynamiclib -current_version 1.0 main.o -o fairyip3.dylib -arch i386 -arch x86_64 -framework Foundation
DYLD_FORCE_FLAT_NAMESPACE=1 DYLD_INSERT_LIBRARIES=fairyip3.dylib /Applications/QQ\ 1.4.app/Contents/MacOS/QQ
DYLD_FORCE_FLAT_NAMESPACE=1 DYLD_INSERT_LIBRARIES=fairyip3.dylib /Applications/QQ\ 2.3.app/Contents/MacOS/QQ
