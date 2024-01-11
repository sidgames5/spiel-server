package net;

import haxe.net.WebSocket;

class WebSocketManager {
    private static var webSocket:WebSocket;

    public static function init(onopen:() -> Void, onclose:() -> Void, onmessageString:(String) -> Void, onerror:(String) -> Void) {
        webSocket = WebSocket.create("ws://0.0.0.0:8193");
        webSocket.onopen = onopen;
        webSocket.onclose = onclose;
        webSocket.onmessageString = onmessageString;
        webSocket.onerror = onerror;
    }

    public static function getWebSocket():WebSocket {
        return webSocket;
    }

    public static function close() {
        webSocket.close();
    }
}
