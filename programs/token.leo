program token.aleo {
    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    record token {
        // The token owner.
        owner: address,
        // The token balance.
        balance: u64,
    }

    /* Helpers */

    async function finalize_decrement_account(public addr: address, public amount: u64) {
        // Decrements `account[addr]` by `amount`.
        // If `account[addr]` does not exist, it will be created.
        // If `account[addr] - amount` underflows, `decrement_mapping` is reverted.
        let addr_amount: u64 = Mapping::get_or_use(account, addr, 0u64);
        Mapping::set(account, addr, addr_amount - amount);
    }

    async function finalize_increment_account(public addr: address, public amount: u64) {
        // Increments `account[addr]` by `amount`.
        // If `account[addr]` does not exist, it will be created.
        // If `account[addr] + amount` overflows, `increment_mapping` is reverted.
        let addr_amount: u64 = Mapping::get_or_use(account, addr, 0u64);
        Mapping::set(account, addr, addr_amount + amount);
    }

    /* Mint */

    // The function `mint_pub` issues the specified token amount for the token receiver publicly on the network.
    async transition mint_pub(public receiver: address, public amount: u64) -> Future {
        // Mint the tokens publicly by invoking the computation on-chain.
        return finalize_increment_account(receiver, amount);
    }

    // The function `mint_priv` initializes a new record with the specified amount of tokens for the receiver.
    transition mint_priv(receiver: address, amount: u64) -> token {
        return token {
            owner: receiver,
            balance: amount,
        };
    }

    /* Transfer */

    async transition transfer_pub(public receiver: address, public amount: u64) -> Future {
        // Transfer the tokens publicly, by invoking the computation on-chain.
        return finalize_transfer_pub(self.caller, receiver, amount);
    }

    async function finalize_transfer_pub(public sender: address, public receiver: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
        
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    // The function `transfer_priv` sends the specified token amount to the token receiver from the specified token record.
    transition transfer_priv(sender: token, receiver: address, amount: u64) -> (token, token) {
        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail if an overflow occurs.
        // `difference` holds the change amount to be returned to sender.
        let difference: u64 = sender.balance - amount;

        // Produce a token record with the change amount for the sender.
        let remaining: token = token {
            owner: sender.owner,
            balance: difference,
        };

        // Produce a token record for the specified receiver.
        let transferred: token = token {
            owner: receiver,
            balance: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }

    // The function `transfer_priv_to_pub` turns a specified token amount from a token record into public tokens for the specified receiver.
    // This function preserves privacy for the sender's record, however it publicly reveals the token receiver and the token amount.
    async transition transfer_priv_to_pub(sender: token, public receiver: address, public amount: u64) -> (token, Future) {
        assert_eq(self.caller, sender.owner);
        // Checks the given token record has a sufficient token amount.
        // This `sub` operation is safe, and the proof will fail if an underflow occurs.
        // `difference` holds the change amount for the caller.
        let difference: u64 = sender.balance - amount;

        // Produces a token record with the change amount for the caller.
        let remaining: token = token {
            owner: sender.owner,
            balance: difference,
        };

        // Output the sender's change record.
        // Increment the token amount publicly for the token receiver.
        return (remaining, finalize_increment_account(receiver, amount));
    }

    // The function `transfer_public_to_private` turns a specified token amount from `account` into a token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    async transition transfer_pub_to_priv(public sender: address, public receiver: address, public amount: u64) -> (token, Future) {
        // Produces a token record for the token receiver.
        let transferred: token = token {
            owner: receiver,
            balance: amount,
        };

        // Output the receiver's record.
        // Decrement the token amount of the caller publicly.
        return (transferred, finalize_decrement_account(sender, amount));
    }

    /* Test Helpers */

    async transition reset_account(public addr: address) -> Future {
        // Reset the token amount for the specified address publicly on the network.
        return finalize_reset_account(addr);
    }

    async function finalize_reset_account(public addr: address) {
        // Resets the token amount for the specified address to zero.
        Mapping::set(account, addr, 0u64);
    }
}
