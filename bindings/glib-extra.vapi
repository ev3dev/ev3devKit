/**
 * Fixes and extra bindings not included in the upstrem GLib bindings.
 */
[CCode (cprefix = "G", lower_case_cprefix = "g_")]
namespace GLib {
    /**
     * Workaround for buggy {@link GLib.FlagsClass}.
     *
     * Existing {@link GLib.FlagsClass} generated CCode for ``values`` is
     * ``GFlagsValue**`` which is incorrect, it should be ``GFlagsValue*``.
     */
    [CCode (cname = "GFlagsClass", lower_case_csuffix = "flags")]
    public class FlagsClass2 : TypeClass {
        public unowned FlagsValue2? get_first_value (uint value);
        public unowned FlagsValue2? get_value_by_name (string name);
        public unowned FlagsValue2? get_value_by_nick (string name);
        public uint mask;
        public uint n_values;
        [CCode (array_length_cname = "n_values")]
        public unowned FlagsValue2[] values;
    }

    /**
     * Workaround for buggy {@link GLib.FlagsClass}.
     *
     * Existing GObject bindings have {@link GLib.FlagsValue} as a compact class.
     * This is a struct to match the bindings for {@link GLib.EnumValue}.
     *
     * @see FlagsClass2
     */
    [CCode (cname = "GFlagsValue", has_type_id = false)]
    public struct FlagsValue2 {
        public uint value;
        public unowned string value_name;
        public unowned string value_nick;
    }
}