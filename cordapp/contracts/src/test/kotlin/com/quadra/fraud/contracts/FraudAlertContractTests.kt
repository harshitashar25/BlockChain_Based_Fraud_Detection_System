package com.quadra.fraud.contracts

import com.quadra.fraud.states.FraudAlertState
import net.corda.core.contracts.Command
import net.corda.core.identity.Party
import net.corda.testing.core.TestIdentity
import net.corda.testing.node.MockServices
import net.corda.testing.node.ledger
import org.junit.Test

class FraudAlertContractTests {
    private val ledgerServices = MockServices(listOf("com.quadra.fraud.contracts"))
    private val alice = TestIdentity("Alice", "London").party
    private val bob = TestIdentity("Bob", "New York").party

    @Test
    fun `transaction must include create command`() {
        ledgerServices.ledger {
            transaction {
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN001",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                fails("Required command not found")
            }
        }
    }

    @Test
    fun `transaction must have no inputs`() {
        ledgerServices.ledger {
            transaction {
                input(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN001",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN002",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                command(listOf(alice.owningKey, bob.owningKey), FraudAlertContract.Commands.Create())
                fails("No inputs should be consumed when creating an alert.")
            }
        }
    }

    @Test
    fun `transaction must have exactly one output`() {
        ledgerServices.ledger {
            transaction {
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN001",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN002",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                command(listOf(alice.owningKey, bob.owningKey), FraudAlertContract.Commands.Create())
                fails("Only one output state should be created.")
            }
        }
    }

    @Test
    fun `amount must be positive`() {
        ledgerServices.ledger {
            transaction {
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN001",
                    amount = -100L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                command(listOf(alice.owningKey, bob.owningKey), FraudAlertContract.Commands.Create())
                fails("Amount must be positive.")
            }
        }
    }

    @Test
    fun `risk score must be between 0 and 1`() {
        ledgerServices.ledger {
            transaction {
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN001",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 1.5,
                    alertMsg = "test"
                ))
                command(listOf(alice.owningKey, bob.owningKey), FraudAlertContract.Commands.Create())
                fails("Risk score must be between 0 and 1.")
            }
        }
    }

    @Test
    fun `valid transaction passes`() {
        ledgerServices.ledger {
            transaction {
                output(FraudAlertContract.ID, FraudAlertState(
                    txId = "TXN001",
                    amount = 1000L,
                    sourceBank = alice,
                    destinationBank = bob,
                    riskScore = 0.5,
                    alertMsg = "test"
                ))
                command(listOf(alice.owningKey, bob.owningKey), FraudAlertContract.Commands.Create())
                verifies()
            }
        }
    }
}

