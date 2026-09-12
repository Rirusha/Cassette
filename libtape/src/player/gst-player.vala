/*
 * Copyright (C) 2025-2026 Vladimir Romanov <rirusha@altlinux.org>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

internal sealed class Tape.GstPlayer : Object {
    const string SOURCE_NAME = "source";

    public double volume { get; set; default = 1.0; }

    public bool mute { get; set; default = false; }

    public int64 duration {
        get {
            if (pipeline == null) {
                return 0;
            }

            int64 d;
            if (pipeline.query_duration (Gst.Format.TIME, out d)) {
                return d / Gst.MSECOND;
            }
            return 0;
        }
    }

    public int64 position {
        get {
            if (pipeline == null) {
                return 0;
            }

            int64 p;
            if (pipeline.query_position (Gst.Format.TIME, out p)) {
                return p / Gst.MSECOND;
            }
            return 0;
        }
    }

    public signal void eos (Gst.Bus bus, Gst.Message message);

    Gst.Pipeline pipeline;

    Gst.Element source;

    // Element contains `mute` and `volume`
    Gst.Element volume_el;

    //  // Normalization
    //  Element level;

    Gst.Element decodebin;
    Gst.Element audioconvert;
    Gst.Element audioresample;
    Gst.Element audiosink;

    construct {
        init_gst_if_not ();

        pipeline = new Gst.Pipeline (Uuid.string_random ());

        var bus = pipeline.get_bus ();

        bus.add_signal_watch ();
        bus.message["eos"].connect ((bus, message) => {
            eos (bus, message);
        });

        decodebin = Gst.ElementFactory.make ("decodebin", "decodebin");
        audioconvert = Gst.ElementFactory.make ("audioconvert", "audioconvert");
        audioresample = Gst.ElementFactory.make ("audioresample", "audioresample");
        volume_el = Gst.ElementFactory.make ("volume", "volume");
        audiosink = Gst.ElementFactory.make ("autoaudiosink", "audiosink");

        if (decodebin == null || audioconvert == null || audioresample == null || audiosink == null) {
            error ("Failed to create elements for pipeline.");
        }

        pipeline.add_many (decodebin, audioconvert, audioresample, volume_el, audiosink);

        decodebin.pad_added.connect ((src, pad) => {
            var sinkpad = audioconvert.get_static_pad ("sink");
            if (sinkpad != null && pad.can_link (sinkpad)) {
                pad.link (sinkpad);
            }
        });

        audioconvert.link (audioresample);
        audioresample.link (volume_el);
        volume_el.link (audiosink);

        bind_property ("volume", volume_el, "volume", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
        bind_property ("mute", volume_el, "mute", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
    }

    void init_gst_if_not () {
        weak string[]? gst_args = null;

        if (!Gst.is_initialized ()) {
            Gst.init (ref gst_args);
        }
    }

    void init_source (AudioSourceType source_type) {
        stop ();

        if (source != null) {
            if (pipeline.get_by_name (SOURCE_NAME) != null) {
                pipeline.remove (source);
            }

            source = null;
        }

        switch (source_type) {
            case FILE:
                source = Gst.ElementFactory.make ("filesrc", SOURCE_NAME);
                break;

            case HTTP:
                source = Gst.ElementFactory.make ("souphttpsrc", SOURCE_NAME);
                break;

            case DATA:
                source = Gst.ElementFactory.make ("appsrc", SOURCE_NAME);
                ((Gst.App.Src) source).set_stream_type (Gst.App.StreamType.STREAM);
                break;
        }

        pipeline.add (source);
        source.link (decodebin);
    }

    public void set_file_uri (string uri) throws PlayerError {
        var file = File.new_for_uri (uri);

        if (!file.has_uri_scheme ("file")) {
            throw new PlayerError.WRONG_SCHEME (_("Wrong scheme for file '%s'. Expected 'file'.").printf (uri));
        }

        set_file (file);
    }

    public void set_file_path (string path) throws PlayerError {
        var file = File.new_for_path (path);
        set_file (file);
    }

    public void set_file (File file) throws PlayerError {
        if (!file.query_exists ()) {
            throw new PlayerError.NO_SUCH_FILE (_("File '%s' does not exist").printf (file.get_path ()));
        }

        init_source (AudioSourceType.FILE);

        source.set_property ("location", file.get_path ());
    }

    public void set_http_uri (string uri) throws PlayerError {
        var file = File.new_for_uri (uri);

        if (!file.has_uri_scheme ("http") && !file.has_uri_scheme ("https")) {
            throw new PlayerError.WRONG_SCHEME (_("Wrong scheme for file '%s'. Expected 'http' or 'https'.").printf (
                uri
            ));
        }

        init_source (AudioSourceType.HTTP);

        source.set_property ("location", uri);
    }

    public void set_audio_data (uint8[] data) {
        init_source (AudioSourceType.DATA);

        var appsrc = (Gst.App.Src) source;
        appsrc.set_size (data.length);

        appsrc.push_buffer (new Gst.Buffer.wrapped (data));
    }

    public void set_audio_bytes (Bytes bytes) {
        init_source (AudioSourceType.DATA);

        var appsrc = (Gst.App.Src) source;
        appsrc.set_size (bytes.length);

        appsrc.push_buffer (new Gst.Buffer.wrapped_bytes (bytes));
    }

    public void seek (int64 position) {
        pipeline.seek_simple (Gst.Format.TIME, Gst.SeekFlags.NONE, position * Gst.MSECOND);
    }

    public void play () {
        pipeline.set_state (Gst.State.PLAYING);
    }

    public void pause () {
        pipeline.set_state (Gst.State.PAUSED);
    }

    public void stop () {
        pipeline.set_state (Gst.State.NULL);
    }
}
