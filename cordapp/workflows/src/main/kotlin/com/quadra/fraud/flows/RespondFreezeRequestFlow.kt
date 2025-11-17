package com.quadra.fraud.flows

import co.paralleluniverse.fibers.Suspendable
import com.quadra.fraud.contracts.FreezeRequestContract
import com.quadra.fraud.states.FreezeRequestState
import net.corda.core.contracts.Command
import net.corda.core.contracts.StateAndRef
import net.corda.core.flows.*
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder

@InitiatingFlow
@StartableByRPC
class RespondFreezeRequestFlow(
    private val freezeRequestStateRef: StateAndRef<FreezeRequestState>,
    private val newStatus: String  // "FROZEN" or "REJECTED"
) : FlowLogic<SignedTransaction>() {

    @Suspendable
    override fun call(): SignedTransaction {
        require(newStatus == "FROZEN" || newStatus == "REJECTED") {
            "Status must be FROZEN or REJECTED"
        }
        
        val notary = freezeRequestStateRef.state.notary
        val inputState = freezeRequestStateRef.state.data
        
        require(inputState.status == "PENDING") {
            "Freeze request must be in PENDING status"
        }
        
        val outputState = inputState.copy(status = newStatus)
        
        val cmd = Command(
            FreezeRequestContract.Commands.Update(),
            outputState.participants.map { it.owningKey }
        )
        
        val tb = TransactionBuilder(notary)
            .addInputState(freezeRequestStateRef)
            .addOutputState(outputState, FreezeRequestContract.ID)
            .addCommand(cmd)
        
        tb.verify(serviceHub)
        val ptx = serviceHub.signInitialTransaction(tb)
        
        // Collect signature from requester
        val requesterSession = initiateFlow(inputState.requestedBy)
        val stx = subFlow(CollectSignaturesFlow(ptx, listOf(requesterSession)))
        val ftx = subFlow(FinalityFlow(stx, listOf(requesterSession)))
        
        return ftx
    }
}

@InitiatedBy(RespondFreezeRequestFlow::class)
class RespondFreezeRequestResponder(val otherPartySession: FlowSession) : FlowLogic<Unit>() {
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

