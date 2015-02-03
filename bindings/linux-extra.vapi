/**
 * Fixes and extra bindings not included in the upstrem Linux bindings.
 */
namespace Linux {
    [CCode (cheader_filename = "linux/input.h")]
    namespace Input {
        public const int SYN_DROPPED;
    }
}