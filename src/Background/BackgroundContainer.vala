//
//  Copyright (C) 2013 Tom Beckmann, Rico Tzschichholz
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Gala {
    public class BackgroundContainer : Meta.BackgroundGroup {
        public signal void changed ();
        public signal void show_background_menu (int x, int y);

        public Meta.Display display { get; construct; }

        public BackgroundContainer (Meta.Display display) {
            Object (display: display);
        }

        construct {
            Meta.MonitorManager.@get ().monitors_changed.connect (update);

            reactive = true;
            button_release_event.connect ((event) => {
                if (event.button == Gdk.BUTTON_SECONDARY) {
                    show_background_menu ((int)event.x, (int)event.y);
                }
            });

            update ();
        }

        ~BackgroundContainer () {
            Meta.MonitorManager.@get ().monitors_changed.disconnect (update);
        }

        private void update () {
            var reference_child = (get_child_at_index (0) as BackgroundManager);
            if (reference_child != null)
                reference_child.changed.disconnect (background_changed);

            destroy_all_children ();

            for (var i = 0; i < display.get_n_monitors (); i++) {
                var background = new BackgroundManager (display, i);

                add_child (background);

                if (i == 0)
                    background.changed.connect (background_changed);
            }
        }

        private void background_changed () {
            changed ();
        }
    }
}
