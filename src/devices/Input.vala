/*
 * ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

using Linux;
using Linux.Input;

namespace EV3devKit.Devices {
    /**
     * Capabilities of an input device.
     */
    [Flags]
    public enum InputCapability {
        /**
         * Key and button press events.
         */
        KEY = 1 << EV_KEY,

        /**
         * Relative axis events, such as mouse movement.
         */
        RELATIVE_AXIS = 1 << EV_REL,

        /**
         * Absolute axis events, such as joystick position.
         */
        ABSOLUTE_AXIS = 1 << EV_ABS,

        /**
         * Uncategorized events.
         */
        MISC = 1 << EV_MSC,

        /**
         * On/off events.
         */
        SWITCH = 1 << EV_SW,

        /**
         * Control LEDs.
         *
         * Note: These are keyboard LEDs. You probably want {@link LED} instead.
         */
        LED = 1 << EV_LED,

        /**
         * Control sound devices.
         *
         * Note: This is for beep only. For other sound playback, you need to use ALSA.
         */
        SOUND = 1 << EV_SND,

        /**
         * Repeat events.
         */
        REPEAT = 1 << EV_REP,

        /**
         * Control force feedback.
         */
        FORCE_FEEDBACK = 1 << EV_FF,

        /**
         * Power events
         */
        POWER = 1 << EV_PWR,

        /**
         * Force feedback status events.
         */
        FORCE_FEEDBACK_STATUS = 1 << EV_FF_STATUS;

        /**
         * Workaround for valac bug.
         *
         * This method exists to force <linux/input.h> to be included in the
         * generated ev3devKit.h file. The compiler includes the initializers
         * (i.e. 1 << EV_KEY) so linux/input.h must be included.
         *
         * This method does not do anything useful.
         *
         * @return ``null``
         */
        [Deprecated]
        public Event? do_not_call_this_method () { return null; }
    }

    /**
     * Specific capabilities of a sound capable input device.
     */
    [Flags]
    public enum SoundCapability {
// Ignoring click for now since almost nothing supports it.
#if 0
        /**
         * The device supports the click event.
         */
        CLICK = 1 << SND_CLICK,
#endif
        /**
         * The device supports the bell event.
         */
        BELL = 1 << SND_BELL,

        /**
         * The device supports the tone event.
         */
        TONE = 1 << SND_TONE
    }

    /**
     * Linux input devices. (keyboard, mouse, joystick, etc.)
     *
     * Note: This is a very low-level - there may be better, higher-level options.
     */
    public class Input : EV3devKit.Devices.Device {
        /**
         * The name of the input device associated with the buttons on the EV3
         * brick itself.
         *
         * This can be passed to {@link DeviceManager.get_input_device} to get
         * the input device for the EV3 buttons.
         */
        public const string EV3_BUTTONS_NAME = "EV3 buttons";

        /**
         * The name of the input device associated with the speaker on the EV3
         * brick itself.
         *
         * This can be passed to {@link DeviceManager.get_input_device} to get
         * the input device for the EV3 speaker.
         *
         * Note: This is only used for the beep/tone mode of the speaker. For
         * other audio playback (PCM), use the ASLA driver.
         */
        public const string EV3_SPEAKER_BEEP_NAME = "EV3 speaker beep";

        /**
         * The number of bytes required to store the key state.
         */
        const int KEY_STATE_SIZE = (KEY_MAX + 7) / 8;

        GUdev.Device input_udev_device;
        int event_fd;
        bool syn_error;
        WeakNotify? weak_ref_func;

        /**
         * Gets the name of the input device.
         *
         * Note: This is not the device node name (i.e. input0, event1, etc.).
         * Those values are returned by {@link device_name} and {@link event_device_name}.
         *
         * This name depends on the driver and is used by {@link DeviceManager.get_input_device}
         * to find the matching input device.
         */
         public string? name {
            get { return input_udev_device.get_sysfs_attr ("name"); }
         }

        /**
         * {@inheritDoc}
         */
        public new string device_name {
            get { return input_udev_device.get_name (); }
        }

        /**
         * Gets the sysfs device node name for the event device associated with
         * this input device.
         *
         * Returns ``null`` if the device no longer exists (i.e. it was
         * disconnected.)
         */
        public string event_device_name {
            get { return udev_device.get_name (); }
        }

        /**
         * Gets the capabilities of this input device.
         */
        public InputCapability capabilities {
            get {
                var str = input_udev_device.get_property ("EV");
                if (str == null)
                    return (InputCapability)0;
                int flags;
                str.scanf ("%x", out flags);
                return (InputCapability)flags;
            }
        }

        /**
         * Emitted when a key is pressed.
         *
         * Uses {@link Linux.Input} for key codes.
         *
         * @param key_code The key code for the key that was pressed.
         */
        public signal void key_down (uint key_code);

        /**
         * Emitted when a key is released.
         *
         * Uses {@link Linux.Input} for key codes.
         *
         * @param key_code The key code for the key that was released.
         */
        public signal void key_up (uint key_code);

        internal Input (GUdev.Device udev_device) throws Error {
            base (udev_device);
            var event_device_name = udev_device.get_name ();
            input_udev_device = udev_device.get_parent_with_subsystem ("input", null);
            if (input_udev_device == null) {
                throw new DeviceError.NOT_FOUND ("Could not find parent input device for '%s'.",
                    event_device_name);
            }
            var channel = new IOChannel.file (udev_device.get_device_file (), "r+");
            event_fd = channel.unix_get_fd ();
            channel.set_encoding (null);
            channel.set_close_on_unref (false);
            var channel_watch_id = channel.add_watch (IOCondition.IN, handle_event);
            weak_ref_func = () => Source.remove (channel_watch_id);
            weak_ref (weak_ref_func);
            notify["connected"].connect (() => {
                if (!connected && weak_ref_func != null) {
                    weak_unref (weak_ref_func);
                    weak_ref_func (this);
                    weak_ref_func = null;
                }
            });
        }

        /**
         * Gets the value of a bit in a byte array.
         *
         * Essentially, this is using a byte array as a bit array. For example,
         * if ``offset`` is 11, it will return the 3rd bit of the 2nd byte.
         *
         * @param offset The offset in bits.
         * @param data The byte array.
         * @return ``true`` if the bit at the specified offset if set.
         */
        public bool get_bit_at (uint offset, uint8[] data) requires (offset < data.length * 8) {
            var byte_offset = offset / 8;
            var bit_offset = offset % 8;
            var bit_mask = 1 << bit_offset;
            return (data[byte_offset] & bit_mask) == bit_mask;
        }

        /**
         * Check if an input device has the specified capability.
         *
         * @param capability The capability flag(s) to check.
         * @return ``true`` if this device has all of the specified capabilities.
         */
        public bool has_capability (InputCapability capability) {
            return (capabilities & capability) == capability;
        }

        /**
         * Check if an input device has the specified key.
         *
         * @param key_code The key to look for.
         * @return ``true`` if the device has the key.
         */
        public bool has_key (uint key_code) requires (key_code < KEY_MAX) {
            // TODO: we could use the capabilities/key sysfs attr here instead
            // of using the ioctl.
            var buf = new uint8[KEY_STATE_SIZE];
            int err = ioctl (event_fd, EVIOCGBIT(EV_KEY, KEY_STATE_SIZE), ref buf);
            if (err < 0) {
                critical ("%s", Posix.strerror (err));
                return false;
            }
            return get_bit_at (key_code, buf);
        }

        /**
         * Check if a key is currently pressed.
         *
         * @param key_code The key to look for.
         * @return ``true`` if the key is pressed.
         */
        public bool get_key_state (uint key_code) requires (key_code < KEY_MAX) {
            var buf = new uint8[KEY_STATE_SIZE];
            int err = ioctl (event_fd, EVIOCGKEY(KEY_STATE_SIZE), ref buf);
            if (err < 0) {
                critical ("%s", Posix.strerror (err));
                return false;
            }
            return !get_bit_at (key_code, buf);
        }

        /**
         * Check if the device supports the specified sound capability.
         *
         * @param capability The sound capability(ies) to check.
         * @return ``true`` if the device supports all of the specified sound
         * capabilities.
         */
        public bool has_sound_capability (SoundCapability capability) {
            var snd_capability = (SoundCapability)input_udev_device.get_property_as_int ("SND");
            return (snd_capability & capability) == capability;
        }
        /**
         * Turns the "bell" of a sound device on or off.
         *
         * Does nothing if input device does not have the {@link SoundCapability.BELL}
         * sound capability.
         *
         * @param on If ``true``, the sound will turn on, otherwise the sound
         * will turn off.
         */
        public void do_bell (bool on) {
            var event = Event () {
                type = EV_SND,
                code = (uint16)SND_BELL,
                value = on ? 1 : 0
            };
            Posix.write (event_fd, &event, sizeof (Event));
        }

        /**
         * Sets the frequency of the a sound device.
         *
         * Does nothing if input device does not have the {@link SoundCapability.TONE}
         * sound capability.
         *
         * @param frequency The frequency of the sound output or ``0`` to turn
         * off sound output.
         */
        public void do_tone (int frequency) requires (frequency >= 0) {
            var event = Event () {
                type = EV_SND,
                code = (uint16)SND_TONE,
                value = frequency
            };
            Posix.write (event_fd, &event, sizeof (Event));
        }

        bool handle_event (IOChannel source, IOCondition condition) {
            try {
                var chars = new char[sizeof(Event)];
                size_t bytes_read;
                source.read_chars (chars, out bytes_read);
                var event = (Event*)chars;
                // don't process events if we are in an error state.
                if (syn_error && event.type != EV_SYN)
                    return true;
                switch (event.type) {
                case EV_SYN:
                    // check for error state
                    if (event.code == SYN_DROPPED) {
                        syn_error = true;
                        return true;
                    }
                    // recover from error
                    if (syn_error && event.code == SYN_REPORT) {
                        syn_error = false;
                        // if we start keeping track of state, we need to re-query state here.
                        return true;
                    }
                    break;
                case EV_KEY:
                    if (event.value == 0)
                        key_down (event.code);
                    else
                        key_up (event.code);
                    break;
                // TODO: handle more types of events.
                }
            } catch (Error err) {
                // TODO: there is a race condition here that sometime will will
                // get a "no such device" error when disconnecting. Not a big deal
                // just prints an error message when there is not really a problem.
                critical ("%s", err.message);
                weak_unref (weak_ref_func);
                weak_ref_func = null;
                return false;
            }
            return true;
        }
    }
}