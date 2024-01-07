package util;

class ValidationUtils {
    public static function validateUsername(username:String):Bool {
        if (username.length < 3)
            return false;

        if (username.charAt(0).toUpperCase() == username.charAt(0).toLowerCase())
            return false;

        if (username.length > 20)
            return false;

        return true;
    }
}
