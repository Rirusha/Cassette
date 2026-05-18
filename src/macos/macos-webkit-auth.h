#pragma once
#include <glib.h>

typedef void (*CassetteTokenCallback) (const char *token, gpointer userdata);

void cassette_macos_auth_start (const char          *auth_url,
                                CassetteTokenCallback callback,
                                gpointer              userdata,
                                GDestroyNotify        userdata_free);
