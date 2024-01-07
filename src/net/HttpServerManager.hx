package net;

import hx_webserver.HTTPRequest;
import hx_webserver.HTTPServer;

class HttpServerManager {
    private static var httpServer:HTTPServer;

    public static function init(handler:(req:HTTPRequest) -> Void) {
        httpServer = new HTTPServer("0.0.0.0", 8183, true);
        httpServer.onClientConnect = handler;
    }

    public static function getHttpServer():HTTPServer {
        return httpServer;
    }

    public static function close() {
        httpServer.server.close();
    }
}
