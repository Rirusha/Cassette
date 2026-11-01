internal class Tape.ResultCodec<T> : Deser.Codec<T> {
    Deser.Codec<T> inner;

    public ResultCodec (Deser.Codec<T> inner) {
        this.inner = inner;
    }

    public override GLib.Type value_type { get { return inner.value_type; } }

    public override Deser.NullableValue pack (T value) throws Deser.Error {
        return inner.pack (value);
    }

    public override T unpack (Deser.NullableValue value) throws Deser.Error {
        return inner.unpack (value);
    }

    public override T decode (
        Deser.ValueView node,
        Deser.DecodeContext context
    ) throws Deser.Error {
        if (node.kind != Deser.ValueKind.MAP) {
            throw new Deser.Error.TYPE_MISMATCH ("%s: expected API response object", context.path ());
        }

        var cursor = node.open_map ();
        string key;
        Deser.ValueView child;
        Deser.ValueView? result = null;
        while (cursor.next (out key, out child)) {
            context.push_key (key);
            try {
                context.visit_node ();
                if (key == "result") {
                    if (result != null) {
                        throw new Deser.Error.DUPLICATE_FIELD ("%s: duplicate result", context.path ());
                    }
                    result = (owned) child;
                }
            } finally {
                context.pop ();
            }
        }
        if (result == null) {
            throw new Deser.Error.MISSING_REQUIRED ("%s: missing result", context.path ());
        }

        context.push_key ("result");
        try {
            return inner.decode (result, context);
        } finally {
            context.pop ();
        }
    }

    public override void encode (
        T value,
        Deser.ValueWriter writer,
        Deser.EncodeContext context
    ) throws Deser.Error {
        writer.begin_map ();
        writer.write_key ("result");
        context.push_key ("result");
        try {
            inner.encode (value, writer, context);
        } finally {
            context.pop ();
        }
        writer.end_map ();
    }
}
