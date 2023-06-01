package io.agora.hack.believe.utils

import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

/**
 * @author create by zhangwei03
 */
class UDPClient constructor(private val serverAddress: String, private val serverPort: Int) {

    private var socket: DatagramSocket? = null
    private var inetAddress: InetAddress? = null
    @Volatile
    private var isRunning: Boolean = false

    fun run() {
        isRunning = true
        socket = DatagramSocket()

//        send("Hello, Server!")

        while (isRunning) {
            val buffer = ByteArray(1024)
            val packet = DatagramPacket(buffer, buffer.size)
            socket?.receive(packet)
            val message = String(packet.data).trim()
            println("Received message: $message")
        }
    }

    fun send(message: String) {
        ThreadTools.get().runOnIOThread {
            if (inetAddress == null) {
                inetAddress = InetAddress.getByName(serverAddress) // 服务器地址
            }

            val buffer = message.toByteArray()
            val packet = DatagramPacket(buffer, buffer.size, inetAddress, serverPort)
            socket?.send(packet)
        }
    }

    fun stop() {
        ThreadTools.get().runOnIOThread {
            isRunning = false
            socket?.close()
            socket = null
            inetAddress = null
        }
    }
}