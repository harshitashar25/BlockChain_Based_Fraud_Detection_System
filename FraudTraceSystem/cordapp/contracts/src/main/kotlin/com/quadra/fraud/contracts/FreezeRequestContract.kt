package com.quadra.fraud.contracts

import net.corda.core.contracts.CommandData
import net.corda.core.contracts.Contract
import net.corda.core.contracts.requireThat
import net.corda.core.transactions.LedgerTransaction
import com.quadra.fraud.states.FreezeRequestState

class FreezeRequestContract : Contract {
    companion object {
        const val ID = "com.quadra.fraud.contracts.FreezeRequestContract"
    }

    interface Commands : CommandData {
        class Create : Commands
        class Update : Commands
    }

    override fun verify(tx: LedgerTransaction) {
        val command = tx.commands.requireSingleCommand<Commands>()
        when (command.value) {
            is Commands.Create -> {
                requireThat {
                    "No inputs should be consumed when creating a freeze request." using (tx.inputs.isEmpty())
                    "Only one output state should be created." using (tx.outputs.size == 1)
                    val out = tx.outputsOfType<FreezeRequestState>().single()
                    "Status must be PENDING when creating." using (out.status == "PENDING")
                    "Reason must not be empty." using (out.reason.isNotEmpty())
                }
            }
            is Commands.Update -> {
                requireThat {
                    "One input and one output should be present when updating." using (tx.inputs.size == 1 && tx.outputs.size == 1)
                    val input = tx.inputsOfType<FreezeRequestState>().single()
                    val output = tx.outputsOfType<FreezeRequestState>().single()
                    "Linear ID must match." using (input.linearId == output.linearId)
                    "Status must change from PENDING." using (input.status == "PENDING")
                    "Status must be FROZEN or REJECTED." using (output.status == "FROZEN" || output.status == "REJECTED")
                }
            }
        }
    }
}

