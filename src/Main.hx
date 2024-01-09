import auth.TokenManager;
import haxe.io.Eof;
import net.PacketHandler;
import net.HttpServerManager;
import database.DatabaseManager;

class Main {
    static function main() {
        if (!DatabaseManager.check()) {
            Sys.println("Initializing database");
            DatabaseManager.init();
        }
        if (!TokenManager.check()) {
            Sys.println("Initializing token storage");
            TokenManager.init();
        }

        Sys.println("Creating listeners");
        HttpServerManager.init(PacketHandler.receivePacket);
    }
}
