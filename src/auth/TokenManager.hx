package auth;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import models.User;

class TokenManager {
    public static function generate(user:User):String {
        var raw = "";

        raw += user.id;
        raw += ".";

        var expiry = Date.fromTime(Date.now().getTime() + (30 * 24 * 60 * 60 * 1000));

        raw += Math.round(expiry.getTime());
        raw += ".";

        var random = Math.floor(Math.random() * 2147483647);

        raw += random;

        return Base64.encode(Bytes.ofString(raw));
    }
}
