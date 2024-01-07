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

        Sys.println("Creating listeners");
        HttpServerManager.init(PacketHandler.receiveDatabasePacket);

        var i = Sys.stdin().readLine();
        HttpServerManager.close();
    }
}
