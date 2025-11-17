package com.quadra.fraud.states

import net.corda.core.contracts.LinearState
import net.corda.core.contracts.UniqueIdentifier
import net.corda.core.identity.AbstractParty
import net.corda.core.identity.Party
import java.time.Instant

data class FreezeRequestState(
    val txId: String,
    val requestedBy: Party,    // LEA or bank
    val targetBank: Party,     // where to freeze
    val reason: String,
    val timestamp: Instant,
    var status: String = "PENDING",  // PENDING / FROZEN / REJECTED
    override val linearId: UniqueIdentifier = UniqueIdentifier(),
    override val participants: List<AbstractParty> = listOf(requestedBy, targetBank)
) : LinearState

