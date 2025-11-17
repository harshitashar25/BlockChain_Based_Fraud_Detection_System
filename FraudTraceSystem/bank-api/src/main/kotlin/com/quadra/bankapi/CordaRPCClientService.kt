package com.quadra.bankapi

import net.corda.client.rpc.CordaRPCClient
import net.corda.core.messaging.CordaRPCOps
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import javax.annotation.PostConstruct
import javax.annotation.PreDestroy

@Service
class CordaRPCClientService(
    @Value("\${corda.rpc.host}") private val host: String,
    @Value("\${corda.rpc.port}") private val port: Int,
    @Value("\${corda.rpc.username}") private val username: String,
    @Value("\${corda.rpc.password}") private val password: String
) {
    lateinit var proxy: CordaRPCOps
    private var connection: net.corda.client.rpc.CordaRPCConnection? = null

    @PostConstruct
    fun start() {
        try {
            val client = CordaRPCClient(java.net.NetworkHostAndPort(host, port))
            connection = client.start(username, password)
            proxy = connection!!.proxy
            println("Connected to Corda node at $host:$port")
        } catch (e: Exception) {
            println("Failed to connect to Corda node: ${e.message}")
            throw e
        }
    }

    @PreDestroy
    fun stop() {
        connection?.close()
    }
}

