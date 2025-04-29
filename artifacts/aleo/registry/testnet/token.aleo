program token.aleo;

record token:
    owner as address.private;
    balance as u64.private;

mapping account:
    key as address.public;
    value as u64.public;

function mint_pub:
    input r0 as address.public;
    input r1 as u64.public;
    async mint_pub r0 r1 into r2;
    output r2 as token.aleo/mint_pub.future;

finalize mint_pub:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];

function mint_priv:
    input r0 as address.private;
    input r1 as u64.private;
    cast r0 r1 into r2 as token.record;
    output r2 as token.record;

function transfer_pub:
    input r0 as address.public;
    input r1 as u64.public;
    async transfer_pub self.caller r0 r1 into r2;
    output r2 as token.aleo/transfer_pub.future;

finalize transfer_pub:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get.or_use account[r0] 0u64 into r3;
    sub r3 r2 into r4;
    set r4 into account[r0];
    get.or_use account[r1] 0u64 into r5;
    add r5 r2 into r6;
    set r6 into account[r1];

function transfer_priv:
    input r0 as token.record;
    input r1 as address.private;
    input r2 as u64.private;
    sub r0.balance r2 into r3;
    cast r0.owner r3 into r4 as token.record;
    cast r1 r2 into r5 as token.record;
    output r4 as token.record;
    output r5 as token.record;

function transfer_priv_to_pub:
    input r0 as token.record;
    input r1 as address.public;
    input r2 as u64.public;
    assert.eq self.caller r0.owner;
    sub r0.balance r2 into r3;
    cast r0.owner r3 into r4 as token.record;
    async transfer_priv_to_pub r1 r2 into r5;
    output r4 as token.record;
    output r5 as token.aleo/transfer_priv_to_pub.future;

finalize transfer_priv_to_pub:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into account[r0];

function transfer_pub_to_priv:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    cast r1 r2 into r3 as token.record;
    async transfer_pub_to_priv r0 r2 into r4;
    output r3 as token.record;
    output r4 as token.aleo/transfer_pub_to_priv.future;

finalize transfer_pub_to_priv:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use account[r0] 0u64 into r2;
    sub r2 r1 into r3;
    set r3 into account[r0];

function reset_account:
    input r0 as address.public;
    async reset_account r0 into r1;
    output r1 as token.aleo/reset_account.future;

finalize reset_account:
    input r0 as address.public;
    set 0u64 into account[r0];
