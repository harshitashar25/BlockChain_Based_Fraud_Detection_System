package com.quadra.fraud.states

import net.corda.core.contracts.LinearState
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party
import java.time.Instant

data class TraceHopState(
    val txId: String,
    val hopIndex: Int,
    val fromBank: Party,
    val toBank: Party,
    val amount: Long,
    val timestamp: Instant,
    override val linearId: UniqueIdentifier = UniqueIdentifier(),
    override val participants: List<AbstractParty> = listOf(fromBank, toBank)
) : LinearState

