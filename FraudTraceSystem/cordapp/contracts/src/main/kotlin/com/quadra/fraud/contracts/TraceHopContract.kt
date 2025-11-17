package com.quadra.fraud.contracts

import net.corda.core.contracts.CommandData
import net.corda.core.contracts.Contract
import net.corda.core.contracts.requireThat
import net.corda.core.transactions.LedgerTransaction
import com.quadra.fraud.states.TraceHopState

class TraceHopContract : Contract {
    companion object {
        const val ID = "com.quadra.fraud.contracts.TraceHopContract"
    }

    interface Commands : CommandData {
        class Create : Commands
    }

    override fun verify(tx: LedgerTransaction) {
        val command = tx.commands.requireSingleCommand<Commands>()
        when (command.value) {
            is Commands.Create -> {
                requireThat {
                    "No inputs should be consumed when creating a trace hop." using (tx.inputs.isEmpty())
                    "Only one output state should be created." using (tx.outputs.size == 1)
                    val out = tx.outputsOfType<TraceHopState>().single()
                    "Amount must be positive." using (out.amount > 0)
                    "Hop index must be non-negative." using (out.hopIndex >= 0)
                }
            }
        }
    }
}

