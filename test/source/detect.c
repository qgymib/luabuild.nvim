#include <stdio.h>

#define S(x)    #x

const char* info =
"DETECT_BEG\n"

"ARCH:"
#if defined(__x86_64__) || defined(_M_X64)
    "amd64"
#elif defined(__i386__) || defined(_M_IX86)
    "x86"
#elif defiend(__ia64__) || defined(_M_IA64)
    "ia64"
#elif defined(__arm__) || defined(_M_ARM)
    "arm"
#elif defined(__aarch64__) || defined(_M_ARM64)
    "arm64"
#elif defined(__ppc__) || defined(__PPC__) || defined(__ppc64__)
    || defined(__PPC64__) || defined(_M_PPC)
    "powerpc"
#elif defined(__mips__)
    "mips"
#else
    "unknown"
#endif
"\n"

"OS:"
#if defined(_WIN32)
    "windows"
#elif defined(__linux__)
    "linux"
#elif defined(__APPLE__)
    "macos"
#elif defined(__ANDROID__)
    "android"
#else
    "unknown"
#endif
"\n"

/**
 * https://gcc.gnu.org/onlinedocs/gcc-11.2.0/gcc/Code-Gen-Options.html
 */
#if defined(__PIC__)
    "PIC:" S(__PIC__) "\n"
#endif
#if defined(__PIE__)
    "PIE:" S(__PIE__) "\n"
#endif

#if defined(__GNUC__)
    "GCC:" S(__GNUC__) "." S(__GNUC_MINOR__) "." S(__GNUC_PATCHLEVEL__) "\n"
#endif
#if defined(__clang__)
    "CLANG:" S(__clang_major__) "." S(__clang_minor__) "." S(__clang_patchlevel__) "\n"
#endif
#if defined(_MSC_VER)
    "MSVC:" S(_MSC_VER) "\n"
#endif

"DETECT_END";

int main(int argc, char* argv[])
{
    (void)argc; (void)argv;
    printf("%s\n", info);
    return 0;
}
