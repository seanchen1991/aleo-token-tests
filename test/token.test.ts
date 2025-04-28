import { ExecutionMode } from '@doko-js/core';
import { TokenContract } from '../artifacts/js/token';
import { decrypttoken } from '../artifacts/js/leo2js/token';

const TIMEOUT = 200_000;

// Available modes are evaluate | execute (Check README.md for further description)
const mode = ExecutionMode.SnarkExecute;
// Contract class initialization
const contract = new TokenContract({ mode });

// This maps the accounts defined inside networks in aleo-config.js and return array of address of respective private keys
const [admin, recipient] = contract.getAccounts();

beforeAll(async() => {
  if ((mode as ExecutionMode) == ExecutionMode.SnarkExecute) {
    const tx = await contract.deploy();
    await tx.wait();
  }
}, TIMEOUT);

beforeEach(async() => {
  const resetAdmin = await contract.reset_account(admin);
  const resetRecipient = await contract.reset_account(recipient);
  
  resetAdmin.wait();
  resetRecipient.wait();
}, TIMEOUT);

describe('tests', () => {
  test('public mint', async() => {
    const actualAmount = BigInt(300000);

    const tx = await contract.mint_pub(admin, actualAmount);
    await tx.wait();

    const expected = await contract.account(admin);
    expect(expected).toBe(actualAmount);
  }, TIMEOUT);

  test('private mint', async () => {
    const actualAmount = BigInt(100000);

    const tx = await contract.mint_priv(recipient, actualAmount);
    const [record1] = await tx.wait();
    
    const recipientKey = contract.getPrivateKey(recipient);

    const decryptedRecord = decrypttoken(record1, recipientKey);

    expect(decryptedRecord.amount).toBe(actualAmount);
  }, TIMEOUT);
  
  test('public transfer', async () => {
    const amount1 = BigInt(100000);
    const amount2 = BigInt(30000);

    const mintTx = await contract.mint_pub(admin, amount1);
    await mintTx.wait();

    let adminAmount = await contract.account(admin);

    expect(adminAmount).toBe(amount1);

    const transferTx = await contract.transfer_pub(recipient, amount2);
    await transferTx.wait();

    adminAmount = await contract.account(admin);
    const recipientAmount = await contract.account(recipient);

    expect(adminAmount).toBe(amount1 - amount2);
    expect(recipientAmount).toBe(amount2);
  }, TIMEOUT);

  test('private transfer', async () => {
    const pk = contract.config.privateKey;

    const amount1 = BigInt(1000000000);
    const amount2 = BigInt(100000000);

    const mintTx = await contract.mint_priv(admin, amount1);
    const [encryptedToken1] = await mintTx.wait();
      
    const decryptedRecord = decrypttoken(encryptedToken1, pk);

    const transferTx = await contract.transfer_priv(decryptedRecord, recipient, amount2);
    const [encryptedToken2, record2] = await transferTx.wait();

    const decryptedRecord2 = decrypttoken(encryptedToken2, pk);

    expect(decryptedRecord2.amount).toBe(amount1 - amount2);
  }, TIMEOUT);

  test('public to private transfer', async () => {
    const amount1 = BigInt(500000);
    const amount2 = BigInt(100000);

    const mintTx = await contract.mint_pub(admin, amount1);
    await mintTx.wait();

    let adminAmount = await contract.account(admin);

    expect(adminAmount).toBe(amount1);

    const recipientKey = contract.getPrivateKey(recipient);

    const transferTx = await contract.transfer_pub_to_priv(admin, recipient, amount2);
    const [record] = await transferTx.wait();

    adminAmount = await contract.account(admin);

    const decryptedRecord = decrypttoken(record, recipientKey);

    expect(adminAmount).toBe(amount1 - amount2);
    expect(decryptedRecord.owner).toBe(recipient);
    expect(decryptedRecord.amount).toBe(amount2);
  }, TIMEOUT);

  test('private to public transfer', async () => {
    const pk = contract.config.privateKey;

    const amount1 = BigInt(600000);
    const amount2 = BigInt(500000);

    const mintTx = await contract.mint_priv(admin, amount1);
    const [encryptedToken] = await mintTx.wait();
    
    const decryptedToken = decrypttoken(encryptedToken, pk);

    expect(decryptedToken.amount).toBe(amount1);

    const transferTx = await contract.transfer_priv_to_pub(decryptedToken, recipient, amount2);
    const [record] = await transferTx.wait();

    const recipientAmount = await contract.account(recipient);
    const decryptedRecord = decrypttoken(record, pk);

    expect(recipientAmount).toBe(amount2);
    expect(decryptedRecord.owner).toBe(admin);
    expect(decryptedRecord.amount).toBe(amount1 - amount2);
  }, TIMEOUT);
});

