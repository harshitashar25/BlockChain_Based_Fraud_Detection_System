package com.quadra.fraud.flows

import co.paralleluniverse.fibers.Suspendable
import com.quadra.fraud.contracts.TraceHopContract
import com.quadra.fraud.states.TraceHopState
import net.corda.core.contracts.Command
import net.corda.core.flows.*
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder
import java.time.Instant

@InitiatingFlow
@StartableByRPC
class RecordTraceHopFlow(
    private val txId: String,
    private val hopIndex: Int,
    private val toBank: Party,
    private val amount: Long
) : FlowLogic<SignedTransaction>() {

    @Suspendable
    override fun call(): SignedTransaction {
        val notary = serviceHub.networkMapCache.notaryIdentities.first()
        
        val output = TraceHopState(
            txId = txId,
            hopIndex = hopIndex,
            fromBank = ourIdentity,
            toBank = toBank,
            amount = amount,
            timestamp = Instant.now()
        )
        
        val cmd = Command(TraceHopContract.Commands.Create(), output.participants.map { it.owningKey })
        
        val tb = TransactionBuilder(notary)
            .addOutputState(output, TraceHopContract.ID)
            .addCommand(cmd)
        
        tb.verify(serviceHub)
        val ptx = serviceHub.signInitialTransaction(tb)
        
        val session = initiateFlow(toBank)
        val stx = subFlow(CollectSignaturesFlow(ptx, listOf(session)))
        val ftx = subFlow(FinalityFlow(stx, listOf(session)))
        
        return ftx
    }
}

@InitiatedBy(RecordTraceHopFlow::class)
class RecordTraceHopResponder(val otherPartySession: FlowSession) : FlowLogic<Unit>() {
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

