package com.quadra.fraud.contracts

import net.corda.core.contracts.CommandData
import net.corda.core.contracts.Contract
import net.corda.core.contracts.requireThat
import net.corda.core.transactions.LedgerTransaction
import com.quadra.fraud.states.FraudAlertState

class FraudAlertContract : Contract {
    companion object {
        const val ID = "com.quadra.fraud.contracts.FraudAlertContract"
    }

    interface Commands : CommandData {
        class Create : Commands
    }

    override fun verify(tx: LedgerTransaction) {
        val command = tx.commands.requireSingleCommand<Commands>()
        when (command.value) {
            is Commands.Create -> {
                requireThat {
                    "No inputs should be consumed when creating an alert." using (tx.inputs.isEmpty())
                    "Only one output state should be created." using (tx.outputs.size == 1)
                    val out = tx.outputsOfType<FraudAlertState>().single()
                    "Amount must be positive." using (out.amount > 0)
                    "Risk score must be between 0 and 1." using (out.riskScore >= 0.0 && out.riskScore <= 1.0)
                }
            }
        }
    }
}

