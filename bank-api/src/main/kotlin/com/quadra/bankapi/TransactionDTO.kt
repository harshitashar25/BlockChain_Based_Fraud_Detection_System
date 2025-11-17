package com.quadra.bankapi

import com.fasterxml.jackson.annotation.JsonProperty

data class TransactionDTO(
    @JsonProperty("txId")
    val txId: String,
    
    @JsonProperty("amount")
    val amount: Long,
    
    @JsonProperty("fromAccount")
    val fromAccount: String,
    
    @JsonProperty("toAccount")
    val toAccount: String,
    
    @JsonProperty("timestamp")
    val timestamp: String
)

