package com.quadra.fraud.flows

import co.paralleluniverse.fibers.Suspendable
import com.quadra.fraud.contracts.FreezeRequestContract
import com.quadra.fraud.states.FreezeRequestState
import net.corda.core.contracts.Command
import net.corda.core.flows.*
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder
import java.time.Instant

@InitiatingFlow
@StartableByRPC
class RaiseFreezeRequestFlow(
    private val txId: String,
    private val targetBank: Party,
    private val reason: String
) : FlowLogic<SignedTransaction>() {

    @Suspendable
    override fun call(): SignedTransaction {
        val notary = serviceHub.networkMapCache.notaryIdentities.first()
        
        val output = FreezeRequestState(
            txId = txId,
            requestedBy = ourIdentity,
            targetBank = targetBank,
            reason = reason,
            timestamp = Instant.now(),
            status = "PENDING"
        )
        
        val cmd = Command(FreezeRequestContract.Commands.Create(), output.participants.map { it.owningKey })
        
        val tb = TransactionBuilder(notary)
            .addOutputState(output, FreezeRequestContract.ID)
            .addCommand(cmd)
        
        tb.verify(serviceHub)
        val ptx = serviceHub.signInitialTransaction(tb)
        
        val session = initiateFlow(targetBank)
        val stx = subFlow(CollectSignaturesFlow(ptx, listOf(session)))
        val ftx = subFlow(FinalityFlow(stx, listOf(session)))
        
        return ftx
    }
}

@InitiatedBy(RaiseFreezeRequestFlow::class)
class RaiseFreezeRequestResponder(val otherPartySession: FlowSession) : FlowLogic<Unit>() {
    @Suspendable
    override fun call() {
        val signFlow = object : SignTransactionFlow(otherPartySession) {
            override fun checkTransaction(stx: SignedTransaction) {
                // optional checks
            }
        }
        subFlow(signFlow)
        subFlow(ReceiveFinalityFlow(otherPartySession))
    }
}

