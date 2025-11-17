package com.quadra.bankapi

import net.corda.core.identity.CordaX500Name
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import com.quadra.fraud.flows.SendFraudAlertFlow
import org.springframework.web.client.RestTemplate
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType

@RestController
@RequestMapping("/fraud")
class FraudController(
    @Autowired private val rpc: CordaRPCClientService,
    @Autowired private val aiClient: AIClient
) {
    private val restTemplate = RestTemplate()

    @PostMapping("/analyze")
    fun analyzeTransaction(@RequestBody tx: TransactionDTO): ResponseEntity<Any> {
        try {
            // 1. Call AI service
            val score = aiClient.getRiskScore(tx)
            
            if (score >= 0.7) {
                // 2. Call Corda flow
                // Note: In production, you'd resolve the destination party properly
                // For now, we'll use a placeholder approach
                val destParty = try {
                    rpc.proxy.wellKnownPartyFromX500Name(
                        CordaX500Name.parse("O=BankB,L=City,C=GB")
                    )
                } catch (e: Exception) {
                    // If party not found, we'll still create the alert
                    // In production, handle this more gracefully
                    null
                }
                
                if (destParty != null) {
                    val flowHandle = rpc.proxy.startFlowDynamic(
                        SendFraudAlertFlow::class.java,
                        tx.txId,
                        tx.amount,
                        destParty,
                        score,
                        "auto-detected suspicious transaction"
                    )
                    
                    val result = flowHandle.returnValue.get()
                    
                    // 3. Notify LEA backend
                    notifyLEA(tx, score)
                    
                    return ResponseEntity.ok(mapOf(
                        "status" to "alert_created",
                        "riskScore" to score,
                        "result" to result.toString()
                    ))
                } else {
                    // Log warning but still notify LEA
                    notifyLEA(tx, score)
                    return ResponseEntity.ok(mapOf(
                        "status" to "alert_created_offchain",
                        "riskScore" to score,
                        "message" to "High risk detected but destination party not found"
                    ))
                }
            }
            
            return ResponseEntity.ok(mapOf(
                "status" to "ok",
                "riskScore" to score
            ))
        } catch (e: Exception) {
            return ResponseEntity.status(500).body(mapOf(
                "status" to "error",
                "message" to e.message
            ))
        }
    }
    
    private fun notifyLEA(tx: TransactionDTO, riskScore: Double) {
        try {
            val headers = HttpHeaders()
            headers.contentType = MediaType.APPLICATION_JSON
            
            val alert = mapOf(
                "txId" to tx.txId,
                "amount" to tx.amount,
                "riskScore" to riskScore,
                "timestamp" to tx.timestamp
            )
            
            val request = HttpEntity(alert, headers)
            restTemplate.postForEntity(
                "http://localhost:8080/notify",
                request,
                Any::class.java
            )
        } catch (e: Exception) {
            println("Failed to notify LEA backend: ${e.message}")
        }
    }
}

