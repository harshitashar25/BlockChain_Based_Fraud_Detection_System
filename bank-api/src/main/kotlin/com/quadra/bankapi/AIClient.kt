package com.quadra.bankapi

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType

@Service
class AIClient(
    @Value("\${ai.engine.url}") private val aiEngineUrl: String
) {
    private val restTemplate = RestTemplate()

    fun getRiskScore(tx: TransactionDTO): Double {
        try {
            val headers = HttpHeaders()
            headers.contentType = MediaType.APPLICATION_JSON
            
            val request = HttpEntity(tx, headers)
            val response = restTemplate.postForEntity(
                "$aiEngineUrl/risk-score",
                request,
                RiskScoreResponse::class.java
            )
            
            return response.body?.riskScore ?: 0.0
        } catch (e: Exception) {
            println("Error calling AI engine: ${e.message}")
            return 0.5 // default risk score on error
        }
    }
}

data class RiskScoreResponse(val riskScore: Double)

