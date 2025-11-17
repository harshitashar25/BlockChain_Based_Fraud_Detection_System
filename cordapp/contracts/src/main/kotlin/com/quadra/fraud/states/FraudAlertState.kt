package com.quadra.fraud.states

import net.corda.core.contracts.ContractState
import net.corda.core.contracts.LinearState
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party
import java.time.Instant

data class FraudAlertState(
    val txId: String,                    // the original transaction/hash being flagged
    val amount: Long,
    val sourceBank: Party,
    val destinationBank: Party,
    val riskScore: Double,
    val alertMsg: String,
    val timestamp: Instant = Instant.now(),
    override val linearId: UniqueIdentifier = UniqueIdentifier(),
    override val participants: List<AbstractParty> = listOf(sourceBank, destinationBank)
) : LinearState

