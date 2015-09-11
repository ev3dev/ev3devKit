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

namespace EV3devKit.Devices {
    /**
     * Flags indicating motor state.
     *
     * These flags are used by {@link DcMotor}, {@link ServoMotor} and
     * {@link TachoMotor}. Not all values are supported by each class.
     */
    [Flags]
    public enum MotorStateFlags {
        RUNNING,
        RAMPING,
        HOLDING,
        STALLED;

        /**
         * Converts a string to a flag value.
         */
        internal static MotorStateFlags from_string (string value) {
            switch (value) {
            case "running":
                return MotorStateFlags.RUNNING;
            case "ramping":
                return MotorStateFlags.RAMPING;
            case "stalled":
                return MotorStateFlags.STALLED;
            default:
                critical ("Unknown MotorStateFlags string");
                return (MotorStateFlags)0;
            }
        }

        internal static MotorStateFlags from_strv (string[] values) {
            var result = (MotorStateFlags)0;
            foreach (var value in values) {
                result |= from_string(value);
            }
            return result;
        }
    }
}