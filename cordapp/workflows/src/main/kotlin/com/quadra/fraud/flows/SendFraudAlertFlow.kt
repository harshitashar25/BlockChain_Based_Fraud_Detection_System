package com.quadra.fraud.flows

import co.paralleluniverse.fibers.Suspendable
import com.quadra.fraud.contracts.FraudAlertContract
import com.quadra.fraud.states.FraudAlertState
import net.corda.core.contracts.Command
import net.corda.core.flows.*
import net.corda.core.transactions.SignedTransaction
import net.corda.core.transactions.TransactionBuilder
import java.time.Instant

@InitiatingFlow
@StartableByRPC
class SendFraudAlertFlow(
    private val txId: String,
    private val amount: Long,
    private val destination: Party,
    private val riskScore: Double,
    private val message: String
) : FlowLogic<SignedTransaction>() {

    @Suspendable
    override fun call(): SignedTransaction {
        // Step 1. Choose notary
        val notary = serviceHub.networkMapCache.notaryIdentities.first()
        
        // Step 2. Build state
        val output = FraudAlertState(
            txId = txId,
            amount = amount,
            sourceBank = ourIdentity,
            destinationBank = destination,
            riskScore = riskScore,
            alertMsg = message,
            timestamp = Instant.now()
        )
        
        // Step 3. Command
        val cmd = Command(FraudAlertContract.Commands.Create(), output.participants.map { it.owningKey })
        
        // Step 4. Build tx
        val tb = TransactionBuilder(notary)
            .addOutputState(output, FraudAlertContract.ID)
            .addCommand(cmd)
        
        tb.verify(serviceHub)
        val ptx = serviceHub.signInitialTransaction(tb)
        
        // Collect counterparty signature
        val session = initiateFlow(destination)
        val stx = subFlow(CollectSignaturesFlow(ptx, listOf(session)))
        val ftx = subFlow(FinalityFlow(stx, listOf(session)))
        
        return ftx
    }
}

@InitiatedBy(SendFraudAlertFlow::class)
class SendFraudAlertResponder(val otherPartySession: FlowSession) : FlowLogic<Unit>() {
    @Suspendable
    override fun call() {
        val signFlow = object : SignTransactionFlow(otherPartySession) {
            override fun checkTransaction(stx: SignedTransaction) {
                // optional checks by recipient
            }
        }
        subFlow(signFlow)
        subFlow(ReceiveFinalityFlow(otherPartySession))
    }
}

