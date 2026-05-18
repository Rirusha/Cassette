[CCode (cname = "CassetteTokenCallback", instance_pos = 1.5, has_target = true)]
public delegate void MacOsTokenCallback (string? token);

[CCode (cname = "cassette_macos_auth_start",
        cheader_filename = "macos-webkit-auth.h")]
public extern void cassette_macos_auth_start (string auth_url,
                                               owned MacOsTokenCallback callback);
