import {
  tx
} from "@doko-js/core";
import * as records from "../types/token";


export type TokenReset_accountTransition = tx.ExecutionReceipt < [tx.Transition < [tx.FutureOutput], 'token', 'reset_account' > , ] >
  export type TokenMint_pubTransition = tx.ExecutionReceipt < [tx.Transition < [tx.FutureOutput], 'token', 'mint_pub' > , ] >
  export type TokenMint_privTransition = tx.ExecutionReceipt < [tx.Transition < [tx.RecordOutput < records.token > ], 'token', 'mint_priv' > , ] >
  export type TokenTransfer_pubTransition = tx.ExecutionReceipt < [tx.Transition < [tx.FutureOutput], 'token', 'transfer_pub' > , ] >
  export type TokenTransfer_privTransition = tx.ExecutionReceipt < [tx.Transition < [tx.RecordOutput < records.token > , tx.RecordOutput < records.token > ], 'token', 'transfer_priv' > , ] >
  export type TokenTransfer_priv_to_pubTransition = tx.ExecutionReceipt < [tx.Transition < [tx.RecordOutput < records.token > , tx.FutureOutput], 'token', 'transfer_priv_to_pub' > , ] >
  export type TokenTransfer_pub_to_privTransition = tx.ExecutionReceipt < [tx.Transition < [tx.RecordOutput < records.token > , tx.FutureOutput], 'token', 'transfer_pub_to_priv' > , ] >