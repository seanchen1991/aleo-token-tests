import {
  token,
  tokenLeo
} from "../types/token";
import {
  js2leo
} from "@doko-js/core";


export function gettokenLeo(token: token): tokenLeo {
  const result: tokenLeo = {
    owner: js2leo.privateField(js2leo.address(token.owner)),
    balance: js2leo.privateField(js2leo.u64(token.balance)),
    _nonce: js2leo.publicField(js2leo.group(token._nonce)),
  }
  return result;
}